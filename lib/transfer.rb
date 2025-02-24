require "socket"
require "fileutils"
require "time"

module SimpleTransfer
  def log_transfer(message, level = "INFO")
    Kernel.puts "[#{level}] [%s] #{message}" % Time.now.utc.iso8601
  end

  def progress_bar(download, length)
    i = (download.to_f / length.to_f * 30).to_i
    return "[" + "❚" * i + " " * (30 - i) + "]"
  end

  def log_progress(downloaded, length, filename)
    Kernel.print "\r[TRANSFER!] Downloading #{filename}... #{downloaded}/#{length} bytes"
  end

  class Server < TCPServer
    @@recv_size = 1024 * 30

    def initialize(*args)
      super(*args)
      @logging = true
    end

    def port()
      return self.addr[1]
    end

    def recv_chunk()
      return @conn.recv(@@recv_size)
    end

    def init_transfer()
      @conn.send("SYNC OK", 1024)
      data_length = Integer(recv_chunk()) # receive data length
      log_transfer("received data length: #{data_length}", level = "DEBUGGING") if @logging
      @conn.send("LENGTH OK", 1024)
      filename = recv_chunk() # receive file name
      log_transfer("received filename: #{filename}", level = "DEBUGGING") if @logging
      @conn.send("FILENAME OK", 1024)
      log_transfer(
        "transfer initiated for #{filename} size: #{data_length}", level = "INFO"
      ) if @logging
      return data_length, filename
    end

    def recv_initiation()
      start_sign = recv_chunk() # wait for the client to sync
      log_transfer("received start sign: #{start_sign}", level = "DEBUGGING") if @logging
      if start_sign != "SYNC NOW"
        if start_sign.empty?
          return 0
        end
        return nil
      end
      return init_transfer()
    end

    def handle_init()
      init_data = recv_initiation()
      if init_data == nil
        log_transfer("Failed to receive initiation data", level = "WARNING") if @logging
        return false, nil
      elsif init_data == 0
        log_transfer("Connection closed by the client", level = "WARNING") if @logging
        return false, 0
        return false, init_data
      end
      return init_data
    end

    def recv_file()
      init = handle_init()
      if not init[0]
        return init[1]
      end
      data_length, filename = init
      data = ""
      while data.length < data_length
        data += recv_chunk()
        sleep(0.01)
        log_progress(data.length, data_length, filename) if @logging
      end
      Kernel.print "\n"
      if data.length != data_length
        log_transfer(
          "partial data received for #{filename}", level = "WARNING"
        ) if @logging
      end
      return data, filename
    end

    def copyto_local(data)
      fdata, filename = data
      dirname = File.dirname(filename)
      if not File.exist?('.' + dirname)
        FileUtils.mkdir_p(dirname)
      end
      File.open(filename, "wb") do |f|
        f.write(fdata)
      end
    end

    def start()
      log_transfer("(Re)starting Simple-Transfer server!") if @logging
      log_transfer("listening at port %s..." % port) if @logging
      self.listen(16)
      @conn = accept()
      log_transfer("Accepted client: #{@conn.peeraddr[2]}: #{@conn.peeraddr[1]}")
      while true
        filedata = recv_file()
        if filedata == nil
          next
        elsif filedata == 0
          start()
          return
        end
        copyto_local(filedata)
        sleep 0.01
      end
    end
  end

  class Sender < TCPSocket
    @@chunk_size = 5000

    def initialize(host, port, logging = false)
      super(host, port)
      @logging = logging
    end

    def self.buffer(data)
      buffers = Array.new
      data = String(data)
      buffer_amount = @@chunk_size > data.length ? 1 : data.length / @@chunk_size + 1

      for i in 0..buffer_amount - 1
        buffers.push data.slice(i * @@chunk_size, @@chunk_size)
      end

      return buffers
    end

    def self.pack(filename, data)
      buffers = self.buffer(data)

      buffers.unshift filename
      buffers.unshift String(data.length)
      return buffers
    end

    def send_chunk(chunk)
      send(chunk, @@chunk_size)
    end

    def initiate_exchange(package)
      send_chunk("SYNC NOW")
      log_transfer("sent start sign: SYNC NOW", level = "DEBUGGING") if @logging
      recv(1024)
      send_chunk(package.shift)
      log_transfer("sent data length", level = "DEBUGGING") if @logging
      recv(1024)
      send_chunk(package.shift)
      log_transfer("sent filename", level = "DEBUGGING") if @logging
      recv(1024)
    end

    def send_file(filename)
      package = nil
      File.open(filename, "rb") do |f|
        log_transfer("sending #{f.path}") if @logging
        package = Sender.pack(filename, f.read())
      end
      initiate_exchange(package)
      package.each do |chunk|
        send_chunk(chunk)
      end
    end

    def scan_directory(directory_name)
      return Dir["%s/**/*" % directory_name]
    end

    def send_directory(directory)
      scan_directory(directory).each do |f|
        #sleep because there is no sync for end of transfer
        sleep 0.5 
        if File.directory?(f)
          send_directory(f)
        else send_file(f)         end
      end
    end
  end
end
