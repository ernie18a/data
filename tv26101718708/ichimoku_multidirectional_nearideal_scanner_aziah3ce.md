# Ichimoku Multi-Directional Near-Ideal Scanner

- url: https://www.tradingview.com/script/aZiAH3ce-Ichimoku-Multi-Directional-Near-Ideal-Scanner/
- type: indicator
- pine_id: PUB;872c62d6161c4c8c8e36904ebc54feb0
- version: 1.0

## Description

This script will indicicate when the underlying has 4 out of 5 Ichimoku indicators in alignent with an "ideal" setup and is just needing one more to trigger entry.

## Source Code

````pine
//@version=5
indicator("Ichimoku Multi-Directional Near-Ideal Scanner", overlay=true)

// --- Inputs ---
trend_mode  = input.string("Bullish", title="Scan Mode", options=["Bullish", "Bearish"])
tenkan_len  = input.int(9, title="Tenkan-sen Period")
kijun_len   = input.int(26, title="Kijun-sen Period")
senkou_len  = input.int(52, title="Senkou Span B Period")
displacement= input.int(26, title="Displacement")

// --- Ichimoku Calculations ---
donchian(len) => math.avg(ta.highest(len), ta.lowest(len))

tenkan  = donchian(tenkan_len)
kijun   = donchian(kijun_len)
spanA   = math.avg(tenkan, kijun)
spanB   = donchian(senkou_len)

// --- Plot Ichimoku Lines ---
plot(tenkan, color=color.blue, title="Tenkan-sen")
plot(kijun, color=color.maroon, title="Kijun-sen")
p1 = plot(spanA[displacement-1], color=color.green, title="Senkou Span A")
p2 = plot(spanB[displacement-1], color=color.red, title="Senkou Span B")
fill(p1, p2, color = spanA[displacement-1] > spanB[displacement-1] ? color.new(color.green, 92) : color.new(color.red, 92))

// --- Condition Mapping (Bullish vs Bearish) ---
bool cond_price_cloud   = false
bool cond_tk_cross      = false
bool cond_future_cloud  = false
bool cond_price_lines   = false
bool cond_chikou        = false

if trend_mode == "Bullish"
    cond_price_cloud   := (close > spanA[displacement-1]) and (close > spanB[displacement-1])
    cond_tk_cross      := tenkan > kijun
    cond_future_cloud  := spanA > spanB
    cond_price_lines   := (close > tenkan) and (close > kijun)
    cond_chikou        := (close > spanA[displacement*2-2]) and (close > spanB[displacement*2-2])
else // Bearish Mode
    cond_price_cloud   := (close < spanA[displacement-1]) and (close < spanB[displacement-1])
    cond_tk_cross      := tenkan < kijun
    cond_future_cloud  := spanA < spanB
    cond_price_lines   := (close < tenkan) and (close < kijun)
    cond_chikou        := (close < spanA[displacement*2-2]) and (close < spanB[displacement*2-2])

// --- Count Met Conditions ---
int score = 0
score := score + (cond_price_cloud ? 1 : 0)
score := score + (cond_tk_cross ? 1 : 0)
score := score + (cond_future_cloud ? 1 : 0)
score := score + (cond_price_lines ? 1 : 0)
score := score + (cond_chikou ? 1 : 0)

bool near_miss   = (score == 4)
bool ideal_setup = (score == 5)

// --- Visual Alerts ---
color bg_near_color  = trend_mode == "Bullish" ? color.new(color.orange, 85) : color.new(color.purple, 85)
color bg_ideal_color = trend_mode == "Bullish" ? color.new(color.green, 85) : color.new(color.red, 85)

bgcolor(near_miss ? bg_near_color : na, title="Near Miss Window")
bgcolor(ideal_setup ? bg_ideal_color : na, title="Ideal Trend Window")

// --- Dashboard Display ---
var table statusTable = table.new(position.top_right, 2, 6, bgcolor=color.new(color.black, 20), border_width=1)
if barstate.islast
    table.cell(statusTable, 0, 0, trend_mode + " Check", text_color=color.white, bgcolor=color.gray)
    table.cell(statusTable, 1, 0, "Status", text_color=color.white, bgcolor=color.gray)
    
    table.cell(statusTable, 0, 1, "Price vs Cloud", text_color=color.white)
    table.cell(statusTable, 1, 1, cond_price_cloud ? "PASS" : "FAIL", bgcolor=cond_price_cloud ? color.green : color.red)
    
    table.cell(statusTable, 0, 2, "TK Cross", text_color=color.white)
    table.cell(statusTable, 1, 2, cond_tk_cross ? "PASS" : "FAIL", bgcolor=cond_tk_cross ? color.green : color.red)
    
    table.cell(statusTable, 0, 3, "Future Cloud Color", text_color=color.white)
    table.cell(statusTable, 1, 3, cond_future_cloud ? "PASS" : "FAIL", bgcolor=cond_future_cloud ? color.green : color.red)
    
    table.cell(statusTable, 0, 4, "Price vs TK Lines", text_color=color.white)
    table.cell(statusTable, 1, 4, cond_price_lines ? "PASS" : "FAIL", bgcolor=cond_price_lines ? color.green : color.red)
    
    table.cell(statusTable, 0, 5, "Chikou Lagging", text_color=color.white)
    table.cell(statusTable, 1, 5, cond_chikou ? "PASS" : "FAIL", bgcolor=cond_chikou ? color.green : color.red)

// --- Alerts ---
alertcondition(near_miss, title="Near Miss Triggered", message="Asset is 1 condition away from ideal trend alignment.")
````
