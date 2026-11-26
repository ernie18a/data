# Statistical Mean-Reversion Engine [SMRE]

- url: https://www.tradingview.com/script/RwVTfoTY-Statistical-Mean-Reversion-Engine-SMRE/
- type: indicator
- pine_id: PUB;396868d796324a89886a024113399996
- version: 3.0

## Description

## Statistical Mean-Reversion Engine (SMRE)

SMRE is an open-source mean-reversion indicator that combines a rigorous statistical core with up to eight optional confirmation layers, designed primarily for index-futures trading on intraday timeframes (1-minute through 1-hour).

### What it does

For every bar, SMRE fits an Ornstein-Uhlenbeck (OU) process to the recent price series via linear regression on lag-1 prices, yielding four outputs:

- **μ (the mean)** — the equilibrium price the series is reverting to
- **θ (mean-reversion speed)** — how strongly the series pulls back to μ
- **HL (half-life)** — how many bars it takes to revert halfway
- **σ_eq (stationary residual variance)** — used to z-score the current price

The current price's z-score against μ (the "OU Z") is the primary signal. When |OU Z| exceeds a configurable threshold, a mean-reversion entry is considered — but only after the script also confirms that the recent price series is genuinely stationary using three orthogonal statistical tests:

- **Hurst exponent** must be below 0.55 (i.e., the series is not persistently trending)
- **Augmented Dickey-Fuller** t-statistic must be below -2.86 (rejects unit root)
- **Variance Ratio** test at q=4 must be below 1.0 (variance grows sub-linearly with horizon)

If all four conditions pass, the L1 (statistical core) signal fires.

### Why the multi-layer structure (mashup justification)

A single OU-based mean-reversion signal works well in stationary regimes but degrades in trending or volatile conditions. SMRE addresses this by validating each potential entry through up to eight orthogonal confirmation channels, each measuring something the others do not:

- **L2 — Volatility Regime (6-state):** Classifies market state via VIX, ADX, and realized volatility. Suppresses signals during high-trend conditions (regime 6, "Spike") where mean-reversion historically fails.
- **L3 — Spot-Futures Basis (Kalman filter):** Tracks the deviation between actual and theoretical futures pricing. Statistically significant basis dislocations often resolve via mean-reversion.
- **L4 — Options Surface:** Computes ATM implied volatility from straddle pricing and a skew z-score from OTM put/call ratio. Optional; requires user to provide option symbols.
- **L5 — Microstructure:** Blends rolling VWAP and session-anchored VWAP z-scores with VPIN (a volume-clock toxicity proxy) and order-flow imbalance. Captures flow-based exhaustion.
- **L6 — Gamma Walls (GEX) OR Put-Call Ratio:** Two mutually exclusive options. GEX requires OI symbols at five strikes; PCR requires a single broker-published PCR feed. Both detect option-driven price magnets.
- **L7 — Dispersion:** Rolling correlation of index returns with its top 5 constituent stocks' returns. High dispersion (low correlation) penalizes signals; high cohesion boosts them.
- **L7b — Residual Dispersion:** Idiosyncratic residual z-scores (β-adjusted) per constituent. If 3 of 5 stocks show same-sign extreme residuals, the index is detached from constituents — strong mean-reversion candidate.
- **L9 — Cross-Asset Stress:** Sigma-normalized stress across USD/INR, DXY, and crude oil. Penalizes signals during cross-asset hedging cascades.

Each layer outputs a {direction, strength} pair. The Layer 8 fusion engine combines these via a weighted composite score (default weights: L1=0.28, L5=0.22, L3=0.18, L4=0.12, L6/L7b=0.10), then applies a regime multiplier (L2 × L7 × VRP × cross-asset × expiry), clamped to [0.5, 1.5] to prevent extreme compounding.

If the absolute composite score crosses one of three thresholds (0.25 / 0.40 / 0.45 by default), a signal is fired at Scalp / Swing / Session horizon respectively. A TCA cost filter then validates that the expected move (distance to μ) exceeds estimated round-trip transaction cost; otherwise the signal is suppressed.

### Originality

The author is not aware of any other public Pine script that implements the full OU-fit chain (mean, mean-reversion speed, half-life, stationary variance) together with all three stationarity tests (Hurst, ADF, Variance Ratio) directly in Pine v6 — every step is computed natively, no external library calls. Additionally, the session-anchored VWAP with running volume-weighted sigma bands, the rolling-beta residual dispersion across multiple constituents, and the Kalman-filtered futures-basis residual are original Pine implementations. The signal telemetry module (a 200-signal FIFO ring buffer with horizon × composite-magnitude bucket attribution) is also an original diagnostic tool.

### How to use

1. **Apply to an index futures chart.** Defaults are pre-configured for NSE NIFTY1! futures, but inputs allow any index — change the VIX symbol, spot/futures symbols, constituent symbols, and currency pairs.

2. **Read the compact dashboard.** It's a single 9-row table (default position: middle-right) showing only what you need to evaluate a setup:

    | Row | What it shows | What it means |
    |---|---|---|
    | Title | Profile + OU window in use | Confirms which calibration is active |
    | OU Z-Score | Z-score with half-life (HL) | How extended price is + how long mean-reversion typically takes |
    | Stat Validity | H / ADF / VR pass-fail | Whether the recent series is actually stationary (all 3 must pass) |
    | Regime | Volatility state + VIX value | Whether market conditions favor mean-reversion |
    | Composite | Fused score × regime multiplier | The unified signal strength |
    | Confluence | Layers agreeing (out of 6) | How many orthogonal signals support the direction |
    | TCA Edge | Expected move in bps + PASS/FAIL | Whether the trade clears transaction costs |
    | E / SL / TP | Entry, Stop, Target + Risk:Reward | The trade levels if a signal fires |
    | **DECISION** | Direction · Horizon · Side | The actionable output (green=long, red=short, gray=neutral) |

3. **Trade levels and markers.** When a signal fires, entry/stop/target lines auto-plot on the chart. Stop is ATR-based (default 1.2× ATR); target is min(OU mean μ, entry + 2× ATR). Triangle markers plot below (long) or above (short) the bar — small for Scalp, medium for Swing, large for Session.

4. **Optional diagnostic.** A separate Signal Telemetry table (disabled by default; enable via the "Show Telemetry Dashboard" input) tracks the last 200 signals' outcomes (win = price touched μ, loss = stop hit, expired = timeout) and reports hit rate by horizon × composite-magnitude bucket. This is a backward-looking diagnostic, not a backtest.

### Recommended chart and timeframe

This indicator was developed and parameter-tested primarily on NIFTY1! futures. The OU window auto-mapping (1m→32, 2m→20, 5m→12, 15m→32, 30m→20, 1h→24) was selected empirically through parameter sweeps. Users on other instruments should expect to tune the OU window manually or accept the auto-mapped default as a starting point.

The indicator works on any timeframe between 1 minute and daily, though intraday timeframes (1m through 1h) are where the multi-layer confluence adds the most value.

### Important notes

- This is an **indicator**, not a strategy — no backtest equity curve is produced. The telemetry table is a descriptive measure of recent signal outcomes only.
- Many layers are **optional**. If you don't have symbols for options OI, just leave those inputs blank; the script will redistribute composite weight naturally across the active layers.
- Signals can fluctuate intra-bar before bar close, especially in real-time mode. For consistent behavior, evaluate signals on closed bars only.
- The default constituents (top-5 NIFTY weights) need to be changed in the L7 inputs to use this on a different index.

### Disclaimer

This indicator is published for educational and research purposes only. It is not financial advice, not an investment recommendation, and not a solicitation to trade. Past behavior of signals does not guarantee future results. Trading futures, options, and equities carries substantial risk of loss. You are solely responsible for your trading decisions. The author makes no representations about the accuracy, completeness, or suitability of this indicator for any particular purpose. Use at your own risk, and always consult a qualified financial professional before trading.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// at https://mozilla.org/MPL/2.0/
// ============================================================================
//  Statistical Mean-Reversion Engine with Multi-Layer Confluence (SMRE)
// ============================================================================
//
//  WHAT THIS INDICATOR DOES
//  ------------------------
//  SMRE looks for potential mean-reversion conditions on liquid instruments
//  (built and tested on index futures, but market-agnostic) by combining a
//  statistical core (Ornstein-Uhlenbeck process fit, Hurst exponent,
//  Augmented Dickey-Fuller test, Variance Ratio test) with up to eight
//  optional confirmation layers: volatility regime, spot-futures basis,
//  options surface, microstructure, gamma exposure, index-vs-constituent
//  dispersion, residual dispersion, and cross-asset stress. All layers feed a
//  single weighted composite score that sets direction, horizon and
//  conviction. It is an INDICATOR, not a strategy: it places no orders and
//  produces no backtest equity curve.
//
//  WORKS ON ANY MARKET (all data sources are configurable)
//  -------------------------------------------------------
//  Nothing is hard-coded to one exchange. The price series used by the
//  statistical core is selectable (Price source). The timezone auto-follows
//  the chart symbol's exchange. The session open/close used by the
//  time-of-day filter, the annualization factor (trading days per year and
//  session length), the expiry day of week, and every external symbol
//  (volatility index, spot, futures, the five constituents, and the three
//  cross-asset feeds) are all inputs. With no external symbols set, the
//  price-only layers (L1 statistical core and L5 microstructure) still run on
//  any chart; fill in the symbols that exist for your market to activate the
//  rest.
//
//  WHY THE MULTI-LAYER STRUCTURE (mashup justification)
//  ----------------------------------------------------
//  Single-indicator mean-reversion signals (RSI extremes, band touches) throw
//  too many false positives in trends. SMRE first requires statistical
//  evidence of stationarity (OU half-life, Hurst below a ceiling, ADF
//  rejection, Variance Ratio) BEFORE any signal fires, then validates through
//  orthogonal channels that each measure something the others do not:
//   - L2 volatility regime filters out high-trend states where reversion
//     historically fails.
//   - L3 spot-futures basis (Kalman-filtered) flags pricing dislocations that
//     often resolve by reverting.
//   - L5 session-anchored VWAP + VPIN microstructure confirms via flow.
//   - L6 net dealer gamma exposure (optional) builds signed GEX from call and
//     put open interest across five strikes around ATM, volume-weighted, and
//     biases toward the dominant gamma wall only when its sign matches the
//     expected support/resistance behaviour.
//   - L7 / L7b dispersion detect when the index has detached from its
//     constituents (correlation and rolling-beta residuals).
//   - L9 cross-asset stress dampens signals during macro stress, using three
//     configurable feeds: a currency cross, a broad dollar / risk-off proxy,
//     and a commodity (for example crude). Choose feeds relevant to your
//     instrument.
//  Because each layer covers a distinct failure mode, all are retained; the
//  fusion weights reflect each layer's relative reliability in reverting
//  conditions.
//
//  ORIGINALITY
//  -----------
//  The full OU-fit chain (lag-1 regression yielding mean, reversion speed,
//  half-life and stationary residual variance) is implemented directly in
//  Pine v6 and gated by three orthogonal stationarity tests (Hurst, ADF,
//  Variance Ratio at q = 2/4/8). The session-anchored VWAP with running
//  sigma-bands, the rolling-beta residual dispersion across five weights, and
//  the Kalman-filtered basis residual are also original Pine implementations.
//  The contribution is the integration, not any single formula.
//
//  HOW TO USE
//  ----------
//  1. Add to a liquid intraday chart. Set the external symbols for your market
//     in the inputs (volatility index, spot, futures, constituents, cross-
//     asset feeds). Anything left blank simply contributes nothing.
//  2. Under Risk & Execution, set the session open/close (in the symbol's
//     exchange timezone); under L2, set the trading-days-per-year and session
//     length used for annualization, to match your market.
//  3. Read the compact dashboard: OU Z-score + half-life, statistical validity
//     (Hurst/ADF/VR), regime + volatility-index level, composite + multiplier,
//     confluence count, TCA edge, trade levels, and the DECISION row
//     (direction, horizon, suggested option side).
//  4. Three horizons (Scalp/Swing/Session) fire by which composite-threshold
//     band is crossed; triangles plot below (long) or above (short).
//  5. The optional Telemetry table (off by default) shows rolling hit-rate
//     diagnostics for recent signals. It is a backward-looking DESCRIPTION of
//     past signals, NOT a backtest and NOT a guarantee of future results.
//
//  KEY PARAMETERS
//  --------------
//  - OU Window: auto-mapped from chart timeframe, or manual. Values were
//    chosen via parameter sweeps; adjust for your instrument.
//  - Hurst Ceiling (0.55): suppresses signals when price shows persistent
//    (trending) behaviour.
//  - Composite Thresholds (Scalp/Swing/Session): minimum |composite| per
//    horizon.
//  - TCA Cost Filter: blocks signals whose expected move (distance to the OU
//    mean) does not clear an estimated round-trip cost.
//
//  KNOWN LIMITATIONS
//  -----------------
//  - Set the five constituent symbols to your index's top weights for the
//    dispersion layers to be meaningful.
//  - Options-layer inputs (ATM/OTM calls and puts; five call + five put OI
//    strikes) require manual symbol entry; if blank, those layers contribute
//    nothing and the composite redistributes across active layers. L6 is off
//    by default as it can use about ten security calls.
//  - The OU fit assumes mean-reverting action; in strong trends the Hurst
//    filter should disable signals (verify the dashboard shows Hurst failing).
//  - Telemetry describes only recent signals; it does not predict the future.
//
//  DISCLAIMER
//  ----------
//  Published for education and research only. Not financial advice, not an
//  investment recommendation, and not a solicitation to trade any instrument.
//  This is an INDICATOR, not a strategy: it places no orders and produces no
//  backtest equity curve. Any telemetry hit-rate is a descriptive measure of
//  recent signals over a rolling window, not a guarantee of future results and
//  not a backtest. Trading futures, options and equities carries substantial
//  risk of loss and is not suitable for everyone; mean-reversion approaches can
//  suffer prolonged drawdowns in trending regimes. You are solely responsible
//  for your own decisions, sizing, risk management and outcomes. Provided
//  AS-IS with no warranty of any kind. Not affiliated with or endorsed by any
//  exchange, broker, data provider, index sponsor or TradingView; all symbol
//  references are user-supplied data inputs only. Always consult a qualified
//  financial professional before trading.
//
// ============================================================================

//@version=6
indicator("Statistical Mean-Reversion Engine [SMRE]", shorttitle="SMRE",
     overlay=true, max_lines_count=50, max_labels_count=100, max_bars_back=500)

// ============================================================================
// INPUT GROUPS
// ============================================================================
g1  = "L1: Statistical Core"
g2  = "L2: Volatility Regime"
g3  = "L3: Spot-Futures Basis (Kalman)"
g4  = "L4: Options Surface"
g5  = "L5: Microstructure"
g6  = "L6: GEX / Gamma Walls"
g7  = "L7: Dispersion"
g8  = "L8: Fusion + TCA + Horizon"
gR  = "Risk & Execution"
gS  = "Strike Engine"
gD  = "Dashboard"
gT  = "Telemetry"
gV  = "Session Guards"
gW  = "Session-Anchored VWAP"
gX  = "Residual Dispersion (L7b)"
gY  = "Multiplier Caps & Misc"
gZ  = "Volatility Risk Premium"
gA  = "Cross-Asset Flows (L9)"
gP  = "Put-Call Ratio (alternative L6)"
gE  = "Expiry-Day Mode"
gC  = "Timeframe Auto-Calibration"
gH  = "High-Trend Regime Block"

// --- L1 ---
useL1       = input.bool(true, "Enable L1 Statistical Core", group=g1)
srcP        = input.source(close, "Price source", group=g1, tooltip="Series the statistical core (OU fit, Hurst, ADF, Variance Ratio) and the return calculations are built from. Default close; you may pick hl2, ohlc4 or another series. Execution levels and option strikes stay on close.")
ouLen       = input.int(80, "OU Window (bars) - used only when Auto-Calib is OFF", minval=15, maxval=300, group=g1)
zScalp      = input.float(1.5, "Z Scalp",   minval=0.8, maxval=4.0, step=0.1, group=g1)
zSwing      = input.float(2.0, "Z Swing",   minval=1.0, maxval=4.0, step=0.1, group=g1)
zSession    = input.float(2.5, "Z Session", minval=1.5, maxval=5.0, step=0.1, group=g1)
hlMax       = input.int(60, "Max Half-Life (bars)", minval=5, maxval=200, group=g1)
hurstMax    = input.float(0.55, "Hurst Ceiling", minval=0.3, maxval=0.7, step=0.01, group=g1)
useADF      = input.bool(true, "Require ADF Stationarity", group=g1)
useVR       = input.bool(true, "Require Variance Ratio Test", group=g1)

// --- L2 ---
useL2       = input.bool(true, "Enable L2 Vol Regime", group=g2)
vixSym      = input.symbol("", "Volatility Index symbol (optional, e.g. your market VIX)", group=g2)
vixLo       = input.float(12.0, "VIX Low",  group=g2)
vixHi       = input.float(20.0, "VIX High", group=g2)
adxTrendThr = input.float(25.0, "ADX Trend Threshold", group=g2)
rvWin       = input.int(20, "Realized Vol Window", group=g2)
tradingDaysYr = input.int(252, "Trading days per year (annualization)", minval=200, maxval=366, group=g2)
sessionHrs    = input.float(6.5, "Session length hours (annualization)", minval=1.0, maxval=24.0, step=0.25, group=g2)

// --- L3 ---
useL3       = input.bool(true, "Enable L3 Basis Kalman", group=g3)
spotSym     = input.symbol("", "Index spot symbol (optional)", group=g3)
futSym      = input.symbol("", "Index futures symbol (optional)", group=g3)
rfRate      = input.float(5.0, "Risk-Free Rate %", minval=0, maxval=15, step=0.25, group=g3)
basisZThr   = input.float(1.5, "Basis Z Threshold", group=g3)
kalmanQ     = input.float(0.001, "Kalman Process Var", minval=0.00001, maxval=0.1, step=0.0001, group=g3)
kalmanR     = input.float(0.1,   "Kalman Obs Var",     minval=0.001,   maxval=1.0, step=0.01,   group=g3)

// --- L4 ---
useL4       = input.bool(true, "Enable L4 Options", group=g4)
atmCE       = input.symbol("", "ATM Call Symbol (optional)", group=g4)
atmPE       = input.symbol("", "ATM Put Symbol (optional)",  group=g4)
otmCE       = input.symbol("", "OTM Call (~+2%) (optional)", group=g4)
otmPE       = input.symbol("", "OTM Put  (~-2%) (optional)", group=g4)
daysToExp   = input.int(7, "Days To Expiry (heuristic)", minval=0, maxval=45, group=g4)
skewZThr    = input.float(1.5, "Skew Z Threshold", minval=0.5, maxval=4.0, step=0.1, group=g4)

// --- L5 ---
useL5       = input.bool(true, "Enable L5 Microstructure", group=g5)
vwapDevWin  = input.int(20,  "VWAP Dev Window", group=g5)
vwapZThr    = input.float(1.5, "VWAP Z Threshold", minval=0.5, maxval=4.0, step=0.1, group=g5)
volMult     = input.float(1.5, "Volume Spike Mult", group=g5)
vpinBuckets = input.int(50,  "VPIN Bucket Count", group=g5)

// --- L6 ---
useL6       = input.bool(false, "Enable L6 GEX (uses ~10 security calls)", group=g6,
                tooltip="When enabled, fetches Open Interest at 5 CE and 5 PE strikes around ATM to compute net dealer Gamma Exposure (GEX = g x [CE_OI - PE_OI]). Each strike also fetches volume for activity signal. Leave OI inputs blank if you don't have OI ticker symbols; the layer will gracefully degrade to zero contribution.")
oiCE_m2     = input.symbol("", "OI CE ATM-2 (optional)", group=g6)
oiCE_m1     = input.symbol("", "OI CE ATM-1 (optional)", group=g6)
oiCE_0      = input.symbol("", "OI CE ATM   (optional)", group=g6)
oiCE_p1     = input.symbol("", "OI CE ATM+1 (optional)", group=g6)
oiCE_p2     = input.symbol("", "OI CE ATM+2 (optional)", group=g6)
oiPE_m2     = input.symbol("", "OI PE ATM-2 (optional)", group=g6)
oiPE_m1     = input.symbol("", "OI PE ATM-1 (optional)", group=g6)
oiPE_0      = input.symbol("", "OI PE ATM   (optional)", group=g6)
oiPE_p1     = input.symbol("", "OI PE ATM+1 (optional)", group=g6)
oiPE_p2     = input.symbol("", "OI PE ATM+2 (optional)", group=g6)
strikeStep  = input.int(50, "Strike Step", group=g6)
useGexFlow  = input.bool(true, "Use option volume as flow weight", group=g6,
                tooltip="When enabled, weight the gamma contribution at each strike by recent option-contract volume (sum of CE+PE volume divided by 20-bar average). Reflects which strikes are actively being traded vs stale OI. Free - no extra security calls.")

// --- L7 ---
useL7       = input.bool(true, "Enable L7 Dispersion", group=g7)
w1Sym       = input.symbol("", "Constituent 1 - top index weight (optional)", group=g7)
w2Sym       = input.symbol("", "Constituent 2 - top index weight (optional)", group=g7)
w3Sym       = input.symbol("", "Constituent 3 - top index weight (optional)", group=g7)
w4Sym       = input.symbol("", "Constituent 4 - top index weight (optional)", group=g7)
w5Sym       = input.symbol("", "Constituent 5 - top index weight (optional)", group=g7)
corrWin     = input.int(60, "Correlation Window", group=g7)

// --- L8 Fusion + TCA ---
fusion      = input.string("Weighted Composite", "Fusion Mode",
                options=["Weighted Composite", "Confluence Count", "Strict"], group=g8)
minConf     = input.int(3, "Min Confluence", minval=2, maxval=6, group=g8)
threshScalp = input.float(0.25, "Composite Threshold Scalp",   minval=0.10, maxval=1.0, step=0.05, group=g8)
threshSwing = input.float(0.40, "Composite Threshold Swing",   minval=0.20, maxval=1.0, step=0.05, group=g8)
threshSess  = input.float(0.45, "Composite Threshold Session", minval=0.30, maxval=1.0, step=0.05, group=g8)
useTCA      = input.bool(true, "Apply TCA Cost Filter", group=g8)
tcaBpsRound = input.float(4.0, "Round-Trip Cost (bps)", minval=1, maxval=50, step=0.5, group=g8)
tcaSharpeMult = input.float(1.0, "Required Edge Multiple (base)", minval=0.5, maxval=5.0, step=0.25, group=g8)

// --- Risk ---
useTimeFilter = input.bool(true, "Time-of-Day Filter", group=gR)
avoidOpenMin  = input.int(15, "Skip Open N min",  group=gR)
avoidCloseMin = input.int(15, "Skip Close N min", group=gR)
avoidLunch    = input.bool(true, "Skip a midday lunch hour", group=gR)
sessOpenHr    = input.int(9,  "Session open hour (exchange tz)",  minval=0, maxval=23, group=gR)
sessOpenMn    = input.int(15, "Session open minute",              minval=0, maxval=59, group=gR)
sessCloseHr   = input.int(15, "Session close hour (exchange tz)", minval=0, maxval=23, group=gR)
sessCloseMn   = input.int(30, "Session close minute",             minval=0, maxval=59, group=gR)
lunchHr       = input.int(12, "Lunch hour to skip (exchange tz)", minval=0, maxval=23, group=gR)
slAtrMult     = input.float(1.2, "SL ATR Mult", minval=0.3, maxval=5.0, step=0.1, group=gR)
tpAtrMult     = input.float(2.0, "TP ATR Mult", minval=0.5, maxval=5.0, step=0.1, group=gR)

// --- Strike ---
deltaScalp  = input.float(0.60, "Scalp Delta",   minval=0.3, maxval=0.9, step=0.05, group=gS)
deltaSwing  = input.float(0.50, "Swing Delta",   minval=0.3, maxval=0.7, step=0.05, group=gS)
deltaSess   = input.float(0.40, "Session Delta", minval=0.2, maxval=0.6, step=0.05, group=gS)

// --- Dashboard ---
showDash    = input.bool(true, "Show Dashboard", group=gD)
dashPos     = input.string("top_right", "Position",
                options=["top_left","top_right","bottom_left","bottom_right","middle_right"], group=gD)
showLevels  = input.bool(true, "Plot Entry/SL/TP", group=gD)
showOUBands = input.bool(true, "Plot OU Mean & Bands", group=gD)
showGexWall = input.bool(true, "Plot Gamma Walls", group=gD)

// --- Telemetry ---
useTelemetry   = input.bool(true,  "Enable Signal Telemetry",       group=gT)
maxSignals     = input.int(200,    "Max Tracked Signals",  minval=50, maxval=500, group=gT)
scalpResWin    = input.int(15,     "Scalp Resolution Window (bars)",  minval=5,  maxval=50,  group=gT,
                    tooltip="Max bars a scalp signal stays open before being marked 'expired'. Lower values increase expired rate but resolve faster.")
swingResWin    = input.int(60,     "Swing Resolution Window (bars)",  minval=20, maxval=120, group=gT,
                    tooltip="Max bars a swing signal stays open before being marked 'expired'.")
sessResWin     = input.int(150,    "Session Resolution Window (bars)",minval=50, maxval=300, group=gT,
                    tooltip="Max bars a session signal stays open before being marked 'expired'.")
meanTouchAtr   = input.float(0.25, "Mean-Touch Tolerance (ATR mult)", minval=0.0, maxval=1.0, step=0.05, group=gT)
bucketLowMax   = input.float(0.30, "Low Composite Bucket Ceiling",  minval=0.10, maxval=0.50, step=0.05, group=gT)
bucketMidMax   = input.float(0.50, "Mid Composite Bucket Ceiling",  minval=0.30, maxval=0.80, step=0.05, group=gT)
showTelemDash  = input.bool(false, "Show Telemetry Dashboard (diagnostic, separate table)", group=gT,
                    tooltip="Optional second table showing rolling hit-rate diagnostics for the last 200 signals. Off by default to keep the chart clean. Enable for performance analysis.")
telemDashPos   = input.string("bottom_right", "Telemetry Position",
                    options=["top_left","top_right","bottom_left","bottom_right","middle_left"], group=gT)

// --- v2.2 Session Guards ---
useSessionGuards = input.bool(true,  "Enable Session-Boundary Guards", group=gV)
sessionGapMult   = input.float(3.0,  "Gap Detection (x median bar)",   minval=1.5, maxval=10.0, step=0.5, group=gV)
sessionStartSkip = input.int(5,      "Skip First N Bars of Session (when Auto-Skip OFF)",   minval=0, maxval=20, group=gV)
gapInvalidatesL1 = input.bool(true,  "Gap In Window Invalidates L1",   group=gV)

// --- v2.2 Session-Anchored VWAP ---
useAnchorVWAP    = input.bool(true,  "Enable Session-Anchored VWAP",   group=gW)
anchorVwapZThr   = input.float(2.0,  "Anchored VWAP Z Threshold",      minval=0.5, maxval=4.0, step=0.1, group=gW)
anchorVwapWeight = input.float(0.60, "Anchored VWAP Weight in L5",     minval=0.0, maxval=1.0, step=0.05, group=gW)

// --- v2.2 Residual Dispersion ---
useResidualDisp  = input.bool(true,  "Enable Residual Dispersion (L7b)", group=gX)
residWin         = input.int(60,     "Residual Lookback (bars)",         minval=30, maxval=200, group=gX)
residSigmaThr    = input.float(1.0,  "Residual sigma Threshold",         minval=0.5, maxval=3.0, step=0.1, group=gX)
residMinAgree    = input.int(3,      "Min Stocks Agreeing (of 5)",       minval=2, maxval=5, group=gX)
residWeight      = input.float(0.12, "L7b Weight in Composite",          minval=0.0, maxval=0.30, step=0.02, group=gX)

// --- v2.3 TF-Aware Session Skip ---
useTfAwareSkip   = input.bool(true,  "Auto-Scale Session Skip by TF",  group=gY)
sessionSkipMins  = input.float(25.0, "Session Warmup (minutes)",       minval=5.0, maxval=120.0, step=5.0, group=gY)
recordLayerTag   = input.bool(true,  "Tag Signals with Dominant Layer",group=gY)

// --- v2.3 VRP Multiplier ---
useVrpMult       = input.bool(true,  "Enable VRP Active Multiplier",   group=gZ)
vrpHighThr       = input.float(5.0,  "VRP High (IV-RV gap) Threshold", minval=2.0, maxval=15.0, step=0.5, group=gZ)
vrpLowThr        = input.float(-2.0, "VRP Low Threshold",              minval=-10.0, maxval=0.0, step=0.5, group=gZ)
vrpHighMult      = input.float(1.15, "Multiplier when VRP High",       minval=1.00, maxval=1.50, step=0.05, group=gZ)
vrpLowMult       = input.float(0.80, "Multiplier when VRP Low",        minval=0.50, maxval=1.00, step=0.05, group=gZ)

// --- v2.3 Cross-Asset Flows (L9) ---
useL9            = input.bool(true,  "Enable L9 Cross-Asset Stress",   group=gA)
usdinrSym        = input.symbol("", "Cross-asset 1 - currency cross (optional)", group=gA)
dxySym           = input.symbol("", "Cross-asset 2 - dollar / risk-off proxy (optional)", group=gA)
crudeSym         = input.symbol("", "Cross-asset 3 - commodity, e.g. crude (optional)", group=gA)
crossStressWin   = input.int(50,     "Stress Normalization Window",    minval=20, maxval=200, group=gA)
crossHighThr     = input.float(2.0,  "High Stress sigma Threshold",    minval=1.0, maxval=4.0, step=0.1, group=gA)
crossHighMult    = input.float(0.75, "Multiplier when Stress High",    minval=0.30, maxval=1.00, step=0.05, group=gA)
crossLowMult     = input.float(1.10, "Multiplier when Stress Low",     minval=1.00, maxval=1.30, step=0.05, group=gA)

// --- v2.3 PCR ---
usePCR           = input.bool(false, "Enable PCR (replaces GEX)",      group=gP)
pcrSym           = input.symbol("",  "PCR Symbol (optional)",          group=gP)
pcrHighThr       = input.float(1.30, "PCR High (oversold) Threshold",  minval=1.0, maxval=2.0, step=0.05, group=gP)
pcrLowThr        = input.float(0.70, "PCR Low (overbought) Threshold", minval=0.3, maxval=1.0, step=0.05, group=gP)
pcrWeight        = input.float(0.10, "PCR Weight in Composite",        minval=0.0, maxval=0.25, step=0.02, group=gP)

// --- v2.3 Expiry-Day Mode ---
useExpiryMode    = input.bool(true,  "Enable Expiry-Day Pinning",      group=gE)
expiryDayName    = input.string("Friday", "Expiry Day of Week",
                    options=["Monday","Tuesday","Wednesday","Thursday","Friday"], group=gE)
expiryAfterHour  = input.int(12,     "Pinning Active After Hour (exchange tz)",minval=9, maxval=15, group=gE)
expiryMrBoost    = input.float(1.20, "MR Boost When Aligned With Pin", minval=1.00, maxval=1.50, step=0.05, group=gE)
expiryMrPenalty  = input.float(0.70, "MR Penalty When Against Pin",    minval=0.30, maxval=1.00, step=0.05, group=gE)

// --- Final multiplier cap ---
multClampLo      = input.float(0.50, "Min Composite Multiplier",       minval=0.10, maxval=1.00, step=0.05, group=gY)
multClampHi      = input.float(1.50, "Max Composite Multiplier",       minval=1.00, maxval=2.50, step=0.05, group=gY)

// --- v2.8 TF Auto-Calibration (simplified to OU-only) ---
useTfCalib       = input.bool(true,  "Enable TF Auto-Calibration (OU window)", group=gC,
                    tooltip="When ON, OU window auto-adjusts to chart timeframe per empirical mapping. When OFF, manual ouLen is used.")
forceOuWindow    = input.string("Auto", "Force OU Window (research only)",
                    options=["Auto","Short","Mid","Long"], group=gC,
                    tooltip="Auto = empirical mapping based on chart TF. Short/Mid/Long = override for A/B testing. Short ~ 0.6x, Mid ~ 1.0x, Long ~ 1.6x of auto value.")

// --- v2.8 High-Trend Hard Block ---
useHighTrendBlock = input.bool(true, "Hard-block signals in High-Trend/Spike regime (regime==6)", group=gH,
                    tooltip="When the volatility regime is classified as Spike (VIX above the high threshold combined with strong trending ADX or a large VIX rate-of-change), suppress all signals regardless of composite score. Mean-reversion strategies typically underperform in such regimes.")

// ============================================================================
// EXTERNAL DATA FETCHES
// ============================================================================
vix     = (useL2 and vixSym != "") ? request.security(vixSym,  timeframe.period, close, ignore_invalid_symbol=true) : na
spotPx  = (useL3 and spotSym != "") ? request.security(spotSym, timeframe.period, close, ignore_invalid_symbol=true) : na
futPx   = (useL3 and futSym != "") ? request.security(futSym,  timeframe.period, close, ignore_invalid_symbol=true) : na

atmCEpx = (useL4 and atmCE != "") ? request.security(atmCE, timeframe.period, close, ignore_invalid_symbol=true) : na
atmPEpx = (useL4 and atmPE != "") ? request.security(atmPE, timeframe.period, close, ignore_invalid_symbol=true) : na
otmCEpx = (useL4 and otmCE != "") ? request.security(otmCE, timeframe.period, close, ignore_invalid_symbol=true) : na
otmPEpx = (useL4 and otmPE != "") ? request.security(otmPE, timeframe.period, close, ignore_invalid_symbol=true) : na

useGexFetches = useL6 and not usePCR

// Helper to conditionally fetch [close, volume] for an OI symbol.
// Pine v6 doesn't allow ternary expressions to return tuples, so we use
// an if/else inside a function that returns the tuple.
f_fetchOiVol(sym, enabled) =>
    float oiVal = na
    float volVal = na
    if enabled and sym != ""
        [c, v] = request.security(sym, timeframe.period, [close, volume], ignore_invalid_symbol=true)
        oiVal := c
        volVal := v
    [oiVal, volVal]

// CE side: fetch [OI, volume] for 5 strikes around ATM
[oiM2_ce, volM2_ce] = f_fetchOiVol(oiCE_m2, useGexFetches)
[oiM1_ce, volM1_ce] = f_fetchOiVol(oiCE_m1, useGexFetches)
[oi0_ce,  vol0_ce ] = f_fetchOiVol(oiCE_0,  useGexFetches)
[oiP1_ce, volP1_ce] = f_fetchOiVol(oiCE_p1, useGexFetches)
[oiP2_ce, volP2_ce] = f_fetchOiVol(oiCE_p2, useGexFetches)

// PE side: same shape
[oiM2_pe, volM2_pe] = f_fetchOiVol(oiPE_m2, useGexFetches)
[oiM1_pe, volM1_pe] = f_fetchOiVol(oiPE_m1, useGexFetches)
[oi0_pe,  vol0_pe ] = f_fetchOiVol(oiPE_0,  useGexFetches)
[oiP1_pe, volP1_pe] = f_fetchOiVol(oiPE_p1, useGexFetches)
[oiP2_pe, volP2_pe] = f_fetchOiVol(oiPE_p2, useGexFetches)

pcrVal = (usePCR and pcrSym != "") ? request.security(pcrSym, timeframe.period, close, ignore_invalid_symbol=true) : na

w1Px = (useL7 and w1Sym != "") ? request.security(w1Sym, timeframe.period, close, ignore_invalid_symbol=true) : na
w2Px = (useL7 and w2Sym != "") ? request.security(w2Sym, timeframe.period, close, ignore_invalid_symbol=true) : na
w3Px = (useL7 and w3Sym != "") ? request.security(w3Sym, timeframe.period, close, ignore_invalid_symbol=true) : na
w4Px = (useL7 and w4Sym != "") ? request.security(w4Sym, timeframe.period, close, ignore_invalid_symbol=true) : na
w5Px = (useL7 and w5Sym != "") ? request.security(w5Sym, timeframe.period, close, ignore_invalid_symbol=true) : na

usdinrPx = (useL9 and usdinrSym != "") ? request.security(usdinrSym, timeframe.period, close, ignore_invalid_symbol=true) : na
dxyPx    = (useL9 and dxySym != "") ? request.security(dxySym,    timeframe.period, close, ignore_invalid_symbol=true) : na
crudePx  = (useL9 and crudeSym != "") ? request.security(crudeSym,  timeframe.period, close, ignore_invalid_symbol=true) : na

// ============================================================================
// GLOBAL UTILITIES
// ============================================================================
atrVal  = ta.atr(14)
atrSafe = math.max(atrVal, 1e-6)

exHr = hour(time, syminfo.timezone)
exMn = minute(time, syminfo.timezone)

barIntervalSec = timeframe.in_seconds(timeframe.period)
barMinutes     = barIntervalSec / 60.0
effectiveSkipBars = useTfAwareSkip and barMinutes > 0 ? math.max(1, math.round(sessionSkipMins / barMinutes)) : sessionStartSkip

// OU AUTO-MAPPING (empirical, from sweep experiments)
ouAuto = 0
if barMinutes <= 1.5
    ouAuto := 32
else if barMinutes <= 2.5
    ouAuto := 20
else if barMinutes <= 7.5
    ouAuto := 12
else if barMinutes <= 22.0
    ouAuto := 32
else if barMinutes <= 45.0
    ouAuto := 20
else
    ouAuto := 24

// Force-OU dropdown lets you A/B test against the auto value
ouForced = forceOuWindow == "Short" ? math.round(ouAuto * 0.6) : forceOuWindow == "Long" ? math.round(ouAuto * 1.6) : ouAuto
// Final OU: from auto-mapping when calib ON, manual otherwise
ouLen_eff_raw = useTfCalib ? ouForced : ouLen
// Defensive floor: f_vr(_, len, 8) needs len > 9. We floor at 15 for headroom.
ouLen_eff = math.max(15, ouLen_eff_raw)

// "Profile" label (cosmetic only - for footer)
profileName = barMinutes <= 1.5  ? "1m"  : barMinutes <= 2.5  ? "2m"  : barMinutes <= 7.5  ? "5m"  : barMinutes <= 22.0 ? "15m" : barMinutes <= 45.0 ? "30m" : barMinutes <= 75.0 ? "1h"  : barMinutes <= 300.0 ? "4h"  : "D+"

// CONSTANT BASELINE
hurstMax_eff         = 0.55
zScalp_eff           = 1.5
zSwing_eff           = 2.0
zSession_eff         = 2.5
threshScalp_eff      = 0.25
threshSwing_eff      = 0.40
threshSess_eff       = 0.45
anchorVwapWeight_eff = 0.60

// L9 stays TF-dependent
useL9_eff = useL9 and barMinutes > 1.5 and barMinutes < 200.0

// Resolution windows come from inputs now
scalpResWin_eff = scalpResWin
swingResWin_eff = swingResWin
sessResWin_eff  = sessResWin

// SESSION-BOUNDARY DETECTION
barDeltaMs   = time - time[1]
medBarMsRaw = ta.median(time - time[1], 50)
medBarMs = bar_index > 50 ? medBarMsRaw : float(na)
isSessionStart = useSessionGuards and not na(medBarMs) and barDeltaMs > medBarMs * sessionGapMult

var int barsSinceSession = 0
if isSessionStart
    barsSinceSession := 0
else
    barsSinceSession += 1

f_windowHasGap(n) =>
    bool found = false
    for i = 0 to math.min(n, 500) - 1
        if isSessionStart[i]
            found := true
            break
    found

// ============================================================================
// L1: STATISTICAL CORE
// ============================================================================
f_ou(src, len) =>
    sumX = 0.0
    sumY = 0.0
    sumXY = 0.0
    sumX2 = 0.0
    n = len
    for i = 1 to len
        x = src[i]
        y = src[i-1]
        sumX  += x
        sumY  += y
        sumXY += x * y
        sumX2 += x * x
    meanX = sumX / n
    meanY = sumY / n
    varX = (sumX2 / n) - meanX * meanX
    cov  = (sumXY / n) - meanX * meanY
    b = varX > 0 ? cov / varX : float(na)
    a = na(b) ? float(na) : meanY - b * meanX
    theta = (not na(b) and b > 0 and b < 1) ? -math.log(b) : float(na)
    mu    = (not na(b) and b != 1) ? a / (1.0 - b) : float(na)
    hl    = (not na(theta) and theta > 0) ? math.log(2) / theta : float(na)
    resSum2 = 0.0
    for i = 1 to len
        pred = a + b * src[i-1]
        res = src[i] - pred
        resSum2 += res * res
    sEps = math.sqrt(resSum2 / math.max(n - 2, 1))
    sEq  = (not na(b) and (1 - b*b) > 0) ? sEps / math.sqrt(1 - b*b) : float(na)
    [mu, theta, hl, sEq]

f_hurst(src, len) =>
    n = len - 1
    sumR = 0.0
    for i = 0 to n - 1
        sumR += math.log(src[i] / src[i+1])
    mu = sumR / n
    runSum = 0.0
    mx = -1e10
    mn =  1e10
    for i = 0 to n - 1
        idx = n - 1 - i
        r = math.log(src[idx] / src[idx+1])
        runSum += r - mu
        mx := math.max(mx, runSum)
        mn := math.min(mn, runSum)
    rng = mx - mn
    sumSq = 0.0
    for i = 0 to n - 1
        r = math.log(src[i] / src[i+1])
        sumSq += math.pow(r - mu, 2)
    sd = math.sqrt(sumSq / math.max(n - 1, 1))
    rs = (sd > 0) ? rng / sd : float(na)
    (not na(rs) and rs > 0) ? math.log(rs) / math.log(n) : float(na)

f_adf(src, len) =>
    sumY = 0.0
    sumDY = 0.0
    sumYDY = 0.0
    sumY2 = 0.0
    n = len
    for i = 1 to len
        y = src[i]
        dy = src[i-1] - src[i]
        sumY   += y
        sumDY  += dy
        sumYDY += y * dy
        sumY2  += y * y
    meanY = sumY / n
    meanDY = sumDY / n
    SSxx = sumY2 - n * meanY * meanY
    SSxy = sumYDY - n * meanY * meanDY
    gamma = SSxx > 0 ? SSxy / SSxx : float(na)
    alpha = na(gamma) ? float(na) : meanDY - gamma * meanY
    resSum2 = 0.0
    for i = 1 to len
        y = src[i]
        dy = src[i-1] - src[i]
        pred = alpha + gamma * y
        res = dy - pred
        resSum2 += res * res
    sigma2 = resSum2 / math.max(n - 2, 1)
    seGamma = (SSxx > 0) ? math.sqrt(sigma2 / SSxx) : float(na)
    tStat = (not na(gamma) and not na(seGamma) and seGamma > 0) ? gamma / seGamma : float(na)
    tStat

f_vr(src, len, q) =>
    float result = float(na)
    if len > q + 1
        var1Sum = 0.0
        varQSum = 0.0
        var1Mean = 0.0
        varQMean = 0.0
        cnt1 = len - 1
        cntQ = len - q
        for i = 0 to cnt1 - 1
            r = src[i] - src[i+1]
            var1Mean += r / cnt1
        for i = 0 to cnt1 - 1
            r = src[i] - src[i+1]
            var1Sum += math.pow(r - var1Mean, 2)
        v1 = var1Sum / math.max(cnt1 - 1, 1)
        for i = 0 to cntQ - 1
            r = src[i] - src[i+q]
            varQMean += r / cntQ
        for i = 0 to cntQ - 1
            r = src[i] - src[i+q]
            varQSum += math.pow(r - varQMean, 2)
        vq = varQSum / math.max(cntQ - 1, 1)
        result := (v1 > 0) ? vq / (q * v1) : float(na)
    result

[ouMuRaw, ouThetaRaw, ouHLRaw, ouSigmaRaw] = f_ou(srcP, ouLen_eff)
ouMu    = useL1 ? ouMuRaw    : float(na)
ouTheta = useL1 ? ouThetaRaw : float(na)
ouHL    = useL1 ? ouHLRaw    : float(na)
ouSigma = useL1 ? ouSigmaRaw : float(na)
hurstH    = useL1 ? f_hurst(srcP, ouLen_eff) : float(na)
adfStat   = (useL1 and useADF) ? f_adf(srcP, ouLen_eff) : float(na)
vr2       = (useL1 and useVR)  ? f_vr(srcP, ouLen_eff, 2)  : float(na)
vr4       = (useL1 and useVR)  ? f_vr(srcP, ouLen_eff, 4)  : float(na)
vr8       = (useL1 and useVR)  ? f_vr(srcP, ouLen_eff, 8)  : float(na)

ouZ = (useL1 and not na(ouMu) and not na(ouSigma) and ouSigma > 0) ? (srcP - ouMu) / ouSigma : float(na)

hlOK    = not na(ouHL) and ouHL > 0 and ouHL <= hlMax
hurstOK = not na(hurstH) and hurstH < hurstMax_eff
adfOK   = not useADF or (not na(adfStat) and adfStat < -2.86)
vrOK    = not useVR or (not na(vr4) and vr4 < 1.0)
windowGapRaw = f_windowHasGap(ouLen_eff)
gapInWindow = useSessionGuards and gapInvalidatesL1 and windowGapRaw
l1Valid = useL1 and hlOK and hurstOK and adfOK and vrOK and not gapInWindow

l1Sig = (l1Valid and not na(ouZ)) ? (ouZ > zScalp_eff ? -1 : ouZ < -zScalp_eff ? 1 : 0) : 0
l1Str = (l1Valid and not na(ouZ)) ? math.min(math.abs(ouZ) / zSwing_eff, 1.5) : 0.0

vrHorizonPref = 0
if useVR
    minVR = math.min(math.min(nz(vr2, 99), nz(vr4, 99)), nz(vr8, 99))
    if minVR < 0.95
        vrHorizonPref := minVR == nz(vr2, 99) ? 1 : minVR == nz(vr4, 99) ? 2 : 3

// ============================================================================
// L2: VOLATILITY REGIME
// ============================================================================
[plusDI, minusDI, adxReal] = ta.dmi(14, 14)
trueAdx = adxReal

vixRoc = (useL2 and not na(vix)) ? ((vix - vix[20]) / vix[20]) * 100 : float(na)

logRet = math.log(srcP / srcP[1])
barsPerYear = tradingDaysYr * (sessionHrs * 60.0 / math.max(barMinutes, 1e-9))
realVolRaw = ta.stdev(logRet, rvWin) * math.sqrt(barsPerYear) * 100
realVol = useL2 ? realVolRaw : float(na)
vrp = (useL2 and not na(vix) and not na(realVol)) ? vix - realVol : float(na)

regime = 0
if useL2 and not na(vix) and not na(trueAdx)
    isTrending = trueAdx > adxTrendThr
    isSpike    = not na(vixRoc) and math.abs(vixRoc) > 20
    if vix < vixLo
        regime := isTrending ? 2 : 1
    else if vix < vixHi
        regime := isTrending ? 4 : 3
    else
        regime := isSpike or isTrending ? 6 : 5

l2Mult = regime == 3 ? 1.25 : regime == 5 ? 1.10 : regime == 1 ? 1.00 : regime == 4 ? 0.50 : regime == 2 ? 0.55 : regime == 6 ? 0.20 : 0.50

// ============================================================================
// L3: KALMAN BASIS
// ============================================================================
T_yr = daysToExp / 365.0
fairFut = (useL3 and not na(spotPx)) ? spotPx * math.exp((rfRate / 100) * T_yr) : float(na)
actualBasis = (useL3 and not na(futPx) and not na(spotPx)) ? futPx - spotPx : float(na)
fairBasis   = (useL3 and not na(fairFut) and not na(spotPx)) ? fairFut - spotPx : float(na)
basisDev    = (useL3 and not na(actualBasis) and not na(fairBasis)) ? actualBasis - fairBasis : float(na)

spotRet = useL3 and not na(spotPx) and not na(spotPx[1]) ? math.log(spotPx / spotPx[1]) : 0.0
futRet  = useL3 and not na(futPx) and not na(futPx[1])  ? math.log(futPx  / futPx[1])  : 0.0

var float kBeta = 1.0
var float kP    = 1.0
if useSessionGuards and isSessionStart
    kBeta := 1.0
    kP    := 1.0
if useL3 and not na(spotRet) and not na(futRet) and spotRet != 0 and not isSessionStart
    kP := kP + kalmanQ
    pred = kBeta * spotRet
    innov = futRet - pred
    S = spotRet * kP * spotRet + kalmanR
    K = kP * spotRet / math.max(S, 1e-10)
    kBeta := kBeta + K * innov
    kP    := (1 - K * spotRet) * kP

basisResidual = useL3 and not na(basisDev) ? basisDev - kBeta * (spotPx - spotPx[1]) : basisDev

basisMeanRaw = ta.sma(basisResidual, 50)
basisStdRaw  = ta.stdev(basisResidual, 50)
basisMean = useL3 ? basisMeanRaw : float(na)
basisStd  = useL3 ? basisStdRaw  : float(na)
basisZ    = (useL3 and not na(basisStd) and basisStd > 0) ? (basisResidual - basisMean) / basisStd : float(na)

l3Sig = (useL3 and not na(basisZ)) ? (basisZ > basisZThr ? -1 : basisZ < -basisZThr ? 1 : 0) : 0
l3Str = (useL3 and not na(basisZ)) ? math.min(math.abs(basisZ) / basisZThr, 1.5) : 0.0

// ============================================================================
// L4: OPTIONS
// ============================================================================
atmStr = (useL4 and not na(atmCEpx) and not na(atmPEpx)) ? atmCEpx + atmPEpx : float(na)
T_optYr = daysToExp / 365.0
atmIV = (useL4 and not na(atmStr) and close > 0 and T_optYr > 0) ? (atmStr / (0.8 * close * math.sqrt(T_optYr))) * 100 : float(na)

ivVixSpread = (useL4 and not na(atmIV) and not na(vix)) ? atmIV - vix : float(na)

skewRatio = (useL4 and not na(otmPEpx) and not na(otmCEpx) and otmCEpx > 0) ? otmPEpx / otmCEpx : float(na)
skewMeanRaw = ta.sma(skewRatio, 50)
skewStdRaw  = ta.stdev(skewRatio, 50)
skewMean  = useL4 ? skewMeanRaw : float(na)
skewStd   = useL4 ? skewStdRaw  : float(na)
skewZ     = (useL4 and not na(skewStd) and skewStd > 0) ? (skewRatio - skewMean) / skewStd : float(na)

l4Sig = (useL4 and not na(skewZ)) ? (skewZ > skewZThr ? 1 : skewZ < -skewZThr ? -1 : 0) : 0
l4Str = (useL4 and not na(skewZ)) ? math.min(math.abs(skewZ) / skewZThr, 1.5) : 0.0

// ============================================================================
// L5: MICROSTRUCTURE
// ============================================================================
vwapVal = ta.vwap(hlc3)
vwapDev = close - vwapVal
vwapDevMean = ta.sma(vwapDev, vwapDevWin)
vwapDevStd  = ta.stdev(vwapDev, vwapDevWin)
vwapZ = (useL5 and vwapDevStd > 0) ? (vwapDev - vwapDevMean) / vwapDevStd : float(na)

var float anchorPVSum  = 0.0
var float anchorVolSum = 0.0
var float anchorSqSum  = 0.0
var int   anchorBars   = 0
if useAnchorVWAP and useSessionGuards and isSessionStart
    anchorPVSum  := 0.0
    anchorVolSum := 0.0
    anchorSqSum  := 0.0
    anchorBars   := 0

priceForVwap = hlc3
volForVwap   = math.max(volume, 0.0)
if useAnchorVWAP and useL5
    anchorPVSum  += priceForVwap * volForVwap
    anchorVolSum += volForVwap
    anchorBars   += 1
anchorVwap = (useAnchorVWAP and anchorVolSum > 0) ? anchorPVSum / anchorVolSum : float(na)

if useAnchorVWAP and useL5 and not na(anchorVwap) and volForVwap > 0
    dev = priceForVwap - anchorVwap
    anchorSqSum += dev * dev * volForVwap
anchorVwapStd = (useAnchorVWAP and anchorVolSum > 0 and anchorBars > 2) ? math.sqrt(anchorSqSum / anchorVolSum) : float(na)
anchorVwapZ   = (useAnchorVWAP and not na(anchorVwapStd) and anchorVwapStd > 0) ? (close - anchorVwap) / anchorVwapStd : float(na)

volMA = ta.sma(volume, 20)
volSpike = useL5 and volume > volMA * volMult

priceChg = close - close[1]
chgStd = ta.stdev(priceChg, 20)
buyFrac = chgStd > 0 ? 1 / (1 + math.exp(-1.7 * priceChg / chgStd)) : 0.5
buyVol = volume * buyFrac
sellVol = volume * (1 - buyFrac)
vpinNum = math.sum(math.abs(buyVol - sellVol), vpinBuckets)
vpinDen = math.sum(volume, vpinBuckets)
vpin = useL5 and vpinDen > 0 ? vpinNum / vpinDen : float(na)
vpinSmaRaw = ta.sma(nz(vpin), 100)
vpinStdRaw = ta.stdev(nz(vpin), 100)
vpinZ = useL5 and not na(vpin) ? (vpin - vpinSmaRaw) / math.max(vpinStdRaw, 1e-10) : float(na)

ofi = useL5 ? math.sum(buyVol - sellVol, 10) / math.max(math.sum(volume, 10), 1) : float(na)

l5SigRoll = (useL5 and not na(vwapZ)) ? (vwapZ > vwapZThr ? -1 : vwapZ < -vwapZThr ? 1 : 0) : 0
l5StrRoll = (useL5 and not na(vwapZ)) ? math.min(math.abs(vwapZ) / vwapZThr, 1.5) : 0.0

l5SigAnchor = (useL5 and useAnchorVWAP and not na(anchorVwapZ)) ? (anchorVwapZ > anchorVwapZThr ? -1 : anchorVwapZ < -anchorVwapZThr ? 1 : 0) : 0
l5StrAnchor = (useL5 and useAnchorVWAP and not na(anchorVwapZ)) ? math.min(math.abs(anchorVwapZ) / anchorVwapZThr, 1.5) : 0.0

anchorAvailable = useAnchorVWAP and not na(anchorVwapZ)
l5SigCombined = 0
l5StrCombined = 0.0
if anchorAvailable
    if l5SigAnchor == l5SigRoll
        l5SigCombined := l5SigAnchor
        l5StrCombined := anchorVwapWeight_eff * l5StrAnchor + (1.0 - anchorVwapWeight_eff) * l5StrRoll
    else if l5SigAnchor != 0 and l5SigRoll == 0
        l5SigCombined := l5SigAnchor
        l5StrCombined := l5StrAnchor * anchorVwapWeight_eff
    else if l5SigRoll != 0 and l5SigAnchor == 0
        l5SigCombined := l5SigRoll
        l5StrCombined := l5StrRoll * (1.0 - anchorVwapWeight_eff)
else
    l5SigCombined := l5SigRoll
    l5StrCombined := l5StrRoll

l5Sig = l5SigCombined
ofiAligns = not na(ofi) and ((l5Sig > 0 and ofi < 0) or (l5Sig < 0 and ofi > 0))
vpinPenalty = (not na(vpinZ) and vpinZ > 2.0) ? 0.7 : 1.0
l5Str = useL5 ? l5StrCombined * (volSpike ? 1.25 : 1.0) * (ofiAligns ? 1.15 : 1.0) * vpinPenalty : 0.0

// ============================================================================
// L6: GEX
// ============================================================================
f_bsGamma(S, K, T, sigma) =>
    if sigma <= 0 or T <= 0 or S <= 0
        float(na)
    else
        d1 = (math.log(S / K) + (0.5 * sigma * sigma) * T) / (sigma * math.sqrt(T))
        pdf = math.exp(-0.5 * d1 * d1) / math.sqrt(2 * math.pi)
        pdf / (S * sigma * math.sqrt(T))

atmStrike = math.round(close / strikeStep) * strikeStep
sigmaUse = not na(atmIV) ? atmIV / 100 : not na(vix) ? vix / 100 : 0.15
T_gex = daysToExp / 365.0

// Net OI per strike (CE - PE).
netOI_M2 = nz(oiM2_ce, 0.0) - nz(oiM2_pe, 0.0)
netOI_M1 = nz(oiM1_ce, 0.0) - nz(oiM1_pe, 0.0)
netOI_0  = nz(oi0_ce,  0.0) - nz(oi0_pe,  0.0)
netOI_P1 = nz(oiP1_ce, 0.0) - nz(oiP1_pe, 0.0)
netOI_P2 = nz(oiP2_ce, 0.0) - nz(oiP2_pe, 0.0)

// Volume weight per strike.
totVol_M2 = nz(volM2_ce, 0.0) + nz(volM2_pe, 0.0)
totVol_M1 = nz(volM1_ce, 0.0) + nz(volM1_pe, 0.0)
totVol_0  = nz(vol0_ce,  0.0) + nz(vol0_pe,  0.0)
totVol_P1 = nz(volP1_ce, 0.0) + nz(volP1_pe, 0.0)
totVol_P2 = nz(volP2_ce, 0.0) + nz(volP2_pe, 0.0)

avgVol_M2 = ta.sma(totVol_M2, 20)
avgVol_M1 = ta.sma(totVol_M1, 20)
avgVol_0  = ta.sma(totVol_0,  20)
avgVol_P1 = ta.sma(totVol_P1, 20)
avgVol_P2 = ta.sma(totVol_P2, 20)

f_volWt(curVol, avgVol) =>
    if not useGexFlow or na(curVol) or na(avgVol) or avgVol <= 0
        1.0
    else
        math.min(math.max(curVol / avgVol, 0.5), 2.0)  // clamp [0.5, 2.0]

vw_M2 = f_volWt(totVol_M2, avgVol_M2)
vw_M1 = f_volWt(totVol_M1, avgVol_M1)
vw_0  = f_volWt(totVol_0,  avgVol_0)
vw_P1 = f_volWt(totVol_P1, avgVol_P1)
vw_P2 = f_volWt(totVol_P2, avgVol_P2)

// Signed gamma exposure per strike
gM2 = useL6 ? netOI_M2 * f_bsGamma(close, atmStrike - 2*strikeStep, T_gex, sigmaUse) * vw_M2 : 0.0
gM1 = useL6 ? netOI_M1 * f_bsGamma(close, atmStrike - 1*strikeStep, T_gex, sigmaUse) * vw_M1 : 0.0
g0  = useL6 ? netOI_0  * f_bsGamma(close, atmStrike,                 T_gex, sigmaUse) * vw_0  : 0.0
gP1 = useL6 ? netOI_P1 * f_bsGamma(close, atmStrike + 1*strikeStep, T_gex, sigmaUse) * vw_P1 : 0.0
gP2 = useL6 ? netOI_P2 * f_bsGamma(close, atmStrike + 2*strikeStep, T_gex, sigmaUse) * vw_P2 : 0.0

totalGex = gM2 + gM1 + g0 + gP1 + gP2

// Gamma wall = strike with largest |signed GEX|.
absM2 = math.abs(gM2)
absM1 = math.abs(gM1)
abs0  = math.abs(g0)
absP1 = math.abs(gP1)
absP2 = math.abs(gP2)
maxAbsGex = math.max(math.max(math.max(math.max(absM2, absM1), abs0), absP1), absP2)

gammaWall = useL6 and maxAbsGex > 0 ? (maxAbsGex == abs0 ? atmStrike : maxAbsGex == absM1 ? atmStrike - strikeStep : maxAbsGex == absP1 ? atmStrike + strikeStep : maxAbsGex == absM2 ? atmStrike - 2*strikeStep : maxAbsGex == absP2 ? atmStrike + 2*strikeStep : atmStrike) : float(na)
wallIsCallHeavy = useL6 and maxAbsGex > 0 ? (maxAbsGex == abs0 ? g0 > 0 : maxAbsGex == absM1 ? gM1 > 0 : maxAbsGex == absP1 ? gP1 > 0 : maxAbsGex == absM2 ? gM2 > 0 : maxAbsGex == absP2 ? gP2 > 0 : false) : false

gexMRBias = 0
if useL6 and not na(gammaWall) and maxAbsGex > 0
    if wallIsCallHeavy and gammaWall > close
        gexMRBias := -1
    else if not wallIsCallHeavy and gammaWall < close
        gexMRBias := 1
gexStr = (useL6 and maxAbsGex > 0 and not na(gammaWall) and gexMRBias != 0) ? math.min(math.abs(close - gammaWall) / atrSafe, 1.5) : 0.0

// ============================================================================
// L7: DISPERSION
// ============================================================================
idxRet = math.log(srcP / srcP[1])
w1Ret = useL7 and not na(w1Px) and not na(w1Px[1]) ? math.log(w1Px / w1Px[1]) : 0.0
w2Ret = useL7 and not na(w2Px) and not na(w2Px[1]) ? math.log(w2Px / w2Px[1]) : 0.0
w3Ret = useL7 and not na(w3Px) and not na(w3Px[1]) ? math.log(w3Px / w3Px[1]) : 0.0
w4Ret = useL7 and not na(w4Px) and not na(w4Px[1]) ? math.log(w4Px / w4Px[1]) : 0.0
w5Ret = useL7 and not na(w5Px) and not na(w5Px[1]) ? math.log(w5Px / w5Px[1]) : 0.0

corr1Raw = ta.correlation(idxRet, w1Ret, corrWin)
corr2Raw = ta.correlation(idxRet, w2Ret, corrWin)
corr3Raw = ta.correlation(idxRet, w3Ret, corrWin)
corr4Raw = ta.correlation(idxRet, w4Ret, corrWin)
corr5Raw = ta.correlation(idxRet, w5Ret, corrWin)
corr1 = useL7 ? corr1Raw : float(na)
corr2 = useL7 ? corr2Raw : float(na)
corr3 = useL7 ? corr3Raw : float(na)
corr4 = useL7 ? corr4Raw : float(na)
corr5 = useL7 ? corr5Raw : float(na)

avgCorr = useL7 ? (nz(corr1) + nz(corr2) + nz(corr3) + nz(corr4) + nz(corr5)) / 5 : float(na)
corrMeanRaw = ta.sma(avgCorr, 100)
corrStdRaw  = ta.stdev(avgCorr, 100)
corrMean = useL7 ? corrMeanRaw : float(na)
corrStd  = useL7 ? corrStdRaw  : float(na)
corrZ    = (useL7 and not na(corrStd) and corrStd > 0) ? (avgCorr - corrMean) / corrStd : float(na)

l7Mult = (useL7 and not na(corrZ)) ? (avgCorr > 0.80 ? 1.15 : avgCorr < 0.40 ? 0.75 : 1.0) : 1.0

// ============================================================================
// L7b: RESIDUAL DISPERSION
// ============================================================================
f_residZ(stockRet, idxRet, win) =>
    meanS = ta.sma(stockRet, win)
    meanI = ta.sma(idxRet, win)
    meanSI = ta.sma(stockRet * idxRet, win)
    sCov = meanSI - meanS * meanI
    sStd = ta.stdev(idxRet, win)
    sVar = sStd * sStd
    beta = sVar > 0 ? sCov / sVar : 1.0
    resid = stockRet - beta * idxRet
    rMean = ta.sma(resid, win)
    rStd  = ta.stdev(resid, win)
    rStd > 0 ? (resid - rMean) / rStd : float(na)

residZ1Raw = f_residZ(w1Ret, idxRet, residWin)
residZ2Raw = f_residZ(w2Ret, idxRet, residWin)
residZ3Raw = f_residZ(w3Ret, idxRet, residWin)
residZ4Raw = f_residZ(w4Ret, idxRet, residWin)
residZ5Raw = f_residZ(w5Ret, idxRet, residWin)
residZ1 = (useResidualDisp and useL7) ? residZ1Raw : float(na)
residZ2 = (useResidualDisp and useL7) ? residZ2Raw : float(na)
residZ3 = (useResidualDisp and useL7) ? residZ3Raw : float(na)
residZ4 = (useResidualDisp and useL7) ? residZ4Raw : float(na)
residZ5 = (useResidualDisp and useL7) ? residZ5Raw : float(na)

posCount = (not na(residZ1) and residZ1 >  residSigmaThr ? 1 : 0) + (not na(residZ2) and residZ2 >  residSigmaThr ? 1 : 0) + (not na(residZ3) and residZ3 >  residSigmaThr ? 1 : 0) + (not na(residZ4) and residZ4 >  residSigmaThr ? 1 : 0) + (not na(residZ5) and residZ5 >  residSigmaThr ? 1 : 0)
negCount = (not na(residZ1) and residZ1 < -residSigmaThr ? 1 : 0) + (not na(residZ2) and residZ2 < -residSigmaThr ? 1 : 0) + (not na(residZ3) and residZ3 < -residSigmaThr ? 1 : 0) + (not na(residZ4) and residZ4 < -residSigmaThr ? 1 : 0) + (not na(residZ5) and residZ5 < -residSigmaThr ? 1 : 0)

l7bSig = 0
if useResidualDisp and useL7
    if posCount >= residMinAgree and negCount < residMinAgree
        l7bSig := 1
    else if negCount >= residMinAgree and posCount < residMinAgree
        l7bSig := -1
agreeCount = math.max(posCount, negCount)
l7bStr = (useResidualDisp and useL7 and l7bSig != 0) ? math.min((agreeCount - residMinAgree + 1) * 0.4 + 0.6, 1.5) : 0.0

avgResidMag = useResidualDisp ? (math.abs(nz(residZ1)) + math.abs(nz(residZ2)) + math.abs(nz(residZ3)) + math.abs(nz(residZ4)) + math.abs(nz(residZ5))) / 5 : float(na)

// ============================================================================
// L6b: PCR
// ============================================================================
pcrChg = (usePCR and not na(pcrVal) and not na(pcrVal[1])) ? pcrVal - pcrVal[1] : float(na)
pcrSig = 0
pcrStr = 0.0
if usePCR and not na(pcrVal) and not na(pcrChg)
    if pcrVal > pcrHighThr and pcrChg > 0
        pcrSig := 1
        pcrStr := math.min((pcrVal - pcrHighThr) / 0.2, 1.5)
    else if pcrVal < pcrLowThr and pcrChg > 0
        pcrSig := -1
        pcrStr := math.min((pcrLowThr - pcrVal) / 0.2, 1.5)

// ============================================================================
// L9: CROSS-ASSET STRESS
// ============================================================================
usdinrRet = (useL9_eff and not na(usdinrPx) and not na(usdinrPx[1])) ? math.log(usdinrPx / usdinrPx[1]) : 0.0
dxyRet    = (useL9_eff and not na(dxyPx)    and not na(dxyPx[1]))    ? math.log(dxyPx    / dxyPx[1])    : 0.0
crudeRet  = (useL9_eff and not na(crudePx)  and not na(crudePx[1]))  ? math.log(crudePx  / crudePx[1])  : 0.0

usdinrStd = ta.stdev(usdinrRet, crossStressWin)
dxyStd    = ta.stdev(dxyRet,    crossStressWin)
crudeStd  = ta.stdev(crudeRet,  crossStressWin)

usdinrZ = (useL9_eff and usdinrStd > 0) ? math.abs(usdinrRet) / usdinrStd : 0.0
dxyZ    = (useL9_eff and dxyStd > 0)    ? math.abs(dxyRet)    / dxyStd    : 0.0
crudeZ  = (useL9_eff and crudeStd > 0)  ? math.abs(crudeRet)  / crudeStd  : 0.0

crossStress = useL9_eff ? usdinrZ + dxyZ + crudeZ : 0.0
crossFeedsAvailable = (useL9_eff and not na(usdinrPx) ? 1 : 0) + (useL9_eff and not na(dxyPx) ? 1 : 0) + (useL9_eff and not na(crudePx) ? 1 : 0)
crossMult = (useL9_eff and crossFeedsAvailable >= 2) ? (crossStress > crossHighThr ? crossHighMult : crossStress < 1.0 ? crossLowMult : 1.0) : 1.0

// ============================================================================
// EXPIRY-DAY PINNING
// ============================================================================
dayMap = expiryDayName == "Monday" ? dayofweek.monday : expiryDayName == "Tuesday" ? dayofweek.tuesday : expiryDayName == "Wednesday" ? dayofweek.wednesday : expiryDayName == "Thursday" ? dayofweek.thursday : dayofweek.friday
exDow = dayofweek(time, syminfo.timezone)
isExpiryDay  = useExpiryMode and exDow == dayMap
isPinningTime = isExpiryDay and exHr >= expiryAfterHour

var float expiryPinStrike = float(na)
if useExpiryMode and isExpiryDay and isSessionStart
    expiryPinStrike := math.round(close / strikeStep) * strikeStep
if not isExpiryDay
    expiryPinStrike := float(na)

expiryPinDir = (isPinningTime and not na(expiryPinStrike)) ? (expiryPinStrike > close ? 1 : expiryPinStrike < close ? -1 : 0) : 0
expiryDistAtr = (isPinningTime and not na(expiryPinStrike)) ? math.abs(close - expiryPinStrike) / atrSafe : 0.0

// ============================================================================
// L8: FUSION + TCA + HORIZON
// ============================================================================
ww1 = 0.28
ww3 = 0.18
ww4 = 0.12
ww5 = 0.22
ww6 = 0.10
ww6p= pcrWeight
ww7 = 0.10

l6Sig = usePCR ? pcrSig : gexMRBias
l6Str = usePCR ? pcrStr : gexStr
l6W   = usePCR ? ww6p : ww6

rawComp = (useL1 ? l1Sig * l1Str * ww1 : 0.0) + (useL3 ? l3Sig * l3Str * ww3 : 0.0) + (useL4 ? l4Sig * l4Str * ww4 : 0.0) + (useL5 ? l5Sig * l5Str * ww5 : 0.0) + (l6Sig * l6Str * l6W) + (useResidualDisp ? l7bSig * l7bStr * residWeight : 0.0)

vrpMult = 1.0
if useVrpMult and not na(vrp)
    if vrp > vrpHighThr
        vrpMult := vrpHighMult
    else if vrp < vrpLowThr
        vrpMult := vrpLowMult

provDir = rawComp > 0 ? 1 : rawComp < 0 ? -1 : 0
expiryMult = 1.0
if useExpiryMode and isPinningTime and expiryPinDir != 0 and provDir != 0
    expiryMult := (provDir == expiryPinDir) ? expiryMrBoost : expiryMrPenalty

combinedMult = (useL2 ? l2Mult : 1.0) * (useL7 ? l7Mult : 1.0) * vrpMult * crossMult * expiryMult
clampedMult  = math.max(multClampLo, math.min(combinedMult, multClampHi))

composite = rawComp * clampedMult
compAbs = math.abs(composite)

domDir = composite > 0 ? 1 : composite < 0 ? -1 : 0

conf = (l1Sig == domDir and l1Sig != 0 ? 1 : 0) + (l3Sig == domDir and l3Sig != 0 ? 1 : 0) + (l4Sig == domDir and l4Sig != 0 ? 1 : 0) + (l5Sig == domDir and l5Sig != 0 ? 1 : 0) + (l6Sig == domDir and l6Sig != 0 ? 1 : 0) + (l7bSig == domDir and l7bSig != 0 ? 1 : 0)

strictAgree = (not useL1 or l1Sig == domDir or l1Sig == 0) and (not useL3 or l3Sig == domDir or l3Sig == 0) and (not useL4 or l4Sig == domDir or l4Sig == 0) and (not useL5 or l5Sig == domDir or l5Sig == 0) and domDir != 0

expectedMove = (not na(ouMu)) ? math.abs(close - ouMu) : float(na)
expectedMoveBps = (not na(expectedMove) and close > 0) ? (expectedMove / close) * 10000 : float(na)

tentHorizon = 0
if fusion == "Weighted Composite"
    if compAbs >= threshSess_eff and (na(ouHL) or ouHL > 20) and (not useVR or nz(vr8, 99) < 0.98)
        tentHorizon := 3
    else if compAbs >= threshSwing_eff and (na(ouHL) or ouHL > 10) and (not useVR or nz(vr4, 99) < 0.98)
        tentHorizon := 2
    else if compAbs >= threshScalp_eff and (not useVR or nz(vr2, 99) < 0.98)
        tentHorizon := 1
else if fusion == "Confluence Count"
    if conf >= minConf
        tentHorizon := conf >= 4 ? 3 : conf >= 3 ? 2 : 1
else
    if strictAgree
        tentHorizon := 3

tcaMultByHorizon = tentHorizon == 1 ? 1.0 : tentHorizon == 2 ? 1.5 : tentHorizon == 3 ? 2.0 : 1.0
tcaRequiredBps = tcaBpsRound * tcaMultByHorizon * tcaSharpeMult
tcaPass = not useTCA or (not na(expectedMoveBps) and expectedMoveBps > tcaRequiredBps)

horizon = tcaPass ? tentHorizon : 0

// ============================================================================
// TIME-OF-DAY FILTER + HIGH-TREND BLOCK
// ============================================================================
minFromOpen  = (exHr - sessOpenHr) * 60 + (exMn - sessOpenMn)
minFromClose = (sessCloseHr - exHr) * 60 + (sessCloseMn - exMn)
inOpenBlk  = useTimeFilter and minFromOpen  < avoidOpenMin
inCloseBlk = useTimeFilter and minFromClose < avoidCloseMin
inLunchBlk = useTimeFilter and avoidLunch and exHr == lunchHr
inSessionStartBlk = useSessionGuards and barsSinceSession < effectiveSkipBars
timeOK = not (inOpenBlk or inCloseBlk or inLunchBlk or inSessionStartBlk)

highTrendBlocked = useHighTrendBlock and regime == 6

finalDir = (timeOK and horizon > 0 and not highTrendBlocked) ? domDir : 0

var int lastSigBar = na
var int lastSigDir = 0
var int lastSigHorizon = 0
var float lastSigEntry = na
if finalDir != 0
    lastSigBar := bar_index
    lastSigDir := finalDir
    lastSigHorizon := horizon
    lastSigEntry := close
barsSinceSignal = not na(lastSigBar) ? bar_index - lastSigBar : -1

// ============================================================================
// LEVELS
// ============================================================================
entryPx = close
slLong  = entryPx - atrVal * slAtrMult
slShort = entryPx + atrVal * slAtrMult
tgtLong  = not na(ouMu) ? math.max(ouMu, entryPx + atrVal * tpAtrMult) : entryPx + atrVal * tpAtrMult
tgtShort = not na(ouMu) ? math.min(ouMu, entryPx - atrVal * tpAtrMult) : entryPx - atrVal * tpAtrMult

useGexTarget = useL6 and not na(gammaWall)
finalTgtLong  = useGexTarget and gammaWall > close and gammaWall < tgtLong ?  gammaWall : tgtLong
finalTgtShort = useGexTarget and gammaWall < close and gammaWall > tgtShort ? gammaWall : tgtShort

// ============================================================================
// STRIKE & GREEKS
// ============================================================================
f_invN(p) =>
    p2 = p < 0.5 ? p : 1 - p
    t = math.sqrt(-2 * math.log(p2))
    num = 2.515517 + 0.802853 * t + 0.010328 * t * t
    den = 1 + 1.432788 * t + 0.189269 * t * t + 0.001308 * t * t * t
    val = t - num / den
    p < 0.5 ? -val : val

T_strike = math.max(daysToExp, 1) / 365.0
oneSD = close * sigmaUse * math.sqrt(T_strike)
deltaTgt = horizon == 1 ? deltaScalp : horizon == 2 ? deltaSwing : horizon == 3 ? deltaSess : 0.5
d1 = f_invN(deltaTgt)
strikeOffset = d1 * oneSD

recoStrike = finalDir > 0 ? math.round((close - strikeOffset) / strikeStep) * strikeStep : finalDir < 0 ? math.round((close + strikeOffset) / strikeStep) * strikeStep : atmStrike
recoSide = finalDir > 0 ? "CE" : finalDir < 0 ? "PE" : "-"

f_bsCallDelta(S, K, T, sigma) =>
    if sigma <= 0 or T <= 0 or S <= 0
        float(na)
    else
        d1c = (math.log(S / K) + (0.5 * sigma * sigma) * T) / (sigma * math.sqrt(T))
        1 / (1 + math.exp(-1.7 * d1c))

f_bsTheta(S, K, T, sigma) =>
    if sigma <= 0 or T <= 0 or S <= 0
        float(na)
    else
        d1c = (math.log(S / K) + (0.5 * sigma * sigma) * T) / (sigma * math.sqrt(T))
        pdf = math.exp(-0.5 * d1c * d1c) / math.sqrt(2 * math.pi)
        -(S * pdf * sigma) / (2 * math.sqrt(T))

f_bsVega(S, K, T, sigma) =>
    if sigma <= 0 or T <= 0 or S <= 0
        float(na)
    else
        d1c = (math.log(S / K) + (0.5 * sigma * sigma) * T) / (sigma * math.sqrt(T))
        pdf = math.exp(-0.5 * d1c * d1c) / math.sqrt(2 * math.pi)
        S * pdf * math.sqrt(T) / 100

recoDelta = finalDir != 0 ? f_bsCallDelta(close, recoStrike, T_strike, sigmaUse) : float(na)
recoGamma = finalDir != 0 ? f_bsGamma(close, recoStrike, T_strike, sigmaUse) : float(na)
recoTheta = finalDir != 0 ? f_bsTheta(close, recoStrike, T_strike, sigmaUse) : float(na)
recoVega  = finalDir != 0 ? f_bsVega(close, recoStrike, T_strike, sigmaUse) : float(na)
recoThetaHr = not na(recoTheta) ? recoTheta / (tradingDaysYr * sessionHrs) : float(na)

recoDeltaDisplay = finalDir < 0 and not na(recoDelta) ? math.abs(recoDelta - 1) : recoDelta

sliceSchedule = horizon == 3 ? "40% now -> 30% +5b -> 30% +10b" : horizon == 2 ? "60% now -> 40% +3b" : horizon == 1 ? "100% now" : "-"

// ============================================================================
// TELEMETRY MODULE
// ============================================================================
var array<int>   tEntryBar    = array.new<int>()
var array<float> tEntryPx     = array.new<float>()
var array<int>   tDir         = array.new<int>()
var array<int>   tHorizon     = array.new<int>()
var array<float> tCompAbs     = array.new<float>()
var array<float> tOuMu        = array.new<float>()
var array<float> tSL          = array.new<float>()
var array<float> tAtrAtEntry  = array.new<float>()
var array<int>   tStatus      = array.new<int>()
var array<int>   tBarsHeld    = array.new<int>()
var array<int>   tDomLayer    = array.new<int>()

f_recordSignal(dir, hz, compMag, entryPrice, target, slPrice, atrEntry, domLayer) =>
    if array.size(tEntryBar) >= maxSignals
        array.shift(tEntryBar)
        array.shift(tEntryPx)
        array.shift(tDir)
        array.shift(tHorizon)
        array.shift(tCompAbs)
        array.shift(tOuMu)
        array.shift(tSL)
        array.shift(tAtrAtEntry)
        array.shift(tStatus)
        array.shift(tBarsHeld)
        array.shift(tDomLayer)
    array.push(tEntryBar,   bar_index)
    array.push(tEntryPx,    entryPrice)
    array.push(tDir,        dir)
    array.push(tHorizon,    hz)
    array.push(tCompAbs,    compMag)
    array.push(tOuMu,       target)
    array.push(tSL,         slPrice)
    array.push(tAtrAtEntry, atrEntry)
    array.push(tStatus,     0)
    array.push(tBarsHeld,   0)
    array.push(tDomLayer,   domLayer)

f_resolveOpenSignals() =>
    n = array.size(tStatus)
    if n > 0
        for i = 0 to n - 1
            if array.get(tStatus, i) == 0
                entryBar = array.get(tEntryBar, i)
                heldBars = bar_index - entryBar
                if heldBars >= 1
                    array.set(tBarsHeld, i, heldBars)
                    dir      = array.get(tDir, i)
                    hz       = array.get(tHorizon, i)
                    muTgt    = array.get(tOuMu, i)
                    slPx     = array.get(tSL, i)
                    atrE     = array.get(tAtrAtEntry, i)
                    touchTol = atrE * meanTouchAtr
                    maxBars  = hz == 1 ? scalpResWin_eff : hz == 2 ? swingResWin_eff : sessResWin_eff
                    meanTouched = dir > 0 ? high >= muTgt - touchTol : low  <= muTgt + touchTol
                    slHit = dir > 0 ? low <= slPx : high >= slPx
                    if slHit
                        array.set(tStatus, i, 2)
                    else if meanTouched
                        array.set(tStatus, i, 1)
                    else if heldBars >= maxBars
                        array.set(tStatus, i, 3)

f_bucket(mag) =>
    mag < bucketLowMax ? 0 : mag < bucketMidMax ? 1 : 2

f_computeStats() =>
    wins     = array.new<int>(9, 0)
    losses   = array.new<int>(9, 0)
    expired  = array.new<int>(9, 0)
    openCnt  = array.new<int>(9, 0)
    barsSum  = array.new<int>(9, 0)
    n = array.size(tStatus)
    if n > 0
        for i = 0 to n - 1
            hz  = array.get(tHorizon, i) - 1
            buc = f_bucket(array.get(tCompAbs, i))
            idx = hz * 3 + buc
            st  = array.get(tStatus, i)
            if st == 1
                array.set(wins,    idx, array.get(wins,    idx) + 1)
                array.set(barsSum, idx, array.get(barsSum, idx) + array.get(tBarsHeld, i))
            else if st == 2
                array.set(losses,  idx, array.get(losses,  idx) + 1)
                array.set(barsSum, idx, array.get(barsSum, idx) + array.get(tBarsHeld, i))
            else if st == 3
                array.set(expired, idx, array.get(expired, idx) + 1)
            else
                array.set(openCnt, idx, array.get(openCnt, idx) + 1)
    [wins, losses, expired, openCnt, barsSum]

f_fmtCell(w, l) =>
    resolved = w + l
    string outTxt = "-"
    color outCol = color.new(#475569, 0)
    if resolved > 0
        hr = 100.0 * w / resolved
        outTxt := str.tostring(math.round(hr)) + "% (" + str.tostring(resolved) + ")"
        outCol := hr >= 60 ? color.new(#22c55e, 0) : hr >= 45 ? color.new(#facc15, 0) : color.new(#ef4444, 0)
    [outTxt, outCol]

if useTelemetry
    if finalDir != 0 and horizon > 0
        muUse = not na(ouMu) ? ouMu : close
        slUse = finalDir > 0 ? slLong : slShort
        c1 = useL1 ? math.abs(l1Sig * l1Str * ww1) : 0.0
        c3 = useL3 ? math.abs(l3Sig * l3Str * ww3) : 0.0
        c4 = useL4 ? math.abs(l4Sig * l4Str * ww4) : 0.0
        c5 = useL5 ? math.abs(l5Sig * l5Str * ww5) : 0.0
        c6 = math.abs(l6Sig * l6Str * l6W)
        c7 = useResidualDisp ? math.abs(l7bSig * l7bStr * residWeight) : 0.0
        maxC = math.max(math.max(math.max(math.max(math.max(c1, c3), c4), c5), c6), c7)
        domLayer = recordLayerTag ? (maxC == 0.0 ? 0 : maxC == c1 ? 1 : maxC == c3 ? 3 : maxC == c4 ? 4 : maxC == c5 ? 5 : maxC == c6 ? 6 : 7) : 0
        f_recordSignal(finalDir, horizon, math.abs(composite), close, muUse, slUse, atrSafe, domLayer)
    f_resolveOpenSignals()

// ============================================================================
// PLOTS
// ============================================================================
plot(showOUBands and useL1 ? ouMu : na, "OU Mean (mu)", color=color.new(#fbbf24, 0), linewidth=2, style=plot.style_line)
upper1 = useL1 and not na(ouMu) and not na(ouSigma) ? ouMu + ouSigma * zScalp_eff   : na
lower1 = useL1 and not na(ouMu) and not na(ouSigma) ? ouMu - ouSigma * zScalp_eff   : na
upper2 = useL1 and not na(ouMu) and not na(ouSigma) ? ouMu + ouSigma * zSwing_eff   : na
lower2 = useL1 and not na(ouMu) and not na(ouSigma) ? ouMu - ouSigma * zSwing_eff   : na
upper3 = useL1 and not na(ouMu) and not na(ouSigma) ? ouMu + ouSigma * zSession_eff : na
lower3 = useL1 and not na(ouMu) and not na(ouSigma) ? ouMu - ouSigma * zSession_eff : na
pUpper3 = plot(showOUBands ? upper3 : na, "Session+", color=color.new(#ef4444, 30), linewidth=1)
pUpper2 = plot(showOUBands ? upper2 : na, "Swing+",   color=color.new(#f59e0b, 40), linewidth=1)
pUpper1 = plot(showOUBands ? upper1 : na, "Scalp+",   color=color.new(#06b6d4, 60), linewidth=1)
pLower1 = plot(showOUBands ? lower1 : na, "Scalp-",   color=color.new(#06b6d4, 60), linewidth=1)
pLower2 = plot(showOUBands ? lower2 : na, "Swing-",   color=color.new(#f59e0b, 40), linewidth=1)
pLower3 = plot(showOUBands ? lower3 : na, "Session-", color=color.new(#ef4444, 30), linewidth=1)

fill(pUpper3, pUpper2, color=color.new(#ef4444, 92), title="Session+ Zone")
fill(pUpper2, pUpper1, color=color.new(#f59e0b, 94), title="Swing+ Zone")
fill(pLower1, pLower2, color=color.new(#f59e0b, 94), title="Swing- Zone")
fill(pLower2, pLower3, color=color.new(#ef4444, 92), title="Session- Zone")

plot(useAnchorVWAP and not na(anchorVwap) ? anchorVwap : na, "Anchor VWAP", color=color.new(#a78bfa, 20), linewidth=2)
anchorUpper = (useAnchorVWAP and not na(anchorVwap) and not na(anchorVwapStd)) ? anchorVwap + anchorVwapZThr * anchorVwapStd : na
anchorLower = (useAnchorVWAP and not na(anchorVwap) and not na(anchorVwapStd)) ? anchorVwap - anchorVwapZThr * anchorVwapStd : na
plot(anchorUpper, "AnchorVWAP +sigma", color=color.new(#a78bfa, 60), linewidth=1, style=plot.style_circles)
plot(anchorLower, "AnchorVWAP -sigma", color=color.new(#a78bfa, 60), linewidth=1, style=plot.style_circles)

plot(showGexWall and useL6 and not na(gammaWall) ? gammaWall : na, "Gamma Wall", color=color.new(#d946ef, 0), linewidth=2, style=plot.style_circles)

plotshape(finalDir > 0 and horizon == 1, "Scalp Long",    shape.triangleup,   location.belowbar, color.new(#06b6d4, 0), size=size.tiny)
plotshape(finalDir > 0 and horizon == 2, "Swing Long",    shape.triangleup,   location.belowbar, color.new(#22c55e, 0), size=size.small)
plotshape(finalDir > 0 and horizon == 3, "Session Long",  shape.triangleup,   location.belowbar, color.new(#15803d, 0), size=size.normal)
plotshape(finalDir < 0 and horizon == 1, "Scalp Short",   shape.triangledown, location.abovebar, color.new(#f97316, 0), size=size.tiny)
plotshape(finalDir < 0 and horizon == 2, "Swing Short",   shape.triangledown, location.abovebar, color.new(#ef4444, 0), size=size.small)
plotshape(finalDir < 0 and horizon == 3, "Session Short", shape.triangledown, location.abovebar, color.new(#991b1b, 0), size=size.normal)

var line lnEntry = na
var line lnSL    = na
var line lnTP    = na
if showLevels and finalDir != 0 and barstate.islast
    line.delete(lnEntry)
    line.delete(lnSL)
    line.delete(lnTP)
    slUseLine = finalDir > 0 ? slLong : slShort
    tpUseLine = finalDir > 0 ? finalTgtLong : finalTgtShort
    lnEntry := line.new(bar_index - 5, entryPx, bar_index + 5, entryPx, color=color.white,  width=1, style=line.style_solid)
    lnSL    := line.new(bar_index - 5, slUseLine, bar_index + 5, slUseLine, color=color.red,    width=1, style=line.style_dashed)
    lnTP    := line.new(bar_index - 5, tpUseLine, bar_index + 5, tpUseLine, color=color.green,  width=1, style=line.style_dashed)

// ============================================================================
// COMPACT DASHBOARD
// ============================================================================
dashPosResolved = dashPos == "top_left" ? position.top_left : dashPos == "top_right" ? position.top_right : dashPos == "bottom_left" ? position.bottom_left : dashPos == "bottom_right" ? position.bottom_right : position.middle_right
var table dash = table.new(dashPosResolved, 2, 9, bgcolor=color.new(#0a0e1a, 0), border_width=1, border_color=color.new(#1a2238, 60), frame_color=color.new(#2a3458, 40), frame_width=1)

f_regLabel(r) => r == 1 ? "Low-Stable" : r == 2 ? "Low-Trend" : r == 3 ? "High-Stable" : r == 4 ? "High-Trend" : r == 5 ? "Ext-Stable" : r == 6 ? "Spike" : "-"
f_hzLabel(h) => h == 1 ? "SCALP" : h == 2 ? "SWING" : h == 3 ? "SESSION" : "-"
f_dirLabel(d) => d > 0 ? "LONG" : d < 0 ? "SHORT" : "NEUTRAL"

cAccent1 = #4a9eff
cGood    = #22c55e
cBad     = #ef4444
cWarn    = #facc15
cMuted   = #475569
cText    = #e2e8f0
cTextDim = #94a3b8
cHeader  = color.new(#0f172a, 0)
cSubHead = color.new(#1a2238, 40)

if showDash and barstate.islast
    titleTxt = "SMRE " + profileName + " | OU=" + str.tostring(ouLen_eff)
    table.cell(dash, 0, 0, titleTxt, text_color=cText, bgcolor=cHeader, text_size=size.small)
    table.merge_cells(dash, 0, 0, 1, 0)

    ouZColor = na(ouZ) ? cMuted : math.abs(ouZ) > zSession_eff ? cBad : math.abs(ouZ) > zSwing_eff ? cWarn : math.abs(ouZ) > zScalp_eff ? cGood : cTextDim
    ouZTxt = na(ouZ) ? "-" : str.tostring(ouZ, "0.00") + (na(ouHL) ? "" : " (HL " + str.tostring(ouHL, "0.0") + "b)")
    table.cell(dash, 0, 1, "OU Z-Score", text_color=cTextDim, text_size=size.tiny, bgcolor=cSubHead)
    table.cell(dash, 1, 1, ouZTxt, text_color=ouZColor, text_size=size.tiny, text_halign=text.align_right)

    statsOK = hlOK and hurstOK and adfOK and vrOK
    statsTxt = "H " + (hurstOK ? "OK" : "x") + "  ADF " + (adfOK ? "OK" : "x") + "  VR " + (vrOK ? "OK" : "x")
    statsCol = statsOK ? cGood : cBad
    table.cell(dash, 0, 2, "Stat Validity", text_color=cTextDim, text_size=size.tiny, bgcolor=cSubHead)
    table.cell(dash, 1, 2, statsTxt, text_color=statsCol, text_size=size.tiny, text_halign=text.align_right)

    regColor = (regime == 3 or regime == 5) ? cGood : (regime == 6 ? cBad : regime == 1 ? cTextDim : cWarn)
    vixTxt = na(vix) ? "-" : str.tostring(vix, "0.0")
    regTxt = f_regLabel(regime) + " (VIX " + vixTxt + ")"
    table.cell(dash, 0, 3, "Regime", text_color=cTextDim, text_size=size.tiny, bgcolor=cSubHead)
    table.cell(dash, 1, 3, regTxt, text_color=regColor, text_size=size.tiny, text_halign=text.align_right)

    compColor = compAbs > threshSess_eff ? cBad : compAbs > threshSwing_eff ? cWarn : compAbs > threshScalp_eff ? cGood : cTextDim
    compTxt = str.tostring(composite, "0.000") + " x" + str.tostring(clampedMult, "0.00")
    table.cell(dash, 0, 4, "Composite", text_color=cTextDim, text_size=size.tiny, bgcolor=cSubHead)
    table.cell(dash, 1, 4, compTxt, text_color=compColor, text_size=size.tiny, text_halign=text.align_right)

    confColor = conf >= 4 ? cGood : conf >= 3 ? cWarn : cTextDim
    confTxt = str.tostring(conf) + "/6 layers"
    table.cell(dash, 0, 5, "Confluence", text_color=cTextDim, text_size=size.tiny, bgcolor=cSubHead)
    table.cell(dash, 1, 5, confTxt, text_color=confColor, text_size=size.tiny, text_halign=text.align_right)

    tcaTxt = (na(expectedMoveBps) ? "-" : str.tostring(expectedMoveBps, "0.0")) + " bps | " + (tcaPass ? "PASS" : "FAIL")
    tcaColor = tcaPass ? cGood : cBad
    table.cell(dash, 0, 6, "TCA Edge", text_color=cTextDim, text_size=size.tiny, bgcolor=cSubHead)
    table.cell(dash, 1, 6, tcaTxt, text_color=tcaColor, text_size=size.tiny, text_halign=text.align_right)

    lvlTxt = ""
    rrTxt = ""
    if finalDir > 0
        lvlTxt := str.tostring(entryPx, "0.0") + " / " + str.tostring(slLong, "0.0") + " / " + str.tostring(finalTgtLong, "0.0")
        rrVal = math.abs(finalTgtLong - entryPx) / math.max(math.abs(entryPx - slLong), 0.01)
        rrTxt := " (R " + str.tostring(rrVal, "0.0") + ")"
    else if finalDir < 0
        lvlTxt := str.tostring(entryPx, "0.0") + " / " + str.tostring(slShort, "0.0") + " / " + str.tostring(finalTgtShort, "0.0")
        rrVal = math.abs(finalTgtShort - entryPx) / math.max(math.abs(entryPx - slShort), 0.01)
        rrTxt := " (R " + str.tostring(rrVal, "0.0") + ")"
    else
        lvlTxt := "-"
    table.cell(dash, 0, 7, "E / SL / TP", text_color=cTextDim, text_size=size.tiny, bgcolor=cSubHead)
    table.cell(dash, 1, 7, lvlTxt + rrTxt, text_color=finalDir != 0 ? cText : cMuted, text_size=size.tiny, text_halign=text.align_right)

    sigBg = finalDir > 0 ? color.new(#16a34a, 0) : finalDir < 0 ? color.new(#dc2626, 0) : color.new(#1e293b, 0)
    sigTxtColor = finalDir != 0 ? color.white : cTextDim
    decisionTxt = finalDir != 0 ? (f_dirLabel(finalDir) + " | " + f_hzLabel(horizon) + " | " + recoSide) : "NEUTRAL"
    table.cell(dash, 0, 8, "DECISION", text_color=sigTxtColor, bgcolor=sigBg, text_size=size.small)
    table.cell(dash, 1, 8, decisionTxt, text_color=sigTxtColor, bgcolor=sigBg, text_size=size.small, text_halign=text.align_right)

// ============================================================================
// TELEMETRY DASHBOARD
// ============================================================================
telDashPosResolved = telemDashPos == "top_left" ? position.top_left : telemDashPos == "top_right" ? position.top_right : telemDashPos == "bottom_left" ? position.bottom_left : telemDashPos == "bottom_right" ? position.bottom_right : position.middle_left
var table telemDash = table.new(telDashPosResolved, 5, 10, bgcolor=color.new(#0a0e1a, 0), border_width=1, border_color=color.new(#1a2238, 60), frame_color=color.new(#7c3aed, 30), frame_width=2)

if useTelemetry and showTelemDash and barstate.islast
    [tWins, tLosses, tExpired, tOpen, tBarsSum] = f_computeStats()

    totalTracked = array.size(tStatus)
    table.cell(telemDash, 0, 0, "SIGNAL TELEMETRY  n=" + str.tostring(totalTracked), text_color=color.new(#e2e8f0, 0), bgcolor=color.new(#0f172a, 0), text_size=size.small)
    table.merge_cells(telemDash, 0, 0, 4, 0)

    table.cell(telemDash, 0, 1, "",       text_color=color.new(#94a3b8, 0), bgcolor=color.new(#1a2238, 30), text_size=size.tiny)
    table.cell(telemDash, 1, 1, "Low",    text_color=color.new(#94a3b8, 0), bgcolor=color.new(#1a2238, 30), text_size=size.tiny)
    table.cell(telemDash, 2, 1, "Mid",    text_color=color.new(#94a3b8, 0), bgcolor=color.new(#1a2238, 30), text_size=size.tiny)
    table.cell(telemDash, 3, 1, "High",   text_color=color.new(#94a3b8, 0), bgcolor=color.new(#1a2238, 30), text_size=size.tiny)
    table.cell(telemDash, 4, 1, "All",    text_color=color.new(#94a3b8, 0), bgcolor=color.new(#1a2238, 30), text_size=size.tiny)

    hzLabels = array.from("SCALP", "SWING", "SESSION")
    for hz = 0 to 2
        rowIdx = hz + 2
        table.cell(telemDash, 0, rowIdx, array.get(hzLabels, hz), text_color=color.new(#facc15, 0), bgcolor=color.new(#1a2238, 50), text_size=size.tiny)
        rowW = 0
        rowL = 0
        for buc = 0 to 2
            idx = hz * 3 + buc
            w = array.get(tWins,   idx)
            l = array.get(tLosses, idx)
            rowW += w
            rowL += l
            [txt, col] = f_fmtCell(w, l)
            table.cell(telemDash, buc + 1, rowIdx, txt, text_color=col, text_size=size.tiny)
        [allTxt, allCol] = f_fmtCell(rowW, rowL)
        table.cell(telemDash, 4, rowIdx, allTxt, text_color=allCol, text_size=size.tiny)

    table.cell(telemDash, 0, 5, "ALL", text_color=color.new(#e2e8f0, 0), bgcolor=color.new(#1a2238, 50), text_size=size.tiny)
    grandW = 0
    grandL = 0
    for buc = 0 to 2
        colW = 0
        colL = 0
        for hz = 0 to 2
            idx = hz * 3 + buc
            colW += array.get(tWins,   idx)
            colL += array.get(tLosses, idx)
        grandW += colW
        grandL += colL
        [txt, col] = f_fmtCell(colW, colL)
        table.cell(telemDash, buc + 1, 5, txt, text_color=col, text_size=size.tiny)
    [gTxt, gCol] = f_fmtCell(grandW, grandL)
    table.cell(telemDash, 4, 5, gTxt, text_color=gCol, text_size=size.tiny)

    totalOpen    = 0
    totalExpired = 0
    totalBars    = 0
    totalRes     = grandW + grandL
    for i = 0 to 8
        totalOpen    += array.get(tOpen,    i)
        totalExpired += array.get(tExpired, i)
        totalBars    += array.get(tBarsSum, i)
    avgBarsHeld = totalRes > 0 ? totalBars / totalRes : 0
    expRate = (totalRes + totalExpired) > 0 ? math.round(100.0 * totalExpired / (totalRes + totalExpired)) : 0

    table.cell(telemDash, 0, 6, "Open",    text_color=color.new(#94a3b8, 0), text_size=size.tiny)
    table.cell(telemDash, 1, 6, str.tostring(totalOpen),                      text_color=color.new(#e2e8f0, 0), text_size=size.tiny)
    table.cell(telemDash, 2, 6, "Expired", text_color=color.new(#94a3b8, 0), text_size=size.tiny)
    table.cell(telemDash, 3, 6, str.tostring(totalExpired) + " (" + str.tostring(expRate) + "%)", text_color=color.new(#e2e8f0, 0), text_size=size.tiny)
    table.cell(telemDash, 4, 6, "avg=" + str.tostring(avgBarsHeld) + "b",     text_color=color.new(#94a3b8, 0), text_size=size.tiny)

    bucketTxt = "Low <" + str.tostring(bucketLowMax, "0.00") + "  |  Mid <" + str.tostring(bucketMidMax, "0.00") + "  |  High >=" + str.tostring(bucketMidMax, "0.00")
    table.cell(telemDash, 0, 7, bucketTxt, text_color=color.new(#475569, 0), bgcolor=color.new(#0f172a, 0), text_size=size.tiny)
    table.merge_cells(telemDash, 0, 7, 4, 7)

// ============================================================================
// ALERTS
// ============================================================================
alertcondition(finalDir > 0 and horizon == 1, "Scalp Long",  "SMRE: Mean-reversion long signal (scalp horizon)")
alertcondition(finalDir > 0 and horizon == 2, "Swing Long",  "SMRE: Mean-reversion long signal (swing horizon)")
alertcondition(finalDir > 0 and horizon == 3, "Session Long","SMRE: Mean-reversion long signal (session horizon)")
alertcondition(finalDir < 0 and horizon == 1, "Scalp Short", "SMRE: Mean-reversion short signal (scalp horizon)")
alertcondition(finalDir < 0 and horizon == 2, "Swing Short", "SMRE: Mean-reversion short signal (swing horizon)")
alertcondition(finalDir < 0 and horizon == 3, "Session Short","SMRE: Mean-reversion short signal (session horizon)")
alertcondition(useL6 and not na(gammaWall) and math.abs(close - gammaWall) < atrVal * 0.5, "Near Gamma Wall", "SMRE: Price near gamma wall")
````
