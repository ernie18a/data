# RSI Liquidity Sweep Confluence Engine [PhenLabs]

- url: https://www.tradingview.com/script/dLoQDirY-RSI-Liquidity-Sweep-Confluence-Engine-PhenLabs/
- type: indicator
- pine_id: PUB;c521e711901643e5901a41949226f541
- version: 1.0

## Description

📊 RSI Liquidity Sweep Confluence Engine [PhenLabs]

Version: PineScript™ v6

📌 Description
The RSI Liquidity Sweep Confluence Engine rebuilds the RSI as dynamic, price-projected support and resistance levels — then waits for liquidity to be swept exactly at those levels before firing a signal. It solves the two biggest problems retail traders face with RSI and liquidity tools: RSI divergence readings that never map to price, and liquidity sweep alerts that fire on every wick with no filter.

By requiring full confluence — an RSI-derived level, a genuine liquidity sweep, and volume confirmation all aligning on the same bar — the engine suppresses noise and only marks the reversals where smart-money delivery actually shifts. Signals do not repaint on closed bars.

This is a fusion indicator. It takes the week’s most popular concept (RSI rebuilt as S/R), PhenLabs’ core specialty (liquidity sweep mapping), and the highest-traction publishing format (confluence-scored, fire-only-on-full-alignment engines) and combines them into one clean, dashboard-backed tool.

🚀 Points of Innovation
[list]
[*]RSI pivots mapped directly onto price as live support/resistance levels, not oscillator readings
[*]Liquidity sweep detection gated to fire only when the sweep occurs at an RSI-derived level
[*]Triple-confluence gate: RSI S/R + liquidity sweep + volume confirmation must all align
[*]Adaptive ATR-based tolerance so the confluence zone scales with current volatility
[*]WMA-smoothed S/R lines with a single soft channel fill for a clean, uncluttered chart
[*]No repaint on closed bars — signals confirm on bar close
[/list]

🔧 Core Components
[list]
[*][b]RSI Core Levels[/b]: Confirmed RSI pivots (left/right bars configurable) are recorded with their corresponding price high/low, building a rolling set of dynamic S/R zones projected onto the chart as smoothed lines
[*][b]Liquidity Sweep Detector[/b]: Tracks swing high/low liquidity pools over a lookback window and flags genuine sweeps (wick beyond pool, optional close-back inside for reversal confirmation)
[*][b]Confluence Gate[/b]: Measures the distance between the swept price and the nearest RSI S/R level using ATR-scaled tolerance, then confirms with a volume-vs-SMA check
[/list]

🔥 Key Features
[list]
[*][b]Triple Confluence Gating[/b]: Signals fire only when RSI level, liquidity sweep, and volume all agree — drastically reducing false reversals
[*][b]RSI-as-Price S/R[/b]: Converts oscillator extremes into actionable price levels you can trade against directly
[*][b]ATR-Adaptive Tolerance[/b]: Confluence zone widens in high volatility, tightens in ranges — works across timeframes and instruments without re-tuning
[*][b]Close-Back Reversal Filter[/b]: Optional requirement that price closes back inside the swept pool, filtering stop-runs that continue
[*][b]Clean Visual Layer[/b]: Two smoothed S/R lines, one soft channel fill, subtle state-tinted background and color-coded bars — premium look without chart clutter
[*][b]Live State Dashboard[/b]: Compact on-chart table shows RSI, nearest S/R levels, volume confirm, ATR, and current state at a glance
[*][b]Dual-Direction Alerts[/b]: Separate bullish and bearish alertconditions for automated notification
[/list]

🎨 Visualization
[list]
[*][b]Smoothed S/R lines[/b]: A red resistance line above price and a green support line below, WMA-smoothed so transitions ease instead of snapping
[*][b]Soft channel fill[/b]: A single subtle purple band between support and resistance defining the active RSI value zone
[*][b]State background tint[/b]: Chart background subtly greens on bullish confluence, reds on bearish confluence, gold-tints when a sweep is armed
[*][b]Color-coded bars[/b]: Candle bodies shift green / red / gold based on the live confluence state
[*][b]Sweep marker + label[/b]: A single dashed box marks the exact swept liquidity pool, with a compact BULL / BEAR label at the signal bar
[*][b]Top-right dashboard[/b]: Compact state table with RSI, resistance, support, volume confirm, ATR, and Scanning / Armed / Confluence state
[/list]

📖 Usage Guidelines
[list]
[*][b]RSI Length[/b] — Default: 14 — Range: 2-50 — Controls RSI period used to derive S/R levels; lower = more reactive levels, higher = more structural
[*][b]RSI Pivot Left / Right[/b] — Default: 5 / 5 — Range: 1-20 — Bars used to confirm RSI pivots; higher = fewer but more reliable levels
[*][b]Active RSI Levels Kept[/b] — Default: 4 — Range: 1-10 — Number of most-recent RSI S/R levels kept active on chart
[*][b]Level Smoothing (WMA)[/b] — Default: 3 — Range: 1-10 — WMA length applied to S/R lines for smoother transitions
[*][b]Sweep Lookback[/b] — Default: 20 — Range: 5-100 — Bars defining the swing high/low liquidity pools
[*][b]Require Close-Back[/b] — Default: true — Toggles whether price must close back inside the swept pool to validate a sweep
[*][b]RSI Level Tolerance (ATR x)[/b] — Default: 0.30 — Range: 0.0-2.0 — Distance (in ATR multiples) within which a sweep counts as touching an RSI level; 0.0 disables RSI confluence
[*][b]Volume Multiplier[/b] — Default: 1.20 — Range: 0.0-5.0 — Volume must exceed this multiple of its SMA to confirm; 0.0 disables volume confluence
[*][b]ATR Length[/b] — Default: 14 — Range: 1-100 — ATR period used to scale the confluence tolerance
[/list]

✅ Best Use Cases
[list]
[*]Intraday and swing reversal trading on indices, FX majors, and high-liquidity crypto
[*]Smart-money / ICT traders who want a filtered sweep signal instead of raw sweep noise
[*]Traders who already use RSI but want it mapped to price as tradable S/R
[*]Multi-timeframe confluence stacking — run on higher TF for bias, lower TF for entries
[/list]

⚠️ Limitations
[list]
[*]Like all pivot-based tools, signals are confirmed pivotRight bars after the pivot forms; expect a small structural lag on the S/R levels themselves
[*]Confluence gating reduces signal frequency by design — fewer but higher-quality signals, not a continuous signal generator
[*]Volume conformance requires sufficient volume data; on symbols with no volume feed, set Volume Multiplier to 0.0
[*]Best on instruments with genuine liquidity pools and clean swings; choppy low-range sessions produce fewer qualified setups
[/list]

💡 What Makes This Unique
[list]
[*][b]RSI-as-S/R fused with liquidity sweeps[/b]: No top community script currently combines RSI-derived price levels with sweep detection — this fills that white space
[*][b]Fire-only-on-full-confluence design[/b]: Uses the highest-viral-ratio publishing format (confluence-scored engines) applied to PhenLabs’ core liquidity specialty
[/list]

🔬 How It Works
[list=1]
[*][b]RSI S/R construction[/b]: The engine computes RSI, detects confirmed pivots via left/right lookbacks, and records the price high (resistance) or low (support) at each RSI pivot bar. The most recent levels are kept in a rolling buffer, WMA-smoothed, and projected as clean lines on the chart with a soft channel fill between them.
[*][b]Liquidity pool tracking[/b]: Swing highs and lows over the configured lookback define resting liquidity pools. A sweep is registered when price wicks beyond a pool — and optionally closes back inside it, confirming a reversal rather than a continuation stop-run.
[*][b]Triple confluence gating[/b]: The engine checks that the sweep occurred within an ATR-scaled tolerance of the nearest RSI S/R level, and that volume exceeded its moving average by the configured multiple. Only when all three gates align does a bullish or bearish signal marker fire, with a dashed box marking the exact swept pool and a BULL / BEAR label at the signal bar.
[/list]

[quote]💡 Note:
Best results come from pairing the engine with your own market-structure read and using it as a high-probability entry filter rather than a standalone signal. Tune RSI Length and Tolerance to your timeframe — shorter for scalping, longer for swing. This tool is an analytical aid to support your own judgment and is not financial advice.
[/quote]

## Source Code

````pine
//@version=6
// =====================================================================
//  RSI Liquidity Sweep Confluence Engine [PhenLabs]
//  Pine Script v6 — (c) PhenLabs
//
//  Fuses three of this week's dominant TradingView trends into one
//  confluence-scored engine:
//    1. RSI rebuilt as dynamic Support/Resistance (RSI Core Levels concept)
//    2. Liquidity sweep detection at those RSI-derived levels
//    3. "Fire only on full confluence" gating (sweep + RSI level + volume)
//  Signals emit ONLY when all confluences align — no repaint on closed bars.
//
//  CLEAN VISUAL LAYER:
//    - Two smoothed S/R lines only (no y-axis label spam)
//    - One soft gradient channel fill between them
//    - Single clean sweep marker on confluence
//    - Subtle state background tint + colored bars
//    - Compact dashboard
// =====================================================================
indicator("RSI Liquidity Sweep Confluence Engine [PhenLabs]", shorttitle="RSI LSC Engine", overlay=true, max_lines_count=50, max_labels_count=50, max_boxes_count=50)

// ---------------------------------------------------------------------
//  INPUTS
// ---------------------------------------------------------------------
g_rsi = "RSI Engine"
rsiLen      = input.int(14, "RSI Length", minval=2, maxval=50, group=g_rsi, tooltip="Length of the RSI used to derive dynamic S/R levels.")
rsiSrc      = input.source(close, "RSI Source", group=g_rsi)
pivotLeft   = input.int(5, "RSI Pivot Left", minval=1, maxval=20, group=g_rsi, tooltip="Bars left used to confirm RSI pivots.")
pivotRight  = input.int(5, "RSI Pivot Right", minval=1, maxval=20, group=g_rsi, tooltip="Bars right used to confirm RSI pivots.")
keepLevels  = input.int(4, "Active RSI Levels Kept", minval=1, maxval=10, group=g_rsi, tooltip="Most-recent RSI S/R levels kept active on chart.")
smoothLen   = input.int(3, "Level Smoothing (WMA)", minval=1, maxval=10, group=g_rsi, tooltip="WMA length applied to S/R levels for smoother transitions.")

g_sweep = "Liquidity Sweep"
sweepLookback  = input.int(20, "Sweep Lookback", minval=5, maxval=100, group=g_sweep, tooltip="Lookback bars defining swing high/low liquidity pools.")
sweepCloseBack = input.bool(true, "Require Close-Back", group=g_sweep, tooltip="Require price to close back inside the swept level for a valid sweep (reversal confirmation).")

g_conf = "Confluence Gate"
levelTol = input.float(0.30, "RSI Level Tolerance (ATR x)", minval=0.0, maxval=2.0, step=0.05, group=g_conf, tooltip="Distance (as multiple of ATR) within which a sweep counts as touching an RSI S/R level. 0.0 disables RSI-level confluence.")
volMult  = input.float(1.20, "Volume Multiplier", minval=0.0, maxval=5.0, step=0.1, group=g_conf, tooltip="Volume must exceed this multiple of its SMA to confirm. 0.0 disables volume confluence.")
volLen   = input.int(20, "Volume SMA Length", minval=1, maxval=100, group=g_conf)
atrLen   = input.int(14, "ATR Length", minval=1, maxval=100, group=g_conf)

g_vis = "Visuals"
colBull     = input.color(color.new(#26a69a, 0),  "Bullish",            group=g_vis)
colBear     = input.color(color.new(#ef5350, 0),  "Bearish",            group=g_vis)
colRes      = input.color(color.new(#ef5350, 30), "Resistance Line",    group=g_vis)
colSup      = input.color(color.new(#26a69a, 30), "Support Line",       group=g_vis)
colChannel  = input.color(color.new(#9b8cf7, 0),  "Channel Fill",       group=g_vis)
colSweep    = input.color(color.new(#e0b04a, 0),  "Swept Pool",         group=g_vis)
colBarBull  = input.color(color.new(#26a69a, 25), "Bull State Bar",     group=g_vis)
colBarBear  = input.color(color.new(#ef5350, 25), "Bear State Bar",     group=g_vis)
colBarArm   = input.color(color.new(#e0b04a, 40), "Armed State Bar",    group=g_vis)
showChannel = input.bool(true, "Show Channel Fill",      group=g_vis)
showBg      = input.bool(true, "State Background Tint",   group=g_vis)
showBars    = input.bool(true, "Color Bars by State",    group=g_vis)
showDash    = input.bool(true, "Show Dashboard",          group=g_vis)

// ---------------------------------------------------------------------
//  CORE CALCULATION
// ---------------------------------------------------------------------
rsiV   = ta.rsi(rsiSrc, rsiLen)
atrV   = ta.atr(atrLen)
volAvg = ta.sma(volume, volLen)
volOk  = volMult <= 0.0 ? true : (na(volAvg) or volAvg <= 0.0 ? false : volume >= volAvg * volMult)

// RSI pivots -> map to price levels (pivot-confirmed bar is pivotRight bars back)
ph = ta.pivothigh(rsiV, pivotLeft, pivotRight)
pl = ta.pivotlow(rsiV, pivotLeft, pivotRight)

var float[] resLevels = array.new_float()
var float[] supLevels = array.new_float()

if not na(ph)
    array.unshift(resLevels, high[pivotRight])
    while array.size(resLevels) > keepLevels
        array.pop(resLevels)
if not na(pl)
    array.unshift(supLevels, low[pivotRight])
    while array.size(supLevels) > keepLevels
        array.pop(supLevels)

// Nearest RSI-derived resistance above price and support below price (persistent for smooth visuals)
var float nearestRes = na
var float nearestSup  = na

freshRes = float(na)
if array.size(resLevels) > 0
    for i = 0 to array.size(resLevels) - 1
        lvl = array.get(resLevels, i)
        if lvl >= close
            freshRes := na(freshRes) ? lvl : (math.abs(lvl - close) < math.abs(freshRes - close) ? lvl : freshRes)
if not na(freshRes)
    nearestRes := freshRes

freshSup = float(na)
if array.size(supLevels) > 0
    for i = 0 to array.size(supLevels) - 1
        lvl = array.get(supLevels, i)
        if lvl <= close
            freshSup := na(freshSup) ? lvl : (math.abs(lvl - close) < math.abs(freshSup - close) ? lvl : freshSup)
if not na(freshSup)
    nearestSup := freshSup

// Liquidity pools (swing high/low over lookback, excluding current bar to avoid lookahead)
swHigh = ta.highest(high, sweepLookback)[1]
swLow  = ta.lowest(low, sweepLookback)[1]

// Sweep detection: wick beyond pool then (optionally) close back inside
bullSweep = not na(swLow)  and low < swLow  and (not sweepCloseBack or close > swLow)
bearSweep = not na(swHigh) and high > swHigh and (not sweepCloseBack or close < swHigh)

// Confluence with RSI S/R level (tolerance in ATR units)
tol   = levelTol <= 0.0 ? 0.0 : atrV * levelTol
supConf  = not na(nearestSup) and (levelTol <= 0.0 or (not na(tol) and math.abs(low  - nearestSup) <= tol))
resConf  = not na(nearestRes) and (levelTol <= 0.0 or (not na(tol) and math.abs(high - nearestRes) <= tol))

// FULL CONFLUENCE — fire only when all gates align (no repaint on closed bars)
bullSignal = bullSweep and supConf and volOk
bearSignal = bearSweep and resConf and volOk

// Smoothed display levels
smR = ta.wma(nearestRes, smoothLen)
smS = ta.wma(nearestSup, smoothLen)
mid = (smR + smS) / 2.0

// ---------------------------------------------------------------------
//  VISUAL LAYER — TWO LINES + ONE SOFT CHANNEL FILL ONLY
// ---------------------------------------------------------------------
pR = plot(showChannel and not na(smR) ? smR : na, "RSI Res", color=colRes, style=plot.style_line, linewidth=2)
pS = plot(showChannel and not na(smS) ? smS : na, "RSI Sup", color=colSup, style=plot.style_line, linewidth=2)
fill(pR, pS, color=color.new(colChannel, 88), title="Channel")

// ---------------------------------------------------------------------
//  STATE BACKGROUND TINT + COLORED BARS
// ---------------------------------------------------------------------
barState = bullSignal ? 1 : bearSignal ? -1 : (bullSweep or bearSweep ? 2 : 0)
bgCol = not showBg ? na : (barState == 1 ? color.new(colBull, 94) : barState == -1 ? color.new(colBear, 94) : barState == 2 ? color.new(colSweep, 95) : na)
bgcolor(bgCol, title="State Background")

barCol = not showBars ? na : (barState == 1 ? colBarBull : barState == -1 ? colBarBear : barState == 2 ? colBarArm : na)
barcolor(barCol, title="State Bars")

// ---------------------------------------------------------------------
//  SINGLE CLEAN SWEEP MARKER + LABELED SIGNALS (no nested boxes, no armed dots)
// ---------------------------------------------------------------------
if bullSignal and not na(swLow)
    box.new(bar_index - 2, swLow, bar_index + 5, swLow, border_color=colSweep, border_width=1, border_style=line.style_dashed, bgcolor=color.new(colSweep, 80))
    label.new(bar_index, na, "BULL", style=label.style_label_up, color=colBull, textcolor=color.white, size=size.normal, yloc=yloc.belowbar)
if bearSignal and not na(swHigh)
    box.new(bar_index - 2, swHigh, bar_index + 5, swHigh, border_color=colSweep, border_width=1, border_style=line.style_dashed, bgcolor=color.new(colSweep, 80))
    label.new(bar_index, na, "BEAR", style=label.style_label_down, color=colBear, textcolor=color.white, size=size.normal, yloc=yloc.abovebar)

// ---------------------------------------------------------------------
//  COMPACT DASHBOARD
// ---------------------------------------------------------------------
var table dash = table.new(position.top_right, 2, 7, bgcolor=color.new(#0d1117, 10), border_width=1, border_color=color.new(color.gray, 70), frame_width=1, frame_color=color.new(color.gray, 70))

if showDash and barstate.islast
    stateTxt = bullSignal ? "BULL CONFLUENCE" : bearSignal ? "BEAR CONFLUENCE" : (bullSweep or bearSweep ? "ARMED" : "SCANNING")
    stateCol = bullSignal ? colBull : bearSignal ? colBear : (bullSweep or bearSweep ? colSweep : color.new(color.gray, 0))

    hdrBg = color.new(#9b8cf7, 60)
    table.cell(dash, 0, 0, "RSI LSC Engine", text_color=color.white, text_size=size.small, bgcolor=hdrBg)
    table.cell(dash, 1, 0, "𓄀",    text_color=color.white, text_size=size.small, bgcolor=hdrBg)

    table.cell(dash, 0, 1, "RSI",         text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 1, str.tostring(rsiV, "#.0"), text_color=color.white, text_size=size.tiny)

    table.cell(dash, 0, 2, "Resistance",  text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 2, na(nearestRes) ? "—" : str.tostring(nearestRes, "#.##"), text_color=color.new(colBear, 0), text_size=size.tiny)

    table.cell(dash, 0, 3, "Support",     text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 3, na(nearestSup) ? "—" : str.tostring(nearestSup, "#.##"), text_color=color.new(colBull, 0), text_size=size.tiny)

    table.cell(dash, 0, 4, "Volume",      text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 4, volOk ? "YES" : "NO", text_color=volOk ? colBull : color.new(color.gray, 0), text_size=size.tiny)

    table.cell(dash, 0, 5, "ATR",         text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 5, na(atrV) ? "—" : str.tostring(atrV, "#.##"), text_color=color.white, text_size=size.tiny)

    table.cell(dash, 0, 6, "State",       text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 6, stateTxt,      text_color=stateCol, text_size=size.tiny, bgcolor=color.new(stateCol, 82))

// ---------------------------------------------------------------------
//  ALERTS
// ---------------------------------------------------------------------
alertcondition(bullSignal, "Bullish RSI Liquidity Sweep Confluence", "Bullish confluence: RSI support swept + volume confirm — PhenLabs RSI LSC Engine")
alertcondition(bearSignal, "Bearish RSI Liquidity Sweep Confluence", "Bearish confluence: RSI resistance swept + volume confirm — PhenLabs RSI LSC Engine")
````
