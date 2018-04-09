require 'socket'
class Cadastro
  attr_accessor :dados
  def initialize(servidor,name,em,pass,cp,ende,cas,cid,tel,ce)
    @server = servidor
    @request = nil
    @response = nil
    @dados = [name,em,pass,cp,ende,cas,cid,tel,ce]

  end

  def enviaDados
  @request = Thread.new do
    loop{
    @server.puts(@dados)
    }
  end
  end



end

Shoes.app title: "Cadastro"  do

  stack do
    para "Nome"
    flow do
      @nome = edit_line
    end
    para "Email"
    flow do
      @email = edit_line
    end
    para "Senha"
    flow do
      @senha = edit_line
    end
    para "CPF"
    flow do
      @cpf = edit_line
    end
    para "Endereco"
    flow do
      @ender = edit_line
    end
    para "Casa"
    flow do
      @casa = edit_line
    end
    para "Cidade"
    flow do
      @cidade = edit_line
    end
    para "Telefone"
    flow do
      @telefone = edit_line
    end
    para "CEP"
    flow do
      @cep = edit_line
    end
  end
  button "Cadastre-se" do
    if @nome.text != nil || @email.text != nil || @senha.text != nil|| @cpf.text!= nil|| @endereco.text != nil || @casa.text != nil || @cidade.text != nil || @telefone.text != nil || @cep.text != nil
      name,em,pass,cp,ende,cas,cid,tel,ce = @nome.text,@email.text,@senha.text,@cpf.text,@ender.text,@casa.text,@cidade.text,@telefone.text,@cep.text
      server = TCPSocket.open("192.168.0.11",3001)
      @cadastro = Cadastro.new server, name,em,pass,cp,ende,cas,cid,tel,ce
      @cadastro.enviaDados

      alert"Cadastro realizado com sucesso!"

      require 'o'
      close
    else
      alert"Nao deixe os campos em branco"
    end


  end

end
