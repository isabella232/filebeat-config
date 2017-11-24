#!/usr/bin/env ruby

require 'docker'
require 'json'
require 'yaml'
require "diffy"

def log(message)
  $stderr.puts message
end

def diff(old_contents, contents)
  Diffy::Diff.new(old_contents, contents, context: 3, include_diff_info: true)
end

def write_if_changed(path, contents)
  if !(file_exists = File.exists?(path)) || (old_contents = File.read(path)) != contents
    log "Config updated... Writing new config to #{path}"
    log diff(old_contents, contents) if old_contents
    File.rename(path, "#{path}.old") if file_exists
    File.write(path, contents)
  end
end

def main
  inputs = []

  Docker::Container.all(all: true).each do |container|
    container.info["Labels"].each do |label, value|
      next unless label =~ /\Afilebeat\.([a-z0-9-]+)\.paths\z/
      type = Regexp.last_match[1]
      input = { "input_type" => 'log' }

      if %w{unicorn rails}.include?(type)
        input["multiline"] ||= {}
        input["multiline"]["pattern"] = "^[[:space:]]|^$"
        input["multiline"]["negate"] = false
        input["multiline"]["match"] = "after"
      end

      input["paths"] = value.split(",")
      input["exclude_files"] = ['.gz$']
      input["fields_under_root"] = true
      input["fields"] ||= {}
      input["fields"]["type"] = type
      input["ignore_older"] = "1h"
      inputs << input
    end
  end

  filebeat_config = {
    "filebeat.prospectors" => inputs,
  }.to_yaml

  write_if_changed("/shared/app_prospectors.yml", filebeat_config)
end

while true do
  main
  sleep 60
end
