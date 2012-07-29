<div class="tabbing" id="navigations" data-active-tab="<?= $ctx->stash('active_navigation_tab') || '' ?>">
    <ul class="nav nav-tabs"></ul>
    <div class="tab-content">
        <?= include 'partial/navigation/folder' ?>
        <?= include 'partial/navigation/sitemap' ?>
? #        <?= include 'partial/navigation/recent' ?>
        <?= include 'partial/navigation/tags' ?>
    </div>
</div>
