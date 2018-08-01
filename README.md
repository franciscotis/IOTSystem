# IOTSystem
Problema 1 - MIP: Concorrência e Conectividade UEFS 2018.1 - Sistema IOT para Monitoramento do Consumo Residencial de Água
Client-Server application made with Ruby.

## O que é necessário para o funcionamento
 Baixar o [Shoes](http://shoesrb.com/downloads/)
 
 Instalar o [Ruby](https://www.ruby-lang.org/en/downloads/)

## Configurações iniciais
Modificar a linha 386 do arquivo server/server.rb

```
Server.new(3001,"192.168.43.162")
```
No qual o primeiro parâmetro é a porta e o segundo é o endereço IP do servidor. 
Modificar o endereço ip para o endereço atual da máquina servidor

Modificar o arquivo /client/endmaq.csv no qual contém o endereço ip e a porta do servidor. Preencher os campos de acordo com os dados do servidor.

## Iniciando o servidor
Iniciar o servidor com o seguinte comando:
```
ruby server.rb

```
Servidor iniciado.

## Iniciando o cliente - Sensor

Iniciar o SHOES e abrir o arquivo sensor.rb

## Iniciando o cliente - Consumidor

Iniciar o SHOES e abrir o arquivo iot_system.rb


 
 
 
 ## AUTHOR
 [Francisco Pereira](franncisco.p@gmail.com)
