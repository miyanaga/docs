package Docs::ContextMethod::Node;

use strict;
use warnings;

use DateTime;
use Sweets::String qw(trim);
use Docs::Model::Node::Tag;
use Docs::Model::Node::Headline;
use Digest::MD5 qw(md5_hex);
use HTML::Entities;

sub url {
    my $node = shift;
    my $ctx = shift;

    $node->uri_path;
}

sub order {
    my $node = shift;
    my $ctx = shift;

    my $order = $node->metadata->ctx_find($ctx, 'order')->as_scalar;
    $order = $node->order unless defined $order;

    int($order);
}

sub hidden {
    my $node = shift;
    my $ctx = shift;

    if ( defined( my $hidden = $node->metadata->ctx_find($ctx, 'hidden')->as_scalar ) ) {
        return $hidden;
    }

    if ( $node->folder && defined( my $show_only = $node->folder->metadata->ctx_find($ctx, 'show_only')->as_array ) ) {
        if ( @$show_only ) {
            for my $name ( @$show_only ) {
                return 0 if $name eq $node->uri_name;
            }
            return 1;
        }
    }

    0;
}

sub children {
    my $node = shift;
    my $ctx = shift;

    my @children = grep {
        !$_->ctx_hidden($ctx) && !$_->is_index;
    } sort {
        $a->ctx_order($ctx) <=> $b->ctx_order($ctx)
    } @{$node->sorted_children('uri')};

    wantarray? @children: \@children;
}

sub number {
    my $node = shift;
    my $ctx = shift;
    pop;

    my $number = 1;
    return '' if $node->depth < 2;
    my $parent = $node->parent || return '';
    my @children = $parent->ctx_children($ctx);
    foreach (@children) {
        # TODO: Pluggable numberer
        return "$number." if $_ == $node;
        $number++;
    }

    return '';
}

sub numbering {
    my $node = shift;
    my $ctx = shift;
    pop;

    my @parents = reverse $node->parents_and_self;
    join('', map { $_->ctx_number($ctx) } @parents );
}

sub updated_on {
    shift->file_mtime;
}

sub title {
    my $node = shift;
    my $ctx = shift;

    my $title = $node->metadata->ctx_find($ctx, 'title')->as_scalar
        || $node->naming->title;

    $title = $node->parent->ctx_title($ctx)
        if $node->is_index && $node->parent && $title eq $node->uri_name;

    $title;
}

sub author {
    my $node = shift;
    my $ctx = shift;
    pop;

    my $author = $node->ctx_stash($ctx, 'author');
    return $author if defined($author);

    $author = $node->metadata->ctx_cascade_find($ctx, 'author')->as_scalar || '';
    $node->ctx_stash($ctx, 'author', $author);
}

sub author_name {
    my $node = shift;
    my $ctx = shift;

    my $name = $node->ctx_stash($ctx, 'author_name');
    return $name if defined($name);

    $name = $node->ctx_author($ctx);
    if ( $name =~ s/<([^>]+)>//s ) {
        $name = trim($name);
    }

    $node->ctx_stash($ctx, 'author_name', $name);
}

sub author_email {
    my $node = shift;
    my $ctx = shift;

    my $email = $node->ctx_stash($ctx, 'author_email');
    return $email if defined($email);

    $email = $node->ctx_author($ctx);
    if ( $email =~ /<([^>]+)>/s ) {
        $email = trim($1);
    } else {
        $email = '';
    }

    $node->ctx_stash($ctx, 'author_email', $email);
}

sub author_email_serial {
    my $node = shift;
    my $ctx = shift;

    my $email = $node->ctx_author_email($ctx);
    md5_hex($email);
}

sub first_paragraph {
    my $node = shift;
    my $ctx = shift;

    my $fp = $node->ctx_stash($ctx, 'first_paragraph');
    return $fp if defined $fp;

    $fp = '';
    my $body = $node->ctx_body($ctx);
    if ( $body =~ m!<p(\s+[^>]*|\s*)>(.+?)</p>!is ) {
        $fp = $2;
    }

    $node->ctx_stash($ctx, 'first_paragraph', $fp);
    $fp;
}

sub excerpt {
    my $node = shift;
    my $ctx = shift;

    my $excerpt = $node->ctx_stash($ctx, 'excerpt');
    return $excerpt if $excerpt;

    $excerpt = $node->ctx_lead($ctx)
        || $node->ctx_first_paragraph($ctx)
        || '';

    # Flatten
    $excerpt =~ s!<[^>]+>!!isg;
    $excerpt =~ s!\s+! !isg;

    # Length or words
    my $leader = $node->metadata->ctx_cascade_find($ctx, qw/excerpt_leader/)->as_scalar || '...';
    my $len = length($excerpt);
    if ( my $length = $node->metadata->ctx_cascade_find($ctx, qw/excerpt_length/)->as_scalar ) {
        $length = int($length);
        $excerpt = substr($excerpt, 0, $length);
        $excerpt .= $leader if length($excerpt) < $len;
    } elsif ( my $words = $node->metadata->ctx_cascade_find($ctx, qw/excerpt_words/)->as_scalar ) {
        $words = int($words);
        $excerpt = join( ' ', grep { $_ } (split /\s+/, $excerpt)[0..$words] );
        $excerpt .= $leader if length($excerpt) < $len;
    }

    $node->ctx_stash($ctx, 'excerpt', $excerpt);
    $excerpt;
}

sub lead {
    my $node = shift;
    my $ctx = shift;

    my $lead = $node->ctx_stash($ctx, 'lead');
    return $lead if defined($lead);

    $lead = $node->metadata->ctx_find($ctx, 'lead')->as_scalar || '';

    $node->ctx_stash($ctx, 'lead', $lead);
    $lead;
}

sub plain_lead {
    my $node = shift;
    my $ctx = shift;

    my $lead = $node->ctx_lead($ctx) || return '';
    $lead =~ s!<[^>]*>! !sg;
    $lead =~ s!^\s+!!s;
    $lead =~ s!\s+$!!s;

    $lead;
}

sub body_without_lead {
    my $node = shift;
    my $ctx = shift;

    my $body = $node->ctx_stash($ctx, 'body_without_lead');
    return $body if defined($body);

    $body = $node->ctx_body($ctx);
    $body =~ s/^(.*)(?=<h1)//is;

    $node->ctx_stash($ctx, 'body_without_lead', $body);
    $body;
}

sub body {
    my $node = shift;
    my $ctx = shift;

    my $body = $node->ctx_stash($ctx, 'body');
    return $body if defined($body);

    my $source = $node->source || return '';

    # Language filter.
    $source =~ s|<docs:lang\s+([a-z]+)>\s*(.*?)\s*</docs:lang>|{$1 eq $ctx->language->key? $2: ''}|iges;

    # docs:pre, docs:escape
    $source =~ s!<docs:(pre)(\s+[^>]*|\s*)>(.*?)</docs:\1>!{
        my $attr = $2;
        my $inner = encode_entities($3, q{<>&"});
        lc($1) eq 'pre'? qq{<pre$attr>$inner</pre>}: $inner;
    }!iegs;

    #my $macro = $ctx->new_macro( template => $source );
    #$body = $macro->render || $source;

    $body = $node->formatter->format($source);

    $node->ctx_stash($ctx, 'body', $body || '');
    $body;
}

sub html {
    my $node = shift;
    my $ctx = shift;

    my $body = $node->ctx_body($ctx);

    my $helper = $ctx->new_helper || return $body;
    $body =~ s!<docs:(node|link|tag)\s+([^>\s]+)\s*/?>!{
        my $result = $&;
        my ( $type, $arg ) = ( lc($1), $2 );
        if ( $type eq 'node' || $type eq 'link' ) {
            if ( my $target = $node->path_find($arg) ) {
                my %attrs;
                if ( $result && $arg && $arg =~ m/#(.*)$/ ) {
                    $attrs{hash} = $1;
                }
                $result = $helper->link_to_node($target, %attrs) || $result;
            }
        } elsif ( $type eq 'tag' ) {
            my $tag = Docs::Model::Node::Tag->new(
                raw => $arg,
                node => $node,
            );
            $result = $helper->link_to_tag($tag) || $result;
        }
        $result;
    }!iegs;

    # docs:module
    $body =~ s!<docs:(module)\s+([^>])>(.*?)</docs:\1>!{
        my $app = Docs::app();
        my $template = 'modules/' . $2;
        my $yaml = $3;
        try {
            my $variant = Sweets::Variant->new;
            $variant->from_yaml($yaml);
            $app->ui->ctx_render($ctx, $variant->raw)->as_string;
        } catch {
            'docs:module error : ' . $_;
        }
    }!iegs;

    $body;
}

sub plain_text {
    my $node = shift;
    my $ctx = shift;

    my $body = $node->ctx_body($ctx);
    $body =~ s!<[^>]*>! !sg;

    $body;
}

sub plain_text_without_headlines {
    my $node = shift;
    my $ctx = shift;

    my $body = $node->ctx_body($ctx);
    $body =~ s!<(h[1-6])(?:.*?)>(.+?)</\1>!!isg;
    $body =~ s!<[^>]*>! !sg;

    $body;
}

sub headlines {
    my $node = shift;
    my $ctx = shift;

    my $html = $node->ctx_body($ctx);
    my @headlines;
    while ( $html =~ m!<(h[1-6])(?:.*?)>(.+?)</\1>!isg ) {
        my $h = Docs::Model::Node::Headline->new(
            node    => $node,
            tag     => $1,
            text    => $2,
        );
        push @headlines, $h;
    }

    return wantarray? @headlines: \@headlines;
}

sub raw_tags {
    my $node = shift;
    my $ctx = shift;

    my @tags = $node->metadata->ctx_find($ctx, 'tags')->as_array;
    wantarray? @tags: \@tags;
}

sub tags {
    my $node = shift;
    my $ctx = shift;

    my @tags = map { Docs::Model::Node::Tag->new(
        node => $node,
        raw => $_
    ) } @{$node->ctx_raw_tags($ctx)};

    wantarray? @tags: \@tags;
}

sub tags_include_body {
    my $node = shift;
    my $ctx = shift;

    my %tags = map { $_ => 1 } @{$node->ctx_raw_tags($ctx)};
    my $body = $node->ctx_body($ctx);

    while ( $body =~ m!<docs:tag\s+([^>\s]+)\s*/?>!isg ) {
        $tags{$1} = 1;
    }

    my @tags = map { Docs::Model::Node::Tag->new(
        node => $node,
        raw => $_
    ) } keys %tags;

    wantarray? @tags: \@tags;
}

sub normalize {
    my $node = shift;
    my $ctx = shift;
    my $original = pop;
    my $methods = shift;
    my $depth = shift;

    my %hash;
    for my $m ( @$methods ) {
        if ( $node->can($m) ) {
            $hash{$m} = $node->$m( $ctx, @_ );
        }
    }

    $depth-- if defined $depth;
    if ( !defined($depth) || $depth >= 0 ) {
        my %children;
        my $children = $node->children('uri');
        while ( my ( $uri, $child ) = each %$children ) {
            $children{$uri} = $child->ctx_normalize( $ctx, $methods, $depth, @_ );
        }
        $hash{children} = \%children;
    }

    \%hash;
}

sub _datetime_format {
    my $format = shift;
    my $node = shift;
    my $ctx = shift;
    pop;

    $node->metadata->ctx_cascade_find($ctx, 'format', $format)->as_scalar || $format;
}

sub datetime_format {
    _datetime_format('datetime', @_);
}

sub date_format {
    _datetime_format('date', @_);
}

sub format_epoch {
    my $node = shift;
    my $ctx = shift;
    my $orig = pop;
    my ( $epoch, $format ) = @_;
    $format = _datetime_format($format, $node, $ctx);

    my $dt = DateTime->from_epoch( epoch => $epoch );
    $dt->strftime($format);
}

sub copyright {
    my $node = shift;
    my $ctx = shift;
    pop;

    my $copyright = $node->metadata->ctx_cascade_find($ctx, 'copyright')->as_scalar || return '';
    my $dt = DateTime->now;
    $dt->strftime($copyright);
}

sub seealso {
    my $node = shift;
    my $ctx = shift;
    pop;

    my $app = Docs::app();
    my $seealso = $node->metadata->ctx_find($ctx, 'seealso')->as_array || [];
    my @results = grep { $_ } map { $app->books->path_find($_) } @$seealso;

    wantarray? @results: \@results;
}

sub _sibling {
    my $method = shift;
    my $node = shift;
    my $ctx = shift;
    pop;

    my $target;
    while ( $node = $node->$method() ) {
        unless ( $node->ctx_hidden($ctx) ) {
            $target = $node;
            last;
        }
    }

    $target;
}

sub next { _sibling('next_sibling', @_); }
sub prev { _sibling('prev_sibling', @_); }

sub flat_next {
    my $node = shift;
    my $ctx = shift;
    pop;

    while ( $node ) {
        if ( my $next = $node->ctx_next($ctx) ) {
            return $next;
        }
        $node = $node->parent;
    }

    undef;
}

sub glossary {
    my $node = shift;
    my $ctx = shift;
    pop;

    my $set = $node->ctx_stash($ctx, 'glossary_set');
    unless ( $set ) {
        $set = $node->metadata->cascade_set('glossary');
        $node->ctx_stash($ctx, 'glossary_set', $set);
    }

    my $words = $set->merge_hashes->as_hash || {};
    my $glossary = $node->new_metadata($words);

    my %result = map {
        my $keyword = $glossary->ctx_find($ctx, $_, 'keyword')->as_scalar || $_;
        my $desc = $glossary->ctx_find($ctx, $_, 'desc')->as_scalar
            || $glossary->ctx_find($ctx, $_, 'description')->as_scalar
            || '';

        my $link;
        if ( $link = $glossary->ctx_find($ctx, $_, 'link')->as_scalar || '' ) {
            if ( my $link_node = $node->path_find($link) ) {
                $link = $link_node->normalized_uri_path;
            }
        }

        ( lc($keyword) => { keyword => $keyword, description => $desc, link => $link } );
    } keys %$words;

    return \%result;
}

1;
__END__
