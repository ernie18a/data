# Stream Master [SimpleAlgo]

- url: https://www.tradingview.com/script/AwBP8jMv-Stream-Master-SimpleAlgo/
- type: indicator
- pine_id: PUB;14c62321df1c4a489a880d7f73024ef9
- version: 1.0

## Description

█ [b]INTRODUCING STREAM MASTER[/b]

Every trend tool answers the same question, which way is the market going, and most of them answer it with a line that changes colour. The line tells you the direction. It tells you nothing about how hard the market is moving, whether the move is running out, or how far into a turn you are.

[b]Stream Master[/b] draws the market as a river. The current is price smoothed twice over 10 bars. Around it, three layers of water follow the current with more and more lag, out to a slow water that follows price smoothed twice over 60 bars. When the market moves, the current runs ahead and the slow water trails behind, and the river leaves a wake: long and bright when the move is fast, gone when the market stalls. Every layer takes the up colour while it is flowing up and the down colour while it is flowing down, so a turn passes through the river from the inside out, and you can see how deep it has gone.

https://www.tradingview.com/x/G2IqZj6a/

There are no labels on the chart. The shape and colour of the river is the whole read, and the panel in the corner says it in words: which way the current flows and how hard, how many of the four layers have turned, how long the wake is and whether it is growing, stretched, fading or turning, and where price sits relative to the current. The seven moments worth knowing about are alerts.

https://www.tradingview.com/x/UifIXrha/

⚪ [b]The river[/b]

Four layers make the river: the current and three edges. Each edge is a blend of the current and the slow water, the first about half way between them, the second most of the way, the third the slow water itself. Each is pushed out by a width that grows with its distance from the current, 35%, 70% and 100% of the river's full width, 3.5 ATRs each side by default. In slack water the river is a smooth band around the current. In a move the inner layers follow the current and the outer layers lag behind it, and the band stretches into a wake. The water is brightest at the current and fades toward the slow water, and the whole river dims when nothing is moving.

⚪ [b]The wake[/b]

The wake is the distance between the current and the slow water, measured in ATRs. It is the memory of the move: how far the market has travelled, in its own volatility units, since the slow water last caught up. The script tracks the longest each wake gets, notices when it has started to give that back, and compares it with the last twenty wakes to say whether this move is already longer than the market usually runs.

⚪ [b]What's different[/b]

The river is not a ribbon of moving averages. There are only two smoothed series in it, the current and the slow water, and the layers are blends between them, which is why the wake is one shape instead of a stack of lines. Each layer is coloured by its own slope rather than by the current's, so the picture shows how far a turn has spread, and the panel counts it. The wake is treated as a measured quantity with a memory, not just a gap between two lines. And the events are in the river's own vocabulary: the current turning, price leaving the stream and rejoining it, a pullback to the current that holds, the wake stretching, the wake fading.

█ [b]HOW IT WORKS[/b]

⚪ [b]1. The current and the slow water[/b]

The current is price smoothed twice, which rounds it without the stepping a single average has. The slow water is the same thing over a much longer length:

[pine]
float centre = ta.ema(ta.ema(close, fastLen), fastLen)
float cslow  = ta.ema(ta.ema(close, slowLen), slowLen)
[/pine]

Everything in the river is measured in ATRs, so the same settings mean the same thing on gold, on bitcoin and on a stock:

[pine]
float atr    = nz(ta.atr(14), high - low)
[/pine]

⚪ [b]2. The flow[/b]

The current's slope, in ATRs per bar and smoothed over 8 bars, is the flow. A flow of 0.12 ATRs a bar is full colour. Anything inside 15% of that is slack:

[pine]
float slope  = (centre - nz(centre[1], centre)) / atr
float flow   = ta.ema(slope, dirLen)
float t      = math.max(-1.0, math.min(1.0, flow / fullAt))
[/pine]

The current flows one way until its slope has crossed the slack zone to the other side. That is the turn, and it is the moment the panel's Since the turn row counts from:

[pine]
if t >= deadAt
    dir := 1
else if t <= -deadAt
    dir := -1
[/pine]

⚪ [b]3. The layers[/b]

Each edge is a blend of the current and the slow water. The blend is curved, so the first edge sits about half way out, the second most of the way, and the third is the slow water itself:

[pine]
float ref = cslow + (centre - cslow) * math.pow(1 - f, shapeK)
[/pine]

The edge is then pushed out by a width that grows with its distance from the current, using a smoothed ATR so the river's width doesn't jump on one big bar:

[pine]
float w   = f * widthIn * atrS
[/pine]

⚪ [b]4. Colour by each layer's own slope[/b]

Every edge is coloured by its own slope, smoothed over 12 bars, not by the current's. The first edge is about half current and half slow water, so it turns a few bars after the current. The outer edge is the slow water, so it turns last. That is why a turn passes through the river from the inside out, and why the panel can count how many of the four layers have turned.

[pine]
float sl  = (ref - nz(ref[1], ref)) / atr
float fl  = ta.ema(sl, colLen)
[/pine]

The colour runs from the slack blue to the up or down colour as the slope rises out of the slack zone, so the river brightens smoothly into a move instead of switching on:

[pine]
ramp(float x) =>
    float a = math.abs(x)
    a < deadAt ? 0.0 : (a - deadAt) / (1 - deadAt)
[/pine]

Each layer's colour is held in steps of a tenth, and a step only moves once the slope has travelled a full step, so a fill keeps one colour for a run of bars instead of flickering between two shades while the slope sits on a boundary:

[pine]
steps(float raw) =>
    var float held = 0.0
    if raw >= held + 0.1
        held := math.floor(raw * 10) / 10
    else if raw <= held - 0.1
        held := math.ceil(raw * 10) / 10
    held
[/pine]

The six bands between the four layers are gradient fills, each running from the inner layer's colour to the outer layer's, brightest at the current and fading to the slow water. In a wake the outer layer can sit on the far side of the inner one, so each fill is told explicitly which of its two edges is on top.

⚪ [b]5. The wake, measured[/b]

The wake is the distance between the current and the slow water in ATRs, and it counts as a wake once it is half an ATR long:

[pine]
float wake   = (centre - cslow) / atr
[/pine]

[pine]
int wakeSign = wake > 0.5 ? 1 : wake < -0.5 ? -1 : 0
[/pine]

While a wake lasts, the script remembers the longest it has been. When the wake has given back a quarter of that, it is fading. While it is at its longest, it is growing. When the current has turned against it, it is turning:

[pine]
bool  wakeTurning   = wakeOn and dir != 0 and dir != wakeSide
bool  wakeFading    = wakeOn and not wakeTurning and wakeAbs < wakePeak * 0.75
bool  wakeGrowing   = wakeOn and not wakeTurning and wakeAbs >= wakePeak * 0.98
[/pine]

When a wake ends, its longest length goes into a list of the last twenty. A wake that is already longer than three quarters of them is stretched: this move has run further than the market has usually run lately.

[pine]
float stretchAt     = array.size(peaks) >= 5 ? array.percentile_nearest_rank(peaks, stretchPct) : na
bool  wakeStretched = wakeOn and not na(stretchAt) and wakeAbs >= stretchAt
[/pine]

Stretched is relative to the market in front of you. Two ATRs can be stretched on a quiet day and ordinary on a wild one.

https://www.tradingview.com/x/iUcxDWhi/

⚪ [b]6. Price and the stream[/b]

Where price sits is measured from the current, in ATRs:

[pine]
float dist = (close - centre) / atr
[/pine]

Price is on the stream while it closes within 0.75 ATRs of the current. It has left the stream when it closes 1.5 ATRs away, and it has rejoined when it is back within 0.75. The gap between the two numbers is on purpose, so price can hover at the edge without an event firing on every bar.

⚪ [b]7. The pullback[/b]

A pullback to the current is only looked for while the river is flowing one way and the wake agrees:

[pine]
int pullCtx = wakeOn and dir == wakeSide ? dir : 0
[/pine]

It arms when price has left the stream on the flowing side, which means the move ran ahead of its current. It fires when a bar then comes back to within 0.25 ATRs of the current and closes back on the flowing side of it:

[pine]
bool touched = pullCtx == 1 ? low <= centre + pullIn * atr : high >= centre - pullIn * atr
[/pine]

[pine]
bool pullDone = reached and (pullCtx == 1 ? close > centre : close < centre)
[/pine]

After one fires, price has to leave the stream again before another can. That keeps it to the real pullbacks: a few per trend, and none at all in slack water.

https://www.tradingview.com/x/TY8COGYX/

⚪ [b]8. Events[/b]

One event a bar, the most important first: the current turning, then a pullback that held, then price leaving the stream, then price rejoining it, then the wake fading, then the wake stretching. Fading and stretched fire once per wake, and carry over to the next bar if something bigger took the slot.

[pine]
int evt = dir != prevDir ? dir : pullDone ? pullCtx * 5 : leftNow ? outSide * 2 : backNow ? outSide * 3 : (wakeFading and not fadeFired) ? 4 : (wakeStretched and not stretchFired) ? 6 : 0
[/pine]

⚪ [b]9. The panel[/b]

[list]
[*][b]Current[/b]: Flowing up or Flowing down, with strong, moderate or weak, or Slack while the current is inside the slack zone.
[*][b]Layers[/b]: how many of the four layers are flowing each way. 4 of 4 flowing up is a river in full flow. 2 up, 1 down is a turn in progress. All slack is a dead market.
[*][b]Wake[/b]: its direction and length in ATRs, and whether it is growing, stretched, fading or turning.
[*][b]Price[/b]: On the stream, or above or below it by so many ATRs.
[*][b]Since the turn[/b]: bars since the current last changed direction.
[*][b]Last event[/b]: the most recent event and how long ago. An event on the live bar shows as pending until the bar closes.
[/list]

⚪ [b]Repainting[/b]

Every bar of the river is built only from the bars before it, so the historical river doesn't change. The current and the layers update on the live bar like any moving average does. Events are decided on closed bars and never move afterwards; on the live bar the panel says an event confirms on close.

█ [b]WHY IT IS ORIGINAL[/b]

The ingredients are ordinary, two smoothed averages and an ATR, and we won't pretend otherwise. What is new is the construction and what it lets you read. A ribbon of averages shows you a stack of lines, each with its own length, that fan out and bunch up. The river has one fast series and one slow one, and the layers are blends between them, so the whole thing is a single shape that stretches into a wake and relaxes out of it. Colouring each layer by its own slope turns that shape into a picture of how deep a turn has gone, and the panel reads the depth off it. The wake is measured, remembered and compared with the wakes before it, so exhaustion and over-extension are readings of this market rather than fixed thresholds. The events come out of that geometry: a pullback is defined by the stream, not by a distance you set. None of that exists in a moving average cloud or a ribbon, and all of it is built so the chart carries the reading without a single label.

█ [b]HOW TO USE IT[/b]

⚪ [b]Colour first[/b]

Mint, the market is flowing up. Pink, it is flowing down. Blue, it is slack, and slack water is the one reading most tools don't give you: it means don't trend-trade here. The current's colour is the quickest read. The layers behind it tell you whether the rest of the river agrees.

⚪ [b]Then the wake[/b]

A growing wake is a move with momentum behind it. A stretched wake is a move that has already run further than this market usually does. That is not a reversal call, strong trends stay stretched for a long time; it is a reason not to chase. A fading wake is a move losing speed, which is when to tighten up. A turning wake is the current already going the other way inside the old wake: the first stage of a turn, and the stage where most turns fail.

https://www.tradingview.com/x/aNfsg7fe/

⚪ [b]Trade with the current[/b]

The useful moments are the ones the events name. Price leaving the stream on the flowing side is a market extended away from its current; it tends to come back before it goes on. The pullback event is that return: price came back to the current and the current held. In a river with a growing wake, that is the location a trend trader waits for. Price leaving the stream against the flow, or the current turning while the wake is long, is a trend being tested.

https://www.tradingview.com/x/27O29M4R/

⚪ [b]Timeframes[/b]

With the defaults the current responds over about ten bars and the slow water over about sixty. On a 5-minute chart the wake describes the last few hours. On a 1-hour chart it is a few days. On a daily chart it is a quarter. Wake lengths and the stretched reading scale with the chart, because everything is in ATRs.

https://www.tradingview.com/x/UcsJ0VX1/

⚪ [b]If you're new[/b]

Three sentences. The coloured line is where the market has been heading lately: mint up, pink down, blue going nowhere. The coloured water behind it is how hard the market has been moving: a long bright tail is a strong move, a tail that is shrinking is a move slowing down, no tail is a market drifting. The only moments worth waiting for are when price comes back to the line in a strong move and the line holds, and when the line changes colour.

None of this predicts where price goes. The river is a smoothed picture of where it has been, and an event isn't a buy or sell signal. Use it with your own analysis and manage your risk.

█ [b]SETTINGS[/b]

⚪ [b]Stream[/b]

[list]
[*][b]Current (bars)[/b]: the current is price smoothed twice over this many bars. 10 by default. Lower follows price more closely, higher is calmer.
[*][b]Wake (bars)[/b]: the slow water is price smoothed twice over this many bars. 60 by default. The bigger the gap between this and the current, the longer the wake a move leaves.
[*][b]River width (ATRs)[/b]: how wide the river is in slack water, each side of the current at its outer edge. 3.5 by default.
[*][b]History (bars)[/b]: how far back the river is drawn, 1,500 bars by default. Scroll further back and it simply stops. Lower it if your chart feels slow.
[/list]

⚪ [b]Events[/b]

[list]
[*][b]Price has left the stream at (ATRs)[/b]: 1.5 by default.
[*][b]And is back on it within (ATRs)[/b]: 0.75 by default.
[*][b]A pullback reaches the current within (ATRs)[/b]: 0.25 by default.
[/list]

⚪ [b]Look[/b]

[list]
[*][b]Theme[/b]: Neon, Classic, Aurora, Ice, or Custom with your own slack, up and down colours.
[*][b]Brightness[/b]: 1 to 5, for your screen and background.
[*][b]Slack water[/b]: how visible the river is when nothing is moving. 1 is almost invisible, 5 keeps it as bright as a move.
[*][b]Current line[/b]: show or hide the current itself.
[*][b]Panel[/b]: position and size.
[/list]

Everything else, the shape of the layers, the smoothing of the colours, the slack zone and the wake memory, is fixed. Those numbers are right or wrong rather than a matter of taste, and we would rather you didn't have to think about them.

█ [b]ALERTS[/b]

[list]
[*]Current turned up, Current turned down.
[*]Price left the stream, Price rejoined the stream.
[*]Pullback to the current.
[*]Wake stretched, Wake fading.
[/list]

Set them to "Once per bar close". Events are only ever confirmed on a closed bar.

█ [b]NOTES AND LIMITS[/b]

[list]
[*]The river lags, by construction. The current is a double smoothing and turns some bars after price does; the slow water turns long after. The wake is that lag, drawn. A V-shaped reversal will always be a few bars old before the current turns, and the outer layers keep the old colour for a while. That is the honest picture of a smoothed trend tool, and it is why the depth of a turn is shown rather than hidden.
[*]In a sideways market the current can change colour several times before the slack zone catches it. The slack zone and the colour steps remove most of the flicker, not all of it. A river that keeps changing colour with no wake is itself the read: nothing is flowing.
[*]Stretched is relative. It compares the present wake with the last twenty on your chart and needs at least five of them, so it stays silent early in a short history. In a market that has only chopped for weeks, the first real move will read as stretched almost at once.
[*]Everything is in ATRs. When a symbol's volatility changes regime, the river's width and the events adjust with it. That is the point, but it means 1.5 ATRs is a different distance on different days.
[*]The pullback event looks for one sequence, left the stream on the flowing side, back to the current, closed on the flowing side, and will miss pullbacks that never quite reach the current or never quite left the stream. It fires on the close that completes the sequence, never earlier.
[*]Only the last 1,500 bars are drawn, to keep the chart quick. A hidden copy of the indicator still calculates, so remove any you aren't using.
[*]The river is six gradient fills. On very long charts or slow machines, lower History first.
[/list]

█ [b]DISCLAIMER[/b]

This script is for education and information. It isn't financial advice, a recommendation to buy or sell anything, or a promise about what any market will do. Past behaviour of a market, a method or an indicator doesn't guarantee future results, and nothing on this chart replaces your own judgement. Trading involves risk and you are responsible for your decisions.

## Source Code

````pine
//@version=6
// Stream Master
//
// The market drawn as a river. The current is a smoothed centre of price. Around it,
// three bands of water follow the current with more and more lag, from a band that
// hugs it to a band that follows a much slower version of it, each drawn as a smooth
// gradient. In a move, the slow water trails behind the fast and the river leaves a
// wake: long and bright when the move is fast, gone when the market stalls. Each edge
// takes the up colour while it is flowing up and the down colour while it is flowing
// down, so a turn passes through the river from the inside out.
//
// The panel reads the river in words: which way the current flows and how hard, how
// many of the four layers have turned, how long the wake is and whether it is growing,
// stretched, fading or turning, and where price sits. Alerts carry the events: the
// current turning, price leaving or rejoining the stream, a pullback to the current
// that holds, the wake stretching further than recent wakes, and the wake fading.

indicator("Stream Master [SimpleAlgo]", "Stream Master [SimpleAlgo]", overlay = true)

// ───────────────────────── Settings ─────────────────────────

grpS = "Stream"
fastLen  = input.int(10, "Current (bars)", minval = 2, maxval = 60, group = grpS, tooltip = "The current is price smoothed twice over this many bars. Lower follows price more closely, higher is calmer.")
slowLen  = input.int(60, "Wake (bars)", minval = 10, maxval = 300, group = grpS, tooltip = "The slow water at the edge of the river is price smoothed twice over this many bars. The bigger the gap between this and the current, the longer the wake a move leaves.")
widthIn  = input.float(3.5, "River width (ATRs)", minval = 0.5, maxval = 10.0, step = 0.5, group = grpS, tooltip = "How wide the river is when the market is slack, in ATRs each side of the current.")
histIn   = input.int(1500, "History (bars)", minval = 200, maxval = 5000, step = 100, group = grpS, tooltip = "How far back the river is drawn. Scroll further back and it simply stops. Lower this if your chart feels slow.")

grpE = "Events"
leaveIn  = input.float(1.5, "Price has left the stream at (ATRs)", minval = 0.5, maxval = 5.0, step = 0.25, group = grpE, tooltip = "How far price has to close from the current before it counts as having left the stream.")
joinIn   = input.float(0.75, "And is back on it within (ATRs)", minval = 0.1, maxval = 3.0, step = 0.25, group = grpE)
pullIn   = input.float(0.25, "A pullback reaches the current within (ATRs)", minval = 0.0, maxval = 2.0, step = 0.25, group = grpE, tooltip = "After price has left the stream on the side the river is flowing, a pullback counts when a bar comes back to within this distance of the current and then closes back on the flowing side of it.")

grpL = "Look"
themeIn   = input.string("Neon", "Theme", options = ["Neon", "Classic", "Aurora", "Ice", "Custom"], group = grpL)
baseIn    = input.color(#7B9CFF, "Slack", group = grpL, inline = "c")
upIn      = input.color(#00FFA3, "Up", group = grpL, inline = "c")
dnIn      = input.color(#FF3D71, "Down", group = grpL, inline = "c")
bright    = input.int(3, "Brightness", minval = 1, maxval = 5, group = grpL)
slackDim  = input.int(2, "Slack water", minval = 1, maxval = 5, group = grpL, tooltip = "How visible the river is when nothing is moving. 1 is almost invisible, 5 keeps it as bright as a move.")
showCore  = input.bool(true, "Current line", group = grpL)
showPanel = input.bool(true, "Panel", group = grpL, inline = "p")
panelPos  = input.string("Top right", "", options = ["Top left", "Top right", "Bottom left", "Bottom right"], group = grpL, inline = "p")
panelSize = input.string("Normal", "", options = ["Small", "Normal", "Large"], group = grpL, inline = "p")

[colBase, colUp, colDn, colPanel] = switch themeIn
    "Neon"    => [#7B9CFF, #00FFA3, #FF3D71, #262B38]
    "Classic" => [#5B8DEF, #00FF31, #FF0013, #23262F]
    "Aurora"  => [#A78BFA, #34D399, #F472B6, #262B38]
    "Ice"     => [#67E8F9, #7DD3FC, #FDA4AF, #1E293B]
    => [baseIn, upIn, dnIn, #262B38]

// fixed tuning: how the layers are spread between the current and the slow water, how
// the width, the direction and the layer colours are smoothed, when a slope counts as
// flowing, and how many finished wakes are remembered to judge whether the present one
// is stretched
float shapeK     = 1.5
int   atrLen     = 20
int   dirLen     = 8       // smoothing of the current's slope, which sets its direction
int   colLen     = 12      // smoothing of each layer's slope, which sets its colour
float fullAt     = 0.12    // ATRs per bar for full colour
float deadAt     = 0.15    // below this share of full colour a layer is slack
int   keepWakes  = 20
int   stretchPct = 75      // a wake longer than this share of remembered wakes is stretched

// ───────────────────────── The current ─────────────────────────

float atr    = nz(ta.atr(14), high - low)
float atrS   = ta.ema(atr, atrLen)
float centre = ta.ema(ta.ema(close, fastLen), fastLen)
float cslow  = ta.ema(ta.ema(close, slowLen), slowLen)
// the flow is the current's slope in ATRs per bar, smoothed, and t is the flow as a share
// of full colour, from -1 to 1. The wake is how far the current has run ahead of the slow
// water, in ATRs.
float slope  = (centre - nz(centre[1], centre)) / atr
float flow   = ta.ema(slope, dirLen)
float t      = math.max(-1.0, math.min(1.0, flow / fullAt))
float wake   = (centre - cslow) / atr
float wakeAbs = math.abs(wake)

// the current flows one way until its slope has crossed the dead zone to the other side
var int dir = 0
var int turnBar = na
int prevDir = dir
if t >= deadAt
    dir := 1
else if t <= -deadAt
    dir := -1
if dir != prevDir
    turnBar := bar_index

// the wake: which way it points, its longest so far, whether it is growing or fading, and
// how it compares with the wakes before it
var peaks = array.new_float()
int wakeSign = wake > 0.5 ? 1 : wake < -0.5 ? -1 : 0
var int wakeSide = 0
var float wakePeak = 0.0
var bool fadeFired = false
var bool stretchFired = false
if wakeSign != wakeSide
    if wakeSide != 0
        array.push(peaks, wakePeak)
        if array.size(peaks) > keepWakes
            array.shift(peaks)
    wakeSide := wakeSign
    wakePeak := wakeAbs
    fadeFired := false
    stretchFired := false
else if wakeAbs > wakePeak
    wakePeak := wakeAbs
bool  wakeOn        = wakeSide != 0
bool  wakeTurning   = wakeOn and dir != 0 and dir != wakeSide
bool  wakeFading    = wakeOn and not wakeTurning and wakeAbs < wakePeak * 0.75
bool  wakeGrowing   = wakeOn and not wakeTurning and wakeAbs >= wakePeak * 0.98
float stretchAt     = array.size(peaks) >= 5 ? array.percentile_nearest_rank(peaks, stretchPct) : na
bool  wakeStretched = wakeOn and not na(stretchAt) and wakeAbs >= stretchAt

// ───────────────────────── Price and the stream ─────────────────────────

// where price is relative to the current, in ATRs
float dist = (close - centre) / atr

// leaving and rejoining the stream
var bool outside = false
var int outSide = 0
bool leftNow = false
bool backNow = false
if not outside and math.abs(dist) >= leaveIn
    outside := true
    outSide := dist > 0 ? 1 : -1
    leftNow := true
else if outside and math.abs(dist) <= joinIn
    outside := false
    backNow := true

// a pullback: price has left the stream on the side the river is flowing, comes back to
// the current, and closes back on the flowing side of it
int pullCtx = wakeOn and dir == wakeSide ? dir : 0
var int ahead = 0
var bool reached = false
if pullCtx == 0
    ahead := 0
    reached := false
else if outside and outSide == pullCtx
    ahead := pullCtx
bool touched = pullCtx == 1 ? low <= centre + pullIn * atr : high >= centre - pullIn * atr
if ahead != 0 and touched
    reached := true
bool pullDone = reached and (pullCtx == 1 ? close > centre : close < centre)
if pullDone
    ahead := 0
    reached := false

// one event a bar, the most important first
// 1 turned up, -1 turned down, 2 left above, -2 left below, 3 rejoined from above,
// -3 rejoined from below, 4 wake fading, 5 pullback held above, -5 pullback held below, 6 wake stretched
int evt = dir != prevDir ? dir : pullDone ? pullCtx * 5 : leftNow ? outSide * 2 : backNow ? outSide * 3 : (wakeFading and not fadeFired) ? 4 : (wakeStretched and not stretchFired) ? 6 : 0
if evt == 4
    fadeFired := true
if evt == 6
    stretchFired := true

bool fire = evt != 0 and barstate.isconfirmed
var int lastEvt = 0
var int lastEvtBar = na
if fire
    lastEvt := evt
    lastEvtBar := bar_index

// ───────────────────────── The river ─────────────────────────

// how far a slope is past the dead zone, 0 at its edge and 1 at full colour, so colour
// and brightness rise smoothly out of slack water instead of jumping
ramp(float x) =>
    float a = math.abs(x)
    a < deadAt ? 0.0 : (a - deadAt) / (1 - deadAt)

// colour by the direction a layer is flowing. A slope inside the dead zone is drawn
// slack, so the river does not flicker between colours while nothing is moving.
tint(float x) =>
    float s = ramp(x)
    x >= 0 ? color.from_gradient(s, 0, 1, colBase, colUp) : color.from_gradient(s, 0, 1, colBase, colDn)

// a layer's colour is held to steps of a tenth, and a step only moves once the slope has
// travelled a full step, so a fill keeps one colour for a run of bars instead of
// flickering between two shades while the slope sits on a boundary
steps(float raw) =>
    var float held = 0.0
    if raw >= held + 0.1
        held := math.floor(raw * 10) / 10
    else if raw <= held - 0.1
        held := math.ceil(raw * 10) / 10
    held

float brightMul = 0.4 + 0.2 * bright
float slackMul  = 0.15 + 0.15 * slackDim
bool  active    = last_bar_index - bar_index <= histIn

// One edge of the river, f = 0 at the current and 1 at the slow water. The edge's
// reference blends from the current to the slow water, its width grows with f, and its
// own slope sets its colour, so a turn shows up at the inner edges first.
edge(float f) =>
    float ref = cslow + (centre - cslow) * math.pow(1 - f, shapeK)
    float sl  = (ref - nz(ref[1], ref)) / atr
    float fl  = ta.ema(sl, colLen)
    float tj  = steps(math.max(-1.0, math.min(1.0, fl / fullAt)))
    float w   = f * widthIn * atrS
    [active ? ref + w : na, active ? ref - w : na, tj]

// brightest at the current, fading to the slow water, and dimmer when the edge is slack
edgeColor(float f, float tj) =>
    float alpha = (0.30 * (1 - f) + 0.04) * brightMul * (slackMul + (1 - slackMul) * ramp(tj))
    int transp = math.min(99, math.max(0, math.round(100 - alpha * 100)))
    color.new(tint(tj), transp)

// Each band is one gradient fill between two edges: the colour runs from the inner
// edge's colour at the inner edge to the outer edge's colour at the outer edge. In a
// wake the outer edge can sit on the far side of the inner one, so the gradient is
// always given its higher and lower value explicitly.
band(float yIn, float yOut, color cIn, color cOut) =>
    bool inAbove = yIn >= yOut
    [math.max(yIn, yOut), math.min(yIn, yOut), inAbove ? cIn : cOut, inAbove ? cOut : cIn]

float t0 = steps(t)
[u1, d1, t1] = edge(0.35)
[u2, d2, t2] = edge(0.70)
[u3, d3, t3] = edge(1.00)
color c0 = edgeColor(0.00, t0)
color c1 = edgeColor(0.35, t1)
color c2 = edgeColor(0.70, t2)
color c3 = edgeColor(1.00, t3)

pC  = plot(active ? centre : na, "", color = na, display = display.none, editable = false)
pU1 = plot(u1, "", color = na, display = display.none, editable = false)
pU2 = plot(u2, "", color = na, display = display.none, editable = false)
pU3 = plot(u3, "", color = na, display = display.none, editable = false)
pD1 = plot(d1, "", color = na, display = display.none, editable = false)
pD2 = plot(d2, "", color = na, display = display.none, editable = false)
pD3 = plot(d3, "", color = na, display = display.none, editable = false)

[hiU1, loU1, hiCU1, loCU1] = band(centre, u1, c0, c1)
[hiU2, loU2, hiCU2, loCU2] = band(u1, u2, c1, c2)
[hiU3, loU3, hiCU3, loCU3] = band(u2, u3, c2, c3)
[hiD1, loD1, hiCD1, loCD1] = band(centre, d1, c0, c1)
[hiD2, loD2, hiCD2, loCD2] = band(d1, d2, c1, c2)
[hiD3, loD3, hiCD3, loCD3] = band(d2, d3, c2, c3)

fill(pC,  pU1, hiU1, loU1, hiCU1, loCU1, title = "River", editable = false)
fill(pU1, pU2, hiU2, loU2, hiCU2, loCU2, title = "River", editable = false)
fill(pU2, pU3, hiU3, loU3, hiCU3, loCU3, title = "River", editable = false)
fill(pC,  pD1, hiD1, loD1, hiCD1, loCD1, title = "River", editable = false)
fill(pD1, pD2, hiD2, loD2, hiCD2, loCD2, title = "River", editable = false)
fill(pD2, pD3, hiD3, loD3, hiCD3, loCD3, title = "River", editable = false)

// the current itself, with a soft glow
color coreCol = tint(t)
plot(showCore ? centre : na, "Current glow", color = color.new(coreCol, 86), linewidth = 6, display = display.pane, editable = false)
plot(showCore ? centre : na, "Current", color = coreCol, linewidth = 2, display = display.pane)

// how many of the four layers (the current and the three edges) are flowing each way
flowing(float x) =>
    math.abs(x) < deadAt ? 0 : x > 0 ? 1 : -1
int f0 = flowing(t)
int f1 = flowing(t1)
int f2 = flowing(t2)
int f3 = flowing(t3)
int nUp = (f0 == 1 ? 1 : 0) + (f1 == 1 ? 1 : 0) + (f2 == 1 ? 1 : 0) + (f3 == 1 ? 1 : 0)
int nDn = (f0 == -1 ? 1 : 0) + (f1 == -1 ? 1 : 0) + (f2 == -1 ? 1 : 0) + (f3 == -1 ? 1 : 0)

// ───────────────────────── Panel ─────────────────────────

eventName(int e) =>
    switch e
        1  => "Current turned up"
        -1 => "Current turned down"
        2  => "Price left the stream above"
        -2 => "Price left the stream below"
        3  => "Price rejoined from above"
        -3 => "Price rejoined from below"
        4  => "Wake fading"
        5  => "Pullback held above the current"
        -5 => "Pullback held below the current"
        6  => "Wake stretched"
        => "None yet"

eventColor(int e, color up, color dn, color plain) =>
    e == 1 or e == 2 or e == -3 or e == 5 ? up : e == -1 or e == -2 or e == 3 or e == -5 ? dn : plain

var table panel = na
if showPanel and barstate.islast
    if na(panel)
        tablePos = switch panelPos
            "Top left"     => position.top_left
            "Bottom left"  => position.bottom_left
            "Bottom right" => position.bottom_right
            => position.top_right
        panel := table.new(tablePos, 2, 7, bgcolor = color.new(colPanel, 15), frame_color = color.new(colPanel, 0), frame_width = 1, border_width = 0)
    txtSize = panelSize == "Small" ? size.small : panelSize == "Large" ? size.large : size.normal
    color txt = #D1D4DC
    color dim = color.new(#D1D4DC, 40)
    float strength = math.abs(t)
    bool slack = strength < deadAt
    string strTxt = strength >= 0.66 ? "strong" : strength >= 0.33 ? "moderate" : "weak"
    string curTxt = slack ? "Slack" : (dir == 1 ? "Flowing up, " : "Flowing down, ") + strTxt
    color curCol = slack ? colBase : dir == 1 ? colUp : colDn
    string layTxt = nUp == 0 and nDn == 0 ? "All slack" : nDn == 0 ? str.tostring(nUp) + " of 4 flowing up" : nUp == 0 ? str.tostring(nDn) + " of 4 flowing down" : str.tostring(nUp) + " up, " + str.tostring(nDn) + " down"
    color layCol = nUp == 0 and nDn == 0 ? colBase : nUp > nDn ? colUp : nDn > nUp ? colDn : txt
    string wakeState = wakeTurning ? ", turning" : wakeFading ? ", fading" : wakeStretched ? ", stretched" : wakeGrowing ? ", growing" : ""
    string wakeTxt = not wakeOn ? "None" : (wakeSide == 1 ? "Up, " : "Down, ") + str.tostring(wakeAbs, "#.#") + " ATR" + wakeState
    color wakeCol = not wakeOn ? txt : wakeSide == 1 ? colUp : colDn
    string priceTxt = math.abs(dist) < joinIn ? "On the stream" : (dist > 0 ? "Above it by " : "Below it by ") + str.tostring(math.abs(dist), "#.#") + " ATR"
    color priceCol = math.abs(dist) < joinIn ? txt : dist > 0 ? colUp : colDn
    int sinceBars = na(turnBar) ? 0 : bar_index - turnBar
    string sinceTxt = na(turnBar) ? "" : sinceBars == 0 ? "This bar" : sinceBars == 1 ? "1 bar" : str.tostring(sinceBars) + " bars"
    int agoBars = na(lastEvtBar) ? 0 : bar_index - lastEvtBar
    string ago = na(lastEvtBar) ? "" : agoBars == 0 ? ", this bar" : agoBars == 1 ? ", 1 bar ago" : ", " + str.tostring(agoBars) + " bars ago"
    // an event on the live bar is shown as pending until the bar closes
    bool pending = evt != 0 and not barstate.isconfirmed
    string evtTxt = pending ? eventName(evt) + ", confirms on close" : eventName(lastEvt) + ago
    color evtCol = pending ? dim : lastEvt == 4 or lastEvt == 6 ? wakeCol : eventColor(lastEvt, colUp, colDn, txt)
    table.cell(panel, 0, 0, "STREAM MASTER", text_color = txt, text_size = txtSize, text_halign = text.align_left)
    table.cell(panel, 1, 0, "", text_color = dim, text_size = txtSize, text_halign = text.align_right)
    table.cell(panel, 0, 1, "Current", text_color = dim, text_size = txtSize, text_halign = text.align_left)
    table.cell(panel, 1, 1, curTxt, text_color = curCol, text_size = txtSize, text_halign = text.align_right)
    table.cell(panel, 0, 2, "Layers", text_color = dim, text_size = txtSize, text_halign = text.align_left)
    table.cell(panel, 1, 2, layTxt, text_color = layCol, text_size = txtSize, text_halign = text.align_right)
    table.cell(panel, 0, 3, "Wake", text_color = dim, text_size = txtSize, text_halign = text.align_left)
    table.cell(panel, 1, 3, wakeTxt, text_color = wakeCol, text_size = txtSize, text_halign = text.align_right)
    table.cell(panel, 0, 4, "Price", text_color = dim, text_size = txtSize, text_halign = text.align_left)
    table.cell(panel, 1, 4, priceTxt, text_color = priceCol, text_size = txtSize, text_halign = text.align_right)
    table.cell(panel, 0, 5, "Since the turn", text_color = dim, text_size = txtSize, text_halign = text.align_left)
    table.cell(panel, 1, 5, sinceTxt, text_color = txt, text_size = txtSize, text_halign = text.align_right)
    table.cell(panel, 0, 6, "Last event", text_color = dim, text_size = txtSize, text_halign = text.align_left)
    table.cell(panel, 1, 6, evtTxt, text_color = evtCol, text_size = txtSize, text_halign = text.align_right)

// ───────────────────────── Alerts ─────────────────────────

alertcondition(fire and evt == 1,  "Current turned up",       "Stream Master: the current turned up")
alertcondition(fire and evt == -1, "Current turned down",     "Stream Master: the current turned down")
alertcondition(fire and (evt == 2 or evt == -2),  "Price left the stream",     "Stream Master: price has left the stream")
alertcondition(fire and (evt == 3 or evt == -3),  "Price rejoined the stream", "Stream Master: price is back on the stream")
alertcondition(fire and (evt == 5 or evt == -5),  "Pullback to the current",   "Stream Master: price pulled back to the current and held")
alertcondition(fire and evt == 6,  "Wake stretched",          "Stream Master: the wake is longer than most recent wakes, the move is stretched")
alertcondition(fire and evt == 4,  "Wake fading",             "Stream Master: the wake is fading, the move is losing speed")
````
