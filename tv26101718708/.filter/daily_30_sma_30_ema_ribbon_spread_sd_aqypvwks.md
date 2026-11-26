# Daily 30 SMA + 30 EMA Ribbon + Spread SD 

- url: https://www.tradingview.com/script/aQypvWkS-Daily-30-SMA-30-EMA-Ribbon-Spread-SD/
- type: indicator
- pine_id: PUB;206defe8b3d2418e90c864e6310e1208
- version: 1.0

## Description

[b]Description[/b]

Multi-timeframe ribbon showing the relationship between the 30-period SMA and EMA calculated on the Daily timeframe. Includes dynamic ribbon fill and ±1 SD bands on the spread for volatility context.

[b]Key Features[/b]

Pulls true Daily 30 SMA & 30 EMA (works on any chart timeframe)
Coloured ribbon between the two MAs (Red when SMA > EMA, Green when EMA > SMA)
Spread ± Standard Deviation bands (default 20-period) around the midline
Visual cross markers
Fully customisable colours, lengths, and visibility

[b]How to Use[/b]

Add to any chart (best on 1H, 4H, or Daily).
Green ribbon = EMA above SMA (bullish in this setup - RED FLAG indicators crossover).
Red ribbon = SMA above EMA (bearish in this setup - GREEN FLAG indicators crossover) - [I forgot to change the flag colours to match, you can do this adjustment yourself.]
Watch the gray SD bands — when the ribbon expands significantly beyond the bands, the spread is statistically wide (potential mean reversion or strong trend).
Use the SD Length (20 default) to adjust sensitivity.

[b]Pros[/b]

Clean visual of daily structure on intraday charts
SD bands help identify statistically significant spread expansions/contractions
Good for spotting pullbacks to the ribbon or regime changes
Highly customisable

[b]Cons / Limitations[/b]

MTF can lag slightly on very short timeframes
The swapped colour scheme (Red = bullish) may feel counter-intuitive at first
Not a standalone signal — best used with price action and volume

## Source Code

````pine
//@version=6
indicator(title="Daily 30 SMA + 30 EMA Ribbon + Spread SD [MTF]", shorttitle="Daily 30 MA Ribbon + SD", overlay=true, timeframe="", timeframe_gaps=true)

// Inputs
len         = input.int(30,  "MA Length",          minval=1,  group="Moving Averages")
sdLen       = input.int(20,  "Spread SD Length",   minval=1,  group="Spread + SD")
sdMult      = input.float(1.0, "SD Multiplier", step=0.1, group="Spread + SD")

smaColor    = input.color(#2196F3, "SMA Color", group="Colors")
emaColor    = input.color(#FF9800, "EMA Color", group="Colors")

bullFill    = input.color(color.new(#FF5252, 75), "Bullish Fill (SMA > EMA)", group="Ribbon Fill")
bearFill    = input.color(color.new(#00E676, 75), "Bearish Fill (SMA < EMA)", group="Ribbon Fill")

showLines   = input.bool(true,  "Show MA Lines", group="Display")
showRibbon  = input.bool(true,  "Show Ribbon Fill", group="Display")
showSDBands = input.bool(true,  "Show Spread ±SD Bands", group="Spread + SD")

// Calculations (Daily MTF)
daily_sma = request.security(syminfo.tickerid, "D", ta.sma(close, len))
daily_ema = request.security(syminfo.tickerid, "D", ta.ema(close, len))

midline   = (daily_sma + daily_ema) / 2
spread    = daily_sma - daily_ema
spreadSD  = ta.stdev(spread, sdLen)

upperBand = midline + sdMult * spreadSD
lowerBand = midline - sdMult * spreadSD

// Plots
smaPlot = plot(showLines ? daily_sma : na, "Daily 30 SMA", color=smaColor, linewidth=2)
emaPlot = plot(showLines ? daily_ema : na, "Daily 30 EMA", color=emaColor, linewidth=2)

// Ribbon
ribbonColor = daily_sma > daily_ema ? bullFill : bearFill
fill(smaPlot, emaPlot, color=showRibbon ? ribbonColor : na, title="MA Ribbon")

// SD Bands
plot(showSDBands ? upperBand : na, "Upper SD Band", color=color.new(color.gray, 60), linewidth=1, style=plot.style_circles)
plot(showSDBands ? lowerBand : na, "Lower SD Band", color=color.new(color.gray, 60), linewidth=1, style=plot.style_circles)

// Crosses
plotshape(ta.crossover(daily_sma, daily_ema), title="SMA > EMA", location=location.belowbar, style=shape.triangleup,   size=size.small, color=color.new(#00E676, 0))
plotshape(ta.crossunder(daily_sma, daily_ema), title="SMA < EMA", location=location.abovebar, style=shape.triangledown, size=size.small, color=color.new(#FF5252, 0))
````
