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

# Requerimentos para o código funcionar
#require 'green_shoes'
require 'socket'
require 'csv'
#encoding: ISO-8859-1


#Interface gráfica, provido pelo framework Ruby Shoes
class Login < Shoes::Widget #Inicio da classe Login
  attr_accessor :server, :dados #Getters e Setters do ruby é definido pelo attr_accessor
  def initialize(servidor) #Construtor da classe
    @server = servidor
    @ip = nil
  end

  #Método que envia os dados do login para o servidor
  def enviaDados(tipo,email,senha)
    @dados = [tipo,getip.to_s,email,senha] #Criado um array de todos os dados que irão ser enviados
    @dados.each do |enviar| #Para cada arquivo dentro do array, será enviado para o servidor
      @server.puts enviar #Envia para o administrador
    end

  end

  def getip
    ip = IPSocket.getaddress(Socket.gethostname) #Método que pega o endereço ip do sistema
  end

  def recebeDados
   resposta = @server.gets #Método que recebe a resposta do servidor
  end

  end

#Interface gráfica
Shoes.app title: "Login", :width => 500, :height => 400, :resizable => false do
  #Tipos da fonte
  style Shoes::Para, font: "MS UI Gothic"
  style Shoes::Title, font: "Lucida Grande"

  background('../img/videoblocks-bright-abstract-water-surface-glare-sun-blurred-background-loop_rizmureyow_thumbnail-small01.jpg')
  ip = ""
  porta = ""
  CSV.foreach("endmaq.csv") do |row| #Pega o endereço do servidor, que está no arquivo csv chamado endmaq
    ip,porta = row[0],row[1] #coloco o resultado nas variáveis ip e porta
  end
  begin
  server = TCPSocket.open(ip,porta) #Abro a conexão com o servidor no ip e na porta
  rescue
    alert "Não possível conectar com o servidor" #Caso não seja possível, irá alertar ao usuário
    require 'iot_system' #E o redirecionará para a página inicial
    close
  end
  @fazlogin = Login.new server #Crio uma nova instância de login, clase que está logo acima

  title "LOGIN", :align=>'center', :margin_top => '10%' #Titulo
  stack(:margin_left => '50%', :left => '-25%', :margin_top => '30%') do #Uma pilha, na interface os seus itens estão situados um abaixo do outro
    para "E-mail" #parágrafo
    flow do #Como se fosse uma lista, na interface, os seus ítens estão situados um ao lado do outro
      @login = edit_line
    end
    para "Senha"
    flow do
      @password = edit_line :secret => true
    end
    flow do

    button "Entrar" do #Botão
      email,senha = @login.text,@password.text #Pega os textos que o usuário digitou
      @fazlogin.enviaDados "Login",email,senha #Envia os dados para o servidor, no qual irá responder 0 ou 1.
      a = Integer(@fazlogin.recebeDados) #Recebe os dados do servidor
      if a.zero? #Caso receba zero, significa que o usuário está cadastrado corretamente
        @fazlogin.server.close #Fecha o servidor
        require 'client' # Abre a página de cliente
        alert("Login realizado com sucesso!") #Diz que o login foi feito com sucesso
        close #Fecha a página

      else #Caso contrário, alerta ao usuário
        alert("Verifique se o e-mail e/ou a senha estao corretas ou se voce ja fez o cadastro!")
      end
    end


    button "Cadastre-se" do # se o usuário quiser se cadastrar
      @fazlogin.server.close #Fecha o servidor
      require 'cadastro' #Abre a página de cadastro
      close #Fecha a página
    end
end
  end

end

