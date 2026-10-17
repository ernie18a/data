# CAGR Projection (KenshinC)

- url: https://www.tradingview.com/script/aXTWYyBl-CAGR-Projection-KenshinC/
- type: indicator
- pine_id: PUB;db10a865793f4c04956a6966c27458cf
- version: 1.0

## Description

[b]CAGR Projection (KenshinC)[/b]
Visualize your long-term growth targets directly on the price chart with this powerful CAGR Projection tool.This indicator projects 8 customizable compound annual growth rate (CAGR) lines starting from a user-defined date and initial price. It helps traders and investors clearly see where the price "should be" at different growth assumptions — making it easier to evaluate performance, set realistic targets, or identify over/undervalued conditions.

[b]Key Features:[/b]
Dual Mode: Positive Mode — Standard upward growth projections
Negative Mode — Symmetric reflection (mirrored) over a custom price level (great for mean-reversion or support/resistance visualization)

Choose any start date and custom starting price (or use the open price at the start bar)
8 independent growth rates (from 0.1% up to 10,000%) with individual color customization
Optional growth rate labels on the latest bar
Clean dotted symmetry line in Negative mode
Works on any timeframe and any asset (stocks, crypto, forex, indices, etc.)

[b]How to Use:[/b]
Set your desired Start At date and starting price
Adjust the 8 growth rates according to your expectations (conservative → aggressive)
Switch between Positive and Negative mode depending on your analysis needs
Compare real price action against the projected trajectories

Whether you're doing long-term investing, evaluating a stock's performance against your return targets, or using it as a visual aid for mean-reversion strategies, this indicator provides a clear and intuitive projection framework.Perfect for investors, swing traders, and anyone who thinks in terms of compound growth.

## Source Code

````pine
//@version=6
indicator("CAGR Projection (KenshinC)", overlay=true)

// ==================== CAGR MODE ====================
group_mode = "CAGR Mode Settings"

cagr_mode = input.string("Positive", "CAGR Mode", 
     options = ["Positive", "Negative"], 
     group = group_mode, 
     tooltip = "Positive: Normal growth projection\nNegative: Symmetric reflection over the custom price line")

// ==================== START POINT & CUSTOM PRICE ====================
group_start = "CAGR Start Settings"

cst = input.bool(true, "", inline="start", group=group_start)
st = input.time(timestamp("01 Jan 2020"), "Start At", confirm=false, inline="start", group=group_start)

use_custom_price = input.bool(true, "Use custom start price (as symmetry axis)", group=group_start)
custom_price = input.float(100.0, "Custom Start Price / Symmetry Axis", minval=0.01, step=0.01, group=group_start)

show_label = input.bool(false, "Show Growth Rate Labels")

// ==================== GROWTH RATES ====================
gr1 = input.float(10.0, "Growth Rate 1 (%)", minval=0.1, maxval=10000, step=0.1)
gr2 = input.float(15.0, "Growth Rate 2 (%)", minval=0.1, maxval=10000, step=0.1)
gr3 = input.float(20.0, "Growth Rate 3 (%)", minval=0.1, maxval=10000, step=0.1)
gr4 = input.float(25.0, "Growth Rate 4 (%)", minval=0.1, maxval=10000, step=0.1)
gr5 = input.float(30.0, "Growth Rate 5 (%)", minval=0.1, maxval=10000, step=0.1)
gr6 = input.float(35.0, "Growth Rate 6 (%)", minval=0.1, maxval=10000, step=0.1)
gr7 = input.float(40.0, "Growth Rate 7 (%)", minval=0.1, maxval=10000, step=0.1)
gr8 = input.float(45.0, "Growth Rate 8 (%)", minval=0.1, maxval=10000, step=0.1)

// ==================== COLORS ====================
color1 = input.color(color.blue,    "Line 1 Color")
color2 = input.color(color.red,     "Line 2 Color")
color3 = input.color(color.green,   "Line 3 Color")
color4 = input.color(color.yellow,  "Line 4 Color")
color5 = input.color(color.purple,  "Line 5 Color")
color6 = input.color(color.orange,  "Line 6 Color")
color7 = input.color(color.teal,    "Line 7 Color")
color8 = input.color(color.black,   "Line 8 Color")

// ==================== CALCULATION LOGIC ====================
var float bv = 0.0
var bool  init = false
var int   sp = na                     // Start time (timestamp)

minutes_per_bar = timeframe.in_seconds() / 60
bars_per_year   = 365 * 24 * 60 / minutes_per_bar

// Initialize start point
if (open > 0 and time >= st and not init) or (not cst and not init)
    bv   := use_custom_price ? custom_price : open
    init := true
    sp   := time

// Time elapsed in years
per = (time - sp) / (timeframe.in_seconds() * 1000)

// Calculate positive projections
pos1 = bv * math.pow(1 + gr1/100, per / bars_per_year)
pos2 = bv * math.pow(1 + gr2/100, per / bars_per_year)
pos3 = bv * math.pow(1 + gr3/100, per / bars_per_year)
pos4 = bv * math.pow(1 + gr4/100, per / bars_per_year)
pos5 = bv * math.pow(1 + gr5/100, per / bars_per_year)
pos6 = bv * math.pow(1 + gr6/100, per / bars_per_year)
pos7 = bv * math.pow(1 + gr7/100, per / bars_per_year)
pos8 = bv * math.pow(1 + gr8/100, per / bars_per_year)

// Apply Negative mode (mirror over custom_price)
res1 = cagr_mode == "Negative" ? 2 * custom_price - pos1 : pos1
res2 = cagr_mode == "Negative" ? 2 * custom_price - pos2 : pos2
res3 = cagr_mode == "Negative" ? 2 * custom_price - pos3 : pos3
res4 = cagr_mode == "Negative" ? 2 * custom_price - pos4 : pos4
res5 = cagr_mode == "Negative" ? 2 * custom_price - pos5 : pos5
res6 = cagr_mode == "Negative" ? 2 * custom_price - pos6 : pos6
res7 = cagr_mode == "Negative" ? 2 * custom_price - pos7 : pos7
res8 = cagr_mode == "Negative" ? 2 * custom_price - pos8 : pos8

// ==================== PLOTTING ====================
plot(init ? res1 : na, color=color1, title="Projection 1")
plot(init ? res2 : na, color=color2, title="Projection 2")
plot(init ? res3 : na, color=color3, title="Projection 3")
plot(init ? res4 : na, color=color4, title="Projection 4")
plot(init ? res5 : na, color=color5, title="Projection 5")
plot(init ? res6 : na, color=color6, title="Projection 6")
plot(init ? res7 : na, color=color7, title="Projection 7")
plot(init ? res8 : na, color=color8, title="Projection 8")

// ==================== SYMMETRY LINE (for Negative mode) ====================
var line symmetry_line = na

if cagr_mode == "Negative" and barstate.islast
    if na(symmetry_line)
        symmetry_line := line.new(bar_index - 50, custom_price, bar_index + 50, custom_price,
                                  xloc = xloc.bar_index,
                                  color = color.gray,
                                  style = line.style_dotted,
                                  width = 1)
    else
        line.set_x1(symmetry_line, bar_index - 50)
        line.set_x2(symmetry_line, bar_index + 50)
        line.set_y1(symmetry_line, custom_price)
        line.set_y2(symmetry_line, custom_price)

// ==================== LABELS ====================
if barstate.islast and show_label
    suffix = cagr_mode == "Negative" ? "% ↓ (Mirror)" : "% ↑"
    
    label.new(bar_index, res1, str.tostring(gr1, "#.##") + suffix, 
              color=color.new(color.white, 100), style=label.style_label_up, 
              textcolor=color1, yloc=yloc.price)
    
    label.new(bar_index, res2, str.tostring(gr2, "#.##") + suffix, 
              color=color.new(color.white, 100), style=label.style_label_up, 
              textcolor=color2, yloc=yloc.price)
    
    label.new(bar_index, res3, str.tostring(gr3, "#.##") + suffix, 
              color=color.new(color.white, 100), style=label.style_label_up, 
              textcolor=color3, yloc=yloc.price)
    
    label.new(bar_index, res4, str.tostring(gr4, "#.##") + suffix, 
              color=color.new(color.white, 100), style=label.style_label_up, 
              textcolor=color4, yloc=yloc.price)
    
    label.new(bar_index, res5, str.tostring(gr5, "#.##") + suffix, 
              color=color.new(color.white, 100), style=label.style_label_up, 
              textcolor=color5, yloc=yloc.price)
    
    label.new(bar_index, res6, str.tostring(gr6, "#.##") + suffix, 
              color=color.new(color.white, 100), style=label.style_label_up, 
              textcolor=color6, yloc=yloc.price)
    
    label.new(bar_index, res7, str.tostring(gr7, "#.##") + suffix, 
              color=color.new(color.white, 100), style=label.style_label_up, 
              textcolor=color7, yloc=yloc.price)
    
    label.new(bar_index, res8, str.tostring(gr8, "#.##") + suffix, 
              color=color.new(color.white, 100), style=label.style_label_up, 
              textcolor=color8, yloc=yloc.price)
````
