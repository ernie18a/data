# 5 star Setup signals-SaahilDandekar

- url: https://www.tradingview.com/script/BsdUnrwX-5-star-Setup-signals-SaahilDandekar/
- type: indicator
- pine_id: PUB;2726f434e7034db2b7536819d63d1b5a
- version: 1.0

## Description

Gold BB Air Candle Reversal Strategy

This strategy is designed for aggressive mean-reversion scalping on Gold (XAUUSD), primarily optimized for the 3-minute timeframe using Bollinger Bands.

The core idea is simple:
When price becomes extremely stretched outside the Bollinger Bands, the market often pulls back toward equilibrium. This setup attempts to capture that reversion move with defined risk and adaptive profit-taking.

Indicators Used
Bollinger Bands
Length: 20
Standard Deviation: 2

No additional indicators are required.

Setup Conditions
Buy Setup

A valid buy setup forms when:

A candle closes completely below the lower Bollinger Band
The candle must not touch the band at all
Entire candle body and wick must remain outside the band

This represents extreme downside expansion.

Sell Setup

A valid sell setup forms when:

A candle closes completely above the upper Bollinger Band
The candle must not touch the band at all
Entire candle body and wick must remain outside the band

This represents extreme upside expansion.

Entry Rules
Buy Entry
Entry triggers when price crosses above the high of the setup candle
Entry happens intrabar
No candle close confirmation is required
Sell Entry
Entry triggers when price crosses below the low of the setup candle
Entry happens intrabar
No candle close confirmation is required
Stop Loss
Buy Trade
Stop loss is placed below the low of the setup candle
A configurable buffer is added
Sell Trade
Stop loss is placed above the high of the setup candle
A configurable buffer is added

The buffer helps reduce premature stop-outs caused by spread and volatility spikes.

Take Profit Logic

The strategy uses dynamic profit-taking.

Two targets are calculated:

1:1 Risk-to-Reward target
Bollinger Band median line (middle band)

Whichever target is reached first becomes the active take-profit level.

This allows the system to adapt automatically to different volatility conditions.

Breakeven Rule

Once price reaches 70% of the total distance toward the take-profit target:

Stop loss is automatically moved to entry price (breakeven)

This helps protect capital during reversals that fail before reaching full target.

Market Type

This strategy performs best during:

ranging markets
slow expansion conditions
liquidity sweeps
overextended intraday moves

Performance may degrade during:

strong trend continuation
high-impact news events
aggressive momentum sessions
Recommended Market
XAUUSD (Gold)
3-Minute Timeframe
Important Notes

This is not a trend-following strategy.
It is a volatility exhaustion and mean-reversion model.

The strategy intentionally fades extreme price extensions, which means risk management and discipline are critical.

## Source Code

````pine
//@version=5
indicator("5 star Setup signals-SaahilDandekar", overlay=true)

bbLength = input.int(20, title="BB Length")
bbMult = input.float(2.0, title="BB Multiplier")

basis = ta.sma(close, bbLength)
dev = bbMult * ta.stdev(close, bbLength)

upper = basis + dev
lower = basis - dev

plot(basis, title="Middle BB", color=color.yellow, linewidth=2)
plot(upper, title="Upper BB", color=color.red)
plot(lower, title="Lower BB", color=color.green)

sellSignal = low > upper
buySignal = high < lower

plotshape(buySignal, title="BUY", location=location.belowbar, style=shape.labelup, color=color.green, text="BUY", textcolor=color.white)

plotshape(sellSignal, title="SELL", location=location.abovebar, style=shape.labeldown, color=color.red, text="SELL", textcolor=color.white)

alertcondition(buySignal, title="BUY ALERT", message="BUY Signal")

alertcondition(sellSignal, title="SELL ALERT", message="SELL Signal")
````
