package Docs::HelperMethod::Common;

use strict;
use warnings;

use Carp;

sub bootstrap_icon {
    my $self = shift;
    my $icon = shift || Carp::confess('require icon name');
    pop;
    my $white = shift;

    my $class = 'icon-' . $icon;
    $class .= ' icon-white' if $white;
    $self->element('i', class => $class, inner => '');
}

sub format_datetime {
    my $self = shift;
    my $format = shift;
    pop;
    my $epoch = shift || time;

    my $dt = DateTime->from_epoch( epoch => $epoch );
    $dt->strftime($format);
}

1;
__END__
