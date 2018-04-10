require 'socket'
require 'csv'
require 'fileutils'
class Server

def initialize(porta,ip)
  @servidor = TCPServer.open(ip,porta)
  @conexoes = Hash.new
  @rooms = Hash.new
  @clientes = Hash.new
  @udp = UDPSocket.new
  @udp.bind(ip,porta)
  run
end


def run
loop{
  Thread.new do
  loop {
  data,client = @udp.recvfrom(1024)
  Thread.new(client) do |clientAddress|
    dados = data.split(',')
    printaSensor(dados[0],dados[1])
  end
  }
  end



  Thread.start(@servidor.accept) do |client|
    tipoOperacao = client.gets.chomp.to_sym
    puts tipoOperacao
    if tipoOperacao == :Cadastro
      puts 'entrei'
      cadastro client
    elsif tipoOperacao == :Login
      login client
    elsif tipoOperacao == :Cliente
    loginCliente client
    end
  end




}.join

end

def printaSensor(nome,data)
  time = Time.now.to_s
  time = DateTime.parse(time).strftime("%d-%m-%Y")
  datahora = Time.now.to_s
  datahora = DateTime.parse(datahora).strftime("%d/%m/%Y %H:%M:%S")
  datah = DateTime.parse(datahora).strftime("%d%m%Y")
  FileUtils.mkdir_p "DadosUsuarios"
  FileUtils.mkdir_p "DadosUsuarios/#{nome.to_s}"
  File.open("../server/DadosUsuarios/#{nome.to_s}/#{datah.to_s}.txt","a") do |line|
    line.puts "Consumo >> #{data.to_s} m³/s || Hora >> #{datahora.to_s} "
  end
end

def armazena(name,em,pass,cp,ende,cas,cid,tel,ce)
  File.open("cadastrados.csv","a") do |line|
    line.puts "#{name},#{em},#{pass},#{cp},#{ende},#{cas},#{cid},#{tel},#{ce}"
  end
end


def listen_user_messages(client)
  arr = Array.new
  a = 0
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
   arr.each do |ar|
     ar.gsub!("\n",",")
   end
  armazena(arr[0].to_s,arr[1].to_s,arr[2].to_s,arr[3].to_s,arr[4].to_s,arr[5].to_s,arr[6].to_s,arr[7].to_s,arr[8].to_s)
  end

  def login(client)
    arr = listen_user_messages client
    arr.each do |aray|
      aray.gsub!("\n","")
    end
    p arr
    CSV.foreach("cadastrados.csv") do |row|
      if (row[1] == arr[1]) && (row[2] == arr[2])
        puts "igual"
        #Cadastra os clientes na Hash para possível login
=begin
        @clientes[arr[0].to_sym][:nome]=row[0] unless clientes[arr[0].to_sym]
        @clientes[arr[0].to_sym][:email]=row[1] unless clientes[arr[0].to_sym]
        @clientes[arr[0].to_sym][:senha]=row[2] unless clientes[arr[0].to_sym]
        @clientes[arr[0].to_sym][:cpf]=row[3] unless clientes[arr[0].to_sym]
        @clientes[arr[0].to_sym][:endereco]=row[4] unless clientes[arr[0].to_sym]
        @clientes[arr[0].to_sym][:casa]=row[5] unless clientes[arr[0].to_sym]
        @clientes[arr[0].to_sym][:cidade]=row[6] unless clientes[arr[0].to_sym]
        @clientes[arr[0].to_sym][:telefone]=row[7] unless clientes[arr[0].to_sym]
        @clientes[arr[0].to_sym][:cep]=row[8] unless clientes[arr[0].to_sym]
=end
        client.puts 0
        return
      end

    end
    client.puts 1
    puts "n deu"
  end

end


Server.new(3001,"192.168.25.5")
