package Docs::UI;

use strict;
use warnings;

use Any::Moose;
use Docs::UI::Helper;
use parent 'Docs::Template';

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
has static_paths => ( is => 'ro', isa => 'ArrayRef', lazy => 1, default => sub {
    shift->_dir_paths_to('static');
});
has include_paths => ( is => 'ro', isa => 'ArrayRef', lazy => 1, default => sub {
    shift->_dir_paths_to('templates');
});

sub ctx_render {
    my $self = shift;
    my $ctx = shift;
    my $file = shift;
    $self->SUPER::render($ctx, $file, {}, @_);
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__
