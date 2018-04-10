#require 'green_shoes'
require 'socket'
require 'csv'
#encoding: ISO-8859-1

class Login < Shoes::Widget
  attr_accessor :server
  def initialize(servidor)
    @server = servidor
    @ip = nil
  end

  def enviaDados(tipo,email,senha)
    @ip = (Socket.ip_address_list)[1].ip_address
    @dados = [tipo,ip,email,senha]
    @request = Thread.new do
    @server.puts @dados
    end
    @request.join
    end

  def ip
    @ip
  end

  def recebeDados
        while msg =  @server.gets
          arr << msg
        end
  end

  def fecha
    @server.close
  end
end

Shoes.app title: "Login" do
  server = TCPSocket.open("192.168.25.5",3001)
  @fazlogin = Login.new server
  stack(left:35, top:90) do
    para "E-mail"
    flow do
      background black
      @login = edit_line
    end
    para "Senha"
    flow do
      background red
      @password = edit_line
    end

  end
  button "Entrar" do

    email,senha = @login.text,@password.text

    @fazlogin.enviaDados "Login",email,senha
    d = @fazlogin.recebeDados
    alert d
    if @fazlogin.recebeDados==0
      alert("Login realizado com sucesso!")
      require 'client'
      #Client.new row[0],row[1],row[2],row[3],row[4],row[5],row[6],row[7],row[8]
      close
    else
      alert("Verifique se o e-mail e/ou a senha estao corretas ou se voce ja fez o cadastro!")
    end
  end


  button "Cadastre-se" do
    require 'cadastro'
    close
  end

end

