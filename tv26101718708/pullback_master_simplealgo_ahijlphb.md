# Pullback Master [SimpleAlgo]

- url: https://www.tradingview.com/script/AHIjLPHB-Pullback-Master-SimpleAlgo/
- type: indicator
- pine_id: PUB;120f19cb07e5475bac01d6058127614d
- version: 1.0

## Description

█ [b]INTRODUCING PULLBACK MASTER[/b]

Every trend trader is told the same thing: buy the pullback. Nobody tells them which one. The first pullback of a new trend and the sixth pullback of an old one look identical on a chart with a moving average on it, and they are not the same trade.

[b]Pullback Master[/b] counts them. It finds a trend, watches price come back to the trend average and lift off again, and counts each pullback that holds. It measures how deep each one went, notes whether price closed through the average on the way, and tells you whether the pullbacks are getting shallower or deeper. Then it shows the count on the chart without a single label: the ribbon behind the trend average charges up with each pullback that holds, brightest around the third and fourth, and fades again as the trend gets old.

https://www.tradingview.com/x/nUCtk6AK/

There are no labels on the chart. The ribbon's colour says whether there is a trend, its brightness says how far along the trend is, and a soft glow marks each place price came back to the average. The panel in the corner says it in words: the trend and its age, how many pullbacks have held and whether they are getting deeper, how the last one behaved, where price sits against the long-term average, and the last event. The five moments worth knowing about are alerts.

https://www.tradingview.com/x/5btZNMXS/

⚪ [b]The ribbon[/b]

The ribbon is a fan of seven averages behind the trend average, from 15% longer to two and a half times longer. In a trend they spread out behind the trend average like a comet tail; in chop they collapse onto it. The whole fan is one colour: mint in an uptrend, pink in a downtrend, the no-trend blue when there is neither. It is densest at the trend average and fades outward, so the eye lands on the line price actually pulls back to.

⚪ [b]The count[/b]

Each pullback that holds raises the ribbon's brightness one step: dim with none, brighter at one and two, brightest at three and four, then fading from the fifth on. That is the whole read in one glance: a dim ribbon in a trend is either a fresh trend or a tired one, and the panel says which.

⚪ [b]What's different[/b]

A moving average ribbon shows you a trend. This one shows you where you are in it. The pullbacks are counted, measured and graded, the ribbon carries the count, and the panel reads the trend's health off them: shallower pullbacks are a healthy trend, deeper ones are a tiring one, a pullback that closed through the average is weaker than one that held cleanly. None of that is in the picture a ribbon gives you.

█ [b]HOW IT WORKS[/b]

⚪ [b]1. The averages[/b]

The trend average is a 20-bar EMA. The fan behind it is seven more, each longer than the last by a growing step, so the layers sit tight near the trend average and spread further out:

[pine]
float e0 = ta.ema(close, fastLen)
float e1 = ta.ema(close, math.round(fastLen * 1.15))
[/pine]

[pine]
float e7 = ta.ema(close, math.round(fastLen * 2.50))
[/pine]

A 200-bar EMA is drawn as a thin grey line for context, and everything is measured in ATRs, so the same rules mean the same thing on gold, on bitcoin and on a stock:

[pine]
float atr  = nz(ta.atr(14), high - low)
[/pine]

⚪ [b]2. When a trend starts[/b]

Three things have to be true on a closed bar. The trend average has to be rising steeply enough, a quarter of an ATR over the last five bars by default; the fan has to have opened, with the trend average above its slowest layer; and price has to close above the trend average on an up candle:

[pine]
float rise = (e0 - nz(e0[5], e0)) / atr
[/pine]

[pine]
bool okUp = rise > slopeMin and e0 > e7 and close > e0 and close > open and (not use200 or close > nz(slow, close))
[/pine]

A downtrend is the mirror. And none of this is looked at while the market is choppy, which means price has closed through the trend average more than twice in the last twenty bars:

[pine]
float crosses = math.sum(ta.cross(close, e0) ? 1.0 : 0.0, 20)
bool  choppy  = crosses > chopMax
[/pine]

⚪ [b]3. When a trend ends[/b]

A trend ends when the trend average has turned the other way, or when price closes out the far side of the fan while the average is no longer rising:

[pine]
if rise < -slopeMin or (close < e7 and rise <= 0)
[/pine]

That rule is deliberately slow. A sharp dip inside a strong trend is a deep pullback, not an ending, and it should count as one. If the same trend comes back within ten bars of ending, it resumes with its pullback count intact, so one bad bar doesn't reset the count.

⚪ [b]4. A pullback[/b]

A pullback begins when price has first moved at least three quarters of an ATR away from the trend average and then comes back to within a fifth of an ATR of it:

[pine]
away := math.max(away, (close - e0) / atr)
if low <= e0 + atr * nearTol and clearBars >= sepBars and away >= awayMin
[/pine]

The distance rule is what makes the count mean something. Without it, a trend that rides along its average would count a pullback every few bars. With it, a pullback is a real swing away and back.

While the pullback is on, the script records its deepest point and whether any bar closed through the average. It holds when price closes back above the average on an up candle:

[pine]
if close > e0 and close > open
[/pine]

That is the moment the count goes up, the depth is measured, and the pullback is graded clean or closed through:

[pine]
lastDepth := (e0 - pullExt) / atr
lastClean := not pierced
[/pine]

https://www.tradingview.com/x/TjtGEzXd/

⚪ [b]5. Grading[/b]

Two things are graded. Depth: how far past the average the pullback reached, in ATRs. A pullback that bounced before the average reads as held at the average. And cleanliness: whether any bar closed through the average before it recovered. A clean, shallow pullback is the trend at its healthiest. A pullback that closed through and reached an ATR past the average is counted, because it held in the end, but the panel shows it in the down colour and the Pullbacks row says whether the pullbacks are getting deeper.

https://www.tradingview.com/x/XPBbnfsE/

⚪ [b]6. The ribbon's brightness[/b]

The fan's transparency is set by the count, so the count is on the chart without a label:

[pine]
float charge = phase == 0 ? 0.30 : count == 0 ? 0.45 : count == 1 ? 0.80 : count == 2 ? 1.20 : count <= 4 ? 1.70 : count == 5 ? 1.25 : 0.90
[/pine]

While price is at the average the ribbon glows, and the glow dies away over the following bars, so each pullback leaves a soft mark in the ribbon where it happened. The glow is smoothed and held to steps so it reads as a patch of light, not a stripe:

[pine]
glowRaw := glowRaw * 0.88 + (inPull ? 0.12 : 0.0)
[/pine]

https://www.tradingview.com/x/yPVlXXXO/

⚪ [b]7. Candles[/b]

Candles take the trend colour, with counter-trend bars muted and no-trend bars dim, so a screenshot reads at a glance. Turn it off in the settings if you prefer your own candle colours.

⚪ [b]8. The panel[/b]

[list]
[*][b]Trend[/b]: Up or Down and how many bars old, None, or None, choppy while the stand-aside rule is on.
[*][b]Pullbacks[/b]: how many have held in this trend, and whether they are getting shallower or deeper. With no trend, the count from the last trend stays up.
[*][b]Last pullback[/b]: Clean or Closed through, and how far past the average it reached.
[*][b]200 average[/b]: whether price is above or below the long-term average.
[*][b]Last event[/b]: the most recent event and how long ago.
[/list]

https://www.tradingview.com/x/sTXDmKRN/

⚪ [b]Repainting[/b]

Every decision is made on closed bars only. The ribbon and the averages update on the live bar like any moving average does, but a trend, a pullback and its grade are only ever decided when the bar closes, and never change afterwards.

█ [b]WHY IT IS ORIGINAL[/b]

The ingredients are a fan of EMAs and an ATR, and we won't pretend otherwise. What is new is what is done with them. A ribbon tells you the direction and, by its width, roughly the strength. Pullback Master treats the pullbacks inside a trend as the unit of analysis: it defines one precisely, a swing away from the average and a return that lifts off, counts them, measures each one's depth and whether it closed through, and reads the trend's health from how the sequence is changing. The ribbon's brightness is driven by that count, so the chart carries the reading with no labels, and the panel states it in words. The distance rule, the slow ending rule and the resume rule exist so that the count means what a trader means by "the third pullback". None of that is in a ribbon or a moving average crossover.

█ [b]HOW TO USE IT[/b]

⚪ [b]Colour first[/b]

Mint, there is an uptrend. Pink, a downtrend. Blue, there is no trend, and the panel will say if that is because the market is choppy. A blue ribbon is the one reading most trend tools skip: it means the average is not something to buy pullbacks to right now.

⚪ [b]Then the brightness[/b]

A dim mint ribbon with a low count is a young trend. A bright one is a trend that has held two, three or four pullbacks: proven, and still with room. A ribbon that has dimmed again after the fifth is a trend that has been going a long time, and the Pullbacks row will usually say the pullbacks are getting deeper by then.

⚪ [b]The pullback itself[/b]

The only moment worth waiting for is the one the alert names: price came back to the average and lifted off. Read the grade before acting on it. A clean, shallow pullback in a bright ribbon is the textbook setup. A pullback that closed through, in a trend whose pullbacks are getting deeper, is a trend being tested, and the next one often doesn't hold.

⚪ [b]Timeframes[/b]

With the defaults a trend is a 20-bar structure, so on a 5-minute chart a trend lasts hours and holds several pullbacks a session, on a 1-hour chart it lasts days, and on a daily chart it is a quarter or more. On higher timeframes trends hold fewer pullbacks, so the count stays low and the ribbon rarely reaches its brightest; that is the market, not the script.

https://www.tradingview.com/x/zagYx7bZ/

⚪ [b]If you're new[/b]

Three sentences. The coloured line is the trend's average, and the fan behind it lights up while there is a trend worth following: mint up, pink down, blue none. Each time price comes back to the line and bounces, that is a pullback that held, and the fan gets brighter, up to the third or fourth, then dimmer. The best pullbacks are the early, shallow, clean ones in a bright fan; the ones to be careful with are the deep ones in a trend that is already old.

None of this predicts where price goes. A pullback that held is a description of what just happened, not a signal to buy or sell. Use it with your own analysis and manage your risk.

█ [b]SETTINGS[/b]

⚪ [b]Averages[/b]

[list]
[*][b]Trend average (bars)[/b]: the average price pulls back to. 20 by default.
[*][b]Long-term average (bars)[/b]: the context line. 200 by default.
[*][b]Show the long-term average[/b]: on by default.
[/list]

⚪ [b]Trend[/b]

[list]
[*][b]Trend strictness[/b]: how steep the trend average has to be before a trend counts. Normal by default. Strict means fewer, cleaner trends; Relaxed catches more and ends more in chop.
[*][b]Only count trends on the right side of the long-term average[/b]: uptrends only above it, downtrends only below it. Off by default.
[*][b]Also alert on pullback number[/b]: every pullback that holds has an alert. This one gets its own, so you can be told about the second or third pullback of a trend and nothing else. 3 by default.
[/list]

⚪ [b]Look[/b]

[list]
[*][b]Theme[/b]: Neon, Classic, Aurora, Ice, or Custom with your own up, down and no-trend colours.
[*][b]Brightness[/b]: 1 to 5, for your screen and background.
[*][b]Colour candles by trend[/b]: on by default.
[*][b]Panel[/b]: position and size.
[/list]

Everything else, the fan's spacing, the chop rule, the distance a pullback has to travel, the resume window and the brightness steps, is fixed. Those numbers are right or wrong rather than a matter of taste, and we would rather you didn't have to think about them.

█ [b]ALERTS[/b]

[list]
[*]New uptrend, New downtrend.
[*]Pullback held.
[*]Chosen pullback held (the number you set).
[*]Trend ended.
[/list]

Set them to "Once per bar close". Everything is decided on closed bars.

█ [b]NOTES AND LIMITS[/b]

[list]
[*]A trend starts late by design. It needs a rising average, an open fan and a close on the right side, which usually means the first leg is already in. The first pullback is the earliest the script will put you in a trend, and that is the point: it is a pullback tool, not a breakout tool.
[*]A trend ends late too. The ending rule is slow so that deep pullbacks count as pullbacks. The cost is that a real reversal is a few bars old before the ribbon turns blue.
[*]The distance rule means a trend that grinds along its average without ever leaving it counts few or no pullbacks. The ribbon stays dim and the panel says so. That is accurate: there was nothing to pull back from.
[*]Depth is in ATRs, so the same pullback reads deeper on a quiet day than on a wild one. That is the point of the unit, but keep it in mind when comparing across days.
[*]The chop rule stands aside after three closes through the average in twenty bars. In a slow, steady trend that hugs its average it can trigger falsely, and the panel will read None, choppy until the crosses age out.
[*]The count is per trend. A trend that ends and restarts outside the ten-bar resume window starts at zero again, even if it looks like the same move to you.
[*]The ribbon is seven fills. On very long charts or slow machines, this is the first thing to suspect if the chart feels heavy.
[/list]

█ [b]DISCLAIMER[/b]

This script is for education and information. It isn't financial advice, a recommendation to buy or sell anything, or a promise about what any market will do. Past behaviour of a market, a method or an indicator doesn't guarantee future results, and nothing on this chart replaces your own judgement. Trading involves risk and you are responsible for your decisions.

## Source Code

````pine
//@version=6
// Pullback Master
//
// A trend, and the pullbacks inside it, counted and graded. The trend average is price
// smoothed over 20 bars; a fan of seven slower averages opens behind it in a trend and
// collapses in chop. Every time price comes back to the trend average and lifts off
// again, that is a pullback that held, and the script counts it, measures how deep it
// went, and notes whether it closed through the average on the way.
//
// The ribbon shows the count without a single label. It charges up with each pullback
// that holds, brightest around the second and third, and fades again as the trend gets
// old. While price is at the average the ribbon glows, and the glow dies away over the
// following bars, so every pullback leaves a soft mark in the ribbon behind it.

indicator("Pullback Master [SimpleAlgo]", "Pullback Master [SimpleAlgo]", overlay = true)

// ───────────────────────── Settings ─────────────────────────

grpA = "Averages"
fastLen  = input.int(20, "Trend average (bars)", minval = 5, maxval = 200, group = grpA, tooltip = "The average price pulls back to. The ribbon fans out behind it.")
slowLen  = input.int(200, "Long-term average (bars)", minval = 50, maxval = 1000, group = grpA)
showSlow = input.bool(true, "Show the long-term average", group = grpA)

grpT = "Trend"
strictIn = input.string("Normal", "Trend strictness", options = ["Relaxed", "Normal", "Strict"], group = grpT, tooltip = "How steep the trend average has to be before a trend counts. Strict means fewer, cleaner trends.")
use200   = input.bool(false, "Only count trends on the right side of the long-term average", group = grpT, tooltip = "Uptrends only above it, downtrends only below it. Off by default: the long-term average is shown as context.")
alertN   = input.int(3, "Also alert on pullback number", minval = 1, maxval = 9, group = grpT, tooltip = "Every pullback that holds has an alert. This one gets its own, so you can be told about the second or third pullback of a trend and nothing else.")

grpL = "Look"
themeIn   = input.string("Neon", "Theme", options = ["Neon", "Classic", "Aurora", "Ice", "Custom"], group = grpL)
upIn      = input.color(#00FFA3, "Up", group = grpL, inline = "c")
dnIn      = input.color(#FF3D71, "Down", group = grpL, inline = "c")
flatIn    = input.color(#7B9CFF, "No trend", group = grpL, inline = "c")
bright    = input.int(3, "Brightness", minval = 1, maxval = 5, group = grpL)
showCandles = input.bool(true, "Colour candles by trend", group = grpL)
showPanel = input.bool(true, "Panel", group = grpL, inline = "p")
panelPos  = input.string("Top right", "", options = ["Top left", "Top right", "Bottom left", "Bottom right"], group = grpL, inline = "p")
panelSize = input.string("Normal", "", options = ["Small", "Normal", "Large"], group = grpL, inline = "p")

[colUp, colDn, colFlat, colPanel] = switch themeIn
    "Neon"    => [#00FFA3, #FF3D71, #7B9CFF, #262B38]
    "Classic" => [#00FF31, #FF0013, #5B8DEF, #23262F]
    "Aurora"  => [#34D399, #F472B6, #A78BFA, #262B38]
    "Ice"     => [#7DD3FC, #FDA4AF, #67E8F9, #1E293B]
    => [upIn, dnIn, flatIn, #262B38]

// fixed rules
float slopeMin = strictIn == "Relaxed" ? 0.15 : strictIn == "Strict" ? 0.40 : 0.25   // 5-bar rise of the trend average, in ATRs
int   chopMax  = 2     // more closes through the average than this in 20 bars: stand aside
int   sepBars  = 3     // bars clear of the average before a new pullback can start
float nearTol  = 0.2   // a pullback begins once price gets within this many ATRs of the average
float awayMin  = 0.75  // and only after price has been at least this many ATRs away from it since the last one
int   resumeIn = 10    // a trend that comes back within this many bars resumes with its count

// ───────────────────────── Averages ─────────────────────────

// the fan: lengths spread out geometrically, tight at the trend average and wider further out
float e0 = ta.ema(close, fastLen)
float e1 = ta.ema(close, math.round(fastLen * 1.15))
float e2 = ta.ema(close, math.round(fastLen * 1.30))
float e3 = ta.ema(close, math.round(fastLen * 1.50))
float e4 = ta.ema(close, math.round(fastLen * 1.70))
float e5 = ta.ema(close, math.round(fastLen * 1.95))
float e6 = ta.ema(close, math.round(fastLen * 2.20))
float e7 = ta.ema(close, math.round(fastLen * 2.50))
float slow = ta.ema(close, slowLen)
float atr  = nz(ta.atr(14), high - low)
float rise = (e0 - nz(e0[5], e0)) / atr
float crosses = math.sum(ta.cross(close, e0) ? 1.0 : 0.0, 20)
bool  choppy  = crosses > chopMax

// ───────────────────────── Trend and pullbacks ─────────────────────────
// Everything here is decided on closed bars only. A trend starts when the trend average
// is rising (or falling) steeply enough, the fan has opened behind it, and price closes
// on the right side of it. It ends when the average has turned, or when price closes out
// the far side of the fan with the average no longer rising. A sharp dip inside a strong
// trend is a deep pullback, not an ending, and a trend that comes back within a few
// bars resumes with its count intact.

var int    phase      = 0        // 1 uptrend, -1 downtrend, 0 none
var int    phaseStart = na
var int    count      = 0        // pullbacks that held in this trend
var bool   inPull     = false    // price is at the average right now
var bool   pierced    = false    // this pullback has closed through the average
var float  pullExt    = na       // deepest point of the current pullback
var float  lastDepth  = na       // depth of the last two pullbacks, in ATRs past the average
var float  prevDepth  = na
var bool   lastClean  = true
var int    clearBars  = 0
var float  away       = 0.0      // furthest price has been from the average, in ATRs, since the last pullback held
var int    lastDir    = 0
var int    lastEndBar = na
var int    lastEvt    = 0        // 1 up started, -1 down started, 2 up resumed, -2 down resumed, 3 held up, -3 held down, 4 up ended, -4 down ended
var int    lastEvtBar = na
var int    lastHeldN  = 0
bool startUp  = false
bool startDn  = false
bool heldNow  = false
bool heldN    = false
bool endedNow = false

if barstate.isconfirmed and not na(e7) and not na(e0[5])
    if phase == 1
        if rise < -slopeMin or (close < e7 and rise <= 0)
            phase := 0
            inPull := false
            endedNow := true
            lastDir := 1
            lastEndBar := bar_index
            lastEvt := 4
            lastEvtBar := bar_index
        else if inPull
            pullExt := math.min(pullExt, low)
            if close < e0
                pierced := true
            // lift-off: closed back above the average on an up candle, so the pullback held
            if close > e0 and close > open
                inPull := false
                count += 1
                prevDepth := lastDepth
                lastDepth := (e0 - pullExt) / atr
                lastClean := not pierced
                clearBars := 0
                heldNow := true
                heldN := count == alertN
                lastHeldN := count
                lastEvt := 3
                lastEvtBar := bar_index
        else
            clearBars += 1
            away := math.max(away, (close - e0) / atr)
            if low <= e0 + atr * nearTol and clearBars >= sepBars and away >= awayMin
                inPull := true
                pierced := close < e0
                pullExt := low
                away := 0.0
    else if phase == -1
        if rise > slopeMin or (close > e7 and rise >= 0)
            phase := 0
            inPull := false
            endedNow := true
            lastDir := -1
            lastEndBar := bar_index
            lastEvt := -4
            lastEvtBar := bar_index
        else if inPull
            pullExt := math.max(pullExt, high)
            if close > e0
                pierced := true
            if close < e0 and close < open
                inPull := false
                count += 1
                prevDepth := lastDepth
                lastDepth := (pullExt - e0) / atr
                lastClean := not pierced
                clearBars := 0
                heldNow := true
                heldN := count == alertN
                lastHeldN := count
                lastEvt := -3
                lastEvtBar := bar_index
        else
            clearBars += 1
            away := math.max(away, (e0 - close) / atr)
            if high >= e0 - atr * nearTol and clearBars >= sepBars and away >= awayMin
                inPull := true
                pierced := close > e0
                pullExt := high
                away := 0.0

    // no trend: watch for one to start
    if phase == 0 and not choppy
        bool okUp = rise > slopeMin and e0 > e7 and close > e0 and close > open and (not use200 or close > nz(slow, close))
        bool okDn = rise < -slopeMin and e0 < e7 and close < e0 and close < open and (not use200 or close < nz(slow, close))
        if okUp or okDn
            int dir = okUp ? 1 : -1
            bool resume = dir == lastDir and not na(lastEndBar) and bar_index - lastEndBar <= resumeIn
            phase := dir
            inPull := false
            clearBars := 0
            away := 0.0
            if not resume
                phaseStart := bar_index
                count := 0
                lastDepth := na
                prevDepth := na
                startUp := okUp
                startDn := okDn
            lastEvt := resume ? dir * 2 : dir
            lastEvtBar := bar_index

// ───────────────────────── The ribbon ─────────────────────────
// One hue for the whole fan: the trend colour in a trend, the no-trend colour otherwise,
// dense at the trend average and fading outward. The ribbon charges up with each
// pullback that holds, brightest around the second and third, and fades again as the
// trend gets old. While price is at the average the ribbon glows, and the glow dies away
// over the following bars.

color ribCol = phase == 1 ? colUp : phase == -1 ? colDn : colFlat

// how charged the ribbon is, by the number of pullbacks that have held
float charge = phase == 0 ? 0.30 : count == 0 ? 0.45 : count == 1 ? 0.80 : count == 2 ? 1.20 : count <= 4 ? 1.70 : count == 5 ? 1.25 : 0.90

// the glow of a pullback in progress, dying away afterwards, held to steps of a tenth
var float glowRaw = 0.0
glowRaw := glowRaw * 0.88 + (inPull ? 0.12 : 0.0)
float glow = math.round(glowRaw * 10) / 10

float brightMul = 0.4 + 0.2 * bright

// transparency of one band of the fan, from its base alpha
band(float base) =>
    float alpha = base * charge * (1 + 0.35 * glow) * brightMul
    int transp = int(math.round((100 - alpha * 100) / 2) * 2)
    color.new(ribCol, math.min(97, math.max(0, transp)))

p0 = plot(e0, "Trend average", color = color.new(ribCol, 10), linewidth = 2, display = display.pane)
p1 = plot(e1, "", color = na, display = display.none, editable = false)
p2 = plot(e2, "", color = na, display = display.none, editable = false)
p3 = plot(e3, "", color = na, display = display.none, editable = false)
p4 = plot(e4, "", color = na, display = display.none, editable = false)
p5 = plot(e5, "", color = na, display = display.none, editable = false)
p6 = plot(e6, "", color = na, display = display.none, editable = false)
p7 = plot(e7, "", color = na, display = display.none, editable = false)
fill(p0, p1, band(0.24), title = "Ribbon", editable = false)
fill(p1, p2, band(0.20), title = "Ribbon", editable = false)
fill(p2, p3, band(0.16), title = "Ribbon", editable = false)
fill(p3, p4, band(0.12), title = "Ribbon", editable = false)
fill(p4, p5, band(0.09), title = "Ribbon", editable = false)
fill(p5, p6, band(0.06), title = "Ribbon", editable = false)
fill(p6, p7, band(0.03), title = "Ribbon", editable = false)

plot(showSlow ? slow : na, "Long-term average", color = color.new(#8B93A7, 55), linewidth = 1, display = display.pane)

// candles: the trend colour, with counter-trend bars muted, and grey with no trend
color dimC    = #2B3040
float inten   = phase == 0 ? 0.0 : math.min(0.5 + 0.17 * count, 1.0)
color withC   = color.from_gradient(0.45 + 0.55 * inten, 0.0, 1.0, dimC, ribCol)
color candleC = phase == 0 ? color.from_gradient(0.25, 0.0, 1.0, dimC, close >= open ? colUp : colDn) : (phase == 1 ? close >= open : close <= open) ? withC : color.from_gradient(0.35, 0.0, 1.0, withC, dimC)
barcolor(showCandles ? candleC : na, title = "Trend candles", editable = false)

// ───────────────────────── Panel ─────────────────────────

eventName(int e, int n) =>
    switch e
        1  => "Uptrend started"
        -1 => "Downtrend started"
        2  => "Uptrend resumed"
        -2 => "Downtrend resumed"
        3  => "Pullback " + str.tostring(n) + " held"
        -3 => "Pullback " + str.tostring(n) + " held"
        4  => "Uptrend ended"
        -4 => "Downtrend ended"
        => "None yet"

var table panel = na
if showPanel and barstate.islast
    if na(panel)
        tablePos = switch panelPos
            "Top left"     => position.top_left
            "Bottom left"  => position.bottom_left
            "Bottom right" => position.bottom_right
            => position.top_right
        panel := table.new(tablePos, 2, 6, bgcolor = color.new(colPanel, 15), frame_color = color.new(colPanel, 0), frame_width = 1, border_width = 0)
    txtSize = panelSize == "Small" ? size.small : panelSize == "Large" ? size.large : size.normal
    color txt = #D1D4DC
    color dim = color.new(#D1D4DC, 40)
    color pCol = phase == 1 ? colUp : phase == -1 ? colDn : txt
    int sinceBars = na(phaseStart) ? 0 : bar_index - phaseStart
    string barsTxt = sinceBars == 1 ? "1 bar" : str.tostring(sinceBars) + " bars"
    string trendTxt = phase == 1 ? "Up, " + barsTxt : phase == -1 ? "Down, " + barsTxt : choppy ? "None, choppy" : "None"
    string depthTxt = na(prevDepth) ? "" : lastDepth > prevDepth + 0.1 ? ", getting deeper" : lastDepth < prevDepth - 0.1 ? ", getting shallower" : ", about the same"
    string pullTxt = phase == 0 ? (count == 0 ? "None" : str.tostring(count) + " held in the last trend") : inPull ? (count == 0 ? "First one forming" : str.tostring(count) + " held, another forming") : count == 0 ? "None yet" : str.tostring(count) + " held" + depthTxt
    color pullCol = phase == 0 ? txt : not na(prevDepth) and lastDepth > prevDepth + 0.1 ? colDn : txt
    string lastTxt = count == 0 ? "None" : lastClean and lastDepth < 0.1 ? "Clean, held at the average" : (lastClean ? "Clean, " : "Closed through, ") + str.tostring(lastDepth, "#.#") + " ATR past the average"
    color lastCol = count == 0 ? txt : lastClean ? txt : colDn
    string slowTxt = na(slow) ? "Not enough bars" : close > slow ? "Price above" : "Price below"
    int agoBars = na(lastEvtBar) ? 0 : bar_index - lastEvtBar
    string ago = na(lastEvtBar) ? "" : agoBars == 0 ? ", this bar" : agoBars == 1 ? ", 1 bar ago" : ", " + str.tostring(agoBars) + " bars ago"
    color evtCol = lastEvt > 0 ? colUp : lastEvt < 0 ? colDn : txt
    table.cell(panel, 0, 0, "PULLBACK MASTER", text_color = txt, text_size = txtSize, text_halign = text.align_left)
    table.cell(panel, 1, 0, "", text_color = dim, text_size = txtSize, text_halign = text.align_right)
    table.cell(panel, 0, 1, "Trend", text_color = dim, text_size = txtSize, text_halign = text.align_left)
    table.cell(panel, 1, 1, trendTxt, text_color = pCol, text_size = txtSize, text_halign = text.align_right)
    table.cell(panel, 0, 2, "Pullbacks", text_color = dim, text_size = txtSize, text_halign = text.align_left)
    table.cell(panel, 1, 2, pullTxt, text_color = pullCol, text_size = txtSize, text_halign = text.align_right)
    table.cell(panel, 0, 3, "Last pullback", text_color = dim, text_size = txtSize, text_halign = text.align_left)
    table.cell(panel, 1, 3, lastTxt, text_color = lastCol, text_size = txtSize, text_halign = text.align_right)
    table.cell(panel, 0, 4, str.tostring(slowLen) + " average", text_color = dim, text_size = txtSize, text_halign = text.align_left)
    table.cell(panel, 1, 4, slowTxt, text_color = txt, text_size = txtSize, text_halign = text.align_right)
    table.cell(panel, 0, 5, "Last event", text_color = dim, text_size = txtSize, text_halign = text.align_left)
    table.cell(panel, 1, 5, eventName(lastEvt, lastHeldN) + ago, text_color = evtCol, text_size = txtSize, text_halign = text.align_right)

// ───────────────────────── Alerts ─────────────────────────

alertcondition(startUp,  "New uptrend",     "Pullback Master: a new uptrend has started")
alertcondition(startDn,  "New downtrend",   "Pullback Master: a new downtrend has started")
alertcondition(heldNow,  "Pullback held",   "Pullback Master: a pullback to the trend average held")
alertcondition(heldN,    "Chosen pullback held", "Pullback Master: the pullback you asked about held")
alertcondition(endedNow, "Trend ended",     "Pullback Master: the trend has ended")
````
