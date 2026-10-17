# ICT Balanced Price Range (BPR)

- url: https://www.tradingview.com/script/eGvnxDh1-ICT-Balanced-Price-Range-BPR/
- type: indicator
- pine_id: PUB;a9ffd3ef7036490bafaca2f18959f06d
- version: 1.0

## Description

What it does:
It scans for bullish FVGs and bearish FVGs and any time the two overlap, it draws a purple BPR zone with a dashed CE midpoint line through the center. Each new FVG is checked against all unmitigated opposite FVGs going back as far as your lookback setting.
FVGs are marked as mitigated (and their boxes closed off) when price reaches the CE midpoint — you can switch this to "full fill" in the settings if you prefer the stricter definition.

Settings to play with:
[*]FVG Lookback — how far back to check for opposing FVGs. Higher = more BPRs found but more noise. 75–100 is a solid starting point on 1H/4H.
[*]Mitigate on Full Fill — off by default (CE mitigation). Turn on if you only want zones removed when price closes fully through them.
[*]Show Individual FVG Zones — off by default to keep the chart clean. Turn on if you want to see all the underlying gaps.


Balanced Price Range (BPR) Entries
This is probably the most underused precision tool in the ICT model. A BPR forms when a bullish FVG and a bearish FVG overlap on the same chart. The overlapping zone represents a highly contested area where both buy-side and sell-side imbalances exist. On the 1H–4H, when price returns to that overlap zone — especially after a structural shift — it tends to produce very clean reactions. Most traders just trade the FVGs individually and miss the confluence entirely.

What's Actually Happening (The Logic)
A Fair Value Gap is an imbalance — price moved so aggressively in one direction that one side of the market (buyers or sellers) wasn't fairly represented. A bullish FVG is where sellers were absent. A bearish FVG is where buyers were absent. When these two overlap, you have a zone where both sides were absent at different moments. That's genuinely contested space. When price returns there, the algorithm is essentially repricing through an area it skipped twice — and the reaction tends to be sharp and decisive because both sets of orders (the unfilled buys and unfilled sells) are stacked in the same region.

How to Identify It
You're looking for a bearish FVG and a bullish FVG whose ranges overlap. The overlap itself is the BPR. A few things to note:
The FVGs don't need to be from the same timeframe, but for 1H–4H trading you want both gaps to be meaningful — created by displacement candles, not just routine movement. A gap created by a news spike or a thin-market move is junk. You want gaps born from genuine institutional displacement.
The overlap zone can be small or large. A tighter overlap is actually preferable — it means the contested space is precise and price is likely to react quickly rather than grind through it.
The BPR is most powerful when it sits inside a larger discount zone (if you're looking for longs) or a premium zone (if you're looking for shorts). An isolated BPR in the middle of a range with no HTF context is just noise.

## Source Code

````pine
//@version=5
indicator("ICT Balanced Price Range (BPR)", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=200)

// ══════════════════════════════════════════════════════════════════════════════
//  INPUTS
// ══════════════════════════════════════════════════════════════════════════════
lookback = input.int  (100,   "FVG Lookback (bars)",       minval=20, maxval=500, group="Settings",
     tooltip="How many bars back to scan for opposing FVGs when checking for a BPR overlap.")
mitFull  = input.bool (false, "Mitigate on Full Fill",     group="Settings",
     tooltip="OFF: zone is mitigated when price reaches the CE midpoint. ON: only when price closes fully through the zone.")

showFVGs = input.bool (false, "Show Individual FVG Zones", group="Display")
showBPR  = input.bool (true,  "Show BPR Zones",            group="Display")
showCE   = input.bool (true,  "Show CE Midpoint Line",     group="Display")
showLbl  = input.bool (true,  "Show BPR Label",            group="Display")

bullC = input.color(color.new(#26C6DA, 82), "Bullish FVG",  group="Colors")
bearC = input.color(color.new(#EF5350, 82), "Bearish FVG",  group="Colors")
bprC  = input.color(color.new(#7C3AED, 65), "BPR Fill",     group="Colors")
bprBC = input.color(color.new(#7C3AED, 20), "BPR Border",   group="Colors")
ceC   = input.color(#A78BFA,                "CE Line",      group="Colors")


// ══════════════════════════════════════════════════════════════════════════════
//  STATE ARRAYS
// ══════════════════════════════════════════════════════════════════════════════
var float[]      bTop   = array.new_float()
var float[]      bBot   = array.new_float()
var int[]        bBar   = array.new_int()
var bool[]       bMit   = array.new_bool()
var array<box>   bBoxes = array.new<box>()

var float[]      rTop   = array.new_float()
var float[]      rBot   = array.new_float()
var int[]        rBar   = array.new_int()
var bool[]       rMit   = array.new_bool()
var array<box>   rBoxes = array.new<box>()

var array<box>   bprBoxes   = array.new<box>()
var array<line>  bprCELines = array.new<line>()
var array<label> bprLabels  = array.new<label>()


// ══════════════════════════════════════════════════════════════════════════════
//  HELPERS
// ══════════════════════════════════════════════════════════════════════════════
mitLevel(top, bot) =>
    mitFull ? bot : (top + bot) * 0.5

invisBox() =>
    box.new(bar_index, 0.0, bar_index, 0.0, bgcolor=color.new(color.white, 100), border_color=color.new(color.white, 100))


// ══════════════════════════════════════════════════════════════════════════════
//  FVG DETECTION
// ══════════════════════════════════════════════════════════════════════════════
newBull = high[2] < low[0]
newBear = low[2]  > high[0]


// ══════════════════════════════════════════════════════════════════════════════
//  NEW BULLISH FVG
// ══════════════════════════════════════════════════════════════════════════════
if newBull
    nTop = low[0]
    nBot = high[2]
    nBar = bar_index - 1

    array.push(bTop, nTop)
    array.push(bBot, nBot)
    array.push(bBar, nBar)
    array.push(bMit, false)
    array.push(bBoxes,
         showFVGs ?
         box.new(bar_index - 2, nTop, bar_index, nBot,
                 bgcolor=bullC, border_color=color.new(#26C6DA, 50), border_width=1,
                 extend=extend.right) :
         invisBox())

    // Check against all unmitigated bear FVGs for BPR overlap
    rSz = array.size(rTop)
    if rSz > 0
        for j = 0 to rSz - 1
            if not array.get(rMit, j)
                jTop    = array.get(rTop, j)
                jBot    = array.get(rBot, j)
                jBar    = array.get(rBar, j)
                oTop    = math.min(nTop, jTop)
                oBot    = math.max(nBot, jBot)
                if oTop > oBot
                    ce      = (oTop + oBot) * 0.5
                    leftBar = math.min(nBar, jBar) - 1
                    if showBPR
                        bx = box.new(leftBar, oTop, bar_index, oBot,
                             bgcolor=bprC, border_color=bprBC, border_width=2,
                             extend=extend.right)
                        array.push(bprBoxes, bx)
                    if showCE
                        ln = line.new(leftBar, ce, bar_index, ce,
                             color=ceC, style=line.style_dashed, width=1,
                             extend=extend.right)
                        array.push(bprCELines, ln)
                    if showLbl
                        lb = label.new(bar_index, oTop, "BPR",
                             color=color.new(#7C3AED, 20), textcolor=color.white,
                             style=label.style_label_left, size=size.small)
                        array.push(bprLabels, lb)

    if array.size(bTop) > lookback
        array.shift(bTop)
        array.shift(bBot)
        array.shift(bBar)
        array.shift(bMit)
        box.delete(array.shift(bBoxes))


// ══════════════════════════════════════════════════════════════════════════════
//  NEW BEARISH FVG
// ══════════════════════════════════════════════════════════════════════════════
if newBear
    nTop = low[2]
    nBot = high[0]
    nBar = bar_index - 1

    array.push(rTop, nTop)
    array.push(rBot, nBot)
    array.push(rBar, nBar)
    array.push(rMit, false)
    array.push(rBoxes,
         showFVGs ?
         box.new(bar_index - 2, nTop, bar_index, nBot,
                 bgcolor=bearC, border_color=color.new(#EF5350, 50), border_width=1,
                 extend=extend.right) :
         invisBox())

    // Check against all unmitigated bull FVGs for BPR overlap
    bSz = array.size(bTop)
    if bSz > 0
        for j = 0 to bSz - 1
            if not array.get(bMit, j)
                jTop    = array.get(bTop, j)
                jBot    = array.get(bBot, j)
                jBar    = array.get(bBar, j)
                oTop    = math.min(nTop, jTop)
                oBot    = math.max(nBot, jBot)
                if oTop > oBot
                    ce      = (oTop + oBot) * 0.5
                    leftBar = math.min(nBar, jBar) - 1
                    if showBPR
                        bx = box.new(leftBar, oTop, bar_index, oBot,
                             bgcolor=bprC, border_color=bprBC, border_width=2,
                             extend=extend.right)
                        array.push(bprBoxes, bx)
                    if showCE
                        ln = line.new(leftBar, ce, bar_index, ce,
                             color=ceC, style=line.style_dashed, width=1,
                             extend=extend.right)
                        array.push(bprCELines, ln)
                    if showLbl
                        lb = label.new(bar_index, oTop, "BPR",
                             color=color.new(#7C3AED, 20), textcolor=color.white,
                             style=label.style_label_left, size=size.small)
                        array.push(bprLabels, lb)

    if array.size(rTop) > lookback
        array.shift(rTop)
        array.shift(rBot)
        array.shift(rBar)
        array.shift(rMit)
        box.delete(array.shift(rBoxes))


// ══════════════════════════════════════════════════════════════════════════════
//  MITIGATION — runs every bar
//  When price reaches the mitigation level, stop extending the zone
// ══════════════════════════════════════════════════════════════════════════════
bTopSz = array.size(bTop)
if bTopSz > 0
    for i = 0 to bTopSz - 1
        if not array.get(bMit, i)
            lvl = mitLevel(array.get(bTop, i), array.get(bBot, i))
            if low <= lvl
                array.set(bMit, i, true)
                bx = array.get(bBoxes, i)
                box.set_extend(bx, extend.none)
                box.set_right(bx, bar_index)
                if showFVGs
                    box.set_bgcolor(bx, color.new(color.gray, 88))
                    box.set_border_color(bx, color.new(color.gray, 60))

rTopSz = array.size(rTop)
if rTopSz > 0
    for i = 0 to rTopSz - 1
        if not array.get(rMit, i)
            lvl = mitLevel(array.get(rTop, i), array.get(rBot, i))
            if high >= lvl
                array.set(rMit, i, true)
                bx = array.get(rBoxes, i)
                box.set_extend(bx, extend.none)
                box.set_right(bx, bar_index)
                if showFVGs
                    box.set_bgcolor(bx, color.new(color.gray, 88))
                    box.set_border_color(bx, color.new(color.gray, 60))


// ══════════════════════════════════════════════════════════════════════════════
//  ALERT
// ══════════════════════════════════════════════════════════════════════════════
alertcondition(newBull or newBear, "New FVG Detected",
     "A new Fair Value Gap has formed — check for BPR overlap.")
````
