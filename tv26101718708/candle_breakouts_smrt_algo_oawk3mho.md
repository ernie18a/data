# Candle Breakouts [SMRT Algo]

- url: https://www.tradingview.com/script/OaWk3Mho-Candle-Breakouts-SMRT-Algo/
- type: indicator
- pine_id: PUB;fd468d791683408a91f1fc462332990f
- version: 1.0

## Description

Candle Breakouts [SMRT Algo] brings price-sequence analysis and momentum visualization directly onto your chart. It marks completed sequences of closing-price comparisons and uses a smooth candle-color gradient to show the direction and relative strength of recent momentum.

Sequence markers highlight discrete events, while the gradient provides continuous context between them. Together, they help users study how sustained price movement develops and how momentum behaves around each completed sequence.

[b]Key Features[/b]

[list]
[*][b]Price-Sequence Markers:[/b] Teal ▲ and pink ▼ markers identify completed sequences based on a fixed four-bar closing-price comparison.
[*][b]Adjustable Sequence Length:[/b] Candle Offset controls the threshold used for visible markers.
[*][b]Momentum Gradient:[/b] Candle colors transition between bearish, neutral, and bullish shades according to normalized price momentum.
[*][b]EMA Smoothing:[/b] Adjustable smoothing makes color transitions more gradual.
[*][b]Independent Displays:[/b] Bar coloring can be disabled without removing sequence markers. Momentum color does not filter marker generation.
[*][b]Customizable Palette:[/b] Bullish, bearish, and neutral colors can be adapted to your chart theme.
[/list]

[image]https://www.tradingview.com/x/3erDG7Cn/[/image]

[b]How It Works[/b]

[b]1. Closing-Price Sequences[/b]

On each bar, the indicator compares the current close with the close four bars earlier and updates two separate counts:

[list]
[*][b]Below-reference sequence → teal ▲:[/b] Each consecutive close below its own four-bars-earlier close advances the count. When the threshold is reached, a teal upward marker appears below the candle.
[*][b]Above-reference sequence → pink ▼:[/b] Each consecutive close above its own four-bars-earlier close advances the count. When the threshold is reached, a pink downward marker appears above the candle.
[/list]

A count resets to zero when its condition fails, including when the two closes are equal. After reaching the threshold, the next qualifying bar starts a new count at one. This allows repeated markers during a sustained move.

These sequences do not require every candle to close above or below the immediately preceding candle. Each comparison uses the close four bars earlier.

[b]Default example:[/b] The visible threshold is 75% of Candle Offset, rounded to the nearest integer. A Candle Offset of 10 therefore produces a marker after 8 consecutive qualifying comparisons. The four-bar reference remains fixed.

[b]2. Momentum-Based Candle Colors[/b]

The indicator measures the change between the current close and the close Gradient Length bars earlier. It normalizes that change against the largest absolute momentum reading over the same lookback window, then smooths the result with an EMA.

[list]
[*][b]Teal:[/b] Positive smoothed normalized momentum.
[*][b]Pink:[/b] Negative smoothed normalized momentum.
[*][b]Gray:[/b] Smoothed normalized momentum near zero.
[/list]

As the smoothed value moves farther from zero, the gradient moves toward the corresponding bullish or bearish color. Its intensity describes momentum relative to recent readings; it does not measure volume, signal accuracy, or the probability of a profitable trade. Colors can differ from a candle's open-to-close direction.

[b]Reading the Annotated Example[/b]

The chart illustrates three important relationships:

[list]
[*]The pink marker identifies a completed above-reference sequence.
[*]The teal markers during the decline show that sequence completion can be followed by further falling prices.
[*]The teal candle colors on the right show positive smoothed momentum, independently of the marker calculation.
[/list]

An upward marker can appear while momentum remains negative, and a downward marker can appear while momentum remains positive. The combination allows users to examine a completed sequence alongside its momentum context without treating either display as confirmation of the other.

[b]Settings Guide[/b]

[list]
[*][b]Candle Offset — default 10, minimum 4:[/b] Sets the base value from which the visible sequence threshold is calculated. Higher values require longer qualifying sequences. Because the threshold is rounded, some adjacent values produce the same result. This setting neither changes the four-bar reference nor shifts markers on the chart.
[*][b]Enable Bar Colors — default on:[/b] Shows or hides the momentum gradient while retaining markers.
[*][b]Gradient Length — default 10:[/b] Sets both the price-change lookback and the normalization window. It does not affect sequence counting.
[*][b]Gradient Smoothing — default 3:[/b] Sets the EMA smoothing length. Higher values generally produce smoother, slower color transitions.
[*][b]Bearish / Neutral / Bullish Colors:[/b] Set the gradient palette. Bearish and bullish colors also control the corresponding triangle markers.
[/list]

[b]Usage and Limitations[/b]

Use the indicator to study sustained closing-price sequences and changes in momentum alongside your own chart analysis. Support and resistance, market structure, and other context must be assessed separately; the script does not calculate them.

Despite the Candle Breakouts name, this version does not test whether price has crossed a support, resistance, or range boundary. Its triangles mark sequence completion and should not be treated as confirmed breakouts, confirmed reversals, or automatic trade entries.

Calculations use the current chart's timeframe. The script uses no future-bar references, higher-timeframe requests, or backward-shifted plots. However, the open candle's changing close can cause its marker or color to change or disappear before the bar closes. Assess completed-bar signals after the close.

The current version displays standard ▲ and ▼ markers only. It contains no built-in alert conditions, automated orders, stop-loss or take-profit levels, or strategy backtest.

[i]For educational and informational purposes only. Sequence completion and momentum readings do not guarantee future price direction or trading results.[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © SMRTAlgo

//@version=6
indicator(title = 'Candle Breakouts [SMRT Algo]', overlay = true)

// Inputs
groupMain = 'Main Settings'
Candles2 = input.int(10, 'Candle Offset', minval = 4, step = 1,group = groupMain)
Candles = math.abs(math.round(Candles2 / 4 * 3))

// Gradient Bar Colors
groupBars = 'Strength Settings'

showBarColors = input.bool(true, 'Enable Bar Colors', group = groupBars)
gradientLength = input.int(10, 'Gradient Length', minval = 1, group = groupBars)
gradientSmooth = input.int(3, 'Gradient Smoothing', minval = 1, group = groupBars)

groupArts = 'Arts'
bearColor = input.color(#e91e63, 'Bearish Color', group = groupArts)
neutralColor = input.color(color.gray, 'Neutral Color', group = groupArts)
bullColor = input.color(#0df1c6, 'Bullish Color', group = groupArts)

// Signal calculations
buySignals = 0
buySignals := close < close[4] ? buySignals[1] == Candles ? 1 : buySignals[1] + 1 : 0

sellSignals = 0
sellSignals := close > close[4] ? sellSignals[1] == Candles ? 1 : sellSignals[1] + 1 : 0

BuyOrSell = math.max(buySignals, sellSignals)

buy = bool(buySignals) and BuyOrSell == Candles
sell = bool(sellSignals) and BuyOrSell == Candles

// Secondary signal calculations
buySignals2 = 0
buySignals2 := close < close[4] ? buySignals2[1] == Candles2 ? 1 : buySignals2[1] + 1 : 0

sellSignals2 = 0
sellSignals2 := close > close[4] ? sellSignals2[1] == Candles2 ? 1 : sellSignals2[1] + 1 : 0

BuyOrSell2 = math.max(buySignals2, buySignals, sellSignals, sellSignals2)

buy2 = bool(buySignals2) and BuyOrSell2 == Candles2
sell2 = bool(sellSignals2) and BuyOrSell2 == Candles2

// Signal labels
//plotshape(buy2, style = shape.labelup, color = color.new(bullColor, 0), text = '▲+', textcolor = color.white, size = size.small, location = location.belowbar)
//plotshape(sell2, style = shape.labeldown, color = color.new(bearColor, 0), text = '▼+', textcolor = color.white, size = size.small, location = location.abovebar)

plotshape(buy, style = shape.xcross, color = #ffffff00, text = '▲', textcolor = color.new(bullColor, 0), size = size.tiny, location = location.belowbar)
plotshape(sell, style = shape.xcross, color = #ffffff00, text = '▼', textcolor = color.new(bearColor, 0), size = size.tiny, location = location.abovebar)

// Normalizr
momentum = close - close[gradientLength]
momentumRange = ta.highest(math.abs(momentum), gradientLength)
normalizedMomentum = momentumRange != 0 ? momentum / momentumRange : 0.0
smoothedMomentum = ta.ema(normalizedMomentum, gradientSmooth)

// gradiet
barGradient = smoothedMomentum >= 0 ? color.from_gradient(smoothedMomentum, 0.0, 1.0, neutralColor, bullColor) : color.from_gradient(smoothedMomentum, -1.0, 0.0, bearColor, neutralColor)

//candle colors
barcolor(showBarColors ? barGradient : na)
````
