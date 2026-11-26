# EMA/SMA + Inside Bar + Liquidity Tag BY RAVI

- url: https://www.tradingview.com/script/3aSUNvQR-EMA-SMA-Inside-Bar-Liquidity-Tag-BY-RAVI/
- type: indicator
- pine_id: PUB;e1e709631f6f448d9769103acb42e6ac
- version: 1.0

## Description

EMA/SMA + Inside Bar + Liquidity Tag
An all-in-one overlay that combines three tools traders usually run separately: a flexible moving-average suite, automatic inside-bar detection, and a live liquidity (traded-value) tag on the latest candle. Built for Pine Script v6.
What it does
1. Moving Averages (5, 10, 20, 50, 100, 200)
Six independent moving-average lines. Each line can be set to EMA or SMA on its own, so you can mix freely (for example, a 20 EMA alongside a 50 and 200 SMA). Every line has its own on/off toggle, colour, and width control (1 = thinnest, 4 = thickest). A single Source input controls which price all the lines are calculated from.
2. Inside Bar Highlighter
Automatically detects inside bars — candles whose entire range sits within the previous candle's range — and recolours the whole candle so they are easy to spot. The highlight colour is fully customizable. A Strict/Inclusive switch lets you choose between a true inside bar (current high below the previous high and current low above the previous low) or an inclusive version that also counts candles touching the previous high or low.
3. Liquidity Tag
Places a label above (or below) the most recent candle showing the stock's liquidity, formatted in crores by default (e.g. "405.98 Cr"). Three calculation methods are available:
20-Day Avg Liquidity (default): A 20-day volume-weighted average price multiplied by the 20-day average daily volume, which equals the average daily traded value. This is the most representative single gauge of how liquid a stock is, and because it is computed on daily data it reads the same on every chart timeframe.
Turnover (accurate): The current session's running sum of price × volume, built from 1-minute data so it tracks the broker's intraday turnover closely and stays consistent across timeframes.
Price × Day Volume (simple): Current price multiplied by the day's total volume — quick but drifts from true turnover as price moves.
The tag updates live on the latest candle, and its vertical position can be nudged above or below the candle using an ATR-based offset (positive places it above, negative below).
Inputs at a glance
Moving Averages: Source · per-line enable / EMA-SMA / colour / width
Inside Bar: enable highlight · highlight colour · strict vs inclusive
Liquidity Tag: enable · calculation method · averaging period (days) · value divisor (1 crore by default; set to 1 for raw value) · suffix · decimals · vertical offset · tag and text colour
Notes
The liquidity figure depends on the symbol having volume data. Cash equities have it; some indices and continuous-futures feeds do not, where the value may read 0.
Traded value is an estimate. TradingView provides one price per bar rather than every individual tick, so the turnover and 20-day methods are close approximations of exchange turnover rather than penny-perfect figures.
The crore (Cr) formatting suits Indian markets; change the divisor and suffix for other conventions.
This script is for chart analysis and educational use, not financial advice. Always validate signals with

## Source Code

````pine
//@version=6
indicator("EMA/SMA + Inside Bar + Liquidity Tag", shorttitle="MA + IB + Liq", overlay=true, max_labels_count=500)

// ============================================================
//  1) MOVING AVERAGES  -  5, 10, 20, 50, 100, 200
//     Each line has its OWN EMA/SMA choice (mix freely)
// ============================================================
gMA = "1 · Moving Averages"

maSource = input.source(close, "Source", group = gMA)

// helper: per-line EMA or SMA
f_ma(_type, _src, _len) => _type == "EMA" ? ta.ema(_src, _len) : ta.sma(_src, _len)

// ---- MA 5 ----
s5 = input.bool(true,                   "MA 5",   inline = "m5",  group = gMA)
y5 = input.string("EMA", "", options = ["EMA","SMA"], inline = "m5", group = gMA)
c5 = input.color(color.new(#e91e63, 0), "",       inline = "m5",  group = gMA)
w5 = input.int(1, "", minval = 1, maxval = 4, inline = "m5", group = gMA, tooltip = "Line width: 1 = thinnest, 4 = thickest")
// ---- MA 10 ----
s10 = input.bool(true,                    "MA 10", inline = "m10", group = gMA)
y10 = input.string("EMA", "", options = ["EMA","SMA"], inline = "m10", group = gMA)
c10 = input.color(color.new(#ff9800, 0),  "",      inline = "m10", group = gMA)
w10 = input.int(1, "", minval = 1, maxval = 4, inline = "m10", group = gMA)
// ---- MA 20 ----
s20 = input.bool(true,                    "MA 20", inline = "m20", group = gMA)
y20 = input.string("EMA", "", options = ["EMA","SMA"], inline = "m20", group = gMA)
c20 = input.color(color.new(#00bcd4, 0),  "",      inline = "m20", group = gMA)
w20 = input.int(1, "", minval = 1, maxval = 4, inline = "m20", group = gMA)
// ---- MA 50 ----
s50 = input.bool(true,                    "MA 50", inline = "m50", group = gMA)
y50 = input.string("EMA", "", options = ["EMA","SMA"], inline = "m50", group = gMA)
c50 = input.color(color.new(#2196f3, 0),  "",      inline = "m50", group = gMA)
w50 = input.int(1, "", minval = 1, maxval = 4, inline = "m50", group = gMA)
// ---- MA 100 ----
s100 = input.bool(true,                   "MA 100", inline = "m100", group = gMA)
y100 = input.string("EMA", "", options = ["EMA","SMA"], inline = "m100", group = gMA)
c100 = input.color(color.new(#9c27b0, 0), "",       inline = "m100", group = gMA)
w100 = input.int(1, "", minval = 1, maxval = 4, inline = "m100", group = gMA)
// ---- MA 200 ----
s200 = input.bool(true,                   "MA 200", inline = "m200", group = gMA)
y200 = input.string("SMA", "", options = ["EMA","SMA"], inline = "m200", group = gMA)
c200 = input.color(color.new(#000000, 0), "",       inline = "m200", group = gMA)
w200 = input.int(1, "", minval = 1, maxval = 4, inline = "m200", group = gMA)

plot(f_ma(y5,   maSource, 5),   "MA 5",   color = c5,   linewidth = w5,   display = s5   ? display.all : display.none)
plot(f_ma(y10,  maSource, 10),  "MA 10",  color = c10,  linewidth = w10,  display = s10  ? display.all : display.none)
plot(f_ma(y20,  maSource, 20),  "MA 20",  color = c20,  linewidth = w20,  display = s20  ? display.all : display.none)
plot(f_ma(y50,  maSource, 50),  "MA 50",  color = c50,  linewidth = w50,  display = s50  ? display.all : display.none)
plot(f_ma(y100, maSource, 100), "MA 100", color = c100, linewidth = w100, display = s100 ? display.all : display.none)
plot(f_ma(y200, maSource, 200), "MA 200", color = c200, linewidth = w200, display = s200 ? display.all : display.none)

// ============================================================
//  2) INSIDE BAR  ->  recolour the candle
// ============================================================
gIB = "2 · Inside Bar"

showIB      = input.bool(true,                   "Highlight Inside Bars", group = gIB)
ibColor     = input.color(color.new(#ffeb3b, 0), "Inside Bar Colour",     group = gIB, tooltip = "Colour applied to the whole candle when it is an inside bar")
ibInclusive = input.bool(false, "Inclusive (allow equal high/low)", group = gIB, tooltip = "OFF = strict inside bar (high < prev high AND low > prev low).  ON = also counts bars that touch the previous high/low.")

// v6: guard against na on the first bar so the bool is always true/false
prevValid = not na(high[1]) and not na(low[1])
strictIB  = high < high[1] and low > low[1]
inclIB    = high <= high[1] and low >= low[1]
insideBar = prevValid and (ibInclusive ? inclIB : strictIB)

// barcolor() recolours the candle; na = leave the candle's normal colour
barcolor(showIB and insideBar ? ibColor : na, title = "Inside Bar Highlight")

// ============================================================
//  3) LIQUIDITY TAG  on top of the last candle  ( e.g. "405.98 Cr" )
// ============================================================
gLQ = "3 · Liquidity Tag"

showLiq    = input.bool(true,        "Show Liquidity Tag", group = gLQ)
liqMethod  = input.string("20-Day Avg Liquidity", "Calculation", options = ["20-Day Avg Liquidity","Turnover (accurate)","Price × Day Volume (simple)"], group = gLQ, tooltip = "20-Day Avg Liquidity = (20-day VWAP) × (20-day avg daily volume) = average daily traded value. Best single liquidity gauge.\nTurnover (accurate) = today's running sum of price×volume.\nPrice × Day Volume = current price × total day volume (simple).")
liqLen     = input.int(20, "Avg Period (days)", minval = 1, group = gLQ, tooltip = "Lookback in trading days for the 20-Day Avg Liquidity method.")
liqDivisor = input.float(10000000.0, "Value Divisor",      group = gLQ, tooltip = "Final value is divided by this for display.\n1 Crore = 10,000,000.  Set to 1 for raw rupees.")
liqSuffix  = input.string("Cr",      "Suffix",             group = gLQ)
liqDec     = input.int(2,            "Decimals",           minval = 0, maxval = 4, group = gLQ)
// + pushes the tag higher (above the candle), - pushes it lower (below the candle)
liqOffset  = input.float(1.0,        "Tag Offset  (+ above / − below)", step = 0.1, group = gLQ, tooltip = "Measured in ATR(14) units so spacing stays consistent across instruments.\nPositive = above the candle, Negative = below it.")
liqBg      = input.color(color.new(#26a69a, 0), "Tag Colour", group = gLQ)
liqTxtCol  = input.color(color.white, "Text Colour",        group = gLQ)

// accurate intraday turnover = running sum of (typical price x volume) across the day, built from
// 1-min data so the figure is the SAME on every chart timeframe and tracks broker turnover closely
dayTurnoverFn() =>
    newDay = ta.change(time("D")) != 0
    var float t = 0.0
    t := newDay ? hlc3 * volume : nz(t[1]) + hlc3 * volume
    t

turnover = request.security(syminfo.tickerid, "1", dayTurnoverFn())
dayVol   = request.security(syminfo.tickerid, "D", volume)

// 20-day volume-weighted average price and average daily traded value (computed on daily data)
liq20Fn() =>
    pv = hlc3 * volume
    vw = math.sum(pv, liqLen) / math.sum(volume, liqLen)   // VWAP over the lookback
    ad = math.sum(pv, liqLen) / liqLen                     // average daily traded value
    [vw, ad]
[vwapN, advtN] = request.security(syminfo.tickerid, "D", liq20Fn())

liqRaw   = liqMethod == "Price × Day Volume (simple)" ? close * dayVol : liqMethod == "Turnover (accurate)" ? turnover : advtN
liqValue = liqRaw / liqDivisor
atr14    = ta.atr(14)

// fixed-decimal format string
fmtStr = switch liqDec
    0 => "0"
    1 => "0.0"
    2 => "0.00"
    3 => "0.000"
    => "0.0000"

var label liqLabel = na
if barstate.islast and showLiq
    label.delete(liqLabel)
    base  = liqOffset >= 0 ? high : low
    yPos  = base + atr14 * liqOffset
    style = liqOffset >= 0 ? label.style_label_down : label.style_label_up
    txt   = str.tostring(liqValue, fmtStr) + " " + liqSuffix
    liqLabel := label.new(bar_index, yPos, text = txt, style = style, color = liqBg, textcolor = liqTxtCol, size = size.normal)
````
