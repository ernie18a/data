<!-- tradingview-pine-id: PUB;8acc1dc64dc24f848709f8aa30875f2f -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Heartland Previous-Day Pivot Levels

Source: https://www.tradingview.com/script/PkIxvj8d-Heartland-Previous-Day-Pivot-Levels/

## Description

This indicator calculates traditional pivot levels using the previous completed trading day’s high, low and closing price. It displays the central equilibrium pivot, R1 and R2 resistance levels, and S1 and S2 support levels. The levels update automatically at the beginning of each new trading day and can help traders identify market direction, potential support and resistance, and possible profit targets. This indicator is intended for educational and market-analysis purposes only and should not be considered financial advice.

---

## Source Code

````pine
//@version=6
indicator("Heartland Previous-Day Pivot Levels", overlay=true)

previousHigh = request.security(
     syminfo.tickerid, "D", high[1],
     lookahead=barmerge.lookahead_on)

previousLow = request.security(
     syminfo.tickerid, "D", low[1],
     lookahead=barmerge.lookahead_on)

previousClose = request.security(
     syminfo.tickerid, "D", close[1],
     lookahead=barmerge.lookahead_on)

// Traditional pivot-point calculations
pivot = (previousHigh + previousLow + previousClose) / 3

r1 = (2 * pivot) - previousLow
s1 = (2 * pivot) - previousHigh

r2 = pivot + (previousHigh - previousLow)
s2 = pivot - (previousHigh - previousLow)

// Display levels
plot(pivot, "Equilibrium Pivot", color=color.yellow,
     linewidth=3, style=plot.style_stepline)

plot(r1, "R1 Resistance", color=color.red,
     linewidth=2, style=plot.style_stepline)

plot(r2, "R2 Resistance", color=color.maroon,
     linewidth=2, style=plot.style_stepline)

plot(s1, "S1 Support", color=color.lime,
     linewidth=2, style=plot.style_stepline)

plot(s2, "S2 Support", color=color.green,
     linewidth=2, style=plot.style_stepline)
````
