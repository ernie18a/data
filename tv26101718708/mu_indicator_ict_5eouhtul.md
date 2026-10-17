# MU indicator ict 

- url: https://www.tradingview.com/script/5EoUhtuL-MU-indicator-ict/
- type: indicator
- pine_id: PUB;65d513a21e0542f69874224c50bae68a
- version: 1.0

## Description

The indicator plots 4 ICT concepts directly on your chart:
1. Fair Value Gaps (FVG)
Colored boxes that appear when there's an imbalance between 3 candles — price tends to come back and fill these. Green = bullish gap, Red = bearish gap.
2. Order Blocks (OB)
Boxes that mark the last candle before a big move — these are areas where institutions placed orders. Blue = bullish OB, Orange = bearish OB.
3. Liquidity Sweeps
Dotted lines at swing highs and lows (where stop losses cluster). When price wicks through one and closes back, it labels it "SWEEP ↑" or "SWEEP ↓" — this signals a potential reversal.
4. Market Structure Shift (MSS)
When price breaks a key swing high or low, it labels it "MSS ▲" or "MSS ▼" — this tells you the trend may be changing direction.

The idea is you look for these concepts to line up — for example, a liquidity sweep into an order block with an FVG nearby, followed by an MSS, is a classic ICT entry signal.
Want me to add anything else to it, like Killzones, NWOG/NDOG, or Premium/Discount zones?

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// ICT Concepts Indicator — FVG | Order Blocks | Liquidity Sweeps | MSS
// Compatible with TradingView Pine Script v5

//@version=5
indicator("ICT Concepts [FVG + OB + Liquidity + MSS]", overlay=true, max_boxes_count=200, max_lines_count=200, max_labels_count=200)

// ─────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────

// Fair Value Gaps
show_fvg       = input.bool(true,  "Show Fair Value Gaps",        group="Fair Value Gaps")
fvg_bull_col   = input.color(color.new(color.green, 80), "Bullish FVG Color", group="Fair Value Gaps")
fvg_bear_col   = input.color(color.new(color.red,   80), "Bearish FVG Color", group="Fair Value Gaps")
fvg_extend     = input.int(20, "Extend FVG Boxes (bars)", minval=1, maxval=500, group="Fair Value Gaps")

// Order Blocks
show_ob        = input.bool(true,  "Show Order Blocks",           group="Order Blocks")
ob_bull_col    = input.color(color.new(color.blue,  75), "Bullish OB Color", group="Order Blocks")
ob_bear_col    = input.color(color.new(color.orange,75), "Bearish OB Color", group="Order Blocks")
ob_extend      = input.int(40, "Extend OB Boxes (bars)", minval=1, maxval=500, group="Order Blocks")

// Liquidity
show_liq       = input.bool(true,  "Show Liquidity Levels",       group="Liquidity Sweeps")
liq_lookback   = input.int(20,  "Swing Lookback",  minval=5, maxval=100, group="Liquidity Sweeps")
liq_col        = input.color(color.new(color.yellow, 0), "Liquidity Line Color", group="Liquidity Sweeps")
show_sweep     = input.bool(true,  "Highlight Sweeps",            group="Liquidity Sweeps")
sweep_bull_col = input.color(color.lime,   "Bullish Sweep Label", group="Liquidity Sweeps")
sweep_bear_col = input.color(color.red,    "Bearish Sweep Label", group="Liquidity Sweeps")

// Market Structure Shift
show_mss       = input.bool(true,  "Show Market Structure Shift", group="MSS")
mss_lookback   = input.int(10, "MSS Swing Lookback", minval=3, maxval=50, group="MSS")
mss_bull_col   = input.color(color.lime,   "Bullish MSS Color",  group="MSS")
mss_bear_col   = input.color(color.red,    "Bearish MSS Color",  group="MSS")

// ─────────────────────────────────────────────
// FAIR VALUE GAPS
// ─────────────────────────────────────────────
// Bullish FVG: low[0] > high[2]  (gap between candle 0 low and candle 2 high)
// Bearish FVG: high[0] < low[2]

if show_fvg and barstate.isconfirmed
    // Bullish FVG
    if low > high[2]
        box.new(bar_index - 2, low, bar_index + fvg_extend, high[2],
             border_color=color.new(color.green, 60),
             bgcolor=fvg_bull_col,
             border_width=1)

    // Bearish FVG
    if high < low[2]
        box.new(bar_index - 2, high, bar_index + fvg_extend, low[2],
             border_color=color.new(color.red, 60),
             bgcolor=fvg_bear_col,
             border_width=1)

// ─────────────────────────────────────────────
// ORDER BLOCKS
// ─────────────────────────────────────────────
// Bullish OB: last bearish candle before a strong bullish move
// Bearish OB: last bullish candle before a strong bearish move

is_strong_bull = close > high[1] and close > open  // engulfing up
is_strong_bear = close < low[1]  and close < open  // engulfing down

if show_ob and barstate.isconfirmed
    // Bullish OB — the candle before the strong bull move was bearish
    if is_strong_bull and close[1] < open[1]
        box.new(bar_index - 1, low[1], bar_index + ob_extend, high[1],
             border_color=color.new(color.blue, 40),
             bgcolor=ob_bull_col,
             border_width=1)

    // Bearish OB — the candle before the strong bear move was bullish
    if is_strong_bear and close[1] > open[1]
        box.new(bar_index - 1, low[1], bar_index + ob_extend, high[1],
             border_color=color.new(color.orange, 40),
             bgcolor=ob_bear_col,
             border_width=1)

// ─────────────────────────────────────────────
// LIQUIDITY LEVELS & SWEEPS
// ─────────────────────────────────────────────

swing_high = ta.pivothigh(high, liq_lookback, liq_lookback)
swing_low  = ta.pivotlow (low,  liq_lookback, liq_lookback)

// Track last swing levels
var float last_sh = na
var float last_sl = na
var int   sh_bar  = na
var int   sl_bar  = na

if not na(swing_high)
    last_sh := swing_high
    sh_bar  := bar_index - liq_lookback

if not na(swing_low)
    last_sl := swing_low
    sl_bar  := bar_index - liq_lookback

// Draw liquidity lines
if show_liq and barstate.isconfirmed
    if not na(swing_high)
        line.new(bar_index - liq_lookback, swing_high,
                 bar_index + liq_lookback, swing_high,
                 color=liq_col, width=1, style=line.style_dotted)

    if not na(swing_low)
        line.new(bar_index - liq_lookback, swing_low,
                 bar_index + liq_lookback, swing_low,
                 color=liq_col, width=1, style=line.style_dotted)

// Sweep detection — price wicks above/below then closes back
swept_high = show_sweep and not na(last_sh) and high > last_sh and close < last_sh
swept_low  = show_sweep and not na(last_sl) and low  < last_sl and close > last_sl

if swept_high
    label.new(bar_index, high, "SWEEP ↑",
         color=sweep_bear_col, textcolor=color.white,
         style=label.style_label_down, size=size.small)

if swept_low
    label.new(bar_index, low, "SWEEP ↓",
         color=sweep_bull_col, textcolor=color.white,
         style=label.style_label_up, size=size.small)

// ─────────────────────────────────────────────
// MARKET STRUCTURE SHIFT (MSS)
// ─────────────────────────────────────────────
// Bullish MSS: price breaks above a recent swing high (after downtrend)
// Bearish MSS: price breaks below a recent swing low  (after uptrend)

mss_sh = ta.pivothigh(high, mss_lookback, mss_lookback)
mss_sl = ta.pivotlow (low,  mss_lookback, mss_lookback)

var float mss_last_sh = na
var float mss_last_sl = na

if not na(mss_sh)
    mss_last_sh := mss_sh
if not na(mss_sl)
    mss_last_sl := mss_sl

bull_mss = show_mss and not na(mss_last_sh) and ta.crossover(close,  mss_last_sh)
bear_mss = show_mss and not na(mss_last_sl) and ta.crossunder(close, mss_last_sl)

if bull_mss
    label.new(bar_index, low, "MSS ▲",
         color=mss_bull_col, textcolor=color.black,
         style=label.style_label_up, size=size.normal)
    line.new(bar_index - 1, mss_last_sh, bar_index, mss_last_sh,
         color=mss_bull_col, width=2)

if bear_mss
    label.new(bar_index, high, "MSS ▼",
         color=mss_bear_col, textcolor=color.white,
         style=label.style_label_down, size=size.normal)
    line.new(bar_index - 1, mss_last_sl, bar_index, mss_last_sl,
         color=mss_bear_col, width=2)

// ─────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────
alertcondition(bull_mss,   "Bullish MSS",    "Bullish Market Structure Shift detected")
alertcondition(bear_mss,   "Bearish MSS",    "Bearish Market Structure Shift detected")
alertcondition(swept_high, "Liquidity Sweep High", "Price swept sell-side liquidity")
alertcondition(swept_low,  "Liquidity Sweep Low",  "Price swept buy-side liquidity")
````
