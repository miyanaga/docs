package Docs::Component::FacebookComment::HelperMethod;

use strict;
use warnings;

use Docs;

{
    sub _facebook_comment {
        my $self = shift;
        my $app = Docs::app;
        my $ctx = $self->context || return;
        my $node = $ctx->node || return;

        my $app_id = $node->metadata->ctx_cascade_find($ctx, qw/facebook_comment app_id/)->as_scalar;
        my $posts = $node->metadata->ctx_cascade_find($ctx, qw/facebook_comment posts/)->as_scalar;
        my $url = $node->normalized_uri_path;
        my $hidden = $node->metadata->ctx_cascade_find($ctx, qw/facebook_comment hidden/)->as_scalar;

        ( $app_id, $posts, $url, $hidden );
    }
}

sub comment_load {
    my $self = shift;
    pop;

    my ( $app_id, $posts, $url, $hidden ) = _facebook_comment($self);
    return '' unless $app_id;
    return '' if $hidden;

    return qq|
<div id="fb-root"></div>
<script>(function(d, s, id) {
  var js, fjs = d.getElementsByTagName(s)[0];
  if (d.getElementById(id)) return;
  js = d.createElement(s); js.id = id;
  js.src = "//connect.facebook.net/ja_JP/all.js#xfbml=1&appId=$app_id";
  fjs.parentNode.insertBefore(js, fjs);
}(document, 'script', 'facebook-jssdk'));</script>
<style>
    .facebook-comment { margin-top: 16px; }
    .fb_iframe_widget,.fb_iframe_widget * { max-width: 100% !important; }
    \@media print { .facebook-comment { display: none !important } }
</style>
|;
}

sub comment_form {
    my $self = shift;
    pop;

    my ( $app_id, $posts, $url, $hidden ) = _facebook_comment($self);
    return '' unless $app_id;
    return '' if $hidden;

    return qq|
<div class="facebook-comment">
<script>document.write('<div class="fb-comments" data-href="' + location.href + '" data-num-posts="$posts" data-width="9999"></div>');</script>
</div>
|;
}

1;
__END__
