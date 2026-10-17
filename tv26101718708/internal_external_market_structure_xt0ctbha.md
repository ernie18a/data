# Internal & External Market Structure

- url: https://www.tradingview.com/script/xt0CTbhA/
- type: indicator
- pine_id: PUB;f4b54dc05b5346f0a922ef2b75036c28
- version: 1.0

## Description

This indicator shows market structure on two levels and marks every break.

Internal structure is the small structure. Its breaks are dotted lines labelled iBOS and iCHoCH.
External structure is the big picture. Its breaks are solid lines labelled BOS and CHoCH.

How it works

There is one setting, the swing length. The default is 5. A swing high or swing low needs that many candles on each side. A candle close through the latest swing is a break. With the trend it is a BOS, against the trend it is a CHoCH.

The external structure needs no second length and no higher timeframe. It is built from the internal structure of the same chart, so the same rules work on every timeframe.

In an uptrend there is a strong low and a weak high. A new high only becomes a confirmed swing high once the internal structure breaks down, because then a real pullback has started. A close above that high is a BOS, and the low of the pullback becomes the new strong low. A close below the strong low is a CHoCH and the trend turns. A downtrend works the same way in reverse.

Only candle closes count as breaks. A wick through a level with a close back inside is a liquidity sweep and is marked with a small cross.

How to use it

Use the external structure for direction and the internal structure for timing. An iCHoCH against the external trend means a pullback has started. An iCHoCH back in the direction of the trend shows that the internal structure points with the trend again.

The status line at the bottom of the chart says whether price is in a trend or in a pullback and shows the current levels.

What else is on the chart

HH, HL, LH and LL at the external swing points. The strong level and the weak level as dashed lines up to the current candle. Candle coloring by structure, which is off by default. Alerts for every break, for the start and the end of a pullback and for sweeps.

Good to know

Everything is decided on closed candles. A break is drawn when its candle closes and is not changed afterwards. Swings appear with a delay of the swing length. The external structure changes much less often than the internal one. A pullback that does not break the internal structure is not counted as an external swing. This is a tool for reading structure. It gives no entries, stops or targets.

## Source Code

````pine
//@version=6
indicator("Internal & External Market Structure", "Internal & External Market Structure", overlay = true, max_lines_count = 500, max_labels_count = 500, max_bars_back = 5000)

// ═════════════════════════════════════════════════════════════
// INPUTS
// There is one length only. The external structure needs no second lookback and no higher timeframe:
// it is built from the internal structure of the chart itself, so the same rule works on every market and timeframe.
// Every setting carries a tooltip in plain words. The status line next to the name stays clean.
// ═════════════════════════════════════════════════════════════
string G1 = "1 · Internal structure"
string G2 = "2 · External structure"
string G3 = "3 · Levels and extras"
string G4 = "4 · Colors"

bool  showInt    = input.bool(true, "Show the internal structure (small swings, dotted)", group = G1, tooltip = "Internal structure is the small structure inside a bigger move. Every close through a small swing is drawn as a dotted line: iBOS (internal break of structure) when the small trend continues, iCHoCH (internal change of character) when it turns. It is used for timing: it shows when a pullback starts and when it ends.")
int   intLen     = input.int(5, "Swing length", minval = 2, maxval = 50, group = G1, display = display.none, tooltip = "How many candles to the left and to the right must be lower (or higher) before a point counts as a small swing high (or low). 5 is the usual value. Lower values react faster and mark more breaks, higher values only keep the clearer swings. This is the only length in the script: the external structure is built from the internal one and adapts to the market by itself.")

bool  showExt    = input.bool(true, "Show the external structure (protected swings, solid)", group = G2, tooltip = "External structure is the big picture. It uses no longer lookback and no higher timeframe, it comes from the chart itself. 1. A new high only becomes a swing high once the internal structure breaks down, because only then a real pullback has started. 2. When a candle closes above that swing high, that is a break of structure (BOS), and the lowest low of the pullback becomes the strong low. 3. As long as no candle closes below the strong low, the trend is up, however deep the pullback goes. A close below it is a change of character (CHoCH) and the trend turns. A downtrend works the same way in reverse. External breaks are drawn as solid lines and named BOS and CHoCH, without the i. A small cross marks a liquidity sweep: a wick that goes beyond the strong or the weak level while the candle closes back inside. The level stays where it is. The crosses can be switched off in the Style tab.")
bool  showSwings = input.bool(true, "Name the external swing points (HH, HL, LH, LL)", group = G2, tooltip = "HH = higher high, HL = higher low, LH = lower high, LL = lower low. Each swing point of the external structure is compared with the one before it.")

bool  showLevels = input.bool(true, "Show the levels that matter right now", group = G3, tooltip = "Draws the current range of the external structure up to the present. Strong low or strong high (dashed, in the color of the trend): the level that protects the trend, a candle close beyond it turns the structure. Weak high or weak low (dashed, neutral color): the level the trend is expected to take next, a candle close beyond it is the next BOS. It appears as soon as the pullback has started. The thin dotted line is the level that holds the internal structure.")
bool  showStatus = input.bool(true, "Show the status line at the bottom of the chart", group = G3, tooltip = "Says in plain words where price is right now. Trend: internal and external structure point the same way. Pullback: the internal structure runs against the external one. Below it the levels that matter.")
bool  colorBars  = input.bool(false, "Color the candles by structure", group = G3, tooltip = "Bullish color while internal and external structure both point up, bearish color while both point down, neutral color during a pullback, when they disagree.")

color colBull    = input.color(#26A69A, "Bullish", inline = "c", group = G4)
color colBear    = input.color(#EF5350, "Bearish", inline = "c", group = G4)
color colNeutral = input.color(#868993, "Neutral", inline = "c", group = G4, tooltip = "Bullish and bearish breaks and levels, and the neutral color for swing names, the weak level and pullback candles.")

// fixed settings (kept out of the menu on purpose)
int MAX_LB   = 4900
int EXTEND   = 8
int KEEP_EXT = 100
int KEEP_INT = 150
int KEEP_SW  = 150

// ═════════════════════════════════════════════════════════════
// STATE
// ═════════════════════════════════════════════════════════════
// the last two named swing highs and swing lows of the external structure: a new one is compared with the one before it
type Mem
    float hiPrev
    float hiPx
    int   hiBar = -1
    label hiLb
    float loPrev
    float loPx
    int   loBar = -1
    label loLb

var Mem          mem      = Mem.new()
var array<line>  eLines   = array.new<line>()
var array<label> eLabels  = array.new<label>()
var array<line>  iLines   = array.new<line>()
var array<label> iLabels  = array.new<label>()
var array<label> swLabels = array.new<label>()

// no repainting: swings and breaks only count once their candle has closed
bool conf = barstate.isconfirmed

// ═════════════════════════════════════════════════════════════
// HELPERS
// ═════════════════════════════════════════════════════════════
f_x(int b) =>
    math.max(b, bar_index - MAX_LB)

f_px(float p) =>
    str.tostring(p, format.mintick)

// names a swing point of the external structure and remembers it. Every swing point is named once
f_swing(Mem m, int atBar, float px, bool isHigh) =>
    if isHigh and atBar != m.hiBar
        m.hiPrev := m.hiPx
        m.hiPx   := px
        m.hiBar  := atBar
        if showExt and showSwings
            m.hiLb := label.new(f_x(atBar), px, na(m.hiPrev) or px > m.hiPrev ? "HH" : "LH", style = label.style_label_down, color = color.new(color.black, 100), textcolor = color.new(colNeutral, 10), size = size.tiny)
            array.push(swLabels, m.hiLb)
    if not isHigh and atBar != m.loBar
        m.loPrev := m.loPx
        m.loPx   := px
        m.loBar  := atBar
        if showExt and showSwings
            m.loLb := label.new(f_x(atBar), px, na(m.loPrev) or px < m.loPrev ? "LL" : "HL", style = label.style_label_up, color = color.new(color.black, 100), textcolor = color.new(colNeutral, 10), size = size.tiny)
            array.push(swLabels, m.loLb)

// a wick carried a confirmed swing point further before the structure turned: its name moves to the wick
f_move(Mem m, int atBar, float px, bool isHigh) =>
    if isHigh
        m.hiPx  := px
        m.hiBar := atBar
        if not na(m.hiLb)
            label.set_xy(m.hiLb, f_x(atBar), px)
            label.set_text(m.hiLb, na(m.hiPrev) or px > m.hiPrev ? "HH" : "LH")
    if not isHigh
        m.loPx  := px
        m.loBar := atBar
        if not na(m.loLb)
            label.set_xy(m.loLb, f_x(atBar), px)
            label.set_text(m.loLb, na(m.loPrev) or px < m.loPrev ? "LL" : "HL")

// ═════════════════════════════════════════════════════════════
// INTERNAL STRUCTURE: small swings (pivots)
// A close through the latest swing high or low is a break: iBOS with the internal trend, iCHoCH against it.
// After a break up, the lowest low since the broken high holds the internal structure (mirrored after a break down).
// ═════════════════════════════════════════════════════════════
f_struct(int len) =>
    float pH    = ta.pivothigh(high, len, len)
    float pL    = ta.pivotlow(low, len, len)
    float loWin = ta.lowest(low, len + 1)
    float hiWin = ta.highest(high, len + 1)
    int   loOff = ta.lowestbars(low, len + 1)
    int   hiOff = ta.highestbars(high, len + 1)
    // a swing only counts once its candle has closed, so no swing shows up inside a running candle and disappears again
    if not conf
        pH := na
        pL := na
    var float sHi    = na
    var float sLo    = na
    var int   sHiBar = na
    var int   sLoBar = na
    var bool  hiOn   = false
    var bool  loOn   = false
    var float runLo  = na
    var float runHi  = na
    var int   runLoB = na
    var int   runHiB = na
    var int   sDir   = 0
    bool   up     = false
    bool   dn     = false
    bool   choch  = false
    float  brkPx  = na
    int    brkBar = na
    // a new swing high; since then the lowest low on the way is tracked (it holds the structure once that high breaks)
    if not na(pH)
        sHi    := pH
        hiOn   := true
        runLo  := loWin
        sHiBar := bar_index - len
        runLoB := bar_index + loOff
    else if na(runLo) or low < runLo
        runLo  := low
        runLoB := bar_index
    // the mirror of it for a new swing low
    if not na(pL)
        sLo    := pL
        loOn   := true
        runHi  := hiWin
        sLoBar := bar_index - len
        runHiB := bar_index + hiOff
    else if na(runHi) or high > runHi
        runHi  := high
        runHiB := bar_index
    // a close through a swing: BOS with the trend, CHoCH against it
    if conf and hiOn and close > sHi
        up     := true
        choch  := sDir == -1
        brkPx  := sHi
        brkBar := sHiBar
        sDir   := 1
        hiOn   := false
        sLo    := runLo
        loOn   := true
        sLoBar := runLoB
    if conf and loOn and close < sLo
        dn     := true
        choch  := sDir == 1
        brkPx  := sLo
        brkBar := sLoBar
        sDir   := -1
        loOn   := false
        sHi    := runHi
        hiOn   := true
        sHiBar := runHiB
    // the level that holds this structure right now: a close beyond it turns it
    float holdPx  = sDir == 1 and loOn ? sLo : sDir == -1 and hiOn ? sHi : na
    int   holdBar = sDir == 1 ? sLoBar : sHiBar
    [sDir, up, dn, choch, brkPx, brkBar, holdPx, holdBar]

[iDir, iUp, iDn, iChoch, iBrkPx, iBrkBar, iHoldPx, iHoldBar] = f_struct(intLen)

// ═════════════════════════════════════════════════════════════
// EXTERNAL STRUCTURE: built from the internal one, no second length
// The engine has one code path. It always thinks "up": while the structure is down, prices are mirrored (xSg = -1),
// so a high is a mirrored low and the same rules apply. Real prices are xSg * mirrored price.
//   sLow  = the strong level (protects the trend). A close below it turns the structure: CHoCH.
//   wHigh = the weak level (the extreme of the current leg). It keeps running with price until the internal structure
//           breaks against the trend. From then on it is locked: a confirmed swing point. A close above it is a BOS.
//   A wick beyond a level without a close beyond it is a sweep. The level stays where it is.
// Running searches (no lookback limit):
//   pbLo = the lowest low after the weak level (the pullback low). It becomes the strong level on a BOS.
//   lgHi = the highest high since that pullback low. It becomes the new weak level on a BOS.
//   tpHi = the highest high of the whole leg, wicks above a locked level included. It becomes the strong level on a CHoCH.
//   dpLo = the lowest low since that high. It becomes the new weak level on a CHoCH.
//   swLo = the lowest wick below the strong level so far, so only a deeper wick counts as a new sweep.
// ═════════════════════════════════════════════════════════════
var int   xSg      = 0
var float sLow     = na
var int   sLowBar  = na
var float wHigh    = na
var int   wHighBar = na
var bool  locked   = false
var float pbLo     = na
var int   pbLoBar  = na
var float lgHi     = na
var int   lgHiBar  = na
var float tpHi     = na
var int   tpHiBar  = na
var float dpLo     = na
var int   dpLoBar  = na
var float swLo     = na

// restarts the running searches after a break, from the candle of the new weak level up to this candle (usually the same candle)
f_seed(int sgn, int fromBar) =>
    float pb  = na
    int   pbB = na
    float lg  = na
    int   lgB = na
    int   n   = math.min(bar_index - fromBar, MAX_LB)
    float dp  = sgn == 1 ? low[n] : -high[n]
    int   dpB = bar_index - n
    if n > 0
        for off = n - 1 to 0
            float hh = sgn == 1 ? high[off] : -low[off]
            float ll = sgn == 1 ? low[off] : -high[off]
            if na(pb) or ll < pb
                pb  := ll
                pbB := bar_index - off
                lg  := hh
                lgB := bar_index - off
            else if hh > lg
                lg  := hh
                lgB := bar_index - off
            if ll < dp
                dp  := ll
                dpB := bar_index - off
    [pb, pbB, lg, lgB, dp, dpB]

bool  eUp     = false
bool  eDn     = false
bool  eChoch  = false
float eBrkPx  = na
int   eBrkBar = na
bool  swpHi   = false
bool  swpLo   = false

if conf
    if xSg == 0
        // the first internal break starts the external structure
        if (iUp or iDn) and not na(iHoldPx)
            xSg      := iUp ? 1 : -1
            sLow     := xSg * iHoldPx
            sLowBar  := iHoldBar
            swLo     := sLow
            wHigh    := xSg == 1 ? high : -low
            wHighBar := bar_index
            locked   := false
            tpHi     := wHigh
            tpHiBar  := bar_index
            pbLo     := na
            lgHi     := na
            dpLo     := xSg == 1 ? low : -high
            dpLoBar  := bar_index
            f_swing(mem, iHoldBar, iHoldPx, xSg == -1)
    else
        float H = xSg == 1 ? high : -low
        float L = xSg == 1 ? low : -high
        float C = xSg * close
        // both breaks are judged against the levels as they stand before this candle
        bool choch = C < sLow
        bool bos   = not choch and locked and C > wHigh
        // sweeps: a wick makes a new extreme beyond a level, but the candle does not close beyond it
        bool swpW = locked and not choch and not bos and H > tpHi
        bool swpS = not choch and not bos and L < swLo
        if swpS
            swLo := L
        // running searches
        if not locked and H > wHigh
            wHigh    := H
            wHighBar := bar_index
            pbLo     := na
            lgHi     := na
        else if na(pbLo) or L < pbLo
            pbLo    := L
            pbLoBar := bar_index
            lgHi    := H
            lgHiBar := bar_index
        else if H > lgHi
            lgHi    := H
            lgHiBar := bar_index
        if H > tpHi
            tpHi    := H
            tpHiBar := bar_index
            dpLo    := L
            dpLoBar := bar_index
        else if L < dpLo
            dpLo    := L
            dpLoBar := bar_index
        if choch
            // CHoCH: a close beyond the strong level turns the structure.
            // The extreme of the old leg becomes the new strong level, the extreme since then the new weak level
            eChoch  := true
            eBrkPx  := xSg * sLow
            eBrkBar := sLowBar
            float top    = tpHi
            int   topBar = tpHiBar
            float bot    = dpLo
            int   botBar = dpLoBar
            // the swing point of the old leg: if a wick went above the confirmed high later, its name moves to that wick
            if locked and topBar != wHighBar
                f_move(mem, topBar, xSg * top, xSg == 1)
            else
                f_swing(mem, topBar, xSg * top, xSg == 1)
            xSg      := -xSg
            sLow     := -top
            sLowBar  := topBar
            swLo     := sLow
            wHigh    := -bot
            wHighBar := botBar
            locked   := false
            tpHi     := wHigh
            tpHiBar  := wHighBar
            [sPb, sPbB, sLg, sLgB, sDp, sDpB] = f_seed(xSg, wHighBar)
            pbLo    := sPb
            pbLoBar := sPbB
            lgHi    := sLg
            lgHiBar := sLgB
            dpLo    := sDp
            dpLoBar := sDpB
            eUp     := xSg == 1
            eDn     := xSg == -1
        else if bos
            // BOS: a close beyond the confirmed swing point continues the trend.
            // The extreme of the pullback becomes the new strong level, the extreme since then the new weak level
            eBrkPx   := xSg * wHigh
            eBrkBar  := wHighBar
            sLow     := pbLo
            sLowBar  := pbLoBar
            swLo     := sLow
            f_swing(mem, sLowBar, xSg * sLow, xSg == -1)
            wHigh    := lgHi
            wHighBar := lgHiBar
            locked   := false
            tpHi     := wHigh
            tpHiBar  := wHighBar
            [sPb, sPbB, sLg, sLgB, sDp, sDpB] = f_seed(xSg, wHighBar)
            pbLo    := sPb
            pbLoBar := sPbB
            lgHi    := sLg
            lgHiBar := sLgB
            dpLo    := sDp
            dpLoBar := sDpB
            eUp     := xSg == 1
            eDn     := xSg == -1
        else
            // no break on this candle: sweeps count, in real prices above the range or below it
            swpHi := (xSg == 1 and swpW) or (xSg == -1 and swpS)
            swpLo := (xSg == 1 and swpS) or (xSg == -1 and swpW)
            if not locked and ((xSg == 1 and iDn) or (xSg == -1 and iUp))
                // the internal structure breaks against the trend: the pullback has started and the extreme of the leg is a confirmed swing point
                locked := true
                f_swing(mem, wHighBar, xSg * wHigh, xSg == 1)

// the two levels of the current range in real prices
float strongPx = xSg == 0 ? na : xSg * sLow
float weakPx   = xSg != 0 and locked ? xSg * wHigh : na

// ═════════════════════════════════════════════════════════════
// VISUALS: external breaks solid (BOS, CHoCH), internal breaks dotted and small (iBOS, iCHoCH)
// ═════════════════════════════════════════════════════════════
if (eUp or eDn) and showExt
    color eCol = eUp ? colBull : colBear
    int   eX1  = f_x(eBrkBar)
    array.push(eLines, line.new(eX1, eBrkPx, bar_index, eBrkPx, color = color.new(eCol, 15), width = 2))
    array.push(eLabels, label.new(math.floor((eX1 + bar_index) / 2.0), eBrkPx, eChoch ? "CHoCH" : "BOS", style = eUp ? label.style_label_down : label.style_label_up, color = color.new(color.black, 100), textcolor = color.new(eCol, 0), size = size.small))
    if array.size(eLines) > KEEP_EXT
        line.delete(array.shift(eLines))
        label.delete(array.shift(eLabels))

// an internal break on the candle of an external break in the same direction is the same move: only the external one is drawn
if (iUp or iDn) and showInt and not ((iUp and eUp) or (iDn and eDn))
    color iCol = iUp ? colBull : colBear
    int   iX1  = f_x(iBrkBar)
    array.push(iLines, line.new(iX1, iBrkPx, bar_index, iBrkPx, color = color.new(iCol, 35), style = line.style_dotted, width = 1))
    array.push(iLabels, label.new(math.floor((iX1 + bar_index) / 2.0), iBrkPx, iChoch ? "iCHoCH" : "iBOS", style = iUp ? label.style_label_down : label.style_label_up, color = color.new(color.black, 100), textcolor = color.new(iCol, 30), size = size.tiny))
    if array.size(iLines) > KEEP_INT
        line.delete(array.shift(iLines))
        label.delete(array.shift(iLabels))

while array.size(swLabels) > KEEP_SW
    label.delete(array.shift(swLabels))

// the levels that matter right now, drawn for the present only.
// Each tag ends where its line ends and sits on the far side of the line, away from the candles
var line  strongLn = na
var label strongLb = na
var line  weakLn   = na
var label weakLb   = na
var line  holdLn   = na
var label holdLb   = na
if barstate.islast and showLevels
    if showExt and xSg != 0
        if na(strongLn)
            strongLn := line.new(bar_index, close, bar_index, close, style = line.style_dashed, width = 1)
            strongLb := label.new(bar_index, close, "", color = color.new(color.black, 100), size = size.small)
            weakLn   := line.new(bar_index, close, bar_index, close, style = line.style_dashed, width = 1)
            weakLb   := label.new(bar_index, close, "", color = color.new(color.black, 100), size = size.small)
        color sCol = xSg == 1 ? colBull : colBear
        line.set_xy1(strongLn, f_x(sLowBar), strongPx)
        line.set_xy2(strongLn, bar_index + EXTEND, strongPx)
        line.set_color(strongLn, color.new(sCol, 15))
        label.set_xy(strongLb, bar_index + EXTEND, strongPx)
        label.set_style(strongLb, xSg == 1 ? label.style_label_upper_right : label.style_label_lower_right)
        label.set_text(strongLb, xSg == 1 ? "Strong low · a close below turns the structure" : "Strong high · a close above turns the structure")
        label.set_textcolor(strongLb, color.new(sCol, 10))
        line.set_xy1(weakLn, f_x(wHighBar), weakPx)
        line.set_xy2(weakLn, bar_index + EXTEND, weakPx)
        line.set_color(weakLn, color.new(colNeutral, 25))
        label.set_xy(weakLb, bar_index + EXTEND, weakPx)
        label.set_style(weakLb, xSg == 1 ? label.style_label_lower_right : label.style_label_upper_right)
        label.set_text(weakLb, na(weakPx) ? "" : xSg == 1 ? "Weak high · a close above is the next BOS" : "Weak low · a close below is the next BOS")
        label.set_textcolor(weakLb, color.new(colNeutral, 10))
    if showInt and iDir != 0
        if na(holdLn)
            holdLn := line.new(bar_index, close, bar_index, close, style = line.style_dotted, width = 1)
            holdLb := label.new(bar_index, close, "", color = color.new(color.black, 100), size = size.tiny)
        color hCol = iDir == 1 ? colBull : colBear
        line.set_xy1(holdLn, f_x(nz(iHoldBar, bar_index)), iHoldPx)
        line.set_xy2(holdLn, bar_index + EXTEND, iHoldPx)
        line.set_color(holdLn, color.new(hCol, 35))
        label.set_xy(holdLb, bar_index + EXTEND, iHoldPx)
        label.set_style(holdLb, iDir == 1 ? label.style_label_upper_right : label.style_label_lower_right)
        label.set_text(holdLb, na(iHoldPx) ? "" : iDir == 1 ? "Internal · a close below turns it" : "Internal · a close above turns it")
        label.set_textcolor(holdLb, color.new(hCol, 30))

// liquidity sweeps of the external range as small crosses at the wick (Style tab)
plotshape(swpHi, "Sweep above the external high", style = shape.xcross, location = location.abovebar, color = color.new(colNeutral, 0), size = size.tiny, display = display.all - display.status_line)
plotshape(swpLo, "Sweep below the external low",  style = shape.xcross, location = location.belowbar, color = color.new(colNeutral, 0), size = size.tiny, display = display.all - display.status_line)

// candles by structure: both up, both down, or a pullback
color barCol = not colorBars or xSg == 0 ? na : xSg == 1 and iDir == 1 ? colBull : xSg == -1 and iDir == -1 ? colBear : colNeutral
barcolor(barCol, title = "Candle color by structure")

// ═════════════════════════════════════════════════════════════
// STATUS: where price is right now, in plain words, and the levels that matter
// ═════════════════════════════════════════════════════════════
var table stTb = na
if barstate.islast and showStatus
    if na(stTb)
        stTb := table.new(position.bottom_center, 1, 2, bgcolor = color(na), border_width = 0)
    string st  = "Waiting for the first structure break"
    color  stC = color.new(colNeutral, 10)
    if xSg == 1 and iDir == 1
        st  := "Uptrend  ·  internal and external structure point up"
        stC := color.new(colBull, 0)
    else if xSg == 1
        st  := "Pullback inside an uptrend  ·  the internal structure is down"
        stC := color.new(colBull, 35)
    else if xSg == -1 and iDir == -1
        st  := "Downtrend  ·  internal and external structure point down"
        stC := color.new(colBear, 0)
    else if xSg == -1
        st  := "Pullback inside a downtrend  ·  the internal structure is up"
        stC := color.new(colBear, 35)
    string d1 = xSg == 0 ? "" : "External " + (xSg == 1 ? "up  ·  strong low " : "down  ·  strong high ") + f_px(strongPx) + (na(weakPx) ? "" : (xSg == 1 ? "  ·  weak high " : "  ·  weak low ") + f_px(weakPx))
    string d2 = iDir == 0 ? "" : "Internal " + (iDir == 1 ? "up" : "down") + (na(iHoldPx) ? "" : (iDir == 1 ? "  ·  turns below " : "  ·  turns above ") + f_px(iHoldPx))
    table.cell(stTb, 0, 0, st, text_color = stC, text_size = size.small, text_formatting = text.format_bold)
    table.cell(stTb, 0, 1, d1 + (d1 != "" and d2 != "" ? "        " : "") + d2, text_color = color.new(color.gray, 25), text_size = size.small)

// the state as plain numbers, only in the data window (and usable as a source in other scripts)
plot(xSg,      "External direction (1 up, -1 down)", display = display.data_window)
plot(iDir,     "Internal direction (1 up, -1 down)", display = display.data_window)
plot(strongPx, "External strong level",              display = display.data_window)
plot(weakPx,   "External weak level",                display = display.data_window)
plot(iHoldPx,  "Internal level",                     display = display.data_window)

// ═════════════════════════════════════════════════════════════
// ALERTS
// ═════════════════════════════════════════════════════════════
alertcondition(eUp and not eChoch, "External BOS up",     "Assay Structure: external BOS up on {{ticker}} ({{interval}})")
alertcondition(eDn and not eChoch, "External BOS down",   "Assay Structure: external BOS down on {{ticker}} ({{interval}})")
alertcondition(eUp and eChoch,     "External CHoCH up",   "Assay Structure: external CHoCH, the structure turned up on {{ticker}} ({{interval}})")
alertcondition(eDn and eChoch,     "External CHoCH down", "Assay Structure: external CHoCH, the structure turned down on {{ticker}} ({{interval}})")
alertcondition(swpHi, "Sweep above the external high", "Assay Structure: a wick took the liquidity above the external high and closed back below it on {{ticker}} ({{interval}})")
alertcondition(swpLo, "Sweep below the external low",  "Assay Structure: a wick took the liquidity below the external low and closed back above it on {{ticker}} ({{interval}})")
alertcondition(iDn and iChoch and xSg == 1 and not eChoch,  "Pullback started in an uptrend",  "Assay Structure: the internal structure turned down inside an external uptrend on {{ticker}} ({{interval}})")
alertcondition(iUp and iChoch and xSg == -1 and not eChoch, "Pullback started in a downtrend", "Assay Structure: the internal structure turned up inside an external downtrend on {{ticker}} ({{interval}})")
alertcondition(iUp and iChoch and xSg == 1 and not eChoch,  "Pullback over in an uptrend",     "Assay Structure: the internal structure turned up again inside an external uptrend on {{ticker}} ({{interval}})")
alertcondition(iDn and iChoch and xSg == -1 and not eChoch, "Pullback over in a downtrend",    "Assay Structure: the internal structure turned down again inside an external downtrend on {{ticker}} ({{interval}})")
alertcondition(iUp and not iChoch, "iBOS up",     "Assay Structure: iBOS up (internal) on {{ticker}} ({{interval}})")
alertcondition(iDn and not iChoch, "iBOS down",   "Assay Structure: iBOS down (internal) on {{ticker}} ({{interval}})")
alertcondition(iUp and iChoch,     "iCHoCH up",   "Assay Structure: iCHoCH up (internal) on {{ticker}} ({{interval}})")
alertcondition(iDn and iChoch,     "iCHoCH down", "Assay Structure: iCHoCH down (internal) on {{ticker}} ({{interval}})")
````
