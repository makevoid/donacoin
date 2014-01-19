require 'warbler'
Warbler::Task.new

task :win do
  `rm -rf build`
  `mkdir build`
  `cp -R vendor/cpuminer/windows_32 build/`
  `cp -R vendor/cpuminer/windows_64 build/`
  `warble`
  `cp donacoin.jar build/`
end


# notes: /opt/jruby/bin/rake win