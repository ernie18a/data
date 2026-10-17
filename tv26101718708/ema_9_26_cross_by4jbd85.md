# EMA 9 / 26 Cross 

- url: https://www.tradingview.com/script/by4jBd85-EMA-9-26-Cross/
- type: indicator
- pine_id: PUB;fbbab93ced3549d49a82a0e6e214493a
- version: 1.0

## Description

HOSAM
EMA 9 / 26 Cross Indicator

This indicator combines two exponential moving averages (EMA 9 and EMA 26) into one clean and simple trading tool.

Features:
	•	Detects bullish and bearish EMA crossovers
	•	Displays a green X for bullish crossovers
	•	Displays a red X for bearish crossovers
	•	Works on all timeframes
	•	Lightweight and clean chart design
	•	Suitable for scalping, intraday trading, and swing trading

How it works:
	•	A bullish signal appears when EMA 9 crosses above EMA 26
	•	A bearish signal appears when EMA 9 crosses below EMA 26

The X markers are plotted close to the crossover area for better visual accuracy and cleaner chart reading.

This indicator can be used as:
	•	Trend confirmation
	•	Entry timing tool
	•	Momentum shift detection
	•	EMA crossover strategy assistant

Best used together with:
	•	Volume analysis
	•	Support and resistance
	•	Trendlines
	•	Higher timeframe confirmation

Educational use only. No

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © h0s1m001

//@version=6

//@version=5
indicator("EMA 9 / 26 Cross", overlay=true)

// إعدادات المتوسطات
fastEMA = ta.ema(close, 9)
slowEMA = ta.ema(close, 26)

// رسم خطوط EMA
plot(fastEMA, title="EMA 9")
plot(slowEMA, title="EMA 26")

// شروط التقاطع
bullCross = ta.crossover(fastEMA, slowEMA)
bearCross = ta.crossunder(fastEMA, slowEMA)

// X أخضر للشراء
plotshape(
     bullCross ? fastEMA : na,
     title="Buy X",
     style=shape.xcross,
     location=location.absolute,
     size=size.normal,
     color=color.blue
)

// X أحمر للبيع
plotshape(
     bearCross ? fastEMA : na,
     title="Sell X",
     style=shape.xcross,
     location=location.absolute,
     size=size.normal,
     color=color.blue
)

// تنبيهات
alertcondition(
     bullCross,
     title="Bullish Cross",
     message="EMA 9 crossed above EMA 26"
)

alertcondition(
     bearCross,
     title="Bearish Cross",
     message="EMA 9 crossed below EMA 26"
)
````
