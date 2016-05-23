$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'pry'
require 'emiler'

require "codeclimate-test-reporter"
CodeClimate::TestReporter.start
