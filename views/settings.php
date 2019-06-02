
<div>
    <ul class="uk-breadcrumb">
        <li><a href="@route('/settings')">@lang('Settings')</a></li>
        <li class="uk-active"><span>@lang('VideoLinkField')</span></li>
    </ul>
</div>

<div riot-view>

    <form class="uk-form uk-grid" onsubmit="{ submit }">

        <div class="uk-width-medium-1-1">

            <div class="uk-margin">
                <b>{ App.i18n.get('Folder') }</b>
            </div>

            <div data-uk-dropdown="mode:'click'">

                <a class="uk-text-muted">
                    <i class="uk-icon-folder-o"></i> { config.folder_id && folders[config.folder_id] ? folders[config.folder_id].name : App.i18n.get('Select folder') }
                </a>

                <div class="uk-dropdown uk-dropdown-close uk-width-1-1">

                    <strong>{ App.i18n.get('Folders') }</strong>

                    <div class="uk-margin-small-top { App.Utils.count(folders) > 10 && 'uk-scrollable-box' }">
                        <ul class="uk-list">
                            <li if="{ config.folder_id && folders[config.folder_id] }"><a class="uk-link-muted" onclick="{unselectFolder}"><i class="uk-icon-close"></i> { App.i18n.get('No folder') }</a></li>
                            <li each="{folder, idx in folders}" riot-style="margin-left: {(folder._lvl * 10)}px">
                                <a class="uk-link-muted" onclick="{selectFolder}"><i class="{ config.folder_id == folder._id ? 'uk-icon-folder' : 'uk-icon-folder-o' }"></i> {folder.name}</a>
                            </li>
                        </ul>
                    </div>
                </div>

            </div>

            <div class="uk-margin">
                <a class="uk-button uk-button-primary" onclick="{addFolder}">{ App.i18n.get('Add folder') }</a>
            </div>

        </div>

        <cp-actionbar>
            <div class="uk-container uk-container-center">
                <button class="uk-button uk-button-large uk-button-primary">@lang('Save')</button>
                <a class="uk-button uk-button-link" href="@route('/settings')">
                    <span>@lang('Cancel')</span>
                </a>
            </div>
        </cp-actionbar>

    </form>

    <script type="view/script">

        var $this = this;

        // riot.util.bind(this);

        this.config = {{ json_encode($config) }};
        this.folders = {};

        this.on('mount', function() {

            this.load();

        });

        addFolder() {

            App.ui.prompt(App.i18n.get('Folder Name:'), '', function(name) {

                if (!name.trim()) return;

                App.request('/assetsmanager/addFolder', {name:name}).then(function(folder) {

                    if (!folder._id) return;

                    $this.folders[folder._id] = folder;

                    $this.config.folder_id = folder._id;
                    $this.config.folder_name = folder.name;

                    $this.update();
                });
            });
        }

        selectFolder(e) {
            this.config.folder_id = e.item.folder._id;
            this.config.folder_name = e.item.folder.name;

        }

        unselectFolder(e) {
            this.config.folder_id = '';
            this.config.folder_name = '';
        }

        load() {

            App.request('/assetsmanager/_folders', {}).then(function(folders) {

                $this.folders = {};

                folders.forEach( function(f) {
                    $this.folders[f._id] = f;
                });

                $this.update();
            });
        }

        submit(e) {

            if (e) {
                e.preventDefault();
            }

            App.request('/videolinkfield/saveConfig', {config:this.config}).then(function(data){

                if (data) {
                    App.ui.notify('Saved config', 'success');
                } else {
                    App.ui.notify('Saving failed', 'danger');
                }

            });

        }

    </script>

</div>
