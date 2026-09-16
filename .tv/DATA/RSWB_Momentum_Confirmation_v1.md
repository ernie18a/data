<!-- tradingview-pine-id: PUB;0928fe6fc608442dbcd2ab0aa1354759 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# RSWB Momentum Confirmation v1

Source: https://www.tradingview.com/script/p5mSuipJ-RSWB-Momentum-Confirmation-v1/

## Description

Momentum Confirmation v1

A momentum confirmation indicator designed to complement the RSWB Bravo-Style Exhaustion indicator by helping traders identify potential reversal opportunities through RSI and MACD analysis.

Features
Relative Strength Index (RSI)
MACD Histogram
Overbought and Oversold Levels
Bullish Momentum Confirmation Signals
Bearish Momentum Confirmation Signals
Alert Conditions for Momentum Shifts
How It Works

This indicator is designed to help confirm whether momentum is beginning to shift following an extended price move.

The system monitors:

RSI for overbought and oversold conditions
MACD histogram momentum changes
Potential reversal confirmation signals
Bullish Confirmation

A bullish confirmation signal occurs when:

RSI is below 35
MACD histogram begins turning upward

Green confirmation dots highlight areas where downside momentum may be weakening and a potential reversal could be developing.

Bearish Confirmation

A bearish confirmation signal occurs when:

RSI is above 65
MACD histogram begins turning downward

Red confirmation dots highlight areas where upside momentum may be weakening and a potential reversal could be developing.

Best Used With

This indicator was specifically designed to work alongside the RSWB Bravo-Style Exhaustion indicator.

High-probability setups often occur when:

Bullish Reversal
Green 8 or 9 exhaustion count
Price near or below the lower Bollinger Band
Green momentum confirmation dot appears
Bearish Reversal
Red 8 or 9 exhaustion count
Price near or above the upper Bollinger Band
Red momentum confirmation dot appears
Intended Use

This indicator serves as a confirmation tool and is not intended to be used as a standalone trading system. Combining trend, exhaustion, and momentum analysis may help improve trade selection and timing.

Disclaimer

For educational and informational purposes only. This indicator does not provide financial advice. Always perform your own analysis and use appropriate risk management techniques before entering any trade.

---

## Source Code

````pine
//@version=6
indicator("RSWB Momentum Confirmation v1", overlay=false)

// RSI
rsiValue = ta.rsi(close, 14)

plot(rsiValue, title="RSI", color=color.yellow, linewidth=2)

hline(70, "Overbought", color=color.red)
hline(50, "Midline", color=color.gray)
hline(30, "Oversold", color=color.green)

// MACD
[macdLine, signalLine, hist] = ta.macd(close, 12, 26, 9)

plot(
     hist,
     title="MACD Histogram",
     style=plot.style_histogram,
     color=hist >= 0 ? color.lime : color.red,
     linewidth=2)

// Confirmation Signals
bullConfirm = ta.crossover(hist, hist[1]) and rsiValue < 35
bearConfirm = ta.crossunder(hist, hist[1]) and rsiValue > 65

// Bullish Dot
plotshape(
     bullConfirm,
     title="Bull Confirm",
     location=location.bottom,
     style=shape.circle,
     color=color.lime,
     size=size.small)

// Bearish Dot
plotshape(
     bearConfirm,
     title="Bear Confirm",
     location=location.top,
     style=shape.circle,
     color=color.red,
     size=size.small)

// Alerts
alertcondition(
     bullConfirm,
     title="Bullish Confirmation",
     message="RSWB Bullish Momentum Confirmation")

alertcondition(
     bearConfirm,
     title="Bearish Confirmation",
     message="RSWB Bearish Momentum Confirmation")
````
