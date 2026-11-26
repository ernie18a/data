# VWAP Mean Reversion Strategy with Session and Volume Filter

- url: https://www.tradingview.com/script/YnLk5B6z-VWAP-Mean-Reversion-Strategy-with-Session-and-Volume-Filter/
- type: strategy
- pine_id: PUB;802f24f63b5043f59be0269c02b58b9f
- version: 1.0

## Description

[b]Description:[/b]

Volume Weighted Average Price, is one of the most referenced levels on any intraday chart. It appears on almost every institutional trading desk as a benchmark for execution quality: did you buy below VWAP or above it? Did you sell above it or below it? That institutional significance is what makes it useful as a trading level, not because it is a magical support and resistance line, but because enough participants are watching it and acting around it that it creates real, observable price behavior.

This strategy is built around one of the most consistent behaviors VWAP produces: mean reversion. In sessions with no strong directional trend, price tends to oscillate around VWAP rather than trending away from it indefinitely. When price moves significantly above VWAP in a non-trending session, institutional sellers often step in, bringing price back toward the average. When price moves significantly below VWAP, buyers who missed the open use VWAP as a reference level for value. The result is a gravitational pull back toward VWAP that is observable, repeatable, and, with the right filters, tradable.

[b]What VWAP Actually Measures[/b]

VWAP is calculated by summing the product of price and volume for every transaction during a session, then dividing by total volume. The result is the average price at which the instrument has traded during the day, weighted by how much traded at each price. A stock trading at $102 when VWAP is $100 means that, on average, every share transacted during the session changed hands at $100, and the current price is 2% above that average. Whether that premium is justified depends on whether volume is expanding in the direction of the move or shrinking, which is exactly what this strategy checks.

VWAP resets every session. This is important: VWAP is an intraday concept. Using it on daily charts or holding positions across sessions removes the institutional context that makes it meaningful. This strategy trades only within the active session for that reason.

[b]The Mean Reversion Logic[/b]

Entries fire when two conditions are met simultaneously. First, price must have moved a defined distance away from VWAP, measured in ATR multiples to scale the threshold to the instrument's actual volatility rather than a fixed percentage. Second, volume on the move away from VWAP must be declining relative to its recent average. This second condition is the critical filter. A price move away from VWAP accompanied by expanding volume suggests a real directional move with genuine participation, shorting into that is dangerous. A move away from VWAP on declining volume suggests the move is losing conviction and the pull back to VWAP is more likely.

When price is above VWAP by more than the ATR threshold and volume is declining, a short entry fires. When price is below VWAP by more than the ATR threshold and volume is declining, a long entry fires. The target for both is VWAP itself — not a fixed ATR level, but the actual VWAP value at the time the target would be hit. Stop-loss is placed at an ATR multiple beyond the entry in the opposite direction from VWAP.

[b]Session Filter[/b]

The strategy only trades between 9:45 AM and 3:15 PM ET. The first 15 minutes after the NYSE open are excluded deliberately. The opening session is when the largest institutional orders are being executed, VWAP has barely formed, and the spread between price and VWAP frequently reflects genuine price discovery rather than mean reversion opportunity. Trading into the first 15 minutes with a mean reversion approach is trading against the most aggressive order flow of the day. The final 45 minutes are excluded because end-of-day institutional rebalancing often moves price away from VWAP and keeps it there through the close, a mean reversion entry in that window frequently doesn't have time to play out before the session ends and the position needs to be closed.

[b]What This Strategy Works Best With[/b]

VWAP mean reversion is most effective on highly liquid instruments where institutional participation is consistently high, major equity indices, large-cap individual stocks, and equity index futures. On thinly traded instruments, VWAP is less meaningful as a reference level because the institutional volume that creates the gravitational pull isn't present. On crypto markets, VWAP mean reversion can work but requires adjusting the session definition since crypto trades continuously, not in defined daily sessions.

[b]What to Watch in Backtesting[/b]

Performance will vary significantly by market regime. In strongly trending sessions, where a catalyst like an earnings surprise, a Fed announcement, or a macro data release drives sustained directional movement, mean reversion against the trend produces losing trades. This is expected and not a flaw. Check the strategy's performance separately on trending days versus range-bound days if you can identify them. The most useful insight from backtesting this strategy is often not the aggregate win rate but the distribution of trade outcomes across different session types.

Shared for educational purposes and community discussion. This is not investment advice. Always backtest on your own instruments and timeframes using realistic commission assumptions before drawing any conclusions.

## Source Code

````pine
//@version=6
strategy("VWAP Mean Reversion + Session Filter", overlay=true,
     default_qty_type=strategy.percent_of_equity, default_qty_value=10,
     commission_type=strategy.commission.percent, commission_value=0.05)

// ── INPUTS ─────────────────────────────────────────────
atrLen     = input.int(14,    "ATR Length",               group="Entry")
vwapDist   = input.float(1.5, "VWAP Distance (ATR mult)", group="Entry", step=0.1)
volLen     = input.int(20,    "Volume MA Length",          group="Entry")
slMult     = input.float(1.5, "Stop ATR Multiplier",       group="Risk",  step=0.1)
startHour  = input.int(9,     "Session Start Hour (ET)",   group="Session")
startMin   = input.int(45,    "Session Start Min (ET)",    group="Session")
endHour    = input.int(15,    "Session End Hour (ET)",     group="Session")
endMin     = input.int(15,    "Session End Min (ET)",      group="Session")

// ── SESSION ─────────────────────────────────────────────
sessionStart = timestamp("America/New_York", year, month, dayofmonth, startHour, startMin, 0)
sessionEnd   = timestamp("America/New_York", year, month, dayofmonth, endHour,   endMin,   0)
inSession    = time >= sessionStart and time < sessionEnd

// ── INDICATORS ──────────────────────────────────────────
vwapVal  = ta.vwap(hlc3)
atrVal   = ta.atr(atrLen)
volAvg   = ta.sma(volume, volLen)
volWeak  = volume < volAvg

// ── DISTANCE FROM VWAP ──────────────────────────────────
aboveVwap = close > vwapVal + atrVal * vwapDist
belowVwap = close < vwapVal - atrVal * vwapDist

// ── ENTRY CONDITIONS ────────────────────────────────────
longCond  = belowVwap and volWeak and inSession and barstate.isconfirmed and strategy.position_size == 0
shortCond = aboveVwap and volWeak and inSession and barstate.isconfirmed and strategy.position_size == 0

// ── EXECUTION ───────────────────────────────────────────
if longCond
    strategy.entry("Long",  strategy.long,
         alert_message="VWAP mean reversion long — {{ticker}} @ {{close}}")
    strategy.exit("Long Exit",  "Long",
         stop  = close - atrVal * slMult,
         limit = vwapVal)

if shortCond
    strategy.entry("Short", strategy.short,
         alert_message="VWAP mean reversion short — {{ticker}} @ {{close}}")
    strategy.exit("Short Exit", "Short",
         stop  = close + atrVal * slMult,
         limit = vwapVal)

// ── VISUALS ─────────────────────────────────────────────
plot(vwapVal, "VWAP", color=color.blue, linewidth=2)
plot(vwapVal + atrVal * vwapDist, "Upper Threshold",
     color=color.new(color.red,   60), linewidth=1, style=plot.style_linebr)
plot(vwapVal - atrVal * vwapDist, "Lower Threshold",
     color=color.new(color.green, 60), linewidth=1, style=plot.style_linebr)

bgcolor(inSession ? color.new(color.blue, 97) : na)

plotshape(longCond,  location=location.belowbar, color=color.green,
     style=shape.triangleup,   size=size.small, text="MR↑")
plotshape(shortCond, location=location.abovebar, color=color.red,
     style=shape.triangledown, size=size.small, text="MR↓")
````
