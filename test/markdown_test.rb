require 'test_helper'
require 'yaml'
require 'tasks/crawl'
class MarkdownTest < ActiveSupport::TestCase
  # test 'the truth' do
  #   blogs = YAML.load_file(Rails.root.join('config', 'awesome_blogs.yml'))
  #
  #   puts blogs.inspect
  #   assert true
  # end
  test 'the crawl' do
    Tasks::Crawl.do
    assert true
  end
end