package Groonga::Console::Simple::Request;

use strict;
use warnings;

use Encode;
use Any::Moose;
use Groonga::Console;
use Time::HiRes qw(time gettimeofday tv_interval);

has command => ( is => 'rw', isa => 'Str' );
has args => ( is => 'ro', isa => 'HashRef', default => sub { {} } );
has data => ( is => 'rw', isa => 'Any' );
has result_class => ( is => 'rw', isa => 'Str', default => 'Groonga::Console::SimpleResult' );

sub to_string {
    my $self = shift;

    my @partials;
    while ( my ( $name, $value ) = each %{$self->args} ) {
        push @partials, qq{--$name $value};
    }
    @partials = sort { $a cmp $b } @partials;

    unshift @partials, $self->command;

    my $str = join( ' ', @partials );
    my $data = ref $self->data? to_json($self->data): $self->data;
    $str .= "\n" . $data if $data;

    $str;
}

sub execute {
    my $self = shift;
    my ( $groonga, $text ) = @_;
    my @start = gettimeofday;

    my $command = $self->to_string;
    $command = Encode::encode_utf8($command) if utf8::is_utf8($command);
    my $str = $groonga->console($command);

    if ( $text ) {
        $command = $text;
        $command = Encode::encode_utf8($command) if utf8::is_utf8($command);
        $str = $groonga->console($command);
    }

    my $result = $self->result_class->new(
        request => $self,
        raw_string => $str || '',
    );
    $result->duration( tv_interval( \@start ) );

    $result;
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;


package Groonga::Console::Simple::Request::Select;

use strict;
use warnings;

use Any::Moose;
use base 'Groonga::Console::Simple::Request';

sub BUILD {
    my $self = shift;

    $self->command('select');
    $self->result_class('Groonga::Console::Simple::Result::Select');
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;


package Groonga::Console::Simple::Result;

use Any::Moose;

has request => ( is => 'ro', isa => 'Groonga::Console::Simple::Request', required => 1 );
has raw_string => ( is => 'ro', isa => 'Str', required => 1 );
has duration => ( is => 'rw', isa => 'Num', default => 0 );

no Any::Moose;
__PACKAGE__->meta->make_immutable;


package Groonga::Console::Simple::Result::Select;

use strict;
use warnings;
use base 'Groonga::Console::Simple::Result';

use Any::Moose;
use JSON;
use Encode;

has index => ( is => 'rw', isa => 'Int', default => 0 );
has raw => ( is => 'ro', isa => 'ArrayRef', lazy_build => 1, builder => sub {
    my $self = shift;
    my $raw = eval {
        from_json( $self->raw_string, { utf8 => 1 } );
    };
    ref $raw eq 'ARRAY'? $raw: [];
});
has results => ( is => 'ro', isa => 'ArrayRef', lazy_build => 1, builder => sub {
    my $self = shift;
    my $results = $self->raw->[$self->index];
    ref $results eq 'ARRAY'? $results: [[0], [], []];
});
has hit => ( is => 'ro', isa => 'Int', lazy_build => 1, builder => sub {
    shift->results->[0]->[0] || 0;
});
has count => ( is => 'ro', isa => 'Int', lazy_build => 1, builder => sub {
    my $count = scalar @{shift->results} - 2;
    $count < 0? 0: $count;
});
has headers => ( is => 'ro', isa => 'ArrayRef', lazy_build => 1, builder => sub {
    my $self = shift;
    my @headers = map { $_->[0] } @{$self->results->[1]};
    \@headers;
});
has header_types => ( is => 'ro', isa => 'HashRef', lazy_build => 1, builder => sub {
    my $self = shift;
    my %types = map { $_->[0] => $_->[1] } @{$self->results->[1]};
    \%types;
});

sub hash_array {
    my $self = shift;
    my @result;

    my @headers = @{$self->headers};
    for ( my $i = 2; $i < scalar @{$self->results}; $i++ ) {
        my $row = $self->results->[$i];
        my %record;
        for ( my $j = 0; $j < scalar @headers; $j++ ) {
            my $header = $headers[$j];
            my $value = $row->[$j];

#            if ( ref $value eq 'ARRAY' ) {
#                $value = [ map { utf8::is_utf8($_)? $_: Encode::decode_utf8($_) } @$value ];
#            } elsif ( ref $value eq '' ) {
#                $value = Encode::decode_utf8($value)
#                    unless utf8::is_utf8($value);
#            }
            $record{$header} = $value;
        }
        push @result, \%record;
    }

    \@result;
}

sub drilldown {
    my $self = shift;
    my $pkg = ref $self;

    $pkg->new(
        request => $self->request,
        raw_string => $self->raw_string,
        duration => $self->duration,
        index => $self->index + 1,
        raw => $self->raw,
    );
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;

package Groonga::Console::Simple::Request::Load;

use strict;
use warnings;

use Any::Moose;
use base 'Groonga::Console::Simple::Request';
use JSON;

sub BUILD {
    my $self = shift;

    $self->command('load');
    $self->result_class('Groonga::Console::Simple::Result');
}

sub execute {
    my $self = shift;
    my ( $groonga, $data ) = @_;
    $data = [ $data ] if ref $data eq 'HASH';

    my $json = to_json($data);
    my $result = $self->SUPER::execute($groonga, $json);

    $result;
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__
