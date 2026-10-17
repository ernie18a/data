# Boshmann's Volatility Hist

- url: https://www.tradingview.com/script/zQigeJ2v-Boshmann-s-Volatility-Hist/
- type: indicator
- pine_id: PUB;8aab6003e026464897ffee202deeb7e2
- version: 2.0

## Description

[b]Boshmann's Volatility Hist[/b]
The theory behind tracking normalized volatility is that market movement is highly cyclical, constantly alternating between periods of tight contraction and explosive expansion. Using raw volatility measures (like a flat Average True Range value) is flawed because the meaning of those points changes drastically as an asset's price scales up or down over time. By applying a statistical Z-Score to the ATR, we normalize the volatility relative to the asset's own historical baseline, allowing traders to objectively identify when price action is anomalously quiet (predicting a breakout) or unsustainably aggressive (predicting exhaustion or mean-reversion).

[b]How the Script Works:[/b] The script calculates a standard 14-period Average True Range (ATR) to measure current price movement. It then runs a 250-period lookback to compute the rolling mean and standard deviation of that ATR, ultimately calculating a real-time Z-Score. This Z-Score is plotted as an oscillating histogram below the chart. The script uses fixed thresholds to color the histogram bars: Green for "Quiet" (Z-score < -0.5), Yellow for "Normal" (Z-score between -0.5 and 0.5), and Red for "Volatile" (Z-score > 0.5). It also plots dotted threshold lines so you can instantly see when volatility crosses into extreme territory.

[b]Why You Should Use It:[/b] This script is the final pillar of the Boshmann's suite, engineered to be used in strict combination with the [b]Regime Counters [/b]and the [b]Market Direction Hist[/b].

While the Regime Counter gives you the structural trend and the Direction Hist gives you the momentum conviction, this Volatility Hist reveals the energy state of the market. You should use this indicator because knowing the market's speed dictates your risk management and strategy timing. For example, if you spot a long string of "Quiet" (green) volatility bars while the Regime Counter just flipped to Bullish, you have found an optimal, low-risk entry before an explosive breakout. Conversely, if you are riding a trend and this histogram spikes deep into the "Volatile" (red) zone, it serves as a mathematical warning that the market is overextended, signaling that you should tighten stops or take profits before the inevitable pullback.

## Source Code

````pine
//@version=6
indicator('Boshmann\'s Volatility Hist v2', overlay = false)

atrPeriod = input.int(14, 'ATR Period', minval = 1)
zLookback = input.int(250, 'Z-Score Lookback', minval = 2)
zLower = input.float(-0.5, 'Z-Score Lower Threshold (Quiet)')
zUpper = input.float(0.5, 'Z-Score Upper Threshold (Volatile)')

atrVal = ta.atr(atrPeriod)
atrSma = ta.sma(atrVal, zLookback)
atrStdDev = ta.stdev(atrVal, zLookback)
zScore = atrStdDev == 0 ? 0 : (atrVal - atrSma) / atrStdDev

isQuiet = zScore < zLower
isNormal = zScore >= zLower and zScore <= zUpper
isVolatile = zScore > zUpper

colorQuiet = color.new(color.green, 0)
colorNormal = color.new(color.yellow, 0) // Reverted to bright yellow
colorVolatile = color.new(color.red, 0)

volColor = isQuiet ? colorQuiet : isNormal ? colorNormal : colorVolatile

plot(zScore, style = plot.style_histogram, color = volColor, linewidth = 3, title = 'Volatility Hist')
hline(zUpper, 'Volatile Level', color = color.red, linestyle = hline.style_dotted)
hline(0, 'Average Level', color = color.gray)
hline(zLower, 'Quiet Level', color = color.green, linestyle = hline.style_dotted)
````
