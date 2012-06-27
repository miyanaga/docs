? my %args = @_;
? my $node = $args{node} || Carp::confess('required node');
? my $sitemap = $args{node};
? my $nolead = $args{nolead};

<div class="docs-node docs-node-digest">
    <h2>
        <?= raw($helper->link_to_node($node, %args)); ?>
        <? my @children = $node->ctx_children($ctx); ?>
        <? if ( $node->is_folder && scalar @children ) { ?>
            <a href="#" class="btn docs-sitemap" data-node="<?= $node->uri_path ?>"><?= raw($helper->theme_icon('list')) ?></a>
        <? } ?>
    </h2>
    <? unless ( $nolead ) { ?>
        <p class="docs-lead"><?= raw($node->ctx_lead($ctx)); ?></p>
    <? } ?>
    <div class="docs-sitemap"></div>
</div>
