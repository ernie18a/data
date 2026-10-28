# MJQ.Smart Money - Zones, Sweeps & Gaps

- url: https://www.tradingview.com/script/VtNPVszW-MJQ-Smart-Money-Zones-Sweeps-Gaps/
- type: indicator
- pine_id: PUB;c4a82914a34a432d9423e7e1632005d4
- version: 1.0

## Description

MJQ Smart Money — multi-timeframe supply/demand, liquidity and structure toolkit

  One overlay that maps where smart money is likely positioned, across your entry, setup and bias timeframes.

  What it draws

  - Supply / Demand zones (unified engine) — finds a quiet consolidation base and only stamps a zone when price departs
  from it with an impulse ≥ 1.2× ATR. Covers all four patterns (rally-base-rally, rally-base-drop, drop-base-drop,
  drop-base-rally). Zones are detected on the chart TF plus Daily, 4H and 1H simultaneously, with a proximity filter so
  only actionable levels near price are drawn.
  - Zone lifecycle — fresh zones are protected by a grace period, fade to dimmed/dashed on first proximal touch
  ("tested", still tradeable), and are removed when the distal edge breaks. Daily+ zones mitigate on first touch since
  daily tests are real mitigations.
  - Liquidity sweeps — pin-bar or engulfing rejections that run stops above confirmed highs (BSL) or below confirmed
  lows (SSL).
  - Market structure — BOS and CHoCH on the chart timeframe, plus an HTF bias engine (auto-mapped or manual HTF) that
  tracks higher-timeframe structure; optionally filter signals to align with HTF bias.
  - Fair Value Gaps — unfilled FVGs with automatic removal once filled.
  - Price gap detector — unfilled session/daily gaps, auto-removed on fill.
  - Round numbers — psychological levels marked inside zones.
  - Dashboard — at-a-glance HTF bias, structure state and module status.

  Trading profiles — pick Swing (Daily bias / 4H setup / 1H entry) or Intraday (1H bias / 15m setup / 3m entry) and the
  zone timeframes configure themselves; Custom uses your own TF slots.

  Alerts — bullish/bearish liquidity sweeps, LTF CHoCH, HTF BOS and HTF CHoCH (8 conditions).

  ---
  Release notes for this version (from recent work)

  - Unified S/D engine: order blocks merged into one base-plus-departure detector across all four patterns
  - Chop filter: minimum departure raised to 1.2× ATR to kill sideways-market zone spam
  - Fixed zone-bound inflation bug (backward loop) that overstated all zone heights
  - New touch handling: Fade/Remove modes, wick-vs-close distal failure, Daily+ first-touch removal
  - Zone proximity filter (15× ATR default) keeps the chart to actionable levels only
  - Trading Profile presets (Swing / Intraday) for automatic timeframe selection

## Source Code

````pine
//@version=6
indicator("MJQ Smart $ ",
     overlay            = true,
     max_boxes_count    = 500,
     max_lines_count    = 500,
     max_labels_count   = 500)

// ══════════════════════════════════════════════════════════════════
// ▸ PALETTE
// ══════════════════════════════════════════════════════════════════
C_BULL       = #26a69a
C_BEAR       = #ef5350
C_FVG_BULL   = #ff9800
C_FVG_BEAR   = #7e57c2
C_DEMAND     = #00bcd4
C_SUPPLY     = #e91e63
C_GAP_UP     = #66bb6a
C_GAP_DN     = #ef5350
C_NEUTRAL    = #787b86
C_RN         = #ffca28
C_DASH_BG    = #131722
C_DASH_HEAD  = #1e222d
C_DASH_BORD  = #363a45
C_TXT_PRI    = #d1d4dc
C_TXT_SEC    = #787b86

// ══════════════════════════════════════════════════════════════════
// ▸ INPUT GROUPS
// ══════════════════════════════════════════════════════════════════
GRP_HTF     = "HTF Bias Engine"
GRP_STRUCT  = "Market Structure (LTF)"
GRP_SWEEP   = "Liquidity Sweeps"
GRP_FVG     = "Fair Value Gaps"
GRP_SD      = "Supply / Demand Zones (unified engine)"
GRP_TF      = "Zone Timeframes (Chart + Daily + 4H + 1H)"
GRP_RN      = "Round Numbers (psych levels)"
GRP_GAP     = "Price Gap Detector"
GRP_DASH    = "Dashboard"

// ══════════════════════════════════════════════════════════════════
// ▸ INPUTS
// ══════════════════════════════════════════════════════════════════
i_htfMode      = input.string("Auto", "HTF Selection", options=["Auto","30","60","240","D","W"], group=GRP_HTF)
i_pivotLen     = input.int(10, "HTF Pivot Length", minval=2, group=GRP_HTF)
i_alignFilter  = input.bool(false, "Align LTF signals with HTF bias", group=GRP_HTF)

i_ltfPivLen    = input.int(5, "LTF Pivot Length (BOS / CHoCH anchor)", minval=2, group=GRP_STRUCT)

i_showSweeps    = input.bool(true,  "Show Liquidity Sweeps", group=GRP_SWEEP)
i_sweepPivLen   = input.int (10,    "Pivot length (each side)", minval=3, maxval=50, group=GRP_SWEEP)
i_sweepMinPen   = input.float(0.1,  "Min wick penetration (× ATR)", minval=0.0, step=0.05, group=GRP_SWEEP)
i_pinRatio      = input.float(2.0,  "Pin bar: wick : body ratio", minval=1.0, step=0.1, group=GRP_SWEEP)
i_engulfingOK   = input.bool(true,  "Allow engulfing pattern as sweep", group=GRP_SWEEP)

i_showFVG      = input.bool(false, "Show Fair Value Gaps", group=GRP_FVG)
i_fvgCount     = input.int(3, "Max unfilled FVGs (total)", minval=1, maxval=40, group=GRP_FVG)
i_mitigateFVG  = input.bool(true, "Auto-remove fully-filled FVGs", group=GRP_FVG)
i_fvgExtend    = input.int(10, "FVG right-edge buffer (bars)", minval=2, maxval=50, group=GRP_FVG)

// ── Unified Supply / Demand engine (Order Blocks merged in).  Fresh only. ──
//    Supply = last BULLISH candle that created the drop (+ its base).
//    Demand = last BEARISH candle that created the rally (+ its base).
//    A zone is ONLY drawn once the impulse out of the base is >= impMult x ATR (FVG not required).
i_showSD     = input.bool(true, "Show Zones", group=GRP_SD)
i_sdCount    = input.int(6, "Max stored zones per side, per TF", minval=1, maxval=20, group=GRP_SD,
     tooltip="Keeps the N most-recently-formed unmitigated zones per side; older untouched zones age out (oldest first). Higher = keeps deeper/older zones but a busier chart; lower = cleaner, only the freshest zones.")
i_sdMaxBase  = input.int(5, "Max base candles", minval=1, maxval=10, group=GRP_SD,
     tooltip="A base is the consolidation a zone is built from. The candle right before the departure is always part of the base; this many MORE quiet candles before it can be absorbed into the same base. Bigger = fatter zones that wrap longer consolidations.")
i_sdImpATR   = input.float(1.2, "Min departure out of base (× ATR)", minval=0.3, step=0.1, group=GRP_SD,
     tooltip="The candle LEAVING the base must have a range >= this x ATR and push beyond the base. Departs UP = demand, departs DOWN = supply. Also doubles as the distance price must impulse away before a fresh zone can be mitigated. Lower = catches gentler moves out of the base (more zones).")
i_sdBaseFrac = input.float(0.5, "Base candle max range (× ATR)", minval=0.1, step=0.05, group=GRP_SD,
     tooltip="A candle is absorbed into the consolidation BASE only if its full range is <= this x ATR. Looser (higher) pulls busier candles into the base (fatter zones); tighter treats only very quiet candles as base. The candle immediately before the departure is always included regardless.")
i_sdBaseAnchorATR = input.float(6.5, "Max base-candle size (× ATR)", minval=0.1, step=0.1, group=GRP_SD,
     tooltip="The base ANCHOR candle (the one right before the departure) must itself be no bigger than this x ATR — so a real quiet base is required, not just a big trend candle. This stops a strong impulse leg from stamping a demand/supply zone on every step (no genuine base). Lower = stricter (only quiet bases qualify, fewer zones); set very high to effectively disable.")
i_sdBaseMaxATR = input.float(3.0, "Max base width (× ATR, 0 = off)", minval=0.0, step=0.5, group=GRP_SD,
     tooltip="Caps total box thickness so a sloppy base can't make a giant zone: supply keeps its proximal LOW edge and trims the top; demand keeps its proximal HIGH edge and trims the bottom. 0 = no cap.")

// ── Zone Timeframes: chart TF (replaces old Order Blocks) + Daily + 4H + 1H ──
i_useChart = input.bool(true,  "Detect zones on chart timeframe", group=GRP_TF,
     tooltip="Runs the unified engine on the current chart timeframe. This replaces the old Order Blocks engine.")
i_useTFA = input.bool(true,  "Detect zones on Daily", group=GRP_TF)
i_tfA    = input.timeframe("D",   "Daily TF", group=GRP_TF)
i_useTFB = input.bool(true,  "Detect zones on 4H", group=GRP_TF)
i_tfB    = input.timeframe("240", "4H TF", group=GRP_TF)
i_useTFC = input.bool(true,  "Detect zones on 1H", group=GRP_TF)
i_tfC    = input.timeframe("60",  "1H TF", group=GRP_TF)

// ── Round numbers: psychological levels inside zones (lines only, no text) ──
i_showRN = input.bool(true, "Mark round numbers inside zones", group=GRP_RN)
i_rnStep = input.float(0.0, "Round-number step (0 = auto)", minval=0.0, group=GRP_RN,
     tooltip="Grid spacing for psych levels. 0 auto-derives from price (e.g. ~20000 -> 200, a $400 stock -> 5).")
i_rnBoth = input.bool(true, "Also mark in demand zones (off = supply only)", group=GRP_RN)

// ── Gap Detector: chart TF + Daily only, unfilled only, no ATR filter ──
i_showGaps      = input.bool(true,  "Show price gaps", group=GRP_GAP,
     tooltip="Detects unfilled price gaps. Chart TF + Daily only. Filled gaps are removed automatically.")
i_gapChart      = input.bool(true,  "Detect chart-TF gaps", group=GRP_GAP)
i_gapD          = input.bool(true,  "Detect Daily gaps",   group=GRP_GAP)

i_showDash     = input.bool(true, "Show Dashboard", group=GRP_DASH)
i_dashPos      = input.string("top_right", "Position",
     options=["top_right","top_left","bottom_right","bottom_left","middle_right"], group=GRP_DASH)

// ── Mitigation cooldown ──
i_sdGrace = input.int(5, "Min bars before a zone can be mitigated", minval=0, maxval=50, group=GRP_SD,
     tooltip="A fresh zone is protected from invalidation for this many bars after it forms, so the base candle's own wick or an immediate 2-3 bar revisit can't kill it before price has impulsed away. Counted in the detection TF's bars (Daily / 4H / 1H).")

// ── Trading profile: auto-picks the bias + setup detection timeframes ──
//    Declared LAST so existing input indices stay stable across a re-add.
i_profile = input.string("Custom", "Trading Profile (auto TFs)",
     options=["Swing","Intraday","Custom"], group=GRP_TF,
     tooltip="Swing = Daily bias + 4H setup; view 1H to enter. Intraday = 1H bias + 15m setup; view 3m to enter. Each draws zones on its two higher TFs PLUS your chart TF (your entry), labelled Bias / Setup / Entry. Custom = use the manual Daily / 4H / 1H slots above.")

// ── Zone proximity filter (declared after i_profile to keep input indices stable) ──
i_zoneMaxDist = input.float(15.0, "Max zone distance from price (× ATR, 0 = off)", minval=0.0, step=1.0, group=GRP_SD,
     tooltip="Zones whose proximal edge sits further than this × ATR(20) from the last close are kept in memory but NOT drawn, so the chart only shows actionable levels. 0 = draw every stored zone.")

// ── Touch handling (declared after i_zoneMaxDist to keep input indices stable) ──
i_touchMode = input.string("Fade", "On first proximal touch", options=["Fade","Remove"], group=GRP_SD,
     tooltip="What happens when price taps an ARMED zone's proximal edge (the entry touch). Fade = keep the zone on the chart, dimmed + dashed, so you can still trade the test; it is only removed when a candle CLOSES through the distal edge (zone failed). Remove = old behavior, zone disappears on the first touch.")

// ── Distal failure + Daily touch exemption (declared after i_touchMode to keep input indices stable) ──
i_failMode = input.string("Wick", "Zone fails (distal break) on", options=["Wick","Close"], group=GRP_SD,
     tooltip="How a zone dies at its DISTAL (far) edge. Wick = any trade through the far edge removes it — the resting supply/demand has been consumed, no close required. Also frees the space so a fresher zone (e.g. a sweep candle) can be stamped there. Close = old behavior, a candle must CLOSE through the far edge.")
i_dailyTouchRemove = input.bool(true, "Daily+ zones remove on first touch", group=GRP_SD,
     tooltip="Zones detected on Daily or higher TFs skip the dimmed 'tested' state: the first armed touch of the proximal edge removes the zone outright (Remove mode), regardless of the touch setting above. Daily carries little noise — a touch there is a real mitigation, so no tested zones linger on the daily map.")

// ══════════════════════════════════════════════════════════════════
// ▸ HTF AUTO-MAPPING
// ══════════════════════════════════════════════════════════════════
autoHTF() =>
    string out = "240"
    string cur = timeframe.period
    if cur == "1" or cur == "3"
        out := "60"
    else if cur == "5"
        out := "240"
    else if cur == "15"
        out := "240"
    else if cur == "30"
        out := "240"
    else if cur == "60"
        out := "240"
    else if cur == "120" or cur == "240"
        out := "D"
    else if cur == "D"
        out := "W"
    else
        sec = timeframe.in_seconds(timeframe.period)
        out := sec <= 180 ? "60" : sec <= 3600 ? "240" : sec <= 14400 ? "D" : "W"
    out

// Profile resolves the bias + setup detection timeframes (Custom falls back to the manual slots).
biasTF  = i_profile == "Swing" ? "D"   : i_profile == "Intraday" ? "60" : i_tfA
setupTF = i_profile == "Swing" ? "240" : i_profile == "Intraday" ? "15" : i_tfB
// Bias-engine (structure) TF follows the profile too; Custom keeps the manual HTF Selection.
htfTF   = i_profile == "Custom" ? (i_htfMode == "Auto" ? autoHTF() : i_htfMode) : biasTF

// ══════════════════════════════════════════════════════════════════
// ▸ ROUND-NUMBER AUTO STEP
// ══════════════════════════════════════════════════════════════════
f_autoRN(float p) =>
    out = 0.0
    if not na(p) and p > 0
        raw  = p / 100.0
        mag  = math.pow(10, math.floor(math.log10(raw)))
        norm = raw / mag
        nice = norm < 1.5 ? 1.0 : norm < 3.5 ? 2.0 : norm < 7.5 ? 5.0 : 10.0
        out := nice * mag
    out

// ══════════════════════════════════════════════════════════════════
// ▸ HTF STRUCTURE
// ══════════════════════════════════════════════════════════════════
htfStructCalc() =>
    var float _pH1 = na, var float _pH2 = na, var float _pH3 = na
    var float _pL1 = na, var float _pL2 = na, var float _pL3 = na
    var int   _bias = 0

    bool brokeH = not na(_pH1) and close > _pH1 and close[1] <= _pH1
    bool brokeL = not na(_pL1) and close < _pL1 and close[1] >= _pL1

    int newEvent = 0
    if brokeH
        newEvent := _bias == -1 ? 3 : 1
        _bias    := 1
    if brokeL
        newEvent := _bias == 1 ? 4 : 2
        _bias    := -1

    pH = ta.pivothigh(i_pivotLen, i_pivotLen)
    pL = ta.pivotlow (i_pivotLen, i_pivotLen)

    if not na(pH)
        _pH3 := _pH2
        _pH2 := _pH1
        _pH1 := pH
    if not na(pL)
        _pL3 := _pL2
        _pL2 := _pL1
        _pL1 := pL

    if _bias == 0 and not na(_pH1) and not na(_pH2) and not na(_pL1) and not na(_pL2)
        if _pH1 > _pH2 and _pL1 > _pL2
            _bias := 1
        else if _pH1 < _pH2 and _pL1 < _pL2
            _bias := -1

    [_bias, newEvent, _pH1, _pH2, _pH3, _pL1, _pL2, _pL3]

[htfBias, htfEvent, pH1, pH2, pH3, pL1, pL2, pL3] = request.security(syminfo.tickerid, htfTF, htfStructCalc(), lookahead=barmerge.lookahead_off)

var string biasStr   = "Neutral"
var color  biasColor = color.new(C_NEUTRAL, 0)
if htfBias == 1
    biasStr   := "Bullish"
    biasColor := color.new(C_BULL, 0)
else if htfBias == -1
    biasStr   := "Bearish"
    biasColor := color.new(C_BEAR, 0)
else
    biasStr   := "Neutral"
    biasColor := color.new(C_NEUTRAL, 0)

have3H = not na(pH1) and not na(pH2) and not na(pH3)
have3L = not na(pL1) and not na(pL2) and not na(pL3)
have2H = not na(pH1) and not na(pH2)
have2L = not na(pL1) and not na(pL2)
var string structStr = "Building"
if have3H and have3L and pH1 > pH2 and pH2 > pH3 and pL1 > pL2 and pL2 > pL3
    structStr := "3·HH + 3·HL"
else if have3H and have3L and pH1 < pH2 and pH2 < pH3 and pL1 < pL2 and pL2 < pL3
    structStr := "3·LH + 3·LL"
else if have2H and have2L and pH1 > pH2 and pL1 > pL2
    structStr := "HH + HL"
else if have2H and have2L and pH1 < pH2 and pL1 < pL2
    structStr := "LH + LL"
else if have2H and have2L
    structStr := "Mixed"

var string htfEventStr = "—"
var color  htfEventCol = color.new(C_NEUTRAL, 0)
if htfEvent == 1
    htfEventStr := "HTF BOS ↑"
    htfEventCol := color.new(C_BULL, 0)
else if htfEvent == 2
    htfEventStr := "HTF BOS ↓"
    htfEventCol := color.new(C_BEAR, 0)
else if htfEvent == 3
    htfEventStr := "HTF CHoCH ↑"
    htfEventCol := color.new(C_BULL, 0)
else if htfEvent == 4
    htfEventStr := "HTF CHoCH ↓"
    htfEventCol := color.new(C_BEAR, 0)

// ══════════════════════════════════════════════════════════════════
// ▸ LTF STRUCTURE
// ══════════════════════════════════════════════════════════════════
ltfPivH = ta.pivothigh(i_ltfPivLen, i_ltfPivLen)
ltfPivL = ta.pivotlow (i_ltfPivLen, i_ltfPivLen)

var float lastSwingHigh = na
var float lastSwingLow  = na

if not na(ltfPivH)
    lastSwingHigh := ltfPivH
if not na(ltfPivL)
    lastSwingLow := ltfPivL

bullBOS_raw = ta.crossover (close, lastSwingHigh)
bearBOS_raw = ta.crossunder(close, lastSwingLow)
bullBOS = not na(lastSwingHigh) and bullBOS_raw
bearBOS = not na(lastSwingLow)  and bearBOS_raw

isCHoCHBull = bullBOS and biasStr == "Bearish"
isCHoCHBear = bearBOS and biasStr == "Bullish"

var string lastEvent  = "—"
var color  lastEventCol = color.new(C_NEUTRAL, 0)
var int    lastEventBar = na
if isCHoCHBull
    lastEvent := "Bullish CHoCH"
    lastEventCol := color.new(C_BULL, 0)
    lastEventBar := bar_index
else if isCHoCHBear
    lastEvent := "Bearish CHoCH"
    lastEventCol := color.new(C_BEAR, 0)
    lastEventBar := bar_index
else if bullBOS
    lastEvent := "Bullish BOS"
    lastEventCol := color.new(C_BULL, 0)
    lastEventBar := bar_index
else if bearBOS
    lastEvent := "Bearish BOS"
    lastEventCol := color.new(C_BEAR, 0)
    lastEventBar := bar_index

// ══════════════════════════════════════════════════════════════════
// ▸ LIQUIDITY SWEEPS
// ══════════════════════════════════════════════════════════════════
sweepPivH_raw = ta.pivothigh(i_sweepPivLen, i_sweepPivLen)
sweepPivL_raw = ta.pivotlow (i_sweepPivLen, i_sweepPivLen)

var float sweepRefHigh = na
var float sweepRefLow  = na
if not na(sweepPivH_raw)
    sweepRefHigh := sweepPivH_raw
if not na(sweepPivL_raw)
    sweepRefLow := sweepPivL_raw

sweepAtr  = ta.atr(20)
sweepBody = math.abs(close - open)
bodyOrMin = sweepBody > 0 ? sweepBody : syminfo.mintick
upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low

isPinBull = lowerWick >= i_pinRatio * bodyOrMin
isPinBear = upperWick >= i_pinRatio * bodyOrMin

isEngulfBull = i_engulfingOK and close > open and close[1] < open[1] and close >= open[1]
isEngulfBear = i_engulfingOK and close < open and close[1] > open[1] and close <= open[1]

penDepthBull = na(sweepRefLow)  ? na : sweepRefLow  - low
penDepthBear = na(sweepRefHigh) ? na : high - sweepRefHigh

rawBullSweep = i_showSweeps and not na(sweepRefLow)  and not na(sweepAtr) and low  < sweepRefLow  and close > sweepRefLow  and penDepthBull >= i_sweepMinPen * sweepAtr and (isPinBull or isEngulfBull)
rawBearSweep = i_showSweeps and not na(sweepRefHigh) and not na(sweepAtr) and high > sweepRefHigh and close < sweepRefHigh and penDepthBear >= i_sweepMinPen * sweepAtr and (isPinBear or isEngulfBear)

bullSweep = rawBullSweep and (not i_alignFilter or biasStr == "Bullish")
bearSweep = rawBearSweep and (not i_alignFilter or biasStr == "Bearish")

plotshape(bullSweep, "Bull Sweep", shape.circle, location.belowbar, color.new(C_BULL, 20), size=size.tiny)
plotshape(bearSweep, "Bear Sweep", shape.circle, location.abovebar, color.new(C_BEAR, 20), size=size.tiny)

var string lastSweep    = "—"
var color  lastSweepCol = color.new(C_NEUTRAL, 0)
if bullSweep
    lastSweep    := "SSL ↑"
    lastSweepCol := color.new(C_BULL, 0)
else if bearSweep
    lastSweep    := "BSL ↓"
    lastSweepCol := color.new(C_BEAR, 0)

// ══════════════════════════════════════════════════════════════════
// ▸ FAIR VALUE GAPS
// ══════════════════════════════════════════════════════════════════
var array<box> fvgs     = array.new<box>()
var array<int> fvgKinds = array.new<int>()

bullFVG = i_showFVG and low > high[2]
bearFVG = i_showFVG and high < low[2]

showBullFVG = bullFVG and (not i_alignFilter or biasStr != "Bearish")
showBearFVG = bearFVG and (not i_alignFilter or biasStr != "Bullish")

if showBullFVG
    bx = box.new(left=bar_index[2], top=low, right=bar_index + i_fvgExtend, bottom=high[2],
         bgcolor=na, border_color=color.new(C_FVG_BULL, 15), border_width=1, border_style=line.style_dashed)
    array.push(fvgs, bx)
    array.push(fvgKinds, 0)
    if array.size(fvgs) > i_fvgCount
        box.delete(array.shift(fvgs))
        array.shift(fvgKinds)

if showBearFVG
    bx = box.new(left=bar_index[2], top=low[2], right=bar_index + i_fvgExtend, bottom=high,
         bgcolor=na, border_color=color.new(C_FVG_BEAR, 15), border_width=1, border_style=line.style_dashed)
    array.push(fvgs, bx)
    array.push(fvgKinds, 1)
    if array.size(fvgs) > i_fvgCount
        box.delete(array.shift(fvgs))
        array.shift(fvgKinds)

if i_showFVG
    nF = array.size(fvgs)
    if nF > 0
        for i = nF - 1 to 0
            bx = array.get(fvgs, i)
            kind = array.get(fvgKinds, i)
            filled = kind == 0 ? low <= box.get_bottom(bx) : high >= box.get_top(bx)
            if filled and i_mitigateFVG
                box.delete(bx)
                array.remove(fvgs, i)
                array.remove(fvgKinds, i)
            else
                box.set_right(bx, bar_index + i_fvgExtend)

// ══════════════════════════════════════════════════════════════════
// ▸ SUPPLY / DEMAND ENGINE  —  BASE + DEPARTURE (all 4 patterns)
//   A zone is a BASE (a small consolidation) that price leaves with a
//   strong DEPARTURE candle. The DIRECTION of departure sets the type,
//   so this catches reversal AND continuation:
//     • departs UP   -> DEMAND  (Drop-Base-Rally  AND Rally-Base-Rally)
//     • departs DOWN -> SUPPLY  (Rally-Base-Drop  AND Drop-Base-Drop)
//   • BASE = the candle right before the departure (bar[2]) plus any
//     consecutive quiet candles before it whose RANGE <= baseFrac×ATR,
//     up to maxBase candles. Box = base high -> low (capped baseMaxATR×ATR).
//   • DEPARTURE = bar[1], range >= impMult×ATR, pushing beyond the base
//     (up: bullish & high > base high; down: bearish & low < base low).
//     FVG is NOT required.
//   • New zone is skipped if it overlaps an existing same-side zone.
//   • FRESH = removed when price taps the PROXIMAL edge (demand: low
//     <= top; supply: high >= bottom) but ONLY after the zone armed
//     (price impulsed impMult×ATR away) AND grace passed; OR removed
//     immediately (no arm needed) once a bar CLOSES through the DISTAL
//     edge (demand: close < bottom; supply: close > top).
//   • Keeps the latest keepN unmitigated zones per side; older ones age out (oldest first).
// ══════════════════════════════════════════════════════════════════
type Zone
    float top
    float bot
    int   tm
    int   kind   // 0 = demand, 1 = supply
    int   tst    // 0 = fresh, 1 = tested (proximal touch happened, zone kept)

sdDetect(float impMult, int keepN, int maxBase, float baseFrac, float baseAnchorATR, float baseMaxATR, int grace, bool removeOnTouch, bool failOnWick) =>
    var array<float> dTop = array.new<float>()
    var array<float> dBot = array.new<float>()
    var array<int>   dTm  = array.new<int>()
    var array<int>   dCb  = array.new<int>()
    var array<int>   dArm = array.new<int>()
    var array<int>   dTch = array.new<int>()
    var array<float> sTop = array.new<float>()
    var array<float> sBot = array.new<float>()
    var array<int>   sTm  = array.new<int>()
    var array<int>   sCb  = array.new<int>()
    var array<int>   sArm = array.new<int>()
    var array<int>   sTch = array.new<int>()

    atrV = ta.atr(20)

    // ---- FRESH check: armed proximal tap (after grace) marks the zone TESTED (or removes
    //      it in Remove mode); a close beyond the distal edge always removes (zone failed).
    //      Runs BEFORE arming so the same impulse bar that leaves the zone can't also kill it.
    if array.size(dTop) > 0
        for i = array.size(dTop) - 1 to 0
            dGok = (bar_index - array.get(dCb, i)) >= grace
            dPrx = low   <= array.get(dTop, i) and array.get(dArm, i) == 1 and dGok   // armed proximal tap (after grace)
            dDst = (failOnWick ? low : close) < array.get(dBot, i)                    // failed: traded (Wick) or closed (Close) beyond distal edge
            if dDst or (dPrx and removeOnTouch)
                array.remove(dTop, i)
                array.remove(dBot, i)
                array.remove(dTm, i)
                array.remove(dCb, i)
                array.remove(dArm, i)
                array.remove(dTch, i)
            else if dPrx
                array.set(dTch, i, 1)
    if array.size(sTop) > 0
        for i = array.size(sTop) - 1 to 0
            sGok = (bar_index - array.get(sCb, i)) >= grace
            sPrx = high  >= array.get(sBot, i) and array.get(sArm, i) == 1 and sGok  // armed proximal tap (after grace)
            sDst = (failOnWick ? high : close) > array.get(sTop, i)                   // failed: traded (Wick) or closed (Close) beyond distal edge
            if sDst or (sPrx and removeOnTouch)
                array.remove(sTop, i)
                array.remove(sBot, i)
                array.remove(sTm, i)
                array.remove(sCb, i)
                array.remove(sArm, i)
                array.remove(sTch, i)
            else if sPrx
                array.set(sTch, i, 1)

    // ---- ARM: a zone becomes mitigable only after price impulses away from it ----
    if not na(atrV) and atrV > 0
        if array.size(dTop) > 0
            for i = 0 to array.size(dTop) - 1
                if array.get(dArm, i) == 0 and high >= array.get(dTop, i) + impMult * atrV
                    array.set(dArm, i, 1)
        if array.size(sTop) > 0
            for i = 0 to array.size(sTop) - 1
                if array.get(sArm, i) == 0 and low <= array.get(sBot, i) - impMult * atrV
                    array.set(sArm, i, 1)

    // ---- BASE + DEPARTURE — base = bar[2] + quiet candles before it; bar[1] departs ----
    int   baseLen = 1
    float bHigh   = na
    float bLow    = na
    bool  depUp   = false
    bool  depDn   = false
    if not na(atrV) and atrV > 0
        if maxBase >= 2                          // guard: Pine for-loops run BACKWARD when to < from
            for k = 3 to maxBase + 1             // absorb consecutive quiet candles behind bar[2]
                if (high[k] - low[k]) <= baseFrac * atrV
                    baseLen := baseLen + 1
                else
                    break
        bHigh := high[2]
        bLow  := low[2]
        if baseLen >= 2                          // guard: without it, baseLen=1 made "for 3 to 2" run k=3,2 and always swallow bar[3]
            for k = 3 to 1 + baseLen             // base spans bar[2 .. 1+baseLen]
                bHigh := math.max(bHigh, high[k])
                bLow  := math.min(bLow,  low[k])
        bool baseQuiet = (high[2] - low[2]) <= baseAnchorATR * atrV  // anchor candle must itself be a quiet base, not a trend candle
        bool bigDep = (high[1] - low[1]) >= impMult * atrV
        depUp := bigDep and baseQuiet and close[1] > open[1] and high[1] > bHigh   // departs UP  -> demand
        depDn := bigDep and baseQuiet and close[1] < open[1] and low[1]  < bLow    // departs DOWN -> supply

    // ---- NEW DEMAND (base, then a strong UP departure) ----
    if depUp
        float zTop = bHigh                       // proximal: top of the base (price returns down to buy)
        float zBot = math.min(bLow, low[1])      // distal: extend down to the departure candle's low
        if baseMaxATR > 0 and (zTop - zBot) > baseMaxATR * atrV
            zBot := zTop - baseMaxATR * atrV     // cap thickness, keep proximal high
        int   zTm = time[1 + baseLen]            // left edge = oldest base candle
        bool  dup = array.size(dTm) > 0 and array.get(dTm, 0) == zTm
        bool  overlap = false
        if array.size(dTop) > 0
            for ov = 0 to array.size(dTop) - 1
                if zTop >= array.get(dBot, ov) and zBot <= array.get(dTop, ov)
                    overlap := true
                    break
        if not dup and not overlap and zTop > zBot
            array.unshift(dTop, zTop)
            array.unshift(dBot, zBot)
            array.unshift(dTm, zTm)
            array.unshift(dCb, bar_index)
            array.unshift(dArm, 0)
            array.unshift(dTch, 0)
            while array.size(dTop) > keepN
                array.pop(dTop)
                array.pop(dBot)
                array.pop(dTm)
                array.pop(dCb)
                array.pop(dArm)
                array.pop(dTch)

    // ---- NEW SUPPLY (base, then a strong DOWN departure) ----
    if depDn
        float zTop = math.max(bHigh, high[1])    // distal: extend up to the departure candle's high
        float zBot = bLow                        // proximal: bottom of the base (price returns up to sell)
        if baseMaxATR > 0 and (zTop - zBot) > baseMaxATR * atrV
            zTop := zBot + baseMaxATR * atrV     // cap thickness, keep proximal low
        int   zTm = time[1 + baseLen]            // left edge = oldest base candle
        bool  dup = array.size(sTm) > 0 and array.get(sTm, 0) == zTm
        bool  overlap = false
        if array.size(sTop) > 0
            for ov = 0 to array.size(sTop) - 1
                if zTop >= array.get(sBot, ov) and zBot <= array.get(sTop, ov)
                    overlap := true
                    break
        if not dup and not overlap and zTop > zBot
            array.unshift(sTop, zTop)
            array.unshift(sBot, zBot)
            array.unshift(sTm, zTm)
            array.unshift(sCb, bar_index)
            array.unshift(sArm, 0)
            array.unshift(sTch, 0)
            while array.size(sTop) > keepN
                array.pop(sTop)
                array.pop(sBot)
                array.pop(sTm)
                array.pop(sCb)
                array.pop(sArm)
                array.pop(sTch)

    // ---- Build output: every stored (still-valid) zone, newest first, demand then supply.
    //      Assembled ONLY on the last bar — the only bar it's rendered. Creating Zone
    //      objects on every historical bar across 4 engine calls (1 local + 3 security)
    //      overruns the object/memory limit (RE10139). ----
    array<Zone> out = array.new<Zone>()
    if barstate.islast
        if array.size(dTop) > 0
            for i = 0 to array.size(dTop) - 1
                array.push(out, Zone.new(array.get(dTop, i), array.get(dBot, i), array.get(dTm, i), 0, array.get(dTch, i)))
        if array.size(sTop) > 0
            for i = 0 to array.size(sTop) - 1
                array.push(out, Zone.new(array.get(sTop, i), array.get(sBot, i), array.get(sTm, i), 1, array.get(sTch, i)))
    out

// Chart-TF detection (local) + HTF detection. Each returns an array of every still-valid zone.
bool removeOnTouch = i_touchMode == "Remove"
bool failOnWick   = i_failMode == "Wick"
// Daily-and-higher detection TFs force Remove-on-touch (no lingering 'tested' zones).
f_touchRemove(string tf) =>
    removeOnTouch or (i_dailyTouchRemove and timeframe.in_seconds(tf) >= timeframe.in_seconds("D"))
array<Zone> localZones = sdDetect(i_sdImpATR, i_sdCount, i_sdMaxBase, i_sdBaseFrac, i_sdBaseAnchorATR, i_sdBaseMaxATR, i_sdGrace, f_touchRemove(timeframe.period), failOnWick)
array<Zone> aZones = request.security(syminfo.tickerid, biasTF,  sdDetect(i_sdImpATR, i_sdCount, i_sdMaxBase, i_sdBaseFrac, i_sdBaseAnchorATR, i_sdBaseMaxATR, i_sdGrace, f_touchRemove(biasTF), failOnWick), lookahead=barmerge.lookahead_off)
array<Zone> bZones = request.security(syminfo.tickerid, setupTF, sdDetect(i_sdImpATR, i_sdCount, i_sdMaxBase, i_sdBaseFrac, i_sdBaseAnchorATR, i_sdBaseMaxATR, i_sdGrace, f_touchRemove(setupTF), failOnWick), lookahead=barmerge.lookahead_off)
array<Zone> cZones = request.security(syminfo.tickerid, i_tfC, sdDetect(i_sdImpATR, i_sdCount, i_sdMaxBase, i_sdBaseFrac, i_sdBaseAnchorATR, i_sdBaseMaxATR, i_sdGrace, f_touchRemove(i_tfC), failOnWick), lookahead=barmerge.lookahead_off)

f_tfVisible(string tf) =>
    // strictly HIGHER than the chart TF — a detection TF equal to the chart TF
    // is left to the chart-TF engine (i_useChart) so zones aren't drawn twice.
    timeframe.in_seconds(tf) > timeframe.in_seconds(timeframe.period)

// ══════════════════════════════════════════════════════════════════
// ▸ GAP DETECTOR — chart TF + Daily only, unfilled only, no ATR filter
// ══════════════════════════════════════════════════════════════════
gapDetector() =>
    var float _t1 = na, var float _b1 = na, var int _tm1 = na, var int _k1 = na
    var float _t2 = na, var float _b2 = na, var int _tm2 = na, var int _k2 = na

    bool fill1 = not na(_t1) and ((_k1 == 0 and low <= _b1) or (_k1 == 1 and high >= _t1))
    bool fill2 = not na(_t2) and ((_k2 == 0 and low <= _b2) or (_k2 == 1 and high >= _t2))

    if fill1
        _t1 := _t2
        _b1 := _b2
        _tm1 := _tm2
        _k1 := _k2
        _t2 := na
        _b2 := na
        _tm2 := na
        _k2 := na
    if fill2 and not fill1
        _t2 := na
        _b2 := na
        _tm2 := na
        _k2 := na

    gapUp = not na(high[1]) and open > high[1]
    gapDn = not na(low[1])  and open < low[1]

    if gapUp or gapDn
        _t2 := _t1
        _b2 := _b1
        _tm2 := _tm1
        _k2 := _k1
        if gapUp
            _t1 := open
            _b1 := high[1]
            _k1 := 0
        else
            _t1 := low[1]
            _b1 := open
            _k1 := 1
        _tm1 := time

    [_t1, _b1, _tm1, _k1, _t2, _b2, _tm2, _k2]

[gCt1, gCb1, gCtm1, gCk1, gCt2, gCb2, gCtm2, gCk2] = gapDetector()
[gDt1, gDb1, gDtm1, gDk1, gDt2, gDb2, gDtm2, gDk2] = request.security(syminfo.tickerid, "D", gapDetector(), lookahead=barmerge.lookahead_off)

// ══════════════════════════════════════════════════════════════════
// ▸ ZONE + GAP RENDERING
// ══════════════════════════════════════════════════════════════════
var array<box>    overlayBoxes  = array.new<box>()
var array<int>    overlayKinds  = array.new<int>()
var array<string> overlayTFs    = array.new<string>()
var array<int>    overlayTiers  = array.new<int>()
var array<box>    gapBoxes      = array.new<box>()
var array<int>    gapBoxKinds   = array.new<int>()
var array<line>   rnLines       = array.new<line>()

f_drawRN(float top, float bot, int leftTm, int rightTm) =>
    step = i_rnStep > 0 ? i_rnStep : f_autoRN((top + bot) / 2.0)
    if step > 0
        float lvl   = math.ceil(bot / step) * step
        int   guard = 0
        while lvl <= top and guard < 12 and array.size(rnLines) < 450
            ln = line.new(x1=leftTm, y1=lvl, x2=rightTm, y2=lvl, xloc=xloc.bar_time,
                 color=color.new(C_RN, 0), width=1, style=line.style_dotted)
            array.push(rnLines, ln)
            lvl   := lvl + step
            guard := guard + 1

// Prettify a raw timeframe string for the on-chart box label (e.g. "240" -> "4H").
f_tfName(string tf) =>
    tf == "D" ? "D" : tf == "W" ? "W" : tf == "M" ? "M" : tf == "240" ? "4H" : tf == "120" ? "2H" : tf == "60" ? "1H" : tf == "30" ? "30m" : tf == "15" ? "15m" : tf == "5" ? "5m" : tf == "3" ? "3m" : tf == "1" ? "1m" : tf

f_pushZone(float top, float bot, int tm, int kind, string tfLabel, int tier, int tst) =>
    if not na(top) and not na(bot) and not na(tm) and top > bot
        // Proximity filter: skip zones whose proximal edge (demand top / supply bottom)
        // is further than i_zoneMaxDist x ATR from the last close. Negative = price inside.
        float prox  = kind == 0 ? close - top : bot - close
        bool  nearOK = i_zoneMaxDist <= 0 or na(sweepAtr) or prox <= i_zoneMaxDist * sweepAtr
        // Containment filter: skip a lower-tier zone swallowed by an already-drawn higher-tier
        // zone on the same side (HTF tiers render first), but ONLY when it is a near-duplicate
        // (covers >= 60% of the HTF zone's height). A thin LTF zone inside a fat HTF zone is a
        // precision entry level and still draws.
        bool swallowed = false
        if array.size(overlayBoxes) > 0
            for ci = 0 to array.size(overlayBoxes) - 1
                if array.get(overlayKinds, ci) == kind and array.get(overlayTiers, ci) > tier
                    cb = array.get(overlayBoxes, ci)
                    cbH = box.get_top(cb) - box.get_bottom(cb)
                    if top <= box.get_top(cb) and bot >= box.get_bottom(cb) and cbH > 0 and (top - bot) >= 0.6 * cbH
                        swallowed := true
                        break
        if nearOK and not swallowed
            col    = kind == 0 ? C_DEMAND : C_SUPPLY
            bool tested = tst == 1
            // tier: 3 = bias (HTF context), 2 = setup, 1 = extra HTF (Custom 1H), 0 = entry/chart.
            // Higher tiers draw outline-only (see price through them) and extend further right so
            // each TF's label sits in its own column; only the entry/chart tier gets a light fill.
            // Tested zones stay drawn but dimmed + dashed until a close through the distal edge.
            fillCol = tier >= 1 ? na : color.new(col, tested ? 92 : 82)
            bWidth  = tier == 3 ? 2 : tier == 0 ? 1 : 2
            rightN  = tier == 3 ? 25 : tier == 2 ? 18 : tier == 1 ? 12 : 8
            rightT  = time + (time - time[1]) * rightN
            bx = box.new(left=tm, top=top, right=rightT, bottom=bot,
                 xloc=xloc.bar_time,
                 bgcolor=fillCol,
                 border_color=color.new(col, tested ? 55 : 10),
                 border_width=bWidth,
                 border_style=tested ? line.style_dashed : line.style_solid,
                 text=tested ? tfLabel + " tested" : tfLabel,
                 text_color=color.new(col, tested ? 40 : 0),
                 text_size=size.tiny,
                 text_halign=text.align_right,
                 text_valign=text.align_top)
            array.push(overlayBoxes, bx)
            array.push(overlayKinds, kind)
            array.push(overlayTFs, tfLabel)
            array.push(overlayTiers, tier)
            if i_showRN and (kind == 1 or i_rnBoth) and not tested
                f_drawRN(top, bot, tm, rightT)

f_renderZones(array<Zone> zs, string tfLabel, int tier) =>
    if array.size(zs) > 0
        for i = 0 to array.size(zs) - 1
            z = array.get(zs, i)
            f_pushZone(z.top, z.bot, z.tm, z.kind, tfLabel, tier, z.tst)

f_pushGap(float top, float bot, int tm, int kind, string tfLabel) =>
    if not na(top) and not na(bot) and not na(tm)
        col = kind == 0 ? C_GAP_UP : C_GAP_DN
        arrow = kind == 0 ? "↑" : "↓"
        lbl = tfLabel + " Gap " + arrow
        rightT = time + (time - time[1]) * 6
        bx = box.new(left=tm, top=top, right=rightT, bottom=bot,
             xloc=xloc.bar_time,
             bgcolor=color.new(col, 80),
             border_color=color.new(col, 25),
             border_width=2,
             text=lbl,
             text_color=color.new(col, 0),
             text_size=size.tiny,
             text_halign=text.align_left,
             text_valign=text.align_top)
        array.push(gapBoxes, bx)
        array.push(gapBoxKinds, kind)

if barstate.islast
    while array.size(overlayBoxes) > 0
        box.delete(array.shift(overlayBoxes))
        array.shift(overlayKinds)
        array.shift(overlayTFs)
        array.shift(overlayTiers)
    while array.size(gapBoxes) > 0
        box.delete(array.shift(gapBoxes))
        array.shift(gapBoxKinds)
    while array.size(rnLines) > 0
        line.delete(array.shift(rnLines))

    if i_showSD
        // Highest tier first so f_pushZone's containment check can drop LTF zones
        // that are fully swallowed by an already-drawn HTF zone.
        if i_useTFA and f_tfVisible(biasTF)
            f_renderZones(aZones, f_tfName(biasTF), 3)
        if i_useTFB and f_tfVisible(setupTF)
            f_renderZones(bZones, f_tfName(setupTF), 2)
        if i_profile == "Custom" and i_useTFC and f_tfVisible(i_tfC)
            f_renderZones(cZones, f_tfName(i_tfC), 1)
        if i_useChart
            f_renderZones(localZones, f_tfName(timeframe.period), 0)

    if i_showGaps
        if i_gapChart
            f_pushGap(gCt1, gCb1, gCtm1, gCk1, timeframe.period)
            f_pushGap(gCt2, gCb2, gCtm2, gCk2, timeframe.period)
        if i_gapD
            f_pushGap(gDt1, gDb1, gDtm1, gDk1, "D")
            f_pushGap(gDt2, gDb2, gDtm2, gDk2, "D")

// ══════════════════════════════════════════════════════════════════
// ▸ DASHBOARD
// ══════════════════════════════════════════════════════════════════
dashPos() =>
    i_dashPos == "top_left"      ? position.top_left      :
     i_dashPos == "bottom_right" ? position.bottom_right  :
     i_dashPos == "bottom_left"  ? position.bottom_left   :
     i_dashPos == "middle_right" ? position.middle_right  :
     position.top_right

var table dash = table.new(dashPos(), 2, 8,
     bgcolor      = color.new(C_DASH_BG, 25),
     border_width = 1,
     border_color = color.new(C_DASH_BORD, 30),
     frame_color  = color.new(C_DASH_BORD, 10),
     frame_width  = 1)

if i_showDash and barstate.islast
    int demCount = 0
    int supCount = 0
    if array.size(overlayKinds) > 0
        for i = 0 to array.size(overlayKinds) - 1
            if array.get(overlayKinds, i) == 0
                demCount := demCount + 1
            else
                supCount := supCount + 1
    fvgCount = array.size(fvgs)
    rnCount  = array.size(rnLines)
    gpCount  = array.size(gapBoxes)

    table.cell(dash, 0, 0, "SMC · " + i_profile, text_color=color.new(C_TXT_PRI, 0), bgcolor=color.new(C_DASH_HEAD, 20), text_size=size.small)
    table.cell(dash, 1, 0, i_alignFilter ? "ALIGNED" : "ALL",
         text_color = i_alignFilter ? color.new(C_BULL, 0) : color.new(C_NEUTRAL, 0),
         bgcolor    = color.new(C_DASH_HEAD, 20), text_size=size.tiny)

    table.cell(dash, 0, 1, "Bias " + f_tfName(biasTF), text_color=color.new(C_TXT_SEC, 0), text_size=size.tiny)
    table.cell(dash, 1, 1, biasStr,     text_color=biasColor,                text_size=size.small)

    table.cell(dash, 0, 2, "Structure", text_color=color.new(C_TXT_SEC, 0), text_size=size.tiny)
    table.cell(dash, 1, 2, structStr,   text_color=biasColor,                text_size=size.small)

    table.cell(dash, 0, 3, "HTF Event", text_color=color.new(C_TXT_SEC, 0), text_size=size.tiny)
    table.cell(dash, 1, 3, htfEventStr, text_color=htfEventCol,             text_size=size.small)

    table.cell(dash, 0, 4, "LTF Event", text_color=color.new(C_TXT_SEC, 0), text_size=size.tiny)
    table.cell(dash, 1, 4, lastEvent,   text_color=lastEventCol,            text_size=size.small)

    table.cell(dash, 0, 5, "Sweep",     text_color=color.new(C_TXT_SEC, 0), text_size=size.tiny)
    table.cell(dash, 1, 5, lastSweep,   text_color=lastSweepCol,            text_size=size.small)

    table.cell(dash, 0, 6, "Zones",     text_color=color.new(C_TXT_SEC, 0), text_size=size.tiny)
    table.cell(dash, 1, 6, "Dem " + str.tostring(demCount) + " · Sup " + str.tostring(supCount) + " · FVG " + str.tostring(fvgCount),
         text_color=color.new(C_TXT_PRI, 0), text_size=size.tiny)

    table.cell(dash, 0, 7, "RN / Gaps", text_color=color.new(C_TXT_SEC, 0), text_size=size.tiny)
    table.cell(dash, 1, 7, "RN " + str.tostring(rnCount) + " · Gaps " + str.tostring(gpCount),
         text_color=color.new(C_TXT_PRI, 0), text_size=size.tiny)

// ══════════════════════════════════════════════════════════════════
// ▸ ALERTS
// ══════════════════════════════════════════════════════════════════
alertcondition(bullSweep,     "Bullish Liquidity Sweep", "Clean SSL sweep at confirmed support")
alertcondition(bearSweep,     "Bearish Liquidity Sweep", "Clean BSL sweep at confirmed resistance")
alertcondition(isCHoCHBull,   "Bullish CHoCH (LTF)",     "LTF Change of Character to bullish")
alertcondition(isCHoCHBear,   "Bearish CHoCH (LTF)",     "LTF Change of Character to bearish")
alertcondition(htfEvent == 1, "HTF BOS Bullish",         "HTF close broke prior swing high")
alertcondition(htfEvent == 2, "HTF BOS Bearish",         "HTF close broke prior swing low")
alertcondition(htfEvent == 3, "HTF CHoCH Bullish",       "HTF reversal — close above prior swing high in bearish bias")
alertcondition(htfEvent == 4, "HTF CHoCH Bearish",       "HTF reversal — close below prior swing low in bullish bias")
````
