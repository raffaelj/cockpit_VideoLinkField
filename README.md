# VideoLinkField Addon for Cockpit CMS

Copy a url from YouTube or Vimeo, click the Button "Find Values", wait a second and in the background starts a service, that downloads the video thumbnail and returns some meta data.

It works without a YouTube API key.

## Installation

Copy this repository into `/addons` and name it `VideoLinkField` or

```bash
cd path/to/cockpit
git clone https://github.com/raffaelj/cockpit_VideoLinkField.git addons/VideoLinkField
```

## Legal advice

If you don't have the rights to use, download or store the thumbnails, you shouldn't use this addon.

## Intended Use

You have your own YouTube or Vimeo channel (or you asked for permission before embedding content from other persons) and you want a simple way to build a privacy friendly website with embedded videos.

But embedding external videos directly is a bad idea for multiple reasons:

1. Privacy - Google tracks my visitors if a YouTube iframe loads videos on startup.
2. EUGDPR - I have to ask my visitors before I can embed third party resources with tracking mechanisms
3. Page speed - If my visitors don't want to see a video, I don't want to load the preview window with 1-2MB

The idea is simple:

Users have a simple UI to copy and paste a video link without taking care of embed snippets. After loading the data from the Wysiwyg field, the link exists, even if users (or search engine bots) disabled javascript. When the document is ready and the visitor accepted cookie usage and third party requests, a script converts the links to iframes.

## Features

### Custom Field

* has a preview of the thumbnail
* stores an object with these keys:
  * url
  * text
  * title
  * id
  * provider
  * asset_id

### TinyMCE Plugin

It has no thumbnail preview, but it produces a simple html `<a>` tag with all the data I need to embed it dynamically.

Example output:

`<a href="https://www.youtube.com/watch?v=fSdVs95Kesk" data-video-id="fSdVs95Kesk" data-video-provider="youtube" data-video-thumb="5cdf0b193338621488000156" data-video-width="480" data-video-height="360">Poledance-Show beim Kammgarnspinnereifest 2018</a>`

## Settings

Go to "settings" --> "VideoLinkField" or call `/videolinkfield/settings`.

Now you can define a folder, where all thumbnails should be stored. It works without a folder, too.

Make sure, that you are an admin or to set the rights to manage the addon. Example configuration in `/config/config.yaml`:

```yaml
groups:
    author:
        cockpit:
            backend: true
        videolinkfield:
            manage: true    # Now authors can change the folder

```

You don't have to set up anything for normal usage.

## What happens internally?

Thumbnails are stored as assets. If title and description are available, they get stored in the assets meta data, too.

### YouTube

* two server-side requests to
  * `https://img.youtube.com/vi/VIDEO_ID/0.jpg` to get the thumbnail
  * `https://www.youtube.com/oembed?url=https://www.youtube.com/watch?v=VIDEO_ID&format=json` to get the video title

### Vimeo

* two server-side requests to
  * `http://vimeo.com/api/v2/video/VIDEO_ID.json` to get the thumbnail url, the title and the description
  * and a second one to download the thumbnail

## Copyright and License

Copyright 2019 Raffael Jesche under the MIT license.

See [LICENSE](/LICENSE) for more information.
