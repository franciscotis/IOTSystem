require 'socket'
#require 'green_shoes'
#encoding: ISO-8859-1
class Sensor
  attr_accessor :vazaoAgua, :tempo
  def initialize
    @vazaoAgua = 0
    @tempo = 1
    @ds = UDPSocket.new
  end

  def enviaDados()
      ip = (Socket.ip_address_list)[3].ip_address
      @dados = "#{ip.to_s},#{@vazaoAgua.to_s}"
      @ds.send(@dados.to_s,0,"localhost",3001)
      sleep tempo
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
