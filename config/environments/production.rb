# damingo (Github ID), 2020-08-09, See: https://github.com/lautis/uglifier/issues/127
require 'uglifier'


AnnotatorStore::Application.configure do

  # damingo (Github ID), 2020-08-09, See: https://github.com/lautis/uglifier/issues/127
  config.assets.js_compressor = Uglifier.new(harmony: true)
end
