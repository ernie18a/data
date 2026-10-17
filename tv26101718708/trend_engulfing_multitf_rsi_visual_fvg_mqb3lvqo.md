# Trend Engulfing + Multi-TF RSI + Visual FVG

- url: https://www.tradingview.com/script/mqB3Lvqo-Trend-Engulfing-Multi-TF-RSI-Visual-FVG/
- type: indicator
- pine_id: PUB;1d582f5734c34b59ab6b7800fb2d344a
- version: 1.0

## Description

Trade using Bullish and Bearish Engulfing follow market trend with BUY/SELL signals, together with RSI and Trend Dashboard.

## Source Code

````pine
//@version=5
indicator("Trend Engulfing + Multi-TF RSI + Visual FVG", overlay=true, max_labels_count=500, max_boxes_count=500)

// ==========================================
// 1. INPUTS & STRATEGY CONFIG
// ==========================================
emaLength = input.int(200, title="H1 Major Trend EMA Length")
rsiLength = input.int(14, title="Dashboard RSI Length")
showFVG   = input.bool(true, title="Display Visual FVGs?")

// ==========================================
// 2. CORE STRATEGY (Engulfing + H1 Filter)
// ==========================================
h1_close = request.security(syminfo.tickerid, "60", close, barmerge.gaps_off, barmerge.lookahead_off)
h1_ema   = request.security(syminfo.tickerid, "60", ta.ema(close, emaLength), barmerge.gaps_off, barmerge.lookahead_off)

is_bullish_trend = h1_close > h1_ema
is_bearish_trend = h1_close < h1_ema

// Engulfing Logic
is_bullish_engulfing = close[1] < open[1] and close > open and close >= open[1] and open <= close[1]
is_bearish_engulfing = close[1] > open[1] and close < open and close <= open[1] and open >= close[1]

buy_signal  = is_bullish_engulfing and is_bullish_trend
sell_signal = is_bearish_engulfing and is_bearish_trend

// Plot Strategy Signals
if buy_signal
    label.new(bar_index, low, text="BUY", color=color.green, textcolor=color.white, style=label.style_label_up, yloc=yloc.belowbar)

if sell_signal
    label.new(bar_index, high, text="SELL", color=color.red, textcolor=color.white, style=label.style_label_down, yloc=yloc.abovebar)

// ==========================================
// 3. VISUAL FAIR VALUE GAP (FVG) ENGINE
// ==========================================
var box[] activeBullishBoxes = array.new_box()
var box[] activeBearishBoxes = array.new_box()

if showFVG
    // FVG Detection Mechanics (3-candle spatial validation)
    isBullishFVG = low > high[2] and close[1] > high[2]
    isBearishFVG = high < low[2] and close[1] < low[2]

    if isBullishFVG
        newBox = box.new(left=bar_index[2], top=low, right=bar_index, bottom=high[2], 
                         bgcolor=color.new(color.green, 93), border_color=color.new(color.green, 75), border_style=line.style_dashed)
        array.push(activeBullishBoxes, newBox)
        
    if isBearishFVG
        newBox = box.new(left=bar_index[2], top=low[2], right=bar_index, bottom=high, 
                         bgcolor=color.new(color.red, 93), border_color=color.new(color.red, 75), border_style=line.style_dashed)
        array.push(activeBearishBoxes, newBox)

    // Dynamic FVG Box Cleanup Engine (Deletes boxes once price completely fills them)
    if array.size(activeBullishBoxes) > 0
        for i = array.size(activeBullishBoxes) - 1 to 0 by 1
            currentBox = array.get(activeBullishBoxes, i)
            if low <= box.get_bottom(currentBox)
                box.delete(currentBox)
                array.remove(activeBullishBoxes, i)
            else
                box.set_right(currentBox, bar_index)

    if array.size(activeBearishBoxes) > 0
        for i = array.size(activeBearishBoxes) - 1 to 0 by 1
            currentBox = array.get(activeBearishBoxes, i)
            if high >= box.get_top(currentBox)
                box.delete(currentBox)
                array.remove(activeBearishBoxes, i)
            else
                box.set_right(currentBox, bar_index)

// ==========================================
// 4. MULTI-TIMEFRAME RSI DATA FETCHING
// ==========================================
baseRsi = ta.rsi(close, rsiLength)

rsi_m5  = request.security(syminfo.tickerid, "5",   baseRsi, barmerge.gaps_off, barmerge.lookahead_off)
rsi_m15 = request.security(syminfo.tickerid, "15",  baseRsi, barmerge.gaps_off, barmerge.lookahead_off)
rsi_m30 = request.security(syminfo.tickerid, "30",  baseRsi, barmerge.gaps_off, barmerge.lookahead_off)
rsi_h1  = request.security(syminfo.tickerid, "60",  baseRsi, barmerge.gaps_off, barmerge.lookahead_off)
rsi_h4  = request.security(syminfo.tickerid, "240", baseRsi, barmerge.gaps_off, barmerge.lookahead_off)
rsi_d1  = request.security(syminfo.tickerid, "D",   baseRsi, barmerge.gaps_off, barmerge.lookahead_off)

f_rsi_color(rsi_val) => rsi_val > 50 ? color.rgb(38, 166, 154) : color.rgb(239, 83, 80)
f_rsi_text(rsi_val)  => rsi_val > 50 ? "BULL" : "BEAR"

// ==========================================
// 5. CREATING THE DASHBOARD
// ==========================================
var table tfTable = table.new(position.top_right, columns=3, rows=7, bgcolor=color.new(color.black, 20), border_width=1, border_color=color.gray)

if barstate.islast
    // Header Row
    table.cell(tfTable, 0, 0, "TF",     text_color=color.white, text_size=size.small, bgcolor=color.gray)
    table.cell(tfTable, 1, 0, "RSI",    text_color=color.white, text_size=size.small, bgcolor=color.gray)
    table.cell(tfTable, 2, 0, "Trend",  text_color=color.white, text_size=size.small, bgcolor=color.gray)
    
    // Row 1: M5
    table.cell(tfTable, 0, 1, "M5", text_color=color.white, text_size=size.small)
    table.cell(tfTable, 1, 1, str.tostring(rsi_m5, "0.0"), text_color=color.white, text_size=size.small)
    table.cell(tfTable, 2, 1, f_rsi_text(rsi_m5), text_color=color.white, bgcolor=f_rsi_color(rsi_m5), text_size=size.small)
    
    // Row 2: M15
    table.cell(tfTable, 0, 2, "M15", text_color=color.white, text_size=size.small)
    table.cell(tfTable, 1, 2, str.tostring(rsi_m15, "0.0"), text_color=color.white, text_size=size.small)
    table.cell(tfTable, 2, 2, f_rsi_text(rsi_m15), text_color=color.white, bgcolor=f_rsi_color(rsi_m15), text_size=size.small)
    
    // Row 3: M30
    table.cell(tfTable, 0, 3, "M30", text_color=color.white, text_size=size.small)
    table.cell(tfTable, 1, 3, str.tostring(rsi_m30, "0.0"), text_color=color.white, text_size=size.small)
    table.cell(tfTable, 2, 3, f_rsi_text(rsi_m30), text_color=color.white, bgcolor=f_rsi_color(rsi_m30), text_size=size.small)
    
    // Row 4: H1
    table.cell(tfTable, 0, 4, "H1", text_color=color.white, text_size=size.small)
    table.cell(tfTable, 1, 4, str.tostring(rsi_h1, "0.0"), text_color=color.white, text_size=size.small)
    table.cell(tfTable, 2, 4, f_rsi_text(rsi_h1), text_color=color.white, bgcolor=f_rsi_color(rsi_h1), text_size=size.small)
    
    // Row 5: H4
    table.cell(tfTable, 0, 5, "H4", text_color=color.white, text_size=size.small)
    table.cell(tfTable, 1, 5, str.tostring(rsi_h4, "0.0"), text_color=color.white, text_size=size.small)
    table.cell(tfTable, 2, 5, f_rsi_text(rsi_h4), text_color=color.white, bgcolor=f_rsi_color(rsi_h4), text_size=size.small)
    
    // Row 6: D1
    table.cell(tfTable, 0, 6, "D1", text_color=color.white, text_size=size.small)
    table.cell(tfTable, 1, 6, str.tostring(rsi_d1, "0.0"), text_color=color.white, text_size=size.small)
    table.cell(tfTable, 2, 6, f_rsi_text(rsi_d1), text_color=color.white, bgcolor=f_rsi_color(rsi_d1), text_size=size.small)

// ==========================================
// 6. ALERTS CONFIGURATION
// ==========================================
alertcondition(buy_signal,  title="Trend Engulfing BUY",  message="[Indicator Alert] Trend-Aligned Bullish Engulfing Pattern Formed! Check structure.")
alertcondition(sell_signal, title="Trend Engulfing SELL", message="[Indicator Alert] Trend-Aligned Bearish Engulfing Pattern Formed! Check structure.")
````
