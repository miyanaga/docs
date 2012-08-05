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

    my $node = $app->books->path_find($self->request->path_info || '');
    $node || Tatsumaki::Error::HTTP->throw(404, 'Not Found');

    $ctx->node($node);
    $node;
});

sub get {
    my $self = shift;
    my $ctx = $self->context;
    my $node = $self->node;

    # Dispatch action
    my $action_result = $self->dispatch_action;
    return $action_result if defined($action_result);

    my $template = $node->ctx_template($ctx);
    $self->render($template);
}

sub sitemap {
    my $self = shift;
    my $ctx = $self->context;

    my %args = ( node => $self->node );
    if ( my $active = $self->request->parameters->get('active') ) {
        my $active = $ctx->books->path_find($active);
        $active = $active->parent if $active->is_index;
        $args{active} = $active;
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
