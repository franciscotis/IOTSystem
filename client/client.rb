require 'socket'
#require 'resolv-replace'
#require 'green_shoes'
#encoding: ISO-8859-1
class Client < Shoes::Widget
  attr_accessor :email, :nome, :cpf, :rg, :endereco, :cidade, :uf, :pais, :telefone, :celular, :cep, :servidor, :casa, :meta, :consumo, :rec, :total, :id

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
    @consumo = Hash.new
    @total = 0

  end

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

      @rec = Array.new
      while line = @servidor.gets.chomp
        if line == "stop"
          break
        end
        @rec << line
      end
    elsif tipo == "Total"
      @servidor.puts email
      @total = @servidor.gets
    end

  end

  def getip
    ip = IPSocket.getaddress(Socket.gethostname)
  end


end

Shoes.app title: "Meu App de Agua", :width => 500, :height => 600, :resizable => false do
  style Shoes::Para, font: "MS UI Gothic"
  style Shoes::Title, font: "MS UI Gothic"
  background "#ccff99"..."#99ffcc"
  ip = ""
  porta = ""
  CSV.foreach("endmaq.csv") do |row|
    ip = row[0]
    porta = row[1]
  end
  server = TCPSocket.open(ip,porta)
  @clickCons = false
  @client = Client.new server
  @cons = ""
  @client.enviaDados "Cliente"
  @client.recebeDados self

  title "Meu App de Água", :align=>'center', :margin_top => '5%'
  stack(:margin_left => '30%', :left => '-25%', :margin_top => '15%') do
    stack do
      para  strong "Meu Consumo"

      stack :margin_left => '3%', :width => "400px", :height => "70px", :scroll => true do
        @consumo = para "Seu consumo irá aparecer aqui!"
      end

      button "Mostrar/Esconder Consumo" do
        if @clickCons
          @consumo.text = "Seu consumo irá aparecer aqui!"
          @clickCons = false
        else

          @client.enviaDados "Consumo",self
          @client.rec.each do |consumo|

            if (@client.rec.index(consumo))%2==0
              @cons+= "Consumo - > #{consumo} m³ | "
            else
              @cons+="Data e Hora - > #{consumo}\n"
            end


          end
          @consumo.text = @cons
          @clickCons = true
        end

      end

    end
    @clickTot = false
    para  strong "Total Acumulado"
    @client.enviaDados "Total"
    @total = para "Seu consumo total irá aparecer aqui!"
    button "Verificar Total" do

    flow do
      if @clickTot
        @total.text = "Seu consumo total irá aparecer aqui!"
        @clickTot = false
      else
        @client.enviaDados "Total"
        @total.text = @client.total.gsub("\n","")+" m³"
        @clickTot = true
      end

    end

    end
    @client.enviaDados "Dados"
    para  strong "Minha meta de Consumo"
    flow do
      inscription "Coloque aqui a sua meta de consumo para quando voce consumir esse valor, voce ser notificado!"
      @goal = title strong("#{@client.meta}")
      para "m³"
      stack(:margin_left => '95%', :left => '-3%', :margin_top =>'10%') do

        button "+" do
          @client.meta += 1
          @goal.text = @client.meta
        end

        button "-" do
          if @client.meta > 0
            @client.meta -= 1
            @goal.text = @client.meta
          end
        end

      end
      button "Enviar" do
        @client.enviaDados "Meta"
      end
    end

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