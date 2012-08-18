<?
    my $tag = delete $attributes->{tag} || 'ul';
    if ( $node ) {
        $attributes->{class} //= $node->metadata->ctx_cascade_find($ctx, 'module', 'tree', 'default_class')->as_scalar || '';
    }

    my $attrs = join(' ', map { qq{$_="} . $attributes->{$_} . qq{"} } sort { $a cmp $b } keys %$attributes);
?>
<?= include('modules/tree/partial', $tag, $attrs, $values) ?>
