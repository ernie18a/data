# Market Phase Detector [JOAT]

- url: https://www.tradingview.com/script/2QJbZIUe-Market-Phase-Detector-JOAT/
- type: indicator
- pine_id: PUB;01e0dba85a9741da9f8025b8fd6f28b3
- version: 1.0

## Description

[b]Market Phase Detector [JOAT][/b]

[b]Introduction[/b]

Market Phase Detector is an open-source market structure classification engine that continuously identifies whether price is operating in a Bullish Trend, Bearish Trend, or Range state. The classification uses three independent inputs that must align simultaneously before a regime is confirmed, making the output robust against single-factor noise and false positives that plague simpler trend detectors.

The problem Market Phase Detector solves is context. Trend-following entries during range conditions produce whipsaws. Mean-reversion entries during strong trending moves produce losses against the dominant flow. Knowing the regime before interpreting any other signal improves the relevance of every decision made from it. Market Phase Detector makes that determination automatically, updates it bar by bar, and visualizes both the current regime and every structural event that contributed to it — including labeled BOS and CHoCH events with horizontal level lines, live swing extension lines at the right edge, and an institutional-grade dashboard.

[image]https://www.tradingview.com/x/xeIsMVXZ/[/image]

[b]Core Concepts[/b]

[b]1. Swing Detection and Pivot Tracking[/b]

Price structure is derived from pivot highs and lows confirmed using ta.pivothigh() and ta.pivotlow() with a configurable symmetric lookback. The lookback controls sensitivity — a value of 5 requires 5 bars on each side of the pivot to confirm it, producing only the most structurally significant swings. Each confirmed pivot updates the tracked level and resets its broken flag to allow new break detection on the next cycle:

[pine]
pivHi = ta.pivothigh(high, swingLen, swingLen)
pivLo = ta.pivotlow(low,  swingLen, swingLen)

if not na(pivHi)
    topLevel  := pivHi
    topBroken := false
[/pine]

[b]2. Break of Structure vs Change of Character[/b]

Two structural event types are distinguished and tracked independently. A Break of Structure (BOS) occurs when price closes through the previous swing extreme in the same direction as the current structural bias — confirming continuation. A Change of Character (CHoCH) occurs when price closes through the previous swing extreme against the current structural bias — signaling a potential regime flip:

[pine]
bosBull   = bullBreak and structureBias == 1
chochBull = bullBreak and structureBias != 1
[/pine]

Every event is labeled directly on the chart with a horizontal line at the break level and a text label (BOS +, BOS -, CHoCH +, CHoCH -). Running counts of each type are tracked and displayed in the dashboard.

[b]3. Three-Factor Regime Gate[/b]

The regime classification evaluates all three inputs simultaneously before assigning a state. Structure bias is set by BOS and CHoCH events. The volatility gate compares current ATR to a moving average of ATR multiplied by a contraction threshold — when ATR falls below this level the market is classified as compressed and the regime defaults to Range regardless of structure or momentum. Momentum uses a smoothed rate-of-change that must confirm the structural direction:

[pine]
if isLowVol
    regime := 0          // Range — volatility gate overrides everything
else if strBias == 1 and roc > 0
    regime := 1          // Bullish
else if strBias == -1 and roc < 0
    regime := -1         // Bearish
else
    regime := 0          // Inconclusive — range
[/pine]

A confidence score (1-3) counts how many of the three factors currently agree and is displayed in the dashboard, allowing the trader to distinguish a fully confirmed 3/3 regime from a weaker 2/3 reading.

[b]4. Swing Level Extension Lines[/b]

The current unbroken swing high and swing low are extended as dotted horizontal lines to the right edge of the chart with price labels. These serve as the nearest structural reference levels — the next points where a BOS or CHoCH could occur. They are deleted and redrawn each bar using barstate.islast so they remain current without consuming the indicator's line budget:

[pine]
if barstate.islast and showSwingExt
    line.delete(swingHiLine)
    swingHiLine := line.new(topBar, topLevel, bar_index + 4, topLevel,
         color=color.new(#E65100, 45), style=line.style_dotted, width=2)
[/pine]

[b]5. Regime Background Shading[/b]

The chart background is tinted according to the current regime — faint teal for Bullish, faint orange for Bearish, neutral gray for Range. This gives immediate context at a glance without adding visual noise to the price action.

[image]https://www.tradingview.com/x/wjpO0red/[/image]

[b]Features[/b]

[list]
[*][b]Three-state regime output:[/b] Bullish, Bearish, and Range states derived from structure, volatility, and momentum alignment
[*][b]BOS and CHoCH event labels:[/b] Every structural break labeled on-chart with event type, direction, and horizontal level line
[*][b]Independent BOS and CHoCH counters:[/b] Running totals of each structural event type in the dashboard
[*][b]Swing level extension lines:[/b] Dotted right-edge lines at the current unbroken swing high and low with price labels
[*][b]ATR-based volatility gate:[/b] Low-volatility contraction forces a Range classification regardless of structure or momentum
[*][b]Smoothed momentum confirmation:[/b] Rate-of-change must align with structure before a trending regime is confirmed
[*][b]Confidence scoring (1/3 to 3/3):[/b] Quantifies how many of the three classification factors are currently aligned
[*][b]Regime background shading:[/b] Chart background tint reflects the current regime in real time
[*][b]Institutional dashboard (top right):[/b] 15-row table with regime state, confidence, last break direction and age, BOS and CHoCH counts, swing levels, and ATR
[*][b]Fully configurable colors:[/b] Bullish, bearish, and ranging tints plus structure line colors are independently adjustable
[*][b]All signals confirmed bar only:[/b] No repainting — all structural events fire on barstate.isconfirmed
[/list]

[b]Input Parameters[/b]

[b]Structure Detection:[/b]
[list]
[*]Swing Lookback: Left/right bars required for pivot confirmation (default: 5)
[*]ATR Period: ATR calculation length (default: 14)
[/list]

[b]Regime Classification:[/b]
[list]
[*]Volatility MA Length: MA length for ATR comparison (default: 20)
[*]Range Contraction Multiplier: ATR fraction below which the market is classified as ranging (default: 0.7)
[*]Momentum Lookback: Rate-of-change lookback and EMA smoothing period (default: 10)
[/list]

[b]Display:[/b]
[list]
[*]Regime Background Shading toggle
[*]Show Dashboard toggle
[*]Show Structure Lines toggle
[*]Show Swing Level Extensions toggle
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Read the Current Regime[/b]
Check the REGIME row in the dashboard. BULLISH, BEARISH, or RANGE appears in its corresponding color. This is the primary output. Use it to establish directional bias before consulting any other signal source.

[b]Step 2: Check Confidence Score[/b]
The Confidence row shows how many of the three inputs align (e.g., 2/3). A 3/3 reading means structure, volatility, and momentum all agree. A 2/3 reading means one factor is diverging. Weight directional decisions higher during full 3/3 alignment.

[b]Step 3: Monitor CHoCH Events[/b]
Each CHoCH label marks a structural break against the current bias — a warning that the regime may be shifting. When a CHoCH appears, watch whether subsequent bars confirm a new opposing BOS or whether the previous regime resumes.

[b]Step 4: Use Swing Extension Lines as Forward Reference[/b]
The dotted right-edge lines mark the current unbroken swing levels — the nearest structural break zones. Knowing how close price is to these levels frames where the next BOS or CHoCH could occur.

[b]Step 5: Apply Regime as a Filter[/b]
Market Phase Detector is designed as a context layer, not a standalone signal generator. Apply the regime output as a filter to your existing tools: only take long signals when the regime is Bullish, only take short signals when Bearish, and step aside or apply mean-reversion logic when Range is active.

[b]Indicator Limitations[/b]

[list]
[*]Pivot detection confirms swingLen bars after the pivot forms, creating a natural offset between the candle where the swing occurred and when it is labeled. This is intentional non-repainting behavior
[*]The volatility gate may temporarily classify a new trend as Range immediately after a volatility expansion if ATR has not yet risen above the threshold. This resolves within a few bars as ATR normalizes
[*]In slow, grinding markets, momentum may repeatedly lag structure, resulting in extended Range readings during mild trends
[*]Market Phase Detector classifies current market state. It does not predict future price direction or generate entry/exit signals
[/list]

[b]Originality Statement[/b]

Market Phase Detector is original in its three-factor gate requiring independent alignment of structure, volatility, and momentum before any regime is confirmed. This indicator is published because:

[list]
[*]The combination of CHoCH and BOS structural logic, an ATR contraction gate, and a smoothed momentum filter into a single lightweight classifier that produces a confidence score is uncommon in published open-source Pine Script v6
[*]Distinguishing BOS from CHoCH within the same indicator — with independent event counts and labeled historical events — provides structural context that standalone trend indicators do not offer
[*]The confidence scoring system (1-3) quantifies the strength of the current regime reading across three independent analytical dimensions, not just a single oscillator value
[*]Swing level extension lines provide live structural reference at the right edge of the chart without requiring the user to manually draw levels or add a separate pivot indicator
[/list]

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice or a recommendation to buy or sell any financial instrument. Trading involves substantial risk of loss. Regime classifications are based on historical price data and do not guarantee any future market behavior. All three factors can produce inaccurate readings in atypical market conditions. Always use proper risk management. The author is not responsible for any trading losses resulting from the use of this indicator.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Market Phase Detector [JOAT]", shorttitle="Phase Detector [JOAT]", overlay=true,
     max_boxes_count=200, max_labels_count=300, max_lines_count=400)

// ─── INPUTS ────────────────────────────────────────────────────────────────────
grpStructure = "Structure Detection"
swingLen     = input.int(5,    "Swing Lookback",        minval=2, maxval=50,  group=grpStructure,
     tooltip="Left/right bars for pivot detection. Lower = more sensitive.")
atrPeriod    = input.int(14,   "ATR Period",            minval=1, maxval=100, group=grpStructure)

grpRegime    = "Regime Classification"
volContLen   = input.int(20,   "Volatility MA Length",  minval=5, maxval=100,  group=grpRegime)
volContThres = input.float(0.7,"Range Contraction Mult",minval=0.3, maxval=1.5, step=0.05, group=grpRegime,
     tooltip="ATR below this fraction of its moving average signals a ranging market.")
momentumLen  = input.int(10,   "Momentum Lookback",     minval=2, maxval=50,  group=grpRegime)

grpVisual = "Display"
showRegimeBg = input.bool(true, "Regime Background Shading", group=grpVisual)
showDash     = input.bool(true, "Show Dashboard",            group=grpVisual)
showStructLn = input.bool(true, "Show Structure Lines",      group=grpVisual)
showSwingExt = input.bool(true, "Show Swing Level Extensions",group=grpVisual,
     tooltip="Extends current swing high/low as a dotted line with a price label at the right edge.")

grpColors = "Colors"
bullTint   = input.color(color.new(#0097A7, 93), "Bullish Regime Tint",  group=grpColors)
bearTint   = input.color(color.new(#E65100, 93), "Bearish Regime Tint",  group=grpColors)
rangeTint  = input.color(color.new(#546E7A, 95), "Ranging Regime Tint",  group=grpColors)
structBull = input.color(color.new(#0097A7, 20), "Bullish Structure",     group=grpColors)
structBear = input.color(color.new(#E65100, 20), "Bearish Structure",     group=grpColors)

// ─── ATR ───────────────────────────────────────────────────────────────────────
atr   = ta.atr(atrPeriod)
atrMA = ta.sma(atr, volContLen)

// ─── SWING DETECTION ───────────────────────────────────────────────────────────
pivHi = ta.pivothigh(high, swingLen, swingLen)
pivLo = ta.pivotlow(low,  swingLen, swingLen)

var float topLevel  = na
var float btmLevel  = na
var int   topBar    = na
var int   btmBar    = na
var bool  topBroken = false
var bool  btmBroken = false

if not na(pivHi)
    topLevel  := pivHi
    topBar    := bar_index - swingLen
    topBroken := false

if not na(pivLo)
    btmLevel  := pivLo
    btmBar    := bar_index - swingLen
    btmBroken := false

// ─── STRUCTURE BREAK DETECTION ─────────────────────────────────────────────────
var int structureBias = 0  // -1 bearish, 0 neutral, 1 bullish
var int bosCount      = 0
var int chochCount    = 0

bullBreak = not na(topLevel) and close > topLevel and not topBroken and barstate.isconfirmed
bearBreak = not na(btmLevel) and close < btmLevel and not btmBroken and barstate.isconfirmed

chochBull = false
chochBear = false
bosBull   = false
bosBear   = false

var float breakLevel = na
var int   breakFrom  = na

if bullBreak
    topBroken  := true
    breakLevel := topLevel
    breakFrom  := topBar
    if structureBias <= 0
        chochBull     := true
        structureBias := 1
        chochCount    += 1
    else
        bosBull  := true
        bosCount += 1

if bearBreak
    btmBroken  := true
    breakLevel := btmLevel
    breakFrom  := btmBar
    if structureBias >= 0
        chochBear     := true
        structureBias := -1
        chochCount    += 1
    else
        bosBear  := true
        bosCount += 1

// ─── STRUCTURE LINES WITH LABELS ───────────────────────────────────────────────
// CHoCH = Change of Character (regime flip) — labeled larger, dashed line
// BOS   = Break of Structure (trend continuation) — labeled smaller, solid line

if showStructLn and chochBull and not na(breakFrom)
    line.new(breakFrom, breakLevel, bar_index, breakLevel,
         color=color.new(#0097A7, 20), style=line.style_dashed, width=2)
    label.new(bar_index, breakLevel, "CHoCH  +",
         style=label.style_label_left, color=color.new(#0097A7, 40),
         textcolor=color.white, size=size.small)

if showStructLn and chochBear and not na(breakFrom)
    line.new(breakFrom, breakLevel, bar_index, breakLevel,
         color=color.new(#E65100, 20), style=line.style_dashed, width=2)
    label.new(bar_index, breakLevel, "CHoCH  -",
         style=label.style_label_left, color=color.new(#E65100, 40),
         textcolor=color.white, size=size.small)

if showStructLn and bosBull and not na(breakFrom)
    line.new(breakFrom, breakLevel, bar_index, breakLevel,
         color=color.new(#0097A7, 35), style=line.style_solid, width=1)
    label.new(bar_index, breakLevel, "BOS  +",
         style=label.style_label_left, color=color.new(#0097A7, 60),
         textcolor=color.white, size=size.tiny)

if showStructLn and bosBear and not na(breakFrom)
    line.new(breakFrom, breakLevel, bar_index, breakLevel,
         color=color.new(#E65100, 35), style=line.style_solid, width=1)
    label.new(bar_index, breakLevel, "BOS  -",
         style=label.style_label_left, color=color.new(#E65100, 60),
         textcolor=color.white, size=size.tiny)

// ─── VOLATILITY STATE ──────────────────────────────────────────────────────────
isLowVol = not na(atr) and not na(atrMA) and atrMA > 0 and atr < atrMA * volContThres

// ─── MOMENTUM ALIGNMENT ───────────────────────────────────────────────────────
roc       = close - close[momentumLen]
rocSmooth = ta.ema(roc, momentumLen)
momBull   = rocSmooth > 0
momBear   = rocSmooth < 0

// ─── REGIME CLASSIFICATION ─────────────────────────────────────────────────────
var int regime = 0  // -1 = bear, 0 = range/neutral, 1 = bull

if isLowVol
    regime := 0
else if structureBias == 1 and momBull
    regime := 1
else if structureBias == -1 and momBear
    regime := -1
else
    regime := 0

// ─── REGIME BACKGROUND ────────────────────────────────────────────────────────
regimeCol = regime == 1 ? bullTint : regime == -1 ? bearTint : rangeTint
bgcolor(showRegimeBg ? regimeCol : na, title="Regime Shading")

// ─── RUNNING EXTREMES ──────────────────────────────────────────────────────────
var float extMax = na
var float extMin = na

if chochBull or chochBear
    extMax := high
    extMin := low

if na(extMax) or high > extMax
    extMax := high
if na(extMin) or low < extMin
    extMin := low

// ─── EVENT TRACKING ────────────────────────────────────────────────────────────
var int    lastStructBar  = na
var int    lastStructDir  = 0
var string lastStructType = ""

if bosBull or chochBull
    lastStructBar  := bar_index
    lastStructDir  := 1
    lastStructType := bosBull ? "BOS" : "CHoCH"
if bosBear or chochBear
    lastStructBar  := bar_index
    lastStructDir  := -1
    lastStructType := bosBear ? "BOS" : "CHoCH"

// ─── SWING LEVEL EXTENSION LINES ───────────────────────────────────────────────
// Extends the most recent swing high and low as a dotted price-level line
// to the current bar with a price label on the right edge.
var line  swingHiLine = na
var line  swingLoLine = na
var label swingHiLbl  = na
var label swingLoLbl  = na

if barstate.islast and showSwingExt
    line.delete(swingHiLine)
    line.delete(swingLoLine)
    label.delete(swingHiLbl)
    label.delete(swingLoLbl)

    if not na(topLevel) and not na(topBar) and not topBroken
        swingHiLine := line.new(topBar, topLevel, bar_index + 4, topLevel,
             color=color.new(#E65100, 45), style=line.style_dotted, width=2,
             extend=extend.none)
        swingHiLbl := label.new(bar_index + 4, topLevel,
             "H  " + str.tostring(topLevel, format.mintick),
             style=label.style_label_right, color=color.new(#1A0A00, 20),
             textcolor=color.new(#E65100, 0), size=size.tiny)

    if not na(btmLevel) and not na(btmBar) and not btmBroken
        swingLoLine := line.new(btmBar, btmLevel, bar_index + 4, btmLevel,
             color=color.new(#0097A7, 45), style=line.style_dotted, width=2,
             extend=extend.none)
        swingLoLbl := label.new(bar_index + 4, btmLevel,
             "L  " + str.tostring(btmLevel, format.mintick),
             style=label.style_label_right, color=color.new(#00070A, 20),
             textcolor=color.new(#0097A7, 0), size=size.tiny)

// ─── DASHBOARD ─────────────────────────────────────────────────────────────────
var table dash = table.new(position.top_right, 2, 15,
     bgcolor=color.new(#0D1117, 5),
     border_color=color.new(#1A2332, 0),
     border_width=1,
     frame_color=color.new(#0097A7, 40),
     frame_width=1)

if barstate.islast and showDash
    color DARK_BG = color.new(#0D1117, 0)
    color SEP_BG  = color.new(#080D13, 0)
    color LBL_C   = color.new(#546E7A, 0)
    color DIM_C   = color.new(#1E2A38, 0)

    // Confidence score: 1 point per aligned factor
    int confScore = (structureBias != 0 ? 1 : 0) + (not isLowVol ? 1 : 0) + ((momBull or momBear) ? 1 : 0)
    color confC = confScore == 3 ? color.new(#0097A7, 0) : confScore == 2 ? color.new(#FFB300, 0) : color.new(#E65100, 0)

    color  regC2  = regime == 1 ? color.new(#0097A7, 0) : regime == -1 ? color.new(#E65100, 0) : color.new(#546E7A, 0)
    string regStr = regime == 1 ? "BULLISH" : regime == -1 ? "BEARISH" : "RANGING"

    color  biasC   = structureBias == 1 ? color.new(#0097A7, 0) : structureBias == -1 ? color.new(#E65100, 0) : color.new(#546E7A, 0)
    string biasStr = structureBias == 1 ? "BULLISH" : structureBias == -1 ? "BEARISH" : "NEUTRAL"

    color  volC   = isLowVol ? color.new(#546E7A, 0) : color.new(#78909C, 0)
    string volStr = isLowVol ? "CONTRACTED" : "EXPANDING"

    color  momC   = momBull ? color.new(#0097A7, 0) : momBear ? color.new(#E65100, 0) : color.new(#546E7A, 0)
    string momStr = momBull ? "POSITIVE" : momBear ? "NEGATIVE" : "FLAT"

    string evStr = not na(lastStructBar)
         ? (lastStructType + (lastStructDir == 1 ? "  +" : "  -") + "  " + str.tostring(bar_index - lastStructBar) + "b")
         : "None"

    string swHStr = not na(topLevel)  ? str.tostring(topLevel, format.mintick)  : "---"
    string swLStr = not na(btmLevel)  ? str.tostring(btmLevel, format.mintick)  : "---"

    // Row 0: Header
    table.cell(dash, 0, 0, "PHASE DETECTOR", text_color=color.new(#ECEFF1, 0), text_size=size.small,
         bgcolor=DARK_BG, text_halign=text.align_left)
    table.cell(dash, 1, 0, "[JOAT]",        text_color=color.new(#0097A7, 0), text_size=size.tiny,
         bgcolor=DARK_BG, text_halign=text.align_right)

    // Row 1: Separator
    table.cell(dash, 0, 1, "", bgcolor=SEP_BG, text_size=size.tiny)
    table.cell(dash, 1, 1, "", bgcolor=SEP_BG, text_size=size.tiny)

    // Row 2: Regime
    table.cell(dash, 0, 2, "Regime",  text_color=LBL_C,  text_size=size.small,
         bgcolor=DARK_BG, text_halign=text.align_left)
    table.cell(dash, 1, 2, regStr,    text_color=regC2,  text_size=size.normal,
         bgcolor=DARK_BG, text_halign=text.align_right)

    // Row 3: Confidence
    table.cell(dash, 0, 3, "Confidence",  text_color=LBL_C,  text_size=size.tiny,
         bgcolor=DARK_BG, text_halign=text.align_left)
    table.cell(dash, 1, 3, str.tostring(confScore) + " / 3 factors", text_color=confC,  text_size=size.small,
         bgcolor=DARK_BG, text_halign=text.align_right)

    // Row 4: Separator
    table.cell(dash, 0, 4, "", bgcolor=SEP_BG, text_size=size.tiny)
    table.cell(dash, 1, 4, "", bgcolor=SEP_BG, text_size=size.tiny)

    // Row 5: Structure Bias
    table.cell(dash, 0, 5, "Structure",  text_color=LBL_C,   text_size=size.tiny,
         bgcolor=DARK_BG, text_halign=text.align_left)
    table.cell(dash, 1, 5, biasStr,      text_color=biasC,   text_size=size.small,
         bgcolor=DARK_BG, text_halign=text.align_right)

    // Row 6: Last Event
    table.cell(dash, 0, 6, "Last Break", text_color=LBL_C,               text_size=size.tiny,
         bgcolor=DARK_BG, text_halign=text.align_left)
    table.cell(dash, 1, 6, evStr,        text_color=color.new(#78909C, 0), text_size=size.tiny,
         bgcolor=DARK_BG, text_halign=text.align_right)

    // Row 7: BOS / CHoCH counts
    table.cell(dash, 0, 7, "BOS / CHoCH",  text_color=LBL_C,               text_size=size.tiny,
         bgcolor=DARK_BG, text_halign=text.align_left)
    table.cell(dash, 1, 7, str.tostring(bosCount) + " / " + str.tostring(chochCount),
         text_color=color.new(#78909C, 0), text_size=size.tiny,
         bgcolor=DARK_BG, text_halign=text.align_right)

    // Row 8: Separator
    table.cell(dash, 0, 8, "", bgcolor=SEP_BG, text_size=size.tiny)
    table.cell(dash, 1, 8, "", bgcolor=SEP_BG, text_size=size.tiny)

    // Row 9: Volatility
    table.cell(dash, 0, 9, "Volatility",  text_color=LBL_C,  text_size=size.tiny,
         bgcolor=DARK_BG, text_halign=text.align_left)
    table.cell(dash, 1, 9, volStr,        text_color=volC,   text_size=size.small,
         bgcolor=DARK_BG, text_halign=text.align_right)

    // Row 10: Momentum
    table.cell(dash, 0, 10, "Momentum",  text_color=LBL_C,  text_size=size.tiny,
         bgcolor=DARK_BG, text_halign=text.align_left)
    table.cell(dash, 1, 10, momStr,      text_color=momC,   text_size=size.small,
         bgcolor=DARK_BG, text_halign=text.align_right)

    // Row 11: Separator
    table.cell(dash, 0, 11, "", bgcolor=SEP_BG, text_size=size.tiny)
    table.cell(dash, 1, 11, "", bgcolor=SEP_BG, text_size=size.tiny)

    // Row 12: ATR
    table.cell(dash, 0, 12, "ATR (" + str.tostring(atrPeriod) + ")",
         text_color=LBL_C,               text_size=size.tiny,
         bgcolor=DARK_BG, text_halign=text.align_left)
    table.cell(dash, 1, 12, str.tostring(atr, format.mintick),
         text_color=color.new(#78909C, 0), text_size=size.tiny,
         bgcolor=DARK_BG, text_halign=text.align_right)

    // Row 13: Swing High
    table.cell(dash, 0, 13, "Swing High",  text_color=LBL_C,               text_size=size.tiny,
         bgcolor=DARK_BG, text_halign=text.align_left)
    table.cell(dash, 1, 13, swHStr,        text_color=color.new(#E65100, 0), text_size=size.tiny,
         bgcolor=DARK_BG, text_halign=text.align_right)

    // Row 14: Swing Low
    table.cell(dash, 0, 14, "Swing Low",   text_color=LBL_C,               text_size=size.tiny,
         bgcolor=DARK_BG, text_halign=text.align_left)
    table.cell(dash, 1, 14, swLStr,        text_color=color.new(#0097A7, 0), text_size=size.tiny,
         bgcolor=DARK_BG, text_halign=text.align_right)

// ─── ALERTS ────────────────────────────────────────────────────────────────────
alertcondition(chochBull, "Bullish CHoCH",    "Market Phase Detector: Bullish Change of Character")
alertcondition(chochBear, "Bearish CHoCH",    "Market Phase Detector: Bearish Change of Character")
alertcondition(bosBull,   "Bullish BOS",      "Market Phase Detector: Bullish Break of Structure")
alertcondition(bosBear,   "Bearish BOS",      "Market Phase Detector: Bearish Break of Structure")
alertcondition(regime == 1  and regime[1] != 1,  "Regime Shift — Bullish", "Market Phase Detector: Regime shifted to BULLISH")
alertcondition(regime == -1 and regime[1] != -1, "Regime Shift — Bearish", "Market Phase Detector: Regime shifted to BEARISH")
alertcondition(regime == 0  and regime[1] != 0,  "Regime Shift — Ranging", "Market Phase Detector: Regime entered RANGING")
````
