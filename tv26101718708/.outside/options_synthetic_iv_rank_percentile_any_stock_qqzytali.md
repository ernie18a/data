# OPTIONS Synthetic IV Rank & Percentile [Any Stock]

- url: https://www.tradingview.com/script/QQZYtALI-OPTIONS-Synthetic-IV-Rank-Percentile-Any-Stock/
- type: indicator
- pine_id: PUB;1b231e3b0a2547728a0f791e893dd5d0
- version: 1.0

## Description

I wanted an indicator to help me visualize options IV.  
It works on any stock, ETF, index, crypto, or forex pair because it only uses the chart’s price data (no options chain needed).

I hope this helps

## Source Code

````pine
//@version=5
indicator("Synthetic IV Rank & Percentile 📊 [Any Stock]", shorttitle="Synth IV Rank", overlay=false, precision=2)

// ── Inputs ─────────────────────────────────────
hvLength     = input.int(20,  "HV Calculation Length (bars)", minval=1, group="Volatility Settings")
rankLength   = input.int(252, "Rank / Percentile Lookback (trading days)", minval=10, group="Volatility Settings")

// ── Synthetic Implied Volatility ──
dailyReturn = math.log(close / close[1])
hv          = ta.stdev(dailyReturn, hvLength) * math.sqrt(252) * 100

// ── IV Rank & Percentile ──
hvLow       = ta.lowest(hv, rankLength)
hvHigh      = ta.highest(hv, rankLength)
ivRank      = (hv - hvLow) / math.max(hvHigh - hvLow, 0.0001) * 100
ivPercentile = ta.percentrank(hv, rankLength)

// ── Plots ─────────────────────────────────────
plot(hv,           title="Synthetic IV %",      color=color.blue,    linewidth=2)
plot(ivRank,       title="IV Rank",            color=color.orange,  linewidth=2)
plot(ivPercentile, title="IV Percentile",     color=color.fuchsia, linewidth=2)

// Background zones
bgcolor(ivRank > 70 ? color.new(color.red, 85)   : na, title="High IV Zone")
bgcolor(ivRank < 30 ? color.new(color.green, 85) : na, title="Low IV Zone")

// Horizontal lines
hline(50, "Neutral", color=color.gray, linestyle=hline.style_dotted)
hline(70, "High IV", color=color.red,   linestyle=hline.style_dashed)
hline(30, "Low IV",  color=color.green, linestyle=hline.style_dashed)

// ── Color Key Table (Top Right) ─────────────────────────────
var table legend = table.new(position.top_right, 2, 8, bgcolor=color.new(color.black, 85), border_width=1, frame_color=color.gray)

if barstate.islast
    // Header
    table.cell(legend, 0, 0, "Indicator",     text_color=color.white, text_size=size.small)
    table.cell(legend, 1, 0, "Meaning",       text_color=color.white, text_size=size.small)
    
    // Lines
    table.cell(legend, 0, 1, "Blue Line",     text_color=color.blue,   text_size=size.normal)
    table.cell(legend, 1, 1, "Synthetic IV %", text_color=color.white, text_size=size.small)
    
    table.cell(legend, 0, 2, "Orange Line",   text_color=color.orange, text_size=size.normal)
    table.cell(legend, 1, 2, "IV Rank (0-100)", text_color=color.white, text_size=size.small)
    
    table.cell(legend, 0, 3, "Pink Line",     text_color=color.fuchsia, text_size=size.normal)
    table.cell(legend, 1, 3, "IV Percentile", text_color=color.white,  text_size=size.small)
    
    // Current Values
    table.cell(legend, 0, 4, "Current IV",    text_color=color.white, text_size=size.small)
    table.cell(legend, 1, 4, str.tostring(hv, "0.00") + "%", text_color=color.blue, text_size=size.normal)
    
    table.cell(legend, 0, 5, "Current Rank",  text_color=color.white, text_size=size.small)
    table.cell(legend, 1, 5, str.tostring(ivRank, "0.0"), 
               text_color = ivRank > 70 ? color.red : ivRank < 30 ? color.green : color.orange, 
               text_size=size.normal)
    
    // Color Key
    table.cell(legend, 0, 6, "🟢 Green Zone", text_color=color.green,  text_size=size.normal)
    table.cell(legend, 1, 6, "IV Rank < 30 → Best time to Buy Options", text_color=color.white, text_size=size.small)
    
    table.cell(legend, 0, 7, "🔴 Red Zone",   text_color=color.red,    text_size=size.normal)
    table.cell(legend, 1, 7, "IV Rank > 70 → Expensive (Better for Selling)", text_color=color.white, text_size=size.small)

// ── Alerts ─────────────────────────────────────
alertcondition(ivRank < 30, title="IV Rank Low (Buy Options)",  message="Synthetic IV Rank is LOW → favorable for buying options on this stock")
alertcondition(ivRank > 70, title="IV Rank High (Sell Options)", message="Synthetic IV Rank is HIGH → favorable for selling premium")
````
