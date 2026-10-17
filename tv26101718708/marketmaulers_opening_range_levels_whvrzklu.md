# MarketMaulers Opening Range Levels

- url: https://www.tradingview.com/script/WhVRZkLU-MarketMaulers-Opening-Range-Levels/
- type: indicator
- pine_id: PUB;aef0ac1ef33d489199c13f252997e55e
- version: 1.0

## Description

MarketMaulers Opening Range Levels draws the first fifteen minutes of the session as a map for the rest of it: the high, the low, the midpoint, and the range height projected above and below as 1× and 2× extensions. Then it stays with those levels through the part that matters, and records the three things that can happen at each one.

● taken · ○ retested · ✕ break failed

THE HEIGHT IS THE PRODUCT
The opening range high and low are on every chart in the world. Drawing them is not an edge. What gets marked far less often is the HEIGHT of the range used as a ruler. Project it from the side that breaks and 1× and 2× are the measured-move levels. This tool puts that ruler on the chart before the move, not after it.

FROM ZERO: WHAT AN OPENING RANGE IS
When a session opens, the first few minutes are the market agreeing on a price after hours of being closed or thin. The highest and lowest prices traded in that window are the opening range. Everything after it is the market deciding whether that first agreement holds. A break of one side is the day's first decision. Whether the break holds is the second.

WHAT IT DRAWS
• The range box, over the opening window itself.
• OR High, OR Low and the midpoint, carried across the session.
• Extensions at 1× and 2× the range height beyond each side. Up to 4×, with an optional 0.5×.
• The current session shows its full ladder. Past sessions keep their box and three levels, so a zoomed-out chart stays readable. One switch brings the old ladders back.

The default window is 09:30 to 09:45 New York. The start time is yours to set, and the length can be 5, 15, 30 or 60 minutes. The clock is New York time with daylight saving handled, so 09:30 stays 09:30 all year.

THE THREE MARKS
A break is the start of the story. Two things can follow, and they mean opposite things.
• TAKEN, a filled dot. The first bar to close beyond a side. Once per side per session.
• RETEST, a hollow dot. After a break, price has to trade fully clear of the level. The first bar that comes back and touches it gets the mark. The "fully clear first" rule is what stops the bar right after the break from being called a retest.
• BREAK FAILED, a cross. The first close back through the midpoint after a break. A setting moves the test to a close back inside the range edge, which is earlier and noisier.

A first break can turn out to be the day's move or the day's trap. The marks do not predict which. They record which one it was, so you can see how each plays out on your own instrument.

THE BAR GETS THE GLYPH, THE TAG GETS THE STORY
Each mark on the chart is a single character, so candles do not print through it and two events close together do not pile up. The detail goes on the level's own tag, with times. A high taken at 09:50 whose break failed at 10:00 reads on the OR HIGH tag as the price, then the dot with 09:50, then the cross with 10:00. Read left to right, that is the level's whole day. Hover any mark for what it is and when. If you prefer the words printed beside each mark, that is one switch.

THE WIDTH READ
A fifteen-minute range at half its usual size and one at double are two different days wearing the same lines. The panel compares today's width to the median of the sessions before it, up to the last 20, and calls it wide, normal or tight.
• Median, not average. One news morning drags an average up for a month. The median ignores it.
• It will not give a verdict until it has 10 sessions. A ratio built on three days is a coincidence.
• Today is never part of its own benchmark. The median is taken before today's range joins the pool.
• The wide and tight cut-offs, 1.25× and 0.80×, are ours. They are not a published threshold.
• The row names how many sessions the median stands on. Different chart timeframes load different amounts of history, so the figure can differ slightly between them.

THE PANEL
Window · width in points and ticks · width against the median · high and low · when each side was first taken, retested and failed · how many extensions have been reached. Every row has a hover note.

ALERTS
First break of the range · Retest of a broken level · Break failed · Extension level reached

One alert covers all four. Each message carries the live price and the level, and a JSON format is available for webhooks. Extension alerts stop when the levels expire, so nothing fires overnight against a finished range.

WHY IT DOES NOT REPAINT
There is no higher-timeframe request anywhere in the script. The range is built from chart bars and commits once, when the window closes. Its levels are never moved afterwards. Every mark is judged on a closed bar, so nothing appears and then vanishes.

WHAT TO KNOW BEFORE YOU USE IT
• Intraday charts only, at or below the range length. A 15-minute range needs a chart of 15 minutes or less.
• The default break test is a bar CLOSE beyond the level, so the break time depends on your chart timeframe. A 1-minute chart can show a break a 5-minute chart does not.
• Level tags sit at the end of their lines. After the levels expire, later candles can print over a tag when price rests on that level.
• On a fast open a retest can print two or three bars after the break. It met the rule, and it carries less information than a retest that took an hour.

MADE TO FIT YOUR CHART
Separate colours for the high and the low, line style and width for every level, box fill and border, extension colours per side, mark colours and size, tag size and position, eight panel positions, every panel colour, and a toggle for each element and each panel section.

HOW TRADERS ACTUALLY USE IT
Let the range finish. Inside it, the market is still deciding. Read the width first, because a tight range and a wide range are different days and the same levels sit at very different distances. Treat 1× as the first place to think. After a break, watch the midpoint. A close back through it is the break failing, and the cross marks it for you.

Works on any market with intraday data.

Display only. This draws levels and records what happened at them, it does not fire buy/sell signals. The width read is a record of recent sessions, not a forecast. Educational tool, not financial advice.

Published open-source. The clock-based window engine, the commit-once range model, the break, retest and failed-break state tracking, the median width benchmark with its sample floor, and the alert transport are all readable in the source. Everything above explains what it draws and how it decides what to mark; the code is there so you can check that the description is accurate rather than take it on faith. Read it, fork it, argue with the constants.

## Source Code

````pine
//@version=6
// ═══════════════════════════════════════════════════════════════════════════════
//  MarketMaulers Opening Range Levels  ·  v1.4
//  ──────────────────────────────────────
//  The session's opening range, drawn as levels: OR High, OR Low, the midpoint,
//  and the 1× / 2× range extensions above and below. Each side can carry three
//  marks, once per session: ● the level was taken, ○ it was retested, ✕ the
//  break failed. A width read says whether today's range is unusually wide or
//  unusually tight for this symbol.
//
//  LEVELS ONLY. NO ENTRIES, NO SIGNALS, NO STRATEGY. The marks are events, not
//  calls: they record what happened at a level and say nothing about what to do
//  next.
//
//  Why the extension ladder is the product: the OR high and low are on every
//  chart in the world. What is marked less often is the range HEIGHT used as a
//  ruler: project it from the breakout side and 1× / 2× are the measured-move
//  levels. The tool exists to put that ruler on the chart before the move, not
//  after it.
//
//  Why the width benchmark matters more than it looks: a 15-minute range that is
//  half its usual size and one that is double it are two different days wearing
//  the same lines. The panel compares today's width to the MEDIAN of the last 20
//  sessions (median, not mean, range width is right-skewed and one news day
//  drags a mean up for a month) and withholds the verdict entirely until it has
//  10 sessions to stand on.
//
//  Non-repaint: window membership is minutes-of-day in America/New_York, so it
//  is DST-aware and comes from each bar's own fixed timestamp. The range commits
//  once, at the close of the window, and its levels are never re-positioned
//  afterwards. Breaks and touches are judged on barstate.isconfirmed. There is
//  NO request.security anywhere in this file, everything is chart-timeframe.
//
//  Built by Market Maulers  ·  Free forever
// ═══════════════════════════════════════════════════════════════════════════════
// NOTE: no `scale=` argument, ever. Standing rule in this suite: it requests a SECOND price
// axis and floats the overlay off the candles. Omitting it is what pins it.
indicator("MarketMaulers Opening Range Levels", shorttitle="MM OR", overlay=true,
     max_boxes_count=500, max_lines_count=500, max_labels_count=500)


// ═══════════════════════════════════════════════════════════════════════════════
//  LOCKED CALIBRATION (v1.0), constants, deliberately NOT inputs
// ═══════════════════════════════════════════════════════════════════════════════
string TZ      = "America/New_York"  // ALWAYS ET, DST-aware, never a UTC offset
int    AVG_N   = 20   // sessions retained for the width benchmark. 20 ≈ one month
                      //   of sessions, long enough to have a shape, short enough
                      //   to still describe the current regime.
int    AVG_MIN = 10   // SAMPLE FLOOR. Below this the width verdict is withheld
                      //   rather than printed weakly. Panel doctrine: a number
                      //   with nothing behind it is worse than no number.
float  WIDE_X  = 1.25 // OURS, not a published threshold, the point at which the
float  NARROW_X= 0.80 //   panel calls the range wide / tight vs its own median.
                      //   Calibrate on NQ; they are read straight off the ratio
                      //   so moving them changes wording only, never a level.
color  COL_NONE = #ffffff00


// ═══════════════════════════════════════════════════════════════════════════════
//  INPUTS
// ═══════════════════════════════════════════════════════════════════════════════
grpR = "Opening Range"
grpL = "Levels"
grpE = "Extensions"
grpB = "Break Marks"
grpT = "Info Panel"
grpA = "Alerts"

orClock  = input.int(930, "OR Start  (HHMM, New York)", minval=0, maxval=2359, group=grpR,
     tooltip="Clock time the opening range starts, on a New York 24h clock, DST handled for you. 930 = the RTH equity open, which is what nearly everyone means by 'the opening range'. Other useful anchors: 1800 (the CME reopen), 300 (London), 000 (midnight true-day open).")
orMinsS  = input.string("15 min", "OR Length", options=["5 min","15 min","30 min","60 min"], group=grpR,
     tooltip="How long the range is measured for. 15 is the default and the most widely used, long enough to hold real two-way trade, short enough that the day still has somewhere to go. 5 is a narrower range, so price crosses its edges sooner and a break says less. 30 and 60 give a range so wide the extensions can be out of reach on a quiet day.")
extHrs   = input.float(6.5, "Extend Levels (hours)", minval=0.5, maxval=24, step=0.5, group=grpR,
     tooltip="How far to the right the levels are carried after the range closes. 6.5h from a 09:45 close reaches the 16:15 futures close, which is why it is the default. Shorten it if the old levels are crowding the right edge of your chart.")
histN    = input.int(5, "Keep Last N Sessions", minval=1, maxval=40, group=grpR,
     tooltip="How many completed opening ranges to retain. 5 ≈ a trading week. Raise it to study how price has treated the levels recently; each session costs roughly a dozen drawing objects.")

showBox  = input.bool(true, "Range Box", group=grpL, inline="bx")
boxCol   = input.color(color.new(#f5a800, 90), "", group=grpL, inline="bx")
boxBrd   = input.color(color.new(#f5a800, 35), "", group=grpL, inline="bx",
     tooltip="The shaded opening window. First swatch is the fill, second is the border. Each carries its own opacity, so drag the border to fully transparent if you want the shade alone.")
showLive = input.bool(true, "Show the range as it forms", group=grpL,
     tooltip="Draws a provisional box while the window is still open, replaced by the real one the moment it closes. Useful for watching the range build; turn it off if you would rather not see a level until it is final.")
showHL   = input.bool(true, "OR High / Low", group=grpL, inline="hl")
hiCol    = input.color(color.new(#f5a800, 15), "", group=grpL, inline="hl")
loCol    = input.color(color.new(#f5a800, 15), "", group=grpL, inline="hl")
hlSty    = input.string("Solid", "", options=["Solid","Dashed","Dotted"], group=grpL, inline="hl")
lvlW     = input.int(1, "", minval=1, maxval=4, group=grpL, inline="hl",
     tooltip="The two edges of the range. High colour, low colour, line style, width. Both ship amber because they are one range. Split the colours if you want the sides told apart at a glance.")
showMid  = input.bool(true, "OR Midpoint", group=grpL, inline="md",
     tooltip="The 50% of the opening range. It is the day's first equilibrium and price crossing back through it is the cleanest evidence a break has failed.")
// v1.1: was white at 30, which is invisible on a light chart. #787b86 reads on both.
midCol   = input.color(#787b86, "", group=grpL, inline="md")
midSty   = input.string("Dotted", "", options=["Solid","Dashed","Dotted"], group=grpL, inline="md")
midW     = input.int(1, "", minval=1, maxval=4, group=grpL, inline="md")
showLbl  = input.bool(true, "Label Levels", group=grpL, inline="lb")
lblSzIn  = input.string("Small", "", options=["Tiny","Small","Medium","Large"], group=grpL, inline="lb")
tagPos   = input.string("Line end", "Tag Position", options=["Line end","Chart edge"], group=grpL, inline="tg")
tagOff   = input.int(3, "bars past price", minval=1, maxval=50, group=grpL, inline="tg",
     tooltip="Where the level tags sit. LINE END (default) puts every tag where its line stops. CHART EDGE rides the current session's tags a few bars ahead of the newest bar while the levels are live, then returns them to the line end when the levels expire. Past sessions always use the line end. The number is how many bars of air Chart edge leaves between price and the tags.")

nExt     = input.int(2, "Extension Multiples (1× … N×)", minval=0, maxval=4, group=grpE,
     tooltip="How many range-widths to project beyond the OR high and low. 2 is the default: 1× and 2× are the usual measured-move levels. 3× and 4× sit a long way from the range, so drawing them every day mostly adds lines.")
showHalf = input.bool(false, "Also draw the 0.5× level", group=grpE,
     tooltip="Half a range width beyond each side. Off by default because it doubles the line count on the part of the chart price spends most of its time in, turn it on if you scale out early.")
upCol    = input.color(#26a69a, "Upside", group=grpE, inline="ec")
dnCol    = input.color(#ef5350, "Downside", group=grpE, inline="ec")
extSty   = input.string("Dashed", "Style", options=["Solid","Dashed","Dotted"], group=grpE, inline="es")
extW     = input.int(1, "Width", minval=1, maxval=4, group=grpE, inline="es")
extHist  = input.bool(false, "Keep extensions on past sessions", group=grpE,
     tooltip="OFF (default): the extension ladder is drawn for the current session only, and a finished session keeps its box, High, Low and Mid. ON: every kept session shows its full ladder, which is useful for studying how far past days travelled and busy on a zoomed-out chart.")

showBrk  = input.bool(true, "Mark the first break each side", group=grpB,
     tooltip="One circle per side per session, on the first bar that takes the level, never a second one. It marks that the range was taken, and nothing more. This is deliberately not a signal: a first break can turn out to be the day's move or the day's trap, and the mark does not know which.")
brkMode  = input.string("Close beyond", "Break Test", options=["Close beyond","Wick beyond"], group=grpB,
     tooltip="CLOSE BEYOND (default) is the stricter read: a bar has to finish outside the range. WICK BEYOND counts any trade through the level and marks it when that bar closes. Earlier and much noisier. If you are using this to study how often the first break holds, use Close.")
brkUpCol = input.color(#26a69a, "Mark colour  ↑", group=grpB, inline="bc")
brkDnCol = input.color(#ef5350, "↓", group=grpB, inline="bc")
brkSz    = input.string("Medium", "Size", options=["Tiny","Small","Medium","Large"], group=grpB, inline="bc")
brkLbl   = input.bool(false, "Print the word beside each mark", group=grpB,
     tooltip="OFF (default): each mark is a single glyph. ● a level was taken, ○ it was retested, ✕ the break failed. Hover a glyph for the detail. ON: the word is printed beside the glyph on the bar. That reads well on a quiet session and bunches up on a fast open, where neighbouring candles print through the text.")
tagEvt   = input.bool(true, "Write the session's events on the level tags", group=grpB,
     tooltip="Adds the day's story to the OR HIGH and OR LOW tags as it happens: ● and the time the level was taken, ○ and the time it was retested, ✕ and the time the break failed. Needs Label Levels on.")
showRet  = input.bool(true, "Mark the first retest of a broken level", group=grpB,
     tooltip="A hollow dot on the first bar that comes BACK to a level after breaking it. Price has to trade fully clear of the level first, so the bar straight after the break does not count. Once per side per session, and not after that break has already failed. It uses the same colours and size as the break marks. It marks that the level was revisited. Whether it held is yours to read.")
showFail = input.bool(true, "Mark a failed break", group=grpB, inline="fl")
failCol  = input.color(#ff9800, "", group=grpB, inline="fl",
     tooltip="A cross on the first bar that closes back through the fail level after a break. Once per side per session. Many traders read a failed break as the opening range being run for liquidity.")
failMode = input.string("Midpoint", "Break fails on a close back through", options=["Midpoint","Range edge"], group=grpB,
     tooltip="MIDPOINT (default): the break has failed once price closes back past the 50% of the range. Stricter, fires less, and by then the break is clearly over. RANGE EDGE: any close back inside the range counts. Earlier and noisier, because a break often dips inside once before it goes. OURS, not a sourced rule.")

tblOn    = input.bool(true, "Show Info Panel", group=grpT, inline="tp")
tblPos   = input.string("Top Right", "", options=["Top Left","Top Center","Top Right","Middle Left","Middle Right","Bottom Left","Bottom Center","Bottom Right"], group=grpT, inline="tp")
tblSz    = input.string("Small", "", options=["Tiny","Small","Medium","Large"], group=grpT, inline="tp",
     tooltip="The panel, where it sits, and its text size.")
tblRng   = input.bool(true, "Range rows", group=grpT, inline="ts")
tblDay   = input.bool(true, "Today rows", group=grpT, inline="ts",
     tooltip="Range rows: the window, the width, the width verdict and the two prices. Today rows: when each side was first taken and how many extensions have been reached. Turn either off to shrink the panel.")
tblBg    = input.color(color.new(#0c0e15, 6), "Background", group=grpT, inline="tc")
tblAcc   = input.color(#f5a800, "Accent", group=grpT, inline="tc")
tblKey   = input.color(#b2b5be, "Labels", group=grpT, inline="tc2")
tblVal   = input.color(color.white, "Values", group=grpT, inline="tc2",
     tooltip="Every panel colour. Accent drives the frame, the section bars and the highlighted values. The panel carries its own background, so it reads the same on a light chart and a dark one.")

alerts_on    = input.bool(false, "Enable alerts", group=grpA,
     tooltip="Master switch. With this ON, create ONE TradingView alert on this indicator with the condition set to Any alert() function call, and every event ticked below arrives through it. OFF, nothing fires regardless of the toggles.")
alBrk        = input.bool(true, "First break of the range", group=grpA, active=alerts_on,
     tooltip="Fires once per side per session, on the bar close that takes the level, with the price and the level in the message. It follows the Break Test setting. It fires even with the chart marks hidden.")
alRet        = input.bool(true, "Retest of a broken level", group=grpA, active=alerts_on,
     tooltip="Fires once per side per session, on the close of the first bar that comes back to a level after price had cleared it.")
alFail       = input.bool(true, "Break failed", group=grpA, active=alerts_on,
     tooltip="Fires once per side per session, on the first close back through the fail level chosen under Break Marks.")
alExt        = input.bool(true, "Extension level reached", group=grpA, active=alerts_on,
     tooltip="Fires once per extension level, on the close of the first bar that trades through it, and names which multiple it was. Stops when the levels expire, so nothing fires overnight against a finished range.")
alert_format = input.string("Plain", "Message format", options=["Plain","Webhook JSON"], group=grpA, active=alerts_on,
     tooltip="Webhook JSON wraps the message in a JSON content field, the shape chat webhooks expect, so an alert pointed at a webhook URL posts cleanly.")


// ═══════════════════════════════════════════════════════════════════════════════
//  MAPPERS (house library)
// ═══════════════════════════════════════════════════════════════════════════════
f_ls(string s) => s == "Solid" ? line.style_solid : s == "Dashed" ? line.style_dashed : line.style_dotted
f_szName(string s) => s == "Large" ? size.large : s == "Medium" ? size.normal : s == "Small" ? size.small : size.tiny
f_tblPos(simple string s) =>
    s == "Top Left" ? position.top_left : s == "Top Center" ? position.top_center :
     s == "Middle Left" ? position.middle_left : s == "Middle Right" ? position.middle_right :
     s == "Bottom Left" ? position.bottom_left : s == "Bottom Center" ? position.bottom_center :
     s == "Bottom Right" ? position.bottom_right : position.top_right

int orMins = orMinsS == "5 min" ? 5 : orMinsS == "30 min" ? 30 : orMinsS == "60 min" ? 60 : 15

// v1.4: moved up from the panel section. The tag story and the mark tooltips
// need it, and a Pine function cannot be called above its own definition.
// Built by hand rather than str.format("{0,number,00}"), the padding pattern is
// the kind of thing that is either exactly right or a runtime string error, and
// this version cannot be either.
f_hhmm(int t) =>
    string out = "-"
    if not na(t)
        int hh = hour(t, TZ)
        int mm = minute(t, TZ)
        out := (hh < 10 ? "0" : "") + str.tostring(hh) + ":" + (mm < 10 ? "0" : "") + str.tostring(mm)
    out

// v1.4: one level's day in one line, for its tag and for the panel.
f_story(bool took, int tT, bool ret, int rT, bool fail, int fT) =>
    (took ? "    ● " + f_hhmm(tT) : "") + (ret ? "   ○ " + f_hhmm(rT) : "") + (fail ? "   ✕ " + f_hhmm(fT) : "")


// ═══════════════════════════════════════════════════════════════════════════════
//  ALERT TRANSPORT (v1.1), the suite's shared transport.
//  varip, not var, and that is the whole point: a realtime bar can roll back and
//  recalculate, and a plain var buffer would roll back with it and let the same
//  event alert twice. varip survives the rollback, so an identical message inside
//  the 10-minute window is recognised as the repeat it is.
//  GLOBAL, not function-local: Pine instantiates a function-local varip PER CALL
//  SITE, which would give each event its own private buffer and defeat this.
//  Declared HERE, above every caller: a Pine function cannot reference a global
//  declared below it.
// ═══════════════════════════════════════════════════════════════════════════════
varip array<string> g_sentMsg = array.new<string>()
varip array<int>    g_sentT   = array.new<int>()

f_alert(bool en, string msg, bool needConf) =>
    if alerts_on and en and (not needConf or barstate.isconfirmed)
        bool dup = false
        if g_sentMsg.size() > 0
            for i = g_sentMsg.size() - 1 to 0
                if time - g_sentT.get(i) > 600000
                    break
                if g_sentMsg.get(i) == msg
                    dup := true
                    break
        if not dup
            g_sentMsg.push(msg)
            g_sentT.push(time)
            if g_sentMsg.size() > 40
                g_sentMsg.shift()
                g_sentT.shift()
            string m = "MM OR | " + syminfo.ticker + " | " + msg
            if alert_format == "Webhook JSON"
                m := '{"content":"' + m + '"}'
            alert(m, alert.freq_all)


// ═══════════════════════════════════════════════════════════════════════════════
//  DATA MODEL
//  One instance per completed opening range, each owning its own drawings →
//  UDT, per house rule "many-of-a-kind instances → UDTs". v6 needs an explicit
//  array.new() per array field in the constructor.
// ═══════════════════════════════════════════════════════════════════════════════
type ORng
    float hi
    float lo
    float h
    int   tS          // window open  (box left edge)
    int   tE          // window close (the moment the levels become valid)
    box   bx
    line  lnH
    line  lnL
    line  lnM
    array<line>  el   // extension lines
    array<label> lb   // High / Low / Mid tags
    array<float> ev   // the price of each extension, parallel to el
    array<bool>  et   // reached-yet flag, parallel to el
    // v1.2: labels split into three pools by JOB. One pool was fine while every
    // label lived and died with the range. Now tags move, extension tags can be
    // dropped early and break marks must stay put, so each needs its own list.
    array<label> xl   // extension tags
    array<label> mk   // break marks, never moved
    int   tR          // right edge of the level lines, where tags go at "Line end"
    label tgH         // v1.4: direct handles to the two tags that carry the story.
    label tgL         //   They also sit in lb, which still owns moving and deleting them.

f_newOR(float hi, float lo, float h, int tS, int tE) =>
    ORng.new(hi, lo, h, tS, tE, na, na, na, na,
     array.new<line>(), array.new<label>(), array.new<float>(), array.new<bool>(),
     array.new<label>(), array.new<label>(), na, na, na)

f_killOR(ORng r) =>
    box.delete(r.bx)
    line.delete(r.lnH)
    line.delete(r.lnL)
    line.delete(r.lnM)
    if r.el.size() > 0                     // guard: Pine runs `for 0 to -1` ONCE
        for i = 0 to r.el.size() - 1
            line.delete(r.el.get(i))
    if r.lb.size() > 0
        for i = 0 to r.lb.size() - 1
            label.delete(r.lb.get(i))
    if r.xl.size() > 0
        for i = 0 to r.xl.size() - 1
            label.delete(r.xl.get(i))
    if r.mk.size() > 0
        for i = 0 to r.mk.size() - 1
            label.delete(r.mk.get(i))
    0

// v1.2: slide every tag of a range to one x. Used to pin the live session's tags
// at the chart edge and to send them back to the line end when it is retired.
f_tagsTo(ORng r, int x) =>
    if r.lb.size() > 0
        for i = 0 to r.lb.size() - 1
            label.set_x(r.lb.get(i), x)
    if r.xl.size() > 0
        for i = 0 to r.xl.size() - 1
            label.set_x(r.xl.get(i), x)
    0

// v1.2: drop a finished session's ladder. The handles stay in the arrays on
// purpose: deleting a drawing twice is a safe no-op, and leaving el / ev / et
// the same length is what keeps those three index-locked.
f_dropExt(ORng r) =>
    if r.el.size() > 0
        for i = 0 to r.el.size() - 1
            line.delete(r.el.get(i))
    if r.xl.size() > 0
        for i = 0 to r.xl.size() - 1
            label.delete(r.xl.get(i))
    0

var array<ORng> ranges = array.new<ORng>()


// ═══════════════════════════════════════════════════════════════════════════════
//  WINDOW ENGINE, minutes-of-day, not a session string
//
//  A session string would have to be BUILT from the two inputs, and building a
//  `simple string` out of arithmetic is the kind of qualifier argument that only
//  shows up at compile time. Minutes-of-day sidesteps it entirely, and
//  hour()/minute() with a tz argument are DST-aware, so 09:30 stays 09:30 across
//  the March and November changes.
//
//  ⚠ Pine v6 footgun: int/int returns a FLOAT. `orClock / 100` is 9.3, not 9:
//  without the explicit int() this silently produces a window minutes off.
// ═══════════════════════════════════════════════════════════════════════════════
int startM = int(orClock / 100) * 60 + int(orClock % 100)
int endM   = startM + orMins
int nowM   = hour(time, TZ) * 60 + minute(time, TZ)

// wrap-aware: an 18:00 + 60 window runs past midnight and must not test as empty
bool inOR   = endM <= 1440 ? (nowM >= startM and nowM < endM) : (nowM >= startM or nowM < endM - 1440)
bool orOpen = inOR and not inOR[1]
bool orShut = not inOR and inOR[1]

var float rHi = na
var float rLo = na
var int   rN  = 0
var int   rT0 = na

if orOpen
    rHi := high
    rLo := low
    rN  := 1
    rT0 := time
else if inOR
    rHi := math.max(nz(rHi, high), high)
    rLo := math.min(nz(rLo, low),  low)
    rN  += 1

// The chart timeframe has to fit inside the window at least once, and the tool
// is meaningless outside intraday. Both checked before anything is drawn.
bool tfOk = timeframe.isintraday and timeframe.in_seconds(timeframe.period) <= orMins * 60


// ═══════════════════════════════════════════════════════════════════════════════
//  LIVE (FORMING) BOX, one reusable object, never part of the committed data
//  Suite rule: the committed range is rebuilt from data; this preview is a
//  separate, ephemeral drawing so the two can never be confused for each other.
// ═══════════════════════════════════════════════════════════════════════════════
var box liveBx = na
if showLive and showBox and tfOk and inOR and not na(rHi)
    if na(liveBx)
        liveBx := box.new(rT0, rHi, time, rLo, xloc=xloc.bar_time,
             border_color=boxBrd, border_style=line.style_dashed,
             border_width=1, bgcolor=boxCol)
    else
        box.set_lefttop(liveBx, rT0, rHi)
        box.set_rightbottom(liveBx, time, rLo)
if (orShut or not showLive or not showBox) and not na(liveBx)
    box.delete(liveBx)
    liveBx := na


// median of the width pool, median, not mean: OR width is right-skewed and one
// CPI morning would drag a mean upward for the next month.
f_median(array<float> a) =>
    float out = na
    int n = a.size()
    if n > 0
        array<float> s = array.copy(a)
        array.sort(s, order.ascending)
        // ⚠ v6 footgun: n / 2 is a FLOAT even for two ints, and array.get needs
        // an int index. The odd branch had the cast; the even branch did not.
        int half = int(n / 2)
        out := n % 2 == 1 ? s.get(half) : (s.get(half - 1) + s.get(half)) / 2.0
    out


// ═══════════════════════════════════════════════════════════════════════════════
//  COMMIT + DRAW THE LADDER
//  Drawn once, at the close of the window, and never re-positioned. Historical
//  objects are created in place (the create-in-place object model) rather than
//  wipe-and-rebuilt, because their coordinates are fixed the moment they exist.
// ═══════════════════════════════════════════════════════════════════════════════
var array<float> wHist = array.new<float>()   // completed OR widths, for the benchmark
var float curMed  = na                         // median of the pool BEFORE today joined it
var int   curMedN = 0                          // how many ranges that median stood on
var float curHi  = na                          // the session currently in play
var float curLo  = na
var float curH   = na
var int   curT   = na    // window close (last in-window bar)
var bool  upDone = false
var bool  dnDone = false
var int   upT    = na
var int   dnT    = na
// v1.3: the life of each break after it happens. Clr = price has traded fully
// clear of the level, which arms the retest. Ret = retested. Fail = failed.
var bool  upClr  = false
var bool  dnClr  = false
var bool  upRet  = false
var bool  dnRet  = false
var bool  upFail = false
var bool  dnFail = false
var int   upFT   = na
var int   dnFT   = na
var int   upRT   = na   // v1.4: retest times, for the tag story and the panel
var int   dnRT   = na

if orShut and tfOk and not na(rHi) and rN >= 1
    float h = rHi - rLo
    // the shut event fires on the first bar OUTSIDE the window, so the window's
    // true close is the previous bar, anchoring on `time` overhangs by one bar
    int tClose = time[1]
    // ⚠ math.round() returns a FLOAT in v6; a bar_time coordinate must be int
    int rEdge  = tClose + int(math.round(extHrs * 3600000))

    ORng r = f_newOR(rHi, rLo, h, nz(rT0, tClose), tClose)
    r.tR := rEdge

    if showBox
        r.bx := box.new(r.tS, r.hi, r.tE, r.lo, xloc=xloc.bar_time,
             border_color=boxBrd, border_width=1,
             bgcolor=boxCol)
    if showHL
        r.lnH := line.new(r.tE, r.hi, rEdge, r.hi, xloc=xloc.bar_time,
             color=hiCol, width=lvlW, style=f_ls(hlSty))
        r.lnL := line.new(r.tE, r.lo, rEdge, r.lo, xloc=xloc.bar_time,
             color=loCol, width=lvlW, style=f_ls(hlSty))
    if showMid
        float mid = (r.hi + r.lo) / 2.0
        r.lnM := line.new(r.tE, mid, rEdge, mid, xloc=xloc.bar_time,
             color=midCol, width=midW, style=f_ls(midSty))
        if showLbl
            r.lb.push(label.new(rEdge, mid, "OR MID  " + str.tostring(mid, format.mintick),
                 xloc=xloc.bar_time, style=label.style_label_left, textcolor=midCol,
                 color=COL_NONE, size=f_szName(lblSzIn)))

    if showLbl and showHL
        r.lb.push(label.new(rEdge, r.hi, "OR HIGH  " + str.tostring(r.hi, format.mintick),
             xloc=xloc.bar_time, style=label.style_label_left, textcolor=hiCol,
             color=COL_NONE, size=f_szName(lblSzIn)))
        r.lb.push(label.new(rEdge, r.lo, "OR LOW  " + str.tostring(r.lo, format.mintick),
             xloc=xloc.bar_time, style=label.style_label_left, textcolor=loCol,
             color=COL_NONE, size=f_szName(lblSzIn)))
        r.tgH := r.lb.get(r.lb.size() - 2)
        r.tgL := r.lb.get(r.lb.size() - 1)

    // ── the extension ladder ──
    // The 0.5× rung is pushed FIRST so the parallel arrays stay in draw order;
    // el / ev / et are index-locked and every push below writes all three.
    if showHalf
        float u5 = r.hi + h * 0.5
        float d5 = r.lo - h * 0.5
        r.el.push(line.new(r.tE, u5, rEdge, u5, xloc=xloc.bar_time, color=color.new(upCol, 45), width=extW, style=f_ls(extSty)))
        r.ev.push(u5), r.et.push(false)
        r.el.push(line.new(r.tE, d5, rEdge, d5, xloc=xloc.bar_time, color=color.new(dnCol, 45), width=extW, style=f_ls(extSty)))
        r.ev.push(d5), r.et.push(false)
        if showLbl
            r.xl.push(label.new(rEdge, u5, "+0.5×  " + str.tostring(u5, format.mintick), xloc=xloc.bar_time,
                 style=label.style_label_left, textcolor=color.new(upCol, 30), color=COL_NONE, size=f_szName(lblSzIn)))
            r.xl.push(label.new(rEdge, d5, "-0.5×  " + str.tostring(d5, format.mintick), xloc=xloc.bar_time,
                 style=label.style_label_left, textcolor=color.new(dnCol, 30), color=COL_NONE, size=f_szName(lblSzIn)))

    if nExt > 0                              // guard: `for 1 to 0` would run once
        for k = 1 to nExt
            float up = r.hi + h * k
            float dn = r.lo - h * k
            r.el.push(line.new(r.tE, up, rEdge, up, xloc=xloc.bar_time, color=upCol, width=extW, style=f_ls(extSty)))
            r.ev.push(up), r.et.push(false)
            r.el.push(line.new(r.tE, dn, rEdge, dn, xloc=xloc.bar_time, color=dnCol, width=extW, style=f_ls(extSty)))
            r.ev.push(dn), r.et.push(false)
            if showLbl
                r.xl.push(label.new(rEdge, up, "+" + str.tostring(k) + "×  " + str.tostring(up, format.mintick),
                     xloc=xloc.bar_time, style=label.style_label_left, textcolor=upCol, color=COL_NONE, size=f_szName(lblSzIn)))
                r.xl.push(label.new(rEdge, dn, "-" + str.tostring(k) + "×  " + str.tostring(dn, format.mintick),
                     xloc=xloc.bar_time, style=label.style_label_left, textcolor=dnCol, color=COL_NONE, size=f_szName(lblSzIn)))

    // v1.2: retire the outgoing session before the new one takes slot 0. Its tags
    // go back to the end of their own lines, and its ladder goes unless kept.
    if ranges.size() > 0
        ORng prev = ranges.get(0)
        f_tagsTo(prev, prev.tR)
        if not extHist
            f_dropExt(prev)

    ranges.unshift(r)
    while ranges.size() > histN
        f_killOR(ranges.pop())

    // ── arm this session's break tracking ──
    curHi  := r.hi
    curLo  := r.lo
    curH   := h
    curT   := tClose
    upDone := false
    dnDone := false
    upT    := na
    dnT    := na
    upClr  := false
    dnClr  := false
    upRet  := false
    dnRet  := false
    upFail := false
    dnFail := false
    upFT   := na
    upRT   := na
    dnRT   := na
    dnFT   := na

    // ── width benchmark pool (median of the last AVG_N completed ranges) ──
    // v1.1: the median is SNAPSHOTTED here, before today's width is pushed. v1.0's
    // comment promised exactly this and the code did the opposite: the panel read
    // the median on islast, long after the push, so today sat inside its own
    // benchmark. On NQ 1m it printed a flat 1x. A range measured against a pool
    // that contains it is pulled toward "normal" every time.
    curMed  := f_median(wHist)
    curMedN := wHist.size()
    wHist.push(h)
    if wHist.size() > AVG_N
        wHist.shift()


// ═══════════════════════════════════════════════════════════════════════════════
//  FIRST BREAK PER SIDE, once each, per session, and never again
// ═══════════════════════════════════════════════════════════════════════════════
bool useClose = brkMode == "Close beyond"
bool brkUp = false
bool brkDn = false
// The levels expire with the drawing. Without this the tool would happily print
// "first break of the session" at 03:00 the next morning against a range that
// stopped being today's range eleven hours earlier.
bool inTrackWin = not na(curT) and time <= curT + int(math.round(extHrs * 3600000))
// v1.1: `showBrk` came OUT of this gate. It was switching off the DETECTION, so
// hiding the marks also killed the alert and froze the panel's two break rows.
// The toggle hides a drawing. It does not get to change what happened.
if barstate.isconfirmed and not na(curHi) and not inOR and inTrackWin
    if not upDone and (useClose ? close > curHi : high > curHi)
        upDone := true
        upT    := time
        brkUp  := true
    if not dnDone and (useClose ? close < curLo : low < curLo)
        dnDone := true
        dnT    := time
        brkDn  := true

// v1.1: one label per mark, OWNED BY THE RANGE (pushed into its lb array), so it
// is deleted when that session ages out (v1.2: its own `mk` pool). v1.0 drew a plotshape plus a loose
// label: the plotshape could not take a size input and the label was never
// tracked, so marks outlived the levels they referred to.
// The dot and the name are one object, so the mark is never "just a floating
// dot". Standing rule in this suite: a chart mark needs an anchor. The body is transparent, so
// only the text shows and it sits clear of the bar on the break side.
if showBrk and (brkUp or brkDn) and ranges.size() > 0
    ORng rb = ranges.get(0)
    if brkUp
        rb.mk.push(label.new(time, high, brkLbl ? "OR HIGH taken\n●" : "●", xloc=xloc.bar_time, yloc=yloc.abovebar,
             style=label.style_label_down, color=COL_NONE, textcolor=brkUpCol, size=f_szName(brkSz), tooltip="OR HIGH taken  ·  " + f_hhmm(time) + " ET\nFirst break of the high this session."))
    if brkDn
        rb.mk.push(label.new(time, low, brkLbl ? "●\nOR LOW taken" : "●", xloc=xloc.bar_time, yloc=yloc.belowbar,
             style=label.style_label_up, color=COL_NONE, textcolor=brkDnCol, size=f_szName(brkSz), tooltip="OR LOW taken  ·  " + f_hhmm(time) + " ET\nFirst break of the low this session."))

// Confirmed-bar only (needConf = true): the break is judged on the close of the
// bar in both modes, so there is nothing to send before the bar has finished.
if brkUp
    f_alert(alBrk, "OR HIGH taken - " + (useClose ? "close " : "trade ") + str.tostring(useClose ? close : high, format.mintick) + " through " + str.tostring(curHi, format.mintick) + " · range " + str.tostring(curH, format.mintick) + " pts. First break of the session. An event, not a call.", true)
if brkDn
    f_alert(alBrk, "OR LOW taken - " + (useClose ? "close " : "trade ") + str.tostring(useClose ? close : low, format.mintick) + " through " + str.tostring(curLo, format.mintick) + " · range " + str.tostring(curH, format.mintick) + " pts. First break of the session. An event, not a call.", true)


// ═══════════════════════════════════════════════════════════════════════════════
//  AFTER THE BREAK (v1.3): retest and failed break, once each per side
//
//  Judged on barstate.isconfirmed like the break itself, so nothing here can
//  appear and then vanish. `time > upT` keeps the break bar out of its own
//  aftermath: that bar crossed the level by definition, so it would otherwise
//  read as an instant retest.
//
//  The retest needs price to have traded FULLY clear first (a whole bar above
//  the high, or below the low). Without that gate the bar straight after the
//  break, which nearly always still touches the level, would take the mark.
//  A retest is not marked once the break has failed: at that point price coming
//  back to the level is a different story and the dot would mislead.
// ═══════════════════════════════════════════════════════════════════════════════
bool retUp  = false
bool retDn  = false
bool failUp = false
bool failDn = false
if barstate.isconfirmed and not na(curHi) and not inOR and inTrackWin
    float curMid  = (curHi + curLo) / 2.0
    float fUpLvl  = failMode == "Midpoint" ? curMid : curHi
    float fDnLvl  = failMode == "Midpoint" ? curMid : curLo
    if upDone and time > upT
        if not upClr and low > curHi
            upClr := true
        else if upClr and not upRet and not upFail and low <= curHi
            upRet := true
            upRT  := time
            retUp := true
        if not upFail and close < fUpLvl
            upFail := true
            upFT   := time
            failUp := true
    if dnDone and time > dnT
        if not dnClr and high < curLo
            dnClr := true
        else if dnClr and not dnRet and not dnFail and high >= curLo
            dnRet := true
            dnRT  := time
            retDn := true
        if not dnFail and close > fDnLvl
            dnFail := true
            dnFT   := time
            failDn := true

// Marks sit on the side the bar came FROM, so they never cover the level itself:
// an upside retest dips down to the high, so its dot goes under the bar. A failed
// upside break is drawn above the bar, where the break mark was.
if (retUp or retDn or failUp or failDn) and ranges.size() > 0
    ORng rm = ranges.get(0)
    if retUp and showRet
        rm.mk.push(label.new(time, low, brkLbl ? "○\nretest" : "○", xloc=xloc.bar_time, yloc=yloc.belowbar,
             style=label.style_label_up, color=COL_NONE, textcolor=brkUpCol, size=f_szName(brkSz), tooltip="OR HIGH retested  ·  " + f_hhmm(time) + " ET\nFirst return to the level after price cleared it."))
    if retDn and showRet
        rm.mk.push(label.new(time, high, brkLbl ? "retest\n○" : "○", xloc=xloc.bar_time, yloc=yloc.abovebar,
             style=label.style_label_down, color=COL_NONE, textcolor=brkDnCol, size=f_szName(brkSz), tooltip="OR LOW retested  ·  " + f_hhmm(time) + " ET\nFirst return to the level after price cleared it."))
    // A break that fails within a few bars would print its cross on top of the
    // break mark, because both hang off the same side of neighbouring bars. Seen
    // on the first chart check, on a violent open. Three blank lines lift the
    // cross clear of the two-line break mark. Pine does not stack labels for you.
    int    nearMs = 6 * timeframe.in_seconds() * 1000
    string lift   = brkLbl ? "\n\n\n" : "\n"
    string padUp  = failUp and time - upT <= nearMs ? lift : ""
    string padDn  = failDn and time - dnT <= nearMs ? lift : ""
    if failUp and showFail
        rm.mk.push(label.new(time, high, (brkLbl ? "break failed\n✕" : "✕") + padUp, xloc=xloc.bar_time, yloc=yloc.abovebar,
             style=label.style_label_down, color=COL_NONE, textcolor=failCol, size=f_szName(brkSz), tooltip="OR HIGH break failed  ·  " + f_hhmm(time) + " ET\nClosed back through the fail level."))
    if failDn and showFail
        rm.mk.push(label.new(time, low, padDn + (brkLbl ? "✕\nbreak failed" : "✕"), xloc=xloc.bar_time, yloc=yloc.belowbar,
             style=label.style_label_up, color=COL_NONE, textcolor=failCol, size=f_szName(brkSz), tooltip="OR LOW break failed  ·  " + f_hhmm(time) + " ET\nClosed back through the fail level."))

if retUp
    f_alert(alRet, "OR HIGH retested - price came back to " + str.tostring(curHi, format.mintick) + " after clearing it, close " + str.tostring(close, format.mintick) + ". First retest of the session. An event, not a call.", true)
if retDn
    f_alert(alRet, "OR LOW retested - price came back to " + str.tostring(curLo, format.mintick) + " after clearing it, close " + str.tostring(close, format.mintick) + ". First retest of the session. An event, not a call.", true)
if failUp
    f_alert(alFail, "OR HIGH break FAILED - close " + str.tostring(close, format.mintick) + " back through " + str.tostring(failMode == "Midpoint" ? (curHi + curLo) / 2.0 : curHi, format.mintick) + ". The upside break did not hold.", true)
if failDn
    f_alert(alFail, "OR LOW break FAILED - close " + str.tostring(close, format.mintick) + " back through " + str.tostring(failMode == "Midpoint" ? (curHi + curLo) / 2.0 : curLo, format.mintick) + ". The downside break did not hold.", true)


// ═══════════════════════════════════════════════════════════════════════════════
//  THE STORY ON THE TAG (v1.4)
//  The text is REBUILT from the state variables every time, never appended to
//  what the label already says. A label mutation does not roll back, so an
//  append would stack one copy per recalculation. Rebuilding is idempotent.
// ═══════════════════════════════════════════════════════════════════════════════
if tagEvt and (brkUp or brkDn or retUp or retDn or failUp or failDn) and ranges.size() > 0
    ORng rs = ranges.get(0)
    label.set_text(rs.tgH, "OR HIGH  " + str.tostring(curHi, format.mintick) + f_story(upDone, upT, upRet, upRT, upFail, upFT))
    label.set_text(rs.tgL, "OR LOW  " + str.tostring(curLo, format.mintick) + f_story(dnDone, dnT, dnRet, dnRT, dnFail, dnFT))


// ═══════════════════════════════════════════════════════════════════════════════
//  EXTENSION TOUCH TRACKING, newest ladder only, each level fires once
// ═══════════════════════════════════════════════════════════════════════════════
// v1.1: gated on inTrackWin. Without it the ladder kept "reaching" levels all
// night against a range whose lines had already stopped.
if barstate.isconfirmed and ranges.size() > 0 and inTrackWin
    ORng r0 = ranges.get(0)
    if r0.ev.size() > 0                    // guard: `for 0 to -1` runs ONCE on empty
        for i = 0 to r0.ev.size() - 1
            if not r0.et.get(i)
                float v = r0.ev.get(i)
                if high >= v and low <= v  // the bar traded through the level
                    r0.et.set(i, true)
                    if r0.h > 0
                        bool  isUp = v > r0.hi
                        float mlt  = isUp ? (v - r0.hi) / r0.h : (r0.lo - v) / r0.h
                        f_alert(alExt, "Extension reached - " + (isUp ? "+" : "-") + str.tostring(mlt, "0.#") + "× at " + str.tostring(v, format.mintick) + ". Price is " + str.tostring(mlt, "0.#") + " range heights " + (isUp ? "above the OR high." : "below the OR low."), true)


// ═══════════════════════════════════════════════════════════════════════════════
//  TAG PINNING (v1.2), newest session only, and only while it is live
//  islast re-runs on every realtime tick, and that is fine here: the x is
//  recomputed from the bar's own time, never read back off the label, so the
//  operation is idempotent. A drawing is never the source of its own state.
//  timeframe.in_seconds() is an int, so the product stays an int and the
//  bar_time coordinate needs no cast.
// ═══════════════════════════════════════════════════════════════════════════════
// Standing rule (2026-10-02): a tag belongs to its line. The edge position is only
// allowed while the lines are still running (inTrackWin). The moment they stop,
// the tags go home to the line end, so a finished session never has labels
// floating out in empty space to the right of price.
if tagPos == "Chart edge" and barstate.islast and ranges.size() > 0
    ORng rt = ranges.get(0)
    f_tagsTo(rt, inTrackWin ? time + tagOff * timeframe.in_seconds() * 1000 : rt.tR)


// ═══════════════════════════════════════════════════════════════════════════════
//  INFO PANEL, one var table, rewritten on islast. Two columns, section bars.
// ═══════════════════════════════════════════════════════════════════════════════
var table tbl = table.new(f_tblPos(tblPos), 2, 9, bgcolor=tblBg,
     border_color=color.new(tblAcc, 94), border_width=1,
     frame_color=color.new(tblAcc, 40), frame_width=1)

f_sec(int row, string title) =>
    table.cell(tbl, 0, row, title, text_color=tblAcc, text_size=f_szName(tblSz),
         bgcolor=color.new(tblAcc, 82), text_halign=text.align_left)
    table.cell(tbl, 1, row, "", bgcolor=color.new(tblAcc, 82))
    row + 1

// v1.1: every row carries a hover tip on its label cell. A readout nobody can
// interpret is not doing its job. Values are monospace so the numbers line up.
f_row(int row, string k, string v, color vc, string tip) =>
    table.cell(tbl, 0, row, k, text_color=tblKey, text_size=f_szName(tblSz), text_halign=text.align_left, tooltip=tip)
    table.cell(tbl, 1, row, v, text_color=vc, text_size=f_szName(tblSz), text_halign=text.align_right,
         text_font_family=font.family_monospace)
    row + 1

// minutes-of-day → clock. Used for the WINDOW row so the panel reports the window
// the user configured, not the open time of the last bar that happened to fall in
// it, on a 5m chart those differ by a bar and the difference reads like a mistake.
f_clock(int m) =>
    int w = m % 1440
    int hh = int(w / 60)              // int/int → float in v6; cast or the label lies
    int mm = int(w % 60)
    (hh < 10 ? "0" : "") + str.tostring(hh) + ":" + (mm < 10 ? "0" : "") + str.tostring(mm)

if barstate.islast and tblOn
    table.clear(tbl, 0, 0, 1, 8)
    int r = 0
    r := f_sec(r, "OPENING RANGE  ·  " + orMinsS)
    if not tfOk
        r := f_row(r, "Unavailable", timeframe.isintraday ? "chart TF > OR length" : "intraday only",
             color.new(color.orange, 10), "The range needs at least one full chart bar inside its window. Drop the chart timeframe to the OR length or lower.")
    else if na(curHi)
        r := f_row(r, "Status", inOR ? "forming…" : "waiting for the open", tblKey,
             "No completed opening range in the loaded history yet.")
        if inOR and not na(rHi)
            r := f_row(r, "So far", str.tostring(rHi - rLo, format.mintick) + " pts", tblVal,
                 "The width of the range as it stands. Not final until the window closes.")
    else
        if tblRng
            r := f_row(r, "Window", f_clock(startM) + " → " + f_clock(endM) + " ET", tblVal,
                 "The clock window the range was measured in, New York time.")
            // int() cast: math.round() returns a FLOAT in v6 and str.tostring would
            // print "249" as "249" but "250.0" the moment the value is a round number
            r := f_row(r, "Width", str.tostring(curH, format.mintick) + " pts  ·  " +
                 str.tostring(int(math.round(curH / syminfo.mintick))) + " ticks", tblAcc,
                 "High minus low of the opening range. This is the unit every extension is measured in.")
            // withheld below the sample floor rather than printed weakly
            float med = curMed
            if curMedN >= AVG_MIN and not na(med) and med > 0
                float ratio = curH / med
                string verdict = ratio >= WIDE_X ? "wide" : ratio <= NARROW_X ? "tight" : "normal"
                r := f_row(r, "vs " + str.tostring(curMedN) + "-session median", str.tostring(ratio, "0.00") + "×  " + verdict,
                     ratio >= WIDE_X ? #ef5350 : ratio <= NARROW_X ? #26c6da : tblVal,
                     "Today's width against the median of the ranges before it, up to the last 20. The row names how many it had. Different chart timeframes load different amounts of history, so the figure can differ a little between them. Above 1.25× reads wide, below 0.80× reads tight. Those two cut-offs are OURS, not a published threshold.")
            else
                r := f_row(r, "vs median", "building  " + str.tostring(curMedN) + " of " + str.tostring(AVG_MIN), tblKey,
                     "Needs 10 completed ranges before it will give a verdict. Load more history or wait.")
            r := f_row(r, "High / Low", str.tostring(curHi, format.mintick) + "  /  " + str.tostring(curLo, format.mintick), tblVal,
                 "The two edges of the range.")
        if tblDay
            r := f_sec(r, "TODAY")
            r := f_row(r, "First break ↑", upDone ? str.trim(f_story(upDone, upT, upRet, upRT, upFail, upFT)) : "not taken", upDone ? brkUpCol : tblKey,
                 "● and a time is when the OR high was first taken. ○ is when it was first retested. ✕ is when that break failed.")
            r := f_row(r, "First break ↓", dnDone ? str.trim(f_story(dnDone, dnT, dnRet, dnRT, dnFail, dnFT)) : "not taken", dnDone ? brkDnCol : tblKey,
                 "● and a time is when the OR low was first taken. ○ is when it was first retested. ✕ is when that break failed.")
            if ranges.size() > 0
                ORng rr = ranges.get(0)
                int hits = 0
                if rr.et.size() > 0
                    for i = 0 to rr.et.size() - 1
                        if rr.et.get(i)
                            hits += 1
                r := f_row(r, "Extensions reached", str.tostring(hits) + " of " + str.tostring(rr.et.size()),
                     hits > 0 ? tblAcc : tblKey,
                     "How many of the drawn extension levels price has traded through this session.")


// ═══════════════════════════════════════════════════════════════════════════════
//  TIMEFRAME SANITY
// ═══════════════════════════════════════════════════════════════════════════════
var label warnLbl = na
if barstate.islast
    if not na(warnLbl)
        label.delete(warnLbl)
    if not tfOk
        warnLbl := label.new(bar_index, high,
             timeframe.isintraday
             ? "⚠ Chart timeframe is larger than the opening range.\nDrop to a chart at or below " + orMinsS + "."
             : "⚠ Opening Range Levels is an intraday tool.",
             style=label.style_label_down, color=color.new(color.orange, 15),
             textcolor=color.white, size=size.small)


// ═══════════════════════════════════════════════════════════════════════════════
//  ALERTS
// ═══════════════════════════════════════════════════════════════════════════════
// v1.1: the three alertcondition() calls that lived here are REMOVED. Their message
// had to be a const string, so it could not carry a price or say which level, and
// they cost three alert slots. Every alert now goes through f_alert at its event
// site: the two break alerts under FIRST BREAK PER SIDE, the extension alert inside
// EXTENSION TOUCH TRACKING. Each call is double-gated: the event AND its toggle.
// Safe to remove: v1.0 was never published, so no configured alert breaks.
````
