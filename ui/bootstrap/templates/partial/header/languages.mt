? my %args = @_;
? my $languages = $ctx->book? $ctx->book->languages: $ctx->books->languages;

<? if ($languages && scalar @$languages) { ?>
<li class="docs-languages dropdown">
    <a href="#" class="dropdown-toggle">
        <?= raw($helper->theme_icon('globe', 1)) ?>
        <?= $ctx->language->local_label ?>
        <b class="caret"></b>
    </a>
    <ul id="docs-languages-pulldown" class="dropdown-menu">
        <? for my $l ( @$languages ) { ?>
        <li>
            <a href="#" class="docs-language-switcher" data-lang="<?= $l->key ?>">
                <? if ($ctx->lang eq $l->key) { ?>
                    <span class="pull-right"><?= raw($helper->theme_icon('ok')) ?></span>
                <? } ?>
                <?= $l->local_label ?>
            </a>
        </li>
        <? } ?>
    </ul>
</li>
<? } ?>
