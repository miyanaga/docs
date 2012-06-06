package Docs::Model::Util::NodeName;

use strict;
use warnings;

use Any::Moose;
use File::Spec;
use URI::Escape;

has file => ( is => 'rw', isa => 'Str' );
has title => ( is => 'rw', isa => 'Str' );
has name => ( is => 'rw', isa => 'Str' );
has order => ( is => 'rw', isa => 'Int', default => 0 );
has language => ( is => 'rw', isa => 'Str' );
has extension => ( is => 'rw', isa => 'Str' );
has error => ( is => 'rw', isa => 'Str' );
has need_error => ( is => 'rw', isa => 'Bool', default => 0 );

around [qw/title name language extension/] => sub {
    my $orig = shift;
    my $self = shift;
    return $self->$orig unless @_;

    my $value = uri_unescape($_[0]);
    $self->$orig($value);
};

sub parse {
    my $pkg = shift;
    my $self = $pkg->new;
    my ( $file_path, $need_error ) = @_;
    $self->need_error($need_error);

    my @paths = File::Spec->splitdir($file_path);
    my $full_name = pop @paths || return $self->with_error("Required file name or path");
    $self->file($full_name);

    # Escape separators.
    $full_name =~ s/\.\./%2e/g;
    $full_name =~ s/\@\@/%40/g;

    # Split with dots.
    my @by_dots = split( /\./, $full_name );
    return $self->with_error("$full_name has to many dots") if @by_dots > 3;
    my $file_name = shift @by_dots;
    return $self->with_error("$full_name has no title or name") unless $file_name;

    # Extension and language.
    $self->extension(uri_unescape(pop @by_dots || ''));
    $self->language(pop @by_dots || '');

    # Order
    if ( $file_name =~ s/^([0-9]+)-// ) {
        $self->order(int($1));
    }

    # Title and uri name.
    my @by_at = split( /(?<!\@)\@/, $file_name );
    return $self->with_error("$full_name has too many atmarks") if scalar @by_at > 2;
    $self->name(pop @by_at);
    $self->title(pop @by_at || $self->name);

    $self;
};

sub with_error {
    my $self = shift;
    $self->error(@_);
    $self->need_error? $self: undef;
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__
