# ATR Volatility Strength Indicator

- url: https://www.tradingview.com/script/QSkY36FU/
- type: indicator
- pine_id: PUB;24431e03f8094d3285d5af1ca44a79ea
- version: 1.0

## Description

# ATR Volatility Strength Indicator

The ATR Volatility Strength Indicator is designed to measure the current market volatility relative to its recent average volatility.

Instead of displaying raw ATR values, the indicator compares the current candle range against a longer-term ATR baseline and converts the result into an easy-to-read 7-level volatility scale.

## Key Features

### Relative Volatility Measurement

Measures current price expansion by comparing the latest candle range to the average ATR.

This helps traders quickly identify whether the market is:

* Quiet
* Normal
* Trending
* Expanding
* Explosive

### 7 Volatility Levels

The indicator automatically classifies volatility into seven categories:

| Level | Description              |
| ----- | ------------------------ |
| 0     | Extremely Low Volatility |
| 1     | Low Volatility           |
| 2     | Normal                   |
| 3     | Moderate Strength        |
| 4     | High Volatility          |
| 5     | Volatility Expansion     |
| 6     | Extreme Expansion        |

### Color-Coded Histogram

Each volatility level is displayed using a different color for quick visual interpretation:

* Gray → Low activity
* Green → Normal market conditions
* Blue → Strong movement
* Orange → Expansion phase
* Red → Extreme volatility

### Extreme Volatility Highlight

When volatility reaches the highest level, the background is automatically highlighted to help traders identify potential breakout or climax conditions.

## Practical Uses

### Trend Confirmation

Strong trends are often accompanied by increasing volatility levels.

### Breakout Detection

Rapid increases in volatility may indicate the beginning of a breakout phase.

### Range Market Identification

Low volatility levels can help identify accumulation, consolidation, or ranging environments.

### Trade Filtering

Can be used as a volatility filter to avoid trading during inactive market conditions.

## Suitable Markets

* Forex
* Gold (XAUUSD)
* Indices
* Stocks
* Cryptocurrency

## Recommended Timeframes

Compatible with all timeframes, from scalping to swing trading.

## Disclaimer

This indicator measures volatility only and does not provide directional signals. It should be used alongside market structure, trend analysis, and proper risk management techniques.

## Source Code

````pine
//@version=6
indicator("ATR Volatility Strength Indicator", overlay=false)

// === input ===
fastLen = input.int(1, title="fastLen")
slowLen = input.int(16, title="slowLen")

// === True Range ===
range_atr = high - low
range_atr_fast = ta.sma(range_atr, fastLen)

// === 快慢線 ===
tr_fast = range_atr_fast
atr_slow = ta.atr(slowLen)

ratio = tr_fast / atr_slow

// === 7 level ===
level =
     ratio < 0.6 ? 0 :
     ratio < 1.0 ? 1 :
     ratio < 1.2 ? 2 :
     ratio < 1.5 ? 3 :
     ratio < 1.8 ? 4 :
     ratio < 2.2 ? 5 :
                   6
// === Colors ===
levelColor =
     level == 0 ? color.new(color.gray, 30) :
     level == 1 ? color.silver :
     level == 2 ? color.new(color.green, 60) :
     level == 3 ? color.green :
     level == 4 ? color.blue :
     level == 5 ? color.orange :
                  color.red

// === Labels ===
levelName =
     level == 0 ? "Extremely Low Volatility" :
     level == 1 ? "Low Volatility" :
     level == 2 ? "Normal" :
     level == 3 ? "Moderately Strong" :
     level == 4 ? "High Volatility" :
     level == 5 ? "Volatility Expansion" :
                  "Extreme Expansion"

// === picture ===
plot(level * 50, title="ATR Volatility Strength Indicator",
     style=plot.style_columns,
     color=levelColor,
     linewidth=6)

// === Reference Lines ===
hline(0,   "Extremely Low Volatility", color=color.gray,   linestyle=hline.style_dotted)
hline(50,  "Low Volatility",           color=color.silver, linestyle=hline.style_dotted)
hline(100, "Normal",                   color=color.green,  linestyle=hline.style_dotted)
hline(150, "Moderately Strong",        color=color.green,  linestyle=hline.style_dotted)
hline(200, "High Volatility",          color=color.blue,   linestyle=hline.style_dotted)
hline(250, "Volatility Expansion",     color=color.orange, linestyle=hline.style_dotted)
hline(300, "Extreme Expansion",        color=color.red,    linestyle=hline.style_dotted)

// === background ===
bgcolor(level == 6 ? color.new(color.red,90) :
       level == 0 ? color.new(color.gray,95) : na)
````
