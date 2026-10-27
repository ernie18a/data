# Volatility Hull Ribbon [BackQuant]

- url: https://www.tradingview.com/script/rcEzc5c7-Volatility-Hull-Ribbon-BackQuant/
- type: indicator
- pine_id: PUB;8fdc77be4d5243178bb0834b2399bc95
- version: 1.0

## Description

[b]Volatility Hull Ribbon [BackQuant][/b]

[b]Overview[/b]  
Volatility Hull Ribbon is a trend-following overlay built from a Hull-style moving average that replaces traditional volume weighting with [b]volatility weighting[/b]. Instead of weighting price by traded volume, this indicator weights price by the absolute True Range of each bar, meaning bars with larger range expansion have more influence on the final trend estimate.

The goal is to create a smoother but responsive trend line that pays more attention to bars where the market actually moved with force. It then plots this volatility-weighted Hull structure as either a clean line or a ribbon-style band, with gradient fill, candle coloring, and long/short flip markers.

At a high level, the indicator does three things:
[list]
[*]Builds a volatility-weighted moving average using True Range as the weighting source.
[*]Applies Hull-style lag reduction to produce a faster trend-following curve.
[*]Visualizes trend direction using slope, ribbon fill, candles, and flip signals.
[/list]

[b]Core idea[/b]  
Most moving averages treat each bar equally or weight only by time. That means a quiet candle and a high-range expansion candle can have similar influence depending on the MA type.

Volatility Hull Ribbon takes a different approach:
[list]
[*]Bars with larger True Range are treated as more important.
[*]Bars with smaller True Range have less influence.
[*]Recent bars are also weighted more heavily than older bars.
[/list]

This creates a trend estimate that responds more strongly when the market expands, while remaining smoother during lower-energy movement.

[b]What “volatility-weighted” means here[/b]  
The custom weighting function uses:
[list]
[*]Price source
[*]Absolute True Range
[*]A decreasing time weight
[/list]

For each bar inside the lookback:
[list]
[*]Weighted price contribution = source[i] * abs(True Range[i]) * recency weight
[*]Weight contribution = abs(True Range[i]) * recency weight
[/list]

Then:
[list]
[*]Volatility-weighted average = weighted price sum / weighted True Range sum
[/list]

So price movement on wide-range bars matters more than price movement on quiet bars.

[b]Why True Range is used[/b]  
True Range captures more than just high-low movement. It accounts for gaps and previous close displacement. This makes it a broader volatility proxy than simple candle range.

Using True Range as the weight means the filter gives more importance to bars where:
[list]
[*]Range expanded,
[*]Price displaced aggressively,
[*]Volatility increased,
[*]Market participation likely intensified.
[/list]

This is useful because strong trend moves often occur during volatility expansion, not during quiet drift.

[b]Hull-style construction[/b]  
The indicator then applies a Hull-style transformation to the volatility-weighted average.

The structure is:

[list]
[*]VWHMA = VWMA_TR( 2 * VWMA_TR(src, len / 2) - VWMA_TR(src, len), sqrt(len) )
[/list]

Where VWMA_TR means the custom True-Range-weighted moving average.

This follows the same logic as the classic Hull Moving Average:
[list]
[*]Use a faster half-length average.
[*]Use a slower full-length average.
[*]Subtract the lagging component.
[*]Smooth the result with sqrt(length).
[/list]

The difference is that every smoothing step is volatility-weighted instead of standard weighted-average based.

[b]Why this matters[/b]  
A classic Hull Moving Average is already designed to reduce lag. This version modifies the internal weighting so the curve becomes more sensitive to [b]volatility-backed price movement[/b].

That means:
[list]
[*]Large expansion bars can pull the filter faster.
[*]Weak low-range chop has less effect.
[*]Trend changes during strong movement can be reflected more clearly.
[/list]

[b]Trend detection[/b]  
Trend direction is based on the slope of the VWHMA:
[list]
[*]Bullish when VWHMA > VWHMA[1]
[*]Bearish when VWHMA < VWHMA[1]
[/list]

This is a simple but effective regime definition:
[list]
[*]Rising volatility-weighted Hull = bullish trend pressure.
[*]Falling volatility-weighted Hull = bearish trend pressure.
[/list]

The script uses this slope state to color:
[list]
[*]The main line,
[*]The ribbon fill,
[*]Optional candles,
[*]Signal markers.
[/list]

[b]Ribbon mode[/b]  
When “Plot as Band?” is enabled, the script creates a second line:
[list]
[*]onebar_off = WMA(VWHMA[1], 10)
[/list]

This is a delayed and smoothed version of the VWHMA. The area between the current VWHMA and this offset line becomes the ribbon.

Interpretation:
[list]
[*]Ribbon expansion shows separation between current trend structure and its delayed reference.
[*]Ribbon compression shows trend slowing or flattening.
[*]A clean flip in the ribbon often coincides with trend transition.
[/list]

The ribbon is not a volatility band. It is a [b]trend displacement ribbon[/b] built from the difference between the current VWHMA and its delayed smoothed version.

[b]Gradient fill logic[/b]  
The fill is directional:
[list]
[*]If VWHMA is above the offset line, fill intensity is stronger near the VWHMA and fades toward the offset.
[*]If VWHMA is below the offset line, the gradient reverses.
[/list]

This creates a cleaner visual than a flat fill because it emphasizes the active side of the ribbon.

In practice:
[list]
[*]Strong bright ribbon = trend line leading the delayed reference.
[*]Faded/narrow ribbon = weaker separation.
[*]Ribbon reversal = trend pressure has shifted.
[/list]

[b]Signal logic[/b]  
Signals are generated when the VWHMA slope changes direction:
[list]
[*]Long signal: crossover(VWHMA, VWHMA[1])
[*]Short signal: crossunder(VWHMA, VWHMA[1])
[/list]

This means:
[list]
[*]A long signal prints when the current VWHMA turns upward relative to the previous value.
[*]A short signal prints when the current VWHMA turns downward.
[/list]

These are slope-flip signals, not price crossover signals.

[b]Important interpretation[/b]  
A signal does not mean “buy blindly” or “sell blindly.” It means the volatility-weighted trend estimate has changed direction. The quality of the signal depends on:
[list]
[*]Market structure,
[*]Higher timeframe trend,
[*]Volatility conditions,
[*]Whether the ribbon is expanding or compressing.
[/list]

[b]Candle coloring[/b]  
When enabled, candles are painted according to the VWHMA slope:
[list]
[*]Bullish slope = long color.
[*]Bearish slope = short color.
[/list]

This makes the indicator easier to read as a regime overlay. You can quickly see when the market is consistently aligned with the volatility-weighted trend.

[b]How to use it[/b]

[b]1) Trend filter[/b]  
Use the VWHMA color as a bias filter:
[list]
[*]Only favor longs when the VWHMA is rising.
[*]Only favor shorts when the VWHMA is falling.
[/list]

[b]2) Trend transition tool[/b]  
Slope flips can identify early trend shifts:
[list]
[*]Long marker = VWHMA has turned upward.
[*]Short marker = VWHMA has turned downward.
[/list]

Because the filter is Hull-style and volatility-weighted, it can react faster than slower trend filters while still suppressing some low-range noise.

[b]3) Ribbon strength reading[/b]  
The ribbon gives additional context:
[list]
[*]Expanding ribbon = stronger separation and cleaner trend pressure.
[*]Contracting ribbon = momentum weakening.
[*]Ribbon flattening = chop or transition risk.
[/list]

[b]4) Pullback structure[/b]  
In strong trends, price often respects the VWHMA or ribbon area:
[list]
[*]Bull regime: pullbacks into the ribbon can act as support.
[*]Bear regime: rallies into the ribbon can act as resistance.
[/list]

[b]5) Volatility-backed trend confirmation[/b]  
Because large True Range bars influence the calculation more, this tool is useful for identifying whether trend changes are being supported by actual range expansion.

If price moves but the VWHMA does not respond strongly, the move may lack volatility-backed confirmation.

[b]Input guide[/b]

[b]Price Source[/b]  
Defines the input series used for the calculation. Close is standard, but hl2, hlc3, or ohlc4 can be used for smoother structural behavior.

[b]Lookback Period[/b]  
Controls the smoothing length:
[list]
[*]Lower values = faster response, more signals, more noise.
[*]Higher values = smoother trend, fewer flips, more lag.
[/list]

[b]Plot as Band[/b]  
Enables the ribbon view using the delayed smoothed VWHMA reference.

[b]Line Width[/b]  
Controls the main line thickness when not relying heavily on band mode.

[b]Show Trend Candles[/b]  
Paints candles by current trend state.

[b]Show Signals[/b]  
Toggles the long/short slope-flip markers.

[b]Strengths[/b]  
[list]
[*]Uses volatility-weighted smoothing instead of equal weighting.
[*]Combines volatility sensitivity with Hull-style lag reduction.
[*]Clean ribbon visualization for trend displacement.
[*]Simple slope-based regime interpretation.
[*]Works well as a trend overlay or bias filter.
[/list]

[b]Limitations[/b]  
[list]
[*]Slope flips can still whipsaw in sideways markets.
[*]Large wick bars can influence the filter strongly because True Range is used as weight.
[*]It does not measure volume, despite using a VWMA-style internal function.
[*]It is a trend tool, not a complete trading system.
[/list]

[b]Best use case[/b]  
Volatility Hull Ribbon works best when used as a visual trend structure layer:
[list]
[*]Use color for bias.
[*]Use ribbon expansion/compression for strength.
[*]Use slope flips for regime transitions.
[*]Use price interaction with the ribbon for pullback context.
[/list]

[b]Summary[/b]  
Volatility Hull Ribbon is a Hull-style trend overlay that replaces traditional weighting with True Range weighting, making the moving average more responsive to volatility-backed price movement. It builds a low-lag volatility-weighted Hull curve, compares it to a delayed smoothed reference to form a ribbon, and uses slope changes to define trend direction and signals. The result is a clean, responsive trend ribbon that highlights when volatility-backed trend pressure is rising, fading, or reversing.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BackQuant

import TradingView/ta/10 as ta

//@version=6
indicator("Volatility Hull Ribbon [BackQuant]", overlay = true, shorttitle = "Volatility WHMA [BackQuant]")

// Define Groups
string calc = "Calculation Settings"
string plt = "Plotting Settings"

// User Inputs
float src = input.source(close, 'Price Source', group = calc)
int len = input.int(50, 'Lookback Period', group = calc)

bool showband = input.bool(true, "Plot as Band?", group=plt)
int width = input.int(1, "Line Width", group=plt, tooltip="Only change this if you're not using it as a band.")
bool showCandles = input.bool(true, "Show Trend Candles?", group=plt)
bool showsig = input.bool(true, "Show Signals?", group=plt)
color longcol = input.color(#00ff00, "Long Color", group=plt, inline=plt)
color shortcol = input.color(#ff0000, "Short Color", group=plt, inline=plt)

vwma(_src, _period) =>
    _vol_sum = 0.0
    _tr_sum = 0.0
    for i = 0 to _period by 1
        _vol_sum := _src[i] * math.abs(ta.tr(true)[i]) * (_period + 1 - i) + _vol_sum
        _tr_sum := math.abs(ta.tr(true)[i]) * (_period + 1 - i) + _tr_sum
        _tr_sum
    _volwma = _vol_sum / _tr_sum
    _volwma

VWHMA(series float src, simple int len) =>
    VWHMA = vwma(2 * vwma(src, len / 2) - vwma(src, len), math.round(math.sqrt(len)))
    VWHMA

VWHMA = VWHMA(src, len)
onebar_off = ta.wma(VWHMA[1], 10)

// Plotting 
trend = VWHMA>VWHMA[1]?longcol:shortcol
v1 = plot(VWHMA, title = "VWHMA", color = trend, linewidth = width)
v2 = plot(showband?onebar_off:na, title = "1 Bar Offset", color = color.new(trend,100), linewidth = 1)
// fill(v1,v2, trend, "Band Mode Fill")

fill(
     v2, v1,
     VWHMA > onebar_off ? VWHMA : onebar_off,
     VWHMA > onebar_off ? onebar_off : VWHMA,
     VWHMA > onebar_off ? color.new(trend, 15) : color.new(trend, 85),
     VWHMA > onebar_off ? color.new(trend, 85) : color.new(trend, 15),
     title = "Trend Gradient")

plotcandle(open,high,low,close,"Trend Candles", trend, trend, true, bordercolor=trend,display=showCandles?display.all:display.none)

plotshape(
     ta.crossover(VWHMA,VWHMA[1]),
     offset=0,
     title="Long",
     text="𝕃",
     style=shape.triangleup,
     location=location.belowbar,
     color=trend,
     textcolor=trend, 
     size = size.tiny, 
     display=showsig?display.all:display.none
     )
plotshape(
     ta.crossunder(VWHMA,VWHMA[1]),
     offset=0,
     title="Short",
     text="𝕊",
     style=shape.triangledown,
     location=location.abovebar,
     color=trend,
     textcolor=trend, 
     size = size.tiny,
     display=showsig?display.all:display.none
     )

// Alerts
alertcondition(ta.crossover(VWHMA,VWHMA[1]),   "VWHMA Long",   "VWHMA Long {{exchange}}:{{ticker}}")
alertcondition(ta.crossunder(VWHMA,VWHMA[1]), "VWHMA Short", "VWHMA Short {{exchange}}:{{ticker}}")
````
