<!-- tradingview-pine-id: PUB;657fbed70bdc4e009c6472199eeca8b7 -->
<!-- tradingviewscripts-format: 1 -->
# Regression Trend - Mies

Source: https://www.tradingview.com/script/yvTpCe0f-Regression-Trend-MiesOnCharts/

## Description

Regression Trend - Mies

What it does
This indicator fits a linear regression line to price over a rolling window and draws a corridor around it based on the statistical error of that fit. The corridor is what decides the trend state. As long as price stays inside it, nothing changes. When price closes outside one side, the whole thing flips color and a triangle marks the bar.

The result is a trend line that carries its own tolerance band with it, so you can see at a glance both where the fitted trend sits and how much room price has before the state changes.

How it works
A least squares regression is fitted across the lookback window. That gives the center line.

Around it, the script computes the standard error of the estimate, which is the typical distance between actual price and the fitted line. It comes from the correlation between price and time:

r is the correlation of the source with bar index over the window
residual variance is the price variance scaled by (1 - r²) 
the standard error is the square root of that, adjusted for the degrees of freedom of the fit.

This is the part that makes the corridor behave differently from a standard deviation band. The width responds to how well price is actually tracking the trend, not just to raw volatility. A strong, clean trend produces a high correlation, small residuals, and a narrow corridor, so the indicator stays sensitive.

Choppy price that wanders around the line produces a weak fit, a wide corridor, and a much higher bar for triggering a state change. The indicator effectively demands more evidence in exactly the conditions where evidence is thin.

The bands sit at the center line plus and minus a multiple of that standard error. A close above the upper band turns the state bullish, a close below the lower band turns it bearish, and everything in between leaves the previous state untouched. That hysteresis is intentional. It is what stops the indicator from flipping every time price crosses its own mean.

On the chart
Regression line, green when the state is bullish, red when bearish, gray before the first breakout
Upper and lower standard error bands with a light fill between them, colored to match the current state Triangle below the bar when the state flips bullish Triangle above the bar when the state flips bearish.

Display controls to hide the fill, or the bands entirely, if you want a bare trend line
Two alert conditions, one for each direction
Settings

Source sets which series gets fitted. Close is the standard choice. HL2 or a smoothed input will give a calmer line and fewer flips.

Regression Window sets how many bars the fit covers. Shorter windows follow recent structure and react fast. Longer windows describe the broader trend and produce fewer, slower signals. This is the main setting for matching the tool to your timeframe.

SE Band Multiplier controls how far price has to move from the fitted line before the state changes. Lower values tighten the corridor and generate more signals. Higher values require a more decisive break and filter more noise, at the cost of entering later.

Display group toggles the bands and the fill, and adjusts band opacity.

How to use it
The most direct use is as a trend filter. Trade only in the direction the line is colored and treat the opposite flip as your exit or your cue to step aside.

The corridor itself gives you two readable things. Its width tells you how well price is respecting the trend, so a corridor that has narrowed over recent bars means the fit is tightening and the move is orderly. A corridor that has ballooned means the fit has broken down and the state you are looking at is stale. The center line works as a dynamic reference within an established regime, since a pullback toward it is price returning to its own fitted mean rather than to an arbitrary level.

It pairs well with a volume or momentum check. A corridor break tells you the move is statistically unusual relative to the current fit, but it says nothing about whether there is participation behind it.

Behavior worth understanding
The regression is recalculated on every bar, and the corridor plotted on each bar is that bar's own fit. This is a running envelope, not a fixed channel anchored to a pivot, so the bands will look wavier than a manually drawn regression channel. The reference moves with price, which is what keeps the state stable through a sustained run.

Signals are evaluated on the live bar, so a flip can appear and then vanish before the bar closes. Wait for bar close if you need signals that hold.

Limitations

Linear regression assumes price is moving in a straight line across the window, which is never fully true. The fit degrades at sharp reversals and around gaps, and the corridor is slow to acknowledge a turn right after a strong move because that extension is still inside the window. Treat this as a description of current trend structure, not a forecast.

Disclaimer
The indicator provided is not financial advice. Always conduct your own research and consider multiple factors before making trading decisions. Trade at your own risk.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © MiesOnCharts

//   __  __ _
//  |  \/  (_) ___  ___
//  | |\/| | |/ _ \/ __|
//  | |  | | |  __/\__ \
//  |_|  |_|_|\___||___/

//@version=6
// ============================================================

//  Indicator: Regression trend line with a standard-error
//  corridor driving regime detection and breakout signals.
// ============================================================
indicator("Regression Trend - Mies", overlay = true)

src  = input.source(close, "Source")
len  = input.int(65, "Regression Window (bars)", minval = 10)
mult = input.float(1.5, "SE Band Multiplier", minval = 0.5, step = 0.25)

showBands = input.bool(true,  "Show Corridor",      group = "Display")
showFill  = input.bool(true,  "Fill Corridor",      group = "Display")
bandTrans = input.int(45, "Corridor Opacity", minval = 0, maxval = 100, group = "Display")

// --- OLS fit + standard error ---------------------------------
mid = ta.linreg(src, len, 0)

r  = ta.correlation(src, bar_index, len)
r2 = r * r
varY = math.pow(ta.stdev(src, len), 2)
se = math.sqrt(math.max(varY * (1 - r2) * (len - 1) / (len - 2), 0))

// Corridor at the current bar drives the regime
curUp = mid + mult * se
curDn = mid - mult * se
var int dir = 0
dir := src > curUp ? 1 : src < curDn ? -1 : dir
isUp = dir == 1

colUp = color.rgb(0, 255, 21)
colDn = color.rgb(255, 0, 0)

regCol = dir == 0 ? color.gray : isUp ? colUp : colDn
plot(mid, "Regression Mid", color = color.new(regCol, 20), linewidth = 2)

// --- Corridor -------------------------------------------------
pUp = plot(showBands ? curUp : na, "Upper SE Band", color = color.new(regCol, bandTrans))
pDn = plot(showBands ? curDn : na, "Lower SE Band", color = color.new(regCol, bandTrans))
fill(pUp, pDn, color = showBands and showFill ? color.new(regCol, 92) : na, title = "Corridor Fill")

flipUp = dir == 1  and dir[1] != 1
flipDn = dir == -1 and dir[1] != -1

plotshape(flipUp, "Long",  shape.triangleup,   location.belowbar, colUp, size = size.small)
plotshape(flipDn, "Short", shape.triangledown, location.abovebar, colDn, size = size.small)

alertcondition(flipUp, "Regression Corridor Up",   "Price above the regression corridor")
alertcondition(flipDn, "Regression Corridor Down", "Price below the regression corridor")
````
