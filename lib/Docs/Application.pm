package Docs::Application;

use strict;
use warnings;
use parent 'Tatsumaki::Application';

use Any::Moose;
use Sweets::Application::Components;
use Plack::Middleware::Static::Multi;
use Docs::Application::Handler::Test;

has app_path => ( is => 'ro', isa => 'Str', required => 1 );
has components => ( is => 'ro', isa => 'Sweets::Application::Components', lazy_build => 1, builder => sub {
    my $self = shift;
    my $components = Sweets::Application::Components->new;
    my $core = $components->load_component($self->app_path, 'core');
    $components->load_plugins('private/plugins', 'buildins');
    $components->load_component($core->path_to('private'), 'private');
    $components;
}, handles => [q/config/] );
has static_paths => ( is => 'rw', isa => 'ArrayRef', default => sub { [] } );

our $INSTANCE;

sub instance {
    return $INSTANCE if $INSTANCE;

    my $pkg = shift;
    my ( $app_path ) = @_;
    $app_path ||= '.';

    $INSTANCE = $pkg->new([
        '/~test/(.+)' => 'Docs::Application::Handler::Test',
        ],
        app_path => $app_path
    );

    $INSTANCE->initialize;
    $INSTANCE;
}

sub initialize {
    my $self = shift;

    # Set static paths.
    $self->static_paths([$self->components->dir_paths_to('ui/static')]);
}

sub compile_psgi_app {
    my $self = shift;
    my $app = $self->SUPER::compile_psgi_app(@_);

    $app = Plack::Middleware::Static::Multi->wrap(
        $app,
        path => sub { s/^\/(?:(favicon\.ico)|static\/)/$1||''/e },
        roots => $self->static_paths,
    );

    $app;
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
