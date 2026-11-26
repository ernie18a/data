# Volumetric Sweep Gravity Engine [PhenLabs]

- url: https://www.tradingview.com/script/3WLWGS0F-Volumetric-Sweep-Gravity-Engine-PhenLabs/
- type: indicator
- pine_id: PUB;e12fef6384a54f178ad88033208ce61c
- version: 1.0

## Description

📊 Volumetric Sweep Gravity Engine [PhenLabs]

Version: PineScript™ v6

📌 Description
The Volumetric Sweep Gravity Engine detects true liquidity stop-hunts and only keeps the ones backed by real volume absorption. Instead of marking every wick beyond a swing, VSGE scores each sweep with volume expansion, wick geometry, and a candle delta proxy — then projects a Fibonacci golden-zone magnet where price is most likely to get pulled next.

Traders get a clean, high-contrast chart: absorption boxes that intensify with score strength, gold-tinted gravity zones, dotted magnet lines, dual glow signal markers, and a live PhenLabs command dashboard. Built for fast visual reads on crypto, indices, FX, and metals without clutter.

🚀 Points of Innovation
[list]
[*]Triple-factor absorption score (volume × wick ratio × delta proxy) filters weak fake sweeps
[*]Liquidity pool tracking from confirmed swing highs/lows with ATR-buffered sweep rules
[*]Automatic Fibonacci golden-zone gravity targets (0.618–0.786) after valid sweeps
[*]Score-reactive zone transparency — stronger absorption draws hotter, more opaque boxes
[*]Dotted magnet projection lines from signal price into the golden-zone midpoint
[*]Live VSGE dashboard with bias, last event, ABS score, GZ magnet, BSL/SSL pools, and vol pulse
[/list]

🔧 Core Components
[list]
[*]Liquidity Pool Engine: Confirms swing highs (BSL) and swing lows (SSL), then watches for wick violations with optional close-back-inside stop-hunt logic
[*]Absorption Scorer: Composites volume-vs-SMA, wick-to-body geometry, and signed volume delta into a 0–100 score with configurable weights
[*]Gravity Projector: Measures the impulse leg and maps the 61.8–78.6 golden zone as the expected rebalance magnet
[*]Visual Command Layer: Absorption boxes, golden zones, magnet lines, glow markers, pool rails, and a gold-framed dashboard
[/list]

🔥 Key Features
[list]
[*]Bullish and bearish volumetric sweep signals with min score gate
[*]Optional EMA trend filter and ATR volatility floor to skip dead markets
[*]Toggleable pool lines, absorption boxes, labels, bar coloring, and magnet lines
[*]Max active zone cap to keep charts clean on lower timeframes
[*]Alert conditions for bull sweeps, bear sweeps, and any sweep
[*]Fully open-source Pine v6 with organized input groups and tooltips
[/list]

🎨 Visualization
[list]
[*]Neon triangle + soft glow circle markers tagged “VSGE” for screenshot-ready signals
[*]Absorption boxes labeled with live ABS % and opacity scaled to conviction
[*]Dashed golden-zone rectangles with centered GOLDEN ZONE text
[*]Dotted gold magnet lines pulling toward the zone midpoint
[*]BSL/SSL pool rails in bear/bull tints for structural context
[*]Top-right dark dashboard with gold border, bias coloring, and vol pulse readout
[/list]

📖 Usage Guidelines
[list]
[*][b]Swing Lookback[/b] — Default: 5 — Range: 2-30 — Higher = fewer, more structural pools
[*][b]Sweep Buffer (ATR mult)[/b] — Default: 0.05 — Range: 0-1 — Extra wick extension required beyond the pool
[*][b]Require Close Back Inside[/b] — Default: true — Enforces classic stop-hunt reclaim closes
[*][b]Min Sweep Wick (ATR)[/b] — Default: 0.15 — Range: 0.05-2 — Rejects tiny liquidity nicks
[*][b]Volume SMA Length[/b] — Default: 20 — Range: 5-100 — Baseline for absorption volume
[*][b]Absorption Volume Mult[/b] — Default: 1.4 — Range: 1-5 — Minimum volume expansion vs SMA
[*][b]Min Wick/Body Ratio[/b] — Default: 1.5 — Range: 0.5-10 — Ensures rejection-style geometry
[*][b]Min Absorption Score[/b] — Default: 55 — Range: 0-100 — Composite gate for signals
[*][b]Golden Zone Low/High (Fib)[/b] — Default: 0.618 / 0.786 — Retracement band for gravity targets
[*][b]Impulse Lookback Bars[/b] — Default: 8 — Range: 3-40 — Bars used to size the impulse leg
[*][b]Max Active Zones[/b] — Default: 6 — Range: 1-20 — Limits drawn boxes/lines/labels
[*][b]EMA Trend Filter[/b] — Default: off — Optional 200 EMA directional gate
[*][b]Min ATR Volatility Filter[/b] — Default: on — Skips low-volatility chop vs ATR SMA
[/list]

✅ Best Use Cases
[list]
[*]Intraday liquidity-grab reversals on crypto, Nasdaq, Gold, and major FX pairs
[*]Confirming stop-hunts before entering toward the golden-zone magnet
[*]Filtering pure wick noise by requiring volumetric absorption
[*]Screenshot-friendly SMC setups for education, social posts, and journal reviews
[/list]

⚠️ Limitations
[list]
[*]Delta is a candle-geometry proxy, not true bid/ask order-flow data
[*]Pivot pools confirm with lag equal to the swing lookback
[*]Golden zones are probabilistic magnets, not guaranteed fill targets
[*]Dense lower-timeframe charts may need higher min score or lower max zones
[/list]

💡 What Makes This Unique
[list]
[*]Fuses liquidity sweeps + volumetric absorption scoring + Fibonacci gravity in one engine — a combination missing from pure sweep or pure Fib tools
[*]Score-reactive visuals make conviction readable at a glance for SEO screenshots and live trading
[*]PhenLabs-style command dashboard turns structure, score, and magnet price into a single decision panel
[/list]

🔬 How It Works
[list=1]
[*]Map liquidity pools from confirmed swing highs (BSL) and swing lows (SSL)
[*]Detect sweeps when price wicks beyond a pool by ATR buffer and optionally closes back inside
[*]Score absorption using volume expansion, wick/body geometry, and signed delta proxy
[*]If score clears the minimum gate, draw the absorption box and project the 0.618–0.786 golden gravity zone with a magnet line
[*]Update the live dashboard (bias, last event, ABS score, GZ magnet, pools, vol pulse) and fire alerts
[/list]

[quote]💡 [b]Note:
[/b]Use VSGE as a confluence layer with your own risk rules, higher-timeframe bias, and position sizing. This is an analytical aid for studying liquidity and absorption behavior — not financial advice.[/quote]

## Source Code

````pine
//@version=6
indicator("Volumetric Sweep Gravity Engine [PhenLabs]", shorttitle="VSGE [PL]", overlay=true, max_boxes_count=100, max_lines_count=100, max_labels_count=100, max_bars_back=500)

// ═══════════════════════════════════════════════════════════════════════════
// Volumetric Sweep Gravity Engine [PhenLabs]
// Detects liquidity sweeps, scores volume absorption, projects golden-zone
// gravity targets with a live on-chart command dashboard.
// ═══════════════════════════════════════════════════════════════════════════

// ─── Inputs ────────────────────────────────────────────────────────────────
grpCore   = "Core Detection"
grpAbs    = "Absorption Scoring"
grpGZ     = "Golden Zone Gravity"
grpVis    = "Visuals & Style"
grpDash   = "Dashboard"
grpFilt   = "Filters"

swingLen      = input.int(5, "Swing Lookback", minval=2, maxval=30, group=grpCore, tooltip="Bars on each side to confirm a swing high/low liquidity pool.")
sweepBuffer   = input.float(0.05, "Sweep Buffer (ATR mult)", minval=0.0, maxval=1.0, step=0.01, group=grpCore, tooltip="Minimum wick extension beyond the pool, as ATR multiple.")
requireClose  = input.bool(true, "Require Close Back Inside", group=grpCore, tooltip="Sweep candle must close back inside the broken level (true stop-hunt).")
minSweepAtr   = input.float(0.15, "Min Sweep Wick (ATR)", minval=0.05, maxval=2.0, step=0.05, group=grpCore)

volLen        = input.int(20, "Volume SMA Length", minval=5, maxval=100, group=grpAbs)
volMult       = input.float(1.4, "Absorption Volume Mult", minval=1.0, maxval=5.0, step=0.1, group=grpAbs, tooltip="Sweep bar volume must exceed SMA × this multiplier.")
wickBodyRatio = input.float(1.5, "Min Wick/Body Ratio", minval=0.5, maxval=10.0, step=0.1, group=grpAbs)
absWeightVol  = input.float(0.45, "Score Weight: Volume", minval=0.0, maxval=1.0, step=0.05, group=grpAbs)
absWeightWick = input.float(0.30, "Score Weight: Wick", minval=0.0, maxval=1.0, step=0.05, group=grpAbs)
absWeightDelta= input.float(0.25, "Score Weight: Delta", minval=0.0, maxval=1.0, step=0.05, group=grpAbs)
minScore      = input.int(55, "Min Absorption Score", minval=0, maxval=100, group=grpAbs, tooltip="Minimum composite score (0-100) to fire a signal.")

gzEnable      = input.bool(true, "Show Golden Zone Targets", group=grpGZ)
gzLow         = input.float(0.618, "Golden Zone Low (Fib)", minval=0.3, maxval=0.9, step=0.001, group=grpGZ)
gzHigh        = input.float(0.786, "Golden Zone High (Fib)", minval=0.4, maxval=0.95, step=0.001, group=grpGZ)
impulseLen    = input.int(8, "Impulse Lookback Bars", minval=3, maxval=40, group=grpGZ, tooltip="Bars used to measure the impulse leg for Fib projection.")
showMagnet    = input.bool(true, "Show Magnet Projection Lines", group=grpGZ)
maxZones      = input.int(6, "Max Active Zones", minval=1, maxval=20, group=grpGZ)

colBull       = input.color(color.new(#00E676, 0), "Bullish Color", group=grpVis)
colBear       = input.color(color.new(#FF1744, 0), "Bearish Color", group=grpVis)
colGold       = input.color(color.new(#FFD54F, 15), "Golden Zone Color", group=grpVis)
colAbsBull    = input.color(color.new(#00BFA5, 70), "Absorption Zone Bull", group=grpVis)
colAbsBear    = input.color(color.new(#FF5252, 70), "Absorption Zone Bear", group=grpVis)
colMagnet     = input.color(color.new(#FFD54F, 40), "Magnet Line Color", group=grpVis)
showLabels    = input.bool(true, "Show Sweep Labels", group=grpVis)
showZones     = input.bool(true, "Show Absorption Boxes", group=grpVis)
barColorOn    = input.bool(true, "Color Bars on Signal", group=grpVis)
showPools     = input.bool(true, "Show Liquidity Pool Lines", group=grpVis)

showDash      = input.bool(true, "Show Dashboard", group=grpDash)
dashPos       = input.string("Top Right", "Dashboard Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=grpDash)
dashSize      = input.string("Normal", "Dashboard Size", options=["Small", "Normal", "Large"], group=grpDash)

useEmaFilter  = input.bool(false, "EMA Trend Filter", group=grpFilt)
emaLen        = input.int(200, "EMA Length", minval=20, maxval=500, group=grpFilt)
useAtrFilter  = input.bool(true, "Min ATR Volatility Filter", group=grpFilt)
atrLen        = input.int(14, "ATR Length", minval=5, maxval=50, group=grpFilt)
atrFloorMult  = input.float(0.3, "ATR Floor vs SMA ATR", minval=0.05, maxval=2.0, step=0.05, group=grpFilt)

// ─── Helpers ───────────────────────────────────────────────────────────────
atrVal   = ta.atr(atrLen)
atrSma   = ta.sma(atrVal, 50)
volSma   = ta.sma(volume, volLen)
emaVal   = ta.ema(close, emaLen)

// Approximate delta from candle geometry (no true bid/ask on TV)
bodySize = math.abs(close - open)
rangeSize = high - low
upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low
// Signed volume proxy: bullish body share vs bearish
deltaProxy = rangeSize > 0 ? volume * ((close - open) / rangeSize) : 0.0
deltaSma   = ta.sma(deltaProxy, volLen)

f_clamp(v, lo, hi) =>
    math.max(lo, math.min(hi, v))

f_score_component(ratio, softCap) =>
    // Map ratio into 0-100 with soft saturation
    f_clamp(100.0 * (ratio / softCap), 0.0, 100.0)

// ─── Liquidity pools (confirmed swings) ────────────────────────────────────
ph = ta.pivothigh(high, swingLen, swingLen)
pl = ta.pivotlow(low, swingLen, swingLen)

var float buyLiq  = na   // sell-side pool above (BSL) — stops of shorts / breakout buys
var float sellLiq = na   // buy-side pool below (SSL)
var int   buyLiqBar  = na
var int   sellLiqBar = na

if not na(ph)
    buyLiq := ph
    buyLiqBar := bar_index - swingLen
if not na(pl)
    sellLiq := pl
    sellLiqBar := bar_index - swingLen

// ─── Filters ───────────────────────────────────────────────────────────────
volOk = not useAtrFilter or na(atrSma) or atrSma == 0 ? true : atrVal >= atrSma * atrFloorMult
bullTrendOk = not useEmaFilter or close > emaVal
bearTrendOk = not useEmaFilter or close < emaVal

// ─── Sweep detection ───────────────────────────────────────────────────────
// Bullish sweep: wick below sellLiq (SSL), close back above
// Bearish sweep: wick above buyLiq (BSL), close back below
float buf = atrVal * sweepBuffer

bullSweepRaw = not na(sellLiq) and not na(atrVal) and atrVal > 0 and volOk and bullTrendOk and
     low < sellLiq - buf and
     lowerWick >= atrVal * minSweepAtr and
     (not requireClose or close > sellLiq) and
     low < low[1]

bearSweepRaw = not na(buyLiq) and not na(atrVal) and atrVal > 0 and volOk and bearTrendOk and
     high > buyLiq + buf and
     upperWick >= atrVal * minSweepAtr and
     (not requireClose or close < buyLiq) and
     high > high[1]

// ─── Absorption scoring (0-100) ────────────────────────────────────────────
volRatio  = volSma > 0 ? volume / volSma : 0.0
wickRatioBull = bodySize > 0 ? lowerWick / bodySize : (lowerWick > 0 ? 5.0 : 0.0)
wickRatioBear = bodySize > 0 ? upperWick / bodySize : (upperWick > 0 ? 5.0 : 0.0)

// Delta confirmation: bullish absorption wants positive delta rebound on sweep bar
// (close reclaiming = buying into the wick)
deltaRatio = math.abs(deltaSma) > 0 ? deltaProxy / math.abs(deltaSma) : 0.0

scoreBull = 0.0
scoreBear = 0.0
wSumBase = absWeightVol + absWeightWick + absWeightDelta
wSumSafe = wSumBase == 0.0 ? 1.0 : wSumBase

if bullSweepRaw
    sVol  = f_score_component(volRatio, volMult * 1.8)
    sWick = f_score_component(wickRatioBull, wickBodyRatio * 2.0)
    sDel  = f_score_component(math.max(deltaRatio, 0.0), 2.0)
    scoreBull := (absWeightVol * sVol + absWeightWick * sWick + absWeightDelta * sDel) / wSumSafe

if bearSweepRaw
    sVol  = f_score_component(volRatio, volMult * 1.8)
    sWick = f_score_component(wickRatioBear, wickBodyRatio * 2.0)
    sDel  = f_score_component(math.max(-deltaRatio, 0.0), 2.0)
    scoreBear := (absWeightVol * sVol + absWeightWick * sWick + absWeightDelta * sDel) / wSumSafe

volPassBull = volRatio >= volMult and wickRatioBull >= wickBodyRatio
volPassBear = volRatio >= volMult and wickRatioBear >= wickBodyRatio

bullSignal = bullSweepRaw and volPassBull and scoreBull >= minScore
bearSignal = bearSweepRaw and volPassBear and scoreBear >= minScore

// ─── Impulse extremes for golden zone ──────────────────────────────────────
// For bullish sweep: impulse low = sweep low, impulse high = highest high over lookback before reclaim
impHigh = ta.highest(high, impulseLen)
impLow  = ta.lowest(low, impulseLen)

// ─── Drawing state ─────────────────────────────────────────────────────────
var box[]   absBoxes   = array.new_box()
var box[]   gzBoxes    = array.new_box()
var line[]  magLines   = array.new_line()
var label[] sigLabels  = array.new_label()
var float[] zoneTops   = array.new_float()
var float[] zoneBots   = array.new_float()
var int[]   zoneDirs   = array.new_int()   // 1 bull, -1 bear
var float[] zoneScores = array.new_float()
var string  lastEvent  = "—"
var float   lastScore  = na
var int     lastDir    = 0
var int     bullCount  = 0
var int     bearCount  = 0
var float   activeGzHi = na
var float   activeGzLo = na
var int     activeDir  = 0

f_trim_array_box(arr, maxN) =>
    excess = array.size(arr) - maxN
    if excess > 0
        for i = 0 to excess - 1
            box.delete(array.shift(arr))

f_trim_array_line(arr, maxN) =>
    excess = array.size(arr) - maxN
    if excess > 0
        for i = 0 to excess - 1
            line.delete(array.shift(arr))

f_trim_array_label(arr, maxN) =>
    excess = array.size(arr) - maxN
    if excess > 0
        for i = 0 to excess - 1
            label.delete(array.shift(arr))

f_trim_float(arr, maxN) =>
    excess = array.size(arr) - maxN
    if excess > 0
        for i = 0 to excess - 1
            array.shift(arr)

f_trim_int(arr, maxN) =>
    excess = array.size(arr) - maxN
    if excess > 0
        for i = 0 to excess - 1
            array.shift(arr)

// ─── On signal: draw absorption + golden gravity zone ──────────────────────
if bullSignal
    bullCount += 1
    lastEvent := "BULL SWEEP"
    lastScore := scoreBull
    lastDir   := 1
    activeDir := 1

    // Absorption zone: from sellLiq down to sweep low
    float zTop = sellLiq
    float zBot = low
    if showZones and not na(zTop) and not na(zBot)
        // Stronger score → less transparent fill
        int tr = int(f_clamp(85 - scoreBull * 0.45, 40, 85))
        b = box.new(bar_index - 1, zTop, bar_index + 8, zBot, border_color=color.new(colBull, 20), bgcolor=color.new(colAbsBull, tr), border_width=2, text="ABS " + str.tostring(scoreBull, "#") + "%", text_color=color.new(colBull, 0), text_size=size.small, text_halign=text.align_right)
        array.push(absBoxes, b)
        f_trim_array_box(absBoxes, maxZones)

    // Golden zone: after bullish sweep, project pullback buy zone from impulse low→high
    float legHi = impHigh
    float legLo = low
    float impRange = legHi - legLo
    if gzEnable and impRange > 0
        // Standard fib: high - impRange * [0.618..0.786]
        float gHi = legHi - impRange * gzLow
        float gLo = legHi - impRange * gzHigh
        if gHi < gLo
            float swapHi = gLo
            gLo := gHi
            gHi := swapHi
        activeGzHi := gHi
        activeGzLo := gLo
        gz = box.new(bar_index, gHi, bar_index + 18, gLo, border_color=color.new(colGold, 10), bgcolor=color.new(colGold, 78), border_width=1, border_style=line.style_dashed, text="GOLDEN ZONE", text_color=color.new(colGold, 0), text_size=size.tiny, text_halign=text.align_center, text_valign=text.align_center)
        array.push(gzBoxes, gz)
        f_trim_array_box(gzBoxes, maxZones)

        if showMagnet
            mid = (gHi + gLo) * 0.5
            ml = line.new(bar_index, close, bar_index + 18, mid, color=colMagnet, style=line.style_dotted, width=2)
            array.push(magLines, ml)
            f_trim_array_line(magLines, maxZones)

    if showLabels
        lbl = label.new(bar_index, low, "▲ SWEEP\n" + str.tostring(scoreBull, "#.0") + " ABS", style=label.style_label_up, color=color.new(colBull, 10), textcolor=color.white, yloc=yloc.belowbar, size=size.small)
        array.push(sigLabels, lbl)
        f_trim_array_label(sigLabels, maxZones * 2)

    array.push(zoneTops, zTop)
    array.push(zoneBots, zBot)
    array.push(zoneDirs, 1)
    array.push(zoneScores, scoreBull)
    f_trim_float(zoneTops, maxZones)
    f_trim_float(zoneBots, maxZones)
    f_trim_int(zoneDirs, maxZones)
    f_trim_float(zoneScores, maxZones)

if bearSignal
    bearCount += 1
    lastEvent := "BEAR SWEEP"
    lastScore := scoreBear
    lastDir   := -1
    activeDir := -1

    float zTopB = high
    float zBotB = buyLiq
    if showZones and not na(zTopB) and not na(zBotB)
        int tr = int(f_clamp(85 - scoreBear * 0.45, 40, 85))
        b = box.new(bar_index - 1, zTopB, bar_index + 8, zBotB, border_color=color.new(colBear, 20), bgcolor=color.new(colAbsBear, tr), border_width=2, text="ABS " + str.tostring(scoreBear, "#") + "%", text_color=color.new(colBear, 0), text_size=size.small, text_halign=text.align_right)
        array.push(absBoxes, b)
        f_trim_array_box(absBoxes, maxZones)

    float legHiB = high
    float legLoB = impLow
    float rangeB = legHiB - legLoB
    if gzEnable and rangeB > 0
        // After bearish sweep: short pullback zone = low + impRange * [0.618..0.786]
        float gLoB = legLoB + rangeB * gzLow
        float gHiB = legLoB + rangeB * gzHigh
        if gHiB < gLoB
            float swapHiB = gLoB
            gLoB := gHiB
            gHiB := swapHiB
        activeGzHi := gHiB
        activeGzLo := gLoB
        gz = box.new(bar_index, gHiB, bar_index + 18, gLoB, border_color=color.new(colGold, 10), bgcolor=color.new(colGold, 78), border_width=1, border_style=line.style_dashed, text="GOLDEN ZONE", text_color=color.new(colGold, 0), text_size=size.tiny, text_halign=text.align_center, text_valign=text.align_center)
        array.push(gzBoxes, gz)
        f_trim_array_box(gzBoxes, maxZones)

        if showMagnet
            midB = (gHiB + gLoB) * 0.5
            ml = line.new(bar_index, close, bar_index + 18, midB, color=colMagnet, style=line.style_dotted, width=2)
            array.push(magLines, ml)
            f_trim_array_line(magLines, maxZones)

    if showLabels
        lbl = label.new(bar_index, high, "▼ SWEEP\n" + str.tostring(scoreBear, "#.0") + " ABS", style=label.style_label_down, color=color.new(colBear, 10), textcolor=color.white, yloc=yloc.abovebar, size=size.small)
        array.push(sigLabels, lbl)
        f_trim_array_label(sigLabels, maxZones * 2)

    array.push(zoneTops, zTopB)
    array.push(zoneBots, zBotB)
    array.push(zoneDirs, -1)
    array.push(zoneScores, scoreBear)
    f_trim_float(zoneTops, maxZones)
    f_trim_float(zoneBots, maxZones)
    f_trim_int(zoneDirs, maxZones)
    f_trim_float(zoneScores, maxZones)

// ─── Liquidity pool level plots ────────────────────────────────────────────
plot(showPools ? buyLiq : na,  "Buy-Side Liquidity (BSL)", color=color.new(colBear, 55), style=plot.style_linebr, linewidth=2)
plot(showPools ? sellLiq : na, "Sell-Side Liquidity (SSL)", color=color.new(colBull, 55), style=plot.style_linebr, linewidth=2)

// ─── Signal markers ────────────────────────────────────────────────────────
plotshape(bullSignal, title="Bull Sweep", style=shape.triangleup, location=location.belowbar, color=colBull, size=size.normal, text="VSGE", textcolor=colBull)
plotshape(bearSignal, title="Bear Sweep", style=shape.triangledown, location=location.abovebar, color=colBear, size=size.normal, text="VSGE", textcolor=colBear)

// Glow rings (extra visual punch for screenshots / SEO)
plotshape(bullSignal, title="Bull Glow", style=shape.circle, location=location.belowbar, color=color.new(colBull, 70), size=size.large, offset=0)
plotshape(bearSignal, title="Bear Glow", style=shape.circle, location=location.abovebar, color=color.new(colBear, 70), size=size.large, offset=0)

// ─── Bar coloring ──────────────────────────────────────────────────────────
signalBarColor = bullSignal ? color.new(colBull, 40) : bearSignal ? color.new(colBear, 40) : na
barcolor(barColorOn ? signalBarColor : na)

// ─── EMA optional ──────────────────────────────────────────────────────────
plot(useEmaFilter ? emaVal : na, "EMA Filter", color=color.new(#90CAF9, 50), linewidth=1)

// ─── Dashboard ─────────────────────────────────────────────────────────────
var table dash = na
posMap = dashPos == "Top Right" ? position.top_right : dashPos == "Top Left" ? position.top_left : dashPos == "Bottom Right" ? position.bottom_right : position.bottom_left
szMap  = dashSize == "Small" ? size.small : dashSize == "Large" ? size.large : size.normal

if showDash and barstate.islast
    if not na(dash)
        table.delete(dash)
    dash := table.new(posMap, 2, 9, bgcolor=color.new(#0D1117, 8), border_color=color.new(#FFD54F, 40), border_width=2, frame_color=color.new(#FFD54F, 20), frame_width=1)

    // Header
    table.cell(dash, 0, 0, "⚡ VSGE", text_color=color.new(#FFD54F, 0), text_size=szMap, bgcolor=color.new(#1A237E, 20), text_halign=text.align_center)
    table.cell(dash, 1, 0, "PhenLabs", text_color=color.new(#FFD54F, 0), text_size=szMap, bgcolor=color.new(#1A237E, 20), text_halign=text.align_center)

    // Bias
    biasTxt = activeDir == 1 ? "BULLISH" : activeDir == -1 ? "BEARISH" : "NEUTRAL"
    biasCol = activeDir == 1 ? colBull : activeDir == -1 ? colBear : color.gray
    table.cell(dash, 0, 1, "Bias", text_color=color.new(#B0BEC5, 0), text_size=szMap, bgcolor=color.new(#161B22, 0))
    table.cell(dash, 1, 1, biasTxt, text_color=biasCol, text_size=szMap, bgcolor=color.new(#161B22, 0), text_halign=text.align_right)

    // Last event
    table.cell(dash, 0, 2, "Last Event", text_color=color.new(#B0BEC5, 0), text_size=szMap, bgcolor=color.new(#0D1117, 0))
    table.cell(dash, 1, 2, lastEvent, text_color=lastDir == 1 ? colBull : lastDir == -1 ? colBear : color.gray, text_size=szMap, bgcolor=color.new(#0D1117, 0), text_halign=text.align_right)

    // Score
    scoreTxt = na(lastScore) ? "—" : str.tostring(lastScore, "#.0") + "%"
    scoreCol = na(lastScore) ? color.gray : lastScore >= 75 ? colBull : lastScore >= minScore ? colGold : colBear
    table.cell(dash, 0, 3, "ABS Score", text_color=color.new(#B0BEC5, 0), text_size=szMap, bgcolor=color.new(#161B22, 0))
    table.cell(dash, 1, 3, scoreTxt, text_color=scoreCol, text_size=szMap, bgcolor=color.new(#161B22, 0), text_halign=text.align_right)

    // Active golden zone mid
    gzMidTxt = na(activeGzHi) or na(activeGzLo) ? "—" : str.tostring((activeGzHi + activeGzLo) * 0.5, format.mintick)
    table.cell(dash, 0, 4, "GZ Magnet", text_color=color.new(#B0BEC5, 0), text_size=szMap, bgcolor=color.new(#0D1117, 0))
    table.cell(dash, 1, 4, gzMidTxt, text_color=colGold, text_size=szMap, bgcolor=color.new(#0D1117, 0), text_halign=text.align_right)

    // Liquidity levels
    bslTxt = na(buyLiq) ? "—" : str.tostring(buyLiq, format.mintick)
    sslTxt = na(sellLiq) ? "—" : str.tostring(sellLiq, format.mintick)
    table.cell(dash, 0, 5, "BSL Pool", text_color=color.new(#B0BEC5, 0), text_size=szMap, bgcolor=color.new(#161B22, 0))
    table.cell(dash, 1, 5, bslTxt, text_color=colBear, text_size=szMap, bgcolor=color.new(#161B22, 0), text_halign=text.align_right)
    table.cell(dash, 0, 6, "SSL Pool", text_color=color.new(#B0BEC5, 0), text_size=szMap, bgcolor=color.new(#0D1117, 0))
    table.cell(dash, 1, 6, sslTxt, text_color=colBull, text_size=szMap, bgcolor=color.new(#0D1117, 0), text_halign=text.align_right)

    // Counts
    table.cell(dash, 0, 7, "Bull / Bear", text_color=color.new(#B0BEC5, 0), text_size=szMap, bgcolor=color.new(#161B22, 0))
    table.cell(dash, 1, 7, str.tostring(bullCount) + " / " + str.tostring(bearCount), text_color=color.white, text_size=szMap, bgcolor=color.new(#161B22, 0), text_halign=text.align_right)

    // Vol pulse
    volPulse = volSma > 0 ? volRatio : 0.0
    pulseTxt = str.tostring(volPulse, "#.00") + "×"
    pulseCol = volPulse >= volMult ? colBull : color.gray
    table.cell(dash, 0, 8, "Vol Pulse", text_color=color.new(#B0BEC5, 0), text_size=szMap, bgcolor=color.new(#0D1117, 0))
    table.cell(dash, 1, 8, pulseTxt, text_color=pulseCol, text_size=szMap, bgcolor=color.new(#0D1117, 0), text_halign=text.align_right)

// ─── Alerts ────────────────────────────────────────────────────────────────
alertcondition(bullSignal, title="VSGE Bullish Sweep", message="Volumetric Sweep Gravity Engine: BULLISH absorption sweep confirmed")
alertcondition(bearSignal, title="VSGE Bearish Sweep", message="Volumetric Sweep Gravity Engine: BEARISH absorption sweep confirmed")
alertcondition(bullSignal or bearSignal, title="VSGE Any Sweep", message="Volumetric Sweep Gravity Engine: Absorption sweep signal")
````
