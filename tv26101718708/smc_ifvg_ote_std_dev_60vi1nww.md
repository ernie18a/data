# SMC: IFVG + OTE + Std Dev

- url: https://www.tradingview.com/script/60vI1nWw-SMC-IFVG-OTE-Std-Dev/
- type: indicator
- pine_id: PUB;658fa1d1f3ee44569c94fc778423a853
- version: 1.0

## Description

This indicator combines three Smart Money Concepts (SMC) tools into a single, 
clean overlay — designed for traders who want institutional-grade confluence 
without cluttering their chart with five separate indicators.

─────────────────────────────────────
 WHAT'S INCLUDED
─────────────────────────────────────

① INVERSE FAIR VALUE GAP (IFVG)
Fair Value Gaps are 3-candle price imbalances created when a strong move leaves 
a gap between candle wicks. Price tends to return and fill them.

When a FVG is fully mitigated (price closes through the midpoint), it flips 
polarity — a bullish FVG becomes a bearish resistance zone, and vice versa. 
This is the Inverse FVG.

- Bullish FVGs drawn in teal
- Bearish FVGs drawn in red
- Mitigated and flipped IFVGs redraw in orange/purple with dashed border
- "IFVG Bullish" / "IFVG Bearish" labels mark the flip point
- Minimum gap size filter using ATR to eliminate noise
- Auto-expiry after adjustable lookback period


② OTE — OPTIMAL TRADE ENTRY ZONE
The OTE is the Fibonacci retracement zone between 62% and 79% of the most 
recent swing — the "golden pocket" where institutional orders are most likely 
to be placed.

- Automatically detects the current swing high and swing low
- Draws the 62%–79% retracement zone as dashed lines
- Labelled "OTE Buy Zone" or "OTE Sell Zone" based on directional bias
- Background highlights when price is actively inside the OTE zone
- Alerts fire when price enters the zone


③ STANDARD DEVIATION CHANNELS
A statistical price channel based on a simple moving average and standard 
deviation bands. Useful for identifying overextension, mean reversion targets, 
and whether current price is at a statistically extreme level.

- Basis line: 20-period SMA (adjustable)
- 1σ bands in yellow — normal range
- 2σ bands in orange — overextension zone
- Inner band fill for visual clarity
- Dashboard shows exact position relative to bands


─────────────────────────────────────
 HOW TO USE IT
─────────────────────────────────────

STEP 1 — CHECK THE DASHBOARD (top right)
The dashboard shows your directional bias, whether price is in an OTE zone, 
where price sits relative to standard deviation, and how many live and inverse 
FVGs are on the chart.

STEP 2 — READ THE STANDARD DEVIATION
- Price inside the 1σ band = normal, ranging conditions
- Price touching 1σ = momentum building
- Price at 2σ = overextended, look for mean reversion setups or be cautious 
  chasing the move

STEP 3 — WATCH FOR IFVG FORMATION
When a FVG flips to an IFVG, the zone has changed polarity. A bullish FVG 
that gets mitigated becomes resistance. A bearish FVG that gets mitigated 
becomes support. These are high-probability reaction zones.

Best use: wait for price to return to an IFVG zone, then look for a 
confirmation candle (engulfing, pin bar) before entering.

STEP 4 — WAIT FOR THE OTE PULLBACK
After a displacement move in your direction of bias, wait for price to retrace 
into the 62%–79% zone. This is where institutions re-enter. 

Best use: combine with a ChoCH or engulfing candle inside the OTE zone for 
maximum confluence before entry.

STEP 5 — CONFLUENCE CHECK
Highest probability setups occur when:
✓ Price is inside the OTE zone
✓ An IFVG is present at or near the same level
✓ Price is not overextended beyond 2σ
✓ Directional bias is clear


─────────────────────────────────────
 SETTINGS
─────────────────────────────────────

Inverse FVG
- Min FVG Size (ATR multiplier) — filters out tiny gaps, default 0.3
- FVG Lookback — how many bars before a gap expires, default 50
- Toggle live FVGs and inverse FVGs on/off independently

OTE
- Swing Length — lookback for detecting the swing high and low, default 20
- Extend Zone — how far right the OTE lines project, default 20 bars

Standard Deviation
- Source — default close
- Length — SMA period, default 20
- 1st and 2nd multipliers — adjustable, defaults 1.0 and 2.0


─────────────────────────────────────
 ALERTS AVAILABLE
─────────────────────────────────────
- Bullish FVG formed
- Bearish FVG formed
- Price entered Bullish OTE zone
- Price entered Bearish OTE zone
- Price above 2σ (overextension)
- Price below 2σ (overextension)


─────────────────────────────────────
 NOTES
─────────────────────────────────────
- Built in Pine Script v6
- Designed for intraday use — works best on 1M, 5M, 15M timeframes
- Optimised for XAU/USD (Gold) but applicable to any liquid instrument
- The OTE zone updates in real time as new swings form — this is intentional 
  for live trading use
- This indicator is for educational and analytical purposes only. 
  Not financial advice. Trade at your own risk.

## Source Code

````pine
//@version=6
indicator("SMC: IFVG + OTE + Std Dev", overlay=true, max_boxes_count=200, max_lines_count=200, max_labels_count=200)

// ─────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────

// Inverse FVG
i_fvg_atr_mult   = input.float(0.3,  "Min FVG Size (ATR multiplier)", group="Inverse FVG", minval=0.0)
i_fvg_lookback   = input.int(50,     "FVG Lookback (bars)",           group="Inverse FVG", minval=10)
i_fvg_show_live  = input.bool(true,  "Show Live FVGs",                group="Inverse FVG")
i_fvg_show_inv   = input.bool(true,  "Show Inverse FVGs (flipped)",   group="Inverse FVG")

// OTE
i_ote_swing_len  = input.int(20,     "Swing Length for OTE",          group="OTE (Optimal Trade Entry)", minval=5)
i_ote_show       = input.bool(true,  "Show OTE Zone",                 group="OTE (Optimal Trade Entry)")
i_ote_extend     = input.int(20,     "Extend OTE Zone (bars)",        group="OTE (Optimal Trade Entry)", minval=1)

// Standard Deviation
i_sd_source      = input.source(close, "Source",                      group="Standard Deviation")
i_sd_length      = input.int(20,       "Length",                      group="Standard Deviation", minval=5)
i_sd_mult1       = input.float(1.0,    "1st Std Dev multiplier",      group="Standard Deviation")
i_sd_mult2       = input.float(2.0,    "2nd Std Dev multiplier",      group="Standard Deviation")
i_sd_show        = input.bool(true,    "Show Std Dev Channels",       group="Standard Deviation")

// ─────────────────────────────────────────────
// COLORS
// ─────────────────────────────────────────────
c_bull_live   = color.new(color.teal,  70)
c_bear_live   = color.new(color.red,   70)
c_bull_inv    = color.new(color.orange, 65)
c_bear_inv    = color.new(color.purple, 65)
c_bull_border = color.new(color.teal,  20)
c_bear_border = color.new(color.red,   20)
c_inv_border  = color.new(color.orange, 20)
c_ote_bull    = color.new(color.lime,   75)
c_ote_bear    = color.new(color.red,    75)
c_sd_mid      = color.new(color.white,  30)
c_sd_1        = color.new(color.yellow, 60)
c_sd_2        = color.new(color.orange, 60)

// ─────────────────────────────────────────────
// STANDARD DEVIATION CHANNELS
// ─────────────────────────────────────────────
sd_basis = ta.sma(i_sd_source, i_sd_length)
sd_val   = ta.stdev(i_sd_source, i_sd_length)

sd_upper1 = sd_basis + i_sd_mult1 * sd_val
sd_lower1 = sd_basis - i_sd_mult1 * sd_val
sd_upper2 = sd_basis + i_sd_mult2 * sd_val
sd_lower2 = sd_basis - i_sd_mult2 * sd_val

plot(i_sd_show ? sd_basis  : na, "SD Basis",   color=c_sd_mid, linewidth=1, style=plot.style_line)
plot(i_sd_show ? sd_upper1 : na, "+1 SD",      color=c_sd_1,   linewidth=1, style=plot.style_line)
plot(i_sd_show ? sd_lower1 : na, "-1 SD",      color=c_sd_1,   linewidth=1, style=plot.style_line)
plot(i_sd_show ? sd_upper2 : na, "+2 SD",      color=c_sd_2,   linewidth=1, style=plot.style_line)
plot(i_sd_show ? sd_lower2 : na, "-2 SD",      color=c_sd_2,   linewidth=1, style=plot.style_line)

sd_fill_bull = plot(i_sd_show ? sd_upper1 : na, display=display.none)
sd_fill_bear = plot(i_sd_show ? sd_lower1 : na, display=display.none)
fill(sd_fill_bull, sd_fill_bear, color=color.new(color.yellow, 92), title="SD Inner Band Fill")

// ─────────────────────────────────────────────
// FAIR VALUE GAP ENGINE
// ─────────────────────────────────────────────
atr_val = ta.atr(14)

bull_fvg_top    = low[1]
bull_fvg_bot    = high[3]
bull_fvg_valid  = barstate.isconfirmed and (bull_fvg_top > bull_fvg_bot) and ((bull_fvg_top - bull_fvg_bot) >= i_fvg_atr_mult * atr_val[1])

bear_fvg_top    = low[3]
bear_fvg_bot    = high[1]
bear_fvg_valid  = barstate.isconfirmed and (bear_fvg_bot < bear_fvg_top) and ((bear_fvg_top - bear_fvg_bot) >= i_fvg_atr_mult * atr_val[1])

// ─────────────────────────────────────────────
// FVG STORAGE ARRAYS
// ─────────────────────────────────────────────
var float[]  fvg_top   = array.new_float()
var float[]  fvg_bot   = array.new_float()
var int[]    fvg_bar   = array.new_int()
var bool[]   fvg_bull  = array.new_bool()
var bool[]   fvg_mit   = array.new_bool()
var bool[]   fvg_inv   = array.new_bool()
var box[]    fvg_boxes = array.new_box()

f_prune_fvgs() =>
    while array.size(fvg_top) > 0
        if bar_index - array.get(fvg_bar, 0) > i_fvg_lookback
            array.remove(fvg_top, 0)
            array.remove(fvg_bot, 0)
            array.remove(fvg_bar, 0)
            array.remove(fvg_bull, 0)
            array.remove(fvg_mit, 0)
            array.remove(fvg_inv, 0)
            b = array.remove(fvg_boxes, 0)
            box.delete(b)
        else
            break

if bull_fvg_valid and i_fvg_show_live
    array.push(fvg_top,  bull_fvg_top)
    array.push(fvg_bot,  bull_fvg_bot)
    array.push(fvg_bar,  bar_index - 1)
    array.push(fvg_bull, true)
    array.push(fvg_mit,  false)
    array.push(fvg_inv,  false)
    new_box = box.new(bar_index - 3, bull_fvg_top, bar_index + i_fvg_lookback, bull_fvg_bot, border_color=c_bull_border, bgcolor=c_bull_live, border_width=1)
    array.push(fvg_boxes, new_box)

if bear_fvg_valid and i_fvg_show_live
    array.push(fvg_top,  bear_fvg_top)
    array.push(fvg_bot,  bear_fvg_bot)
    array.push(fvg_bar,  bar_index - 1)
    array.push(fvg_bull, false)
    array.push(fvg_mit,  false)
    array.push(fvg_inv,  false)
    new_box = box.new(bar_index - 3, bear_fvg_top, bar_index + i_fvg_lookback, bear_fvg_bot, border_color=c_bear_border, bgcolor=c_bear_live, border_width=1)
    array.push(fvg_boxes, new_box)

// ─────────────────────────────────────────────
// MITIGATION + INVERSE FVG CHECK
// ─────────────────────────────────────────────
if barstate.isconfirmed and array.size(fvg_top) > 0
    for i = 0 to array.size(fvg_top) - 1
        if not array.get(fvg_mit, i)
            top_level = array.get(fvg_top, i)
            bot_level = array.get(fvg_bot, i)
            is_bull   = array.get(fvg_bull, i)
            mid_level = (top_level + bot_level) / 2.0
            bx        = array.get(fvg_boxes, i)

            bull_mitigated = is_bull  and close < mid_level
            bear_mitigated = not is_bull and close > mid_level

            if bull_mitigated or bear_mitigated
                array.set(fvg_mit, i, true)

                if i_fvg_show_inv and not array.get(fvg_inv, i)
                    array.set(fvg_inv, i, true)
                    box.delete(bx)
                    inv_color  = is_bull ? c_bear_inv : c_bull_inv
                    new_inv = box.new(array.get(fvg_bar, i) - 2, top_level, bar_index + 10, bot_level, border_color=c_inv_border, bgcolor=inv_color, border_width=1, border_style=line.style_dashed)
                    array.set(fvg_boxes, i, new_inv)
                    lbl_txt = is_bull ? "IFVG Bearish" : "IFVG Bullish"
                    lbl_col = is_bull ? color.orange : color.purple
                    label.new(bar_index, is_bull ? top_level : bot_level, lbl_txt, style=is_bull ? label.style_label_down : label.style_label_up, color=lbl_col, textcolor=color.white, size=size.small)

f_prune_fvgs()

// ─────────────────────────────────────────────
// OTE — OPTIMAL TRADE ENTRY
// ─────────────────────────────────────────────
swing_high = ta.highest(high, i_ote_swing_len)
swing_low  = ta.lowest(low,  i_ote_swing_len)

range_mid  = (swing_high + swing_low) / 2.0
bull_bias  = close > range_mid
bear_bias  = close < range_mid

fib_range  = swing_high - swing_low

ote_bull_top = swing_low + fib_range * 0.79
ote_bull_bot = swing_low + fib_range * 0.62

ote_bear_top = swing_high - fib_range * 0.62
ote_bear_bot = swing_high - fib_range * 0.79

price_in_bull_ote = bull_bias and close <= ote_bull_top and close >= ote_bull_bot
price_in_bear_ote = bear_bias and close >= ote_bear_bot and close <= ote_bear_top

var line  ote_top_line = na
var line  ote_bot_line = na
var label ote_label    = na

if i_ote_show
    line.delete(ote_top_line)
    line.delete(ote_bot_line)
    label.delete(ote_label)

    ote_top = bull_bias ? ote_bull_top : ote_bear_top
    ote_bot = bull_bias ? ote_bull_bot : ote_bear_bot
    ote_col = bull_bias ? color.new(color.lime, 40) : color.new(color.red, 40)
    ote_txt = bull_bias ? "OTE Buy Zone\n(62–79% retrace)" : "OTE Sell Zone\n(62–79% retrace)"

    ote_top_line := line.new(bar_index - i_ote_swing_len, ote_top, bar_index + i_ote_extend, ote_top, color=ote_col, width=1, style=line.style_dashed)
    ote_bot_line := line.new(bar_index - i_ote_swing_len, ote_bot, bar_index + i_ote_extend, ote_bot, color=ote_col, width=1, style=line.style_dashed)
    ote_label    := label.new(bar_index + i_ote_extend, (ote_top + ote_bot) / 2, ote_txt, style=label.style_label_left, color=color.new(color.black, 60), textcolor=ote_col, size=size.small)

alertcondition(price_in_bull_ote, "Price in Bullish OTE", "Price has entered the Bullish OTE zone (62–79% retracement) — watch for long setup")
alertcondition(price_in_bear_ote, "Price in Bearish OTE", "Price has entered the Bearish OTE zone (62–79% retracement) — watch for short setup")

ote_bg_color = price_in_bull_ote ? color.new(color.lime, 90) : price_in_bear_ote ? color.new(color.red, 90) : na
bgcolor(ote_bg_color, title="OTE Zone Background")

// ─────────────────────────────────────────────
// DASHBOARD
// ─────────────────────────────────────────────
var table dash = table.new(position.top_right, 2, 6, bgcolor=color.new(color.black, 60), border_width=1)

f_dash_row(row, label_txt, val_txt, val_col) =>
    table.cell(dash, 0, row, label_txt, text_color=color.new(color.gray, 20), text_size=size.small, bgcolor=color.new(color.black, 70))
    table.cell(dash, 1, row, val_txt,   text_color=val_col,                   text_size=size.small, bgcolor=color.new(color.black, 60))

sd_position = close > sd_upper2 ? "Above 2σ ▲▲" : close > sd_upper1 ? "Above 1σ ▲" : close < sd_lower2 ? "Below 2σ ▼▼" : close < sd_lower1 ? "Below 1σ ▼" : "Inside 1σ ◆"

sd_col = close > sd_upper2 ? color.orange : close > sd_upper1 ? color.yellow : close < sd_lower2 ? color.red : close < sd_lower1 ? color.orange : color.teal

ote_status = price_in_bull_ote ? "BUY ZONE ✓" : price_in_bear_ote ? "SELL ZONE ✓" : "Not in OTE"
ote_col2   = price_in_bull_ote ? color.lime : price_in_bear_ote ? color.red : color.gray

bias_txt = bull_bias ? "Bullish" : "Bearish"
bias_col = bull_bias ? color.teal : color.red

live_fvgs = 0
inv_fvgs  = 0
if array.size(fvg_top) > 0
    for i = 0 to array.size(fvg_top) - 1
        if not array.get(fvg_mit, i)
            live_fvgs := live_fvgs + 1
        if array.get(fvg_inv, i)
            inv_fvgs := inv_fvgs + 1

if barstate.islast
    table.cell(dash, 0, 0, "SMC Suite",   text_color=color.white, text_size=size.normal, bgcolor=color.new(color.navy, 40))
    table.cell(dash, 1, 0, "v1.0",        text_color=color.gray,  text_size=size.normal, bgcolor=color.new(color.navy, 40))
    f_dash_row(1, "Bias",       bias_txt,             bias_col)
    f_dash_row(2, "OTE",        ote_status,            ote_col2)
    f_dash_row(3, "Std Dev",    sd_position,           sd_col)
    f_dash_row(4, "Live FVGs",  str.tostring(live_fvgs), color.teal)
    f_dash_row(5, "Inv FVGs",   str.tostring(inv_fvgs),  color.orange)

// ─────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────
alertcondition(bull_fvg_valid, "Bullish FVG Formed",  "New Bullish FVG detected — potential support zone")
alertcondition(bear_fvg_valid, "Bearish FVG Formed",  "New Bearish FVG detected — potential resistance zone")
alertcondition(close > sd_upper2, "Price Above 2σ",   "Price extended above 2nd standard deviation — possible mean reversion area")
alertcondition(close < sd_lower2, "Price Below 2σ",   "Price extended below 2nd standard deviation — possible mean reversion area")
````
