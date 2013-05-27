package Docs::Application::Handler;

use strict;
use warnings;
use parent 'Tatsumaki::Handler';

use Any::Moose;

has context => ( is => 'ro', isa => 'Docs::Context', lazy_build => 1, builder => sub {
    my $self = shift;
    my $ctx = Docs::app()->new_context(
        lang => 'en',
        path_info => $self->request->path_info || '/',
    );
    $ctx->handler($self);
    $ctx;
});

sub render {
    my $self = shift;
    my $file = shift;
    my $ctx = $self->context;
    my $app = Docs::app();

    my $result = $app->ui->ctx_render( $ctx, $file, {}, @_ )->as_string;

    Docs::log($self, ': Template rendered, the length: ', length($result))
        if $Docs::is_debug;

    $self->finish($result);
}

sub dispatch_action {
    my $self = shift;
    my $action = $self->request->parameters->get('action') || return;
    $self->can($action) || Tatsumaki::Error::HTTP->throw(501, 'Unknown Action');

    $self->$action();

    1;
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
