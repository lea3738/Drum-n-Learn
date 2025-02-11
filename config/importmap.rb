# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "bootstrap", to: "bootstrap.min.js", preload: true
pin "@popperjs/core", to: "popper.js", preload: true
pin "tone" # @15.0.4
pin "@babel/runtime/helpers/classCallCheck", to: "@babel--runtime--helpers--classCallCheck.js" # @7.26.0
pin "@babel/runtime/helpers/createClass", to: "@babel--runtime--helpers--createClass.js" # @7.26.0
pin "@babel/runtime/helpers/slicedToArray", to: "@babel--runtime--helpers--slicedToArray.js" # @7.26.0
pin "automation-events" # @7.1.4
pin "standardized-audio-context" # @25.3.77
pin "tslib" # @2.8.1
pin "stimulus" # @3.2.2
