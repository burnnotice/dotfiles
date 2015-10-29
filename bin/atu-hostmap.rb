#!/usr/bin/env ruby
#get the CN of a cert and reverse resolve of an IP
require 'socket'
require 'openssl'
require 'resolv'

ip = ARGV[0]
port = 443 unless ARGV[2]
#puts "ip: #{ip}"
#puts "port: #{port}"

def ssl_cert(ip, port)
  tcp_client = TCPSocket.new(ip, port)
  ssl_client = OpenSSL::SSL::SSLSocket.new(tcp_client).connect
  cert = OpenSSL::X509::Certificate.new(ssl_client.peer_cert)
  ssl_client.sysclose
  tcp_client.close
  return cert
end

def rresolve(ip)
  Resolv.getname(ip)
end

puts "#{ip} RESULTS:"
begin
cert = ssl_cert(ip,port)
cert.subject.to_s.scan(/CN=(.*)$/)
puts "  SSL - #{ip}:#{port} - #{$1}"
rescue Errno::ETIMEDOUT
  puts "  SSL - #{ip}:#{port} - ERROR: TIME OUT"
rescue Errno::ECONNREFUSED
  puts "  SSL - #{ip}:#{port} - ERROR: CONNECTION REFUSED"
end

begin
  rresolve ip
rescue Resolv::ResolvError
  puts "  DNS - #{ip} - ERROR: NO ENTRY"
end