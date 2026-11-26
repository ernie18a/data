# CryptoStatus Waves / Layered Oscillator Companion

- url: https://www.tradingview.com/script/olA3StkC-CryptoStatus-Waves-Layered-Oscillator-Companion/
- type: indicator
- pine_id: PUB;a57a74f36eee43dd9fb4576d572b0556
- version: 1.0

## Description

CryptoStatus Waves is the oscillator companion to CryptoStatus. Where the overlay gives you the regime and context on your price chart, Waves opens the hood and shows you the underlying momentum, money flow, trend strength, and positioning that drive the read, all layered in one cohesive pane. The two are designed to be run together: every oscillator here is the same series, at the same Daily or Weekly anchor, that feeds the overlay's divergences and score.

WHAT YOU SEE

The dominant element is the MoneyFlow area, a volume-weighted Money Flow Index plotted as a filled area split at its midline. Green above the midline means money flow is confirming (net inflow). Red below means flow is failing (net outflow). This is the backdrop everything else rides on, because in crypto, flow is the foundation.

Three lines ride on top of the money-flow area. RSI is plotted as a two-tone line, magenta above 50 and cyan below, so momentum direction is readable at a glance. ADX is plotted as a single line colored by directional dominance: gold when the positive directional index leads (bulls control the trend), blue when the negative directional index leads (bears control the trend). Its height shows trend strength, its color shows trend direction. OBV is plotted as an orange line tracking the longer-run accumulation and distribution flow.

A bold white CryptoScore line sits on top of all of it. This is the same 0 to 100 composite the CryptoStatus overlay reports, mapped onto the pane and centered at the zero gate. Above zero is net bullish, below is net bearish. Because it is built from the regime, RSI, money flow, and OBV with an ADX conviction multiplier, it gives you a single fast read of where the weight of evidence sits, and it agrees with the overlay's score on the same symbol.

DIVERGENCES

The same RSI, ADX-exhaustion, and OI positioning divergences that CryptoStatus marks on price are pinned here to their own waves, so you can see exactly which oscillator is diverging and where. RSI divergences sit on the RSI line, ADX exhaustion on the ADX line, and OI positioning divergences on the OBV line. Used with identical pivot settings to the overlay, the markers line up between the two panes.

VALUE TABLE

A compact table reports the current value of each component: RSI, OBV percentile, money flow with an in or out tag, ADX with the leading directional index, the positive and negative directional index values, and the composite SCORE with its label. Volume-less symbols are handled gracefully, with money flow showing not available rather than breaking the score.

WHY IT PAIRS WITH CRYPTOSTATUS

CryptoStatus Waves is crypto-native. The composite score's regime vote reads Bitcoin, and the positioning divergence uses open interest rather than the equity-style on-balance-volume positioning. Lengths, ribbon parameters, money-flow length, and the confirmation buffer all match the CryptoStatus overlay so the two stay in agreement. Run CryptoStatus on your price chart and CryptoStatus Waves in the pane below it for a complete top-down picture: regime and context above, the engine driving it below.

INPUTS AND DEFAULTS

The anchor matches CryptoStatus and defaults to Daily, switchable to Weekly. RSI, ADX, money-flow, and OBV lengths, the wave heights and opacities, divergence pivot settings, score weights, and all colors are adjustable. Keep the money-flow length and regime parameters aligned with the overlay if you want the scores to match exactly. The open interest symbol used for positioning divergence is configurable and na-safe.

This indicator is provided for educational and informational purposes only. It is not financial advice. Past performance and historical behavior do not guarantee future results. Trade at your own risk.

TheurgyLabs — Conjured with AI

## Source Code

````pine
//@version=6
indicator("CryptoStatus Waves", shorttitle="CS Waves", overlay=false, max_bars_back=5000)

// ═══════════════════════════════════════════════════════════════════════════════
// CryptoStatus Waves — Layered Oscillator Companion (crypto-native)    TheurgyLabs
// ═══════════════════════════════════════════════════════════════════════════════
// Companion to CryptoStatus, same format as MarketStatus Waves but BTC-only:
//   BACKGROUND — MoneyFlow (MFI) red/green filled area, split at its midline (predominant)
//   LINES      — RSI (magenta>50 / cyan<50), ADX (DI-colored gold/blue), OBV (orange)
//   SCORE      — CryptoScore composite as a white line
//
// Everything reads the CHART symbol at the Daily/Weekly anchor, same lengths as
// CryptoStatus — these are the oscillators its divergences come from. Positioning
// divergence uses OI (crypto), not OBV. Table shows each one's current value.
// ═══════════════════════════════════════════════════════════════════════════════

// ── ANCHOR ──────────────────────────────────────────────────────────────────
string G_MODE = "══ ANCHOR ══"
i_regimeTF = input.string("Daily", "Anchor Timeframe", options=["Daily","Weekly"], group=G_MODE, tooltip="Matches CryptoStatus. Reads off this D/W anchor regardless of chart TF.")

// ── LENGTHS (match CryptoStatus) ────────────────────────────────────────────
string G_LEN = "══ LENGTHS ══"
i_rsiLen  = input.int(14, "RSI Length", minval=5, maxval=50, group=G_LEN)
i_adxLen  = input.int(14, "ADX Length", minval=5, maxval=50, group=G_LEN)
i_obvNorm = input.int(120, "OBV Normalize Lookback", minval=20, maxval=500, group=G_LEN, tooltip="OBV is unbounded; percentile-ranked over this window into 0-100.")

// ── MONEYFLOW (standard MFI) ────────────────────────────────────────────────
string G_MF = "══ MONEYFLOW AREA ══"
i_showFlow   = input.bool(true, "Show MoneyFlow Area", group=G_MF, tooltip="Green above midline = flow confirming. Red below = flow failing. The predominant background.")
i_mfiLen     = input.int(14, "MFI Length", minval=5, maxval=50, group=G_MF, tooltip="Keep at 14 to match the CryptoStatus overlay's score (the overlay's MFI vote is fixed at 14). Changing this shifts the MoneyFlow plot AND desyncs the Waves SCORE from the overlay.")
i_mfiSmooth  = input.int(3, "MFI Smoothing (EMA)", minval=1, maxval=10, group=G_MF, tooltip="Light EMA on MFI to reduce jitter. 1 = raw MFI.")
i_mfMid      = input.float(50, "MoneyFlow Midline", minval=20, maxval=80, step=1, group=G_MF, tooltip="The green/red split. 50 = balanced money-flow center (net inflow above, net outflow below).")
i_mfHeight   = input.float(0.7, "MoneyFlow Height", minval=0.1, maxval=1.0, step=0.05, group=G_MF, tooltip="How much of the pane the money-flow area fills.")
i_mfOpacity  = input.int(45, "MoneyFlow Opacity", minval=0, maxval=100, group=G_MF)

// ── RSI LINE ──────────────────────────────────────────────────────────────────
string G_RSI = "══ RSI LINE ══"
i_showRSI    = input.bool(true, "Show RSI Line", group=G_RSI)
i_rsiHeight  = input.float(0.85, "RSI Line Height", minval=0.1, maxval=1.0, step=0.05, group=G_RSI, tooltip="How much of the pane height the RSI line spans.")
i_rsiUpClr   = input.color(#FF00FF, "RSI > 50 (up)", group=G_RSI)
i_rsiDnClr   = input.color(#00FFFF, "RSI < 50 (down)", group=G_RSI)

// ── WAVE LINES (ADX + OBV) ──────────────────────────────────────────────────
string G_WAVE = "══ WAVE LINES ══"
i_showADX    = input.bool(true, "Show ADX Wave", group=G_WAVE)
i_showOBV    = input.bool(true, "Show OBV Wave", group=G_WAVE)
i_waveSmooth = input.int(4, "Wave Smoothing (EMA)", minval=1, maxval=20, group=G_WAVE)
i_waveHeight = input.float(0.85, "Wave Line Height", minval=0.1, maxval=1.0, step=0.05, group=G_WAVE, tooltip="How much of the pane the ADX/OBV lines span.")
i_obvClr     = input.color(#F77508, "OBV Line (positioning)", group=G_WAVE)
i_adxClr     = input.color(#FF9800, "ADX Line (trend)", group=G_WAVE)
i_adxDirClr  = input.bool(true, "Color ADX by DI direction", group=G_WAVE, tooltip="ADX line gold/yellow when +DI leads, blue when -DI leads.")

// ── DISPLAY ─────────────────────────────────────────────────────────────────
string G_DISP = "══ DISPLAY ══"
i_showTable = input.bool(true, "Show Value Table", group=G_DISP)
i_tablePos  = input.string("Middle Right", "Table Position", options=["Top Left","Top Center","Top Right","Middle Left","Middle Center","Middle Right","Bottom Left","Bottom Center","Bottom Right"], group=G_DISP)

// ── DIVERGENCE MARKERS (mirror CryptoStatus, pinned to each wave) ────────────
string G_DIV = "══ DIVERGENCE MARKERS ══"
i_divOn    = input.bool(true, "Show Divergence Markers", group=G_DIV, tooltip="Same RSI/ADX/OI divergences as CryptoStatus, pinned to their wave here. Use identical pivot settings to match the overlay.")
i_divPivL  = input.int(5, "Pivot Left", minval=2, maxval=10, group=G_DIV)
i_divPivR  = input.int(3, "Pivot Right", minval=1, maxval=10, group=G_DIV)
i_divMax   = input.int(60, "Max Pivot Lookback", minval=10, maxval=200, group=G_DIV)
i_oiSym    = input.symbol("BINANCE:BTCUSDT.P_OI", "BTC Open Interest", group=G_DIV, tooltip="Used for the positioning divergence (crypto uses OI, not OBV).")

// ── COMPOSITE CRYPTOSCORE (identical to CryptoStatus) ───────────────────────
string G_SCORE = "══ CRYPTOSCORE ══"
i_showScore  = input.bool(true, "Show CryptoScore Line", group=G_SCORE, tooltip="0-100 composite plotted as a line: 50=neutral. Regime + RSI + MFI + OBV votes, ADX conviction multiplier. Matches CryptoStatus.")
i_scoreClr   = input.color(#FFFFFF, "Score Line Color", group=G_SCORE)
i_wRegime    = input.float(1.0, "Weight: Regime", minval=0.0, maxval=3.0, step=0.5, group=G_SCORE)
i_wRSI       = input.float(1.0, "Weight: RSI", minval=0.0, maxval=3.0, step=0.5, group=G_SCORE)
i_wMFI       = input.float(1.0, "Weight: MFI", minval=0.0, maxval=3.0, step=0.5, group=G_SCORE)
i_wOBV       = input.float(1.0, "Weight: OBV", minval=0.0, maxval=3.0, step=0.5, group=G_SCORE)
// ribbon params for the regime vote (must match CryptoStatus to agree)
i_fastOut = input.int(8,  "Regime Fast Outer", minval=5, maxval=50, group=G_SCORE)
i_fastIn  = input.int(16, "Regime Fast Inner", minval=5, maxval=50, group=G_SCORE)
i_slowIn  = input.int(24, "Regime Slow Inner", minval=5, maxval=60, group=G_SCORE)
i_slowOut = input.int(32, "Regime Slow Outer", minval=10, maxval=80, group=G_SCORE)
i_confirmBars = input.int(3, "Regime Confirmation Bars", minval=0, maxval=20, group=G_SCORE, tooltip="Match CryptoStatus (default 3). Buffers the regime vote so the Waves SCORE tracks the overlay's buffered regime.")
i_neutGap = input.float(0.34, "Regime Neutral Zone %", minval=0.05, maxval=2.0, step=0.01, group=G_SCORE)
i_btcSym  = input.symbol("INDEX:BTCUSD", "Regime BTC", group=G_SCORE)

// ── PALETTE ───────────────────────────────────────────────────────────────────
color c_tblBase=#0d0d1a, c_zebra=#2a2a4a, c_tblBorder=#333355, c_white=#FFFFFF, c_green=#00FF88, c_red=#FF4444, c_gold=#FFD700

anchorTF = i_regimeTF == "Weekly" ? "W" : "D"
int mfTransp = math.max(0, math.min(95, 100 - i_mfOpacity))

// ═══════════════════════════════════════════════════════════════════════════════
// ENGINE — chart symbol at anchor TF
// ═══════════════════════════════════════════════════════════════════════════════
f_engine(int rsiLen, int adxLen, int obvNorm, int mfiLen, int mfiSm, int waveSm) =>
    float rsi = ta.rsi(close, rsiLen)
    float obv = ta.obv
    float obvRank = ta.percentrank(obv, obvNorm)
    float obvC = ta.ema(obvRank - 50.0, waveSm)
    float obvSlope = obv - obv[3]
    float obvSd = ta.stdev(obvSlope, 100)
    float vObvSoft = obvSd > 0 ? math.max(-1.0, math.min(1.0, obvSlope / (2.0 * obvSd))) : 0.0
    [diP, diM, adx] = ta.dmi(adxLen, adxLen)
    float adxC = ta.ema(adx - 50.0, waveSm)
    float mfiRaw = ta.mfi(hlc3, mfiLen)
    float mfiScore = ta.ema(mfiRaw, mfiSm)
    [rsi, obvRank, adx, diP, diM, obvC, adxC, mfiScore, vObvSoft, mfiRaw]

[rsiV, obvV, adxV, diPlus, diMinus, obvC, adxC, mfiScore, scVOBV, mfiRawV] = request.security(syminfo.tickerid, anchorTF, f_engine(i_rsiLen, i_adxLen, i_obvNorm, i_mfiLen, i_mfiSmooth, i_waveSmooth), barmerge.gaps_off, barmerge.lookahead_off)

// ═══════════════════════════════════════════════════════════════════════════════
// DIVERGENCE DETECTION — byte-identical to CryptoStatus so markers agree
// ═══════════════════════════════════════════════════════════════════════════════
f_oscDiv(float osc, int pL, int pR, int maxBars) =>
    float ph = ta.pivothigh(high, pL, pR)
    float pl = ta.pivotlow(low, pL, pR)
    var float prevPH = na
    var float prevOscH = na
    var int phBar = na
    var float prevPL = na
    var float prevOscL = na
    var int plBar = na
    bool bear = false
    bool bull = false
    float oscAtPiv = osc[pR]
    if not na(ph)
        if not na(prevPH) and (bar_index - phBar) <= maxBars and ph > prevPH and oscAtPiv < prevOscH
            bear := true
        prevPH := ph
        prevOscH := oscAtPiv
        phBar := bar_index
    if not na(pl)
        if not na(prevPL) and (bar_index - plBar) <= maxBars and pl < prevPL and oscAtPiv > prevOscL
            bull := true
        prevPL := pl
        prevOscL := oscAtPiv
        plBar := bar_index
    [bull, bear]

f_adxExhaust(int adxLen, int pL, int pR, int maxBars) =>
    [diP2, diM2, adx2] = ta.dmi(adxLen, adxLen)
    float ph = ta.pivothigh(high, pL, pR)
    float pl = ta.pivotlow(low, pL, pR)
    var float prevPH = na
    var int phBar = na
    var float prevPL = na
    var int plBar = na
    bool bear = false
    bool bull = false
    bool adxFalling = adx2[pR] < adx2[pR + 1]
    if not na(ph)
        if not na(prevPH) and (bar_index - phBar) <= maxBars and ph > prevPH and adxFalling
            bear := true
        prevPH := ph
        phBar := bar_index
    if not na(pl)
        if not na(prevPL) and (bar_index - plBar) <= maxBars and pl < prevPL and adxFalling
            bull := true
        prevPL := pl
        plBar := bar_index
    [bull, bear]

f_oiDiv(int pL, int pR, int maxBars) =>
    float ph = ta.pivothigh(high, pL, pR)
    float pl = ta.pivotlow(low, pL, pR)
    var float prevPH = na
    var float prevOiH = na
    var int phBar = na
    var float prevPL = na
    var float prevOiL = na
    var int plBar = na
    bool bear = false
    bool bull = false
    float oiAtPiv = close[pR]
    if not na(ph)
        if not na(prevPH) and (bar_index - phBar) <= maxBars and ph > prevPH and oiAtPiv < prevOiH
            bear := true
        prevPH := ph
        prevOiH := oiAtPiv
        phBar := bar_index
    if not na(pl)
        if not na(prevPL) and (bar_index - plBar) <= maxBars and pl < prevPL and oiAtPiv > prevOiL
            bull := true
        prevPL := pl
        prevOiL := oiAtPiv
        plBar := bar_index
    [bull, bear]

// detect RSI + ADX divergence on chart symbol at anchor TF
f_divAll(int rsiLen, int adxLen, int pL, int pR, int maxBars) =>
    float rsi = ta.rsi(close, rsiLen)
    [rb, rbe] = f_oscDiv(rsi, pL, pR, maxBars)
    [ab, abe] = f_adxExhaust(adxLen, pL, pR, maxBars)
    [rb, rbe, ab, abe]

[rsiBull, rsiBear, adxBull, adxBear] = request.security(syminfo.tickerid, anchorTF, f_divAll(i_rsiLen, i_adxLen, i_divPivL, i_divPivR, i_divMax), barmerge.gaps_off, barmerge.lookahead_off)
[oiBull, oiBear] = request.security(i_oiSym, anchorTF, f_oiDiv(i_divPivL, i_divPivR, i_divMax), barmerge.gaps_off, barmerge.lookahead_off)

// positioning divergence: OI (crypto)
bool posBull = oiBull
bool posBear = oiBear

bool dRsiBull = i_divOn and rsiBull
bool dRsiBear = i_divOn and rsiBear
bool dAdxBull = i_divOn and adxBull
bool dAdxBear = i_divOn and adxBear
bool dPosBull = i_divOn and posBull
bool dPosBear = i_divOn and posBear

// ═══════════════════════════════════════════════════════════════════════════════
// COMPOSITE CRYPTOSCORE (0-100) — identical construction to CryptoStatus
// ═══════════════════════════════════════════════════════════════════════════════
smma(float src, int len) =>
    var float val = na
    val := na(val) ? ta.sma(src, len) : (val * (len - 1) + src) / len
    val
f_regimeTrend() =>
    float v1 = smma(hl2, i_fastOut)
    float m1 = smma(hl2, i_fastIn)
    float m2 = smma(hl2, i_slowIn)
    float v2 = smma(hl2, i_slowOut)
    bool  tangled = (v1 < m1) != (v1 < v2) or (m2 < v2) != (v1 < v2)
    float spr = v2 != 0 ? (v1 - v2) / v2 * 100 : 0.0
    bool  flat = math.abs(spr) < i_neutGap
    bool  bear = not tangled and not flat and v1 < v2
    bool  bull = not tangled and not flat and not bear
    bull ? 1.0 : bear ? -1.0 : 0.0
float rawRegimeW = request.security(i_btcSym, anchorTF, f_regimeTrend(), barmerge.gaps_off, barmerge.lookahead_off)
// Apply the same confirmation buffer the overlay uses, so the regime VOTE matches shownRegime
var float shownRegimeW = 0.0
var int   stableCountW = 0
var float candidateW = 0.0
if rawRegimeW == shownRegimeW
    stableCountW := 0
else
    if rawRegimeW == candidateW
        stableCountW += 1
    else
        candidateW := rawRegimeW
        stableCountW := 1
    if stableCountW >= i_confirmBars
        shownRegimeW := candidateW
        stableCountW := 0
if i_confirmBars == 0
    shownRegimeW := rawRegimeW
float vRegime = shownRegimeW

float vRSI = na(rsiV) ? 0.0 : math.max(-1.0, math.min(1.0, (rsiV - 50.0) / 25.0))
float vMFI = na(mfiRawV) ? 0.0 : math.max(-1.0, math.min(1.0, (mfiRawV - 50.0) / 25.0))
float vOBV = nz(scVOBV)

float wSum = i_wRegime + i_wRSI + i_wMFI + i_wOBV
float dirSum = (nz(vRegime)*i_wRegime + vRSI*i_wRSI + vMFI*i_wMFI + vOBV*i_wOBV) / (wSum > 0 ? wSum : 1.0)
float adxConv = 0.5 + math.min(1.0, nz(adxV) / 50.0)
float marketScoreRaw = 50.0 + nz(dirSum) * 50.0 * nz(adxConv, 1.0)
float marketScore = na(marketScoreRaw) ? 50.0 : math.max(0.0, math.min(100.0, marketScoreRaw))

// ── EXPORTABLE VALUES (data_window only; draw nothing) ──
plot(nz(vRegime), "Regime", color=color.new(color.white, 100), display=display.data_window)
plot(marketScore, "CryptoScore (value)", color=color.new(color.white, 100), display=display.data_window)

// ═══════════════════════════════════════════════════════════════════════════════
// MAP TO PANE — all normalized to a common scale, then weighted by height
// ═══════════════════════════════════════════════════════════════════════════════
float PANE_SCALE = 50.0

// MoneyFlow: predominant background area
float mfNorm = (mfiScore - i_mfMid) / 50.0
float mfDisp = i_showFlow ? math.max(-1.2, math.min(1.2, mfNorm)) * PANE_SCALE * i_mfHeight : na
color mfClr  = mfiScore >= i_mfMid ? color.new(c_green, mfTransp) : color.new(c_red, mfTransp)

// RSI line: magenta>50 / cyan<50
float rsiNorm = (rsiV - 50.0) / 50.0
float rsiLine = i_showRSI ? rsiNorm * PANE_SCALE * i_rsiHeight : na
color rsiLineClr = rsiV >= 50.0 ? i_rsiUpClr : i_rsiDnClr

// ADX + OBV wave lines
float adxNorm = adxC / 50.0
float obvNorm2 = obvC / 50.0
float adxLine = i_showADX ? adxNorm * PANE_SCALE * i_waveHeight : na
float obvLine = i_showOBV ? obvNorm2 * PANE_SCALE * i_waveHeight : na
color adxLineClr = i_adxDirClr ? (diPlus >= diMinus ? #FFD700 : #1E90FF) : i_adxClr

// ═══════════════════════════════════════════════════════════════════════════════
// PLOTS — background area (predominant), then lines on top
// ═══════════════════════════════════════════════════════════════════════════════
plot(mfDisp, "MoneyFlow", color=mfClr, style=plot.style_area, histbase=0)
plot(rsiLine, "RSI Line", color=rsiLineClr, style=plot.style_line, linewidth=2)
plot(obvLine, "OBV", color=i_obvClr, linewidth=2)
plot(adxLine, "ADX", color=adxLineClr, linewidth=2)

// ── DIVERGENCE MARKERS — pinned to each wave at its plotted height ──
plotshape(dRsiBear ? rsiLine[i_divPivR] : na, "RSI Div Bear", shape.triangledown, location.absolute, color.new(#FFD700, 0), size=size.small, offset=-i_divPivR)
plotshape(dRsiBull ? rsiLine[i_divPivR] : na, "RSI Div Bull", shape.triangleup, location.absolute, color.new(#FFD700, 0), size=size.small, offset=-i_divPivR)
plotshape(dAdxBear ? adxLine[i_divPivR] : na, "ADX Div Bear", shape.xcross, location.absolute, color.new(#FF69B4, 0), size=size.small, offset=-i_divPivR)
plotshape(dAdxBull ? adxLine[i_divPivR] : na, "ADX Div Bull", shape.xcross, location.absolute, color.new(#FF69B4, 0), size=size.small, offset=-i_divPivR)
plotshape(dPosBear ? obvLine[i_divPivR] : na, "Pos Div Bear", shape.diamond, location.absolute, color.new(#00FFFF, 0), size=size.small, offset=-i_divPivR)
plotshape(dPosBull ? obvLine[i_divPivR] : na, "Pos Div Bull", shape.diamond, location.absolute, color.new(#00FFFF, 0), size=size.small, offset=-i_divPivR)

// ── CRYPTOSCORE line — white, (score-50)/50 mapped onto the ±pane ──
float scoreDisp = i_showScore ? (marketScore - 50.0) / 50.0 * PANE_SCALE : na
plot(scoreDisp, "CryptoScore", color=i_scoreClr, linewidth=3)

hline(0, "Zero / Gate", color=color.new(c_white, 50), linestyle=hline.style_solid)

// ═══════════════════════════════════════════════════════════════════════════════
// VALUE TABLE
// ═══════════════════════════════════════════════════════════════════════════════
f_tblPos(string p) =>
    switch p
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Top Right"     => position.top_right
        "Middle Left"   => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right"  => position.middle_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Bottom Right"  => position.bottom_right
        => position.bottom_right

var table tbl = table.new(position.top_right, 2, 8, bgcolor=c_tblBase, border_color=c_tblBorder, border_width=1, frame_color=c_tblBorder, frame_width=1)
table.set_position(tbl, f_tblPos(i_tablePos))

if i_showTable and barstate.islast
    string ts = size.small
    table.cell(tbl, 0, 0, "CS WAVES", bgcolor=c_zebra, text_color=c_gold, text_size=ts, text_halign=text.align_left)
    table.cell(tbl, 1, 0, anchorTF, bgcolor=c_zebra, text_color=c_gold, text_size=ts, text_halign=text.align_center)
    table.cell(tbl, 0, 1, "RSI", bgcolor=c_tblBase, text_color=rsiV >= 50 ? i_rsiUpClr : i_rsiDnClr, text_size=ts, text_halign=text.align_left)
    table.cell(tbl, 1, 1, str.tostring(rsiV, "#.#"), bgcolor=c_tblBase, text_color=c_white, text_size=ts, text_halign=text.align_center)
    table.cell(tbl, 0, 2, "OBV %", bgcolor=c_tblBase, text_color=i_obvClr, text_size=ts, text_halign=text.align_left)
    table.cell(tbl, 1, 2, str.tostring(obvV, "#.#"), bgcolor=c_tblBase, text_color=c_white, text_size=ts, text_halign=text.align_center)
    table.cell(tbl, 0, 3, "Flow", bgcolor=c_tblBase, text_color=na(mfiScore) ? c_white : mfiScore >= i_mfMid ? c_green : c_red, text_size=ts, text_halign=text.align_left)
    table.cell(tbl, 1, 3, na(mfiScore) ? "n/a" : str.tostring(mfiScore, "#") + (mfiScore >= i_mfMid ? " in" : " out"), bgcolor=c_tblBase, text_color=na(mfiScore) ? c_white : mfiScore >= i_mfMid ? c_green : c_red, text_size=ts, text_halign=text.align_center)
    table.cell(tbl, 0, 4, "ADX", bgcolor=c_tblBase, text_color=i_adxClr, text_size=ts, text_halign=text.align_left)
    table.cell(tbl, 1, 4, str.tostring(adxV, "#") + (diPlus >= diMinus ? " +DI" : " -DI"), bgcolor=c_tblBase, text_color=diPlus >= diMinus ? #FFD700 : #1E90FF, text_size=ts, text_halign=text.align_center)
    table.cell(tbl, 0, 5, "+DI", bgcolor=c_tblBase, text_color=#00FF88, text_size=ts, text_halign=text.align_left)
    table.cell(tbl, 1, 5, str.tostring(diPlus, "#"), bgcolor=c_tblBase, text_color=#00FF88, text_size=ts, text_halign=text.align_center)
    table.cell(tbl, 0, 6, "-DI", bgcolor=c_tblBase, text_color=#FF4444, text_size=ts, text_halign=text.align_left)
    table.cell(tbl, 1, 6, str.tostring(diMinus, "#"), bgcolor=c_tblBase, text_color=#FF4444, text_size=ts, text_halign=text.align_center)
    if i_showScore
        string scLbl = marketScore >= 65 ? "BULL" : marketScore >= 55 ? "LEAN B" : marketScore > 45 ? "NEUT" : marketScore > 35 ? "LEAN BR" : "BEAR"
        color scClr = marketScore >= 55 ? c_green : marketScore > 45 ? c_gold : c_red
        table.cell(tbl, 0, 7, "SCORE", bgcolor=c_zebra, text_color=c_gold, text_size=ts, text_halign=text.align_left)
        table.cell(tbl, 1, 7, str.tostring(marketScore, "#") + " " + scLbl, bgcolor=c_zebra, text_color=scClr, text_size=ts, text_halign=text.align_center)
````
