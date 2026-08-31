<!-- tradingview-pine-id: PUB;317d5f027bba442f8ef8ebe63aefc371 -->
<!-- tradingviewscripts-format: 1 -->
# Fair Value Gap + Break of Structure

Source: https://www.tradingview.com/script/jyhTizLX-Fair-Value-Gap-Strategy-with-Break-of-Structure-Confirmation/

## Description

Description:
Fair Value Gaps are one of the most discussed concepts in modern price action trading, and one of the most misunderstood. Most traders who learn about FVGs start marking every three-candle imbalance they can find and entering every time price returns to one. The results are typically poor — not because the concept is wrong, but because the context around the FVG determines almost everything about whether it will hold or fail.

This strategy is built around one specific idea: a Fair Value Gap is only worth trading when it forms in the direction of a confirmed Break of Structure. Without that structural context, an FVG is just a gap in price — interesting, but not tradable on its own.

What a Fair Value Gap actually is
A Fair Value Gap forms when three consecutive candles create a price zone that the middle candle's body does not overlap. Specifically: the high of the first candle is below the low of the third candle (bullish FVG), or the low of the first candle is above the high of the third candle (bearish FVG). The gap represents a price range where no two-way trading occurred — price moved through it so quickly, driven by aggressive one-directional orders, that the normal auction process was bypassed. When price returns to that zone, the institutional logic is that unfilled orders from the original move are still resting there, creating a reaction point.

The reason most traders misuse FVGs is that they treat them as generic support and resistance. They are not. An FVG formed during a weak, low-conviction move in a choppy market has almost no institutional significance. An FVG formed during an aggressive displacement move that also breaks market structure, that is a different animal entirely.

What a Break of Structure is
Break of Structure (BOS) is the confirmation that the current swing direction has been validated by price taking out the most recent swing high (in an uptrend) or swing low (in a downtrend). In a series of higher highs and higher lows, each break above the prior swing high is a BOS confirming the uptrend. A BOS tells you the market is making a committed directional statement, not oscillating within a range.

The reason BOS matters for FVG trading is displacement. An aggressive candle that creates a BOS almost always leaves a Fair Value Gap behind it, the candle moves so fast that a price imbalance forms in its wake. That FVG is structurally significant because it was created by the same momentum that just confirmed the trend direction. When price returns to fill that gap, it is returning to the exact zone where institutional momentum entered the market and structural commitment was made.

How the strategy works
The strategy identifies bullish FVGs formed during upward BOS moves and bearish FVGs formed during downward BOS moves. A bullish FVG entry fires when price retraces into the gap after a confirmed bullish BOS, the high of candle one is plotted as the upper boundary, and price closing back inside that zone triggers the long entry. The stop is placed below the low of the FVG zone. The target is set at a 2x ATR multiple from the entry, scaled to current volatility rather than a fixed distance.

The BOS confirmation uses swing high and swing low detection with a defined lookback period. Only FVGs that form within a specified number of bars after a BOS are considered valid, older gaps that formed long before the most recent structural move are not traded, since the institutional orders that created them have likely already been filled or cancelled.

Why FVGs fail and how this addresses it
The most common failure mode for FVG strategies is trading imbalances in ranging, low-conviction markets where no structural context exists. The BOS filter directly addresses this by requiring that a swing high or low has been broken with enough conviction to register a structural shift before any FVG is considered valid. The second most common failure is holding positions through the entire FVG zone hoping for a reversal, this strategy enters at the gap boundary and exits at a defined ATR target rather than waiting for a full reversal, which keeps the average trade duration shorter and reduces exposure to the next structural shift invalidating the position.

What to examine in backtesting
FVG strategies are particularly sensitive to the lookback period used for swing detection and the maximum bar age allowed for a gap to remain valid. Shorter lookbacks detect more swing points and more FVGs but include lower-quality setups. Longer lookbacks produce fewer, higher-conviction structural shifts but generate fewer trades, which makes backtesting more difficult due to small sample sizes. Run the strategy across at least 200 completed trades before drawing any performance conclusions, and test separately across trending and ranging market environments. FVGs in ranging markets without genuine displacement will produce consistently poor results regardless of parameter tuning, this is expected behavior, not a failure of the strategy.

Shared for educational purposes and community discussion. This is not investment advice. Always backtest on your own instruments and timeframes with realistic commission assumptions before evaluating performance.

---

## Source Code

````pine
//@version=6
strategy("Fair Value Gap + Break of Structure", overlay=true,
     default_qty_type=strategy.percent_of_equity, default_qty_value=10,
     commission_type=strategy.commission.percent, commission_value=0.05)

// ── INPUTS ─────────────────────────────────────────────
swingLen  = input.int(10,   "Swing Lookback",         group="Structure", minval=3)
fvgExpiry = input.int(20,   "FVG Max Age (bars)",     group="FVG",       minval=5)
atrLen    = input.int(14,   "ATR Length",             group="Risk")
tpMult    = input.float(2.0,"TP ATR Multiplier",      group="Risk", step=0.1)
slBuffer  = input.float(0.1,"SL Buffer ATR Mult",     group="Risk", step=0.1)

// ── ATR ──────────────────────────────────────────────
atrVal = ta.atr(atrLen)

// ── SWING DETECTION ─────────────────────────────────
swingHigh = ta.pivothigh(high, swingLen, swingLen)
swingLow  = ta.pivotlow(low,   swingLen, swingLen)

// ── BREAK OF STRUCTURE ──────────────────────────────
var float lastSwingHigh = na
var float lastSwingLow  = na
var int   bosUpBar      = na
var int   bosDnBar      = na

if not na(swingHigh)
    lastSwingHigh := swingHigh

if not na(swingLow)
    lastSwingLow := swingLow

bosUp = not na(lastSwingHigh) and close > lastSwingHigh and barstate.isconfirmed
bosDn = not na(lastSwingLow)  and close < lastSwingLow  and barstate.isconfirmed

if bosUp
    bosUpBar := bar_index
if bosDn
    bosDnBar := bar_index

// ── FAIR VALUE GAP DETECTION ─────────────────────────
bullFvgHigh = low[0]  > high[2] ? low[0]  : na
bullFvgLow  = low[0]  > high[2] ? high[2] : na
bearFvgHigh = high[0] < low[2]  ? low[2]  : na
bearFvgLow  = high[0] < low[2]  ? high[0] : na

var float bFvgH = na
var float bFvgL = na
var int   bFvgBar = na
var float sFvgH = na
var float sFvgL = na
var int   sFvgBar = na

recentBosUp = not na(bosUpBar) and (bar_index - bosUpBar) <= fvgExpiry
recentBosDn = not na(bosDnBar) and (bar_index - bosDnBar) <= fvgExpiry

if not na(bullFvgHigh) and recentBosUp
    bFvgH   := bullFvgHigh
    bFvgL   := bullFvgLow
    bFvgBar := bar_index

if not na(bearFvgHigh) and recentBosDn
    sFvgH   := bearFvgHigh
    sFvgL   := bearFvgLow
    sFvgBar := bar_index

// ── ENTRY CONDITIONS ────────────────────────────────
fvgValid  = (bar_index - bFvgBar) <= fvgExpiry
sfvgValid = (bar_index - sFvgBar) <= fvgExpiry

longCond  = not na(bFvgL) and fvgValid  and low  <= bFvgH and close >= bFvgL and barstate.isconfirmed and strategy.position_size == 0
shortCond = not na(sFvgH) and sfvgValid and high >= sFvgL and close <= sFvgH and barstate.isconfirmed and strategy.position_size == 0

// ── EXECUTION ───────────────────────────────────────
if longCond
    strategy.entry("Long",  strategy.long,
         alert_message="FVG long entry — BOS confirmed — {{ticker}} @ {{close}}")
    strategy.exit("Long Exit",  "Long",
         stop  = bFvgL - atrVal * slBuffer,
         limit = close + atrVal * tpMult)
    bFvgH   := na
    bFvgL   := na

if shortCond
    strategy.entry("Short", strategy.short,
         alert_message="FVG short entry — BOS confirmed — {{ticker}} @ {{close}}")
    strategy.exit("Short Exit", "Short",
         stop  = sFvgH + atrVal * slBuffer,
         limit = close - atrVal * tpMult)
    sFvgH   := na
    sFvgL   := na

// ── VISUALS ─────────────────────────────────────────
plotshape(bosUp, location=location.belowbar, color=color.new(color.green, 60),
     style=shape.diamond, size=size.tiny, text="BOS")
plotshape(bosDn, location=location.abovebar, color=color.new(color.red, 60),
     style=shape.diamond, size=size.tiny, text="BOS")

plotshape(longCond,  location=location.belowbar, color=color.green,
     style=shape.triangleup,   size=size.small, text="FVG↑")
plotshape(shortCond, location=location.abovebar, color=color.red,
     style=shape.triangledown, size=size.small, text="FVG↓")
````
