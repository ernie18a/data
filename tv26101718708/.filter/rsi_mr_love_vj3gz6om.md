# RSI Mr. Love

- url: https://www.tradingview.com/script/vj3GZ6oM/
- type: indicator
- pine_id: PUB;7760f224b3f64b79bf00f62d04760145
- version: 1.0

## Description

[b]RSI Mr. Love[/b] is a cleaner, more informative version of the classic RSI. It keeps the standard RSI calculation and adds the context you usually have to piece together from several indicators: a smoothed trend line, adaptive bands, a percentile-based score, and the RSI of higher timeframes, all in one pane.

WHAT MAKES IT DIFFERENT

1. Mr. Love Score (percentile rank)
Instead of judging the RSI only against fixed levels like 70/30, the score shows where the current RSI sits compared to its own recent history (default: last 100 bars), on a scale from 0 to 100. A score of 85 means the RSI is higher than in 85% of the lookback period. This adapts to each market: a volatile coin and a calm blue-chip stock get their own "normal" range.
- Score >= 80: OVERBOUGHT (red)
- Score <= 20: OVERSOLD (blue)
- In between: NEUTRAL (green)

2. Multi-timeframe RSI table
The table shows the RSI of the daily (24H), weekly (W) and monthly (M) timeframes next to the score, so you can see at a glance whether short-term momentum agrees with the bigger picture. All three timeframes can be changed in the settings.

3. Adaptive dotted bands
Red (upper) and green (lower) bands are drawn around the RSI moving average, based on the RSI's own standard deviation. They widen in volatile phases and tighten in quiet ones, which highlights moves that are unusual for the current market environment.

4. Clean, minimal design
White RSI line, yellow moving average, dotted 70/30 zones, no background fills. Only the RSI value is shown on the price scale, so the pane stays readable even when it is small.

HOW TO USE

- Trend: RSI above its yellow average = momentum is improving; below = momentum is fading.
- Extremes: A touch of the red or green band signals an unusually strong move relative to recent volatility. Watch for the RSI turning back inside the band.
- Confirmation: Signals are stronger when the score and the 24H / W / M values point in the same direction. Example: an OVERSOLD score while the weekly RSI is still above 50 can indicate a pullback within an intact uptrend.
- Higher timeframes: On intraday charts (e.g. 1h, 4h, 8h) the 24H row gives you the daily RSI without switching charts.

SETTINGS

- RSI: length (default 14) and source
- Yellow line: type (SMA, EMA, SMMA, WMA) and length
- Bands: length and distance multiplier
- Zones: upper and lower levels (default 70 / 30)
- Table: score lookback, overbought/oversold thresholds, timeframes for each row

NOTES

The RSI calculation is identical to TradingView's built-in RSI. The multi-timeframe values update in real time and are final once the higher-timeframe candle closes. This indicator is a tool for analysis, not a buy or sell recommendation. Always combine it with your own risk management.

## Source Code

````pine
//@version=6
indicator("RSI Mr. Love", shorttitle = "RSI Mr. Love", format = format.price, precision = 2)

// ───────── RSI (gleiche Rechnung wie der TradingView-Standard) ─────────
GRP_R  = "RSI"
rsiLen = input.int(14, "RSI-Länge", minval = 1, group = GRP_R, display = display.none)
rsiSrc = input.source(close, "Quelle", group = GRP_R, display = display.none)

change = ta.change(rsiSrc)
up     = ta.rma(math.max(change, 0), rsiLen)
down   = ta.rma(-math.min(change, 0), rsiLen)
rsi    = down == 0 ? 100 : up == 0 ? 0 : 100 - (100 / (1 + up / down))

// ───────── Gelbe Linie (Durchschnitt des RSI) ─────────
GRP_M  = "Gelbe Linie"
maType = input.string("SMA", "Typ", options = ["SMA", "EMA", "SMMA (RMA)", "WMA"], group = GRP_M, display = display.none)
maLen  = input.int(14, "Länge", minval = 1, group = GRP_M, display = display.none)
rsiMa  = switch maType
    "EMA"        => ta.ema(rsi, maLen)
    "SMMA (RMA)" => ta.rma(rsi, maLen)
    "WMA"        => ta.wma(rsi, maLen)
    => ta.sma(rsi, maLen)

// ───────── Gepunktete Bänder (rot oben, grün unten) ─────────
GRP_B    = "Bänder"
showBand = input.bool(true, "Anzeigen", group = GRP_B, display = display.none)
bandLen  = input.int(20, "Länge", minval = 2, group = GRP_B, display = display.none)
bandMult = input.float(1.5, "Abstand (Faktor)", minval = 0.1, step = 0.1, group = GRP_B, display = display.none)
bandDev  = ta.stdev(rsi, bandLen) * bandMult
upper    = rsiMa + bandDev
lower    = rsiMa - bandDev

// ───────── Zonen ─────────
GRP_Z = "Zonen"
obLvl = input.float(70, "Oben (rot)", group = GRP_Z, display = display.none)
osLvl = input.float(30, "Unten (grün)", group = GRP_Z, display = display.none)
hline(obLvl, "Zone oben", color = color.new(color.red, 40), linestyle = hline.style_dotted, linewidth = 1)
hline(osLvl, "Zone unten", color = color.new(color.green, 40), linestyle = hline.style_dotted, linewidth = 1)

// ───────── Linien zeichnen ─────────
plot(showBand ? upper : na, "Oberes Band", color = color.new(color.red, 25),   linewidth = 1, linestyle = plot.linestyle_dotted, display = display.pane)
plot(showBand ? lower : na, "Unteres Band", color = color.new(color.green, 25), linewidth = 1, linestyle = plot.linestyle_dotted, display = display.pane)
plot(rsiMa, "Gelbe Linie", color = #D9A928, linewidth = 1, display = display.pane)
plot(rsi,   "RSI",         color = color.white, linewidth = 1)

// ───────── Tabelle ─────────
GRP_T     = "Tabelle"
showTable = input.bool(true, "Anzeigen", group = GRP_T, display = display.none)
scoreLen  = input.int(100, "Mr. Love Rückblick (Kerzen)", minval = 10, group = GRP_T, display = display.none)
obScore   = input.float(80, "Ab hier OVERBOUGHT", group = GRP_T, display = display.none)
osScore   = input.float(20, "Ab hier OVERSOLD", group = GRP_T, display = display.none)
tfDay     = input.timeframe("D", "Zeile 24H", group = GRP_T, display = display.none)
tfWeek    = input.timeframe("W", "Zeile W", group = GRP_T, display = display.none)
tfMonth   = input.timeframe("M", "Zeile M", group = GRP_T, display = display.none)

rsiDay   = request.security(syminfo.tickerid, tfDay,   ta.rsi(rsiSrc, rsiLen))
rsiWeek  = request.security(syminfo.tickerid, tfWeek,  ta.rsi(rsiSrc, rsiLen))
rsiMonth = request.security(syminfo.tickerid, tfMonth, ta.rsi(rsiSrc, rsiLen))

xScore  = ta.percentrank(rsi, scoreLen)
xStatus = xScore >= obScore ? "OVERBOUGHT" : xScore <= osScore ? "OVERSOLD" : "NEUTRAL"
xColor  = xScore >= obScore ? #F23645 : xScore <= osScore ? #00BCD4 : #4CAF50

bg  = #131722
brd = color.new(#787B86, 50)
txt = #D1D4DC
var table xTab = table.new(position.top_right, 2, 4, bgcolor = bg, border_color = brd, border_width = 1, frame_color = brd, frame_width = 1)

if showTable and barstate.islast
    table.cell(xTab, 0, 0, "Mr. Love", text_color = txt, text_size = size.tiny, text_halign = text.align_left)
    table.cell(xTab, 1, 0, str.tostring(xScore, "#.0") + " " + xStatus, text_color = xColor, text_size = size.tiny, text_halign = text.align_left)
    table.cell(xTab, 0, 1, "24H", text_color = txt, text_size = size.tiny, text_halign = text.align_left)
    table.cell(xTab, 1, 1, str.tostring(rsiDay, "#.0"), text_color = txt, text_size = size.tiny, text_halign = text.align_right)
    table.cell(xTab, 0, 2, "W", text_color = txt, text_size = size.tiny, text_halign = text.align_left)
    table.cell(xTab, 1, 2, str.tostring(rsiWeek, "#.0"), text_color = txt, text_size = size.tiny, text_halign = text.align_right)
    table.cell(xTab, 0, 3, "M", text_color = txt, text_size = size.tiny, text_halign = text.align_left)
    table.cell(xTab, 1, 3, str.tostring(rsiMonth, "#.0"), text_color = txt, text_size = size.tiny, text_halign = text.align_right)
````
