use strict;
use warnings;
use utf8;

use Test::More;

use Docs;
use Docs::Model::Util::NodeName;

{
    my @badnames = qw/. .md title.lang.needless.ext Title@name@needless.md/;

    for my $name ( @badnames ) {
        my $nn = Docs::Model::Util::NodeName->parse($name);
        is $nn, undef, "$name must be a bad name";
    }
}

{
    my $nn = Docs::Model::Util::NodeName->parse('Title@name.ext');
    ok $nn;
    is $nn->file, 'Title@name.ext';
    is $nn->title, 'Title';
    is $nn->name, 'name';
    is $nn->extension, 'ext';
    is $nn->language, '';
    is $nn->order, 0;
}

{
    my $nn = Docs::Model::Util::NodeName->parse('path/to/Title@name.ext');
    ok $nn;
    is $nn->file, 'Title@name.ext';
    is $nn->title, 'Title';
    is $nn->name, 'name';
    is $nn->extension, 'ext';
    is $nn->language, '';
    is $nn->order, 0;
}

{
    my $nn = Docs::Model::Util::NodeName->parse('Title@name');
    ok $nn;
    is $nn->title, 'Title';
    is $nn->name, 'name';
    is $nn->extension, '';
    is $nn->language, '';
    is $nn->order, 0;
}

{
    my $nn = Docs::Model::Util::NodeName->parse('日本語@name.ext');
    ok $nn;
    is $nn->title, '日本語';
    is $nn->name, 'name';
    is $nn->extension, 'ext';
    is $nn->language, '';
    is $nn->order, 0;
}

{
    my $nn = Docs::Model::Util::NodeName->parse('日本語@name');
    ok $nn;
    is $nn->title, '日本語';
    is $nn->name, 'name';
    is $nn->extension, '';
    is $nn->language, '';
    is $nn->order, 0;
}

{
    my $nn = Docs::Model::Util::NodeName->parse('01-Title@name.ext');
    ok $nn;
    is $nn->title, 'Title';
    is $nn->name, 'name';
    is $nn->extension, 'ext';
    is $nn->language, '';
    is $nn->order, 1;
}

{
    my $nn = Docs::Model::Util::NodeName->parse('01=Title@name.ext');
    ok $nn;
    is $nn->title, '01=Title';
    is $nn->order, 0;
}

{
    my $nn = Docs::Model::Util::NodeName->parse('01-Title@name');
    ok $nn;
    is $nn->title, 'Title';
    is $nn->name, 'name';
    is $nn->extension, '';
    is $nn->language, '';
    is $nn->order, 1;
}

{
    my $nn = Docs::Model::Util::NodeName->parse('Title@name.ja.ext');
    ok $nn;
    is $nn->title, 'Title';
    is $nn->name, 'name';
    is $nn->extension, 'ext';
    is $nn->language, 'ja';
}

{
    my $nn = Docs::Model::Util::NodeName->parse('Title..dot@name.ext');
    ok $nn;
    is $nn->title, 'Title.dot';
}

{
    my $nn = Docs::Model::Util::NodeName->parse('Title@@atmark@name.ext');
    ok $nn;
    is $nn->title, 'Title@atmark';
}

{
    my $nn = Docs::Model::Util::NodeName->parse('Title@@@@double_atmark@name.ext');
    ok $nn;
    is $nn->title, 'Title@@double_atmark';
}

done_testing;
