# ICT Narrative [by Roman]

- url: https://www.tradingview.com/script/u5fsVmEk-ICT-Narrative-by-Roman/
- type: indicator
- pine_id: PUB;ac044c29c7e94b9d8ae8fe42fc15468a
- version: 1.0

## Description

ICT Narrative is a lightweight multi-timeframe bias dashboard designed for traders using ICT and Smart Money Concepts.

The script automatically analyzes higher timeframe structure and displays the current narrative across:
• Monthly (M)
• Weekly (W)
• Daily (D)
• H4

For each timeframe the indicator shows:
• Market Bias → Bull / Bear
• Dealing Range Position → Premium / Discount

How it works:
The script uses fractal-based structure to build an equilibrium range and determine:
• Whether price is trading above or below equilibrium
• Whether the market is in a bullish or bearish narrative
• Whether price is positioned in premium or discount territory

Features:
• Clean table layout
• Multi-timeframe narrative alignment
• Automatic premium/discount detection
• Bullish and bearish color coding
• Minimalistic design with low chart clutter
• Works on all markets and timeframes

Useful for:
• ICT traders
• Smart Money Concepts analysis
• Top-down analysis
• Bias confirmation
• Dealing range analysis
• Intraday and swing trading

This indicator helps traders quickly identify higher timeframe context before looking for entries on lower timeframes.

## Source Code

````pine
//@version=5
indicator("ICT Narrative [by Roman]", overlay=true)

//====================================================
// FRACTALS ENGINE
//====================================================

bullFractal() =>
    high[1] > high[0] and high[1] > high[2]

bearFractal() =>
    low[1] < low[0] and low[1] < low[2]

//====================================================
// TF ENGINE
//====================================================

f_tf() =>
    bull = bullFractal()
    bear = bearFractal()

    var float h = na
    var float l = na

    if bull
        h := high[1]

    if bear
        l := low[1]

    eq = (h + l) / 2

    bias = not na(eq) ? (close > eq ? "Bull" : "Bear") : "NA"
    pos  = not na(eq) ? (close > eq ? "Premium" : "Discount") : "NA"

    [bias, pos]

//====================================================
// MULTI-TF STACK
//====================================================

[mBias, mPos]   = request.security(syminfo.tickerid, "M", f_tf())
[wBias, wPos]   = request.security(syminfo.tickerid, "W", f_tf())
[dBias, dPos]   = request.security(syminfo.tickerid, "D", f_tf())
[h4Bias, h4Pos] = request.security(syminfo.tickerid, "240", f_tf())

//====================================================
// COLORS
//====================================================

bgBull    = color.new(color.green, 0)
bgBear    = color.new(color.red, 0)
bgNeutral = color.new(color.rgb(220,220,220), 0)

// Position text colors
posTextColor(p) =>
    p == "Discount" ? color.rgb(0, 0, 0) :p == "Premium"  ? color.rgb(0, 0, 0) :color.gray

// Bias background
biasBg(b) =>b == "Bull" ? bgBull :b == "Bear" ? bgBear :bgNeutral

//====================================================
// TABLE
//====================================================

// 5 rows × 3 columns
var table t = table.new(position.top_right, 3, 5, border_width=1)

//====================================================
// RENDER
//====================================================

if barstate.islast

    // HEADER
    table.cell(t, 0, 0, "TF", bgcolor=color.rgb(30,30,30), text_color=color.white)
    table.cell(t, 1, 0, "Bias", bgcolor=color.rgb(30,30,30), text_color=color.white)
    table.cell(t, 2, 0, "Zone", bgcolor=color.rgb(30,30,30), text_color=color.white)

    // M
    table.cell(t, 0, 1, "M", bgcolor=color.rgb(245,245,245))
    table.cell(t, 1, 1, mBias, bgcolor=biasBg(mBias), text_color=color.white)
    table.cell(t, 2, 1, mPos, bgcolor=color.rgb(245,245,245), text_color=posTextColor(mPos))

    // W
    table.cell(t, 0, 2, "W", bgcolor=color.rgb(245,245,245))
    table.cell(t, 1, 2, wBias, bgcolor=biasBg(wBias), text_color=color.white)
    table.cell(t, 2, 2, wPos, bgcolor=color.rgb(245,245,245), text_color=posTextColor(wPos))

    // D
    table.cell(t, 0, 3, "D", bgcolor=color.rgb(245,245,245))
    table.cell(t, 1, 3, dBias, bgcolor=biasBg(dBias), text_color=color.white)
    table.cell(t, 2, 3, dPos, bgcolor=color.rgb(245,245,245), text_color=posTextColor(dPos))

    // H4
    table.cell(t, 0, 4, "H4", bgcolor=color.rgb(245,245,245))
    table.cell(t, 1, 4, h4Bias, bgcolor=biasBg(h4Bias), text_color=color.white)
    table.cell(t, 2, 4, h4Pos, bgcolor=color.rgb(245,245,245), text_color=posTextColor(h4Pos))
````
