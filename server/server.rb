=begin
Autor: Francisco Tito Silva Satos Pereira - 16111203
Componente Curricular: MI - Conectividade e Concorrência
Concluido em: 17/04/2018
Declaro que este código foi elaborado por mim de forma individual e não contém nenhum
trecho de código de outro colega ou de outro autor, tais como provindos de livros e
apostilas, e páginas ou documentos eletrônicos da Internet. Qualquer trecho de código
de outra autoria que não a minha está destacado com uma citação para o autor e a fonte
do código, e estou ciente que estes trechos não serão considerados para fins de avaliação.
=end
#requerimentos
require 'socket'
require 'csv'
require 'fileutils'
require 'resolv-replace'
require 'net/smtp' #Para o envio de emails
# encoding: UTF-8
# #Classe servidor
class Server
  attr_accessor :ip,:porta #Getters e Setters
  def initialize(porta,ip) #Construtor
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
    @udp = UDPSocket.new #Abre-se uma nova conexão UDP
    @udp.bind(ip,3002)
    run
  end

  def run
    #Método que fica em um loop esperando uma conexão UDP e/ou TCP.

    loop{ #loop infinito

      Thread.start() do #Cria-se uma nova thread
        loop { #loop
          data,client = @udp.recvfrom(1024) #Recebe os dados da conexão UDP
          Thread.new(client) do |clientAddress| #Cria um thread para cada cliente
            dados = data.split(',') #recebe os dados
            printaSensor(dados[0].chomp,dados[1].chomp,dados[2].chomp) #Chama o método printaSensor que irá armazenar os dados do sensor
          end
        }
      end

      Thread.start(@servidor.accept) do |client| #Thread que irá esperar uma conexão TCP
        loop { #loop
          tipoOperacao =client.gets.chomp.to_sym #Recebe o tipo de operação
          p tipoOperacao
          if tipoOperacao == :Cadastro #Se o tipo de operação for cadastro. Nota, os : significa que a variável é um symbol. Ou seja, uma variável que é imutável e mais segura
            cadastro client #Chama o método cadastro
          elsif tipoOperacao == :Login #Caso o tipo de operação for Login. Recebe os dados e os armazena os dados
            ip = client.gets.to_sym  #Transforma o que recebe em um symbol,
            email = client.gets.chomp # O chomp significa que irá tirar o \n
            senha = client.gets.chomp
            login client,ip,email,senha  # Chama o método login
          elsif tipoOperacao == :Cliente #Caso o tipo de operação for cliente
            ip = client.gets.to_sym #Recebe os dados
            getDados ip,client #Chama o método getDados
          elsif tipoOperacao == :Meta #Caso o tipo de operação for Meta. Recebe os dados
            valor = client.gets.chomp
            email = client.gets.chomp.to_sym
            armazenaMetas client, valor, email #Chama o método armazenaMetas
          elsif tipoOperacao == :Consumo #Caso o tipo de operação for consumo. Recebe os dados
            email = client.gets.chomp
            getConsumo client,email #Chama o método getConsumo
          elsif tipoOperacao == :Total #Caso o tipo de operação for Total
            email = client.gets.chomp
            consumoTotal client,email #Chama o método consumoTotal
          elsif tipoOperacao == :Sensor #Caso o tipo de operação for sensor
            ip = client.gets.to_sym
            client.puts @clientes[ip] #Envia o email do cliente que está armazenado na hash @clientes e tem como key ip
          elsif tipoOperacao == :Sair #Caso a operação seja sair
            client.close #Fecha a conexão com o cliente
          elsif tipoOperacao == :DadosAdmin #Caso o tipo de operação for DadosAdmin
            enviaDadosAdmin client #Chama o método enviaDadosAdmin
          elsif tipoOperacao == :PessoasZona #Caso o tipo de operação for PessoasZona
            pessoasZona client #Chama o método pessoasZona
          elsif tipoOperacao == :Fatura #Caso o tipo de operação for Fatura
            fatura client #Chama o método fatura

          end
        }
      end






    }.join

  end



  def consumoTotal client,email #Método que manda para o cliente o seu consumo total
    id = -1
    id = getidCliente email #pego o id do cliente a partir do email
    total=0
    CSV.foreach("DadosUsuarios/#{id}/consumo.csv") do |row|
      total+=Integer(row[0]) #Calcula-se o consumo total que está armazenado na pasta do cliente. Dados enviados pelo sensor
    end
    client.puts total #Manda para o cliente o seu total
  end

  def getidCliente email #Método que pega o id do cliente a partir do seu email
    id = -1
    CSV.foreach("cadastrados.csv") do |row| #Abre o arquivo csv contendo todos os cadastrados
      if row[1] == email
        id = Integer(row[9])
      end
    end
    return id #Retorna o id a partir do email
  end


  def getConsumo client,email #Método que envia para o cliente o seu consumo detalhado
    em = getidCliente email #pega o id do cliente a partir do seu email
    arr = Array.new
    CSV.foreach("DadosUsuarios/#{em}/consumo.csv") do |row| #Pega todos os dados de consumo do cliente
      if row[2] == "true " #Caso tenha água, armazena no array
        arr << row[0]
        arr << row[1]
      end
    end
    arr.each do |envio| #Envia os dados para o cliente
      client.puts envio
    end
    client.puts "stop"
  end


  def leituraMetas #Método que faz a leitura de todos os métodos
    File.open("metas.csv","a") #Abre o arquivo metas.csv, caso não exista
    CSV.foreach("metas.csv") do |row| #Abre o arquivo metas.csv e faz a leitura
      unless row.nil? #O unless é um if ao contrário. Ou seja, só entra no bloco se a condição for falsa. Então, se tiver alguma coisa dentro d arquivo
        @metas[(row[0]).to_sym] = Integer(row[1])  #Armazena a meta do usuário na Hash metas. Que tem como key o seu email
      end
    end
  end

  def armazenaMetas client, valor,email #Método que armazena as metas do cliente
    @metas[email] = valor #Armazena os valores na hash
    File.open("metas.csv","a") do |line| #Abre o arquivo metas.csv
      line.puts "#{email.to_s},#{valor.to_s}" #Insere lá os dados
    end
  end

  def getDados ip,client #Método que pega todos os dados do cliente
    email = @clientes[ip] #Pega o email do cliente a partir do seu ip
    CSV.foreach("cadastrados.csv") do |row| #Abre o arquivo de cadastrados
      if row[1] == email
        #Envia os dados para o cliente
        row.each do |envio|
          client.puts envio
        end

        if @metas[email.to_sym] #Caso o usuário tenha alguma meta armazenada
          client.puts @metas[email.to_sym] #Envia essa meta para ele
        else
          client.puts -1 #Caso contrário, envia -1, que será interpretado como 0
        end

      end

    end


  end

  def printaSensor(nome,data,agua) #Método que armazena os dados do sensor
    agua.sub!(" ","") #Substitui o espaço por ""
    time = Time.now.to_s #Pega a hora de agora
    time = DateTime.parse(time).strftime("%d-%m-%Y") #Formata a hora
    datahora = Time.now.to_s #pega a hora de agora
    datahora = DateTime.parse(datahora).strftime("%d/%m/%Y %H:%M:%S") #Formata a hora
    @ident = getidCliente nome #Pega o id do cliente a partir do seu email
    File.open("../server/DadosUsuarios/#{@ident}/consumo.csv","a") do |line| #Abre o arquivo onde será armazenado os dados do sensor
      line.puts "#{data.to_s},#{datahora.to_s},#{agua.to_s} " #Insere no arquivo
    end
    total=0 #O consumo total do usuário = 0
    CSV.foreach("DadosUsuarios/#{@ident}/consumo.csv") do |row| #Abre o arquivo
      if agua=="true" #Se tiver consumo de água
        total+=Integer(row[0]) end #Soma o total de água com o consumo da hora
    end
    if total == Integer(@metas[nome.to_sym]) and !@envioEmail[nome.to_sym] #Caso o usuário tenha definido uma meta e o sistema não tiver o enviado um email
      @envioEmail[nome.to_sym] = true #Diz que já foi enviado email, para evitar emails duplicados
      File.open("envioEmail.csv", "a") do |line| #Abre o arquivo
        line.puts "#{nome},true" #Insere que já foi enviado o email
      end
      message nome #Envia o email
    end




  end

  def leituraEmail #Leitura de todos os emails enviados
    CSV.foreach("envioEmail.csv") do |row|
      @envioEmail[row[0].to_sym] = row[1] #armazena na hash de emails enviados, para cada email armazenado no arquivo csv
    end
  end

  def armazena(name,em,pass,cp,ende,cas,cid,tel,ce) #Armazena os cadastrados no arquivo csv
    File.open("cadastrados.csv","a")
    @id = 0
    CSV.foreach("cadastrados.csv") do |row|
      if row[1].chomp == em.chomp #Se já tiver cadastrado, não cadastra novamente
        return
      else
        @id = Integer(row[9]) #Pega o último id
      end
    end
    if @id>=0 then @id+=1 end #Caso o ultimo id seja maior ou igual a 0, soma mais 1
    FileUtils.mkdir_p "DadosUsuarios" #Cria o diretorio para armazenar os dados do sensor
    FileUtils.mkdir_p "DadosUsuarios/#{@id}"
    File.open("../server/DadosUsuarios/#{@id}/consumo.csv","a")
    File.open("cadastrados.csv","a") do |line| #Armazena os dados do usuário no arquivo csv
      line.puts "#{name}#{em}#{pass}#{cp}#{ende}#{cas}#{cid}#{tel}#{ce}#{@id}"
    end

  end


  def listen_user_messages(client) #Método que escuta as mensagens do usuário e os armazena em um array
    arr = Array.new
    while line = client.gets
      arr << line
    end
    return arr
  end


  def cadastro(client) #Método que realiza cadastro do cliente
    arr = listen_user_messages client #Escuta as mensagens do usuário
    arr.each do |ar|
      ar.gsub!("\n",",")  #Tira a quebra de linha
    end
    armazena(arr[0].to_s,arr[1].to_s,arr[2].to_s,arr[3].to_s,arr[4].to_s,arr[5].to_s,arr[6].to_s,arr[7].to_s,arr[8].to_s) #Chama o método armazena
  end

  def login(client,ip,email,senha) #Método que realiza o login do usuário
    CSV.foreach("cadastrados.csv") do |row| #Verifica todos os cadastrados
      if (row[1].chomp == email) && (row[2].chomp == senha) #Verifica se o email e a senha estão certos
        @clientes[ip] = email #Armazena o email do cliente em um Hash que tem como key o seu endereço ip
        id = getidCliente email #Pega o id do cliente a partir do seu email
        File.open("../server/DadosUsuarios/#{id}/consumo.csv","a") #Abre sua página de consumo
        client.puts 0 #Envia 0 dizendo que tudo deu certo
        return
      end

    end
    client.puts 1 #Envia 1 se não deu certo
  end

  def message email #Método que envia email para o usuário
    msg = "Subject: NOTIFICAÇÃO EMBASA\n\nCaro Cliente, essa é uma notificação porquê você atingiu o limite desejado!" #Assunto, título e corpo da mensagem
    smtp = Net::SMTP.new 'smtp.gmail.com', 587 #Envia para o gmail com o endereço e a porta do gmail
    smtp.enable_starttls
    smtp.start('google.com', 'testandoemailfrancisco@gmail.com', 'Testeemail1', :login) do #abre conexão
      smtp.send_message(msg, 'testandoemailfrancisco@gmail.com', email) #envia email
    end
  end

  def enviaDadosAdmin client #Envia os dados para o administrador
    CSV.foreach("cadastrados.csv") do |row| #Abre todos os cadastrados
      tot = 0
      CSV.foreach("DadosUsuarios/#{row[9]}/consumo.csv") do |cons| #Abre todos os consumos do usuário

        if cons[2] == "true " #Caso haja água
          tot+=Integer(cons[0]) end #Soma o total
      end
      #Envia para o usuário os dados do usuário
      client.puts  "NOME - #{row[0]} | EMAIL - #{row[1]} | CPF - #{row[3]} | ENDEREÇO - #{row[4]} | NUMERO DA CASA - #{row[5]} | CIDADE - #{row[6]} | TELEFONE - #{row[7]} | CEP - #{row[8]} | ID - #{row[9]} | CONSUMO TOTAL - #{tot} m³\n\n"
    end
    client.puts "stop" #Envia a condição de parada
  end

  def pessoasZona client #Método que verifica todas as zonas existentes, sendo que a condição de zona é pegar o número da casa do usuário e o primeiro número é referente a zona. Ex : Casa 123 - >  Zona 1 | Casa 222 - > Zona 2
    #Cria uma hash com as zonas, onde a key é o número da zona e o value é quantas pessoas tem na zona
    @Zonas = Hash.new(0)
    CSV.foreach("cadastrados.csv") do |row| #Abre o arquivo com os cadastrados
      zona = row[5].to_s.split('') #Pega o numero inteiro e o separa para fazer a comparação
      @Zonas[zona[0].to_sym] +=1 #Soma a quantidade de pessoas na zona
    end
    @Zonas.each_key do |chave|
      pessoas = @Zonas[chave.to_sym] #Pega a quantidade de pessoas na zona
      client.puts "ZONA - >  #{chave} PESSOAS - > #{pessoas}" #Envia para o administrador a mensagem
    end
    client.puts "stop" #Envia a condição de parada
    # O administrador irá escolher qual zona ele deseja ver os dados
    zon = Integer(client.gets) #Recebe a escolha
    acumulado = 0
    falta = 0
    CSV.foreach("cadastrados.csv") do |row| #Abre o arquivo cadastrados.csv
      zn = row[5].to_s.split('') #Verifica a zona do usuário
      if zon == Integer(zn[0]) #Se a zona do usuário for a zona que o administrador deseja saber
        CSV.foreach("DadosUsuarios/#{row[9]}/consumo.csv") do |cons| #Verifica o consumo do usuário
          if cons[2] == "true " #Se tem água
            acumulado+=Integer(cons[0]) #Acumula o seu total
          else
            falta+=1 #Caso não tenha água, somo mais 1 à falta d'água
          end
        end
        if acumulado > 30 #Caso tenha mais de 30 m³ acumulados  envia a mensagem para o administrador
          client.puts "Cliente de id #{row[9]} tem acumulado #{acumulado} m³. Existe um provável vazamento de água"
        elsif  falta > 10 and acumulado < 10 #Caso tenha mais de 10 faltas d'água e menos de 10m³ acumulados envia a mensagem
          client.puts "Cliente de id #{row[9]} tem acumulado #{acumulado} m³. Existe uma provável escassez de água"
        else #Caso contrário envia a seguinte mensagem
          client.puts "Cliente de id #{row[9]} tem acumulado #{acumulado} m³. Situação considerada normal"
        end
      end
    end
    client.puts "stop" #Envia a condição de parada
  end

  def valorConta total #Método que calcula o consumo total do usuário com base nos dados da Embasa
    #Retorna os valores
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


  def fatura client #Método que gera a fatura
    id = ""
    email = ""
    total = 0
    CSV.foreach("cadastrados.csv") do |row| #Abre os cadastrados
      email = row[1]
      unless File.zero?("DadosUsuarios/#{row[9]}/consumo.csv") #Verifica se existe alguma coisa dentro do arquivo
        CSV.foreach("DadosUsuarios/#{row[9]}/consumo.csv") do |cons| #abre a sua pasta de consumo
          if cons[2] == "true " #Caso tenha água
            total+=Integer(cons[0]) #soma o eu total
          end
        end
        #Como irá enviar a sua fatura, os dados do usuário de consumo, meta e email enviado por causa de meta será apagado, significa que é um novo mês
        File.open("DadosUsuarios/#{row[9]}/consumo.csv","w+")
        File.open("metas.csv","w+")
        File.open("envioEmail.csv","w+")
      end
      if total!=0 #Se total for diferente de 0 chama o método que calcula a conta
        cont = valorConta total
      else #Caso contrario
        cont = 0
      end
      #Envia o email com a fatura para o usuário
      msg = "Subject: CONTA DE ÁGUA\n\nOlá, sua conta de água chegou! Pague antes do vencimento!\n Seu consumo total = > #{total} m³\n Você irá pagar #{cont} reais"
      smtp = Net::SMTP.new 'smtp.gmail.com', 587
      smtp.enable_starttls
      smtp.start('google.com', 'testandoemailfrancisco@gmail.com', 'Testeemail1', :login) do
        smtp.send_message(msg, 'testandoemailfrancisco@gmail.com', email)
      end
    end
    #Envia mensagem de sucesso!
    client.puts "Faturas geradas com sucesso!"
  end

end


Server.new(3001,"192.168.43.162")
