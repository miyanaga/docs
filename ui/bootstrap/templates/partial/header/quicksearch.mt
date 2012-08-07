? my $book = $ctx->book;

<? if ($book) { ?>
<li class="dropdown docs-quick-search" data-node-url="<?= $book->uri_path ?>">
    <form class="navbar-form pull-left" name="quick-sarch" action="<?= $book->uri_path ?>" method="GET">
        <input type="hidden" name="action" value="search">
        <input type="text" class="keyword" name="q" data-toggle="dropdown" placeholder="Quick Search">
    </form>
    <a href="#quick-search" class="hidden" data-toggle="dropdown"></a>
  <ul class="dropdown-menu docs-quick-search-result"></ul>
</li>
<? } ?>
