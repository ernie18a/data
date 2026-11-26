# OTE Wealth Multi-Timeframe [Din]

- url: https://www.tradingview.com/script/CmEDi9PI-OTE-Wealth-Multi-Timeframe-Din/
- type: indicator
- pine_id: PUB;b87a79572c0f4aaf892bf9ff2fd97621
- version: 1.0

## Description

OTE Wealth — Multi-Timeframe Fibo / ICT Optimal Trade Entry Map

Short description (for the script list):
Multi-timeframe Fibo / ICT OTE (Optimal Trade Entry) mapping tool with confirmed-swing detection, full zone lifecycle, and visual backtesting through unlimited historical zones.

Full description:

OTE Wealth maps the ICT Optimal Trade Entry retracement zone (0.618–0.886, with 0.705 as the primary sweet spot) across up to 5 independently configurable timeframes at once — see your current chart's OTE alongside 5m, 15m, 1H and 4H without switching charts or cluttering price action.

Detection, not guesswork. Impulse legs are anchored to confirmed pivots only (ta.pivothigh/ta.pivotlow), filtered by market structure break and/or ATR displacement so minor noise never becomes a zone. The leg anchor uses the deepest confirmed pullback between swings, not just the most recent pivot, so the fib is drawn from the true impulse rather than a fragment of it. Higher-timeframe data is pulled through request.security with lookahead_off and an optional one-bar confirmation shift — built to minimize repaint, accepting a small delay in exchange for zones that don't move once drawn.

Built for visual backtesting. Every OTE ever confirmed is retained — not just the current one — with its original swing anchors, sweet spot line, and label intact. Choose how history is kept: a fixed count per timeframe, a lookback in bars, or a lookback in days, with no upper limit. Scroll back through the chart and see exactly how price reacted to past zones, on every timeframe, at once.

Clean by design. Transparent fills, a prominent 0.705 line, right-side labels instead of clutter on old candles, and an automatic object-budget manager that keeps the most recent zones fully detailed while older ones gracefully fade to a simple shaded box — so a deep history never breaks the chart or exceeds TradingView's drawing limits.

Also included: 3 custom fib levels, configurable invalidation (close or wick beyond 0.886, with fade/delete/keep behavior), swing-point markers, and alerts for zone entry, sweet-spot touch, core-range entry, invalidation, and new zone creation — with timeframe and direction included in the alert message.

This is a mapping tool, not a signal generator — it shows you where OTE zones are, not when to trade them.

## Source Code

````pine
//@version=6
indicator("OTE Wealth", "OTE Wealth", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500, max_bars_back = 500)

// ===========================================================================
//  OTE Wealth - Multi-Timeframe ICT Optimal Trade Entry (OTE) map
// ---------------------------------------------------------------------------
//  Detection : confirmed ta.pivothigh / ta.pivotlow swings evaluated INSIDE
//              each requested timeframe. The impulse anchor is the DEEPEST
//              confirmed pullback pivot between the previous swing and the new
//              one, not merely the most recent pivot, so a leg that runs
//              through several minor pivots is measured end to end.
//  Filters   : market structure break (BOS) and / or ATR displacement.
//  MTF       : request.security(..., lookahead = barmerge.lookahead_off) plus
//              an optional one bar shift of the returned state, which makes
//              the higher timeframe value strictly historical.
//  History   : every OTE ever confirmed is retained - with its original swing
//              anchors, sweet spot and label - under a retention rule of zone
//              count, lookback bars or lookback days, so past setups can be
//              scrolled back to and visually backtested.
//  Objects   : drawings are rebuilt on the last bar only, NEWEST ZONE FIRST,
//              under a hard per type object budget. When the budget runs out
//              the OLDEST zones lose detail first, never the current ones.
// ===========================================================================

const string GD = "OTE Detection"
const string G1 = "Timeframe 1"
const string G2 = "Timeframe 2"
const string G3 = "Timeframe 3"
const string G4 = "Timeframe 4"
const string G5 = "Timeframe 5"
const string GF = "Fibonacci Levels"
const string GH = "Historical Zones / Backtesting"
const string GS = "Swing Points"
const string GV = "Visual"
const string GA = "Alerts"

// TradingView hard caps each drawing type at 500. Stay just under so a late
// push can never be silently dropped by the engine.
const int MAXOBJ  = 495
// absolute per timeframe retention ceiling, protects memory when a lookback
// rule would otherwise let the store grow without bound
const int SAFECAP = 500

// ---------------------------------------------------------------------------
//  OTE detection inputs
// ---------------------------------------------------------------------------
string methodStr = input.string("Structure + Displacement", "Swing detection method", options = ["Pivot only", "Structure (BOS)", "Displacement (ATR)", "Structure + Displacement"], group = GD, tooltip = "Pivot only      : any confirmed pivot pair becomes the leg.\nStructure (BOS) : the new pivot must break the previous swing in the same direction.\nDisplacement    : the leg must be at least 'Min impulse size' x ATR.\nBoth            : strictest, fewest and cleanest legs.")
int    pivLen     = input.int(5, "Pivot sensitivity (bars each side)", minval = 2, maxval = 50, group = GD, tooltip = "Bars required on each side of a swing before it is accepted. Higher = fewer, larger, later swings.")
int    atrLen     = input.int(14, "ATR length (displacement filter)", minval = 1, maxval = 200, group = GD)
float  atrMult    = input.float(1.5, "Min impulse size (x ATR)", minval = 0.0, maxval = 20.0, step = 0.1, group = GD)
int    minLegBars = input.int(3, "Min impulse length (bars)", minval = 1, maxval = 200, group = GD)
bool   deepAnchor = input.bool(true, "Anchor to deepest pullback", group = GD, tooltip = "ON  : the leg starts at the deepest confirmed pivot between the previous swing and the new one - measures the whole impulse.\nOFF : the leg starts at the most recent confirmed pivot - shorter, more reactive legs.")
bool   useConf    = input.bool(true, "Use confirmed HTF bars only (non repaint)", group = GD, tooltip = "Shifts the higher timeframe state by one closed HTF bar. Removes any flicker inside the forming HTF candle at the cost of one extra bar of delay.")
string invalRule  = input.string("Close", "Invalidate on", options = ["Close", "Wick"], group = GD)
string invalBeh   = input.string("Fade", "Invalid zone behavior", options = ["Fade", "Delete", "Keep"], group = GD, tooltip = "Fade   : keep the zone but drop its opacity (and dash the lines).\nDelete : remove the zone as soon as it is invalidated.\nKeep   : keep the zone with normal styling, frozen at the invalidation bar.\n\nFor visual backtesting use Fade or Keep - Delete throws the history away.")

// ---------------------------------------------------------------------------
//  Historical zones / backtesting
// ---------------------------------------------------------------------------
bool   histOn     = input.bool(true, "Show historical OTE zones", group = GH, tooltip = "Master switch for the whole backtesting history. OFF shows only the one live OTE per timeframe.")
string histMode   = input.string("Zones per timeframe", "Retention rule", options = ["Zones per timeframe", "Lookback bars", "Lookback days"], group = GH, tooltip = "Zones per timeframe : keep the N most recent OTEs of each timeframe (set N in each Timeframe group).\nLookback bars       : keep every OTE created within the last N chart bars.\nLookback days       : keep every OTE anchored within the last N days.")
int    histBars   = input.int(2000, "Historical lookback bars", minval = 1, group = GH, tooltip = "Used when the retention rule is 'Lookback bars'. Counted in bars of the CHART timeframe.")
int    histDays   = input.int(30, "Historical lookback days", minval = 1, group = GH, tooltip = "Used when the retention rule is 'Lookback days'. Measured from each zone's swing anchor.")
string histDetail = input.string("Zone + sweet spot + label", "Historical zone detail", options = ["Zone only", "Zone + sweet spot", "Zone + sweet spot + label", "Full (all fib levels)"], group = GH, tooltip = "How much of a past OTE is redrawn.\nEach step costs more chart objects, which is what limits how far back the history can reach - see 'Show budget readout'.")
bool   histSwing  = input.bool(true, "Keep original swing anchors", group = GH, tooltip = "Redraws the swing high / swing low markers that the past OTE was measured from, so you can see exactly which impulse produced it.")
bool   histLeg    = input.bool(false, "Keep impulse leg line", group = GH)
int    histSweetTr= input.int(40, "Historical sweet spot transparency", minval = 0, maxval = 100, group = GH, tooltip = "Kept separate from the general historical line transparency so the 0.705 of a past setup stays readable while the rest of the zone recedes.")
bool   histStatus = input.bool(false, "Show budget readout", group = GH, tooltip = "Small corner table: how many zones are stored, how many were actually drawn, and how much of the 500 object budget each type used. Turn on if history looks truncated.")

// ---------------------------------------------------------------------------
//  Timeframe inputs
// ---------------------------------------------------------------------------
bool   tf1On  = input.bool(true, "Enable", group = G1, inline = "t1")
string tf1Tf  = input.timeframe("1", "", group = G1, inline = "t1")
color  tf1Col = input.color(#42BDA8, "", group = G1, inline = "t1")
int    tf1Lb  = input.int(200, "Lookback (bars of this timeframe)", minval = 20, maxval = 5000, group = G1)
int    tf1N   = input.int(10, "Max historical zones", minval = 1, group = G1)
bool   tf1Lbl = input.bool(true, "Label", group = G1, inline = "s1")
bool   tf1Fib = input.bool(true, "Fib lines", group = G1, inline = "s1")
bool   tf1Zn  = input.bool(true, "Zone fill", group = G1, inline = "s1")

bool   tf2On  = input.bool(true, "Enable", group = G2, inline = "t2")
string tf2Tf  = input.timeframe("5", "", group = G2, inline = "t2")
color  tf2Col = input.color(#5B8DEF, "", group = G2, inline = "t2")
int    tf2Lb  = input.int(200, "Lookback (bars of this timeframe)", minval = 20, maxval = 5000, group = G2)
int    tf2N   = input.int(10, "Max historical zones", minval = 1, group = G2)
bool   tf2Lbl = input.bool(true, "Label", group = G2, inline = "s2")
bool   tf2Fib = input.bool(true, "Fib lines", group = G2, inline = "s2")
bool   tf2Zn  = input.bool(true, "Zone fill", group = G2, inline = "s2")

bool   tf3On  = input.bool(true, "Enable", group = G3, inline = "t3")
string tf3Tf  = input.timeframe("15", "", group = G3, inline = "t3")
color  tf3Col = input.color(#C77DFF, "", group = G3, inline = "t3")
int    tf3Lb  = input.int(200, "Lookback (bars of this timeframe)", minval = 20, maxval = 5000, group = G3)
int    tf3N   = input.int(10, "Max historical zones", minval = 1, group = G3)
bool   tf3Lbl = input.bool(true, "Label", group = G3, inline = "s3")
bool   tf3Fib = input.bool(true, "Fib lines", group = G3, inline = "s3")
bool   tf3Zn  = input.bool(true, "Zone fill", group = G3, inline = "s3")

bool   tf4On  = input.bool(true, "Enable", group = G4, inline = "t4")
string tf4Tf  = input.timeframe("60", "", group = G4, inline = "t4")
color  tf4Col = input.color(#F2A25C, "", group = G4, inline = "t4")
int    tf4Lb  = input.int(200, "Lookback (bars of this timeframe)", minval = 20, maxval = 5000, group = G4)
int    tf4N   = input.int(10, "Max historical zones", minval = 1, group = G4)
bool   tf4Lbl = input.bool(true, "Label", group = G4, inline = "s4")
bool   tf4Fib = input.bool(true, "Fib lines", group = G4, inline = "s4")
bool   tf4Zn  = input.bool(true, "Zone fill", group = G4, inline = "s4")

bool   tf5On  = input.bool(true, "Enable", group = G5, inline = "t5")
string tf5Tf  = input.timeframe("240", "", group = G5, inline = "t5")
color  tf5Col = input.color(#E5566D, "", group = G5, inline = "t5")
int    tf5Lb  = input.int(200, "Lookback (bars of this timeframe)", minval = 20, maxval = 5000, group = G5)
int    tf5N   = input.int(10, "Max historical zones", minval = 1, group = G5)
bool   tf5Lbl = input.bool(true, "Label", group = G5, inline = "s5")
bool   tf5Fib = input.bool(true, "Fib lines", group = G5, inline = "s5")
bool   tf5Zn  = input.bool(true, "Zone fill", group = G5, inline = "s5")

// ---------------------------------------------------------------------------
//  Fibonacci level inputs
// ---------------------------------------------------------------------------
bool  fAOn = input.bool(true, "", group = GF, inline = "fa")
float fA   = input.float(0.618, "Level A  (OTE start)", step = 0.001, minval = 0.0, maxval = 1.0, group = GF, inline = "fa")
bool  fBOn = input.bool(true, "", group = GF, inline = "fb")
float fB   = input.float(0.650, "Level B", step = 0.001, minval = 0.0, maxval = 1.0, group = GF, inline = "fb")
bool  fCOn = input.bool(true, "", group = GF, inline = "fc")
float fC   = input.float(0.705, "Level C  (sweet spot)", step = 0.001, minval = 0.0, maxval = 1.0, group = GF, inline = "fc")
bool  fDOn = input.bool(true, "", group = GF, inline = "fd")
float fD   = input.float(0.790, "Level D", step = 0.001, minval = 0.0, maxval = 1.0, group = GF, inline = "fd")
bool  fEOn = input.bool(true, "", group = GF, inline = "fe")
float fE   = input.float(0.886, "Level E  (deepest / invalidation)", step = 0.001, minval = 0.0, maxval = 1.0, group = GF, inline = "fe")

bool  c1On = input.bool(false, "", group = GF, inline = "c1")
float c1V  = input.float(0.500, "Custom Fib 1", step = 0.001, group = GF, inline = "c1")
bool  c1Ln = input.bool(true, "Line", group = GF, inline = "c1")
bool  c1Lb = input.bool(true, "Label", group = GF, inline = "c1")

bool  c2On = input.bool(false, "", group = GF, inline = "c2")
float c2V  = input.float(1.000, "Custom Fib 2", step = 0.001, group = GF, inline = "c2")
bool  c2Ln = input.bool(true, "Line", group = GF, inline = "c2")
bool  c2Lb = input.bool(true, "Label", group = GF, inline = "c2")

bool  c3On = input.bool(false, "", group = GF, inline = "c3")
float c3V  = input.float(0.000, "Custom Fib 3", step = 0.001, group = GF, inline = "c3")
bool  c3Ln = input.bool(true, "Line", group = GF, inline = "c3")
bool  c3Lb = input.bool(true, "Label", group = GF, inline = "c3")

// ---------------------------------------------------------------------------
//  Swing point inputs
// ---------------------------------------------------------------------------
bool   swShow  = input.bool(true, "Mark the swing points of each OTE", group = GS)
string swStyle = input.string("Dot", "Marker", options = ["Dot", "Triangle", "Diamond", "Cross", "Square"], group = GS)
string swSizeS = input.string("Tiny", "Marker size", options = ["Tiny", "Small", "Normal"], group = GS)
bool   swLeg   = input.bool(true, "Connect the swing points", group = GS, tooltip = "Draws a thin dotted line along the impulse leg, from the origin swing to the extreme that the retracement is measured from.")
bool   swPrice = input.bool(false, "Show swing prices", group = GS, tooltip = "Adds a price tag to each swing marker. Costs two extra labels per zone - the first thing to turn off when a deep history runs out of objects.")

// ---------------------------------------------------------------------------
//  Visual inputs
// ---------------------------------------------------------------------------
bool   zoneShow    = input.bool(true, "Show OTE zone fill (Level A to Level E)", group = GV)
int    zoneTransp  = input.int(90, "Zone transparency", minval = 0, maxval = 100, group = GV)
bool   innerShow   = input.bool(false, "Highlight inner zone", group = GV, inline = "iz")
string innerRange  = input.string("0.618 - 0.790", "", options = ["0.618 - 0.790", "0.650 - 0.790"], group = GV, inline = "iz")
int    innerTransp = input.int(82, "Inner zone transparency", minval = 0, maxval = 100, group = GV)

int    lineW       = input.int(1, "Line width", minval = 1, maxval = 4, group = GV)
int    lineW705    = input.int(2, "Sweet spot line width", minval = 1, maxval = 5, group = GV)
string lineStyleS  = input.string("Solid", "Line style", options = ["Solid", "Dashed", "Dotted"], group = GV)
int    lineTransp  = input.int(35, "Line transparency", minval = 0, maxval = 100, group = GV)
int    transp705   = input.int(0, "Sweet spot line transparency", minval = 0, maxval = 100, group = GV)
bool   use705Col   = input.bool(false, "Custom sweet spot color", group = GV, inline = "sc")
color  col705      = input.color(#FFD166, "", group = GV, inline = "sc")

int    invLineTr   = input.int(65, "Invalid / historical line transparency", minval = 0, maxval = 100, group = GV)
int    invZoneTr   = input.int(94, "Invalid / historical zone transparency", minval = 0, maxval = 100, group = GV)
bool   invalDash   = input.bool(true, "Dash lines when invalid", group = GV)

bool   showTFName  = input.bool(true, "Show timeframe name", group = GV, inline = "lb1")
bool   showDir     = input.bool(true, "Show bull / bear", group = GV, inline = "lb1")
bool   showFibVal  = input.bool(true, "Show fib value", group = GV, inline = "lb1")
bool   showLvlLbls = input.bool(false, "Label every fib level", group = GV)
string lblSizeS    = input.string("Small", "Label size", options = ["Tiny", "Small", "Normal", "Large"], group = GV)
bool   hideLower   = input.bool(true, "Hide timeframes below chart timeframe", group = GV)

string extS        = input.string("Extend Right", "Active zone extension", options = ["Current Price", "Extend Right", "Fixed Number of Bars"], group = GV)
int    extBars     = input.int(30, "Fixed bar count", minval = 1, maxval = 500, group = GV)

// ---------------------------------------------------------------------------
//  Alert inputs
// ---------------------------------------------------------------------------
bool alEnter = input.bool(true, "Price enters an OTE zone", group = GA)
bool alCore  = input.bool(true, "Price enters the core (A to D)", group = GA)
bool al705   = input.bool(true, "Price touches the sweet spot", group = GA)
bool alInval = input.bool(true, "OTE invalidated", group = GA)
bool alNew   = input.bool(true, "New OTE created", group = GA)

// ---------------------------------------------------------------------------
//  Derived settings
// ---------------------------------------------------------------------------
int  methodId = methodStr == "Pivot only" ? 1 : methodStr == "Structure (BOS)" ? 2 : methodStr == "Displacement (ATR)" ? 3 : 4
bool useWick  = invalRule == "Wick"
bool byCount  = histMode == "Zones per timeframe"
bool byBars   = histMode == "Lookback bars"

// upper bound of the inner / core band - shared by the drawing and the alert
// so the shaded box and the "core entered" alert can never disagree
float innerLo = innerRange == "0.650 - 0.790" ? fB : fA

lstyle  = lineStyleS == "Dashed" ? line.style_dashed : lineStyleS == "Dotted" ? line.style_dotted : line.style_solid
lblSize = lblSizeS == "Tiny" ? size.tiny : lblSizeS == "Normal" ? size.normal : lblSizeS == "Large" ? size.large : size.small
swSize  = swSizeS == "Small" ? size.small : swSizeS == "Normal" ? size.normal : size.tiny

swHiSty = swStyle == "Triangle" ? label.style_triangledown : swStyle == "Diamond" ? label.style_diamond : swStyle == "Cross" ? label.style_xcross : swStyle == "Square" ? label.style_square : label.style_circle
swLoSty = swStyle == "Triangle" ? label.style_triangleup : swStyle == "Diamond" ? label.style_diamond : swStyle == "Cross" ? label.style_xcross : swStyle == "Square" ? label.style_square : label.style_circle

int chartMs = timeframe.in_seconds() * 1000

f_tfName(simple string s) =>
    string r = s
    float  n = str.tonumber(s)
    if not na(n)
        int m = int(n)
        r := m >= 1440 and m % 1440 == 0 ? str.tostring(int(m / 1440)) + "D" : m >= 60 and m % 60 == 0 ? str.tostring(int(m / 60)) + "H" : str.tostring(m) + "m"
    r

// ---------------------------------------------------------------------------
//  Core detection - runs inside the requested timeframe context
// ---------------------------------------------------------------------------
//  A rolling window of the last PIVMEM confirmed pivots is kept on each side.
//  When a swing high confirms, the bullish leg origin is the LOWEST confirmed
//  pivot low recorded between the previous swing high and this one, so an
//  impulse that ran through several minor pivots is measured from its true
//  base. Falls back to the most recent pivot low when that window is empty.
// ---------------------------------------------------------------------------
const int PIVMEM = 40

f_ote(simple int pv, simple int lookback, simple int method, simple float aMult, simple int aLen, simple int minLeg, simple bool deep, simple bool confirmedOnly) =>
    var array<float> phV = array.new<float>()
    var array<int>   phB = array.new<int>()
    var array<int>   phT = array.new<int>()
    var array<float> plV = array.new<float>()
    var array<int>   plB = array.new<int>()
    var array<int>   plT = array.new<int>()

    var int   dir   = 0
    var float legHi = na
    var float legLo = na
    var int   legT1 = na
    var int   legT2 = na

    float atr = ta.atr(aLen)
    float ph  = ta.pivothigh(pv, pv)
    float pl  = ta.pivotlow(pv, pv)
    int   pb  = bar_index - pv
    int   pt  = time[pv]

    // ---- bullish leg : confirmed swing low -> confirmed swing high ----------
    if not na(ph)
        int   nH      = array.size(phB)
        float prevPHv = nH > 0 ? array.get(phV, nH - 1) : na
        int   prevPHb = nH > 0 ? array.get(phB, nH - 1) : na
        int   wStart  = na(prevPHb) ? pb - lookback : prevPHb

        float aLo  = na
        int   aLoB = na
        int   aLoT = na
        int   nL   = array.size(plB)
        if nL > 0
            if deep
                for q = 0 to nL - 1
                    int bq = array.get(plB, q)
                    if bq < pb and bq > wStart
                        float vq = array.get(plV, q)
                        if na(aLo) or vq < aLo
                            aLo  := vq
                            aLoB := bq
                            aLoT := array.get(plT, q)
            if na(aLo)
                for q = nL - 1 to 0
                    if na(aLo) and array.get(plB, q) < pb
                        aLo  := array.get(plV, q)
                        aLoB := array.get(plB, q)
                        aLoT := array.get(plT, q)

        bool geom = not na(aLo) and ph > aLo and (pb - aLoB) >= minLeg and (pb - aLoB) <= lookback and (bar_index - pb) <= lookback
        bool bos  = na(prevPHv) or ph > prevPHv
        bool disp = aMult <= 0 or na(atr) or (ph - aLo) >= aMult * atr
        bool ok   = method == 1 ? geom : method == 2 ? geom and bos : method == 3 ? geom and disp : geom and bos and disp

        if ok
            dir   := 1
            legHi := ph
            legLo := aLo
            legT1 := aLoT
            legT2 := pt

        array.push(phV, ph)
        array.push(phB, pb)
        array.push(phT, pt)
        if array.size(phV) > PIVMEM
            array.shift(phV)
            array.shift(phB)
            array.shift(phT)

    // ---- bearish leg : confirmed swing high -> confirmed swing low ----------
    if not na(pl)
        int   nL      = array.size(plB)
        float prevPLv = nL > 0 ? array.get(plV, nL - 1) : na
        int   prevPLb = nL > 0 ? array.get(plB, nL - 1) : na
        int   wStart  = na(prevPLb) ? pb - lookback : prevPLb

        float aHi  = na
        int   aHiB = na
        int   aHiT = na
        int   nH   = array.size(phB)
        if nH > 0
            if deep
                for q = 0 to nH - 1
                    int bq = array.get(phB, q)
                    if bq < pb and bq > wStart
                        float vq = array.get(phV, q)
                        if na(aHi) or vq > aHi
                            aHi  := vq
                            aHiB := bq
                            aHiT := array.get(phT, q)
            if na(aHi)
                for q = nH - 1 to 0
                    if na(aHi) and array.get(phB, q) < pb
                        aHi  := array.get(phV, q)
                        aHiB := array.get(phB, q)
                        aHiT := array.get(phT, q)

        bool geom = not na(aHi) and pl < aHi and (pb - aHiB) >= minLeg and (pb - aHiB) <= lookback and (bar_index - pb) <= lookback
        bool bos  = na(prevPLv) or pl < prevPLv
        bool disp = aMult <= 0 or na(atr) or (aHi - pl) >= aMult * atr
        bool ok   = method == 1 ? geom : method == 2 ? geom and bos : method == 3 ? geom and disp : geom and bos and disp

        if ok
            dir   := -1
            legHi := aHi
            legLo := pl
            legT1 := aHiT
            legT2 := pt

        array.push(plV, pl)
        array.push(plB, pb)
        array.push(plT, pt)
        if array.size(plV) > PIVMEM
            array.shift(plV)
            array.shift(plB)
            array.shift(plT)

    int   rD  = confirmedOnly ? dir[1]   : dir
    float rHi = confirmedOnly ? legHi[1] : legHi
    float rLo = confirmedOnly ? legLo[1] : legLo
    int   rT1 = confirmedOnly ? legT1[1] : legT1
    int   rT2 = confirmedOnly ? legT2[1] : legT2
    [rD, rHi, rLo, rT1, rT2]

// ---------------------------------------------------------------------------
//  Higher timeframe requests
// ---------------------------------------------------------------------------
[d1, h1, l1, a1, b1] = request.security(syminfo.tickerid, tf1Tf, f_ote(pivLen, tf1Lb, methodId, atrMult, atrLen, minLegBars, deepAnchor, useConf), lookahead = barmerge.lookahead_off)
[d2, h2, l2, a2, b2] = request.security(syminfo.tickerid, tf2Tf, f_ote(pivLen, tf2Lb, methodId, atrMult, atrLen, minLegBars, deepAnchor, useConf), lookahead = barmerge.lookahead_off)
[d3, h3, l3, a3, b3] = request.security(syminfo.tickerid, tf3Tf, f_ote(pivLen, tf3Lb, methodId, atrMult, atrLen, minLegBars, deepAnchor, useConf), lookahead = barmerge.lookahead_off)
[d4, h4, l4, a4, b4] = request.security(syminfo.tickerid, tf4Tf, f_ote(pivLen, tf4Lb, methodId, atrMult, atrLen, minLegBars, deepAnchor, useConf), lookahead = barmerge.lookahead_off)
[d5, h5, l5, a5, b5] = request.security(syminfo.tickerid, tf5Tf, f_ote(pivLen, tf5Lb, methodId, atrMult, atrLen, minLegBars, deepAnchor, useConf), lookahead = barmerge.lookahead_off)

// ---------------------------------------------------------------------------
//  Per timeframe setting tables
// ---------------------------------------------------------------------------
var array<bool>   tfEn   = array.from(tf1On, tf2On, tf3On, tf4On, tf5On)
var array<color>  tfCol  = array.from(tf1Col, tf2Col, tf3Col, tf4Col, tf5Col)
var array<bool>   tfLbl  = array.from(tf1Lbl, tf2Lbl, tf3Lbl, tf4Lbl, tf5Lbl)
var array<bool>   tfFib  = array.from(tf1Fib, tf2Fib, tf3Fib, tf4Fib, tf5Fib)
var array<bool>   tfZn   = array.from(tf1Zn, tf2Zn, tf3Zn, tf4Zn, tf5Zn)
var array<int>    tfHist = array.from(tf1N, tf2N, tf3N, tf4N, tf5N)
var array<int>    tfMs   = array.from(timeframe.in_seconds(tf1Tf) * 1000, timeframe.in_seconds(tf2Tf) * 1000, timeframe.in_seconds(tf3Tf) * 1000, timeframe.in_seconds(tf4Tf) * 1000, timeframe.in_seconds(tf5Tf) * 1000)
var array<string> tfName = array.from(f_tfName(tf1Tf), f_tfName(tf2Tf), f_tfName(tf3Tf), f_tfName(tf4Tf), f_tfName(tf5Tf))

var array<float>  fibVal = array.from(fA, fB, fC, fD, fE, c1V, c2V, c3V)
var array<bool>   fibOn  = array.from(fAOn, fBOn, fCOn, fDOn, fEOn, c1On and c1Ln, c2On and c2Ln, c3On and c3Ln)
var array<bool>   fibLbl = array.from(showLvlLbls, showLvlLbls, showLvlLbls, showLvlLbls, showLvlLbls, c1On and c1Lb, c2On and c2Lb, c3On and c3Lb)

// ---------------------------------------------------------------------------
//  Zone store
// ---------------------------------------------------------------------------
type Zone
    int   tf    = 0
    int   dir   = 0
    float hi    = na
    float lo    = na
    int   t1    = na
    int   t2    = na
    int   tEnd  = na
    int   bIdx  = 0
    int   st    = 0
    bool  eZone = false
    bool  eCore = false
    bool  e705  = false

var array<Zone> zones  = array.new<Zone>()
var array<Zone> active = array.new<Zone>(5)

var array<int>   lastT2  = array.from(0, 0, 0, 0, 0)
var array<int>   lastDir = array.from(0, 0, 0, 0, 0)
var array<float> lastHi  = array.from(0.0, 0.0, 0.0, 0.0, 0.0)
var array<float> lastLo  = array.from(0.0, 0.0, 0.0, 0.0, 0.0)

f_lvl(int dir, float hi, float lo, float f) =>
    dir == 1 ? hi - (hi - lo) * f : lo + (hi - lo) * f

// right hand edge of a zone. Active zones follow the extension setting, retired
// ones are frozen at the bar where they stopped being current.
f_geom(Zone z, string mode, int nBars, int tfms, int tnow) =>
    bool act = z.st == 0
    int  x2  = act ? (mode == "Fixed Number of Bars" ? z.t2 + nBars * tfms : tnow) : (na(z.tEnd) ? tnow : z.tEnd)
    if x2 < z.t2 + tfms
        x2 := z.t2 + tfms
    [act, x2]

// expired under the active time based retention rule. Never expires the live
// zone of a timeframe - that one is governed by invalidation, not by age.
f_expired(Zone z, int bi, int tnow, bool bars, int nBars, int nDays) =>
    z.st != 0 and (bars ? (bi - z.bIdx) > nBars : (tnow - z.t2) > nDays * 86400000.0)

// ---------------------------------------------------------------------------
//  New zone registration
// ---------------------------------------------------------------------------
array<int>   dArr  = array.from(d1, d2, d3, d4, d5)
array<float> hiArr = array.from(h1, h2, h3, h4, h5)
array<float> loArr = array.from(l1, l2, l3, l4, l5)
array<int>   t1Arr = array.from(a1, a2, a3, a4, a5)
array<int>   t2Arr = array.from(b1, b2, b3, b4, b5)

bool evEnter   = false
bool evCore    = false
bool ev705     = false
bool evInval   = false
bool evNewBull = false
bool evNewBear = false

for i = 0 to 4
    int   d  = array.get(dArr, i)
    float hh = array.get(hiArr, i)
    float ll = array.get(loArr, i)
    int   tA = array.get(t1Arr, i)
    int   tB = array.get(t2Arr, i)

    bool valid   = array.get(tfEn, i) and not na(d) and d != 0 and not na(tB) and not na(hh) and not na(ll) and hh > ll
    bool changed = valid and (tB != array.get(lastT2, i) or d != array.get(lastDir, i) or hh != array.get(lastHi, i) or ll != array.get(lastLo, i))

    if changed
        array.set(lastT2,  i, tB)
        array.set(lastDir, i, d)
        array.set(lastHi,  i, hh)
        array.set(lastLo,  i, ll)

        // retire the currently active zone of this timeframe - it stays in the
        // store as history, it is only no longer the live one
        Zone old = array.get(active, i)
        if not na(old)
            old.st   := 2
            old.tEnd := time

        Zone nz = Zone.new(tf = i, dir = d, hi = hh, lo = ll, t1 = tA, t2 = tB, bIdx = bar_index)
        array.push(zones, nz)
        array.set(active, i, nz)

        if d == 1
            evNewBull := true
        else
            evNewBear := true

        if alNew
            alert(array.get(tfName, i) + " new " + (d == 1 ? "bullish" : "bearish") + " OTE created", alert.freq_once_per_bar_close)

        // ---- retention : count rule, plus the absolute safety ceiling -------
        int keep = byCount ? array.get(tfHist, i) : SAFECAP
        if keep > SAFECAP
            keep := SAFECAP
        int cnt = 0
        int n1  = array.size(zones)
        if n1 > 0
            for j = 0 to n1 - 1
                if array.get(zones, j).tf == i
                    cnt += 1
        while cnt > keep
            int rem = -1
            int n2  = array.size(zones)
            if n2 > 0
                for j = 0 to n2 - 1
                    if rem == -1 and array.get(zones, j).tf == i
                        rem := j
            if rem >= 0
                array.remove(zones, rem)
                cnt -= 1
            else
                cnt := 0

        // ---- retention : time rule -----------------------------------------
        if not byCount
            int n3 = array.size(zones)
            if n3 > 0
                for j = n3 - 1 to 0
                    if f_expired(array.get(zones, j), bar_index, time, byBars, histBars, histDays)
                        array.remove(zones, j)

// ---------------------------------------------------------------------------
//  Lifecycle - only the five active zones are tracked each bar, so a deep
//  history costs nothing per bar
// ---------------------------------------------------------------------------
for i = 0 to 4
    Zone z = array.get(active, i)
    if not na(z) and z.st == 0 and not na(z.hi) and not na(z.lo)
        float pA = f_lvl(z.dir, z.hi, z.lo, fA)
        float pC = f_lvl(z.dir, z.hi, z.lo, fC)
        float pD = f_lvl(z.dir, z.hi, z.lo, fD)
        float pE = f_lvl(z.dir, z.hi, z.lo, fE)
        float pI = f_lvl(z.dir, z.hi, z.lo, innerLo)

        bool ins = high >= math.min(pA, pE) and low <= math.max(pA, pE)
        if ins and not z.eZone
            z.eZone := true
            evEnter := true
            if alEnter
                alert(array.get(tfName, z.tf) + " " + (z.dir == 1 ? "bullish" : "bearish") + " OTE entered", alert.freq_once_per_bar_close)
        else if not ins
            z.eZone := false

        bool inc = high >= math.min(pI, pD) and low <= math.max(pI, pD)
        if inc and not z.eCore
            z.eCore := true
            evCore  := true
            if alCore
                alert(array.get(tfName, z.tf) + " " + (z.dir == 1 ? "bullish" : "bearish") + " OTE core " + str.tostring(innerLo, "#.###") + " - " + str.tostring(fD, "#.###") + " entered", alert.freq_once_per_bar_close)
        else if not inc
            z.eCore := false

        bool t705 = high >= pC and low <= pC
        if t705 and not z.e705
            z.e705 := true
            ev705  := true
            if al705
                alert(array.get(tfName, z.tf) + " OTE " + str.tostring(fC, "#.###") + " touched", alert.freq_once_per_bar_close)
        else if not t705
            z.e705 := false

        bool bad = z.dir == 1 ? (useWick ? low < pE : close < pE) : (useWick ? high > pE : close > pE)
        if bad
            z.st    := 1
            z.tEnd  := time
            evInval := true
            array.set(active, i, na)
            if alInval
                alert(array.get(tfName, z.tf) + " " + (z.dir == 1 ? "bullish" : "bearish") + " OTE invalidated", alert.freq_once_per_bar_close)

if invalBeh == "Delete" and evInval
    int nd = array.size(zones)
    if nd > 0
        for j = nd - 1 to 0
            if array.get(zones, j).st == 1
                array.remove(zones, j)

// ---------------------------------------------------------------------------
//  Rendering - newest zone first, under a hard per type object budget
// ---------------------------------------------------------------------------
var array<line>  lns = array.new<line>()
var array<box>   bxs = array.new<box>()
var array<label> lbs = array.new<label>()
var table stTbl = table.new(position.bottom_right, 2, 5, bgcolor = color.new(color.black, 75), border_width = 1, border_color = color.new(color.gray, 60))

if barstate.islast
    int nl = array.size(lns)
    if nl > 0
        for i = 0 to nl - 1
            line.delete(array.get(lns, i))
        array.clear(lns)
    int nb = array.size(bxs)
    if nb > 0
        for i = 0 to nb - 1
            box.delete(array.get(bxs, i))
        array.clear(bxs)
    int nn = array.size(lbs)
    if nn > 0
        for i = 0 to nn - 1
            label.delete(array.get(lbs, i))
        array.clear(lbs)

    // time based retention is re-applied here so the drawn history matches the
    // rule even on bars where no new zone was created
    if not byCount
        int n4 = array.size(zones)
        if n4 > 0
            for j = n4 - 1 to 0
                if f_expired(array.get(zones, j), bar_index, time, byBars, histBars, histDays)
                    array.remove(zones, j)

    int zStored = 0
    int zDrawn  = 0
    int nzz     = array.size(zones)

    // -----------------------------------------------------------------------
    //  PASS 1 - the zone box for every zone, newest first.
    //  A box is one object, so this reaches the furthest back and is what makes
    //  a deep visual backtest possible. Detail is added afterwards.
    // -----------------------------------------------------------------------
    if nzz > 0
        for j = nzz - 1 to 0
            Zone z = array.get(zones, j)
            bool vis = array.get(tfEn, z.tf) and z.dir != 0 and not na(z.hi) and not na(z.lo) and not na(z.t2)
            if vis and hideLower and array.get(tfMs, z.tf) < chartMs
                vis := false
            if vis and z.st != 0 and not histOn
                vis := false

            if vis
                zStored += 1
                [act, x2] = f_geom(z, extS, extBars, array.get(tfMs, z.tf), time)
                bool  faded = z.st == 2 or (z.st == 1 and invalBeh != "Keep")
                bool  full  = act or histDetail == "Full (all fib levels)"
                color base  = array.get(tfCol, z.tf)
                extK = act and extS == "Extend Right" ? extend.right : extend.none

                if zoneShow and array.get(tfZn, z.tf) and array.size(bxs) < MAXOBJ
                    float pTop = f_lvl(z.dir, z.hi, z.lo, fA)
                    float pBot = f_lvl(z.dir, z.hi, z.lo, fE)
                    array.push(bxs, box.new(z.t2, math.max(pTop, pBot), x2, math.min(pTop, pBot), xloc = xloc.bar_time, border_color = color.new(base, 100), border_width = 0, bgcolor = color.new(base, faded ? invZoneTr : zoneTransp), extend = extK))
                    zDrawn += 1

                    if innerShow and full and array.size(bxs) < MAXOBJ
                        float iTop = f_lvl(z.dir, z.hi, z.lo, innerLo)
                        float iBot = f_lvl(z.dir, z.hi, z.lo, fD)
                        array.push(bxs, box.new(z.t2, math.max(iTop, iBot), x2, math.min(iTop, iBot), xloc = xloc.bar_time, border_color = color.new(base, 100), border_width = 0, bgcolor = color.new(base, faded ? invZoneTr : innerTransp), extend = extK))

    // -----------------------------------------------------------------------
    //  PASS 2 - sweet spot, fib lines, swing anchors and label, newest first.
    //  These run out before the boxes do, so the most recent setups stay fully
    //  annotated while older ones degrade to a plain shaded zone.
    // -----------------------------------------------------------------------
    if nzz > 0
        for j = nzz - 1 to 0
            Zone z = array.get(zones, j)
            bool vis = array.get(tfEn, z.tf) and z.dir != 0 and not na(z.hi) and not na(z.lo) and not na(z.t2)
            if vis and hideLower and array.get(tfMs, z.tf) < chartMs
                vis := false
            if vis and z.st != 0 and not histOn
                vis := false

            if vis
                [act, x2] = f_geom(z, extS, extBars, array.get(tfMs, z.tf), time)
                bool  faded = z.st == 2 or (z.st == 1 and invalBeh != "Keep")
                bool  dash  = z.st == 1 and invalDash
                bool  full  = act or histDetail == "Full (all fib levels)"
                bool  sweet = act or histDetail != "Zone only"
                bool  wantL = act or histDetail == "Zone + sweet spot + label" or histDetail == "Full (all fib levels)"
                color base  = array.get(tfCol, z.tf)
                extK = act and extS == "Extend Right" ? extend.right : extend.none

                // ---- fib lines --------------------------------------------
                if array.get(tfFib, z.tf) and sweet
                    for k = 0 to 7
                        bool drawIt = array.get(fibOn, k) and (full or k == 2)
                        if drawIt and array.size(lns) < MAXOBJ
                            float fv  = array.get(fibVal, k)
                            float py  = f_lvl(z.dir, z.hi, z.lo, fv)
                            bool  is7 = k == 2
                            color lc  = is7 and use705Col ? col705 : base
                            int   lw  = is7 ? lineW705 : lineW
                            int   tr  = faded ? (is7 ? histSweetTr : invLineTr) : (is7 ? transp705 : lineTransp)
                            array.push(lns, line.new(z.t2, py, x2, py, xloc = xloc.bar_time, extend = extK, color = color.new(lc, tr), style = dash ? line.style_dashed : lstyle, width = lw))
                            if array.get(fibLbl, k) and full and array.size(lbs) < MAXOBJ
                                array.push(lbs, label.new(x2, py, str.tostring(fv, "#.###"), xloc = xloc.bar_time, style = label.style_none, textcolor = color.new(lc, faded ? 55 : 15), size = size.tiny, textalign = text.align_left))

                // ---- swing points and impulse leg -------------------------
                bool wantSw  = swShow and (act or histSwing)
                bool wantLeg = swLeg  and (act or histLeg)

                if not na(z.t1)
                    float yLo = z.dir == 1 ? z.lo : z.hi
                    float yHi = z.dir == 1 ? z.hi : z.lo
                    int   trS = faded ? 45 : 0

                    if wantLeg and array.size(lns) < MAXOBJ
                        array.push(lns, line.new(z.t1, yLo, z.t2, yHi, xloc = xloc.bar_time, color = color.new(base, faded ? 75 : 45), style = line.style_dotted, width = 1))

                    if wantSw
                        if array.size(lbs) < MAXOBJ
                            array.push(lbs, label.new(z.t1, yLo, "", xloc = xloc.bar_time, yloc = yloc.price, style = z.dir == 1 ? swLoSty : swHiSty, color = color.new(base, trS), size = swSize))
                        if array.size(lbs) < MAXOBJ
                            array.push(lbs, label.new(z.t2, yHi, "", xloc = xloc.bar_time, yloc = yloc.price, style = z.dir == 1 ? swHiSty : swLoSty, color = color.new(base, trS), size = swSize))

                        if swPrice
                            if array.size(lbs) < MAXOBJ
                                array.push(lbs, label.new(z.t1, yLo, str.tostring(yLo, format.mintick), xloc = xloc.bar_time, yloc = yloc.price, style = z.dir == 1 ? label.style_label_up : label.style_label_down, color = color.new(base, 100), textcolor = color.new(base, trS), size = size.tiny))
                            if array.size(lbs) < MAXOBJ
                                array.push(lbs, label.new(z.t2, yHi, str.tostring(yHi, format.mintick), xloc = xloc.bar_time, yloc = yloc.price, style = z.dir == 1 ? label.style_label_down : label.style_label_up, color = color.new(base, 100), textcolor = color.new(base, trS), size = size.tiny))

                // ---- right side label -------------------------------------
                if array.get(tfLbl, z.tf) and wantL and array.size(lbs) < MAXOBJ
                    string txt = showTFName ? array.get(tfName, z.tf) : ""
                    if showDir
                        txt := txt + (str.length(txt) > 0 ? " " : "") + (z.dir == 1 ? "Bull" : "Bear")
                    txt := txt + (str.length(txt) > 0 ? " " : "") + "OTE"
                    if showFibVal
                        txt := txt + " " + str.tostring(fC, "#.###")
                    if z.st == 1
                        txt := txt + " inv"
                    array.push(lbs, label.new(x2, f_lvl(z.dir, z.hi, z.lo, fC), txt, xloc = xloc.bar_time, style = label.style_label_left, color = color.new(base, 100), textcolor = color.new(use705Col ? col705 : base, faded ? 45 : 0), size = lblSize, textalign = text.align_left))

    // ---- budget readout ---------------------------------------------------
    if histStatus
        bool tight = array.size(lns) >= MAXOBJ or array.size(bxs) >= MAXOBJ or array.size(lbs) >= MAXOBJ
        table.cell(stTbl, 0, 0, "OTE Wealth", text_color = color.white, text_size = size.tiny, text_halign = text.align_left)
        table.cell(stTbl, 1, 0, tight ? "budget full" : "ok", text_color = tight ? color.orange : color.new(color.lime, 20), text_size = size.tiny)
        table.cell(stTbl, 0, 1, "zones shown", text_color = color.silver, text_size = size.tiny, text_halign = text.align_left)
        table.cell(stTbl, 1, 1, str.tostring(zDrawn) + " / " + str.tostring(zStored), text_color = color.white, text_size = size.tiny)
        table.cell(stTbl, 0, 2, "lines", text_color = color.silver, text_size = size.tiny, text_halign = text.align_left)
        table.cell(stTbl, 1, 2, str.tostring(array.size(lns)) + " / 500", text_color = color.white, text_size = size.tiny)
        table.cell(stTbl, 0, 3, "boxes", text_color = color.silver, text_size = size.tiny, text_halign = text.align_left)
        table.cell(stTbl, 1, 3, str.tostring(array.size(bxs)) + " / 500", text_color = color.white, text_size = size.tiny)
        table.cell(stTbl, 0, 4, "labels", text_color = color.silver, text_size = size.tiny, text_halign = text.align_left)
        table.cell(stTbl, 1, 4, str.tostring(array.size(lbs)) + " / 500", text_color = color.white, text_size = size.tiny)

// ---------------------------------------------------------------------------
//  Alert conditions
// ---------------------------------------------------------------------------
alertcondition(evEnter,   "OTE zone entered",   "Price entered an OTE zone")
alertcondition(evCore,    "OTE core entered",   "Price entered the OTE core range")
alertcondition(ev705,     "OTE sweet spot hit", "Price touched the OTE sweet spot level")
alertcondition(evInval,   "OTE invalidated",    "An OTE zone was invalidated")
alertcondition(evNewBull, "New bullish OTE",    "A new bullish OTE was created")
alertcondition(evNewBear, "New bearish OTE",    "A new bearish OTE was created")
````
