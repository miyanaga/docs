? my $folder = $ctx->folder;
? my $document = $ctx->document;
? my $active = $document->is_index? $folder: $document;

<? if ( $folder->depth > 0 ) { ?>
<div class="tab-pane" id="navigation-folder" data-tab="<?= $helper->theme_icon('folder-open'); ?>">
    <ul class="nodes nodes-sitemap docs-cascading nav nav-pills nav-stacked">
    <? my $first = 1; ?>
    <? for my $parent ( grep { $_->depth > 0 } reverse @{$folder->parents_and_self} ) { ?>
        <? unless ($first) { ?></ul><? $first = 0; } ?>
        <li class="<?= $parent == $active? 'active': '' ?>">
            <?= raw($helper->link_to_node($parent)); ?>
        </li>
        <ul class="nodes nodes-sitemap docs-cascading nav nav-pills nav-stacked">
    <? } ?>
    <? for my $child ( @{$folder->ctx_children($ctx)} ) { ?>
        <li class="<?= $child == $active? 'active': '' ?>">
            <?= raw($helper->link_to_node($child)); ?>
        </li>
    <? } ?>
    </ul>
</div>
<? } ?>
