? my %args = @_;
? my $groups = $args{groups};
? my $active = $args{active};

<? for my $group ( @$groups ) { ?>
    <h3><?= $group->{date} ?></h3>
    <ul class="docs-nodes docs-nodes-sitemap nav nav-pills nav-stacked">
        <? for my $node ( @{$group->{nodes}} ) { ?>
            <li class="docs-node <?= $node->uri_path eq $active? 'active': ''; ?>">
                <?= raw($helper->link_to_node($node)) ?>
            </li>
        <? } ?>
    </ul>
<? } ?>
