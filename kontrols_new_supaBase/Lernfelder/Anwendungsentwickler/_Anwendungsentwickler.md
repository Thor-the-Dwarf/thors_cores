# Phase 1: Analysieren
- Projektdefinition.sql

### Analysearten
- Analyse bestehender Software.sql
- Kosten-Nutzen-Analyse.sql
- Normen (ISO 9421(Ergonomie), WCAG(Accessibility)).sql
- Rechtliche Rahmenbedingungen abklären.sql
- Rentabilität bewerten.sql
- Risikoanalyse.sql
- Risikobewertung.sql

## Trends
- aktuell (Benutzerfreundlichkeit, Barrierefreiheit).sql
- künftig (Darkmode, Mirkointeraktionen).sql

### Zielsetzung des Kundenauftrags erfassen
- Anforderungen klären.sql
- Anforderungskatalog (Funktionale und nicht funktionale Anforderungen, Barrierefreiheit).sql
- Erwartungen dokumentieren.sql
- Ist-Analyse (Arbeitsabläufe und Geschäftsprozesse analysieren und beschreiben).sql



# Phase 2: Planen

## Datenstrukturen

### Bedarfsgerechte Auswahl
- Anwendungsszenarien analysieren.sql (Passende Strukturen für spezifische Probleme auswählen)
- Effizienz bewerten.sql (Laufzeit- und Speicherbedarf der Datenstrukturen analysieren)

### Grundlegende Datenstrukturen
- Arrays, Listen, Stacks, Queues.sql (Lineare Strukturen für verschiedene Anwendungsfälle)
- Bäume, Hash-Tabellen.sql (Hierarchische und schnelle Zugriffsstrukturen)
- Java-Datenstrukturen (ArrayList, HashMap).sql (Java-spezifische Implementierungen)
- Python-Datenstrukturen (Listen, Dictionaries).sql (Python-spezifische Implementierungen)

## Design Werkzeuge
- Mockdaten (Realistische Testdaten, Inhaltssimulation).sql (Daten für Tests und Demos erstellen)
- Mockups (Detailgetreue Statische Designs).sql (Visuelle Entwürfe ohne Funktionalität)
- Prototyping (Interaktive Modelle, Validierung mit Nutzern).sql (Funktionale Modelle zum Testen)
- Wireframes (Sketch, Erster Entwurf, Strukturplanung).sql (Grundgerüst der UI-Planung)
- Farben und Typografie.sql (Gestaltungselemente für Konsistenz und Ästhetik)
- Verbindung zur Softwarestruktur.sql (Design mit Code-Architektur abstimmen)

## Designprinzipien
- Feedback und Hierarchie, Visuelle Rückmeldung, Strukturierte Navigation.sql (Nutzerführung und Interaktion)
- Konsistenz und Einfachheit, Einheitliches Layout, Reduktion auf Wesentliches.sql (Klarheit und Benutzbarkeit)

## IT-Sicherheit

### Grundlagen
- IT-Sicherheitskonzepte.sql (Überblick über Sicherheitsanforderungen und -prinzipien, z. B. Schutz vor Bedrohungen)
- Schwachstellenanalyse.sql (Methoden zur Identifikation von Sicherheitslücken, z. B. Penetrationstests)
- Bedrohungsmodellierung.sql (Analyse potenzieller Angriffsvektoren, z. B. STRIDE-Modell)

### Datenschutz
- Datenschutzgrundsätze.sql (z. B. Rechtmäßigkeit, Zweckbindung, Datenminimierung gemäß DSGVO)
- DSGVO-Anforderungen.sql (EU-Datenschutz-Grundverordnung, Rechte der Betroffenen wie Auskunft und Löschung)
- Betroffenenrechte.sql (Auskunft, Löschung, Berichtigung etc., Rechte der Nutzer gemäß Datenschutzgesetzen)
- Datenschutz-Folgenabschätzung.sql (Risikobewertung bei Datenverarbeitung, z. B. bei neuen Projekten erforderlich)
- Verzeichnis von Verarbeitungstätigkeiten.sql (Dokumentation gemäß DSGVO, Übersicht über Datenverarbeitungsprozesse)

### Schutzziele
- Vertraulichkeit.sql (Schutz vor unbefugtem Zugriff, z. B. durch Verschlüsselung)
- Integrität.sql (Sicherstellung der Datenkorrektheit, z. B. durch Hashfunktionen)
- Verfügbarkeit.sql (Gewährleistung des Zugriffs bei Bedarf, z. B. durch Backup-Strategien)
- Authentizität.sql (Überprüfung der Identität von Nutzern/Systemen, z. B. durch Zertifikate)
- Nachvollziehbarkeit.sql (Protokollierung und Rückverfolgbarkeit von Aktionen, z. B. durch Logging)

### Gesetze und Normen
- DSGVO.sql (Datenschutz-Grundverordnung der EU, rechtliche Basis für Datenschutz)
- BDSG.sql (Bundesdatenschutzgesetz Deutschland, nationale Ergänzung zur DSGVO)
- IT-Sicherheitsgesetz.sql (IT-SiG, Anforderungen an Kritische Infrastrukturen wie Energie oder Gesundheit)
- ISO-27001.sql (Internationaler Standard für Informationssicherheit, Zertifizierung für Sicherheitsmanagement)
- BSI-Grundschutz.sql (BSI-Standards für IT-Sicherheit, Leitfaden für Schutzmaßnahmen)
- TKG.sql (Telekommunikationsgesetz, Datenschutz in der Kommunikation, z. B. für Anbieter)
- TMG.sql (Telemediengesetz, Regelungen für Online-Dienste, z. B. Websites oder Apps)

### Technische und Organisatorische Maßnahmen (TOMs)
#### Technische Maßnahmen
- Verschlüsselung.sql (z. B. AES, TLS – technische Umsetzung für Datensicherheit)
- Zugriffskontrollen.sql (Authentifizierung, Autorisierung, z. B. Passwörter oder Rollen)
- Firewall-Konfiguration.sql (Netzwerksicherheit, Schutz vor externen Angriffen)
- Antivirenprogramme.sql (Schutz vor Malware, z. B. Virenscanner)
- Intrusion-Detection-Systeme.sql (Erkennung von Angriffen, z. B. IDS/IPS)
- Backup-Strategien.sql (Datensicherung und Wiederherstellung, z. B. regelmäßige Sicherungen)
- Hashfunktionen.sql (z. B. SHA-256 – Integritätssicherung, Prüfsummen für Daten)
- Public-Key-Infrastruktur.sql (PKI, Zertifikate für sichere Kommunikation, z. B. SSL/TLS)
- Zwei-Faktor-Authentifizierung.sql (2FA, zusätzliche Sicherheitsebene, z. B. Passwort + SMS)
- Sicherheitsprotokolle.sql (z. B. HTTPS, SSH – sichere Datenübertragung, Netzwerkprotokolle)

#### Organisatorische Maßnahmen
- Sicherheitsrichtlinien.sql (Regeln und Verfahren für Mitarbeiter, z. B. Passwortrichtlinien)
- Schulungen-Mitarbeiter.sql (Sensibilisierung für Sicherheitsrisiken, z. B. Phishing-Schulungen)
- Notfallmanagement.sql (Reaktion auf Sicherheitsvorfälle, z. B. Incident Response Plan)
- Rollen-und-Rechte-Konzept.sql (Verantwortlichkeiten definieren, z. B. Zugriffsrechte festlegen)
- Audits-und-Überprüfungen.sql (Regelmäßige Kontrolle der Maßnahmen, z. B. Sicherheitsprüfungen)

### USV-Arten (Unterbrechungsfreie Stromversorgung)
- Offline-USV.sql (Standby, einfache Absicherung bei Stromausfall, kostengünstig)
- Line-Interactive-USV.sql (Spannungsregulierung, für mittlere Anforderungen, z. B. kleine Server)
- Online-USV.sql (Dauerhafte Stromumwandlung, höchste Sicherheit, z. B. für kritische Systeme)

### Verschlüsselung bei Datentransfair
- Symmetrische-Verschlüsselung.sql (Ein Schlüssel für Ver- und Entschlüsselung, z. B. AES, schnell)
- Asymmetrische-Verschlüsselung.sql (Public und Private Key, z. B. RSA, sicherer Schlüsselaustausch)
- Hybride-Verschlüsselung.sql (Kombination aus symmetrischer und asymmetrischer Verschlüsselung, z. B. TLS, effizient und sicher)

## Reflektieren
- Projektstruktur im Unternehmen präsentieren.sql (Rollen und Verantwortlichkeiten im Team oder Unternehmen definieren)
- Mit Stakeholdern abstimmen und Feedback einholen.sql (Kommunikation mit Beteiligten zur Sicherstellung von Akzeptanz und Anpassung)

## Ressourcen- und Kostenplanung
- Budget kalkulieren.sql (Kosten für Personal, Material und Zeit abschätzen)
- Personal- und Materialbedarf schätzen.sql (Ressourcenbedarf für Projektumsetzung planen)





# Phase 3: Entwickeln
- Git nutzen (Commits, Branches, Merges).sql
- Prinzip der Modularisierung anwenden.sql
## Benutzerschnittstellen
- CLI (textbasiert).sql (Command Line Interface, z. B. für Terminal-basierte Anwendungen)
- GUI (Desktop, Web, Mobile).sql (Graphical User Interface, z. B. Fenster, Webseiten oder Apps)
- Rolle der UI in Softwareprojekten.sql (Bedeutung der Benutzeroberfläche für Usability und Akzeptanz)

## Funktionalität realisieren

### Algorithmen entwerfen und implementieren
- Hashfunktionen (SHA-256).sql (z. B. SHA-256 für Integritätssicherung, Prüfsummenbildung)
- Komprimierungsverfahren (Huffman-Codierung).sql (z. B. Huffman-Codierung für Datenkompression)
- Rekursive Algorithmen.sql (Selbstaufrufende Funktionen, z. B. für Baumdurchläufe)
- Sortierverfahren (Bubble Sort, Quick Sort).sql (z. B. Bubble Sort und Quick Sort für Datenordnung)
- Verschlüsselungsverfahren (AES).sql (z. B. AES für symmetrische Verschlüsselung, Datensicherheit)

## Automatisierung
- CI CD-Pipelines einsetzen.sql (Continuous Integration/Continuous Deployment, z. B. Jenkins, GitLab)
- Skripte zur Prozessautomatisierung erstellen.sql (z. B. Bash- oder Python-Skripte für wiederkehrende Aufgaben)

## Schnittstellen integrieren
- Funktionalität mit Datenbanken realisieren.sql (z. B. SQL-Abfragen für Datenbankanbindung)
- JSON-Dateien exportieren und WebServices nutzen.sql (z. B. REST-APIs für Datenaustausch)

## Programmierung

### Java
### Python
### Web
- Event-Listener und -Handler.sql (z. B. JavaScript für Ereignisverarbeitung, Klicks oder Eingaben)
- UI mit Backend verbinden.sql (z. B. Frontend-Backend-Integration über APIs oder AJAX)

## Programmierung Makro Perspektive
### UML Unified Modelling Language
    #### Prüfungsrelevant
    - Use-Case-Diagramm.sql (Zentral für Anforderungen und Benutzerinteraktionen, z. B. Akteure und Szenarien)
    - Klassendiagramm.sql (Maßgeblich für Klassenstruktur und Beziehungen, z. B. Attribute und Methoden)
    - Sequenzdiagramm.sql (Essenziell für Abläufe und Interaktionen, z. B. Nachrichtenfluss zwischen Objekten)
    - Aktivitätsdiagramm.sql (Nützlich für Prozesse und Workflows, z. B. Ablaufvisualisierung)
    - Zustandsdiagramm.sql (Schlüssel für Zustandswechsel im System, z. B. Zustandsübergänge eines Objekts)
    
    #### nice to have
    - Komponentendiagramm.sql (Praktisch für Systemarchitektur, aber nicht geprüft, z. B. Modulaufteilung)
    - Verteilungsdiagramm.sql (Relevant für Deployment, aber nicht im Fokus, z. B. Hardwarezuordnung)
    - Paketdiagramm.sql (Hilfreich für Modulstruktur, jedoch nicht relevant, z. B. Paketorganisation)
    - Objektidiagramm.sql (Nützlich für Instanzen, aber nicht verlangt, z. B. konkrete Objekte zur Laufzeit)

### Datenbankmodellierungs-Diagramme
- ERM (Entity-Relationship-Modell).sql (Entscheidend für Datenbankmodellierung, konzeptionelle Ebene, z. B. Entitäten und Beziehungen)
- ERD (Entity-Relationship-Diagramm).sql (Maßgeblich für Datenbankimplementierung, visuelle Darstellung des ERM, z. B. Tabellen und Schlüssel)

### Struktur- und Ablaufdiagramme
- Nassi-Shneiderman-Diagramm.sql (Zentral für strukturierte Programmabläufe, z. B. blockbasierte Darstellung)
- Programmablaufplan.sql (Essenziell für Ablaufvisualisierung, auch als Flussdiagramm bekannt, z. B. Entscheidungen und Schleifen)
- Entscheidungstabelle.sql (Schlüssel für logische Entscheidungsfindung, z. B. Bedingungen und Aktionen)
- Struktogramm.sql (Praktisch für hierarchische Programmstruktur, z. B. Top-Down-Darstellung)
- Datenflussdiagramm.sql (Wichtig für Datenfluss und Prozessmodellierung, auch als DFD bekannt, z. B. Datenströme zwischen Prozessen)

### Design-Patterns (Best Practice Lösungen)
#### nice to know
- Abstract Factory-Pattern.sql (Komplexe Objekterstellung, z. B. für plattformunabhängige Systeme)
- Adapter-Pattern.sql (Schnittstellenintegration, z. B. für Legacy-Systeme)
- Command-Pattern.sql (Flexible Befehlsverarbeitung, z. B. Undo-Funktionen)
- Decorator-Pattern.sql (Dynamische Funktionserweiterung, z. B. für UI-Komponenten)
- Factory-Method.sql (Standardisierte Objekterstellung, z. B. für Klassenfamilien)
- Singleton-Pattern.sql (Globale Ressourcensteuerung, z. B. eine einzige Instanz)
- Strategy-Pattern.sql (Algorithmische Flexibilität, z. B. austauschbare Verhalten)
#### Prüfungsrelevant
- MVC (Model-View-Controller).sql (Zentral für UI und Anwendungsstruktur, z. B. Web-Apps)
- Observer-Pattern.sql (Ereignisgesteuerte Systeme, z. B. Benachrichtigungen)



# Phase 4: Testen und Optimieren
- Prinzip der Modularisierung anwenden.sql (Code in unabhängige, wiederverwendbare Module aufteilen)

## Code-Optimierung
- Performance-Tests durchführen.sql (z. B. Laufzeit- und Lasttests zur Geschwindigkeitsverbesserung)
- Ressourcennutzung verbessern.sql (z. B. Speicher- und CPU-Verbrauch optimieren)
- Unittests mit Tools (JUnit, PyTest).sql (z. B. JUnit für Java, PyTest für Python, automatisierte Modultests)

### Benutzeroberfläche verbessern
- Responsives Design.sql (Anpassung der UI an verschiedene Bildschirmgrößen, z. B. CSS Media Queries)
- UI/UX-Optimierungen.sql (Verbesserung von Benutzerfreundlichkeit und Erfahrung, z. B. durch Usability-Tests)

### Clean Code Prinzipien
- Single Responsibility Principle (Ein-Verantwortungs-Prinzip).sql (Entscheidend dafür, dass jede Klasse nur eine Aufgabe übernimmt, z. B. Trennung von Logik und Darstellung)
- Open Closed Principle (Offen Geschlossen-Prinzip).sql (Maßgeblich für Erweiterbarkeit ohne Änderung bestehenden Codes, z. B. durch Interfaces)
- Liskov Substitution Principle (austauschbare Unterklassen ohne Probleme).sql (Schlüssel für austauschbare Unterklassen ohne Probleme, z. B. Vererbung ohne Nebenwirkungen)
- Interface Segregation Principle (Schnittstellentrennungs-Prinzip).sql (Wichtig für schlanke und zweckmäßige Schnittstellen, z. B. Vermeidung von überladenen Interfaces)
- Dependency Inversion Principle (Abhängigkeitsumkehr-Prinzip).sql (Essenziell für Abhängigkeit von Abstraktionen statt Konkretem, z. B. Dependency Injection)
- Keep It Simple, Stupid (KISS - Halte es einfach, Dummkopf).sql (Praktisch für klare und unkomplizierte Lösungen, z. B. Vermeidung unnötiger Komplexität)
- Don’t Repeat Yourself (DRY - Wiederhole dich nicht).sql (Zentral für Vermeidung von Code-Wiederholungen, z. B. durch Funktionen oder Klassen)
- You Aren’t Gonna Need It (YAGNI - Du wirst es nicht brauchen).sql (Nützlich, um überflüssige Features zu verhindern, z. B. nur aktuelle Anforderungen umsetzen)
- Meaningful Names, Small Functions, Sparse Comments (Sinnvolle Namen, kleine Funktionen, sparsame Kommentare).sql (Wichtig für verständliche Bezeichnungen, kompakte Methoden und gezielten Kommentareinsatz, z. B. sprechende Variablennamen)

### Optimierungspotenziale identifizieren
- Qualitätssicherung im Projekt.sql (z. B. Sicherstellung von Standards und Best Practices)
- Schwachstellen erkennen.sql (z. B. Identifikation von Bugs oder ineffizientem Code)
- Verbesserungsvorschläge erarbeiten.sql (z. B. konkrete Maßnahmen zur Code- oder Prozessoptimierung)

## Code-Qualität
- Reviews durchführen.sql (z. B. Code-Reviews durch Teammitglieder zur Fehlerfindung)
- Ressourcennutzung verbessern.sql (z. B. Optimierung von Speicher- und Rechenleistung)
- Schwachstellen erkennen.sql (z. B. Analyse auf Sicherheitslücken oder Performance-Probleme)
- Verbesserungsvorschläge erarbeiten.sql (z. B. Vorschläge für Refactoring oder bessere Algorithmen)

## Testverfahren
- Blackbox- und Whitebox-Tests.sql (Blackbox: Funktionalität ohne Code-Einblick, Whitebox: mit Code-Kenntnis)
- Grenzwerte prüfen.sql (z. B. Tests an den Randbereichen von Eingabewerten)
- Performance-Tests durchführen.sql (z. B. Stress- und Lasttests für Systemstabilität)
- Unit-, Integrations- und Systemtests.sql (Unit: Einzelmodule, Integration: Zusammenspiel, System: Gesamtsystem)
- Unittests mit Tools (JUnit, PyTest).sql (z. B. JUnit für Java, PyTest für Python, automatisierte Tests)



# Phase 5: Abschließen
- Bereitstellungsstrategien (Cloud, Container, Server).sql (Methoden zur Auslieferung, z. B. AWS, Docker, On-Premise)
- Bericht archivieren.sql (Abschlussbericht speichern, z. B. für Nachweis oder Referenz)
- Funktionen präsentieren.sql (Vorstellung der Features, z. B. in einer Demo für Stakeholder)
- Schulungsplanung und -durchführung.sql (Vorbereitung und Durchführung von Trainings, z. B. für Endnutzer oder Admins)
- Software übergeben (Installation, Schulung).sql (Übergabe an Kunden inkl. Setup und Training, z. B. Live-Schaltung)

## Dokumentation

### Benutzerdokumentation
- Bedienungsanleitungen erstellen.sql (Anleitungen für Nutzer, z. B. Schritt-für-Schritt-Anweisungen)
- Support-Dokumente bereitstellen.sql (Materialien für Hilfe bei Problemen, z. B. FAQs oder Handbücher)

### Technische Dokumentation
- Code-Kommentare.sql (Erläuterungen im Quellcode, z. B. für Entwickler zur Wartung)
- Schnittstellenbeschreibungen.sql (Dokumentation von APIs oder Schnittstellen, z. B. Parameter und Rückgabewerte)
- Softwarekomponenten dokumentieren.sql (Beschreibung der Systemteile, z. B. Architekturübersicht)
- Änderungen und Testprotokolle festhalten.sql (Nachverfolgung von Modifikationen und Tests, z. B. für Audits)

## Änderungsprotokolle
- Optimierungen festhalten.sql (Verbesserungen dokumentieren, z. B. Performance-Steigerungen)
- Versionshistorie führen.sql (Änderungen in Versionen nachhalten, z. B. mit Git-Commits oder Changelogs)

## Reflexion
- Ergebnisse bewerten (Ziele, Kundenzufriedenheit).sql (Überprüfung des Erfolgs, z. B. gegen Anforderungen)
- Lessons Learned sammeln.sql (Erfahrungen und Erkenntnisse aufzeichnen, z. B. für zukünftige Projekte)






# Phase 6: Wartung

## Fehleranalyse in Software
- Fehler identifizieren.sql (Bugs oder Abstürze lokalisieren, z. B. durch Log-Analyse)
- Optimierungspotenziale erkennen.sql (Verbesserungsmöglichkeiten finden, z. B. ineffiziente Prozesse)
- Performance und Funktionalität bewerten.sql (Leistung und Features prüfen, z. B. durch Monitoring)


## Support
- Schulungen anbieten.sql (Trainings für Nutzer oder Admins, z. B. zur Bedienung oder Verwaltung)
- Support bei Softwareproblemen.sql (Hilfe bei Nutzeranfragen oder Fehlern, z. B. durch Ticketsysteme)

## Wartung von Anwendungen
- Kompatibilität mit neuen Systemen sicherstellen.sql (Anpassung an neue OS oder Hardware, z. B. Versionsupdates)
- Updates und Patches implementieren.sql (Sicherheits- oder Funktionsupdates einspielen, z. B. Bugfixes)
- Kollaborativ Code pflegen.sql (Teamarbeit an der Codebasis, z. B. über Versionskontrolle wie Git)



# Teamarbeit (Managementmethodik)
- Konfliktmanagement.sql (Lösung von Team- oder Stakeholder-Konflikten, z. B. durch Mediation oder Kommunikation)
- Phasen der Teamentwicklung (Forming, Storming, Norming, Performing).sql (Tuckman-Modell für Teamdynamik, z. B. Entwicklung von Zusammenarbeit)
- Änderungsmanagement.sql (Prozess zur Bewertung und Umsetzung von Änderungen, z. B. Anforderungsänderungen im Projekt)


## Unternehmensorganisationsformen
- Einliniensystem.sql (Hierarchische Struktur mit direkter Weisung, z. B. klassisches Management)
- Mehrliniensystem.sql (Mehrere Weisungslinien, z. B. für spezialisierte Abteilungen)
- Stabstellensystem.sql (Fachliche Unterstützung ohne Weisungsbefugnis, z. B. Beratungsrollen)
- Matrixorganisation.sql (Kombination aus Fach- und Projektverantwortung, z. B. für komplexe Projekte)
- Divisionsorganisation.sql (Aufteilung nach Geschäftsbereichen, z. B. Produktlinien)
- Prozessorganisation.sql (Fokus auf Prozessabläufe, z. B. optimierte Workflows)
- Agile Organisation.sql (Flexible, teamorientierte Struktur, z. B. für schnelle Anpassung)

## Vorgehens- bzw. Entwicklungs-Modelle
### Agile Modelle

#### Extreme Programming (XP)
- Ablauf (User-Stories, Tests schreiben, Code entwickeln, regelmäßig ausliefern und verbessern (Refactoring)).sql (Schrittweise Entwicklung mit Fokus auf Qualität, z. B. iterative Lieferung)
- Praktiken (Pair-Programming, Test-Driven Development (TDD), Häufige releases).sql (Techniken wie Paarprogrammierung und TDD, z. B. für besseren Code)
- Werte (Kommunikation, Einfachheit, Feedback).sql (Grundprinzipien von XP, z. B. enge Zusammenarbeit)

#### Kanban
- Ablauf (visualisieren, priorisieren, kontinuierlich bearbeiten, analysieren, anpassen).sql (Kontinuierlicher Workflow, z. B. für flexible Aufgabenbearbeitung)
- Prinzipien (Visualisierung, Abgrenzung und Optimierung - des Workflows).sql (Grundregeln wie Sichtbarkeit und Begrenzung, z. B. WIP-Limits)
- Werkzeuge (Kanban-Board, WIP-Limits (Work in Progress)).sql (Hilfsmittel wie Boards und Begrenzungen, z. B. für Übersichtlichkeit)

#### Scrum
- Ablauf (Backlog erstellen, Sprint planen, Daily Scrum, Sprint Review, Retrospective).sql (Sprint-basierte Entwicklung, z. B. 2-Wochen-Zyklen)
- Artefakte (das Increment, der Product- und Sprintbacklog).sql (Ergebnisse wie Produktinkrement und Planungsdokumente, z. B. für Transparenz)
- Rollen (Product Owner, Scrum Master, Entwickler).sql (Aufgabenverteilung im Team, z. B. Verantwortlichkeiten)
- Agiles Manifest.sql (Grundwerte und Prinzipien von Agile, z. B. Individuen über Prozesse)

### Hybride Modelle

#### DevOps
- Ablauf (Planen, Entwickeln, Testen, Bereitstellen, Überwachen, Feedback integrieren).sql (Kontinuierlicher Zyklus von Entwicklung und Betrieb, z. B. für schnelle und zuverlässige Softwarebereitstellung)
- Praktiken (Continuous Integration (CI), Continuous Deployment (CD), Infrastruktur als Code (IaC)).sql (Techniken wie automatisiertes Testen und Deployment, z. B. für Effizienz und Skalierbarkeit)
- Prinzipien (Zusammenarbeit, Automatisierung, kontinuierliche Verbesserung).sql (Grundwerte wie Teamübergreifende Kooperation und Prozessoptimierung, z. B. für kürzere Release-Zyklen)

#### Spiralmodell
- Ablauf (Risiken identifizieren, Prototyping, bewerten, nächsten Zyklus planen, fertig stellen).sql (Risikoorientierte Zyklen, z. B. für komplexe Projekte)
- Ausgaben (Prototypen, Risikoberichte, Endprodukt).sql (Ergebnisse jeder Phase, z. B. Dokumentation und Prototypen)
- Zyklen (Risikoanalyse, Prototyping, Bewertung).sql (Wiederholte Schritte mit Risikofokus, z. B. iterative Absicherung)

#### Iterative Entwicklung
- Ablauf (planen, durchführen oder Prototyp entwickeln, Feedback sammeln, verbessern).sql (Wiederholte Zyklen mit Anpassung, z. B. für Prototypen)
- Feedback (Nutzer einbinden, Rückmeldungen sammeln).sql (Nutzerinput für Verbesserungen, z. B. durch Tests)
- Planung (Anforderungen priorisieren, Iterationen festlegen).sql (Strukturierte Vorbereitung der Zyklen, z. B. Priorisierung)
- Verbesserungen (Design und Code optimieren).sql (Fortlaufende Anpassung, z. B. durch Refactoring)

#### Lean Software Development
- Ablauf (wert definieren, Prozesse analysieren, MVP entwickeln, Feedback sammeln, Verbesserungen umsetzen).sql (Fokus auf Wert und Effizienz, z. B. Minimum Viable Product)
- Methoden (Value Stream Mapping, Build-Measure-Learn).sql (Techniken wie Prozessanalyse und Lernzyklen, z. B. für Optimierung)
- Prinzipien (Verschwendung eliminieren, Wert maximieren, schnelle Lieferung).sql (Leitlinien für schlanke Entwicklung, z. B. Effizienzsteigerung)



### Klassische Modelle

#### V-Modell
- Ablauf (Anforderungen Festlegen, System entwerfen, Module entwickeln, testen jeder Ebene, System abnehmen).sql (Strukturierter Ablauf mit Testphasen, z. B. für sicherheitskritische Systeme)
- Dokumentation (Spezifikationen, Abnahmeprotokolle, Testpläne).sql (Umfangreiche Unterlagen, z. B. für Nachvollziehbarkeit)
- Testebenen (Unit-Tests, Integrationstests, Systemtests).sql (Abgestufte Testphasen, z. B. für Qualitätssicherung)

#### Wasserfallmodell
- Ablauf (Anforderungen Festlegen, System entwerfen, Code implementieren, Tests durchführen, Produkt warten).sql (Linearer Ablauf, z. B. für gut definierte Projekte)
- Ergebnisse (Anforderungsspezifikation, Entwurfsdokumente, Testberichte).sql (Dokumentierte Ausgaben jeder Phase, z. B. für Projektabschluss)
- Verantwortlichkeiten (Projektleiter, Entwickler, Tester).sql (Klare Rollenverteilung, z. B. für Aufgabenstruktur)