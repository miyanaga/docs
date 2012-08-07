

(function($){
    $.Docs = $.Docs || {};

    // Enable tabs
    $.fn.docsTabbing = function(options) {
        var defaults = {};
        var opts = $.extend(defaults, options);

        return this.each(function() {
            var $tabbing = $(this);
            var $panes = $(this).find('.tab-content .tab-pane');
            var $tabs = $(this).find('.nav-tabs');

            var $first;
            $panes.each(function() {
                var $pane = $(this);
                var tab = $pane.attr('data-tab');
                var id = $pane.attr('id');
                if (!tab || !id) return;

                var $tab = $('<a/>');
                $tab
                    .attr('id', id + '-tab').attr('href', '#' + id)
                    .html(tab)
                    .click(function(e) {
                        // Manually
                        e.preventDefault();
                        var $tab = $(this);
                        $.cookie('_navigation', '#' + $tab.attr('id'), { path: '/', expires: $.Docs.cookiesExpires(), path: '/' } );
                        $tab.tab('show');
                    });

                if ($pane.hasClass('docs-ajax-tab')) {
                    $tab.bind('shown', function() {
                        $.Docs.elementAjax({ element: $pane });
                    });
                }

                if (!$first) $first = $tab;
                $tabs.append($('<li/>').append($tab));
            });

            // Show active tab
            var $active = $tabs.find($tabbing.attr('data-active-tab'));
            if ($active.length < 1)
                $active = $tabs.find($.cookie('_navigation'));
            if ($active.length < 1)
                $active = $first;

            if ($active.length > 0)
                $active.tab('show');
        });
    };

    // TOC
    $.fn.docsHeadlinesShortcut = function(options) {
        var defaults = {
            target: 'h1',
            prefix: 'docs-headline',
            delimiter: '-',
            selector: '.docs-headline-shortcuts',
            addAnchor: function(anchor, title, count) {
                var $li = $('<li><a></a></li>');
                $li.find('a').attr('href', '#' + anchor).text(' ' + title).prepend($('<i class="icon-share-alt">'));
                $(this).append($li);
                if ( count > 1 ) $(this).show();
            }
        };
        var opts = $.extend(defaults, options);

        var i = 0;
        return this.each(function() {
            i++;
            var $article = $(this),
                toc = $(this).find(opts.selector).get(0);

            var j = 0;
            $(this).find(opts.target).each(function() {
                j++;
                var $target = $(this);

                if ( $target.text() ) {
                    var anchor = opts.prefix + i + opts.delimiter + j;
                    var $a = $('<a></a>').attr('name', anchor);
                    $target.before($a);
                    opts.addAnchor.call(toc, anchor, $target.text(), j);
                }
            });
        });
    };

    // Load relations
    $.fn.docsLoadRelations = function(options) {
        var defaults = {};
        var opts = $.extend(defaults, options);

        return this.each(function() {
            var $target = $(this);
            var url = $target.attr('data-node');
            if ( !url ) return;

            $target.docsStartLoading('m');
            $.get(url, { action: 'relations' }, function(data) {
                $target.append($(data));
            }).complete(function() {
                $target.docsStopLoading();
            }).error(function() {
                $target.docsStopLoading();
            });
        });
    };

    // Install sitemap opnener
    $.fn.docsSitemapOpener = function(options) {
        var defaults = {
            node_attr: 'data-node',
            selector: 'a.docs-sitemap',
            container: '.docs-node',
            append_to: '.docs-sitemap'
        };
        var opts = $.extend(defaults, options);

        return this.each(function() {
            $(this).find(opts.selector).each(function() {
                $(this).click(function(e) {
                    e.preventDefault();
                    var $opener = $(this);
                    var url = $(this).attr('data-node');
                    if (!url) return;

                    var $loading = $('<span/>')
                        .addClass('docs-inline-block')
                        .docsStartLoading('inline');
                    $(this).append($loading);

                    $.get(url, { action: 'sitemap' }, function(data) {
                        var $append_to = $opener.parents(opts.container).first().find(opts.append_to);
                        $append_to.append($(data));
                        $opener.remove();
                    }).complete(function() { $loading.remove(); });

                    return false;
                });
            })
        });
    };

    // Install quick search
    $.fn.docsQuickSearcher = function(options) {
        var defaults = {
            textbox: '.keyword',
            min_length: 2
            // cancel: function() {},
            // before: function() {},
            // after: function() {},
        };
        var opts = $.extend(options, defaults);

        return this.each(function() {
            var container = this;
            var $this = $(this);
            var url = $(this).attr('data-node-url');
            if (!url) return;

            $this.find(opts.textbox).bind('keyup', function(e) {
                var $textbox = $(this);
                var keyword = $textbox.val();
                if ( keyword.length < opts.min_length ) {
                    // Cancel
                    $this.find('.docs-quick-search-result').find('li').remove();
                    $this.parents('.nav-collapse.in.collapse').css('height', 'auto');
                    $this.removeClass('open');
                    return;
                }

                // Before
                $this.addClass('open');

                $.get(
                    url,
                    {
                        action: 'quicksearch',
                        q: keyword
                    },
                    function(data) {

                        // After/Complete
                        $this.find('.docs-quick-search-result').find('li').remove();
                        $this.find('.docs-quick-search-result').append($(data));
                        $this.parents('.nav-collapse.in.collapse').css('height', 'auto');
                    }
                )
            });
        });

    }
})(jQuery);

jQuery(function() {
    // Tabbing
    $('.tabbing').docsTabbing();

    $('div.docs-node-relations').docsLoadRelations();
    $('body').docsSitemapOpener();

    // Headline shortcut
    $('article.docs-node section.docs-node-body').docsHeadlinesShortcut();

    // Glossary
    $('article.docs-node').docsReplaceGlossary({
        target: '.docs-node-body p, .docs-node-body td',
        replace: function(original, glossary) {
            var $wrap = glossary.link && glossary.link != ''
                ? $('<p><a rel="tooltip"></a><sup></sup></p>')
                : $('<p><u rel="tooltip"></u><sup></sup></p>')
            $wrap.find('*[rel=tooltip]').attr('title', glossary.description).text(original);
            $wrap.find('sup').text('*' + glossary.index);
            if ( glossary.link && glossary.link != '' )
                $wrap.find('a').attr('href', glossary.link);
            return $wrap.html();
        },
        complete: function(glossary, used) {
            var $node = $(this);
            $node.find('.docs-node-body').tooltip({
                selector: '*[rel=tooltip]'
            });

            if (used && used.length > 0) {
                var $dl = $('<dl></dl>');
                $.each(used, function(i, g) {
                    var $dt = $('<dt><span></span> <u></u></dt>');
                    $dt.find('span').text('*' + g.index);
                    $dt.find('*[rel=tooltip]').text(g.keyword);
                    var $dd = $('<dd></dd>').text(g.description);

                    $dl.append($dt).append($dd);
                });

                $node.find('.docs-node-footnote').append($dl);
            }
        }
    });

    // Quick Search
    $('.docs-quick-search').docsQuickSearcher();

    // Gravator
    $('.docs-node-footer .docs-node-author-gravatar img').docsAvatar();

    // Pretty print
    if(window.prettyPrint) {
        $('section.docs-node-body pre').addClass('prettyprint');
        prettyPrint();
    }

    // TODO: Remove
    $('.docs-rebuilder').click(function(e) {
        e.preventDefault();
        $(this).find('span').text('Rebuilding...');
        $.get(
            '/',
            { action: 'rebuild' },
            function(data) {
                location.reload();
            }
        );
        return false;
    });
});
