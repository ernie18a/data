# Turtle RVOL Filter (T-RVOL)

- url: https://www.tradingview.com/script/tfDGvZ83/
- type: indicator
- pine_id: PUB;66decab50e244249bd53f3b7479694bb
- version: 1.0

## Description

Turtle RVOL Filter (T-RVOL)

What it does
T-RVOL measures how much volume a stock is trading today compared with its recent average. It is built as a companion to Turtle-style breakout systems, to help you tell a breakout backed by real buying from one that is likely to fade.

How it works

Relative volume (RVOL) = current bar volume ÷ average volume of the previous N days (default 20). The current bar is excluded from the average, so a single high-volume day does not distort its own baseline.
Each bar is plotted as a column and colored by strength:
Green (RVOL ≥ 1.5): strong volume, the breakout is well supported.
Gray (0.75 to 1.5): normal volume, judge the setup on other criteria.
Red (RVOL < 0.75): weak volume, the breakout is less reliable.
Dashed and dotted reference lines mark the average (1.0), the strong threshold and the minimum threshold.
An on-chart legend explains the colors and shows the current RVOL value.

Inputs

Average volume length (days): default 20.
Strong volume threshold: default 1.5.
Minimum volume threshold: default 0.75.
Show legend: on/off.

How to use it
Use it alongside your breakout indicator or a screener. Look for a breakout candle with a green or gray column. Be cautious when the column is red.

Notes and limitations

On intraday sessions and on the daily chart before the close, today’s volume is still accumulating, so RVOL is typically low early in the day and rises toward the close.
RVOL is a confirmation filter, not an entry signal. It does not generate buy or sell signals.
The thresholds are starting points. Adjust them to your market and timeframe.
This script is for educational purposes only and is not financial advice.

Co-developed with Claude (Anthropic)

## Source Code

````pine
//@version=6
indicator("RVOL (Turtle)", overlay=false)

len = input.int(20, "Moyenne du volume (jours)", minval=1)
th  = input.float(1.5, "Seuil fort", step=0.25)
tl  = input.float(0.75, "Seuil minimum", step=0.25)

// moyenne des jours précédents, sans la bougie courante
avgVol = ta.sma(volume[1], len)
rvol   = avgVol > 0 ? volume / avgVol : na

col = rvol >= th ? color.new(color.lime, 0) : rvol >= tl ? color.new(color.gray, 30) : color.new(color.red, 40)

plot(rvol, "RVOL", style=plot.style_columns, color=col)
hline(1.0, "Moyenne", color=color.gray, linestyle=hline.style_dashed)
hline(th,  "Fort",    color=color.lime, linestyle=hline.style_dotted)
hline(tl,  "Minimum", color=color.red,  linestyle=hline.style_dotted)
````
