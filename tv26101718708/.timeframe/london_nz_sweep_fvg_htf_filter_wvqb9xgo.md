# London NZ Sweep + FVG (HTF FILTER)

- url: https://www.tradingview.com/script/WVQB9xGo-London-NZ-Sweep-FVG-HTF-FILTER/
- type: strategy
- pine_id: PUB;47681177011c4da5b2d6dce521e23635
- version: 1.0

## Description

📊 London Sweep + Displacement + FVG Strategy (NZ Session-Based)

This strategy is a liquidity-based intraday trading model designed to capture high-probability reversals during the London session, using ICT concepts such as Asia range, liquidity sweeps, displacement, and Fair Value Gaps (FVGs).

## Source Code

````pine
//@version=5
strategy("London NZ Sweep + FVG (HTF FILTER)", 
     overlay=true,
     initial_capital=150000,
     default_qty_type=strategy.cash)

// ===== SETTINGS =====
tz = "Pacific/Auckland"
asiaSession = "1300-1900"
londonKill  = "2000-2200"
rr = input.float(3.0, "RR")
riskPercent = 1.0

// ===== HTF BIAS (1H) =====
htfClose = request.security(syminfo.tickerid, "60", close)
htfMA    = request.security(syminfo.tickerid, "60", ta.sma(close, 20))

bullBias = htfClose > htfMA
bearBias = htfClose < htfMA

// ===== SESSION =====
inAsia   = not na(time(timeframe.period, asiaSession, tz))
inLondon = not na(time(timeframe.period, londonKill, tz))

asiaStart   = inAsia and not inAsia[1]
londonStart = inLondon and not inLondon[1]

// ===== ASIA RANGE =====
var float asiaHigh = na
var float asiaLow  = na

if asiaStart
    asiaHigh := high
    asiaLow  := low

if inAsia
    asiaHigh := math.max(nz(asiaHigh, high), high)
    asiaLow  := math.min(nz(asiaLow, low), low)

// ===== STATE =====
var bool tradeTaken = false
var int sweepDir = 0

if londonStart
    tradeTaken := false
    sweepDir := 0

// ===== SWEEP =====
bullSweep = inLondon and low < asiaLow
bearSweep = inLondon and high > asiaHigh

if not tradeTaken and sweepDir == 0
    if bullSweep
        sweepDir := 1
    else if bearSweep
        sweepDir := -1

// ===== STRONG DISPLACEMENT =====
bullDisplacement = close > open and math.abs(close - open) > ta.atr(14)
bearDisplacement = close < open and math.abs(close - open) > ta.atr(14)

// ===== FVG =====
bullFVG = low > high[2]
bearFVG = high < low[2]

// ===== ENTRY WITH HTF FILTER =====
buySignal =    not tradeTaken and    inLondon and    sweepDir == 1 and    bullDisplacement and    bullFVG and    bullBias

sellSignal =    not tradeTaken and    inLondon and    sweepDir == -1 and    bearDisplacement and    bearFVG and    bearBias

// ===== POSITION SIZE (1% RISK) =====
calcQty(entry, sl) =>
    risk = math.abs(entry - sl)
    riskValue = strategy.equity * (riskPercent / 100)
    risk > 0 ? riskValue / risk : 0

// ===== EXECUTION =====
if buySignal
    entry = close
    sl = low[1]
    tp = entry + (entry - sl) * rr

    qty = calcQty(entry, sl)

    if qty > 0
        strategy.entry("BUY", strategy.long, qty=qty)
        strategy.exit("TP/SL BUY", "BUY", stop=sl, limit=tp)
        tradeTaken := true

if sellSignal
    entry = close
    sl = high[1]
    tp = entry - (sl - entry) * rr

    qty = calcQty(entry, sl)

    if qty > 0
        strategy.entry("SELL", strategy.short, qty=qty)
        strategy.exit("TP/SL SELL", "SELL", stop=sl, limit=tp)
        tradeTaken := true
````
