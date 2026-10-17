# Analyst Targets + PE & Forward PE

- url: https://www.tradingview.com/script/t8nBasa2-Analyst-Targets-PE-Forward-PE/
- type: indicator
- pine_id: PUB;f850ff9b9a3c4f6fa3a114f571f50984
- version: 1.0

## Description

[b]Analyst Targets + PE & Forward PE
[/b]
This indicator displays key fundamental and analyst data directly on your chart in a clean table, along with visual target price lines.
Features:

[b]Trailing P/E (TTM) and Forward P/E[/b]
Full Analyst Consensus Breakdown:
Strong Buy
Buy
Hold
Sell
Strong Sell

[b]Overall Analyst Rating[/b] (Strong Buy to Strong Sell)
Analyst Price Targets:
Average Target
High Target
Low Target

[b]Visual Target Lines[/b] (all in light green with different styles for easy distinction)
Dynamic labels showing exact target values

The table updates in real-time and only appears on the last bar for a clean look. Target lines automatically adjust and extend as new bars form.

[b]Perfect For:[/b]

Swing traders and investors who want quick insight into valuation and Wall Street consensus
Checking how the current price compares to analyst targets
Monitoring changes in analyst sentiment

[b]Settings:[/b]

Table position can be changed in the script (currently Top Right)
Line length and styles are customizable

## Source Code

````pine
//@version=5
indicator("Analyst Targets + PE & Forward PE", shorttitle="Analyst Targets", overlay=true, max_lines_count=10)

// === Fundamentals ===
eps_ttm     = request.financial(syminfo.tickerid, "EARNINGS_PER_SHARE_DILUTED", "TTM")
pe          = close / (eps_ttm != 0 ? eps_ttm : na)
forward_pe  = request.financial(syminfo.tickerid, "PRICE_EARNINGS_FORWARD", "FY")

// === Analyst Recommendations - Full Breakdown ===
strong_buy  = syminfo.recommendations_buy_strong
buy         = syminfo.recommendations_buy
hold        = syminfo.recommendations_hold
sell        = syminfo.recommendations_sell
strong_sell = syminfo.recommendations_sell_strong

total_analysts = strong_buy + buy + hold + sell + strong_sell

// Consensus Rating
consensus_score = total_analysts > 0 ? (strong_buy*1.0 + buy*0.75 + hold*0.5 + sell*0.25) / total_analysts : na
rating_text = consensus_score >= 0.8 ? "Strong Buy" :
              consensus_score >= 0.65 ? "Buy" :
              consensus_score >= 0.45 ? "Hold" :
              consensus_score >= 0.25 ? "Sell" : "Strong Sell"

// === Analyst Targets ===
target_avg  = syminfo.target_price_average
target_high = syminfo.target_price_high
target_low  = syminfo.target_price_low

// === Light Green Lines ===
light_green = color.new(color.green, 30)

var line avg_line  = na
var line high_line = na
var line low_line  = na

if barstate.islastconfirmedhistory or barstate.isrealtime
    // Average Target
    if not na(target_avg)
        if na(avg_line)
            avg_line := line.new(bar_index - 40, target_avg, bar_index + 10, target_avg, 
                                 color=light_green, width=2, style=line.style_dashed)
        else
            line.set_xy1(avg_line, bar_index - 40, target_avg)
            line.set_xy2(avg_line, bar_index + 10, target_avg)
    
    // High Target
    if not na(target_high)
        if na(high_line)
            high_line := line.new(bar_index - 40, target_high, bar_index + 10, target_high, 
                                  color=light_green, width=1)
        else
            line.set_xy1(high_line, bar_index - 40, target_high)
            line.set_xy2(high_line, bar_index + 10, target_high)
    
    // Low Target
    if not na(target_low)
        if na(low_line)
            low_line := line.new(bar_index - 40, target_low, bar_index + 10, target_low, 
                                 color=light_green, width=1, style=line.style_dotted)
        else
            line.set_xy1(low_line, bar_index - 40, target_low)
            line.set_xy2(low_line, bar_index + 10, target_low)

// === Table with Full Analyst Breakdown ===
var table info = table.new(position.top_right, 2, 12, bgcolor=color.new(color.black, 85), border_width=1)

if barstate.islast
    table.cell(info, 0, 0, "Metric",           bgcolor=color.navy, text_color=color.white)
    table.cell(info, 1, 0, "Value",            bgcolor=color.navy, text_color=color.white)
    
    table.cell(info, 0, 1, "P/E (TTM)",        text_color=color.white)
    table.cell(info, 1, 1, str.tostring(pe, "#.##"), text_color= pe <= 15 ? color.lime : pe <= 25 ? color.yellow : color.red)
    
    table.cell(info, 0, 2, "Forward P/E",      text_color=color.white)
    table.cell(info, 1, 2, str.tostring(forward_pe, "#.##"), text_color= forward_pe <= 15 ? color.lime : forward_pe <= 25 ? color.yellow : color.red)
    
    table.cell(info, 0, 3, "Overall Rating",   text_color=color.white)
    table.cell(info, 1, 3, rating_text, text_color = rating_text == "Strong Buy" or rating_text == "Buy" ? color.lime : rating_text == "Hold" ? color.orange : color.red)
    
    table.cell(info, 0, 4, "Strong Buy",       text_color=color.white)
    table.cell(info, 1, 4, str.tostring(strong_buy), text_color=color.lime)
    
    table.cell(info, 0, 5, "Buy",              text_color=color.white)
    table.cell(info, 1, 5, str.tostring(buy), text_color=color.green)
    
    table.cell(info, 0, 6, "Hold",             text_color=color.white)
    table.cell(info, 1, 6, str.tostring(hold), text_color=color.yellow)
    
    table.cell(info, 0, 7, "Sell",             text_color=color.white)
    table.cell(info, 1, 7, str.tostring(sell), text_color=color.orange)
    
    table.cell(info, 0, 8, "Strong Sell",      text_color=color.white)
    table.cell(info, 1, 8, str.tostring(strong_sell), text_color=color.red)
    
    table.cell(info, 0, 9, "Total Analysts",   text_color=color.white)
    table.cell(info, 1, 9, str.tostring(total_analysts) + " firms", text_color=color.white)
    
    table.cell(info, 0, 10, "Avg Target",      text_color=color.white)
    table.cell(info, 1, 10, str.tostring(target_avg, "#.##"), text_color=light_green)
    
    table.cell(info, 0, 11, "Target Range",    text_color=color.white)
    table.cell(info, 1, 11, str.tostring(target_low,"#.##") + " – " + str.tostring(target_high,"#.##"), text_color=light_green)

// === Labels ===
if barstate.islast
    label.delete(na)
    if not na(target_avg)
        label.new(bar_index, target_avg, " Avg " + str.tostring(target_avg, "#.##"), 
                  style=label.style_label_left, color=light_green, textcolor=color.white, size=size.small)
    if not na(target_high)
        label.new(bar_index, target_high, " High", 
                  style=label.style_label_left, color=light_green, textcolor=color.white, size=size.small)
    if not na(target_low)
        label.new(bar_index, target_low, " Low", 
                  style=label.style_label_left, color=light_green, textcolor=color.white, size=size.small)
````
