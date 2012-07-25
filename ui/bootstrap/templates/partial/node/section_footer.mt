? my %args = @_;
? my $node = $args{node} || Carp::confess('required node');

<? if ( my $author_email_serial = $node->ctx_author_email_serial($ctx) ) { ?>
<div class="pull-right" id="docs-node-author-avatar" data-email-serial="<?= $author_email_serial ?>"></div>
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
