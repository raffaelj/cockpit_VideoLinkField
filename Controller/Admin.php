<?php

namespace VideoLinkField\Controller;


class Admin extends \Cockpit\AuthController {

    public function index() {}

    public function getVideoLinkData() {

        // to do: server side url parsing

        $meta = [
            'video_id' => $this->app->param('video_id', null),
            'video_provider' => $this->app->param('video_provider', null),
        ];

        if (!$meta['video_id'])       return ['error' => 'video_id is missing'];
        if (!$meta['video_provider']) return ['error' => 'video_provider is missing'];

        return $this->app->module('videolinkfield')->getVideoLinkData($meta);

    }

    public function settings() {

        if (!$this->module('cockpit')->hasaccess('videolinkfield', 'manage')) {
            return $this('admin')->denyRequest();
        }

        $config = $this->app->storage->getKey('cockpit/options', 'videolinkfield', false);

        if (!$config) {
            $config = [
                'folder_id' => '',
                'folder_name' => '',
            ];
        }

        return $this->render('videolinkfield:views/settings.php', compact('config'));

    }

    public function saveConfig() {

        if (!$this->module('cockpit')->hasaccess('videolinkfield', 'manage')) {
            return $this('admin')->denyRequest();
        }

        $config = $this->param('config', false);

        if ($config) {
            $this->app->storage->setKey('cockpit/options', 'videolinkfield', $config);
        }

        return $config;

    }

}
