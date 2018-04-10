require 'socket'
#require 'green_shoes'
#encoding: ISO-8859-1
class Client < Shoes::Widget
  attr_accessor :email, :nome, :cpf, :rg, :endereco, :cidade, :uf, :pais, :telefone, :celular, :cep
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
=begin
    def conexao(hostname, port)
      server = TCPSocket.open(hostname,port)
      server.puts 4
      puts 'Valor enviado, esperando o seu dobro'
      resp = server.recvfrom(10_000)
      puts resp[0]
      server.close
    end
=end

  def recebeDados
    @response = Thread.new do
      arr = Array.new
       while msg = @server.gets
         arr << msg
       end
    end
    @nome=arr[0],@email=arr[1],@senha=arr[2],@cpf=arr[3],@endereco=arr[4],@cidade=arr[5],@telefone=arr[6],@cep=arr[7],@casa=arr[8]
  end

  def enviaDados
    @ip = (Socket.ip_address_list)[1].ip_address
    @dados = ["Cliente",@ip]
    @server.puts(@dados)
    recebeDados
    @server.close
  end


end
Shoes.app title: "Meu App de Agua" do
  server = TCPSocket.open("192.168.137.155",3001)
  @client = Client.new server
  @client.enviaDados
  stack do
    para "Meu Consumo"
    flow do
      #Recebe o seu consumo de água - data e horario especifico do consumo
      #Implementar. Necessita de Sensor + Servidor
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