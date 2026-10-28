# Ribbon Conviction System

- url: https://www.tradingview.com/script/S3zeKzoT-Ribbon-Conviction-System/
- type: indicator
- pine_id: PUB;438375333ca14e33b3424ad8615e8dc5
- version: 6.0

## Description

Ribbon Conviction System — Trend, Flow, Value and Adaptive Stop

Overview

This is a single decision-support system for intraday traders. It answers three questions on one chart: which way is the trend, how much conviction is behind the current move, and where a logical trailing stop sits. A moving-average ribbon defines direction, a conviction score from 0 to 100% grades every signal, and an adaptive volatility stop marks risk. The components are designed to work together as one filtered signal, not as a loose collection of separate indicators.

Why these components are combined

A moving-average crossover on its own fires constantly in sideways markets and gives no sense of whether a cross is meaningful. Each part added here exists to fix a specific weakness of the part before it, so the result is one filtered signal rather than several indicators stacked on a chart.

Ribbon (direction). Five Fibonacci-length averages — 8, 13, 21, 34, 55 — using a mix of Hull, EMA and Kaufman Adaptive Moving Average (KAMA). The KAMA anchors deliberately flatten in choppy conditions, so the ribbon stops giving direction when there is no trend. Weakness it leaves open: a crossover can still fire on a weak, low-conviction move.
Conviction score (filter). Instead of taking every crossover, each signal is graded 0–100% by blending four independent readings of the same bar, chosen because they measure different things rather than repeat each other:

Buy/sell flow — net buying versus selling pressure, inferred from lower-timeframe price-and-volume behaviour.
Effort vs move — how far price travelled for the volume spent; absorption and churn are penalised.
Trend quality — Kaufman Efficiency Ratio: directional travel divided by total path, separating trend from noise.
Price location — is price on the right side of value? Blends session VWAP slope, a swing-anchored VWAP, the session volume-profile value area (VAH/VAL/POC), and the prior session's VWAP and unfilled POC.

A flow-toxicity proxy (VPIN-style) then lowers the score when flow looks one-sided and unstable. Weakness it leaves open: all four readings come from the chart timeframe, so they can agree for the wrong reason.
Higher-timeframe agreement (independent confirmation). The same volatility-stop direction is computed on 3×, 5× and 15× the chart timeframe and folded in as a multiplier, not a fifth blended input. It is kept separate precisely because it is the one genuinely independent check on the chart-timeframe score: full agreement raises conviction, disagreement lowers it.
Adaptive volatility stop (risk). A Chande-style volatility stop whose ATR period and multiplier adapt through the Efficiency Ratio, so the stop tightens in clean trends and widens in chop. This turns the tool from "where is the signal" into "where is my risk if I take it."

How they work together

Direction (ribbon) decides the side. The conviction score decides whether a crossover on that side is worth showing and how strongly. Higher-timeframe agreement scales that conviction up or down. The adaptive stop shows the exit reference. Every signal is the product of all four stages working in sequence.
What it plots

The five-average ribbon with shaded bands; the 55 line is the bold trend-reference band.
Signal badges at qualifying crossovers, labelled with the band crossed and the conviction percent (for example "21 65%").
Optional value references: session VWAP, swing-anchored VWAP with bands, volume-profile VAH/VAL/POC, and the prior session's VWAP and POC.
The adaptive volatility stop as a step line with a live distance label.
A compact dashboard summarising trend, conviction and each component, higher-timeframe agreement, the stop, and the data mode.
A small higher-timeframe agreement ribbon.

How to use

Add it to an intraday chart. The defaults suit index futures, but direction works on any symbol.
Spot vs futures: many spot indices publish no real volume, which the flow, value-area and toxicity parts depend on. Under "Data source" the script auto-detects this and switches the volume-based parts to a time-at-price method so everything still works; you can also set the mode manually. The dashboard "Data" row shows which mode is active.
Trade in the ribbon's direction. Prefer signals with a higher conviction percent and higher-timeframe agreement, and treat low-conviction crosses as noise. Use "Hide signals weaker than" to suppress them.
Use the adaptive stop as a trailing-risk reference, sized to your own plan.
The "Look & size" group controls signal size, dashboard size and position, a "Minimal" preset (ribbon + signals + stop only), and band lightness.

Originality

The individual techniques — adaptive moving averages, the Efficiency Ratio, effort-versus-result, VWAP, volume profile and volatility stops — are publicly documented. What is original here is the integration: a single conviction score that fuses chart-timeframe flow, effort, efficiency and value, damps it by flow toxicity, and scales it by independent higher-timeframe agreement, then gates an adaptive-stop-aware signal on that score. The components were selected so each covers a distinct weakness, and redundant filters were deliberately left out to keep one clear signal.
Credits
Perry Kaufman — Adaptive Moving Average and Efficiency Ratio. Tushar Chande — Volatility Stop concept. The effort-versus-result component is an original, compact reimplementation inspired by the publicly described effort-versus-result method from the volume-spread-analysis lineage.

Disclaimer

This script is for education and information only. It is not financial, investment or trading advice and does not guarantee any outcome. Signals describe current conditions; they do not predict the future. Markets carry substantial risk of loss. Volume-based readings depend on the data feed and are unreliable on instruments without real volume. Always test on your own market and timeframe, and manage risk with your own stops and position sizing. The author is not a licensed financial advisor; consult a qualified professional before making financial decisions. You are solely responsible for your own trading decisions.

## Source Code

````pine
//@version=6
// ════════════════════════════════════════════════════════════════════════════
//
//   Ribbon Conviction System — Trend, Flow, Value and Adaptive Stop
//
// ════════════════════════════════════════════════════════════════════════════
//
//  OVERVIEW
//  ────────
//  This is a single decision-support system for intraday traders. It answers
//  three questions on one chart: (1) which way is the trend, (2) how much
//  conviction is behind the current move, and (3) where a logical trailing
//  stop sits. A moving-average ribbon defines direction. A conviction score
//  from 0 to 100 percent grades every signal. An adaptive volatility stop
//  marks risk. The pieces are designed to work together, not as a loose
//  collection of separate indicators.
//
//  WHY THESE COMPONENTS ARE COMBINED (mashup justification)
//  ────────────────────────────────────────────────────────
//  A moving-average crossover on its own fires constantly in sideways
//  markets and gives no sense of whether a cross is meaningful. Every part
//  added here exists to fix a specific weakness of the part before it, so
//  the result is one filtered signal rather than several indicators stacked
//  on a chart:
//
//   1. RIBBON (direction). Five Fibonacci-length averages (8, 13, 21, 34, 55)
//      using a mix of Hull, EMA and Kaufman Adaptive Moving Average (KAMA).
//      The KAMA anchors deliberately flatten in choppy conditions, so the
//      ribbon stops giving direction when there is no trend. Problem it
//      leaves open: a crossover can still fire on a weak, low-conviction move.
//
//   2. CONVICTION SCORE (filter). Instead of taking every crossover, each
//      signal is graded 0-100 percent by blending four independent readings
//      of the SAME bar, chosen because they measure different things and do
//      not simply repeat each other:
//        a. Buy/sell flow  - net buying vs selling pressure, inferred from
//                            lower-timeframe price-and-volume behaviour.
//        b. Effort vs move - how far price travelled for the volume spent
//                            (a compact reimplementation of the effort-versus-
//                            result idea; absorption / churn is penalised).
//        c. Trend quality  - Kaufman Efficiency Ratio: directional travel
//                            divided by total path, separating trend from noise.
//        d. Price location - is price on the right side of value? Blends
//                            session VWAP slope, a swing-anchored VWAP, the
//                            session volume-profile value area (VAH/VAL/POC),
//                            and the prior session's VWAP and unfilled POC.
//      A flow-toxicity proxy (VPIN-style) then lowers the score when flow
//      looks one-sided and unstable. Problem it leaves open: all four readings
//      come from the chart timeframe, so they can agree for the wrong reason.
//
//   3. HIGHER-TIMEFRAME AGREEMENT (independent confirmation). The same
//      volatility-stop direction is computed on 3x, 5x and 15x the chart
//      timeframe and folded in as a multiplier, not a fifth blended input.
//      It is kept separate precisely because it is the one genuinely
//      independent check on the chart-timeframe score: full agreement raises
//      conviction, disagreement lowers it.
//
//   4. ADAPTIVE VOLATILITY STOP (risk). A Chande-style volatility stop whose
//      ATR period and multiplier adapt through the Efficiency Ratio, so the
//      stop tightens in clean trends and widens in chop. This turns the tool
//      from "where is the signal" into "where is my risk if I take it".
//
//  HOW THEY WORK TOGETHER
//  ──────────────────────
//  Direction (ribbon) decides the side. The conviction score decides whether
//  a crossover on that side is worth showing and how strongly. Higher-
//  timeframe agreement scales that conviction up or down. The adaptive stop
//  shows the exit reference. One signal is the product of all four stages.
//
//  WHAT IT PLOTS
//  ─────────────
//   • The five-average ribbon with shaded bands; the 55 line is the bold
//     trend-reference band.
//   • Signal badges at qualifying crossovers, labelled with the band crossed
//     and the conviction percent (for example "21  65%").
//   • Optional value references: session VWAP, swing-anchored VWAP with bands,
//     volume-profile VAH/VAL/POC, and the prior session's VWAP and POC.
//   • The adaptive volatility stop as a step line with a live distance label.
//   • A compact dashboard summarising trend, conviction and each component,
//     higher-timeframe agreement, the stop, and the data mode.
//   • A small higher-timeframe agreement ribbon.
//
//  HOW TO USE
//  ──────────
//   1. Add to an intraday chart. Defaults suit liquid index futures.
//      Direction works on any symbol; the flow, value-area and toxicity
//      parts need real traded volume.
//   2. SPOT vs FUTURES: many spot indices publish no real volume. Under
//      "Data source" the script auto-detects this and switches the volume-
//      based parts to a time-at-price method so everything still works; you
//      can also force the mode. The dashboard "Data" row shows which is active.
//   3. Trade in the ribbon's direction. Prefer signals with higher conviction
//      percent and higher-timeframe agreement. Treat low-conviction crosses
//      as noise. Use "Hide signals weaker than" to suppress them.
//   4. Use the adaptive stop as a trailing-risk reference, sized to your plan.
//   5. Look & size group controls signal size, dashboard size/position, a
//      "Minimal" preset (ribbon + signals + stop only), and band lightness.
//
//  ORIGINALITY
//  ───────────
//  The individual techniques (adaptive moving averages, the Efficiency Ratio,
//  effort-versus-result, VWAP, volume profile, volatility stops) are publicly
//  documented. What is original here is the integration: a single conviction
//  score that fuses chart-timeframe flow, effort, efficiency and value, damps
//  it by flow toxicity, and scales it by independent higher-timeframe
//  agreement, then gates an adaptive-stop-aware signal on that score. The
//  components were selected so each covers a distinct weakness; redundant
//  filters were deliberately left out to keep one clear signal.
//
//  CREDITS
//  ───────
//   • Perry Kaufman — Adaptive Moving Average and Efficiency Ratio.
//   • Tushar Chande — Volatility Stop concept.
//   • The effort-versus-result component is an original, compact
//     reimplementation inspired by the publicly described "effort vs result"
//     method (volume-spread analysis lineage).
//
//  DISCLAIMER
//  ──────────
//  This script is for education and information only. It is not financial,
//  investment or trading advice and does not guarantee any outcome. Signals
//  describe current conditions; they do not predict the future. Markets carry
//  substantial risk of loss. Volume-based readings depend on the data feed and
//  are unreliable on instruments without real volume. Always test on your own
//  market and timeframe and manage risk with your own stops and position
//  sizing. The author is not a licensed financial advisor; consult a qualified
//  professional before making financial decisions. You are solely responsible
//  for your own trading decisions.
//
// ════════════════════════════════════════════════════════════════════════════
//  VISIBILITY: default transparencies below are set to the values you get when
//  the script is stacked on itself twice (translucent fills compound), so a
//  SINGLE instance now reads as boldly as a doubled one. Solid lines are
//  unaffected by stacking, so their widths are unchanged.
//  STABILITY: max_bars_back is declared so the history buffer for the three
//  request.security() volatility-stop calls is sized deterministically — this
//  removes the intermittent "cannot determine referencing length" buffer error.
// ════════════════════════════════════════════════════════════════════════════
indicator("Ribbon Conviction System", shorttitle="Ribbon Conviction", overlay=true, max_labels_count=500, max_bars_back=500)

// ─── Ribbon inputs ───────────────────────────────────────────────────────────
src = input.source(close, "Price source", tooltip="Series the ribbon and all price comparisons are built from. Default = close; choose any series (hl2, ohlc4, or another indicator's output) so the tool fits the asset/market you trade.")
g1  = "Ribbon Lengths"
len1 = input.int(8,  "HMA Length",       minval=1, group=g1)
len2 = input.int(13, "EMA Length",       minval=1, group=g1)
len3 = input.int(21, "KAMA Length #1",   minval=1, group=g1)
len4 = input.int(34, "KAMA Length #2",   minval=1, group=g1)
len5 = input.int(55, "KAMA Length (ref)",minval=1, group=g1)
kFast = input.int(2,  "KAMA Fast EMA", minval=1, group=g1)
kSlow = input.int(30, "KAMA Slow EMA", minval=1, group=g1)

// ─── Strength weights ──────────────────────────────────────────────────────────
g2 = "Signal strength — how much each part counts"
wFlow = input.float(0.30, "Buy/sell flow",       minval=0.0, maxval=1.0, step=0.05, group=g2)
wEv   = input.float(0.20, "Effort vs move",      minval=0.0, maxval=1.0, step=0.05, group=g2)
wEr   = input.float(0.15, "Trend quality",       minval=0.0, maxval=1.0, step=0.05, group=g2)
wLoc  = input.float(0.35, "Price location",      minval=0.0, maxval=1.0, step=0.05, group=g2)
strMin = input.float(0.0, "Hide signals weaker than (0 = show all)", minval=0.0, maxval=0.9, step=0.05, group=g2)
useVpin = input.bool(true, "Lower strength when flow looks toxic", group=g2)

g3 = "Effort vs move"
ltfRes  = input.timeframe("5S", "Sub-bar resolution", group=g3)
flowWin = input.int(50, "Flow z / VPIN window", minval=10, group=g3)
evLook  = input.int(20, "Effort/result lookback", minval=1, group=g3)

// ─── Location & Value inputs ───────────────────────────────────────────────────
g4 = "Location & Value (VWAP gradient · anchored VWAP · volume profile)"
wGrad   = input.float(0.30, "  sub-weight: VWAP gradient",  minval=0.0, maxval=1.0, step=0.05, group=g4)
wAvwap  = input.float(0.25, "  sub-weight: anchored VWAP",  minval=0.0, maxval=1.0, step=0.05, group=g4)
wVa     = input.float(0.25, "  sub-weight: value area",     minval=0.0, maxval=1.0, step=0.05, group=g4)
wPrior  = input.float(0.20, "  sub-weight: prior-session refs", minval=0.0, maxval=1.0, step=0.05, group=g4)
gradLen = input.int(5, "VWAP gradient lookback (bars)", minval=1, group=g4)
gradGain= input.float(8.0, "Slope gain (ATR-normalized)", minval=1.0, maxval=30.0, step=1.0, group=g4)
avPivLen= input.int(21, "Anchored-VWAP swing length", minval=3, group=g4)
vpBins  = input.int(24, "Volume profile bins", minval=10, maxval=50, group=g4)
vpRange = input.float(8.0, "Profile half-range (× ATR from session open)", minval=3.0, maxval=20.0, step=1.0, group=g4)
vaPct   = input.float(0.70, "Value-area fraction", minval=0.5, maxval=0.9, step=0.05, group=g4)

g5 = "Visuals"
colorByTrend = input.bool(true, "Color ribbon by alignment", group=g5)
showBands  = input.bool(true,  "Color ribbon bands", group=g5)
showVwap   = input.bool(true,  "Session VWAP (slope gradient)", group=g5)
showAvwap  = input.bool(true,  "Swing-anchored VWAP + σ", group=g5)
showVP     = input.bool(true,  "POC / VAH / VAL lines", group=g5)
showPrior  = input.bool(true,  "Prior-session VWAP / naked POC", group=g5)
showStop   = input.bool(true,  "Adaptive volatility stop + distance", group=g5)
showRibbon = input.bool(true,  "HTF agreement ribbon", group=g5)
showDash   = input.bool(true,  "Strength dashboard", group=g5)

g6 = "Risk — adaptive volatility stop"
stopFast = input.int(8,  "Fast ATR bound (trending)", minval=2, maxval=20, group=g6)
stopSlow = input.int(30, "Slow ATR bound (choppy)",   minval=10, maxval=100, group=g6)
stopMult = input.float(2.0, "Base ATR multiplier", minval=0.5, step=0.1, group=g6)

g7 = "MTF confirmation (independent higher-TF agreement)"
useMtf  = input.bool(true, "Fold 3×/5×/15× agreement into strength", group=g7)
mtfBonus= input.float(0.10, "Bonus when all agree", minval=0.0, maxval=0.3, step=0.05, group=g7)

g8 = "Signal filters"
flipPersist = input.bool(false, "Only signal if price clears the line by ½ ATR", group=g8)
flipATR     = input.float(0.5, "  clearance (× ATR)", minval=0.1, maxval=2.0, step=0.1, group=g8)
sessFilter  = input.bool(false, "Skip signals in first N bars after the open", group=g8)
sessBars    = input.int(3, "  bars to skip", minval=1, maxval=12, group=g8)

// ─── Crossover lines (which ribbon lines fire a signal AND get highlighted) ──────
gX = "Crossover lines — 8-HMA crosses these"
useX13 = input.bool(false, "Use 13 (EMA)",      group=gX)
useX21 = input.bool(false, "Use 21 (KAMA)",     group=gX)
useX34 = input.bool(false, "Use 34 (KAMA)",     group=gX)
useX55 = input.bool(true,  "Use 55 (KAMA ref)", group=gX, tooltip="Tick one or more lines. The 8-HMA crossing ANY ticked line fires a signal, and each ticked line is highlighted on the chart so you can see which crossover is live. Default = 55 only.")
hiliteX= input.bool(true,  "Highlight the selected line(s) on the chart", group=gX)

// ─── Data source: spot vs futures (works on any symbol) ──────────────────────────
g9 = "Data source — works on any symbol"
assetMode = input.string("Auto-detect", "Volume on this symbol",
     options=["Auto-detect", "Real volume (futures / stocks / crypto)", "No volume (spot index)"],
     tooltip="Some parts of the score use traded volume (buy/sell flow, value area, yesterday's POC, flow toxicity). A spot index has no real volume, so on Auto the indicator switches those parts to a time-at-price method and everything keeps working. Pick a setting manually only if Auto gets it wrong.", group=g9)
volSym    = input.symbol("", "Borrow volume / flow from another symbol",
     tooltip="Leave blank to use the chart symbol. To get REAL volume on a spot index, put the matching futures contract here (for example chart a cash index, borrow volume from its front-month index future). Price and the ribbon stay on your chart symbol; only the volume/flow inputs come from this symbol. Works for any market: index→futures, cash stock→its futures, etc.", group=g9)
anchorPer = input.string("Session", "Anchor for VWAP / profile / prior-day",
     options=["Session","Day","Week","Month"],
     tooltip="What resets the session VWAP, the volume profile and the 'yesterday' references. Use Session/Day for intraday stocks and futures, Day for 24-hour markets like crypto and forex, Week or Month for swing timeframes.", group=g9)

// ─── Look & size (clean chart) ───────────────────────────────────────────────────
gL = "Look & size"
preset     = input.string("Full", "Chart preset", options=["Full","Minimal (ribbon + signals only)"], tooltip="Minimal hides the VWAP, anchored VWAP, volume-profile and yesterday lines so only the ribbon, its bands, the crossover signals (with strength) and the trailing stop remain. The dashboard still shows everything.", group=gL)
sigSize    = input.string("Small", "Signal arrow size", options=["Tiny","Small","Normal","Large"], group=gL)
showSigLbl = input.bool(true, "Show strength % next to each signal", group=gL)
dashPos    = input.string("Top right", "Dashboard position", options=["Top right","Top left","Bottom right","Bottom left","Middle right"], group=gL)
dashSize   = input.string("Small", "Dashboard text size", options=["Tiny","Small","Normal"], group=gL)
dashTheme  = input.string("Auto (match chart)", "Table theme", options=["Auto (match chart)","Dark","Light"], group=gL, tooltip="Auto reads the chart background brightness and keeps the dashboard and HTF ribbon legible on any theme (light, dark or colored). Cells are fully opaque so the tables never wash out. Dark/Light force a scheme.")
dashCompact= input.bool(false, "Compact dashboard (hide breakdown rows)", group=gL)
ribbonPos  = input.string("Top left", "HTF ribbon position", options=["Top left","Top right","Bottom left","Bottom right"], group=gL)
bandTransp = input.int(74, "Ribbon band lightness (higher = lighter)", minval=60, maxval=95, group=gL, tooltip="Default 74 ≈ the look of loading the script twice. Raise toward 86–95 for the old lighter bands, lower toward 60 for even bolder.")

// helpers: option strings → constants
f_pos(s) => s=="Top right"?position.top_right : s=="Top left"?position.top_left : s=="Bottom right"?position.bottom_right : s=="Bottom left"?position.bottom_left : position.middle_right
dSz = dashSize=="Tiny"?size.tiny : dashSize=="Small"?size.small : size.normal
minimal = preset == "Minimal (ribbon + signals only)"

// ─── Helpers ──────────────────────────────────────────────────────────────────
kama(source, length, fastLen, slowLen) =>
    fa = 2.0 / (fastLen + 1)
    sa = 2.0 / (slowLen + 1)
    mom = math.abs(source - source[length])
    vol = nz(math.sum(math.abs(source - source[1]), length))
    e   = vol > 0 ? nz(mom) / vol : 0.0
    sc  = math.pow(e * (fa - sa) + sa, 2)
    var float k = na
    k := na(k[1]) ? source : k[1] + sc * (source - k[1])
    k

norm(_v, _avg) =>
    x = _avg != 0 ? _v / _avg : 0.0
    x > 1.50 ? 1.00 : x > 1.20 ? 0.90 : x > 1.00 ? 0.80 : x > 0.80 ? 0.70 : x > 0.60 ? 0.60 : x > 0.40 ? 0.50 : x > 0.20 ? 0.25 : 0.10

clamp01(x) => math.max(0.0, math.min(1.0, x))

// float-length RMA (for ATR with adaptive period)
f_rma(s, length) =>
    a = 1.0 / math.max(length, 1.0)
    var float r = na
    r := na(r[1]) ? s : r[1] + a * (s - r[1])
    r

// ER-adaptive Chande volatility stop (Kaufman-adapted ATR period + multiplier)
f_advstop(s, fLen, sLen, baseMult) =>
    erLen = 10
    net  = math.abs(s - s[erLen])
    path = math.sum(math.abs(s - s[1]), erLen)
    e    = path > 0 ? net / path : 0.0
    eSm  = ta.ema(e, 5)
    fa = 2.0 / (fLen + 1)
    sa = 2.0 / (sLen + 1)
    alpha = math.pow(eSm * (fa - sa) + sa, 2)
    lenMin = math.max(2, fLen - 2)
    lenMax = sLen + 10
    useLen = math.max(float(lenMin), math.min(float(lenMax), 1.0 / math.max(alpha, 1e-10)))
    mult = eSm >= 0.6 ? baseMult * 0.8 : eSm <= 0.3 ? baseMult * 1.3 : baseMult   // tighter in trend, wider in chop
    dist = mult * f_rma(ta.tr(true), useLen)
    var float vs = na
    var bool up = true
    if up
        vs := math.max(nz(vs, s - dist), s - dist)
    else
        vs := math.min(nz(vs, s + dist), s + dist)
    if up and s < vs
        up := false
        vs := s + dist
    else if not up and s > vs
        up := true
        vs := s - dist
    [vs, up, dist]

// timeframe-multiple string resolver (nearest standard TV timeframe)
f_tf(mins) =>
    m = mins
    m<=1.5?"1":m<=2.5?"2":m<=4?"3":m<=7.5?"5":m<=12.5?"10":m<=22.5?"15":m<=37.5?"30":m<=52.5?"45":m<=90?"60":m<=150?"120":m<=210?"180":m<=300?"240":m<=540?"360":m<=1080?"720":"D"

// value-area metrics from running bins (O(bins))
f_va(array<float> bins, float lowPx, float bSize, int n, float frac) =>
    float poc = na
    float vah = na
    float val = na
    if not na(lowPx) and bSize > 0
        float maxV = 0.0
        int pocI = 0
        float tot = 0.0
        for i = 0 to n - 1
            v = array.get(bins, i)
            tot += v
            if v > maxV
                maxV := v
                pocI := i
        if tot > 0
            poc := lowPx + (pocI + 0.5) * bSize
            target = tot * frac
            acc = array.get(bins, pocI)
            up = pocI, dn = pocI
            bool go = true
            while go and acc < target and (up < n - 1 or dn > 0)
                uv = up < n - 1 ? array.get(bins, up + 1) : -1.0
                dv = dn > 0 ? array.get(bins, dn - 1) : -1.0
                if uv < 0 and dv < 0
                    go := false
                else if uv >= dv
                    up += 1
                    acc += math.max(uv, 0)
                else
                    dn -= 1
                    acc += math.max(dv, 0)
            vah := lowPx + (up + 1) * bSize
            val := lowPx + dn * bSize
    [poc, vah, val]

atr = ta.atr(14)

// ─── Ribbon + direction ─────────────────────────────────────────────────────────
ma1 = ta.hma(src, len1)
ma2 = ta.ema(src, len2)
ma3 = kama(src, len3, kFast, kSlow)
ma4 = kama(src, len4, kFast, kSlow)
ma5 = kama(src, len5, kFast, kSlow)
bull = ma1 > ma2 and ma2 > ma3 and ma3 > ma4 and ma4 > ma5
bear = ma1 < ma2 and ma2 < ma3 and ma3 < ma4 and ma4 < ma5
dir  = ma1 > ma5 ? 1 : ma1 < ma5 ? -1 : 0
refUp = ma4 > ma5

erPeriod = 10
er = math.sum(math.abs(close - close[1]), erPeriod) > 0 ? math.min(1.0, math.abs(close - close[erPeriod]) / math.sum(math.abs(close - close[1]), erPeriod)) : 0.0
erComp = clamp01(er)

// ─── Resolve the volume / flow data symbol (blank = chart symbol) ────────────────
useAltSym = volSym != "" and volSym != syminfo.tickerid
volId     = useAltSym ? volSym : syminfo.tickerid
// effective volume series: borrowed symbol's volume, or the chart's own
vEff = useAltSym ? request.security(volId, timeframe.period, volume, lookahead=barmerge.lookahead_off) : volume

// ─── Is real volume usable? (checks the effective source, not just the chart) ────
var int volSeen = 0
var int volTot  = 0
if barstate.isconfirmed
    volTot  += 1
    volSeen += (not na(vEff) and vEff > 0) ? 1 : 0
volRate = volTot > 0 ? volSeen / float(volTot) : 0.0
isIdx   = (syminfo.type == "index" or syminfo.type == "economic") and not useAltSym
autoVol = volRate >= 0.80 and not isIdx
useVol  = assetMode == "Auto-detect" ? autoVol : assetMode == "Real volume (futures / stocks / crypto)" ? true : false

// ─── 1. FLOW (inferred order flow; price-only when no real volume) ───────────────
// sub-bars come from the volume symbol so a spot chart can borrow futures flow
[lc, lv] = request.security_lower_tf(volId, ltfRes, [close, volume])
n = array.size(lc)
float signed = 0.0
float tot    = 0.0
if n > 1
    for i = 1 to n - 1
        c0 = array.get(lc, i - 1)
        c1 = array.get(lc, i)
        w  = useVol ? nz(array.get(lv, i)) : 1.0   // weight by volume, or 1 per sub-bar
        s  = c1 > c0 ? 1.0 : c1 < c0 ? -1.0 : 0.0
        signed += s * w
        tot    += w
if tot == 0
    bs = close > close[1] ? 1.0 : close < close[1] ? -1.0 : 0.0
    w0 = useVol ? nz(vEff) : 1.0
    signed := bs * w0
    tot    := w0
ofi  = tot > 0 ? signed / tot : 0.0
ofiSd  = ta.stdev(ofi, flowWin)
ofiAvg = ta.sma(ofi, flowWin)
ofiZ = ofiSd > 0 ? (ofi - ofiAvg) / ofiSd : 0.0
vpin = ta.sma(tot > 0 ? math.abs(signed) / tot : 0.0, flowWin)
flowAgree = dir == 0 ? 0.0 : clamp01((dir * ofiZ) / 2.0)

// ─── 2. EFFORT vs RESULT (price travelled per unit of volume) ───────────────────
v = (na(vEff) or not useVol) ? 1.0 : vEff
nVol = norm(v, ta.sma(v, evLook)) * 100.0
barRange = high - low
ll2 = ta.lowest(2)
r2 = ta.highest(2) - ll2
srcShift = ta.change(close)
barClose  = barRange > 0 ? 2 * (close - low) / barRange * 100 - 100 : 0.0
s2r       = barRange > 0 ? (close - open) / barRange * 100 : 0.0
spreadN   = norm(math.abs(close - open), ta.sma(math.abs(close - open), evLook)) * 100 * math.sign(close - open)
barClose2 = r2 > 0 ? 2 * (close - ll2) / r2 * 100 - 100 : 0.0
shift2r   = r2 > 0 ? srcShift / r2 * 100 : 0.0
shiftN    = norm(math.abs(srcShift), ta.sma(math.abs(srcShift), evLook)) * 100 * math.sign(srcShift)
nPrice = math.max(-100.0, math.min(100.0, (barClose + s2r + spreadN + barClose2 + shift2r + shiftN) / 6.0))
nPriceAbs = math.abs(nPrice)
evRatio = nVol > 0 ? 100.0 * nPriceAbs / nVol : 0.0
isMega  = nPriceAbs >= 80 and nVol >= 80
isComp  = evRatio <= 50
isEoM   = evRatio >= 120 and not isMega
nSign   = nPrice > 0 ? 1 : nPrice < 0 ? -1 : 0
evQual  = isMega ? 1.0 : isEoM ? 0.9 : isComp ? 0.3 : 0.6
evComp  = (dir == 0 or nSign != dir) ? 0.0 : clamp01((nPriceAbs / 100.0) * evQual)
evState = isMega ? "MEGA" : isEoM ? "EoM" : isComp ? "COMPRESS" : "balance"

// ─── Anchor (resets VWAP / profile / prior-period refs) ─────────────────────────
// Session and Day both roll on the symbol's own daily boundary (respects the
// instrument's exchange and timezone automatically), so this works on any market.
anchorChg = anchorPer=="Week" ? ta.change(time("W"))!=0 : anchorPer=="Month" ? ta.change(time("M"))!=0 : ta.change(time("D"))!=0
// session VWAP anchored to the chosen period
vwap = ta.vwap(hlc3, anchorChg)
vwapSlope = (vwap - vwap[gradLen]) / gradLen
vwapGradN = atr > 0 ? vwapSlope / atr : 0.0
vwapGradComp = dir == 0 ? 0.0 : clamp01(dir * vwapGradN * gradGain)

// ─── 4b. ANCHORED VWAP (re-anchored at swing pivots) ────────────────────────────
ph = ta.pivothigh(avPivLen, avPivLen)
pl = ta.pivotlow(avPivLen, avPivLen)
newAnchor = (not na(ph)) or (not na(pl))
[avwap, avUp, avDn] = ta.vwap(hlc3, newAnchor, 1.0)
avValid = not na(avwap)
sideAgree = (not avValid or dir == 0) ? 0.0 : (dir * (close - avwap) > 0 ? 1.0 : 0.0)
avSlope = avValid ? (avwap - avwap[3]) : 0.0
avSlopeN = atr > 0 ? avSlope / atr : 0.0
slopeAgree = dir == 0 ? 0.0 : clamp01(dir * avSlopeN * gradGain)
avwapPosComp = 0.5 * sideAgree + 0.5 * slopeAgree

// ─── 4c. ANCHORED VOLUME PROFILE (session, incremental bins) ────────────────────
var array<float> vaBins = array.new<float>(vpBins, 0.0)
var float vpLow = na
var float vpBinSz = na
sessReset = anchorChg
if sessReset
    array.fill(vaBins, 0.0)
    vpLow := close - vpRange * atr
    vpBinSz := (2 * vpRange * atr) / vpBins
if not na(vpLow) and vpBinSz > 0
    topPx = vpLow + vpBinSz * vpBins
    if not (high < vpLow or low > topPx)
        fb = math.max(0, int((low - vpLow) / vpBinSz))
        lb = math.min(vpBins - 1, int((high - vpLow) / vpBinSz))
        span = lb - fb + 1
        vper = useVol ? nz(vEff) / math.max(1, span) : 1.0   // volume-at-price, or time-at-price (TPO)
        for b = fb to lb
            array.set(vaBins, b, array.get(vaBins, b) + vper)
[poc, vah, val] = f_va(vaBins, vpLow, vpBinSz, vpBins, vaPct)
aboveVAH = not na(vah) and close > vah
belowVAL = not na(val) and close < val
inVA     = not na(vah) and not na(val) and not aboveVAH and not belowVAL
vaComp = (na(vah) or na(val)) ? 0.4 : dir == 1 ? (aboveVAH ? 1.0 : inVA ? 0.4 : 0.0) : dir == -1 ? (belowVAL ? 1.0 : inVA ? 0.4 : 0.0) : 0.0
vaState = na(vah) ? "warmup" : aboveVAH ? "above VAH" : belowVAL ? "below VAL" : "in value"

// ─── 4d. PRIOR-SESSION CARRYOVER (yesterday's VWAP & naked POC) ──────────────────
// Captured at each session roll as fixed reference levels. Price tends to react
// where the prior auction left unfinished business. A naked POC = a prior POC
// price hasn't yet traded back through.
var float priorVwap = na
var float priorPoc  = na
var bool  priorPocNaked = false
if sessReset
    priorVwap := vwap[1]              // prior session's last VWAP
    priorPoc  := poc[1]               // prior session's last POC
    priorPocNaked := not na(poc[1])   // starts naked until tested
// naked POC is "tested" once price trades through it
if not na(priorPoc) and priorPocNaked and high >= priorPoc and low <= priorPoc
    priorPocNaked := false

// nearest prior reference above / below current price (obstacles / magnets)
float nearAbove = na
float nearBelow = na
if not na(priorVwap)
    nearAbove := priorVwap > close ? (na(nearAbove) ? priorVwap : math.min(nearAbove, priorVwap)) : nearAbove
    nearBelow := priorVwap < close ? (na(nearBelow) ? priorVwap : math.max(nearBelow, priorVwap)) : nearBelow
if not na(priorPoc)
    nearAbove := priorPoc > close ? (na(nearAbove) ? priorPoc : math.min(nearAbove, priorPoc)) : nearAbove
    nearBelow := priorPoc < close ? (na(nearBelow) ? priorPoc : math.max(nearBelow, priorPoc)) : nearBelow

// acceptance through a prior level in the signal direction = confirming
crossUpPrior = (not na(priorVwap) and close > priorVwap and close[1] <= priorVwap) or (not na(priorPoc) and close > priorPoc and close[1] <= priorPoc)
crossDnPrior = (not na(priorVwap) and close < priorVwap and close[1] >= priorVwap) or (not na(priorPoc) and close < priorPoc and close[1] >= priorPoc)
acceptPrior  = dir == 1 ? crossUpPrior : dir == -1 ? crossDnPrior : false
// obstacle in the way of the signal direction
obstacle = dir == 1 ? nearAbove : dir == -1 ? nearBelow : na
distObsATR = (not na(obstacle) and atr > 0) ? math.abs(obstacle - close) / atr : na
priorComp = acceptPrior ? 0.9 : (dir == 0 or na(obstacle)) ? 0.6 : distObsATR <= 0.3 ? 0.2 : distObsATR <= 1.0 ? 0.45 : 0.7
priorState = na(priorVwap) and na(priorPoc) ? "—" : acceptPrior ? "accepted" : (not na(distObsATR) and distObsATR <= 0.3) ? "at wall" : "clear"

// ─── Adaptive volatility stop (chart TF) ────────────────────────────────────────
[vStop, vStopUp, vStopDist] = f_advstop(close, stopFast, stopSlow, stopMult)

// ─── MTF independent confirmation (vol-stop direction on 3×/5×/15×) ──────────────
tfSec = timeframe.in_seconds()
tf3x  = f_tf(tfSec * 3  / 60)
tf5x  = f_tf(tfSec * 5  / 60)
tf15x = f_tf(tfSec * 15 / 60)
[_v3, up3x, _d3] = request.security(syminfo.tickerid, tf3x,  f_advstop(close, stopFast, stopSlow, stopMult), lookahead=barmerge.lookahead_off)
[_v5, up5x, _d5] = request.security(syminfo.tickerid, tf5x,  f_advstop(close, stopFast, stopSlow, stopMult), lookahead=barmerge.lookahead_off)
[_vF, up15x,_dF] = request.security(syminfo.tickerid, tf15x, f_advstop(close, stopFast, stopSlow, stopMult), lookahead=barmerge.lookahead_off)
mtfBullN = (up3x == true ? 1 : 0) + (up5x == true ? 1 : 0) + (up15x == true ? 1 : 0)
mtfAgree = dir == 0 ? 0 : dir == 1 ? mtfBullN : (3 - mtfBullN)   // HTFs agreeing with signal direction
// independent multiplier: full agreement boosts, contradiction damps
mtfMult = (not useMtf or dir == 0) ? 1.0 : mtfAgree == 3 ? (1.0 + mtfBonus) : mtfAgree == 2 ? 1.0 : mtfAgree == 1 ? 0.8 : 0.6

// ─── Location & Value composite ─────────────────────────────────────────────────
wLocSum = wGrad + wAvwap + wVa + wPrior
locComp = wLocSum > 0 ? (wGrad * vwapGradComp + wAvwap * avwapPosComp + wVa * vaComp + wPrior * priorComp) / wLocSum : 0.0

// ─── STRENGTH fusion ────────────────────────────────────────────────────────────
wSum = wFlow + wEv + wEr + wLoc
strengthRaw = wSum > 0 ? (wFlow * flowAgree + wEv * evComp + wEr * erComp + wLoc * locComp) / wSum : 0.0
vpinDamp = useVpin ? 1.0 - 0.4 * clamp01((vpin - 0.5) / 0.5) : 1.0
strength = clamp01(strengthRaw * vpinDamp * mtfMult)
strTier  = strength >= 0.66 ? "STRONG" : strength >= 0.33 ? "MOD" : "WEAK"

// ─── Plots: ribbon + bands ──────────────────────────────────────────────────────
gUp = #26a69a, gDn = #ef5350
trendCol = bull ? color.new(gUp,0) : bear ? color.new(gDn,0) : color.new(color.gray,0)
c1 = colorByTrend ? trendCol : color.new(#8e9aaf,0)
c2 = colorByTrend ? trendCol : color.new(#6b7a99,0)
c3 = colorByTrend ? trendCol : color.new(#f0a830,0)
c4 = colorByTrend ? trendCol : color.new(#e0683c,0)
p1 = plot(ma1, "HMA 8",   color=c1, linewidth=1)
p2 = plot(ma2, "EMA 13",  color=c2, linewidth=1)
p3 = plot(ma3, "KAMA 21", color=c3, linewidth=1)
p4 = plot(ma4, "KAMA 34", color=c4, linewidth=2)
p5 = plot(ma5, "KAMA 55 (ref)", color = refUp ? color.new(gUp,0) : color.new(gDn,0), linewidth=3)
b1 = ma1>ma2 ? color.new(gUp,bandTransp) : color.new(gDn,bandTransp)
b2 = ma2>ma3 ? color.new(gUp,bandTransp) : color.new(gDn,bandTransp)
b3 = ma3>ma4 ? color.new(gUp,int(math.min(95,bandTransp-3))) : color.new(gDn,int(math.min(95,bandTransp-3)))
bR = refUp    ? color.new(gUp,int(math.max(60,bandTransp-14))) : color.new(gDn,int(math.max(60,bandTransp-14)))
fill(p1,p2,color=showBands?b1:na)
fill(p2,p3,color=showBands?b2:na)
fill(p3,p4,color=showBands?b3:na)
fill(p4,p5,color=showBands?bR:na)

// highlight the user-selected crossover line(s): a bright cyan band over the line
// (the trend-coloured line shows through, so direction is preserved)
hC = #00E5FF
plot(hiliteX and useX13 ? ma2 : na, "✦ cross 13", color=color.new(hC, 50), linewidth=4, style=plot.style_line)
plot(hiliteX and useX21 ? ma3 : na, "✦ cross 21", color=color.new(hC, 50), linewidth=4, style=plot.style_line)
plot(hiliteX and useX34 ? ma4 : na, "✦ cross 34", color=color.new(hC, 50), linewidth=4, style=plot.style_line)
plot(hiliteX and useX55 ? ma5 : na, "✦ cross 55", color=color.new(hC, 50), linewidth=4, style=plot.style_line)

// ─── Plots: VWAP (slope gradient), AVWAP, value-area ──────────────────────────────
// gradient: green/red by slope sign, opacity scales with |slope| (steeper = bolder)
// 55 cap ≈ the doubled (stacked-twice) look so a single instance reads bold.
vwapTransp = int(math.max(0, math.min(55, 55 - math.abs(vwapGradN) * gradGain * 60)))
vwapCol = vwapSlope >= 0 ? color.new(gUp, vwapTransp) : color.new(gDn, vwapTransp)
plot(showVwap and not minimal ? vwap : na, "Session VWAP", color=vwapCol, linewidth=2)

avCol = avSlope >= 0 ? color.new(#7C4DFF, 0) : color.new(#D500F9, 0)
plot(showAvwap and avValid and not minimal ? avwap : na, "Anchored VWAP", color=avCol, linewidth=2)
ub = plot(showAvwap and avValid and not minimal ? avUp : na, "+σ", color=color.new(avCol, 64))
db = plot(showAvwap and avValid and not minimal ? avDn : na, "-σ", color=color.new(avCol, 64))
fill(ub, db, color = showAvwap and avValid and not minimal ? color.new(avCol, 88) : na)

plot(showVP and not minimal and not na(poc) ? poc : na, "POC", color=color.new(color.orange,0), linewidth=2, style=plot.style_linebr)
plot(showVP and not minimal and not na(vah) ? vah : na, "VAH", color=color.new(#2196f3,4), linewidth=1, style=plot.style_linebr)
plot(showVP and not minimal and not na(val) ? val : na, "VAL", color=color.new(#2196f3,4), linewidth=1, style=plot.style_linebr)

// prior-session reference levels (fixed per session). Naked POC brighter.
pPocCol = priorPocNaked ? color.new(#FFD600, 0) : color.new(#FFD600, 20)
plot(showPrior and not minimal and not na(priorVwap) ? priorVwap : na, "Prior VWAP", color=color.new(#9e9e9e,2), linewidth=1, style=plot.style_linebr)
plot(showPrior and not minimal and not na(priorPoc) ? priorPoc : na, "Prior POC (naked=bold)", color=pPocCol, linewidth=2, style=plot.style_linebr)

// adaptive volatility stop (trailing risk/exit line)
vStopCol = vStopUp ? color.new(#00e676, 0) : color.new(#ff1744, 0)
plot(showStop ? vStop : na, "Vol Stop", color=vStopCol, linewidth=2, style=plot.style_stepline)
if showStop and barstate.islast
    sd = math.abs(close - vStop)
    label.new(bar_index + 1, vStop, (vStopUp?"▲ stop ":"▼ stop ")+str.tostring(vStop, format.mintick)+"  ("+str.tostring(sd/close*100,"#.00")+"%)", xloc=xloc.bar_index, yloc=yloc.price, color=color.new(vStopUp?#00e676:#ff1744, 25), textcolor=color.white, style=label.style_label_left, size=size.tiny)

// ─── Signals: 8-HMA crossing a deeper ribbon line; small & color-coded by strength ─
xu13=ta.crossover(ma1,ma2), xu21=ta.crossover(ma1,ma3), xu34=ta.crossover(ma1,ma4), xu55=ta.crossover(ma1,ma5)
xd13=ta.crossunder(ma1,ma2), xd21=ta.crossunder(ma1,ma3), xd34=ta.crossunder(ma1,ma4), xd55=ta.crossunder(ma1,ma5)
// keep only crossovers on lines the user ticked (default = 55 only)
xu13e = useX13 and xu13, xu21e = useX21 and xu21, xu34e = useX34 and xu34, xu55e = useX55 and xu55
xd13e = useX13 and xd13, xd21e = useX21 and xd21, xd34e = useX34 and xd34, xd55e = useX55 and xd55
upLvl = xu55e?4:xu34e?3:xu21e?2:xu13e?1:0
dnLvl = xd55e?4:xd34e?3:xd21e?2:xd13e?1:0
clearedUp = not flipPersist or (upLvl==4 ? close>ma5+flipATR*atr : upLvl==3 ? close>ma4+flipATR*atr : upLvl==2 ? close>ma3+flipATR*atr : close>ma2+flipATR*atr)
clearedDn = not flipPersist or (dnLvl==4 ? close<ma5-flipATR*atr : dnLvl==3 ? close<ma4-flipATR*atr : dnLvl==2 ? close<ma3-flipATR*atr : close<ma2-flipATR*atr)
intraday = timeframe.in_seconds() < 86400
var int barsInSess = 9999
barsInSess := (intraday and timeframe.change("D")) ? 1 : barsInSess + 1
sessBlock = sessFilter and intraday and barsInSess <= sessBars
gate = strength >= strMin and not sessBlock
upLvlF = (gate and clearedUp) ? upLvl : 0
dnLvlF = (gate and clearedDn) ? dnLvl : 0
// Signals drawn as LABELS (these do NOT consume any of the 64 plot slots).
// A bright filled badge reads as a glowing arrow; strength % is built in.
sUp = #00e676
sDn = #ff1744
showUpSig = upLvlF >= 1
showDnSig = dnLvlF >= 1
lblSz = sigSize=="Tiny"?size.tiny : sigSize=="Small"?size.small : sigSize=="Normal"?size.normal : size.large
// brightness of the badge scales with strength (stronger = more solid = more "glow")
upBg = color.new(sUp, strength>=0.66?0:strength>=0.33?20:42)
dnBg = color.new(sDn, strength>=0.66?0:strength>=0.33?20:42)
band(int l) => l==4?"55":l==3?"34":l==2?"21":"13"
upTxt = showSigLbl ? "▲ "+band(upLvlF)+"  "+str.tostring(strength*100,"#")+"%" : "▲"
dnTxt = showSigLbl ? "▼ "+band(dnLvlF)+"  "+str.tostring(strength*100,"#")+"%" : "▼"
if showUpSig
    label.new(bar_index, low,  upTxt, style=label.style_label_up,   color=upBg, textcolor=color.white, size=lblSz, yloc=yloc.belowbar)
if showDnSig
    label.new(bar_index, high, dnTxt, style=label.style_label_down, color=dnBg, textcolor=color.white, size=lblSz, yloc=yloc.abovebar)

// ════════════════════════════════════════════════════════════════════════════
//  THEME-ADAPTIVE TABLE PALETTE (shared by the dashboard and the HTF ribbon)
//  "Auto" reads the chart background brightness (luma) and flips between a dark
//  and a light scheme so text always has contrast. Table cells are fully OPAQUE
//  so the panels never wash out against a light or colored background.
// ════════════════════════════════════════════════════════════════════════════
_uiBg   = chart.bg_color
_uiLuma = na(_uiBg) ? 0.0 : color.r(_uiBg) * 0.299 + color.g(_uiBg) * 0.587 + color.b(_uiBg) * 0.114
uiDark  = dashTheme == "Dark" ? true : dashTheme == "Light" ? false : (na(_uiBg) or _uiLuma < 140)

uiPanel = uiDark ? color.rgb(8, 12, 20)     : color.rgb(244, 246, 248)   // table background
uiFrame = uiDark ? color.rgb(42, 52, 88)    : color.rgb(196, 204, 212)   // frame / grid
// Accent text colors: bright on dark, deepened on light for contrast.
posUp = uiDark ? color.rgb(0, 230, 118)   : color.rgb(13, 140, 90)
posDn = uiDark ? color.rgb(255, 82, 82)   : color.rgb(205, 40, 55)
lblC  = uiDark ? color.rgb(238, 242, 248) : color.rgb(20, 26, 38)        // primary labels / values
dimC  = uiDark ? color.rgb(160, 170, 184) : color.rgb(92, 100, 112)      // neutral
hot   = uiDark ? color.rgb(255, 179, 0)   : color.rgb(176, 110, 0)       // amber
dataTxt = (useVol ? "real volume" : "no volume → time-based") + (useAltSym ? " (borrowed)" : "")
dataCol = useVol ? posUp : hot

// ─── Dashboard ──────────────────────────────────────────────────────────────────
if showDash and barstate.islast
    nRows = dashCompact ? 9 : 15
    var table t = table.new(f_pos(dashPos), 2, nRows, border_width=1, frame_width=1)
    table.set_bgcolor(t, uiPanel)
    table.set_frame_color(t, uiFrame)
    table.set_border_color(t, uiFrame)
    t.cell(0,0,"Trend", text_color=lblC, text_size=dSz), t.cell(1,0, refUp?"UP":"DOWN", text_color=refUp?posUp:posDn, text_size=dSz)
    t.cell(0,1,"Strength", text_color=lblC, text_size=dSz), t.cell(1,1,str.tostring(strength*100,"#")+"%  "+strTier, text_color=strength>=0.66?posUp:strength>=0.33?hot:dimC, text_size=dSz)
    t.cell(0,2,"Buy/sell flow", text_color=lblC, text_size=dSz), t.cell(1,2,str.tostring(flowAgree*100,"#")+"%", text_color=flowAgree>=0.5?posUp:lblC, text_size=dSz)
    t.cell(0,3,"Effort vs move", text_color=lblC, text_size=dSz), t.cell(1,3,str.tostring(evComp*100,"#")+"%  "+evState, text_color=isComp?hot:lblC, text_size=dSz)
    t.cell(0,4,"Trend quality", text_color=lblC, text_size=dSz), t.cell(1,4,str.tostring(erComp*100,"#")+"%", text_color=er>=0.6?posUp:er<=0.3?hot:lblC, text_size=dSz)
    t.cell(0,5,"Price location", text_color=lblC, text_size=dSz), t.cell(1,5,str.tostring(locComp*100,"#")+"%", text_color=locComp>=0.6?posUp:locComp>=0.33?hot:dimC, text_size=dSz)
    if not dashCompact
        t.cell(0,6,"  VWAP slope", text_color=dimC, text_size=dSz), t.cell(1,6,(vwapSlope>=0?"▲ ":"▼ ")+str.tostring(vwapGradComp*100,"#")+"%", text_color=vwapSlope>=0?posUp:posDn, text_size=dSz)
        t.cell(0,7,"  Swing VWAP", text_color=dimC, text_size=dSz), t.cell(1,7,(avValid?(close>avwap?"above ":"below "):"— ")+str.tostring(avwapPosComp*100,"#")+"%", text_color=avValid?(close>avwap?posUp:posDn):dimC, text_size=dSz)
        t.cell(0,8,"  Value area", text_color=dimC, text_size=dSz), t.cell(1,8,vaState+" "+str.tostring(vaComp*100,"#")+"%", text_color=aboveVAH?posUp:belowVAL?posDn:dimC, text_size=dSz)
        t.cell(0,9,"  Yesterday", text_color=dimC, text_size=dSz), t.cell(1,9,priorState+(priorPocNaked?" · POC open":""), text_color=priorState=="accepted"?posUp:priorState=="at wall"?hot:dimC, text_size=dSz)
    rMtf  = dashCompact ? 6  : 10
    rStop = dashCompact ? 7  : 11
    rData = dashCompact ? 8  : 12
    mtfTxt = dir==0 ? "—" : str.tostring(mtfAgree,"#")+"/3  ×"+str.tostring(mtfMult,"#.00")
    t.cell(0,rMtf,"Higher TFs", text_color=lblC, text_size=dSz), t.cell(1,rMtf, mtfTxt, text_color=mtfAgree==3?posUp:(mtfAgree==0 and dir!=0)?posDn:lblC, text_size=dSz)
    t.cell(0,rStop,"Trailing stop", text_color=lblC, text_size=dSz), t.cell(1,rStop,(vStopUp?"▲ ":"▼ ")+str.tostring(vStop,format.mintick)+"  "+str.tostring(vStopDist/close*100,"#.00")+"%", text_color=vStopUp?posUp:posDn, text_size=dSz)
    t.cell(0,rData,"Data", text_color=lblC, text_size=dSz), t.cell(1,rData, dataTxt, text_color=dataCol, text_size=dSz)
    if not dashCompact
        t.cell(0,13,"Flow toxicity", text_color=lblC, text_size=dSz), t.cell(1,13,str.tostring(vpin,"#.00"), text_color=vpin>0.6?posDn:lblC, text_size=dSz)
        t.cell(0,14,"Tick detail", text_color=lblC, text_size=dSz), t.cell(1,14,str.tostring(n,"#")+(n<10?" thin":""), text_color=n<10?hot:lblC, text_size=dSz)

// ─── HTF agreement ribbon (compact, opposite the dashboard) ──────────────────────
if showRibbon and barstate.islast
    var table rb = table.new(f_pos(ribbonPos), 4, 1, border_width=1, frame_width=1)
    table.set_bgcolor(rb, uiPanel)
    table.set_frame_color(rb, uiFrame)
    table.set_border_color(rb, uiFrame)
    rbU = color.new(posUp, 0)
    rbD = color.new(posDn, 0)
    rbN = color.new(dimC, 0)
    rb.cell(0,0, (dir==1?"▲":dir==-1?"▼":"~")+" chart", text_color=color.white, text_size=size.tiny, bgcolor=dir==1?rbU:dir==-1?rbD:rbN, text_halign=text.align_center)
    rb.cell(1,0, (up3x==true?"▲":"▼")+" 3×",  text_color=color.white, text_size=size.tiny, bgcolor=up3x==true?rbU:rbD, text_halign=text.align_center)
    rb.cell(2,0, (up5x==true?"▲":"▼")+" 5×",  text_color=color.white, text_size=size.tiny, bgcolor=up5x==true?rbU:rbD, text_halign=text.align_center)
    rb.cell(3,0, (up15x==true?"▲":"▼")+" 15×", text_color=color.white, text_size=size.tiny, bgcolor=up15x==true?rbU:rbD, text_halign=text.align_center)

// ─── Alerts ────────────────────────────────────────────────────────────────────
alertcondition(gate and xu55, "Cross 55 up",   "8 crossed 55 ref up — strength-backed")
alertcondition(gate and xd55, "Cross 55 down", "8 crossed 55 ref down — strength-backed")
alertcondition(aboveVAH and not aboveVAH[1], "Accept above VAH", "Price accepted above value area high")
alertcondition(belowVAL and not belowVAL[1], "Accept below VAL", "Price accepted below value area low")
alertcondition(not na(priorPoc) and priorPocNaked[1] and not priorPocNaked, "Naked POC tested", "Price reached the prior-session naked POC")
alertcondition(crossUpPrior, "Cleared prior level up", "Price closed above a prior-session VWAP/POC")
alertcondition(crossDnPrior, "Cleared prior level down", "Price closed below a prior-session VWAP/POC")
alertcondition(vStopUp and not vStopUp[1], "Vol stop flip up", "Adaptive volatility stop flipped long")
alertcondition(not vStopUp and vStopUp[1], "Vol stop flip down", "Adaptive volatility stop flipped short")
alertcondition(dir!=0 and mtfAgree==3, "All HTF agree", "Chart + 3×/5×/15× all aligned with signal direction")
alertcondition(showUpSig, "Signal up (selected line)",   "8-HMA crossed a selected line up — strength-backed")
alertcondition(showDnSig, "Signal down (selected line)", "8-HMA crossed a selected line down — strength-backed")
````
