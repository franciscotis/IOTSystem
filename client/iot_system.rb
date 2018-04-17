
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
      File.open("endmaq.csv","w") do |line|
        line.puts "#{@ipserver.text},#{@porta.text}"
      end
      require 'login'
      close
    end
  end


end