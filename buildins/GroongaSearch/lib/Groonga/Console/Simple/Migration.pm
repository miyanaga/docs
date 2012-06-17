use strict;
use warnings;

package Groonga::Console::Simple::Migration::Script;

use File::Spec;
use File::Path;
use Any::Moose;
use Groonga::Console;

# Groonga::Console->debug_mode(1);

has 'file' => ( is => 'ro', isa => 'Str' );
has 'path' => ( is => 'ro', isa => 'Str' );
has 'age' => ( is => 'ro', isa => 'Int' );
has 'switch' => ( is => 'ro', isa => 'Str' );
has 'name' => ( is => 'ro', isa => 'Str' );

sub gather {
    my $class = shift;
    my ( $dir, $switch, $descend ) = @_;
    $switch ||= lc($switch) || 'up';

    my @scripts;
    if ( opendir(my $dh, $dir) ) {
        while ( my $file = readdir($dh) ) {
            next if $file eq '.' || $file eq '..';
            my ( $age, $sw, $name ) = split( '-', $file, 3 );
            next if !$sw || $sw ne $switch || !$name || !$age;

            push @scripts, $class->new(
                file => $file,
                path => File::Spec->rel2abs( File::Spec->catdir( $dir, $file ) ),
                age => $age, switch => $sw, name => $name
            );
        }
        closedir($dh);
    }

    @scripts = $descend
        ? sort { $b->age <=> $a->age } @scripts
        : sort { $a->age <=> $b->age } @scripts;

    \@scripts;
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;

package Groonga::Console::Simple::Migration;

use Any::Moose;
use Groonga::Console;
use JSON;

has 'migration_table' => ( is => 'ro', isa => 'Str', default => sub { 'Migration' } );
has 'groonga' => ( is => 'ro', isa => 'Groonga::Console', required => 1 );
has 'script_dir' => ( is => 'ro', isa => 'Str', required => 1 );
has 'key' => ( is => 'ro', isa => 'Str', default => sub { '_default' } );
has 'logger' => ( is => 'ro', isa => 'CodeRef', default => sub { sub {} } );

sub current_age {
    my $self = shift;
    my ( $set_age ) = @_;

    # Check current age.
    my $command = sprintf( 'select --table %s --query _key:%s', $self->migration_table, $self->key );
    my @results = $self->groonga->console($command);
    my $json = $results[0];
    my $age = 0;

    # Initialize database if migration_table not exist.
    if ( $json ) {

        my $ret = from_json($json);
        $age = $ret->[0]->[2]->[2] || 0;
    } else {
        my $initialize = File::Spec->catdir( $self->script_dir, 'initialize.grn' );

        # TODO: Fatal error if initialize not found.
        $self->groonga->file($initialize);
    }

    if ( defined($set_age) ) {

        # Update age.
        my $command = sprintf( qq{load --table %s\n[{"_key":"%s","age":%d}]}, $self->migration_table, $self->key, int($set_age) );
        $self->groonga->console($command);
        $age = $set_age;
    }

    $age;
}

sub clear {
    my $self = shift;
    $self->run('clear');
}

sub reset {
    my $self = shift;
    $self->run('reset');
}

sub run {
    my $self = shift;
    my ( $command ) = @_;
    $command ||= '';
    my $age = $self->current_age;

    if ( $command eq 'reset' || $command eq 'clear' ) {
        my $downs = Groonga::Console::Simple::Migration::Script->gather( $self->script_dir, 'down', 1 );
        foreach my $down ( @$downs ) {
            if ( $down->age > $age ) {
                $self->logger->( 'Skip ' . $down->file );
                next;
            }
            $self->logger->( 'Execute ', $down->file );
            my @results = $self->groonga->file($down->path);
            $age = $self->current_age( $down->age - 1 );
        }
    }

    unless ( $command eq 'clear' ) {
        my $ups = Groonga::Console::Simple::Migration::Script->gather( $self->script_dir, 'up' );
        foreach my $up ( @$ups ) {
            if ( $up->age <= $age ) {
                $self->logger->( 'Skip ' . $up->file );
                next;
            }
            $self->logger->( 'Execute ' . $up->file );
            my @results = $self->groonga->file($up->path);

            $self->current_age( $up->age );
        }
    }

    $age = $self->current_age;
    $self->logger->( 'Finished migration aged to ' . $age );

    $age;
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
