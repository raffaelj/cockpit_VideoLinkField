<?php

$this->on('admin.init', function() {

    $this('admin')->addAssets('videolinkfield:assets/field-videolink.tag');

    // bind admin routes
    $this->bindClass('VideoLinkField\\Controller\\Admin', 'videolinkfield');

    // bind custom css file for TinyMCE dialog
    $this->bind('/videolinkfield/style.css', function() {

        $path = $this->pathToUrl('videolinkfield:assets/videolink.css');

        $version = '';
        if ($v = $this->param('v', false)) {
            $version = '?v=' . $v;
        }

        header('Location: ' . $path . $version);
        $this->stop();

    });

    if ($this->module('cockpit')->hasaccess('videolinkfield', 'manage')) {

        // add settings entry
        $this->on('cockpit.view.settings.item', function () {
            $this->renderView('videolinkfield:views/partials/settings.php');
        });

    }

    // quick hack to add options to EditorFormats addon
    // As long as @pauloamgomes doesn't change the form id, the route or the variable names, it will work
    // route: https://github.com/pauloamgomes/CockpitCms-EditorFormats/blob/master/Controller/Admin.php#L30
    // form id: https://github.com/pauloamgomes/CockpitCms-EditorFormats/blob/master/views/formats/format.php#L9
    // toolbar: https://github.com/pauloamgomes/CockpitCms-EditorFormats/blob/master/views/formats/format.php#L129
    // format.plugins: https://github.com/pauloamgomes/CockpitCms-EditorFormats/blob/master/views/formats/format.php#L127
    if (isset($this['modules']['editorformats'])) {

        // load only if EditorFormats Controller was called
        $this->on('app.editorformats.controller.admin.init', function() {

            if (strpos($this['route'], '/editor-formats/format') !== false) {

                $this->on('app.layout.contentafter', function() {

                    echo '<div class="uk-hidden" id="add-cpvideolink-to-editor-formats">';
                    // toolbar option
                    echo '{ toolbar.indexOf("cpvideolink") === -1 ? toolbar.push("cpvideolink") : "" }';
                    // plugin option
                    echo '{ format.plugins.cpvideolink = format.plugins.cpvideolink || false }';
                    echo '</div>';

                    // move div inside riot view to update the variables
                    echo '<script>App.$("#account-form").prepend(App.$("#add-cpvideolink-to-editor-formats"));</script>';

                });

            }

        });

    }

});
