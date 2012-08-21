? my $book = $ctx->book || $ctx->books;
? my $caption = $book->metadata->ctx_cascade_find($ctx, 'caption')->as_scalar || 'never';

<div
     class="tab-pane docs-ajax-tab"
     id="navigation-figures"
     data-tab="<?= $helper->theme_icon('camera'); ?>"
     data-ajax-url="<?= $book->uri_path ?>"
     data-ajax-param="action=navigation_figures"
     data-caption="<?= $caption ?>"
     onshow="$(this).docsFiguresNavigation()">
</div>
