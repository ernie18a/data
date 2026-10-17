# DOUBLE MACD[jackieee]

- url: https://www.tradingview.com/script/VEoX8uQ3-DOUBLE-MACD-jackieee/
- type: indicator
- pine_id: PUB;57e37364e2594a3486d316a3ac5215c9
- version: 1.0

## Description

Description

This is a double MACD indicator based on the default MACD, designed to help identify both the higher-timeframe trend and the lower-timeframe rhythm at the same time.
The first MACD is recommended to be set to 55, 89, 1, and is used to identify the main trend on the higher timeframe. The second MACD is recommended to be set to 13, 21, 1, and is used to identify pullbacks within the larger trend, or smaller trend movements on the lower level.
In practice, the first MACD can be used to define the overall market direction, while the second MACD helps track whether a pullback is ending and whether a continuation opportunity is forming. This makes it easier to read both the larger trend and the smaller price rhythm within the same framework.

Reminder
please open the indicator style settings and untick the top “plot” line, otherwise an extra price line will appear and may affect chart readability.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © jackieeeeeeeee

//@version=6

plot(close)


indicator('DOUBLE MACD[jackieee]')

//====================
// MACD 1 Inputs
//====================
group1 = "MACD 1"

float  sourceInput1  = input.source(close, "Source", group = group1)
int    fastLenInput1 = input.int(55, "Fast length", minval = 1, group = group1)
int    slowLenInput1 = input.int(89, "Slow length", minval = 1, group = group1)
int    sigLenInput1  = input.int(1,  "Signal length", minval = 1, group = group1)
string oscTypeInput1 = input.string("EMA", "Oscillator MA type", ["EMA", "SMA"], display = display.none, group = group1)
string sigTypeInput1 = input.string("EMA", "Signal MA type", ["EMA", "SMA"], display = display.none, group = group1)

//====================
// MACD 2 Inputs
//====================
group2 = "MACD 2"

float  sourceInput2  = input.source(close, "Source", group = group2)
int    fastLenInput2 = input.int(13, "Fast length", minval = 1, group = group2)
int    slowLenInput2 = input.int(21, "Slow length", minval = 1, group = group2)
int    sigLenInput2  = input.int(1,  "Signal length", minval = 1, group = group2)
string oscTypeInput2 = input.string("EMA", "Oscillator MA type", ["EMA", "SMA"], display = display.none, group = group2)
string sigTypeInput2 = input.string("EMA", "Signal MA type", ["EMA", "SMA"], display = display.none, group = group2)

//====================
// Function
//====================
ma(float source, int length, simple string maType) =>
    switch maType
        "EMA" => ta.ema(source, length)
        "SMA" => ta.sma(source, length)

//====================
// MACD 1 Calculation
//====================
float maFast1 = ma(sourceInput1, fastLenInput1, oscTypeInput1)
float maSlow1 = ma(sourceInput1, slowLenInput1, oscTypeInput1)
float macd1   = maFast1 - maSlow1
float signal1 = ma(macd1, sigLenInput1, sigTypeInput1)

//====================
// MACD 2 Calculation
//====================
float maFast2 = ma(sourceInput2, fastLenInput2, oscTypeInput2)
float maSlow2 = ma(sourceInput2, slowLenInput2, oscTypeInput2)
float macd2   = maFast2 - maSlow2
float signal2 = ma(macd2, sigLenInput2, sigTypeInput2)

//====================
// Plot
//====================
hline(0, "Zero", #787b8680)

// MACD 1 = column / Signal 1 = line / 深红色
plot(macd1, "MACD 1", color = #ff5252, style = plot.style_columns)
plot(signal1, "Signal 1", color = #ff5252, linewidth = 2)

// MACD 2 = column / Signal 2 = line / 黑色
plot(macd2, "MACD 2", color = color.black, style = plot.style_columns)
plot(signal2, "Signal 2", color = color.black, linewidth = 2)
````
