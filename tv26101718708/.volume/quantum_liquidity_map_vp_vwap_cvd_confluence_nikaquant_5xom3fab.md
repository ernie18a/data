# Quantum Liquidity Map - VP, VWAP & CVD Confluence [NikaQuant]

- url: https://www.tradingview.com/script/5xom3FAB-Quantum-Liquidity-Map-VP-VWAP-CVD-Confluence-NikaQuant/
- type: indicator
- pine_id: PUB;fec72930c36e44678cbc70fdffc6f58d
- version: 2.0

## Description

Info:

An overlay that combines three institutional order-flow methods — visible-range Volume Profile, session-anchored VWAP with standard-deviation bands, and Cumulative Volume Delta with divergence detection — into one coordinated tool for reading liquidity and order-flow conviction.

## Why This Combination Exists

Each of the three methods answers a different question about price, and none of them can answer the others alone. Volume Profile answers "where has the market actually traded?" — it locates the price levels participants have defended with size. Anchored VWAP answers "how far is the current price from the session's true volume-weighted average?" — it measures stretch from fair value. CVD divergence answers "is this move real?" — it exposes when a new price high or low is being printed on weakening order-flow pressure.

Used in isolation, each method produces false signals. A Value Area edge can be tagged without any participation. A VWAP band touch can continue for hours without mean-reverting. A CVD divergence can fire in a vacuum away from any structural level. The coordination is the entire point of this script: a Value Area edge touched while price is already two standard deviations stretched from VWAP, with a confirmed CVD divergence printing at the same bar — three independent systems agreeing — is a structurally different event than any one of them firing alone. The script exists to make that specific confluence visible in a single overlay without chart clutter or flipping between tools.

## How It Works

Volume Profile — The visible range is split into horizontal price buckets. Each completed bar's volume is distributed into the bucket containing its midpoint. The highest-volume bucket becomes the Point of Control (POC). From the POC outward, buckets are added alternately above and below (whichever neighbour carries more volume) until a configurable percentage of total volume is captured — 70% by default, following the CBOT value-area method. The upper and lower boundaries of that expansion become Value Area High (VAH) and Value Area Low (VAL). A previous-session POC that current price has not yet revisited is drawn as a "naked POC" — an untested volume cluster that tends to act as a magnet.

Anchored VWAP — The volume-weighted average price is calculated from scratch each time the anchor period resets (thirteen anchor options from one hour through yearly). Two standard-deviation bands are derived from the running variance of the weighted price distribution, with multipliers adjustable for both the inner and outer bands. Bands are deliberately suppressed for the first five bars of every new anchor period, because variance is mathematically unstable immediately after a reset and early spikes would be misleading.

CVD Divergence — Cumulative Volume Delta is estimated per bar using the close-location-within-range method: a bar that closes near its high is interpreted as predominantly buy-driven, one that closes near its low as sell-driven, and the net difference is summed across the session. Structural swing highs and lows are detected with equal left and right confirmation windows, which prevents repainting because a pivot is only recognised once both sides are closed. A divergence is flagged only when three conditions are met: (1) price prints a new swing extreme relative to the previous one, (2) the CVD value at that swing fails to confirm the new extreme, and (3) the swing itself exceeds 1.5 times the 14-bar Average True Range. The ATR gate is the key noise filter — it throws out minor pivots that would otherwise generate meaningless divergences during tight consolidations.

## How To Use It

- Start with the profile: locate POC, VAH, and VAL. These are the decision levels.
- Check the VWAP band zone (shown live in the dashboard). Inside ±1 standard deviation of VWAP, price is near fair value. Beyond ±2 standard deviations, it is statistically stretched and mean-reversion odds improve.
- Look for confluence at profile levels. A rejection candle at VAH while price is also outside the +2 standard deviation band on VWAP and a bearish CVD divergence has just fired is the highest-probability setup the indicator produces. The inverse applies at VAL.
- A naked POC tag accompanied by CVD trending in the same direction as the test is more likely to hold than one where CVD disagrees.
- Recommended timeframes: 5-minute through 4-hour for intraday; 1-hour through daily for swing. The VWAP anchor period should match the trading horizon — Session for intraday, Weekly or Monthly for swing.
- Recommended markets: liquid futures, major FX pairs, large-cap equities, and liquid crypto perpetuals — any market where per-bar volume is meaningful enough for the close-location-within-range buy/sell estimate to be informative.
- Avoid using on illiquid symbols where volume is sparse or spiky, and on non-standard chart types (Heikin Ashi, Renko, Kagi, Point & Figure, Range) — they distort both the profile inputs and the CVD calculation.

## Settings

- Profile Rows (default 60): number of horizontal buckets. Higher values give finer resolution at the cost of more noise per bucket.
- Value Area % (default 0.70): volume percentage that defines the value area, following the CBOT convention.
- Lookback Bars (default 48): how many completed bars of history feed the profile.
- Show Naked POC (default on): draws previous-session POCs that current price has not yet revisited.
- Profile Width (default 0.30): horizontal footprint of the heatmap as a fraction of the lookback window.
- CVD Pivot Lookback (default 5): bars required on each side to confirm a swing. Higher values produce fewer but stronger divergence signals.
- VWAP Period (default Session): anchor period from one hour through yearly.
- Inner SD Multiplier (default 1.0) and Outer SD Multiplier (default 2.0): standard-deviation band widths.
- Dashboard position, size, and dark-mode toggle: cosmetic only.

## Alerts

Four alert conditions are included, each with a JSON payload suitable for webhook routing:
- Price touches POC (within half an ATR)
- Price enters the VAH zone
- Price enters the VAL zone
- CVD divergence detected (bullish or bearish)

## Notes

- Non-repainting. Divergence signals fire only on confirmed (closed) bars and require both-sided pivot confirmation. The profile, VWAP and CVD values use historical bar data only, with no lookahead.
- The CVD estimate is range-based (close-location-within-range), not tick-based. On very short timeframes, where a single bar can contain many aggressive sweeps, this is an approximation of true order flow — it correlates well with tick CVD on liquid instruments but is not a substitute for it on sub-minute scalping.
- Overlay indicator, pinned to the right scale. Pine Script v6.
─────────────────────────────────────────
════════════════════════

## Source Code

````pine
//@version=6
// ============================================================
//  Quantum Liquidity Map V3.0 — Championship Edition [NikaQuant]
//  Author : NikaQuant
//  Version: 3.0
//
//  Institutional-grade liquidity analysis overlay:
//  • Volume Profile heatmap with CBOT value-area expansion
//  • HVN / LVN auto-detection (magnet levels / fast-travel zones)
//  • Previous Session POC/VAH/VAL anchors + Naked-POC tracking
//  • Developing POC (dPOC) — live intra-session auction tracker
//  • Initial Balance (IBH/IBL) with 50% / 100% extensions
//  • Liquidity Sweep detection (failed breakouts / stop hunts)
//  • Volume Spike markers (institutional footprints)
//  • Relative Volume vs 20-bar average
//  • Manual VWAP (13 anchor periods) with SD bands
//  • Session CVD with ATR-filtered pivot divergence
//  • Confluence Score (0–100) — multi-system composite
//  • Session Type (Balance / Trend / Rotation)
//  • Auction Shape (P / b / Normal / Thin)
//  • 9 webhook-ready alerts + live HUD dashboard
// ============================================================
// NOTE on the `scale` parameter: it is DELIBERATELY OMITTED below.
// Per TradingView's official docs (verified 2026-04-17):
//   - Omitted  → uses the chart's EXISTING right scale (scale A, candle-locked).
//   - scale.right → CREATES a new right scale (becomes scale B, separate).
//   - scale.left  → creates a new left scale (separate).
//   - scale.none  → "No Scale" — indicator floats free of the candles and
//                   DRIFTS when scrolling/zooming.
// The only way to pin this indicator to the candles' own scale is to
// leave `scale` unspecified. Do NOT add scale=scale.right here.
indicator("Quantum Liquidity Map V3 [NikaQuant]",
     shorttitle       = "QLM V3 • NikaQuant",
     overlay          = true,
     max_boxes_count  = 500,
     max_lines_count  = 500,
     max_labels_count = 500)

// ╔══════════════════════════════════════════════════════════╗
// ║  SECTION 1 — INPUTS                                      ║
// ╚══════════════════════════════════════════════════════════╝

// ── Mode ─────────────────────────────────────────────────────
string i_mode = input.string("Easy", "Mode",
     options=["Easy", "Advanced"],
     group="Mode",
     tooltip="Easy: Volume Profile + VWAP + CVD only (clean, minimal). Advanced: all V3 features — HVN/LVN, session anchors, dPOC, Initial Balance, sweeps, confluence intelligence.")

// ── Volume Profile ──────────────────────────────────────────
int   i_vpRows    = input.int(60, "Profile Rows",
     minval=8, maxval=120,
     group="Volume Profile",
     tooltip="Horizontal price buckets for the profile heatmap.")

float i_vaPercent = input.float(0.70, "Value Area %",
     minval=0.10, maxval=0.99, step=0.01,
     group="Volume Profile",
     tooltip="Volume percentage defining the Value Area (standard = 70%).")

int   i_vpLookback = input.int(250, "Lookback Bars",
     minval=10, maxval=500,
     group="Volume Profile",
     tooltip="Bars included in the main profile calculation.")

float i_vpWidth   = input.float(0.30, "Profile Width",
     minval=0.05, maxval=0.90, step=0.05,
     group="Volume Profile",
     tooltip="Width of profile bars as a fraction of lookback window.")

bool  i_showDpoc  = input.bool(true, "Show Developing POC (dPOC)",
     group="Volume Profile",
     tooltip="Live intra-session POC — updates as the auction develops.")

// ── HVN / LVN ───────────────────────────────────────────────
bool  i_showHVN   = input.bool(true, "Show HVN (High-Volume Nodes)",
     group="HVN / LVN",
     tooltip="Auto-detect local volume peaks — magnet levels that attract price.")

bool  i_showLVN   = input.bool(true, "Show LVN (Low-Volume Nodes)",
     group="HVN / LVN",
     tooltip="Auto-detect local volume gaps — fast-travel zones price slices through.")

float i_hvnMult   = input.float(1.50, "HVN Threshold (× Mean)",
     minval=1.10, maxval=5.00, step=0.05,
     group="HVN / LVN",
     tooltip="Bucket volume must exceed this × mean to qualify as HVN.")

float i_lvnMult   = input.float(0.35, "LVN Threshold (× Mean)",
     minval=0.05, maxval=0.90, step=0.05,
     group="HVN / LVN",
     tooltip="Bucket volume below this × mean qualifies as LVN.")

int   i_nodeMaxCount = input.int(6, "Max HVN/LVN Labels",
     minval=2, maxval=15,
     group="HVN / LVN",
     tooltip="Limit the count of each marker type to keep the chart clean.")

// ── Previous Session Anchors ────────────────────────────────
bool  i_showPrevSes = input.bool(true, "Show Previous Session Levels",
     group="Previous Session",
     tooltip="Draw previous session POC, VAH, VAL as dimmed anchors.")

bool  i_showNPOC    = input.bool(true, "Show Naked POCs",
     group="Previous Session",
     tooltip="Persist un-revisited POCs from prior sessions (max 5).")

// ── Initial Balance ─────────────────────────────────────────
bool  i_showIB    = input.bool(true, "Show Initial Balance",
     group="Initial Balance",
     tooltip="Draw the first-hour range (IBH/IBL) with extension projections.")

int   i_ibMinutes = input.int(60, "IB Duration (minutes)",
     minval=15, maxval=240, step=15,
     group="Initial Balance",
     tooltip="Minutes from session open that define the Initial Balance.")

bool  i_showIBExt = input.bool(true, "Show IB Extensions (±50% / ±100%)",
     group="Initial Balance",
     tooltip="Project IB-range multiples above and below the initial range.")

// ── Liquidity Sweeps ────────────────────────────────────────
bool  i_showSweep  = input.bool(true, "Detect Liquidity Sweeps",
     group="Liquidity Sweeps",
     tooltip="Flag bars that sweep a recent swing high/low and reverse (stop hunt).")

int   i_sweepLen   = input.int(20, "Swing Lookback",
     minval=5, maxval=100,
     group="Liquidity Sweeps",
     tooltip="Bars used to define the most recent swing high/low.")

float i_sweepVolMult = input.float(1.30, "Min RelVol for Sweep",
     minval=1.00, maxval=5.00, step=0.05,
     group="Liquidity Sweeps",
     tooltip="Sweep bar must have volume ≥ this × 20-bar average.")

// ── Volume Spikes ───────────────────────────────────────────
bool  i_showVolSpike = input.bool(true, "Mark Volume Spikes",
     group="Volume Spikes",
     tooltip="Mark bars where volume > threshold × average (institutional footprint).")

float i_volSpikeMult = input.float(2.50, "Spike Threshold (× Avg)",
     minval=1.50, maxval=10.00, step=0.10,
     group="Volume Spikes",
     tooltip="Volume multiplier vs 20-bar average for spike detection.")

// ── VWAP ─────────────────────────────────────────────────────
bool  i_showVwap  = input.bool(true, "Show VWAP",
     group="VWAP",
     tooltip="Display VWAP line on chart.")

string i_vwapPeriod = input.string("Session", "VWAP Period",
     options=["1H", "2H", "4H", "6H", "8H", "12H", "Session", "3D", "Week", "2W", "Month", "3M", "Year"],
     group="VWAP",
     tooltip="VWAP anchor reset period.")

bool  i_showBands = input.bool(true, "Show SD Bands",
     group="VWAP",
     tooltip="Display VWAP ±1σ / ±2σ bands with gradient fills.")

float i_sdMult1   = input.float(1.0, "Inner SD Multiplier",
     minval=0.1, maxval=5.0, step=0.1,
     group="VWAP",
     tooltip="Standard-deviation multiplier for the inner band.")

float i_sdMult2   = input.float(2.0, "Outer SD Multiplier",
     minval=0.1, maxval=5.0, step=0.1,
     group="VWAP",
     tooltip="Standard-deviation multiplier for the outer band.")

// ── CVD ──────────────────────────────────────────────────────
int   i_cvdLen    = input.int(5, "CVD Pivot Lookback (bars each side)",
     minval=2, maxval=20,
     group="CVD",
     tooltip="Bars left AND right for a confirmed swing pivot.")

// ── Intelligence Layer ──────────────────────────────────────
bool  i_showConf  = input.bool(true, "Show Confluence Score",
     group="Intelligence",
     tooltip="Composite 0–100 score combining VWAP, Value Area, CVD, RelVol.")

float i_confAlertThresh = input.float(80.0, "Confluence Alert Threshold",
     minval=50.0, maxval=100.0, step=5.0,
     group="Intelligence",
     tooltip="Absolute confluence score that triggers the strong-signal alert.")

// ── Visual ────────────────────────────────────────────────────
color i_colBull   = input.color(#26a69a, "Bull Color",
     group="Visual",
     tooltip="Bullish accent color (muted teal).")

color i_colBear   = input.color(#ef5350, "Bear Color",
     group="Visual",
     tooltip="Bearish accent color (muted red).")

color i_colPOC    = input.color(#e6b800, "POC Color",
     group="Visual",
     tooltip="Point-of-Control color (muted gold).")

color i_colVwap   = input.color(#7b5dff, "VWAP / dPOC Color",
     group="Visual",
     tooltip="VWAP line + developing POC color.")

color i_colVA     = input.color(#4ecdc4, "Value Area Color",
     group="Visual",
     tooltip="Value Area (VAH / VAL) color.")

color i_colHVN    = input.color(#f5a623, "HVN Color",
     group="Visual",
     tooltip="High-Volume Node color.")

color i_colLVN    = input.color(#9b59b6, "LVN Color",
     group="Visual",
     tooltip="Low-Volume Node color.")

color i_colIB     = input.color(#5dade2, "Initial Balance Color",
     group="Visual",
     tooltip="Initial Balance (IBH/IBL) color.")

color i_colTable  = input.color(#1565c0, "Table / HUD Accent Color",
     group="Visual",
     tooltip="Border, frame, header, and section-header color for the HUD dashboard.")

string i_labelSize = input.string("Small", "Chart Label Size",
     options=["Tiny", "Small", "Normal", "Large"],
     group="Visual",
     tooltip="Size of all price labels on the chart (POC, VAH, VAL, HVN, LVN, IB, etc.).")

bool  i_darkHUD   = input.bool(true, "Force Dark HUD",
     group="Visual",
     tooltip="Force dark dashboard regardless of chart background.")

// ── Dashboard ─────────────────────────────────────────────────
bool  i_showDash  = input.bool(true, "Show Dashboard",
     group="Dashboard",
     tooltip="Display the live stats panel.")

string i_dashPos  = input.string("Top Right", "Dashboard Position",
     options=["Top Left","Top Center","Top Right","Middle Left","Middle Right","Bottom Left","Bottom Right"],
     group="Dashboard")

string i_dashSize = input.string("Small", "Dashboard Size",
     options=["Tiny","Small","Normal","Large"],
     group="Dashboard")

// ╔══════════════════════════════════════════════════════════╗
// ║  SECTION 2 — THEME & COLORS                              ║
// ╚══════════════════════════════════════════════════════════╝
bool isDark = i_darkHUD or color.r(chart.bg_color) < 128

color C_BULL    = i_colBull
color C_BEAR    = i_colBear
color C_POC     = i_colPOC
color C_VWAP    = i_colVwap
color C_VA      = i_colVA
color C_HVN     = i_colHVN
color C_LVN     = i_colLVN
color C_IB      = i_colIB
color C_TABLE   = i_colTable
color C_NEUTRAL = isDark ? #b0b8c8 : #4a5568
color C_BG_HUD  = isDark ? color.new(#0d0f14, 8)  : color.new(#f5f7fa, 8)
color C_HDR_HUD = isDark ? color.new(#1a1d27, 0)  : color.new(#dde1ea, 0)
color C_SEC_HUD = isDark ? color.new(#151823, 0)  : color.new(#e6eaf1, 0)
color C_DIM     = isDark ? #2d3249               : #cbd5e0
color C_TEXT    = isDark ? #e2e8f0               : #1a202c
color C_MUTED   = isDark ? #6b7280               : #9ca3af

string _lblSize = switch i_labelSize
    "Tiny"   => size.tiny
    "Normal" => size.normal
    "Large"  => size.large
    =>           size.small

bool _isAdvanced = i_mode == "Advanced"

// ╔══════════════════════════════════════════════════════════╗
// ║  SECTION 3 — SESSION ANCHOR + VWAP                       ║
// ╚══════════════════════════════════════════════════════════╝
var float _cumPV  = 0.0
var float _cumVol = 0.0
var float _cumPV2 = 0.0

string _vwapTf = switch i_vwapPeriod
    "1H"    => "60"
    "2H"    => "120"
    "4H"    => "240"
    "6H"    => "360"
    "8H"    => "480"
    "12H"   => "720"
    "3D"    => "3D"
    "Week"  => "W"
    "2W"    => "2W"
    "Month" => "M"
    "3M"    => "3M"
    "Year"  => "12M"
    =>          "D"

bool _newSes = timeframe.change(_vwapTf)

if _newSes
    _cumPV  := 0.0
    _cumVol := 0.0
    _cumPV2 := 0.0

_cumPV  += hlc3 * volume
_cumVol += volume
_cumPV2 += volume * hlc3 * hlc3

float vwapVal  = _cumVol > 0 ? _cumPV / _cumVol : hlc3
float variance = _cumVol > 0 ? math.max(0.0, (_cumPV2 / _cumVol) - vwapVal * vwapVal) : 0.0
float vwapSD   = math.sqrt(variance)

var int _sesBars = 0
if _newSes
    _sesBars := 0
_sesBars += 1
bool _bandsReady = _sesBars >= 5

float vwapU2 = _bandsReady ? vwapVal + i_sdMult2 * vwapSD : na
float vwapU1 = _bandsReady ? vwapVal + i_sdMult1 * vwapSD : na
float vwapL1 = _bandsReady ? vwapVal - i_sdMult1 * vwapSD : na
float vwapL2 = _bandsReady ? vwapVal - i_sdMult2 * vwapSD : na

// Session high/low (for Session Type classifier)
var float sesHi = na
var float sesLo = na
if _newSes
    sesHi := high
    sesLo := low
else
    sesHi := na(sesHi) ? high : math.max(sesHi, high)
    sesLo := na(sesLo) ? low  : math.min(sesLo, low)

// ╔══════════════════════════════════════════════════════════╗
// ║  SECTION 4 — VOLUME METRICS & CVD                        ║
// ╚══════════════════════════════════════════════════════════╝
float barRange  = high - low
float buyVolEst = barRange > 0 ? volume * (close - low) / barRange  : volume * 0.5
float selVolEst = barRange > 0 ? volume * (high - close) / barRange : volume * 0.5
float barDelta  = buyVolEst - selVolEst

var float cvd = 0.0
if _newSes
    cvd := 0.0
cvd += barDelta

var float dayVol   = 0.0
var float dayDelta = 0.0
if _newSes
    dayVol   := 0.0
    dayDelta := 0.0
dayVol   += volume
dayDelta += barDelta

float deltaPct = dayVol > 0 ? dayDelta / dayVol * 100.0 : 0.0
float cvdEma   = ta.ema(cvd, 9)

// Relative Volume (vs 20-bar avg) — used by sweep, spike, confluence
float avgVol = ta.sma(volume, 20)
float rVol   = avgVol > 0 ? volume / avgVol : 1.0

// ╔══════════════════════════════════════════════════════════╗
// ║  SECTION 5 — CVD DIVERGENCE                              ║
// ╚══════════════════════════════════════════════════════════╝
int   dLen   = i_cvdLen
float atrNow = ta.atr(14)

float ph = ta.pivothigh(high, dLen, dLen)
float pl = ta.pivotlow(low,  dLen, dLen)

var float prevPH    = na
var float prevPHcvd = na
var float prevPL    = na
var float prevPLcvd = na

var bool bearDiv = false
var bool bullDiv = false

if not na(ph)
    float swingSize = na(prevPH) ? 0.0 : math.abs(ph - prevPH)
    if not na(prevPH) and ph > prevPH and cvd[dLen] < prevPHcvd and swingSize > atrNow * 1.5
        bearDiv := true
    else
        bearDiv := false
    prevPH    := ph
    prevPHcvd := cvd[dLen]
else
    bearDiv := false

if not na(pl)
    float swingSize = na(prevPL) ? 0.0 : math.abs(pl - prevPL)
    if not na(prevPL) and pl < prevPL and cvd[dLen] > prevPLcvd and swingSize > atrNow * 1.5
        bullDiv := true
    else
        bullDiv := false
    prevPL    := pl
    prevPLcvd := cvd[dLen]
else
    bullDiv := false

bool bearDivConf = bearDiv and barstate.isconfirmed
bool bullDivConf = bullDiv and barstate.isconfirmed

// ╔══════════════════════════════════════════════════════════╗
// ║  SECTION 6 — VOLUME SPIKE & LIQUIDITY SWEEP              ║
// ╚══════════════════════════════════════════════════════════╝
bool volSpike     = i_showVolSpike and avgVol > 0 and volume >= avgVol * i_volSpikeMult
bool bullVolSpike = volSpike and close > open
bool bearVolSpike = volSpike and close < open

// Liquidity sweep: price pierces recent swing high/low then closes back inside with volume
float recentHi = ta.highest(high[1], i_sweepLen)
float recentLo = ta.lowest(low[1],   i_sweepLen)

bool bearSweep = i_showSweep and high > recentHi and close < recentHi and
                 rVol >= i_sweepVolMult and close < open
bool bullSweep = i_showSweep and low  < recentLo and close > recentLo and
                 rVol >= i_sweepVolMult and close > open

bool bearSweepConf = bearSweep and barstate.isconfirmed
bool bullSweepConf = bullSweep and barstate.isconfirmed

// ╔══════════════════════════════════════════════════════════╗
// ║  SECTION 7 — INITIAL BALANCE                             ║
// ╚══════════════════════════════════════════════════════════╝
var float ibHi       = na
var float ibLo       = na
var int   ibEndTime  = na
var bool  ibComplete = false
var bool  ibBrokeUp  = false
var bool  ibBrokeDn  = false

int ibMs = i_ibMinutes * 60 * 1000

if _newSes
    ibHi       := high
    ibLo       := low
    ibEndTime  := time + ibMs
    ibComplete := false
    ibBrokeUp  := false
    ibBrokeDn  := false
else if not ibComplete and not na(ibEndTime)
    if time <= ibEndTime
        ibHi := math.max(ibHi, high)
        ibLo := math.min(ibLo, low)
    else
        ibComplete := true

bool ibBreakUp = ibComplete and not ibBrokeUp and not na(ibHi) and close > ibHi
bool ibBreakDn = ibComplete and not ibBrokeDn and not na(ibLo) and close < ibLo
if ibBreakUp
    ibBrokeUp := true
if ibBreakDn
    ibBrokeDn := true

bool ibBreakUpConf = ibBreakUp and barstate.isconfirmed
bool ibBreakDnConf = ibBreakDn and barstate.isconfirmed

// ╔══════════════════════════════════════════════════════════╗
// ║  SECTION 8 — SESSION TRACKING & PREV-SESSION LEVELS      ║
// ╚══════════════════════════════════════════════════════════╝
var bool    _firstSes          = true
var int     _sesStartBar       = 0
var float   _prevSesPOC        = na
var float   _prevSesVAH        = na
var float   _prevSesVAL        = na
var bool    _prevSesPOCTouched = false
var float[] _nakedPocs         = array.new_float()

// Helper: compute [POC, VAH, VAL] over a bar range (specified as bars-ago offsets)
f_sessionLevels(int barsAgoOld, int barsAgoNew, int rows, float vaPct) =>
    int len = barsAgoOld - barsAgoNew + 1
    float poc = float(na)
    float vah = float(na)
    float val = float(na)
    bool valid = len >= 3 and rows >= 3 and barsAgoOld < bar_index and
                 not na(high[barsAgoOld]) and not na(low[barsAgoOld])
    if valid
        float hi = high[barsAgoNew]
        float lo = low[barsAgoNew]
        for k = barsAgoNew to barsAgoOld
            float hk = high[k]
            float lk = low[k]
            if not na(hk) and hk > hi
                hi := hk
            if not na(lk) and lk < lo
                lo := lk
        if hi > lo
            float rowSz = (hi - lo) / rows
            float[] bkts = array.new_float(rows, 0.0)
            for k = barsAgoNew to barsAgoOld
                float mk = (high[k] + low[k]) * 0.5
                float vk = nz(volume[k], 0.0)
                if not na(mk)
                    int bk = math.floor((mk - lo) / rowSz)
                    bk := math.max(0, math.min(bk, rows - 1))
                    bkts.set(bk, bkts.get(bk) + vk)
            float totV = bkts.sum()
            int pIdx = 0
            for k = 0 to rows - 1
                if bkts.get(k) > bkts.get(pIdx)
                    pIdx := k
            float accum = bkts.get(pIdx)
            int plo = pIdx
            int phi = pIdx
            float tgt = totV * vaPct
            while accum < tgt and (phi < rows - 1 or plo > 0)
                float upV = phi < rows - 1 ? bkts.get(phi + 1) : 0.0
                float dnV = plo > 0         ? bkts.get(plo - 1) : 0.0
                if upV >= dnV and phi < rows - 1
                    phi += 1
                    accum += upV
                else if plo > 0
                    plo -= 1
                    accum += dnV
                else
                    break
            poc := lo + pIdx * rowSz + rowSz * 0.5
            vah := lo + (phi + 1) * rowSz
            val := lo + plo * rowSz
    [poc, vah, val]

// Session boundary: snapshot just-ended session and promote previous POC to naked list if untested
if _newSes and bar_index > 0
    if not _firstSes and _sesStartBar < bar_index
        int barsAgoOld = bar_index - _sesStartBar
        int barsAgoNew = 1
        [newPOC, newVAH, newVAL] = f_sessionLevels(barsAgoOld, barsAgoNew, i_vpRows, i_vaPercent)
        if not na(newPOC)
            if not na(_prevSesPOC) and not _prevSesPOCTouched
                _nakedPocs.push(_prevSesPOC)
                if _nakedPocs.size() > 5
                    _nakedPocs.shift()
            _prevSesPOC := newPOC
            _prevSesVAH := newVAH
            _prevSesVAL := newVAL
            _prevSesPOCTouched := false
    _firstSes    := false
    _sesStartBar := bar_index

// Post-session-change: if current bar tests _prevSesPOC, mark as touched
if not na(_prevSesPOC) and high >= _prevSesPOC and low <= _prevSesPOC
    _prevSesPOCTouched := true

// Purge any naked POCs tested by the current bar
if _nakedPocs.size() > 0
    int idx = _nakedPocs.size() - 1
    while idx >= 0
        float p = _nakedPocs.get(idx)
        if high >= p and low <= p
            _nakedPocs.remove(idx)
        idx -= 1

// ╔══════════════════════════════════════════════════════════╗
// ║  SECTION 9 — MAIN PROFILE + ALL DRAWINGS (barstate.islast) ║
// ╚══════════════════════════════════════════════════════════╝
var box[]   _vpBoxes  = array.new<box>()
var line[]  _vpLines  = array.new<line>()
var label[] _vpLabels = array.new<label>()

var float vpPOC  = na
var float vpVAH  = na
var float vpVAL  = na
var float dPOC   = na

var string auctionShape = "—"

// Node storage (for HUD counts)
var float[] _hvnPrices = array.new_float()
var float[] _lvnPrices = array.new_float()

// Must be computed every bar so _hiAll/_loAll are valid when we need them
int   _lkb_raw = math.min(i_vpLookback, bar_index)
float _hiAll   = ta.highest(high, math.max(_lkb_raw, 1))
float _loAll   = ta.lowest(low,  math.max(_lkb_raw, 1))

if barstate.islast
    // Clear stale drawings
    for b in _vpBoxes
        box.delete(b)
    for l in _vpLines
        line.delete(l)
    for lb in _vpLabels
        label.delete(lb)
    _vpBoxes.clear()
    _vpLines.clear()
    _vpLabels.clear()
    _hvnPrices.clear()
    _lvnPrices.clear()

    int   lkb   = _lkb_raw
    float hiAll = _hiAll
    float loAll = _loAll
    int   rows  = i_vpRows

    if hiAll > loAll and rows > 0 and lkb > 0
        float rowSz = (hiAll - loAll) / rows

        // Accumulate main profile
        float[] bkts = array.new_float(rows, 0.0)
        for i = 0 to lkb - 1
            float mid = (high[i] + low[i]) * 0.5
            int   bk  = math.floor((mid - loAll) / rowSz)
            bk := math.max(0, math.min(bk, rows - 1))
            bkts.set(bk, bkts.get(bk) + volume[i])

        float maxVol  = bkts.max()
        float totVol  = bkts.sum()
        float meanVol = rows > 0 ? totVol / rows : 0.0

        // POC
        int pocIdx = 0
        for k = 0 to rows - 1
            if bkts.get(k) > bkts.get(pocIdx)
                pocIdx := k

        // CBOT value-area expansion
        float vaAcc  = bkts.get(pocIdx)
        int   vaLow  = pocIdx
        int   vaHigh = pocIdx
        float vaTgt  = totVol > 0 ? totVol * i_vaPercent : 0.0
        while vaAcc < vaTgt and (vaHigh < rows - 1 or vaLow > 0)
            float upV = vaHigh < rows - 1 ? bkts.get(vaHigh + 1) : 0.0
            float dnV = vaLow  > 0        ? bkts.get(vaLow  - 1) : 0.0
            if upV >= dnV and vaHigh < rows - 1
                vaHigh += 1
                vaAcc  += upV
            else if vaLow > 0
                vaLow -= 1
                vaAcc += dnV
            else
                break

        float pocPrice = loAll + pocIdx * rowSz + rowSz * 0.5
        float vahPrice = loAll + (vaHigh + 1) * rowSz
        float valPrice = loAll + vaLow * rowSz

        vpPOC := pocPrice
        vpVAH := vahPrice
        vpVAL := valPrice

        // Auction Shape (P / b / Normal / Thin) from POC position + concentration
        float relPocPos     = rows > 1 ? float(pocIdx) / float(rows - 1) : 0.5
        float concentration = meanVol > 0 ? maxVol / meanVol : 1.0
        if concentration < 1.6
            auctionShape := "Thin"
        else if relPocPos > 0.70
            auctionShape := "P-Shape"
        else if relPocPos < 0.30
            auctionShape := "b-Shape"
        else
            auctionShape := "Normal"

        // HVN / LVN detection
        for k = 1 to rows - 2
            float v  = bkts.get(k)
            float vp = bkts.get(k - 1)
            float vn = bkts.get(k + 1)
            float rowP = loAll + k * rowSz + rowSz * 0.5
            bool isHVN = v > vp and v > vn and v > meanVol * i_hvnMult and k != pocIdx
            bool isLVN = v < vp and v < vn and v < meanVol * i_lvnMult and v > 0 and
                         (k < vaLow or k > vaHigh)
            if isHVN and _hvnPrices.size() < i_nodeMaxCount
                _hvnPrices.push(rowP)
            if isLVN and _lvnPrices.size() < i_nodeMaxCount
                _lvnPrices.push(rowP)

        int xLeft  = bar_index - lkb
        int xRight = bar_index

        // ─── PROFILE HEATMAP ──────────────────────────────────
        for i = 0 to rows - 1
            float rowLo = loAll + i * rowSz
            float rowHi = rowLo + rowSz
            float ratio = maxVol > 0 ? bkts.get(i) / maxVol : 0.0
            int   xEdge = xLeft + int(ratio * (xRight - xLeft) * i_vpWidth)
            bool  inVA  = i >= vaLow  and i <= vaHigh
            bool  isPOC = i == pocIdx

            int   transp = 50
            color bClr   = C_NEUTRAL
            if isPOC
                transp := 55
                bClr   := C_POC
            else if inVA
                transp := int(math.max(72, 90 - ratio * 18))
                bClr   := C_VA
            else
                transp := int(math.max(82, 95 - ratio * 13))
                bClr   := color.from_gradient(ratio, 0.0, 1.0,
                              color.new(C_NEUTRAL, 92), color.new(C_BULL, 78))

            color bdrClr = isPOC ? color.new(C_POC, 40) : color.new(bClr, 95)
            box bx = box.new(xLeft, rowHi, xEdge, rowLo,
                 border_color = bdrClr,
                 border_width = isPOC ? 1 : 0,
                 bgcolor      = color.new(bClr, transp))
            _vpBoxes.push(bx)

            float volPct = totVol > 0 ? math.round(bkts.get(i) / totVol * 1000) / 10 : 0.0
            string zone  = isPOC ? "POC" : inVA ? "Value Area" : "Outside VA"
            string tipTxt = zone + "\n" + str.tostring(rowLo, format.mintick) + " – " +
                 str.tostring(rowHi, format.mintick) + "\nVol: " +
                 str.tostring(math.round(bkts.get(i))) + "  (" + str.tostring(volPct) + "%)"
            int xMid  = math.round((xLeft + xEdge) / 2)
            float yMid = (rowLo + rowHi) / 2
            label tipLbl = label.new(xMid, yMid, "",
                 tooltip   = tipTxt,
                 style     = label.style_none,
                 color     = #00000000,
                 textcolor = #00000000,
                 size      = size.normal)
            _vpLabels.push(tipLbl)

        // ─── POC / VAH / VAL LINES ────────────────────────────
        _vpLines.push(line.new(xLeft, pocPrice, xRight + 4, pocPrice,
             color=color.new(C_POC, 30), width=1, style=line.style_solid))
        _vpLabels.push(label.new(xRight + 5, pocPrice,
             "POC " + str.tostring(pocPrice, format.mintick),
             style=label.style_label_left,
             color=color.new(C_POC, 75), textcolor=color.new(C_POC, 0), size=_lblSize,
             tooltip="Point of Control — highest volume price in session\nPrice: " + str.tostring(pocPrice, format.mintick) + "\nDist to close: " + str.tostring(math.abs((pocPrice - close) / close * 100), "#.##") + "%\nFair value magnet — price gravitates here across sessions"))

        _vpLines.push(line.new(xLeft, vahPrice, xRight + 4, vahPrice,
             color=color.new(C_VA, 55), width=1, style=line.style_dashed))
        _vpLabels.push(label.new(xRight + 5, vahPrice,
             "VAH " + str.tostring(vahPrice, format.mintick),
             style=label.style_label_left,
             color=color.new(C_VA, 80), textcolor=color.new(C_VA, 0), size=_lblSize,
             tooltip="Value Area High — upper bound of 70% volume zone\nPrice: " + str.tostring(vahPrice, format.mintick) + "\nAbove VAH = premium territory / seller pressure zone\nDist to close: " + str.tostring(math.abs((vahPrice - close) / close * 100), "#.##") + "%"))

        _vpLines.push(line.new(xLeft, valPrice, xRight + 4, valPrice,
             color=color.new(C_VA, 55), width=1, style=line.style_dashed))
        _vpLabels.push(label.new(xRight + 5, valPrice,
             "VAL " + str.tostring(valPrice, format.mintick),
             style=label.style_label_left,
             color=color.new(C_VA, 80), textcolor=color.new(C_VA, 0), size=_lblSize,
             tooltip="Value Area Low — lower bound of 70% volume zone\nPrice: " + str.tostring(valPrice, format.mintick) + "\nBelow VAL = discount territory / buyer support zone\nDist to close: " + str.tostring(math.abs((valPrice - close) / close * 100), "#.##") + "%"))

        // ─── HVN MARKERS ──────────────────────────────────────
        if _isAdvanced and i_showHVN and _hvnPrices.size() > 0
            for k = 0 to _hvnPrices.size() - 1
                float p = _hvnPrices.get(k)
                _vpLines.push(line.new(xRight - 4, p, xRight + 4, p,
                     color=color.new(C_HVN, 40), width=2, style=line.style_solid))
                _vpLabels.push(label.new(xRight + 5, p,
                     "◆ HVN " + str.tostring(p, format.mintick),
                     style=label.style_label_left,
                     color=color.new(C_HVN, 80), textcolor=color.new(C_HVN, 0),
                     size=_lblSize,
                     tooltip="High Volume Node — strong acceptance zone\nPrice: " + str.tostring(p, format.mintick) + "\nExpect: price slows / stalls / reverses here\nActs as magnet in both directions — high-probability reaction level"))

        // ─── LVN MARKERS ──────────────────────────────────────
        if _isAdvanced and i_showLVN and _lvnPrices.size() > 0
            for k = 0 to _lvnPrices.size() - 1
                float p = _lvnPrices.get(k)
                _vpLines.push(line.new(xRight - 4, p, xRight + 4, p,
                     color=color.new(C_LVN, 50), width=1, style=line.style_dotted))
                _vpLabels.push(label.new(xRight + 5, p,
                     "◇ LVN " + str.tostring(p, format.mintick),
                     style=label.style_label_left,
                     color=color.new(C_LVN, 80), textcolor=color.new(C_LVN, 0),
                     size=_lblSize,
                     tooltip="Low Volume Node — rejection / fast-travel zone\nPrice: " + str.tostring(p, format.mintick) + "\nExpect: price moves quickly through this level\nBreaks from LVN often launch sustained moves"))

        // ─── PREVIOUS SESSION LEVELS ──────────────────────────
        if _isAdvanced and i_showPrevSes and not na(_prevSesPOC)
            _vpLines.push(line.new(xLeft, _prevSesPOC, xRight + 8, _prevSesPOC,
                 color=color.new(C_POC, 60), width=1, style=line.style_dashed))
            _vpLabels.push(label.new(xRight + 9, _prevSesPOC,
                 "pPOC " + str.tostring(_prevSesPOC, format.mintick),
                 style=label.style_label_left,
                 color=color.new(C_POC, 55), textcolor=color.new(C_POC, 10),
                 size=_lblSize,
                 tooltip="Previous Session POC — prior session fair value\nPrice: " + str.tostring(_prevSesPOC, format.mintick) + "\nKey magnet if price revisits prior session range\nBreak + acceptance above/below = regime change signal"))
        if _isAdvanced and i_showPrevSes and not na(_prevSesVAH)
            _vpLines.push(line.new(xLeft, _prevSesVAH, xRight + 8, _prevSesVAH,
                 color=color.new(C_VA, 75), width=1, style=line.style_dotted))
            _vpLabels.push(label.new(xRight + 9, _prevSesVAH,
                 "pVAH " + str.tostring(_prevSesVAH, format.mintick),
                 style=label.style_label_left,
                 color=color.new(C_VA, 65), textcolor=color.new(C_VA, 15),
                 size=_lblSize,
                 tooltip="Previous Session Value Area High\nPrice: " + str.tostring(_prevSesVAH, format.mintick) + "\nUpper boundary of prior session's 70% value zone\nTrading above = carrying prior-session premium"))
        if _isAdvanced and i_showPrevSes and not na(_prevSesVAL)
            _vpLines.push(line.new(xLeft, _prevSesVAL, xRight + 8, _prevSesVAL,
                 color=color.new(C_VA, 75), width=1, style=line.style_dotted))
            _vpLabels.push(label.new(xRight + 9, _prevSesVAL,
                 "pVAL " + str.tostring(_prevSesVAL, format.mintick),
                 style=label.style_label_left,
                 color=color.new(C_VA, 65), textcolor=color.new(C_VA, 15),
                 size=_lblSize,
                 tooltip="Previous Session Value Area Low\nPrice: " + str.tostring(_prevSesVAL, format.mintick) + "\nLower boundary of prior session's 70% value zone\nTrading below = carrying prior-session discount"))

        // ─── NAKED POCs (untested older POCs) ────────────────
        if _isAdvanced and i_showNPOC and _nakedPocs.size() > 0
            for k = 0 to _nakedPocs.size() - 1
                float np = _nakedPocs.get(k)
                if not na(np)
                    _vpLines.push(line.new(xLeft, np, xRight + 12, np,
                         color=color.new(C_POC, 75), width=1, style=line.style_dotted))
                    _vpLabels.push(label.new(xRight + 13, np,
                         "nPOC " + str.tostring(np, format.mintick),
                         style=label.style_label_left,
                         color=color.new(C_POC, 65), textcolor=color.new(C_POC, 15),
                         size=_lblSize,
                         tooltip="Naked POC — untested prior session fair value\nPrice: " + str.tostring(np, format.mintick) + "\nStrong gravity magnet — price statistically seeks these\nLevel removed automatically once price touches it"))

        // ─── DEVELOPING POC (dPOC) ───────────────────────────
        if _isAdvanced and i_showDpoc and not _firstSes and _sesStartBar < bar_index
            int curSesLen = math.max(1, bar_index - _sesStartBar)
            [dpoc_cur, _dvah, _dval] = f_sessionLevels(curSesLen, 0, i_vpRows, i_vaPercent)
            if not na(dpoc_cur)
                dPOC := dpoc_cur
                _vpLines.push(line.new(_sesStartBar, dpoc_cur, xRight + 4, dpoc_cur,
                     color=color.new(C_VWAP, 35), width=2, style=line.style_solid))
                _vpLabels.push(label.new(xRight + 5, dpoc_cur,
                     "dPOC " + str.tostring(dpoc_cur, format.mintick),
                     style=label.style_label_left,
                     color=color.new(C_VWAP, 55), textcolor=color.new(C_VWAP, 0),
                     size=_lblSize,
                     tooltip="Developing POC — current session's evolving fair value\nPrice: " + str.tostring(dpoc_cur, format.mintick) + "\nUpdates every bar as volume builds in this session\nWatch for acceptance (slow) vs rejection (fast bounce)"))

        // ─── INITIAL BALANCE + EXTENSIONS ────────────────────
        if _isAdvanced and i_showIB and not na(ibHi) and not na(ibLo)
            int ibLeftX  = _sesStartBar
            int ibRightX = xRight + 6
            _vpLines.push(line.new(ibLeftX, ibHi, ibRightX, ibHi,
                 color=color.new(C_IB, 30), width=2, style=line.style_solid))
            _vpLines.push(line.new(ibLeftX, ibLo, ibRightX, ibLo,
                 color=color.new(C_IB, 30), width=2, style=line.style_solid))
            _vpLabels.push(label.new(ibRightX + 1, ibHi,
                 "IBH " + str.tostring(ibHi, format.mintick),
                 style=label.style_label_left,
                 color=color.new(C_IB, 60), textcolor=color.new(C_IB, 0),
                 size=_lblSize,
                 tooltip="Initial Balance High — first-hour auction ceiling\nPrice: " + str.tostring(ibHi, format.mintick) + "\nBreak above IBH = bullish range extension signal\nIB range: " + str.tostring(ibHi - ibLo, format.mintick) + " pts"))
            _vpLabels.push(label.new(ibRightX + 1, ibLo,
                 "IBL " + str.tostring(ibLo, format.mintick),
                 style=label.style_label_left,
                 color=color.new(C_IB, 60), textcolor=color.new(C_IB, 0),
                 size=_lblSize,
                 tooltip="Initial Balance Low — first-hour auction floor\nPrice: " + str.tostring(ibLo, format.mintick) + "\nBreak below IBL = bearish range extension signal\nIB range: " + str.tostring(ibHi - ibLo, format.mintick) + " pts"))

            if i_showIBExt
                float ibRange = ibHi - ibLo
                float ib150U  = ibHi + ibRange * 0.5
                float ib150D  = ibLo - ibRange * 0.5
                float ib200U  = ibHi + ibRange
                float ib200D  = ibLo - ibRange

                _vpLines.push(line.new(ibLeftX, ib150U, ibRightX, ib150U,
                     color=color.new(C_IB, 65), width=1, style=line.style_dashed))
                _vpLines.push(line.new(ibLeftX, ib150D, ibRightX, ib150D,
                     color=color.new(C_IB, 65), width=1, style=line.style_dashed))
                _vpLines.push(line.new(ibLeftX, ib200U, ibRightX, ib200U,
                     color=color.new(C_IB, 75), width=1, style=line.style_dotted))
                _vpLines.push(line.new(ibLeftX, ib200D, ibRightX, ib200D,
                     color=color.new(C_IB, 75), width=1, style=line.style_dotted))

                _vpLabels.push(label.new(ibRightX + 1, ib150U,
                     "IB+50%", style=label.style_label_left,
                     color=color.new(C_IB, 75), textcolor=color.new(C_IB, 15),
                     size=_lblSize,
                     tooltip="IB +50% Extension — IBH + half the IB range\nTarget: " + str.tostring(ib150U, format.mintick) + "\nCommon first target after IBH breakout\nModerate trending / responsive day structure"))
                _vpLabels.push(label.new(ibRightX + 1, ib150D,
                     "IB-50%", style=label.style_label_left,
                     color=color.new(C_IB, 75), textcolor=color.new(C_IB, 15),
                     size=_lblSize,
                     tooltip="IB -50% Extension — IBL minus half the IB range\nTarget: " + str.tostring(ib150D, format.mintick) + "\nCommon first target after IBL breakdown\nModerate trending / responsive day structure"))
                _vpLabels.push(label.new(ibRightX + 1, ib200U,
                     "IB+100%", style=label.style_label_left,
                     color=color.new(C_IB, 85), textcolor=color.new(C_IB, 20),
                     size=_lblSize,
                     tooltip="IB +100% Extension — full IB range projected above IBH\nTarget: " + str.tostring(ib200U, format.mintick) + "\nStrong momentum / trend-day signal on upside\nHigh conviction breakout target"))
                _vpLabels.push(label.new(ibRightX + 1, ib200D,
                     "IB-100%", style=label.style_label_left,
                     color=color.new(C_IB, 85), textcolor=color.new(C_IB, 20),
                     size=_lblSize,
                     tooltip="IB -100% Extension — full IB range projected below IBL\nTarget: " + str.tostring(ib200D, format.mintick) + "\nStrong momentum / trend-day signal on downside\nHigh conviction breakdown target"))

// ╔══════════════════════════════════════════════════════════╗
// ║  SECTION 10 — PLOTS                                      ║
// ╚══════════════════════════════════════════════════════════╝

// VWAP core + SD bands with gradient fills
pVwap = plot(i_showVwap ? vwapVal : na, "VWAP",
     color=color.new(C_VWAP, 20), linewidth=1, style=plot.style_line)
pU2 = plot(i_showBands ? vwapU2 : na, "VWAP +2SD",
     color=color.new(C_BULL, 60), linewidth=1, style=plot.style_linebr)
pU1 = plot(i_showBands ? vwapU1 : na, "VWAP +1SD",
     color=color.new(C_BULL, 70), linewidth=1, style=plot.style_linebr)
pL1 = plot(i_showBands ? vwapL1 : na, "VWAP -1SD",
     color=color.new(C_BEAR, 70), linewidth=1, style=plot.style_linebr)
pL2 = plot(i_showBands ? vwapL2 : na, "VWAP -2SD",
     color=color.new(C_BEAR, 60), linewidth=1, style=plot.style_linebr)

fill(pU1, pU2, color.new(C_BULL, 95))
fill(pL2, pL1, color.new(C_BEAR, 95))
fill(pVwap, pU1, color.new(C_BULL, 97))
fill(pL1, pVwap, color.new(C_BEAR, 97))

// Data-window only — display.data_window ensures these CANNOT influence
// the price scale (critical so the indicator always merges to scale A,
// not a separate scale B with its own axis)
color cvdCol = cvd >= 0.0 ? C_BULL : C_BEAR
plot(cvd,        "CVD",           color=cvdCol,                linewidth=1, display=display.data_window)
plot(cvdEma,     "CVD EMA",       color=color.new(C_VWAP, 25), linewidth=1, display=display.data_window)
plot(buyVolEst,  "Buy Pressure",  color=color.new(C_BULL, 45),              display=display.data_window)
plot(-selVolEst, "Sell Pressure", color=color.new(C_BEAR, 45),              display=display.data_window)
plot(rVol,       "Relative Vol",  color=color.new(C_VWAP, 30),              display=display.data_window)

// CVD Divergence markers
plotshape(bullDivConf, "Bull CVD Divergence",
     shape.triangleup, location.belowbar,
     color=C_BULL, size=size.small,
     text="CVD", textcolor=C_BULL)

plotshape(bearDivConf, "Bear CVD Divergence",
     shape.triangledown, location.abovebar,
     color=C_BEAR, size=size.small,
     text="CVD", textcolor=C_BEAR)

// Liquidity Sweep markers (Advanced only)
plotshape(_isAdvanced and bullSweepConf, "Bull Liquidity Sweep",
     shape.arrowup, location.belowbar,
     color=color.new(C_BULL, 10), size=size.small,
     text="SWEEP", textcolor=C_BULL)

plotshape(_isAdvanced and bearSweepConf, "Bear Liquidity Sweep",
     shape.arrowdown, location.abovebar,
     color=color.new(C_BEAR, 10), size=size.small,
     text="SWEEP", textcolor=C_BEAR)

// Volume spike markers (Advanced only)
plotshape(_isAdvanced and bullVolSpike, "Bull Volume Spike",
     shape.diamond, location.belowbar,
     color=color.new(C_BULL, 25), size=size.tiny)
plotshape(_isAdvanced and bearVolSpike, "Bear Volume Spike",
     shape.diamond, location.abovebar,
     color=color.new(C_BEAR, 25), size=size.tiny)

// ╔══════════════════════════════════════════════════════════╗
// ║  SECTION 11 — INTELLIGENCE: CONFLUENCE + SESSION TYPE    ║
// ╚══════════════════════════════════════════════════════════╝

// Session Type (every bar — only reads session hi/lo + ATR)
var string sessionType = "—"
if not na(sesHi) and not na(sesLo) and not na(atrNow) and atrNow > 0
    float sesSpan = sesHi - sesLo
    if sesSpan < 1.5 * atrNow
        sessionType := "Balance"
    else if sesSpan > 2.5 * atrNow
        sessionType := "Trend"
    else
        sessionType := "Rotation"

// Confluence score — compute inside barstate.islast since it depends on vpPOC/VAH/VAL
var float confScore = 0.0
var float confAbs   = 0.0
var bool  confBull  = true

if barstate.islast
    float s = 0.0
    s += close > vwapVal ? 20.0 : -20.0
    s += na(vpVAH) or na(vpVAL) ? 0.0 :
         close > vpVAH ? 20.0 :
         close < vpVAL ? -20.0 : 0.0
    s += math.max(-20.0, math.min(20.0, deltaPct * 2.0))
    s += cvd > cvdEma ? 20.0 : -20.0
    s += rVol > 1.3 ? 20.0 : rVol < 0.7 ? -20.0 : 0.0

    confScore := s
    confAbs   := math.min(100.0, math.abs(s))
    confBull  := s >= 0

bool strongConfBull = barstate.islast and confBull  and confAbs >= i_confAlertThresh
bool strongConfBear = barstate.islast and not confBull and confAbs >= i_confAlertThresh

// ╔══════════════════════════════════════════════════════════╗
// ║  SECTION 12 — DASHBOARD                                  ║
// ╚══════════════════════════════════════════════════════════╝
string _dashPos = switch i_dashPos
    "Top Left"     => position.top_left
    "Top Center"   => position.top_center
    "Top Right"    => position.top_right
    "Middle Left"  => position.middle_left
    "Middle Right" => position.middle_right
    "Bottom Left"  => position.bottom_left
    "Bottom Right" => position.bottom_right
    =>                position.top_right

string _tblSize = switch i_dashSize
    "Tiny"   => size.tiny
    "Normal" => size.normal
    "Large"  => size.large
    =>           size.small

var table hud = table.new(_dashPos, 2, 19,
     bgcolor      = C_BG_HUD,
     border_color = color.new(C_TABLE, 55),
     border_width = 1,
     frame_color  = C_TABLE,
     frame_width  = 1,
     force_overlay = true)

hudCell(int col, int row, string txt, color clr, color bg, string tip = "") =>
    table.cell(hud, col, row, txt,
         text_color  = clr,
         text_size   = _tblSize,
         text_halign = col == 0 ? text.align_left : text.align_right,
         bgcolor     = bg,
         tooltip     = tip)

hudSection(int row, string title) =>
    table.merge_cells(hud, 0, row, 1, row)
    table.cell(hud, 0, row, title,
         text_color  = C_TABLE,
         text_size   = size.tiny,
         text_halign = text.align_center,
         bgcolor     = C_SEC_HUD)

if i_showDash and barstate.islast
    // Header
    table.merge_cells(hud, 0, 0, 1, 0)
    table.cell(hud, 0, 0, "Quantum Liquidity Map V3 • NikaQuant",
         text_color  = C_TABLE,
         text_size   = size.small,
         text_halign = text.align_center,
         bgcolor     = C_HDR_HUD,
         tooltip     = "Mode: " + i_mode + "  |  VWAP: " + i_vwapPeriod + "  |  VA: " + str.tostring(i_vaPercent * 100, "#") + "%  |  Lookback: " + str.tostring(i_vpLookback) + " bars")

    // ── MARKET ──────────────────────────────────────────────
    hudSection(1, "— MARKET —")

    string volTxt = dayVol >= 1.0e9 ? str.tostring(dayVol / 1.0e9, "#.##") + " B"
         : dayVol >= 1.0e6           ? str.tostring(dayVol / 1.0e6, "#.##") + " M"
         : dayVol >= 1.0e3           ? str.tostring(dayVol / 1.0e3, "#.##") + " K"
         :                             str.tostring(math.round(dayVol))
    string volTip = "Total volume accumulated this session.\nRaw: " + str.tostring(math.round(dayVol))
    hudCell(0, 2, "Day Volume", C_NEUTRAL, C_BG_HUD, "Session volume")
    hudCell(1, 2, volTxt,       C_TEXT,    C_BG_HUD, volTip)

    color  dClr = deltaPct >= 0.0 ? C_BULL : C_BEAR
    string dTxt = (deltaPct >= 0.0 ? "+" : "") + str.tostring(deltaPct, "#.##") + "%"
    string dTip = "Net buy/sell delta as % of total session volume.\n>0% = buyers dominating  <0% = sellers dominating\nRaw delta: " + str.tostring(math.round(dayDelta))
    hudCell(0, 3, "Delta %", C_NEUTRAL, C_BG_HUD, "Buy/sell pressure imbalance")
    hudCell(1, 3, dTxt,      dClr,      C_BG_HUD, dTip)

    color  rvClr = rVol >= 1.5 ? C_BULL : rVol <= 0.7 ? C_BEAR : C_TEXT
    string rvTxt = str.tostring(rVol, "#.##") + "×"
    string rvTip = "Current bar volume vs 20-bar average.\n>1.5× = elevated activity (institutional)\n<0.7× = low interest / consolidation\nAvg: " + str.tostring(math.round(avgVol))
    hudCell(0, 4, "Rel Volume", C_NEUTRAL, C_BG_HUD, "Volume vs 20-bar average")
    hudCell(1, 4, rvTxt,        rvClr,    C_BG_HUD, rvTip)

    // ── INTELLIGENCE (Advanced only) ────────────────────────
    if _isAdvanced
        hudSection(5, "— INTELLIGENCE —")

        color  cfStrong = confBull ? C_BULL : C_BEAR
        color  cfMid    = confBull ? color.new(C_BULL, 20) : color.new(C_BEAR, 20)
        color  cfClr    = confAbs >= 80 ? cfStrong : confAbs >= 50 ? cfMid : C_MUTED
        string cfDir  = confBull ? "▲" : "▼"
        string cfTxt  = cfDir + " " + str.tostring(math.round(confAbs)) + " / 100"
        string cfTip  = "Composite signal strength (0–100).\n+VWAP position (±20)\n+Value Area position (±20)\n+Delta trend (±20)\n+CVD vs EMA (±20)\n+Relative Volume (±20)\nScore: " + str.tostring(confScore, "#.#")
        hudCell(0, 6, "Confluence", C_NEUTRAL, C_BG_HUD, "Multi-system signal composite")
        hudCell(1, 6, cfTxt,        cfClr,    C_BG_HUD, cfTip)

        color stClr = sessionType == "Trend"    ? C_VWAP :
                      sessionType == "Balance"  ? C_VA   :
                      sessionType == "Rotation" ? C_NEUTRAL : C_MUTED
        string stTip = "Balance = session range < 1.5×ATR (tight, two-sided)\nTrend = range > 2.5×ATR (directional, one-sided)\nRotation = in between (developing)\nSession range: " + (na(sesHi) or na(sesLo) ? "—" : str.tostring(sesHi - sesLo, format.mintick))
        hudCell(0, 7, "Session",    C_NEUTRAL, C_BG_HUD, "Session auction type")
        hudCell(1, 7, sessionType,  stClr,    C_BG_HUD, stTip)

        color asClr = auctionShape == "P-Shape" ? C_BULL :
                      auctionShape == "b-Shape" ? C_BEAR :
                      auctionShape == "Thin"    ? C_MUTED : C_TEXT
        string asTip = "Profile distribution shape:\nP-Shape = vol concentrated at top (short covering, bullish)\nb-Shape = vol concentrated at bottom (long liquidation, bearish)\nNormal = balanced bell curve\nThin = no dominant price level (trending)"
        hudCell(0, 8, "Auction",    C_NEUTRAL, C_BG_HUD, "Profile shape classification")
        hudCell(1, 8, auctionShape, asClr,    C_BG_HUD, asTip)

    // ── LEVELS ──────────────────────────────────────────────
    hudSection(9, "— LEVELS —")

    float  vDist    = close - vwapVal
    float  vDistPct = vwapVal > 0.0 ? vDist / vwapVal * 100.0 : 0.0
    color  vDistClr = vDist >= 0.0 ? C_BULL : C_BEAR
    string vDistTxt = (vDist >= 0.0 ? "+" : "") + str.tostring(vDistPct, "#.##") + "%"
    string vDistTip = "Price vs VWAP fair value.\nPositive = above VWAP (bullish bias)\nNegative = below VWAP (bearish bias)\nVWAP: " + str.tostring(vwapVal, format.mintick) + "  Close: " + str.tostring(close, format.mintick)
    hudCell(0, 10, "VWAP Dist", C_NEUTRAL, C_BG_HUD, "% distance from VWAP")
    hudCell(1, 10, vDistTxt,    vDistClr,  C_BG_HUD, vDistTip)

    string zTxt = close > vwapU2  ? "Above +2σ"   :
                  close > vwapU1  ? "+1σ → +2σ"   :
                  close > vwapVal ? "VWAP → +1σ"  :
                  close > vwapL1  ? "VWAP → -1σ"  :
                  close > vwapL2  ? "-1σ → -2σ"   : "Below -2σ"
    color  zClr = close >= vwapVal ? C_BULL : C_BEAR
    string zTip = "Current SD band zone.\nOutside ±2σ = statistically stretched — mean reversion likely\nVWAP: " + str.tostring(vwapVal, format.mintick) + "\n+1σ: " + (na(vwapU1) ? "—" : str.tostring(vwapU1, format.mintick)) + "  +2σ: " + (na(vwapU2) ? "—" : str.tostring(vwapU2, format.mintick)) + "\n-1σ: " + (na(vwapL1) ? "—" : str.tostring(vwapL1, format.mintick)) + "  -2σ: " + (na(vwapL2) ? "—" : str.tostring(vwapL2, format.mintick))
    hudCell(0, 11, "Band Zone", C_NEUTRAL, C_BG_HUD, "VWAP standard-deviation zone")
    hudCell(1, 11, zTxt,        zClr,      C_BG_HUD, zTip)

    string vahTxt = na(vpVAH) ? "—" : str.tostring(close - vpVAH, format.mintick)
    color  vahClr = na(vpVAH) ? C_NEUTRAL : close >= vpVAH ? C_BULL : C_BEAR
    string vahTip = "Distance from Value Area High.\nNegative = price inside VA (below VAH)\nPositive = price above VA (breakout)\nVAH: " + (na(vpVAH) ? "—" : str.tostring(vpVAH, format.mintick))
    hudCell(0, 12, "VAH Dist", C_NEUTRAL, C_BG_HUD, "Distance from Value Area High")
    hudCell(1, 12, vahTxt,     vahClr,    C_BG_HUD, vahTip)

    string valTxt = na(vpVAL) ? "—" : str.tostring(close - vpVAL, format.mintick)
    color  valClr = na(vpVAL) ? C_NEUTRAL : close >= vpVAL ? C_BULL : C_BEAR
    string valTip = "Distance from Value Area Low.\nPositive = price inside VA (above VAL)\nNegative = price below VA (breakdown)\nVAL: " + (na(vpVAL) ? "—" : str.tostring(vpVAL, format.mintick))
    hudCell(0, 13, "VAL Dist", C_NEUTRAL, C_BG_HUD, "Distance from Value Area Low")
    hudCell(1, 13, valTxt,     valClr,    C_BG_HUD, valTip)

    if _isAdvanced
        string dpocTxt = na(dPOC) ? "—" : str.tostring(dPOC, format.mintick)
        color  dpocClr = na(dPOC) ? C_NEUTRAL : close >= dPOC ? C_BULL : C_BEAR
        string dpocTip = "Developing POC — current session's highest-volume price.\nUpdates live as the auction progresses.\nPrice above = intra-session bullish control"
        hudCell(0, 14, "dPOC",    C_NEUTRAL, C_BG_HUD, "Live intra-session POC")
        hudCell(1, 14, dpocTxt,   dpocClr,   C_BG_HUD, dpocTip)

        string ppocTxt = na(_prevSesPOC) ? "—" : str.tostring(_prevSesPOC, format.mintick)
        color  ppocClr = na(_prevSesPOC) ? C_NEUTRAL : close >= _prevSesPOC ? C_BULL : C_BEAR
        string ppocTip = "Previous session's Point of Control.\nStrong overnight anchor — institutions reference this level.\nUntested pPOC = magnet for price to revisit."
        hudCell(0, 15, "pPOC",    C_NEUTRAL, C_BG_HUD, "Prior session Point of Control")
        hudCell(1, 15, ppocTxt,   ppocClr,   C_BG_HUD, ppocTip)

    // ── SIGNALS ─────────────────────────────────────────────
    hudSection(16, "— SIGNALS —")

    string divTxt = bearDiv ? "Bear Divergence" : bullDiv ? "Bull Divergence" : "No Signal"
    color  divClr = bearDiv ? C_BEAR : bullDiv ? C_BULL : C_NEUTRAL
    string divTip = "CVD pivot divergence vs price swing.\nBear: price made HH but CVD made LH (hidden selling)\nBull: price made LL but CVD made HL (hidden buying)\nRequires swing > 1.5×ATR to confirm"
    hudCell(0, 17, "CVD", C_NEUTRAL, C_BG_HUD, "Cumulative Volume Delta divergence")
    hudCell(1, 17, divTxt, divClr,   C_BG_HUD, divTip)

    if _isAdvanced
        string evTxt = bullSweepConf ? "Bull Sweep" :
                       bearSweepConf ? "Bear Sweep" :
                       ibBreakUpConf ? "IB Break ↑" :
                       ibBreakDnConf ? "IB Break ↓" :
                       bullVolSpike  ? "Vol Spike ↑" :
                       bearVolSpike  ? "Vol Spike ↓" :
                       strongConfBull ? "Strong Bull" :
                       strongConfBear ? "Strong Bear" : "—"
        color  evClr = bullSweepConf or ibBreakUpConf or bullVolSpike or strongConfBull ? C_BULL :
                       bearSweepConf or ibBreakDnConf or bearVolSpike or strongConfBear ? C_BEAR :
                       C_NEUTRAL
        string evTip = "Most recent signal this session:\nSweep = liquidity grab + reversal (stop hunt)\nIB Break = price exits initial balance range\nVol Spike = volume >" + str.tostring(i_volSpikeMult, "#.#") + "× avg (institutional)\nStrong = confluence score ≥" + str.tostring(math.round(i_confAlertThresh))
        hudCell(0, 18, "Last Event", C_NEUTRAL, C_BG_HUD, "Most recent V3 signal")
        hudCell(1, 18, evTxt,        evClr,     C_BG_HUD, evTip)

// ╔══════════════════════════════════════════════════════════╗
// ║  SECTION 13 — ALERTS (webhook-ready)                     ║
// ╚══════════════════════════════════════════════════════════╝
float atr14   = ta.atr(14)
float atrHalf = atr14 * 0.5

bool aPOC = barstate.isconfirmed and not na(vpPOC) and math.abs(close - vpPOC) <= atrHalf
bool aVAH = barstate.isconfirmed and not na(vpVAH) and math.abs(close - vpVAH) <= atrHalf
bool aVAL = barstate.isconfirmed and not na(vpVAL) and math.abs(close - vpVAL) <= atrHalf
bool aDIV = bearDivConf or bullDivConf

alertcondition(aPOC,
     "Price Touches POC",
     '{"alert":"poc_touch","ticker":"{{ticker}}","tf":"{{interval}}","price":"{{close}}"}')

alertcondition(aVAH,
     "Price Enters VAH Zone",
     '{"alert":"vah_touch","ticker":"{{ticker}}","tf":"{{interval}}","price":"{{close}}"}')

alertcondition(aVAL,
     "Price Enters VAL Zone",
     '{"alert":"val_touch","ticker":"{{ticker}}","tf":"{{interval}}","price":"{{close}}"}')

alertcondition(aDIV,
     "CVD Divergence Detected",
     '{"alert":"cvd_divergence","ticker":"{{ticker}}","tf":"{{interval}}","price":"{{close}}"}')

alertcondition(bullSweepConf,
     "Bullish Liquidity Sweep",
     '{"alert":"bull_sweep","ticker":"{{ticker}}","tf":"{{interval}}","price":"{{close}}"}')

alertcondition(bearSweepConf,
     "Bearish Liquidity Sweep",
     '{"alert":"bear_sweep","ticker":"{{ticker}}","tf":"{{interval}}","price":"{{close}}"}')

alertcondition(ibBreakUpConf,
     "Initial Balance Break Up",
     '{"alert":"ib_break_up","ticker":"{{ticker}}","tf":"{{interval}}","price":"{{close}}"}')

alertcondition(ibBreakDnConf,
     "Initial Balance Break Down",
     '{"alert":"ib_break_dn","ticker":"{{ticker}}","tf":"{{interval}}","price":"{{close}}"}')

alertcondition(strongConfBull or strongConfBear,
     "Strong Confluence Signal",
     '{"alert":"strong_confluence","ticker":"{{ticker}}","tf":"{{interval}}","price":"{{close}}","direction":"{{strategy.order.action}}"}')
````
