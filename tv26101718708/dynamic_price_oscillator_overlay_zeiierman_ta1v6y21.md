# Dynamic Price Oscillator Overlay (Zeiierman)

- url: https://www.tradingview.com/script/TA1v6Y21-Dynamic-Price-Oscillator-Overlay-Zeiierman/
- type: indicator
- pine_id: PUB;6bcf3601825545348b7ff59d8da04e24
- version: 1.0

## Description

█ [b]Overview[/b]
[b]Dynamic Price Oscillator Overlay (Zeiierman)[/b] is a volatility-adjusted momentum overlay that transforms oscillator behavior directly onto the price chart.

Instead of displaying momentum in a separate pane, the indicator wraps a dynamic oscillator around an adaptive price anchor, allowing traders to visualize momentum expansion, contraction, and directional bias directly within price action.

The calculation combines long-term price displacement with volatility-adjusted movement and then applies Bollinger Band analysis to identify statistically stretched market conditions.

The result is a dynamic price-following structure that highlights momentum extremes, trend transitions, and overextended conditions while remaining visually integrated with the chart.
[image]https://www.tradingview.com/x/1ZVz2S8T/[/image]

█ [b]How It Works[/b]

⚪ [b]Volatility-Adjusted Price Engine[/b]
The indicator begins by measuring market volatility using True Range.
[pine]volAdjPrice = ta.ema(trueRange(high, low, close), length)[/pine]
This creates a dynamic volatility component that adapts to changing market conditions.

⚪ [b]Dual Momentum Calculation[/b]
The oscillator combines two independent measurements:

[b]• Long-term price displacement[/b]
[pine]priceChange = close - close[length][/pine]
[b]• Volatility-adjusted price movement[/b]
[pine]priceDelta = close - volAdjPrice[/pine]
These components are blended together and smoothed.
[pine]oscillator = ta.ema(math.avg(priceDelta, priceChange), smoothFactor)[/pine]
The result is a momentum engine that reacts to both directional movement and changing volatility.

⚪ [b]Dynamic Oscillator Bands[/b]
The oscillator is surrounded by two Bollinger Band structures.

Standard bands identify elevated momentum conditions while expanded bands identify extreme momentum conditions.
[pine][bbHigh, bbLow] = bollingerBands(oscillator, length * 5, 1)
[bbHighExp, bbLowExp] = bollingerBands(oscillator, length * 5, 2)[/pine]
These bands create adaptive thresholds that expand and contract as market behavior changes.

⚪ [b]Dynamic Mean[/b]
The indicator calculates a central equilibrium level using the midpoint of the expanded Bollinger Bands.
[pine]mean = math.avg(bbHighExp, bbLowExp)[/pine]
This serves as the oscillator's primary trend reference.

⚪ [b]Price Overlay Projection[/b]
Rather than plotting the oscillator separately, the indicator wraps the oscillator around a moving price anchor.
[pine]priceAnchor = ta.ema(close, anchorLength)[/pine]
The oscillator is projected directly onto the chart:
[pine]overlayOsc = priceAnchor + oscillator - mean[/pine]
This creates a momentum structure that follows price while preserving oscillator behavior.

█ [b]How to Use[/b]

⚪ [b]Dynamic Price Oscillator Overlay[/b]
• When the oscillator line remains above the Dynamic Mean, momentum conditions are generally bullish.

• When the oscillator line remains below the Dynamic Mean, momentum conditions are generally bearish.
[image]https://www.tradingview.com/x/Gwb4qHWc/[/image]
⚪[b]Mean Crosses[/b]
The Dynamic Mean acts as the primary trend reference.

[b]•  Bullish Cross:[/b]
The oscillator line crosses above the mean.

[b]•  Bearish Cross:[/b]
The oscillator line crosses below the mean.

These signals often represent transitions between bullish and bearish momentum regimes.
[image]https://www.tradingview.com/x/kQ1H8Q7t/[/image]

⚪[b]Mean Retests[/b]
The Dynamic Mean acts as the primary momentum equilibrium level.

[b]• Bullish Retest:[/b]
The price pulls back toward the mean from above and holds.

[b]• Bearish Retest:[/b]
The price rallies back toward the mean from below and rejects.

Successful retests suggest the current momentum regime remains intact and may continue in the prevailing direction.
[image]https://www.tradingview.com/x/nxU7a4wt/[/image]

⚪[b]Bollinger Breakouts[/b]
The standard Bollinger Bands identify strong momentum expansions.

[b]• Bullish Breakout:[/b]
The oscillator line closes above the upper band.

[b]• Bearish Breakout:[/b]
The oscillator line closes below the lower band.

These conditions suggest momentum is becoming unusually strong. Bullish breakouts above the upper band may indicate overbought conditions, while bearish breakouts below the lower band may indicate oversold conditions.
[image]https://www.tradingview.com/x/QxYUuZxl/[/image]

⚪[b]Expanded Bollinger Extremes[/b]
The expanded Bollinger Bands represent statistically extreme momentum conditions.

[b]•  Bullish Extreme:[/b]
The oscillator line exceeds the expanded upper band.

[b]•  Bearish Extreme:[/b]
The oscillator line exceeds the expanded lower band.

These events occur less frequently and often identify powerful directional moves or temporary exhaustion phases.
[image]https://www.tradingview.com/x/VAofpezL/[/image]

⚪[b]Momentum Context[/b]
The indicator should not be viewed as a simple overbought or oversold tool.

Instead, it measures how far momentum has deviated from its dynamic equilibrium while continuously adapting to current volatility conditions.

The interaction between the oscillator, mean, and adaptive bands provides a framework for identifying:

• Trend continuation
• Momentum expansion
• Momentum exhaustion
• Volatility shifts
• Regime transitions

The result is a price-integrated momentum model that provides both trend context and extreme-condition analysis within a single overlay.

█ [b]Related Scripts[/b]
[url=https://www.tradingview.com/script/MDtuDzTh-Dynamic-Price-Oscillator-Zeiierman/]Dynamic Price Oscillator (Zeiierman)[/url]

█ [b]Settings[/b]
[list]
[*][b]Length:[/b] Controls the primary lookback period used throughout the oscillator calculations and Bollinger Band framework.
[*][b]Smoothing Factor:[/b] Controls the responsiveness of the oscillator. Higher values produce smoother movement while lower values increase sensitivity.
[*][b]Price Anchor Length:[/b] Determines the EMA length used to anchor the overlay structure to price.
[/list]
-----------------
Disclaimer

The content provided in my scripts, indicators, ideas, algorithms, and systems is for educational and informational purposes only. It does not constitute financial advice, investment recommendations, or a solicitation to buy or sell any financial instruments. I will not accept liability for any loss or damage, including without limitation any loss of profit, which may arise directly or indirectly from the use of or reliance on such information.

All investments involve risk, and the past performance of a security, industry, sector, market, financial product, trading strategy, backtest, or individual's trading does not guarantee future results or returns. Investors are fully responsible for any investment decisions they make. Such decisions should be based solely on an evaluation of their financial circumstances, investment objectives, risk tolerance, and liquidity needs.

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © Zeiierman {
//@version=6
indicator('Dynamic Price Oscillator Overlay (Zeiierman)', overlay = true, precision = 0)
//}

// ~~ Tooltips {
var string t1 = 'Defines the main lookback period used for the oscillator and Bollinger Band calculations. Higher values create smoother, slower signals. Lower values make the oscillator more responsive to recent price movement.'
var string t2 = 'Controls the EMA smoothing applied to the Dynamic Price Oscillator. Higher values reduce noise but add delay. Lower values react faster but may produce more false signals.'
var string t3 = 'Defines the EMA length used as the price anchor for the overlay. The oscillator is wrapped around this price-based anchor so it follows the chart instead of appearing in a separate pane.'
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Inputs {
length = input.int(33, 'Length', minval = 1, group = 'Dynamic Price Oscillator', tooltip = t1)
smoothFactor = input.int(5, 'Smoothing Factor', minval = 1, group = 'Dynamic Price Oscillator', tooltip = t2)
anchorLength = input.int(33, 'Price Anchor Length', minval = 1, group = 'Overlay Settings', tooltip = t3)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ True Range Function {
trueRange(h, l, c) =>
    tr1 = h - l
    tr2 = math.abs(h - c[1])
    tr3 = math.abs(l - c[1])
    math.max(tr1, tr2, tr3)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Bollinger Bands Function {
bollingerBands(src, length, mult) =>
    basis = ta.sma(src, length)
    dev = mult * ta.stdev(src, length)
    upper = basis + dev
    lower = basis - dev
    [upper, lower]
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Volatility Adjusted Price {
volAdjPrice = ta.ema(trueRange(high, low, close), length)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Oscillator Calculation {
priceChange = close - close[length]
priceDelta = close - volAdjPrice
oscillator = ta.ema(math.avg(priceDelta, priceChange), smoothFactor)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Oscillator Bands {
[bbHigh, bbLow] = bollingerBands(oscillator, length * 5, 1)
[bbHighExp, bbLowExp] = bollingerBands(oscillator, length * 5, 2)
mean = math.avg(bbHighExp, bbLowExp)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Wrapped Price Overlay {
priceAnchor = ta.ema(close, anchorLength)

overlayOsc = priceAnchor + oscillator - mean
overlayMean = priceAnchor
overlayBBHigh = priceAnchor + bbHigh - mean
overlayBBHighExp = priceAnchor + bbHighExp - mean
overlayBBLow = priceAnchor + bbLow - mean
overlayBBLowExp = priceAnchor + bbLowExp - mean
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Plots {
p1 = plot(overlayOsc, 'Dynamic Price Oscillator Overlay', color = color.rgb(227, 161, 54), linewidth = 2)
plot(overlayMean, 'Dynamic Mean Overlay', color = color.new(#f7cb85, 0))

p2 = plot(overlayBBHigh, 'Bollinger High Overlay', color = color.new(#089981, 60))
p3 = plot(overlayBBHighExp, 'Expanded Bollinger High Overlay', color = color.new(#089981, 0))
p4 = plot(overlayBBLow, 'Bollinger Low Overlay', color = color.new(#f23645, 60))
p5 = plot(overlayBBLowExp, 'Expanded Bollinger Low Overlay', color = color.new(#f23645, 0))
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Fills {
fill(p1, p2, oscillator > bbHigh ? color.new(#089981, 80) : na)
fill(p1, p3, oscillator > bbHighExp ? color.new(#089981, 80) : na)
fill(p1, p4, oscillator < bbLow ? color.new(#f23645, 80) : na)
fill(p1, p5, oscillator < bbLowExp ? color.new(#f23645, 80) : na)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Alert Conditions {
bullCrossMean = ta.crossover(oscillator, mean)
bearCrossMean = ta.crossunder(oscillator, mean)

bullCrossBB = ta.crossover(oscillator, bbHigh)
bearCrossBB = ta.crossunder(oscillator, bbLow)

bullCrossExpandedBB = ta.crossover(oscillator, bbHighExp)
bearCrossExpandedBB = ta.crossunder(oscillator, bbLowExp)

bullReentryBB = ta.crossunder(oscillator, bbHigh)
bearReentryBB = ta.crossover(oscillator, bbLow)

bullReentryExpandedBB = ta.crossunder(oscillator, bbHighExp)
bearReentryExpandedBB = ta.crossover(oscillator, bbLowExp)

bullTrend = oscillator > mean
bearTrend = oscillator < mean

extremeBull = oscillator > bbHighExp
extremeBear = oscillator < bbLowExp

anyBullSignal = bullCrossMean or bullCrossBB or bullCrossExpandedBB or bullReentryBB or bullReentryExpandedBB
anyBearSignal = bearCrossMean or bearCrossBB or bearCrossExpandedBB or bearReentryBB or bearReentryExpandedBB
anySignal = anyBullSignal or anyBearSignal
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Alerts {
alertcondition(bullCrossMean, 'Bullish Mean Cross', 'Dynamic Price Oscillator crossed above the mean.')
alertcondition(bearCrossMean, 'Bearish Mean Cross', 'Dynamic Price Oscillator crossed below the mean.')

alertcondition(bullCrossBB, 'Bullish Bollinger Breakout', 'Dynamic Price Oscillator crossed above the upper Bollinger Band.')
alertcondition(bearCrossBB, 'Bearish Bollinger Breakout', 'Dynamic Price Oscillator crossed below the lower Bollinger Band.')

alertcondition(bullCrossExpandedBB, 'Bullish Expanded Bollinger Breakout', 'Dynamic Price Oscillator crossed above the expanded upper Bollinger Band.')
alertcondition(bearCrossExpandedBB, 'Bearish Expanded Bollinger Breakout', 'Dynamic Price Oscillator crossed below the expanded lower Bollinger Band.')

alertcondition(bullReentryBB, 'Bullish Upper Band Reentry', 'Dynamic Price Oscillator crossed back below the upper Bollinger Band.')
alertcondition(bearReentryBB, 'Bearish Lower Band Reentry', 'Dynamic Price Oscillator crossed back above the lower Bollinger Band.')

alertcondition(bullReentryExpandedBB, 'Bullish Expanded Upper Band Reentry', 'Dynamic Price Oscillator crossed back below the expanded upper Bollinger Band.')
alertcondition(bearReentryExpandedBB, 'Bearish Expanded Lower Band Reentry', 'Dynamic Price Oscillator crossed back above the expanded lower Bollinger Band.')

alertcondition(extremeBull, 'Extreme Bullish Condition', 'Dynamic Price Oscillator is above the expanded upper Bollinger Band.')
alertcondition(extremeBear, 'Extreme Bearish Condition', 'Dynamic Price Oscillator is below the expanded lower Bollinger Band.')

alertcondition(bullTrend, 'Bullish Trend Condition', 'Dynamic Price Oscillator is above the mean.')
alertcondition(bearTrend, 'Bearish Trend Condition', 'Dynamic Price Oscillator is below the mean.')

alertcondition(anyBullSignal, 'Any Bullish Signal', 'Dynamic Price Oscillator triggered a bullish alert.')
alertcondition(anyBearSignal, 'Any Bearish Signal', 'Dynamic Price Oscillator triggered a bearish alert.')
alertcondition(anySignal, 'Any Signal', 'Dynamic Price Oscillator triggered any alert.')
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
````
