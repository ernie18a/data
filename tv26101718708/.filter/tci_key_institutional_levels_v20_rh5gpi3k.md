# TCI Key Institutional Levels v2.0

- url: https://www.tradingview.com/script/rh5Gpi3k-TCI-Key-Institutional-Levels-v2-0/
- type: indicator
- pine_id: PUB;ac237740e2284a80955730e33c49c318
- version: 2.0

## Description

TCI Key Institutional Levels v2.0 [Pine Script v6]
Overview
TCI Key Institutional Levels v2.0 is a comprehensive technical analysis tool designed to automate the identification of market structure, liquidity zones, and supply/demand imbalances. Written in the latest Pine Script v6, this indicator focuses on high-probability "Institutional" footprints, providing traders with a clean, real-time map of market intent.

Core Features

Dual Structure Tracking: The script tracks both Internal Structure (short-term shifts) and Swing Structure (long-term trend). It automatically identifies Break of Structure (BOS) and Change of Character (CHoCH), labeled here as "Breakers" and "Traps" to highlight potential liquidity grabs.

Dynamic Order Blocks (OB): Identifies the specific candles where institutional buying or selling occurred. These zones are automatically mitigated (removed) once price reclaims the level, ensuring your chart stays relevant.

Fair Value Gaps (FVG): Detects price imbalances using a multi-timeframe approach. It includes an Auto-Threshold feature that filters out insignificant gaps based on recent volatility.

Institutional Highs/Lows: Highlights "Strong" and "Weak" highs and lows. A "Strong" level is one that successfully led to a break in structure, while a "Weak" level is a target for future price runs.

MTF Levels: Optionally plot Previous Daily, Weekly, and Monthly Highs/Lows to see where your current timeframe sits within the higher-order liquidity cycle.

Premium & Discount Zones: Automatically calculates the equilibrium of the current swing, helping traders avoid "buying the top" or "selling the bottom."

How to Use

Trend Alignment: Look for the "Institutional Buying" or "Selling" labels to determine the dominant swing bias.

Entry Zones: Seek confluence between Discount zones and Bullish Order Blocks for long entries, or Premium zones and Bearish Order Blocks for short entries.

Liquidity Targets: Use Equal Highs/Lows (Double Tops/Bottoms) as potential "magnet" levels where stops may be resting.

Technical Note
This script is a modernized derivative of the Smart Money Concepts framework. It has been optimized for Pine Script v6 to improve calculation speed and label management.

Disclaimer
Past performance is not indicative of future results. This tool is for educational purposes and manual technical analysis. Trading involves significant risk.

## Source Code

````pine
//@version=6
indicator('TCI Key Institutional Levels v2.0',
     overlay            = true,
     max_labels_count   = 500,
     max_lines_count    = 500,
     max_boxes_count    = 500)

// ─────────────────────────────────────────────────────────────────
// CONSTANTS
// ─────────────────────────────────────────────────────────────────

int   BULL      = 1
int   BEAR      = -1

color C_GREEN   = #089981
color C_RED     = #F23645
color C_BLUE    = #2157f3
color C_GRAY    = #878b94

string HISTORICAL = 'Historical'
string PRESENT    = 'Present'
string COLORED    = 'Colored'
string MONOCHROME = 'Monochrome'
string ALL        = 'All'
string BREAKER    = 'Breaker'
string TRAP       = 'Trap'
string ATR_F      = 'Atr'
string RANGE_F    = 'Cumulative Mean Range'
string CLOSE_M    = 'Close'
string HIGHLOW_M  = 'High/Low'
string SOLID      = '⎯⎯⎯'
string DASHED     = '----'
string DOTTED     = '····'

string GRP_SMART = 'Smart Money Concepts'
string GRP_INT   = 'Real Time Internal Structure'
string GRP_SWING = 'Real Time Swing Structure'
string GRP_OB    = 'Order Blocks'
string GRP_EQ    = 'Double High/Double LOW'
string GRP_FVG   = 'Fair Value Gaps'
string GRP_LVL   = 'Highs & Lows MTF'
string GRP_ZONE  = 'Premium & Discount Zones'

// ─────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────

i_mode         = input.string(HISTORICAL, 'Mode',
     options   = [HISTORICAL, PRESENT],
     group     = GRP_SMART,
     tooltip   = 'Display historical structure or only recent ones')
i_style        = input.string(COLORED,   'Style',
     options   = [COLORED, MONOCHROME],
     group     = GRP_SMART,
     tooltip   = 'Indicator color theme')
i_colorCandles = input.bool(false, 'Color Candles',
     group     = GRP_SMART,
     tooltip   = 'Color candles by current trend direction')

i_showInternal = input.bool(true,  'Show Internal Structure', group = GRP_INT)
i_intBullFilt  = input.string(ALL, 'Bullish Structure',
     options   = [ALL, BREAKER, TRAP], group = GRP_INT, inline = 'ib')
i_intBullColor = input.color(C_GREEN, '', group = GRP_INT, inline = 'ib')
i_intBearFilt  = input.string(ALL, 'Bearish Structure',
     options   = [ALL, BREAKER, TRAP], group = GRP_INT, inline = 'ibr')
i_intBearColor = input.color(C_RED,   '', group = GRP_INT, inline = 'ibr')
i_intConfl     = input.bool(false, 'Confluence Filter',
     group     = GRP_INT,
     tooltip   = 'Filter non-significant internal structure breakouts')
i_intLblSz     = input.string(size.tiny, 'Internal Label Size',
     options   = [size.tiny, size.small, size.normal], group = GRP_INT)

i_showSwing    = input.bool(true,  'Show Swing Structure',    group = GRP_SWING)
i_swBullFilt   = input.string(ALL, 'Bullish Structure',
     options   = [ALL, BREAKER, TRAP], group = GRP_SWING, inline = 'sb')
i_swBullColor  = input.color(C_GREEN, '', group = GRP_SWING, inline = 'sb')
i_swBearFilt   = input.string(ALL, 'Bearish Structure',
     options   = [ALL, BREAKER, TRAP], group = GRP_SWING, inline = 'sbr')
i_swBearColor  = input.color(C_RED,   '', group = GRP_SWING, inline = 'sbr')
i_swLblSz      = input.string(size.small, 'Swing Label Size',
     options   = [size.tiny, size.small, size.normal], group = GRP_SWING)
i_showSwPts    = input.bool(false, 'Show Swing Points',
     group     = GRP_SWING, inline = 'sp')
i_swLength     = input.int(50, '', minval = 10, group = GRP_SWING, inline = 'sp')
i_showStrWeak  = input.bool(true, 'Show Strong/Supply Zone/Low',
     group     = GRP_SWING,
     tooltip   = 'Highlight most recent strong and weak high/low points')

i_showIntOB    = input.bool(true, 'Internal Order Blocks',
     group     = GRP_OB, inline = 'iob')
i_intOBCnt     = input.int(5, '', minval = 1, maxval = 20,
     group     = GRP_OB, inline = 'iob')
i_showSwOB     = input.bool(false, 'Swing Order Blocks',
     group     = GRP_OB, inline = 'sob')
i_swOBCnt      = input.int(5, '', minval = 1, maxval = 20,
     group     = GRP_OB, inline = 'sob')
i_obFilt       = input.string(ATR_F, 'Order Block Filter',
     options   = [ATR_F, RANGE_F], group = GRP_OB,
     tooltip   = 'Method to filter volatile order blocks')
i_obMit        = input.string(HIGHLOW_M, 'Order Block Mitigation',
     options   = [CLOSE_M, HIGHLOW_M], group = GRP_OB,
     tooltip   = 'Values used for order block mitigation')
i_intBullOBCol = input.color(color.new(#3179f5, 80), 'Internal Bullish OB', group = GRP_OB)
i_intBearOBCol = input.color(color.new(#f77c80, 80), 'Internal Bearish OB', group = GRP_OB)
i_swBullOBCol  = input.color(color.new(#1848cc, 80), 'Bullish OB',          group = GRP_OB)
i_swBearOBCol  = input.color(color.new(#b22833, 80), 'Bearish OB',          group = GRP_OB)

i_showEqHL     = input.bool(true, 'Equal High/Low', group = GRP_EQ)
i_eqLen        = input.int(3, 'Bars Confirmation', minval = 1, group = GRP_EQ,
     tooltip   = 'Bars to confirm equal highs/lows')
i_eqThresh     = input.float(0.1, 'Threshold',
     minval    = 0.0, maxval = 0.5, step = 0.1, group = GRP_EQ,
     tooltip   = 'Lower = fewer but stronger signals')
i_eqLblSz      = input.string(size.tiny, 'Label Size',
     options   = [size.tiny, size.small, size.normal], group = GRP_EQ)

i_showFVG      = input.bool(false, 'Fair Value Gaps',   group = GRP_FVG)
i_fvgAuto      = input.bool(true,  'Auto Threshold',    group = GRP_FVG)
i_fvgTF        = input.timeframe('', 'Timeframe',       group = GRP_FVG)
i_fvgBullCol   = input.color(color.new(#00ff68, 70), 'Bullish FVG', group = GRP_FVG)
i_fvgBearCol   = input.color(color.new(#ff0008, 70), 'Bearish FVG', group = GRP_FVG)
i_fvgExtend    = input.int(1, 'Extend FVG', minval = 0, group = GRP_FVG,
     tooltip   = 'Bars to extend FVG boxes')

i_showDaily    = input.bool(false, 'Daily',
     group     = GRP_LVL, inline = 'dl')
i_dailyStyle   = input.string(SOLID, '',
     options   = [SOLID, DASHED, DOTTED], group = GRP_LVL, inline = 'dl')
i_dailyCol     = input.color(C_BLUE, '', group = GRP_LVL, inline = 'dl')

i_showWeekly   = input.bool(false, 'Weekly',
     group     = GRP_LVL, inline = 'wk')
i_weeklyStyle  = input.string(SOLID, '',
     options   = [SOLID, DASHED, DOTTED], group = GRP_LVL, inline = 'wk')
i_weeklyCol    = input.color(C_BLUE, '', group = GRP_LVL, inline = 'wk')

i_showMonthly  = input.bool(false, 'Monthly',
     group     = GRP_LVL, inline = 'mo')
i_monthlyStyle = input.string(SOLID, '',
     options   = [SOLID, DASHED, DOTTED], group = GRP_LVL, inline = 'mo')
i_monthlyCol   = input.color(C_BLUE, '', group = GRP_LVL, inline = 'mo')

i_showZones    = input.bool(false, 'Premium/Discount Zones', group = GRP_ZONE)
i_premCol      = input.color(C_RED,   'Premium Zone',        group = GRP_ZONE)
i_equilCol     = input.color(C_GRAY,  'Equilibrium Zone',    group = GRP_ZONE)
i_discCol      = input.color(C_GREEN, 'Discount Zone',       group = GRP_ZONE)

// ─────────────────────────────────────────────────────────────────
// RESOLVED COLORS
// ─────────────────────────────────────────────────────────────────

swBullCol  = i_style == MONOCHROME ? color(#b2b5be) : i_swBullColor
swBearCol  = i_style == MONOCHROME ? color(#5d606b) : i_swBearColor
intBullCol = i_style == MONOCHROME ? color(#b2b5be) : i_intBullColor
intBearCol = i_style == MONOCHROME ? color(#5d606b) : i_intBearColor
fvgBullCol = i_style == MONOCHROME ? color.new(#b2b5be, 70) : i_fvgBullCol
fvgBearCol = i_style == MONOCHROME ? color.new(#5d606b, 70) : i_fvgBearCol
premCol    = i_style == MONOCHROME ? color(#5d606b) : i_premCol
discCol    = i_style == MONOCHROME ? color(#b2b5be) : i_discCol

// ─────────────────────────────────────────────────────────────────
// USER DEFINED TYPES
// ─────────────────────────────────────────────────────────────────

type PivotPoint
    float level     = na
    float prevLevel = na
    bool  used      = false
    int   t         = na
    int   idx       = na

type SwingExtremes
    float hi       = na
    float lo       = na
    int   hiTime   = na
    int   loTime   = na
    int   hiIdx    = na
    int   loIdx    = na
    int   lastTime = na
    int   lastIdx  = na

type TrendState
    int bias = 0

type FVGap
    float top  = na
    float bot  = na
    int   bias = 0
    box   bTop = na
    box   bBot = na

type OBlock
    float hi   = na
    float lo   = na
    int   t    = na
    int   bias = 0

type EqualDisplay
    line  ln = na
    label lb = na

type AlertSet
    bool intBullBreaker = false
    bool intBearBreaker = false
    bool intBullTrap    = false
    bool intBearTrap    = false
    bool swBullBreaker  = false
    bool swBearBreaker  = false
    bool swBullTrap     = false
    bool swBearTrap     = false
    bool intBullOB      = false
    bool intBearOB      = false
    bool swBullOB       = false
    bool swBearOB       = false
    bool eqHigh         = false
    bool eqLow          = false
    bool bullFVG        = false
    bool bearFVG        = false

// ─────────────────────────────────────────────────────────────────
// STATE VARIABLES
// ─────────────────────────────────────────────────────────────────

var PivotPoint    swHigh     = PivotPoint.new()
var PivotPoint    swLow      = PivotPoint.new()
var PivotPoint    intHigh    = PivotPoint.new()
var PivotPoint    intLow     = PivotPoint.new()
var PivotPoint    eqHi       = PivotPoint.new()
var PivotPoint    eqLo       = PivotPoint.new()
var TrendState    swTrend    = TrendState.new()
var TrendState    intTrend   = TrendState.new()
var EqualDisplay  eqHiDisp   = EqualDisplay.new()
var EqualDisplay  eqLoDisp   = EqualDisplay.new()
var SwingExtremes trailing   = SwingExtremes.new()
var array<FVGap>  fvgList    = array.new<FVGap>()
var array<OBlock> intOBList  = array.new<OBlock>()
var array<OBlock> swOBList   = array.new<OBlock>()
var array<box>    intOBBoxes = array.new<box>()
var array<box>    swOBBoxes  = array.new<box>()
var array<float>  allHighs   = array.new<float>()
var array<float>  allLows    = array.new<float>()
var array<float>  parsedHi   = array.new<float>()
var array<float>  parsedLo   = array.new<float>()
var array<int>    allTimes   = array.new<int>()
var int           chartStart = time

AlertSet curAlerts = AlertSet.new()

varip int curBarIdx  = bar_index
varip int prevBarIdx = bar_index

// ─────────────────────────────────────────────────────────────────
// VOLATILITY & BAR ARRAYS
// ─────────────────────────────────────────────────────────────────

baseATR    = ta.atr(200)
cumMeanRng = ta.cum(ta.tr) / bar_index
volMeasure = i_obFilt == ATR_F ? baseATR : cumMeanRng
hiVolBar   = (high - low) >= 2.0 * volMeasure
adjHi      = hiVolBar ? low  : high
adjLo      = hiVolBar ? high : low

parsedHi.push(adjHi)
parsedLo.push(adjLo)
allHighs.push(high)
allLows.push(low)
allTimes.push(time)

bearMitSrc = i_obMit == CLOSE_M ? close : high
bullMitSrc = i_obMit == CLOSE_M ? close : low

// ─────────────────────────────────────────────────────────────────
// INITIALISE OB DISPLAY BOXES
// ─────────────────────────────────────────────────────────────────

if barstate.isfirst
    if i_showSwOB
        for _i = 1 to i_swOBCnt
            swOBBoxes.push(box.new(na, na, na, na, xloc = xloc.bar_time, extend = extend.right))
    if i_showIntOB
        for _i = 1 to i_intOBCnt
            intOBBoxes.push(box.new(na, na, na, na, xloc = xloc.bar_time, extend = extend.right))

// ─────────────────────────────────────────────────────────────────
// HELPER — LINE STYLE RESOLVER
// ─────────────────────────────────────────────────────────────────

resolveStyle(string s) =>
    switch s
        SOLID  => line.style_solid
        DASHED => line.style_dashed
        DOTTED => line.style_dotted
        =>        line.style_solid

// ─────────────────────────────────────────────────────────────────
// HELPER — SWING POINT LABEL
// ─────────────────────────────────────────────────────────────────

drawSwingLabel(int t, float p, string txt, color c, string sty) =>
    var label lb = na
    if i_mode == PRESENT
        lb.delete()
    lb := label.new(chart.point.new(t, na, p), txt, xloc.bar_time,
         color     = color(na),
         textcolor = c,
         style     = sty,
         size      = size.small)

// ─────────────────────────────────────────────────────────────────
// HELPER — STRUCTURE LINE + LABEL
// ─────────────────────────────────────────────────────────────────

drawStructure(PivotPoint pp, string tag, color c, string ls, string lbs, string lbsz) =>
    var line  ln = line.new(na, na, na, na, xloc = xloc.bar_time)
    var label lb = label.new(na, na)
    if i_mode == PRESENT
        ln.delete()
        lb.delete()
    ln := line.new(chart.point.new(pp.t, na, pp.level), chart.point.new(time, na, pp.level),
         xloc.bar_time, color = c, style = ls)
    int midIdx = math.round(0.5 * (pp.idx + bar_index))
    lb := label.new(chart.point.new(na, midIdx, pp.level), tag, xloc.bar_index,
         color     = color(na),
         textcolor = c,
         style     = lbs,
         size      = lbsz)

// ─────────────────────────────────────────────────────────────────
// HELPER — EQUAL HIGH/LOW LINE + LABEL
// ─────────────────────────────────────────────────────────────────

drawEqualHL(PivotPoint pp, float lvl, int bk, bool isHigh) =>
    EqualDisplay disp = isHigh ? eqHiDisp : eqLoDisp
    string tag        = isHigh ? 'Double High'          : 'Double LOW'
    color  c          = isHigh ? swBearCol              : swBullCol
    string sty        = isHigh ? label.style_label_down : label.style_label_up
    if i_mode == PRESENT
        disp.ln.delete()
        disp.lb.delete()
    disp.ln := line.new(chart.point.new(pp.t, na, pp.level), chart.point.new(time[bk], na, lvl),
         xloc  = xloc.bar_time,
         color = c,
         style = line.style_dotted)
    int midIdx = math.round(0.5 * (pp.idx + bar_index - bk))
    disp.lb := label.new(chart.point.new(na, midIdx, lvl), tag, xloc.bar_index,
         color     = color(na),
         textcolor = c,
         style     = sty,
         size      = i_eqLblSz)

// ─────────────────────────────────────────────────────────────────
// HELPER — UPDATE TRAILING EXTREMES
// ─────────────────────────────────────────────────────────────────

updateTrailing() =>
    if na(trailing.hi) or high > trailing.hi
        trailing.hi     := high
        trailing.hiTime := time
        trailing.hiIdx  := bar_index
    if na(trailing.lo) or low < trailing.lo
        trailing.lo     := low
        trailing.loTime := time
        trailing.loIdx  := bar_index
    trailing.lastTime   := time
    trailing.lastIdx    := bar_index

// ─────────────────────────────────────────────────────────────────
// HELPER — STRONG / WEAK LEVEL LINES
// ─────────────────────────────────────────────────────────────────

drawStrongWeak() =>
    var line  hiLn = line.new(na, na, na, na, color = swBearCol, xloc = xloc.bar_time)
    var line  loLn = line.new(na, na, na, na, color = swBullCol, xloc = xloc.bar_time)
    var label hiLb = label.new(na, na,
         color = color(na), textcolor = swBearCol,
         xloc  = xloc.bar_time, style = label.style_label_down, size = size.tiny)
    var label loLb = label.new(na, na,
         color = color(na), textcolor = swBullCol,
         xloc  = xloc.bar_time, style = label.style_label_up,   size = size.tiny)
    int ext = last_bar_time + 20 * (time - time[1])
    hiLn.set_first_point( chart.point.new(trailing.hiTime, na, trailing.hi))
    hiLn.set_second_point(chart.point.new(ext,             na, trailing.hi))
    hiLb.set_point(       chart.point.new(ext,             na, trailing.hi))
    hiLb.set_text(swTrend.bias == BEAR ? 'Institutional Selling' : 'Supply Zone')
    loLn.set_first_point( chart.point.new(trailing.loTime, na, trailing.lo))
    loLn.set_second_point(chart.point.new(ext,             na, trailing.lo))
    loLb.set_point(       chart.point.new(ext,             na, trailing.lo))
    loLb.set_text(swTrend.bias == BULL ? 'Institutional Buying' : 'Demand Zone')

// ─────────────────────────────────────────────────────────────────
// HELPER — SINGLE ZONE BOX + LABEL
// ─────────────────────────────────────────────────────────────────

drawZone(float lblLvl, int lblIdx, float top, float bot, string tag, color c, string sty) =>
    var label lb = label.new(na, na, text = tag,
         color     = color(na),
         textcolor = c,
         style     = sty,
         size      = size.small)
    var box bx = box.new(na, na, na, na,
         bgcolor      = color.new(c, 80),
         border_color = color(na),
         xloc         = xloc.bar_time)
    bx.set_top_left_point(    chart.point.new(trailing.lastTime, na, top))
    bx.set_bottom_right_point(chart.point.new(last_bar_time,     na, bot))
    lb.set_point(chart.point.new(na, lblIdx, lblLvl))

// ─────────────────────────────────────────────────────────────────
// HELPER — PREMIUM / DISCOUNT / EQUILIBRIUM ZONES
// ─────────────────────────────────────────────────────────────────

drawPDZones() =>
    float rng = trailing.hi - trailing.lo
    float eq  = trailing.hi - rng * 0.5
    int   mid = math.round(0.5 * (trailing.lastIdx + last_bar_index))
    drawZone(trailing.hi, mid, trailing.hi, trailing.hi - rng * 0.05, 'Premium',     premCol,     label.style_label_down)
    drawZone(eq, last_bar_index, eq + rng * 0.025, eq - rng * 0.025,  'Equilibrium', i_equilCol,  label.style_label_left)
    drawZone(trailing.lo, mid, trailing.lo + rng * 0.05, trailing.lo, 'Discount',    discCol,     label.style_label_up)

// ─────────────────────────────────────────────────────────────────
// CORE — PIVOT DETECTION
// ─────────────────────────────────────────────────────────────────

detectPivots(int length, bool isInternal = false, bool isEqHL = false) =>
    bool newHigh = high[length] >= ta.highest(high, length + 1)[1]
    bool newLow  = low[length]  <= ta.lowest(low,   length + 1)[1]
    bool pivHigh = newHigh and not newLow
    bool pivLow  = newLow  and not newHigh

    if pivLow
        PivotPoint pp = na
        if isEqHL
            pp := eqLo
        else if isInternal
            pp := intLow
        else
            pp := swLow

        if isEqHL and not na(pp.level)
            if math.abs(pp.level - low[length]) < i_eqThresh * baseATR
                drawEqualHL(pp, low[length], length, false)
                curAlerts.eqLow := true

        pp.prevLevel := pp.level
        pp.level     := low[length]
        pp.used      := false
        pp.t         := time[length]
        pp.idx       := bar_index - length

        if not isEqHL and not isInternal
            trailing.lo     := na(trailing.lo) ? pp.level : math.min(trailing.lo, pp.level)
            trailing.loTime := pp.t
            trailing.loIdx  := pp.idx

        if i_showSwPts and not isInternal and not isEqHL
            drawSwingLabel(pp.t, pp.level,
                 not na(pp.prevLevel) and pp.level < pp.prevLevel ? 'LL' : 'HL',
                 swBullCol, label.style_label_up)

    if pivHigh
        PivotPoint pp = na
        if isEqHL
            pp := eqHi
        else if isInternal
            pp := intHigh
        else
            pp := swHigh

        if isEqHL and not na(pp.level)
            if math.abs(pp.level - high[length]) < i_eqThresh * baseATR
                drawEqualHL(pp, high[length], length, true)
                curAlerts.eqHigh := true

        pp.prevLevel := pp.level
        pp.level     := high[length]
        pp.used      := false
        pp.t         := time[length]
        pp.idx       := bar_index - length

        if not isEqHL and not isInternal
            trailing.hi     := na(trailing.hi) ? pp.level : math.max(trailing.hi, pp.level)
            trailing.hiTime := pp.t
            trailing.hiIdx  := pp.idx

        if i_showSwPts and not isInternal and not isEqHL
            drawSwingLabel(pp.t, pp.level,
                 not na(pp.prevLevel) and pp.level > pp.prevLevel ? 'HH' : 'LH',
                 swBearCol, label.style_label_down)

// ─────────────────────────────────────────────────────────────────
// CORE — STORE ORDER BLOCK
// KEY FIX: all multiline boolean expressions collapsed to single line
// ─────────────────────────────────────────────────────────────────

storeOB(PivotPoint pp, bool isInternal, int bias) =>
    bool eligible = (isInternal and i_showIntOB) or (not isInternal and i_showSwOB)
    if eligible
        array<float> src = bias == BEAR ? parsedHi : parsedLo
        int s  = pp.idx
        int e  = bar_index
        int sz = src.size()
        if e > s and s >= 0 and e <= sz
            array<float> slc = src.slice(s, e)
            if slc.size() > 0
                int rel = bias == BEAR ? slc.indexof(slc.max()) : slc.indexof(slc.min())
                int fi  = s + rel
                if fi >= 0 and fi < sz
                    float obHi = parsedHi.get(fi)
                    float obLo = parsedLo.get(fi)
                    int   obT  = allTimes.get(fi)
                    array<OBlock> lst = isInternal ? intOBList : swOBList
                    if lst.size() >= 100
                        lst.pop()
                    lst.unshift(OBlock.new(obHi, obLo, obT, bias))

// ─────────────────────────────────────────────────────────────────
// CORE — MITIGATE ORDER BLOCKS
// ─────────────────────────────────────────────────────────────────

mitigateOBs(bool isInternal) =>
    array<OBlock> lst = isInternal ? intOBList : swOBList
    int i = 0
    while i < lst.size()
        OBlock ob   = lst.get(i)
        bool broken = false
        if ob.bias == BEAR and bearMitSrc > ob.hi
            broken := true
            if isInternal
                curAlerts.intBearOB := true
            else
                curAlerts.swBearOB  := true
        else if ob.bias == BULL and bullMitSrc < ob.lo
            broken := true
            if isInternal
                curAlerts.intBullOB := true
            else
                curAlerts.swBullOB  := true
        if broken
            lst.remove(i)
            continue
        i += 1

// ─────────────────────────────────────────────────────────────────
// CORE — RENDER ORDER BLOCK BOXES
// ─────────────────────────────────────────────────────────────────

renderOBBoxes(bool isInternal) =>
    array<OBlock> lst   = isInternal ? intOBList  : swOBList
    array<box>    boxes = isInternal ? intOBBoxes : swOBBoxes
    int maxC  = isInternal ? i_intOBCnt : i_swOBCnt
    int drawC = math.min(maxC, lst.size())
    for i = 0 to drawC - 1
        OBlock ob = lst.get(i)
        box    bx = boxes.get(i)
        color obCol = na
        if i_style == MONOCHROME
            obCol := ob.bias == BEAR ? color.new(#5d606b, 80) : color.new(#b2b5be, 80)
        else if isInternal
            obCol := ob.bias == BEAR ? i_intBearOBCol : i_intBullOBCol
        else
            obCol := ob.bias == BEAR ? i_swBearOBCol  : i_swBullOBCol
        bx.set_top_left_point(    chart.point.new(ob.t,          na, ob.hi))
        bx.set_bottom_right_point(chart.point.new(last_bar_time, na, ob.lo))
        bx.set_bgcolor(obCol)
        bx.set_border_color(isInternal ? na : obCol)

// ─────────────────────────────────────────────────────────────────
// CORE — DETECT BOS / CHOCH STRUCTURE
// ─────────────────────────────────────────────────────────────────

detectStructure(bool isInternal) =>
    bool candleUp = true
    bool candleDn = true
    if i_intConfl and isInternal
        float uw = high - math.max(close, open)
        float lw = math.min(close, open) - low
        candleUp := uw > lw
        candleDn := uw < lw

    PivotPoint hiPP = isInternal ? intHigh : swHigh
    PivotPoint loPP = isInternal ? intLow  : swLow
    TrendState tr   = isInternal ? intTrend : swTrend
    string ls   = isInternal ? line.style_dashed : line.style_solid
    string lbsz = isInternal ? i_intLblSz : i_swLblSz

    // ── BULLISH BREAK ─────────────────────────────────────────
    bool hiDiff    = isInternal ? intHigh.level != swHigh.level : true
    bool bullBreak = not na(hiPP.level) and ta.crossover(close, hiPP.level) and not hiPP.used and hiDiff and candleUp
    if bullBreak
        string tag = tr.bias == BEAR ? TRAP : BREAKER
        if isInternal
            curAlerts.intBullTrap    := tag == TRAP
            curAlerts.intBullBreaker := tag == BREAKER
        else
            curAlerts.swBullTrap    := tag == TRAP
            curAlerts.swBullBreaker := tag == BREAKER
        hiPP.used := true
        tr.bias   := BULL
        color bc  = isInternal ? intBullCol : swBullCol
        bool show = false
        if isInternal
            show := i_showInternal and (i_intBullFilt == ALL or (i_intBullFilt == BREAKER and tag == BREAKER) or (i_intBullFilt == TRAP and tag == TRAP))
        else
            show := i_showSwing and (i_swBullFilt == ALL or (i_swBullFilt == BREAKER and tag == BREAKER) or (i_swBullFilt == TRAP and tag == TRAP))
        if show
            drawStructure(hiPP, tag, bc, ls, label.style_label_down, lbsz)
        bool storeIntOB = isInternal and i_showIntOB
        bool storeSwOB  = not isInternal and i_showSwOB
        if storeIntOB or storeSwOB
            storeOB(hiPP, isInternal, BULL)

    // ── BEARISH BREAK ─────────────────────────────────────────
    bool loDiff    = isInternal ? intLow.level != swLow.level : true
    bool bearBreak = not na(loPP.level) and ta.crossunder(close, loPP.level) and not loPP.used and loDiff and candleDn
    if bearBreak
        string tag = tr.bias == BULL ? TRAP : BREAKER
        if isInternal
            curAlerts.intBearTrap    := tag == TRAP
            curAlerts.intBearBreaker := tag == BREAKER
        else
            curAlerts.swBearTrap    := tag == TRAP
            curAlerts.swBearBreaker := tag == BREAKER
        loPP.used := true
        tr.bias   := BEAR
        color bc  = isInternal ? intBearCol : swBearCol
        bool show = false
        if isInternal
            show := i_showInternal and (i_intBearFilt == ALL or (i_intBearFilt == BREAKER and tag == BREAKER) or (i_intBearFilt == TRAP and tag == TRAP))
        else
            show := i_showSwing and (i_swBearFilt == ALL or (i_swBearFilt == BREAKER and tag == BREAKER) or (i_swBearFilt == TRAP and tag == TRAP))
        if show
            drawStructure(loPP, tag, bc, ls, label.style_label_up, lbsz)
        bool storeIntOB = isInternal and i_showIntOB
        bool storeSwOB  = not isInternal and i_showSwOB
        if storeIntOB or storeSwOB
            storeOB(loPP, isInternal, BEAR)

// ─────────────────────────────────────────────────────────────────
// CORE — FAIR VALUE GAPS
// ─────────────────────────────────────────────────────────────────

makeFVGBox(int lt, int rt, float top, float bot, color c) =>
    box.new(chart.point.new(lt, na, top), chart.point.new(rt + i_fvgExtend * (time - time[1]), na, bot),
         xloc = xloc.bar_time, border_color = c, bgcolor = c)

purgeFVGs() =>
    int i = 0
    while i < fvgList.size()
        FVGap g     = fvgList.get(i)
        bool filled = (g.bias == BULL and low < g.bot) or (g.bias == BEAR and high > g.top)
        if filled
            g.bTop.delete()
            g.bBot.delete()
            fvgList.remove(i)
            continue
        i += 1

detectFVGs() =>
    [c1, o1, t1, h0, l0, t0, h2, l2] = request.security(syminfo.tickerid, i_fvgTF,
         [close[1], open[1], time[1], high[0], low[0], time[0], high[2], low[2]],
         lookahead = barmerge.lookahead_on)
    float dp  = (c1 - o1) / (o1 * 100.0)
    bool  ntf = timeframe.change(i_fvgTF)
    float thr = i_fvgAuto ? ta.cum(math.abs(ntf ? dp : 0.0)) / bar_index * 2.0 : 0.0
    bool bullG = l0 > h2 and c1 > h2 and  dp >  thr and ntf
    bool bearG = h0 < l2 and c1 < l2 and -dp >  thr and ntf
    if bullG
        curAlerts.bullFVG := true
        float mid = math.avg(l0, h2)
        fvgList.unshift(FVGap.new(l0, h2, BULL,
             makeFVGBox(t1, t0, l0,  mid, fvgBullCol),
             makeFVGBox(t1, t0, mid, h2,  fvgBullCol)))
    if bearG
        curAlerts.bearFVG := true
        float mid = math.avg(h0, l2)
        fvgList.unshift(FVGap.new(h0, l2, BEAR,
             makeFVGBox(t1, t0, h0,  mid, fvgBearCol),
             makeFVGBox(t1, t0, mid, l2,  fvgBearCol)))

// ─────────────────────────────────────────────────────────────────
// CORE — MTF HIGH/LOW LEVELS
// ─────────────────────────────────────────────────────────────────

drawMTFLevel(string tf, bool sameTF, string lstyle, color c) =>
    [tfHi, tfLo, tfT, tfTN] = request.security(syminfo.tickerid, tf,
         [high[1], low[1], time[1], time], lookahead = barmerge.lookahead_on)
    float dHi = sameTF ? high : tfHi
    float dLo = sameTF ? low  : tfLo
    int   lT  = sameTF ? time : tfT
    int   rT  = sameTF ? time : tfTN
    int   hiT = time
    int   loT = time
    if not sameTF
        int li = allTimes.binary_search_rightmost(lT)
        int ri = allTimes.binary_search_rightmost(rT)
        array<int>   ts  = allTimes.slice(li, ri)
        array<float> hs  = allHighs.slice(li, ri)
        array<float> lss = allLows.slice(li, ri)
        if ts.size() > 0
            hiT := ts.get(hs.indexof(hs.max()))
            loT := ts.get(lss.indexof(lss.min()))
        else
            hiT := chartStart
            loT := chartStart
    var line  hiLn = line.new(na, na, na, na, xloc = xloc.bar_time, color = c, style = resolveStyle(lstyle))
    var line  loLn = line.new(na, na, na, na, xloc = xloc.bar_time, color = c, style = resolveStyle(lstyle))
    var label hiLb = label.new(na, na, xloc = xloc.bar_time, text = str.format('P{0}H', tf),
         color = color(na), textcolor = c, size = size.small, style = label.style_label_left)
    var label loLb = label.new(na, na, xloc = xloc.bar_time, text = str.format('P{0}L', tf),
         color = color(na), textcolor = c, size = size.small, style = label.style_label_left)
    int ext = last_bar_time + 20 * (time - time[1])
    hiLn.set_first_point( chart.point.new(hiT, na, dHi))
    hiLn.set_second_point(chart.point.new(ext, na, dHi))
    hiLb.set_point(       chart.point.new(ext, na, dHi))
    loLn.set_first_point( chart.point.new(loT, na, dLo))
    loLn.set_second_point(chart.point.new(ext, na, dLo))
    loLb.set_point(       chart.point.new(ext, na, dLo))

isHigherTF(string tf) => timeframe.in_seconds() > timeframe.in_seconds(tf)

// ─────────────────────────────────────────────────────────────────
// CANDLE COLORING
// ─────────────────────────────────────────────────────────────────

candleCol  = intTrend.bias == BULL ? swBullCol : swBearCol
parsedOpen = i_colorCandles ? open : na
plotcandle(parsedOpen, high, low, close,
     color = candleCol, wickcolor = candleCol, bordercolor = candleCol)

// ─────────────────────────────────────────────────────────────────
// EXECUTION FLOW
// ─────────────────────────────────────────────────────────────────

if i_showStrWeak or i_showZones
    updateTrailing()
    if i_showStrWeak
        drawStrongWeak()
    if i_showZones
        if not na(trailing.hi) and not na(trailing.lo) and not na(trailing.lastTime)
            drawPDZones()

if i_showFVG
    purgeFVGs()

detectPivots(i_swLength)
detectPivots(5, isInternal = true)

if i_showEqHL
    detectPivots(i_eqLen, isEqHL = true)

if i_showInternal or i_showIntOB or i_colorCandles
    detectStructure(true)

if i_showSwing or i_showSwOB or i_showStrWeak
    detectStructure(false)

if i_showIntOB
    mitigateOBs(true)

if i_showSwOB
    mitigateOBs(false)

if i_showFVG
    detectFVGs()

if barstate.islastconfirmedhistory or barstate.islast
    if i_showIntOB
        renderOBBoxes(true)
    if i_showSwOB
        renderOBBoxes(false)

prevBarIdx  := curBarIdx
curBarIdx   := bar_index
bool newBar  = curBarIdx != prevBarIdx

if barstate.islastconfirmedhistory or (barstate.isrealtime and newBar)
    if i_showDaily and not isHigherTF('D')
        drawMTFLevel('D', timeframe.isdaily,   i_dailyStyle,   i_dailyCol)
    if i_showWeekly and not isHigherTF('W')
        drawMTFLevel('W', timeframe.isweekly,  i_weeklyStyle,  i_weeklyCol)
    if i_showMonthly and not isHigherTF('M')
        drawMTFLevel('M', timeframe.ismonthly, i_monthlyStyle, i_monthlyCol)

// ─────────────────────────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────────────────────────

alertcondition(curAlerts.intBullBreaker, 'Internal Bullish Breaker',  'Internal Bullish Breaker formed')
alertcondition(curAlerts.intBullTrap,    'Internal Bullish Trap',     'Internal Bullish Trap formed')
alertcondition(curAlerts.intBearBreaker, 'Internal Bearish Breaker',  'Internal Bearish Breaker formed')
alertcondition(curAlerts.intBearTrap,    'Internal Bearish Trap',     'Internal Bearish Trap formed')
alertcondition(curAlerts.swBullBreaker,  'Bullish Breaker',           'Bullish Breaker formed')
alertcondition(curAlerts.swBullTrap,     'Bullish Trap',              'Bullish Trap formed')
alertcondition(curAlerts.swBearBreaker,  'Bearish Breaker',           'Bearish Breaker formed')
alertcondition(curAlerts.swBearTrap,     'Bearish Trap',              'Bearish Trap formed')
alertcondition(curAlerts.intBullOB,      'Bullish Internal OB Break', 'Price broke bullish internal OB')
alertcondition(curAlerts.intBearOB,      'Bearish Internal OB Break', 'Price broke bearish internal OB')
alertcondition(curAlerts.swBullOB,       'Bullish Swing OB Break',    'Price broke bullish swing OB')
alertcondition(curAlerts.swBearOB,       'Bearish Swing OB Break',    'Price broke bearish swing OB')
alertcondition(curAlerts.eqHigh,         'Equal Highs',               'Equal highs detected')
alertcondition(curAlerts.eqLow,          'Equal Lows',                'Equal lows detected')
alertcondition(curAlerts.bullFVG,        'Bullish FVG',               'Bullish FVG formed')
alertcondition(curAlerts.bearFVG,        'Bearish FVG',               'Bearish FVG formed')
````
