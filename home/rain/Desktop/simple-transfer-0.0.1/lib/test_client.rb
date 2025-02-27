require_relative "./transfer.rb"

include SimpleTransfer


def test()
    s = Sender.new("localhost", 5000, logging = true)
    s.send_directory("/home")
end


test() #!