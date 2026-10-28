# HARNIKK Trend Reversal Detector [HARSHAL & NIKKY]

- url: https://www.tradingview.com/script/mfsBOxlU-HARNIKK-Trend-Reversal-Detector-HARSHAL-NIKKY/
- type: indicator
- pine_id: PUB;c076aaa6f2dc4d0482db106121ed0357
- version: 1.0

## Description

HARSHAL AND NIKKY FAVOURITE 

This is a multi-confluence trend reversal indicator built for TradingView (Pine Script v6). It detects potential BUY and SELL reversal points on any chart by combining 5 independent signals and only fires an alert when enough of them agree.

#	Signal	Bullish Trigger	Bearish Trigger
1	Break of Structure	Price breaks above last swing low	Price breaks below last swing high
2	RSI Divergence	Price makes lower low, RSI makes higher low	Price makes higher high, RSI makes lower high
3	Volume Confirmation	Volume spikes above MA × multiplier	Same condition
4	Candlestick Patterns	Hammer, Bullish Engulfing, Morning Star	Shooting Star, Bearish Engulfing, Evening Star
5	Trendline Break	Price breaks above falling trendline	Price breaks below rising trendline

## Source Code

````pine
//@version=6
indicator("HARNIKK Trend Reversal Detector [All Signals]", overlay=true, max_bars_back=500, max_lines_count=50, max_labels_count=100)

// ─────────────────────────────────────────────
//  INPUTS
// ─────────────────────────────────────────────
grp_bos     = "Break of Structure"
bos_len     = input.int(10,    "Swing Lookback",       group=grp_bos, minval=3)

grp_rsi     = "RSI Divergence"
rsi_len     = input.int(14,    "RSI Length",           group=grp_rsi)
rsi_lkbk    = input.int(5,     "Divergence Lookback",  group=grp_rsi, minval=2)

grp_vol     = "Volume Confirmation"
vol_mult    = input.float(1.5, "Volume Multiplier",    group=grp_vol, minval=1.0, step=0.1)
vol_ma_len  = input.int(20,    "Volume MA Length",     group=grp_vol)

grp_cdl     = "Candlestick Patterns"
use_hammer  = input.bool(true, "Hammer / Shooting Star", group=grp_cdl)
use_engulf  = input.bool(true, "Engulfing",              group=grp_cdl)
use_star    = input.bool(true, "Morning / Evening Star", group=grp_cdl)

grp_tl      = "Trendline Break"
tl_len      = input.int(20,    "Trendline Pivot Length", group=grp_tl, minval=5)

grp_filt    = "Signal Filter"
min_signals = input.int(2,     "Min Signals Required (1–5)", group=grp_filt, minval=1, maxval=5)

grp_sr      = "Support / Resistance Lines"
sr_extend   = input.int(40,    "Extend Lines (bars)",  group=grp_sr, minval=5)

// ─────────────────────────────────────────────
//  HELPERS
// ─────────────────────────────────────────────
body        = math.abs(close - open)
upper_wick  = high - math.max(close, open)
lower_wick  = math.min(close, open) - low
avg_body    = ta.sma(body, 14)

// ─────────────────────────────────────────────
//  1. BREAK OF STRUCTURE
// ─────────────────────────────────────────────
swing_high = ta.pivothigh(high, bos_len, bos_len)
swing_low  = ta.pivotlow (low,  bos_len, bos_len)

var float last_hh = na
var float last_ll = na

if not na(swing_high)
    last_hh := swing_high
if not na(swing_low)
    last_ll := swing_low

// ── FIX (CW10002) ────────────────────────────
// ta.crossunder / ta.crossover MUST be assigned at the global (unconditional)
// scope BEFORE being used in a boolean expression.  Wrapping them inside
// `not na(last_hh) and ta.crossunder(…)` prevented them from running on
// every bar, corrupting their internal history buffers.
// Solution: pre-compute every cross call at the top level, then gate with na-checks.
// ─────────────────────────────────────────────
_cross_under_hh = ta.crossunder(close, last_hh[bos_len])
_cross_over_ll  = ta.crossover (close, last_ll[bos_len])

bos_bearish = not na(last_hh) and _cross_under_hh
bos_bullish = not na(last_ll) and _cross_over_ll

// ─────────────────────────────────────────────
//  2. RSI DIVERGENCE
// ─────────────────────────────────────────────
rsi = ta.rsi(close, rsi_len)

price_hh = ta.highest(high, rsi_lkbk)
price_ll = ta.lowest (low,  rsi_lkbk)
rsi_hh   = ta.highest(rsi,  rsi_lkbk)
rsi_ll   = ta.lowest (rsi,  rsi_lkbk)

// Bearish divergence: price makes higher high, RSI makes lower high
bear_div = high >= price_hh and rsi < rsi_hh[1]
// Bullish divergence: price makes lower low, RSI makes higher low
bull_div = low  <= price_ll and rsi > rsi_ll[1]

// ─────────────────────────────────────────────
//  3. VOLUME CONFIRMATION
// ─────────────────────────────────────────────
vol_ma    = ta.sma(volume, vol_ma_len)
vol_spike = volume > vol_ma * vol_mult

// ─────────────────────────────────────────────
//  4. CANDLESTICK PATTERNS
// ─────────────────────────────────────────────
// — Hammer (bullish) & Shooting Star (bearish)
hammer        = use_hammer and lower_wick >= body * 2 and upper_wick <= body * 0.5 and close > open
shooting_star = use_hammer and upper_wick >= body * 2 and lower_wick <= body * 0.5 and close < open

// — Bullish & Bearish Engulfing
bull_engulf = use_engulf and close[1] < open[1] and close > open and
     close >= open[1] and open <= close[1]
bear_engulf = use_engulf and close[1] > open[1] and close < open and
     close <= open[1] and open >= close[1]

// — Morning Star (3-bar bullish) & Evening Star (3-bar bearish)
doji_body = body[1] < avg_body[1] * 0.3
morn_star = use_star and close[2] < open[2] and doji_body and close > open and
     close > (open[2] + close[2]) / 2
even_star = use_star and close[2] > open[2] and doji_body and close < open and
     close < (open[2] + close[2]) / 2

cdl_bull = hammer or bull_engulf or morn_star
cdl_bear  = shooting_star or bear_engulf or even_star

// ─────────────────────────────────────────────
//  5. TRENDLINE BREAK
// ─────────────────────────────────────────────
tl_high = ta.pivothigh(high, tl_len, tl_len)
tl_low  = ta.pivotlow (low,  tl_len, tl_len)

var float prev_tl_high     = na
var float prev_tl_low      = na
var int   prev_tl_high_bar = na
var int   prev_tl_low_bar  = na

if not na(tl_high)
    prev_tl_high     := tl_high
    prev_tl_high_bar := bar_index - tl_len

if not na(tl_low)
    prev_tl_low     := tl_low
    prev_tl_low_bar := bar_index - tl_len

// Project trendline slope from last two swings
var float tl_slope_up = na
var float tl_slope_dn = na

if not na(prev_tl_low)
    tl_slope_up := (prev_tl_low - prev_tl_low[1]) /
         math.max(bar_index - prev_tl_low_bar, 1)

if not na(prev_tl_high)
    tl_slope_dn := (prev_tl_high - prev_tl_high[1]) /
         math.max(bar_index - prev_tl_high_bar, 1)

tl_proj_up = not na(prev_tl_low)  ? prev_tl_low  + tl_slope_up * (bar_index - prev_tl_low_bar)  : na
tl_proj_dn = not na(prev_tl_high) ? prev_tl_high + tl_slope_dn * (bar_index - prev_tl_high_bar) : na

// ── FIX (CW10002) ────────────────────────────
// Same issue as BOS: ta.crossunder / ta.crossover called inside a conditional
// compound expression (not na(tl_proj_up) and ta.crossunder(…)) is illegal.
// Pre-assign each cross result unconditionally, then gate with the na-check.
// nz() converts na to 0.0 so the cross function always receives a valid float.
// ─────────────────────────────────────────────
_cross_under_tl = ta.crossunder(close, nz(tl_proj_up))
_cross_over_tl  = ta.crossover (close, nz(tl_proj_dn))

tl_break_bear = not na(tl_proj_up) and _cross_under_tl
tl_break_bull = not na(tl_proj_dn) and _cross_over_tl

// ─────────────────────────────────────────────
//  SIGNAL CONFLUENCE SCORE
// ─────────────────────────────────────────────
bull_score = (bos_bullish   ? 1 : 0) +
             (bull_div      ? 1 : 0) +
             (vol_spike     ? 1 : 0) +
             (cdl_bull      ? 1 : 0) +
             (tl_break_bull ? 1 : 0)

bear_score = (bos_bearish   ? 1 : 0) +
             (bear_div      ? 1 : 0) +
             (vol_spike     ? 1 : 0) +
             (cdl_bear      ? 1 : 0) +
             (tl_break_bear ? 1 : 0)

bull_signal = bull_score >= min_signals
bear_signal = bear_score >= min_signals

// ─────────────────────────────────────────────
//  BUY / SELL LABELS
// ─────────────────────────────────────────────
signal_str(score) =>
    score == 5 ? "★★★★★" :
     score == 4 ? "★★★★☆" :
     score == 3 ? "★★★☆☆" :
     score == 2 ? "★★☆☆☆" : "★☆☆☆☆"

if bull_signal
    label.new(
         bar_index, low * 0.998,
         "BUY\n" + signal_str(bull_score),
         style     = label.style_label_up,
         color     = color.new(color.teal, 15),
         textcolor = color.white,
         size      = size.normal)

if bear_signal
    label.new(
         bar_index, high * 1.002,
         "SELL\n" + signal_str(bear_score),
         style     = label.style_label_down,
         color     = color.new(color.red, 15),
         textcolor = color.white,
         size      = size.normal)

// ─────────────────────────────────────────────
//  SUPPORT / RESISTANCE LINES
// ─────────────────────────────────────────────
if not na(swing_high)
    line.new(
         bar_index - bos_len, swing_high,
         bar_index - bos_len + sr_extend, swing_high,
         color = color.new(color.red, 50),
         width = 1,
         style = line.style_dashed)

if not na(swing_low)
    line.new(
         bar_index - bos_len, swing_low,
         bar_index - bos_len + sr_extend, swing_low,
         color = color.new(color.teal, 50),
         width = 1,
         style = line.style_dashed)

// ─────────────────────────────────────────────
//  RSI PANEL (separate pane)
// ─────────────────────────────────────────────
plot(rsi, "RSI", color=color.gray, display=display.pane)
hline(70, "OB",  color=color.new(color.red,  60), linestyle=hline.style_dashed)
hline(30, "OS",  color=color.new(color.teal, 60), linestyle=hline.style_dashed)
hline(50, "Mid", color=color.new(color.gray, 70), linestyle=hline.style_dotted)

// Colour RSI line by divergence
rsi_col = bull_div ? color.teal : bear_div ? color.red : color.gray
plot(rsi, "RSI Coloured", color=rsi_col, linewidth=2, display=display.pane)

// Mark divergences on RSI pane
plotshape(bull_div, "Bull Div", shape.circle, location.absolute,
     color.new(color.teal, 20), size=size.tiny, display=display.pane)
plotshape(bear_div, "Bear Div", shape.circle, location.absolute,
     color.new(color.red,  20), size=size.tiny, display=display.pane)

// ─────────────────────────────────────────────
//  VOLUME BAR COLOURING (main pane)
// ─────────────────────────────────────────────
vol_color = vol_spike and bull_signal ? color.new(color.teal,   20) :
             vol_spike and bear_signal ? color.new(color.red,    20) :
             vol_spike                  ? color.new(color.orange, 30) :
             close >= open              ? color.new(color.teal,   60) :
                                          color.new(color.red,    60)

// ─────────────────────────────────────────────
//  ALERTS
// ── FIX (CE10123) ────────────────────────────
// alertcondition() `message` must be a CONST string — no runtime expressions,
// no str.tostring(), no string concatenation with dynamic variables.
// Removed "+ str.tostring(bull_score) + …" and replaced with static text.
// Dynamic score info is surfaced via the on-chart label instead.
// ─────────────────────────────────────────────
alertcondition(bull_signal, "Bullish Reversal",
     "Bullish reversal detected — check chart label for signal score")
alertcondition(bear_signal, "Bearish Reversal",
     "Bearish reversal detected — check chart label for signal score")
alertcondition(bull_signal or bear_signal, "Any Reversal",
     "Reversal signal detected — check chart label for details")
````
