# Breathing VWAP ATR Bands 2

- url: https://www.tradingview.com/script/0HarrIPF-Breathing-VWAP-ATR-Bands-2/
- type: indicator
- pine_id: PUB;3c4305ac49b146d4bf6dcd0b041a1809
- version: 1.0

## Description

This indicator plots adaptive ATR bands around Session VWAP, allowing the bands to expand and contract dynamically as market volatility changes. Unlike traditional standard deviation bands, the ATR-based bands "breathe" with current price action, providing more responsive support and resistance zones. Multiple configurable ATR levels help identify potential mean reversion, profit-taking, and exhaustion areas across different market conditions. The indicator is fully customizable, making it suitable for scalping, intraday trading, and VWAP-based trading strategies.

## Source Code

````pine
//@version=6
indicator("Breathing VWAP ATR Bands", overlay=true)

// Inputs
atrLen    = input.int(14, "ATR Length", minval=1)
atrSmooth = input.int(5, "ATR Smoothing", minval=1)

mult1 = input.float(1.00, "Band 1 ATR", step=0.05)
mult2 = input.float(1.50, "Band 2 ATR", step=0.05)
mult3 = input.float(1.75, "Band 3 ATR", step=0.05)
mult4 = input.float(2.25, "Band 4 ATR", step=0.05)

show1 = input.bool(true, "Show Band 1")
show2 = input.bool(true, "Show Band 2")
show3 = input.bool(true, "Show Band 3")
show4 = input.bool(true, "Show Band 4")

// VWAP center
vwapLine = ta.vwap(hlc3)

// True breathing ATR
rawAtr = ta.atr(atrLen)
breathingAtr = ta.ema(rawAtr, atrSmooth)

// Bands
upper1 = vwapLine + breathingAtr * mult1
lower1 = vwapLine - breathingAtr * mult1

upper2 = vwapLine + breathingAtr * mult2
lower2 = vwapLine - breathingAtr * mult2

upper3 = vwapLine + breathingAtr * mult3
lower3 = vwapLine - breathingAtr * mult3

upper4 = vwapLine + breathingAtr * mult4
lower4 = vwapLine - breathingAtr * mult4

// Plots
plot(vwapLine, "VWAP", linewidth=2)

plot(show1 ? upper1 : na, "Upper 1.00 ATR")
plot(show1 ? lower1 : na, "Lower 1.00 ATR")

plot(show2 ? upper2 : na, "Upper 1.50 ATR")
plot(show2 ? lower2 : na, "Lower 1.50 ATR")

plot(show3 ? upper3 : na, "Upper 1.75 ATR")
plot(show3 ? lower3 : na, "Lower 1.75 ATR")

plot(show4 ? upper4 : na, "Upper 2.25 ATR")
plot(show4 ? lower4 : na, "Lower 2.25 ATR")
````
