#!/usr/bin/perl
use strict;
use warnings;

use FindBin::libs;
use Docs;

return Docs->app->psgi_app;
