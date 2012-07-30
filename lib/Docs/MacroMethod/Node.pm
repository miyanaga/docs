package Docs::MacroMethod::Node;

use strict;
use warnings;

use Carp;

sub node {
    my ( $macro, $args ) = @_;

    my $path = delete $args->{''} || delete $args->{href}
        || return '';
    return '';
}

sub tag {
    my ( $macro, $args ) = @_;

    my $tag = delete $args->{''} || return '';
    $macro->helper->link_to_tag( $tag, %$args );
}

1;
__END__
