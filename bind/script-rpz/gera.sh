#!/bin/sh
sleep 1
echo
echo "Baixando lista shallalist"
wget http://www.shallalist.de/Downloads/shallalist.tar.gz -O /etc/bind/script-rpz/shallalist.tar.gz
tar -zxf /etc/bind/script-rpz/shallalist.tar.gz -C /etc/bind/script-rpz/
 if [ $? -ne 0 ]
        then
         echo "Atualização de DNS Não foi possivel baixar atualização Servidor: `hostname` Data: `date +%d/%m/%Y-%H:%M`"  >> /var/log/adblockdns.log
	exit 1
	fi
echo "Baixando adblok"
wget https://raw.githubusercontent.com/notracking/hosts-blocklists/master/adblock/adblock.txt -O /etc/bind/script-rpz/BL/adblock.txt
wget https://raw.githubusercontent.com/notracking/hosts-blocklists/master/hostnames.txt -O /etc/bind/script-rpz/BL/hostnames.txt
wget https://raw.githubusercontent.com/notracking/hosts-blocklists/master/domains.txt  -O /etc/bind/script-rpz/BL/domains.txt

sleep 1
echo
echo "Preparando Lista: ADBLOCK"
mkdir /etc/bind/script-rpz/BL/ads/
cat  /etc/bind/script-rpz/BL/domains.txt | grep -v '#' | cut -d / -f 2 | more > /etc/bind/script-rpz/BL/ads/domains
cat  /etc/bind/script-rpz/BL/hostnames.txt | egrep -v ':|#' | awk {'print $2'} >> /etc/bind/script-rpz/BL/ads/domains 
cat  /etc/bind/script-rpz/BL/adblock.txt | grep -v '!' | tr -d '|,^'  >> /etc/bind/script-rpz/BL/ads/domains 
 
sleep 1
echo 
echo "Preparando Lista: DROGAS"
mv /etc/bind/script-rpz/BL/drugs/domains /etc/bind/script-rpz/BL/drugs/domains.org
cat /etc/bind/script-rpz/BL/drugs/domains.org |grep -Eo "^[a-zA-Z0-9][a-zA-Z0-9-]{1,61}[a-zA-Z0-9]\.[a-zA-Z]{2,}.*" >> /etc/bind/script-rpz/BL/drugs/domains

cd /etc/bind/script-rpz/
echo 
echo "Gerando db.rpz.zone" 
perl rpz.pl
 
echo 
echo "Removendo arquivos desnecessarios"
rm -rf BL/
rm -f shallalist.tar.gz
 
echo 
echo "Corrigindo enderecos invalidos"
sed -i -e 's/www.battleit.ee\/tpb/battleit.ee/' /etc/bind/script-rpz/db.rpz.zone
sed -i -e 's/battleit.ee"/battleit.ee/' /etc/bind/script-rpz/db.rpz.zone
sed -i -e 's/freebiggals.net./freebiggals.net/' /etc/bind/script-rpz/db.rpz.zone
 
SEQUENCIAL=`date +%Y%m%d00`
 
sed -i -e "s/9999999999/$SEQUENCIAL/" /etc/bind/script-rpz/db.rpz.zone
 
echo
echo "Verificando se tem algum erros no arquivo db.rpz.zone"
named-checkzone localhost /etc/bind/script-rpz/db.rpz.zone
 if [ $? -ne 0 ]
        then
         echo "Atualização de DNS *VERIFICAÇÃO FALHOU* Servidor: `hostname` Data: `date +%d/%m/%Y-%H:%M`" >> /var/log/adblockdns.log
        exit 1
        fi
echo 
echo "Caso tenha algum erro do tipo: ignoring out-of-zone edite este script e adicione ele como"
echo "no exemplo dos dominios corrigindos com o comando sed -i -e ......"
echo
echo "Se voce recebeu um OK na verificacao"
echo "Agora basta mover db.rpz.zone  /var/cache/bind/rpz/ e reinicie o bind"
echo
echo "Comandos:"
mv /var/cache/bind/rpz/db.rpz.zone /var/cache/bind/rpz/db.rpz.zone.`date +%Y%m%d`
mv /etc/bind/script-rpz/db.rpz.zone /var/cache/bind/rpz/

/etc/init.d/bind9 restart
	if [ $? -ne 0 ]
	then
	echo "Atualização de bloqueios com erro:\n*EXIT CODE NÃO É 0* Servidor: `hostname` Data: `date +%d/%m/%Y-%H:%M`" >> /var/log/adblockdns.log
	exit 1
	else
	echo "Atualização de bloqueios com sucesso ervidor: `hostname` Data: `date +%d/%m/%Y-%H:%M`" >> /var/log/adblockdns.log
	fi
exit 0
