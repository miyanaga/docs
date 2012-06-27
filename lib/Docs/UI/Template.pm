package Docs::UI::Template;

use strict;
use warnings;
use parent 'Text::MicroTemplate::Extended';

sub h {
    'HTML Encoded';
}

sub u {
    'UTL Encoded';
}

1;
__END__
