package Docs::MacroMethod::Common;

use strict;
use warnings;

use Carp;
use Sweets::Text::Xsv;

sub lang {
    my ( $macro, $args, $inner ) = @_;
    print STDERR $inner;
    my $lang = $args->{''} || $args->{lang}
        || return $macro->render($inner);
    $lang eq $macro->context->language->key? $macro->render($inner): '';
}

sub table {
    my ( $macro, $args, $inner ) = @_;
    my $source = $macro->render($inner);

    my $separator = $args->{type} && delete $args->{type} eq 'tsv'? "\t": ",";
    my $rows = Sweets::Text::Xsv->new( separator => $separator )->parse($source)->rows;
    my @trs;
    for my $r ( @$rows ) {
        next if ref $r ne 'ARRAY';
        my @tds = map {
            /^\((.*?)\)/? "<th>$1</th>": "<td>$_</td>"
        } @$r;
        push @trs, join '', @tds;
    }
    my $html = join "\n", map {
        "<tr>$_</tr>"
    } @trs;

    my %attr = %$args;
    $attr{inner} = $html;
    $macro->helper->element( 'table', %attr );
}

1;
__END__
