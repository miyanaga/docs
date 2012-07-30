<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title><? block 'html_title' => sub { }?></title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="<?= $ctx->stash_or('html_description', '', 1) ?>">
    <meta name="author" content="<?= $ctx->stash_or('html_author', '', 1) ?>">

    <!-- Le styles -->
    <link href="/static/bootstrap/css/bootstrap.css" rel="stylesheet">
    <style type="text/css">
      body {
        padding-top: 60px;
        padding-bottom: 40px;
      }
      .sidebar-nav {
        padding: 9px 0;
      }
    </style>
    <link href="/static/bootstrap/css/bootstrap-responsive.css" rel="stylesheet">
    <link href="/static/css/prettify.css" rel="stylesheet">
    <link href="/static/css/docs.css" rel="stylesheet">
    <link href="/static/css/docs.bootstrap.css" rel="stylesheet">

    <!-- Le HTML5 shim, for IE6-8 support of HTML5 elements -->
    <!--[if lt IE 9]>
      <script src="http://html5shim.googlecode.com/svn/trunk/html5.js"></script>
    <![endif]-->

    <!-- Le fav and touch icons -->
    <link rel="shortcut icon" href="/static/ico/favicon.ico">
    <link rel="apple-touch-icon-precomposed" sizes="114x114" href="/static/ico/apple-touch-icon-114-precomposed.png">
    <link rel="apple-touch-icon-precomposed" sizes="72x72" href="/static/ico/apple-touch-icon-72-precomposed.png">
    <link rel="apple-touch-icon-precomposed" href="/static/ico/apple-touch-icon-57-precomposed.png">
    <? block html_head => sub {} ?>
  </head>

  <body class="<? block body_class => sub { } ?>">
    <?= include 'partial/body_header' ?>
    <?= raw($helper->facebook_comment_load) if $helper->can('facebook_comment_load') ?>

    <div id="global-nav" class="navbar navbar-fixed-top">
      <div class="navbar-inner">
        <div class="container-fluid">
          <a class="btn btn-navbar" id="nav-opener" data-toggle="collapse" data-target=".nav-collapse">
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
          </a>
          <? block brand => sub { ?><a class="brand" href="#">BRAND</a><? } ?>
          <? block global_header => sub {} ?>
          <div class="nav-collapse">
            <ul class="nav">
              <? block global_primary_nav => sub {} ?>
            </ul>
            <? if ( $ctx->is_admin ) { ?>
            <ul class="nav pull-right">
              <? block global_teritiary_nav => sub { ?>
              <? } ?>
                <li><a href="#" id="docs-rebuilder">
                  <i class="icon-refresh icon-white"></i>
                  <span>Rebuild</span></a>
                </li>

              <? block global_secondary_nav => sub {} ?>
            </ul>
            <? } ?>
          </div><!--/.nav-collapse -->
        </div>
      </div>
    </div>

    <div class="container-fluid">
      <div class="row-fluid">
