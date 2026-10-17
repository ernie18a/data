# Structure Retest Sniper v1

- url: https://www.tradingview.com/script/AZSv2u2u-Structure-Retest-Sniper-v1/
- type: indicator
- pine_id: PUB;63a7db44206842579acf8c2b1c52e101
- version: 1.0

## Description

Structure Retest Sniper v1 (SRS v1) is a precision-built trend continuation indicator designed to capture high-probability entries after a confirmed break of structure. By combining a triple EMA trend filter (21/50/200), swing-based market structure detection, and dynamic supply/demand zones, the script identifies when price is trending cleanly and breaking key levels. Once a breakout occurs, the system tracks a controlled pullback into value—specifically the 50 EMA—allowing traders to enter on a retest rather than chasing momentum. This creates a disciplined, rule-based approach aligned with institutional price behavior.

The indicator provides clear BUY and SELL signals only when all conditions align: trend direction, break of structure, and valid retest within a defined window. Visual elements such as zone boxes, arrows, labels, and background trend shading make chart reading simple and efficient, while built-in alerts ensure you never miss a setup. SRS v1 performs best on higher timeframes like the 1H, 4H, and Daily charts, and excels in trending markets such as Forex majors, indices, and gold—especially during high-volume sessions like London and New York. This is a clean, no-noise system built for traders who rely on structure, patience, and precision execution.

WHAT THE SCRIPT IS COMPRISED OF
1.  TREND ENGINE (EMA STACK)

You’re using:

21 EMA (fast)
50 EMA (mid)
200 EMA (slow)
Logic:
Bull trend → 21 > 50 > 200
Bear trend → 21 < 50 < 200

This is filtering out bad trades and aligning you with direction.

What it means:
Market is only tradable when it's cleanly trending
No chop = fewer fake signals
2.  STRUCTURE DETECTION (SWING POINTS)

Using:

ta.pivothigh
ta.pivotlow
What it does:
Finds recent highs/lows
Defines:
Resistance (highs)
Support (lows)
Important:

These are confirmed pivots, not guesswork → reduces noise.

3.  SUPPLY & DEMAND ZONES

Every time a swing forms:

Pivot High → Supply Zone
Pivot Low → Demand Zone
How zones are built:
Uses 40% of the candle range
Extended forward (zone_extend)
Meaning:
These zones act as:
Reaction areas
Liquidity zones
Retest targets
4.  BREAK OF STRUCTURE (BOS)

This is your trigger event.

Bullish BOS → price closes above last high
Bearish BOS → price closes below last low
Why it matters:

This confirms:

Trend continuation
Market intent
Liquidity taken
5. RETEST LOGIC (YOUR EDGE)

This is the core sniper logic.

After a BOS:

Wait up to X candles (retest_bars)
Price must pull back to:
EMA 50 (mid EMA)
Entry conditions:
BUY:
Bullish BOS happened
Price pulls back to EMA 50
Trend is bullish
SELL:
Bearish BOS happened
Price pulls back to EMA 50
Trend is bearish

 This is textbook continuation entry

6.  ATR BUFFER (SMART ENTRY SPACING)

Uses:

ATR(14)
Purpose:
Places labels slightly away from price
Helps visualize realistic entry zones

 You can also use this for:

Stop loss placement
Risk control
7.  SIGNAL SYSTEM

You get:

BUY / SELL labels
Triangle arrows
Background trend shading
Alerts
Meaning:
You’re never guessing
Signals are only printed when ALL conditions align

 HOW TO USE THIS (REAL STRATEGY)
 Entry Model (Simple & Effective)

BUY SETUP:
Trend = bullish (EMA aligned)
Price breaks previous high (BOS)
Price pulls back to EMA 50
BUY signal prints

Enter on:

Signal candle close OR
Lower timeframe confirmation
SELL SETUP:
Trend = bearish
Break of low (BOS)
Retest EMA 50
SELL signal prints

STOP LOSS
Best options:

Below/above retest candle
Or:
Below demand zone (for buys)
Above supply zone (for sells)

TAKE PROFIT
Use:

Previous highs/lows
Next structure level
2R–3R minimum

BEST TIMEFRAMES
This is where your indicator shines:

HIGH PROBABILITY SETUP
Daily → Bias
4H → Structure + BOS
1H → Entry (signals)

This matches exactly how you said you trade.

Alternative (Scalping):
15M → structure
5M → entries

 More noise, lower accuracy

BEST MARKETS TO TRADE

This system works best on:

Forex majors
EURUSD
GBPUSD
USDJPY
Gold (XAUUSD) 
Indices
NAS100
US30
Why?
Clean structure
Respect EMAs
Strong trends

BEST SESSIONS (IMPORTANT)
 London Session (BEST)
Strong moves
Clean break + retest behavior

New York Session
Continuations
Volatility expansions

## Source Code

````pine
//@version=6
indicator("Structure Retest Sniper v1", shorttitle="SRS v1", overlay=true, max_boxes_count=100, max_labels_count=100)

// ─────────────────────────────
// INPUTS
// ─────────────────────────────
grpTrend = "Trend Settings"
grpZone  = "Zone Settings"
grpEntry = "Entry Settings"
grpColor = "Colors"

// Trend
ema_fast_len = input.int(21, "Fast EMA", group=grpTrend)
ema_mid_len  = input.int(50, "Mid EMA", group=grpTrend)
ema_slow_len = input.int(200, "Slow EMA", group=grpTrend)

// Zones
swing_len   = input.int(10, "Swing Length", minval=3, group=grpZone)
zone_extend = input.int(50, "Zone Extend", group=grpZone)

// Entries
retest_bars = input.int(5, "Retest Window", group=grpEntry)
atr_mult    = input.float(1.0, "ATR Buffer", step=0.1, group=grpEntry)

// Colors
colBull   = input.color(color.new(#00E676, 0), "Bull Color", group=grpColor)
colBear   = input.color(color.new(#FF1744, 0), "Bear Color", group=grpColor)
colSupply = input.color(color.new(#D4A017, 80), "Supply Zone", group=grpColor)
colDemand = input.color(color.new(#00BCD4, 80), "Demand Zone", group=grpColor)

// ─────────────────────────────
// EMAs
// ─────────────────────────────
ema_fast = ta.ema(close, ema_fast_len)
ema_mid  = ta.ema(close, ema_mid_len)
ema_slow = ta.ema(close, ema_slow_len)

plot(ema_fast, "EMA Fast", color=color.red, linewidth=2)
plot(ema_mid,  "EMA Mid",  color=color.yellow, linewidth=2)
plot(ema_slow, "EMA Slow", color=color.white, linewidth=2)

// Trend Bias
bull_trend = ema_fast > ema_mid and ema_mid > ema_slow
bear_trend = ema_fast < ema_mid and ema_mid < ema_slow

// ─────────────────────────────
// STRUCTURE (SWINGS)
// ─────────────────────────────
ph = ta.pivothigh(high, swing_len, swing_len)
pl = ta.pivotlow(low, swing_len, swing_len)

// Store last structure
var float lastHigh = na
var float lastLow  = na

if not na(ph)
    lastHigh := ph

if not na(pl)
    lastLow := pl

// ─────────────────────────────
// ZONES
// ─────────────────────────────
if not na(ph)
    box.new(bar_index[swing_len], ph,
            bar_index[swing_len] + zone_extend, ph - (high[swing_len] - low[swing_len]) * 0.4,
            bgcolor=colSupply)

if not na(pl)
    box.new(bar_index[swing_len], pl + (high[swing_len] - low[swing_len]) * 0.4,
            bar_index[swing_len] + zone_extend, pl,
            bgcolor=colDemand)

// ─────────────────────────────
// BREAK OF STRUCTURE (BOS)
// ─────────────────────────────
bull_bos = not na(lastHigh) and close > lastHigh
bear_bos = not na(lastLow)  and close < lastLow

// Track break bar
var int bos_bar = na
if bull_bos or bear_bos
    bos_bar := bar_index

// ─────────────────────────────
// RETEST LOGIC (YOUR EDGE)
// ─────────────────────────────
bars_since_bos = bar_index - bos_bar

retest_long  = bull_bos[1] and bars_since_bos <= retest_bars and low <= ema_mid
retest_short = bear_bos[1] and bars_since_bos <= retest_bars and high >= ema_mid

// ATR buffer
atr = ta.atr(14)

// Final Signals
long_signal  = retest_long and bull_trend
short_signal = retest_short and bear_trend

// ─────────────────────────────
// SIGNAL PLOTS
// ─────────────────────────────
if long_signal
    label.new(bar_index, low - atr * atr_mult,
        "BUY",
        style=label.style_label_up,
        color=colBull,
        textcolor=color.black)

if short_signal
    label.new(bar_index, high + atr * atr_mult,
        "SELL",
        style=label.style_label_down,
        color=colBear,
        textcolor=color.white)

// Arrows
plotshape(long_signal, style=shape.triangleup, location=location.belowbar, color=colBull, size=size.small)
plotshape(short_signal, style=shape.triangledown, location=location.abovebar, color=colBear, size=size.small)

// ─────────────────────────────
// BACKGROUND TREND
// ─────────────────────────────
bgcolor(bull_trend ? color.new(colBull, 90) : bear_trend ? color.new(colBear, 90) : na)

// ─────────────────────────────
// ALERTS
// ─────────────────────────────
alertcondition(long_signal, "BUY Signal", "Structure Retest BUY")
alertcondition(short_signal, "SELL Signal", "Structure Retest SELL")
````
