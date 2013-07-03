require 'ipaddr'
require 'timeout'
require 'socket'

class IPRange
  
  include Enumerable
  
  def initialize(from, to)
    @from = IPAddr.new from
    @to = IPAddr.new to
  end
  
  def each
    current = @from
    until current > @to
      yield current
      current = current.succ
    end
  end

end

class PortScanner
  
  attr_reader :open_ports
  
  CommonPorts = [7,20,21,22,23,25,80,220,443,992,993,995,8080]
  
  def initialize(from, to, timeout=0.01)
    @from = from
    @to = to
    @timeout = timeout
    
    @ip_range = IPRange.new(@from, @to)
    @open_ports = []
  end
  
  def scan(*ports)
    ports = CommonPorts if ports.empty?
    @open_ports = []
    @ip_range.each { |ip| ports.each { |port| connect(ip, port) } }
  end

  private
  
  def socket
    @socket ||= Socket.new(AF_INET, SOCK_STREAM, 0)
  end
  
  def connect(ip, port)
    begin
      Timeout::timeout(@timeout) { TCPSocket.new(ip.to_s, port ) }
      @open_ports << "#{ip.to_s}:#{port}"
      puts "Port Open: #{ip.to_s}:#{port}"
    rescue Timeout::Error
      puts "Port Closed: #{ip.to_s}:#{port}"
    rescue => e
      puts "Port Closed: #{ip.to_s}:#{port}"
    end
  end
  
end

scanner = PortScanner.new("172.16.24.0", "172.16.24.40")
scanner.scan(20,21,22,80,8080)
p scanner.open_ports