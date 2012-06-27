? my %args = @_;
? my $result = $args{result};
? my $form = $args{form} || '';

<? if ($result) { ?>
<div class="pagination">
    <ul>
        <li class="docs-pager-count disabled">
            <a href="#">
                <?= raw($helper->theme_icon('file')) ?><strong><?= $result->count ?></strong>
            </a>
        </li>
        <? if ( $result->has_previous_page ) { ?>
            <li class="docs-pager-prev"><!--
                --><a href="#" class="docs-search-page-switcher" data-page="<?= $result->previous_page ?>" data-form="<?= $form ?>">&laquo;</a><!--
            --></li>
        <? } ?>
        <? my @windows = $result->windows(3); ?>
        <? for ( my $i = 0; $i < scalar @windows; $i++ ) { ?>
            <? if ( $i > 0 ) { ?>
                <li class="disabled">
                    <a href="#">...</a>
                </li>
            <? } ?>
            <? for my $p ( @{$windows[$i]} ) { ?>
                <li class="<?= $p == $result->page? 'active': '' ?>">
                    <a href="#" class="docs-search-page-switcher" data-page="<?= $p ?>" data-form="<?= $form ?>"><?= $p + 1 ?></a>
                </li>
            <? } ?>
        <? } ?>
        <? if ( $result->has_next_page ) { ?>
            <li class="docs-pager-next"><!--
                --><a href="#" class="docs-search-page-switcher" data-page="<?= $result->next_page ?>" data-form="<?= $form ?>">&raquo;</a><!--
            --></li>
        <? } ?>
    </ul>
</div>
<? } ?>
