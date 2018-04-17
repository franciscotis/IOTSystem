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
# encoding: UTF-8
 ip = ""
porta = ""
CSV.foreach("endmaq.csv") do |row| #Pega o endereço ip do servidor e a porta que estão no arquivo csv
  ip,porta = row[0],row[1]
end
@servidor  = TCPSocket.open("192.168.0.101","3001") #Abre uma conexão TCP com o servidor


def dadosAdmin #Função que envia os dados para o servidor
  @servidor.puts "DadosAdmin" #Tipo de dado a ser enviado
  #Pega os dados que o servidor irá enviar e ai armazena em um array
  @rec = Array.new
  while line = @servidor.gets.chomp
    if line == "stop" #Enquanto o servidor não envia "stop" ele irá continuar armazenando no array os dados
      break
    end
    @rec << line
  end
  @rec.each do |rec| #Para cada dado recebido, ele irá dar o print
    puts rec
  end
end

def situacaoZona #Função que verifica a situação de cada zona
  @servidor.puts "PessoasZona" #Tipo de dado a ser enviado
  while line = @servidor.gets.chomp
    if line == "stop"  #Enquanto o servidor não envia "stop" ele irá continuar armazenando no array os dados
      break
    end
    puts line #Para cada dado recebido, ele irá mostrar as zonas disponiveis
  end
  puts "Digite qual zona você gostaria de verificar a situação" # O usuário irá escolher qual opção ele deseja
  zona = Integer(gets.chomp)
  @servidor.puts zona #Envia a zona desejada
while line = @servidor.gets.chomp #Enquanto o servidor não envia "stop" ele irá continuar recebendo os dados
  if line == "stop"
    break
  end
  puts line #Mostra para o administrador os dados recebidos
end

end

def gerarFatura #Método que faz gerar a fatura
  @servidor.puts "Fatura" #Envia para o servidor o tipo da operação
  resp = @servidor.gets #Recebe a resposta do servidor, dizendo se a operação foi realizada com sucesso
    puts resp #Imprime na tela
end

#Interface do administrador
loop do
  puts "==SEJA BEM-VINDO ADMINISTRADOR=="
  puts "Escolha o que você deseja
   [1] Verificar os dados de todos os clientes cadastrados
   [2] Verificar Situação de cada Zona
   [3] Gerar Fatura de todos os clientes
   [4] Sair"
  opcao = Integer(gets.chomp)
#O administador irá escolher
  case opcao
    when 1
      dadosAdmin
    when 2
      situacaoZona
    when 3
      gerarFatura
    when 4
      return
    else
      puts "Digite uma opção válida!"
  end



end

