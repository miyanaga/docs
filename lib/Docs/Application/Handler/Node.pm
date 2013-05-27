package Docs::Application::Handler::Node;

use strict;
use warnings;
use parent 'Docs::Application::Handler';

use Docs;
use JSON;
use Any::Moose;

has node => ( is => 'ro', isa => 'Docs::Model::Node', lazy_build => 1, builder => sub {
    my $self = shift;
    my $ctx = $self->context;
    my $app = Docs::app();

    my $path = $self->request->path_info;
    my $node = $app->books->path_find($self->request->path_info || '');
    $node || Tatsumaki::Error::HTTP->throw(404, 'Not Found');

    $ctx->node($node);
    $node;
});

sub redirect {
    my $self = shift;
    my ( $url ) = @_;

    $url ||= $self->node;
    if ( ref $url && eval { $url->isa('Docs::Model::Node') } ) {
        $url = $url->normalized_uri_path; # In the case of the argument is a node
    }

    $self->response->header('Location', $url);
    $self->response->status(301);
    return;
}

sub get {
    my $self = shift;
    my $ctx = $self->context;
    my $node = $self->node;

    Docs::log($self, ': GET request to ', $self->request->path_info, sub {
        my $env = $self->request->env;
        defined $env->{QUERY_STRING} ? '?'.$env->{QUERY_STRING} : '';
    })
        if $Docs::is_debug;

    # Dispatch action
    my $action_result = $self->dispatch_action;
    return $action_result if defined($action_result);

    # Switch cookie values like lang
    if ( $ctx->to_cookies ) {
        return $self->redirect($node);
    }

    # Refine path
    if ( $node->normalized_uri_path ne $self->request->path_info ) {
        Docs::log($self, ': Reroute from directory to file: ', $node->normalized_uri_path)
            if $Docs::is_debug;

        return $self->redirect($node);
    }

    my $template = $node->ctx_template($ctx);

    # Prerender html because Text::MicroTemplate::Extend can't render nestedly
    my $html = $node->ctx_html($ctx);
    Docs::log($self, ': HTML generated, the length: ', length($html))
        if $Docs::is_debug;

    $self->render($template, html => $html);
}

sub sitemap {
    my $self = shift;
    my $ctx = $self->context;

    my %args = ( node => $self->node );
    if ( my $active = $self->request->parameters->get('active') ) {
        my $node = $ctx->books->path_find($active);
        $node = $node->parent if $node->is_index;
        $args{active} = $node;
    }
    $self->render('partial/node/sitemap', %args );
}

sub relations {
    my $self = shift;
    my $ctx = $self->context;
    my $node = $self->node;

    my @nodes;

    # See Also
    my @seealso = $node->ctx_seealso($ctx);
    push @nodes, map { $_->ctx_stash($ctx, 'relation', 'eye-open'); $_ } @seealso;

    # Same folder
    if ( !$node->is_folder && $node->parent ) {
        push @nodes, map {
            $_->ctx_stash($ctx, 'relation', 'folder-open');
            $_;
        } @{$node->parent->ctx_children($ctx)};
    }

    # TODO: run callback for same tags

    # Parent
    if ( my $parent = $node->parent ) {
        $parent->ctx_stash($ctx, 'relation', 'arrow-up');
        push @nodes, $parent;
    }

    # Next and prev.
    if ( my $prev = $node->ctx_prev($ctx) ) {
        $prev->ctx_stash($ctx, 'relation', 'arrow-left');
        push @nodes, $prev;
    }
    if ( my $next = $node->ctx_next($ctx) ) {
        $next->ctx_stash($ctx, 'relation', 'arrow-right');
        push @nodes, $next;
    }

    # Make unique by path
    my %unique;
    @nodes = grep {
        my $path = $_->normalized_uri_path;
        $_ == $node
            ? 0
            : $unique{$path}
                ? 0
                : ($unique{$path} = 1);
    } reverse @nodes;

    $self->render('partial/node/relations', nodes => \@nodes );
}

sub navigation_figures {
    my $self = shift;
    my $ctx = $self->context;
    my $node = $self->node;

    my $offset = int($self->request->parameters->get('offset') || 0);
    my $limit = $node->metadata->ctx_cascade_find($ctx, qw/navigation figures/)->as_scalar || 10;
    my $until = $offset + $limit;

    my @figures = $node->ctx_all_figures($ctx);
    my $next = scalar @figures > $until? $until: 0;
    $until = scalar @figures unless $next;
    @figures = @figures[$offset..$until - 1];

    $self->render('partial/node/figures',
        node => $node,
        figures => \@figures,
        offset => $offset,
        limit => $limit,
        next => $next
    );
}

sub glossary {
    my $self = shift;
    my $ctx = $self->context;
    my $node = $self->node;

    my $glossary = $node->ctx_glossary($ctx);
    $self->write($glossary);
}

sub rebuild {
    my $self = shift;
    Tatsumaki::Error::HTTP->throw(403) unless $self->context->is_admin;

    my $app = Docs::app();
    $app->rebuild_books();

    $self->write('finished');
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__
