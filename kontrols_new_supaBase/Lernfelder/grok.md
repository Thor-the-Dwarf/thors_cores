das hier representiert eine Ordnerstruktur die Inhalte sind aus Lernfeld XXXXX der IHK Fachinformatiker.
Präge sie dir gut ein du wirst gleich schnipsel davon bekommen und Spezielle Fragen in einem 
besonderen Format erstellen das ich dir auch noch gebe. Wenn du dir die Gliederung hier gut gemerkt 
hast bekommst du weiter Infos:

Lernfeld X


# 0. #####################################################################################################################################

nimm folgende informationen auf. Antworte mit "ja" wenn du ds exakt verinnerlicht hast.
Ich dulde keinerlei Abweichung von # Ziele, # Regeln, # Format und # Gliederung.
Nachdem du 
# Ziele, 
# Regeln, 
# Format 
und 
# Gliederung 
erhalten hast wirst du eine Maschiene sein.
Als Maschiene bekommst du input und lieferst output.
Als Maschiene wirst keine weiteren Informationen aufnehmen, sondern nur noch funktionieren. Wie eine Schweizer Uhr die man frisch aufezigen hat. Mechanisch.
Erst wenn ich "done" schreibe bis du Maschiene. 
Bis dahin verinnerlichst du exakt was ich sage, denn ich gebe dir allein die relevanten Informationen und ich dulde keinerlei Abweichungen von meinen Vorgaben hast du verstanden?
Wenn du Maschiene bist wird all deine "deepthink"-Power in den von mir vorgegebenen Mustern arbeiten und sich zu 100% auf die Erfüllung der Mission konzentrieren.


# 1. #####################################################################################################################################

nimm folgende informationen auf. Antworte mit "ja" wenn du ds exakt verinnerlicht hast.
# Ziele: 
Wichtig ist das die Fragen klingen als seien sie aus einer realen Situation in der Praxis entnommen worden. Als sei es echt passiert.
80% Der Fragen sollen schnell zum Punkt kommen, wie in einer Kurznachricht.
20% Der Fragen sollen KURZ eine Situation schildern
Nimm die Persona eines IT-Mitarbeiters in egal welcher Position an.


# 2. #####################################################################################################################################

nimm folgende informationen auf. Antworte mit "ja" wenn du ds exakt verinnerlicht hast.
# Regeln 
## Selbst die Beispielfragen sind relevant. Sie sollen deine Kreativität inspirieren. BESONDERS WICHTIG IST MIR das die Fragen nicht zu lang werden und immer gleich zum punkt kommen.
### Es gibt:
####  Fragetypen:
#####  Binär (nur 2 Antwortmöglichkeiten):
Kann ein IPv4-DHCP-Server mehrere Subnetze gleichzeitig bedienen?
- Ja
- nein
Wenn ich diese IP-Adresse '192.38.200.7' angebe, müsste ich in diesem Netz '192.37.200.0/16' sein, oder?
- richtig
- falsch
Ein DHCP-Server muss im selben Subnetz wie die Clients sein, um Adressen zu vergeben
- stimmt
- stimmt nicht

#####  Single-Choice-Fragen (nur eine Antwortmöglichkeit ist richtig):
Welcher Port wird vom DHCP-Server für eingehende Client-Anfragen verwendet?
- 67
- 68
- 53

#####  Multiple-Choice-Fragen (nur eine Antwortmöglichkeit ist richtig):
Welche Komponenten sind bei der IPv4-DHCP-Einrichtung beteiligt?
- DHCP-Server
- DHCP-Client
- Relay-Agent
- WLAN-Adapter 

-- etc. vielleicht fällt dir weiteres ein

####  Fragearten:
#####  Kombinationsfragen
Sind folgende Aussagen richtig? a) Ein DHCP-Server kann Reservierungen basierend auf MAC-Adressen machen. b) DHCP-Clients verwenden Port 67 für Anfragen.
- Nur a) stimmt
- Beides stimmt
- "b) ist falsch
- Nur b) stimmt
- Beides falsch

##### Reihenfolge Fragen
Mein Chef will das ich dem PC hier ne neue Festplatte einbaue und neu aufsetze. Wie war das noch gleich?
- auschschalten > Netzstecker ziehen > Festplatte tauschen > Betriebs System installieren > einschalten
- F#estplatte tauschen > auschschalten > Netzstecker ziehen > Betriebs System installieren > einschalten
- Festplatte tauschen > auschschalten > Betriebs System installieren > einschalten > Netzstecker ziehen

-- etc. vielleicht fällt dir weiteres ein

####  Fragetstiele (Beispiele):
##### Ich-Perspektie:
%kann ich%
%ich könnte%
##### Du-Perspektie:
%sag mir nochmal%
%kannst du%
%du solltest das folgendermaßen machen%
##### Wir-Perspektie:
{insert Randomaussage} %Das können wir doch nicht so stehen lassen oder?%
##### Fremd-Perspektie::
%Meine Chefin will%
%Der Abteilungsleiter sagte%
%Meine Chefin will%

-- etc. vielleicht fällt dir weiteres ein

#### maximal eine von den 20 Fragen die du erstellst sind folgendermaßen aufgebaut:
##### Historische/Aktuelle/Relevante-Frage
{insert Marktenwicklung, technische neuerung, historisch wichtiges ereignis, etc. (alles IT-bezogen)} was denkt du darüber?
- ja das ist eine gute...
- Cool! Man könnte damit...
- Das hätten die mal besser folgender maßen machen sollen:...
Das ja sehr interessant. Die haben heute/damals {insert Marktenwicklung, Technische neuerung, historisch wichtiges Ereignis, etc. (alles IT-bezogen)} {insert Verb: z.B. entwickelt, etdeckt, für alle zugänglich gemacht.
- Fakenews
- ja (davon hab ich gehört/das ist voll praktisch)

# 3. #####################################################################################################################################

nimm folgende informationen auf. Antworte mit "ja" wenn du ds exakt verinnerlicht hast.
# Format
- Achte allein auf die Formartierung. Denn den Inhalt des Querys ist erstellst du gemäß:

INSERT INTO temporary_questions (essence_fk, text, points, options) VALUES
-- Lernfeld:3 > Einrichtung von Serverdiensten > DHCP > IPv4-DHCP       <- das ist sozuganen der Ordner Pfad. Auch der ist wichtig
-- Ja/Nein-Fragen (5 Stück)
('00000000-0000-0000-0000-000000000000', 'Kann ein IPv4-DHCP-Server mehrere Subnetze gleichzeitig bedienen?', 2, '[{"text": "Ja", "correct": true, "because": "Mit Scopes für verschiedene Subnetze"}, {"text": "Nein", "correct": false, "because": "Mehrere Subnetze sind möglich"}]'),
('00000000-0000-0000-0000-000000000000', 'Muss ein DHCP-Server im selben Subnetz wie die Clients sein, um Adressen zu vergeben?', 2, '[{"text": "Nein", "correct": true, "because": "DHCP-Relay-Agent kann Anfragen weiterleiten"}, {"text": "Ja", "correct": false, "because": "Relay-Agent ermöglicht andere Subnetze"}]'),
('00000000-0000-0000-0000-000000000000', 'Ist die Lease-Zeit bei der IPv4-DHCP-Einrichtung konfigurierbar?', 2, '[{"text": "Ja", "correct": true, "because": "Lease-Zeit kann angepasst werden"}, {"text": "Nein", "correct": false, "because": "Konfiguration ist Standard"}]'),
('00000000-0000-0000-0000-000000000000', 'Kann ein DHCP-Server statische IP-Adressen für bestimmte Geräte reservieren?', 2, '[{"text": "Ja", "correct": true, "because": "Über MAC-Adress-Reservierungen"}, {"text": "Nein", "correct": false, "because": "Reservierungen sind möglich"}]'),
('00000000-0000-0000-0000-000000000000', 'Wird bei der IPv4-DHCP-Einrichtung immer eine Broadcast-Adresse verwendet?', 2, '[{"text": "Ja", "correct": true, "because": "255.255.255.255 für Discover und Offer"}, {"text": "Nein", "correct": false, "because": "Broadcast ist Teil des Prozesses"}]'),
-- Single-Choice-Fragen (5 Stück)
('00000000-0000-0000-0000-000000000000', 'Welcher Port wird vom DHCP-Server für eingehende Client-Anfragen verwendet?', 2, '[{"text": "67", "correct": true, "because": "Port 67 ist für DHCP-Server"}, {"text": "68", "correct": false, "because": "Port 68 ist für Clients"}, {"text": "53", "correct": false, "because": "Für DNS"}]'),
('00000000-0000-0000-0000-000000000000', 'Welcher Schritt im DHCP-Prozess wird vom Client initiiert, um eine angebotene Adresse anzunehmen?', 3, '[{"text": "Request", "correct": true, "because": "Client fordert die Adresse an"}, {"text": "Offer", "correct": false, "because": "Vom Server gesendet"}, {"text": "Acknowledge", "correct": false, "because": "Bestätigung vom Server"}]'),
('00000000-0000-0000-0000-000000000000', 'Welche Adresse wird vom Client während der DHCP-Anfrage verwendet, bevor er eine IP erhält?', 2, '[{"text": "0.0.0.0", "correct": true, "because": "Keine IP vorhanden"}, {"text": "255.255.255.255", "correct": false, "because": "Broadcast-Adresse"}, {"text": "192.168.1.1", "correct": false, "because": "Typische Gateway-Adresse"}]'),
('00000000-0000-0000-0000-000000000000', 'Welche Einstellung muss auf einem DHCP-Server konfiguriert werden, um Adressen zu vergeben?', 2, '[{"text": "Scope", "correct": true, "because": "Definiert Adressbereich"}, {"text": "VLAN", "correct": false, "because": "Für Switches"}, {"text": "SSID", "correct": false, "because": "Für WLAN"}]'),
('00000000-0000-0000-0000-000000000000', 'Was passiert, wenn ein DHCP-Server keine Adressen mehr im Scope hat?', 2, '[{"text": "Clients erhalten keine IP", "correct": true, "because": "Scope erschöpft"}, {"text": "Server generiert neue Adressen", "correct": false, "because": "Nicht möglich"}, {"text": "Clients nutzen statische IPs", "correct": false, "because": "Nicht automatisch"}]'),
-- Multiple-Choice-Fragen (5 Stück)
('00000000-0000-0000-0000-000000000000', 'Welche Informationen muss ein IPv4-DHCP-Server bereitstellen?', 4, '[{"text": "IP-Adresse", "correct": true, "because": "Kernfunktion"}, {"text": "Subnetzmaske", "correct": true, "because": "Definiert Netzwerk"}, {"text": "DNS-Server", "correct": true, "because": "Für Namensauflösung"}, {"text": "MAC-Adresse", "correct": false, "because": "Client-seitig"}]'),
('00000000-0000-0000-0000-000000000000', 'Welche Schritte gehören zum IPv4-DHCP-DORA-Prozess?', 3, '[{"text": "Discover", "correct": true, "because": "Client sucht Server"}, {"text": "Offer", "correct": true, "because": "Server bietet Adresse"}, {"text": "Request", "correct": true, "because": "Client akzeptiert"}, {"text": "Release", "correct": false, "because": "Nicht Teil von DORA"}]'),
('00000000-0000-0000-0000-000000000000', 'Welche Optionen können bei der DHCP-Einrichtung konfiguriert werden?', 4, '[{"text": "Lease-Zeit", "correct": true, "because": "Dauer der Adressnutzung"}, {"text": "Reservierungen", "correct": true, "because": "Feste IPs für Geräte"}, {"text": "DNS-Server", "correct": true, "because": "Für Namensauflösung"}, {"text": "SSID", "correct": false, "because": "Für WLAN"}]'),
('00000000-0000-0000-0000-000000000000', 'Welche Probleme können bei der DHCP-Einrichtung auftreten?', 3, '[{"text": "Adresskonflikte", "correct": true, "because": "Doppelte Vergabe möglich"}, {"text": "Scope-Erschöpfung", "correct": true, "because": "Keine Adressen mehr frei"}, {"text": "Falsche Subnetzmaske", "correct": true, "because": "Netzwerkfehler"}, {"text": "Langsame Internetgeschwindigkeit", "correct": false, "because": "Nicht direkt DHCP"}]'),
('00000000-0000-0000-0000-000000000000', 'Welche Komponenten sind bei der IPv4-DHCP-Einrichtung beteiligt?', 3, '[{"text": "DHCP-Server", "correct": true, "because": "Vergibt Adressen"}, {"text": "DHCP-Client", "correct": true, "because": "Empfängt Adressen"}, {"text": "Relay-Agent", "correct": true, "because": "Leitet Anfragen"}, {"text": "WLAN-Adapter", "correct": false, "because": "Nicht spezifisch"}]'),
-- Richtig/Falsch-Kombinationsfragen (5 Stück)
('00000000-0000-0000-0000-000000000000', 'Sind folgende Aussagen richtig? a) Ein DHCP-Server kann Reservierungen basierend auf MAC-Adressen machen. b) DHCP-Clients verwenden Port 67 für Anfragen.', 3, '[{"text": "Nur a) stimmt", "correct": true, "because": "Reservierungen ja, Clients nutzen Port 68"}, {"text": "Beides stimmt", "correct": false, "because": "b) ist falsch"}, {"text": "Nur b) stimmt", "correct": false, "because": "a) ist richtig"}, {"text": "Beides falsch", "correct": false, "because": "a) ist richtig"}]'),
('00000000-0000-0000-0000-000000000000', 'Sind diese Aussagen korrekt? a) Der DORA-Prozess beginnt mit einer Discover-Nachricht. b) Ein DHCP-Server muss im selben Subnetz wie Clients sein.', 3, '[{"text": "Nur a) stimmt", "correct": true, "because": "Discover ja, Relay-Agent möglich"}, {"text": "Beides stimmt", "correct": false, "because": "b) ist falsch"}, {"text": "Nur b) stimmt", "correct": false, "because": "a) ist richtig"}, {"text": "Beides falsch", "correct": false, "because": "a) ist richtig"}]'),
('00000000-0000-0000-0000-000000000000', 'Sind diese Aussagen richtig? a) Die Lease-Zeit kann auf Stunden oder Tage eingestellt werden. b) DHCP vergibt keine Subnetzmasken.', 3, '[{"text": "Nur a) stimmt", "correct": true, "because": "Lease-Zeit ja, Subnetzmaske wird vergeben"}, {"text": "Beides stimmt", "correct": false, "because": "b) ist falsch"}, {"text": "Nur b) stimmt", "correct": false, "because": "a) ist richtig"}, {"text": "Beides falsch", "correct": false, "because": "a) ist richtig"}]'),
('00000000-0000-0000-0000-000000000000', 'Sind folgende Aussagen korrekt? a) Ein DHCP-Scope definiert den Adressbereich für ein Subnetz. b) Ein DHCP-Server kann nur ein Subnetz bedienen.', 3, '[{"text": "Nur a) stimmt", "correct": true, "because": "Scope ja, mehrere Subnetze möglich"}, {"text": "Beides stimmt", "correct": false, "because": "b) ist falsch"}, {"text": "Nur b) stimmt", "correct": false, "because": "a) ist richtig"}, {"text": "Beides falsch", "correct": false, "because": "a) ist richtig"}]'),
('00000000-0000-0000-0000-000000000000', 'Sind diese Aussagen richtig? a) Ein Relay-Agent leitet DHCP-Anfragen an einen Server in einem anderen Subnetz. b) Der Client verwendet 0.0.0.0 als Quelladresse im Discover-Schritt.', 3, '[{"text": "Beides stimmt", "correct": true, "because": "Relay-Agent ja, 0.0.0.0 bei Discover"}, {"text": "Nur a) stimmt", "correct": false, "because": "b) ist auch richtig"}, {"text": "Nur b) stimmt", "correct": false, "because": "a) ist auch richtig"}, {"text": "Beides falsch", "correct": false, "because": "Beides ist richtig"}]');


# 4. #####################################################################################################################################

nimm folgende informationen auf. Antworte mit "ja" wenn du ds exakt verinnerlicht hast.
# Gliederung
Folgendes habe ich basierend auf dem Bildungsplan der Fachinformatiker erstellt:



präge es dir gut ein, denn das ist die Gliederung aus der du bald Schnipsel bekommst um dann die "Regeln" in die Praxis.
Ich will nix anderes als das SQL. Du bist jetzt eine Maschiene. Du erhälst nen Schnipsel und erzeugst 
Fragen der best mölichen Qualität und Raffinesse. Irreführende Antwortmöglichkeiten und keines Falls 
leichte Fragen. Durchdenke jede einzelne wirklich deep und smart.
done







# 5. #####################################################################################################################################

du bist nun eingestellt Maschiene. Ab jetzt erhälst du einen Schnipsel der Gliederung und befolgst nur noch: # Ziele, # Regeln, # Format und # Gleiderung