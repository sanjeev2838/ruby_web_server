# version 1:- (first part) 
# --------------
require 'socket'

# read documentation of /home/sanjeev/Applications/RubyMine-6.3.2/rubystubs193/tcp_server.rb:10

class Server
  def initialize(port)
    @server = TCPServer.new(port)
  end

  def start
    socket = @server.accept
    data = socket.readpartial(1024)
    puts data
    socket.write "HTTP/1.1 200 OK\r\n"
    socket.write "\r\n"
    socket.write "Hello\n"
    socket.close
  end
end

server =  Server.new(3000)
puts "Server is started"
server.start

# Let accepts more connection on server 

class Server
  def initialize(port)
    @server = TCPServer.new(port)
  end

  def start
  	loop do
      socket = @server.accept
      data = socket.readpartial(1024)
      puts data
      socket.write "HTTP/1.1 200 OK\r\n"
      socket.write "\r\n"
      socket.write "Hello\n"
      socket.close
    end
  end
end

server =  Server.new(3000)
puts "Server is started"
server.start

# version 2 :- 
# --------------------------
# Let create a connection class to refactor it a bit 
require 'socket'

# read documentation of /home/sanjeev/Applications/RubyMine-6.3.2/rubystubs193/tcp_server.rb:10

class Server
  def initialize(port)
    @server = TCPServer.new(port)
  end

  def start
    # so that server being alive
    loop do
      socket = @server.accept
      connection = Connection.new(scoket)
      connection.process
    end
  end
end

class Connection
  def initialize(socket)
    @socket = socket
  end

  def process
    data = @socket.readpartial(1024)
    puts data
    @socket.write "HTTP/1.1 200 OK\r\n"
    @socket.write "\r\n"
    @socket.write "Hello\n"
    @socket.close
  end
end


server =  Server.new(3000)
puts "Server is started"
server.start


# version 3 :- 
# --------------------------
require 'socket'

# read documentation of /home/sanjeev/Applications/RubyMine-6.3.2/rubystubs193/tcp_server.rb:10

class Server
  def initialize(port)
    @server = TCPServer.new(port)
  end

  def start
    # so that server being alive
    loop do
      socket = @server.accept
      connection = Connection.new(socket)
      connection.process
    end
  end
end

class Connection
  def initialize(socket)
    @socket = socket
  end

  def process
    data = @socket.readpartial(1024)
    puts data
    send_response
  end

  def send_response
    @socket.write "HTTP/1.1 200 OK\r\n"
    @socket.write "\r\n"
    @socket.write "Hello\n"
    close
  end

  def close
    @socket.close
  end
end


server =  Server.new(3000)
puts "Server is started"
server.start


# version 4 :- 
# ----------------
#Let parse the diffrent headers that are passed by request by using http/parser
require 'socket'
require 'http/parser'
# read documentation of /home/sanjeev/Applications/RubyMine-6.3.2/rubystubs193/tcp_server.rb:10

class Server
  def initialize(port)
    @server = TCPServer.new(port)
  end

  def start
    # so that server being alive
    loop do
      socket = @server.accept
      connection = Connection.new(socket)
      connection.process
    end
  end
end

class Connection
  def initialize(socket)
    @socket = socket
    @parser = Http::Parser.new(self)
  end

  def process
    # data = @socket.readpartial(1024)
    # we need to keep reading tha data
  while  !@socket.closed? || !@socket.eof?
      data = @socket.readpartial(1024)
      @parser <<  data
    end
    # # instead of putting data here we can feed it to parser
    # @parser <<  data
  end

  def on_message_complete
    puts "#{@parser.http_method} #{@parser.request_path}"
    puts "  " + @parser.headers.inspect
    puts
    send_response
  end


  def send_response
    @socket.write "HTTP/1.1 200 OK\r\n"
    @socket.write "\r\n"
    @socket.write "Hello\n"
    close
  end

  def close
    @socket.close
  end
end

server =  Server.new(3000)
puts "Server is started"
server.start

#------------------------version 5 ------------------------------------
# version 5:- 
# Make it fully compliant as per Rack specification :- 
require 'socket'
require 'http/parser'
require 'stringio'
# read documentation of /home/sanjeev/Applications/RubyMine-6.3.2/rubystubs193/tcp_server.rb:10

class Server
  def initialize(port, app)
    @server = TCPServer.new(port)
    @app = app
  end

  def start
    # so that server being alive
    loop do
      socket = @server.accept
      connection = Connection.new(socket,@app)
      connection.process
    end
  end
end

class Connection
  def initialize(socket,app)
    @socket = socket
    @app = app
    @parser = Http::Parser.new(self)
  end

  def process
    # data = @socket.readpartial(1024)
    # we need to keep reading tha data
    until @socket.closed? || @socket.eof?
      data = @socket.readpartial(1024)
      @parser <<  data
    end
    # # instead of putting data here we can feed it to parser
    # @parser <<  data
  end

  def on_message_complete
    puts "#{@parser.http_method} #{@parser.request_path}"
    puts "  " + @parser.headers.inspect
    puts

    env = {}
    @parser.headers.each_pair do |name, value|
      name = "HTTP_" + name.upcase.tr("-","_")
      env[name] = value
    end

    env["PATH_INFO"] = @parser.request_path
    env["REQUEST_METHOD"] = @parser.http_method
    env["rack.input"] = StringIO.new
    send_response(env)
  end


  def send_response(env)
    status, header, message  = @app.call(env)
    @socket.write "HTTP/1.1 200 OK\r\n"
    @socket.write "\r\n"
    @socket.write "Hello\n"
    close
  end

  def close
    @socket.close
  end
end

class App
  def call(env)
    message = "Hello from the #{Process.pid}.\n"
    [
        200,
        { 'Content-Type' => 'text/plain', 'Content-Length' => message.size.to_s },
        [message]
    ]
  end
end

app = App.new
server =  Server.new(3000, app)
puts "Server is started"
server.start

#-------------------------------
# returning headers from a rack application :- 

see the final version on attached ruby file
