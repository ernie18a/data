# Multicator + Sweeps + IFVG + Zone Alerts by Olu777

- url: https://www.tradingview.com/script/x6Xam693-Multicator-Sweeps-IFVG-Zone-Alerts-by-Olu777/
- type: indicator
- pine_id: PUB;a21dc97b663f4e29a8db41b4642a9f7c
- version: 11.0

## Description

Indicator Description

EMA + Liquidity Sweep + IFVG Institutional Trading Assistant

A multi-purpose institutional trading indicator combining:

EMA Trend Framework (13 / 21 / 34) for higher-timeframe directional bias
Liquidity Sweeps to identify stop hunts, buy-side/sell-side liquidity grabs, and institutional reaction zones
Inverse Fair Value Gaps (IFVGs) to detect imbalance reversals and continuation opportunities
Multicator Dashboard (RSI, ATR, volume, MA data, optional overlays) for quick market context
Smart Alerts for execution timing
Core Trading Logic

Designed around an institutional execution model:

HTF Trend
↓
Liquidity Sweep
↓
Displacement
↓
IFVG Formation
↓
Retest
↓
Trade Entry
What It Detects

✅ Higher timeframe trend bias

EMA 13 / 21 / 34 alignment
bullish or bearish market structure

✅ Liquidity Sweeps

buy-side sweeps (highs raided)
sell-side sweeps (lows raided)
extended sweep zones for future retests

✅ Inverse Fair Value Gaps (IFVGs)

IFVG beginning to form
IFVG completion
bullish and bearish imbalance zones

✅ Sweep Zone Retests

alerts when price first touches the top of a sweep box
useful for pullback / continuation entries
Alert Types
Bullish IFVG Beginning
Bearish IFVG Beginning
Bullish IFVG Completed
Bearish IFVG Completed
Bullish Sweep Zone Touched
Bearish Sweep Zone Touched
Recommended Workflow
4H: determine directional bias (EMA stack)
1H: confirm continuation / momentum
15M: execution timeframe for sweeps, IFVGs, and entries
Best Use Case

Optimized for:

Forex scalping & intraday trading
BTCUSD
XAUUSD
USTEC / Nasdaq
Smart Money / institutional-style execution

Best during:

London Open
NY Open
Session volatility expansions
Recommended Strategy
4H bias
+
1H continuation
+
15M liquidity sweep
+
IFVG completion
+
retest
=
trade entry

This indicator is built to help traders identify high-probability institutional setups rather than chasing random momentum or indicator crossovers.

## Source Code

````pine
// This Pine Script® code is subject to the Mozilla Public License 2.0
// Combined: Multicator Table + Liquidity Sweeps + IFVG Alerts + Sweep Zone Touch Alerts
// Original credits: © only_fibonacci, © LuxAlgo
// Modified/combined for unified use

//@version=6
indicator("Multicator + Sweeps + IFVG + Zone Alerts + ZL Table",
     shorttitle="EMA Sweeps IFVG ZL",
     overlay=true,
     max_lines_count=500,
     max_boxes_count=500,
     max_labels_count=500)

//==============================================================================
// MULTICATOR SETTINGS
//==============================================================================

dil = input.string(defval="EN", title="Language", options=["EN", "TR"], group="Multicator Table")
yaziRenk = input.color(defval=color.black, title="Text Color", group="Multicator Table")
multScaleLen = input.int(defval=200, title="Fine Tunning", maxval=300, minval=50, group="Multicator Table")

scaleMax = ta.lowest(multScaleLen)
scaleMin = scaleMax / 2

en = dil == "EN"
fibUst = en ? "Top ( " : "Tepe ( "
fibAlt = en ? "Bottom ( " : "Dip ( "

mobilGoster = input.bool(false, "Is mobile?", group="Multicator Table")
tabloGoster = input.bool(true, "Show Table?", group="Multicator Table")
tabloYonu = input.string(defval="Sağ Üst", title="Table Position", options=["Sağ Üst", "Sağ Alt", "Sağ Orta", "Orta Alt", "Orta Sol"], group="Multicator Table")
tabloBuyukluk = input.string(defval="Tiny", title="Table Size", options=["Tiny", "Küçük", "Orta", "Büyük"], group="Multicator Table")

yon = switch tabloYonu
    "Sağ Üst" => position.top_right
    "Sağ Alt" => position.bottom_right
    "Sağ Orta" => position.middle_right
    "Orta Alt" => position.bottom_center
    "Orta Sol" => position.bottom_left

buyuk = switch tabloBuyukluk
    "Tiny" => size.tiny
    "Küçük" => size.small
    "Orta" => size.normal
    "Büyük" => size.large

var table mobiletablo = table.new(position.bottom_right, 2, 6, border_width=1, border_color=color.new(color.gray, 70), frame_color=color.new(color.gray, 70), frame_width=1)
var table tablo = table.new(yon, 6, 6, border_width=1, border_color=color.new(color.gray, 70), frame_color=color.new(color.gray, 70), frame_width=1)

//==============================================================================
// FIBONACCI
//==============================================================================

fibonacciGoster = input.bool(false, "Show Fibonacci Retracement", group="Fibonacci")
fibonacciExtendRight = input.bool(true, "Fibonacci Extend Right", group="Fibonacci", inline="FG")
fibShowData = input.bool(true, "Fibonacci Show Data", group="Fibonacci", inline="FG")
uzunluk = input.int(233, minval=8, title="Fibonacci Distance", group="Fibonacci")
fibColor = input.color(defval=color.black, title="Fibonacci Color", group="Fibonacci")
fib1 = input.int(defval=618, title="Fib Level 1", group="Fibonacci", maxval=1618)
fib2 = input.int(defval=382, title="Fib Level 2", group="Fibonacci", maxval=1618)
fib3 = input.int(defval=786, title="Fib Level 3", group="Fibonacci", maxval=1618)

fibTepe = ta.highest(uzunluk)
fibDip = ta.lowest(uzunluk)
tepeyeUzaklik = math.abs(ta.highestbars(uzunluk))
dipeUzaklik = math.abs(ta.lowestbars(uzunluk))

if barstate.islast and fibonacciGoster
    fib618 = dipeUzaklik > tepeyeUzaklik ? fibTepe - ((fibTepe - fibDip) * fib1 / 1000) : fibDip + ((fibTepe - fibDip) * fib1 / 1000)
    fib50 = dipeUzaklik > tepeyeUzaklik ? fibTepe - ((fibTepe - fibDip) * 500 / 1000) : fibDip + ((fibTepe - fibDip) * 500 / 1000)
    fib382 = dipeUzaklik > tepeyeUzaklik ? fibTepe - ((fibTepe - fibDip) * fib2 / 1000) : fibDip + ((fibTepe - fibDip) * fib2 / 1000)
    fib786 = dipeUzaklik > tepeyeUzaklik ? fibTepe - ((fibTepe - fibDip) * fib3 / 1000) : fibDip + ((fibTepe - fibDip) * fib3 / 1000)

    line.new(bar_index - tepeyeUzaklik, fibTepe, bar_index + 50, fibTepe, color=fibColor, width=1, extend=fibonacciExtendRight ? extend.right : extend.none)
    line.new(bar_index - dipeUzaklik, fibDip, bar_index + 50, fibDip, color=fibColor, width=1, extend=fibonacciExtendRight ? extend.right : extend.none)
    line.new(bar_index + 10, fib382, bar_index + 50, fib382, color=fibColor, style=line.style_dashed, extend=fibonacciExtendRight ? extend.right : extend.none)
    line.new(bar_index + 10, fib50, bar_index + 50, fib50, color=fibColor, style=line.style_dashed, extend=fibonacciExtendRight ? extend.right : extend.none)
    line.new(bar_index + 10, fib618, bar_index + 50, fib618, color=fibColor, style=line.style_dashed, extend=fibonacciExtendRight ? extend.right : extend.none)
    line.new(bar_index + 10, fib786, bar_index + 50, fib786, color=fibColor, style=line.style_dashed, extend=fibonacciExtendRight ? extend.right : extend.none)

    if fibShowData
        label.new(bar_index + 55, fibTepe, fibUst + str.tostring(math.round_to_mintick(fibTepe)) + " )", style=label.style_none, textcolor=yaziRenk)
        label.new(bar_index + 55, fibDip, fibAlt + str.tostring(math.round_to_mintick(fibDip)) + " )", style=label.style_none, textcolor=yaziRenk)
        label.new(bar_index + 55, fib382, str.tostring(fib2 / 1000) + " ( " + str.tostring(math.round_to_mintick(fib382)) + " )", style=label.style_none, textcolor=yaziRenk)
        label.new(bar_index + 55, fib618, str.tostring(fib1 / 1000) + " ( " + str.tostring(math.round_to_mintick(fib618)) + " )", style=label.style_none, textcolor=yaziRenk)
        label.new(bar_index + 55, fib50, "% 50 ( " + str.tostring(math.round_to_mintick(fib50)) + " )", style=label.style_none, textcolor=yaziRenk)
        label.new(bar_index + 55, fib786, str.tostring(fib3 / 1000) + " ( " + str.tostring(math.round_to_mintick(fib786)) + " )", style=label.style_none, textcolor=yaziRenk)

//==============================================================================
// EMA / SMA SETTINGS
//==============================================================================

ema1 = input.int(defval=13, title="EMA 1", group="MA", inline="E1")
ema1Show = input.bool(defval=true, group="MA", inline="E1", title="")
ema1Color = input.color(defval=color.red, title="EMA1 Color", group="MA")

ema2 = input.int(defval=21, title="EMA 2", group="MA", inline="E2")
ema2Show = input.bool(defval=true, group="MA", inline="E2", title="")
ema2Color = input.color(defval=color.black, title="EMA2 Color", group="MA")

ema3 = input.int(defval=50, title="EMA 3", group="MA", inline="E3")
ema3Show = input.bool(defval=true, group="MA", inline="E3", title="")
ema3Color = input.color(defval=color.blue, title="EMA3 Color", group="MA")

sma1 = input.int(defval=50, title="SMA 1", group="MA", inline="S1")
sma1Show = input.bool(defval=false, group="MA", inline="S1", title="")
sma1Color = input.color(defval=color.black, title="SMA1 Color", group="MA")

sma2 = input.int(defval=100, title="SMA 2", group="MA", inline="S2")
sma2Show = input.bool(defval=false, group="MA", inline="S2", title="")
sma2Color = input.color(defval=color.black, title="SMA2 Color", group="MA")

sma3 = input.int(defval=200, title="SMA 3", group="MA", inline="S3")
sma3Show = input.bool(defval=false, group="MA", inline="S3", title="")
sma3Color = input.color(defval=color.black, title="SMA3 Color", group="MA")

ema50 = ta.ema(close, ema1)
ema100 = ta.ema(close, ema2)
ema200 = ta.ema(close, ema3)
sma50 = ta.sma(close, sma1)
sma100 = ta.sma(close, sma2)
sma200 = ta.sma(close, sma3)

plot(ema1Show ? ema50 : na, color=ema1Color, title="EMA1")
plot(ema2Show ? ema100 : na, color=ema2Color, title="EMA2")
plot(ema3Show ? ema200 : na, color=ema3Color, title="EMA3")
plot(sma1Show ? sma50 : na, color=sma1Color, title="SMA1")
plot(sma2Show ? sma100 : na, color=sma2Color, title="SMA2")
plot(sma3Show ? sma200 : na, color=sma3Color, title="SMA3")

//==============================================================================
// OSCILLATORS / TABLE VALUES
//==============================================================================

textColor = input.color(defval=color.white, title="Oscillator Label Text Color", group="Oscillator Display")

rsiPeriod = input.int(defval=14, title="RSI Period", inline="RSI", group="RSI")
rsiShow = input.bool(defval=true, title="", inline="RSI", group="RSI")
rsiColor = input.color(defval=color.purple, title="RSI Color", group="RSI")
rsi = ta.rsi(close, rsiPeriod)
rsiMaPeriod = input.int(defval=10, title="RSI MA Period", group="RSI")
rsiMa = ta.sma(rsi, rsiMaPeriod)

atrPeriodTable = input.int(defval=14, title="ATR Period", inline="ATR", group="ATR")
atrShow = input.bool(defval=true, title="", inline="ATR", group="ATR")
atrColor = input.color(defval=color.red, title="ATR Color", group="ATR")
atrTable = ta.atr(atrPeriodTable)

momPeriod = input.int(defval=14, title="MOM Period", inline="MOM", group="MOM")
momShow = input.bool(defval=false, title="", inline="MOM", group="MOM")
momColor = input.color(defval=color.orange, title="MOM Color", group="MOM")
mom = ta.mom(close, momPeriod)

lensig = input.int(14, title="ADX Smoothing", minval=1, maxval=50, inline="ADX", group="ADX")
adxShow = input.bool(defval=false, title="", inline="ADX", group="ADX")
[diplus, diminus, adx] = ta.dmi(17, lensig)
adxColor = input.color(defval=color.green, title="ADX Color", group="ADX")

ml = input.int(defval=12, title="MACD Line", inline="MACD", group="MACD")
sl = input.int(defval=26, title="Signal Line", group="MACD")
hl = input.int(defval=9, title="Hist Line", group="MACD")
macdShow = input.bool(defval=false, title="", inline="MACD", group="MACD")
[macdLine, signalLine, histLine] = ta.macd(close, ml, sl, hl)
macdLineColor = input.color(defval=color.blue, title="MACD Line Color", group="MACD")
macdSignalColor = input.color(defval=color.orange, title="MACD Signal Color", group="MACD")

scale(data) =>
    dataMax = ta.highest(data, multScaleLen)
    dataMin = ta.lowest(data, multScaleLen)
    dataMax == dataMin ? na : (data - dataMin) / (dataMax - dataMin) * (scaleMax - scaleMin) + scaleMin

last = 50

if rsiShow
    rS = label.new(bar_index, scale(rsi), text="RSI : " + str.tostring(math.round_to_mintick(rsi)), textcolor=textColor, color=rsiColor)
    label.delete(rS[1])
plot(rsiShow ? scale(rsi) : na, show_last=last, color=rsiColor)
plot(rsiShow ? scale(rsiMa) : na, show_last=last, color=color.black)

if atrShow
    aS = label.new(bar_index - last, scale(atrTable), text="ATR : " + str.tostring(math.round_to_mintick(atrTable)), textcolor=textColor, color=atrColor)
    label.delete(aS[1])
plot(atrShow ? scale(atrTable) : na, show_last=last, offset=-1 * last, color=atrColor)

if momShow
    mS = label.new(bar_index - last * 2, scale(mom), text="MOM : " + str.tostring(math.round_to_mintick(mom)), textcolor=textColor, color=momColor)
    label.delete(mS[1])
plot(momShow ? scale(mom) : na, show_last=last, offset=-2 * last, color=momColor)

if adxShow
    adS = label.new(bar_index - last * 3, scale(adx), text="ADX : " + str.tostring(math.round_to_mintick(adx)), textcolor=textColor, color=adxColor)
    label.delete(adS[1])
plot(adxShow ? scale(adx) : na, show_last=last, offset=-3 * last, color=adxColor)

if macdShow
    mcS = label.new(bar_index - last * 4 - last / 2, math.max(scale(macdLine)[last / 2], scale(signalLine)[last / 2]), text="MACD", textcolor=textColor, color=macdLineColor)
    label.delete(mcS[1])
plot(macdShow ? scale(macdLine) : na, show_last=last, offset=-4 * last, color=macdLineColor)
plot(macdShow ? scale(signalLine) : na, show_last=last, offset=-4 * last, color=macdSignalColor)

//==============================================================================
// OPTIONAL MULTICATOR OVERLAYS
//==============================================================================

sarShow = input.bool(defval=false, title="Show P.SAR", inline="SAR", group="P.SAR")
sarStart = input.float(0.02, group="P.SAR", inline="SAR")
sarIncrement = input.float(0.02, group="P.SAR")
sarMaximum = input.float(0.2, "Max Value", group="P.SAR")
sarOut = ta.sar(sarStart, sarIncrement, sarMaximum)
plot(sarShow ? sarOut : na, "Parabolic SAR", style=plot.style_cross, color=#2962FF)

bbShow = input.bool(defval=false, title="Show Bollinger Bands", inline="BB", group="BB")
bbLength = input.int(20, minval=1, group="BB", inline="BB")
maType = input.string("SMA", "Basis MA Type", options=["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"], group="BB")
src = input(close, title="Source", group="BB")
mult = input.float(2.0, minval=0.001, maxval=50, title="StdDev", group="BB")

ma(source, length, _type) =>
    switch _type
        "SMA" => ta.sma(source, length)
        "EMA" => ta.ema(source, length)
        "SMMA (RMA)" => ta.rma(source, length)
        "WMA" => ta.wma(source, length)
        "VWMA" => ta.vwma(source, length)

basis = ma(src, bbLength, maType)
dev = mult * ta.stdev(src, bbLength)
upper = basis + dev
lower = basis - dev
bbOffset = input.int(0, "Offset", minval=-500, maxval=500, group="BB")
bbP1 = plot(bbShow ? upper : na, "BB Upper", color=#2962FF, offset=bbOffset)
bbP2 = plot(bbShow ? lower : na, "BB Lower", color=#2962FF, offset=bbOffset)
plot(bbShow ? basis : na, "BB Basis", color=#FF6D00, offset=bbOffset)
fill(bbP1, bbP2, title="BB Background", color=bbShow ? color.rgb(33, 150, 243, 90) : na)

ichShow = input.bool(defval=false, group="ICHIMOKU", inline="ICHIMOKU", title="Show Ichimoku")
conversionPeriods = input.int(9, minval=1, title="Conversion Line Length", group="ICHIMOKU")
basePeriods = input.int(26, minval=1, title="Base Line Length", group="ICHIMOKU")
laggingSpan2Periods = input.int(52, minval=1, title="Leading Span B Length", group="ICHIMOKU")
displacement = input.int(26, minval=1, title="Lagging Span", group="ICHIMOKU")

donchian(_len) => math.avg(ta.lowest(_len), ta.highest(_len))
conversionLine = donchian(conversionPeriods)
baseLine = donchian(basePeriods)
leadLine1 = math.avg(conversionLine, baseLine)
leadLine2 = donchian(laggingSpan2Periods)

plot(ichShow ? conversionLine : na, color=#2962FF, title="Ichimoku Conversion")
plot(ichShow ? baseLine : na, color=#B71C1C, title="Ichimoku Base")
plot(ichShow ? close : na, offset=-displacement + 1, color=#43A047, title="Lagging Span")
p1i = plot(ichShow ? leadLine1 : na, offset=displacement - 1, color=#A5D6A7, title="Leading Span A")
p2i = plot(ichShow ? leadLine2 : na, offset=displacement - 1, color=#EF9A9A, title="Leading Span B")
fill(p1i, p2i, color=leadLine1 > leadLine2 ? color.rgb(67, 160, 71, ichShow ? 90 : 100) : color.rgb(244, 67, 54, ichShow ? 90 : 100))

pivotShow = input.bool(defval=false, title="Pivot Labels Show", group="Pivot Labels")
leftLenH = input.int(title="Pivot High Left", defval=10, minval=1, group="Pivot Labels")
rightLenH = input.int(title="Pivot High Right", defval=10, minval=1, group="Pivot Labels")
leftLenL = input.int(title="Pivot Low Left", defval=10, minval=1, group="Pivot Labels")
rightLenL = input.int(title="Pivot Low Right", defval=10, minval=1, group="Pivot Labels")
textColorH = input.color(title="Pivot High Text", defval=color.black, group="Pivot Labels")
labelColorH = input.color(title="Pivot High Label", defval=color.white, group="Pivot Labels")
textColorL = input.color(title="Pivot Low Text", defval=color.black, group="Pivot Labels")
labelColorL = input.color(title="Pivot Low Label", defval=color.white, group="Pivot Labels")

phPivotLabel = ta.pivothigh(leftLenH, rightLenH)
plPivotLabel = ta.pivotlow(leftLenL, rightLenL)

drawLabel(_offset, _pivot, _style, _color, _textColor) =>
    if not na(_pivot)
        label.new(bar_index[_offset], _pivot, str.tostring(_pivot, format.mintick), style=_style, color=_color, textcolor=_textColor)

if pivotShow
    drawLabel(rightLenH, phPivotLabel, label.style_label_down, labelColorH, textColorH)
    drawLabel(rightLenL, plPivotLabel, label.style_label_up, labelColorL, textColorL)

//==============================================================================
// MULTICATOR TABLE
//==============================================================================

hacim = volume
acilis = open
kapanis = close
fark = (ta.change(close) / close[1]) * 100

// Robust Multicator table rendering.
// Fix: prior mobile branch used "mobilGoster and not tabloGoster", so if "Is mobile?" was ON
// together with "Show Table?" ON, no multicator table could render.
// Also clears stale cells when switching desktop/mobile or hiding the table.
f_clearMulticatorTables() =>
    table.clear(tablo, 0, 0, 5, 5)
    table.clear(mobiletablo, 0, 0, 1, 5)

if barstate.islast
    f_clearMulticatorTables()

    if tabloGoster and not mobilGoster
        table.cell(tablo, 0, 0, bgcolor=color.black, text_color=color.white, text="Open", text_size=buyuk)
        table.cell(tablo, 1, 0, bgcolor=color.black, text_color=color.white, text="Close", text_size=buyuk)
        table.cell(tablo, 2, 0, bgcolor=color.black, text_color=color.white, text="Change %", text_size=buyuk)
        table.cell(tablo, 3, 0, bgcolor=color.black, text_color=color.white, text="RSI", text_size=buyuk)
        table.cell(tablo, 4, 0, bgcolor=color.black, text_color=color.white, text="ATR", text_size=buyuk)
        table.cell(tablo, 5, 0, bgcolor=color.black, text_color=color.white, text="Volume", text_size=buyuk)

        table.cell(tablo, 0, 1, bgcolor=color.black, text_color=color.white, text=str.tostring(acilis), text_size=buyuk)
        table.cell(tablo, 1, 1, bgcolor=color.black, text_color=color.white, text=str.tostring(kapanis), text_size=buyuk)
        table.cell(tablo, 2, 1, bgcolor=fark > 0 ? color.green : color.red, text_color=color.white, text=str.tostring(math.round_to_mintick(fark)) + " %", text_size=buyuk)
        table.cell(tablo, 3, 1, bgcolor=rsi > 70 ? color.green : rsi < 30 ? color.red : color.teal, text_color=color.white, text=str.tostring(math.round_to_mintick(rsi)), text_size=buyuk)
        table.cell(tablo, 4, 1, bgcolor=color.black, text_color=color.white, text=str.tostring(math.round_to_mintick(atrTable)), text_size=buyuk)
        table.cell(tablo, 5, 1, bgcolor=color.black, text_color=color.white, text=str.tostring(hacim), text_size=buyuk)

        table.cell(tablo, 0, 2, bgcolor=color.gray, text_color=color.white, text="SMA" + str.tostring(sma1), text_size=buyuk)
        table.cell(tablo, 1, 2, bgcolor=color.gray, text_color=color.white, text="SMA" + str.tostring(sma2), text_size=buyuk)
        table.cell(tablo, 2, 2, bgcolor=color.gray, text_color=color.white, text="SMA" + str.tostring(sma3), text_size=buyuk)
        table.cell(tablo, 3, 2, bgcolor=color.gray, text_color=color.white, text="EMA" + str.tostring(ema1), text_size=buyuk)
        table.cell(tablo, 4, 2, bgcolor=color.gray, text_color=color.white, text="EMA" + str.tostring(ema2), text_size=buyuk)
        table.cell(tablo, 5, 2, bgcolor=color.gray, text_color=color.white, text="EMA" + str.tostring(ema3), text_size=buyuk)

        table.cell(tablo, 0, 3, bgcolor=sma50 > close ? color.red : color.green, text_color=color.white, text=str.tostring(math.round_to_mintick(sma50)), text_size=buyuk)
        table.cell(tablo, 1, 3, bgcolor=sma100 > close ? color.red : color.green, text_color=color.white, text=str.tostring(math.round_to_mintick(sma100)), text_size=buyuk)
        table.cell(tablo, 2, 3, bgcolor=sma200 > close ? color.red : color.green, text_color=color.white, text=str.tostring(math.round_to_mintick(sma200)), text_size=buyuk)
        table.cell(tablo, 3, 3, bgcolor=ema50 > close ? color.red : color.green, text_color=color.white, text=str.tostring(math.round_to_mintick(ema50)), text_size=buyuk)
        table.cell(tablo, 4, 3, bgcolor=ema100 > close ? color.red : color.green, text_color=color.white, text=str.tostring(math.round_to_mintick(ema100)), text_size=buyuk)
        table.cell(tablo, 5, 3, bgcolor=ema200 > close ? color.red : color.green, text_color=color.white, text=str.tostring(math.round_to_mintick(ema200)), text_size=buyuk)

    if tabloGoster and mobilGoster
        table.cell(mobiletablo, 0, 0, bgcolor=color.black, text_color=color.white, text="Open", text_size=buyuk)
        table.cell(mobiletablo, 0, 1, bgcolor=color.black, text_color=color.white, text="Close", text_size=buyuk)
        table.cell(mobiletablo, 0, 2, bgcolor=color.black, text_color=color.white, text="Change %", text_size=buyuk)
        table.cell(mobiletablo, 0, 3, bgcolor=color.black, text_color=color.white, text="RSI", text_size=buyuk)
        table.cell(mobiletablo, 0, 4, bgcolor=color.black, text_color=color.white, text="ATR", text_size=buyuk)
        table.cell(mobiletablo, 0, 5, bgcolor=color.black, text_color=color.white, text="Volume", text_size=buyuk)

        table.cell(mobiletablo, 1, 0, bgcolor=color.black, text_color=color.white, text=str.tostring(acilis), text_size=buyuk)
        table.cell(mobiletablo, 1, 1, bgcolor=color.black, text_color=color.white, text=str.tostring(kapanis), text_size=buyuk)
        table.cell(mobiletablo, 1, 2, bgcolor=fark > 0 ? color.green : color.red, text_color=color.white, text=str.tostring(math.round_to_mintick(fark)) + " %", text_size=buyuk)
        table.cell(mobiletablo, 1, 3, bgcolor=rsi > 70 ? color.green : rsi < 30 ? color.red : color.teal, text_color=color.white, text=str.tostring(math.round_to_mintick(rsi)), text_size=buyuk)
        table.cell(mobiletablo, 1, 4, bgcolor=color.black, text_color=color.white, text=str.tostring(math.round_to_mintick(atrTable)), text_size=buyuk)
        table.cell(mobiletablo, 1, 5, bgcolor=color.black, text_color=color.white, text=str.tostring(hacim), text_size=buyuk)


//==============================================================================
// ZERO LAG MTF SIGNAL TABLE
//==============================================================================

showZltTable = input.bool(true, "Show Zero Lag MTF Table", group="Zero Lag MTF Table")
zltLength = input.int(70, "Zero Lag Length", group="Zero Lag MTF Table")
zltMult = input.float(1.2, "Band Multiplier", group="Zero Lag MTF Table")

zltT1 = input.timeframe("5", "Time Frame 1", group="Zero Lag MTF Table")
zltT2 = input.timeframe("15", "Time Frame 2", group="Zero Lag MTF Table")
zltT3 = input.timeframe("60", "Time Frame 3", group="Zero Lag MTF Table")
zltT4 = input.timeframe("240", "Time Frame 4", group="Zero Lag MTF Table")
zltT5 = input.timeframe("1D", "Time Frame 5", group="Zero Lag MTF Table")

zltBullColor = input.color(#00ffbb, "Bullish Color", group="Zero Lag MTF Table")
zltBearColor = input.color(#ff1100, "Bearish Color", group="Zero Lag MTF Table")

zltTablePosition = input.string(
     "Middle Bottom",
     "Table Position",
     options=["Top Right", "Middle Right", "Bottom Right", "Middle Bottom", "Top Left", "Bottom Left"],
     group="Zero Lag MTF Table")

zltTableSize = input.string(
     "Tiny",
     "Table Size",
     options=["Tiny", "Small", "Normal"],
     group="Zero Lag MTF Table")

zltTablePos = switch zltTablePosition
    "Top Right" => position.top_right
    "Middle Right" => position.middle_right
    "Bottom Right" => position.bottom_right
    "Middle Bottom" => position.bottom_center
    "Top Left" => position.top_left
    "Bottom Left" => position.bottom_left

zltTextSize = switch zltTableSize
    "Tiny" => size.tiny
    "Small" => size.small
    "Normal" => size.normal

zltCalcTrend() =>
    zltLag = math.floor((zltLength - 1) / 2)
    zltBasis = ta.ema(close + (close - close[zltLag]), zltLength)
    zltVolatility = ta.highest(ta.atr(zltLength), zltLength * 3) * zltMult

    var int zltTrend = 0

    if ta.crossover(close, zltBasis + zltVolatility)
        zltTrend := 1

    if ta.crossunder(close, zltBasis - zltVolatility)
        zltTrend := -1

    zltTrend

zltS1 = request.security(syminfo.tickerid, zltT1, zltCalcTrend())
zltS2 = request.security(syminfo.tickerid, zltT2, zltCalcTrend())
zltS3 = request.security(syminfo.tickerid, zltT3, zltCalcTrend())
zltS4 = request.security(syminfo.tickerid, zltT4, zltCalcTrend())
zltS5 = request.security(syminfo.tickerid, zltT5, zltCalcTrend())

zltS1Text = zltS1 == 1 ? "Bullish" : "Bearish"
zltS2Text = zltS2 == 1 ? "Bullish" : "Bearish"
zltS3Text = zltS3 == 1 ? "Bullish" : "Bearish"
zltS4Text = zltS4 == 1 ? "Bullish" : "Bearish"
zltS5Text = zltS5 == 1 ? "Bullish" : "Bearish"

var table zltTable = table.new(
     position=zltTablePos,
     columns=2,
     rows=8,
     bgcolor=chart.bg_color,
     border_width=1,
     border_color=color.new(chart.fg_color, 70),
     frame_color=color.new(chart.fg_color, 70),
     frame_width=1)

if barstate.islast and showZltTable
    table.cell(zltTable, column=0, row=0, text="Time Frame", text_halign=text.align_center, text_color=chart.fg_color, text_size=zltTextSize)
    table.cell(zltTable, column=1, row=0, text="Signal", text_halign=text.align_center, text_color=chart.fg_color, text_size=zltTextSize)

    table.cell(zltTable, column=0, row=1, text=zltT1, text_halign=text.align_center, text_color=chart.fg_color, text_size=zltTextSize)
    table.cell(zltTable, column=1, row=1, text=zltS1Text, text_halign=text.align_center, text_color=chart.fg_color, bgcolor=zltS1 == 1 ? color.new(zltBullColor, 70) : color.new(zltBearColor, 70), text_size=zltTextSize)

    table.cell(zltTable, column=0, row=2, text=zltT2, text_halign=text.align_center, text_color=chart.fg_color, text_size=zltTextSize)
    table.cell(zltTable, column=1, row=2, text=zltS2Text, text_halign=text.align_center, text_color=chart.fg_color, bgcolor=zltS2 == 1 ? color.new(zltBullColor, 70) : color.new(zltBearColor, 70), text_size=zltTextSize)

    table.cell(zltTable, column=0, row=3, text=zltT3, text_halign=text.align_center, text_color=chart.fg_color, text_size=zltTextSize)
    table.cell(zltTable, column=1, row=3, text=zltS3Text, text_halign=text.align_center, text_color=chart.fg_color, bgcolor=zltS3 == 1 ? color.new(zltBullColor, 70) : color.new(zltBearColor, 70), text_size=zltTextSize)

    table.cell(zltTable, column=0, row=4, text=zltT4, text_halign=text.align_center, text_color=chart.fg_color, text_size=zltTextSize)
    table.cell(zltTable, column=1, row=4, text=zltS4Text, text_halign=text.align_center, text_color=chart.fg_color, bgcolor=zltS4 == 1 ? color.new(zltBullColor, 70) : color.new(zltBearColor, 70), text_size=zltTextSize)

    table.cell(zltTable, column=0, row=5, text=zltT5, text_halign=text.align_center, text_color=chart.fg_color, text_size=zltTextSize)
    table.cell(zltTable, column=1, row=5, text=zltS5Text, text_halign=text.align_center, text_color=chart.fg_color, bgcolor=zltS5 == 1 ? color.new(zltBullColor, 70) : color.new(zltBearColor, 70), text_size=zltTextSize)

if barstate.islast and not showZltTable
    table.clear(zltTable, 0, 0, 1, 7)

//==============================================================================
// LIQUIDITY SWEEPS + IFVG SETTINGS
//==============================================================================

sweepLen = input.int(5, "Swings", minval=1, group="Liquidity Sweeps")
sweepOpt = input.string("Wicks + Outbreaks & Retest", "Sweep Options", options=["Only Wicks", "Only Outbreaks & Retest", "Wicks + Outbreaks & Retest"], group="Liquidity Sweeps")

colBl = input.color(#ffeb3b, "Bullish Sweep", group="Liquidity Sweeps", inline="c1")
colBr = input.color(#9c27b0, "Bearish Sweep", group="Liquidity Sweeps", inline="c2")
colBl2 = input.color(#ffeb3b80, "", group="Liquidity Sweeps", inline="c1")
colBr2 = input.color(#9c27b080, "", group="Liquidity Sweeps", inline="c2")

extendSweeps = input.bool(true, "Extend Sweep Areas", group="Sweep Area")
maxB = input.int(300, "Max Bars to Extend", minval=1, maxval=5000, group="Sweep Area")
colBl3 = input.color(#ffeb3b41, "Bull Area Color", group="Sweep Area")
colBr3 = input.color(#9c27b041, "Bear Area Color", group="Sweep Area")

showIfvg = input.bool(true, "Show Inverse FVGs", group="IFVG Settings")
volFilter = input.float(0.6, "Volatility Filter Multiplier", minval=0, step=0.1, group="IFVG Settings")
ifvgBullCol = input.color(color.new(#089981, 85), "IFVG Bullish Color", group="IFVG Settings")
ifvgBearCol = input.color(color.new(#f23645, 85), "IFVG Bearish Color", group="IFVG Settings")
maxIfvgDisplay = input.int(3, "Max Displayed IFVGs", minval=1, group="IFVG Settings")

//==============================================================================
// MULTI-TIMEFRAME FVG SETTINGS
//==============================================================================

showMtfFvgs = input.bool(true, "Show MTF FVGs", group="MTF FVGs")
showMtf3m = input.bool(false, "Show 3m FVG", group="MTF FVGs")
showMtf5m = input.bool(true, "Show 5m FVG", group="MTF FVGs")
showMtf30m = input.bool(true, "Show 30m FVG", group="MTF FVGs")
showMtf1h = input.bool(true, "Show 1H FVG", group="MTF FVGs")
showMtf4h = input.bool(true, "Show 4H FVG", group="MTF FVGs")
mtfFvgAtrLen = input.int(14, "MTF FVG ATR Length", minval=1, group="MTF FVGs")
mtfFvgMinAtr = input.float(0.6, "MTF FVG Min Size x ATR", minval=0.0, step=0.1, group="MTF FVGs")
mtfFvgExtend = input.int(12, "MTF FVG Extend Bars", minval=1, maxval=100, group="MTF FVGs")
mtfBullFvgCol = input.color(color.new(#089981, 88), "MTF Bullish FVG", group="MTF FVGs")
mtfBearFvgCol = input.color(color.new(#f23645, 88), "MTF Bearish FVG", group="MTF FVGs")

alertSweeps = input.bool(false, "Enable Original Sweep Formation Alerts", group="Alert Settings")
alertIfvgs = input.bool(true, "Enable IFVG Alerts", group="Alert Settings")
alertSweepTouches = input.bool(true, "Enable Sweep Zone Touch Alerts", group="Alert Settings")

//==============================================================================
// CISD SETTINGS
//==============================================================================

showCisd = input.bool(true, "Show CISD", group="CISD")
cisdRequireSweep = input.bool(true, "Require Sweep First", group="CISD")
cisdRequireFailure = input.bool(true, "Require Displacement Failure", group="CISD")
cisdValidBars = input.int(20, "CISD Valid Bars", minval=1, maxval=200, group="CISD")
showCisdTableRows = input.bool(true, "Show CISD Table Rows", group="CISD")
alertCisd = input.bool(true, "Enable CISD Alerts", group="CISD")
bullCisdCol = input.color(color.new(#00b894, 0), "BCISD Line Color", group="CISD")
bearCisdCol = input.color(color.new(#f23645, 0), "SCISD Line Color", group="CISD")


//==============================================================================
// DYNAMIC SUPPORT / RESISTANCE ZONES SETTINGS
//==============================================================================

showDynSR = input.bool(true, "Show Dynamic Support / Resistance Zones", group="Dynamic S/R")
srSwingLen = input.int(10, "Swing Length", minval=2, maxval=50, group="Dynamic S/R")
srAtrLen = input.int(14, "S/R ATR Length", minval=1, group="Dynamic S/R")
srZoneAtrMult = input.float(0.25, "Zone Width x ATR", minval=0.05, step=0.05, group="Dynamic S/R")
srMergeAtrMult = input.float(0.35, "Merge Nearby Zones x ATR", minval=0.05, step=0.05, group="Dynamic S/R")
srExtendBars = input.int(80, "Extend Zone Bars", minval=5, maxval=500, group="Dynamic S/R")
srMaxSupport = input.int(3, "Max Support Zones", minval=1, maxval=10, group="Dynamic S/R")
srMaxResistance = input.int(3, "Max Resistance Zones", minval=1, maxval=10, group="Dynamic S/R")
srShowLabels = input.bool(true, "Show S/R Labels", group="Dynamic S/R")
srShowOnlyNear = input.bool(false, "Only Show Zones Near Price", group="Dynamic S/R")
srNearAtrMult = input.float(4.0, "Near Price x ATR", minval=0.5, step=0.5, group="Dynamic S/R")

showHtfSR = input.bool(true, "Show HTF Main S/R Zones", group="Dynamic S/R - HTF Main Zones")
show1hSR = input.bool(true, "Show 1H Main Zones", group="Dynamic S/R - HTF Main Zones")
show4hSR = input.bool(true, "Show 4H Main Zones", group="Dynamic S/R - HTF Main Zones")
show1dSR = input.bool(true, "Show 1D Main Zones", group="Dynamic S/R - HTF Main Zones")
htfSrZoneAtrMult = input.float(0.35, "HTF Zone Width x ATR", minval=0.05, step=0.05, group="Dynamic S/R - HTF Main Zones")
htfSrExtendBars = input.int(180, "HTF Zone Extend Bars", minval=20, maxval=1000, group="Dynamic S/R - HTF Main Zones")
htfSrShowLabels = input.bool(true, "Show HTF S/R Labels", group="Dynamic S/R - HTF Main Zones")

srSupportWeakCol = input.color(color.new(#64b5f6, 84), "Weak Support", group="Dynamic S/R")
srSupportMedCol = input.color(color.new(#2196f3, 78), "Medium Support", group="Dynamic S/R")
srSupportStrongCol = input.color(color.new(#0d47a1, 70), "Strong Support", group="Dynamic S/R")
srResWeakCol = input.color(color.new(#ef9a9a, 84), "Weak Resistance", group="Dynamic S/R")
srResMedCol = input.color(color.new(#f44336, 78), "Medium Resistance", group="Dynamic S/R")
srResStrongCol = input.color(color.new(#b71c1c, 70), "Strong Resistance", group="Dynamic S/R")
htfSupportCol = input.color(color.new(#0d47a1, 62), "HTF Main Support", group="Dynamic S/R - HTF Main Zones")
htfResistanceCol = input.color(color.new(#b71c1c, 62), "HTF Main Resistance", group="Dynamic S/R - HTF Main Zones")

showDecisionTable = input.bool(true, "Show Decision Confluence Table", group="Decision Confluence Table")
decisionTablePosition = input.string("Lower Center", "Decision Table Position", options=["Lower Center", "Middle Bottom", "Bottom Right", "Bottom Left"], group="Decision Confluence Table")
decisionTableSize = input.string("Tiny", "Decision Table Size", options=["Tiny", "Small"], group="Decision Confluence Table")

decisionTablePos = switch decisionTablePosition
    "Lower Center" => position.bottom_center
    "Middle Bottom" => position.bottom_center
    "Bottom Right" => position.bottom_right
    "Bottom Left" => position.bottom_left

decisionTextSize = switch decisionTableSize
    "Small" => size.small
    => size.tiny


//==============================================================================
// INSTITUTIONAL ORDER BLOCK SETTINGS
//==============================================================================

showOB = input.bool(true, "Show Institutional Order Blocks", group="Order Blocks")
obBosLen = input.int(12, "OB BOS Swing Length", minval=2, maxval=50, group="Order Blocks")
obDispMult = input.float(1.0, "Displacement Body x ATR", minval=0.1, step=0.1, group="Order Blocks")
obAtrLen = input.int(14, "OB ATR Length", minval=1, group="Order Blocks")
obFvgAtrMult = input.float(0.6, "Required FVG Size x ATR", minval=0.0, step=0.1, group="Order Blocks")
obMaxDisplay = input.int(2, "Max OBs per Side", minval=1, maxval=20, group="Order Blocks")
obExtendBars = input.int(12, "Extend Active OB Bars", minval=1, maxval=500, group="Order Blocks")
obMitigationRule = input.string("Wick", "Mitigation Rule", options=["Wick", "Close"], group="Order Blocks")
obAlertTaps = input.bool(true, "Alert When Price Taps OB", group="Order Blocks")
bullObCol = input.color(color.new(#00b894, 82), "Bullish OB Color", group="Order Blocks")
bearObCol = input.color(color.new(#e17055, 82), "Bearish OB Color", group="Order Blocks")

oW = sweepOpt == "Only Wicks"
oO = sweepOpt == "Only Outbreaks & Retest"
n = bar_index

//==============================================================================
// TYPES
//==============================================================================

type piv
    float prc
    int bix
    bool brk
    bool mit
    bool tak
    bool wic
    line lin

type boxBr
    box bx
    line ln
    bool br
    int dr
    bool touchedTop

type fvg
    float top
    float bottom
    int startIndex
    bool isBull

type ifvgObj
    box bx
    float top
    float bottom
    bool isBull
    bool mitigated

type obObj
    box bx
    float top
    float bottom
    bool isBull
    bool mitigated
    bool tapped
    string quality
    float buyPct
    float sellPct


type srZoneObj
    box bx
    label lb
    float top
    float bottom
    int touches
    float score
    bool isSupport
    bool active
    int createdBar
    int lastTouchBar

var array<piv> aPivH = array.new<piv>()
var array<piv> aPivL = array.new<piv>()
var array<boxBr> aBoxBr = array.new<boxBr>()
var array<fvg> activeFvgs = array.new<fvg>()
var array<ifvgObj> activeIfvgs = array.new<ifvgObj>()
var array<obObj> activeBullOBs = array.new<obObj>()
var array<obObj> activeBearOBs = array.new<obObj>()
var array<srZoneObj> activeSrZones = array.new<srZoneObj>()

var bool bullSrTouched = false
var bool bearSrTouched = false
var bool strongBullSrTouched = false
var bool strongBearSrTouched = false

var string lastIfvgText = "None"
var int lastIfvgDir = 0
var int lastIfvgExpire = na
var string lastSweepText = "None"
var int lastSweepDir = 0
var int lastSweepExpire = na
var string lastObText = "None"
var int lastObDir = 0
var int lastObExpire = na
var string lastSrText = "None"
var int lastSrDir = 0
var int lastSrExpire = na

var box sr1hResBox = na
var box sr1hSupBox = na
var box sr4hResBox = na
var box sr4hSupBox = na
var box sr1dResBox = na
var box sr1dSupBox = na
var label sr1hResLabel = na
var label sr1hSupLabel = na
var label sr4hResLabel = na
var label sr4hSupLabel = na
var label sr1dResLabel = na
var label sr1dSupLabel = na
var int sr1hResTime = na
var int sr1hSupTime = na
var int sr4hResTime = na
var int sr4hSupTime = na
var int sr1dResTime = na
var int sr1dSupTime = na

var string currentSrText = "None"
var int currentSrDir = 0

var bool ifvgBearBeginning = false
var bool ifvgBullBeginning = false
var bool ifvgBearCompleted = false
var bool ifvgBullCompleted = false
var bool bullishSweepZoneTouched = false
var bool bearishSweepZoneTouched = false
var bool bullishObCreated = false
var bool bearishObCreated = false
var bool bullishObTapped = false
var bool bearishObTapped = false
var bool strongBullishObTapped = false
var bool strongBearishObTapped = false
var bool bullCisdTriggered = false
var bool bearCisdTriggered = false
var bool bullCisdArmed = false
var bool bearCisdArmed = false
var float bullCisdLevel = na
var float bearCisdLevel = na
var int bullCisdArmBar = na
var int bearCisdArmBar = na
var int lastCisdExpireBar = na
var string cisdText = "None"
var string cisdQuality = "-"
var line activeCisdLine = na
var label activeCisdLabel = na

ifvgBearBeginning := false
ifvgBullBeginning := false
ifvgBearCompleted := false
ifvgBullCompleted := false
bullishSweepZoneTouched := false
bearishSweepZoneTouched := false
bullishObCreated := false
bearishObCreated := false
bullishObTapped := false
bearishObTapped := false
strongBullishObTapped := false
strongBearishObTapped := false
bullCisdTriggered := false
bearCisdTriggered := false
bullSrTouched := false
bearSrTouched := false
strongBullSrTouched := false
strongBearSrTouched := false

// Per-bar sweep flags used by CISD. These are set inside the Liquidity Sweeps logic.
bool bullSweep = false
bool bearSweep = false
float lastSweepLow = na
float lastSweepHigh = na

method l(piv get, color c, string s="sd") =>
    style = switch s
        "dt" => line.style_dotted
        "ds" => line.style_dashed
        => line.style_solid
    line.new(get.bix, get.prc, n, get.prc, color=c, style=style)

method br(piv get, color c3, color c, int d) =>
    y1 = d == 1 ? high : get.prc
    y2 = d == 1 ? get.prc : low
    boxBr.new(box.new(n - 1, y1, n + 1, y2, border_color=color.new(color.white, 100), bgcolor=c3), line.new(n, y1, n, y2, color=c, width=3), false, d, false)

lnDot(y, c) =>
    line.new(n, y, n + 3, y, color=c, style=line.style_dotted)

f_detectMtfFvg(_atrLen, _minMult) =>
    _atr = ta.atr(_atrLen)
    _bull = low > high[2] and (low - high[2]) >= _atr * _minMult
    _bear = high < low[2] and (low[2] - high) >= _atr * _minMult
    [_bull, _bear, low, high[2], low[2], high, time]

f_obQuality(_dispBody, _fvgGap, _atr, _vol, _volAvg) =>
    _score = 0.0
    _score += _dispBody >= _atr * 1.5 ? 40 : _dispBody >= _atr * 1.0 ? 30 : 20
    _score += _fvgGap >= _atr * 1.0 ? 30 : _fvgGap >= _atr * 0.6 ? 20 : 10
    _score += _vol >= _volAvg * 1.25 ? 30 : _vol >= _volAvg ? 20 : 10
    _score >= 75 ? "Strong" : _score >= 55 ? "Medium" : "Weak"

f_obVolSplit(_o, _c, _h, _l) =>
    _rng = math.max(_h - _l, syminfo.mintick)
    _bodyRatio = math.abs(_c - _o) / _rng
    _buyPct = _c >= _o ? 50 + _bodyRatio * 50 : 50 - _bodyRatio * 50
    _buyPct := math.max(5, math.min(95, _buyPct))
    _sellPct = 100 - _buyPct
    [_buyPct, _sellPct]

f_obText(_prefix, _quality, _buyPct, _sellPct) =>
    _q = _quality == "Strong" ? "S" : _quality == "Medium" ? "M" : "W"
    _prefix + " " + _q + "\nB" + str.tostring(math.round(_buyPct)) + "/S" + str.tostring(math.round(_sellPct))


f_srStrengthText(_score) =>
    _score >= 75 ? "Strong" : _score >= 55 ? "Medium" : "Weak"

f_srColor(_isSupport, _score) =>
    _strength = f_srStrengthText(_score)
    _isSupport ? (_strength == "Strong" ? srSupportStrongCol : _strength == "Medium" ? srSupportMedCol : srSupportWeakCol) : (_strength == "Strong" ? srResStrongCol : _strength == "Medium" ? srResMedCol : srResWeakCol)

f_srBorderColor(_isSupport, _score) =>
    _strength = f_srStrengthText(_score)
    _base = _isSupport ? color.blue : color.red
    _alpha = _strength == "Strong" ? 0 : _strength == "Medium" ? 25 : 45
    color.new(_base, _alpha)

f_srScore(_touches, _createdBar, _atr, _vol, _volAvg, _body) =>
    _touchScore = math.min(_touches, 4) / 4.0 * 40.0
    _volScore = _vol >= _volAvg * 1.5 ? 30.0 : _vol >= _volAvg ? 20.0 : 10.0
    _dispScore = _body >= _atr * 1.2 ? 20.0 : _body >= _atr * 0.6 ? 12.0 : 5.0
    _timeScore = math.min(math.max(bar_index - _createdBar, 0), 50) / 50.0 * 10.0
    math.min(_touchScore + _volScore + _dispScore + _timeScore, 100.0)

f_srText(_isSupport, _score, _touches) =>
    (_isSupport ? "SUP " : "RES ") + f_srStrengthText(_score) + " (" + str.tostring(_touches) + ")"

f_srCount(_isSupport) =>
    _cnt = 0
    if activeSrZones.size() > 0
        for _i = 0 to activeSrZones.size() - 1
            _z = activeSrZones.get(_i)
            if _z.active and _z.isSupport == _isSupport
                _cnt += 1
    _cnt

f_signalBg(_dir) =>
    _dir == 1 ? color.new(color.green, 25) : _dir == -1 ? color.new(color.red, 25) : color.new(color.gray, 70)

f_signalTextColor(_dir) =>
    _dir == 0 ? chart.fg_color : color.white

f_htfSrPack(_len, _atrLen) =>
    _ph = ta.pivothigh(high, _len, _len)
    _pl = ta.pivotlow(low, _len, _len)
    _atr = ta.atr(_atrLen)
    [_ph, _pl, _atr, time]

f_htfSrText(_tf, _isSupport, _isMajor) =>
    _tf + " " + (_isSupport ? "SUP" : "RES") + (_isMajor ? " Main" : "")

f_htfSrBg(_isSupport) =>
    _isSupport ? htfSupportCol : htfResistanceCol

f_htfSrBorder(_isSupport) =>
    color.new(_isSupport ? color.blue : color.red, 0)

//==============================================================================
// LIQUIDITY SWEEPS
//==============================================================================

sweepPh = ta.pivothigh(sweepLen, sweepLen)
sweepPl = ta.pivotlow(sweepLen, sweepLen)

if not na(sweepPh)
    aPivH.unshift(piv.new(sweepPh, n - sweepLen, false, false, false, false, na))

if not na(sweepPl)
    aPivL.unshift(piv.new(sweepPl, n - sweepLen, false, false, false, false, na))

if aPivH.size() > 0
    for i = aPivH.size() - 1 to 0
        get = aPivH.get(i)

        if not get.mit
            if not get.brk
                if close > get.prc
                    if not oW
                        get.brk := true
                    else
                        get.mit := true

                if not oO and not get.wic
                    if high > get.prc and close < get.prc
                        aBoxBr.unshift(get.br(colBr3, colBr, 1))
                        get.lin := get.l(colBr2, "dt")
                        lnDot(low, colBr)
                        get.wic := true
                        bearSweep := true
                        lastSweepHigh := get.prc
                        if alertSweeps
                            alert("Bearish Sweep Detected at " + str.tostring(get.prc), alert.freq_once_per_bar)
            else
                if close < get.prc
                    get.mit := true

                if not oW and low < get.prc and close > get.prc
                    aBoxBr.unshift(get.br(colBl3, colBl, -1))
                    get.lin := get.l(colBl2, "ds")
                    lnDot(high, colBl)
                    get.tak := true
                    bullSweep := true
                    lastSweepLow := get.prc
                    if alertSweeps
                        alert("Bullish Sweep Detected at " + str.tostring(get.prc), alert.freq_once_per_bar)

        if n - get.bix > 2000 or get.mit or get.tak
            p = aPivH.remove(i)
            if not na(p.lin)
                p.lin.delete()

if aPivL.size() > 0
    for i = aPivL.size() - 1 to 0
        get = aPivL.get(i)

        if not get.mit
            if not get.brk
                if close < get.prc
                    if not oW
                        get.brk := true
                    else
                        get.mit := true

                if not oO and not get.wic
                    if low < get.prc and close > get.prc
                        aBoxBr.unshift(get.br(colBl3, colBl, -1))
                        get.lin := get.l(colBl2, "dt")
                        lnDot(high, colBl)
                        get.wic := true
                        bullSweep := true
                        lastSweepLow := get.prc
                        if alertSweeps
                            alert("Bullish Sweep Detected at " + str.tostring(get.prc), alert.freq_once_per_bar)
            else
                if close > get.prc
                    get.mit := true

                if not oW and high > get.prc and close < get.prc
                    aBoxBr.unshift(get.br(colBr3, colBr, 1))
                    get.lin := get.l(colBr2, "ds")
                    lnDot(low, colBr)
                    get.tak := true
                    bearSweep := true
                    lastSweepHigh := get.prc
                    if alertSweeps
                        alert("Bearish Sweep Detected at " + str.tostring(get.prc), alert.freq_once_per_bar)

        if n - get.bix > 2000 or get.mit or get.tak
            p = aPivL.remove(i)
            if not na(p.lin)
                p.lin.delete()

// Extend sweep boxes + alert when price touches the TOP of the sweep box.
// touchedTop prevents repeated alerts from the same box.
if extendSweeps and aBoxBr.size() > 0
    for i = aBoxBr.size() - 1 to 0
        bx = aBoxBr.get(i)

        if not bx.br and n - bx.bx.get_left() - 1 <= maxB
            bx.bx.set_right(n)

            sweepTop = bx.bx.get_top()
            sweepBottom = bx.bx.get_bottom()

            if not bx.touchedTop and high >= sweepTop
                bx.touchedTop := true

                if bx.dr == -1
                    bullishSweepZoneTouched := true
                    if alertSweepTouches
                        alert("Price touched Bullish Sweep Zone top on " + syminfo.ticker + " " + timeframe.period, alert.freq_once_per_bar)

                if bx.dr == 1
                    bearishSweepZoneTouched := true
                    if alertSweepTouches
                        alert("Price touched Bearish Sweep Zone top on " + syminfo.ticker + " " + timeframe.period, alert.freq_once_per_bar)

            if bx.dr == -1 and close < sweepBottom
                bx.br := true

            if bx.dr == 1 and close > sweepTop
                bx.br := true

            aBoxBr.set(i, bx)


//==============================================================================
// CISD - Change in State of Delivery
// Prints after a liquidity sweep and close through the sweep candle level.
// BCISD = bullish CISD after sell-side sweep.
// SCISD = bearish CISD after buy-side sweep.
//==============================================================================

if showCisd
    if (not cisdRequireSweep or bullSweep) and (not cisdRequireFailure or (not na(lastSweepLow) and close > lastSweepLow))
        bullCisdArmed := true
        bullCisdLevel := high
        bullCisdArmBar := bar_index
        bearCisdArmed := false

    if (not cisdRequireSweep or bearSweep) and (not cisdRequireFailure or (not na(lastSweepHigh) and close < lastSweepHigh))
        bearCisdArmed := true
        bearCisdLevel := low
        bearCisdArmBar := bar_index
        bullCisdArmed := false

    bullCisdNow = bullCisdArmed and not na(bullCisdLevel) and bar_index > bullCisdArmBar and bar_index - bullCisdArmBar <= cisdValidBars and close > bullCisdLevel
    bearCisdNow = bearCisdArmed and not na(bearCisdLevel) and bar_index > bearCisdArmBar and bar_index - bearCisdArmBar <= cisdValidBars and close < bearCisdLevel

    if bullCisdNow
        bullCisdTriggered := true
        bullCisdArmed := false
        cisdText := "BCISD"
        cisdBody = math.abs(close - open)
        cisdQuality := cisdBody >= atrTable * 0.8 ? "Strong" : cisdBody >= atrTable * 0.5 ? "Medium" : "Weak"
        lastCisdExpireBar := bar_index + cisdValidBars

        if not na(activeCisdLine)
            line.delete(activeCisdLine)
        if not na(activeCisdLabel)
            label.delete(activeCisdLabel)

        activeCisdLine := line.new(bar_index, bullCisdLevel, bar_index + cisdValidBars, bullCisdLevel, color=bullCisdCol, style=line.style_dotted, width=1)
        activeCisdLabel := label.new(bar_index + cisdValidBars, bullCisdLevel, "BCISD", style=label.style_none, textcolor=bullCisdCol, size=size.tiny)

        if alertCisd
            alert("BCISD printed on " + syminfo.ticker + " " + timeframe.period, alert.freq_once_per_bar_close)

    if bearCisdNow
        bearCisdTriggered := true
        bearCisdArmed := false
        cisdText := "SCISD"
        cisdBody = math.abs(close - open)
        cisdQuality := cisdBody >= atrTable * 0.8 ? "Strong" : cisdBody >= atrTable * 0.5 ? "Medium" : "Weak"
        lastCisdExpireBar := bar_index + cisdValidBars

        if not na(activeCisdLine)
            line.delete(activeCisdLine)
        if not na(activeCisdLabel)
            label.delete(activeCisdLabel)

        activeCisdLine := line.new(bar_index, bearCisdLevel, bar_index + cisdValidBars, bearCisdLevel, color=bearCisdCol, style=line.style_dotted, width=1)
        activeCisdLabel := label.new(bar_index + cisdValidBars, bearCisdLevel, "SCISD", style=label.style_none, textcolor=bearCisdCol, size=size.tiny)

        if alertCisd
            alert("SCISD printed on " + syminfo.ticker + " " + timeframe.period, alert.freq_once_per_bar_close)

    if not na(lastCisdExpireBar) and bar_index > lastCisdExpireBar
        cisdText := "None"
        cisdQuality := "-"

if barstate.islast and showZltTable
    if showCisdTableRows
        cisdBg = cisdText == "BCISD" ? color.new(bullCisdCol, 65) : cisdText == "SCISD" ? color.new(bearCisdCol, 65) : color.new(color.gray, 80)
        qBg = cisdQuality == "Strong" ? color.new(color.green, 60) : cisdQuality == "Medium" ? color.new(color.orange, 60) : cisdQuality == "Weak" ? color.new(color.gray, 65) : color.new(color.gray, 80)
        table.cell(zltTable, column=0, row=6, text="CISD", text_halign=text.align_center, text_color=chart.fg_color, text_size=zltTextSize)
        table.cell(zltTable, column=1, row=6, text=cisdText, text_halign=text.align_center, text_color=chart.fg_color, bgcolor=cisdBg, text_size=zltTextSize)
        table.cell(zltTable, column=0, row=7, text="Q", text_halign=text.align_center, text_color=chart.fg_color, text_size=zltTextSize)
        table.cell(zltTable, column=1, row=7, text=cisdQuality, text_halign=text.align_center, text_color=chart.fg_color, bgcolor=qBg, text_size=zltTextSize)
    else
        table.clear(zltTable, 0, 6, 1, 7)


//==============================================================================
// CISD ROW ON MULTICATOR TABLE
// Keeps the original Multicator table visible while adding CISD status compactly.
//==============================================================================

if barstate.islast and not mobilGoster and tabloGoster and showCisdTableRows
    cisdBgMain = cisdText == "BCISD" ? color.new(bullCisdCol, 55) : cisdText == "SCISD" ? color.new(bearCisdCol, 55) : color.new(color.gray, 75)
    cisdQBgMain = cisdQuality == "Strong" ? color.new(color.green, 55) : cisdQuality == "Medium" ? color.new(color.orange, 55) : cisdQuality == "Weak" ? color.new(color.gray, 60) : color.new(color.gray, 75)
    table.cell(tablo, 0, 4, bgcolor=color.black, text_color=color.white, text="CISD", text_size=buyuk)
    table.cell(tablo, 1, 4, bgcolor=cisdBgMain, text_color=color.white, text=cisdText, text_size=buyuk)
    table.cell(tablo, 2, 4, bgcolor=color.black, text_color=color.white, text="Q", text_size=buyuk)
    table.cell(tablo, 3, 4, bgcolor=cisdQBgMain, text_color=color.white, text=cisdQuality, text_size=buyuk)
    table.cell(tablo, 4, 4, bgcolor=color.black, text_color=color.white, text="Line", text_size=buyuk)
    table.cell(tablo, 5, 4, bgcolor=cisdBgMain, text_color=color.white, text=cisdText == "None" ? "-" : "ON", text_size=buyuk)



//==============================================================================
// FVG / IFVG
//==============================================================================

ifvgAtr = ta.atr(14)
threshold = ifvgAtr * volFilter

if low > high[2]
    gapSize = low - high[2]
    if gapSize > threshold
        activeFvgs.push(fvg.new(low, high[2], n - 2, true))

if high < low[2]
    gapSize = low[2] - high
    if gapSize > threshold
        activeFvgs.push(fvg.new(low[2], high, n - 2, false))

if showIfvg
    if activeFvgs.size() > 0
        for i = activeFvgs.size() - 1 to 0
            item = activeFvgs.get(i)
            bool confirmed = false

            if item.isBull
                // Original bullish FVG starts to invert bearish.
                if low < item.top and close >= item.bottom
                    ifvgBearBeginning := true
                    if alertIfvgs
                        alert("Bearish IFVG beginning to form", alert.freq_once_per_bar)

                // Bearish IFVG completed.
                if close < item.bottom
                    ifvgBearCompleted := true
                    newBx = box.new(item.startIndex, item.top, n + 5, item.bottom, bgcolor=ifvgBearCol, border_color=color.new(ifvgBearCol, 20), text="Bearish IFVG", text_color=chart.fg_color, text_size=size.tiny)
                    activeIfvgs.unshift(ifvgObj.new(newBx, item.top, item.bottom, false, false))

                    if alertIfvgs
                        alert("Bearish IFVG completed", alert.freq_once_per_bar_close)

                    confirmed := true
            else
                // Original bearish FVG starts to invert bullish.
                if high > item.bottom and close <= item.top
                    ifvgBullBeginning := true
                    if alertIfvgs
                        alert("Bullish IFVG beginning to form", alert.freq_once_per_bar)

                // Bullish IFVG completed.
                if close > item.top
                    ifvgBullCompleted := true
                    newBx = box.new(item.startIndex, item.top, n + 5, item.bottom, bgcolor=ifvgBullCol, border_color=color.new(ifvgBullCol, 20), text="Bullish IFVG", text_color=chart.fg_color, text_size=size.tiny)
                    activeIfvgs.unshift(ifvgObj.new(newBx, item.top, item.bottom, true, false))

                    if alertIfvgs
                        alert("Bullish IFVG completed", alert.freq_once_per_bar_close)

                    confirmed := true

            if confirmed or n - item.startIndex > 1000
                activeFvgs.remove(i)

    if activeIfvgs.size() > 0
        for i = activeIfvgs.size() - 1 to 0
            ifvO = activeIfvgs.get(i)

            if not ifvO.mitigated
                if ifvO.isBull
                    if close < ifvO.bottom
                        ifvO.mitigated := true
                        ifvO.bx.set_right(n)
                else
                    if close > ifvO.top
                        ifvO.mitigated := true
                        ifvO.bx.set_right(n)

            if not ifvO.mitigated
                ifvO.bx.set_right(n + 5)

    while activeIfvgs.size() > maxIfvgDisplay
        old = activeIfvgs.pop()
        old.bx.delete()


//==============================================================================
// MULTI-TIMEFRAME FVGs - compact nearest-per-TF zones
//==============================================================================

var box mtf3BullBox = na
var box mtf3BearBox = na
var box mtf5BullBox = na
var box mtf5BearBox = na
var box mtf30BullBox = na
var box mtf30BearBox = na
var box mtf1hBullBox = na
var box mtf1hBearBox = na
var box mtf4hBullBox = na
var box mtf4hBearBox = na

var float mtf3BullTop = na, var float mtf3BullBot = na, var int mtf3BullExp = na, var int mtf3BullTime = na
var float mtf3BearTop = na, var float mtf3BearBot = na, var int mtf3BearExp = na, var int mtf3BearTime = na
var float mtf5BullTop = na, var float mtf5BullBot = na, var int mtf5BullExp = na, var int mtf5BullTime = na
var float mtf5BearTop = na, var float mtf5BearBot = na, var int mtf5BearExp = na, var int mtf5BearTime = na
var float mtf30BullTop = na, var float mtf30BullBot = na, var int mtf30BullExp = na, var int mtf30BullTime = na
var float mtf30BearTop = na, var float mtf30BearBot = na, var int mtf30BearExp = na, var int mtf30BearTime = na
var float mtf1hBullTop = na, var float mtf1hBullBot = na, var int mtf1hBullExp = na, var int mtf1hBullTime = na
var float mtf1hBearTop = na, var float mtf1hBearBot = na, var int mtf1hBearExp = na, var int mtf1hBearTime = na
var float mtf4hBullTop = na, var float mtf4hBullBot = na, var int mtf4hBullExp = na, var int mtf4hBullTime = na
var float mtf4hBearTop = na, var float mtf4hBearBot = na, var int mtf4hBearExp = na, var int mtf4hBearTime = na

[mtf3Bull, mtf3Bear, mtf3BTop, mtf3BBot, mtf3STop, mtf3SBot, mtf3Time] = request.security(syminfo.tickerid, "3", f_detectMtfFvg(mtfFvgAtrLen, mtfFvgMinAtr))
[mtf5Bull, mtf5Bear, mtf5BTop, mtf5BBot, mtf5STop, mtf5SBot, mtf5Time] = request.security(syminfo.tickerid, "5", f_detectMtfFvg(mtfFvgAtrLen, mtfFvgMinAtr))
[mtf30Bull, mtf30Bear, mtf30BTop, mtf30BBot, mtf30STop, mtf30SBot, mtf30Time] = request.security(syminfo.tickerid, "30", f_detectMtfFvg(mtfFvgAtrLen, mtfFvgMinAtr))
[mtf1hBull, mtf1hBear, mtf1hBTop, mtf1hBBot, mtf1hSTop, mtf1hSBot, mtf1hTime] = request.security(syminfo.tickerid, "60", f_detectMtfFvg(mtfFvgAtrLen, mtfFvgMinAtr))
[mtf4hBull, mtf4hBear, mtf4hBTop, mtf4hBBot, mtf4hSTop, mtf4hSBot, mtf4hTime] = request.security(syminfo.tickerid, "240", f_detectMtfFvg(mtfFvgAtrLen, mtfFvgMinAtr))

if showMtfFvgs and showMtf3m and mtf3Bull and mtf3Time != mtf3BullTime
    if not na(mtf3BullBox)
        box.delete(mtf3BullBox)
    mtf3BullTop := mtf3BTop, mtf3BullBot := mtf3BBot, mtf3BullExp := bar_index + mtfFvgExtend, mtf3BullTime := mtf3Time
    mtf3BullBox := box.new(bar_index - 2, mtf3BullTop, mtf3BullExp, mtf3BullBot, bgcolor=mtfBullFvgCol, border_color=color.new(mtfBullFvgCol, 35), text="3m BFVG", text_color=chart.fg_color, text_size=size.tiny, text_halign=text.align_left, text_valign=text.align_center)
if showMtfFvgs and showMtf3m and mtf3Bear and mtf3Time != mtf3BearTime
    if not na(mtf3BearBox)
        box.delete(mtf3BearBox)
    mtf3BearTop := mtf3STop, mtf3BearBot := mtf3SBot, mtf3BearExp := bar_index + mtfFvgExtend, mtf3BearTime := mtf3Time
    mtf3BearBox := box.new(bar_index - 2, mtf3BearTop, mtf3BearExp, mtf3BearBot, bgcolor=mtfBearFvgCol, border_color=color.new(mtfBearFvgCol, 35), text="3m SFVG", text_color=chart.fg_color, text_size=size.tiny, text_halign=text.align_left, text_valign=text.align_center)

if showMtfFvgs and showMtf5m and mtf5Bull and mtf5Time != mtf5BullTime
    if not na(mtf5BullBox)
        box.delete(mtf5BullBox)
    mtf5BullTop := mtf5BTop, mtf5BullBot := mtf5BBot, mtf5BullExp := bar_index + mtfFvgExtend, mtf5BullTime := mtf5Time
    mtf5BullBox := box.new(bar_index - 2, mtf5BullTop, mtf5BullExp, mtf5BullBot, bgcolor=mtfBullFvgCol, border_color=color.new(mtfBullFvgCol, 35), text="5m BFVG", text_color=chart.fg_color, text_size=size.tiny, text_halign=text.align_left, text_valign=text.align_center)
if showMtfFvgs and showMtf5m and mtf5Bear and mtf5Time != mtf5BearTime
    if not na(mtf5BearBox)
        box.delete(mtf5BearBox)
    mtf5BearTop := mtf5STop, mtf5BearBot := mtf5SBot, mtf5BearExp := bar_index + mtfFvgExtend, mtf5BearTime := mtf5Time
    mtf5BearBox := box.new(bar_index - 2, mtf5BearTop, mtf5BearExp, mtf5BearBot, bgcolor=mtfBearFvgCol, border_color=color.new(mtfBearFvgCol, 35), text="5m SFVG", text_color=chart.fg_color, text_size=size.tiny, text_halign=text.align_left, text_valign=text.align_center)

if showMtfFvgs and showMtf30m and mtf30Bull and mtf30Time != mtf30BullTime
    if not na(mtf30BullBox)
        box.delete(mtf30BullBox)
    mtf30BullTop := mtf30BTop, mtf30BullBot := mtf30BBot, mtf30BullExp := bar_index + mtfFvgExtend, mtf30BullTime := mtf30Time
    mtf30BullBox := box.new(bar_index - 2, mtf30BullTop, mtf30BullExp, mtf30BullBot, bgcolor=mtfBullFvgCol, border_color=color.new(mtfBullFvgCol, 35), text="30m BFVG", text_color=chart.fg_color, text_size=size.tiny, text_halign=text.align_left, text_valign=text.align_center)
if showMtfFvgs and showMtf30m and mtf30Bear and mtf30Time != mtf30BearTime
    if not na(mtf30BearBox)
        box.delete(mtf30BearBox)
    mtf30BearTop := mtf30STop, mtf30BearBot := mtf30SBot, mtf30BearExp := bar_index + mtfFvgExtend, mtf30BearTime := mtf30Time
    mtf30BearBox := box.new(bar_index - 2, mtf30BearTop, mtf30BearExp, mtf30BearBot, bgcolor=mtfBearFvgCol, border_color=color.new(mtfBearFvgCol, 35), text="30m SFVG", text_color=chart.fg_color, text_size=size.tiny, text_halign=text.align_left, text_valign=text.align_center)

if showMtfFvgs and showMtf1h and mtf1hBull and mtf1hTime != mtf1hBullTime
    if not na(mtf1hBullBox)
        box.delete(mtf1hBullBox)
    mtf1hBullTop := mtf1hBTop, mtf1hBullBot := mtf1hBBot, mtf1hBullExp := bar_index + mtfFvgExtend, mtf1hBullTime := mtf1hTime
    mtf1hBullBox := box.new(bar_index - 2, mtf1hBullTop, mtf1hBullExp, mtf1hBullBot, bgcolor=mtfBullFvgCol, border_color=color.new(mtfBullFvgCol, 35), text="1H BFVG", text_color=chart.fg_color, text_size=size.tiny, text_halign=text.align_left, text_valign=text.align_center)
if showMtfFvgs and showMtf1h and mtf1hBear and mtf1hTime != mtf1hBearTime
    if not na(mtf1hBearBox)
        box.delete(mtf1hBearBox)
    mtf1hBearTop := mtf1hSTop, mtf1hBearBot := mtf1hSBot, mtf1hBearExp := bar_index + mtfFvgExtend, mtf1hBearTime := mtf1hTime
    mtf1hBearBox := box.new(bar_index - 2, mtf1hBearTop, mtf1hBearExp, mtf1hBearBot, bgcolor=mtfBearFvgCol, border_color=color.new(mtfBearFvgCol, 35), text="1H SFVG", text_color=chart.fg_color, text_size=size.tiny, text_halign=text.align_left, text_valign=text.align_center)

if showMtfFvgs and showMtf4h and mtf4hBull and mtf4hTime != mtf4hBullTime
    if not na(mtf4hBullBox)
        box.delete(mtf4hBullBox)
    mtf4hBullTop := mtf4hBTop, mtf4hBullBot := mtf4hBBot, mtf4hBullExp := bar_index + mtfFvgExtend, mtf4hBullTime := mtf4hTime
    mtf4hBullBox := box.new(bar_index - 2, mtf4hBullTop, mtf4hBullExp, mtf4hBullBot, bgcolor=mtfBullFvgCol, border_color=color.new(mtfBullFvgCol, 35), text="4H BFVG", text_color=chart.fg_color, text_size=size.tiny, text_halign=text.align_left, text_valign=text.align_center)
if showMtfFvgs and showMtf4h and mtf4hBear and mtf4hTime != mtf4hBearTime
    if not na(mtf4hBearBox)
        box.delete(mtf4hBearBox)
    mtf4hBearTop := mtf4hSTop, mtf4hBearBot := mtf4hSBot, mtf4hBearExp := bar_index + mtfFvgExtend, mtf4hBearTime := mtf4hTime
    mtf4hBearBox := box.new(bar_index - 2, mtf4hBearTop, mtf4hBearExp, mtf4hBearBot, bgcolor=mtfBearFvgCol, border_color=color.new(mtfBearFvgCol, 35), text="4H SFVG", text_color=chart.fg_color, text_size=size.tiny, text_halign=text.align_left, text_valign=text.align_center)

if not na(mtf3BullBox) and (low < mtf3BullBot or bar_index > mtf3BullExp or not showMtfFvgs or not showMtf3m)
    box.delete(mtf3BullBox)
    mtf3BullBox := na
if not na(mtf3BearBox) and (high > mtf3BearTop or bar_index > mtf3BearExp or not showMtfFvgs or not showMtf3m)
    box.delete(mtf3BearBox)
    mtf3BearBox := na
if not na(mtf5BullBox) and (low < mtf5BullBot or bar_index > mtf5BullExp or not showMtfFvgs or not showMtf5m)
    box.delete(mtf5BullBox)
    mtf5BullBox := na
if not na(mtf5BearBox) and (high > mtf5BearTop or bar_index > mtf5BearExp or not showMtfFvgs or not showMtf5m)
    box.delete(mtf5BearBox)
    mtf5BearBox := na
if not na(mtf30BullBox) and (low < mtf30BullBot or bar_index > mtf30BullExp or not showMtfFvgs or not showMtf30m)
    box.delete(mtf30BullBox)
    mtf30BullBox := na
if not na(mtf30BearBox) and (high > mtf30BearTop or bar_index > mtf30BearExp or not showMtfFvgs or not showMtf30m)
    box.delete(mtf30BearBox)
    mtf30BearBox := na
if not na(mtf1hBullBox) and (low < mtf1hBullBot or bar_index > mtf1hBullExp or not showMtfFvgs or not showMtf1h)
    box.delete(mtf1hBullBox)
    mtf1hBullBox := na
if not na(mtf1hBearBox) and (high > mtf1hBearTop or bar_index > mtf1hBearExp or not showMtfFvgs or not showMtf1h)
    box.delete(mtf1hBearBox)
    mtf1hBearBox := na
if not na(mtf4hBullBox) and (low < mtf4hBullBot or bar_index > mtf4hBullExp or not showMtfFvgs or not showMtf4h)
    box.delete(mtf4hBullBox)
    mtf4hBullBox := na
if not na(mtf4hBearBox) and (high > mtf4hBearTop or bar_index > mtf4hBearExp or not showMtfFvgs or not showMtf4h)
    box.delete(mtf4hBearBox)
    mtf4hBearBox := na


//==============================================================================
// DYNAMIC SUPPORT / RESISTANCE ZONES
// Creates ATR-width zones around pivots, auto-flips S/R based on price location,
// and grades strength using rejection count, volume, displacement, and time held.
//==============================================================================

srAtr = ta.atr(srAtrLen)
srVolAvg = ta.sma(volume, 20)
srBody = math.abs(close - open)
srPh = ta.pivothigh(high, srSwingLen, srSwingLen)
srPl = ta.pivotlow(low, srSwingLen, srSwingLen)

currentSrText := "None"
currentSrDir := 0
float srNearestDist = 10000000000.0

f_srAddZone(_level) =>
    _width = srAtr[srSwingLen] * srZoneAtrMult
    _top = _level + _width
    _bottom = _level - _width
    _mid = (_top + _bottom) / 2.0
    _isSupport = close >= _mid
    _score = f_srScore(1, bar_index - srSwingLen, srAtr, volume, srVolAvg, srBody)
    _merged = false
    if activeSrZones.size() > 0
        for _i = activeSrZones.size() - 1 to 0
            _z = activeSrZones.get(_i)
            _near = math.abs(((_z.top + _z.bottom) / 2.0) - _mid) <= srAtr * srMergeAtrMult
            _overlap = _bottom <= _z.top and _top >= _z.bottom
            if _z.active and (_near or _overlap) and not _merged
                _z.top := math.max(_z.top, _top)
                _z.bottom := math.min(_z.bottom, _bottom)
                _z.touches += 1
                _z.score := math.max(_z.score, _score)
                _z.isSupport := close >= ((_z.top + _z.bottom) / 2.0)
                _z.bx.set_top(_z.top)
                _z.bx.set_bottom(_z.bottom)
                _z.bx.set_right(bar_index + srExtendBars)
                _z.bx.set_bgcolor(f_srColor(_z.isSupport, _z.score))
                _z.bx.set_border_color(f_srBorderColor(_z.isSupport, _z.score))
                _z.bx.set_text(srShowLabels ? f_srText(_z.isSupport, _z.score, _z.touches) : "")
                if not na(_z.lb)
                    _z.lb.set_xy(bar_index + srExtendBars, (_z.top + _z.bottom) / 2.0)
                    _z.lb.set_text(srShowLabels ? f_srText(_z.isSupport, _z.score, _z.touches) : "")
                    _z.lb.set_textcolor(_z.isSupport ? color.blue : color.red)
                activeSrZones.set(_i, _z)
                _merged := true
    if not _merged
        _txt = srShowLabels ? f_srText(_isSupport, _score, 1) : ""
        _bx = box.new(bar_index - srSwingLen, _top, bar_index + srExtendBars, _bottom, bgcolor=f_srColor(_isSupport, _score), border_color=f_srBorderColor(_isSupport, _score), text=_txt, text_color=chart.fg_color, text_size=size.tiny, text_halign=text.align_left, text_valign=text.align_center)
        _lb = srShowLabels ? label.new(bar_index + srExtendBars, _mid, _txt, style=label.style_none, textcolor=_isSupport ? color.blue : color.red, size=size.tiny) : na
        activeSrZones.unshift(srZoneObj.new(_bx, _lb, _top, _bottom, 1, _score, _isSupport, true, bar_index - srSwingLen, na))

if showDynSR and not na(srPh)
    f_srAddZone(srPh)

if showDynSR and not na(srPl)
    f_srAddZone(srPl)

if activeSrZones.size() > 0
    for _i = activeSrZones.size() - 1 to 0
        _z = activeSrZones.get(_i)
        if _z.active
            _mid = (_z.top + _z.bottom) / 2.0
            _z.isSupport := close >= _mid
            _z.bx.set_right(bar_index + srExtendBars)
            if not na(_z.lb)
                _z.lb.set_xy(bar_index + srExtendBars, _mid)

            _touching = high >= _z.bottom and low <= _z.top
            _bullReject = _z.isSupport and _touching and close > _z.top
            _bearReject = not _z.isSupport and _touching and close < _z.bottom
            if (_bullReject or _bearReject) and (_z.lastTouchBar != bar_index)
                _z.touches += 1
                _z.lastTouchBar := bar_index
                _z.score := f_srScore(_z.touches, _z.createdBar, srAtr, volume, srVolAvg, srBody)
                if _bullReject
                    bullSrTouched := true
                    strongBullSrTouched := _z.score >= 75
                    lastSrText := f_srText(true, _z.score, _z.touches)
                    lastSrDir := 1
                    lastSrExpire := bar_index + 20
                if _bearReject
                    bearSrTouched := true
                    strongBearSrTouched := _z.score >= 75
                    lastSrText := f_srText(false, _z.score, _z.touches)
                    lastSrDir := -1
                    lastSrExpire := bar_index + 20

            _visible = showDynSR and (not srShowOnlyNear or math.abs(close - _mid) <= srAtr * srNearAtrMult)
            _distToZone = math.abs(close - _mid)
            if _visible and _distToZone < srNearestDist
                srNearestDist := _distToZone
                currentSrText := f_srText(_z.isSupport, _z.score, _z.touches)
                currentSrDir := _z.isSupport ? 1 : -1

            _z.bx.set_bgcolor(_visible ? f_srColor(_z.isSupport, _z.score) : color.new(chart.bg_color, 100))
            _z.bx.set_border_color(_visible ? f_srBorderColor(_z.isSupport, _z.score) : color.new(chart.bg_color, 100))
            _z.bx.set_text(_visible and srShowLabels ? f_srText(_z.isSupport, _z.score, _z.touches) : "")
            if not na(_z.lb)
                _z.lb.set_text(_visible and srShowLabels ? f_srText(_z.isSupport, _z.score, _z.touches) : "")
                _z.lb.set_textcolor(_z.isSupport ? color.blue : color.red)
            activeSrZones.set(_i, _z)

while f_srCount(true) > srMaxSupport
    _removed = false
    for _i = activeSrZones.size() - 1 to 0
        _z = activeSrZones.get(_i)
        if _z.isSupport and not _removed
            _z.bx.delete()
            if not na(_z.lb)
                _z.lb.delete()
            activeSrZones.remove(_i)
            _removed := true

while f_srCount(false) > srMaxResistance
    _removed = false
    for _i = activeSrZones.size() - 1 to 0
        _z = activeSrZones.get(_i)
        if not _z.isSupport and not _removed
            _z.bx.delete()
            if not na(_z.lb)
                _z.lb.delete()
            activeSrZones.remove(_i)
            _removed := true

if not showDynSR and activeSrZones.size() > 0
    for _i = activeSrZones.size() - 1 to 0
        _z = activeSrZones.get(_i)
        _z.bx.delete()
        if not na(_z.lb)
            _z.lb.delete()
        activeSrZones.remove(_i)

if not na(lastSrExpire) and bar_index > lastSrExpire
    lastSrText := "None"
    lastSrDir := 0


//==============================================================================
// HTF MAIN SUPPORT / RESISTANCE ZONES
// Adds dominant 1H / 4H / 1D zones that remain visible on lower charts.
// 4H and 1D zones are intentionally thicker and labelled as Main zones.
//==============================================================================

[htf1hPh, htf1hPl, htf1hAtr, htf1hTime] = request.security(syminfo.tickerid, "60", f_htfSrPack(srSwingLen, srAtrLen), barmerge.gaps_off, barmerge.lookahead_off)
[htf4hPh, htf4hPl, htf4hAtr, htf4hTime] = request.security(syminfo.tickerid, "240", f_htfSrPack(srSwingLen, srAtrLen), barmerge.gaps_off, barmerge.lookahead_off)
[htf1dPh, htf1dPl, htf1dAtr, htf1dTime] = request.security(syminfo.tickerid, "1D", f_htfSrPack(srSwingLen, srAtrLen), barmerge.gaps_off, barmerge.lookahead_off)

if showDynSR and showHtfSR and show1hSR and not na(htf1hPh) and htf1hTime != sr1hResTime
    sr1hResTime := htf1hTime
    if not na(sr1hResBox)
        box.delete(sr1hResBox)
    if not na(sr1hResLabel)
        label.delete(sr1hResLabel)
    _w = htf1hAtr * htfSrZoneAtrMult
    _top = htf1hPh + _w
    _bot = htf1hPh - _w
    _isSup = close >= htf1hPh
    _txt = htfSrShowLabels ? f_htfSrText("1H", _isSup, false) : ""
    sr1hResBox := box.new(bar_index, _top, bar_index + htfSrExtendBars, _bot, bgcolor=f_htfSrBg(_isSup), border_color=f_htfSrBorder(_isSup), border_width=1, text=_txt, text_color=chart.fg_color, text_size=size.tiny, text_halign=text.align_left, text_valign=text.align_center)
    sr1hResLabel := htfSrShowLabels ? label.new(bar_index + htfSrExtendBars, htf1hPh, _txt, style=label.style_none, textcolor=_isSup ? color.blue : color.red, size=size.tiny) : na

if showDynSR and showHtfSR and show1hSR and not na(htf1hPl) and htf1hTime != sr1hSupTime
    sr1hSupTime := htf1hTime
    if not na(sr1hSupBox)
        box.delete(sr1hSupBox)
    if not na(sr1hSupLabel)
        label.delete(sr1hSupLabel)
    _w = htf1hAtr * htfSrZoneAtrMult
    _top = htf1hPl + _w
    _bot = htf1hPl - _w
    _isSup = close >= htf1hPl
    _txt = htfSrShowLabels ? f_htfSrText("1H", _isSup, false) : ""
    sr1hSupBox := box.new(bar_index, _top, bar_index + htfSrExtendBars, _bot, bgcolor=f_htfSrBg(_isSup), border_color=f_htfSrBorder(_isSup), border_width=1, text=_txt, text_color=chart.fg_color, text_size=size.tiny, text_halign=text.align_left, text_valign=text.align_center)
    sr1hSupLabel := htfSrShowLabels ? label.new(bar_index + htfSrExtendBars, htf1hPl, _txt, style=label.style_none, textcolor=_isSup ? color.blue : color.red, size=size.tiny) : na

if showDynSR and showHtfSR and show4hSR and not na(htf4hPh) and htf4hTime != sr4hResTime
    sr4hResTime := htf4hTime
    if not na(sr4hResBox)
        box.delete(sr4hResBox)
    if not na(sr4hResLabel)
        label.delete(sr4hResLabel)
    _w = htf4hAtr * htfSrZoneAtrMult * 1.35
    _top = htf4hPh + _w
    _bot = htf4hPh - _w
    _isSup = close >= htf4hPh
    _txt = htfSrShowLabels ? f_htfSrText("4H", _isSup, true) : ""
    sr4hResBox := box.new(bar_index, _top, bar_index + htfSrExtendBars, _bot, bgcolor=f_htfSrBg(_isSup), border_color=f_htfSrBorder(_isSup), border_width=2, text=_txt, text_color=chart.fg_color, text_size=size.tiny, text_halign=text.align_left, text_valign=text.align_center)
    sr4hResLabel := htfSrShowLabels ? label.new(bar_index + htfSrExtendBars, htf4hPh, _txt, style=label.style_none, textcolor=_isSup ? color.blue : color.red, size=size.tiny) : na

if showDynSR and showHtfSR and show4hSR and not na(htf4hPl) and htf4hTime != sr4hSupTime
    sr4hSupTime := htf4hTime
    if not na(sr4hSupBox)
        box.delete(sr4hSupBox)
    if not na(sr4hSupLabel)
        label.delete(sr4hSupLabel)
    _w = htf4hAtr * htfSrZoneAtrMult * 1.35
    _top = htf4hPl + _w
    _bot = htf4hPl - _w
    _isSup = close >= htf4hPl
    _txt = htfSrShowLabels ? f_htfSrText("4H", _isSup, true) : ""
    sr4hSupBox := box.new(bar_index, _top, bar_index + htfSrExtendBars, _bot, bgcolor=f_htfSrBg(_isSup), border_color=f_htfSrBorder(_isSup), border_width=2, text=_txt, text_color=chart.fg_color, text_size=size.tiny, text_halign=text.align_left, text_valign=text.align_center)
    sr4hSupLabel := htfSrShowLabels ? label.new(bar_index + htfSrExtendBars, htf4hPl, _txt, style=label.style_none, textcolor=_isSup ? color.blue : color.red, size=size.tiny) : na

if showDynSR and showHtfSR and show1dSR and not na(htf1dPh) and htf1dTime != sr1dResTime
    sr1dResTime := htf1dTime
    if not na(sr1dResBox)
        box.delete(sr1dResBox)
    if not na(sr1dResLabel)
        label.delete(sr1dResLabel)
    _w = htf1dAtr * htfSrZoneAtrMult * 1.7
    _top = htf1dPh + _w
    _bot = htf1dPh - _w
    _isSup = close >= htf1dPh
    _txt = htfSrShowLabels ? f_htfSrText("1D", _isSup, true) : ""
    sr1dResBox := box.new(bar_index, _top, bar_index + htfSrExtendBars, _bot, bgcolor=f_htfSrBg(_isSup), border_color=f_htfSrBorder(_isSup), border_width=3, text=_txt, text_color=chart.fg_color, text_size=size.tiny, text_halign=text.align_left, text_valign=text.align_center)
    sr1dResLabel := htfSrShowLabels ? label.new(bar_index + htfSrExtendBars, htf1dPh, _txt, style=label.style_none, textcolor=_isSup ? color.blue : color.red, size=size.tiny) : na

if showDynSR and showHtfSR and show1dSR and not na(htf1dPl) and htf1dTime != sr1dSupTime
    sr1dSupTime := htf1dTime
    if not na(sr1dSupBox)
        box.delete(sr1dSupBox)
    if not na(sr1dSupLabel)
        label.delete(sr1dSupLabel)
    _w = htf1dAtr * htfSrZoneAtrMult * 1.7
    _top = htf1dPl + _w
    _bot = htf1dPl - _w
    _isSup = close >= htf1dPl
    _txt = htfSrShowLabels ? f_htfSrText("1D", _isSup, true) : ""
    sr1dSupBox := box.new(bar_index, _top, bar_index + htfSrExtendBars, _bot, bgcolor=f_htfSrBg(_isSup), border_color=f_htfSrBorder(_isSup), border_width=3, text=_txt, text_color=chart.fg_color, text_size=size.tiny, text_halign=text.align_left, text_valign=text.align_center)
    sr1dSupLabel := htfSrShowLabels ? label.new(bar_index + htfSrExtendBars, htf1dPl, _txt, style=label.style_none, textcolor=_isSup ? color.blue : color.red, size=size.tiny) : na

f_updateHtfSr(_bx, _lb, _tf, _isMajor, _borderWidth) =>
    float _dist = na
    string _txtOut = ""
    int _dirOut = 0
    if not na(_bx)
        _top = box.get_top(_bx)
        _bot = box.get_bottom(_bx)
        _mid = (_top + _bot) / 2.0
        _isSup = close >= _mid
        _txt = htfSrShowLabels ? f_htfSrText(_tf, _isSup, _isMajor) : ""
        box.set_right(_bx, bar_index + htfSrExtendBars)
        box.set_bgcolor(_bx, showDynSR and showHtfSR ? f_htfSrBg(_isSup) : color.new(chart.bg_color, 100))
        box.set_border_color(_bx, showDynSR and showHtfSR ? f_htfSrBorder(_isSup) : color.new(chart.bg_color, 100))
        box.set_border_width(_bx, _borderWidth)
        box.set_text(_bx, showDynSR and showHtfSR and htfSrShowLabels ? _txt : "")
        if not na(_lb)
            label.set_xy(_lb, bar_index + htfSrExtendBars, _mid)
            label.set_text(_lb, showDynSR and showHtfSR and htfSrShowLabels ? _txt : "")
            label.set_textcolor(_lb, _isSup ? color.blue : color.red)
        _dist := math.abs(close - _mid)
        if showDynSR and showHtfSR and _dist <= srAtr * srNearAtrMult
            _txtOut := _txt
            _dirOut := _isSup ? 1 : -1
    [_dist, _txtOut, _dirOut, _isMajor ? 1 : 0]

[_srD1, _srT1, _srDir1, _srMaj1] = f_updateHtfSr(sr1hResBox, sr1hResLabel, "1H", false, 1)
if _srT1 != "" and (_srD1 < srNearestDist or _srMaj1 == 1)
    srNearestDist := _srD1
    currentSrText := _srT1
    currentSrDir := _srDir1
[_srD2, _srT2, _srDir2, _srMaj2] = f_updateHtfSr(sr1hSupBox, sr1hSupLabel, "1H", false, 1)
if _srT2 != "" and (_srD2 < srNearestDist or _srMaj2 == 1)
    srNearestDist := _srD2
    currentSrText := _srT2
    currentSrDir := _srDir2
[_srD3, _srT3, _srDir3, _srMaj3] = f_updateHtfSr(sr4hResBox, sr4hResLabel, "4H", true, 2)
if _srT3 != "" and (_srD3 < srNearestDist or _srMaj3 == 1)
    srNearestDist := _srD3
    currentSrText := _srT3
    currentSrDir := _srDir3
[_srD4, _srT4, _srDir4, _srMaj4] = f_updateHtfSr(sr4hSupBox, sr4hSupLabel, "4H", true, 2)
if _srT4 != "" and (_srD4 < srNearestDist or _srMaj4 == 1)
    srNearestDist := _srD4
    currentSrText := _srT4
    currentSrDir := _srDir4
[_srD5, _srT5, _srDir5, _srMaj5] = f_updateHtfSr(sr1dResBox, sr1dResLabel, "1D", true, 3)
if _srT5 != "" and (_srD5 < srNearestDist or _srMaj5 == 1)
    srNearestDist := _srD5
    currentSrText := _srT5
    currentSrDir := _srDir5
[_srD6, _srT6, _srDir6, _srMaj6] = f_updateHtfSr(sr1dSupBox, sr1dSupLabel, "1D", true, 3)
if _srT6 != "" and (_srD6 < srNearestDist or _srMaj6 == 1)
    srNearestDist := _srD6
    currentSrText := _srT6
    currentSrDir := _srDir6


//==============================================================================
// INSTITUTIONAL ORDER BLOCKS
// Criteria:
// 1) Last opposite candle before displacement
// 2) OB candle breaks previous candle high/low
// 3) FVG forms during displacement
// 4) Displacement candle creates BOS
//==============================================================================

obAtr = ta.atr(obAtrLen)
obBody = math.abs(close - open)

obPh = ta.pivothigh(obBosLen, obBosLen)
obPl = ta.pivotlow(obBosLen, obBosLen)

var float lastObSwingHigh = na
var float lastObSwingLow = na

if not na(obPh)
    lastObSwingHigh := obPh

if not na(obPl)
    lastObSwingLow := obPl

obBullDisplacement = close > open and obBody >= obAtr * obDispMult
obBearDisplacement = close < open and obBody >= obAtr * obDispMult

obBullFvg = low > high[2] and (low - high[2]) >= obAtr * obFvgAtrMult
obBearFvg = high < low[2] and (low[2] - high) >= obAtr * obFvgAtrMult

// Last opposite candle = previous candle.
// Bullish OB: previous candle is bearish and breaks below its own previous candle's low.
// Bearish OB: previous candle is bullish and breaks above its own previous candle's high.
obBullCandle = close[1] < open[1] and low[1] < low[2]
obBearCandle = close[1] > open[1] and high[1] > high[2]

obBullBos = not na(lastObSwingHigh) and close > lastObSwingHigh
obBearBos = not na(lastObSwingLow) and close < lastObSwingLow

newBullOB = showOB and obBullCandle and obBullDisplacement and obBullFvg and obBullBos
newBearOB = showOB and obBearCandle and obBearDisplacement and obBearFvg and obBearBos

if newBullOB
    bullishObCreated := true
    obGap = low - high[2]
    obQuality = f_obQuality(obBody, obGap, obAtr, volume, ta.sma(volume, 20))
    [obBuyPct, obSellPct] = f_obVolSplit(open[1], close[1], high[1], low[1])
    mergedTop = high[1]
    mergedBottom = low[1]
    if activeBullOBs.size() > 0
        for j = activeBullOBs.size() - 1 to 0
            old = activeBullOBs.get(j)
            overlaps = mergedBottom <= old.top and mergedTop >= old.bottom
            if overlaps
                mergedTop := math.max(mergedTop, old.top)
                mergedBottom := math.min(mergedBottom, old.bottom)
                old.bx.delete()
                activeBullOBs.remove(j)
    bullBx = box.new(bar_index - 1, mergedTop, bar_index + obExtendBars, mergedBottom, bgcolor=bullObCol, border_color=color.new(bullObCol, 20), text=f_obText("BOB", obQuality, obBuyPct, obSellPct), text_color=chart.fg_color, text_size=size.tiny, text_halign=text.align_left, text_valign=text.align_center)
    activeBullOBs.unshift(obObj.new(bullBx, mergedTop, mergedBottom, true, false, false, obQuality, obBuyPct, obSellPct))

if newBearOB
    bearishObCreated := true
    obGap = low[2] - high
    obQuality = f_obQuality(obBody, obGap, obAtr, volume, ta.sma(volume, 20))
    [obBuyPct, obSellPct] = f_obVolSplit(open[1], close[1], high[1], low[1])
    mergedTop = high[1]
    mergedBottom = low[1]
    if activeBearOBs.size() > 0
        for j = activeBearOBs.size() - 1 to 0
            old = activeBearOBs.get(j)
            overlaps = mergedBottom <= old.top and mergedTop >= old.bottom
            if overlaps
                mergedTop := math.max(mergedTop, old.top)
                mergedBottom := math.min(mergedBottom, old.bottom)
                old.bx.delete()
                activeBearOBs.remove(j)
    bearBx = box.new(bar_index - 1, mergedTop, bar_index + obExtendBars, mergedBottom, bgcolor=bearObCol, border_color=color.new(bearObCol, 20), text=f_obText("SOB", obQuality, obBuyPct, obSellPct), text_color=chart.fg_color, text_size=size.tiny, text_halign=text.align_left, text_valign=text.align_center)
    activeBearOBs.unshift(obObj.new(bearBx, mergedTop, mergedBottom, false, false, false, obQuality, obBuyPct, obSellPct))

if activeBullOBs.size() > 0
    for i = activeBullOBs.size() - 1 to 0
        ob = activeBullOBs.get(i)
        if not ob.mitigated
            ob.bx.set_right(bar_index + obExtendBars)
            inZone = low <= ob.top and high >= ob.bottom
            if inZone and not ob.tapped
                ob.tapped := true
                bullishObTapped := true
                if ob.quality == "Strong"
                    strongBullishObTapped := true
                if obAlertTaps
                    alert((ob.quality == "Strong" ? "Strong Bull OB tapped" : "Price tapped Bullish Institutional OB") + " on " + syminfo.ticker + " " + timeframe.period, alert.freq_once_per_bar)
            mitigated = obMitigationRule == "Close" ? close < ob.bottom : low < ob.bottom
            if mitigated
                ob.mitigated := true
                ob.bx.set_right(bar_index)
        activeBullOBs.set(i, ob)

while activeBullOBs.size() > obMaxDisplay
    oldOb = activeBullOBs.pop()
    oldOb.bx.delete()

if activeBearOBs.size() > 0
    for i = activeBearOBs.size() - 1 to 0
        ob = activeBearOBs.get(i)
        if not ob.mitigated
            ob.bx.set_right(bar_index + obExtendBars)
            inZone = low <= ob.top and high >= ob.bottom
            if inZone and not ob.tapped
                ob.tapped := true
                bearishObTapped := true
                if ob.quality == "Strong"
                    strongBearishObTapped := true
                if obAlertTaps
                    alert((ob.quality == "Strong" ? "Strong Bear OB tapped" : "Price tapped Bearish Institutional OB") + " on " + syminfo.ticker + " " + timeframe.period, alert.freq_once_per_bar)
            mitigated = obMitigationRule == "Close" ? close > ob.top : high > ob.top
            if mitigated
                ob.mitigated := true
                ob.bx.set_right(bar_index)
        activeBearOBs.set(i, ob)

while activeBearOBs.size() > obMaxDisplay
    oldOb = activeBearOBs.pop()
    oldOb.bx.delete()


//==============================================================================
// DECISION CONFLUENCE TABLE
// Compact decision table for the highest-value execution clues from this indicator.
//==============================================================================

if ifvgBullCompleted
    lastIfvgText := "Bull IFVG"
    lastIfvgDir := 1
    lastIfvgExpire := bar_index + 20
if ifvgBearCompleted
    lastIfvgText := "Bear IFVG"
    lastIfvgDir := -1
    lastIfvgExpire := bar_index + 20
if not na(lastIfvgExpire) and bar_index > lastIfvgExpire
    lastIfvgText := "None"
    lastIfvgDir := 0

if bullSweep
    lastSweepText := "Bull Sweep"
    lastSweepDir := 1
    lastSweepExpire := bar_index + 20
if bearSweep
    lastSweepText := "Bear Sweep"
    lastSweepDir := -1
    lastSweepExpire := bar_index + 20
if not na(lastSweepExpire) and bar_index > lastSweepExpire
    lastSweepText := "None"
    lastSweepDir := 0

if bullishObCreated
    lastObText := "Bull OB"
    lastObDir := 1
    lastObExpire := bar_index + 30
if bearishObCreated
    lastObText := "Bear OB"
    lastObDir := -1
    lastObExpire := bar_index + 30
if strongBullishObTapped
    lastObText := "Strong Bull OB Tap"
    lastObDir := 1
    lastObExpire := bar_index + 20
if strongBearishObTapped
    lastObText := "Strong Bear OB Tap"
    lastObDir := -1
    lastObExpire := bar_index + 20
if not na(lastObExpire) and bar_index > lastObExpire
    lastObText := "None"
    lastObDir := 0

if bullCisdTriggered
    cisdText := "BCISD"
if bearCisdTriggered
    cisdText := "SCISD"

var table decisionTable = table.new(decisionTablePos, 2, 7, border_width=0, border_color=color.new(chart.fg_color, 100), frame_color=color.new(chart.fg_color, 100), frame_width=0)

if barstate.islast and showDecisionTable
    table.cell(decisionTable, 0, 0, "Item", bgcolor=color.black, text_color=color.white, text_size=decisionTextSize)
    table.cell(decisionTable, 1, 0, "Signal", bgcolor=color.black, text_color=color.white, text_size=decisionTextSize)

    _cisdDir = cisdText == "BCISD" ? 1 : cisdText == "SCISD" ? -1 : 0
    table.cell(decisionTable, 0, 1, "CISD", bgcolor=color.new(color.gray, 75), text_color=chart.fg_color, text_size=decisionTextSize)
    table.cell(decisionTable, 1, 1, cisdText, bgcolor=f_signalBg(_cisdDir), text_color=f_signalTextColor(_cisdDir), text_size=decisionTextSize)

    table.cell(decisionTable, 0, 2, "IFVG", bgcolor=color.new(color.gray, 75), text_color=chart.fg_color, text_size=decisionTextSize)
    table.cell(decisionTable, 1, 2, lastIfvgText, bgcolor=f_signalBg(lastIfvgDir), text_color=f_signalTextColor(lastIfvgDir), text_size=decisionTextSize)

    table.cell(decisionTable, 0, 3, "OB", bgcolor=color.new(color.gray, 75), text_color=chart.fg_color, text_size=decisionTextSize)
    table.cell(decisionTable, 1, 3, lastObText, bgcolor=f_signalBg(lastObDir), text_color=f_signalTextColor(lastObDir), text_size=decisionTextSize)

    _srTableText = lastSrText != "None" ? lastSrText : currentSrText
    _srTableDir = lastSrText != "None" ? lastSrDir : currentSrDir
    table.cell(decisionTable, 0, 4, "S/R", bgcolor=color.new(color.gray, 75), text_color=chart.fg_color, text_size=decisionTextSize)
    table.cell(decisionTable, 1, 4, _srTableText, bgcolor=f_signalBg(_srTableDir), text_color=f_signalTextColor(_srTableDir), text_size=decisionTextSize)

    table.cell(decisionTable, 0, 5, "Sweep", bgcolor=color.new(color.gray, 75), text_color=chart.fg_color, text_size=decisionTextSize)
    table.cell(decisionTable, 1, 5, lastSweepText, bgcolor=f_signalBg(lastSweepDir), text_color=f_signalTextColor(lastSweepDir), text_size=decisionTextSize)

    _biasScore = _cisdDir + lastIfvgDir + lastObDir + _srTableDir + lastSweepDir
    _biasDir = _biasScore >= 2 ? 1 : _biasScore <= -2 ? -1 : 0
    _biasText = _biasDir == 1 ? "Bull Bias" : _biasDir == -1 ? "Bear Bias" : "Mixed"
    table.cell(decisionTable, 0, 6, "Bias", bgcolor=color.new(color.gray, 75), text_color=chart.fg_color, text_size=decisionTextSize)
    table.cell(decisionTable, 1, 6, _biasText, bgcolor=f_signalBg(_biasDir), text_color=f_signalTextColor(_biasDir), text_size=decisionTextSize)

if barstate.islast and not showDecisionTable
    table.clear(decisionTable, 0, 0, 1, 6)

//==============================================================================
// ALERT CONDITIONS - these appear as selectable alert options in TradingView
//==============================================================================

alertcondition(ifvgBearBeginning, title="Bearish IFVG Beginning", message="Bearish IFVG is beginning to form on {{ticker}} {{interval}}")
alertcondition(ifvgBullBeginning, title="Bullish IFVG Beginning", message="Bullish IFVG is beginning to form on {{ticker}} {{interval}}")
alertcondition(ifvgBearCompleted, title="Bearish IFVG Completed", message="Bearish IFVG completed on {{ticker}} {{interval}}")
alertcondition(ifvgBullCompleted, title="Bullish IFVG Completed", message="Bullish IFVG completed on {{ticker}} {{interval}}")

alertcondition(bullishSweepZoneTouched, title="Bullish Sweep Zone Touched", message="Price touched the top of a Bullish Sweep Zone on {{ticker}} {{interval}}")
alertcondition(bearishSweepZoneTouched, title="Bearish Sweep Zone Touched", message="Price touched the top of a Bearish Sweep Zone on {{ticker}} {{interval}}")

alertcondition(bullishObCreated, title="Bullish Institutional OB Created", message="Bullish Institutional OB created on {{ticker}} {{interval}}")
alertcondition(bearishObCreated, title="Bearish Institutional OB Created", message="Bearish Institutional OB created on {{ticker}} {{interval}}")
alertcondition(bullishObTapped, title="Bullish Institutional OB Tapped", message="Price tapped a Bullish Institutional OB on {{ticker}} {{interval}}")
alertcondition(bearishObTapped, title="Bearish Institutional OB Tapped", message="Price tapped a Bearish Institutional OB on {{ticker}} {{interval}}")
alertcondition(strongBullishObTapped, title="Strong Bull OB Tapped", message="Strong Bull OB tapped on {{ticker}} {{interval}}")
alertcondition(strongBearishObTapped, title="Strong Bear OB Tapped", message="Strong Bear OB tapped on {{ticker}} {{interval}}")
alertcondition(bullSrTouched, title="Support Zone Rejection", message="Price rejected from a Dynamic Support zone on {{ticker}} {{interval}}")
alertcondition(bearSrTouched, title="Resistance Zone Rejection", message="Price rejected from a Dynamic Resistance zone on {{ticker}} {{interval}}")
alertcondition(strongBullSrTouched, title="Strong Support Rejection", message="Strong Dynamic Support rejection on {{ticker}} {{interval}}")
alertcondition(strongBearSrTouched, title="Strong Resistance Rejection", message="Strong Dynamic Resistance rejection on {{ticker}} {{interval}}")
alertcondition(bullCisdTriggered, title="BCISD Printed", message="BCISD printed on {{ticker}} {{interval}}")
alertcondition(bearCisdTriggered, title="SCISD Printed", message="SCISD printed on {{ticker}} {{interval}}")
````
