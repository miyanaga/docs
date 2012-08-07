package Docs::Component::Gravatar::ContextMethod;

use strict;
use warnings;

use Docs;

sub author_gravatar {
    my $node = shift;
    my $ctx = shift;

    my $serial = $node->ctx_author_email_serial($ctx) || return '';
    my $url = $node->metadata->ctx_cascade_find($ctx, 'gravatar', 'url')->as_scalar || return '';

    sprintf($url, $serial);
}

1;
__END__
