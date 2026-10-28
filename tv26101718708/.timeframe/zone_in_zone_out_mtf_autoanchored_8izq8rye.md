# Zone in, Zone out (MTF Auto-Anchored)

- url: https://www.tradingview.com/script/8IzQ8ryE-Zone-in-Zone-out-MTF-Auto-Anchored/
- type: indicator
- pine_id: PUB;44d4c46cc37f43e6b5552facf63e8c14
- version: 2.0

## Description

ZIZO · BTC Zone Projector (MTF, Auto-Anchored)
 
Auto-anchored cycle zones off the 200-day SMA. No manual anchoring. No hardcoded dates. Every number on screen is a chosen value, not a fitted one.
 
Hard money. Don't trust. Verify.
 
──────────────────────────────
 
WHAT IT DOES
 
Most zone tools make you drag an anchor to a top or bottom by hand. This one places the anchor for you.
 
When price makes a confirmed 200-SMA cross, the script drops an anchor at that cross and fans out a set of percentage-offset zones — five to the upside, five to the downside. Each set stays pinned to its own cross. When a new regime confirms, a fresh set spawns and the old one closes off.
 
The upside ladder walks the emotional cycle of a bull:
Optimism → Belief → Thrill → Euphoria → Maximum Risk
 
The downside ladder walks the bear:
Anxiety → Denial → Panic → Capitulation → Maximum Opportunity
 
──────────────────────────────
 
HOW THE ANCHORING WORKS
 
Three ideas do the heavy lifting.
 
1. The SMA runs on a timeframe you choose, not your chart timeframe.
Set the source to Daily (default) and you get a true 200-day SMA even while you view a Weekly chart. The cross logic is computed on that source timeframe and pulled in with lookahead off, so confirmed anchors do not repaint.
 
2. A new anchor locks only after conviction, not on the first touch.
Price has to hold on one side of the SMA for N consecutive source-timeframe closes (default 20) before a new anchor prints. That filters the chop around the line. The trade-off is honest and by design: the anchor appears a little after the cross itself.
 
3. A set ends fast, but starts slow.
A cycle is marked complete on the first single-bar confirmed close on the opposite side of the SMA. Slow to commit to a new regime, quick to admit the last one is over. The asymmetry is deliberate.
 
The live set — the one you're in right now — projects forward to a fixed expiry date you set. Completed sets simply terminate at the close that ended them. That keeps old geometry from cluttering the projection.
 
──────────────────────────────
 
WHAT YOU SEE
 
• Anchor line at 0% (the cross price) with a bull/bear tag.
• Ten zone lines with price and percentage labels.
• Heat-gradient fills between zones (green→blue below, yellow→red above).
• A cross signal label at each confirmed anchor.
• A cycle-duration label — elapsed days while a set is live, realised days once it completes. Days are counted on the calendar, not by bar, so data gaps and mixed timeframes don't distort the count.
• An optional Cycle Map table: current anchor, price now, deviation from anchor, and the stage you're standing in.
 
You can show the current set only, the last bull plus last bear, or every confirmed anchor in history.
 
──────────────────────────────
 
INPUTS WORTH KNOWING
 
• Confirm bars — how many consecutive closes lock a new anchor. Higher = fewer, cleaner anchors. Lower = earlier, noisier ones.
• Source timeframe — where the SMA and cross confirmation live. Keep it at or below your chart timeframe.
• Zone expiry date — how far the live set projects.
• Upside / Downside offsets — the percentage ladder. This is your calibration. Own it.
• Per-zone visibility, colours, line style, fills, table position.
 
──────────────────────────────
 
HONEST NOTES
 
This is a framing tool, not a crystal ball. The zones are geometry measured off an anchor. They mark where the emotional stages of past cycles have tended to sit relative to the 200-SMA cross — they are not forecasts, and the market is under no obligation to respect them.
 
The offsets ship calibrated for BTC. Change the asset and the numbers should change with it. Verify them against your own history before you trust a single line.
 
The confirmation filter means the anchor prints after the cross, on purpose. If you want an earlier anchor, lower the confirm-bars count and accept more noise. There is no free lunch here — only a dial you control.
 
Nothing here is financial advice. It is a lens for thinking, not a signal to act.
 
Hard money. Don't trust. Verify.
 
— PseudoNakamoto21

## Source Code

````pine
//@version=6
// ══════════════════════════════════════════════════════════════════
// Zone in ,Zone out · BTC Zone Projector (MTF, Auto-Anchored)  ·  PseudoNakamoto21
// 200-SMA cross-anchored zone sets. Anchors confirm on N bars;
// a cycle completes on the first 1-bar-confirmed opposite close.
// Hard money. Don't trust. Verify.
// ══════════════════════════════════════════════════════════════════
indicator("Zone in, Zone out (MTF Auto-Anchored)", overlay=true, max_lines_count=500, max_labels_count=500)

// ① Cross Detection
maLen       = input.int(200, "SMA length", minval=1, maxval=500, group="① Cross Detection")
confirmBars = input.int(20,  "Confirm bars (anchor)", minval=1, maxval=50, group="① Cross Detection",
              tooltip="Consecutive source-timeframe closes price must hold above/below the SMA before a NEW anchor locks. Completion of the previous cycle uses 1-bar confirmation, not this value.")
srcTF       = input.timeframe("D", "Source timeframe", group="① Cross Detection",
              tooltip="Timeframe the SMA and cross confirmation run on, independent of the chart. Default D = 200-day SMA even on a Weekly chart. Keep ≤ chart timeframe.")

// ② Display
expiryTime  = input.time(timestamp("31 Dec 2026 00:00 +0000"), "Zone expiry date", group="② Display",
              tooltip="Fixed date the LIVE zone set projects to. Completed sets terminate at the first 1-bar-confirmed opposite close.")
labelMode   = input.string("Current only", "Anchors shown", options=["All", "Last up + last down", "Current only"], group="② Display",
              tooltip="Current only: newest anchor. Last up + last down: newest bull + newest bear. All: every confirmed anchor. Only the live set projects to expiry.")

// ③ Upside Offsets %
u1=input.float(70,"U1 · Optimism",           step=0.00001, group="③ Upside Offsets %")
u2=input.float(100,"U2 · Belief",             step=0.00001, group="③ Upside Offsets %")
u3=input.float(140,"U3 · Thrill",             step=0.00001, group="③ Upside Offsets %")
u4=input.float(190,"U4 · Euphoria",           step=0.00001, group="③ Upside Offsets %")
u5=input.float(250,"U5 · Maximum Risk",       step=0.00001, group="③ Upside Offsets %")

// ④ Downside Offsets %
d1=input.float(26, "D1 · Anxiety",            step=0.00001, group="④ Downside Offsets %")
d2=input.float(42, "D2 · Denial",             step=0.00001, group="④ Downside Offsets %")
d3=input.float(50, "D3 · Panic",              step=0.00001, group="④ Downside Offsets %")
d4=input.float(58, "D4 · Capitulation",       step=0.00001, group="④ Downside Offsets %")
d5=input.float(66, "D5 · Maximum Opportunity",step=0.00001, group="④ Downside Offsets %")

// ⑤ Zone Visibility
vU1=input.bool(true,"U1 · Optimism",           group="⑤ Zone Visibility — Upside")
vU2=input.bool(true,"U2 · Belief",             group="⑤ Zone Visibility — Upside")
vU3=input.bool(true,"U3 · Thrill",             group="⑤ Zone Visibility — Upside")
vU4=input.bool(true,"U4 · Euphoria",           group="⑤ Zone Visibility — Upside")
vU5=input.bool(true,"U5 · Maximum Risk",       group="⑤ Zone Visibility — Upside")
vD1=input.bool(true,"D1 · Anxiety",            group="⑤ Zone Visibility — Downside")
vD2=input.bool(true,"D2 · Denial",             group="⑤ Zone Visibility — Downside")
vD3=input.bool(true,"D3 · Panic",              group="⑤ Zone Visibility — Downside")
vD4=input.bool(true,"D4 · Capitulation",       group="⑤ Zone Visibility — Downside")
vD5=input.bool(true,"D5 · Maximum Opportunity",group="⑤ Zone Visibility — Downside")

// ⑥ Colours
uc1=input.color(#e6e64c,"U1",group="⑥ Upside Colours (yellow→red)",inline="uc")
uc2=input.color(#ffcc33,"U2",group="⑥ Upside Colours (yellow→red)",inline="uc")
uc3=input.color(#ff9933,"U3",group="⑥ Upside Colours (yellow→red)",inline="uc")
uc4=input.color(#ff6633,"U4",group="⑥ Upside Colours (yellow→red)",inline="uc")
uc5=input.color(#e6392d,"U5",group="⑥ Upside Colours (yellow→red)",inline="uc")
dc1=input.color(#a6d96e,"D1",group="⑥ Downside Colours (green→blue)",inline="dc")
dc2=input.color(#3ed9a6,"D2",group="⑥ Downside Colours (green→blue)",inline="dc")
dc3=input.color(#2eb8d9,"D3",group="⑥ Downside Colours (green→blue)",inline="dc")
dc4=input.color(#1e7cc2,"D4",group="⑥ Downside Colours (green→blue)",inline="dc")
dc5=input.color(#0a4d8c,"D5",group="⑥ Downside Colours (green→blue)",inline="dc")

// ⑦ Style
showLabels   = input.bool(true,  "Show price labels",           group="⑦ Style")
showAnchor   = input.bool(true,  "Show anchor (0%) line",       group="⑦ Style")
showBounds   = input.bool(true,  "Show start/finish verticals", group="⑦ Style")
showFills    = input.bool(true,  "Fill zones (heat gradient)",  group="⑦ Style")
showCross    = input.bool(true,  "Show cross signal labels",    group="⑦ Style")
showDuration = input.bool(true,  "Show cycle-duration label",   group="⑦ Style")
fillTransp   = input.int(85,     "Fill transparency", minval=0, maxval=100, group="⑦ Style")
tablePos     = input.string("None", "Cycle-map table", options=["Top Left","Top Right","Bottom Left","Bottom Right","None"], group="⑦ Style")
labelDec     = input.int(2,      "Label decimals (%)", minval=0, maxval=8, group="⑦ Style")
lineWidth    = input.int(1,      "Zone line width", minval=1, maxval=4, group="⑦ Style")
styleStr     = input.string("Solid", "Zone line style", options=["Solid","Dashed","Dotted"], group="⑦ Style")

lineStyle = styleStr == "Dashed" ? line.style_dashed : styleStr == "Dotted" ? line.style_dotted : line.style_solid

// ════════════ SMA & CROSS LOGIC (multi-timeframe) ════════════
// Anchor confirms on `confirmBars` consecutive closes; completion trigger
// fires on the first close (1-bar) after a side flip. Monotonic ids keep
// mid-period events from being dropped when sampled at chart resolution.
f_crossState() =>
    var int   _abv        = 0
    var int   _blw        = 0
    var int   _crossId    = 0
    var int   _crossDir   = 0
    var float _crossPrice = na
    var int   _crossTime  = na
    var int   _trigId     = 0
    var int   _trigDir    = 0
    var int   _trigTime   = na

    _sma = ta.sma(close, maLen)

    if close > _sma
        _abv += 1
        _blw := 0
    else if close < _sma
        _blw += 1
        _abv := 0

    // 1-bar-confirmed side flip = completion trigger
    if _abv == 1
        _trigId  += 1
        _trigDir := 1
        _trigTime := time
    if _blw == 1
        _trigId  += 1
        _trigDir := -1
        _trigTime := time

    // full anchor confirmation
    if _abv == confirmBars
        _crossId    += 1
        _crossDir   := 1
        _crossPrice := _sma[confirmBars - 1]
        _crossTime  := time[confirmBars - 1]
    if _blw == confirmBars
        _crossId    += 1
        _crossDir   := -1
        _crossPrice := _sma[confirmBars - 1]
        _crossTime  := time[confirmBars - 1]

    [_crossId, _crossDir, _crossPrice, _crossTime, _trigId, _trigDir, _trigTime]

[srcCrossId, srcCrossDir, srcCrossPrice, srcCrossTime, srcTrigId, srcTrigDir, srcTrigTime] =
     request.security(syminfo.tickerid, srcTF, f_crossState(), lookahead=barmerge.lookahead_off)

// ── Anchor stream ──
var int lastSeenCrossId = 0
newCross  = srcCrossId > lastSeenCrossId
crossUp   = newCross and srcCrossDir == 1
crossDown = newCross and srcCrossDir == -1
if newCross
    lastSeenCrossId := srcCrossId

// ── Completion-trigger stream ──
var int lastSeenTrigId = 0
newTrig = srcTrigId > lastSeenTrigId
if newTrig
    lastSeenTrigId := srcTrigId

detectedPrice = srcCrossPrice
detectedTime  = srcCrossTime

// ── Store anchors (chronological) ──
var float[] allPrices = array.new<float>()
var int[]   allTimes  = array.new<int>()
var int[]   allDirs   = array.new<int>()

// ── Store completion triggers ──
var int[] trigTimes = array.new<int>()
var int[] trigDirs  = array.new<int>()

var float lastBullPrice = na
var int   lastBullTime  = na
var float lastBearPrice = na
var int   lastBearTime  = na

if crossUp
    array.push(allPrices, detectedPrice)
    array.push(allTimes,  detectedTime)
    array.push(allDirs,   1)
    lastBullPrice := detectedPrice
    lastBullTime  := detectedTime

if crossDown
    array.push(allPrices, detectedPrice)
    array.push(allTimes,  detectedTime)
    array.push(allDirs,   -1)
    lastBearPrice := detectedPrice
    lastBearTime  := detectedTime

if newTrig
    array.push(trigTimes, srcTrigTime)
    array.push(trigDirs,  srcTrigDir)

// ── Cross (anchor) signal labels ──
var label lastUpLbl = na
var label lastDnLbl = na

if showCross and crossUp
    if labelMode != "All"
        label.delete(lastUpLbl)
    if labelMode == "Current only"
        label.delete(lastDnLbl)
    lastUpLbl := label.new(detectedTime, detectedPrice, str.tostring(detectedPrice, format.mintick),
         xloc=xloc.bar_time, color=#008000, textcolor=color.black, style=label.style_label_up, size=size.normal)

if showCross and crossDown
    if labelMode != "All"
        label.delete(lastDnLbl)
    if labelMode == "Current only"
        label.delete(lastUpLbl)
    lastDnLbl := label.new(detectedTime, detectedPrice, str.tostring(detectedPrice, format.mintick),
         xloc=xloc.bar_time, color=#ff0000, textcolor=color.black, style=label.style_label_down, size=size.normal)

// ════════════ ZONE SETUP ════════════
actLabel = "BTC"
var upNames = array.from("Optimism","Belief","Thrill","Euphoria","Maximum Risk")
var dnNames = array.from("Anxiety","Denial","Panic","Capitulation","Maximum Opportunity")

upCols = array.from(uc1,uc2,uc3,uc4,uc5)
dnCols = array.from(dc1,dc2,dc3,dc4,dc5)
actU   = array.from(u1,u2,u3,u4,u5)
actD   = array.from(d1,d2,d3,d4,d5)

var line[]  L = array.new<line>()
var label[] T = array.new<label>()

// End of a set = first opposite-direction 1-bar trigger after its anchor.
// If none, the set is live and projects to expiry (min 1-day safeguard).
f_endInfo(int aTime, int aDir) =>
    int  endT = math.max(expiryTime, aTime + 86400000)
    bool live = true
    int  n = array.size(trigTimes)
    if n > 0
        for i = 0 to n - 1
            if array.get(trigDirs, i) == -aDir and array.get(trigTimes, i) > aTime
                endT := array.get(trigTimes, i)
                live := false
                break
    [endT, live]

// Draw one zone set from anchor to its computed end time.
f_drawZones(float aPrice, int aTime, int aDir, int x2, bool live) =>
    isBull = aDir == 1
    devs   = isBull ? actU : actD
    cols   = isBull ? upCols : dnCols
    names  = isBull ? upNames : dnNames
    vis    = isBull ? array.from(vU1,vU2,vU3,vU4,vU5) : array.from(vD1,vD2,vD3,vD4,vD5)
    sgn    = isBull ? "+" : "-"

    x1 = aTime
    float hi = aPrice
    float lo = aPrice

    anchorCol = showAnchor ? color.new(color.gray, 0) : color.new(color.gray, 100)
    line lnAnchor = line.new(x1, aPrice, x2, aPrice, xloc=xloc.bar_time, color=anchorCol, style=line.style_dotted, width=1)
    array.push(L, lnAnchor)
    if showAnchor and showLabels
        array.push(T, label.new(x2, aPrice,
             actLabel + " · " + (isBull ? "↑ Bull cross" : "↓ Bear cross") + "  " + str.tostring(aPrice, format.mintick),
             xloc=xloc.bar_time, style=label.style_label_left,
             color=color.new(color.gray,80), textcolor=color.gray, size=size.small))

    // ── Cycle-duration label on the anchor line ──
    // Live: elapsed anchor→now, centred over the elapsed span, tagged "· live".
    // Complete: realised anchor→completion, centred over the full span.
    if showDuration
        int  durEnd  = live ? time : x2
        int  durDays = int(math.round((durEnd - x1) / 86400000.0))
        int  midT    = x1 + int((durEnd - x1) / 2)
        durTxt = (isBull ? "▲ " : "▼ ") + str.tostring(durDays) + "d" + (live ? " · live" : "")
        array.push(T, label.new(midT, aPrice, durTxt, xloc=xloc.bar_time,
             style=label.style_label_center, color=color.new(#1a1a2e, 15),
             textcolor=live ? color.silver : color.white, size=size.small))

    line prevLine = lnAnchor
    for i = 0 to 4
        if array.get(vis, i)
            dev = array.get(devs, i)
            col = array.get(cols, i)
            nm  = array.get(names, i)
            lvl = isBull ? aPrice * (1 + dev/100) : aPrice * (1 - dev/100)
            if lvl > 0
                hi := math.max(hi, lvl)
                lo := math.min(lo, lvl)
                line ln = line.new(x1, lvl, x2, lvl, xloc=xloc.bar_time, color=col, style=lineStyle, width=lineWidth)
                array.push(L, ln)
                if showFills
                    linefill.new(prevLine, ln, color.new(col, fillTransp))
                prevLine := ln
                if showLabels
                    txt = nm + "  " + sgn + str.tostring(math.round(dev, labelDec)) + "%  " + str.tostring(lvl, format.mintick)
                    array.push(T, label.new(x2, lvl, txt, xloc=xloc.bar_time, style=label.style_label_left, color=color.new(col,85), textcolor=col, size=size.small))

    if showBounds and hi > lo
        array.push(L, line.new(x1, lo, x1, hi, xloc=xloc.bar_time, color=color.new(color.gray,50), style=line.style_dashed, width=1))
        array.push(L, line.new(x2, lo, x2, hi, xloc=xloc.bar_time, color=color.new(color.gray,50), style=line.style_dashed, width=1))

if barstate.islast
    for ln in L
        line.delete(ln)
    array.clear(L)
    for lb in T
        label.delete(lb)
    array.clear(T)

    int sz = array.size(allPrices)

    if sz == 0
        array.push(T, label.new(bar_index, close,
             "No confirmed cross yet — waiting for " + str.tostring(confirmBars) + " consecutive " + srcTF + " bars",
             style=label.style_label_down, color=color.new(color.red,0), textcolor=color.white, size=size.normal))
    else
        if labelMode == "Current only"
            int   aT = array.get(allTimes, sz-1)
            int   aD = array.get(allDirs,  sz-1)
            [eT, live] = f_endInfo(aT, aD)
            f_drawZones(array.get(allPrices, sz-1), aT, aD, eT, live)

        else if labelMode == "Last up + last down"
            if not na(lastBullPrice)
                [eTb, liveB] = f_endInfo(lastBullTime, 1)
                f_drawZones(lastBullPrice, lastBullTime, 1, eTb, liveB)
            if not na(lastBearPrice)
                [eTr, liveR] = f_endInfo(lastBearTime, -1)
                f_drawZones(lastBearPrice, lastBearTime, -1, eTr, liveR)

        else  // All
            for i = 0 to sz - 1
                int aT = array.get(allTimes, i)
                int aD = array.get(allDirs,  i)
                [eT, live] = f_endInfo(aT, aD)
                f_drawZones(array.get(allPrices, i), aT, aD, eT, live)

        // ── Cycle-map table (most recent anchor) ──
        if tablePos != "None"
            float anchorPrice = array.get(allPrices, sz-1)
            int   anchorDir   = array.get(allDirs,   sz-1)
            bool  isBull      = anchorDir == 1
            float devNow      = (close - anchorPrice) / anchorPrice * 100.0
            string posName    = ""
            color  posCol     = color.gray

            if isBull
                int reached = -1
                for i = 0 to 4
                    if devNow >= array.get(actU, i)
                        reached := i
                if reached >= 0
                    posName := array.get(upNames, reached)
                    posCol  := array.get(upCols,  reached)
                else
                    posName := devNow >= 0 ? "Below Optimism" : "Below cross"
            else
                float dd = -devNow
                int reached = -1
                for i = 0 to 4
                    if dd >= array.get(actD, i)
                        reached := i
                if reached >= 0
                    posName := array.get(dnNames, reached)
                    posCol  := array.get(dnCols,  reached)
                else
                    posName := dd >= 0 ? "Above Anxiety" : "Above cross"

            tpos = tablePos=="Top Right" ? position.top_right : tablePos=="Bottom Left" ? position.bottom_left : tablePos=="Bottom Right" ? position.bottom_right : position.top_left
            var table tb = table.new(tpos, 2, 5, bgcolor=color.new(#0d0d1a,10), border_width=1, border_color=color.new(color.gray,55), frame_width=1, frame_color=color.new(color.gray,35))
            cHdr = color.new(#e6e64c, 0)
            cLbl = color.new(color.silver, 10)
            cVal = color.white
            table.cell(tb, 0, 0, "ZIZO · Cycle Map",           bgcolor=color.new(#0d0d1a,5), text_color=cHdr, text_size=size.small)
            table.cell(tb, 1, 0, isBull ? "Bull ▲" : "Bear ▼", bgcolor=color.new(#0d0d1a,5), text_color=cHdr, text_size=size.small)
            table.cell(tb, 0, 1, "Anchor",    text_color=cLbl, text_size=size.small)
            table.cell(tb, 1, 1, str.tostring(anchorPrice, format.mintick), text_color=cVal, text_size=size.small)
            table.cell(tb, 0, 2, "Price now", text_color=cLbl, text_size=size.small)
            table.cell(tb, 1, 2, str.tostring(close, format.mintick),       text_color=cVal, text_size=size.small)
            table.cell(tb, 0, 3, "vs anchor", text_color=cLbl, text_size=size.small)
            table.cell(tb, 1, 3, str.format("{0,number,+0.0}", devNow) + "%", text_color=posCol, text_size=size.small)
            table.cell(tb, 0, 4, "Stage",     text_color=cLbl, text_size=size.small)
            table.cell(tb, 1, 4, posName,     text_color=posCol, text_size=size.small)
````
