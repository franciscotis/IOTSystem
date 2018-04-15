require 'socket'
#require 'green_shoes'
#encoding: ISO-8859-1
class Sensor
  attr_accessor :vazaoAgua, :tempo, :email
  def initialize
    @vazaoAgua = 0
    @tempo = 1
    @email
    @ds = UDPSocket.new
    getDado


  end

  def enviaDados()
      @dados = "#{email},#{@vazaoAgua.to_s}"
      @ds.send(@dados.to_s,0,"192.168.0.120",3002)
      sleep tempo
  end

  def getDado()
    server = TCPSocket.open("192.168.0.120",3001)
    server.puts "Sensor"
    server.puts getip
    @email = server.gets
  end

  def getip
    ip = IPSocket.getaddress(Socket.gethostname)
  end


end

Shoes.app do
  @sensor = Sensor.new
  Thread.new do
    loop {
      @sensor.enviaDados
    }
  end

  title "SENSOR", :align=>'center'
  flow(:margin_left => '50%', :left => '-25%', :margin_top => '20%') do
    @vazao = title strong("#{@sensor.vazaoAgua}")
    para"metro cubi"
    stack(:margin_left => '35%', :left => '-3%') do
      button "+" do
        @sensor.vazaoAgua=@sensor.vazaoAgua+1
        @vazao.text = "#{@sensor.vazaoAgua}"
      end

      button "-" do
        if @sensor.vazaoAgua>0
          @sensor.vazaoAgua=@sensor.vazaoAgua-1
          @vazao.text = "#{@sensor.vazaoAgua}"
        end
      end
    end


  end

  stack() do
    title "DADOS DO CLIENTE", :align=>'center'
    # irá colocar o id do cliente
  end

  stack() do
    title "FREQUENCIA DE ENVIO", :align=>'center'
    flow(:margin_left => '35%') {
      @onesec = radio; para strong("1s")
      @fivesec = radio; para strong("5s")
      @tensec = radio; para strong("10s")
    }



  end



end
