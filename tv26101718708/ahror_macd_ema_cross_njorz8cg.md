# Ahror MACD + EMA Cross

- url: https://www.tradingview.com/script/njorz8Cg-Ahror-MACD-EMA-Cross/
- type: indicator
- pine_id: PUB;1104bc54196d4106a2dbf103320a499b
- version: 1.0

## Description

This indicator is a combination of the EMA and MACD indicators.

For the EMA, the 100 EMA and 25 EMA levels are used. Whenever the 25 EMA crosses the 100 EMA, a signal label appears on the chart for both bullish and bearish trend conditions.

For the MACD, a signal label appears whenever the MACD line crosses the signal line. In addition, a signal label is also displayed when the MACD crosses its zero line.

The purpose of combining these two indicators is to allow traders to see signals from both the MACD and EMA at the same time in a single indicator.

You can use this indicator on any timeframe, and its settings can be customized according to your own trading style and preferences.

**Disclaimer:** This indicator is **not financial advice** and is not intended to encourage or require anyone to trade based on its signals. It is provided solely for informational and educational purposes.

Please remember that you should never rely on a single indicator when making trading decisions. Indicators are only secondary tools that assist traders and should always be used alongside proper analysis, risk management, and a well-defined trading strategy.

I wish you success in your trading journey!

## Source Code

````pine
//@version=6
indicator("Ahror MACD + EMA Cross", "Ahror MACD+EMA", overlay=true, max_labels_count=500)

// ═══════════════════════════════════════════
//   MACD SETTINGS
// ═══════════════════════════════════════════
grMACD = "MACD Settings"
float  sourceInput  = input.source(close, "Source",         group=grMACD)
int    fastLenInput = input.int(12, "Fast length",          group=grMACD, minval=1)
int    slowLenInput = input.int(26, "Slow length",          group=grMACD, minval=1)
int    sigLenInput  = input.int(9,  "Signal length",        group=grMACD, minval=1)
string oscTypeInput = input.string("EMA", "Oscillator MA type", ["EMA","SMA"],
     group=grMACD, display=display.none)
string sigTypeInput = input.string("EMA", "Signal MA type",     ["EMA","SMA"],
     group=grMACD, display=display.none)

// ═══════════════════════════════════════════
//   EMA CROSS SETTINGS
// ═══════════════════════════════════════════
grEMA  = "EMA Cross Settings"
int    pbStep    = input.int(5,          "Backstep of Pullback",  group=grEMA)
source1          = input.source(close,   "EMA 1 Source",          group=grEMA)
int    emaLen    = input.int(25,         "EMA 1 Period",           group=grEMA)
color  emaCol    = input.color(color.blue, "EMA 1 Color",          group=grEMA)
source2          = input.source(close,   "EMA 2 Source",          group=grEMA)
int    emaLen2   = input.int(100,        "EMA 2 Period",           group=grEMA)
color  emaCol2   = input.color(color.red, "EMA 2 Color",           group=grEMA)

// ═══════════════════════════════════════════
//   MA HELPER
// ═══════════════════════════════════════════
ma(float src, int len, simple string maType) =>
    switch maType
        "EMA" => ta.ema(src, len)
        "SMA" => ta.sma(src, len)

// ═══════════════════════════════════════════
//   MACD CALCULATIONS
// ═══════════════════════════════════════════
float maFast   = ma(sourceInput, fastLenInput, oscTypeInput)
float maSlow   = ma(sourceInput, slowLenInput, oscTypeInput)
float macdLine = maFast - maSlow
float macdSig  = ma(macdLine, sigLenInput, sigTypeInput)

bool crossUp       = ta.crossover(macdLine, macdSig)
bool crossDown     = ta.crossunder(macdLine, macdSig)
bool macdAboveZero = macdLine[1] < 0 and macdLine > 0
bool macdBelowZero = macdLine[1] > 0 and macdLine < 0

// ═══════════════════════════════════════════
//   EMA CALCULATIONS
// ═══════════════════════════════════════════
float ema1 = ta.ema(source1, emaLen)
float ema2 = ta.ema(source2, emaLen2)

bool goldenCross  = ta.crossover(ema1, ema2)
bool bearishCross = ta.crossunder(ema1, ema2)

// ═══════════════════════════════════════════
//   PLOTS — EMA lines
// ═══════════════════════════════════════════
plot(ema1, "EMA 1", color=emaCol)
plot(ema2, "EMA 2", color=emaCol2)

// ═══════════════════════════════════════════
//   BACKGROUND — EMA cross flash
// ═══════════════════════════════════════════
bgcolor(
     (goldenCross or bearishCross) ? color.new(color.orange, 70) : na,
     title="EMA Cross Background")

// ═══════════════════════════════════════════
//   PLOTSHAPE — MACD signals
// ═══════════════════════════════════════════
plotshape(crossUp,
     title="Bullish Cross", text="🚀",
     style=shape.labelup,   location=location.belowbar,
     color=color.new(color.green, 70), textcolor=color.white, size=size.small)

plotshape(crossDown,
     title="Bearish Cross", text="🪂",
     style=shape.labeldown, location=location.abovebar,
     color=color.new(color.red, 70),   textcolor=color.white, size=size.small)

plotshape(macdAboveZero,
     title="MACD Above Zero", text="🪝",
     style=shape.labelup,   location=location.belowbar,
     color=color.new(color.teal, 75),  textcolor=color.white, size=size.tiny)

plotshape(macdBelowZero,
     title="MACD Below Zero", text="⚠",
     style=shape.labeldown, location=location.abovebar,
     color=color.new(color.orange, 75),textcolor=color.white, size=size.tiny)

// ═══════════════════════════════════════════
//   LABELS — EMA cross arrows
// ═══════════════════════════════════════════
if goldenCross
    label.new(bar_index, low, "🔼",
     style=label.style_label_up,
     color=color.new(color.green, 60),
     size=size.small, textcolor=color.white)

if bearishCross
    label.new(bar_index, high, "🔻",
     style=label.style_label_down,
     color=color.new(color.red, 60),
     size=size.small, textcolor=color.white)

// ═══════════════════════════════════════════
//   ALERTS
// ═══════════════════════════════════════════
alertcondition(crossUp,       "MACD Cross Up",    "MACD crossed above Signal line 🚀")
alertcondition(crossDown,     "MACD Cross Down",  "MACD crossed below Signal line 🪂")
alertcondition(macdAboveZero, "MACD Above Zero",  "MACD crossed above 0 line 🪝")
alertcondition(macdBelowZero, "MACD Below Zero",  "MACD crossed below 0 line ⚠")
alertcondition(goldenCross,   "Golden Cross",     "EMA 25 crossed above EMA 100!")
alertcondition(bearishCross,  "Bearish Cross",    "EMA 25 crossed below EMA 100!")
````
