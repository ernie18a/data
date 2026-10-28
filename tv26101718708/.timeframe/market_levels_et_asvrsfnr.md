# Market Levels (ET)

- url: https://www.tradingview.com/script/ASvRSFnR-Market-Levels-ET/
- type: indicator
- pine_id: PUB;0e651956640b4caf82e6b17ae5e7c3d0
- version: 4.0

## Description

Market Levels & Intraday Reference Indicator provides essential daily and intraday price levels for traders. The indicator automatically plots key market references including previous day high/low, pre-market levels, opening range breakout (ORB), session opens, and dynamic intraday highs/lows. Designed for scalpers and day traders to quickly identify important support, resistance, breakout, and liquidity zones throughout the trading session.

## Source Code

````pine
// ============================================================
// Market Levels & Intraday Reference Indicator
// Version: 2.1.0  |  Pine Script v6
// ============================================================
// Displays key daily and intraday reference levels in ET:
//   • Last Trading Day High / Low  (RTH only: 9:30–16:00)
//   • 4:00 AM candle High / Low  (pre-market open)
//   • 3:59 PM candle High / Low  (last regular-session minute)
//   • 9:30 AM candle Open        (RTH open)
//   • 11:00 AM candle High / Low (late-morning reference)
//   • ORB: 5-min (9:30–9:34) shown at 9:35, auto-replaced by
//          15-min (9:30–9:44) shown at 9:45
//   • Pre-market session High / Low
//   • Dynamic Day High / Low     (live rolling extremes)
//
// FIXES in v2.1.0:
//   • PDH/PDL now accumulates ONLY during RTH (9:30–16:00 ET)
//     so the 4:00 AM pre-market candle is excluded.
//   • ORB auto-phases:
//       9:35 AM → shows 5-min ORB (9:30–9:34)
//       9:45 AM → removes 5-min ORB, shows 15-min ORB (9:30–9:44)
//     The i_orbStart / i_orbEnd inputs are removed; ranges are
//     hardcoded to match the new logic.
// ============================================================

//#region ── DECLARATION ──────────────────────────────────────
//@version=6
indicator(
     title           = "Market Levels (ET)",
     shorttitle      = "NL Market Levels",
     overlay         = true,
     max_lines_count = 500,
     max_labels_count = 500)
//#endregion

// ============================================================
//#region ── HELPER: LINE / LABEL STYLE CONVERTERS ────────────
// ============================================================

f_lineStyle(s) =>
    switch s
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_solid

f_labelSize(s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Large"  => size.large
        "Huge"   => size.huge
        => size.normal

f_extend(s) =>
    switch s
        "Left"  => extend.left
        "Both"  => extend.both
        => extend.right
//#endregion

// ============================================================
//#region ── INPUTS: GENERAL ──────────────────────────────────
// ============================================================

var GRP_GEN = "── General ──────────────────────────────────────"
i_tz        = input.string ("America/New_York", "Timezone",
                 options = ["America/New_York","America/Chicago",
                            "America/Los_Angeles","UTC"],
                 group = GRP_GEN)
i_lw        = input.int   (1, "Default Line Width", minval=1, maxval=4,
                 group = GRP_GEN)
i_ls        = input.string("Solid", "Default Line Style",
                 options = ["Solid","Dashed","Dotted"],
                 group = GRP_GEN)
i_ext       = input.string("Both", "Extend Lines",
                 options = ["Right","Left","Both"],
                 group = GRP_GEN)
i_showLbl   = input.bool  (true,  "Show Labels",         group = GRP_GEN)
i_showPrice = input.bool  (true,  "Show Price in Label",  group = GRP_GEN)
i_lblSize   = input.string("Normal","Label Size",
                 options = ["Tiny","Small","Normal","Large","Huge"],
                 group = GRP_GEN)

// ── Label position ───────────────────────────────────────────
var GRP_LBL = "── Label Position ───────────────────────────────"
i_lblPos    = input.string("Fixed Offset", "Label Placement",
                 options  = ["Far Right", "Near Candle", "Fixed Offset"],
                 tooltip  = "Far Right: pinned to the right edge of visible chart.\n" +
                            "Near Candle: just to the right of the latest bar.\n" +
                            "Fixed Offset: a fixed number of bars to the right of the latest bar.",
                 group    = GRP_LBL)
i_lblOffset = input.int  (120, "Fixed Offset (bars)", minval=0, maxval=500,
                 tooltip  = "Used only when Label Placement = Fixed Offset.",
                 group    = GRP_LBL)
//#endregion

// ============================================================
//#region ── INPUTS: PRIOR DAY HIGH / LOW ─────────────────────
// ============================================================

var GRP_PD  = "── Prior Day High / Low ─────────────────────────"
i_pdEnable  = input.bool  (true,                         "Enable",     group=GRP_PD)
i_pdHColor  = input.color (color.new(#9c27b0, 0),      "High Color", group=GRP_PD)
i_pdLColor  = input.color (color.new(#9c27b0, 0),      "Low Color",  group=GRP_PD)
i_pdHLabel  = input.string("PDH",                        "High Label", group=GRP_PD)
i_pdLLabel  = input.string("PDL",                        "Low Label",  group=GRP_PD)
i_pdLW      = input.int   (2, "Line Width", minval=1, maxval=4, group=GRP_PD)
i_pdLS      = input.string("Dashed","Line Style",
                 options=["Solid","Dashed","Dotted"], group=GRP_PD)
//#endregion

// ============================================================
//#region ── INPUTS: 4:00 AM CANDLE ───────────────────────────
// ============================================================

var GRP_4AM  = "── 4:00 AM Candle High / Low ────────────────────"
i_4amEnable = input.bool  (true,                         "Enable",     group=GRP_4AM)
i_4amHColor = input.color (color.new(#ffe0b2,0),    "High Color", group=GRP_4AM)
i_4amLColor = input.color (color.new(#ffe0b2,40),   "Low Color",  group=GRP_4AM)
i_4amHLabel = input.string("4AMH",                      "High Label", group=GRP_4AM)
i_4amLLabel = input.string("4AML",                      "Low Label",  group=GRP_4AM)
i_4amLW     = input.int   (1, "Line Width", minval=1, maxval=4, group=GRP_4AM)
i_4amLS     = input.string("Dashed","Line Style",
                 options=["Solid","Dashed","Dotted"], group=GRP_4AM)
//#endregion

// ============================================================
//#region ── INPUTS: 3:59 PM CANDLE ───────────────────────────
// ============================================================

var GRP_359  = "── 3:59 PM Candle High / Low ────────────────────"
i_359Enable = input.bool  (true,                         "Enable",     group=GRP_359)
i_359HColor = input.color (color.new(#2962ff, 0),    "High Color", group=GRP_359)
i_359LColor = input.color (color.new(#2962ff,40),   "Low Color",  group=GRP_359)
i_359HLabel = input.string("359-H",                      "High Label", group=GRP_359)
i_359LLabel = input.string("359-L",                      "Low Label",  group=GRP_359)
i_359LW     = input.int   (2, "Line Width", minval=1, maxval=4, group=GRP_359)
i_359LS     = input.string("Dashed","Line Style",
                 options=["Solid","Dashed","Dotted"], group=GRP_359)
//#endregion

// ============================================================
//#region ── INPUTS: 9:30 AM OPEN ─────────────────────────────
// ============================================================

var GRP_930  = "── 9:30 AM Open ─────────────────────────────────"
i_930Enable = input.bool  (true,                         "Enable",     group=GRP_930)
i_930Color  = input.color (color.new(#ff9800, 0),    "Color",      group=GRP_930)
i_930Label  = input.string("Open",                   "Label",      group=GRP_930)
i_930LW     = input.int   (2, "Line Width", minval=1, maxval=4, group=GRP_930)
i_930LS     = input.string("Dashed","Line Style",
                 options=["Solid","Dashed","Dotted"], group=GRP_930)
//#endregion

// ============================================================
//#region ── INPUTS: 11:00 AM CANDLE ──────────────────────────
// ============================================================

var GRP_11   = "── 11:00 AM Candle High / Low ───────────────────"
i_11Enable  = input.bool  (true,                         "Enable",     group=GRP_11)
i_11HColor  = input.color (color.new(#c8e6c9, 0),      "High Color", group=GRP_11)
i_11LColor  = input.color (color.new(#c8e6c9, 40),     "Low Color",  group=GRP_11)
i_11HLabel  = input.string("LDCH",                     "High Label", group=GRP_11)
i_11LLabel  = input.string("LDCL",                     "Low Label",  group=GRP_11)
i_11LW      = input.int   (1, "Line Width", minval=1, maxval=4, group=GRP_11)
i_11LS      = input.string("Dashed","Line Style",
                 options=["Solid","Dashed","Dotted"], group=GRP_11)
//#endregion

// ============================================================
//#region ── INPUTS: ORB ───────────────────────────────────────
// 5-min ORB  : 9:30–9:34 (shown from 9:35 AM)
// 15-min ORB : 9:30–9:44 (replaces 5-min at 9:45 AM)
// ============================================================

var GRP_ORB  = "── ORB High / Low (5-min → 15-min) ─────────────"
i_orbEnable  = input.bool  (true,                         "Enable",           group=GRP_ORB)
i_orbHColor  = input.color (color.new(#81682a, 0),      "High Color",       group=GRP_ORB)
i_orbLColor  = input.color (color.new(#81682a, 0),      "Low Color",        group=GRP_ORB)
i_orb5HLabel = input.string("5ORBH",                   "5min High Label",  group=GRP_ORB)
i_orb5LLabel = input.string("5ORBL",                   "5min Low Label",   group=GRP_ORB)
i_orbHLabel  = input.string("ORBH",                      "15min High Label", group=GRP_ORB)
i_orbLLabel  = input.string("ORBL",                      "15min Low Label",  group=GRP_ORB)
i_orbLW      = input.int   (2, "Line Width", minval=1, maxval=4, group=GRP_ORB)
i_orbLS      = input.string("Solid","Line Style",
                 options=["Solid","Dashed","Dotted"], group=GRP_ORB)
//#endregion

// ============================================================
//#region ── INPUTS: PRE-MARKET HIGH / LOW ────────────────────
// ============================================================

var GRP_PM   = "── Pre-Market High / Low ────────────────────────"
i_pmEnable  = input.bool  (true,                         "Enable",     group=GRP_PM)
i_pmHColor  = input.color (color.new(#ffeb3b, 0),     "High Color", group=GRP_PM)
i_pmLColor  = input.color (color.new(#ffeb3b, 0),   "Low Color",  group=GRP_PM)
i_pmHLabel  = input.string("PMH",                       "High Label", group=GRP_PM)
i_pmLLabel  = input.string("PML",                       "Low Label",  group=GRP_PM)
i_pmLW      = input.int   (2, "Line Width", minval=1, maxval=4, group=GRP_PM)
i_pmLS      = input.string("Solid","Line Style",
                 options=["Solid","Dashed","Dotted"], group=GRP_PM)
i_pmStart   = input.int(400,  "PM Start (HHMM)", minval=0, maxval=2359, group=GRP_PM)
i_pmEnd     = input.int(929,  "PM End   (HHMM)", minval=0, maxval=2359, group=GRP_PM)
//#endregion

// ============================================================
//#region ── INPUTS: DYNAMIC DAY HIGH / LOW ───────────────────
// ============================================================

var GRP_DYN  = "── Dynamic Day High / Low ───────────────────────"
i_dynEnable = input.bool  (true,                         "Enable",     group=GRP_DYN)
i_dynHColor = input.color (color.new(#673ab7, 0),     "High Color", group=GRP_DYN)
i_dynLColor = input.color (color.new(#673ab7, 0),     "Low Color",  group=GRP_DYN)
i_dynHLabel = input.string("DayH",                      "High Label", group=GRP_DYN)
i_dynLLabel = input.string("DayL",                      "Low Label",  group=GRP_DYN)
i_dynLW     = input.int   (1, "Line Width", minval=1, maxval=4, group=GRP_DYN)
i_dynLS     = input.string("Solid","Line Style",
                 options=["Solid","Dashed","Dotted"], group=GRP_DYN)
//#endregion

// ============================================================
//#region ── 1-MINUTE DATA VIA security() ─────────────────────
// gaps=barmerge.gaps_on prevents forward-fill.
// lookahead_off prevents repainting.
// ============================================================

[m1_open, m1_high, m1_low, m1_time] =
     request.security(syminfo.tickerid, "1",
         [open, high, low, time],
         gaps      = barmerge.gaps_on,
         lookahead = barmerge.lookahead_off)
//#endregion

// ============================================================
//#region ── TIME HELPERS ─────────────────────────────────────
// ============================================================

barHour   = hour  (time, i_tz)
barMinute = minute(time, i_tz)
barHHMM   = barHour * 100 + barMinute   // e.g. 400, 930, 1559

// HHMM for the 1-minute security bar
m1_barHour   = na(m1_time) ? na : hour  (m1_time, i_tz)
m1_barMinute = na(m1_time) ? na : minute(m1_time, i_tz)
m1_HHMM      = na(m1_time) ? na : m1_barHour * 100 + m1_barMinute

// ── 4:00 AM reset gate ───────────────────────────────────────
barDateStr = str.tostring(year(time, i_tz))        + "-" +
             str.tostring(month(time, i_tz))       + "-" +
             str.tostring(dayofmonth(time, i_tz))

var string lastResetDate = ""
// Fire exactly once per calendar date at or after 4:00 AM ET
is4amReset = barHHMM >= 400 and barDateStr != lastResetDate

// Classic new-day helper kept for PDH/PDL accumulator promotion.
isNewDay = ta.change(dayofweek(time, i_tz)) != 0 or
           (barHour == 0 and barMinute == 0)
//#endregion

// ============================================================
//#region ── LABEL X-POSITION HELPER ──────────────────────────
// ============================================================

f_labelX() =>
    switch i_lblPos
        "Far Right"    => last_bar_index
        "Near Candle"  => bar_index + 1
        => bar_index + i_lblOffset          // "Fixed Offset"
//#endregion

// ============================================================
//#region ── UTILITY: DRAW LINE + LABEL ───────────────────────
// ============================================================

f_drawLevel(ln, lb, price, col, lw, ls, ext, labelTxt, showLbl, showPrice, lblSz) =>
    var line  _ln = na
    var label _lb = na

    if not na(ln)
        line.delete(ln)
    if not na(lb)
        label.delete(lb)

    _ln := line.new(
         x1    = bar_index,
         y1    = price,
         x2    = bar_index + 1,
         y2    = price,
         color = col,
         width = lw,
         style = f_lineStyle(ls),
         extend= f_extend(ext))

    if showLbl
        displayTxt = showPrice
             ? labelTxt + "  " + str.tostring(price, format.mintick)
             : labelTxt
        _lb := label.new(
             x         = f_labelX(),
             y         = price,
             text      = displayTxt,
             color     = color.new(col, 80),
             textcolor = col,
             style     = label.style_label_left,
             size      = f_labelSize(lblSz),
             xloc      = xloc.bar_index,
             yloc      = yloc.price)

    [_ln, _lb]
//#endregion

// ============================================================
//#region ── PERSISTENT STATE VARIABLES ───────────────────────
// ============================================================

// ── Prior Day ────────────────────────────────────────────────
var float pdHigh      = na
var float pdLow       = na
var float _pdHigh_acc = na
var float _pdLow_acc  = na
var line  ln_pdH      = na
var line  ln_pdL      = na
var label lb_pdH      = na
var label lb_pdL      = na

// ── 4:00 AM candle (TODAY's pre-market open bar) ──────────────
var float cam4_high  = na
var float cam4_low   = na
var bool  cam4_set   = false
var line  ln_4H      = na
var line  ln_4L      = na
var label lb_4H      = na
var label lb_4L      = na

// ── 3:59 PM candle ───────────────────────────────────────────
var float _359_acc_high = na
var float _359_acc_low  = na
var float cam359_high   = na
var float cam359_low    = na
var bool  cam359_set    = false
var line  ln_359H       = na
var line  ln_359L       = na
var label lb_359H       = na
var label lb_359L       = na

// ── 9:30 AM open ─────────────────────────────────────────────
var float rthOpen     = na
var bool  rthOpen_set = false
var line  ln_930      = na
var label lb_930      = na

// ── 11:00 AM candle ──────────────────────────────────────────
var float cam11_high = na
var float cam11_low  = na
var bool  cam11_set  = false
var line  ln_11H     = na
var line  ln_11L     = na
var label lb_11H     = na
var label lb_11L     = na

// ── 5-min ORB (9:30–9:34, shown 9:35–9:44) ───────────────────
var float orb5_high  = na
var float orb5_low   = na
var bool  orb5_done  = false
var line  ln_orb5H   = na
var line  ln_orb5L   = na
var label lb_orb5H   = na
var label lb_orb5L   = na

// ── 15-min ORB (9:30–9:44, shown from 9:45) ──────────────────
var float orb_high   = na
var float orb_low    = na
var bool  orb_done   = false
var line  ln_orbH    = na
var line  ln_orbL    = na
var label lb_orbH    = na
var label lb_orbL    = na

// ── Pre-Market ────────────────────────────────────────────────
var float pm_high    = na
var float pm_low     = na
var line  ln_pmH     = na
var line  ln_pmL     = na
var label lb_pmH     = na
var label lb_pmL     = na

// ── Dynamic Day High / Low ───────────────────────────────────
var float dyn_high   = na
var float dyn_low    = na
var line  ln_dynH    = na
var line  ln_dynL    = na
var label lb_dynH    = na
var label lb_dynL    = na
//#endregion

// ============================================================
//#region ── PDH/PDL ACCUMULATOR ──────────────────────────────
// Restricted to RTH hours (9:30–16:00 ET) so the 4:00 AM
// pre-market candle is excluded from the Prior Day H/L.
// Must execute BEFORE the reset block.
// ============================================================

if not na(high) and barHHMM >= 930 and barHHMM <= 1600
    _pdHigh_acc := na(_pdHigh_acc) ? high : math.max(_pdHigh_acc, high)
    _pdLow_acc  := na(_pdLow_acc)  ? low  : math.min(_pdLow_acc,  low)
//#endregion

// ============================================================
//#region ── PROMOTE PDH/PDL ON NEW CALENDAR DAY ───────────────
// ============================================================

if isNewDay
    if not na(_pdHigh_acc)
        pdHigh := _pdHigh_acc
        pdLow  := _pdLow_acc
    _pdHigh_acc := na
    _pdLow_acc  := na
//#endregion

// ============================================================
//#region ── 4:00 AM RESET (intraday levels) ───────────────────
// ============================================================

if is4amReset
    lastResetDate := barDateStr

    // Promote today's (now yesterday's) 3:59 PM accumulator
    if not na(_359_acc_high)
        cam359_high := _359_acc_high
        cam359_low  := _359_acc_low
    _359_acc_high := na
    _359_acc_low  := na
    cam359_set    := false

    // Reset 4 AM candle for the new day
    cam4_set   := false
    cam4_high  := na
    cam4_low   := na

    // Reset other intraday levels
    rthOpen_set := false
    rthOpen     := na

    cam11_set  := false
    cam11_high := na
    cam11_low  := na

    // Reset ORB (both phases)
    orb5_done  := false
    orb5_high  := na
    orb5_low   := na

    orb_done   := false
    orb_high   := na
    orb_low    := na

    pm_high    := na
    pm_low     := na

    dyn_high   := na
    dyn_low    := na
//#endregion

// ============================================================
//#region ── CAPTURE SPECIFIC 1-MINUTE CANDLES ────────────────
// ============================================================

if not na(m1_HHMM)

    // ── 4:00 AM candle ──────────────────────────────────────
    if m1_HHMM == 400 and not cam4_set
        cam4_high := m1_high
        cam4_low  := m1_low
        cam4_set  := true

    // ── 3:59 PM candle ──────────────────────────────────────
    if m1_HHMM == 1559 and not cam359_set
        _359_acc_high := m1_high
        _359_acc_low  := m1_low
        cam359_high   := m1_high
        cam359_low    := m1_low
        cam359_set    := true

    // ── 9:30 AM open ────────────────────────────────────────
    if m1_HHMM == 930 and not rthOpen_set
        rthOpen     := m1_open
        rthOpen_set := true

    // ── 11:00 AM candle ─────────────────────────────────────
    if m1_HHMM == 1100 and not cam11_set
        cam11_high := m1_high
        cam11_low  := m1_low
        cam11_set  := true
//#endregion

// ============================================================
//#region ── ORB ACCUMULATION ──────────────────────────────────
// Phase 1 – 5-min ORB : accumulate 9:30–9:34, lock at 9:35
// Phase 2 – 15-min ORB: accumulate 9:30–9:44, lock at 9:45
// ============================================================

// 5-min ORB (9:30–9:34)
if not na(m1_HHMM) and m1_HHMM >= 930 and m1_HHMM <= 934
    orb5_high := na(orb5_high) ? m1_high : math.max(orb5_high, m1_high)
    orb5_low  := na(orb5_low)  ? m1_low  : math.min(orb5_low,  m1_low)

if barHHMM >= 935 and not orb5_done and not na(orb5_high)
    orb5_done := true

// 15-min ORB (9:30–9:44)
if not na(m1_HHMM) and m1_HHMM >= 930 and m1_HHMM <= 944
    orb_high := na(orb_high) ? m1_high : math.max(orb_high, m1_high)
    orb_low  := na(orb_low)  ? m1_low  : math.min(orb_low,  m1_low)

if barHHMM >= 945 and not orb_done and not na(orb_high)
    orb_done := true
//#endregion

// ============================================================
//#region ── PRE-MARKET ACCUMULATION ──────────────────────────
// ============================================================

if not na(m1_HHMM) and m1_HHMM >= i_pmStart and m1_HHMM <= i_pmEnd
    pm_high := na(pm_high) ? m1_high : math.max(pm_high, m1_high)
    pm_low  := na(pm_low)  ? m1_low  : math.min(pm_low,  m1_low)
//#endregion

// ============================================================
//#region ── DYNAMIC DAY HIGH / LOW ───────────────────────────
// ============================================================

if not na(high)
    dyn_high := na(dyn_high) ? high : math.max(dyn_high, high)
    dyn_low  := na(dyn_low)  ? low  : math.min(dyn_low,  low)
//#endregion

// ============================================================
//#region ── DRAW LINES (last bar only) ───────────────────────
// ============================================================

if barstate.islast

    ls  = i_ls
    lw  = i_lw
    ext = i_ext
    sl  = i_showLbl
    sp  = i_showPrice
    lsz = i_lblSize

    // ── Prior Day High / Low ─────────────────────────────────
    if i_pdEnable
        if not na(pdHigh)
            [lnH, lbH] = f_drawLevel(ln_pdH, lb_pdH, pdHigh,
                 i_pdHColor, i_pdLW, i_pdLS, ext,
                 i_pdHLabel, sl, sp, lsz)
            ln_pdH := lnH
            lb_pdH := lbH
        if not na(pdLow)
            [lnL, lbL] = f_drawLevel(ln_pdL, lb_pdL, pdLow,
                 i_pdLColor, i_pdLW, i_pdLS, ext,
                 i_pdLLabel, sl, sp, lsz)
            ln_pdL := lnL
            lb_pdL := lbL

    // ── 4:00 AM Candle High / Low ────────────────────────────
    if i_4amEnable and cam4_set
        [lnH, lbH] = f_drawLevel(ln_4H, lb_4H, cam4_high,
             i_4amHColor, i_4amLW, i_4amLS, ext,
             i_4amHLabel, sl, sp, lsz)
        ln_4H := lnH
        lb_4H := lbH
        [lnL, lbL] = f_drawLevel(ln_4L, lb_4L, cam4_low,
             i_4amLColor, i_4amLW, i_4amLS, ext,
             i_4amLLabel, sl, sp, lsz)
        ln_4L := lnL
        lb_4L := lbL

    // ── 3:59 PM Candle High / Low ────────────────────────────
    if i_359Enable and not na(cam359_high)
        [lnH, lbH] = f_drawLevel(ln_359H, lb_359H, cam359_high,
             i_359HColor, i_359LW, i_359LS, ext,
             i_359HLabel, sl, sp, lsz)
        ln_359H := lnH
        lb_359H := lbH
        [lnL, lbL] = f_drawLevel(ln_359L, lb_359L, cam359_low,
             i_359LColor, i_359LW, i_359LS, ext,
             i_359LLabel, sl, sp, lsz)
        ln_359L := lnL
        lb_359L := lbL

    // ── 9:30 AM Open ─────────────────────────────────────────
    if i_930Enable and rthOpen_set
        [ln0, lb0] = f_drawLevel(ln_930, lb_930, rthOpen,
             i_930Color, i_930LW, i_930LS, ext,
             i_930Label, sl, sp, lsz)
        ln_930 := ln0
        lb_930 := lb0

    // ── 11:00 AM Candle High / Low ───────────────────────────
    if i_11Enable and cam11_set and barHHMM > 1100
        [lnH, lbH] = f_drawLevel(ln_11H, lb_11H, cam11_high,
             i_11HColor, i_11LW, i_11LS, ext,
             i_11HLabel, sl, sp, lsz)
        ln_11H := lnH
        lb_11H := lbH
        [lnL, lbL] = f_drawLevel(ln_11L, lb_11L, cam11_low,
             i_11LColor, i_11LW, i_11LS, ext,
             i_11LLabel, sl, sp, lsz)
        ln_11L := lnL
        lb_11L := lbL

    // ── 5-min ORB (visible 9:35–9:44) ───────────────────────
    // Show from 9:35 until the 15-min ORB is ready at 9:45.
    if i_orbEnable and orb5_done and not orb_done
        [lnH, lbH] = f_drawLevel(ln_orb5H, lb_orb5H, orb5_high,
             i_orbHColor, i_orbLW, i_orbLS, ext,
             i_orb5HLabel, sl, sp, lsz)
        ln_orb5H := lnH
        lb_orb5H := lbH
        [lnL, lbL] = f_drawLevel(ln_orb5L, lb_orb5L, orb5_low,
             i_orbLColor, i_orbLW, i_orbLS, ext,
             i_orb5LLabel, sl, sp, lsz)
        ln_orb5L := lnL
        lb_orb5L := lbL

    // ── 15-min ORB (visible from 9:45) ───────────────────────
    // When this fires, also clean up any residual 5-min ORB lines.
    if i_orbEnable and orb_done
        // Remove 5-min ORB lines so they don't linger
        if not na(ln_orb5H)
            line.delete(ln_orb5H)
            ln_orb5H := na
        if not na(lb_orb5H)
            label.delete(lb_orb5H)
            lb_orb5H := na
        if not na(ln_orb5L)
            line.delete(ln_orb5L)
            ln_orb5L := na
        if not na(lb_orb5L)
            label.delete(lb_orb5L)
            lb_orb5L := na
        // Draw 15-min ORB
        [lnH, lbH] = f_drawLevel(ln_orbH, lb_orbH, orb_high,
             i_orbHColor, i_orbLW, i_orbLS, ext,
             i_orbHLabel, sl, sp, lsz)
        ln_orbH := lnH
        lb_orbH := lbH
        [lnL, lbL] = f_drawLevel(ln_orbL, lb_orbL, orb_low,
             i_orbLColor, i_orbLW, i_orbLS, ext,
             i_orbLLabel, sl, sp, lsz)
        ln_orbL := lnL
        lb_orbL := lbL

    // ── Pre-Market High / Low ────────────────────────────────
    if i_pmEnable and not na(pm_high)
        [lnH, lbH] = f_drawLevel(ln_pmH, lb_pmH, pm_high,
             i_pmHColor, i_pmLW, i_pmLS, ext,
             i_pmHLabel, sl, sp, lsz)
        ln_pmH := lnH
        lb_pmH := lbH
        [lnL, lbL] = f_drawLevel(ln_pmL, lb_pmL, pm_low,
             i_pmLColor, i_pmLW, i_pmLS, ext,
             i_pmLLabel, sl, sp, lsz)
        ln_pmL := lnL
        lb_pmL := lbL

    // ── Dynamic Day High / Low ───────────────────────────────
    if i_dynEnable and not na(dyn_high)
        [lnH, lbH] = f_drawLevel(ln_dynH, lb_dynH, dyn_high,
             i_dynHColor, i_dynLW, i_dynLS, ext,
             i_dynHLabel, sl, sp, lsz)
        ln_dynH := lnH
        lb_dynH := lbH
        [lnL, lbL] = f_drawLevel(ln_dynL, lb_dynL, dyn_low,
             i_dynLColor, i_dynLW, i_dynLS, ext,
             i_dynLLabel, sl, sp, lsz)
        ln_dynL := lnL
        lb_dynL := lbL
//#endregion
// ── END OF SCRIPT ────────────────────────────────────────────
````
