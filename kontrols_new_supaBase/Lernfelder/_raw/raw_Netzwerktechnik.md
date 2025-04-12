Oberbegriff: Netzwerktechnik

# Subnetting IPv4

## Grundlagen von IPv4-Adressen
### Struktur einer IPv4-Adresse
- BinäreDarstellung (32 Bits, 0 und 1).sql
- DezimaleDarstellung (4 Oktette, 0-255).sql
- Adressaufbau (Netzwerkanteil, Hostanteil).sql
### Adressklassen
- KlassenDefinition (A, B, C, D, E).sql
- Bereichsbestimmung (z. B. Klasse A: 1.0.0.0 - 127.255.255.255).sql
- Einsatzgebiete (Unternehmen, Multicast).sql

## Subnetzmasken
### Definition und Funktion
- SubnetzmaskeGrundlagen (32 Bits, Netzwerktrennung).sql
- BinäreBerechnung (AND-Operation).sql
- Standardmasken (z. B. 255.255.255.0).sql
### CIDR-Notation
- CIDRDefinition (z. B. #24).sql
- Bitanzahl (Netzwerkbits, Hostbits).sql
- Umrechnung (CIDR zu Dezimalmaske).sql

## Subnetting-Prozess
### Aufteilung eines Netzwerks
- Subnetzanzahl (2^n, geliehene Bits).sql
- Hostanzahl (2^(32-m) - 2).sql
- Berechnungsgrundlagen (Formeln, Beispiele).sql
### Berechnung der Subnetzadressen
- Inkrement (Schrittweite, z. B. 64 bei #26).sql
- Netzwerkadresse (Erste Adresse).sql
- Broadcastadresse (Letzte Adresse).sql
### Praktische Schritte
- Subnetzplanung (IP-Bereiche, Zuweisung).sql
- Fehlervermeidung (Überlappung, Adressverlust).sql

## Praktische Anwendung
### Beispielrechnung
- Ausgangsadresse (z. B. 192.168.1.0#24).sql
- Aufteilung (z. B. #26, 4 Subnetze).sql
- Ergebnisse (Adressbereiche, Hosts).sql
### DHCP IPV4
- DHCPGrundlagen (Automatische Adresszuweisung, IPv4).sql
- DHCPProzess (DORA: Discover, Offer, Request, Acknowledge).sql
- DHCPKonfiguration (Server, IP-Pool, Lease-Zeit).sql
### Einsatzszenarien
- Netzwerksegmentierung (Effizienz, Sicherheit).sql
- Adressmanagement (IP-Sparsamkeit).sql
- Praxisbeispiele (LAN, WAN).sql











# Subnetting IPv6

## Grundlagen von IPv6-Adressen
### Struktur einer IPv6-Adresse
- HexadezimaleDarstellung (128 Bits, 8 Blöcke).sql
- Adressformat (z. B. 2001:0db8::1, Kürzungsregeln).sql
- Adresstypen (Unicast, Multicast, Anycast).sql
### Adresszuweisung
- GlobalUnicast (2000::#3, weltweit eindeutig).sql
- LinkLocal (FE80::#10, lokale Kommunikation).sql
- UniqueLocal (FC00::#7, private Netze).sql

## Subnetzmasken und Präfixe
- PräfixDefinition (z. B. #64, 64 Bits).sql
- Präfixberechnung (Netzwerkanteil, Interface-ID).sql
- Standardpräfixe (#64 für LAN, #48 für Organisationen).sql
- Adressraum (2^128 vs. 2^32).sql

## Subnetting-Prozess
### Aufteilung eines Netzwerks
- Subnetzanzahl (2^n, n = geliehene Bits).sql
- Präfixaufteilung (z. B. #48 zu #64).sql
- InterfaceID (Hostanteil, 64 Bits).sql
### Berechnung der Subnetzadressen
- Subnetzgrenzen (Hexadezimalzählung).sql
- Adressbereiche (z. B. 2001:db8:1::#64).sql
- Multicastadressen (FF00::#8, Gruppen).sql

## Praktische Anwendung
### Beispielrechnung
- Ausgangsadresse (z. B. 2001:db8::#48).sql
- Aufteilung (z. B. in #64-Subnetze).sql
- Ergebnisse (Subnetzadressen, Anzahl).sql
### DHCPv6
- DHCPv6Grundlagen (Automatische Adresszuweisung, IPv6).sql
- DHCPv6Prozess (Solicit, Advertise, Request, Reply).sql
- DHCPv6vsSLAAC (Vergleich, Einsatzszenarien).sql
### Einsatzszenarien
- Netzwerkplanung (LAN, WAN, ISP).sql
- Autokonfiguration (SLAAC, DHCPv6).sql
- Adressverwaltung (großer Adressraum).sql











# Netzwerkdiagnose

## Grundlagen der Netzwerkkommunikation
### Protokolle
- ICMPv6 (Echo Request, Neighbor Discovery).sql
- IPGrundlagen (128-Bit-Adressen, Header).sql
- NDP (Neighbor Discovery, SLAAC).sql
### Kommunikationsarten
- Unicast (1-zu-1-Kommunikation).sql
- Multicast (1-zu-Gruppe, z. B. FF02::1).sql
- Anycast (1-zu-Nächstem, gleiche Adresse).sql

## Netzwerkkomponenten
### Gateway
- Standardgateway (Routing zwischen Netzen).sql
- GatewayKonfiguration (IPv6-Adresse, DHCPv6).sql
- GatewayFunktion (Paketweiterleitung).sql
### Multicast
- MulticastAdressen (FF00::#8, Scope).sql
- MulticastVerwendung (Gerätesuche, NDP).sql
- MulticastGruppen (z. B. FF02::1 für alle Knoten).sql

## Diagnosewerkzeuge
- Ipconfig (Windows, IPv6-Adressen).sql
- Ifconfig (Linux, Scope-ID, Schnittstellen).sql
### Ping
- PingGrundlagen (ICMPv6, Erreichbarkeit).sql
- PingOptionen (ping6, -c, -s).sql
- MulticastPing (Ping an FF02::1%Interface).sql
### Traceroute
- TracerouteGrundlagen (Routennachverfolgung).sql
- TracerouteOptionen (traceroute6, -n).sql
- TracerouteAuswertung (Latenz, Hops).sql 
### DHCP-Diagnose
  - DHCPFehlererkennung (Lease-Probleme, Serverausfall).sql
  - DHCPAbfragen (Client-Anfragen, Serverantworten).sql
  - DHCPTools (z. B. dhclient, Netzwerküberwachung).sql


## Praktische Anwendung
### Fehlerdiagnose
- Erreichbarkeitsprobleme (Timeout, Adressfehler).sql
- Paketverlust (Ursachen, ICMPv6-Fehler).sql
- Latenzprobleme (Messung, Multicast-Effekte).sql
### Netzwerkanalyse
- Routenverfolgung (Pfadanalyse, Engpässe).sql
- MulticastNutzung (Netzwerkübersicht, Debugging).sql
- Autokonfigurationsanalyse (SLAAC, NDP-Fehler).sql