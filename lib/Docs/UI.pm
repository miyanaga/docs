package Docs::UI;

use strict;
use warnings;

use Any::Moose;
use Text::MicroTemplate::Extended;
use Docs::UI::Helper;

{
    sub _dir_paths_to {
        my $self = shift;
        my ( $rel ) = @_;
        my $app = Docs::app();

        [
            @{$app->components->dir_paths_to(join('/', 'ui', $self->theme, $rel))},
            @{$app->components->dir_paths_to(join('/', 'ui/common', $rel))},
        ];
    }
}

has theme => ( is => 'ro', isa => 'Str', lazy_build => 1, builder => sub {
    my $app = Docs::app();
    $app->config->cascade_find(qw/ui theme/)->as_scalar || 'common';
});
has static_paths => ( is => 'ro', isa => 'ArrayRef', lazy_build => 1, builder => sub {
    shift->_dir_paths_to('static');
});
has template_paths => ( is => 'ro', isa => 'ArrayRef', lazy_build => 1, builder => sub {
    shift->_dir_paths_to('templates');
});

sub ctx_render {
    my $self = shift;
    my $ctx = shift;
    my $file = shift;
    my %args = @_;

    my $helper = $ctx->new_helper;
    my $mt = Text::MicroTemplate::Extended->new(
        include_path => $self->template_paths,
        template_args => { ctx => $ctx, helper => $helper },
    );

    $mt->render($file, %args);
}

sub raw { Docs::UI::Helper->raw(@_); }
sub u { raw(Docs::UI::Helper->escape_url(@_)); }
sub js { raw(Docs::UI::Helper->escape_js(@_)); }

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__
