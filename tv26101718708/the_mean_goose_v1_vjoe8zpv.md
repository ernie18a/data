# The Mean Goose v1

- url: https://www.tradingview.com/script/Vjoe8ZpV-The-Mean-Goose-v1/
- type: indicator
- pine_id: PUB;53d421c6bc6c4de98012d67aa0212930
- version: 1.0

## Description

The Mean Goose

CONCEPT
The Mean Goose is a mean-reversion tool built to identify exhaustion extremes and
signal their reversal. The premise is that price stretching well beyond its typical
range often precedes a snap back toward the mean — but acting on an extreme alone is
unreliable, because price can keep extending in an orderly way. The Mean Goose
addresses this with two Keltner Channels that do different jobs, plus an EMA that
times the reversal.

WHY TWO CHANNELS
The two channels are not redundant — each filters a different problem:

- The wide channel (slow, long-period) marks major extremes. It defines the zone
  where price has stretched far enough from the mean to be a mean-reversion candidate
  at all.

- The tight channel (fast, short-period) identifies exhaustion. Its job is to filter
  out price that is simply grinding higher or lower in an efficient, orderly manner —
  the kind of trending move that pokes a single band repeatedly without ever being
  truly overextended. By requiring the candle's extreme to clear BOTH channels at once,
  the script ignores efficient drift and isolates moves that are stretched on two
  timeframes simultaneously. This dual condition is the core filter and is what
  separates a genuine exhaustion event from ordinary directional price action.

THE EMA AS REVERSAL SIGNAL
Clearing both channels arms the setup but does not trigger it. The script then waits
for confirmation that reversion has actually begun, defined as a candle closing back
through a fast EMA in the opposite direction of the extreme. The EMA recross is the
timing component — it keeps the script from firing into a move that is still extending
and only signals once price has started to revert.

HOW THE SIGNAL LOGIC WORKS
The script runs two independent state machines:

High setup (looks for a reversal down)
1. A breakout dot prints above a candle whose high clears BOTH upper channels.
2. This arms an internal high trigger.
3. While armed, the first candle that closes below the EMA prints a down arrow above
   the bar — the reversal signal.
4. The trigger resets and waits for the next exhaustion extreme.

Low setup (looks for a reversal up)
1. A breakout dot prints below a candle whose low clears BOTH lower channels.
2. This arms an internal low trigger.
3. While armed, the first candle that closes above the EMA prints an up arrow below
   the bar — the reversal signal.
4. The trigger resets and waits for the next exhaustion extreme.

The two setups run independently, so a long and short context can be armed at the
same time.

WHAT IT PLOTS
- Wide Keltner Channel — defaults: Length 200, Multiplier 9.5, EMA basis, ATR Length 200.
- Tight Keltner Channel — defaults: Length 20, Multiplier 3.5, SMA basis, ATR Length 40.
- EMA — the reversal reference line. Default Length 9.
- Breakout dots — mark candles whose extreme clears both channels (above for highs,
  below for lows).
- Reversal arrows — down arrow after a high exhaustion once price closes back below the
  EMA; up arrow after a low exhaustion once price closes back above the EMA.

OPTIONAL HIGH-OF-DAY / LOW-OF-DAY FILTER
A "Require new HOD/LOD" toggle (off by default) further restricts breakout dots to
candles that also set a new session high or low, for traders who only want to act on
exhaustion that coincides with a fresh daily extreme. The session resets each day at a
user-defined time (default 18:00 America/New_York). Use the Reset Hour, Reset Minute
and Timezone inputs to match your market's session.

INPUTS
- Wide / Tight Keltner Channels: Length, Multiplier, Source, Use Exponential MA, ATR Length.
- EMA: Length, Source, Offset.
- Breakout Dots: Require new HOD/LOD, Reset Hour, Reset Minute, Timezone.

DEVELOPMENT NOTES
The default settings were developed on NQ (Nasdaq 100 futures) on the 1-minute chart.
Other instruments and timeframes will likely need the channel lengths, multipliers and
EMA period re-tuned to behave sensibly.

NOTES AND LIMITATIONS
- On intraday charts the session reset only lands cleanly when the reset time aligns
  with a candle boundary.
- If an exhaustion candle also closes back through the EMA on the same bar, the arrow
  can fire on that bar.
- This is an analysis and visualisation tool. It does not place orders and makes no
  guarantee of future results. Always test on your own instrument and timeframe before
  relying on it.

## Source Code

````pine
//@version=6
indicator("The Mean Goose v1", overlay=true)

// ============================================================
// KELTNER CHANNEL 1  (wide)
// ============================================================
kc1_len    = input.int(200,   "KC1 Length",        group="Keltner Channel 1")
kc1_mult   = input.float(9.5, "KC1 Multiplier",    group="Keltner Channel 1")
kc1_src    = input.source(close, "KC1 Source",     group="Keltner Channel 1")
kc1_useEMA = input.bool(true, "KC1 Use Exponential MA", group="Keltner Channel 1")
kc1_atrLen = input.int(200,   "KC1 ATR Length",    group="Keltner Channel 1")

kc1_ma  = kc1_useEMA ? ta.ema(kc1_src, kc1_len) : ta.sma(kc1_src, kc1_len)
kc1_rng = ta.atr(kc1_atrLen)
kc1_upper = kc1_ma + kc1_rng * kc1_mult
kc1_lower = kc1_ma - kc1_rng * kc1_mult

plot(kc1_ma,    "KC1 Basis", color=color.new(color.orange, 0))
plot(kc1_upper, "KC1 Upper", color=color.new(color.orange, 30))
plot(kc1_lower, "KC1 Lower", color=color.new(color.orange, 30))

// ============================================================
// KELTNER CHANNEL 2  (tight)
// ============================================================
kc2_len    = input.int(20,    "KC2 Length",        group="Keltner Channel 2")
kc2_mult   = input.float(3.5, "KC2 Multiplier",    group="Keltner Channel 2")
kc2_src    = input.source(close, "KC2 Source",     group="Keltner Channel 2")
kc2_useEMA = input.bool(false, "KC2 Use Exponential MA", group="Keltner Channel 2")
kc2_atrLen = input.int(40,    "KC2 ATR Length",    group="Keltner Channel 2")

kc2_ma  = kc2_useEMA ? ta.ema(kc2_src, kc2_len) : ta.sma(kc2_src, kc2_len)
kc2_rng = ta.atr(kc2_atrLen)
kc2_upper = kc2_ma + kc2_rng * kc2_mult
kc2_lower = kc2_ma - kc2_rng * kc2_mult

plot(kc2_ma,    "KC2 Basis", color=color.new(color.blue, 0))
plot(kc2_upper, "KC2 Upper", color=color.new(color.blue, 30))
plot(kc2_lower, "KC2 Lower", color=color.new(color.blue, 30))

// ============================================================
// EMA
// ============================================================
ema_len = input.int(9, "EMA Length", group="EMA")
ema_src = input.source(close, "EMA Source", group="EMA")
ema_off = input.int(0, "EMA Offset", group="EMA")

ema_val = ta.ema(ema_src, ema_len)
plot(ema_val, "EMA", color=color.new(color.white, 0), offset=ema_off)

// ============================================================
// KC BREAKOUT DOTS  (any candle outside BOTH channels)
// ============================================================
useHODFilter = input.bool(false, "Require new HOD/LOD", group="Breakout Dots")
reset_hour   = input.int(18, "Reset Hour (0-23)", minval=0, maxval=23, group="Breakout Dots")
reset_min    = input.int(0,  "Reset Minute",      minval=0, maxval=59, group="Breakout Dots")
tz           = input.string("America/New_York", "Timezone", group="Breakout Dots")

// --- Keltner breakout: candle extreme outside BOTH channels ---
highOutsideBoth = high > kc1_upper and high > kc2_upper
lowOutsideBoth  = low  < kc1_lower and low  < kc2_lower

// --- Optional HOD/LOD session filter (resets at reset_hour:reset_min) ---
is_reset = (hour(time, tz) == reset_hour and minute(time, tz) == reset_min) and not (hour(time[1], tz) == reset_hour and minute(time[1], tz) == reset_min)

var float dayHigh = na
var float dayLow  = na

if is_reset or na(dayHigh)
    dayHigh := high
    dayLow  := low
else
    dayHigh := math.max(dayHigh, high)
    dayLow  := math.min(dayLow,  low)

prevHigh = is_reset ? na : dayHigh[1]
prevLow  = is_reset ? na : dayLow[1]

newHigh = not na(prevHigh) and high > prevHigh
newLow  = not na(prevLow)  and low  < prevLow

// --- Combine: HOD/LOD requirement only applied when toggle is on ---
highDot = highOutsideBoth and (not useHODFilter or newHigh)
lowDot  = lowOutsideBoth  and (not useHODFilter or newLow)

plotshape(highDot, "High Breakout", style=shape.circle, location=location.abovebar, color=color.new(color.lime, 0), size=size.tiny)
plotshape(lowDot,  "Low Breakout",  style=shape.circle, location=location.belowbar, color=color.new(color.red, 0),  size=size.tiny)

// ============================================================
// TRIGGER STATE MACHINE  ->  ARROWS
// ============================================================
var bool highTrigger = false
var bool lowTrigger  = false

// Arm triggers when a breakout dot prints
if highDot
    highTrigger := true
if lowDot
    lowTrigger := true

// Fire conditions: armed trigger + EMA-cross close, confirmed on bar close only
fireDown = highTrigger and close < ema_val and barstate.isconfirmed   // high setup -> down label
fireUp   = lowTrigger  and close > ema_val and barstate.isconfirmed   // low setup  -> up label

// Disarm after firing
if fireDown
    highTrigger := false
if fireUp
    lowTrigger := false

plotshape(fireDown, "Down Signal", style=shape.labeldown, location=location.abovebar, color=color.new(color.red, 0),  textcolor=color.white, size=size.small)
plotshape(fireUp,   "Up Signal",   style=shape.labelup,   location=location.belowbar, color=color.new(color.lime, 0), textcolor=color.white, size=size.small)
````
