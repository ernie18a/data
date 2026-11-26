# Nifty Futures ORB - Smart Trail

- url: https://www.tradingview.com/script/CDhXq8DM-Nifty-Futures-ORB-Smart-Trail/
- type: strategy
- pine_id: PUB;d5ea052baec34138a60f50cc31716410
- version: 1.0

## Description

Strategy Name

Nifty Futures ORB (Opening Range Breakout) with Smart Trailing Stop

Category

Intraday, trend-following breakout strategy

Instrument

Nifty 50 Futures (current month contract)

Timeframe

5-min or 1-min execution chart, with a fixed 9:15–9:30 AM opening range window (IST)

Core Logic (one-line summary)

Trade breakouts of the first 15 minutes' price range, in the direction of the breakout, with risk capped by a volatility-adjusted stop and profits protected by a stop that tightens as the trade matures.

Entry Rules

Long: Price closes above the Opening Range High (9:15–9:30 high)
Short: Price closes below the Opening Range Low (9:15–9:30 low)

Filters applied before any entry is allowed:

Opening range width must be ≤ 0.5% of spot price (skips erratic/gap-driven opens where the range itself is too wide to trade reliably)
No new entries after 2:30 PM
Only one trade per direction per day (no re-entry if price whipsaws back across the boundary)
Only one position open at a time (must exit current position before reversing)
Risk Management

Initial Stop-Loss: The wider of —

Opposite boundary of the opening range (structural invalidation — if price returns fully across the range, the breakout has failed), or
1.5 × ATR(14) from entry (volatility floor, so the stop isn't unrealistically tight on a quiet-range day)

Position Sizing: Risk a fixed % of account equity per trade, calculated from the entry-to-stop distance, rounded to whole futures lots

Trailing Stop Logic ("Smart Trail")

Three layers working together:

Step-down ATR trail — the trailing distance shrinks as the trade accumulates profit:
0 to 1R profit: trail at 3×ATR (wide, lets the trade breathe)
1R to 2R profit: trail at 2×ATR
Beyond 2R profit: trail at 1×ATR (tight, protects gains aggressively)
Structural swing trail — the stop also tracks the recent 5-candle swing high/low, and the system always uses whichever of the two trails (ATR or structural) sits closer to price
Reversal-candle backstop — if a single candle closes against the position by more than 1×ATR, the position is closed immediately on that candle, rather than waiting for the trailing stop to be touched (catches sharp V-reversals early)
Exit Rules (any one triggers a close)
Trailing stop hit
Reversal-candle backstop triggered
Hard square-off at 3:15–3:30 PM (no overnight positions, ever)

## Source Code

````pine
//@version=6
strategy("Nifty Futures ORB - Smart Trail", overlay=true, initial_capital=500000,
     default_qty_type=strategy.fixed, default_qty_value=1,
     pyramiding=0, commission_type=strategy.commission.percent, commission_value=0.03,
     slippage=1)

// ============================================================
// INPUTS
// ============================================================
orStart         = input.session("0915-0930", "Opening Range Window (IST)", group="Opening Range")
orMaxWidthPct   = input.float(0.5, "Max OR Width (% of price) — skip wider days", step=0.1, group="Opening Range")

atrLen          = input.int(14, "ATR Length", group="Risk")
initStopAtrMult = input.float(1.5, "Initial Stop = ATR x", step=0.1, group="Risk")
riskPct         = input.float(1.0, "Risk % of Equity per Trade", step=0.1, group="Risk")

// Step-down ATR trailing
trailAtrMult1   = input.float(3.0, "Trail Mult: 0-1R profit", step=0.1, group="Trailing")
trailAtrMult2   = input.float(2.0, "Trail Mult: 1R-2R profit", step=0.1, group="Trailing")
trailAtrMult3   = input.float(1.0, "Trail Mult: beyond 2R profit", step=0.1, group="Trailing")

// Structural swing trail
swingLen        = input.int(5, "Structural Swing Lookback (bars)", group="Trailing")

// Reversal candle backstop
reversalAtrMult = input.float(1.0, "Reversal Exit: single candle moves x ATR against position", step=0.1, group="Trailing")

squareOffTime   = input.session("1515-1530", "Square-Off Window (IST)", group="Session")
noNewEntryAfter = input.session("1430-1530", "No New Entries After (IST)", group="Session")

allowLongs      = input.bool(true, "Allow Longs", group="Direction")
allowShorts     = input.bool(true, "Allow Shorts", group="Direction")

// ============================================================
// SESSION / TIME HELPERS
// ============================================================
inOrWindow      = not na(time(timeframe.period, orStart, "Asia/Kolkata"))
inSquareOff     = not na(time(timeframe.period, squareOffTime, "Asia/Kolkata"))
inNoEntryWindow = not na(time(timeframe.period, noNewEntryAfter, "Asia/Kolkata"))
newDay = ta.change(time("D")) != 0

// ============================================================
// OPENING RANGE TRACKING
// ============================================================
var float orHigh = na
var float orLow  = na
var bool  orLocked = false

if newDay
    orHigh := na
    orLow  := na
    orLocked := false

if inOrWindow
    orHigh := na(orHigh) ? high : math.max(orHigh, high)
    orLow  := na(orLow)  ? low  : math.min(orLow, low)

if not inOrWindow and not orLocked and not na(orHigh)
    orLocked := true

orWidthPct = (not na(orHigh) and not na(orLow)) ? (orHigh - orLow) / close * 100 : na
orValid = orLocked and not na(orWidthPct) and orWidthPct <= orMaxWidthPct

// ============================================================
// ATR
// ============================================================
atrVal = ta.atr(atrLen)

// ============================================================
// ENTRY LOGIC
// ============================================================
var bool tookLongToday  = false
var bool tookShortToday = false

if newDay
    tookLongToday := false
    tookShortToday := false

canEnter = orValid and not inNoEntryWindow and strategy.position_size == 0

longSignal  = allowLongs  and canEnter and not tookLongToday  and close > orHigh
shortSignal = allowShorts and canEnter and not tookShortToday and close < orLow

// ============================================================
// POSITION SIZING
// ============================================================
longStopDist  = math.max(close - orLow,  atrVal * initStopAtrMult)
shortStopDist = math.max(orHigh - close, atrVal * initStopAtrMult)

riskAmount = strategy.equity * (riskPct / 100)
longQty  = longStopDist  > 0 ? math.max(1, math.round(riskAmount / longStopDist))  : 1
shortQty = shortStopDist > 0 ? math.max(1, math.round(riskAmount / shortStopDist)) : 1

// ============================================================
// STATE: entry price, R distance, stop price
// ============================================================
var float entryPrice  = na
var float initRisk    = na
var float stopPrice   = na

if longSignal
    strategy.entry("Long", strategy.long, qty=longQty)
    entryPrice := close
    initRisk   := longStopDist
    stopPrice  := close - longStopDist
    tookLongToday := true

if shortSignal
    strategy.entry("Short", strategy.short, qty=shortQty)
    entryPrice := close
    initRisk   := shortStopDist
    stopPrice  := close + shortStopDist
    tookShortToday := true

// ============================================================
// STEP-DOWN ATR TRAIL + STRUCTURAL SWING TRAIL
// ============================================================
swingHigh = ta.highest(high, swingLen)
swingLow  = ta.lowest(low, swingLen)

if strategy.position_size > 0
    profitR = (high - entryPrice) / initRisk
    trailMult = profitR >= 2 ? trailAtrMult3 : profitR >= 1 ? trailAtrMult2 : trailAtrMult1
    atrTrail = high - atrVal * trailMult
    structTrail = swingLow
    newStop = math.max(atrTrail, structTrail)
    stopPrice := math.max(stopPrice, newStop)
    strategy.exit("L-Exit", "Long", stop=stopPrice)

if strategy.position_size < 0
    profitR = (entryPrice - low) / initRisk
    trailMult = profitR >= 2 ? trailAtrMult3 : profitR >= 1 ? trailAtrMult2 : trailAtrMult1
    atrTrail = low + atrVal * trailMult
    structTrail = swingHigh
    newStop = math.min(atrTrail, structTrail)
    stopPrice := math.min(stopPrice, newStop)
    strategy.exit("S-Exit", "Short", stop=stopPrice)

// ============================================================
// REVERSAL-CANDLE BACKSTOP
// ============================================================
if strategy.position_size > 0 and (close - open) < 0 and (open - close) > atrVal * reversalAtrMult
    strategy.close("Long", comment="Reversal Candle")

if strategy.position_size < 0 and (close - open) > 0 and (close - open) > atrVal * reversalAtrMult
    strategy.close("Short", comment="Reversal Candle")

// ============================================================
// SQUARE OFF
// ============================================================
if inSquareOff and strategy.position_size != 0
    strategy.close_all(comment="Square Off")

// ============================================================
// PLOTS
// ============================================================
plot(orHigh, "OR High", color=color.blue, style=plot.style_linebr)
plot(orLow, "OR Low", color=color.blue, style=plot.style_linebr)
plot(strategy.position_size != 0 ? stopPrice : na, "Stop/Trail", color=color.red, linewidth=2, style=plot.style_circles)

plotshape(longSignal, title="Long Entry", style=shape.triangleup, location=location.belowbar, color=color.green, size=size.small)
plotshape(shortSignal, title="Short Entry", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small)
````
