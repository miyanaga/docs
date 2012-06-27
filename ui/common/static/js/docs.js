
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
                console.log($el);
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
                $.cookie('_lang', lang, { expires: $.Docs.cookiesExpires() });
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
                $.cookie('_search_per_page', per_page, { expires: $.Docs.cookiesExpires() });
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
            console.log('install');
            $switcher.click(function(e) {
                e.preventDefault();
                var $form = $(form);
                $form.find('#docs-search-page, input[name=page]').val(page);
                $form.get(0).submit();
                return false;
            });
        });
    };
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
