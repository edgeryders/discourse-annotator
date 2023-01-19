/*
 * Annotator plugin documentation:
 * http://docs.annotatorjs.org/en/v1.2.x/hacking/plugin-development.html
 *
 */
Annotator.Plugin.MyTags = function (element, message) {
    var plugin = {};
    plugin.input = null;

    plugin.pluginInit = function () {

        function parseTags(string) {
            if (string.length == 0) {
                return [];
            }
            var v = JSON.parse(string)
            var tags = [];
            for (var i = 0; i < v.length; i++) {
                tags.push(v[i]['value']);
            }
            return tags;
        }


        this.annotator.viewer.addField({
            load: function (field, annotation) {
                field = $(field);
                // console.log(annotation.codes);
                if (annotation.codes && $.isArray(annotation.codes) && annotation.codes.length) {
                    return field.addClass('annotator-tags').html(function () {
                        var string;
                        return string = $.map(annotation.codes, function (tag) {
                            return '<span class="annotator-tag">' + tag + '</span>';
                        }).join(' ');
                    });
                } else {
                    return field.remove();
                }
            }
        })

        this.field = this.annotator.editor.addField({
            label: Annotator._t('Add some codes here') + '\u2026',
            submit: function (field, annotation) {
                return annotation.codes = parseTags(plugin.input.val());
            }
        });

        // https://github.com/yairEO/tagify#settings
        var tagify = new Tagify($(this.field).find(':input')[0], {
            whitelist: [],
            editTags: false,
            keepInvalidTags: true,
            dropdown: {
                fuzzySearch: true,
                enabled: 0,                 // <- show suggestions on focus
                // closeOnSelect: false,    // <- do not hide the suggestions dropdown once an item has been selected
            }
        });


        this.annotator.subscribe("annotationEditorShown", function (editor, annotation) {
            tagify.removeAllTags();
            if (annotation.codes) {
                tagify.addTags(annotation.codes);
            }
            if (Object.keys(annotation).length === 0) { // create annotation
                tagify.settings.maxTags = Infinity
                tagify.settings.keepInvalidTags = true
            } else { // edit annotation
                tagify.settings.maxTags = 1
                tagify.settings.keepInvalidTags = false
            }
        });


        var controller; // for aborting the call
        tagify.on('input', onInput);

        function onInput(e) {
            var value = e.detail.value;
            tagify.settings.whitelist.length = 0;
            // https://developer.mozilla.org/en-US/docs/Web/API/AbortController/abort
            controller && controller.abort();
            controller = new AbortController();
            // show loading animation and hide the suggestions dropdown
            tagify.loading(true).dropdown.hide.call(tagify)
            var projectId = window.location.href.match(/annotator\/projects\/(.+)\/topics\//i)[1];
            fetch('/annotator/projects/'+projectId+'/localized_codes.json?q='+value, {signal: controller.signal})
                .then(function (result) {
                    return result.json()
                })
                .then(function (results) {
                    var whitelist = [];
                    for (var i = 0; i < results.length; i++) {
                        whitelist.push(
                            {
                                value: results[i]['localized_path'],
                                title: results[i]['description']
                            }
                        );
                    }
                    // update whitelist Array in-place
                    // Causes this error https://github.com/lautis/uglifier/issues/127 but `Uglifier.new(harmony: true)`
                    // doesn't resolve it.
                    // tagify.settings.whitelist.splice(0, whitelist.length, ...whitelist)
                    tagify.settings.whitelist = whitelist;
                    tagify.loading(false).dropdown.show.call(tagify, value); // render the suggestions dropdown
                });

        }

        return plugin.input = $(this.field).find(':input');
    };

    return plugin;
};