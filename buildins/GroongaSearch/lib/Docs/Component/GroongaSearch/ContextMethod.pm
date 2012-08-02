package Docs::Component::GroongaSearch::ContextMethod;

use strict;
use warnings;

use File::Spec;
use File::Path;
use Groonga::Console;
use Groonga::Console::Simple::Migration;
use Groonga::Console::Simple::Request;
use Docs::Model::Node::SearchResult;
use Docs;
use Carp;
use Time::HiRes;
use JSON;

sub groonga_path {
    my $node = shift;
    my $ctx = shift;

    my $book = $node->book || Carp::confess('book not found');
    my $groonga_root = Docs->app->config->cascade_find(qw/groonga root/)->as_scalar;

    my $path = File::Spec->catdir($groonga_root, $book->uri_name);
    unless (-d $path) {
        mkpath($path);
    }

    Carp::confess("can't create groonga drectory $path")
        unless -d $path;

    File::Spec->catdir($path, $ctx->lang);
}

sub groonga_console {
    my $node = shift;
    my $ctx = shift;

    my $path = $node->ctx_groonga_path($ctx);
    Groonga::Console->new($path)
        || Carp::confess("can't create groonga console object");
}

sub groonga_migrate {
    my $node = shift;
    my $ctx = shift;
    my $flag = 'groonga_migrated_' . $ctx->lang;

    return 1 if $node->stash( $flag );

    my $g = $node->ctx_groonga_console($ctx);
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
        my $script_dir = $c->path_to('migrations/groonga');
        next unless -d $script_dir;

        my $migration = Groonga::Console::Simple::Migration->new(
            key     => $c->id,
            script_dir => $script_dir,
            groonga => $g,
        );

        $migration->run;
    }

    $node->stash( $flag => 1 );

    1;
}

sub groonga_headlines {
    my $node = shift;
    my $ctx = shift;

    my %headlines;
    for my $h ( $node->ctx_headlines($ctx) ) {
        $headlines{$h->tag} ||= [];
        push @{$headlines{$h->tag}}, $h->text;
    }

    \%headlines;
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
    my @tags = $node->ctx_tags_include_body($ctx);

    {
        my $groonga = $book->ctx_groonga_console($ctx);
        my %data;
        my $tags = [map { $_->raw } @tags];

        $data{_key} = $node->uri_path;
        $data{parents} = $node->ctx_groonga_step_paths($ctx) || [];
        $data{title} = $node->ctx_title($ctx) || '';
        $data{tags} = $tags;
        $data{lead} = $node->ctx_lead($ctx) || '';
        $data{text} = $node->ctx_plain_text_without_headlines($ctx) || '';
        $data{tags} = $node->ctx_raw_tags($ctx) || [];
        $data{updated_on} = $node->file_mtime || 0;
        $data{timestamp} = Time::HiRes::time || 0;

        my $headlines = $node->ctx_groonga_headlines($ctx);
        for my $level (1..6) {
            my $tag = "h$level";
            $data{$tag} = $headlines->{$tag} || [];
        }

        my $request = Groonga::Console::Simple::Request::Load->new(
            args => { table => 'Node' }
        );
        my $result = $request->execute($groonga, \%data);
    }

    {
        my $groonga = $book->ctx_groonga_console($ctx);
        my @data = map {
            {
                _key => $_->raw,
                group => $_->group,
                label => $_->label,
            }
        } @tags;

        my $request = Groonga::Console::Simple::Request::Load->new(
            args => { table => 'Tag' }
        );
        my $result = $request->execute($groonga, \@data);
    }

}

{
    sub _stash_value {
        my $name = shift;
        my $self = shift;
        my $ctx = shift;
        pop;

        $self->ctx_stash( $ctx, $name, @_ );
    }
}

sub stash_score { _stash_value( 'groonga_score', @_ ); }
sub stash_title { _stash_value( 'groonga_title', @_ ); }
sub stash_text { _stash_value( 'groonga_text', @_ ); }
sub stash_lead { _stash_value( 'groonga_lead', @_ ); }
sub stash_headlines { _stash_value( 'groonga_headlines', @_ ); }

sub _keyword_search {
    my $node = shift;
    my $ctx = shift;
    my ( $app, $groonga, $books, $book, $keyword, $pager_req ) = @_;

    my $path = $node->uri_path;
    my $weights = $app->config->cascade_set(qw/groonga node_columns_weight/)->merge_hashes->as_hash;
    my $match_columns = join ',', map { join '*', $_, $weights->{$_} } keys %$weights;

    my $groonga_req = Groonga::Console::Simple::Request::Select->new(
        args => {
            offset      => $pager_req->offset,
            limit       => $pager_req->per_page,
            table       => 'Node',
            query       => qq("$keyword"),
            filter      => qq('parents\@"$path"'),
            output_columns => '_id,_key,_score,title,lead,text,h1',
            match_columns => $match_columns,
        }
    );

    $groonga_req->execute($groonga);
}

sub _tag_search {
    my $node = shift;
    my $ctx = shift;
    my ( $app, $groonga, $books, $book, $tag, $pager_req ) = @_;

    my $path = $node->uri_path;

    my $groonga_req = Groonga::Console::Simple::Request::Select->new(
        args => {
            offset      => $pager_req->offset,
            limit       => $pager_req->per_page,
            table       => 'Node',
            query       => qq('tags:"$tag"'),
            filter      => qq('parents\@"$path"'),
            output_columns => '_id,_key,_score,title,lead,text,h1',
            match_columns => 'tags',
        }
    );

    $groonga_req->execute($groonga);
}

sub search {
    my $node = shift;
    my $ctx = shift;
    my $original = pop;
    my ( $keyword, $page, $per_page ) = @_;

    my $app = Docs::app();
    my $books = $node->books;
    my $book = $node->book || return;
    my $groonga = $book->ctx_groonga_console($ctx);

    $keyword ||= '';
    $page ||= 0;
    $per_page ||= $app->config->cascade_find(qw/search per_page/)->as_scalar || 10;

    my $pager_req = Docs::Model::Node::SearchRequest->new(
        base => 0,
        page => $page,
        per_page => $per_page,
    );

    my $pager_res = Docs::Model::Node::SearchResult->new(
        request => $pager_req,
        count => 0,
        data => [],
    );

    my $groonga_res;
    if ( $keyword =~ /^tag:([^\s]+)/ ) {
        my $tag = $1;
        $pager_res->search_type('tag');
        $pager_res->search_tag(Docs::Model::Node::Tag->new(node => $book, raw => $tag));
        $groonga_res = _tag_search( $node, $ctx, $app, $groonga, $books, $book, $tag, $pager_req );
    } else {
        $pager_res->search_type('keyword');
        $pager_res->search_keyword($keyword);
        $groonga_res = _keyword_search( $node, $ctx, $app, $groonga, $books, $book, $keyword, $pager_req );
    }

    my @records = map {
        my @path = grep { $_ } split '/', $_->{_key};
        my $node = $books->find_uri(@path) || return;
        $node->ctx_stash_score( $ctx, $_->{_score} );
        $node->ctx_stash_title( $ctx, $_->{title} );
        $node->ctx_stash_text( $ctx, $_->{text} );
        $node->ctx_stash_headlines( $ctx, $_->{h1} );

        $node;
    } @{$groonga_res->hash_array};

    $pager_res->count($groonga_res->hit);
    $pager_res->data(\@records);

    $pager_res;
}

sub navigation_recent {
    my $node = shift;
    my $ctx = shift;
    pop; # original
    my ( $limit ) = @_;

    my $book = $node->book || return;
    my $books = $node->books;
    my $groonga = $book->ctx_groonga_console($ctx);
    my $path = $node->uri_path;

    my $req = Groonga::Console::Simple::Request::Select->new(
        args => {
            offset      => 0,
            limit       => $limit || 10,
            table       => 'Node',
            filter      => qq('parents\@"$path"'),
            output_columns => '_id,_key,_score,title',
            sortby      => '-updated_on',
        }
    );

    my $res = $req->execute($groonga);

    my @records = grep { $_ } map {
        my $path = $_->{_key};
        my $node = $books->path_find($path) || return;
        $node->ctx_stash_title( $ctx, $_->{title} );

        $node;
    } @{$res->hash_array};

    wantarray? @records: \@records;
}

sub navigation_tags {
    my $node = shift;
    my $ctx = shift;
    pop; # original
    my ( $sort ) = @_;

    my $book = $node->book || return;
    my $groonga = $book->ctx_groonga_console($ctx);
    my $path = $node->uri_path;

    my $req = Groonga::Console::Simple::Request::Select->new(
        args => {
            offset      => 0,
            limit       => 0,
            table       => 'Node',
            filter      => qq('parents\@"$path"'),
            output_columns => '_id',
            drilldown   => 'tags',
            drilldown_limit => 100,
        }
    );

    my $res = $req->execute($groonga)->drilldown;

    my @records = map {
        Docs::Model::Node::Tag->new(
            node        => $node,
            raw         => $_->{_key},
            node_count  => $_->{_nsubrecs},
        );
    } grep {
        $_->{_key}
    } @{$res->hash_array};

    if ( $sort ) {
        if ( lc($sort) eq 'asc' ) {
            @records = sort { $a->node_count <=> $b->node_count } @records;
        } else {
            @records = sort { $b->node_count <=> $a->node_count } @records;
        }
    }

    wantarray? @records: \@records;
}

1;
__END__
