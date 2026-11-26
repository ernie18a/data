# Imtiyaz Signature Liquidity Compass SMC

- url: https://www.tradingview.com/script/mo4lABG2-Imtiyaz-Signature-Liquidity-Compass-SMC/
- type: indicator
- pine_id: PUB;d58bde2e64944d5cab8db4d64fb3b0b7
- version: 2.0

## Description

[b]Imtiyaz Signature Liquidity Compass SMC[/b]

Imtiyaz Signature Liquidity Compass SMC is an original Smart Money Concepts decision-support indicator that maps nearby buy-side and sell-side liquidity, tracks sweeps, highlights structure breaks, displays fair value gaps, and ranks the strongest active liquidity target on each side of price.

The purpose of the tool is not to predict the future or issue guaranteed buy/sell calls. It is designed to help traders see where meaningful liquidity may be resting, whether one side of the market has stronger current pull, and how that context lines up with structure and higher-timeframe trend.
[b]
What It Shows[/b]

[list]
[*]Buy-side liquidity pools above price, based on confirmed swing highs.
[*]Sell-side liquidity pools below price, based on confirmed swing lows.
[*]Buy-side and sell-side liquidity sweeps.
[*]Bullish and bearish BOS events.
[*]Bullish and bearish CHOCH events when structure changes direction.
[*]Bullish and bearish Fair Value Gaps.
[*]A compact dashboard showing upside pull, downside pull, net pull, active pool counts, HTF trend, and current structure.
[/list]

[b]Scoring Model[/b]
Every active liquidity pool receives a 0-100 score. The score is a weighted context reading, not a probability.

The score combines:
[list]
[*]
[*]Distance from current price, normalized by ATR.
[*]Volume at the swing that created the pool.
[*]Freshness of the pool.
[*]Number of touches or reactions.
[*]Whether the pool is still on the correct side of price.
[*]Higher-timeframe EMA trend alignment.
[/list]
The dashboard compares the strongest upside pool against the strongest downside pool. If the difference is small, the field is marked Balanced. If one side is stronger by the selected threshold, the dashboard marks Upside Pull or Downside Pull.

[b]Main Settings[/b]

Swing Confirmation Length controls how important a swing must be before it becomes a liquidity pool. A higher value creates fewer but more significant levels.

Maximum Pools Per Side limits how many active buy-side and sell-side pools are kept on the chart.

Pool Freshness Window controls how quickly old pools lose score.

Touch Buffer ATR controls how close price must get before a pool is considered touched.

Sweep Confirmation lets you choose between wick-only sweep detection and stricter close-back-inside sweep detection.

Minimum Visible Pool Score hides weaker pools so the chart remains clean.

Dominance Threshold controls how much stronger one side must be before the dashboard changes from Balanced to a directional pull.

HTF Trend Timeframe and HTF EMA Length define the higher-timeframe trend component used in the scoring engine.

[b]Alerts[/b]

The indicator includes alerts for:

[list]
[*]Buy-side liquidity sweep.
[*]Sell-side liquidity sweep.
[*]Bullish BOS or CHOCH.
[*]Bearish BOS or CHOCH.
[*]Upside liquidity pull becoming dominant.
[*]Downside liquidity pull becoming dominant.
[*]Bullish FVG formation.
[*]Bearish FVG formation.
[/list]

[b]How To Use[/b]
Start with the dashboard. If the field is Balanced, liquidity pressure is mixed and traders may prefer to wait for a sweep, structure break, or FVG reaction. If Upside Pull or Downside Pull is dominant, look at the strongest marked pool and judge whether price action supports a move toward or away from that area.

Liquidity sweeps can be used as context for potential reversals or displacement. BOS and CHOCH markers help separate continuation from possible directional change. FVGs highlight imbalance areas that may later be revisited or mitigated.

This indicator is best used alongside a complete trading plan, risk management, and independent confirmation. It does not guarantee future price movement, win rate, profitability, or signal accuracy.

[b]Originality[/b]

Imtiyaz Signature Liquidity Compass SMC uses an original scoring model that combines liquidity-pool distance, swing volume, freshness, reaction count, side validity, and higher-timeframe trend alignment. The goal is to reduce chart clutter by showing the pools that currently matter most, while keeping the logic transparent and avoiding unsupported probability claims.

[b]Disclaimer[/b]

This script is for educational and informational purposes only. Trading involves risk. Always do your own analysis before taking any trade.

## Source Code

````pine
//@version=6
indicator("Imtiyaz Signature Liquidity Compass SMC", "Imtiyaz's Compass", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=200)

// Liquidity Compass is an original decision-support indicator. It does not predict
// future price. It ranks visible liquidity pools and SMC context using current data.
// Disclaimer: This script is for educational and informational purposes only.
// Trading involves risk. Always do your own analysis before taking any trade.

grpPools = "Liquidity Pools"
swingLen = input.int(5, "Swing Confirmation Length", minval=2, maxval=50, group=grpPools)
maxPools = input.int(18, "Maximum Pools Per Side", minval=3, maxval=50, group=grpPools)
staleBars = input.int(300, "Pool Freshness Window", minval=25, maxval=2000, group=grpPools)
touchAtrBuffer = input.float(0.10, "Touch Buffer ATR", minval=0.0, maxval=2.0, step=0.05, group=grpPools)
sweepCloseMode = input.string("Close Back Inside", "Sweep Confirmation", options=["Close Back Inside", "Wick Touch"], group=grpPools)

grpScore = "Scoring Engine"
atrLen = input.int(14, "ATR Length", minval=2, group=grpScore)
reachAtr = input.float(8.0, "Maximum Scored Reach ATR", minval=1.0, maxval=50.0, step=0.5, group=grpScore)
volLen = input.int(50, "Volume Baseline Length", minval=2, group=grpScore)
volSpikeRef = input.float(2.0, "Full Volume Score At", minval=0.5, maxval=10.0, step=0.1, group=grpScore)
minDisplayScore = input.float(35.0, "Minimum Visible Pool Score", minval=0.0, maxval=100.0, step=1.0, group=grpScore)
dominanceThreshold = input.float(12.0, "Bias Threshold", minval=1.0, maxval=50.0, step=1.0, group=grpScore)

grpStructure = "SMC Context"
showStructure = input.bool(true, "Show BOS and CHoCH", group=grpStructure)
showFvg = input.bool(true, "Show Fair Value Gaps", group=grpStructure)
maxFvg = input.int(12, "Maximum Active FVGs", minval=1, maxval=50, group=grpStructure)
fvgMitigation = input.string("Any Touch", "FVG Mitigation", options=["Any Touch", "Close Through"], group=grpStructure)
htfTf = input.timeframe("240", "HTF Trend Timeframe", group=grpStructure)
htfEmaLen = input.int(50, "HTF EMA Length", minval=2, group=grpStructure)

grpVisual = "Visuals"
showPools = input.bool(true, "Show Liquidity Pools", group=grpVisual)
showLabels = input.bool(true, "Show Pool Labels", group=grpVisual)
showSweeps = input.bool(true, "Show Sweep Markers", group=grpVisual)
showDashboard = input.bool(true, "Show Dashboard", group=grpVisual)
rightBars = input.int(40, "Right Extension Bars", minval=5, maxval=300, group=grpVisual)
upColor = input.color(color.rgb(0, 180, 160), "Upside Liquidity Color", group=grpVisual)
downColor = input.color(color.rgb(240, 80, 80), "Downside Liquidity Color", group=grpVisual)
bullColor = input.color(color.rgb(0, 170, 90), "Bullish Context Color", group=grpVisual)
bearColor = input.color(color.rgb(220, 60, 60), "Bearish Context Color", group=grpVisual)
neutralColor = input.color(color.rgb(140, 145, 155), "Neutral Color", group=grpVisual)

atr = ta.atr(atrLen)
volBase = ta.sma(volume, volLen)
volRatioNow = volBase > 0.0 ? volume / volBase : 1.0
htfEma = request.security(syminfo.tickerid, htfTf, ta.ema(close, htfEmaLen), barmerge.gaps_off, barmerge.lookahead_off)
htfEmaPrev = request.security(syminfo.tickerid, htfTf, ta.ema(close, htfEmaLen)[3], barmerge.gaps_off, barmerge.lookahead_off)
htfTrend = close > htfEma and htfEma > htfEmaPrev ? 1 : close < htfEma and htfEma < htfEmaPrev ? -1 : 0

var array<float> upPrices = array.new_float()
var array<int> upBars = array.new_int()
var array<float> upVols = array.new_float()
var array<int> upTouches = array.new_int()
var array<bool> upActive = array.new_bool()
var array<bool> upSwept = array.new_bool()
var array<line> upLines = array.new_line()
var array<label> upLabels = array.new_label()

var array<float> dnPrices = array.new_float()
var array<int> dnBars = array.new_int()
var array<float> dnVols = array.new_float()
var array<int> dnTouches = array.new_int()
var array<bool> dnActive = array.new_bool()
var array<bool> dnSwept = array.new_bool()
var array<line> dnLines = array.new_line()
var array<label> dnLabels = array.new_label()

var array<box> fvgBoxes = array.new_box()
var array<float> fvgTops = array.new_float()
var array<float> fvgBots = array.new_float()
var array<int> fvgDirs = array.new_int()
var array<bool> fvgActive = array.new_bool()

f_poolScore(float price, int bornBar, float bornVolRatio, int touches, int side) =>
    float distAtr = math.abs(price - close) / math.max(atr, syminfo.mintick)
    float distanceScore = math.max(0.0, 1.0 - distAtr / reachAtr) * 25.0
    float volumeScore = math.min(bornVolRatio / volSpikeRef, 1.0) * 20.0
    float age = bar_index - bornBar
    float freshnessScore = math.max(0.0, 1.0 - age / staleBars) * 15.0
    float touchScore = math.min(touches, 3) / 3.0 * 15.0
    bool sideOk = side == 1 ? price > close : price < close
    float locationScore = sideOk ? 10.0 : 0.0
    float trendScore = side == 1 and htfTrend == 1 ? 15.0 : side == -1 and htfTrend == -1 ? 15.0 : htfTrend == 0 ? 7.5 : 0.0
    distanceScore + volumeScore + freshnessScore + touchScore + locationScore + trendScore

f_deleteUp(int idx) =>
    line.delete(array.get(upLines, idx))
    label.delete(array.get(upLabels, idx))
    array.remove(upPrices, idx)
    array.remove(upBars, idx)
    array.remove(upVols, idx)
    array.remove(upTouches, idx)
    array.remove(upActive, idx)
    array.remove(upSwept, idx)
    array.remove(upLines, idx)
    array.remove(upLabels, idx)

f_deleteDn(int idx) =>
    line.delete(array.get(dnLines, idx))
    label.delete(array.get(dnLabels, idx))
    array.remove(dnPrices, idx)
    array.remove(dnBars, idx)
    array.remove(dnVols, idx)
    array.remove(dnTouches, idx)
    array.remove(dnActive, idx)
    array.remove(dnSwept, idx)
    array.remove(dnLines, idx)
    array.remove(dnLabels, idx)

f_addUp(float price, int bornBar, float bornVolRatio) =>
    line poolLine = line.new(bornBar, price, bar_index + rightBars, price, xloc=xloc.bar_index, color=color.new(upColor, 45), style=line.style_dashed, width=1)
    label poolLabel = label.new(bar_index + rightBars, price, "", xloc=xloc.bar_index, style=label.style_label_left, color=color.new(upColor, 85), textcolor=upColor, size=size.tiny)
    array.push(upPrices, price)
    array.push(upBars, bornBar)
    array.push(upVols, bornVolRatio)
    array.push(upTouches, 0)
    array.push(upActive, true)
    array.push(upSwept, false)
    array.push(upLines, poolLine)
    array.push(upLabels, poolLabel)
    if array.size(upPrices) > maxPools
        f_deleteUp(0)

f_addDn(float price, int bornBar, float bornVolRatio) =>
    line poolLine = line.new(bornBar, price, bar_index + rightBars, price, xloc=xloc.bar_index, color=color.new(downColor, 45), style=line.style_dashed, width=1)
    label poolLabel = label.new(bar_index + rightBars, price, "", xloc=xloc.bar_index, style=label.style_label_left, color=color.new(downColor, 85), textcolor=downColor, size=size.tiny)
    array.push(dnPrices, price)
    array.push(dnBars, bornBar)
    array.push(dnVols, bornVolRatio)
    array.push(dnTouches, 0)
    array.push(dnActive, true)
    array.push(dnSwept, false)
    array.push(dnLines, poolLine)
    array.push(dnLabels, poolLabel)
    if array.size(dnPrices) > maxPools
        f_deleteDn(0)

ph = ta.pivothigh(high, swingLen, swingLen)
pl = ta.pivotlow(low, swingLen, swingLen)
newUpPool = not na(ph)
newDnPool = not na(pl)

if newUpPool
    float bornVol = nz(volRatioNow[swingLen], 1.0)
    f_addUp(ph, bar_index - swingLen, bornVol)

if newDnPool
    float bornVol = nz(volRatioNow[swingLen], 1.0)
    f_addDn(pl, bar_index - swingLen, bornVol)

var float lastSwingHigh = na
var float lastSwingLow = na
if newUpPool
    lastSwingHigh := ph
if newDnPool
    lastSwingLow := pl

bullBreak = not na(lastSwingHigh) and close > lastSwingHigh and close[1] <= lastSwingHigh
bearBreak = not na(lastSwingLow) and close < lastSwingLow and close[1] >= lastSwingLow
var int structureTrend = 0
bullChoch = bullBreak and structureTrend == -1
bearChoch = bearBreak and structureTrend == 1
if bullBreak
    structureTrend := 1
if bearBreak
    structureTrend := -1

bool buySideSweep = false
bool sellSideSweep = false
float bestUpScore = na
float bestDnScore = na
float bestUpPrice = na
float bestDnPrice = na
int activeUpCount = 0
int activeDnCount = 0

int upCount = array.size(upPrices)
if upCount > 0
    for i = upCount - 1 to 0
        float p = array.get(upPrices, i)
        int b = array.get(upBars, i)
        bool active = array.get(upActive, i)
        bool touched = high >= p - atr * touchAtrBuffer
        bool swept = sweepCloseMode == "Close Back Inside" ? high > p and close < p : high >= p
        bool alreadySwept = array.get(upSwept, i)
        bool consumed = close > p + atr * touchAtrBuffer
        if active and touched
            array.set(upTouches, i, array.get(upTouches, i) + 1)
        if active and swept and not alreadySwept
            buySideSweep := true
            array.set(upSwept, i, true)
        if consumed or bar_index - b > staleBars * 2
            array.set(upActive, i, false)
            active := false

        float s = f_poolScore(p, b, array.get(upVols, i), array.get(upTouches, i), 1)
        bool visible = showPools and active and s >= minDisplayScore and p > close
        color c = color.new(upColor, visible ? math.round(math.max(5.0, 80.0 - s * 0.65)) : 100)
        line ln = array.get(upLines, i)
        label lb = array.get(upLabels, i)
        line.set_xy1(ln, b, p)
        line.set_xy2(ln, bar_index + rightBars, p)
        line.set_color(ln, c)
        line.set_width(ln, s >= 70.0 ? 2 : 1)
        label.set_x(lb, bar_index + rightBars)
        label.set_y(lb, p)
        label.set_text(lb, visible and showLabels ? "BSL " + str.tostring(s, "#") : "")
        label.set_color(lb, color.new(upColor, 86))
        label.set_textcolor(lb, upColor)
        if active and p > close
            activeUpCount += 1
            if na(bestUpScore) or s > bestUpScore
                bestUpScore := s
                bestUpPrice := p

int dnCount = array.size(dnPrices)
if dnCount > 0
    for i = dnCount - 1 to 0
        float p = array.get(dnPrices, i)
        int b = array.get(dnBars, i)
        bool active = array.get(dnActive, i)
        bool touched = low <= p + atr * touchAtrBuffer
        bool swept = sweepCloseMode == "Close Back Inside" ? low < p and close > p : low <= p
        bool alreadySwept = array.get(dnSwept, i)
        bool consumed = close < p - atr * touchAtrBuffer
        if active and touched
            array.set(dnTouches, i, array.get(dnTouches, i) + 1)
        if active and swept and not alreadySwept
            sellSideSweep := true
            array.set(dnSwept, i, true)
        if consumed or bar_index - b > staleBars * 2
            array.set(dnActive, i, false)
            active := false

        float s = f_poolScore(p, b, array.get(dnVols, i), array.get(dnTouches, i), -1)
        bool visible = showPools and active and s >= minDisplayScore and p < close
        color c = color.new(downColor, visible ? math.round(math.max(5.0, 80.0 - s * 0.65)) : 100)
        line ln = array.get(dnLines, i)
        label lb = array.get(dnLabels, i)
        line.set_xy1(ln, b, p)
        line.set_xy2(ln, bar_index + rightBars, p)
        line.set_color(ln, c)
        line.set_width(ln, s >= 70.0 ? 2 : 1)
        label.set_x(lb, bar_index + rightBars)
        label.set_y(lb, p)
        label.set_text(lb, visible and showLabels ? "SSL " + str.tostring(s, "#") : "")
        label.set_color(lb, color.new(downColor, 86))
        label.set_textcolor(lb, downColor)
        if active and p < close
            activeDnCount += 1
            if na(bestDnScore) or s > bestDnScore
                bestDnScore := s
                bestDnPrice := p

bullFvg = showFvg and low > high[2]
bearFvg = showFvg and high < low[2]

f_addFvg(float top, float bot, int dir) =>
    color boxColor = dir == 1 ? color.new(bullColor, 86) : color.new(bearColor, 86)
    color borderColor = dir == 1 ? color.new(bullColor, 55) : color.new(bearColor, 55)
    box fvgBox = box.new(bar_index - 2, top, bar_index + rightBars, bot, xloc=xloc.bar_index, bgcolor=boxColor, border_color=borderColor)
    array.push(fvgBoxes, fvgBox)
    array.push(fvgTops, top)
    array.push(fvgBots, bot)
    array.push(fvgDirs, dir)
    array.push(fvgActive, true)
    if array.size(fvgBoxes) > maxFvg
        box.delete(array.shift(fvgBoxes))
        array.shift(fvgTops)
        array.shift(fvgBots)
        array.shift(fvgDirs)
        array.shift(fvgActive)

if bullFvg
    f_addFvg(low, high[2], 1)
if bearFvg
    f_addFvg(low[2], high, -1)

int fvgCount = array.size(fvgBoxes)
if fvgCount > 0
    for i = fvgCount - 1 to 0
        box bx = array.get(fvgBoxes, i)
        float top = array.get(fvgTops, i)
        float bot = array.get(fvgBots, i)
        int dir = array.get(fvgDirs, i)
        bool active = array.get(fvgActive, i)
        bool mitigated = dir == 1 ? (fvgMitigation == "Any Touch" ? low <= top and high >= bot : close < bot) : (fvgMitigation == "Any Touch" ? high >= bot and low <= top : close > top)
        if active and mitigated
            array.set(fvgActive, i, false)
            active := false
        box.set_right(bx, bar_index + rightBars)
        box.set_bgcolor(bx, active ? (dir == 1 ? color.new(bullColor, 86) : color.new(bearColor, 86)) : color.new(neutralColor, 94))
        box.set_border_color(bx, active ? (dir == 1 ? color.new(bullColor, 55) : color.new(bearColor, 55)) : color.new(neutralColor, 90))

upPull = nz(bestUpScore, 0.0)
dnPull = nz(bestDnScore, 0.0)
netPull = upPull - dnPull
fieldState = math.abs(netPull) < dominanceThreshold ? "Balanced" : netPull > 0.0 ? "Upside Pull" : "Downside Pull"
fieldColor = math.abs(netPull) < dominanceThreshold ? neutralColor : netPull > 0.0 ? upColor : downColor

plotshape(showSweeps and buySideSweep, "Buy-Side Liquidity Sweep", shape.xcross, location.abovebar, color.new(upColor, 0), text="BSL Sweep", textcolor=upColor, size=size.tiny)
plotshape(showSweeps and sellSideSweep, "Sell-Side Liquidity Sweep", shape.xcross, location.belowbar, color.new(downColor, 0), text="SSL Sweep", textcolor=downColor, size=size.tiny)
plotshape(showStructure and bullBreak and not bullChoch, "Bullish BOS", shape.triangleup, location.belowbar, color.new(bullColor, 0), text="BOS", textcolor=bullColor, size=size.tiny)
plotshape(showStructure and bearBreak and not bearChoch, "Bearish BOS", shape.triangledown, location.abovebar, color.new(bearColor, 0), text="BOS", textcolor=bearColor, size=size.tiny)
plotshape(showStructure and bullChoch, "Bullish CHoCH", shape.labelup, location.belowbar, color.new(bullColor, 0), text="CHoCH", textcolor=color.white, size=size.tiny)
plotshape(showStructure and bearChoch, "Bearish CHoCH", shape.labeldown, location.abovebar, color.new(bearColor, 0), text="CHoCH", textcolor=color.white, size=size.tiny)

var table dash = table.new(position.top_right, 2, 7, border_width=1)
if showDashboard and barstate.islast
    table.cell(dash, 0, 0, "Imtiyaz Compass", text_color=color.white, bgcolor=fieldColor)
    table.cell(dash, 1, 0, fieldState, text_color=color.white, bgcolor=fieldColor)
    table.cell(dash, 0, 1, "Upside pull", text_color=upColor, bgcolor=color.new(color.black, 0))
    table.cell(dash, 1, 1, str.tostring(upPull, "#") + " @ " + (na(bestUpPrice) ? "-" : str.tostring(bestUpPrice, format.mintick)), text_color=upColor, bgcolor=color.new(color.black, 0))
    table.cell(dash, 0, 2, "Downside pull", text_color=downColor, bgcolor=color.new(color.black, 0))
    table.cell(dash, 1, 2, str.tostring(dnPull, "#") + " @ " + (na(bestDnPrice) ? "-" : str.tostring(bestDnPrice, format.mintick)), text_color=downColor, bgcolor=color.new(color.black, 0))
    table.cell(dash, 0, 3, "Net", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(dash, 1, 3, str.tostring(netPull, "#"), text_color=fieldColor, bgcolor=color.new(color.black, 0))
    table.cell(dash, 0, 4, "Active pools", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(dash, 1, 4, str.tostring(activeUpCount) + " up / " + str.tostring(activeDnCount) + " down", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(dash, 0, 5, "HTF trend", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(dash, 1, 5, htfTrend == 1 ? "Bullish" : htfTrend == -1 ? "Bearish" : "Neutral", text_color=htfTrend == 1 ? bullColor : htfTrend == -1 ? bearColor : neutralColor, bgcolor=color.new(color.black, 0))
    table.cell(dash, 0, 6, "Structure", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(dash, 1, 6, structureTrend == 1 ? "Bullish" : structureTrend == -1 ? "Bearish" : "Unknown", text_color=structureTrend == 1 ? bullColor : structureTrend == -1 ? bearColor : neutralColor, bgcolor=color.new(color.black, 0))
else if not showDashboard and barstate.islast
    table.clear(dash, 0, 0, 1, 6)

alertcondition(buySideSweep, "Buy-Side Liquidity Sweep", "Buy-side liquidity was swept on {{ticker}} {{interval}} near {{close}}.")
alertcondition(sellSideSweep, "Sell-Side Liquidity Sweep", "Sell-side liquidity was swept on {{ticker}} {{interval}} near {{close}}.")
alertcondition(bullBreak, "Bullish BOS or CHoCH", "Bullish structure break on {{ticker}} {{interval}} near {{close}}.")
alertcondition(bearBreak, "Bearish BOS or CHoCH", "Bearish structure break on {{ticker}} {{interval}} near {{close}}.")
alertcondition(math.abs(netPull) >= dominanceThreshold and netPull > 0.0 and netPull[1] <= dominanceThreshold, "Upside Liquidity Pull", "Upside liquidity pull became dominant on {{ticker}} {{interval}}.")
alertcondition(math.abs(netPull) >= dominanceThreshold and netPull < 0.0 and netPull[1] >= -dominanceThreshold, "Downside Liquidity Pull", "Downside liquidity pull became dominant on {{ticker}} {{interval}}.")
alertcondition(bullFvg, "Bullish FVG Formed", "Bullish fair value gap formed on {{ticker}} {{interval}}.")
alertcondition(bearFvg, "Bearish FVG Formed", "Bearish fair value gap formed on {{ticker}} {{interval}}.")
````
