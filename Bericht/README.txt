###### Hinzufügen des Pfad ######

Zur Verwendung des CardDetectors empfehlen wir zunächst alle Ordner die Funktionen und Testdatensätze enthalten zum MATLAB-Path hinzuzufuegen. 
So muss bei der späteren Verwendung nicht immer der momentane Ort gewechselt werden.
Das kann entweder durch das Browserfenster "Current Folder" (in der MATLAB-Oberfläche üblicherweise links) geschehen, oder über die "Set Path" Option im HOME-Tab, unter ENVIRONMENT. 
Beim Letzten einfach auf "Add with Subfolders..." klicken und die Location angeben. 
Beim Ersten, den entsprechenden Ordner suchen und im Kontextmenü (Rechtsklick auf Ordner)"Add to Path" -> "Select Folders and Subfolders" auswählen.


###### Verwenden der detectCards-Funktion ######

Dies ist die Hauptfunktion die die gesamte Arbeit übernimmt. 
Es muss verpflichtend der Pfad zum Bild angegeben werden das analysiert werden soll. 
Befindet sich dieses im CurrentFolder, ist dies lediglich der Dateiname (inklusive der file extension). 
Ist das Bild in einem Ordner muss der Pfad dorthin angegeben werden (absolut, wenn er nicht wie oben beschrieben zu MATLAB hinzugefügt wurde). 
Unterstützte Bildformate sind die der MATLAB-Funktion "imread". 

Der Output-Parameter "cards" ist ein cell array in dem die segmentierten Karten (max. 10) als Matrix/Bild gespeichert werden. 
Das "annotIm" ist das annotierte Bild, das am Ende der Ausführung angezeigt wird. 
Hier kann es zusätzlich gespeichert werden.

Optionale Parameter werden nach dem filename-Argument in beliebiger Reihenfolge als String mitgegeben:
'fastMode' - nutzt MATLAB-Funktionen statt der selbst implementierten Methoden und ist dementsprechend performanter.
'showCards' - erzeugt eine neue Figure für jede segmentierte Karte und zeigt diese darin an
'debugMode' - zeigt auf dem annotierten Bild die verwendeten BoundingBoxes des Symbols und des Werts an

Beispiel:
detectCards('Datensatz/Voraussetzungen/Paar.jpg');
detectCards('Koenig.png', 'fastMode');
detectCards('FullHouse.tiff', 'showCards', 'fastMode', 'debugMode');


###### Gesamten Datensatz mit testAll testen ######

Um das Testen zu erleichtern gibt es außerdem die Funktion "testAll" die in einem gegeben Ordner auf alle Dateien "detectCards" anwendet. 
Der Aufruf erfolgt mit folgenden Parametern: detectCards(path, 'fastMode'); Ausgegeben werden also nur die annotierten Bilder.
Der angegebene Pfad muss zu einem Ordner führen in dem die Testbilder enthalten sind und als String übergeben werden.

Beispiel:
testAll('Datensatz/Fehler/');



###### Tipps ######

- wenn der Bildschirm voller Bilder ist, schließt "close all" in der MATLAB sämtliche Figures
- wir raten zum Testen den 'fastMode' zu wählen, da dieser sehr viel schneller ist als der default mode


