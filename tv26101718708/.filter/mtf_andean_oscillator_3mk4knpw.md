# MTF Andean Oscillator

- url: https://www.tradingview.com/script/3mk4kNpw-MTF-Andean-Oscillator/
- type: indicator
- pine_id: PUB;e17f49bbc0664a2a8e6e0deb5dcb1f51
- version: 1.0

## Description

MTF Andean Oscillator is a Multi Timeframe version of the popular Andean Oscillator that allows traders to view oscillator data from another selected timeframe while staying on the current chart.

This helps traders align entries with higher timeframe trend strength or monitor lower timeframe momentum without switching charts.

How It Works:

The script uses the standard Andean Oscillator formula and imports values from a user selected timeframe using multi timeframe logic.

Example:

Stay on 5 Minute chart and view 1 Hour Andean trend
Stay on 15 Minute chart and view 4 Hour Andean trend
Stay on Daily chart and view 4 Hour momentum shifts

Features:

• Standard Andean Oscillator calculation
• External timeframe selector
• Bull line shown in green
• Bear line shown in red
• Signal line shown in orange
• Separate oscillator pane for clean viewing
• Optional show or hide lines
• Real time multi timeframe updates
• Current selected timeframe display panel

Best Use Cases:

• Scalping with higher timeframe confirmation
• Intraday trading with trend alignment
• Spotting pullbacks inside larger trends
• Avoiding trades against dominant momentum
• Multi timeframe confluence setups

Reading the Oscillator:

Bull line above Bear line may indicate stronger bullish momentum.

Bear line above Bull line may indicate stronger bearish momentum.

Signal line can help identify momentum shifts and transitions.

Examples:

5 Minute chart + 1 Hour external timeframe for scalping

15 Minute chart + 4 Hour external timeframe for intraday trend trades

1 Hour chart + Daily external timeframe for swing bias

Important Note:

This tool is designed for analysis support and should be used together with price action, structure, volume, and risk management.

No indicator guarantees future movement.

## Source Code

````pine
//@version=6
indicator("MTF Andean Oscillator", shorttitle="MTF Andean", overlay=false)

//=============================
// Inputs
//=============================
tfInput     = input.timeframe("240", "External Timeframe")
length      = input.int(50, "Length", minval=1)
sigLength   = input.int(9, "Signal Length", minval=1)

showBull    = input.bool(true, "Show Bull Line")
showBear    = input.bool(true, "Show Bear Line")
showSignal  = input.bool(true, "Show Signal Line")

//=============================
// Standard Andean Function
//=============================
andeanFunc() =>
    alpha = 2.0 / (length + 1.0)

    var float up1 = na
    var float up2 = na
    var float dn1 = na
    var float dn2 = na

    c = close
    o = open

    up1 := na(up1[1]) ? c : math.max(c, o, up1[1] - (up1[1] - c) * alpha)
    up2 := na(up2[1]) ? c * c : math.max(c * c, o * o, up2[1] - (up2[1] - c * c) * alpha)

    dn1 := na(dn1[1]) ? c : math.min(c, o, dn1[1] + (c - dn1[1]) * alpha)
    dn2 := na(dn2[1]) ? c * c : math.min(c * c, o * o, dn2[1] + (c * c - dn2[1]) * alpha)

    bull = math.sqrt(math.max(dn2 - dn1 * dn1, 0))
    bear = math.sqrt(math.max(up2 - up1 * up1, 0))
    sig  = ta.ema(math.max(bull, bear), sigLength)

    [bull, bear, sig]

//=============================
// Get External Timeframe Data
//=============================
[bullLine, bearLine, sigLine] = request.security(syminfo.tickerid, tfInput, andeanFunc())

//=============================
// Plots
//=============================
plot(showBull ? bullLine : na,  title="Bull",   color=color.lime, linewidth=2)
plot(showBear ? bearLine : na,  title="Bear",   color=color.red, linewidth=2)
plot(showSignal ? sigLine : na, title="Signal", color=color.orange, linewidth=2)

// Fill
fill(
     plot(showBull ? bullLine : na, display=display.none),
     plot(showBear ? bearLine : na, display=display.none),
     color = bullLine > bearLine ? color.new(color.green,85) : color.new(color.red,85)
)

// Zero line
hline(0, "Zero", color=color.gray)

//=============================
// Info Label
//=============================
var table t = table.new(position.top_right, 1, 2, border_width=1)

if barstate.islast
    table.clear(t, 0, 0, 0, 1)
    table.cell(t, 0, 0, "MTF Andean", text_color=color.white, bgcolor=color.rgb(30,30,60))
    table.cell(t, 0, 1, "TF: " + tfInput, text_color=color.white, bgcolor=color.rgb(20,20,20))
````
