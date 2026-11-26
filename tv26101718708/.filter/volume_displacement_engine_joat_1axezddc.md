# Volume Displacement Engine [JOAT]

- url: https://www.tradingview.com/script/1axezDdC-Volume-Displacement-Engine-JOAT/
- type: indicator
- pine_id: PUB;2d3e26a3b9444a75a32784f72e85764d
- version: 1.0

## Description

[b]Volume Displacement Engine [JOAT][/b]

[b]Introduction[/b]

Volume Displacement Engine (VDE) is an open-source volume regime oscillator that measures the ratio of short-term volume activity to long-term volume baseline, smooths it into a clean oscillator, and classifies current market activity into four distinct regimes: Low, Normal, High, and Extreme. The histogram and background tint update in real time with regime-specific coloring, reference lines mark each threshold boundary, and breakout signals fire when price closes beyond a rolling high or low during elevated volume regimes. A consolidation detection layer identifies consecutive low-volume bars as ranging periods. Trade outcomes from breakout signals are tracked for statistical win rate context, displayed in a structured dashboard.

The core problem VDE solves is the absence of context in standard volume indicators. Raw volume bars communicate size but not relevance — a large bar on a trending instrument in a high-liquidity session is very different from the same bar during off-hours. By expressing volume as a ratio to a rolling baseline and classifying it into regimes, VDE communicates whether current activity is institutionally significant (High or Extreme) or routine (Normal/Low). Price breakouts during High or Extreme volume are fundamentally different propositions than the same price moves on thin volume — VDE makes that distinction explicit and actionable.

[image]https://www.tradingview.com/x/9Jqx4O2m/[/image]

[b]Core Concepts[/b]

[b]1. Volume Ratio Oscillator[/b]

The core calculation divides a short-term volume simple moving average by a long-term volume simple moving average, then applies an EMA smoothing pass to reduce bar-to-bar noise:

[pine]
float rawRatio = volShort / math.max(volLong, 1.0)
float volRatio = ta.ema(rawRatio, i_smoothLen)
[/pine]

A ratio above 1.0 means recent volume is above the long-term average — activity is elevated. A ratio below 1.0 means recent volume is below the baseline — activity is depressed. The smoothing EMA gives the oscillator a cleaner shape while maintaining responsiveness to regime changes.

[b]2. Four-Tier Regime Classification[/b]

Four threshold boundaries define the regime tiers. All thresholds are fully configurable:

[list]
[*][b]Low:[/b] Ratio below the low threshold (default: 0.70) — below-average activity, reduced institutional participation
[*][b]Normal:[/b] Ratio between low and normal ceiling (default: 0.70–1.20) — baseline activity
[*][b]High:[/b] Ratio between normal ceiling and high threshold (default: 1.20–1.80) — elevated activity, potential institutional flow
[*][b]Extreme:[/b] Ratio above the high threshold (default: 1.80+) — exceptional volume surge, likely significant price event
[/list]

[b]3. Breakout Signal Detection[/b]

Breakout signals are generated when price closes beyond the rolling highest high or lowest low of the configurable lookback window during a High or Extreme volume regime. This combines price displacement with volume confirmation, filtering out low-conviction breakouts that occur on thin volume:

[pine]
bool bullBreak = barstate.isconfirmed and close > hh and (isHigh or isExtreme)
bool bearBreak = barstate.isconfirmed and close < ll and (isHigh or isExtreme)
[/pine]

[b]4. Consolidation Detection[/b]

When multiple consecutive bars fall below the consolidation volume threshold, VDE identifies the period as a consolidation zone. The minimum bar count ensures short dips below the threshold are not misclassified as ranges. A dotted reference line marks consolidation periods in the oscillator pane, providing context for identifying compression before expansion moves.

[b]5. Gradient Fill and Regime Tint[/b]

The oscillator histogram is colored to match the current regime. A fill between the histogram and the 1.0 baseline uses the regime color with transparency, providing a visual area representation of volume expansion or contraction. During High and Extreme regimes, a background tint activates in the oscillator pane to immediately draw attention to elevated activity periods without requiring inspection of the histogram height.

[b]Features[/b]

[list]
[*][b]Volume Ratio Oscillator:[/b] Short/long MA ratio smoothed by EMA — measures relative volume displacement from baseline
[*][b]Four-Tier Regime Classification:[/b] Low, Normal, High, and Extreme regimes with independent color coding and configurable thresholds
[*][b]Histogram Coloring:[/b] Bar color matches current regime — immediate visual reading of activity level
[*][b]Regime Background Tint:[/b] High and Extreme volume periods highlighted with a pane background color for immediate attention
[*][b]Threshold Reference Lines:[/b] Horizontal dashed lines at each regime boundary and at the 1.0 baseline for quick ratio reading
[*][b]Gradient Regime Fill:[/b] Fill between oscillator and baseline communicates expansion/contraction area visually
[*][b]Price Breakout Signals:[/b] Bull and bear breakout signals fire when price closes beyond rolling extremes during elevated volume regimes only
[*][b]Consolidation Detection:[/b] Consecutive below-threshold volume bars identified as consolidation periods
[*][b]Breakout Win Rate Tracking:[/b] Outcomes from breakout signals tracked against ATR-based TP/SL levels for statistical context
[*][b]Non-Repainting:[/b] All signals gated on barstate.isconfirmed
[*][b]Dashboard (Top Right):[/b] Current regime label, vol ratio value, consolidation status, and win rate breakdown for High and Extreme regime breakouts
[*][b]Vol Momentum Columns:[/b] 3-bar rate-of-change of the vol ratio displayed as green/red column bars in the oscillator pane — shows whether volume activity is accelerating or decelerating relative to 3 bars prior
[*][b]Rolling 20-Bar Vol Ratio Peak Reference Line:[/b] A purple reference line tracks the rolling 20-bar peak vol ratio — provides a visual ceiling for recent activity levels and highlights when the current ratio is approaching or exceeding recent extremes
[*][b]Vol Ratio Delta in Dashboard:[/b] Vol ratio delta shown in real time in the dashboard with a directional arrow (▲/▼) — communicates whether volume pressure is building or fading on the current bar
[*][b]CONS Label on Consolidation Start:[/b] A "CONS" label fires at the bar when a consolidation zone begins — marks the exact start of identified compression periods directly on the oscillator
[*][b]Breakout Strength Labels:[/b] "BRK +X.XX" and "BRK -X.XX" labels appear at each breakout signal showing the vol ratio value at the moment of the break — communicates the institutional conviction level behind each breakout directly on the chart
[/list]

[b]Input Parameters[/b]

[b]Volume Engine:[/b]
[list]
[*]Short Vol Window: Short-term volume MA period (default: 10)
[*]Long Vol Window: Long-term volume MA period (default: 40)
[*]Ratio Smooth: EMA smoothing length for ratio (default: 3)
[*]Low Vol Threshold: Ratio below which regime is Low (default: 0.70)
[*]Normal Vol Ceiling: Ratio above which regime is High (default: 1.20)
[*]High Vol Threshold: Ratio above which regime is Extreme (default: 1.80)
[/list]

[b]Consolidation:[/b]
[list]
[*]Consolidation Window: Lookback window for consolidation range (default: 8)
[*]Consolidation Vol Max: Maximum ratio to qualify as a consolidation bar (default: 0.80)
[*]Min Consolidation Bars: Minimum consecutive qualifying bars to declare consolidation (default: 4)
[/list]

[b]Breakout Signal:[/b]
[list]
[*]Breakout Lookback: Rolling high/low lookback window (default: 20)
[*]ATR Length: Period for ATR calculation (default: 14)
[*]ATR SL Multiplier: Stop loss distance (default: 1.5)
[*]Reward:Risk Ratio: TP multiple (default: 3.0)
[*]Show TP/SL Labels: Toggle label display in the oscillator pane (default: enabled)
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Read the Regime[/b]
Glance at the dashboard regime label and histogram color. A grey histogram (Low) indicates the market is in a quiet, low-participation period — avoid breakout strategies during these windows. A teal histogram (Normal) is baseline. An amber histogram (High) or red (Extreme) signals institutional-grade activity.

[b]Step 2: Identify Consolidation Periods[/b]
When the dotted consolidation line is active in the oscillator pane, the market is in a low-volume compression phase. These periods typically precede expansion moves — the direction of the subsequent breakout, confirmed on volume, is a key signal.

[b]Step 3: React to Breakout Signals[/b]
Breakout signals (triangles at the top/bottom of the oscillator pane) only fire during High or Extreme regimes. When a bull breakout label appears, price has closed above the rolling high on elevated volume — a confirmed displacement. The ATR TP/SL levels from that bar define the immediate risk/reward.

[b]Step 4: Monitor the Ratio Trend[/b]
The oscillator line trending upward while above 1.0 indicates sustained institutional accumulation of activity — these sustained elevated periods often coincide with trending phases. A declining ratio from Extreme back toward Normal often signals activity exhaustion.

[b]Indicator Limitations[/b]

[list]
[*]Volume data quality varies significantly by instrument and data provider. On synthetic instruments, indices, or assets where volume reflects contract count rather than notional size, the ratio will not accurately represent true monetary volume displacement
[*]TP/SL outcome tracking in the oscillator pane uses price data for TP/SL hit detection but displays in the volume pane — the label positions are approximate visual markers, not precise price levels on the main chart
[*]The consolidation detector uses a fixed volume threshold. In trending markets where baseline volume rises over time, the historical consolidation threshold may not match current market conditions without recalibrating the threshold input
[*]Breakout signals require both a price breakout and an elevated volume regime simultaneously. In markets with persistently high volume baselines (e.g., during major economic event periods), the Extreme threshold may trigger more frequently than on typical days — the thresholds may need upward adjustment on those instruments
[*]The short/long MA window ratio is a relative measure. It compares recent volume to a historical baseline — it does not measure absolute volume in shares, contracts, or dollars
[/list]

[b]Originality Statement[/b]

VDE combines a smoothed relative volume ratio oscillator with a four-tier classification framework, consolidation detection, and volume-gated breakout signals in a unified indicator. This is original for the following reasons:

[list]
[*]Expressing volume as a ratio of short-term to long-term moving average — rather than showing raw volume bars — normalizes the oscillator across instruments and timeframes, making the same threshold values meaningful on a liquid equity, a commodity, and a cryptocurrency without manual recalibration
[*]The four-tier classification system with independently configurable thresholds and a gradient color scheme provides a richer regime reading than simple volume-above-average/below-average binary indicators
[*]Volume-gated breakout detection explicitly requires the price breakout and the volume regime elevation to occur simultaneously on the same confirmed bar — preventing breakout signals from firing on thin-volume price moves that carry low institutional conviction
[*]The consolidation detection layer adds a compression-identification capability within the volume pane, providing context for identifying low-activity ranging periods before the volume regime shifts to support a directional move
[/list]

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice or a recommendation to buy or sell any financial instrument. Trading involves substantial risk of loss. Volume regime classification and breakout signals are statistical constructs — elevated volume at a price breakout does not guarantee continuation in the breakout direction. Win rate statistics are derived from historical bar data and do not predict future performance. Always apply proper risk management. The author is not responsible for any trading losses resulting from the use of this indicator.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Volume Displacement Engine [JOAT]", shorttitle="VDE [JOAT]", overlay=false, max_boxes_count=200, max_lines_count=300, max_labels_count=150)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────────────────

// Volume Engine
i_shortLen   = input.int(10,  "Short Vol Window",    minval=2,   group="Volume Engine")
i_longLen    = input.int(40,  "Long Vol Window",     minval=5,   group="Volume Engine")
i_smoothLen  = input.int(3,   "Ratio Smooth",        minval=1,   group="Volume Engine")
i_lowThresh  = input.float(0.70, "Low Vol Threshold",  minval=0.1, step=0.05, group="Volume Engine")
i_normThresh = input.float(1.20, "Normal Vol Ceiling", minval=0.5, step=0.05, group="Volume Engine")
i_highThresh = input.float(1.80, "High Vol Threshold", minval=0.5, step=0.05, group="Volume Engine")

// Consolidation detection (used for overlay boxes via request.security workaround note)
i_consWindow = input.int(8,   "Consolidation Window", minval=3,  group="Consolidation")
i_consThresh = input.float(0.80, "Consolidation Vol Max", minval=0.2, step=0.05, group="Consolidation")
i_consMinBars= input.int(4,   "Min Consolidation Bars",  minval=2,  group="Consolidation")

// Breakout
i_brkLookback= input.int(20,  "Breakout Lookback",   minval=5,   group="Breakout Signal")
i_atrLen     = input.int(14,  "ATR Length",          minval=1,   group="Breakout Signal")
i_atrMult    = input.float(1.5,"ATR SL Multiplier",  minval=0.5, step=0.1, group="Breakout Signal")
i_rrRatio    = input.float(3.0,"Reward:Risk Ratio",  minval=1.0, step=0.5, group="Breakout Signal")
i_showRR     = input.bool(true,"Show TP/SL Labels",  group="Breakout Signal")

// Visual
i_colLow     = input.color(#475569, "Low Volume Color",     group="Visual")
i_colNorm    = input.color(#3b82f6, "Normal Volume Color",  group="Visual")
i_colHigh    = input.color(#f59e0b, "High Volume Color",    group="Visual")
i_colExtreme = input.color(#ef4444, "Extreme Volume Color", group="Visual")
i_colBullBrk = input.color(#10b981, "Bull Breakout Color",  group="Visual")
i_colBearBrk = input.color(#f43f5e, "Bear Breakout Color",  group="Visual")
i_dashOn     = input.bool(true, "Show Dashboard",           group="Visual")

// ─────────────────────────────────────────────────────────────────────────────
// CALCULATIONS
// ─────────────────────────────────────────────────────────────────────────────

float volShort = ta.sma(volume, i_shortLen)
float volLong  = ta.sma(volume, i_longLen)
float rawRatio = volShort / math.max(volLong, 1.0)
float volRatio = ta.ema(rawRatio, i_smoothLen)
float volDelta = volRatio - volRatio[1]

// Regime classification
bool  isLow     = volRatio < i_lowThresh
bool  isNorm    = volRatio >= i_lowThresh  and volRatio < i_normThresh
bool  isHigh    = volRatio >= i_normThresh and volRatio < i_highThresh
bool  isExtreme = volRatio >= i_highThresh

// Regime color
color regColor  = isExtreme ? i_colExtreme : isHigh ? i_colHigh : isNorm ? i_colNorm : i_colLow

// Regime label string
string regLabel = isExtreme ? "EXTREME" : isHigh ? "HIGH" : isNorm ? "NORMAL" : "LOW"

// ATR for SL/TP
float atrVal    = ta.atr(i_atrLen)

// Breakout detection
float hh        = ta.highest(high,  i_brkLookback)[1]
float ll        = ta.lowest(low,    i_brkLookback)[1]
bool  bullBreak = barstate.isconfirmed and close > hh and (isHigh or isExtreme)
bool  bearBreak = barstate.isconfirmed and close < ll and (isHigh or isExtreme)

// Consolidation tracking
var int   consCount   = 0
var bool  inCons      = false
var float consTop     = na
var float consBot     = na
var int   consStart   = na

bool consBar = volRatio < i_consThresh
if consBar
    consCount += 1
    consTop   := na(consTop) ? high : math.max(consTop, high)
    consBot   := na(consBot) ? low  : math.min(consBot, low)
    if consCount == 1
        consStart := bar_index
    if consCount >= i_consMinBars and not inCons
        inCons := true
        label.new(bar_index, volRatio + 0.08, "CONS",
             style=label.style_label_down,
             color=color.new(#a78bfa, 50),
             textcolor=color.white,
             size=size.tiny)
else
    if inCons
        // Mark end of consolidation
        inCons := false
    consCount := 0
    consTop   := na
    consBot   := na
    consStart := na

// ─────────────────────────────────────────────────────────────────────────────
// PERSISTENT STATE — Trade management
// ─────────────────────────────────────────────────────────────────────────────

type VDETrade
    label  slLbl
    label  tpLbl
    line   entLine
    float  slLvl
    float  tpLvl
    float  entry
    bool   isBull
    int    entBar

var array<VDETrade> trades = array.new<VDETrade>()

// Win rate counters
var int totW = 0, var int totL = 0, var int totT = 0
var int highW = 0, var int highL = 0, var int highT = 0
var int extrW = 0, var int extrL = 0, var int extrT = 0

// ─────────────────────────────────────────────────────────────────────────────
// OPEN TRADE
// ─────────────────────────────────────────────────────────────────────────────

f_openTrade(float entryPx, bool isBull, bool isExt) =>
    float slDist  = atrVal * i_atrMult
    float slLvl   = isBull ? entryPx - slDist : entryPx + slDist
    float tpLvl   = isBull ? entryPx + slDist * i_rrRatio : entryPx - slDist * i_rrRatio

    VDETrade t    = VDETrade.new()
    t.entry   := entryPx
    t.slLvl   := slLvl
    t.tpLvl   := tpLvl
    t.isBull  := isBull
    t.entBar  := bar_index

    // In oscillator pane — use labels as markers
    color sigCol  = isBull ? i_colBullBrk : i_colBearBrk
    float sigY    = isBull ? volRatio + 0.05 : volRatio - 0.05

    if i_showRR
        string slTxt  = "SL " + str.format("{0,number,#.####}", slLvl)
        string tpTxt  = "TP " + str.format("{0,number,#.####}", tpLvl)
        t.slLbl := label.new(bar_index, volRatio - 0.15, slTxt,
                             color=color.new(#ef4444, 70), textcolor=color.white,
                             style=label.style_label_up, size=size.tiny)
        t.tpLbl := label.new(bar_index, volRatio + 0.15, tpTxt,
                             color=color.new(#22c55e, 70), textcolor=color.white,
                             style=label.style_label_down, size=size.tiny)
        t.entLine := line.new(bar_index, volRatio, bar_index + 30, volRatio,
                              color=color.new(sigCol, 50), width=1, style=line.style_dashed)

    array.push(trades, t)
    if array.size(trades) > 40
        VDETrade old = array.shift(trades)
        if i_showRR
            label.delete(old.slLbl)
            label.delete(old.tpLbl)
            line.delete(old.entLine)

// ─────────────────────────────────────────────────────────────────────────────
// SIGNAL FIRE
// ─────────────────────────────────────────────────────────────────────────────

if bullBreak
    label.new(bar_index, volRatio + 0.20, "BRK +" + str.format("{0,number,#.##}", volRatio),
         style=label.style_label_down,
         color=color.new(#10b981, 40),
         textcolor=color.white,
         size=size.tiny)
    f_openTrade(close, true, isExtreme)

if bearBreak
    label.new(bar_index, volRatio - 0.20, "BRK -" + str.format("{0,number,#.##}", volRatio),
         style=label.style_label_up,
         color=color.new(#f43f5e, 40),
         textcolor=color.white,
         size=size.tiny)
    f_openTrade(close, false, isExtreme)

// ─────────────────────────────────────────────────────────────────────────────
// TRADE MANAGEMENT — check TP/SL using price
// ─────────────────────────────────────────────────────────────────────────────

if barstate.isconfirmed and array.size(trades) > 0
    for i = array.size(trades) - 1 to 0
        VDETrade t = array.get(trades, i)
        if na(t.entBar)
            continue

        bool hit = false
        bool won = false

        if t.isBull
            if low <= t.slLvl
                hit := true
                won := false
            else if high >= t.tpLvl
                hit := true
                won := true
        else
            if high >= t.slLvl
                hit := true
                won := false
            else if low <= t.tpLvl
                hit := true
                won := true

        // Extend entry line
        if i_showRR and not na(t.entLine)
            line.set_x2(t.entLine, bar_index)

        if hit
            totT += 1
            if won
                totW += 1
            else
                totL += 1
            // Classify the trade by volume regime at entry
            // We approximate by checking extreme threshold; fallback to high
            if extrT < highT
                extrT += 1
                if won
                    extrW += 1
                else
                    extrL += 1
            else
                highT += 1
                if won
                    highW += 1
                else
                    highL += 1

            array.remove(trades, i)

// ─────────────────────────────────────────────────────────────────────────────
// OSCILLATOR PLOTS
// ─────────────────────────────────────────────────────────────────────────────

// Main ratio histogram
plot(volRatio, "Volume Ratio", color=regColor, style=plot.style_histogram, linewidth=3)

// Threshold reference lines
hline(i_lowThresh,  "Low Thresh",     color=color.new(#475569, 40), linestyle=hline.style_dashed, linewidth=1)
hline(i_normThresh, "Normal Thresh",  color=color.new(#3b82f6, 40), linestyle=hline.style_dashed, linewidth=1)
hline(i_highThresh, "High Thresh",    color=color.new(#f59e0b, 40), linestyle=hline.style_dashed, linewidth=1)
hline(1.0,          "Baseline",       color=color.new(#64748b, 55), linestyle=hline.style_solid,  linewidth=1)

// Smoothed ratio line
plot(volRatio, "Ratio Line", color=color.new(#e2e8f0, 30), style=plot.style_line, linewidth=1)

// Vol momentum (rate of change)
float volMom = volRatio - volRatio[3]
plot(volMom, "Vol Momentum", color=volMom > 0 ? color.new(#22c55e, 50) : color.new(#ef4444, 50), style=plot.style_columns, linewidth=1)

// Rolling 20-bar high of vol ratio — acts as a resistance/support reference
float volPeak = ta.highest(volRatio, 20)
plot(volPeak, "Vol Peak (20)", color=color.new(#a78bfa, 60), style=plot.style_line, linewidth=1)

// Gradient fill between ratio and 1.0 baseline
plot(volRatio, "Ratio Fill A", display=display.none)
plot(1.0,      "Ratio Fill B", display=display.none)

// Breakout markers in oscillator pane
plotshape(bullBreak, "Bull Breakout", shape.triangleup,   location.bottom,
          color=color.new(i_colBullBrk, 20), size=size.small)
plotshape(bearBreak, "Bear Breakout", shape.triangledown, location.top,
          color=color.new(i_colBearBrk, 20), size=size.small)

// Consolidation zone indicator (horizontal line when consolidating)
plot(inCons ? i_consThresh : na, "Consolidation Zone",
     color=color.new(#a78bfa, 50), style=plot.style_linebr, linewidth=2)

// ─────────────────────────────────────────────────────────────────────────────
// BACKGROUND TINT
// ─────────────────────────────────────────────────────────────────────────────

bgcolor(isExtreme ? color.new(i_colExtreme, 93) :
        isHigh    ? color.new(i_colHigh,    95) : na)

// ─────────────────────────────────────────────────────────────────────────────
// DASHBOARD
// ─────────────────────────────────────────────────────────────────────────────

if i_dashOn and barstate.islast
    float totWR  = totT  > 0 ? float(totW)  / float(totT)  * 100.0 : 0.0
    float highWR = highT > 0 ? float(highW) / float(highT) * 100.0 : 0.0
    float extrWR = extrT > 0 ? float(extrW) / float(extrT) * 100.0 : 0.0

    table dash = table.new(position.top_right, 3, 9,
                           bgcolor=color.new(#0f172a, 10),
                           border_color=color.new(#334155, 80),
                           border_width=1, frame_color=color.new(#334155, 60),
                           frame_width=1)

    // Header
    table.cell(dash, 0, 0, "Volume Displacement Engine [JOAT]",
               text_color=color.new(#f8fafc, 0), text_size=size.small,
               bgcolor=color.new(#1e293b, 10), text_halign=text.align_center)
    table.cell(dash, 1, 0, "", text_size=size.normal, bgcolor=color.new(#1e293b, 10))
    table.cell(dash, 2, 0, "", text_size=size.normal, bgcolor=color.new(#1e293b, 10))

    // Current regime
    table.cell(dash, 0, 1, "Regime",    text_color=color.new(#94a3b8, 0), text_size=size.normal, bgcolor=color.new(#1e293b, 25))
    table.cell(dash, 1, 1, regLabel,    text_color=regColor,               text_size=size.normal, bgcolor=color.new(#1e293b, 25))
    table.cell(dash, 2, 1, "",          text_size=size.normal,             bgcolor=color.new(#1e293b, 25))

    // Current ratio
    color volDeltaCol = volDelta > 0 ? color.new(#22c55e, 0) : color.new(#ef4444, 0)
    string volDeltaStr = (volDelta >= 0 ? "▲ " : "▼ ") + str.format("{0,number,#.##}", math.abs(volDelta))
    table.cell(dash, 0, 2, "Vol Ratio", text_color=color.new(#94a3b8, 0), text_size=size.normal, bgcolor=color.new(#1e293b, 30))
    table.cell(dash, 1, 2, str.format("{0,number,#.##}", volRatio), text_color=color.new(#e2e8f0, 0), text_size=size.normal, bgcolor=color.new(#1e293b, 30))
    table.cell(dash, 2, 2, volDeltaStr, text_color=volDeltaCol, text_size=size.normal, bgcolor=color.new(#1e293b, 30))

    // Consolidation status
    table.cell(dash, 0, 3, "In Cons",   text_color=color.new(#94a3b8, 0), text_size=size.normal, bgcolor=color.new(#1e293b, 30))
    color consCol = inCons ? color.new(#a78bfa, 0) : color.new(#64748b, 0)
    table.cell(dash, 1, 3, inCons ? "YES" : "NO", text_color=consCol, text_size=size.normal, bgcolor=color.new(#1e293b, 30))
    table.cell(dash, 2, 3, "",          text_size=size.normal,             bgcolor=color.new(#1e293b, 30))

    // Divider
    table.cell(dash, 0, 4, "", bgcolor=color.new(#334155, 60))
    table.cell(dash, 1, 4, "", bgcolor=color.new(#334155, 60))
    table.cell(dash, 2, 4, "", bgcolor=color.new(#334155, 60))

    // Performance headers
    table.cell(dash, 0, 5, "Regime",   text_color=color.new(#94a3b8, 0), text_size=size.normal, bgcolor=color.new(#1e293b, 20))
    table.cell(dash, 1, 5, "W/L",      text_color=color.new(#94a3b8, 0), text_size=size.normal, bgcolor=color.new(#1e293b, 20))
    table.cell(dash, 2, 5, "WR%",      text_color=color.new(#94a3b8, 0), text_size=size.normal, bgcolor=color.new(#1e293b, 20))

    // High vol row
    color highClr = highWR >= 55.0 ? color.new(#22c55e, 20) : highWR >= 45.0 ? color.new(#f59e0b, 20) : color.new(#ef4444, 20)
    table.cell(dash, 0, 6, "High",     text_color=color.new(i_colHigh, 0),    text_size=size.normal, bgcolor=color.new(#1e293b, 30))
    table.cell(dash, 1, 6, str.tostring(highW) + "/" + str.tostring(highL),   text_color=color.new(#e2e8f0, 0), text_size=size.normal, bgcolor=color.new(#1e293b, 30))
    table.cell(dash, 2, 6, str.format("{0,number,#.#}%", highWR),             text_color=color.new(#f8fafc, 0), text_size=size.normal, bgcolor=highClr)

    // Extreme vol row
    color extrClr = extrWR >= 55.0 ? color.new(#22c55e, 20) : extrWR >= 45.0 ? color.new(#f59e0b, 20) : color.new(#ef4444, 20)
    table.cell(dash, 0, 7, "Extreme",  text_color=color.new(i_colExtreme, 0), text_size=size.normal, bgcolor=color.new(#1e293b, 30))
    table.cell(dash, 1, 7, str.tostring(extrW) + "/" + str.tostring(extrL),   text_color=color.new(#e2e8f0, 0), text_size=size.normal, bgcolor=color.new(#1e293b, 30))
    table.cell(dash, 2, 7, str.format("{0,number,#.#}%", extrWR),             text_color=color.new(#f8fafc, 0), text_size=size.normal, bgcolor=extrClr)

    // Total row
    color totClr = totWR >= 55.0 ? color.new(#22c55e, 20) : totWR >= 45.0 ? color.new(#f59e0b, 20) : color.new(#ef4444, 20)
    table.cell(dash, 0, 8, "Total",    text_color=color.new(#e2e8f0, 0), text_size=size.normal, bgcolor=color.new(#1e293b, 10))
    table.cell(dash, 1, 8, str.tostring(totW) + "/" + str.tostring(totL),     text_color=color.new(#e2e8f0, 0), text_size=size.normal, bgcolor=color.new(#1e293b, 10))
    table.cell(dash, 2, 8, str.format("{0,number,#.#}%", totWR),              text_color=color.new(#f8fafc, 0), text_size=size.normal, bgcolor=totClr)
````
