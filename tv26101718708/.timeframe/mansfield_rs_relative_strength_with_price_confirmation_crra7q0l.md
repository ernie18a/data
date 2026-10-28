# Mansfield RS+ - Relative Strength with Price Confirmation

- url: https://www.tradingview.com/script/CrRa7q0l-Mansfield-RS-Relative-Strength-with-Price-Confirmation/
- type: indicator
- pine_id: PUB;bd8383d8a12f4ad4a9d7e7ce93e496c5
- version: 3.0

## Description

Combines the Mansfield Relative Strength calculation (credit: stageanalysis) with a price action confirmation overlay (credit: bharatTrader) into a single indicator.

[b]Calculation[/b]
The RS line measures daily stock price divided by weekly SPX close, normalized against a 52-week SMA of that ratio. Values above zero indicate outperformance vs. the S&P 500. Values below zero indicate underperformance.
Inputs

[list]
[*]Symbol: benchmark index (default SP:SPX)
[*]MA Length: lookback period for the zero line SMA (default 52)
[*]Price Confirmation Period: SMA length for bubble logic (default 50)
[*]RS Trend Range: lookback for zero line momentum color (default 5)
[*]Show Bubbles: toggle price confirmation overlay
[*]Show Background Colors: toggle Mansfield-style background
[/list]

[b]Reading the indicator[/b]
The zero line changes color based on RS momentum direction — green when RS is accelerating, red when decelerating.
Bubbles appear when price and its 50 SMA agree on direction. Green bubbles indicate price above a rising SMA. Red bubbles indicate price below a falling SMA.
RS above zero with green bubbles: RS and price both confirm, strongest long signal. RS above zero with red bubbles: RS positive but price weakening, use as a caution signal. RS below zero with green bubbles: price leading RS, early watch but not yet actionable. RS below zero with red bubbles: both confirm weakness, avoid.

[b]Alerts included[/b]
[list]
[*]RS crossed above/below zero
[*]RS trend turned bullish/bearish
[*]
[/list]

Credits:
Mansfield RS formula: [url=https://www.tradingview.com/script/NzUBDDtb-Mansfield-Relative-Strength-Original-Version-by-stageanalysis/[/url]
Price confirmation bubble logic: [url=https://www.tradingview.com/script/OhSlks3B-Relative-Strength-of-a-stock/]bharatTrader[/url]

## Source Code

````pine
//@version=5
indicator('Mansfield RS+', shorttitle='Mansfield RS+', overlay=false)

// Inputs
sym                = input.symbol(title='Symbol', defval='SPCFD:SPX')
maLength           = input.int(52, minval=1, title='MA Length')
showBubbles        = input.bool(defval=true, title='Show Bubbles', group='Price Confirmation')
lengthPriceSMA     = input.int(50, minval=1, title='Price Confirmation Period', group='Price Confirmation')
showRSTrend        = input.bool(defval=true, title='Color Zero Line by Trend', group='RS Trend')
base               = input.int(title='Range', minval=1, defval=5, group='RS Trend')
labelSize          = input.string(defval='normal', title='Value Label Size', options=['tiny', 'small', 'normal', 'large', 'huge'], group='Value Label')
labelColorOverride = input.bool(defval=false, title='Override Label Color', group='Value Label')
labelColor         = input.color(defval=color.white, title='Label Color', group='Value Label')

// Colors
bullColor  = color.new(#2962ff, 0)
bearColor  = color.new(#e91e63, 0)
bullBubble = color.new(#00bcd4, 50)
bearBubble = color.new(#e91e63, 50)

// Data — daily stock / weekly SPX, matches original Mansfield exactly
spx   = request.security(sym, '1W', close)
stock = close

// Mansfield RS — exact formula
stockDividedBySpx = stock / spx * 100
zeroLineMA        = ta.sma(stockDividedBySpx, maLength)
mansfieldRS       = ((stockDividedBySpx / zeroLineMA) - 1) * 100

// Zero line trend color
y0            = mansfieldRS - mansfieldRS[base]
angle0        = math.atan(y0 / base)
zeroLineColor = showRSTrend ? (angle0 > 0.0 ? bullColor : bearColor) : color.gray

// RS line color
rsColor = mansfieldRS > 0 ? bullColor : bearColor

// Price confirmation bubbles (daily)
sma_price   = ta.sma(stock, lengthPriceSMA)
pos_div     = ta.rising(sma_price, 3) and stock >= sma_price
neg_div     = ta.falling(sma_price, 3) and stock < sma_price
div_started = pos_div or neg_div
div_color   = div_started ? (pos_div ? bullBubble : bearBubble) : na

// Plot
plot(0, linewidth=1, color=zeroLineColor, title='Zero Line', display=display.pane)
plot(mansfieldRS, title='Mansfield RS', linewidth=1, color=rsColor)
plot(showBubbles and div_started ? mansfieldRS : na, title='Confirmation Bubbles', color=div_color, linewidth=4, style=plot.style_circles, display=display.data_window + display.pane)

// Value label at tip of RS line
if barstate.islast
    resolvedSize  = labelSize == 'tiny' ? size.tiny : labelSize == 'small' ? size.small : labelSize == 'large' ? size.large : labelSize == 'huge' ? size.huge : size.normal
    resolvedColor = labelColorOverride ? labelColor : rsColor
    label.new(time, mansfieldRS, text=str.tostring(mansfieldRS, '#.##'), color=color.new(color.black, 100), textcolor=resolvedColor, style=label.style_label_left, size=resolvedSize, xloc=xloc.bar_time)

// Alerts
alertcondition(ta.crossover(mansfieldRS, 0), title='RS Crossed Above Zero', message='Mansfield RS crossed above zero — bullish')
alertcondition(ta.crossunder(mansfieldRS, 0), title='RS Crossed Below Zero', message='Mansfield RS crossed below zero — bearish')
alertcondition(angle0 > 0.0 and angle0[1] <= 0.0, title='RS Trend Turned Up', message='Mansfield RS trend turned bullish')
alertcondition(angle0 < 0.0 and angle0[1] >= 0.0, title='RS Trend Turned Down', message='Mansfield RS trend turned bearish')
````
