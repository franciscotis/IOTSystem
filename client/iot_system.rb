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

#Página inicial no qual o usuário irá digitar o endereço ip do servidore a porta
Shoes.app title: "IOT SYSTEM", :width => 500, :height => 400, :resizable => false do
  style Shoes::Para, font: "MS UI Gothic"
  style Shoes::Title, font: "Lucida Grande"
  background "#99cfcc"..."#99cfcf"
  stack(:margin_left => '50%', :left => '-25%', :margin_top => '5%') do
    image "../img/iot.png"
    flow do
    para "Endereço IP"
    @ipserver = edit_line
    end
    para "Porta "
    @porta = edit_line
    button "Enviar" do
      File.open("endmaq.csv","w") do |line| #armazena em um arquivo csv
        line.puts "#{@ipserver.text},#{@porta.text}"
      end
      require 'login' #Abre a página de login
      close #Fecha a página atual
    end
  end


end