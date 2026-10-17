# Bollinger Bands Breakout Oscillator

- url: https://www.tradingview.com/script/3hsXe2jd-Bollinger-Bands-Breakout-Oscillator/
- type: indicator
- pine_id: PUB;b21afddcde8d4bbab4afb56a9bc204b7
- version: 1.0

## Description

[image]https://www.tradingview.com/x/Q9ddEBsc/[/image]

A Bollinger-style volatility oscillator that measures bullish and bearish breakout pressure when price expands beyond the upper or lower band.

Bollinger Breakout Pressure Oscillator is a momentum and volatility-based oscillator designed to measure bullish and bearish pressure outside a Bollinger-style volatility envelope.

The indicator uses an EMA as the central baseline and calculates upper and lower bands using standard deviation. Instead of simply showing whether price is above or below the bands, it measures how much price has expanded beyond the upper or lower band over a selected lookback period.

Bullish pressure is calculated when price pushes above the upper band.
Bearish pressure is calculated when price pushes below the lower band.

The result is displayed as two separate oscillator readings:

- Bullish Breakout Pressure
- Bearish Breakout Pressure

A higher bullish reading suggests stronger upside expansion beyond the upper volatility band.
A higher bearish reading suggests stronger downside expansion beyond the lower volatility band.

The midline at 50 can be used as a reference zone to evaluate whether breakout pressure is becoming more significant.

This tool can help traders identify:

- Volatility expansion
- Bullish breakout pressure
- Bearish breakout pressure
- Momentum continuation
- Exhaustion after strong moves
- Directional imbalance outside the bands

Best used with price action, volume, VWAP, support and resistance, session structure, or trend filters. This indicator is not designed to predict reversals or guarantee breakout continuation. It should be used as a pressure-reading tool, not as a standalone trading system.

How it works:

The indicator builds a volatility envelope using an EMA baseline and standard deviation bands. It then compares price against the upper and lower bands over the selected lookback period.

When price moves above the upper band, bullish breakout pressure increases.
When price moves below the lower band, bearish breakout pressure increases.

The oscillator normalizes this pressure into a percentage-style reading, making it easier to compare breakout strength across different market conditions.

Inputs:

Length:
Controls the lookback period used for the EMA, standard deviation, and pressure calculation.

Multiplier:
Controls the width of the volatility bands. Higher values create wider bands and require stronger movement to register breakout pressure.

Source:
Defines the price source used in the calculation.

Bullish Color:
Sets the color for bullish breakout pressure.

Bearish Color:
Sets the color for bearish breakout pressure.

Limitations:

- Strong readings may appear after a move is already extended.
- Low readings do not always mean the market is inactive.
- The oscillator does not provide automatic entries, exits, stop loss, or take profit levels.
- Breakout pressure can fail during fake breakouts or sharp reversals.
- It should be combined with market structure, volume, or trend context.

## Source Code

````pine
//@version=5
indicator("Bollinger Bands Breakout Oscillator", "BBands BO ")
//------------------------------------------------------------------------------
//Settings
//------------------------------------------------------------------------------
length = input(14)

mult   = input(1.)

src    = input(close)

//Style
bull_css = input(#089981, 'Bullish Color'
  , group = 'Style')

bear_css = input(#f23645, 'Bearish Color'
  , group = 'Style')

//------------------------------------------------------------------------------
//Calculation
//------------------------------------------------------------------------------
stdev = ta.stdev(src, length) * mult
ema   = ta.ema(src, length)

upper = ema + stdev
lower = ema - stdev

bull = 0.
bear = 0.
bull_den = 0.
bear_den = 0.

for i = 0 to length-1
    bull += math.max(src[i] - upper[i], 0)
    bear += math.max(lower[i] - src[i], 0)
    
    bull_den += math.abs(src[i] - upper[i])
    bear_den += math.abs(lower[i] - src[i])
    
bull := bull/bull_den*100
bear := bear/bear_den*100

//------------------------------------------------------------------------------
//Plots
//------------------------------------------------------------------------------
bull_grad = color.from_gradient(bull, 0, 100
  , color.new(bull_css, 100)
  , color.new(bull_css, 50))

bear_grad = color.from_gradient(bear, 0, 100
  , color.new(bear_css, 100)
  , color.new(bear_css, 50))

plot0 = plot(bull
  , color = bull == 0 ? na : bull_css)

plot1 = plot(bear
  , color = bear == 0 ? na : bear_css)

plot2 = plot(0
  , color    = na
  , editable = false)

hline(50, 'Midline')

fill(plot0, plot2
  , color = bull_grad)

fill(plot1, plot2
  , color = bear_grad)
````
