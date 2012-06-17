package Docs::Component::GroongaSearch;

use strict;
use warnings;

use Docs;
use Docs::Context;

sub on_post_init {
    my ( $cb, $app ) = @_;

    for my $book ( values %{$app->books->children('uri')} ) {
        for my $lang ( @{$book->languages} ) {
            my $ctx = Docs::Context->new(
                language => $lang
            );
            $book->groonga_migrate($ctx);
        }
    }

    1;
}

sub on_document_rebuild {

}

1;
__END__
