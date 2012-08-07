package Docs::Application::Static;

use strict;
use warnings;

use parent qw/Plack::Middleware::Static/;

use Plack::Util::Accessor qw( application );

sub _handle_static {
    my($self, $env) = @_;

    my $path_match = $self->path or return;
    my $path = $env->{PATH_INFO};

    for ($path) {
        my $matched = 'CODE' eq ref $path_match ? $path_match->($_) : $_ =~ $path_match;
        return unless $matched;
    }

    # Convert url path to file path.
    $path =~ s!^/+!!;
    my @paths = File::Spec->splitdir($path);

    my $file = pop @paths || return;

    # Deny file starts with period(.) and document
    return if $file =~ /^\./;
    if ( $file =~ /\.(.+)/ ) {
        return if $self->application->formatter($1);
    }

    # Detect the folder
    my $node = $self->application->books->find_uri(@paths) || return;
    return unless $node->is_folder;

    # Build file path
    $path = File::Spec->catdir( $node->file_path, $file );
    return unless -f $path;

    $self->{file} ||= Plack::App::File->new({ root => '.', encoding => $self->encoding });
    local $env->{PATH_INFO} = $path; # rewrite PATH
    return $self->{file}->call($env);
}

1;
__END__
