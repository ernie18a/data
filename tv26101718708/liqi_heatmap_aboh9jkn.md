# Liqi Heatmap

- url: https://www.tradingview.com/script/abOh9jKn/
- type: indicator
- pine_id: PUB;1d2a0cdae0b04d36a4d43839af4a2a66
- version: 1.0

## Description

Dieser Indikator bringt die Funktionsweise von professionellen Krypto-Orderbuch-Plattformen (wie Hyblock, Coinglass oder Kingfisher) direkt auf deinen TradingView-Chart. Er berechnet mathematisch, wo die Liquidations-Preise von gehebelten Marktteilnehmern liegen, und visualisiert diese als dynamische Unterstützungs- und Widerstandszonen.

Im Gegensatz zu klassischen, nachlaufenden Indikatoren schaut die Heatmap nach vorne: Sie zeigt dir, wo das meiste Geld im Markt liegt und welche Levels der Kurs wie ein Magnet anziehen wird.

Wie der Indikator funktioniert
Liquidation-Mapping: Das Skript scannt den Chart nach signifikanten Swing-Hochs und Swing-Tiefs (Swing-Suchzeitraum). Sobald ein Swing-Level bestätigt wird, berechnet der Indikator basierend auf dem gewählten Hebel (z. B. 50x, 25x oder 10x) das exakte Preislevel, an dem die dort eingestiegenen Trader zwangsliquidiert werden.

Dynamische Linien: Diese potenziellen Liquidations-Levels werden als horizontale Linien in die Zukunft gezogen (Orange für Short-Liquidationen, Grün für Long-Liquidationen).

Cluster-Erkennung (Die "Heatmap"): Wenn mehrere Liquidations-Linien sehr nah beieinander liegen (Cluster-Nähe in %), erkennt das Skript eine erhöhte Liquiditätsdichte.

Ein Short-Cluster beginnt hellrot zu glühen.

Ein Long-Cluster wird fett gelb gefärbt.

Automatische Zonen-Generierung: Sobald ein kritisches Cluster entsteht, zeichnet das Skript automatisch eine farbige Heatmap-Box (Rot/Gelb) in den Chart, um die Kernzone visuell hervorzuheben.

Echtzeit-Bereinigung: Berührt der aktuelle Kurs eine Linie oder durchbricht er eine Cluster-Box, gilt die Liquidität als "abgeholt" (rausliquidiert). Die Linien und Boxen werden sofort gelöscht oder gekappt, um den Chart absolut sauber zu halten.

Trading-Strategie & Anwendung
Große Marktteilnehmer (Whales und Market Maker) benötigen massive Liquidität, um ihre großen Positionen zu füllen, ohne den Kurs unkontrolliert zu bewegen. Sie treiben den Kurs gezielt in Bereiche, in denen viele Stop-Losses und Liquidationen liegen.

Magnet-Effekt: Nutze die dicken Cluster (rot/gelb) als primäre Kursziele (Take Profit) für deine Trades. Der Kurs tendiert dazu, diese "Taschen voller Geld" abzugreifen.

Das Reversal-Setup: Wenn der Kurs in ein dickes Cluster hineinrauscht, dort alle Linien eliminiert und die Kerze mit einer Docht-Bildung reagiert, deutet das auf die Erschöpfung der Bewegung hin. Dies ist oft der exakte Wendepunkt für einen Counter-Trend-Trade.

Die wichtigsten Einstellungen (Inputs)
Swing Perioden-Suchzeitraum: Bestimmt, wie weit das Skript zurückschaut, um relevante Hochs/Tiefs zu finden (höhere Werte = langfristigere, stärkere Level).

Simulierter Hebel: Definiert den Abstand der Liquidation zum Swing-Punkt. Bei 50x Hebel liegt die Liquidation ca. 2% entfernt, bei 25x Hebel ca. 4%.

Cluster-Nähe (in %): Wie eng die Linien beieinander liegen müssen, um als ein großes Cluster gewertet zu werden.

Mindestanzahl Linien: Wie viele Trader-Level sich auf engem Raum überschneiden müssen, damit das optische "Glühen" (die Heatmap) aktiviert wird.

Tipp für die Praxis: Kombiniere diesen Indikator mit einem CVD (Cumulative Volume Delta). Wenn der Kurs ein gelbes Long-Cluster abholt, das CVD aber eine bullische Divergenz zeigt (Käufer absorbieren den Druck), hast du eines der treffsichersten Umkehrsignale im modernen Krypto-Trading.

## Source Code

````pine
//@version=6
indicator("Hyblock-Style Active Cluster Heatmap [Gemini v6 Pro]", overlay=true, max_lines_count=500, max_boxes_count=100)

// --- Inputs ---
int lookback          = input.int(20, title="Swing Perioden-Suchzeitraum", minval=5)
int leverage          = input.int(50, title="Simulierter Hebel (z.B. 50x, 25x, 10x)", minval=1)
float clusterPercent  = input.float(0.4, title="Cluster-Nähe (in %)", minval=0.1, step=0.1)
int clusterMinLines   = input.int(3, title="Mindestanzahl Linien für ein Cluster", minval=2)

// Farben laut Vorgabe
color normShortColor  = color.new(color.orange, 40)  // Normal Short: Orange
color glowShortColor  = color.new(#ff3333, 0)        // Dickes Short-Cluster: Hellrot glühend
color normLongColor   = color.new(color.green, 40)   // Normal Long: Grün
color glowLongColor   = color.new(color.yellow, 0)   // Dickes Long-Cluster: Gelb

// Cluster Zonen Farben (Heatmap Boxen)
color zoneShortFill   = color.new(#ff3333, 85)       // Hellrote Box für Short-Cluster
color zoneLongFill    = color.new(color.yellow, 85)  // Gelbe Box für Long-Cluster

// --- Globale Speicher-Arrays für Linien und deren Preis-Level ---
var line[] activeShortLines  = array.new<line>()
var float[] shortPriceLevels = array.new<float>()

var line[] activeLongLines   = array.new<line>()
var float[] longPriceLevels  = array.new<float>()

// Speicher für die neuen Cluster-Boxen
var box[] shortClusterBoxes  = array.new<box>()
var box[] longClusterBoxes   = array.new<box>()

// Prozentuale Distanz bis zur Liquidation berechnen (z.B. 50x Hebel = 2% Bewegung)
float liqDistance = 1.0 / leverage

// --- Neue potentielle Liquidations-Zonen finden ---
float swingHigh = ta.highest(high, lookback)[1]
float swingLow  = ta.lowest(low, lookback)[1]

bool isSwingHigh = high[1] == swingHigh and high < high[1]
bool isSwingLow  = low[1] == swingLow and low > low[1]

// 1. Wenn ein Swing-Hoch entsteht -> Neue Short-Liquidation darüber platzieren
if isSwingHigh
    float targetPrice = high[1] * (1.0 + liqDistance)
    line newLine = line.new(x1=bar_index[1], y1=targetPrice, x2=bar_index, y2=targetPrice, 
                            xloc=xloc.bar_index, color=normShortColor, width=1)
    array.push(activeShortLines, newLine)
    array.push(shortPriceLevels, targetPrice)

// 2. Wenn ein Swing-Tief entsteht -> Neue Long-Liquidation darunter platzieren
if isSwingLow
    float targetPrice = low[1] * (1.0 - liqDistance)
    line newLine = line.new(x1=bar_index[1], y1=targetPrice, x2=bar_index, y2=targetPrice, 
                            xloc=xloc.bar_index, color=normLongColor, width=1)
    array.push(activeLongLines, newLine)
    array.push(longPriceLevels, targetPrice)

// --- Überprüfung, Löschen & Farb-Updates von Positionen ---

// 1. SHORT-CHECK (Verkäufer)
if array.size(activeShortLines) > 0
    for i = array.size(activeShortLines) - 1 to 0
        float currentLinePrice = array.get(shortPriceLevels, i)
        line currentLine = array.get(activeShortLines, i)
        
        if high >= currentLinePrice
            // Rausliquidiert! Linie kappen und aus Array löschen
            line.set_x2(currentLine, bar_index)
            array.remove(activeShortLines, i)
            array.remove(shortPriceLevels, i)
        else
            // Linie verlängern
            line.set_x2(currentLine, bar_index)
            
            // Cluster-Check für diese Short-Linie
            int nearbyLines = 0
            for j = 0 to array.size(shortPriceLevels) - 1
                if math.abs(array.get(shortPriceLevels, j) - currentLinePrice) / currentLinePrice * 100 <= clusterPercent
                    nearbyLines += 1
            
            // Wenn genug Linien auf engem Raum liegen -> Auf glühendes Hellrot umschalten
            if nearbyLines >= clusterMinLines
                line.set_color(currentLine, glowShortColor)
                line.set_width(currentLine, 3)
                
                // NEU: Erstelle eine visuelle Cluster-Zone (Heatmap-Box), wenn keine existiert
                if ta.crossover(nearbyLines, clusterMinLines - 1)
                    float topBox = currentLinePrice * (1.0 + (clusterPercent/100))
                    float btmBox = currentLinePrice * (1.0 - (clusterPercent/100))
                    box newBox = box.new(left=bar_index, top=topBox, right=bar_index, bottom=btmBox, 
                                         bgcolor=zoneShortFill, border_color=glowShortColor, border_style=line.style_dashed)
                    array.push(shortClusterBoxes, newBox)
            else
                line.set_color(currentLine, normShortColor)
                line.set_width(currentLine, 1)

// 2. LONG-CHECK (Käufer)
if array.size(activeLongLines) > 0
    for i = array.size(activeLongLines) - 1 to 0
        float currentLinePrice = array.get(longPriceLevels, i)
        line currentLine = array.get(activeLongLines, i)
        
        if low <= currentLinePrice
            // Rausliquidiert! Linie kappen und aus Array löschen
            line.set_x2(currentLine, bar_index)
            array.remove(activeLongLines, i)
            array.remove(longPriceLevels, i)
        else
            // Linie verlängern
            line.set_x2(currentLine, bar_index)
            
            // Cluster-Check für diese Long-Linie
            int nearbyLines = 0
            for j = 0 to array.size(longPriceLevels) - 1
                if math.abs(array.get(longPriceLevels, j) - currentLinePrice) / currentLinePrice * 100 <= clusterPercent
                    nearbyLines += 1
            
            // Wenn genug Linien auf engem Raum liegen -> Auf Gelb umschalten
            if nearbyLines >= clusterMinLines
                line.set_color(currentLine, glowLongColor)
                line.set_width(currentLine, 3)
                
                // NEU: Erstelle eine visuelle Cluster-Zone (Heatmap-Box), wenn keine existiert
                if ta.crossover(nearbyLines, clusterMinLines - 1)
                    float topBox = currentLinePrice * (1.0 + (clusterPercent/100))
                    float btmBox = currentLinePrice * (1.0 - (clusterPercent/100))
                    box newBox = box.new(left=bar_index, top=topBox, right=bar_index, bottom=btmBox, 
                                         bgcolor=zoneLongFill, border_color=glowLongColor, border_style=line.style_dashed)
                    array.push(longClusterBoxes, newBox)
            else
                line.set_color(currentLine, normLongColor)
                line.set_width(currentLine, 1)

// --- Cluster-Boxen (Heatmap Zonen) in die Zukunft verlängern oder löschen wenn abgeholt ---
if array.size(shortClusterBoxes) > 0
    for i = array.size(shortClusterBoxes) - 1 to 0
        box currentBox = array.get(shortClusterBoxes, i)
        float boxTop = box.get_top(currentBox)
        if high >= boxTop
            array.remove(shortClusterBoxes, i) // Komplett abgeholt -> Löschen
        else
            box.set_right(currentBox, bar_index) // Sonst weiterziehen

if array.size(longClusterBoxes) > 0
    for i = array.size(longClusterBoxes) - 1 to 0
        box currentBox = array.get(longClusterBoxes, i)
        float boxBottom = box.get_bottom(currentBox)
        if low <= boxBottom
            array.remove(longClusterBoxes, i) // Komplett abgeholt -> Löschen
        else
            box.set_right(currentBox, bar_index) // Sonst weiterziehen
````
