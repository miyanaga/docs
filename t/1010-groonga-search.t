use strict;
use warnings;

use Test::More;
use Docs;

my $app = Docs::app;
my $books = $app->books;
my $book = $books->find_uri('example');

{
    my $ctx = $app->new_context(language => 'en');
    # my $result = $book->search('headline');
}

done_testing;
