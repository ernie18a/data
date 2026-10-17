# NY close past prior extremes

- url: https://www.tradingview.com/script/Q4qLOfOd-NY-close-past-prior-extremes/
- type: indicator
- pine_id: PUB;f109fb6222ff4e11ad91ea0d7451d28c
- version: 1.0

## Description

Extreme Close , Inside Day, Signal Day, this way  users can see what to expect the following trading day as post 16:59 pm close of NY trading day

## Source Code

````pine
//@version=5
// =============================================================================
// NY outside-close: end-of-NY-day-range print vs prior completed range + week/month tags
//
// NY day range: 17:00 → next calendar day 16:59 America/New_York (same as your other NY tools).
//
// Base: On each NY day range end, is the official print above **yesterday’s** range high
// or below **yesterday’s** range low? → triangle.
//
// „Yesterday“ = prior **completed** NY day range 17:00–16:59 (high/low of that range, not calendar Sun).
//
// Extra tags (optional): same print also outside a 5-session week envelope and/or a
// 22-session month envelope → separate shapes (not filters — they don’t hide triangles).
//
// Blue ref plots: prior **completed** NY day range H/L (same levels as the base triangle signal),
// flat intraday — taken from prevSess* before each bar’s finalize rollover so lines match marks.
//
// Engine runs on 1m (or chosen TF) via request.security so this stays correct on any chart TF.
//
// Optional: only finalize sessions and print signals when the session-end bar is a NY-
// timezone weekday (Mon–Fri), so Sat/Sun session closes are ignored for stacking history
// and markers (useful on 24h crypto where weekend sessions still print 16:59 bars).
//
// Session open lines: up to 16 optional session “starts” in Open-line timezone, evaluated
// on the chart timeframe (not inside the 1m request.security engine). Use narrow
// windows (e.g. 1700-1701) to mark opens on any TF. Each slot has its own Mon–Sun toggles;
// optional global “hide weekends” still blocks Sat/Sun for all slots.
// Band colors: slots 1–4 / 5–8 / 9–12 / 13–16 each use one user color; optional per-slot
// tint within the band. Anchor slot (default slot 1) extends farther right for 6h-grid open.
// Inside / double inside (choose in settings): (1) Strict — full high/low vs **prior** completed
// NY day range only; double = two consecutive such days. (2) Legacy — envelope from last outside-close
// “mother”; cumulative count inside mother until next outside arm.
// Opposing day: NY day range after bull/bear outside with bearish/bullish close vs 17:00 open;
// meaningful with 16:59 end-of-range mode.
// =============================================================================
indicator(
     "NY close past prior extremes",
     overlay = true,
     max_labels_count = 500,
     max_lines_count = 500)

TZ = "America/New_York"

grpData = "Session data"
grpSig = "Signals"
grpTag = "Week / month tags"
grpVis = "Display"

engineTf = input.timeframe("1", "Session engine timeframe", group = grpData, tooltip = "Use 1. Coarser TF can skip 16:59 bars on some symbols.")
sessionPriceMode = input.string("16:59 bar close", "Session end price", options = ["16:59 bar close", "17:00 bar open"], group = grpData, tooltip = "16:59 = last bar of the NY day range. 17:00 open = first print of the new range (often matches close; use if 16:59 is missing on your feed). Opposing-day marker is intended for 16:59 mode; it is off under 17:00 open (close equals that bar’s open).")
weekdaysOnly = input.bool(true, "Weekdays only (Mon–Fri NY)", group = grpData, tooltip = "If on, no finalize / signals on Sat or Sun (NY date of the session-end bar). History only advances on weekday closes — Mon compares to prior stored session (often Fri), not skipped weekend sessions.")

bullishOnly = input.bool(true, "Show bullish (end print > prior session high)", group = grpSig)
bearishOnly = input.bool(true, "Show bearish (end print < prior session low)", group = grpSig)

insideEnvelopeMode = input.string("Prior NY day (strict)", "Inside / double envelope", options = ["Prior NY day (strict)", "Outside-close mother (legacy)"], group = grpSig, tooltip = "Strict: each day’s full high/low must lie inside the **prior** completed NY day range (wicks outside disqualify). Double = **two consecutive** such days. Legacy: envelope is the last outside-close range; 2nd inside counts inside that mother without resetting on non-inside days.")

showInsideFollow = input.bool(true, "Marker: 1st inside NY day range", group = grpSig, tooltip = "Strict: first finalized range fully inside prior day’s high/low. Legacy: first inside last outside-close mother after it was armed.")
insideFollowMatchVisible = input.bool(false, "Legacy: mother arms only if triangle visible", group = grpSig, tooltip = "Legacy mode only. If on, refreshing the mother envelope requires the same bullish/bearish-only filters as triangles. Ignored in strict mode.")
showDoubleInside = input.bool(true, "Marker: 2nd inside (strict or legacy)", group = grpSig, tooltip = "Strict: second **consecutive** day with full range inside prior day. Legacy: second finalized range inside same mother before next outside arm; non-enveloped days do not reset count.")
showOppDay = input.bool(true, "Marker: opposing NY day after outside", group = grpSig, tooltip = "After bull outside: next finalize is bearish NY day (close < that day’s 17:00 open). After bear outside: bullish (close > open). For 16:59 end mode; disabled for 17:00 open mode.")
oppMatchVisible = input.bool(false, "Opposing marker only when triangle visible", group = grpSig, tooltip = "If on, arm opposing check only when bull/bear passes display filters.")

showWeekTag = input.bool(true, "Tag when also outside 5-session week range", group = grpTag, tooltip = "Envelope of sessions stored at indices 1..5 right after this close (completed sessions before the one that just closed).")
showMonthTag = input.bool(true, "Tag when also outside 22-session month range", group = grpTag, tooltip = "Envelope of sessions at indices 1..22. Needs enough history.")

showLabel = input.bool(false, "Show text label on base signal", group = grpVis)
bullColorIn = input.color(color.new(color.teal, 0), "Bull marker color", group = grpVis)
bearColorIn = input.color(color.new(color.orange, 0), "Bear marker color", group = grpVis)
weekTagColor = input.color(color.new(color.yellow, 0), "Week tag color", group = grpVis)
monthTagColor = input.color(color.new(color.fuchsia, 0), "Month tag color", group = grpVis)

insideFollowColor = input.color(color.new(color.aqua, 0), "1st inside marker color", group = grpVis)
insideFollowNested = input.bool(true, "1st inside: nested circles", group = grpVis, tooltip = "Nested: large faded ring + small solid circle. Off: single normal circle. One Style row per plot (Pine limitation).")
doubleInsideColor = input.color(color.new(color.lime, 0), "2nd inside marker color", group = grpVis)
oppDayColor = input.color(color.new(color.white, 0), "Opposing day marker color", group = grpVis)

grpOl = "Open lines · global"
grpOl1 = "Open lines · slots 1–4"
grpOl2 = "Open lines · slots 5–8"
grpOl3 = "Open lines · slots 9–12"
grpOl4 = "Open lines · slots 13–16"

showOpenLines = input.bool(true, "Show session open lines", group = grpOl)
lineTz = input.string("America/New_York", "Open-line timezone", group = grpOl, tooltip = "All slot sessions below use this timezone.")
olHideWeekends = input.bool(true, "Hide lines on Sat/Sun (all slots)", group = grpOl, tooltip = "Master switch: no line on Saturday/Sunday in Open-line timezone, regardless of per-slot day checkboxes.")
olBand1Color = input.color(color.new(color.blue, 0), "Band 1 color (slots 1–4)", group = grpOl)
olBand2Color = input.color(color.new(color.teal, 0), "Band 2 color (slots 5–8)", group = grpOl)
olBand3Color = input.color(color.new(color.orange, 0), "Band 3 color (slots 9–12)", group = grpOl)
olBand4Color = input.color(color.new(color.purple, 0), "Band 4 color (slots 13–16)", group = grpOl)
olTintPerSlot = input.bool(true, "Tint per slot within band", group = grpOl, tooltip = "Slight transparency steps so slots in the same band differ slightly.")
olWidth = input.int(2, "Line width", minval = 1, maxval = 5, group = grpOl)
olStyleIn = input.string("Solid", "Line style", options = ["Solid", "Dashed", "Dotted"], group = grpOl)
olExtendNormal = input.int(100, "Extend right (bars)", minval = 1, maxval = 500, group = grpOl)
olAnchorSlot = input.int(1, "Anchor slot number (1–16 = Slot N in settings)", minval = 1, maxval = 16, group = grpOl, tooltip = "Same number as each row’s slot (Slot 1 = 00:00 grid open, Slot 9 = first line of band 3, etc.). Only that slot’s lines get the longer extend; others use “Extend right” only.")
olAnchorExtendMult = input.float(2.0, "Anchor extend multiplier", minval = 1.0, maxval = 5.0, step = 0.5, group = grpOl)
olMaxKeep = input.int(120, "Max lines kept", minval = 16, maxval = 400, group = grpOl, tooltip = "Oldest horizontal lines deleted when over this count.")

olE1 = input.bool(true, "On", inline = "ol1", group = grpOl1)
olS1 = input.session("0000-0001", "Slot 1 · 6h grid", inline = "ol1", group = grpOl1, tooltip = "00:00 (wall clock). One-minute window = open marker on any chart TF.")
ol1Mo = input.bool(true, "M", inline = "s1d", group = grpOl1)
ol1Tu = input.bool(true, "Tu", inline = "s1d", group = grpOl1)
ol1We = input.bool(true, "W", inline = "s1d", group = grpOl1)
ol1Th = input.bool(true, "Th", inline = "s1d", group = grpOl1)
ol1Fr = input.bool(true, "F", inline = "s1d", group = grpOl1)
ol1Sa = input.bool(false, "Sa", inline = "s1d", group = grpOl1)
ol1Su = input.bool(false, "Su", inline = "s1d", group = grpOl1, tooltip = "Per-slot days (open-bar date in Open-line timezone).")
olE2 = input.bool(true, "On", inline = "ol2", group = grpOl1)
olS2 = input.session("0600-0601", "Slot 2", inline = "ol2", group = grpOl1)
ol2Mo = input.bool(true, "M", inline = "s2d", group = grpOl1)
ol2Tu = input.bool(true, "Tu", inline = "s2d", group = grpOl1)
ol2We = input.bool(true, "W", inline = "s2d", group = grpOl1)
ol2Th = input.bool(true, "Th", inline = "s2d", group = grpOl1)
ol2Fr = input.bool(true, "F", inline = "s2d", group = grpOl1)
ol2Sa = input.bool(false, "Sa", inline = "s2d", group = grpOl1)
ol2Su = input.bool(false, "Su", inline = "s2d", group = grpOl1)
olE3 = input.bool(true, "On", inline = "ol3", group = grpOl1)
olS3 = input.session("1200-1201", "Slot 3", inline = "ol3", group = grpOl1)
ol3Mo = input.bool(true, "M", inline = "s3d", group = grpOl1)
ol3Tu = input.bool(true, "Tu", inline = "s3d", group = grpOl1)
ol3We = input.bool(true, "W", inline = "s3d", group = grpOl1)
ol3Th = input.bool(true, "Th", inline = "s3d", group = grpOl1)
ol3Fr = input.bool(true, "F", inline = "s3d", group = grpOl1)
ol3Sa = input.bool(false, "Sa", inline = "s3d", group = grpOl1)
ol3Su = input.bool(false, "Su", inline = "s3d", group = grpOl1)
olE4 = input.bool(true, "On", inline = "ol4", group = grpOl1)
olS4 = input.session("1800-1801", "Slot 4", inline = "ol4", group = grpOl1)
ol4Mo = input.bool(true, "M", inline = "s4d", group = grpOl1)
ol4Tu = input.bool(true, "Tu", inline = "s4d", group = grpOl1)
ol4We = input.bool(true, "W", inline = "s4d", group = grpOl1)
ol4Th = input.bool(true, "Th", inline = "s4d", group = grpOl1)
ol4Fr = input.bool(true, "F", inline = "s4d", group = grpOl1)
ol4Sa = input.bool(false, "Sa", inline = "s4d", group = grpOl1)
ol4Su = input.bool(false, "Su", inline = "s4d", group = grpOl1)

olE5 = input.bool(false, "On", inline = "ol5", group = grpOl2)
olS5 = input.session("1700-1701", "Slot 5 · NY 5pm", inline = "ol5", group = grpOl2, tooltip = "Matches NY 17:00 session roll used in this script’s close model.")
ol5Mo = input.bool(true, "M", inline = "s5d", group = grpOl2)
ol5Tu = input.bool(true, "Tu", inline = "s5d", group = grpOl2)
ol5We = input.bool(true, "W", inline = "s5d", group = grpOl2)
ol5Th = input.bool(true, "Th", inline = "s5d", group = grpOl2)
ol5Fr = input.bool(true, "F", inline = "s5d", group = grpOl2)
ol5Sa = input.bool(false, "Sa", inline = "s5d", group = grpOl2)
ol5Su = input.bool(false, "Su", inline = "s5d", group = grpOl2)
olE6 = input.bool(false, "On", inline = "ol6", group = grpOl2)
olS6 = input.session("2000-2001", "Slot 6 · Asia eve", inline = "ol6", group = grpOl2)
ol6Mo = input.bool(true, "M", inline = "s6d", group = grpOl2)
ol6Tu = input.bool(true, "Tu", inline = "s6d", group = grpOl2)
ol6We = input.bool(true, "W", inline = "s6d", group = grpOl2)
ol6Th = input.bool(true, "Th", inline = "s6d", group = grpOl2)
ol6Fr = input.bool(true, "F", inline = "s6d", group = grpOl2)
ol6Sa = input.bool(false, "Sa", inline = "s6d", group = grpOl2)
ol6Su = input.bool(false, "Su", inline = "s6d", group = grpOl2)
olE7 = input.bool(false, "On", inline = "ol7", group = grpOl2)
olS7 = input.session("0200-0201", "Slot 7 · London", inline = "ol7", group = grpOl2)
ol7Mo = input.bool(true, "M", inline = "s7d", group = grpOl2)
ol7Tu = input.bool(true, "Tu", inline = "s7d", group = grpOl2)
ol7We = input.bool(true, "W", inline = "s7d", group = grpOl2)
ol7Th = input.bool(true, "Th", inline = "s7d", group = grpOl2)
ol7Fr = input.bool(true, "F", inline = "s7d", group = grpOl2)
ol7Sa = input.bool(false, "Sa", inline = "s7d", group = grpOl2)
ol7Su = input.bool(false, "Su", inline = "s7d", group = grpOl2)
olE8 = input.bool(false, "On", inline = "ol8", group = grpOl2)
olS8 = input.session("0930-0931", "Slot 8 · 9:30", inline = "ol8", group = grpOl2)
ol8Mo = input.bool(true, "M", inline = "s8d", group = grpOl2)
ol8Tu = input.bool(true, "Tu", inline = "s8d", group = grpOl2)
ol8We = input.bool(true, "W", inline = "s8d", group = grpOl2)
ol8Th = input.bool(true, "Th", inline = "s8d", group = grpOl2)
ol8Fr = input.bool(true, "F", inline = "s8d", group = grpOl2)
ol8Sa = input.bool(false, "Sa", inline = "s8d", group = grpOl2)
ol8Su = input.bool(false, "Su", inline = "s8d", group = grpOl2)

olE9 = input.bool(false, "On", inline = "ol9", group = grpOl3)
olS9 = input.session("0300-0301", "Slot 9", inline = "ol9", group = grpOl3)
ol9Mo = input.bool(true, "M", inline = "s9d", group = grpOl3)
ol9Tu = input.bool(true, "Tu", inline = "s9d", group = grpOl3)
ol9We = input.bool(true, "W", inline = "s9d", group = grpOl3)
ol9Th = input.bool(true, "Th", inline = "s9d", group = grpOl3)
ol9Fr = input.bool(true, "F", inline = "s9d", group = grpOl3)
ol9Sa = input.bool(false, "Sa", inline = "s9d", group = grpOl3)
ol9Su = input.bool(false, "Su", inline = "s9d", group = grpOl3)
olE10 = input.bool(false, "On", inline = "ol10", group = grpOl3)
olS10 = input.session("0400-0401", "Slot 10", inline = "ol10", group = grpOl3)
ol10Mo = input.bool(true, "M", inline = "s10d", group = grpOl3)
ol10Tu = input.bool(true, "Tu", inline = "s10d", group = grpOl3)
ol10We = input.bool(true, "W", inline = "s10d", group = grpOl3)
ol10Th = input.bool(true, "Th", inline = "s10d", group = grpOl3)
ol10Fr = input.bool(true, "F", inline = "s10d", group = grpOl3)
ol10Sa = input.bool(false, "Sa", inline = "s10d", group = grpOl3)
ol10Su = input.bool(false, "Su", inline = "s10d", group = grpOl3)
olE11 = input.bool(false, "On", inline = "ol11", group = grpOl3)
olS11 = input.session("1000-1001", "Slot 11", inline = "ol11", group = grpOl3)
ol11Mo = input.bool(true, "M", inline = "s11d", group = grpOl3)
ol11Tu = input.bool(true, "Tu", inline = "s11d", group = grpOl3)
ol11We = input.bool(true, "W", inline = "s11d", group = grpOl3)
ol11Th = input.bool(true, "Th", inline = "s11d", group = grpOl3)
ol11Fr = input.bool(true, "F", inline = "s11d", group = grpOl3)
ol11Sa = input.bool(false, "Sa", inline = "s11d", group = grpOl3)
ol11Su = input.bool(false, "Su", inline = "s11d", group = grpOl3)
olE12 = input.bool(false, "On", inline = "ol12", group = grpOl3)
olS12 = input.session("1600-1601", "Slot 12", inline = "ol12", group = grpOl3)
ol12Mo = input.bool(true, "M", inline = "s12d", group = grpOl3)
ol12Tu = input.bool(true, "Tu", inline = "s12d", group = grpOl3)
ol12We = input.bool(true, "W", inline = "s12d", group = grpOl3)
ol12Th = input.bool(true, "Th", inline = "s12d", group = grpOl3)
ol12Fr = input.bool(true, "F", inline = "s12d", group = grpOl3)
ol12Sa = input.bool(false, "Sa", inline = "s12d", group = grpOl3)
ol12Su = input.bool(false, "Su", inline = "s12d", group = grpOl3)

olE13 = input.bool(false, "On", inline = "ol13", group = grpOl4)
olS13 = input.session("0800-0801", "Slot 13", inline = "ol13", group = grpOl4)
ol13Mo = input.bool(true, "M", inline = "s13d", group = grpOl4)
ol13Tu = input.bool(true, "Tu", inline = "s13d", group = grpOl4)
ol13We = input.bool(true, "W", inline = "s13d", group = grpOl4)
ol13Th = input.bool(true, "Th", inline = "s13d", group = grpOl4)
ol13Fr = input.bool(true, "F", inline = "s13d", group = grpOl4)
ol13Sa = input.bool(false, "Sa", inline = "s13d", group = grpOl4)
ol13Su = input.bool(false, "Su", inline = "s13d", group = grpOl4)
olE14 = input.bool(false, "On", inline = "ol14", group = grpOl4)
olS14 = input.session("1100-1101", "Slot 14", inline = "ol14", group = grpOl4)
ol14Mo = input.bool(true, "M", inline = "s14d", group = grpOl4)
ol14Tu = input.bool(true, "Tu", inline = "s14d", group = grpOl4)
ol14We = input.bool(true, "W", inline = "s14d", group = grpOl4)
ol14Th = input.bool(true, "Th", inline = "s14d", group = grpOl4)
ol14Fr = input.bool(true, "F", inline = "s14d", group = grpOl4)
ol14Sa = input.bool(false, "Sa", inline = "s14d", group = grpOl4)
ol14Su = input.bool(false, "Su", inline = "s14d", group = grpOl4)
olE15 = input.bool(false, "On", inline = "ol15", group = grpOl4)
olS15 = input.session("1300-1301", "Slot 15", inline = "ol15", group = grpOl4)
ol15Mo = input.bool(true, "M", inline = "s15d", group = grpOl4)
ol15Tu = input.bool(true, "Tu", inline = "s15d", group = grpOl4)
ol15We = input.bool(true, "W", inline = "s15d", group = grpOl4)
ol15Th = input.bool(true, "Th", inline = "s15d", group = grpOl4)
ol15Fr = input.bool(true, "F", inline = "s15d", group = grpOl4)
ol15Sa = input.bool(false, "Sa", inline = "s15d", group = grpOl4)
ol15Su = input.bool(false, "Su", inline = "s15d", group = grpOl4)
olE16 = input.bool(false, "On", inline = "ol16", group = grpOl4)
olS16 = input.session("1400-1401", "Slot 16", inline = "ol16", group = grpOl4)
ol16Mo = input.bool(true, "M", inline = "s16d", group = grpOl4)
ol16Tu = input.bool(true, "Tu", inline = "s16d", group = grpOl4)
ol16We = input.bool(true, "W", inline = "s16d", group = grpOl4)
ol16Th = input.bool(true, "Th", inline = "s16d", group = grpOl4)
ol16Fr = input.bool(true, "F", inline = "s16d", group = grpOl4)
ol16Sa = input.bool(false, "Sa", inline = "s16d", group = grpOl4)
ol16Su = input.bool(false, "Su", inline = "s16d", group = grpOl4)

var array<line> olLinePool = array.new_line(0)

olDay7(bool mo, bool tu, bool we, bool th, bool fr, bool sa, bool su) =>
    d = dayofweek(time, lineTz)
    (d == dayofweek.monday and mo) or (d == dayofweek.tuesday and tu) or (d == dayofweek.wednesday and we) or (d == dayofweek.thursday and th) or (d == dayofweek.friday and fr) or (d == dayofweek.saturday and sa) or (d == dayofweek.sunday and su)

openLineWeekendOk() =>
    d = dayofweek(time, lineTz)
    not olHideWeekends or (d != dayofweek.saturday and d != dayofweek.sunday)

getOlLineStyle() =>
    olStyleIn == "Dashed" ? line.style_dashed : olStyleIn == "Dotted" ? line.style_dotted : line.style_solid

olBandBaseColor(int sid) =>
    sid < 4 ? olBand1Color : sid < 8 ? olBand2Color : sid < 12 ? olBand3Color : olBand4Color

olSlotColor(int sid) =>
    bc = olBandBaseColor(sid)
    olTintPerSlot ? color.new(bc, (sid % 4) * 12) : bc

olExtForSid(int sid) =>
    anchorSid = olAnchorSlot - 1
    extRaw = sid == anchorSid ? int(math.round(olExtendNormal * olAnchorExtendMult)) : olExtendNormal
    math.min(math.max(extRaw, 1), 500)

// First bar of session for this slot (pure); global array push must stay in main scope (Pine UDF rule).
olSessJustOpened(string sessStr) =>
    inS = not na(time(timeframe.period, sessStr, lineTz))
    inS and not inS[1]

sessCap = 28

nyExtremesEngine() =>
    nyH = hour(time, TZ)
    nyM = minute(time, TZ)
    ny595 = nyH == 16 and nyM == 59
    ny1700 = nyH == 17 and nyM == 0
    useOpen = sessionPriceMode == "17:00 bar open"

    var float sHigh = na
    var float sLow = na
    var float prevSessHi = na
    var float prevSessLo = na
    var aHi = array.new_float(0)
    var aLo = array.new_float(0)
    var float plotPh = na
    var float plotPl = na
    var float motherHi = na
    var float motherLo = na
    var bool motherActive = false
    var int insideMotherCount = 0
    var float nyDayOpen = na
    var int oppArmDir = 0
    var int strictInsideRun = 0

    useStrictInside = insideEnvelopeMode == "Prior NY day (strict)"

    bool nyFin = false
    float clF = na
    float fH = na
    float fL = na

    if ny1700
        nyDayOpen := open

    if useOpen
        nyFin := ny1700 and bar_index > 0 and not na(sHigh)
        clF := ny1700 ? open : na
        fH := sHigh
        fL := sLow
    else
        if ny1700
            sHigh := high
            sLow := low
        else if not na(sHigh)
            sHigh := math.max(sHigh, high)
            sLow := math.min(sLow, low)
        else
            sHigh := high
            sLow := low
        nyFin := ny595 and not na(sHigh)
        clF := close
        fH := sHigh
        fL := sLow

    dow = dayofweek(time, TZ)
    isNyWeekday = dow >= dayofweek.monday and dow <= dayofweek.friday
    nyFin := nyFin and (not weekdaysOnly or isNyWeekday)

    bullCore = nyFin and not na(prevSessHi) and clF > prevSessHi
    bearCore = nyFin and not na(prevSessLo) and clF < prevSessLo

    earlyBull = bullishOnly and bullCore
    earlyBear = bearishOnly and bearCore
    rawOut = insideFollowMatchVisible ? (earlyBull or earlyBear) : (bullCore or bearCore)

    refHi = prevSessHi
    refLo = prevSessLo

    envThis = motherActive and not na(motherHi) and not na(motherLo) and (fH <= motherHi) and (fL >= motherLo)
    strictEnv = not na(refHi) and not na(refLo) and (fH <= refHi) and (fL >= refLo)

    if nyFin
        if useStrictInside
            if strictEnv and not rawOut
                strictInsideRun := strictInsideRun + 1
            else
                strictInsideRun := 0
        array.unshift(aHi, fH)
        array.unshift(aLo, fL)
        while array.size(aHi) > sessCap
            array.pop(aHi)
            array.pop(aLo)
        prevSessHi := fH
        prevSessLo := fL
        if not useStrictInside
            if rawOut
                motherHi := fH
                motherLo := fL
                motherActive := true
                insideMotherCount := 0
            else if motherActive and envThis
                insideMotherCount := insideMotherCount + 1

    oppArmBull = oppMatchVisible ? earlyBull : bullCore
    oppArmBear = oppMatchVisible ? earlyBear : bearCore
    oppArmedPrev = oppArmDir
    oppHit = nyFin and oppArmedPrev != 0 and not useOpen and not na(nyDayOpen) and ((oppArmedPrev == 1 and clF < nyDayOpen) or (oppArmedPrev == -1 and clF > nyDayOpen))
    if nyFin and oppArmedPrev != 0
        oppArmDir := 0
    if nyFin and oppArmBull
        oppArmDir := 1
    else if nyFin and oppArmBear
        oppArmDir := -1

    insideHitLegacy = nyFin and not rawOut and motherActive and envThis and insideMotherCount == 1
    doubleInsideHitLegacy = nyFin and not rawOut and motherActive and envThis and insideMotherCount == 2
    insideHitStrict = nyFin and strictEnv and not rawOut and strictInsideRun == 1
    doubleInsideHitStrict = nyFin and strictEnv and not rawOut and strictInsideRun == 2
    insideHit = useStrictInside ? insideHitStrict : insideHitLegacy
    doubleInsideHit = useStrictInside ? doubleInsideHitStrict : doubleInsideHitLegacy

    if useOpen
        if ny1700
            sHigh := high
            sLow := low
        else if not na(sHigh)
            sHigh := math.max(sHigh, high)
            sLow := math.min(sLow, low)
        else
            sHigh := high
            sLow := low

    plotPh := refHi
    plotPl := refLo

    szPost = array.size(aHi)

    float wH = na
    float wL = na
    if szPost >= 6
        for i = 1 to 5
            hh = array.get(aHi, i)
            ll = array.get(aLo, i)
            wH := na(wH) ? hh : math.max(wH, hh)
            wL := na(wL) ? ll : math.min(wL, ll)

    float mH = na
    float mL = na
    if szPost >= 23
        for i = 1 to 22
            hh = array.get(aHi, i)
            ll = array.get(aLo, i)
            mH := na(mH) ? hh : math.max(mH, hh)
            mL := na(mL) ? ll : math.min(mL, ll)

    baseBull = bullishOnly and bullCore
    baseBear = bearishOnly and bearCore

    // Week/month: same close must pierce the envelope on the signal side (bull → above range high, bear → below range low).
    weekHit = nyFin and szPost >= 6 and not na(wH) and not na(wL) and ((baseBull and clF > wH) or (baseBear and clF < wL))
    monthHit = nyFin and szPost >= 23 and not na(mH) and not na(mL) and ((baseBull and clF > mH) or (baseBear and clF < mL))

    weekSig = showWeekTag and weekHit
    monthSig = showMonthTag and monthHit

    insideSig = showInsideFollow and insideHit
    doubleInsideSig = showDoubleInside and doubleInsideHit
    oppDaySig = showOppDay and oppHit

    [baseBull, baseBear, weekSig, monthSig, plotPh, plotPl, insideSig, doubleInsideSig, oppDaySig]

[baseBull, baseBear, weekSig, monthSig, plotPh, plotPl, insideSig, doubleInsideSig, oppDaySig] = request.security(syminfo.tickerid, engineTf, nyExtremesEngine(), barmerge.gaps_off, barmerge.lookahead_off)

plotshape(baseBull, title = "Outside prior session (bull)", style = shape.triangleup, location = location.belowbar, size = size.normal, color = bullColorIn, display = display.all)
plotshape(baseBear, title = "Outside prior session (bear)", style = shape.triangledown, location = location.abovebar, size = size.normal, color = bearColorIn, display = display.all)
plotshape(weekSig, title = "Also outside week (5 sess)", style = shape.circle, location = location.top, size = size.tiny, color = weekTagColor, display = display.all)
plotshape(monthSig, title = "Also outside month (22 sess)", style = shape.diamond, location = location.top, size = size.tiny, color = monthTagColor, display = display.all)

// plotshape() requires const style/size — circles only for inside-after-outside marker.
inFolN = insideSig and insideFollowNested
inFol1 = insideSig and not insideFollowNested
plotshape(inFolN, title = "Inside · nested outer", style = shape.circle, location = location.top, size = size.large, color = color.new(insideFollowColor, 55), display = display.all)
plotshape(inFolN, title = "Inside · nested inner", style = shape.circle, location = location.top, size = size.small, color = insideFollowColor, display = display.all)
plotshape(inFol1, title = "1st inside (single circle)", style = shape.circle, location = location.top, size = size.normal, color = insideFollowColor, display = display.all)
plotshape(doubleInsideSig, title = "2nd inside", style = shape.circle, location = location.top, size = size.huge, color = color.new(doubleInsideColor, 15), display = display.all)
plotchar(oppDaySig, title = "Opposing day after outside", char = "O", location = location.top, color = oppDayColor, size = size.small, display = display.all)

if showLabel and baseBull
    label.new(bar_index, low, "Past prior HI", style = label.style_label_up, size = size.small, color = color.new(bullColorIn, 40), textcolor = color.white)
if showLabel and baseBear
    label.new(bar_index, high, "Past prior LO", style = label.style_label_down, size = size.small, color = color.new(bearColorIn, 40), textcolor = color.white)

plot(plotPh, title = "Prior NY day high (ref)", color = color.new(color.blue, 70), style = plot.style_linebr, linewidth = 1)
plot(plotPl, title = "Prior NY day low (ref)", color = color.new(color.blue, 70), style = plot.style_linebr, linewidth = 1)

// Session open lines (chart timeframe) — array mutations here, not inside UDFs
olCanBase = showOpenLines and openLineWeekendOk()
olSt = getOlLineStyle()
if olCanBase and olE1 and olSessJustOpened(olS1) and olDay7(ol1Mo, ol1Tu, ol1We, ol1Th, ol1Fr, ol1Sa, ol1Su)
    array.push(olLinePool, line.new(bar_index, open, bar_index + olExtForSid(0), open, xloc = xloc.bar_index, color = olSlotColor(0), width = olWidth, style = olSt))
if olCanBase and olE2 and olSessJustOpened(olS2) and olDay7(ol2Mo, ol2Tu, ol2We, ol2Th, ol2Fr, ol2Sa, ol2Su)
    array.push(olLinePool, line.new(bar_index, open, bar_index + olExtForSid(1), open, xloc = xloc.bar_index, color = olSlotColor(1), width = olWidth, style = olSt))
if olCanBase and olE3 and olSessJustOpened(olS3) and olDay7(ol3Mo, ol3Tu, ol3We, ol3Th, ol3Fr, ol3Sa, ol3Su)
    array.push(olLinePool, line.new(bar_index, open, bar_index + olExtForSid(2), open, xloc = xloc.bar_index, color = olSlotColor(2), width = olWidth, style = olSt))
if olCanBase and olE4 and olSessJustOpened(olS4) and olDay7(ol4Mo, ol4Tu, ol4We, ol4Th, ol4Fr, ol4Sa, ol4Su)
    array.push(olLinePool, line.new(bar_index, open, bar_index + olExtForSid(3), open, xloc = xloc.bar_index, color = olSlotColor(3), width = olWidth, style = olSt))
if olCanBase and olE5 and olSessJustOpened(olS5) and olDay7(ol5Mo, ol5Tu, ol5We, ol5Th, ol5Fr, ol5Sa, ol5Su)
    array.push(olLinePool, line.new(bar_index, open, bar_index + olExtForSid(4), open, xloc = xloc.bar_index, color = olSlotColor(4), width = olWidth, style = olSt))
if olCanBase and olE6 and olSessJustOpened(olS6) and olDay7(ol6Mo, ol6Tu, ol6We, ol6Th, ol6Fr, ol6Sa, ol6Su)
    array.push(olLinePool, line.new(bar_index, open, bar_index + olExtForSid(5), open, xloc = xloc.bar_index, color = olSlotColor(5), width = olWidth, style = olSt))
if olCanBase and olE7 and olSessJustOpened(olS7) and olDay7(ol7Mo, ol7Tu, ol7We, ol7Th, ol7Fr, ol7Sa, ol7Su)
    array.push(olLinePool, line.new(bar_index, open, bar_index + olExtForSid(6), open, xloc = xloc.bar_index, color = olSlotColor(6), width = olWidth, style = olSt))
if olCanBase and olE8 and olSessJustOpened(olS8) and olDay7(ol8Mo, ol8Tu, ol8We, ol8Th, ol8Fr, ol8Sa, ol8Su)
    array.push(olLinePool, line.new(bar_index, open, bar_index + olExtForSid(7), open, xloc = xloc.bar_index, color = olSlotColor(7), width = olWidth, style = olSt))
if olCanBase and olE9 and olSessJustOpened(olS9) and olDay7(ol9Mo, ol9Tu, ol9We, ol9Th, ol9Fr, ol9Sa, ol9Su)
    array.push(olLinePool, line.new(bar_index, open, bar_index + olExtForSid(8), open, xloc = xloc.bar_index, color = olSlotColor(8), width = olWidth, style = olSt))
if olCanBase and olE10 and olSessJustOpened(olS10) and olDay7(ol10Mo, ol10Tu, ol10We, ol10Th, ol10Fr, ol10Sa, ol10Su)
    array.push(olLinePool, line.new(bar_index, open, bar_index + olExtForSid(9), open, xloc = xloc.bar_index, color = olSlotColor(9), width = olWidth, style = olSt))
if olCanBase and olE11 and olSessJustOpened(olS11) and olDay7(ol11Mo, ol11Tu, ol11We, ol11Th, ol11Fr, ol11Sa, ol11Su)
    array.push(olLinePool, line.new(bar_index, open, bar_index + olExtForSid(10), open, xloc = xloc.bar_index, color = olSlotColor(10), width = olWidth, style = olSt))
if olCanBase and olE12 and olSessJustOpened(olS12) and olDay7(ol12Mo, ol12Tu, ol12We, ol12Th, ol12Fr, ol12Sa, ol12Su)
    array.push(olLinePool, line.new(bar_index, open, bar_index + olExtForSid(11), open, xloc = xloc.bar_index, color = olSlotColor(11), width = olWidth, style = olSt))
if olCanBase and olE13 and olSessJustOpened(olS13) and olDay7(ol13Mo, ol13Tu, ol13We, ol13Th, ol13Fr, ol13Sa, ol13Su)
    array.push(olLinePool, line.new(bar_index, open, bar_index + olExtForSid(12), open, xloc = xloc.bar_index, color = olSlotColor(12), width = olWidth, style = olSt))
if olCanBase and olE14 and olSessJustOpened(olS14) and olDay7(ol14Mo, ol14Tu, ol14We, ol14Th, ol14Fr, ol14Sa, ol14Su)
    array.push(olLinePool, line.new(bar_index, open, bar_index + olExtForSid(13), open, xloc = xloc.bar_index, color = olSlotColor(13), width = olWidth, style = olSt))
if olCanBase and olE15 and olSessJustOpened(olS15) and olDay7(ol15Mo, ol15Tu, ol15We, ol15Th, ol15Fr, ol15Sa, ol15Su)
    array.push(olLinePool, line.new(bar_index, open, bar_index + olExtForSid(14), open, xloc = xloc.bar_index, color = olSlotColor(14), width = olWidth, style = olSt))
if olCanBase and olE16 and olSessJustOpened(olS16) and olDay7(ol16Mo, ol16Tu, ol16We, ol16Th, ol16Fr, ol16Sa, ol16Su)
    array.push(olLinePool, line.new(bar_index, open, bar_index + olExtForSid(15), open, xloc = xloc.bar_index, color = olSlotColor(15), width = olWidth, style = olSt))
while array.size(olLinePool) > olMaxKeep
    line.delete(array.shift(olLinePool))
````
