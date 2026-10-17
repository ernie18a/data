# Quad Triple EMA Trend Bands

- url: https://www.tradingview.com/script/siAWIOA2-Quad-Triple-EMA-Trend-Bands/
- type: indicator
- pine_id: PUB;80fdb0675cfa473b9c7ee3b89d607c28
- version: 1.0

## Description

Four groups of triple EMA to gauge trend strength and variance

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © LuxAlgo

//@version=6
indicator("Quad Triple EMA Trend Bands", overlay = true)

// --- Constants ---
BULL_COLOR = #089981
BEAR_COLOR = #f23645

// ==========================================
// BAND 1
// ==========================================
gp1 = "Triple Band 1"
b1_f_len = input.int(10, "Fast",   minval = 1, inline = "b1", group = gp1)
b1_m_len = input.int(20, "Medium", minval = 1, inline = "b1", group = gp1)
b1_s_len = input.int(30, "Slow",   minval = 1, inline = "b1", group = gp1)

b1_f = ta.ema(close, b1_f_len)
b1_m = ta.ema(close, b1_m_len)
b1_s = ta.ema(close, b1_s_len)

b1_up   = b1_f > b1_s
b1_down = b1_f < b1_s
b1_col  = b1_up ? color.new(BULL_COLOR, 80) : b1_down ? color.new(BEAR_COLOR, 80) : na

p1_f = plot(b1_f, "B1 Fast", color = color.new(chart.fg_color, 100))
p1_m = plot(b1_m, "B1 Mid",  color = color.new(chart.fg_color, 100))
p1_s = plot(b1_s, "B1 Slow", color = color.new(chart.fg_color, 100))
fill(p1_f, p1_s, b1_col, "B1 Fill")

// ==========================================
// BAND 2
// ==========================================
gp2 = "Triple Band 2"
b2_f_len = input.int(50,  "Fast",   minval = 1, inline = "b2", group = gp2)
b2_m_len = input.int(75,  "Medium", minval = 1, inline = "b2", group = gp2)
b2_s_len = input.int(100, "Slow",   minval = 1, inline = "b2", group = gp2)

b2_f = ta.ema(close, b2_f_len)
b2_m = ta.ema(close, b2_m_len)
b2_s = ta.ema(close, b2_s_len)

b2_up   = b2_f > b2_s
b2_down = b2_f < b2_s
b2_col  = b2_up ? color.new(BULL_COLOR, 75) : b2_down ? color.new(BEAR_COLOR, 75) : na

p2_f = plot(b2_f, "B2 Fast", color = color.new(chart.fg_color, 100))
p2_m = plot(b2_m, "B2 Mid",  color = color.new(chart.fg_color, 100))
p2_s = plot(b2_s, "B2 Slow", color = color.new(chart.fg_color, 100))
fill(p2_f, p2_s, b2_col, "B2 Fill")

// ==========================================
// BAND 3
// ==========================================
gp3 = "Triple Band 3"
b3_f_len = input.int(150, "Fast",   minval = 1, inline = "b3", group = gp3)
b3_m_len = input.int(200, "Medium", minval = 1, inline = "b3", group = gp3)
b3_s_len = input.int(250, "Slow",   minval = 1, inline = "b3", group = gp3)

b3_f = ta.ema(close, b3_f_len)
b3_m = ta.ema(close, b3_m_len)
b3_s = ta.ema(close, b3_s_len)

b3_up   = b3_f > b3_s
b3_down = b3_f < b3_s
b3_col  = b3_up ? color.new(BULL_COLOR, 70) : b3_down ? color.new(BEAR_COLOR, 70) : na

p3_f = plot(b3_f, "B3 Fast", color = color.new(chart.fg_color, 100))
p3_m = plot(b3_m, "B3 Mid",  color = color.new(chart.fg_color, 100))
p3_s = plot(b3_s, "B3 Slow", color = color.new(chart.fg_color, 100))
fill(p3_f, p3_s, b3_col, "B3 Fill")

// ==========================================
// BAND 4
// ==========================================
gp4 = "Triple Band 4"
b4_f_len = input.int(300, "Fast",   minval = 1, inline = "b4", group = gp4)
b4_m_len = input.int(400, "Medium", minval = 1, inline = "b4", group = gp4)
b4_s_len = input.int(500, "Slow",   minval = 1, inline = "b4", group = gp4)

b4_f = ta.ema(close, b4_f_len)
b4_m = ta.ema(close, b4_m_len)
b4_s = ta.ema(close, b4_s_len)

b4_up   = b4_f > b4_s
b4_down = b4_f < b4_s
b4_col  = b4_up ? color.new(BULL_COLOR, 65) : b4_down ? color.new(BEAR_COLOR, 65) : na

p4_f = plot(b4_f, "B4 Fast", color = color.new(chart.fg_color, 100))
p4_m = plot(b4_m, "B4 Mid",  color = color.new(chart.fg_color, 100))
p4_s = plot(b4_s, "B4 Slow", color = color.new(chart.fg_color, 100))
fill(p4_f, p4_s, b4_col, "B4 Fill")
````
