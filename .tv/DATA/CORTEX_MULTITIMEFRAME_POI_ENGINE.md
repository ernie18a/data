<!-- tradingview-pine-id: PUB;75c629edc1e14d5e897c2f0bb9fe588b -->
<!-- tradingviewscripts-format: 1 -->
# CORTEX MULTI-TIMEFRAME POI ENGINE

Source: https://www.tradingview.com/script/92NXCRCq-CORTEX-MULTI-TIMEFRAME-POI-ENGINE/

## Description

# CORTEX MULTI-TIMEFRAME POI ENGINE

The CORTEX MULTI-TIMEFRAME POI ENGINE is a rules-based TradingView indicator designed to identify, qualify, and manage supply-and-demand Points of Interest across multiple structural timeframes.

Rather than marking every pivot, opposing candle, or conventional order block, CORTEX applies a structured qualification process built around confirmed market structure, consolidation quality, displacement, retracement depth, imbalance, liquidity proxies, and breaker-block behavior.

## Multi-Timeframe Market Structure

CORTEX organizes market location into three distinct layers:

- **Daily POIs** establish higher-timeframe macro location.
- **H4 POIs** identify intermediate structural areas.
- **M15 and M5 AM-session POIs** support intraday refinement on NQ and ES.

Daily, H4, M15, and M5 layers are independently controlled, allowing traders to reduce chart clutter and focus only on the context relevant to their current workflow.

## POI Qualification

A standard CORTEX POI progresses through an objective detection pipeline:

1. Meaningful retracement
2. Compressed base formation
3. Institutional Footprint Candle refinement
4. Directional displacement
5. Mandatory break of structure
6. Liquidity and imbalance evaluation
7. Width and location validation
8. Transparent quality scoring
9. Confirmed zone creation

Break of structure is mandatory. Additional characteristics contribute to a configurable quality score rather than relying on unexplained probability claims.

Available qualification modes include:

- **Loose** for broader structural identification
- **Balanced** for the recommended combination of quality and frequency
- **Strict** for selective, higher-confluence zones
- **Custom** for complete user control

## Breaker-Block Fusion

The engine includes an independently developed ICT breaker-block module.

A potential order block becomes a breaker only after a later confirmed candle closes through its opposite boundary. Wick-only violations do not qualify.

Breaker blocks may:

- Create standalone breaker POIs
- Add confluence to existing supply or demand zones
- Merge with overlapping, same-direction POIs
- Refine the final area to the valid price intersection
- Increase the zone’s score without exceeding 100

Merged areas are classified as **Breaker-Confluent POIs**, helping distinguish ordinary structural zones from areas supported by a confirmed failed-block transition.

## CORTEX AM Session POI Layer

The intraday module is designed specifically for NQ and ES during the default **08:00–11:00 America/New_York** session.

It provides:

- M15 POIs on M15 and M5 charts
- M5 POIs on M5 charts
- Automatic daylight-saving adjustment
- Automatic NQ and ES futures-root recognition
- Optional manual instrument override
- Confirmed post-session BOS allowance
- Independent demand, supply, timeframe, and display controls

Mandatory default width limits are:

- **NQ: 250 ticks**
- **ES: 40 ticks**

Zone width is calculated using the instrument’s native minimum tick size. Candidates exceeding the applicable limit are rejected before publication.

## Transparent Scoring

Each POI receives an objective score from 0 to 100. Depending on the selected mode and timeframe, the score may incorporate:

- Confirmed BOS
- Base quality
- Retracement depth
- Departure strength
- Liquidity sweep
- Fair-value gap or imbalance
- Resting-liquidity proxy
- Breaker-block confluence

Scores and classifications can be displayed directly on zone labels and in the Data Window.

## Zone Lifecycle Management

Every confirmed POI is actively managed through the following lifecycle:

- **Fresh**
- **Tested**
- **Mitigated**
- **Invalidated**
- **Expired**

Users can configure mitigation and invalidation behavior, retain invalidated zones for historical review, and control how long intraday zones remain available.

## Non-Repainting Design

CORTEX uses confirmed source-timeframe information for zone creation.

Higher-timeframe results are transported using confirmed historical offsets, preventing unfinished Daily, H4, M15, or M5 candles from publishing premature zones. A confirmed POI may be anchored to its original footprint candle, but it does not become logically active before its qualifying structure is complete.

This deliberate confirmation delay is intended to support stable behavior across:

- Historical charts
- Realtime execution
- TradingView Bar Replay

## Diagnostics and Alerts

The CORTEX diagnostics dashboard reports:

- Latest qualification stage
- Signals detected
- Candidates awaiting BOS
- Width-filter rejections
- Breaker flips
- Zones retained
- Session status
- Detected instrument
- Applicable tick limit
- Chart-timeframe compatibility

Alerts are available for new POIs, breaker zones, confluence, first tests, mitigation, and invalidation. Alerts should be configured for **Once Per Bar Close**.

## Intended Workflow

CORTEX is designed to support a top-down process:

1. Use Daily zones to establish macro location.
2. Use H4 zones to refine structural context.
3. Use M15 zones for intraday directional areas.
4. Use M5 zones for lower-timeframe refinement.
5. Evaluate price behavior at qualified zones rather than treating every zone as an automatic entry.

CORTEX does not claim to identify actual institutional orders. Supply, demand, liquidity, imbalance, and breaker classifications are objective technical proxies derived from price action.

This indicator is an analytical framework—not financial advice or a guarantee of future performance. Traders should combine it with appropriate confirmation, risk management, and independent judgment.

---

## Source Code

````pine
//@version=6
indicator("CORTEX MULTI-TIMEFRAME POI ENGINE", "CORTEX MTF POI", overlay = true, max_boxes_count = 300, max_labels_count = 300)

// CORTEX/WWA rules-based POI model. A zone is published only after a confirmed
// source-timeframe departure has closed through an objective structure level.

// ── Inputs ───────────────────────────────────────────────────────────────────
string G1 = "Layers & history", G2 = "Qualification", G3 = "Base", G4 = "Departure / BOS"
string G5 = "Zone refinement", G6 = "Lifecycle", G7 = "Scoring / alerts", G8 = "Appearance"
string G9 = "Breaker fusion"
string G10 = "AM session layer", G11 = "AM qualification", G12 = "AM limits & appearance"
bool showD = input.bool(true, "Show Daily POIs", group = G1)
bool showH4 = input.bool(true, "Show H4 POIs", group = G1)
int dailyDays = input.int(92, "Daily lookback (calendar days)", minval = 30, maxval = 730, group = G1)
int h4Weeks = input.int(4, "H4 history (current + prior weekly buckets)", minval = 1, maxval = 26, group = G1)
int maxPerLayer = input.int(30, "Maximum zones per layer", minval = 5, maxval = 100, group = G1)

string mode = input.string("Balanced", "Qualification mode", options = ["Loose", "Balanced", "Strict", "Custom"], group = G2)
string measureMode = input.string("Automatic", "Distance measurement", options = ["Automatic", "Pips", "ATR multiple"], group = G2)
float dailyRetracePips = input.float(30.0, "Daily minimum retracement (pips)", minval = 0, group = G2)
float h4RetracePips = input.float(20.0, "H4 minimum retracement (pips)", minval = 0, group = G2)
float dailyRetraceAtr = input.float(1.0, "Daily minimum retracement (ATR)", minval = 0, step = 0.05, group = G2)
float h4RetraceAtr = input.float(0.75, "H4 minimum retracement (ATR)", minval = 0, step = 0.05, group = G2)
int retraceLookback = input.int(12, "Retracement reference lookback", minval = 3, maxval = 100, group = G2)

int baseBars = input.int(3, "Base candles used", minval = 3, maxval = 7, group = G3)
float maxBodyRatio = input.float(0.55, "Maximum average body/range", minval = 0.05, maxval = 1, step = 0.05, group = G3)
float minOverlap = input.float(0.30, "Minimum neighboring overlap", minval = 0, maxval = 1, step = 0.05, group = G3)
float maxBaseAtr = input.float(1.25, "Maximum complete base range (ATR)", minval = 0.1, step = 0.05, group = G3)
float maxDriftAtr = input.float(0.50, "Maximum base close drift (ATR)", minval = 0, step = 0.05, group = G3)

int atrLen = input.int(14, "ATR length", minval = 2, group = G4)
float departureAtr = input.float(0.80, "Minimum departure body (ATR)", minval = 0, step = 0.05, group = G4)
float strongDepartureAtr = input.float(1.20, "Strong departure body (ATR)", minval = 0, step = 0.05, group = G4)
float directionalPct = input.float(0.60, "Minimum departure body/range", minval = 0.1, maxval = 1, step = 0.05, group = G4)
float closeBufferAtr = input.float(0.10, "Close beyond base / BOS buffer (ATR)", minval = 0, step = 0.01, group = G4)
string bosMethod = input.string("Confirmed pivot", "BOS method", options = ["Confirmed pivot", "Rolling structure", "Hybrid"], group = G4)
int swingLeft = input.int(3, "Pivot left strength", minval = 1, maxval = 20, group = G4)
int swingRight = input.int(3, "Pivot right strength", minval = 1, maxval = 20, group = G4)
int structureLookback = input.int(20, "Rolling structure lookback", minval = 5, maxval = 200, group = G4)
int bosConfirmBars = input.int(3, "Bars allowed for BOS after departure", minval = 1, maxval = 10, group = G4)

string boundaryMethod = input.string("Refined IFC", "Boundary method", options = ["Refined IFC", "Full IFC candle", "Complete base extremes", "Body only"], group = G5)
bool widthFilter = input.bool(false, "Enable maximum-width filter", group = G5)
string widthMode = input.string("Pips", "Width measurement", options = ["Pips", "ATR multiple"], group = G5)
float dailyMaxWidth = input.float(50, "Daily maximum width", minval = 0.1, group = G5)
float h4MaxWidth = input.float(30, "H4 maximum width", minval = 0.1, group = G5)

string mitigation = input.string("Midpoint", "Mitigation threshold", options = ["Proximal touch", "Midpoint", "Distal touch"], group = G6)
string invalidation = input.string("Close beyond distal", "Invalidation", options = ["Close beyond distal", "Wick beyond distal"], group = G6)
bool keepInvalid = input.bool(true, "Keep invalidated zones", group = G6)
int expireDays = input.int(0, "Expire after calendar days (0 = disabled)", minval = 0, maxval = 730, group = G6)

bool breakerEnabled = input.bool(true, "Enable breaker-block fusion", group = G9)
bool breakerStandalone = input.bool(true, "Create standalone breaker POIs", group = G9, tooltip = "When disabled, breaker events remain in diagnostics but are not drawn.")
int breakerPivot = input.int(5, "Breaker structure strength", minval = 2, maxval = 10, group = G9)
int breakerSearch = input.int(12, "Opposing-candle search", minval = 3, maxval = 50, group = G9)
int breakerMaxAge = input.int(50, "Maximum failed-block age", minval = 5, maxval = 250, group = G9)
string breakerBoundary = input.string("Full candle", "Breaker boundaries", options = ["Full candle", "Body only"], group = G9)
bool breakerTwoCandles = input.bool(false, "Include second same-direction candle", group = G9)
float breakerBufferAtr = input.float(0.05, "Required close-through buffer (ATR)", minval = 0, step = 0.01, group = G9)
int breakerScore = input.int(75, "Standalone breaker score", minval = 50, maxval = 95, group = G9)
int breakerBonus = input.int(10, "POI + breaker confluence bonus", minval = 0, maxval = 25, group = G9)
float breakerMergeRatio = input.float(0.50, "Minimum zone overlap to merge", minval = 0.10, maxval = 1, step = 0.05, group = G9)

bool showAM = input.bool(true, "Show AM-session POIs", group = G10)
bool showM15 = input.bool(true, "Show M15 POIs", group = G10)
bool showM5 = input.bool(true, "Show M5 POIs", group = G10)
bool showM15OnM5 = input.bool(true, "Show M15 POIs on M5", group = G10)
bool showAMDemand = input.bool(true, "Show AM demand", group = G10)
bool showAMSupply = input.bool(true, "Show AM supply", group = G10)
string amSession = input.session("0800-1100", "AM session", group = G10)
string amTimezone = input.string("America/New_York", "Session timezone", group = G10)
bool allowPostSession = input.bool(true, "Allow post-session confirmation", group = G10)
int postSessionBars = input.int(3, "Post-session confirmation bars", minval = 0, maxval = 12, group = G10)
string amInstrument = input.string("Automatic", "Instrument", options = ["Automatic", "NQ", "ES", "Custom"], group = G10)
float nqMaxTicks = input.float(250, "NQ maximum zone width (ticks)", minval = 1, group = G10)
float esMaxTicks = input.float(40, "ES maximum zone width (ticks)", minval = 1, group = G10)
float customMaxTicks = input.float(100, "Custom maximum width (ticks)", minval = 1, group = G10)
int amRetentionDays = input.int(10, "Intraday retention (calendar days)", minval = 1, maxval = 60, group = G10)

int amBaseBars = input.int(3, "Base candles", minval = 2, maxval = 5, group = G11)
float amMaxBody = input.float(0.60, "Maximum average body/range", minval = 0.1, maxval = 1, step = 0.05, group = G11)
float amMinOverlap = input.float(0.20, "Minimum neighboring overlap", minval = 0, maxval = 1, step = 0.05, group = G11)
float amMaxBaseAtr = input.float(1.50, "Maximum base range (ATR)", minval = 0.1, step = 0.05, group = G11)
float amDepartureAtr = input.float(0.65, "Minimum departure body (ATR)", minval = 0.1, step = 0.05, group = G11)
float amDirectionalPct = input.float(0.50, "Minimum departure body/range", minval = 0.1, maxval = 1, step = 0.05, group = G11)
float amBufferAtr = input.float(0.05, "Departure/BOS buffer (ATR)", minval = 0, step = 0.01, group = G11)
float amRetraceAtr = input.float(0.50, "Minimum retracement (ATR)", minval = 0, step = 0.05, group = G11)
int amBosWindow = input.int(3, "BOS confirmation window", minval = 1, maxval = 10, group = G11)
int m15Swing = input.int(3, "M15 swing strength", minval = 1, maxval = 10, group = G11)
int m5Swing = input.int(2, "M5 swing strength", minval = 1, maxval = 10, group = G11)

int maxM15Session = input.int(3, "Maximum M15 zones per direction/session", minval = 1, maxval = 10, group = G12)
int maxM5Session = input.int(4, "Maximum M5 zones per direction/session", minval = 1, maxval = 12, group = G12)
int maxIntradayTotal = input.int(40, "Maximum retained intraday zones", minval = 4, maxval = 150, group = G12)
bool showTickWidth = input.bool(true, "Show width in labels", group = G12)
bool showSessionBackground = input.bool(false, "Show session background", group = G12)
color m15Demand = input.color(color.rgb(52, 152, 219), "M15 demand", group = G12)
color m15Supply = input.color(color.rgb(155, 89, 182), "M15 supply", group = G12)
color m5Demand = input.color(color.rgb(93, 173, 226), "M5 demand", group = G12)
color m5Supply = input.color(color.rgb(187, 143, 206), "M5 supply", group = G12)

int customScore = input.int(65, "Custom minimum score", minval = 0, maxval = 100, group = G7)
bool customRequireRetrace = input.bool(true, "Custom: require retracement", group = G7)
bool customRequireFvg = input.bool(false, "Custom: require FVG", group = G7)
bool customRequireSweep = input.bool(false, "Custom: require liquidity sweep", group = G7)
bool alertNew = input.bool(true, "Alert: new POI", group = G7)
bool alertTouch = input.bool(true, "Alert: first test", group = G7)
bool alertInvalid = input.bool(true, "Alert: invalidation", group = G7)
bool showLabels = input.bool(true, "Show labels", group = G8)
bool showDiagnostics = input.bool(true, "Show diagnostic panel", group = G8)
color dDemand = input.color(color.rgb(32, 125, 70), "Daily demand", group = G8)
color dSupply = input.color(color.rgb(175, 55, 55), "Daily supply", group = G8)
color hDemand = input.color(color.rgb(45, 145, 125), "H4 demand", group = G8)
color hSupply = input.color(color.rgb(195, 115, 45), "H4 supply", group = G8)
int fillTransparency = input.int(84, "Fill transparency", minval = 0, maxval = 100, group = G8)

string amSessionSpec = amSession + ":23456"
string rootUpper = str.upper(syminfo.root)
string tickerUpper = str.upper(syminfo.ticker)
bool autoNQ = rootUpper == "NQ" or str.startswith(tickerUpper, "NQ")
bool autoES = rootUpper == "ES" or str.startswith(tickerUpper, "ES")
string detectedAMInstrument = amInstrument == "NQ" ? "NQ" : amInstrument == "ES" ? "ES" : amInstrument == "Custom" ? "Custom" : autoNQ ? "NQ" : autoES ? "ES" : "Unsupported"
bool amInstrumentOK = detectedAMInstrument != "Unsupported"
float amMaxTicks = detectedAMInstrument == "NQ" ? nqMaxTicks : detectedAMInstrument == "ES" ? esMaxTicks : customMaxTicks
bool chartM5 = timeframe.isminutes and timeframe.multiplier == 5
bool chartM15 = timeframe.isminutes and timeframe.multiplier == 15
bool amChartSupported = chartM5 or chartM15
bool m15LayerOn = showAM and showM15 and (chartM15 or chartM5 and showM15OnM5)
bool m5LayerOn = showAM and showM5 and chartM5
bool chartInAMSession = not na(time(timeframe.period, amSessionSpec, amTimezone))
bgcolor(showSessionBackground and showAM and amChartSupported and chartInAMSession ? color.new(color.blue, 94) : na, title = "CORTEX AM session")

// ── Source-timeframe engine ─────────────────────────────────────────────────
f_pip() =>
    bool jpy = str.contains(syminfo.ticker, "JPY")
    syminfo.type == "forex" ? (jpy ? 0.01 : 0.0001) : syminfo.mintick

f_engine(float retracePips, float retraceAtr, float maxWidth, int scanBars) =>
    float atr = ta.atr(atrLen)
    float pip = f_pip()
    bool pipMeasure = measureMode == "Pips" or (measureMode == "Automatic" and syminfo.type == "forex")
    float minRet = pipMeasure ? retracePips * pip : retraceAtr * atr
    float allowedWidth = widthMode == "Pips" ? maxWidth * pip : maxWidth * atr
    float baseHi = ta.highest(high[1], baseBars)
    float baseLo = ta.lowest(low[1], baseBars)
    float avgBodyRatio = ta.sma(math.abs(close - open) / math.max(high - low, syminfo.mintick), baseBars)[1]
    float overlapSum = 0.0
    for i = 1 to baseBars - 1
        float shared = math.max(0.0, math.min(high[i], high[i + 1]) - math.max(low[i], low[i + 1]))
        float smaller = math.max(math.min(high[i] - low[i], high[i + 1] - low[i + 1]), syminfo.mintick)
        overlapSum += shared / smaller
    float avgOverlap = overlapSum / math.max(baseBars - 1, 1)
    float effectiveBody = mode == "Loose" ? math.min(0.85, maxBodyRatio + 0.15) : mode == "Strict" ? math.max(0.10, maxBodyRatio - 0.05) : maxBodyRatio
    float effectiveRange = mode == "Loose" ? maxBaseAtr * 1.35 : mode == "Strict" ? maxBaseAtr * 0.90 : maxBaseAtr
    bool compressed = avgBodyRatio <= effectiveBody and baseHi - baseLo <= effectiveRange * atr[1]
    bool overlapOK = avgOverlap >= minOverlap
    bool driftOK = math.abs(close[1] - close[baseBars]) <= maxDriftAtr * atr[1]
    bool baseOK = compressed and (mode == "Loose" ? true : mode == "Strict" ? overlapOK and driftOK : overlapOK or driftOK)
    int demandIfc = 1
    int supplyIfc = 1
    bool demandIfcFound = false
    bool supplyIfcFound = false
    for i = 1 to baseBars
        if close[i] < open[i] and not demandIfcFound
            demandIfc := i
            demandIfcFound := true
        if close[i] > open[i] and not supplyIfcFound
            supplyIfc := i
            supplyIfcFound := true
    float dDistal = boundaryMethod == "Complete base extremes" ? baseLo : boundaryMethod == "Body only" ? math.min(open[demandIfc], close[demandIfc]) : low[demandIfc]
    float dProx = boundaryMethod == "Complete base extremes" ? baseHi : boundaryMethod == "Full IFC candle" ? high[demandIfc] : math.max(open[demandIfc], close[demandIfc])
    float sDistal = boundaryMethod == "Complete base extremes" ? baseHi : boundaryMethod == "Body only" ? math.max(open[supplyIfc], close[supplyIfc]) : high[supplyIfc]
    float sProx = boundaryMethod == "Complete base extremes" ? baseLo : boundaryMethod == "Full IFC candle" ? low[supplyIfc] : math.min(open[supplyIfc], close[supplyIfc])
    float body = math.abs(close - open), rng = math.max(high - low, syminfo.mintick)
    float effectiveDeparture = mode == "Loose" ? departureAtr * 0.75 : mode == "Strict" ? math.max(departureAtr, strongDepartureAtr) : departureAtr
    float effectiveDirection = mode == "Loose" ? math.max(0.35, directionalPct - 0.10) : directionalPct
    bool bullDeparture = close > open and body >= effectiveDeparture * atr and body / rng >= effectiveDirection and close > baseHi + closeBufferAtr * atr
    bool bearDeparture = close < open and body >= effectiveDeparture * atr and body / rng >= effectiveDirection and close < baseLo - closeBufferAtr * atr
    float ph = ta.valuewhen(not na(ta.pivothigh(high, swingLeft, swingRight)), ta.pivothigh(high, swingLeft, swingRight), 0)
    float pl = ta.valuewhen(not na(ta.pivotlow(low, swingLeft, swingRight)), ta.pivotlow(low, swingLeft, swingRight), 0)
    float rollHi = ta.highest(high[baseBars + 1], structureLookback)
    float rollLo = ta.lowest(low[baseBars + 1], structureLookback)
    float bosHi = bosMethod == "Rolling structure" ? rollHi : bosMethod == "Hybrid" ? math.max(nz(ph, rollHi), rollHi) : nz(ph, rollHi)
    float bosLo = bosMethod == "Rolling structure" ? rollLo : bosMethod == "Hybrid" ? math.min(nz(pl, rollLo), rollLo) : nz(pl, rollLo)
    float priorHi = ta.highest(high[baseBars + 1], retraceLookback)
    float priorLo = ta.lowest(low[baseBars + 1], retraceLookback)
    bool dRetrace = priorHi - baseLo >= minRet
    bool sRetrace = baseHi - priorLo >= minRet
    float shortPL = ta.valuewhen(not na(ta.pivotlow(low, 2, 2)), ta.pivotlow(low, 2, 2), 0)
    float shortPH = ta.valuewhen(not na(ta.pivothigh(high, 2, 2)), ta.pivothigh(high, 2, 2), 0)
    bool dSweep = ta.lowest(low[1], baseBars) < shortPL and close[1] > shortPL
    bool sSweep = ta.highest(high[1], baseBars) > shortPH and close[1] < shortPH
    bool dFvgRaw = low > high[2]
    bool sFvgRaw = high < low[2]
    bool dLiquidity = ta.highest(high[baseBars + 1], structureLookback) > close
    bool sLiquidity = ta.lowest(low[baseBars + 1], structureLookback) < close
    int basePts = baseOK ? (overlapOK and driftOK ? 15 : 10) : 0
    bool dWidth = not widthFilter or dProx - dDistal <= allowedWidth
    bool sWidth = not widthFilter or sDistal - sProx <= allowedWidth
    bool dCandidate = baseOK and bullDeparture and dWidth
    bool sCandidate = baseOK and bearDeparture and sWidth

    // Preserve the latest valid departure candidate while waiting for BOS.
    // This is the missing state in the original build: BOS no longer has to
    // occur on the exact same candle as departure.
    int dAge = ta.barssince(dCandidate)
    int sAge = ta.barssince(sCandidate)
    bool dPending = not na(dAge) and dAge <= bosConfirmBars
    bool sPending = not na(sAge) and sAge <= bosConfirmBars
    int cDOrigin = ta.valuewhen(dCandidate, time[demandIfc], 0)
    int cSOrigin = ta.valuewhen(sCandidate, time[supplyIfc], 0)
    float cDProx = ta.valuewhen(dCandidate, dProx, 0)
    float cDDistal = ta.valuewhen(dCandidate, dDistal, 0)
    float cSProx = ta.valuewhen(sCandidate, sProx, 0)
    float cSDistal = ta.valuewhen(sCandidate, sDistal, 0)
    float cDBos = ta.valuewhen(dCandidate, bosHi, 0)
    float cSBos = ta.valuewhen(sCandidate, bosLo, 0)
    int cDBasePts = ta.valuewhen(dCandidate, basePts, 0)
    int cSBasePts = ta.valuewhen(sCandidate, basePts, 0)
    bool cDRetrace = ta.valuewhen(dCandidate, dRetrace, 0)
    bool cSRetrace = ta.valuewhen(sCandidate, sRetrace, 0)
    bool cDSweep = ta.valuewhen(dCandidate, dSweep, 0)
    bool cSSweep = ta.valuewhen(sCandidate, sSweep, 0)
    bool cDStrong = ta.valuewhen(dCandidate, body >= strongDepartureAtr * atr, 0)
    bool cSStrong = ta.valuewhen(sCandidate, body >= strongDepartureAtr * atr, 0)
    int dFvgAge = ta.barssince(dFvgRaw)
    int sFvgAge = ta.barssince(sFvgRaw)
    bool cDFvg = dPending and not na(dFvgAge) and dFvgAge <= dAge
    bool cSFvg = sPending and not na(sFvgAge) and sFvgAge <= sAge
    bool bullBos = dPending and close > cDBos + closeBufferAtr * atr
    bool bearBos = sPending and close < cSBos - closeBufferAtr * atr
    bool bullBosFirst = bullBos and (dAge == 0 or not bullBos[1])
    bool bearBosFirst = bearBos and (sAge == 0 or not bearBos[1])
    int dScore = (bullBosFirst ? 30 : 0) + cDBasePts + (cDRetrace ? 15 : 0) + (cDStrong ? 15 : 12) + (cDSweep ? 10 : 0) + (cDFvg ? 10 : 0) + (dLiquidity ? 5 : 0)
    int sScore = (bearBosFirst ? 30 : 0) + cSBasePts + (cSRetrace ? 15 : 0) + (cSStrong ? 15 : 12) + (cSSweep ? 10 : 0) + (cSFvg ? 10 : 0) + (sLiquidity ? 5 : 0)
    int threshold = mode == "Loose" ? 50 : mode == "Balanced" ? 60 : mode == "Strict" ? 75 : customScore
    bool dExtras = mode == "Strict" ? cDRetrace and (cDSweep or cDFvg) : mode == "Custom" ? (not customRequireRetrace or cDRetrace) and (not customRequireFvg or cDFvg) and (not customRequireSweep or cDSweep) : true
    bool sExtras = mode == "Strict" ? cSRetrace and (cSSweep or cSFvg) : mode == "Custom" ? (not customRequireRetrace or cSRetrace) and (not customRequireFvg or cSFvg) and (not customRequireSweep or cSSweep) : true
    bool dEvent = bullBosFirst and dExtras and dScore >= threshold
    bool sEvent = bearBosFirst and sExtras and sScore >= threshold
    int dStage = dEvent ? 5 : bullBosFirst ? 4 : dPending ? 3 : dCandidate ? 2 : baseOK ? 1 : 0
    int sStage = sEvent ? 5 : bearBosFirst ? 4 : sPending ? 3 : sCandidate ? 2 : baseOK ? 1 : 0
    int dSignals = int(math.sum(dEvent ? 1 : 0, scanBars))
    int sSignals = int(math.sum(sEvent ? 1 : 0, scanBars))
    [dEvent, cDOrigin, time_close, cDProx, cDDistal, dScore, cDSweep, cDFvg, dStage, dSignals, sEvent, cSOrigin, time_close, cSProx, cSDistal, sScore, cSSweep, cSFvg, sStage, sSignals]

// Offset the complete source result by one HTF bar and pair it with lookahead_on.
// Thus realtime and historical lower-timeframe bars receive identical, last-
// confirmed HTF values. The one-source-bar publication delay is intentional.
f_confirmed(float rp, float ra, float mw, int scanBars) =>
    [de, dor, dc, dp, dd, ds, dsw, df, dst, dcnt, se, sor, sc, sp, sd, ss, ssw, sf, sst, scnt] = f_engine(rp, ra, mw, scanBars)
    [de[1], dor[1], dc[1], dp[1], dd[1], ds[1], dsw[1], df[1], dst[1], dcnt[1], se[1], sor[1], sc[1], sp[1], sd[1], ss[1], ssw[1], sf[1], sst[1], scnt[1]]

// ── AM-session M15/M5 engine ────────────────────────────────────────────────
f_amEngine(int swingStrength, float maxTicks) =>
    float atr = ta.atr(atrLen)
    bool inSession = not na(time(timeframe.period, amSessionSpec, amTimezone))
    bool baseInSession = true
    for i = 1 to amBaseBars
        if not inSession[i]
            baseInSession := false
    float baseHi = ta.highest(high[1], amBaseBars)
    float baseLo = ta.lowest(low[1], amBaseBars)
    float avgBody = ta.sma(math.abs(close - open) / math.max(high - low, syminfo.mintick), amBaseBars)[1]
    float overlapSum = 0.0
    for i = 1 to amBaseBars - 1
        float shared = math.max(0.0, math.min(high[i], high[i + 1]) - math.max(low[i], low[i + 1]))
        float smaller = math.max(math.min(high[i] - low[i], high[i + 1] - low[i + 1]), syminfo.mintick)
        overlapSum += shared / smaller
    float avgOverlap = overlapSum / math.max(amBaseBars - 1, 1)
    float bodyLimit = mode == "Loose" ? math.min(0.85, amMaxBody + 0.15) : mode == "Strict" ? math.max(0.15, amMaxBody - 0.05) : amMaxBody
    float rangeLimit = mode == "Loose" ? amMaxBaseAtr * 1.25 : mode == "Strict" ? amMaxBaseAtr * 0.90 : amMaxBaseAtr
    bool compressed = avgBody <= bodyLimit and baseHi - baseLo <= rangeLimit * atr[1]
    bool overlapOK = avgOverlap >= amMinOverlap
    bool baseOK = baseInSession and compressed and (mode == "Strict" ? overlapOK : true)

    int demandIfc = 1
    int supplyIfc = 1
    bool demandFound = false
    bool supplyFound = false
    for i = 1 to amBaseBars
        if close[i] < open[i] and not demandFound
            demandIfc := i
            demandFound := true
        if close[i] > open[i] and not supplyFound
            supplyIfc := i
            supplyFound := true
    float dDistal = boundaryMethod == "Complete base extremes" ? baseLo : boundaryMethod == "Body only" ? math.min(open[demandIfc], close[demandIfc]) : low[demandIfc]
    float dProx = boundaryMethod == "Complete base extremes" ? baseHi : boundaryMethod == "Full IFC candle" ? high[demandIfc] : math.max(open[demandIfc], close[demandIfc])
    float sDistal = boundaryMethod == "Complete base extremes" ? baseHi : boundaryMethod == "Body only" ? math.max(open[supplyIfc], close[supplyIfc]) : high[supplyIfc]
    float sProx = boundaryMethod == "Complete base extremes" ? baseLo : boundaryMethod == "Full IFC candle" ? low[supplyIfc] : math.min(open[supplyIfc], close[supplyIfc])
    float dWidthTicks = (dProx - dDistal) / syminfo.mintick
    float sWidthTicks = (sDistal - sProx) / syminfo.mintick
    bool dWidthOK = dWidthTicks <= maxTicks
    bool sWidthOK = sWidthTicks <= maxTicks

    float body = math.abs(close - open)
    float rng = math.max(high - low, syminfo.mintick)
    float depLimit = mode == "Loose" ? amDepartureAtr * 0.75 : mode == "Strict" ? math.max(amDepartureAtr, 0.90) : amDepartureAtr
    float dirLimit = mode == "Loose" ? math.max(0.35, amDirectionalPct - 0.10) : amDirectionalPct
    bool bullDeparture = close > open and body >= depLimit * atr and body / rng >= dirLimit and close > baseHi + amBufferAtr * atr and close > dProx
    bool bearDeparture = close < open and body >= depLimit * atr and body / rng >= dirLimit and close < baseLo - amBufferAtr * atr and close < sProx
    float phRaw = ta.pivothigh(high, swingStrength, swingStrength)
    float plRaw = ta.pivotlow(low, swingStrength, swingStrength)
    float ph = ta.valuewhen(not na(phRaw), phRaw, 0)
    float pl = ta.valuewhen(not na(plRaw), plRaw, 0)
    float priorHi = ta.highest(high[amBaseBars + 1], retraceLookback)
    float priorLo = ta.lowest(low[amBaseBars + 1], retraceLookback)
    bool dRetrace = priorHi - baseLo >= amRetraceAtr * atr
    bool sRetrace = baseHi - priorLo >= amRetraceAtr * atr
    bool dFvg = low > high[2]
    bool sFvg = high < low[2]
    bool dLiquidity = ta.highest(high[amBaseBars + 1], structureLookback) > close
    bool sLiquidity = ta.lowest(low[amBaseBars + 1], structureLookback) < close
    bool dRawCandidate = amInstrumentOK and inSession and baseOK and bullDeparture
    bool sRawCandidate = amInstrumentOK and inSession and baseOK and bearDeparture
    bool dTooWide = dRawCandidate and not dWidthOK
    bool sTooWide = sRawCandidate and not sWidthOK
    bool dCandidate = dRawCandidate and dWidthOK
    bool sCandidate = sRawCandidate and sWidthOK
    int dAge = ta.barssince(dCandidate)
    int sAge = ta.barssince(sCandidate)
    int pendingWindow = allowPostSession ? math.max(amBosWindow, postSessionBars) : amBosWindow
    bool dPending = not na(dAge) and dAge <= pendingWindow
    bool sPending = not na(sAge) and sAge <= pendingWindow
    bool dConfirmTimeOK = dPending and (inSession or allowPostSession and dAge <= postSessionBars)
    bool sConfirmTimeOK = sPending and (inSession or allowPostSession and sAge <= postSessionBars)
    int cDOrigin = ta.valuewhen(dCandidate, time[demandIfc], 0)
    int cSOrigin = ta.valuewhen(sCandidate, time[supplyIfc], 0)
    float cDProx = ta.valuewhen(dCandidate, dProx, 0)
    float cDDistal = ta.valuewhen(dCandidate, dDistal, 0)
    float cSProx = ta.valuewhen(sCandidate, sProx, 0)
    float cSDistal = ta.valuewhen(sCandidate, sDistal, 0)
    float cDBos = ta.valuewhen(dCandidate, ph, 0)
    float cSBos = ta.valuewhen(sCandidate, pl, 0)
    bool cDRetrace = ta.valuewhen(dCandidate, dRetrace, 0)
    bool cSRetrace = ta.valuewhen(sCandidate, sRetrace, 0)
    bool cDFvg = ta.valuewhen(dCandidate, dFvg, 0)
    bool cSFvg = ta.valuewhen(sCandidate, sFvg, 0)
    bool cDLiquidity = ta.valuewhen(dCandidate, dLiquidity, 0)
    bool cSLiquidity = ta.valuewhen(sCandidate, sLiquidity, 0)
    bool cDStrong = ta.valuewhen(dCandidate, body >= 1.0 * atr, 0)
    bool cSStrong = ta.valuewhen(sCandidate, body >= 1.0 * atr, 0)
    int cDBasePts = ta.valuewhen(dCandidate, overlapOK ? 15 : 10, 0)
    int cSBasePts = ta.valuewhen(sCandidate, overlapOK ? 15 : 10, 0)
    bool bullBos = dConfirmTimeOK and not na(cDBos) and close > cDBos + amBufferAtr * atr
    bool bearBos = sConfirmTimeOK and not na(cSBos) and close < cSBos - amBufferAtr * atr
    bool bullBosFirst = bullBos and (dAge == 0 or not bullBos[1])
    bool bearBosFirst = bearBos and (sAge == 0 or not bearBos[1])
    int dScore = math.min(100, (bullBosFirst ? 30 : 0) + cDBasePts + (cDRetrace ? 15 : 0) + (cDStrong ? 15 : 12) + (cDFvg ? 10 : 0) + (cDLiquidity ? 5 : 0))
    int sScore = math.min(100, (bearBosFirst ? 30 : 0) + cSBasePts + (cSRetrace ? 15 : 0) + (cSStrong ? 15 : 12) + (cSFvg ? 10 : 0) + (cSLiquidity ? 5 : 0))
    int threshold = mode == "Loose" ? 50 : mode == "Balanced" ? 60 : mode == "Strict" ? 75 : customScore
    bool dExtras = mode == "Strict" ? cDRetrace and cDFvg : mode == "Custom" ? (not customRequireRetrace or cDRetrace) and (not customRequireFvg or cDFvg) : true
    bool sExtras = mode == "Strict" ? cSRetrace and cSFvg : mode == "Custom" ? (not customRequireRetrace or cSRetrace) and (not customRequireFvg or cSFvg) : true
    bool dEvent = bullBosFirst and dExtras and dScore >= threshold and low >= cDDistal
    bool sEvent = bearBosFirst and sExtras and sScore >= threshold and high <= cSDistal

    int dayKey = year(time, amTimezone) * 10000 + month(time, amTimezone) * 100 + dayofmonth(time, amTimezone)
    bool newDay = na(dayKey[1]) or dayKey != dayKey[1]
    var int dSignals = 0
    var int sSignals = 0
    var int dCandidates = 0
    var int sCandidates = 0
    var int dWidthRejects = 0
    var int sWidthRejects = 0
    if newDay
        dSignals := 0
        sSignals := 0
        dCandidates := 0
        sCandidates := 0
        dWidthRejects := 0
        sWidthRejects := 0
    if dCandidate and not dCandidate[1]
        dCandidates += 1
    if sCandidate and not sCandidate[1]
        sCandidates += 1
    if dTooWide and not dTooWide[1]
        dWidthRejects += 1
    if sTooWide and not sTooWide[1]
        sWidthRejects += 1
    if dEvent
        dSignals += 1
    if sEvent
        sSignals += 1
    int dStage = not amInstrumentOK ? 7 : not inSession and not dPending ? 0 : dEvent ? 6 : bullBosFirst ? 5 : dTooWide ? 4 : dPending ? 3 : baseOK ? 2 : 1
    int sStage = not amInstrumentOK ? 7 : not inSession and not sPending ? 0 : sEvent ? 6 : bearBosFirst ? 5 : sTooWide ? 4 : sPending ? 3 : baseOK ? 2 : 1
    int dStats = dSignals * 10000 + dCandidates * 100 + dWidthRejects
    int sStats = sSignals * 10000 + sCandidates * 100 + sWidthRejects
    [dEvent, cDOrigin, time_close, cDProx, cDDistal, dScore, dStage, dStats, sEvent, cSOrigin, time_close, cSProx, cSDistal, sScore, sStage, sStats]

// Clean-room ICT breaker model. A source-timeframe order block is recorded on
// a confirmed structural break. It becomes a breaker only if a later confirmed
// candle closes through the opposite edge of that failed block.
f_breakerEngine(int scanBars, int pivotStrength, int maxAge, bool restrictToAM) =>
    float bAtr = ta.atr(atrLen)
    bool bInSession = not na(time(timeframe.period, amSessionSpec, amTimezone))
    int bDayKey = year(time, amTimezone) * 10000 + month(time, amTimezone) * 100 + dayofmonth(time, amTimezone)
    bool bNewDay = na(bDayKey[1]) or bDayKey != bDayKey[1]
    float bPhRaw = ta.pivothigh(high, pivotStrength, pivotStrength)
    float bPlRaw = ta.pivotlow(low, pivotStrength, pivotStrength)
    float bPh = ta.valuewhen(not na(bPhRaw), bPhRaw, 0)
    float bPl = ta.valuewhen(not na(bPlRaw), bPlRaw, 0)
    bool rawBullMss = not na(bPh) and close > bPh + breakerBufferAtr * bAtr
    bool rawBearMss = not na(bPl) and close < bPl - breakerBufferAtr * bAtr
    bool bullMss = rawBullMss and not rawBullMss[1] and (not restrictToAM or bInSession)
    bool bearMss = rawBearMss and not rawBearMss[1] and (not restrictToAM or bInSession)

    var float demandTop = na
    var float demandBottom = na
    var int demandOrigin = na
    var int demandCreated = na
    var bool demandLive = false
    var float supplyTop = na
    var float supplyBottom = na
    var int supplyOrigin = na
    var int supplyCreated = na
    var bool supplyLive = false

    if restrictToAM and bNewDay
        demandLive := false
        supplyLive := false
    if demandLive and bar_index - demandCreated > maxAge
        demandLive := false
    if supplyLive and bar_index - supplyCreated > maxAge
        supplyLive := false

    bool bullTimeOK = not restrictToAM or bInSession or allowPostSession and bar_index - supplyCreated <= postSessionBars
    bool bearTimeOK = not restrictToAM or bInSession or allowPostSession and bar_index - demandCreated <= postSessionBars
    bool bullBreaker = breakerEnabled and supplyLive and bullTimeOK and bar_index > supplyCreated and close > supplyTop + breakerBufferAtr * bAtr
    bool bearBreaker = breakerEnabled and demandLive and bearTimeOK and bar_index > demandCreated and close < demandBottom - breakerBufferAtr * bAtr
    int bullOrigin = supplyOrigin
    float bullTop = supplyTop
    float bullBottom = supplyBottom
    int bearOrigin = demandOrigin
    float bearTop = demandTop
    float bearBottom = demandBottom
    if bullBreaker
        supplyLive := false
    if bearBreaker
        demandLive := false

    if bullMss
        int idx = na
        for i = 1 to breakerSearch
            if na(idx) and close[i] < open[i] and (not restrictToAM or bInSession[i])
                idx := i
        if not na(idx)
            float firstTop = breakerBoundary == "Body only" ? math.max(open[idx], close[idx]) : high[idx]
            float firstBottom = breakerBoundary == "Body only" ? math.min(open[idx], close[idx]) : low[idx]
            int firstOrigin = time[idx]
            if breakerTwoCandles and idx + 1 <= breakerSearch and close[idx + 1] < open[idx + 1]
                firstTop := math.max(firstTop, breakerBoundary == "Body only" ? math.max(open[idx + 1], close[idx + 1]) : high[idx + 1])
                firstBottom := math.min(firstBottom, breakerBoundary == "Body only" ? math.min(open[idx + 1], close[idx + 1]) : low[idx + 1])
                firstOrigin := math.min(firstOrigin, time[idx + 1])
            demandTop := firstTop
            demandBottom := firstBottom
            demandOrigin := firstOrigin
            demandCreated := bar_index
            demandLive := true

    if bearMss
        int idx = na
        for i = 1 to breakerSearch
            if na(idx) and close[i] > open[i] and (not restrictToAM or bInSession[i])
                idx := i
        if not na(idx)
            float firstTop = breakerBoundary == "Body only" ? math.max(open[idx], close[idx]) : high[idx]
            float firstBottom = breakerBoundary == "Body only" ? math.min(open[idx], close[idx]) : low[idx]
            int firstOrigin = time[idx]
            if breakerTwoCandles and idx + 1 <= breakerSearch and close[idx + 1] > open[idx + 1]
                firstTop := math.max(firstTop, breakerBoundary == "Body only" ? math.max(open[idx + 1], close[idx + 1]) : high[idx + 1])
                firstBottom := math.min(firstBottom, breakerBoundary == "Body only" ? math.min(open[idx + 1], close[idx + 1]) : low[idx + 1])
                firstOrigin := math.min(firstOrigin, time[idx + 1])
            supplyTop := firstTop
            supplyBottom := firstBottom
            supplyOrigin := firstOrigin
            supplyCreated := bar_index
            supplyLive := true

    int bullCount = int(math.sum(bullBreaker ? 1 : 0, scanBars))
    int bearCount = int(math.sum(bearBreaker ? 1 : 0, scanBars))
    [bullBreaker, bullOrigin, time_close, bullTop, bullBottom, bullCount, bearBreaker, bearOrigin, time_close, bearTop, bearBottom, bearCount]

f_breakerConfirmed(int scanBars, int pivotStrength, int maxAge, bool restrictToAM) =>
    [be, bo, bc, bt, bb, bcnt, se, so, sc, st, sb, scnt] = f_breakerEngine(scanBars, pivotStrength, maxAge, restrictToAM)
    [be[1], bo[1], bc[1], bt[1], bb[1], bcnt[1], se[1], so[1], sc[1], st[1], sb[1], scnt[1]]

f_amBundle(int swingStrength, float maxTicks, int breakerScanBars, int breakerAge) =>
    [de, dor, dc, dp, dd, ds, dst, dstat, se, sor, sc, sp, sd, ss, sst, sstat] = f_amEngine(swingStrength, maxTicks)
    [bde, bdor, bdc, bdtop, bdbot, bdcnt, bse, bsor, bsc, bstop, bsbot, bscnt] = f_breakerEngine(breakerScanBars, swingStrength, breakerAge, true)
    [de[1], dor[1], dc[1], dp[1], dd[1], ds[1], dst[1], dstat[1], se[1], sor[1], sc[1], sp[1], sd[1], ss[1], sst[1], sstat[1], bde[1], bdor[1], bdc[1], bdtop[1], bdbot[1], bdcnt[1], bse[1], bsor[1], bsc[1], bstop[1], bsbot[1], bscnt[1]]

int dailyScanBars = syminfo.type == "crypto" ? dailyDays : int(math.ceil(dailyDays * 5.0 / 7.0))
int h4ScanBars = h4Weeks * (syminfo.type == "crypto" ? 7 : 5) * 6
[dDE, dDO, dDC, dDP, dDD, dDS, dDSw, dDF, dDStage, dDSignals, dSE, dSO, dSC, dSP, dSD, dSS, dSSw, dSF, dSStage, dSSignals] = request.security(syminfo.tickerid, "1D", f_confirmed(dailyRetracePips, dailyRetraceAtr, dailyMaxWidth, dailyScanBars), lookahead = barmerge.lookahead_on)
[hDE, hDO, hDC, hDP, hDD, hDS, hDSw, hDF, hDStage, hDSignals, hSE, hSO, hSC, hSP, hSD, hSS, hSSw, hSF, hSStage, hSSignals] = request.security(syminfo.tickerid, "240", f_confirmed(h4RetracePips, h4RetraceAtr, h4MaxWidth, h4ScanBars), lookahead = barmerge.lookahead_on)
[dBDE, dBDO, dBDC, dBDTop, dBDBottom, dBDCount, dBSE, dBSO, dBSC, dBSTop, dBSBottom, dBSCount] = request.security(syminfo.tickerid, "1D", f_breakerConfirmed(dailyScanBars, breakerPivot, breakerMaxAge, false), lookahead = barmerge.lookahead_on)
[hBDE, hBDO, hBDC, hBDTop, hBDBottom, hBDCount, hBSE, hBSO, hBSC, hBSTop, hBSBottom, hBSCount] = request.security(syminfo.tickerid, "240", f_breakerConfirmed(h4ScanBars, breakerPivot, breakerMaxAge, false), lookahead = barmerge.lookahead_on)
[m15DE, m15DO, m15DC, m15DP, m15DD, m15DS, m15DStage, m15DStats, m15SE, m15SO, m15SC, m15SP, m15SD, m15SS, m15SStage, m15SStats, m15BDE, m15BDO, m15BDC, m15BDTop, m15BDBottom, m15BDCount, m15BSE, m15BSO, m15BSC, m15BSTop, m15BSBottom, m15BSCount] = request.security(syminfo.tickerid, "15", f_amBundle(m15Swing, amMaxTicks, 80, 20), lookahead = barmerge.lookahead_on)
[m5DE, m5DO, m5DC, m5DP, m5DD, m5DS, m5DStage, m5DStats, m5SE, m5SO, m5SC, m5SP, m5SD, m5SS, m5SStage, m5SStats, m5BDE, m5BDO, m5BDC, m5BDTop, m5BDBottom, m5BDCount, m5BSE, m5BSO, m5BSC, m5BSTop, m5BSBottom, m5BSCount] = request.security(syminfo.tickerid, "5", f_amBundle(m5Swing, amMaxTicks, 240, 30), lookahead = barmerge.lookahead_on)
int m15DSignals = int(math.floor(m15DStats / 10000))
int m15DCandidates = int(math.floor((m15DStats % 10000) / 100))
int m15DWidthRejects = m15DStats % 100
int m15SSignals = int(math.floor(m15SStats / 10000))
int m15SCandidates = int(math.floor((m15SStats % 10000) / 100))
int m15SWidthRejects = m15SStats % 100
int m5DSignals = int(math.floor(m5DStats / 10000))
int m5DCandidates = int(math.floor((m5DStats % 10000) / 100))
int m5DWidthRejects = m5DStats % 100
int m5SSignals = int(math.floor(m5SStats / 10000))
int m5SCandidates = int(math.floor((m5SStats % 10000) / 100))
int m5SWidthRejects = m5SStats % 100

// ── Zone store and lifecycle ────────────────────────────────────────────────
type Zone
    box bx
    label lb
    string tf
    int dir
    int origin
    int confirmed
    float proximal
    float distal
    int score
    string classification
    string status
    bool visible

var zones = array.new<Zone>()
var int lastDD = na
var int lastDS = na
var int lastHD = na
var int lastHS = na
var int lastDBD = na
var int lastDBS = na
var int lastHBD = na
var int lastHBS = na
var int lastM15D = na
var int lastM15S = na
var int lastM5D = na
var int lastM5S = na
var int lastM15BD = na
var int lastM15BS = na
var int lastM5BD = na
var int lastM5BS = na
var bool anyNew = false
var bool anyTouch = false
var bool anyInvalid = false
anyNew := false, anyTouch := false, anyInvalid := false

f_layerCount(string tf) =>
    int n = 0
    for z in zones
        if z.tf == tf
            n += 1
    n

f_classCount(string tf, string needle) =>
    int n = 0
    for z in zones
        if z.tf == tf and str.contains(z.classification, needle)
            n += 1
    n

f_directionCount(string tf, int dir) =>
    int n = 0
    for z in zones
        if z.tf == tf and z.dir == dir
            n += 1
    n

f_trim(string tf) =>
    int layerLimit = tf == "M15" ? math.min(100, maxM15Session * 2 * amRetentionDays) : tf == "M5" ? math.min(120, maxM5Session * 2 * amRetentionDays) : maxPerLayer
    if f_layerCount(tf) > layerLimit
        for i = 0 to array.size(zones) - 1
            Zone z = array.get(zones, i)
            if z.tf == tf
                box.delete(z.bx)
                if not na(z.lb)
                    label.delete(z.lb)
                array.remove(zones, i)
                break

f_add(string tf, int dir, int origin, int confirmed, float proximal, float distal, int score, bool swept, bool fvg, color clr, bool layerVisible, string klassOverride) =>
    float top = math.max(proximal, distal), bottom = math.min(proximal, distal)
    string side = dir == 1 ? "Demand" : "Supply"
    string klass = klassOverride != "" ? klassOverride : swept ? "Liquidity-sweep POI" : fvg ? "Imbalance POI" : "Qualified POI"
    bool intradayZone = tf == "M15" or tf == "M5"
    string widthText = intradayZone and showTickWidth ? " | " + str.tostring(math.round((top - bottom) / syminfo.mintick)) + "t" : ""
    bool incomingBreaker = str.contains(klass, "Breaker")
    bool merged = false
    if array.size(zones) > 0
        for i = array.size(zones) - 1 to 0
            Zone z = array.get(zones, i)
            float zTop = math.max(z.proximal, z.distal)
            float zBottom = math.min(z.proximal, z.distal)
            float shared = math.max(0.0, math.min(top, zTop) - math.max(bottom, zBottom))
            float smallerWidth = math.max(math.min(top - bottom, zTop - zBottom), syminfo.mintick)
            bool existingBreaker = str.contains(z.classification, "Breaker")
            bool mergeOK = not merged and z.tf == tf and z.dir == dir and z.status != "Invalidated" and shared / smallerWidth >= breakerMergeRatio and (incomingBreaker or existingBreaker)
            if mergeOK
                float mergedTop = math.min(top, zTop)
                float mergedBottom = math.max(bottom, zBottom)
                z.proximal := dir == 1 ? mergedTop : mergedBottom
                z.distal := dir == 1 ? mergedBottom : mergedTop
                z.origin := math.min(z.origin, origin)
                z.confirmed := math.max(z.confirmed, confirmed)
                z.score := math.min(100, math.max(z.score, score) + breakerBonus)
                z.classification := "Breaker-confluent POI"
                box.set_left(z.bx, z.origin)
                box.set_top(z.bx, mergedTop)
                box.set_bottom(z.bx, mergedBottom)
                if not na(z.lb)
                    label.set_xy(z.lb, z.origin, dir == 1 ? mergedBottom : mergedTop)
                    label.set_text(z.lb, tf + " " + side + " | " + str.tostring(z.score) + widthText + "\n" + z.classification)
                array.set(zones, i, z)
                merged := true
    if not merged
        box b = box.new(origin, top, time, bottom, xloc = xloc.bar_time, extend = extend.right, border_color = layerVisible ? clr : color.new(clr, 100), bgcolor = layerVisible ? color.new(clr, fillTransparency) : color.new(clr, 100))
        label l = na
        if showLabels and layerVisible
            l := label.new(origin, dir == 1 ? bottom : top, tf + " " + side + " | " + str.tostring(score) + widthText + "\n" + klass, xloc = xloc.bar_time, style = dir == 1 ? label.style_label_up : label.style_label_down, color = color.new(clr, 15), textcolor = color.white, size = size.tiny)
        array.push(zones, Zone.new(b, l, tf, dir, origin, confirmed, proximal, distal, score, klass, "Fresh", layerVisible))
        f_trim(tf)

f_removeZone(int idx) =>
    Zone z = array.get(zones, idx)
    box.delete(z.bx)
    if not na(z.lb)
        label.delete(z.lb)
    array.remove(zones, idx)

f_amAlertMessage(string tf, int dir, int score, float proximal, float distal, int origin, int confirmed, string status) =>
    float top = math.max(proximal, distal)
    float bottom = math.min(proximal, distal)
    string side = dir == 1 ? "Demand" : "Supply"
    tf + " " + side + " | " + syminfo.ticker + " | score " + str.tostring(score) + " | " + str.tostring(math.round((top - bottom) / syminfo.mintick)) + " ticks | " + str.tostring(bottom, format.mintick) + "-" + str.tostring(top, format.mintick) + " | origin " + str.format_time(origin, "yyyy-MM-dd HH:mm", amTimezone) + " | confirmed " + str.format_time(confirmed, "yyyy-MM-dd HH:mm", amTimezone) + " | " + status

f_trimAMSession(string tf, int dir, int limit) =>
    int currentDay = year(time, amTimezone) * 10000 + month(time, amTimezone) * 100 + dayofmonth(time, amTimezone)
    int count = 0
    int weakest = na
    int weakestScore = 101
    int oldestOrigin = na
    if array.size(zones) > 0
        for i = 0 to array.size(zones) - 1
            Zone z = array.get(zones, i)
            int zoneDay = year(z.origin, amTimezone) * 10000 + month(z.origin, amTimezone) * 100 + dayofmonth(z.origin, amTimezone)
            if z.tf == tf and z.dir == dir and zoneDay == currentDay
                count += 1
                if z.score < weakestScore or z.score == weakestScore and (na(oldestOrigin) or z.origin < oldestOrigin)
                    weakest := i
                    weakestScore := z.score
                    oldestOrigin := z.origin
    if count > limit and not na(weakest)
        f_removeZone(weakest)

f_trimAMTotal() =>
    int count = 0
    int weakest = na
    int weakestScore = 101
    int oldestOrigin = na
    if array.size(zones) > 0
        for i = 0 to array.size(zones) - 1
            Zone z = array.get(zones, i)
            if z.tf == "M15" or z.tf == "M5"
                count += 1
                if z.score < weakestScore or z.score == weakestScore and (na(oldestOrigin) or z.origin < oldestOrigin)
                    weakest := i
                    weakestScore := z.score
                    oldestOrigin := z.origin
    if count > maxIntradayTotal and not na(weakest)
        f_removeZone(weakest)

int dayMs = 86400000
int dCutoff = time - dailyDays * dayMs
int hCutoff = time - h4Weeks * 7 * dayMs
int amCutoff = time - amRetentionDays * dayMs
// The explicit na() branch is essential. In Pine, comparing a value with an
// uninitialized `na` ID does not return true. Without this branch, the first
// event can never initialize its ID, permanently blocking every later zone.
bool newDD = dDE and (na(lastDD) or dDC != lastDD) and dDO >= dCutoff
bool newDS = dSE and (na(lastDS) or dSC != lastDS) and dSO >= dCutoff
bool newHD = hDE and (na(lastHD) or hDC != lastHD) and hDO >= hCutoff
bool newHS = hSE and (na(lastHS) or hSC != lastHS) and hSO >= hCutoff
bool newDBD = breakerStandalone and dBDE and (na(lastDBD) or dBDC != lastDBD) and dBDO >= dCutoff
bool newDBS = breakerStandalone and dBSE and (na(lastDBS) or dBSC != lastDBS) and dBSO >= dCutoff
bool newHBD = breakerStandalone and hBDE and (na(lastHBD) or hBDC != lastHBD) and hBDO >= hCutoff
bool newHBS = breakerStandalone and hBSE and (na(lastHBS) or hBSC != lastHBS) and hBSO >= hCutoff
bool newM15D = m15LayerOn and showAMDemand and m15DE and close > m15DP and (na(lastM15D) or m15DC != lastM15D) and m15DO >= amCutoff
bool newM15S = m15LayerOn and showAMSupply and m15SE and close < m15SP and (na(lastM15S) or m15SC != lastM15S) and m15SO >= amCutoff
bool newM5D = m5LayerOn and showAMDemand and m5DE and close > m5DP and (na(lastM5D) or m5DC != lastM5D) and m5DO >= amCutoff
bool newM5S = m5LayerOn and showAMSupply and m5SE and close < m5SP and (na(lastM5S) or m5SC != lastM5S) and m5SO >= amCutoff
bool newM15BD = amInstrumentOK and m15LayerOn and showAMDemand and breakerStandalone and m15BDE and close > m15BDTop and (m15BDTop - m15BDBottom) / syminfo.mintick <= amMaxTicks and (na(lastM15BD) or m15BDC != lastM15BD) and m15BDO >= amCutoff
bool newM15BS = amInstrumentOK and m15LayerOn and showAMSupply and breakerStandalone and m15BSE and close < m15BSBottom and (m15BSTop - m15BSBottom) / syminfo.mintick <= amMaxTicks and (na(lastM15BS) or m15BSC != lastM15BS) and m15BSO >= amCutoff
bool newM5BD = amInstrumentOK and m5LayerOn and showAMDemand and breakerStandalone and m5BDE and close > m5BDTop and (m5BDTop - m5BDBottom) / syminfo.mintick <= amMaxTicks and (na(lastM5BD) or m5BDC != lastM5BD) and m5BDO >= amCutoff
bool newM5BS = amInstrumentOK and m5LayerOn and showAMSupply and breakerStandalone and m5BSE and close < m5BSBottom and (m5BSTop - m5BSBottom) / syminfo.mintick <= amMaxTicks and (na(lastM5BS) or m5BSC != lastM5BS) and m5BSO >= amCutoff
if newDD
    f_add("D", 1, dDO, dDC, dDP, dDD, dDS, dDSw, dDF, dDemand, showD, "")
    lastDD := dDC
    anyNew := true
if newDS
    f_add("D", -1, dSO, dSC, dSP, dSD, dSS, dSSw, dSF, dSupply, showD, "")
    lastDS := dSC
    anyNew := true
if newHD
    f_add("H4", 1, hDO, hDC, hDP, hDD, hDS, hDSw, hDF, hDemand, showH4, "")
    lastHD := hDC
    anyNew := true
if newHS
    f_add("H4", -1, hSO, hSC, hSP, hSD, hSS, hSSw, hSF, hSupply, showH4, "")
    lastHS := hSC
    anyNew := true
if newDBD
    f_add("D", 1, dBDO, dBDC, dBDTop, dBDBottom, breakerScore, false, false, dDemand, showD, "Bullish Breaker POI")
    lastDBD := dBDC
    anyNew := true
if newDBS
    f_add("D", -1, dBSO, dBSC, dBSBottom, dBSTop, breakerScore, false, false, dSupply, showD, "Bearish Breaker POI")
    lastDBS := dBSC
    anyNew := true
if newHBD
    f_add("H4", 1, hBDO, hBDC, hBDTop, hBDBottom, breakerScore, false, false, hDemand, showH4, "Bullish Breaker POI")
    lastHBD := hBDC
    anyNew := true
if newHBS
    f_add("H4", -1, hBSO, hBSC, hBSBottom, hBSTop, breakerScore, false, false, hSupply, showH4, "Bearish Breaker POI")
    lastHBS := hBSC
    anyNew := true
if newM15D
    f_add("M15", 1, m15DO, m15DC, m15DP, m15DD, m15DS, false, false, m15Demand, m15LayerOn, "AM Session POI")
    lastM15D := m15DC
    anyNew := true
    if alertNew
        alert(f_amAlertMessage("M15", 1, m15DS, m15DP, m15DD, m15DO, m15DC, "Fresh"), alert.freq_once_per_bar_close)
if newM15S
    f_add("M15", -1, m15SO, m15SC, m15SP, m15SD, m15SS, false, false, m15Supply, m15LayerOn, "AM Session POI")
    lastM15S := m15SC
    anyNew := true
    if alertNew
        alert(f_amAlertMessage("M15", -1, m15SS, m15SP, m15SD, m15SO, m15SC, "Fresh"), alert.freq_once_per_bar_close)
if newM5D
    f_add("M5", 1, m5DO, m5DC, m5DP, m5DD, m5DS, false, false, m5Demand, m5LayerOn, "AM Session POI")
    lastM5D := m5DC
    anyNew := true
    if alertNew
        alert(f_amAlertMessage("M5", 1, m5DS, m5DP, m5DD, m5DO, m5DC, "Fresh"), alert.freq_once_per_bar_close)
if newM5S
    f_add("M5", -1, m5SO, m5SC, m5SP, m5SD, m5SS, false, false, m5Supply, m5LayerOn, "AM Session POI")
    lastM5S := m5SC
    anyNew := true
    if alertNew
        alert(f_amAlertMessage("M5", -1, m5SS, m5SP, m5SD, m5SO, m5SC, "Fresh"), alert.freq_once_per_bar_close)
if newM15BD
    f_add("M15", 1, m15BDO, m15BDC, m15BDTop, m15BDBottom, breakerScore, false, false, m15Demand, m15LayerOn, "AM Bullish Breaker POI")
    lastM15BD := m15BDC
    anyNew := true
    if alertNew
        alert(f_amAlertMessage("M15", 1, breakerScore, m15BDTop, m15BDBottom, m15BDO, m15BDC, "Fresh breaker"), alert.freq_once_per_bar_close)
if newM15BS
    f_add("M15", -1, m15BSO, m15BSC, m15BSBottom, m15BSTop, breakerScore, false, false, m15Supply, m15LayerOn, "AM Bearish Breaker POI")
    lastM15BS := m15BSC
    anyNew := true
    if alertNew
        alert(f_amAlertMessage("M15", -1, breakerScore, m15BSBottom, m15BSTop, m15BSO, m15BSC, "Fresh breaker"), alert.freq_once_per_bar_close)
if newM5BD
    f_add("M5", 1, m5BDO, m5BDC, m5BDTop, m5BDBottom, breakerScore, false, false, m5Demand, m5LayerOn, "AM Bullish Breaker POI")
    lastM5BD := m5BDC
    anyNew := true
    if alertNew
        alert(f_amAlertMessage("M5", 1, breakerScore, m5BDTop, m5BDBottom, m5BDO, m5BDC, "Fresh breaker"), alert.freq_once_per_bar_close)
if newM5BS
    f_add("M5", -1, m5BSO, m5BSC, m5BSBottom, m5BSTop, breakerScore, false, false, m5Supply, m5LayerOn, "AM Bearish Breaker POI")
    lastM5BS := m5BSC
    anyNew := true
    if alertNew
        alert(f_amAlertMessage("M5", -1, breakerScore, m5BSBottom, m5BSTop, m5BSO, m5BSC, "Fresh breaker"), alert.freq_once_per_bar_close)

f_trimAMSession("M15", 1, maxM15Session)
f_trimAMSession("M15", -1, maxM15Session)
f_trimAMSession("M5", 1, maxM5Session)
f_trimAMSession("M5", -1, maxM5Session)
f_trimAMTotal()

if barstate.isconfirmed and array.size(zones) > 0
    for i = array.size(zones) - 1 to 0
        Zone z = array.get(zones, i)
        bool directionOn = z.dir == 1 ? showAMDemand : showAMSupply
        bool layerOn = z.tf == "D" ? showD : z.tf == "H4" ? showH4 : z.tf == "M15" ? m15LayerOn and directionOn : m5LayerOn and directionOn
        color baseColor = z.tf == "D" ? (z.dir == 1 ? dDemand : dSupply) : z.tf == "H4" ? (z.dir == 1 ? hDemand : hSupply) : z.tf == "M15" ? (z.dir == 1 ? m15Demand : m15Supply) : (z.dir == 1 ? m5Demand : m5Supply)
        if z.visible != layerOn
            box.set_border_color(z.bx, layerOn ? baseColor : color.new(baseColor, 100))
            box.set_bgcolor(z.bx, layerOn ? color.new(baseColor, fillTransparency) : color.new(baseColor, 100))
            if not na(z.lb)
                label.set_textcolor(z.lb, layerOn ? color.white : color.new(color.white, 100))
                label.set_color(z.lb, layerOn ? color.new(baseColor, 15) : color.new(baseColor, 100))
            z.visible := layerOn
        bool after = time > z.confirmed
        float top = math.max(z.proximal, z.distal), bottom = math.min(z.proximal, z.distal), mid = (top + bottom) * 0.5
        bool overlap = after and high >= bottom and low <= top
        float mitLevel = mitigation == "Proximal touch" ? z.proximal : mitigation == "Midpoint" ? mid : z.distal
        bool mitigated = after and (z.dir == 1 ? low <= mitLevel : high >= mitLevel)
        bool invalidNow = after and (z.dir == 1 ? (invalidation == "Close beyond distal" ? close < z.distal : low < z.distal) : (invalidation == "Close beyond distal" ? close > z.distal : high > z.distal))
        bool expired = expireDays > 0 and time - z.confirmed > expireDays * dayMs
        bool outsideHistory = z.origin < (z.tf == "D" ? dCutoff : z.tf == "H4" ? hCutoff : amCutoff)
        if invalidNow and z.status != "Invalidated"
            z.status := "Invalidated", anyInvalid := true
            box.set_extend(z.bx, extend.none), box.set_right(z.bx, time), box.set_bgcolor(z.bx, color.new(color.gray, 92)), box.set_border_color(z.bx, color.new(color.gray, 55))
        else if expired and z.status != "Invalidated"
            z.status := "Expired"
            box.set_extend(z.bx, extend.none), box.set_right(z.bx, time)
        else if mitigated and z.status == "Fresh"
            z.status := "Mitigated", anyTouch := true
            box.set_bgcolor(z.bx, color.new(baseColor, math.min(96, fillTransparency + 8)))
        else if overlap and z.status == "Fresh"
            z.status := "Tested", anyTouch := true
            box.set_bgcolor(z.bx, color.new(baseColor, math.min(94, fillTransparency + 5)))
        if outsideHistory or (z.status == "Invalidated" and not keepInvalid)
            box.delete(z.bx)
            if not na(z.lb)
                label.delete(z.lb)
            array.remove(zones, i)
        else
            array.set(zones, i, z)

alertcondition(anyNew and alertNew, "New confirmed POI", "CORTEX: a new confirmed POI was created.")
alertcondition(newDBD or newDBS or newHBD or newHBS, "New breaker POI", "CORTEX: a confirmed Daily/H4 breaker POI was created.")
alertcondition(newM15D, "New M15 demand POI", "CORTEX {{ticker}}: new confirmed M15 AM-session demand POI.")
alertcondition(newM15S, "New M15 supply POI", "CORTEX {{ticker}}: new confirmed M15 AM-session supply POI.")
alertcondition(newM5D, "New M5 demand POI", "CORTEX {{ticker}}: new confirmed M5 AM-session demand POI.")
alertcondition(newM5S, "New M5 supply POI", "CORTEX {{ticker}}: new confirmed M5 AM-session supply POI.")
alertcondition(newM15BD or newM15BS or newM5BD or newM5BS, "New intraday breaker POI", "CORTEX {{ticker}}: new confirmed AM-session breaker POI.")
alertcondition((newM15D or newM15S) and (newM15BD or newM15BS) or (newM5D or newM5S) and (newM5BD or newM5BS), "Intraday breaker confluence", "CORTEX {{ticker}}: AM-session POI and breaker confluence confirmed.")
alertcondition(anyTouch and alertTouch, "POI first test / mitigation", "CORTEX: price first tested or mitigated a POI.")
alertcondition(anyInvalid and alertInvalid, "POI invalidated", "CORTEX: a POI was invalidated on a confirmed chart bar.")

// Data Window diagnostics (last confirmed source events).
plot(dDS, "Daily demand score", display = display.data_window)
plot(dSS, "Daily supply score", display = display.data_window)
plot(hDS, "H4 demand score", display = display.data_window)
plot(hSS, "H4 supply score", display = display.data_window)
plot(m15DS, "M15 AM demand score", display = display.data_window)
plot(m15SS, "M15 AM supply score", display = display.data_window)
plot(m5DS, "M5 AM demand score", display = display.data_window)
plot(m5SS, "M5 AM supply score", display = display.data_window)
plot(amMaxTicks, "AM maximum width (ticks)", display = display.data_window)

f_stageText(int stage) =>
    stage == 5 ? "POI created" : stage == 4 ? "Score / mode rejected" : stage == 3 ? "Waiting for BOS" : stage == 2 ? "Departure found" : stage == 1 ? "Base; no departure" : "No valid base"

f_amStageText(int stage) =>
    stage == 7 ? "Unsupported instrument" : stage == 6 ? "POI created" : stage == 5 ? "Score / mode rejected" : stage == 4 ? "Width rejected" : stage == 3 ? "Waiting for BOS" : stage == 2 ? "Base; no departure" : stage == 1 ? "No valid base" : "Outside session"

var table diagnostics = table.new(position.top_right, 4, 16, border_width = 1)
if barstate.islast and showDiagnostics
    table.cell(diagnostics, 0, 0, "CORTEX diagnostics", bgcolor = color.rgb(28, 32, 40), text_color = color.white)
    table.cell(diagnostics, 1, 0, "Latest confirmed stage", bgcolor = color.rgb(28, 32, 40), text_color = color.white)
    table.cell(diagnostics, 2, 0, "Signals (approx.)", bgcolor = color.rgb(28, 32, 40), text_color = color.white)
    table.cell(diagnostics, 3, 0, "Zones retained", bgcolor = color.rgb(28, 32, 40), text_color = color.white)
    table.cell(diagnostics, 0, 1, "Daily demand")
    table.cell(diagnostics, 1, 1, f_stageText(dDStage))
    table.cell(diagnostics, 2, 1, str.tostring(dDSignals))
    table.cell(diagnostics, 3, 1, str.tostring(f_directionCount("D", 1)))
    table.cell(diagnostics, 0, 2, "Daily supply")
    table.cell(diagnostics, 1, 2, f_stageText(dSStage))
    table.cell(diagnostics, 2, 2, str.tostring(dSSignals))
    table.cell(diagnostics, 3, 2, str.tostring(f_directionCount("D", -1)))
    table.cell(diagnostics, 0, 3, "H4 demand")
    table.cell(diagnostics, 1, 3, f_stageText(hDStage))
    table.cell(diagnostics, 2, 3, str.tostring(hDSignals))
    table.cell(diagnostics, 3, 3, str.tostring(f_directionCount("H4", 1)))
    table.cell(diagnostics, 0, 4, "H4 supply")
    table.cell(diagnostics, 1, 4, f_stageText(hSStage))
    table.cell(diagnostics, 2, 4, str.tostring(hSSignals))
    table.cell(diagnostics, 3, 4, str.tostring(f_directionCount("H4", -1)))
    table.cell(diagnostics, 0, 5, "Daily breakers")
    table.cell(diagnostics, 1, 5, breakerEnabled ? "Confirmed flips" : "Disabled")
    table.cell(diagnostics, 2, 5, str.tostring(dBDCount) + " / " + str.tostring(dBSCount))
    table.cell(diagnostics, 3, 5, str.tostring(f_classCount("D", "Breaker")))
    table.cell(diagnostics, 0, 6, "H4 breakers")
    table.cell(diagnostics, 1, 6, breakerEnabled ? "Confirmed flips" : "Disabled")
    table.cell(diagnostics, 2, 6, str.tostring(hBDCount) + " / " + str.tostring(hBSCount))
    table.cell(diagnostics, 3, 6, str.tostring(f_classCount("H4", "Breaker")))
    table.cell(diagnostics, 0, 7, "M15 demand")
    table.cell(diagnostics, 1, 7, m15DE and close <= m15DP ? "Already tested / misplaced" : f_amStageText(m15DStage))
    table.cell(diagnostics, 2, 7, str.tostring(m15DSignals) + "/" + str.tostring(m15DCandidates) + "/" + str.tostring(m15DWidthRejects))
    table.cell(diagnostics, 3, 7, str.tostring(f_directionCount("M15", 1)))
    table.cell(diagnostics, 0, 8, "M15 supply")
    table.cell(diagnostics, 1, 8, m15SE and close >= m15SP ? "Already tested / misplaced" : f_amStageText(m15SStage))
    table.cell(diagnostics, 2, 8, str.tostring(m15SSignals) + "/" + str.tostring(m15SCandidates) + "/" + str.tostring(m15SWidthRejects))
    table.cell(diagnostics, 3, 8, str.tostring(f_directionCount("M15", -1)))
    table.cell(diagnostics, 0, 9, "M5 demand")
    table.cell(diagnostics, 1, 9, m5DE and close <= m5DP ? "Already tested / misplaced" : f_amStageText(m5DStage))
    table.cell(diagnostics, 2, 9, str.tostring(m5DSignals) + "/" + str.tostring(m5DCandidates) + "/" + str.tostring(m5DWidthRejects))
    table.cell(diagnostics, 3, 9, str.tostring(f_directionCount("M5", 1)))
    table.cell(diagnostics, 0, 10, "M5 supply")
    table.cell(diagnostics, 1, 10, m5SE and close >= m5SP ? "Already tested / misplaced" : f_amStageText(m5SStage))
    table.cell(diagnostics, 2, 10, str.tostring(m5SSignals) + "/" + str.tostring(m5SCandidates) + "/" + str.tostring(m5SWidthRejects))
    table.cell(diagnostics, 3, 10, str.tostring(f_directionCount("M5", -1)))
    table.cell(diagnostics, 0, 11, "M15 breakers")
    table.cell(diagnostics, 1, 11, breakerEnabled ? "Confirmed flips" : "Disabled")
    table.cell(diagnostics, 2, 11, str.tostring(m15BDCount) + " / " + str.tostring(m15BSCount))
    table.cell(diagnostics, 3, 11, str.tostring(f_classCount("M15", "Breaker")))
    table.cell(diagnostics, 0, 12, "M5 breakers")
    table.cell(diagnostics, 1, 12, breakerEnabled ? "Confirmed flips" : "Disabled")
    table.cell(diagnostics, 2, 12, str.tostring(m5BDCount) + " / " + str.tostring(m5BSCount))
    table.cell(diagnostics, 3, 12, str.tostring(f_classCount("M5", "Breaker")))
    table.cell(diagnostics, 0, 13, "AM session / instrument")
    table.cell(diagnostics, 1, 13, chartInAMSession ? "In session" : "Outside session")
    table.cell(diagnostics, 2, 13, detectedAMInstrument + " / " + str.tostring(amMaxTicks) + "t", text_color = amInstrumentOK ? color.green : color.orange)
    table.cell(diagnostics, 3, 13, amChartSupported ? "Chart TF OK" : "Use M15 or M5", text_color = amChartSupported ? color.green : color.orange)
    table.cell(diagnostics, 0, 14, "Mode / threshold")
    table.cell(diagnostics, 1, 14, mode)
    table.cell(diagnostics, 2, 14, str.tostring(mode == "Loose" ? 50 : mode == "Balanced" ? 60 : mode == "Strict" ? 75 : customScore))
    table.cell(diagnostics, 3, 14, "Confirmed only")
    table.cell(diagnostics, 0, 15, "Display")
    table.cell(diagnostics, 1, 15, (showD ? "D" : "") + "/" + (showH4 ? "H4" : "") + "/" + (m15LayerOn ? "M15" : "") + "/" + (m5LayerOn ? "M5" : ""))
    table.cell(diagnostics, 2, 15, "Sig/Cand/Width rej")
    table.cell(diagnostics, 3, 15, "NY session")
else if barstate.islast
    table.clear(diagnostics, 0, 0, 3, 15)
````
