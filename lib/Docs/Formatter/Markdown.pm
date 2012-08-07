package Docs::Formatter::Markdown;

use strict;
use warnings;
use parent 'Docs::Formatter';

use Text::Markdown;
use Any::Moose;
use Encode;

has markdown => ( is => 'ro', isa => 'Text::Markdown', lazy_build => 1, builder => sub {
    my $self = shift;
    my $args = $self->args;
    my %args = ref $args eq 'HASH'? %$args: ();
    Text::Markdown->new(%args);
});

sub format {
    my $self = shift;
    my ( $source ) = @_;

    # Remove header comment.
    $source = $self->SUPER::format($source);

    $self->markdown->markdown($source);
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__
