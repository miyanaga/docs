package Docs::Context;

use strict;
use warnings;
use parent qw(Sweets::Aspect::Stashable);

use Any::Moose;
use NetAddr::IP;
use Docs::UI::Helper;
use Docs::UI::Module;

has cookies_expires_days => ( is => 'rw', isa => 'Int', default => 365 );
has cookieing => ( is => 'ro', isa => 'ArrayRef', default => sub { [qw/lang search_per_page navigation/] } );
has lang => ( is => 'rw', isa => 'Str', default => sub {
    Docs::app()->preferred_lang;
});
has node => ( is => 'rw', isa => 'Docs::Model::Node', lazy_build => 1, builder => sub {
    Docs::app()->books;
});
has handler => ( is => 'rw', isa => 'Docs::Application::Handler', trigger => sub {
    my $self = shift;
    $self->from_cookies;
});
has path_info => ( is => 'rw', isa => 'Str', default => '/' );
has paths => ( is => 'rw', isa => 'ArrayRef', lazy_build => 1, builder => sub {
    [ grep { $_ } split '/', shift->path_info ];
});
has search_per_page => ( is => 'rw', isa => 'Int', default => 10 );
has navigation => ( is => 'rw', isa => 'Str', default => '' );

has app => ( is => 'rw', isa => 'Docs::Application', lazy_build => 1, builder => sub {
    Docs::app();
});

has is_admin => ( is => 'rw', isa => 'Bool', lazy => 1, default => sub {
    my $self = shift;
    my $app = Docs->app;

    my $networks = $app->config->cascade_find(qw/admin_networks/)->as_hash || return 1;
    for my $location ( keys %$networks ) {
        my $network = $networks->{$location} || next;
        my $subnets = $app->config->cascade_find( 'admin_networks', $location, 'allow_from' )->as_array || next;
        next unless @$subnets;
        my $headers = $app->config->cascade_find( 'admin_networks', $location, 'http_header' )->as_array;
        push @$headers, qw/REMOTE_ADDR HTTP_X_FORWARDED_FOR HTTP_X_REAL_IP/ unless @$headers;

        for my $header ( @$headers ) {
            my $value = $self->handler->request->env->{$header}
                || next;
            my $remote = NetAddr::IP->new($value);
            for my $subnet ( @$subnets ) {
                $subnet = NetAddr::IP->new($subnet);
                return 1 if $subnet->contains($remote);
            }
        }
    }

    0;
});

sub language {
    my $self = shift;
    my $app = Docs::app();
    $app->language($self->lang) || $app->preferred_language;
}

sub cookies_expires_on {
    time + 60 * 60 * 24 * shift->cookies_expires_days
}

sub document {
    my $node = shift->node || return;
    $node->is_folder
        ? $node->find_uri('index') || $node
        : $node;
}

sub has_node_in_path {
    my $self = shift;
    my ( $node ) = shift || return 0;
    my @paths = split '/', $self->path_info;

    # Ignore last index
    pop @paths if $paths[-1] && $paths[-1] eq 'index';
    return 0 if scalar @paths <= 2;

    $node->is_in_uri_path(@paths);
}

sub folder {
    my $node = shift->node || return;
    $node->is_folder? $node: $node->parent;
}

sub book {
    my $node = shift->node || return;
    $node->book;
}

sub books {
    my $self = shift;
    $self->node? $self->node->books: $self->app->books;
}

sub from_cookies {
    my $self = shift;
    my $handler = $self->handler || return;
    my $parameters = $handler->request->parameters || return;
    my $cookies = $handler->request->cookies || return;

    for my $prop ( @{$self->cookieing} ) {
        next unless eval { $self->can($prop) };
        my $name = "_$prop";
        if ( defined( my $cookie = $cookies->{$name} ) ) {
            $self->$prop($cookie);
        }
    }
}

sub to_cookies {
    my $self = shift;
    my $handler = $self->handler || return;
    my $cookies = $handler->response->cookies || {};
    my $props = @_? \@_: $self->cookieing;

    my $count = 0;
    for my $prop ( @$props ) {
        my $value = $handler->request->parameters->get($prop) || next;
        $self->$prop($value) if $self->can($prop);
        my $name = "_$prop";
        $cookies->{$name} = {
            value => $value,
            path => '/',
            expires => $self->cookies_expires_on,
        };
        $count++;
    }
    $handler->response->cookies($cookies);

    $count;
}

sub new_helper {
    my $self = shift;
    my %args = @_;

    Docs::UI::Helper->new(
        context => $self,
        %args
    );
}

sub new_module {
    my $self = shift;
    my ( $file ) = @_;

    Docs::UI::Module->new(
        file => $file,
    );
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__
