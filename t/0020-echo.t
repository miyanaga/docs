use Plack::Test;
use Test::More;
use HTTP::Request::Common;
use Tatsumaki::Application;

use Docs;

my $app = Docs::app;
test_psgi $app, sub {
    my $cb = shift;
    my $res = $cb->(GET "http://localhost/~test/echo?echo=hello");

    ok $res->is_success;
    is $res->code, 200;
    is $res->content, 'hello';

    $res = $cb->(GET "http://localhost/~test/unknown");
    is $res->content, 'unknown test';
};

done_testing;
