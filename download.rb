#!/usr/bin/env ruby

require 'bundler/setup'
require 'mechanize'

if ARGV.size != 4
  puts "Usage: ruby download.rb subdomain id email password"
  puts "Example: ruby download.rb churchio 11209 tim@timmorgan.org mypassword"
  exit(1)
end

(project_subdomain, project_id, email, password) = ARGV

PROJECT_URL  = "https://#{project_subdomain}.oneskyapp.com/admin/project/dashboard/project/#{project_id}"
LOGIN_URL    = "https://#{project_subdomain}.oneskyapp.com/translate/sign/in"
DOWNLOAD_URL = "https://#{project_subdomain}.oneskyapp.com/admin/export/file/project/#{project_id}/language/%s"

agent = Mechanize.new
login = agent.get(LOGIN_URL)
login_form = login.forms.last
login_form.email = email
login_form.password = password
agent.submit(login_form, login_form.buttons.first)

project = agent.get(PROJECT_URL)
language_ids = project.body.scan(/"language_id":\s?([^,]+)/).map(&:first).uniq - ['1']

language_ids.each do |language_id|
  url = DOWNLOAD_URL % language_id
  puts url
  download = agent.get(url)
  download.save("out/#{language_id}.zip")
end
