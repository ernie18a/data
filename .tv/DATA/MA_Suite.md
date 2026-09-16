<!-- tradingview-pine-id: PUB;7f7a6e847cbb46d9a535587d6a1bfc29 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# MA Suite

Source: https://www.tradingview.com/script/7PW7EhHp-MA-Suite/

## Description

The MA Suite consolidates 11 essential daily and weekly moving averages (5 SMAs and 6 EMAs) into a single Pine Script v6 indicator, saving indicator slots on TradingView while maintaining multi-timeframe context on lower-timeframe charts.

Why I made this Script
I wanted all the useful MA's on one chart, the MA labels floating next to price, the lines only at 5% transparency(barely can see) and fully customizable alerts for when any interaction w/ and MA is triggered(*hover over the indictor line on top left of chart and click the three dots and select "Add alert"*)

Features

[*]Right-Margined Labels: MA Labeled on chart and are pushed to the right of the active candle so you can see MA name.
[*]Dynamic Price-Relative Line Coloring: Every individual MA line automatically shifts color:
  - Green when price trades above the MA 
  - Red when price trades below it
[*]Integrated Crossover Signal Labels: Automatically prints explicit **BUY** and **SELL** shape tags when price crosses the 50D SMA, plus visual markers whenever the 10D(slow) and 40D(fast) SMAs intersect.
[*]Ultra-Low Transparency Styling: Uses a 95% transparency overlay so 11 simultaneous lines won't visually clutter your chart or obscure candlestick patterns.
[*]Can change in settings or permanently via "--- SMA Plots ---" & "--- EMA Plots ---" sections in Pinescript (edit the 95 number down..)

---

## Source Code

````pine
//@version=6
indicator("MA Suite", shorttitle="MA Suite", overlay=true)

// --- HELPER FUNCTION ---
get_ma(string ma_type, float src, int len, string tf) =>
    float sma_val = ta.sma(src, len)
    float ema_val = ta.ema(src, len)
    float ma_expr = ma_type == "SMA" ? sma_val : ema_val
    request.security(syminfo.tickerid, tf, ma_expr, gaps=barmerge.gaps_off)

// -----------------------------------------------------
// INPUTS & CALCULATIONS
// -----------------------------------------------------

// ==================== SMA GROUP ====================

// --- 10D SMA ---
s1_len = input.int(10, "Length", minval=1, group="10D SMA")
s1_src = input.source(close, "Source", group="10D SMA")
s1_tf  = input.timeframe("D", "Timeframe", group="10D SMA")
s1_val = get_ma("SMA", s1_src, s1_len, s1_tf)

// --- 40D SMA ---
s2_len = input.int(40, "Length", minval=1, group="40D SMA")
s2_src = input.source(close, "Source", group="40D SMA")
s2_tf  = input.timeframe("D", "Timeframe", group="40D SMA")
s2_val = get_ma("SMA", s2_src, s2_len, s2_tf)

// --- 50D SMA ---
s3_len = input.int(50, "Length", minval=1, group="50D SMA")
s3_src = input.source(close, "Source", group="50D SMA")
s3_tf  = input.timeframe("D", "Timeframe", group="50D SMA")
s3_val = get_ma("SMA", s3_src, s3_len, s3_tf)

// --- 100D SMA ---
s4_len = input.int(100, "Length", minval=1, group="100D SMA")
s4_src = input.source(close, "Source", group="100D SMA")
s4_tf  = input.timeframe("D", "Timeframe", group="100D SMA")
s4_val = get_ma("SMA", s4_src, s4_len, s4_tf)

// --- 200D SMA ---
s5_len = input.int(200, "Length", minval=1, group="200D SMA")
s5_src = input.source(close, "Source", group="200D SMA")
s5_tf  = input.timeframe("D", "Timeframe", group="200D SMA")
s5_val = get_ma("SMA", s5_src, s5_len, s5_tf)

// ==================== EMA GROUP ====================

// --- 9D EMA ---
e2_len = input.int(9, "Length", minval=1, group="9D EMA")
e2_src = input.source(close, "Source", group="9D EMA")
e2_tf  = input.timeframe("D", "Timeframe", group="9D EMA")
e2_val = get_ma("EMA", e2_src, e2_len, e2_tf)

// --- 21D EMA ---
e3_len = input.int(21, "Length", minval=1, group="21D EMA")
e3_src = input.source(close, "Source", group="21D EMA")
e3_tf  = input.timeframe("D", "Timeframe", group="21D EMA")
e3_val = get_ma("EMA", e3_src, e3_len, e3_tf)

// --- 50D EMA ---
e4_len = input.int(50, "Length", minval=1, group="50D EMA")
e4_src = input.source(close, "Source", group="50D EMA")
e4_tf  = input.timeframe("D", "Timeframe", group="50D EMA")
e4_val = get_ma("EMA", e4_src, e4_len, e4_tf)

// --- 100D EMA ---
e6_len = input.int(100, "Length", minval=1, group="100D EMA")
e6_src = input.source(close, "Source", group="100D EMA")
e6_tf  = input.timeframe("D", "Timeframe", group="100D EMA")
e6_val = get_ma("EMA", e6_src, e6_len, e6_tf)

// --- 200D EMA ---
e5_len = input.int(200, "Length", minval=1, group="200D EMA")
e5_src = input.source(close, "Source", group="200D EMA")
e5_tf  = input.timeframe("D", "Timeframe", group="200D EMA")
e5_val = get_ma("EMA", e5_src, e5_len, e5_tf)

// --- 200W EMA ---
e1_len = input.int(200, "Length", minval=1, group="200W EMA")
e1_src = input.source(close, "Source", group="200W EMA")
e1_tf  = input.timeframe("W", "Timeframe", group="200W EMA")
e1_val = get_ma("EMA", e1_src, e1_len, e1_tf)

// -----------------------------------------------------
// VISUALIZATION
// -----------------------------------------------------

// --- Price vs MA Colors: SMAs ---
s1_col = close >= s1_val ? color.green : color.red
s2_col = close >= s2_val ? color.green : color.red
s3_col = close >= s3_val ? color.green : color.red
s4_col = close >= s4_val ? color.green : color.red
s5_col = close >= s5_val ? color.green : color.red

// --- Price vs MA Colors: EMAs ---
e2_col = close >= e2_val ? color.green : color.red
e3_col = close >= e3_val ? color.green : color.red
e4_col = close >= e4_val ? color.green : color.red
e6_col = close >= e6_val ? color.green : color.red
e5_col = close >= e5_val ? color.green : color.red
e1_col = close >= e1_val ? color.green : color.red

// --- SMA Plots ---
plot(s1_val, "10D SMA",  color=color.new(s1_col, 95), linewidth=1)
plot(s2_val, "40D SMA",  color=color.new(s2_col, 95), linewidth=2)
plot(s3_val, "50D SMA",  color=color.new(s3_col, 95), linewidth=2)
plot(s4_val, "100D SMA", color=color.new(s4_col, 95), linewidth=2)
plot(s5_val, "200D SMA", color=color.new(s5_col, 95), linewidth=3)

// --- EMA Plots ---
plot(e2_val, "9D EMA",   color=color.new(e2_col, 95), linewidth=1)
plot(e3_val, "21D EMA",  color=color.new(e3_col, 95), linewidth=1)
plot(e4_val, "50D EMA",  color=color.new(e4_col, 95), linewidth=2)
plot(e6_val, "100D EMA", color=color.new(e6_col, 95), linewidth=2)
plot(e5_val, "200D EMA", color=color.new(e5_col, 95), linewidth=3)
plot(e1_val, "200W EMA", color=color.new(e1_col, 95), linewidth=3)

// --- 10/40 SMA CROSS VISUAL ---
plot(ta.cross(s1_val, s2_val) ? s1_val : na, color=#2962FF, style=plot.style_cross, linewidth=4, title="10/40 Cross Symbol")

// -----------------------------------------------------
// CROSS DETECTION & LABELS (Anchored to 50D SMA)
// -----------------------------------------------------
crossUp   = ta.crossover(close, s3_val)
crossDown = ta.crossunder(close, s3_val)

plotshape(crossUp,   title="Buy Label",   style=shape.labelup,   location=location.belowbar, color=color.green, text="BUY",  textcolor=color.white, size=size.small)
plotshape(crossDown, title="Sell Label",  style=shape.labeldown, location=location.abovebar, color=color.red,   text="SELL", textcolor=color.white, size=size.small)

// -----------------------------------------------------
// END-OF-LINE MA LABELS
// -----------------------------------------------------
print_ma_label(float val, string txt, color col) =>
    var label lbl = na
    if barstate.islast and not na(val)
        label.delete(lbl)
        lbl := label.new(x=bar_index + 1, y=val, text=txt, 
                         color=color.new(color.white, 100), 
                         textcolor=col, 
                         style=label.style_label_left, 
                         size=size.small)

// --- SMA Labels ---
print_ma_label(s1_val, "10D SMA", s1_col)
print_ma_label(s2_val, "40D SMA", s2_col)
print_ma_label(s3_val, "50D SMA", s3_col)
print_ma_label(s4_val, "100D SMA", s4_col)
print_ma_label(s5_val, "200D SMA", s5_col)

// --- EMA Labels ---
print_ma_label(e2_val, "9D EMA", e2_col)
print_ma_label(e3_val, "21D EMA", e3_col)
print_ma_label(e4_val, "50D EMA", e4_col)
print_ma_label(e6_val, "100D EMA", e6_col)
print_ma_label(e5_val, "200D EMA", e5_col)
print_ma_label(e1_val, "200W EMA", e1_col)
````
