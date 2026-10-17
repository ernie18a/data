# Session Highs & Lows + BSL / SSL

- url: https://www.tradingview.com/script/lOKkkdOo-Session-Highs-Lows-BSL-SSL/
- type: indicator
- pine_id: PUB;cfb8e87b218d45ba8370de92f89d80b8
- version: 1.0

## Description

Session Highs & Lows + BSL / SSL

Marks the Asia, London and New York sessions, then turns each one's high and low into labelled liquidity once the session closes.

How it works

While a session is running, its range is boxed and updated live with every new high and low, so you can watch the range build rather than only seeing it after the fact.

The moment the session closes, that range stops being decoration and becomes two levels. The session high is buy-side liquidity, drawn and tagged BSL. The session low is sell-side liquidity, tagged SSL. Both extend to the right until price trades through them.

Once a level is taken, the line dims and stops at the bar that swept it, with an optional marker on the sweep. So at any moment the bright lines are the liquidity still resting on your chart, and the faded ones are the record of what has already been run.

Each session carries its own colour through to its lines, so a level always tells you which session produced it. Tags read ASIA BSL, LONDON SSL and so on.

Timezone handling

All three session windows are read in a timezone you set rather than your chart's exchange timezone. This is the detail that breaks most session indicators.

Because the windows are anchored to a real timezone, they follow daylight saving correctly and stay in the same place when you switch between instruments that quote in different exchange timezones. Set it once to how you think about the market, and the sessions stop drifting.

Defaults

The session windows default to the commonly traded periods in New York time:

Asia, 20:00 to 00:00
London, 02:00 to 05:00
New York, 08:00 to 11:00

These are the concentrated windows rather than full sessions. Every window, name and colour is editable, so if you trade the full Asian range or the whole London day, enter your own times.

Settings

Sweep trigger decides whether a wick through a level counts as taking it, or whether only a body close does. It defaults to wick through, because taking the Asian high is the wick running the stops rather than a close beyond it.

Stop line at the sweep controls whether swept levels terminate where they were taken or keep extending in a dimmed state.

Session boxes can be turned off if you only want the levels. An optional midline draws the 50% of each session range, which is a level price often returns to before continuing.

A panel shows which session is currently open along with each session's high and low.

Alerts are available for every session open and close.

Notes

Levels are created when a session closes, so they appear at the session boundary rather than at the moment the high or low printed. The high and low themselves are tracked from the first bar of the session.

This is a levels and context tool. It does not generate entries, exits or directional signals, and makes no claim about what price will do at any level it draws.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © rcj101208

//@version=6
// ==============================================================================
//  SESSION HIGHS & LOWS + BSL / SSL
//
//  Tracks the Asia, London and New York sessions. While a session runs, its
//  range is boxed and updated live. When it closes, its high becomes buy-side
//  liquidity and its low becomes sell-side liquidity, drawn as labelled lines
//  that extend right until price trades through them, then dim and stop.
//
//  Session times are set in a timezone you choose, so they stay correct through
//  daylight saving changes and whatever exchange timezone your chart uses.
//
//  Defaults are the commonly traded windows in New York time:
//    Asia    20:00 - 00:00
//    London  02:00 - 05:00
//    New York 08:00 - 11:00
//  Change them to full sessions if that is how you trade.
// ==============================================================================
indicator("Session Highs & Lows + BSL / SSL", "SESSIONS + LIQ", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

// -- Sessions -----------------------------------------------------------------
gS    = "Sessions"
tzStr = input.string("America/New_York", "Timezone", group = gS, tooltip = "All three windows are read in this timezone, so they follow daylight saving correctly whatever your chart is set to.")
aOn   = input.bool(true, "Asia", inline = "a", group = gS)
aSess = input.session("2000-0000", "", inline = "a", group = gS)
aName = input.string("ASIA", "", inline = "a", group = gS)
lOn   = input.bool(true, "London", inline = "l", group = gS)
lSess = input.session("0200-0500", "", inline = "l", group = gS)
lName = input.string("LONDON", "", inline = "l", group = gS)
nOn   = input.bool(true, "New York", inline = "n", group = gS)
nSess = input.session("0800-1100", "", inline = "n", group = gS)
nName = input.string("NY", "", inline = "n", group = gS)

// -- Liquidity lines ----------------------------------------------------------
gL         = "BSL / SSL"
showLiq    = input.bool(true, "Draw BSL and SSL after each session", group = gL)
sweepMode  = input.string("Wick through", "Sweep trigger", options = ["Wick through", "Close through"], group = gL, tooltip = "Wick through means the level is taken the moment price trades past it, which is the raid itself.")
stopAtSwp  = input.bool(true, "Stop line at the sweep", group = gL)
markSweeps = input.bool(true, "Mark sweeps", group = gL)
padBars    = input.int(6, "Extend past current bar", minval = 0, maxval = 100, group = gL)
dimAmt     = input.int(72, "Swept line dim amount", minval = 0, maxval = 95, step = 5, group = gL)
keepLiq    = input.int(48, "Max levels kept", minval = 6, maxval = 200, group = gL, tooltip = "Two levels per session, so 48 is about 8 days of all three sessions.")
liqWidth   = input.int(1, "Line width", minval = 1, maxval = 4, group = gL)
showTags   = input.bool(true, "Show BSL / SSL tags", group = gL)

// -- Boxes and style ----------------------------------------------------------
gB       = "Session boxes"
showBox  = input.bool(true, "Show session range boxes", group = gB)
showMid  = input.bool(false, "Show session midline", group = gB, tooltip = "The 50% of each session range, which is where price often returns before continuing.")
boxFill  = input.int(92, "Box fill transparency", minval = 0, maxval = 100, step = 2, group = gB)
showName = input.bool(true, "Label the boxes", group = gB)
colA     = input.color(#ff9800, "Asia", group = gB)
colL     = input.color(#2962ff, "London", group = gB)
colN     = input.color(#9c27b0, "New York", group = gB)
showPanel = input.bool(true, "Show panel", group = gB)

// ==============================================================================
//  SESSION STATE
// ==============================================================================
type Sess
    string nm
    bool   act
    float  hi
    float  lo
    int    x0
    box    bx
    line   mid

type Liq
    float  px
    line   ln
    label  lb
    bool   hi
    bool   swept
    color  c
    string nm

var array<Sess> ses  = array.new<Sess>()
var array<Liq>  liqs = array.new<Liq>()

if barstate.isfirst
    ses.push(Sess.new(aName, false, na, na, 0, na, na))
    ses.push(Sess.new(lName, false, na, na, 0, na, na))
    ses.push(Sess.new(nName, false, na, na, 0, na, na))

// time() is evaluated at global scope, then the result is passed in
inA = aOn and not na(time(timeframe.period, aSess, tzStr))
inL = lOn and not na(time(timeframe.period, lSess, tzStr))
inN = nOn and not na(time(timeframe.period, nSess, tzStr))

// ==============================================================================
//  RUN ONE SESSION
//   Opens a box on the first bar, stretches it while the session runs, and on
//   the close converts the high and low into BSL and SSL.
// ==============================================================================
stepSession(Sess s, array<Liq> arr, bool inS, color col) =>
    if inS and not s.act
        s.act := true
        s.hi  := high
        s.lo  := low
        s.x0  := bar_index
        s.bx  := showBox ? box.new(bar_index, high, bar_index, low, border_color = color.new(col, 55), border_width = 1, bgcolor = color.new(col, boxFill), text = showName ? s.nm : "", text_color = color.new(col, 25), text_halign = text.align_left, text_valign = text.align_top, text_size = size.tiny) : na
        s.mid := showMid ? line.new(bar_index, (high + low) / 2, bar_index, (high + low) / 2, color = color.new(col, 40), style = line.style_dotted, width = 1) : na
    else if inS and s.act
        s.hi := math.max(s.hi, high)
        s.lo := math.min(s.lo, low)
        if not na(s.bx)
            box.set_lefttop(s.bx, s.x0, s.hi)
            box.set_rightbottom(s.bx, bar_index, s.lo)
        if not na(s.mid)
            line.set_xy1(s.mid, s.x0, (s.hi + s.lo) / 2)
            line.set_xy2(s.mid, bar_index, (s.hi + s.lo) / 2)
    else if not inS and s.act
        s.act := false
        if showLiq and not na(s.hi) and not na(s.lo) and s.hi > s.lo
            lnH = line.new(bar_index, s.hi, bar_index + padBars, s.hi, color = col, width = liqWidth)
            lbH = showTags ? label.new(bar_index + padBars, s.hi, s.nm + " BSL", style = label.style_label_left, color = color.new(color.black, 100), textcolor = col, size = size.small) : na
            arr.push(Liq.new(s.hi, lnH, lbH, true, false, col, s.nm))
            lnL = line.new(bar_index, s.lo, bar_index + padBars, s.lo, color = col, width = liqWidth)
            lbL = showTags ? label.new(bar_index + padBars, s.lo, s.nm + " SSL", style = label.style_label_left, color = color.new(color.black, 100), textcolor = col, size = size.small) : na
            arr.push(Liq.new(s.lo, lnL, lbL, false, false, col, s.nm))
            while arr.size() > keepLiq
                old = arr.shift()
                if not na(old.ln)
                    line.delete(old.ln)
                if not na(old.lb)
                    label.delete(old.lb)
    s.act

// ==============================================================================
//  EXTEND AND SWEEP
// ==============================================================================
updateLiq(array<Liq> arr) =>
    if arr.size() > 0
        for i = 0 to arr.size() - 1
            q = arr.get(i)
            if q.swept
                if not stopAtSwp
                    line.set_x2(q.ln, bar_index + padBars)
                    if not na(q.lb)
                        label.set_x(q.lb, bar_index + padBars)
            else
                gone = sweepMode == "Close through" ? (q.hi ? close > q.px : close < q.px) : (q.hi ? high > q.px : low < q.px)
                if gone
                    q.swept := true
                    line.set_color(q.ln, color.new(q.c, dimAmt))
                    line.set_style(q.ln, line.style_dotted)
                    line.set_x2(q.ln, stopAtSwp ? bar_index : bar_index + padBars)
                    if not na(q.lb)
                        label.set_textcolor(q.lb, color.new(q.c, dimAmt))
                        label.set_text(q.lb, "")
                    if markSweeps
                        label.new(bar_index, q.px, "", style = label.style_xcross, color = q.c, size = size.tiny, tooltip = q.nm + (q.hi ? " buy-side liquidity swept at " : " sell-side liquidity swept at ") + str.tostring(q.px, format.mintick))
                else
                    line.set_x2(q.ln, bar_index + padBars)
                    if not na(q.lb)
                        label.set_xy(q.lb, bar_index + padBars, q.px)
    arr.size()

if ses.size() == 3
    stepSession(ses.get(0), liqs, inA, colA)
    stepSession(ses.get(1), liqs, inL, colL)
    stepSession(ses.get(2), liqs, inN, colN)

updateLiq(liqs)

// ==============================================================================
//  PANEL
// ==============================================================================
var table pn = table.new(position.top_right, 2, 4, border_width = 1, frame_color = color.new(color.gray, 70), frame_width = 1)

rngTxt(Sess s) =>
    na(s.hi) or na(s.lo) ? "-" : str.tostring(s.hi, format.mintick) + " / " + str.tostring(s.lo, format.mintick)

if showPanel and barstate.islast and ses.size() == 3
    a = ses.get(0)
    l = ses.get(1)
    n = ses.get(2)
    live = a.act ? a.nm : l.act ? l.nm : n.act ? n.nm : "none open"
    table.cell(pn, 0, 0, "Session", text_color = color.white, bgcolor = color.new(color.gray, 25), text_size = size.small)
    table.cell(pn, 1, 0, live, text_color = color.white, bgcolor = color.new(color.gray, 25), text_size = size.small)
    table.cell(pn, 0, 1, a.nm, text_color = colA, text_size = size.small)
    table.cell(pn, 1, 1, rngTxt(a), text_color = color.white, text_size = size.small)
    table.cell(pn, 0, 2, l.nm, text_color = colL, text_size = size.small)
    table.cell(pn, 1, 2, rngTxt(l), text_color = color.white, text_size = size.small)
    table.cell(pn, 0, 3, n.nm, text_color = colN, text_size = size.small)
    table.cell(pn, 1, 3, rngTxt(n), text_color = color.white, text_size = size.small)

// ==============================================================================
//  ALERTS
// ==============================================================================
alertcondition(inA and not inA[1], "Asia session open", "Asia session opened on {{ticker}}")
alertcondition(inL and not inL[1], "London session open", "London session opened on {{ticker}}")
alertcondition(inN and not inN[1], "New York session open", "New York session opened on {{ticker}}")
alertcondition(not inA and inA[1], "Asia session close", "Asia session closed, BSL and SSL drawn on {{ticker}}")
alertcondition(not inL and inL[1], "London session close", "London session closed, BSL and SSL drawn on {{ticker}}")
alertcondition(not inN and inN[1], "New York session close", "New York session closed, BSL and SSL drawn on {{ticker}}")
````
