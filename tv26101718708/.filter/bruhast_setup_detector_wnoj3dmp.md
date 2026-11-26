# Bruhast Setup Detector

- url: https://www.tradingview.com/script/wnoJ3dmP-Bruhast-Setup-Detector/
- type: indicator
- pine_id: PUB;a933b2a0d1954a249bc97ea85f8c1dcf
- version: 1.0

## Description

// Purpose: detect high-quality price-action setups and fire structured webhook alerts.
// This script does NOT execute trades. Validation, regime, options, and scoring happen in the app backend.

## Source Code

````pine
//@version=5
// Bruhast Market Intel — Setup Detection Layer
// Purpose: detect high-quality price-action setups and fire structured webhook alerts.
// This script does NOT execute trades. Validation, regime, options, and scoring happen in the app backend.
indicator(
     title="Bruhast Setup Detector",
     shorttitle="Bruhast Setups",
     overlay=true,
     max_labels_count=500,
     max_lines_count=100)
// Non-repainting: all signals require barstate.isconfirmed (evaluated on bar close only).

// =============================================================================
// CONSTANTS
// =============================================================================

const string STRATEGY_NAME = "Bruhast Setup Detector"
const string SETUP_INSIDE_BULL   = "inside_bar_bullish"
const string SETUP_INSIDE_BEAR   = "inside_bar_bearish"
const string SETUP_ATH_BULL      = "ath_breakout_bullish"
const string SETUP_GAP_BULL      = "gap_fill_bullish_reversal"
const string SETUP_GAP_BEAR      = "gap_fill_bearish_continuation"
const string SETUP_OUTSIDE_BULL  = "outside_bar_bullish"
const string SETUP_OUTSIDE_BEAR  = "outside_bar_bearish"

// alertcondition() requires const string messages (TradingView substitutes {{placeholders}} at fire time).
const string ALERT_INSIDE_BULL = '{"symbol":"{{ticker}}","ticker":"{{ticker}}","exchange":"{{exchange}}","timeframe":"{{interval}}","interval":"{{interval}}","action":"long","direction":"long","setup":"inside_bar_bullish","price":{{close}},"close":{{close}},"volume":{{volume}},"strategy":"Bruhast Setup Detector","timestamp":"{{timenow}}","source":"tradingview"}'
const string ALERT_INSIDE_BEAR = '{"symbol":"{{ticker}}","ticker":"{{ticker}}","exchange":"{{exchange}}","timeframe":"{{interval}}","interval":"{{interval}}","action":"short","direction":"short","setup":"inside_bar_bearish","price":{{close}},"close":{{close}},"volume":{{volume}},"strategy":"Bruhast Setup Detector","timestamp":"{{timenow}}","source":"tradingview"}'
const string ALERT_ATH_BULL    = '{"symbol":"{{ticker}}","ticker":"{{ticker}}","exchange":"{{exchange}}","timeframe":"{{interval}}","interval":"{{interval}}","action":"long","direction":"long","setup":"ath_breakout_bullish","price":{{close}},"close":{{close}},"volume":{{volume}},"strategy":"Bruhast Setup Detector","timestamp":"{{timenow}}","source":"tradingview"}'
const string ALERT_GAP_BULL    = '{"symbol":"{{ticker}}","ticker":"{{ticker}}","exchange":"{{exchange}}","timeframe":"{{interval}}","interval":"{{interval}}","action":"long","direction":"long","setup":"gap_fill_bullish_reversal","price":{{close}},"close":{{close}},"volume":{{volume}},"strategy":"Bruhast Setup Detector","timestamp":"{{timenow}}","source":"tradingview"}'
const string ALERT_GAP_BEAR    = '{"symbol":"{{ticker}}","ticker":"{{ticker}}","exchange":"{{exchange}}","timeframe":"{{interval}}","interval":"{{interval}}","action":"short","direction":"short","setup":"gap_fill_bearish_continuation","price":{{close}},"close":{{close}},"volume":{{volume}},"strategy":"Bruhast Setup Detector","timestamp":"{{timenow}}","source":"tradingview"}'
const string ALERT_OUTSIDE_BULL = '{"symbol":"{{ticker}}","ticker":"{{ticker}}","exchange":"{{exchange}}","timeframe":"{{interval}}","interval":"{{interval}}","action":"long","direction":"long","setup":"outside_bar_bullish","price":{{close}},"close":{{close}},"volume":{{volume}},"strategy":"Bruhast Setup Detector","timestamp":"{{timenow}}","source":"tradingview"}'
const string ALERT_OUTSIDE_BEAR = '{"symbol":"{{ticker}}","ticker":"{{ticker}}","exchange":"{{exchange}}","timeframe":"{{interval}}","interval":"{{interval}}","action":"short","direction":"short","setup":"outside_bar_bearish","price":{{close}},"close":{{close}},"volume":{{volume}},"strategy":"Bruhast Setup Detector","timestamp":"{{timenow}}","source":"tradingview"}'

// =============================================================================
// INPUTS — SETUP TYPES
// =============================================================================

string GRP_SETUPS = "Setup Types"
bool   enableInsideBar   = input.bool(true,  "Inside Bar Breakout",        group=GRP_SETUPS)
bool   enableAthBreakout = input.bool(true,  "ATH Breakout",               group=GRP_SETUPS)
bool   enableGapFill     = input.bool(true,  "Gap Fill Setup",             group=GRP_SETUPS)
bool   enableOutsideBar  = input.bool(true,  "Outside Bar Expansion",      group=GRP_SETUPS)

// =============================================================================
// INPUTS — GENERAL FILTERS
// =============================================================================

string GRP_FILTERS = "General Filters"
bool   useMinVolume      = input.bool(true,  "Minimum Volume Filter",      group=GRP_FILTERS)
int    minVolume         = input.int(100000, "Minimum Volume", minval=0, step=10000, group=GRP_FILTERS)
bool   useRvolFilter     = input.bool(true,  "Relative Volume Filter",     group=GRP_FILTERS)
int    rvolLookback      = input.int(20,     "RVOL Lookback", minval=5, group=GRP_FILTERS)
float  rvolThreshold     = input.float(1.2,  "RVOL Threshold", minval=0.1, step=0.1, group=GRP_FILTERS)
bool   useAtrFilter      = input.bool(true,  "ATR Range Filter",           group=GRP_FILTERS)
int    atrLength         = input.int(14,     "ATR Length", minval=1, group=GRP_FILTERS)
float  atrMinMult        = input.float(0.5,  "Min Bar Range (× ATR)", minval=0.1, step=0.1, group=GRP_FILTERS)
bool   useMinPrice       = input.bool(true,  "Minimum Price Filter",       group=GRP_FILTERS)
float  minPrice          = input.float(5.0,  "Minimum Price ($)", minval=0.01, step=0.5, group=GRP_FILTERS)
bool   useEmaTrendFilter = input.bool(true,  "EMA Trend Filter",           group=GRP_FILTERS)
int    emaLength         = input.int(20,     "EMA Length", minval=1, group=GRP_FILTERS)
bool   useSessionFilter  = input.bool(false, "Market Session Filter",     group=GRP_FILTERS)
string sessionWindow     = input.session("0930-1600", "Session (Exchange TZ)", group=GRP_FILTERS)
bool   useIndexAlignment = input.bool(false, "SPY/QQQ Trend Alignment",    group=GRP_FILTERS)
string indexSymbol       = input.string("SPY", "Index Symbol", options=["SPY", "QQQ"], group=GRP_FILTERS)

// =============================================================================
// INPUTS — INSIDE BAR
// =============================================================================

string GRP_INSIDE = "Inside Bar Settings"
bool   insideUseEmaSide = input.bool(true, "Require EMA Side Alignment", group=GRP_INSIDE)

// =============================================================================
// INPUTS — ATH BREAKOUT
// =============================================================================

string GRP_ATH = "ATH Breakout Settings"
int    athLookback         = input.int(252,   "Highest High Lookback", minval=20, group=GRP_ATH)
bool   athRequireRvol      = input.bool(true,  "Require RVOL on Breakout", group=GRP_ATH)
bool   athRequireConsol    = input.bool(false, "Require Consolidation", group=GRP_ATH)
int    athConsolBars       = input.int(5,      "Consolidation Bars", minval=2, group=GRP_ATH)
float  athConsolProximity  = input.float(3.0, "Consolidation Proximity (%)", minval=0.5, step=0.5, group=GRP_ATH)

// =============================================================================
// INPUTS — GAP FILL
// =============================================================================

string GRP_GAP = "Gap Fill Settings"
float  gapMinPct       = input.float(1.0,  "Minimum Gap Size (%)", minval=0.1, step=0.1, group=GRP_GAP)
float  gapPartialPct   = input.float(50.0, "Partial Fill (%)", minval=10, maxval=90, group=GRP_GAP)
bool   gapAllowPartial = input.bool(true,  "Allow Partial Fill Triggers", group=GRP_GAP)
bool   gapAllowFull    = input.bool(true,  "Allow Full Fill Triggers", group=GRP_GAP)

// =============================================================================
// INPUTS — OUTSIDE BAR
// =============================================================================

string GRP_OUTSIDE = "Outside Bar Settings"
float  outsideMinBodyPct = input.float(40.0, "Min Body vs Range (%)", minval=0, maxval=100, group=GRP_OUTSIDE)

// =============================================================================
// INPUTS — ALERTS
// =============================================================================

string GRP_ALERTS = "Alerts"
bool enableDynamicAlerts = input.bool(false, "Enable alert() Calls (optional)", tooltip="Off by default. Use alertcondition-based alerts to avoid duplicate webhook fires.", group=GRP_ALERTS)

// =============================================================================
// INPUTS — VISUALS
// =============================================================================

string GRP_VISUAL = "Visuals"
bool   showEma           = input.bool(true,  "Show EMA", group=GRP_VISUAL)
bool   showSetupMarkers  = input.bool(true,  "Show Setup Markers", group=GRP_VISUAL)
bool   showBreakoutLevels = input.bool(false, "Show Breakout Levels", group=GRP_VISUAL)

// =============================================================================
// HELPER FUNCTIONS — FILTERS
// =============================================================================

// Average relative volume vs lookback SMA.
f_rvol(_lookback) =>
    float avgVol = ta.sma(volume, _lookback)
    avgVol > 0 ? volume / avgVol : 0.0

// True when bar range meets minimum ATR expansion.
f_atrRangeOk(_atrLen, _mult) =>
    float atrVal = ta.atr(_atrLen)
    (high - low) >= atrVal * _mult

// Session filter using exchange timezone session string.
f_inSession(_session) =>
    not na(time(timeframe.period, _session))

// Index trend alignment via non-repainting security call.
f_indexBullish(_symbol, _emaLen) =>
    float idxClose = request.security(_symbol, timeframe.period, close, barmerge.gaps_off, barmerge.lookahead_off)
    float idxEma   = request.security(_symbol, timeframe.period, ta.ema(close, _emaLen), barmerge.gaps_off, barmerge.lookahead_off)
    idxClose > idxEma

f_indexBearish(_symbol, _emaLen) =>
    float idxClose = request.security(_symbol, timeframe.period, close, barmerge.gaps_off, barmerge.lookahead_off)
    float idxEma   = request.security(_symbol, timeframe.period, ta.ema(close, _emaLen), barmerge.gaps_off, barmerge.lookahead_off)
    idxClose < idxEma

// Aggregate filter gate for bullish or bearish setups.
f_passesCommonFilters(_isBull) =>
    bool volOk   = not useMinVolume or volume >= minVolume
    bool rvolOk  = not useRvolFilter or f_rvol(rvolLookback) >= rvolThreshold
    bool atrOk   = not useAtrFilter or f_atrRangeOk(atrLength, atrMinMult)
    bool priceOk = not useMinPrice or close >= minPrice
    bool sessOk  = not useSessionFilter or f_inSession(sessionWindow)
    bool emaOk   = not useEmaTrendFilter or (_isBull ? close > ta.ema(close, emaLength) : close < ta.ema(close, emaLength))
    bool idxOk   = not useIndexAlignment or (_isBull ? f_indexBullish(indexSymbol, emaLength) : f_indexBearish(indexSymbol, emaLength))
    volOk and rvolOk and atrOk and priceOk and sessOk and emaOk and idxOk

// =============================================================================
// HELPER FUNCTIONS — SETUP DETECTION
// =============================================================================

// Inside bar: prior bar [1] fully inside mother bar [2]; breakout on confirmed close.
f_detectInsideBar(_useEmaSide, _emaLen) =>
    bool motherExists = high[2] > low[2]
    bool isInsideBar  = motherExists and high[1] <= high[2] and low[1] >= low[2]
    bool bullBreak    = isInsideBar and close > high[1]
    bool bearBreak    = isInsideBar and close < low[1]
    bool emaBullOk    = not _useEmaSide or close > ta.ema(close, _emaLen)
    bool emaBearOk    = not _useEmaSide or close < ta.ema(close, _emaLen)
    [bullBreak and emaBullOk, bearBreak and emaBearOk, high[1], low[1]]

// ATH breakout: close above rolling highest high (excluding current bar).
f_detectAthBreakout(_lookback, _requireRvol, _rvolLb, _rvolThr, _requireConsol, _consolBars, _proxPct) =>
    float priorHigh = ta.highest(high, _lookback)[1]
    bool  brokeAth   = not na(priorHigh) and close > priorHigh and close[1] <= priorHigh
    bool  rvolOk     = not _requireRvol or f_rvol(_rvolLb) >= _rvolThr
    bool  consolOk   = true
    if _requireConsol
        float proxLevel = priorHigh * (1.0 - _proxPct / 100.0)
        int   nearCount = 0
        for i = 1 to _consolBars
            if close[i] >= proxLevel and close[i] <= priorHigh
                nearCount += 1
        consolOk := nearCount >= _consolBars
    [brokeAth and rvolOk and consolOk, priorHigh]

// Gap fill state machine — tracks active gap across session bars (non-repainting on bar close).
f_gapFillSignals(_minGapPct, _partialPct, _allowPartial, _allowFull) =>
    var float gapTop      = na
    var float gapBottom   = na
    var int   gapDir      = 0
    var bool  gapActive   = false
    var bool  partialSeen = false

    bool newDay = ta.change(time("D")) != 0

    if newDay
        float gapSize = open - close[1]
        float gapPct  = math.abs(gapSize) / close[1] * 100.0
        if gapPct >= _minGapPct
            gapActive   := true
            partialSeen := false
            gapDir      := gapSize > 0 ? 1 : -1
            gapTop      := gapSize > 0 ? open : close[1]
            gapBottom   := gapSize > 0 ? close[1] : open
        else
            gapActive := false
            gapDir    := 0

    if gapActive and not na(gapTop) and not na(gapBottom)
        float gapRange = gapTop - gapBottom
        if gapRange > 0
            float fillDepth = gapDir == 1 ? (gapTop - low) / gapRange * 100.0 : (high - gapBottom) / gapRange * 100.0
            if fillDepth >= _partialPct
                partialSeen := true
            if fillDepth >= 99.0
                gapActive := false

    // Bullish gap-fill reversal: gap down, price fills gap, closes bullish.
    bool bullReversal = gapActive and gapDir == -1 and partialSeen and close > open and close > gapBottom
    bool bullTrigger  = bullReversal and ((_allowPartial and partialSeen) or (_allowFull and low <= gapBottom))

    // Bearish continuation: gap up, fails to fill, closes weak.
    bool bearContinuation = gapActive and gapDir == 1 and close < open and high < gapTop and low > gapBottom
    bool bearTrigger      = bearContinuation

    [bullTrigger, bearTrigger]

// Outside bar: current bar range engulfs prior bar; direction from close location.
f_detectOutsideBar(_minBodyPct) =>
    bool isOutside = high > high[1] and low < low[1]
    float barRange = high - low
    float bodyPct  = barRange > 0 ? math.abs(close - open) / barRange * 100.0 : 0.0
    bool bodyOk    = bodyPct >= _minBodyPct
    bool bullExp   = isOutside and bodyOk and close > open and close >= high[1]
    bool bearExp   = isOutside and bodyOk and close < open and close <= low[1]
    [bullExp, bearExp, high[1], low[1]]

// Build JSON webhook payload string for alert() calls.
f_buildPayload(_setup, _action) =>
    str.format(
         '{{"symbol":"{0}","ticker":"{0}","exchange":"{1}","timeframe":"{2}","interval":"{2}","action":"{3}","direction":"{3}","setup":"{4}","price":{5},"close":{5},"volume":{6},"strategy":"{7}","timestamp":"{8}","source":"tradingview"}}',
         syminfo.ticker,
         syminfo.prefix,
         timeframe.period,
         _action,
         _setup,
         str.tostring(close, format.mintick),
         str.tostring(volume, format.volume),
         STRATEGY_NAME,
         str.tostring(timenow))

// =============================================================================
// SETUP DETECTION (evaluated on confirmed bars only — no repainting)
// =============================================================================

float emaLine = ta.ema(close, emaLength)

[insideBullRaw, insideBearRaw, insideHigh, insideLow] =
     f_detectInsideBar(insideUseEmaSide, emaLength)

[athBullRaw, athLevel] =
     f_detectAthBreakout(athLookback, athRequireRvol, rvolLookback, rvolThreshold, athRequireConsol, athConsolBars, athConsolProximity)

[gapBullRaw, gapBearRaw] =
     f_gapFillSignals(gapMinPct, gapPartialPct, gapAllowPartial, gapAllowFull)

[outsideBullRaw, outsideBearRaw, outsidePriorHigh, outsidePriorLow] =
     f_detectOutsideBar(outsideMinBodyPct)

bool confirmed = barstate.isconfirmed

bool insideBull  = enableInsideBar   and confirmed and insideBullRaw  and f_passesCommonFilters(true)
bool insideBear  = enableInsideBar   and confirmed and insideBearRaw  and f_passesCommonFilters(false)
bool athBull     = enableAthBreakout and confirmed and athBullRaw     and f_passesCommonFilters(true)
bool gapBull     = enableGapFill     and confirmed and gapBullRaw     and f_passesCommonFilters(true)
bool gapBear     = enableGapFill     and confirmed and gapBearRaw     and f_passesCommonFilters(false)
bool outsideBull = enableOutsideBar  and confirmed and outsideBullRaw and f_passesCommonFilters(true)
bool outsideBear = enableOutsideBar  and confirmed and outsideBearRaw and f_passesCommonFilters(false)

// =============================================================================
// ALERTS — alertcondition() for TradingView alert dialog (webhook-ready JSON)
// =============================================================================

alertcondition(insideBull,  title="Inside Bar Bullish",  message=ALERT_INSIDE_BULL)
alertcondition(insideBear,  title="Inside Bar Bearish",  message=ALERT_INSIDE_BEAR)
alertcondition(athBull,     title="ATH Breakout Bullish", message=ALERT_ATH_BULL)
alertcondition(gapBull,     title="Gap Fill Bullish Reversal", message=ALERT_GAP_BULL)
alertcondition(gapBear,     title="Gap Fill Bearish Continuation", message=ALERT_GAP_BEAR)
alertcondition(outsideBull, title="Outside Bar Bullish", message=ALERT_OUTSIDE_BULL)
alertcondition(outsideBear, title="Outside Bar Bearish", message=ALERT_OUTSIDE_BEAR)

// Optional alert() path — enable only if you prefer a single "Any alert() function call" webhook.
if enableDynamicAlerts and insideBull
    alert(f_buildPayload(SETUP_INSIDE_BULL, "long"), alert.freq_once_per_bar_close)
if enableDynamicAlerts and insideBear
    alert(f_buildPayload(SETUP_INSIDE_BEAR, "short"), alert.freq_once_per_bar_close)
if enableDynamicAlerts and athBull
    alert(f_buildPayload(SETUP_ATH_BULL, "long"), alert.freq_once_per_bar_close)
if enableDynamicAlerts and gapBull
    alert(f_buildPayload(SETUP_GAP_BULL, "long"), alert.freq_once_per_bar_close)
if enableDynamicAlerts and gapBear
    alert(f_buildPayload(SETUP_GAP_BEAR, "short"), alert.freq_once_per_bar_close)
if enableDynamicAlerts and outsideBull
    alert(f_buildPayload(SETUP_OUTSIDE_BULL, "long"), alert.freq_once_per_bar_close)
if enableDynamicAlerts and outsideBear
    alert(f_buildPayload(SETUP_OUTSIDE_BEAR, "short"), alert.freq_once_per_bar_close)

// =============================================================================
// VISUALS
// =============================================================================

plot(showEma ? emaLine : na, title="EMA", color=color.new(color.orange, 0), linewidth=2)

color bullColor = color.new(color.teal, 0)
color bearColor = color.new(color.red, 0)

plotshape(showSetupMarkers and insideBull,  title="Inside Bar Bull",  style=shape.triangleup,   location=location.belowbar, color=bullColor, size=size.small, text="IB↑")
plotshape(showSetupMarkers and insideBear,  title="Inside Bar Bear",  style=shape.triangledown, location=location.abovebar, color=bearColor, size=size.small, text="IB↓")
plotshape(showSetupMarkers and athBull,     title="ATH Breakout",     style=shape.triangleup,   location=location.belowbar, color=color.new(color.lime, 0), size=size.small, text="ATH")
plotshape(showSetupMarkers and gapBull,     title="Gap Fill Bull",    style=shape.triangleup,   location=location.belowbar, color=color.new(color.aqua, 0), size=size.small, text="GF↑")
plotshape(showSetupMarkers and gapBear,     title="Gap Fill Bear",    style=shape.triangledown, location=location.abovebar, color=color.new(color.fuchsia, 0), size=size.small, text="GF↓")
plotshape(showSetupMarkers and outsideBull,  title="Outside Bar Bull", style=shape.triangleup,   location=location.belowbar, color=color.new(color.green, 0), size=size.small, text="OB↑")
plotshape(showSetupMarkers and outsideBear,  title="Outside Bar Bear", style=shape.triangledown, location=location.abovebar, color=color.new(color.maroon, 0), size=size.small, text="OB↓")

plot(showBreakoutLevels and not na(insideHigh) and insideBullRaw ? insideHigh : na, title="Inside High", color=color.new(bullColor, 50), style=plot.style_circles, linewidth=1)
plot(showBreakoutLevels and not na(insideLow) and insideBearRaw ? insideLow : na, title="Inside Low", color=color.new(bearColor, 50), style=plot.style_circles, linewidth=1)
plot(showBreakoutLevels and athBullRaw and not na(athLevel) ? athLevel : na, title="ATH Level", color=color.new(color.lime, 60), style=plot.style_cross, linewidth=1)
````
