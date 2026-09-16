<!-- tradingview-pine-id: PUB;35956547c1c64248b5027b793e99b297 -->
<!-- tradingview-pine-version: 4.0 -->
<!-- tradingviewscripts-format: 1 -->
# Stan Weinstein Power Zone (Screener Ready)

Source: https://www.tradingview.com/script/uWhSr7rk-Stan-Weinstein-Power-Zone-Screener/

## Description

Sure — here's the short version:

**What it does:** A Pine v6 indicator that checks price against Stan Weinstein's classic 30-period MA (default: weekly timeframe). If price is above the MA → **Power Zone**. Below it → **No Power Zone**.

**Screener part:** You paste a comma-separated list of stocks (up to 39 per copy) into an input box. The script loops through all of them using `request.security()` — something only possible in Pine v6 — pulls each stock's price and MA, and sorts them into a table with Power Zone stocks on top.

**Alerts:** Fires automatically whenever a stock newly crosses into (or out of) the Power Zone. You just set up one TradingView alert on "Any alert() function call" and it covers every stock in your list.

**Bonus:** Also plots the MA and tints the chart background green/red for whatever symbol you're currently viewing.

---

## Source Code

````pine
//@version=6
indicator("Stan Weinstein Power Zone (Screener Ready)", overlay=true)

grpMA  = "Weinstein Trend Indicator"
maLen  = input.int(30, "MA Length", minval=5, group=grpMA)
maTF   = input.timeframe("W", "MA Timeframe", group=grpMA)
maType = input.string("SMA", "MA Type", options=["SMA", "EMA"], group=grpMA)

f_ma(len, mtype) => mtype == "EMA" ? ta.ema(close, len) : ta.sma(close, len)

ma = request.security(syminfo.tickerid, maTF, f_ma(maLen, maType))

// ---------------- Core conditions ----------------
aboveMA   = close > ma
belowMA   = close < ma
powerZone = aboveMA ? 1 : 0
distPct   = (close - ma) / ma * 100

// ---------------- Plots (Screener columns/filters) ----------------
plot(ma, "Weinstein MA", color = powerZone == 1 ? color.lime : color.red)
plot(powerZone, "Power Zone (1=Yes / 0=No)")
plot(aboveMA ? 1 : 0, "Above Stan Indicator (1=Yes / 0=No)")
plot(belowMA ? 1 : 0, "Below Stan Indicator (1=Yes / 0=No)")
plot(distPct, "Distance % from MA")

bgcolor(powerZone == 1 ? color.new(color.green, 90) : color.new(color.red, 90))

// ---------------- Crossover alerts (fire once, on the flip) ----------------
bullCross = ta.crossover(close, ma)
bearCross = ta.crossunder(close, ma)

if bullCross
    alert(syminfo.ticker + " entered POWER ZONE", alert.freq_once_per_bar_close)
if bearCross
    alert(syminfo.ticker + " exited POWER ZONE", alert.freq_once_per_bar_close)

alertcondition(bullCross, "Entered Power Zone", "{{ticker}} entered Power Zone")
alertcondition(bearCross, "Exited Power Zone", "{{ticker}} exited Power Zone")

// ---------------- NEW: Continuous state alerts (fire every bar the state holds) ----------------
if aboveMA
    alert(syminfo.ticker + " is IN POWER ZONE", alert.freq_once_per_bar_close)
if belowMA
    alert(syminfo.ticker + " is IN NO POWER ZONE", alert.freq_once_per_bar_close)

alertcondition(aboveMA, "In Power Zone", "{{ticker}} is currently IN the Power Zone")
alertcondition(belowMA, "In No Power Zone", "{{ticker}} is currently IN the No Power Zone")
````
