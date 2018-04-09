require 'socket'
require 'csv'
class Server

def initialize(porta,ip)
  @servidor = TCPServer.open(ip,porta)
  @conexoes = Hash.new
  @rooms = Hash.new
  @clientes = Hash.new
  @conexoes[:server] = @server
  @conexoes[:rooms] = @rooms
  @conexoes[:clientes] = @clientes
  run
end


def run
loop{
  Thread.start(@servidor.accept) do |client|
    tipoOperacao = client.gets.chomp.to_sym
    puts tipoOperacao
    if tipoOperacao == :Cadastro
      cadastro client
    elsif tipoOperacao == :Login
    login client
    end
  end
}.join

end

def armazena(name,em,pass,cp,ende,cas,cid,tel,ce)
  File.open("cadastrados.csv","a") do |line|
    line.puts "#{name},#{em},#{pass},#{cp},#{ende},#{cas},#{cid},#{tel},#{ce}"
  end
end


def listen_user_messages(client)
  arr = Array.new
  while line = client.gets
    arr << line
  end
return arr
end

  def cadastro(client)
   arr = listen_user_messages client
  armazena(arr[0],arr[1],arr[2],arr[3],arr[4],arr[5],arr[6],arr[7],arr[8])
  end

  def login(client)
    arr = listen_user_messages client
    puts arr[0]
    puts arr[1]

    CSV.foreach("cadastrados.csv") do |row|
      if (row[1] == arr[0]) && (row[2] == arr[1])
        puts "sim"
        client.puts 0
      end

      puts "nao"
      client.puts 1

  end

  end
end

Server.new(3001,"192.168.0.11")

