package Docs;

use 5.012004;
use strict;
use warnings;

our $NAME = 'Docs';
our $VERSION = '0.61';
our $APP_CLASS = 'Docs::Application';

use Docs::Application;

sub app {
    shift if eval { $_[0] && $_[0] eq 'Docs' };
    $APP_CLASS->instance(@_);
}

1;
__END__

=head1 NAME

Docs - Perl extension for sweet application framework.

=head1 SYNOPSIS

  use Docs;

=head1 DESCRIPTION

Blah blah blah.

=head2 EXPORT

None by default.



=head1 SEE ALSO


=head1 AUTHOR

Kunihiko Miyanaga, E<lt>miyanaga@ideamans.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kunihiko Miyanaga

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.12.4 or,
at your option, any later version of Perl 5 you may have available.


=cut
