package Docs::Model::Language;

use strict;
use warnings;

use Any::Moose;

has key => ( is => 'ro', isa => 'Str', required => 1 );
has global_label => ( is => 'ro', isa => 'Str', required => 1 );
has local_label => ( is => 'ro', isa => 'Str', required => 1 );
has is_preferred => ( is => 'rw', isa => 'Bool', default => 0 );

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__
