# 15-Minute Squeeze Scalper (Traffic Light Edition)

- url: https://www.tradingview.com/script/GhMFgiA3-15-Minute-Squeeze-Scalper-Traffic-Light-Edition/
- type: indicator
- pine_id: PUB;1fbbed687fa84b4e95495b26ed579a59
- version: 1.0

## Description

[b]Overview [/b]This is a highly optimized version of the famous Squeeze Momentum Indicator, customized specifically for [b]15-minute scalping[/b].

While the original indicator is powerful, the default colors can be confusing for new traders. I have recoded this to function as a simple [b]"Traffic Light"[/b] system to help you identify periods of inaction vs. periods of high-probability breakouts.

[b]How it Works [/b]This tool identifies when the market is "quiet" (low volatility) and getting ready to explode. It uses Bollinger Bands and Keltner Channels to measure this energy.

[b]The "Traffic Light" Visuals[/b]

[b]🔴 RED Cross (Center Line): STOP / WAIT[/b]

[b]Meaning:[/b] The Squeeze is ON. The market is coiling tight.

[b]Action:[/b] Do not trade yet. Wait for the energy to release. The longer the line of red dots, the bigger the potential move.

[b]🟢 GREEN Cross (Center Line): GO / ACTION[/b]

[b]Meaning:[/b] The Squeeze has FIRED. Volatility is expanding.

[b]Action: [/b]Look at the Histogram to determine the direction of the trade.

[b]📊 Histogram Bars:[/b]

[b]Lime/Green:[/b] Bullish Momentum (Trade Long).

[b]Red/Maroon:[/b] Bearish Momentum (Trade Short).

[b]The 15-Minute Scalping Strategy[/b]

[list=1]
[*][b]Identify the Squeeze: [/b]Look for a series of Red Crosses on the zero line.
[*][b]Wait for the Fire:[/b] Wait for the first Green Cross to appear.
[*][b]Confirm Direction:[/b]
[/list]

[list]
[*]If the Cross turns Green AND the Histogram is above zero: LONG.
[*]If the Cross turns Green AND the Histogram is below zero: SHORT.
[/list]

[b]Alerts Included [/b]I have added custom alerts so you don't have to stare at the screen:

[b]"Squeeze Fired": [/b]Alerts you instantly when the Red Cross changes to Green.

[b]"Momentum Long/Short": [/b]Alerts you when momentum flips direction.

## Source Code

````pine
//@version=6
indicator("Squeeze Momentum Scalper [15m]", shorttitle="SQZ_Scalp", overlay=false)

// --- Inputs ---
lengthBB = input.int(20, title="BB Length")
multBB   = input.float(2.0, title="BB MultFactor")
lengthKC = input.int(20, title="KC Length")
multKC   = input.float(1.5, title="KC MultFactor")

useTrueRange = input.bool(true, title="Use TrueRange (KC)")

// --- Calculations ---

// 1. Bollinger Bands
source = close
basis = ta.sma(source, lengthBB)
dev   = multBB * ta.stdev(source, lengthBB)
upperBB = basis + dev
lowerBB = basis - dev

// 2. Keltner Channels
ma = ta.sma(source, lengthKC)
range_val = useTrueRange ? ta.tr : (high - low)
rangema = ta.sma(range_val, lengthKC)
upperKC = ma + rangema * multKC
lowerKC = ma - rangema * multKC

// --- Squeeze Logic ---
// Red (Squeeze ON) = Market is coiling (NO ACTION)
sqzOn  = (lowerBB > lowerKC) and (upperBB < upperKC)

// Green (Squeeze OFF) = Volatility Expansion (ACTION)
sqzOff = (lowerBB < lowerKC) and (upperBB > upperKC)

// Blue (No Squeeze) = Standard volatility
noSqz  = (sqzOn == false) and (sqzOff == false)

// --- Momentum Logic ---
// Linear Regression of price delta to determine direction
mom_source = source - math.avg(math.avg(ta.highest(high, lengthKC), ta.lowest(low, lengthKC)), ta.sma(close, lengthKC))
val = ta.linreg(mom_source, lengthKC, 0)

// --- Visual Colors ---
// Histogram Colors
bcolor = val > 0 ? (val > nz(val[1]) ? color.lime : color.green) : (val < nz(val[1]) ? color.red : color.maroon)

// Squeeze Dots Colors (User Requested Update)
// Squeeze ON (Waiting) -> Red
// Squeeze FIRED (Action) -> Green
scolor = noSqz ? color.blue : sqzOn ? color.red : color.green

// --- Plotting ---
plot(val, color=bcolor, style=plot.style_histogram, linewidth=4, title="Momentum Histogram")
plot(0, color=scolor, style=plot.style_cross, linewidth=2, title="Squeeze Status")

// --- Alert Conditions ---

// Alert 1: Squeeze Fired (Turns from Red to Green or Blue) - The trigger for entry
squeezeFired = sqzOn[1] and not sqzOn

// Alert 2: Momentum Entry Long (Histogram crosses 0 to positive)
longEntry = ta.crossover(val, 0)

// Alert 3: Momentum Entry Short (Histogram crosses 0 to negative)
shortEntry = ta.crossunder(val, 0)

alertcondition(squeezeFired, title="Squeeze Fired", message="Volatility Squeeze has FIRED! Check histogram for direction.")
alertcondition(longEntry, title="Long Momentum", message="Momentum has crossed bullish.")
alertcondition(shortEntry, title="Short Momentum", message="Momentum has crossed bearish.")
````
