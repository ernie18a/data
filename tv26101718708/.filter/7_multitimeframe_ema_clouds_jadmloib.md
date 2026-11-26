# 7 Multi-Timeframe EMA Clouds

- url: https://www.tradingview.com/script/JaDmLOiB-7-Multi-Timeframe-EMA-Clouds/
- type: indicator
- pine_id: PUB;7c1a21fb17164d729faf94a5249e48ed
- version: 1.0

## Description

-----------------------
done with luxalgo quant
---------------------------
7 ema cloud on other TF
-------------------

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © LuxAlgo

//@version=6
indicator("7 Multi-Timeframe EMA Clouds", overlay = true, max_labels_count = 10)

// --- Constants ---
int EMA_1_LEN = 78
int EMA_2_LEN = 84

// --- Functions ---
// Function to handle EMA cloud calculations and plotting
// Since plot() must be in global scope, we define the logic manually for each cloud.
// We use a helper function for the security call to keep it clean.
f_get_tf_emas(string tf) =>
    [request.security(syminfo.tickerid, tf, ta.ema(close, EMA_1_LEN), gaps = barmerge.gaps_off), 
     request.security(syminfo.tickerid, tf, ta.ema(close, EMA_2_LEN), gaps = barmerge.gaps_off)]

// --- Inputs ---
// Cloud 1
showCloud1 = input.bool(true, "Cloud 1", inline = "c1")
tf1        = input.timeframe("15", "", inline = "c1")
color1     = input.color(#089981, "", inline = "c1")

// Cloud 2
showCloud2 = input.bool(true, "Cloud 2", inline = "c2")
tf2        = input.timeframe("30", "", inline = "c2")
color2     = input.color(#f23645, "", inline = "c2")

// Cloud 3
showCloud3 = input.bool(true, "Cloud 3", inline = "c3")
tf3        = input.timeframe("60", "", inline = "c3")
color3     = input.color(#5b9cf6, "", inline = "c3")

// Cloud 4
showCloud4 = input.bool(false, "Cloud 4", inline = "c4")
tf4        = input.timeframe("240", "", inline = "c4")
color4     = input.color(#ff9800, "", inline = "c4")

// Cloud 5
showCloud5 = input.bool(false, "Cloud 5", inline = "c5")
tf5        = input.timeframe("D", "", inline = "c5")
color5     = input.color(#9c27b0, "", inline = "c5")

// Cloud 6
showCloud6 = input.bool(false, "Cloud 6", inline = "c6")
tf6        = input.timeframe("W", "", inline = "c6")
color6     = input.color(#795548, "", inline = "c6")

// Cloud 7
showCloud7 = input.bool(false, "Cloud 7", inline = "c7")
tf7        = input.timeframe("M", "", inline = "c7")
color7     = input.color(#607d8b, "", inline = "c7")

showLabels = input.bool(true, "Show Timeframe Labels", tooltip = "Displays the timeframe name at the end of the cloud lines.")

// --- Calculations & Plotting ---

// Cloud 1
[ema1_1, ema1_2] = f_get_tf_emas(tf1)
p1_1 = plot(showCloud1 ? ema1_1 : na, "C1 EMA 78", color1)
p1_2 = plot(showCloud1 ? ema1_2 : na, "C1 EMA 84", color1)
fill(p1_1, p1_2, color.new(color1, 80), "C1 Fill")

// Cloud 2
[ema2_1, ema2_2] = f_get_tf_emas(tf2)
p2_1 = plot(showCloud2 ? ema2_1 : na, "C2 EMA 78", color2)
p2_2 = plot(showCloud2 ? ema2_2 : na, "C2 EMA 84", color2)
fill(p2_1, p2_2, color.new(color2, 80), "C2 Fill")

// Cloud 3
[ema3_1, ema3_2] = f_get_tf_emas(tf3)
p3_1 = plot(showCloud3 ? ema3_1 : na, "C3 EMA 78", color3)
p3_2 = plot(showCloud3 ? ema3_2 : na, "C3 EMA 84", color3)
fill(p3_1, p3_2, color.new(color3, 80), "C3 Fill")

// Cloud 4
[ema4_1, ema4_2] = f_get_tf_emas(tf4)
p4_1 = plot(showCloud4 ? ema4_1 : na, "C4 EMA 78", color4)
p4_2 = plot(showCloud4 ? ema4_2 : na, "C4 EMA 84", color4)
fill(p4_1, p4_2, color.new(color4, 80), "C4 Fill")

// Cloud 5
[ema5_1, ema5_2] = f_get_tf_emas(tf5)
p5_1 = plot(showCloud5 ? ema5_1 : na, "C5 EMA 78", color5)
p5_2 = plot(showCloud5 ? ema5_2 : na, "C5 EMA 84", color5)
fill(p5_1, p5_2, color.new(color5, 80), "C5 Fill")

// Cloud 6
[ema6_1, ema6_2] = f_get_tf_emas(tf6)
p6_1 = plot(showCloud6 ? ema6_1 : na, "C6 EMA 78", color6)
p6_2 = plot(showCloud6 ? ema6_2 : na, "C6 EMA 84", color6)
fill(p6_1, p6_2, color.new(color6, 80), "C6 Fill")

// Cloud 7
[ema7_1, ema7_2] = f_get_tf_emas(tf7)
p7_1 = plot(showCloud7 ? ema7_1 : na, "C7 EMA 78", color7)
p7_2 = plot(showCloud7 ? ema7_2 : na, "C7 EMA 84", color7)
fill(p7_1, p7_2, color.new(color7, 80), "C7 Fill")
// --- Labels ---
var label1 = label.new(na, na, "", color = #00000000, style = label.style_label_left)
var label2 = label.new(na, na, "", color = #00000000, style = label.style_label_left)
var label3 = label.new(na, na, "", color = #00000000, style = label.style_label_left)
var label4 = label.new(na, na, "", color = #00000000, style = label.style_label_left)
var label5 = label.new(na, na, "", color = #00000000, style = label.style_label_left)
var label6 = label.new(na, na, "", color = #00000000, style = label.style_label_left)
var label7 = label.new(na, na, "", color = #00000000, style = label.style_label_left)

if barstate.islast and showLabels
    if showCloud1
        label.set_xy(label1, bar_index, ema1_1)
        label.set_text(label1, tf1)
        label.set_textcolor(label1, color1)
    else
        label.set_xy(label1, na, na)

    if showCloud2
        label.set_xy(label2, bar_index, ema2_1)
        label.set_text(label2, tf2)
        label.set_textcolor(label2, color2)
    else
        label.set_xy(label2, na, na)

    if showCloud3
        label.set_xy(label3, bar_index, ema3_1)
        label.set_text(label3, tf3)
        label.set_textcolor(label3, color3)
    else
        label.set_xy(label3, na, na)

    if showCloud4
        label.set_xy(label4, bar_index, ema4_1)
        label.set_text(label4, tf4)
        label.set_textcolor(label4, color4)
    else
        label.set_xy(label4, na, na)

    if showCloud5
        label.set_xy(label5, bar_index, ema5_1)
        label.set_text(label5, tf5)
        label.set_textcolor(label5, color5)
    else
        label.set_xy(label5, na, na)

    if showCloud6
        label.set_xy(label6, bar_index, ema6_1)
        label.set_text(label6, tf6)
        label.set_textcolor(label6, color6)
    else
        label.set_xy(label6, na, na)

    if showCloud7
        label.set_xy(label7, bar_index, ema7_1)
        label.set_text(label7, tf7)
        label.set_textcolor(label7, color7)
    else
        label.set_xy(label7, na, na)
````
