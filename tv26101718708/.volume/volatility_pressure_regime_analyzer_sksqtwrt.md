# Volatility Pressure & Regime Analyzer

- url: https://www.tradingview.com/script/sksqtWRt-Volatility-Pressure-Regime-Analyzer/
- type: indicator
- pine_id: PUB;f113dd3b485b4709894db5581b713f33
- version: 3.0

## Description

Volatility Pressure & Regime Analyzer [VPRA]

## What this script does

VPRA estimates **when a market is loading energy for an outsized move, how large that move could be, and whether the current regime favors chasing or fading the breakout**. It condenses this into one on-chart verdict panel, directional signal markers, a regime ribbon, and a forecast of the expected move in ATR and points.

It works on **any symbol, any market, any timeframe**. A related volatility index and a companion symbol (the underlying if you chart a derivative, or vice versa) are optional inputs that sharpen the analysis; both can be disabled and the model renormalizes to price-only mode automatically.

## Why these components are combined (mashup justification)

Each module answers a question the others cannot, and the signal only fires when their answers agree. None of them is a stock indicator pasted alongside another — they are inputs to a single pressure model:

1. **Compression (ATR percentile)** answers *"is energy being stored?"* Quiet ranges precede expansion, but compression alone says nothing about direction or timing.
2. **Implied-vs-realized volatility dislocation** (optional vol index) answers *"is the options market mispricing the calm?"* A large gap between implied and realized volatility marks complacency or stress that compression alone cannot see.
3. **Basis tension** (optional companion symbol) answers *"is positioning leaning?"* Momentum in the derivative-to-underlying spread, and outright backwardation, reveal funding pressure and de-risking invisible in a single price series.
4. **Convexity and trend inefficiency** (return acceleration, efficiency ratio) answer *"is price behavior becoming unstable?"*
   These four are blended into one **Pressure score (0–100)**, percent-ranked against its own history so thresholds adapt to every symbol and timeframe.
5. **A variance-ratio regime filter** answers *"will the break run or get faded?"* The ratio of k-bar to 1-bar return variance classifies the tape as mean-reverting (pinning) or trending (amplifying). Breakouts in a pinning regime are statistically more likely to fail, so the script can label or skip them.
6. **A multi-timeframe trend filter (Ichimoku cloud bias on the chart TF + three higher TFs)** answers *"is the release direction supported by structure?"* It grades signals rather than generating them. Higher-timeframe values are taken from **closed bars by default, so the confluence grade does not repaint**.
7. **Session, expiry, gap and event context** scale the expected-move forecast: an expiry-afternoon release during a volatility spike forecasts a larger move than a sleepy mid-session one.

Removing any module degrades a specific, named capability — that is the test the combination was built to pass.

## How a signal is generated

A marker prints only when **all** of the following align: pressure has reached a high percentile of its own history within a short lookback ("loaded"), the current bar shows a genuine range expansion ("release"), the condition persists for a confirmation bar count, a debounce gap has passed, and (optionally) the regime and trend filters pass. Direction is scored from **trigger-break** (close beyond the prior N-bar extreme), **close location** within the bar, and short momentum.

Marker color encodes the inferred event type: expiry-session releases, volatility-co-movement squeezes (price and vol index moving together — a short-covering tell), or plain expansions. The glow ring encodes how many higher timeframes agree. An ⓘ label stores a full diagnostic snapshot (pressure, regime, instability, basis, energy, session, expected move) in its tooltip for every signal.

## How to use it

- Apply to a liquid symbol; set "This chart is" to Derivative or Underlying, point the companion and volatility-index inputs at your market's related symbols (or disable them), and set your session hours and expiry weekday.
- Read the panel top-down: **Regime** (chase vs fade), **Pressure/Energy** (how loaded), **Move size** (forecast), **Trend align / HTF** (structure), **Triggers** (the price levels that confirm).
- Use the "Filter" modes to suppress signals against regime or higher-timeframe structure, or leave them as badges and judge manually.
- The advanced rows show per-type follow-through statistics (hit rate, average favorable and adverse excursion in ATR) and an early-vs-late history split as a coarse robustness check. **These are in-sample descriptive statistics, not a backtest.** A companion strategy script with identical logic is available for proper backtesting with costs.
- Alerts: per-signal dynamic alert with all values (webhook-ready), plus static conditions for expiry signals, releases, critical pressure, and vol shocks.

## Originality

The pressure blend (compression x vol-dislocation x basis tension x convexity x inefficiency, percent-rank normalized), the variance-ratio regime gate applied to breakout qualification, the compression-energy budget, and the per-type MFE/MAE statistics with an early/late split are original constructions written from first principles for this script. The only classical components used are public-domain building blocks (ATR, Bollinger/Keltner-style compression logic via ATR percentile, Ichimoku cloud bias as a trend filter, Kaufman efficiency ratio), each justified above.

## Limitations (please read)

- Dealer-positioning effects (often discussed as gamma/vanna/charm) are **inferred from price, volatility and basis behavior**. This script does not and cannot read option-chain open interest. Labels such as "gamma blast" describe an expiry-session release pattern, not a measured dealer position.
- All on-panel statistics are computed on the loaded chart history and will differ across symbols, timeframes and history length.
- Higher-timeframe confluence uses closed HTF bars by default (no repaint); the current chart bar still forms in real time, as with any script.
- Expected-move figures are model estimates, not guarantees.

This script is for education and analysis. It is **not financial advice**; trade at your own risk and test before use.

## Source Code

````pine
//@version=6
// =====================================================================
// VOLATILITY PRESSURE & REGIME ANALYZER  [VPRA]  v2  (+ vol forecast)
// ---------------------------------------------------------------------
// METHODOLOGY (price + optional volatility index + optional companion
// symbol — no option-chain data is used or required):
//   Pressure  = blend of compression (ATR %ile), implied-vs-realized vol
//               dislocation, basis tension, convexity (return acceleration),
//               and trend inefficiency.
//   Forecast  = a compact PATH-DEPENDENT volatility forecast (reduced
//               Guyon-Lekeufack 2023) predicts next-period realized vol
//               from the price path; it sharpens the dislocation factor
//               and anchors the expected-move magnitude (see v2 UPDATE).
//   Signal    = pressure loaded to a high percentile + a real range release,
//               direction from trigger-break + close-location + momentum.
//   Type      = GAMMA BLAST on derivative-expiry sessions, SQUEEZE when the
//               volatility index co-moves with price, else EXPANSION.
//   Regime    = variance-ratio proxy: VR>1 trending/amplifying,
//               VR<1 mean-reverting/pinning. Inferred from price behaviour.
//   Flow      = vol-index ROC + vol-of-vol instability, basis backwardation
//               stress, expiry intraday clock, session phases, gap z-score,
//               manual event days. These scale the expected-move forecast.
//   Energy    = compression integral ("stored") vs expansion ("spent").
//   Stats     = per-type MFE/MAE follow-through + early/late split.
//
// ---------------------------------------------------------------------
// v2 UPDATE — PATH-DEPENDENT VOLATILITY FORECAST
// ---------------------------------------------------------------------
// Adds a compact forecast of next-period realized volatility built from
// the price path (reduced Guyon-Lekeufack 2023: a leverage feature R1 +
// an activity feature sqrt(R2), each a fast+slow kernel blend of the
// CONFIRMED, lagged returns, lightly calibrated to THIS chart's realized
// vol). It upgrades two previously heuristic pieces and adds one gauge:
//   (1) DISLOCATION — the implied-vs-realized factor now compares the
//       volatility index against the FORECAST of realized vol, not the
//       trailing realized vol. Implied-vs-expected is the variance-risk-
//       premium reading; trailing realized lags and is symmetric.
//   (2) EXPECTED MOVE — the move magnitude (expATR) is now anchored to
//       the fitted forecast (converted to ATR units) and modulated by
//       pressure/flow, instead of a fixed linear pressure slope. The
//       expected move now widens/narrows with the model's own vol level.
//   (3) TRUST GAUGE (toggle) — a rolling R-squared of forecast vs
//       realized vol shows how much of realized-vol variance the path
//       explains on this symbol; low fit flags a structural break.
//
// The forecast is deliberately NOT added as another term in the pressure
// blend — that would double-count the compression / vol-level signal the
// pressure factors already carry. It is used only where it fills a gap
// (dislocation comparison and expected-move magnitude) and as an
// independent trust gauge. Turning the forecast off restores exact v1
// behaviour. The forecast is price-only, so (2) and (3) work even on
// assets without a volatility index; (1) needs the volatility index.
//
// DATA SOURCES (fully configurable — works on any asset, any market):
//   * Price source selectable (close/hl2/etc on the current chart).
//   * Volatility index optional; disable for assets without one
//     (vol factors switch off and weights renormalize).
//   * Companion symbol optional (underlying if chart is a derivative, or
//     derivative if chart is the underlying); enables basis factors.
//
// LIMITATIONS (read before trusting):
//   * Dealer-flow effects (gamma/vanna/charm) are INFERRED from price, vol
//     and basis behaviour — true positioning needs option-chain open
//     interest, which Pine cannot access.
//   * The volatility forecast is a REDUCED form (leverage + activity, light
//     calibration; no upside-convexity / HAR / power-law tail of the full
//     model). It forecasts a smoothed realized vol and is itself uncertain;
//     the realized-vol literature explains a minority of realized-vol
//     variance even at its best. Trust it more when the fit gauge is high.
//   * All statistics are computed on loaded chart history (in-sample). The
//     early/late split is a coarse robustness check, not a true backtest.
//   * "Confirmed HTF bars" mode (default ON) removes higher-timeframe
//     repaint; current-bar values still form live until close.
//   * Forecasts are estimates. Nothing here is financial advice.
// =====================================================================
indicator("Volatility Pressure & Regime Analyzer 2.0", "VPRA 2.0", overlay=true,
     max_boxes_count=80, max_labels_count=200, max_lines_count=80, calc_bars_count=3000)

// ---------------------------------------------------------------------
// INPUTS
// ---------------------------------------------------------------------
enum Phase
    dormant    = "DORMANT"
    loading    = "LOADING"
    compressed = "COMPRESSED"
    critical   = "CRITICAL"
    detonation = "DETONATION"
    exhaustion = "EXHAUSTION"

gD      = "Data sources"
priceSrc= input.source(close, "Price source", group=gD,
             tooltip="Series used for return, momentum and efficiency calculations. OHLC structure (ranges, triggers) always uses the chart's high/low/close.")
chartIs = input.string("Derivative", "This chart is", options=["Derivative","Underlying"], group=gD,
             tooltip="Derivative = futures/perpetual/CFD chart with an underlying index or spot. Underlying = spot/index chart with a related derivative.")
useComp = input.bool(true, "Use companion symbol (basis factors)", group=gD,
             tooltip="The other leg of the pair: the underlying if this chart is a derivative, or the derivative if this chart is the underlying. Enables basis tension and backwardation factors. Disable for assets without a related contract — weights renormalize automatically.")
compIn  = input.symbol("NSE:NIFTY", "Companion symbol", group=gD)
useVol  = input.bool(true, "Use volatility index", group=gD,
             tooltip="An implied-volatility index related to this asset. Enables vol-dislocation, squeeze co-direction and vol-shock factors. Disable for assets without one — the script runs in price-only mode and weights renormalize.")
volIn   = input.symbol("NSE:INDIAVIX", "Volatility index symbol", group=gD)

gE      = "Expiry engine"
expDay  = input.string("Tuesday", "Weekly expiry day",
             options=["Monday","Tuesday","Wednesday","Thursday","Friday"], group=gE,
             tooltip="Set to the weekday on which this asset's options/futures expire. Used only for the expiry-session classification and intraday clock.")
monthly = input.bool(false, "Monthly only (last <day> of month)", group=gE)
sH = input.int(9,  "Session start hour", group=gE), sM = input.int(15, "min", group=gE)
eH = input.int(15, "Session end hour",   group=gE), eM = input.int(30, "min", group=gE)
emBandK = input.float(1.0, "EM band width (× session expected-move)", minval=0.25, maxval=3.0, step=0.05, group=gE, tooltip="Width of the exported expected-move band (→Conf: EM band pos), as a multiple of the session-horizon expected move (per-bar expPts × √session-bars, captured at the session open). Lower = tighter band that flags 'at the edge' more often; higher = only extreme stretch counts. This is a MODEL-based EM proxy from the price-path forecast, NOT the option-implied straddle move.")

gW      = "Windows"
volLen  = input.int(20, "Vol window",        minval=5,  group=gW)
erLen   = input.int(20, "Efficiency window", minval=5,  group=gW)
basLen  = input.int(5,  "Basis momentum",    minval=1,  group=gW)
rankLen = input.int(120,"Percentile window", minval=30, group=gW)
trigLen = input.int(20, "Trigger lookback",  minval=5,  group=gW)

gF      = "Path-dependent vol forecast"
useVolFcast = input.bool(true, "Forecast realized vol from price path", group=gF,
             tooltip="Adds a compact path-dependent volatility forecast (reduced Guyon-Lekeufack 2023: a leverage feature + an activity feature, lightly calibrated to this chart's realized vol). It (1) sharpens the implied-vs-realized dislocation by comparing the volatility index against the FORECAST of realized vol instead of trailing realized vol, and (2) anchors the expected-move magnitude to a fitted forecast instead of a fixed pressure slope. Off = original v1 behaviour. It is NOT added as another pressure factor (that would double-count compression).")
vfFast  = input.int(10, "Vol kernel — fast", minval=2, group=gF, tooltip="Short-memory kernel of the path features.")
vfSlow  = input.int(60, "Vol kernel — slow", minval=5, group=gF, tooltip="Long-memory kernel of the path features.")
vfW     = input.float(0.5, "Fast-vs-slow weight", minval=0, maxval=1, step=0.05, group=gF)
vfCalLen= input.int(150, "Forecast calibration window", minval=20, group=gF, tooltip="Rolling window the leverage+activity model is fit over. Longer = steadier, slower to adapt.")
useFitGauge = input.bool(true, "Show path-vol fit (trust) gauge", group=gF,
             tooltip="Displays the rolling R-squared of the forecast vs realized vol on this symbol — how much of realized-vol variance the price path explains here. Informational: low fit (weak) suggests discounting the vol-based reads through a structural break. Does not block signals.")
coneBars = input.int(10, "Forecast-cone horizon (bars)", minval=1, maxval=200, group=gF, tooltip="Horizon for the exported forecast cone (→Conf: Cone upper / Cone lower), used by the Probability engine as its target/stop bands. Half-width = per-bar expected move (expPts) × √horizon, so the cone is the expected move over this many bars ahead. Larger = farther target/wider stop. This is a MODEL cone from the price-path vol forecast, not a coverage-calibrated confidence band.")

gS      = "Signal sensitivity"
sigPct  = input.float(78, "Very-high-pressure %ile", minval=50, maxval=99, group=gS,
             tooltip="Pressure must reach this percentile of its own recent range. Higher = rarer.")
loadLook= input.int(10, "Spring memory (bars)", minval=1, group=gS,
             tooltip="High pressure must have occurred within this many bars of the release.")
relThr  = input.float(0.75, "Release size (0-1)", minval=0.1, maxval=1.0, group=gS,
             tooltip="How big the range expansion must be to count as a release.")
relBars = input.int(3, "Direction lookback", minval=1, group=gS)
coThr   = input.float(0.40, "Squeeze (VIX co-dir) cutoff", minval=0, maxval=1, group=gS)
confBars= input.int(2, "Confirm bars", minval=1, group=gS)
minGap  = input.int(6,"Min bars between signals", minval=1, group=gS)
critThr = input.float(75, "Critical pressure (panel)", group=gS)
detThr  = input.float(88, "Detonation pressure (panel)", group=gS)
fwdBars = input.int(5,   "Reliability fwd bars", minval=1, group=gS, tooltip="In-sample: bars to measure follow-through after a signal.")
fwdATR  = input.float(1.5,"Reliability target (ATR)", minval=0.1, group=gS)

gC      = "HTF trend confluence (Ichimoku)"
useConf = input.bool(false, "Enable Ichimoku confluence (3 HTF requests — slower load)", group=gC,
             tooltip="Aligns release direction with Ichimoku cloud bias on current + 3 higher timeframes.")
confHTF = input.bool(true, "Confirmed HTF bars (no repaint)", group=gC,
             tooltip="ON = HTF cloud bias from the last CLOSED higher-TF bar (stable, slightly lagged). OFF = live forming HTF bar (faster, can repaint).")
confMode= input.string("Badge (don't block)", "Mode",
             options=["Badge (don't block)","Filter (require agreement)"], group=gC)
minAgree= input.int(3, "Min TFs agreeing (of 4)", minval=1, maxval=4, group=gC)
gateGam = input.bool(true, "Also filter gamma blasts", group=gC,
             tooltip="On = gamma blasts must also pass HTF agreement.")
mlt1    = input.int(3,  "HTF multiple ×1", minval=2, group=gC)
mlt2    = input.int(5,  "HTF multiple ×2", minval=2, group=gC)
mlt3    = input.int(15, "HTF multiple ×3", minval=2, group=gC)
icC     = input.int(9,  "Ichimoku conversion", group=gC)
icB     = input.int(26, "Ichimoku base",       group=gC)
icS     = input.int(52, "Ichimoku span B",     group=gC)
icD     = input.int(26, "Ichimoku displacement", group=gC)

gR      = "Regime & flow proxies"
useReg  = input.bool(true,  "Regime via variance ratio", group=gR,
             tooltip="VR>1 = trending / amplify (negative-gamma-like). VR<1 = mean-reverting / pinning (positive-gamma-like). Inferred from price behaviour — NOT measured dealer gamma.")
vrK     = input.int(5,   "VR horizon k (bars)",  minval=2,  group=gR)
vrLen   = input.int(100, "VR sample window",     minval=20, group=gR)
vrBand  = input.float(0.15,"Regime neutral band", minval=0.0, maxval=0.9, group=gR)
vrSig   = input.bool(true, "Require VR significance (Lo-MacKinlay z)", group=gR, tooltip="Only call AMPLIFY / PIN when the variance ratio is statistically different from 1 (random walk), via the Lo-MacKinlay heteroskedastic z-statistic. Cuts regime flips on noise.")
vrZcrit = input.float(1.64, "VR significance z", minval=1.0, maxval=3.0, step=0.05, group=gR)
regMode = input.string("Badge (don't block)", "Regime gate",
             options=["Badge (don't block)","Filter (require not-pinning)"], group=gR,
             tooltip="Filter = skip non-gamma releases while in a pinning regime (more fakeouts there).")
regGam  = input.bool(true, "Also gate gamma blasts by regime", group=gR)
useShock= input.bool(true,  "Vol-shock & instability (VIX ROC, vol-of-vol)", group=gR)
vrocLen = input.int(5,   "VIX ROC window",        minval=1,  group=gR)
shockThr= input.float(8.0,"Vol-shock threshold (VIX % move)", minval=1, group=gR)
vvolLen = input.int(20,  "Vol-of-vol window",     minval=5,  group=gR)
useBasis= input.bool(true,  "Basis backwardation stress", group=gR)
backThr = input.float(0.05,"Backwardation threshold (basis %)", group=gR)
useCharm= input.bool(true,  "Expiry charm clock (intraday)", group=gR,
             tooltip="Morning-pin -> power-hour acceleration weighting on expiry day.")
applyFlow=input.bool(true,  "Scale expected move by instability + charm", group=gR)

gX      = "Session & events (intraday)"
useSess = input.bool(true, "Session phase weighting (all days)", group=gX,
             tooltip="Opening drive 1.2x, midday lull 0.85x, close acceleration 1.15x on the expected move.")
useGap  = input.bool(true, "Overnight gap z-score (day type)", group=gX)
gapThr  = input.float(1.0, "Gap watch threshold (ATR)", minval=0.1, group=gX)
evDates = input.string("", "Event days (YYYY-MM-DD, comma-sep)", group=gX,
             tooltip="RBI / budget / Fed days. Expected move is widened 1.3x on these dates.")

gV      = "Display"
themeOpt= input.string("Auto", "Color theme", options=["Auto","Dark","Light"], group=gV,
             tooltip="Auto reads the chart background. Force Dark or Light if signals look washed out.")
showBars= input.bool(false, "Colour candles by direction", group=gV)
showBox = input.bool(true, "Compression boxes", group=gV)
showTrg = input.bool(true,  "Trigger lines",     group=gV)
showSig = input.bool(true,  "Signal markers",    group=gV)
sigSize = input.string("Small", "Marker size", options=["Tiny","Small","Normal","Large"], group=gV)
showPnl = input.bool(true,  "Verdict panel",     group=gV)
showAdv = input.bool(false, "Show advanced rows (reliability, DNA)", group=gV)
showFlow= input.bool(true,  "Show regime & flow rows", group=gV)
showRib = input.bool(true,  "Regime ribbon (chart bottom)", group=gV)
showFx  = input.bool(true,  "Signal forensics tooltip (ⓘ)", group=gV)
posOpt  = input.string("Top Right", "Panel position",
             options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=gV)

gH      = "HTF signal ladder (5 higher TFs)"
showHTF = input.bool(true,  "Plot 5 higher-TF signal markers", group=gH,
             tooltip="Steps up the standard TradingView resolution ladder from THIS chart's timeframe and plots the VPRA price-core signal (compression + convexity + inefficiency, loaded to a high %ile + a real range release, with the same trigger/close/momentum direction engine) computed natively on each of the next 5 higher timeframes. Rungs at or below the chart TF are auto-skipped, so near the top of the ladder you simply get fewer markers (nothing exists above 1M). These markers use the PRICE-ONLY core — no VIX/basis/Ichimoku enrichment — so each HTF needs only one data request and stays light.")
htfConfirmed = input.bool(true, "Confirmed HTF bars (no repaint)", group=gH,
             tooltip="ON = a higher-TF marker only appears after that higher-TF bar has CLOSED (stable, lagged by up to one HTF bar). OFF = live forming HTF bar (faster, can repaint).")
htfTags = input.bool(true,  "Label each marker with its timeframe", group=gH,
             tooltip="Draws a small text tag (e.g. 240, D, W) next to each higher-TF marker. Turn off for a cleaner chart; the colour + legend table still identify each timeframe.")
showHTFleg = input.bool(true, "Show HTF legend table", group=gH)
htfPosOpt = input.string("Bottom Left", "HTF legend position",
             options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=gH)
en1 = input.bool(true, "Slot 1 (nearest higher TF)", group=gH, inline="en1")
en2 = input.bool(true, "2", group=gH, inline="en1")
en3 = input.bool(true, "3", group=gH, inline="en1")
en4 = input.bool(true, "4", group=gH, inline="en1")
en5 = input.bool(true, "5 (farthest)", group=gH, inline="en1")

// resolve data feeds (any asset, any market)
chartFut = chartIs == "Derivative"
comp = useComp ? request.security(compIn, timeframe.period, close, lookahead=barmerge.lookahead_off) : na
fut  = chartFut ? close : comp
spot = chartFut ? comp : close
vix  = useVol ? request.security(volIn, timeframe.period, close, lookahead=barmerge.lookahead_off) : na
spotValid = useComp and not na(spot) and spot != 0 and not na(fut)
feedOK    = (not useComp or spotValid) and (not useVol or not na(vix))

// ---------------------------------------------------------------------
// ADAPTIVE PALETTE — Auto (reads chart bg) or forced Dark/Light
//   Dark bg  -> bright colours    ·    Light bg -> deep saturated colours
// ---------------------------------------------------------------------
bgLum   = 0.299 * color.r(chart.bg_color) + 0.587 * color.g(chart.bg_color) + 0.114 * color.b(chart.bg_color)
isDark  = themeOpt == "Dark" ? true : themeOpt == "Light" ? false : (na(bgLum) ? true : bgLum < 128)
txtCol  = isDark ? color.white : #111111
txtDim  = isDark ? color.new(color.white, 15) : color.new(color.black, 12)
cellBg  = chart.bg_color
hdrBg   = chart.bg_color
frameCol= isDark ? color.new(color.white, 30) : color.new(color.black, 35)
cGamma  = isDark ? #bb6bff : #6a1b9a
cSqueeze= isDark ? #ff9e40 : #d84315
cExpand = isDark ? #40a9ff : #1565c0
cGreen  = isDark ? #00e676 : #2e7d32
cRed    = isDark ? #ff5252 : #c62828
cAmber  = isDark ? #ffd740 : #e65100

// ---------------------------------------------------------------------
// HELPERS
// ---------------------------------------------------------------------
n01(x) => math.max(0.0, math.min(1.0, x / 100.0))
gm2(a,b) => math.pow(math.max(0.0,a)*math.max(0.0,b), 0.5)
ar(b) => b > 0 ? "▲" : b < 0 ? "▼" : "•"
// pick black/white text for best contrast on a given fill colour
txtOn(c) =>
    l = 0.299 * color.r(c) + 0.587 * color.g(c) + 0.114 * color.b(c)
    l > 140 ? #0a0a0a : color.white
// Ichimoku trend bias: +1 above cloud, -1 below cloud, 0 inside (displaced)
ichiBias() =>
    conv = (ta.highest(high, icC) + ta.lowest(low, icC)) / 2
    base = (ta.highest(high, icB) + ta.lowest(low, icB)) / 2
    spanA = (conv + base) / 2
    spanB = (ta.highest(high, icS) + ta.lowest(low, icS)) / 2
    topC = math.max(spanA[icD], spanB[icD])
    botC = math.min(spanA[icD], spanB[icD])
    close > topC ? 1 : close < botC ? -1 : 0
ichiPair() =>
    ib = ichiBias()
    [ib, ib[1]]
barStr(p) =>
    n = math.round(math.max(0, math.min(100, p)) / 10)
    s = ""
    for i = 0 to 9
        s := s + (i < n ? "█" : "░")
    s


// ---------------------------------------------------------------------
// FEATURES + PRESSURE
// ---------------------------------------------------------------------
ret   = math.log(priceSrc / priceSrc[1])
atr   = ta.atr(volLen)
rv    = ta.stdev(ret, volLen) * math.sqrt(252.0) * 100

// =====================================================================
// PATH-DEPENDENT VOLATILITY FORECAST (compact)
//   Reduced Guyon-Lekeufack (2023): leverage feature R1 + activity sqrt(R2),
//   each a fast+slow kernel blend of the CONFIRMED (lagged) return path,
//   lightly ridge-calibrated to THIS chart's realized vol (rv) by a rolling
//   2-predictor regression. Output forecasts next-period realized vol in
//   the SAME annualized units as rv, so it is directly comparable to VIX.
// =====================================================================
vfEps   = 1e-12
rLagF   = nz(ret[1])
r2LagF  = rLagF * rLagF
e_tf    = ta.ema(rLagF,  vfFast)
e_ts    = ta.ema(rLagF,  vfSlow)
e_af    = ta.ema(r2LagF, vfFast)
e_as    = ta.ema(r2LagF, vfSlow)
R1v     = vfW * e_tf + (1.0 - vfW) * e_ts                          // trend / leverage feature
R2v     = vfW * e_af + (1.0 - vfW) * e_as                          // activity feature
sR2v    = math.sqrt(math.max(R2v, vfEps))
// light 2-predictor ridge OLS:  rv ~ b0 + b1*R1v + b2*sR2v
m1f  = ta.sma(R1v,  vfCalLen)
m2f  = ta.sma(sR2v, vfCalLen)
myf  = ta.sma(rv,   vfCalLen)
S11f = ta.sma(R1v * R1v,   vfCalLen) - m1f * m1f + vfEps
S22f = ta.sma(sR2v * sR2v, vfCalLen) - m2f * m2f + vfEps
S12f = ta.sma(R1v * sR2v,  vfCalLen) - m1f * m2f
S1yf = ta.sma(R1v * rv,    vfCalLen) - m1f * myf
S2yf = ta.sma(sR2v * rv,   vfCalLen) - m2f * myf
detf = S11f * S22f - S12f * S12f
b1f  = detf != 0 ? (S1yf * S22f - S2yf * S12f) / detf : 0.0
b2f  = detf != 0 ? (S2yf * S11f - S1yf * S12f) / detf : 0.0
b0f  = myf - b1f * m1f - b2f * m2f
rvForecast = math.max(b0f + b1f * R1v + b2f * sR2v, 0.0)          // annualized %, comparable to VIX
volFcastReady = useVolFcast and bar_index > vfCalLen + vfSlow
rvForUse = volFcastReady ? rvForecast : rv                        // (1) used in the dislocation factor
// forecast per-bar move expressed in ATR units, for (2) expected-move anchor
perBarFcast = rvForecast / 100.0 / math.sqrt(252.0)               // per-bar return std (sqrt(252) cancels rv scaling)
forecastATR = (not na(atr) and atr != 0) ? perBarFcast * priceSrc / atr : 1.0
// (3) trust gauge: rolling R^2 of forecast vs realized rv
residF = rv - rvForecast
ssResF = ta.sma(residF * residF, vfCalLen)
ssTotF = ta.sma(rv * rv, vfCalLen) - myf * myf
r2fit  = ssTotF > 1e-12 ? math.max(0.0, 1.0 - ssResF / ssTotF) : na
fitPct = na(r2fit) ? na : r2fit * 100.0
fitWord= na(fitPct) ? "—" : fitPct >= 30 ? "reliable" : fitPct >= 10 ? "partial" : "weak"
fitCol = na(fitPct) ? color.gray : fitPct >= 30 ? cGreen : fitPct >= 10 ? cAmber : cRed

basisPct = spotValid ? (fut - spot) / spot * 100 : 0.0
basisMom = ta.change(basisPct, basLen)
vixChgRaw = ta.change(vix)
vixChg= nz(vixChgRaw, 0.0)
vixR  = na(vix) ? 0.0 : vix
accel = ta.change(ret)
_dir  = math.abs(priceSrc - priceSrc[erLen])
_vol  = math.sum(math.abs(ta.change(priceSrc)), erLen)
er    = _vol != 0 ? _dir / _vol : 0.0
rng   = atr != 0 ? (high - low) / atr : 0.0

fComp = 100 - ta.percentrank(atr, rankLen)
// (1) dislocation now compares the volatility index against the FORECAST
//     of realized vol (rvForUse) rather than trailing realized vol.
fDislRaw = ta.percentrank(math.abs(nz(vix - rvForUse, 0.0)), rankLen)
fDisl = useVol ? nz(fDislRaw, 0.0) : 0.0
fBasRaw = ta.percentrank(math.abs(basisMom), rankLen)
fBas  = useComp ? nz(fBasRaw, 0.0) : 0.0
fCvx  = ta.percentrank(math.abs(accel), rankLen)
wD    = useVol ? 1.0 : 0.0
wB    = useComp ? 1.0 : 0.0
pressure = (1.0*fComp + wD*fDisl + wB*fBas + 1.5*fCvx + 1.0*(100 - er*100)) / (2.5 + wD + wB)
pPct  = ta.percentrank(pressure, rankLen)     // adaptive "how loaded" 0..100

// ---------------------------------------------------------------------
// ENGINE ANALYTICS (ported from the pane: phase, forecast, size, weather)
// ---------------------------------------------------------------------
var int compAge = 0
compAge := fComp > 70 ? compAge + 1 : 0
var Phase ph = Phase.dormant
ph := switch
    pressure >= detThr                                => Phase.detonation
    pressure >= critThr and compAge > 10              => Phase.critical
    fComp > 70                                        => Phase.compressed
    pressure >= 50                                    => Phase.loading
    ph == Phase.detonation and pressure < critThr     => Phase.exhaustion
    => Phase.dormant
phaseStr = switch ph
    Phase.detonation => "DETONATION"
    Phase.critical   => "CRITICAL"
    Phase.compressed => "COMPRESSED"
    Phase.loading    => "LOADING"
    Phase.exhaustion => "EXHAUSTION"
    => "DORMANT"
phaseCol = switch ph
    Phase.detonation => color.red
    Phase.critical   => color.orange
    Phase.compressed => cAmber
    Phase.loading    => color.teal
    Phase.exhaustion => color.purple
    => color.gray

// (2) expected-move base is now ANCHORED to the fitted forecast (in ATR units)
//     and modulated by pressure, instead of a fixed linear pressure slope.
//     Forecast off  -> original  0.5 + pressure/100*3.0  behaviour.
expATR0 = volFcastReady ? math.max(0.3, forecastATR * (0.8 + pressure / 100.0 * 1.6)) : (0.5 + pressure / 100 * 3.0)
blast   = useComp ? math.pow(math.max(0.0,fComp) * math.max(0.0,fCvx) * math.max(0.0,fBas), 1.0/3.0) : gm2(fComp, fCvx)
moveSize= blast < 30 ? "Low" : blast < 60 ? "Medium" : blast < 80 ? "High" : "Extreme"
weatherTxt = pressure < 20 ? "CALM" : pressure < 40 ? "BREEZY" : pressure < 60 ? "WINDY" : pressure < 80 ? "STORM" : "HURRICANE"

// ---------------------------------------------------------------------
// EXPIRY DETECTION
// ---------------------------------------------------------------------
dowNum = expDay == "Monday" ? dayofweek.monday : expDay == "Tuesday" ? dayofweek.tuesday : expDay == "Wednesday" ? dayofweek.wednesday : expDay == "Thursday" ? dayofweek.thursday : dayofweek.friday
isDOW  = dayofweek == dowNum
isLast = isDOW and month(time + 7 * 86400000) != month
isExp  = monthly ? isLast : isDOW
mins   = (hour * 60 + minute) - (sH * 60 + sM)
total  = (eH * 60 + eM) - (sH * 60 + sM)
prog   = math.max(0.0, math.min(1.0, total > 0 ? mins / total : 0.0))
isExpiryNow = isExp and prog > 0.0

// --- session phase (all days), overnight gap, event days ---
sessPh = prog <= 0.08 ? "OPEN DRIVE" : prog < 0.30 ? "MORNING" : prog < 0.70 ? "MIDDAY" : prog < 0.85 ? "AFTERNOON" : "CLOSE ACCEL"
sessW  = not useSess ? 1.0 : prog <= 0.08 ? 1.2 : (prog >= 0.30 and prog < 0.70) ? 0.85 : prog >= 0.85 ? 1.15 : 1.0
dayChg = ta.change(time("D"))
var float gapZ = 0.0
if dayChg != 0 and not na(atr) and atr != 0
    gapZ := (open - close[1]) / atr
gapTag = not useGap ? "" : gapZ >= gapThr ? " ·GAP▲" : gapZ <= -gapThr ? " ·GAP▼" : ""
todayStr = str.format("{0,number,0000}-{1,number,00}-{2,number,00}", year, month, dayofmonth)
eventDay = str.length(evDates) > 0 and str.contains(evDates, todayStr)

// ---------------------------------------------------------------------
// TYPE CLASSIFIER (squeeze vs expansion on non-expiry days)
// ---------------------------------------------------------------------
mv     = n01(ta.percentrank(math.abs(ret), rankLen))
vMag   = n01(ta.percentrank(math.abs(vixChg), rankLen))
sameD  = (math.sign(ret) == math.sign(vixChg)) and vixChg != 0
coD    = sameD ? gm2(mv, vMag) : 0.0          // VIX co-direction = squeeze tell
rngExp = math.max(0.0, math.min(1.0, (rng - 0.8) / 1.2))

// ---------------------------------------------------------------------
// FLOW PROXIES (spot/future/VIX only — inferred, not measured)
//   1) Regime via variance ratio: VR>1 trending/amplify, VR<1 pin/dampen
//   2) Vol-shock & instability:   VIX ROC + vol-of-vol percentile
//   3) Positioning stress:        basis backwardation (future < spot)
//   4) Charm clock:               expiry intraday morning-pin -> power-hour
// ---------------------------------------------------------------------
ret1v = ta.variance(ret, vrLen)
retK  = math.log(priceSrc / priceSrc[vrK])
retKv = ta.variance(retK, vrLen)
vr    = (ret1v != 0 and vrK > 0) ? retKv / (vrK * ret1v) : 1.0
vrSE  = math.sqrt(math.max(1e-9, (2.0 * (2.0 * vrK - 1.0) * (vrK - 1.0)) / (3.0 * vrK * vrLen)))
vrZ   = (vr - 1.0) / vrSE
regimeAmp = useReg and vr >= 1 + vrBand and (not vrSig or vrZ >=  vrZcrit)
regimePin = useReg and vr <= 1 - vrBand and (not vrSig or vrZ <= -vrZcrit)
regimeStr = not useReg ? "off" : regimeAmp ? "AMPLIFY" : regimePin ? "PIN/DAMPEN" : "NEUTRAL"
regimeCol = regimeAmp ? cExpand : regimePin ? color.gray : cAmber

vixRocRaw = ta.roc(vix, vrocLen)
vixRoc = (not useShock or na(vixRocRaw)) ? 0.0 : vixRocRaw
vvol   = ta.stdev(vixChg, vvolLen)
instabRaw = ta.percentrank(vvol, rankLen)
instab = (useShock and useVol) ? nz(instabRaw, 0.0) : 0.0
vixSpike = useShock and vixRoc >=  shockThr
vixCrush = useShock and vixRoc <= -shockThr

backwardation = useBasis and spotValid and basisPct < -backThr

charmPh = (not useCharm or not isExp) ? "—" : prog < 0.4 ? "AM PIN" : prog < 0.75 ? "MIDDAY" : "POWER HR"
charmW  = (not useCharm or not isExp) ? 1.0 : prog < 0.4 ? 0.7 : prog < 0.75 ? 1.0 : 1.35

flowMult = math.max(0.5, math.min(2.5, (applyFlow ? (1 + instab / 100 * 0.4) : 1.0) * (useCharm ? charmW : 1.0) * sessW * (eventDay ? 1.3 : 1.0)))
expATR   = math.max(0.3, expATR0 * flowMult)                 // instability + charm scaled
expPts   = expATR * atr                                      // ...in price points

// ---------------------------------------------------------------------
// SIGNAL: very high pressure (loaded) + real release, any day
// ---------------------------------------------------------------------
loaded  = ta.highest(pPct, loadLook) >= sigPct
release = rngExp >= relThr
// --- triggers (computed here so direction can use them) ---
upTrig = ta.highest(high, trigLen)
dnTrig = ta.lowest(low,  trigLen)
// --- direction engine: trigger-break > close location > momentum ---
brokeUp = close > upTrig[1]
brokeDn = close < dnTrig[1]
clvUp   = (close - low) >= (high - close)
chgC    = ta.change(priceSrc, relBars)
upScore = (brokeUp ? 2 : 0) + (clvUp ? 1 : 0) + (chgC >= 0 ? 1 : 0)
dnScore = (brokeDn ? 2 : 0) + (clvUp ? 0 : 1) + (chgC >= 0 ? 0 : 1)
relUp   = upScore >= dnScore
// --- energy budget: compression stores, expansion spends ---
var float energy = 0.0
energy := math.max(0.0, math.min(10.0, nz(energy) + nz(math.max(0.0, (nz(fComp) - 50) / 50) * 0.12 - nz(rngExp) * 0.35, 0.0)))
rawSig  = feedOK and loaded and release

// --- HTF Ichimoku confluence ---
_cs   = timeframe.in_seconds(timeframe.period)
_cm   = _cs > 0 ? _cs / 60.0 : 1.0
tf1   = str.tostring(math.round(_cm * mlt1))
tf2   = str.tostring(math.round(_cm * mlt2))
tf3   = str.tostring(math.round(_cm * mlt3))
b0    = ichiBias()
float b1L = na
float b1C = na
float b2L = na
float b2C = na
float b3L = na
float b3C = na
if useConf
    [q1a, q1b] = request.security(syminfo.tickerid, tf1, ichiPair(), lookahead=barmerge.lookahead_off)
    b1L := q1a
    b1C := q1b
    [q2a, q2b] = request.security(syminfo.tickerid, tf2, ichiPair(), lookahead=barmerge.lookahead_off)
    b2L := q2a
    b2C := q2b
    [q3a, q3b] = request.security(syminfo.tickerid, tf3, ichiPair(), lookahead=barmerge.lookahead_off)
    b3L := q3a
    b3C := q3b
b1    = not useConf ? 0 : confHTF ? b1C : b1L
b2    = not useConf ? 0 : confHTF ? b2C : b2L
b3    = not useConf ? 0 : confHTF ? b3C : b3L
sigDir= relUp ? 1 : -1
agreeN= (b0 == sigDir ? 1 : 0) + (useConf ? (b1 == sigDir ? 1 : 0) + (b2 == sigDir ? 1 : 0) + (b3 == sigDir ? 1 : 0) : 0)
aligned = useConf and agreeN >= minAgree
needFilter = useConf and confMode == "Filter (require agreement)"
passConf = not needFilter ? true : (isExpiryNow and not gateGam ? true : agreeN >= minAgree)
needReg  = useReg and regMode == "Filter (require not-pinning)"
passReg  = not needReg ? true : (isExpiryNow and not regGam ? true : not regimePin)

var int rAge = 0
rAge := rawSig ? rAge + 1 : 0
var int lastSig = -100000
ev = rAge == confBars and (bar_index - lastSig) >= minGap and passConf and passReg
if ev
    lastSig := bar_index

// type + colours (needed by stats below)
typ    = not feedOK ? "—" : isExpiryNow ? "GAMMA BLAST" : (coD >= coThr ? "SQUEEZE" : "EXPANSION")
typCol = typ == "GAMMA BLAST" ? cGamma : typ == "SQUEEZE" ? cSqueeze : typ == "EXPANSION" ? cExpand : color.gray
dirUp  = close > ta.ema(close, volLen)
dirTxt = relUp ? "▲ UP" : "▼ DOWN"

// --- follow-through stats: MFE/MAE per type + early/late split (in-sample) ---
var int sigN = 0
var int hitN = 0
var int nG = 0
var int hG = 0
var float fG = 0.0
var float aG = 0.0
var int nS = 0
var int hS = 0
var float fS = 0.0
var float aS = 0.0
var int nE = 0
var int hE = 0
var float fE = 0.0
var float aE = 0.0
var int nEarly = 0
var int hEarly = 0
var int nLate = 0
var int hLate = 0
hhF = ta.highest(high, fwdBars)
llF = ta.lowest(low,  fwdBars)
if ev[fwdBars] and not na(atr[fwdBars]) and atr[fwdBars] != 0
    up  = relUp[fwdBars]
    mfe = (up ? (hhF - close[fwdBars]) : (close[fwdBars] - llF)) / atr[fwdBars]
    mae = (up ? (close[fwdBars] - llF) : (hhF - close[fwdBars])) / atr[fwdBars]
    hit = mfe >= fwdATR
    sigN := sigN + 1
    hitN := hit ? hitN + 1 : hitN
    tAt = typ[fwdBars]
    if tAt == "GAMMA BLAST"
        nG := nG + 1
        hG := hit ? hG + 1 : hG
        fG := nz(fG) + nz(mfe)
        aG := nz(aG) + nz(mae)
    else if tAt == "SQUEEZE"
        nS := nS + 1
        hS := hit ? hS + 1 : hS
        fS := nz(fS) + nz(mfe)
        aS := nz(aS) + nz(mae)
    else
        nE := nE + 1
        hE := hit ? hE + 1 : hE
        fE := nz(fE) + nz(mfe)
        aE := nz(aE) + nz(mae)
    if bar_index <= last_bar_index / 2
        nEarly := nEarly + 1
        hEarly := hit ? hEarly + 1 : hEarly
    else
        nLate := nLate + 1
        hLate := hit ? hLate + 1 : hLate
reliability = sigN > 0 ? hitN / sigN * 100 : na
statStr(n, h, f, a) => n == 0 ? "—" : str.tostring(math.round(h / n * 100)) + "% · F" + str.tostring(f / n, "#.0") + "/A" + str.tostring(a / n, "#.0") + " (" + str.tostring(n) + ")"


// ---------------------------------------------------------------------
// MARKERS — triangles only; brightness + glow halo = HTF alignment strength
//   strength (cumulative): 3x+5x+15x = brightest/full glow ... 3x only = dim
//   colour = type (gamma/squeeze/expansion) · ⚡ = expiry
// ---------------------------------------------------------------------
a1 = useConf and b1 == sigDir
a2 = useConf and b2 == sigDir
a3 = useConf and b3 == sigDir
strength = not useConf ? 3 : (a1 and a2 and a3 ? 3 : a1 and a2 ? 2 : a1 ? 1 : 0)
coreT = strength == 3 ? 0  : strength == 2 ? 4  : strength == 1 ? 9  : 14   // core stays solid even when weak
coreCol = color.new(typCol, coreT)
szT = sigSize == "Tiny"
szS = sigSize == "Small"
szN = sigSize == "Normal"
szL = sigSize == "Large"
sUp = showSig and ev and relUp
sDn = showSig and ev and not relUp
// markers — triangles, size-selectable (halo glow removed to stay under the plot-count cap)
plotshape(sUp and szT, "Up",   style=shape.triangleup,   location=location.belowbar, color=coreCol, size=size.tiny)
plotshape(sUp and szS, "Up ",  style=shape.triangleup,   location=location.belowbar, color=coreCol, size=size.tiny)
plotshape(sUp and szN, "Up  ", style=shape.triangleup,   location=location.belowbar, color=coreCol, size=size.small)
plotshape(sUp and szL, "Up   ",style=shape.triangleup,   location=location.belowbar, color=coreCol, size=size.normal)
plotshape(sDn and szT, "Dn",   style=shape.triangledown, location=location.abovebar, color=coreCol, size=size.tiny)
plotshape(sDn and szS, "Dn ",  style=shape.triangledown, location=location.abovebar, color=coreCol, size=size.tiny)
plotshape(sDn and szN, "Dn  ", style=shape.triangledown, location=location.abovebar, color=coreCol, size=size.small)
plotshape(sDn and szL, "Dn   ",style=shape.triangledown, location=location.abovebar, color=coreCol, size=size.normal)
plotchar(sUp and isExpiryNow, "Expiry Up",   "⚡", location.belowbar, color=cGamma, size=size.tiny)
plotchar(sDn and isExpiryNow, "Expiry Down", "⚡", location.abovebar, color=cGamma, size=size.tiny)

// --- regime ribbon: thin strip at chart bottom (VR amplify/pin) ---
ribCol = regimeAmp ? color.new(cExpand, 35) : regimePin ? color.new(color.gray, 55) : color.new(cAmber, 55)
plotshape(showRib and useReg, "Regime ribbon", style=shape.square, location=location.bottom, color=ribCol, size=size.tiny)

// --- signal forensics: ⓘ with full DNA snapshot in tooltip ---
if showFx and ev
    fxTxt = typ + " " + dirTxt + "\nPressure " + str.tostring(math.round(pressure)) + " (%ile " + str.tostring(math.round(pPct)) + ")"
         + "\nRegime " + regimeStr + " · VR " + str.tostring(vr, "#.00")
         + "\nInstability " + str.tostring(math.round(instab)) + " · VIX " + str.tostring(vixRoc, "#.0") + "%"
         + "\nBasis " + str.tostring(basisPct, "#.00") + "%" + (backwardation ? " DISC" : "")
         + "\nHTF " + str.tostring(agreeN) + "/4 · Energy " + str.tostring(energy, "#.0")
         + "\nSession " + sessPh + gapTag + (eventDay ? " · EVENT" : "")
         + "\nExp move ≈" + str.tostring(expATR, "#.0") + " ATR (" + str.tostring(math.round(expPts)) + "pt)"
         + (useVolFcast and volFcastReady ? "\nFcast RV " + str.tostring(rvForecast, "#.0") + "%" + (useFitGauge ? " · fit " + str.tostring(math.round(nz(fitPct))) + "%" : "") : "")
    label.new(bar_index, relUp ? low : high, "ⓘ", style=relUp ? label.style_label_up : label.style_label_down,
         color=color.new(typCol, 70), textcolor=txtOn(typCol), size=size.tiny, tooltip=fxTxt)

// --- rich webhook-ready alert with live values ---
if ev
    alert("VPRA " + typ + " " + (relUp ? "UP" : "DOWN") + " | " + syminfo.ticker + " " + timeframe.period
         + " | P=" + str.tostring(math.round(pressure)) + " VR=" + str.tostring(vr, "#.00")
         + " regime=" + regimeStr + " instab=" + str.tostring(math.round(instab))
         + (useVolFcast and volFcastReady ? " fcastRV=" + str.tostring(rvForecast, "#.0") : "")
         + " expPts=" + str.tostring(math.round(expPts))
         + " trig=" + str.tostring(dnTrig, format.mintick) + "/" + str.tostring(upTrig, format.mintick),
         alert.freq_once_per_bar_close)

// --- data-window internals (hidden from chart) ---
plot(ev ? (relUp ? 1 : -1) : 0, "→Conf: VPRA dir", display=display.data_window)   // feed for Reversal & Continuation Confluence
plot(regimeAmp ? 1 : regimePin ? -1 : 0, "→Conf: VPRA regime", display=display.data_window)
plot(expPts, "→Conf: VPRA expPts", display=display.data_window)
plot(ev and isExpiryNow ? (relUp ? 1 : -1) : 0, "→Conf: VPRA gamma", display=display.data_window)
plot(isExpiryNow ? 1 : 0, "→Conf: VPRA expiryNow", display=display.data_window)
// Two more cross-instrument / multi-TF export feeds are appended at the very end
// of the script (→Conf: VPRA dir ALL and →Conf: Basis state) — they must sit
// after the HTF ladder, where their inputs become available.

// optional candle tint by direction (off by default)
cUp = color.from_gradient(pPct, 40, 100, color.new(cGreen, 45), color.new(cGreen, 0))
cDn = color.from_gradient(pPct, 40, 100, color.new(cRed,   45), color.new(cRed,   0))
barcolor(not showBars ? na : pPct >= 50 ? (dirUp ? cUp : cDn) : na)

// ---------------------------------------------------------------------
// COMPRESSION BOXES (off by default)
// ---------------------------------------------------------------------
comp70 = fComp > 70
var int   cAge = 0
cAge := comp70 ? cAge + 1 : 0
var box   cbox = na
var float ctop = na
var float cbot = na
hh20 = ta.highest(high, 20)
ll20 = ta.lowest(low, 20)
if showBox and cAge == 5
    ctop := hh20
    cbot := ll20
    cbox := box.new(bar_index - 5, ctop, bar_index, cbot, border_color=color.new(cAmber, 30), bgcolor=color.new(cAmber, 94), border_width=1)
if showBox and comp70 and not na(cbox)
    box.set_right(cbox, bar_index)
if showBox and (not comp70) and not na(cbox)
    bcol = close > ctop ? cGreen : cRed
    box.set_border_color(cbox, bcol)
    box.set_bgcolor(cbox, color.new(bcol, 92))
    box.set_right(cbox, bar_index)
    cbox := na

// ---------------------------------------------------------------------
// TRIGGER LINES (where the move would confirm) — computed earlier
// ---------------------------------------------------------------------
var line  upL = na
var line  dnL = na
var label upLb = na
var label dnLb = na
if showTrg and barstate.islast
    if not na(upL)
        line.delete(upL)
    if not na(dnL)
        line.delete(dnL)
    if not na(upLb)
        label.delete(upLb)
    if not na(dnLb)
        label.delete(dnLb)
    upL  := line.new(bar_index - trigLen, upTrig, bar_index + 8, upTrig, color=cGreen, style=line.style_dashed)
    dnL  := line.new(bar_index - trigLen, dnTrig, bar_index + 8, dnTrig, color=cRed, style=line.style_dashed)
    upLb := label.new(bar_index + 8, upTrig, "▲ " + str.tostring(upTrig, format.mintick), style=label.style_label_left, color=cGreen, textcolor=color.white, size=size.small)
    dnLb := label.new(bar_index + 8, dnTrig, "▼ " + str.tostring(dnTrig, format.mintick), style=label.style_label_left, color=cRed, textcolor=color.white, size=size.small)

// ---------------------------------------------------------------------
// VERDICT PANEL  (full analytics; advanced rows toggle)
// ---------------------------------------------------------------------
action = ev ? (typ + " · " + dirTxt) : loaded ? "LOADED — release imminent" : pPct >= 60 ? "BUILDING" : "QUIET — no edge"
panelPos = posOpt == "Top Left" ? position.top_left : posOpt == "Bottom Right" ? position.bottom_right : posOpt == "Bottom Left" ? position.bottom_left : position.top_right
var table pnl = table.new(panelPos, 2, 28, border_width=1, frame_width=1, frame_color=frameCol)
prow(r, k, v, vbg) =>
    table.cell(pnl, 0, r, k, text_color=txtDim, text_size=size.small, text_halign=text.align_left,  bgcolor=cellBg)
    table.cell(pnl, 1, r, v, text_color=txtOn(vbg), text_size=size.small, text_halign=text.align_right, bgcolor=color.new(vbg, 10))
if showPnl and barstate.islast
    headTyp = feedOK ? (loaded or ev ? typ : "—") : "⚠ SYMBOLS"
    headCol = (loaded or ev) and feedOK ? typCol : color.gray
    table.cell(pnl, 0, 0, isExpiryNow ? "REGIME ⚡EXP" : "REGIME", text_color=txtCol, text_size=size.normal, bgcolor=hdrBg)
    table.cell(pnl, 1, 0, headTyp, text_color=txtOn(headCol), text_size=size.normal, bgcolor=color.new(headCol, 0))
    int ri = 1
    prow(ri, "Direction",  dirTxt, relUp ? cGreen : cRed)
    ri := ri + 1
    prow(ri, "Phase",      phaseStr, phaseCol)
    ri := ri + 1
    if showFlow
        prow(ri, "Energy", str.tostring(energy, "#.0") + " " + barStr(energy * 10), energy >= 7 ? cRed : energy >= 4 ? cAmber : color.gray)
        ri := ri + 1
    if showFlow
        prow(ri, "Regime", useReg ? (regimeStr + " (VR " + str.tostring(vr, "#.00") + ")") : "off", useReg ? regimeCol : color.gray)
        ri := ri + 1
    prow(ri, "Pressure",   str.tostring(math.round(pressure)) + " " + barStr(pressure) + " " + weatherTxt, pressure >= detThr ? cRed : pressure >= critThr ? cAmber : color.gray)
    ri := ri + 1
    prow(ri, "Loaded %ile",str.tostring(math.round(pPct)) + (pPct >= sigPct ? "  ✓" : "  ·"), pPct >= sigPct ? cGreen : color.gray)
    ri := ri + 1
    prow(ri, "Move size",  moveSize + " · ≈" + str.tostring(expATR, "#.0") + " ATR (" + str.tostring(math.round(expPts)) + "pt)", blast >= 80 ? cRed : blast >= 60 ? cAmber : color.gray)
    ri := ri + 1
    if useVolFcast
        prow(ri, "Vol forecast", volFcastReady ? (str.tostring(rvForecast, "#.0") + "%" + (useVol ? " vs VIX " + str.tostring(vixR, "#.0") + "%" : "")) : "warming…", volFcastReady ? ((useVol and rvForecast > vixR) ? cRed : cExpand) : color.gray)
        ri := ri + 1
    if useFitGauge
        prow(ri, "Path-vol fit", volFcastReady ? (str.tostring(math.round(nz(fitPct))) + "% · " + fitWord) : "warming…", volFcastReady ? fitCol : color.gray)
        ri := ri + 1
    if showFlow
        prow(ri, "Instability", (useShock and useVol) ? (str.tostring(math.round(instab)) + " · VIX " + (vixRoc >= 0 ? "+" : "") + str.tostring(vixRoc, "#.0") + "%") : "off", vixSpike ? cRed : vixCrush ? cGreen : instab >= 70 ? cAmber : color.gray)
        ri := ri + 1
        prow(ri, "Basis", useBasis ? ((basisPct >= 0 ? "+" : "") + str.tostring(basisPct, "#.00") + "%" + (backwardation ? " ▼DISC" : "")) : "off", backwardation ? cRed : basisPct > 0 ? cGreen : color.gray)
        ri := ri + 1
        prow(ri, "Charm", (useCharm and isExp) ? (charmPh + " ×" + str.tostring(charmW, "#.00")) : "—", (useCharm and isExp and prog >= 0.75) ? cGamma : color.gray)
        ri := ri + 1
        prow(ri, "Session", sessPh + gapTag + (eventDay ? " ⚠EVT" : ""), eventDay ? cAmber : (useGap and math.abs(gapZ) >= gapThr) ? cExpand : color.gray)
        ri := ri + 1
    prow(ri, "Trend align",useConf ? (str.tostring(agreeN) + "/4 " + (sigDir > 0 ? "▲" : "▼")) : "off", useConf ? (aligned ? cGreen : color.gray) : color.gray)
    ri := ri + 1
    prow(ri, "HTF 3/5/15", useConf ? (ar(b1) + " " + ar(b2) + " " + ar(b3)) : "off", useConf ? (aligned ? cGreen : color.gray) : color.gray)
    ri := ri + 1
    prow(ri, "Action",     action, (loaded or ev) ? typCol : color.gray)
    ri := ri + 1
    prow(ri, "Triggers",   str.tostring(dnTrig, format.mintick) + " / " + str.tostring(upTrig, format.mintick), color.new(cExpand, 20))
    ri := ri + 1
    if showAdv
        prow(ri, "Hit% all*", na(reliability) ? "building…" : str.tostring(math.round(reliability)) + "% (" + str.tostring(sigN) + ")", color.new(cGreen, 18))
        ri := ri + 1
        prow(ri, "Gamma*",   statStr(nG, hG, fG, aG), color.new(cGamma, 18))
        ri := ri + 1
        prow(ri, "Squeeze*", statStr(nS, hS, fS, aS), color.new(cSqueeze, 18))
        ri := ri + 1
        prow(ri, "Expansion*", statStr(nE, hE, fE, aE), color.new(cExpand, 18))
        ri := ri + 1
        prow(ri, "WF early/late*", (nEarly > 0 ? str.tostring(math.round(hEarly / nEarly * 100)) + "%(" + str.tostring(nEarly) + ")" : "—") + " / " + (nLate > 0 ? str.tostring(math.round(hLate / nLate * 100)) + "%(" + str.tostring(nLate) + ")" : "—"), color.new(color.gray, 18))
        ri := ri + 1
        prow(ri, "DNA C/D/B/X/I", str.tostring(math.round(fComp)) + "/" + str.tostring(math.round(fDisl)) + "/" + str.tostring(math.round(fBas)) + "/" + str.tostring(math.round(fCvx)) + "/" + str.tostring(math.round(100 - er*100)), color.new(color.gray, 18))
        ri := ri + 1

// =====================================================================
// 5 HIGHER-TIMEFRAME SIGNAL LADDER  (added on top of the v2 engine)
// ---------------------------------------------------------------------
// Steps up the standard TradingView resolution ladder from the current
// chart TF and plots the VPRA PRICE-CORE signal computed natively on each
// of the next 5 higher timeframes. Auto-skips rungs at/below the chart TF
// (so on a high chart TF you simply get fewer markers). Price-only core =
// one data request per HTF; no nested VIX / basis / Ichimoku feeds.
// =====================================================================
var float[] htfLadder = array.from(1., 2., 3., 5., 15., 30., 45., 60., 120., 180., 240., 1440., 10080., 43200.)

f_baseIdx(cm) =>
    idx = -1
    for i = 0 to array.size(htfLadder) - 1
        if idx == -1 and array.get(htfLadder, i) > cm
            idx := i
    idx
f_rungMin(rank) =>
    bi = f_baseIdx(timeframe.in_seconds() / 60.0)
    j  = bi == -1 ? -1 : bi + rank - 1
    (j >= 0 and j < array.size(htfLadder)) ? array.get(htfLadder, j) : na
f_tfStr(m) =>
    na(m) ? na : m >= 43200 ? "M" : m >= 10080 ? "W" : m >= 1440 ? "D" : str.tostring(int(m))

// price-only VPRA signal core, evaluated in whatever context it is requested
f_coreSig() =>
    a   = ta.atr(volLen)
    r   = math.log(close / close[1])
    cmp = 100 - ta.percentrank(a, rankLen)
    acc = ta.change(r)
    cvx = ta.percentrank(math.abs(acc), rankLen)
    dd  = math.abs(close - close[erLen])
    vv  = math.sum(math.abs(ta.change(close)), erLen)
    eff = vv != 0 ? dd / vv : 0.0
    prs = (1.0 * cmp + 1.5 * cvx + 1.0 * (100 - eff * 100)) / 3.5
    pp  = ta.percentrank(prs, rankLen)
    rngA= a != 0 ? (high - low) / a : 0.0
    rexp= math.max(0.0, math.min(1.0, (rngA - 0.8) / 1.2))
    ld  = ta.highest(pp, loadLook) >= sigPct
    rel = rexp >= relThr
    ut  = ta.highest(high, trigLen)
    dt  = ta.lowest(low,  trigLen)
    bu  = close > ut[1]
    bd  = close < dt[1]
    cl  = (close - low) >= (high - close)
    cc  = ta.change(close, relBars)
    us  = (bu ? 2 : 0) + (cl ? 1 : 0) + (cc >= 0 ? 1 : 0)
    ds  = (bd ? 2 : 0) + (cl ? 0 : 1) + (cc >= 0 ? 0 : 1)
    rU  = us >= ds
    raw = ld and rel
    var int rg = 0
    rg := raw ? rg + 1 : 0
    var int ls = -100000
    fire = rg == confBars and (bar_index - ls) >= minGap
    if fire
        ls := bar_index
    u = fire and rU
    d = fire and not rU
    [u, d, u[1], d[1]]

// request the core signal on each HTF at GLOBAL scope (request.security is
// safest there); pick live vs confirmed per the toggle.

// resolve the 5 rungs above this chart's timeframe
hm1 = f_rungMin(1)
hm2 = f_rungMin(2)
hm3 = f_rungMin(3)
hm4 = f_rungMin(4)
hm5 = f_rungMin(5)
htf1 = f_tfStr(hm1)
htf2 = f_tfStr(hm2)
htf3 = f_tfStr(hm3)
htf4 = f_tfStr(hm4)
htf5 = f_tfStr(hm5)
hv1 = showHTF and en1 and not na(hm1)
hv2 = showHTF and en2 and not na(hm2)
hv3 = showHTF and en3 and not na(hm3)
hv4 = showHTF and en4 and not na(hm4)
hv5 = showHTF and en5 and not na(hm5)

// requests gated behind showHTF (Pine v6 dynamic_requests skips them when off)
bool r1u = false
bool r1d = false
bool r1pu = false
bool r1pd = false
bool r2u = false
bool r2d = false
bool r2pu = false
bool r2pd = false
bool r3u = false
bool r3d = false
bool r3pu = false
bool r3pd = false
bool r4u = false
bool r4d = false
bool r4pu = false
bool r4pd = false
bool r5u = false
bool r5d = false
bool r5pu = false
bool r5pd = false
if showHTF
    [c1a, c1b, c1c, c1d] = request.security(syminfo.tickerid, na(htf1) ? "M" : htf1, f_coreSig(), lookahead=barmerge.lookahead_off)
    r1u := c1a
    r1d := c1b
    r1pu := c1c
    r1pd := c1d
    [c2a, c2b, c2c, c2d] = request.security(syminfo.tickerid, na(htf2) ? "M" : htf2, f_coreSig(), lookahead=barmerge.lookahead_off)
    r2u := c2a
    r2d := c2b
    r2pu := c2c
    r2pd := c2d
    [c3a, c3b, c3c, c3d] = request.security(syminfo.tickerid, na(htf3) ? "M" : htf3, f_coreSig(), lookahead=barmerge.lookahead_off)
    r3u := c3a
    r3d := c3b
    r3pu := c3c
    r3pd := c3d
    [c4a, c4b, c4c, c4d] = request.security(syminfo.tickerid, na(htf4) ? "M" : htf4, f_coreSig(), lookahead=barmerge.lookahead_off)
    r4u := c4a
    r4d := c4b
    r4pu := c4c
    r4pd := c4d
    [c5a, c5b, c5c, c5d] = request.security(syminfo.tickerid, na(htf5) ? "M" : htf5, f_coreSig(), lookahead=barmerge.lookahead_off)
    r5u := c5a
    r5d := c5b
    r5pu := c5c
    r5pd := c5d
hu1 = htfConfirmed ? r1pu : r1u
hd1 = htfConfirmed ? r1pd : r1d
hu2 = htfConfirmed ? r2pu : r2u
hd2 = htfConfirmed ? r2pd : r2d
hu3 = htfConfirmed ? r3pu : r3u
hd3 = htfConfirmed ? r3pd : r3d
hu4 = htfConfirmed ? r4pu : r4u
hd4 = htfConfirmed ? r4pd : r4d
hu5 = htfConfirmed ? r5pu : r5u
hd5 = htfConfirmed ? r5pd : r5d

// one marker per HTF fire: rising edge of the (confirmed) HTF signal
heu1 = hv1 and hu1 and not hu1[1]
hed1 = hv1 and hd1 and not hd1[1]
heu2 = hv2 and hu2 and not hu2[1]
hed2 = hv2 and hd2 and not hd2[1]
heu3 = hv3 and hu3 and not hu3[1]
hed3 = hv3 and hd3 and not hd3[1]
heu4 = hv4 and hu4 and not hu4[1]
hed4 = hv4 and hd4 and not hd4[1]
heu5 = hv5 and hu5 and not hu5[1]
hed5 = hv5 and hd5 and not hd5[1]

// distinct colour per timeframe slot is handled inline below (cGreen up / cRed down)
plotshape(heu1, "HTF1 ▲", style=shape.triangleup,   location=location.belowbar, color=cGreen, size=size.tiny)
plotshape(hed1, "HTF1 ▼", style=shape.triangledown, location=location.abovebar, color=cRed,   size=size.tiny)
plotshape(heu2, "HTF2 ▲", style=shape.triangleup,   location=location.belowbar, color=cGreen, size=size.tiny)
plotshape(hed2, "HTF2 ▼", style=shape.triangledown, location=location.abovebar, color=cRed,   size=size.tiny)
plotshape(heu3, "HTF3 ▲", style=shape.triangleup,   location=location.belowbar, color=cGreen, size=size.tiny)
plotshape(hed3, "HTF3 ▼", style=shape.triangledown, location=location.abovebar, color=cRed,   size=size.tiny)
plotshape(heu4, "HTF4 ▲", style=shape.triangleup,   location=location.belowbar, color=cGreen, size=size.tiny)
plotshape(hed4, "HTF4 ▼", style=shape.triangledown, location=location.abovebar, color=cRed,   size=size.tiny)
plotshape(heu5, "HTF5 ▲", style=shape.triangleup,   location=location.belowbar, color=cGreen, size=size.tiny)
plotshape(hed5, "HTF5 ▼", style=shape.triangledown, location=location.abovebar, color=cRed,   size=size.tiny)

// optional TF tag labels (text is dynamic, so labels not plotshape)
f_htfTag(cond, tf, up) =>
    if htfTags and cond
        tc = up ? cGreen : cRed
        label.new(bar_index, up ? low : high, tf,
             style = up ? label.style_label_up : label.style_label_down,
             color = color.new(tc, 15), textcolor = txtOn(tc), size = size.small,
             text_formatting = text.format_bold)
f_htfTag(heu1, htf1, true)
f_htfTag(hed1, htf1, false)
f_htfTag(heu2, htf2, true)
f_htfTag(hed2, htf2, false)
f_htfTag(heu3, htf3, true)
f_htfTag(hed3, htf3, false)
f_htfTag(heu4, htf4, true)
f_htfTag(hed4, htf4, false)
f_htfTag(heu5, htf5, true)
f_htfTag(hed5, htf5, false)

// HTF legend: which timeframe each slot resolved to + its current state
hstate(en, valid, u, d) => not en ? "off" : not valid ? "—" : u ? "▲ UP" : d ? "▼ DN" : "·"
hstcol(en, valid, u, d) => (not en or not valid) ? color.gray : u ? cGreen : d ? cRed : color.gray
hnamecol(en, valid, u, d) => (not en or not valid) ? txtDim : u ? cGreen : d ? cRed : txtCol
htfLegPos = htfPosOpt == "Top Right" ? position.top_right : htfPosOpt == "Top Left" ? position.top_left : htfPosOpt == "Bottom Right" ? position.bottom_right : position.bottom_left
var table htfTab = table.new(htfLegPos, 2, 6, border_width=1, frame_width=1, frame_color=frameCol)
if showHTF and showHTFleg and barstate.islast
    table.cell(htfTab, 0, 0, "HTF SIGNALS", text_color=txtCol, text_size=size.small, bgcolor=hdrBg, text_formatting=text.format_bold)
    table.cell(htfTab, 1, 0, htfConfirmed ? "confirmed" : "live", text_color=txtCol, text_size=size.small, bgcolor=hdrBg, text_formatting=text.format_bold)
    table.cell(htfTab, 0, 1, na(htf1) ? "—" : htf1, text_color=hnamecol(en1, hv1, hu1, hd1), text_size=size.small, text_halign=text.align_left, bgcolor=cellBg, text_formatting=text.format_bold)
    table.cell(htfTab, 1, 1, hstate(en1, hv1, hu1, hd1), text_color=txtOn(hstcol(en1, hv1, hu1, hd1)), text_size=size.small, text_halign=text.align_right, bgcolor=color.new(hstcol(en1, hv1, hu1, hd1), 10), text_formatting=text.format_bold)
    table.cell(htfTab, 0, 2, na(htf2) ? "—" : htf2, text_color=hnamecol(en2, hv2, hu2, hd2), text_size=size.small, text_halign=text.align_left, bgcolor=cellBg, text_formatting=text.format_bold)
    table.cell(htfTab, 1, 2, hstate(en2, hv2, hu2, hd2), text_color=txtOn(hstcol(en2, hv2, hu2, hd2)), text_size=size.small, text_halign=text.align_right, bgcolor=color.new(hstcol(en2, hv2, hu2, hd2), 10), text_formatting=text.format_bold)
    table.cell(htfTab, 0, 3, na(htf3) ? "—" : htf3, text_color=hnamecol(en3, hv3, hu3, hd3), text_size=size.small, text_halign=text.align_left, bgcolor=cellBg, text_formatting=text.format_bold)
    table.cell(htfTab, 1, 3, hstate(en3, hv3, hu3, hd3), text_color=txtOn(hstcol(en3, hv3, hu3, hd3)), text_size=size.small, text_halign=text.align_right, bgcolor=color.new(hstcol(en3, hv3, hu3, hd3), 10), text_formatting=text.format_bold)
    table.cell(htfTab, 0, 4, na(htf4) ? "—" : htf4, text_color=hnamecol(en4, hv4, hu4, hd4), text_size=size.small, text_halign=text.align_left, bgcolor=cellBg, text_formatting=text.format_bold)
    table.cell(htfTab, 1, 4, hstate(en4, hv4, hu4, hd4), text_color=txtOn(hstcol(en4, hv4, hu4, hd4)), text_size=size.small, text_halign=text.align_right, bgcolor=color.new(hstcol(en4, hv4, hu4, hd4), 10), text_formatting=text.format_bold)
    table.cell(htfTab, 0, 5, na(htf5) ? "—" : htf5, text_color=hnamecol(en5, hv5, hu5, hd5), text_size=size.small, text_halign=text.align_left, bgcolor=cellBg, text_formatting=text.format_bold)
    table.cell(htfTab, 1, 5, hstate(en5, hv5, hu5, hd5), text_color=txtOn(hstcol(en5, hv5, hu5, hd5)), text_size=size.small, text_halign=text.align_right, bgcolor=color.new(hstcol(en5, hv5, hu5, hd5), 10), text_formatting=text.format_bold)

// optional alert when any enabled HTF fires
if (heu1 or hed1 or heu2 or hed2 or heu3 or hed3 or heu4 or hed4 or heu5 or hed5)
    alert("VPRA HTF signal | " + syminfo.ticker + " | chart " + timeframe.period, alert.freq_once_per_bar_close)

// ---------------------------------------------------------------------
// ALERTS
// ---------------------------------------------------------------------
alertcondition(ev and isExpiryNow,        "Expiry Gamma Signal",  "VPRA: GAMMA BLAST on {{ticker}} ({{interval}})")
alertcondition(ev and not isExpiryNow,    "Pressure Release",     "VPRA: pressure release on {{ticker}} ({{interval}})")
alertcondition(pressure >= critThr and pressure[1] < critThr, "Critical pressure", "VPRA: pressure CRITICAL on {{ticker}}")
alertcondition(useShock and vixSpike and not vixSpike[1], "Vol shock (VIX spike)", "VPRA: vol-index spike / vol-shock on {{ticker}} ({{interval}})")

// =====================================================================
// ADDITIONAL EXPORT FEEDS (appended here because they depend on the HTF
// ladder + basis computed above). Hidden data-window plots for companion
// scripts; they do not draw on the chart.
//   →Conf: VPRA dir ALL  combined trigger: +1 if ANY timeframe (native or
//                        the 5 HTF rungs) fired up, -1 if any fired down,
//                        0 if none — or if up & down fired the same bar.
//   →Conf: Basis state   futures-vs-spot basis: +1 premium / -1 backwardation
//                        / 0 flat (deadband = backThr). Cross-instrument feed.
// =====================================================================
bool vpUpAny = (ev and relUp) or heu1 or heu2 or heu3 or heu4 or heu5
bool vpDnAny = (ev and not relUp) or hed1 or hed2 or hed3 or hed4 or hed5
int  vpraDirAll = (vpUpAny and vpDnAny) ? 0 : vpUpAny ? 1 : vpDnAny ? -1 : 0
plot(vpraDirAll, "→Conf: VPRA dir ALL", display=display.data_window)

int basisState = not spotValid ? 0 : basisPct > backThr ? 1 : basisPct < -backThr ? -1 : 0
plot(basisState, "→Conf: Basis state", display=display.data_window)

// =====================================================================
// EXPECTED-MOVE BAND POSITION  →  feed for the Expiry Engine (PIN-FADE)
// ---------------------------------------------------------------------
//   →Conf: EM band pos   +1 price at/above the upper expected-move band
//                        -1 price at/below the lower band
//                         0 inside the band
// The band is anchored at each day's session OPEN, half-width = the
// session-horizon expected move (per-bar expPts scaled by √session-bars,
// captured at the open and held for the day) × emBandK. It is a MODEL-based
// proxy (price-path forecast), not the option-implied straddle move.
// =====================================================================
emBarMin   = math.max(timeframe.in_seconds() / 60.0, 1.0)
emSessBars = math.max(total / emBarMin, 1.0)
var float emAnchor = na
var float emHalf   = na
if dayChg != 0
    emAnchor := open
    emHalf   := expPts * math.sqrt(emSessBars) * emBandK
emUpper = emAnchor + emHalf
emLower = emAnchor - emHalf
int emBandPos = (na(emAnchor) or na(emHalf) or emHalf <= 0) ? 0 : close >= emUpper ? 1 : close <= emLower ? -1 : 0
plot(emBandPos, "→Conf: EM band pos", display=display.data_window)

// =====================================================================
// VARIANCE RISK PREMIUM (VRP)  →  feed for the Expiry Engine (PIN-FADE filter)
// ---------------------------------------------------------------------
//   →Conf: VRP       implied (volatility index) minus FORECAST realized vol,
//                    both annualized %. >0 = options rich (fades favoured),
//                    <0 = options cheap (don't fade). Engine vrpThr default 0.0
//                    works directly with this raw feed.
//   →Conf: VRP %ile  the same VRP expressed as its own recent percentile 0-100,
//                    so "rich" is relative to this symbol's history (set the
//                    engine's vrpThr near 50-60 if you wire this one instead).
// Both use rvForUse (the path forecast when ready, else trailing realized), so
// they are forward-looking — implied vol is about the future, so it is compared
// to forecast realized, not backward realized. This is a BROAD-INDEX VRP proxy
// (the volatility index is 30-day index-wide IV), not the front-expiry straddle
// premium — directionally correct as a rich/cheap filter, not the exact expiry VRP.
// =====================================================================
bool  vrpReady = useVol and not na(vix) and not na(rvForUse)
float vrp      = vrpReady ? vix - rvForUse : na
plot(nz(vrp, 0.0), "→Conf: VRP", display=display.data_window)
float vrpPct = vrpReady ? ta.percentrank(vrp, rankLen) : na
plot(nz(vrpPct, 50.0), "→Conf: VRP %ile", display=display.data_window)

// =====================================================================
// FORECAST CONE BANDS  →  feed for the Probability Engine (target / stop)
// ---------------------------------------------------------------------
//   →Conf: Cone upper   close + expected move over `coneBars` ahead
//   →Conf: Cone lower   close - expected move over `coneBars` ahead
// Half-width = per-bar expected move (expPts) × √coneBars (vol-time scaling),
// so these are the expected-move envelope `coneBars` bars forward. The
// Probability engine uses upper as long target / short stop and lower as
// long stop / short target. MODEL cone from the price-path vol forecast —
// an expected-move envelope, NOT a coverage-calibrated confidence band.
// =====================================================================
coneHalf = expPts * math.sqrt(math.max(coneBars, 1))
plot(close + coneHalf, "→Conf: Cone upper", display=display.data_window)
plot(close - coneHalf, "→Conf: Cone lower", display=display.data_window)

// =====================================================================
// PROBABILITY TRIGGER (logistic P-up)  →  feed for the Probability Engine
// ---------------------------------------------------------------------
//   →Conf: P(up)   0-100 transparent logistic "probability of an up-move".
// NOT a trained / streaming ML model — Pine cannot train or persist one.
// It is a LOGISTIC SCORECARD: directional features (trend, momentum, MACD
// slope, directional efficiency, volume flow), each softly squashed to
// [-1,1], blended by the weights below and passed through a logistic so the
// output behaves like a probability (50 = neutral) and crosses the engine's
// long/short bands (default 60/40). The number LOOKS like a probability but is
// NOT calibrated to the actual frequency of up-moves — read it as a transparent
// confidence score. Reuses VPRA's atr and efficiency ratio; other features fresh.
// =====================================================================
gPU = "Probability trigger (P-up export)"
usePup     = input.bool(true, "Export P(up) trigger", group=gPU, tooltip="Exports →Conf: P(up) for the Probability engine. Off = the feed reads na (engine won't trigger on it). This is a transparent feature scorecard squashed into a 0-100 probability-like value, NOT a calibrated probability.")
puTrendLen = input.int(50, "Trend EMA length", minval=2, group=gPU)
puRsiLen   = input.int(14, "RSI length (momentum)", minval=2, group=gPU)
puMacdF    = input.int(12, "MACD fast", minval=2, group=gPU)
puMacdS    = input.int(26, "MACD slow", minval=3, group=gPU)
puCvdLen   = input.int(20, "Volume-flow slope length", minval=2, group=gPU)
puWT   = input.float(1.2, "Weight: trend", step=0.1, group=gPU)
puWM   = input.float(1.0, "Weight: momentum", step=0.1, group=gPU)
puWMac = input.float(1.0, "Weight: MACD slope", step=0.1, group=gPU)
puWE   = input.float(1.0, "Weight: directional efficiency", step=0.1, group=gPU)
puWC   = input.float(0.8, "Weight: volume flow", step=0.1, group=gPU)
puBias = input.float(0.0, "Bias (logit intercept)", step=0.1, group=gPU)
puGain = input.float(1.0, "Logistic gain (steepness)", minval=0.1, maxval=5.0, step=0.1, group=gPU)
puSmooth = input.int(1, "Smooth P(up) (EMA, 1 = off)", minval=1, maxval=50, group=gPU)

f_puSq(x) => x / (1.0 + math.abs(x))                    // soft squash -> (-1, 1)
atrPuSafe = (na(atr) or atr == 0) ? syminfo.mintick : atr
puFTrend = f_puSq((close - ta.ema(close, puTrendLen)) / atrPuSafe)
puFMom   = math.max(-1.0, math.min(1.0, (ta.rsi(close, puRsiLen) - 50.0) / 50.0))
puFMacd  = f_puSq((ta.ema(close, puMacdF) - ta.ema(close, puMacdS)) / atrPuSafe)
puDir0   = math.sign(priceSrc - priceSrc[erLen])
puFEff   = math.max(-1.0, math.min(1.0, er * puDir0))    // er = VPRA efficiency ratio
puObv    = ta.cum((close > close[1] ? 1.0 : close < close[1] ? -1.0 : 0.0) * nz(volume, 0.0))
puObvSl  = puObv - nz(puObv[puCvdLen], puObv)
puObvSd  = ta.stdev(puObv - nz(puObv[1], puObv), 20) * math.sqrt(puCvdLen)
puFCvd   = f_puSq(puObvSd > 0 ? puObvSl / puObvSd : 0.0)
puLogit  = puBias + puWT*puFTrend + puWM*puFMom + puWMac*puFMacd + puWE*puFEff + puWC*puFCvd
puRaw    = 100.0 / (1.0 + math.exp(-puGain * puLogit))
pUp      = puSmooth > 1 ? ta.ema(puRaw, puSmooth) : puRaw
plot(usePup ? pUp : na, "→Conf: P(up)", display=display.data_window)
````
