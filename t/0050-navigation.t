use strict;
use warnings;
use utf8;

use Test::More;
use Docs;

my $app = Docs::app(books_path => 't/books');
my $books = $app->books;
my $book = $books->find_uri('example');

{
    my $ctx = $app->new_context(lang => 'en');
    my $map = $book->ctx_navigation_map($ctx);

    is $map->{ctx_title}, 'Example';
    is scalar(keys(%{$map->{children}->{en}->{children}})), 6;
    is $map->{children}->{en}->{children}->{multilang}->{ctx_title}, 'Multi Language Folder';
    is $map->{children}->{en}->{children}->{multilang}->{children}->{document}->{ctx_title}, 'Multi Language Document';
}

{
    my $ctx = $app->new_context(lang => 'ja');
    my $map = $book->ctx_navigation_map($ctx);

    is $map->{ctx_title}, 'Example';
    is scalar(keys(%{$map->{children}->{en}->{children}})), 6;
    is $map->{children}->{en}->{children}->{multilang}->{ctx_title}, '多言語フォルダ';
    is $map->{children}->{en}->{children}->{multilang}->{children}->{document}->{ctx_title}, '多言語ドキュメント';
}

{
    my $ctx = $app->new_context(lang => 'en');
    my $map = $book->ctx_navigation_map($ctx, undef, 0);

    is $map->{ctx_title}, 'Example';
    is $map->{children}, undef;
}

{
    my $ctx = $app->new_context(lang => 'en');
    my $map = $book->ctx_navigation_map($ctx, undef, 1);

    is $map->{ctx_title}, 'Example';
    is $map->{children}->{en}->{ctx_title}, 'English';
    is $map->{children}->{en}->{children}, undef;
}



done_testing;
