# Discourse Annotator

*(aka Open Ethnographer)*

[1. Overview](#1-overview)
[2. Features](#2-features)
[3. Architecture](#3-architecture)


## 1. Overview

Discourse Annotator is a text annotation application for [Discourse](https://www.discourse.org). Discourse is currently the best and most widely used open source web forum software.

Discourse Annotator is free software, written in Ruby and based on [Annotator](https://annotatorjs.org/) and our fork of the now-archived [Annotator Store](https://github.com/itskingori/annotator_store-gem) software.

Since we developed and use Discourse Annotator for our online ethnography offerings, we also call this software "Open Ethnographer". It has more general usecases though, so the official name is Discourse Annotator.

For additional (though outdated) documentation, see [README.annotator-store.md](https://github.com/edgeryders/discourse-annotator/blob/master/README.annotator-store.md).


## 2. Features

* **Coding ("tagging") selected text.** Any text you select out of any contribution to a discussions in Discourse ("Discourse posts") can be freely coded (ethnography jargon for "tagging").

* **On-the-fly coding.** Codes ("tags") are automatically created in case a code by that name does not yet exist.

* **Code hierarchies.** Your codes can optionally be arranged into a hierarchy. This is useful for later analysis, as you can create a concept hierarchy that way. For example, annotations with the codes "joy" and "sadness" could later be found additionally as annotations of a common parent code "emotion".

* **Collaborative coding.** All annotations are associated with the Discourse username of the user who created them. You can see the annotations made by other users of the software. Also, Discourse Annotator can propose you both your own and others' codes in the auto-complete of the coding overlay window. This behavior can be adapted in your Discourse Annotator user settings.

* **Multilingual codes.** Codes ("tags") can have their names translated into any number of languages, and Discourse Annotator will preferentially propose translated code names if they match the language you have chosen in your user settings. To support translating your codes in bulk, there is a special translation view in the Discourse Annotator backend.

* **Image and video coding.** In addition to text selections, you can also add codes to selections of an image (a rectangle) and of video (a rectangle plus start and end time). This works with all images and videos uploaded to a Discourse forum post.

* **Management backend.** To manage your codes and annotations after you created them, there is a mature management backend where you can list Discourse topics, codes and annotations, search, filter and sort these lists, and create, edit and delete records in these lists.

* **Graph-based analysis.** All codes and annotations created in Discourse Annotator, together with the original text content, can be imported into both [Graphryder](https://github.com/edgeryders/graphryder-dashboard) and [RyderEx](https://github.com/edgeryders/ryderex). Note that Graphryder ("Graphryder 1") is legacy software and should no longer be used; RyderEx ("Graphryder 2") is a much improved, much faster, fully functional reimplementation.

* **Extensible.** Some additional features are prepared in the data structures, but not currently implemented, including: freetext comments as part of annotations; more annotations types than just text, image and video.


## 3. Architecture

**Annotation library.** Our solution to create annotations on selected text (or image or video portions) is an open source JavaScript library called [Annotator](https://annotatorjs.org/) (also often called Annotator.JS). Unfortunately, this software is no longer maintained, so [we are looking](https://github.com/edgeryders/discourse-annotator/issues/223) to replace it with an alternative, possibly [RecogitoJS](https://github.com/recogito/recogito-js).

**Rails engines.** Discourse Annotator includes two (!) [Rails engines](https://guides.rubyonrails.org/engines.html). The Annotator storage backend, which we forked from [itskingori/annotator_store-gem](https://github.com/itskingori/annotator_store-gem), is the first. [Administrate](https://github.com/thoughtbot/administrate), a rapid generator for admin backends, is the second. Though unusual, we did not experience issues combining two Rails engines in this way.

**Packaging format.** Discourse Annotator is not packaged as a regular [Discourse plugin](http://www.discourse.org/plugins), but rather as a [Ruby gem](https://en.wikipedia.org/wiki/RubyGems) that you can add to your Discourse repository. This means, you need to fork the official Discourse software in order to install Discourse Annotator. See our fork [edgeryders/discourse](https://github.com/edgeryders/discourse) for an example. We chose this packaging format because of the extensive nature of Discourse Annotator, including many Ruby on Rails generated backend pages that are not usually part of plugins.

**Adaptation to other host software.** Due to the Rails engines and gem packaging format, Discourse Annotator is a relatively self-contained Ruby application that can relatively easily be adapted to create annotations for content in other applications than Discourse. However, it needs access to the database of that application, so it will have to be a self-hosted application. Cloud applications of which you don't have the source code available will not work for this purpose. If these cloud applications provide a plugin interface, you would have to use that to create an annotation solution; if not, there is no clean software architecture for building an annotation solution, because the analysis of third-party HTML is much too fragile for anchoring annotations.
