      </div><!--/.row-fluid-->

      <hr>
      <footer>
        <? block footer => sub { ?>
          &copy;<?= raw($ctx->document->ctx_copyright($ctx)); ?>
        <? } ?>
        Powered by <a href="https://github.com/miyanaga/docs">docs</a>
      </footer>

    </div><!--/.fluid-container-->

    <!-- Le javascript
    ================================================== -->
    <!-- Placed at the end of the document so the pages load faster -->
    <script src="/static/js/jquery-1.7.2.min.js"></script>
    <script src="/static/js/jquery.cookie.js"></script>
    <script src="/static/bootstrap/js/bootstrap.min.js"></script>
    <script src="/static/jcaption/jcaption.min.js"></script>
    <script src="/static/js/jquery.replace-text.js"></script>
    <script src="/static/js/docs.js"></script>
    <script src="/static/js/docs.bootstrap.js"></script>
    <script src="/static/js/prettify.js"></script>
    <script>
      jQuery(function($) {
        $('.dropdown-toggle').dropdown();
      });
    </script>
    <? block html_foot => sub {} ?>
    <?= include 'partial/tracker' ?>
  </body>
</html>
