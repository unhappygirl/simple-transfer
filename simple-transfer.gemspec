Gem::Specification.new do |s|
    s.name      = 'simple-transfer'
    s.version   = '1.1.3'
    s.platform  = Gem::Platform::RUBY
    s.summary   = 'A gem for transfering files over your network with extreme simplicity -and fast.'
    s.description = "An extremely simple gem that relies on the TCP stack for transfer of files over a IP network.
    It is as simple as it gets. Relies on no other protocol."
    s.authors   = ['Burzum']
    s.email     = ['atifaydinturanli@gmail.com']
    s.license   = 'MIT'
    s.homepage = "https://github.com/unhappygirl/simple-transfer"
    s.metadata = {
      "source_code_uri" => "https://github.com/unhappygirl/simple-transfer",
      "homepage_uri"    => "https://github.com/unhappygirl/simple-transfer"
    }
    s.files     = Dir.glob("{lib,bin}/**/*")
    s.require_path = 'lib'
    s.bindir = 'bin'
    s.executables = ['simple-transfer']
  end