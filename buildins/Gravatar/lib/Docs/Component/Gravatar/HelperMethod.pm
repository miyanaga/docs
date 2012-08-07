package Docs::Component::Gravatar::HelperMethod;

use strict;
use warnings;

use Docs;

sub node_author_gravatar {
    my $self = shift;
    my $ctx = $self->context || return '';
    my $node = shift || $ctx->node || return '';
    pop;

    my $url = $node->ctx_author_gravatar($ctx, $node);
    $self->element('img', class => 'docs-author-gravatar', raw_attr => {
        'src' => $url,
    });
}

1;
__END__
