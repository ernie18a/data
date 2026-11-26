# AMD/IFVG Confluence System

- url: https://www.tradingview.com/script/uqX1whAG-AMD-IFVG-Confluence-System/
- type: indicator
- pine_id: PUB;cbdabc5b97cf4b1b8182f47d197799dd
- version: 1.0

## Description

AMD/IFVG Confluence System
Multi-timeframe ICT/SMC indicator that combines Power-of-3 session structure, fair value gap inversion tracking, market structure, volume profile, and a 10-point confluence score into a single directional signal engine. Designed for 15m through monthly timeframes on liquid instruments (crypto, FX majors, indices, large-cap equities).
What it plots
[/b]HTF bias table — scores six configurable timeframes (default 15m/1H/4H/D/W/M) using fast EMA, slow EMA, and 200 EMA stack. Each timeframe gets -3 to +3; aggregate range is -18 to +18.
Fair Value Gaps + Inverse FVGs — every 3-candle imbalance is plotted and extended right until tested. When price fully closes through an unmitigated FVG, the box flips polarity and recolors automatically (IFVG). Optional ATR-based minimum-size filter removes noise gaps.
AMD / Power-of-3 sessions — color-coded boxes for Accumulation (Asia 20:00–00:00 NY), Manipulation (London killzone 02:00–05:00 NY), Distribution (NY AM killzone 08:30–11:00 NY), and NY PM (13:30–16:00 NY). All session times and timezone configurable.
Market structure — pivot-based BOS (break of structure) and CHoCH (change of character) detection with line/label markers. Order blocks plotted as the last opposite-direction candle preceding each BOS. Liquidity sweep marks (x) on prior swing-high/low wicks that close back inside.
Volume profile — fixed-lookback VPVR drawn on the latest bar with buy/sell volume split (stacked horizontally), POC line, and VAH/VAL at configurable value-area percentage (default 70%).
Cumulative Volume Delta — windowed CVD with bullish and bearish divergence detection against price.
Reference levels — daily, weekly, and monthly opens; NY midnight open; PDH/PDL/PWH/PWL; daily equilibrium with 38.2% premium/discount edges.
Signal scoring
Each bar computes independent bull and bear scores (0–10) from ten weighted components:

HTF bias alignment (2 pts if strong, 1 pt if mild)
BOS or CHoCH in direction (1 pt)
IFVG flip in direction (1 pt)
Liquidity sweep in direction (1 pt)
Price in premium/discount of daily range (1 pt)
CVD direction (1 pt)
Price above/below NY midnight open (1 pt)
Inside London or NY killzone (1 pt)
CVD divergence in direction (1 pt)

Signal fires when the dominant side ≥ user-set minimum score (default 5) AND beats the opposite side. Triangle marker plots with ATR-based stop-loss and configurable RR target labels.
Alerts
Eight conditions wired: bull/bear confluence signals, bull/bear CHoCH, bull/bear IFVG formation, SSL sweep, BSL sweep.
How to use
Top-down workflow: confirm HTF bias on the bias table, identify the dominant session phase from the AMD boxes, wait for a setup at a premium/discount level or sweep, take signals only when the score meets your threshold and aligns with the bias. Use the killzone gating and CVD divergence components to filter chop. ATR stop suggestion is a starting point — adjust to your risk model.
Settings worth tuning per instrument

Min Confluence Score — raise to 6–7 for fewer/higher-quality signals, drop to 4 for more setups
FVG Min Size (ATR mult) — set to 0.2–0.4 on noisy instruments to filter micro-gaps
VP Lookback — 100 for intraday context, 250+ for swing
Swing Pivot Length — 5 for fast scalping, 15+ for swing structure

Notes

Volume profile renders on the last bar only (standard for performance).
CVD is estimated from candle direction × volume; true tick delta requires exchange-level data not available in TradingView.
Midnight open requires a 00:00 NY bar in your data feed; some exchanges skip it.
HTF requests use lookahead_off to prevent repainting on bias scores.

Disclaimer
This is an indicator, not a strategy or financial advice. Past behavior of price-action patterns does not guarantee future results. Backtest and forward-test on your own instrument and timeframe before risking capital. Signals are decision support, not autopilot.By Primo

## Source Code

````pine
//@version=6
// =============================================================================
// AMD / IFVG / FVG Confluence System
// Multi-timeframe ICT/SMC + TradFi confluence indicator
// Built for: 15m, 1H, 4H, D, W, M
// =============================================================================
indicator("AMD/IFVG Confluence System", "AMD-CFL", overlay=true,
     max_boxes_count=500, max_lines_count=500, max_labels_count=500, max_bars_back=1000)

// =============================================================================
// INPUTS
// =============================================================================

// ---- HTF Bias ----
g_bias = "HTF Bias"
showBiasTable   = input.bool(true,  "Show HTF Bias Table",            group=g_bias)
biasTop         = input.bool(true,  "Table on Top (else Bottom)",     group=g_bias)
biasRight       = input.bool(true,  "Table on Right (else Left)",     group=g_bias)
htf1            = input.timeframe("15",  "TF 1",  group=g_bias)
htf2            = input.timeframe("60",  "TF 2",  group=g_bias)
htf3            = input.timeframe("240", "TF 3",  group=g_bias)
htf4            = input.timeframe("D",   "TF 4",  group=g_bias)
htf5            = input.timeframe("W",   "TF 5",  group=g_bias)
htf6            = input.timeframe("M",   "TF 6",  group=g_bias)
emaFastLen      = input.int(20,  "Fast EMA (bias)", group=g_bias)
emaSlowLen      = input.int(50,  "Slow EMA (bias)", group=g_bias)
emaTrendLen     = input.int(200, "Trend EMA",      group=g_bias)

// ---- FVG / IFVG ----
g_fvg = "FVG / IFVG"
showFVG         = input.bool(true,  "Show FVGs",            group=g_fvg)
showIFVG        = input.bool(true,  "Show Inverse FVGs",    group=g_fvg)
fvgMaxBoxes     = input.int(60,  "Max FVG Boxes",           group=g_fvg, minval=5, maxval=200)
fvgMinSize      = input.float(0.0, "Min FVG Size (ATR mult, 0=off)", group=g_fvg, step=0.05)
extendFVG       = input.bool(true,  "Extend Unmitigated FVGs to Right", group=g_fvg)
bullFVGColor    = input.color(color.new(#26a69a, 80), "Bull FVG",  group=g_fvg)
bearFVGColor    = input.color(color.new(#ef5350, 80), "Bear FVG",  group=g_fvg)
bullIFVGColor   = input.color(color.new(#ef5350, 60), "Bear IFVG (flipped bull)", group=g_fvg)
bearIFVGColor   = input.color(color.new(#26a69a, 60), "Bull IFVG (flipped bear)", group=g_fvg)
mitFVGColor     = input.color(color.new(color.gray, 90),"Mitigated FVG", group=g_fvg)

// ---- AMD Sessions (Power of 3) ----
g_amd = "AMD / PO3 Sessions"
showAMD         = input.bool(true,  "Show AMD Sessions",   group=g_amd)
sessionTZ       = input.string("America/New_York", "Session Timezone", group=g_amd)
asianSess       = input.session("2000-0000", "Accumulation (Asia)",      group=g_amd)
londonSess      = input.session("0200-0500", "Manipulation (London KZ)", group=g_amd)
nyAMSess        = input.session("0830-1100", "Distribution (NY AM KZ)",  group=g_amd)
nyPMSess        = input.session("1330-1600", "NY PM KZ",                 group=g_amd)
accColor        = input.color(color.new(color.blue,    85), "Accumulation",  group=g_amd)
manColor        = input.color(color.new(color.orange,  85), "Manipulation",  group=g_amd)
disColor        = input.color(color.new(color.purple,  85), "Distribution",  group=g_amd)
pmColor         = input.color(color.new(color.fuchsia, 90), "NY PM",         group=g_amd)
labelSessions   = input.bool(true, "Label Sessions", group=g_amd)

// ---- Structure ----
g_str = "Market Structure"
swingLen        = input.int(10, "Swing Pivot Length", group=g_str, minval=2)
showBOS         = input.bool(true, "Show BOS / CHoCH", group=g_str)
showOB          = input.bool(true, "Show Order Blocks", group=g_str)
obLookback      = input.int(20, "OB Lookback Bars",   group=g_str)
showLiqSweep    = input.bool(true, "Show Liquidity Sweeps", group=g_str)
eqlTolATR       = input.float(0.10, "Equal H/L Tolerance (ATR)", group=g_str, step=0.05)

// ---- Volume ----
g_vol = "Volume"
showVP          = input.bool(true, "Show Volume Profile", group=g_vol)
vpLookback      = input.int(150,  "VP Lookback Bars",    group=g_vol, minval=20, maxval=500)
vpRows          = input.int(35,   "VP Rows",             group=g_vol, minval=10, maxval=80)
vpWidthBars     = input.int(40,   "VP Width (bars to right)", group=g_vol, minval=5)
vpValueArea     = input.float(70.0,"Value Area %",        group=g_vol, minval=50, maxval=90)
vpUpColor       = input.color(color.new(#26a69a, 70), "VP Up Vol", group=g_vol)
vpDnColor       = input.color(color.new(#ef5350, 70), "VP Down Vol", group=g_vol)
pocColor        = input.color(color.yellow, "POC Line", group=g_vol)
vaColor         = input.color(color.new(color.aqua, 50), "VAH/VAL Lines", group=g_vol)
showVD          = input.bool(true, "Show Cumulative Volume Delta", group=g_vol)
vdLen           = input.int(50, "CVD Window", group=g_vol)

// ---- Reference Levels ----
g_lvl = "Reference Levels"
showOpens       = input.bool(true, "Show D/W/M Opens", group=g_lvl)
showMidnight    = input.bool(true, "Show Midnight Open (NY)", group=g_lvl)
showPDH_PDL     = input.bool(true, "Show PDH/PDL/PWH/PWL", group=g_lvl)
showPremDisc    = input.bool(true, "Show Premium/Discount (Daily Range)", group=g_lvl)

// ---- Signals ----
g_sig = "Signals & Scoring"
showSignals     = input.bool(true, "Show Entry Signals", group=g_sig)
minScore        = input.int(5, "Min Confluence Score (1-10)", group=g_sig, minval=1, maxval=10)
showSignalTable = input.bool(true, "Show Signal Strength Table", group=g_sig)
atrLen          = input.int(14, "ATR Length", group=g_sig)
rrTarget        = input.float(2.0, "RR Target Multiple", group=g_sig, step=0.1)
slATRmult       = input.float(1.5, "SL ATR Multiple", group=g_sig, step=0.1)

// =============================================================================
// CORE CALCULATIONS
// =============================================================================
atr = ta.atr(atrLen)

// ---------- HTF Bias engine ----------
biasScore(tf) =>
    [c, ef, es, et] = request.security(syminfo.tickerid, tf,
         [close, ta.ema(close, emaFastLen), ta.ema(close, emaSlowLen), ta.ema(close, emaTrendLen)],
         lookahead=barmerge.lookahead_off)
    s = 0
    s := s + (c > et ? 1 : -1)         // above/below long-term trend
    s := s + (ef > es ? 1 : -1)        // fast > slow
    s := s + (c > ef ? 1 : -1)         // price > fast
    s

bs1 = biasScore(htf1)
bs2 = biasScore(htf2)
bs3 = biasScore(htf3)
bs4 = biasScore(htf4)
bs5 = biasScore(htf5)
bs6 = biasScore(htf6)
biasTotal = bs1 + bs2 + bs3 + bs4 + bs5 + bs6   // range: -18 to +18

biasLabel(s) => s >=  2 ? "BULL"  : s <= -2 ? "BEAR"  : "NEUT"
biasColor(s) => s >=  2 ? color.new(color.green,30) : s <= -2 ? color.new(color.red,30) : color.new(color.gray,30)

// ---------- Swing Pivots ----------
ph = ta.pivothigh(high, swingLen, swingLen)
pl = ta.pivotlow(low,  swingLen, swingLen)
var float lastPH = na, var float lastPL = na
var int lastPHBar = na, var int lastPLBar = na
var float prevPH = na, var float prevPL = na

if not na(ph)
    prevPH := lastPH
    lastPH := ph
    lastPHBar := bar_index - swingLen
if not na(pl)
    prevPL := lastPL
    lastPL := pl
    lastPLBar := bar_index - swingLen

// ---------- BOS / CHoCH ----------
var int trendDir = 0   // 1 bull, -1 bear, 0 none
bullBOS = false, bearBOS = false, bullCHoCH = false, bearCHoCH = false

if not na(lastPH) and close > lastPH and close[1] <= lastPH
    if trendDir == -1
        bullCHoCH := true
    else
        bullBOS := true
    trendDir := 1
if not na(lastPL) and close < lastPL and close[1] >= lastPL
    if trendDir == 1
        bearCHoCH := true
    else
        bearBOS := true
    trendDir := -1

if showBOS
    if bullBOS
        line.new(lastPHBar, lastPH, bar_index, lastPH, color=color.new(color.green,30), style=line.style_dashed)
        label.new(bar_index, lastPH, "BOS", style=label.style_label_down, color=color.new(color.green,30), textcolor=color.white, size=size.tiny)
    if bearBOS
        line.new(lastPLBar, lastPL, bar_index, lastPL, color=color.new(color.red,30), style=line.style_dashed)
        label.new(bar_index, lastPL, "BOS", style=label.style_label_up, color=color.new(color.red,30), textcolor=color.white, size=size.tiny)
    if bullCHoCH
        line.new(lastPHBar, lastPH, bar_index, lastPH, color=color.new(color.lime,10), style=line.style_solid, width=2)
        label.new(bar_index, lastPH, "CHoCH", style=label.style_label_down, color=color.new(color.lime,10), textcolor=color.black, size=size.tiny)
    if bearCHoCH
        line.new(lastPLBar, lastPL, bar_index, lastPL, color=color.new(color.maroon,10), style=line.style_solid, width=2)
        label.new(bar_index, lastPL, "CHoCH", style=label.style_label_up, color=color.new(color.maroon,10), textcolor=color.white, size=size.tiny)

// ---------- Liquidity Sweeps ----------
// Sweep = price wicks above prior PH (or below prior PL) then closes back inside
bullSweep = false, bearSweep = false
if not na(prevPH) and high > prevPH and close < prevPH
    bearSweep := true   // swept buyside, expecting reversal down
if not na(prevPL) and low < prevPL and close > prevPL
    bullSweep := true   // swept sellside, expecting reversal up

if showLiqSweep
    if bullSweep
        label.new(bar_index, low, "x", style=label.style_label_up, color=color.new(color.lime,20), textcolor=color.black, size=size.tiny, tooltip="SSL Sweep")
    if bearSweep
        label.new(bar_index, high, "x", style=label.style_label_down, color=color.new(color.red,20), textcolor=color.white, size=size.tiny, tooltip="BSL Sweep")

// =============================================================================
// FVG / IFVG ENGINE
// =============================================================================
// FVG def: 3-candle imbalance
//   Bull FVG: low[0] > high[2]  -> gap zone = [high[2], low[0]]  (we record on the middle candle index, which is bar_index-1)
//   Bear FVG: high[0] < low[2]  -> gap zone = [high[0], low[2]]
// IFVG: an unmitigated FVG that is fully closed through; the closed-through FVG flips polarity.

type FVG
    int   id
    int   leftBar
    int   rightBar
    float top
    float bot
    int   dir       // 1 bull, -1 bear
    bool  mitigated
    bool  inverted
    box   bx
    line  midLn

var array<FVG> fvgs = array.new<FVG>()
var int nextFvgId = 0

newFVG(_id, _top, _bot, _dir) =>
    sz = _top - _bot
    if fvgMinSize > 0 and sz < fvgMinSize * atr
        FVG.new(na, na, na, na, na, na, false, false, na, na)
    else
        col = _dir == 1 ? bullFVGColor : bearFVGColor
        bx  = box.new(bar_index - 2, _top, bar_index, _bot, border_color=color.new(col, 50), bgcolor=col)
        ln  = line.new(bar_index - 2, (_top + _bot)/2, bar_index, (_top + _bot)/2, color=color.new(color.gray, 50), style=line.style_dotted)
        FVG.new(_id, bar_index - 2, bar_index, _top, _bot, _dir, false, false, bx, ln)

// Detect new FVG on close of bar (using bar_index-2 as left, bar_index as right -> middle bar is bar_index-1)
bullFVGFound = low > high[2]
bearFVGFound = high < low[2]

if showFVG
    if bullFVGFound
        nextFvgId += 1
        f = newFVG(nextFvgId, low, high[2], 1)
        if not na(f.id)
            fvgs.push(f)
    if bearFVGFound
        nextFvgId += 1
        f = newFVG(nextFvgId, low[2], high, -1)
        if not na(f.id)
            fvgs.push(f)

// Trim oldest if exceeding cap
while fvgs.size() > fvgMaxBoxes
    f = fvgs.shift()
    if not na(f.bx)
        box.delete(f.bx)
    if not na(f.midLn)
        line.delete(f.midLn)

// Update each FVG: extend, check mitigation, check inversion
var int newlyInvertedBull = 0  // count this bar
var int newlyInvertedBear = 0
newlyInvertedBull := 0
newlyInvertedBear := 0

if fvgs.size() > 0
    for i = 0 to fvgs.size() - 1
        f = fvgs.get(i)
        // Extend right edge while unmitigated and unverted
        if extendFVG and not f.mitigated and not f.inverted and not na(f.bx)
            box.set_right(f.bx, bar_index)
            line.set_x2(f.midLn, bar_index)

        // Check inversion (full close-through)
        if not f.inverted and not f.mitigated
            if f.dir == 1 and close < f.bot
                f.inverted := true
                f.dir := -1
                newlyInvertedBull += 1   // bull FVG just inverted -> now bearish IFVG
                if not na(f.bx)
                    box.set_bgcolor(f.bx, bullIFVGColor)
                    box.set_border_color(f.bx, color.new(bullIFVGColor, 30))
            else if f.dir == -1 and close > f.top
                f.inverted := true
                f.dir := 1
                newlyInvertedBear += 1   // bear FVG just inverted -> now bullish IFVG
                if not na(f.bx)
                    box.set_bgcolor(f.bx, bearIFVGColor)
                    box.set_border_color(f.bx, color.new(bearIFVGColor, 30))

        // Check normal mitigation only if not inverted yet (touched but not closed through)
        if not f.inverted and not f.mitigated
            if f.dir == 1 and low <= f.top and low >= f.bot
                // tagged the bull FVG but didn't close through -> still valid until inversion
                na
            if f.dir == -1 and high >= f.bot and high <= f.top
                na

        fvgs.set(i, f)

// =============================================================================
// ORDER BLOCKS (basic last opposite candle before displacement)
// =============================================================================
var array<box> obBoxes = array.new<box>()
// Bullish OB: last bearish candle before a bull BOS
// Bearish OB: last bullish candle before a bear BOS
if showOB and bullBOS
    // find nearest bearish candle within obLookback
    for k = 1 to obLookback
        if close[k] < open[k]
            b = box.new(bar_index - k, high[k], bar_index, low[k], border_color=color.new(color.green,40), bgcolor=color.new(color.green, 88))
            obBoxes.push(b)
            break
if showOB and bearBOS
    for k = 1 to obLookback
        if close[k] > open[k]
            b = box.new(bar_index - k, high[k], bar_index, low[k], border_color=color.new(color.red,40), bgcolor=color.new(color.red, 88))
            obBoxes.push(b)
            break
while obBoxes.size() > 30
    b = obBoxes.shift()
    box.delete(b)

// =============================================================================
// AMD SESSIONS (PO3)
// =============================================================================
inSession(sess) => not na(time(timeframe.period, sess, sessionTZ))

inAsia    = inSession(asianSess)
inLondon  = inSession(londonSess)
inNYAM    = inSession(nyAMSess)
inNYPM    = inSession(nyPMSess)

var box asiaBox = na, var float asiaHi = na, var float asiaLo = na, var int asiaStart = na
var box lonBox  = na, var float lonHi  = na, var float lonLo  = na, var int lonStart  = na
var box nyBox   = na, var float nyHi   = na, var float nyLo   = na, var int nyStart   = na
var box pmBox   = na, var float pmHi   = na, var float pmLo   = na, var int pmStart   = na

mkSessionBox(start_state, in_now, ref_state) => 0  // unused helper placeholder

// Asia
if showAMD
    if inAsia and not inAsia[1]
        asiaStart := bar_index
        asiaHi := high
        asiaLo := low
        asiaBox := box.new(asiaStart, asiaHi, bar_index, asiaLo, border_color=color.new(color.blue,50), bgcolor=accColor)
        if labelSessions
            label.new(asiaStart, asiaHi, "ACCUM", style=label.style_label_down, color=color.new(color.blue,40), textcolor=color.white, size=size.small)
    if inAsia
        asiaHi := math.max(asiaHi, high)
        asiaLo := math.min(asiaLo, low)
        if not na(asiaBox)
            box.set_top(asiaBox, asiaHi)
            box.set_bottom(asiaBox, asiaLo)
            box.set_right(asiaBox, bar_index)
    // London
    if inLondon and not inLondon[1]
        lonStart := bar_index
        lonHi := high
        lonLo := low
        lonBox := box.new(lonStart, lonHi, bar_index, lonLo, border_color=color.new(color.orange,50), bgcolor=manColor)
        if labelSessions
            label.new(lonStart, lonHi, "MANIP", style=label.style_label_down, color=color.new(color.orange,30), textcolor=color.black, size=size.small)
    if inLondon
        lonHi := math.max(lonHi, high)
        lonLo := math.min(lonLo, low)
        if not na(lonBox)
            box.set_top(lonBox, lonHi)
            box.set_bottom(lonBox, lonLo)
            box.set_right(lonBox, bar_index)
    // NY AM
    if inNYAM and not inNYAM[1]
        nyStart := bar_index
        nyHi := high
        nyLo := low
        nyBox := box.new(nyStart, nyHi, bar_index, nyLo, border_color=color.new(color.purple,50), bgcolor=disColor)
        if labelSessions
            label.new(nyStart, nyHi, "DIST", style=label.style_label_down, color=color.new(color.purple,30), textcolor=color.white, size=size.small)
    if inNYAM
        nyHi := math.max(nyHi, high)
        nyLo := math.min(nyLo, low)
        if not na(nyBox)
            box.set_top(nyBox, nyHi)
            box.set_bottom(nyBox, nyLo)
            box.set_right(nyBox, bar_index)
    // NY PM
    if inNYPM and not inNYPM[1]
        pmStart := bar_index
        pmHi := high
        pmLo := low
        pmBox := box.new(pmStart, pmHi, bar_index, pmLo, border_color=color.new(color.fuchsia,60), bgcolor=pmColor)
    if inNYPM
        pmHi := math.max(pmHi, high)
        pmLo := math.min(pmLo, low)
        if not na(pmBox)
            box.set_top(pmBox, pmHi)
            box.set_bottom(pmBox, pmLo)
            box.set_right(pmBox, bar_index)

// =============================================================================
// REFERENCE LEVELS: D/W/M opens, Midnight Open, PDH/PDL/PWH/PWL, Premium/Discount
// =============================================================================
[dOpen, dHigh, dLow, dClose] = request.security(syminfo.tickerid, "D", [open, high[1], low[1], close[1]], lookahead=barmerge.lookahead_on)
[wOpen, wHigh, wLow]         = request.security(syminfo.tickerid, "W", [open, high[1], low[1]],          lookahead=barmerge.lookahead_on)
[mOpen]                      = request.security(syminfo.tickerid, "M", [open],                            lookahead=barmerge.lookahead_on)

plot(showOpens     ? dOpen : na, "Daily Open",   color=color.new(color.yellow, 20), linewidth=1, style=plot.style_circles)
plot(showOpens     ? wOpen : na, "Weekly Open",  color=color.new(color.orange, 20), linewidth=2, style=plot.style_circles)
plot(showOpens     ? mOpen : na, "Monthly Open", color=color.new(color.red,    20), linewidth=2, style=plot.style_circles)
plot(showPDH_PDL   ? dHigh : na, "PDH",          color=color.new(color.aqua,    40), style=plot.style_linebr)
plot(showPDH_PDL   ? dLow  : na, "PDL",          color=color.new(color.aqua,    40), style=plot.style_linebr)
plot(showPDH_PDL   ? wHigh : na, "PWH",          color=color.new(color.purple,  30), style=plot.style_linebr)
plot(showPDH_PDL   ? wLow  : na, "PWL",          color=color.new(color.purple,  30), style=plot.style_linebr)

// Midnight Open (NY)
var float midnightOpen = na
isNewDayNY = ta.change(time("D", "0000-0001", sessionTZ))
if not na(isNewDayNY) and isNewDayNY != 0
    midnightOpen := open
plot(showMidnight ? midnightOpen : na, "NY Midnight Open", color=color.new(#ffffff, 20), style=plot.style_linebr, linewidth=1)

// Premium / Discount on daily range
dMid = (dHigh + dLow) / 2
dPrem = dHigh - (dHigh - dLow) * 0.382
dDisc = dLow  + (dHigh - dLow) * 0.382
plot(showPremDisc ? dMid  : na, "Daily Equilibrium", color=color.new(color.gray, 30), style=plot.style_linebr)
plot(showPremDisc ? dPrem : na, "Premium Edge",      color=color.new(color.red,  60), style=plot.style_linebr)
plot(showPremDisc ? dDisc : na, "Discount Edge",     color=color.new(color.green,60), style=plot.style_linebr)

// =============================================================================
// VOLUME PROFILE (fixed lookback, right-projected)
// =============================================================================
var array<float> vpVolBuy  = array.new_float(vpRows, 0.0)
var array<float> vpVolSell = array.new_float(vpRows, 0.0)
var array<box>   vpBoxes   = array.new<box>()
var line pocLine = na
var line vahLine = na
var line valLine = na

calcVP() =>
    // reset
    for i = 0 to vpRows - 1
        vpVolBuy.set(i, 0.0)
        vpVolSell.set(i, 0.0)
    float hi = high
    float lo = low
    for k = 0 to vpLookback - 1
        hi := math.max(hi, high[k])
        lo := math.min(lo, low[k])
    rowH = (hi - lo) / vpRows
    if rowH > 0
        for k = 0 to vpLookback - 1
            // distribute bar volume across the rows the candle spans
            bHi = high[k]
            bLo = low[k]
            bSpan = bHi - bLo
            isUp = close[k] >= open[k]
            spanRows = math.max(1, math.round(bSpan / rowH))
            volPerRow = volume[k] / spanRows
            startRow = math.floor((bLo - lo) / rowH)
            for r = 0 to spanRows - 1
                idx = startRow + r
                if idx >= 0 and idx < vpRows
                    if isUp
                        vpVolBuy.set(idx, vpVolBuy.get(idx) + volPerRow)
                    else
                        vpVolSell.set(idx, vpVolSell.get(idx) + volPerRow)
    [hi, lo, rowH]

[vpHi, vpLo, vpRowH] = calcVP()

// Find POC and Value Area
findPOC() =>
    maxVol = 0.0
    pocIdx = 0
    totalVol = 0.0
    for i = 0 to vpRows - 1
        v = vpVolBuy.get(i) + vpVolSell.get(i)
        totalVol += v
        if v > maxVol
            maxVol := v
            pocIdx := i
    [pocIdx, maxVol, totalVol]

[pocIdx, pocVol, totalVol] = findPOC()
pocPrice = vpLo + (pocIdx + 0.5) * vpRowH

// Value area expansion from POC
findVA(_pocIdx, _totalVol) =>
    target = _totalVol * vpValueArea / 100.0
    acc = vpVolBuy.get(_pocIdx) + vpVolSell.get(_pocIdx)
    lo_i = _pocIdx
    hi_i = _pocIdx
    while acc < target and (lo_i > 0 or hi_i < vpRows - 1)
        upV   = hi_i < vpRows - 1 ? vpVolBuy.get(hi_i + 1) + vpVolSell.get(hi_i + 1) : -1.0
        dnV   = lo_i > 0          ? vpVolBuy.get(lo_i - 1) + vpVolSell.get(lo_i - 1) : -1.0
        if upV >= dnV and hi_i < vpRows - 1
            hi_i += 1
            acc += upV
        else if lo_i > 0
            lo_i -= 1
            acc += dnV
        else
            break
    [lo_i, hi_i]

[vaLoIdx, vaHiIdx] = findVA(pocIdx, totalVol)
vahPrice = vpLo + (vaHiIdx + 1) * vpRowH
valPrice = vpLo + vaLoIdx * vpRowH

// Draw VP on last bar
if showVP and barstate.islast
    // clear old
    while vpBoxes.size() > 0
        b = vpBoxes.shift()
        box.delete(b)
    // find max combined for scaling
    maxComb = 0.0
    for i = 0 to vpRows - 1
        c = vpVolBuy.get(i) + vpVolSell.get(i)
        if c > maxComb
            maxComb := c
    if maxComb > 0
        rightBar = bar_index + vpWidthBars
        for i = 0 to vpRows - 1
            buyV  = vpVolBuy.get(i)
            sellV = vpVolSell.get(i)
            comb  = buyV + sellV
            rowLo = vpLo + i * vpRowH
            rowHi = rowLo + vpRowH
            buyWidth  = math.round(vpWidthBars * (buyV  / maxComb))
            sellWidth = math.round(vpWidthBars * (sellV / maxComb))
            // sell stacked left of buy (both starting at bar_index)
            if sellWidth > 0
                bs = box.new(bar_index, rowHi, bar_index + sellWidth, rowLo, border_color=na, bgcolor=vpDnColor)
                vpBoxes.push(bs)
            if buyWidth > 0
                bb = box.new(bar_index + sellWidth, rowHi, bar_index + sellWidth + buyWidth, rowLo, border_color=na, bgcolor=vpUpColor)
                vpBoxes.push(bb)
        // POC line
        if not na(pocLine)
            line.delete(pocLine)
        pocLine := line.new(bar_index - vpLookback, pocPrice, rightBar, pocPrice, color=pocColor, width=2)
        if not na(vahLine)
            line.delete(vahLine)
        vahLine := line.new(bar_index - vpLookback, vahPrice, rightBar, vahPrice, color=vaColor, style=line.style_dashed)
        if not na(valLine)
            line.delete(valLine)
        valLine := line.new(bar_index - vpLookback, valPrice, rightBar, valPrice, color=vaColor, style=line.style_dashed)

// =============================================================================
// CUMULATIVE VOLUME DELTA (estimated from candle direction within window)
// =============================================================================
barDelta = close > open ? volume : close < open ? -volume : 0.0
cvd = math.sum(barDelta, vdLen)
cvdRising  = cvd > cvd[1]
cvdFalling = cvd < cvd[1]
// CVD divergence with price
priceUp   = close > close[vdLen]
priceDown = close < close[vdLen]
cvdBullDiv = priceDown and cvd > cvd[vdLen]   // price down, CVD up -> bullish divergence
cvdBearDiv = priceUp   and cvd < cvd[vdLen]   // price up, CVD down -> bearish divergence

// =============================================================================
// KILLZONE FLAG (for signal scoring)
// =============================================================================
inKZ = inLondon or inNYAM or inNYPM

// =============================================================================
// CONFLUENCE SCORING ENGINE (0-10)
// Bull score components:
//   +2  HTF bias >=  4
//   +1  HTF bias >=  2
//   +1  CHoCH bull or BOS bull this bar
//   +1  Bullish IFVG flipped this bar (bear FVG inverted)
//   +1  Bull liquidity sweep this bar
//   +1  Price in discount of daily range (close < dMid)
//   +1  CVD rising
//   +1  Price above NY midnight open
//   +1  In killzone (London/NY)
//   +1  CVD bullish divergence
// Bear score mirrors.
// =============================================================================
bullScore = 0
bearScore = 0

bullScore += biasTotal >=  4 ? 2 : 0
bullScore += biasTotal >=  2 and biasTotal < 4 ? 1 : 0
bullScore += (bullCHoCH or bullBOS) ? 1 : 0
bullScore += newlyInvertedBear > 0 ? 1 : 0      // bear FVG -> bull IFVG
bullScore += bullSweep ? 1 : 0
bullScore += close < dMid ? 1 : 0
bullScore += cvdRising ? 1 : 0
bullScore += not na(midnightOpen) and close > midnightOpen ? 1 : 0
bullScore += inKZ ? 1 : 0
bullScore += cvdBullDiv ? 1 : 0

bearScore += biasTotal <= -4 ? 2 : 0
bearScore += biasTotal <= -2 and biasTotal > -4 ? 1 : 0
bearScore += (bearCHoCH or bearBOS) ? 1 : 0
bearScore += newlyInvertedBull > 0 ? 1 : 0
bearScore += bearSweep ? 1 : 0
bearScore += close > dMid ? 1 : 0
bearScore += cvdFalling ? 1 : 0
bearScore += not na(midnightOpen) and close < midnightOpen ? 1 : 0
bearScore += inKZ ? 1 : 0
bearScore += cvdBearDiv ? 1 : 0

bullSignal = showSignals and bullScore >= minScore and bullScore > bearScore
bearSignal = showSignals and bearScore >= minScore and bearScore > bullScore

// Suggested SL/TP using ATR
bullSL = low  - slATRmult * atr
bullTP = close + (close - bullSL) * rrTarget
bearSL = high + slATRmult * atr
bearTP = close - (bearSL - close) * rrTarget

plotshape(bullSignal, "LONG", style=shape.triangleup,   location=location.belowbar, color=color.new(color.lime,0), text="L", textcolor=color.black, size=size.small)
plotshape(bearSignal, "SHORT", style=shape.triangledown, location=location.abovebar, color=color.new(color.red,0),  text="S", textcolor=color.white, size=size.small)

// Plot SL/TP markers when signal fires
if bullSignal
    label.new(bar_index, bullTP, "TP " + str.tostring(bullTP, format.mintick), style=label.style_label_left, color=color.new(color.green,50), textcolor=color.white, size=size.tiny)
    label.new(bar_index, bullSL, "SL " + str.tostring(bullSL, format.mintick), style=label.style_label_left, color=color.new(color.red,50),   textcolor=color.white, size=size.tiny)
if bearSignal
    label.new(bar_index, bearTP, "TP " + str.tostring(bearTP, format.mintick), style=label.style_label_left, color=color.new(color.green,50), textcolor=color.white, size=size.tiny)
    label.new(bar_index, bearSL, "SL " + str.tostring(bearSL, format.mintick), style=label.style_label_left, color=color.new(color.red,50),   textcolor=color.white, size=size.tiny)

// =============================================================================
// TABLES
// =============================================================================
tablePos = biasTop and biasRight ? position.top_right : biasTop and not biasRight ? position.top_left : not biasTop and biasRight ? position.bottom_right : position.bottom_left

var table tBias = table.new(tablePos, 3, 8, border_width=1)
if showBiasTable and barstate.islast
    table.cell(tBias, 0, 0, "TF",    bgcolor=color.new(color.black,30), text_color=color.white, text_size=size.small)
    table.cell(tBias, 1, 0, "Score", bgcolor=color.new(color.black,30), text_color=color.white, text_size=size.small)
    table.cell(tBias, 2, 0, "Bias",  bgcolor=color.new(color.black,30), text_color=color.white, text_size=size.small)
    rows = array.from(htf1, htf2, htf3, htf4, htf5, htf6)
    scores = array.from(bs1, bs2, bs3, bs4, bs5, bs6)
    for i = 0 to 5
        table.cell(tBias, 0, i+1, rows.get(i), text_color=color.white, text_size=size.small)
        table.cell(tBias, 1, i+1, str.tostring(scores.get(i)), text_color=color.white, text_size=size.small)
        table.cell(tBias, 2, i+1, biasLabel(scores.get(i)), bgcolor=biasColor(scores.get(i)), text_color=color.white, text_size=size.small)
    table.cell(tBias, 0, 7, "TOTAL", bgcolor=color.new(color.gray,50), text_color=color.white, text_size=size.small)
    table.cell(tBias, 1, 7, str.tostring(biasTotal), bgcolor=color.new(color.gray,50), text_color=color.white, text_size=size.small)
    table.cell(tBias, 2, 7, biasLabel(biasTotal), bgcolor=biasColor(biasTotal), text_color=color.white, text_size=size.small)

var table tSig = table.new(position.bottom_right, 2, 6, border_width=1)
if showSignalTable and barstate.islast
    sigDir = bullScore > bearScore ? "BULL" : bearScore > bullScore ? "BEAR" : "NEUT"
    sigCol = bullScore > bearScore ? color.new(color.green,30) : bearScore > bullScore ? color.new(color.red,30) : color.new(color.gray,30)
    sigMax = math.max(bullScore, bearScore)
    strength = sigMax >= 8 ? "VERY STRONG" : sigMax >= 6 ? "STRONG" : sigMax >= 4 ? "MODERATE" : "WEAK"
    table.cell(tSig, 0, 0, "Direction", bgcolor=color.new(color.black,30), text_color=color.white, text_size=size.small)
    table.cell(tSig, 1, 0, sigDir, bgcolor=sigCol, text_color=color.white, text_size=size.small)
    table.cell(tSig, 0, 1, "Bull Score", text_color=color.white, text_size=size.small)
    table.cell(tSig, 1, 1, str.tostring(bullScore) + " / 10", text_color=color.lime, text_size=size.small)
    table.cell(tSig, 0, 2, "Bear Score", text_color=color.white, text_size=size.small)
    table.cell(tSig, 1, 2, str.tostring(bearScore) + " / 10", text_color=color.red, text_size=size.small)
    table.cell(tSig, 0, 3, "Strength", text_color=color.white, text_size=size.small)
    table.cell(tSig, 1, 3, strength, bgcolor=sigCol, text_color=color.white, text_size=size.small)
    table.cell(tSig, 0, 4, "POC",  text_color=color.white, text_size=size.small)
    table.cell(tSig, 1, 4, str.tostring(pocPrice, format.mintick), text_color=color.yellow, text_size=size.small)
    table.cell(tSig, 0, 5, "VAH/VAL", text_color=color.white, text_size=size.small)
    table.cell(tSig, 1, 5, str.tostring(vahPrice, format.mintick) + " / " + str.tostring(valPrice, format.mintick), text_color=color.aqua, text_size=size.small)

// =============================================================================
// ALERTS
// =============================================================================
alertcondition(bullSignal, "Bull Confluence Signal", "AMD/IFVG bull signal {{ticker}} {{interval}} score {{plot_0}}")
alertcondition(bearSignal, "Bear Confluence Signal", "AMD/IFVG bear signal {{ticker}} {{interval}} score {{plot_0}}")
alertcondition(bullCHoCH,  "Bull CHoCH",   "Bull CHoCH on {{ticker}} {{interval}}")
alertcondition(bearCHoCH,  "Bear CHoCH",   "Bear CHoCH on {{ticker}} {{interval}}")
alertcondition(newlyInvertedBear > 0, "Bull IFVG formed", "Bear FVG flipped bullish on {{ticker}} {{interval}}")
alertcondition(newlyInvertedBull > 0, "Bear IFVG formed", "Bull FVG flipped bearish on {{ticker}} {{interval}}")
alertcondition(bullSweep, "SSL Sweep (bullish)", "Sellside liquidity swept on {{ticker}}")
alertcondition(bearSweep, "BSL Sweep (bearish)", "Buyside liquidity swept on {{ticker}}")
````
