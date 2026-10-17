# Horizontal Support & Resistance Regions

- url: https://www.tradingview.com/script/WPp9LbME-Horizontal-Support-Resistance-Regions/
- type: indicator
- pine_id: PUB;19e97f8576cf4c0ab787b726abfe9ff9
- version: 7.0

## Description

[b]Horizontal Support & Resistance Regions[/b]
by Jestin V James

Built for breakout traders. This indicator automatically detects horizontal support and resistance zones from swing pivots, tracks how many times each zone has been tested, and measures the depth of every pullback before a test. Together these signals reveal whether a zone is holding firm or progressively weakening — giving you an edge in timing breakout entries before the move happens.


── [i]HOW IT WORKS [/i]──────────────────────────────────────────

Each zone is anchored to a swing pivot detected using the same algorithm as the Swing High/Low Dots indicator:

• Resistance zone — formed at a swing high. The zone spans from the candle body top up to the wick high (the supply area).
• Support zone — formed at a swing low. The zone spans from the wick low up to the candle body bottom (the demand area).

A zone is only displayed once price has exited it and re-tested it at least twice. This filters out noise and ensures only confirmed, battle-tested levels are shown on your chart.


── [i]PULLBACK DEPTH TRACKING[/i] ───────────────────────────────

For every test, the indicator records the pullback depth — how far price retreated from the zone before returning to test it again:

• Resistance depth = zone bottom − minimum low during the pullback
• Support depth = maximum high during the pullback − zone top

Depths are shown as a comma-separated list on the zone label, e.g. "3 tests | Depth: 32, 18, 9". A live depth is also shown while price is currently pulling back, so you can watch it develop in real time.

Why does this matter?
When pullbacks get shallower with each successive test, buyers (or sellers) are returning to the zone more eagerly — they are no longer waiting for a deep discount. This is a classic pre-breakout signature. The zone is being absorbed, and a break is becoming more likely.


── [i]WEAKENING SIGNALS[/i] ─────────────────────────────────────

Two warning badges appear on the zone label when weakness is detected:

◈ "Depths decreasing — zone weakening"
  Every successive pullback has been strictly shallower than the one before it. This is the strongest signal that the zone is losing its power and a breakout may be imminent.

◈ "Latest test depth has been weaker"
  The most recent pullback was shallower than the deepest prior pullback for that zone. A softer signal — worth watching but not yet a full pattern.

Both badges are automatically suppressed when the current pullback already exceeds the last recorded depth, so you will not see false warnings when price shows renewed momentum away from the zone.


── [i]ALERT[/i] ──────────────────────────────────────────────────

A built-in alert "Zone Depths Decreasing" fires on every bar that the strongest weakening badge is visible. Set it to Once Per Bar Close to receive one notification per closed candle while the condition holds. You will be alerted in real time when a zone is entering breakout territory, without needing to watch the chart.


── [i]SETTINGS[/i] ───────────────────────────────────────────────

Lookback / Lookahead Bars
  Swing detection sensitivity. Match this to your Swing High/Low Dots setting.

Zone Lookback (bars)
  Zones older than this are automatically removed to keep the chart clean. Default: 100.

Show Zones
  Filter to Resistance only, Support only, or Both.

Resistance / Support Color
  Independent color pickers for each zone type.

Background Transparency
  Controls zone fill opacity.

Border Style / Width
  Solid, Dashed, or Dotted border with adjustable thickness.


── [i]TIPS FOR BREAKOUT TRADERS[/i] ─────────────────────────────

• Look for zones with 3 or more tests and a depth list like "40, 25, 12" — a classic exhaustion pattern.
• The "Depths decreasing" badge combined with a tight consolidation near the zone is a high-probability breakout setup.
• Use the alert to get notified early and set your entry orders before the break.
• Combine with volume or momentum indicators to confirm the breakout direction.


── [i]NOTE[/i] ───────────────────────────────────────────────────

Swing detection logic is identical to the companion Swing High/Low Dots indicator (available in the scripts section of my profile). Using both together gives you dots that mark the pivots and regions that show you the zones.

## Source Code

````pine
//@version=6
indicator("Horizontal Support & Resistance Regions", overlay=true, max_boxes_count=100, max_labels_count=200)

// ─── Inputs ───────────────────────────────────────────────────────────────────
i_n        = input.int(2,   "Lookback / Lookahead Bars", minval=1, maxval=20,
               group="Swing Detection",
               tooltip="Bars on each side of the pivot for swing detection. Same as Swing High/Low Dots.")
i_lookback = input.int(100, "Zone Lookback (bars)",      minval=10,
               group="Swing Detection",
               tooltip="Zones whose pivot is older than this many bars are automatically removed.")

i_show     = input.string("Both", "Show Zones", group="Zone Appearance", options=["Both","Resistance Only","Support Only"])
i_rColor   = input.color(color.new(color.red,   70), "Resistance Color", group="Zone Appearance")
i_sColor   = input.color(color.new(color.green, 70), "Support Color",    group="Zone Appearance")
i_bgTrans  = input.int(85, "Background Transparency",   minval=0, maxval=100, group="Zone Appearance")
i_bdrStyle = input.string("Dotted", "Border Style",     group="Zone Appearance", options=["Solid","Dashed","Dotted"])
i_bdrWidth   = input.int(1, "Border Width",              group="Zone Appearance", minval=1, maxval=4)
i_maxResist  = input.int(2, "Max Resistance Zones",      group="Zone Appearance", minval=1, maxval=10,
                 tooltip="Maximum number of resistance zones shown. Shows the most recent ones.")
i_maxSupport = input.int(2, "Max Support Zones",         group="Zone Appearance", minval=1, maxval=10,
                 tooltip="Maximum number of support zones shown. Shows the most recent ones.")

// ─── Derived  ──────────────────────────────────────────────────────────────────
bStyle = i_bdrStyle == "Solid" ? line.style_solid : i_bdrStyle == "Dashed" ? line.style_dashed : line.style_dotted

// ─── Swing Detection (identical logic to Swing High/Low Dots) ─────────────────
_swHigh   = ta.highest(high, i_n) < high[i_n]   and ta.highest(high, i_n)[i_n + 1] < high[i_n]
_swLow    = ta.lowest(low,   i_n) > low[i_n]    and ta.lowest(low,   i_n)[i_n + 1] > low[i_n]
_eqHigh   = high[i_n + 1] == high[i_n] and ta.highest(high, i_n) < high[i_n]  and ta.highest(high, i_n)[i_n + 2] < high[i_n]
_eqLow    = low[i_n + 1]  == low[i_n]  and ta.lowest(low,   i_n) > low[i_n]   and ta.lowest(low,   i_n)[i_n + 2] > low[i_n]
isMarkHigh = _swHigh or _eqHigh
isMarkLow  = _swLow  or _eqLow

// ─── Zone State Arrays ────────────────────────────────────────────────────────
// Depth semantics — depth(test N) = pullback depth BEFORE test N starts:
//   Resistance: bot − min(low)  from previous-test-end (or initial exit) → test-N entry
//   Support:    max(high) − top from previous-test-end (or initial exit) → test-N entry
//
// maxPrev  : max of all completed depths BEFORE the most recent one
// lastDep  : most recent completed depth
// isWeak   : lastDep < maxPrev  (latest pullback shallower than any prior)
// allDecr  : every depth is strictly less than the one before it (needs 2+ depths)
var array<float>  zA_top      = array.new_float()
var array<float>  zA_bot      = array.new_float()
var array<int>    zA_origin   = array.new_int()
var array<int>    zA_type     = array.new_int()
var array<int>    zA_state    = array.new_int()
var array<int>    zA_tests    = array.new_int()
var array<bool>   zA_inTest   = array.new_bool()
var array<float>  zA_curTrack = array.new_float()
var array<string> zA_depthLog = array.new_string()
var array<float>  zA_lastDep  = array.new_float()
var array<float>  zA_maxPrev  = array.new_float()
var array<bool>   zA_isWeak   = array.new_bool()
var array<bool>   zA_allDecr  = array.new_bool()
var array<box>    zA_box      = array.new<box>()
var array<label>  zA_lbl      = array.new<label>()
var array<label>  zA_wkLbl    = array.new<label>()

MAX_ZONES = 50

// ─── Helpers ──────────────────────────────────────────────────────────────────
INVIS = color.new(color.white, 100)

makeInvisBox() =>
    box.new(bar_index, close, bar_index + 1, close, border_color=INVIS, bgcolor=INVIS)

makeInvisLabel() =>
    label.new(bar_index, close, "", color=INVIS, textcolor=INVIS)

appendDepth(log, d) =>
    ds = str.tostring(d, "#.##")
    log == "" ? ds : log + ", " + ds

buildDepthStr(dlog, tracker, bot, top, ztp, inT) =>
    if not inT
        live = str.tostring(ztp == 1 ? bot - tracker : tracker - top, "#.##")
        dlog == "" ? live : dlog + ", " + live
    else
        dlog

// Update maxPrev/lastDep when a new completed depth arrives.
// Returns [new_maxPrev, new_lastDep, isWeakening].
trackDepth(prevMaxPrev, prevLastDep, newDep) =>
    newMaxPrev = math.max(prevMaxPrev, prevLastDep)
    isWeak     = newDep > 0.0 and newMaxPrev > 0.0 and newDep < newMaxPrev
    [newMaxPrev, newDep, isWeak]

// Compute the new allDecr flag when a new depth arrives.
// depCount = number of completed depths BEFORE this new one.
// Rule: allDecr is true only when every consecutive pair is strictly decreasing.
//   depCount==0 → first depth, no comparison yet → false
//   depCount==1 → second depth, first real comparison, ignore prev flag
//   depCount>=2 → AND previous flag with new comparison
calcAllDecr(prevAllDecr, prevLastDep, newDep, depCount) =>
    depCount == 0 ? false :
     depCount == 1 ? newDep < prevLastDep :
     prevAllDecr and newDep < prevLastDep

// Show "Depths decreasing" when all depths are strictly descending,
// "latest test depth has been weaker" when only the last one is weaker,
// or hide otherwise.
// Badge is also suppressed when live pullback depth already exceeds maxPrev
// (avoids false warning when the current pullback is already deeper than all prior).
updateWkLbl(wkLb, isWeak, allDecr, yPos) =>
    txt = allDecr ? "Depths decreasing - zone weakening" :
          isWeak  ? "latest test depth has been weaker"  : ""
    if txt != ""
        label.set_xy(wkLb,        bar_index + 1, yPos)
        label.set_text(wkLb,      txt)
        label.set_color(wkLb,     color.yellow)
        label.set_textcolor(wkLb, color.red)
        label.set_style(wkLb,     label.style_label_right)
        label.set_size(wkLb,      size.small)
    else
        label.set_text(wkLb,      "")
        label.set_color(wkLb,     INVIS)
        label.set_textcolor(wkLb, INVIS)

// ─── activateBox ─────────────────────────────────────────────────────────────
activateBox(bx, lb, origin, top, bot, ztp, tst, dlog, tracker, inT) =>
    zc = ztp == 1 ? i_rColor : i_sColor
    box.set_left(bx,         origin)
    box.set_right(bx,        bar_index)
    box.set_top(bx,          top)
    box.set_bottom(bx,       bot)
    box.set_border_color(bx, zc)
    box.set_border_style(bx, bStyle)
    box.set_border_width(bx, i_bdrWidth)
    box.set_bgcolor(bx,      color.new(zc, i_bgTrans))
    typeStr = ztp == 1 ? "Resistance" : "Support"
    dd      = buildDepthStr(dlog, tracker, bot, top, ztp, inT)
    label.set_xy(lb,         bar_index + 1, (top + bot) / 2.0)
    label.set_text(lb,       typeStr + " Region - " + str.tostring(tst) + " tests | Depth: " + dd)
    label.set_color(lb,      color.new(zc, 70))
    label.set_textcolor(lb,  zc)
    label.set_style(lb,      label.style_label_right)
    label.set_size(lb,       size.small)

// ─── addZone ─────────────────────────────────────────────────────────────────
addZone(top, bot, pivotBar, ztp) =>
    barsBack = bar_index - pivotBar
    st       = 0
    tst      = 0
    inT      = false
    tracker  = 0.0
    dlog     = ""
    lastDep  = 0.0
    maxPrev  = 0.0
    isWeak   = false
    allDecr  = false

    for k = barsBack - 1 to 0
        h = high[k]
        l = low[k]

        if ztp == 1  // ── Resistance ──────────────────────────────────────────
            if st == 0
                if l > top
                    st := -1
                    break
                if h < bot
                    st      := 1
                    tracker := l

            else if st == 1
                tracker := math.min(tracker, l)
                if h >= bot
                    d        = bot - tracker
                    allDecr := calcAllDecr(allDecr, lastDep, d, tst)
                    [mp, ld, iw] = trackDepth(maxPrev, lastDep, d)
                    maxPrev := mp
                    lastDep := ld
                    isWeak  := iw
                    dlog    := appendDepth(dlog, d)
                    tst     += 1
                    st      := 2
                    inT     := true

            else if st == 2
                if l > top
                    st := -1
                    break
                if h < bot
                    st      := 3
                    inT     := false
                    tracker := l

            else if st == 3
                tracker := math.min(tracker, l)
                if h >= bot
                    d        = bot - tracker
                    allDecr := calcAllDecr(allDecr, lastDep, d, tst)
                    [mp, ld, iw] = trackDepth(maxPrev, lastDep, d)
                    maxPrev := mp
                    lastDep := ld
                    isWeak  := iw
                    dlog    := appendDepth(dlog, d)
                    tst     += 1
                    st      := 4
                    inT     := true

            else  // st == 4
                if l > top
                    st := -1
                    break
                if inT and h < bot
                    inT     := false
                    tracker := l
                if not inT
                    tracker := math.min(tracker, l)
                    if h >= bot
                        d        = bot - tracker
                        allDecr := calcAllDecr(allDecr, lastDep, d, tst)
                        [mp, ld, iw] = trackDepth(maxPrev, lastDep, d)
                        maxPrev := mp
                        lastDep := ld
                        isWeak  := iw
                        dlog    := appendDepth(dlog, d)
                        tst     += 1
                        inT     := true

        else  // ── Support ─────────────────────────────────────────────────────
            if st == 0
                if h < bot
                    st := -1
                    break
                if l > top
                    st      := 1
                    tracker := h

            else if st == 1
                tracker := math.max(tracker, h)
                if l <= top
                    d        = tracker - top
                    allDecr := calcAllDecr(allDecr, lastDep, d, tst)
                    [mp, ld, iw] = trackDepth(maxPrev, lastDep, d)
                    maxPrev := mp
                    lastDep := ld
                    isWeak  := iw
                    dlog    := appendDepth(dlog, d)
                    tst     += 1
                    st      := 2
                    inT     := true

            else if st == 2
                if h < bot
                    st := -1
                    break
                if l > top
                    st      := 3
                    inT     := false
                    tracker := h

            else if st == 3
                tracker := math.max(tracker, h)
                if l <= top
                    d        = tracker - top
                    allDecr := calcAllDecr(allDecr, lastDep, d, tst)
                    [mp, ld, iw] = trackDepth(maxPrev, lastDep, d)
                    maxPrev := mp
                    lastDep := ld
                    isWeak  := iw
                    dlog    := appendDepth(dlog, d)
                    tst     += 1
                    st      := 4
                    inT     := true

            else  // st == 4
                if h < bot
                    st := -1
                    break
                if inT and l > top
                    inT     := false
                    tracker := h
                if not inT
                    tracker := math.max(tracker, h)
                    if l <= top
                        d        = tracker - top
                        allDecr := calcAllDecr(allDecr, lastDep, d, tst)
                        [mp, ld, iw] = trackDepth(maxPrev, lastDep, d)
                        maxPrev := mp
                        lastDep := ld
                        isWeak  := iw
                        dlog    := appendDepth(dlog, d)
                        tst     += 1
                        inT     := true

    if st >= 0
        newBox  = makeInvisBox()
        newLbl  = makeInvisLabel()
        newWkLb = makeInvisLabel()
        yPos    = ztp == 1 ? bot : top
        if st == 4
            activateBox(newBox, newLbl, pivotBar, top, bot, ztp, tst, dlog, tracker, inT)
            updateWkLbl(newWkLb, isWeak, allDecr, yPos)
        array.push(zA_top,      top)
        array.push(zA_bot,      bot)
        array.push(zA_origin,   pivotBar)
        array.push(zA_type,     ztp)
        array.push(zA_state,    st)
        array.push(zA_tests,    tst)
        array.push(zA_inTest,   inT)
        array.push(zA_curTrack, tracker)
        array.push(zA_depthLog, dlog)
        array.push(zA_lastDep,  lastDep)
        array.push(zA_maxPrev,  maxPrev)
        array.push(zA_isWeak,   isWeak)
        array.push(zA_allDecr,  allDecr)
        array.push(zA_box,      newBox)
        array.push(zA_lbl,      newLbl)
        array.push(zA_wkLbl,    newWkLb)
        while array.size(zA_top) > MAX_ZONES
            array.shift(zA_top)
            array.shift(zA_bot)
            array.shift(zA_origin)
            array.shift(zA_type)
            array.shift(zA_state)
            array.shift(zA_tests)
            array.shift(zA_inTest)
            array.shift(zA_curTrack)
            array.shift(zA_depthLog)
            array.shift(zA_lastDep)
            array.shift(zA_maxPrev)
            array.shift(zA_isWeak)
            array.shift(zA_allDecr)
            box.delete(array.shift(zA_box))
            label.delete(array.shift(zA_lbl))
            label.delete(array.shift(zA_wkLbl))

// ─── Register new pivots ──────────────────────────────────────────────────────
showResist  = i_show != "Support Only"
showSupport = i_show != "Resistance Only"

if isMarkHigh and showResist
    zT = high[i_n]
    zB = math.max(open[i_n], close[i_n])
    if zT > zB
        addZone(zT, zB, bar_index - i_n, 1)

if isMarkLow and showSupport
    zB = low[i_n]
    zT = math.min(open[i_n], close[i_n])
    if zT > zB
        addZone(zT, zB, bar_index - i_n, -1)

// ─── Per-bar update loop ──────────────────────────────────────────────────────
anyDecr = false   // set true this bar if any zone displays "Depths decreasing"
anyWeak = false   // set true this bar if any zone's latest depth is weaker than a prior one
idx = 0
while idx < array.size(zA_top)
    top     = array.get(zA_top,     idx)
    bot     = array.get(zA_bot,     idx)
    ztp     = array.get(zA_type,    idx)
    st      = array.get(zA_state,   idx)
    tst     = array.get(zA_tests,   idx)
    inT     = array.get(zA_inTest,  idx)
    origin  = array.get(zA_origin,  idx)
    bx      = array.get(zA_box,     idx)
    lb      = array.get(zA_lbl,     idx)
    wkLb    = array.get(zA_wkLbl,   idx)
    lastDep = array.get(zA_lastDep, idx)
    maxPrev = array.get(zA_maxPrev, idx)

    h = high
    l = low
    c = close

    failed = false

    if bar_index - origin > i_lookback
        failed := true

    if not failed
        if ztp == 1  // ── Resistance ────────────────────────────────────────
            if st == 0
                if l > top
                    failed := true
                else if h < bot
                    array.set(zA_state,    idx, 1)
                    array.set(zA_curTrack, idx, l)

            else if st == 1
                array.set(zA_curTrack, idx, math.min(array.get(zA_curTrack, idx), l))
                if h >= bot
                    d  = bot - array.get(zA_curTrack, idx)
                    ad = calcAllDecr(array.get(zA_allDecr, idx), lastDep, d, tst)
                    [mp, ld, iw] = trackDepth(maxPrev, lastDep, d)
                    array.set(zA_maxPrev,  idx, mp)
                    array.set(zA_lastDep,  idx, ld)
                    array.set(zA_isWeak,   idx, iw)
                    array.set(zA_allDecr,  idx, ad)
                    array.set(zA_depthLog, idx, appendDepth(array.get(zA_depthLog, idx), d))
                    tst += 1
                    array.set(zA_tests,   idx, tst)
                    array.set(zA_state,   idx, 2)
                    array.set(zA_inTest,  idx, true)

            else if st == 2
                if l > top
                    failed := true
                else if h < bot
                    array.set(zA_state,    idx, 3)
                    array.set(zA_inTest,   idx, false)
                    array.set(zA_curTrack, idx, l)

            else if st == 3
                array.set(zA_curTrack, idx, math.min(array.get(zA_curTrack, idx), l))
                if h >= bot
                    d  = bot - array.get(zA_curTrack, idx)
                    ad = calcAllDecr(array.get(zA_allDecr, idx), lastDep, d, tst)
                    [mp, ld, iw] = trackDepth(maxPrev, lastDep, d)
                    array.set(zA_maxPrev,  idx, mp)
                    array.set(zA_lastDep,  idx, ld)
                    array.set(zA_isWeak,   idx, iw)
                    array.set(zA_allDecr,  idx, ad)
                    dlog = appendDepth(array.get(zA_depthLog, idx), d)
                    array.set(zA_depthLog, idx, dlog)
                    tst += 1
                    array.set(zA_tests,   idx, tst)
                    array.set(zA_state,   idx, 4)
                    array.set(zA_inTest,  idx, true)
                    activateBox(bx, lb, origin, top, bot, 1, tst, dlog,
                         array.get(zA_curTrack, idx), true)
                    updateWkLbl(wkLb, iw, ad, bot)

            else  // st == 4
                if l > top
                    failed := true
                else
                    if inT and h < bot
                        array.set(zA_inTest,   idx, false)
                        array.set(zA_curTrack, idx, l)
                    curInT = array.get(zA_inTest, idx)
                    if not curInT
                        array.set(zA_curTrack, idx, math.min(array.get(zA_curTrack, idx), l))
                        if h >= bot
                            d  = bot - array.get(zA_curTrack, idx)
                            ad = calcAllDecr(array.get(zA_allDecr, idx),
                                             array.get(zA_lastDep,  idx), d, tst)
                            [mp, ld, iw] = trackDepth(array.get(zA_maxPrev, idx),
                                                       array.get(zA_lastDep, idx), d)
                            array.set(zA_maxPrev,  idx, mp)
                            array.set(zA_lastDep,  idx, ld)
                            array.set(zA_isWeak,   idx, iw)
                            array.set(zA_allDecr,  idx, ad)
                            array.set(zA_depthLog, idx, appendDepth(array.get(zA_depthLog, idx), d))
                            tst += 1
                            array.set(zA_tests,   idx, tst)
                            array.set(zA_inTest,  idx, true)
                    curTests  = array.get(zA_tests,   idx)
                    curInTest = array.get(zA_inTest,  idx)
                    dd = buildDepthStr(array.get(zA_depthLog, idx),
                                       array.get(zA_curTrack, idx), bot, top, 1, curInTest)
                    newerActive = 0
                    for j = 0 to array.size(zA_top) - 1
                        if j != idx and array.get(zA_state, j) == 4 and array.get(zA_type, j) == 1 and array.get(zA_origin, j) > origin
                            newerActive += 1
                    zVisible = newerActive < i_maxResist
                    zc = i_rColor
                    box.set_right(bx,  bar_index)
                    box.set_bgcolor(bx, zVisible ? color.new(zc, i_bgTrans) : INVIS)
                    box.set_border_color(bx, zVisible ? zc : INVIS)
                    label.set_xy(lb,   bar_index + 1, (top + bot) / 2.0)
                    label.set_text(lb, zVisible ? "Resistance Region - " + str.tostring(curTests) + " tests | Depth: " + dd : "")
                    label.set_color(lb, zVisible ? color.new(zc, 70) : INVIS)
                    label.set_textcolor(lb, zVisible ? zc : INVIS)
                    wkShow   = array.get(zA_isWeak,  idx)
                    wkAllDec = array.get(zA_allDecr, idx)
                    if (wkShow or wkAllDec) and not curInTest
                        curLastDep = array.get(zA_lastDep, idx)
                        liveD      = bot - array.get(zA_curTrack, idx)
                        if curLastDep > 0.0 and liveD >= curLastDep
                            wkShow   := false
                            wkAllDec := false
                    if zVisible
                        updateWkLbl(wkLb, wkShow, wkAllDec, bot)
                    else
                        label.set_text(wkLb, "")
                        label.set_color(wkLb, INVIS)
                        label.set_textcolor(wkLb, INVIS)
                    anyDecr := anyDecr or (zVisible and wkAllDec)
                    anyWeak := anyWeak or (zVisible and wkShow)

        else  // ── Support ───────────────────────────────────────────────────
            if st == 0
                if h < bot
                    failed := true
                else if l > top
                    array.set(zA_state,    idx, 1)
                    array.set(zA_curTrack, idx, h)

            else if st == 1
                array.set(zA_curTrack, idx, math.max(array.get(zA_curTrack, idx), h))
                if l <= top
                    d  = array.get(zA_curTrack, idx) - top
                    ad = calcAllDecr(array.get(zA_allDecr, idx), lastDep, d, tst)
                    [mp, ld, iw] = trackDepth(maxPrev, lastDep, d)
                    array.set(zA_maxPrev,  idx, mp)
                    array.set(zA_lastDep,  idx, ld)
                    array.set(zA_isWeak,   idx, iw)
                    array.set(zA_allDecr,  idx, ad)
                    array.set(zA_depthLog, idx, appendDepth(array.get(zA_depthLog, idx), d))
                    tst += 1
                    array.set(zA_tests,   idx, tst)
                    array.set(zA_state,   idx, 2)
                    array.set(zA_inTest,  idx, true)

            else if st == 2
                if h < bot
                    failed := true
                else if l > top
                    array.set(zA_state,    idx, 3)
                    array.set(zA_inTest,   idx, false)
                    array.set(zA_curTrack, idx, h)

            else if st == 3
                array.set(zA_curTrack, idx, math.max(array.get(zA_curTrack, idx), h))
                if l <= top
                    d  = array.get(zA_curTrack, idx) - top
                    ad = calcAllDecr(array.get(zA_allDecr, idx), lastDep, d, tst)
                    [mp, ld, iw] = trackDepth(maxPrev, lastDep, d)
                    array.set(zA_maxPrev,  idx, mp)
                    array.set(zA_lastDep,  idx, ld)
                    array.set(zA_isWeak,   idx, iw)
                    array.set(zA_allDecr,  idx, ad)
                    dlog = appendDepth(array.get(zA_depthLog, idx), d)
                    array.set(zA_depthLog, idx, dlog)
                    tst += 1
                    array.set(zA_tests,   idx, tst)
                    array.set(zA_state,   idx, 4)
                    array.set(zA_inTest,  idx, true)
                    activateBox(bx, lb, origin, top, bot, -1, tst, dlog,
                         array.get(zA_curTrack, idx), true)
                    updateWkLbl(wkLb, iw, ad, top)

            else  // st == 4
                if h < bot
                    failed := true
                else
                    if inT and l > top
                        array.set(zA_inTest,   idx, false)
                        array.set(zA_curTrack, idx, h)
                    curInT = array.get(zA_inTest, idx)
                    if not curInT
                        array.set(zA_curTrack, idx, math.max(array.get(zA_curTrack, idx), h))
                        if l <= top
                            d  = array.get(zA_curTrack, idx) - top
                            ad = calcAllDecr(array.get(zA_allDecr, idx),
                                             array.get(zA_lastDep,  idx), d, tst)
                            [mp, ld, iw] = trackDepth(array.get(zA_maxPrev, idx),
                                                       array.get(zA_lastDep, idx), d)
                            array.set(zA_maxPrev,  idx, mp)
                            array.set(zA_lastDep,  idx, ld)
                            array.set(zA_isWeak,   idx, iw)
                            array.set(zA_allDecr,  idx, ad)
                            array.set(zA_depthLog, idx, appendDepth(array.get(zA_depthLog, idx), d))
                            tst += 1
                            array.set(zA_tests,   idx, tst)
                            array.set(zA_inTest,  idx, true)
                    curTests  = array.get(zA_tests,   idx)
                    curInTest = array.get(zA_inTest,  idx)
                    dd = buildDepthStr(array.get(zA_depthLog, idx),
                                       array.get(zA_curTrack, idx), bot, top, -1, curInTest)
                    newerActive = 0
                    for j = 0 to array.size(zA_top) - 1
                        if j != idx and array.get(zA_state, j) == 4 and array.get(zA_type, j) == -1 and array.get(zA_origin, j) > origin
                            newerActive += 1
                    zVisible = newerActive < i_maxSupport
                    zc = i_sColor
                    box.set_right(bx,  bar_index)
                    box.set_bgcolor(bx, zVisible ? color.new(zc, i_bgTrans) : INVIS)
                    box.set_border_color(bx, zVisible ? zc : INVIS)
                    label.set_xy(lb,   bar_index + 1, (top + bot) / 2.0)
                    label.set_text(lb, zVisible ? "Support Region - " + str.tostring(curTests) + " tests | Depth: " + dd : "")
                    label.set_color(lb, zVisible ? color.new(zc, 70) : INVIS)
                    label.set_textcolor(lb, zVisible ? zc : INVIS)
                    wkShow   = array.get(zA_isWeak,  idx)
                    wkAllDec = array.get(zA_allDecr, idx)
                    if (wkShow or wkAllDec) and not curInTest
                        curLastDep = array.get(zA_lastDep, idx)
                        liveD      = array.get(zA_curTrack, idx) - top
                        if curLastDep > 0.0 and liveD >= curLastDep
                            wkShow   := false
                            wkAllDec := false
                    if zVisible
                        updateWkLbl(wkLb, wkShow, wkAllDec, top)
                    else
                        label.set_text(wkLb, "")
                        label.set_color(wkLb, INVIS)
                        label.set_textcolor(wkLb, INVIS)
                    anyDecr := anyDecr or (zVisible and wkAllDec)
                    anyWeak := anyWeak or (zVisible and wkShow)

    if failed
        box.delete(bx)
        label.delete(lb)
        label.delete(wkLb)
        array.remove(zA_top,      idx)
        array.remove(zA_bot,      idx)
        array.remove(zA_origin,   idx)
        array.remove(zA_type,     idx)
        array.remove(zA_state,    idx)
        array.remove(zA_tests,    idx)
        array.remove(zA_inTest,   idx)
        array.remove(zA_curTrack, idx)
        array.remove(zA_depthLog, idx)
        array.remove(zA_lastDep,  idx)
        array.remove(zA_maxPrev,  idx)
        array.remove(zA_isWeak,   idx)
        array.remove(zA_allDecr,  idx)
        array.remove(zA_box,      idx)
        array.remove(zA_lbl,      idx)
        array.remove(zA_wkLbl,    idx)
        // do NOT increment idx — the next zone has shifted into this slot
    else
        idx += 1

// ─── Alerts ───────────────────────────────────────────────────────────────────
alertcondition(anyDecr,
     title   = "Zone Depths Decreasing",
     message = "A S/R zone is showing consistently decreasing test depths — zone may be weakening.")
alertcondition(anyWeak,
     title   = "Zone Latest Test Depth Weaker",
     message = "A S/R zone's latest test depth is shallower than a previous one — zone may be losing strength.")
alertcondition(anyWeak or anyDecr,
     title   = "Zone Weakening (Any)",
     message = "A S/R zone is showing signs of weakening — latest test depth weaker or all depths consistently decreasing.")
````
