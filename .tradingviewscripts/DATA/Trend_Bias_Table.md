<!-- tradingview-pine-id: PUB;b99df6fd63104496bd980d27bf4f17f0 -->
<!-- tradingviewscripts-format: 1 -->
# Trend Bias Table

Source: https://www.tradingview.com/script/8qN6RIKp-Trend-Bias-Table/

## Description

Trend Bias Table — Indicator Description

Type: Overlay indicator (displays directly on the price chart, top-right corner)

What It Does

Trend Bias Table shows a multi-timeframe directional bias panel — Day, 4 Hour, 1 Hour, and 15 Minute — without using any moving averages. Each timeframe is scored independently as Bullish, Bearish, or Neutral based on pure price action.

How the Bias Is Calculated

For each timeframe, three independent factors are scored:

Market Structure — Detects swing pivot highs/lows (via ta.pivothigh / ta.pivotlow) and compares the two most recent pivots:
Higher High + Higher Low → bullish structure
Lower High + Lower Low → bearish structure
Momentum — A Rate of Change (ROC) calculation measures whether price has moved up or down over a smoothing period, with no lag-inducing moving average involved.
Price vs. Open — Checks whether the current close is trading above or below that timeframe's opening price.

Each factor contributes one point to either a bullish or bearish score. Whichever score is higher determines that timeframe's bias; a tie results in Neutral.

What's Displayed

A clean 2-column, 5-row table pinned to the top-right of the chart:

TIMEFRAME	BIAS
Day	▲ BULL / ▼ BEAR / ● NEUT
4 Hour	▲ BULL / ▼ BEAR / ● NEUT
1 Hour	▲ BULL / ▼ BEAR / ● NEUT
15 Min	▲ BULL / ▼ BEAR / ● NEUT
Teal = Bullish
Red = Bearish
Grey = Neutral
Inputs
Swing Pivot Length (default 5) — sensitivity of pivot detection for structure analysis
ROC Smoothing (default 3) — lookback period for the momentum calculation
Use Case

Gives traders a fast, at-a-glance read on trend alignment across timeframes — useful for confirming whether a lower-timeframe setup agrees with the higher-timeframe trend, without cluttering the chart with moving average lines.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © TrendBias Table — No Moving Averages
// Uses: Price Structure (HH/HL/LH/LL) + Momentum (Rate of Change)
// Displays ONLY the multi-timeframe bias table, top-right of chart

//@version=6
indicator("Trend Bias Table", overlay=true, max_bars_back=500)

// ─────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────
swing_len   = input.int(5,  "Swing Pivot Length", minval=2, maxval=20, group="Structure")
roc_smooth  = input.int(3,  "ROC Smoothing",      minval=1, maxval=10, group="Momentum")

// ─────────────────────────────────────────────
// TIMEFRAME HELPERS
// ─────────────────────────────────────────────
tf_day  = "D"
tf_4h   = "240"
tf_1h   = "60"
tf_15m  = "15"

// ─────────────────────────────────────────────
// STRUCTURE BIAS FUNCTION
// Returns: +1 (bullish), -1 (bearish), 0 (neutral)
// Logic: Compare current close to the open of the given timeframe period,
//        combined with Rate-of-Change momentum and pivot HH/HL vs LH/LL structure.
// ─────────────────────────────────────────────

// Rate of Change (momentum, no MAs)
roc(src, length) =>
    (src - src[length]) / src[length] * 100

// Pivot High / Low detection
pivotHigh(src, lb) =>
    ta.pivothigh(src, lb, lb)

pivotLow(src, lb) =>
    ta.pivotlow(src, lb, lb)

// Structure score based on recent pivot structure
// Checks last two pivots to determine HH/HL or LH/LL
structureBias(tf) =>
    ph = request.security(syminfo.tickerid, tf, pivotHigh(high, swing_len), lookahead=barmerge.lookahead_off)
    pl = request.security(syminfo.tickerid, tf, pivotLow(low,  swing_len), lookahead=barmerge.lookahead_off)
    c  = request.security(syminfo.tickerid, tf, close,                      lookahead=barmerge.lookahead_off)
    o  = request.security(syminfo.tickerid, tf, open,                       lookahead=barmerge.lookahead_off)

    // Track last two pivot highs and lows
    var float ph1 = na
    var float ph2 = na
    var float pl1 = na
    var float pl2 = na

    if not na(ph)
        ph2 := ph1
        ph1 := ph
    if not na(pl)
        pl2 := pl1
        pl1 := pl

    // Momentum: Rate of Change
    r = roc(c, roc_smooth)

    // Structure logic
    bullish_struct = not na(ph1) and not na(ph2) and not na(pl1) and not na(pl2) and ph1 > ph2 and pl1 > pl2
    bearish_struct = not na(ph1) and not na(ph2) and not na(pl1) and not na(pl2) and ph1 < ph2 and pl1 < pl2

    // Price relative to session open
    price_above_open = c > o
    price_below_open = c < o

    // Combine structure + momentum + price vs open
    bull_score = (bullish_struct ? 1 : 0) + (r > 0 ? 1 : 0) + (price_above_open ? 1 : 0)
    bear_score = (bearish_struct ? 1 : 0) + (r < 0 ? 1 : 0) + (price_below_open ? 1 : 0)

    bias = bull_score > bear_score ? 1 : bear_score > bull_score ? -1 : 0
    bias

// ─────────────────────────────────────────────
// COMPUTE BIAS PER TIMEFRAME
// ─────────────────────────────────────────────
bias_day  = structureBias(tf_day)
bias_4h   = structureBias(tf_4h)
bias_1h   = structureBias(tf_1h)
bias_15m  = structureBias(tf_15m)

// ─────────────────────────────────────────────
// COLOUR HELPERS
// ─────────────────────────────────────────────
bull_col    = color.new(#26a69a, 0)   // teal
bear_col    = color.new(#ef5350, 0)   // red
neut_col    = color.new(#888888, 0)   // grey

biasColor(b) =>
    b == 1 ? bull_col : b == -1 ? bear_col : neut_col

biasLabel(b) =>
    b == 1 ? "▲ BULL" : b == -1 ? "▼ BEAR" : "● NEUT"

// ─────────────────────────────────────────────
// TABLE DISPLAY (top right, overlaid on chart)
// ─────────────────────────────────────────────
var table panel = table.new(
     position.top_right, 2, 5,
     bgcolor       = color.new(#1a1a2e, 5),
     border_width  = 1,
     border_color  = color.new(#444466, 60),
     frame_width   = 1,
     frame_color   = color.new(#444466, 40))

if barstate.islast
    // Header row
    table.cell(panel, 0, 0, "TIMEFRAME", text_color=color.new(#aaaacc, 0), text_size=size.small, bgcolor=color.new(#12122a, 0))
    table.cell(panel, 1, 0, "BIAS",      text_color=color.new(#aaaacc, 0), text_size=size.small, bgcolor=color.new(#12122a, 0))

    // Row data: [label, bias value]
    table.cell(panel, 0, 1, "  Day  ",  text_color=color.new(#ccccee, 0), text_size=size.normal, bgcolor=color.new(#1a1a2e, 0))
    table.cell(panel, 1, 1, biasLabel(bias_day), text_color=biasColor(bias_day), text_size=size.normal, bgcolor=color.new(#1a1a2e, 0))

    table.cell(panel, 0, 2, "  4 Hour", text_color=color.new(#ccccee, 0), text_size=size.normal, bgcolor=color.new(#1a1a2e, 0))
    table.cell(panel, 1, 2, biasLabel(bias_4h), text_color=biasColor(bias_4h), text_size=size.normal, bgcolor=color.new(#1a1a2e, 0))

    table.cell(panel, 0, 3, "  1 Hour", text_color=color.new(#ccccee, 0), text_size=size.normal, bgcolor=color.new(#1a1a2e, 0))
    table.cell(panel, 1, 3, biasLabel(bias_1h), text_color=biasColor(bias_1h), text_size=size.normal, bgcolor=color.new(#1a1a2e, 0))

    table.cell(panel, 0, 4, "  15 Min", text_color=color.new(#ccccee, 0), text_size=size.normal, bgcolor=color.new(#1a1a2e, 0))
    table.cell(panel, 1, 4, biasLabel(bias_15m), text_color=biasColor(bias_15m), text_size=size.normal, bgcolor=color.new(#1a1a2e, 0))
````
