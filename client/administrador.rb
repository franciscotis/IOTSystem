require 'socket'

begin
@servidor  = TCPSocket.open("192.168.25.5",3001)
raise
puts "Verifique se os dados estão corretos"
rescue
  puts "hi"
end

loop do
  puts "==SEJA BEM-VINDO ADMINISTRADOR=="
  puts "Escolha o que você deseja
   [1] Verificar os dados de todos os clientes cadastrados
   [2] Gerar Fatura de todos os clientes
   [3] Verificar Situação de cada Zona
   [4] Sair"
  opcao = Integer(gets.chomp)

  case opcao
    when 1
    when 2
    when 3
    when 4
    else
      puts "Digite uma opção válida!"
  end


end