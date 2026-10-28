# Gap Hunter Pro [forexobroker]

- url: https://www.tradingview.com/script/KcolabFG-Gap-Hunter-Pro-forexobroker/
- type: indicator
- pine_id: PUB;cd3251fa53ca4af88206431ce93dd2f6
- version: 1.0

## Description

Gap Hunter Pro is a specialized tool for detecting, classifying, and tracking price gaps in real time. Price gaps are among the most powerful yet underutilized chart features -- they reveal sudden shifts in supply and demand that occurred between trading sessions or during high-impact events. This indicator automates the entire gap analysis workflow from detection through fill tracking.

What sets Gap Hunter Pro apart is its gap classification engine. Rather than treating all gaps equally, it categorizes each gap as a Breakaway, Continuation, or Exhaustion gap based on trend context, volume characteristics, and price extension. This classification helps traders determine whether a gap is likely to fill or continue, which is critical for choosing the right trading approach.

The indicator serves both gap-fill traders who expect price to return to fill open gaps, and gap-and-go traders who want to ride the momentum when price accelerates away from an unfilled gap.

CONCEPTS

Not all price gaps carry the same meaning. Breakaway gaps occur with high volume as price moves in the trend direction from a non-extended position -- these tend to signal the start of a new trend leg and often remain unfilled for extended periods. Continuation gaps appear mid-trend with moderate volume, confirming that the existing move has further to run. Exhaustion gaps happen on low volume when price is already extended far from the trend mean -- these are the most likely to fill quickly.

Understanding gap fill statistics is also valuable. Studies across asset classes show that a large percentage of gaps eventually fill, but the timing varies enormously based on gap type and market conditions. Tracking fill rates in real time helps calibrate expectations for each open gap on your chart.

HOW IT WORKS

- Detects gaps when the open of the current bar differs from the previous close by more than the minimum gap percentage
- Classifies each gap using trend EMA position, volume ratio, and price extension from the mean
- Draws color-coded zone boxes: green for Breakaway, purple for Continuation, orange for Exhaustion
- Monitors all open gaps on every bar and marks them as filled when price returns through the zone
- Fires Gap Fill signals when a gap fills with above-average volume, and Gap-and-Go signals when price trends away from an unfilled gap with conviction
- Maintains a real-time fill rate statistic for all tracked gaps

HOW TO USE

1. Add the indicator to any chart -- gaps will automatically appear as colored zones
2. Note the gap type label (BRK, CNT, EXH) and percentage size on each gap zone
3. For gap-fill trading: watch for price approaching an open gap zone, and look for BUY/SELL fill signals when price enters the zone with volume
4. For gap-and-go trading: watch for price accelerating away from fresh gaps, confirmed by the gap-and-go signal with volume
5. Use the info table to monitor total gaps, fill count, open gaps, and fill rate
6. Place stops beyond the opposite side of the gap zone for gap-fill trades

FEATURES

- Non-repainting signals (barstate.isconfirmed)
- Works on all timeframes and instruments
- 9 alert conditions with JSON webhook support
- Three-category gap classification (Breakaway, Continuation, Exhaustion)
- Persistent gap zone boxes that extend until filled or expire
- Real-time fill rate tracking and statistics table
- Dual signal types: Gap Fill and Gap-and-Go

SETTINGS GUIDE

- Minimum Gap Size (%) -- Smallest gap worth tracking as a percentage of price (default 0.1%)
- Max Tracked Gaps -- Maximum number of gap zones displayed simultaneously (default 20)
- Trend EMA Length -- EMA period for determining trend context during gap classification (default 50)
- Volume SMA Length -- Period for the volume moving average used in signals (default 20)
- Signal Cooldown (bars) -- Minimum bars between consecutive signals (default 15)
- Show Filled Gaps (faded) -- Toggle whether filled gaps remain visible in gray

ALERTS

- Bullish Gap Fill -- Price fills a gap down zone with bullish candle and volume
- Bearish Gap Fill -- Price fills a gap up zone with bearish candle and volume
- Bullish Gap and Go -- Price trends up away from unfilled gap with volume
- Bearish Gap and Go -- Price trends down away from unfilled gap with volume
- Gap Up Detected -- A new gap up is identified
- Gap Down Detected -- A new gap down is identified
- Any Gap Filled -- Any tracked gap gets filled
- Any Signal -- Either fill or gap-and-go signal fires
- Large Gap -- A gap exceeding 1% of price is detected

LIMITATIONS & DISCLAIMER

- Technical analysis tool, not financial advice
- Past gap fill patterns do not guarantee future behavior
- Gap detection relies on session close-to-open price differences; instruments that trade continuously (24/7 crypto) may produce fewer traditional gaps
- Very small gaps near the minimum threshold may produce noise on volatile instruments
- Gap classification is based on heuristics and may not perfectly categorize every gap

## Source Code

````pine
// © forexobroker
//@version=6
indicator("Gap Hunter Pro [forexobroker]", shorttitle="GHP [fob]", overlay=true, max_labels_count=500, max_boxes_count=500)

// ─── INPUTS ────────────────────────────────────────────────────────────────────
grp_core = "Core Settings"
minGapPct    = input.float(0.1, "Minimum Gap Size (%)", minval=0.01, maxval=2.0, step=0.05, group=grp_core, tooltip="Minimum gap as % of price to track")
maxGaps      = input.int(20, "Max Tracked Gaps", minval=5, maxval=50, group=grp_core, tooltip="Maximum number of gap zones to display")
trendEmaLen  = input.int(50, "Trend EMA Length", minval=10, maxval=200, group=grp_core, tooltip="EMA for gap classification trend context")
volSmaLen    = input.int(20, "Volume SMA Length", minval=5, maxval=50, group=grp_core)
cooldownBars = input.int(15, "Signal Cooldown (bars)", minval=5, maxval=50, group=grp_core)

grp_vis = "Visual Settings"
showTable    = input.bool(true, "Show Info Table", group=grp_vis)
showFilledGaps = input.bool(true, "Show Filled Gaps (faded)", group=grp_vis)
neonCyan     = input.color(#00d4ff, "Buy/Gap Up Color", group=grp_vis)
neonPink     = input.color(#ff2d78, "Sell/Gap Down Color", group=grp_vis)
neonGreen    = input.color(#39ff14, "Breakaway Color", group=grp_vis)
neonPurple   = input.color(#a855f7, "Continuation Color", group=grp_vis)
neonOrange   = input.color(#ffaa00, "Exhaustion Color", group=grp_vis)

// ─── GAP DETECTION ─────────────────────────────────────────────────────────────
gapUp   = open > close[1] and (open - close[1]) / close[1] * 100 >= minGapPct
gapDown = open < close[1] and (close[1] - open) / close[1] * 100 >= minGapPct
gapSize = math.abs(open - close[1])
gapPct  = close[1] != 0 ? gapSize / close[1] * 100 : 0.0

// ─── TREND CONTEXT ─────────────────────────────────────────────────────────────
trendEma = ta.ema(close, trendEmaLen)
volSma   = ta.sma(volume, volSmaLen)
volRatio = volSma != 0 ? volume / volSma : 0.0
confirmed = barstate.isconfirmed

// ─── GAP CLASSIFICATION ────────────────────────────────────────────────────────
// Breakaway: gap in trend direction + high volume + price far from EMA
// Continuation: gap in trend direction + moderate volume + trending
// Exhaustion: gap in trend direction + low volume + extended move
isUpTrend = close > trendEma
isDnTrend = close < trendEma

// UDT for gap tracking
type GapInfo
    float top
    float bot
    bool  isUp
    int   barIdx
    bool  filled
    int   gapType  // 0=breakaway, 1=continuation, 2=exhaustion
    box   gapBox
    label gapLbl

var array<GapInfo> gaps = array.new<GapInfo>()

// Classify gap
classifyGap(bool _gapUp, float _volRatio, bool _upTrend, bool _dnTrend, float _close, float _ema, float _atr) =>
    inTrendDir = (_gapUp and _upTrend) or (not _gapUp and _dnTrend)
    extended = math.abs(_close - _ema) > _atr * 2.0
    result = 1
    if inTrendDir and _volRatio > 1.5 and not extended
        result := 0
    else if inTrendDir and _volRatio < 0.8 and extended
        result := 2
    else
        result := 1
    result

atrVal = ta.atr(14)

// ─── GAP TRACKING ──────────────────────────────────────────────────────────────
if (gapUp or gapDown) and confirmed
    gTop = gapUp ? open : close[1]
    gBot = gapUp ? close[1] : open
    gType = classifyGap(gapUp, volRatio, isUpTrend, isDnTrend, close, trendEma, atrVal)
    gColor = gType == 0 ? neonGreen : gType == 1 ? neonPurple : neonOrange
    bxColor = gapUp ? color.new(gColor, 70) : color.new(gColor, 70)
    bx = box.new(bar_index - 1, gTop, bar_index + 50, gBot, border_color=color.new(gColor, 40), bgcolor=bxColor, border_width=1)
    typeStr = gType == 0 ? "BRK" : gType == 1 ? "CNT" : "EXH"
    dirStr  = gapUp ? "▲" : "▼"
    lbl = label.new(bar_index - 1, gapUp ? gTop : gBot, dirStr + " " + typeStr + " " + str.tostring(gapPct, "#.1") + "%", style=gapUp ? label.style_label_down : label.style_label_up, color=color.new(gColor, 30), textcolor=color.white, size=size.tiny)

    newGap = GapInfo.new(gTop, gBot, gapUp, bar_index, false, gType, bx, lbl)
    array.push(gaps, newGap)

    if array.size(gaps) > maxGaps
        oldest = array.shift(gaps)
        box.delete(oldest.gapBox)
        label.delete(oldest.gapLbl)

// ─── GAP FILL TRACKING ────────────────────────────────────────────────────────
var int fillCount = 0
var int totalGaps = 0
var bool gapFillEvent = false
var bool gapGoEvent   = false
gapFillEvent := false
gapGoEvent   := false

if array.size(gaps) > 0
    for i = array.size(gaps) - 1 to 0
        g = array.get(gaps, i)
        if not g.filled
            fillUp   = g.isUp and low <= g.bot
            fillDown = not g.isUp and high >= g.top
            if fillUp or fillDown
                g.filled := true
                fillCount += 1
                gapFillEvent := true
                if showFilledGaps
                    box.set_bgcolor(g.gapBox, color.new(color.gray, 90))
                    box.set_border_color(g.gapBox, color.new(color.gray, 80))
                else
                    box.delete(g.gapBox)
                    label.delete(g.gapLbl)
            else
                barsHeld = bar_index - g.barIdx
                if barsHeld > 5
                    trendingAway = g.isUp ? close > g.top : close < g.bot
                    if trendingAway and volRatio > 1.2
                        gapGoEvent := true
                box.set_right(g.gapBox, bar_index + 5)

if gapUp or gapDown
    totalGaps += 1

// ─── SIGNAL LOGIC ──────────────────────────────────────────────────────────────
var int lastSigBar = 0
cooldownOk  = bar_index - lastSigBar >= cooldownBars
volFilter   = volume > volSma

bullFillSig = confirmed and gapFillEvent and volFilter and cooldownOk and close > open
bearFillSig = confirmed and gapFillEvent and volFilter and cooldownOk and close < open
bullGoSig   = confirmed and gapGoEvent and gapUp and volFilter and cooldownOk
bearGoSig   = confirmed and gapGoEvent and gapDown and volFilter and cooldownOk

if bullFillSig or bearFillSig or bullGoSig or bearGoSig
    lastSigBar := bar_index

// ─── 3-LAYER GLOW ARROWS ──────────────────────────────────────────────────────
bullSig = bullFillSig or bullGoSig
bearSig = bearFillSig or bearGoSig

plotshape(bullSig, title="Buy Glow 1", style=shape.triangleup, location=location.belowbar, color=color.new(neonCyan, 70), size=size.huge)
plotshape(bullSig, title="Buy Glow 2", style=shape.triangleup, location=location.belowbar, color=color.new(neonCyan, 40), size=size.large)
plotshape(bullSig, title="Buy Signal", style=shape.triangleup, location=location.belowbar, color=color.new(neonCyan, 0), size=size.normal, text="BUY", textcolor=color.white)

plotshape(bearSig, title="Sell Glow 1", style=shape.triangledown, location=location.abovebar, color=color.new(neonPink, 70), size=size.huge)
plotshape(bearSig, title="Sell Glow 2", style=shape.triangledown, location=location.abovebar, color=color.new(neonPink, 40), size=size.large)
plotshape(bearSig, title="Sell Signal", style=shape.triangledown, location=location.abovebar, color=color.new(neonPink, 0), size=size.normal, text="SELL", textcolor=color.white)

// ─── BAR COLORING ──────────────────────────────────────────────────────────────
barcolor(bullSig ? neonCyan : bearSig ? neonPink : na)

// ─── SIGNAL LABELS ─────────────────────────────────────────────────────────────
if bullFillSig
    label.new(bar_index, low, "GAP FILL BUY\nVol: " + str.tostring(volRatio, "#.1") + "x", style=label.style_label_up, color=neonCyan, textcolor=color.white, size=size.small)

if bearFillSig
    label.new(bar_index, high, "GAP FILL SELL\nVol: " + str.tostring(volRatio, "#.1") + "x", style=label.style_label_down, color=neonPink, textcolor=color.white, size=size.small)

if bullGoSig
    label.new(bar_index, low, "GAP & GO ▲\nVol: " + str.tostring(volRatio, "#.1") + "x", style=label.style_label_up, color=neonGreen, textcolor=color.white, size=size.small)

if bearGoSig
    label.new(bar_index, high, "GAP & GO ▼\nVol: " + str.tostring(volRatio, "#.1") + "x", style=label.style_label_down, color=neonGreen, textcolor=color.white, size=size.small)

// ─── INFO TABLE ────────────────────────────────────────────────────────────────
if showTable and barstate.islast
    var table infoTbl = table.new(position.top_right, 2, 7, bgcolor=color.new(color.black, 20), border_width=1, border_color=color.new(color.gray, 60))
    table.cell(infoTbl, 0, 0, "Gap Hunter Pro", text_color=neonCyan, text_size=size.small, bgcolor=color.new(color.black, 10))
    table.merge_cells(infoTbl, 0, 0, 1, 0)
    table.cell(infoTbl, 0, 1, "Total Gaps", text_color=color.white, text_size=size.tiny)
    table.cell(infoTbl, 1, 1, str.tostring(totalGaps), text_color=neonPurple, text_size=size.tiny)
    table.cell(infoTbl, 0, 2, "Filled", text_color=color.white, text_size=size.tiny)
    table.cell(infoTbl, 1, 2, str.tostring(fillCount), text_color=neonOrange, text_size=size.tiny)
    unfilled = totalGaps - fillCount
    table.cell(infoTbl, 0, 3, "Open", text_color=color.white, text_size=size.tiny)
    table.cell(infoTbl, 1, 3, str.tostring(unfilled < 0 ? 0 : unfilled), text_color=neonGreen, text_size=size.tiny)
    fillRate = totalGaps > 0 ? fillCount / totalGaps * 100 : 0.0
    table.cell(infoTbl, 0, 4, "Fill Rate", text_color=color.white, text_size=size.tiny)
    table.cell(infoTbl, 1, 4, str.tostring(fillRate, "#.0") + "%", text_color=neonOrange, text_size=size.tiny)
    table.cell(infoTbl, 0, 5, "Vol Ratio", text_color=color.white, text_size=size.tiny)
    table.cell(infoTbl, 1, 5, str.tostring(volRatio, "#.00") + "x", text_color=volRatio > 1.0 ? neonGreen : color.gray, text_size=size.tiny)
    table.cell(infoTbl, 0, 6, "Trend", text_color=color.white, text_size=size.tiny)
    table.cell(infoTbl, 1, 6, isUpTrend ? "▲ Bullish" : "▼ Bearish", text_color=isUpTrend ? neonGreen : neonPink, text_size=size.tiny)

// ─── ALERTS ────────────────────────────────────────────────────────────────────
if bullSig
    sigType = bullFillSig ? "gap_fill" : "gap_and_go"
    alert('{"indicator":"GHP","signal":"BUY","ticker":"' + syminfo.tickerid + '","price":' + str.tostring(close) + ',"type":"' + sigType + '","timeframe":"' + timeframe.period + '"}', alert.freq_once_per_bar_close)

if bearSig
    sigType = bearFillSig ? "gap_fill" : "gap_and_go"
    alert('{"indicator":"GHP","signal":"SELL","ticker":"' + syminfo.tickerid + '","price":' + str.tostring(close) + ',"type":"' + sigType + '","timeframe":"' + timeframe.period + '"}', alert.freq_once_per_bar_close)

alertcondition(bullFillSig, title="Bullish Gap Fill", message="GHP Bullish gap fill on {{ticker}} {{interval}} at {{close}}")
alertcondition(bearFillSig, title="Bearish Gap Fill", message="GHP Bearish gap fill on {{ticker}} {{interval}} at {{close}}")
alertcondition(bullGoSig, title="Bullish Gap & Go", message="GHP Bullish gap-and-go on {{ticker}} {{interval}} at {{close}}")
alertcondition(bearGoSig, title="Bearish Gap & Go", message="GHP Bearish gap-and-go on {{ticker}} {{interval}} at {{close}}")
alertcondition(gapUp, title="Gap Up Detected", message="GHP Gap up detected on {{ticker}} {{interval}}")
alertcondition(gapDown, title="Gap Down Detected", message="GHP Gap down detected on {{ticker}} {{interval}}")
alertcondition(gapFillEvent, title="Any Gap Filled", message="GHP Gap filled on {{ticker}} {{interval}}")
alertcondition(bullSig or bearSig, title="Any Signal", message="GHP Gap signal on {{ticker}} {{interval}} at {{close}}")
alertcondition(gapPct > 1.0, title="Large Gap", message="GHP Large gap (>1%) on {{ticker}} {{interval}}")
````
