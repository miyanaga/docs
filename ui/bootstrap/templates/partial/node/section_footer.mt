? my %args = @_;
? my $node = $args{node} || Carp::confess('required node');

<? if ( $node->ctx_author_email($ctx) ) { ?>
<div class="pull-right docs-node-author-gravatar">
    <img data-gravatar-src="<?= $node->ctx_author_gravatar($ctx) ?>" >
</div>
<? } ?>

<? if ( my $author = $node->ctx_author_name($ctx) ) { ?>
<div class="docs-signature docs-node-author">
    <?= raw($helper->theme_icon('user')); ?>
    <?= $author; ?>
</div>
<? } ?>

<? if ( my $updated_on = $node->ctx_updated_on($ctx) ) { ?>
<div class="docs-signature docs-node-updated-on">
    <?= raw($helper->theme_icon('time')); ?>
    <?= raw($helper->format_datetime($node->ctx_datetime_format($ctx), $updated_on)); ?>
</div>
<? } ?>
