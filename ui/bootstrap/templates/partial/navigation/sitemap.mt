? my $node = $ctx->book || $ctx->books;
? my $document = $ctx->document || $ctx->books;

<div
     class="tab-pane docs-ajax-tab"
     id="navigation-sitemap"
     data-tab="<?= $helper->theme_icon('list'); ?>"
     data-ajax-url="<?= $node->book->uri_path ?>"
     data-ajax-param="action=sitemap&active=<?= u($document->uri_path); ?>">
</div>
