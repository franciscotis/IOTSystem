require 'socket'
require 'csv'
require 'fileutils'
require 'resolv-replace'
require 'net/smtp'
# encoding: UTF-8
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
  @envioEmail = Hash.new #Hash que armazena se já foi enviado um email para o cliente
  leituraMetas
  leituraEmail
  @udp = UDPSocket.new
  @udp.bind(ip,3002)
  run
end

def run
loop{

  Thread.start() do
    loop {
      data,client = @udp.recvfrom(1024)
      Thread.new(client) do |clientAddress|
        dados = data.split(',')
        p dados
        printaSensor(dados[0].chomp,dados[1].chomp,dados[2].chomp)
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
    elsif tipoOperacao == :DadosAdmin
      enviaDadosAdmin client
    elsif tipoOperacao == :PessoasZona
      pessoasZona client
    elsif tipoOperacao == :Fatura
      fatura client


    end
    }
  end






}.join

end



def consumoTotal client,email
  id = -1
  id = getidCliente email
  total=0
  puts "ID #{id}"
  CSV.foreach("DadosUsuarios/#{id}/consumo.csv") do |row|
    puts row[0]
    total+=Integer(row[0])
  end
  puts "Total > #{total}"
client.puts total
end

  def getidCliente email
    id = -1
    CSV.foreach("cadastrados.csv") do |row|
      if row[1] == email
        id = Integer(row[9])
      end
    end
    return id
  end


def getConsumo client,email
  puts email
  em = getidCliente email
  puts "consumo"
  puts em
  arr = Array.new
  CSV.foreach("DadosUsuarios/#{em}/consumo.csv") do |row|
    if row[2] == "true "
  arr << row[0]
    arr << row[1]
      end
  end
  arr.each do |envio|
    client.puts envio
  end
  p arr
  puts "stop"
  client.puts "stop"
end


def leituraMetas
  File.open("metas.csv","a")
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
        p "n"
      client.puts -1
      end

    end

  end


end

def printaSensor(nome,data,agua)
  agua.sub!(" ","")
  time = Time.now.to_s
  time = DateTime.parse(time).strftime("%d-%m-%Y")
  datahora = Time.now.to_s
  datahora = DateTime.parse(datahora).strftime("%d/%m/%Y %H:%M:%S")
  @ident = getidCliente nome
  File.open("../server/DadosUsuarios/#{@ident}/consumo.csv","a") do |line|
    line.puts "#{data.to_s},#{datahora.to_s},#{agua.to_s} "
  end
  total=0
  CSV.foreach("DadosUsuarios/#{@ident}/consumo.csv") do |row|
    if agua=="true"
    total+=Integer(row[0]) end
  end
  if total == Integer(@metas[nome.to_sym]) and !@envioEmail[nome.to_sym]
    @envioEmail[nome.to_sym] = true
    File.open("envioEmail.csv", "a") do |line|
      line.puts "#{nome},true"
    end
  message nome
  end




    end

  def leituraEmail
    CSV.foreach("envioEmail.csv") do |row|
      @envioEmail[row[0].to_sym] = row[1].to_boolean
    end
  end

def armazena(name,em,pass,cp,ende,cas,cid,tel,ce)
  File.open("cadastrados.csv","a")
  @id = 0
  CSV.foreach("cadastrados.csv") do |row|
    if row[1].chomp == em.chomp
      return
    else
      @id = Integer(row[9])
    end
  end
  if @id>=0 then @id+=1 end
  FileUtils.mkdir_p "DadosUsuarios"
  FileUtils.mkdir_p "DadosUsuarios/#{@id}"
  File.open("../server/DadosUsuarios/#{@id}/consumo.csv","a")
  File.open("cadastrados.csv","a") do |line|
    line.puts "#{name}#{em}#{pass}#{cp}#{ende}#{cas}#{cid}#{tel}#{ce}#{@id}"
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
    puts "entrei"
    puts email
    puts senha
    CSV.foreach("cadastrados.csv") do |row|
      if (row[1].chomp == email) && (row[2].chomp == senha)
        @clientes[ip] = email
        id = getidCliente email
        File.open("../server/DadosUsuarios/#{id}/consumo.csv","a")
        client.puts 0
        client.close
        return
      end

    end
    client.puts 1
  end

  def message email
    msg = "Subject: NOTIFICAÇÃO EMBASA\n\nCaro Cliente, essa é uma notificação porquê você atingiu o limite desejado!"
    smtp = Net::SMTP.new 'smtp.gmail.com', 587
    smtp.enable_starttls
    smtp.start('google.com', 'testandoemailfrancisco@gmail.com', 'Testeemail1', :login) do
      smtp.send_message(msg, 'testandoemailfrancisco@gmail.com', email)
    end
  end

  def enviaDadosAdmin client
    puts "entre"
  CSV.foreach("cadastrados.csv") do |row|
    tot = 0
    puts row[9]
    CSV.foreach("DadosUsuarios/#{row[9]}/consumo.csv") do |cons|
      p cons
      if cons[2] == "true "
      tot+=Integer(cons[0]) end
    end
    client.puts  "NOME - #{row[0]} | EMAIL - #{row[1]} | CPF - #{row[3]} | ENDEREÇO - #{row[4]} | NUMERO DA CASA - #{row[5]} | CIDADE - #{row[6]} | TELEFONE - #{row[7]} | CEP - #{row[8]} | ID - #{row[9]} | CONSUMO TOTAL - #{tot} m³\n\n"
  end
    client.puts "stop"
  end

  def pessoasZona client
    @Zonas = Hash.new(0)
    CSV.foreach("cadastrados.csv") do |row|
      zona = row[5].to_s.split('')
      @Zonas[zona[0].to_sym] +=1
    end
    @Zonas.each_key do |chave|
      pessoas = @Zonas[chave.to_sym]
      client.puts "ZONA - >  #{chave} PESSOAS - > #{pessoas}"
    end
    client.puts "stop"
    zon = Integer(client.gets)
    acumulado = 0
    falta = 0
    CSV.foreach("cadastrados.csv") do |row|
      zn = row[5].to_s.split('')
      if zon == Integer(zn[0])
        CSV.foreach("DadosUsuarios/#{row[9]}/consumo.csv") do |cons|
          if cons[2] == "true "
          acumulado+=Integer(cons[0])
          else
            falta+=1
            end
        end
        if acumulado > 30
          client.puts "Cliente de id #{row[9]} tem acumulado #{acumulado} m³. Existe um provável vazamento de água"
        elsif  falta > 10 and acumulado < 10
          client.puts "Cliente de id #{row[9]} tem acumulado #{acumulado} m³. Existe uma provável escassez de água"
        else
          client.puts "Cliente de id #{row[9]} tem acumulado #{acumulado} m³. Situação considerada normal"
         end
      end
    end
    client.puts "stop"
  end

  def valorConta total
    if total.between?(1,6)
      return 27.50
    elsif total.between?(7,10)
      return ((27.50)+(1.09*total))
    elsif total.between?(11,15)
      return ((27.50)+(7.68*total))
    elsif total.between?(16,20)
      return ((27.50)+(7.68*total))
    elsif total.between?(21,25)
      return ((27.50)+(9.24*total))
    elsif total.between?(26,30)
      return ((27.50)+(10.31*total))
    elsif total.between?(31,40)
      return ((27.50)+(11.34*total))
    elsif total.between?(41,50)
      return ((27.50)+(12.43*total))
    else
      return ((27.50)+(14.95*total))
    end
  end


  def fatura client
    id = ""
    email = ""
    total = 0
    CSV.foreach("cadastrados.csv") do |row|
      email = row[1]
      puts File.zero?("DadosUsuarios/#{row[9]}/consumo.csv")
      unless File.zero?("DadosUsuarios/#{row[9]}/consumo.csv") #Verifica se existe alguma coisa dentro do arquivo
        puts "1"
        CSV.foreach("DadosUsuarios/#{row[9]}/consumo.csv") do |cons|
        if cons[2] == "true "
        total+=Integer(cons[0])
        end
        end

        File.open("DadosUsuarios/#{row[9]}/consumo.csv","w+")
        File.open("metas.csv","w+")
        File.open("envioEmail.csv","w+")
      end
    if total!=0
    cont = valorConta total
    else
      cont = 0
    end
      msg = "Subject: CONTA DE ÁGUA\n\nOlá, sua conta de água chegou! Pague antes do vencimento!\n Seu consumo total = > #{total} m³\n Você irá pagar #{cont} reais"
      smtp = Net::SMTP.new 'smtp.gmail.com', 587
      smtp.enable_starttls
      smtp.start('google.com', 'testandoemailfrancisco@gmail.com', 'Testeemail1', :login) do
        smtp.send_message(msg, 'testandoemailfrancisco@gmail.com', email)
      end
    end
    client.puts "Faturas geradas com sucesso!"
    end

  end


Server.new(3001,"192.168.0.120")
