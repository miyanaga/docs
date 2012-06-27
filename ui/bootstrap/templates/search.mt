? extends 'node';
? my %args = @_;
? my $result = $args{result};
? my $folder = $ctx->folder;
? my $q = $args{q} || '';
? $ctx->stash('active_navigation_tab', '#navigation-tags-tab') if $result->search_type eq 'tag';

<? block body_class => sub { 'docs-search-' . $result->search_type } ?>

<? block content => sub { ?>
    <? if (!$result) { ?>
        no search results
    <? } else { ?>
        <div class="docs-search-form">
        <form id="docs-search" method="GET" action="<?= $folder->uri_path ?>">
            <input type="hidden" name="action" value="search">
            <input type="hidden" name="page" value="<?= $result->page ?>">

            <div class="row-fluid">
                <div class="docs-search-control span8">
                    <div class="control-group input-append docs-search-box">
                        <input type="text" name="q" value="<?= $q ?>"><!--
                        --><button type="submit" class="btn"><?= raw($helper->theme_icon('search')) ?></button>
                    </div>
                    <div class="control-group docs-searched-tag">
                        <? if ($result->search_type eq 'tag' && $result->search_tag) { ?>
                            <?= raw($helper->link_to_tag($result->search_tag, class => 'docs-tag-large', nolink => 1)) ?>
                        <? } ?>
                    </div>
                </div>
                <div class="per-page-selector span4">
                    <div class="btn-group pull-right">
                        <? for my $per_page ( qw/10 20 50 100/ ) { ?>
                            <? my $class = $per_page == $result->request->per_page? 'btn-inverse': ''; ?>
                            <a href="#" class="btn <?= $class ?> docs-search-per-page-switcher" data-per-page="<?= $per_page ?>"><!--
                                --><?= $per_page ?><!--
                            --></a>
                        <? } ?>
                    </div>
                </div>
            </div>
        </form>
        </div>

        <?= include('partial/search/pager', result => $result, form => '#docs-search' ) ?>

        <? for my $node ( @{$result->data} ) { ?>
            <?= include('partial/node/digest', node => $node, nonumbering => 1); ?>
        <? } ?>

        <? if($result->count > 0) { ?>
            <?= include('partial/search/pager', result => $result, form => '#docs-search' ) ?>
        <? } ?>
    <? } ?>
<? } ?>
