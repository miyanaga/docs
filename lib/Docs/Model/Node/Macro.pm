package Docs::Model::Node::Macro;

use strict;
use warnings;

use parent 'Sweets::Text::NanoTemplate';
use Any::Moose;

has context => ( is => 'ro', isa => 'Docs::Context', required => 1 );
has helper => ( is => 'ro', isa => 'Docs::UI::Helper', lazy => 1, default => sub {
    shift->context->new_helper
});

sub BUILD {
    my $self = shift;
    my $app = Docs->app;

    $self->prefix('docs');

    if ( my $blocks = $app->macros->{block} ) {
        $self->handles_block( %$blocks );
    }
    if ( my $functions = $app->macros->{function} ) {
        $self->handles_function( %$functions );
    }
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__
