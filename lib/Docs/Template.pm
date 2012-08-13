package Docs::Template;

use strict;
use warnings;

use Text::MicroTemplate::Extended;

use Any::Moose;
use Text::MicroTemplate;

has include_paths => ( is => 'ro', isa => 'ArrayRef', lazy => 1, default => sub {} );

sub raw { Text::MicroTemplate::encoded_string(@_); }
sub u { raw(Docs::UI::Helper->escape_url(@_)); }
sub js { raw(Docs::UI::Helper->escape_js(@_)); }

sub render {
    my $self = shift;
    my $ctx = shift;
    my $file = shift;
    my $args = shift || {};

    my $helper = $ctx->new_helper;
    my $mt = Text::MicroTemplate::Extended->new(
        include_path => $self->include_paths,
        template_args => { ctx => $ctx, helper => $helper, %$args },
    );

    $mt->render($file, @_);
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__
