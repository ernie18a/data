# Volatility, Flow & Liquidity Engine

- url: https://www.tradingview.com/script/4bIhpshm-Volatility-Flow-Liquidity-Engine/
- type: indicator
- pine_id: PUB;6c4a962d1b744867bdabe910a9c31c03
- version: 2.0

## Description

Volatility, Flow & Liquidity Engine (VFL)

Why these parts are ONE tool, not a mashup of separate indicators

The three layers aren't independent studies stacked for show — they are sequential stages of a single trade decision (is a move coming, which way, and can I execute it) and they share one computational core. The same path-dependent volatility forecast is computed once and used by all three: it anchors Layer 1's expected move and implied-vs-realized dislocation, and it de-biases Layer 3's high-low spread estimators and prices its slippage and sizing. A signal is only actionable when Layer 1 says "loaded," Layer 2's order flow confirms the side, and Layer 3 says the spread and impact let you execute at size. Remove any layer and the decision is incomplete — timing without direction is a coin flip; direction without an execution read ignores slippage that can exceed the edge. That dependency, and the shared vol core, is why this lives in one script rather than three.

The three layers

Pressure & regime — when a move is coming. Compression, implied-vs-expected-vol dislocation, basis tension, convexity and trend inefficiency combine into a "pressure" reading. A high-percentile load plus a real range release fires a signal, typed GAMMA BLAST / SQUEEZE / EXPANSION, alongside a variance-ratio regime read and a path-dependent realized-vol forecast with a rolling fit/trust gauge.

Order flow — which way. Reconstructed intrabar buy/sell pressure (bulk-volume by default, with candle-geometry and intrabar tick-rule options) standardized to a z-score plus session CVD. Used only to confirm or veto a release's direction — the one orthogonal read price geometry alone can't give.

Liquidity & execution — can I trade it, and at what cost. Low-frequency effective-spread estimators (EDGE primary, with high-low covariance and high-low range cross-checks), an illiquidity ratio and impact-slope, and a volume-at-price liquidity map (POC, value area, walls, voids, anchored VWAP with σ bands, nearest dense liquidity). These become a liquidity score, slippage estimate, and order-type and size guidance. A structure sub-layer (prior-day value area + untested "naked" POCs) builds a per-bar support/resistance ladder that location-gates the final signal: a long is withheld if it would fire into a resistance shelf, a short if into support.

How to use it

Wait for the consolidated decision table to line up — pressure loaded, order flow confirming the side, liquidity executable, and the trade well-located against the S/R ladder. Read the size and order-type guidance before entering, and treat STRESSED liquidity or Extreme vol as stand-aside flags. The on-chart glow lines map the structure (prior-day value, naked-POC magnets, liquidity support/resistance, nearest shelves, fair-value VWAP); the legend-key panel decodes every line and marker.

Universal — works on any asset, any market

Price source, volume source (with a borrow-volume option for cash indices/FX), companion symbol and volatility index are all configurable inputs. Defaults are tuned for NSE NIFTY index futures (intraday, weekly Tuesday expiry, 09:15–15:30) — change the companion/vol-index symbols, expiry day and session for other instruments. The volatility index and companion symbol are optional; without them the engine runs price-only and re-weights automatically.

Non-repaint

Higher-timeframe confluence reads the last closed HTF bar by default, and every higher-timeframe request uses no-lookahead — confirmed signals don't move after the bar closes. The current bar forms live and settles on close, like any indicator.

Honesty / limitations

Every block is a low-frequency estimator of a quantity normally measured from quote/tick/book data — it approximates, it does not measure. Order flow is reconstructed (≈tick-rule accuracy), not true bid/ask; dealer-flow effects are inferred from price/vol/basis, not read from an option chain. Volume modules need a real volume feed and auto-disable without one. Follow-through statistics are computed on loaded chart history (in-sample), not a forward backtest.

This is a study/education tool, not financial advice. Estimates only; past behaviour does not guarantee future results.

## Source Code

````pine
//@version=6
// =====================================================================
// VOLATILITY, FLOW & LIQUIDITY ENGINE  [VFL]
// ---------------------------------------------------------------------
// A single OHLCV-only engine that answers a trader's three questions in
// one place — IS a move coming, WHICH way, and CAN I execute it — by
// running three cooperating layers off one shared volatility core. No
// option-chain, quote, tick or order-book data is used; no symbol is
// hardcoded; works on any asset and any market.
//
//   LAYER 1 · PRESSURE & REGIME (when / what kind of move)
//     Compression, implied-vs-expected-vol dislocation, basis tension,
//     convexity and trend inefficiency form a "pressure" reading;
//     a high-percentile load + a real range release fires a signal,
//     typed GAMMA BLAST / SQUEEZE / EXPANSION, with a variance-ratio
//     regime and a path-dependent realized-vol forecast.
//
//   LAYER 2 · ORDER FLOW (which way)
//     Reconstructed intrabar buy/sell pressure (tick-rule / BVC /
//     geometry) standardized to a z-score + session CVD, used purely to
//     confirm or veto the DIRECTION of a release — the one read the
//     price-geometry direction engine lacks.
//
//   LAYER 3 · LIQUIDITY & EXECUTION (can I trade it, and at what cost)
//     Low-frequency estimators of effective spread (EDGE primary, with
//     Abdi-Ranaldo and Corwin-Schultz cross-checks), price impact
//     (Amihud ILLIQ + rolling Kyle lambda), and a volume-at-price
//     liquidity map (POC / value area / walls / voids / anchored VWAP
//     with sigma bands / nearest dense liquidity), turned into a
//     liquidity score, regime, slippage estimate, order-type and size
//     guidance. A market-profile STRUCTURE sub-layer (prior-session
//     value area + untested "naked" POCs) builds a per-bar support/
//     resistance ladder that LOCATION-GATES the final signal: a long is
//     withheld when it would fire directly into a resistance shelf, a
//     short when it would fire into support.
//
// WHY THESE ARE ONE ENGINE (the mashup justification):
//   The three layers are not independent indicators stacked for show —
//   they are sequential stages of one decision and they SHARE a core.
//   The SAME path-dependent volatility forecast (reduced Guyon-Lekeufack
//   2023) is computed once and used by all three: it anchors Layer 1's
//   expected move and dislocation, and it de-biases Layer 3's high-low
//   spread estimators and prices Layer 3's slippage/sizing. A signal is
//   only actionable when Layer 1 says "loaded", Layer 2 confirms the
//   side, and Layer 3 says the spread/impact let you execute at size.
//   Remove any layer and the decision is incomplete: timing without
//   direction is a coin flip; direction without an execution read ignores
//   slippage that can exceed the edge. That dependency — and the shared
//   vol core — is why they live in one script, not three.
//
// CONCEPT CREDIT (public, peer-reviewed methods this engine approximates
//   on OHLCV — independent original implementation; no third-party Pine
//   code is reused):
//     • Path-dependent volatility — Guyon & Lekeufack (2023).
//     • Effective-spread estimators — Ardia, Guidotti & Kroencke (2024,
//       EDGE); Abdi & Ranaldo (2017); Corwin & Schultz (2012); Roll (1984).
//     • Price impact / illiquidity — Kyle (1985, lambda); Amihud (2002,
//       ILLIQ); square-root impact law — Almgren et al. (2005),
//       Tóth et al. / Bouchaud (2011).
//     • Order-flow classification — Lee & Ready (1991, tick rule);
//       Easley, López de Prado & O'Hara (2012, bulk-volume / VPIN);
//       Cont, Kukanov & Stoikov (2014, order-flow imbalance).
//     • Self-exciting flow clustering — Hawkes (1971); Bacry & Muzy.
//     • Market / volume profile (POC, value area, naked POC, structure)
//       — Steidlmayer & the CBOT Market Profile tradition.
//     • Variance-ratio regime — Lo & MacKinlay (1988).
//     • Efficiency ratio — Kaufman. Effective-sample / design effect —
//       Kish (1965). HTF trend confluence — Ichimoku Kinko Hyo (Hosoda).
//   These are standard, attributable concepts; the synthesis, the shared
//   vol core and the location-gated decision logic are the original work.
//
// LIMITATIONS: every block is a LOW-FREQUENCY ESTIMATOR of a quantity
//   normally measured from quote/tick/book data — it approximates, it
//   does not measure. Order flow is reconstructed (~tick-rule accuracy),
//   not true bid/ask. Volume modules need a real volume feed and auto-
//   disable without one. Estimators assume daily-type OHLC behaviour;
//   a calc-timeframe option keeps them stable. "Confirmed HTF bars"
//   (default ON) removes higher-timeframe repaint. NOT financial advice;
//   estimates only; past behaviour does not guarantee future results.
//
// NON-REPAINT: all higher-timeframe requests use lookahead_off and, with
//   "Confirmed HTF bars" ON (default), read the last CLOSED HTF bar — so
//   confirmed signals do not move after the bar closes. The current bar
//   forms live and settles on close, like every indicator. Turning
//   "Confirmed HTF bars" OFF trades that guarantee for faster (repainting)
//   HTF reads.
// =====================================================================
// METHODOLOGY (price + optional volatility index + optional companion
// symbol — no option-chain data is used or required):
//   Pressure  = blend of compression (ATR %ile), implied-vs-realized vol
//               dislocation, basis tension, convexity (return acceleration),
//               and trend inefficiency.
//   Forecast  = a compact PATH-DEPENDENT volatility forecast (reduced
//               Guyon-Lekeufack 2023) predicts next-period realized vol
//               from the price path; it sharpens the dislocation factor
//               and anchors the expected-move magnitude.
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
// PATH-DEPENDENT VOLATILITY FORECAST
// ---------------------------------------------------------------------
// A compact forecast of next-period realized volatility built from the
// price path (reduced Guyon-Lekeufack 2023: a leverage feature R1 + an
// activity feature sqrt(R2), each a fast+slow kernel blend of the
// CONFIRMED, lagged returns, lightly calibrated to THIS chart's realized
// vol). It feeds two parts of the engine and adds one gauge:
//   (1) DISLOCATION — the implied-vs-realized factor compares the
//       volatility index against the FORECAST of realized vol, not the
//       trailing realized vol. Implied-vs-expected is the variance-risk-
//       premium reading; trailing realized lags and is symmetric.
//   (2) EXPECTED MOVE — the move magnitude (expATR) is anchored to the
//       fitted forecast (converted to ATR units) and modulated by
//       pressure/flow, instead of a fixed linear pressure slope. The
//       expected move widens/narrows with the model's own vol level.
//   (3) TRUST GAUGE (toggle) — a rolling R-squared of forecast vs
//       realized vol shows how much of realized-vol variance the path
//       explains on this symbol; low fit flags a structural break.
//
// The forecast is deliberately NOT added as another term in the pressure
// blend — that would double-count the compression / vol-level signal the
// pressure factors already carry. It is used only where it fills a gap
// (dislocation comparison and expected-move magnitude) and as an
// independent trust gauge. Turning the forecast off reverts to the
// simpler pressure-slope expected move. The forecast is price-only, so
// (2) and (3) work even on assets without a volatility index; (1) needs
// the volatility index.
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
indicator("Volatility, Flow & Liquidity Engine", "VFL Engine", overlay=true,
     max_boxes_count=500, max_labels_count=500, max_lines_count=200, calc_bars_count=3000)

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

gD      = "01 · Data & market"
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
volSrcIn = input.source(volume, "Volume source (raw data)", group=gD,
             tooltip="The raw volume series the liquidity, profile and order-flow modules consume — lets the engine run on any instrument in any market. Default is the symbol's own volume; substitute a custom volume study's plot if your feed's volume is unreliable.")
volBorrowSym = input.symbol("", "Borrow volume from symbol (no-volume assets)", group=gD,
             tooltip="Optional, for cash indices / FX feeds that report no native volume. Enter a volume-bearing proxy for the same instrument (its future or continuous contract). Activates only when the charted symbol truly has no native volume; blank = never borrow.")
volNativeSeen = ta.cum(nz(volume)) > 0
useVolBorrow  = str.length(volBorrowSym) > 0 and not volNativeSeen
volBorrowed   = useVolBorrow ? request.security(volBorrowSym, timeframe.period, volume, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true) : na
volSrc        = useVolBorrow and not na(volBorrowed) ? volBorrowed : volSrcIn

gE      = "02 · Expiry engine"
expDay  = input.string("Tuesday", "Weekly expiry day",
             options=["Monday","Tuesday","Wednesday","Thursday","Friday"], group=gE,
             tooltip="Set to the weekday on which this asset's options/futures expire. Used only for the expiry-session classification and intraday clock.")
monthly = input.bool(false, "Monthly only (last <day> of month)", group=gE)
sH = input.int(9,  "Session start hour", group=gE), sM = input.int(15, "min", group=gE)
eH = input.int(15, "Session end hour",   group=gE), eM = input.int(30, "min", group=gE)

gW      = "03 · Lookback windows"
volLen  = input.int(20, "Vol window",        minval=5,  group=gW)
erLen   = input.int(20, "Efficiency window", minval=5,  group=gW)
basLen  = input.int(5,  "Basis momentum",    minval=1,  group=gW)
rankLen = input.int(120,"Percentile window", minval=30, group=gW)
trigLen = input.int(20, "Trigger lookback",  minval=5,  group=gW)

gF      = "04 · Volatility forecast"
useVolFcast = input.bool(true, "Forecast realized vol from price path", group=gF,
             tooltip="Adds a compact path-dependent volatility forecast (a reduced leverage + activity model, lightly calibrated to this chart's realized vol). It (1) sharpens the implied-vs-realized dislocation by comparing the volatility index against the FORECAST of realized vol instead of trailing realized vol, and (2) anchors the expected-move magnitude to a fitted forecast instead of a fixed pressure slope. Off = simpler pressure-slope expected move. It is NOT added as another pressure factor (that would double-count compression).")
vfFast  = input.int(10, "Vol kernel — fast", minval=2, group=gF, tooltip="Short-memory kernel of the path features.")
vfSlow  = input.int(60, "Vol kernel — slow", minval=5, group=gF, tooltip="Long-memory kernel of the path features.")
vfW     = input.float(0.5, "Fast-vs-slow weight", minval=0, maxval=1, step=0.05, group=gF)
vfCalLen= input.int(150, "Forecast calibration window", minval=20, group=gF, tooltip="Rolling window the leverage+activity model is fit over. Longer = steadier, slower to adapt.")
useFitGauge = input.bool(true, "Show path-vol fit (trust) gauge", group=gF,
             tooltip="Displays the rolling R-squared of the forecast vs realized vol on this symbol — how much of realized-vol variance the price path explains here. Informational: low fit (weak) suggests discounting the vol-based reads through a structural break. Does not block signals.")

gS      = "05 · Signals & sensitivity"
sigPct  = input.float(85, "Very-high-pressure %ile", minval=50, maxval=99, group=gS,
             tooltip="Pressure must reach this percentile of its own recent range. Higher = rarer.")
loadLook= input.int(10, "Spring memory (bars)", minval=1, group=gS,
             tooltip="High pressure must have occurred within this many bars of the release.")
relThr  = input.float(1.0, "Release size (0-1)", minval=0.1, maxval=1.0, group=gS,
             tooltip="How big the range expansion must be to count as a release.")
relBars = input.int(3, "Direction lookback", minval=1, group=gS)
coThr   = input.float(0.40, "Squeeze (VIX co-dir) cutoff", minval=0, maxval=1, group=gS)
confBars= input.int(2, "Confirm bars", minval=1, group=gS)
minGap  = input.int(10,"Min bars between signals", minval=1, group=gS)
critThr = input.float(75, "Critical pressure (panel)", group=gS)
detThr  = input.float(88, "Detonation pressure (panel)", group=gS)
fwdBars = input.int(5,   "Reliability fwd bars", minval=1, group=gS, tooltip="In-sample: bars to measure follow-through after a signal.")
fwdATR  = input.float(1.5,"Reliability target (ATR)", minval=0.1, group=gS)

gC      = "06 · HTF trend confluence (Ichimoku)"
useConf = input.bool(false, "Enable confluence (3 HTF requests — slower load)", group=gC,
             tooltip="Aligns release direction with Ichimoku cloud bias on current + 3 higher timeframes. OFF by default because it adds three higher-timeframe data requests, which is the single biggest load cost. Turn on if you want the HTF agreement filter and accept a slower load.")
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

gR      = "07 · Regime & flow"
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

gOF      = "08 · Order flow (direction)"
useOF    = input.bool(true, "Enable order-flow confirmation", group=gOF,
             tooltip="Reconstructs intrabar buy vs sell pressure (synthetic order-flow imbalance) and uses it to confirm the DIRECTION of a release — the one orthogonal read the price-geometry direction engine otherwise lacks. NOT added to the pressure blend (that would double-count). Proxy only: real order flow needs Level-2 data a chart cannot access.")
ofMethod = input.string("Bulk Volume Classification", "Classification", options=["Intrabar Tick Rule","Bulk Volume Classification","Candle Geometry"], group=gOF,
             tooltip="Bulk Volume Classification (default, light): splits each bar's volume via a normal CDF of its standardized return — robust on bar data, no extra data feed. Candle Geometry: splits by close location within range — lightest, works everywhere. Intrabar Tick Rule: tags lower-TF bars buy/sell — most faithful when intrabar data exists (Premium), but pulls an intrabar feed every bar, so it is the heaviest option — pick it only if you need it. Auto-falls back to geometry if intrabar data is unavailable.")
ofLTF    = input.timeframe("1", "Intrabar resolution", group=gOF, tooltip="Lower timeframe used by the tick-rule classifier.")
ofZLen   = input.int(50, "Imbalance z-score / CVD window", minval=10, maxval=500, group=gOF)
ofThr    = input.float(0.5, "Confirm threshold (|z|)", minval=0.1, maxval=3.0, step=0.1, group=gOF,
             tooltip="Minimum standardized imbalance for order flow to count as confirming a side.")
ofMode   = input.string("Badge (don't block)", "Mode", options=["Badge (don't block)","Filter (require agreement)"], group=gOF,
             tooltip="Badge = show the read and brighten confirmed signals, never block. Filter = veto a release only when order flow actively OPPOSES its direction (neutral flow still passes).")
ofGateGam= input.bool(false, "Also filter gamma blasts", group=gOF, tooltip="On = expiry gamma-blast signals must also not be opposed by order flow.")

gX      = "09 · Session & events"
useSess = input.bool(true, "Session phase weighting (all days)", group=gX,
             tooltip="Opening drive 1.2x, midday lull 0.85x, close acceleration 1.15x on the expected move.")
useGap  = input.bool(true, "Overnight gap z-score (day type)", group=gX)
gapThr  = input.float(1.0, "Gap watch threshold (ATR)", minval=0.1, group=gX)
evDates = input.string("", "Event days (YYYY-MM-DD, comma-sep)", group=gX,
             tooltip="RBI / budget / Fed days. Expected move is widened 1.3x on these dates.")

gV      = "10 · Display & panel"
themeOpt= input.string("Auto", "Color theme", options=["Auto","Dark","Light"], group=gV,
             tooltip="Auto reads the chart background. Force Dark or Light if signals look washed out.")
panelFontOpt = input.string("Small", "Panel font size", options=["Tiny","Small","Normal","Large"], group=gV,
             tooltip="Font size for the decision table. The header and TRADE rows render one tier larger.")
labelFontOpt = input.string("Small", "On-chart label size", options=["Tiny","Small","Normal","Large"], group=gV,
             tooltip="Font size for the on-chart text labels (S/R, liquidity, structure, VWAP tag, triggers, legend, trade tags).")
useGlow = input.bool(true, "Neon glow on signals & fair-value line", group=gV,
             tooltip="Soft halos under the BUY/SELL markers and the anchored-VWAP fair-value line. Off = solid lines/markers only.")
visMode = input.string("Compact", "Visual density", options=["Compact","Full"], group=gV, tooltip="Compact (default) hides the decorative layers — regime ribbon, legend key, compression boxes, trigger lines, VWAP sigma-bands, structure ladder — for a cleaner, faster chart. Full shows everything. Your individual toggles still apply on top.")
compact = visMode == "Compact"
showBars= input.bool(true,  "Colour candles by direction", group=gV)
showBox = input.bool(true,  "Compression boxes", group=gV)
showTrg = input.bool(true,  "Trigger lines",     group=gV)
showSig = input.bool(true,  "Trade signal markers", group=gV)
panelMode = input.string("Compact", "Panel mode", options=["Compact","Pro"], group=gV,
             tooltip="Compact (default): one consolidated decision table — trade, direction, pressure, flow, liquidity, size. Pro: the full readout of all three layers.")
showPnl = input.bool(true,  "Decision panel", group=gV)
tradeReqLiq = input.bool(true, "Require executable liquidity for a trade signal", group=gV,
             tooltip="ON: suppress a BUY/SELL when liquidity is STRESSED (you'd pay too much to execute). OFF: fire on pressure+flow regardless of liquidity.")
showRib = input.bool(true,  "Regime ribbon (chart bottom)", group=gV)
showFx  = input.bool(true,  "Signal forensics tooltip (ⓘ)", group=gV)
posOpt  = input.string("Top Right", "Panel position",
             options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=gV)
lnWidth = input.int(2, "Line thickness", minval=1, maxval=5, group=gV,
             tooltip="Core width of the level lines (structure, liquidity S/R, nearest-liquidity). A soft glow underlay is drawn beneath each at this width + 5.")
showKey = input.bool(true, "Legend key (what each line/marker means)", group=gV,
             tooltip="A small theme-adaptive table decoding every line and marker the engine draws.")
keyPos  = input.string("Bottom Left", "Legend key position",
             options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=gV)

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
isDark  = themeOpt == "Dark" ? true : themeOpt == "Light" ? false : (na(bgLum) ? true : bgLum < 140)
txtCol  = isDark ? color.white : color.rgb(16, 20, 24)
txtDim  = isDark ? color.rgb(154, 166, 178) : color.rgb(74, 82, 91)
// institution dashboard surface — OPAQUE + theme-adaptive + zebra striped
panelBg = isDark ? color.rgb(17, 22, 28)  : color.rgb(244, 246, 248)
rowAlt  = isDark ? color.rgb(25, 31, 39)  : color.rgb(232, 236, 240)
hdrBg   = isDark ? color.rgb(30, 38, 48)  : color.rgb(222, 228, 234)
frameCol= isDark ? color.rgb(58, 70, 84)  : color.rgb(196, 204, 212)
cGamma  = isDark ? #bb6bff : #6a1b9a
cSqueeze= isDark ? #ff9e40 : #d84315
cExpand = isDark ? #40a9ff : #1565c0
cGreen  = isDark ? #00e676 : #2e7d32
cRed    = isDark ? #ff5252 : #c62828
cAmber  = isDark ? #ffd740 : #e65100

// resolved font sizes (from the Display group)
panelTxtSize = panelFontOpt == "Tiny" ? size.tiny : panelFontOpt == "Normal" ? size.normal : panelFontOpt == "Large" ? size.large : size.small
panelBigSize = panelFontOpt == "Tiny" ? size.small : panelFontOpt == "Small" ? size.normal : panelFontOpt == "Normal" ? size.large : size.huge
labelTxtSize = labelFontOpt == "Tiny" ? size.tiny : labelFontOpt == "Normal" ? size.normal : labelFontOpt == "Large" ? size.large : size.small

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
// Standard normal CDF (rational erf approximation) — used by BVC order-flow split
ofNcdf(x) =>
    z = x / math.sqrt(2.0)
    t = 1.0 / (1.0 + 0.3275911 * math.abs(z))
    y = 1.0 - (((((1.061405429 * t - 1.453152027) * t) + 1.421413741) * t - 0.284496736) * t + 0.254829592) * t * math.exp(-z * z)
    erf = z >= 0 ? y : -y
    0.5 * (1.0 + erf)
// ORB-style glow line: soft wide underlay beneath a solid core, pushed into an array
f_glowLine(larr, x1, x2, y, col, sty) =>
    array.push(larr, line.new(x1, y, x2, y, color=color.new(col, 82), width=lnWidth + 5, style=sty))
    array.push(larr, line.new(x1, y, x2, y, color=color.new(col, 0),  width=lnWidth,     style=sty))


// ---------------------------------------------------------------------
// FEATURES + PRESSURE
// ---------------------------------------------------------------------
ret   = math.log(priceSrc / priceSrc[1])
atr   = ta.atr(volLen)
rv    = ta.stdev(ret, volLen) * math.sqrt(252.0) * 100

// =====================================================================
// PATH-DEPENDENT VOLATILITY FORECAST (compact)
//   Reduced path-dependent model: leverage feature R1 + activity sqrt(R2),
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
// ENGINE ANALYTICS (phase, forecast, size, weather)
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
//     Forecast off  -> simpler  0.5 + pressure/100*3.0  behaviour.
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

backwardation = useBasis and spotValid and basisPct < -backThr

charmW  = (not useCharm or not isExp) ? 1.0 : prog < 0.4 ? 0.7 : prog < 0.75 ? 1.0 : 1.35

flowMult = math.max(0.5, math.min(2.5, (applyFlow ? (1 + instab / 100 * 0.4) : 1.0) * (useCharm ? charmW : 1.0) * sessW * (eventDay ? 1.3 : 1.0)))
expATR   = math.max(0.3, expATR0 * flowMult)                 // instability + charm scaled
expPts   = expATR * atr                                      // ...in price points

// ---------------------------------------------------------------------
// ORDER-FLOW CONFIRMATION — synthetic OFI, orthogonal direction read
//   Reconstruct intrabar buy vs sell volume (tick-rule / BVC / geometry),
//   standardize the signed imbalance, track a session CVD, derive a +1/-1
//   directional bias. Used only to confirm/veto release DIRECTION and as a
//   panel row — never folded into 'pressure'. Requests are unconditional
//   (consistent history); method branches just consume them.
// ---------------------------------------------------------------------
// Intrabar feed is fetched ONLY when the tick-rule method is selected (heavy
// call). Other methods and "off" skip it entirely. (Method input is constant
// per run, so the branch is consistent across history.)
ofUseLTF = useOF and ofMethod == "Intrabar Tick Rule"
ofO = array.new<float>(0)
ofC = array.new<float>(0)
ofV = array.new<float>(0)
if ofUseLTF
    [qofO, qofC, qofV] = request.security_lower_tf(syminfo.tickerid, ofLTF, [open, close, volume])
    ofO := qofO
    ofC := qofC
    ofV := qofV
ofRetSig = ta.stdev(close - close[1], ofZLen)
ofEffVol = na(volSrc) or volSrc == 0 ? 1.0 : volSrc
var float ofBuy  = na
var float ofSell = na
ofBuy  := 0.0
ofSell := 0.0
if useOF and ofMethod == "Intrabar Tick Rule" and array.size(ofC) > 0
    for i = 0 to array.size(ofC) - 1
        lo = array.get(ofO, i)
        lc = array.get(ofC, i)
        lv = array.get(ofV, i)
        vv = na(lv) or lv == 0 ? 1.0 : lv
        if lc > lo
            ofBuy  += vv
        else if lc < lo
            ofSell += vv
        else
            ofBuy  += vv * 0.5
            ofSell += vv * 0.5
if useOF and ofMethod == "Bulk Volume Classification"
    zb = ofRetSig > 0 ? (close - close[1]) / ofRetSig : 0.0
    bf = ofNcdf(zb)
    ofBuy  := ofEffVol * bf
    ofSell := ofEffVol * (1.0 - bf)
if useOF and (ofMethod == "Candle Geometry" or (ofBuy + ofSell == 0.0))
    rng0 = high - low
    if rng0 > 0
        ofBuy  := ofEffVol * (close - low) / rng0
        ofSell := ofEffVol * (high - close) / rng0
    else
        ofBuy  := ofEffVol * 0.5
        ofSell := ofEffVol * 0.5
ofTot  = ofBuy + ofSell
ofRaw  = ofBuy - ofSell
ofImb  = ofTot > 0 ? ofRaw / ofTot : 0.0
ofMean = ta.sma(ofRaw, ofZLen)
ofSd   = ta.stdev(ofRaw, ofZLen)
ofZ    = ofSd > 0 ? (ofRaw - ofMean) / ofSd : 0.0
ofZ   := math.max(math.min(ofZ, 4.0), -4.0)
ofNewDay = ta.change(time("D")) != 0
var float ofCVD = 0.0
ofCVD := (ofNewDay ? 0.0 : ofCVD) + ofRaw
ofCvdUp = ofCVD >= nz(ofCVD[1])
ofBias  = not useOF ? 0 : (ofZ >= ofThr and ofImb > 0) ? 1 : (ofZ <= -ofThr and ofImb < 0) ? -1 : 0
ofCol   = ofBias > 0 ? cGreen : ofBias < 0 ? cRed : color.gray

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
energy := math.max(0.0, math.min(10.0, energy + math.max(0.0, (fComp - 50) / 50) * 0.12 - rngExp * 0.35))
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
    [x1a, x1b] = request.security(syminfo.tickerid, tf1, ichiPair(), lookahead=barmerge.lookahead_off)
    b1L := x1a
    b1C := x1b
    [x2a, x2b] = request.security(syminfo.tickerid, tf2, ichiPair(), lookahead=barmerge.lookahead_off)
    b2L := x2a
    b2C := x2b
    [x3a, x3b] = request.security(syminfo.tickerid, tf3, ichiPair(), lookahead=barmerge.lookahead_off)
    b3L := x3a
    b3C := x3b
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

// order-flow direction confirmation / veto (mirrors the Ichimoku gate)
ofConfirm = useOF and ofBias == sigDir
needOF    = useOF and ofMode == "Filter (require agreement)"
passOF    = not needOF ? true : (isExpiryNow and not ofGateGam ? true : ofBias != -sigDir)

var int rAge = 0
rAge := rawSig ? rAge + 1 : 0
var int lastSig = -100000
ev = rAge == confBars and (bar_index - lastSig) >= minGap and passConf and passReg and passOF
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
        fG := fG + mfe
        aG := aG + mae
    else if tAt == "SQUEEZE"
        nS := nS + 1
        hS := hit ? hS + 1 : hS
        fS := fS + mfe
        aS := aS + mae
    else
        nE := nE + 1
        hE := hit ? hE + 1 : hE
        fE := fE + mfe
        aE := aE + mae
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
sUp = showSig and ev and relUp
sDn = showSig and ev and not relUp
// Bold/bright BUY-SELL trade markers are rendered at the END of the script,
// where the liquidity layer is known and can gate them. Expiry + ribbon stay here.
plotchar(sUp and isExpiryNow, "Expiry Up",   "⚡", location.belowbar, color=cGamma, size=size.tiny)
plotchar(sDn and isExpiryNow, "Expiry Down", "⚡", location.abovebar, color=cGamma, size=size.tiny)

// --- regime ribbon: thin strip at chart bottom (VR amplify/pin) ---
ribCol = regimeAmp ? color.new(cExpand, 35) : regimePin ? color.new(color.gray, 55) : color.new(cAmber, 55)
plotshape(showRib and useReg and not compact, "Regime ribbon", style=shape.square, location=location.bottom, color=ribCol, size=size.tiny)

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
         + (useOF ? "\nOrder flow " + (ofBias > 0 ? "▲" : ofBias < 0 ? "▼" : "•") + " " + str.tostring(ofZ, "#.0") + "σ" + (ofConfirm ? " ✓" : "") : "")
    label.new(bar_index, relUp ? low : high, "ⓘ", style=relUp ? label.style_label_up : label.style_label_down,
         color=color.new(typCol, 70), textcolor=txtOn(typCol), size=labelTxtSize, tooltip=fxTxt)

// --- rich webhook-ready alert with live values ---
if ev
    alert("VFL " + typ + " " + (relUp ? "UP" : "DOWN") + " | " + syminfo.ticker + " " + timeframe.period
         + " | P=" + str.tostring(math.round(pressure)) + " VR=" + str.tostring(vr, "#.00")
         + " regime=" + regimeStr + " instab=" + str.tostring(math.round(instab))
         + (useVolFcast and volFcastReady ? " fcastRV=" + str.tostring(rvForecast, "#.0") : "")
         + (useOF ? " of=" + str.tostring(ofZ, "#.0") + (ofConfirm ? "(confirm)" : "") : "")
         + " expPts=" + str.tostring(math.round(expPts))
         + " trig=" + str.tostring(dnTrig, format.mintick) + "/" + str.tostring(upTrig, format.mintick),
         alert.freq_once_per_bar_close)

// --- data-window internals (trimmed for plot budget) ---
plot(pressure, "Pressure",    display=display.data_window)
plot(pPct,     "Loaded %ile", display=display.data_window)
plot(vr,       "Variance ratio", display=display.data_window)
plot(volFcastReady ? rvForecast : na, "Vol forecast (annz %)", display=display.data_window)
plot(useOF ? ofZ : na, "Order-flow z", display=display.data_window)

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
if showBox and not compact and cAge == 5
    ctop := hh20
    cbot := ll20
    cbox := box.new(bar_index - 5, ctop, bar_index, cbot, border_color=color.new(cAmber, 30), bgcolor=color.new(cAmber, 94), border_width=1)
if showBox and not compact and comp70 and not na(cbox)
    box.set_right(cbox, bar_index)
if showBox and not compact and (not comp70) and not na(cbox)
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
if showTrg and not compact and barstate.islast
    if not na(upL)
        line.delete(upL)
    if not na(dnL)
        line.delete(dnL)
    if not na(upLb)
        label.delete(upLb)
    if not na(dnLb)
        label.delete(dnLb)
    upL  := line.new(bar_index - trigLen, upTrig, bar_index + 8, upTrig, color=cGreen, width=lnWidth, style=line.style_dashed)
    dnL  := line.new(bar_index - trigLen, dnTrig, bar_index + 8, dnTrig, color=cRed, width=lnWidth, style=line.style_dashed)
    upLb := label.new(bar_index + 8, upTrig, "▲ " + str.tostring(upTrig, format.mintick), style=label.style_label_left, color=cGreen, textcolor=color.white, size=labelTxtSize)
    dnLb := label.new(bar_index + 8, dnTrig, "▼ " + str.tostring(dnTrig, format.mintick), style=label.style_label_left, color=cRed, textcolor=color.white, size=labelTxtSize)

// ---------------------------------------------------------------------
// UNIFIED DECISION TABLE — table + helper defined here, rendered at end
// ---------------------------------------------------------------------
panelPos = posOpt == "Top Left" ? position.top_left : posOpt == "Bottom Right" ? position.bottom_right : posOpt == "Bottom Left" ? position.bottom_left : position.top_right
var table pnl = table.new(panelPos, 2, 42, border_width=1, frame_width=1, frame_color=frameCol)
prow(r, k, v, vbg) =>
    rbg = r % 2 == 0 ? panelBg : rowAlt
    table.cell(pnl, 0, r, k, text_color=txtDim, text_size=panelTxtSize, text_halign=text.align_left,  bgcolor=rbg)
    table.cell(pnl, 1, r, v, text_color=txtOn(vbg), text_size=panelTxtSize, text_halign=text.align_right, bgcolor=color.new(vbg, 10))
// (unified decision table is rendered at the very end, after the liquidity layer)

// ---------------------------------------------------------------------
// ALERTS
// ---------------------------------------------------------------------
alertcondition(ev and isExpiryNow,        "Expiry Gamma Signal",  "VFL: GAMMA BLAST on {{ticker}} ({{interval}})")
alertcondition(ev and not isExpiryNow,    "Pressure Release",     "VFL: pressure release on {{ticker}} ({{interval}})")
alertcondition(pressure >= critThr and pressure[1] < critThr, "Critical pressure", "VFL: pressure CRITICAL on {{ticker}}")
alertcondition(useShock and vixSpike and not vixSpike[1], "Vol shock (VIX spike)", "VFL: vol-index spike / vol-shock on {{ticker}} ({{interval}})")

// =====================================================================
// =====================================================================
//  LAYER 3 · LIQUIDITY & EXECUTION
//  Reuses the shared path-dependent vol forecast (perBarFcast) and the
//  shared theme/helpers from Layers 1-2. All identifiers are lx-prefixed
//  to keep the namespaces separate.
// =====================================================================
// --- palette aliases onto the shared theme ---
cDeep   = cGreen
cStress = cRed
cThin   = cAmber
cNorm   = cExpand

// --- inputs ---
gLD       = "11 · Liquidity · data & basis"
lxSrcSel  = input.string("close", "Price source (returns)", options=["close","hl2","ohlc4","hlc3"], group=gLD,
             tooltip="Picks which price series drives the liquidity return-math. Spread estimators always use OHLC.")
lxCalcTF  = input.timeframe("", "Calc timeframe (blank = chart)", group=gLD,
             tooltip="Run the liquidity estimators on a fixed timeframe (e.g. D) for stability regardless of chart timeframe. Blank uses the chart timeframe.")
lxVolMode = input.string("Auto", "Volume feed", options=["Auto","Force on","Force off (price-only)"], group=gLD,
             tooltip="Auto disables volume modules when the symbol reports no usable volume (indices/FX often lack real volume).")
gLW       = "12 · Liquidity · windows"
lxEstLen  = input.int(20,  "Spread sample window",  minval=5,  group=gLW)
lxImpLen  = input.int(20,  "Impact / illiquidity window", minval=5, group=gLW)
lxImbLen  = input.int(14,  "Order-imbalance window", minval=3, group=gLW)
lxRankLen = input.int(252, "Percentile / history window", minval=50, group=gLW,
             tooltip="Lookback used to rank each raw estimator 0-100 against its own history.")
gLP       = "13 · Liquidity · spread estimators"
lxSpreadPrimary = input.string("EDGE (2024)", "Primary estimator",
             options=["EDGE (2024)","High-low covariance","High-low range","Consensus (median)"], group=gLP,
             tooltip="EDGE uses OHLC and is generally most accurate and vol-robust. Consensus takes the median of all three.")
gLVol     = "14 · Liquidity · vol conditioning"
lxVolAdjOn= input.bool(true, "Condition cost/size on volatility", group=gLVol,
             tooltip="Uses the engine's shared path-vol forecast to (1) de-bias the high-low spread estimators when a wide range is really just volatility, (2) add a volatility timing cost to slippage, and (3) scale size by a volatility budget. EDGE stays the vol-robust anchor; volatility is NOT added into the liquidity score.")
lxMaxShrink= input.float(0.6, "Max vol de-bias of high-low spread", minval=0, maxval=1, step=0.05, group=gLVol,
             tooltip="At extreme volatility, shrink up to this fraction of the high-low estimators' EXCESS over EDGE, attributing it to volatility rather than spread. 0 = never de-bias.")
lxVolTimingK= input.float(0.5, "Vol timing cost (x 1-bar forecast)", minval=0, maxval=5, step=0.1, group=gLVol,
             tooltip="Slippage gains a timing component = this x the one-bar volatility forecast (adverse drift while an order works). 0 = spread-only slippage.")
gLM       = "15 · Liquidity · map & nearest"
lxShowMap = input.bool(true,  "Show liquidity zones", group=gLM)
lxShowNearLiq = input.bool(true, "Mark nearest liquidity (above/below price)", group=gLM,
             tooltip="Highlights the closest dense volume shelf above and below price — the nearest pools of resting liquidity price is likely to gravitate to or stall at. Shown with distance in ATR.")
lxLiqThr  = input.float(50, "Nearest-liquidity sensitivity (%)", minval=20, maxval=95, step=5, group=gLM,
             tooltip="A price bin counts as a liquidity shelf when its volume reaches this % of the busiest bin. Lower = marks more (closer, lighter) shelves; higher = only the heaviest.")
lxMapStyle= input.string("Heatmap", "Zone style", options=["Heatmap","Bands"], group=gLM)
lxMapBins = input.int(24, "Price bins", minval=8, maxval=60, group=gLM)
lxMapLook = input.int(250, "Map history (bars)", minval=30, maxval=480, group=gLM,
             tooltip="How far back to read where trading happened, to colour the zones.")
lxThinPct = input.float(35, "Thin-zone threshold (%ile)", minval=5, maxval=95, group=gLM,
             tooltip="Volume-at-price below this percentile is treated as a thin (low-resistance) zone.")
lxDecayHL = input.int(60, "Recency half-life (bars, 0=off)", minval=0, group=gLM,
             tooltip="Recent trading counts more. Volume this many bars ago counts half. 0 = equal weight.")
lxDistrib = input.bool(true, "Spread each bar across its range", group=gLM,
             tooltip="Distributes a bar's volume across its high-low range instead of dumping it at the midpoint.")
lxVaPct   = input.float(70, "Value area (%)", minval=50, maxval=95, group=gLM,
             tooltip="The central band holding this % of volume. POC = busiest price.")
lxShowVoid= input.bool(true, "Flag nearest liquidity void (magnet)", group=gLM)
lxShowVwap= input.bool(true, "Anchored VWAP (fair-value line)", group=gLM)
lxVwapAnchor = input.string("Last major swing", "VWAP anchor",
             options=["Last major swing","Session open","Week open","Month open","Highest-volume bar"], group=gLM,
             tooltip="Where the fair-value line starts. 'Last major swing' holds until a bigger swing replaces it; period options reset each period; 'Highest-volume bar' anchors to the biggest liquidity event.")
lxSwingStrength = input.int(10, "Swing strength (for swing anchor)", minval=3, group=gLM)
lxShowBands = input.bool(true, "VWAP σ-deviation bands", group=gLM,
             tooltip="Volume-weighted standard-deviation channel on the SAME anchor as the fair-value line: ±1σ (inner) and ±2σ (outer). The heat fill reddens above fair value and greens below, getting denser toward the ±2σ edge where mean-reversion risk is highest.")
lxBandFill  = input.string("Reversion heat", "Band fill", options=["Reversion heat","Neon glow","Off"], group=gLM,
             tooltip="Reversion heat: red above / green below, denser toward ±2σ. Neon glow: single-colour halo fading outward. Off: edge lines only.")
lxBandMult1 = input.float(1.0, "Inner band (σ)", minval=0.1, step=0.1, group=gLM)
lxBandMult2 = input.float(2.0, "Outer band (σ)", minval=0.1, step=0.1, group=gLM)
gST       = "16 · Structure & location"
stPriorDay  = input.bool(true,  "Prior-day value area (POC / VAH / VAL)", group=gST,
             tooltip="A per-session volume-at-price built fresh each day; the completed day's POC and value-area edges become next session's reference S/R.")
stNakedPoc  = input.bool(true,  "Untested (naked) prior POCs", group=gST,
             tooltip="Logs each completed day's POC; it stays a live magnet until price trades back through it, then retires.")
stMaxNaked  = input.int(15, "Keep last N naked POCs", minval=2, maxval=60, group=gST)
stGrid      = input.int(10, "Daily map grid (ticks per bin)", minval=1, maxval=200, group=gST,
             tooltip="Accumulation resolution for the prior-day profile = mintick × this. Raise on very wide-range instruments.")
stShowLevels= input.bool(true, "Draw structure levels on chart", group=gST)
tradeReqLoc = input.bool(true, "Location-gate trade signals", group=gST,
             tooltip="ON: suppress a BUY when a resistance level sits within the buffer just above (you'd be buying into a wall), and a SELL when support is just below. The structure says WHERE; the engine says WHETHER.")
stLocBufATR = input.float(0.5, "Location buffer (× ATR)", minval=0.1, maxval=3.0, step=0.1, group=gST,
             tooltip="How much clearance the trade needs to the opposing level to count as well-located.")
gLT       = "17 · Liquidity · decision"
lxRiskPct = input.float(1.0, "Account risk per trade (%)", minval=0.05, group=gLT,
             tooltip="Used only to scale the suggested size text; no account data is read.")
lxTickVal = input.float(0.0, "Point value (0 = auto from syminfo)", minval=0, group=gLT)
// (Liquidity reads render in the unified decision table; use the Display
//  group's panel controls for mode and position.)

// --- source & volume resolution ---
lxSrcBase = lxSrcSel == "hl2" ? hl2 : lxSrcSel == "ohlc4" ? ohlc4 : lxSrcSel == "hlc3" ? hlc3 : close
lxVolSeen = ta.cum(nz(volSrc)) > 0 and not na(volSrc)
lxVolHi50 = ta.highest(nz(volSrc), 50)
lxHasVolAuto = lxVolSeen and lxVolHi50 > 0
lxUseVol = lxVolMode == "Force on" ? true : lxVolMode == "Force off (price-only)" ? false : lxHasVolAuto

// Liquidity feed: on the chart timeframe (default) read raw series directly —
// no request.security at all. Only fetch a higher calc-timeframe when one is set,
// and then in a SINGLE tuple call instead of six. (Calc-TF input is constant per
// run, so the branch is consistent across history — no repaint.)
lxOnChart = lxCalcTF == "" or lxCalcTF == timeframe.period
float lxO = open
float lxH = high
float lxL = low
float lxC = close
float lxVq = nz(volume)
float lxS = lxSrcBase
if not lxOnChart
    [qO, qH, qL, qC, qV, qS] = request.security(syminfo.tickerid, lxCalcTF, [open, high, low, close, nz(volume), lxSrcBase], lookahead=barmerge.lookahead_off)
    lxO  := qO
    lxH  := qH
    lxL  := qL
    lxC  := qC
    lxVq := qV
    lxS  := qS
lxV = lxOnChart ? nz(volSrc) : lxVq

lxLH = math.log(lxH)
lxLL = math.log(lxL)
lxLC = math.log(lxC)
lxLO = math.log(lxO)
lxRet = math.log(lxS / lxS[1])

// --- spread estimators (proportional, >= 0) ---
lxMid   = (lxLH + lxLL) / 2
lxArCov = ta.sma((lxLC - lxMid) * (lxLC - lxMid[1]), lxEstLen)
lxArSpread = 2 * math.sqrt(math.max(0.0, lxArCov))

lxBeta2 = math.pow(lxLH - lxLL, 2) + math.pow(lxLH[1] - lxLL[1], 2)
lxHl2d  = math.max(lxLH, lxLH[1]) - math.min(lxLL, lxLL[1])
lxGamma = math.pow(lxHl2d, 2)
lxK     = 3 - 2 * math.sqrt(2.0)
lxAlpha = (math.sqrt(2 * lxBeta2) - math.sqrt(lxBeta2)) / lxK - math.sqrt(lxGamma / lxK)
lxCsRaw = 2 * (math.exp(lxAlpha) - 1) / (1 + math.exp(lxAlpha))
lxCsSpread = ta.sma(math.max(0.0, lxCsRaw), lxEstLen)

lxMt  = (lxLH + lxLL) / 2
lxMp  = (lxLH[1] + lxLL[1]) / 2
lxX1  = (lxLC - lxMt)
lxX2  = (lxLO - lxMt)
lxX3  = (lxLC[1] - lxMp)
lxX4  = (lxLO - lxMp)
lxE1  = -2.0 * ta.sma(lxX1 * lxX4, lxEstLen)
lxE2  = -2.0 * ta.sma(lxX2 * lxX3, lxEstLen)
lxEdgeVar = (lxE1 + lxE2) / 2.0
lxEdgeSpread = math.sqrt(math.max(0.0, lxEdgeVar))

// --- shared vol forecast (per-bar return units) -> liquidity percentile/regime ---
lxVolReady  = volFcastReady
lxVolPct    = ta.percentrank(perBarFcast, lxRankLen)
lxVolRegime = not lxVolReady ? "—" : lxVolPct >= 90 ? "Extreme" : lxVolPct >= 65 ? "High" : lxVolPct >= 25 ? "Normal" : "Low"

// --- spread selection (+ vol de-bias of high-low estimators; EDGE unshrunk) ---
lxVolShrink = lxVolAdjOn and lxVolReady ? math.min(lxMaxShrink, math.max(0.0, (lxVolPct - 50.0) / 50.0) * lxMaxShrink) : 0.0
lxArAdj = lxArSpread - math.max(0.0, lxArSpread - lxEdgeSpread) * lxVolShrink
lxCsAdj = lxCsSpread - math.max(0.0, lxCsSpread - lxEdgeSpread) * lxVolShrink
lxMedSpread    = math.max(math.min(lxEdgeSpread, lxArAdj), math.min(math.max(lxEdgeSpread, lxArAdj), lxCsAdj))
lxSpreadRaw = lxSpreadPrimary == "High-low covariance" ? lxArAdj : lxSpreadPrimary == "High-low range" ? lxCsAdj : lxSpreadPrimary == "EDGE (2024)" ? lxEdgeSpread : math.avg(lxEdgeSpread, lxArAdj, lxCsAdj)
lxSpreadP   = lxSpreadPrimary == "Consensus (median)" ? lxMedSpread : lxSpreadRaw
lxSpreadBps = lxSpreadP * 10000.0

// --- price impact (illiquidity ratio + high-low refinement + impact slope) ---
lxDollarVol = lxV * lxC
lxAmiClassic = lxUseVol and lxDollarVol > 0 ? math.abs(lxRet) / lxDollarVol : na
lxHlRange = (lxH - lxL) / lxC
lxAmiHL = lxUseVol and lxDollarVol > 0 ? lxHlRange / lxDollarVol : na
lxAmiRaw = nz(lxAmiHL, nz(lxAmiClassic, 0.0))
lxAmihud = ta.sma(lxAmiRaw, lxImpLen) * 1e9

lxSgn    = lxRet > 0 ? 1.0 : lxRet < 0 ? -1.0 : 0.0
lxSignedVol = lxSgn * lxV
lxKyleCov = ta.sma(lxRet * lxSignedVol, lxImpLen) - ta.sma(lxRet, lxImpLen) * ta.sma(lxSignedVol, lxImpLen)
lxKyleVar = ta.variance(lxSignedVol, lxImpLen)
lxKyleSlope = lxUseVol and lxKyleVar > 0 ? math.abs(lxKyleCov / lxKyleVar) : na
lxKyleLam = lxKyleSlope

// --- anchored VWAP ---
lxSwLen = math.max(3, lxSwingStrength)
lxPH = ta.pivothigh(high, lxSwLen, lxSwLen)
lxPL = ta.pivotlow(low, lxSwLen, lxSwLen)
lxVolHiBar = ta.highest(nz(volSrc), lxMapLook)
lxIsNewSession = ta.change(time("D")) != 0
lxIsNewWeek    = ta.change(time("W")) != 0
lxIsNewMonth   = ta.change(time("M")) != 0
lxIsVolSpike   = not na(volSrc) and volSrc >= lxVolHiBar and volSrc > 0
lxReAnchor = false
if lxVwapAnchor == "Last major swing"
    lxReAnchor := not na(lxPH) or not na(lxPL)
else if lxVwapAnchor == "Session open"
    lxReAnchor := lxIsNewSession
else if lxVwapAnchor == "Week open"
    lxReAnchor := lxIsNewWeek
else if lxVwapAnchor == "Month open"
    lxReAnchor := lxIsNewMonth
else
    lxReAnchor := lxIsVolSpike
var float lxAvNum = na
var float lxAvDen = na
var float lxAvP2  = na
if lxReAnchor or na(lxAvNum)
    lxAvNum := 0.0
    lxAvDen := 0.0
    lxAvP2  := 0.0
lxAvWt = lxUseVol ? lxV : 1.0
lxAvNum := nz(lxAvNum) + hlc3 * lxAvWt
lxAvDen := nz(lxAvDen) + lxAvWt
lxAvP2  := nz(lxAvP2)  + hlc3 * hlc3 * lxAvWt
lxAvwap = lxAvDen > 0 ? lxAvNum / lxAvDen : na
lxVwSd  = lxAvDen > 0 ? math.sqrt(math.max(lxAvP2 / lxAvDen - lxAvwap * lxAvwap, 0.0)) : na
lxVwapWord = lxVwapAnchor == "Session open" ? "since today's open" : lxVwapAnchor == "Week open" ? "since this week" : lxVwapAnchor == "Month open" ? "since this month" : lxVwapAnchor == "Highest-volume bar" ? "since the big-volume bar" : "since the last major swing"
lxVwapSide = na(lxAvwap) ? "—" : close >= lxAvwap ? "above fair value" : "below fair value"
lxVwapSideCol = na(lxAvwap) ? color.gray : close >= lxAvwap ? cGreen : cRed
lxVwapRising = not na(lxAvwap) and not na(lxAvwap[1]) and lxAvwap >= lxAvwap[1]
lxVwapUp = not na(lxAvwap) and (close >= lxAvwap) and lxVwapRising
lxVwapDn = not na(lxAvwap) and (close < lxAvwap) and not lxVwapRising
lxVwapTrendCol = na(lxAvwap) ? color.gray : lxVwapUp ? cGreen : lxVwapDn ? cRed : cThin
var label lxVwapTag = na
if lxShowVwap and barstate.islast and not na(lxAvwap)
    label.delete(lxVwapTag)
    lxVwapTag := label.new(bar_index + 2, lxAvwap, "Fair value (" + lxVwapWord + ")", style=label.style_label_left, color=color.new(lxVwapTrendCol, 12), textcolor=txtOn(lxVwapTrendCol), size=labelTxtSize)

// =====================================================================
//  STRUCTURE — prior-day value area + naked POCs (cheap, per-bar)
//  A session-segmented volume-at-price (separate from the rolling liquidity
//  map). The completed day's POC/VAH/VAL become next session's reference S/R;
//  each day's POC is carried forward as a "naked" magnet until traded through.
// =====================================================================
stMapVA(m, st, pct) =>
    ks = map.keys(m)
    int nK = array.size(ks)
    float tot = 0.0
    float bestV = -1.0
    int bestK = 0
    int minK = nK > 0 ? array.get(ks, 0) : 0
    int maxK = nK > 0 ? array.get(ks, 0) : 0
    for i = 0 to nK - 1
        kk = array.get(ks, i)
        vv = map.get(m, kk)
        tot += vv
        if vv > bestV
            bestV := vv
            bestK := kk
        minK := math.min(minK, kk)
        maxK := math.max(maxK, kk)
    float acc = bestV
    int up = bestK
    int dn = bestK
    float target = tot * pct / 100.0
    span = maxK - minK + 2
    for n = 0 to span
        if acc >= target
            break
        upCan = up < maxK
        dnCan = dn > minK
        if not upCan and not dnCan
            break
        uV = upCan and map.contains(m, up + 1) ? map.get(m, up + 1) : 0.0
        dV = dnCan and map.contains(m, dn - 1) ? map.get(m, dn - 1) : 0.0
        if (uV >= dV and upCan) or not dnCan
            up += 1
            acc += uV
        else
            dn -= 1
            acc += dV
    [(bestK + 0.5) * st, (up + 1) * st, dn * st]

stStep = syminfo.mintick * stGrid
var map<int, float> stDMap = map.new<int, float>()
var float pdPOC = na
var float pdVAH = na
var float pdVAL = na
var float[] stNakPx   = array.new<float>(0)
var bool[]  stNakLive = array.new<bool>(0)
// on a new session, close out the completed day's profile -> prior-day VA + naked POC
if stPriorDay and lxIsNewSession and map.size(stDMap) > 0
    [dP, dH, dL] = stMapVA(stDMap, stStep, lxVaPct)
    pdPOC := dP
    pdVAH := dH
    pdVAL := dL
    map.clear(stDMap)
    if stNakedPoc and not na(pdPOC)
        bool straddled = false
        int lbk = math.min(20, bar_index)
        for kk = 0 to lbk
            if low[kk] <= pdPOC and high[kk] >= pdPOC
                straddled := true
                break
        if not straddled
            array.push(stNakPx, pdPOC)
            array.push(stNakLive, true)
            if array.size(stNakPx) > stMaxNaked
                array.shift(stNakPx)
                array.shift(stNakLive)
// accumulate the current session into the daily map
if stPriorDay and stStep > 0 and high >= low
    stVol = lxUseVol ? nz(lxV) : 1.0
    stRng = high - low
    stSub = stRng <= 0 ? 1 : int(math.min(8, int(stRng / stStep) + 1))
    stVper = stVol / stSub
    for s = 0 to stSub - 1
        stPx = stSub == 1 ? hlc3 : low + stRng * s / (stSub - 1)
        stK = int(math.floor(stPx / stStep))
        stPv = map.contains(stDMap, stK) ? map.get(stDMap, stK) : 0.0
        map.put(stDMap, stK, stPv + stVper)
// retire naked POCs once price trades back through them
if stNakedPoc and array.size(stNakPx) > 0
    for i = 0 to array.size(stNakPx) - 1
        if array.get(stNakLive, i) and low <= array.get(stNakPx, i) and high >= array.get(stNakPx, i)
            array.set(stNakLive, i, false)
// nearest live naked POC = magnet
float stMagnet = na
float stMagD = 1e20
if array.size(stNakPx) > 0
    for i = 0 to array.size(stNakPx) - 1
        if array.get(stNakLive, i)
            d = math.abs(array.get(stNakPx, i) - close)
            if d < stMagD
                stMagD := d
                stMagnet := array.get(stNakPx, i)

// --- draw prior-day VA + live naked POCs (last bar; lines/labels are budget-free) ---
var line[]  stLines  = array.new<line>()
var label[] stLabels = array.new<label>()
if stShowLevels and not compact and barstate.islast
    if array.size(stLines) > 0
        for ln in stLines
            line.delete(ln)
        array.clear(stLines)
    if array.size(stLabels) > 0
        for lb in stLabels
            label.delete(lb)
        array.clear(stLabels)
    stLX = bar_index - lxMapLook
    stRX = bar_index + 2
    if stPriorDay and not na(pdPOC)
        f_glowLine(stLines, stLX, stRX, pdPOC, cThin, line.style_dashed)
        array.push(stLabels, label.new(stRX, pdPOC, "PD POC", style=label.style_label_left, color=color.new(cThin, 15), textcolor=#0a0a0a, size=labelTxtSize))
        f_glowLine(stLines, stLX, stRX, pdVAH, cThin, line.style_dotted)
        f_glowLine(stLines, stLX, stRX, pdVAL, cThin, line.style_dotted)
        array.push(stLabels, label.new(stRX, pdVAH, "PD VAH", style=label.style_label_left, color=color.new(cThin, 35), textcolor=#0a0a0a, size=labelTxtSize))
        array.push(stLabels, label.new(stRX, pdVAL, "PD VAL", style=label.style_label_left, color=color.new(cThin, 35), textcolor=#0a0a0a, size=labelTxtSize))
    if stNakedPoc and array.size(stNakPx) > 0
        for i = 0 to array.size(stNakPx) - 1
            if array.get(stNakLive, i)
                yv = array.get(stNakPx, i)
                isMag = not na(stMagnet) and yv == stMagnet
                f_glowLine(stLines, stLX, stRX, yv, cAmber, line.style_dashed)
                if isMag
                    array.push(stLabels, label.new(stRX, yv, "MAGNET (naked POC)", style=label.style_label_left, color=color.new(cAmber, 10), textcolor=#0a0a0a, size=labelTxtSize))

lxAmiMean = ta.sma(lxAmiRaw, lxRankLen)
lxAmiSd   = ta.stdev(lxAmiRaw, lxRankLen)
lxIlliqJump = lxUseVol and not na(lxAmiSd) and lxAmiSd > 0 and (lxAmiRaw - lxAmiMean) / lxAmiSd >= 3.0

// --- order imbalance (tick-rule signed volume + autocorrelation) ---
lxClv = (lxH - lxL) != 0 ? ((lxC - lxL) - (lxH - lxC)) / (lxH - lxL) : 0.0
lxSv  = lxUseVol ? lxClv * lxV : lxClv
lxImbSum = math.sum(lxSv, lxImbLen)
lxVolSumRaw = math.sum(lxV, lxImbLen)
lxVolSum = lxUseVol ? lxVolSumRaw : lxImbLen
lxImbalance = lxVolSum != 0 ? lxImbSum / lxVolSum : 0.0

// --- percentiles & composite liquidity score (HIGH = liquid) ---
lxSpreadPct = ta.percentrank(lxSpreadP, lxRankLen)
lxAmihudPR  = ta.percentrank(lxAmihud, lxRankLen)
lxKylePR    = ta.percentrank(lxKyleLam, lxRankLen)
lxDepthPR   = ta.percentrank(ta.sma(lxDollarVol, lxImpLen), lxRankLen)
lxImpactPct = lxUseVol ? lxAmihudPR : na
lxKylePct   = lxUseVol ? lxKylePR : na
lxDepthProxy = lxUseVol ? lxDepthPR : na
lxIlliqBlend = lxUseVol ? math.avg(nz(lxSpreadPct,50), nz(lxImpactPct,50), nz(lxKylePct,50)) : nz(lxSpreadPct, 50)
lxLiqScore = 100 - lxIlliqBlend
lxLiqScore := lxUseVol and not na(lxDepthProxy) ? math.min(100, lxLiqScore*0.8 + lxDepthProxy*0.2) : lxLiqScore
lxState = lxIlliqJump ? "STRESSED" : lxLiqScore >= 66 ? "DEEP" : lxLiqScore >= 40 ? "NORMAL" : lxLiqScore >= 20 ? "THIN" : "STRESSED"
lxStateCol = lxState == "DEEP" ? cDeep : lxState == "NORMAL" ? cNorm : lxState == "THIN" ? cThin : cStress

// =====================================================================
//  SPATIAL LIQUIDITY MAP (volume-at-price -> S/R, walls, voids)
// =====================================================================
var box[]   lxZoneBoxes = array.new<box>()
var float[] lxBinVol = array.new<float>(lxMapBins, 0.0)
var line[]  lxSrLines  = array.new<line>()
var label[] lxSrLabels = array.new<label>()
var float lxThinAbove = na
var float lxThinBelow = na
lxHiN = ta.highest(high, lxMapLook)
lxLoN = ta.lowest(low, lxMapLook)
if lxShowMap and barstate.islast and not na(lxHiN) and not na(lxLoN) and lxHiN > lxLoN
    if array.size(lxZoneBoxes) > 0
        for i = 0 to array.size(lxZoneBoxes) - 1
            box.delete(array.get(lxZoneBoxes, i))
        array.clear(lxZoneBoxes)
    if array.size(lxSrLines) > 0
        for i = 0 to array.size(lxSrLines) - 1
            line.delete(array.get(lxSrLines, i))
        array.clear(lxSrLines)
    if array.size(lxSrLabels) > 0
        for i = 0 to array.size(lxSrLabels) - 1
            label.delete(array.get(lxSrLabels, i))
        array.clear(lxSrLabels)
    lxBinH = (lxHiN - lxLoN) / lxMapBins
    for b = 0 to lxMapBins - 1
        array.set(lxBinVol, b, 0.0)
    lxDecayK = lxDecayHL > 0 ? math.log(2.0) / lxDecayHL : 0.0
    for i = 0 to lxMapLook - 1
        lxBvRaw = lxUseVol ? nz(volSrc[i]) : 1.0
        lxWDecay = lxDecayHL > 0 ? math.exp(-lxDecayK * i) : 1.0
        lxBvW = lxBvRaw * lxWDecay
        if lxDistrib
            lxBhi = high[i]
            lxBlo = low[i]
            lxLoB = math.max(0, math.min(lxMapBins - 1, int(math.floor((lxBlo - lxLoN) / lxBinH))))
            lxHiB = math.max(0, math.min(lxMapBins - 1, int(math.floor((lxBhi - lxLoN) / lxBinH))))
            lxNb = lxHiB - lxLoB + 1
            lxShare = lxBvW / math.max(1, lxNb)
            for bb = lxLoB to lxHiB
                array.set(lxBinVol, bb, array.get(lxBinVol, bb) + lxShare)
        else
            lxMidp = (low[i] + high[i]) / 2
            lxBin = math.max(0, math.min(lxMapBins - 1, int(math.floor((lxMidp - lxLoN) / lxBinH))))
            array.set(lxBinVol, lxBin, array.get(lxBinVol, lxBin) + lxBvW)
    float lxVmax = array.max(lxBinVol)
    float lxVmin = array.min(lxBinVol)
    float lxVtot = array.sum(lxBinVol)
    int lxPocBin = array.indexof(lxBinVol, lxVmax)
    float lxVaVol = array.get(lxBinVol, lxPocBin)
    float lxVaTarget = lxVtot * lxVaPct / 100.0
    int lxVaUp = lxPocBin
    int lxVaDn = lxPocBin
    for _x = 0 to lxMapBins * 2
        if lxVaVol >= lxVaTarget
            break
        lxUpV = lxVaUp < lxMapBins - 1 ? array.get(lxBinVol, lxVaUp + 1) : -1.0
        lxDnV = lxVaDn > 0 ? array.get(lxBinVol, lxVaDn - 1) : -1.0
        if lxUpV < 0 and lxDnV < 0
            break
        if lxUpV >= lxDnV
            lxVaUp := lxVaUp + 1
            lxVaVol := lxVaVol + lxUpV
        else
            lxVaDn := lxVaDn - 1
            lxVaVol := lxVaVol + lxDnV
    lxPocY = lxLoN + (lxPocBin + 0.5) * lxBinH
    lxVahY = lxLoN + (lxVaUp + 1) * lxBinH
    lxValY = lxLoN + lxVaDn * lxBinH
    lxLeftX  = bar_index - lxMapLook
    lxRightX = bar_index + 2
    lxThinAbove := na
    lxThinBelow := na
    for b = 0 to lxMapBins - 1
        lxv = array.get(lxBinVol, b)
        lxFrac = lxVmax > lxVmin ? (lxv - lxVmin) / (lxVmax - lxVmin) : 0.0
        lxYTop = lxLoN + (b + 1) * lxBinH
        lxYBot = lxLoN + b * lxBinH
        lxZc   = lxLoN + (b + 0.5) * lxBinH
        lxIsThin = lxFrac * 100 <= lxThinPct
        lxAbove = lxZc > close
        col = color(na)
        if lxIsThin
            col := color.new(cDeep, 90)
        else
            t = math.round(86 - lxFrac*46)
            col := lxAbove ? color.new(cStress, t) : color.new(cGreen, t)
        if lxMapStyle == "Bands" and not lxIsThin
            col := lxAbove ? color.new(cStress, 84) : color.new(cGreen, 84)
        if not na(col) and (lxMapStyle == "Heatmap" or not lxIsThin)
            bx = box.new(lxLeftX, lxYTop, lxRightX, lxYBot, border_color=color.new(col, 96), bgcolor=col)
            array.push(lxZoneBoxes, bx)
        if lxIsThin
            if lxAbove and na(lxThinAbove)
                lxThinAbove := lxZc
            if not lxAbove
                lxThinBelow := lxZc
    float lxBestAboveV = 0.0
    float lxBestBelowV = 0.0
    float lxWallAboveY = na
    float lxWallBelowY = na
    for b = 0 to lxMapBins - 1
        lxv = array.get(lxBinVol, b)
        lxZc = lxLoN + (b + 0.5) * lxBinH
        if lxZc > close and lxv > lxBestAboveV
            lxBestAboveV := lxv
            lxWallAboveY := lxZc
        if lxZc < close and lxv > lxBestBelowV
            lxBestBelowV := lxv
            lxWallBelowY := lxZc
    lxResY = lxVahY > close ? lxVahY : lxWallAboveY
    lxSupY = lxValY < close ? lxValY : lxWallBelowY
    f_glowLine(lxSrLines, lxLeftX, lxRightX, lxPocY, cThin, line.style_dashed)
    lxPocLb = label.new(lxRightX, lxPocY, "POC — busiest price (fair value)", style=label.style_label_left, color=color.new(cThin, 15), textcolor=#0a0a0a, size=labelTxtSize)
    array.push(lxSrLabels, lxPocLb)
    if not na(lxResY)
        f_glowLine(lxSrLines, lxLeftX, lxRightX, lxResY, cStress, line.style_solid)
        lb = label.new(lxRightX, lxResY, "RESISTANCE — sellers here", style=label.style_label_left, color=color.new(cStress, 10), textcolor=color.white, size=labelTxtSize)
        array.push(lxSrLabels, lb)
    if not na(lxSupY)
        f_glowLine(lxSrLines, lxLeftX, lxRightX, lxSupY, cGreen, line.style_solid)
        lb2 = label.new(lxRightX, lxSupY, "SUPPORT — buyers here", style=label.style_label_left, color=color.new(cGreen, 10), textcolor=color.white, size=labelTxtSize)
        array.push(lxSrLabels, lb2)
    // nearest dense liquidity shelf above / below price (closest, not strongest)
    if lxShowNearLiq
        float lxNearA  = na
        float lxNearB  = na
        float lxNearAd = 1e20
        float lxNearBd = 1e20
        float lxNearAf = na
        float lxNearBf = na
        for b = 0 to lxMapBins - 1
            lxv = array.get(lxBinVol, b)
            lxFr = lxVmax > lxVmin ? (lxv - lxVmin) / (lxVmax - lxVmin) : 0.0
            lxZc = lxLoN + (b + 0.5) * lxBinH
            if lxFr * 100 >= lxLiqThr
                if lxZc > close and (lxZc - close) < lxNearAd
                    lxNearAd := lxZc - close
                    lxNearA  := lxZc
                    lxNearAf := lxFr
                if lxZc < close and (close - lxZc) < lxNearBd
                    lxNearBd := close - lxZc
                    lxNearB  := lxZc
                    lxNearBf := lxFr
        lxNearX = bar_index - math.min(40, lxMapLook)
        if not na(lxNearA)
            lxAtxt = "≈ LIQUIDITY ↑ " + str.tostring(lxNearA, format.mintick) + (nz(atr) > 0 ? "  +" + str.tostring(lxNearAd / atr, "#.0") + " ATR" : "") + "  · " + str.tostring(math.round(nz(lxNearAf) * 100)) + "%"
            f_glowLine(lxSrLines, lxNearX, lxRightX, lxNearA, cAmber, line.style_dotted)
            array.push(lxSrLabels, label.new(lxRightX, lxNearA, lxAtxt, style=label.style_label_left, color=color.new(cAmber, 0), textcolor=#0a0a0a, size=labelTxtSize))
        if not na(lxNearB)
            lxBtxt = "≈ LIQUIDITY ↓ " + str.tostring(lxNearB, format.mintick) + (nz(atr) > 0 ? "  −" + str.tostring(lxNearBd / atr, "#.0") + " ATR" : "") + "  · " + str.tostring(math.round(nz(lxNearBf) * 100)) + "%"
            f_glowLine(lxSrLines, lxNearX, lxRightX, lxNearB, cAmber, line.style_dotted)
            array.push(lxSrLabels, label.new(lxRightX, lxNearB, lxBtxt, style=label.style_label_left, color=color.new(cAmber, 0), textcolor=#0a0a0a, size=labelTxtSize))
    int lxStrongBin = 0
    int lxWeakBin = 0
    float lxSVal = -1.0
    float lxWVal = 1e18
    for b = 0 to lxMapBins - 1
        lxv = array.get(lxBinVol, b)
        if lxv > lxSVal
            lxSVal := lxv
            lxStrongBin := b
        if lxv < lxWVal
            lxWVal := lxv
            lxWeakBin := b
    lxWallY = lxLoN + (lxStrongBin + 0.5) * lxBinH
    lxOpenY = lxLoN + (lxWeakBin + 0.5) * lxBinH
    lxWallAbove = lxWallY > close
    lxTagWall = label.new(int(lxLeftX + lxMapLook*0.5), lxWallY, (lxWallAbove ? "⊏ WALL — hard to pass up" : "⊏ WALL — strong floor"), style=label.style_label_center, color=color.new(lxWallAbove ? cStress : cGreen, 25), textcolor=color.white, size=labelTxtSize)
    array.push(lxSrLabels, lxTagWall)
    lxTagOpen = label.new(int(lxLeftX + lxMapLook*0.5), lxOpenY, "open — price moves fast", style=label.style_label_center, color=color.new(color.gray, 35), textcolor=txtCol, size=labelTxtSize)
    array.push(lxSrLabels, lxTagOpen)
    if lxShowVoid
        lxVoidY = na(lxThinAbove) and na(lxThinBelow) ? na : not na(lxThinAbove) and (na(lxThinBelow) or (lxThinAbove - close) < (close - lxThinBelow)) ? lxThinAbove : lxThinBelow
        if not na(lxVoidY)
            vLab = label.new(lxRightX, lxVoidY, "◎ likely pull toward here", style=label.style_label_left, color=color.new(cNorm, 20), textcolor=color.white, size=labelTxtSize)
            array.push(lxSrLabels, vLab)

// =====================================================================
//  DECISION LAYER (volatility-aware)
// =====================================================================
lxPv = lxTickVal > 0 ? lxTickVal : syminfo.pointvalue
lxHalfSpread = lxSpreadP * close / 2.0
lxVolTimePts = lxVolAdjOn and lxVolReady ? lxVolTimingK * perBarFcast * close : 0.0
lxSlipPts = lxHalfSpread + lxVolTimePts
lxSlipCcy = lxSlipPts * lxPv
lxLiqSizeMult = lxState == "DEEP" ? 1.0 : lxState == "NORMAL" ? 0.75 : lxState == "THIN" ? 0.4 : 0.0
lxVolSizeMult = not (lxVolAdjOn and lxVolReady) ? 1.0 : lxVolRegime == "Low" ? 1.0 : lxVolRegime == "Normal" ? 0.85 : lxVolRegime == "High" ? 0.6 : 0.35
lxSizeMult = math.min(lxLiqSizeMult, lxVolSizeMult)
lxSizeBound = not (lxVolAdjOn and lxVolReady) ? "liquidity" : lxVolSizeMult < lxLiqSizeMult ? "vol-limited" : lxLiqSizeMult < lxVolSizeMult ? "liquidity-limited" : "both"
lxOrderAdvice = lxState == "DEEP" ? "Market OK" : lxState == "NORMAL" ? "Limit preferred" : lxState == "THIN" ? "Limit only · expect slippage" : "Stand aside / minimal size"
lxTravelTxt = na(lxThinAbove) and na(lxThinBelow) ? "balanced" : not na(lxThinAbove) and (na(lxThinBelow) or (lxThinAbove - close) < (close - lxThinBelow)) ? "thin above → breakout fuel" : "thin below → air-pocket risk"
lxImbTxt = lxImbalance > 0.15 ? "▲ buyers" : lxImbalance < -0.15 ? "▼ sellers" : "balanced"
lxImbCol = lxImbalance > 0.15 ? cGreen : lxImbalance < -0.15 ? cRed : color.gray
lxContext = lxState == "STRESSED" ? "High risk — reduce / wait" : (lxVolAdjOn and lxVolReady and lxVolRegime == "Extreme") ? "Extreme vol — trade small / wait" : (lxState == "THIN" and (lxVolRegime == "High" or lxVolRegime == "Extreme")) ? "Air-pocket risk — thin & volatile" : (lxState == "THIN" and lxVolRegime == "Low") ? "Complacent — gap risk on thin liquidity" : ((lxState == "DEEP" or lxState == "NORMAL") and lxVolRegime == "High") ? "Orderly volatility — tradeable" : "Normal conditions"
lxContextCol = str.contains(lxContext, "risk") or str.contains(lxContext, "wait") or str.contains(lxContext, "Air-pocket") ? cRed : str.contains(lxContext, "Orderly") ? cAmber : str.contains(lxContext, "Complacent") ? cAmber : cGreen
lxLiqWord = lxState == "DEEP" ? "Good" : lxState == "NORMAL" ? "OK" : lxState == "THIN" ? "Thin" : "Poor"
lxCostWord = lxSpreadPct >= 66 ? "High" : lxSpreadPct >= 40 ? "Medium" : "Low"
lxPressWord = lxImbalance > 0.15 ? "Buyers in control" : lxImbalance < -0.15 ? "Sellers in control" : "Evenly matched"
lxSizeWord = lxSizeMult >= 1.0 ? "Full" : lxSizeMult >= 0.75 ? "Most" : lxSizeMult >= 0.4 ? "Half" : "Wait"
lxSizeCol  = lxSizeMult >= 0.75 ? cGreen : lxSizeMult >= 0.4 ? cAmber : cRed
lxOrderWord = lxState == "DEEP" ? "Market is fine" : lxState == "NORMAL" ? "Use limit orders" : lxState == "THIN" ? "Limit orders only" : "Wait for liquidity"
lxVerdict = lxState == "STRESSED" ? "Poor liquidity — best to wait" : (lxVolAdjOn and lxVolReady and lxVolRegime == "Extreme") ? "Volatile — trade small, limits only" : (lxState == "THIN" ? "Thin liquidity — trade small with limit orders" : (lxSizeWord + " size, " + str.lower(lxPressWord) + ", " + str.lower(lxOrderWord)))
lxVerdictCol = lxStateCol

// =====================================================================
//  LIQUIDITY PLOTS (trimmed: VWAP core+glow, illiq mark, key internals)
// =====================================================================
lxVwapPlot = lxShowVwap and not na(lxAvwap) ? lxAvwap : na
// σ-deviation band levels (same anchor, same σ). 0.5σ and 1.5σ steps are
// invisible anchors that let the heat fill build a smooth gradient.
lxBandsOn = lxShowVwap and lxShowBands and not compact and not na(lxAvwap) and not na(lxVwSd) and lxVwSd > 0
lxBU1 = lxBandsOn ? lxAvwap + lxVwSd * lxBandMult1            : na
lxBL1 = lxBandsOn ? lxAvwap - lxVwSd * lxBandMult1            : na
lxBU2 = lxBandsOn ? lxAvwap + lxVwSd * lxBandMult2            : na
lxBL2 = lxBandsOn ? lxAvwap - lxVwSd * lxBandMult2            : na
lxBUe = lxBandsOn ? lxAvwap + lxVwSd * lxBandMult1 * 0.5      : na
lxBLe = lxBandsOn ? lxAvwap - lxVwSd * lxBandMult1 * 0.5      : na
lxBUm = lxBandsOn ? lxAvwap + lxVwSd * (lxBandMult1 + lxBandMult2) * 0.5 : na
lxBLm = lxBandsOn ? lxAvwap - lxVwSd * (lxBandMult1 + lxBandMult2) * 0.5 : na
plot(useGlow ? lxVwapPlot : na, "Fair value glow", color=color.new(lxVwapTrendCol, 70), linewidth=5, style=plot.style_line)
pLxMid = plot(lxVwapPlot, "Fair value (Anchored VWAP)", color=color.new(lxVwapTrendCol, 0), linewidth=2, style=plot.style_line)
pLxUe = plot(lxBUe, "VWAP +0.5σ", color=na)
pLxLe = plot(lxBLe, "VWAP -0.5σ", color=na)
pLxU1 = plot(lxBU1, "VWAP +1σ", color=color.new(lxVwapTrendCol, 35))
pLxL1 = plot(lxBL1, "VWAP -1σ", color=color.new(lxVwapTrendCol, 35))
pLxUm = plot(lxBUm, "VWAP +1.5σ", color=na)
pLxLm = plot(lxBLm, "VWAP -1.5σ", color=na)
pLxU2 = plot(lxBU2, "VWAP +2σ", color=color.new(lxVwapTrendCol, 45))
pLxL2 = plot(lxBL2, "VWAP -2σ", color=color.new(lxVwapTrendCol, 45))
// Heat fill: red above fair value, green below, denser toward ±2σ. Neon glow
// = single-colour halo fading outward. Off = edges only. (fill() is budget-free)
lxFc(int seg, bool up) =>
    lxBandFill == "Off" ? na : lxBandFill == "Reversion heat" ? color.new(up ? cRed : cGreen, 85 - seg * 13) : color.new(lxVwapTrendCol, math.min(96, 80 + seg * 5))
fill(pLxMid, pLxUe, lxFc(0, true),  title="VWAP fill 0.5σ up")
fill(pLxMid, pLxLe, lxFc(0, false), title="VWAP fill 0.5σ dn")
fill(pLxUe,  pLxU1, lxFc(1, true),  title="VWAP fill 1σ up")
fill(pLxLe,  pLxL1, lxFc(1, false), title="VWAP fill 1σ dn")
fill(pLxU1,  pLxUm, lxFc(2, true),  title="VWAP fill 1.5σ up")
fill(pLxL1,  pLxLm, lxFc(2, false), title="VWAP fill 1.5σ dn")
fill(pLxUm,  pLxU2, lxFc(3, true),  title="VWAP fill 2σ up")
fill(pLxLm,  pLxL2, lxFc(3, false), title="VWAP fill 2σ dn")
plotchar(lxIlliqJump, "Illiquidity jump", "✦", location.abovebar, color=cStress, size=size.tiny)
plot(lxSpreadBps, "Spread (bps, vol-adj)", display=display.data_window)
plot(lxLiqScore,  "Liquidity score", display=display.data_window)
plot(lxUseVol ? lxKyleLam : na, "Impact slope (lambda)", display=display.data_window)
plot(lxVolReady ? perBarFcast * 10000.0 : na, "Vol forecast (bps/bar)", display=display.data_window)

// =====================================================================
//  TRADE SIGNALS  (release + flow-confirmed direction + executable liquidity)
//  Bold/bright BUY-SELL markers (glow + solid core) plus text labels.
// =====================================================================
// --- per-bar S/R ladder from structure + VWAP/σ levels (cheap; every bar) ---
stLvls = array.new<float>(0)
if not na(pdVAH)
    array.push(stLvls, pdVAH)
if not na(pdVAL)
    array.push(stLvls, pdVAL)
if not na(pdPOC)
    array.push(stLvls, pdPOC)
if stNakedPoc and array.size(stNakPx) > 0
    for i = 0 to array.size(stNakPx) - 1
        if array.get(stNakLive, i)
            array.push(stLvls, array.get(stNakPx, i))
if not na(lxAvwap)
    array.push(stLvls, lxAvwap)
float stR1 = na
float stS1 = na
float stRd = 1e20
float stSd = 1e20
if array.size(stLvls) > 0
    for i = 0 to array.size(stLvls) - 1
        lv = array.get(stLvls, i)
        dd = lv - close
        if dd > 0 and dd < stRd
            stRd := dd
            stR1 := lv
        if dd < 0 and -dd < stSd
            stSd := -dd
            stS1 := lv
locBuf = stLocBufATR * nz(atr)
longLocated  = na(stR1) or (stR1 - close) >= locBuf   // room up to resistance
shortLocated = na(stS1) or (close - stS1) >= locBuf   // room down to support

liqExecOK  = not tradeReqLiq or (lxState != "STRESSED")
rawLong  = showSig and ev and relUp and liqExecOK
rawShort = showSig and ev and not relUp and liqExecOK
tradeLong  = rawLong  and (not tradeReqLoc or longLocated)
tradeShort = rawShort and (not tradeReqLoc or shortLocated)
plotshape(tradeLong and useGlow,  "BUY glow",  style=shape.triangleup,   location=location.belowbar, color=color.new(cGreen, 55), size=size.large)
plotshape(tradeLong,  "BUY",       style=shape.triangleup,   location=location.belowbar, color=color.new(cGreen, 0),  size=size.normal)
plotshape(tradeShort and useGlow, "SELL glow", style=shape.triangledown, location=location.abovebar, color=color.new(cRed, 55),   size=size.large)
plotshape(tradeShort, "SELL",      style=shape.triangledown, location=location.abovebar, color=color.new(cRed, 0),    size=size.normal)
if tradeLong
    label.new(bar_index, low,  "BUY",  style=label.style_label_up,   color=cGreen, textcolor=color.white, size=labelTxtSize)
if tradeShort
    label.new(bar_index, high, "SELL", style=label.style_label_down, color=cRed,   textcolor=color.white, size=labelTxtSize)

// =====================================================================
//  UNIFIED DECISION TABLE  (Compact default / Pro) — all three layers
// =====================================================================
tradeTxt = tradeLong ? "▲ BUY" : tradeShort ? "▼ SELL" : (rawLong and not longLocated) ? "long · into resistance" : (rawShort and not shortLocated) ? "short · into support" : (ev and not liqExecOK ? "signal · too illiquid" : loaded ? "LOADED — wait" : pPct >= 60 ? "BUILDING" : "WAIT — no edge")
tradeCol = tradeLong ? cGreen : tradeShort ? cRed : ((ev and (not liqExecOK or not longLocated or not shortLocated)) or loaded ? cAmber : color.gray)
isPro = panelMode == "Pro"
if showPnl and barstate.islast
    table.cell(pnl, 0, 0, "VFL ENGINE", text_color=txtCol, text_size=panelBigSize, bgcolor=hdrBg, text_halign=text.align_left)
    table.cell(pnl, 1, 0, timeframe.period + " · " + syminfo.ticker, text_color=txtDim, text_size=panelTxtSize, bgcolor=hdrBg, text_halign=text.align_right)
    int ri = 1
    table.cell(pnl, 0, ri, "TRADE", text_color=txtCol, text_size=panelBigSize, text_halign=text.align_left, bgcolor=color.new(tradeCol, 35))
    table.cell(pnl, 1, ri, tradeTxt, text_color=txtOn(tradeCol), text_size=panelBigSize, text_halign=text.align_right, bgcolor=color.new(tradeCol, 0))
    ri := ri + 1
    if not isPro
        prow(ri, "Type · dir",  (feedOK ? typ : "—") + " · " + dirTxt, relUp ? cGreen : cRed)
        ri := ri + 1
        prow(ri, "Order flow",  useOF ? ((ofBias > 0 ? "▲" : ofBias < 0 ? "▼" : "•") + " " + str.tostring(ofZ, "#.0") + "σ" + (ofConfirm ? " ✓" : "")) : "off", useOF ? ofCol : color.gray)
        ri := ri + 1
        prow(ri, "Pressure",    str.tostring(math.round(pressure)) + " · " + weatherTxt, pressure >= detThr ? cRed : pressure >= critThr ? cAmber : color.gray)
        ri := ri + 1
        prow(ri, "Regime",      useReg ? regimeStr : "off", useReg ? regimeCol : color.gray)
        ri := ri + 1
        prow(ri, "Liquidity",   lxLiqWord + " · cost " + lxCostWord, lxStateCol)
        ri := ri + 1
        prow(ri, "Size · order", lxSizeWord + " · " + lxOrderWord, lxSizeCol)
        ri := ri + 1
        prow(ri, "Move",        moveSize + " ≈" + str.tostring(expATR, "#.0") + " ATR (" + str.tostring(math.round(expPts)) + "pt)", blast >= 80 ? cRed : blast >= 60 ? cAmber : color.gray)
        ri := ri + 1
        prow(ri, "Fair value",  lxVwapSide, lxVwapSideCol)
        ri := ri + 1
        prow(ri, "S/R",         (na(stR1) ? "—" : str.tostring(stR1, format.mintick)) + " ↑  ↓ " + (na(stS1) ? "—" : str.tostring(stS1, format.mintick)), (not na(stR1) and not na(stS1)) ? (close <= (stR1 + stS1) / 2 ? cGreen : cRed) : cThin)
        ri := ri + 1
        table.cell(pnl, 0, ri, "→ " + lxVerdict, text_color=txtOn(lxVerdictCol), text_size=panelTxtSize, text_halign=text.align_left, bgcolor=color.new(lxVerdictCol, 20))
        table.cell(pnl, 1, ri, "", bgcolor=color.new(lxVerdictCol, 20))
        ri := ri + 1
    else
        prow(ri, "Direction",   dirTxt, relUp ? cGreen : cRed)
        ri := ri + 1
        prow(ri, "Type",        feedOK ? typ : "—", typCol)
        ri := ri + 1
        prow(ri, "Order flow",  useOF ? ((ofBias > 0 ? "▲" : ofBias < 0 ? "▼" : "•") + " " + str.tostring(ofZ, "#.0") + "σ · CVD" + (ofCvdUp ? "↑" : "↓") + (ofConfirm ? " ✓" : (needOF and ofBias == -sigDir ? " ✗veto" : ""))) : "off", useOF ? ofCol : color.gray)
        ri := ri + 1
        prow(ri, "Phase",       phaseStr, phaseCol)
        ri := ri + 1
        prow(ri, "Regime",      useReg ? (regimeStr + " (VR " + str.tostring(vr, "#.00") + ")") : "off", useReg ? regimeCol : color.gray)
        ri := ri + 1
        prow(ri, "Energy",      str.tostring(energy, "#.0") + " " + barStr(energy * 10), energy >= 7 ? cRed : energy >= 4 ? cAmber : color.gray)
        ri := ri + 1
        prow(ri, "Pressure",    str.tostring(math.round(pressure)) + " " + barStr(pressure) + " " + weatherTxt, pressure >= detThr ? cRed : pressure >= critThr ? cAmber : color.gray)
        ri := ri + 1
        prow(ri, "Loaded %ile", str.tostring(math.round(pPct)) + (pPct >= sigPct ? "  ✓" : "  ·"), pPct >= sigPct ? cGreen : color.gray)
        ri := ri + 1
        prow(ri, "Move size",   moveSize + " · ≈" + str.tostring(expATR, "#.0") + " ATR (" + str.tostring(math.round(expPts)) + "pt)", blast >= 80 ? cRed : blast >= 60 ? cAmber : color.gray)
        ri := ri + 1
        prow(ri, "Vol forecast", volFcastReady ? (str.tostring(rvForecast, "#.0") + "%" + (useVol ? " vs VIX " + str.tostring(vixR, "#.0") + "%" : "")) : "warming…", volFcastReady ? ((useVol and rvForecast > vixR) ? cRed : cExpand) : color.gray)
        ri := ri + 1
        prow(ri, "Path-vol fit", volFcastReady ? (str.tostring(math.round(nz(fitPct))) + "% · " + fitWord) : "warming…", volFcastReady ? fitCol : color.gray)
        ri := ri + 1
        prow(ri, "Trend align", useConf ? (str.tostring(agreeN) + "/4 " + (sigDir > 0 ? "▲" : "▼")) : "off", useConf ? (aligned ? cGreen : color.gray) : color.gray)
        ri := ri + 1
        prow(ri, "Triggers",    str.tostring(dnTrig, format.mintick) + " / " + str.tostring(upTrig, format.mintick), color.new(cExpand, 20))
        ri := ri + 1
        prow(ri, "Liquidity",   str.tostring(math.round(lxLiqScore)) + "/100 · " + lxState, lxStateCol)
        ri := ri + 1
        prow(ri, "Spread",      str.tostring(lxSpreadBps, "#.##") + " bps" + (lxVolShrink > 0 ? " ·adj" : ""), lxSpreadPct >= 66 ? cRed : lxSpreadPct >= 40 ? cAmber : cGreen)
        ri := ri + 1
        prow(ri, "Illiquidity %ile", lxUseVol ? (str.tostring(math.round(nz(lxImpactPct))) + " %ile") : "no volume", not lxUseVol ? color.gray : lxImpactPct >= 66 ? cRed : lxImpactPct >= 40 ? cAmber : cGreen)
        ri := ri + 1
        prow(ri, "Impact slope λ", lxUseVol ? (str.tostring(math.round(nz(lxKylePct))) + " %ile") : "no volume", not lxUseVol ? color.gray : lxKylePct >= 66 ? cRed : cGreen)
        ri := ri + 1
        prow(ri, "Depth",       lxUseVol ? (str.tostring(math.round(nz(lxDepthProxy))) + " %ile") : "no volume", not lxUseVol ? color.gray : lxDepthProxy >= 50 ? cGreen : cAmber)
        ri := ri + 1
        prow(ri, "Imbalance",   lxImbTxt + " (" + str.tostring(lxImbalance, "#.00") + ")", lxImbCol)
        ri := ri + 1
        prow(ri, "Est. slippage", str.tostring(lxSlipPts, format.mintick) + (lxPv > 0 ? " (" + str.tostring(lxSlipCcy, "#.##") + ")" : "") + (lxVolTimePts > 0 ? " +vol" : ""), lxSpreadPct >= 50 ? cAmber : cGreen)
        ri := ri + 1
        prow(ri, "Suggest size", lxSizeMult == 0 ? "skip" : "×" + str.tostring(lxSizeMult, "#.0#") + " of " + str.tostring(lxRiskPct, "#.0#") + "% · " + lxSizeBound, lxSizeMult >= 0.75 ? cGreen : lxSizeMult >= 0.4 ? cAmber : cRed)
        ri := ri + 1
        prow(ri, "Order type",  lxOrderAdvice, lxState == "DEEP" ? cGreen : lxState == "STRESSED" ? cRed : cAmber)
        ri := ri + 1
        prow(ri, "Context",     lxContext, lxContextCol)
        ri := ri + 1
        prow(ri, "Air-pockets", lxTravelTxt, str.contains(lxTravelTxt, "above") ? cGreen : str.contains(lxTravelTxt, "below") ? cRed : color.gray)
        ri := ri + 1
        prow(ri, "Fair value",  na(lxAvwap) ? "—" : str.tostring(lxAvwap, format.mintick) + " · " + lxVwapSide, lxVwapSideCol)
        ri := ri + 1
        prow(ri, "Prior-day VA", (na(pdPOC) ? "—" : "POC " + str.tostring(pdPOC, format.mintick)) + (na(pdVAH) ? "" : " · " + str.tostring(pdVAL, format.mintick) + "–" + str.tostring(pdVAH, format.mintick)), na(pdPOC) ? color.gray : (close > pdVAH ? cRed : close < pdVAL ? cGreen : cThin))
        ri := ri + 1
        prow(ri, "Resist / Supp", (na(stR1) ? "—" : str.tostring(stR1, format.mintick)) + " / " + (na(stS1) ? "—" : str.tostring(stS1, format.mintick)), (not na(stR1) and not na(stS1)) ? (close <= (stR1 + stS1) / 2 ? cGreen : cRed) : cThin)
        ri := ri + 1
        prow(ri, "Magnet (naked POC)", na(stMagnet) ? "none live" : str.tostring(stMagnet, format.mintick), na(stMagnet) ? color.gray : cThin)
        ri := ri + 1
        prow(ri, "Location", tradeLong ? "long · clear ↑" : tradeShort ? "short · clear ↓" : (rawLong and not longLocated) ? "long blocked ↑" : (rawShort and not shortLocated) ? "short blocked ↓" : "—", tradeLong ? cGreen : tradeShort ? cRed : (rawLong or rawShort) ? cAmber : color.gray)
        ri := ri + 1
        prow(ri, "Hit% all*",   na(reliability) ? "building…" : str.tostring(math.round(reliability)) + "% (" + str.tostring(sigN) + ")", color.new(cGreen, 18))
        ri := ri + 1
        prow(ri, "Gamma*",      statStr(nG, hG, fG, aG), color.new(cGamma, 18))
        ri := ri + 1
        prow(ri, "Squeeze*",    statStr(nS, hS, fS, aS), color.new(cSqueeze, 18))
        ri := ri + 1
        prow(ri, "Expansion*",  statStr(nE, hE, fE, aE), color.new(cExpand, 18))
        ri := ri + 1
        prow(ri, "WF early/late*", (nEarly > 0 ? str.tostring(math.round(hEarly / nEarly * 100)) + "%(" + str.tostring(nEarly) + ")" : "—") + " / " + (nLate > 0 ? str.tostring(math.round(hLate / nLate * 100)) + "%(" + str.tostring(nLate) + ")" : "—"), color.new(color.gray, 18))
        ri := ri + 1
        prow(ri, "DNA C/D/B/X/I", str.tostring(math.round(fComp)) + "/" + str.tostring(math.round(fDisl)) + "/" + str.tostring(math.round(fBas)) + "/" + str.tostring(math.round(fCvx)) + "/" + str.tostring(math.round(100 - er*100)), color.new(color.gray, 18))
        ri := ri + 1

// --- combined trade alert ---
alertcondition(tradeLong,  "VFL BUY",  "VFL BUY on {{ticker}} {{interval}} — pressure release, flow-confirmed up, liquidity OK")
alertcondition(tradeShort, "VFL SELL", "VFL SELL on {{ticker}} {{interval}} — pressure release, flow-confirmed down, liquidity OK")

// --- map legend ---
var label lxLegA = na
if lxShowMap and barstate.islast and not na(lxHiN)
    label.delete(lxLegA)
    lxLegTxt = "GREEN below = support (buyers)   ·   RED above = resistance (sellers)\nSolid colour = a WALL price struggles at   ·   faint = open road, price moves fast"
    lxLegA := label.new(bar_index - lxMapLook, lxHiN, lxLegTxt, style=label.style_label_lower_right,
         color=color.new(chart.bg_color, 15), textcolor=txtCol, size=labelTxtSize, textalign=text.align_left)

// --- liquidity alerts ---
var string lxPrevState = na
lxStateChanged = not na(lxPrevState) and lxPrevState != lxState
if barstate.isconfirmed
    lxPrevState := lxState
alertcondition(lxIlliqJump and not lxIlliqJump[1], "Liquidity withdrawal", "VFL: sudden liquidity withdrawal on {{ticker}} {{interval}}")
alertcondition(lxStateChanged, "Liquidity regime change", "VFL: liquidity regime changed on {{ticker}} {{interval}}")

// =====================================================================
//  LEGEND KEY — what each line / marker on the chart means (theme-adaptive)
// =====================================================================
keyP = keyPos == "Top Right" ? position.top_right : keyPos == "Top Left" ? position.top_left : keyPos == "Bottom Right" ? position.bottom_right : position.bottom_left
var table keyT = table.new(keyP, 2, 12, border_width=1, frame_width=1, frame_color=frameCol)
f_key(r, sc, meaning) =>
    kbg = r % 2 == 0 ? panelBg : rowAlt
    table.cell(keyT, 0, r, "▬", text_color=sc, text_size=size.normal, text_halign=text.align_center, bgcolor=kbg)
    table.cell(keyT, 1, r, meaning, text_color=txtDim, text_size=size.tiny, text_halign=text.align_left, bgcolor=kbg)
if showKey and not compact and barstate.islast
    table.cell(keyT, 0, 0, "KEY", text_color=txtCol, text_size=size.small, text_halign=text.align_center, bgcolor=hdrBg)
    table.cell(keyT, 1, 0, "signal / line", text_color=txtDim, text_size=size.tiny, text_halign=text.align_left, bgcolor=hdrBg)
    int kr = 1
    f_key(kr, cGreen,  "BUY — flow-confirmed, located long")
    kr += 1
    f_key(kr, cStress, "SELL — flow-confirmed, located short")
    kr += 1
    f_key(kr, cGreen,  "Support shelf (value-area low / volume wall)")
    kr += 1
    f_key(kr, cStress, "Resistance shelf (value-area high / volume wall)")
    kr += 1
    f_key(kr, cThin,   "POC · PD POC / VAH-VAL — prior value reference")
    kr += 1
    f_key(kr, cAmber,  "Naked-POC magnet · nearest liquidity shelf")
    kr += 1
    f_key(kr, cNorm,   "Liquidity void — likely magnet / fast travel")
    kr += 1
    f_key(kr, lxVwapTrendCol, "Fair value (anchored VWAP) + σ bands")
    kr += 1
    f_key(kr, cExpand, "Trigger lines — where a release confirms")
    kr += 1
    f_key(kr, cGamma,  "⚡ expiry session · regime ribbon at chart base")
    kr += 1
````
