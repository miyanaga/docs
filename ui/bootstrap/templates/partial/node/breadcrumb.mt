<? if ( my @breadcrum = reverse grep { $_->depth > 0 && $_->uri_name ne 'index' } @{$ctx->folder->parents} ) { ?>
<ul class="breadcrumb">
    <? for my $b ( @breadcrum ) { ?>
        <li><?= raw($helper->link_to_node($b)) ?> &raquo; </li>
    <? } ?>
</ul>
<? } ?>

