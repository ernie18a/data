# Weinstein NHNL Quality Divergenz

- url: https://www.tradingview.com/script/06Y3K2OY/
- type: indicator
- pine_id: PUB;9bb1d36fc7dc47e5bb6101dca345c313
- version: 1.0

## Description

Der Weg zu echten Makro-Signalen (Qualität über Quantität)
Stan Weinstein handelt keine täglichen oder wöchentlichen Wiggles. Er sucht nach den großen Stage 3 Topbildungen (bzw. Stage 1 Bodenbildungen). Eine Divergenz ist für ihn nur relevant, wenn der Index ein massives neues Hoch macht, die Marktbreite aber spürbar wegbricht.

Um das zu erreichen, habe ich die Logik im Code komplett umgebaut:

Strikte Preis-Verankerung: Das Skript sucht jetzt nur noch nach echten Pivot-Hochs im S&P 500. Erst wenn der Index ein strukturelles Hoch markiert, schaut der Indikator nach, wo die Marktbreite zu diesem Zeitpunkt stand, und vergleicht das mit dem letzten strukturellen Hoch. Das eliminiert das Dauerfeuer.

Längere Zeitfenster: Ich habe die Standardeinstellungen auf Makro-Ebene gehoben. Die Glättung steht jetzt auf 10 Wochen (um das Rauschen zu killen) und der Pivot-Lookback auf 10 Wochen (wir suchen nur noch Hochs, die über 10 Wochen Bestand haben).

## Source Code

````pine
//@version=5
indicator("Weinstein NH-NL Qualitäts-Divergenz", shorttitle="NH-NL Qual Div", overlay=false)

// 1. Eingaben (Makro-Fokus)
prd = input.int(10, title="Pivot Lookback (Wochen)", minval=3, tooltip="Höherer Wert = weniger, aber relevantere Makro-Signale.")
smooth_len = input.int(10, title="Glättung (EMA)", minval=1, tooltip="Nimmt das Rauschen aus der Linie.")

// 2. Datenbezug
nh = request.security("INDEX:HIGN", "W", close)
nl = request.security("INDEX:LOWN", "W", close)

// 3. Oszillator Berechnung
net_nhnl = nz(nh) - nz(nl)
osc = ta.ema(net_nhnl, smooth_len)

// 4. Darstellung
plot(osc, title="NH-NL Histogramm", style=plot.style_histogram, color=osc > 0 ? color.new(color.green, 60) : color.new(color.red, 60), linewidth=3)
plot(osc, title="Signal-Linie", color=color.new(color.blue, 0), linewidth=2)
hline(0, title="Nulllinie", color=color.gray, linestyle=hline.style_dashed)

// 5. Exakte Divergenz-Logik (Qualität über Quantität)
// Wir suchen NUR nach strukturellen Pivot-Punkten im PREIS.
price_ph = ta.pivothigh(close, prd, prd)
price_pl = ta.pivotlow(close, prd, prd)

// Variablen zum Speichern der alten Hochs/Tiefs
var float prev_price_ph = na
var float prev_osc_ph = na
var float prev_price_pl = na
var float prev_osc_pl = na

// Bearische Divergenz (Nur wenn der Preis ein echtes Hoch macht)
if not na(price_ph)
    // Oszillator-Wert exakt am Pivot-Hoch (prd Kerzen zurück)
    current_osc_ph = osc[prd]
    
    if not na(prev_price_ph)
        // Prüfen: Preis macht höheres Hoch, Oszillator macht tieferes Hoch
        if price_ph > prev_price_ph and current_osc_ph < prev_osc_ph and current_osc_ph > 0
            label.new(bar_index - prd, current_osc_ph, text="Bear Div", color=color.red, textcolor=color.white, style=label.style_label_down, size=size.normal)
    
    // Werte für das nächste Mal speichern
    prev_price_ph := price_ph
    prev_osc_ph := current_osc_ph

// Bullische Divergenz (Nur wenn der Preis ein echtes Tief macht)
if not na(price_pl)
    current_osc_pl = osc[prd]
    
    if not na(prev_price_pl)
        if price_pl < prev_price_pl and current_osc_pl > prev_osc_pl and current_osc_pl < 0
            label.new(bar_index - prd, current_osc_pl, text="Bull Div", color=color.green, textcolor=color.white, style=label.style_label_up, size=size.normal)
            
    prev_price_pl := price_pl
    prev_osc_pl := current_osc_pl
````
