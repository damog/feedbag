#!/usr/bin/env rake
# frozen_string_literal: true

require "bundler"
require "bundler/gem_tasks"
Bundler::GemHelper.install_tasks

require "rake/testtask"
Rake::TestTask.new(:test) do |test|
  test.libs << "lib" << "test"
  test.pattern = "test/*.rb"
  test.verbose = true
end

task default: :test
