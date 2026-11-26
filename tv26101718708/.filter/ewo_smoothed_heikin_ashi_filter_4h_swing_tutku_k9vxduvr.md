# EWO + Smoothed Heikin Ashi Filter (4H Swing) TUTKU

- url: https://www.tradingview.com/script/k9vXdUvr/
- type: indicator
- pine_id: PUB;95f3b5ca68ca46c190d77e363f432e17
- version: 1.0

## Description

Kombinierte Signale aus EWO und SMOOTHED HEIKIN ASHI

## Source Code

````pine
//@version=5
// Combined EWO (DGT) + Smoothed Heikin Ashi (SamAccountX) Filter for Swing (4H default)
// Portions adapted from:
//  - "Elliott Wave Oscillator Signals by DGT" © dgtrd  (user-supplied)  [EWO crossover & histogram idea]
//  - "Smoothed Heiken Ashi - SamX" by SamAccountX (MPL 2.0, user-supplied)  [smoothed/double-smoothed HA and color-change logic]
// Please keep attributions per the originals.

// === Indicator header ===
indicator("EWO + Smoothed Heikin Ashi Filter (4H Swing)", overlay=true, timeframe="", timeframe_gaps=true)

// === Inputs ===
grpTF = "Timeframe"
useHTF   = input.bool(true, "Festes HTF verwenden?", group=grpTF)
htf      = input.timeframe("240", "HTF (z. B. 240 = 4h)", group=grpTF, confirm=true)

grpEWO = "EWO (nach DGT)"
useEMA  = input.bool(true, "EWO: Exponential", group=grpEWO)
sigLen  = input.int(5, "Signal: Delay", minval=2, group=grpEWO)
thr     = input.int(13, "Strength Threshold (|EWO|)", minval=0, group=grpEWO)
showHist= input.bool(true, "Histogram unten anzeigen", group=grpEWO)

grpHA = "Smoothed Heikin Ashi (nach SamX)"
haLen1  = input.int(10, "HA Price Smoothing Length", minval=1, maxval=500, group=grpHA)
haType1 = input.string("Exponential", "MA Type", options=["Exponential","Simple","Smoothed","Weighted","Linear","Hull","Arnaud Legoux"], group=grpHA)
doubleHA= input.bool(true, "Double-smoothing aktivieren", group=grpHA)
haLen2  = input.int(10, "Second Smoothing Length", minval=1, maxval=500, group=grpHA)
haType2 = input.string("Exponential", "Second MA Type", options=["Exponential","Simple","Smoothed","Weighted","Linear","Hull","Arnaud Legoux"], group=grpHA)
needStreak = input.int(2, "Min. aufeinanderfolgende HA-Bars in Trendrichtung", minval=1, group=grpHA)

grpSig = "Kombinierte Signale"
confirmClose = input.bool(true, "Nur bei Bar-Schluss signalisieren (empfohlen)", group=grpSig)
plotArrows   = input.bool(true, "Pfeile zeichnen", group=grpSig)

// === Utility ===
var string tfUse = useHTF ? htf : timeframe.period
realTicker = ticker.new(prefix=syminfo.prefix, ticker=syminfo.ticker)

// --- pull real OHLC on chosen TF to avoid HA/other-chart contamination (per SamX idea) ---
o = request.security(realTicker, tfUse, open,  gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
h = request.security(realTicker, tfUse, high,  gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
l = request.security(realTicker, tfUse, low,   gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
c = request.security(realTicker, tfUse, close, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

// === EWO (nach deinem DGT-Script-Setup): prozentuale EMA/SMA-Variante mit Signal ===
// (vgl. DGT: ewo = EMA(5)/EMA(34)-1 in %, Signal = EMA/SMA über ewo)  :contentReference[oaicite:2]{index=2}
ma(src, len, useExp) => useExp ? ta.ema(src, len) : ta.sma(src, len)
ewoRaw = (ma(c, 5, useEMA) / ma(c, 34, useEMA) - 1.0) * 100.0
ewoSig = useEMA ? ta.ema(ewoRaw, sigLen) : ta.sma(ewoRaw, sigLen)
ewoCrossUp   = ta.crossover(ewoRaw, ewoSig)
ewoCrossDown = ta.crossunder(ewoRaw, ewoSig)
ewoStrongLong  = ewoCrossUp   and ewoRaw < -thr
ewoLong         = ewoCrossUp   and ewoRaw >= -thr
ewoStrongShort = ewoCrossDown and ewoRaw >  thr
ewoShort        = ewoCrossDown and ewoRaw <= thr

// === Smoothed Heikin Ashi (nach SamX) – kompaktes Re-Build der Kernlogik ===
// (Smoothed HA + optional Double-Smoothing und Farb-/Richtungslogik)  :contentReference[oaicite:3]{index=3}
smma(src, len) =>
    var float _smma = na
    _smma := na(_smma[1]) ? ta.sma(src, len) : (_smma[1] * (len - 1) + src) / len

getMA(src, len, typ, isDouble) =>
    typ == "Exponential"    ? ta.ema(src, len) :  typ == "Simple"         ? ta.sma(src, len) : typ == "Smoothed"       ? smma(src, len)   : typ == "Weighted"       ? ta.wma(src, len) : typ == "Linear"         ? ta.linreg(src, len, 0) : typ == "Hull"           ? ta.hma(src, len) : ta.alma(src, len, isDouble ? 0.85 : 0.85, isDouble ? 6.0 : 6.0)  // Default ALMA-Params wie im SamX-Script

// 1) Preis glätten
mO1 = getMA(o, haLen1, haType1, false)
mH1 = getMA(h, haLen1, haType1, false)
mL1 = getMA(l, haLen1, haType1, false)
mC1 = getMA(c, haLen1, haType1, false)

// 2) Heikin-Ashi aus den geglätteten Preisen
haC1 = (mO1 + mH1 + mL1 + mC1) / 4.0
var float haO1 = na
haO1 := na(haO1[1]) ? (mO1 + mC1)/2.0 : (haO1[1] + haC1[1]) / 2.0
haH1 = math.max(mH1, math.max(haO1, haC1))
haL1 = math.min(mL1, math.min(haO1, haC1))

// 3) Optional Double-Smoothing auf HA-OHLC
haO = doubleHA ? getMA(haO1, haLen2, haType2, true) : haO1
haC = doubleHA ? getMA(haC1, haLen2, haType2, true) : haC1
haH = doubleHA ? getMA(haH1, haLen2, haType2, true) : haH1
haL = doubleHA ? getMA(haL1, haLen2, haType2, true) : haL1

// 4) Trendrichtung + Streak
haBull = haC > haO
haBear = haC < haO
var int bullStreak = 0
var int bearStreak = 0
bullStreak := haBull ? bullStreak[1] + 1 : 0
bearStreak := haBear ? bearStreak[1] + 1 : 0
haBullOK = bullStreak >= needStreak
haBearOK = bearStreak >= needStreak

// === Kombinierte Signale ===
baseLong  = (ewoStrongLong or ewoLong)   and haBullOK
baseShort = (ewoStrongShort or ewoShort) and haBearOK
// optional Bar-Close-Bestätigung, um Flattern/Repaints bei HTF zu minimieren
longSignal  = confirmClose ? (baseLong  and barstate.isconfirmed) : baseLong
shortSignal = confirmClose ? (baseShort and barstate.isconfirmed) : baseShort

// === Plots ===
plot(ewoRaw, "EWO %", color=ewoRaw >= 0 ? color.new(color.green, 0) : color.new(color.red, 0), style=plot.style_columns)
plot(0, "Zero", color=color.new(color.gray, 70))
plotshape(plotArrows and longSignal,  title="LONG",  style=shape.triangleup,   location=location.belowbar, color=color.new(color.green,0), size=size.tiny, text="EWO↑ + SHA")
plotshape(plotArrows and shortSignal, title="SHORT", style=shape.triangledown, location=location.abovebar, color=color.new(color.red,0),   size=size.tiny, text="EWO↓ + SHA")

// (dezent) HA-Close als Linie färben, damit Trendregime sichtbar ist
haCol = haBull ? color.new(color.green, 80) : haBear ? color.new(color.red, 80) : color.new(color.gray, 85)
plot(haC, "Smoothed HA Close (HTF)", color=haCol, linewidth=1)

// === Alerts ===
alertcondition(longSignal,  title="LONG: EWO x Signal + SHA-Filter",  message="LONG {{ticker}} {{interval}}: EWO cross↑ & Smoothed-HA bull (streak >= )")
alertcondition(shortSignal, title="SHORT: EWO x Signal + SHA-Filter", message="SHORT {{ticker}} {{interval}}: EWO cross↓ & Smoothed-HA bear (streak >= )")

// Hinweis-Check ✓ bei Bar-Schluss
plotchar(barstate.isconfirmed, title="Bar bestätigt", char="✓", location=location.bottom, color=color.new(color.gray,70), size=size.tiny)
````
