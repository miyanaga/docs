

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
                        console.log($append_to);
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
            min_length: 2,
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
                    console.log(container);
                    $this.find('#quick-search-result').find('li').remove();
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
                        $this.find('#quick-search-result').find('li').remove();
                        $this.find('#quick-search-result').append($(data));
                        console.log($this.parents('.nav-collapse.in.collapse'));
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

    $('div#node-relations').docsLoadRelations();
    $('body').docsSitemapOpener();

    // Grossaly
    $('article#node').docsReplaceGrossaly({
        target: '#node-body p, #node-body td',
        replace: function(original, grossaly) {
            var $wrap = $('<p><u rel="tooltip"></u><sup></sup></p>');
            $wrap.find('u').attr('title', grossaly.description).text(original);
            $wrap.find('sup').text('*' + grossaly.index);
            return $wrap.html();
        },
        complete: function(grossaly, used) {
            var $node = $(this);
            $node.find('#node-body').tooltip({
                selector: 'u[rel=tooltip]'
            });

            if (used && used.length > 0) {
                var $dl = $('<dl></dl>');
                $.each(used, function(i, g) {
                    var $dt = $('<dt><span></span> <u></u></dt>');
                    $dt.find('span').text('*' + g.index);
                    $dt.find('u').text(g.keyword);
                    var $dd = $('<dd></dd>').text(g.description);

                    $dl.append($dt).append($dd);
                });

                $node.find('#node-footnote').append($dl);
            }
        }
    });

    // Quick Search
    $('#quick-search').docsQuickSearcher();

    // Gravator
    $('#node-footer #node-author-avatar').docsGravatar({
        complete: function(url) {
            $(this).append($('<img class="avatar">').attr('src', url));
        }
    });

    // Pretty print
    if(window.prettyPrint) {
        console.log('prityprint');
        $('section#docs-node-body pre').addClass('prettyprint');
        prettyPrint();
    }

    // TODO: Remove
    $('#rebuilder').click(function(e) {
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
