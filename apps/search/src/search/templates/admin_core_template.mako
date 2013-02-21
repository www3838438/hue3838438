## Licensed to Cloudera, Inc. under one
## or more contributor license agreements.  See the NOTICE file
## distributed with this work for additional information
## regarding copyright ownership.  Cloudera, Inc. licenses this file
## to you under the Apache License, Version 2.0 (the
## "License"); you may not use this file except in compliance
## with the License.  You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.

<%!
  from desktop.views import commonheader, commonfooter
  from django.utils.translation import ugettext as _
%>

<%namespace name="layout" file="layout.mako" />
<%namespace name="macros" file="macros.mako" />

${ commonheader(_('Search'), "search", user) | n,unicode }

<style type="text/css">
  .available-fields {
    padding: 0;
    padding-left:10px;
  }
  .available-fields ul {
    list-style: none;
    margin-left: 0;
  }
  .available-fields ul li {
    color: #666;
  }
  .preview-row:nth-child(odd) {
    background-color:#f9f9f9;
  }
  .tmpl {
    border: 1px solid #CCC;
    margin: 10px;
    height: 80px;
    cursor: pointer;
  }
  .tmpl:hover {
    border: 1px solid #999;
  }
  .tmpl.selected {
    border: 2px solid #999;
  }
</style>

<%layout:skeleton>
  <%def name="title()">
    <h1>${_('Search Admin - ')}${hue_core.name}</h1>
  </%def>
  <%def name="navigation()">
    ${ layout.sidebar(hue_core.name, 'template') }
  </%def>
  <%def name="content()">

    <ul class="nav nav-tabs">
      <li class="active"><a href="#visual" data-toggle="tab">${_('Visual editor')}</a></li>
      <li><a href="#source" data-toggle="tab">${_('Source')}</a></li>
      <li><a href="#preview" data-toggle="tab">${_('Preview')}</a></li>
    </ul>
    <div class="tab-content">
      <div class="tab-pane active" id="visual">

        <div class="row-fluid">
          <div class="span9">
            <div id="toolbar"></div>
            <div id="content-editor" class="clear">${_('Add your content here...')}</div>
            <div id="load-template" class="btn-group"><a title="Load template" class="btn toolbar-btn toolbar-cmd"><i class="icon-paste" style="margin-top:2px;"></i></a></div>
          </div>

          <div class="span3">
            <div class="well available-fields">
              <h4>${_('Available Fields')}</h4>
              <ul data-bind="foreach: fields">
                <li data-bind="text: $data, click: $root.addField"></li>
              </ul>
            </div>
          </div>
        </div>

      </div>
      <div class="tab-pane" id="source">
        <div class="row-fluid">
          <div class="span9">
            <textarea id="template-source"></textarea>
          </div>

          <div class="span3">
            <div class="well available-fields">
              <h4>${_('Available Fields')}</h4>
              <ul data-bind="foreach: fields">
                <li data-bind="text: $data, click: $root.addField"></li>
              </ul>
            </div>
          </div>
        </div>

      </div>

      <div class="tab-pane" id="preview">
        <div id="preview-container"></div>
      </div>
    </div>

    <div class="form-actions">
      <a class="btn btn-primary" id="save-template">${_('Save Template')}</a>
      <a class="btn" href="${ url('search:admin') }"><i class="icon-list"></i> ${ _('Return to Core list') }</a>
      <a class="btn" href="${ url('search:index') }"><i class="icon-search"></i> ${ _('Back to Search') }</a>
    </div>

    <div id="load-template-modal" class="modal hide fade">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal">&times;</button>
        <h3>${_('Load template')}</h3>
      </div>
      <div class="modal-body">
        <div class="tmpl">
          <div class="row-fluid">
            <div class="span1"><img src="http://twitter.com/api/users/profile_image/{{user_screen_name}}" style="margin:20px"></div>
            <div class="span9">
              <h5>{{user_name}}</h5>
              {{text}}
            </div>
            <div class="span2"><br><a class="btn" href="https://twitter.com/{{user_screen_name}}/status/{{id}}" target="_blank"><i class="icon-twitter"></i></a></div>
          </div>
        </div>
        <div class="tmpl">
          <h5>{{user_name}} <span style="color:#999">({{user_screen_name}})</span></h5>
          <p>{{text}}</p>
        </div>
      </div>
      <div class="modal-footer">
        <a href="#" class="btn" data-dismiss="modal">${_('Cancel')}</a>
        <button type="button" id="load-template-btn" href="#" class="btn btn-primary" disabled="disabled">${_('Load template')}</button>
      </div>
    </div>


  </%def>
</%layout:skeleton>

<link rel="stylesheet" href="/static/ext/farbtastic/farbtastic.css">
<link rel="stylesheet" href="/static/ext/css/freshereditor.css">
<script src="/static/ext/js/knockout-2.1.0.js" type="text/javascript" charset="utf-8"></script>
<script src="/static/ext/farbtastic/farbtastic.js" type="text/javascript" charset="utf-8"></script>
<script src="/static/ext/js/shortcut.js" type="text/javascript" charset="utf-8"></script>
<script src="/static/ext/js/freshereditor.min.js" type="text/javascript" charset="utf-8"></script>
<script src="/static/ext/js/codemirror-3.0.js"></script>
<link rel="stylesheet" href="/static/ext/css/codemirror.css">
<script src="/static/ext/js/codemirror-xml.js"></script>
<script src="/static/ext/js/mustache.js"></script>


<script type="text/javascript">
  $(document).ready(function () {
    function ViewModel() {
      var self = this;
      self.fields = ko.observableArray(${ hue_core.fields | n,unicode });
      self.addField = function (field) {
        $("#content-editor").focus();
        $("#content-editor").html($("#content-editor").html() + "{{" + field + "}}");
      };
    };

    ko.applyBindings(new ViewModel());

    var samples = ${ sample_data | n,unicode };

    var templateEditor = $("#template-source")[0];

    var codeMirror = CodeMirror(function (elt) {
      templateEditor.parentNode.replaceChild(elt, templateEditor);
    }, {
      value: templateEditor.value,
      readOnly: false,
      lineNumbers: true
    });

    $("#content-editor").freshereditor({toolbar_selector: "#toolbar", excludes: ['strikethrough', 'removeFormat', 'backcolor', 'insertorderedlist', 'justifyfull', 'insertheading1', 'insertheading2', 'superscript', 'subscript']});
    $("#content-editor").freshereditor("edit", true);

    // force refresh on tab change
    $("a[data-toggle='tab']").on("shown", function (e) {
      if ($(e.target).attr("href") == "#source") {
        codeMirror.setValue($("#content-editor").html());
        codeMirror.refresh();
      }
      if ($(e.target).attr("href") == "#preview") {
        $("#preview-container").empty();
        $(samples).each(function (cnt, item) {
          $("<div>").addClass("preview-row").html(Mustache.render($("#content-editor").html(), item)).appendTo($("#preview-container"));
        });
      }
    });

    var delay = -1;
    codeMirror.on("change", function () {
      clearTimeout(delay);
      delay = setTimeout(function () {
        $("#content-editor").html(codeMirror.getValue());
      }, 300);
    });

    $("#load-template").appendTo($("#toolbar .btn-toolbar")).removeClass("hide");

    $("#load-template-modal").modal({
      show: false
    });

    $("#load-template .btn").click(function(){
      $(".tmpl.selected").removeClass("selected");
      $("#load-template-modal").modal("show");
      $("#load-template-btn").attr("disabled", "disabled");
    });

    $(".tmpl").click(function(){
      $(".tmpl.selected").removeClass("selected");
      $(this).addClass("selected");
      $("#load-template-btn").removeAttr("disabled");
    });

    $("#load-template-btn").click(function(){
      $("#load-template-modal").modal("hide");
      $("#content-editor").html($(".tmpl.selected").html());
    });


    $("#save-template").click(function () {
      ##TODO: save template
      ## you can access it with: $("#content-editor").html()
      ## console.log($("#content-editor").html());
    });

  });
</script>

${ commonfooter(messages) | n,unicode }
