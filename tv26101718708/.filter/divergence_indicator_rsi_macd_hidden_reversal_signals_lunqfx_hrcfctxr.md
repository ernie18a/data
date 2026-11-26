# Divergence Indicator RSI, MACD,, Hidden Reversal Signals LunqFX

- url: https://www.tradingview.com/script/hRcFctXr-Divergence-Indicator-RSI-MACD-Hidden-Reversal-Signals-LunqFX/
- type: indicator
- pine_id: PUB;90867d9b282248fdace0fa7c356229f4
- version: 1.0

## Description

Divergence Indicator is a multi-engine divergence scanner for TradingView that reads RSI, MACD and OBV at every confirmed swing and only draws a divergence when the engines agree — so instead of the usual flood of weak one-oscillator signals, you get a few graded, high-conviction ones. Every divergence is rated by strength: ★★★ all three engines confirm (rare, strongest), ★★ two confirm, single-engine noise is filtered out by default. It detects regular divergences (price makes a new extreme, oscillators refuse — potential reversal) and hidden divergences (trend continuation), on any market — forex, crypto, stocks, indices, gold — and any timeframe. Built in Pine Script v6, fully non-repainting. Keywords: divergence indicator, RSI divergence, MACD divergence, OBV divergence, hidden divergence, regular divergence, reversal, momentum, exhaustion, multi oscillator scanner.

◆ WHY MULTI-ENGINE
Any single oscillator diverges constantly — that's why classic divergence tools feel random. Requiring independent confirmation from momentum (RSI), trend-momentum (MACD) and volume flow (OBV) removes most false positives: when all three refuse to follow price, the move is genuinely running out of fuel.

◆ WHAT IT DRAWS
Divergence lines on price — solid neon violet for bullish, neon amber for bearish; dashed for hidden divergences.
Star-graded labels — ★★ / ★★★ with tooltips explaining exactly what diverged.
Exhaustion candles — a unique display layer: candles glow at full neon while price and engines agree, and fade as engines stop confirming — you see a divergence brewing before it prints.
Status strip dashboard — a horizontal HUD along the bottom: last signal + strength, a live engine board (P / RSI / MACD / OBV direction arrows), a FUEL meter, and bull/bear counters.

◆ HOW IT WORKS
Swings are detected with confirmed pivots (N closed bars each side).
At each new confirmed pivot the scanner compares price and each engine against the previous pivot: price lower low + engine higher low = regular bull; price higher low + engine lower low = hidden bull (mirrored for highs).
The number of agreeing engines (1–3) becomes the star rating; signals below your minimum are skipped.
The live engine board and fuel meter track slope agreement in real time — display-only context that never alters signals.

◆ HOW TO USE IT
Treat ★★★ regular divergences as your primary reversal alerts — look for entries with your own structure/levels.
Use hidden divergences to join the trend on pullbacks.
Watch the FUEL meter: when it drains and candles fade, tighten stops on trend trades.
Raise Min strength to 3 for only the rarest, cleanest signals; lower pivot bars for faster (but noisier) detection.

◆ SETTINGS
Pivot left/right bars, max gap between swings, minimum strength, hidden divergences on/off, engine toggles (RSI/MACD/OBV), RSI length, exhaustion candles, label size, dashboard position/size.

◆ ALERTS
Bullish divergence · Bearish divergence (fire when a confirmed signal prints).

◆ LIMITATIONS
Signals confirm with a pivot delay (right bars) — that is the honest cost of zero repaint; lower it for speed, raise it for reliability.
On symbols without volume data the OBV engine adds no information — disable it there.
Divergence marks exhaustion, not timing — always combine with structure and risk management.

◆ ORIGINALITY & NON-REPAINTING
Original work: the three-engine agreement grading, the exhaustion-candle layer, the live engine board and the fuel meter are my own implementation — no third-party code. All divergences are built from confirmed pivots only; a drawn line or label never moves or disappears.

Educational analysis tool, not financial advice. © LunqFX.

## Source Code

````pine
//@version=6
// ============================================================================
//  Divergence Scanner - RSI MACD OBV Regular & Hidden Divergence [LunqFX]
// ----------------------------------------------------------------------------
//  Most divergence tools read ONE oscillator and flood the chart with weak
//  signals. This scanner reads THREE independent engines - RSI (momentum),
//  MACD (trend momentum) and OBV (volume flow) - and only draws a divergence
//  when they agree. Every signal is graded by how many engines confirm it:
//
//      ***  all three agree   - strongest, rare, high conviction
//      **   two agree         - solid
//      *    one engine        - hidden by default (noise filter)
//
//  It detects both types:
//      • REGULAR  divergence - price makes a new extreme, oscillators refuse
//                              -> exhaustion, potential REVERSAL
//      • HIDDEN   divergence - price holds structure, oscillators overshoot
//                              -> strength, potential CONTINUATION
//
//  NON-REPAINTING: divergences are built from CONFIRMED pivots only (a pivot
//  needs N closed bars on both sides). A drawn line and label never move or
//  disappear. Signals arrive with the pivot-confirmation delay by design -
//  that is the honest cost of zero repaint.
// ============================================================================
indicator("Divergence Indicator - RSI, MACD, OBV, Hidden + Reversal Signals", "Divergence Scanner [LunqFX]", overlay = true, max_lines_count = 500, max_labels_count = 500)

// ─────────────────────────────────────────────────────────────────────────
//  PALETTE
// ─────────────────────────────────────────────────────────────────────────
// neon violet (bull) x neon amber (bear) — a fresh LunqFX palette
VIO_MID  = #9333EA
VIO_HI   = #C879FF
AMB_MID  = #FF7A00
AMB_HI   = #FFB35C
GOLD     = #FFD166
MUTE     = #5C6675
INKHI    = #EAEEF6
INK      = #0B0E14
CARDBG   = #0A0D14

// ─────────────────────────────────────────────────────────────────────────
//  INPUTS
// ─────────────────────────────────────────────────────────────────────────
gD = "Detection"
pivL    = input.int(5, "Pivot left bars",  minval = 2, maxval = 20, group = gD, tooltip = "Bars required to the left of a swing point.")
pivR    = input.int(5, "Pivot right bars", minval = 2, maxval = 20, group = gD, tooltip = "Bars required to the right before a swing is CONFIRMED. Higher = later but more reliable. This is the no-repaint delay.")
maxGap  = input.int(60, "Max bars between pivots", minval = 10, maxval = 300, group = gD, tooltip = "Two swings further apart than this are not compared.")
minStars= input.int(2, "Min strength (engines agreeing)", minval = 1, maxval = 3, group = gD, tooltip = "Only draw a divergence confirmed by at least this many engines (RSI / MACD / OBV). 2 = clean, 3 = rare & strongest.")
showHid = input.bool(true, "Show hidden divergences", group = gD)

gE = "Engines"
useRSI  = input.bool(true, "RSI",  inline = "e", group = gE)
useMACD = input.bool(true, "MACD", inline = "e", group = gE)
useOBV  = input.bool(true, "OBV",  inline = "e", group = gE)
rsiLen  = input.int(14, "RSI length", minval = 2, group = gE)

gV = "Visuals"
neonOn  = input.bool(true, "Neon gradient candles", group = gV)
lblSz   = input.string("Normal","Label size", options = ["Small","Normal","Large"], group = gV)

gP = "Panel"
showHUD = input.bool(true, "Show dashboard", group = gP)
txtSize = input.string("Large","Text size", options = ["Normal","Large","Huge"], group = gP)
hudPos  = input.string("Bottom Center","Position", options = ["Bottom Center","Top Right","Top Left","Bottom Right","Bottom Left"], group = gP)

// ─────────────────────────────────────────────────────────────────────────
//  HELPERS
// ─────────────────────────────────────────────────────────────────────────
hudPosition(string s) =>
    switch s
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        => position.bottom_center

f_sz(string s) => s == "Huge" ? size.huge : s == "Normal" ? size.normal : size.large
f_lsz(string s) => s == "Small" ? size.small : s == "Large" ? size.large : size.normal
f_eng(bool on, float slope) => not on ? "—" : (slope > 0 ? "▲" : "▼")

// ─────────────────────────────────────────────────────────────────────────
//  ENGINES
// ─────────────────────────────────────────────────────────────────────────
rsiV  = ta.rsi(close, rsiLen)
[macdLine, _s, _h] = ta.macd(close, 12, 26, 9)
obvV  = ta.obv

// ─────────────────────────────────────────────────────────────────────────
//  PIVOTS  (confirmed only — the no-repaint core)
// ─────────────────────────────────────────────────────────────────────────
pl = ta.pivotlow(low, pivL, pivR)
ph = ta.pivothigh(high, pivL, pivR)

// previous confirmed pivot memory
var float loP  = na
var float loR  = na
var float loM  = na
var float loO  = na
var int   loB  = na
var float hiP  = na
var float hiR  = na
var float hiM  = na
var float hiO  = na
var int   hiB  = na

// state for the panel
var string lastSig  = "—"
var color  lastCol  = MUTE
var int    lastStars= 0
var int    lastBar  = na
var int    cntBull  = 0
var int    cntBear  = 0

f_stars(int n) => n >= 3 ? "★★★" : n == 2 ? "★★" : "★"

// ── bullish checks on a new confirmed pivot LOW ──
if not na(pl)
    curP = low[pivR]
    curR = rsiV[pivR]
    curM = macdLine[pivR]
    curO = obvV[pivR]
    curB = bar_index - pivR
    if not na(loP) and (curB - loB) <= maxGap
        // REGULAR bull: price lower low, engines higher low
        regN = 0
        regN += useRSI  and curP < loP and curR > loR ? 1 : 0
        regN += useMACD and curP < loP and curM > loM ? 1 : 0
        regN += useOBV  and curP < loP and curO > loO ? 1 : 0
        // HIDDEN bull: price higher low, engines lower low
        hidN = 0
        hidN += useRSI  and curP > loP and curR < loR ? 1 : 0
        hidN += useMACD and curP > loP and curM < loM ? 1 : 0
        hidN += useOBV  and curP > loP and curO < loO ? 1 : 0
        if regN >= minStars
            line.new(loB, loP, curB, curP, color = VIO_MID, width = 2)
            label.new(curB, curP, f_stars(regN) + " BULL", style = label.style_label_up, color = color.new(VIO_MID, 0), textcolor = #FFFFFF, size = f_lsz(lblSz), tooltip = "Regular bullish divergence — price lower low, " + str.tostring(regN) + "/3 engines higher low. Possible reversal up.")
            lastSig := "REGULAR BULL"
            lastCol := VIO_MID
            lastStars := regN
            lastBar := bar_index
            cntBull += 1
        else if showHid and hidN >= minStars
            line.new(loB, loP, curB, curP, color = color.new(VIO_MID, 40), width = 1, style = line.style_dashed)
            label.new(curB, curP, f_stars(hidN) + " bull·h", style = label.style_label_up, color = color.new(VIO_MID, 55), textcolor = INKHI, size = f_lsz(lblSz), tooltip = "Hidden bullish divergence — trend continuation signal.")
            lastSig := "HIDDEN BULL"
            lastCol := VIO_MID
            lastStars := hidN
            lastBar := bar_index
            cntBull += 1
    loP := curP
    loR := curR
    loM := curM
    loO := curO
    loB := curB

// ── bearish checks on a new confirmed pivot HIGH ──
if not na(ph)
    curP = high[pivR]
    curR = rsiV[pivR]
    curM = macdLine[pivR]
    curO = obvV[pivR]
    curB = bar_index - pivR
    if not na(hiP) and (curB - hiB) <= maxGap
        regN = 0
        regN += useRSI  and curP > hiP and curR < hiR ? 1 : 0
        regN += useMACD and curP > hiP and curM < hiM ? 1 : 0
        regN += useOBV  and curP > hiP and curO < hiO ? 1 : 0
        hidN = 0
        hidN += useRSI  and curP < hiP and curR > hiR ? 1 : 0
        hidN += useMACD and curP < hiP and curM > hiM ? 1 : 0
        hidN += useOBV  and curP < hiP and curO > hiO ? 1 : 0
        if regN >= minStars
            line.new(hiB, hiP, curB, curP, color = AMB_MID, width = 2)
            label.new(curB, curP, f_stars(regN) + " BEAR", style = label.style_label_down, color = color.new(AMB_MID, 0), textcolor = #FFFFFF, size = f_lsz(lblSz), tooltip = "Regular bearish divergence — price higher high, " + str.tostring(regN) + "/3 engines lower high. Possible reversal down.")
            lastSig := "REGULAR BEAR"
            lastCol := AMB_MID
            lastStars := regN
            lastBar := bar_index
            cntBear += 1
        else if showHid and hidN >= minStars
            line.new(hiB, hiP, curB, curP, color = color.new(AMB_MID, 40), width = 1, style = line.style_dashed)
            label.new(curB, curP, f_stars(hidN) + " bear·h", style = label.style_label_down, color = color.new(AMB_MID, 55), textcolor = INKHI, size = f_lsz(lblSz), tooltip = "Hidden bearish divergence — trend continuation signal.")
            lastSig := "HIDDEN BEAR"
            lastCol := AMB_MID
            lastStars := hidN
            lastBar := bar_index
            cntBear += 1
    hiP := curP
    hiR := curR
    hiM := curM
    hiO := curO
    hiB := curB

// ─────────────────────────────────────────────────────────────────────────
//  EXHAUSTION CANDLES  (divergence-aware — a LunqFX first)
//  Candles FADE when momentum stops agreeing with price: price pushes on but
//  the engines don't -> the move is running out of fuel. Bright = confirmed
//  move, washed-out = brewing divergence. Display-only, never affects signals.
// ─────────────────────────────────────────────────────────────────────────
slLen   = 8
pSlope  = close - close[slLen]
rSlope  = rsiV - rsiV[slLen]
mSlope  = macdLine - macdLine[slLen]
oSlope  = obvV - obvV[slLen]
agreeN  = 0
agreeN += (useRSI  and (rSlope > 0) == (pSlope > 0)) ? 1 : 0
agreeN += (useMACD and (mSlope > 0) == (pSlope > 0)) ? 1 : 0
agreeN += (useOBV  and (oSlope > 0) == (pSlope > 0)) ? 1 : 0
engTot  = (useRSI ? 1 : 0) + (useMACD ? 1 : 0) + (useOBV ? 1 : 0)
fuel    = engTot > 0 ? agreeN / engTot : 1.0        // 1 = full agreement, 0 = full divergence
bull    = close >= open
upC     = color.from_gradient(fuel, 0, 1, color.new(VIO_MID, 65), VIO_HI)
dnC     = color.from_gradient(fuel, 0, 1, color.new(AMB_MID, 65), AMB_HI)
plotcandle(neonOn ? open : na, high, low, close, "Exhaustion candles", color = bull ? upC : dnC, wickcolor = bull ? upC : dnC, bordercolor = bull ? upC : dnC)

// ─────────────────────────────────────────────────────────────────────────
//  DASHBOARD  (colour-rail card)
// ─────────────────────────────────────────────────────────────────────────
var table hud = na
if showHUD and barstate.islast
    if not na(hud)
        table.delete(hud)
    bsz    = f_sz(txtSize)
    cardBg = color.new(CARDBG, 0)
    headBg = color.new(color.from_gradient(0.5, 0, 1, CARDBG, #1A2234), 0)
    // ── HORIZONTAL STATUS STRIP — one row of colour-coded segments, like a
    //    terminal HUD along the bottom of the chart (not another vertical card).
    //    [ scanner ] [ SIGNAL ★★ ] [ P▲ RSI▼ MACD▼ OBV▲ ] [ FUEL ▰▰▱ ] [ 12/8 ]
    hud := table.new(hudPosition(hudPos), 9, 1, bgcolor = cardBg, border_width = 0, frame_color = color.new(#242C3C, 0), frame_width = 1)

    agoTxt = na(lastBar) ? "" : "  ·  " + str.tostring(bar_index - lastBar) + "b ago"

    pArrow = pSlope > 0 ? "▲" : "▼"
    rA = f_eng(useRSI, rSlope)
    mA = f_eng(useMACD, mSlope)
    oA = f_eng(useOBV, oSlope)
    brewing  = fuel < 0.5

    fuelN = math.round(fuel * 5)
    fbar  = ""
    for i = 1 to 5
        fbar := fbar + (i <= fuelN ? "▰" : "▱")
    fuelCol = fuel >= 0.67 ? VIO_HI : fuel >= 0.34 ? GOLD : AMB_HI

    // segment backgrounds: each block gets its own tinted surface
    sigBg  = color.new(lastCol, 84)
    engBg  = brewing ? color.new(GOLD, 86) : cardBg
    fuelBg = color.new(fuelCol, 88)

    table.cell(hud, 0, 0, "  ◈ DIV SCAN  ", text_color = VIO_HI, text_size = bsz, text_halign = text.align_center, bgcolor = headBg)
    table.cell(hud, 1, 0, " ", bgcolor = cardBg)
    table.cell(hud, 2, 0, "  " + lastSig + (lastStars > 0 ? " " + f_stars(lastStars) : "") + agoTxt + "  ", text_color = lastCol == MUTE ? MUTE : (lastCol == VIO_MID ? VIO_HI : AMB_HI), text_size = bsz, text_halign = text.align_center, bgcolor = sigBg)
    table.cell(hud, 3, 0, " ", bgcolor = cardBg)
    table.cell(hud, 4, 0, "  P " + pArrow + "  ·  RSI " + rA + "  ·  MACD " + mA + "  ·  OBV " + oA + "  ", text_color = brewing ? GOLD : INKHI, text_size = bsz, text_halign = text.align_center, bgcolor = engBg)
    table.cell(hud, 5, 0, " ", bgcolor = cardBg)
    table.cell(hud, 6, 0, "  FUEL " + fbar + "  ", text_color = fuelCol, text_size = bsz, text_halign = text.align_center, bgcolor = fuelBg)
    table.cell(hud, 7, 0, " ", bgcolor = cardBg)
    table.cell(hud, 8, 0, "  " + str.tostring(cntBull) + "▲ / " + str.tostring(cntBear) + "▼  ", text_color = INKHI, text_size = bsz, text_halign = text.align_center, bgcolor = headBg)

// ─────────────────────────────────────────────────────────────────────────
//  ALERTS
// ─────────────────────────────────────────────────────────────────────────
newBull = not na(lastBar) and lastBar == bar_index and lastCol == VIO_MID
newBear = not na(lastBar) and lastBar == bar_index and lastCol == AMB_MID
alertcondition(newBull, "Bullish divergence", "A confirmed bullish divergence was detected")
alertcondition(newBear, "Bearish divergence", "A confirmed bearish divergence was detected")
````
