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
                // console.log(annotation.tags);
                if (annotation.tags && $.isArray(annotation.tags) && annotation.tags.length) {
                    return field.addClass('annotator-tags').html(function () {
                        var string;
                        return string = $.map(annotation.tags, function (tag) {
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
                return annotation.tags = parseTags(plugin.input.val());
            }
        });


        var tagify = new Tagify($(this.field).find(':input')[0], {
            whitelist: [],
            editTags: false,
            keepInvalidTags: true,
            dropdown: {
                enabled: 0,                 // <- show suggestions on focus
                // closeOnSelect: false,    // <- do not hide the suggestions dropdown once an item has been selected
            }
        });


        this.annotator.subscribe("annotationEditorShown", function (editor, annotation) {
            tagify.removeAllTags();
            if (annotation.tags) {
                tagify.addTags(annotation.tags);
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
            fetch('/annotator/localized_codes.json?q=' + value, {signal: controller.signal})
                .then(RES => RES.json())
                .then(function (results) {
                    var whitelist = [];
                    for (var i = 0; i < results.length; i++) {
                        whitelist.push(results[i]['localized_path']);
                    }
                    // update whitelist Array in-place
                    tagify.settings.whitelist.splice(0, whitelist.length, ...whitelist)
                    tagify.loading(false).dropdown.show.call(tagify, value); // render the suggestions dropdown
                })
        }

        return plugin.input = $(this.field).find(':input');
    };

    return plugin;
}