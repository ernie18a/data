# Trucker Macro HUD: Fear vs Greed

- url: https://www.tradingview.com/script/2fIYISTA-Trucker-Macro-HUD-Fear-vs-Greed/
- type: indicator
- pine_id: PUB;6812c492d69f422f9fc99b92dd17569f
- version: 1.0

## Description

This script uses the VIX and DXY to build a fear and greed gauge for SPY. High VIX paired with a strong dollar signals fear and potential downside pressure, while falling VIX and a weaker dollar points to greed and bullish conditions. A clean table displays the current market state — fearful, greedy, bullish, or bearish — making sentiment easy to read at a glance. Great for spotting extremes and timing SPY moves.

## Source Code

````pine
//@version=6
indicator("Trucker Macro HUD: Fear vs Greed", overlay=true)

// 1. Inputs
emaLength = input.int(20, title="Trend EMA Length")

// 2. Fetch Data (DXY, VIX, SPY)
dxy_close = request.security("TVC:DXY", timeframe.period, close)
dxy_ema   = ta.ema(dxy_close, emaLength)

vix_close = request.security("TVC:VIX", timeframe.period, close)
vix_ema   = ta.ema(vix_close, emaLength)

spy_close = request.security("AMEX:SPY", timeframe.period, close)
spy_ema   = ta.ema(spy_close, emaLength)

// 3. Determine Trends (Is price above or below the 20 EMA?)
dxy_up = dxy_close > dxy_ema
vix_up = vix_close > vix_ema
spy_up = spy_close > spy_ema

// 4. Define Market Sentiment Logic
// FEAR: Dollar UP, VIX UP, SPY DOWN
is_fear  = dxy_up and vix_up and not spy_up

// GREED: Dollar DOWN, VIX DOWN, SPY UP
is_greed = not dxy_up and not vix_up and spy_up

// 5. Paint the Chart Background (Optional, keeps the visual bands)
bgcolor(is_greed ? color.new(color.green, 85) : na, title="Greed Background")
bgcolor(is_fear ? color.new(color.red, 85) : na, title="Fear Background")

// 6. Draw the Macro Dashboard Table
var macroTable = table.new(position.top_right, 2, 5, border_width = 2, border_color = color.new(color.gray, 50), frame_color = color.black, frame_width = 2)

if barstate.islast
    // Row 0: Headers
    table.cell(macroTable, 0, 0, "ASSET", text_color=color.white, bgcolor=color.new(color.blue, 30), text_halign=text.align_left)
    table.cell(macroTable, 1, 0, "TREND", text_color=color.white, bgcolor=color.new(color.blue, 30), text_halign=text.align_center)
    
    // Row 1: DXY
    table.cell(macroTable, 0, 1, "DXY (Dollar)", text_color=color.white, bgcolor=color.new(color.black, 20), text_halign=text.align_left)
    table.cell(macroTable, 1, 1, dxy_up ? "UP 📈" : "DOWN 📉", text_color=color.white, bgcolor=dxy_up ? color.new(color.red, 30) : color.new(color.green, 30)) 
    
    // Row 2: VIX
    table.cell(macroTable, 0, 2, "VIX (Volatility)", text_color=color.white, bgcolor=color.new(color.black, 20), text_halign=text.align_left)
    table.cell(macroTable, 1, 2, vix_up ? "UP 📈" : "DOWN 📉", text_color=color.white, bgcolor=vix_up ? color.new(color.red, 30) : color.new(color.green, 30))
    
    // Row 3: SPY
    table.cell(macroTable, 0, 3, "SPY (S&P 500)", text_color=color.white, bgcolor=color.new(color.black, 20), text_halign=text.align_left)
    table.cell(macroTable, 1, 3, spy_up ? "UP 📈" : "DOWN 📉", text_color=color.white, bgcolor=spy_up ? color.new(color.green, 30) : color.new(color.red, 30))
    
    // Row 4: The Final Indicator (Fear vs Greed)
    sentiment_text = is_fear ? "🚨 FEAR (BEARISH)" : is_greed ? "🟢 GREED (BULLISH)" : "🟡 MIXED (CHOP)"
    sentiment_color = is_fear ? color.new(color.red, 10) : is_greed ? color.new(color.green, 10) : color.new(color.gray, 30)
    
    table.cell(macroTable, 0, 4, "MARKET STATUS", text_color=color.white, bgcolor=color.new(color.black, 0), text_halign=text.align_left)
    table.cell(macroTable, 1, 4, sentiment_text, text_color=color.white, bgcolor=sentiment_color, text_halign=text.align_center)
````
