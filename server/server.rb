require 'socket'
require 'csv'
class Server

def initialize(porta,ip)
  @servidor = TCPServer.open(ip,porta)
  @conexoes = Hash.new
  @rooms = Hash.new
  @clientes = Hash.new
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
    elsif tipoOperacao == :Cliente
    loginCliente client
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

def loginCliente client
arr = listen_user_messages client
  client.puts clientes[arr[0].to_sym]
end

  def cadastro(client)
   arr = listen_user_messages client
  armazena(arr[0],arr[1],arr[2],arr[3],arr[4],arr[5],arr[6],arr[7],arr[8])
  end

  def login(client)
    arr = listen_user_messages client
    puts arr[0]
    puts arr[1]
    puts arr[2]

    CSV.foreach("cadastrados.csv") do |row|
      if (row[1] == arr[0]) && (row[2] == arr[1])
        puts "sim"
        #Cadastra os clientes na Hash para possível login
        @clientes[arr[0].to_sym][:nome]=row[0] unless clientes[arr[0].to_sym]
        @clientes[arr[0].to_sym][:email]=row[1] unless clientes[arr[0].to_sym]
        @clientes[arr[0].to_sym][:senha]=row[2] unless clientes[arr[0].to_sym]
        @clientes[arr[0].to_sym][:cpf]=row[3] unless clientes[arr[0].to_sym]
        @clientes[arr[0].to_sym][:endereco]=row[4] unless clientes[arr[0].to_sym]
        @clientes[arr[0].to_sym][:casa]=row[5] unless clientes[arr[0].to_sym]
        @clientes[arr[0].to_sym][:cidade]=row[6] unless clientes[arr[0].to_sym]
        @clientes[arr[0].to_sym][:telefone]=row[7] unless clientes[arr[0].to_sym]
        @clientes[arr[0].to_sym][:cep]=row[8] unless clientes[arr[0].to_sym]
        client.puts 0
      end

      puts "nao"
      client.puts 1

  end

  end
end



Server.new(3001,"192.168.0.11")
