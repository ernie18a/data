# Liquidity Map & Execution Cost

- url: https://www.tradingview.com/script/uKkSiMHV-Liquidity-Map-Execution-Cost/
- type: indicator
- pine_id: PUB;7f31137a62844266a644992fc003072c
- version: 2.0

## Description

# Liquidity Map & Execution Cost [LMX]

## What this script does

LMX answers three execution questions most indicators ignore: **how expensive is it to get in and out right now, how hard would it be to move size, and where on the chart will price struggle versus travel freely.** It reads only the chart's own price and volume — no symbol is hardcoded, so it runs on any asset and any market (equities, futures, FX, crypto, indices) — and turns the answers into a plain-language trade check: liquidity state, suggested position size, order type, estimated slippage, and a colour-coded map of support, resistance, walls and open gaps.

## Why these components are combined (mashup justification)

This is not several indicators stacked together — it is one liquidity model whose parts each answer a question the others cannot, and they are designed to be read together. Removing any one leaves a specific blind spot:

1. **Cost to cross — effective spread.** Estimated with the EDGE estimator (Ardia, Guidotti & Kroencke 2024) from open/high/low/close, cross-checked against Abdi-Ranaldo (2017) and Corwin-Schultz (2012). This tells you the round-trip cost of entering, which spread-blind tools cannot show. Alone, it says nothing about moving size or about levels.
2. **Cost to move size — price impact.** The Amihud (2002) illiquidity ratio with a high-low refinement, plus a rolling Kyle (1985) lambda computed as a true regression slope. This tells you how far your own order would push price — the question that matters for sizing, and one a spread estimate cannot answer.
3. **Direction of pressure — order imbalance.** A close-location signed-volume imbalance and its persistence. This tells you which side is leaning now, adding direction that the cost measures lack.
4. **The spatial map — volume at price.** A time-decay-weighted, range-distributed volume profile that yields the Point of Control and Value Area (standard 70% method), rendered as directional zones: green support below price, red resistance above, solid = a wall price struggles at, faint = an open gap price slides through. This converts the abstract cost/impact numbers into *locations* on the chart.
5. **Anchored VWAP — fair value.** A volume-weighted average anchored to your chosen reference (last major swing by default; or session/week/month open, or the highest-volume bar), drawn as a trend-coloured line. It is the dynamic counterpart to the static profile: where the average participant is positioned, and whether price is rich or cheap versus that.

Together they form one decision: the spread and impact set the **cost and size**, the imbalance and VWAP set the **direction and fair value**, and the map sets the **location** — so the output is "trade full size with market orders, buyers in control, room to run up to the gap above," not five separate readings.

## How a reading is produced

Each estimator is normalised to a percentile of its own history so thresholds adapt to every symbol and timeframe. The inverted spread, inverted impact and depth combine into a 0–100 **Liquidity Score**, classified as Deep / Normal / Thin / Stressed (a sudden impact spike forces Stressed). The score drives the suggested size multiplier, the order-type advice and the slippage estimate. The map is rebuilt on the last bar from the volume-at-price profile.

## How to use it

- Apply to any symbol. Set the price source and, if you trade very low intraday timeframes, optionally fix the calc timeframe (e.g. Daily) so the spread estimators stay stable. On symbols without real volume the volume modules disable automatically and the score leans on the spread estimators (the panel shows "price-only").
- **Simple mode (default)** gives plain-language guidance: Liquidity, Trade cost, Pressure, Position size, Orders, Watch-out, Fair value, and a one-line verdict. **Pro mode** exposes the full readout (spread in bps, Amihud and Kyle percentiles, depth, imbalance, flow persistence, value-area levels).
- On the chart: trade toward green support, expect resistance at red, size down where the map is thin (price moves fast there), and read the trend-coloured fair-value line for rich/cheap context.
- Alerts: liquidity-state change and sudden liquidity withdrawal.

## Originality

The combination is the original contribution: a single overlay that fuses low-frequency **spread**, **impact** and **imbalance** estimators with a **time-decay, range-distributed volume profile** and an anchored fair-value line, then translates all of it into sizing/order/slippage decisions in plain language. The building blocks are public-domain methods (EDGE, Abdi-Ranaldo, Corwin-Schultz, Amihud, Kyle, volume-profile Value Area, anchored VWAP), each used for the specific job described above and cited in the script header.

## Limitations (please read)

- These are **low-frequency estimators** of quantities normally measured from quote/tick data. They approximate — they do not measure — the true spread, depth, or dealer book.
- Volume-based modules require a real volume feed; they disable on symbols without one.
- Spread estimators were validated on daily-type bars; on very fast intraday timeframes they are noisier — use the calc-timeframe option if needed.
- The on-panel statistics are computed on the loaded chart history.
- This is an analysis tool, **not financial advice.** Test before use and trade at your own risk.

## Source Code

````pine
//@version=6
// =====================================================================
// LIQUIDITY MAP & EXECUTION COST  [LMX]  v2  (+ volatility conditioning)
// ---------------------------------------------------------------------
// A transaction-cost / liquidity lens built entirely from the chart's
// own OHLCV — no quote, tick, or order-book data required, and no symbol
// is hardcoded. Works on any asset, any market (equities, futures, FX,
// crypto, indices). It estimates three things institutions track for
// execution, then turns them into sizing and order-type decisions:
//
//   1) COST TO CROSS  — effective bid-ask spread, estimated with the
//      EDGE estimator (Ardia, Guidotti & Kroencke 2024) as primary,
//      cross-checked against Abdi-Ranaldo (2017) and Corwin-Schultz
//      (2012).
//   2) COST TO MOVE SIZE — price impact, via the Amihud (2002) ILLIQ
//      ratio with a high-low refinement (Realized Illiquidity, Ranaldo
//      et al. 2023) and a rolling Kyle (1985) lambda.
//   3) DIRECTION OF PRESSURE — tick-rule signed-volume order imbalance
//      and its autocorrelation (most bias-robust microstructure signals,
//      NBER w24297).
//
// These feed a 0-100 Liquidity Score, a Deep/Normal/Thin/Stressed
// regime, an on-chart map of thin vs thick price zones, and a decision
// panel (size multiplier, limit-vs-market, slippage estimate, where the
// air-pockets are).
//
// ---------------------------------------------------------------------
// v2 UPDATE — VOLATILITY CONDITIONING ("PathVol-lite")
// ---------------------------------------------------------------------
// WHY: the high-low spread estimators (Corwin-Schultz, and partly
// Abdi-Ranaldo) read a bar's range as spread, but a range carries BOTH
// the bid-ask bounce AND the volatility over the interval. When vol
// spikes they over-state the spread — a wide range gets mislabelled as
// illiquidity. EDGE is more vol-robust, which is why it is the primary.
//
// WHAT WAS ADDED: a compact path-dependent volatility forecast (a
// reduced form of the Guyon-Lekeufack 2023 PDV model: a leverage
// feature R1 and an activity feature sqrt(R2), each a fast+slow kernel
// blend, lightly ridge-calibrated to this symbol's realised vol). It is
// used in four targeted, NON-redundant ways:
//   (a) DE-BIAS SPREAD — when the volatility forecast is elevated, the
//       high-low estimators' EXCESS over the vol-robust EDGE anchor is
//       shrunk toward EDGE, attributing that excess to volatility, not
//       spread. EDGE itself is never shrunk.
//   (b) VOL-AWARE SLIPPAGE — slippage gains a timing component (adverse
//       drift while an order works) = k x the one-bar vol forecast, on
//       top of the half-spread. Tight-spread-but-fast markets now cost
//       what they should.
//   (c) VOL-SCALED SIZING — size is now the MORE BINDING of a liquidity
//       budget and a volatility budget (min of the two), i.e. proper
//       vol-targeting layered on the liquidity constraint.
//   (d) TWO-AXIS REGIME — a volatility regime sits alongside the
//       liquidity regime; the tradeable information is in the
//       divergences (deep+volatile = orderly trend; thin+volatile =
//       air-pocket danger; thin+calm = complacent gap risk).
//
// IMPORTANT — volatility is NOT summed into the Liquidity Score. It only
// (i) corrects the high-low spread bias and (ii) adds an independent
// cost/size axis. This avoids double-counting, since the spread, Amihud
// and Kyle modules already derive from the same variance-bearing
// primitives the vol forecast uses.
//
// LIMITATIONS (read before trusting):
//   * These are LOW-FREQUENCY ESTIMATORS of quantities normally measured
//     from quote/tick data. They approximate, they do not measure, the
//     true spread, depth, or dealer book.
//   * Volume-based modules (Amihud, Kyle, imbalance, depth) require a
//     real volume feed. On symbols with no/poor volume they auto-disable
//     and the score leans on the spread estimators only.
//   * Spread estimators assume daily-type OHLC behaviour; on very high
//     intraday timeframes they are noisier. A calc-timeframe option keeps
//     them on a stable basis.
//   * The volatility module is a REDUCED-FORM forecast (leverage +
//     activity, light calibration; no upside-convexity / HAR / power-law
//     tail of the full model) — adequate for conditioning, not a
//     stand-alone vol product. The spread de-bias is an approximate
//     separation, not a clean decomposition: when illiquidity and
//     volatility genuinely rise together it will shrink some real spread.
//     Keep the vol module and the estimators on the SAME calc timeframe.
//   * Not financial advice. Estimates only.
// =====================================================================
indicator("Liquidity Map & Execution Cost", "LMX", overlay=true,
     max_boxes_count=500, max_labels_count=100, max_lines_count=100)

// ---------------------------------------------------------------------
// INPUTS
// ---------------------------------------------------------------------
gD       = "Data & basis"
srcSel   = input.string("close", "Price source (returns)", options=["close","hl2","ohlc4","hlc3"], group=gD,
             tooltip="The script reads THIS chart's symbol — no symbol is hardcoded, so it works on any asset/market. This setting picks which price series drives the return-based math. Spread estimators always use OHLC.")
calcTF   = input.timeframe("", "Calc timeframe (blank = chart)", group=gD,
             tooltip="Run the estimators on a fixed timeframe (e.g. D) so they stay stable regardless of the chart timeframe. Blank uses the chart timeframe.")
volMode  = input.string("Auto", "Volume feed", options=["Auto","Force on","Force off (price-only)"], group=gD,
             tooltip="Auto disables volume modules when the symbol reports no usable volume. Indices/FX often lack real volume.")

gW       = "Windows"
estLen   = input.int(20,  "Spread sample window",  minval=5,  group=gW)
impLen   = input.int(20,  "Impact (Amihud/Kyle) window", minval=5, group=gW)
imbLen   = input.int(14,  "Order-imbalance window", minval=3, group=gW)
rankLen  = input.int(252, "Percentile / history window", minval=50, group=gW,
             tooltip="Lookback used to rank each raw estimator 0-100 against its own history.")

gP       = "Spread estimator"
spreadPrimary = input.string("EDGE (2024)", "Primary estimator",
             options=["EDGE (2024)","Abdi-Ranaldo (2017)","Corwin-Schultz (2012)","Consensus (median)"], group=gP,
             tooltip="EDGE uses OHLC and is generally most accurate. Consensus takes the median of all three for robustness.")

gVol     = "Volatility conditioning (PathVol-lite)"
volAdjOn  = input.bool(true, "Condition cost/size on volatility", group=gVol,
             tooltip="Adds a compact path-dependent volatility forecast that (1) de-biases the high-low spread estimators when a wide range is really just volatility, (2) adds a volatility timing cost to slippage, and (3) scales position size by a volatility budget. EDGE stays the vol-robust anchor — volatility is NOT added into the liquidity score, only used to correct and to form a second axis.")
volRvLen  = input.int(10, "Realised-vol window", minval=2, group=gVol,
             tooltip="Bars used to measure the realised vol the compact model is fit to.")
volFastLen= input.int(10, "Vol kernel — fast", minval=2, group=gVol, tooltip="Short-memory kernel for the path features.")
volSlowLen= input.int(60, "Vol kernel — slow", minval=5, group=gVol, tooltip="Long-memory kernel for the path features.")
volW      = input.float(0.5, "Fast-vs-slow weight", minval=0, maxval=1, step=0.05, group=gVol)
volCalLen = input.int(150, "Vol calibration window", minval=20, group=gVol,
             tooltip="Rolling window the compact leverage+activity model is fit over.")
maxShrink = input.float(0.6, "Max vol de-bias of high-low spread", minval=0, maxval=1, step=0.05, group=gVol,
             tooltip="At extreme volatility, shrink up to this fraction of the high-low estimators' EXCESS over EDGE, attributing it to volatility rather than spread. 0 = never de-bias.")
volTimingK= input.float(0.5, "Vol timing cost (x 1-bar forecast)", minval=0, maxval=5, step=0.1, group=gVol,
             tooltip="Slippage gains a timing component = this x the one-bar volatility forecast, capturing adverse drift while an order works. 0 = spread-only slippage.")

gM       = "Liquidity map (zones)"
showMap  = input.bool(true,  "Show liquidity zones", group=gM)
mapStyle = input.string("Heatmap", "Zone style", options=["Heatmap","Bands"], group=gM)
mapBins  = input.int(24, "Price bins", minval=8, maxval=60, group=gM)
mapLook  = input.int(250, "Map history (bars)", minval=30, maxval=480, group=gM,
             tooltip="How far back to read where trading happened, to colour the zones. Larger = more of the chart is covered.")
thinPct  = input.float(35, "Thin-zone threshold (%ile)", minval=5, maxval=95, group=gM,
             tooltip="Volume-at-price below this percentile of the profile is treated as a thin (low-resistance) zone.")
decayHL  = input.int(60, "Recency half-life (bars, 0=off)", minval=0, group=gM,
             tooltip="Recent trading counts more. Volume this many bars ago counts half. 0 = all history weighted equally.")
distrib  = input.bool(true, "Spread each bar across its range", group=gM,
             tooltip="More accurate: distributes a bar's volume across its high-low range instead of dumping it at the midpoint.")
vaPct    = input.float(70, "Value area (%)", minval=50, maxval=95, group=gM,
             tooltip="Standard volume-profile value area: the central band holding this % of volume. POC = busiest price.")
showVoid = input.bool(true, "Flag nearest liquidity void (magnet)", group=gM)
showVwap = input.bool(true, "Anchored VWAP (fair-value line)", group=gM)
vwapAnchor = input.string("Last major swing", "VWAP anchor",
             options=["Last major swing","Session open","Week open","Month open","Highest-volume bar"], group=gM,
             tooltip="Where the fair-value line starts measuring from. 'Last major swing' holds the level until a bigger swing replaces it. 'Session/Week/Month open' resets each period. 'Highest-volume bar' anchors to the biggest liquidity event.")
swingStrength = input.int(10, "Swing strength (for swing anchor)", minval=3, group=gM,
             tooltip="Bigger = only major turning points reset the line (more stable). Smaller = reacts to minor swings.")

gT       = "Decision layer"
riskPct  = input.float(1.0, "Account risk per trade (%)", minval=0.05, group=gT,
             tooltip="Used only to scale the suggested size multiplier text; no account data is read.")
tickVal  = input.float(0.0, "Point value (0 = auto from syminfo)", minval=0, group=gT)

gV       = "Display"
panelMode= input.string("Simple", "Panel mode", options=["Simple","Pro"], group=gV,
             tooltip="Simple = plain-language guidance for any trader. Pro = the full estimator readout (Amihud, Kyle, percentiles).")
showPnl  = input.bool(true,  "Decision panel", group=gV)
panelPos = input.string("Top Right", "Panel position",
             options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=gV)
themeOpt = input.string("Auto", "Color theme", options=["Auto","Dark","Light"], group=gV)

// ---------------------------------------------------------------------
// THEME / PALETTE
// ---------------------------------------------------------------------
bgLum  = 0.299*color.r(chart.bg_color) + 0.587*color.g(chart.bg_color) + 0.114*color.b(chart.bg_color)
isDark = themeOpt == "Dark" ? true : themeOpt == "Light" ? false : (na(bgLum) ? true : bgLum < 128)
txtCol = isDark ? color.white : #0a0a0a
txtDim = isDark ? color.new(color.white, 18) : color.new(color.black, 15)
cellBg = chart.bg_color
hdrBg  = chart.bg_color
frameCol = isDark ? color.new(color.white, 30) : color.new(color.black, 35)
cDeep  = isDark ? #00e676 : #2e7d32
cNorm  = isDark ? #40a9ff : #1565c0
cThin  = isDark ? #ffd740 : #e65100
cStress= isDark ? #ff5252 : #c62828
cGreen = cDeep
cRed   = cStress
cAmber = cThin

panelPosV = panelPos == "Top Right" ? position.top_right : panelPos == "Top Left" ? position.top_left : panelPos == "Bottom Right" ? position.bottom_right : position.bottom_left

// auto-contrast text for a colored cell
txtOn(c) =>
    l = 0.299*color.r(c) + 0.587*color.g(c) + 0.114*color.b(c)
    l > 140 ? #0a0a0a : color.white

// ---------------------------------------------------------------------
// SOURCE & VOLUME RESOLUTION
// ---------------------------------------------------------------------
srcBase = srcSel == "hl2" ? hl2 : srcSel == "ohlc4" ? ohlc4 : srcSel == "hlc3" ? hlc3 : close

// detect usable volume over a window
volSeen = ta.cum(nz(volume)) > 0 and not na(volume)
volHi50 = ta.highest(nz(volume), 50)
hasVolAuto = volSeen and volHi50 > 0
useVol = volMode == "Force on" ? true : volMode == "Force off (price-only)" ? false : hasVolAuto

// pull everything on calcTF for stability (lookahead off)
_o = request.security(syminfo.tickerid, calcTF, open,  lookahead=barmerge.lookahead_off)
_h = request.security(syminfo.tickerid, calcTF, high,  lookahead=barmerge.lookahead_off)
_l = request.security(syminfo.tickerid, calcTF, low,   lookahead=barmerge.lookahead_off)
_c = request.security(syminfo.tickerid, calcTF, close, lookahead=barmerge.lookahead_off)
_v = request.security(syminfo.tickerid, calcTF, nz(volume), lookahead=barmerge.lookahead_off)
_s = request.security(syminfo.tickerid, calcTF, srcBase, lookahead=barmerge.lookahead_off)

// log prices for the spread estimators
lh = math.log(_h)
ll = math.log(_l)
lc = math.log(_c)
lo = math.log(_o)
lcPrev = lc[1]
ret = math.log(_s / _s[1])

// ---------------------------------------------------------------------
// SPREAD ESTIMATORS (all return a proportional/percent spread, >= 0)
// ---------------------------------------------------------------------
// --- Abdi-Ranaldo (2017): mid-range based ---
mid   = (lh + ll) / 2
arCov = ta.sma((lc - mid) * (lc - mid[1]), estLen)
arSpread = 2 * math.sqrt(math.max(0.0, arCov))      // proportional

// --- Corwin-Schultz (2012): high-low two-day ---
beta2 = math.pow(lh - ll, 2) + math.pow(lh[1] - ll[1], 2)
hl2d  = math.max(lh, lh[1]) - math.min(ll, ll[1])
gamma = math.pow(hl2d, 2)
k     = 3 - 2 * math.sqrt(2.0)
alpha = (math.sqrt(2 * beta2) - math.sqrt(beta2)) / k - math.sqrt(gamma / k)
csRaw = 2 * (math.exp(alpha) - 1) / (1 + math.exp(alpha))
csSpread = ta.sma(math.max(0.0, csRaw), estLen)

// --- EDGE (Ardia, Guidotti & Kroencke 2024): OHLC GMM-style ---
// Uses log mid-range deviations of open & close to the prior/curr mid.
// Implementation of the closed-form moment estimator.
m_t  = (lh + ll) / 2
m_p  = (lh[1] + ll[1]) / 2
x1   = (lc - m_t)
x2   = (lo - m_t)
x3   = (lc[1] - m_p)
x4   = (lo - m_p)
e1   = -2.0 * ta.sma(x1 * x4, estLen)               // E[ (c_t-m_t)(o_t-m_{t-1}) ]
e2   = -2.0 * ta.sma(x2 * x3, estLen)               // E[ (o_t-m_t)(c_{t-1}-m_{t-1}) ]
edgeVar = (e1 + e2) / 2.0
edgeSpread = math.sqrt(math.max(0.0, edgeVar))      // proportional root

// =====================================================================
// COMPACT PATH-DEPENDENT VOLATILITY (PathVol-lite)
//   Reduced Guyon-Lekeufack form for CONDITIONING only:
//   leverage feature R1 + activity feature sqrt(R2), each a fast+slow
//   kernel blend (lagged one bar), lightly ridge-calibrated to realised
//   vol by a 2-predictor rolling regression. Output is a one-step vol
//   forecast in per-bar return units and its own percentile.
// =====================================================================
vEps   = 1e-12
rvBaseV = math.sqrt(math.max(ta.sma(ret * ret, volRvLen), 0.0))   // realised vol (per-bar)
rLagV  = nz(ret[1])
r2LagV = rLagV * rLagV
// fast + slow kernels of the CONFIRMED past return path
e_t_f = ta.ema(rLagV,  volFastLen)
e_t_s = ta.ema(rLagV,  volSlowLen)
e_a_f = ta.ema(r2LagV, volFastLen)
e_a_s = ta.ema(r2LagV, volSlowLen)
R1v   = volW * e_t_f + (1.0 - volW) * e_t_s                       // trend / leverage feature
R2v   = volW * e_a_f + (1.0 - volW) * e_a_s                       // activity feature
sR2v  = math.sqrt(math.max(R2v, vEps))
// light 2-predictor ridge OLS:  rvBase ~ b0 + b1*R1v + b2*sR2v
m1v  = ta.sma(R1v,  volCalLen)
m2v  = ta.sma(sR2v, volCalLen)
myv  = ta.sma(rvBaseV, volCalLen)
S11v = ta.sma(R1v * R1v,    volCalLen) - m1v * m1v + vEps
S22v = ta.sma(sR2v * sR2v,  volCalLen) - m2v * m2v + vEps
S12v = ta.sma(R1v * sR2v,   volCalLen) - m1v * m2v
S1yv = ta.sma(R1v * rvBaseV, volCalLen) - m1v * myv
S2yv = ta.sma(sR2v * rvBaseV, volCalLen) - m2v * myv
detv = S11v * S22v - S12v * S12v
b1v  = detv != 0 ? (S1yv * S22v - S2yv * S12v) / detv : 0.0
b2v  = detv != 0 ? (S2yv * S11v - S1yv * S12v) / detv : 0.0
b0v  = myv - b1v * m1v - b2v * m2v
volForecast = math.max(b0v + b1v * R1v + b2v * sR2v, 0.0)         // per-bar return units
volReady = bar_index > volCalLen + volSlowLen
volPct   = ta.percentrank(volForecast, rankLen)                   // high = high forecast vol
volRegime = not volReady ? "—" : volPct >= 90 ? "Extreme" : volPct >= 65 ? "High" : volPct >= 25 ? "Normal" : "Low"
volRegCol = volPct >= 90 ? cStress : volPct >= 65 ? cThin : volPct >= 25 ? cNorm : cDeep
volWord   = volRegime == "Low" ? "Calm" : volRegime == "Normal" ? "Normal" : volRegime == "High" ? "Active" : volRegime == "Extreme" ? "Wild" : "—"

// =====================================================================
// SPREAD SELECTION  (+ volatility de-bias of the high-low estimators)
//   When forecast vol is elevated, shrink the high-low estimators' EXCESS
//   over the vol-robust EDGE anchor toward EDGE. EDGE itself is unshrunk.
// =====================================================================
volShrink = volAdjOn and volReady ? math.min(maxShrink, math.max(0.0, (volPct - 50.0) / 50.0) * maxShrink) : 0.0
arAdj = arSpread - math.max(0.0, arSpread - edgeSpread) * volShrink
csAdj = csSpread - math.max(0.0, csSpread - edgeSpread) * volShrink
medSpread    = math.max(math.min(edgeSpread, arAdj), math.min(math.max(edgeSpread, arAdj), csAdj))      // vol-adjusted consensus
medSpreadRaw = math.max(math.min(edgeSpread, arSpread), math.min(math.max(edgeSpread, arSpread), csSpread))
spreadRaw = spreadPrimary == "Abdi-Ranaldo (2017)" ? arAdj : spreadPrimary == "Corwin-Schultz (2012)" ? csAdj : spreadPrimary == "EDGE (2024)" ? edgeSpread : math.avg(edgeSpread, arAdj, csAdj)
spreadP   = spreadPrimary == "Consensus (median)" ? medSpread : spreadRaw
spreadBps = spreadP * 10000.0                       // proportional -> basis points

// ---------------------------------------------------------------------
// PRICE IMPACT  (Amihud + high-low refinement + Kyle lambda)
// ---------------------------------------------------------------------
dollarVol = _v * _c
// classic Amihud: |ret| / dollar volume (scaled for readability)
amiClassic = useVol and dollarVol > 0 ? math.abs(ret) / dollarVol : na
// high-low refinement (Realized Illiquidity): use intrabar range instead of |ret|
hlRange = (_h - _l) / _c
amiHL = useVol and dollarVol > 0 ? hlRange / dollarVol : na
amiRaw = nz(amiHL, nz(amiClassic, 0.0))
amihud = ta.sma(amiRaw, impLen) * 1e9               // scaled

// Kyle's lambda: TRUE rolling regression slope of return on signed volume
// slope = cov(ret, signedVol) / var(signedVol)
sgn    = ret > 0 ? 1.0 : ret < 0 ? -1.0 : 0.0
signedVol = sgn * _v
// Kyle lambda = cov(ret, signedVol)/var(signedVol). Pine has no ta.covariance,
// so compute covariance as E[xy] - E[x]E[y].
kyleCov = ta.sma(ret * signedVol, impLen) - ta.sma(ret, impLen) * ta.sma(signedVol, impLen)
kyleVar = ta.variance(signedVol, impLen)
kyleSlope = useVol and kyleVar > 0 ? math.abs(kyleCov / kyleVar) : na
kyleLam = kyleSlope

// Anchored VWAP — anchor point depends on user choice (default: last MAJOR swing, held)
// All ta.* calls hoisted so they run every bar (consistency).
swLen = math.max(3, swingStrength)
ph = ta.pivothigh(high, swLen, swLen)
pl = ta.pivotlow(low, swLen, swLen)
volHiBar = ta.highest(volume, mapLook)
isNewSession = ta.change(time("D"))   != 0
isNewWeek    = ta.change(time("W"))   != 0
isNewMonth   = ta.change(time("M"))   != 0
isVolSpike   = not na(volume) and volume >= volHiBar and volume > 0

// decide whether to (re)anchor this bar
reAnchor = false
if vwapAnchor == "Last major swing"
    // a pivot confirmed with swingStrength bars each side IS a major swing;
    // re-anchor to it and hold until the next major swing — minor wiggles
    // (which never form a strength-N pivot) do not reset the line.
    reAnchor := not na(ph) or not na(pl)
else if vwapAnchor == "Session open"
    reAnchor := isNewSession
else if vwapAnchor == "Week open"
    reAnchor := isNewWeek
else if vwapAnchor == "Month open"
    reAnchor := isNewMonth
else
    reAnchor := isVolSpike

var float avNum = na
var float avDen = na
if reAnchor or na(avNum)
    avNum := 0.0
    avDen := 0.0
avNum := nz(avNum) + hlc3 * (useVol ? _v : 1.0)
avDen := nz(avDen) + (useVol ? _v : 1.0)
avwap = avDen > 0 ? avNum / avDen : na
// plain-language tag for the line label
vwapWord = vwapAnchor == "Session open" ? "since today's open" : vwapAnchor == "Week open" ? "since this week" : vwapAnchor == "Month open" ? "since this month" : vwapAnchor == "Highest-volume bar" ? "since the big-volume bar" : "since the last major swing"
vwapSide = na(avwap) ? "—" : close >= avwap ? "above fair value" : "below fair value"
vwapSideCol2 = na(avwap) ? color.gray : close >= avwap ? cGreen : cRed
// trend colour for the line: price side + slope agreement
vwapRising = not na(avwap) and not na(avwap[1]) and avwap >= avwap[1]
vwapUp = not na(avwap) and (close >= avwap) and vwapRising
vwapDn = not na(avwap) and (close < avwap) and not vwapRising
vwapTrendCol = na(avwap) ? color.gray : vwapUp ? cGreen : vwapDn ? cRed : cThin   // amber = mixed (price one side, slope the other)
var label vwapTag = na
if showVwap and barstate.islast and not na(avwap)
    label.delete(vwapTag)
    vwapTag := label.new(bar_index + 2, avwap, "Fair value (" + vwapWord + ")", style=label.style_label_left, color=color.new(vwapTrendCol, 12), textcolor=txtOn(vwapTrendCol), size=size.tiny)

// illiquidity jump flag (sudden liquidity withdrawal)
amiMean = ta.sma(amiRaw, rankLen)
amiSd   = ta.stdev(amiRaw, rankLen)
illiqJump = useVol and not na(amiSd) and amiSd > 0 and (amiRaw - amiMean) / amiSd >= 3.0

// ---------------------------------------------------------------------
// ORDER IMBALANCE  (tick-rule signed volume + autocorrelation)
// ---------------------------------------------------------------------
clv = (_h - _l) != 0 ? ((_c - _l) - (_h - _c)) / (_h - _l) : 0.0   // close-location value [-1,1]
sv  = useVol ? clv * _v : clv                                      // signed proxy
imbSum = math.sum(sv, imbLen)
volSumRaw = math.sum(_v, imbLen)
volSum = useVol ? volSumRaw : imbLen
imbalance = volSum != 0 ? imbSum / volSum : 0.0                    // [-1,1]
imbAc = ta.correlation(sv, sv[1], imbLen)                          // flow persistence

// ---------------------------------------------------------------------
// PERCENTILE NORMALIZATION (0..100; higher = more illiquid where noted)
// ---------------------------------------------------------------------
spreadPct = ta.percentrank(spreadP, rankLen)        // high = wide spread = illiquid
amihudPR  = ta.percentrank(amihud, rankLen)
kylePR    = ta.percentrank(kyleLam, rankLen)
depthPR   = ta.percentrank(ta.sma(dollarVol, impLen), rankLen)
impactPct = useVol ? amihudPR : na                  // high = high impact = illiquid
kylePct   = useVol ? kylePR : na
depthProxy = useVol ? depthPR : na                  // high = deep

// composite Liquidity Score 0..100 (HIGH = liquid/good)
// NOTE: volatility is deliberately NOT a term here — it only de-biases the
// spread (above) and forms the independent vol axis (below).
illiqBlend = useVol ? math.avg(nz(spreadPct,50), nz(impactPct,50), nz(kylePct,50)) : nz(spreadPct, 50)
liqScore = 100 - illiqBlend
liqScore := useVol and not na(depthProxy) ? math.min(100, liqScore*0.8 + depthProxy*0.2) : liqScore

// regime
state = illiqJump ? "STRESSED" : liqScore >= 66 ? "DEEP" : liqScore >= 40 ? "NORMAL" : liqScore >= 20 ? "THIN" : "STRESSED"
stateCol = state == "DEEP" ? cDeep : state == "NORMAL" ? cNorm : state == "THIN" ? cThin : cStress

// ---------------------------------------------------------------------
// SPATIAL LIQUIDITY MAP  (volume-at-price -> support/resistance, walls, gaps)
//   Colour logic (directional, traffic-light):
//     GREEN below price = support (buyers)   RED above price = resistance (sellers)
//     Thick zone = a WALL (price struggles)  Thin zone = open road (price slides)
// ---------------------------------------------------------------------
var box[]   zoneBoxes = array.new<box>()
var float[] binVol = array.new<float>(mapBins, 0.0)
var line[]  srLines  = array.new<line>()
var label[] srLabels = array.new<label>()
var float thinAbove = na
var float thinBelow = na
hiN = ta.highest(high, mapLook)
loN = ta.lowest(low, mapLook)
if showMap and barstate.islast and not na(hiN) and not na(loN) and hiN > loN
    // clear previous drawings
    if array.size(zoneBoxes) > 0
        for i = 0 to array.size(zoneBoxes) - 1
            box.delete(array.get(zoneBoxes, i))
        array.clear(zoneBoxes)
    if array.size(srLines) > 0
        for i = 0 to array.size(srLines) - 1
            line.delete(array.get(srLines, i))
        array.clear(srLines)
    if array.size(srLabels) > 0
        for i = 0 to array.size(srLabels) - 1
            label.delete(array.get(srLabels, i))
        array.clear(srLabels)
    binH = (hiN - loN) / mapBins
    for b = 0 to mapBins - 1
        array.set(binVol, b, 0.0)
    // accumulate: time-decay weighting + spread each bar across its high-low range
    decayK = decayHL > 0 ? math.log(2.0) / decayHL : 0.0
    for i = 0 to mapLook - 1
        bvRaw = useVol ? nz(volume[i]) : 1.0
        wDecay = decayHL > 0 ? math.exp(-decayK * i) : 1.0
        bvW = bvRaw * wDecay
        if distrib
            // distribute across the bins the bar's range spans
            bhi = high[i]
            blo = low[i]
            lo_b = math.max(0, math.min(mapBins - 1, int(math.floor((blo - loN) / binH))))
            hi_b = math.max(0, math.min(mapBins - 1, int(math.floor((bhi - loN) / binH))))
            nb = hi_b - lo_b + 1
            share = bvW / math.max(1, nb)
            for bb = lo_b to hi_b
                array.set(binVol, bb, array.get(binVol, bb) + share)
        else
            midp = (low[i] + high[i]) / 2
            bin = math.max(0, math.min(mapBins - 1, int(math.floor((midp - loN) / binH))))
            array.set(binVol, bin, array.get(binVol, bin) + bvW)
    float vmax = array.max(binVol)
    float vmin = array.min(binVol)
    float vtot = array.sum(binVol)
    // --- POC + Value Area (CME 70% expansion algorithm) ---
    int pocBin = array.indexof(binVol, vmax)
    float vaVol = array.get(binVol, pocBin)
    float vaTarget = vtot * vaPct / 100.0
    int vaUp = pocBin
    int vaDn = pocBin
    for _x = 0 to mapBins * 2
        if vaVol >= vaTarget
            break
        upV = vaUp < mapBins - 1 ? array.get(binVol, vaUp + 1) : -1.0
        dnV = vaDn > 0 ? array.get(binVol, vaDn - 1) : -1.0
        if upV < 0 and dnV < 0
            break
        if upV >= dnV
            vaUp := vaUp + 1
            vaVol := vaVol + upV
        else
            vaDn := vaDn - 1
            vaVol := vaVol + dnV
    pocY = loN + (pocBin + 0.5) * binH
    vahY = loN + (vaUp + 1) * binH
    valY = loN + vaDn * binH
    leftX  = bar_index - mapLook
    rightX = bar_index + 2
    thinAbove := na
    thinBelow := na
    // draw heatmap + collect thin zones
    for b = 0 to mapBins - 1
        v = array.get(binVol, b)
        frac = vmax > vmin ? (v - vmin) / (vmax - vmin) : 0.0
        yTop = loN + (b + 1) * binH
        yBot = loN + b * binH
        zc   = loN + (b + 0.5) * binH
        isThin = frac * 100 <= thinPct
        above = zc > close
        // directional traffic-light colour
        col = color(na)
        if isThin
            // open road = faint, neutral-bright (price moves freely here)
            col := color.new(cDeep, 90)
        else
            // a wall: red if above price (resistance), green if below (support)
            // stronger wall (higher frac) = more opaque
            t = math.round(86 - frac*46)
            col := above ? color.new(cStress, t) : color.new(cGreen, t)
        if mapStyle == "Bands" and not isThin
            col := above ? color.new(cStress, 84) : color.new(cGreen, 84)
        if not na(col) and (mapStyle == "Heatmap" or not isThin)
            bx = box.new(leftX, yTop, rightX, yBot, border_color=color.new(col, 96), bgcolor=col)
            array.push(zoneBoxes, bx)
        // nearest thin (open) zones for the panel text
        if isThin
            if above and na(thinAbove)
                thinAbove := zc
            if not above
                thinBelow := zc
    // --- SUPPORT / RESISTANCE anchored to Value Area edges + POC (volume-profile standard) ---
    // Resistance: VAH if above price, else strongest wall above. Support: VAL if below, else strongest wall below.
    float bestAboveV = 0.0
    float bestBelowV = 0.0
    float wallAboveY = na
    float wallBelowY = na
    for b = 0 to mapBins - 1
        v = array.get(binVol, b)
        zc = loN + (b + 0.5) * binH
        if zc > close and v > bestAboveV
            bestAboveV := v
            wallAboveY := zc
        if zc < close and v > bestBelowV
            bestBelowV := v
            wallBelowY := zc
    resY = vahY > close ? vahY : wallAboveY
    supY = valY < close ? valY : wallBelowY
    // POC line (the single fairest price — orange/amber, dashed)
    pocLn = line.new(leftX, pocY, rightX, pocY, color=color.new(cThin, 0), width=1, style=line.style_dashed)
    array.push(srLines, pocLn)
    pocLb = label.new(rightX, pocY, "POC — busiest price (fair value)", style=label.style_label_left, color=color.new(cThin, 15), textcolor=#0a0a0a, size=size.small)
    array.push(srLabels, pocLb)
    // resistance line (red, above)
    if not na(resY)
        ln = line.new(leftX, resY, rightX, resY, color=color.new(cStress, 0), width=2, style=line.style_solid)
        array.push(srLines, ln)
        lb = label.new(rightX, resY, "RESISTANCE — sellers here", style=label.style_label_left, color=color.new(cStress, 10), textcolor=color.white, size=size.small)
        array.push(srLabels, lb)
    // support line (green, below)
    if not na(supY)
        ln2 = line.new(leftX, supY, rightX, supY, color=color.new(cGreen, 0), width=2, style=line.style_solid)
        array.push(srLines, ln2)
        lb2 = label.new(rightX, supY, "SUPPORT — buyers here", style=label.style_label_left, color=color.new(cGreen, 10), textcolor=color.white, size=size.small)
        array.push(srLabels, lb2)
    // --- WALL / open word tags at the single strongest & weakest zone ---
    int strongBin = 0
    int weakBin = 0
    float sVal = -1.0
    float wVal = 1e18
    for b = 0 to mapBins - 1
        v = array.get(binVol, b)
        if v > sVal
            sVal := v
            strongBin := b
        if v < wVal
            wVal := v
            weakBin := b
    wallY = loN + (strongBin + 0.5) * binH
    openY = loN + (weakBin + 0.5) * binH
    wallAbove = wallY > close
    tagWall = label.new(int(leftX + mapLook*0.5), wallY, (wallAbove ? "⊏ WALL — hard to pass up" : "⊏ WALL — strong floor"), style=label.style_label_center, color=color.new(wallAbove ? cStress : cGreen, 25), textcolor=color.white, size=size.small)
    array.push(srLabels, tagWall)
    tagOpen = label.new(int(leftX + mapLook*0.5), openY, "open — price moves fast", style=label.style_label_center, color=color.new(color.gray, 35), textcolor=txtCol, size=size.tiny)
    array.push(srLabels, tagOpen)
    // --- nearest liquidity VOID (a true gap = magnet target) ---
    if showVoid
        voidY = na(thinAbove) and na(thinBelow) ? na : not na(thinAbove) and (na(thinBelow) or (thinAbove - close) < (close - thinBelow)) ? thinAbove : thinBelow
        if not na(voidY)
            vLab = label.new(rightX, voidY, "◎ likely pull toward here", style=label.style_label_left, color=color.new(cNorm, 20), textcolor=color.white, size=size.tiny)
            array.push(srLabels, vLab)

// ---------------------------------------------------------------------
// DECISION LAYER  (now volatility-aware)
// ---------------------------------------------------------------------
pv = tickVal > 0 ? tickVal : syminfo.pointvalue
// slippage estimate (one side): half (vol-adjusted) spread + a volatility
// timing component (adverse drift while the order works).
halfSpread = spreadP * close / 2.0
volTimePts = volAdjOn and volReady ? volTimingK * volForecast * close : 0.0
slipPts = halfSpread + volTimePts
slipCcy = slipPts * pv

// sizing: take the MORE BINDING of the liquidity budget and the vol budget
liqSizeMult = state == "DEEP" ? 1.0 : state == "NORMAL" ? 0.75 : state == "THIN" ? 0.4 : 0.0
volSizeMult = not (volAdjOn and volReady) ? 1.0 : volRegime == "Low" ? 1.0 : volRegime == "Normal" ? 0.85 : volRegime == "High" ? 0.6 : 0.35
sizeMult = math.min(liqSizeMult, volSizeMult)
sizeBound = not (volAdjOn and volReady) ? "liquidity" : volSizeMult < liqSizeMult ? "vol-limited" : liqSizeMult < volSizeMult ? "liquidity-limited" : "both"

orderAdvice = state == "DEEP" ? "Market OK" : state == "NORMAL" ? "Limit preferred" : state == "THIN" ? "Limit only · expect slippage" : "Stand aside / minimal size"
travelTxt = na(thinAbove) and na(thinBelow) ? "balanced" : not na(thinAbove) and (na(thinBelow) or (thinAbove - close) < (close - thinBelow)) ? "thin above → breakout fuel" : "thin below → air-pocket risk"
imbTxt = imbalance > 0.15 ? "▲ buyers" : imbalance < -0.15 ? "▼ sellers" : "balanced"
imbCol = imbalance > 0.15 ? cGreen : imbalance < -0.15 ? cRed : color.gray

// --- two-axis context: liquidity regime x volatility regime ---
context = state == "STRESSED" ? "High risk — reduce / wait" : (volAdjOn and volReady and volRegime == "Extreme") ? "Extreme vol — trade small / wait" : (state == "THIN" and (volRegime == "High" or volRegime == "Extreme")) ? "Air-pocket risk — thin & volatile" : (state == "THIN" and volRegime == "Low") ? "Complacent — gap risk on thin liquidity" : ((state == "DEEP" or state == "NORMAL") and volRegime == "High") ? "Orderly volatility — tradeable" : "Normal conditions"
contextCol = str.contains(context, "risk") or str.contains(context, "wait") or str.contains(context, "Air-pocket") ? cRed : str.contains(context, "Orderly") ? cAmber : str.contains(context, "Complacent") ? cAmber : cGreen

// ---- PLAIN-LANGUAGE TRANSLATIONS (Simple mode) ----
// liquidity in plain words
liqWord = state == "DEEP" ? "Good" : state == "NORMAL" ? "OK" : state == "THIN" ? "Thin" : "Poor"
// trade cost from spread percentile -> Low/Medium/High
costWord = spreadPct >= 66 ? "High" : spreadPct >= 40 ? "Medium" : "Low"
costCol  = spreadPct >= 66 ? cRed : spreadPct >= 40 ? cAmber : cGreen
// pressure in plain words
pressWord = imbalance > 0.15 ? "Buyers in control" : imbalance < -0.15 ? "Sellers in control" : "Evenly matched"
// size in plain words
sizeWord = sizeMult >= 1.0 ? "Full" : sizeMult >= 0.75 ? "Most" : sizeMult >= 0.4 ? "Half" : "Wait"
sizeCol  = sizeMult >= 0.75 ? cGreen : sizeMult >= 0.4 ? cAmber : cRed
// orders in plain words
orderWord = state == "DEEP" ? "Market is fine" : state == "NORMAL" ? "Use limit orders" : state == "THIN" ? "Limit orders only" : "Wait for liquidity"
orderCol  = state == "DEEP" ? cGreen : state == "STRESSED" ? cRed : cAmber
// watch-out (air-pocket) in plain words
watchWord = na(thinAbove) and na(thinBelow) ? "Nothing unusual" : str.contains(travelTxt, "above") ? "Room to run up" : "Fast drops possible below"
watchCol  = str.contains(travelTxt, "above") ? cGreen : str.contains(travelTxt, "below") ? cRed : color.gray
// one-line verdict (liquidity + volatility aware)
verdict = state == "STRESSED" ? "Poor liquidity — best to wait" : (volAdjOn and volReady and volRegime == "Extreme") ? "Volatile — trade small, limits only" : (state == "THIN" ? "Thin liquidity — trade small with limit orders" : (sizeWord + " size, " + str.lower(pressWord) + ", " + str.lower(orderWord)))
verdictCol = stateCol

// ---------------------------------------------------------------------
// PLOTS — state strip + jump marker
// ---------------------------------------------------------------------
plot(useVol ? na : na)  // keep plot count anchored
bgRib = color.new(stateCol, 80)
plotshape(true, "State ribbon", style=shape.square, location=location.bottom, color=bgRib, size=size.tiny)
plotchar(illiqJump, "Illiquidity jump", "✦", location.abovebar, color=cStress, size=size.tiny)
// Anchored VWAP — glow stack (wide transparent halos) + bright core, trend-coloured
vwapPlot = showVwap and not na(avwap) ? avwap : na
plot(vwapPlot, "VWAP glow 3", color=color.new(vwapTrendCol, 88), linewidth=8, style=plot.style_line)
plot(vwapPlot, "VWAP glow 2", color=color.new(vwapTrendCol, 78), linewidth=6, style=plot.style_line)
plot(vwapPlot, "VWAP glow 1", color=color.new(vwapTrendCol, 60), linewidth=4, style=plot.style_line)
plot(vwapPlot, "Fair value (Anchored VWAP)", color=color.new(vwapTrendCol, 0), linewidth=2, style=plot.style_line)

// data-window internals (for power users / verification)
plot(spreadBps, "Spread (bps, vol-adj)", display=display.data_window)
plot(medSpreadRaw * 10000.0, "Spread consensus RAW (bps)", display=display.data_window)
plot(liqScore,  "Liquidity score", display=display.data_window)
plot(useVol ? amihud : na, "Amihud (scaled)", display=display.data_window)
plot(useVol ? kyleLam : na, "Kyle lambda", display=display.data_window)
plot(imbalance, "Order imbalance", display=display.data_window)
plot(useVol ? nz(imbAc) : na, "Flow autocorr", display=display.data_window)
plot(volReady ? volForecast * 10000.0 : na, "Vol forecast (bps/bar)", display=display.data_window)
plot(volReady ? volPct : na, "Vol forecast %ile", display=display.data_window)
plot(volShrink, "Vol de-bias weight", display=display.data_window)
plot(volReady ? volSizeMult : na, "Vol size mult", display=display.data_window)

// ---------------------------------------------------------------------
// DECISION PANEL
// ---------------------------------------------------------------------
fSize = size.small   // single uniform font size for the whole panel
var table pnl = table.new(panelPosV, 2, 20, border_width=0, frame_width=1, frame_color=frameCol)
prow(r, k, v, vbg) =>
    table.cell(pnl, 0, r, k, text_color=txtDim, text_size=fSize, text_halign=text.align_left,  bgcolor=cellBg)
    table.cell(pnl, 1, r, v, text_color=txtOn(vbg), text_size=fSize, text_halign=text.align_right, bgcolor=color.new(vbg, 12))
if showPnl and barstate.islast
    simple = panelMode == "Simple"
    hdrTxt = simple ? "TRADE CHECK" : "LIQUIDITY"
    table.cell(pnl, 0, 0, hdrTxt, text_color=txtCol, text_size=fSize, bgcolor=hdrBg)
    table.cell(pnl, 1, 0, simple ? liqWord : state, text_color=txtOn(stateCol), text_size=fSize, bgcolor=color.new(stateCol, 0))
    int ri = 1
    if simple
        // ---- SIMPLE: plain words only ----
        prow(ri, "Liquidity",   liqWord + (state == "DEEP" ? " — trade normally" : state == "NORMAL" ? "" : state == "THIN" ? " — be careful" : " — risky"), stateCol)
        ri := ri + 1
        prow(ri, "Volatility",  volAdjOn ? (volWord + (volReady ? "" : " (warming)")) : "off", volRegCol)
        ri := ri + 1
        prow(ri, "Trade cost",  costWord, costCol)
        ri := ri + 1
        prow(ri, "Pressure",    pressWord, imbCol)
        ri := ri + 1
        prow(ri, "Position size", sizeWord + (volAdjOn and volReady ? " (" + sizeBound + ")" : ""), sizeCol)
        ri := ri + 1
        prow(ri, "Orders",      orderWord, orderCol)
        ri := ri + 1
        prow(ri, "Watch out",   watchWord, watchCol)
        ri := ri + 1
        prow(ri, "Context",     context, contextCol)
        ri := ri + 1
        prow(ri, "Fair value",  vwapSide, vwapSideCol2)
        ri := ri + 1
        // verdict spanning line
        table.cell(pnl, 0, ri, "→ " + verdict, text_color=txtOn(verdictCol), text_size=fSize, text_halign=text.align_left, bgcolor=color.new(verdictCol, 20))
        table.cell(pnl, 1, ri, "", bgcolor=color.new(verdictCol, 20))
        ri := ri + 1
    else
        // ---- PRO: full estimator readout ----
        prow(ri, "Score",        str.tostring(math.round(liqScore)) + " / 100", stateCol)
        ri := ri + 1
        prow(ri, "Spread",       str.tostring(spreadBps, "#.##") + " bps" + (volShrink > 0 ? " ·adj" : ""), spreadPct >= 66 ? cRed : spreadPct >= 40 ? cAmber : cGreen)
        ri := ri + 1
        prow(ri, "Vol forecast", volAdjOn and volReady ? (str.tostring(math.round(volPct)) + " %ile · " + volRegime) : (volAdjOn ? "warming" : "off"), volRegCol)
        ri := ri + 1
        prow(ri, "Impact (Amihud)", useVol ? (str.tostring(math.round(nz(impactPct))) + " %ile") : "no volume", not useVol ? color.gray : impactPct >= 66 ? cRed : impactPct >= 40 ? cAmber : cGreen)
        ri := ri + 1
        prow(ri, "Kyle λ",       useVol ? (str.tostring(math.round(nz(kylePct))) + " %ile") : "no volume", not useVol ? color.gray : kylePct >= 66 ? cRed : cGreen)
        ri := ri + 1
        prow(ri, "Depth",        useVol ? (str.tostring(math.round(nz(depthProxy))) + " %ile") : "no volume", not useVol ? color.gray : depthProxy >= 50 ? cGreen : cAmber)
        ri := ri + 1
        prow(ri, "Imbalance",    imbTxt + " (" + str.tostring(imbalance, "#.00") + ")", imbCol)
        ri := ri + 1
        prow(ri, "Flow persist", useVol ? str.tostring(nz(imbAc), "#.00") : "—", nz(imbAc) > 0.2 ? cNorm : color.gray)
        ri := ri + 1
        prow(ri, "Est. slippage", str.tostring(slipPts, format.mintick) + (pv > 0 ? " (" + str.tostring(slipCcy, "#.##") + ")" : "") + (volTimePts > 0 ? " +vol" : ""), spreadPct >= 50 ? cAmber : cGreen)
        ri := ri + 1
        prow(ri, "Suggest size", sizeMult == 0 ? "skip" : "×" + str.tostring(sizeMult, "#.0#") + " of " + str.tostring(riskPct, "#.0#") + "% · " + sizeBound, sizeMult >= 0.75 ? cGreen : sizeMult >= 0.4 ? cAmber : cRed)
        ri := ri + 1
        prow(ri, "Order type",  orderAdvice, state == "DEEP" ? cGreen : state == "STRESSED" ? cRed : cAmber)
        ri := ri + 1
        prow(ri, "Context",     context, contextCol)
        ri := ri + 1
        prow(ri, "Air-pockets", travelTxt, str.contains(travelTxt, "above") ? cGreen : str.contains(travelTxt, "below") ? cRed : color.gray)
        ri := ri + 1
        prow(ri, "Fair value (VWAP)", na(avwap) ? "—" : str.tostring(avwap, format.mintick) + " · " + vwapSide, vwapSideCol2)
        ri := ri + 1
        prow(ri, "Mode",        useVol ? "full (volume)" : "price-only", useVol ? cNorm : color.gray)
        ri := ri + 1

// ---------------------------------------------------------------------
// MAP LEGEND (plain-language, so the colours are self-explanatory)
// ---------------------------------------------------------------------
var label legA = na
if showMap and barstate.islast and not na(hiN)
    label.delete(legA)
    legTxt = "GREEN below = support (buyers)   ·   RED above = resistance (sellers)\nSolid colour = a WALL price struggles at   ·   faint = open road, price moves fast"
    legA := label.new(bar_index - mapLook, hiN, legTxt, style=label.style_label_lower_right,
         color=color.new(chart.bg_color, 15), textcolor=txtCol, size=size.small, textalign=text.align_left)
var string prevState = na
stateChanged = not na(prevState) and prevState != state
if barstate.isconfirmed
    prevState := state
alertcondition(illiqJump and not illiqJump[1], "Liquidity withdrawal", "LMX: sudden liquidity withdrawal on {{ticker}} {{interval}}")
alert(stateChanged ? "LMX regime: " + state + " | vol=" + volRegime + " score=" + str.tostring(math.round(liqScore)) + " spread=" + str.tostring(spreadBps, "#.0") + "bps imb=" + str.tostring(imbalance, "#.00") + " | " + syminfo.ticker + " " + timeframe.period : na, alert.freq_once_per_bar_close)
````
