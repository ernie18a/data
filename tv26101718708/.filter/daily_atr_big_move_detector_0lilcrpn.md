# Daily ATR Big Move Detector

- url: https://www.tradingview.com/script/0LILCrPn-Daily-ATR-Big-Move-Detector/
- type: indicator
- pine_id: PUB;293da2d8327c46bea55ea577b42f5eed
- version: 1.0

## Description

Daily ATR Big Move DetectorThis indicator identifies significant intraday price moves relative to the Daily ATR (14).It automatically detects both bullish surges and bearish drops on your current chart timeframe (ideal for 5m, 15m, 30m charts) when a candle’s range exceeds 20% of the Daily ATR.Key Features:Highlights candles that represent 20%+ of the Daily ATR
Labels each qualifying candle with the exact percentage (e.g. “22.45% of Daily ATR”)
“Manipulation Candle” label automatically appears on moves ≥ 25% of Daily ATR
Color-coded:Green tones for bullish moves
Red/purple tones for bearish moves

Shows current Daily ATR value and candle percentage in a clean table
Works on any symbol (stocks, ETFs, futures, crypto, etc.)

Perfect for spotting potential manipulation moves, exhaustion candles, or high-conviction intraday momentum.Recommended Timeframes: 5min, 15min, or 30min charts (using Daily ATR as reference).

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Smokey1559

//@version=6
indicator("Daily ATR Big Move Detector", shorttitle="ATR Move", overlay=true, max_labels_count=500)

// Daily ATR
daily_atr = request.security(syminfo.tickerid, "D", ta.atr(14), lookahead = barmerge.lookahead_off)

// Candle calculation
candle_move = math.abs(open - close)
percent_of_atr = (candle_move / daily_atr) * 100
is_bullish = close > open
is_significant = candle_move >= (daily_atr * 0.20) and barstate.isconfirmed

// Background
bgcolor(is_significant ? (is_bullish ? color.new(color.green, 80) : color.new(color.red, 80)) : na)

// Labels
if is_significant
    direction = is_bullish ? "Bullish Surge\n" : "Bearish Drop\n"
    manip = percent_of_atr >= 25 ? "Manipulation Candle\n" : ""
    label_text = direction + manip + str.tostring(percent_of_atr, "#.##") + "% of Daily ATR"
    
    label_color = percent_of_atr >= 50 ? (is_bullish ? color.lime : color.fuchsia) :
                  percent_of_atr >= 35 ? (is_bullish ? color.green : color.red) :
                  percent_of_atr >= 25 ? (is_bullish ? color.new(#006400, 0) : color.orange) : 
                  (is_bullish ? color.green : color.red)
    
    label.new(bar_index, is_bullish ? low : high, label_text, 
              style = is_bullish ? label.style_label_up : label.style_label_down, 
              color = label_color, textcolor = color.white, size = size.normal, 
              yloc = is_bullish ? yloc.belowbar : yloc.abovebar)

// Info Table
var table info = table.new(position.top_right, 1, 4, bgcolor = color.new(color.black, 80))
if barstate.islast
    table.cell(info, 0, 0, "Daily ATR", text_color = color.white)
    table.cell(info, 0, 1, str.tostring(daily_atr, "#.####"), text_color = color.yellow)
    table.cell(info, 0, 2, "Candle %", text_color = color.white)
    table.cell(info, 0, 3, str.tostring(percent_of_atr, "#.##") + "%", 
               text_color = is_significant ? (is_bullish ? color.green : color.red) : color.gray)

// Plot
plot(daily_atr, "Daily ATR", color = color.new(color.gray, 60))
````
