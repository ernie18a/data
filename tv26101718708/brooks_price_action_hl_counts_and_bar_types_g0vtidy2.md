# Brooks Price Action  H-L Counts and Bar Types

- url: https://www.tradingview.com/script/g0vTIdy2-Brooks-Price-Action-H-L-Counts-and-Bar-Types/
- type: indicator
- pine_id: PUB;a01daf0c97c34c60af81250640cdaeae
- version: 1.0

## Description

An overlay indicator that annotates your chart with the core visual vocabulary of Al Brooks' price action method: H/L counts, inside and outside bar patterns, and signal bar tinting. It does not generate buy/sell signals. It surfaces the raw structural information a Brooks-style reader would mark on every bar, so you can form your own interpretation faster and more consistently.

[b]What it marks[/b]

[i]H and L counts (above/below bars)[/i]
Numbers above bars are "H" counts (higher highs); numbers below are "L" counts (lower lows). These are the tempo of Brooks' leg analysis — H2 is the second attempt to make a higher high in an up leg, L2 is the second attempt to make a lower low in a down leg, and so on. Two counting modes are available:

[i]Strict HH/LL[/i] — counts pure consecutive new highs or new lows. Each bar must have a higher high than the previous bar to increment H, a lower low to increment L. The count resets to zero when the direction breaks.
[pine]Brooks (pullback)[/pine] — closer to how Brooks himself counts. It waits for a pullback (a bar that fails to make a higher high or lower low) before counting the next H or L, capturing the "pullback and resume" rhythm that defines trending legs.

Counts display from 2 upward and are capped at a user-defined maximum to keep the chart readable.

[i][b]Inside and outside bars[/b][/i]

ii — two consecutive inside bars. A classical Brooks breakout setup. Compression that resolves with momentum.
iii — three or more consecutive inside bars. Even tighter compression. Breakouts from iii patterns often carry strong follow-through.
oo — outside bar (high exceeds prior high while low undercuts prior low). Represents two-sided conviction within a single bar — frequently a reversal or a stop-run event.

[i][b]Signal bars (background tint)[/i][b][/b]
[/b]Bars whose close is within the top quartile of the bar's range AND whose body is at least 50% of the range receive a background tint — green for bull signals, red for bear signals. These are the "strong signal bars" Brooks-style readers look for as entry triggers. Both thresholds are user-configurable.

[i]Doji (optional)[/i]
When enabled, small-body bars (body less than a configurable percent of range) receive a dot below them. Useful for seeing indecision or exhaustion, especially when clusters appear at range extremes.
How to use it
The indicator does not produce signals. It gives you the bar-by-bar structural context a discretionary price action trader would annotate manually. Typical applications:

Trend counting. When you see H4 or higher without a meaningful pullback, the move is extended and fresh entries on that side become lower probability. L1, L2, L3 in a downtrend mark the natural pullback-entry locations.
Breakout anticipation. ii and iii patterns mark compression. Paired with directional context — are you in a trend? is there a level overhead? — they help you anticipate resolution direction.
Reversal awareness. oo tags often mark pivots or liquidity sweeps. Context determines whether it's a reversal or a volatile continuation.
Entry quality filter. If the bar at your intended trigger doesn't tint as a signal bar, the momentum isn't there and the entry is lower quality. If it does, the bar itself confirms the setup.

[b]Settings[/b]
All visual elements can be individually toggled and color-customized. Text size is adjustable (tiny / small / normal) for readability on dense charts. The quartile and body thresholds for signal bars, and the body-percent threshold for doji, are all exposed so you can tune strictness to your instrument and timeframe.
Notes

Works on any timeframe and any market. The method is intrinsic to price action, not tuned to specific instruments.
The Brooks counting mode is designed for trending structures. On pure range days, counts may not develop meaningfully regardless of mode.
Purely visual. Does not repaint, does not project into the future, does not generate alerts.
Based on Al Brooks' price action methodology as described in his books. Conceptual credit belongs to him. This script is an attempt to express the bar-by-bar reading as an on-chart annotation so you don't have to mark it by hand.

Open-source so you can inspect, modify, or extend it for your own workflow.

## Source Code

````pine
//@version=5
indicator("Brooks Price Action - H/L & Bar Types", overlay=true, max_labels_count=500)

// ─────────────────────────────────────────────────
//   INPUTS
// ─────────────────────────────────────────────────

grpCount = "H/L Counting"
countMode = input.string("Strict HH/LL", "Count mode",
     options=["Strict HH/LL", "Brooks (pullback)"], group=grpCount,
     tooltip="Strict: consecutive HHs/LLs. Brooks: counts pullback-and-resume attempts within a leg (resets on direction flip).")
maxCount  = input.int(20, "Max count to display", minval=2, maxval=100, group=grpCount)
showHighs = input.bool(true, "Show H counts above bars", group=grpCount)
showLows  = input.bool(true, "Show L counts below bars", group=grpCount)
highColor = input.color(color.orange, "H color", group=grpCount)
lowColor  = input.color(color.lime,   "L color", group=grpCount)

grpIO = "Inside / Outside Bars"
showInside   = input.bool(true, "Mark ii / iii", group=grpIO)
showOutside  = input.bool(true, "Mark oo (outside bar)", group=grpIO)
insideColor  = input.color(color.yellow,  "ii/iii color", group=grpIO)
outsideColor = input.color(color.fuchsia, "oo color",    group=grpIO)

grpSig = "Signal Bars"
showSignalBars = input.bool(true, "Tint strong signal bars", group=grpSig)
closeQuartile  = input.float(0.25, "Close within % of extreme",
     minval=0.1, maxval=0.5, step=0.05, group=grpSig,
     tooltip="0.25 = close must be in top/bottom quarter of the bar's range.")
minBodyPct     = input.float(0.50, "Min body as % of range",
     minval=0.2, maxval=0.9, step=0.05, group=grpSig)
bullSigColor   = input.color(color.new(color.green, 80), "Bull tint", group=grpSig)
bearSigColor   = input.color(color.new(color.red,   80), "Bear tint", group=grpSig)

grpDoji = "Doji"
showDoji    = input.bool(false, "Mark doji (weak) bars", group=grpDoji)
dojiBodyPct = input.float(0.10, "Doji body % of range",
     minval=0.03, maxval=0.3, step=0.01, group=grpDoji)
dojiColor   = input.color(color.gray, "Doji color", group=grpDoji)

grpDisp = "Display"
textSizeInput = input.string("small", "Text size",
     options=["tiny", "small", "normal"], group=grpDisp)
labelSize = textSizeInput == "tiny" ? size.tiny : textSizeInput == "small" ? size.small : size.normal

// ─────────────────────────────────────────────────
//   BAR TYPES
// ─────────────────────────────────────────────────

barRange = high - low
bodySize = math.abs(close - open)
isBull   = close > open
isBear   = close < open

isInside  = high <= high[1] and low >= low[1] and not (high == high[1] and low == low[1])
isOutside = high >  high[1] and low <  low[1]
isDoji    = barRange > 0 and (bodySize / barRange) <= dojiBodyPct

bullSignal = isBull and barRange > 0 and (high - close) / barRange <= closeQuartile and bodySize / barRange >= minBodyPct
bearSignal = isBear and barRange > 0 and (close - low)  / barRange <= closeQuartile and bodySize / barRange >= minBodyPct

// ─────────────────────────────────────────────────
//   H / L COUNTING
// ─────────────────────────────────────────────────

var int  highCount = 0
var int  lowCount  = 0
var bool bullPullbackSeen = true
var bool bearPullbackSeen = true

if countMode == "Strict HH/LL"
    highCount := high > high[1] ? highCount + 1 : 0
    lowCount  := low  < low[1]  ? lowCount  + 1 : 0
else
    // A "pullback" opens the door for the next H/L event
    if high < high[1]
        bullPullbackSeen := true
    if low > low[1]
        bearPullbackSeen := true
    // Trend-resume bars register the next H or L
    if high > high[1] and bullPullbackSeen
        highCount += 1
        bullPullbackSeen := false
    if low < low[1] and bearPullbackSeen
        lowCount += 1
        bearPullbackSeen := false
    // Reset the opposite count when the leg flips
    if high > high[1] and lowCount > 0
        lowCount := 0
        bearPullbackSeen := true
    if low < low[1] and highCount > 0
        highCount := 0
        bullPullbackSeen := true

// ─────────────────────────────────────────────────
//   LABELS & VISUALS
// ─────────────────────────────────────────────────

// H / L numbers
if showHighs and highCount >= 2 and highCount <= maxCount
    label.new(bar_index, high, str.tostring(highCount),
         yloc=yloc.abovebar, style=label.style_none, textcolor=highColor, size=labelSize)

if showLows and lowCount >= 2 and lowCount <= maxCount
    label.new(bar_index, low, str.tostring(lowCount),
         yloc=yloc.belowbar, style=label.style_none, textcolor=lowColor, size=labelSize)

// Inside bar streak
var int insideStreak = 0
insideStreak := isInside ? insideStreak + 1 : 0

if showInside and insideStreak == 2
    label.new(bar_index, high, "ii",
         yloc=yloc.abovebar, style=label.style_none, textcolor=insideColor, size=labelSize)
if showInside and insideStreak >= 3
    label.new(bar_index, high, "iii",
         yloc=yloc.abovebar, style=label.style_none, textcolor=insideColor, size=labelSize)

// Outside bars
if showOutside and isOutside
    label.new(bar_index, high, "oo",
         yloc=yloc.abovebar, style=label.style_none, textcolor=outsideColor, size=labelSize)

// Doji marker
if showDoji and isDoji
    label.new(bar_index, low, "•",
         yloc=yloc.belowbar, style=label.style_none, textcolor=dojiColor, size=labelSize)

// Signal bar background tint
bgcolor(showSignalBars and bullSignal ? bullSigColor : na, title="Bull signal")
bgcolor(showSignalBars and bearSignal ? bearSigColor : na, title="Bear signal")
````
