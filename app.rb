require 'tty-reader'
require 'discourse_api'
require 'yaml'
require 'json'
require 'securerandom'

@config = YAML.load_file('config.yml')
site = ENV['SITE']

if site.nil? || site == ""
  puts "Please specify a site"
  exit 1
end

client = DiscourseApi::Client.new(@config[site]['host'])
client.api_key = @config[site]['api_key']
client.api_username = @config[site]['api_username']

type = ARGV[0]
rand = SecureRandom.hex

if type.nil? || type == ""
  puts "Please specify an action type 'new-topic', 'new-post', or 'edit-last-post'"
  exit 1
end

case type
when "new-topic"

  title = ARGV[1]
  category_id = ARGV[2]

  system('vim', "#{rand}.md")

  contents = File.open("#{rand}.md", 'rb').read

  new_topic = {
    title: title,
    raw: contents
  }

  if category_id
    new_topic.merge!(category: category_id)
  end

  client.create_topic(new_topic)
  File.delete "#{rand}.md"

when "new-post"
  topic_id = ARGV[1]

  if topic_id.nil? || topic_id == ""
    puts "Please provide a topic_id when editing a topic"
  end

  system('vim', "#{rand}.md")

  contents = File.open("#{rand}.md", 'rb').read

  new_post = {
    topic_id: topic_id,
    raw: contents
  }

  client.create_post(new_post)
  File.delete "#{rand}.md"

when "edit-last-post"

  topic_id = ARGV[1]

  if topic_id.nil? || topic_id == ""
    puts "Please provide a topic_id when editing a topic"
  end

  topic = client.topic(topic_id)

  # Grab the last post in a topic
  stream = topic['post_stream']['stream']
  post_id = stream.last

  response = client.get_post(post_id)
  post = response['raw']

  File.write("#{rand}.md", post)

  system('vim', "#{rand}.md")

  contents = File.open("#{rand}.md", 'rb').read
  client.edit_post(post_id, contents)
  File.delete "#{rand}.md"

end

