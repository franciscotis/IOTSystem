require 'socket'
require 'csv'
require 'fileutils'
require 'resolv-replace'
class Server

def initialize(porta,ip)
  @servidor = TCPServer.open(ip,porta)
  @conexoes = Hash.new
  @rooms = Hash.new
  @clientes = Hash.new
  @metas  = Hash.new
 # leituraMetas
  @udp = UDPSocket.new
 @conexaoudp =  @udp.bind(ip,porta)
  run
end


def run
loop{
=begin
  Thread.start(@conexaoudp) do
    puts "entrou udp"
  loop {
  data,client = @udp.recvfrom(1024)
  Thread.new(client) do |clientAddress|
    dados = data.split(',')
    printaSensor(dados[0],dados[1])
  end
  }
  end
=end

  Thread.start(@servidor.accept) do |client|
    puts "entrou tcp"
    loop {
    tipoOperacao = client.gets.chomp.to_sym
    puts tipoOperacao
    if tipoOperacao == :Cadastro
      cadastro client
      client.close

    elsif tipoOperacao == :Login
      ip = client.gets.to_sym
      email = client.gets
      senha = client.gets
      login client,ip,email,senha
    elsif tipoOperacao == :Cliente
      ip = client.gets.to_sym
      puts "clientelogin"
      getDados ip,client
      elsif tipoOperacao == :Meta
      valor = client.gets
      email = client.gets.to_sym
      armazenaMetas valor, email
    elsif tipoOperacao == :Dados
      email = client.gets.to_sym
    elsif tipoOperaecao == :Sair
      client.close

    end
    }
  end




}.join

end

def

def leituraMetas
  CSV.foreach("metas.csv") do |row|
  unless row.nil?
    @metas[(row[0]).to_sym] = Integer(row[1])
  end
  end
end

def armazenaMetas valor,email
@metas[email] = valor
  File.open("metas.csv","a") do |line|
    line.puts "#{email},#{valor}"
  end
end

def getDados ip,client
  email = @clientes[ip]
  CSV.foreach("cadastrados.csv") do |row|
    if row[1] == email
      row.each do |envio|
        client.puts envio
      end
    end
  end


end

def printaSensor(nome,data)
  time = Time.now.to_s
  time = DateTime.parse(time).strftime("%d-%m-%Y")
  datahora = Time.now.to_s
  datahora = DateTime.parse(datahora).strftime("%d/%m/%Y %H:%M:%S")
  datah = DateTime.parse(datahora).strftime("%d%m%Y")
  FileUtils.mkdir_p "DadosUsuarios"
  FileUtils.mkdir_p "DadosUsuarios/#{nome.to_s}"
  File.open("../server/DadosUsuarios/#{nome.to_s}/#{datah.to_s}.csv","a") do |line|
    line.puts "#{data.to_s},#{datahora.to_s} "
  end
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
   arr.each do |ar|
     ar.gsub!("\n",",")
   end
  armazena(arr[0].to_s,arr[1].to_s,arr[2].to_s,arr[3].to_s,arr[4].to_s,arr[5].to_s,arr[6].to_s,arr[7].to_s,arr[8].to_s)
  end

  def login(client,ip,email,senha)
    puts email.gsub!("\n","")
    puts senha.gsub!("\n","")
    CSV.foreach("cadastrados.csv") do |row|
      if (row[1] == email) && (row[2] == senha)
        @clientes[ip] = email
        client.puts 0
        return
      end

    end
    client.puts 1
  end

end


Server.new(3001,"localhost")



