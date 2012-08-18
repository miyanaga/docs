? my ( $tag, $attrs, $branches ) = @_;

<? if ( ref $branches eq 'ARRAY' && @$branches ) { ?>
<<?= raw($tag) ?> <?= raw($attrs) ?>>
    <? for my $branch ( @$branches ) { ?>
        <? if ( ref $branch eq 'ARRAY' ) { ?>
            <?= include('modules/tree/partial', $tag, $attrs, $branch) ?>
        <? } elsif ( !ref $branch ) { ?>
            <li><?= raw($branch) ?></li>
        <? } ?>
    <? } ?>
</<?= raw($tag) ?>>
<? } ?>
