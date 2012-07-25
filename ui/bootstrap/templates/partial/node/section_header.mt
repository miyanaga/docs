? my %args = @_;
? my $node = $args{node} || Carp::confess('reduired node');

<h1><?= $node->ctx_title($ctx) ?></h1>
<? if ( my @tags = $node->ctx_tags($ctx) ) { ?>
    <p class="docs-node-tags">
        <? for my $tag ( @tags ) { ?>
            <?= raw($helper->link_to_tag($tag)); ?>
        <? } ?>
    </p>
<? } ?>

<? if ( my $lead = $node->ctx_lead($ctx) ) { ?>
<p class="docs-node-lead"><?= raw($lead) ?></p>
<? } ?>
