? my %args = @_;
? my $node = $args{node} || Carp::confess('required node');
? my $sitemap = $args{node};
? my $nolead = $args{nolead};
? my $parent_title = $args{parent} && $node->parent? $node->parent->ctx_title($ctx): '';

<div class="docs-node docs-node-digest">
    <h2>
        <? if ($parent_title) { ?>
            <small><?= $parent_title ?> &raquo; </small>
        <? } ?>
        <?= raw($helper->link_to_node($node, %args)); ?>
        <? my @children = $node->ctx_children($ctx); ?>
    </h2>
    <? unless ( $nolead ) { ?>
        <p class="docs-lead"><?= raw($node->ctx_excerpt($ctx)); ?></p>
    <? } ?>
    <? if ( $node->is_folder && scalar @children ) { ?>
        <p><a href="#" class="btn docs-sitemap" data-node="<?= $node->uri_path ?>"><?= raw($helper->theme_icon('list')) ?></a></p>
    <? } ?>
    <div class="docs-sitemap"></div>
</div>
