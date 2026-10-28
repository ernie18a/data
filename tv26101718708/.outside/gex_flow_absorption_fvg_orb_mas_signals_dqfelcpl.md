# GEX Flow + Absorption + FVG + ORB + MAs + Signals

- url: https://www.tradingview.com/script/DQFElcPl-GEX-Flow-Absorption-FVG-ORB-MAs-Signals/
- type: indicator
- pine_id: PUB;81b38bdbf07c4a5b9b3b72c58a1495b7
- version: 3.0

## Description

GEX-Absorb: indicator summary

It's a Pine Script v6 overlay for TradingView, built around NQ-style order flow and market structure. I haven't compiled it yet, so expect small fixes on first paste.

Absorption bubbles

A bubble appears on a bar with unusually high volume (2x the 50-bar average by default) and a strong one-sided delta.
Green means sellers hit hard but price held the upper half, so buyers absorbed. Red is the reverse.
Each bubble shows the bar's volume, and larger volume gives a larger bubble.
Delta is approximated from lower-timeframe candles, because TradingView has no real bid/ask footprint data.

Fair value gaps

It marks bullish and bearish gaps of at least 8 points, with labels like "Bull FVG 12.5".
Gaps extend to the right and stop when price closes through them.

9:30 ORB

It draws a box plus high and low lines for the 9:30 to 9:45 New York window, extended through the session.

HTF levels

Small labeled lines mark the previous completed high and low for 1H, 4H, Daily and Weekly.

GEX levels

Call wall, put wall, and gamma flip are typed in by hand, since TradingView can't pull GEX. You'd paste them in from FlashAlpha.

Moving averages

There are four MAs (9, 21, 50, 200), with 9 off by default. Each has its own length, color, and width.
One setting switches them all between EMA, SMA, WMA, RMA, and HMA.

Buy/sell signals

Three triggers:
Price wicks the signal MA (the 200 by default) and closes back on the trade side.
Price retests an active FVG, first retest only by default.
An absorption bubble prints.
BUY and SELL labels show which triggers fired, for example "BUY MA FVG".
Controls:
Minimum number of triggers that must agree (1 by default, 2 for confluence).
An MA slope filter.
A cooldown between signals.
Alert conditions.

Customization

Every element has its own color setting, and the line styles are adjustable.

Main limits

There are no real footprint numbers or stacked imbalance labels like the ATAS screenshot has.
GEX levels are manual.
The signals are untested, so replay them before trading.

## Source Code

````pine
//@version=6
indicator("GEX Flow + Absorption + FVG + ORB + Sessions + VP + Bias", "GEX-Absorb", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// ═════════════ INPUTS ═════════════
g1 = "Absorption Bubbles"
showBubbles = input.bool(true, "Show absorption bubbles", group=g1)
lowerTF     = input.timeframe("1", "Lower TF used for delta (must be < chart TF)", group=g1)
volLen      = input.int(50, "Volume average length", minval=1, group=g1)
volMult     = input.float(2.0, "Min volume (x average)", step=0.1, group=g1)
deltaPct    = input.float(25.0, "Min |delta| as % of volume", step=1.0, group=g1)
bullCol     = input.color(color.new(#00c853, 45), "Bullish absorption color", group=g1)
bearCol     = input.color(color.new(#ff1744, 45), "Bearish absorption color", group=g1)

g2 = "Fair Value Gaps"
showFvg    = input.bool(true, "Show FVG", group=g2)
minFvg     = input.float(8.0, "Minimum FVG size (points)", step=0.25, group=g2)
maxFvg     = input.int(15, "Max active FVGs", minval=1, maxval=100, group=g2)
fvgBull    = input.color(color.new(#00c853, 80), "Bullish FVG fill", group=g2)
fvgBear    = input.color(color.new(#ff1744, 80), "Bearish FVG fill", group=g2)
fvgBullTxt = input.color(#00c853, "Bullish FVG label color", group=g2)
fvgBearTxt = input.color(#ff1744, "Bearish FVG label color", group=g2)
showFvgLbl = input.bool(true, "Show FVG labels", group=g2)
fvgLblSize = input.string("Small", "FVG label size", options=["Tiny", "Small", "Normal"], group=g2)

g2b = "HTF Fair Value Gaps (labeled)"
showHfLbl = input.bool(true, "Show HTF FVG labels", group=g2b)
hfKeep    = input.int(6, "Max active gaps per timeframe", minval=1, maxval=20, group=g2b)
showHF1 = input.bool(true, "Slot 1", inline="h1", group=g2b)
tfHF1   = input.string("60", "", options=["15", "30", "60", "120", "240", "D", "W"], inline="h1", group=g2b)
minHF1  = input.float(10.0, "Min pts", step=0.5, inline="h1", group=g2b)
bullHF1 = input.color(color.new(#00c853, 70), "Bull / Bear", inline="h1c", group=g2b)
bearHF1 = input.color(color.new(#ff1744, 70), "", inline="h1c", group=g2b)
showHF2 = input.bool(true, "Slot 2", inline="h2", group=g2b)
tfHF2   = input.string("240", "", options=["15", "30", "60", "120", "240", "D", "W"], inline="h2", group=g2b)
minHF2  = input.float(20.0, "Min pts", step=0.5, inline="h2", group=g2b)
bullHF2 = input.color(color.new(#00e5ff, 72), "Bull / Bear", inline="h2c", group=g2b)
bearHF2 = input.color(color.new(#e040fb, 72), "", inline="h2c", group=g2b)
showHF3 = input.bool(true, "Slot 3", inline="h3", group=g2b)
tfHF3   = input.string("D", "", options=["15", "30", "60", "120", "240", "D", "W"], inline="h3", group=g2b)
minHF3  = input.float(40.0, "Min pts", step=0.5, inline="h3", group=g2b)
bullHF3 = input.color(color.new(#2962ff, 75), "Bull / Bear", inline="h3c", group=g2b)
bearHF3 = input.color(color.new(#ff9800, 75), "", inline="h3c", group=g2b)

g3 = "9:30 Opening Range (ORB)"
showOrb   = input.bool(true, "Show ORB", group=g3)
orbSess   = input.session("0930-0945", "ORB window (New York)", group=g3)
orbCol    = input.color(#2962ff, "ORB line color", group=g3)
orbWidth  = input.int(2, "ORB line width", minval=1, maxval=5, group=g3)
orbFillTr = input.int(90, "ORB box transparency", minval=0, maxval=100, group=g3)

g4 = "HTF High / Low (previous completed candle)"
show1h   = input.bool(true, "1H", inline="t1", group=g4)
c1h      = input.color(#ffeb3b, "", inline="t1", group=g4)
show4h   = input.bool(true, "4H", inline="t2", group=g4)
c4h      = input.color(#ff9800, "", inline="t2", group=g4)
showD    = input.bool(true, "Daily", inline="t3", group=g4)
cD       = input.color(#e040fb, "", inline="t3", group=g4)
showW    = input.bool(true, "Weekly", inline="t4", group=g4)
cW       = input.color(#00e5ff, "", inline="t4", group=g4)
lineLen  = input.int(25, "Line length (bars)", minval=3, group=g4)
lvlWidth = input.int(1, "Line width", minval=1, maxval=5, group=g4)
lvlStyleIn = input.string("Dashed", "Line style", options=["Solid", "Dashed", "Dotted"], group=g4)
lvlStyle = lvlStyleIn == "Solid" ? line.style_solid : lvlStyleIn == "Dotted" ? line.style_dotted : line.style_dashed

g4b = "Sessions + Midnight Open (labeled like HTF levels)"
showAsia = input.bool(true, "Asia H/L", inline="s1", group=g4b)
cAsia    = input.color(#7e57c2, "", inline="s1", group=g4b)
asiaSess = input.session("2000-0000", "Asia session (New York)", group=g4b)
showLon  = input.bool(true, "London H/L", inline="s2", group=g4b)
cLon     = input.color(#26a69a, "", inline="s2", group=g4b)
lonSess  = input.session("0200-0500", "London session (New York)", group=g4b)
showMO   = input.bool(true, "Midnight open (NY)", inline="s3", group=g4b)
cMO      = input.color(#ffffff, "", inline="s3", group=g4b)

g5 = "GEX Levels (type in from FlashAlpha, 0 = off)"
callWall  = input.float(0.0, "Call wall", group=g5)
callCol   = input.color(#00c853, "Call wall color", group=g5)
putWall   = input.float(0.0, "Put wall", group=g5)
putCol    = input.color(#ff1744, "Put wall color", group=g5)
gammaFlip = input.float(0.0, "Gamma flip", group=g5)
flipCol   = input.color(#ffffff, "Gamma flip color", group=g5)
gexWidth  = input.int(2, "GEX line width", minval=1, maxval=5, group=g5)

g6 = "Moving Averages"
maType = input.string("EMA", "MA type (all lines)", options=["EMA", "SMA", "WMA", "RMA", "HMA"], group=g6)
ma1On  = input.bool(false, "MA 1", inline="m1", group=g6)
ma1Len = input.int(9, "", minval=1, inline="m1", group=g6)
ma1Col = input.color(#ffeb3b, "", inline="m1", group=g6)
ma1W   = input.int(1, "", minval=1, maxval=5, inline="m1", group=g6)
ma2On  = input.bool(true, "MA 2", inline="m2", group=g6)
ma2Len = input.int(21, "", minval=1, inline="m2", group=g6)
ma2Col = input.color(#00e5ff, "", inline="m2", group=g6)
ma2W   = input.int(1, "", minval=1, maxval=5, inline="m2", group=g6)
ma3On  = input.bool(true, "MA 3", inline="m3", group=g6)
ma3Len = input.int(50, "", minval=1, inline="m3", group=g6)
ma3Col = input.color(#ff9800, "", inline="m3", group=g6)
ma3W   = input.int(2, "", minval=1, maxval=5, inline="m3", group=g6)
ma4On  = input.bool(true, "MA 4", inline="m4", group=g6)
ma4Len = input.int(200, "", minval=1, inline="m4", group=g6)
ma4Col = input.color(#ffffff, "", inline="m4", group=g6)
ma4W   = input.int(2, "", minval=1, maxval=5, inline="m4", group=g6)

g7 = "Buy / Sell Signals: triggers"
enableSig     = input.bool(true, "Enable signals", group=g7)
useMaTouch    = input.bool(true, "Trigger: price touches signal MA", group=g7)
useFvgSig     = input.bool(true, "Trigger: price retests a chart FVG", group=g7)
useHtfFvgSig  = input.bool(true, "Trigger: price retests an HTF FVG", group=g7)
useAbsSig     = input.bool(true, "Trigger: absorption bubble", group=g7)
sigMaSel      = input.string("MA 4", "Signal MA", options=["MA 1", "MA 2", "MA 3", "MA 4"], group=g7)
trendFilter   = input.bool(true, "Require MA slope in trade direction", group=g7)
slopeLen      = input.int(10, "Slope lookback (bars)", minval=1, group=g7)
firstTouch    = input.bool(true, "FVG: first retest only", group=g7)
minConf       = input.int(1, "Min triggers that must agree (1 = any, 2+ = confluence)", minval=1, maxval=4, group=g7)
cooldown      = input.int(5, "Min bars between signals", minval=0, group=g7)
buyCol        = input.color(#00c853, "BUY label color", group=g7)
sellCol       = input.color(#ff1744, "SELL label color", group=g7)

g7b = "Buy / Sell Signals: grading + filters"
minGrade   = input.string("C", "Minimum grade to show", options=["C", "B", "A", "A+"], group=g7b, tooltip="Grade = triggers that fired + 1 if price is on the right side of VWAP + 1 if the 15m and 4H bias are aligned with the trade. A+ is 5 or more, A is 4, B is 3, C is 2 or less.")
reqVwap    = input.bool(false, "Require price on the right side of VWAP", group=g7b)
reqBias    = input.bool(false, "Require 15m + 4H bias aligned with the trade", group=g7b)
useWindow  = input.bool(false, "Only signal inside the window below", group=g7b)
sigSess    = input.session("0930-1600", "Signal window (New York)", group=g7b)

g7c = "Risk levels + signal stats"
showRisk  = input.bool(true, "Draw entry / stop / targets", group=g7c)
atrLen    = input.int(14, "ATR length", minval=1, group=g7c)
stopMult  = input.float(1.5, "Stop distance (x ATR)", minval=0.1, step=0.1, group=g7c)
rr1       = input.float(1.5, "Target 1 (R multiple, used for stats)", minval=0.1, step=0.1, group=g7c)
rr2       = input.float(3.0, "Target 2 (R multiple)", minval=0.1, step=0.1, group=g7c)
riskLen   = input.int(20, "Level line length (bars)", minval=3, group=g7c)
riskKeep  = input.int(5, "Signals with levels kept on chart", minval=1, maxval=20, group=g7c)

g8 = "VWAP"
showVwap     = input.bool(true, "Show VWAP", group=g8)
vwapCol      = input.color(#ff69b4, "VWAP color (pink)", group=g8)
vwapW        = input.int(2, "VWAP width", minval=1, maxval=5, group=g8)
vwapAnchorSel = input.string("Midnight NY", "VWAP anchor", options=["Midnight NY", "9:30 NY", "Weekly"], group=g8)

g9 = "Volume Profile: timeframe blocks"
showVpTf  = input.bool(true, "Show timeframe profiles", group=g9)
vpTfSel   = input.string("Auto", "Profile timeframe", options=["Auto", "15", "30", "60", "120", "240", "D", "W"], group=g9, tooltip="Auto: chart up to 3m uses 1H blocks, up to 15m uses 4H, up to 1H uses Daily, anything higher uses Weekly. A fixed timeframe lower than the chart falls back to one profile per bar.")
vpTfKeep  = input.int(4, "Profiles kept", minval=1, maxval=8, group=g9)
vpTfWidth = input.float(50.0, "Width (% of block)", minval=10.0, maxval=100.0, group=g9)
vpTfVa    = input.color(color.new(#2962ff, 55), "Value area color", group=g9)

g9b = "Volume Profile: daily"
showVpDay   = input.bool(true, "Show daily profiles", group=g9b)
vpDayAnchor = input.string("Exchange day (chart daily candle)", "Day starts at", options=["Exchange day (chart daily candle)", "Midnight NY"], group=g9b)
vpDayKeep   = input.int(2, "Profiles kept", minval=1, maxval=5, group=g9b)
vpDayWidth  = input.float(50.0, "Width (% of block)", minval=10.0, maxval=100.0, group=g9b)
vpDayVa     = input.color(color.new(#ab47bc, 55), "Value area color", group=g9b)

g9c = "Volume Profile: custom time windows (New York time)"
showC1  = input.bool(false, "Window 1", inline="c1", group=g9c)
sessC1  = input.session("0930-1600", "", inline="c1", group=g9c)
vaC1    = input.color(color.new(#26a69a, 55), "", inline="c1", group=g9c)
showC2  = input.bool(false, "Window 2", inline="c2", group=g9c)
sessC2  = input.session("0200-0500", "", inline="c2", group=g9c)
vaC2    = input.color(color.new(#ff9800, 55), "", inline="c2", group=g9c)
showC3  = input.bool(false, "Window 3", inline="c3", group=g9c)
sessC3  = input.session("2000-0000", "", inline="c3", group=g9c)
vaC3    = input.color(color.new(#e040fb, 55), "", inline="c3", group=g9c)
vpCKeep  = input.int(2, "Profiles kept per window", minval=1, maxval=3, group=g9c)
vpCWidth = input.float(50.0, "Width (% of window)", minval=10.0, maxval=100.0, group=g9c)

g9d = "Volume Profile: shared settings"
vpBins       = input.int(20, "Price bins per profile", minval=8, maxval=24, group=g9d)
vaPct        = input.float(70.0, "Value area %", minval=50.0, maxval=95.0, group=g9d)
vpAlignRight = input.bool(false, "Draw bars from the right edge of the block", group=g9d)
showPoc      = input.bool(true, "Show POC level", group=g9d)
pocMode      = input.string("Extend until touched", "POC level behavior", options=["Block only", "Extend until touched", "Extend always"], group=g9d, tooltip="Block only: the POC line stays inside its profile. Extend until touched: it runs to the right until price trades through it (naked POC). Extend always: it keeps running to the current bar.")
showPocLbl   = input.bool(true, "Label POC levels (with price)", group=g9d)
vpPocCol     = input.color(#ffeb3b, "POC color", group=g9d)
vpPocW       = input.int(1, "POC width", minval=1, maxval=4, group=g9d)
showVaLines  = input.bool(false, "Show value area high / low lines", group=g9d)
vpVaLnCol    = input.color(color.new(#9e9e9e, 30), "VAH / VAL line color", group=g9d)
vpOutCol     = input.color(color.new(#9e9e9e, 75), "Bars outside value area", group=g9d)

g10 = "Day Bias Table (15m + 4H)"
showTbl       = input.bool(true, "Show bias table", group=g10)
tblPosIn      = input.string("Top Right", "Table position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=g10)
biasLen       = input.int(21, "Bias EMA length (per timeframe)", minval=2, group=g10)
biasConfirmed = input.bool(true, "Use completed HTF candles (no repaint)", group=g10)

// ═════════════ TIME / SESSION SETUP ═════════════
tz = "America/New_York"
bool inRth  = not na(time(timeframe.period, "0930-1600", tz))
bool inOrb  = not na(time(timeframe.period, orbSess, tz))
bool inAsia = not na(time(timeframe.period, asiaSess, tz))
bool inLon  = not na(time(timeframe.period, lonSess, tz))
int dayNy   = dayofmonth(time, tz)
bool newDay = dayNy != dayNy[1]

// ═════════════ MOVING AVERAGES ═════════════
f_ma(float src, int len) =>
    switch maType
        "SMA" => ta.sma(src, len)
        "WMA" => ta.wma(src, len)
        "RMA" => ta.rma(src, len)
        "HMA" => ta.hma(src, len)
        => ta.ema(src, len)

float ma1 = f_ma(close, ma1Len)
float ma2 = f_ma(close, ma2Len)
float ma3 = f_ma(close, ma3Len)
float ma4 = f_ma(close, ma4Len)
plot(ma1On ? ma1 : na, "MA 1", ma1Col, ma1W)
plot(ma2On ? ma2 : na, "MA 2", ma2Col, ma2W)
plot(ma3On ? ma3 : na, "MA 3", ma3Col, ma3W)
plot(ma4On ? ma4 : na, "MA 4", ma4Col, ma4W)

float sigMa = sigMaSel == "MA 1" ? ma1 : sigMaSel == "MA 2" ? ma2 : sigMaSel == "MA 3" ? ma3 : ma4

// ═════════════ VWAP (pink) ═════════════
bool vwapAnchor = vwapAnchorSel == "Midnight NY" ? newDay : vwapAnchorSel == "9:30 NY" ? (inRth and not inRth[1]) : (weekofyear(time, tz) != weekofyear(time[1], tz))
float vwapV = ta.vwap(hlc3, vwapAnchor)
plot(showVwap ? vwapV : na, "VWAP", vwapCol, vwapW)

// ═════════════ ABSORPTION BUBBLES ═════════════
// TradingView has no bid/ask footprint data, so delta is approximated
// from lower-timeframe candles (up-candle volume minus down-candle volume).
array<float> dArr = request.security_lower_tf(syminfo.tickerid, lowerTF, close > open ? volume : close < open ? -volume : 0.0)
float delta = dArr.size() > 0 ? dArr.sum() : (close > open ? volume : -volume)
float deltaRatio = volume > 0 ? delta / volume * 100 : 0.0
float avgVol = ta.sma(volume, volLen)
bool bigVol = volume > avgVol * volMult
float mid = (high + low) / 2

// Sellers hit hard but price held the upper half -> buyers absorbed
bool bullAbs = bigVol and deltaRatio <= -deltaPct and close >= mid
// Buyers lifted hard but price sat in the lower half -> sellers absorbed
bool bearAbs = bigVol and deltaRatio >= deltaPct and close <= mid

if showBubbles and barstate.isconfirmed
    if bullAbs
        label.new(bar_index, low, str.tostring(volume, format.volume), style=label.style_circle, color=bullCol, textcolor=color.white, size=volume > avgVol * volMult * 2 ? size.normal : size.small)
    if bearAbs
        label.new(bar_index, high, str.tostring(volume, format.volume), style=label.style_circle, color=bearCol, textcolor=color.white, size=volume > avgVol * volMult * 2 ? size.normal : size.small)

// ═════════════ FAIR VALUE GAPS ═════════════
var array<box> fvgBoxes = array.new<box>()
var array<bool> fvgIsBull = array.new<bool>()
var array<bool> fvgTouched = array.new<bool>()
var array<label> fvgLbls = array.new<label>()
string lblSz = fvgLblSize == "Tiny" ? size.tiny : fvgLblSize == "Normal" ? size.normal : size.small

bool fvgBuy = false
bool fvgSell = false

if showFvg
    if barstate.isconfirmed and fvgBoxes.size() > 0
        for i = fvgBoxes.size() - 1 to 0
            box b = fvgBoxes.get(i)
            bool isBull = fvgIsBull.get(i)
            bool touched = fvgTouched.get(i)
            if (isBull and close < b.get_bottom()) or (not isBull and close > b.get_top())
                // gap fully taken out: stop drawing it
                b.set_right(bar_index)
                b.set_extend(extend.none)
                fvgBoxes.remove(i)
                fvgIsBull.remove(i)
                fvgTouched.remove(i)
                label.delete(fvgLbls.remove(i))
            else
                bool hit = isBull ? low <= b.get_top() : high >= b.get_bottom()
                if hit and (not firstTouch or not touched)
                    if isBull
                        fvgBuy := true
                    else
                        fvgSell := true
                if hit
                    fvgTouched.set(i, true)

    if barstate.isconfirmed
        if low > high[2] and (low - high[2]) >= minFvg
            float sz = low - high[2]
            fvgBoxes.push(box.new(bar_index - 2, low, bar_index, high[2], border_color=na, bgcolor=fvgBull, extend=extend.right))
            fvgIsBull.push(true)
            fvgTouched.push(false)
            fvgLbls.push(showFvgLbl ? label.new(bar_index + 3, (low + high[2]) / 2, "Bull FVG " + str.tostring(sz, "#.##"), style=label.style_none, textcolor=fvgBullTxt, size=lblSz) : na)
        if high < low[2] and (low[2] - high) >= minFvg
            float sz = low[2] - high
            fvgBoxes.push(box.new(bar_index - 2, low[2], bar_index, high, border_color=na, bgcolor=fvgBear, extend=extend.right))
            fvgIsBull.push(false)
            fvgTouched.push(false)
            fvgLbls.push(showFvgLbl ? label.new(bar_index + 3, (low[2] + high) / 2, "Bear FVG " + str.tostring(sz, "#.##"), style=label.style_none, textcolor=fvgBearTxt, size=lblSz) : na)

    while fvgBoxes.size() > maxFvg
        box.delete(fvgBoxes.shift())
        fvgIsBull.shift()
        fvgTouched.shift()
        label.delete(fvgLbls.shift())

// ═════════════ 9:30 ORB ═════════════
bool newOrb = inOrb and not inOrb[1]

var float orbH = na
var float orbL = na
var line orbHiLn = na
var line orbLoLn = na
var box orbBox = na

if showOrb
    if newOrb
        orbH := high
        orbL := low
        orbBox := box.new(bar_index, high, bar_index, low, border_color=orbCol, bgcolor=color.new(orbCol, orbFillTr))
        orbHiLn := line.new(bar_index, high, bar_index, high, color=orbCol, width=orbWidth)
        orbLoLn := line.new(bar_index, low, bar_index, low, color=orbCol, width=orbWidth)
    else if inOrb
        orbH := math.max(orbH, high)
        orbL := math.min(orbL, low)
        orbBox.set_top(orbH)
        orbBox.set_bottom(orbL)
        orbBox.set_right(bar_index)
        orbHiLn.set_y1(orbH)
        orbHiLn.set_y2(orbH)
        orbHiLn.set_x2(bar_index)
        orbLoLn.set_y1(orbL)
        orbLoLn.set_y2(orbL)
        orbLoLn.set_x2(bar_index)
    else if inRth and not na(orbHiLn)
        orbHiLn.set_x2(bar_index)
        orbLoLn.set_x2(bar_index)

// ═════════════ ASIA / LONDON / MIDNIGHT OPEN ═════════════
// Shows the developing range while the session is open, then the finished range.
var float asiaH = na
var float asiaL = na
var float lonH = na
var float lonL = na
var float midOpen = na

if inAsia and not inAsia[1]
    asiaH := high
    asiaL := low
else if inAsia
    asiaH := math.max(asiaH, high)
    asiaL := math.min(asiaL, low)

if inLon and not inLon[1]
    lonH := high
    lonL := low
else if inLon
    lonH := math.max(lonH, high)
    lonL := math.min(lonL, low)

if newDay
    midOpen := open

// ═════════════ VOLUME PROFILES ═════════════
// One engine, five profiles: timeframe blocks, daily, and three custom time windows.
// Each finished block gets a profile with value-area shading, POC, and optional VAH/VAL.
// TradingView allows 500 boxes per script, so total bars drawn = profiles x bins; reduce bins or counts if older ones vanish.
type VProf
    array<float> h
    array<float> l
    array<float> v
    array<box> boxes
    array<line> lines
    array<int> bcnt
    array<int> lcnt
    int start
    array<line> pocLn
    array<label> pocLb
    array<float> pocPx
    array<bool> pocLive

f_newVp() =>
    VProf.new(array.new<float>(), array.new<float>(), array.new<float>(), array.new<box>(), array.new<line>(), array.new<int>(), array.new<int>(), 0, array.new<line>(), array.new<label>(), array.new<float>(), array.new<bool>())

method step(VProf p, bool finalize, bool begin, bool accumulate, int keep, float widthPct, color vaCol, string tag) =>
    if finalize and p.h.size() > 0
        float lo = p.l.min()
        float hi = p.h.max()
        int nBars = p.h.size()
        if hi > lo
            float stp = (hi - lo) / vpBins
            array<float> bv = array.new<float>(vpBins, 0.0)
            for k = 0 to nBars - 1
                float bh = p.h.get(k)
                float bl = p.l.get(k)
                float vv = p.v.get(k)
                if bh == bl
                    int idx = math.min(vpBins - 1, int((bl - lo) / stp))
                    bv.set(idx, bv.get(idx) + vv)
                else
                    for j = 0 to vpBins - 1
                        float bLo = lo + j * stp
                        float bHi = bLo + stp
                        float ov = math.min(bh, bHi) - math.max(bl, bLo)
                        if ov > 0
                            bv.set(j, bv.get(j) + vv * ov / (bh - bl))

            float maxV = bv.max()
            int poc = bv.indexof(maxV)
            float tot = bv.sum()
            int upI = poc
            int dnI = poc
            float acc = bv.get(poc)
            while acc < tot * vaPct / 100.0 and (upI < vpBins - 1 or dnI > 0)
                float upV = upI < vpBins - 1 ? bv.get(upI + 1) : -1.0
                float dnV = dnI > 0 ? bv.get(dnI - 1) : -1.0
                if upV >= dnV
                    upI += 1
                    acc += upV
                else
                    dnI -= 1
                    acc += dnV

            int endBar = p.start + nBars
            int bc = 0
            for j = 0 to vpBins - 1
                float bLo = lo + j * stp
                int w = math.max(1, int(math.round(bv.get(j) / maxV * nBars * widthPct / 100.0)))
                int left = vpAlignRight ? endBar - w : p.start
                int right = vpAlignRight ? endBar : p.start + w
                bool inVa = j >= dnI and j <= upI
                p.boxes.push(box.new(left, bLo + stp, right, bLo, border_color=na, bgcolor=inVa ? vaCol : vpOutCol))
                bc += 1
            int lc = 0
            float pocPrice = lo + (poc + 0.5) * stp
            line pocLine = na
            label pocLabel = na
            if showPoc
                pocLine := line.new(p.start, pocPrice, endBar, pocPrice, color=vpPocCol, width=vpPocW)
                p.lines.push(pocLine)
                lc += 1
                if showPocLbl
                    pocLabel := label.new(endBar, pocPrice, tag + " " + str.tostring(pocPrice, format.mintick), style=label.style_label_left, color=color.new(color.black, 100), textcolor=vpPocCol, size=size.tiny)
            p.pocLn.push(pocLine)
            p.pocLb.push(pocLabel)
            p.pocPx.push(pocPrice)
            p.pocLive.push(pocMode != "Block only")
            if showVaLines
                float vahPx = lo + (upI + 1) * stp
                float valPx = lo + dnI * stp
                p.lines.push(line.new(p.start, vahPx, endBar, vahPx, color=vpVaLnCol, width=1, style=line.style_dotted))
                p.lines.push(line.new(p.start, valPx, endBar, valPx, color=vpVaLnCol, width=1, style=line.style_dotted))
                lc += 2
            p.bcnt.push(bc)
            p.lcnt.push(lc)

            while p.bcnt.size() > keep
                int c1 = p.bcnt.shift()
                for n = 1 to c1
                    box.delete(p.boxes.shift())
                int c2 = p.lcnt.shift()
                for n = 1 to c2
                    line.delete(p.lines.shift())
                p.pocLn.shift()
                label.delete(p.pocLb.shift())
                p.pocPx.shift()
                p.pocLive.shift()
        p.h.clear()
        p.l.clear()
        p.v.clear()
    if begin
        p.h.clear()
        p.l.clear()
        p.v.clear()
        p.start := bar_index
    if accumulate
        p.h.push(high)
        p.l.push(low)
        p.v.push(volume)

// keeps POC levels running to the right (and stops them once price touches, if chosen)
method pocUpdate(VProf p) =>
    int n = p.pocLn.size()
    if n > 0
        for i = 0 to n - 1
            line ln = p.pocLn.get(i)
            if not na(ln) and p.pocLive.get(i)
                float px = p.pocPx.get(i)
                label lb = p.pocLb.get(i)
                if pocMode == "Extend until touched" and low <= px and high >= px
                    p.pocLive.set(i, false)
                    ln.set_x2(bar_index)
                    if not na(lb)
                        lb.set_x(bar_index)
                else
                    ln.set_x2(bar_index)
                    if barstate.islast and not na(lb)
                        lb.set_x(bar_index + 2)

var VProf vpTfP  = f_newVp()
var VProf vpDayP = f_newVp()
var VProf vpC1P  = f_newVp()
var VProf vpC2P  = f_newVp()
var VProf vpC3P  = f_newVp()

// timeframe blocks (Auto picks a block size from the chart timeframe)
int tfSec = timeframe.in_seconds()
string autoTf = tfSec <= 180 ? "60" : tfSec <= 900 ? "240" : tfSec <= 3600 ? "D" : "W"
string vpTfWanted = vpTfSel == "Auto" ? autoTf : vpTfSel
string vpTfUse = timeframe.in_seconds(vpTfWanted) < tfSec ? timeframe.period : vpTfWanted
string tfTag = vpTfUse == "60" ? "1H" : vpTfUse == "120" ? "2H" : vpTfUse == "240" ? "4H" : vpTfUse == "D" ? "D" : vpTfUse == "W" ? "W" : vpTfUse + "m"
bool newTfBlk = ta.change(time(vpTfUse)) != 0

// daily blocks
bool newDayEx = ta.change(time("D")) != 0
bool newDayBlk = vpDayAnchor == "Midnight NY" ? newDay : newDayEx

// custom windows
bool inC1 = not na(time(timeframe.period, sessC1, tz))
bool inC2 = not na(time(timeframe.period, sessC2, tz))
bool inC3 = not na(time(timeframe.period, sessC3, tz))

if showVpTf
    vpTfP.step(newTfBlk, newTfBlk, true, vpTfKeep, vpTfWidth, vpTfVa, "POC " + tfTag)
    vpTfP.pocUpdate()
if showVpDay
    vpDayP.step(newDayBlk, newDayBlk, true, vpDayKeep, vpDayWidth, vpDayVa, "POC DAY")
    vpDayP.pocUpdate()
if showC1
    vpC1P.step(inC1[1] and not inC1, inC1 and not inC1[1], inC1, vpCKeep, vpCWidth, vaC1, "POC C1")
    vpC1P.pocUpdate()
if showC2
    vpC2P.step(inC2[1] and not inC2, inC2 and not inC2[1], inC2, vpCKeep, vpCWidth, vaC2, "POC C2")
    vpC2P.pocUpdate()
if showC3
    vpC3P.step(inC3[1] and not inC3, inC3 and not inC3[1], inC3, vpCKeep, vpCWidth, vaC3, "POC C3")
    vpC3P.pocUpdate()

// ═════════════ HTF FAIR VALUE GAPS ═════════════
// Gaps are read from completed higher-timeframe candles (no repaint), drawn as boxes that run right
// until a chart candle closes through them, each with a label like "4H Bull FVG 24.5".
type HFvg
    array<box> boxes
    array<bool> isBull
    array<label> lbls
    array<bool> touched

f_newHf() =>
    HFvg.new(array.new<box>(), array.new<bool>(), array.new<label>(), array.new<bool>())

f_tfName(string t) =>
    t == "60" ? "1H" : t == "120" ? "2H" : t == "240" ? "4H" : t == "D" ? "D" : t == "W" ? "W" : t + "m"

f_hfData(string tf) =>
    request.security(syminfo.tickerid, tf, [high[1], low[1], high[3], low[3], time[3], time[1]], lookahead=barmerge.lookahead_on)

method hfStep(HFvg p, bool show, bool newBar, float h1, float l1, float h3, float l3, int t3, string tag, float minSz, int keep, color bullC, color bearC) =>
    int n = p.boxes.size()
    bool fb = false
    bool fs = false
    if barstate.isconfirmed and n > 0
        for i = n - 1 to 0
            box b = p.boxes.get(i)
            bool bl = p.isBull.get(i)
            if (bl and close < b.get_bottom()) or (not bl and close > b.get_top())
                b.set_right(time)
                b.set_extend(extend.none)
                p.boxes.remove(i)
                p.isBull.remove(i)
                p.touched.remove(i)
                label.delete(p.lbls.remove(i))
            else
                bool hit = bl ? low <= b.get_top() : high >= b.get_bottom()
                if hit and not p.touched.get(i)
                    if bl
                        fb := true
                    else
                        fs := true
                if hit
                    p.touched.set(i, true)

    if show and barstate.isconfirmed and newBar and not na(h1) and not na(h3) and not na(t3)
        if l1 > h3 and (l1 - h3) >= minSz
            p.boxes.push(box.new(t3, l1, time, h3, xloc=xloc.bar_time, border_color=na, bgcolor=bullC, extend=extend.right))
            p.isBull.push(true)
            p.touched.push(false)
            p.lbls.push(showHfLbl ? label.new(bar_index + 3, (l1 + h3) / 2, tag + " Bull FVG " + str.tostring(l1 - h3, "#.##"), style=label.style_none, textcolor=color.new(bullC, 0), size=lblSz) : na)
        if h1 < l3 and (l3 - h1) >= minSz
            p.boxes.push(box.new(t3, l3, time, h1, xloc=xloc.bar_time, border_color=na, bgcolor=bearC, extend=extend.right))
            p.isBull.push(false)
            p.touched.push(false)
            p.lbls.push(showHfLbl ? label.new(bar_index + 3, (l3 + h1) / 2, tag + " Bear FVG " + str.tostring(l3 - h1, "#.##"), style=label.style_none, textcolor=color.new(bearC, 0), size=lblSz) : na)

    while p.boxes.size() > keep
        box.delete(p.boxes.shift())
        p.isBull.shift()
        p.touched.shift()
        label.delete(p.lbls.shift())

    // keep the labels of active gaps parked at the right edge, like the HTF levels
    if barstate.islast and p.lbls.size() > 0
        for k = 0 to p.lbls.size() - 1
            label lb = p.lbls.get(k)
            if not na(lb)
                lb.set_x(bar_index + 3)

    (fb ? 1 : 0) + (fs ? 2 : 0)

var HFvg hf1P = f_newHf()
var HFvg hf2P = f_newHf()
var HFvg hf3P = f_newHf()

[hf1h1, hf1l1, hf1h3, hf1l3, hf1t3, hf1t1] = f_hfData(tfHF1)
[hf2h1, hf2l1, hf2h3, hf2l3, hf2t3, hf2t1] = f_hfData(tfHF2)
[hf3h1, hf3l1, hf3h3, hf3l3, hf3t3, hf3t1] = f_hfData(tfHF3)

int chartSec = timeframe.in_seconds()
bool hfNew1 = ta.change(hf1t1) != 0
bool hfNew2 = ta.change(hf2t1) != 0
bool hfNew3 = ta.change(hf3t1) != 0
// a slot only runs when its timeframe is higher than the chart timeframe
bool hfOk1 = timeframe.in_seconds(tfHF1) > chartSec
bool hfOk2 = timeframe.in_seconds(tfHF2) > chartSec
bool hfOk3 = timeframe.in_seconds(tfHF3) > chartSec

int hf1F = hf1P.hfStep(showHF1 and hfOk1, hfNew1, hf1h1, hf1l1, hf1h3, hf1l3, int(hf1t3), f_tfName(tfHF1), minHF1, hfKeep, bullHF1, bearHF1)
int hf2F = hf2P.hfStep(showHF2 and hfOk2, hfNew2, hf2h1, hf2l1, hf2h3, hf2l3, int(hf2t3), f_tfName(tfHF2), minHF2, hfKeep, bullHF2, bearHF2)
int hf3F = hf3P.hfStep(showHF3 and hfOk3, hfNew3, hf3h1, hf3l1, hf3h3, hf3l3, int(hf3t3), f_tfName(tfHF3), minHF3, hfKeep, bullHF3, bearHF3)

// ═════════════ HTF HIGH / LOW + SESSION LEVELS ═════════════
f_prev(tf) =>
    request.security(syminfo.tickerid, tf, [high[1], low[1]], lookahead=barmerge.lookahead_on)

[h1h, l1h] = f_prev("60")
[h4h, l4h] = f_prev("240")
[hD, lD]   = f_prev("D")
[hW, lW]   = f_prev("W")

var array<line> lvlLines = array.new<line>()
var array<label> lvlLabels = array.new<label>()

f_level(float price, string txt, color col, bool show) =>
    if show and not na(price)
        lvlLines.push(line.new(bar_index - lineLen, price, bar_index + 2, price, color=col, width=lvlWidth, style=lvlStyle))
        lvlLabels.push(label.new(bar_index + 2, price, txt, style=label.style_label_left, color=color.new(color.black, 100), textcolor=col, size=size.tiny))

if barstate.islast
    for l in lvlLines
        l.delete()
    for lb in lvlLabels
        lb.delete()
    lvlLines.clear()
    lvlLabels.clear()

    f_level(h1h, "1H H", c1h, show1h)
    f_level(l1h, "1H L", c1h, show1h)
    f_level(h4h, "4H H", c4h, show4h)
    f_level(l4h, "4H L", c4h, show4h)
    f_level(hD,  "D H",  cD, showD)
    f_level(lD,  "D L",  cD, showD)
    f_level(hW,  "W H",  cW, showW)
    f_level(lW,  "W L",  cW, showW)
    f_level(asiaH, "ASIA H", cAsia, showAsia)
    f_level(asiaL, "ASIA L", cAsia, showAsia)
    f_level(lonH,  "LDN H",  cLon, showLon)
    f_level(lonL,  "LDN L",  cLon, showLon)
    f_level(midOpen, "MO", cMO, showMO)

// ═════════════ GEX LEVELS (manual) ═════════════
plot(callWall > 0 ? callWall : na, "Call wall", callCol, gexWidth, plot.style_linebr)
plot(putWall > 0 ? putWall : na, "Put wall", putCol, gexWidth, plot.style_linebr)
plot(gammaFlip > 0 ? gammaFlip : na, "Gamma flip", flipCol, gexWidth, plot.style_linebr)

// ═════════════ DAY BIAS (15m + 4H) ═════════════
// Per-timeframe bias: bull = close above its EMA and the EMA rising, bear = the opposite.
f_biasCalc() =>
    float e = ta.ema(close, biasLen)
    int b = close > e and e > e[1] ? 1 : close < e and e < e[1] ? -1 : 0
    b

int bias15 = biasConfirmed ? request.security(syminfo.tickerid, "15", f_biasCalc()[1], lookahead=barmerge.lookahead_on) : request.security(syminfo.tickerid, "15", f_biasCalc())
int bias4h = biasConfirmed ? request.security(syminfo.tickerid, "240", f_biasCalc()[1], lookahead=barmerge.lookahead_on) : request.security(syminfo.tickerid, "240", f_biasCalc())

bool alignBull = bias15 == 1 and bias4h == 1
bool alignBear = bias15 == -1 and bias4h == -1

// ═════════════ BUY / SELL SIGNALS (graded, filtered, with risk levels + tracking) ═════════════
f_rank(int sc) => sc >= 5 ? 4 : sc >= 4 ? 3 : sc >= 3 ? 2 : 1
f_grade(int sc) => sc >= 5 ? "A+" : sc >= 4 ? "A" : sc >= 3 ? "B" : "C"
int minRank = minGrade == "A+" ? 4 : minGrade == "A" ? 3 : minGrade == "B" ? 2 : 1

bool hfBuy = hf1F == 1 or hf1F == 3 or hf2F == 1 or hf2F == 3 or hf3F == 1 or hf3F == 3
bool hfSell = hf1F >= 2 or hf2F >= 2 or hf3F >= 2

bool slopeUp = sigMa > sigMa[slopeLen]
bool slopeDn = sigMa < sigMa[slopeLen]
bool maBuy = low <= sigMa and close > sigMa and (not trendFilter or slopeUp)
bool maSell = high >= sigMa and close < sigMa and (not trendFilter or slopeDn)

float atrV = ta.atr(atrLen)
bool inSigWin = not na(time(timeframe.period, sigSess, tz))
bool vwapBuyOk = close > vwapV
bool vwapSellOk = close < vwapV

int trigBuy = (useMaTouch and maBuy ? 1 : 0) + (useFvgSig and fvgBuy ? 1 : 0) + (useHtfFvgSig and hfBuy ? 1 : 0) + (useAbsSig and bullAbs ? 1 : 0)
int trigSell = (useMaTouch and maSell ? 1 : 0) + (useFvgSig and fvgSell ? 1 : 0) + (useHtfFvgSig and hfSell ? 1 : 0) + (useAbsSig and bearAbs ? 1 : 0)
int scoreBuy = trigBuy + (vwapBuyOk ? 1 : 0) + (alignBull ? 1 : 0)
int scoreSell = trigSell + (vwapSellOk ? 1 : 0) + (alignBear ? 1 : 0)

bool winOk = not useWindow or inSigWin
bool buyOk = winOk and (not reqVwap or vwapBuyOk) and (not reqBias or alignBull) and f_rank(scoreBuy) >= minRank
bool sellOk = winOk and (not reqVwap or vwapSellOk) and (not reqBias or alignBear) and f_rank(scoreSell) >= minRank

// open-trade tracker: each signal is followed until target 1 or the stop is hit
var array<int> tDir = array.new<int>()
var array<float> tStop = array.new<float>()
var array<float> tTp = array.new<float>()
var array<bool> tHi = array.new<bool>()
var int wins = 0
var int losses = 0
var int winsHi = 0
var int lossesHi = 0
var float totalR = 0.0

if barstate.isconfirmed and tDir.size() > 0
    for i = tDir.size() - 1 to 0
        int d = tDir.get(i)
        float stp = tStop.get(i)
        float tp = tTp.get(i)
        bool hiG = tHi.get(i)
        bool hitStop = d == 1 ? low <= stp : high >= stp
        bool hitTp = d == 1 ? high >= tp : low <= tp
        if hitStop or hitTp
            // if both levels sit inside one bar it is counted as a loss (conservative)
            if hitTp and not hitStop
                wins += 1
                totalR += rr1
                if hiG
                    winsHi += 1
            else
                losses += 1
                totalR -= 1.0
                if hiG
                    lossesHi += 1
            tDir.remove(i)
            tStop.remove(i)
            tTp.remove(i)
            tHi.remove(i)

var array<line> riskLines = array.new<line>()

f_openTrade(int d, int score) =>
    float dist = atrV * stopMult
    float stp = close - d * dist
    float tp1 = close + d * dist * rr1
    float tp2 = close + d * dist * rr2
    tDir.push(d)
    tStop.push(stp)
    tTp.push(tp1)
    tHi.push(f_rank(score) >= 3)
    while tDir.size() > 30
        tDir.shift()
        tStop.shift()
        tTp.shift()
        tHi.shift()
    if showRisk
        riskLines.push(line.new(bar_index, close, bar_index + riskLen, close, color=color.new(color.white, 15), width=1))
        riskLines.push(line.new(bar_index, stp, bar_index + riskLen, stp, color=color.new(#ff1744, 0), width=1, style=line.style_dotted))
        riskLines.push(line.new(bar_index, tp1, bar_index + riskLen, tp1, color=color.new(#00c853, 0), width=1, style=line.style_dashed))
        riskLines.push(line.new(bar_index, tp2, bar_index + riskLen, tp2, color=color.new(#00c853, 40), width=1, style=line.style_dashed))
        while riskLines.size() > riskKeep * 4
            line.delete(riskLines.shift())

var int lastSigBar = -1000
bool buySig = false
bool sellSig = false

if enableSig and barstate.isconfirmed and (bar_index - lastSigBar) > cooldown and not na(atrV)
    if buyOk and trigBuy >= minConf and trigBuy > trigSell
        buySig := true
        lastSigBar := bar_index
    else if sellOk and trigSell >= minConf and trigSell > trigBuy
        sellSig := true
        lastSigBar := bar_index

if buySig
    string why = (useMaTouch and maBuy ? "MA " : "") + (useFvgSig and fvgBuy ? "FVG " : "") + (useHtfFvgSig and hfBuy ? "HTF " : "") + (useAbsSig and bullAbs ? "ABS" : "")
    label.new(bar_index, low, "BUY " + f_grade(scoreBuy) + "\n" + why, style=label.style_label_up, color=buyCol, textcolor=color.white, size=size.small)
    f_openTrade(1, scoreBuy)
    alert("BUY " + f_grade(scoreBuy) + " " + syminfo.ticker + " @ " + str.tostring(close, format.mintick) + " | SL " + str.tostring(close - atrV * stopMult, format.mintick) + " | TP1 " + str.tostring(close + atrV * stopMult * rr1, format.mintick), alert.freq_once_per_bar_close)
if sellSig
    string why = (useMaTouch and maSell ? "MA " : "") + (useFvgSig and fvgSell ? "FVG " : "") + (useHtfFvgSig and hfSell ? "HTF " : "") + (useAbsSig and bearAbs ? "ABS" : "")
    label.new(bar_index, high, "SELL " + f_grade(scoreSell) + "\n" + why, style=label.style_label_down, color=sellCol, textcolor=color.white, size=size.small)
    f_openTrade(-1, scoreSell)
    alert("SELL " + f_grade(scoreSell) + " " + syminfo.ticker + " @ " + str.tostring(close, format.mintick) + " | SL " + str.tostring(close + atrV * stopMult, format.mintick) + " | TP1 " + str.tostring(close - atrV * stopMult * rr1, format.mintick), alert.freq_once_per_bar_close)

alertcondition(buySig, "Buy signal", "GEX-Absorb: BUY on {{ticker}} @ {{close}}")
alertcondition(sellSig, "Sell signal", "GEX-Absorb: SELL on {{ticker}} @ {{close}}")

// ═════════════ DASHBOARD ═════════════
var int dayBars = 0
var int algBull = 0
var int algBear = 0
var int dayBuys = 0
var int daySells = 0
var int dayBullAbs = 0
var int dayBearAbs = 0

if newDay
    dayBars := 0
    algBull := 0
    algBear := 0
    dayBuys := 0
    daySells := 0
    dayBullAbs := 0
    dayBearAbs := 0

if barstate.isconfirmed
    dayBars += 1
    if alignBull
        algBull += 1
    if alignBear
        algBear += 1
    if buySig
        dayBuys += 1
    if sellSig
        daySells += 1
    if bullAbs
        dayBullAbs += 1
    if bearAbs
        dayBearAbs += 1

f_biasTxt(int b) => b == 1 ? "BULL" : b == -1 ? "BEAR" : "NEUTRAL"
f_biasCol(int b) => b == 1 ? color.new(#00c853, 30) : b == -1 ? color.new(#ff1744, 30) : color.new(color.gray, 40)

string tblPos = tblPosIn == "Top Left" ? position.top_left : tblPosIn == "Bottom Right" ? position.bottom_right : tblPosIn == "Bottom Left" ? position.bottom_left : position.top_right
var table biasTbl = table.new(tblPos, 2, 10, bgcolor=color.new(color.black, 20), frame_color=color.gray, frame_width=1, border_color=color.gray, border_width=1)

if barstate.islast and showTbl
    float pBull = dayBars > 0 ? algBull * 100.0 / dayBars : 0.0
    float pBear = dayBars > 0 ? algBear * 100.0 / dayBars : 0.0
    int dayBias = algBull > algBear ? 1 : algBear > algBull ? -1 : 0
    int nowBias = alignBull ? 1 : alignBear ? -1 : 0
    string matchTxt = alignBull ? "ALIGNED BULL" : alignBear ? "ALIGNED BEAR" : "MIXED"
    string dayTxt = dayBias == 1 ? "BULL " + str.tostring(pBull, "#") + "%" : dayBias == -1 ? "BEAR " + str.tostring(pBear, "#") + "%" : "NEUTRAL"
    float chg = na(midOpen) ? 0.0 : close - midOpen
    string chgTxt = na(midOpen) ? "n/a" : (chg >= 0 ? "+" : "") + str.tostring(chg, "#.##") + " (" + str.tostring(chg / midOpen * 100, "#.##") + "%)"

    int nTr = wins + losses
    int nHi = winsHi + lossesHi
    float wr = nTr > 0 ? wins * 100.0 / nTr : na
    float wrHi = nHi > 0 ? winsHi * 100.0 / nHi : na
    float avgR = nTr > 0 ? totalR / nTr : 0.0
    string wrTxt = nTr > 0 ? str.tostring(wr, "#") + "% (" + str.tostring(wins) + "W/" + str.tostring(losses) + "L) " + str.tostring(avgR, "#.##") + "R" : "n/a"
    string wrHiTxt = nHi > 0 ? str.tostring(wrHi, "#") + "% (" + str.tostring(winsHi) + "W/" + str.tostring(lossesHi) + "L)" : "n/a"
    color wrCol = na(wr) ? color.new(color.gray, 40) : wr >= 50 ? f_biasCol(1) : f_biasCol(-1)
    color wrHiCol = na(wrHi) ? color.new(color.gray, 40) : wrHi >= 50 ? f_biasCol(1) : f_biasCol(-1)

    table.cell(biasTbl, 0, 0, "DAY BIAS", text_color=color.white, text_size=size.small, bgcolor=color.new(color.gray, 30))
    table.cell(biasTbl, 1, 0, syminfo.ticker, text_color=color.white, text_size=size.small, bgcolor=color.new(color.gray, 30))
    table.cell(biasTbl, 0, 1, "15m bias", text_color=color.white, text_size=size.small, text_halign=text.align_left)
    table.cell(biasTbl, 1, 1, f_biasTxt(bias15), text_color=color.white, text_size=size.small, bgcolor=f_biasCol(bias15))
    table.cell(biasTbl, 0, 2, "4H bias", text_color=color.white, text_size=size.small, text_halign=text.align_left)
    table.cell(biasTbl, 1, 2, f_biasTxt(bias4h), text_color=color.white, text_size=size.small, bgcolor=f_biasCol(bias4h))
    table.cell(biasTbl, 0, 3, "15m + 4H", text_color=color.white, text_size=size.small, text_halign=text.align_left)
    table.cell(biasTbl, 1, 3, matchTxt, text_color=color.white, text_size=size.small, bgcolor=f_biasCol(nowBias))
    table.cell(biasTbl, 0, 4, "Day bias (aligned bars)", text_color=color.white, text_size=size.small, text_halign=text.align_left)
    table.cell(biasTbl, 1, 4, dayTxt, text_color=color.white, text_size=size.small, bgcolor=f_biasCol(dayBias))
    table.cell(biasTbl, 0, 5, "vs midnight open", text_color=color.white, text_size=size.small, text_halign=text.align_left)
    table.cell(biasTbl, 1, 5, chgTxt, text_color=color.white, text_size=size.small, bgcolor=chg > 0 ? f_biasCol(1) : chg < 0 ? f_biasCol(-1) : f_biasCol(0))
    table.cell(biasTbl, 0, 6, "Signals today", text_color=color.white, text_size=size.small, text_halign=text.align_left)
    table.cell(biasTbl, 1, 6, "B " + str.tostring(dayBuys) + " / S " + str.tostring(daySells), text_color=color.white, text_size=size.small)
    table.cell(biasTbl, 0, 7, "Absorption today", text_color=color.white, text_size=size.small, text_halign=text.align_left)
    table.cell(biasTbl, 1, 7, "Bull " + str.tostring(dayBullAbs) + " / Bear " + str.tostring(dayBearAbs), text_color=color.white, text_size=size.small)
    table.cell(biasTbl, 0, 8, "TP1 vs stop (all)", text_color=color.white, text_size=size.small, text_halign=text.align_left)
    table.cell(biasTbl, 1, 8, wrTxt, text_color=color.white, text_size=size.small, bgcolor=wrCol)
    table.cell(biasTbl, 0, 9, "TP1 vs stop (A / A+)", text_color=color.white, text_size=size.small, text_halign=text.align_left)
    table.cell(biasTbl, 1, 9, wrHiTxt, text_color=color.white, text_size=size.small, bgcolor=wrHiCol)
````
