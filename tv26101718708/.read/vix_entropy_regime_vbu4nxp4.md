# VIX Entropy Regime

- url: https://www.tradingview.com/script/Vbu4Nxp4/
- type: indicator
- pine_id: PUB;c7e4f8ac03b84743a5a76965aec2fca8
- version: 1.0

## Description

VIX Entropy Regime – Beschreibung

Der VIX Entropy Regime Indikator misst die Unordnung bzw. Informationsdichte in den Bewegungen des Volatilitätsindex (VIX), um Marktphasen in unterschiedliche Regime zu klassifizieren.

Statt nur den absoluten VIX-Wert zu betrachten, analysiert dieser Ansatz die Verteilung der täglichen Veränderungen (Delta) des VIX. Daraus wird mittels Shannon-Entropie ein Wert berechnet, der zeigt, wie strukturiert oder chaotisch sich die Volatilität aktuell verhält.

⚙️ Funktionsweise
VIX-Daten
Es wird der Schlusskurs des VIX verwendet.
Delta-Berechnung
Die tägliche Veränderung (delta) wird berechnet.
Diskretisierung (Buckets)
Die Veränderungen werden in 6 Kategorien eingeteilt:
starke Abfälle
moderate Abfälle
leichte Abfälle
leichte Anstiege
moderate Anstiege
starke Anstiege
Wahrscheinlichkeiten
Für ein Zeitfenster (z. B. 21 Perioden) wird gezählt, wie oft jede Kategorie vorkommt.
Shannon-Entropie
Daraus wird die Entropie berechnet und auf einen Bereich von 0 bis 1 normalisiert:
niedrig = geordnet (Trend)
hoch = chaotisch (Unsicherheit)
📊 Regime-Interpretation

Der Indikator unterteilt den Markt in vier Zustände:

🟢 Trend (Entropy < 0.5)
Strukturierte Bewegungen im VIX
Markt zeigt klare Richtung
Gute Bedingungen für Trendstrategien
🟡 Neutral (0.5 – 0.65)
Übergangsphase
Weniger klare Signale
Vorsicht bei aggressiven Trades
🟠 Instabil (Entropy > 0.65)
Hohe Unordnung im Volatilitätsverhalten
Markt wird unberechenbar
Risiko steigt deutlich
🔴 Danger (Entropy > 0.7 & VIX < 22)
Kritische Kombination:
hohe Entropie (Chaos)
aber noch niedriger VIX
Hinweis auf mögliche plötzliche Volatilitätsausbrüche
Oft Vorläufer von Stressphasen oder Korrekturen
💡 Interpretation & Einsatz
Der Indikator ist kein klassisches Signal-Tool, sondern ein Regime-Filter
Besonders nützlich für:
Positionsgröße steuern
Strategiewechsel (Trend vs. Mean Reversion)
Risiko-Management

👉 Kerngedanke:

Nicht nur wie hoch die Volatilität ist zählt – sondern wie chaotisch sie sich bewegt.

⚠️ Hinweise
Funktioniert am besten in Kombination mit Preis- oder Trendindikatoren
„Danger“-Zone ist ein Frühwarnsignal, kein Timing-Trigger
Unterschiedliche Märkte können leicht angepasste Schwellenwerte erfordern

## Source Code

````pine
//@version=6
indicator("VIX Entropy Regime", overlay=false)

length = input.int(21, "Entropy Window", minval=2)

vix = request.security("CBOE:VIX", timeframe.period, close)
delta = ta.change(vix)

bucket =
     delta < -4 ? 0 :
     delta < -2 ? 1 :
     delta <  0 ? 2 :
     delta <  2 ? 3 :
     delta <  4 ? 4 : 5

f_count(bucket_id) =>
    int count = 0
    for i = 0 to length - 1
        count += bucket[i] == bucket_id ? 1 : 0
    count

f_entropy(p) =>
    p > 0 ? -p * math.log(p) / math.log(2) : 0

p0 = f_count(0) / length
p1 = f_count(1) / length
p2 = f_count(2) / length
p3 = f_count(3) / length
p4 = f_count(4) / length
p5 = f_count(5) / length

H = f_entropy(p0) + f_entropy(p1) + f_entropy(p2) + f_entropy(p3) + f_entropy(p4) + f_entropy(p5)

entropy = H / (math.log(6) / math.log(2))

trend    = entropy < 0.5
neutral  = entropy >= 0.5 and entropy <= 0.65
unstable = entropy > 0.65
danger   = entropy > 0.7 and vix < 22

plot(entropy, title="Entropy", linewidth=2)

hline(0.5,  "Trend",    color=color.green)
hline(0.65, "Instabil", color=color.orange)
hline(0.7,  "Danger",   color=color.red)

bgcolor(
     danger   ? color.new(color.red, 80) :
     unstable ? color.new(color.orange, 85) :
     neutral  ? color.new(color.yellow, 90) :
     trend    ? color.new(color.green, 90) :
     na)
````
