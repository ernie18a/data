<!-- tradingview-pine-id: PUB;70d7babeed8b4c3296ea28e536cbd249 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Coinbase Premium — Barometer

Source: https://www.tradingview.com/script/ApLYQk7W/

## Description

COINBASE PREMIUM — BAROMETER

WHAT IT DOES

This indicator measures the price difference between Coinbase — the regulated
US exchange where buyers pay in actual dollars — and an offshore reference
exchange quoted in USDT (Binance by default). That spread is a proxy for where
demand is coming from.

    Above zero  →  Coinbase is more expensive. US buyers are paying up.
    Below zero  →  Coinbase is cheaper. Selling pressure sits on the US side.

It is a context tool, not an entry signal. Its value lies in whether the spread
confirms or contradicts what price is doing.

HOW IT IS CALCULATED

    Premium (USD)     =  Coinbase price − reference price
    Premium (percent) =  (Coinbase price − reference price) / reference price × 100

Both exchanges are requested on the timeframe of your chart, with no lookahead.

An optional USDT depeg adjustment converts the reference price into real dollars
via USDT/USD before comparing. This removes the portion of the spread that only
exists because the stablecoin itself is trading off its peg — useful during
periods of stablecoin stress, when a raw spread overstates the actual demand
imbalance.

FEATURES

- Absolute USD or percentage display
- Any symbol pair — works for ETH, SOL or anything listed on both venues
- Optional USDT depeg correction
- Signal moving average (EMA or SMA) to read the trend rather than the noise
- Extreme detection, either adaptive (standard deviation bands) or fixed
  thresholds, with background shading
- Automatic trendlines connecting the last two pivot highs and pivot lows of
  the premium itself, extended right — shows when a premium regime is losing
  momentum before the zero line is crossed
- Markers at every zero crossing
- Info box with the current value, the signal MA and a Z-score
- Six alert conditions: zero crossings in both directions, signal MA crossings,
  and entries into either extreme

HOW TO USE IT

Add it to a daily chart first. The daily is where the reading is cleanest; on
low timeframes the spread becomes noisy and the EMA smoothing input (try 5)
becomes necessary.

Then watch the relationship, not the number:

- Price rising while the premium stays negative — the move is not carried by US
  spot demand. Weaker than it looks.
- Price rising with the premium turning positive — demand and price agree.
- Premium making higher lows while price chops sideways — accumulation building
  under the surface. The automatic trendlines are there to make exactly this
  visible.
- Extremes in either direction tend to mean-revert. They mark exhaustion more
  often than continuation.

NOTES AND LIMITATIONS

Single spikes are noise. The signal is in the trend over days and weeks.

Part of any spread is structural rather than informational: USDT can trade off
its dollar peg, and the two venues differ in fees, liquidity and depth. The
depeg option addresses the first of these; the others remain.

The indicator reads the same on every chart it is applied to, because it pulls
both legs from the symbols set in the inputs rather than from the chart symbol.

This is a market-structure tool for context. It is not financial advice and
makes no claim about future prices.

COINBASE PREMIUM — BAROMETER

WAS ER MACHT

Der Indikator misst die Preisdifferenz zwischen Coinbase — der regulierten
US-Börse, an der in echten Dollar gekauft wird — und einer Offshore-Referenzbörse
in USDT (voreingestellt Binance). Diese Differenz ist ein Näherungsmaß dafür,
woher die Nachfrage gerade kommt.

    Über null   →  Coinbase ist teurer. US-Käufer zahlen auf.
    Unter null  →  Coinbase ist günstiger. Der Verkaufsdruck sitzt in den USA.

Es ist ein Kontextwerkzeug, kein Einstiegssignal. Der Wert liegt darin, ob die
Differenz bestätigt oder widerspricht, was der Preis tut.

BERECHNUNG

    Premium (USD)     =  Coinbase-Preis − Referenzpreis
    Premium (Prozent) =  (Coinbase-Preis − Referenzpreis) / Referenzpreis × 100

Beide Börsen werden auf der Zeiteinheit des Charts abgefragt, ohne Lookahead.

Optional lässt sich der USDT-Depeg herausrechnen: Der Referenzpreis wird über
USDT/USD in echte Dollar umgerechnet, bevor verglichen wird. Das entfernt den
Anteil der Differenz, der nur daher kommt, dass der Stablecoin selbst von seiner
Bindung abweicht.

FUNKTIONEN

- Anzeige in absoluten USD oder in Prozent
- Beliebiges Symbolpaar — funktioniert für ETH, SOL und alles, was an beiden
  Börsen gelistet ist
- Optionale USDT-Depeg-Korrektur
- Signal-MA (EMA oder SMA), um den Trend statt des Rauschens zu lesen
- Extremerkennung wahlweise adaptiv (Standardabweichungsbänder) oder über feste
  Schwellen, mit Hintergrundfärbung
- Automatische Trendlinien auf dem Premium selbst, gezogen zwischen den letzten
  beiden Pivot-Hochs bzw. -Tiefs und nach rechts verlängert — macht sichtbar,
  wenn eine Phase ausläuft, bevor die Nulllinie gekreuzt wird
- Markierungen an jedem Nulldurchgang
- Info-Box mit aktuellem Wert, Signal-MA und Z-Score
- Sechs Alarmbedingungen: Nulldurchgänge in beide Richtungen, MA-Kreuzungen und
  das Erreichen beider Extrembereiche

ANWENDUNG

Zuerst auf dem Tageschart. Dort ist die Ablesung am saubersten; auf kleinen
Zeiteinheiten wird die Differenz verrauscht, dann ist die EMA-Glättung nötig
(Startwert 5).

Dann auf das Verhältnis achten, nicht auf die Zahl:

- Preis steigt, Premium bleibt negativ — die Bewegung wird nicht von US-Spot-
  Nachfrage getragen. Schwächer, als sie aussieht.
- Preis steigt und das Premium dreht ins Positive — Nachfrage und Preis stimmen
  überein.
- Premium bildet höhere Tiefs, während der Preis seitwärts läuft — darunter baut
  sich etwas auf. Genau dafür sind die automatischen Trendlinien da.
- Extreme in beide Richtungen neigen zur Rückkehr zum Mittel. Sie markieren
  häufiger Erschöpfung als Fortsetzung.

HINWEISE UND GRENZEN

Einzelne Ausschläge sind Rauschen. Die Aussage liegt im Verlauf über Tage bis
Wochen.

Ein Teil jeder Differenz ist strukturell und nicht informativ: USDT kann von der
Dollarbindung abweichen, und die beiden Börsen unterscheiden sich in Gebühren,
Liquidität und Markttiefe. Die Depeg-Option adressiert den ersten Punkt, die
übrigen bleiben.

Der Indikator zeigt auf jedem Chart dasselbe, weil er beide Seiten aus den in
den Einstellungen gesetzten Symbolen zieht und nicht aus dem Chartsymbol.

Ein Werkzeug zur Marktstruktur-Einordnung. Keine Anlageberatung und keine
Aussage über künftige Kurse.

---

## Source Code

````pine
//@version=6
// ─────────────────────────────────────────────────────────────────────────────
//  Coinbase Premium — Barometer
//  Preisdifferenz Coinbase (Fiat-USD, US-Nachfrage) vs. Binance (USDT, offshore).
//
//  Lesart:  > 0 = US-Kaufdruck (Rückenwind)   < 0 = US-Verkaufsdruck (Gegenwind)
//  Anzeige in absoluten USD (Voreinstellung) oder in Prozent.
// ─────────────────────────────────────────────────────────────────────────────
indicator("Coinbase Premium — Barometer", shorttitle = "CB Premium", overlay = false, precision = 2)

// ═══ Symbole ═════════════════════════════════════════════════════════════════
gS       = "Symbole"
symCB    = input.symbol("COINBASE:BTCUSD",  "Coinbase (Fiat-USD)", group = gS)
symREF   = input.symbol("BINANCE:BTCUSDT",  "Referenz (USDT)",     group = gS)
useDepeg = input.bool(false, "USDT-Depeg herausrechnen", group = gS,
     tooltip = "Rechnet den Referenzpreis über USDT/USD in echte Dollar um. Entfernt den Anteil der Differenz, der nur daher kommt, dass USDT selbst vom Dollar abweicht.")
symUSDT  = input.symbol("COINBASE:USDTUSD", "USDT/USD",            group = gS)

// ═══ Berechnung ══════════════════════════════════════════════════════════════
gC        = "Berechnung"
mode      = input.string("USD", "Anzeige", options = ["USD", "Prozent"], group = gC)
smoothLen = input.int(0,  "Glättung des Premiums (EMA, 0 = aus)", minval = 0, maxval = 500, group = gC)
maType    = input.string("EMA", "Signal-MA",        options = ["EMA", "SMA"], group = gC)
maLen     = input.int(20, "Signal-MA Länge", minval = 1, group = gC)

// ═══ Extreme ═════════════════════════════════════════════════════════════════
gB       = "Extreme"
extMode  = input.string("Std-Abw.-Bänder", "Methode", options = ["Std-Abw.-Bänder", "Feste Schwellen", "aus"], group = gB)
bandLen  = input.int(100, "Bänder: Länge",           minval = 2,   group = gB)
bandMult = input.float(2.0, "Bänder: Multiplikator", minval = 0.1, step = 0.1, group = gB)
thrUp    = input.float( 100.0, "Feste Schwelle oben",  step = 1, group = gB)
thrDn    = input.float(-100.0, "Feste Schwelle unten", step = 1, group = gB)

// ═══ Trendlinien ═════════════════════════════════════════════════════════════
gT     = "Auto-Trendlinien"
showTL = input.bool(true, "Trendlinien auf dem Premium", group = gT,
     tooltip = "Verbindet automatisch die letzten beiden Pivot-Hochs bzw. -Tiefs des Premiums und verlängert sie nach rechts. Zeigt, ob eine Premium-Phase ausläuft.")
pivLen = input.int(5, "Pivot-Stärke", minval = 1, group = gT)

// ═══ Darstellung ═════════════════════════════════════════════════════════════
gV        = "Darstellung"
style     = input.string("Fläche", "Stil", options = ["Fläche", "Histogramm", "Linie"], group = gV)
colUp     = input.color(#26a69a, "Premium  (Coinbase teurer)",   group = gV)
colDn     = input.color(#ef5350, "Discount (Coinbase billiger)", group = gV)
colSig    = input.color(#ff9800, "Signal-MA",                    group = gV)
showCross = input.bool(true, "Nulldurchgänge markieren", group = gV)
showBg    = input.bool(true, "Hintergrund bei Extremen",  group = gV)
showInfo  = input.bool(true, "Info-Box oben rechts",      group = gV)

// ═══ Datenabruf ══════════════════════════════════════════════════════════════
f_sec(sym) =>
    request.security(sym, timeframe.period, close, barmerge.gaps_off, barmerge.lookahead_off)

pCB     = f_sec(symCB)
pREF    = f_sec(symREF)
usdtRaw = f_sec(symUSDT)

usdt   = useDepeg ? nz(usdtRaw, 1.0) : 1.0
refAdj = pREF * usdt

premAbs = pCB - refAdj
premPct = refAdj != 0 ? (pCB - refAdj) / refAdj * 100 : na

raw  = mode == "USD" ? premAbs : premPct
rawS = ta.ema(raw, math.max(smoothLen, 1))
prem = smoothLen > 0 ? rawS : raw

sigE   = ta.ema(prem, maLen)
sigS   = ta.sma(prem, maLen)
signal = maType == "EMA" ? sigE : sigS

basis = ta.sma(prem, bandLen)
dev   = ta.stdev(prem, bandLen)
upper = basis + bandMult * dev
lower = basis - bandMult * dev
zsc   = dev != 0 ? (prem - basis) / dev : 0.0

useBands = extMode == "Std-Abw.-Bänder"
useThr   = extMode == "Feste Schwellen"

extUp = useBands ? prem > upper : useThr ? prem > thrUp : false
extDn = useBands ? prem < lower : useThr ? prem < thrDn : false

xUp = ta.crossover(prem, 0)
xDn = ta.crossunder(prem, 0)

// ═══ Plots ═══════════════════════════════════════════════════════════════════
barCol = prem >= 0 ? colUp : colDn

plot(style == "Fläche"     ? prem : na, "Premium", color = color.new(barCol, 55), style = plot.style_area)
plot(style == "Histogramm" ? prem : na, "Premium", color = color.new(barCol, 25), style = plot.style_columns)
plot(style == "Linie"      ? prem : na, "Premium", color = barCol, style = plot.style_line, linewidth = 2)

hline(0, "Nulllinie", color = color.new(color.gray, 20), linestyle = hline.style_solid, linewidth = 1)

plot(signal, "Signal-MA", color = colSig, linewidth = 2)

pU = plot(useBands ? upper : useThr ? thrUp : na, "Obere Grenze",  color = color.new(color.gray, 60), linewidth = 1)
pL = plot(useBands ? lower : useThr ? thrDn : na, "Untere Grenze", color = color.new(color.gray, 60), linewidth = 1)
fill(pU, pL, color = color.new(color.gray, 95), title = "Neutralzone")

bgcolor(showBg and extUp ? color.new(colUp, 88) : showBg and extDn ? color.new(colDn, 88) : na, title = "Extrem-Hintergrund")

plotshape(showCross and xUp ? 0 : na, "Wechsel ins Positive", shape.triangleup,   location.absolute, colUp, size = size.tiny)
plotshape(showCross and xDn ? 0 : na, "Wechsel ins Negative", shape.triangledown, location.absolute, colDn, size = size.tiny)

// ═══ Auto-Trendlinien auf dem Premium ════════════════════════════════════════
var float ph1 = na, var int phx1 = na, var float ph2 = na, var int phx2 = na
var float pl1 = na, var int plx1 = na, var float pl2 = na, var int plx2 = na
var line  tlH = na
var line  tlL = na

ph = ta.pivothigh(prem, pivLen, pivLen)
pl = ta.pivotlow(prem,  pivLen, pivLen)

if not na(ph)
    ph2  := ph1
    phx2 := phx1
    ph1  := ph
    phx1 := bar_index - pivLen
    if showTL and not na(ph2)
        line.delete(tlH)
        tlH := line.new(phx2, ph2, phx1, ph1, extend = extend.right, color = color.new(colDn, 30), style = line.style_dashed, width = 1)

if not na(pl)
    pl2  := pl1
    plx2 := plx1
    pl1  := pl
    plx1 := bar_index - pivLen
    if showTL and not na(pl2)
        line.delete(tlL)
        tlL := line.new(plx2, pl2, plx1, pl1, extend = extend.right, color = color.new(colUp, 30), style = line.style_dashed, width = 1)

if not showTL
    line.delete(tlH)
    line.delete(tlL)

// ═══ Info-Box ════════════════════════════════════════════════════════════════
var table info = table.new(position.top_right, 2, 4, border_width = 1)
if showInfo and barstate.islast
    unit = mode == "USD" ? " $" : " %"
    fmt  = mode == "USD" ? "#.##" : "#.###"
    txt  = prem >= 0 ? "PREMIUM" : "DISCOUNT"
    table.cell(info, 0, 0, "Coinbase Premium", text_color = color.gray,  text_size = size.tiny, bgcolor = color.new(color.gray, 92))
    table.cell(info, 1, 0, txt,                text_color = color.white, text_size = size.tiny, bgcolor = color.new(barCol, 20))
    table.cell(info, 0, 1, "Aktuell",   text_color = color.gray, text_size = size.tiny)
    table.cell(info, 1, 1, str.tostring(prem,   fmt) + unit, text_color = barCol,  text_size = size.tiny)
    table.cell(info, 0, 2, "Signal-MA", text_color = color.gray, text_size = size.tiny)
    table.cell(info, 1, 2, str.tostring(signal, fmt) + unit, text_color = colSig,  text_size = size.tiny)
    table.cell(info, 0, 3, "Z-Score",   text_color = color.gray, text_size = size.tiny)
    table.cell(info, 1, 3, str.tostring(zsc, "#.##"),        text_color = color.gray, text_size = size.tiny)

// ═══ Alarme ══════════════════════════════════════════════════════════════════
alertcondition(xUp,                         "Premium dreht positiv",   "Coinbase Premium hat die Nulllinie nach oben gekreuzt – US-Kaufdruck kehrt zurück.")
alertcondition(xDn,                         "Premium dreht negativ",   "Coinbase Premium hat die Nulllinie nach unten gekreuzt – US-Verkaufsdruck.")
alertcondition(ta.crossover(prem, signal),  "Premium über Signal-MA",  "Coinbase Premium kreuzt den Signal-MA nach oben.")
alertcondition(ta.crossunder(prem, signal), "Premium unter Signal-MA", "Coinbase Premium kreuzt den Signal-MA nach unten.")
alertcondition(extUp and not extUp[1],      "Extremes Premium",        "Coinbase Premium im oberen Extrembereich.")
alertcondition(extDn and not extDn[1],      "Extremer Discount",       "Coinbase Premium im unteren Extrembereich.")
````
