
<field-videolink>

    <div class="uk-grid uk-grid-small uk-grid-match">

        <div class="uk-width-1-4">

            <div class="uk-text-center">
                <a class="uk-button uk-margin-small { value.url && value.url.match(/^http/) && !value.asset_id ? 'uk-button-primary' : '' }" onclick="{ getData }" title="{ App.i18n.get('Type a YouTube or Vimeo Url before pressing this button.') }" data-uk-tooltip>{ App.i18n.get('Find Values') }</a>

                <cp-thumbnail class="uk-margin-small-top uk-text-center" height="100" src="{ value.asset_id }" show="{ value.asset_id }"></cp-thumbnail>
            </div>

        </div>

        <div class="uk-grid uk-grid-small uk-width-3-4">

            <div class="uk-width-1-3" each="{field,idx in fields}">
                <label class="uk-display-block uk-text-bold uk-text-small">{ field.label || field.name || ''}</label>
                <cp-field class="uk-display-block uk-margin-small-top" type="{ field.type || 'text' }" bind="value.{field.name}" opts="{ field.options || {} }"></cp-field>
            </div>

        </div>

    </div>

    <script>

        var $this = this;

        this._field = null;
        this.set    = {};
        this.value  = {};
        this.fields = [];
        
        var myFields = [
            {
                'type': 'text',
                'name': 'url',
                'label': App.i18n.get('Url'),
                'options': {'placeholder': App.i18n.get('YouTube or Vimeo link')}
            },
            {
                'type': 'text',
                'name': 'text',
                'label': App.i18n.get('Display Text')
            },
            {
                'type': 'text',
                'name': 'title',
                'label': App.i18n.get('Title')
            },
            {
                'type': 'text',
                'name': 'id',
                'label': App.i18n.get('ID')
            },
            {
                'type': 'text',
                'name': 'provider',
                'label': App.i18n.get('Provider')
            },
            {
                'type': 'text',
                'name': 'asset_id',
                'label': App.i18n.get('Asset ID')
            },
        ];

        riot.util.bind(this);

        this.on('mount', function() {
            this.update();
        });

        this.on('update', function() {
            this.fields = myFields;
        });

        this.$initBind = function() {
            this.root.$value = this.value;
        };

        this.$updateValue = function(value, field) {

            if (!App.Utils.isObject(value) || Array.isArray(value)) {

                value = {};

                this.fields.forEach(function(field){
                    value[field.name] = null;
                });
            }

            if (JSON.stringify(this.value) != JSON.stringify(value)) {
                this.value = value;
                this.update();
            }

            this._field = field;

        }.bind(this);

        this.on('bindingupdated', function() {
            $this.$setValue(this.value);
        });

        getData(e) {

            e.preventDefault(); // don't save the entry on button click

            var url = this.value.url;

            var video = parseVideoUrl(url);
            var meta = {
                video_id: video.id,
                video_provider: video.provider
            };

            if (video.id != 'none') {

                this.value.id = video.id;
                this.value.provider = video.provider;

                App.request('/videolinkfield/getVideoLinkData', meta).then(function(data) {

                    if (data && data._id) {
                        $this.value.asset_id = data._id;
                    }

                    if (data && data.title) {

                        if (!$this.value.text || $this.value.text == '' || $this.value.text == 'undefined' || $this.value.text == 'none') {
                            $this.value.text = data.title;
                        }
                    }

                    $this.update();

                });
            }

        }

    </script>

</field-videolink>

// renderer in entries view
App.Utils.renderer['videolink'] = function(v) {

    if (!v) return;

    if (v.asset_id) {
        var id = 'img'+Math.random().toString(36).substring(2, 15) + Math.random().toString(36).substring(2, 15);;

        App.request('/cockpit/utils/thumb_url', {src:v.asset_id,w:20}, 'text').then(function(url){

            App.$('#'+id).attr('src', url);

        }).catch(function(e){
            // todo
        });

        return '<img id="'+id+'" width="20">'
             + '<i class="uk-margin-small-left uk-icon uk-icon-'+v.provider+'"></i>'
             + '<span class="uk-margin-small-left">' + (v.text || v.url) + '</span>'
             ;
    }
    
    return v.text || v.url || '';

}

// parse video url and return id + provider
// used in field and in wysiwyg/TinyMCE plugin
function parseVideoUrl(url) {

    var video = {};
    var regExpYouTube = /^.*(youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*/;
    var regExpVimeo   = /https?:\/\/(?:www\.)?vimeo.com\/(?:channels\/(?:\w+\/)?|groups\/([^\/]*)\/videos\/|album\/(\d+)\/video\/|)(\d+)(?:$|\/|\?)/;

    var match = url.match(regExpYouTube);

    if (match && match[2].length == 11) {
        video.id       = match[2];
        video.provider = 'youtube';
    }

    else {
        match = url.match(regExpVimeo);
        if (match) {
            video.id       = match[3];
            video.provider = 'vimeo';
        }
        else {
            video.id       = 'none';
            video.provider = 'none';
        }
    }
    return video;
}

// wysiwyg field
App.$(document).on("init-wysiwyg-editor", function(e, editor) {

    // custom TinyMCE plugin
    tinymce.PluginManager.add('cpvideolink', function(ed) {

        var getData = function () {

            var url = document.getElementById('cpvideolinkfield_url').value;

            var video = parseVideoUrl(url);
            var meta = {
                video_id: video.id,
                video_provider: video.provider
            };

            if (video.id != 'none') {
                document.getElementById('cpvideolinkfield_id').value = video.id;
                document.getElementById('cpvideolinkfield_provider').value = video.provider;

                App.request('/videolinkfield/getVideoLinkData', meta).then(function(data) {

                    if (data && data._id) {
                        document.getElementById('cpvideolinkfield_asset_id').value = data._id;
                        document.getElementById('cpvideolinkfield_asset_width').value = data.width;
                        document.getElementById('cpvideolinkfield_asset_height').value = data.height;

                        // document.getElementById('cpvideolinkfield_preview').innerHTML = '<img alt="" src="'+App.route('/cockpit/utils/thumb_url') + '?src='+data._id+'&h=100&o=1'+'" />'
                    }

                    if (data && data.title) {
                        var node = document.getElementById('cpvideolinkfield_text');

                        if (!node.value || node.value == '' || node.value == 'undefined' || node.value == 'none') {
                            node.value = data.title;
                        }
                    }

                });
            }

        };

        var openDialog = function() {

            var node = ed.selection.getNode();
            var data = {};
            var isUpdate = false;

            if (node.nodeName == 'A' && node.dataset && node.dataset.videoId) {
                data = {
                    'id':       node.dataset.videoId,
                    'provider': node.dataset.videoProvider,
                    'asset_id': node.dataset.videoThumb,
                    'asset_width': node.dataset.videoWidth,
                    'asset_height': node.dataset.videoHeight,
                    'url':      node.getAttribute('href'),
                    'title':    node.getAttribute('title'),
                    'text':     node.innerHTML,
                };
                isUpdate = true;
            }

            return ed.windowManager.open({
                title: App.i18n.get('Enter Video Url'),
                id: 'cpvideolink_modal',
                data,
                bodyType: 'tabpanel',
                body: [
                        {
                            title: 'Main',
                            type: 'form',
                            items: [
                                {
                                    type: 'textbox',
                                    name: 'url',
                                    label: App.i18n.get('Url'),
                                    id: 'cpvideolinkfield_url'
                                },
                                {
                                    type: 'textbox',
                                    name: 'text',
                                    label: App.i18n.get('Display Text'),
                                    id: 'cpvideolinkfield_text'
                                },
                                {
                                    type: 'textbox',
                                    name: 'title',
                                    label: App.i18n.get('Title'),
                                    id: 'cpvideolinkfield_title'
                                },
                                {
                                    type: 'textbox',
                                    name: 'asset_id',
                                    label: App.i18n.get('Asset ID'),
                                    id: 'cpvideolinkfield_asset_id'
                                },
                            ]
                        },
                        {
                            title: 'Other',
                            type: 'form',
                            items: [
                                {
                                    type: 'textbox',
                                    name: 'id',
                                    label: App.i18n.get('ID'),
                                    id: 'cpvideolinkfield_id'
                                },
                                {
                                    type: 'textbox',
                                    name: 'provider',
                                    label: App.i18n.get('Provider'),
                                    id: 'cpvideolinkfield_provider'
                                },
                                {
                                    type: 'textbox',
                                    name: 'asset_width',
                                    label: App.i18n.get('Width'),
                                    id: 'cpvideolinkfield_asset_width'
                                },
                                {
                                    type: 'textbox',
                                    name: 'asset_height',
                                    label: App.i18n.get('Height'),
                                    id: 'cpvideolinkfield_asset_height'
                                },
                            ]
                        },
                        /*{
                            title: 'Preview',
                            type: 'form',
                            html: '<span id="cpvideolinkfield_preview">test</span>'
                        },*/
                    ]
                ,
                buttons: [
                    {
                        text: App.i18n.get('Find Values'),
                        id: 'cpvideolinkfield_find',
                        onclick: function() {getData();}
                    },
                    {
                        text: 'OK',
                        id: 'cpvideolinkfield_submit',
                        onclick: 'submit'
                    },
                    {text: 'Cancel', onclick: 'close'}
                ],

                onSubmit: function (e) {

                    var url      = e.data.url,
                        text     = e.data.text != '' ? e.data.text : url,
                        title    = e.data.title,
                        id       = e.data.id,
                        provider = e.data.provider,
                        asset_id = e.data.asset_id
                        asset_width = e.data.asset_width
                        asset_height = e.data.asset_height
                        ;

                    if (!isUpdate) {

                        ed.insertContent('<a href="' + url + '"'
                                        + ' data-video-id="' + id + '"'
                                        + ' data-video-provider="' + provider + '"'
                                        + ' data-video-thumb="' + asset_id + '"'
                                        + ' data-video-width="' + asset_width + '"'
                                        + ' data-video-height="' + asset_height + '"'
                                        + (title != '' ? ' title="'+title+'"' : '')
                                        // + ' style="background-image:url(' + App.route('/cockpit/utils/thumb_url') + '?src='+asset_id+'&h=100&o=1)"'
                                        + '>'+ text + '</a>');

                    } else {

                        var node = ed.selection.getNode();

                        node.innerHTML = text;
                        node.setAttribute('href', url);
                        node.setAttribute('data-video-id', id);
                        node.setAttribute('data-video-provider', provider);
                        node.setAttribute('data-video-thumb', asset_id);
                        node.setAttribute('data-video-width', asset_width);
                        node.setAttribute('data-video-height', asset_height);
                        if (title != '') node.setAttribute('title', title);

                    }

                }
            });
        };

        ed.addMenuItem('cpvideolink', {
            icon: 'media',
            text: App.i18n.get('Insert/Edit Video'),
            onclick: function(){
                openDialog();
            },
            context: 'insert',
            prependToContext: true
        });

        ed.addButton('cpvideolink', {
            icon: 'media',
            tooltip: App.i18n.get('Insert/Edit Video'),
            onclick: function(){
                openDialog();
            },
            stateSelector: 'a[data-video-id]',

        });

        // load css file for dialog
        App.$(document).ready(function() {
            App.assets.getCss('/videolinkfield/style.css');
        });

    });

    // don't enable automatically, if EditorFormats addon is installed
    if (editor.settings.modified === undefined) {

        // enable plugin
        editor.settings.plugins = editor.settings.plugins + ' cpvideolink';

        // add toolbar button
        if (typeof editor.settings.toolbar == 'undefined') {
            // add default toolbar buttons
            editor.settings.toolbar = 'undo redo | styleselect | bold italic | alignleft'
                                    + 'aligncenter alignright alignjustify | '
                                    + 'bullist numlist outdent indent | link image';
        }
        editor.settings.toolbar += ' | cpvideolink';

    }

    if (editor.settings.plugins.indexOf('cpvideolink') !== -1) {
        if (typeof editor.settings.content_style == 'undefined') {
            editor.settings.content_style = '';
        }
        editor.settings.content_style += 'a[data-video-id] {'
            + 'display: inline-block;'
            + 'width:30em;'
            + 'padding:1em;'
            + 'text-align:center;'
            + 'border:1px solid #ccc;'
            + '}';
    }

});
