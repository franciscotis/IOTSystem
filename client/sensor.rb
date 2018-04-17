=begin
Autor: Francisco Tito Silva Satos Pereira - 16111203
Componente Curricular: MI - Conectividade e Concorrência
Concluido em: 17/04/2018
Declaro que este código foi elaborado por mim de forma individual e não contém nenhum
trecho de código de outro colega ou de outro autor, tais como provindos de livros e
apostilas, e páginas ou documentos eletrônicos da Internet. Qualquer trecho de código
de outra autoria que não a minha está destacado com uma citação para o autor e a fonte
do código, e estou ciente que estes trechos não serão considerados para fins de avaliação.
=end
require 'socket'
require 'csv'
#encoding: ISO-8859-1
#require 'green_shoes'
#Classe sensor
class Sensor
  attr_accessor :vazaoAgua, :tempo, :email, :presenca,:ip, :porta #Getters e Setters
  def initialize #construtor
    @vazaoAgua = 0
    @tempo = 1 #Tempo de envio
    @email
    @ds = UDPSocket.new #Abre uma conexão UDP
    @presenca = true #tem presença de agua

    CSV.foreach("endmaq.csv") do |row| #Pega o endereço ip e a porta do servidor
      @ip = row[0].to_s
      @porta = row[1].to_s
    end

    getDado
  end

  def enviaDados() #Envia os dados do sensor para o servidor
      @dados = "#{email},#{@vazaoAgua.to_s},#{@presenca}"
      @ds.send(@dados.to_s,0,ip,3002) #Envia para o sensor
      sleep tempo #Espera o tempo em segundos
  end

  def getDado() #Recebe os dados do servidor através de uma conexão TCP
    server = TCPSocket.open(ip,porta)
    server.puts "Sensor"
    server.puts getip #Envia o ip para o servidor
    @email = server.gets #Recebe o email a partir do endereço ip enviado
  end

  def getip #Pega o endereço ip da máquina
    ip = IPSocket.getaddress(Socket.gethostname)
  end


end
#Interface gráfica
Shoes.app title: "SENSOR", :align=>'center', :width => 400, :height => 300, :resizable => false do
  style Shoes::Para, font: "MS UI Gothic"
  style Shoes::Title, font: "MS UI Gothic"
  background "#ECE9E6"..."#FFFFFF"
  @sensor = Sensor.new #Cria uma instância de sensor
  #Cria-se uma thread para enviar os dados ao mesmo tempo que cria a interface
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
      #Botões
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
    #Botões do tipo radio que verificam se tem presença ou não de água
    title "PRESENÇA DE ÁGUA", :align=>'center'
    flow(:margin_left => '35%') {
      @sim = radio; para strong("sim")
      @nao = radio; para strong("não")
    }

  end

#Ações dos botões do tipo radio
@sim.click do
  @sensor.presenca = true
end
  @nao.click do
    @sensor.presenca = false
  end



end
