# 8 SMA Bands (Points) Auction [MTF]

- url: https://www.tradingview.com/script/npHkhOaa-8-SMA-Bands-Points-Auction-MTF/
- type: indicator
- pine_id: PUB;8d315b127c4243cabfdbb8c0e9ce0d8f
- version: 1.0

## Description

8 SMA Bands (Points) Auction [MTF] is a multi-timeframe overlay indicator that plots 8 different Simple Moving Averages (default length 2048) from a higher timeframe, along with symmetric point-based bands around each MA.It creates a layered "auction zone" system using a base point offset (default 0.2441405 — Gann-inspired) multiplied from 1× to 8×. These bands are not percentage or ATR-based, but fixed price points, making them geometrically proportional in absolute price distance. 

The bands are grouped into 5 visual "Auction" levels:
Low Auction (Level 1)
Normal Auction (Level 2)
High Auction (Level 4)
Very High Auction (Level 6)
Extreme Auction (Level 8)

It also highlights one MA as "FV" (Fair Value).
Key Features: Higher Timeframe MTF (default Daily)
Individual length and fine-tune adjustment for each of the 8 MAs
Master base offset control (easy to switch between Gann / Murrey Math styles)
Clean right-side labels for each auction level

Primary Use Cases:
1. Auction / Market Profile Style Trading
Visualizes different "auction intensities" or value areas.
Price moving into High/Very High/Extreme Auction zones often signals over-extension or potential reversal.
Normal Auction area acts as a fair value / equilibrium zone.

2. Dynamic Support & Resistance
The bands serve as layered S/R levels, especially powerful when using Daily or Weekly MAs on lower timeframes (e.g., 15m, 1H, 4H).

3. Fair Value Trading
The central MA (labeled FV) is used as a mean-reversion magnet.
Traders look for entries toward FV from outer auction zones.

4. Trend Strength & Exhaustion
When price sustains in Extreme Auction territory → strong trend.
Rejection or failure to hold outer bands → possible exhaustion.

5. Institutional / Smart Money Concepts
Helps identify premium and discount zones relative to higher-timeframe fair value.

Best Suited For:
Futures, Forex, and large-cap stocks
Swing and intraday traders who like higher-timeframe bias
Traders familiar with Gann, Murrey Math, or Auction Market Theory

This indicator is particularly useful for context — giving you a clear visual map of how far price has extended from fair value on multiple levels simultaneously.

## Source Code

````pine
//@version=6
indicator(title = '8 SMA Bands (Points) Auction [MTF]', shorttitle = '8 Bands Auction MTF', overlay = true)

// ── Inputs ──

// Timeframe
tf = input.timeframe('D', 'Higher Timeframe', group = 'MTF Settings')

// Global Multiplier
multiplier = input.float(2.0, title = 'Global Multiplier', minval = 0.001, step = 0.001, group = 'MTF Settings')

// Master Offset Control
base_offset = input.float(0.2441405, title = 'Base MA Offset (Points)', minval = 0.00001, step = 0.00001, group = 'Master Offset Settings', tooltip = 'Base multiplier for all 8 bands.\n\n' + 'Common values:\n' + '• 0.305176 = MM (Murrey Math)\n' + '• 0.2441405 = Gann')

// Label Offset
label_offset_bars = input.int(60, title = 'Label Offset (Bars to Right)', minval = 0, maxval = 300, step = 1, group = 'Display')

// ── MA Settings + Fine Tune ──
length1 = input.int(2048, title = 'MA 1 Length', minval = 1, group = 'MA 1 Settings')
fine_tune1 = input.float(0.0, title = 'Fine Tune 1', minval = -1.0, step = 0.00001, group = 'MA 1 Settings')
ma1_color = input.color(#ffffff, title = 'MA 1 Color', group = 'MA 1 Settings')

length2 = input.int(2048, title = 'MA 2 Length', minval = 1, group = 'MA 2 Settings')
fine_tune2 = input.float(0.0, title = 'Fine Tune 2', minval = -1.0, step = 0.00001, group = 'MA 2 Settings')
ma2_color = input.color(#ffffff, title = 'MA 2 Color', group = 'MA 2 Settings')

length3 = input.int(2048, title = 'MA 3 Length', minval = 1, group = 'MA 3 Settings')
fine_tune3 = input.float(0.0, title = 'Fine Tune 3', minval = -1.0, step = 0.00001, group = 'MA 3 Settings')
ma3_color = input.color(#ffffff, title = 'MA 3 Color', group = 'MA 3 Settings')

length4 = input.int(2048, title = 'MA 4 Length', minval = 1, group = 'MA 4 Settings')
fine_tune4 = input.float(0.0, title = 'Fine Tune 4', minval = -1.0, step = 0.00001, group = 'MA 4 Settings')
ma4_color = input.color(#ffffff, title = 'MA 4 Color', group = 'MA 4 Settings')

length5 = input.int(2048, title = 'MA 5 Length', minval = 1, group = 'MA 5 Settings')
fine_tune5 = input.float(0.0, title = 'Fine Tune 5', minval = -1.0, step = 0.00001, group = 'MA 5 Settings')
ma5_color = input.color(#ffffff, title = 'MA 5 Color', group = 'MA 5 Settings')

length6 = input.int(2048, title = 'MA 6 Length', minval = 1, group = 'MA 6 Settings')
fine_tune6 = input.float(0.0, title = 'Fine Tune 6', minval = -1.0, step = 0.00001, group = 'MA 6 Settings')
ma6_color = input.color(#ffffff, title = 'MA 6 Color', group = 'MA 6 Settings')

length7 = input.int(2048, title = 'MA 7 Length', minval = 1, group = 'MA 7 Settings')
fine_tune7 = input.float(0.0, title = 'Fine Tune 7', minval = -1.0, step = 0.00001, group = 'MA 7 Settings')
ma7_color = input.color(#ffffff, title = 'MA 7 Color', group = 'MA 7 Settings')

length8 = input.int(2048, title = 'MA 8 Length', minval = 1, group = 'MA 8 Settings')
fine_tune8 = input.float(0.0, title = 'Fine Tune 8', minval = -1.0, step = 0.00001, group = 'MA 8 Settings')
ma8_color = input.color(#ffffff, title = 'MA 8 Color', group = 'MA 8 Settings')

// ── Request Security (MTF) ──
f_get_ma(len) =>
    request.security(syminfo.tickerid, tf, ta.sma(close, len))

ma1 = f_get_ma(length1)
ma2 = f_get_ma(length2)
ma3 = f_get_ma(length3)
ma4 = f_get_ma(length4)
ma5 = f_get_ma(length5)
ma6 = f_get_ma(length6)
ma7 = f_get_ma(length7)
ma8 = f_get_ma(length8)

// ── Final Offsets ──
offset_pts1 = base_offset * 1 + fine_tune1
offset_pts2 = base_offset * 2 + fine_tune2
offset_pts3 = base_offset * 3 + fine_tune3
offset_pts4 = base_offset * 4 + fine_tune4
offset_pts5 = base_offset * 5 + fine_tune5
offset_pts6 = base_offset * 6 + fine_tune6
offset_pts7 = base_offset * 7 + fine_tune7
offset_pts8 = base_offset * 8 + fine_tune8

// ── Calculate Bands ──
upper1 = ma1 + offset_pts1 * multiplier
lower1 = ma1 - offset_pts1 * multiplier
upper2 = ma2 + offset_pts2 * multiplier
lower2 = ma2 - offset_pts2 * multiplier
upper3 = ma3 + offset_pts3 * multiplier
lower3 = ma3 - offset_pts3 * multiplier
upper4 = ma4 + offset_pts4 * multiplier
lower4 = ma4 - offset_pts4 * multiplier
upper5 = ma5 + offset_pts5 * multiplier
lower5 = ma5 - offset_pts5 * multiplier
upper6 = ma6 + offset_pts6 * multiplier
lower6 = ma6 - offset_pts6 * multiplier
upper7 = ma7 + offset_pts7 * multiplier
lower7 = ma7 - offset_pts7 * multiplier
upper8 = ma8 + offset_pts8 * multiplier
lower8 = ma8 - offset_pts8 * multiplier

// ── Plot SMAs ──
plot(ma1, color = ma1_color, linewidth = 4, title = 'MA 1')
plot(ma2, color = ma2_color, linewidth = 1, title = 'MA 2')
plot(ma3, color = ma3_color, linewidth = 1, title = 'MA 3')
plot(ma4, color = ma4_color, linewidth = 1, title = 'MA 4')
plot(ma5, color = ma5_color, linewidth = 1, title = 'MA 5')
plot(ma6, color = ma6_color, linewidth = 1, title = 'MA 6')
plot(ma7, color = ma7_color, linewidth = 1, title = 'MA 7')
plot(ma8, color = ma8_color, linewidth = 1, title = 'MA 8')

// ── Plot Bands ──
plot(upper1, color = color.new(ma1_color, 10), linewidth = 1, title = 'Upper Band 1')
plot(lower1, color = color.new(ma1_color, 10), linewidth = 1, title = 'Lower Band 1')
plot(upper2, color = color.new(ma2_color, 10), linewidth = 2, title = 'Upper Band 2')
plot(lower2, color = color.new(ma2_color, 10), linewidth = 2, title = 'Lower Band 2')
plot(upper3, color = color.new(ma3_color, 10), linewidth = 1, title = 'Upper Band 3')
plot(lower3, color = color.new(ma3_color, 10), linewidth = 1, title = 'Lower Band 3')
plot(upper4, color = color.new(ma4_color, 10), linewidth = 4, title = 'Upper Band 4')
plot(lower4, color = color.new(ma4_color, 10), linewidth = 4, title = 'Lower Band 4')
plot(upper5, color = color.new(ma5_color, 10), linewidth = 1, title = 'Upper Band 5')
plot(lower5, color = color.new(ma5_color, 10), linewidth = 1, title = 'Lower Band 5')
plot(upper6, color = color.new(ma6_color, 10), linewidth = 2, title = 'Upper Band 6')
plot(lower6, color = color.new(ma6_color, 10), linewidth = 2, title = 'Lower Band 6')
plot(upper7, color = color.new(ma7_color, 10), linewidth = 1, title = 'Upper Band 7')
plot(lower7, color = color.new(ma7_color, 10), linewidth = 1, title = 'Lower Band 7')
plot(upper8, color = color.new(ma8_color, 10), linewidth = 4, title = 'Upper Band 8')
plot(lower8, color = color.new(ma8_color, 10), linewidth = 4, title = 'Lower Band 8')

// ── LABELS ──
create_band_label(x_pos, y_pos, lbl_text, color_val) =>
    var label lbl = na
    if barstate.islast
        label.delete(lbl)
        lbl := label.new(x = x_pos, y = y_pos, text = lbl_text, color = color.new(color_val, 100), textcolor = color_val, style = label.style_none, xloc = xloc.bar_index)
        lbl

// MA 1 (FV) Label
var label ma1_label = na
if barstate.islast
    label.delete(ma1_label)
    ma1_label := label.new(x = bar_index + label_offset_bars, y = ma1, text = 'FV', color = color.new(ma1_color, 100), textcolor = ma1_color, style = label.style_none, xloc = xloc.bar_index)
    ma1_label

// Band Labels
if barstate.islast
    create_band_label(bar_index + label_offset_bars, lower1, 'low Auction', ma1_color)
    create_band_label(bar_index + label_offset_bars, upper1, 'low Auction', ma1_color)

    create_band_label(bar_index + label_offset_bars, lower2, 'normal Auction', ma2_color)
    create_band_label(bar_index + label_offset_bars, upper2, 'normal Auction', ma2_color)

    create_band_label(bar_index + label_offset_bars, lower4, 'high Auction', ma4_color)
    create_band_label(bar_index + label_offset_bars, upper4, 'high Auction', ma4_color)

    create_band_label(bar_index + label_offset_bars, lower6, 'very high Auction', ma6_color)
    create_band_label(bar_index + label_offset_bars, upper6, 'very high Auction', ma6_color)

    create_band_label(bar_index + label_offset_bars, lower8, 'extreme Auction', ma8_color)
    create_band_label(bar_index + label_offset_bars, upper8, 'extreme Auction', ma8_color)
````
