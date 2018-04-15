#require 'green_shoes'
require 'socket'
require 'csv'
#encoding: ISO-8859-1

class Login < Shoes::Widget
  attr_accessor :server, :dados
  def initialize(servidor)
    @server = servidor
    @ip = nil
  end

  def enviaDados(tipo,email,senha)
    @dados = [tipo,getip.to_s,email,senha]
    @dados.each do |enviar|
      @server.puts enviar
    end

  end

  def ip
    @ip
  end

  def getip
    ip = IPSocket.getaddress(Socket.gethostname)
  end

  def recebeDados
   resposta = @server.gets
  end

  end

Shoes.app title: "Login" do
  server = TCPSocket.open("192.168.0.120",3001)
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
    a = Integer(@fazlogin.recebeDados)
    if a.zero?
      @fazlogin.server.close
      require 'client'
      alert("Login realizado com sucesso!")
      close

    else
      alert("Verifique se o e-mail e/ou a senha estao corretas ou se voce ja fez o cadastro!")
    end
  end


  button "Cadastre-se" do
    @fazlogin.server.close
    require 'cadastro'
    close
  end

end

