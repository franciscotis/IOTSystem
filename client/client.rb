require 'socket'
require 'green_shoes'
#encoding: ISO-8859-1
class Client < Shoes::Widget
  attr_reader :email, :nome, :cpf, :rg, :endereco, :cidade, :uf, :pais, :telefone, :celular, :cep
  def initialize(nome,email,senha,cpf,endereco,casa,cidade,telefone,cep)
    @email = email
    @nome = nome
    @cpf = cpf
    @endereco = endereco
    @cidade = cidade
    @telefone = telefone
    @cep = cep
    @casa = casa

  end

    def conexao(hostname, port)
      server = TCPSocket.open(hostname,port)
      server.puts 4
      puts 'Valor enviado, esperando o seu dobro'
      resp = server.recvfrom(10_000)
      puts resp[0]
      server.close
    end


end

Shoes.app title: "Meu App de Agua" do
  #criar def para capturar dados do cliente
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
      inscription "E-mail cadastrado #{email}\nNome do cliente #{nome}\nCPF do cliente #{cpf}\nEndereco do cliente #{endereco}\nCidade do cliente #{cidade}\nTelefone do cliente #{telefone}\nCep do cliente #{cep}\nNumero da casa #{casa}"
    end

  end

end