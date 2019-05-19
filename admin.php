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

});
