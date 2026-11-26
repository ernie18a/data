# EW Auto-Custom Elliott Wave  Indicator with Fibonacci

- url: https://www.tradingview.com/script/KXHDluu9-EW-Auto-Custom-Elliott-Wave-Indicator-with-Fibonacci/
- type: indicator
- pine_id: PUB;f3e7515dc79649b0b9eda55a3c3826f5
- version: 3.0

## Description

EW Auto — Custom Elliott Wave 
Indicator with Fibonacci + EMA

WHAT IT DOES:
This indicator automatically detects 
Elliott Wave structures (1-2-3-4-5) 
on any chart using pivot high and low 
detection. It combines three core 
concepts into one unified tool:

1. ELLIOTT WAVE AUTO-DETECTION
Uses pivot highs and lows to 
automatically identify and label 
the 5-wave impulse structure in 
both bullish and bearish directions.
Wave labels appear directly on 
swing points so you can instantly 
see where price is in the cycle.

2. FIBONACCI LEVELS
Automatically draws retracement 
levels (23.6%, 38.2%, 50%, 61.8%, 
78.6%) from the detected wave 
structure. Extension targets at 
127.2% and 161.8% are drawn as 
potential wave 5 price targets.

3. EMA TREND FILTER
EMA 20 and EMA 50 are plotted 
to confirm wave direction. When 
price is above both EMAs with 
EMA20 above EMA50 the trend is 
bullish. When below both the 
trend is bearish.

4. CANDLE PATTERN DETECTION
Hammer and Shooting Star candles 
are automatically detected and 
labeled H and S on the chart.
Hammers appear at wave bottoms 
as buy confirmation. Stars appear 
at wave tops as sell confirmation.

5. INFO TABLE
A dashboard in the top right corner 
shows current wave direction, EMA 
trend status, EMA values and latest 
candle pattern in real time.

HOW TO USE:
- Increase Pivot Length for 
  smoother waves on higher 
  timeframes (8-10 on daily)
- Decrease for more signals 
  on intraday charts (3-5)
- Buy when Wave label shows 
  early wave 1 or wave 3 with 
  EMA aligned bullish
- Sell or short when wave 5 
  completes with S signal and 
  EMA turns bearish
- Use 38.2% and 50% fib levels 
  as wave 4 buy zones
- Use 127% and 162% extensions 
  as wave 5 profit targets

SETTINGS:
- Pivot Length: sensitivity control
- Toggle Fibonacci on or off
- Toggle wave labels on or off
- Toggle wave lines on or off
- Toggle hammer detection on or off
- Toggle info table on or off
- Customise all colors

Works on all timeframes and 
all markets including stocks, 
indices, forex and crypto.

NOTE: Elliott Wave analysis is 
subjective. This tool is for 
educational purposes. Always 
use proper risk management.

Coded in Pine Script v6.

## Source Code

````pine
//@version=6
indicator("WavePilot Pro [Elliott + Fib + Volume + ADX + Divergence]", overlay=true, max_labels_count=500, max_lines_count=500)

grp1 = "Wave Settings"
pivotLen   = input.int(5,     "Pivot Length",    minval=2, maxval=20, group=grp1)
showLabels = input.bool(true, "Wave Labels",     group=grp1)
showLines  = input.bool(true, "Wave Lines",      group=grp1)
showFib    = input.bool(true, "Fibonacci",       group=grp1)
showHammer = input.bool(true, "Hammers Stars",   group=grp1)
showTable  = input.bool(true, "Info Table",      group=grp1)
showDir    = input.bool(true, "Direction Label", group=grp1)

grp2 = "Colors"
colUp   = input.color(color.orange, "Bull Color", group=grp2)
colDown = input.color(color.red,    "Bear Color", group=grp2)
colFib  = input.color(color.blue,   "Fib Color",  group=grp2)
colExt  = input.color(color.teal,   "Ext Color",  group=grp2)

grp3 = "Volume"
showVol  = input.bool(true,  "Show Volume Signal",   group=grp3)
volMult  = input.float(2.0,  "Volume Spike x avg",   minval=1.0, maxval=5.0, group=grp3)

grp4 = "ADX"
showADX  = input.bool(true, "Show ADX Strength",     group=grp4)
adxLen   = input.int(14,    "ADX Length",             minval=5, maxval=30, group=grp4)
adxLevel = input.int(25,    "Strong Trend Level",     minval=15, maxval=40, group=grp4)

grp5 = "Divergence"
showDiv  = input.bool(true, "Show Divergence",        group=grp5)
divLen   = input.int(5,     "Divergence Lookback",    minval=3, maxval=20, group=grp5)

grp6 = "Risk Reward"
showRR   = input.bool(true,  "Show SL and TP Lines",  group=grp6)
rrRatio  = input.float(2.0,  "RR Ratio",              minval=1.0, maxval=5.0, group=grp6)

grp7 = "Sessions"
showSess  = input.bool(true, "Show Sessions",          group=grp7)
showIndia = input.bool(true, "India Session",          group=grp7)
showUS    = input.bool(true, "US Session",             group=grp7)

pivHigh = ta.pivothigh(high, pivotLen, pivotLen)
pivLow  = ta.pivotlow(low,  pivotLen, pivotLen)

var float[] phVals = array.new_float(0)
var int[]   phBars = array.new_int(0)
var float[] plVals = array.new_float(0)
var int[]   plBars = array.new_int(0)

if not na(pivHigh)
    array.unshift(phVals, pivHigh)
    array.unshift(phBars, bar_index - pivotLen)
    if array.size(phVals) > 10
        array.pop(phVals)
        array.pop(phBars)

if not na(pivLow)
    array.unshift(plVals, pivLow)
    array.unshift(plBars, bar_index - pivotLen)
    if array.size(plVals) > 10
        array.pop(plVals)
        array.pop(plBars)

var label[] waveLabels = array.new_label(0)
var line[]  waveLines  = array.new_line(0)

while array.size(waveLabels) > 20
    label.delete(array.shift(waveLabels))
while array.size(waveLines) > 25
    line.delete(array.shift(waveLines))

phSize    = array.size(phVals)
plSize    = array.size(plVals)
bullTrend = plSize >= 2 and array.get(plVals, 0) > array.get(plVals, 1)
bearTrend = phSize >= 2 and array.get(phVals, 0) < array.get(phVals, 1)

ema20   = ta.ema(close, 20)
ema50   = ta.ema(close, 50)
rsi     = ta.rsi(close, 14)
emaBull = close > ema20 and ema20 > ema50
emaBear = close < ema20 and ema20 < ema50

upMove   = ta.change(high)
downMove = -ta.change(low)
pDM      = na(upMove)   ? na : upMove > downMove   and upMove > 0   ? upMove   : 0
mDM      = na(downMove) ? na : downMove > upMove   and downMove > 0 ? downMove : 0
trur     = ta.rma(ta.tr, adxLen)
pDI      = fixnan(100 * ta.rma(pDM, adxLen) / trur)
mDI      = fixnan(100 * ta.rma(mDM, adxLen) / trur)
dx       = pDI + mDI
adx      = ta.rma(100 * math.abs(pDI - mDI) / math.max(dx, 1), adxLen)
trendStr = adx >= adxLevel

volAvg   = ta.sma(volume, 20)
volSpike = volume >= volAvg * volMult

rsiHigh   = ta.pivothigh(rsi,  divLen, divLen)
rsiLow    = ta.pivotlow(rsi,   divLen, divLen)
priceHigh = ta.pivothigh(high, divLen, divLen)
priceLow  = ta.pivotlow(low,   divLen, divLen)

ph1 = ta.valuewhen(not na(priceHigh), priceHigh, 1)
pl1 = ta.valuewhen(not na(priceLow),  priceLow,  1)
rh1 = ta.valuewhen(not na(rsiHigh),   rsiHigh,   1)
rl1 = ta.valuewhen(not na(rsiLow),    rsiLow,    1)

bearDiv = not na(rsiHigh) and not na(priceHigh) and priceHigh > ph1 and rsiHigh < rh1
bullDiv = not na(rsiLow)  and not na(priceLow)  and priceLow  < pl1 and rsiLow  > rl1

bs = (bullTrend ? 1 : 0) + (emaBull ? 1 : 0) + (rsi > 50 ? 1 : 0) + (trendStr ? 1 : 0) + (volSpike and close > open ? 1 : 0)
rs = (bearTrend ? 1 : 0) + (emaBear ? 1 : 0) + (rsi < 50 ? 1 : 0) + (trendStr ? 1 : 0) + (volSpike and close < open ? 1 : 0)

if showLabels and phSize >= 3 and plSize >= 3 and bullTrend
    float w0 = array.get(plVals, 2)
    int   b0 = array.get(plBars, 2)
    float w1 = array.get(phVals, 2)
    int   b1 = array.get(phBars, 2)
    float w2 = array.get(plVals, 1)
    int   b2 = array.get(plBars, 1)
    float w3 = array.get(phVals, 1)
    int   b3 = array.get(phBars, 1)
    float w4 = array.get(plVals, 0)
    int   b4 = array.get(plBars, 0)
    float w5 = array.get(phVals, 0)
    int   b5 = array.get(phBars, 0)
    if w3 > w1 and w2 > w0 and w4 > w1
        if showLines
            array.push(waveLines, line.new(b0, w0, b1, w1, color=colUp,   width=2))
            array.push(waveLines, line.new(b1, w1, b2, w2, color=colDown, width=2))
            array.push(waveLines, line.new(b2, w2, b3, w3, color=colUp,   width=2))
            array.push(waveLines, line.new(b3, w3, b4, w4, color=colDown, width=2))
            array.push(waveLines, line.new(b4, w4, b5, w5, color=colUp,   width=2))
        array.push(waveLabels, label.new(b1, w1, "1", color=color.new(colUp,80),   textcolor=colUp,   style=label.style_label_down, size=size.normal))
        array.push(waveLabels, label.new(b2, w2, "2", color=color.new(colDown,80), textcolor=colDown, style=label.style_label_up,   size=size.normal))
        array.push(waveLabels, label.new(b3, w3, "3", color=color.new(colUp,80),   textcolor=colUp,   style=label.style_label_down, size=size.normal))
        array.push(waveLabels, label.new(b4, w4, "4", color=color.new(colDown,80), textcolor=colDown, style=label.style_label_up,   size=size.normal))
        array.push(waveLabels, label.new(b5, w5, "5", color=color.new(colUp,80),   textcolor=colUp,   style=label.style_label_down, size=size.normal))
        if showFib
            r    = w5 - w0
            r236 = w5 - 0.236 * r
            r382 = w5 - 0.382 * r
            r500 = w5 - 0.500 * r
            r618 = w5 - 0.618 * r
            r786 = w5 - 0.786 * r
            e127 = w5 + 0.272 * r
            e162 = w5 + 0.618 * r
            array.push(waveLines,  line.new(b5, r236, b5+30, r236, color=colFib, style=line.style_dashed, width=1, extend=extend.right))
            array.push(waveLabels, label.new(b5+32, r236, "23.6",    color=color.new(colFib,85), textcolor=colFib, style=label.style_label_left, size=size.small))
            array.push(waveLines,  line.new(b5, r382, b5+30, r382, color=colFib, style=line.style_dashed, width=1, extend=extend.right))
            array.push(waveLabels, label.new(b5+32, r382, "38.2",    color=color.new(colFib,85), textcolor=colFib, style=label.style_label_left, size=size.small))
            array.push(waveLines,  line.new(b5, r500, b5+30, r500, color=colFib, style=line.style_dashed, width=1, extend=extend.right))
            array.push(waveLabels, label.new(b5+32, r500, "50.0",    color=color.new(colFib,85), textcolor=colFib, style=label.style_label_left, size=size.small))
            array.push(waveLines,  line.new(b5, r618, b5+30, r618, color=colFib, style=line.style_dashed, width=1, extend=extend.right))
            array.push(waveLabels, label.new(b5+32, r618, "61.8",    color=color.new(colFib,85), textcolor=colFib, style=label.style_label_left, size=size.small))
            array.push(waveLines,  line.new(b5, r786, b5+30, r786, color=colFib, style=line.style_dashed, width=1, extend=extend.right))
            array.push(waveLabels, label.new(b5+32, r786, "78.6",    color=color.new(colFib,85), textcolor=colFib, style=label.style_label_left, size=size.small))
            array.push(waveLines,  line.new(b5, e127, b5+30, e127, color=colExt, style=line.style_dashed, width=1, extend=extend.right))
            array.push(waveLabels, label.new(b5+32, e127, "127 TGT", color=color.new(colExt,85), textcolor=colExt, style=label.style_label_left, size=size.small))
            array.push(waveLines,  line.new(b5, e162, b5+30, e162, color=colExt, style=line.style_dashed, width=1, extend=extend.right))
            array.push(waveLabels, label.new(b5+32, e162, "162 TGT", color=color.new(colExt,85), textcolor=colExt, style=label.style_label_left, size=size.small))

if showLabels and phSize >= 3 and plSize >= 3 and bearTrend and not bullTrend
    float w0 = array.get(phVals, 2)
    int   b0 = array.get(phBars, 2)
    float w1 = array.get(plVals, 2)
    int   b1 = array.get(plBars, 2)
    float w2 = array.get(phVals, 1)
    int   b2 = array.get(phBars, 1)
    float w3 = array.get(plVals, 1)
    int   b3 = array.get(plBars, 1)
    float w4 = array.get(phVals, 0)
    int   b4 = array.get(phBars, 0)
    float w5 = array.get(plVals, 0)
    int   b5 = array.get(plBars, 0)
    if w3 < w1 and w2 < w0 and w4 < w1
        if showLines
            array.push(waveLines, line.new(b0, w0, b1, w1, color=colDown, width=2))
            array.push(waveLines, line.new(b1, w1, b2, w2, color=colUp,   width=2))
            array.push(waveLines, line.new(b2, w2, b3, w3, color=colDown, width=2))
            array.push(waveLines, line.new(b3, w3, b4, w4, color=colUp,   width=2))
            array.push(waveLines, line.new(b4, w4, b5, w5, color=colDown, width=2))
        array.push(waveLabels, label.new(b1, w1, "1", color=color.new(colDown,80), textcolor=colDown, style=label.style_label_up,   size=size.normal))
        array.push(waveLabels, label.new(b2, w2, "2", color=color.new(colUp,80),   textcolor=colUp,   style=label.style_label_down, size=size.normal))
        array.push(waveLabels, label.new(b3, w3, "3", color=color.new(colDown,80), textcolor=colDown, style=label.style_label_up,   size=size.normal))
        array.push(waveLabels, label.new(b4, w4, "4", color=color.new(colUp,80),   textcolor=colUp,   style=label.style_label_down, size=size.normal))
        array.push(waveLabels, label.new(b5, w5, "5", color=color.new(colDown,80), textcolor=colDown, style=label.style_label_up,   size=size.normal))
        if showFib
            r    = w0 - w5
            r236 = w5 + 0.236 * r
            r382 = w5 + 0.382 * r
            r500 = w5 + 0.500 * r
            r618 = w5 + 0.618 * r
            r786 = w5 + 0.786 * r
            e127 = w5 - 0.272 * r
            e162 = w5 - 0.618 * r
            array.push(waveLines,  line.new(b5, r236, b5+30, r236, color=colFib, style=line.style_dashed, width=1, extend=extend.right))
            array.push(waveLabels, label.new(b5+32, r236, "23.6",    color=color.new(colFib,85), textcolor=colFib, style=label.style_label_left, size=size.small))
            array.push(waveLines,  line.new(b5, r382, b5+30, r382, color=colFib, style=line.style_dashed, width=1, extend=extend.right))
            array.push(waveLabels, label.new(b5+32, r382, "38.2",    color=color.new(colFib,85), textcolor=colFib, style=label.style_label_left, size=size.small))
            array.push(waveLines,  line.new(b5, r500, b5+30, r500, color=colFib, style=line.style_dashed, width=1, extend=extend.right))
            array.push(waveLabels, label.new(b5+32, r500, "50.0",    color=color.new(colFib,85), textcolor=colFib, style=label.style_label_left, size=size.small))
            array.push(waveLines,  line.new(b5, r618, b5+30, r618, color=colFib, style=line.style_dashed, width=1, extend=extend.right))
            array.push(waveLabels, label.new(b5+32, r618, "61.8",    color=color.new(colFib,85), textcolor=colFib, style=label.style_label_left, size=size.small))
            array.push(waveLines,  line.new(b5, r786, b5+30, r786, color=colFib, style=line.style_dashed, width=1, extend=extend.right))
            array.push(waveLabels, label.new(b5+32, r786, "78.6",    color=color.new(colFib,85), textcolor=colFib, style=label.style_label_left, size=size.small))
            array.push(waveLines,  line.new(b5, e127, b5+30, e127, color=colExt, style=line.style_dashed, width=1, extend=extend.right))
            array.push(waveLabels, label.new(b5+32, e127, "127 TGT", color=color.new(colExt,85), textcolor=colExt, style=label.style_label_left, size=size.small))
            array.push(waveLines,  line.new(b5, e162, b5+30, e162, color=colExt, style=line.style_dashed, width=1, extend=extend.right))
            array.push(waveLabels, label.new(b5+32, e162, "162 TGT", color=color.new(colExt,85), textcolor=colExt, style=label.style_label_left, size=size.small))

bodySize   = math.abs(close - open)
totalRange = high - low
upperWick  = high - math.max(close, open)
lowerWick  = math.min(close, open) - low
isHammer   = showHammer and totalRange > 0 and lowerWick >= 2 * bodySize and upperWick <= bodySize * 0.5
isStar     = showHammer and totalRange > 0 and upperWick >= 2 * bodySize and lowerWick <= bodySize * 0.5

if isHammer
    label.new(bar_index, low,  "H", color=color.new(color.lime,60), textcolor=color.white, style=label.style_label_up,   size=size.small)
if isStar
    label.new(bar_index, high, "S", color=color.new(color.red,60),  textcolor=color.white, style=label.style_label_down, size=size.small)

if showVol and volSpike
    vc = close >= open ? color.new(color.yellow,20) : color.new(color.orange,20)
    label.new(bar_index, low, "VOL", color=vc, textcolor=color.black, style=label.style_label_up, size=size.small)

if showDiv and bearDiv
    label.new(bar_index - divLen, high[divLen], "BEAR DIV", color=color.new(color.red,30),  textcolor=color.white, style=label.style_label_down, size=size.small)
if showDiv and bullDiv
    label.new(bar_index - divLen, low[divLen],  "BULL DIV", color=color.new(color.lime,30), textcolor=color.white, style=label.style_label_up,   size=size.small)

plot(ema20, "EMA20", color=color.new(color.red,  20), linewidth=1)
plot(ema50, "EMA50", color=color.new(color.blue, 20), linewidth=1)

indiaOpen  = "0915-1530"
usOpen     = "0930-1600"
inIndia    = not na(time(timeframe.period, indiaOpen, "Asia/Kolkata"))
inUS       = not na(time(timeframe.period, usOpen,    "America/New_York"))

bgcolor(showSess and showIndia and inIndia ? color.new(color.blue,   96) : na, title="India Session")
bgcolor(showSess and showUS    and inUS    ? color.new(color.purple, 96) : na, title="US Session")

atr      = ta.atr(14)
slDist   = atr * 1.5
tpDist   = slDist * rrRatio
slLine   = bs >= 3 ? close - slDist : rs >= 3 ? close + slDist : na
tpLine   = bs >= 3 ? close + tpDist : rs >= 3 ? close - tpDist : na

plot(showRR and not na(slLine) ? slLine : na, "Stop Loss",   color=color.new(color.red,  40), linewidth=1, style=plot.style_linebr)
plot(showRR and not na(tpLine) ? tpLine : na, "Take Profit", color=color.new(color.lime, 40), linewidth=1, style=plot.style_linebr)

dirText  = bs >= 3 ? "LOOK LONG"  : rs >= 3 ? "LOOK SHORT" : "STAY OUT"
dirColor = bs >= 3 ? color.new(color.lime,20) : rs >= 3 ? color.new(color.red,20) : color.new(color.orange,20)

if showDir and barstate.islast
    label.new(bar_index + 5, close, dirText, color=dirColor, textcolor=color.white, style=label.style_label_left, size=size.large)

bgCol = bs >= 3 ? color.new(color.green,95) : rs >= 3 ? color.new(color.red,95) : na
bgcolor(bgCol, title="Trend Background")

if showTable and barstate.islast
    var table t = table.new(position.top_right, 2, 11, border_width=1, border_color=color.gray, bgcolor=color.new(color.black,60))
    wp   = bullTrend ? "UP"   : bearTrend ? "DOWN" : "CORR"
    es   = emaBull   ? "BULL" : emaBear   ? "BEAR" : "MIXED"
    ris  = rsi > 70  ? "OVERBOUGHT" : rsi < 30 ? "OVERSOLD" : rsi > 50 ? "BULLISH" : "BEARISH"
    ads  = trendStr  ? "STRONG " + str.tostring(math.round(adx)) : "WEAK " + str.tostring(math.round(adx))
    vols = volSpike  ? "SPIKE " + str.tostring(math.round(volume/volAvg, 1)) + "x" : "normal"
    divs = bearDiv   ? "BEAR DIV" : bullDiv ? "BULL DIV" : "-"
    cn   = isHammer  ? "HAMMER"   : isStar  ? "STAR"     : "-"
    sess = inIndia   ? "INDIA"    : inUS     ? "US"       : "OFF"
    e20s = str.tostring(ema20, "#.##")
    e50s = str.tostring(ema50, "#.##")
    sc   = str.tostring(bs >= rs ? bs : rs) + "/5"
    dirT = bs >= 3   ? "LOOK LONG" : rs >= 3 ? "LOOK SHORT" : "STAY OUT"
    dirC = bs >= 3   ? color.lime  : rs >= 3 ? color.red    : color.orange

    table.cell(t, 0, 0,  "WavePilot Pro", bgcolor=color.navy, text_color=color.white, text_size=size.small)
    table.cell(t, 1, 0,  "STATUS",        bgcolor=color.navy, text_color=color.white, text_size=size.small)
    table.cell(t, 0, 1,  "DIRECTION",     text_color=color.gray,  text_size=size.small)
    table.cell(t, 1, 1,  dirT,            text_color=dirC,        text_size=size.small)
    table.cell(t, 0, 2,  "Wave",          text_color=color.gray,  text_size=size.small)
    table.cell(t, 1, 2,  wp,              text_color=color.white, text_size=size.small)
    table.cell(t, 0, 3,  "EMA",           text_color=color.gray,  text_size=size.small)
    table.cell(t, 1, 3,  es,              text_color=color.white, text_size=size.small)
    table.cell(t, 0, 4,  "RSI",           text_color=color.gray,  text_size=size.small)
    table.cell(t, 1, 4,  ris,             text_color=color.white, text_size=size.small)
    table.cell(t, 0, 5,  "ADX",           text_color=color.gray,  text_size=size.small)
    table.cell(t, 1, 5,  ads,             text_color=color.white, text_size=size.small)
    table.cell(t, 0, 6,  "Volume",        text_color=color.gray,  text_size=size.small)
    table.cell(t, 1, 6,  vols,            text_color=color.white, text_size=size.small)
    table.cell(t, 0, 7,  "Divergence",    text_color=color.gray,  text_size=size.small)
    table.cell(t, 1, 7,  divs,            text_color=color.white, text_size=size.small)
    table.cell(t, 0, 8,  "Candle",        text_color=color.gray,  text_size=size.small)
    table.cell(t, 1, 8,  cn,              text_color=color.white, text_size=size.small)
    table.cell(t, 0, 9,  "Session",       text_color=color.gray,  text_size=size.small)
    table.cell(t, 1, 9,  sess,            text_color=color.white, text_size=size.small)
    table.cell(t, 0, 10, "Score",         text_color=color.gray,  text_size=size.small)
    table.cell(t, 1, 10, sc,              text_color=color.white, text_size=size.small)

alertcondition(bs >= 3,   title="LOOK LONG",       message="WavePilot: LOOK LONG signal!")
alertcondition(rs >= 3,   title="LOOK SHORT",      message="WavePilot: LOOK SHORT signal!")
alertcondition(isHammer,  title="Hammer",          message="WavePilot: Hammer detected!")
alertcondition(isStar,    title="Shooting Star",   message="WavePilot: Shooting Star detected!")
alertcondition(volSpike,  title="Volume Spike",    message="WavePilot: Volume spike!")
alertcondition(bullDiv,   title="Bull Divergence", message="WavePilot: Bullish Divergence!")
alertcondition(bearDiv,   title="Bear Divergence", message="WavePilot: Bearish Divergence!")
alertcondition(rsi < 30,  title="RSI Oversold",    message="WavePilot: RSI oversold!")
alertcondition(rsi > 70,  title="RSI Overbought",  message="WavePilot: RSI overbought!")
````
