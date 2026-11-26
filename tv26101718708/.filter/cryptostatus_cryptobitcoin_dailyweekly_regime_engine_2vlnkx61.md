# CryptoStatus / Crypto/Bitcoin Daily/Weekly Regime Engine

- url: https://www.tradingview.com/script/2vlnkx61-CryptoStatus-Crypto-Bitcoin-Daily-Weekly-Regime-Engine/
- type: indicator
- pine_id: PUB;ecb8ead5c53944408aeda301129731bb
- version: 1.0

## Description

CryptoStatus is a top-down regime indicator built specifically for crypto. It answers one question clearly and keeps it on your screen no matter what timeframe you are working: is the crypto market bullish, bearish, or neutral right now, and how much should you trust that read? The regime is computed off a fixed Daily or Weekly anchor, so the status stays stable while you analyze any intraday chart underneath it.

HOW THE STATUS IS DETERMINED

The market STATUS is driven by one thing only: the Bitcoin regime ribbon read at your chosen anchor timeframe. CryptoStatus uses a four-SMMA ribbon (8/16/24/32 on HL2) with tangle and flat-zone detection. When the ribbon is cleanly separated and rising, the status is BULLISH (gold). Cleanly separated and falling, it is BEARISH (blue). Tangled or inside the neutral zone, it is NEUTRAL (near-white). A confirmation buffer requires the raw regime to hold for a configurable number of anchor bars before the displayed status flips, which cuts whipsaw at the turns. This keeps the headline call simple and legible rather than a muddy composite of many inputs.

HOW CONFIDENCE WORKS

The status tells you direction. Confidence tells you conviction. It is built from the decisiveness of the ribbon spread, then modulated by three crypto-native factors, none of which can override the status. They only raise or lower the confidence number depending on whether they back or fight the trend.

The first factor is open interest. CryptoStatus reads OI relative to its own moving average. A healthy rise in leverage backing a trend reads as risk-on and adds confidence. Extreme leverage reads as stress, a crowded and fragile condition that historically precedes violent liquidation moves, and subtracts confidence.

The second factor is alt participation, read from TOTAL3 (the combined market cap of all coins excluding Bitcoin and Ethereum). This is a breadth or fragility gauge. When the broad altcoin market trends with Bitcoin, participation is broad and the move is healthy. When Bitcoin rises while alts fall, the move is narrow and BTC-only, which is fragile. The table labels this relationship directly: CONFIRMING in a bull with alts rising, NARROWING in a bull with alts falling, CAPITULATE in a bear with alts falling, and ROTATING in a bear with alts rising (alts decoupling or leading).

The third factor is Bitcoin dominance (BTC.D). Rising dominance means capital is concentrating into Bitcoin and out of alts, a risk-off posture within crypto. Falling dominance means the market is broadening. Dominance is interpreted so that broadening backs a bull read and concentration fights it.

A neutral status always reports low confidence, because a neutral market has not committed to a direction.

DIVERGENCES

CryptoStatus detects three orthogonal divergence types on the chart symbol at the anchor timeframe. RSI divergence flags momentum failing to confirm a price extreme. ADX-falling exhaustion flags a price extreme made while trend strength is fading. OI divergence flags a price extreme that leveraged positioning is not confirming. When two or more fire within a short window, a confluence shading marks the bar. Each divergence type has its own marker and color so you can read them at a glance.

COMPOSITE SCORE

A 0 to 100 CryptoScore blends the regime, RSI, money flow, and OBV into a single faster read, with ADX acting as a conviction multiplier. It is more granular than the categorical status and often moves ahead of it.

CROSS-TIMEFRAME ALIGNMENT

The table includes a cross-reference row showing the other anchor's status and score. If you are on the Daily anchor it shows the Weekly read, and vice versa. The row tints green when the two timeframes agree on direction and red when they conflict, turning CryptoStatus into a quick multi-timeframe alignment check. Aligned timeframes suggest trend-with-trend conditions; conflicting timeframes suggest a counter-trend move within a larger trend.

EXPORTABLE VALUES

CryptoStatus publishes its Regime, Confidence, and Market Score as hidden data-window plots, so other indicators can subscribe to them via the source input and read the regime from one source of truth.

INPUTS AND DEFAULTS

The anchor defaults to Daily and can be switched to Weekly. The Bitcoin regime symbol, open interest symbol, TOTAL3 symbol, and BTC dominance symbol are all configurable, and every external read is na-safe: if a symbol does not resolve on your data feed, that factor simply contributes nothing rather than breaking the indicator. The ribbon, neutral zone, confirmation buffer, factor thresholds, divergence settings, and score weights are all adjustable.

This tool is designed as a regime and context layer to sit alongside your entry system, not as a standalone buy or sell signal generator.

This indicator is provided for educational and informational purposes only. It is not financial advice. Past performance and historical behavior do not guarantee future results. Trade at your own risk.

TheurgyLabs — Conjured with AI

## Source Code

````pine
// ═══════════════════════════════════════════════════════════════════════════════
// CryptoStatus — Crypto/Bitcoin Daily/Weekly Regime Engine                TheurgyLabs
// ═══════════════════════════════════════════════════════════════════════════════
// Crypto-native sibling of MarketStatus. Regime is read off the D/W anchor from a
// BTC reference ribbon, so the classification is stable across chart timeframes.
//
//   STATUS  — driven ONLY by the BTC regime ribbon (gold/blue/gray → BULL/BEAR/NEUT).
//   CONFIDENCE — modulated by three crypto-native factors, NONE of which veto status:
//       • OI/leverage (primary confirmer, ±20)
//       • Alt participation: TOTAL3 trend vs BTC trend (±breadth wt) — broad vs narrow
//       • BTC dominance trend (±dom wt) — concentration (risk-off) vs broadening (risk-on)
//   DIVERGENCES — RSI (momentum), ADX-falling (trend exhaustion), OI (positioning),
//       detected on the CHART symbol at the anchor TF; confluence line when ≥N align.
//
// Breadth is a FRAGILITY gauge, never a status driver: BTC's regime is BTC's regime,
// but thin alt participation / rising dominance tells you the move is narrow.
// ═══════════════════════════════════════════════════════════════════════════════
//@version=6
indicator("CryptoStatus", "CryptoStat", overlay=true, max_lines_count=100, max_labels_count=200)

// ── ANCHOR ──
string G_ANCHOR = "══ ANCHOR ══"
i_anchor = input.string("Daily", "Regime Anchor", options=["Daily","Weekly"], group=G_ANCHOR, tooltip="Timeframe the regime is read from. Stays fixed regardless of chart TF.")
anchorTF = i_anchor == "Weekly" ? "W" : "D"

// ── SYMBOLS ──
string G_SYM = "══ SYMBOLS ══"
i_btcSym  = input.symbol("INDEX:BTCUSD",            "BTC (regime trend)",  group=G_SYM)
i_oiSym   = input.symbol("BINANCE:BTCUSDT.P_OI",    "BTC Open Interest",   group=G_SYM)
i_t3Sym   = input.symbol("CRYPTOCAP:TOTAL3",        "TOTAL3 (alt cap ex-BTC/ETH)", group=G_SYM, tooltip="Broad altcoin market cap excluding BTC and ETH. Its trend vs BTC's = alt participation. na-safe.")
i_domSym  = input.symbol("CRYPTOCAP:BTC.D",         "BTC Dominance",       group=G_SYM, tooltip="Bitcoin's share of total crypto cap. Rising = capital concentrating in BTC (risk-off within crypto); falling = broadening/alt season (risk-on). na-safe.")

// ── RIBBON (fleet 4-SMMA standard) ──
string G_RIB = "══ RIBBON ══"
i_src     = input.source(hl2, "Ribbon Source", group=G_RIB)
i_fastOut = input.int(8,  "Fast Outer", minval=2, group=G_RIB)
i_fastIn  = input.int(16, "Fast Inner", minval=2, group=G_RIB)
i_slowIn  = input.int(24, "Slow Inner", minval=2, group=G_RIB)
i_slowOut = input.int(32, "Slow Outer", minval=2, group=G_RIB)
i_neutGap = input.float(0.34, "Neutral Zone %", minval=0.05, maxval=2.0, step=0.01, group=G_RIB)

// ── CONFIRMATION FACTOR (OI) ──
string G_FAC = "══ CONFIRMATION FACTOR (OI) ══"
i_oiLen     = input.int(20, "OI Average Length", minval=5, maxval=100, group=G_FAC)
i_oiHealthy = input.float(2.0, "OI Healthy Rise %", minval=0.0, maxval=20.0, step=0.5, group=G_FAC)

// ── ALT PARTICIPATION (TOTAL3 vs BTC) ──
string G_ALT = "══ ALT PARTICIPATION ══"
i_altOn   = input.bool(true, "Alt Participation Modulator", group=G_ALT, tooltip="Fragility gauge on TOTAL3 (alt cap ex-BTC/ETH) trend, read against the BTC regime. Table label: CONFIRMING (bull + alts up = broad/healthy), NARROWING (bull + alts down = BTC-only/fragile), CAPITULATE (bear + alts down = broad risk-off), ROTATING (bear + alts up = alts decoupling/leading). Confirming raises confidence, narrowing/rotating lowers it. Never flips STATUS.")
i_altWt   = input.float(15.0, "Alt Max Confidence Swing", group=G_ALT, minval=0.0, maxval=30.0, step=1.0, tooltip="Most alt-participation can add/subtract from confidence. Kept below the OI factor's ±20.")

// ── DOMINANCE (BTC.D) ──
string G_DOM = "══ DOMINANCE ══"
i_domOn   = input.bool(true, "Dominance Modulator", group=G_DOM, tooltip="Fragility gauge. BTC dominance RISING = capital concentrating in BTC = risk-off within crypto (narrowing). FALLING = broadening/alt season = risk-on. Interpreted so that broadening backs a bull and concentration fights it. Never flips STATUS.")
i_domWt   = input.float(10.0, "Dominance Max Confidence Swing", group=G_DOM, minval=0.0, maxval=30.0, step=1.0, tooltip="Most dominance can add/subtract from confidence. Kept smallest of the three factors.")

// ── CONFIRMATION BUFFER ──
string G_BUF = "══ CONFIRMATION BUFFER ══"
i_confirmBars = input.int(3, "Confirmation Bars", minval=0, maxval=20, group=G_BUF, tooltip="Raw regime must hold this many anchor-TF bars before the displayed status flips. 0 = instant.")

// ── DIVERGENCES ──
string G_DIV = "══ DIVERGENCES ══"
i_divOn     = input.bool(true, "Show Divergences", group=G_DIV)
i_rsiLen    = input.int(14, "RSI Length", minval=2, group=G_DIV)
i_adxLen    = input.int(14, "ADX Length", minval=2, group=G_DIV)
i_divPivL   = input.int(5, "Pivot Left", minval=1, group=G_DIV)
i_divPivR   = input.int(3, "Pivot Right", minval=1, group=G_DIV)
i_divMax    = input.int(60, "Max Lookback (bars)", minval=10, group=G_DIV)
i_confN     = input.int(2, "Confluence: ≥N align", minval=2, maxval=3, group=G_DIV)
i_confWin   = input.int(5, "Confluence Window (bars)", minval=1, group=G_DIV)
i_rsiDivClr = input.color(#FFD700, "RSI Div", group=G_DIV)
i_adxDivClr = input.color(#FF69B4, "ADX Div", group=G_DIV)
i_posDivClr = input.color(#00FFFF, "OI Div", group=G_DIV)

// ── MARKET SCORE ──
string G_SCORE = "══ MARKET SCORE ══"
i_showScore = input.bool(true, "Show Market Score", group=G_SCORE)
i_wRegime   = input.float(1.0, "Weight: Regime", minval=0.0, maxval=3.0, step=0.5, group=G_SCORE)
i_wRSI      = input.float(1.0, "Weight: RSI", minval=0.0, maxval=3.0, step=0.5, group=G_SCORE)
i_wMFI      = input.float(1.0, "Weight: MFI", minval=0.0, maxval=3.0, step=0.5, group=G_SCORE)
i_wOBV      = input.float(1.0, "Weight: OBV", minval=0.0, maxval=3.0, step=0.5, group=G_SCORE)

// ── DISPLAY ──
string G_DISP = "══ DISPLAY ══"
i_showRibbon = input.bool(true, "Show Ribbon", group=G_DISP)
i_showTbl    = input.bool(true, "Show Table", group=G_DISP)
i_tablePos   = input.string("Middle Right", "Table Position", options=["Top Left","Top Center","Top Right","Middle Left","Middle Center","Middle Right","Bottom Left","Bottom Center","Bottom Right"], group=G_DISP)

// Colors (fleet MoneyLine theme — no dim text; labels use cyan via c_dim)
color c_gold = #FFD700, c_blue = #1E90FF, c_gray = #E8E8E8
color c_goldFill = #FFEE33   // brighter, more yellow than gold — used for the bull ribbon FILL only
color c_tblBase=#0d0d1a, c_tblBorder=#333355, c_zebra=#2a2a4a, c_dim=#00FFFF
color c_green=#00FF88, c_red=#FF4444, c_cyan=#00FFFF

// ═══════════════════════════════════════════════════════════════════════════════
// ENGINES (ported byte-faithful from MarketStatus)
// ═══════════════════════════════════════════════════════════════════════════════
smma(float src, int len) =>
    var float val = na
    val := na(val) ? ta.sma(src, len) : (val * (len - 1) + src) / len
    val

f_ribbon() =>
    float v1 = smma(i_src, i_fastOut)
    float m1 = smma(i_src, i_fastIn)
    float m2 = smma(i_src, i_slowIn)
    float v2 = smma(i_src, i_slowOut)
    bool  tangled = (v1 < m1) != (v1 < v2) or (m2 < v2) != (v1 < v2)
    float spr = v2 != 0 ? (v1 - v2) / v2 * 100 : 0.0
    bool  flat = math.abs(spr) < i_neutGap
    bool  bear = not tangled and not flat and v1 < v2
    bool  bull = not tangled and not flat and not bear
    float trend = bull ? 1.0 : bear ? -1.0 : 0.0
    [v1, m1, m2, v2, spr, trend]

// Lightweight trend-only ribbon for reference symbols (TOTAL3, dominance)
f_trendOnly() =>
    float v1 = smma(close, i_fastOut)
    float v2 = smma(close, i_slowOut)
    float spr = v2 != 0 ? (v1 - v2) / v2 * 100 : 0.0
    spr > i_neutGap ? 1.0 : spr < -i_neutGap ? -1.0 : 0.0

f_oi() =>
    float oiAvg = ta.sma(close, i_oiLen)
    oiAvg > 0 ? (close - oiAvg) / oiAvg * 100.0 : 0.0

f_scoreInputs(int rsiLen, int mfiLen, int adxLen) =>
    float rsi = ta.rsi(close, rsiLen)
    float mfi = ta.mfi(hlc3, mfiLen)
    float obvv = ta.obv
    float obvSlope = obvv - obvv[3]
    float obvSd = ta.stdev(obvSlope, 100)
    float vObvSoft = obvSd > 0 ? math.max(-1.0, math.min(1.0, obvSlope / (2.0 * obvSd))) : 0.0
    [dip, dim, adx] = ta.dmi(adxLen, adxLen)
    [rsi, mfi, vObvSoft, adx]

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
    [diPlus, diMinus, adx] = ta.dmi(adxLen, adxLen)
    float ph = ta.pivothigh(high, pL, pR)
    float pl = ta.pivotlow(low, pL, pR)
    var float prevPH = na
    var int phBar = na
    var float prevPL = na
    var int plBar = na
    bool bear = false
    bool bull = false
    bool adxFalling = adx[pR] < adx[pR + 1]
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

f_divAll(int rsiLen, int adxLen, int pL, int pR, int maxBars) =>
    float rsi = ta.rsi(close, rsiLen)
    [rsiBull, rsiBear] = f_oscDiv(rsi, pL, pR, maxBars)
    [adxBull, adxBear] = f_adxExhaust(adxLen, pL, pR, maxBars)
    [rsiBull, rsiBear, adxBull, adxBear]

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

// ═══════════════════════════════════════════════════════════════════════════════
// SECURITY READS
// ═══════════════════════════════════════════════════════════════════════════════
// Visible chart-symbol ribbon (sits on the candles you're viewing)
[v1, m1, m2, v2, spread, ribTrend] = request.security(syminfo.tickerid, anchorTF, f_ribbon(), barmerge.gaps_off, barmerge.lookahead_off)
color ribbonClr = ribTrend > 0.5 ? c_gold : ribTrend < -0.5 ? c_blue : c_gray

// BTC regime ribbon — the broad-market driver (the STATUS)
[rv1, rm1, rm2, rv2, regSpread, btcTrend] = request.security(i_btcSym, anchorTF, f_ribbon(), barmerge.gaps_off, barmerge.lookahead_off)

// OI confirming factor
float oiLoad = request.security(i_oiSym, anchorTF, f_oi(), barmerge.gaps_off, barmerge.lookahead_off)
bool oiAvail = not na(oiLoad)

// Alt participation: TOTAL3 trend, and BTC trend for comparison (BTC trend = btcTrend above)
float t3Trend = i_altOn ? request.security(i_t3Sym, anchorTF, f_trendOnly(), barmerge.gaps_off, barmerge.lookahead_off) : na
// Dominance trend
float domTrend = i_domOn ? request.security(i_domSym, anchorTF, f_trendOnly(), barmerge.gaps_off, barmerge.lookahead_off) : na

// Chart-symbol divergences (RSI + ADX) + score inputs + OI divergence
[rsiBull, rsiBear, adxBull, adxBear] = request.security(syminfo.tickerid, anchorTF, f_divAll(i_rsiLen, i_adxLen, i_divPivL, i_divPivR, i_divMax), barmerge.gaps_off, barmerge.lookahead_off)
[scRsi, scMfi, scVOBV, scAdx] = request.security(syminfo.tickerid, anchorTF, f_scoreInputs(i_rsiLen, 14, i_adxLen), barmerge.gaps_off, barmerge.lookahead_off)

// ── CROSS-TIMEFRAME REFERENCE: compute the OTHER anchor's status + score ──
// Lightweight: just the BTC regime ribbon + chart-symbol score inputs at the other TF.
string otherTF = anchorTF == "D" ? "W" : "D"
string otherTFlbl = anchorTF == "D" ? "Weekly" : "Daily"
[orv1, orm1, orm2, orv2, oRegSpread, oBtcTrend] = request.security(i_btcSym, otherTF, f_ribbon(), barmerge.gaps_off, barmerge.lookahead_off)
[oScRsi, oScMfi, oScVOBV, oScAdx] = request.security(syminfo.tickerid, otherTF, f_scoreInputs(i_rsiLen, 14, i_adxLen), barmerge.gaps_off, barmerge.lookahead_off)
[oiBull, oiBear] = request.security(i_oiSym, anchorTF, f_oiDiv(i_divPivL, i_divPivR, i_divMax), barmerge.gaps_off, barmerge.lookahead_off)

// ═══════════════════════════════════════════════════════════════════════════════
// RAW REGIME + CONFIDENCE (trend LEADS; factors MODULATE confidence, no veto)
// ═══════════════════════════════════════════════════════════════════════════════
float rawRegime = btcTrend > 0.5 ? 1.0 : btcTrend < -0.5 ? -1.0 : 0.0

// Primary confirmer: OI. healthy rise = risk-on; extreme = stress/risk-off.
float conf = 0.0
if oiAvail
    bool healthy = oiLoad >= i_oiHealthy
    bool stress  = oiLoad >= (i_oiHealthy * 4.0)
    conf := stress ? -1.0 : healthy ? 1.0 : 0.0

// Base confidence from ribbon decisiveness
float sprMag = math.min(1.0, math.abs(nz(regSpread)) / (i_neutGap * 4.0))
float baseConf = sprMag * 55.0      // leave headroom for the three factors

// OI alignment (±20, primary)
float confAlign = 0.0
if rawRegime != 0.0 and conf != 0.0
    confAlign := (rawRegime > 0 and conf > 0) or (rawRegime < 0 and conf < 0) ? 1.0 : -1.0

// Alt-participation lean: alts trending up = broad/risk-on (+1); down = narrow (-1)
float altLean = na(t3Trend) ? 0.0 : t3Trend > 0.5 ? 1.0 : t3Trend < -0.5 ? -1.0 : 0.0
float altAlign = 0.0
if rawRegime != 0.0 and altLean != 0.0
    altAlign := (rawRegime > 0 and altLean > 0) or (rawRegime < 0 and altLean < 0) ? 1.0 : -1.0

// Dominance lean: dominance FALLING = broadening/risk-on (+1); RISING = concentration/risk-off (-1)
// (inverse of dominance trend direction)
float domLean = na(domTrend) ? 0.0 : domTrend < -0.5 ? 1.0 : domTrend > 0.5 ? -1.0 : 0.0
float domAlign = 0.0
if rawRegime != 0.0 and domLean != 0.0
    domAlign := (rawRegime > 0 and domLean > 0) or (rawRegime < 0 and domLean < 0) ? 1.0 : -1.0

float confidence = math.round(math.max(0.0, math.min(100.0, baseConf + confAlign * 20.0 + altAlign * i_altWt + domAlign * i_domWt)))
if rawRegime == 0.0
    confidence := math.round(math.min(40.0, sprMag * 40.0))

// ── confirmation buffer ──
var float shownRegime = 0.0
var int   stableCount = 0
var float candidate = 0.0
if rawRegime == shownRegime
    stableCount := 0
else
    if rawRegime == candidate
        stableCount += 1
    else
        candidate := rawRegime
        stableCount := 1
    if stableCount >= i_confirmBars
        shownRegime := candidate
        stableCount := 0
if i_confirmBars == 0
    shownRegime := rawRegime

string regStr = shownRegime > 0.5 ? "BULLISH" : shownRegime < -0.5 ? "BEARISH" : "NEUTRAL"
color regClr = shownRegime > 0.5 ? c_gold : shownRegime < -0.5 ? c_blue : c_gray
bool pending = rawRegime != shownRegime and i_confirmBars > 0
string pendStr = pending ? (str.tostring(stableCount) + "/" + str.tostring(i_confirmBars)) : "—"

// ═══════════════════════════════════════════════════════════════════════════════
// COMPOSITE MARKET SCORE (na-guarded; identical construction to MarketStatus)
// ═══════════════════════════════════════════════════════════════════════════════
float vRegime = shownRegime
float vRSI = na(scRsi) ? 0.0 : math.max(-1.0, math.min(1.0, (scRsi - 50.0) / 25.0))
float vMFI = na(scMfi) ? 0.0 : math.max(-1.0, math.min(1.0, (scMfi - 50.0) / 25.0))
float vOBV = nz(scVOBV)
float wSum = i_wRegime + i_wRSI + i_wMFI + i_wOBV
float dirSum = (vRegime*i_wRegime + vRSI*i_wRSI + vMFI*i_wMFI + vOBV*i_wOBV) / (wSum > 0 ? wSum : 1.0)
float adxConv = 0.5 + math.min(1.0, nz(scAdx) / 50.0)
float marketScoreRaw = 50.0 + nz(dirSum) * 50.0 * nz(adxConv, 1.0)
float marketScore = na(marketScoreRaw) ? 50.0 : math.max(0.0, math.min(100.0, marketScoreRaw))

// Other-TF status + score (no confirmation buffer — it's a raw reference read)
float oRawRegime = oBtcTrend > 0.5 ? 1.0 : oBtcTrend < -0.5 ? -1.0 : 0.0
string oRegStr = oRawRegime > 0.5 ? "BULLISH" : oRawRegime < -0.5 ? "BEARISH" : "NEUTRAL"
color oRegClr = oRawRegime > 0.5 ? c_gold : oRawRegime < -0.5 ? c_blue : c_gray
float oVRSI = na(oScRsi) ? 0.0 : math.max(-1.0, math.min(1.0, (oScRsi - 50.0) / 25.0))
float oVMFI = na(oScMfi) ? 0.0 : math.max(-1.0, math.min(1.0, (oScMfi - 50.0) / 25.0))
float oVOBV = nz(oScVOBV)
float oDirSum = (oRawRegime*i_wRegime + oVRSI*i_wRSI + oVMFI*i_wMFI + oVOBV*i_wOBV) / (wSum > 0 ? wSum : 1.0)
float oAdxConv = 0.5 + math.min(1.0, nz(oScAdx) / 50.0)
float oScoreRaw = 50.0 + nz(oDirSum) * 50.0 * nz(oAdxConv, 1.0)
float oScore = na(oScoreRaw) ? 50.0 : math.max(0.0, math.min(100.0, oScoreRaw))
// Alignment: do the two timeframes agree on direction?
bool tfAligned = (rawRegime > 0.5 and oRawRegime > 0.5) or (rawRegime < -0.5 and oRawRegime < -0.5)
bool tfConflict = (rawRegime > 0.5 and oRawRegime < -0.5) or (rawRegime < -0.5 and oRawRegime > 0.5)
string scoreLabel = marketScore >= 65 ? "BULLISH" : marketScore >= 55 ? "LEAN BULL" : marketScore > 45 ? "NEUTRAL" : marketScore > 35 ? "LEAN BEAR" : "BEARISH"
color scoreClr = marketScore >= 55 ? c_green : marketScore > 45 ? c_gold : c_red

// ── EXPORTABLE VALUES (data_window only; draw nothing) ──
plot(shownRegime, "Regime",       color=color.new(color.white, 100), display=display.data_window)
plot(confidence,  "Confidence",   color=color.new(color.white, 100), display=display.data_window)
plot(marketScore, "Market Score", color=color.new(color.white, 100), display=display.data_window)

// ═══════════════════════════════════════════════════════════════════════════════
// VISIBLE RIBBON (chart symbol)
// ═══════════════════════════════════════════════════════════════════════════════
int ribLineTransp = ribTrend == 0.0 ? 55 : 20
p1 = plot(i_showRibbon ? v1[1] : na, "Ribbon Fast Out", color=color.new(ribbonClr, ribLineTransp))
p2 = plot(i_showRibbon ? v2[1] : na, "Ribbon Slow Out", color=color.new(ribbonClr, ribLineTransp))
color fillClr = ribTrend > 0.5 ? c_goldFill : ribTrend < -0.5 ? c_blue : c_gray
int ribFillTransp = ribTrend == 0.0 ? 90 : 70
fill(p1, p2, color=color.new(fillClr, ribFillTransp))

// ═══════════════════════════════════════════════════════════════════════════════
// DIVERGENCE MARKERS + CONFLUENCE (chart symbol)
// ═══════════════════════════════════════════════════════════════════════════════
plotshape(i_divOn and rsiBull ? low[i_divPivR]  : na, "RSI Bull", shape.triangleup,   location.absolute, color.new(i_rsiDivClr, 0), size=size.small, offset=-i_divPivR)
plotshape(i_divOn and rsiBear ? high[i_divPivR] : na, "RSI Bear", shape.triangledown, location.absolute, color.new(i_rsiDivClr, 0), size=size.small, offset=-i_divPivR)
plotshape(i_divOn and adxBull ? low[i_divPivR]  : na, "ADX Bull", shape.xcross, location.absolute, color.new(i_adxDivClr, 0), size=size.small, offset=-i_divPivR)
plotshape(i_divOn and adxBear ? high[i_divPivR] : na, "ADX Bear", shape.xcross, location.absolute, color.new(i_adxDivClr, 0), size=size.small, offset=-i_divPivR)
plotshape(i_divOn and oiBull ? low[i_divPivR]  : na, "OI Bull", shape.diamond, location.absolute, color.new(i_posDivClr, 0), size=size.small, offset=-i_divPivR)
plotshape(i_divOn and oiBear ? high[i_divPivR] : na, "OI Bear", shape.diamond, location.absolute, color.new(i_posDivClr, 0), size=size.small, offset=-i_divPivR)

// Confluence: ≥N bull or bear divergences within a short window (proven f_recent pattern)
f_recent(bool b, int win) =>
    bool hit = false
    for i = 0 to win - 1
        if b[i]
            hit := true
    hit
int bullCluster = (f_recent(rsiBull, i_confWin) ? 1 : 0) + (f_recent(adxBull, i_confWin) ? 1 : 0) + (f_recent(oiBull, i_confWin) ? 1 : 0)
int bearCluster = (f_recent(rsiBear, i_confWin) ? 1 : 0) + (f_recent(adxBear, i_confWin) ? 1 : 0) + (f_recent(oiBear, i_confWin) ? 1 : 0)
bool confBull = i_divOn and bullCluster >= i_confN and (rsiBull or adxBull or oiBull)
bool confBear = i_divOn and bearCluster >= i_confN and (rsiBear or adxBear or oiBear)
bgcolor(confBull ? color.new(c_green, 50) : confBear ? color.new(c_red, 50) : na, title="Confluence")

alertcondition(confBull, "Bull Confluence", "CryptoStatus: bullish divergence confluence")
alertcondition(confBear, "Bear Confluence", "CryptoStatus: bearish divergence confluence")
alertcondition(shownRegime > 0.5 and shownRegime[1] <= 0.5, "Regime → Bull", "CryptoStatus: regime turned BULLISH")
alertcondition(shownRegime < -0.5 and shownRegime[1] >= -0.5, "Regime → Bear", "CryptoStatus: regime turned BEARISH")

// ═══════════════════════════════════════════════════════════════════════════════
// STATUS TABLE
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
        => position.middle_right

var table tbl = table.new(position.top_right, 2, 15, bgcolor=c_tblBase, border_color=c_tblBorder, border_width=1, frame_color=c_tblBorder, frame_width=1)
table.set_position(tbl, f_tblPos(i_tablePos))
if i_showTbl and barstate.islast
    ts = size.small
    table.cell(tbl, 0, 0, "CRYPTO STATUS", bgcolor=c_zebra, text_color=c_gold, text_size=ts, text_halign=text.align_left)
    table.cell(tbl, 1, 0, "BTC " + anchorTF, bgcolor=c_zebra, text_color=c_gold, text_size=ts, text_halign=text.align_center)
    table.cell(tbl, 0, 1, "STATUS", bgcolor=c_tblBase, text_color=c_dim, text_size=ts, text_halign=text.align_left)
    table.cell(tbl, 1, 1, regStr, bgcolor=c_tblBase, text_color=regClr, text_size=ts, text_halign=text.align_center)
    table.cell(tbl, 0, 2, "Confidence", bgcolor=c_tblBase, text_color=c_dim, text_size=ts, text_halign=text.align_left)
    table.cell(tbl, 1, 2, str.tostring(confidence, "#") + "%", bgcolor=c_tblBase, text_color=confidence >= 66 ? c_green : confidence >= 33 ? c_gold : c_dim, text_size=ts, text_halign=text.align_center)
    // cross-timeframe reference: the OTHER anchor's status + score. Background tints
    // green when the two TFs agree on direction, red when they conflict.
    color xtfBg = tfAligned ? color.new(c_green, 70) : tfConflict ? color.new(c_red, 70) : c_tblBase
    table.cell(tbl, 0, 14, otherTFlbl, bgcolor=xtfBg, text_color=c_dim, text_size=ts, text_halign=text.align_left)
    table.cell(tbl, 1, 14, oRegStr + " " + str.tostring(oScore, "#"), bgcolor=xtfBg, text_color=oRegClr, text_size=ts, text_halign=text.align_center)
    table.cell(tbl, 0, 4, "Confirm (OI)", bgcolor=c_tblBase, text_color=c_dim, text_size=ts, text_halign=text.align_left)
    table.cell(tbl, 1, 4, oiAvail ? (conf > 0 ? "RISK-ON" : conf < 0 ? "STRESS" : "NEUTRAL") : "N/A", bgcolor=c_tblBase, text_color=conf > 0 ? c_green : conf < 0 ? c_red : c_dim, text_size=ts, text_halign=text.align_center)
    table.cell(tbl, 0, 5, "Pending Flip", bgcolor=c_tblBase, text_color=c_dim, text_size=ts, text_halign=text.align_left)
    table.cell(tbl, 1, 5, pendStr, bgcolor=c_tblBase, text_color=c_dim, text_size=ts, text_halign=text.align_center)
    table.cell(tbl, 0, 6, "Ribbon", bgcolor=c_tblBase, text_color=c_dim, text_size=ts, text_halign=text.align_left)
    table.cell(tbl, 1, 6, ribTrend > 0.5 ? "UP" : ribTrend < -0.5 ? "DOWN" : "FLAT", bgcolor=c_tblBase, text_color=ribbonClr, text_size=ts, text_halign=text.align_center)
    table.cell(tbl, 0, 7, "Spread", bgcolor=c_tblBase, text_color=c_dim, text_size=ts, text_halign=text.align_left)
    table.cell(tbl, 1, 7, str.tostring(spread, "#.##") + "%", bgcolor=c_tblBase, text_color=c_dim, text_size=ts, text_halign=text.align_center)
    table.cell(tbl, 0, 8, "OI Load", bgcolor=c_tblBase, text_color=c_dim, text_size=ts, text_halign=text.align_left)
    table.cell(tbl, 1, 8, oiAvail ? str.tostring(oiLoad, "#.#") + "%" : "N/A", bgcolor=c_tblBase, text_color=c_cyan, text_size=ts, text_halign=text.align_center)
    // alt participation
    table.cell(tbl, 0, 9, "Alt Partic.", bgcolor=c_tblBase, text_color=c_dim, text_size=ts, text_halign=text.align_left)
    // Relationship-aware label: what the alt move MEANS given the BTC regime.
    //   bull + alts up   → CONFIRMING (broad, healthy)        → green
    //   bull + alts down → NARROWING  (BTC-only, fragile)     → amber warning
    //   bear + alts down → CAPITULATE (broad risk-off)        → red
    //   bear + alts up   → ROTATING   (alts decoupling/leading)→ amber warning
    //   neutral regime or flat alts → directional fallback (ALTS UP/DOWN/FLAT)
    string altStr = na(t3Trend) ? "—" : rawRegime > 0.5 ? (altLean > 0 ? "CONFIRMING" : altLean < 0 ? "NARROWING" : "FLAT") : rawRegime < -0.5 ? (altLean < 0 ? "CAPITULATE" : altLean > 0 ? "ROTATING" : "FLAT") : (altLean > 0 ? "ALTS UP" : altLean < 0 ? "ALTS DOWN" : "FLAT")
    color altClr = na(t3Trend) ? c_dim : altAlign > 0 ? c_green : altAlign < 0 ? c_gold : (altLean > 0 ? c_green : altLean < 0 ? c_red : c_dim)
    table.cell(tbl, 1, 9, altStr, bgcolor=c_tblBase, text_color=altClr, text_size=ts, text_halign=text.align_center)
    // dominance
    table.cell(tbl, 0, 10, "BTC.D", bgcolor=c_tblBase, text_color=c_dim, text_size=ts, text_halign=text.align_left)
    string domStr = na(domTrend) ? "—" : domTrend > 0.5 ? "RISING" : domTrend < -0.5 ? "FALLING" : "FLAT"
    table.cell(tbl, 1, 10, domStr, bgcolor=c_tblBase, text_color=domTrend > 0.5 ? c_red : domTrend < -0.5 ? c_green : c_gold, text_size=ts, text_halign=text.align_center)
    // div key
    // div key — each marker in its own cell so its color is correct (one color per cell)
    table.cell(tbl, 0, 11, "DIV KEY", bgcolor=c_zebra, text_color=c_gold, text_size=ts, text_halign=text.align_left)
    table.cell(tbl, 1, 11, i_divOn ? "on" : "off", bgcolor=c_zebra, text_color=i_divOn ? c_green : c_dim, text_size=ts, text_halign=text.align_center)
    table.cell(tbl, 0, 12, "▲▼ RSI", bgcolor=c_tblBase, text_color=i_rsiDivClr, text_size=ts, text_halign=text.align_left)
    table.cell(tbl, 1, 12, "✕ ADX", bgcolor=c_tblBase, text_color=i_adxDivClr, text_size=ts, text_halign=text.align_center)
    table.cell(tbl, 0, 13, "◆ OI", bgcolor=c_tblBase, text_color=i_posDivClr, text_size=ts, text_halign=text.align_left)
    table.cell(tbl, 1, 13, "Positioning", bgcolor=c_tblBase, text_color=c_dim, text_size=ts, text_halign=text.align_center)
    // score
    if i_showScore
        table.cell(tbl, 0, 3, "SCORE", bgcolor=c_zebra, text_color=c_gold, text_size=ts, text_halign=text.align_left)
        table.cell(tbl, 1, 3, str.tostring(marketScore, "#") + " " + scoreLabel, bgcolor=c_zebra, text_color=scoreClr, text_size=ts, text_halign=text.align_center)
````
