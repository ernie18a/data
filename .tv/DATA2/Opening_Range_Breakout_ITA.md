<!-- tradingview-pine-id: PUB;32b5840974b049eba7ede2684a471fab -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Opening Range Breakout [ITA]

Source: https://www.tradingview.com/script/1l4KG2VP-Opening-Range-Breakout-ITA/

## Description

🟠 OVERVIEW

Opening Range Breakout marks the high and low of the first minutes of the trading session, extends those boundaries forward, and flags the bar where price closes outside them. The range is built live as the session opens, tracking its running high and low, then locks once the opening period ends.

Once the range is set, the indicator measures its height and projects extension targets above and below it. Four range lengths are available, and the session open time and timezone are configurable so the tool works on any market rather than being fixed to a single exchange.

🟠 CONCEPTS

* Opening Range - The high and low established during the first minutes of the session. Represents the initial boundaries of agreement between buyers and sellers before the day develops.
* Range Lock - The moment the opening period ends and the boundaries stop updating. From that bar onward the levels extend forward unchanged.
* Extension Target - A projected level placed at a multiple of the range height above the range high or below the range low. Acts as a measured move reference rather than a prediction.
* Qualified Breakout - The first close outside the range in a given direction. Each direction is tracked independently and marked only once, so a session that breaks up, reverses and then breaks down shows both events without repeating either.
* Session Anchoring - The range window is evaluated in the selected timezone rather than the chart timezone, keeping it aligned to the actual market open regardless of the user's location.

🟠 FEATURES

* Selectable Range Length - Choose between 5, 15, 30 or 60 minute opening ranges.
* Live Range Building - The box tracks the running high and low as the opening period develops, then locks when it closes.
* Extension Targets - Projects two configurable multiples of the range height in both directions.
* Breakout Marking - Labels the first close outside the range in each direction.
* Breakout Alerts - Fires on upside and downside breaks independently.

🟠 HOW TO USE

* Match the range length to the instrument. Shorter ranges suit fast-moving markets and scalping, longer ranges suit index futures and higher-priced equities where the first minutes tend to be noisy.
* Set the session open time and timezone to your market. The default is 09:30 New York.
* Use the range boundaries as the reference for the session. Price holding inside them points to rotation, while a decisive close outside tends to set the tone for the rest of the day.
* Read the extension targets as measured moves. A tight opening range produces close targets, while a wide one produces targets that may take the full session to reach, which is itself useful when sizing expectations.
* Adjust Days to Display to keep the chart clean when reviewing several sessions of history.

🟠 CONCLUSION

Opening Range Breakout combines automatic range detection, forward-extending boundaries, and range-based extension targets in a single tool. It removes the manual work of marking the opening range each session while keeping the framework configurable enough to apply across different markets and session times.

---

## Source Code

````pine
// © ITA Trading Tools - itamardrori_
//@version=6
indicator("Opening Range Breakout [ITA]", overlay=true, max_boxes_count=100, max_lines_count=200, max_labels_count=200)

// ─── INPUTS ──────────────────────────────────────────────────────────────────
rangeMins  = input.string("15", "Opening Range Length", options=["5","15","30","60"], group="Range")
sessStart  = input.session("0930-0931", "Session Open Time", group="Range", tooltip="Market open in exchange time. 0930 for US stocks/futures.")
tz         = input.string("America/New_York", "Timezone", options=["America/New_York","Europe/London","Asia/Tokyo","Exchange"], group="Range")
maxDays    = input.int(5, "Days to Display", minval=1, maxval=30, group="Range")

showTargets = input.bool(true, "Show Extension Targets", group="Targets")
t1Mult      = input.float(1.0, "Target 1 (x range)", minval=0.5, maxval=5, step=0.5, group="Targets")
t2Mult      = input.float(2.0, "Target 2 (x range)", minval=0.5, maxval=5, step=0.5, group="Targets")

// 85 transparency was the original default and the box was almost invisible on
// a dark chart. The box is the whole point of the indicator, and on 4.9.2026
// the boost data showed the three weakest scripts were the three with the
// faintest drawings. A default nobody can see is a bad default.
rangeColor  = input.color(color.new(#2962ff, 75), "Range Fill", group="Style")
highColor   = input.color(color.new(#089981, 0),  "Range High", group="Style")
lowColor    = input.color(color.new(#f23645, 0),  "Range Low",  group="Style")
targetColor = input.color(color.new(#787b86, 30), "Target Lines", group="Style")
showLabels  = input.bool(true, "Show Labels", group="Style")
lblSizeStr  = input.string("Small", "Label Size", options=["Tiny","Small","Normal","Large"], group="Style")

lblSize = lblSizeStr == "Tiny" ? size.tiny : lblSizeStr == "Normal" ? size.normal : lblSizeStr == "Large" ? size.large : size.small

// ─── SESSION LOGIC ───────────────────────────────────────────────────────────
rangeLen = str.tonumber(rangeMins)
tzStr    = tz == "Exchange" ? syminfo.timezone : tz

// build the opening-range session string, e.g. "0930-0945"
openHH = str.substring(sessStart, 0, 2)
openMM = str.substring(sessStart, 2, 4)
openMinutes = str.tonumber(openHH) * 60 + str.tonumber(openMM)
closeMinutes = openMinutes + rangeLen
closeHH = math.floor(closeMinutes / 60)
closeMM = closeMinutes % 60
closeStr = (closeHH < 10 ? "0" : "") + str.tostring(closeHH) + (closeMM < 10 ? "0" : "") + str.tostring(closeMM)
orSession = str.substring(sessStart, 0, 4) + "-" + closeStr

inOR = not na(time(timeframe.period, orSession, tzStr))

// ─── STATE ───────────────────────────────────────────────────────────────────
var float orHigh    = na
var float orLow     = na
var int   orStart   = na
var bool  orDone    = false
var bool  brokeUp   = false
var bool  brokeDown = false

var box   orBox   = na
var line  hiLine  = na
var line  loLine  = na
var line  t1Up    = na
var line  t2Up    = na
var line  t1Dn    = na
var line  t2Dn    = na
var label hiLbl   = na
var label loLbl   = na

cutoff = timenow - maxDays * 86400000
recent = time > cutoff

newSession = inOR and not inOR[1]

// start of a new opening range
if newSession and recent
    orHigh    := high
    orLow     := low
    orStart   := bar_index
    orDone    := false
    brokeUp   := false
    brokeDown := false
    orBox  := box.new(bar_index, orHigh, bar_index, orLow, bgcolor=rangeColor, border_color=color.new(color.gray, 40), border_width=2)
    hiLine := line.new(bar_index, orHigh, bar_index, orHigh, color=highColor, style=line.style_solid, width=2)
    loLine := line.new(bar_index, orLow,  bar_index, orLow,  color=lowColor,  style=line.style_solid, width=2)
    if showTargets
        t1Up := line.new(bar_index, orHigh, bar_index, orHigh, color=targetColor, style=line.style_dotted, width=1)
        t2Up := line.new(bar_index, orHigh, bar_index, orHigh, color=targetColor, style=line.style_dotted, width=1)
        t1Dn := line.new(bar_index, orLow,  bar_index, orLow,  color=targetColor, style=line.style_dotted, width=1)
        t2Dn := line.new(bar_index, orLow,  bar_index, orLow,  color=targetColor, style=line.style_dotted, width=1)

// building the range
else if inOR and not na(orBox)
    orHigh := math.max(orHigh, high)
    orLow  := math.min(orLow,  low)
    box.set_top(orBox, orHigh)
    box.set_bottom(orBox, orLow)
    box.set_right(orBox, bar_index)
    line.set_xy1(hiLine, orStart, orHigh)
    line.set_xy2(hiLine, bar_index, orHigh)
    line.set_xy1(loLine, orStart, orLow)
    line.set_xy2(loLine, bar_index, orLow)

// range closed - extend levels and targets forward
else if not inOR and not na(orBox) and not na(orHigh)
    if not orDone
        orDone := true
    rng = orHigh - orLow
    line.set_xy2(hiLine, bar_index, orHigh)
    line.set_xy2(loLine, bar_index, orLow)
    if showTargets and not na(t1Up)
        line.set_xy1(t1Up, orStart, orHigh + rng * t1Mult)
        line.set_xy2(t1Up, bar_index, orHigh + rng * t1Mult)
        line.set_xy1(t2Up, orStart, orHigh + rng * t2Mult)
        line.set_xy2(t2Up, bar_index, orHigh + rng * t2Mult)
        line.set_xy1(t1Dn, orStart, orLow - rng * t1Mult)
        line.set_xy2(t1Dn, bar_index, orLow - rng * t1Mult)
        line.set_xy1(t2Dn, orStart, orLow - rng * t2Mult)
        line.set_xy2(t2Dn, bar_index, orLow - rng * t2Mult)

// ─── BREAKOUT DETECTION ──────────────────────────────────────────────────────
breakUp   = orDone and not brokeUp   and not na(orHigh) and close > orHigh
breakDown = orDone and not brokeDown and not na(orLow)  and close < orLow

if breakUp
    brokeUp := true
    if showLabels
        label.new(bar_index, high, "ORB ↑", style=label.style_label_down, color=color.new(highColor, 10), textcolor=color.white, size=lblSize)
if breakDown
    brokeDown := true
    if showLabels
        label.new(bar_index, low, "ORB ↓", style=label.style_label_up, color=color.new(lowColor, 10), textcolor=color.white, size=lblSize)

// ─── ALERTS ──────────────────────────────────────────────────────────────────
alertcondition(breakUp,   "Opening Range Breakout Up",   "Price broke above the opening range high")
alertcondition(breakDown, "Opening Range Breakout Down", "Price broke below the opening range low")
````
