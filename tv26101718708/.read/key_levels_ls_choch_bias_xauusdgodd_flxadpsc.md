# Key Levels + LS + ChoCh + Bias - [XAUUSDGODD]

- url: https://www.tradingview.com/script/fLXadPsC-Key-Levels-LS-ChoCh-Bias-XAUUSDGODD/
- type: indicator
- pine_id: PUB;43f41c1693a344c7beb974f55ea1434b
- version: 1.0

## Description

A minimalist SMC / liquidity toolkit that maps the key levels price reacts to, flags when liquidity is swept, tracks the resulting change of character, and gives you a higher-timeframe directional bias — all on one clean overlay. Built with gold (XAUUSD) in mind, but works on any symbol.

**What it plots**

- **Multi-timeframe key levels (1H / 4H / 1D):** highs and lows drawn as horizontal lines that follow price to the current bar and don't project into empty space. Each level is labelled with its timeframe and its liquidity side — BSL (buy-side, above highs) or SSL (sell-side, below lows).
- **Session highs and lows (Asia / London / New York):** fully customizable session hours and timezone (default UTC+2). Choose between absolute session high/low or a swing-based definition.
- **Liquidity Sweep (LS):** a level is marked as swept when price takes its liquidity — by wick, by a close-beyond-then-close-back sequence, or either (your choice). Swept levels fade out or are removed to keep the chart clean.
- **Change of Character (ChoCh):** after a sweep, the structure level that needs to break is drawn dotted while pending and turns solid the moment a close actually breaks it. It auto-invalidates if price closes back beyond the sweep, or expires after a set number of bars.
- **Daily bias panel:** a compact corner table showing 4H bias, 1H bias, and the combined daily bias, derived from market-structure breaks (BOS) on each timeframe. Flags ·mix when the two timeframes disagree.

**How the levels are defined**

A high is the higher wick of a bullish-then-bearish candle pair; a low is the lower wick of a bearish-then-bullish pair. Higher-timeframe levels are read from closed candles (non-repainting). When several levels stack at the same price, their labels are automatically merged into one multi-line label (tolerance adjustable via ATR) so text never overlaps.

**Settings**

- **Key levels:** toggle 1H / 4H / 1D, number of levels per timeframe, line style.
- **Sessions:** enable Asia / London / NY, set hours and timezone, line style and transparency, high-low or swing mode.
- **Setup:** show LS / ChoCh, sweep mode (Wick / Close / Both), double-close window, ChoCh window, invalidation on/off.
- **Swept levels:** fade or delete, swept color.
- **Colors & style:** BSL / SSL and setup colors, line width, label size, label offset, label merging and tolerance.
- **Daily bias:** show panel, panel position, neutral color.

**Suggested use**

Use the key levels and session liquidity as your map of where price is likely to react. Wait for an LS into one of those pools, let the ChoCh confirm the shift, and trade in line with the daily bias for confluence. The setup logic runs on whatever timeframe the chart is set to.

**Notes**

Real-time LS / ChoCh signals evaluate on the live candle and settle on close — this is inherent to live trading, not a bug. The bias starts as Neutral until the first confirmed break of structure on each timeframe. This is an analysis tool, not financial advice; it draws no entries, stop losses or take profits.

## Source Code

````pine
//@version=6
// =============================================================================
//  Key Levels + Liquidity Sweep / ChoCh + Daily Bias  —  minimalist
//  Key levels (1H/4H/1D) + sessions (Asia/London/NY) as finite horizontal lines
//  that follow price. Setup (LS -> ChoCh) on the chart TF. Daily bias from
//  4H + 1H market structure (BOS). No entry / TP / SL / iFVG.
// =============================================================================

indicator("Key Levels · LS · ChoCh · Bias", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 50)

// ============================== INPUTS =======================================
gTF = "Key levels (timeframes)"
use1H = input.bool(true, "1H", group = gTF, inline = "tf")
use4H = input.bool(true, "4H", group = gTF, inline = "tf")
use1D = input.bool(true, "1D", group = gTF, inline = "tf")
htfHistory = input.int(6, "Levels per TF", minval = 1, maxval = 30, group = gTF)
htfStyleS  = input.string("Solid", "HTF line style", options = ["Solid", "Dashed", "Dotted"], group = gTF)

gS = "Sessions"
useAsia    = input.bool(true,  "Asia",     group = gS, inline = "a")
asiaSess   = input.session("0200-1100", "", group = gS, inline = "a")
useLondon  = input.bool(true,  "London",   group = gS, inline = "l")
londonSess = input.session("0900-1800", "", group = gS, inline = "l")
useNY      = input.bool(true,  "New York", group = gS, inline = "n")
nySess     = input.session("1400-2300", "", group = gS, inline = "n")
tz         = input.string("UTC+2", "Timezone", tooltip = "E.g. UTC+2, UTC, America/New_York.", group = gS)
sessHistory= input.int(2, "Sessions per type", minval = 1, maxval = 10, group = gS)
sessStyleS = input.string("Dashed", "Session line style", options = ["Solid", "Dashed", "Dotted"], group = gS)
sessTransp = input.int(35, "Session line transparency", minval = 0, maxval = 90, group = gS)
sessLevelType = input.string("High / Low", "Session levels", options = ["High / Low", "Swing (bull-bear)"], group = gS)

gSet = "Setup (chart timeframe)"
showSetup       = input.bool(true,  "Show LS / ChoCh", group = gSet)
sweepMode       = input.string("Both", "LS mode", options = ["Wick", "Close", "Both"], group = gSet, tooltip = "Wick: pierced by wick. Close: close beyond then close back. Both: either.")
lsWindow        = input.int(10, "Double-close window (bars)", minval = 2, maxval = 100, group = gSet)
chochWindow     = input.int(30, "ChoCh window (bars)", minval = 3, maxval = 300, group = gSet)
useInvalidation = input.bool(true, "Invalidate if close beyond sweep", group = gSet)

gSw = "Swept levels"
sweptAction = input.string("Fade", "When swept", options = ["Fade", "Delete"], group = gSw)
sweptColor  = input.color(color.new(#787b86, 55), "Swept color", group = gSw)

gC = "Colors & style"
bslColor  = input.color(color.new(#34d1bf, 0), "BSL (highs)", group = gC)
sslColor  = input.color(color.new(#ef6a5a, 0), "SSL (lows)",  group = gC)
bullCol   = input.color(color.new(#34d1bf, 0), "Bullish setup", group = gC)
bearCol   = input.color(color.new(#ef6a5a, 0), "Bearish setup", group = gC)
lineWidth = input.int(1, "Line width", minval = 1, maxval = 4, group = gC)
labelOff  = input.int(6, "Label offset (bars)", minval = 0, maxval = 40, group = gC)
labelSzS  = input.string("Small", "Label size", options = ["Small", "Normal"], group = gC)
mergeLabels  = input.bool(true, "Merge overlapping labels", group = gC)
mergeTolMult = input.float(0.2, "Overlap tolerance (×ATR)", minval = 0.0, step = 0.05, group = gC, tooltip = "Levels closer than this are grouped into one label.")

gB = "Daily bias"
showBias   = input.bool(true, "Show daily bias", group = gB)
biasPosS   = input.string("Top right", "Panel position", options = ["Top right","Top left","Bottom right","Bottom left","Middle right"], group = gB)
neutralCol = input.color(color.new(#b2b5be, 0), "Neutral color", group = gB)

// ============================ HELPERS ========================================
mapStyle(simple string s) =>
    s == "Dashed" ? line.style_dashed : s == "Dotted" ? line.style_dotted : line.style_solid
mapSize(simple string s) =>
    s == "Normal" ? size.normal : size.small
biasTxt(int b) => b == 1 ? "Bullish" : b == -1 ? "Bearish" : "Neutral"
biasCol(int b) => b == 1 ? bullCol : b == -1 ? bearCol : neutralCol
mapPos(simple string p) =>
    p == "Top left" ? position.top_left : p == "Bottom right" ? position.bottom_right : p == "Bottom left" ? position.bottom_left : p == "Middle right" ? position.middle_right : position.top_right

htfLineStyle  = mapStyle(htfStyleS)
sessLineStyle = mapStyle(sessStyleS)
lblSize       = mapSize(labelSzS)
useSwingSess  = sessLevelType != "High / Low"
atr           = ta.atr(14)

// =============================== TYPES =======================================
type Level
    line   ln
    label  lb
    float  price
    bool   isHigh
    bool   taken
    string tag
    int    sState
    int    sBar

type Setup
    int   bias
    int   phase
    float sweepExt
    float ref
    int   refBar
    int   lsBar
    line  chochLine
    label chochLbl

// =========================== LEVEL FUNCTIONS =================================
addLevel(array<Level> arr, int maxN, float price, int t, bool isHigh, string tag, color col, int w, string lstyle) =>
    line ln = line.new(x1 = t, y1 = price, x2 = t, y2 = price, xloc = xloc.bar_time, extend = extend.none, color = col, width = w, style = lstyle)
    string lqt = isHigh ? "BSL" : "SSL"
    label lb = label.new(x = bar_index + labelOff, y = price, text = tag + " · " + lqt, xloc = xloc.bar_index, style = label.style_label_left, color = color.new(col, 100), textcolor = col, size = lblSize)
    Level lvl = Level.new(ln, lb, price, isHigh, false, tag, 0, na)
    array.push(arr, lvl)
    if array.size(arr) > maxN
        Level old = array.shift(arr)
        if not na(old.ln)
            line.delete(old.ln)
        if not na(old.lb)
            label.delete(old.lb)

extendLevels(array<Level> arr) =>
    int n = array.size(arr)
    if n > 0
        for i = 0 to n - 1
            Level lvl = array.get(arr, i)
            if not lvl.taken and not na(lvl.ln)
                line.set_x2(lvl.ln, time)

collectLabels(array<Level> src, array<Level> dst) =>
    int n = array.size(src)
    if n > 0
        for i = 0 to n - 1
            Level lvl = array.get(src, i)
            if not lvl.taken and not na(lvl.lb)
                array.push(dst, lvl)

// =========================== SETUP FUNCTIONS ================================
clearSetup(Setup s) =>
    if not na(s.chochLine)
        line.delete(s.chochLine)
        s.chochLine := na
    if not na(s.chochLbl)
        label.delete(s.chochLbl)
        s.chochLbl := na
    s.bias  := 0
    s.phase := 0
    s.sweepExt := na
    s.ref   := na
    s.refBar := na
    s.lsBar := na

armSetup(Setup s, int bias, float ext, float ref, int refBar) =>
    clearSetup(s)
    s.bias  := bias
    s.phase := 1
    s.sweepExt := ext
    s.ref   := ref
    s.refBar := refBar
    s.lsBar := bar_index
    color cc = bias == 1 ? bullCol : bearCol
    s.chochLine := line.new(x1 = refBar, y1 = ref, x2 = bar_index, y2 = ref, xloc = xloc.bar_index, extend = extend.none, color = cc, width = 1, style = line.style_dotted)
    s.chochLbl  := label.new(x = bar_index + labelOff, y = ref, text = "ChoCH", xloc = xloc.bar_index, style = label.style_label_left, color = color.new(cc, 100), textcolor = cc, size = lblSize)

checkSweeps(array<Level> arr, Setup s, float swH, int swHBar, float swL, int swLBar) =>
    int n = array.size(arr)
    if n > 0
        for i = 0 to n - 1
            Level lvl = array.get(arr, i)
            if not lvl.taken and not na(lvl.ln)
                bool modeA = (sweepMode != "Close") and (lvl.isHigh ? high > lvl.price : low < lvl.price)
                bool closeBeyond = lvl.isHigh ? close > lvl.price : close < lvl.price
                bool closeBack   = lvl.isHigh ? close < lvl.price : close > lvl.price
                bool modeB = false
                if sweepMode != "Wick"
                    if lvl.sState == 0
                        if closeBeyond
                            lvl.sState := 1
                            lvl.sBar   := bar_index
                    else
                        if bar_index - lvl.sBar > lsWindow
                            lvl.sState := 0
                        else if closeBack
                            modeB := true
                bool ls = modeA or modeB
                if ls
                    lvl.taken := true
                    if not na(lvl.lb)
                        label.delete(lvl.lb)
                        lvl.lb := na
                    if sweptAction == "Delete"
                        if not na(lvl.ln)
                            line.delete(lvl.ln)
                            lvl.ln := na
                    else
                        if not na(lvl.ln)
                            line.set_x2(lvl.ln, time)
                            line.set_style(lvl.ln, line.style_dotted)
                            line.set_color(lvl.ln, sweptColor)
                    if showSetup
                        int   bias = lvl.isHigh ? -1 : 1
                        float ext  = lvl.isHigh ? high : low
                        float ref  = lvl.isHigh ? swL : swH
                        int   rBar = lvl.isHigh ? swLBar : swHBar
                        if not na(ref)
                            armSetup(s, bias, ext, ref, rBar)

// =============================== STATE =======================================
var array<Level> lv1H     = array.new<Level>()
var array<Level> lv4H     = array.new<Level>()
var array<Level> lv1D     = array.new<Level>()
var array<Level> lvAsia   = array.new<Level>()
var array<Level> lvLondon = array.new<Level>()
var array<Level> lvNY     = array.new<Level>()
var array<float> stAsia   = array.new<float>(7, 0.0)
var array<float> stLondon = array.new<float>(7, 0.0)
var array<float> stNY     = array.new<float>(7, 0.0)

var Setup S = Setup.new(0, 0, na, na, na, na, na, na)

var float lastSwH    = na
var int   lastSwHBar = na
var float lastSwL    = na
var int   lastSwLBar = na

// =================== HTF SWING DETECTION (non-repaint) ======================
detectSwing(simple string tf) =>
    [o0, h0, l0, c0, t0, o1, h1, l1, c1, t1] = request.security(syminfo.tickerid, tf, [open[1], high[1], low[1], close[1], time[1], open[2], high[2], low[2], close[2], time[2]], lookahead = barmerge.lookahead_on)
    bool  newBar = t0 != t0[1]
    bool  isH = false
    bool  isL = false
    float hP  = na
    int   hT  = na
    float lP  = na
    int   lT  = na
    if newBar and not na(t1)
        bool bull1 = c1 > o1
        bool bear1 = c1 < o1
        bool bull0 = c0 > o0
        bool bear0 = c0 < o0
        if bull1 and bear0
            isH := true
            hP  := math.max(h1, h0)
            hT  := h1 >= h0 ? t1 : t0
        if bear1 and bull0
            isL := true
            lP  := math.min(l1, l0)
            lT  := l1 <= l0 ? t1 : t0
    [isH, hP, hT, isL, lP, lT]

handleSession(simple string sess, bool en, simple string tzin, string name, color colHigh, color colLow, array<Level> arr, array<float> st, bool useSwing) =>
    if en
        bool inS   = not na(time(timeframe.period, sess, tzin))
        bool wasIn = array.get(st, 4) == 1
        if inS and not wasIn
            if useSwing
                array.set(st, 0, na)
                array.set(st, 1, na)
                array.set(st, 2, na)
                array.set(st, 3, na)
                array.set(st, 5, 0.0)
                array.set(st, 6, 0.0)
            else
                array.set(st, 0, high)
                array.set(st, 1, low)
                array.set(st, 2, float(time))
                array.set(st, 3, float(time))
                array.set(st, 5, 1.0)
                array.set(st, 6, 1.0)
        else if inS
            if useSwing
                bool bullPrev = close[1] > open[1]
                bool bearPrev = close[1] < open[1]
                bool bullCur  = close > open
                bool bearCur  = close < open
                if bullPrev and bearCur
                    float sh  = math.max(high[1], high)
                    int   shT = high[1] >= high ? time[1] : time
                    if array.get(st, 5) == 0 or sh > array.get(st, 0)
                        array.set(st, 0, sh)
                        array.set(st, 2, float(shT))
                        array.set(st, 5, 1.0)
                if bearPrev and bullCur
                    float sl  = math.min(low[1], low)
                    int   slT = low[1] <= low ? time[1] : time
                    if array.get(st, 6) == 0 or sl < array.get(st, 1)
                        array.set(st, 1, sl)
                        array.set(st, 3, float(slT))
                        array.set(st, 6, 1.0)
            else
                if high > array.get(st, 0)
                    array.set(st, 0, high)
                    array.set(st, 2, float(time))
                if low < array.get(st, 1)
                    array.set(st, 1, low)
                    array.set(st, 3, float(time))
        if (not inS) and wasIn
            if array.get(st, 5) == 1
                addLevel(arr, sessHistory, array.get(st, 0), int(array.get(st, 2)), true,  name, colHigh, lineWidth, sessLineStyle)
            if array.get(st, 6) == 1
                addLevel(arr, sessHistory, array.get(st, 1), int(array.get(st, 3)), false, name, colLow,  lineWidth, sessLineStyle)
        array.set(st, 4, inS ? 1.0 : 0.0)

// =================== HTF DETECTION (unconditional security) =================
chartSec = timeframe.in_seconds(timeframe.period)

[i1h_h, p1h_h, t1h_h, i1h_l, p1h_l, t1h_l] = detectSwing("60")
[i4h_h, p4h_h, t4h_h, i4h_l, p4h_l, t4h_l] = detectSwing("240")
[i1d_h, p1d_h, t1d_h, i1d_l, p1d_l, t1d_l] = detectSwing("1D")

if use1H and timeframe.in_seconds("60") >= chartSec
    if i1h_h
        addLevel(lv1H, htfHistory, p1h_h, t1h_h, true,  "1H", bslColor, lineWidth, htfLineStyle)
    if i1h_l
        addLevel(lv1H, htfHistory, p1h_l, t1h_l, false, "1H", sslColor, lineWidth, htfLineStyle)
if use4H and timeframe.in_seconds("240") >= chartSec
    if i4h_h
        addLevel(lv4H, htfHistory, p4h_h, t4h_h, true,  "4H", bslColor, lineWidth, htfLineStyle)
    if i4h_l
        addLevel(lv4H, htfHistory, p4h_l, t4h_l, false, "4H", sslColor, lineWidth, htfLineStyle)
if use1D and timeframe.in_seconds("1D") >= chartSec
    if i1d_h
        addLevel(lv1D, htfHistory, p1d_h, t1d_h, true,  "1D", bslColor, lineWidth, htfLineStyle)
    if i1d_l
        addLevel(lv1D, htfHistory, p1d_l, t1d_l, false, "1D", sslColor, lineWidth, htfLineStyle)

// =================== DAILY BIAS (4H + 1H market structure) ==================
var float biasH1 = na
var float biasL1 = na
var int   bias1H = 0
var float biasH4 = na
var float biasL4 = na
var int   bias4H = 0

if i1h_h
    biasH1 := p1h_h
if i1h_l
    biasL1 := p1h_l
if i4h_h
    biasH4 := p4h_h
if i4h_l
    biasL4 := p4h_l

float biasC1 = request.security(syminfo.tickerid, "60",  close[1], lookahead = barmerge.lookahead_on)
float biasC4 = request.security(syminfo.tickerid, "240", close[1], lookahead = barmerge.lookahead_on)

if not na(biasH1) and biasC1 > biasH1
    bias1H := 1
if not na(biasL1) and biasC1 < biasL1
    bias1H := -1
if not na(biasH4) and biasC4 > biasH4
    bias4H := 1
if not na(biasL4) and biasC4 < biasL4
    bias4H := -1

int  biasDaily = bias4H == bias1H ? bias4H : (bias4H != 0 ? bias4H : bias1H)
bool biasMixed = bias4H != 0 and bias1H != 0 and bias4H != bias1H

// =============================== SESSIONS ====================================
color sHc = color.new(bslColor, sessTransp)
color sLc = color.new(sslColor, sessTransp)
handleSession(asiaSess,   useAsia,   tz, "Asia",   sHc, sLc, lvAsia,   stAsia,   useSwingSess)
handleSession(londonSess, useLondon, tz, "London", sHc, sLc, lvLondon, stLondon, useSwingSess)
handleSession(nySess,     useNY,     tz, "NY",     sHc, sLc, lvNY,     stNY,     useSwingSess)

// =================== CHART-TF SWINGS ========================================
bool bP = close[1] > open[1]
bool rP = close[1] < open[1]
bool bC = close > open
bool rC = close < open
if bP and rC
    lastSwH    := math.max(high[1], high)
    lastSwHBar := high[1] >= high ? bar_index - 1 : bar_index
if rP and bC
    lastSwL    := math.min(low[1], low)
    lastSwLBar := low[1] <= low ? bar_index - 1 : bar_index

// =============================== SWEEPS (LS) =================================
checkSweeps(lv1H,     S, lastSwH, lastSwHBar, lastSwL, lastSwLBar)
checkSweeps(lv4H,     S, lastSwH, lastSwHBar, lastSwL, lastSwLBar)
checkSweeps(lv1D,     S, lastSwH, lastSwHBar, lastSwL, lastSwLBar)
checkSweeps(lvAsia,   S, lastSwH, lastSwHBar, lastSwL, lastSwLBar)
checkSweeps(lvLondon, S, lastSwH, lastSwHBar, lastSwL, lastSwLBar)
checkSweeps(lvNY,     S, lastSwH, lastSwHBar, lastSwL, lastSwLBar)

// =================== CHoCh: dotted while pending, solid when broken =========
if showSetup and S.phase == 1
    bool invalid = useInvalidation and (S.bias == 1 ? close < S.sweepExt : close > S.sweepExt)
    bool expired = bar_index - S.lsBar > chochWindow
    if invalid or expired
        clearSetup(S)
    else
        bool choch = S.bias == 1 ? close > S.ref : close < S.ref
        if choch
            S.phase := 2
            if not na(S.chochLine)
                line.set_style(S.chochLine, line.style_solid)

// =================== FOLLOW PRICE: extend everything to now =================
extendLevels(lv1H)
extendLevels(lv4H)
extendLevels(lv1D)
extendLevels(lvAsia)
extendLevels(lvLondon)
extendLevels(lvNY)

if S.phase >= 1 and not na(S.chochLine)
    line.set_x2(S.chochLine, bar_index)
    label.set_x(S.chochLbl, bar_index + labelOff)

// =================== LABELS: position right edge + merge overlaps ===========
if barstate.islast
    array<Level> allL = array.new<Level>()
    collectLabels(lv1H, allL)
    collectLabels(lv4H, allL)
    collectLabels(lv1D, allL)
    collectLabels(lvAsia, allL)
    collectLabels(lvLondon, allL)
    collectLabels(lvNY, allL)
    int m = array.size(allL)
    if m > 0
        array<float> pr = array.new<float>()
        for i = 0 to m - 1
            Level lvl = array.get(allL, i)
            label.set_text(lvl.lb, lvl.tag + " · " + (lvl.isHigh ? "BSL" : "SSL"))
            label.set_x(lvl.lb, bar_index + labelOff)
            label.set_y(lvl.lb, lvl.price)
            array.push(pr, lvl.price)
        if mergeLabels and m > 1
            float tol = (na(atr) ? 0.0 : atr) * mergeTolMult
            array<int> ord = array.sort_indices(pr, order.ascending)
            int i = 0
            while i < m
                float base = array.get(pr, array.get(ord, i))
                int j = i + 1
                while j < m and (array.get(pr, array.get(ord, j)) - base) <= tol
                    j := j + 1
                if j - i > 1
                    string txt = ""
                    bool allHigh = true
                    bool allLow  = true
                    for k = i to j - 1
                        Level lvl = array.get(allL, array.get(ord, k))
                        string lnTxt = lvl.tag + " · " + (lvl.isHigh ? "BSL" : "SSL")
                        txt := txt == "" ? lnTxt : lnTxt + "\n" + txt
                        allHigh := allHigh and lvl.isHigh
                        allLow  := allLow and (not lvl.isHigh)
                    Level owner = array.get(allL, array.get(ord, j - 1))
                    color mc = allHigh ? bslColor : allLow ? sslColor : color.new(#b2b5be, 0)
                    label.set_text(owner.lb, txt)
                    label.set_textcolor(owner.lb, mc)
                    label.set_y(owner.lb, owner.price)
                    for k = i to j - 2
                        Level lvl = array.get(allL, array.get(ord, k))
                        label.set_text(lvl.lb, "")
                i := j

// =================== DAILY BIAS PANEL =======================================
var table biasTbl = na
if showBias and barstate.islast
    if na(biasTbl)
        biasTbl := table.new(mapPos(biasPosS), 2, 3, bgcolor = color.new(color.black, 35), border_width = 1, border_color = color.new(#787b86, 70))
    table.cell(biasTbl, 0, 0, "4H",    text_color = neutralCol, text_size = size.small, text_halign = text.align_left)
    table.cell(biasTbl, 1, 0, biasTxt(bias4H), text_color = biasCol(bias4H), text_size = size.small, text_halign = text.align_right)
    table.cell(biasTbl, 0, 1, "1H",    text_color = neutralCol, text_size = size.small, text_halign = text.align_left)
    table.cell(biasTbl, 1, 1, biasTxt(bias1H), text_color = biasCol(bias1H), text_size = size.small, text_halign = text.align_right)
    table.cell(biasTbl, 0, 2, "Daily", text_color = neutralCol, text_size = size.small, text_halign = text.align_left)
    table.cell(biasTbl, 1, 2, biasTxt(biasDaily) + (biasMixed ? " ·mix" : ""), text_color = biasCol(biasDaily), text_size = size.small, text_halign = text.align_right)
````
