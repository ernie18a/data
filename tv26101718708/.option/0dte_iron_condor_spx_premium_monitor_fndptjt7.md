# 0DTE Iron Condor SPX Premium Monitor

- url: https://www.tradingview.com/script/fndptJT7-0DTE-Iron-Condor-SPX-Premium-Monitor/
- type: indicator
- pine_id: PUB;0af9d3462aeb4930a426921389fce97a
- version: 1.0

## Description

So this is my first indicator for 0DTE Iron Condor SPX Premium Monitor. It takes the premium for both sides of the credit spreads and adds them to get the total. You will need the OPRA Feed so data isnt delayed. It costs only $1.50 USD so not too much for real time data. You basically set the date and the contract strikes. OPRA Feed gives real time data for options premium. You can set an alert so that If an Iron Condor breaches your stop loss, it will send an alert when premium reaches your stop loss. This is helpful in managing and controlling your losses.

## Source Code

````pine
//@version=6
indicator("0DTE Iron Condor Premium Monitor")

// ── Expiration (shared by both spreads) ──
i_year   = input.int(26, "Year (YY)", minval = 0, maxval = 99, group = "Expiration")
i_month  = input.int(6, "Month (MM)", minval = 1, maxval = 12, group = "Expiration")
i_day    = input.int(18, "Day (DD)", minval = 1, maxval = 31, group = "Expiration")

// ── Put side (the bull put spread) ──
i_shortPut = input.float(7350.0, "Short Put Strike (SELL)", step = 0.5, group = "Put Spread")
i_longPut  = input.float(7345.0, "Long Put Strike (BUY)", step = 0.5, group = "Put Spread")

// ── Call side (the bear call spread) — placeholder strikes, set to yours ──
i_shortCall = input.float(7470.0, "Short Call Strike (SELL)", step = 0.5, group = "Call Spread")
i_longCall  = input.float(7475.0, "Long Call Strike (BUY)", step = 0.5, group = "Call Spread")

i_alert = input.float(1.00, "Alert when TOTAL net credit drops to (<=)", group = "Alerts")

// ── Helpers ──
f_pad2(n) =>
    s = str.tostring(n)
    n < 10 ? "0" + s : s

f_strike(s) =>
    str.tostring(s, "#.0")

yymmdd = f_pad2(i_year) + f_pad2(i_month) + f_pad2(i_day)

// ── Build each leg's contract ticker ──
shortPutLeg  = "OPRA:SPXW" + yymmdd + "P" + f_strike(i_shortPut)
longPutLeg   = "OPRA:SPXW" + yymmdd + "P" + f_strike(i_longPut)
shortCallLeg = "OPRA:SPXW" + yymmdd + "C" + f_strike(i_shortCall)
longCallLeg  = "OPRA:SPXW" + yymmdd + "C" + f_strike(i_longCall)

// ── Composite spread tickers: Short minus Long, positive = credit collected ──
putSpreadTicker  = shortPutLeg + "-" + longPutLeg
callSpreadTicker = shortCallLeg + "-" + longCallLeg

putCredit  = request.security(putSpreadTicker, timeframe.period, close, ignore_invalid_symbol = true)
callCredit = request.security(callSpreadTicker, timeframe.period, close, ignore_invalid_symbol = true)

totalCredit = putCredit + callCredit

plot(totalCredit, title = "Total IC Net Credit", color = color.new(color.orange, 0), linewidth = 2)
plot(putCredit, title = "Put Spread Credit", color = color.new(color.teal, 0))
plot(callCredit, title = "Call Spread Credit", color = color.new(color.fuchsia, 0))
hline(i_alert, title = "Alert Level", color = color.red, linestyle = hline.style_dashed)

alertcondition(totalCredit <= i_alert, title = "Iron Condor Credit Alert", message = "Total iron condor net credit has reached your alert level")

// ── On-chart readout for verifying the constructed tickers ──
var table infoTable = table.new(position.top_right, 1, 3, bgcolor = color.new(color.black, 70))
if barstate.islast
    table.cell(infoTable, 0, 0, "Total Credit: " + str.tostring(totalCredit, "#.00"), text_color = color.white)
    table.cell(infoTable, 0, 1, "Put: " + str.tostring(putCredit, "#.00") + "  (" + putSpreadTicker + ")", text_color = color.white)
    table.cell(infoTable, 0, 2, "Call: " + str.tostring(callCredit, "#.00") + "  (" + callSpreadTicker + ")", text_color = color.white)
````
