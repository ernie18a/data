# KTP Basic Parameters

- url: https://www.tradingview.com/script/6gE4mkHG-KTP-Basic-Parameters/
- type: indicator
- pine_id: PUB;9b3b8d1e78974f0c8a0cbb5ba3617c2a
- version: 1.0

## Description

Very basic indicator displaying  the following parameters (in order) of the candle under the cross hair. 
True Range
Average True Range
Daily Ave True Range (This will be same for all the candles of the day)
Filled Percentage (Percentage of the body to total size) 

This info can be used to :
- figure out Filled-Unfilled-Filled patterns which might indicate Demand and Supply Zones.
- estimate the buffer for entry and stoploss from DATR. 
- Search for boring/ base candles based on the filled percentage
- compare TR and ATR with previous and next candles
- The spikes in the bottom indicate explosive price movements So wherever you see a Peak-Valley-Peak pattern, it should indicate Filled-Unfilled-Filled pattern visually. 

This should help beginners to train their mind and train their brain. 


Disclaimer: Not associated with KTP in any capacity. Thanks to Ravi Sir for teaching these concepts though.

## Source Code

````pine
//@version=6
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/


indicator(title = 'KTP Basic Parameters', shorttitle = 'TR, ATR, DATR, Filled', overlay = false)
import TradingView/ta/10	

valtr = ta.tr(true)
valatr = ta.atr(14)
datr = request.security(syminfo.tickerid, '1D', ta.atr(14))
tratr_ratio = valtr/valatr
filled_percentage =(math.abs(open-close)*100/(high-low))

// plot_tratr = plot(tratr_ratio -1,  title ="TR/ATR" , color=color.silver, style = plot.style_columns)
// plot_one = plot(, 'One', color.blue)
plot_tr = plot(valtr, title = 'TR', color = color.blue) 
plot_atr = plot(valatr, title = 'ATR', color = color.green)
plot_datr = plot(datr, title = 'DATR', color = color.new(color.black, 20), display = display.status_line + display.data_window)
plot_filled = plot(filled_percentage, title = "Filled", color = color.red, display = display.status_line + display.data_window)


fill_color = valtr > valatr ? color.new(color.green, 80) : color.new(color.red, 80)
fill(plot_tr, plot_atr, color = fill_color)

// bgcolor(valtr < valatr ? color.new(color.red,96) : color.new(color.green, 96))
````
