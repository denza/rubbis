require 'redis'

require 'rubbis/server'

TEST_PORT = 6380

RSpec.configuration do |c|
  c.treat_symbols_as_metadata_keys_with_true_values=true
end

describe 'Rubbis', :acceptance do
  it 'responds to ping' do
    with_server do
      expect(client.ping).to eq("OK")
    end
  end

  def client
    Redis.new(host: 'localhost',port: TEST_PORT)
  end

def with_server
  server_thread = Thread.new do
    server = Rubbis::Server.new(TEST_PORT)
    server.listen
  end

  wait_for_open_port TEST_PORT

  yield
rescue TimeoutError
  sleep 0.01
  server_thread.value unless server_thread.alive?
  raise
ensure
  Thread.kill(server_thread) if server_thread
end

def wait_for_open_port(port)
  time = Time.now
  while !check_port(port) && 1 > Time.now - time
    sleep 0.01
  end

  raise TimeoutError unless check_port(port)
end

def check_port(port)
  'nc -z localhost #{port}'
  #$?.success?
  true
end
end
