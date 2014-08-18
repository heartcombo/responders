## 1.1.0

* Lock Rails requirement to < 4.2.

## 1.1.0

* Support Rails 4.1.
* Allow callable objects as the location.

## 1.0.0

* Improve controller generator to work closer to the Rails 4 one, and make it
  compatible with strong parameters.
* Drop support for Rails 3.1 and Ruby 1.8, keep support for Rails 3.2
* Support for Rails 4.0 onward
* Fix flash message on destroy failure. Fixes #61

## 0.9.3

* Fix url generation for namespaced models

## 0.9.2

* Properly inflect custom responders names

## 0.9.1

* Fix bug with namespace lookup

## 0.9.0

* Disable namespace lookup by default

## 0.8

* Allow embedded HTML in flash messages

## 0.7

* Support Rails 3.1 onward
* Support namespaced engines

## 0.6

* Allow engine detection in generators
* HTTP Cache is no longer triggered for collections
* `:js` now sets the `flash.now` by default, instead of `flash`
* Renamed `responders_install` generator to `responders:install`
* Added `CollectionResponder` which allows you to always redirect to the collection path
  (index action) after POST/PUT/DELETE

## 0.5

* Added Railtie and better Rails 3 support
* Added `:flash_now` as option

## 0.4

* Added `Responders::FlashResponder.flash_keys` and default to `[ :notice, :alert ]`
* Added support to `respond_with(@resource, :notice => "Yes!", :alert => "No!")``

## 0.1

* Added `FlashResponder`
* Added `HttpCacheResponder`
* Added responders generators
