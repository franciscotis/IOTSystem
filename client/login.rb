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

Shoes.app title: "Login", :width => 500, :height => 400, :resizable => false do
  style Shoes::Para, font: "MS UI Gothic"
  style Shoes::Title, font: "Lucida Grande"
  background('../img/videoblocks-bright-abstract-water-surface-glare-sun-blurred-background-loop_rizmureyow_thumbnail-small01.jpg')
  ip = ""
  porta = ""
  CSV.foreach("endmaq.csv") do |row|
    ip,porta = row[0],row[1]
  end
  begin
  server = TCPSocket.open(ip,porta)
  rescue
    alert "Não possível conectar com o servidor"
    require 'iot_system'
    close
  end
  @fazlogin = Login.new server
  title "LOGIN", :align=>'center', :margin_top => '10%'
  stack(:margin_left => '50%', :left => '-25%', :margin_top => '30%') do
    para "E-mail"
    flow do
      @login = edit_line
    end
    para "Senha"
    flow do
      @password = edit_line :secret => true
    end
    flow do

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
  end

end

