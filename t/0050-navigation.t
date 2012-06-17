use strict;
use warnings;

use Test::More;
use Docs;

my $app = Docs::app;
my $books = $app->books;
my $book = $books->find_uri('example');

{
    my $ctx = $app->new_context(language => 'en');
    my $map = $book->navigation_map($ctx);

    is $map->{title}, 'Example';
    is scalar(keys(%{$map->{children}->{en}->{children}})), 4;
    is $map->{children}->{en}->{children}->{multilang}->{title}, 'Multi Language Folder';
    is $map->{children}->{en}->{children}->{multilang}->{children}->{document}->{title}, 'Multi Language Document';
}

{
    my $ctx = $app->new_context(language => 'ja');
    my $map = $book->navigation_map($ctx);

    is $map->{title}, 'Example';
    is scalar(keys(%{$map->{children}->{en}->{children}})), 4;
    is $map->{children}->{en}->{children}->{multilang}->{title}, '多言語フォルダ';
    is $map->{children}->{en}->{children}->{multilang}->{children}->{document}->{title}, '多言語ドキュメント';
}

{
    my $ctx = $app->new_context(language => 'en');
    my $map = $book->navigation_map($ctx, undef, 0);

    is $map->{title}, 'Example';
    is $map->{children}, undef;
}

{
    my $ctx = $app->new_context(language => 'en');
    my $map = $book->navigation_map($ctx, undef, 1);

    is $map->{title}, 'Example';
    is $map->{children}->{en}->{title}, 'English';
    is $map->{children}->{en}->{children}, undef;
}



done_testing;
