@module/table/default_class default-class
@module/table/default_format ssv

<docs:module format="csv" file="table" id="the-table" classes="col1,col2,col3">
(head1),(head2),(head3)
value1-1,value1-2,value1-3
value2-1,value2-2,value2-3
</docs:module>

<docs:module format="tsv" file="table" class="table" id="the-table" classes="col1,col2,col3">
"(head1)"	"(head2)"	"(head3)"
'value1-1'	'value1-2'	'value1-3'
value2-1	value2-2	value2-3
</docs:module>

<docs:module file="table" class="table" id="the-table" classes="col1,col2,col3">
"(head1)"       "(head2)"       "(head3)"
'value1-1'      'value1-2'      'value1-3'
value2-1      value2-2      value2-3
</docs:module>

<docs:module format="yaml" file="table" class="table" id="the-table" classes="col1,col2,col3">
-
    - "(head1)"
    - '(head2)'
    - (head3)
-
    - "value1-1"
    - 'value1-2'
    - value1-3
-
    - "value2-1"
    - 'value2-2'
    - value2-3
</docs:module>
