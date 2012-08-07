
(function($) {
    $.Docs = $.Docs || {};

    $.Docs.elementAjax = function(options) {
        var defaults = {};
        var opts = $.extend(defaults, options);

        if (!opts.element) {
            console.log('elementAjax requires element option');
            return;
        }

        var $el = $(opts.element);
        var loaded = $el.attr('data-ajax-loaded'),
            url = $el.attr('data-ajax-url'),
            param = $el.attr('data-ajax-param') || {},
            loading = $el.attr('data-ajax-loading');

        if (loaded) return;

        if (!url) {
            console.log('elementAjax requires data-ajax-url attribute of element');
            return;
        }

        if (loading) {
            $el.docsStartLoading(loading);
        }

        $.get(url, param, function(data) {
            $el.empty().append($(data)).attr('data-ajax-loaded', 'loaded');
            if ( opts.after ) {
                $el.each(function() {
                    opts.after.call(this);
                });
            }
        }).complete(function() {
            $el.docsStopLoading();
        });
    };

    // Start loading
    $.fn.docsStartLoading = function(type) {
        return this.each(function() {
            $(this).addClass('docs-loading-' + type);
        });
    };

    // Stop loading
    $.fn.docsStopLoading = function(options) {
        return this.each(function() {
            $(this).removeClass('docs-loading-s docs-loading-m docs-loading-l');
        });
    };

    // Open/Close
    $.fn.docsOpenClose = function(options) {
        var defaults = {
            opend_class: 'docs-opened',
            closed_class: 'docs-closed'
        };
        var opts = $.extend(defaults, options);
        return this.each(function() {
            var $el = $(this);
            $el.click(function(e) {
                e.preventDefault();
                if ( $el.hasClass(opts.closed_class) ) {
                    $el
                        .removeClass(opts.closed_class)
                        .addClass(opts.opened_class);
                } else {
                    $el
                        .removeClass(opts.opened_class)
                        .addClass(opts.closed_class);
                }
                return false;
            });
        });
    };

    // Cookie expires
    $.Docs.cookiesExpires = function() {
        $('body').attr('data-cookies-expires-days') || 365;
    };

    // Switch language
    $.fn.docsSwitchLanguage = function() {
        return this.each(function() {
            var $switcher = $(this);
            var lang = $switcher.attr('data-lang');
            $switcher.click(function(e) {
                e.preventDefault();
                $.cookie('_lang', lang, { path: '/', expires: $.Docs.cookiesExpires() });
                location.reload();
                return false;
            });
        });
    };

    // Switch per page
    $.fn.docsSwitchSearchPerPage = function() {
        return this.each(function() {
            var $switcher = $(this);
            var per_page = $switcher.attr('data-per-page') || $switcher.val() || 10;
            $switcher.click(function(e) {
                e.preventDefault();
                $.cookie('_search_per_page', per_page, { path: '/', expires: $.Docs.cookiesExpires() });
                var $form = $switcher.parents('form');
                $form.find('#docs-search-page, input[name=page]').val(0);
                $form.get(0).submit();
                return false;
            });
        });
    };

    // Switch search page
    $.fn.docsSwitchSearchPage = function() {
        return this.each(function() {
            var $switcher = $(this);
            var page = $switcher.attr('data-page') || $switcher.val() || 10;
            var form = $switcher.attr('data-form');
            $switcher.click(function(e) {
                e.preventDefault();
                var $form = $(form);
                $form.find('#docs-search-page, input[name=page]').val(page);
                $form.get(0).submit();
                return false;
            });
        });
    };

    // Replace text
    $.fn.docsReplaceText = function( search, replace ) {
        return this.each(function(){
            var node = this.firstChild,
                replacing,
                replaced,
                remove = [];
            if ( node ) {
                do {
                    if ( node.nodeType === 3 ) {
                        replacing = node.nodeValue;
                        replaced = replacing.replace( search, replace );
                        if ( replaced !== replacing ) {
                            if ( /</.test( replaced ) ) {
                                $(node).before( replaced );
                                remove.push( node );
                            } else {
                                node.nodeValue = replaced;
                            }
                        }
                    }
                } while ( node = node.nextSibling );
            }
            remove.length && $(remove).remove();
        });
    };

    // Glossary
    $.fn.docsReplaceGlossary = function(options) {
        var defaults = {
            target: '.docs-node-body p,.docs-node-body td',
            replace: function(original, glossary) {
                return original;
            }
            // complete: function(glossary, used)
        };
        var opts = $.extend(defaults, options);

        return this.each(function() {
            var node = this;
            var $node = $(this);
            var url = $node.attr('data-node-url');
            if (!url) return;

            $.get($node.attr('data-node-url'), {
                action: 'glossary'
            }, function(data) {
                // RegExp
                var keywords = [];
                for ( var keyword in data ) {
                    if ( typeof keyword == 'string' ) {
                        keywords.push(keyword);
                    }
                }
                var reg = new RegExp(keywords.join('|'), 'ig');

                // Replace text
                var unique = {},
                    used = [],
                    index = 1;

                $node.find(opts.target).docsReplaceText(reg, function(match, p) {
                    var k = match.toLowerCase();
                    var g = data[k];
                    if (!g) return k;

                    // Make unique array
                    if (!unique[k]) {
                        g.index = index++;
                        used.push(g);
                        unique[k] = { index: index };
                    }

                    return opts.replace.call(node, match, g);
                });

                if(opts.complete && typeof opts.complete == 'function') {
                    opts.complete.call(node, data, used);
                }
            });
        });
    };

    // Avatar
    $.fn.docsAvatar = function(options) {
        var defaults = {
            load: function() {
                $(this).show();
            }
        };
        var opts = $.extend(defaults, options);

        return this.each(function() {
            var src = $(this).attr('data-gravatar-src');
            $(this).load(opts.load).attr('src', src);
        });
    };

    $.fn.docsTagcloud = function() { /* Override in each UI */ };

})(jQuery);

jQuery(function($) {
    // Open/Close
    $('.docs-open-close').docsOpenClose();

    // Languages
    $('a.docs-language-switcher').docsSwitchLanguage();

    // Search
    $('a.docs-search-page-switcher').docsSwitchSearchPage();
    $('a.docs-search-per-page-switcher').docsSwitchSearchPerPage();
});
