
require_relative "transfer.rb"


$logo = <<EOF

.---.             .         .                             
\___  . ,-,-. ,-. |  ,-.    |- ,-. ,-. ,-. ,-. ," ,-. ,-. 
    \ | | | | | | |  |-' -- |  |   ,-| | | `-. |- |-' |   
`---' ' ' ' ' |-' `' `-'    `' '   `-^ ' ' `-' |  `-' '   
              |                                '          
              '                                                                     
EOF
    

class STShell
    def initialize(server_addr, port)
        @port = port
        @client = SimpleTransfer::Sender.new(server_addr, port, logging=true)
    end

    def self.list_files(path)
        Dir.entries(path).each do |f|
            if File.directory?(f)
                puts "#{f}/"
            else
                puts f
            end
        end
    end

    
    def eval(query)
        p1, p2 = query.split(" ")
        if p1 == "clear"
            system "clear"
        elsif p1 == "send_file"
            if File.directory?(p2)
                puts "You can't send a directory as a file, friend!"
            else
                @client.send_file(p2)
            end
        elsif p1 == "send_directory"
            if not File.directory?(p2)
                puts "You can't send a file as a directory, friend!"
            else
                @client.send_directory(p2)
            end
        elsif p1 == "cd"
            Dir.chdir(p2)
        elsif p1 == "ls"
            if p2.nil?
              STShell.list_files(Dir.pwd)
            else
                STShell.list_files(p2)
            end
        elsif p1 == "help"
            help()
        else
            p "I don't recognize this command: `#{p1}` friend!"
        end
    end

    def help()
        puts "Type 'send_file <filename>' to send a file"
        puts "Type 'send_directory <directory>' to send a directory"
        puts "Type 'cd <directory>' to change directory"
        puts "Type 'ls <directory>' to list directory contents"
        puts "Type help to see this message"
    end

    def read()
        query = $stdin.gets.chomp
        #puts query, echo is very annoying
        return query
    end

    def print()
        Kernel.print("[ST]🍀 #{Dir.pwd} >>>> ")
    end

    def init_loop()
        puts $logo
        puts "STShell initialized on port #{@port}!"
        puts "Hello friend, thank you for using simple transfer!"
        puts "Are you ready to drown in simplicity?"
        puts "It is indeed extremely simple:"
        help()
        repl()
        #real...
        # let it be
    end

    def repl()
        while true
            print()
            query = read()
            begin
                eval(query)
            rescue => e
                p e
                puts "An error occurred, friend! >:3"
            end
        end
    end
end
