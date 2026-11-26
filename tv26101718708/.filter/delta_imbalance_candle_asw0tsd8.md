# delta imbalance candle 

- url: https://www.tradingview.com/script/AsW0tSd8-delta-imbalance-candle/
- type: indicator
- pine_id: PUB;9fed78325c1b4e0082d6ed88d32a33b8
- version: 1.0

## Description

What this code does:
​Auto-Detects Chart: It automatically identifies the symbol you are currently viewing (e.g., Nifty or BankNifty) using syminfo.tickerid. No more manual typing.
​Analyzes "Inside" the Candle: It breaks a 15-minute candle into 1-minute slices. It calculates how much volume was Buying (Green 1-min bars) vs. Selling (Red 1-min bars).
​Spots Big Players: If Buying volume is 3x larger than Selling (or vice versa), it signals an Institutional Imbalance.
​Visual Alerts: It changes the Bar Color to Neon Green/Red and shows a Live Table with the exact Buy/Sell volume totals.

## Source Code

````pine
//@version=5
indicator("Auto-Ticker Delta Imbalance [Table]", overlay=true)

// --- Inputs ---
int imb_ratio = input.int(3, "Imbalance Ratio", minval=1)
color bullColor = input.color(#00ffbb, "Institutional Buy Color")
color bearColor = input.color(#ff1100, "Institutional Sell Color")
string tablePos = input.string("Top Right", "Table Position", options=["Top Right", "Bottom Right", "Top Left", "Bottom Left"])

// --- Dynamic Data Fetching (Automatic) ---
// Yahan ticker_input ki jagah syminfo.tickerid use kiya hai jo current chart uthayega
[it_vol, it_c, it_o] = request.security_lower_tf(syminfo.tickerid, "1", [volume, close, open])

float b_vol = 0.0
float s_vol = 0.0

if array.size(it_vol) > 0
    for i = 0 to array.size(it_vol) - 1
        v = array.get(it_vol, i)
        c = array.get(it_c, i)
        o = array.get(it_o, i)
        
        if c > o
            b_vol += v
        else if c < o
            s_vol += v
        else
            b_vol += v * 0.5
            s_vol += v * 0.5

// --- Logic for Imbalance ---
bool strong_buy = b_vol > (s_vol * imb_ratio)
bool strong_sell = s_vol > (b_vol * imb_ratio)

// --- Dynamic Bar Coloring ---
color final_bar_col = strong_buy ? bullColor : strong_sell ? bearColor : na
barcolor(final_bar_col, title="Imbalance Color Override")

// --- Dashboard Table ---
var pos = tablePos == "Top Right" ? position.top_right : tablePos == "Bottom Right" ? position.bottom_right : tablePos == "Top Left" ? position.top_left : position.bottom_left
var table dash = table.new(pos, 2, 4, bgcolor=color.new(color.black, 70), border_width=1, border_color=color.gray)

if barstate.islast
    // Header - Symbol Name
    table.cell(dash, 0, 0, "SYMBOL:", text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 0, syminfo.ticker, text_color=color.yellow, text_size=size.small)
    
    // Buying Volume
    table.cell(dash, 0, 1, "BUY VOL:", text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 1, str.tostring(b_vol, format.volume), text_color=bullColor, text_size=size.small)
    
    // Selling Volume
    table.cell(dash, 0, 2, "SELL VOL:", text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 2, str.tostring(s_vol, format.volume), text_color=bearColor, text_size=size.small)
    
    // Status
    string status = strong_buy ? "BULLISH IMB" : strong_sell ? "BEARISH IMB" : "NORMAL"
    color statusCol = strong_buy ? bullColor : strong_sell ? bearColor : color.gray
    table.cell(dash, 0, 3, "STATUS:", text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 3, status, text_color=statusCol, text_size=size.small)
````
