# usage: ruby build_windows.rb

require 'fileutils'
include FileUtils

rm_f "donacoin.jar"

cp_r "vendor/cpuminer/bin/windows_32/", "build_windows"
cp_r "vendor/cpuminer/bin/windows_64/", "build_windows"

puts `warble`


cp_r "donacoin.jar", "build_windows"