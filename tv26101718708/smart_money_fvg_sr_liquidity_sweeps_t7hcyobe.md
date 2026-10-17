# Smart Money: FVG + S/R + Liquidity Sweeps

- url: https://www.tradingview.com/script/T7HCYoBE-Smart-Money-FVG-S-R-Liquidity-Sweeps/
- type: indicator
- pine_id: PUB;721bd88c0a664d88a44463ee4d5d5d6d
- version: 1.0

## Description

Built a Smart Money Concepts indicator that combines Fair Value Gaps (FVG), Support & Resistance zones, and Liquidity Sweep detection into one clean workflow for traders. 

The goal of this script is simple:
help traders understand market structure visually instead of relying on cluttered indicators or subjective charting.

What this script brings to the community:

• Automatic Fair Value Gap detection for identifying institutional imbalance zones
• Dynamic Support & Resistance zones with touch-count validation
• Liquidity Sweep detection to spot stop hunts and potential reversals
• Equal High / Equal Low mapping for liquidity pools
• Re-entry signals after FVG mitigation
• ATR-based adaptive filtering to reduce noise across different markets and timeframes
• Fully visual and beginner-friendly Smart Money Concepts workflow

I wanted to create something that bridges the gap between retail traders and institutional-style market reading without making charts unreadable.

This indicator is designed for:

* ICT / SMC traders
* Scalpers
* Swing traders
* Futures & crypto traders
* Anyone learning liquidity-based price action

The script is highly customizable and optimized for real-time chart analysis.

Would love feedback from the community and ideas for future improvements like:
• BOS / CHoCH detection
• Session liquidity mapping
• Volume profile integration
• Multi-timeframe confluence
• AI-assisted trade scoring

Open to collaboration and improvements from fellow traders and developers.

## Source Code

````pine
//@version=6
// ═══════════════════════════════════════════════════════════════
// Smart Money Concepts: FVG + Support/Resistance + Liquidity Sweeps
// Combines:
//   1. Fair Value Gap (FVG) Order Blocks
//   2. Pivot-based Support & Resistance zones with touch count
//   3. Liquidity Sweep detection with Equal Highs/Lows
// ═══════════════════════════════════════════════════════════════
indicator("Smart Money: FVG + S/R + Liquidity Sweeps", overlay = true,
         max_boxes_count  = 500,
         max_lines_count  = 500,
         max_labels_count = 500,
         max_bars_back    = 2000)

// ═══════════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════════

string grp1 = "── Fair Value Gaps (FVG) ──"
bool   show_fvg        = input.bool(true,    "Show FVG Blocks",         group = grp1, inline = "fvg1")
bool   show_fvg_zone   = input.bool(true,    "Show Gap Zone",           group = grp1, inline = "fvg1")
float  fvg_filter      = input.float(0.5,   "Filter Gaps by %",        group = grp1, minval = 0, maxval = 100, step = 0.1)
int    fvg_amount      = input.int(6,        "Max FVG Blocks",          group = grp1, minval = 1, maxval = 20)
bool   show_fvg_broken = input.bool(false,   "Show Broken FVG",         group = grp1)
bool   show_fvg_signal = input.bool(true,    "FVG Re-entry Signals",    group = grp1)
color  col_fvg_bull    = input.color(#14be94,"Bullish / Bearish",       group = grp1, inline = "fvg2")
color  col_fvg_bear    = input.color(#c21919,"",                        group = grp1, inline = "fvg2")

string grp2 = "── Support & Resistance ──"
bool   show_sr         = input.bool(true,    "Show S/R Zones",          group = grp2)
int    sr_pivot_len    = input.int(10,       "Pivot Lookback",          group = grp2, minval = 3, maxval = 50)
float  sr_atr_mult     = input.float(0.3,   "Zone Width (ATR x)",      group = grp2, minval = 0.1, maxval = 2.0, step = 0.1)
int    sr_max_zones    = input.int(5,        "Max S/R Zones",           group = grp2, minval = 1, maxval = 15)
bool   show_sr_broken  = input.bool(false,   "Show Broken S/R",         group = grp2)
color  col_sr_sup      = input.color(#1976d2,"Support / Resistance",    group = grp2, inline = "sr1")
color  col_sr_res      = input.color(#f57c00,"",                        group = grp2, inline = "sr1")

string grp3 = "── Liquidity Sweeps ──"
bool   show_sweep      = input.bool(true,    "Show Liquidity Sweeps",   group = grp3)
float  sweep_atr_mult  = input.float(0.4,   "Min Wick Size (ATR x)",   group = grp3, minval = 0.1, maxval = 3.0, step = 0.1)
bool   show_sweep_zone = input.bool(true,    "Show Sweep Zone",         group = grp3)
bool   show_eq_levels  = input.bool(true,    "Show Equal H/L Levels",   group = grp3)
float  eq_threshold    = input.float(0.1,   "Equal Level Threshold %", group = grp3, minval = 0.01, maxval = 1.0, step = 0.01)
color  col_sweep_bull  = input.color(#00e5ff,"Bull Sweep / Bear Sweep", group = grp3, inline = "sw1")
color  col_sweep_bear  = input.color(#ff1744,"",                        group = grp3, inline = "sw1")

// ═══════════════════════════════════════════════════════════════
// SHARED
// ═══════════════════════════════════════════════════════════════

float atr = ta.atr(200)

// ═══════════════════════════════════════════════════════════════
// 1. FVG ORDER BLOCKS
// ═══════════════════════════════════════════════════════════════

var array<box> fvg_boxes_bull = array.new<box>()
var array<box> fvg_boxes_bear = array.new<box>()

float filt_up = (low    - high[2]) / low    * 100
float filt_dn = (low[2] - high)    / low[2] * 100
float max_up  = ta.highest(filt_up, 200)
float max_dn  = ta.highest(filt_dn, 200)

bool isBull_fvg = barstate.isconfirmed
     and high[2] < low  and high[2] < high[1] and low[2] < low
     and filt_up > fvg_filter

bool isBear_fvg = barstate.isconfirmed
     and low[2] > high and low[2] > low[1] and high[2] > high
     and filt_dn > fvg_filter

// Create bullish FVG block
if isBull_fvg and show_fvg
    if show_fvg_zone
        box.new(bar_index - 1, low, bar_index + 5, high[2],
             border_color = na,
             border_width = 0,
             bgcolor      = color.from_gradient(filt_up, 0, max_up, color.new(chart.fg_color, 92), color.new(chart.fg_color, 72)),
             text         = "FVG +" + str.tostring(filt_up, format.percent),
             text_color   = chart.fg_color,
             text_size    = size.tiny)

    box newBull = box.new(bar_index - 1, high[2], last_bar_index, high[2] - atr,
             border_color = col_fvg_bull,
             border_width = 1,
             bgcolor      = color.from_gradient(filt_up, 0, max_up, color.new(col_fvg_bull, 95), color.new(col_fvg_bull, 72)),
             text         = "▲ FVG " + str.tostring(filt_up, format.percent),
             text_size    = size.small,
             text_color   = chart.fg_color,
             text_halign  = text.align_right)
    array.push(fvg_boxes_bull, newBull)

// Create bearish FVG block
if isBear_fvg and show_fvg
    if show_fvg_zone
        box.new(bar_index - 1, low[2], bar_index + 5, high,
             border_color = na,
             border_width = 0,
             bgcolor      = color.from_gradient(filt_dn, 0, max_dn, color.new(chart.fg_color, 92), color.new(chart.fg_color, 72)),
             text         = "FVG -" + str.tostring(filt_dn, format.percent),
             text_color   = chart.fg_color,
             text_size    = size.tiny)

    box newBear = box.new(bar_index - 1, low[2] + atr, last_bar_index, low[2],
             border_color = col_fvg_bear,
             border_width = 1,
             bgcolor      = color.from_gradient(filt_dn, 0, max_dn, color.new(col_fvg_bear, 95), color.new(col_fvg_bear, 72)),
             text         = "▼ FVG " + str.tostring(filt_dn, format.percent),
             text_size    = size.small,
             text_color   = chart.fg_color,
             text_halign  = text.align_right)
    array.push(fvg_boxes_bear, newBear)

// Extend FVG boxes to current bar
if barstate.islast
    for fvgB in fvg_boxes_bull
        box.set_right(fvgB, bar_index + 15)
    for fvgB in fvg_boxes_bear
        box.set_right(fvgB, bar_index + 15)

// Manage broken bullish FVG blocks — reverse loop for safe removal
int fvgBullSize = array.size(fvg_boxes_bull)
if fvgBullSize > 0
    for idx = fvgBullSize - 1 to 0
        box   fvgB = array.get(fvg_boxes_bull, idx)
        float bTop = box.get_top(fvgB)
        float bBot = box.get_bottom(fvgB)
        if high < bBot
            if show_fvg_broken
                box.set_border_width(fvgB, 0)
                box.set_bgcolor(fvgB, color.new(chart.fg_color, 88))
            else
                box.delete(fvgB)
                array.remove(fvg_boxes_bull, idx)
        else if low > bTop and low[1] <= bTop and not isBull_fvg and show_fvg_signal
            label.new(bar_index - 1, low[1], "▲",
                 color     = color(na),
                 textcolor = col_fvg_bull,
                 style     = label.style_label_up,
                 size      = size.small)

// Manage broken bearish FVG blocks — reverse loop for safe removal
int fvgBearSize = array.size(fvg_boxes_bear)
if fvgBearSize > 0
    for idx = fvgBearSize - 1 to 0
        box   fvgB = array.get(fvg_boxes_bear, idx)
        float bTop = box.get_top(fvgB)
        float bBot = box.get_bottom(fvgB)
        if low > bTop
            if show_fvg_broken
                box.set_border_width(fvgB, 0)
                box.set_bgcolor(fvgB, color.new(chart.fg_color, 88))
            else
                box.delete(fvgB)
                array.remove(fvg_boxes_bear, idx)
        else if high < bBot and high[1] >= bBot and not isBear_fvg and show_fvg_signal
            label.new(bar_index - 1, high[1], "▼",
                 color     = color(na),
                 textcolor = col_fvg_bear,
                 style     = label.style_label_down,
                 size      = size.small)

// Cap FVG box count
if array.size(fvg_boxes_bull) > fvg_amount
    box.delete(array.shift(fvg_boxes_bull))
if array.size(fvg_boxes_bear) > fvg_amount
    box.delete(array.shift(fvg_boxes_bear))


// ═══════════════════════════════════════════════════════════════
// 2. SUPPORT & RESISTANCE ZONES
// ═══════════════════════════════════════════════════════════════

var array<box> sr_sup_boxes   = array.new<box>()
var array<box> sr_res_boxes   = array.new<box>()
var array<int> sr_sup_touches = array.new<int>()
var array<int> sr_res_touches = array.new<int>()

float pivotHigh = ta.pivothigh(high, sr_pivot_len, sr_pivot_len)
float pivotLow  = ta.pivotlow(low,   sr_pivot_len, sr_pivot_len)
float sr_zone   = atr * sr_atr_mult

// ── Resistance zones from pivot highs ─────────────────────────
if not na(pivotHigh) and show_sr
    float rLevel = pivotHigh
    bool  rFound = false
    int   rSize  = array.size(sr_res_boxes)

    if rSize > 0
        for ri = 0 to rSize - 1
            box   rb   = array.get(sr_res_boxes, ri)
            float rTop = box.get_top(rb)
            float rBot = box.get_bottom(rb)
            if rLevel >= rBot and rLevel <= rTop
                rFound := true
                int rTouches = array.get(sr_res_touches, ri) + 1
                array.set(sr_res_touches, ri, rTouches)
                box.set_bgcolor(rb, color.new(col_sr_res, math.max(30, 85 - rTouches * 10)))
                box.set_text(rb, "R · " + str.tostring(rTouches) + " touches")

    if not rFound
        box newR = box.new(bar_index - sr_pivot_len, rLevel + sr_zone, last_bar_index, rLevel - sr_zone,
                 border_color = col_sr_res,
                 border_width = 1,
                 border_style = line.style_dashed,
                 bgcolor      = color.new(col_sr_res, 82),
                 text         = "Resistance",
                 text_size    = size.small,
                 text_color   = col_sr_res,
                 text_halign  = text.align_right)
        array.push(sr_res_boxes, newR)
        array.push(sr_res_touches, 1)

// ── Support zones from pivot lows ─────────────────────────────
if not na(pivotLow) and show_sr
    float sLevel = pivotLow
    bool  sFound = false
    int   sSize  = array.size(sr_sup_boxes)

    if sSize > 0
        for si = 0 to sSize - 1
            box   sb   = array.get(sr_sup_boxes, si)
            float sTop = box.get_top(sb)
            float sBot = box.get_bottom(sb)
            if sLevel >= sBot and sLevel <= sTop
                sFound := true
                int sTouches = array.get(sr_sup_touches, si) + 1
                array.set(sr_sup_touches, si, sTouches)
                box.set_bgcolor(sb, color.new(col_sr_sup, math.max(30, 85 - sTouches * 10)))
                box.set_text(sb, "S · " + str.tostring(sTouches) + " touches")

    if not sFound
        box newS = box.new(bar_index - sr_pivot_len, sLevel + sr_zone, last_bar_index, sLevel - sr_zone,
                 border_color = col_sr_sup,
                 border_width = 1,
                 border_style = line.style_dashed,
                 bgcolor      = color.new(col_sr_sup, 82),
                 text         = "Support",
                 text_size    = size.small,
                 text_color   = col_sr_sup,
                 text_halign  = text.align_right)
        array.push(sr_sup_boxes, newS)
        array.push(sr_sup_touches, 1)

// Extend S/R boxes to current bar
if barstate.islast
    for srB in sr_sup_boxes
        box.set_right(srB, bar_index + 20)
    for srB in sr_res_boxes
        box.set_right(srB, bar_index + 20)

// Broken support — reverse loop for safe removal
int supSize = array.size(sr_sup_boxes)
if supSize > 0
    for si = supSize - 1 to 0
        box   sb  = array.get(sr_sup_boxes, si)
        float bot = box.get_bottom(sb)
        if close < bot and close[1] >= bot
            if show_sr_broken
                box.set_bgcolor(sb, color.new(chart.fg_color, 90))
                box.set_border_color(sb, color.new(chart.fg_color, 60))
            else
                box.delete(sb)
                array.remove(sr_sup_boxes, si)
                array.remove(sr_sup_touches, si)

// Broken resistance — reverse loop for safe removal
int resSize = array.size(sr_res_boxes)
if resSize > 0
    for ri = resSize - 1 to 0
        box   rb  = array.get(sr_res_boxes, ri)
        float top = box.get_top(rb)
        if close > top and close[1] <= top
            if show_sr_broken
                box.set_bgcolor(rb, color.new(chart.fg_color, 90))
                box.set_border_color(rb, color.new(chart.fg_color, 60))
            else
                box.delete(rb)
                array.remove(sr_res_boxes, ri)
                array.remove(sr_res_touches, ri)

// Cap S/R zone count
if array.size(sr_sup_boxes) > sr_max_zones
    box.delete(array.shift(sr_sup_boxes))
    array.shift(sr_sup_touches)
if array.size(sr_res_boxes) > sr_max_zones
    box.delete(array.shift(sr_res_boxes))
    array.shift(sr_res_touches)


// ═══════════════════════════════════════════════════════════════
// 3. LIQUIDITY SWEEPS
// ═══════════════════════════════════════════════════════════════

var array<box> sweep_boxes = array.new<box>()

float min_wick       = atr * sweep_atr_mult
float recentSwingLow = ta.lowest(low,   20)[1]
float recentSwingHgh = ta.highest(high, 20)[1]

// Bullish sweep: wick pierces below swing low, closes back above
bool bull_sweep = barstate.isconfirmed
     and low   < recentSwingLow
     and close > recentSwingLow
     and (close - low) > min_wick

// Bearish sweep: wick pierces above swing high, closes back below
bool bear_sweep = barstate.isconfirmed
     and high  > recentSwingHgh
     and close < recentSwingHgh
     and (high - close) > min_wick

if bull_sweep and show_sweep
    label.new(bar_index, low, "💧 Liq. Sweep",
         color     = color.new(col_sweep_bull, 20),
         textcolor = color.white,
         style     = label.style_label_up,
         size      = size.small)
    if show_sweep_zone
        box swB = box.new(bar_index - 2, recentSwingLow, bar_index + 10, low,
                 border_color = col_sweep_bull,
                 border_width = 1,
                 bgcolor      = color.new(col_sweep_bull, 80),
                 text         = "Sell-Side Liq. Swept",
                 text_size    = size.tiny,
                 text_color   = col_sweep_bull)
        array.push(sweep_boxes, swB)

if bear_sweep and show_sweep
    label.new(bar_index, high, "💧 Liq. Sweep",
         color     = color.new(col_sweep_bear, 20),
         textcolor = color.white,
         style     = label.style_label_down,
         size      = size.small)
    if show_sweep_zone
        box swB = box.new(bar_index - 2, high, bar_index + 10, recentSwingHgh,
                 border_color = col_sweep_bear,
                 border_width = 1,
                 bgcolor      = color.new(col_sweep_bear, 80),
                 text         = "Buy-Side Liq. Swept",
                 text_size    = size.tiny,
                 text_color   = col_sweep_bear)
        array.push(sweep_boxes, swB)

// Equal Highs / Equal Lows
if show_eq_levels
    float eq_range = close * eq_threshold / 100

    if math.abs(high[1] - high[2]) < eq_range and high[1] > high[3] and high[1] > high
        line.new(bar_index - 2, high[1], bar_index + 20, high[1],
                 color = color.new(col_sweep_bear, 30), width = 1, style = line.style_dotted)
        label.new(bar_index, high[1], "EQH",
                 color     = color(na),
                 textcolor = col_sweep_bear,
                 style     = label.style_label_left,
                 size      = size.tiny)

    if math.abs(low[1] - low[2]) < eq_range and low[1] < low[3] and low[1] < low
        line.new(bar_index - 2, low[1], bar_index + 20, low[1],
                 color = color.new(col_sweep_bull, 30), width = 1, style = line.style_dotted)
        label.new(bar_index, low[1], "EQL",
                 color     = color(na),
                 textcolor = col_sweep_bull,
                 style     = label.style_label_left,
                 size      = size.tiny)

// Extend sweep boxes
if barstate.islast
    for swB in sweep_boxes
        box.set_right(swB, bar_index + 15)

// Cap sweep box count
if array.size(sweep_boxes) > 10
    box.delete(array.shift(sweep_boxes))


// ═══════════════════════════════════════════════════════════════
// ALERTS
// ═══════════════════════════════════════════════════════════════

alertcondition(isBull_fvg,               "Bullish FVG Detected",    "A bullish Fair Value Gap has formed")
alertcondition(isBear_fvg,               "Bearish FVG Detected",    "A bearish Fair Value Gap has formed")
alertcondition(bull_sweep,               "Bullish Liquidity Sweep", "Sell-side liquidity swept — potential long")
alertcondition(bear_sweep,               "Bearish Liquidity Sweep", "Buy-side liquidity swept — potential short")
alertcondition(bull_sweep or bear_sweep, "Any Liquidity Sweep",     "Liquidity sweep detected")
````
