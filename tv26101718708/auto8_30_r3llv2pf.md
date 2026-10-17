# Auto8 3.0

- url: https://www.tradingview.com/script/R3llV2Pf-Auto8-3-0/
- type: indicator
- pine_id: PUB;2bda3f0ce6ea46148219afdecb334ade
- version: 1.0

## Description

Auto8 3.0 is an automatic Fibonacci 1/8th Levels indicator (also known as Murrey Math Lines style). It dynamically calculates the highest high and lowest low over a user-defined lookback period (Fib Length, default 4096 bars), then divides that range into 8 equal parts. The script plots:
The 9 main levels (8/8 down to 0/8)
Several 1/16th intermediate lines
Upper and lower extensions (beyond the range)
Beautiful colored fills between each 1/8th zone
Clean right-side labels for every major level

It is fully automatic — it constantly updates as new highs/lows are made within the lookback window.

Main Use Cases:
High-Probability Support & Resistance
The 1/8th levels (especially 0/8, 2/8, 4/8, 6/8, 8/8) act as major psychological and institutional zones where price frequently reacts.

Market Structure & Bias Determination  Price trading above 4/8 → Bullish structure  
Price trading below 4/8 → Bearish structure  
4/8 level often acts as a strong magnet (mean reversion point).

Zone Trading
Traders use the colored zones for:Buying in lower zones (1/8 – 3/8)
Selling in upper zones (5/8 – 7/8)
Breakout confirmation when price decisively breaks and holds a level

Very popular among Forex, Index, and Commodity traders on Daily, Weekly, and Monthly timeframes.

Key Strengths: Clean, visually appealing zone fills
Automatic — no manual drawing needed
Works on all instruments and timeframes
Good for identifying overextended moves (price at 8/8 or 0/8)

Typical Trading Style:
Swing trading, positional trading, and ICT/SMC traders who love Fair Value Gaps + Order Blocks + Fibonacci/Murrey levels.

## Source Code

````pine
//@version=6
indicator(title="Auto8 3.0", shorttitle="Auto8 3.0", overlay=true)

fiblength = input.int(4096, "Fib Length", minval=1)

// ── Label Settings ───────────────────────────────────────────────────────
label_offset_bars = input.int(5, "Label Offset (bars)", minval=0, group="Labels")

// ── Fill Color Settings ──────────────────────────────────────────────────
fill_8_7  = input.color(color.new(color.red,    88), "8/8 - 7/8 Fill",   group="Fill Colors")
fill_7_6  = input.color(color.new(color.yellow, 88), "7/8 - 6/8 Fill",   group="Fill Colors")
fill_6_5  = input.color(color.new(#3399FF,      88), "6/8 - 5/8 Fill",   group="Fill Colors")
fill_5_4  = input.color(color.new(color.lime,   88), "5/8 - 4/8 Fill",   group="Fill Colors")
fill_4_3  = input.color(color.new(color.lime,   88), "4/8 - 3/8 Fill",   group="Fill Colors")
fill_3_2  = input.color(color.new(#3399FF,      88), "3/8 - 2/8 Fill",   group="Fill Colors")
fill_2_1  = input.color(color.new(color.yellow, 88), "2/8 - 1/8 Fill",   group="Fill Colors")
fill_1_0  = input.color(color.new(color.red,    88), "1/8 - 0/8 Fill",   group="Fill Colors")

// Colors (match your plot colors)
ma1_color = #ffffff
ma875_color = color.red
ma75_color = #3399FF
ma625_color = color.green
ma5_color = color.yellow
ma375_color = color.green
ma25_color = #3399FF
ma125_color = color.red
ma0_color = #ffffff

// ── LABEL FUNCTION ───────────────────────────────────────────────────────
// Note: We changed y_pos type expectation implicitly by passing floats now
create_band_label(x_pos, y_pos, lbl_text, color_val) =>
    var label lbl = na
    if barstate.islast
        label.delete(lbl)
        lbl := label.new(
             x=x_pos,
             y=y_pos, // This now receives a series float, not a plot object
             text=lbl_text,
             color=color.new(color_val, 100),
             textcolor=color_val,
             style=label.style_none,
             xloc=xloc.bar_index
             )

maxr = ta.highest(close, fiblength)
minr = ta.lowest(close, fiblength)
ranr = maxr - minr

ON  = plot(maxr,                     color=color.rgb(255, 255, 255, 20),   title="1")
SS  = plot(maxr - 0.125 * ranr,     color=color.rgb(255, 82, 82, 20),     title="0.875")
SSE = plot(maxr - 0.25 * ranr,      color=color.rgb(51, 153, 255, 20),       title="0.75")
SO  = plot(maxr - 0.375 * ranr,     color=color.rgb(76, 175, 80, 20),   title="0.625")
FI  = plot(maxr - 0.50 * ranr,      color=color.rgb(255, 235, 59, 20),  title="0.5")
TE  = plot(minr + 0.375 * ranr,     color=color.rgb(76, 175, 80, 20),   title="0.375")
TEE = plot(minr + 0.25 * ranr,      color=color.rgb(51, 153, 255, 20),       title="0.25")
TT  = plot(minr + 0.125 * ranr,     color=color.rgb(255, 82, 82, 20),     title="0.125")
ZZ  = plot(minr,                     color=color.rgb(255, 255, 255, 20),   title="0")

// 1/16's
SS5  = plot(maxr - 0.0625 * ranr,     color=color.rgb(255, 82, 82, 40),     title="15/16")
SSE5 = plot(maxr - 0.1875 * ranr,      color=color.rgb(255, 235, 59, 40),       title="13/16")
SO5  = plot(maxr - 0.3125 * ranr,     color=color.rgb(51, 153, 255, 40),   title="11/16")
SO5a  = plot(maxr - 0.4375 * ranr,     color=color.rgb(76, 175, 80, 40),   title="9/16")

FI5   = plot(minr + 0.4375 * ranr,     color=color.rgb(76, 175, 80, 40),   title="7/16")

TE5  = plot(minr + 0.3125 * ranr,     color=color.rgb(51, 153, 255, 40),   title="5/16")
TEE5 = plot(minr + 0.1875 * ranr,      color=color.rgb(255, 235, 59, 40),       title="3/16")
TT5  = plot(minr + 0.0625 * ranr,     color=color.rgb(255, 82, 82, 40),     title="1/16")

// extensions

SSL  = plot(maxr - 1.125 * ranr,     color=color.gray,     title="1/8 lower ext")
SSEL = plot(maxr - 1.25 * ranr,      color=color.gray,       title="2/8 lower ext")
SOL  = plot(maxr - 1.375 * ranr,     color=color.gray,   title="3/8 lower ext")

TEH  = plot(minr + 1.375 * ranr,     color=color.gray,   title="1/8 higher ext")
TEEH = plot(minr + 1.25 * ranr,      color=color.gray,       title="2/8 higher ext")
TTH  = plot(minr + 1.125 * ranr,     color=color.gray,     title="3/8 higher ext")


fill(ON,  SS,  color=fill_8_7)
fill(SS,  SSE, color=fill_7_6)
fill(SSE, SO,  color=fill_6_5)
fill(SO,  FI,  color=fill_5_4)
fill(FI,  TE,  color=fill_4_3)
fill(TE,  TEE, color=fill_3_2)
fill(TEE, TT,  color=fill_2_1)
fill(TT,  ZZ,  color=fill_1_0)

// ── LABELS ───────────────────────────────────────────────────────────────

// ==================== Bands Labels ====================

// We must pass the calculated values (maxr, minr, ranr) directly, NOT the plot objects
if barstate.islast
    // Band 1
    create_band_label(bar_index + label_offset_bars, maxr, "8/8", ma1_color)     // Was ON
    create_band_label(bar_index + label_offset_bars, minr, "0/8", ma0_color)     // Was ZZ

    // Band 2
    create_band_label(bar_index + label_offset_bars, maxr - 0.125 * ranr, "7/8",   ma875_color) // Was SS
    create_band_label(bar_index + label_offset_bars, minr + 0.125 * ranr, "1/8",   ma125_color) // Was TT

    // Band 4
    create_band_label(bar_index + label_offset_bars, maxr - 0.25 * ranr,  "6/8",     ma75_color) // Was SSE
    create_band_label(bar_index + label_offset_bars, minr + 0.25 * ranr,  "2/8",     ma25_color) // Was TEE

    // Band 5 
    create_band_label(bar_index + label_offset_bars, maxr - 0.375 * ranr, "5/8",   ma625_color) // Was SO
    create_band_label(bar_index + label_offset_bars, minr + 0.375 * ranr, "3/8",   ma375_color) // Was TE

    // ==================== MA6 - Extreme ====================
    create_band_label(bar_index + label_offset_bars, maxr - 0.50 * ranr, "4/8", ma5_color) // Was FI
````
