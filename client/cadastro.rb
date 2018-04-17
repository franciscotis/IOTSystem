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
#Requerimentos
require 'socket'
require 'csv'
#Inicio da classe
class Cadastro
  attr_accessor :dados, :server #Getters e Setters da classe
  def initialize(servidor,tipo,nombre,em,pass,cp,ende,cas,cid,tel,ce) #Construtor
    @server = servidor
    @request = nil
    @response = nil
    @dados = [tipo,nombre,em,pass,cp,ende,cas,cid,tel,ce] #Array de todos os dados

  end

  def enviaDados #método que envia os dados para o servidor
      @dados.each do |dads|
        @server.puts dads
      end
  end


end


#interface gráfica
Shoes.app title: "Cadastro",:width => 500, :height => 500, :resizable => false   do
  style Shoes::Para, font: "MS UI Gothic"
  style Shoes::Title, font: "Lucida Grande"
  style Shoes::Button, font: "Andale Mono"
  background "#99ffcc"..."#99ccff"
  title "CADASTRO", :align=>'center', :margin_top => '5%'
  stack(:margin_left => '50%', :left => '-25%', :margin_top => '14%') do
    para "Nome"
    flow do
      @nome = edit_line
    end
    para "Email"
    flow do
      @email = edit_line
    end
    para "Senha"
    flow do
      @senha = edit_line
    end
    para "CPF"
    flow do
      @cpf = edit_line
    end
    para "Endereco"
    flow do
      @ender = edit_line
    end
    para "Casa"
    flow do
      @casa = edit_line
    end
    para "Cidade"
    flow do
      @cidade = edit_line
    end
    para "Telefone"
    flow do
      @telefone = edit_line
    end
    para "CEP"
    flow do
      @cep = edit_line
    end
    stack do
    button "Cadastre-se", :margin_top => '18%' do #Botão do cadastro
      if @nome.text != "" || @email.text != "" || @senha.text != ""|| @cpf.text!= ""|| @endereco.text != "" || @casa.text != "" || @cidade.text != "" || @telefone.text != "" || @cep.text != ""
        #Caso o usuário digite tudo corretamente
        nombre,em,pass,cp,ende,cas,cid,tel,ce = @nome.text,@email.text,@senha.text,@cpf.text,@ender.text,@casa.text,@cidade.text,@telefone.text,@cep.text
        ip = ""
        porta = ""
        CSV.foreach("endmaq.csv") do |row|  #Abre o arquivo csv que contém o endereço e a porta do servidor
          ip,porta = row[0],row[1]
        end
        server = TCPSocket.open(ip,porta) #É aberto uma conexão TCP com o servidor
        @cadastro = Cadastro.new server,'Cadastro',nombre,em,pass,cp,ende,cas,cid,tel,ce #Cria uma instância de cadastro
        @cadastro.enviaDados #Envia os dados para o servidor
        alert"Cadastro realizado com sucesso!" #Exibe a mensagem para o usuário
        @cadastro.server.close #Fecha a conexão com o servidor
        require 'login' #Abre a página de Login
        close #Fecha a página
      else #Caso contrário, mostra o alerta para o usuário
        alert"Nao deixe os campos em branco"
      end

    end
    end
  end


end
