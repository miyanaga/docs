? my %args = @_;
? my $book_nodes = $ctx->books->ctx_children($ctx);
? my $book = $ctx->book;

<? if ($book && scalar @$book_nodes > 1) { ?>
<li class="docs-books dropdown">
    <a href="#" class="dropdown-toggle">
        <?= raw($helper->theme_icon('book', 1)) ?>
        <?= $book->ctx_title($ctx) ?>
        <b class="caret"></b>
    </a>
    <ul id="books-pulldown" class="dropdown-menu">
        <? for my $b ( @$book_nodes ) { ?>
        <li>
            <a href="<?= $b->uri_path ?>" class="book-switcher">
                <? if ($book == $b) { ?>
                    <span class="pull-right"><?= raw($helper->theme_icon('ok')) ?></span>
                <? } ?>
                <?= $b->ctx_title($ctx) ?>
            </a>
        </li>
        <? } ?>
    </ul>
</li>
<? } ?>
