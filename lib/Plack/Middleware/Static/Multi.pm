package Plack::Middleware::Static::Multi;
use strict;
use warnings;
use parent qw/Plack::Middleware::Static/;
use Plack::App::File;

use Plack::Util::Accessor qw( roots );

sub call {
    my $self = shift;
    my $env  = shift;

    for my $root ( @{$self->roots} ) {
        my $res = $self->_handle_static($env, $root);

        if ($res && $res->[0] != 404) {
            return $res;
        }
    }

    return $self->app->($env);
}

sub _handle_static {
    my($self, $env, $root) = @_;

    my $path_match = $self->path or return;
    my $path = $env->{PATH_INFO};

    for ($path) {
        my $matched = 'CODE' eq ref $path_match ? $path_match->($_) : $_ =~ $path_match;
        return unless $matched;
    }

    $self->{file}{$root} ||= Plack::App::File->new({ root => $root || '.', encoding => $self->encoding });
    local $env->{PATH_INFO} = $path; # rewrite PATH
    return $self->{file}{$root}->call($env);
}

1;
__END__
