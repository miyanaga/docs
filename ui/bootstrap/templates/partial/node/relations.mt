? my %args = @_;
? my $nodes = ( ref $args{nodes} eq 'ARRAY'? $args{nodes}: undef) || Carp::confess('required node array');
? use Data::Dumper;

<!-- node relation -->
<? if ( @$nodes ) { ?>
    <ul class="nodes nodes-relations nav nav-pills nav-stacked">
    <? for my $node ( @$nodes ) { ?>
        <? if ( my $relation = $node->ctx_stash($ctx, 'relation') ) { ?>
            <li>
                <? my $icon = $helper->theme_icon($relation); ?>
                <? my $tags = join( "\n", map { raw($helper->link_to_tag($_, nolink => 1)); } @{$node->ctx_tags($ctx)} ) || ''; ?>
                <?= raw($helper->link_to_node($node, prepend => "$icon\n", append => "\n$tags")); ?>
            </li>
        <? } ?>
    <? } ?>
    </ul>
<? } ?>
