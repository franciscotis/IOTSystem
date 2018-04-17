require 'socket'
require 'csv'
#encoding: ISO-8859-1
#require 'green_shoes'
class Sensor
  attr_accessor :vazaoAgua, :tempo, :email, :presenca,:ip, :porta
  def initialize
    @vazaoAgua = 0
    @tempo = 1
    @email
    @ds = UDPSocket.new
    @presenca = true

    CSV.foreach("endmaq.csv") do |row|
      @ip = row[0].to_s
      @porta = row[1].to_s
    end

    getDado
  end

  def enviaDados()
      @dados = "#{email},#{@vazaoAgua.to_s},#{@presenca}"
      @ds.send(@dados.to_s,0,ip,3002)
      sleep tempo
  end

  def getDado()
    server = TCPSocket.open(ip,porta)
    server.puts "Sensor"
    server.puts getip
    @email = server.gets
  end

  def getip
    ip = IPSocket.getaddress(Socket.gethostname)
  end


end

Shoes.app title: "SENSOR", :align=>'center', :width => 400, :height => 300, :resizable => false do
  style Shoes::Para, font: "MS UI Gothic"
  style Shoes::Title, font: "MS UI Gothic"
  background "#ECE9E6"..."#FFFFFF"
  @sensor = Sensor.new

  Thread.new do
    loop {
      @sensor.enviaDados
    }
  end

  title "SENSOR", :align=>'center'

  flow(:margin_left => '70%', :left => '-25%', :margin_top => '25%') do

    @vazao = title strong("#{@sensor.vazaoAgua}")
    para"m³"
    stack(:margin_left => '65%', :left => '-3%') do
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
    title "PRESENÇA DE ÁGUA", :align=>'center'
    flow(:margin_left => '35%') {
      @sim = radio; para strong("sim")
      @nao = radio; para strong("não")
    }

  end


@sim.click do
  @sensor.presenca = true
end
  @nao.click do
    @sensor.presenca = false
  end



end
