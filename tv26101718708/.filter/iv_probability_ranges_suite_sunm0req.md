# IV Probability Ranges - Suite

- url: https://www.tradingview.com/script/Sunm0reQ-IV-Probability-Ranges-Suite/
- type: indicator
- pine_id: PUB;b4ccca62e58649639c153e1d41fc274f
- version: 2.0

## Description

[b]IV Probability Ranges[/b]

IV Probability Ranges is a volatility-based range and market-behavior study. It uses the selected implied-volatility index to build a projected range around the opening price of each day, week, month, quarter, half-year, or year.

The script divides that range into configurable levels and tracks how price historically behaved around them.

[b]Main features:[/b]
[list]
[*]Implied-volatility range centered on the period open
[*]Support for VIX, VXN, RVX, VXD, GVZ, OVX, VXFXI, VXEEM, VXTYN, and VXEW
[*]Daily through annual range periods
[*]Configurable divisions inside the main range
[*]Additional standard-deviation and extension levels
[*]Historical reach rates for each upper and lower level
[*]Reversion-versus-continuation statistics after a level is reached
[*]First-touch statistics showing whether the upper or lower side was reached first
[*]Box breach, return-to-open, and close-back-inside statistics
[*]Optional prior-period VWAP and VWAP deviation references
[*]Adjustable rolling sample size
[/list]

[b]How the statistics work:[/b]

“Reach” shows how often price touched a level during completed historical periods.

After a level is reached, the script also records whether price moved back to the nearest inner level or continued to the nearest outer level first.

The optional first-touch section compares matching upper and lower levels and records whether the upside, downside, or neither side was reached first.

All statistics are calculated from completed periods using the available chart history and selected sample size.

[b]How to use it[/b]

Choose a period and the volatility index most relevant to the chart symbol. Adjust the range divisions, extension levels, and sample size as needed.

The tool can be used to:

[list]
[*]Compare the current move with the implied range
[*]Identify historically common or uncommon price extensions
[*]Study whether price tended to revert or continue after reaching a level
[*]Compare upside and downside first-touch behavior
[*]Add volatility context to another trading method
[/list]

[b]Limitations:[/b]

[list]
[*]This script is a research and context tool, not a trading system.
[*]Historical results depend on the selected symbol, timeframe, volatility index, settings, chart history, and sample size. Implied volatility does not guarantee that price will remain inside a range or reach a specific level.
[*]Historical bars also do not always reveal the exact intrabar order of events, so some same-bar situations require a consistent tie-breaking assumption.
[*]VWAP features require usable volume data.
[/list]

[b]Originality[/b]

The script combines implied-volatility ranges, historical level-reach statistics, reversion-versus-continuation tracking, first-touch analysis, breach statistics, and prior-period VWAP references into one configurable study.

The Pine implementation and combined feature set were developed for this publication. The underlying concepts of implied volatility, standard deviations, and VWAP are established market concepts.

[b]Version note[/b]

This script replaces an older publication with a similar title, but it is not a minor revision or repackaged version of that script.

The underlying modeling engine was substantially redesigned and expanded. The new version uses a different statistical framework and adds rolling historical samples, level-specific reach analysis, conditional reversion-versus-continuation tracking, first-touch race statistics, extended range modeling, breach and return analysis, and period-matched VWAP references.

Because the new script functions differently from the prior model, and because TradingView’s Update feature does not allow the publication title to be changed, it was released as a separate script. The older publication was marked as deprecated so users would not continue relying on the obsolete version.

Future revisions to this model will be published through the Update feature.

## Source Code

````pine
//@version=6
indicator("IV Probability Ranges - Suite", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 100)

// =========================================================================
// ① IV ENGINE
// =========================================================================
grpEng         = "① IV Engine"
showVIX        = input.bool(true, "Enable IV Box & Ranges", group=grpEng, tooltip="Master switch for the implied-volatility box, all range levels, statistics and analytics.")
vixIndex       = input.string("S&P 500", "Underlying Index", options=["S&P 500", "Nasdaq-100", "Russell 2000", "Dow Jones", "S&P 500 (No Weeklys)", "Gold", "Crude Oil", "China", "Emerging Markets", "10Y Treasury"], group=grpEng, tooltip="Select the market whose CBOE implied-volatility index drives the box height.")
vixPeriod      = input.string("1 Week", "Box Period", options=["1 Day", "1 Week", "1 Month", "3 Months", "6 Months", "1 Year"], group=grpEng, tooltip="The annualized implied volatility is de-annualized to the chosen horizon by dividing by √(periods per year):\n1 Day    ÷ √252\n1 Week   ÷ √52\n1 Month  ÷ √12\n3 Months ÷ √4\n6 Months ÷ √2\n1 Year   ÷ √1\nThe box rebuilds at the start of each new period and the VWAP anchor matches it (D / W / M / 3M / 6M / 12M).")
maxSamples     = input.int(1000, "Max Samples (rolling window)", minval=1, group=grpEng, tooltip="All statistics are computed over only the most recent N completed boxes. The result matrix is capped to this many rows (and hard-limited under Pine's 100k-element ceiling), so daily/intraday won't overflow. Set to e.g. 10, 50, 500 for last-N hit rates.")

// =========================================================================
// ② DAILY SESSION SPLIT  (only active when Box Period = 1 Day)
// =========================================================================
grpSess        = "② Daily Session Split (Box Period = 1 Day)"
dayMode        = input.string("Standard (Calendar Day)", "Daily Mode", options=["Standard (Calendar Day)", "RTH Session", "ETH Session"], group=grpSess, tooltip="Only applies when Box Period = '1 Day' AND the chart is intraday.\nStandard = the full calendar-day box (anchored to 'D').\nRTH Session = box built at the Regular-hours open, spans ONLY RTH.\nETH Session = box spans ONLY the Extended-hours session.\nThe box freezes between sessions; the previous session is scored when the next one opens.")
rthSess        = input.session("0930-1600", "RTH Session", group=grpSess, tooltip="Regular trading-hours session, in the chart symbol's exchange timezone. Used when Daily Mode = RTH Session.")
ethSess        = input.session("1600-0930", "ETH Session", group=grpSess, tooltip="Extended trading-hours session (overnight by default), in the chart symbol's exchange timezone. Used when Daily Mode = ETH Session.")

// =========================================================================
// ③ RANGE LEVELS
// =========================================================================
grpLvl         = "③ Range Levels"
vixDivisions   = input.int(4, "In-Box Divisions (per half)", minval=1, maxval=10, group=grpLvl, tooltip="Each half of the box (0→1σ) is split into this many equal range levels.")
sdLevels       = input.int(1, "Std-Dev Bands (box edge = 1σ)", minval=1, maxval=5, group=grpLvl, tooltip="The box edge IS 1σ (the implied move). Once price exits the box, bands at 2σ … this many σ are drawn on the breached side, each with its live conditional reach probability. Set to 1 to disable SD expansion.")
extLevels      = input.int(0, "Extension Levels Beyond Box", minval=0, maxval=20, group=grpLvl, tooltip="Starts at 0. Each increment adds a level beyond the 1σ edge, spaced by 'Extension Step %' of the implied move, on BOTH sides. 0 = disabled.")
extStep        = input.float(10, "Extension Step %", minval=1, maxval=200, step=5, group=grpLvl, tooltip="Spacing between extension levels, as a percentage of the implied move (box half-height / 1σ). Default 10% → 110%, 120%, 130% … Increase to 20–40% on volatile markets so levels spread out instead of crowding.")

// =========================================================================
// ④ CONDITIONAL ANALYTICS
// =========================================================================
grpCond        = "④ Conditional Analytics"
showRace       = input.bool(false, "First-Touch Race (which ±side reached first)", group=grpCond, tooltip="Adds a mutually-exclusive 'race' section to the table. For each symmetric distance ±X it records WHICH SIDE price reached FIRST during the period:\n  ↑1st = +X reached before -X\n  ↓1st = -X reached before +X\n  None = neither side reached ±X that period\nThese three sum to 100% per level. A single bar spanning both sides at once (unorderable intrabar) breaks the tie by that bar's close vs open.")
showPath       = input.bool(false, "Momentum Path (conditional chain)", group=grpCond, tooltip="Tracks, per period, the ORDERED sequence of the first time price touches each NEW level (nearest-first as the high/low frontier expands, plus a 'Mid' event when price returns to the open AFTER having reached at least the first division). On the last bar it finds every historical period that OPENED with the same signature as the current period and shows the probability distribution of the touch that came NEXT. Intrabar order uses the standard OHLC heuristic (up-close bar → low before high, down-close → high before low).")
pathDepth      = input.int(2, "Opening Signature Length (touches)", minval=1, maxval=16, group=grpCond, tooltip="How many of the current period's FIRST touches define the 'opening signature' used for conditioning. This is a FIXED, SHORT prefix — e.g. 2 means 'condition on the first two levels touched, such as +25% → +50%'. Once the period has printed this many touches the signature FREEZES; it does NOT deepen as the period runs on. Small values (1–2) keep a large, statistically meaningful matched cohort; larger values isolate rarer, more specific openings. This is the whole thesis: a week that opens +25%→+50% is a different animal, so re-base everything on all prior weeks that opened the same way.")
pathOverride   = input.bool(false, "Momentum Override — recompute ALL probabilities conditioned on the opening signature", group=grpCond, tooltip="When ON, the ENTIRE statistics engine (every level's Reach / →Rev / →Cont / None on the chart labels AND in the table, plus the Close-Inside/Breach summary) is recomputed using ONLY the historical periods that OPENED with the same signature (first N touches, N = Opening Signature Length) as the current period. 'Samples' then shows the matched cohort size. Turn OFF for the standard unconditional stats. Deeper signatures = smaller cohorts, so keep the length short (1–2) unless you have lots of history.")

// =========================================================================
// ⑤ VWAP REFERENCE (PRIOR PERIOD)
// =========================================================================
grpRef         = "⑤ VWAP Reference (Prior Period)"
showRef        = input.bool(false, "Show VWAP & SD Bands (each period)", group=grpRef, tooltip="Draws the PRIOR period's closing VWAP and ±σ bands as a stepped level on each period. The VWAP anchor MATCHES the box period (Day → D, Week → W, Month → M, 3M, 6M, 12M). Requires VOLUME data. Breach→return stats use the prior-period levels snapshot taken at the box's start.")
refBands       = input.int(1, "VWAP SD Bands (each side)", minval=1, maxval=3, group=grpRef)
refLblBands    = input.bool(true, "Label σ Bands (off = label VWAP line only)", group=grpRef, tooltip="Each label counts against the 500-label limit shared with the IV boxes. Turn off to label only the VWAP line per period so more historical periods stay visible.")
refVwapCol     = input.color(color.new(color.blue, 0), "VWAP Line Color", group=grpRef)
refBandCol     = input.color(color.new(color.blue, 30), "VWAP SD Band Color", group=grpRef)
refTxtCol      = input.color(color.white, "VWAP Label Text Color", group=grpRef)

// =========================================================================
// ⑥ STATISTICS TABLE
// =========================================================================
grpTbl         = "⑥ Statistics Table"
showTable      = input.bool(false, "Show Statistics Table", group=grpTbl, tooltip="Toggles the data panel (bottom-right). Turn OFF to see only the lines, boxes and level labels on the chart.")
tblHeadBgCol   = input.color(color.new(color.blue, 80), "Header BG Color", group=grpTbl)
tblHeadTxtCol  = input.color(color.white, "Header Text Color", group=grpTbl)
tblCellBgCol   = input.color(color.new(color.black, 0), "Cell BG Color", group=grpTbl)
tblCellTxtCol  = input.color(color.white, "Cell Text Color", group=grpTbl)
tblBorderCol   = input.color(color.new(color.gray, 50), "Border Color", group=grpTbl)
pathHdrCol     = input.color(color.new(color.purple, 40), "Momentum Path Header BG", group=grpTbl)

// =========================================================================
// ⑦ VISUALS (BOX & LEVELS)
// =========================================================================
grpVis         = "⑦ Visuals (Box & Levels)"
vixBoxCol      = input.color(color.rgb(255, 255, 255), "IV Box Fill Color", group=grpVis)
boxOpacity     = input.int(95, "IV Box Transparency", 0, 100, group=grpVis)
vixBorderCol   = input.color(color.rgb(255, 255, 255), "IV Border Color", group=grpVis)
vixBorderTransp= input.int(0, "IV Border Transparency", 0, 100, group=grpVis)
upRangeCol     = input.color(color.new(#ffffff, 0), "Upper Range Line Color", group=grpVis)
dnRangeCol     = input.color(color.new(#ffffff, 0), "Lower Range Line Color", group=grpVis)
sdCol          = input.color(color.new(color.red, 0), "Std-Dev Band Color", group=grpVis)
extCol         = input.color(color.new(color.red, 0), "Extension Level Color", group=grpVis)
midCol         = input.color(color.new(color.yellow, 0), "Midpoint (50%) Line Color", group=grpVis)
rangeLblTxtCol = input.color(color.white, "Range Label Text Color", group=grpVis)

float extFrac = extStep / 100.0
int nPathLvl  = 2 * (vixDivisions + extLevels + (sdLevels - 1)) + 1
int pathStore = pathDepth + 1   // store the signature (pathDepth touches) + 1 slot so the touch AFTER the signature can be predicted

// =========================================================================
// STATIC ORDERED FRACTION SET (all levels, one side). Distances are
// symmetric, so one set serves both sides. Rebuilt once on the first bar.
// Used to find each level's nearest INNER/OUTER neighbor LIVE.
// =========================================================================
var float[] allFracs = array.new_float()
if barstate.isfirst
    for i = 0 to vixDivisions - 1
        array.push(allFracs, (i + 1) * 1.0 / vixDivisions)
    if extLevels > 0
        for i = 0 to extLevels - 1
            array.push(allFracs, 1.0 + (i + 1) * extFrac)
    if sdLevels >= 2
        for j = 2 to sdLevels
            array.push(allFracs, j * 1.0)

// =========================================================================
// SIGNED LEVEL SET FOR THE MOMENTUM PATH (both sides + Mid), ID = index
// =========================================================================
var float[] pathFracs = array.new_float()
var int     pathMidID = na
if barstate.isfirst
    array.push(pathFracs, 0.0)
    for i = 0 to vixDivisions - 1
        array.push(pathFracs, (i + 1) * 1.0 / vixDivisions)
        array.push(pathFracs, -((i + 1) * 1.0 / vixDivisions))
    if extLevels > 0
        for i = 0 to extLevels - 1
            array.push(pathFracs, 1.0 + (i + 1) * extFrac)
            array.push(pathFracs, -(1.0 + (i + 1) * extFrac))
    if sdLevels >= 2
        for j = 2 to sdLevels
            array.push(pathFracs, j * 1.0)
            array.push(pathFracs, -(j * 1.0))
    array.sort(pathFracs, order.ascending)
    for idx = 0 to array.size(pathFracs) - 1
        if math.abs(array.get(pathFracs, idx)) < 0.0000001
            pathMidID := idx


// =========================================================================
// UNDERLYING INDEX MAPPING (symbol)
// =========================================================================
f_tickerOf(string idx) =>
    switch idx
        "S&P 500"              => "CBOE:VIX"
        "Nasdaq-100"           => "CBOE:VXN"
        "Russell 2000"         => "CBOE:RVX"
        "Dow Jones"            => "CBOE:VXD"
        "S&P 500 (No Weeklys)" => "CBOE:VXEW"
        "Gold"                 => "CBOE:GVZ"
        "Crude Oil"            => "CBOE:OVX"
        "China"                => "CBOE:VXFXI"
        "Emerging Markets"     => "CBOE:VXEEM"
        "10Y Treasury"         => "CBOE:VXTYN"
        =>                        "CBOE:VIX"


// =========================================================================
// PERIOD MAPPING (de-annualization, anchor TF, display tags)
// =========================================================================
f_periodsPerYear(string p) =>
    switch p
        "1 Day"    => 252.0
        "1 Week"   => 52.0
        "1 Month"  => 12.0
        "3 Months" => 4.0
        "6 Months" => 2.0
        "1 Year"   => 1.0
        =>            52.0

f_anchorTF(string p) =>
    switch p
        "1 Day"    => "D"
        "1 Week"   => "W"
        "1 Month"  => "M"
        "3 Months" => "3M"
        "6 Months" => "6M"
        "1 Year"   => "12M"
        =>            "W"

f_periodTag(string p) =>
    switch p
        "1 Day"    => "Daily"
        "1 Week"   => "Weekly"
        "1 Month"  => "Monthly"
        "3 Months" => "Quarterly"
        "6 Months" => "Semiannual"
        "1 Year"   => "Annual"
        =>            "Weekly"

f_anomalyTag(string p) =>
    switch p
        "1 Day"    => "day"
        "1 Week"   => "wk"
        "1 Month"  => "mo"
        "3 Months" => "qtr"
        "6 Months" => "half"
        "1 Year"   => "yr"
        =>            "wk"


// =========================================================================
// PERIOD CLASSIFICATION (needed early for the VWAP anchor)
// =========================================================================
string effTicker = f_tickerOf(vixIndex)
string effName   = vixIndex

float divisor = math.sqrt(f_periodsPerYear(vixPeriod))

string boxAnchorTF  = f_anchorTF(vixPeriod)
string vwapAnchorTF = boxAnchorTF
string refPeriodTag = f_periodTag(vixPeriod)
string anomalyTag   = f_anomalyTag(vixPeriod)

// ---- DAILY SESSION (ETH / RTH) HANDLING ----
bool   useSession = (vixPeriod == "1 Day") and (dayMode != "Standard (Calendar Day)")
string sessSpec   = dayMode == "RTH Session" ? rthSess : ethSess
bool   inSess     = not na(time(timeframe.period, sessSpec))
var bool prevInSess = false
bool   sessStart  = inSess and not prevInSess
prevInSess := inSess


// =========================================================================
// DATE / LEVEL LABEL HELPERS
// =========================================================================
f_monAbbr(int m) =>
    switch m
        1  => "Jan"
        2  => "Feb"
        3  => "Mar"
        4  => "Apr"
        5  => "May"
        6  => "Jun"
        7  => "Jul"
        8  => "Aug"
        9  => "Sep"
        10 => "Oct"
        11 => "Nov"
        =>    "Dec"

f_periodDate(int t) =>
    string res = f_monAbbr(month(t)) + " " + str.tostring(year(t))
    if vixPeriod == "1 Week"
        res := "Wk " + f_monAbbr(month(t)) + " " + str.tostring(dayofmonth(t))
    else if vixPeriod == "1 Day"
        res := f_monAbbr(month(t)) + " " + str.tostring(dayofmonth(t))
    res

// Format a distance fraction (1.0 = 1σ = 100%) as a percent string
f_lvlPctStr(float f) =>
    str.tostring(f * 100, "#") + "%"

// Name a signed path fraction
f_pathName(float f) =>
    float a = math.abs(f)
    string s = f >= 0 ? "+" : "-"
    string res = a < 0.0000001 ? "Mid" : (a >= 1.0 and math.abs(a - math.round(a)) < 0.0000001 ? s + str.tostring(int(math.round(a))) + "σ" : s + f_lvlPctStr(a))
    res

// Build the current touch-sequence prefix as a readable string
f_prefixStr(int plen, int[] pth, float[] frs) =>
    string s = plen <= 0 ? "(opening)" : ""
    if plen > 0
        for k = 0 to plen - 1
            s := s + f_pathName(array.get(frs, array.get(pth, k))) + (k < plen - 1 ? "→" : "")
    s

// -------------------------------------------------------------------------
// FIRST-EVENT (RACE) FORMATTERS
// -------------------------------------------------------------------------
f_lblText(string lvlName, int num, int total, int revNum, float innerF, int contNum, float outerF, bool up) =>
    float ov = total > 0 ? num / total * 100 : na
    float rv = num   > 0 ? revNum / num * 100 : na
    string sign  = up ? "+" : "-"
    string ovS   = na(ov) ? "N/A" : str.tostring(ov, "#.#") + "%"
    string rvS   = na(rv) ? "N/A" : str.tostring(rv, "#.#") + "%"
    string innerS = (na(innerF) or innerF == 0) ? "Mid" : sign + f_lvlPctStr(innerF)
    string res = lvlName + " | " + ovS + " overall · →" + innerS + " " + rvS + " rev"
    if not na(outerF)
        float ct = num > 0 ? contNum / num * 100 : na
        string ctS = na(ct) ? "N/A" : str.tostring(ct, "#.#") + "%"
        string outerS = sign + f_lvlPctStr(outerF)
        res := res + " · →" + outerS + " " + ctS + " cont"
        float un = num > 0 ? (num - revNum - contNum) / num * 100 : na
        string unS = na(un) ? "N/A" : str.tostring(un, "#.#") + "%"
        res := res + " · " + unS + " none"
    res

// =========================================================================
// NEAREST-NEIGHBOR HELPERS (static fraction set → valid live/bar-by-bar)
// =========================================================================
f_innerFrac(float target, float[] allF) =>
    float best = 0.0
    if array.size(allF) > 0
        for idx = 0 to array.size(allF) - 1
            float f = array.get(allF, idx)
            if f < target - 0.000001 and f > best
                best := f
    best

f_outerFrac(float target, float[] allF) =>
    float best = na
    if array.size(allF) > 0
        for idx = 0 to array.size(allF) - 1
            float f = array.get(allF, idx)
            if f > target + 0.000001 and (na(best) or f < best)
                best := f
    best

// Push a distinct level ID into the ordered path (mutates arrays by ref)
f_pushPath(int id, int[] pth, bool[] tch, int[] lenArr, int depth) =>
    int ln = array.get(lenArr, 0)
    if ln < depth and id >= 0 and not array.get(tch, id)
        array.set(tch, id, true)
        array.set(pth, ln, id)
        array.set(lenArr, 0, ln + 1)
    0


// =========================================================================
// STATS STORAGE: per-period results pushed to a matrix; summed over last N
// =========================================================================
var matrix<float> statM = matrix.new<float>(0, 0)
var matrix<float> pathM = matrix.new<float>(0, 0)

int cUp     = 0
int cDn     = cUp   + vixDivisions
int cSdUp   = cDn   + vixDivisions
int cSdDn   = cSdUp + sdLevels
int cInside = cSdDn + sdLevels
int cBreach = cInside + 1
int cBCI    = cBreach + 1
int cRetMid = cBCI + 1
int cTVwap  = cRetMid + 1
int cRefUp  = cTVwap + 1
int cRefDn  = cRefUp + refBands
int cExtUp  = cRefDn + refBands
int cExtDn  = cExtUp + extLevels
// ---- per-level REVERT-FIRST blocks ----
int cRUp    = cExtDn + extLevels
int cRDn    = cRUp   + vixDivisions
int cRSdUp  = cRDn   + vixDivisions
int cRSdDn  = cRSdUp + sdLevels
int cRExtUp = cRSdDn + sdLevels
int cRExtDn = cRExtUp + extLevels
// ---- per-level CONTINUE-FIRST blocks ----
int cCUp    = cRExtDn + extLevels
int cCDn    = cCUp    + vixDivisions
int cCSdUp  = cCDn    + vixDivisions
int cCSdDn  = cCSdUp  + sdLevels
int cCExtUp = cCSdDn  + sdLevels
int cCExtDn = cCExtUp + extLevels
// ---- FIRST-TOUCH RACE blocks (±level, which side reached first) ----
int cRcUp    = cCExtDn + extLevels
int cRcDn    = cRcUp   + vixDivisions
int cRcExtUp = cRcDn   + vixDivisions
int cRcExtDn = cRcExtUp + extLevels
int cRcSdUp  = cRcExtDn + extLevels
int cRcSdDn  = cRcSdUp + sdLevels
int nCols    = cRcSdDn + sdLevels

// Rolling row cap for the stats matrix (see maxSamples tooltip).
int rowCap = math.max(1, math.min(maxSamples, int(90000 / math.max(nCols, 1))))

var int[] winUpReach = array.new_int(vixDivisions, 0)
var int[] winDnReach = array.new_int(vixDivisions, 0)
var int[] winSdUp    = array.new_int(sdLevels, 0)
var int[] winSdDn    = array.new_int(sdLevels, 0)
var int[] winRefUp   = array.new_int(refBands, 0)
var int[] winRefDn   = array.new_int(refBands, 0)
var int[] winExtUp   = array.new_int(extLevels, 0)
var int[] winExtDn   = array.new_int(extLevels, 0)
// windowed REVERT-FIRST counts (per level)
var int[] winRUp     = array.new_int(vixDivisions, 0)
var int[] winRDn     = array.new_int(vixDivisions, 0)
var int[] winRSdUp   = array.new_int(sdLevels, 0)
var int[] winRSdDn   = array.new_int(sdLevels, 0)
var int[] winRExtUp  = array.new_int(extLevels, 0)
var int[] winRExtDn  = array.new_int(extLevels, 0)
// windowed CONTINUE-FIRST counts (per level)
var int[] winCUp     = array.new_int(vixDivisions, 0)
var int[] winCDn     = array.new_int(vixDivisions, 0)
var int[] winCSdUp   = array.new_int(sdLevels, 0)
var int[] winCSdDn   = array.new_int(sdLevels, 0)
var int[] winCExtUp  = array.new_int(extLevels, 0)
var int[] winCExtDn  = array.new_int(extLevels, 0)
// windowed FIRST-TOUCH RACE counts (per level)
var int[] winRaceUpDiv = array.new_int(vixDivisions, 0)
var int[] winRaceDnDiv = array.new_int(vixDivisions, 0)
var int[] winRaceUpExt = array.new_int(extLevels, 0)
var int[] winRaceDnExt = array.new_int(extLevels, 0)
var int[] winRaceUpSd  = array.new_int(sdLevels, 0)
var int[] winRaceDnSd  = array.new_int(sdLevels, 0)
var int   winTotal  = 0
var int   winInside = 0
var int   winBreach = 0
var int   winBCI    = 0
var int   winRetMid = 0
var int   winTVwap  = 0
var int   winBCIup  = 0
var int   winBCIdn  = 0

// ---- MOMENTUM PATH windowed conditional counts ----
var int[] pathNextCnt = array.new_int(nPathLvl, 0)
var int   pathNoneCnt = 0
var int   pathDenom   = 0

// ---- MOMENTUM OVERRIDE display state ----
var bool gCond    = false
var int  gCondLen = 0
var int  gWinAll  = 0

// Live box state
var float currentBoxTop      = na
var float currentBoxBottom   = na
var float currentBoxOpen     = na
var bool  currentBoxBreached = false
var float curPeriodHigh      = na
var float curPeriodLow       = na
var float boxVixRef          = na
var float curImpliedPoints   = na
var int   boxLeftBar         = na

var bool  seenBreachUp = false
var bool  seenBreachDn = false
var bool  retToMid     = false

var float refVwap0       = na
var float refSigma0      = na
var bool  touchedVwapFlag = false
var bool[] touchedUp     = array.new_bool(refBands, false)
var bool[] touchedDn     = array.new_bool(refBands, false)

// ---- PER-LEVEL RACE live state: touched / revert-first / continue-first / resolved ----
var bool[] tUpLvl   = array.new_bool(vixDivisions, false)
var bool[] rUpLvl   = array.new_bool(vixDivisions, false)
var bool[] cUpLvl   = array.new_bool(vixDivisions, false)
var bool[] resUpLvl = array.new_bool(vixDivisions, false)
var bool[] tDnLvl   = array.new_bool(vixDivisions, false)
var bool[] rDnLvl   = array.new_bool(vixDivisions, false)
var bool[] cDnLvl   = array.new_bool(vixDivisions, false)
var bool[] resDnLvl = array.new_bool(vixDivisions, false)
var bool[] tUpSD    = array.new_bool(sdLevels, false)
var bool[] rUpSD    = array.new_bool(sdLevels, false)
var bool[] cUpSD    = array.new_bool(sdLevels, false)
var bool[] resUpSD  = array.new_bool(sdLevels, false)
var bool[] tDnSD    = array.new_bool(sdLevels, false)
var bool[] rDnSD    = array.new_bool(sdLevels, false)
var bool[] cDnSD    = array.new_bool(sdLevels, false)
var bool[] resDnSD  = array.new_bool(sdLevels, false)
var bool[] tUpExt   = array.new_bool(extLevels, false)
var bool[] rUpExt   = array.new_bool(extLevels, false)
var bool[] cUpExt   = array.new_bool(extLevels, false)
var bool[] resUpExt = array.new_bool(extLevels, false)
var bool[] tDnExt   = array.new_bool(extLevels, false)
var bool[] rDnExt   = array.new_bool(extLevels, false)
var bool[] cDnExt   = array.new_bool(extLevels, false)
var bool[] resDnExt = array.new_bool(extLevels, false)

// ---- FIRST-TOUCH RACE live state (±level, which side first) ----
var bool[] raceUpDiv = array.new_bool(vixDivisions, false)
var bool[] raceDnDiv = array.new_bool(vixDivisions, false)
var bool[] raceUpExt = array.new_bool(extLevels, false)
var bool[] raceDnExt = array.new_bool(extLevels, false)
var bool[] raceUpSd  = array.new_bool(sdLevels, false)
var bool[] raceDnSd  = array.new_bool(sdLevels, false)

// ---- MOMENTUM PATH live state (store pathStore = pathDepth+1 touches) ----
var int[]  periodPath    = array.new_int(pathStore, -1)
var int[]  pathLenArr    = array.new_int(1, 0)
var bool[] pathTouched   = array.new_bool(nPathLvl, false)
var float  reachedUpFrac = 0.0
var float  reachedDnFrac = 0.0

var bool  boxActive  = false

var bool  sdDrawnUp = false
var bool  sdDrawnDn = false

var box     vixBox      = na
var line    curMidLine  = na
var label   curMidLabel = na
var line[]  curUpLines   = array.new_line()
var line[]  curDnLines   = array.new_line()
var label[] curUpLabels  = array.new_label()
var label[] curDnLabels  = array.new_label()
var float[] curUpLevels  = array.new_float()
var float[] curDnLevels  = array.new_float()
var line[]  curUpSDLines  = array.new_line()
var line[]  curDnSDLines  = array.new_line()
var label[] curUpSDLabels = array.new_label()
var label[] curDnSDLabels = array.new_label()

var line[]  curUpExtLines  = array.new_line()
var line[]  curDnExtLines  = array.new_line()
var label[] curUpExtLabels = array.new_label()
var label[] curDnExtLabels = array.new_label()

var line    curRefVwap = na
var line[]  curRefUp   = array.new_line()
var line[]  curRefDn   = array.new_line()
var int     periodStartBar  = na
var int     periodStartTime = na
var float   pdVwap  = na
var float   pdSigma = na

float vixDailyClose = request.security(effTicker, "D", close[1])

// ---- VWAP REFERENCE: live computation & per-period snapshot ----
bool refNewPeriod = useSession ? sessStart : (ta.change(time(vwapAnchorTF)) != 0)
[vwVal, vwUp, vwLo] = ta.vwap(hlc3, refNewPeriod, 1.0)
if refNewPeriod
    pdVwap          := vwVal[1]
    pdSigma         := vwUp[1] - vwVal[1]
    periodStartBar  := bar_index
    periodStartTime := time

// =========================================================================
// VWAP REFERENCE: draw a stepped, DATE-STAMPED level for EVERY period
// =========================================================================
if showRef
    if refNewPeriod and not na(pdVwap)
        string dstr = f_periodDate(periodStartTime)

        curRefVwap := line.new(bar_index, pdVwap, bar_index, pdVwap, color=refVwapCol, width=2, style=line.style_solid)
        label.new(bar_index, pdVwap, refPeriodTag + " VWAP  " + str.tostring(pdVwap, format.mintick) + "  · " + dstr, style=label.style_label_left, color=color.new(refVwapCol, 70), textcolor=refTxtCol, size=size.small)

        array.clear(curRefUp)
        array.clear(curRefDn)
        if not na(pdSigma) and pdSigma > 0
            for k = 1 to refBands
                float up = pdVwap + k * pdSigma
                float dn = pdVwap - k * pdSigma
                array.push(curRefUp, line.new(bar_index, up, bar_index, up, color=refBandCol, width=1, style=line.style_dotted))
                array.push(curRefDn, line.new(bar_index, dn, bar_index, dn, color=refBandCol, width=1, style=line.style_dotted))
                if refLblBands
                    label.new(bar_index, up, "VWAP +" + str.tostring(k) + "σ  " + str.tostring(up, format.mintick), style=label.style_label_left, color=color.new(refBandCol, 70), textcolor=refTxtCol, size=size.small)
                    label.new(bar_index, dn, "VWAP -" + str.tostring(k) + "σ  " + str.tostring(dn, format.mintick), style=label.style_label_left, color=color.new(refBandCol, 70), textcolor=refTxtCol, size=size.small)
    else if not na(curRefVwap)
        line.set_x2(curRefVwap, bar_index)
        if array.size(curRefUp) > 0
            for k = 0 to array.size(curRefUp) - 1
                line.set_x2(array.get(curRefUp, k), bar_index)
                line.set_x2(array.get(curRefDn, k), bar_index)


if showVIX
    bool isNewPeriod = useSession ? sessStart : (ta.change(time(boxAnchorTF)) != 0)
    bool canTrack    = (not useSession) or inSess

    bool doBuild = false

    if isNewPeriod
        // ---- Score the PREVIOUS period: push one row to the matrix ----
        if boxActive and not na(currentBoxTop) and not na(currentBoxOpen)
            float upImplied = currentBoxTop - currentBoxOpen
            float dnImplied = currentBoxOpen - currentBoxBottom
            float[] row = array.new_float(nCols, 0.0)

            for i = 0 to vixDivisions - 1
                float frac = (i + 1) * 1.0 / vixDivisions
                if curPeriodHigh >= currentBoxOpen + frac * upImplied
                    array.set(row, cUp + i, 1.0)
                if curPeriodLow <= currentBoxOpen - frac * dnImplied
                    array.set(row, cDn + i, 1.0)

            for j = 1 to sdLevels
                if curPeriodHigh >= currentBoxOpen + j * upImplied
                    array.set(row, cSdUp + (j - 1), 1.0)
                if curPeriodLow <= currentBoxOpen - j * dnImplied
                    array.set(row, cSdDn + (j - 1), 1.0)

            if extLevels > 0
                for i = 0 to extLevels - 1
                    float fracE = 1.0 + (i + 1) * extFrac
                    if curPeriodHigh >= currentBoxOpen + fracE * upImplied
                        array.set(row, cExtUp + i, 1.0)
                    if curPeriodLow <= currentBoxOpen - fracE * dnImplied
                        array.set(row, cExtDn + i, 1.0)

            // ---- per-level RACE outcomes (read from live state) ----
            for i = 0 to vixDivisions - 1
                if array.get(rUpLvl, i)
                    array.set(row, cRUp + i, 1.0)
                if array.get(cUpLvl, i)
                    array.set(row, cCUp + i, 1.0)
                if array.get(rDnLvl, i)
                    array.set(row, cRDn + i, 1.0)
                if array.get(cDnLvl, i)
                    array.set(row, cCDn + i, 1.0)
            for j = 0 to sdLevels - 1
                if array.get(rUpSD, j)
                    array.set(row, cRSdUp + j, 1.0)
                if array.get(cUpSD, j)
                    array.set(row, cCSdUp + j, 1.0)
                if array.get(rDnSD, j)
                    array.set(row, cRSdDn + j, 1.0)
                if array.get(cDnSD, j)
                    array.set(row, cCSdDn + j, 1.0)
            if extLevels > 0
                for i = 0 to extLevels - 1
                    if array.get(rUpExt, i)
                        array.set(row, cRExtUp + i, 1.0)
                    if array.get(cUpExt, i)
                        array.set(row, cCExtUp + i, 1.0)
                    if array.get(rDnExt, i)
                        array.set(row, cRExtDn + i, 1.0)
                    if array.get(cDnExt, i)
                        array.set(row, cCExtDn + i, 1.0)

            // ---- FIRST-TOUCH RACE outcomes (read from live state) ----
            for i = 0 to vixDivisions - 1
                if array.get(raceUpDiv, i)
                    array.set(row, cRcUp + i, 1.0)
                if array.get(raceDnDiv, i)
                    array.set(row, cRcDn + i, 1.0)
            if extLevels > 0
                for i = 0 to extLevels - 1
                    if array.get(raceUpExt, i)
                        array.set(row, cRcExtUp + i, 1.0)
                    if array.get(raceDnExt, i)
                        array.set(row, cRcExtDn + i, 1.0)
            for j = 0 to sdLevels - 1
                if array.get(raceUpSd, j)
                    array.set(row, cRcSdUp + j, 1.0)
                if array.get(raceDnSd, j)
                    array.set(row, cRcSdDn + j, 1.0)

            bool closedInside = close[1] < currentBoxTop and close[1] > currentBoxBottom
            if closedInside
                array.set(row, cInside, 1.0)
            if currentBoxBreached
                array.set(row, cBreach, 1.0)
                if closedInside
                    array.set(row, cBCI, 1.0)
                if retToMid
                    array.set(row, cRetMid, 1.0)
                if showRef
                    if touchedVwapFlag
                        array.set(row, cTVwap, 1.0)
                    for k = 0 to refBands - 1
                        if array.get(touchedUp, k)
                            array.set(row, cRefUp + k, 1.0)
                        if array.get(touchedDn, k)
                            array.set(row, cRefDn + k, 1.0)

            // ---- MOMENTUM PATH row (parallel matrix, pathStore columns) ----
            float[] prow = array.new_float(pathStore, -1.0)
            for k = 0 to pathStore - 1
                array.set(prow, k, array.get(periodPath, k) * 1.0)

            if matrix.rows(statM) >= rowCap
                matrix.remove_row(statM, 0)
            matrix.add_row(statM, matrix.rows(statM), row)

            if matrix.rows(pathM) >= rowCap
                matrix.remove_row(pathM, 0)
            matrix.add_row(pathM, matrix.rows(pathM), prow)

        doBuild := true

    if doBuild
        currentBoxOpen := open
        boxVixRef      := vixDailyClose
        boxActive      := true
        boxLeftBar     := bar_index
        sdDrawnUp      := false
        sdDrawnDn      := false
        seenBreachUp   := false
        seenBreachDn   := false
        retToMid       := false
        refVwap0        := pdVwap
        refSigma0       := pdSigma
        touchedVwapFlag := false
        for k = 0 to refBands - 1
            array.set(touchedUp, k, false)
            array.set(touchedDn, k, false)
        // reset per-level race state + first-touch race state
        for i = 0 to vixDivisions - 1
            array.set(tUpLvl, i, false)
            array.set(rUpLvl, i, false)
            array.set(cUpLvl, i, false)
            array.set(resUpLvl, i, false)
            array.set(tDnLvl, i, false)
            array.set(rDnLvl, i, false)
            array.set(cDnLvl, i, false)
            array.set(resDnLvl, i, false)
            array.set(raceUpDiv, i, false)
            array.set(raceDnDiv, i, false)
        for j = 0 to sdLevels - 1
            array.set(tUpSD, j, false)
            array.set(rUpSD, j, false)
            array.set(cUpSD, j, false)
            array.set(resUpSD, j, false)
            array.set(tDnSD, j, false)
            array.set(rDnSD, j, false)
            array.set(cDnSD, j, false)
            array.set(resDnSD, j, false)
            array.set(raceUpSd, j, false)
            array.set(raceDnSd, j, false)
        if extLevels > 0
            for i = 0 to extLevels - 1
                array.set(tUpExt, i, false)
                array.set(rUpExt, i, false)
                array.set(cUpExt, i, false)
                array.set(resUpExt, i, false)
                array.set(tDnExt, i, false)
                array.set(rDnExt, i, false)
                array.set(cDnExt, i, false)
                array.set(resDnExt, i, false)
                array.set(raceUpExt, i, false)
                array.set(raceDnExt, i, false)
        // reset momentum path (pathStore slots)
        for k = 0 to pathStore - 1
            array.set(periodPath, k, -1)
        array.set(pathLenArr, 0, 0)
        reachedUpFrac := 0.0
        reachedDnFrac := 0.0
        for i = 0 to nPathLvl - 1
            array.set(pathTouched, i, false)

        float periodIV = vixDailyClose / divisor
        float impliedPoints = currentBoxOpen * (periodIV / 100)
        curImpliedPoints := impliedPoints

        currentBoxTop      := currentBoxOpen + impliedPoints
        currentBoxBottom   := currentBoxOpen - impliedPoints
        currentBoxBreached := high > currentBoxTop or low < currentBoxBottom

        curPeriodHigh := high
        curPeriodLow  := low

        vixBox := box.new(left=bar_index, top=currentBoxTop, bottom=currentBoxBottom, right=bar_index + 1, bgcolor=color.new(vixBoxCol, boxOpacity), border_color=color.new(vixBorderCol, vixBorderTransp))

        array.clear(curUpLines)
        array.clear(curDnLines)
        array.clear(curUpLabels)
        array.clear(curDnLabels)
        array.clear(curUpLevels)
        array.clear(curDnLevels)
        array.clear(curUpSDLines)
        array.clear(curDnSDLines)
        array.clear(curUpSDLabels)
        array.clear(curDnSDLabels)
        array.clear(curUpExtLines)
        array.clear(curDnExtLines)
        array.clear(curUpExtLabels)
        array.clear(curDnExtLabels)

        curMidLine  := line.new(bar_index, currentBoxOpen, bar_index + 1, currentBoxOpen, color=midCol, width=2, style=line.style_solid)
        curMidLabel := label.new(bar_index + 1, currentBoxOpen, "MID 50% | Open (revert target for innermost level)", style=label.style_label_left, color=color.new(midCol, 70), textcolor=rangeLblTxtCol, size=size.small)

        for i = 0 to vixDivisions - 1
            float frac = (i + 1) * 1.0 / vixDivisions
            float upLevel = currentBoxOpen + frac * impliedPoints
            float dnLevel = currentBoxOpen - frac * impliedPoints

            line upL = line.new(bar_index, upLevel, bar_index + 1, upLevel, color=upRangeCol, width=1, style=line.style_solid)
            line dnL = line.new(bar_index, dnLevel, bar_index + 1, dnLevel, color=dnRangeCol, width=1, style=line.style_solid)
            label upLab = label.new(bar_index + 1, upLevel, "", style=label.style_label_left, color=color.new(upRangeCol, 70), textcolor=rangeLblTxtCol, size=size.small)
            label dnLab = label.new(bar_index + 1, dnLevel, "", style=label.style_label_left, color=color.new(dnRangeCol, 70), textcolor=rangeLblTxtCol, size=size.small)

            array.push(curUpLines, upL)
            array.push(curDnLines, dnL)
            array.push(curUpLabels, upLab)
            array.push(curDnLabels, dnLab)
            array.push(curUpLevels, upLevel)
            array.push(curDnLevels, dnLevel)

        // ---- Extension levels beyond the box (configurable step %, both sides) ----
        if extLevels > 0
            for i = 0 to extLevels - 1
                float fracE = 1.0 + (i + 1) * extFrac
                float upLevel = currentBoxOpen + fracE * impliedPoints
                float dnLevel = currentBoxOpen - fracE * impliedPoints

                line upL = line.new(bar_index, upLevel, bar_index + 1, upLevel, color=extCol, width=1, style=line.style_dotted)
                line dnL = line.new(bar_index, dnLevel, bar_index + 1, dnLevel, color=extCol, width=1, style=line.style_dotted)
                label upLab = label.new(bar_index + 1, upLevel, "", style=label.style_label_left, color=color.new(extCol, 70), textcolor=rangeLblTxtCol, size=size.small)
                label dnLab = label.new(bar_index + 1, dnLevel, "", style=label.style_label_left, color=color.new(extCol, 70), textcolor=rangeLblTxtCol, size=size.small)

                array.push(curUpExtLines, upL)
                array.push(curDnExtLines, dnL)
                array.push(curUpExtLabels, upLab)
                array.push(curDnExtLabels, dnLab)

    else if canTrack
        if boxActive and not na(vixBox)
            box.set_right(vixBox, bar_index)
            curPeriodHigh := math.max(curPeriodHigh, high)
            curPeriodLow  := math.min(curPeriodLow, low)
            if high > currentBoxTop or low < currentBoxBottom
                currentBoxBreached := true

            if not na(curMidLine)
                line.set_x2(curMidLine, bar_index)
                label.set_x(curMidLabel, bar_index)
            if array.size(curUpLines) > 0
                for i = 0 to array.size(curUpLines) - 1
                    line.set_x2(array.get(curUpLines, i), bar_index)
                    line.set_x2(array.get(curDnLines, i), bar_index)
                    label.set_x(array.get(curUpLabels, i), bar_index)
                    label.set_x(array.get(curDnLabels, i), bar_index)
            if array.size(curUpExtLines) > 0
                for i = 0 to array.size(curUpExtLines) - 1
                    line.set_x2(array.get(curUpExtLines, i), bar_index)
                    line.set_x2(array.get(curDnExtLines, i), bar_index)
                    label.set_x(array.get(curUpExtLabels, i), bar_index)
                    label.set_x(array.get(curDnExtLabels, i), bar_index)

    // ---- SEQUENTIAL BREACH / RETURN TRACKING (box-edge / 1σ, to open) ----
    if boxActive and canTrack and not na(currentBoxTop) and not na(currentBoxOpen)
        bool breachUpNow = high > currentBoxTop
        bool breachDnNow = low  < currentBoxBottom
        if (seenBreachUp or breachUpNow) and low  <= currentBoxOpen
            retToMid := true
        if (seenBreachDn or breachDnNow) and high >= currentBoxOpen
            retToMid := true
        if breachUpNow
            seenBreachUp := true
        if breachDnNow
            seenBreachDn := true

    // ---- PER-LEVEL FIRST-EVENT RACE: REVERT-TO-PRIOR vs CONTINUE-TO-NEXT ----
    if boxActive and canTrack and not na(currentBoxTop) and not na(currentBoxOpen)
        float upImp = currentBoxTop - currentBoxOpen
        float dnImp = currentBoxOpen - currentBoxBottom
        for i = 0 to vixDivisions - 1
            float frac   = (i + 1) * 1.0 / vixDivisions
            float innerF = f_innerFrac(frac, allFracs)
            float outerF = f_outerFrac(frac, allFracs)
            // UP
            if array.get(tUpLvl, i) and not array.get(resUpLvl, i)
                bool hitOuter = not na(outerF) and high >= currentBoxOpen + outerF * upImp
                bool hitInner = low <= currentBoxOpen + innerF * upImp
                if hitOuter
                    array.set(cUpLvl, i, true)
                    array.set(resUpLvl, i, true)
                else if hitInner
                    array.set(rUpLvl, i, true)
                    array.set(resUpLvl, i, true)
            if high >= currentBoxOpen + frac * upImp
                array.set(tUpLvl, i, true)
            // DN
            if array.get(tDnLvl, i) and not array.get(resDnLvl, i)
                bool hitOuterD = not na(outerF) and low <= currentBoxOpen - outerF * dnImp
                bool hitInnerD = high >= currentBoxOpen - innerF * dnImp
                if hitOuterD
                    array.set(cDnLvl, i, true)
                    array.set(resDnLvl, i, true)
                else if hitInnerD
                    array.set(rDnLvl, i, true)
                    array.set(resDnLvl, i, true)
            if low <= currentBoxOpen - frac * dnImp
                array.set(tDnLvl, i, true)
        for j = 1 to sdLevels
            float f      = j * 1.0
            float innerF = f_innerFrac(f, allFracs)
            float outerF = f_outerFrac(f, allFracs)
            if array.get(tUpSD, j - 1) and not array.get(resUpSD, j - 1)
                bool hitOuter = not na(outerF) and high >= currentBoxOpen + outerF * upImp
                bool hitInner = low <= currentBoxOpen + innerF * upImp
                if hitOuter
                    array.set(cUpSD, j - 1, true)
                    array.set(resUpSD, j - 1, true)
                else if hitInner
                    array.set(rUpSD, j - 1, true)
                    array.set(resUpSD, j - 1, true)
            if high >= currentBoxOpen + f * upImp
                array.set(tUpSD, j - 1, true)
            if array.get(tDnSD, j - 1) and not array.get(resDnSD, j - 1)
                bool hitOuterD = not na(outerF) and low <= currentBoxOpen - outerF * dnImp
                bool hitInnerD = high >= currentBoxOpen - innerF * dnImp
                if hitOuterD
                    array.set(cDnSD, j - 1, true)
                    array.set(resDnSD, j - 1, true)
                else if hitInnerD
                    array.set(rDnSD, j - 1, true)
                    array.set(resDnSD, j - 1, true)
            if low <= currentBoxOpen - f * dnImp
                array.set(tDnSD, j - 1, true)
        if extLevels > 0
            for i = 0 to extLevels - 1
                float fracE  = 1.0 + (i + 1) * extFrac
                float innerF = f_innerFrac(fracE, allFracs)
                float outerF = f_outerFrac(fracE, allFracs)
                if array.get(tUpExt, i) and not array.get(resUpExt, i)
                    bool hitOuter = not na(outerF) and high >= currentBoxOpen + outerF * upImp
                    bool hitInner = low <= currentBoxOpen + innerF * upImp
                    if hitOuter
                        array.set(cUpExt, i, true)
                        array.set(resUpExt, i, true)
                    else if hitInner
                        array.set(rUpExt, i, true)
                        array.set(resUpExt, i, true)
                if high >= currentBoxOpen + fracE * upImp
                    array.set(tUpExt, i, true)
                if array.get(tDnExt, i) and not array.get(resDnExt, i)
                    bool hitOuterD = not na(outerF) and low <= currentBoxOpen - outerF * dnImp
                    bool hitInnerD = high >= currentBoxOpen - innerF * dnImp
                    if hitOuterD
                        array.set(cDnExt, i, true)
                        array.set(resDnExt, i, true)
                    else if hitInnerD
                        array.set(rDnExt, i, true)
                        array.set(resDnExt, i, true)
                if low <= currentBoxOpen - fracE * dnImp
                    array.set(tDnExt, i, true)

    // ---- FIRST-TOUCH RACE: which SIDE (+X vs -X) is reached FIRST ----
    if boxActive and canTrack and not na(currentBoxTop) and not na(currentBoxOpen)
        float upImpRc = currentBoxTop - currentBoxOpen
        float dnImpRc = currentBoxOpen - currentBoxBottom
        bool  tieUp   = close >= currentBoxOpen
        for i = 0 to vixDivisions - 1
            if not (array.get(raceUpDiv, i) or array.get(raceDnDiv, i))
                float frac = (i + 1) * 1.0 / vixDivisions
                bool uH = high >= currentBoxOpen + frac * upImpRc
                bool dH = low  <= currentBoxOpen - frac * dnImpRc
                if uH and dH
                    if tieUp
                        array.set(raceUpDiv, i, true)
                    else
                        array.set(raceDnDiv, i, true)
                else if uH
                    array.set(raceUpDiv, i, true)
                else if dH
                    array.set(raceDnDiv, i, true)
        if extLevels > 0
            for i = 0 to extLevels - 1
                if not (array.get(raceUpExt, i) or array.get(raceDnExt, i))
                    float fracE = 1.0 + (i + 1) * extFrac
                    bool uH = high >= currentBoxOpen + fracE * upImpRc
                    bool dH = low  <= currentBoxOpen - fracE * dnImpRc
                    if uH and dH
                        if tieUp
                            array.set(raceUpExt, i, true)
                        else
                            array.set(raceDnExt, i, true)
                    else if uH
                        array.set(raceUpExt, i, true)
                    else if dH
                        array.set(raceDnExt, i, true)
        for j = 1 to sdLevels
            if not (array.get(raceUpSd, j - 1) or array.get(raceDnSd, j - 1))
                float f = j * 1.0
                bool uH = high >= currentBoxOpen + f * upImpRc
                bool dH = low  <= currentBoxOpen - f * dnImpRc
                if uH and dH
                    if tieUp
                        array.set(raceUpSd, j - 1, true)
                    else
                        array.set(raceDnSd, j - 1, true)
                else if uH
                    array.set(raceUpSd, j - 1, true)
                else if dH
                    array.set(raceDnSd, j - 1, true)

    // ---- MOMENTUM PATH: ordered distinct-level first-touch sequence ----
    // Track up to pathStore (= pathDepth+1) distinct touches: the opening
    // signature plus one 'next' slot. A 'Mid' event is only recorded once
    // price has reached at least the first division and returned to the open
    // (kills 1-tick-wobble noise).
    if boxActive and canTrack and not na(currentBoxTop) and not na(currentBoxOpen) and array.get(pathLenArr, 0) < pathStore
        float upImpP = currentBoxTop - currentBoxOpen
        float dnImpP = currentBoxOpen - currentBoxBottom
        float hUpP = upImpP > 0 ? (high - currentBoxOpen) / upImpP : 0.0
        float lDnP = dnImpP > 0 ? (currentBoxOpen - low) / dnImpP : 0.0
        bool  spansOpen = low <= currentBoxOpen and high >= currentBoxOpen
        float midThresh = 1.0 / vixDivisions
        bool  leftMid   = reachedUpFrac >= midThresh or reachedDnFrac >= midThresh
        bool  upCloseP  = close >= currentBoxOpen
        int   dummyPush = 0
        if upCloseP
            // assumed low-first: mid-return, then down levels (nearest-first), then up levels
            if leftMid and spansOpen
                dummyPush := f_pushPath(pathMidID, periodPath, pathTouched, pathLenArr, pathStore)
            for idx = array.size(pathFracs) - 1 to 0
                float f = array.get(pathFracs, idx)
                if f < -0.0000001 and (-f) <= lDnP
                    dummyPush := f_pushPath(idx, periodPath, pathTouched, pathLenArr, pathStore)
            for idx = 0 to array.size(pathFracs) - 1
                float f = array.get(pathFracs, idx)
                if f > 0.0000001 and f <= hUpP
                    dummyPush := f_pushPath(idx, periodPath, pathTouched, pathLenArr, pathStore)
        else
            // assumed high-first: up levels, then mid-return, then down levels
            for idx = 0 to array.size(pathFracs) - 1
                float f = array.get(pathFracs, idx)
                if f > 0.0000001 and f <= hUpP
                    dummyPush := f_pushPath(idx, periodPath, pathTouched, pathLenArr, pathStore)
            if leftMid and spansOpen
                dummyPush := f_pushPath(pathMidID, periodPath, pathTouched, pathLenArr, pathStore)
            for idx = array.size(pathFracs) - 1 to 0
                float f = array.get(pathFracs, idx)
                if f < -0.0000001 and (-f) <= lDnP
                    dummyPush := f_pushPath(idx, periodPath, pathTouched, pathLenArr, pathStore)
        reachedUpFrac := math.max(reachedUpFrac, hUpP)
        reachedDnFrac := math.max(reachedDnFrac, lDnP)

    // ---- VWAP touch tracking (only at/after a box breach) ----
    if showRef and boxActive and canTrack and (seenBreachUp or seenBreachDn) and not na(refVwap0)
        if low <= refVwap0 and high >= refVwap0
            touchedVwapFlag := true
        if not na(refSigma0) and refSigma0 > 0
            for k = 1 to refBands
                float u = refVwap0 + k * refSigma0
                float d = refVwap0 - k * refSigma0
                if low <= u and high >= u
                    array.set(touchedUp, k - 1, true)
                if low <= d and high >= d
                    array.set(touchedDn, k - 1, true)

    // ---- STANDARD DEVIATION BAND EXPANSION ----
    if boxActive and canTrack and not na(vixBox) and sdLevels >= 2 and not na(curImpliedPoints)
        if high > currentBoxTop and not sdDrawnUp
            for j = 2 to sdLevels
                float lvl = currentBoxOpen + j * curImpliedPoints
                line ln = line.new(boxLeftBar, lvl, bar_index, lvl, color=sdCol, width=1, style=line.style_dashed)
                label lb = label.new(bar_index, lvl, "", style=label.style_label_left, color=color.new(sdCol, 70), textcolor=rangeLblTxtCol, size=size.small)
                array.push(curUpSDLines, ln)
                array.push(curUpSDLabels, lb)
            sdDrawnUp := true
        if low < currentBoxBottom and not sdDrawnDn
            for j = 2 to sdLevels
                float lvl = currentBoxOpen - j * curImpliedPoints
                line ln = line.new(boxLeftBar, lvl, bar_index, lvl, color=sdCol, width=1, style=line.style_dashed)
                label lb = label.new(bar_index, lvl, "", style=label.style_label_left, color=color.new(sdCol, 70), textcolor=rangeLblTxtCol, size=size.small)
                array.push(curDnSDLines, ln)
                array.push(curDnSDLabels, lb)
            sdDrawnDn := true
        if array.size(curUpSDLines) > 0
            for k = 0 to array.size(curUpSDLines) - 1
                line.set_x2(array.get(curUpSDLines, k), bar_index)
                label.set_x(array.get(curUpSDLabels, k), bar_index)
        if array.size(curDnSDLines) > 0
            for k = 0 to array.size(curDnSDLines) - 1
                line.set_x2(array.get(curDnSDLines, k), bar_index)
                label.set_x(array.get(curDnSDLabels, k), bar_index)


// =========================================================================
// WINDOWED (LAST-N) AGGREGATION — runs on the last bar only
// With MOMENTUM OVERRIDE: only rows whose OPENING SIGNATURE (first pathDepth
// touches) matches the current period's signature are counted, so every stat
// becomes conditional. The signature length is FIXED — it does NOT deepen as
// the current period runs on.
// =========================================================================
if barstate.islast
    int totalRows = matrix.rows(statM)
    int nWin = math.min(totalRows, maxSamples)
    int pNow    = boxActive ? array.get(pathLenArr, 0) : 0
    bool useCond = pathOverride and boxActive
    int condLen  = math.min(pNow, pathDepth)   // FIXED opening-signature length (does NOT grow past pathDepth)
    gCond    := useCond
    gCondLen := condLen
    gWinAll  := nWin
    winTotal  := 0
    winInside := 0
    winBreach := 0
    winBCI    := 0
    winRetMid := 0
    winTVwap  := 0
    winBCIup  := 0
    winBCIdn  := 0
    for i = 0 to vixDivisions - 1
        array.set(winUpReach, i, 0)
        array.set(winDnReach, i, 0)
        array.set(winRUp, i, 0)
        array.set(winRDn, i, 0)
        array.set(winCUp, i, 0)
        array.set(winCDn, i, 0)
        array.set(winRaceUpDiv, i, 0)
        array.set(winRaceDnDiv, i, 0)
    for j = 0 to sdLevels - 1
        array.set(winSdUp, j, 0)
        array.set(winSdDn, j, 0)
        array.set(winRSdUp, j, 0)
        array.set(winRSdDn, j, 0)
        array.set(winCSdUp, j, 0)
        array.set(winCSdDn, j, 0)
        array.set(winRaceUpSd, j, 0)
        array.set(winRaceDnSd, j, 0)
    for k = 0 to refBands - 1
        array.set(winRefUp, k, 0)
        array.set(winRefDn, k, 0)
    if extLevels > 0
        for i = 0 to extLevels - 1
            array.set(winExtUp, i, 0)
            array.set(winExtDn, i, 0)
            array.set(winRExtUp, i, 0)
            array.set(winRExtDn, i, 0)
            array.set(winCExtUp, i, 0)
            array.set(winCExtDn, i, 0)
            array.set(winRaceUpExt, i, 0)
            array.set(winRaceDnExt, i, 0)

    if totalRows > 0 and nWin > 0
        for r = totalRows - nWin to totalRows - 1
            // ---- MOMENTUM OVERRIDE opening-signature match filter ----
            bool matchRow = true
            if useCond and condLen > 0
                for k = 0 to condLen - 1
                    if int(matrix.get(pathM, r, k)) != array.get(periodPath, k)
                        matchRow := false
            if matchRow
                winTotal += 1
                for i = 0 to vixDivisions - 1
                    array.set(winUpReach, i, array.get(winUpReach, i) + int(matrix.get(statM, r, cUp + i)))
                    array.set(winDnReach, i, array.get(winDnReach, i) + int(matrix.get(statM, r, cDn + i)))
                    array.set(winRUp, i, array.get(winRUp, i) + int(matrix.get(statM, r, cRUp + i)))
                    array.set(winRDn, i, array.get(winRDn, i) + int(matrix.get(statM, r, cRDn + i)))
                    array.set(winCUp, i, array.get(winCUp, i) + int(matrix.get(statM, r, cCUp + i)))
                    array.set(winCDn, i, array.get(winCDn, i) + int(matrix.get(statM, r, cCDn + i)))
                    array.set(winRaceUpDiv, i, array.get(winRaceUpDiv, i) + int(matrix.get(statM, r, cRcUp + i)))
                    array.set(winRaceDnDiv, i, array.get(winRaceDnDiv, i) + int(matrix.get(statM, r, cRcDn + i)))
                for j = 0 to sdLevels - 1
                    array.set(winSdUp, j, array.get(winSdUp, j) + int(matrix.get(statM, r, cSdUp + j)))
                    array.set(winSdDn, j, array.get(winSdDn, j) + int(matrix.get(statM, r, cSdDn + j)))
                    array.set(winRSdUp, j, array.get(winRSdUp, j) + int(matrix.get(statM, r, cRSdUp + j)))
                    array.set(winRSdDn, j, array.get(winRSdDn, j) + int(matrix.get(statM, r, cRSdDn + j)))
                    array.set(winCSdUp, j, array.get(winCSdUp, j) + int(matrix.get(statM, r, cCSdUp + j)))
                    array.set(winCSdDn, j, array.get(winCSdDn, j) + int(matrix.get(statM, r, cCSdDn + j)))
                    array.set(winRaceUpSd, j, array.get(winRaceUpSd, j) + int(matrix.get(statM, r, cRcSdUp + j)))
                    array.set(winRaceDnSd, j, array.get(winRaceDnSd, j) + int(matrix.get(statM, r, cRcSdDn + j)))
                if extLevels > 0
                    for i = 0 to extLevels - 1
                        array.set(winExtUp, i, array.get(winExtUp, i) + int(matrix.get(statM, r, cExtUp + i)))
                        array.set(winExtDn, i, array.get(winExtDn, i) + int(matrix.get(statM, r, cExtDn + i)))
                        array.set(winRExtUp, i, array.get(winRExtUp, i) + int(matrix.get(statM, r, cRExtUp + i)))
                        array.set(winRExtDn, i, array.get(winRExtDn, i) + int(matrix.get(statM, r, cRExtDn + i)))
                        array.set(winCExtUp, i, array.get(winCExtUp, i) + int(matrix.get(statM, r, cCExtUp + i)))
                        array.set(winCExtDn, i, array.get(winCExtDn, i) + int(matrix.get(statM, r, cCExtDn + i)))
                        array.set(winRaceUpExt, i, array.get(winRaceUpExt, i) + int(matrix.get(statM, r, cRcExtUp + i)))
                        array.set(winRaceDnExt, i, array.get(winRaceDnExt, i) + int(matrix.get(statM, r, cRcExtDn + i)))
                winInside += int(matrix.get(statM, r, cInside))
                winBreach += int(matrix.get(statM, r, cBreach))
                winBCI    += int(matrix.get(statM, r, cBCI))
                winRetMid += int(matrix.get(statM, r, cRetMid))
                winTVwap  += int(matrix.get(statM, r, cTVwap))
                if int(matrix.get(statM, r, cSdUp)) == 1 and int(matrix.get(statM, r, cInside)) == 1
                    winBCIup += 1
                if int(matrix.get(statM, r, cSdDn)) == 1 and int(matrix.get(statM, r, cInside)) == 1
                    winBCIdn += 1
                for k = 0 to refBands - 1
                    array.set(winRefUp, k, array.get(winRefUp, k) + int(matrix.get(statM, r, cRefUp + k)))
                    array.set(winRefDn, k, array.get(winRefDn, k) + int(matrix.get(statM, r, cRefDn + k)))

// =========================================================================
// MOMENTUM PATH: distribution of the touch that came AFTER the opening
// signature, across all historical periods that opened the same way.
// Conditions on the first condLen = min(currentChain, pathDepth) touches and
// tabulates touch[condLen].
// =========================================================================
if barstate.islast and showVIX
    for i = 0 to nPathLvl - 1
        array.set(pathNextCnt, i, 0)
    pathNoneCnt := 0
    pathDenom   := 0
    if boxActive
        int p = math.min(array.get(pathLenArr, 0), pathDepth)
        int totR = matrix.rows(pathM)
        int nW   = math.min(totR, maxSamples)
        if totR > 0 and nW > 0
            for r = totR - nW to totR - 1
                bool match = true
                if p > 0
                    for k = 0 to p - 1
                        if int(matrix.get(pathM, r, k)) != array.get(periodPath, k)
                            match := false
                if match
                    int nid = int(matrix.get(pathM, r, p))
                    pathDenom += 1
                    if nid < 0
                        pathNoneCnt += 1
                    else
                        array.set(pathNextCnt, nid, array.get(pathNextCnt, nid) + 1)

// =========================================================================
// 1σ-BREACH COUNTS (informational; also a natural denominator elsewhere)
// =========================================================================
var int condUpN = 0
var int condDnN = 0
if barstate.islast
    condUpN := array.size(winSdUp) > 0 ? array.get(winSdUp, 0) : 0
    condDnN := array.size(winSdDn) > 0 ? array.get(winSdDn, 0) : 0


// =========================================================================
// LIVE LABEL TEXT (OVERALL + REVERT-FIRST + CONTINUE-FIRST)
// (these read the win* arrays, so they are AUTOMATICALLY conditional when
//  Momentum Override is on)
// =========================================================================
if showVIX and barstate.islast and array.size(curUpLevels) > 0
    string condTag = gCond ? " [sig " + f_prefixStr(gCondLen, periodPath, pathFracs) + "]" : ""
    for i = 0 to vixDivisions - 1
        float frac   = (i + 1) * 1.0 / vixDivisions
        string sdTag = frac == 1.0 ? " (1σ)" : ""
        float innerF = f_innerFrac(frac, allFracs)
        float outerF = f_outerFrac(frac, allFracs)
        label.set_text(array.get(curUpLabels, i), f_lblText("+" + f_lvlPctStr(frac) + sdTag + condTag, array.get(winUpReach, i), winTotal, array.get(winRUp, i), innerF, array.get(winCUp, i), outerF, true))
        label.set_text(array.get(curDnLabels, i), f_lblText("-" + f_lvlPctStr(frac) + sdTag + condTag, array.get(winDnReach, i), winTotal, array.get(winRDn, i), innerF, array.get(winCDn, i), outerF, false))

if showVIX and barstate.islast and array.size(curUpExtLines) > 0
    for i = 0 to array.size(curUpExtLines) - 1
        float fracE  = 1.0 + (i + 1) * extFrac
        float innerF = f_innerFrac(fracE, allFracs)
        float outerF = f_outerFrac(fracE, allFracs)
        label.set_text(array.get(curUpExtLabels, i), f_lblText("+" + f_lvlPctStr(fracE), array.get(winExtUp, i), winTotal, array.get(winRExtUp, i), innerF, array.get(winCExtUp, i), outerF, true))
        label.set_text(array.get(curDnExtLabels, i), f_lblText("-" + f_lvlPctStr(fracE), array.get(winExtDn, i), winTotal, array.get(winRExtDn, i), innerF, array.get(winCExtDn, i), outerF, false))

if showVIX and barstate.islast and sdLevels >= 2
    if array.size(curUpSDLines) > 0
        for k = 0 to array.size(curUpSDLines) - 1
            int j = k + 2
            float f = j * 1.0
            float innerF = f_innerFrac(f, allFracs)
            float outerF = f_outerFrac(f, allFracs)
            label.set_text(array.get(curUpSDLabels, k), f_lblText("+" + str.tostring(j) + "σ", array.get(winSdUp, j - 1), winTotal, array.get(winRSdUp, j - 1), innerF, array.get(winCSdUp, j - 1), outerF, true))
    if array.size(curDnSDLines) > 0
        for k = 0 to array.size(curDnSDLines) - 1
            int j = k + 2
            float f = j * 1.0
            float innerF = f_innerFrac(f, allFracs)
            float outerF = f_outerFrac(f, allFracs)
            label.set_text(array.get(curDnSDLabels, k), f_lblText("-" + str.tostring(j) + "σ", array.get(winSdDn, j - 1), winTotal, array.get(winRSdDn, j - 1), innerF, array.get(winCSdDn, j - 1), outerF, false))

// =========================================================================
// STATS TABLE (compact, 5-column, bottom-right)
// =========================================================================
f_pctS(float num, float den) =>
    den > 0 ? str.tostring(num / den * 100, "#.#") + "%" : "N/A"

// fills one level row across the 5 grid columns
f_lvlRow(table t, int rowi, string nm, color nmCol, int num, int total, int revNum, float innerF, int contNum, float outerF, bool up) =>
    string sign   = up ? "+" : "-"
    string revTgt = (na(innerF) or innerF == 0) ? "Mid" : sign + f_lvlPctStr(innerF)
    string revS   = num > 0 ? revTgt + " " + str.tostring(revNum / num * 100, "#") + "%" : "—"
    string contS  = na(outerF) ? "—" : (num > 0 ? sign + f_lvlPctStr(outerF) + " " + str.tostring(contNum / num * 100, "#") + "%" : "—")
    string noneS  = na(outerF) ? "—" : (num > 0 ? str.tostring((num - revNum - contNum) / num * 100, "#") + "%" : "—")
    table.cell(t, 0, rowi, nm,               bgcolor=tblCellBgCol, text_color=nmCol,        text_size=size.tiny, text_halign=text.align_left)
    table.cell(t, 1, rowi, f_pctS(num, total), bgcolor=tblCellBgCol, text_color=tblCellTxtCol, text_size=size.tiny)
    table.cell(t, 2, rowi, revS,             bgcolor=tblCellBgCol, text_color=tblCellTxtCol, text_size=size.tiny)
    table.cell(t, 3, rowi, contS,            bgcolor=tblCellBgCol, text_color=tblCellTxtCol, text_size=size.tiny)
    table.cell(t, 4, rowi, noneS,            bgcolor=tblCellBgCol, text_color=tblCellTxtCol, text_size=size.tiny)

// first-touch race row: ↑1st / ↓1st / None (sum to 100%)
f_raceRow(table t, int rowi, string nm, int upN, int dnN, int total) =>
    string upS = total > 0 ? str.tostring(upN / total * 100, "#.#") + "%" : "—"
    string dnS = total > 0 ? str.tostring(dnN / total * 100, "#.#") + "%" : "—"
    int neitherN = total - upN - dnN
    string nS  = total > 0 ? str.tostring(neitherN / total * 100, "#.#") + "%" : "—"
    table.cell(t, 0, rowi, nm,  bgcolor=tblCellBgCol, text_color=tblCellTxtCol, text_size=size.tiny, text_halign=text.align_left)
    table.cell(t, 1, rowi, upS, bgcolor=tblCellBgCol, text_color=color.new(color.lime, 0), text_size=size.tiny)
    table.cell(t, 2, rowi, dnS, bgcolor=tblCellBgCol, text_color=color.new(color.red, 0),  text_size=size.tiny)
    table.cell(t, 3, rowi, nS,  bgcolor=tblCellBgCol, text_color=color.gray, text_size=size.tiny)
    table.cell(t, 4, rowi, "",  bgcolor=tblCellBgCol, text_size=size.tiny)

// momentum-path candidate row: name | P(next) | n
f_pathRow(table t, int rowi, string nm, color nmCol, int cnt, int den) =>
    string pS = den > 0 ? str.tostring(cnt / den * 100, "#.#") + "%" : "—"
    table.cell(t, 0, rowi, nm, bgcolor=tblCellBgCol, text_color=nmCol, text_size=size.tiny, text_halign=text.align_left)
    table.cell(t, 1, rowi, pS, bgcolor=tblCellBgCol, text_color=tblCellTxtCol, text_size=size.tiny)
    table.cell(t, 2, rowi, str.tostring(cnt), bgcolor=tblCellBgCol, text_color=tblCellTxtCol, text_size=size.tiny)
    table.cell(t, 3, rowi, "", bgcolor=tblCellBgCol, text_size=size.tiny)
    table.cell(t, 4, rowi, "", bgcolor=tblCellBgCol, text_size=size.tiny)

// info/summary row: label in col0, value spanning col1-4
f_infoRow(table t, int rowi, string lbl, color lblCol, string val, color valCol) =>
    table.cell(t, 0, rowi, lbl, bgcolor=tblCellBgCol, text_color=lblCol, text_size=size.tiny, text_halign=text.align_left)
    table.cell(t, 1, rowi, val, bgcolor=tblCellBgCol, text_color=valCol, text_size=size.tiny)
    table.cell(t, 2, rowi, "",  bgcolor=tblCellBgCol, text_size=size.tiny)
    table.cell(t, 3, rowi, "",  bgcolor=tblCellBgCol, text_size=size.tiny)
    table.cell(t, 4, rowi, "",  bgcolor=tblCellBgCol, text_size=size.tiny)
    table.merge_cells(t, 1, rowi, 4, rowi)

var table statsTable = table.new(position.bottom_right, 5, 300, border_width=1, border_color=tblBorderCol)

if barstate.islast and showTable
    string vixBoxStatus = "N/A"
    color  vixStatusCol = tblCellTxtCol
    if showVIX and not na(currentBoxTop) and not na(curImpliedPoints) and curImpliedPoints != 0
        if close > currentBoxTop
            vixBoxStatus := "Outside ↑ " + str.tostring((close - currentBoxOpen) / curImpliedPoints, "#.#") + "σ"
            vixStatusCol := color.yellow
        else if close < currentBoxBottom
            vixBoxStatus := "Outside ↓ " + str.tostring((currentBoxOpen - close) / curImpliedPoints, "#.#") + "σ"
            vixStatusCol := color.red
        else
            vixBoxStatus := "Inside " + str.tostring(math.abs(close - currentBoxOpen) / curImpliedPoints, "#.##") + "σ"
            vixStatusCol := color.yellow

    float refVix    = na(boxVixRef) ? vixDailyClose : boxVixRef
    float impliedPct = refVix / divisor
    string vixValStr = str.tostring(refVix, "#.##") + " (" + str.tostring(impliedPct, "#.##") + "%)"

    int r = 0

    // ---- Header ----
    string hdrName = gCond ? "IV Ranges (COND)" : "IV Ranges"
    table.cell(statsTable, 0, r, hdrName, bgcolor=tblHeadBgCol, text_color=(gCond ? color.yellow : tblHeadTxtCol), text_size=size.tiny, text_halign=text.align_left)
    table.cell(statsTable, 1, r, "Reach",     bgcolor=tblHeadBgCol, text_color=tblHeadTxtCol, text_size=size.tiny)
    table.cell(statsTable, 2, r, "→Rev",      bgcolor=tblHeadBgCol, text_color=tblHeadTxtCol, text_size=size.tiny)
    table.cell(statsTable, 3, r, "→Cont",     bgcolor=tblHeadBgCol, text_color=tblHeadTxtCol, text_size=size.tiny)
    table.cell(statsTable, 4, r, "None",      bgcolor=tblHeadBgCol, text_color=tblHeadTxtCol, text_size=size.tiny)
    r += 1

    // ---- Info block ----
    if not showVIX
        f_infoRow(statsTable, r, "Status", tblCellTxtCol, "Disabled", color.gray)
        r += 1
    else
        string modeTag = useSession ? (dayMode == "RTH Session" ? " · RTH" : " · ETH") : ""
        f_infoRow(statsTable, r, effName + " " + vixPeriod + modeTag + " IV", tblCellTxtCol, vixValStr, color.white)
        r += 1
        string sampVal = gCond ? (str.tostring(winTotal) + " matched / " + str.tostring(gWinAll)) : (str.tostring(winTotal) + (winTotal >= maxSamples ? " (cap " + str.tostring(maxSamples) + ")" : ""))
        f_infoRow(statsTable, r, gCond ? "Samples (cond)" : "Samples", gCond ? color.yellow : tblCellTxtCol, sampVal, color.white)
        r += 1
        if gCond
            f_infoRow(statsTable, r, "Opening signature", midCol, f_prefixStr(gCondLen, periodPath, pathFracs), tblCellTxtCol)
            r += 1
        f_infoRow(statsTable, r, "1σ Breach " + anomalyTag + " ↑/↓", extCol, str.tostring(condUpN) + " / " + str.tostring(condDnN), tblCellTxtCol)
        r += 1
        f_infoRow(statsTable, r, "Box Status", tblCellTxtCol, vixBoxStatus, vixStatusCol)
        r += 1

    if showVIX and winTotal > 0
        // ---- UP: SD bands (farthest first) ----
        if sdLevels >= 2
            for j = sdLevels to 2
                float f = j * 1.0
                f_lvlRow(statsTable, r, "+" + str.tostring(j) + "σ", sdCol, array.get(winSdUp, j - 1), winTotal, array.get(winRSdUp, j - 1), f_innerFrac(f, allFracs), array.get(winCSdUp, j - 1), f_outerFrac(f, allFracs), true)
                r += 1
        // ---- UP: extension levels (farthest first) ----
        if extLevels > 0
            for i = extLevels - 1 to 0
                float fracE = 1.0 + (i + 1) * extFrac
                f_lvlRow(statsTable, r, "+" + f_lvlPctStr(fracE), extCol, array.get(winExtUp, i), winTotal, array.get(winRExtUp, i), f_innerFrac(fracE, allFracs), array.get(winCExtUp, i), f_outerFrac(fracE, allFracs), true)
                r += 1
        // ---- UP: in-box divisions (edge first) ----
        for i = vixDivisions - 1 to 0
            float frac = (i + 1) * 1.0 / vixDivisions
            string sdTag = frac == 1.0 ? "σ" : ""
            f_lvlRow(statsTable, r, "+" + f_lvlPctStr(frac) + sdTag, upRangeCol, array.get(winUpReach, i), winTotal, array.get(winRUp, i), f_innerFrac(frac, allFracs), array.get(winCUp, i), f_outerFrac(frac, allFracs), true)
            r += 1

        f_infoRow(statsTable, r, "MID 50% / Open", midCol, "revert target", tblCellTxtCol)
        r += 1

        // ---- DOWN: in-box divisions (near first) ----
        for i = 0 to vixDivisions - 1
            float frac = (i + 1) * 1.0 / vixDivisions
            string sdTag = frac == 1.0 ? "σ" : ""
            f_lvlRow(statsTable, r, "-" + f_lvlPctStr(frac) + sdTag, dnRangeCol, array.get(winDnReach, i), winTotal, array.get(winRDn, i), f_innerFrac(frac, allFracs), array.get(winCDn, i), f_outerFrac(frac, allFracs), false)
            r += 1
        // ---- DOWN: extension levels ----
        if extLevels > 0
            for i = 0 to extLevels - 1
                float fracE = 1.0 + (i + 1) * extFrac
                f_lvlRow(statsTable, r, "-" + f_lvlPctStr(fracE), extCol, array.get(winExtDn, i), winTotal, array.get(winRExtDn, i), f_innerFrac(fracE, allFracs), array.get(winCExtDn, i), f_outerFrac(fracE, allFracs), false)
                r += 1
        // ---- DOWN: SD bands ----
        if sdLevels >= 2
            for j = 2 to sdLevels
                float f = j * 1.0
                f_lvlRow(statsTable, r, "-" + str.tostring(j) + "σ", sdCol, array.get(winSdDn, j - 1), winTotal, array.get(winRSdDn, j - 1), f_innerFrac(f, allFracs), array.get(winCSdDn, j - 1), f_outerFrac(f, allFracs), false)
                r += 1

        // ---- FIRST-TOUCH RACE (mutually exclusive: ↑1st + ↓1st + None = 100%) ----
        if showRace
            table.cell(statsTable, 0, r, "First-Touch ±", bgcolor=tblHeadBgCol, text_color=tblHeadTxtCol, text_size=size.tiny, text_halign=text.align_left)
            table.cell(statsTable, 1, r, "↑1st", bgcolor=tblHeadBgCol, text_color=tblHeadTxtCol, text_size=size.tiny)
            table.cell(statsTable, 2, r, "↓1st", bgcolor=tblHeadBgCol, text_color=tblHeadTxtCol, text_size=size.tiny)
            table.cell(statsTable, 3, r, "None", bgcolor=tblHeadBgCol, text_color=tblHeadTxtCol, text_size=size.tiny)
            table.cell(statsTable, 4, r, "",     bgcolor=tblHeadBgCol, text_size=size.tiny)
            r += 1
            for i = 0 to vixDivisions - 1
                float frac = (i + 1) * 1.0 / vixDivisions
                string sdTag = frac == 1.0 ? "σ" : ""
                f_raceRow(statsTable, r, "±" + f_lvlPctStr(frac) + sdTag, array.get(winRaceUpDiv, i), array.get(winRaceDnDiv, i), winTotal)
                r += 1
            if extLevels > 0
                for i = 0 to extLevels - 1
                    float fracE = 1.0 + (i + 1) * extFrac
                    f_raceRow(statsTable, r, "±" + f_lvlPctStr(fracE), array.get(winRaceUpExt, i), array.get(winRaceDnExt, i), winTotal)
                    r += 1
            if sdLevels >= 2
                for j = 2 to sdLevels
                    f_raceRow(statsTable, r, "±" + str.tostring(j) + "σ", array.get(winRaceUpSd, j - 1), array.get(winRaceDnSd, j - 1), winTotal)
                    r += 1

        // ---- MOMENTUM PATH (distribution of the touch AFTER the opening signature) ----
        if showPath and boxActive
            table.cell(statsTable, 0, r, "After Signature →", bgcolor=pathHdrCol, text_color=tblHeadTxtCol, text_size=size.tiny, text_halign=text.align_left)
            table.cell(statsTable, 1, r, "P(next)", bgcolor=pathHdrCol, text_color=tblHeadTxtCol, text_size=size.tiny)
            table.cell(statsTable, 2, r, "n",       bgcolor=pathHdrCol, text_color=tblHeadTxtCol, text_size=size.tiny)
            table.cell(statsTable, 3, r, "",        bgcolor=pathHdrCol, text_size=size.tiny)
            table.cell(statsTable, 4, r, "",        bgcolor=pathHdrCol, text_size=size.tiny)
            r += 1
            int plenFull = array.get(pathLenArr, 0)
            int sigLen   = math.min(plenFull, pathDepth)
            f_infoRow(statsTable, r, "Touched (full)", midCol, f_prefixStr(plenFull, periodPath, pathFracs), tblCellTxtCol)
            r += 1
            f_infoRow(statsTable, r, "Signature", midCol, f_prefixStr(sigLen, periodPath, pathFracs), tblCellTxtCol)
            r += 1
            if pathDenom == 0
                f_infoRow(statsTable, r, "No prior match", tblCellTxtCol, "(unique opening)", color.gray)
                r += 1
            else
                f_infoRow(statsTable, r, "Matched (n)", tblCellTxtCol, str.tostring(pathDenom), color.white)
                r += 1
                for idx = array.size(pathFracs) - 1 to 0
                    int c = array.get(pathNextCnt, idx)
                    if c > 0
                        float fr = array.get(pathFracs, idx)
                        color nmC = math.abs(fr) < 0.0000001 ? midCol : (fr > 0 ? upRangeCol : dnRangeCol)
                        f_pathRow(statsTable, r, f_pathName(fr), nmC, c, pathDenom)
                        r += 1
                if pathNoneCnt > 0
                    f_pathRow(statsTable, r, "None (ended)", color.gray, pathNoneCnt, pathDenom)
                    r += 1

        // ---- Summary block ----
        f_infoRow(statsTable, r, "Close Inside 1σ", tblCellTxtCol, f_pctS(winInside, winTotal) + " (" + str.tostring(winInside) + "/" + str.tostring(winTotal) + ")", tblCellTxtCol)
        r += 1
        f_infoRow(statsTable, r, "Breached 1σ (wick)", tblCellTxtCol, f_pctS(winBreach, winTotal) + " (" + str.tostring(winBreach) + "/" + str.tostring(winTotal) + ")", tblCellTxtCol)
        r += 1

        if winBreach > 0
            f_infoRow(statsTable, r, "Breach→Within 1σ", color.yellow, f_pctS(winBCI, winBreach) + " (" + str.tostring(winBCI) + "/" + str.tostring(winBreach) + ")", tblCellTxtCol)
            r += 1
            f_infoRow(statsTable, r, "Breach→Midpoint", color.yellow, f_pctS(winRetMid, winBreach) + " (" + str.tostring(winRetMid) + "/" + str.tostring(winBreach) + ")", tblCellTxtCol)
            r += 1
            if condUpN > 0
                f_infoRow(statsTable, r, "Breach↑→Close in 1σ", color.yellow, f_pctS(winBCIup, condUpN) + " (" + str.tostring(winBCIup) + "/" + str.tostring(condUpN) + ")", tblCellTxtCol)
                r += 1
            if condDnN > 0
                f_infoRow(statsTable, r, "Breach↓→Close in 1σ", color.yellow, f_pctS(winBCIdn, condDnN) + " (" + str.tostring(winBCIdn) + "/" + str.tostring(condDnN) + ")", tblCellTxtCol)
                r += 1
            if showRef
                f_infoRow(statsTable, r, "Breach→VWAP", refVwapCol, f_pctS(winTVwap, winBreach) + " (" + str.tostring(winTVwap) + "/" + str.tostring(winBreach) + ")", tblCellTxtCol)
                r += 1
                for k = 1 to refBands
                    f_infoRow(statsTable, r, "  →VWAP +" + str.tostring(k) + "σ", refBandCol, f_pctS(array.get(winRefUp, k - 1), winBreach), tblCellTxtCol)
                    r += 1
                    f_infoRow(statsTable, r, "  →VWAP -" + str.tostring(k) + "σ", refBandCol, f_pctS(array.get(winRefDn, k - 1), winBreach), tblCellTxtCol)
                    r += 1
    else if showVIX and gCond
        f_infoRow(statsTable, r, "No cond. matches", color.gray, "shorten signature / more history", color.gray)
        r += 1
````
