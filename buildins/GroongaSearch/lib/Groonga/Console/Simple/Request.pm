package Groonga::Console::Simple::Request;

use strict;
use warnings;

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
    my ( $groonga ) = @_;
    my @start = gettimeofday;
    my $str = $groonga->console($self->to_string);

    my $result = $self->result_class->new(
        request => $self,
        raw_string => $str,
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

has raw => ( is => 'ro', isa => 'ArrayRef', lazy_build => 1, builder => sub {
    my $self = shift;
    my $data = eval {
        from_json( $self->raw_string, { utf8 => 1 } );
    };
    ref $data eq 'ARRAY' && $data->[0] && ref $data->[0] eq 'ARRAY'? $data->[0]: [[0],[],[]];
});
has hit => ( is => 'ro', isa => 'Int', lazy_build => 1, builder => sub {
    shift->raw->[0]->[0] || 0;
});
has count => ( is => 'ro', isa => 'Int', lazy_build => 1, builder => sub {
    my $count = scalar @{shift->raw} - 2;
    $count < 0? 0: $count;
});
has headers => ( is => 'ro', isa => 'ArrayRef', lazy_build => 1, builder => sub {
    my @headers = map { $_->[0] } @{shift->raw->[1]};
    \@headers;
});

sub hash_array {
    my $self = shift;
    my @result;

    my @headers = @{$self->headers};
    for ( my $i = 2; $i < scalar @{$self->raw}; $i++ ) {
        my $row = $self->raw->[$i];
        my %record;
        for ( my $j = 0; $j < scalar @headers; $j++ ) {
            my $header = $headers[$j];
            my $value = $row->[$j];
            $record{$header} = $value;
        }
        push @result, \%record;
    }

    \@result;
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
