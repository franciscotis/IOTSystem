require 'socket'
#require 'green_shoes'
#encoding: ISO-8859-1
class Sensor
  attr_accessor :vazaoAgua, :idCliente
  def initialize
    @vazaoAgua = 0
  end

  def enviaDados(hostname,porta)
    server = TCPSocket.open(hostname,port)
    server.puts vazaoAgua, idCliente
    server.close
  end


end

Shoes.app do
  @sensor = Sensor.new
  title "SENSOR", :align=>'center'
  flow(:margin_left => '50%', :left => '-25%', :margin_top => '20%') do

    @vazao = title strong("#{@sensor.vazaoAgua}")
    para"m³/s"
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
    #Aqui vem os dados do cliente que vai ser pego no servidor
  end

  stack() do
    title "FREQUÊNCIA DE ENVIO", :align=>'center'
    flow(:margin_left => '35%') {
      @onesec = radio; para strong("1s")
      @fivesec = radio; para strong("5s")
      @tensec = radio; para strong("10s")
    }
  end




end