# SMC  Premium  Automation

- url: https://www.tradingview.com/script/ifeB4U0R-SMC-Premium-Automation/
- type: indicator
- pine_id: PUB;6693459648bd4068b2ee2e081a9d0250
- version: 1.0

## Description

The Story of How This Indicator Tells You to BUY or SELL



1️⃣ The Sweep — “Peek‑a‑boo!”
This is when the price monster sticks its hand above a high or below a low to grab candy.

But then it pulls its hand back quickly.

It’s like:

“Peek‑a‑boo! I took the candy!”

That’s a sweep.

2️⃣ The CHoCH — “Uh‑oh… the monster slipped!”
After the monster grabs the candy, it loses its balance and falls the other way.

That fall is called a CHoCH.

It means:

“The monster is changing direction!”

3️⃣ The Order Block — “The monster left footprints!”
Before the monster fell, it stepped on the ground and left a footprint.

That footprint is called an Order Block.

It’s like:

“Here’s where the monster stood before turning around.”

4️⃣ The Entry — “The hero jumps in!”
When the monster comes back to its footprint…

The hero jumps out and says:

BUY! if the monster fell upward

SELL! if the monster fell downward

This is your entry signal.

It’s the safest moment to act because:

“The monster already showed where it’s going.”

⭐ Putting it all together
Here’s the whole adventure:

Sweep → Monster grabs candy

CHoCH → Monster slips and turns around

Order Block → Monster leaves a footprint

Entry → Hero jumps in and says BUY or SELL

That’s it.

⭐ Why this is so powerful
Even a five‑year‑old can understand:

“Wait for the monster to grab candy, slip, leave a footprint, and come back.”

That’s when the hero makes the best move.

If you want, I can also explain:

Stop loss like a “safety shield”

Take profit like “collecting treasure”

Trend like “the direction the river is flowing”

Just tell me what you want next.

## Source Code

````pine
//@version=5
indicator("SMC – Premium Bold + Monochrome Badges + Automation", "SMC Premium", overlay = true, max_labels_count = 500)

//---------------------------------------------------------
// SETTINGS
//---------------------------------------------------------
lenSwing       = input.int(2, "Swing Length", minval = 1)
showSweeps     = input.bool(true, "Show Sweeps")
showSignals    = input.bool(true, "Show Buy/Sell Signals")
showOB         = input.bool(true, "Show Order Blocks")
showAutoEntry  = input.bool(true, "Show Auto Entries")
trendLen       = input.int(12, "Trend Lookback")
colorCandles   = input.bool(true, "Premium Bold Candles")

//---------------------------------------------------------
// COLORS
//---------------------------------------------------------
colBoldBull = color.new(color.green, 0)
colBoldBear = color.new(color.red, 0)

colBadgeDark     = color.new(color.black, 0)
colBadgeDarkSoft = color.new(color.black, 60)
colBadgeBlue     = color.new(color.blue, 70)
colBadgeGray     = color.new(color.gray, 70)

colEntryBull = color.new(color.green, 0)
colEntryBear = color.new(color.red, 0)

//---------------------------------------------------------
// SWING POINTS
//---------------------------------------------------------
swHigh = ta.pivothigh(high, lenSwing, lenSwing)
swLow  = ta.pivotlow(low, lenSwing, lenSwing)

var float lastHigh = na
var float lastLow  = na
var int lastHighBar = na
var int lastLowBar  = na

if not na(swHigh)
    lastHigh := swHigh
    lastHighBar := bar_index - lenSwing

if not na(swLow)
    lastLow := swLow
    lastLowBar := bar_index - lenSwing

//---------------------------------------------------------
// BOS / CHoCH LOGIC
//---------------------------------------------------------
var int trend = 0

bullBOS = not na(lastHigh) and close > lastHigh and bar_index > lastHighBar
bearBOS = not na(lastLow) and close < lastLow and bar_index > lastLowBar

bullCHoCH = bullBOS and trend == -1
bearCHoCH = bearBOS and trend == 1

if bullBOS
    trend := 1
if bearBOS
    trend := -1

//---------------------------------------------------------
// PREMIUM BADGES
//---------------------------------------------------------
if bullBOS
    label.new(lastHighBar, lastHigh + syminfo.mintick * 6, "BOS", style=label.style_label_up, textcolor=color.white, size=size.small, color=colBadgeDark)

if bearBOS
    label.new(lastLowBar, lastLow - syminfo.mintick * 6, "BOS", style=label.style_label_down, textcolor=color.white, size=size.small, color=colBadgeDark)

if bullCHoCH
    label.new(lastHighBar, lastHigh + syminfo.mintick * 12, "CH", style=label.style_label_up, textcolor=color.white, size=size.small, color=colBadgeDarkSoft)

if bearCHoCH
    label.new(lastLowBar, lastLow - syminfo.mintick * 12, "CH", style=label.style_label_down, textcolor=color.white, size=size.small, color=colBadgeDarkSoft)

//---------------------------------------------------------
// WICK‑ONLY SWEEPS (ONE LINE, ERROR‑PROOF)
//---------------------------------------------------------
liqUp = showSweeps and not na(swHigh) and high > swHigh and close < swHigh and open < swHigh
liqDown = showSweeps and not na(swLow) and low < swLow and close > swLow and open > swLow

if liqUp
    label.new(bar_index, high + syminfo.mintick * 5, "SWEEP", style=label.style_label_down, textcolor=color.white, size=size.tiny, color=colBadgeBlue)

if liqDown
    label.new(bar_index, low - syminfo.mintick * 5, "SWEEP", style=label.style_label_up, textcolor=color.white, size=size.tiny, color=colBadgeBlue)

//---------------------------------------------------------
// SWEEP → CHoCH → OB → BUY/SELL ENTRY AUTOMATION
//---------------------------------------------------------
// Sweep flags
var bool hadBearSweep = false
var bool hadBullSweep = false

// OB storage
var float bearObHigh = na
var float bearObLow  = na
var float bullObHigh = na
var float bullObLow  = na

// Setup flags
var bool bearSetup = false
var bool bullSetup = false

// 1) Track sweeps
if liqUp
    hadBearSweep := true
if liqDown
    hadBullSweep := true

// 2) After sweep, wait for opposite CHoCH and define OB
if bearCHoCH and hadBearSweep
    bearObHigh := high[1]
    bearObLow := low[1]
    bearSetup := true
    hadBearSweep := false
    if showOB
        label.new(bar_index - 1, bearObHigh, "OB", style=label.style_label_down, textcolor=color.white, size=size.tiny, color=colBadgeGray)

if bullCHoCH and hadBullSweep
    bullObHigh := high[1]
    bullObLow := low[1]
    bullSetup := true
    hadBullSweep := false
    if showOB
        label.new(bar_index - 1, bullObLow, "OB", style=label.style_label_up, textcolor=color.white, size=size.tiny, color=colBadgeGray)

// 3) BUY/SELL ENTRY: price returns to OB and rejects
bearEntry = showAutoEntry and bearSetup and not na(bearObHigh) and high >= bearObHigh and close < bearObLow
bullEntry = showAutoEntry and bullSetup and not na(bullObLow) and low <= bullObLow and close > bullObHigh

if bearEntry
    label.new(bar_index, bearObLow - syminfo.mintick * 10, "SELL", style=label.style_label_down, textcolor=color.white, size=size.small, color=colEntryBear)
    bearSetup := false

if bullEntry
    label.new(bar_index, bullObHigh + syminfo.mintick * 10, "BUY", style=label.style_label_up, textcolor=color.white, size=size.small, color=colEntryBull)
    bullSetup := false

//---------------------------------------------------------
// TREND + PREMIUM BOLD CANDLES
//---------------------------------------------------------
bullTrend = ta.ema(close, trendLen) > ta.ema(close, trendLen * 2)
bearTrend = ta.ema(close, trendLen) < ta.ema(close, trendLen * 2)

barcolor(colorCandles ? (bullTrend ? colBoldBull : bearTrend ? colBoldBear : na) : na)

//---------------------------------------------------------
// BUY / SELL SIGNALS (STRUCTURE-BASED)
//---------------------------------------------------------
buySig = showSignals and bullCHoCH and bullTrend
sellSig = showSignals and bearCHoCH and bearTrend

buyY = low - syminfo.mintick * 20
sellY = high + syminfo.mintick * 20

if buySig
    label.new(bar_index, buyY, "BUY", style=label.style_label_up, textcolor=color.white, size=size.small, color=color.new(color.green, 0))

if sellSig
    label.new(bar_index, sellY, "SELL", style=label.style_label_down, textcolor=color.white, size=size.small, color=color.new(color.red, 0))

//---------------------------------------------------------
// ALERTS
//---------------------------------------------------------
alertcondition(buySig, "BUY", "Buy Signal")
alertcondition(sellSig, "SELL", "Sell Signal")
alertcondition(bearEntry, "SELL Entry", "Bearish Sweep → CHoCH → OB → SELL Entry")
alertcondition(bullEntry, "BUY Entry", "Bullish Sweep → CHoCH → OB → BUY Entry")
````
