# Analyst Price Target

- url: https://www.tradingview.com/script/0zEdjxTl-Analyst-Price-Target/
- type: indicator
- pine_id: PUB;fc515c460c9d4157ac6be2dd03fa75ca
- version: 1.0

## Description

Analyst targets & no of analysts 
The format is: max, avg, min price, strong buy, buy, hold, sell, strong sell

## Source Code

````pine
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)
// © Zeiierman (Modified for Status Line Display)
//@version=5
// The shorttitle acts as the text label in your status line
indicator("Analyst Price Target", shorttitle="Analyst Targets:", overlay=true)

// ~~ Robust Data Capture (First Principles) ~~ //
// Using 'var' ensures the data is remembered even if the real-time tick momentarily drops.
var float tgt_max = na
var float tgt_avg = na
var float tgt_min = na

var float rec_sb = na
var float rec_b  = na
var float rec_h  = na
var float rec_s  = na
var float rec_ss = na

if not na(syminfo.target_price_high)
    tgt_max := syminfo.target_price_high
if not na(syminfo.target_price_average)
    tgt_avg := syminfo.target_price_average
if not na(syminfo.target_price_low)
    tgt_min := syminfo.target_price_low

if not na(syminfo.recommendations_buy_strong)
    rec_sb := syminfo.recommendations_buy_strong
if not na(syminfo.recommendations_buy)
    rec_b := syminfo.recommendations_buy
if not na(syminfo.recommendations_hold)
    rec_h := syminfo.recommendations_hold
if not na(syminfo.recommendations_sell)
    rec_s := syminfo.recommendations_sell
if not na(syminfo.recommendations_sell_strong)
    rec_ss := syminfo.recommendations_sell_strong

// ~~ Output to Indicator Status Line ~~ //
// By plotting the variables and setting display to 'status_line', TradingView will string 
// the numbers side-by-side next to the indicator name at the top left, without drawing anything on the chart.

// Price Targets
plot(tgt_max, title="Max Price",   color=color.rgb(8, 153, 129),  display=display.status_line + display.data_window)
plot(tgt_avg, title="Avg Price",   color=color.rgb(23, 108, 255), display=display.status_line + display.data_window)
plot(tgt_min, title="Min Price",   color=color.rgb(242, 54, 69),  display=display.status_line + display.data_window)

// Analyst Recommendations
plot(rec_sb,  title="Strong Buy",  color=color.lime,              display=display.status_line + display.data_window)
plot(rec_b,   title="Buy",         color=color.green,             display=display.status_line + display.data_window)
plot(rec_h,   title="Hold",        color=color.orange,            display=display.status_line + display.data_window)
plot(rec_s,   title="Sell",        color=color.red,               display=display.status_line + display.data_window)
plot(rec_ss,  title="Strong Sell", color=color.maroon,            display=display.status_line + display.data_window)
````
