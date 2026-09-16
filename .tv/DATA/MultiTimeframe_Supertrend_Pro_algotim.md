<!-- tradingview-pine-id: PUB;76d134d671704ec1b32dcaf7daf0233d -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Multi-Timeframe Supertrend Pro [algotim]

Source: https://www.tradingview.com/script/isf58Fgf-Multi-Timeframe-Supertrend-Pro-algotim/

## Description

Overview
Multi-Timeframe Supertrend Consensus is a trend-analysis indicator designed to address a common problem with single-timeframe trend signals: a direction change on one chart timeframe does not necessarily represent a broader change in market direction.

Instead of treating one Supertrend state as the complete trend decision, the script evaluates up to three independently configured Supertrend calculations and converts their directional states into a single timeframe-consensus reading.

The purpose is to distinguish isolated timeframe changes from situations where multiple timeframe structures are aligned.

Problem Statement
A conventional Supertrend evaluates price direction from one timeframe. This can be useful for identifying local trends, but it can also produce direction changes that are not supported by the broader timeframe structure.

A trader may therefore see a bullish change on the chart timeframe while the higher timeframe remains bearish.

This script addresses that problem by separating trend detection into three layers:
1. Primary trend on the current chart timeframe.
2. Confirmation trend on an optional timeframe.
3. Higher-timeframe trend on a configurable timeframe.

The resulting directional states are evaluated together rather than interpreted independently.

Methodology
Each Supertrend calculation uses ATR-based bands derived from the selected ATR length and multiplier.

The calculation begins from the midpoint price (`HL2`) and determines upper and lower volatility-adjusted bands using ATR.

The Supertrend state then maintains directional continuity until price crosses the relevant previous band. A bullish state uses the upper calculated Supertrend line, while a bearish state uses the lower line.

The three calculations are independently parameterized, allowing the confirmation and higher-timeframe models to use different ATR lengths and factors from the primary model.

For non-current timeframes, the script requests the corresponding Supertrend state through `request.security()` using `barmerge.lookahead_off`. This prevents the requested timeframe from intentionally using future bars.

The important part of the architecture is what happens after these calculations: their directional states are counted and evaluated through a configurable consensus threshold.

Signal Workflow
The analytical workflow is:
1. Calculate the primary Supertrend using the current chart timeframe.
2. Calculate the optional confirmation Supertrend using the selected confirmation timeframe.
3. Calculate the higher-timeframe Supertrend using the configured higher timeframe.
4. Determine whether each Supertrend is bullish or bearish.
5. Count the number of aligned bullish and bearish timeframe states.
6. Compare that alignment against the user-defined consensus threshold.
7. Issue the corresponding consensus trend state when sufficient timeframe agreement exists.
8. Display the individual Supertrend lines and the consensus information so the trader can see both the underlying states and the resulting agreement.

The consensus threshold controls how selective the framework is. A lower threshold allows a signal with less agreement, while requiring all three timeframes produces the strictest alignment condition.

Why This Indicator Is Different
The primary purpose of this script is not to provide three separate Supertrend lines.
Its purpose is to convert multiple Supertrend states into a **single timeframe-agreement framework**.

A conventional Supertrend answers:

> "What is the trend according to this timeframe?"
This script adds another question:

> "How many of the monitored timeframes agree with that direction?"
This distinction is useful when a trader wants to separate local trend changes from broader directional alignment.

The confirmation and higher-timeframe calculations are also independently configurable rather than being simple copies of the primary settings. This allows the user to make the faster timeframe more responsive while keeping the broader timeframe more selective.

The resulting workflow can therefore be viewed as:
**Local trend -> Confirmation trend -> Higher-timeframe trend -> Agreement calculation -> Consensus state**
This is the central analytical contribution of the script.

Inputs
Primary Supertrend
Controls the Supertrend calculated directly on the chart timeframe.
* ATR Length
* Factor

Confirmation Supertrend
Controls the optional second timeframe calculation.
* Timeframe
* ATR Length
* Factor
Leaving the timeframe blank uses the primary chart-timeframe calculation.

Higher-Timeframe Supertrend
Controls the broader trend reference.
* Timeframe
* ATR Length
* Factor

Consensus Engine
Controls how much timeframe agreement is required.

* Minimum Timeframes Needed for Signal
* Confidence Shading

A threshold of 3 requires all three monitored states to agree and therefore provides stricter filtering than a threshold of 2.

Visual Settings
The script provides independent visibility controls for:
* Primary Supertrend line
* Confirmation Supertrend line
* Higher-timeframe Supertrend line
* Consensus entry signals

Bullish and bearish colors can also be customized.

Alerts
The script provides alert functionality for its consensus-based trend events.
Alerts should be configured from the indicator's available TradingView alert conditions/functions after adding the script to a chart.

Practical Usage
A practical workflow is to use the primary Supertrend to observe the local market direction while using the confirmation and higher-timeframe calculations to determine whether that direction is supported by broader timeframe structure.
For example, requiring two of three timeframes to agree can provide a moderate filtering level. Requiring three of three creates a stricter consensus condition and may result in fewer signals.
The individual lines should remain visible while evaluating the indicator so that the trader can see why a consensus state was produced rather than treating the consensus output as a standalone trading decision.
The indicator can be used for trend filtering, directional analysis, and identifying periods of stronger multi-timeframe alignment.

Limitations
Supertrend remains a reactive, volatility-based trend-following calculation. It does not predict future price movement.
Because the methodology depends on ATR and price crossings, rapid volatility changes can produce direction changes or conflicting timeframe states.
Higher-timeframe values also update according to the availability of confirmed data from their respective timeframe. Signals should therefore be evaluated with awareness of the timeframe relationship.
A consensus state indicates agreement between the configured Supertrend calculations; it does not guarantee continuation of the resulting trend.
The indicator is an analytical tool and should not be treated as a standalone trading system or a guarantee of future performance.

Notes
The script is designed to make multi-timeframe Supertrend agreement visible within one analytical framework.
Its main distinction from a conventional single-timeframe Supertrend is the explicit consensus layer that evaluates the directional state of multiple independently configured timeframe calculations.
Users should select timeframe and ATR parameters appropriate to the instrument and timeframe being analyzed and validate the resulting signals with their own market analysis and risk-management process.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © algotim

//@version=6
indicator(
     title     = "Multi-Timeframe Supertrend Pro [algotim]",
     shorttitle = "MTF ST Pro [algotim]",
     overlay   = true,
     max_bars_back = 500
 )

// ─────────────────────────────────────────────────────────────────────────────
// ░░  SECTION 1 — INPUT GROUPS
// ─────────────────────────────────────────────────────────────────────────────

// ── Primary Supertrend ───────────────────────────────────────────────────────
var string G1 = "⚙  Primary Supertrend"
p_atr_len  = input.int(10,   "ATR Length",      minval=1,  group=G1)
p_factor   = input.float(2.0,"Factor",           minval=0.1, step=0.1, group=G1)

// ── Confirmation Supertrend ──────────────────────────────────────────────────
var string G2 = "⚙  Confirmation Supertrend"
c_tf       = input.timeframe("",   "Timeframe (blank = current)", group=G2)
c_atr_len  = input.int(10,   "ATR Length",      minval=1,  group=G2)
c_factor   = input.float(3.0,"Factor",           minval=0.1, step=0.1, group=G2)

// ── Higher-Timeframe Supertrend ──────────────────────────────────────────────
var string G3 = "⚙  Higher-Timeframe Supertrend"
h_tf       = input.timeframe("W",  "Timeframe",               group=G3)
h_atr_len  = input.int(10,   "ATR Length",      minval=1,  group=G3)
h_factor   = input.float(3.0,"Factor",           minval=0.1, step=0.1, group=G3)

// ── Consensus Engine ─────────────────────────────────────────────────────────
var string G4 = "🔬  Consensus Engine"
consensus_threshold = input.int(2, "Min Timeframes Needed for Signal",
     minval=1, maxval=3, tooltip="Number of timeframes that must agree before a trend signal is issued. 3 = strictest filtering.", group=G4)
show_conf_bg = input.bool(true, "Show Confidence Shading", group=G4,
     tooltip="Adaptive background shading reflects how many timeframes are aligned. More agreement = more vivid shading.")

// ── Visual Settings ──────────────────────────────────────────────────────────
var string G5 = "🎨  Visual Settings"
bull_col   = input.color(color.new(#00C9A7, 0),  "Bullish Color",  group=G5)
bear_col   = input.color(color.new(#FF5370, 0),  "Bearish Color",  group=G5)
show_primary_line  = input.bool(true,  "Show Primary ST Line",          group=G5)
show_confirm_line  = input.bool(true,  "Show Confirmation ST Line",     group=G5)
show_htf_line      = input.bool(true,  "Show HTF ST Line",              group=G5)
show_signals       = input.bool(true,  "Show Consensus Entry Signals",  group=G5)

// ── Alerts ───────────────────────────────────────────────────────────────────
var string G6 = "🔔  Alerts"
// (Alert conditions wired to alert() calls below — no action inputs needed)


// ─────────────────────────────────────────────────────────────────────────────
// ░░  SECTION 2 — SUPERTREND FUNCTION
// ─────────────────────────────────────────────────────────────────────────────

// Returns [supertrend_line, direction]
// direction: 1 = bullish, -1 = bearish
f_supertrend(src, atr_len, factor) =>
    atr_val = ta.atr(atr_len)
    upper_band = src - factor * atr_val
    lower_band = src + factor * atr_val

    var float prev_upper = na
    var float prev_lower = na
    var int   direction  = 1

    upper_band := (upper_band > nz(prev_upper) or close[1] < nz(prev_upper))
                  ? upper_band : nz(prev_upper)
    lower_band := (lower_band < nz(prev_lower) or close[1] > nz(prev_lower))
                  ? lower_band : nz(prev_lower)

    direction := direction == -1 and close > prev_lower ? 1
                 : direction == 1  and close < prev_upper ? -1
                 : direction

    st_line = direction == 1 ? upper_band : lower_band

    prev_upper := upper_band
    prev_lower := lower_band

    [st_line, direction]


// ─────────────────────────────────────────────────────────────────────────────
// ░░  SECTION 3 — PRIMARY SUPERTREND (current chart timeframe)
// ─────────────────────────────────────────────────────────────────────────────

src_hl2 = hl2
[p_st, p_dir] = f_supertrend(src_hl2, p_atr_len, p_factor)


// ─────────────────────────────────────────────────────────────────────────────
// ░░  SECTION 4 — CONFIRMATION SUPERTREND (optional timeframe)
//     Uses barmerge.lookahead_off for non-repainting HTF data
// ─────────────────────────────────────────────────────────────────────────────

// When c_tf is blank/same, we just reuse the primary calculation.
// When a different timeframe is selected, request.security() with lookahead_off
// is used so there is no future-bar peeking.

[c_st_raw, c_dir_raw] = request.security(
     syminfo.tickerid, c_tf,
     f_supertrend(hl2, c_atr_len, c_factor),
     lookahead = barmerge.lookahead_off
 )

// Fall back to primary values when confirmation TF == chart TF (blank input)
c_st  = c_tf == "" ? p_st  : c_st_raw
c_dir = c_tf == "" ? p_dir : c_dir_raw


// ─────────────────────────────────────────────────────────────────────────────
// ░░  SECTION 5 — HIGHER-TIMEFRAME SUPERTREND
//     Strictly non-repainting via lookahead_off
// ─────────────────────────────────────────────────────────────────────────────

[h_st_raw, h_dir_raw] = request.security(
     syminfo.tickerid, h_tf,
     f_supertrend(hl2, h_atr_len, h_factor),
     lookahead = barmerge.lookahead_off
 )

h_st  = h_st_raw
h_dir = h_dir_raw


// ─────────────────────────────────────────────────────────────────────────────
// ░░  SECTION 6 — TREND CONSENSUS ENGINE
// ─────────────────────────────────────────────────────────────────────────────

// Count how many timeframes are bullish / bearish
bull_votes = (p_dir == 1 ? 1 : 0) + (c_dir == 1 ? 1 : 0) + (h_dir == 1 ? 1 : 0)
bear_votes = (p_dir == -1 ? 1 : 0) + (c_dir == -1 ? 1 : 0) + (h_dir == -1 ? 1 : 0)

// Consensus direction: net majority wins; 0 = neutral
consensus_bull = bull_votes >= consensus_threshold
consensus_bear = bear_votes >= consensus_threshold

// Detect consensus flip (new signal bar)
var int prev_consensus = 0
curr_consensus = consensus_bull ? 1 : consensus_bear ? -1 : 0
consensus_flip_bull = curr_consensus == 1  and prev_consensus != 1
consensus_flip_bear = curr_consensus == -1 and prev_consensus != -1
prev_consensus := curr_consensus


// ─────────────────────────────────────────────────────────────────────────────
// ░░  SECTION 7 — COLOR LOGIC
// ─────────────────────────────────────────────────────────────────────────────

// Primary line color follows primary direction
p_col = p_dir == 1 ? bull_col : bear_col

// Confirmation line — slightly muted
c_col = c_dir == 1 ? color.new(bull_col, 40) : color.new(bear_col, 40)

// HTF line — dashed-style via width difference + higher transparency
h_col = h_dir == 1 ? color.new(bull_col, 25) : color.new(bear_col, 25)

// Confidence shading transparency: more agreement → less transparent
// bull_votes: 3 → transp 88, 2 → transp 93, 1 → transp 97
// bear_votes: symmetric
bg_transp_bull = bull_votes == 3 ? 88 : bull_votes == 2 ? 93 : 97
bg_transp_bear = bear_votes == 3 ? 88 : bear_votes == 2 ? 93 : 97

bg_color = show_conf_bg
     ? (consensus_bull
        ? color.new(bull_col, bg_transp_bull)
        : consensus_bear
          ? color.new(bear_col, bg_transp_bear)
          : na)
     : na


// ─────────────────────────────────────────────────────────────────────────────
// ░░  SECTION 8 — PLOT: SUPERTREND LINES
// ─────────────────────────────────────────────────────────────────────────────

// Primary Supertrend — bold, solid
plot(show_primary_line ? p_st : na,
     title     = "Primary Supertrend",
     color     = p_col,
     linewidth = 2,
     style     = plot.style_line)

// Confirmation Supertrend — thinner, semi-transparent
plot(show_confirm_line ? c_st : na,
     title     = "Confirmation Supertrend",
     color     = c_col,
     linewidth = 1,
     style     = plot.style_line)

// HTF Supertrend — circles style gives a "stepped" institutional look
plot(show_htf_line ? h_st : na,
     title     = "HTF Supertrend",
     color     = h_col,
     linewidth = 2,
     style     = plot.style_circles)


// ─────────────────────────────────────────────────────────────────────────────
// ░░  SECTION 9 — PLOT: CONFIDENCE BACKGROUND SHADING
// ─────────────────────────────────────────────────────────────────────────────

bgcolor(bg_color, title = "Consensus Confidence Shading")


// ─────────────────────────────────────────────────────────────────────────────
// ░░  SECTION 10 — PLOT: CONSENSUS ENTRY SIGNALS
// ─────────────────────────────────────────────────────────────────────────────

// Entry signals appear only when consensus threshold is freshly crossed
plotshape(
     show_signals and consensus_flip_bull ? low : na,
     title    = "Consensus Bull Signal",
     style    = shape.triangleup,
     location = location.belowbar,
     color    = bull_col,
     size     = size.small,
     text     = "▲",
     textcolor= bull_col
 )

plotshape(
     show_signals and consensus_flip_bear ? high : na,
     title    = "Consensus Bear Signal",
     style    = shape.triangledown,
     location = location.abovebar,
     color    = bear_col,
     size     = size.small,
     text     = "▼",
     textcolor= bear_col
 )


// ─────────────────────────────────────────────────────────────────────────────
// ░░  SECTION 11 — TREND CHANGE CANDLE HIGHLIGHT
//     Subtle candle coloring on the bar where consensus flips
// ─────────────────────────────────────────────────────────────────────────────

barcolor(
     consensus_flip_bull ? color.new(bull_col, 60)
     : consensus_flip_bear ? color.new(bear_col, 60)
     : na,
     title = "Consensus Flip Bar Highlight"
 )


// ─────────────────────────────────────────────────────────────────────────────
// ░░  SECTION 12 — ALERTS
// ─────────────────────────────────────────────────────────────────────────────

// ── Consensus Bullish Entry ───────────────────────────────────────────────────
if consensus_flip_bull
    alert(
         "🟢 MTF ST Pro [algotim] | BULLISH CONSENSUS on " + syminfo.ticker
         + " (" + timeframe.period + ") | "
         + str.tostring(bull_votes) + "/3 TFs aligned BULLISH"
         + " | Price: " + str.tostring(close),
         alert.freq_once_per_bar_close
     )

// ── Consensus Bearish Entry ───────────────────────────────────────────────────
if consensus_flip_bear
    alert(
         "🔴 MTF ST Pro [algotim] | BEARISH CONSENSUS on " + syminfo.ticker
         + " (" + timeframe.period + ") | "
         + str.tostring(bear_votes) + "/3 TFs aligned BEARISH"
         + " | Price: " + str.tostring(close),
         alert.freq_once_per_bar_close
     )

// ── Primary TF Flip (standalone) ─────────────────────────────────────────────
p_dir_changed_bull = p_dir == 1  and p_dir[1] == -1
p_dir_changed_bear = p_dir == -1 and p_dir[1] == 1

if p_dir_changed_bull
    alert(
         "↑ MTF ST Pro [algotim] | Primary ST turned BULLISH on "
         + syminfo.ticker + " | Price: " + str.tostring(close),
         alert.freq_once_per_bar_close
     )

if p_dir_changed_bear
    alert(
         "↓ MTF ST Pro [algotim] | Primary ST turned BEARISH on "
         + syminfo.ticker + " | Price: " + str.tostring(close),
         alert.freq_once_per_bar_close
     )

// ── Full 3/3 Consensus (max-strength signal) ─────────────────────────────────
if bull_votes == 3 and bull_votes[1] < 3
    alert(
         "⭐ MTF ST Pro [algotim] | FULL BULLISH CONSENSUS (3/3) on "
         + syminfo.ticker + " (" + timeframe.period + ")"
         + " | Price: " + str.tostring(close),
         alert.freq_once_per_bar_close
     )

if bear_votes == 3 and bear_votes[1] < 3
    alert(
         "⭐ MTF ST Pro [algotim] | FULL BEARISH CONSENSUS (3/3) on "
         + syminfo.ticker + " (" + timeframe.period + ")"
         + " | Price: " + str.tostring(close),
         alert.freq_once_per_bar_close
     )


// ─────────────────────────────────────────────────────────────────────────────
// ░░  SECTION 13 — ALERT CONDITIONS (for TradingView Alert Dialog)
// ─────────────────────────────────────────────────────────────────────────────

alertcondition(consensus_flip_bull,
     title   = "Bullish Consensus",
     message = "MTF ST Pro [algotim] — Bullish Consensus on {{ticker}} | Price: {{close}}")

alertcondition(consensus_flip_bear,
     title   = "Bearish Consensus",
     message = "MTF ST Pro [algotim] — Bearish Consensus on {{ticker}} | Price: {{close}}")

alertcondition(p_dir_changed_bull,
     title   = "Primary ST Bullish Flip",
     message = "MTF ST Pro [algotim] — Primary ST Bullish on {{ticker}} | Price: {{close}}")

alertcondition(p_dir_changed_bear,
     title   = "Primary ST Bearish Flip",
     message = "MTF ST Pro [algotim] — Primary ST Bearish on {{ticker}} | Price: {{close}}")

alertcondition(bull_votes == 3 and bull_votes[1] < 3,
     title   = "Full Bullish Consensus (3/3)",
     message = "MTF ST Pro [algotim] — FULL BULL (3/3) on {{ticker}} | Price: {{close}}")

alertcondition(bear_votes == 3 and bear_votes[1] < 3,
     title   = "Full Bearish Consensus (3/3)",
     message = "MTF ST Pro [algotim] — FULL BEAR (3/3) on {{ticker}} | Price: {{close}}")
````
