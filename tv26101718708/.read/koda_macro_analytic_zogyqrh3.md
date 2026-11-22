# Koda Macro Analytic

- url: https://www.tradingview.com/script/zogyqrH3-Koda-Macro-Analytic/
- type: indicator
- pine_id: PUB;a72533e338f44ec0a447a0486f729dfb
- version: 1.0

## Description

Koda Macro Analytic 

Why the 10-Year Real Yield Controls Gold
The 10-year Real Yield (specifically the 10Y TIPS) is widely considered the "North Star" for Gold pricing because of the Opportunity Cost of capital. Unlike stocks or bonds, Gold is a non-yielding asset—it doesn't pay a dividend, and it doesn't pay interest. It is simply a store of value.

1. The Interest Rate Rivalry
When 10-year Real Yields rise, investors can get a "guaranteed" return from the government that outpaces inflation. In this scenario, holding Gold becomes "expensive" because you are giving up that guaranteed yield. This leads big institutions to sell Gold and buy Bonds, driving Gold prices down.

2. The Inflation Hedge
Conversely, when Real Yields fall (or turn negative), the "safety" of bonds disappears. If the government is paying 2% but inflation is at 4%, investors are effectively losing money in "safe" paper. They flee to Gold to protect their purchasing power. Because the 10-year yield reflects the market's long-term outlook on growth and inflation, it is the most reliable lead indicator for where Gold "should" be priced.

3. The Institutional Mirror
In the Koda Macro Analytic, we invert this yield. By flipping the yield upside down, the Blue Line becomes a mirror of institutional demand. When the Blue Line is rising, "Macro Gravity" is pulling Gold higher. When it dives, it indicates that the opportunity cost is rising and Gold will likely face selling pressure.

How to Use the Koda Macro Analytic

Reading the Dashboard
In the top right, the Koda Dashboard gives you an instant "Heat Map" of the market:
•	10Y TIPS: The current Real Yield percentage.
•	Gold Spot: The live price of Gold.
•	Macro Bias: A logic-based signal.

BULLISH: The Blue Line is trending above its short-term average, suggesting macro momentum is upward.

BEARISH: The Blue Line is losing momentum, suggesting macro headwinds for Gold.
________________________________________

Pro Strategy: The "Koda Gap"

When you see a large gap between the Blue Line and the Yellow Area, it indicates an "oversold" or "overbought" macro condition.

•	If the Blue Line is much higher than the Yellow Area, Gold is "cheap" relative to where yields say it should be.

•	If the Blue Line is much lower than the Yellow Area, Gold may be "overextended" relative to the macro backdrop.

The "Why": What Makes This Different?

Most traders look at Gold in a vacuum. The Koda Macro Analytic is different because it visualizes the Inverted 10Y TIPS Yield (Real Yields) directly over the Gold price.

•	The Inverse Correlation: Historically, Gold and Real Yields move in opposite directions. When Yields fall, Gold usually rises.

•	The Lead Signal: By inverting the Yield (the Blue Line), we make them move in the same direction. When the Blue Line is rising, it means the macro environment is "Bullish" for Gold.

•	The Institutional Edge: This indicator allows you to see "Divergences"—if Gold is falling but the Blue Line is staying high, the macro trend suggests the dip is a buying opportunity.
________________________________________
Setup Steps: The "Koda Look"

To ensure the indicator displays correctly and looks professional, follow these four steps:

1. Set Your Asset
•	Symbol: Always use XAUUSD as your main chart. The script is calibrated to the price range of Gold.

2. Clean the Canvas
•	Candles: TradingView defaults to showing red/blue candles. To get the clean Koda aesthetic, find XAUUSD in the top-left legend and click the "Eye" icon to hide the candles. 

This leaves only the Koda lines visible.

3. Check the Scale
•	Invert Scale: Ensure "Invert Scale" is un-checked on your main right-hand axis. The script handles all necessary inversions internally. If your scale is inverted, the fill and lines will appear "upside down."

4. Maintain Clarity
•	Cleanliness: TradingView’s scaling can sometimes act up when you zoom in or out rapidly. If the lines ever look "stretched" or the yellow area looks like a flat block, simply right-click the price scale and hit "Reset Price Scale."

## Source Code

````pine
//@version=5
// Author: Tono Miakoda
// Branded Asset: Koda Macro Analytic Dashboard
indicator("Koda Macro Analytic", overlay=true, precision=2)

// ==========================================
// BRAND COLORS
// ==========================================
color kodaBlue   = #1E90FF 
color kodaYellow = #FFD700 
color kodaBlack  = #131722 
color kodaGrid   = #000000 

// ==========================================
// INPUTS
// ==========================================
ticker_yield = input.string("FRED:DFII10", "10Y TIPS Yield Ticker") 
show_gold    = input.bool(true, "Show Gold Area Background")
dash_pos     = input.string("Top Right", "Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"])
dash_size    = input.string("Small", "Size", options=["Large", "Medium", "Small", "Tiny"])

// Data fetching
yield_raw = request.security(ticker_yield, timeframe.period, close, ignore_invalid_symbol=true)
gold_raw  = close 

// ==========================================
// MACRO LOGIC (Normalization)
// ==========================================
// 200 bar stable visual window
p_hi  = ta.highest(high, 200)
p_lo  = ta.lowest(low, 200)
p_rg  = math.max(p_hi - p_lo, 1.0)

y_inv = yield_raw * -1
y_min = ta.lowest(y_inv, 200)
y_max = ta.highest(y_inv, 200)
y_df  = math.max(y_max - y_min, 0.01)

// Normalize yield to the gold price range
y_norm = p_lo + (y_inv - y_min) / y_df * p_rg

// ==========================================
// THE KODA VISUAL (Clean Mountain Baseline)
// ==========================================
// 1. Gold Price Line
p1 = plot(show_gold ? gold_raw : na, "Koda Gold Line", color=kodaYellow, linewidth=2)

// 2. The Anchor (Pushed 50% below the range to hide the blocky edge)
p2 = plot(show_gold ? p_lo - (p_rg * 0.5) : na, "Visual Floor", color=color.new(color.black, 100))

// 3. The Clean Area Fill (High transparency for a subtle "pro" look)
fill(p1, p2, color=color.new(kodaYellow, 90), title="Gold Shading")

// 4. The Lead Royal Blue Yield Line
plot(y_norm, "Inverted 10Y TIPS", color=kodaBlue, linewidth=3)

// ==========================================
// KODA DASHBOARD
// ==========================================
var table koda_dash = na
c_sz = dash_size == "Large" ? size.normal : dash_size == "Medium" ? size.small : size.tiny

if barstate.islast
    t_pos = dash_pos == "Top Right" ? position.top_right : 
             dash_pos == "Top Left" ? position.top_left : 
             dash_pos == "Bottom Right" ? position.bottom_right : position.bottom_left
    
    koda_dash := table.new(t_pos, 2, 4, frame_color=kodaGrid, frame_width=2, border_color=kodaGrid, border_width=2)
    
    // Header
    table.cell(koda_dash, 0, 0, "𝐊𝐎𝐃𝐀 𝐌𝐀𝐂𝐑𝐎 𝐀𝐍𝐀𝐋𝐘𝐓𝐈𝐂", text_color=color.white, bgcolor=kodaBlue, text_size=c_sz)
    table.merge_cells(koda_dash, 0, 0, 1, 0)
    
    // Data Rows
    table.cell(koda_dash, 0, 1, "10Y TIPS", text_color=color.white, bgcolor=kodaBlue, text_halign=text.align_left, text_size=c_sz)
    table.cell(koda_dash, 1, 1, str.tostring(yield_raw, "#.##") + "%", text_color=color.black, bgcolor=kodaYellow, text_size=c_sz)
    
    table.cell(koda_dash, 0, 2, "Gold Spot", text_color=color.white, bgcolor=kodaBlue, text_halign=text.align_left, text_size=c_sz)
    table.cell(koda_dash, 1, 2, "$" + str.tostring(gold_raw, "#.#"), text_color=color.black, bgcolor=kodaYellow, text_size=c_sz)
    
    // Bias Logic
    string macro_bias = y_inv > ta.sma(y_inv, 20) ? "BULLISH" : "BEARISH"
    table.cell(koda_dash, 0, 3, "Macro Bias", text_color=color.white, bgcolor=kodaBlue, text_halign=text.align_left, text_size=c_sz)
    table.cell(koda_dash, 1, 3, macro_bias, text_color=color.white, bgcolor=kodaBlack, text_size=c_sz)
````
