? my $node = $ctx->book || $ctx->books;
? my $document = $ctx->document || $ctx->books;

<div
     class="tab-pane docs-ajax-tab"
     id="navigation-recent"
     data-tab="<?= $helper->theme_icon('time'); ?>"
     data-ajax-url="<?= $node->book->uri_path ?>"
     data-ajax-param="action=navigation_recent&active=<?= u($document->uri_path); ?>">
</div>
