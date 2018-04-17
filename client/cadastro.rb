require 'socket'
class Cadastro
  attr_accessor :dados, :server
  def initialize(servidor,tipo,nombre,em,pass,cp,ende,cas,cid,tel,ce)
    @server = servidor
    @request = nil
    @response = nil
    @dados = [tipo,nombre,em,pass,cp,ende,cas,cid,tel,ce]

  end

  def enviaDados
      @dados.each do |dads|
        @server.puts dads
      end
  end


end



Shoes.app title: "Cadastro",:width => 500, :height => 500, :resizable => false   do
  style Shoes::Para, font: "MS UI Gothic"
  style Shoes::Title, font: "Lucida Grande"
  style Shoes::Button, font: "Andale Mono"
  background "#99ffcc"..."#99ccff"
  title "CADASTRO", :align=>'center', :margin_top => '5%'
  stack(:margin_left => '50%', :left => '-25%', :margin_top => '14%') do
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
    stack do
    button "Cadastre-se", :margin_top => '18%' do
      if @nome.text != "" || @email.text != "" || @senha.text != ""|| @cpf.text!= ""|| @endereco.text != "" || @casa.text != "" || @cidade.text != "" || @telefone.text != "" || @cep.text != ""
        nombre,em,pass,cp,ende,cas,cid,tel,ce = @nome.text,@email.text,@senha.text,@cpf.text,@ender.text,@casa.text,@cidade.text,@telefone.text,@cep.text
        ip = ""
        porta = ""
        CSV.foreach("endmaq.csv") do |row|
          ip,porta = row[0],row[1]
        end
        server = TCPSocket.open(ip,porta)
        @cadastro = Cadastro.new server,'Cadastro',nombre,em,pass,cp,ende,cas,cid,tel,ce
        @cadastro.enviaDados
        alert"Cadastro realizado com sucesso!"
        @cadastro.server.close
        require 'login'
        close
      else
        alert"Nao deixe os campos em branco"
      end

    end
    end
  end


end
