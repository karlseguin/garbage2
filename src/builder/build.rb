require('json')
require('redis')
require('fileutils')
require('open3')

redis = Redis.new
commit = JSON.parse(ARGV[0])
name = commit['name']
commit = commit['commit']

config = JSON.parse(redis.hget 'projectByName', name)
source = "/tmp/build-#{rand(100000)}"
start = Time.now
build = {:commit => commit['after'], :message => commit['commits'][-1]['message'], :date => Time.now.utc}
output = ''
begin
  output += "\n\ngit clone #{config['url']} #{source}\n"
  output += `git clone #{config['url']} #{source}`
  output += "\n\ncd #{source} && git checkout #{commit['after']}\n"
  output += `cd #{source} && git checkout #{commit['after']} 2>&1`
  output += "\n\ncd #{source} && npm install\n"
  output += `cd #{source} && npm install 2>&1`


  coffeescript = config['coffeescript']
  if coffeescript
    output += "\n\ncoffee -c -o #{source}/lib #{source}/#{config['coffeescript']}\n"
    result = `coffee -c -o #{source}/lib #{source}/#{config['coffeescript']}`
    raise StandardError.new('coffeescript compilation failed: ' + result) if result.length > 0
  end

  if config['test']
    if config['test']['type'] == 'jasmine'
      command = "\n\ncd #{source} && /usr/local/bin/jasmine-node --noColor"
      command += " --coffee" if coffeescript
      command += " #{config['test']['source']}/\n"
      output += command
      result = `#{command}`
      matches = /(\d+\.\d+) seconds\n(\d+) tests, (\d+) assertions, (\d+) failures/.match(result)
      raise StandardError.new('test failed: ' + result)  if matches.nil?
      build[:test] = {:time => matches[1], :total => matches[2], :failed => matches[4]}
      output += result
    end
  end
  build[:pass] = true
rescue
  output += $!.message
  build[:pass] = false
ensure
  build[:output] = output
  build[:time] = Time.now.utc - start
  redis.rpush "builds:#{name}", build.to_json
  FileUtils.rm_rf(source)
end