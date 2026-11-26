# AlgoSentry Smart Money Engine [Non-Repaint]

- url: https://www.tradingview.com/script/7gYUjCtJ-AlgoSentry-Smart-Money-Engine-Non-Repaint/
- type: indicator
- pine_id: PUB;5789e391f67c4a64abb5ff35d6de4c39
- version: 1.0

## Description

AlgoSentry Smart Money Engine [Non-Repaint]

A complete Smart Money Concepts toolkit built on a single rule: nothing is drawn until the candle closes. No repainting, no future leaks, no lookahead. What you see on historical bars is exactly what you would have seen live.

This is one coherent engine, not a bundle of disconnected tools — each layer feeds the next:
Market Structure -> Liquidity Sweep -> Fair Value Gap -> Break of Structure / Change of Character -> Order Block -> Premium / Discount -> Smart Money Score.

──────────  What it reads  ──────────

Market Structure
Swing highs and lows are detected with confirmed pivots. A swing only prints after a set number of closed bars on each side, so the structure labels (HH, HL, LH, LL) never move once drawn. Labels are off by default for a clean chart — the live bias is always in the dashboard.

Break of Structure & Change of Character
A break registers only when price closes beyond a confirmed swing level. Continuing the trend, it is a Break of Structure (BOS); reversing it after breaking the opposite level, it is a Change of Character (CHoCH). A line is drawn from the broken swing to the break candle.

Displacement Quality
Each break is graded Weak, Valid, or Institutional from candle body strength, ATR expansion, and — where available — volume expansion. It separates a real institutional move from a marginal one.

Liquidity Sweeps
Marked when price wicks beyond a prior swing but closes back inside it: a sell-side sweep below a swing low, a buy-side sweep above a swing high. Each swing is swept once, so the chart stays clean.

Fair Value Gaps
Three-candle imbalances are drawn as zones and tracked through their life — Fresh, Partially mitigated, Filled. Show active gaps only, or keep historical ones faded.

Order Blocks
After a confirmed break, the last opposite candle before that break becomes an order-block zone, tracked as Fresh, Touched, or Invalidated.

Premium / Discount
The last confirmed swing range is split into premium (upper), equilibrium (50%), and discount (lower) — context for where price sits inside its range.

Smart Money Score
A 0-100 context score from the confluence of structure, breaks, sweeps, imbalance, order-block proximity, and trend agreement, reading from Strong Bearish to Strong Bullish. It is a market-context score, not a buy or sell signal.

──────────  Why it does not repaint  ──────────

Every layer runs on confirmed, closed bars. Pivots require bars on both sides before they confirm. Breaks, sweeps, gaps, and blocks are all evaluated on candle close. There is no security() call, no higher-timeframe lookahead, and no recalculation that moves a past signal. Backtest behaviour matches live behaviour.

──────────  How to use it  ──────────

Read the dashboard top-down — bias, then the Smart Money Score for context, then the live phase (Accumulation, Expansion, Pullback, Distribution). Use BOS and CHoCH to read structural shifts, sweeps to spot liquidity grabs, and the Fair Value Gap and order-block zones as areas of interest. The optional EMA filter aligns events to the higher-timeframe trend. Alerts are available for every event, all candle-close confirmed.

──────────  What it does NOT do  ──────────

It does not predict price. It does not give buy or sell signals. It does not place trades or guarantee any outcome. It is a structural and contextual reading tool — the decisions and the risk are yours.

──────────  Disclaimer  ──────────

For educational and informational purposes only. This is not financial advice. Trading carries substantial risk of loss, and past behaviour does not guarantee future results.

Every signal is confirmed on candle close. No future leaks. No lookahead.

## Source Code

````pine
//@version=6
// ============================================================================
//  AlgoSentry Smart Money Engine [Non-Repaint]   ·   v2 institutional layer
//  Free educational Smart Money Concepts engine by AlgoSentry.
//
//  DESIGN PRINCIPLE — every signal is confirmed on candle close.
//  No future leaks. No lookahead. No request.security. Closed bars only.
//
//  Pipeline (one coherent engine):
//    Structure -> Liquidity Sweep -> Imbalance (FVG) -> BOS / CHoCH
//    -> Order Block -> Premium/Discount context -> Smart Money Score
// ============================================================================
indicator("AlgoSentry Smart Money Engine [Non-Repaint]", "AlgoSentry SMC", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

// ----------------------------------------------------------------------------
//  PALETTE — AlgoSentry visual hierarchy (cyan / magenta / green / red)
// ----------------------------------------------------------------------------
color C_BULL  = #26a69a   // green   — bullish structure / demand
color C_BEAR  = #ef5350   // red     — bearish structure / supply
color C_CYAN  = #22d3ee   // cyan    — BOS / structure accent
color C_MAG   = #e0117f   // magenta — CHoCH / brand accent
color C_PANEL = #0d0d14   // dashboard background
color C_INK   = #e8e8f0   // dashboard text
color C_DIM   = #5a5a72   // muted text

// ----------------------------------------------------------------------------
//  INPUTS
// ----------------------------------------------------------------------------
gMS        = "Market Structure"
pivLen     = input.int(10, "Pivot Length", minval = 2, maxval = 50, group = gMS, tooltip = "Bars required on each side to confirm a swing. Swings confirm only after this many CLOSED bars — never on the live bar.")
showMS     = input.bool(false, "Show HH / HL / LH / LL", group = gMS, tooltip = "Structure labels. Off by default for a clean chart — the bias is always summarised in the dashboard. Turn on for full structure mapping.")

gBC        = "BOS / CHoCH"
showBOS    = input.bool(true, "Show Break of Structure", group = gBC)
showCHOCH  = input.bool(true, "Show Change of Character", group = gBC)

gDISP      = "Displacement Quality"
showDisp   = input.bool(true, "Grade Break Displacement", group = gDISP, tooltip = "Tags each break as Weak / Valid / Institutional from body strength, ATR expansion and (if available) volume expansion.")
atrLen     = input.int(14, "ATR Length", minval = 1, group = gDISP)

gLQ        = "Liquidity Sweeps"
showSweep  = input.bool(true, "Show Liquidity Sweeps", group = gLQ)

gFVG       = "Fair Value Gaps"
showFVG    = input.bool(true, "Show Fair Value Gaps", group = gFVG)
fvgMode    = input.string("Active only", "FVG Display", options = ["Active only", "Historical"], group = gFVG, tooltip = "Active only: remove a gap once fully filled. Historical: keep and fade it.")
fvgMax     = input.int(8, "Max FVG Boxes", minval = 1, maxval = 50, group = gFVG)

gOB        = "Order Blocks"
showOB     = input.bool(true, "Show Order Blocks", group = gOB)
obMax      = input.int(6, "Max Order Block Zones", minval = 1, maxval = 30, group = gOB)
obLookback = input.int(20, "OB Search Depth", minval = 3, maxval = 50, group = gOB, tooltip = "Bars to search back for the last opposite candle before a confirmed break.")

gPD        = "Premium / Discount"
showPD     = input.bool(true, "Show Premium / Discount Zones", group = gPD, tooltip = "Splits the last confirmed swing range into Premium (upper), Equilibrium (50%) and Discount (lower).")

gTF        = "Trend Filter"
showEMA    = input.bool(true, "Show EMA", group = gTF)
emaLen     = input.int(200, "EMA Length", minval = 1, group = gTF)
reqAlign   = input.bool(false, "Require EMA Alignment", group = gTF, tooltip = "When on, BOS / CHoCH / sweeps only fire in the direction of the EMA bias.")

gSCORE     = "Smart Money Score"
showScore  = input.bool(true, "Compute Smart Money Score", group = gSCORE, tooltip = "A 0-100 market CONTEXT score from structure, breaks, sweeps, imbalance, order-block proximity and EMA. NOT a buy/sell signal.")

gVIS       = "Visuals"
colBull    = input.color(#26a69a, "Bullish", group = gVIS, inline = "v1")
colBear    = input.color(#ef5350, "Bearish", group = gVIS, inline = "v1")
zoneTransp = input.int(85, "Zone Transparency", minval = 50, maxval = 100, group = gVIS, tooltip = "Higher = more subtle zones.")

gDASH      = "Dashboard"
showDash   = input.bool(true, "Show Dashboard", group = gDASH)

// ----------------------------------------------------------------------------
//  CONTEXT SERIES
// ----------------------------------------------------------------------------
emaVal = ta.ema(close, emaLen)
plot(showEMA ? emaVal : na, "EMA", color = color.new(C_CYAN, 35), linewidth = 1)
bullBias = close > emaVal
bearBias = close < emaVal
bullOk = not reqAlign or bullBias
bearOk = not reqAlign or bearBias

atrVal = ta.atr(atrLen)
volAvg = ta.sma(volume, 20)
volOk  = not na(volume) and volume > 0 and not na(volAvg) and volAvg > 0

// ----------------------------------------------------------------------------
//  MODULE 1 — MARKET STRUCTURE (confirmed pivots, HH / HL / LH / LL)
// ----------------------------------------------------------------------------
ph = ta.pivothigh(pivLen, pivLen)
pl = ta.pivotlow(pivLen, pivLen)

var float lastSwingHigh = na
var float prevSwingHigh = na
var int   swingHighBar  = na
var float lastSwingLow  = na
var float prevSwingLow  = na
var int   swingLowBar   = na

var float upLevel    = na
var int   upLevelBar  = na
var bool  upTaken     = true
var float dnLevel    = na
var int   dnLevelBar  = na
var bool  dnTaken     = true
var bool  swHiTaken   = true     // swing-high already swept? (anti-duplicate)
var bool  swLoTaken   = true     // swing-low already swept?

newHigh = not na(ph)
newLow  = not na(pl)

if newHigh
    prevSwingHigh := lastSwingHigh
    lastSwingHigh := ph
    swingHighBar  := bar_index - pivLen
    upLevel       := ph
    upLevelBar    := bar_index - pivLen
    upTaken       := false
    swHiTaken     := false
    if showMS
        bool isHH = not na(prevSwingHigh) and ph > prevSwingHigh
        label.new(bar_index - pivLen, ph, isHH ? "HH" : "LH", style = label.style_label_down, color = color.new(color.black, 100), textcolor = isHH ? colBull : colBear, size = size.tiny)

if newLow
    prevSwingLow := lastSwingLow
    lastSwingLow := pl
    swingLowBar  := bar_index - pivLen
    dnLevel      := pl
    dnLevelBar   := bar_index - pivLen
    dnTaken      := false
    swLoTaken    := false
    if showMS
        bool isHL = not na(prevSwingLow) and pl > prevSwingLow
        label.new(bar_index - pivLen, pl, isHL ? "HL" : "LL", style = label.style_label_up, color = color.new(color.black, 100), textcolor = isHL ? colBull : colBear, size = size.tiny)

// ----------------------------------------------------------------------------
//  Per-bar event flags
// ----------------------------------------------------------------------------
bool bosBull   = false
bool bosBear   = false
bool chochBull = false
bool chochBear = false
bool sweepBull = false
bool sweepBear = false
bool fvgBull   = false
bool fvgBear   = false
bool obBull    = false
bool obBear    = false

// ----------------------------------------------------------------------------
//  MODULE 2 — DISPLACEMENT QUALITY (graded at the break candle)
//  Weak / Valid / Institutional from body strength + ATR + volume expansion.
// ----------------------------------------------------------------------------
gradeDisplacement() =>
    float rng  = high - low
    float body = math.abs(close - open)
    bool bodyStrong = rng > 0 and body / rng > 0.55
    bool atrExp     = atrVal > 0 and rng / atrVal > 1.5
    bool volExp     = volOk and volume / volAvg > 1.5
    int  s = (bodyStrong ? 1 : 0) + (atrExp ? 1 : 0) + (volExp ? 1 : 0)
    string cls = volOk ? (s >= 3 ? "Institutional Break" : s == 2 ? "Valid Break" : "Weak Break") : (s >= 2 ? "Institutional Break" : s == 1 ? "Valid Break" : "Weak Break")
    cls

var string lastDisp = "—"
var bool   lastDispInst = false

// ----------------------------------------------------------------------------
//  MODULE 3 — BOS / CHOCH (confirmed close beyond a confirmed swing level)
// ----------------------------------------------------------------------------
var int trendDir = 0   // 1 bullish, -1 bearish, 0 neutral

if not na(upLevel) and not upTaken and barstate.isconfirmed and close > upLevel and bullOk
    upTaken := true
    bool isChoch = trendDir <= 0
    trendDir := 1
    if isChoch
        chochBull := true
    else
        bosBull := true
    string disp = showDisp ? gradeDisplacement() : ""
    lastDisp := showDisp ? disp : lastDisp
    lastDispInst := showDisp ? disp == "Institutional Break" : lastDispInst
    color bcCol = isChoch ? C_MAG : C_CYAN
    bool  show  = isChoch ? showCHOCH : showBOS
    if show
        line.new(upLevelBar, upLevel, bar_index, upLevel, color = bcCol, style = line.style_dashed, width = 1)
        label.new(bar_index, upLevel, isChoch ? "CHoCH" : "BOS", style = label.style_label_down, color = color.new(bcCol, 75), textcolor = color.white, size = size.tiny)

if not na(dnLevel) and not dnTaken and barstate.isconfirmed and close < dnLevel and bearOk
    dnTaken := true
    bool isChoch = trendDir >= 0
    trendDir := -1
    if isChoch
        chochBear := true
    else
        bosBear := true
    string disp = showDisp ? gradeDisplacement() : ""
    lastDisp := showDisp ? disp : lastDisp
    lastDispInst := showDisp ? disp == "Institutional Break" : lastDispInst
    color bcCol = isChoch ? C_MAG : C_BEAR
    bool  show  = isChoch ? showCHOCH : showBOS
    if show
        line.new(dnLevelBar, dnLevel, bar_index, dnLevel, color = bcCol, style = line.style_dashed, width = 1)
        label.new(bar_index, dnLevel, isChoch ? "CHoCH" : "BOS", style = label.style_label_up, color = color.new(bcCol, 75), textcolor = color.white, size = size.tiny)

// ----------------------------------------------------------------------------
//  MODULE 4 — LIQUIDITY SWEEPS (wick beyond a swing, close back inside)
// ----------------------------------------------------------------------------
var int lastSweepBar = -100000

if showSweep and barstate.isconfirmed
    // sell-side sweep: wick pierces the last swing low, close holds back above it (once per swing)
    if not swLoTaken and not na(lastSwingLow) and low < lastSwingLow and close > lastSwingLow and bullOk
        sweepBull := true
        swLoTaken := true
        lastSweepBar := bar_index
    // buy-side sweep: wick pierces the last swing high, close holds back below it (once per swing)
    if not swHiTaken and not na(lastSwingHigh) and high > lastSwingHigh and close < lastSwingHigh and bearOk
        sweepBear := true
        swHiTaken := true
        lastSweepBar := bar_index

// clean triangle markers instead of text labels — no chart clutter
plotshape(showSweep and sweepBull, "Sell-side Sweep", style = shape.triangleup, location = location.belowbar, color = C_CYAN, size = size.tiny)
plotshape(showSweep and sweepBear, "Buy-side Sweep", style = shape.triangledown, location = location.abovebar, color = C_MAG, size = size.tiny)

// ----------------------------------------------------------------------------
//  MODULE 5 — FAIR VALUE GAPS (3-candle imbalance + mitigation quality)
//  state: 0 Fresh · 1 Partially mitigated · 2 Filled
// ----------------------------------------------------------------------------
var array<box>  fvgBox = array.new<box>()
var array<int>  fvgD   = array.new<int>()
var array<int>  fvgSt  = array.new<int>()

if showFVG and barstate.isconfirmed
    if low > high[2]
        fvgBull := true
        box b = box.new(bar_index[1], low, bar_index, high[2], border_color = color.new(colBull, 55), bgcolor = color.new(colBull, zoneTransp))
        array.push(fvgBox, b)
        array.push(fvgD, 1)
        array.push(fvgSt, 0)
    if high < low[2]
        fvgBear := true
        box b = box.new(bar_index[1], low[2], bar_index, high, border_color = color.new(colBear, 55), bgcolor = color.new(colBear, zoneTransp))
        array.push(fvgBox, b)
        array.push(fvgD, -1)
        array.push(fvgSt, 0)

// maintain FVG: progress state Fresh -> Partial -> Filled, extend / fade / remove
if barstate.isconfirmed and array.size(fvgBox) > 0
    for i = array.size(fvgBox) - 1 to 0
        box b = array.get(fvgBox, i)
        int d = array.get(fvgD, i)
        int st = array.get(fvgSt, i)
        float top = box.get_top(b)
        float bot = box.get_bottom(b)
        bool entered = d == 1 ? low <= top : high >= bot       // price touched the gap
        bool filled  = d == 1 ? low <= bot : high >= top       // gap fully filled
        if filled and st < 2
            st := 2
        else if entered and st < 1
            st := 1
        array.set(fvgSt, i, st)
        if st == 2
            if fvgMode == "Active only"
                box.delete(b)
                array.remove(fvgBox, i)
                array.remove(fvgD, i)
                array.remove(fvgSt, i)
            else
                box.set_right(b, bar_index)
                box.set_bgcolor(b, color.new(color.gray, 93))
                box.set_border_color(b, color.new(color.gray, 80))
        else
            box.set_right(b, bar_index)
            box.set_bgcolor(b, color.new(d == 1 ? colBull : colBear, st == 1 ? math.min(zoneTransp + 6, 97) : zoneTransp))

while array.size(fvgBox) > fvgMax
    box old = array.shift(fvgBox)
    array.shift(fvgD)
    array.shift(fvgSt)
    box.delete(old)

// ----------------------------------------------------------------------------
//  MODULE 6 — ORDER BLOCKS (last opposite candle before a confirmed break)
//  state: 0 Fresh · 1 Touched · 2 Invalidated
// ----------------------------------------------------------------------------
var array<box>  obBox = array.new<box>()
var array<int>  obD   = array.new<int>()
var array<int>  obSt  = array.new<int>()

if showOB and barstate.isconfirmed
    if bosBull or chochBull
        int found = -1
        for off = 1 to obLookback
            if close[off] < open[off]
                found := off
                break
        if found >= 0
            box b = box.new(bar_index[found], high[found], bar_index, low[found], border_color = color.new(C_CYAN, 45), bgcolor = color.new(C_CYAN, zoneTransp))
            array.push(obBox, b)
            array.push(obD, 1)
            array.push(obSt, 0)
            obBull := true
    if bosBear or chochBear
        int found = -1
        for off = 1 to obLookback
            if close[off] > open[off]
                found := off
                break
        if found >= 0
            box b = box.new(bar_index[found], high[found], bar_index, low[found], border_color = color.new(C_MAG, 45), bgcolor = color.new(C_MAG, zoneTransp))
            array.push(obBox, b)
            array.push(obD, -1)
            array.push(obSt, 0)
            obBear := true

// maintain OB: Fresh -> Touched -> Invalidated
if barstate.isconfirmed and array.size(obBox) > 0
    for i = array.size(obBox) - 1 to 0
        box b = array.get(obBox, i)
        int d = array.get(obD, i)
        int st = array.get(obSt, i)
        float top = box.get_top(b)
        float bot = box.get_bottom(b)
        bool touched = d == 1 ? low <= top : high >= bot
        bool invalid = d == 1 ? close < bot : close > top
        if invalid and st < 2
            st := 2
        else if touched and st < 1
            st := 1
        array.set(obSt, i, st)
        if st == 2
            box.set_right(b, bar_index)
            box.set_bgcolor(b, color.new(color.gray, 93))
            box.set_border_color(b, color.new(color.gray, 80))
        else
            box.set_right(b, bar_index)
            box.set_bgcolor(b, color.new(d == 1 ? C_CYAN : C_MAG, st == 1 ? math.min(zoneTransp + 6, 97) : zoneTransp))

while array.size(obBox) > obMax
    box old = array.shift(obBox)
    array.shift(obD)
    array.shift(obSt)
    box.delete(old)

// ----------------------------------------------------------------------------
//  MODULE 7 — PREMIUM / DISCOUNT (last confirmed swing range)
// ----------------------------------------------------------------------------
var box  premBox = na
var box  discBox = na
var line eqLine  = na

if showPD and not na(lastSwingHigh) and not na(lastSwingLow) and lastSwingHigh > lastSwingLow and not na(swingHighBar) and not na(swingLowBar)
    float eq = math.avg(lastSwingHigh, lastSwingLow)
    int   lft = swingHighBar < swingLowBar ? swingHighBar : swingLowBar
    int   rgt = bar_index + 8
    if na(premBox)
        premBox := box.new(lft, lastSwingHigh, rgt, eq, border_color = color.new(C_BEAR, 80), bgcolor = color.new(C_BEAR, 94))
        discBox := box.new(lft, eq, rgt, lastSwingLow, border_color = color.new(C_BULL, 80), bgcolor = color.new(C_BULL, 94))
        eqLine  := line.new(lft, eq, rgt, eq, color = color.new(C_DIM, 30), style = line.style_dotted, width = 1)
    box.set_lefttop(premBox, lft, lastSwingHigh)
    box.set_rightbottom(premBox, rgt, eq)
    box.set_lefttop(discBox, lft, eq)
    box.set_rightbottom(discBox, rgt, lastSwingLow)
    line.set_xy1(eqLine, lft, eq)
    line.set_xy2(eqLine, rgt, eq)

// price location within the range (for the score + phase)
inPremium  = showPD and not na(lastSwingHigh) and not na(lastSwingLow) and lastSwingHigh > lastSwingLow and close > math.avg(lastSwingHigh, lastSwingLow)
inDiscount = showPD and not na(lastSwingHigh) and not na(lastSwingLow) and lastSwingHigh > lastSwingLow and close < math.avg(lastSwingHigh, lastSwingLow)

// ----------------------------------------------------------------------------
//  MODULE 8 — SMART MONEY SCORE (0-100 market CONTEXT — NOT a signal)
// ----------------------------------------------------------------------------
var float fBosF   = 0.0
var float fChochF = 0.0
var float fSweepF = 0.0
var float fFvgF   = 0.0
var int   smScore = 50
var string smTxt  = "Neutral"
var bool   inZone = false

if barstate.isconfirmed
    // decaying event factors (recent confluence fades over ~10-15 bars)
    fBosF   := bosBull ? 1.0 : bosBear ? -1.0 : fBosF * 0.92
    fChochF := chochBull ? 1.0 : chochBear ? -1.0 : fChochF * 0.92
    fSweepF := sweepBull ? 1.0 : sweepBear ? -1.0 : fSweepF * 0.90
    fFvgF   := fvgBull ? 1.0 : fvgBear ? -1.0 : fFvgF * 0.90
    // order-block proximity: price sitting inside a live zone
    float fOb = 0.0
    inZone := false
    if array.size(obBox) > 0
        for i = 0 to array.size(obBox) - 1
            if array.get(obSt, i) < 2
                box b = array.get(obBox, i)
                if close <= box.get_top(b) and close >= box.get_bottom(b)
                    fOb := array.get(obD, i) == 1 ? 1.0 : -1.0
                    inZone := true
    if not inZone and array.size(fvgBox) > 0
        for i = 0 to array.size(fvgBox) - 1
            if array.get(fvgSt, i) < 2
                box b = array.get(fvgBox, i)
                if close <= box.get_top(b) and close >= box.get_bottom(b)
                    inZone := true
    float fStruct = trendDir
    float fEma = bullBias ? 1.0 : bearBias ? -1.0 : 0.0
    float fPD = inDiscount ? 0.5 : inPremium ? -0.5 : 0.0   // discount favours longs
    // weighted confluence, normalised to 0-100 (50 = neutral)
    float raw = 2.0 * fStruct + 2.0 * fBosF + 1.0 * fChochF + 1.0 * fSweepF + 1.0 * fFvgF + 1.0 * fOb + 2.0 * fEma + fPD
    float maxRaw = 10.5
    smScore := int(math.round(math.max(0, math.min(100, 50 + (raw / maxRaw) * 50))))
    smTxt := smScore >= 75 ? "Strong Bullish" : smScore >= 60 ? "Bullish" : smScore >= 41 ? "Neutral" : smScore >= 26 ? "Bearish" : "Strong Bearish"

// ----------------------------------------------------------------------------
//  MODULE 9 — MARKET PHASE + LIQUIDITY STATE
// ----------------------------------------------------------------------------
var string phase = "—"
if barstate.isconfirmed
    if chochBull
        phase := "Accumulation"
    else if chochBear
        phase := "Distribution"
    else if (bosBull or bosBear) and lastDispInst
        phase := "Expansion"
    else if inZone
        phase := "Pullback"

liqTaken = (bar_index - lastSweepBar) <= 10

// ----------------------------------------------------------------------------
//  MODULE 10 — DASHBOARD (compact, top-right, last bar only)
// ----------------------------------------------------------------------------
activeFvg = 0
if array.size(fvgSt) > 0
    for i = 0 to array.size(fvgSt) - 1
        activeFvg += array.get(fvgSt, i) < 2 ? 1 : 0
activeOb = 0
if array.size(obSt) > 0
    for i = 0 to array.size(obSt) - 1
        activeOb += array.get(obSt, i) < 2 ? 1 : 0

var table dash = na
if showDash and barstate.islast
    if na(dash)
        dash := table.new(position.top_right, 2, 10, bgcolor = C_PANEL, frame_color = color.new(C_CYAN, 65), frame_width = 1, border_color = color.new(C_CYAN, 82), border_width = 1)
    color scoreCol = smScore >= 60 ? C_BULL : smScore <= 40 ? C_BEAR : C_DIM
    string biasTxt = trendDir == 1 ? "Bullish" : trendDir == -1 ? "Bearish" : "Neutral"
    color  biasCol = trendDir == 1 ? colBull : trendDir == -1 ? colBear : color.gray
    table.cell(dash, 0, 0, "AlgoSentry", text_color = C_CYAN, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 0, "SMC", text_color = C_MAG, text_size = size.small, text_halign = text.align_right)
    table.cell(dash, 0, 1, "Smart Money", text_color = C_INK, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, 1, showScore ? str.tostring(smScore) + " · " + smTxt : "—", text_color = scoreCol, text_size = size.tiny, text_halign = text.align_right)
    table.cell(dash, 0, 2, "Structure", text_color = C_INK, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, 2, biasTxt, text_color = biasCol, text_size = size.tiny, text_halign = text.align_right)
    table.cell(dash, 0, 3, "Liquidity", text_color = C_INK, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, 3, liqTaken ? "Taken" : "Resting", text_color = liqTaken ? C_MAG : C_DIM, text_size = size.tiny, text_halign = text.align_right)
    table.cell(dash, 0, 4, "Phase", text_color = C_INK, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, 4, phase, text_color = C_CYAN, text_size = size.tiny, text_halign = text.align_right)
    table.cell(dash, 0, 5, "Last break", text_color = C_INK, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, 5, lastDisp, text_color = lastDispInst ? C_BULL : C_DIM, text_size = size.tiny, text_halign = text.align_right)
    table.cell(dash, 0, 6, "Active FVG", text_color = C_INK, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, 6, str.tostring(activeFvg), text_color = C_INK, text_size = size.tiny, text_halign = text.align_right)
    table.cell(dash, 0, 7, "Active OB", text_color = C_INK, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, 7, str.tostring(activeOb), text_color = C_INK, text_size = size.tiny, text_halign = text.align_right)
    table.cell(dash, 0, 8, "EMA filter", text_color = C_INK, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, 8, reqAlign ? "On" : "Off", text_color = reqAlign ? C_BULL : C_DIM, text_size = size.tiny, text_halign = text.align_right)
    table.cell(dash, 0, 9, "Non-Repaint", text_color = C_INK, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, 9, "Confirmed ✓", text_color = C_BULL, text_size = size.tiny, text_halign = text.align_right)

// ----------------------------------------------------------------------------
//  MODULE 11 — ALERTS (all candle-close confirmed by construction)
// ----------------------------------------------------------------------------
alertcondition(bosBull,   "Bullish BOS",     "AlgoSentry SMC: Bullish Break of Structure (confirmed close)")
alertcondition(bosBear,   "Bearish BOS",     "AlgoSentry SMC: Bearish Break of Structure (confirmed close)")
alertcondition(chochBull, "Bullish CHoCH",   "AlgoSentry SMC: Bullish Change of Character (confirmed close)")
alertcondition(chochBear, "Bearish CHoCH",   "AlgoSentry SMC: Bearish Change of Character (confirmed close)")
alertcondition(sweepBull, "Sell-side Sweep", "AlgoSentry SMC: Sell-side liquidity sweep (confirmed close)")
alertcondition(sweepBear, "Buy-side Sweep",  "AlgoSentry SMC: Buy-side liquidity sweep (confirmed close)")
alertcondition(fvgBull,   "Bullish FVG",     "AlgoSentry SMC: New bullish Fair Value Gap (confirmed close)")
alertcondition(fvgBear,   "Bearish FVG",     "AlgoSentry SMC: New bearish Fair Value Gap (confirmed close)")
alertcondition(obBull,    "Bullish OB",      "AlgoSentry SMC: New bullish Order Block (confirmed close)")
alertcondition(obBear,    "Bearish OB",      "AlgoSentry SMC: New bearish Order Block (confirmed close)")
````
