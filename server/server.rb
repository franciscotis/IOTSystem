require 'socket'
require 'csv'
require 'fileutils'
require 'resolv-replace'
require 'net/smtp'
class Server
  attr_accessor :ip,:porta
def initialize(porta,ip)
  @@id=0
  @ip = ip
  @porta = porta
  @servidor = TCPServer.open(ip,porta)
  @clientes = Hash.new # Hash Armazena todos os clientes conectados no sistema
  @metas  = Hash.new # Hash que armazena a meta de consumo dos clientes
  @consumo = Hash.new # Hash que armazena todos os consumos dos clientes
  @idCliente = Hash.new #Hash que armazena os ids dos clientes
  leituraMetas
  @udp = UDPSocket.new
  @udp.bind(ip,3002)
  run
end

def run
loop{

  Thread.start() do
    puts "entrou udp"
    loop {
      data,client = @udp.recvfrom(1024)
      Thread.new(client) do |clientAddress|
        dados = data.split(',')
        p dados
        printaSensor(dados[0].chomp,dados[1].chomp)
      end
    }
  end

  Thread.start(@servidor.accept) do |client|
    puts "entrou tcp"
    loop {
    tipoOperacao = client.gets.chomp.to_sym
    puts tipoOperacao
    if tipoOperacao == :Cadastro
      cadastro client
    elsif tipoOperacao == :Login
      ip = client.gets.to_sym
      email = client.gets.chomp
      senha = client.gets.chomp
      login client,ip,email,senha
    elsif tipoOperacao == :Cliente
      ip = client.gets.to_sym
      puts "clientelogin"
      getDados ip,client
      elsif tipoOperacao == :Meta
      valor = client.gets.chomp
      email = client.gets.chomp.to_sym
      armazenaMetas client, valor, email
    elsif tipoOperacao == :Dados
      email = client.gets.chomp.to_sym
    elsif tipoOperacao == :Consumo
      email = client.gets.chomp
      getConsumo client,email
    elsif tipoOperacao == :Total
      email = client.gets.chomp
      consumoTotal client,email
    elsif tipoOperacao == :Sensor
    ip = client.gets.to_sym
      client.puts @clientes[ip]
    elsif tipoOperacao == :Sair
      client.close

    end
    }
  end






}.join

end



def consumoTotal client,email
  id = @idCliente[email.to_sym]
  total=0
  puts "ID #{id}"
  CSV.foreach("DadosUsuarios/#{id}/consumo.csv") do |row|
    puts row[0]
    total+=Integer(row[0])
  end
  puts "Total > #{total}"
client.puts total
end


def getConsumo client,email
  puts email
  em = @idCliente[email.to_sym]
  puts "consumo"
  puts em
  arr = Array.new
  CSV.foreach("DadosUsuarios/#{em}/consumo.csv") do |row|
  arr << row
  end
  arr.each do |envio|
    client.puts envio
  end
  p arr
  puts "stop"
  client.puts "stop"
end


def leituraMetas
  CSV.foreach("metas.csv") do |row|
  unless row.nil?
    @metas[(row[0]).to_sym] = Integer(row[1])
  end
  end
end

def armazenaMetas client, valor,email
@metas[email] = valor
  File.open("metas.csv","a") do |line|
    line.puts "#{email.to_s},#{valor.to_s}"
  end
end

def getDados ip,client
  email = @clientes[ip]
  CSV.foreach("cadastrados.csv") do |row|
    if row[1] == email
      puts "enviando"
      row.each do |envio|
        client.puts envio
      end
      if @metas[email.to_sym]
        puts "hey"
        client.puts @metas[email.to_sym]
      else
      client.puts "não"
        end
    end
  end


end

def printaSensor(nome,data)
  time = Time.now.to_s
  time = DateTime.parse(time).strftime("%d-%m-%Y")
  datahora = Time.now.to_s
  datahora = DateTime.parse(datahora).strftime("%d/%m/%Y %H:%M:%S")
  @ident = @idCliente[nome.to_sym]
  FileUtils.mkdir_p "DadosUsuarios"
  FileUtils.mkdir_p "DadosUsuarios/#{@ident}"
  puts @ident
  File.open("../server/DadosUsuarios/#{@ident}/consumo.csv","a") do |line|
    line.puts "#{data.to_s},#{datahora.to_s} "
  end
  total=0
  CSV.foreach("DadosUsuarios/#{@ident}/consumo.csv") do |row|
    total+=Integer(row[0])
  end
puts "totalizando > #{total}"
  if total == Integer(@metas[nome.to_sym])
  message nome
  end

end

def armazena(name,em,pass,cp,ende,cas,cid,tel,ce)
  File.open("cadastrados.csv","a") do |line|
    line.puts "#{name}#{em}#{pass}#{cp}#{ende}#{cas}#{cid}#{tel}#{ce}"
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
        @idCliente[email.to_sym] = @@id
        idClientes email,@@id
        File.open("../server/DadosUsuarios/#{@@id}/consumo.csv","a")
        @@id+=1
        client.puts 0
        client.close
        return
      end

    end
    client.puts 1
  end

  def idClientes email,id
    File.open("../server/id.csv","a") do |line|
      line.puts "#{email},#{id}"
    end
  end

  def message email
    msg = "Subject: NOTIFICAÇÃO EMBASA\n\nCaro Cliente, essa é uma notificação porquê você atingiu o limite desejado!"
    smtp = Net::SMTP.new 'smtp.gmail.com', 587
    smtp.enable_starttls
    smtp.start('google.com', 'testandoemailfrancisco@gmail.com', 'Testeemail1', :login) do
      smtp.send_message(msg, 'testandoemailfrancisco@gmail.com', email)
    end
  end



end


Server.new(3001,"192.168.0.120")
