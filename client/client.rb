require 'socket'
require 'resolv-replace'
#require 'green_shoes'
#encoding: ISO-8859-1
class Client < Shoes::Widget
  attr_accessor :email, :nome, :cpf, :rg, :endereco, :cidade, :uf, :pais, :telefone, :celular, :cep, :servidor
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

  end

  def recebeDados
    @nome = server.gets
    @email = server.gets
    @senha = server.gets
    @cpf = server.gets
    @endereco = server.gets
    @casa = server.gets
    @cidade = server.gets
    @telefone = server.gets
    @cep = server.gets
  end

  def enviaDados tipo
    @server.puts tipo
    @server.puts getid.to_s
  end

  def getid
    ip = Socket.ip_address_list.detect{|intf| intf.ipv4_private?}
    ip.ip_address
  end


end

Shoes.app title: "Meu App de Agua" do
  server = TCPSocket.open("localhost",3001)
  #@client = Client.new server
  #@client.enviaDados "Cliente"
  stack do
    para "Meu Consumo"
    flow do
    end
    para "Total Acumulado"
    flow do
      # Recebe o seu total de água consumido
      #Implementar. Necessita de Sensor + Servidor
    end
    para "Minha meta de Consumo"
    flow do
      inscription "Coloque aqui a sua meta de consumo para quando voce consumir esse valor, voce ser notificado!"
      @meta = edit_line
      button "Enviar" do
        #Envia os dados para o servidor
      end
    end
    para "Meus Dados"
    flow do
     # inscription "E-mail cadastrado #{email}\nNome do cliente #{nome}\nCPF do cliente #{cpf}\nEndereco do cliente #{endereco}\nCidade do cliente #{cidade}\nTelefone do cliente #{telefone}\nCep do cliente #{cep}\nNumero da casa #{casa}"
    end

  end

end