package Docs::UI::Helper;

use strict;
use warnings;
use parent qw(Sweets::Helper::HTML Sweets::Aspect::Stashable::AnyEvent);

use Any::Moose;
use Text::MicroTemplate::Extended;

has context => ( is => 'ro', isa => 'Docs::Context', required => 1 );

sub raw {
    my $self = shift;
    Text::MicroTemplate::encoded_string(@_);
}

sub node_action {
    my $self = shift;
    my ( $node, $action, $queries, $hash ) = @_;
    $queries ||= {};
    $queries->{action} = $action;

    $self->url( $node->uri_path, $queries, $hash );
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__
