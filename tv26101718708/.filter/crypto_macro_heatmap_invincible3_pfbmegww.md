# Crypto: Macro Heatmap [invincible3]

- url: https://www.tradingview.com/script/PFbmeGww-Crypto-Macro-Heatmap-invincible3/
- type: indicator
- pine_id: PUB;00fa7ba561cd442188afd218595b5712
- version: 2.0

## Description

Crypto Macro Heatmap is an automatic market-regime dashboard designed to summarize crypto macro conditions using liquidity, leverage, breadth, and risk-participation metrics.

The indicator converts multiple market data sources into normalized 0–100 scores and displays them in a structured heatmap table. It is built to help traders quickly understand whether the broader crypto environment is risk-on, neutral, or risk-off.

[b]Main dashboard sections:[/b]

1. Liquidity
   Tracks Global M2, total crypto market cap, USDT dominance, and BTC volume confirmation. Higher liquidity scores generally suggest stronger macro support for crypto markets.

2. Leverage
   Tracks open interest pressure, funding-risk proxy, liquidation-risk proxy, and OI acceleration. Higher leverage scores mean higher stress or crowding risk.

3. Breadth
   Tracks TOTAL2, TOTAL3, BTC dominance, ETH dominance, and altcoin participation. This section helps identify whether market strength is broad or concentrated.

[b]Key features:[/b]

* Fully automatic scoring
* No manual market-score inputs
* Dashboard show/hide checkbox
* Light/dark chart theme detection
* Composite regime score
* Regime meter
* Market phase detection
* Risk-state classification
* Confidence score
* Section delta versus 7 days ago
* Fixed-width heatmap layout for cleaner visual alignment

The composite score combines liquidity support, market breadth, and leverage-adjusted risk into one regime reading. The dashboard is intended for macro context and regime analysis, not direct buy or sell signals.

Use this tool as a higher-timeframe market filter together with your own technical analysis, risk management, and trading system.

[b]Disclaimer: [/b]This indicator is for educational and analytical purposes only. It does not provide financial advice. Always do your own research and manage risk carefully.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © invincible3

//@version=6
indicator(
     "Crypto: Macro Heatmap [invincible3]",
     shorttitle = "CrypMacro",
     overlay = true,
     max_labels_count = 500
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// AUTO DATA SOURCES / FIXED SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
const string m2Sym      = "ECONOMICS:USM2"
const string totalSym   = "CRYPTOCAP:TOTAL"
const string usdtDSym   = "CRYPTOCAP:USDT.D"
const string volumeSym  = "BINANCE:BTCUSDT"

const string oiSym      = "BINANCE:BTCUSDT.P_OI"
const string fundSym    = "BINANCE:BTCUSDT.P"

const string total2Sym  = "CRYPTOCAP:TOTAL2"
const string total3Sym  = "CRYPTOCAP:TOTAL3"
const string btcDSym    = "CRYPTOCAP:BTC.D"
const string ethDSym    = "CRYPTOCAP:ETH.D"

const bool  useAutoFunding    = true
const bool  fundingIsDecimal  = true
const float fundingExtremePct = 0.10

const float sensCrypto = 1.00
const float sensMacro  = 3.00
const float sensOI     = 1.00

const float m2Fallback     = 50.0
const float totalFallback  = 50.0
const float usdtFallback   = 50.0
const float volumeFallback = 50.0

const float oiFallback   = 50.0
const float fundFallback = 50.0

const float total2Fallback = 50.0
const float total3Fallback = 50.0
const float btcDFallback   = 50.0
const float ethDFallback   = 50.0
const float altFallback    = 50.0

showDashboard = input.bool(true, "Show Dashboard Table")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// COLORS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

float chartLuma = color.r(chart.bg_color) * 0.299 + color.g(chart.bg_color) * 0.587 + color.b(chart.bg_color) * 0.114
bool isLightTheme = chartLuma > 128

color bgMain   = isLightTheme ? color.rgb(255, 255, 255, 0)  : color.rgb(18, 18, 20, 5)
color bgPanel  = isLightTheme ? color.rgb(243, 244, 246, 0)  : color.rgb(24, 24, 27, 8)
color bgPanel2 = isLightTheme ? color.rgb(229, 231, 235, 0)  : color.rgb(39, 39, 42, 12)
color bgSoft   = isLightTheme ? color.rgb(209, 213, 219, 0)  : color.rgb(63, 63, 70, 18)
color border   = isLightTheme ? color.rgb(156, 163, 175, 25) : color.rgb(82, 82, 91, 45)

color txtMain  = isLightTheme ? color.rgb(17, 24, 39)        : color.rgb(250, 250, 250)
color txtMute  = isLightTheme ? color.rgb(107, 114, 128)     : color.rgb(161, 161, 170)

color green1   = isLightTheme ? color.rgb(5, 150, 105)       : color.rgb(16, 185, 129)
color green2   = isLightTheme ? color.rgb(16, 185, 129)      : color.rgb(52, 211, 153)
color yellow1  = isLightTheme ? color.rgb(217, 119, 6)       : color.rgb(251, 191, 36)
color orange1  = isLightTheme ? color.rgb(234, 88, 12)       : color.rgb(251, 146, 60)
color red1     = isLightTheme ? color.rgb(220, 38, 38)       : color.rgb(248, 113, 113)
color red2     = isLightTheme ? color.rgb(185, 28, 28)       : color.rgb(239, 68, 68)
color blue1    = isLightTheme ? color.rgb(37, 99, 235)       : color.rgb(96, 165, 250)
color purple1  = isLightTheme ? color.rgb(124, 58, 237)      : color.rgb(167, 139, 250)

int heatBgTransp = isLightTheme ? 10 : 28

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// UTILITY FUNCTIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

f_txtSize() => size.small

f_clamp(x) => math.max(0.0, math.min(100.0, x))

f_pick(x, fallback) => na(x) ? fallback : x

f_pct(now, past) => not na(now) and not na(past) and past != 0 ? (now / past - 1.0) * 100.0 : na

f_avg4(a, b, c, d) =>
    float sum = 0.0
    float n = 0.0
    if not na(a)
        sum += a
        n += 1
    if not na(b)
        sum += b
        n += 1
    if not na(c)
        sum += c
        n += 1
    if not na(d)
        sum += d
        n += 1
    n > 0 ? sum / n : na

f_wavg4(a, wa, b, wb, c, wc, d, wd) =>
    float sum = 0.0
    float wt = 0.0
    if not na(a)
        sum += a * wa
        wt += wa
    if not na(b)
        sum += b * wb
        wt += wb
    if not na(c)
        sum += c * wc
        wt += wc
    if not na(d)
        sum += d * wd
        wt += wd
    wt > 0 ? sum / wt : na

f_scoreFromPct(p, inverse, mult) =>
    na(p) ? na : f_clamp(50.0 + (inverse ? -p : p) * mult)

f_metricScores(v, v7, v30, v90, v180, v14, v37, v97, v187, inverse, sens) =>
    float s1 = f_scoreFromPct(f_pct(v, v7), inverse, 4.0 * sens)
    float s2 = f_scoreFromPct(f_pct(v, v30), inverse, 2.0 * sens)
    float s3 = f_scoreFromPct(f_pct(v, v90), inverse, 1.0 * sens)
    float s4 = f_scoreFromPct(f_pct(v, v180), inverse, 0.70 * sens)

    float a1 = f_scoreFromPct(f_pct(v7, v14), inverse, 4.0 * sens)
    float a2 = f_scoreFromPct(f_pct(v7, v37), inverse, 2.0 * sens)
    float a3 = f_scoreFromPct(f_pct(v7, v97), inverse, 1.0 * sens)
    float a4 = f_scoreFromPct(f_pct(v7, v187), inverse, 0.70 * sens)

    [f_avg4(s1, s2, s3, s4), f_avg4(a1, a2, a3, a4), s1, s2, s3, s4]

f_accelScores(v, v7, v30, v90, v180, v14, v37, v97, v187, sens) =>
    float p7   = f_pct(v, v7)
    float p30  = f_pct(v, v30)
    float p90  = f_pct(v, v90)
    float p180 = f_pct(v, v180)

    float s1 = na(p7) or na(p30) ? na : f_clamp(50.0 + (p7 - p30 / 4.0) * 4.0 * sens)
    float s2 = na(p30) or na(p90) ? na : f_clamp(50.0 + (p30 - p90 / 3.0) * 2.0 * sens)
    float s3 = na(p90) or na(p180) ? na : f_clamp(50.0 + (p90 - p180 / 2.0) * 1.0 * sens)
    float s4 = na(p180) ? na : f_clamp(50.0 + p180 * 0.50 * sens)

    float ap7   = f_pct(v7, v14)
    float ap30  = f_pct(v7, v37)
    float ap90  = f_pct(v7, v97)
    float ap180 = f_pct(v7, v187)

    float a1 = na(ap7) or na(ap30) ? na : f_clamp(50.0 + (ap7 - ap30 / 4.0) * 4.0 * sens)
    float a2 = na(ap30) or na(ap90) ? na : f_clamp(50.0 + (ap30 - ap90 / 3.0) * 2.0 * sens)
    float a3 = na(ap90) or na(ap180) ? na : f_clamp(50.0 + (ap90 - ap180 / 2.0) * 1.0 * sens)
    float a4 = na(ap180) ? na : f_clamp(50.0 + ap180 * 0.50 * sens)

    [f_avg4(s1, s2, s3, s4), f_avg4(a1, a2, a3, a4), s1, s2, s3, s4]

f_fundingRisk(v) =>
    float pct = fundingIsDecimal ? v * 100.0 : v
    f_clamp(math.abs(pct) / fundingExtremePct * 100.0)

f_validFunding(v) => not na(v) and math.abs(fundingIsDecimal ? v * 100.0 : v) <= 5.0

f_ratio(a, b) => not na(a) and not na(b) and b != 0 ? a / b : na

f_deltaStr(x) => (x > 0 ? "+" : "") + str.tostring(math.round(x))

f_bar(score, segments) =>
    int filled = int(math.round(f_clamp(score) / 100.0 * segments))
    string out = ""
    for i = 0 to segments - 1
        out += i < filled ? "█" : "░"
    out

f_heat(score, riskMode) =>
    riskMode ?
         score >= 80 ? red1 :
         score >= 60 ? orange1 :
         score >= 40 ? yellow1 :
         score >= 20 ? green2 :
                       green1 :
         score >= 80 ? green1 :
         score >= 60 ? green2 :
         score >= 40 ? yellow1 :
         score >= 20 ? orange1 :
                       red1

f_scoreColor(score, riskMode) => f_heat(score, riskMode)

f_moveRisk(score) => f_clamp(math.abs(score - 50.0) * 2.0)

f_fundingProxy(oiPressure, marketMomentum) => f_clamp(50.0 + (oiPressure - 50.0) * 0.60 + (marketMomentum - 50.0) * 0.40)

f_liqRiskProxy(oiPressure, fundingPressure, marketMomentum) => f_clamp(oiPressure * 0.45 + fundingPressure * 0.35 + f_moveRisk(marketMomentum) * 0.20)

f_barStrengthColor(score) =>
    score >= 80 ? green1 :
     score >= 60 ? green2 :
     score >= 40 ? yellow1 :
     score >= 20 ? orange1 :
                   red1

f_stateBull(score) =>
    score >= 80 ? "Strong" :
     score >= 60 ? "Healthy" :
     score >= 40 ? "Mixed" :
     score >= 20 ? "Weak" :
                   "Risk-Off"

f_stateRisk(score) =>
    score >= 80 ? "Dangerous" :
     score >= 60 ? "Elevated" :
     score >= 40 ? "Neutral" :
     score >= 20 ? "Low" :
                   "Calm"

f_regime(score) =>
    score >= 80 ? "Strong Bull" :
     score >= 60 ? "Healthy Bull" :
     score >= 40 ? "Neutral / Transition" :
     score >= 20 ? "Bearish / Risk-Off" :
                   "Panic / Deleveraging"

f_phase(liq, breadth) =>
    liq >= 60 and breadth >= 60 ? "Liquidity Expansion" :
     liq >= 60 and breadth < 60 ? "Narrow Liquidity Rally" :
     liq < 40 and breadth < 40 ? "Risk-Off / Deleveraging" :
                                 "Transition"

f_riskState(lev) =>
    lev >= 80 ? "Extreme Leverage" :
     lev >= 60 ? "Elevated Leverage" :
     lev >= 40 ? "Normal Leverage" :
                 "Deleveraged"

f_confidence(liq, lev, breadth) =>
    float levSupport = f_clamp(100.0 - math.max(0.0, lev - 50.0) * 1.25)
    float mean = (liq + levSupport + breadth) / 3.0
    float variance = (math.pow(liq - mean, 2) + math.pow(levSupport - mean, 2) + math.pow(breadth - mean, 2)) / 3.0
    f_clamp(100.0 - math.sqrt(variance) * 1.50)

f_getClose(sym) =>
    request.security(
         sym,
         "1D",
         [close, close[7], close[30], close[90], close[180], close[14], close[37], close[97], close[187]],
         gaps = barmerge.gaps_off,
         lookahead = barmerge.lookahead_off,
         ignore_invalid_symbol = true
     )

f_getVolume(sym) =>
    request.security(
         sym,
         "1D",
         [volume, volume[7], volume[30], volume[90], volume[180], volume[14], volume[37], volume[97], volume[187]],
         gaps = barmerge.gaps_off,
         lookahead = barmerge.lookahead_off,
         ignore_invalid_symbol = true
     )

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DATA
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[m2, m2_7, m2_30, m2_90, m2_180, m2_14, m2_37, m2_97, m2_187] = f_getClose(m2Sym)
[tot, tot_7, tot_30, tot_90, tot_180, tot_14, tot_37, tot_97, tot_187] = f_getClose(totalSym)
[usdt, usdt_7, usdt_30, usdt_90, usdt_180, usdt_14, usdt_37, usdt_97, usdt_187] = f_getClose(usdtDSym)
[vol, vol_7, vol_30, vol_90, vol_180, vol_14, vol_37, vol_97, vol_187] = f_getVolume(volumeSym)

[oi, oi_7, oi_30, oi_90, oi_180, oi_14, oi_37, oi_97, oi_187] = f_getClose(oiSym)
[fund, fund_7, fund_30, fund_90, fund_180, fund_14, fund_37, fund_97, fund_187] = f_getClose(fundSym)

[tot2, tot2_7, tot2_30, tot2_90, tot2_180, tot2_14, tot2_37, tot2_97, tot2_187] = f_getClose(total2Sym)
[tot3, tot3_7, tot3_30, tot3_90, tot3_180, tot3_14, tot3_37, tot3_97, tot3_187] = f_getClose(total3Sym)
[btcd, btcd_7, btcd_30, btcd_90, btcd_180, btcd_14, btcd_37, btcd_97, btcd_187] = f_getClose(btcDSym)
[ethd, ethd_7, ethd_30, ethd_90, ethd_180, ethd_14, ethd_37, ethd_97, ethd_187] = f_getClose(ethDSym)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// METRIC SCORES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[m2Raw, m2AgoRaw, m2WRaw, m2MRaw, m2QRaw, m2HRaw] = f_metricScores(m2, m2_7, m2_30, m2_90, m2_180, m2_14, m2_37, m2_97, m2_187, false, sensMacro)
[totRaw, totAgoRaw, totWRaw, totMRaw, totQRaw, totHRaw] = f_metricScores(tot, tot_7, tot_30, tot_90, tot_180, tot_14, tot_37, tot_97, tot_187, false, sensCrypto)
[usdtRaw, usdtAgoRaw, usdtWRaw, usdtMRaw, usdtQRaw, usdtHRaw] = f_metricScores(usdt, usdt_7, usdt_30, usdt_90, usdt_180, usdt_14, usdt_37, usdt_97, usdt_187, true, sensCrypto)
[volRaw, volAgoRaw, volWRaw, volMRaw, volQRaw, volHRaw] = f_metricScores(vol, vol_7, vol_30, vol_90, vol_180, vol_14, vol_37, vol_97, vol_187, false, sensCrypto)

[oiRaw, oiAgoRaw, oiWRaw, oiMRaw, oiQRaw, oiHRaw] = f_metricScores(oi, oi_7, oi_30, oi_90, oi_180, oi_14, oi_37, oi_97, oi_187, false, sensOI)
[oiAccRaw, oiAccAgoRaw, oiAccWRaw, oiAccMRaw, oiAccQRaw, oiAccHRaw] = f_accelScores(oi, oi_7, oi_30, oi_90, oi_180, oi_14, oi_37, oi_97, oi_187, sensOI)

[tot2Raw, tot2AgoRaw, tot2WRaw, tot2MRaw, tot2QRaw, tot2HRaw] = f_metricScores(tot2, tot2_7, tot2_30, tot2_90, tot2_180, tot2_14, tot2_37, tot2_97, tot2_187, false, sensCrypto)
[tot3Raw, tot3AgoRaw, tot3WRaw, tot3MRaw, tot3QRaw, tot3HRaw] = f_metricScores(tot3, tot3_7, tot3_30, tot3_90, tot3_180, tot3_14, tot3_37, tot3_97, tot3_187, false, sensCrypto)
[btcdRaw, btcdAgoRaw, btcdWRaw, btcdMRaw, btcdQRaw, btcdHRaw] = f_metricScores(btcd, btcd_7, btcd_30, btcd_90, btcd_180, btcd_14, btcd_37, btcd_97, btcd_187, true, sensCrypto)
[ethdRaw, ethdAgoRaw, ethdWRaw, ethdMRaw, ethdQRaw, ethdHRaw] = f_metricScores(ethd, ethd_7, ethd_30, ethd_90, ethd_180, ethd_14, ethd_37, ethd_97, ethd_187, false, sensCrypto)

altNow = f_ratio(tot3, tot)
alt7   = f_ratio(tot3_7, tot_7)
alt30  = f_ratio(tot3_30, tot_30)
alt90  = f_ratio(tot3_90, tot_90)
alt180 = f_ratio(tot3_180, tot_180)
alt14  = f_ratio(tot3_14, tot_14)
alt37  = f_ratio(tot3_37, tot_37)
alt97  = f_ratio(tot3_97, tot_97)
alt187 = f_ratio(tot3_187, tot_187)

[altRaw, altAgoRaw, altWRaw, altMRaw, altQRaw, altHRaw] = f_metricScores(altNow, alt7, alt30, alt90, alt180, alt14, alt37, alt97, alt187, false, sensCrypto)

m2Score     = f_pick(m2Raw, m2Fallback)
totScore    = f_pick(totRaw, totalFallback)
usdtScore   = f_pick(usdtRaw, usdtFallback)
volScore    = f_pick(volRaw, volumeFallback)

oiScore     = f_pick(oiRaw, oiFallback)
oiAccScore  = f_pick(oiAccRaw, oiScore)

tot2Score   = f_pick(tot2Raw, total2Fallback)
tot3Score   = f_pick(tot3Raw, total3Fallback)
btcdScore   = f_pick(btcdRaw, btcDFallback)
ethdScore   = f_pick(ethdRaw, ethDFallback)
altScore    = f_pick(altRaw, altFallback)

fundProxyScore = f_pick(f_fundingProxy(oiScore, totScore), fundFallback)
fundAutoRaw    = useAutoFunding and f_validFunding(fund) ? f_fundingRisk(fund) : na
fundScore      = f_pick(fundAutoRaw, fundProxyScore)

liqRiskScore = f_liqRiskProxy(oiScore, fundScore, totScore)

m2Ago     = f_pick(m2AgoRaw, m2Score)
totAgo    = f_pick(totAgoRaw, totScore)
usdtAgo   = f_pick(usdtAgoRaw, usdtScore)
volAgo    = f_pick(volAgoRaw, volScore)

oiAgo     = f_pick(oiAgoRaw, oiScore)
oiAccAgo  = f_pick(oiAccAgoRaw, oiAccScore)

tot2Ago   = f_pick(tot2AgoRaw, tot2Score)
tot3Ago   = f_pick(tot3AgoRaw, tot3Score)
btcdAgo   = f_pick(btcdAgoRaw, btcdScore)
ethdAgo   = f_pick(ethdAgoRaw, ethdScore)
altAgo    = f_pick(altAgoRaw, altScore)

fundAgoProxy = f_fundingProxy(oiAgo, totAgo)
fundAgoAuto  = useAutoFunding and f_validFunding(fund_7) ? f_fundingRisk(fund_7) : na
fundAgo      = f_pick(fundAgoAuto, fundAgoProxy)

liqRiskAgo = f_liqRiskProxy(oiAgo, fundAgo, totAgo)

m2W = f_pick(m2WRaw, m2Score), m2M = f_pick(m2MRaw, m2Score), m2Q = f_pick(m2QRaw, m2Score), m2H = f_pick(m2HRaw, m2Score)
totW = f_pick(totWRaw, totScore), totM = f_pick(totMRaw, totScore), totQ = f_pick(totQRaw, totScore), totH = f_pick(totHRaw, totScore)
usdtW = f_pick(usdtWRaw, usdtScore), usdtM = f_pick(usdtMRaw, usdtScore), usdtQ = f_pick(usdtQRaw, usdtScore), usdtH = f_pick(usdtHRaw, usdtScore)
volW = f_pick(volWRaw, volScore), volM = f_pick(volMRaw, volScore), volQ = f_pick(volQRaw, volScore), volH = f_pick(volHRaw, volScore)

oiW = f_pick(oiWRaw, oiScore), oiM = f_pick(oiMRaw, oiScore), oiQ = f_pick(oiQRaw, oiScore), oiH = f_pick(oiHRaw, oiScore)
oiAccW = f_pick(oiAccWRaw, oiAccScore), oiAccM = f_pick(oiAccMRaw, oiAccScore), oiAccQ = f_pick(oiAccQRaw, oiAccScore), oiAccH = f_pick(oiAccHRaw, oiAccScore)

fundWAuto = useAutoFunding and f_validFunding(fund) ? f_fundingRisk(fund) : na
fundMAuto = useAutoFunding and f_validFunding(fund_30) ? f_fundingRisk(fund_30) : na
fundQAuto = useAutoFunding and f_validFunding(fund_90) ? f_fundingRisk(fund_90) : na
fundHAuto = useAutoFunding and f_validFunding(fund_180) ? f_fundingRisk(fund_180) : na

fundW = f_pick(fundWAuto, f_fundingProxy(oiW, totW))
fundM = f_pick(fundMAuto, f_fundingProxy(oiM, totM))
fundQ = f_pick(fundQAuto, f_fundingProxy(oiQ, totQ))
fundH = f_pick(fundHAuto, f_fundingProxy(oiH, totH))

liqRiskW = f_liqRiskProxy(oiW, fundW, totW)
liqRiskM = f_liqRiskProxy(oiM, fundM, totM)
liqRiskQ = f_liqRiskProxy(oiQ, fundQ, totQ)
liqRiskH = f_liqRiskProxy(oiH, fundH, totH)

tot2W = f_pick(tot2WRaw, tot2Score), tot2M = f_pick(tot2MRaw, tot2Score), tot2Q = f_pick(tot2QRaw, tot2Score), tot2H = f_pick(tot2HRaw, tot2Score)
tot3W = f_pick(tot3WRaw, tot3Score), tot3M = f_pick(tot3MRaw, tot3Score), tot3Q = f_pick(tot3QRaw, tot3Score), tot3H = f_pick(tot3HRaw, tot3Score)
btcdW = f_pick(btcdWRaw, btcdScore), btcdM = f_pick(btcdMRaw, btcdScore), btcdQ = f_pick(btcdQRaw, btcdScore), btcdH = f_pick(btcdHRaw, btcdScore)
ethdW = f_pick(ethdWRaw, ethdScore), ethdM = f_pick(ethdMRaw, ethdScore), ethdQ = f_pick(ethdQRaw, ethdScore), ethdH = f_pick(ethdHRaw, ethdScore)
altW = f_pick(altWRaw, altScore), altM = f_pick(altMRaw, altScore), altQ = f_pick(altQRaw, altScore), altH = f_pick(altHRaw, altScore)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// COMPOSITES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

liqBase = f_wavg4(m2Score, 30.0, totScore, 50.0, usdtScore, 20.0, float(na), 0.0)
liqScore = f_clamp(liqBase + (volScore - 50.0) * 0.10)

liqAgoBase = f_wavg4(m2Ago, 30, totAgo, 50, usdtAgo, 20, float(na), 0.0)
liqAgoScore = f_clamp(liqAgoBase + (volAgo - 50.0) * 0.10)

levBase = f_wavg4(oiScore, 40, fundScore, 35, liqRiskScore, 25, float(na), 0.0)
levScore = f_clamp(levBase + (oiAccScore - 50.0) * 0.10)

levAgoBase = f_wavg4(oiAgo, 40, fundAgo, 35, liqRiskAgo, 25, float(na), 0.0)
levAgoScore = f_clamp(levAgoBase + (oiAccAgo - 50.0) * 0.10)

breadBase = f_wavg4(tot2Score, 40, tot3Score, 35, btcdScore, 15, ethdScore, 10)
breadScore = f_clamp(breadBase + (altScore - 50.0) * 0.10)

breadAgoBase = f_wavg4(tot2Ago, 40, tot3Ago, 35, btcdAgo, 15, ethdAgo, 10)
breadAgoScore = f_clamp(breadAgoBase + (altAgo - 50.0) * 0.10)

levSupport = f_clamp(100.0 - math.max(0.0, levScore - 50.0) * 1.25)
levSupportAgo = f_clamp(100.0 - math.max(0.0, levAgoScore - 50.0) * 1.25)

compScore = f_wavg4(liqScore, 45, breadScore, 35, levSupport, 20, float(na), 0.0)
compAgoScore = f_wavg4(liqAgoScore, 45, breadAgoScore, 35, levSupportAgo, 20, float(na), 0.0)

confidence = f_confidence(liqScore, levScore, breadScore)

liqD = liqScore - liqAgoScore
levD = levScore - levAgoScore
breadD = breadScore - breadAgoScore
compD = compScore - compAgoScore

liqW = f_clamp(f_wavg4(m2W, 30.0, totW, 50.0, usdtW, 20.0, float(na), 0.0) + (volW - 50.0) * 0.10)
liqM = f_clamp(f_wavg4(m2M, 30.0, totM, 50.0, usdtM, 20.0, float(na), 0.0) + (volM - 50.0) * 0.10)
liqQ = f_clamp(f_wavg4(m2Q, 30.0, totQ, 50.0, usdtQ, 20.0, float(na), 0.0) + (volQ - 50.0) * 0.10)
liqH = f_clamp(f_wavg4(m2H, 30.0, totH, 50.0, usdtH, 20.0, float(na), 0.0) + (volH - 50.0) * 0.10)

levW = f_clamp(f_wavg4(oiW, 40.0, fundW, 35.0, liqRiskW, 25.0, float(na), 0.0) + (oiAccW - 50.0) * 0.10)
levM = f_clamp(f_wavg4(oiM, 40.0, fundM, 35.0, liqRiskM, 25.0, float(na), 0.0) + (oiAccM - 50.0) * 0.10)
levQ = f_clamp(f_wavg4(oiQ, 40.0, fundQ, 35.0, liqRiskQ, 25.0, float(na), 0.0) + (oiAccQ - 50.0) * 0.10)
levH = f_clamp(f_wavg4(oiH, 40.0, fundH, 35.0, liqRiskH, 25.0, float(na), 0.0) + (oiAccH - 50.0) * 0.10)

breadW = f_clamp(f_wavg4(tot2W, 40, tot3W, 35, btcdW, 15, ethdW, 10) + (altW - 50) * 0.10)
breadM = f_clamp(f_wavg4(tot2M, 40, tot3M, 35, btcdM, 15, ethdM, 10) + (altM - 50) * 0.10)
breadQ = f_clamp(f_wavg4(tot2Q, 40, tot3Q, 35, btcdQ, 15, ethdQ, 10) + (altQ - 50) * 0.10)
breadH = f_clamp(f_wavg4(tot2H, 40, tot3H, 35, btcdH, 15, ethdH, 10) + (altH - 50) * 0.10)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TABLE RENDERING
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

const int COLS = 24
const int ROWS = 21

var table dash = na

f_cell(t, c, r, txt, tc, bg, hal, sz, f_fam) =>
    table.cell(
         t,
         c,
         r,
         txt,
         text_color = tc,
         bgcolor = bg,
         text_halign = hal,
         text_valign = text.align_center,
         text_size = sz,
         text_font_family = f_fam
     )

const float LIQ_METRIC_WIDTH = 5.20
const float LIQ_TF_WIDTH     = 2.80
const float LIQ_SCORE_WIDTH  = 3.10
const float LIQ_DELTA_WIDTH  = 3.10
const float LIQ_STATE_WIDTH  = 5.20

f_cellW(t, c, r, txt, tc, bg, hal, sz, f_fam, w) =>
    table.cell(
         t,
         c,
         r,
         txt,
         width = w,
         text_color = tc,
         bgcolor = bg,
         text_halign = hal,
         text_valign = text.align_center,
         text_size = sz,
         text_font_family = f_fam
     )

f_heatCell(t, c, r, score, riskMode) =>
    table.cell(
         t,
         c,
         r,
         "",
         bgcolor = color.new(f_heat(score, riskMode), heatBgTransp)
     )

f_heatCellW(t, c, r, score, riskMode, w) =>
    table.cell(
         t,
         c,
         r,
         "",
         width = w,
         bgcolor = color.new(f_heat(score, riskMode), heatBgTransp)
     )

f_metricRow(t, startCol, row, name, sW, sM, sQ, sH, score, delta, state, riskMode, sz) =>
    f_cell(t, startCol + 0, row, name, txtMain, bgPanel, text.align_left, sz, font.family_default)
    f_heatCell(t, startCol + 1, row, sW, riskMode)
    f_heatCell(t, startCol + 2, row, sM, riskMode)
    f_heatCell(t, startCol + 3, row, sQ, riskMode)
    f_heatCell(t, startCol + 4, row, sH, riskMode)
    f_cell(t, startCol + 5, row, str.tostring(math.round(score)), f_scoreColor(score, riskMode), bgPanel, text.align_center, sz, font.family_monospace)
    f_cell(t, startCol + 6, row, f_deltaStr(delta), delta >= 0 ? green1 : red1, bgPanel, text.align_center, sz, font.family_monospace)
    f_cell(t, startCol + 7, row, state, f_scoreColor(score, riskMode), bgPanel, text.align_center, sz, font.family_default)

f_headerRow(t, startCol, row, sz) =>
    f_cell(t, startCol + 0, row, "Metric", txtMain, bgSoft, text.align_left, sz, font.family_default)
    f_cell(t, startCol + 1, row, "1W", txtMain, bgSoft, text.align_center, sz, font.family_default)
    f_cell(t, startCol + 2, row, "1M", txtMain, bgSoft, text.align_center, sz, font.family_default)
    f_cell(t, startCol + 3, row, "3M", txtMain, bgSoft, text.align_center, sz, font.family_default)
    f_cell(t, startCol + 4, row, "6M", txtMain, bgSoft, text.align_center, sz, font.family_default)
    f_cell(t, startCol + 5, row, "Score", txtMain, bgSoft, text.align_center, sz, font.family_default)
    f_cell(t, startCol + 6, row, "Δ7D", txtMain, bgSoft, text.align_center, sz, font.family_default)
    f_cell(t, startCol + 7, row, "State", txtMain, bgSoft, text.align_center, sz, font.family_default)

f_headerRowLiquidity(t, row, sz) =>
    f_cellW(t, 0, row, "Metric", txtMain, bgSoft, text.align_left, sz, font.family_default, LIQ_METRIC_WIDTH)
    f_cellW(t, 1, row, "1W", txtMain, bgSoft, text.align_center, sz, font.family_default, LIQ_TF_WIDTH)
    f_cellW(t, 2, row, "1M", txtMain, bgSoft, text.align_center, sz, font.family_default, LIQ_TF_WIDTH)
    f_cellW(t, 3, row, "3M", txtMain, bgSoft, text.align_center, sz, font.family_default, LIQ_TF_WIDTH)
    f_cellW(t, 4, row, "6M", txtMain, bgSoft, text.align_center, sz, font.family_default, LIQ_TF_WIDTH)
    f_cellW(t, 5, row, "Score", txtMain, bgSoft, text.align_center, sz, font.family_default, LIQ_SCORE_WIDTH)
    f_cellW(t, 6, row, "Δ7D", txtMain, bgSoft, text.align_center, sz, font.family_default, LIQ_DELTA_WIDTH)
    f_cellW(t, 7, row, "State", txtMain, bgSoft, text.align_center, sz, font.family_default, LIQ_STATE_WIDTH)

f_metricRowLiquidity(t, row, name, sW, sM, sQ, sH, score, delta, state, riskMode, sz) =>
    f_cellW(t, 0, row, name, txtMain, bgPanel, text.align_left, sz, font.family_default, LIQ_METRIC_WIDTH)
    f_heatCellW(t, 1, row, sW, riskMode, LIQ_TF_WIDTH)
    f_heatCellW(t, 2, row, sM, riskMode, LIQ_TF_WIDTH)
    f_heatCellW(t, 3, row, sQ, riskMode, LIQ_TF_WIDTH)
    f_heatCellW(t, 4, row, sH, riskMode, LIQ_TF_WIDTH)
    f_cellW(t, 5, row, str.tostring(math.round(score)), f_scoreColor(score, riskMode), bgPanel, text.align_center, sz, font.family_monospace, LIQ_SCORE_WIDTH)
    f_cellW(t, 6, row, f_deltaStr(delta), delta >= 0 ? green1 : red1, bgPanel, text.align_center, sz, font.family_monospace, LIQ_DELTA_WIDTH)
    f_cellW(t, 7, row, state, f_scoreColor(score, riskMode), bgPanel, text.align_center, sz, font.family_default, LIQ_STATE_WIDTH)

f_headerRowFixed(t, startCol, row, sz) =>
    f_cellW(t, startCol + 0, row, "Metric", txtMain, bgSoft, text.align_left, sz, font.family_default, LIQ_METRIC_WIDTH)
    f_cellW(t, startCol + 1, row, "1W", txtMain, bgSoft, text.align_center, sz, font.family_default, LIQ_TF_WIDTH)
    f_cellW(t, startCol + 2, row, "1M", txtMain, bgSoft, text.align_center, sz, font.family_default, LIQ_TF_WIDTH)
    f_cellW(t, startCol + 3, row, "3M", txtMain, bgSoft, text.align_center, sz, font.family_default, LIQ_TF_WIDTH)
    f_cellW(t, startCol + 4, row, "6M", txtMain, bgSoft, text.align_center, sz, font.family_default, LIQ_TF_WIDTH)
    f_cellW(t, startCol + 5, row, "Score", txtMain, bgSoft, text.align_center, sz, font.family_default, LIQ_SCORE_WIDTH)
    f_cellW(t, startCol + 6, row, "Δ7D", txtMain, bgSoft, text.align_center, sz, font.family_default, LIQ_DELTA_WIDTH)
    f_cellW(t, startCol + 7, row, "State", txtMain, bgSoft, text.align_center, sz, font.family_default, LIQ_STATE_WIDTH)

f_metricRowFixed(t, startCol, row, name, sW, sM, sQ, sH, score, delta, state, riskMode, sz) =>
    f_cellW(t, startCol + 0, row, name, txtMain, bgPanel, text.align_left, sz, font.family_default, LIQ_METRIC_WIDTH)
    f_heatCellW(t, startCol + 1, row, sW, riskMode, LIQ_TF_WIDTH)
    f_heatCellW(t, startCol + 2, row, sM, riskMode, LIQ_TF_WIDTH)
    f_heatCellW(t, startCol + 3, row, sQ, riskMode, LIQ_TF_WIDTH)
    f_heatCellW(t, startCol + 4, row, sH, riskMode, LIQ_TF_WIDTH)
    f_cellW(t, startCol + 5, row, str.tostring(math.round(score)), f_scoreColor(score, riskMode), bgPanel, text.align_center, sz, font.family_monospace, LIQ_SCORE_WIDTH)
    f_cellW(t, startCol + 6, row, f_deltaStr(delta), delta >= 0 ? green1 : red1, bgPanel, text.align_center, sz, font.family_monospace, LIQ_DELTA_WIDTH)
    f_cellW(t, startCol + 7, row, state, f_scoreColor(score, riskMode), bgPanel, text.align_center, sz, font.family_default, LIQ_STATE_WIDTH)

if showDashboard and barstate.isfirst
    dash := table.new(
         position.middle_center,
         COLS,
         ROWS,
         frame_color = border,
         border_color = border,
         frame_width = 2,
         border_width = 1,
         bgcolor = bgMain
    )

    for c = 0 to COLS - 1
        for r = 0 to ROWS - 1
            table.cell(dash, c, r, "", bgcolor = bgMain)

    table.merge_cells(dash, 0, 0, 23, 0)

    table.merge_cells(dash, 0, 1, 7, 4)
    table.merge_cells(dash, 8, 1, 15, 4)
    table.merge_cells(dash, 16, 1, 17, 4)
    table.merge_cells(dash, 18, 1, 20, 4)
    table.merge_cells(dash, 21, 1, 23, 4)

    table.merge_cells(dash, 0, 5, 7, 5)
    table.merge_cells(dash, 8, 5, 23, 5)

    table.merge_cells(dash, 0, 6, 7, 6)
    table.merge_cells(dash, 8, 6, 15, 6)
    table.merge_cells(dash, 16, 6, 23, 6)

    table.merge_cells(dash, 0, 12, 7, 12)
    table.merge_cells(dash, 8, 12, 15, 12)

    table.merge_cells(dash, 0, 13, 4, 13)
    table.merge_cells(dash, 8, 13, 12, 13)
    table.merge_cells(dash, 16, 13, 20, 13)

    table.merge_cells(dash, 0, 14, 7, 15)
    table.merge_cells(dash, 8, 14, 15, 15)
    table.merge_cells(dash, 16, 14, 23, 15)

    table.merge_cells(dash, 0, 16, 5, 20)
    table.merge_cells(dash, 6, 16, 11, 20)
    table.merge_cells(dash, 12, 16, 17, 20)
    table.merge_cells(dash, 18, 16, 23, 20)

if showDashboard and barstate.islast
    sz = f_txtSize()

    regime = f_regime(compScore)
    phase = f_phase(liqScore, breadScore)
    riskState = f_riskState(levScore)
    confLabel = confidence >= 70 ? "High" : confidence >= 50 ? "Medium" : "Low"
    regimeBarColor = f_barStrengthColor(compScore)

    // Detect if the main chart has less than 180 days of data
    bool isLimitedHistory = na(tot_180) and not na(tot)

    f_cell(dash, 0, 0, "CRYPTO MACRO HEATMAP by invincible3", txtMain, bgMain, text.align_center, size.normal, font.family_default)

    f_cell(
         dash,
         0,
         1,
         "COMPOSITE REGIME SCORE\n\n" +
         str.tostring(math.round(compScore)) + " / 100\n\n" +
         "Δ vs 7D ago   " + f_deltaStr(compD),
         f_scoreColor(compScore, false),
         bgPanel,
         text.align_center,
         size.large,
         font.family_monospace
     )

    f_cell(
         dash,
         8,
         1,
         "REGIME METER\n\n" +
         f_bar(compScore, 18) + "\n\n" +
         regime,
         regimeBarColor,
         bgPanel,
         text.align_center,
         size.normal,
         font.family_default
     )


    f_cell(
         dash,
         16,
         1,
         "MARKET PHASE\n\n" +
         phase ,
         liqScore >= 60 ? green1 : yellow1,
         bgPanel,
         text.align_center,
         size.normal,
         font.family_default
     )

    f_cell(
         dash,
         18,
         1,
         "RISK STATE\n\n" +
         riskState ,
         f_scoreColor(levScore, true),
         bgPanel,
         text.align_center,
         size.normal,
         font.family_default
     )

    f_cell(
         dash,
         21,
         1,
         "CONFIDENCE\n\n" +
         str.tostring(math.round(confidence)) + "%\n\n" +
         confLabel,
         confidence >= 70 ? green1 : confidence >= 50 ? yellow1 : orange1,
         bgPanel,
         text.align_center,
         size.normal,
         font.family_monospace
     )

    f_cell(dash, 0, 5, "SECONDARY LABELS", txtMain, bgPanel2, text.align_center, sz, font.family_default)
    f_cell(
         dash,
         8,
         5,
         regime + "  |  " +
         phase + "  |  " +
         riskState + "  |  " +
         (levScore < 80 ? "No Extreme Deleveraging" : "Extreme Leverage Risk") ,
         txtMain,
         bgPanel2,
         text.align_left,
         sz,
         font.family_default
     )

    f_cell(dash, 0, 6, "💧  SECTION 1 — LIQUIDITY        " + str.tostring(math.round(liqScore)) + "     Δ " + f_deltaStr(liqD), green1, bgPanel2, text.align_left, size.normal, font.family_monospace)
    f_cell(dash, 8, 6, "⚖️  SECTION 2 — LEVERAGE        " + str.tostring(math.round(levScore)) + "     Δ " + f_deltaStr(levD), orange1, bgPanel2, text.align_left, size.normal, font.family_monospace)
    f_cell(dash, 16, 6, "👥  SECTION 3 — BREADTH        " + str.tostring(math.round(breadScore)) + "     Δ " + f_deltaStr(breadD), blue1, bgPanel2, text.align_left, size.normal, font.family_monospace)

    f_headerRowLiquidity(dash, 7, sz)
    f_headerRowFixed(dash, 8, 7, sz)
    f_headerRowFixed(dash, 16, 7, sz)

    f_metricRowLiquidity(dash, 8, "Global M2", m2W, m2M, m2Q, m2H, m2Score, m2Score - m2Ago, m2Score >= 60 ? "Expanding" : m2Score >= 40 ? "Mixed" : "Contracting", false, sz)
    f_metricRowLiquidity(dash, 9, "TOTAL", totW, totM, totQ, totH, totScore, totScore - totAgo, f_stateBull(totScore), false, sz)
    f_metricRowLiquidity(dash, 10, "USDT.D", usdtW, usdtM, usdtQ, usdtH, usdtScore, usdtScore - usdtAgo, usdtScore >= 60 ? "Risk-On" : usdtScore >= 40 ? "Neutral" : "Risk-Off", false, sz)
    f_metricRowLiquidity(dash, 11, "Volume", volW, volM, volQ, volH, volScore, volScore - volAgo, f_stateBull(volScore), false, sz)

    f_cell(dash, 0, 12, "", txtMain, bgMain, text.align_center, sz, font.family_default)

    f_cell(dash, 0, 13, "LIQUIDITY COMPOSITE", green1, bgPanel2, text.align_left, sz, font.family_default)
    f_cell(dash, 5, 13, str.tostring(math.round(liqScore)), green1, bgPanel2, text.align_center, sz, font.family_monospace)
    f_cell(dash, 6, 13, f_deltaStr(liqD), liqD >= 0 ? green1 : red1, bgPanel2, text.align_center, sz, font.family_monospace)
    f_cell(dash, 7, 13, liqScore >= 60 ? "Strong" : liqScore >= 40 ? "Mixed" : "Weak", green1, bgPanel2, text.align_center, sz, font.family_default)

    f_cell(
         dash,
         0,
         14,
         "How Liquidity Score is calculated\n" +
         "Global M2 30%  •  TOTAL 50%\n" +
         "USDT.D inverse 20%  •  Volume confirmation",
         txtMain,
         bgPanel,
         text.align_center,
         sz,
         font.family_default
     )

    f_metricRowFixed(dash, 8, 8, "OI", oiW, oiM, oiQ, oiH, oiScore, oiScore - oiAgo, f_stateRisk(oiScore), true, sz)
    f_metricRowFixed(dash, 8, 9, "Funding", fundW, fundM, fundQ, fundH, fundScore, fundScore - fundAgo, f_stateRisk(fundScore), true, sz)
    f_metricRowFixed(dash, 8, 10, "Liq. Risk", liqRiskW, liqRiskM, liqRiskQ, liqRiskH, liqRiskScore, liqRiskScore - liqRiskAgo, f_stateRisk(liqRiskScore), true, sz)
    f_metricRowFixed(dash, 8, 11, "OI Accel", oiAccW, oiAccM, oiAccQ, oiAccH, oiAccScore, oiAccScore - oiAccAgo, f_stateRisk(oiAccScore), true, sz)

    f_cell(dash, 8, 12, "", txtMain, bgMain, text.align_center, sz, font.family_default)

    f_cell(dash, 8, 13, "LEVERAGE STRESS", red1, bgPanel2, text.align_left, sz, font.family_default)
    f_cell(dash, 13, 13, str.tostring(math.round(levScore)), red1, bgPanel2, text.align_center, sz, font.family_monospace)
    f_cell(dash, 14, 13, f_deltaStr(levD), levD >= 0 ? red1 : green1, bgPanel2, text.align_center, sz, font.family_monospace)
    f_cell(dash, 15, 13, levScore >= 60 ? "High Risk" : "Controlled", red1, bgPanel2, text.align_center, sz, font.family_default)

    f_cell(
         dash,
         8,
         14,
         "How Leverage Stress is calculated\n" +
         "OI Risk 40%  •  Auto Funding Risk 35%\n" +
         "Auto Liquidation Risk 25%\n" +
         "Higher score = higher risk",
         txtMain,
         bgPanel,
         text.align_center,
         sz,
         font.family_default
     )

    f_metricRowFixed(dash, 16, 8, "TOTAL2", tot2W, tot2M, tot2Q, tot2H, tot2Score, tot2Score - tot2Ago, f_stateBull(tot2Score), false, sz)
    f_metricRowFixed(dash, 16, 9, "TOTAL3", tot3W, tot3M, tot3Q, tot3H, tot3Score, tot3Score - tot3Ago, f_stateBull(tot3Score), false, sz)
    f_metricRowFixed(dash, 16, 10, "BTC.D", btcdW, btcdM, btcdQ, btcdH, btcdScore, btcdScore - btcdAgo, btcdScore >= 60 ? "Broadening" : btcdScore >= 40 ? "Neutral" : "Narrow", false, sz)
    f_metricRowFixed(dash, 16, 11, "ETH.D", ethdW, ethdM, ethdQ, ethdH, ethdScore, ethdScore - ethdAgo, f_stateBull(ethdScore), false, sz)
    f_metricRowFixed(dash, 16, 12, "Alt Part.", altW, altM, altQ, altH, altScore, altScore - altAgo, f_stateBull(altScore), false, sz)

    f_cell(dash, 16, 13, "BREADTH COMPOSITE", blue1, bgPanel2, text.align_left, sz, font.family_default)
    f_cell(dash, 21, 13, str.tostring(math.round(breadScore)), blue1, bgPanel2, text.align_center, sz, font.family_monospace)
    f_cell(dash, 22, 13, f_deltaStr(breadD), breadD >= 0 ? green1 : red1, bgPanel2, text.align_center, sz, font.family_monospace)
    f_cell(dash, 23, 13, breadScore >= 60 ? "Healthy" : breadScore >= 40 ? "Mixed" : "Weak", blue1, bgPanel2, text.align_center, sz, font.family_default)

    f_cell(
         dash,
         16,
         14,
         "How Breadth Score is calculated\n" +
         "TOTAL2 40%  •  TOTAL3 35%\n" +
         "BTC.D inverse 15%  •  ETH.D 10%\n" +
         "Alt participation confirmation",
         txtMain,
         bgPanel,
         text.align_center,
         sz,
         font.family_default
     )

    f_cell(
         dash,
         0,
         16,
         "CURRENT CONDITIONS SUMMARY\n\n" +
         "💧 Liquidity: " + (liqScore >= 60 ? "strong / expanding" : liqScore >= 40 ? "mixed" : "weak") + "\n" +
         "👥 Breadth: " + (breadScore >= 60 ? "healthy participation" : breadScore >= 40 ? "mixed participation" : "narrow market") + "\n" +
         "⚠️ Leverage: " + riskState + "\n" +
         "📈 Market: " + regime + 
         (isLimitedHistory ? "\n\n⚠️ CHART HISTORY < 180D\nMetrics fall back to 50" : ""),
         isLimitedHistory ? orange1 : txtMain,
         bgPanel,
         text.align_left,
         sz,
         font.family_default
     )

    f_cell(
         dash,
         6,
         16,
         "SECTION DELTA vs 7D\n\n" +
         "Liquidity          " + f_deltaStr(liqD) + "\n" +
         "Leverage Stress    " + f_deltaStr(levD) + "\n" +
         "Breadth            " + f_deltaStr(breadD) + "\n" +
         "Composite          " + f_deltaStr(compD),
         txtMain,
         bgPanel,
         text.align_left,
         sz,
         font.family_monospace
     )

    f_cell(
         dash,
         12,
         16,
         "KEY LEVELS TO WATCH\n\n" +
         "BTC.D > 58%       Risk: narrow market\n" +
         "Funding risk high Risk: crowded perp side\n" +
         "OI accel > 15%    Risk: leverage build-up\n" +
         "USDT.D rising     Risk-off signal",
         yellow1,
         bgPanel,
         text.align_left,
         sz,
         font.family_monospace
     )

    f_cell(
         dash,
         18,
         16,
         "NEXT POSSIBLE SCENARIOS\n\n" +
         "⬆ Leverage cools → Strong Bull\n" +
         "⬆ Breadth improves → Altseason\n" +
         "➡ Leverage stays high → Mania Risk\n" +
         "⬇ Liquidity weakens → Risk-Off",
         blue1,
         bgPanel,
         text.align_left,
         sz,
         font.family_default
     )
````
