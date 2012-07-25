? my %args = @_;
? my $result = $args{result};
? my $node = $ctx->folder;
? my $q = $args{q} || '';

<? if ($result) { ?>
    <? for my $node ( @{$result->data} ) { ?>
        <? my $parent_title = $node->parent? $node->parent->ctx_title($ctx): ''; ?>
        <li>
            <a href="<?= $node->uri_path ?>">
                <h4>
                    <? if ($parent_title) { ?>
                        <small><?= $parent_title ?></small><small>  &raquo; </small>
                    <? } ?>
                    <?= $node->ctx_title($ctx) ?>
                </h4>
                <? if ( my $lead = $node->ctx_lead($ctx) ) { ?>
                    <div><?= $lead ?></div>
                <? } ?>
            </a>
        </li>
    <? } ?>
    <li class="docs-more">
        <a href="<?= $helper->node_action($node, 'search', { q => $q }) ?>">
            <?= raw($helper->theme_icon('search')) ?>
            <strong><?= $result->count ?></strong>
        </a>
    </li>
<? } ?>
