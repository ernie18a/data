# Zone Trading Indicator [Anupam Anand]

- url: https://www.tradingview.com/script/gyNahS0R-Zone-Trading-Indicator-Anupam-Anand/
- type: indicator
- pine_id: PUB;3e82aacd237b4eae86ee3378d6de9e9d
- version: 2.0

## Description

The strategy is based on a 3-candle structure:

1. Legin Candle → strong directional move into consolidation


2. Boring Candle → low-volatility base candle representing unfilled institutional orders


3. Legout Candle → explosive imbalance candle confirming institutional participation



The boring candle becomes the institutional supply/demand zone.


---

Candle Structure Requirements

1. Boring Candle (Base Candle)

This is the most important candle in the structure.

Requirements

True Range (TR) must be less than ATR

Small-range, low-volatility candle

Must contain upper and lower wicks

Preferably:

Green candle for Demand zones

Red candle for Supply zones


The candle should visually represent consolidation/absorption


Gap Requirement (Critical)

The boring candle must have an unfilled gap relative to the legout candle.

## Source Code

````pine
// ╔══════════════════════════════════════════════════════════════════════════╗
// ║        ZONE TRADING INDICATOR  —  by Anupam Anand                       ║
// ║        Institutional Supply & Demand Zones via LBL Methodology          ║
// ║        Pine Script v6  |  Non-Repainting  |  TradingView Ready          ║
// ╚══════════════════════════════════════════════════════════════════════════╝
//@version=6
indicator("Zone Trading Indicator [Anupam Anand]",
     overlay          = true,
     max_boxes_count  = 500,
     max_labels_count = 500,
     max_lines_count  = 200)

// ═══════════════════════════════════════════════════════════════════════════
// INPUT GROUP CONSTANTS
// ═══════════════════════════════════════════════════════════════════════════
string G1 = "⚡ LBL Candle Filters"
string G2 = "📦 Zone Construction"
string G3 = "🎨 Zone Colors"
string G4 = "♻️  Zone Lifecycle"
string G5 = "🎯 Entry Signals"
string G6 = "📊 Dashboard"

// ═══════════════════════════════════════════════════════════════════════════
// SECTION 1 — LBL CANDLE FILTER INPUTS
// ═══════════════════════════════════════════════════════════════════════════
i_atrLen          = input.int   (14,   "ATR Length",                                  group=G1)
i_boringATRMult   = input.float (1.0,  "Boring: Max True Range (× ATR)",              group=G1, step=0.1, minval=0.1)
i_leginBodyPct    = input.float (45.0, "Legin: Min Body % of Range",                  group=G1, step=1.0, minval=10.0, maxval=100.0)
i_leginRangeMult  = input.float (2.0,  "Legin: Min Range (× Boring)",                 group=G1, step=0.1, minval=1.0)
i_legoutLeginMult = input.float (2.0,  "Legout: Min Range (× Legin)",                 group=G1, step=0.1, minval=1.0)
i_legoutBoringMult= input.float (4.0,  "Legout: Min Range (× Boring)",                group=G1, step=0.5, minval=1.0)
i_useGap          = input.bool  (true, "Enable Gap Filter (Unfilled Gap Required)",   group=G1)

// ═══════════════════════════════════════════════════════════════════════════
// SECTION 2 — ZONE CONSTRUCTION INPUTS
// ═══════════════════════════════════════════════════════════════════════════
i_zoneMode  = input.string("Full Candle", "Zone Boundary Mode",
     options=["Full Candle", "Body Only", "Open to Extreme", "Wick Sensitive"],
     tooltip ="Full Candle = High→Low | Body Only = Open→Close | Open to Extreme = open to directional wick | Wick Sensitive = open-biased",
     group=G2)
i_maxZones  = input.int  (50,   "Max Active Zones",  minval=5, maxval=200,             group=G2)
i_extend    = input.bool (true, "Extend Zones Right",                                  group=G2)
i_showLabel = input.bool (true, "Show Zone Labels",                                    group=G2)
i_showScore = input.bool (true, "Show Strength Score in Label",                        group=G2)
i_showTouch = input.bool (true, "Show Touch Count in Label",                           group=G2)

// ═══════════════════════════════════════════════════════════════════════════
// SECTION 3 — COLOR INPUTS
// ═══════════════════════════════════════════════════════════════════════════
i_dFresh   = input.color(color.new(#00C853, 75), "Demand — Fresh",   group=G3)
i_dTested  = input.color(color.new(#00C853, 88), "Demand — Tested",  group=G3)
i_dInvalid = input.color(color.new(#4CAF50, 93), "Demand — Invalid", group=G3)
i_sFresh   = input.color(color.new(#D50000, 75), "Supply — Fresh",   group=G3)
i_sTested  = input.color(color.new(#D50000, 88), "Supply — Tested",  group=G3)
i_sInvalid = input.color(color.new(#F44336, 93), "Supply — Invalid", group=G3)
i_weekClr  = input.color(color.new(#FFD600, 40), "Border: 1-Week Old Zone",  group=G3)
i_monthClr = input.color(color.new(#FF6D00, 30), "Border: 1-Month Old Zone", group=G3)

// ═══════════════════════════════════════════════════════════════════════════
// SECTION 4 — ZONE LIFECYCLE INPUTS
// ═══════════════════════════════════════════════════════════════════════════
i_onInvalid    = input.string("Fade",  "On Invalidation",
     options=["Delete", "Fade", "Keep"],
     tooltip ="Delete removes zone | Fade grays it out | Keep leaves it unchanged",
     group=G4)
i_minAge       = input.int  (0,    "Min Zone Age Before Showing (bars)", minval=0,      group=G4)
i_showWeekOld  = input.bool (true, "Highlight 1-Week-Old Untouched Zones",              group=G4)
i_showMonthOld = input.bool (true, "Highlight 1-Month-Old Untouched Zones",             group=G4)

// ═══════════════════════════════════════════════════════════════════════════
// SECTION 5 — ENTRY SIGNAL INPUTS
// ═══════════════════════════════════════════════════════════════════════════
i_showSig  = input.bool  (true,  "Show BUY / SELL Signals on Zone Entry",  group=G5)
i_reqConf  = input.bool  (false, "Require Reversal Candle Confirmation",   group=G5)
i_showSLTP = input.bool  (false, "Plot SL & TP Levels",                    group=G5)
i_rrRatio  = input.float (2.0,   "Risk : Reward Ratio", step=0.5, minval=0.5, group=G5)

// ═══════════════════════════════════════════════════════════════════════════
// SECTION 6 — DASHBOARD
// ═══════════════════════════════════════════════════════════════════════════
i_showDash = input.bool(true, "Show Stats Dashboard", group=G6)

// ═══════════════════════════════════════════════════════════════════════════
// CORE ATR
// ═══════════════════════════════════════════════════════════════════════════
float atr = ta.atr(i_atrLen)

// ═══════════════════════════════════════════════════════════════════════════
// CANDLE UTILITY FUNCTIONS
// ═══════════════════════════════════════════════════════════════════════════
f_range(h, l)          => h - l
f_body(o, c)           => math.abs(c - o)
f_bodyPct(o, c, h, l)  =>
    float r = f_range(h, l)
    r > 0 ? f_body(o, c) / r * 100.0 : 0.0

// ═══════════════════════════════════════════════════════════════════════════
// LBL BAR REFERENCES  (Non-Repainting: confirmed lookback only)
// ───────────────────────────────────────────────────────────────────────────
//  Legin  = bar[2]  (oldest of the 3)
//  Boring = bar[1]  (middle / base candle)
//  Legout = bar[0]  (current confirmed bar)
// Detection fires inside barstate.isconfirmed → zero repainting
// ═══════════════════════════════════════════════════════════════════════════

// — Boring Candle (bar[1]) —
float bH = high[1]
float bL = low[1]
float bO = open[1]
float bC = close[1]
float bRange      = f_range(bH, bL)
float bTR         = ta.tr[1]
bool  bBull       = bC >= bO
bool  bHasUpWick  = bBull ? bH > bC  : bH > bO
bool  bHasLowWick = bBull ? bL < bO  : bL < bC

// — Legin Candle (bar[2]) —
float lgH = high[2]
float lgL = low[2]
float lgO = open[2]
float lgC = close[2]
float lgRange    = f_range(lgH, lgL)
float lgBodyPct  = f_bodyPct(lgO, lgC, lgH, lgL)
bool  lgBull     = lgC >= lgO

// — Legout Candle (bar[0] — current, evaluated after close) —
float loRange = f_range(high, low)
bool  loBull  = close >= open

// ═══════════════════════════════════════════════════════════════════════════
// LBL STRUCTURE VALIDATION
// ═══════════════════════════════════════════════════════════════════════════

// Boring: low TR, must have both wicks
bool isBoring = (bTR < atr * i_boringATRMult) and bHasUpWick and bHasLowWick

// Legin: must be ≥ 2× boring, body ≥ 45%
bool isLegin  = (lgRange >= i_leginRangeMult * bRange) and (lgBodyPct >= i_leginBodyPct)

// Legout: must be ≥ 2× legin AND ≥ 4× boring
bool isLegout = (loRange >= i_legoutLeginMult * lgRange) and (loRange >= i_legoutBoringMult * bRange)

// Gap filter — unfilled gap between boring and legout (Max size = Legin range)
float demandGapSize = low  - bH
float supplyGapSize = bL   - high

bool gapDemand = (demandGapSize > 0) and (demandGapSize <= lgRange)
bool gapSupply = (supplyGapSize > 0) and (supplyGapSize <= lgRange)

bool gapOKD    = i_useGap ? gapDemand : true
bool gapOKS    = i_useGap ? gapSupply : true

// Complete LBL conditions
bool isLBL_Demand = isBoring and isLegin and isLegout and loBull       and gapOKD
bool isLBL_Supply = isBoring and isLegin and isLegout and (not loBull) and gapOKS

// — Pattern classification —
int demandPat = lgBull       ? 0 : 2   // 0=RBR, 2=DBR
int supplyPat = (not lgBull) ? 1 : 3   // 1=DBD, 3=RBD

// ═══════════════════════════════════════════════════════════════════════════
// ZONE ARRAYS  (parallel arrays simulate object storage)
// ═══════════════════════════════════════════════════════════════════════════
var float[] za_top     = array.new_float()
var float[] za_bot     = array.new_float()
var bool[]  za_bull    = array.new_bool()
var int[]   za_touches = array.new_int()
var int[]   za_birth   = array.new_int()
var bool[]  za_valid   = array.new_bool()
var bool[]  za_tested  = array.new_bool()
var float[] za_score   = array.new_float()
var int[]   za_pat     = array.new_int()
var box[]   za_box     = array.new_box()
var label[] za_lbl     = array.new_label()
var bool[]  za_sigSent = array.new_bool()

// ═══════════════════════════════════════════════════════════════════════════
// HELPER FUNCTIONS
// ═══════════════════════════════════════════════════════════════════════════

f_patName(int p) =>
    p == 0 ? "RBR" : p == 1 ? "DBD" : p == 2 ? "DBR" : "RBD"

// ─── FIX: declare return types explicitly for tuple functions ───
f_zoneBounds(bool isBull, float bO_, float bC_, float bH_, float bL_) =>
    float zt = na
    float zb = na
    if i_zoneMode == "Full Candle"
        zt := bH_
        zb := bL_
    else if i_zoneMode == "Body Only"
        zt := math.max(bO_, bC_)
        zb := math.min(bO_, bC_)
    else if i_zoneMode == "Open to Extreme"
        zt := isBull ? bH_ : math.max(bO_, bC_)
        zb := isBull ? math.min(bO_, bC_) : bL_
    else  // Wick Sensitive
        zt := isBull ? bH_ : bO_
        zb := isBull ? bO_ : bL_
    [zt, zb]

f_calcScore(float loRng, float lgRng, float bRng, bool hasGap, float gapSz) =>
    float denom = math.max(bRng, syminfo.mintick)
    float sc    = 30.0
    sc += math.min(loRng / denom / 6.0 * 30.0, 30.0)
    sc += math.min(lgRng / denom / 4.0 * 20.0, 20.0)
    if hasGap
        sc += math.min(gapSz / denom * 20.0, 20.0)
    math.min(sc, 100.0)

f_lblText(int pat, float sc, int touches, bool wk, bool mo) =>
    string s = f_patName(pat)
    if i_showScore
        s += "  " + str.tostring(math.round(sc)) + "%"
    if i_showTouch
        s += "  " + str.tostring(touches) + "T"
    if mo
        s += "  ★★"
    else if wk
        s += "  ★"
    s

f_barsPerWeek() =>
    int b = 5
    if   timeframe.isseconds
        b := int(7 * 24 * 3600 / timeframe.multiplier)
    else if timeframe.isminutes
        b := int(7 * 24 * 60   / timeframe.multiplier)
    else if timeframe.isdaily
        b := 5
    else if timeframe.isweekly
        b := 1
    else if timeframe.ismonthly
        b := 0
    else
        b := int(7 * 24 / math.max(timeframe.multiplier, 1))
    b

int barsPerWeek  = f_barsPerWeek()
int barsPerMonth = barsPerWeek * 4

// ═══════════════════════════════════════════════════════════════════════════
// CREATE ZONE FUNCTION
// ═══════════════════════════════════════════════════════════════════════════
f_createZone(float zt, float zb, bool isBull, int pat, float sc) =>
    if array.size(za_top) >= i_maxZones
        if array.size(za_box) > 0
            box.delete(array.shift(za_box))
        if array.size(za_lbl) > 0
            label.delete(array.shift(za_lbl))
        array.shift(za_top)
        array.shift(za_bot)
        array.shift(za_bull)
        array.shift(za_touches)
        array.shift(za_birth)
        array.shift(za_valid)
        array.shift(za_tested)
        array.shift(za_score)
        array.shift(za_pat)
        array.shift(za_sigSent)

    array.push(za_top,     zt)
    array.push(za_bot,     zb)
    array.push(za_bull,    isBull)
    array.push(za_touches, 0)
    array.push(za_birth,   bar_index)
    array.push(za_valid,   true)
    array.push(za_tested,  false)
    array.push(za_score,   sc)
    array.push(za_pat,     pat)
    array.push(za_sigSent, false)

    color bgClr = isBull ? i_dFresh : i_sFresh
    color bdClr = color.new(isBull ? #00C853 : #D50000, 45)
    box newBox  = box.new(
         left         = bar_index - 2,
         top          = zt,
         right        = bar_index,
         bottom       = zb,
         bgcolor      = bgClr,
         border_color = bdClr,
         border_width = 1,
         extend       = i_extend ? extend.right : extend.none)
    array.push(za_box, newBox)

    string lStyle = isBull ? label.style_label_up : label.style_label_down
    float  lY     = isBull ? zb : zt
    color  lClr   = color.new(isBull ? #00C853 : #D50000, 35)
    string lTxt   = i_showLabel ? f_patName(pat) + "  " + str.tostring(math.round(sc)) + "%" : ""
    label newLbl  = label.new(
         x         = bar_index,
         y         = lY,
         text      = lTxt,
         style     = lStyle,
         color     = lClr,
         textcolor = color.white,
         size      = size.tiny)
    array.push(za_lbl, newLbl)

// ═══════════════════════════════════════════════════════════════════════════
// DETECT NEW ZONES  (barstate.isconfirmed → strictly non-repainting)
// ═══════════════════════════════════════════════════════════════════════════
if barstate.isconfirmed
    // Declare once — if-blocks share scope in Pine v6 (CE10095 fix)
    float zt  = na
    float zb  = na
    float gSz = 0.0
    float sc  = 0.0
    if isLBL_Demand
        [zt, zb] = f_zoneBounds(true, bO, bC, bH, bL)
        gSz := i_useGap ? demandGapSize : 0.0
        sc  := f_calcScore(loRange, lgRange, bRange, i_useGap and gapDemand, gSz)
        f_createZone(zt, zb, true, demandPat, sc)
    if isLBL_Supply
        [zt, zb] = f_zoneBounds(false, bO, bC, bH, bL)
        gSz := i_useGap ? supplyGapSize : 0.0
        sc  := f_calcScore(loRange, lgRange, bRange, i_useGap and gapSupply, gSz)
        f_createZone(zt, zb, false, supplyPat, sc)

// ═══════════════════════════════════════════════════════════════════════════
// ZONE LIFECYCLE — UPDATE EVERY BAR
// ═══════════════════════════════════════════════════════════════════════════
int zCount = array.size(za_top)

if zCount > 0
    for i = 0 to zCount - 1
        float zt      = array.get(za_top,     i)
        float zb      = array.get(za_bot,     i)
        bool  isBull  = array.get(za_bull,    i)
        int   birth   = array.get(za_birth,   i)
        bool  valid   = array.get(za_valid,   i)
        bool  tested  = array.get(za_tested,  i)
        int   touches = array.get(za_touches, i)
        float sc      = array.get(za_score,   i)
        int   pat     = array.get(za_pat,     i)
        bool  sigSent = array.get(za_sigSent, i)
        box   zBox    = array.get(za_box,     i)
        label zLbl    = array.get(za_lbl,     i)

        int age = bar_index - birth

        // Skip until zone has matured past minimum age
        if age < i_minAge
            continue

        // ── Invalidation check ──
        if valid
            bool broken = isBull ? (close < zb) : (close > zt)
            if broken
                array.set(za_valid, i, false)
                if i_onInvalid == "Delete"
                    box.delete(zBox)
                    label.delete(zLbl)
                else if i_onInvalid == "Fade"
                    box.set_bgcolor(zBox, isBull ? i_dInvalid : i_sInvalid)
                    box.set_border_color(zBox, color.new(color.gray, 70))
                    if i_showLabel
                        label.set_text(zLbl, "✕ " + f_patName(pat))
                        label.set_color(zLbl, color.new(color.gray, 50))
                continue

        if not valid
            continue

        // ── Touch / retest tracking ──
        bool inZone = low <= zt and high >= zb
        if inZone and age > 0
            array.set(za_touches, i, touches + 1)
            touches := touches + 1
            if not tested
                array.set(za_tested, i, true)
                tested := true

        // ── Age flags (only for untouched zones) ──
        bool isWeekOld  = i_showWeekOld  and (age >= barsPerWeek)  and (touches == 0)
        bool isMonthOld = i_showMonthOld and (age >= barsPerMonth) and (touches == 0)

        // ── Box color update ──
        color bgClr = tested ? (isBull ? i_dTested : i_sTested) : (isBull ? i_dFresh : i_sFresh)
        color bdClr = isMonthOld ? i_monthClr : isWeekOld ? i_weekClr : color.new(isBull ? #00C853 : #D50000, 45)

        box.set_bgcolor(zBox,      bgClr)
        box.set_border_color(zBox, bdClr)

        // ── Label update ──
        if i_showLabel
            bool wk = isWeekOld and not isMonthOld
            label.set_text(zLbl, f_lblText(pat, sc, touches, wk, isMonthOld))

        // ── Entry signals ──
        if i_showSig and inZone and not sigSent and age > 0
            bool confOK = true
            if i_reqConf
                confOK := isBull ? (close > open) : (close < open)

            if confOK
                array.set(za_sigSent, i, true)
                float zHeight = zt - zb

                if isBull
                    label.new(bar_index, low,
                         text      = "▲ BUY",
                         style     = label.style_label_up,
                         color     = color.new(#00C853, 20),
                         textcolor = color.white,
                         size      = size.small)
                    if i_showSLTP
                        float sl = zb - zHeight * 0.1
                        float tp = zt + zHeight * i_rrRatio
                        line.new(bar_index, sl, bar_index + 20, sl,
                             color=color.red,   style=line.style_dashed, width=1)
                        line.new(bar_index, tp, bar_index + 20, tp,
                             color=color.green, style=line.style_dashed, width=1)
                else
                    label.new(bar_index, high,
                         text      = "▼ SELL",
                         style     = label.style_label_down,
                         color     = color.new(#D50000, 20),
                         textcolor = color.white,
                         size      = size.small)
                    if i_showSLTP
                        float sl = zt + zHeight * 0.1
                        float tp = zb - zHeight * i_rrRatio
                        line.new(bar_index, sl, bar_index + 20, sl,
                             color=color.red,   style=line.style_dashed, width=1)
                        line.new(bar_index, tp, bar_index + 20, tp,
                             color=color.green, style=line.style_dashed, width=1)

// ═══════════════════════════════════════════════════════════════════════════
// DASHBOARD
// ═══════════════════════════════════════════════════════════════════════════
var table dash = table.new(position.top_right, 2, 7,
     bgcolor      = color.new(color.black, 80),
     border_color = color.new(color.gray, 60),
     border_width = 1,
     frame_color  = color.new(color.gray, 50),
     frame_width  = 1)

if i_showDash
    int totalZ   = array.size(za_top)
    int demandZ  = 0
    int supplyZ  = 0
    int freshZ   = 0
    int testedZ  = 0
    int invalidZ = 0

    if totalZ > 0
        for i = 0 to totalZ - 1
            bool bull  = array.get(za_bull,  i)
            bool valid = array.get(za_valid, i)
            bool tst   = array.get(za_tested,i)
            if bull
                demandZ += 1
            else
                supplyZ += 1
            if not valid
                invalidZ += 1
            else if tst
                testedZ += 1
            else
                freshZ += 1

    // Header
    table.cell(dash, 0, 0, "Zone Trading",   text_color=color.white,            text_size=size.small, bgcolor=color.new(#1A237E, 30))
    table.cell(dash, 1, 0, "[Anupam Anand]", text_color=color.new(#FFD600, 0),  text_size=size.small, bgcolor=color.new(#1A237E, 30))
    // Rows
    table.cell(dash, 0, 1, "Total Zones",  text_color=color.silver,             text_size=size.tiny)
    table.cell(dash, 1, 1, str.tostring(totalZ),   text_color=color.white,      text_size=size.tiny)
    table.cell(dash, 0, 2, "Demand",       text_color=color.new(#00C853, 0),    text_size=size.tiny)
    table.cell(dash, 1, 2, str.tostring(demandZ),  text_color=color.white,      text_size=size.tiny)
    table.cell(dash, 0, 3, "Supply",       text_color=color.new(#D50000, 0),    text_size=size.tiny)
    table.cell(dash, 1, 3, str.tostring(supplyZ),  text_color=color.white,      text_size=size.tiny)
    table.cell(dash, 0, 4, "Fresh",        text_color=color.lime,               text_size=size.tiny)
    table.cell(dash, 1, 4, str.tostring(freshZ),   text_color=color.white,      text_size=size.tiny)
    table.cell(dash, 0, 5, "Tested",       text_color=color.orange,             text_size=size.tiny)
    table.cell(dash, 1, 5, str.tostring(testedZ),  text_color=color.white,      text_size=size.tiny)
    table.cell(dash, 0, 6, "Invalid",      text_color=color.new(color.gray, 20),text_size=size.tiny)
    table.cell(dash, 1, 6, str.tostring(invalidZ), text_color=color.white,      text_size=size.tiny)
````
