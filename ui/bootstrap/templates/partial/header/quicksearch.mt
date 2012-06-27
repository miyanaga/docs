? my $book = $ctx->book;

<? if ($book) { ?>
<li class="dropdown quick-search">
    <form class="navbar-search form-inline pull-right" name="quick-sarch" action="<?= $book->uri_path ?>" method="GET">
        <input type="hidden" name="action" value="search">
        <input type="text" class="search-query quick-search" name="q" data-toggle="dropdown" placeholder="Quick Search">
    </form>
    <a href="#" class="hidden" data-toggle="dropdown"></a>
  <ul class="dropdown-menu"></ul>
</li>
<? } ?>
