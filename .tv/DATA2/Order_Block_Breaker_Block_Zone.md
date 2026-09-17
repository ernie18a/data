<!-- tradingview-pine-id: PUB;cd4de2ca321f4aad9ecb816d89d97086 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Order Block & Breaker Block Zone

Source: https://www.tradingview.com/script/Y3O5TG2B-Order-Block-Breaker-Block-Zone/

## Description

Order Block & Breaker Block Zone

A strict Order Block detector, and the Breaker Block that a failed Order Block turns into.

Most Order Block tools mark the last opposite coloured candle before a strong move. That
description fits almost any pullback, which is why those tools cover a chart in boxes. This one
asks for four independent pieces of evidence on the same candle before it will draw anything, and then it keeps following the zone for the rest of its life instead of drawing it once and walking away.

The candle's own colour is never checked. Colour is a description of a candle, not evidence about what happened at that price.

WHAT HAS TO HAPPEN

Bullish Order Block

1 The block candle trades BELOW the previous candle's low the sweep
2 That same candle is Candle 1 of a valid three candle bullish imbalance, so Candle 3's low sits above the block candle's high the gap
3 Price does not trade back into the block's high to low range while it is still waiting the zone stays clean
4 A candle CLOSES above the last unbroken swing high the structure break

Bearish Order Block is the same read upside down: the block candle trades above the previous
candle's high, the imbalance runs the other way, and a candle closes below the last unbroken
swing low.

The zone drawn is the block candle's full high to low range.

The structure break also has to land inside a wait window, counted forward from Candle 3. A block that needs fifty candles to break structure is no longer the same story, so the wait is limited and the block is dropped when it expires.

BOS OR CHoCH - A TAG, NOT A GRADE

Market structure is tracked separately, from swing pivots. Each new swing is compared with the
one before it, which gives the familiar higher high, higher low, lower high, lower low reading,
and from that the structure is either bullish or bearish.

A break that runs WITH the structure is a Break of Structure. A break that runs AGAINST it is a
Change of Character, and that is what flips the structure the other way. Mechanically they are
the same event - a close beyond a swing level. Only the direction relative to the current
structure decides the name.

So a Bullish Order Block can arrive in two very different situations, and the label says which:

Bull OB (CHoCH) the market was bearish and this block flipped it a reversal block
Bull OB (BOS) the market was already bullish and carried on a continuation block

Neither ranks above the other. They are different stories, not different quality levels, and the
tag exists so you can tell them apart at a glance instead of reconstructing it from the chart.

THE LIFE CYCLE

A zone is not finished when it is drawn. It is followed until it resolves.

Fresh confirmed and untouched. Drawn in the bullish or bearish colour.

Mitigated price has traded back into the zone. It is no longer a fresh Order Block, so it
is repainted in grey. It is kept because it is what a Breaker grows from.

Breaker Block the zone has failed, with a candle CLOSING through its far side. It flips polarity and is redrawn in the opposite colour. A wick through does not count.

The entry and the failure can land on the same candle. One candle that trades into the zone and closes through the other side takes the block from fresh to Breaker in a single step, and that is treated exactly like a slower failure.

No reaction inside the zone is asked for before a Breaker is drawn, and that is a deliberate
departure from how this is usually done. Where an Order Block is only "the last opposite candle
before a move", a Breaker built on it needs a second proof, because the block itself proved
nothing. That weakness is not present here. A zone only becomes an Order Block after a sweep, and imbalance and a structure break, and a displacement that broke structure IS the evidence that orders were resting at that price. Asking for a reaction on top of it is asking for a second
receipt for the same purchase.

It is also worth being clear about what actually traps a trader. Limit orders fill the moment
price trades into the zone. They are trapped the moment a candle closes through the far side. A reaction candle in between never created that trap - it was only a witness to it, and the absence of a witness does not mean the event did not happen. A proven zone that is overrun without even being allowed to answer is not the weaker case. It is the more one sided one.

WHAT MAKES THIS DIFFERENT

1. Four conditions, not one.

Sweep, imbalance, clean zone and structure break each test something different: that liquidity
was taken, that the move away was violent enough to leave a gap, that nobody has been back, and that the move changed something. Any one of them on its own is common. All four on the same candle is not.

2. Colour is ignored on purpose.

The classic "last opposite candle" case still gets caught, because the candle that sweeps the
previous extreme is usually that candle anyway. It is caught as a consequence of the evidence
rather than as the rule, and the blocks that only ever qualified on colour are left out.

3. The zone is followed, not just marked.

Fresh, mitigated and breaker are three different states, and a zone moves between them as price does its work. What is on the chart is the zone's current condition, not the condition it was in on the day it formed.

4. The Breaker inherits the block's proof instead of asking for a new one.

Because the Order Block had to earn its place, a Breaker built on it does not need a reaction
close to be believed. What is asked for is the one thing that actually matters: a candle body
closing through the far side. That keeps the rule honest in both directions - it does not throw
away a violent one candle break, and it still refuses a wick.

5. Structure is measured, not assumed.

BOS and CHoCH come from confirmed swing pivots that have to be paid for with right hand candles. Nothing is read from a moving average or a fixed lookback window.

6. The evidence is on the chart, not just the claim.

Each block can show the imbalance that qualified it and the swing level whose break confirmed it. You are not asked to take the label's word for it - the gap and the broken level are drawn where they happened, so the block can be checked in a couple of seconds.

READING THE CHART

Green box, "Bull OB (BOS)" or "Bull OB (CHoCH)" fresh bullish Order Block, label below
Red box, "Bear OB (BOS)" or "Bear OB (CHoCH)" fresh bearish Order Block, label above
Grey box, "... mitigated" tapped, waiting to resolve
Green box, "Bullish Breaker" a failed bearish block, polarity flipped
Red box, "Bearish Breaker" a failed bullish block, polarity flipped

Each box spans the Order Block candle's full high to low range, and runs to the right edge while
the zone is still drawn so you can see where price sits against it now.

Two extras are drawn alongside each block:

Dotted yellow box the imbalance that qualified the block. It covers the three candles it formed on and sits directly ON TOP of a bullish zone or directly BELOW a bearish one, because the gap starts where the block candle ends.

Dashed line the swing level whose break confirmed the block. It runs from the swing itself across to the candle that closed through it, so you can see which high or low was taken and how far the move travelled to take it.

Between them these two say why the block exists: the gap is the imbalance test, the dashed line is the structure test. Both are the Order Block's credentials, so both disappear once the zone flips to a Breaker. By then its Order Block life is over and only the level still matters.

A Breaker's box can begin either at the candle that broke the zone or at the original Order Block
candle. The price levels are identical either way - only the left edge moves. Starting at the
breakout is the default, because a Breaker only becomes a Breaker when it flips, and drawing it
from its birth stretches old ones across the entire chart.

A chart can only stay readable if it is not covered in boxes, so only the most recent few zones
of each kind are drawn. Order Blocks - fresh and mitigated together - have their own limit, and
Breaker Blocks have theirs. Everything older is still tracked and can still turn into a Breaker
later, it is simply not on screen.

The corner table counts everything still being tracked: fresh Order Blocks, mitigated zones and
Breaker Blocks, split into bull and bear. It counts zones whose type is switched off and zones
sitting outside the display limits too, so the table describes the record while the chart shows
the recent part of it. If the table reads higher than what you can see, that is the display limit
doing its job.

Two more optional overlays are available for checking the structure engine directly. Swing labels put HH, HL, LH and LL on the pivots, and the structure break markers name every BOS and CHoCH on the chart rather than only the ones that confirmed a block. Both are off by default.

SETTINGS

Market Structure
- Swing Left and Swing Right: how many candles must confirm a pivot on each side. The default of 5 and 5 reads ordinary swing structure. Lower it to 3 and 3 for minor structure and many more breaks; raise it for major structure only. Swing Right is also the confirmation delay - a swing does not exist until that many candles have closed.
- Show Swing Labels (HH / HL / LH / LL): names each confirmed pivot.
- Show Every Structure Break (BOS / CHoCH): draws and names every break on the chart, not only the ones that confirmed a zone.

Order Block
- Scan Length: how many closed candles back the search for new blocks reaches. The running candle is always excluded. This bounds the search, not the structure engine - swings and the bullish or bearish structure state are read from the whole chart, so a block found right at the edge of the window is still measured against everything that came before it.
- Max Order Blocks Shown: how many of the most recent Order Blocks are drawn. Fresh and mitigated zones share this limit. This is the setting to reach for when the chart feels crowded.
- Max Breaker Blocks Shown: the same limit for Breaker Blocks, counted separately.
- Structure Break Wait: how many candles a block may wait for its structure break, counted from Candle 3 of the imbalance. The zone has to stay clean for the whole wait. If the wait runs out the block is dropped.

Zone Types
- A switch for each of the five things that can be on screen: bullish and bearish Order Blocks,
mitigated zones, and bullish and bearish Breaker Blocks.
- Show Order Block FVG: draws the imbalance that qualified each block.
- Show Confirming Swing: draws the swing level whose break confirmed each block.

Zone Style
- Bullish, bearish, mitigated and imbalance colours, fill transparency, and whether drawn zones
extend right. The imbalance is always filled a little lighter than the zone it belongs to, and
neither the imbalance nor the confirming swing is ever extended - both mark where something
happened, not where price is now.
- Breaker Zone Starts At: whether a Breaker's box begins at the Breakout Candle, where the zone actually flipped, or at the Order Block Candle it grew from. Breakout Candle is the default and keeps old Breakers from stretching across the whole chart. The price levels do not change.

Labels
- Show Labels, Label Size, and Label Distance from Zone as a percentage of the zone height.
Increase the distance on noisy charts so labels clear the candles.

Summary Table
- Show, position and size of the corner table.

ALERTS

Six alert conditions:

Bullish Order Block a bullish block has confirmed its structure break
Bearish Order Block a bearish block has confirmed its structure break
Bullish OB Mitigated price has traded back into a fresh bullish block
Bearish OB Mitigated price has traded back into a fresh bearish block
Bullish Breaker Block a failed bearish block has become a bullish Breaker
Bearish Breaker Block a failed bullish block has become a bearish Breaker

Each message carries the event, the symbol, the timeframe and the closing price. The same
messages are also sent through the alert function, so the "Any alert() function call" alert type
can deliver all six through a single alert.

Every alert is evaluated only after a candle has fully closed.

REPAINTING

This script does not repaint.

- The whole engine runs once per closed candle. Price moving inside an open candle cannot create, change or remove anything, and cannot make a signal appear and then disappear.
- Swings are only usable after their right hand candles have closed. That delay is deliberate: it
is what makes a swing a fact rather than a guess. A swing high therefore appears Swing Right candles after the candle it belongs to, and a structure break can only be measured against a
swing that already existed.
- Zones are built forward, one candle at a time, in the same order they would have been built
live. A zone that has been drawn is never moved. Its colour changes when its state changes, and
that is a record of what price did afterwards, not a revision of what it did before.
- Nothing is read from a higher timeframe, so there is no higher timeframe lookahead to get
wrong.

When you create an alert, TradingView may show a caution banner saying the indicator can repaint. That banner appears automatically for any script that uses the built in bar state variables, no matter how they are used, because the platform cannot check the intent behind them. This script uses one of them for the opposite purpose: it is what restricts the entire engine to bar close. Choosing "Once Per Bar Close" when creating the alert is still recommended.

NOTES AND LIMITATIONS

- The pattern is rare by design. Four conditions have to line up on the same candle, so long
stretches with nothing new on the chart are normal. If you want to see more, look at a faster
timeframe rather than loosening the settings.
- A block that is tapped before its structure break lands is dropped rather than confirmed. This
is strict on purpose: an Order Block that has already been traded back into was not untouched
when it confirmed, whatever happened afterwards.
- Swing Right is a real delay. On a very slow timeframe the confirmation of a swing can take a
meaningful amount of time, and a structure break cannot be recognised before the swing it breaks has been confirmed.
- Scan Length and the display limits do two different jobs. Scan Length decides how far back
blocks are looked for at all, so raising it can find older blocks. The display limits only
decide how many of what was found is drawn; raising them shows more of the same set, lowering them hides zones that are still being tracked. Nothing about how a block is detected or how it resolves depends on whether it happens to be drawn.
- An internal cap of 200 tracked zones keeps memory and the drawing count inside TradingView's limits. On a very long history the oldest tracked zones are dropped, so the table describes the recent record rather than the entire chart.
- Detection is purely structural. It reports where these sequences occurred and what state each
zone is in. It does not rank zones by quality, measure follow through, or produce entries,targets or stops.

HOW TO USE IT

A fresh Order Block marks a price where liquidity was taken, the move away left a gap, nobody has been back, and structure changed. Traders commonly watch these areas for:

- A reaction on the first return, since the zone is untouched until then
- Context from the tag, where a CHoCH block sits at a possible turn and a BOS block sits inside
an existing move
- Confirmation against a higher timeframe read, where a block that agrees with the larger picture carries more weight than one that fights it

A grey mitigated zone is a zone that has already been used once. It is worth less as an entry
area and worth more as a warning: it either holds from here, or it becomes a Breaker.

A Breaker Block is the opposite side of the same level. Traders commonly watch the far edge - the low of a broken bullish block, the high of a broken bearish block - on the first return after the flip.

These are reference areas, not entry signals on their own. Use them alongside your own structure read, your own entry method and proper risk management.

DISCLAIMER

This indicator is a pattern detection tool. It is not financial advice and it makes no claim
about profitability. Trading involves risk. Always apply your own analysis and risk management.

---

## Source Code

````pine
//@version=6
indicator(
     title            = "Order Block & Breaker Block Zone",
     overlay          = true,
     max_boxes_count  = 500,
     max_labels_count = 500,
     max_lines_count  = 500,
     max_bars_back    = 500
     )

// ==========================================================
// Order Block & Breaker Block Zone
//
// A strict Order Block, and the Breaker Block that a failed one turns into.
//
// ORDER BLOCK - five things have to happen, and all five are mandatory:
//
//   1  LIQUIDITY SWEEP    the Order Block candle takes the previous candle's
//                         low (bullish) or high (bearish)
//   2  IMBALANCE          that same candle is Candle 1 of a valid 3-candle FVG,
//                         so the move away from it left an unfilled gap
//   3  ZONE STAYS CLEAN   from the fourth candle onwards price may not trade
//                         back into the zone while it is still waiting
//   4  STRUCTURE BREAK    a candle CLOSES beyond the last unbroken swing level,
//                         which is either a BOS or a CHoCH
//   5  INSIDE THE WAIT    that break has to land within the wait window
//
// The Order Block candle's own colour is never checked. Colour describes a
// candle; it is not evidence about what happened at that price.
//
// The break is tagged, not graded. A block that confirms while the market was
// already trending the same way is tagged (BOS) and reads as continuation. One
// that confirms by flipping the structure is tagged (CHoCH) and reads as a
// reversal. Neither ranks above the other.
//
// The swing level that was broken is kept with the block and can be drawn, so
// the evidence behind the tag stays visible instead of having to be trusted.
// The imbalance that qualified the block can be drawn too. Both are the Order
// Block's credentials, so both are dropped once the zone flips to a Breaker.
//
// ZONE LIFE CYCLE
//
//   Fresh  ->  Mitigated  ->  Breaker Block
//
// A confirmed zone starts Fresh. The first time price trades back into it the
// zone becomes Mitigated and is redrawn in grey - it is no longer a Fresh
// Order Block, but it is kept, because it is what a Breaker grows from. It
// becomes a Breaker Block when a candle CLOSES through its far side. A wick
// through does not count, and that close is the only filter on the failure.
//
// The entry and the failure can land on the same candle. One candle that
// trades into the zone and closes through the other side takes the block from
// Fresh to Breaker in a single step.
//
// No reaction inside the zone is asked for. In the loose definition of an
// Order Block a Breaker needs that second proof, because the block itself
// proved nothing. Here the block already had to sweep, leave a gap and break
// structure, and a displacement that broke structure IS the proof that orders
// were resting there. What traps traders is the fill on entry and the close
// through the far side; a reaction candle was only ever a witness to that, not
// the cause of it.
//
// MARKET STRUCTURE
//
// Swings are pivots: a high with Swing Left lower highs on its left and Swing
// Right lower highs on its right. A swing does not exist until its right-side
// candles have closed, which is what keeps the reading honest. Each new swing
// is compared with the one before it to give HH, HL, LH or LL. The reference
// for an upward break is the most recent swing high that has not been broken
// yet; once broken it is used up and the next one takes over. Breaking with
// the structure is a BOS, breaking against it is a CHoCH, and a CHoCH is what
// flips the structure state.
//
// Scan Length limits how far back new blocks are looked for. It does not limit
// the structure engine, which reads the whole chart, so a block found at the
// edge of the window is still measured against the structure that preceded it.
//
// All detection reads closed candles only. The running candle is never used.
// ==========================================================

// ============================ INPUTS ============================
gStruct = "Market Structure"
gScan   = "Order Block"
gType   = "Zone Types"
gStyle  = "Zone Style"
gLabel  = "Labels"
gTable  = "Summary Table"

swingL = input.int(5, "Swing Left", minval = 1, maxval = 50, group = gStruct,
     tooltip = "How many candles on the left of a swing must be lower for a high, or higher for a low. Smaller values read minor structure and give many breaks.")
swingR = input.int(5, "Swing Right", minval = 1, maxval = 50, group = gStruct,
     tooltip = "How many candles on the right must confirm the swing. A swing is only usable after this many candles have closed, which is what stops the structure reading from changing later.")
showSwings = input.bool(false, "Show Swing Labels (HH / HL / LH / LL)", group = gStruct)
showBreaks = input.bool(false, "Show Every Structure Break (BOS / CHoCH)", group = gStruct,
     tooltip = "Marks every structure break on the chart, not only the ones that confirmed a zone. Useful for studying the structure engine itself.")

candleLen = input.int(500, "Scan Length (closed candles)", minval = 50, maxval = 5000, group = gScan,
     tooltip = "How many closed candles back the search for new blocks reaches. The running candle is always excluded. Market structure is still read from the whole chart, so a block near the start of the window is measured against the swings that came before it.")
maxOB = input.int(5, "Max Order Blocks Shown", minval = 1, maxval = 50, group = gScan,
     tooltip = "Only this many of the most recent Order Blocks are drawn. Fresh and mitigated zones share this limit. Older ones are still tracked and still counted in the table, they are just not drawn.")
maxBB = input.int(5, "Max Breaker Blocks Shown", minval = 1, maxval = 50, group = gScan,
     tooltip = "Only this many of the most recent Breaker Blocks are drawn. Older ones are still tracked and still counted in the table.")
waitBars = input.int(20, "Structure Break Wait (candles)", minval = 1, maxval = 100, group = gScan,
     tooltip = "How long a block may wait for its structure break, counted from the third candle of the imbalance. While it waits the zone has to stay clean. If the wait runs out the block is dropped.")

showBullOB  = input.bool(true, "Bullish Order Block",   group = gType)
showBearOB  = input.bool(true, "Bearish Order Block",   group = gType)
showMitOB   = input.bool(true, "Mitigated Order Block", group = gType)
showBullBB  = input.bool(true, "Bullish Breaker Block", group = gType)
showBearBB  = input.bool(true, "Bearish Breaker Block", group = gType)
showFVG     = input.bool(true, "Show Order Block FVG",  group = gType,
     tooltip = "Draws the imbalance that qualified the block. It sits directly above a bullish zone and directly below a bearish one.")
showConfSw  = input.bool(true, "Show Confirming Swing", group = gType,
     tooltip = "Draws the swing level whose break confirmed the block, from the swing itself across to the candle that closed through it.")

bullColor  = input.color(#22c55e, "Bullish Zone Color",   group = gStyle)
bearColor  = input.color(#ef4444, "Bearish Zone Color",   group = gStyle)
mitColor   = input.color(#9598a1, "Mitigated Zone Color", group = gStyle)
fvgColor   = input.color(#facc15, "Order Block FVG Color", group = gStyle)
zoneTransp = input.int(80, "Zone Transparency", minval = 0, maxval = 95, group = gStyle,
     tooltip = "Fill transparency of a zone. The imbalance is always drawn a little lighter than this.")
extendZones = input.bool(true, "Extend Zones Right", group = gStyle,
     tooltip = "Runs each drawn zone to the right edge, so you can see where price sits against it now. The imbalance and the confirming swing are never extended.")
bbAnchorStr = input.string("Breakout Candle", "Breaker Zone Starts At", options = ["Breakout Candle", "Order Block Candle"], group = gStyle,
     tooltip = "Where a Breaker Block's box begins. Breakout Candle starts it where the zone actually flipped, which keeps old Breakers from stretching across the whole chart. Order Block Candle starts it at the candle the block was built from, which shows the full history but draws much longer boxes. The price levels are identical either way.")

showLabels     = input.bool(true, "Show Labels", group = gLabel)
labelSizeStr   = input.string("Normal", "Label Size", options = ["Tiny", "Small", "Normal", "Large"], group = gLabel)
labelOffsetPct = input.int(30, "Label Distance from Zone (%)", minval = 0, group = gLabel,
     tooltip = "Gap between the zone edge and the label, as a percentage of the zone height.")

showTable    = input.bool(true, "Show Summary Table", group = gTable)
tablePosStr  = input.string("Top Right", "Table Position", options = ["Top Right", "Middle Right", "Bottom Right", "Top Left", "Bottom Left"], group = gTable)
tableSizeStr = input.string("Small", "Table Size", options = ["Tiny", "Small", "Normal"], group = gTable)

// ============================ STYLE CONSTANTS ============================
labelBull = #107a34
labelBear = #b22222
labelMit  = #5d606b
swingBg   = #363a45
tableHead = #000000
tableBg   = #1e222d
tableEdge = #363a45

labelSize = labelSizeStr == "Tiny" ? size.tiny : labelSizeStr == "Small" ? size.small : labelSizeStr == "Large" ? size.large : size.normal
tableSize = tableSizeStr == "Tiny" ? size.tiny : tableSizeStr == "Normal" ? size.normal : size.small
tablePos  = tablePosStr == "Top Right" ? position.top_right : tablePosStr == "Middle Right" ? position.middle_right : tablePosStr == "Bottom Right" ? position.bottom_right : tablePosStr == "Top Left" ? position.top_left : position.bottom_left

// The imbalance is drawn a little lighter than the zone it belongs to.
fvgTransp = zoneTransp + 10 > 95 ? 95 : zoneTransp + 10

// true when a Breaker's box should begin at the candle that broke the zone
bbFromBreak = bbAnchorStr == "Breakout Candle"

// Zone states
STATE_PENDING   = 0
STATE_FRESH     = 1
STATE_MITIGATED = 2
STATE_BREAKER   = 3

MAX_ZONES  = 200
MAX_STRUCT = 60

// ============================ ZONE MODEL ============================
type Zone
    int   obBar         // bar_index of the Order Block candle
    int   c3Bar         // bar_index of Candle 3, where the imbalance completed
    int   confirmBar    // bar_index of the structure break that confirmed it
    int   breakBar      // bar_index of the candle that broke the zone, once it does
    float top
    float bot
    float fvgFar        // far edge of the imbalance: Candle 3 low, or Candle 3 high
    float swPrice       // the swing level whose break confirmed this block
    int   swBar         // bar_index of that swing
    int   dir           // 1 = bullish Order Block, -1 = bearish Order Block
    int   state
    int   drawnState    // last state actually painted, so styling is not redone every bar
    bool  choch
    int   deadline
    box   bx
    box   fvgBx
    line  swLn
    label lb

var array<Zone> zones = array.new<Zone>()

// ============================ MARKET STRUCTURE STATE ============================
var float swHigh     = na    // latest confirmed swing high
var float swHighPrev = na    // the one before it, used for the HH / LH label
var int   swHighBar  = na
var bool  swHighUsed = true  // true once this level has been broken
var float swLow      = na
var float swLowPrev  = na
var int   swLowBar   = na
var bool  swLowUsed  = true
var int   mss        = 0     // structure state: 1 Bullish, -1 Bearish, 0 none yet

// The last break in each direction is remembered with the level it broke, so a
// block whose displacement candle already broke structure can be confirmed the
// moment its imbalance completes, and still know which swing it broke.
var int   lastUpBar   = -1
var bool  lastUpChoch = false
var float lastUpLevel = na
var int   lastUpLvlBar = na
var int   lastDnBar   = -1
var bool  lastDnChoch = false
var float lastDnLevel = na
var int   lastDnLvlBar = na

var array<label> structLabels = array.new<label>()
var array<line>  structLines  = array.new<line>()

// ============================ SIGNALS ============================
bool sigBullOB  = false
bool sigBearOB  = false
bool sigBullMit = false
bool sigBearMit = false
bool sigBullBB  = false
bool sigBearBB  = false

// ============================ DRAWING HELPERS ============================
pushStructLabel(label lb) =>
    array.push(structLabels, lb)
    if array.size(structLabels) > MAX_STRUCT
        label old = array.shift(structLabels)
        label.delete(old)

pushStructLine(line ln) =>
    array.push(structLines, ln)
    if array.size(structLines) > MAX_STRUCT
        line old = array.shift(structLines)
        line.delete(old)

killZone(Zone z) =>
    if not na(z.bx)
        box.delete(z.bx)
        z.bx := na
    if not na(z.fvgBx)
        box.delete(z.fvgBx)
        z.fvgBx := na
    if not na(z.swLn)
        line.delete(z.swLn)
        z.swLn := na
    if not na(z.lb)
        label.delete(z.lb)
        z.lb := na
    z.drawnState := -1

zoneVisible(Zone z) =>
    bool v = false
    if z.state == STATE_FRESH
        v := z.dir == 1 ? showBullOB : showBearOB
    else if z.state == STATE_MITIGATED
        v := showMitOB
    else if z.state == STATE_BREAKER
        v := z.dir == -1 ? showBullBB : showBearBB
    v

// Paints a zone in the style its current state calls for. A Breaker flips
// polarity, so a Bullish Order Block that failed is drawn as a Bearish Breaker
// and its label moves to the top of the box.
//
// `allowed` is the display limit talking. A zone that is still tracked but sits
// outside the most recent few of its kind is simply not drawn.
refreshZone(Zone z, bool allowed) =>
    if not allowed or z.state == STATE_PENDING or not zoneVisible(z)
        killZone(z)
    else
        color  fill    = mitColor
        color  lblCol  = labelMit
        string txt     = z.dir == 1 ? "Bull OB mitigated" : "Bear OB mitigated"
        bool   bullish = z.dir == 1

        if z.state == STATE_FRESH
            fill   := z.dir == 1 ? bullColor : bearColor
            lblCol := z.dir == 1 ? labelBull : labelBear
            txt    := (z.dir == 1 ? "Bull OB" : "Bear OB") + (z.choch ? " (CHoCH)" : " (BOS)")
        else if z.state == STATE_BREAKER
            bullish := z.dir == -1
            fill    := bullish ? bullColor : bearColor
            lblCol  := bullish ? labelBull : labelBear
            txt     := bullish ? "Bullish Breaker" : "Bearish Breaker"

        // A Breaker may start at the candle that broke it instead of at the
        // Order Block candle. The price levels are the same either way; only
        // the left edge moves, which stops old Breakers stretching across the
        // whole chart.
        bool  onBreak = z.state == STATE_BREAKER and bbFromBreak and not na(z.breakBar)
        int   left    = onBreak ? z.breakBar : z.obBar

        // When zones are not extended, a box still spans at least its own
        // imbalance, so a block confirmed on the displacement candle is not
        // drawn as a sliver.
        int   baseR  = z.confirmBar > z.c3Bar ? z.confirmBar : z.c3Bar
        int   fixedR = baseR > left + 1 ? baseR : left + 1
        int   right  = extendZones ? bar_index + 10 : fixedR
        float h      = math.abs(z.top - z.bot)
        float off    = h * labelOffsetPct * 0.01
        float y      = bullish ? z.bot - off : z.top + off
        bool  fresh  = z.drawnState != z.state

        // --- the zone itself ---
        if na(z.bx)
            z.bx := box.new(left, z.top, right, z.bot,
                 xloc         = xloc.bar_index,
                 border_color = color.new(fill, 0),
                 border_width = 1,
                 border_style = line.style_solid,
                 bgcolor      = color.new(fill, zoneTransp))
        else
            if extendZones
                box.set_right(z.bx, right)
            if fresh
                box.set_left(z.bx, left)
                box.set_border_color(z.bx, color.new(fill, 0))
                box.set_bgcolor(z.bx, color.new(fill, zoneTransp))

        // --- the imbalance that qualified it ---
        // Bullish: the gap sits between the block candle high and Candle 3 low,
        // so it rests directly on top of the zone. Bearish is the mirror.
        //
        // The imbalance and the confirming swing are the Order Block's
        // credentials, so they are dropped once the zone has flipped. By then
        // its Order Block life is over and only the level still matters.
        bool showProof = z.state != STATE_BREAKER

        if showFVG and showProof and not na(z.fvgFar)
            float fTop = z.dir == 1 ? z.fvgFar : z.bot
            float fBot = z.dir == 1 ? z.top    : z.fvgFar
            if na(z.fvgBx)
                z.fvgBx := box.new(z.obBar, fTop, z.c3Bar, fBot,
                     xloc         = xloc.bar_index,
                     border_color = color.new(fvgColor, 40),
                     border_width = 1,
                     border_style = line.style_dotted,
                     bgcolor      = color.new(fvgColor, fvgTransp))
        else
            if not na(z.fvgBx)
                box.delete(z.fvgBx)
                z.fvgBx := na

        // --- the swing whose break confirmed it ---
        if showConfSw and showProof and not na(z.swPrice) and not na(z.swBar)
            if na(z.swLn)
                z.swLn := line.new(z.swBar, z.swPrice, z.confirmBar, z.swPrice,
                     xloc  = xloc.bar_index,
                     color = z.dir == 1 ? bullColor : bearColor,
                     width = 1,
                     style = line.style_dashed)
        else
            if not na(z.swLn)
                line.delete(z.swLn)
                z.swLn := na

        // --- the label ---
        if showLabels
            if na(z.lb)
                z.lb := label.new(left + 1, y,
                     text      = txt,
                     xloc      = xloc.bar_index,
                     yloc      = yloc.price,
                     style     = bullish ? label.style_label_up : label.style_label_down,
                     color     = lblCol,
                     textcolor = color.white,
                     size      = labelSize)
            else if fresh
                label.set_xy(z.lb, left + 1, y)
                label.set_text(z.lb, txt)
                label.set_style(z.lb, bullish ? label.style_label_up : label.style_label_down)
                label.set_color(z.lb, lblCol)
        else
            if not na(z.lb)
                label.delete(z.lb)
                z.lb := na

        z.drawnState := z.state

// ============================ SUMMARY TABLE ============================
var table sumTable = table.new(tablePos, 3, 4, border_width = 1, border_color = tableEdge)

// ============================ PIVOTS ============================
// Evaluated on every bar so the pivot history stays intact. The value returned
// belongs to the candle Swing Right bars back, which is why a swing can never
// appear before its right side has closed.
float pivotH = ta.pivothigh(high, swingL, swingR)
float pivotL = ta.pivotlow(low, swingL, swingR)

// ============================ MAIN ENGINE (BAR CLOSE ONLY) ============================
int cFreshBull = 0
int cFreshBear = 0
int cMitBull   = 0
int cMitBear   = 0
int cBBBull    = 0
int cBBBear    = 0

if barstate.isconfirmed

    // ---------- 1. Market structure ----------
    if not na(pivotH)
        swHighPrev := swHigh
        swHigh     := pivotH
        swHighBar  := bar_index - swingR
        swHighUsed := false
        if showSwings
            string tag = na(swHighPrev) ? "H" : pivotH > swHighPrev ? "HH" : pivotH < swHighPrev ? "LH" : "H"
            pushStructLabel(label.new(swHighBar, pivotH, tag,
                 xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_down,
                 color = color.new(swingBg, 20), textcolor = color.white, size = size.tiny))

    if not na(pivotL)
        swLowPrev := swLow
        swLow     := pivotL
        swLowBar  := bar_index - swingR
        swLowUsed := false
        if showSwings
            string tag = na(swLowPrev) ? "L" : pivotL < swLowPrev ? "LL" : pivotL > swLowPrev ? "HL" : "L"
            pushStructLabel(label.new(swLowBar, pivotL, tag,
                 xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_up,
                 color = color.new(swingBg, 20), textcolor = color.white, size = size.tiny))

    bool upBreak = not na(swHigh) and not swHighUsed and close > swHigh
    bool dnBreak = not na(swLow)  and not swLowUsed  and close < swLow

    // A single candle can only be read as one break. If it closes past both
    // levels the candle's own direction decides which one counts.
    if upBreak and dnBreak
        if close > open
            dnBreak := false
        else
            upBreak := false

    bool upChoch = false
    bool dnChoch = false

    if upBreak
        upChoch      := mss == -1
        mss          := 1
        swHighUsed   := true
        lastUpBar    := bar_index
        lastUpChoch  := upChoch
        lastUpLevel  := swHigh
        lastUpLvlBar := swHighBar
        if showBreaks
            pushStructLine(line.new(swHighBar, swHigh, bar_index, swHigh,
                 xloc = xloc.bar_index, color = bullColor, width = 1, style = line.style_dotted))
            pushStructLabel(label.new(bar_index, swHigh, upChoch ? "CHoCH" : "BOS",
                 xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_down,
                 color = labelBull, textcolor = color.white, size = size.tiny))

    if dnBreak
        dnChoch      := mss == 1
        mss          := -1
        swLowUsed    := true
        lastDnBar    := bar_index
        lastDnChoch  := dnChoch
        lastDnLevel  := swLow
        lastDnLvlBar := swLowBar
        if showBreaks
            pushStructLine(line.new(swLowBar, swLow, bar_index, swLow,
                 xloc = xloc.bar_index, color = bearColor, width = 1, style = line.style_dotted))
            pushStructLabel(label.new(bar_index, swLow, dnChoch ? "CHoCH" : "BOS",
                 xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_up,
                 color = labelBear, textcolor = color.white, size = size.tiny))

    // ---------- 2. Advance every zone already on the books ----------
    if array.size(zones) > 0
        for idx = array.size(zones) - 1 to 0
            Zone z    = array.get(zones, idx)
            bool drop = false

            // --- PENDING: waiting for its structure break, must stay clean ---
            if z.state == STATE_PENDING
                // Candle 3 is guaranteed clear of the zone by the imbalance
                // itself, so the clean-zone watch starts on the candle after it.
                if bar_index > z.c3Bar
                    bool backInZone = z.dir == 1 ? low <= z.top : high >= z.bot
                    if backInZone
                        drop := true

                if not drop
                    bool brk = z.dir == 1 ? upBreak : dnBreak
                    if brk
                        z.state      := STATE_FRESH
                        z.choch      := z.dir == 1 ? upChoch : dnChoch
                        z.confirmBar := bar_index
                        z.swPrice    := z.dir == 1 ? lastUpLevel  : lastDnLevel
                        z.swBar      := z.dir == 1 ? lastUpLvlBar : lastDnLvlBar
                        if z.dir == 1
                            sigBullOB := true
                        else
                            sigBearOB := true
                    else if bar_index >= z.deadline
                        drop := true

            // --- FRESH: alive until price comes back into it ---
            if not drop and z.state == STATE_FRESH
                bool tapped = z.dir == 1 ? low <= z.top : high >= z.bot
                if tapped
                    z.state   := STATE_MITIGATED
                    if z.dir == 1
                        sigBullMit := true
                    else
                        sigBearMit := true

            // --- MITIGATED: waiting to be broken ---
            // Tested on the same bar as the tap, because one candle can dip into
            // the zone and still close through the other side. That candle takes
            // the block from Fresh to Breaker on its own.
            if not drop and z.state == STATE_MITIGATED
                bool failed = z.dir == 1 ? close < z.bot : close > z.top
                if failed
                    z.state    := STATE_BREAKER
                    z.breakBar := bar_index
                    if z.dir == 1
                        sigBearBB := true
                    else
                        sigBullBB := true

            if drop
                killZone(z)
                array.remove(zones, idx)

    // ---------- 3. New imbalance completing on this candle ----------
    // Offsets: [2] = Candle 1 = the ORDER BLOCK candle
    //          [1] = Candle 2 = the displacement
    //          [0] = Candle 3 = this candle, which completes the gap
    //          [3] = the candle the Order Block swept
    //
    // Scan Length gates only this step. The structure engine above keeps
    // running on every bar, so a block that forms at the very start of the
    // window is still measured against swings that formed before it, and its
    // BOS / CHoCH tag is still read from a fully warmed up structure state.
    if bar_index >= 3 and bar_index >= last_bar_index - candleLen
        // Bullish: sweep the previous low, then leave a gap above the block
        bool bullOK = low[2] < low[3] and low[0] > high[2]
        // Bearish: sweep the previous high, then leave a gap below the block
        bool bearOK = high[2] > high[3] and high[0] < low[2]

        if bullOK or bearOK
            int obDir = bullOK ? 1 : -1

            Zone nz = Zone.new(
                 obBar      = bar_index - 2,
                 c3Bar      = bar_index,
                 confirmBar = bar_index,
                 breakBar   = na,
                 top        = high[2],
                 bot        = low[2],
                 fvgFar     = obDir == 1 ? low[0] : high[0],
                 swPrice    = na,
                 swBar      = na,
                 dir        = obDir,
                 state      = STATE_PENDING,
                 drawnState = -1,
                 choch      = false,
                 deadline   = bar_index + waitBars)

            // The displacement candle or this candle may have broken structure
            // already. If so the block confirms right here, and it remembers
            // which swing that break took out.
            int  brkBar   = obDir == 1 ? lastUpBar   : lastDnBar
            bool brkChoch = obDir == 1 ? lastUpChoch : lastDnChoch

            if brkBar >= bar_index - 1
                nz.state      := STATE_FRESH
                nz.choch      := brkChoch
                nz.confirmBar := brkBar
                nz.swPrice    := obDir == 1 ? lastUpLevel  : lastDnLevel
                nz.swBar      := obDir == 1 ? lastUpLvlBar : lastDnLvlBar
                if obDir == 1
                    sigBullOB := true
                else
                    sigBearOB := true

            array.push(zones, nz)

            if array.size(zones) > MAX_ZONES
                Zone oldest = array.shift(zones)
                killZone(oldest)

    // ---------- 4. Draw and count ----------
    // Newest first, so the display limits keep the most recent zones and drop
    // the older ones off the chart. Everything still tracked is still counted.
    int obShown = 0
    int bbShown = 0

    if array.size(zones) > 0
        for idx = array.size(zones) - 1 to 0
            Zone z = array.get(zones, idx)
            bool allowed = false

            if z.state == STATE_FRESH or z.state == STATE_MITIGATED
                obShown += 1
                allowed := obShown <= maxOB
            else if z.state == STATE_BREAKER
                bbShown += 1
                allowed := bbShown <= maxBB

            refreshZone(z, allowed)

            if z.state == STATE_FRESH
                if z.dir == 1
                    cFreshBull += 1
                else
                    cFreshBear += 1
            else if z.state == STATE_MITIGATED
                if z.dir == 1
                    cMitBull += 1
                else
                    cMitBear += 1
            else if z.state == STATE_BREAKER
                if z.dir == -1
                    cBBBull += 1
                else
                    cBBBear += 1

    // ---------- 5. Summary table ----------
    if showTable
        table.cell(sumTable, 0, 0, "Zone", bgcolor = tableHead, text_color = color.white, text_size = tableSize, text_halign = text.align_left)
        table.cell(sumTable, 1, 0, "Bull", bgcolor = tableHead, text_color = color.white, text_size = tableSize)
        table.cell(sumTable, 2, 0, "Bear", bgcolor = tableHead, text_color = color.white, text_size = tableSize)

        table.cell(sumTable, 0, 1, "Order Block", bgcolor = tableBg, text_color = color.white, text_size = tableSize, text_halign = text.align_left)
        table.cell(sumTable, 1, 1, str.tostring(cFreshBull), bgcolor = tableBg, text_color = bullColor, text_size = tableSize)
        table.cell(sumTable, 2, 1, str.tostring(cFreshBear), bgcolor = tableBg, text_color = bearColor, text_size = tableSize)

        table.cell(sumTable, 0, 2, "Mitigated", bgcolor = tableBg, text_color = color.white, text_size = tableSize, text_halign = text.align_left)
        table.cell(sumTable, 1, 2, str.tostring(cMitBull), bgcolor = tableBg, text_color = mitColor, text_size = tableSize)
        table.cell(sumTable, 2, 2, str.tostring(cMitBear), bgcolor = tableBg, text_color = mitColor, text_size = tableSize)

        table.cell(sumTable, 0, 3, "Breaker", bgcolor = tableBg, text_color = color.white, text_size = tableSize, text_halign = text.align_left)
        table.cell(sumTable, 1, 3, str.tostring(cBBBull), bgcolor = tableBg, text_color = bullColor, text_size = tableSize)
        table.cell(sumTable, 2, 3, str.tostring(cBBBear), bgcolor = tableBg, text_color = bearColor, text_size = tableSize)
    else
        table.clear(sumTable, 0, 0, 2, 3)

// ============================ ALERTS ============================
alertcondition(sigBullOB,  title = "Bullish Order Block",   message = "Bullish Order Block confirmed | {{ticker}} {{interval}} | Close {{close}}")
alertcondition(sigBearOB,  title = "Bearish Order Block",   message = "Bearish Order Block confirmed | {{ticker}} {{interval}} | Close {{close}}")
alertcondition(sigBullMit, title = "Bullish OB Mitigated",  message = "Bullish Order Block mitigated | {{ticker}} {{interval}} | Close {{close}}")
alertcondition(sigBearMit, title = "Bearish OB Mitigated",  message = "Bearish Order Block mitigated | {{ticker}} {{interval}} | Close {{close}}")
alertcondition(sigBullBB,  title = "Bullish Breaker Block", message = "Bullish Breaker Block formed | {{ticker}} {{interval}} | Close {{close}}")
alertcondition(sigBearBB,  title = "Bearish Breaker Block", message = "Bearish Breaker Block formed | {{ticker}} {{interval}} | Close {{close}}")

// Dynamic message for the "Any alert() function call" alert type.
alertMsg(string tag) =>
    tag + " | " + syminfo.ticker + " " + timeframe.period + " | Close " + str.tostring(close, format.mintick)

if barstate.isconfirmed
    if sigBullOB
        alert(alertMsg("Bullish Order Block confirmed"), alert.freq_once_per_bar_close)
    if sigBearOB
        alert(alertMsg("Bearish Order Block confirmed"), alert.freq_once_per_bar_close)
    if sigBullMit
        alert(alertMsg("Bullish Order Block mitigated"), alert.freq_once_per_bar_close)
    if sigBearMit
        alert(alertMsg("Bearish Order Block mitigated"), alert.freq_once_per_bar_close)
    if sigBullBB
        alert(alertMsg("Bullish Breaker Block formed"), alert.freq_once_per_bar_close)
    if sigBearBB
        alert(alertMsg("Bearish Breaker Block formed"), alert.freq_once_per_bar_close)
````
