package Docs::Component::Navigation::ContextMethod;

use strict;
use warnings;

sub navigation_map {
    my $node = shift;
    my $ctx = shift;
    my $original = pop;
    my ( $methods, $depth ) = @_;
    $methods ||= [qw/title uri_path/];

    $node->normalize( $ctx, $methods, $depth, $original );
}

1;
__END__
