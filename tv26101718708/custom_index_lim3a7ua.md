# Custom Index

- url: https://www.tradingview.com/script/lim3a7Ua-Custom-Index/
- type: indicator
- pine_id: PUB;17a6eb5815b84b3c8bcbbd089217d41c
- version: 2.0

## Description

The idea is to create custom index that can be use to visually judge the relative strength. It works best on line grph as the % calculation logic for Bar graph make the plot show incorrect percentage values. It works well for visual clue but the accuracy during plotting is lot.

## Source Code

````pine
//@version=6
// scale.none ignores axes so the lines and candles can stretch together
indicator(title="Custom Scaled Index", shorttitle="Index", overlay=true, scale=scale.none, format = format.price)

// Inputs
index_name = input.string(title="Your Index Name", defval="My Custom Basket")
show_table = input.bool(title="Show Debug Price Table", defval=true)

groupName = "Hidden Stock Settings"
symbol_1    = input.bool(true, 'Symbol 1', inline='1', group=groupName, display = display.none)
ticker_1    = input.symbol('LZ', '', inline='1', group=groupName, display = display.none)
weighting_1 = input.float(10, 'Weight %', inline='1', group=groupName, display = display.none) / 100.0

symbol_2    = input.bool(true, 'Symbol 2', inline='2', group=groupName, display = display.none)
ticker_2    = input.symbol('BAND', '', inline='2', group=groupName, display = display.none)
weighting_2 = input.float(10, 'Weight %', inline='2', group=groupName, display = display.none) / 100.0

symbol_3    = input.bool(true, 'Symbol 3', inline='3', group=groupName, display = display.none)
ticker_3    = input.symbol('DM', '', inline='3', group=groupName, display = display.none)
weighting_3 = input.float(10, 'Weight %', inline='3', group=groupName, display = display.none) / 100.0

symbol_4    = input.bool(true, 'Symbol 4', inline='4', group=groupName, display = display.none)
ticker_4    = input.symbol('ONON', '', inline='4', group=groupName, display = display.none)
weighting_4 = input.float(10, 'Weight %', inline='4', group=groupName, display = display.none) / 100.0

symbol_5    = input.bool(true, 'Symbol 5', inline='5', group=groupName, display = display.none)
ticker_5    = input.symbol('EXFY', '', inline='5', group=groupName, display = display.none)
weighting_5 = input.float(10, 'Weight %', inline='5', group=groupName, display = display.none) / 100.0

symbol_6    = input.bool(true, 'Symbol 6', inline='6', group=groupName, display = display.none)
ticker_6    = input.symbol('NRDS', '', inline='6', group=groupName, display = display.none)
weighting_6 = input.float(10, 'Weight %', inline='6', group=groupName, display = display.none) / 100.0

symbol_7    = input.bool(true, 'Symbol 7', inline='7', group=groupName, display = display.none)
ticker_7    = input.symbol('RDFN', '', inline='7', group=groupName, display = display.none)
weighting_7 = input.float(10, 'Weight %', inline='7', group=groupName, display = display.none) / 100.0

symbol_8    = input.bool(true, 'Symbol 8', inline='8', group=groupName, display = display.none)
ticker_8    = input.symbol('UPWK', '', inline='8', group=groupName, display = display.none)
weighting_8 = input.float(10, 'Weight %', inline='8', group=groupName, display = display.none) / 100.0

symbol_9    = input.bool(true, 'Symbol 9', inline='9', group=groupName, display = display.none)
ticker_9    = input.symbol('STNE', '', inline='9', group=groupName, display = display.none)
weighting_9 = input.float(10, 'Weight %', inline='9', group=groupName, display = display.none) / 100.0

symbol_10    = input.bool(true, 'Symbol 10', inline='10', group=groupName, display = display.none)
ticker_10    = input.symbol('BAND', '', inline='10', group=groupName, display = display.none)
weighting_10 = input.float(10, 'Weight %', inline='10', group=groupName, display = display.none) / 100.0

// 1. Fetching raw prices
s1 = symbol_1 ? nz(request.security(ticker_1, timeframe.period, close), 0) : 0
s2 = symbol_2 ? nz(request.security(ticker_2, timeframe.period, close), 0) : 0
s3 = symbol_3 ? nz(request.security(ticker_3, timeframe.period, close), 0) : 0
s4 = symbol_4 ? nz(request.security(ticker_4, timeframe.period, close), 0) : 0
s5 = symbol_5 ? nz(request.security(ticker_5, timeframe.period, close), 0) : 0
s6 = symbol_6 ? nz(request.security(ticker_6, timeframe.period, close), 0) : 0
s7 = symbol_7 ? nz(request.security(ticker_7, timeframe.period, close), 0) : 0
s8 = symbol_8 ? nz(request.security(ticker_8, timeframe.period, close), 0) : 0
s9 = symbol_9 ? nz(request.security(ticker_9, timeframe.period, close), 0) : 0
s10 = symbol_10 ? nz(request.security(ticker_10, timeframe.period, close), 0) : 0

// Grab starting prices on the first visible bar
var float base_s1 = na, var float base_s2 = na, var float base_s3 = na
var float base_s4 = na, var float base_s5 = na, var float base_s6 = na
var float base_s7 = na, var float base_s8 = na, var float base_s9 = na, var float base_s10 = na
var float base_chart = na 

is_first_candle = (time == chart.left_visible_bar_time)

if is_first_candle
    base_s1 := s1
    base_s2 := s2
    base_s3 := s3
    base_s4 := s4
    base_s5 := s5
    base_s6 := s6
    base_s7 := s7
    base_s8 := s8
    base_s9 := s9
    base_s10 := s10
    base_chart := close

// 2. Finding the Scaling Factors (Multipliers)
m1 = 1.0
m2 = (base_s1 > 0) ? base_s2 / base_s1 : 1.0
m3 = (base_s1 > 0) ? base_s3 / base_s1 : 1.0
m4 = (base_s1 > 0) ? base_s4 / base_s1 : 1.0
m5 = (base_s1 > 0) ? base_s5 / base_s1 : 1.0
m6 = (base_s1 > 0) ? base_s6 / base_s1 : 1.0
m7 = (base_s1 > 0) ? base_s7 / base_s1 : 1.0
m8 = (base_s1 > 0) ? base_s8 / base_s1 : 1.0
m9 = (base_s1 > 0) ? base_s9 / base_s1 : 1.0
m10 = (base_s1 > 0) ? base_s10 / base_s1 : 1.0 // 💡 Fixed reference bug here

// 3. Normalising Prices
norm_s1 = (m1 > 0) ? (s1 / m1) : 0
norm_s2 = (m2 > 0) ? (s2 / m2) : 0
norm_s3 = (m3 > 0) ? (s3 / m3) : 0
norm_s4 = (m4 > 0) ? (s4 / m4) : 0
norm_s5 = (m5 > 0) ? (s5 / m5) : 0
norm_s6 = (m6 > 0) ? (s6 / m6) : 0
norm_s7 = (m7 > 0) ? (s7 / m7) : 0
norm_s8 = (m8 > 0) ? (s8 / m8) : 0
norm_s9 = (m9 > 0) ? (s9 / m9) : 0
norm_s10 = (m10 > 0) ? (s10 / m10) : 0

weighted_price = (norm_s1 * weighting_1) + (norm_s2 * weighting_2) + (norm_s3 * weighting_3) + 
                 (norm_s4 * weighting_4) + (norm_s5 * weighting_5) + (norm_s6 * weighting_6) + 
                 (norm_s7 * weighting_7) + (norm_s8 * weighting_8) + (norm_s9 * weighting_9) + 
                 (norm_s10 * weighting_10)

total_active_weight = (symbol_1 ? weighting_1 : 0) + (symbol_2 ? weighting_2 : 0) + 
                      (symbol_3 ? weighting_3 : 0) + (symbol_4 ? weighting_4 : 0) + 
                      (symbol_5 ? weighting_5 : 0) + (symbol_6 ? weighting_6 : 0) + 
                      (symbol_7 ? weighting_7 : 0) + (symbol_8 ? weighting_8 : 0) + 
                      (symbol_9 ? weighting_9 : 0) + (symbol_10 ? weighting_10 : 0)

final_index = total_active_weight > 0 ? weighted_price / total_active_weight : 0

// 💡 NEW LABELS: Print final_index values for the first and last bar
// First Bar Label (Left Edge)
//if is_first_candle
 //   label.new(bar_index, low, text="First final_index: " + str.tostring(final_index, "#.##"), color=color.blue, textcolor=color.white, style=label.style_label_up, size=size.small)

// Last Bar Label (Right Edge)
//if barstate.islast
//    label.new(bar_index, low, text="Last final_index: " + ":"+  str.tostring(close[0], "#.##")+":"+ str.tostring(final_index, "#.##"), color=color.green, textcolor=color.white, style=label.style_label_left, size=size.small)


// 💡 4. THE NEW MAGIC STEP: Calculate mSymbol on the first bar and scale the line
var float mSymbol = na
if is_first_candle and final_index > 0 and base_chart > 0
    mSymbol := final_index / base_chart

// Pulling static scaling factor forward in time
mSymbol := ta.valuewhen(not na(mSymbol), mSymbol, 0)

// Divide the final index by the factor to align it with the main symbol
aligned_index = (nz(mSymbol) > 0) ? final_index / mSymbol : final_index
//aligned_index = final_index

// 💡 4. THE MAGIC STEP: Ignore plotting for invisible bars
// If the bar's time is before the leftmost visible bar, output 'na' to hide the line.
plot_value = (time >= chart.left_visible_bar_time) ? aligned_index : na

// Anchor Marker
plotshape(is_first_candle, title="Index Anchor Point", style=shape.triangleup, location=location.bottom, color=color.blue, size=size.small)

// Render line
plot(aligned_index, title="Rescaled Index Plot", linewidth=3, color=color.blue)


//if is_first_candle
//    label.new(bar_index, low, text=index_name + " Val: " + str.tostring(close[0], "#.##")  + ":" +  str.tostring(final_index, "#.##") + ":" + str.tostring(aligned_index, "#.##"), color=color.blue, textcolor=color.white, style=label.style_label_left)

// UI label
//if barstate.islast
//    label.new(bar_index, aligned_index, text=index_name + " Val: " + ":" +  str.tostring(final_index, "#.##") + ":" + str.tostring(aligned_index, "#.##"), color=color.blue, textcolor=color.white, style=label.style_label_left)

// Debug Table
var tableId = table.new(position.bottom_left, 2, 11, border_width=1, frame_color=color.gray, frame_width=1)

if show_table and barstate.islast
    table.cell(tableId, 0, 0, text="Symbol", text_color=color.white, bgcolor=color.blue)
    table.cell(tableId, 1, 0, text="Live Price", text_color=color.white, bgcolor=color.blue)
    
    if symbol_1
        table.cell(tableId, 0, 1, text=ticker_1, text_color=color.white, bgcolor=color.black)
        table.cell(tableId, 1, 1, text=str.tostring(s1, "#.##"), text_color=color.white, bgcolor=color.black)
    if symbol_2
        table.cell(tableId, 0, 2, text=ticker_2, text_color=color.white, bgcolor=color.black)
        table.cell(tableId, 1, 2, text=str.tostring(s2, "#.##"), text_color=color.white, bgcolor=color.black)
    if symbol_3
        table.cell(tableId, 0, 3, text=ticker_3, text_color=color.white, bgcolor=color.black)
        table.cell(tableId, 1, 3, text=str.tostring(s3, "#.##"), text_color=color.white, bgcolor=color.black)
    if symbol_4
        table.cell(tableId, 0, 4, text=ticker_4, text_color=color.white, bgcolor=color.black)
        table.cell(tableId, 1, 4, text=str.tostring(s4, "#.##"), text_color=color.white, bgcolor=color.black)
    if symbol_5
        table.cell(tableId, 0, 5, text=ticker_5, text_color=color.white, bgcolor=color.black)
        table.cell(tableId, 1, 5, text=str.tostring(s5, "#.##"), text_color=color.white, bgcolor=color.black)
    if symbol_6
        table.cell(tableId, 0, 6, text=ticker_6, text_color=color.white, bgcolor=color.black)
        table.cell(tableId, 1, 6, text=str.tostring(s6, "#.##"), text_color=color.white, bgcolor=color.black)
    if symbol_7
        table.cell(tableId, 0, 7, text=ticker_7, text_color=color.white, bgcolor=color.black)
        table.cell(tableId, 1, 7, text=str.tostring(s7, "#.##"), text_color=color.white, bgcolor=color.black)
    if symbol_8
        table.cell(tableId, 0, 8, text=ticker_8, text_color=color.white, bgcolor=color.black)
        table.cell(tableId, 1, 8, text=str.tostring(s8, "#.##"), text_color=color.white, bgcolor=color.black)
    if symbol_9
        table.cell(tableId, 0, 9, text=ticker_9, text_color=color.white, bgcolor=color.black)
        table.cell(tableId, 1, 9, text=str.tostring(s9, "#.##"), text_color=color.white, bgcolor=color.black)
    if symbol_10
        table.cell(tableId, 0, 10, text=ticker_10, text_color=color.white, bgcolor=color.black)
        table.cell(tableId, 1, 10, text=str.tostring(s10, "#.##"), text_color=color.white, bgcolor=color.black)
````
