# Regime & Structure Engine [JOAT]

- url: https://www.tradingview.com/script/4UySCUCo-Regime-Structure-Engine-JOAT/
- type: indicator
- pine_id: PUB;5349394e6078441a985eb01ce65fd768
- version: 1.0

## Description

[b]Regime & Structure Engine [JOAT][/b]

[b]Introduction[/b]

Markets do not move randomly — they cycle through defined behavioral states: trending phases where momentum compounds in one direction, and ranging phases where price consolidates before the next impulse. Identifying which state the market is currently in, and detecting when structural breaks signal a transition, is fundamental to any disciplined trading approach. The Regime & Structure Engine [JOAT] is built around that single core principle: before anything else, know your regime.

This indicator unifies three distinct analytical layers into a single overlay system. The first layer is the Hull-EMA Hybrid (HEMA), a custom moving average that resolves the trade-off between smoothness and responsiveness by combining double-weighted EMA calculation with a square-root length final smoothing. The second layer is a three-state confirmed regime engine that uses the relative alignment of three HEMA periods to classify market condition as bull, bear, or neutral — with a mandatory two-bar confirmation to eliminate false transitions. The third layer is a market structure engine based on classical swing pivot logic, capable of identifying Break of Structure (BOS) and Change of Character (CHoCH) events that signal genuine momentum shifts.

All of this is augmented by a Z-score cumulative impulse detector that quantifies the statistical significance of directional momentum streaks, a trend cloud that visually represents regime state through gradient fills, proximity-based bar coloring that encodes distance from the HEMA mid-layer, a configurable alert system, and a compact six-row dashboard. Every signal in this indicator is anchored to confirmed bars only, eliminating any look-ahead repainting.

[image]https://www.tradingview.com/x/Udc37cMY/[/image]

[b]Core Concepts[/b]

[b]1. Hull-EMA Hybrid (HEMA) Moving Average[/b]

The foundational calculation of this indicator is the HEMA — a three-step smoothing function that delivers both noise reduction and lag compensation. A standard EMA applies uniform smoothing that creates meaningful lag on higher periods. Hull Moving Averages address lag through weighted differencing but can produce jagged outputs. The HEMA bridges this by constructing the Hull-style weighted difference first, then applying a square-root-period EMA as the final smoother.

[pine]
f_hema(src, len) =>
    ta.ema(2 * ta.ema(src, len / 2) - ta.ema(src, len), math.round(math.sqrt(len)))
[/pine]

Three instances are calculated at lengths 20, 50, and 100, producing a fast, slow, and macro trend layer respectively. The fast layer reacts to short-term price action, the slow layer represents the primary trend, and the macro layer anchors the broader structural bias. When all three are aligned in sequence (fast above slow above macro, or inverse), the trend is considered directionally clean.

[b]2. Three-State Confirmed Regime Engine[/b]

Regime classification is determined by the ordinal alignment of all three HEMA layers. A raw bull signal requires hema1 greater than hema2, which must in turn be greater than hema3. The inverse defines raw bear. Any other arrangement is classified as neutral. To prevent rapid regime flipping on borderline conditions, a two-bar confirmation requirement is enforced: the raw signal must hold for at least two consecutive bars before the confirmed regime variable updates.

[pine]
rawBull = hema1 > hema2 and hema2 > hema3
rawBear = hema1 < hema2 and hema2 < hema3

var int confirmCount = 0
var int confirmedRegime = 0

if rawBull
    confirmCount := confirmCount + 1
else if rawBear
    confirmCount := confirmCount - 1
else
    confirmCount := 0

confirmedRegime := confirmCount >= 2 ? 1 : confirmCount <= -2 ? -1 : 0
[/pine]

This confirmation mechanism is critical in volatile markets where HEMA layers can briefly reorder on a single candle only to revert immediately. The two-bar requirement sacrifices minimal reaction speed in exchange for a meaningful reduction in false regime transitions.

[b]3. Z-Score Cumulative Impulse Detection[/b]

Regime direction tells you the structural bias. The Z-score impulse system tells you when that bias is being expressed with statistical force. Rather than measuring a single bar's momentum, this system accumulates consecutive directional closes into a running streak — a cumulative bull or bear pressure counter — then normalizes that streak against its own historical mean and standard deviation.

[pine]
cumBull = close > close[1] ? nz(cumBull[1]) + (close - close[1]) : 0
cumBear = close < close[1] ? nz(cumBear[1]) + (close[1] - close) : 0

zBull = (cumBull - ta.sma(cumBull, zLen)) / ta.stdev(cumBull, zLen)
zBear = (cumBear - ta.sma(cumBear, zLen)) / ta.stdev(cumBear, zLen)

impulseUp = ta.crossover(zBull, zThresh) and barstate.isconfirmed
impulseDn = ta.crossover(zBear, zThresh) and barstate.isconfirmed
[/pine]

An impulse fires when the Z-score exceeds the user-defined threshold (default: 2.0 sigma). This ensures that only statistically unusual momentum streaks generate signals, filtering out the ordinary ebb and flow of price during low-conviction moves.

[b]4. BOS and CHoCH Market Structure[/b]

Market structure tracking is built on classical pivot high/low detection using Pine Script's built-in ta.pivothigh and ta.pivotlow functions. A Break of Structure (BOS) occurs when price closes or wicks beyond the most recent swing high (bullish BOS) or swing low (bearish BOS). A Change of Character (CHoCH) is a BOS that opposes the direction of the prior BOS — indicating a potential regime reversal rather than continuation.

[pine]
swingHigh = ta.pivothigh(high, swingLen, swingLen)
swingLow = ta.pivotlow(low, swingLen, swingLen)

lastSwingHigh = ta.valuewhen(not na(swingHigh), swingHigh, 0)
lastSwingLow = ta.valuewhen(not na(swingLow), swingLow, 0)

bosUp = barstate.isconfirmed and ta.crossover(close, lastSwingHigh)
bosDn = barstate.isconfirmed and ta.crossunder(close, lastSwingLow)

chochUp = bosUp and lastBOSDir == -1
chochDn = bosDn and lastBOSDir == 1
[/pine]

CHoCH events are particularly significant because they represent the market's first structural evidence of a trend change — not merely a continuation of prior momentum. Distinguishing BOS from CHoCH allows traders to calibrate their response: a BOS in trend direction is a continuation entry opportunity, while a CHoCH warrants reassessment of existing positions.

[b]5. Trend Cloud and Proximity Bar Coloring[/b]

The trend cloud fills the space between the HEMA fast and slow layers. The fill color matches the confirmed regime — teal for bull, red for bear, gray for neutral — creating an immediate visual encoding of market state across the chart. Bar coloring is driven by a normalized proximity calculation using the 14-period ATR as a reference distance.

[pine]
normProx = math.abs(close - hema2) / (atr14 * 3)
barAlpha = math.min(math.round(normProx * 200), 200)
[/pine]

Bars that are far from the HEMA slow layer receive more saturated coloring, while bars trading near the HEMA mid-line are rendered at reduced opacity. This creates an intuitive gradient where extreme dislocations are visually prominent.

[b]Features[/b]

[list]
[*][b]HEMA Triple Layer:[/b] Three independent Hull-EMA Hybrid instances at periods 20, 50, and 100 provide fast, primary, and macro trend context simultaneously.
[*][b]Confirmed Regime State:[/b] Two-bar confirmation gate prevents false regime transitions on temporary HEMA crossovers, reducing noise on volatile instruments.
[*][b]BOS Detection:[/b] Swing-based Break of Structure signals on both bullish and bearish side, drawn at confirmed bars only with no look-ahead.
[*][b]CHoCH Detection:[/b] Change of Character identification when BOS direction opposes the prior structural break, highlighting potential trend reversal zones.
[*][b]Z-Score Impulse:[/b] Statistically normalized cumulative momentum streaks that fire signals only when directional pressure reaches a configurable sigma threshold.
[*][b]Gradient Trend Cloud:[/b] Dynamic fill between HEMA layers color-coded by regime for instant visual orientation on any timeframe.
[*][b]Proximity Bar Coloring:[/b] ATR-normalized distance from HEMA mid controls bar color alpha, making dislocations visually distinct.
[*][b]Six-Row Dashboard:[/b] Compact table displaying regime, last BOS direction, bull Z-score, bear Z-score, and HEMA layer alignment.
[*][b]No Repainting:[/b] All signals gated behind barstate.isconfirmed — no signals are printed on unfinished bars.
[*][b]Full Alert Coverage:[/b] Seven alert conditions covering BOS, CHoCH, impulse, and regime flip events.
[/list]

[b]Input Parameters[/b]

[b]HEMA Settings:[/b]
[list]
[*]Fast Length: Period for the HEMA fast layer (default: 20)
[*]Slow Length: Period for the HEMA slow layer (default: 50)
[*]Macro Length: Period for the HEMA macro layer (default: 100)
[*]Source: Price source for all HEMA calculations (default: close)
[/list]

[b]Regime Settings:[/b]
[list]
[*]Confirmation Bars: Number of consecutive bars required to confirm a regime change (default: 2)
[/list]

[b]Structure Settings:[/b]
[list]
[*]Swing Length: Pivot lookback for swing high/low detection (default: 10)
[*]Show BOS Labels: Toggle BOS annotation labels on the chart (default: true)
[*]Show CHoCH Labels: Toggle CHoCH annotation labels on the chart (default: true)
[/list]

[b]Z-Score Settings:[/b]
[list]
[*]Z Lookback: Rolling window for Z-score mean and standard deviation (default: 50)
[*]Z Threshold: Sigma level required to fire an impulse signal (default: 2.0)
[/list]

[b]Display Settings:[/b]
[list]
[*]Show Trend Cloud: Toggle the gradient fill between HEMA layers (default: true)
[*]Show Bar Colors: Toggle proximity-based bar coloring (default: true)
[*]Show Dashboard: Toggle the six-row information table (default: true)
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Establish Regime Context[/b]

Before analyzing any signal, check the dashboard and the trend cloud to identify the confirmed regime. A bull regime (all three HEMA layers in ascending order with a teal cloud) means the structural bias favors long positions. A bear regime (descending alignment with a red cloud) favors shorts. A neutral regime suggests consolidation — reduce position sizing or stand aside. The regime confirmation requirement means the dashboard will update one to two bars after alignment begins, giving you a cleaner entry rather than reacting to the first crossover.

[b]Step 2: Wait for Structure to Break[/b]

Within the context of the confirmed regime, watch for BOS events in the trend direction. A bullish BOS during a bull regime is a continuation structure signal — it means price has broken above a prior swing high, suggesting the up-trend is extending. A bearish BOS during a bull regime, especially if classified as a CHoCH, is your first warning that the structure may be shifting. Use the BOS labels on the chart to track the sequence of structural breaks over time.

[b]Step 3: Confirm with Z-Score Impulse[/b]

A BOS or CHoCH becomes significantly more actionable when accompanied by a Z-score impulse signal in the same direction. When the cumulative bull streak normalized to 2+ sigma fires at the same time as or immediately following a bullish BOS, the move is backed by sustained directional momentum — not a single large candle. When regime, structure, and impulse all align, the signal quality is at its highest.

[b]Step 4: Manage Position with HEMA Proximity[/b]

Once in a position, the proximity bar coloring helps manage exits. Bars that are far from HEMA mid (highly saturated) represent extended conditions — areas where mean reversion risk is elevated. Bars near HEMA mid are in equilibrium. Exits on strength (closing during a high-saturation bullish bar after a BOS continuation trade) allow for locking in gains at points of extension rather than waiting for a reversal to develop.

[image]https://www.tradingview.com/x/hND2uGu6/[/image]

[b]Indicator Limitations[/b]

[list]
[*]The two-bar regime confirmation introduces a brief delay relative to the actual HEMA crossover. On fast-moving instruments, this can mean a slightly later entry but provides meaningful protection against false transitions.
[*]BOS detection is based on prior swing highs and lows defined by the swing length parameter. On very low swing length settings, minor highs and lows will be used as structure levels, potentially generating frequent BOS events of less structural significance.
[*]Z-score impulse requires a sufficient lookback to establish a stable mean and standard deviation for the cumulative streak. In the first Z-lookback bars of any chart, signals may be less statistically reliable as the normalization period is not fully seeded.
[*]The HEMA and all derivative signals are calculated on the chart's native timeframe. This indicator does not internally pull higher timeframe data — users who want multi-timeframe regime context should reference signals from higher timeframe chart instances.
[*]Like all trend-following tools, this indicator will produce whipsaw signals in choppy, range-bound markets where neither bulls nor bears sustain momentum long enough to trigger clean regime confirmation.
[*]Proximity bar coloring uses ATR as a normalizer. During volatility regime shifts (e.g., sudden spike in ATR), the alpha thresholds may temporarily misrepresent proximity distance.
[/list]

[b]Originality Statement[/b]

The Regime & Structure Engine is not a repackaging of any single existing indicator. It is a purpose-built synthesis of methodologies that individually exist in various forms but have not been combined in this specific architecture.

[list]
[*]The HEMA function (Hull-inspired double-weighted EMA followed by square-root-period smoothing) is a custom construction that differs from both standard HMA and standard EMA in its layering approach and final smoothing step.
[*]The three-state confirmed regime engine with mandatory multi-bar confirmation is an original state machine design. Most indicators display regime as a simple crossover condition; this system enforces a holding period before state transition.
[*]The Z-score cumulative impulse system measures the statistical significance of a directional streak rather than the magnitude of a single bar move. This normalization approach — accumulating consecutive closes and comparing against rolling sma/stdev — is not a standard oscillator pattern.
[*]The combination of HEMA-based regime with classical BOS/CHoCH structural analysis on top of Z-score momentum creates a three-dimensional signal framework that no single publicly available indicator replicates.
[*]The proximity bar coloring system using ATR-normalized distance to the HEMA mid layer as the alpha channel driver is an original visual encoding not found in standard bar coloring implementations.
[/list]

[b]Disclaimer[/b]

The Regime & Structure Engine [JOAT] is provided for educational and informational purposes only. It is a technical analysis tool and does not constitute financial advice. Past behavior of price relative to indicator signals does not guarantee future results. All trading involves risk, including the potential loss of principal. Users are solely responsible for their own trading decisions. Always conduct your own due diligence and consider consulting a licensed financial professional before making any investment decisions.

-Made with passion by officialjackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Regime & Structure Engine [JOAT]", shorttitle="RSE [JOAT]", overlay=true,
          max_lines_count=500, max_labels_count=500, max_boxes_count=500,
          explicit_plot_zorder=true)

// ══════════════════════════════════════════════════════════════════
// INPUTS
// ══════════════════════════════════════════════════════════════════
grpHema   = "HEMA Trend Engine"
hLen1     = input.int(20,  "Fast HEMA Length",   group=grpHema, minval=2)
hLen2     = input.int(50,  "Slow HEMA Length",   group=grpHema, minval=4)
hLen3     = input.int(100, "Macro HEMA Length",  group=grpHema, minval=8)

grpMS     = "Market Structure"
swingLen  = input.int(20, "Swing Detection Window", group=grpMS, minval=5, maxval=100,
            tooltip="Pivot lookback. Larger = fewer but more significant swings.")
bosType   = input.string("Close", "BOS Confirmation", options=["Close","Wick"], group=grpMS)
showChoch = input.bool(true, "Display CHoCH Labels", group=grpMS)

grpZ      = "Impulse Filter"
zLen      = input.int(50, "Z-Score Lookback", group=grpZ, minval=10)
zThresh   = input.float(3.0, "Impulse Threshold (σ)", group=grpZ, minval=1.0, step=0.5)

grpVis    = "Appearance"
bullCol   = input.color(#00e5aa, "Bullish Color",  group=grpVis)
bearCol   = input.color(#ff3366, "Bearish Color",  group=grpVis)
neutCol   = input.color(#8888aa, "Neutral Color",  group=grpVis)
showCloud = input.bool(true,  "Show HEMA Trend Cloud", group=grpVis)
showBars  = input.bool(true,  "Custom Bar Color",      group=grpVis)
showDash  = input.bool(true,  "Show Dashboard",        group=grpVis)
dashPos   = input.string("top_right","Dashboard Position",
              options=["top_right","top_left","bottom_right","bottom_left"], group=grpVis)

// ══════════════════════════════════════════════════════════════════
// HEMA FUNCTION (Hull-EMA hybrid — reduced lag, smooth output)
// ══════════════════════════════════════════════════════════════════
f_hema(_src, _len) =>
    h = math.max(1, math.round(_len / 2))
    s = math.max(1, math.round(math.sqrt(_len)))
    ta.ema(2 * ta.ema(_src, h) - ta.ema(_src, _len), s)

hema1 = f_hema(close, hLen1)  // Fast — signal sensitivity
hema2 = f_hema(close, hLen2)  // Slow — trend backbone
hema3 = f_hema(close, hLen3)  // Macro — regime context

// ══════════════════════════════════════════════════════════════════
// TREND REGIME — Three-state (Bull / Bear / Neutral)
// ══════════════════════════════════════════════════════════════════
var int regime = 0
regime := hema1 > hema2 and hema2 > hema3 ? 1 :
          hema1 < hema2 and hema2 < hema3 ? -1 : 0

// Smooth regime transitions: require confirmation across two bars
var int confirmedRegime = 0
confirmedRegime := regime == regime[1] ? regime : nz(confirmedRegime[1])

// ══════════════════════════════════════════════════════════════════
// Z-SCORE IMPULSE DETECTION (momentum surge filter)
// ══════════════════════════════════════════════════════════════════
bullImpulse = close > open ? close - open : 0.0
bearImpulse = close < open ? open - close : 0.0

// Cumulative streak
var float cumBull = 0.0
var float cumBear = 0.0
cumBull := close > open ? nz(cumBull[1]) + bullImpulse : 0.0
cumBear := close < open ? nz(cumBear[1]) + bearImpulse : 0.0

zBull = (cumBull - ta.sma(cumBull, zLen)) / math.max(ta.stdev(cumBull, zLen), 1e-10)
zBear = (cumBear - ta.sma(cumBear, zLen)) / math.max(ta.stdev(cumBear, zLen), 1e-10)

impulseUp   = ta.crossover(zBull, zThresh)  and barstate.isconfirmed
impulseDn   = ta.crossover(zBear, zThresh)  and barstate.isconfirmed

// ══════════════════════════════════════════════════════════════════
// MARKET STRUCTURE — BOS / CHoCH ENGINE
// ══════════════════════════════════════════════════════════════════
pivHi = ta.pivothigh(high, swingLen, swingLen)
pivLo = ta.pivotlow(low,  swingLen, swingLen)

var float prevSwingHigh     = na
var float prevSwingLow      = na
var int   prevSwingHighIdx  = na
var int   prevSwingLowIdx   = na
var bool  highActive        = false
var bool  lowActive         = false
var int   prevBosDir        = 0

if not na(pivHi)
    prevSwingHigh    := pivHi
    prevSwingHighIdx := bar_index - swingLen
    highActive       := true

if not na(pivLo)
    prevSwingLow    := pivLo
    prevSwingLowIdx := bar_index - swingLen
    lowActive       := true

confHi = bosType == "Close" ? close : high
confLo = bosType == "Close" ? close : low

bosUp   = highActive and confHi > prevSwingHigh and barstate.isconfirmed
bosDn   = lowActive  and confLo < prevSwingLow  and barstate.isconfirmed

if bosUp
    highActive := false
if bosDn
    lowActive  := false

chochUp = bosUp  and prevBosDir == -1
chochDn = bosDn  and prevBosDir ==  1

if bosUp
    prevBosDir := 1
if bosDn
    prevBosDir := -1

// BOS/CHoCH lines and labels
if bosUp and not na(prevSwingHighIdx)
    ln = line.new(prevSwingHighIdx, prevSwingHigh, bar_index, prevSwingHigh,
                  color=color.new(bullCol, 30), width=1, style=line.style_dashed)
    lbl = label.new(math.floor((prevSwingHighIdx + bar_index) / 2), prevSwingHigh,
                    (chochUp and showChoch) ? "CHoCH" : "BOS",
                    color=color.new(color.black, 100), textcolor=bullCol,
                    style=label.style_label_down, size=size.tiny)

if bosDn and not na(prevSwingLowIdx)
    ln = line.new(prevSwingLowIdx, prevSwingLow, bar_index, prevSwingLow,
                  color=color.new(bearCol, 30), width=1, style=line.style_dashed)
    lbl = label.new(math.floor((prevSwingLowIdx + bar_index) / 2), prevSwingLow,
                    (chochDn and showChoch) ? "CHoCH" : "BOS",
                    color=color.new(color.black, 100), textcolor=bearCol,
                    style=label.style_label_up, size=size.tiny)

// ══════════════════════════════════════════════════════════════════
// TREND CLOUD — gradient fill between fast and slow HEMA
// ══════════════════════════════════════════════════════════════════
cloudCol = confirmedRegime == 1  ? color.new(bullCol, 75) :
           confirmedRegime == -1 ? color.new(bearCol, 75) :
           color.new(neutCol, 85)

p_h1 = plot(hema1, "HEMA Fast", color=color.new(
            confirmedRegime == 1 ? bullCol : confirmedRegime == -1 ? bearCol : neutCol, 40),
            linewidth=1)
p_h2 = plot(hema2, "HEMA Slow", color=color.new(
            confirmedRegime == 1 ? bullCol : confirmedRegime == -1 ? bearCol : neutCol, 60),
            linewidth=2)
p_h3 = plot(hema3, "HEMA Macro", color=color.new(neutCol, 70), linewidth=1,
            style=plot.style_circles)

fill(p_h1, p_h2, color=showCloud ? cloudCol : na, title="Trend Cloud")

// ══════════════════════════════════════════════════════════════════
// BAR COLORING — proximity-aware + regime-based
// ══════════════════════════════════════════════════════════════════
atr14       = ta.atr(14)
normProx    = math.min(math.abs(close - hema2) / (atr14 * 3), 1.0)
barAlpha    = math.round(normProx * 60)

barCol = confirmedRegime == 1  ? color.new(bullCol, barAlpha) :
         confirmedRegime == -1 ? color.new(bearCol, barAlpha) :
         color.new(neutCol, 70)

barcolor(showBars ? barCol : na)

// ══════════════════════════════════════════════════════════════════
// IMPULSE MARKERS — subtle, non-cluttered
// ══════════════════════════════════════════════════════════════════
plotshape(impulseUp, "Bullish Impulse", shape.circle,
          location.belowbar, color.new(bullCol, 40), size=size.tiny)
plotshape(impulseDn, "Bearish Impulse", shape.circle,
          location.abovebar, color.new(bearCol, 40), size=size.tiny)

// ══════════════════════════════════════════════════════════════════
// DASHBOARD
// ══════════════════════════════════════════════════════════════════
dashPosConst = dashPos == "top_right"    ? position.top_right    :
               dashPos == "top_left"     ? position.top_left     :
               dashPos == "bottom_right" ? position.bottom_right :
               position.bottom_left

if barstate.islast and showDash
    var table dash = table.new(dashPosConst, 2, 6,
                               bgcolor=color.new(#0d0d1a, 10),
                               border_width=1,
                               border_color=color.new(color.white, 80),
                               frame_color=color.new(color.white, 70),
                               frame_width=1)

    regimeTxt  = confirmedRegime == 1 ? "BULL" : confirmedRegime == -1 ? "BEAR" : "NEUTRAL"
    regimeCol  = confirmedRegime == 1 ? bullCol : confirmedRegime == -1 ? bearCol : neutCol
    bosDirTxt  = prevBosDir == 1 ? "BULLISH" : prevBosDir == -1 ? "BEARISH" : "—"
    bosDirCol  = prevBosDir == 1 ? bullCol : prevBosDir == -1 ? bearCol : neutCol
    zBullTxt   = str.tostring(zBull, "#.##") + "σ"
    zBearTxt   = str.tostring(zBear, "#.##") + "σ"
    hAligned   = hema1 > hema2 and hema2 > hema3
    bAligned   = hema1 < hema2 and hema2 < hema3

    table.cell(dash, 0, 0, "JOAT · RSE",         text_color=color.new(color.white, 30),
               text_size=size.small, text_halign=text.align_center, bgcolor=color.new(#111130,0))
    table.cell(dash, 1, 0, "v1.0",                text_color=color.new(color.white, 60),
               text_size=size.tiny,  text_halign=text.align_center, bgcolor=color.new(#111130,0))

    table.cell(dash, 0, 1, "Regime",              text_color=color.new(color.white, 40), text_size=size.tiny)
    table.cell(dash, 1, 1, regimeTxt,             text_color=regimeCol,  text_size=size.tiny, text_halign=text.align_center)

    table.cell(dash, 0, 2, "Last BOS",            text_color=color.new(color.white, 40), text_size=size.tiny)
    table.cell(dash, 1, 2, bosDirTxt,             text_color=bosDirCol,  text_size=size.tiny, text_halign=text.align_center)

    table.cell(dash, 0, 3, "Bull Impulse Z",      text_color=color.new(color.white, 40), text_size=size.tiny)
    table.cell(dash, 1, 3, zBullTxt,              text_color=zBull > zThresh ? bullCol : color.new(color.white,50),
               text_size=size.tiny, text_halign=text.align_center)

    table.cell(dash, 0, 4, "Bear Impulse Z",      text_color=color.new(color.white, 40), text_size=size.tiny)
    table.cell(dash, 1, 4, zBearTxt,              text_color=zBear > zThresh ? bearCol : color.new(color.white,50),
               text_size=size.tiny, text_halign=text.align_center)

    table.cell(dash, 0, 5, "HEMA Alignment",      text_color=color.new(color.white, 40), text_size=size.tiny)
    table.cell(dash, 1, 5, hAligned ? "FULL BULL" : bAligned ? "FULL BEAR" : "MIXED",
               text_color=hAligned ? bullCol : bAligned ? bearCol : neutCol,
               text_size=size.tiny, text_halign=text.align_center)

// ══════════════════════════════════════════════════════════════════
// ALERTS
// ══════════════════════════════════════════════════════════════════
alertcondition(bosUp,      "BOS Bullish",        "JOAT RSE: Bullish Break of Structure")
alertcondition(bosDn,      "BOS Bearish",        "JOAT RSE: Bearish Break of Structure")
alertcondition(chochUp,    "CHoCH Bullish",      "JOAT RSE: Bullish Change of Character")
alertcondition(chochDn,    "CHoCH Bearish",      "JOAT RSE: Bearish Change of Character")
alertcondition(impulseUp,  "Bull Impulse",       "JOAT RSE: Bullish Impulse Surge")
alertcondition(impulseDn,  "Bear Impulse",       "JOAT RSE: Bearish Impulse Surge")
alertcondition(confirmedRegime != confirmedRegime[1] and confirmedRegime == 1,  "Regime Bull", "JOAT RSE: Regime → Bullish")
alertcondition(confirmedRegime != confirmedRegime[1] and confirmedRegime == -1, "Regime Bear", "JOAT RSE: Regime → Bearish")
````
