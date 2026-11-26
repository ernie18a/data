# PDH/PDL + FVG + Order Blocks (Clean ICT)

- url: https://www.tradingview.com/script/m66dtUyk-PDH-PDL-FVG-Order-Blocks-Clean-ICT/
- type: indicator
- pine_id: PUB;91d6f2283f9e4e70940bad0f27aa23c8
- version: 1.0

## Description

**PDH/PDL + Session Highs/Lows + FVG + Order Blocks (Clean ICT)**

An all-in-one ICT/Smart Money toolkit that layers the core concepts traders use for daily bias and liquidity mapping onto a single, clean chart — no clutter, no repainting boxes, fully configurable.

**What it plots:**

📍 **Previous Day High / Low (PDH/PDL)**
Day boundary locked to a chosen timezone (defaults to New York midnight, the ICT standard), so the daily range always lines up with how ICT concepts are taught, regardless of your exchange's native session times.

🌏 **Asia / London / New York Session Highs & Lows**
Each session range builds live as price moves through it, then locks and stays on the chart once the session closes — giving you the classic liquidity pools traders watch for sweeps and reversals. All three sessions are fully customizable (time window, color) to match your own session definitions.

⚡ **Liquidity Sweep Tags (SFP)**
Automatically tags candles that wick through the prior day's high or low and close back inside it — a classic stop-hunt / failure-to-continue signal.

📊 **Fair Value Gaps (FVG)**
Detects 3-candle imbalances above a minimum size threshold (scaled to ATR, so it adapts across instruments and timeframes). Gaps auto-remove once fully filled, keeping the chart from filling up with stale zones.

🟦 **Order Blocks (OB)**
Marks the last opposing candle before a strong displacement move, with an ATR-based displacement filter and an optional "must leave an FVG" filter to cut down on noise. Blocks auto-remove once price closes through and mitigates them.

📈 **EMA**
A simple configurable EMA for trend context.

**Why it's different:**
- Everything is timezone-anchored, not just chart-timezone dependent — so PDH/PDL and session ranges stay accurate no matter what timezone your chart is displaying.
- Labels track live with price instead of sitting frozen back at the bar where a level formed, so the chart stays readable as new bars print.
- Old FVGs and Order Blocks clean themselves up once invalidated, instead of piling up indefinitely.
- Every color, threshold, and session window is adjustable from the settings panel — no code editing required.

**How to use it:**
1. Add the indicator and open Settings to toggle on/off any of the five modules (PDH/PDL, Sessions, FVG, Order Blocks, EMA).
2. Adjust the session time inputs to match the sessions you trade (defaults: Asia 20:00–00:00, London 02:00–05:00, New York 07:00–16:00, all in the day-boundary timezone).
3. Use the ATR-based thresholds to tune how many FVGs/Order Blocks show up — raise them for fewer, larger, higher-conviction zones; lower them to see more.
4. Watch for confluence: a liquidity sweep of PDH/PDL near a session high/low, followed by a fresh FVG or Order Block, is a common ICT-style setup.

**Notes:**
This script is for educational and analytical purposes and does not constitute financial advice. As with any tool, backtest and forward-test any strategy built around these concepts before trading live.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TJRDemoaccount

//@version=6
plot(close)
//@version=5
indicator("PDH/PDL + FVG + Order Blocks (Clean ICT)", overlay=true, max_boxes_count=200, max_lines_count=200, max_labels_count=200)

// ============================================================================
// INPUTS
// ============================================================================
grpLevels = "Previous Day High / Low"
showPDHL     = input.bool(true, "Show PDH / PDL", group=grpLevels)
pdhLineColor = input.color(color.new(color.green, 0), "PDH Line Color", group=grpLevels)
pdlLineColor = input.color(color.new(color.red, 0), "PDL Line Color", group=grpLevels)
pdLineWidth  = input.int(1, "Line Width", minval=1, maxval=4, group=grpLevels)
dayTZ        = input.string("America/New_York", "Day boundary timezone (ICT standard = NY midnight)", group=grpLevels)

grpSessions = "Asia / London / New York Session High-Low"
showAsia    = input.bool(true, "Show Asia High/Low", group=grpSessions)
asiaHiColor = input.color(color.new(color.purple, 0), "Asia High Color", group=grpSessions)
asiaLoColor = input.color(color.new(color.fuchsia, 0), "Asia Low Color", group=grpSessions)
asiaSession = input.session("2000-0000", "Asia session (in day boundary timezone)", group=grpSessions)
showLondon    = input.bool(true, "Show London High/Low", group=grpSessions)
londonHiColor = input.color(color.new(color.blue, 0), "London High Color", group=grpSessions)
londonLoColor = input.color(color.new(color.orange, 0), "London Low Color", group=grpSessions)
londonSession = input.session("0200-0500", "London session (in day boundary timezone)", group=grpSessions)
showNY      = input.bool(true, "Show New York High/Low", group=grpSessions)
nyHiColor   = input.color(color.new(color.lime, 0), "NY High Color", group=grpSessions)
nyLoColor   = input.color(color.new(color.maroon, 0), "NY Low Color", group=grpSessions)
nySession   = input.session("0700-1600", "New York session (in day boundary timezone)", group=grpSessions)
showSweeps   = input.bool(true, "Tag liquidity sweeps of PDH/PDL", group=grpLevels)

grpFVG = "Fair Value Gaps"
showFVG      = input.bool(true, "Show FVGs", group=grpFVG)
fvgBullColor = input.color(color.new(color.teal, 80), "Bullish FVG Color", group=grpFVG)
fvgBearColor = input.color(color.new(color.red, 80), "Bearish FVG Color", group=grpFVG)
fvgMaxCount  = input.int(6, "Max FVGs shown", minval=1, maxval=30, group=grpFVG)
minFvgSize   = input.float(0.15, "Minimum FVG size (x ATR14, higher = fewer/larger gaps)", minval=0.0, step=0.05, group=grpFVG)
removeFilledFVG = input.bool(true, "Remove FVG once fully filled", group=grpFVG)

grpOB = "Order Blocks"
showOB       = input.bool(true, "Show Order Blocks", group=grpOB)
obBullColor  = input.color(color.new(color.blue, 82), "Bullish OB Color", group=grpOB)
obBearColor  = input.color(color.new(color.orange, 82), "Bearish OB Color", group=grpOB)
obMaxCount   = input.int(4, "Max Order Blocks shown", minval=1, maxval=20, group=grpOB)
atrMult      = input.float(0.8, "Displacement threshold (x ATR14, lower = more OBs)", minval=0.1, maxval=5.0, step=0.1, group=grpOB)
minObSize    = input.float(0.15, "Minimum OB size (x ATR14, higher = fewer/larger blocks)", minval=0.0, step=0.05, group=grpOB)
requireFVGforOB = input.bool(false, "Only mark OB if displacement leaves an FVG (reduces noise)", group=grpOB)
removeMitigatedOB = input.bool(true, "Remove OB once mitigated (price closes through it)", group=grpOB)

grpEMA = "EMA"
showEMA   = input.bool(true, "Show EMA", group=grpEMA)
emaLength = input.int(20, "EMA Length", minval=1, group=grpEMA)
emaColor  = input.color(color.new(color.yellow, 0), "EMA Color", group=grpEMA)

// ============================================================================
// PREVIOUS DAY HIGH / LOW (day boundary locked to chosen timezone, NY midnight by default)
// ============================================================================
var float dayHigh = na
var float dayLow  = na
var float pdh = na
var float pdl = na

newDay = ta.change(time("D", "", dayTZ)) != 0

if newDay
    pdh := dayHigh
    pdl := dayLow
    dayHigh := high
    dayLow := low
else
    dayHigh := na(dayHigh) ? high : math.max(dayHigh, high)
    dayLow := na(dayLow) ? low : math.min(dayLow, low)

var line pdhLine = na
var line pdlLine = na
var label pdhLabel = na
var label pdlLabel = na

if showPDHL and (newDay or barstate.isfirst)
    // only redraw when the daily PDH/PDL value actually changes (new session)
    if not na(pdhLine)
        line.delete(pdhLine)
    if not na(pdlLine)
        line.delete(pdlLine)
    if not na(pdhLabel)
        label.delete(pdhLabel)
    if not na(pdlLabel)
        label.delete(pdlLabel)
    pdhLine := line.new(bar_index - 1, pdh, bar_index, pdh, extend=extend.right, color=pdhLineColor, width=pdLineWidth, style=line.style_solid)
    pdlLine := line.new(bar_index - 1, pdl, bar_index, pdl, extend=extend.right, color=pdlLineColor, width=pdLineWidth, style=line.style_solid)
    pdhLabel := label.new(bar_index, pdh, "PDH", style=label.style_label_down, color=color.new(color.gray,100), textcolor=pdhLineColor, size=size.small)
    pdlLabel := label.new(bar_index, pdl, "PDL", style=label.style_label_up, color=color.new(color.gray,100), textcolor=pdlLineColor, size=size.small)

// keep PDH/PDL labels pinned near the live edge of the chart rather than back where the day started
if showPDHL and not na(pdhLabel)
    label.set_xy(pdhLabel, bar_index, pdh)
if showPDHL and not na(pdlLabel)
    label.set_xy(pdlLabel, bar_index, pdl)

// ============================================================================
// LIQUIDITY SWEEP TAGS (wick through PDH/PDL, close back inside)
// ============================================================================
sweptHigh = showSweeps and high > pdh and close < pdh
sweptLow  = showSweeps and low < pdl and close > pdl

if sweptHigh
    label.new(bar_index, high, "SFP", style=label.style_label_down, color=color.new(color.red, 20), textcolor=color.white, size=size.tiny)
if sweptLow
    label.new(bar_index, low, "SFP", style=label.style_label_up, color=color.new(color.teal, 20), textcolor=color.white, size=size.tiny)

// ============================================================================
// ASIA / LONDON SESSION HIGH-LOW (updates live during each session, locks once it ends)
// ============================================================================
var float asiaHigh = na
var float asiaLow  = na
var line asiaHiLine = na
var line asiaLoLine = na
var label asiaHiLabel = na
var label asiaLoLabel = na

inAsiaSession = not na(time(timeframe.period, asiaSession, dayTZ))
asiaSessionStart = inAsiaSession and not inAsiaSession[1]

if showAsia and asiaSessionStart
    asiaHigh := high
    asiaLow := low
    if not na(asiaHiLine)
        line.delete(asiaHiLine)
    if not na(asiaLoLine)
        line.delete(asiaLoLine)
    if not na(asiaHiLabel)
        label.delete(asiaHiLabel)
    if not na(asiaLoLabel)
        label.delete(asiaLoLabel)
    asiaHiLine := line.new(bar_index, high, bar_index + 1, high, extend=extend.right, color=asiaHiColor, width=pdLineWidth, style=line.style_solid)
    asiaLoLine := line.new(bar_index, low, bar_index + 1, low, extend=extend.right, color=asiaLoColor, width=pdLineWidth, style=line.style_solid)
    asiaHiLabel := label.new(bar_index, high, "Asia H", style=label.style_label_down, color=color.new(color.gray,100), textcolor=asiaHiColor, size=size.small)
    asiaLoLabel := label.new(bar_index, low, "Asia L", style=label.style_label_up, color=color.new(color.gray,100), textcolor=asiaLoColor, size=size.small)
else if showAsia and inAsiaSession
    if high > asiaHigh
        asiaHigh := high
        line.set_xy1(asiaHiLine, line.get_x1(asiaHiLine), asiaHigh)
        line.set_xy2(asiaHiLine, bar_index, asiaHigh)
        label.set_xy(asiaHiLabel, bar_index, asiaHigh)
    if low < asiaLow
        asiaLow := low
        line.set_xy1(asiaLoLine, line.get_x1(asiaLoLine), asiaLow)
        line.set_xy2(asiaLoLine, bar_index, asiaLow)
        label.set_xy(asiaLoLabel, bar_index, asiaLow)

// keep Asia labels pinned near the live edge of the chart rather than back where the session ended
if showAsia and not na(asiaHiLabel)
    label.set_xy(asiaHiLabel, bar_index, asiaHigh)
if showAsia and not na(asiaLoLabel)
    label.set_xy(asiaLoLabel, bar_index, asiaLow)

var float londonHigh = na
var float londonLow  = na
var line londonHiLine = na
var line londonLoLine = na
var label londonHiLabel = na
var label londonLoLabel = na

inLondonSession = not na(time(timeframe.period, londonSession, dayTZ))
londonSessionStart = inLondonSession and not inLondonSession[1]

if showLondon and londonSessionStart
    londonHigh := high
    londonLow := low
    if not na(londonHiLine)
        line.delete(londonHiLine)
    if not na(londonLoLine)
        line.delete(londonLoLine)
    if not na(londonHiLabel)
        label.delete(londonHiLabel)
    if not na(londonLoLabel)
        label.delete(londonLoLabel)
    londonHiLine := line.new(bar_index, high, bar_index + 1, high, extend=extend.right, color=londonHiColor, width=pdLineWidth, style=line.style_solid)
    londonLoLine := line.new(bar_index, low, bar_index + 1, low, extend=extend.right, color=londonLoColor, width=pdLineWidth, style=line.style_solid)
    londonHiLabel := label.new(bar_index, high, "London H", style=label.style_label_down, color=color.new(color.gray,100), textcolor=londonHiColor, size=size.small)
    londonLoLabel := label.new(bar_index, low, "London L", style=label.style_label_up, color=color.new(color.gray,100), textcolor=londonLoColor, size=size.small)
else if showLondon and inLondonSession
    if high > londonHigh
        londonHigh := high
        line.set_xy1(londonHiLine, line.get_x1(londonHiLine), londonHigh)
        line.set_xy2(londonHiLine, bar_index, londonHigh)
        label.set_xy(londonHiLabel, bar_index, londonHigh)
    if low < londonLow
        londonLow := low
        line.set_xy1(londonLoLine, line.get_x1(londonLoLine), londonLow)
        line.set_xy2(londonLoLine, bar_index, londonLow)
        label.set_xy(londonLoLabel, bar_index, londonLow)

// keep London labels pinned near the live edge of the chart rather than back where the session ended
if showLondon and not na(londonHiLabel)
    label.set_xy(londonHiLabel, bar_index, londonHigh)
if showLondon and not na(londonLoLabel)
    label.set_xy(londonLoLabel, bar_index, londonLow)

var float nyHigh = na
var float nyLow  = na
var line nyHiLine = na
var line nyLoLine = na
var label nyHiLabel = na
var label nyLoLabel = na

inNYSession = not na(time(timeframe.period, nySession, dayTZ))
nySessionStart = inNYSession and not inNYSession[1]

if showNY and nySessionStart
    nyHigh := high
    nyLow := low
    if not na(nyHiLine)
        line.delete(nyHiLine)
    if not na(nyLoLine)
        line.delete(nyLoLine)
    if not na(nyHiLabel)
        label.delete(nyHiLabel)
    if not na(nyLoLabel)
        label.delete(nyLoLabel)
    nyHiLine := line.new(bar_index, high, bar_index + 1, high, extend=extend.right, color=nyHiColor, width=pdLineWidth, style=line.style_solid)
    nyLoLine := line.new(bar_index, low, bar_index + 1, low, extend=extend.right, color=nyLoColor, width=pdLineWidth, style=line.style_solid)
    nyHiLabel := label.new(bar_index, high, "NY H", style=label.style_label_down, color=color.new(color.gray,100), textcolor=nyHiColor, size=size.small)
    nyLoLabel := label.new(bar_index, low, "NY L", style=label.style_label_up, color=color.new(color.gray,100), textcolor=nyLoColor, size=size.small)
else if showNY and inNYSession
    if high > nyHigh
        nyHigh := high
        line.set_xy1(nyHiLine, line.get_x1(nyHiLine), nyHigh)
        line.set_xy2(nyHiLine, bar_index, nyHigh)
        label.set_xy(nyHiLabel, bar_index, nyHigh)
    if low < nyLow
        nyLow := low
        line.set_xy1(nyLoLine, line.get_x1(nyLoLine), nyLow)
        line.set_xy2(nyLoLine, bar_index, nyLow)
        label.set_xy(nyLoLabel, bar_index, nyLow)

// keep NY labels pinned near the live edge of the chart rather than back where the session ended
if showNY and not na(nyHiLabel)
    label.set_xy(nyHiLabel, bar_index, nyHigh)
if showNY and not na(nyLoLabel)
    label.set_xy(nyLoLabel, bar_index, nyLow)

// ============================================================================
// FAIR VALUE GAPS
// ============================================================================
var box[] bullFvgBoxes = array.new_box()
var box[] bearFvgBoxes = array.new_box()

bullFVG = showFVG and low > high[2] and (low - high[2]) > ta.atr(14) * minFvgSize
bearFVG = showFVG and high < low[2] and (low[2] - high) > ta.atr(14) * minFvgSize

if bullFVG
    top = low
    bot = high[2]
    b = box.new(bar_index[2], top, bar_index + 20, bot, border_color=color.new(fvgBullColor,60), bgcolor=fvgBullColor, extend=extend.none, text="FVG", text_color=color.new(color.teal,0), text_size=size.tiny, text_halign=text.align_right)
    array.push(bullFvgBoxes, b)
    if array.size(bullFvgBoxes) > fvgMaxCount
        box.delete(array.shift(bullFvgBoxes))

if bearFVG
    top = low[2]
    bot = high
    b = box.new(bar_index[2], top, bar_index + 20, bot, border_color=color.new(fvgBearColor,60), bgcolor=fvgBearColor, extend=extend.none, text="FVG", text_color=color.new(color.red,0), text_size=size.tiny, text_halign=text.align_right)
    array.push(bearFvgBoxes, b)
    if array.size(bearFvgBoxes) > fvgMaxCount
        box.delete(array.shift(bearFvgBoxes))

// extend + optionally remove filled FVGs each bar
if showFVG and array.size(bullFvgBoxes) > 0
    for i = array.size(bullFvgBoxes) - 1 to 0
        b = array.get(bullFvgBoxes, i)
        box.set_right(b, bar_index + 20)
        if removeFilledFVG and low <= box.get_bottom(b)
            box.delete(b)
            array.remove(bullFvgBoxes, i)
if showFVG and array.size(bearFvgBoxes) > 0
    for i = array.size(bearFvgBoxes) - 1 to 0
        b = array.get(bearFvgBoxes, i)
        box.set_right(b, bar_index + 20)
        if removeFilledFVG and high >= box.get_top(b)
            box.delete(b)
            array.remove(bearFvgBoxes, i)

// ============================================================================
// ORDER BLOCKS (simplified ICT: last opposite candle before displacement)
// ============================================================================
var box[] bullObBoxes = array.new_box()
var box[] bearObBoxes = array.new_box()

bigMove = math.abs(close - open) > ta.atr(14) * atrMult

// bullish displacement up, last down candle before it = bullish OB
bullDisp = showOB and close > open and bigMove and (requireFVGforOB ? bullFVG : true)
bearDisp = showOB and close < open and bigMove and (requireFVGforOB ? bearFVG : true)
obBigEnough = (high[1] - low[1]) > ta.atr(14) * minObSize

if bullDisp and close[1] < open[1] and obBigEnough
    b = box.new(bar_index[1], high[1], bar_index + 20, low[1], border_color=color.new(obBullColor,40), bgcolor=obBullColor, extend=extend.none, text="OB", text_color=color.new(color.blue,0), text_size=size.tiny, text_halign=text.align_right)
    array.push(bullObBoxes, b)
    if array.size(bullObBoxes) > obMaxCount
        box.delete(array.shift(bullObBoxes))

if bearDisp and close[1] > open[1] and obBigEnough
    b = box.new(bar_index[1], high[1], bar_index + 20, low[1], border_color=color.new(obBearColor,40), bgcolor=obBearColor, extend=extend.none, text="OB", text_color=color.new(color.orange,0), text_size=size.tiny, text_halign=text.align_right)
    array.push(bearObBoxes, b)
    if array.size(bearObBoxes) > obMaxCount
        box.delete(array.shift(bearObBoxes))

if showOB and array.size(bullObBoxes) > 0
    for i = array.size(bullObBoxes) - 1 to 0
        b = array.get(bullObBoxes, i)
        box.set_right(b, bar_index + 20)
        if removeMitigatedOB and close < box.get_bottom(b)
            box.delete(b)
            array.remove(bullObBoxes, i)
if showOB and array.size(bearObBoxes) > 0
    for i = array.size(bearObBoxes) - 1 to 0
        b = array.get(bearObBoxes, i)
        box.set_right(b, bar_index + 20)
        if removeMitigatedOB and close > box.get_top(b)
            box.delete(b)
            array.remove(bearObBoxes, i)

// ============================================================================
// EMA
// ============================================================================
emaVal = ta.ema(close, emaLength)
plot(showEMA ? emaVal : na, title="EMA", color=emaColor, linewidth=2)
````
