use Plack::Test;
use Test::More;
use HTTP::Request::Common;
use Tatsumaki::Application;
use utf8;

use Docs;

my $app = Docs::app(books_path => 't/books');
test_psgi $app, sub {
    my $cb = shift;
    my $res = $cb->(GET "http://localhost/~test/echo?echo=hello");

    ok $res->is_success;
    is $res->code, 200;
    is $res->content, 'hello';

    $res = $cb->(GET "http://localhost/~test/path_info");
    is $res->code, 200;
    is $res->content, '/~test/path_info';

    $res = $cb->(GET "http://localhost/example/en/formatters/htmldoc");

    $res = $cb->(GET "http://localhost/~test/unknown");
    is $res->content, 'unknown test';
};

done_testing;
