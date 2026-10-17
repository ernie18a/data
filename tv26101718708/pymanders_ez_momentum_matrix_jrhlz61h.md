# Pymander's EZ Momentum Matrix

- url: https://www.tradingview.com/script/JRhlz61H-Pymander-s-EZ-Momentum-Matrix/
- type: indicator
- pine_id: PUB;cbb9f93cd141484abb509d3e47c86353
- version: 1.0

## Description

Pymander's EZ Momentum Matrix—your new go-to tool for catching the pulse of the market!
I built this indicator because I know how frustrating it is to feel like you're "chasing" a move or getting caught in choppy fakeouts. This tool is designed to act like your trading GPS, helping you cut through the noise and align yourself with the high-probability trend instantly.
How it works:
Under the hood, we’ve combined two powerful components into one seamless visual experience:
The Momentum Wave: An ultra-sensitive oscillator that reacts to price shifts almost instantly. It changes color based on its slope—green when rising and red when falling—so you know exactly when momentum is shifting, even before a zero-cross.
The Trend Matrix: This is the heatmap bar at the bottom. It uses low-lag DEMA (Double EMA) logic and a 50-period trend filter to act as your "gatekeeper." It ensures you only take long signals when the macro trend is actually in your favor.
What makes it unique?
Confluence Diamonds: When the fast momentum wave and the filtered Trend Matrix align perfectly, a diamond signal appears on the wave. These are your "stars aligned" moments for high-probability entries.
Extreme Turn Signals: Small circles appear when the oscillator curls back in overbought or oversold zones, giving scalpers an early warning for potential micro-reversals.
The Glow: We polished the visuals with a slight aura glow effect and smooth gradients. Not only does it help you see signals more clearly, but your charts will look amazing while you're trading!
Why you’ll love it:
It’s all about clarity. By using the EZ Momentum Matrix, you stop guessing and start following. It simplifies complex trend and momentum data into a color-coded system that makes trade decisions faster and much more disciplined.
We’d love to hear how this is working for your specific strategy, so please reach out with any feedback or suggestions!
Wishing you tons of luck out there, stay disciplined, and here’s to many green days ahead!
-Pymander

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
indicator("Pymander's EZ Momentum Matrix", shorttitle="EZ Momentum Matrix", overlay=false, precision=2)

// --- Style Settings ---
grp_style   = "Style Settings"
colorUp     = input.color(#089981, "Oscillator Rising", group=grp_style, tooltip="Color of the oscillator when it is moving upward.")
colorDn     = input.color(#f23645, "Oscillator Falling", group=grp_style, tooltip="Color of the oscillator when it is moving downward.")
colorBull   = input.color(#26A69A, "Matrix Bullish", group=grp_style, tooltip="Color of the trend matrix when trend is bullish.")
colorBear   = input.color(#f23645, "Matrix Bearish", group=grp_style, tooltip="Color of the trend matrix when trend is bearish.")
colorNeut   = input.color(#FFFFFF, "Matrix Neutral", group=grp_style, tooltip="Color of the trend matrix when trend is neutral.")
showGlow    = input.bool(true, "Show Glow Effect", group=grp_style, tooltip="Adds a slight visual glow to the oscillator line.")
showFill    = input.bool(true, "Show Oscillator Fill", group=grp_style, tooltip="Shows the gradient background fill.")

// --- Oscillator Settings ---
grp_osc     = "Oscillator Settings"
sensitivity = input.float(13.0, "Sensitivity", minval=1.0, group=grp_osc, tooltip="Controls the magnitude and responsiveness of the wave.")
fastLen     = input.int(7, "Fast Period", minval=1, group=grp_osc, tooltip="Lookback for the fast component.")
slowLen     = input.int(16, "Slow Period", minval=1, group=grp_osc, tooltip="Lookback for the slow component.")
smooth      = input.int(3, "Smoothing", minval=1, group=grp_osc, tooltip="Final smoothing of the oscillator line.")

// --- Zones & Signals ---
grp_zones   = "Zones & Turn Signals"
obLevel     = input.float(10.0, "Overbought Level", group=grp_zones, tooltip="Level above which bearish turn signals can appear.")
osLevel     = input.float(-10.0, "Oversold Level", group=grp_zones, tooltip="Level below which bullish turn signals can appear.")

// --- Matrix Settings ---
grp_mat     = "Trend Matrix Logic"
maFastLen   = input.int(12, "Fast MA Length", minval=1, group=grp_mat)
maSlowLen   = input.int(26, "Slow MA Length", minval=1, group=grp_mat)
maSignalLen = input.int(9, "Signal Smoothing", minval=1, group=grp_mat)
maTrendLen  = input.int(50, "Trend Filter Length", minval=1, group=grp_mat)
showMatrix  = input.bool(true, "Show Trend Matrix", group=grp_mat, tooltip="Displays a trend heatmap at the bottom.")

// --- Core Calculations ---
// Double EMA function
dema(s, l) => 
    float e = ta.ema(s, l)
    2 * e - ta.ema(e, l)

// Oscillator logic
emaFast = ta.ema(close, fastLen)
emaSlow = ta.ema(close, slowLen)
diffOsc = emaFast - emaSlow
stdOsc  = ta.stdev(diffOsc, slowLen * 2)
oscRaw  = (diffOsc / (stdOsc == 0 ? 1 : stdOsc)) * sensitivity
osc     = ta.ema(oscRaw, smooth)
signal  = ta.ema(osc, math.max(2, smooth * 2))

// Slope and Turn logic
isRising   = osc > nz(osc[1])
hyperColor = isRising ? colorUp : colorDn
bearTurn   = osc < nz(osc[1]) and nz(osc[1]) >= nz(osc[2]) and nz(osc[1]) > obLevel
bullTurn   = osc > nz(osc[1]) and nz(osc[1]) <= nz(osc[2]) and nz(osc[1]) < osLevel

// Trend Matrix logic
bbFastMA   = dema(close, maFastLen)
bbSlowMA   = dema(close, maSlowLen)
bbMACD     = bbFastMA - bbSlowMA
bbSignalMA = dema(bbMACD, maSignalLen)
bbHist     = bbMACD - bbSignalMA
bbTrendMA  = dema(close, maTrendLen)

isBullishTrend = bbHist > 0 and close > bbTrendMA and open > bbTrendMA and low > bbTrendMA
isBearishTrend = bbHist < 0 and close < bbTrendMA and open < bbTrendMA and high < bbTrendMA

matrixColor = isBullishTrend ? colorBull : isBearishTrend ? colorBear : colorNeut

// Confluence logic
bullConfluence = isRising and isBullishTrend and not (isRising[1] and isBullishTrend[1])
bearConfluence = (not isRising) and isBearishTrend and not ((not isRising[1]) and isBearishTrend[1])

// --- Visuals ---
midlineColor = #787b86
hline(0, "Midline", color.new(midlineColor, 50), linestyle=hline.style_dashed)
hline(obLevel, "OB Level", color.new(colorDn, 80), linestyle=hline.style_dotted)
hline(osLevel, "OS Level", color.new(colorUp, 80), linestyle=hline.style_dotted)

// Oscillator Glow Effect (Polished Visuals)
plot(showGlow ? osc : na, "Oscillator Glow", color=color.new(hyperColor, 75), linewidth=6)
plot(showGlow ? osc : na, "Oscillator Outer Glow", color=color.new(hyperColor, 90), linewidth=10)

// Main Plot
p_osc  = plot(osc, "Oscillator", color=hyperColor, linewidth=3)
p_zero = plot(0, "Zero Reference", display=display.none)

// Refined Fill
fill(p_osc, p_zero, 
     top_value = math.max(0, osc), 
     bottom_value = math.min(0, osc), 
     top_color = showFill ? (osc > 0 ? color.new(hyperColor, 60) : color.new(hyperColor, 95)) : na, 
     bottom_color = showFill ? (osc > 0 ? color.new(hyperColor, 95) : color.new(hyperColor, 60)) : na,
     title = "Oscillator Fill")

// Confluence Signals
plotshape(bullConfluence ? osc : na, title="Bullish Confluence", style=shape.diamond, location=location.absolute, color=colorUp, size=size.small)
plotshape(bearConfluence ? osc : na, title="Bearish Confluence", style=shape.diamond, location=location.absolute, color=colorDn, size=size.small)

// Turn Signals
plotshape(bearTurn ? osc[1] : na, title="Bearish Turn", style=shape.circle, location=location.absolute, color=colorDn, size=size.tiny, offset=-1)
plotshape(bullTurn ? osc[1] : na, title="Bullish Turn", style=shape.circle, location=location.absolute, color=colorUp, size=size.tiny, offset=-1)

// Signal Line
plot(signal, "Signal Line", color.new(chart.fg_color, 60), linewidth=1)

// Trend Matrix
matrixLevel = -18.0
plot(showMatrix ? matrixLevel : na, "Trend Matrix", color=matrixColor, style=plot.style_columns, histbase=matrixLevel - 2, linewidth=4)

// --- Alerts ---
alertcondition(bullConfluence, "Bullish Confluence Signal", "Oscillator Rising and Trend Matrix Bullish (Confluence)")
alertcondition(bearConfluence, "Bearish Confluence Signal", "Oscillator Falling and Trend Matrix Bearish (Confluence)")
alertcondition(bearTurn, "Extreme Bearish Turn", "Oscillator turned down in Overbought zone")
alertcondition(bullTurn, "Extreme Bullish Turn", "Oscillator turned up in Oversold zone")
````
