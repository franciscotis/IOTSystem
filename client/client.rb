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
#Requerimentos
require 'socket'
#require 'resolv-replace'
#require 'green_shoes'
#encoding: ISO-8859-1
# Classe do cliente(Consumidor)
class Client < Shoes::Widget
  attr_accessor :email, :nome, :cpf, :rg, :endereco, :cidade, :uf, :pais, :telefone, :celular, :cep, :servidor, :casa, :meta, :consumo, :rec, :total, :id
#construtor
  def initialize(servidor, nome = nil, email = nil, senha = nil, cpf = nil, endereco = nil, casa = nil, cidade = nil, telefone = nil, cep = nil, id=nil)
    @id = id
    @email = email
    @nome = nome
    @cpf = cpf
    @endereco = endereco
    @cidade = cidade
    @telefone = telefone
    @cep = cep
    @casa = casa
    @servidor = servidor
    @meta = 0
    @consumo = Hash.new #Hash que armazena o seu consumo
    @total = 0

  end
#Método que recebe os dados do servidor e os atribui em seus atributos
  def recebeDados msg
    @nome = @servidor.gets
    @email = @servidor.gets
    @senha = @servidor.gets
    @cpf = @servidor.gets
    @endereco = @servidor.gets
    @casa = @servidor.gets
    @cidade = @servidor.gets
    @telefone = @servidor.gets
    @cep = @servidor.gets
    @id = Integer(@servidor.gets)
    m = Integer(@servidor.gets)
    if m>=0
      @meta = m
    end

  end
#Método que envia os dados para o servidor a depender do seu tip
  def enviaDados tipo, data = nil
    @servidor.puts tipo
    if tipo == "Cliente"
      @servidor.puts getip
    elsif tipo == "Meta"
      @servidor.puts @meta
      @servidor.puts email
    elsif tipo == "Dados"
      @servidor.puts email
    elsif tipo == "Consumo"
      @servidor.puts email
      #Envia o seu email
      @rec = Array.new
      while line = @servidor.gets.chomp
        if line == "stop" #Enquanto o servidor não envia "stop" o conteudo enviado pelo servidor continuará sendo armazenado no array
          break
        end
        @rec << line
      end
    elsif tipo == "Total"
      @servidor.puts email
      @total = @servidor.gets
    end

  end

  def getip #Método que pega o endereço ip da máquina
    ip = IPSocket.getaddress(Socket.gethostname)
  end


end
#Interface gráfica
Shoes.app title: "Meu App de Agua", :width => 500, :height => 600, :resizable => false do
  style Shoes::Para, font: "MS UI Gothic"
  style Shoes::Title, font: "MS UI Gothic"
  background "#ccff99"..."#99ffcc"
  ip = ""
  porta = ""
  CSV.foreach("endmaq.csv") do |row| #Método que pega o endereço ip e a porta do servidor
    ip = row[0]
    porta = row[1]
  end
  server = TCPSocket.open(ip,porta) #Cria uma conexão TCP com o servidor
  @clickCons = false  #boolean para ver se o consumidor já quis saber o seu consumo
  @client = Client.new server #Criação de uma nova instância de cliente
  @cons = "" #Mensagem a ser exibida para o cliente
  @client.enviaDados "Cliente" #Envia o tipo de operação para o servidor
  @client.recebeDados self #Recebe os dados do servidor

  title "Meu App de Água", :align=>'center', :margin_top => '5%' #Título
  #Conteudo da ágina
  stack(:margin_left => '30%', :left => '-25%', :margin_top => '15%') do
    stack do
      para  strong "Meu Consumo"

      stack :margin_left => '3%', :width => "400px", :height => "70px", :scroll => true do
        @consumo = para "Seu consumo irá aparecer aqui!" #Parágrafo a ser mostrado para o usuário
      end

      button "Mostrar/Esconder Consumo" do #Botão
        if @clickCons #Se o usuário clicou no botão
          @consumo.text = "Seu consumo irá aparecer aqui!" #Mostra a mensagem
          @clickCons = false
        else
      #Caso o contrário
          @client.enviaDados "Consumo",self #Envia os dados para o servidor
          @client.rec.each do |consumo| #Para cada mensagem recebida faz a verificação = >

            if (@client.rec.index(consumo))%2==0
              @cons+= "Consumo - > #{consumo} m³ | "
            else
              @cons+="Data e Hora - > #{consumo}\n"
            end
            #O servidor envia os dados e o cliente os armazena em um array, os índices pares estão contidos os consumos
            # e os índices ímpares estão contidos a data e a hora do consumo


          end
          @consumo.text = @cons #Mostra o texto
          @clickCons = true
        end

      end

    end
    @clickTot = false
    para  strong "Total Acumulado"
    @client.enviaDados "Total"
    @total = para "Seu consumo total irá aparecer aqui!"
    button "Verificar Total" do #Verifica o total acumulado

    flow do
      if @clickTot
        @total.text = "Seu consumo total irá aparecer aqui!"
        @clickTot = false
      else
        @client.enviaDados "Total"
        @total.text = @client.total.gsub("\n","")+" m³" #Mostra o total para o cliente, nota, o gsub("\n","") substitui a quebra de linha por um espaço em branco
        @clickTot = true
      end

    end

    end
    @client.enviaDados "Dados" #envia o tipo de operação para o servidor
    para  strong "Minha meta de Consumo"
    flow do
      #Meta de consumo
      inscription "Coloque aqui a sua meta de consumo para quando voce consumir esse valor, voce ser notificado!"
      @goal = title strong("#{@client.meta}")
      para "m³"
      stack(:margin_left => '95%', :left => '-3%', :margin_top =>'10%') do
    #Botões para aumentar e/ou diminuir
        button "+" do
          @client.meta += 1
          @goal.text = @client.meta
        end

        button "-" do
          if @client.meta > 0 #Só diminui se a meta atual for maior que zero, para não ter meta negativa
            @client.meta -= 1
            @goal.text = @client.meta
          end
        end

      end
      button "Enviar" do #Envia a meta para o servidor
        @client.enviaDados "Meta"
      end
    end
  #Mostra os dados do usuário
    para strong "Meus Dados"
    flow :margin=> 10 do
    stack :width => "200px", :height => "90px", :scroll => true do
      para strong "E-mail cadastrado"
      inscription @client.email.gsub("\n","")
      para strong "Nome do cliente"
      inscription @client.nome.gsub("\n","")
      para strong "CPF do cliente"
      inscription @client.cpf.gsub("\n","")
      para strong "Endereco do cliente"
      inscription @client.endereco.gsub("\n","")
      para strong "Cidade do cliente"
      inscription @client.cidade.gsub("\n","")
      para strong "Telefone do cliente"
      inscription @client.telefone.gsub("\n","")
      para strong "Cep do cliente"
      inscription @client.cep.gsub("\n","")
      para strong "Numero da casa"
      inscription @client.casa.gsub("\n","")
    end

end
  end

end