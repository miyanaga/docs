

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
                        $.cookie('_navigation', '#' + $tab.attr('id'), { expires: $.Docs.cookiesExpires(), path: '/' } );
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
})(jQuery);

jQuery(function() {
    // Tabbing
    $('.tabbing').docsTabbing();

    $('div#node-relations').docsLoadRelations();
    $('body').docsSitemapOpener();
});
