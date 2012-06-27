use strict;
use warnings;
use utf8;

use Test::More;

use_ok 'Docs';
use_ok 'Docs::Application';
use_ok 'Docs::Application::Handler';
use_ok 'Docs::Application::Handler::Test';
use_ok 'Docs::Formatter';
use_ok 'Docs::Formatter::Markdown';
use_ok 'Docs::Model::Node';
use_ok 'Docs::Model::Node::Document';
use_ok 'Docs::Model::Node::Folder';
use_ok 'Docs::Model::Node::Book';
use_ok 'Docs::Model::Node::Books';
use_ok 'Docs::Context';
use_ok 'Docs::UI::Helper';

done_testing;
