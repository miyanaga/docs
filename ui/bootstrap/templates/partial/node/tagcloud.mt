? my %args = @_;
? my $tags = $args{tags} || Carp::confess('tagcloud requires tags');

<!-- Tag Cloud -->

<div id="navigation-tags-inner" class="docs-tag-cloud">
<? for my $tag (@$tags) { ?>
    <? my $class = 'docs-tag doca-tag-scaled docs-tag-scale-' . $tag->scale; ?>
    <?= raw($helper->link_to_tag($tag, class => $class, attr => { 'rel' => 'tooltip', 'data-node-count' => $tag->node_count })); ?>
<? } ?>
</div>

<script>
    $(function() {
        $('#navigation-tags-inner *[data-tooltip]').tooltip({
            title: function() {
                return $(this).attr('data-node-count');
            }
        });
    } );
</script>
