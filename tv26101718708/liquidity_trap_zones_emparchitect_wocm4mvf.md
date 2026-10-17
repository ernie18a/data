# Liquidity Trap Zones [EmpArchitect]

- url: https://www.tradingview.com/script/wOcm4MvF-Liquidity-Trap-Zones-EmpArchitect/
- type: indicator
- pine_id: PUB;e46331d0988342578b805602a4df5923
- version: 1.0

## Description

█ What This Does

This indicator detects a strict failed-reversal event:
A candle attempts to reverse → the very next candle closes beyond its extreme with displacement → that failed candle's range becomes the trap zone.

These are the zones where countertrend orders are now trapped and may fuel the continuation move.

One pattern. Multiple vocabularies.
- ICT traders will recognize the same event through breaker / mitigation logic
- Wyckoff traders may read it as a spring or upthrust-style trap
- Classical price action sees a failed breakout
- Retail traders call it a bull or bear trap
The detection is the same in every case.


█ How It Works

Formation (strict 1-bar invalidation):
  1. Bar N-1: failed reversal candle (bearish for bullish traps, bullish for bearish traps)
  2. Bar N: closes beyond bar N-1's extreme with displacement body ≥ C-grade threshold
  3. The range of bar N-1 becomes the trap zone

Grading (fixed at formation, never changes):
  • A-grade: body ≥ 2.5 × ATR — strong displacement
  • B-grade: body ≥ 1.7 × ATR — moderate displacement
  • C-grade: body ≥ 1.2 × ATR — minimum valid
  Opacity encodes grade visually — A is most saturated, C is most transparent.

Zone lifecycle:
  • Fresh — not yet touched. Full color, extends right.
  • Tested — price wicked into the zone (optional, off by default).
  • Resolved — price closed beyond the opposite edge. Zone deleted immediately.

Directional bias filter:
  Optional rolling HH/LL expansion filter. This is NOT swing-confirmed BOS — it is a lightweight structure bias. Toggle off to see all raw detections.


█ Vocabulary Toggle

Choose your label language in settings. Detection is identical in all modes:
  • Plain / ICT: Bull B · 76,400.0 / Bear A · 79,200.5
  • Wyckoff: Spring B · 76,400.0 / UT A · 79,200.5


█ Display Controls

  • Max Bull / Bear Zones — caps visible zones per direction. Oldest deleted when exceeded.
    Recommended: 15m = 2 | 1H = 3 | 4H = 5
  • Show Tested Zones — off by default for cleaner charts
  • Extend Fresh Right — fresh zones extend to the right edge
  • Show Trigger Markers — marks the displacement candle with ◆ grade
  • Small status card shows current bias and zone counts


█ Non-Repainting

All zones are confirmed on closed bars only.
Formation requires bar N-1 to be fully closed.
Displacement is confirmed when bar N closes — never mid-bar.
No future bar data is used at any point in the logic.


█ Pairs With

Smart Liquidity Map [EmpArchitect] — the map shows where liquidity sits. Trap Zones show where it gets taken.


█ Alerts

  • Bull Trap Zone Formed
  • Bear Trap Zone Formed
  • Any Trap Zone Formed

## Source Code

````pine
//@version=6
indicator("Liquidity Trap Zones [EmpArchitect]", shorttitle="TrapZones [EA]", overlay=true, max_boxes_count=200, max_labels_count=500)

grp1 = "Detection"
atrLen  = input.int(14,    "ATR Length",               minval=5,  maxval=50,  group=grp1)
gradeA  = input.float(2.5, "A-grade (x ATR)",          minval=1.5,step=0.1,   group=grp1)
gradeB  = input.float(1.7, "B-grade (x ATR)",          minval=1.0,step=0.1,   group=grp1)
gradeC  = input.float(1.2, "C-grade (x ATR)",          minval=0.8,step=0.05,  group=grp1)
useCtx  = input.bool(true, "Directional Bias",          group=grp1, tooltip="Rolling HH/LL expansion. NOT swing BOS. Off = all detections.")
ctxLen  = input.int(30,    "Bias Lookback",             minval=10, maxval=100, group=grp1)

grp2 = "Display"
showOnlyA   = input.bool(false, "A-grade Only",         group=grp2)
showC       = input.bool(true,  "Show C-grade",          group=grp2)
maxBull     = input.int(3,      "Max Bull Zones",        minval=1, maxval=10,  group=grp2, tooltip="15m=2, 1H=3, 4H=5")
maxBear     = input.int(3,      "Max Bear Zones",        minval=1, maxval=10,  group=grp2)
showTested  = input.bool(false, "Show Tested Zones",     group=grp2)
extendFresh = input.bool(true,  "Extend Fresh Right",    group=grp2)

grp3 = "Colours"
bullA      = input.color(color.new(#00D9A3, 20), "Bull A", group=grp3)
bullB      = input.color(color.new(#00D9A3, 50), "Bull B", group=grp3)
bullC      = input.color(color.new(#00D9A3, 75), "Bull C", group=grp3)
bearA      = input.color(color.new(#FF4B5C, 20), "Bear A", group=grp3)
bearB      = input.color(color.new(#FF4B5C, 50), "Bear B", group=grp3)
bearC      = input.color(color.new(#FF4B5C, 75), "Bear C", group=grp3)
testedFill = input.color(color.new(#FFA726, 80), "Tested", group=grp3)

grp4 = "Labels & Markers"
vocab      = input.string("Plain", "Vocabulary", group=grp4, options=["Plain", "ICT", "Wyckoff"], tooltip="Plain/ICT: Bull A / Bear B\nWyckoff: Spring A / UT B")
showDash   = input.bool(true,  "Show Dashboard",      group=grp4)
showMarker = input.bool(true,  "Show Trigger Markers", group=grp4, tooltip="Marks the displacement candle that created each zone.")

atr     = ta.atr(atrLen)
atrPrev = nz(atr[1], atr)
body    = math.abs(close - open)
isBull  = close > open
isBear  = close < open

ready    = bar_index >= ctxLen * 2
recentHH = ta.highest(high,  ctxLen)
recentLL = ta.lowest( low,   ctxLen)
priorHH  = ta.highest(high[ctxLen], ctxLen)
priorLL  = ta.lowest( low[ctxLen],  ctxLen)

bullBias = ready and recentHH > priorHH
bearBias = ready and recentLL < priorLL
ctxBull  = not useCtx or (bullBias and not bearBias)
ctxBear  = not useCtx or (bearBias and not bullBias)

string biasStr = bullBias and not bearBias ? "▲ Bullish" : bearBias and not bullBias ? "▼ Bearish" : "— Neutral"
color  biasCol = bullBias and not bearBias ? #00D9A3 : bearBias and not bullBias ? #FF4B5C : #6B7280

getGrade(float b, float a) =>
    string g = "C"
    if b >= gradeA * a
        g := "A"
    else if b >= gradeB * a
        g := "B"
    g

bullGrade = getGrade(body, atrPrev)
bearGrade = getGrade(body, atrPrev)

bullCol(string g) =>
    g == "A" ? bullA : g == "B" ? bullB : bullC

bearCol(string g) =>
    g == "A" ? bearA : g == "B" ? bearB : bearC

buildLabel(string g, bool bull, float price) =>
    string base = ""
    if vocab == "Wyckoff"
        base := bull ? "Spring" : "UT"
    else
        base := bull ? "Bull" : "Bear"
    base + " " + g + " · " + str.tostring(price, format.mintick)

prevBear = close[1] < open[1]
prevBull = close[1] > open[1]
fBull = prevBear and close > high[1] and isBull and body >= gradeC * atrPrev and ctxBull
fBear = prevBull and close < low[1]  and isBear and body >= gradeC * atrPrev and ctxBear

var box[]    BX  = array.new_box()
var label[]  LB  = array.new_label()
var float[]  TOP = array.new_float()
var float[]  BOT = array.new_float()
var bool[]   DIR = array.new_bool()
var string[] GRD = array.new_string()
var int[]    ST  = array.new_int()
var int[]    BR  = array.new_int()

del(int i) =>
    box.delete(array.get(BX, i))
    lb = array.get(LB, i)
    if not na(lb)
        label.delete(lb)
    array.remove(BX,  i)
    array.remove(LB,  i)
    array.remove(TOP, i)
    array.remove(BOT, i)
    array.remove(DIR, i)
    array.remove(GRD, i)
    array.remove(ST,  i)
    array.remove(BR,  i)

var bool evtFB = false
var bool evtFR = false
evtFB := false
evtFR := false

addZone(float top, float bot, bool bull, string g) =>
    ok = (not showOnlyA or g == "A") and (showC or g != "C")
    if ok
        fc  = bull ? bullCol(g) : bearCol(g)
        bc  = bull ? color.new(#00D9A3, 5) : color.new(#FF4B5C, 5)
        bx  = box.new(bar_index - 1, top, bar_index, bot, bgcolor=fc, border_color=bc, border_width=1, extend=extendFresh ? extend.right : extend.none)

        label lb = na
        txt = buildLabel(g, bull, bull ? top : bot)
        float labelY = bull ? top : bot
        lb := label.new(bar_index, labelY, txt, style=bull ? label.style_label_down : label.style_label_up, color=color.new(bull ? #00D9A3 : #FF4B5C, 70), textcolor=color.white, size=size.tiny)

        if showMarker
            string mTxt = "◆ " + g
            label.new(bar_index, bull ? low - atrPrev * 0.15 : high + atrPrev * 0.15, mTxt, style=bull ? label.style_label_up : label.style_label_down, color=color.new(color.black, 100), textcolor=bull ? #00D9A3 : #FF4B5C, size=size.tiny)

        array.push(BX,  bx)
        array.push(LB,  lb)
        array.push(TOP, top)
        array.push(BOT, bot)
        array.push(DIR, bull)
        array.push(GRD, g)
        array.push(ST,  0)
        array.push(BR,  bar_index)

if fBull
    addZone(high[1], low[1], true,  bullGrade)
    evtFB := true

if fBear
    addZone(high[1], low[1], false, bearGrade)
    evtFR := true

int[] gone = array.new_int()
int   n    = array.size(BX)

if n > 0
    for i = n - 1 to 0
        st   = array.get(ST,  i)
        born = array.get(BR,  i)
        top  = array.get(TOP, i)
        bot  = array.get(BOT, i)
        bull = array.get(DIR, i)
        g    = array.get(GRD, i)
        bx   = array.get(BX,  i)
        lb   = array.get(LB,  i)

        if bar_index <= born
            continue

        if st == 0 and not na(lb)
            label.set_x(lb, bar_index)
            float labelY = bull ? top : bot
            label.set_y(lb, labelY)
            label.set_text(lb, buildLabel(g, bull, bull ? top : bot))

        inZone = low <= top and high >= bot

        if bull
            if close < bot
                array.push(gone, i)
            else if st == 0 and inZone
                array.set(ST, i, 1)
                if not showTested
                    array.push(gone, i)
                else
                    box.set_bgcolor(bx, testedFill)
                    box.set_border_color(bx, color.new(#FFA726, 40))
                    box.set_extend(bx, extend.none)
                    box.set_right(bx, bar_index)
        else
            if close > top
                array.push(gone, i)
            else if st == 0 and inZone
                array.set(ST, i, 1)
                if not showTested
                    array.push(gone, i)
                else
                    box.set_bgcolor(bx, testedFill)
                    box.set_border_color(bx, color.new(#FFA726, 40))
                    box.set_extend(bx, extend.none)
                    box.set_right(bx, bar_index)

if array.size(gone) > 0
    for j = array.size(gone) - 1 to 0
        idx = array.get(gone, j)
        if idx < array.size(BX)
            del(idx)

int[] prune = array.new_int()
int   bc    = 0
int   be    = 0
int   pn    = array.size(BX)

if pn > 0
    for i = pn - 1 to 0
        bull = array.get(DIR, i)
        if bull
            bc += 1
            if bc > maxBull
                array.push(prune, i)
        else
            be += 1
            if be > maxBear
                array.push(prune, i)

if array.size(prune) > 0
    for j = array.size(prune) - 1 to 0
        idx = array.get(prune, j)
        if idx < array.size(BX)
            del(idx)

int bullCount = 0
int bearCount = 0
int sz = array.size(BX)
if sz > 0
    for i = 0 to sz - 1
        if array.get(DIR, i)
            bullCount += 1
        else
            bearCount += 1

var table dash = table.new(position.top_right, 2, 4, bgcolor=color.new(color.black, 82), border_width=0)

if barstate.islast and showDash
    table.cell(dash, 0, 0, "Trap Zones", text_color=color.white, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 0, "v1.0", text_color=#6B7280, text_size=size.tiny, text_halign=text.align_right)
    table.cell(dash, 0, 1, "Bias", text_color=#9CA3AF, text_size=size.tiny, text_halign=text.align_left)
    table.cell(dash, 1, 1, useCtx ? biasStr : "Off", text_color=useCtx ? biasCol : #6B7280, text_size=size.tiny, text_halign=text.align_right)
    table.cell(dash, 0, 2, "▲ Bull", text_color=#00D9A3, text_size=size.tiny, text_halign=text.align_left)
    table.cell(dash, 1, 2, str.tostring(bullCount), text_color=color.white, text_size=size.tiny, text_halign=text.align_right)
    table.cell(dash, 0, 3, "▼ Bear", text_color=#FF4B5C, text_size=size.tiny, text_halign=text.align_left)
    table.cell(dash, 1, 3, str.tostring(bearCount), text_color=color.white, text_size=size.tiny, text_halign=text.align_right)
else if barstate.islast and not showDash
    table.clear(dash, 0, 0, 1, 3)

aFB = evtFB and (not showOnlyA or bullGrade == "A") and (showC or bullGrade != "C")
aFR = evtFR and (not showOnlyA or bearGrade == "A") and (showC or bearGrade != "C")

alertcondition(aFB,        title="Bull Trap Zone Formed", message="Bullish Liquidity Trap Zone formed")
alertcondition(aFR,        title="Bear Trap Zone Formed", message="Bearish Liquidity Trap Zone formed")
alertcondition(aFB or aFR, title="Trap Zone Formed",      message="Liquidity Trap Zone formed")
````
