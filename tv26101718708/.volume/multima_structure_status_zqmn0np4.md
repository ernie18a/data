# Multi-MA Structure Status

- url: https://www.tradingview.com/script/ZQMn0np4-Multi-MA-Structure-Status/
- type: indicator
- pine_id: PUB;0497735a46c044398cdb7b9ebeacd83e
- version: 4.0

## Description

Just a simple table that shows the current price your chosen moving averages are at, fully customizable, option to plot MAs on chart if you want.

## Source Code

````pine
//@version=6
indicator("Multi-MA Table", overlay=true, max_bars_back=500)

// ====================== INPUTS ======================
group_ma = "Moving Averages"

len1 = input.int(9,  "MA 1 Length", minval=1, group=group_ma)
type1 = input.string("EMA", "MA 1 Type", options=["EMA","SMA","WMA","HMA","VWMA","RMA"], group=group_ma)
en1  = input.bool(true, "Enable MA 1", group=group_ma)

len2 = input.int(21, "MA 2 Length", minval=1, group=group_ma)
type2 = input.string("EMA", "MA 2 Type", options=["EMA","SMA","WMA","HMA","VWMA","RMA"], group=group_ma)
en2  = input.bool(true, "Enable MA 2", group=group_ma)

len3 = input.int(50, "MA 3 Length", minval=1, group=group_ma)
type3 = input.string("EMA", "MA 3 Type", options=["EMA","SMA","WMA","HMA","VWMA","RMA"], group=group_ma)
en3  = input.bool(true, "Enable MA 3", group=group_ma)

len4 = input.int(100,"MA 4 Length", minval=1, group=group_ma)
type4 = input.string("EMA", "MA 4 Type", options=["EMA","SMA","WMA","HMA","VWMA","RMA"], group=group_ma)
en4  = input.bool(true, "Enable MA 4", group=group_ma)

len5 = input.int(200,"MA 5 Length", minval=1, group=group_ma)
type5 = input.string("EMA", "MA 5 Type", options=["EMA","SMA","WMA","HMA","VWMA","RMA"], group=group_ma)
en5  = input.bool(true, "Enable MA 5", group=group_ma)

group_disp = "Display"
plot_mas   = input.bool(true, "Plot MAs on chart?", group=group_disp)
table_pos  = input.string("top_right", "Table Position", options=["top_right","top_left","bottom_right","bottom_left"], group=group_disp)

// ====================== COLORS ======================
c1 = color.new(#00BCD4, 0)   // Cyan
c2 = color.new(#9C27B0, 0)   // Purple
c3 = color.new(#4CAF50, 0)   // Green
c4 = color.new(#FFEB3B, 0)   // Yellow
c5 = color.new(#90A4AE, 0)   // Grey

// ====================== MA FUNCTION ======================
f_ma(src, len, type) =>
    switch type
        "EMA"  => ta.ema(src, len)
        "SMA"  => ta.sma(src, len)
        "WMA"  => ta.wma(src, len)
        "HMA"  => ta.hma(src, len)
        "VWMA" => ta.vwma(src, len)
        "RMA"  => ta.rma(src, len)
        => ta.ema(src, len)

// ====================== CALCULATIONS ======================
ma1 = f_ma(close, len1, type1)
ma2 = f_ma(close, len2, type2)
ma3 = f_ma(close, len3, type3)
ma4 = f_ma(close, len4, type4)
ma5 = f_ma(close, len5, type5)

above1 = en1 and close > ma1
above2 = en2 and close > ma2
above3 = en3 and close > ma3
above4 = en4 and close > ma4
above5 = en5 and close > ma5

// Always use "Above ALL enabled MAs" logic now (simplified)
bullish = (en1 ? above1 : true) and 
          (en2 ? above2 : true) and 
          (en3 ? above3 : true) and 
          (en4 ? above4 : true) and 
          (en5 ? above5 : true)

var int days_above = 0
if bullish
    days_above += 1
else
    days_above := 0

pct1 = (en1 and not na(ma1)) ? (close - ma1) / ma1 * 100 : na
pct2 = (en2 and not na(ma2)) ? (close - ma2) / ma2 * 100 : na
pct3 = (en3 and not na(ma3)) ? (close - ma3) / ma3 * 100 : na
pct4 = (en4 and not na(ma4)) ? (close - ma4) / ma4 * 100 : na
pct5 = (en5 and not na(ma5)) ? (close - ma5) / ma5 * 100 : na

// ====================== TABLE ======================
var table t = table.new(table_pos, 2, 7, bgcolor=color.new(color.black, 82), border_width=1, border_color=color.gray)

if barstate.islast
    table.cell(t, 0, 0, "Structure Status  •  " + syminfo.ticker, 
         text_color=color.white, bgcolor=color.rgb(55,71,79), text_size=size.normal)
    table.merge_cells(t, 0, 0, 1, 0)
    
    d_bg = days_above > 0 ? color.new(#00C853, 0) : color.new(#FF5252, 0)
    table.cell(t, 0, 1, "Days Above", text_color=color.white, bgcolor=d_bg, text_size=size.normal)
    table.cell(t, 1, 1, str.tostring(days_above), text_color=color.white, bgcolor=d_bg, text_size=size.large)
    
    if en1
        bg1 = above1 ? color.new(#4CAF50, 68) : color.new(#EF5350, 68)
        table.cell(t, 0, 2, str.tostring(len1) + " " + type1, text_color=color.white, bgcolor=bg1)
        table.cell(t, 1, 2, str.tostring(ma1, format.mintick) + " (" + str.tostring(pct1, "+0.00") + "%)", text_color=color.white, bgcolor=bg1)
    else
        table.cell(t, 0, 2, str.tostring(len1) + " " + type1 + " (disabled)", text_color=color.gray, bgcolor=color.new(color.black, 0))
        table.cell(t, 1, 2, "—", text_color=color.gray, bgcolor=color.new(color.black, 0))
    
    if en2
        bg2 = above2 ? color.new(#4CAF50, 68) : color.new(#EF5350, 68)
        table.cell(t, 0, 3, str.tostring(len2) + " " + type2, text_color=color.white, bgcolor=bg2)
        table.cell(t, 1, 3, str.tostring(ma2, format.mintick) + " (" + str.tostring(pct2, "+0.00") + "%)", text_color=color.white, bgcolor=bg2)
    else
        table.cell(t, 0, 3, str.tostring(len2) + " " + type2 + " (disabled)", text_color=color.gray, bgcolor=color.new(color.black, 0))
        table.cell(t, 1, 3, "—", text_color=color.gray, bgcolor=color.new(color.black, 0))
    
    if en3
        bg3 = above3 ? color.new(#4CAF50, 68) : color.new(#EF5350, 68)
        table.cell(t, 0, 4, str.tostring(len3) + " " + type3, text_color=color.white, bgcolor=bg3)
        table.cell(t, 1, 4, str.tostring(ma3, format.mintick) + " (" + str.tostring(pct3, "+0.00") + "%)", text_color=color.white, bgcolor=bg3)
    else
        table.cell(t, 0, 4, str.tostring(len3) + " " + type3 + " (disabled)", text_color=color.gray, bgcolor=color.new(color.black, 0))
        table.cell(t, 1, 4, "—", text_color=color.gray, bgcolor=color.new(color.black, 0))
    
    if en4
        bg4 = above4 ? color.new(#4CAF50, 68) : color.new(#EF5350, 68)
        table.cell(t, 0, 5, str.tostring(len4) + " " + type4, text_color=color.white, bgcolor=bg4)
        table.cell(t, 1, 5, str.tostring(ma4, format.mintick) + " (" + str.tostring(pct4, "+0.00") + "%)", text_color=color.white, bgcolor=bg4)
    else
        table.cell(t, 0, 5, str.tostring(len4) + " " + type4 + " (disabled)", text_color=color.gray, bgcolor=color.new(color.black, 0))
        table.cell(t, 1, 5, "—", text_color=color.gray, bgcolor=color.new(color.black, 0))
    
    if en5
        bg5 = above5 ? color.new(#4CAF50, 68) : color.new(#EF5350, 68)
        table.cell(t, 0, 6, str.tostring(len5) + " " + type5, text_color=color.white, bgcolor=bg5)
        table.cell(t, 1, 6, str.tostring(ma5, format.mintick) + " (" + str.tostring(pct5, "+0.00") + "%)", text_color=color.white, bgcolor=bg5)
    else
        table.cell(t, 0, 6, str.tostring(len5) + " " + type5 + " (disabled)", text_color=color.gray, bgcolor=color.new(color.black, 0))
        table.cell(t, 1, 6, "—", text_color=color.gray, bgcolor=color.new(color.black, 0))

// ====================== PLOTTING ======================
plot_enabled = plot_mas

c1_plot = above1 ? c1 : color.new(c1, 55)
plot(ma1, "MA1", color=c1_plot, linewidth=1,
     display = (en1 and plot_enabled) ? display.all : display.none)

c2_plot = above2 ? c2 : color.new(c2, 55)
plot(ma2, "MA2", color=c2_plot, linewidth=1,
     display = (en2 and plot_enabled) ? display.all : display.none)

c3_plot = above3 ? c3 : color.new(c3, 55)
plot(ma3, "MA3", color=c3_plot, linewidth=1,
     display = (en3 and plot_enabled) ? display.all : display.none)

c4_plot = above4 ? c4 : color.new(c4, 55)
plot(ma4, "MA4", color=c4_plot, linewidth=1,
     display = (en4 and plot_enabled) ? display.all : display.none)

c5_plot = above5 ? c5 : color.new(c5, 55)
plot(ma5, "MA5", color=c5_plot, linewidth=1,
     display = (en5 and plot_enabled) ? display.all : display.none)
````
