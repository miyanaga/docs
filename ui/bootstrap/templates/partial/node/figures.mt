? my %args = @_;
? my $node = $args{node};
? my $is_first = $args{offset} == 0? 1: 0;

<? if ( $is_first ) { ?><ul class="nav nav-pills nav-stacked"><? } ?>
    <? for my $f ( @{$args{figures}} ) { ?>
    <li>
        <a href="<?= $f->{node}->normalized_uri_path ?>">
            <img alt="<?= $f->{alt} ?>" src="<?= $f->{src} ?>">
        </a>
    </li>
    <? } ?>
    <? if ( $args{next} ) { ?>
        <button class="btn increment" data-url="<?= raw($node->normalized_uri_path) ?>?action=navigation_figures&offset=<?= $args{next} ?>"><?= raw($helper->theme_icon('arrow-down')) ?></button>
    <? } ?>
<? if ( $is_first ) { ?></ul><? } ?>
