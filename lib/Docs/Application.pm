package Docs::Application;

use strict;
use warnings;
use parent 'Tatsumaki::Application';

use Any::Moose;
use Sweets::Application::Components;
use Plack::Middleware::Static::Multi;
use Docs::Application::Handler::Test;
use Docs::Model::Node::Books;

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
has formatters => ( is => 'ro', isa => 'HashRef', default => sub { {} } );
has books => ( is => 'ro', isa => 'Docs::Model::Node::Books', lazy_build => 1, builder => sub {
    my $self = shift;
    my $books = Docs::Model::Node::Books->new;
    $books->uri_name( '' );
    $books->file_name( $self->config->_cascade_find('books', 'root')->_scalar || 'private/books' );
    $books->rebuild;
    $books;
} );

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

    # Load books.

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

sub formatter {
    my $self = shift;
    my ( $key ) = @_;

    return $self->formatters->{$key} if $self->formatters->{$key};

    if ( my $fmt = $self->config->_cascade_find('formatters', $key)->_hash ) {
        if ( my $pkg = delete $fmt->{class} || delete $fmt->{package} ) {
            if ( eval qq{require $pkg;} ) {
                return $self->formatters->{$key} = $pkg->new(%$fmt);
            } else {
                print STDERR "$@\n";
            }
        }
    }

    die 'Formatter: _default is not found.' if $key eq '_default';
    $self->formatters->{$key} = $self->formatter('_default');
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
