# adblock-dns
Bloqueio de anúncios via DNS usando BIND9

Instalação:

git clone https://github.com/phvilasboas/adblock-dns.git

cd adblock-dns/

chmod +x install.sh

./install.sh

Apos a instalação, mudar o 	_zone "rpz.zone" policy CNAME_  no arquivo named.conf.options para um domínio valido ou um proprio dns local.
