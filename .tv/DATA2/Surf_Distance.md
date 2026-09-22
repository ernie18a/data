<!-- tradingview-pine-id: PUB;53aaba8d1a004c5588250d2ba9eb1602 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Surf Distance

Source: https://www.tradingview.com/script/ZT3HjVyz-Surf-Distance/

## Description

Qullamaggie Surfing the EMA
The median for Qullamaggie is  0.110 

The measurement

Take the entry price and subtract the 10-day average. That gives the distance in dollars.
Divide by the stock's typical daily range (probably ATR or average daily range in your system; check which one you used). That gives the distance in "daily ranges."

Dividing by the range makes stocks comparable. A 30-cent gap is huge for a quiet $10 stock and meaningless for a volatile $300 one. Measured in daily ranges, both are on the same scale.

Reading 0.110: The median entry was 0.11 of one day's range above the 10-day average. A normal day's wiggle is one full range, so 0.11 is well inside the noise. Price was essentially sitting on the average when the entry triggered. Half the entries were closer than that (or below it) and half were further.

Example

10-day average: $50.00
Daily range (ATR): $2.50
Entry: $50.275

Distance = ($50.275 − $50.00) / $2.50 = 0.110. You paid 27.5 cents above the average, on a stock that moves $2.50 on a normal day. That's an entry at the average.

Compare an entry at $55.00: ($55.00 − $50.00) / $2.50 = 2.0. The stock is two full daily ranges above its average, which is extended and usually a chase.

Why it matters: The finding says the Qullamaggie entries are mostly pullbacks or consolidations that come back to the 10-day (the "surf" the average idea), not chases of extended moves. It also gives you a testable rule: entries far above 0 (say, above 1 range) are outside the profile that the system's results come from.

---

## Source Code

````pine
//@version=6
indicator("Surf Distance", shorttitle="Surf", overlay=true, precision=3)

// Inputs
maLen    = input.int(10, "MA length (EMA)", minval=1)
adrLen   = input.int(20, "ADR length", minval=1)
tf       = input.timeframe("D", "Timeframe for MA and ADR")
nearThr  = input.float(0.25, "On-the-surf band (+/-)", minval=0.0, step=0.05)
extThr   = input.float(1.0, "Extended above", minval=0.0, step=0.25)

// 10-day EMA and 20-day ADR (average of high minus low), pulled from the chosen timeframe
[ma, adr] = request.security(syminfo.tickerid, tf, [ta.ema(close, maLen), ta.sma(high - low, adrLen)])

// Surf Distance = (price - MA) / ADR
surf = adr > 0 ? (close - ma) / adr : na

// Colour only affects the status-line number
col = surf > extThr ? color.red : surf > nearThr ? color.orange : surf >= -nearThr ? color.green : color.blue

// Nothing is drawn on the chart: the value shows in the status line and Data Window only
plot(surf, "Surf Distance", color=col, display=display.status_line + display.data_window)
````
