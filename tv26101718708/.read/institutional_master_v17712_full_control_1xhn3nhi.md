# Institutional Master V17.7.12 - Full Control

- url: https://www.tradingview.com/script/1XHn3nHI/
- type: indicator
- pine_id: PUB;6fc7405fd7524d4b9f97bdebfdc3351f
- version: 1.0

## Description

The Institutional Master V17.7.12 Full Control is a sophisticated trading system primarily designed to identify and visualize the activities of major market participants (institutions).

Here are the key features of this system:

Identification of Smart Money: The indicator analyzes price and volume data to uncover accumulation and distribution phases executed by banks and institutions.

Full Control Interface: This version enables granular control over all parameters, allowing users to adjust sensitivity to suit various market conditions and asset classes.

Trend Validation: The system acts as a filter to ensure that trades are executed exclusively in alignment with the direction of dominant institutional capital flows.

Volume Analysis: A core component involves the evaluation of volume clusters to gauge the sustainability of a trend or the likelihood of a trend reversal.

Precision Entries: By combining price action with institutional flow data, the model aims to generate entry points with a high risk-reward ratio.

Stability and Reliability: Version V17.7.12 is considered one of the most stable iterations of the system, having been specifically optimized to minimize false signals during periods of high volatility.

## Source Code

````pine
//@version=5
indicator("Institutional Master V17.7.12 - Full Control", overlay=true, max_labels_count=500)

// --- 1. INPUTS ---
lb = input.int(50, "Lookback (Periode)")
vol_m = input.float(1.4, "Volumen-Schranke") 
rsi_len = input.int(9, "RSI Periode")
use_h1_filter = input.bool(true, "H1-Trend Filter aktivieren?", tooltip="Anschalten: Signale nur im Einklang mit dem 1-Stunden-Trend.")

// --- 2. TREND & FIB-LOGIK ---
sma200 = ta.sma(close, 200)

// H1-Trend Abfrage für Filter
h1_sma = request.security(syminfo.tickerid, "60", ta.sma(close, 200))
h1_close = request.security(syminfo.tickerid, "60", close)
h1_bullish = h1_close > h1_sma
h1_bearish = h1_close < h1_sma

hi = ta.highest(high, lb)
lo = ta.lowest(low, lb)
is_uptrend = close > sma200

f_level = is_uptrend ? lo + ((hi - lo) * 0.618) : hi - ((hi - lo) * 0.618)
target_up   = lo + ((hi - lo) * 1.618)
target_down = hi - ((hi - lo) * 1.618)
main_target = is_uptrend ? target_up : target_down

// --- 3. VOLUME POC & RSI ---
var float poc_price = na
float max_vol = 0.0
for i = 0 to lb - 1
    if volume[i] > max_vol
        max_vol := volume[i]
        poc_price := close[i]

rsi = ta.rsi(close, rsi_len)
poc_dist = ((close - poc_price) / poc_price) * 100

// --- 4. ABSORPTION LOGIK ---
vol_spike = volume > ta.sma(volume, 20) * vol_m

// BUY Signal mit Schalter
buy_base = is_uptrend and low <= f_level * 1.0015 and close > open
buy_final = use_h1_filter ? (buy_base and h1_bullish) : buy_base

// SELL Signal mit Schalter
sell_base = not is_uptrend and high >= f_level * 0.9985 and close < open
sell_final = use_h1_filter ? (sell_base and h1_bearish) : sell_base

// --- 5. VISUALS ---
plot(sma200, "SMA 200", color=color.new(color.white, 40), linewidth=2)
plot(f_level, "Fib 0.618", color=is_uptrend ? color.new(#FFD700, 20) : color.new(color.red, 20), linewidth=2)
plot(poc_price, "Volume POC", color=color.new(#00E6FF, 30), linewidth=2, style=plot.style_linebr)

if buy_final and vol_spike
    label.new(bar_index, low, "PRO BUY\\nRSI: " + str.tostring(math.round(rsi, 1)), color=color.green, textcolor=color.white, style=label.style_label_up, size=size.small)

if sell_final and vol_spike
    label.new(bar_index, high, "PRO SELL\\nRSI: " + str.tostring(math.round(rsi, 1)), color=color.red, textcolor=color.white, style=label.style_label_down, size=size.small)

if barstate.islast
    label.new(bar_index + 2, target_up, "Ziel Up: " + str.tostring(math.round(target_up, 2)), color=color.lime, style=label.style_label_left)
    label.new(bar_index + 2, target_down, "Ziel Down: " + str.tostring(math.round(target_down, 2)), color=color.fuchsia, textcolor=color.white, style=label.style_label_left)

// --- 6. DASHBOARD (ERWEITERT) ---
t15m = request.security(syminfo.tickerid, "15",  close > ta.sma(close, 200))
t4h  = request.security(syminfo.tickerid, "240", close > ta.sma(close, 200))
t1d  = request.security(syminfo.tickerid, "D",   close > ta.sma(close, 200))

var table board = table.new(position.bottom_right, 2, 12, frame_width=1, border_width=1)
if barstate.islast
    table.cell(board, 0, 0, "Timeframe", bgcolor=color.black, text_color=color.white), table.cell(board, 1, 0, "Trend", bgcolor=color.black, text_color=color.white)
    table.cell(board, 0, 1, "15m", bgcolor=color.gray, text_color=color.white), table.cell(board, 1, 1, t15m ? "BULL" : "BEAR", bgcolor=t15m ? color.green : color.red)
    table.cell(board, 0, 2, "1h", bgcolor=color.gray, text_color=color.white),  table.cell(board, 1, 2, h1_bullish ? "BULL" : "BEAR", bgcolor=h1_bullish ? color.green : color.red)
    table.cell(board, 0, 3, "4h", bgcolor=color.gray, text_color=color.white),  table.cell(board, 1, 3, t4h ? "BULL" : "BEAR", bgcolor=t4h ? color.green : color.red)
    table.cell(board, 0, 4, "1d", bgcolor=color.gray, text_color=color.white),  table.cell(board, 1, 4, t1d ? "BULL" : "BEAR", bgcolor=t1d ? color.green : color.red)
    table.cell(board, 0, 5, "HAUPTZIEL", bgcolor=#FFD700, text_color=color.black), table.cell(board, 1, 5, str.tostring(math.round(main_target, 2)), bgcolor=#FFD700, text_color=color.black)
    table.cell(board, 0, 6, "POC Dist %", bgcolor=#00E6FF, text_color=color.black), table.cell(board, 1, 6, str.tostring(math.round(poc_dist, 2)) + "%", bgcolor=color.white, text_color=color.black)
    table.cell(board, 0, 7, "RSI (9)", bgcolor=color.black, text_color=color.white), table.cell(board, 1, 7, str.tostring(math.round(rsi, 1)), bgcolor=rsi < 40 ? color.green : rsi > 60 ? color.red : color.gray)
    table.cell(board, 0, 8, "H1-Filter", bgcolor=color.black, text_color=color.white), table.cell(board, 1, 8, use_h1_filter ? "AKTIV" : "AUS", bgcolor=use_h1_filter ? color.blue : color.gray)
````
