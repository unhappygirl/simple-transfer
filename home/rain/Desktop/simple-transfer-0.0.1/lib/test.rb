require_relative "./transfer.rb"

include SimpleTransfer


def test()
    s = Server.new(5000)
    s.start()
end


test() #!
