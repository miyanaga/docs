use strict;
use warnings;

use Test::More;

use Docs;
use Docs::Model::Node::Naming;

{
    my @badnames = qw/. .md title.lang.needless.ext Title@name@needless.md/;

    for my $name ( @badnames ) {
        my $naming = Docs::Model::Node::Naming->parse($name);
        is $naming, undef, "$name must be a bad name";
    }
}

{
    my $naming = Docs::Model::Node::Naming->parse('Title@name.ext');
    ok $naming;
    is $naming->file, 'Title@name.ext';
    is $naming->title, 'Title';
    is $naming->name, 'name';
    is $naming->extension, 'ext';
    is $naming->language, '';
    is $naming->order, 0;
}

{
    my $naming = Docs::Model::Node::Naming->parse('path/to/Title@name.ext');
    ok $naming;
    is $naming->file, 'Title@name.ext';
    is $naming->title, 'Title';
    is $naming->name, 'name';
    is $naming->extension, 'ext';
    is $naming->language, '';
    is $naming->order, 0;
}

{
    my $naming = Docs::Model::Node::Naming->parse('Title@name');
    ok $naming;
    is $naming->title, 'Title';
    is $naming->name, 'name';
    is $naming->extension, '';
    is $naming->language, '';
    is $naming->order, 0;
}

{
    my $naming = Docs::Model::Node::Naming->parse('日本語@name.ext');
    ok $naming;
    is $naming->title, '日本語';
    is $naming->name, 'name';
    is $naming->extension, 'ext';
    is $naming->language, '';
    is $naming->order, 0;
}

{
    my $naming = Docs::Model::Node::Naming->parse('日本語@name');
    ok $naming;
    is $naming->title, '日本語';
    is $naming->name, 'name';
    is $naming->extension, '';
    is $naming->language, '';
    is $naming->order, 0;
}

{
    my $naming = Docs::Model::Node::Naming->parse('01-Title@name.ext');
    ok $naming;
    is $naming->title, 'Title';
    is $naming->name, 'name';
    is $naming->extension, 'ext';
    is $naming->language, '';
    is $naming->order, 1;
}

{
    my $naming = Docs::Model::Node::Naming->parse('01=Title@name.ext');
    ok $naming;
    is $naming->title, '01=Title';
    is $naming->order, 0;
}

{
    my $naming = Docs::Model::Node::Naming->parse('01-Title@name');
    ok $naming;
    is $naming->title, 'Title';
    is $naming->name, 'name';
    is $naming->extension, '';
    is $naming->language, '';
    is $naming->order, 1;
}

{
    my $naming = Docs::Model::Node::Naming->parse('Title@name.ja.ext');
    ok $naming;
    is $naming->title, 'Title';
    is $naming->name, 'name';
    is $naming->extension, 'ext';
    is $naming->language, 'ja';
}

{
    my $naming = Docs::Model::Node::Naming->parse('Title..dot@name.ext');
    ok $naming;
    is $naming->title, 'Title.dot';
}

{
    my $naming = Docs::Model::Node::Naming->parse('Title@@atmark@name.ext');
    ok $naming;
    is $naming->title, 'Title@atmark';
}

{
    my $naming = Docs::Model::Node::Naming->parse('Title@@@@double_atmark@name.ext');
    ok $naming;
    is $naming->title, 'Title@@double_atmark';
}

done_testing;
