? my %args = @_;
? my $node = $args{node} || Carp::confess('required node');
? my $active = $args{active};

? my @children = $node->ctx_children($ctx);
? if ( @children ) {
<ul class="nodes nodes-sitemap docs-cascading nav nav-pills nav-stacked">
?    for my $child ( @children ) {
    <li class="node <?= $child == $active? 'active': ''; ?>"><?= raw($helper->link_to_node($child)); ?></li>
        <?= include('partial/node/sitemap', ( %args, node => $child )); ?>
?    }
</ul>
? }
