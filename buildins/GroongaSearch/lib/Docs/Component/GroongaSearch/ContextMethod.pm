package Docs::Component::GroongaSearch::ContextMethod;

use strict;
use warnings;

use File::Spec;
use File::Path;
use Groonga::Console;
use Groonga::Console::Simple::Migration;
use Docs;
use Carp;
use Time::HiRes;
use JSON;

sub groonga_path {
    my $node = shift;
    my $ctx = shift;

    my $book = $node->book || Carp::confess('book not found');
    my $groonga_root = Docs->app->config->_cascade_find(qw/groonga root/)->_scalar;

    my $path = File::Spec->catdir($groonga_root, $book->uri_name);
    unless (-d $path) {
        mkpath($path);
    }

    Carp::confess("can't create groonga drectory $path")
        unless -d $path;

    File::Spec->catdir($path, $ctx->language);
}

sub groonga_console {
    my $node = shift;
    my $ctx = shift;

    my $path = $node->groonga_path($ctx);
    Groonga::Console->new($path)
        || Carp::confess("can't create groonga console object");
}

sub groonga_migrate {
    my $node = shift;
    my $ctx = shift;

    return 1 if $node->temporary->{groonga_migrated}{$ctx->language};

    my $g = $node->groonga_console($ctx);
    my @components = @{Docs->app->components->all};
    my $this;

    my @sorted;
    for my $c ( @components ) {
        if ( $c->id eq 'GroongaSearch' ) {
            $this = $c;
        } else {
            push @sorted, $c;
        }
    }
    unshift @sorted, $this;

    for my $c ( @sorted ) {
        my $script_dir = $c->path_to('migrations/groogna');
        next unless -d $script_dir;

        my $migration = Groonga::Simple::Migration->new(
            key     => $c->id,
            script_dir => $script_dir,
            groonga => $g,
        );

        $migration->run;
    }

    $node->temporary->{groonga_migrated}{$ctx->language} = 1;

    1;
}

sub groonga_step_paths {
    my $node = shift;
    my $ctx = shift;

    my @paths = map { $_->uri_path }
        grep { $_->depth > 0 }
        @{$node->parents};

    wantarray? @paths: \@paths;
}

sub groonga_load {
    my $node = shift;
    my $ctx = shift;
    my $book = $node->book || Carp::confess('book not found');

    my $g = $node->groonga_console($ctx);
    my @headlines = $node->headlines;
    my @tags = $node->tags;

    if ( @tags ) {
        my @rows = map {
            {
                _key    => $_->raw,
                book    => $book->uri_name,
                group   => $_->group,
                label   => $_->label,
            }
        } @tags;

        my $command .= "load --table Tag\n" . to_json(\@rows);
        utf8::decode($command);
        $g->console($command, { utf8 => 0 } );
    }

    my %columns;
    $columns{_key} = $node->uri_path;
    $columns{path} = $node->uri_path;
    $columns{parents} = $node->groonga_step_paths($ctx);
    $columns{title} = $node->title($ctx);
    $columns{text} = $node->plain_text_without_headlines($ctx);
    for my $h (@headlines) {
        $columns{$h->tag} ||= [];
        push @{$columns{$h->tag}}, $h->text;
    }
    for my $t (@tags) {
        $columns{tags} ||= [];
        push @{$columns{tags}}, $t->raw;
    }
    $columns{updated_on} = $node->file_mtime;
    $columns{timestamp} = Time::HiRes::time;

    my $command = "load --table Node\n" . to_json([\%columns]);
    utf8::decode($command);
    $g->console( $command, { utf8 => 0 } );
}

sub groonga_search {
    my $node = shift;
    my $ctx = shift;


}

sub groonga_tagsearch {
    my $node = shift;
    my $ctx = shift;
}

1;
__END__
