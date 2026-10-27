# BTC TABI (Tops and Bottoms Indicator) Model 

- url: https://www.tradingview.com/script/OhApYf0W-BTC-TABI-Tops-and-Bottoms-Indicator-Model/
- type: indicator
- pine_id: PUB;c61ef3303979405cbda42131e03fea8b
- version: 1.0

## Description

[b]TABI BTC Model [/b]

[b]Overview[/b]
The TABI BTC Model is an 18-component composite oscillator designed to identify Bitcoin macro cycle tops and bottoms. It's a reverse-engineered and expanded implementation of the InvestAnswers TABI (Top And Bottom Indicator) concept, combining price-derived technicals, on-chain proxies, and cross-market signals into a single 0–100 score with a 7-color heatmap.

[b]How It Works[/b]
Each of the 18 sub-metrics is percentile-ranked over a rolling 4-year lookback (1460 bars on Daily), multiplied by a configurable weight, then averaged and smoothed with a 5-period EMA. This normalization means every component contributes on the same 0–1 scale regardless of its raw units — solving the scaling problem that breaks most multi-indicator composites.

[b]The 18 Components[/b]
Price-Derived (7)

350DMA Multiple, Mayer Multiple (200DMA), Pi Cycle Distance, Puell Proxy (365DMA), RSI(14), Log-Log Regression Position, Volatility Ratio (ATR)
TradingView On-Chain Feeds (2)

MVRV Z-Score (BTC_MVRV), BTC Dominance Inverted (CRYPTOCAP:BTC.D)
On-Chain Approximations (2)

NUPL Proxy (2yr MA), Hodler Proxy (1yr/4yr MA ratio)
New Cross-Market & Flow Signals (7)

Monthly RSI — Multi-year cycle exhaustion; historically only fires >80 at confirmed tops
SOPR Proxy — Short-term return velocity vs. medium-term trend (profit-taking flow)
Reserve Risk Proxy — Price vs. accumulated long-term holder cost basis
ETH/BTC Ratio — Late-cycle altcoin rotation signal
Stablecoin Supply Ratio (SSR) — Dry powder / buying fuel remaining
Coinbase Premium — US institutional demand proxy
Hash Ribbon Proxy — Miner capitulation signal (with fallback)

[b][/b]Color Zones
Score	Zone	Interpretation
0–20	🟣 Dark Blue	Maximum buy / capitulation bottom
20–35	🔵 Blue	Strong accumulation
35–50	🟢 Green	Mild accumulation
50–65	🟡 Yellow	Neutral / caution
65–75	🟠 Light Orange	Reduce size
75–85	🟧 Orange	Sell zone
85–100	🔴 Red	Danger / distribution top

[b][/b]Features
Fully adjustable weights per metric — tune to your analysis style
Individual metric toggles to inspect sub-components
Built-in alerts for crosses of 20, 50, and 85 thresholds
Extreme zone background highlighting
Graceful NA handling on on-chain feeds that may be unavailable on some plans

[b][/b]Best Used On
Symbol: BTCUSD (or any major BTC pair)
Timeframe: Daily (the 4-year percentile lookback is calibrated for this)

[b][/b]Limitations
This is not the original InvestAnswers TABI — that uses 19 proprietary metrics including true on-chain data (SOPR, hashrate, NVT) that Pine Script cannot access directly
On-chain feeds (MVRV, BTC.D, QUANDL hashrate) depend on your TradingView plan; the script falls back to neutral (0.5) if data is missing
Coinbase and USDC data only goes back to ~2018; pre-2019 percentiles on those components are compressed
Not financial advice — a tool to support analysis, not replace it

## Source Code

````pine
// ============================================================================
// IA TABI Composite [BTCUSD] — v2 — InvestAnswers TABI Model (18 components)
// ============================================================================
// 18-metric composite oscillator (0–100) with 7-color heatmap.
// Color zones:
//   0–20  Dark Blue  — Maximum buy / bottom zone
//   20–35 Blue       — Strong accumulation
//   35–50 Green      — Mild accumulation
//   50–65 Yellow     — Neutral / caution
//   65–75 Lt Orange  — Reduce size / take some profits
//   75–85 Orange     — Sell zone
//   85–100 Red       — Danger / top zone
// Best used on BTCUSD Daily timeframe.
// ============================================================================

//@version=6
indicator("TABI BTC Model", shorttitle="TABI v2", overlay=false, max_bars_back=2000)

// ── Inputs ───────────────────────────────────────────────────────────────────
var GRP_MAIN    = "Core Settings"
var GRP_WEIGHTS = "Metric Weights (Original)"
var GRP_NEW_W   = "Metric Weights (New v2)"
var GRP_VIZ     = "Visualization"
var GRP_METRICS = "Individual Metrics"

lookback = input.int(1460, "Percentile Lookback (bars)", minval=365, maxval=3000, group=GRP_MAIN,
     tooltip="Number of bars used for percentile rank. 1460 ≈ 4 years on Daily.", display=display.none)
smooth   = input.int(5, "Composite Smoothing (EMA)", minval=1, maxval=50, group=GRP_MAIN,
     tooltip="EMA smoothing applied to the final composite score.", display=display.none)

// Original component weights (w7 reduced 0.6→0.4, w9 reduced 0.7→0.5)
w1  = input.float(1.0, "350DMA Multiple",         minval=0, maxval=3, step=0.1, group=GRP_WEIGHTS, display=display.none)
w2  = input.float(1.0, "Mayer Multiple (200DMA)", minval=0, maxval=3, step=0.1, group=GRP_WEIGHTS, display=display.none)
w3  = input.float(0.8, "Pi Cycle Distance",       minval=0, maxval=3, step=0.1, group=GRP_WEIGHTS, display=display.none)
w4  = input.float(0.8, "Puell Proxy",             minval=0, maxval=3, step=0.1, group=GRP_WEIGHTS, display=display.none)
w5  = input.float(1.0, "RSI (14)",                minval=0, maxval=3, step=0.1, group=GRP_WEIGHTS, display=display.none)
w6  = input.float(1.0, "Log Regression",          minval=0, maxval=3, step=0.1, group=GRP_WEIGHTS, display=display.none)
w7  = input.float(0.4, "Volatility Ratio",        minval=0, maxval=3, step=0.1, group=GRP_WEIGHTS, display=display.none)
w8  = input.float(1.2, "MVRV Z-Score",            minval=0, maxval=3, step=0.1, group=GRP_WEIGHTS, display=display.none)
w9  = input.float(0.5, "BTC Dominance",           minval=0, maxval=3, step=0.1, group=GRP_WEIGHTS, display=display.none)
w10 = input.float(0.9, "NUPL Proxy",              minval=0, maxval=3, step=0.1, group=GRP_WEIGHTS, display=display.none)
w11 = input.float(0.7, "Hodler Proxy",            minval=0, maxval=3, step=0.1, group=GRP_WEIGHTS, display=display.none)

// New component weights (v2)
w12 = input.float(0.8, "SOPR Proxy",           minval=0, maxval=3, step=0.1, group=GRP_NEW_W, display=display.none)
w13 = input.float(0.8, "Reserve Risk Proxy",   minval=0, maxval=3, step=0.1, group=GRP_NEW_W, display=display.none)
w14 = input.float(1.1, "Monthly RSI",          minval=0, maxval=3, step=0.1, group=GRP_NEW_W, display=display.none)
w15 = input.float(0.6, "ETH/BTC Ratio",        minval=0, maxval=3, step=0.1, group=GRP_NEW_W, display=display.none)
w16 = input.float(0.7, "Stablecoin SSR",       minval=0, maxval=3, step=0.1, group=GRP_NEW_W, display=display.none)
w17 = input.float(0.7, "Coinbase Premium",     minval=0, maxval=3, step=0.1, group=GRP_NEW_W, display=display.none)
w18 = input.float(0.8, "Hash Ribbon Proxy",    minval=0, maxval=3, step=0.1, group=GRP_NEW_W, display=display.none)

showBgColor  = input.bool(true, "Highlight Extreme Zones (background)", group=GRP_VIZ, display=display.none)

// ── Individual Metric Toggles ─────────────────────────────────────────────────
showTABI    = input.bool(true,  "TABI Composite",     group=GRP_METRICS, display=display.none)
show350DMA  = input.bool(false, "350DMA Multiple",    group=GRP_METRICS, display=display.none)
showMayer   = input.bool(false, "Mayer Multiple",     group=GRP_METRICS, display=display.none)
showPiCycle = input.bool(false, "Pi Cycle",           group=GRP_METRICS, display=display.none)
showPuell   = input.bool(false, "Puell Proxy",        group=GRP_METRICS, display=display.none)
showRSI     = input.bool(false, "RSI (14)",           group=GRP_METRICS, display=display.none)
showLogReg  = input.bool(false, "Log Regression",     group=GRP_METRICS, display=display.none)
showVol     = input.bool(false, "Volatility Ratio",   group=GRP_METRICS, display=display.none)
showMVRV    = input.bool(false, "MVRV Z-Score",       group=GRP_METRICS, display=display.none)
showDom     = input.bool(false, "BTC Dominance",      group=GRP_METRICS, display=display.none)
showNUPL    = input.bool(false, "NUPL Proxy",         group=GRP_METRICS, display=display.none)
showHodler  = input.bool(false, "Hodler Proxy",       group=GRP_METRICS, display=display.none)
showSOPR    = input.bool(false, "SOPR Proxy",         group=GRP_METRICS, display=display.none)
showResRisk = input.bool(false, "Reserve Risk Proxy", group=GRP_METRICS, display=display.none)
showMthRSI  = input.bool(false, "Monthly RSI",        group=GRP_METRICS, display=display.none)
showETHBTC  = input.bool(false, "ETH/BTC Ratio",      group=GRP_METRICS, display=display.none)
showSSR     = input.bool(false, "Stablecoin SSR",     group=GRP_METRICS, display=display.none)
showCBPrem  = input.bool(false, "Coinbase Premium",   group=GRP_METRICS, display=display.none)
showHash    = input.bool(false, "Hash Ribbon Proxy",  group=GRP_METRICS, display=display.none)

// ── Percentile Rank Helper ───────────────────────────────────────────────────
percentile_rank(series float src, simple int length) =>
    float count = 0.0
    for i = 0 to length - 1
        if src[i] <= src
            count += 1.0
    count / length

// ── Group A: Price-Derived Metrics ───────────────────────────────────────────

// 1. 350DMA Multiple
ma350 = ta.sma(close, 350)
m350  = close / ma350
p1    = percentile_rank(m350, lookback)

// 2. Mayer Multiple (price / 200DMA)
ma200 = ta.sma(close, 200)
mayer = close / ma200
p2    = percentile_rank(mayer, lookback)

// 3. Pi Cycle Distance (111DMA vs 2x350DMA)
ma111  = ta.sma(close, 111)
piDist = (ma111 - 2.0 * ma350) / ma350
p3     = percentile_rank(piDist, lookback)

// 4. Puell Multiple Proxy (price / 365DMA)
ma365 = ta.sma(close, 365)
puell = close / ma365
p4    = percentile_rank(puell, lookback)

// 5. RSI (14)
rsiVal = ta.rsi(close, 14)
p5     = rsiVal / 100.0

// 6. Log-Log Regression Position
logClose = math.log(close)
logReg   = ta.linreg(logClose, lookback, 0)
logResid = logClose - logReg
p6       = percentile_rank(logResid, lookback)

// 7. Volatility Ratio (ATR14 / 200-bar ATR SMA)
atr14    = ta.atr(14)
atrSma   = ta.sma(atr14, 200)
volRatio = atr14 / atrSma
p7       = percentile_rank(volRatio, lookback)

// ── Group B: TradingView On-Chain Feeds ──────────────────────────────────────

// 8. MVRV Z-Score
mvrv_raw   = request.security("BTC_MVRV", "D", close, ignore_invalid_symbol=true)
mvrv_prank = percentile_rank(mvrv_raw, lookback)
p8         = na(mvrv_raw) ? 0.5 : mvrv_prank

// 9. BTC Dominance (inverted)
dom_raw   = request.security("CRYPTOCAP:BTC.D", "D", close, ignore_invalid_symbol=true)
dom_prank = percentile_rank(dom_raw, lookback)
p9        = na(dom_raw) ? 0.5 : (1.0 - dom_prank)

// ── Group C: On-Chain Approximations ─────────────────────────────────────────

// 10. NUPL Proxy
ma730     = ta.sma(close, 730)
nuplProxy = (close - ma730) / close
p10       = percentile_rank(nuplProxy, lookback)

// 11. Hodler Proxy
ma252  = ta.sma(close, 252)
ma1460 = ta.sma(close, 1460)
hodler = ma252 / ma1460
p11    = percentile_rank(hodler, lookback)

// ── Group D: New v2 Components ───────────────────────────────────────────────

// 12. SOPR Proxy — short-term return velocity vs medium-term trend.
// Captures active distribution (profit taking) vs capitulation.
// Clipped to [-5, 5] to prevent extreme outliers corrupting the rank.
ret_7d   = (close / close[7])  - 1.0
ret_90d  = (close / close[90]) - 1.0
sopr_raw = math.min(math.max(ret_7d / (math.abs(ret_90d) + 0.01), -5.0), 5.0)
p12      = percentile_rank(sopr_raw, lookback)

// 13. Reserve Risk Proxy — price relative to accumulated LTH cost basis.
// High = holders sitting on large gains = top risk.
ema1460  = ta.ema(close, 1460)
resRisk  = close / math.sqrt(ema1460 * ma252)
p13      = percentile_rank(resRisk, lookback)

// 14. Monthly RSI — fires above 80 only at confirmed macro tops.
// Uses [1] shift (last completed monthly candle) to prevent repainting.
mth_rsi_raw = request.security(syminfo.tickerid, "M", ta.rsi(close, 14)[1],
     lookahead=barmerge.lookahead_on, ignore_invalid_symbol=true)
_p14_rank   = percentile_rank(nz(mth_rsi_raw, 50.0) / 100.0, lookback)
p14         = na(mth_rsi_raw) ? 0.5 : _p14_rank

// 15. ETH/BTC Ratio — late-cycle altcoin season signal.
// Rising ETH/BTC = risk-on rotation = approaching cycle top.
ethbtc_raw = request.security("BINANCE:ETHBTC", "D", close, ignore_invalid_symbol=true)
_p15_rank  = percentile_rank(nz(ethbtc_raw, 0.0), lookback)
p15        = na(ethbtc_raw) ? 0.5 : _p15_rank

// 16. Stablecoin Supply Ratio (SSR) — BTC mcap / stablecoin supply.
// High SSR = dry powder deployed = top risk. Low SSR = buying fuel available.
btc_mcap  = request.security("CRYPTOCAP:BTC",  "D", close, ignore_invalid_symbol=true)
usdt_mcap = request.security("CRYPTOCAP:USDT", "D", close, ignore_invalid_symbol=true)
usdc_mcap = request.security("CRYPTOCAP:USDC", "D", close, ignore_invalid_symbol=true)
usdc_safe = nz(usdc_mcap, 0.0)
ssr_denom = usdt_mcap + usdc_safe + 1.0
ssr_raw   = (na(btc_mcap) or na(usdt_mcap)) ? float(na) : btc_mcap / ssr_denom
_p16_rank = percentile_rank(nz(ssr_raw, 0.0), lookback)
p16       = na(ssr_raw) ? 0.5 : _p16_rank

// 17. Coinbase Premium Index — US institutional demand proxy.
// Positive premium = institutional buying pressure = top risk.
// 14-bar EMA smooths daily exchange noise.
cb_price  = request.security("COINBASE:BTCUSD",  "D", close, ignore_invalid_symbol=true)
bn_price  = request.security("BINANCE:BTCUSDT",  "D", close, ignore_invalid_symbol=true)
cb_raw    = (na(cb_price) or na(bn_price)) ? 0.0 : (cb_price - bn_price) / bn_price * 100.0
cb_smooth = ta.ema(cb_raw, 14)
p17       = percentile_rank(cb_smooth, lookback)

// 18. Hash Ribbon Proxy — miner capitulation = bottom signal.
// Primary: 30d/60d SMA of hashrate (QUANDL feed).
// Fallback: same ratio on price SMAs when hashrate feed unavailable.
hr_raw      = request.security("QUANDL:BCHAIN/HRATE", "D", close, ignore_invalid_symbol=true)
hr_src      = na(hr_raw) ? close : hr_raw
hash_sma30  = ta.sma(hr_src, 30)
hash_sma60  = ta.sma(hr_src, 60)
hash_raw    = hash_sma30 / hash_sma60
p18         = percentile_rank(hash_raw, lookback)

// ── Weighted Composite Score ─────────────────────────────────────────────────
totalWeight = w1+w2+w3+w4+w5+w6+w7+w8+w9+w10+w11+w12+w13+w14+w15+w16+w17+w18

partA    = p1*w1 + p2*w2 + p3*w3 + p4*w4 + p5*w5 + p6*w6
partB    = p7*w7 + nz(p8,0.5)*w8 + nz(p9,0.5)*w9 + p10*w10 + p11*w11
partC    = p12*w12 + p13*w13 + nz(p14,0.5)*w14 + nz(p15,0.5)*w15 +
           nz(p16,0.5)*w16 + p17*w17 + p18*w18

rawScore  = (partA + partB + partC) / totalWeight
tabiScore = ta.ema(rawScore * 100.0, smooth)

// ── Heatmap Color ─────────────────────────────────────────────────────────────
tabiColor = switch
    tabiScore <= 20 => color.new(#0d1b6e, 0)
    tabiScore <= 35 => color.new(#0288d1, 0)
    tabiScore <= 50 => color.new(#2e7d32, 0)
    tabiScore <= 65 => color.new(#f9a825, 0)
    tabiScore <= 75 => color.new(#ef6c00, 0)
    tabiScore <= 85 => color.new(#e64a19, 0)
    => color.new(#b71c1c, 0)

// ── Zone Threshold Lines ──────────────────────────────────────────────────────
hline(85, "Danger Zone",  color=color.new(#b71c1c, 50), linestyle=hline.style_dashed, linewidth=1)
hline(75, "Sell Zone",    color=color.new(#e64a19, 50), linestyle=hline.style_dashed, linewidth=1)
hline(65, "Caution",      color=color.new(#ef6c00, 50), linestyle=hline.style_dashed, linewidth=1)
hline(50, "Neutral",      color=color.new(#888888, 60), linestyle=hline.style_dotted,  linewidth=1)
hline(35, "Accumulate",   color=color.new(#2e7d32, 50), linestyle=hline.style_dashed, linewidth=1)
hline(20, "Max Buy Zone", color=color.new(#0288d1, 50), linestyle=hline.style_dashed, linewidth=1)

// ── Main Score Plot + Fill ────────────────────────────────────────────────────
p_score = plot(showTABI ? tabiScore : na, "TABI Score", color=tabiColor, linewidth=3)
p_zero  = plot(showTABI ? 0 : na,          "Zero",       display=display.none)
fill(p_score, p_zero, color=color.new(tabiColor, 88), title="TABI Fill")

// ── Background Highlight for Extreme Zones ────────────────────────────────────
bgCol = switch
    showBgColor and tabiScore <= 20 => color.new(#0d1b6e, 82)
    showBgColor and tabiScore >= 85 => color.new(#b71c1c, 82)
    => na
bgcolor(bgCol, title="Extreme Zone Background")

// ── Individual Metric Lines — Original ───────────────────────────────────────
plot(show350DMA  ? p1  * 100 : na, "350DMA Multiple",    color=#9c27b0, linewidth=2)
plot(showMayer   ? p2  * 100 : na, "Mayer Multiple",     color=#2196f3, linewidth=2)
plot(showPiCycle ? p3  * 100 : na, "Pi Cycle",           color=#00bcd4, linewidth=2)
plot(showPuell   ? p4  * 100 : na, "Puell Proxy",        color=#4caf50, linewidth=2)
plot(showRSI     ? p5  * 100 : na, "RSI (14)",           color=#ffeb3b, linewidth=2)
plot(showLogReg  ? p6  * 100 : na, "Log Regression",     color=#ff9800, linewidth=2)
plot(showVol     ? p7  * 100 : na, "Volatility Ratio",   color=#9e9e9e, linewidth=2)
plot(showMVRV    ? p8  * 100 : na, "MVRV Z-Score",       color=#f44336, linewidth=2)
plot(showDom     ? p9  * 100 : na, "BTC Dominance",      color=#e91e63, linewidth=2)
plot(showNUPL    ? p10 * 100 : na, "NUPL Proxy",         color=#00e5ff, linewidth=2)
plot(showHodler  ? p11 * 100 : na, "Hodler Proxy",       color=#ff4081, linewidth=2)

// ── Individual Metric Lines — New v2 ─────────────────────────────────────────
plot(showSOPR    ? p12 * 100 : na, "SOPR Proxy",         color=#cddc39, linewidth=2)
plot(showResRisk ? p13 * 100 : na, "Reserve Risk Proxy", color=#ffc107, linewidth=2)
plot(showMthRSI  ? p14 * 100 : na, "Monthly RSI",        color=#7c4dff, linewidth=2)
plot(showETHBTC  ? p15 * 100 : na, "ETH/BTC Ratio",      color=#40c4ff, linewidth=2)
plot(showSSR     ? p16 * 100 : na, "Stablecoin SSR",     color=#69f0ae, linewidth=2)
plot(showCBPrem  ? p17 * 100 : na, "Coinbase Premium",   color=#ff6d00, linewidth=2)
plot(showHash    ? p18 * 100 : na, "Hash Ribbon Proxy",  color=#b0bec5, linewidth=2)

// ── Alert Conditions ──────────────────────────────────────────────────────────
alertcondition(ta.crossunder(tabiScore, 20), "TABI: Entered Bottom Zone (<20)",
     "TABI dropped below 20 — potential max accumulation zone")
alertcondition(ta.crossover(tabiScore,  85), "TABI: Entered Danger Zone (>85)",
     "TABI crossed above 85 — potential distribution / top zone")
alertcondition(ta.crossover(tabiScore,  50), "TABI: Crossed 50 Upward",
     "TABI crossed 50 upward — momentum turning bullish")
alertcondition(ta.crossunder(tabiScore, 50), "TABI: Crossed 50 Downward",
     "TABI crossed 50 downward — momentum turning bearish")
````
