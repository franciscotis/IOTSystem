require 'socket'
#require 'resolv-replace'
#require 'green_shoes'
#encoding: ISO-8859-1
class Client < Shoes::Widget
  attr_accessor :email, :nome, :cpf, :rg, :endereco, :cidade, :uf, :pais, :telefone, :celular, :cep, :servidor, :casa, :meta
  def initialize(servidor,nome=nil,email=nil,senha=nil,cpf=nil,endereco=nil,casa=nil,cidade=nil,telefone=nil,cep=nil)
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

  end

  def recebeDados
    @nome = @servidor.gets
    @email = @servidor.gets
    @senha = @servidor.gets
    @cpf = @servidor.gets
    @endereco = @servidor.gets
    @casa = @servidor.gets
    @cidade = @servidor.gets
    @telefone = @servidor.gets
    @cep = @servidor.gets
  end

  def enviaDados tipo
    @servidor.puts tipo
    if tipo == "Cliente"
    @servidor.puts getid
    elsif tipo == "Meta"
      @servidor.puts @meta
      @servidor.puts email
    elsif tipo == "Dados"
      @servidor.puts email
      end
  end

  def getid
    ip = UDPSocket.open {|s| s.connect("64.233.187.99", 1); s.addr.last}
    return ip
  end


end

Shoes.app title: "Meu App de Agua" do
  server = TCPSocket.open("localhost",3001)
  @client = Client.new server
  stack do
    para "Meu Consumo"
    flow do
    end
    para "Total Acumulado"
    flow do
      @client.enviaDados "Dados"
    end
    para "Minha meta de Consumo"
    flow do
      inscription "Coloque aqui a sua meta de consumo para quando voce consumir esse valor, voce ser notificado!"
      @goal = title strong("#{@client.meta}")
      para"m³"
      stack(:margin_left => '35%', :left => '-3%') do
        button "+" do
          @client.meta +=1
          @goal.text = @client.meta
        end

        button "-" do
          if @client.meta>0
            @client.meta -=1
            @goal.text = @client.meta
          end
        end
      end
      button "Enviar" do
        @client.enviaDados "Meta"
      end
    end

    para "Meus Dados"
    stack  do
      @client.enviaDados "Cliente"
      @client.recebeDados
     para "E-mail cadastrado"
     inscription @client.email
     para "Nome do cliente"
     inscription @client.nome
      para "CPF do cliente"
      inscription @client.cpf
      para "Endereco do cliente"
      inscription @client.endereco
      para "Cidade do cliente"
      inscription @client.cidade
      para "Telefone do cliente"
      inscription @client.telefone
      para "Cep do cliente"
      inscription @client.cep
      para "Numero da casa"
      inscription @client.casa
      end

  end
  alert @client.cpf

end