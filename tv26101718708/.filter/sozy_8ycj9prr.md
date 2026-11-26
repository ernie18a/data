# sozy

- url: https://www.tradingview.com/script/8YCj9prr-sozy/
- type: indicator
- pine_id: PUB;14793c681d344e7cb50c760794d7ef3d
- version: 1.0

## Description

absorption indicator can be used to see where big players absorb orders.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Bleh89

//@version=5
indicator("Absorption Zone+", overlay=true, max_boxes_count=500, max_labels_count=500, max_lines_count=500)

// ══════════════════════════════════════════════════════════════════════════════
// INPUTS
// ══════════════════════════════════════════════════════════════════════════════

var string g1 = "Absorption Settings"
var string g2 = "Imbalance Settings"
var string g3 = "Filter Settings"

i_body_thresh  = input.float(0.6,   "Body Size Threshold",          minval=0.1,  maxval=1.0,  step=0.05, group=g1,
                              tooltip="Candle body must be less than this % of the full candle range")
i_vol_mult     = input.float(1.5,   "Volume Multiplier",            minval=0.5,  maxval=10.0, step=0.1,  group=g1,
                              tooltip="Volume must exceed this multiple of the rolling average")
i_vol_len      = input.int  (20,    "Volume Average Length",        minval=5,    maxval=100,             group=g1,
                              tooltip="Lookback for average volume calculation")
i_min_rng      = input.float(0.25,  "Min Candle Range (ATR mult)",  minval=0.05, maxval=2.0,  step=0.05, group=g1,
                              tooltip="Filters out tiny illiquid candles")
i_col_bull     = input.color(color.new(#00e5ff,  0),  "Bullish Absorption Color", group=g1)
i_col_bear     = input.color(color.new(#ff1744,  0),  "Bearish Absorption Color", group=g1)
i_bull_bg      = input.color(color.new(#00e5ff, 85),  "Bullish Candle BG",        group=g1)
i_bear_bg      = input.color(color.new(#ff1744, 85),  "Bearish Candle BG",        group=g1)

i_show_imb     = input.bool (false, "Show Imbalance Boxes?",                                             group=g2)
i_col_imb_bull = input.color(color.new(#00e5ff, 80),  "Bullish Imbalance",        group=g2)
i_col_imb_bear = input.color(color.new(#ff1744, 80),  "Bearish Imbalance",        group=g2)
i_show_mid     = input.bool (true,  "Show Imbalance Midpoint?",                                          group=g2)
i_extend_cur   = input.bool (true,  "Extend to Current Price?",                                          group=g2)
i_imb_ext      = input.int  (7,     "Extend Boxes (Bars)",          minval=1,    maxval=100,             group=g2)
i_max_imb      = input.int  (5,     "Max Imbalances Per Session",   minval=1,    maxval=50,              group=g2)

i_isolate      = input.bool (false, "Isolate to Structure?",                                             group=g3,
                              tooltip="When ON only shows absorption near key highs and lows")
i_struct_len   = input.int  (50,    "Structure Lookback (bars)",    minval=10,   maxval=500,             group=g3)
i_struct_atr   = input.float(3.0,   "Structure Proximity (ATR)",   minval=0.5,  maxval=20.0, step=0.5,  group=g3)
i_confirm      = input.bool (true,  "Require Next Bar Confirm?",                                         group=g3,
                              tooltip="When ON waits for next candle to confirm the absorption before painting")
i_trend_filter = input.bool (false, "Trend Filter?",                                                     group=g3,
                              tooltip="Only show bullish absorption in uptrend and bearish in downtrend")
i_trend_len    = input.int  (50,    "Trend EMA Length",             minval=5,    maxval=500,             group=g3)

// ══════════════════════════════════════════════════════════════════════════════
// BASE CALCULATIONS
// ══════════════════════════════════════════════════════════════════════════════

float atr        = ta.atr(14)
float avg_vol    = ta.sma(volume, i_vol_len)
float body       = math.abs(close - open)
float candle_rng = high - low
float body_ratio = candle_rng > 0 ? body / candle_rng : 1.0
float ema_trend  = ta.ema(close, i_trend_len)

bool  uptrend    = close > ema_trend
bool  downtrend  = close < ema_trend

// ══════════════════════════════════════════════════════════════════════════════
// STRUCTURE LEVELS
// ══════════════════════════════════════════════════════════════════════════════

float s_hi    = ta.highest(high, i_struct_len)
float s_lo    = ta.lowest (low,  i_struct_len)
float prox    = atr * i_struct_atr
bool  near_hi = math.abs(high - s_hi) <= prox
bool  near_lo = math.abs(low  - s_lo) <= prox

// ══════════════════════════════════════════════════════════════════════════════
// ABSORPTION DETECTION
// ══════════════════════════════════════════════════════════════════════════════

bool is_absorb   = body_ratio   < i_body_thresh
                 and volume     > avg_vol * i_vol_mult
                 and candle_rng > atr * i_min_rng

bool raw_bull    = is_absorb and close >= open
bool raw_bear    = is_absorb and close <  open

// Structure isolation filter
bool struct_bull = not i_isolate or near_lo
bool struct_bear = not i_isolate or near_hi

// Trend filter
bool trend_bull  = not i_trend_filter or uptrend
bool trend_bear  = not i_trend_filter or downtrend

// Confirmation filter — wait for next bar to close in the expected direction
bool confirm_bull = not i_confirm or close > close[1]
bool confirm_bear = not i_confirm or close < close[1]

// Final signals
bool bull_absorb = raw_bull[1] and struct_bull[1] and trend_bull[1] and (not i_confirm or close > open)
bool bear_absorb = raw_bear[1] and struct_bear[1] and trend_bear[1] and (not i_confirm or close < open)

// Without confirmation — immediate paint
bool bull_raw_final = raw_bull and struct_bull and trend_bull and not i_confirm
bool bear_raw_final = raw_bear and struct_bear and trend_bear and not i_confirm

// ══════════════════════════════════════════════════════════════════════════════
// CANDLE COLORING
// Paints the absorption candle body with full OHLC override
// ══════════════════════════════════════════════════════════════════════════════

bool paint_bull = i_confirm ? bull_absorb : bull_raw_final
bool paint_bear = i_confirm ? bear_absorb : bear_raw_final

barcolor(paint_bull ? i_col_bull : paint_bear ? i_col_bear : na)

// ══════════════════════════════════════════════════════════════════════════════
// VOLUME DELTA LABEL — shows relative volume strength on absorption candle
// Small label above/below showing how strong the absorption was
// ══════════════════════════════════════════════════════════════════════════════

float vol_ratio = volume / avg_vol

if paint_bull
    label.new(
         x         = bar_index,
         y         = low - atr * 0.5,
         text      = str.tostring(math.round(vol_ratio, 1)) + "x",
         color     = color.new(color.black, 100),
         textcolor = i_col_bull,
         style     = label.style_label_up,
         size      = size.tiny)

if paint_bear
    label.new(
         x         = bar_index,
         y         = high + atr * 0.5,
         text      = str.tostring(math.round(vol_ratio, 1)) + "x",
         color     = color.new(color.black, 100),
         textcolor = i_col_bear,
         style     = label.style_label_down,
         size      = size.tiny)

// ══════════════════════════════════════════════════════════════════════════════
// IMBALANCE (FVG) BOXES
// ══════════════════════════════════════════════════════════════════════════════

var int bull_count = 0
var int bear_count = 0

if ta.change(time("D")) != 0
    bull_count := 0
    bear_count := 0

if i_show_imb

    // Reference bar depends on confirmation mode
    bool b_bull = i_confirm ? bull_absorb : bull_raw_final[1]
    bool b_bear = i_confirm ? bear_absorb : bear_raw_final[1]

    bool bull_fvg = b_bull and low > high[2]
    bool bear_fvg = b_bear and high < low[2]

    if bull_fvg and bull_count < i_max_imb
        float top   = low
        float bot   = high[2]
        float mid   = (top + bot) / 2.0
        int   ext_r = i_extend_cur ? bar_index + 500 : bar_index + i_imb_ext
        box.new(
             left         = bar_index - 1,
             top          = top,
             right        = ext_r,
             bottom       = bot,
             border_color = color.new(#00e5ff, 20),
             border_width = 1,
             bgcolor      = i_col_imb_bull)
        if i_show_mid
            line.new(
                 x1    = bar_index - 1,
                 y1    = mid,
                 x2    = ext_r,
                 y2    = mid,
                 color = color.new(#00e5ff, 40),
                 style = line.style_dotted,
                 width = 1)
        bull_count += 1

    if bear_fvg and bear_count < i_max_imb
        float top   = low[2]
        float bot   = high
        float mid   = (top + bot) / 2.0
        int   ext_r = i_extend_cur ? bar_index + 500 : bar_index + i_imb_ext
        box.new(
             left         = bar_index - 1,
             top          = top,
             right        = ext_r,
             bottom       = bot,
             border_color = color.new(#ff1744, 20),
             border_width = 1,
             bgcolor      = i_col_imb_bear)
        if i_show_mid
            line.new(
                 x1    = bar_index - 1,
                 y1    = mid,
                 x2    = ext_r,
                 y2    = mid,
                 color = color.new(#ff1744, 40),
                 style = line.style_dotted,
                 width = 1)
        bear_count += 1
````
