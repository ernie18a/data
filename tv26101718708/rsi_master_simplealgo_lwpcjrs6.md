# RSI Master [SimpleAlgo]

- url: https://www.tradingview.com/script/lwPCjrs6-RSI-Master-SimpleAlgo/
- type: indicator
- pine_id: PUB;6a243d9babe74396b3231b9ba83ff821
- version: 1.0

## Description

█ [b]THE RSI MASTER[/b]

RSI tells you a number. It doesn't tell you a price. You look down at the pane, see 63, and the question you actually have is the one it can't answer: how far does price have to go before this is overbought?

[b]RSI Master[/b] answers it on the chart. Every bar, it solves the RSI formula backwards and finds the exact close that would put RSI at 70 on the next bar, and the exact close that would put it at 30. Those two prices are drawn as the edges of two zones: overbought above the first, oversold below the second. When price is inside a zone it is overbought or oversold, no pane needed, and the gap between price and a zone is the room it has left.

https://www.tradingview.com/x/JsyfirgC/

The candles carry the RSI value too. They stay a quiet grey through the middle of the range, warm toward the overbought colour as RSI climbs, cool toward the oversold colour as it falls, and light fully once price is inside a zone. A dot marks the first close into a zone and a small arrow marks the exit, which is the classic RSI signal. The panel in the corner says it in words: the RSI value, the price overbought starts from and how far away it is, the same for oversold, what happened on this chart the last ten times price reached a zone, and a one-line read. Four alerts cover the events.

⚪ [b]The zones[/b]

The overbought zone is a band that is full at its edge and fades upward over about two ATRs. The oversold zone is its mirror below. The edges follow price, because the close needed to reach RSI 70 moves with every bar, so after a big up candle the overbought edge is closer than it was. That is not noise, it is the information.

⚪ [b]What's different[/b]

An RSI in a pane shows you where momentum is. RSI Master shows you where it would have to go, in the only unit that matters at the moment of a trade: price. It is not an approximation and not a band fitted around price. It is the RSI formula run in reverse, and the price it names lands RSI exactly on the level.

█ [b]HOW IT WORKS[/b]

⚪ [b]1. RSI[/b]

RSI is the standard Wilder RSI, 14 bars by default. Gains and losses are averaged with the same smoothing every charting platform uses, so the number matches the RSI in your pane:

[pine]
float up  = ta.rma(math.max(chg, 0), lenIn)
float dn  = ta.rma(-math.min(chg, 0), lenIn)
float rsi = dn == 0 ? 100 : up == 0 ? 0 : 100 - 100 / (1 + up / dn)
[/pine]

⚪ [b]2. The price behind a level[/b]

RSI next bar depends on today's averages and one unknown: tomorrow's move. So for any RSI level you can ask the formula which move would get there, and it has a closed-form answer. If the level is above where RSI sits, it takes a rise; if it is below, it takes a fall:

[pine]
priceFor(float level) =>
    float r = level / (100 - level)
    float u = (lenIn - 1) * (r * dn - up)
    u >= 0 ? close + u : close - (lenIn - 1) * (up / r - dn)
[/pine]

That is the whole engine. Run it for 70 and you have the overbought edge; run it for 30 and you have the oversold edge. We checked it numerically: a close exactly at the price it names puts RSI on 70.00 on the next bar.

Because the edges are measured from each bar's close, they move with price. A short average keeps them calm without hiding the moves that matter:

[pine]
float ob  = ta.ema(obRaw, smIn)
float os  = ta.ema(osRaw, smIn)
[/pine]

⚪ [b]3. The zones[/b]

Each zone is drawn from its edge outward, a little over two ATRs deep by default, full at the edge and fading away from price:

[pine]
float obTop = ob + depthIn * atr
float osBot = os - depthIn * atr
[/pine]

The fade is just drawing. Overbought begins at the edge and continues upward forever; the band is there so the zone is visible without covering the chart.

⚪ [b]4. In and out[/b]

Price is in a zone when RSI is at or past the level. The first bar in is an entry, the first bar out is an exit:

[pine]
bool inOB = rsi >= obIn
bool inOS = rsi <= osIn
bool enterOB = inOB and not inOB[1]
bool exitOB  = not inOB and inOB[1]
[/pine]

Entries get a dot at the candle's high or low. Exits get a small arrow, down out of overbought and up out of oversold. When price flickers in and out of a zone over a few bars, only the first exit gets an arrow, so a choppy edge doesn't turn into a row of them:

[pine]
bool arrowOB = exitOB and bar_index - lastArrowOB > 3
[/pine]

⚪ [b]5. The record[/b]

Overbought means different things on different charts. On some, reaching it is where rallies die; on others, it is where they get going. So each entry into a zone is judged by what price did next, measured from the entry close in ATRs. An overbought entry reversed if price closed a full ATR lower before it closed a full ATR higher, and followed through if the opposite happened first:

[pine]
verdict := close <= c0 - moveAt * a0 ? 1 : close >= c0 + moveAt * a0 ? 0 : -1
[/pine]

An entry that does neither within ten bars is dropped rather than guessed:

[pine]
bool expired = bar_index - array.get(evBar, i) >= judgeBars
[/pine]

The last ten verdicts for each zone are kept, and the panel shows the record for whichever zone is nearer: "Overbought reversed 7 of the last 10 times", or "Oversold bounced 4 of the last 10 times". When the record is lopsided, the read says so in words: "it tends to reverse here" at seven or more, "it tends to keep going here" at three or fewer.

https://www.tradingview.com/x/n93ROWzs/

⚪ [b]6. The candles[/b]

The candles show the RSI value between the zones. They stay a neutral grey through the middle of the range, with up candles a shade brighter than down candles, and start to take colour about a third of the way from 50 to a zone:

[pine]
float warmFrom = 50 + (obIn - 50) * 0.3
[/pine]

From there the colour builds faster than it starts, so the chart stays calm until RSI is actually getting somewhere, and is fully lit inside a zone:

[pine]
float tWarm = math.pow(math.min(math.max((rsi - warmFrom) / (obIn - warmFrom), 0.0), 1.0), 1.4)
[/pine]

[pine]
color candleCol = rsi >= 50 ? color.from_gradient(tWarm, 0, 1, neutral, colOB) : color.from_gradient(tCool, 0, 1, neutral, colOS)
[/pine]

The candles replace your chart's candle colours while they are on. Turn them off in the settings to keep your own.

⚪ [b]7. The panel[/b]

[list]
[*][b]RSI[/b]: the value, and whether it is rising, falling or flat over the last three bars.
[*][b]Overbought from[/b]: the price the overbought zone starts at, and how far away it is in ATRs, or how deep inside it price already is.
[*][b]Oversold from[/b]: the same for oversold.
[*][b]On this chart[/b]: the record for the nearer zone, out of the last ten entries.
[*][b]Read[/b]: one line. "Room to run, 2.8 ATR to overbought", "Knocking on overbought", "Overbought, 3 bars in", "Left oversold 2 bars ago", with the chart's tendency added when the record is lopsided.
[/list]

The distance in the panel is the same number the chart draws:

[pine]
float toOB = (ob - close) / atr
[/pine]

⚪ [b]Repainting[/b]

RSI changes while a bar is open, so on the live bar the edges, the candle colour and a fresh entry or exit can move until the close. The panel says "confirms on close" next to any entry or exit that happened on the live bar. Once a bar closes, nothing about it changes: the edges, the dots, the arrows and the record are final. The record is only ever written on closed bars:

[pine]
if barstate.isconfirmed
[/pine]

█ [b]WHY IT IS ORIGINAL[/b]

RSI is fifty years old and we have not changed it; that is the point. What is new is turning it inside out. Instead of asking what RSI is, the script asks what price would have to be, solves the formula for that price on every bar, and draws the answer on the chart as the two zones. The zones are exact, not fitted, and they move for a reason you can see: a big candle moves the price needed for the next one. On top of that sits a record kept per chart of what reaching a zone actually led to, read back in plain words, and candles that carry the RSI value so the number never has to be looked up. An RSI in a pane, a band drawn around price, and a candle colour keyed to RSI each exist on their own. The price behind the level, measured exactly and judged against the chart's own history, is what none of them give you.

█ [b]HOW TO USE IT[/b]

⚪ [b]Read the distance first[/b]

The most useful line in the panel is the one nobody had before: "2.8 ATR to overbought". A trade with room to run before momentum is stretched is a different trade from one that is a candle away from the zone. The edge on the chart is that same number drawn as a price, so you can set a target at it or decide not to chase into it.

⚪ [b]Then the zone[/b]

Price inside the overbought zone is overbought by the exact definition you already use, 70 on a 14-bar RSI. The candles turn fully pink so you can't miss it, and the dot marks the bar it happened. Whether that means "sell" depends on the chart, which is what the record is for.

⚪ [b]Then the record[/b]

If the panel says overbought reversed 8 of the last 10 times on this chart, fading the zone has been the right side lately. If it says 2 of the last 10, the zone has been a place rallies kept going, and the read will tell you it tends to keep going here. Take the number at face value and let it argue with your habit.

⚪ [b]The arrow[/b]

The exit from a zone is the oldest RSI signal there is: momentum stretched, then let go. The arrow marks it on the chart. It is a description of what just happened, not an instruction; combine it with the record and the rest of your analysis.

⚪ [b]Timeframes[/b]

Nothing in the script is tied to a timeframe. On a 5-minute chart the zones are a few points away and price visits them several times a session; on a daily chart they can be thousands of points away and the visits are weeks apart. The record is slower to fill on high timeframes, since it needs ten entries per zone to be worth much.

https://www.tradingview.com/x/UoRfZYsG/

⚪ [b]If you're new[/b]

Three sentences. The pink line is where overbought begins and the mint line is where oversold begins, in price, right now. Grey candles are the middle of the road; pink or mint ones are getting close, and fully lit ones are inside a zone. The panel tells you how far away each zone is and what this chart usually did the last ten times it got there.

None of this predicts where price goes. Overbought is a description of how far price has come, not a promise it will turn. Use it with your own analysis and manage your risk.

█ [b]SETTINGS[/b]

⚪ [b]RSI[/b]

[list]
[*][b]Length[/b]: 14 by default, the same as your pane.
[*][b]Overbought[/b] and [b]Oversold[/b]: 70 and 30 by default. Move them and the zones move with them.
[*][b]Smoothing (bars)[/b]: how calm the zone edges are. 3 by default. Lower is more exact and more jagged on fast charts; higher is smoother and a bar or two behind.
[/list]

⚪ [b]Look[/b]

[list]
[*][b]Theme[/b]: Neon, Classic, Aurora, Ice, or Custom with your own overbought and oversold colours.
[*][b]Brightness[/b]: 1 to 5, for your screen and background.
[*][b]Zone depth (ATR)[/b]: how far the zone's glow reaches past its edge. Drawing only; the zone itself has no far edge.
[*][b]RSI candles[/b]: on by default. Off keeps your own candle colours.
[*][b]Midline (RSI 50)[/b]: the price that would put RSI exactly at 50, as a dotted line. Off by default.
[*][b]Entry dots[/b] and [b]Exit arrows[/b]: on by default.
[*][b]Panel[/b]: position and size.
[/list]

The rules behind the record are fixed: an entry is judged within ten bars, by a full ATR either way, and the last ten verdicts per zone are kept:

[pine]
int   judgeBars = 10    // a zone entry is judged within this many bars
float moveAt    = 1.0   // reversed or followed through once a close is this many ATRs from the entry
int   keepRec   = 10    // entries remembered per zone
[/pine]

Those numbers are right or wrong rather than a matter of taste, and we would rather you didn't have to think about them.

█ [b]ALERTS[/b]

[list]
[*]Overbought: price closed into the overbought zone.
[*]Left overbought: price left it.
[*]Oversold: price closed into the oversold zone.
[*]Left oversold: price left it.
[/list]

Set them to "Once per bar close". A zone entry on a live bar can still be undone before the close.

█ [b]NOTES AND LIMITS[/b]

[list]
[*]The edge is the close needed on the next bar, measured from this bar's close. It is exact for one bar ahead, not a level that holds for the week. That is why it moves.
[*]A big candle moves the edges. After a large up candle, overbought is closer; after a large down candle, further away. The edges kink where the candles are big. Smoothing softens this at the cost of lag.
[*]Closes count, wicks don't. A wick poking into a zone is not an entry; RSI is a close-to-close measure and so is this.
[*]The record needs ten entries per zone to mean much, and it is the last ten only. On a daily chart that can be a year of history. Read the count next to the number.
[*]The record judges an entry by what happened within ten bars. A reversal that came on bar twelve is not counted; it is dropped, not scored against the zone.
[*]Zone depth is drawing. Price three ATRs past the edge is still overbought; it is just past the glow.
[*]RSI candles replace your candle colours while they are on, and up and down candles are told apart by brightness rather than colour. If you rely on green and red, turn them off.
[*]On symbols with very few bars of history, the zones exist from the first bar but the record is empty until the first entries have been judged.
[/list]

█ [b]DISCLAIMER[/b]

This script is for education and information. It isn't financial advice, a recommendation to buy or sell anything, or a promise about what any market will do. Past behaviour of a market, a method or an indicator doesn't guarantee future results, and nothing on this chart replaces your own judgement. Trading involves risk and you are responsible for your decisions.

## Source Code

````pine
//@version=6
// RSI Master
//
// RSI turned into price. Instead of watching a line in a pane, you see on the chart
// itself where overbought begins and where oversold begins: the price a close would
// have to reach for RSI to hit 70 or 30 on the next bar, worked out exactly from the
// RSI formula. The overbought zone is drawn above that level as a soft band, the
// oversold zone below its level, so when price is inside a band it is overbought or
// oversold, and the distance to each band is the room price has before it gets there.
// Dots mark the first close into a zone. The panel says it in words, with the chart's
// own record of what happened the last times price reached a zone.
//
// The bands do the reading, the dots mark the entries, the panel does the words, the
// alerts carry the events.

indicator("RSI Master [SimpleAlgo]", "RSI Master [SimpleAlgo]", overlay = true)

// ───────────────────────── Settings ─────────────────────────

grpR = "RSI"
lenIn  = input.int(14, "Length", minval = 2, maxval = 100, group = grpR)
obIn   = input.float(70, "Overbought", minval = 50.5, maxval = 99, step = 1, group = grpR)
osIn   = input.float(30, "Oversold", minval = 1, maxval = 49.5, step = 1, group = grpR)
smIn   = input.int(3, "Smoothing (bars)", minval = 1, maxval = 10, group = grpR, tooltip = "The zone edges follow price bar by bar; a little smoothing keeps them calm.")

grpL = "Look"
themeIn  = input.string("Neon", "Theme", options = ["Neon", "Classic", "Aurora", "Ice", "Custom"], group = grpL)
osColIn  = input.color(#00FFA3, "Oversold", group = grpL, inline = "c")
obColIn  = input.color(#FF3D71, "Overbought", group = grpL, inline = "c")
bright   = input.int(3, "Brightness", minval = 1, maxval = 5, group = grpL)
depthIn  = input.float(2.2, "Zone depth (ATR)", minval = 0.5, maxval = 6, step = 0.1, group = grpL, tooltip = "How far the zone's glow reaches past its edge.")
showCandles = input.bool(true, "RSI candles", group = grpL, inline = "m", tooltip = "Candles cool toward the oversold colour and warm toward the overbought colour as RSI moves. Up and down candles stay apart by brightness.")
showMid  = input.bool(false, "Midline (RSI 50)", group = grpL, inline = "m")
showDots = input.bool(true, "Entry dots", group = grpL, inline = "d")
showTurns = input.bool(true, "Exit arrows", group = grpL, inline = "d", tooltip = "A small arrow where price leaves a zone: down out of overbought, up out of oversold. The classic RSI signal.")
showPanel = input.bool(true, "Panel", group = grpL, inline = "p")
panelPos  = input.string("Top right", "", options = ["Top left", "Top right", "Bottom left", "Bottom right"], group = grpL, inline = "p")
panelSize = input.string("Normal", "", options = ["Small", "Normal", "Large"], group = grpL, inline = "p")

[colOS, colOB, colPanel] = switch themeIn
    "Neon"    => [#00FFA3, #FF3D71, #262B38]
    "Classic" => [#00FF31, #FF0013, #23262F]
    "Aurora"  => [#34D399, #F472B6, #262B38]
    "Ice"     => [#7DD3FC, #FDA4AF, #1E293B]
    => [osColIn, obColIn, #262B38]
color colMid = #7B9CFF

// fixed rules
int   judgeBars = 10    // a zone entry is judged within this many bars
float moveAt    = 1.0   // reversed or followed through once a close is this many ATRs from the entry
int   keepRec   = 10    // entries remembered per zone

// ───────────────────────── RSI, and the prices behind it ─────────────────────────

float atr = math.max(nz(ta.atr(14), high - low), syminfo.mintick)
float chg = ta.change(close)
float up  = ta.rma(math.max(chg, 0), lenIn)
float dn  = ta.rma(-math.min(chg, 0), lenIn)
float rsi = dn == 0 ? 100 : up == 0 ? 0 : 100 - 100 / (1 + up / dn)

// the close next bar that would put RSI exactly at a level: a rise if the level is above
// where RSI sits, a fall if it is below, straight from the RSI formula
priceFor(float level) =>
    float r = level / (100 - level)
    float u = (lenIn - 1) * (r * dn - up)
    u >= 0 ? close + u : close - (lenIn - 1) * (up / r - dn)

float obRaw = priceFor(obIn)
float osRaw = priceFor(osIn)
float midRaw = priceFor(50)
float ob  = ta.ema(obRaw, smIn)
float os  = ta.ema(osRaw, smIn)
float mid = ta.ema(midRaw, smIn)

bool inOB = rsi >= obIn
bool inOS = rsi <= osIn
bool enterOB = inOB and not inOB[1]
bool exitOB  = not inOB and inOB[1]
bool enterOS = inOS and not inOS[1]
bool exitOS  = not inOS and inOS[1]

var int obSince = -1
var int osSince = -1
var int obLeft  = -1
var int osLeft  = -1
if enterOB
    obSince := bar_index
if enterOS
    osSince := bar_index
if exitOB
    obLeft := bar_index
if exitOS
    osLeft := bar_index

// ───────────────────────── The record ─────────────────────────
// each entry into a zone is judged: did price reverse a full ATR from the entry close
// first, or keep going a full ATR first?

var evBar   = array.new_int()
var evSide  = array.new_int()      // 1 overbought, -1 oversold
var evClose = array.new_float()
var evAtr   = array.new_float()
var obRec   = array.new_int()      // 1 reversed, 0 followed through
var osRec   = array.new_int()

if barstate.isconfirmed
    if enterOB
        array.push(evBar, bar_index)
        array.push(evSide, 1)
        array.push(evClose, close)
        array.push(evAtr, atr)
    if enterOS
        array.push(evBar, bar_index)
        array.push(evSide, -1)
        array.push(evClose, close)
        array.push(evAtr, atr)
    int i = 0
    while i < array.size(evBar)
        int side = array.get(evSide, i)
        float c0 = array.get(evClose, i)
        float a0 = array.get(evAtr, i)
        int verdict = -1
        if side == 1
            verdict := close <= c0 - moveAt * a0 ? 1 : close >= c0 + moveAt * a0 ? 0 : -1
        else
            verdict := close >= c0 + moveAt * a0 ? 1 : close <= c0 - moveAt * a0 ? 0 : -1
        bool expired = bar_index - array.get(evBar, i) >= judgeBars
        if verdict >= 0 or expired
            if verdict >= 0
                if side == 1
                    array.push(obRec, verdict)
                    if array.size(obRec) > keepRec
                        array.shift(obRec)
                else
                    array.push(osRec, verdict)
                    if array.size(osRec) > keepRec
                        array.shift(osRec)
            array.remove(evBar, i)
            array.remove(evSide, i)
            array.remove(evClose, i)
            array.remove(evAtr, i)
        else
            i += 1

// ───────────────────────── Drawing ─────────────────────────

float brightMul = 0.4 + 0.2 * bright
tp(float alpha) =>
    int(math.round(100 - math.min(math.max(alpha * brightMul, 0.0), 1.0) * 100))

float obTop = ob + depthIn * atr
float osBot = os - depthIn * atr

pOB    = plot(ob, "Overbought edge", color = na, display = display.none, editable = false)
pOBtop = plot(obTop, "", color = na, display = display.none, editable = false)
pOS    = plot(os, "Oversold edge", color = na, display = display.none, editable = false)
pOSbot = plot(osBot, "", color = na, display = display.none, editable = false)

// the zones: full at the edge, fading away from price
fill(pOB, pOBtop, obTop, ob, color.new(colOB, 100), color.new(colOB, tp(0.26)), title = "Overbought zone", editable = false)
fill(pOS, pOSbot, os, osBot, color.new(colOS, tp(0.26)), color.new(colOS, 100), title = "Oversold zone", editable = false)

// the edges, with a soft halo
plot(ob, "Overbought glow", color = color.new(colOB, tp(0.16)), linewidth = 6, editable = false, display = display.pane)
plot(ob, "Overbought", color = colOB, linewidth = 2)
plot(os, "Oversold glow", color = color.new(colOS, tp(0.16)), linewidth = 6, editable = false, display = display.pane)
plot(os, "Oversold", color = colOS, linewidth = 2)
plot(showMid ? mid : na, "Midline", color = color.new(colMid, 55), linewidth = 1, style = plot.style_circles, display = display.pane)

// the candles: a soft neutral through the middle of the range, warming to the overbought
// colour over the last stretch before the zone and cooling to the oversold colour on the
// way down, with up candles a shade brighter than down candles. The colour comes on
// late and builds fast, so the chart stays calm until RSI is actually getting somewhere.
color neutral = close >= open ? #A3ABBD : #5F6677
float warmFrom = 50 + (obIn - 50) * 0.3
float coolFrom = 50 - (50 - osIn) * 0.3
float tWarm = math.pow(math.min(math.max((rsi - warmFrom) / (obIn - warmFrom), 0.0), 1.0), 1.4)
float tCool = math.pow(math.min(math.max((coolFrom - rsi) / (coolFrom - osIn), 0.0), 1.0), 1.4)
color candleCol = rsi >= 50 ? color.from_gradient(tWarm, 0, 1, neutral, colOB) : color.from_gradient(tCool, 0, 1, neutral, colOS)
barcolor(showCandles ? candleCol : na, title = "RSI candles", editable = false)

// the first close into a zone
plotshape(showDots and enterOB ? high : na, "Overbought entry glow", shape.circle, location.absolute, color.new(colOB, tp(0.18)), size = size.small, editable = false, display = display.pane)
plotshape(showDots and enterOB ? high : na, "Overbought entry", shape.circle, location.absolute, colOB, size = size.tiny, editable = false, display = display.pane)
plotshape(showDots and enterOS ? low : na, "Oversold entry glow", shape.circle, location.absolute, color.new(colOS, tp(0.18)), size = size.small, editable = false, display = display.pane)
plotshape(showDots and enterOS ? low : na, "Oversold entry", shape.circle, location.absolute, colOS, size = size.tiny, editable = false, display = display.pane)

// the exits: the classic signal, a small arrow where price leaves a zone. When price
// flickers in and out of a zone over a few bars, only the first exit gets an arrow.
var int lastArrowOB = -10
var int lastArrowOS = -10
bool arrowOB = exitOB and bar_index - lastArrowOB > 3
bool arrowOS = exitOS and bar_index - lastArrowOS > 3
if arrowOB
    lastArrowOB := bar_index
if arrowOS
    lastArrowOS := bar_index
plotshape(showTurns and arrowOB, "Left overbought", shape.triangledown, location.abovebar, colOB, size = size.small, editable = false, display = display.pane)
plotshape(showTurns and arrowOS, "Left oversold", shape.triangleup, location.belowbar, colOS, size = size.small, editable = false, display = display.pane)

// ───────────────────────── Panel ─────────────────────────

bars(int n) =>
    str.tostring(n) + (n == 1 ? " bar" : " bars")

px(float x) =>
    syminfo.mintick >= 1 ? str.tostring(x, "#,##0") : syminfo.mintick >= 0.01 ? str.tostring(x, "#,##0.00") : str.tostring(x, format.mintick)

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
    string pend = barstate.isconfirmed ? "" : ", confirms on close"
    string rsiTxt = str.tostring(rsi, "0") + (rsi > rsi[3] + 1 ? ", rising" : rsi < rsi[3] - 1 ? ", falling" : ", flat")
    color  rsiClr = inOB ? colOB : inOS ? colOS : txt
    float toOB = (ob - close) / atr
    float toOS = (close - os) / atr
    string obTxt = inOB ? px(ob) + ", price " + str.tostring(-toOB, "0.0") + " ATR inside" : px(ob) + ", " + str.tostring(toOB, "0.0") + " ATR away"
    string osTxt = inOS ? px(os) + ", price " + str.tostring(-toOS, "0.0") + " ATR inside" : px(os) + ", " + str.tostring(toOS, "0.0") + " ATR away"
    // the record for the nearer zone
    int nOB = array.size(obRec)
    int nOS = array.size(osRec)
    float rOB = nOB > 0 ? array.sum(obRec) : 0.0
    float rOS = nOS > 0 ? array.sum(osRec) : 0.0
    bool upperSide = rsi >= 50
    string recTxt = upperSide ? (nOB == 0 ? "No overbought entries judged yet" : "Overbought reversed " + str.tostring(rOB, "0") + " of the last " + str.tostring(nOB) + (nOB == 1 ? " time" : " times")) : (nOS == 0 ? "No oversold entries judged yet" : "Oversold bounced " + str.tostring(rOS, "0") + " of the last " + str.tostring(nOS) + (nOS == 1 ? " time" : " times"))
    // the read
    // what this chart tends to do once it gets there
    string tendOB = nOB >= 5 ? (rOB / nOB >= 0.7 ? ", it tends to reverse here" : rOB / nOB <= 0.3 ? ", it tends to keep going here" : "") : ""
    string tendOS = nOS >= 5 ? (rOS / nOS >= 0.7 ? ", it tends to bounce here" : rOS / nOS <= 0.3 ? ", it tends to keep falling here" : "") : ""
    string read = inOB ? "Overbought, " + (bar_index - obSince == 0 ? "just in" : bars(bar_index - obSince) + " in") + (enterOB ? pend : "") : inOS ? "Oversold, " + (bar_index - osSince == 0 ? "just in" : bars(bar_index - osSince) + " in") + (enterOS ? pend : "") : obLeft >= 0 and bar_index - obLeft <= 5 ? "Left overbought " + (bar_index == obLeft ? "this bar" : bars(bar_index - obLeft) + " ago") + (exitOB ? pend : "") : osLeft >= 0 and bar_index - osLeft <= 5 ? "Left oversold " + (bar_index == osLeft ? "this bar" : bars(bar_index - osLeft) + " ago") + (exitOS ? pend : "") : upperSide ? (toOB <= 0.5 ? "Knocking on overbought" + tendOB : "Room to run, " + str.tostring(toOB, "0.0") + " ATR to overbought" + tendOB) : (toOS <= 0.5 ? "Knocking on oversold" + tendOS : "Room to fall, " + str.tostring(toOS, "0.0") + " ATR to oversold" + tendOS)
    color readClr = inOB or (obLeft >= 0 and bar_index - obLeft <= 5 and not inOS) ? colOB : inOS or (osLeft >= 0 and bar_index - osLeft <= 5) ? colOS : txt
    table.cell(panel, 0, 0, "RSI MASTER", text_color = txt, text_size = txtSize, text_halign = text.align_left)
    table.cell(panel, 1, 0, px(close), text_color = dim, text_size = txtSize, text_halign = text.align_right)
    table.cell(panel, 0, 1, "RSI", text_color = dim, text_size = txtSize, text_halign = text.align_left)
    table.cell(panel, 1, 1, rsiTxt, text_color = rsiClr, text_size = txtSize, text_halign = text.align_right)
    table.cell(panel, 0, 2, "Overbought from", text_color = dim, text_size = txtSize, text_halign = text.align_left)
    table.cell(panel, 1, 2, obTxt, text_color = colOB, text_size = txtSize, text_halign = text.align_right)
    table.cell(panel, 0, 3, "Oversold from", text_color = dim, text_size = txtSize, text_halign = text.align_left)
    table.cell(panel, 1, 3, osTxt, text_color = colOS, text_size = txtSize, text_halign = text.align_right)
    table.cell(panel, 0, 4, "On this chart", text_color = dim, text_size = txtSize, text_halign = text.align_left)
    table.cell(panel, 1, 4, recTxt, text_color = txt, text_size = txtSize, text_halign = text.align_right)
    table.cell(panel, 0, 5, "Read", text_color = dim, text_size = txtSize, text_halign = text.align_left)
    table.cell(panel, 1, 5, read, text_color = readClr, text_size = txtSize, text_halign = text.align_right)

// ───────────────────────── Alerts ─────────────────────────

alertcondition(enterOB, "Overbought",      "RSI Master: price closed into the overbought zone")
alertcondition(exitOB,  "Left overbought", "RSI Master: price left the overbought zone")
alertcondition(enterOS, "Oversold",        "RSI Master: price closed into the oversold zone")
alertcondition(exitOS,  "Left oversold",   "RSI Master: price left the oversold zone")
````
