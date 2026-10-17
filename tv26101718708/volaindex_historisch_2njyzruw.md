# Vola-Index (Historisch)

- url: https://www.tradingview.com/script/2nJYzRuW/
- type: indicator
- pine_id: PUB;fe15f0e20a59433f8f1a98f429d1a94c
- version: 1.0

## Description

Volatilität, 1. Welche Vola brauchst du aktuell?

Du brauchst immer den Zusammenhang zwischen der weißen Linie und der roten Linie:

    Weiße Linie (Vola Aktuell): Das ist deine ATR-basierte Volatilität. Sie zeigt dir, wie stark der Markt gerade "atmet".

    Rote Linie (Limit): Das ist deine statistische Schwelle (Vola-Basis + Multiplikator).

    Deine Entscheidungshilfe:

        Wenn die weiße Linie über der roten Linie liegt, ist der Markt in einem "Extremzustand" (sehr hohe Volatilität). Das ist der Moment, in dem du besonders vorsichtig sein musst, weil Trends entweder sehr schnell explodieren oder (bei Übertreibung) sofort in sich zusammenbrechen.

        Wenn die weiße Linie niedrig ist (nahe der Basis), ist der Markt in einer "ruhigen" Phase. Das ist oft die Zeit für Seitwärtsstrategien oder den Aufbau von Positionen vor einem Ausbruch.

2. Was bedeuten die 3 Farben (Linien)?

Im Sub-Chart siehst du drei Linien, die dir genau sagen, wo die Reise hingeht:

    Weiße Linie (Vola %): Das ist der aktuelle Wert. Er bewegt sich dynamisch.

    Graue Linie (Basis): Das ist der gleitende Durchschnitt der Volatilität über die letzten 20 Perioden (dein volaBandsLength). Sie zeigt dir das "Normalmaß" der Volatilität für den aktuellen Zeitrahmen an.

    Rote Linie (Limit/Upper Band): Das ist deine Sicherheitslinie. Sie berechnet sich aus Basis + 2.0 * Standardabweichung. Sie markiert den Bereich, in dem der Markt "ungewöhnlich" volatil wird.

3. Was bedeuten die Hintergrundfarben?

In deinem Screenshot sieht man an einigen Stellen dunkelrote, senkrechte Streifen im Hintergrund des Sub-Charts:

    Das ist genau der Moment, in dem die weiße Linie das rote Limit durchbrochen hat.

    Die Bedeutung: Das sind deine "Vola-Alarm-Zonen". Wenn du diese roten Balken siehst, hast du eine Phase von hoher Volatilität. Das ist das visuelle Signal, nach dem du gesucht hast – es ist viel intuitiver als eine Zahl in einer Tabelle, weil du den Verlauf über die Zeit siehst.

Mein Tipp für dein Backtesting:
Schau dir die Stellen an, an denen die weißen Punkte (du hast dort kleine blaue Kreise/Marker auf der weißen Linie) auftauchen und die rote Linie berühren. Wenn du dort in den Hauptchart schaust, wirst du oft sehen, dass genau das die Punkte sind, an denen der Markt entweder einen starken Ausbruch gestartet hat oder an denen eine Trendwende (Reversal) stattfand.

## Source Code

````pine
//@version=6
indicator("Vola-Index (Historisch)", overlay=false) // WICHTIG: overlay=false erstellt einen eigenen Bereich unter dem Chart

// --- Einstellungen ---
atrLength       = input.int(14, title="ATR Zeitraum")
volaBandsLength = input.int(20, title="Durchschnitts-Vola")
multiplierHigh  = input.float(2.0, title="Multiplikator Oberes Limit")

// --- Berechnung ---
atrValue    = ta.atr(atrLength)
volaPercent = (atrValue / close) * 100
volaBasis   = ta.sma(volaPercent, volaBandsLength)
volaDev     = ta.stdev(volaPercent, volaBandsLength)
levelHigh   = volaBasis + (multiplierHigh * volaDev)

// --- Plotting im Sub-Chart ---
// Die Vola-Kurve
plot(volaPercent, title="Vola (%)", color=color.white, linewidth=2)
// Das Limit (als dynamische Linie)
plot(levelHigh, title="Limit", color=color.red, linewidth=1, style=plot.style_linebr)
// Der Durchschnittsbereich
plot(volaBasis, title="Basis", color=color.gray, linewidth=1)

// --- Hintergrund-Färbung bei Extrem-Vola ---
bgcolor(volaPercent >= levelHigh ? color.new(color.red, 85) : na)
````
