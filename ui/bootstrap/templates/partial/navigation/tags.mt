? my $book = $ctx->book || $ctx->books;

<!-- Tags Navigation -->

<div
     class="tab-pane docs-ajax-tab"
     id="navigation-tags"
     data-tab="<?= $helper->theme_icon('tags'); ?>"
     data-ajax-url="<?= $book->uri_path ?>"
     data-ajax-param="action=navigation_tags"
     onshow="$(this).docsTagcloud()">
</div>
