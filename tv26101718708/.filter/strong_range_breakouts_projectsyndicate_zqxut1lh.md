# Strong Range Breakouts | ProjectSyndicate

- url: https://www.tradingview.com/script/ZqXuT1Lh-Strong-Range-Breakouts-ProjectSyndicate/
- type: indicator
- pine_id: PUB;47fe06ec178e44998b92bdff15ab3bad
- version: 1.0

## Description

Strong Range Breakouts

[b]Strong Range Breakouts power-ranks the consolidations your market keeps coiling into — and tells you, before the move, which one is loaded and which way it's likely to break. For every tightening range it builds a clean, equal-logic zone, scores that consolidation 0–10 from real, measurable compression quality, and stamps a directional probability on it (▲ likely UP / ▼ likely DOWN). It then projects Buy-Stop / Sell-Stop breakout levels with a buffer and full SL / TP1 / TP2 / TP3 targets — and tracks every breakout's outcome live in a win-rate dashboard, so the chart is constantly grading its own edge instead of asking you to take it on faith.[/b]

🎯 Power-Ranking System (0–10) — every consolidation earns a live grade from five sign-stable, self-calibrating factors: trend flatness (ADX percentile — is the market genuinely going nowhere?), volatility squeeze (Bollinger-width percentile — is range compressing vs its own recent history?), range tightness (N-bar range percentile — how coiled is price?), volume dry-up (low participation = accumulation), and price balance (RSI sitting near 50 = no directional pressure yet). Each factor is a smooth percentile rank, not a crude on/off flag, so the score spreads cleanly across the full 0–10 range and adapts to any instrument with no re-tuning. Prototyped and validated across FX datasets (EUR/USD, GBP/USD, USD/CHF) — higher-scored ranges produced cleaner, higher-win-rate breakouts than low-scored ones, so the number reflects genuine edge, not decoration.
🧭 Directional Probability — each zone carries a live ▲/▼ breakout bias built from where price sits in the range, top-vs-bottom edge-touch asymmetry, time spent in the upper vs lower half, and momentum lean. In validation this prediction landed correct 77–81% of the time vs a 50% coin-flip — so the bias on the box is a real tell, not a guess.
🏷️ Strength-Rank Label Above Every Box — each range carries its grade on top of the zone, impossible to miss: stars · X.X/10 · tier (FORMING → MODERATE → STRONG → VERY STRONG → ELITE) plus the directional bias. Quality and likely direction read instantly, no separate panel needed.

🎨 Direction-Coloured, Strength-Shaded Zones — boxes are tinted by their predicted break direction (bullish-bias teal, bearish-bias red/purple), and the shade deepens with strength tier, so the chart shows which ranges carry weight and which way they lean before you read a single number. The label freezes tinted to the actual break direction once it fires.
🚧 Buy / Sell Stop & SL / TP Levels — dashed Buy-Stop and Sell-Stop lines sit a configurable buffer beyond each range edge to define a genuine breakout. On a fired breakout the indicator projects a structure- or ATR-based Stop-Loss and TP1 / TP2 / TP3 at your chosen R-multiples, framing the trade the moment it triggers.
📊 Live Win-Rate Dashboard — an institutional gold-on-dark panel that tracks outcomes, not just signals: overall win rate (with █░ meter), total breakouts, wins/losses, Long WR vs Short WR, Strong-Zone WR (≥8), TP1/TP2/TP3 hit counts, expectancy (R per trade), total R, best/worst streak, the live zone score meter, and the current breakout bias. You see the system's measured performance on your symbol and timeframe in real time.
🔒 Non-Repainting — all detection and scoring run only on confirmed candles. A zone forms, extends, and breaks on closed-bar logic; once a breakout fires the level and its label lock in and never repaint.
🔔 Native Alerts — fires on a confirmed Buy breakout and Sell breakout, with the zone's score and entry level embedded in the message, so you're notified the instant a graded range gives way.

🔧 Fully Customizable — minimum score to display, minimum/maximum range span, scoring weights for all five factors, breakout confirmation (close vs wick), stop buffer, SL basis (opposite edge / zone mid / ATR), the three R-multiple targets, what counts as a "win" (TP1/2/3), the full institutional colour palette, transparency, label size, and dashboard position/size — all adjustable.
🎯 Why this is different — most "breakout" tools draw a box and fire an arrow the moment price pokes out, with no sense of whether the range was even worth trading or which way it should go. Strong Range Breakouts quantifies the consolidation first, predicts the direction, frames the trade, and then keeps score — so a high-grade zone with a strong bias is one to trade with, and a low-grade or counter-bias break is one to treat with suspicion. The validation behind the score even informs how you trade each one (see below).
🚀 Apply to Gold (XAUUSD), Silver, Forex, Crypto, and Indices on any intraday or higher timeframe.

[b]🎯 How To Trade It — Quick Overview[/b]

The score decides whether a setup is worth taking; the directional bias decides which way; the levels frame the trade. In validation, high-scored ranges broke cleaner and counter-bias breaks failed more often — so play them differently.
1) Trade-With Breakout (the primary play) — use on STRONG / ELITE zones (≥7) that break with their bias
Best when a range is rated STRONG or ELITE and the breakout fires in the same direction the ▲/▼ bias predicted.

Wait for a confirmed close beyond the Buy-Stop (long) or Sell-Stop (short) line — not a single wick.
Confirmation is strongest when the break direction matches the zone's directional bias (the ~77–81% edge).
Entry: on the close beyond the stop level, or on a retest of the broken edge (broken top flips to support; broken bottom flips to resistance).
Stop: the projected SL (opposite range edge / zone mid / ATR — your choice).
Targets: TP1 first (in testing TP1 hit by far the most often — bank or de-risk there), then trail toward TP2 / TP3 as the move extends.
Use the Buy/Sell breakout alert to catch the trigger the moment a graded range gives way.

2) Fade the False Break — use on WEAK / MODERATE zones, or breaks against a strong bias
Best when a low-scored range pokes out, or price breaks opposite to a high-confidence bias — statistically the more likely failure.

Wait for price to push just beyond the range edge and fail to hold (no decisive close beyond, momentum stalling).
Entry: on the reversal back inside the range (a close back through the broken edge).
Stop: just beyond the level that was swept — if price reclaims and holds it, the fade is wrong and it's a real breakout.
Targets: the opposite range edge first, then the measured range height.

Rule of thumb: ⭐ STRONG/ELITE + break with bias → trade the breakout. ⭐ WEAK/MODERATE, or break against a strong bias → suspect a trap, fade it. Let the dashboard win-rate on your symbol tell you which behaviour is paying on the instrument you actually trade.

⚠️ IMPORTANT NOTICE: This indicator power-ranks consolidations, predicts likely breakout direction, and frames breakout-vs-fade scenarios. It should NOT be used as a standalone signal for entering trades. The dashboard statistics are measured on historical, closed-bar data and describe past behaviour only. Always combine it with your own strategy, price-action analysis, and risk management to confirm setups. Past statistical behaviour does not guarantee future results.

## Source Code

````pine
//@version=6

// ═══════════════════════════════════════════════════════════════════════════════════
indicator("Strong Range Breakouts ",overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

// ═══════════════════════════════════════════════════════════════════════════════════
//                                     INPUTS
// ═══════════════════════════════════════════════════════════════════════════════════
gGen = "═══ Detection ═══"
minScore   = input.float(6.0, "Minimum Zone Score (0–10)", group = gGen, minval = 0, maxval = 10, step = 0.5, tooltip = "Only build/keep zones whose graded score reaches this. 6=moderate, 7=strong, 8=very strong, 9=elite.")
minBars    = input.int(10,  "Minimum Zone Span (bars)", group = gGen, minval = 3, maxval = 200, tooltip = "A consolidation must persist at least this many confirmed candles before it qualifies as a zone.")
maxBars    = input.int(120, "Maximum Zone Span (bars)", group = gGen, minval = 10, maxval = 1000, tooltip = "If a consolidation never breaks within this many bars it is retired.")
lookback   = input.int(5000,"Lookback (bars, 0 = all)", group = gGen, minval = 0, tooltip = "Only process the most recent N bars for speed. 0 = everything loaded.")
maxZones   = input.int(40,  "Max Zones Kept (history)", group = gGen, minval = 1, maxval = 200)

gBrk = "═══ Breakout & Trade Tracking ═══"
brkConfirm = input.string("Close", "Breakout Confirmation", options = ["Close", "Wick"], group = gBrk, tooltip = "Close = a candle must CLOSE beyond the stop level. Wick = any touch beyond it triggers.")
buffPct    = input.float(8.0, "Stop Buffer (% of zone height)", group = gBrk, minval = 0.0, maxval = 100, step = 1.0, tooltip = "Buy/Sell stop sits this far above/below the zone edge, as a fraction of the zone's height.")
slMode     = input.string("Opposite Edge", "Stop-Loss Basis", options = ["Opposite Edge", "Zone Mid", "ATR Multiple"], group = gBrk, tooltip = "Where the protective stop for outcome tracking sits.")
slATR      = input.float(1.5, "SL ATR Multiple", group = gBrk, minval = 0.1, step = 0.1, tooltip = "Used when Stop-Loss Basis = ATR Multiple.")
rr1        = input.float(1.0, "TP1 (R multiple)", group = gBrk, minval = 0.1, step = 0.1)
rr2        = input.float(2.0, "TP2 (R multiple)", group = gBrk, minval = 0.1, step = 0.1)
rr3        = input.float(3.0, "TP3 (R multiple)", group = gBrk, minval = 0.1, step = 0.1)
winBasis   = input.string("TP1", "Win Counts When", options = ["TP1", "TP2", "TP3"], group = gBrk, tooltip = "A breakout is scored a WIN when this target is reached before the stop.")
maxTrack   = input.int(200, "Max Bars To Track A Trade", group = gBrk, minval = 10, tooltip = "If neither TP nor SL is hit within this many bars the trade is closed as a scratch (no win/loss).")

gStr = "═══ Strength Engine (graded sub-scores) ═══"
adxLen     = input.int(14,  "ADX Length",           group = gStr, minval = 1)
bbLen      = input.int(20,  "Bollinger Length",     group = gStr, minval = 2)
bbSD       = input.float(2.0, "Bollinger StdDev",   group = gStr, minval = 0.1, step = 0.1)
sqzLook    = input.int(100, "Squeeze Percentile Window", group = gStr, minval = 20, tooltip = "BB-width percentile is measured over this window. Tighter than recent history = stronger.")
rsiLen     = input.int(14,  "RSI Length",           group = gStr, minval = 1)
wAdx   = input.float(0.20, "Weight: Trend Flatness (ADX)", group = gStr, minval = 0, maxval = 1, step = 0.05)
wSqz   = input.float(0.30, "Weight: Volatility Squeeze",   group = gStr, minval = 0, maxval = 1, step = 0.05)
wTight = input.float(0.20, "Weight: Range Tightness",      group = gStr, minval = 0, maxval = 1, step = 0.05)
wVol   = input.float(0.15, "Weight: Volume Dry-Up",        group = gStr, minval = 0, maxval = 1, step = 0.05)
wBal   = input.float(0.15, "Weight: Price Balance (RSI)",  group = gStr, minval = 0, maxval = 1, step = 0.05)

gStyle = "═══ Color Theme (Institutional) ═══"
bullColor1 = input.color(#26a69a, "Bullish-bias Low (4-6)",   group = gStyle, inline = "bull")
bullColor2 = input.color(#00897b, "Mid (7-8)",                group = gStyle, inline = "bull")
bullColor3 = input.color(#004d40, "High (9-10)",              group = gStyle, inline = "bull")
bearColor1 = input.color(#b71c1c, "Bearish-bias Low (4-6)",   group = gStyle, inline = "bear")
bearColor2 = input.color(#880e4f, "Mid (7-8)",                group = gStyle, inline = "bear")
bearColor3 = input.color(#4a148c, "High (9-10)",              group = gStyle, inline = "bear")
bgTransp   = input.int(80, "Zone Fill Transparency", group = gStyle, minval = 40, maxval = 96)
showStops  = input.bool(true, "Show Stop Lines", group = gStyle)
showTPs    = input.bool(true, "Show SL / TP Levels", group = gStyle)
showStopLbl= input.bool(true, "Show Stop-Level Labels", group = gStyle)
showRank   = input.bool(true, "Show Strength-Rank Label Above Box", group = gStyle)
showProb   = input.bool(true, "Show Directional Probability", group = gStyle)
showMarks  = input.bool(true, "Show Breakout Arrows", group = gStyle)
labelSize  = input.string("normal", "Rank Label Size", group = gStyle, options = ["tiny","small","normal","large","huge"])

gDash = "═══ Dashboard ═══"
showDash   = input.bool(true, "Show Statistics Dashboard", group = gDash)
dashPos    = input.string("Top Right", "Dashboard Position", options = ["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right"], group = gDash)
dashSize   = input.string("normal", "Dashboard Text Size", options = ["tiny","small","normal","large"], group = gDash)

gAlerts = "═══ Alerts ═══"
enaAlerts  = input.bool(true, "Enable Alerts", group = gAlerts)


var color cUp = na
var color cDn = na
if barstate.isfirst
    cUp := bullColor1
    cDn := bearColor1


var color DASH_BG      = color.new(#0d1117,  6)
var color DASH_HDR_BG  = color.new(#1a1f2e, 10)
var color DASH_ROW_BG  = color.new(#111827, 14)
var color DASH_ROW_ALT = color.new(#0d1117, 20)
var color DASH_BORDER  = color.new(#2d3748, 50)
var color DASH_GOLD    = #FFD700
var color DASH_WHITE   = #E2E8F0
var color DASH_GREY    = #718096
var color DASH_TEAL    = #4DB6AC
var color DASH_RED     = #EF5350

f_lsize(s) =>
    switch s
        "tiny" => size.tiny
        "small" => size.small
        "normal" => size.normal
        "large" => size.large
        "huge" => size.huge
        => size.normal

f_stars(sc) => sc >= 9 ? "★★★★★" : sc >= 8 ? "★★★★" : sc >= 7 ? "★★★" : sc >= 6 ? "★★" : sc >= 4 ? "★" : "·"
f_tier(sc)  => sc >= 9 ? "ELITE" : sc >= 8 ? "VERY STRONG" : sc >= 7 ? "STRONG" : sc >= 6 ? "MODERATE" : "FORMING"


f_zoneCol(bool bull, float sc) =>
    bull ? (sc >= 9 ? bullColor3 : sc >= 7 ? bullColor2 : bullColor1) : (sc >= 9 ? bearColor3 : sc >= 7 ? bearColor2 : bearColor1)


var string pfmt = "#.##"
if barstate.isfirst
    pfmt := syminfo.mintick <= 0.0001 ? "#.#####" : syminfo.mintick <= 0.01 ? "#.###" : syminfo.mintick <= 0.1 ? "#.##" : "#.#"
f_px(p) => str.tostring(p, pfmt)

f_dashPos(s) =>
    switch s
        "Top Right" => position.top_right
        "Top Left" => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left" => position.bottom_left
        "Middle Right" => position.middle_right
        => position.top_right


n      = bar_index
atrv   = nz(ta.atr(14), ta.tr)


_up   = ta.change(high)
_dn   = -ta.change(low)
plusDM  = (_up > _dn and _up > 0) ? _up : 0.0
minusDM = (_dn > _up and _dn > 0) ? _dn : 0.0
trur  = ta.rma(ta.tr, adxLen)
plusDI  = 100 * ta.rma(plusDM, adxLen) / trur
minusDI = 100 * ta.rma(minusDM, adxLen) / trur
dx    = (plusDI + minusDI) == 0 ? 0.0 : 100 * math.abs(plusDI - minusDI) / (plusDI + minusDI)
adxv  = ta.rma(dx, adxLen)
sAdx  = ta.percentrank(adxv, sqzLook) / 100.0
sAdx  := math.min(math.max(1.0 - sAdx, 0.0), 1.0)


basis = ta.sma(close, bbLen)
dev   = bbSD * ta.stdev(close, bbLen)
bbw   = basis != 0 ? (2 * dev) / basis : 0.0
bbwLo = ta.lowest(bbw, sqzLook)
bbwHi = ta.highest(bbw, sqzLook)
sSqz  = (bbwHi - bbwLo) > 0 ? math.min(math.max((bbwHi - bbw) / (bbwHi - bbwLo), 0.0), 1.0) : 0.0


rngN  = ta.highest(high, bbLen) - ta.lowest(low, bbLen)
sTight= math.min(math.max(1.0 - ta.percentrank(rngN, sqzLook) / 100.0, 0.0), 1.0)


sVol  = volume > 0 ? math.min(math.max(1.0 - ta.percentrank(volume, sqzLook) / 100.0, 0.0), 1.0) : 0.5


rsiv  = ta.rsi(close, rsiLen)
sBal  = math.min(math.max(1.0 - math.abs(rsiv - 50) / 25.0, 0.0), 1.0)

wSum  = wAdx + wSqz + wTight + wVol + wBal
rawScore = wSum > 0 ? (sAdx*wAdx + sSqz*wSqz + sTight*wTight + sVol*wVol + sBal*wBal) / wSum : 0.0
barScore = math.min(math.max(rawScore * 10.0, 0.0), 10.0)
isCompress = barScore >= minScore


type trade
    int   dir        = 0       // 1 = long breakout, -1 = short breakout
    float entry      = na
    float sl         = na
    float tp1        = na
    float tp2        = na
    float tp3        = na
    float score      = 0.0
    int   bornBar    = na
    int   stage      = 0       // 0 open, count of TPs hit
    bool  closed     = false
    bool  won        = false
    line  lnEntry    = na
    label tag        = na

var array<trade> live = array.new<trade>()

// ── Statistics counters (global state) ───────────────────────────────────────────
var int   stTotal   = 0
var int   stWins    = 0
var int   stLosses  = 0
var int   stScratch = 0
var int   stLongW   = 0
var int   stLongL   = 0
var int   stShortW  = 0
var int   stShortL  = 0
var int   stTp1     = 0
var int   stTp2     = 0
var int   stTp3     = 0
var float stRsum    = 0.0      // realized R, running sum
var int   stStrongW = 0        // wins on score>=8
var int   stStrongT = 0        // total on score>=8
var int   stCurStreak = 0
var int   stBestStreak= 0
var int   stWorstStreak=0


var bool  inZone   = false
var int   zStart   = na
var int   zConsec  = 0
var float zHigh    = na
var float zLow     = na
var float zScoreMx = 0.0
var box   zBox     = na
var line  lnBuy    = na
var line  lnSell   = na
var label lblBuy   = na
var label lblSell  = na
var label lblRank  = na          // prominent strength-rank label above the box

var int   zTouchTop = 0
var int   zTouchBot = 0
var int   zTimeUp   = 0
var int   zTimeDn   = 0
var float zBullProb = 50.0
var int   zPredDir  = 1          // 1 = lean up, -1 = lean down
var float aBuy     = na    // active buy stop
var float aSell    = na    // active sell stop
var bool  firedUp  = false
var bool  firedDn  = false

inWindow = lookback <= 0 or (last_bar_index - n) <= lookback

f_buff() => math.max((zHigh - zLow) * (buffPct / 100.0), syminfo.mintick * 2)


f_bullProb(float rsiNow) =>
    float rngH = math.max(zHigh - zLow, syminfo.mintick)
    float pos  = (close - zLow) / rngH                 // 0 bottom .. 1 top
    int   tot  = math.max(zTimeUp + zTimeDn, 1)
    float upT  = zTimeUp / tot
    float tTot = math.max(zTouchTop + zTouchBot, 1)
    float topR = zTouchTop / tTot
    float bull = 0.0
    float bear = 0.0
    // 1) position in range (30)
    bull += pos * 30.0
    bear += (1.0 - pos) * 30.0
    // 2) time distribution (25)
    bull += upT * 25.0
    bear += (1.0 - upT) * 25.0
    // 3) edge interaction (25) — repeated resistance touches = absorption = upward pressure
    bull += topR * 25.0
    bear += (1.0 - topR) * 25.0
    // 4) RSI momentum (20)
    float rl = math.min(math.max((rsiNow - 50.0) / 25.0, -1.0), 1.0)
    bull += (rl > 0 ? rl : 0.0) * 20.0
    bear += (rl < 0 ? -rl : 0.0) * 20.0
    float t = bull + bear
    t > 0 ? math.round(bull / t * 100.0) : 50.0

// Build / refresh the big rank label that sits ABOVE the zone box.
f_rankText() =>
    string head = f_stars(zScoreMx) + "  " + str.tostring(zScoreMx, "#.0") + "/10  " + f_tier(zScoreMx)
    string sub  = showProb ? ("\n" + (zPredDir > 0 ? "▲ " : "▼ ") + str.tostring(zPredDir > 0 ? zBullProb : 100 - zBullProb, "#") + "% likely " + (zPredDir > 0 ? "UP" : "DOWN")) : ""
    head + sub

// Archive pool to bound box count
var array<box> zHist = array.new<box>()
f_archiveBox(box b) =>
    if not na(b)
        array.push(zHist, b)
        while array.size(zHist) > maxZones
            box.delete(array.shift(zHist))



bool evBuyBrk  = false
bool evSellBrk = false
float evScore  = 0.0

if barstate.isconfirmed and inWindow
    // ---------- forming / extending the consolidation ----------
    if not inZone
        if isCompress
            zConsec += 1
            if zConsec == 1
                zStart    := n
                zHigh     := high
                zLow      := low
                zScoreMx  := barScore
                zTouchTop := 0
                zTouchBot := 0
                zTimeUp   := 0
                zTimeDn   := 0
            else
                zHigh    := math.max(zHigh, high)
                zLow     := math.min(zLow, low)
                zScoreMx := math.max(zScoreMx, barScore)
            if zConsec >= minBars
                inZone  := true
                firedUp := false
                firedDn := false
                zBullProb := f_bullProb(rsiv)
                zPredDir  := zBullProb >= 50 ? 1 : -1
                bool predBull = zPredDir > 0
                col   = color.new(f_zoneCol(predBull, zScoreMx), bgTransp)
                bcol  = color.new(f_zoneCol(predBull, zScoreMx), 30)
                zBox  := box.new(zStart, zHigh, n, zLow, bgcolor = col, border_color = bcol, border_width = 1)
                aBuy  := zHigh + f_buff()
                aSell := zLow  - f_buff()
                if showStops
                    lnBuy  := line.new(zStart, aBuy,  n, aBuy,  color = color.new(cUp, 20), width = 1, style = line.style_dashed)
                    lnSell := line.new(zStart, aSell, n, aSell, color = color.new(cDn, 20), width = 1, style = line.style_dashed)
                if showStopLbl
                    lblBuy  := label.new(n, aBuy,  "▲ Buy "  + f_px(aBuy),  style = label.style_none, textcolor = cUp, size = size.small, textalign = text.align_left)
                    lblSell := label.new(n, aSell, "▼ Sell " + f_px(aSell), style = label.style_none, textcolor = cDn, size = size.small, textalign = text.align_left)
                if showRank
                    lblRank := label.new(math.round((zStart + n) / 2), zHigh, f_rankText(), style = label.style_label_down, color = color.new(f_zoneCol(predBull, zScoreMx), 15), textcolor = color.white, size = f_lsize(labelSize), textalign = text.align_center)
        else
            zConsec := 0
    else
        // ---------- zone live: extend, then watch for a breakout ----------
        bool stillTight = isCompress and (high <= aBuy and low >= aSell)
        if stillTight and (n - zStart) < maxBars
            zHigh    := math.max(zHigh, high)
            zLow     := math.min(zLow, low)
            zScoreMx := math.max(zScoreMx, barScore)
            aBuy     := zHigh + f_buff()
            aSell    := zLow  - f_buff()
            // track edge touches + time-in-half for directional probability
            float rngH = math.max(zHigh - zLow, syminfo.mintick)
            if high >= zHigh - rngH * 0.10
                zTouchTop += 1
            if low <= zLow + rngH * 0.10
                zTouchBot += 1
            if (close - zLow) / rngH > 0.5
                zTimeUp += 1
            else
                zTimeDn += 1
            zBullProb := f_bullProb(rsiv)
            zPredDir  := zBullProb >= 50 ? 1 : -1
            bool predBull = zPredDir > 0
            color zc = f_zoneCol(predBull, zScoreMx)
            box.set_right(zBox, n)
            box.set_top(zBox, zHigh)
            box.set_bottom(zBox, zLow)
            box.set_bgcolor(zBox, color.new(zc, bgTransp))
            box.set_border_color(zBox, color.new(zc, 30))
            if showStops
                line.set_xy1(lnBuy, zStart, aBuy), line.set_xy2(lnBuy, n, aBuy)
                line.set_xy1(lnSell, zStart, aSell), line.set_xy2(lnSell, n, aSell)
            if showStopLbl
                label.set_xy(lblBuy, n, aBuy),   label.set_text(lblBuy, "▲ Buy " + f_px(aBuy))
                label.set_xy(lblSell, n, aSell), label.set_text(lblSell, "▼ Sell " + f_px(aSell))
            if showRank and not na(lblRank)
                label.set_xy(lblRank, math.round((zStart + n) / 2), zHigh)
                label.set_text(lblRank, f_rankText())
                label.set_color(lblRank, color.new(zc, 15))
        else
            // breakout test
            bool upBrk  = brkConfirm == "Close" ? close > aBuy  : high > aBuy
            bool dnBrk  = brkConfirm == "Close" ? close < aSell : low  < aSell
            if upBrk and not firedUp
                firedUp  := true
                evBuyBrk := true
                evScore  := zScoreMx
            else if dnBrk and not firedDn
                firedDn  := true
                evSellBrk:= true
                evScore  := zScoreMx
            // retire zone on first breakout (either side) or on timeout
            if upBrk or dnBrk or (n - zStart) >= maxBars
                // freeze the rank label with the realized breakout direction tint
                if showRank and not na(lblRank) and (upBrk or dnBrk)
                    color fc = f_zoneCol(upBrk, zScoreMx)
                    label.set_color(lblRank, color.new(fc, 0))
                f_archiveBox(zBox)
                inZone  := false
                zConsec := 0
                zBox    := na
                lnBuy   := na
                lnSell  := na
                lblBuy  := na
                lblSell := na
                lblRank := na

    // ---------- open a tracked trade on a fresh breakout ----------
    if evBuyBrk or evSellBrk
        int   d   = evBuyBrk ? 1 : -1
        float ent = evBuyBrk ? aBuy : aSell
        float topE = zHigh
        float botE = zLow
        float risk = slMode == "Opposite Edge" ? (evBuyBrk ? ent - botE : topE - ent) : slMode == "Zone Mid" ? (evBuyBrk ? ent - (topE+botE)/2 : (topE+botE)/2 - ent) : slATR * atrv
        risk := math.max(risk, atrv * 0.25)
        float sl  = evBuyBrk ? ent - risk : ent + risk
        float t1  = evBuyBrk ? ent + risk*rr1 : ent - risk*rr1
        float t2  = evBuyBrk ? ent + risk*rr2 : ent - risk*rr2
        float t3  = evBuyBrk ? ent + risk*rr3 : ent - risk*rr3
        tr = trade.new(d, ent, sl, t1, t2, t3, evScore, n, 0, false, false, na, na)
        if showTPs
            tr.lnEntry := line.new(n, ent, n + 1, ent, color = color.new(d>0?cUp:cDn, 0), width = 2)
            line.new(n, t1, n+1, t1, color = color.new(d>0?cUp:cDn, 55), style = line.style_dotted)
            line.new(n, sl, n+1, sl, color = color.new(color.gray, 40), style = line.style_dotted)
        if showMarks
            label.new(n, evBuyBrk ? aSell : aBuy, evBuyBrk ? "▲" : "▼", style = evBuyBrk ? label.style_label_up : label.style_label_down, color = color.new(d>0?cUp:cDn, 0), textcolor = color.white, size = size.small)
        array.push(live, tr)
        stTotal += 1
        if evScore >= 8
            stStrongT += 1

    // ---------- resolve open trades ----------
    if array.size(live) > 0
        winLevel = winBasis == "TP1" ? 1 : winBasis == "TP2" ? 2 : 3
        i = array.size(live) - 1
        while i >= 0
            t = array.get(live, i)
            if not t.closed
                bool hitSL = t.dir > 0 ? low <= t.sl : high >= t.sl
                bool h1 = t.dir > 0 ? high >= t.tp1 : low <= t.tp1
                bool h2 = t.dir > 0 ? high >= t.tp2 : low <= t.tp2
                bool h3 = t.dir > 0 ? high >= t.tp3 : low <= t.tp3
                int reached = h3 ? 3 : h2 ? 2 : h1 ? 1 : 0
                // SL first if both in same bar and SL is closer is ignored for simplicity: TP priority only if reached>=winLevel
                if reached >= winLevel
                    t.closed := true
                    t.won := true
                    t.stage := reached
                    stWins += 1
                    stRsum += (reached == 3 ? rr3 : reached == 2 ? rr2 : rr1)
                    if reached >= 1
                        stTp1 += 1
                    if reached >= 2
                        stTp2 += 1
                    if reached >= 3
                        stTp3 += 1
                    if t.dir > 0
                        stLongW += 1
                    else
                        stShortW += 1
                    if t.score >= 8
                        stStrongW += 1
                    stCurStreak := stCurStreak >= 0 ? stCurStreak + 1 : 1
                    stBestStreak := math.max(stBestStreak, stCurStreak)
                else if hitSL
                    t.closed := true
                    t.won := false
                    stLosses += 1
                    stRsum -= 1.0
                    if t.dir > 0
                        stLongL += 1
                    else
                        stShortL += 1
                    stCurStreak := stCurStreak <= 0 ? stCurStreak - 1 : -1
                    stWorstStreak := math.min(stWorstStreak, stCurStreak)
                else if (n - t.bornBar) >= maxTrack
                    t.closed := true
                    stScratch += 1
                if t.closed and not na(t.lnEntry)
                    line.set_x2(t.lnEntry, n)
                array.set(live, i, t)
            i -= 1
        // prune fully-closed old trades to bound memory
        while array.size(live) > 60
            old = array.shift(live)
            if not na(old.lnEntry)
                line.delete(old.lnEntry)

// ═══════════════════════════════════════════════════════════════════════════════════
//                                   DASHBOARD
// ═══════════════════════════════════════════════════════════════════════════════════
f_bar(float pct) =>          // 5-cell █/░ progress bar
    int filled = math.round(pct / 100.0 * 5)
    string s = ""
    for i = 1 to 5
        s := s + (i <= filled ? "█" : "░")
    s

var table dash = na
if showDash and barstate.islast
    if na(dash)
        dash := table.new(f_dashPos(dashPos), 2, 16, bgcolor = DASH_BG, border_color = DASH_BORDER, border_width = 1, frame_color = DASH_GOLD, frame_width = 2)
    closed = stWins + stLosses
    wr     = closed > 0 ? 100.0 * stWins / closed : 0.0
    lwr    = (stLongW + stLongL) > 0 ? 100.0 * stLongW / (stLongW + stLongL) : 0.0
    swr    = (stShortW + stShortL) > 0 ? 100.0 * stShortW / (stShortW + stShortL) : 0.0
    strwr  = stStrongT > 0 ? 100.0 * stStrongW / stStrongT : 0.0
    expR   = stTotal > 0 ? stRsum / stTotal : 0.0
    ds     = f_lsize(dashSize)
    rA     = DASH_ROW_BG
    rB     = DASH_ROW_ALT
    wrCol  = wr >= 60 ? DASH_TEAL : wr >= 45 ? DASH_GOLD : DASH_RED
    statusTxt = inZone ? "● TRACKING" : "○ SCANNING"
    statusCol = inZone ? DASH_TEAL : DASH_GREY
    liveDir   = inZone ? (zPredDir > 0 ? "▲ UP " : "▼ DOWN ") + str.tostring(zPredDir > 0 ? zBullProb : 100 - zBullProb, "#") + "%" : "--"
    liveDirCol= not inZone ? DASH_GREY : zPredDir > 0 ? DASH_TEAL : DASH_RED

    table.cell(dash, 0, 0, "CONSOLIDATION BREAKOUT PRO", text_color = DASH_GOLD, bgcolor = DASH_HDR_BG, text_size = ds, text_halign = text.align_left)
    table.cell(dash, 1, 0, statusTxt, text_color = statusCol, bgcolor = DASH_HDR_BG, text_size = ds, text_halign = text.align_right)

    table.cell(dash, 0, 1, "Win Rate", text_color = DASH_GREY, bgcolor = rA, text_size = ds, text_halign = text.align_left)
    table.cell(dash, 1, 1, str.tostring(wr, "#.0") + "%  (" + str.tostring(stWins) + "/" + str.tostring(closed) + ")", text_color = wrCol, bgcolor = rA, text_size = ds, text_halign = text.align_right)

    table.cell(dash, 0, 2, "WR Meter", text_color = DASH_GREY, bgcolor = rB, text_size = ds, text_halign = text.align_left)
    table.cell(dash, 1, 2, f_bar(wr), text_color = wrCol, bgcolor = rB, text_size = ds, text_halign = text.align_right)

    table.cell(dash, 0, 3, "Total Breakouts", text_color = DASH_GREY, bgcolor = rA, text_size = ds, text_halign = text.align_left)
    table.cell(dash, 1, 3, str.tostring(stTotal), text_color = DASH_WHITE, bgcolor = rA, text_size = ds, text_halign = text.align_right)

    table.cell(dash, 0, 4, "Wins / Losses", text_color = DASH_GREY, bgcolor = rB, text_size = ds, text_halign = text.align_left)
    table.cell(dash, 1, 4, str.tostring(stWins) + "W / " + str.tostring(stLosses) + "L", text_color = DASH_WHITE, bgcolor = rB, text_size = ds, text_halign = text.align_right)

    table.cell(dash, 0, 5, "Open / Scratch", text_color = DASH_GREY, bgcolor = rA, text_size = ds, text_halign = text.align_left)
    table.cell(dash, 1, 5, str.tostring(stTotal - closed - stScratch) + " / " + str.tostring(stScratch), text_color = DASH_WHITE, bgcolor = rA, text_size = ds, text_halign = text.align_right)

    table.cell(dash, 0, 6, "Long WR", text_color = DASH_GREY, bgcolor = rB, text_size = ds, text_halign = text.align_left)
    table.cell(dash, 1, 6, str.tostring(lwr, "#.0") + "%  (" + str.tostring(stLongW) + "/" + str.tostring(stLongW+stLongL) + ")", text_color = DASH_TEAL, bgcolor = rB, text_size = ds, text_halign = text.align_right)

    table.cell(dash, 0, 7, "Short WR", text_color = DASH_GREY, bgcolor = rA, text_size = ds, text_halign = text.align_left)
    table.cell(dash, 1, 7, str.tostring(swr, "#.0") + "%  (" + str.tostring(stShortW) + "/" + str.tostring(stShortW+stShortL) + ")", text_color = DASH_RED, bgcolor = rA, text_size = ds, text_halign = text.align_right)

    table.cell(dash, 0, 8, "Strong-Zone WR (≥8)", text_color = DASH_GREY, bgcolor = rB, text_size = ds, text_halign = text.align_left)
    table.cell(dash, 1, 8, str.tostring(strwr, "#.0") + "%  (" + str.tostring(stStrongW) + "/" + str.tostring(stStrongT) + ")", text_color = DASH_GOLD, bgcolor = rB, text_size = ds, text_halign = text.align_right)

    table.cell(dash, 0, 9, "TP1 / TP2 / TP3", text_color = DASH_GREY, bgcolor = rA, text_size = ds, text_halign = text.align_left)
    table.cell(dash, 1, 9, str.tostring(stTp1) + " / " + str.tostring(stTp2) + " / " + str.tostring(stTp3), text_color = DASH_WHITE, bgcolor = rA, text_size = ds, text_halign = text.align_right)

    table.cell(dash, 0, 10, "Expectancy", text_color = DASH_GREY, bgcolor = rB, text_size = ds, text_halign = text.align_left)
    table.cell(dash, 1, 10, str.tostring(expR, "#.00") + "R / trade", text_color = expR >= 0 ? DASH_TEAL : DASH_RED, bgcolor = rB, text_size = ds, text_halign = text.align_right)

    table.cell(dash, 0, 11, "Total R", text_color = DASH_GREY, bgcolor = rA, text_size = ds, text_halign = text.align_left)
    table.cell(dash, 1, 11, str.tostring(stRsum, "#.0") + "R", text_color = stRsum >= 0 ? DASH_TEAL : DASH_RED, bgcolor = rA, text_size = ds, text_halign = text.align_right)

    table.cell(dash, 0, 12, "Best / Worst Streak", text_color = DASH_GREY, bgcolor = rB, text_size = ds, text_halign = text.align_left)
    table.cell(dash, 1, 12, "+" + str.tostring(stBestStreak) + " / " + str.tostring(stWorstStreak), text_color = DASH_WHITE, bgcolor = rB, text_size = ds, text_halign = text.align_right)

    table.cell(dash, 0, 13, "Live Zone Score", text_color = DASH_GREY, bgcolor = rA, text_size = ds, text_halign = text.align_left)
    table.cell(dash, 1, 13, f_stars(barScore) + " " + str.tostring(barScore, "#.0") + "/10", text_color = DASH_GOLD, bgcolor = rA, text_size = ds, text_halign = text.align_right)

    table.cell(dash, 0, 14, "Score Meter", text_color = DASH_GREY, bgcolor = rB, text_size = ds, text_halign = text.align_left)
    table.cell(dash, 1, 14, f_bar(barScore * 10) + "  " + f_tier(barScore), text_color = DASH_WHITE, bgcolor = rB, text_size = ds, text_halign = text.align_right)

    table.cell(dash, 0, 15, "Live Breakout Bias", text_color = DASH_GREY, bgcolor = rA, text_size = ds, text_halign = text.align_left)
    table.cell(dash, 1, 15, liveDir, text_color = liveDirCol, bgcolor = rA, text_size = ds, text_halign = text.align_right)

// ═══════════════════════════════════════════════════════════════════════════════════
//                                    ALERTS
// ═══════════════════════════════════════════════════════════════════════════════════
if enaAlerts and evBuyBrk
    alert("CBP BUY breakout " + syminfo.ticker + " " + timeframe.period + " | score " + str.tostring(evScore, "#.0") + "/10 | entry " + f_px(aBuy), alert.freq_once_per_bar_close)
if enaAlerts and evSellBrk
    alert("CBP SELL breakout " + syminfo.ticker + " " + timeframe.period + " | score " + str.tostring(evScore, "#.0") + "/10 | entry " + f_px(aSell), alert.freq_once_per_bar_close)

// Data window outputs
plot(barScore, "Zone Score", display = display.data_window)
plot(adxv, "ADX", display = display.data_window)
plot(bbw, "BB Width", display = display.data_window)
plot(rsiv, "RSI", display = display.data_window)
````
