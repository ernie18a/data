# Risk Co-Pilot | Position Sizing & Volatility Risk

- url: https://www.tradingview.com/script/BZ0wT7v2/
- type: indicator
- pine_id: PUB;f422b938f52b47fd914ad7eed783658c
- version: 1.0

## Description

A position-sizing and volatility-risk tool. You enter your account size and risk percent per trade; it computes how much to risk and how large a position that implies, plus a volatility state light. It does NOT generate buy or sell signals.

What it shows
- Risk $ for your chosen account size and risk percent
- ATR-based stop distance and the resulting long/short stop levels
- Position size in units so that hitting the stop loses exactly your chosen risk percent
- Volatility risk state (Normal / Elevated / Caution) from the ATR percentile, a reminder to size down when volatility is high

Honest by design
- No buy/sell signals, no auto-execution. It sizes risk; you decide and execute.
- Non-repainting: every value is a function of confirmed bars.
- The position size assumes a 1:1 price-to-PnL instrument. Adjust for pip value (forex) or point value (futures).

Open-source and MIT licensed.

Disclaimer: impersonal educational and risk tool. This is not investment advice, not a personalised recommendation, and carries no performance guarantee. Past results do not predict future results. You are solely responsible for your own trading decisions.

## Source Code

````pine
//@version=6
indicator("Risk Co-Pilot | Position Sizing & Volatility Risk", overlay = true)
// Disclaimer: impersonal educational/analytics tool, not investment advice, no
// performance guarantees, no buy/sell signals, no auto-execution.

acct      = input.float(10000, "Account Size", minval = 0)
riskPct   = input.float(1.0, "Risk % per Trade", minval = 0, step = 0.1)
atrLen    = input.int(14, "ATR Length", minval = 1)
stopMult  = input.float(2.0, "Stop = ATR x", minval = 0.1, step = 0.1)
volLook   = input.int(100, "Vol Regime Lookback", minval = 10)
showStops = input.bool(true, "Show Suggested Stops")

atr       = ta.atr(atrLen)
stopDist  = atr * stopMult
riskAmt   = acct * riskPct / 100.0
posSize   = stopDist > 0 ? riskAmt / stopDist : na
longStop  = close - stopDist
shortStop = close + stopDist

volRank   = ta.percentrank(atr, volLook)
lightCol  = volRank >= 80 ? color.red : volRank >= 50 ? color.orange : color.green
lightTxt  = volRank >= 80 ? "CAUTION  size down" : volRank >= 50 ? "ELEVATED" : "NORMAL"

plot(showStops ? longStop : na, "Long Stop", color = color.new(color.green, 0), style = plot.style_linebr)
plot(showStops ? shortStop : na, "Short Stop", color = color.new(color.red, 0), style = plot.style_linebr)

var table t = table.new(position.top_right, 2, 7, border_width = 1)
if barstate.islast
    table.cell(t, 0, 0, "Risk Co-Pilot", text_color = color.white, bgcolor = color.gray)
    table.cell(t, 1, 0, "", bgcolor = color.gray)
    table.cell(t, 0, 1, "Risk $")
    table.cell(t, 1, 1, str.tostring(riskAmt, "#,###.##"))
    table.cell(t, 0, 2, "Stop dist (ATRx)")
    table.cell(t, 1, 2, str.tostring(stopDist, "#.#####"))
    table.cell(t, 0, 3, "Size (units)")
    table.cell(t, 1, 3, str.tostring(posSize, "#,###.##"))
    table.cell(t, 0, 4, "Long stop")
    table.cell(t, 1, 4, str.tostring(longStop, "#.##"))
    table.cell(t, 0, 5, "Short stop")
    table.cell(t, 1, 5, str.tostring(shortStop, "#.##"))
    table.cell(t, 0, 6, "Risk state")
    table.cell(t, 1, 6, lightTxt, bgcolor = lightCol, text_color = color.white)
````
