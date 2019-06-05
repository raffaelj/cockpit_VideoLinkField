<?php
/**
 * Video Link field Addon for Cockpit CMS
 * 
 * @see       https://github.com/raffaelj/cockpit_VideoLinkField/
 * @see       https://github.com/agentejo/cockpit/
 * 
 * @version   0.1.1
 * @author    Raffael Jesche
 * @license   MIT
 */


$this->module('videolinkfield')->extend([

    'getVideoLinkData' => function($meta = []) {

        // to do: server side url parsing

        $asset = $this->app->storage->findOne('cockpit/assets', ['video_id' => $meta['video_id']]);

        if (!$asset) {
            $asset = $this->saveThumbnail($meta);
        }

        return $asset;

    },

    'saveThumbnail' => function($meta) {

        $assets = [];

        $id       = $meta['video_id'];
        $provider = $meta['video_provider'];

        if (empty($id)) return ['error' => 'id is missing'];
        if (empty($provider)) return ['error' => 'provider is missing'];

        if ($provider == 'youtube') {

            $image_url = 'https://img.youtube.com/vi/' . $id . '/0.jpg';
            $tmp_path  = $this->app->path('#tmp:').'/'.$provider.'_'.$id.'.jpg';

            $json_url = 'https://www.youtube.com/oembed?url=https://www.youtube.com/watch?v=' . $id . '&format=json';

            $info = json_decode(file_get_contents($json_url), true);

            $meta['title'] = $info['title'] ?? '';

        }

        if ($provider == 'vimeo') {

            $json_url = 'http://vimeo.com/api/v2/video/' . $id . '.json';

            $info = json_decode(file_get_contents($json_url), true);

            if (isset($info[0])) $info = $info[0];

            $image_url = '';
            if     (isset($info['thumbnail_large']))  $image_url = $info['thumbnail_large'];
            elseif (isset($info['thumbnail_medium'])) $image_url = $info['thumbnail_medium'];
            else                                      $image_url = $info['thumbnail_small'];

            $tmp_path  = $this->app->path('#tmp:').'/'.$provider.'_'.$id.'.jpg';

            $meta['title'] = $info['title'] ?? '';
            $meta['description'] = strip_tags($info['description'] ?? '');

        }
        
        if ($folder = $this->getFolder()) {
            $meta['folder'] = $folder;
        }

        // save file in #tmp dir
        if (file_put_contents($tmp_path, file_get_contents($image_url))) {

            $assets = $this->app->module('cockpit')->addAssets([$tmp_path], $meta);

            unlink($tmp_path); // delete file in #tmp dir

        }

        return isset($assets[0]) ? $assets[0] : [];

    },

    'getFolder' => function() {

        $config = $this->app->storage->getKey('cockpit/options', 'videolinkfield', []);

        if (!empty($config['folder_id'])) {
            return $config['folder_id'];
        }

        return false;

    },

]);

// ACL
$this('acl')->addResource('videolinkfield', ['manage']);

// admin
if (COCKPIT_ADMIN && !COCKPIT_API_REQUEST) {
    include_once(__DIR__.'/admin.php');
}
