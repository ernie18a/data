# MGI  Key reference

- url: https://www.tradingview.com/script/hMAlF926-MGI-Key-reference/
- type: indicator
- pine_id: PUB;7e86c4f692cc4e6199c74d09470946fb
- version: 1.0

## Description

Plot:
PDH
PDL
dVah
dVaL
Prior weekly and Monthly VA

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0
// © tradesdontlie
//
// MGI — Auction Extremes & Liquidity Pools
// Levels: PDH, PDL, PWH, PWL
//         Prior Day / Week / Month  VAH, VAL, POC  (volume profile)

//@version=6
indicator(title="MGI — Auction Extremes & Liquidity Pools", shorttitle="MGI·AE",
     overlay=true, max_lines_count=40, max_labels_count=40)

// ─────────────────────────────────────────────
//  INPUTS — Previous Day Extremes
// ─────────────────────────────────────────────
grpDay = "Previous Day Levels"
showPDH      = input.bool(true,  "Show PDH",      group=grpDay)
pdh_color    = input.color(color.new(#26c6da, 0), "PDH Color", group=grpDay)
showPDL      = input.bool(true,  "Show PDL",      group=grpDay)
pdl_color    = input.color(color.new(#ef5350, 0), "PDL Color", group=grpDay)

// ─────────────────────────────────────────────
//  INPUTS — Previous Day Volume Profile
// ─────────────────────────────────────────────
grpDayVP = "Previous Day — Value Area"
showPdVAH = input.bool(true,  "Show dVAH", group=grpDayVP)
pdVAH_col = input.color(color.new(#26c6da, 40), "dVAH Color", group=grpDayVP)
showPdVAL = input.bool(true,  "Show dVAL", group=grpDayVP)
pdVAL_col = input.color(color.new(#26c6da, 40), "dVAL Color", group=grpDayVP)
showPdPOC = input.bool(true,  "Show dPOC", group=grpDayVP)
pdPOC_col = input.color(color.new(#ffeb3b, 0),  "dPOC Color", group=grpDayVP)

// ─────────────────────────────────────────────
//  INPUTS — Previous Week Extremes
// ─────────────────────────────────────────────
grpWeek = "Previous Week Levels"
showPWH      = input.bool(true,  "Show PWH",      group=grpWeek)
pwh_color    = input.color(color.new(#66bb6a, 0), "PWH Color", group=grpWeek)
showPWL      = input.bool(true,  "Show PWL",      group=grpWeek)
pwl_color    = input.color(color.new(#ffa726, 0), "PWL Color", group=grpWeek)

// ─────────────────────────────────────────────
//  INPUTS — Previous Week Volume Profile
// ─────────────────────────────────────────────
grpWeekVP = "Previous Week — Value Area"
showPwVAH = input.bool(true,  "Show wVAH", group=grpWeekVP)
pwVAH_col = input.color(color.new(#66bb6a, 40), "wVAH Color", group=grpWeekVP)
showPwVAL = input.bool(true,  "Show wVAL", group=grpWeekVP)
pwVAL_col = input.color(color.new(#66bb6a, 40), "wVAL Color", group=grpWeekVP)
showPwPOC = input.bool(true,  "Show wPOC", group=grpWeekVP)
pwPOC_col = input.color(color.new(#ffcc02, 0),  "wPOC Color", group=grpWeekVP)

// ─────────────────────────────────────────────
//  INPUTS — Previous Month Volume Profile
// ─────────────────────────────────────────────
grpMonthVP = "Previous Month — Value Area"
showPmVAH = input.bool(true,  "Show mVAH", group=grpMonthVP)
pmVAH_col = input.color(color.new(#ce93d8, 40), "mVAH Color", group=grpMonthVP)
showPmVAL = input.bool(true,  "Show mVAL", group=grpMonthVP)
pmVAL_col = input.color(color.new(#ce93d8, 40), "mVAL Color", group=grpMonthVP)
showPmPOC = input.bool(true,  "Show mPOC", group=grpMonthVP)
pmPOC_col = input.color(color.new(#f48fb1, 0),  "mPOC Color", group=grpMonthVP)

// ─────────────────────────────────────────────
//  INPUTS — Style
// ─────────────────────────────────────────────
grpStyle       = "Style"
lineWidth      = input.int(1,       "Line Width",     minval=1, maxval=4, group=grpStyle)
showPriceLabel = input.bool(true,   "Show Price Label",                   group=grpStyle)
labelSize      = input.string("normal", "Label Size",
     options=["tiny","small","normal","large","huge"],                    group=grpStyle)

// ─────────────────────────────────────────────
//  INPUTS — Value Area
// ─────────────────────────────────────────────
grpVA      = "Value Area Settings"
vaAreaPct  = input.float(70.0, "Value Area %", minval=50.0, maxval=95.0, step=1.0, group=grpVA)
profileBins= input.int(50,     "Profile Bins",  minval=20,  maxval=200,  step=10,  group=grpVA,
     tooltip="Internal price bins used to calculate VAH/VAL/POC. Higher = more precise.")

// ─────────────────────────────────────────────
//  HELPERS
// ─────────────────────────────────────────────
lsz(s) =>
    switch s
        "tiny"  => size.tiny
        "small" => size.small
        "large" => size.large
        "huge"  => size.huge
        =>         size.normal

txt(tag, price) =>
    showPriceLabel ? tag + "  " + str.tostring(math.round_to_mintick(price)) : tag

// ─────────────────────────────────────────────
//  PROFILE CALCULATION
//  Returns [poc, vah, val] from arrays of midpoints and volumes
// ─────────────────────────────────────────────
calcProfile(midArr, volArr, nBins, vaPct) =>
    poc = float(na)
    vah = float(na)
    val = float(na)
    n   = array.size(midArr)
    if n >= 2
        hi  = array.max(midArr)
        lo  = array.min(midArr)
        rng = hi - lo
        if rng > syminfo.mintick
            binSz  = rng / nBins
            binVol = array.new_float(nBins, 0.0)
            // Assign each bar to its bin
            for i = 0 to n - 1
                m   = array.get(midArr, i)
                v   = array.get(volArr,  i)
                bin = math.min(int(math.floor((m - lo) / binSz)), nBins - 1)
                bin := math.max(bin, 0)
                array.set(binVol, bin, array.get(binVol, bin) + v)
            // POC = highest volume bin
            maxV   = array.max(binVol)
            pocBin = array.indexof(binVol, maxV)
            poc   := lo + (pocBin + 0.5) * binSz
            // Expand value area from POC outward until vaPct % of volume is captured
            totalV  = array.sum(binVol)
            targV   = totalV * vaPct / 100.0
            vaV     = maxV
            vahBin  = pocBin
            valBin  = pocBin
            for _ = 0 to nBins - 1
                if vaV >= targV
                    break
                upV = vahBin + 1 < nBins ? array.get(binVol, vahBin + 1) : 0.0
                dnV = valBin - 1 >= 0    ? array.get(binVol, valBin - 1) : 0.0
                if upV == 0.0 and dnV == 0.0
                    break
                if upV >= dnV
                    vahBin += 1
                    vaV    += upV
                else
                    valBin -= 1
                    vaV    += dnV
            vah := lo + (vahBin + 1) * binSz
            val := lo + valBin * binSz
        else
            // Flat session — all levels at midpoint
            mid = (hi + lo) / 2.0
            poc := mid
            vah := mid
            val := mid
    [poc, vah, val]

// ─────────────────────────────────────────────
//  REQUEST SECURITY — period open times & H/L
// ─────────────────────────────────────────────
[dHigh, dLow, dOpenTime] = request.security(syminfo.tickerid, "D",
     [high[1], low[1], time[1]], lookahead=barmerge.lookahead_on)

[wHigh, wLow, wOpenTime] = request.security(syminfo.tickerid, "W",
     [high[1], low[1], time[1]], lookahead=barmerge.lookahead_on)

mOpenTime = request.security(syminfo.tickerid, "M",
     time[1], lookahead=barmerge.lookahead_on)

// ─────────────────────────────────────────────
//  VOLUME TRACKING — bar midpoint & volume per period
//  Populated every bar AFTER period-change checks
// ─────────────────────────────────────────────
var float[] dayMid   = array.new_float(0)
var float[] dayVol   = array.new_float(0)
var float[] weekMid  = array.new_float(0)
var float[] weekVol  = array.new_float(0)
var float[] monthMid = array.new_float(0)
var float[] monthVol = array.new_float(0)

// ─────────────────────────────────────────────
//  SAVED PRIOR PERIOD PROFILE LEVELS
// ─────────────────────────────────────────────
var float pdPOC = na
var float pdVAH = na
var float pdVAL = na
var float pwPOC = na
var float pwVAH = na
var float pwVAL = na
var float pmPOC = na
var float pmVAH = na
var float pmVAL = na

// ─────────────────────────────────────────────
//  LINE & LABEL OBJECTS
// ─────────────────────────────────────────────
// — Day Extremes —
var line  lnPDH = na
var label lbPDH = na
var line  lnPDL = na
var label lbPDL = na
// — Day Value Area —
var line  lnPdVAH = na
var label lbPdVAH = na
var line  lnPdVAL = na
var label lbPdVAL = na
var line  lnPdPOC = na
var label lbPdPOC = na
// — Week Extremes —
var line  lnPWH = na
var label lbPWH = na
var line  lnPWL = na
var label lbPWL = na
// — Week Value Area —
var line  lnPwVAH = na
var label lbPwVAH = na
var line  lnPwVAL = na
var label lbPwVAL = na
var line  lnPwPOC = na
var label lbPwPOC = na
// — Month Value Area —
var line  lnPmVAH = na
var label lbPmVAH = na
var line  lnPmVAL = na
var label lbPmVAL = na
var line  lnPmPOC = na
var label lbPmPOC = na

// ─────────────────────────────────────────────
//  PERIOD CHANGE FLAGS
// ─────────────────────────────────────────────
isNewDay   = timeframe.change("D")
isNewWeek  = timeframe.change("W")
isNewMonth = timeframe.change("M")

// ─────────────────────────────────────────────
//  ON NEW DAY
//  1. Calculate prior day profile from accumulated arrays
//  2. Create new lines anchored to prev day open time
// ─────────────────────────────────────────────
if isNewDay
    // Calculate prior day profile
    [poc_, vah_, val_] = calcProfile(dayMid, dayVol, profileBins, vaAreaPct)
    pdPOC := poc_
    pdVAH := vah_
    pdVAL := val_
    // Clear for new day
    array.clear(dayMid)
    array.clear(dayVol)

    // Day Extremes
    if showPDH
        line.delete(lnPDH),   label.delete(lbPDH)
        lnPDH := line.new(int(dOpenTime), dHigh, time, dHigh,
             xloc=xloc.bar_time, color=pdh_color, width=lineWidth)
        lbPDH := label.new(time, dHigh, txt("PDH", dHigh),
             xloc=xloc.bar_time, color=color.new(pdh_color, 85), textcolor=pdh_color,
             style=label.style_label_lower_left, size=lsz(labelSize))
    if showPDL
        line.delete(lnPDL),   label.delete(lbPDL)
        lnPDL := line.new(int(dOpenTime), dLow, time, dLow,
             xloc=xloc.bar_time, color=pdl_color, width=lineWidth)
        lbPDL := label.new(time, dLow, txt("PDL", dLow),
             xloc=xloc.bar_time, color=color.new(pdl_color, 85), textcolor=pdl_color,
             style=label.style_label_upper_left, size=lsz(labelSize))

    // Day Value Area — only draw if profile was calculated
    if not na(pdVAH)
        if showPdVAH
            line.delete(lnPdVAH), label.delete(lbPdVAH)
            lnPdVAH := line.new(int(dOpenTime), pdVAH, time, pdVAH,
                 xloc=xloc.bar_time, color=pdVAH_col, width=lineWidth,
                 style=line.style_dashed)
            lbPdVAH := label.new(time, pdVAH, txt("dVAH", pdVAH),
                 xloc=xloc.bar_time, color=color.new(pdVAH_col, 85), textcolor=pdVAH_col,
                 style=label.style_label_lower_left, size=lsz(labelSize))
        if showPdVAL
            line.delete(lnPdVAL), label.delete(lbPdVAL)
            lnPdVAL := line.new(int(dOpenTime), pdVAL, time, pdVAL,
                 xloc=xloc.bar_time, color=pdVAL_col, width=lineWidth,
                 style=line.style_dashed)
            lbPdVAL := label.new(time, pdVAL, txt("dVAL", pdVAL),
                 xloc=xloc.bar_time, color=color.new(pdVAL_col, 85), textcolor=pdVAL_col,
                 style=label.style_label_upper_left, size=lsz(labelSize))
        if showPdPOC
            line.delete(lnPdPOC), label.delete(lbPdPOC)
            lnPdPOC := line.new(int(dOpenTime), pdPOC, time, pdPOC,
                 xloc=xloc.bar_time, color=pdPOC_col, width=lineWidth,
                 style=line.style_dotted)
            lbPdPOC := label.new(time, pdPOC, txt("dPOC", pdPOC),
                 xloc=xloc.bar_time, color=color.new(pdPOC_col, 85), textcolor=pdPOC_col,
                 style=label.style_label_lower_left, size=lsz(labelSize))

// ─────────────────────────────────────────────
//  ON NEW WEEK
// ─────────────────────────────────────────────
if isNewWeek
    [poc_, vah_, val_] = calcProfile(weekMid, weekVol, profileBins, vaAreaPct)
    pwPOC := poc_
    pwVAH := vah_
    pwVAL := val_
    array.clear(weekMid)
    array.clear(weekVol)

    // Week Extremes
    if showPWH
        line.delete(lnPWH),   label.delete(lbPWH)
        lnPWH := line.new(int(wOpenTime), wHigh, time, wHigh,
             xloc=xloc.bar_time, color=pwh_color, width=lineWidth)
        lbPWH := label.new(time, wHigh, txt("PWH", wHigh),
             xloc=xloc.bar_time, color=color.new(pwh_color, 85), textcolor=pwh_color,
             style=label.style_label_lower_left, size=lsz(labelSize))
    if showPWL
        line.delete(lnPWL),   label.delete(lbPWL)
        lnPWL := line.new(int(wOpenTime), wLow, time, wLow,
             xloc=xloc.bar_time, color=pwl_color, width=lineWidth)
        lbPWL := label.new(time, wLow, txt("PWL", wLow),
             xloc=xloc.bar_time, color=color.new(pwl_color, 85), textcolor=pwl_color,
             style=label.style_label_upper_left, size=lsz(labelSize))

    // Week Value Area
    if not na(pwVAH)
        if showPwVAH
            line.delete(lnPwVAH), label.delete(lbPwVAH)
            lnPwVAH := line.new(int(wOpenTime), pwVAH, time, pwVAH,
                 xloc=xloc.bar_time, color=pwVAH_col, width=lineWidth,
                 style=line.style_dashed)
            lbPwVAH := label.new(time, pwVAH, txt("wVAH", pwVAH),
                 xloc=xloc.bar_time, color=color.new(pwVAH_col, 85), textcolor=pwVAH_col,
                 style=label.style_label_lower_left, size=lsz(labelSize))
        if showPwVAL
            line.delete(lnPwVAL), label.delete(lbPwVAL)
            lnPwVAL := line.new(int(wOpenTime), pwVAL, time, pwVAL,
                 xloc=xloc.bar_time, color=pwVAH_col, width=lineWidth,
                 style=line.style_dashed)
            lbPwVAL := label.new(time, pwVAL, txt("wVAL", pwVAL),
                 xloc=xloc.bar_time, color=color.new(pwVAL_col, 85), textcolor=pwVAL_col,
                 style=label.style_label_upper_left, size=lsz(labelSize))
        if showPwPOC
            line.delete(lnPwPOC), label.delete(lbPwPOC)
            lnPwPOC := line.new(int(wOpenTime), pwPOC, time, pwPOC,
                 xloc=xloc.bar_time, color=pwPOC_col, width=lineWidth,
                 style=line.style_dotted)
            lbPwPOC := label.new(time, pwPOC, txt("wPOC", pwPOC),
                 xloc=xloc.bar_time, color=color.new(pwPOC_col, 85), textcolor=pwPOC_col,
                 style=label.style_label_lower_left, size=lsz(labelSize))

// ─────────────────────────────────────────────
//  ON NEW MONTH
// ─────────────────────────────────────────────
if isNewMonth
    [poc_, vah_, val_] = calcProfile(monthMid, monthVol, profileBins, vaAreaPct)
    pmPOC := poc_
    pmVAH := vah_
    pmVAL := val_
    array.clear(monthMid)
    array.clear(monthVol)

    // Month Value Area
    if not na(pmVAH)
        if showPmVAH
            line.delete(lnPmVAH), label.delete(lbPmVAH)
            lnPmVAH := line.new(int(mOpenTime), pmVAH, time, pmVAH,
                 xloc=xloc.bar_time, color=pmVAH_col, width=lineWidth,
                 style=line.style_dashed)
            lbPmVAH := label.new(time, pmVAH, txt("mVAH", pmVAH),
                 xloc=xloc.bar_time, color=color.new(pmVAH_col, 85), textcolor=pmVAH_col,
                 style=label.style_label_lower_left, size=lsz(labelSize))
        if showPmVAL
            line.delete(lnPmVAL), label.delete(lbPmVAL)
            lnPmVAL := line.new(int(mOpenTime), pmVAL, time, pmVAL,
                 xloc=xloc.bar_time, color=pmVAL_col, width=lineWidth,
                 style=line.style_dashed)
            lbPmVAL := label.new(time, pmVAL, txt("mVAL", pmVAL),
                 xloc=xloc.bar_time, color=color.new(pmVAL_col, 85), textcolor=pmVAL_col,
                 style=label.style_label_upper_left, size=lsz(labelSize))
        if showPmPOC
            line.delete(lnPmPOC), label.delete(lbPmPOC)
            lnPmPOC := line.new(int(mOpenTime), pmPOC, time, pmPOC,
                 xloc=xloc.bar_time, color=pmPOC_col, width=lineWidth,
                 style=line.style_dotted)
            lbPmPOC := label.new(time, pmPOC, txt("mPOC", pmPOC),
                 xloc=xloc.bar_time, color=color.new(pmPOC_col, 85), textcolor=pmPOC_col,
                 style=label.style_label_lower_left, size=lsz(labelSize))

// ─────────────────────────────────────────────
//  PUSH CURRENT BAR INTO TRACKING ARRAYS
//  Must happen AFTER period-change blocks
// ─────────────────────────────────────────────
barMid = (high + low) / 2.0
array.push(dayMid,   barMid)
array.push(dayVol,   volume)
array.push(weekMid,  barMid)
array.push(weekVol,  volume)
array.push(monthMid, barMid)
array.push(monthVol, volume)

// ─────────────────────────────────────────────
//  EVERY BAR — extend x2 to current bar time
//  x1 (period open) never changes
// ─────────────────────────────────────────────

// Day Extremes
if showPDH and not na(lnPDH)
    line.set_x2(lnPDH, time),  label.set_x(lbPDH, time)
    line.set_color(lnPDH, pdh_color),  line.set_width(lnPDH, lineWidth)
    label.set_text(lbPDH, txt("PDH", dHigh))
    label.set_textcolor(lbPDH, pdh_color),  label.set_color(lbPDH, color.new(pdh_color, 85))
    label.set_size(lbPDH, lsz(labelSize))

if showPDL and not na(lnPDL)
    line.set_x2(lnPDL, time),  label.set_x(lbPDL, time)
    line.set_color(lnPDL, pdl_color),  line.set_width(lnPDL, lineWidth)
    label.set_text(lbPDL, txt("PDL", dLow))
    label.set_textcolor(lbPDL, pdl_color),  label.set_color(lbPDL, color.new(pdl_color, 85))
    label.set_size(lbPDL, lsz(labelSize))

// Day Value Area
if showPdVAH and not na(lnPdVAH)
    line.set_x2(lnPdVAH, time), label.set_x(lbPdVAH, time)
    line.set_color(lnPdVAH, pdVAH_col), line.set_width(lnPdVAH, lineWidth)
    label.set_text(lbPdVAH, txt("dVAH", pdVAH))
    label.set_textcolor(lbPdVAH, pdVAH_col), label.set_color(lbPdVAH, color.new(pdVAH_col, 85))
    label.set_size(lbPdVAH, lsz(labelSize))

if showPdVAL and not na(lnPdVAL)
    line.set_x2(lnPdVAL, time), label.set_x(lbPdVAL, time)
    line.set_color(lnPdVAL, pdVAL_col), line.set_width(lnPdVAL, lineWidth)
    label.set_text(lbPdVAL, txt("dVAL", pdVAL))
    label.set_textcolor(lbPdVAL, pdVAL_col), label.set_color(lbPdVAL, color.new(pdVAL_col, 85))
    label.set_size(lbPdVAL, lsz(labelSize))

if showPdPOC and not na(lnPdPOC)
    line.set_x2(lnPdPOC, time), label.set_x(lbPdPOC, time)
    line.set_color(lnPdPOC, pdPOC_col), line.set_width(lnPdPOC, lineWidth)
    label.set_text(lbPdPOC, txt("dPOC", pdPOC))
    label.set_textcolor(lbPdPOC, pdPOC_col), label.set_color(lbPdPOC, color.new(pdPOC_col, 85))
    label.set_size(lbPdPOC, lsz(labelSize))

// Week Extremes
if showPWH and not na(lnPWH)
    line.set_x2(lnPWH, time),  label.set_x(lbPWH, time)
    line.set_color(lnPWH, pwh_color),  line.set_width(lnPWH, lineWidth)
    label.set_text(lbPWH, txt("PWH", wHigh))
    label.set_textcolor(lbPWH, pwh_color),  label.set_color(lbPWH, color.new(pwh_color, 85))
    label.set_size(lbPWH, lsz(labelSize))

if showPWL and not na(lnPWL)
    line.set_x2(lnPWL, time),  label.set_x(lbPWL, time)
    line.set_color(lnPWL, pwl_color),  line.set_width(lnPWL, lineWidth)
    label.set_text(lbPWL, txt("PWL", wLow))
    label.set_textcolor(lbPWL, pwl_color),  label.set_color(lbPWL, color.new(pwl_color, 85))
    label.set_size(lbPWL, lsz(labelSize))

// Week Value Area
if showPwVAH and not na(lnPwVAH)
    line.set_x2(lnPwVAH, time), label.set_x(lbPwVAH, time)
    line.set_color(lnPwVAH, pwVAH_col), line.set_width(lnPwVAH, lineWidth)
    label.set_text(lbPwVAH, txt("wVAH", pwVAH))
    label.set_textcolor(lbPwVAH, pwVAH_col), label.set_color(lbPwVAH, color.new(pwVAH_col, 85))
    label.set_size(lbPwVAH, lsz(labelSize))

if showPwVAL and not na(lnPwVAL)
    line.set_x2(lnPwVAL, time), label.set_x(lbPwVAL, time)
    line.set_color(lnPwVAL, pwVAL_col), line.set_width(lnPwVAL, lineWidth)
    label.set_text(lbPwVAL, txt("wVAL", pwVAL))
    label.set_textcolor(lbPwVAL, pwVAL_col), label.set_color(lbPwVAL, color.new(pwVAL_col, 85))
    label.set_size(lbPwVAL, lsz(labelSize))

if showPwPOC and not na(lnPwPOC)
    line.set_x2(lnPwPOC, time), label.set_x(lbPwPOC, time)
    line.set_color(lnPwPOC, pwPOC_col), line.set_width(lnPwPOC, lineWidth)
    label.set_text(lbPwPOC, txt("wPOC", pwPOC))
    label.set_textcolor(lbPwPOC, pwPOC_col), label.set_color(lbPwPOC, color.new(pwPOC_col, 85))
    label.set_size(lbPwPOC, lsz(labelSize))

// Month Value Area
if showPmVAH and not na(lnPmVAH)
    line.set_x2(lnPmVAH, time), label.set_x(lbPmVAH, time)
    line.set_color(lnPmVAH, pmVAH_col), line.set_width(lnPmVAH, lineWidth)
    label.set_text(lbPmVAH, txt("mVAH", pmVAH))
    label.set_textcolor(lbPmVAH, pmVAH_col), label.set_color(lbPmVAH, color.new(pmVAH_col, 85))
    label.set_size(lbPmVAH, lsz(labelSize))

if showPmVAL and not na(lnPmVAL)
    line.set_x2(lnPmVAL, time), label.set_x(lbPmVAL, time)
    line.set_color(lnPmVAL, pmVAL_col), line.set_width(lnPmVAL, lineWidth)
    label.set_text(lbPmVAL, txt("mVAL", pmVAL))
    label.set_textcolor(lbPmVAL, pmVAL_col), label.set_color(lbPmVAL, color.new(pmVAL_col, 85))
    label.set_size(lbPmVAL, lsz(labelSize))

if showPmPOC and not na(lnPmPOC)
    line.set_x2(lnPmPOC, time), label.set_x(lbPmPOC, time)
    line.set_color(lnPmPOC, pmPOC_col), line.set_width(lnPmPOC, lineWidth)
    label.set_text(lbPmPOC, txt("mPOC", pmPOC))
    label.set_textcolor(lbPmPOC, pmPOC_col), label.set_color(lbPmPOC, color.new(pmPOC_col, 85))
    label.set_size(lbPmPOC, lsz(labelSize))
````
