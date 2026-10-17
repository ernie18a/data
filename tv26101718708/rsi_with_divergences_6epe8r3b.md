# RSI with Divergences

- url: https://www.tradingview.com/script/6Epe8R3b/
- type: indicator
- pine_id: PUB;41e70bf393c74ee39a5e634b4eca52d7
- version: 6.0

## Description

The RSI indicator has been expanded with an additional SMA line, allowing not only for analyzing market strength but also for more easily identifying changes in momentum and potential entry and exit points.

The script includes:

* the main RSI line,
* an RSI-based SMA line that helps smooth out movement and filter market noise,
* automatic detection of regular and hidden divergences.

Regular divergences help identify possible trend reversals, while hidden divergences support the identification of continuations of current movement. This allows the indicator to be used both for detecting market changes and for trend-following trading.

The entire design emphasizes simplicity, readability, and quick signal reading without cluttering the chart with unnecessary elements.

## Source Code

````pine
//@version=6
indicator("RSI PRO", overlay=false)

// --- Ustawienia ---
rsiLen = input.int(14, "Długość RSI", minval=1)
maLen  = input.int(14, "Długość SMA na RSI", minval=1)
src    = input.source(close, "Źródło")

// Poziomy
obLevel   = input.int(70, "Wykupienie (OB)", group="Poziomy")
osLevel   = input.int(30, "Wyprzedanie (OS)", group="Poziomy")

// --- Kolory dla 4 typów dywergencji ---
colRegBull = input.color(color.blue,  "Regularna Wzrostowa (D)", group="Kolory Dywergencji")
colHidBull = input.color(color.lime,   "Ukryta Wzrostowa (H)",    group="Kolory Dywergencji")
colRegBear = input.color(color.red,    "Regularna Spadkowa (D)",  group="Kolory Dywergencji")
colHidBear = input.color(color.orange, "Ukryta Spadkowa (H)",     group="Kolory Dywergencji")

// --- NOWA REGUŁA: Opcja pokazywania na wykresie cenowym (Domyślnie UKRYTA) ---
pokazNaCenie = input.bool(true, "Pokaż dywergencje na wykresie cenowym", group="Ustawienia Wykresu")

// --- Obliczenia ---
rsiValue = ta.rsi(src, rsiLen)
rsiMA    = ta.sma(rsiValue, maLen)

// --- Logika Dywergencji ---
lbR = 5, lbL = 5 
plFound = not na(ta.pivotlow(rsiValue, lbL, lbR))
phFound = not na(ta.pivothigh(rsiValue, lbL, lbR))

prev_pl_rsi   = ta.valuewhen(plFound, rsiValue[lbR], 1)
prev_pl_price = ta.valuewhen(plFound, close[lbR], 1)
prev_pl_index = ta.valuewhen(plFound, bar_index[lbR], 1)

prev_ph_rsi   = ta.valuewhen(phFound, rsiValue[lbR], 1)
prev_ph_price = ta.valuewhen(phFound, close[lbR], 1)
prev_ph_index = ta.valuewhen(phFound, bar_index[lbR], 1)

// Warunki dywergencji
regBull = plFound and close[lbR] < prev_pl_price and rsiValue[lbR] > prev_pl_rsi
hidBull = plFound and close[lbR] > prev_pl_price and rsiValue[lbR] < prev_pl_rsi
regBear = phFound and close[lbR] > prev_ph_price and rsiValue[lbR] < prev_ph_rsi
hidBear = phFound and close[lbR] < prev_ph_price and rsiValue[lbR] > prev_ph_rsi

// --- Rysowanie Linii Dywergencji ---
if regBull
    line.new(prev_pl_index, prev_pl_rsi, bar_index[lbR], rsiValue[lbR], color=colRegBull, width=2)
if hidBull
    line.new(prev_pl_index, prev_pl_rsi, bar_index[lbR], rsiValue[lbR], color=colHidBull, width=2)
if regBear
    line.new(prev_ph_index, prev_ph_rsi, bar_index[lbR], rsiValue[lbR], color=colRegBear, width=2)
if hidBear
    line.new(prev_ph_index, prev_ph_rsi, bar_index[lbR], rsiValue[lbR], color=colHidBear, width=2)

// --- Wizualizacja ---
// Poziom 50
hline(50, "Poziom 50", color=color.new(color.gray, 0), linestyle=hline.style_solid)

// Poziomy 70/30 (domyślnie ukryte w zakładce Styl)
p70 = plot(obLevel, "Poziom 70", color=color.new(color.gray, 0), display=display.none)
p30 = plot(osLevel, "Poziom 30", color=color.new(color.gray, 0), display=display.none)

// Wypełnienie kanału
fill(p70, p30, color=color.new(#2962ff, 90), title="Wypełnienie RSI")

// Główne linie
plot(rsiValue, "RSI", color=#0c3299, linewidth=2)
plot(rsiMA, "RSI SMA", color=#e91e63, linewidth=1)

// Etykiety w oknie wskaźnika (Nienaruszone)
plotshape(regBull, "Reg Bull", shape.labelup, location.bottom, colRegBull, text="D", textcolor=color.white, offset=-lbR)
plotshape(hidBull, "Hid Bull", shape.labelup, location.bottom, colHidBull, text="H", textcolor=color.black, offset=-lbR)
plotshape(regBear, "Reg Bear", shape.labeldown, location.top, colRegBear, text="D", textcolor=color.white, offset=-lbR)
plotshape(hidBear, "Hid Bear", shape.labeldown, location.top, colHidBear, text="H", textcolor=color.black, offset=-lbR)

// --- NOWA REGUŁA: Odzwierciedlenie na wykresie cenowym ---
// Używamy force_overlay=true oraz lokalizacji abovebar/belowbar, aby idealnie sklonować etykiety na cenę.
plotshape(regBull and pokazNaCenie, "Reg Bull na Cenie", shape.labelup, location.belowbar, colRegBull, text="D", textcolor=color.white, offset=-lbR, force_overlay=true)
plotshape(hidBull and pokazNaCenie, "Hid Bull na Cenie", shape.labelup, location.belowbar, colHidBull, text="H", textcolor=color.black, offset=-lbR, force_overlay=true)
plotshape(regBear and pokazNaCenie, "Reg Bear na Cenie", shape.labeldown, location.abovebar, colRegBear, text="D", textcolor=color.white, offset=-lbR, force_overlay=true)
plotshape(hidBear and pokazNaCenie, "Hid Bear na Cenie", shape.labeldown, location.abovebar, colHidBear, text="H", textcolor=color.black, offset=-lbR, force_overlay=true)
````
