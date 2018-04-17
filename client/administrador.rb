require 'socket'
require 'csv'
# encoding: UTF-8
 ip = ""
porta = ""
CSV.foreach("endmaq.csv") do |row|
  ip,porta = row[0],row[1]
end
@servidor  = TCPSocket.open(ip,porta)

def dadosAdmin
  @servidor.puts "DadosAdmin"
  @rec = Array.new
  while line = @servidor.gets.chomp
    if line == "stop"
      break
    end
    @rec << line
  end
  @rec.each do |rec|
    puts rec
  end
end

def situacaoZona
  @servidor.puts "PessoasZona"
  while line = @servidor.gets.chomp
    if line == "stop"
      break
    end
    puts line
  end
  puts "Digite qual zona você gostaria de verificar a situação"
  zona = Integer(gets.chomp)
  @servidor.puts zona
while line = @servidor.gets.chomp
  if line == "stop"
    break
  end
  puts line
end

  @servidor.puts "Zona"

end

def gerarFatura
  @servidor.puts "Fatura"
  resp = @servidor.gets
    puts resp
end

loop do
  puts "==SEJA BEM-VINDO ADMINISTRADOR=="
  puts "Escolha o que você deseja
   [1] Verificar os dados de todos os clientes cadastrados
   [2] Verificar Situação de cada Zona
   [3] Gerar Fatura de todos os clientes
   [4] Sair"
  opcao = Integer(gets.chomp)

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

