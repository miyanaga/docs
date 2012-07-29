? my $book = $ctx->book;

<? if ($book) { ?>
<li id="docs-quick-search" class="dropdown quick-search" data-node-url="<?= $book->uri_path ?>">
    <form class="navbar-search form-inline pull-right" name="quick-sarch" action="<?= $book->uri_path ?>" method="GET">
        <input type="hidden" name="action" value="search">
        <input type="text" class="keyword" name="q" data-toggle="dropdown" placeholder="Quick Search">
    </form>
    <a href="#quick-search" class="hidden" data-toggle="dropdown"></a>
  <ul id="docs-quick-search-result" class="dropdown-menu"></ul>
</li>
<? } ?>
