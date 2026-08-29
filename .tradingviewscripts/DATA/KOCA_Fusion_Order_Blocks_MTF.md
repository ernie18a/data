<!-- tradingview-pine-id: PUB;c9e98e94d15e49669385f4d7bdd59695 -->
<!-- tradingviewscripts-format: 1 -->
# KOCA Fusion Order Blocks MTF

Source: https://www.tradingview.com/script/SvxhlY5C-KOCA-Order-Blocks/

## Description

koca orrder block is a highly configurable TradingView indicator designed to identify potential demand, supply, order-block, and pullback zones. It combines two different detection methods and allows the user to control how strict or loose the zone detection should be.

Detection modes

The indicator offers three detection methods:

Base Break
Identifies the last opposite-colored candle as a potential base. A demand zone is created when price breaks above a bearish base candle, while a supply zone is created when price breaks below a bullish base candle.

Candle Streak
Detects bullish or bearish momentum based on a configurable number of consecutive candles moving in the same direction. The zone can be created from either the last opposite candle or the first candle of the impulse.

Hybrid
Requires both conditions at the same time: price must break the base candle and a valid bullish or bearish candle streak must also be present.

Multi-timeframe functionality

The indicator can calculate zones from a separate source timeframe and display them on the current chart.

For example, it can display:

15-minute order blocks on a 5-minute chart
1-hour supply and demand zones on a 15-minute chart
Daily zones on an intraday chart

For correct behavior, the source timeframe should normally be equal to or higher than the chart timeframe. New source-timeframe zones are processed only after the source candle has closed, which helps reduce repainting.

Quality filters

The user can filter weaker setups using several optional conditions:

ATR-based displacement
Confirmed Break of Structure
Volume spike
Average impulse volume
Candle body-to-range ratio
Close location near the candle high or low
Directional confirmation candle

Four strictness presets are available:

Loose: no ATR or BOS requirement
Medium: requires at least 1.5 ATR displacement
Strict: requires at least 2.5 ATR displacement and a confirmed BOS
Custom: allows manual control of ATR and BOS requirements

The BOS logic uses confirmed swing highs and lows and attempts to count each structural break only once.

Zone construction

Zones can be drawn using three different methods:

Full Range: candle high to candle low
Body: candle open to candle close
Refined: open-to-low for demand and high-to-open for supply

An optional 50% midpoint line can be displayed inside every zone.

Zone lifecycle

Each detected zone can move through several states:

Fresh: price has not returned to the zone
Tested: price has touched the zone for the first time
Mitigated: price has entered a configurable percentage of the zone
Invalidated: price has closed or wicked through the opposite boundary
Breaker: an invalidated zone has been converted into a zone with the opposite direction

The first-touch behavior can be configured to:

Ignore the touch
Mark the zone as tested
Stop extending the zone immediately

Mitigation depth is adjustable from 1% to 100%. Invalidation can be based on either candle close or wick penetration.

Invalidated zones can be deleted, retained, recolored, or converted into breaker blocks.

Display controls

The indicator provides separate colors for:

Demand zones
Supply zones
Tested zones
Mitigated zones
Invalidated zones
Bullish breakers
Bearish breakers

The fill color, border color, transparency, border visibility, and border thickness can all be adjusted.

To keep the chart clean, the indicator can display only the nearest active zones above and below the current price while keeping more distant zones stored internally.

Debugging and alerts

The optional debug mode marks rejected candidates and shows why they failed, such as:

Insufficient ATR displacement
Missing BOS
Insufficient volume
Invalid base candle
Poor confirmation-candle quality

Alerts are available for:

New demand zone
New supply zone
First zone test
Zone mitigation
Zone invalidation
Bullish breaker creation
Bearish breaker creation

This indicator does not predict guaranteed reversals. It highlights areas where price previously showed structural or momentum-based displacement and where a future reaction may occur.

---

## Source Code

````pine
//@version=6
indicator("KOCA Fusion Order Blocks MTF", shorttitle="KOCA Fusion OB", overlay=true,
     max_boxes_count=500, max_lines_count=500, max_labels_count=500, max_bars_back=5000)

// ============================================================================
// KOCA FUSION ORDER BLOCKS MTF v1.3
// Spojuje:
// 1) Base candle + break + displacement + potvrzený BOS
// 2) Sekvenci impulzních svíček a MTF pullback zóny
// 3) Volume/ATR/body filtry, freshness, test, mitigaci, invalidaci a breakery
//
// DŮLEŽITÉ:
// - Zdrojový timeframe používej stejný nebo vyšší než timeframe grafu.
// - Signály ze zdrojového TF se zpracují až po uzavření zdrojové svíčky.
// ============================================================================

// ----------------------------------------------------------------------------
// GROUPS
// ----------------------------------------------------------------------------
string G_TF       = "1. Timeframe a směr"
string G_DET      = "2. Detekce"
string G_STREAK   = "3. Impulzní série"
string G_FILTER   = "4. Filtry kvality"
string G_ZONE     = "5. Konstrukce zóny"
string G_LIFE     = "6. Životní cyklus"
string G_DISPLAY  = "7. Zobrazení a limity"
string G_VISUAL   = "8. Barvy"
string G_DEBUG    = "9. Debug"

// ----------------------------------------------------------------------------
// INPUTS — TIMEFRAME / DIRECTION
// ----------------------------------------------------------------------------
bool   useSourceTf   = input.bool(true, "Použít zdrojový timeframe", group=G_TF)
string sourceTf      = input.timeframe("15", "Zdrojový timeframe", group=G_TF,
     tooltip="Pro správné MTF chování nastav stejný nebo vyšší timeframe než má graf.")
bool   showDemand    = input.bool(true, "Zobrazit bullish / demand zóny", group=G_TF)
bool   showSupply    = input.bool(true, "Zobrazit bearish / supply zóny", group=G_TF)

string calcTf = useSourceTf ? sourceTf : timeframe.period

// ----------------------------------------------------------------------------
// INPUTS — DETECTION
// ----------------------------------------------------------------------------
string detectionMode = input.string("Base Break", "Režim detekce",
     options=["Base Break", "Candle Streak", "Hybrid"], group=G_DET,
     tooltip="Base Break: poslední protisměrná base + následný break.\nCandle Streak: série stejně směrových svíček.\nHybrid: base musí být proražena a zároveň musí vzniknout požadovaná série.")
int impulseBars = input.int(5, "Max. svíček od base k potvrzení", minval=1, maxval=50, group=G_DET)
string breakRef = input.string("Body (open/close)", "Úroveň base pro break",
     options=["Body (open/close)", "Wick (high/low)"], group=G_DET)
bool requireDirectionalConfirm = input.bool(true, "Potvrzovací svíčka musí mít směr impulzu", group=G_DET)

// ----------------------------------------------------------------------------
// INPUTS — STREAK
// ----------------------------------------------------------------------------
int bullCountNeeded = input.int(4, "Počet bullish svíček v sérii", minval=2, maxval=20, group=G_STREAK)
int bearCountNeeded = input.int(4, "Počet bearish svíček v sérii", minval=2, maxval=20, group=G_STREAK)
string streakBoxSource = input.string("Last Opposite Candle", "Zdroj zóny u série",
     options=["Last Opposite Candle", "First Impulse Candle"], group=G_STREAK)

// ----------------------------------------------------------------------------
// INPUTS — FILTERS
// ----------------------------------------------------------------------------
string filterPreset = input.string("Střední", "Předvolba přísnosti",
     options=["Volná", "Střední", "Přísná", "Vlastní"], group=G_FILTER,
     tooltip="Volná: bez ATR a BOS.\nStřední: displacement 1.5× ATR.\nPřísná: displacement 2.5× ATR + potvrzený BOS.\nVlastní: použije ruční přepínače níže.")
int atrLen = input.int(96, "ATR délka", minval=1, maxval=2000, group=G_FILTER)
bool customUseAtr = input.bool(true, "Vlastní: použít ATR displacement", group=G_FILTER)
float customAtrMult = input.float(1.5, "Vlastní: min. displacement v ATR", minval=0.0, step=0.1, group=G_FILTER)
bool customUseBos = input.bool(false, "Vlastní: vyžadovat nový potvrzený BOS", group=G_FILTER)
int swingLen = input.int(5, "Swing délka pro BOS", minval=2, maxval=50, group=G_FILTER)

bool useVolumeFilter = input.bool(false, "Použít volume filtr", group=G_FILTER)
int volumeLength = input.int(20, "Volume SMA délka", minval=1, maxval=1000, group=G_FILTER)
float volumeMultiplier = input.float(1.5, "Volume násobek", minval=0.1, step=0.1, group=G_FILTER)
string volumeMeasureMode = input.string("Potvrzovací svíčka", "Měřené volume",
     options=["Potvrzovací svíčka", "Průměr posledních N svíček"], group=G_FILTER)
int volumeImpulseBars = input.int(3, "N pro průměr impulzního volume", minval=1, maxval=50, group=G_FILTER)

bool useBodyQuality = input.bool(false, "Použít filtr kvality potvrzovací svíčky", group=G_FILTER)
float minBodyRatio = input.float(0.60, "Min. poměr těla k range", minval=0.0, maxval=1.0, step=0.05, group=G_FILTER)
float closeExtremePct = input.float(0.25, "Close musí být v krajních X % range", minval=0.01, maxval=0.50, step=0.05, group=G_FILTER)

// ----------------------------------------------------------------------------
// INPUTS — ZONE
// ----------------------------------------------------------------------------
string zoneMode = input.string("Full Range", "Rozsah zóny",
     options=["Full Range", "Body", "Refined"], group=G_ZONE,
     tooltip="Full Range: high–low.\nBody: tělo svíčky.\nRefined: demand open–low, supply high–open.")
bool showMidpoint = input.bool(true, "Zobrazit midpoint 50 %", group=G_ZONE)
string midpointStyle = input.string("Dotted", "Styl midpointu",
     options=["Solid", "Dashed", "Dotted"], group=G_ZONE)

// ----------------------------------------------------------------------------
// INPUTS — LIFECYCLE
// ----------------------------------------------------------------------------
string touchAction = input.string("Mark Tested", "Akce při prvním doteku",
     options=["Ignore", "Mark Tested", "Stop on First Touch"], group=G_LIFE)
bool useMitigation = input.bool(true, "Používat procentní mitigaci", group=G_LIFE)
float mitigationPct = input.float(25.0, "Práh mitigace (%)", minval=1.0, maxval=100.0, step=1.0, group=G_LIFE)
string armMode = input.string("Touch outside edge", "Kdy je zóna považována za opuštěnou",
     options=["Touch outside edge", "Full candle outside"], group=G_LIFE)

string departureMode = input.string("% of zone", "Minimální vzdálenost opuštění",
     options=["% of zone", "Ticks", "ATR"], group=G_LIFE,
     tooltip="% of zone: vzdálenost se počítá z výšky konkrétního OB.\nTicks: pevný počet minimálních ticků trhu.\nATR: vzdálenost jako násobek ATR(14).")
float departureZonePct = input.float(20.0, "Opuštění: % výšky zóny", minval=0.0, maxval=300.0, step=5.0, group=G_LIFE)
int departureTicks = input.int(8, "Opuštění: počet ticků", minval=0, maxval=10000, group=G_LIFE)
float departureAtrMult = input.float(0.15, "Opuštění: násobek ATR(14)", minval=0.0, maxval=10.0, step=0.05, group=G_LIFE)

bool allowSameBarRetest = input.bool(false, "Povolit mitigaci ve stejném baru jako opuštění", group=G_LIFE)
bool stopOnMitigation = input.bool(true, "Po mitigaci ukončit prodlužování boxu", group=G_LIFE)
bool deleteMitigated = input.bool(false, "Smazat mitigované zóny", group=G_LIFE)

string invalidationMode = input.string("Close", "Zneplatnění zóny",
     options=["Close", "Wick"], group=G_LIFE)
bool deleteInvalidated = input.bool(false, "Smazat zneplatněné zóny", group=G_LIFE)
bool keepOriginalColorWhenInvalid = input.bool(false, "Při invalidaci ponechat původní barvu", group=G_LIFE)
bool convertToBreaker = input.bool(false, "Převést první invalidaci na breaker", group=G_LIFE)

// ----------------------------------------------------------------------------
// INPUTS — DISPLAY / LIMITS
// ----------------------------------------------------------------------------
int maxTotalZones = input.int(100, "Max. celkový počet zón", minval=10, maxval=450, group=G_DISPLAY)
int lookbackBars = input.int(10000, "Max. stáří zóny v barech grafu", minval=100, maxval=10000, group=G_DISPLAY)
int maxTestedKeep = input.int(20, "Max. ponechaných ukončených Tested", minval=0, maxval=200, group=G_DISPLAY)
int maxMitigatedKeep = input.int(20, "Max. ponechaných Mitigated", minval=0, maxval=200, group=G_DISPLAY)
int maxInvalidKeep = input.int(20, "Max. ponechaných Invalidated", minval=0, maxval=200, group=G_DISPLAY)

bool limitNearest = input.bool(true, "Zobrazit jen nejbližší aktivní zóny", group=G_DISPLAY)
int maxPerSide = input.int(5, "Max. aktivních zón nad / pod cenou", minval=1, maxval=25, group=G_DISPLAY)

// ----------------------------------------------------------------------------
// INPUTS — VISUALS
// ----------------------------------------------------------------------------
color demandColor = input.color(#26A69A, "Demand výplň", group=G_VISUAL)
color supplyColor = input.color(#EF5350, "Supply výplň", group=G_VISUAL)
color testedColor = input.color(#F9A825, "Tested výplň", group=G_VISUAL)
color mitigatedColor = input.color(color.gray, "Mitigated výplň", group=G_VISUAL)
color invalidColor = input.color(#616161, "Invalidated výplň", group=G_VISUAL)
color bullishBreakerColor = input.color(#42A5F5, "Bullish breaker výplň", group=G_VISUAL)
color bearishBreakerColor = input.color(#AB47BC, "Bearish breaker výplň", group=G_VISUAL)

color demandBorderColor = input.color(#00897B, "Demand hrana", group=G_VISUAL)
color supplyBorderColor = input.color(#E53935, "Supply hrana", group=G_VISUAL)
color testedBorderColor = input.color(#F57F17, "Tested hrana", group=G_VISUAL)
color mitigatedBorderColor = input.color(#757575, "Mitigated hrana", group=G_VISUAL)
color invalidBorderColor = input.color(#424242, "Invalidated hrana", group=G_VISUAL)
color bullishBreakerBorderColor = input.color(#1E88E5, "Bullish breaker hrana", group=G_VISUAL)
color bearishBreakerBorderColor = input.color(#8E24AA, "Bearish breaker hrana", group=G_VISUAL)

int freshTransparency = input.int(85, "Fresh průhlednost", minval=0, maxval=100, group=G_VISUAL)
int testedTransparency = input.int(88, "Tested průhlednost", minval=0, maxval=100, group=G_VISUAL)
int inactiveTransparency = input.int(91, "Mitigated / invalid průhlednost", minval=0, maxval=100, group=G_VISUAL)
bool showBorder = input.bool(true, "Zobrazit ohraničení", group=G_VISUAL)
int borderWidth = input.int(1, "Tloušťka hrany", minval=1, maxval=4, group=G_VISUAL)

// ----------------------------------------------------------------------------
// INPUTS — DEBUG
// ----------------------------------------------------------------------------
bool showDebug = input.bool(false, "Zobrazit zamítnuté kandidáty", group=G_DEBUG)
int maxDebugLabels = input.int(100, "Max. debug štítků", minval=10, maxval=400, group=G_DEBUG)
bool showTfWarning = input.bool(true, "Varovat při nižším source TF než TF grafu", group=G_DEBUG)

// ----------------------------------------------------------------------------
// CONSTANTS / TYPES
// ----------------------------------------------------------------------------
int ST_FRESH       = 0
int ST_TESTED      = 1
int ST_MITIGATED   = 2
int ST_INVALIDATED = 3
int ST_BREAKER     = 4

type Zone
    float top
    float bot
    int leftTime
    int createdBar
    bool isDemand
    bool active
    bool armed
    int armedBar
    int state
    float extreme
    box bx
    line midLn

var array<Zone> zones = array.new<Zone>()
var array<label> debugLabels = array.new<label>()

// ----------------------------------------------------------------------------
// HELPERS — SOURCE LOGIC
// ----------------------------------------------------------------------------
f_breakUp(float _o, float _c, float _h) =>
    breakRef == "Wick (high/low)" ? _h : math.max(_o, _c)

f_breakDn(float _o, float _c, float _l) =>
    breakRef == "Wick (high/low)" ? _l : math.min(_o, _c)

f_zoneTop(float _o, float _c, float _h, float _l, bool _isDemand) =>
    switch zoneMode
        "Body"    => math.max(_o, _c)
        "Refined" => _isDemand ? _o : _h
        => _h

f_zoneBot(float _o, float _c, float _h, float _l, bool _isDemand) =>
    switch zoneMode
        "Body"    => math.min(_o, _c)
        "Refined" => _isDemand ? _l : _o
        => _l

f_effectiveAtrMult() =>
    filterPreset == "Volná" ? 0.0 : filterPreset == "Střední" ? 1.5 : filterPreset == "Přísná" ? 2.5 : customAtrMult

f_useAtr() =>
    filterPreset == "Volná" ? false : filterPreset == "Vlastní" ? customUseAtr : true

f_useBos() =>
    filterPreset == "Přísná" ? true : filterPreset == "Vlastní" ? customUseBos : false

// Bitový kód debug důvodů:
// 1 = ATR displacement, 2 = BOS, 4 = volume, 8 = opačná base, 16 = kvalita svíčky
f_reasonText(int _code) =>
    string txt = ""
    if _code % 2 >= 1
        txt += "ATR "
    if _code % 4 >= 2
        txt += "BOS "
    if _code % 8 >= 4
        txt += "VOL "
    if _code % 16 >= 8
        txt += "BASE "
    if _code % 32 >= 16
        txt += "BODY "
    txt

// Celý detekční engine se vyhodnocuje v kontextu source timeframe.
f_sourceEngine() =>
    bool bullish = close > open
    bool bearish = close < open

    // Série svíček
    int bullStreak = 0
    bullStreak := bullish ? nz(bullStreak[1], 0) + 1 : 0
    int bearStreak = 0
    bearStreak := bearish ? nz(bearStreak[1], 0) + 1 : 0
    bool bullStreakSignal = bullStreak == bullCountNeeded and nz(bullStreak[1], 0) < bullCountNeeded
    bool bearStreakSignal = bearStreak == bearCountNeeded and nz(bearStreak[1], 0) < bearCountNeeded

    // Potvrzené swingy a jednorázový BOS
    float ph = ta.pivothigh(high, swingLen, swingLen)
    float pl = ta.pivotlow(low, swingLen, swingLen)

    float activeSwingHigh = na
    activeSwingHigh := not na(ph) ? ph : activeSwingHigh[1]
    float activeSwingLow = na
    activeSwingLow := not na(pl) ? pl : activeSwingLow[1]

    bool swingHighBroken = true
    swingHighBroken := not na(ph) ? false : swingHighBroken[1]
    bool swingLowBroken = true
    swingLowBroken := not na(pl) ? false : swingLowBroken[1]

    bool bullBosEvent = not na(activeSwingHigh) and not swingHighBroken and close > activeSwingHigh and close[1] <= activeSwingHigh
    bool bearBosEvent = not na(activeSwingLow) and not swingLowBroken and close < activeSwingLow and close[1] >= activeSwingLow

    if bullBosEvent
        swingHighBroken := true
    if bearBosEvent
        swingLowBroken := true

    int lastBullBosIdx = na
    lastBullBosIdx := bullBosEvent ? bar_index : lastBullBosIdx[1]
    int lastBearBosIdx = na
    lastBearBosIdx := bearBosEvent ? bar_index : lastBearBosIdx[1]

    // Base kandidát pro demand = poslední bearish svíčka
    float candDbreak = na
    candDbreak := candDbreak[1]
    float candDtop = na
    candDtop := candDtop[1]
    float candDbot = na
    candDbot := candDbot[1]
    int candDtime = na
    candDtime := candDtime[1]
    int candDidx = na
    candDidx := candDidx[1]
    int candDage = na
    candDage := candDage[1]

    if bearish
        candDbreak := f_breakUp(open, close, high)
        candDtop := f_zoneTop(open, close, high, low, true)
        candDbot := f_zoneBot(open, close, high, low, true)
        candDtime := time
        candDidx := bar_index
        candDage := 0
    else if not na(candDage)
        candDage := candDage + 1

    // Base kandidát pro supply = poslední bullish svíčka
    float candSbreak = na
    candSbreak := candSbreak[1]
    float candStop = na
    candStop := candStop[1]
    float candSbot = na
    candSbot := candSbot[1]
    int candStime = na
    candStime := candStime[1]
    int candSidx = na
    candSidx := candSidx[1]
    int candSage = na
    candSage := candSage[1]

    if bullish
        candSbreak := f_breakDn(open, close, low)
        candStop := f_zoneTop(open, close, high, low, false)
        candSbot := f_zoneBot(open, close, high, low, false)
        candStime := time
        candSidx := bar_index
        candSage := 0
    else if not na(candSage)
        candSage := candSage + 1

    float atrVal = ta.atr(atrLen)
    float atrMult = f_effectiveAtrMult()
    bool requireAtr = f_useAtr()
    bool requireBos = f_useBos()

    float volBase = ta.sma(volume, volumeLength)
    float volMeasure = volumeMeasureMode == "Potvrzovací svíčka" ? volume : ta.sma(volume, volumeImpulseBars)
    bool volumeOK = not useVolumeFilter or (not na(volMeasure) and not na(volBase) and volMeasure > volBase * volumeMultiplier)

    float candleRange = math.max(high - low, syminfo.mintick)
    float bodyRatio = math.abs(close - open) / candleRange
    bool demandBodyOK = not useBodyQuality or (bodyRatio >= minBodyRatio and close >= high - candleRange * closeExtremePct)
    bool supplyBodyOK = not useBodyQuality or (bodyRatio >= minBodyRatio and close <= low + candleRange * closeExtremePct)
    bool demandDirectionOK = not requireDirectionalConfirm or bullish
    bool supplyDirectionOK = not requireDirectionalConfirm or bearish

    bool dEvent = false
    float dTopOut = na
    float dBotOut = na
    int dLeftOut = na
    bool dRejected = false
    int dReason = 0
    float dRejectY = na

    bool sEvent = false
    float sTopOut = na
    float sBotOut = na
    int sLeftOut = na
    bool sRejected = false
    int sReason = 0
    float sRejectY = na

    // ---------------- Demand ----------------
    if detectionMode == "Candle Streak"
        int dOffset = streakBoxSource == "Last Opposite Candle" ? bullCountNeeded : bullCountNeeded - 1
        bool dOppositeOK = streakBoxSource != "Last Opposite Candle" or close[dOffset] < open[dOffset]
        float dTop = f_zoneTop(open[dOffset], close[dOffset], high[dOffset], low[dOffset], true)
        float dBot = f_zoneBot(open[dOffset], close[dOffset], high[dOffset], low[dOffset], true)
        int dLeft = time[dOffset]
        int impulseStartIdx = bar_index - (bullCountNeeded - 1)
        float dLeg = close - low[bullCountNeeded - 1]
        bool dAtrOK = not requireAtr or (not na(atrVal) and atrVal > 0 and dLeg >= atrMult * atrVal)
        bool dBosOK = not requireBos or (not na(lastBullBosIdx) and lastBullBosIdx >= impulseStartIdx)
        bool dQualityOK = demandBodyOK and demandDirectionOK
        int reason = (not dAtrOK ? 1 : 0) + (not dBosOK ? 2 : 0) + (not volumeOK ? 4 : 0) + (not dOppositeOK ? 8 : 0) + (not dQualityOK ? 16 : 0)
        if bullStreakSignal and reason == 0 and dTop > dBot
            dEvent := true
            dTopOut := dTop
            dBotOut := dBot
            dLeftOut := dLeft
        else if bullStreakSignal and reason != 0
            dRejected := true
            dReason := reason
            dRejectY := dBot
            dLeftOut := dLeft
    else
        bool dWindow = not na(candDidx) and candDage >= 1 and candDage <= impulseBars
        bool dBreak = dWindow and close > candDbreak and candDtop > candDbot
        bool dHybridOK = detectionMode != "Hybrid" or bullStreak >= bullCountNeeded
        float dLeg = close - candDbot
        bool dAtrOK = not requireAtr or (not na(atrVal) and atrVal > 0 and dLeg >= atrMult * atrVal)
        bool dBosOK = not requireBos or (not na(lastBullBosIdx) and lastBullBosIdx >= candDidx)
        bool dQualityOK = demandBodyOK and demandDirectionOK
        int reason = (not dAtrOK ? 1 : 0) + (not dBosOK ? 2 : 0) + (not volumeOK ? 4 : 0) + (not dQualityOK ? 16 : 0)
        if dBreak and dHybridOK and reason == 0
            dEvent := true
            dTopOut := candDtop
            dBotOut := candDbot
            dLeftOut := candDtime
            candDbreak := na
            candDtop := na
            candDbot := na
            candDtime := na
            candDidx := na
            candDage := na
        else if dBreak and dHybridOK and reason != 0 and candDage == impulseBars
            dRejected := true
            dReason := reason
            dRejectY := candDbot
            dLeftOut := candDtime

    // ---------------- Supply ----------------
    if detectionMode == "Candle Streak"
        int sOffset = streakBoxSource == "Last Opposite Candle" ? bearCountNeeded : bearCountNeeded - 1
        bool sOppositeOK = streakBoxSource != "Last Opposite Candle" or close[sOffset] > open[sOffset]
        float sTop = f_zoneTop(open[sOffset], close[sOffset], high[sOffset], low[sOffset], false)
        float sBot = f_zoneBot(open[sOffset], close[sOffset], high[sOffset], low[sOffset], false)
        int sLeft = time[sOffset]
        int impulseStartIdx = bar_index - (bearCountNeeded - 1)
        float sLeg = high[bearCountNeeded - 1] - close
        bool sAtrOK = not requireAtr or (not na(atrVal) and atrVal > 0 and sLeg >= atrMult * atrVal)
        bool sBosOK = not requireBos or (not na(lastBearBosIdx) and lastBearBosIdx >= impulseStartIdx)
        bool sQualityOK = supplyBodyOK and supplyDirectionOK
        int reason = (not sAtrOK ? 1 : 0) + (not sBosOK ? 2 : 0) + (not volumeOK ? 4 : 0) + (not sOppositeOK ? 8 : 0) + (not sQualityOK ? 16 : 0)
        if bearStreakSignal and reason == 0 and sTop > sBot
            sEvent := true
            sTopOut := sTop
            sBotOut := sBot
            sLeftOut := sLeft
        else if bearStreakSignal and reason != 0
            sRejected := true
            sReason := reason
            sRejectY := sTop
            sLeftOut := sLeft
    else
        bool sWindow = not na(candSidx) and candSage >= 1 and candSage <= impulseBars
        bool sBreak = sWindow and close < candSbreak and candStop > candSbot
        bool sHybridOK = detectionMode != "Hybrid" or bearStreak >= bearCountNeeded
        float sLeg = candStop - close
        bool sAtrOK = not requireAtr or (not na(atrVal) and atrVal > 0 and sLeg >= atrMult * atrVal)
        bool sBosOK = not requireBos or (not na(lastBearBosIdx) and lastBearBosIdx >= candSidx)
        bool sQualityOK = supplyBodyOK and supplyDirectionOK
        int reason = (not sAtrOK ? 1 : 0) + (not sBosOK ? 2 : 0) + (not volumeOK ? 4 : 0) + (not sQualityOK ? 16 : 0)
        if sBreak and sHybridOK and reason == 0
            sEvent := true
            sTopOut := candStop
            sBotOut := candSbot
            sLeftOut := candStime
            candSbreak := na
            candStop := na
            candSbot := na
            candStime := na
            candSidx := na
            candSage := na
        else if sBreak and sHybridOK and reason != 0 and candSage == impulseBars
            sRejected := true
            sReason := reason
            sRejectY := candStop
            sLeftOut := candStime

    // Exspirace kandidátů
    if not na(candDage) and candDage > impulseBars
        candDbreak := na
        candDtop := na
        candDbot := na
        candDtime := na
        candDidx := na
        candDage := na
    if not na(candSage) and candSage > impulseBars
        candSbreak := na
        candStop := na
        candSbot := na
        candStime := na
        candSidx := na
        candSage := na

    [dEvent, dTopOut, dBotOut, dLeftOut, dRejected, dReason, dRejectY,
     sEvent, sTopOut, sBotOut, sLeftOut, sRejected, sReason, sRejectY, time]

// ----------------------------------------------------------------------------
// REQUEST SOURCE TIMEFRAME
// ----------------------------------------------------------------------------
[srcDemandEvent, srcDTop, srcDBot, srcDLeft, srcDRejected, srcDReason, srcDRejectY,
 srcSupplyEvent, srcSTop, srcSBot, srcSLeft, srcSRejected, srcSReason, srcSRejectY,
 srcTime] = request.security(syminfo.tickerid, calcTf, f_sourceEngine(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

bool newSourceBar = ta.change(srcTime) != 0

// ----------------------------------------------------------------------------
// HELPERS — DRAWINGS / STORAGE
// ----------------------------------------------------------------------------
f_midStyle() =>
    midpointStyle == "Solid" ? line.style_solid : midpointStyle == "Dashed" ? line.style_dashed : line.style_dotted

f_deleteZoneDrawings(Zone _z) =>
    box.delete(_z.bx)
    if not na(_z.midLn)
        line.delete(_z.midLn)

f_zoneColor(Zone _z) =>
    color base = _z.isDemand ? demandColor : supplyColor
    color c = base
    if _z.state == ST_TESTED
        c := testedColor
    else if _z.state == ST_MITIGATED
        c := mitigatedColor
    else if _z.state == ST_INVALIDATED
        c := keepOriginalColorWhenInvalid ? base : invalidColor
    else if _z.state == ST_BREAKER
        c := _z.isDemand ? bullishBreakerColor : bearishBreakerColor
    c

f_zoneTransparency(Zone _z) =>
    _z.state == ST_FRESH or _z.state == ST_BREAKER ? freshTransparency : _z.state == ST_TESTED ? testedTransparency : inactiveTransparency

f_zoneBorderColor(Zone _z) =>
    color base = _z.isDemand ? demandBorderColor : supplyBorderColor
    color c = base
    if _z.state == ST_TESTED
        c := testedBorderColor
    else if _z.state == ST_MITIGATED
        c := mitigatedBorderColor
    else if _z.state == ST_INVALIDATED
        c := keepOriginalColorWhenInvalid ? base : invalidBorderColor
    else if _z.state == ST_BREAKER
        c := _z.isDemand ? bullishBreakerBorderColor : bearishBreakerBorderColor
    c

f_applyStyle(Zone _z) =>
    color fillColor = f_zoneColor(_z)
    color edgeColor = f_zoneBorderColor(_z)
    int tr = f_zoneTransparency(_z)
    box.set_bgcolor(_z.bx, color.new(fillColor, tr))
    box.set_border_color(_z.bx, showBorder ? edgeColor : na)
    box.set_border_width(_z.bx, borderWidth)
    if not na(_z.midLn)
        line.set_color(_z.midLn, fillColor)
        line.set_style(_z.midLn, f_midStyle())

f_isDuplicate(int _leftTime, float _top, float _bot) =>
    bool found = false
    if array.size(zones) > 0
        for z in zones
            if z.leftTime == _leftTime and math.abs(z.top - _top) <= syminfo.mintick and math.abs(z.bot - _bot) <= syminfo.mintick
                found := true
    found

f_pushDebug(int _xTime, float _y, string _text, bool _isDemand) =>
    label lb = label.new(x=_xTime, y=_y, text=_text, xloc=xloc.bar_time, yloc=yloc.price,
         style=_isDemand ? label.style_label_up : label.style_label_down,
         color=color.new(_isDemand ? demandColor : supplyColor, 15), textcolor=color.white, size=size.tiny)
    array.push(debugLabels, lb)
    while array.size(debugLabels) > maxDebugLabels
        label old = array.shift(debugLabels)
        label.delete(old)

// ----------------------------------------------------------------------------
// EVENT FLAGS FOR ALERTS
// ----------------------------------------------------------------------------
bool alertNewDemand = false
bool alertNewSupply = false
bool alertDemandTest = false
bool alertSupplyTest = false
bool alertDemandMitigated = false
bool alertSupplyMitigated = false
bool alertDemandInvalid = false
bool alertSupplyInvalid = false
bool alertBullBreaker = false
bool alertBearBreaker = false

// ----------------------------------------------------------------------------
// CREATE CONFIRMED SOURCE-TF ZONES
// ----------------------------------------------------------------------------
if newSourceBar
    bool dReady = showDemand and srcDemandEvent[1] and not na(srcDTop[1]) and not na(srcDBot[1]) and not na(srcDLeft[1])
    if dReady and srcDTop[1] > srcDBot[1] and not f_isDuplicate(srcDLeft[1], srcDTop[1], srcDBot[1])
        float mid = (srcDTop[1] + srcDBot[1]) / 2.0
        box bx = box.new(left=srcDLeft[1], top=srcDTop[1], right=time, bottom=srcDBot[1], xloc=xloc.bar_time,
             bgcolor=color.new(demandColor, freshTransparency), border_color=showBorder ? demandBorderColor : na, border_width=borderWidth)
        line ml = na
        if showMidpoint
            ml := line.new(x1=srcDLeft[1], y1=mid, x2=time, y2=mid, xloc=xloc.bar_time,
                 color=demandColor, style=f_midStyle())
        Zone z = Zone.new(srcDTop[1], srcDBot[1], srcDLeft[1], bar_index, true, true, false, na, ST_FRESH, srcDTop[1], bx, ml)
        array.push(zones, z)
        alertNewDemand := true

    bool sReady = showSupply and srcSupplyEvent[1] and not na(srcSTop[1]) and not na(srcSBot[1]) and not na(srcSLeft[1])
    if sReady and srcSTop[1] > srcSBot[1] and not f_isDuplicate(srcSLeft[1], srcSTop[1], srcSBot[1])
        float mid = (srcSTop[1] + srcSBot[1]) / 2.0
        box bx = box.new(left=srcSLeft[1], top=srcSTop[1], right=time, bottom=srcSBot[1], xloc=xloc.bar_time,
             bgcolor=color.new(supplyColor, freshTransparency), border_color=showBorder ? supplyBorderColor : na, border_width=borderWidth)
        line ml = na
        if showMidpoint
            ml := line.new(x1=srcSLeft[1], y1=mid, x2=time, y2=mid, xloc=xloc.bar_time,
                 color=supplyColor, style=f_midStyle())
        Zone z = Zone.new(srcSTop[1], srcSBot[1], srcSLeft[1], bar_index, false, true, false, na, ST_FRESH, srcSBot[1], bx, ml)
        array.push(zones, z)
        alertNewSupply := true

    if showDebug and srcDRejected[1] and not na(srcDLeft[1]) and not na(srcDRejectY[1])
        f_pushDebug(srcDLeft[1], srcDRejectY[1], "D✗ " + f_reasonText(srcDReason[1]), true)
    if showDebug and srcSRejected[1] and not na(srcSLeft[1]) and not na(srcSRejectY[1])
        f_pushDebug(srcSLeft[1], srcSRejectY[1], "S✗ " + f_reasonText(srcSReason[1]), false)

// ATR grafu se používá pouze pro volitelnou citlivost opuštění zóny.
float lifecycleAtr = ta.atr(14)

// ----------------------------------------------------------------------------
// UPDATE ZONES — TEST / MITIGATION / INVALIDATION / BREAKER
// ----------------------------------------------------------------------------
if array.size(zones) > 0
    for i = array.size(zones) - 1 to 0
        Zone z = array.get(zones, i)
        bool removed = false

        if z.active
            box.set_right(z.bx, time)
            if not na(z.midLn)
                line.set_x2(z.midLn, time)

            bool canCheck = bar_index > z.createdBar
            bool invalid = false
            if canCheck
                invalid := z.isDemand ?
                     (invalidationMode == "Close" ? close < z.bot : low < z.bot) :
                     (invalidationMode == "Close" ? close > z.top : high > z.top)

            if invalid
                bool oldDirectionDemand = z.isDemand
                if oldDirectionDemand
                    alertDemandInvalid := true
                else
                    alertSupplyInvalid := true

                if convertToBreaker and z.state != ST_BREAKER
                    z.isDemand := not z.isDemand
                    z.state := ST_BREAKER
                    z.active := true
                    z.armed := false
                    z.armedBar := na
                    z.extreme := z.isDemand ? z.top : z.bot
                    if z.isDemand
                        alertBullBreaker := true
                    else
                        alertBearBreaker := true
                    f_applyStyle(z)
                else
                    z.state := ST_INVALIDATED
                    z.active := false
                    box.set_right(z.bx, time)
                    if not na(z.midLn)
                        line.set_x2(z.midLn, time)
                    if deleteInvalidated
                        f_deleteZoneDrawings(z)
                        array.remove(zones, i)
                        removed := true
                    else
                        f_applyStyle(z)
            else
                // Aktivace až po dostatečně velkém opuštění zóny ve směru impulzu.
                // Tím se zabrání aktivaci po pouhém překročení hrany o jeden tick.
                if not z.armed
                    float zoneHeight = math.max(z.top - z.bot, syminfo.mintick)
                    float departureDistance = switch departureMode
                        "% of zone" => zoneHeight * departureZonePct / 100.0
                        "Ticks"     => syminfo.mintick * departureTicks
                        => lifecycleAtr * departureAtrMult

                    float demandTrigger = z.top + departureDistance
                    float supplyTrigger = z.bot - departureDistance

                    bool demandLeft = z.isDemand and (
                         armMode == "Touch outside edge" ? high >= demandTrigger : low >= demandTrigger)
                    bool supplyLeft = not z.isDemand and (
                         armMode == "Touch outside edge" ? low <= supplyTrigger : high <= supplyTrigger)

                    if demandLeft or supplyLeft
                        z.armed := true
                        z.armedBar := bar_index
                        z.extreme := z.isDemand ? z.top : z.bot

                bool retestTimingOK = z.armed and (allowSameBarRetest or na(z.armedBar) or bar_index > z.armedBar)
                bool touching = canCheck and retestTimingOK and high >= z.bot and low <= z.top
                if touching
                    bool isRegular = z.state != ST_BREAKER
                    if isRegular and z.state == ST_FRESH and touchAction != "Ignore"
                        z.state := ST_TESTED
                        if z.isDemand
                            alertDemandTest := true
                        else
                            alertSupplyTest := true
                        f_applyStyle(z)

                    if touchAction == "Stop on First Touch"
                        z.active := false
                        box.set_right(z.bx, time)
                        if not na(z.midLn)
                            line.set_x2(z.midLn, time)
                    else if useMitigation and isRegular
                        float h = z.top - z.bot
                        if z.isDemand
                            z.extreme := math.min(z.extreme, low)
                        else
                            z.extreme := math.max(z.extreme, high)
                        float depth = h > 0 ? (z.isDemand ? (z.top - z.extreme) / h : (z.extreme - z.bot) / h) : 0.0
                        if depth >= mitigationPct / 100.0 and z.state != ST_MITIGATED
                            z.state := ST_MITIGATED
                            if z.isDemand
                                alertDemandMitigated := true
                            else
                                alertSupplyMitigated := true
                            if deleteMitigated
                                f_deleteZoneDrawings(z)
                                array.remove(zones, i)
                                removed := true
                            else
                                z.active := not stopOnMitigation
                                if stopOnMitigation
                                    box.set_right(z.bx, time)
                                    if not na(z.midLn)
                                        line.set_x2(z.midLn, time)
                                f_applyStyle(z)

                if not removed
                    f_applyStyle(z)

// ----------------------------------------------------------------------------
// PRUNE OLD / EXCESS RETAINED ZONES
// ----------------------------------------------------------------------------
int testedCount = 0
int mitigatedCount = 0
int invalidCount = 0
for z in zones
    if not z.active and z.state == ST_TESTED
        testedCount += 1
    else if z.state == ST_MITIGATED
        mitigatedCount += 1
    else if z.state == ST_INVALIDATED
        invalidCount += 1

int dropTested = math.max(0, testedCount - maxTestedKeep)
int dropMit = math.max(0, mitigatedCount - maxMitigatedKeep)
int dropInv = math.max(0, invalidCount - maxInvalidKeep)

int pruneIdx = 0
while pruneIdx < array.size(zones)
    Zone z = array.get(zones, pruneIdx)
    bool tooOld = bar_index - z.createdBar >= lookbackBars
    bool drop = tooOld
    if not drop and not z.active and z.state == ST_TESTED and dropTested > 0
        drop := true
        dropTested -= 1
    else if not drop and z.state == ST_MITIGATED and dropMit > 0
        drop := true
        dropMit -= 1
    else if not drop and z.state == ST_INVALIDATED and dropInv > 0
        drop := true
        dropInv -= 1

    if drop
        f_deleteZoneDrawings(z)
        array.remove(zones, pruneIdx)
    else
        pruneIdx += 1

while array.size(zones) > maxTotalZones
    Zone oldest = array.shift(zones)
    f_deleteZoneDrawings(oldest)

// ----------------------------------------------------------------------------
// SHOW ONLY NEAREST ACTIVE ZONES
// ----------------------------------------------------------------------------
if barstate.islast and limitNearest and array.size(zones) > 0
    for z in zones
        if z.active
            bool visible = false
            if z.bot <= close and z.top >= close
                visible := true
            else if z.bot > close
                int rankAbove = 0
                for other in zones
                    if other.active and other.bot > close and (other.bot - close) < (z.bot - close)
                        rankAbove += 1
                visible := rankAbove < maxPerSide
            else if z.top < close
                int rankBelow = 0
                for other in zones
                    if other.active and other.top < close and (close - other.top) < (close - z.top)
                        rankBelow += 1
                visible := rankBelow < maxPerSide

            if not visible
                box.set_bgcolor(z.bx, color.new(f_zoneColor(z), 100))
                box.set_border_color(z.bx, na)
                if not na(z.midLn)
                    line.set_color(z.midLn, color.new(f_zoneColor(z), 100))

// ----------------------------------------------------------------------------
// TIMEFRAME WARNING
// ----------------------------------------------------------------------------
var table warnTable = table.new(position.top_right, 1, 1)
float sourceSeconds = timeframe.in_seconds(calcTf)
float chartSeconds = timeframe.in_seconds(timeframe.period)
bool lowerTfWarning = not na(sourceSeconds) and not na(chartSeconds) and sourceSeconds < chartSeconds
if barstate.islast
    if showTfWarning and lowerTfWarning
        table.cell(warnTable, 0, 0, "⚠ Source TF je nižší než TF grafu.\nPoužij stejný nebo vyšší TF.",
             text_color=color.white, bgcolor=color.new(color.red, 15))
    else
        table.cell(warnTable, 0, 0, "", bgcolor=color.new(color.black, 100))

// ----------------------------------------------------------------------------
// ALERTS — pouze skutečné události indikátoru
// ----------------------------------------------------------------------------
alertcondition(alertNewDemand, title="New Demand Order Block", message="Nový potvrzený demand order block na {{ticker}}")
alertcondition(alertNewSupply, title="New Supply Order Block", message="Nový potvrzený supply order block na {{ticker}}")
alertcondition(alertDemandTest, title="Demand First Test", message="První test demand zóny na {{ticker}}")
alertcondition(alertSupplyTest, title="Supply First Test", message="První test supply zóny na {{ticker}}")
alertcondition(alertDemandMitigated, title="Demand Mitigated", message="Demand zóna byla mitigována na {{ticker}}")
alertcondition(alertSupplyMitigated, title="Supply Mitigated", message="Supply zóna byla mitigována na {{ticker}}")
alertcondition(alertDemandInvalid, title="Demand Invalidated", message="Demand zóna byla zneplatněna na {{ticker}}")
alertcondition(alertSupplyInvalid, title="Supply Invalidated", message="Supply zóna byla zneplatněna na {{ticker}}")
alertcondition(alertBullBreaker, title="Bullish Breaker Created", message="Vznikl bullish breaker na {{ticker}}")
alertcondition(alertBearBreaker, title="Bearish Breaker Created", message="Vznikl bearish breaker na {{ticker}}")
````
