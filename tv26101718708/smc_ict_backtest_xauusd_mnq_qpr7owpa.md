# SMC ICT Backtest XAUUSD + MNQ

- url: https://www.tradingview.com/script/QpR7OWpA-SMC-ICT-Backtest-XAUUSD-MNQ/
- type: strategy
- pine_id: PUB;c94173158a0d4ee6a16689d44d64606a
- version: 1.0

## Description

It's a Pine Script v5 strategy named "SMC ICT Backtest XAUUSD + MNQ" that backtests a supply/demand / Smart Money Concepts (SMC) style entry logic.
Runs with initial capital $10,000, 0.01% commission, no pyramiding, and processes orders on bar close.
Key components

Sessions: defines trading allowed only during London (07:00–10:00) or New York (12:30–16:00) session bars.
Swings: detects pivot highs/lows using ta.pivothigh / ta.pivotlow with a user input swingLen (default 5) and stores the last confirmed pivot high/low.
Liquidity sweeps:
bullSweep: current low breaks below last pivot low and the close reclaims above that pivot low (liquidity grab below support).
bearSweep: current high breaks above last pivot high and close falls back below that pivot high.
MSS (Market Structure Shift) filters:
bullMSS: bullSweep plus close > previous bar high (high[1]).
bearMSS: bearSweep plus close < previous bar low (low[1]).
FVG (Fair Value Gap) filter:
bullFVG: current low > high[2] (i.e., a gap / imbalance to the upside).
bearFVG: current high < low[2] (gap to the downside).
Entries:
Long when tradeSession AND bullMSS AND bullFVG.
Short when tradeSession AND bearMSS AND bearFVG.
Risk management:
Stop-loss for long = current bar low; for short = current bar high.
Position size default (strategy.entry) uses account sizing defaults (no explicit size defined).
Take-profit is set at Risk * rr (input; default 2.0) from entry.
Orders: entry + paired exit (strategy.exit with stop and limit for each side).
Visuals: plots triangle up/down for long/short signals.
Notes, assumptions, and cautions

The script name references XAUUSD and MNQ but contains no symbol-specific logic — it will run on whatever chart you attach it to.
Uses pivots that require swingLen bars of confirmation; results depend strongly on chart timeframe and swingLen.
Stop is set to the full low/high of the signal bar — that may be wide; position sizing should account for risk per trade.
FVG and MSS rules are implemented in a simple way (comparisons to specific bars); you may want to refine definitions for your edge.
No explicit position sizing or instrument correlation handling; add sizing rules if needed.

## Source Code

````pine
//@version=5
strategy(
     "SMC ICT Backtest XAUUSD + MNQ",
     overlay=true,
     initial_capital=10000,
     commission_type=strategy.commission.percent,
     commission_value=0.01,
     pyramiding=0,
     process_orders_on_close=true)

// ===== SETTINGS =====
swingLen = input.int(5,"Swing Length")
rr = input.float(2.0,"Risk Reward",step=0.5)

// ===== SESSIONS =====
london = not na(time(timeframe.period,"0700-1000"))
newYork = not na(time(timeframe.period,"1230-1600"))
tradeSession = london or newYork

// ===== SWINGS =====
ph = ta.pivothigh(high,swingLen,swingLen)
pl = ta.pivotlow(low,swingLen,swingLen)

var float lastHigh = na
var float lastLow = na

if not na(ph)
    lastHigh := ph

if not na(pl)
    lastLow := pl

// ===== LIQUIDITY SWEEPS =====
bullSweep = not na(lastLow) and low < lastLow and close > lastLow
bearSweep = not na(lastHigh) and high > lastHigh and close < lastHigh

// ===== MSS =====
bullMSS = bullSweep and close > high[1]
bearMSS = bearSweep and close < low[1]

// ===== FVG =====
bullFVG = low > high[2]
bearFVG = high < low[2]

// ===== ENTRIES =====
buy = tradeSession and bullMSS and bullFVG
sell = tradeSession and bearMSS and bearFVG

// ===== RISK =====
buySL = low
sellSL = high

buyRisk = close - buySL
sellRisk = sellSL - close

buyTP = close + (buyRisk * rr)
sellTP = close - (sellRisk * rr)

// ===== ORDERS =====
if buy
    strategy.entry("BUY", strategy.long)
    strategy.exit("BUY EXIT", "BUY", stop=buySL, limit=buyTP)

if sell
    strategy.entry("SELL", strategy.short)
    strategy.exit("SELL EXIT", "SELL", stop=sellSL, limit=sellTP)

// ===== VISUALS =====
plotshape(buy, style=shape.triangleup, location=location.belowbar)
plotshape(sell, style=shape.triangledown, location=location.abovebar)
````
