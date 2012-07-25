package Docs::Component::FacebookComment::HelperMethod;

use strict;
use warnings;

use Docs;

{
    sub _facebook_app_id {
        my $app = Docs::app;
        $app->config->cascade_find(qw/facebook_comment app_id/)->as_scalar
            || return '';
    }
}

sub comment_load {
    my $self = shift;
    pop;

    my $app_id = _facebook_app_id || return '';

    return qq|
<div id="fb-root"></div>
<script>(function(d, s, id) {
  var js, fjs = d.getElementsByTagName(s)[0];
  if (d.getElementById(id)) return;
  js = d.createElement(s); js.id = id;
  js.src = "//connect.facebook.net/ja_JP/all.js#xfbml=1&appId=$app_id";
  fjs.parentNode.insertBefore(js, fjs);
}(document, 'script', 'facebook-jssdk'));</script>
|;
}

sub comment_form {
    my $self = shift;
    pop;

    my $app = Docs::app;
    my $app_id = _facebook_app_id || return '';
    my $posts = $app->config->cascade_find(qw/facebook_comment posts/)->as_scalar || 10;
    my $node = $self->context->node || return;
    my $node_path = $node->uri_path;

    return qq|
<style>.fb_iframe_widget,.fb_iframe_widget * { max-width: 100% !important; }</style>
<script>document.write('<div class="fb-comments" data-href="' + location.href + '" data-num-posts="$posts" data-width="1200"></div>');</script>
|;
}

1;
__END__
