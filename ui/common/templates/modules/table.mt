<?
    my @classes;
    if ( my $classes = delete $attributes->{classes} ) {
        @classes = split( /\s*,\s*/, $classes );
    }

    if ( $node ) {
        $attributes->{class} //= $node->metadata->ctx_cascade_find($ctx, 'module', 'table', 'default_class')->as_scalar || '';
    }
    my $attrs = join(' ', map { qq{$_="} . $attributes->{$_} . qq{"} } sort { $a cmp $b } keys %$attributes);
?>
<? if ( ref $values eq 'ARRAY' ) { ?>
    <table <?= raw($attrs) ?>>
    <? for my $row ( @$values ) { ?>
        <? if ( ref $row eq 'ARRAY' ) { ?>
            <tr>
            <? for ( my $i = 0; $i < scalar @$row; $i++) { ?>
                <? my $class = $classes[$i] || ''; ?>
                <? my $value = $row->[$i] || ''; ?>
                <? if ( $value =~ /^\((.+)\)$/s ) { ?>
                    <th class="<?= raw($class) ?>"><?= raw($1) ?></th>
                <? } else { ?>
                    <td class="<?= raw($class) ?>"><?= raw($value) ?></td>
                <? } ?>
            <? } ?>
            </tr>
        <? } ?>
    <? } ?>
    </table>
<? } ?>
