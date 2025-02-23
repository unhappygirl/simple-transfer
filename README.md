This gem is created to make transfering whole directories; scripts, photos, videos, any files that are up to 30 MB simple and easy.

**Please don't forget to read the notes section.**



## Usage

As the name suggests, to transfer files is simple and easy with ```simple-transfer```.

The ```Transfer``` module has two methods: ```Transfer::run_server``` and ```Transfer::transfer```.

#### ```Transfer::run_server```

This method will run a server on your local machine. Once you call it, the server will listen for connections.

The server is for receiving files only. So the machine that will receive files needs to call this method first.

#### ```Transfer::transfer```
This method takes two arguments, first argument is the IPv4 of the target; second one is the name of the file, directory that will be sent.

It will try to connect to the target machine if not already connected and send the files that are specified.


## Example


The server:

```
require 'transfer'
include Transfer

Transfer.run_server

```

The client:

```
require 'transfer'
include Transfer

Transfer.transfer('192.168.1.25', 'foo.png')

```

## Notes

* Using ```simple-transfer``` from the interactive ruby shell is terribly bad.

* ```simple-transfer``` uses tcp sockets and buffers data that are bigger than 65 KB. If you are receiving files only partially and encountering strange errors, try setting the ```$MAX_BUFFER_SIZE``` constant to a lower value.

* To make ```simple-transfer``` work on the internetwork, port forwarding is required.

* Relative paths are NOT supported in simple-transfer. Files need to be in the cwd to be transfered.
