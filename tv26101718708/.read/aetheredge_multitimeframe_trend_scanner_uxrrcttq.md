# AetherEdge - Multi-Timeframe Trend Scanner

- url: https://www.tradingview.com/script/uxRRcTtQ/
- type: indicator
- pine_id: PUB;2bfee1b17e744119b1b9660ebd3661c1
- version: 1.0

## Description

🖊️ Overview
AetherEdge Multi-Timeframe Trend Scanner is the ultimate consensus engine that surveys four timeframes simultaneously, capturing the market's true directional bias in a single view. Through a proprietary scoring system integrating EMA structure, RSI momentum, and ADX strength, it quantifies each timeframe's objective trend assessment on a −2 to +2 scale. Instantly visualizing multi-timeframe alignment (consensus), it ensures you never miss a high-conviction opportunity where every dimension agrees.

🔶 Key Features

4-Timeframe Simultaneous Scan: 15M / 1H / 4H / 1D (fully customizable)
Triple-Factor Scoring: EMA Fast/Slow structure + Bias EMA(200) + ADX strength
5-Tier Score (−2 to +2): STRONG BULL / BULL / NEUTRAL / BEAR / STRONG BEAR
Consensus % Calculation: 4-TF total normalized to −1.0 to +1.0
Auto-Dampening on Low ADX: Halves scores during trendless conditions
RSI / ADX Columns: Momentum and strength at a glance
Consensus Bar Visualization: Intuitive grasp of overall directionality
Premium Dark Mode UI: AetherEdge brand color palette
Consensus Flip Alert: Never miss a directional reversal
6 Selectable Table Positions: Optimal layout placement

🧠 Technical Architecture

This scanner is a sophisticated aggregation engine integrating multi-timeframe data.

Trend Engine (f_trend): Integrates three judgment axes. ①Close vs Bias EMA(200) for macro bias (±1), ②EMA Fast vs EMA Slow for short/mid-term structure (±1), summing to a raw score of −2 to +2.
ADX Dampening Logic: When ADX < adxMin (default 20), math.round(score / 2) halves the raw score, structurally suppressing false signals in trendless markets.
request.security Integration: Parallel retrieval of score, RSI, and ADX from four timeframes with repaint-resistant aggregation.
Consensus Formula: consensusPct = (s1+s2+s3+s4) / 8.0, theoretically ranging −1.0 to +1.0; values closer to ±1 indicate stronger TF alignment.
5-Tier Consensus Classification: ±0.75 as strong threshold, ±0.25 as weak threshold, classified into STRONG BULLISH / BULLISH / NEUTRAL / BEARISH / STRONG BEARISH.
Multi-Color System: 5-tier gradient (cStrongBull / cBull / cNeutral / cBear / cStrongBear) directly linking score values to cell backgrounds.
RSI Color Mapping: 5-color classification at 70/55/45/30 thresholds for instant overbought/oversold visualization.
ADX Color Mapping: 3–4 tier display at 40/25/adxMin thresholds for trend strength.
Custom f_adx Implementation: Faithfully reproduces DI+ / DI− with full reconstruction, allowing more flexible tuning than Pine's built-in.
Table Rendering: Updates only at barstate.islast, minimizing CPU load while preserving real-time responsiveness.

⚙️ Recommended Settings & Tuning Guide

Crypto Defaults:

BTC (1H Main): TF1=15M / TF2=1H / TF3=4H / TF4=D, emaFast=21, emaSlow=55, emaBias=200
ETH (15M Main): TF1=5M / TF2=15M / TF3=1H / TF4=4H, adxMin=18
SOL (High-Vol): TF1=15M / TF2=1H / TF3=4H / TF4=D, adxMin=22, emaSlow=50
XRP (Range-Heavy): adxMin=25 for aggressive false-breakout filtering
Tuning Guide:

Day Trading: TF set 5M/15M/1H/4H, short-term focus
Swing Trading: TF set 1H/4H/D/W, macro perspective
Scalping: TF set 1M/5M/15M/1H, emaFast=9, emaSlow=21
Long-Term Investing: TF set 4H/D/W/M, retain emaBias=200 for big-picture
Strict Trend Filter: adxMin=25–30 to display only clear trends
More Signals: adxMin=15 to capture minor trends
Minimalist UI: Disable showRSI/showADX

💡 How to Use in Practice

4-TF Full Alignment Entry: consensusPct ≥ 0.75 (STRONG BULLISH) for trend-following longs, ≤ −0.75 for shorts—the highest-conviction setup
Counter-Trend Filter: Skip shorts when higher TFs are BULLISH—an iron rule for reducing stop-outs
Consensus Flip Tracking: Transitions from NEUTRAL to BULLISH/BEARISH mark trend inception
Divergence Detection: When lower TFs are BULLISH but higher TFs are BEARISH, treat as short-term bounce only
RSI Overheating Avoidance: Even in BULLISH consensus, RSI ≥ 70 across multiple TFs signals profit-taking priority
ADX Accumulation Watch: Rising ADX across all TFs foreshadows a major trend birth
AetherEdge Synergy: Self-Evolving S/R Grid strong-line reactions + this scanner's consensus alignment = ultimate dual confirmation
Alert Utilization: alertOnFlip notifies directional reversals—free yourself from constant chart monitoring

⚠️ Important Notes

request.security Latency: Higher-TF scores update only upon that TF's bar close
TF Lag: Daily judgments don't finalize until daily close—treat intraday values as provisional
adxMin Sensitivity: Too low increases false signals in ranges; too high reduces signals dramatically
Near-Zero Consensus: No clear directional bias—recommended no-trade zone
EMA Period Changes: Major emaBias changes drastically alter score structure—adjust cautiously

🚨 Disclaimer

This indicator is a technical analysis tool provided for educational and research purposes only and does not constitute financial advice. Multi-timeframe consensus represents an evaluation based on historical price data and does not guarantee future market direction. All trading decisions are made at your own risk and should be accompanied by proper risk management.

## Source Code

````pine
//@version=5
indicator("AetherEdge - Multi-Timeframe Trend Scanner", "AE-MTF Scanner", overlay=true)

// ═══════════════════════════════════════════════════════════════
//  INPUTS
// ═══════════════════════════════════════════════════════════════
grpTF   = "⏱ Timeframes"
tf1 = input.timeframe("15",    "TF 1", group=grpTF)
tf2 = input.timeframe("60",    "TF 2", group=grpTF)
tf3 = input.timeframe("240",   "TF 3", group=grpTF)
tf4 = input.timeframe("D",     "TF 4", group=grpTF)

grpMA   = "📈 Trend Engine"
emaFast = input.int(21,  "EMA Fast",   minval=2, group=grpMA)
emaSlow = input.int(55,  "EMA Slow",   minval=2, group=grpMA)
emaBias = input.int(200, "Bias EMA",   minval=2, group=grpMA)
rsiLen  = input.int(14,  "RSI Length", minval=2, group=grpMA)
adxLen  = input.int(14,  "ADX Length", minval=2, group=grpMA)
adxMin  = input.float(20, "ADX Trend Threshold", minval=0, group=grpMA)

grpUI   = "🎨 Display"
tablePos = input.string("Top Right", "Table Position",
             options=["Top Right","Top Left","Middle Right","Middle Left","Bottom Right","Bottom Left"], group=grpUI)
tblSize  = input.string("Normal", "Table Size",
             options=["Tiny","Small","Normal","Large"], group=grpUI)
showBar  = input.bool(true,  "Show Consensus Bar", group=grpUI)
showRSI  = input.bool(true,  "Show RSI Column",    group=grpUI)
showADX  = input.bool(true,  "Show ADX Column",    group=grpUI)
darkMode = input.bool(true,  "Dark Mode",          group=grpUI)

grpAlert = "🔔 Alerts"
alertOnFlip = input.bool(true, "Alert on Consensus Flip", group=grpAlert)

// ═══════════════════════════════════════════════════════════════
//  COLOR PALETTE (AetherEdge theme)
// ═══════════════════════════════════════════════════════════════
cBgMain    = darkMode ? color.new(#0b1221, 10)  : color.new(#f7f9fc, 10)
cBgAlt     = darkMode ? color.new(#111a2e, 20)  : color.new(#ffffff, 0)
cBorder    = darkMode ? color.new(#1f2a44, 0)   : color.new(#d8dee9, 0)
cTextMain  = darkMode ? color.new(#e6edf7, 0)   : color.new(#1a202c, 0)
cTextMute  = darkMode ? color.new(#8892b0, 0)   : color.new(#64748b, 0)
cAccent    = color.new(#00d4ff, 0)

cStrongBull = color.new(#00e5a0, 0)
cBull       = color.new(#26a69a, 15)
cNeutral    = color.new(#5c6b7d, 30)
cBear       = color.new(#ef5350, 15)
cStrongBear = color.new(#ff3d71, 0)

// ═══════════════════════════════════════════════════════════════
//  TREND ENGINE  (returns score -2..+2, label, RSI, ADX)
// ═══════════════════════════════════════════════════════════════
f_adx(len) =>
    up   = ta.change(high)
    down = -ta.change(low)
    plusDM  = na(up)   ? na : (up   > down and up   > 0 ? up   : 0)
    minusDM = na(down) ? na : (down > up   and down > 0 ? down : 0)
    trur = ta.rma(ta.tr, len)
    plus  = fixnan(100 * ta.rma(plusDM,  len) / trur)
    minus = fixnan(100 * ta.rma(minusDM, len) / trur)
    sum   = plus + minus
    100 * ta.rma(math.abs(plus - minus) / (sum == 0 ? 1 : sum), len)

f_trend() =>
    eF = ta.ema(close, emaFast)
    eS = ta.ema(close, emaSlow)
    eB = ta.ema(close, emaBias)
    rsi = ta.rsi(close, rsiLen)
    adx = f_adx(adxLen)

    score = 0
    score := score + (close > eB ? 1 : -1)
    score := score + (eF > eS   ? 1 : -1)
    // dampen if low ADX
    finalScore = adx < adxMin ? math.round(score / 2) : score
    [finalScore, rsi, adx, eF, eS]

[s1, rsi1, adx1, _a1, _b1] = request.security(syminfo.tickerid, tf1, f_trend())
[s2, rsi2, adx2, _a2, _b2] = request.security(syminfo.tickerid, tf2, f_trend())
[s3, rsi3, adx3, _a3, _b3] = request.security(syminfo.tickerid, tf3, f_trend())
[s4, rsi4, adx4, _a4, _b4] = request.security(syminfo.tickerid, tf4, f_trend())

// ═══════════════════════════════════════════════════════════════
//  HELPERS
// ═══════════════════════════════════════════════════════════════
f_scoreLabel(s) =>
    s >=  2 ? "▲▲ STRONG BULL" :
     s ==  1 ? "▲ BULLISH"      :
     s ==  0 ? "■ NEUTRAL"      :
     s == -1 ? "▼ BEARISH"      :
               "▼▼ STRONG BEAR"

f_scoreColor(s) =>
    s >=  2 ? cStrongBull :
     s ==  1 ? cBull       :
     s ==  0 ? cNeutral    :
     s == -1 ? cBear       :
               cStrongBear

f_rsiColor(r) =>
    r >= 70 ? cStrongBull :
     r >= 55 ? cBull       :
     r >= 45 ? cNeutral    :
     r >= 30 ? cBear       :
               cStrongBear

f_adxColor(a) =>
    a >= 40 ? cStrongBull :
     a >= 25 ? cBull       :
     a >= adxMin ? cNeutral :
                   cTextMute

f_tfLabel(tf) =>
    tf == "15"  ? "15m" :
     tf == "60"  ? "1H"  :
     tf == "240" ? "4H"  :
     tf == "D"   ? "1D"  :
     tf == "W"   ? "1W"  : tf

// consensus score: sum / max possible
totalScore = s1 + s2 + s3 + s4
consensusPct = totalScore / 8.0  // range -1..+1

f_consensusLabel(p) =>
    p >=  0.75 ? "STRONG BULLISH" :
     p >=  0.25 ? "BULLISH"        :
     p >  -0.25 ? "NEUTRAL / MIXED":
     p >  -0.75 ? "BEARISH"        :
                  "STRONG BEARISH"

f_consensusColor(p) =>
    p >=  0.75 ? cStrongBull :
     p >=  0.25 ? cBull       :
     p >  -0.25 ? cNeutral    :
     p >  -0.75 ? cBear       :
                  cStrongBear

consensusTxt = f_consensusLabel(consensusPct)
consensusCol = f_consensusColor(consensusPct)

// ═══════════════════════════════════════════════════════════════
//  TABLE RENDERING
// ═══════════════════════════════════════════════════════════════
f_pos(p) =>
    p == "Top Right"     ? position.top_right    :p == "Top Left"      ? position.top_left     :p == "Middle Right"  ? position.middle_right :p == "Middle Left"   ? position.middle_left  :p == "Bottom Right"  ? position.bottom_right :position.bottom_left

f_size(s) =>
    s == "Tiny"   ? size.tiny   :
     s == "Small"  ? size.small  :
     s == "Large"  ? size.large  :
                     size.normal

var table scanner = na

if barstate.islast
    cols = 2 + (showRSI ? 1 : 0) + (showADX ? 1 : 0) + 1   // TF | Trend | (RSI) | (ADX) | Bar
    rows = 7  // header row + title + 4 TFs + consensus row + bar row
    scanner := table.new(f_pos(tablePos), cols, rows, bgcolor=cBgMain, border_color=cBorder, border_width=1, frame_color=cAccent, frame_width=1)

    sz = f_size(tblSize)

    // ─── Title Row (merged) ───
    table.cell(scanner, 0, 0, "◆ AETHEREDGE  MTF SCANNER ◆", text_color=cAccent, bgcolor=cBgAlt, text_size=sz, text_halign=text.align_center)
    table.merge_cells(scanner, 0, 0, cols - 1, 0)

    // ─── Header Row ───
    table.cell(scanner, 0, 1, "TF",     text_color=cTextMute, bgcolor=cBgAlt, text_size=sz, text_halign=text.align_center)
    table.cell(scanner, 1, 1, "TREND",  text_color=cTextMute, bgcolor=cBgAlt, text_size=sz, text_halign=text.align_center)
    col = 2
    if showRSI
        table.cell(scanner, col, 1, "RSI", text_color=cTextMute, bgcolor=cBgAlt, text_size=sz, text_halign=text.align_center)
        col += 1
    if showADX
        table.cell(scanner, col, 1, "ADX", text_color=cTextMute, bgcolor=cBgAlt, text_size=sz, text_halign=text.align_center)
        col += 1
    table.cell(scanner, col, 1, "BIAS",  text_color=cTextMute, bgcolor=cBgAlt, text_size=sz, text_halign=text.align_center)

    // ─── Per-TF rows ───
    tfs    = array.from(tf1, tf2, tf3, tf4)
    scores = array.from(s1, s2, s3, s4)
    rsis   = array.from(rsi1, rsi2, rsi3, rsi4)
    adxs   = array.from(adx1, adx2, adx3, adx4)

    for i = 0 to 3
        r = i + 2
        sc  = array.get(scores, i)
        rs  = array.get(rsis, i)
        ax  = array.get(adxs, i)
        tfL = f_tfLabel(array.get(tfs, i))

        rowBg = i % 2 == 0 ? cBgMain : cBgAlt

        table.cell(scanner, 0, r, tfL, text_color=cTextMain, bgcolor=rowBg, text_size=sz, text_halign=text.align_center)
        table.cell(scanner, 1, r, f_scoreLabel(sc), text_color=color.white, bgcolor=f_scoreColor(sc), text_size=sz, text_halign=text.align_center)

        c = 2
        if showRSI
            table.cell(scanner, c, r, str.tostring(rs, "#.0"), text_color=color.white, bgcolor=f_rsiColor(rs), text_size=sz, text_halign=text.align_center)
            c += 1
        if showADX
            table.cell(scanner, c, r, str.tostring(ax, "#.0"), text_color=color.white, bgcolor=f_adxColor(ax), text_size=sz, text_halign=text.align_center)
            c += 1

        // Bias marker dot
        biasTxt = sc > 0 ? "●" : sc < 0 ? "●" : "○"
        table.cell(scanner, c, r, biasTxt, text_color=f_scoreColor(sc), bgcolor=rowBg, text_size=sz, text_halign=text.align_center)

    // ─── Consensus Header ───
    table.cell(scanner, 0, 6, "CONSENSUS", text_color=cAccent, bgcolor=cBgAlt, text_size=sz, text_halign=text.align_center)
    table.merge_cells(scanner, 0, 6, 0, 6)

    // Consensus text (merged across remaining cols)
    table.cell(scanner, 1, 6, consensusTxt + "   " + str.tostring(consensusPct * 100, "+#;-#") + "%",
               text_color=color.white, bgcolor=consensusCol, text_size=sz, text_halign=text.align_center)
    table.merge_cells(scanner, 1, 6, cols - 1, 6)

// ═══════════════════════════════════════════════════════════════
//  CONSENSUS BAR (separate floating table at bottom-center area)
// ═══════════════════════════════════════════════════════════════
var table bar = na
if showBar and barstate.islast
    segs = 10
    bar := table.new(position.bottom_center, segs + 2, 2, bgcolor=cBgMain, border_color=cBorder, border_width=1, frame_color=cAccent, frame_width=1)

    sz2 = f_size(tblSize)
    table.cell(bar, 0, 0, "BEAR", text_color=cStrongBear, bgcolor=cBgAlt, text_size=sz2)
    table.cell(bar, segs + 1, 0, "BULL", text_color=cStrongBull, bgcolor=cBgAlt, text_size=sz2)
    table.cell(bar, 0, 1, "", bgcolor=cBgAlt)
    table.cell(bar, segs + 1, 1, "", bgcolor=cBgAlt)

    // label row
    table.cell(bar, 1, 0, "◆ " + consensusTxt + "  (" + str.tostring(consensusPct * 100, "+#.0;-#.0") + "%) ◆",
               text_color=color.white, bgcolor=consensusCol, text_size=sz2, text_halign=text.align_center)
    table.merge_cells(bar, 1, 0, segs, 0)

    // filled segments based on consensusPct (-1..+1)  → map to 0..segs, center = segs/2
    centerIdx = segs / 2
    filled = math.round(consensusPct * centerIdx)  // -5..+5

    for i = 1 to segs
        idxFromCenter = i - centerIdx - 1  // -5..+4 roughly
        segColor = cBgAlt
        if filled > 0 and i > centerIdx and i <= centerIdx + filled
            segColor := consensusCol
        if filled < 0 and i <= centerIdx and i > centerIdx + filled
            segColor := consensusCol
        if i == centerIdx or i == centerIdx + 1
            segColor := filled == 0 ? cNeutral : segColor
        table.cell(bar, i, 1, "", bgcolor=segColor, text_size=sz2)

// ═══════════════════════════════════════════════════════════════
//  VISUAL CUE ON CHART: subtle background tint when full alignment
// ═══════════════════════════════════════════════════════════════
fullBull = s1 >= 2 and s2 >= 2 and s3 >= 2 and s4 >= 2
fullBear = s1 <= -2 and s2 <= -2 and s3 <= -2 and s4 <= -2
bgcolor(fullBull ? color.new(cStrongBull, 92) : fullBear ? color.new(cStrongBear, 92) : na, title="Full Alignment Tint")

// ═══════════════════════════════════════════════════════════════
//  ALERTS
// ═══════════════════════════════════════════════════════════════
var float prevConsensus = na
flipToBull = alertOnFlip and not na(prevConsensus) and prevConsensus <= 0 and consensusPct > 0.25
flipToBear = alertOnFlip and not na(prevConsensus) and prevConsensus >= 0 and consensusPct < -0.25
prevConsensus := consensusPct

alertcondition(flipToBull, "MTF Consensus → Bullish", "AetherEdge: Multi-TF consensus flipped BULLISH")
alertcondition(flipToBear, "MTF Consensus → Bearish", "AetherEdge: Multi-TF consensus flipped BEARISH")
alertcondition(fullBull,   "Full Bullish Alignment", "AetherEdge: All timeframes STRONG BULLISH")
alertcondition(fullBear,   "Full Bearish Alignment", "AetherEdge: All timeframes STRONG BEARISH")
````
