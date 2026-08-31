<!-- tradingview-pine-id: PUB;918dcd9dabb847a4ba258e18ff1dfc2a -->
<!-- tradingviewscripts-format: 1 -->
# Range Break Levels (MTF)

Source: https://www.tradingview.com/script/4adData2-Range-Break-Levels-MTF/

## Description

range break analysis
0.66 chance of continuation
0.33 chance of reversal

works on multi time frame

---

## Source Code

````pine
//@version=6
// ═══════════════════════════════════════════════════════════════════════════
//  RANGE BREAK LEVELS (MTF)
//
//  The ranges themselves, drawn on the candles. The direction strip that used
//  to live here is now its own script, "Range MTF Lines", which docks in a pane
//  at the bottom of the chart. Both use the identical range engine, so they
//  always agree.
//
//  Logic
//  -----
//  1. The first available candle defines the initial range (its high / low).
//  2. The range stays alive while candles CLOSE inside it.
//  3. The first candle that CLOSES outside the range terminates it, and that
//     same candle's high / low becomes the NEW range.
//  4. Repeat forever.
//
//  Every range is therefore born from a break and carries a direction, which is
//  what colours it: UP (green by default) when it was created by a close ABOVE
//  the old range, DOWN (red) when created by a close BELOW it. The very first
//  range on the chart has no parent, so it draws neutral.
//
//  4 independent timeframe slots run at once (defaults 5 / 15 / 30 / 60 min),
//  each with its own visibility tick, colours and line width.
//
//  Fibs
//  ----
//  Optional interior levels of the live range, per slot: the 0.5 midpoint plus
//  two custom levels you type in yourself (0 = range low, 1 = range high; values
//  outside 0-1 project beyond the range). They follow whichever slots have
//  "Show range" ticked.
// ═══════════════════════════════════════════════════════════════════════════
indicator("Range Break Levels (MTF)", shorttitle = "RangeBreak MTF", overlay = true)

// ──────────────────────── Fibs inside the range ────────────────────
grpF      = "Fib levels inside range"
fibOn     = input.bool(false, "Draw fibs inside the active range", group = grpF,
     tooltip = "Interior levels of whatever range is currently alive, for every slot that has \"Show range\" " +
     "ticked. They step to the new range on the same candle the range does. Levels are measured from the " +
     "range LOW: 0 = low, 0.5 = midpoint, 1 = high. Values outside 0-1 project beyond the range.")
fib50On   = input.bool(true, "0.50 (midpoint)", group = grpF)
fibAOn    = input.bool(false, "Custom 1", group = grpF, inline = "fa")
fibALvl   = input.float(0.66, "", minval = -5, maxval = 5, step = 0.01, group = grpF, inline = "fa")
fibBOn    = input.bool(false, "Custom 2", group = grpF, inline = "fb")
fibBLvl   = input.float(0.34, "", minval = -5, maxval = 5, step = 0.01, group = grpF, inline = "fb")
fibTrans  = input.int(45, "Transparency", minval = 0, maxval = 90, group = grpF, inline = "g")
fibWid    = input.int(1, "Width", minval = 1, maxval = 4, group = grpF, inline = "g")

// ───────────────────────────── Slot inputs ─────────────────────────
grp1  = "Range 1"
sr1   = input.bool(true, "Show range", group = grp1, inline = "s")
tf1   = input.timeframe("5", "TF", group = grp1, inline = "s")
cu1   = input.color(color.new(color.green, 0), "Up", group = grp1, inline = "c")
cd1   = input.color(color.new(color.red, 0),   "Down", group = grp1, inline = "c")
cn1   = input.color(color.new(color.gray, 0),  "First", group = grp1, inline = "c")
wid1  = input.int(1, "Line width", minval = 1, maxval = 4, group = grp1)
alr1  = input.bool(false, "Alert on break", group = grp1)

grp2  = "Range 2"
sr2   = input.bool(true, "Show range", group = grp2, inline = "s")
tf2   = input.timeframe("15", "TF", group = grp2, inline = "s")
cu2   = input.color(color.new(color.green, 0), "Up", group = grp2, inline = "c")
cd2   = input.color(color.new(color.red, 0),   "Down", group = grp2, inline = "c")
cn2   = input.color(color.new(color.gray, 0),  "First", group = grp2, inline = "c")
wid2  = input.int(1, "Line width", minval = 1, maxval = 4, group = grp2)
alr2  = input.bool(false, "Alert on break", group = grp2)

grp3  = "Range 3"
sr3   = input.bool(true, "Show range", group = grp3, inline = "s")
tf3   = input.timeframe("30", "TF", group = grp3, inline = "s")
cu3   = input.color(color.new(color.green, 0), "Up", group = grp3, inline = "c")
cd3   = input.color(color.new(color.red, 0),   "Down", group = grp3, inline = "c")
cn3   = input.color(color.new(color.gray, 0),  "First", group = grp3, inline = "c")
wid3  = input.int(1, "Line width", minval = 1, maxval = 4, group = grp3)
alr3  = input.bool(false, "Alert on break", group = grp3)

grp4  = "Range 4"
sr4   = input.bool(true, "Show range", group = grp4, inline = "s")
tf4   = input.timeframe("60", "TF", group = grp4, inline = "s")
cu4   = input.color(color.new(color.green, 0), "Up", group = grp4, inline = "c")
cd4   = input.color(color.new(color.red, 0),   "Down", group = grp4, inline = "c")
cn4   = input.color(color.new(color.gray, 0),  "First", group = grp4, inline = "c")
wid4  = input.int(1, "Line width", minval = 1, maxval = 4, group = grp4)
alr4  = input.bool(false, "Alert on break", group = grp4)

// ───────────────────────── Core state machine ──────────────────────
// Runs on whatever timeframe it is evaluated in (chart or HTF via security).
// cnt increments every time a brand new range is established -> a change in cnt
// is the "range broke" trigger. dir carries how that range was born:
// 1 = broke up, -1 = broke down, 0 = the very first range (no parent).
rangeState() =>
    var float rH  = na
    var float rL  = na
    var int   cnt = 0
    var int   dir = 0
    if na(rH)
        rH  := high
        rL  := low
        dir := 0
        cnt += 1
    else if close > rH or close < rL
        dir := close > rH ? 1 : -1
        rH  := high
        rL  := low
        cnt += 1
    [rH, rL, cnt, dir]

// Slot TF == chart TF is evaluated natively (zero lag: the range flips on the
// very candle that breaks it). Higher TFs go through security and track the
// live HTF bar in real time.
getRange(simple string tf) =>
    simple bool isChart = tf == "" or tf == timeframe.period
    [nh, nl, nc, nd] = rangeState()
    [xh, xl, xc, xd] = request.security(syminfo.tickerid, tf, rangeState())
    float outH = isChart ? nh : xh
    float outL = isChart ? nl : xl
    int   outC = isChart ? nc : xc
    int   outD = isChart ? nd : xd
    [outH, outL, outC, outD]

// ─────────────────────────────── Wiring ────────────────────────────
[rh1, rl1, c1, d1] = getRange(tf1)
[rh2, rl2, c2, d2] = getRange(tf2)
[rh3, rl3, c3, d3] = getRange(tf3)
[rh4, rl4, c4, d4] = getRange(tf4)

name1 = tf1 == "" ? timeframe.period : tf1
name2 = tf2 == "" ? timeframe.period : tf2
name3 = tf3 == "" ? timeframe.period : tf3
name4 = tf4 == "" ? timeframe.period : tf4

// Direction colour of the live range, using that slot's own palette.
dirCol(int d, color cu, color cd, color cn) => d == 1 ? cu : d == -1 ? cd : cn

dc1 = dirCol(d1, cu1, cd1, cn1)
dc2 = dirCol(d2, cu2, cd2, cn2)
dc3 = dirCol(d3, cu3, cd3, cn3)
dc4 = dirCol(d4, cu4, cd4, cn4)

brk1 = not na(c1) and not na(c1[1]) and c1 != c1[1]
brk2 = not na(c2) and not na(c2[1]) and c2 != c2[1]
brk3 = not na(c3) and not na(c3[1]) and c3 != c3[1]
brk4 = not na(c4) and not na(c4[1]) and c4 != c4[1]

// ──────────────────── Range high / low on price ────────────────────
plot(sr1 ? rh1 : na, "R1 High", color = dc1, style = plot.style_stepline, linewidth = wid1)
plot(sr1 ? rl1 : na, "R1 Low",  color = dc1, style = plot.style_stepline, linewidth = wid1)
plot(sr2 ? rh2 : na, "R2 High", color = dc2, style = plot.style_stepline, linewidth = wid2)
plot(sr2 ? rl2 : na, "R2 Low",  color = dc2, style = plot.style_stepline, linewidth = wid2)
plot(sr3 ? rh3 : na, "R3 High", color = dc3, style = plot.style_stepline, linewidth = wid3)
plot(sr3 ? rl3 : na, "R3 Low",  color = dc3, style = plot.style_stepline, linewidth = wid3)
plot(sr4 ? rh4 : na, "R4 High", color = dc4, style = plot.style_stepline, linewidth = wid4)
plot(sr4 ? rl4 : na, "R4 Low",  color = dc4, style = plot.style_stepline, linewidth = wid4)

// ─────────────────── Interior fibs of the active range ─────────────
// Measured from the range LOW, so the level reads the same whichever way the
// range was born. They inherit the range's direction colour and follow the
// slot's "Show range" tick.
fibLvl(bool show, bool on, float hi, float lo, float f) =>
    show and fibOn and on and not na(hi) and not na(lo) ? lo + (hi - lo) * f : na

f50_1 = fibLvl(sr1, fib50On, rh1, rl1, 0.50)
fA_1  = fibLvl(sr1, fibAOn,  rh1, rl1, fibALvl)
fB_1  = fibLvl(sr1, fibBOn,  rh1, rl1, fibBLvl)
f50_2 = fibLvl(sr2, fib50On, rh2, rl2, 0.50)
fA_2  = fibLvl(sr2, fibAOn,  rh2, rl2, fibALvl)
fB_2  = fibLvl(sr2, fibBOn,  rh2, rl2, fibBLvl)
f50_3 = fibLvl(sr3, fib50On, rh3, rl3, 0.50)
fA_3  = fibLvl(sr3, fibAOn,  rh3, rl3, fibALvl)
fB_3  = fibLvl(sr3, fibBOn,  rh3, rl3, fibBLvl)
f50_4 = fibLvl(sr4, fib50On, rh4, rl4, 0.50)
fA_4  = fibLvl(sr4, fibAOn,  rh4, rl4, fibALvl)
fB_4  = fibLvl(sr4, fibBOn,  rh4, rl4, fibBLvl)

fcol1 = color.new(dc1, fibTrans)
fcol2 = color.new(dc2, fibTrans)
fcol3 = color.new(dc3, fibTrans)
fcol4 = color.new(dc4, fibTrans)

plot(f50_1, "R1 fib 0.50",     color = fcol1, style = plot.style_stepline, linewidth = fibWid)
plot(fA_1,  "R1 fib custom 1", color = fcol1, style = plot.style_stepline, linewidth = fibWid)
plot(fB_1,  "R1 fib custom 2", color = fcol1, style = plot.style_stepline, linewidth = fibWid)
plot(f50_2, "R2 fib 0.50",     color = fcol2, style = plot.style_stepline, linewidth = fibWid)
plot(fA_2,  "R2 fib custom 1", color = fcol2, style = plot.style_stepline, linewidth = fibWid)
plot(fB_2,  "R2 fib custom 2", color = fcol2, style = plot.style_stepline, linewidth = fibWid)
plot(f50_3, "R3 fib 0.50",     color = fcol3, style = plot.style_stepline, linewidth = fibWid)
plot(fA_3,  "R3 fib custom 1", color = fcol3, style = plot.style_stepline, linewidth = fibWid)
plot(fB_3,  "R3 fib custom 2", color = fcol3, style = plot.style_stepline, linewidth = fibWid)
plot(f50_4, "R4 fib 0.50",     color = fcol4, style = plot.style_stepline, linewidth = fibWid)
plot(fA_4,  "R4 fib custom 1", color = fcol4, style = plot.style_stepline, linewidth = fibWid)
plot(fB_4,  "R4 fib custom 2", color = fcol4, style = plot.style_stepline, linewidth = fibWid)

// ─────────────────────────────── Alerts ────────────────────────────
if brk1 and alr1 and barstate.isconfirmed
    alert("Range break " + name1 + " — new range " + str.tostring(rl1) + " / " + str.tostring(rh1), alert.freq_once_per_bar)
if brk2 and alr2 and barstate.isconfirmed
    alert("Range break " + name2 + " — new range " + str.tostring(rl2) + " / " + str.tostring(rh2), alert.freq_once_per_bar)
if brk3 and alr3 and barstate.isconfirmed
    alert("Range break " + name3 + " — new range " + str.tostring(rl3) + " / " + str.tostring(rh3), alert.freq_once_per_bar)
if brk4 and alr4 and barstate.isconfirmed
    alert("Range break " + name4 + " — new range " + str.tostring(rl4) + " / " + str.tostring(rh4), alert.freq_once_per_bar)
````
