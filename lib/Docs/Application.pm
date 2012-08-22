package Docs::Application;

use strict;
use warnings;
use parent 'Tatsumaki::Application';

use Time::HiRes;
use Try::Tiny;
use AnyEvent;
use Any::Moose;
use Sweets::Application::Components;
use Sweets::Code::Binding;
use Sweets::Callback::Engine;
use Plack::Middleware::Static::Multi;
use Docs::Application::Handler::Test;
use Docs::Application::Handler::Node;
use Docs::Model::Node::Books;
use Docs::Context;
use Docs::ContextMethod;
use Docs::UI;
use Docs::Model::Language;
use Docs::Application::Static;

has app_path => ( is => 'ro', isa => 'Str', required => 1 );
has books_path => ( is => 'ro', isa => 'Str', lazy => 1, default => sub {
    shift->config->cascade_find('books', 'root')->as_scalar || 'private/books'
});
has components => ( is => 'ro', isa => 'Sweets::Application::Components', lazy_build => 1, builder => sub {
    my $self = shift;
    my $components = Sweets::Application::Components->new;
    my $core = $components->load_component($self->app_path, 'core');
    $components->load_plugins('private/plugins', 'buildins');
    $components->load_component($core->path_to('private'), 'private');
    $components;
}, handles => [q/config/] );
has callbacks => ( is => 'ro', isa => 'Sweets::Callback::Engine', lazy_build => 1, builder => sub {
    my $self = shift;
    my $engine = Sweets::Callback::Engine->new;
    my $callbacks = $self->components->config->cascade_set('callbacks')->merge_hashes->as_hash;
    while ( my ( $key, $tuple ) = each %$callbacks ) {
        $tuple->{event} ||= $key;
        $engine->add( $tuple );
    }
    $engine;
});
has formatters => ( is => 'ro', isa => 'HashRef', default => sub { {} } );
has books => ( is => 'rw', isa => 'Docs::Model::Node::Books', lazy_build => 1, builder => sub {
    shift->rebuild_books
} );
has ui => ( is => 'ro', isa => 'Docs::UI', lazy_build => 1, builder => sub {
    Docs::UI->new;
});
has languages => ( is => 'ro', isa => 'HashRef', lazy_build => 1, builder => sub {
    my $self = shift;
    my $preferred = $self->preferred_lang;
    my $hash = $self->config->cascade_set(qw/languages/)->merge_hashes->as_hash;

    my %languages;
    while ( my ( $key, $l ) = each %$hash ) {
        my $global = $l->{global_label} || Carp::confess('application languages entry required global_label');
        $languages{$key} = Docs::Model::Language->new(
            key => $key,
            global_label => $global,
            local_label => $l->{local_label} || $global,
            is_preferred => $key eq $preferred? 1: 0,
        );
    }

    Carp::confess('application defined no languages')
        unless %languages;
    Carp::confess('application defiend no preferred language')
        unless $languages{$preferred};

    \%languages;
});
has preferred_lang => ( is => 'ro', isa => 'Str', lazy_build => 1, builder => sub {
    my $self = shift;
    $self->config->cascade_find(qw/preferred_language/)->as_scalar || 'en';
});
has rebuild_started => ( is => 'rw', isa => 'Num', default => 0 );

sub rebuild_books {
    my $self = shift;
    my $started = Time::HiRes::time;
    $self->rebuild_started($started);

    my $books = Docs::Model::Node::Books->new;
    $books->rebuild_started($started);

    try {
        $books->naming->title('Docs');
        $books->uri_name( '' );
        $books->file_name( $self->books_path );
        $books->rebuild;

        $self->books($books);
    } catch {
        print STDERR "Rebuild cancled: $_\n";
    };
}

sub language {
    my $self = shift;
    my ( $lang ) = @_;
    $self->languages->{$lang};
}

sub preferred_language {
    my $self = shift;
    $self->languages->{$self->preferred_lang};
}

our $INSTANCE;

sub instance {
    return $INSTANCE if $INSTANCE;

    my $pkg = shift;
    my %args = @_;
    $args{app_path} ||= '.';

    $INSTANCE = $pkg->new([
        '/~test/(.+)' => 'Docs::Application::Handler::Test',
        '/(.*)' => 'Docs::Application::Handler::Node',
        ],
        %args,
    );

    $INSTANCE->init;
    $INSTANCE;
}

after init => sub {
    my $self = shift;
    $self->callbacks->run_all( 'app.post_init', $self );
};

sub init {
    my $self = shift;

    # Library paths.
    push @INC, $self->components->dir_paths_to('lib');

    # TODO: Almost repeating...
    # Bind context methods.
    {
        my $methods = $self->config->cascade_set('context_methods')->merge_hashes->as_hash;
        while ( my ( $key, $tuple ) = each %$methods ) {
            next if !$tuple->{method} || !$tuple->{code} || !$tuple->{package};
            my $code = Docs::ContextMethod->new(
                code => $tuple->{code}
            );
            $code->bind( $tuple->{package}, 'ctx_' . $tuple->{method} );
        }
    }

    # Bind handler methods
    {
        my $methods = $self->config->cascade_set('handler_methods')->merge_hashes->as_hash;
        while ( my ( $key, $tuple ) = each %$methods ) {
            next if !$tuple->{method} || !$tuple->{code} || !$tuple->{package};
            my $code = Sweets::Code::Binding->new(
                code => $tuple->{code}
            );
            $code->bind( $tuple->{package}, $tuple->{method} );
        }
    }

    # Bind helper methods.
    {
        my $methods = $self->config->cascade_set(qw/ui helper_methods/)->merge_hashes->as_hash;
        while ( my ( $key, $tuple ) = each %$methods ) {
            next if !$tuple->{method} || !$tuple->{code};
            next if $tuple->{theme} && $tuple->{theme} ne $self->ui->theme;
            my $code = Sweets::Code::Binding->new(
                code => $tuple->{code}
            );
            $code->bind( 'Docs::UI::Helper', $tuple->{method} );
        }
    }

    $self->rebuild_books;

}

sub compile_psgi_app {
    my $self = shift;
    my $app = $self->SUPER::compile_psgi_app(@_);

    $app = Plack::Middleware::Static::Multi->wrap(
        $app,
        path => sub { s/^\/(?:(favicon\.ico)|static\/)/$1||''/e },
        roots => $self->ui->static_paths,
    );

    $app = Docs::Application::Static->wrap(
        $app,
        application => $self,
        path => sub { !/^\./ },
    );

    $app;
}

sub formatter {
    my $self = shift;
    my ( $key ) = @_;
    $key = lc($key);

    return $self->formatters->{$key}
        if defined($self->formatters->{$key});

    if ( my $fmt = $self->config->cascade_set('formatters', $key)->merge_hashes->as_hash ) {
        if ( my $pkg = delete $fmt->{class} || delete $fmt->{package} ) {
            if ( eval qq{require $pkg;} ) {
                return $self->formatters->{$key} = $pkg->new(%$fmt);
            } else {
                print STDERR "$@\n";
            }
        }
    }

    $self->formatters->{$key} = 0;
}

sub new_context {
    my $self = shift;
    my %args = @_;
    $args{lang} ||= $self->preferred_lang;
    Docs::Context->new(%args);
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
