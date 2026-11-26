# Valid Range - F1 + F2 + F3 + MTF Screener

- url: https://www.tradingview.com/script/3Tunq2WF-Valid-Range-F1-F2-F3-MTF-Screener/
- type: indicator
- pine_id: PUB;99b5b3972a98432693143a39daf012a4
- version: 1.0

## Description

VALID RANGE: F1 + F2 + F3 + MTF SCREENER

Detects three "Valid Range" pullback formations in both directions, marks the Structure Break (SB) and the Strong Low / Strong High, and scans up to 8 timeframes in a colour-coded table.

━━━━━━━━━━━━━━━━━━
WHAT IT DOES
━━━━━━━━━━━━━━━━━━
The script finds a candle pattern, waits for a pullback, then confirms the setup when price breaks the structure level. When a setup is confirmed it draws:

- A shaded Valid Range box from Candle 1 to the SB
- The SB level as a line with a label (SB1 / SB2 / SB3)
- The Strong Low (uptrend) or Strong High (downtrend), extended until price takes it out

━━━━━━━━━━━━━━━━━━
THE THREE FORMATIONS (uptrend)
━━━━━━━━━━━━━━━━━━
Formation 1
- C1: bullish candle with an upper wick; its high is the SB level
- PB: the next candle is bearish with a lower high than C1
- SB: C1 high is broken. Strong Low = lowest low of the pullback

Formation 2
- C1: bullish candle (wick optional)
- C2: bearish candle that closes above the C1 high; its high is the SB level
- PB: following candles stay below the C2 high
- SB: C2 high is broken after at least one pullback candle

Formation 3
- Same as Formation 2, but C2 is a bearish candle whose high is equal to the C1 high (within a tolerance you set) instead of closing above it

Downtrend setups are the exact mirror of each formation. They run through the same logic on mirrored prices, so the two sides cannot drift apart.

━━━━━━━━━━━━━━━━━━
MTF SCREENER
━━━━━━━━━━━━━━━━━━
A table on the chart reports, for up to 8 timeframes (default: 1, 5, 15, 30, 60, 240, D, W):

- Bias: whichever side confirmed an SB most recently
- Uptrend / Downtrend status: pullback in progress (with the level that must break), or the latest SB with its age ("now", "3 ago")
- Strong Low and Strong High of the latest confirmed SB
- Recent SBs are highlighted; pullbacks in progress are shown in orange

An optional Overall box counts the Bias column of the timeframes you tick and shows BULLISH, BEARISH or NEUTRAL. Each timeframe has its own Show and Overall toggle.

━━━━━━━━━━━━━━━━━━
SETTINGS
━━━━━━━━━━━━━━━━━━
- Formations: enable or disable F1 / F2 / F3; direction Both / Uptrend / Downtrend
- SB triggered by: Wick, Close, or Both. In Both mode the label is tagged C (candle also closed beyond the level) or W (wick only), and wick-only SBs get a dotted line
- F1: require wick on Candle 1
- Invalidate if the pullback undercuts Candle 1 (uptrend) or overshoots it (downtrend)
- Max pullback candles before a setup is dropped
- F3 equal-high tolerance in ticks
- Minimum pullback duration: automatic 8h on the 4H chart, or a custom number of hours for other timeframes
- Visuals: colours, box, SB line, PB/C2 markers, extension of Strong levels, max active levels per side
- Screener: position, text size, "recent SB" window, timeframes

━━━━━━━━━━━━━━━━━━
ALERTS
━━━━━━━━━━━━━━━━━━
- Valid Range SB, Uptrend
- Valid Range SB, Downtrend
- Valid setup started, Uptrend
- Valid setup started, Downtrend

━━━━━━━━━━━━━━━━━━
NOTES
━━━━━━━━━━━━━━━━━━
- Detection and drawing run on closed bars only, so there are no repaints or duplicate drawings on realtime ticks
- The screener reports the state of the last closed bar of each timeframe
- Lower-timeframe screener rows depend on the intraday history available for the symbol on your plan
- If several formations fire on the same bar in the screener, the higher formation number is reported
- This is a pattern-detection and visualisation tool, not a trading signal or financial advice. Test any setup on your own markets before relying on it.

Feedback and suggestions are welcome in the comments.

## Source Code

````pine
//@version=6
indicator("Valid Range - F1 + F2 + F3 + MTF Screener", shorttitle="VR F1/F2/F3", overlay=true,
     max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// =============================================================================
// VALID RANGE - FORMATIONS 1, 2 and 3 (uptrend and downtrend)
//
// FORMATION 1 (uptrend)
//   C1 : bullish candle closing with an upper wick (SB level = C1 high)
//   PB : next candle bearish AND LH (high < C1 high)
//   SB : C1 high broken after the PB.  Strong Low = lowest low of the pullback.
//
// FORMATION 2 (uptrend)
//   C1 : bullish candle (wick optional)
//   C2 : bearish candle that CLOSES ABOVE the C1 high (SB level = C2 high)
//   PB : 3rd+ candles (any colour) that stay below the C2 high (LH vs C2)
//   SB : C2 high broken after at least one PB candle.
//        Strong Low = lowest low of C2 and the pullback candles.
//
// FORMATION 3 (uptrend)
//   Same as Formation 2, except C2 is a bearish candle whose HIGH is EQUAL to the
//   C1 high (within the tolerance input) rather than closing above it.
//   SB level = C2 high. Strong Low = lowest low of C2 and the pullback candles.
//
// Downtrend = exact mirror of each. Implemented by running the same logic on
// mirrored prices (-low, -high, -close, -open) so both sides cannot drift apart.
//
// NOTE: the guide's F2 downtrend step 2 says "closes below the HIGH of the
// bearish candle". That reads as a typo; this script mirrors the uptrend rule
// (C2 closes below the C1 LOW).
// =============================================================================

// ---- Constants --------------------------------------------------------------
const int    SEC_4H        = 14400
const int    MIN_PB_4H_SEC = 28800     // 8 hours
const string GRP_FRM       = "Formations"
const string GRP_DET       = "Detection"
const string GRP_PB        = "Pullback Duration"
const string GRP_VIS       = "Visuals"
const string GRP_SCR       = "MTF Screener"

// ---- Inputs -----------------------------------------------------------------
i_useF1      = input.bool(true, "Formation 1", group=GRP_FRM, inline="f")
i_useF2      = input.bool(true, "Formation 2", group=GRP_FRM, inline="f")
i_useF3      = input.bool(true, "Formation 3", group=GRP_FRM, inline="f")
i_dir        = input.string("Both", "Direction", options=["Both", "Uptrend", "Downtrend"], group=GRP_FRM)

i_reqWick    = input.bool(true, "F1: require wick on Candle 1", group=GRP_DET,
     tooltip="Uptrend: C1 needs an upper wick (high > close). Downtrend: lower wick (low < close). Formations 2 and 3 never require a wick.")
i_sbMode     = input.string("Wick", "SB triggered by", options=["Wick", "Close", "Both"], group=GRP_DET,
     tooltip="Wick: any trade beyond the SB level counts. Close: a candle must CLOSE beyond it. Both: a wick break triggers the SB, and it is tagged C (candle also closed beyond the level) or W (wick only). Wick-only SBs get a dotted line.")
i_invalidate = input.bool(true, "Invalidate if pullback undercuts Candle 1", group=GRP_DET,
     tooltip="If price trades below C1 low (uptrend) / above C1 high (downtrend) before the SB, the setup is dropped.")
i_maxPb      = input.int(30, "Max pullback candles", minval=1, maxval=500, group=GRP_DET,
     tooltip="Setup is dropped if no SB happens within this many candles.")
i_eqTicks    = input.float(0.0, "F3: equal-high tolerance (ticks)", minval=0.0, step=1.0, group=GRP_DET,
     tooltip="Formation 3: how far C2 high may differ from C1 high and still count as an equal high. 0 = exact match. Within this band, F3 owns the setup and F1 ignores it.")

i_auto4H     = input.bool(true, "Auto: 8h minimum pullback on 4H", group=GRP_PB,
     tooltip="Guide rule: on 4H the pullback must last at least 8 hours (2+ candles). F1 counts the PB candle(s); F2/F3 count the candles after C2.")
i_minHrs     = input.float(0.0, "Min pullback (hours) - other TFs", minval=0.0, step=0.25, group=GRP_PB,
     tooltip="0 = no minimum. Ignored on 4H while Auto is on. Pullback length = candles x timeframe.")

i_upClr      = input.color(#26a69a, "Uptrend colour", group=GRP_VIS)
i_dnClr      = input.color(#ef5350, "Downtrend colour", group=GRP_VIS)
i_showBox    = input.bool(true, "Shade valid range", group=GRP_VIS)
i_showSB     = input.bool(true, "SB line + label", group=GRP_VIS)
i_showPB     = input.bool(true, "Mark PB (F1) / C2 (F2) candle", group=GRP_VIS)
i_extend     = input.bool(true, "Extend Strong Low/High until broken", group=GRP_VIS)
i_maxLvls    = input.int(10, "Max active Strong levels per side", minval=1, maxval=100, group=GRP_VIS)

i_showTbl    = input.bool(true, "Show screener table", group=GRP_SCR)
i_showOverall = input.bool(true, "Overall bias box", group=GRP_SCR,
     tooltip="Colour-coded box under the table. Counts the Bias column of the timeframes that have BOTH 'Show' and 'Overall' ticked: more UP than DOWN = BULLISH, more DOWN than UP = BEARISH, otherwise NEUTRAL. Timeframes shown but not in the overall have a dimmed TF label.")
i_tblPos     = input.string(position.top_right, "Position", options=[position.top_left, position.top_center, position.top_right, position.middle_left, position.middle_right, position.bottom_left, position.bottom_center, position.bottom_right], group=GRP_SCR)
i_tblSize    = input.string(size.small, "Text size", options=[size.tiny, size.small, size.normal], group=GRP_SCR)
i_recent     = input.int(3, "Highlight SB if within N closed bars of that TF", minval=0, maxval=100, group=GRP_SCR)
i_tf1 = input.timeframe("1",   "TF 1", group=GRP_SCR, inline="t1")
i_on1 = input.bool(true, "Show", group=GRP_SCR, inline="t1")
i_ov1 = input.bool(true, "Overall", group=GRP_SCR, inline="t1")
i_tf2 = input.timeframe("5",   "TF 2", group=GRP_SCR, inline="t2")
i_on2 = input.bool(true, "Show", group=GRP_SCR, inline="t2")
i_ov2 = input.bool(true, "Overall", group=GRP_SCR, inline="t2")
i_tf3 = input.timeframe("15",  "TF 3", group=GRP_SCR, inline="t3")
i_on3 = input.bool(true, "Show", group=GRP_SCR, inline="t3")
i_ov3 = input.bool(true, "Overall", group=GRP_SCR, inline="t3")
i_tf4 = input.timeframe("30",  "TF 4", group=GRP_SCR, inline="t4")
i_on4 = input.bool(true, "Show", group=GRP_SCR, inline="t4")
i_ov4 = input.bool(true, "Overall", group=GRP_SCR, inline="t4")
i_tf5 = input.timeframe("60",  "TF 5", group=GRP_SCR, inline="t5")
i_on5 = input.bool(true, "Show", group=GRP_SCR, inline="t5")
i_ov5 = input.bool(true, "Overall", group=GRP_SCR, inline="t5")
i_tf6 = input.timeframe("240", "TF 6", group=GRP_SCR, inline="t6")
i_on6 = input.bool(true, "Show", group=GRP_SCR, inline="t6")
i_ov6 = input.bool(true, "Overall", group=GRP_SCR, inline="t6")
i_tf7 = input.timeframe("D",   "TF 7", group=GRP_SCR, inline="t7")
i_on7 = input.bool(true, "Show", group=GRP_SCR, inline="t7")
i_ov7 = input.bool(true, "Overall", group=GRP_SCR, inline="t7")
i_tf8 = input.timeframe("W",   "TF 8", group=GRP_SCR, inline="t8")
i_on8 = input.bool(true, "Show", group=GRP_SCR, inline="t8")
i_ov8 = input.bool(true, "Overall", group=GRP_SCR, inline="t8")

// ---- Types ------------------------------------------------------------------
// All prices are stored in "up space". For the downtrend they are mirrored (x -1).
type VRState
    bool  active  = false
    int   c1Bar   = na     // box starts here
    int   sbBar   = na     // SB line starts here (C1 for F1, C2 for F2)
    float sbLvl   = na     // structure-break trigger level
    float invLvl  = na     // C1 low -> invalidation level
    float pbLo    = na     // strong low (up space)
    int   pbLoBar = na
    int   count   = 0      // pullback candles so far
    bool  sbCls   = false  // on the SB bar: did the candle CLOSE beyond the SB level (true) or wick only (false)

// ---- Methods ----------------------------------------------------------------
method wipe(VRState s) =>
    s.active  := false
    s.c1Bar   := na
    s.sbBar   := na
    s.sbLvl   := na
    s.invLvl  := na
    s.pbLo    := na
    s.pbLoBar := na
    s.count   := 0
    s.sbCls   := false
    s.active

// Returns: 0 nothing | 1 setup started | 2 valid range with SB | -1 setup dropped
method advance(VRState s, float hi, float lo, float cl, float op,
     float hi1, float lo1, float cl1, float op1, int formation,
     bool reqWick, bool brkOnClose, bool invalidate, int maxPb, int minSec, int tfSec, float eqTol) =>
    int result = 0
    bool eqHigh = math.abs(hi - hi1) <= eqTol
    if not s.active
        if formation == 1
            bool c1Ok = cl1 > op1 and (not reqWick or hi1 > cl1)
            bool pbOk = cl < op and hi < hi1 and not eqHigh
            if c1Ok and pbOk
                s.active  := true
                s.c1Bar   := bar_index - 1
                s.sbBar   := bar_index - 1
                s.sbLvl   := hi1
                s.invLvl  := lo1
                s.pbLo    := lo
                s.pbLoBar := bar_index
                s.count   := 1
                result    := 1
        else if formation == 2
            bool c1Ok2 = cl1 > op1
            bool c2Ok  = cl < op and cl > hi1
            if c1Ok2 and c2Ok
                s.active  := true
                s.c1Bar   := bar_index - 1
                s.sbBar   := bar_index
                s.sbLvl   := hi
                s.invLvl  := lo1
                s.pbLo    := lo
                s.pbLoBar := bar_index
                s.count   := 0
                result    := 1
        else
            bool c1Ok3 = cl1 > op1
            bool c2Ok3 = cl < op and eqHigh and cl <= hi1
            if c1Ok3 and c2Ok3
                s.active  := true
                s.c1Bar   := bar_index - 1
                s.sbBar   := bar_index
                s.sbLvl   := hi
                s.invLvl  := lo1
                s.pbLo    := lo
                s.pbLoBar := bar_index
                s.count   := 0
                result    := 1
    else
        bool brk = brkOnClose ? cl > s.sbLvl : hi > s.sbLvl
        if brk
            s.sbCls := cl > s.sbLvl
            result := (s.count >= 1 and s.count * tfSec >= minSec) ? 2 : -1
        else if invalidate and lo < s.invLvl
            result := -1
        else if s.count >= maxPb
            result := -1
        else
            s.count := s.count + 1
            if lo < s.pbLo
                s.pbLo    := lo
                s.pbLoBar := bar_index
    result

// ---- Helpers ----------------------------------------------------------------
f_minSec(int tfS) =>
    (i_auto4H and tfS == SEC_4H) ? MIN_PB_4H_SEC : int(math.round(i_minHrs * 3600))

f_tfLabel(string tf) =>
    int s = timeframe.in_seconds(tf)
    string r = tf
    if s >= 86400
        r := tf
    else if s % 3600 == 0
        r := str.tostring(int(s / 3600)) + "H"
    else
        r := str.tostring(int(s / 60)) + "m"
    r

// Draws box, SB line + label, strong level. Returns the strong-level line.
f_drawVR(VRState s, bool isUp, int form, color clr, bool showBox, bool showSB) =>
    float sgn       = isUp ? 1.0 : -1.0
    float sbLvl     = sgn * s.sbLvl
    float strongLvl = sgn * s.pbLo
    if showBox
        box.new(left=s.c1Bar, top=isUp ? sbLvl : strongLvl, right=bar_index,
             bottom=isUp ? strongLvl : sbLvl, border_color=color.new(clr, 70), bgcolor=color.new(clr, 90))
    if showSB
        bool both = i_sbMode == "Both"
        line.new(s.sbBar, sbLvl, bar_index, sbLvl, color=clr, width=1,
             style=(both and not s.sbCls) ? line.style_dotted : line.style_solid)
        label.new(bar_index, isUp ? high : low, "SB" + str.tostring(form) + (both ? (s.sbCls ? " C" : " W") : ""),
             style=isUp ? label.style_label_down : label.style_label_up,
             color=clr, textcolor=color.white, size=size.tiny)
    line.new(s.pbLoBar, strongLvl, bar_index, strongLvl, color=clr, width=1, style=line.style_dashed)

// Draws on SB, wipes finished/dropped setups, returns r unchanged.
f_handle(VRState s, int r, bool isUp, int form, color clr, array<line> lvls) =>
    if r == 2
        line lv = f_drawVR(s, isUp, form, clr, i_showBox, i_showSB)
        if i_extend
            lvls.push(lv)
            if lvls.size() > i_maxLvls
                lvls.shift()
    if r == 2 or r == -1
        s.wipe()
    r

// Extends active strong levels; stops them once price takes them out.
f_extendLevels(array<line> lvls, bool isUp) =>
    int i = lvls.size() - 1
    while i >= 0
        line ln = lvls.get(i)
        float lvl = ln.get_y1()
        bool broken = isUp ? low < lvl : high > lvl
        ln.set_x2(bar_index)
        if broken
            lvls.remove(i)
        i -= 1
    lvls.size()

// ---- State ------------------------------------------------------------------
var VRState     upS1   = VRState.new()
var VRState     upS2   = VRState.new()
var VRState     upS3   = VRState.new()
var VRState     dnS1   = VRState.new()
var VRState     dnS2   = VRState.new()
var VRState     dnS3   = VRState.new()
var array<line> upLvls = array.new<line>()
var array<line> dnLvls = array.new<line>()

// ---- Core (chart timeframe) -------------------------------------------------
int  tfSec      = timeframe.in_seconds()
int  minSec     = f_minSec(tfSec)
bool brkOnClose = i_sbMode == "Close"
bool allowUp    = i_dir != "Downtrend"
bool allowDn    = i_dir != "Uptrend"

float eqTol = i_eqTicks * syminfo.mintick + syminfo.mintick * 0.01

int rU1 = 0
int rU2 = 0
int rU3 = 0
int rD1 = 0
int rD2 = 0
int rD3 = 0

// Closed bars only -> no repainting, no duplicate drawings on realtime ticks.
if barstate.isconfirmed
    f_extendLevels(upLvls, true)
    f_extendLevels(dnLvls, false)

    if allowUp and i_useF1
        rU1 := f_handle(upS1, upS1.advance(high, low, close, open, high[1], low[1], close[1], open[1], 1,
             i_reqWick, brkOnClose, i_invalidate, i_maxPb, minSec, tfSec, eqTol), true, 1, i_upClr, upLvls)
    if allowUp and i_useF2
        rU2 := f_handle(upS2, upS2.advance(high, low, close, open, high[1], low[1], close[1], open[1], 2,
             i_reqWick, brkOnClose, i_invalidate, i_maxPb, minSec, tfSec, eqTol), true, 2, i_upClr, upLvls)
    if allowUp and i_useF3
        rU3 := f_handle(upS3, upS3.advance(high, low, close, open, high[1], low[1], close[1], open[1], 3,
             i_reqWick, brkOnClose, i_invalidate, i_maxPb, minSec, tfSec, eqTol), true, 3, i_upClr, upLvls)
    if allowDn and i_useF1
        rD1 := f_handle(dnS1, dnS1.advance(-low, -high, -close, -open, -low[1], -high[1], -close[1], -open[1], 1,
             i_reqWick, brkOnClose, i_invalidate, i_maxPb, minSec, tfSec, eqTol), false, 1, i_dnClr, dnLvls)
    if allowDn and i_useF2
        rD2 := f_handle(dnS2, dnS2.advance(-low, -high, -close, -open, -low[1], -high[1], -close[1], -open[1], 2,
             i_reqWick, brkOnClose, i_invalidate, i_maxPb, minSec, tfSec, eqTol), false, 2, i_dnClr, dnLvls)
    if allowDn and i_useF3
        rD3 := f_handle(dnS3, dnS3.advance(-low, -high, -close, -open, -low[1], -high[1], -close[1], -open[1], 3,
             i_reqWick, brkOnClose, i_invalidate, i_maxPb, minSec, tfSec, eqTol), false, 3, i_dnClr, dnLvls)

bool upSB    = rU1 == 2 or rU2 == 2 or rU3 == 2
bool dnSB    = rD1 == 2 or rD2 == 2 or rD3 == 2
bool upStart = rU1 == 1 or rU2 == 1 or rU3 == 1
bool dnStart = rD1 == 1 or rD2 == 1 or rD3 == 1

// ---- Plots ------------------------------------------------------------------
plotshape(i_showPB and rU1 == 1, "F1 PB (Uptrend)", style=shape.triangledown, location=location.abovebar,
     color=i_upClr, size=size.tiny, text="PB", textcolor=i_upClr)
plotshape(i_showPB and rU2 == 1, "F2 C2 (Uptrend)", style=shape.triangledown, location=location.abovebar,
     color=i_upClr, size=size.tiny, text="C2", textcolor=i_upClr)
plotshape(i_showPB and rU3 == 1, "F3 C2 (Uptrend)", style=shape.triangledown, location=location.abovebar,
     color=i_upClr, size=size.tiny, text="C2=", textcolor=i_upClr)
plotshape(i_showPB and rD1 == 1, "F1 PB (Downtrend)", style=shape.triangleup, location=location.belowbar,
     color=i_dnClr, size=size.tiny, text="PB", textcolor=i_dnClr)
plotshape(i_showPB and rD2 == 1, "F2 C2 (Downtrend)", style=shape.triangleup, location=location.belowbar,
     color=i_dnClr, size=size.tiny, text="C2", textcolor=i_dnClr)
plotshape(i_showPB and rD3 == 1, "F3 C2 (Downtrend)", style=shape.triangleup, location=location.belowbar,
     color=i_dnClr, size=size.tiny, text="C2=", textcolor=i_dnClr)

// ---- Alerts -----------------------------------------------------------------
alertcondition(upSB, "Valid Range SB - Uptrend", "Valid Range with Structure Break (UP) on {{ticker}} {{interval}}")
alertcondition(dnSB, "Valid Range SB - Downtrend", "Valid Range with Structure Break (DOWN) on {{ticker}} {{interval}}")
alertcondition(upStart, "Valid setup started - Uptrend", "Valid Range pullback started (UP) on {{ticker}} {{interval}}")
alertcondition(dnStart, "Valid setup started - Downtrend", "Valid Range pullback started (DOWN) on {{ticker}} {{interval}}")

// =============================================================================
// MTF SCREENER
// Runs both formations on each selected timeframe and reports the state as of
// the LAST CLOSED bar of that timeframe (non-repainting).
//
// Tuple per TF: [upSt, upLvl, upStrong, upCode, dnSt, dnLvl, dnStrong, dnCode]
//   St     : 0 none | 1/2/3 = Formation 1/2/3 pullback in progress
//   Lvl    : price that must break to confirm the SB (while pullback in progress)
//   Strong : Strong Low (up) / Strong High (down) of the latest confirmed SB
//   Code   : bars-since-latest-SB * 8 + formation (1, 2 or 3) + 4 if the SB candle closed beyond the level; na if none yet
// =============================================================================
f_screen(int tfS, int minS, bool reqWick, bool brkClose, bool invalidate, int maxPb,
     bool useF1, bool useF2, bool useF3, float eqTol) =>
    var VRState u1 = VRState.new()
    var VRState u2 = VRState.new()
    var VRState u3 = VRState.new()
    var VRState d1 = VRState.new()
    var VRState d2 = VRState.new()
    var VRState d3 = VRState.new()
    var float upStrong = na
    var int   upSbBar  = na
    var int   upForm   = 0
    var bool  upCls    = false
    var float dnStrong = na
    var int   dnSbBar  = na
    var int   dnForm   = 0
    var bool  dnCls    = false

    int rU1 = u1.advance(high, low, close, open, high[1], low[1], close[1], open[1], 1,
         reqWick, brkClose, invalidate, maxPb, minS, tfS, eqTol)
    int rU2 = u2.advance(high, low, close, open, high[1], low[1], close[1], open[1], 2,
         reqWick, brkClose, invalidate, maxPb, minS, tfS, eqTol)
    int rU3 = u3.advance(high, low, close, open, high[1], low[1], close[1], open[1], 3,
         reqWick, brkClose, invalidate, maxPb, minS, tfS, eqTol)
    int rD1 = d1.advance(-low, -high, -close, -open, -low[1], -high[1], -close[1], -open[1], 1,
         reqWick, brkClose, invalidate, maxPb, minS, tfS, eqTol)
    int rD2 = d2.advance(-low, -high, -close, -open, -low[1], -high[1], -close[1], -open[1], 2,
         reqWick, brkClose, invalidate, maxPb, minS, tfS, eqTol)
    int rD3 = d3.advance(-low, -high, -close, -open, -low[1], -high[1], -close[1], -open[1], 3,
         reqWick, brkClose, invalidate, maxPb, minS, tfS, eqTol)

    // confirmed SB events (higher formation number wins if several fire on the same bar)
    if useF1 and rU1 == 2
        upStrong := u1.pbLo
        upSbBar  := bar_index
        upForm   := 1
        upCls    := u1.sbCls
    if useF2 and rU2 == 2
        upStrong := u2.pbLo
        upSbBar  := bar_index
        upForm   := 2
        upCls    := u2.sbCls
    if useF3 and rU3 == 2
        upStrong := u3.pbLo
        upSbBar  := bar_index
        upForm   := 3
        upCls    := u3.sbCls
    if useF1 and rD1 == 2
        dnStrong := -d1.pbLo
        dnSbBar  := bar_index
        dnForm   := 1
        dnCls    := d1.sbCls
    if useF2 and rD2 == 2
        dnStrong := -d2.pbLo
        dnSbBar  := bar_index
        dnForm   := 2
        dnCls    := d2.sbCls
    if useF3 and rD3 == 2
        dnStrong := -d3.pbLo
        dnSbBar  := bar_index
        dnForm   := 3
        dnCls    := d3.sbCls

    // pullbacks still in progress after this bar
    bool pU1 = useF1 and u1.active and rU1 != 2 and rU1 != -1
    bool pU2 = useF2 and u2.active and rU2 != 2 and rU2 != -1
    bool pU3 = useF3 and u3.active and rU3 != 2 and rU3 != -1
    bool pD1 = useF1 and d1.active and rD1 != 2 and rD1 != -1
    bool pD2 = useF2 and d2.active and rD2 != 2 and rD2 != -1
    bool pD3 = useF3 and d3.active and rD3 != 2 and rD3 != -1
    int   upSt  = pU1 ? 1 : pU2 ? 2 : pU3 ? 3 : 0
    int   dnSt  = pD1 ? 1 : pD2 ? 2 : pD3 ? 3 : 0
    float upLvl = pU1 ? u1.sbLvl : pU2 ? u2.sbLvl : pU3 ? u3.sbLvl : na
    float dnLvl = pD1 ? -d1.sbLvl : pD2 ? -d2.sbLvl : pD3 ? -d3.sbLvl : na

    if rU1 == 2 or rU1 == -1
        u1.wipe()
    if rU2 == 2 or rU2 == -1
        u2.wipe()
    if rU3 == 2 or rU3 == -1
        u3.wipe()
    if rD1 == 2 or rD1 == -1
        d1.wipe()
    if rD2 == 2 or rD2 == -1
        d2.wipe()
    if rD3 == 2 or rD3 == -1
        d3.wipe()

    int upCode = na(upSbBar) ? na : (bar_index - upSbBar) * 8 + upForm + (upCls ? 4 : 0)
    int dnCode = na(dnSbBar) ? na : (bar_index - dnSbBar) * 8 + dnForm + (dnCls ? 4 : 0)
    [upSt, upLvl, upStrong, upCode, dnSt, dnLvl, dnStrong, dnCode]

// One bar back + lookahead_on = state of the last CLOSED bar of that timeframe.
f_screenConf(int tfS, int minS, bool reqWick, bool brkClose, bool invalidate, int maxPb,
     bool useF1, bool useF2, bool useF3, float eqTol) =>
    [a, b, c, d, e, f, g, h] = f_screen(tfS, minS, reqWick, brkClose, invalidate, maxPb, useF1, useF2, useF3, eqTol)
    [a[1], b[1], c[1], d[1], e[1], f[1], g[1], h[1]]

// ---- Table text helpers -----------------------------------------------------
// kind: 0 none | 1 old SB | 2 recent SB | 3 pullback in progress
f_status(int st, float lvl, int code, int recent, bool showCls) =>
    string txt = "-"
    int kind = 0
    if st > 0
        txt := "F" + str.tostring(st) + " PB " + (na(lvl) ? "-" : str.tostring(lvl, format.mintick))
        kind := 3
    else if not na(code)
        int age = int(code / 8)
        int form = code % 4
        bool cls = (code % 8) >= 4
        txt := "F" + str.tostring(form) + " SB" + (showCls ? (cls ? " C " : " W ") : " ") + (age == 0 ? "now" : str.tostring(age) + " ago")
        kind := age <= recent ? 2 : 1
    [txt, kind]

// Bias = whichever side confirmed an SB most recently.
f_bias(int upCode, int dnCode) =>
    string txt = "-"
    int dir = 0
    bool hasUp = not na(upCode)
    bool hasDn = not na(dnCode)
    int upAge = hasUp ? int(upCode / 8) : 0
    int dnAge = hasDn ? int(dnCode / 8) : 0
    if hasUp and (not hasDn or upAge < dnAge)
        txt := "▲ UP"
        dir := 1
    else if hasDn and (not hasUp or dnAge < upAge)
        txt := "▼ DOWN"
        dir := -1
    else if hasUp and hasDn
        txt := "MIXED"
    [txt, dir]

f_row(table t, int row, string tf, int uSt, float uLvl, float uStrong, int uCode,
     int dSt, float dLvl, float dStrong, int dCode, int recent, color upC, color dnC, string sz, bool showCls, bool inOv) =>
    [uTxt, uKind] = f_status(uSt, uLvl, uCode, recent, showCls)
    [dTxt, dKind] = f_status(dSt, dLvl, dCode, recent, showCls)
    [bTxt, bDir]  = f_bias(uCode, dCode)
    color txtC  = chart.fg_color
    color none  = color.new(color.gray, 100)
    color neut  = color.new(color.gray, 85)
    color uBg   = uKind == 3 ? color.new(color.orange, 70) : uKind == 2 ? color.new(upC, 70) : none
    color dBg   = dKind == 3 ? color.new(color.orange, 70) : dKind == 2 ? color.new(dnC, 70) : none
    color uTxtC = uKind == 1 ? color.gray : txtC
    color dTxtC = dKind == 1 ? color.gray : txtC
    table.cell(t, 0, row, f_tfLabel(tf), text_color=inOv ? txtC : color.gray, bgcolor=neut, text_size=sz)
    table.cell(t, 1, row, bTxt, text_color=bDir == 1 ? upC : bDir == -1 ? dnC : txtC, bgcolor=neut, text_size=sz)
    table.cell(t, 2, row, uTxt, text_color=uTxtC, bgcolor=uBg, text_size=sz)
    table.cell(t, 3, row, na(uStrong) ? "-" : str.tostring(uStrong, format.mintick), text_color=upC, bgcolor=none, text_size=sz)
    table.cell(t, 4, row, dTxt, text_color=dTxtC, bgcolor=dBg, text_size=sz)
    table.cell(t, 5, row, na(dStrong) ? "-" : str.tostring(dStrong, format.mintick), text_color=dnC, bgcolor=none, text_size=sz)
    bDir

// ---- One request per timeframe (each owns its own state) --------------------
int tfS1 = timeframe.in_seconds(i_tf1)
int tfS2 = timeframe.in_seconds(i_tf2)
int tfS3 = timeframe.in_seconds(i_tf3)
int tfS4 = timeframe.in_seconds(i_tf4)
int tfS5 = timeframe.in_seconds(i_tf5)
int tfS6 = timeframe.in_seconds(i_tf6)
int tfS7 = timeframe.in_seconds(i_tf7)
int tfS8 = timeframe.in_seconds(i_tf8)

[uS1, uL1, uK1, uC1, dS1, dL1, dK1, dC1] = request.security(syminfo.tickerid, i_tf1,
     f_screenConf(tfS1, f_minSec(tfS1), i_reqWick, brkOnClose, i_invalidate, i_maxPb, i_useF1, i_useF2, i_useF3, eqTol),
     barmerge.gaps_off, barmerge.lookahead_on)
[uS2, uL2, uK2, uC2, dS2, dL2, dK2, dC2] = request.security(syminfo.tickerid, i_tf2,
     f_screenConf(tfS2, f_minSec(tfS2), i_reqWick, brkOnClose, i_invalidate, i_maxPb, i_useF1, i_useF2, i_useF3, eqTol),
     barmerge.gaps_off, barmerge.lookahead_on)
[uS3, uL3, uK3, uC3, dS3, dL3, dK3, dC3] = request.security(syminfo.tickerid, i_tf3,
     f_screenConf(tfS3, f_minSec(tfS3), i_reqWick, brkOnClose, i_invalidate, i_maxPb, i_useF1, i_useF2, i_useF3, eqTol),
     barmerge.gaps_off, barmerge.lookahead_on)
[uS4, uL4, uK4, uC4, dS4, dL4, dK4, dC4] = request.security(syminfo.tickerid, i_tf4,
     f_screenConf(tfS4, f_minSec(tfS4), i_reqWick, brkOnClose, i_invalidate, i_maxPb, i_useF1, i_useF2, i_useF3, eqTol),
     barmerge.gaps_off, barmerge.lookahead_on)
[uS5, uL5, uK5, uC5, dS5, dL5, dK5, dC5] = request.security(syminfo.tickerid, i_tf5,
     f_screenConf(tfS5, f_minSec(tfS5), i_reqWick, brkOnClose, i_invalidate, i_maxPb, i_useF1, i_useF2, i_useF3, eqTol),
     barmerge.gaps_off, barmerge.lookahead_on)
[uS6, uL6, uK6, uC6, dS6, dL6, dK6, dC6] = request.security(syminfo.tickerid, i_tf6,
     f_screenConf(tfS6, f_minSec(tfS6), i_reqWick, brkOnClose, i_invalidate, i_maxPb, i_useF1, i_useF2, i_useF3, eqTol),
     barmerge.gaps_off, barmerge.lookahead_on)
[uS7, uL7, uK7, uC7, dS7, dL7, dK7, dC7] = request.security(syminfo.tickerid, i_tf7,
     f_screenConf(tfS7, f_minSec(tfS7), i_reqWick, brkOnClose, i_invalidate, i_maxPb, i_useF1, i_useF2, i_useF3, eqTol),
     barmerge.gaps_off, barmerge.lookahead_on)
[uS8, uL8, uK8, uC8, dS8, dL8, dK8, dC8] = request.security(syminfo.tickerid, i_tf8,
     f_screenConf(tfS8, f_minSec(tfS8), i_reqWick, brkOnClose, i_invalidate, i_maxPb, i_useF1, i_useF2, i_useF3, eqTol),
     barmerge.gaps_off, barmerge.lookahead_on)

// ---- Table ------------------------------------------------------------------
var table scr = table.new(i_tblPos, 6, 10, border_width=1,
     border_color=color.new(color.gray, 60), frame_width=1, frame_color=color.new(color.gray, 40))

if barstate.islast and i_showTbl
    color hdr = color.new(color.gray, 70)
    table.cell(scr, 0, 0, "TF",         text_color=chart.fg_color, bgcolor=hdr, text_size=i_tblSize)
    table.cell(scr, 1, 0, "Bias",       text_color=chart.fg_color, bgcolor=hdr, text_size=i_tblSize)
    table.cell(scr, 2, 0, "Uptrend",    text_color=i_upClr,        bgcolor=hdr, text_size=i_tblSize)
    table.cell(scr, 3, 0, "Strong Low", text_color=i_upClr,        bgcolor=hdr, text_size=i_tblSize)
    table.cell(scr, 4, 0, "Downtrend",  text_color=i_dnClr,        bgcolor=hdr, text_size=i_tblSize)
    table.cell(scr, 5, 0, "Strong High", text_color=i_dnClr,       bgcolor=hdr, text_size=i_tblSize)

    int row = 1
    bool showCls = i_sbMode == "Both"
    array<int> dirs = array.new<int>()
    if i_on1
        int ovDir1 = f_row(scr, row, i_tf1, uS1, uL1, uK1, uC1, dS1, dL1, dK1, dC1, i_recent, i_upClr, i_dnClr, i_tblSize, showCls, i_ov1)
        if i_ov1
            dirs.push(ovDir1)
        row += 1
    if i_on2
        int ovDir2 = f_row(scr, row, i_tf2, uS2, uL2, uK2, uC2, dS2, dL2, dK2, dC2, i_recent, i_upClr, i_dnClr, i_tblSize, showCls, i_ov2)
        if i_ov2
            dirs.push(ovDir2)
        row += 1
    if i_on3
        int ovDir3 = f_row(scr, row, i_tf3, uS3, uL3, uK3, uC3, dS3, dL3, dK3, dC3, i_recent, i_upClr, i_dnClr, i_tblSize, showCls, i_ov3)
        if i_ov3
            dirs.push(ovDir3)
        row += 1
    if i_on4
        int ovDir4 = f_row(scr, row, i_tf4, uS4, uL4, uK4, uC4, dS4, dL4, dK4, dC4, i_recent, i_upClr, i_dnClr, i_tblSize, showCls, i_ov4)
        if i_ov4
            dirs.push(ovDir4)
        row += 1
    if i_on5
        int ovDir5 = f_row(scr, row, i_tf5, uS5, uL5, uK5, uC5, dS5, dL5, dK5, dC5, i_recent, i_upClr, i_dnClr, i_tblSize, showCls, i_ov5)
        if i_ov5
            dirs.push(ovDir5)
        row += 1
    if i_on6
        int ovDir6 = f_row(scr, row, i_tf6, uS6, uL6, uK6, uC6, dS6, dL6, dK6, dC6, i_recent, i_upClr, i_dnClr, i_tblSize, showCls, i_ov6)
        if i_ov6
            dirs.push(ovDir6)
        row += 1
    if i_on7
        int ovDir7 = f_row(scr, row, i_tf7, uS7, uL7, uK7, uC7, dS7, dL7, dK7, dC7, i_recent, i_upClr, i_dnClr, i_tblSize, showCls, i_ov7)
        if i_ov7
            dirs.push(ovDir7)
        row += 1
    if i_on8
        int ovDir8 = f_row(scr, row, i_tf8, uS8, uL8, uK8, uC8, dS8, dL8, dK8, dC8, i_recent, i_upClr, i_dnClr, i_tblSize, showCls, i_ov8)
        if i_ov8
            dirs.push(ovDir8)
        row += 1

    if i_showOverall
        int nUp = 0
        int nDn = 0
        for d in dirs
            if d == 1
                nUp += 1
            else if d == -1
                nDn += 1
        bool bull = nUp > nDn
        bool bear = nDn > nUp
        string ovTxt = (bull ? "OVERALL: BULLISH" : bear ? "OVERALL: BEARISH" : "OVERALL: NEUTRAL") +
             "  (" + str.tostring(nUp) + "▲ " + str.tostring(nDn) + "▼ of " + str.tostring(dirs.size()) + " TFs)"
        color ovBg = bull ? color.new(i_upClr, 20) : bear ? color.new(i_dnClr, 20) : color.new(color.gray, 40)
        table.cell(scr, 0, row, ovTxt, text_color=color.white, bgcolor=ovBg, text_size=i_tblSize)
        table.merge_cells(scr, 0, row, 5, row)
````
