# Peak Decoder v1.0

- url: https://www.tradingview.com/script/R8QTUCzF/
- type: indicator
- pine_id: PUB;b677c0f0b6ed4405bb922833a1b82df8
- version: 1.0

## Description

Kurzbeschreibung:

Ein hochentwickelter, strukturbasierter Oszillator, der die relative Position des Preises innerhalb seiner aktuellen Handelsspanne entschlüsselt. 
Das Tool identifiziert vollautomatisch die mathematischen und visuellen Scheitelpunkte (Peaks & Troughs) in den Extremzonen und filtert kurzfristiges Marktrauschen sowie Fehlausbrüche effektiv heraus.

Hauptfunktionen & Funktionsweise:Drei integrierte Sensitivitäts-Modi: 
Über das Einstellungsmenü kann die Reaktivität des Algorithmus fliegend gewechselt werden:

Aggressiv: Extrem schnell, optimiert für das Scalping in kleinsten Zeiteinheiten.
Normal: Die ausgewogene Standard-Einstellung für das klassische Daytrading.
Passiv: Filtert starkes Rauschen heraus, ideal für die übergeordnete Trendbestimmung (HTF).

Intelligenter Bounce- & Wellenfilter: Der Indikator speichert Ausbrüche in den Extremzonen im Zwischenspeicher. Er wartet geduldig, bis eine Bewegung endgültig abgeschlossen ist. Entstehen tiefere Täler oder höhere Hochs innerhalb derselben Phase, wandert das Signal automatisch mit.

Striktes Wechselsystem: Die Logik erzwingt ein sauberes, alternierendes Signalmuster (Top ➔ Bottom ➔ Top). Dadurch werden mehrfache Fehlsignale auf derselben Seite in volatilen Seitwärtsphasen komplett eliminiert.

Präzise visuelle Signale: Bestätigte Wendepunkte werden mit dezenten Kreisen direkt auf der Wellenspitze markiert. Zur besseren Übersicht wird ein fetter Richtungspfeil  horizontal (auf 3 Uhr) daneben platziert.

Anwendung im Trading:Der Oszillator dient als hervorragender Filter zur Bestimmung von Premium- (Überkauft) und Discount-Zonen (Überverkauft) im Rahmen von Smart Money Concepts (SMC) oder klassischen Marktstruktur-Strategien.

Rot (Oben): Potenzielle Erschöpfung der Käufer, Vorbereitung für Short-Setups.
Grün (Unten): Potenzielle Erschöpfung der Verkäufer, Vorbereitung für Long-Setups.

Enthält eine voll integrierte Alarm-Schnittstelle (alert()), die pro Bar-Close einmalig auslöst, sobald ein Peak final bestätigt wurde.

## Source Code

````pine
//@version=6
indicator("Peak Decoder v1.0", overlay=false)

// --- EINSTELLUNGEN (MODI) ---
string modeInput = input.string("Normal", "Modus (Sensitivität)", options=["Aggressiv", "Normal", "Passiv"])

// Kanallinien im Menü anpassbar machen
float upperLine = input.float(-20.0, "Obere Kanallinie")
float lowerLine = input.float(-80.0, "Untere Kanallinie")

// Definition der Perioden-Länge basierend auf dem gewählten Modus
int length = switch modeInput
    "Aggressiv" => 4  
    "Normal"     => 10 
    "Passiv"     => 22 
    => 10

// --- STRUKTUR-LOGIK ---
float highestHigh = ta.highest(high, length)
float lowestLow   = ta.lowest(low, length)

// Robuste Berechnung gegen Division durch Null
float denominator = highestHigh - lowestLow
float oscValue = (denominator > 0) ? (((close - lowestLow) / denominator) * 100) - 100 : -50

// --- VISUALISIERUNG (LAYOUT) ---
// TRICK: Unsichtbare Linien bei 0 und -100 zwingen die Skala in die richtige Höhe
plot(0, "Skala Oben (Unsichtbar)", color=color.new(color.black, 100))
plot(-100, "Skala Unten (Unsichtbar)", color=color.new(color.black, 100))

// Sichtbare Kanallinien zeichnen
plot(upperLine, "Obere Grenze", color=color.new(color.gray, 30), linewidth=2)
plot(lowerLine, "Untere Grenze", color=color.new(color.gray, 30), linewidth=2)

// Oszillator-Linie (Orange wie im Original)
plot(oscValue, "Oszillator Wert", color=color.orange, linewidth=2)

// --- STRIGENTE WECHSEL- & PUFFERLOGIK (STRENGES WECHSELSYSTEM) ---
var int nextSignal = 0 

// Label-IDs im Speicher halten für die dynamische Löschung/Ersetzung
var label lastTopCircle = na
var label lastTopArrow = na
var label lastBotCircle = na
var label lastBotArrow = na

var float currentSeqTop = -105.0
var float currentSeqBot = 5.0

var int peakIndex = na
var float peakValue = na
var bool insideZone = false

bool triggerTop = false
bool triggerBot = false
int drawIndex = na
float drawValue = na

// --- LOGIK FÜR DIE OBERE ZONE (> -20) ---
if oscValue > upperLine
    if not insideZone
        insideZone := true
        peakValue := oscValue
        peakIndex := bar_index
    else
        if oscValue > peakValue
            peakValue := oscValue
            peakIndex := bar_index

if insideZone and oscValue <= upperLine and not na(peakValue) and peakValue > upperLine
    if nextSignal == 0 or nextSignal == 1 or (nextSignal == -1 and peakValue > currentSeqTop)
        triggerTop := true
        drawIndex := peakIndex
        drawValue := peakValue
        currentSeqTop := peakValue
        nextSignal := -1 
    insideZone := false
    peakValue := na
    peakIndex := na

// --- LOGIK FÜR DIE UNTERE ZONE (< -80) ---
if oscValue < lowerLine
    if not insideZone
        insideZone := true
        peakValue := oscValue
        peakIndex := bar_index
    else
        if oscValue < peakValue
            peakValue := oscValue
            peakIndex := bar_index

if insideZone and oscValue >= lowerLine and not na(peakValue) and peakValue < lowerLine
    if nextSignal == 0 or nextSignal == -1 or (nextSignal == 1 and peakValue < currentSeqBot)
        triggerBot := true
        drawIndex := peakIndex
        drawValue := peakValue
        currentSeqBot := peakValue
        nextSignal := 1 
    insideZone := false
    peakValue := na
    peakIndex := na

// --- ERSTELLEN UND ERSETZEN DER LABELS ---
if triggerTop
    if not na(lastTopCircle) and lastTopCircle.get_x() > lastBotCircle.get_x()
        label.delete(lastTopCircle)
        label.delete(lastTopArrow)
    
    lastTopCircle := label.new(x=drawIndex, y=drawValue, text="", color=color.new(color.red, 20), style=label.style_circle, size=size.small)
    // KORREKTUR: Auf +2 Balken Abstand verringert für den perfekten v6-Look
    lastTopArrow  := label.new(x=drawIndex + 2, y=drawValue, text="毁灭", textcolor=color.red, color=color.new(color.black, 100), style=label.style_none, size=size.huge)
    lastTopArrow.set_text("➘")
    
    currentSeqBot := 5.0 
    alert("Oszillator Signal: TOP gebildet!", alert.freq_once_per_bar_close)

if triggerBot
    if not na(lastBotCircle) and lastBotCircle.get_x() > lastTopCircle.get_x()
        label.delete(lastBotCircle)
        label.delete(lastBotArrow)
    
    lastBotCircle := label.new(x=drawIndex, y=drawValue, text="", color=color.new(color.green, 20), style=label.style_circle, size=size.small)
    // KORREKTUR: Auf +2 Balken Abstand verringert für den perfekten v6-Look
    lastBotArrow  := label.new(x=drawIndex + 2, y=drawValue, text="诞生", textcolor=color.green, color=color.new(color.black, 100), style=label.style_none, size=size.huge)
    lastBotArrow.set_text("➚")
    
    currentSeqTop := -105.0 
    alert("Oszillator Signal: TIEF gebildet!", alert.freq_once_per_bar_close)
````
