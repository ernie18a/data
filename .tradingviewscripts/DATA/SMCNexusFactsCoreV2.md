<!-- tradingview-pine-id: PUB;b678bff0ca844e38bbcd3ae5a7a375f2 -->
<!-- tradingviewscripts-format: 1 -->
# SMCNexusFactsCoreV2

Source: https://www.tradingview.com/script/jNz5RL5Y/

## Description

SMCNexusFactsCoreV2 is an open-source, non-visual Pine Script library that maintains confirmed and bounded Smart Money Concepts market facts for use by importing indicators.

The library provides a stateful market-facts engine for swing structure, BOS, CHoCH, MSS, Fair Value Gaps, Order Blocks, liquidity pools, liquidity sweeps, Premium/Discount context and EMA-based context.

It does not draw chart objects, create inputs, request other timeframes, generate alerts, transmit data, calculate trade recommendations or place orders. The importing indicator supplies all chart series and decides how the returned facts are displayed or used.

ORIGINAL CONCEPT AND PURPOSE

The library maintains one consistent, confirmed market-state model instead of calculating unrelated labels independently.

Confirmed swing points become the shared source for:

• HH, HL, LH and LL classification,  
• market bias,  
• Break of Structure,  
• Change of Character,  
• Market Structure Shift,  
• buy-side and sell-side liquidity pools,  
• Premium and Discount dealing ranges.

Fair Value Gaps and Order Blocks use bounded lifecycle records. The library retains only a limited number of objects for each type and direction, preventing unbounded array growth.

Visual settings are not part of this library. An importing indicator can hide or show its own presentation without changing the underlying facts maintained by Facts Core.

CONFIRMED-ONLY PROCESSING

The importing indicator explicitly tells the library whether the current bar is confirmed.

Canonical state changes occur only when confirmed data is supplied. This includes:

• new swing confirmation,  
• BOS or CHoCH confirmation,  
• MSS confirmation,  
• creation of FVG and Order Block facts,  
• zone tests and mitigation,  
• liquidity-pool creation and collection,  
• sweep confirmation.

The library does not use future chart data, negative visual offsets to rewrite history or hidden lookahead requests.

MARKET STRUCTURE

The stateful swing engine stores the latest and previous confirmed swing highs and lows.

It classifies confirmed swings as:

• HH — Higher High  
• HL — Higher Low  
• LH — Lower High  
• LL — Lower Low

The structure model tracks:

• latest swing prices,  
• origin bars,  
• swing types,  
• current market bias,  
• consumed structure levels,  
• latest break type and direction,  
• latest MSS direction and bar.

BOS AND CHOCH

A confirmed break can require a candle close beyond the structure level, depending on the supplied configuration.

The current market bias and the direction of the broken swing determine whether the event represents continuation or a Change of Character.

The library preserves the confirmed event level, direction, origin and confirmation bar in the returned snapshot.

MARKET STRUCTURE SHIFT

MSS can require:

• a confirmed close through structure,  
• a previous opposite bias,  
• a displacement candle,  
• a minimum ATR-based displacement.

These requirements are provided through FactsConfiguration. The library does not silently relax a missing requirement.

FAIR VALUE GAPS

The library detects bullish and bearish three-candle imbalances from caller-supplied OHLC data.

Optional ATR filtering can require a minimum imbalance size.

Each FVG fact can contain:

• direction,  
• upper and lower boundaries,  
• origin bar and time,  
• confirmation bar,  
• mitigation state,  
• invalidation state,  
• test count,  
• fill percentage,  
• latest test bar,  
• origin volume,  
• origin average volume,  
• origin Premium/Discount location,  
• bounded strength,  
• displacement confirmation.

ORDER BLOCKS

Order Block facts are created from a bounded lookback and can require a confirmed BOS or MSS.

The configuration controls whether candle bodies or full candle ranges define the zone.

Each Order Block uses the same auditable lifecycle metadata as an FVG, including origin, tests, fill, mitigation, invalidation, volume, relative volume context, strength and displacement confirmation.

ZONE LIFECYCLE

A zone can be:

• available,  
• tested,  
• partially filled,  
• mitigated,  
• invalidated.

The test counter and fill percentage are updated from confirmed interaction with the stored zone boundaries.

The library does not invent missing origin metadata. If a fact cannot be associated with a valid source, the unavailable value remains unavailable.

LIQUIDITY

The library maintains bounded arrays of confirmed swing-high and swing-low liquidity references.

It derives:

• BSL — Buy-Side Liquidity,  
• SSL — Sell-Side Liquidity,  
• EQH — Equal Highs,  
• EQL — Equal Lows.

Equal-level classification uses the supplied ATR-based tolerance rather than exact floating-point equality.

Liquidity metadata includes:

• side and type,  
• level,  
• origin bar,  
• collection state,  
• collection time,  
• sweep type and level.

A pool origin is preserved only when its price is genuinely associated with the originating swing. The library does not transfer unrelated swing metadata to a new liquidity level.

LIQUIDITY SWEEPS

Depending on configuration, a sweep can require price to move beyond the stored pool and close back inside it.

The returned snapshot distinguishes BSL and SSL sweep facts. A sweep is a confirmed market fact, not a BUY or SELL recommendation.

PREMIUM AND DISCOUNT

The library can build a dealing range from confirmed swing extremes.

The returned context can contain:

• range high,  
• range low,  
• equilibrium,  
• current Premium, Discount or Equilibrium classification.

An unavailable or invalid range remains unavailable rather than using a synthetic fallback.

EMA AND CONTEXT FACTS

The importing indicator supplies the configured fast, medium and slow EMA values together with available higher-timeframe context.

Facts Core returns bounded contextual facts such as:

• EMA trend state,  
• price relation to EMA values,  
• available higher-timeframe trend and bias context.

The library does not request higher-timeframe data itself. This keeps data ownership and confirmation timing inside the importing indicator.

BOUNDED STATE

The implementation uses explicit limits:

• maximum six zones for each kind and direction,  
• maximum eight swing references for each side.

This prevents unlimited state growth and makes runtime behavior predictable.

PUBLIC API

Exported records:

• FactsConfiguration  
• ZoneFact  
• FactsState  
• StructureFacts  
• ZoneFacts  
• LiquidityFacts  
• ContextFacts  
• FactsSnapshot

Exported functions:

• contractVersion()  
• defaultConfiguration()  
• newState()  
• advance(...)  
• snapshotValid(...)

TYPICAL USAGE

An importing indicator should:

1. Create one persistent FactsState.
2. Create or resolve a FactsConfiguration.
3. Supply confirmed OHLCV, ATR, EMA and available context values to advance().
4. Store the returned state.
5. Read the returned FactsSnapshot.
6. Validate the snapshot with snapshotValid().
7. Present or transport only facts that are actually available.

Conceptual example:

```pine
import AreXoN_/SMCNexusFactsCoreV2/1 as facts

var facts.FactsState state = facts.newState()
facts.FactsConfiguration configuration =
    facts.defaultConfiguration()

[stateNext, snapshot] = facts.advance(
    state,
    configuration,
    barstate.isconfirmed,
    bar_index,
    time,
    open,
    high,
    low,
    close,
    volume,
    atr14,
    emaFast,
    emaMedium,
    emaSlow,
    higherTimeframeTrend,
    higherTimeframeBias,
    localContext)

state := stateNext

bool validSnapshot = facts.snapshotValid(snapshot)
```

The example is conceptual. The exact function signature in the published source is authoritative. Replace the example import with the exact path assigned by TradingView.

WHY THE CHART IS CLEAN

This is a non-visual market-facts library. It intentionally creates no plots, labels, boxes, lines, tables or chart drawings.

The publication chart is therefore intentionally clean and contains no other indicators or unexplained visual elements. An importing indicator is responsible for visual presentation.

LIMITATIONS

• Facts are based on the chart OHLCV series supplied by the importer.  
• Swing confirmation necessarily occurs after the configured right-side bars.  
• The library does not provide native bid/ask data, footprint or real order flow.  
• Chart volume may be broker tick volume rather than centralized exchange volume.  
• It does not verify spread, slippage or broker execution.  
• It does not request macroeconomic information.  
• It does not produce trading signals or recommendations.  
• It does not place, modify or close orders.  
• It produces no visual chart output by itself.

Contract version: 1.0.0.

This library is an analytical and software-development component. It is not investment advice, a trading recommendation or an automated trading system.

---

## Source Code

````pine
//@version=6
library("SMCNexusFactsCoreV2", overlay = true)

// Open-source SMC Nexus Facts Core V2 publication candidate.
// Confirmed, bounded chart-timeframe facts for importing Pine indicators.
// No drawings, inputs, requests, alerts, transport, scoring or trade planning.

const string CONTRACT_VERSION = "1.0.0"
const string PARITY_LEVEL = "CHART_TIMEFRAME"
const int MAX_ZONES_PER_KIND_DIRECTION = 6
const int MAX_SWINGS_PER_SIDE = 8

export type FactsConfiguration
    int swingLeftBars
    int swingRightBars
    bool bosRequireCloseBreak
    bool mssRequireCloseBreak
    bool mssRequirePreviousOppositeBias
    bool mssRequireDisplacement
    float mssDisplacementAtrMultiplier
    bool fvgUseAtrFilter
    float fvgMinSizeAtrMultiplier
    int obLookbackBars
    bool obRequireBosOrMss
    bool obUseCandleBody
    int liquidityLookbackSwings
    float equalLiquidityAtrMultiplier
    bool requireSweepCloseBackInside
    int premiumDiscountLookbackSwings
    int emaFastLength
    int emaMediumLength
    int emaSlowLength

export type ZoneFact
    bool available
    string kind
    string direction
    float top
    float bottom
    int originBar
    int confirmedBar
    bool mitigated
    bool invalidated
    int testCount
    float fillPercent
    int lastTestBar
    int originTime
    float originVolume
    float originAverageVolume
    string originPremiumDiscount
    float strength
    bool afterDisplacement

export type FactsState
    float previousHigh
    float previousLow
    float lastHighPrice
    float lastLowPrice
    int lastHighOriginBar
    int lastLowOriginBar
    string lastHighType
    string lastLowType
    string marketBias
    int breakConsumedHighOriginBar
    int breakConsumedLowOriginBar
    int mssConsumedHighOriginBar
    int mssConsumedLowOriginBar
    string lastBreakType
    string lastBreakDirection
    int lastBreakBar
    string lastMssDirection
    int lastMssBar
    array<float> swingHighPrices
    array<int> swingHighBars
    array<float> swingLowPrices
    array<int> swingLowBars
    array<ZoneFact> zones
    string highPool
    float highLevel
    int highOriginBar
    string lowPool
    float lowLevel
    int lowOriginBar
    int consumedBslOriginBar
    int consumedSslOriginBar
    bool highCollected
    int highCollectedTime
    bool lowCollected
    int lowCollectedTime
    string lastSweep
    int lastSweepBar

export type StructureFacts
    bool ready
    float lastHighPrice
    float lastLowPrice
    int lastHighOriginBar
    int lastLowOriginBar
    string lastHighType
    string lastLowType
    string structure
    string marketBias
    string lastBreakType
    string lastBreakDirection
    int lastBreakBar
    string lastMssDirection
    int lastMssBar

export type ZoneFacts
    ZoneFact latestAny
    ZoneFact latestBullish
    ZoneFact latestBearish
    int fvgCount
    int obCount

export type LiquidityFacts
    string highPool
    float highLevel
    int highOriginBar
    string lowPool
    float lowLevel
    int lowOriginBar
    bool highCollected
    int highCollectedTime
    bool lowCollected
    int lowCollectedTime
    string lastSweep
    int lastSweepBar
    bool pdValid
    float rangeHigh
    float rangeLow
    int rangeHighBar
    int rangeLowBar
    float equilibrium
    string pdZone

export type ContextFacts
    string emaTrend
    string currentBias
    string marketPhase
    string primaryTrend
    string primaryBias
    string smartMoney
    int smartMoneyScore
    string liquidity
    string momentum

export type FactsSnapshot
    bool ready
    bool confirmedBar
    string parityLevel
    StructureFacts structure
    ZoneFacts zones
    LiquidityFacts liquidity
    ContextFacts context

export contractVersion() =>
    CONTRACT_VERSION

export defaultConfiguration() =>
    FactsConfiguration.new(
      swingLeftBars = 3,
      swingRightBars = 3,
      bosRequireCloseBreak = true,
      mssRequireCloseBreak = true,
      mssRequirePreviousOppositeBias = true,
      mssRequireDisplacement = true,
      mssDisplacementAtrMultiplier = 1.2,
      fvgUseAtrFilter = false,
      fvgMinSizeAtrMultiplier = 0.1,
      obLookbackBars = 10,
      obRequireBosOrMss = true,
      obUseCandleBody = false,
      liquidityLookbackSwings = 5,
      equalLiquidityAtrMultiplier = 0.15,
      requireSweepCloseBackInside = true,
      premiumDiscountLookbackSwings = 5,
      emaFastLength = 20,
      emaMediumLength = 50,
      emaSlowLength = 200)

export newState() =>
    FactsState.new(
      previousHigh = na,
      previousLow = na,
      lastHighPrice = na,
      lastLowPrice = na,
      lastHighOriginBar = na,
      lastLowOriginBar = na,
      lastHighType = "NEUTRAL",
      lastLowType = "NEUTRAL",
      marketBias = "NEUTRAL",
      breakConsumedHighOriginBar = na,
      breakConsumedLowOriginBar = na,
      mssConsumedHighOriginBar = na,
      mssConsumedLowOriginBar = na,
      lastBreakType = "NONE",
      lastBreakDirection = "NONE",
      lastBreakBar = na,
      lastMssDirection = "NONE",
      lastMssBar = na,
      swingHighPrices = array.new<float>(),
      swingHighBars = array.new<int>(),
      swingLowPrices = array.new<float>(),
      swingLowBars = array.new<int>(),
      zones = array.new<ZoneFact>(),
      highPool = "NONE",
      highLevel = na,
      highOriginBar = na,
      lowPool = "NONE",
      lowLevel = na,
      lowOriginBar = na,
      consumedBslOriginBar = na,
      consumedSslOriginBar = na,
      highCollected = false,
      highCollectedTime = na,
      lowCollected = false,
      lowCollectedTime = na,
      lastSweep = "NONE",
      lastSweepBar = na)

emptyZone() =>
    ZoneFact.new(false, "NONE", "NONE", na, na, na, na, false, false, 0, 0.0, na, na, na, na, "UNKNOWN", na, false)

boundedInt(int value, int minimum, int maximum) =>
    math.max(minimum, math.min(maximum, value))

classifySwingHigh(float current, float previous) =>
    na(previous) or current == previous ? "NEUTRAL" : current > previous ? "HH" : "LH"

classifySwingLow(float current, float previous) =>
    na(previous) or current == previous ? "NEUTRAL" : current > previous ? "HL" : "LL"

classifyStructure(string highType, string lowType) =>
    highType == "NEUTRAL" or lowType == "NEUTRAL" ? "UNKNOWN" : highType == "HH" and lowType == "HL" ? "UP" : highType == "LH" and lowType == "LL" ? "DOWN" : "MIXED"

directionScore(string value) =>
    value == "BUY" or value == "UP" or value == "BULLISH" ? 1 : value == "SELL" or value == "DOWN" or value == "BEARISH" ? -1 : 0

pushSwing(array<float> prices, array<int> bars, float price, int originBar) =>
    array.push(prices, price)
    array.push(bars, originBar)
    while array.size(prices) > MAX_SWINGS_PER_SIDE
        array.shift(prices)
        array.shift(bars)

liquidityPool(array<float> prices, int lookback, float atrValue, float toleranceMultiplier, bool highSide) =>
    string result = highSide ? "BSL" : "SSL"
    int size = array.size(prices)
    if size > 0 and not na(atrValue)
        float newest = array.get(prices, size - 1)
        float tolerance = atrValue * toleranceMultiplier
        int first = math.max(0, size - boundedInt(lookback, 2, MAX_SWINGS_PER_SIDE))
        int matches = 0
        for index = first to size - 1
            if math.abs(array.get(prices, index) - newest) <= tolerance
                matches += 1
        result := matches >= 2 ? highSide ? "EQH" : "EQL" : result
    result

zoneCount(array<ZoneFact> zones, string kind, string direction) =>
    int count = 0
    if array.size(zones) > 0
        for index = 0 to array.size(zones) - 1
            ZoneFact zone = array.get(zones, index)
            if zone.kind == kind and zone.direction == direction
                count += 1
    count

addBoundedZone(array<ZoneFact> zones, ZoneFact newZone) =>
    if zoneCount(zones, newZone.kind, newZone.direction) >= MAX_ZONES_PER_KIND_DIRECTION
        int removeIndex = na
        if array.size(zones) > 0
            for index = 0 to array.size(zones) - 1
                ZoneFact zone = array.get(zones, index)
                if na(removeIndex) and zone.kind == newZone.kind and zone.direction == newZone.direction
                    removeIndex := index
        if not na(removeIndex)
            array.remove(zones, removeIndex)
    array.push(zones, newZone)

mitigateZones(array<ZoneFact> zones, bool confirmed, int currentBarIndex, float highPrice, float lowPrice) =>
    if confirmed and array.size(zones) > 0
        for index = 0 to array.size(zones) - 1
            ZoneFact zone = array.get(zones, index)
            int minimumAge = zone.kind == "FVG" ? 2 : 1
            bool oldEnough = currentBarIndex > zone.originBar + minimumAge
            float zoneLow = math.min(zone.top, zone.bottom)
            float zoneHigh = math.max(zone.top, zone.bottom)
            float zoneWidth = zoneHigh - zoneLow
            bool touched = zone.direction == "BULLISH" ? lowPrice <= zoneHigh : zone.direction == "BEARISH" ? highPrice >= zoneLow : false
            if zone.available and not zone.mitigated and not zone.invalidated and oldEnough and touched
                float currentFill = zoneWidth > 0.0 ? zone.direction == "BULLISH" ? (zoneHigh - lowPrice) / zoneWidth * 100.0 : zone.direction == "BEARISH" ? (highPrice - zoneLow) / zoneWidth * 100.0 : 0.0 : 100.0
                float boundedFill = math.max(0.0, math.min(100.0, currentFill))
                zone.fillPercent := math.max(zone.fillPercent, boundedFill)
                if na(zone.lastTestBar) or zone.lastTestBar != currentBarIndex
                    zone.testCount := zone.testCount + 1
                    zone.lastTestBar := currentBarIndex
                zone.mitigated := zone.fillPercent >= 100.0
                array.set(zones, index, zone)

latestZones(array<ZoneFact> zones) =>
    ZoneFact latestAny = emptyZone()
    ZoneFact latestBullish = emptyZone()
    ZoneFact latestBearish = emptyZone()
    int fvgCount = 0
    int obCount = 0
    if array.size(zones) > 0
        for index = 0 to array.size(zones) - 1
            ZoneFact zone = array.get(zones, index)
            if zone.kind == "FVG"
                fvgCount += 1
            else if zone.kind == "OB"
                obCount += 1
            if zone.available and not zone.mitigated and not zone.invalidated
                latestAny := zone
                if zone.direction == "BULLISH"
                    latestBullish := zone
                else if zone.direction == "BEARISH"
                    latestBearish := zone
    [latestAny, latestBullish, latestBearish, fvgCount, obCount]

latestZoneDirection(array<ZoneFact> zones, string kind) =>
    string result = "NONE"
    if array.size(zones) > 0
        for index = 0 to array.size(zones) - 1
            ZoneFact zone = array.get(zones, index)
            if zone.kind == kind and zone.available and not zone.mitigated and not zone.invalidated
                result := zone.direction
    result

primaryTrend(int score) =>
    score >= 3 ? "STRONG_BUY" : score > 0 ? "BUY" : score <= -3 ? "STRONG_SELL" : score < 0 ? "SELL" : "NEUTRAL"

smartMoney(int score) =>
    score >= 4 ? "STRONG_BULLISH" : score > 0 ? "BULLISH" : score <= -4 ? "STRONG_BEARISH" : score < 0 ? "BEARISH" : "NEUTRAL"

premiumDiscountAtOrigin(float price, float rangeHigh, float rangeLow) =>
    not na(price) and not na(rangeHigh) and not na(rangeLow) and rangeHigh > rangeLow ? price > (rangeHigh + rangeLow) / 2.0 ? "PREMIUM" : price < (rangeHigh + rangeLow) / 2.0 ? "DISCOUNT" : "EQUILIBRIUM" : "UNKNOWN"

configurationValid(FactsConfiguration config) =>
    config.swingLeftBars >= 1 and config.swingLeftBars <= 50 and
      config.swingRightBars >= 1 and config.swingRightBars <= 50 and
      config.mssDisplacementAtrMultiplier >= 0.1 and config.mssDisplacementAtrMultiplier <= 10.0 and
      config.fvgMinSizeAtrMultiplier >= 0.0 and config.fvgMinSizeAtrMultiplier <= 10.0 and
      config.obLookbackBars >= 1 and config.obLookbackBars <= 48 and
      config.liquidityLookbackSwings >= 2 and config.liquidityLookbackSwings <= MAX_SWINGS_PER_SIDE and
      config.equalLiquidityAtrMultiplier >= 0.0 and config.equalLiquidityAtrMultiplier <= 5.0 and
      config.premiumDiscountLookbackSwings >= 2 and config.premiumDiscountLookbackSwings <= MAX_SWINGS_PER_SIDE and
      config.emaFastLength >= 1 and config.emaFastLength <= 500 and
      config.emaMediumLength >= 1 and config.emaMediumLength <= 500 and
      config.emaSlowLength >= 1 and config.emaSlowLength <= 500

export advance(FactsState state, FactsConfiguration config, bool confirmed, int currentBarIndex, int currentTime, float openPrice, float highPrice, float lowPrice, float closePrice, float currentVolume, float atr14, float emaFast, float emaMedium, float emaSlow, string mtfH4Trend, string mtfH1Trend, string mtfH1Bias) =>
    max_bars_back(currentTime, 128)
    max_bars_back(openPrice, 128)
    max_bars_back(highPrice, 128)
    max_bars_back(lowPrice, 128)
    max_bars_back(closePrice, 128)
    max_bars_back(currentVolume, 128)
    float averageVolume20 = ta.sma(currentVolume, 20)

    bool configValid = configurationValid(config)
    float swingHighPivot = configValid ? ta.pivothigh(highPrice, config.swingLeftBars, config.swingRightBars) : na
    float swingLowPivot = configValid ? ta.pivotlow(lowPrice, config.swingLeftBars, config.swingRightBars) : na
    bool highConfirmed = confirmed and not na(swingHighPivot)
    bool lowConfirmed = confirmed and not na(swingLowPivot)

    if highConfirmed
        int originBar = currentBarIndex - config.swingRightBars
        string highType = classifySwingHigh(swingHighPivot, state.previousHigh)
        state.lastHighPrice := swingHighPivot
        state.lastHighOriginBar := originBar
        state.lastHighType := highType
        state.previousHigh := swingHighPivot
        pushSwing(state.swingHighPrices, state.swingHighBars, swingHighPivot, originBar)
        state.highPool := liquidityPool(state.swingHighPrices, config.liquidityLookbackSwings, atr14, config.equalLiquidityAtrMultiplier, true)
        state.highLevel := swingHighPivot
        state.highOriginBar := originBar
        state.highCollected := false
        state.highCollectedTime := na

    if lowConfirmed
        int originBar = currentBarIndex - config.swingRightBars
        string lowType = classifySwingLow(swingLowPivot, state.previousLow)
        state.lastLowPrice := swingLowPivot
        state.lastLowOriginBar := originBar
        state.lastLowType := lowType
        state.previousLow := swingLowPivot
        pushSwing(state.swingLowPrices, state.swingLowBars, swingLowPivot, originBar)
        state.lowPool := liquidityPool(state.swingLowPrices, config.liquidityLookbackSwings, atr14, config.equalLiquidityAtrMultiplier, false)
        state.lowLevel := swingLowPivot
        state.lowOriginBar := originBar
        state.lowCollected := false
        state.lowCollectedTime := na

    string priorBias = state.marketBias
    bool breakUp = configValid and not na(state.lastHighPrice) and not na(state.lastHighOriginBar) and (na(state.breakConsumedHighOriginBar) or state.breakConsumedHighOriginBar != state.lastHighOriginBar) and (config.bosRequireCloseBreak ? closePrice > state.lastHighPrice : highPrice > state.lastHighPrice)
    bool breakDown = configValid and not na(state.lastLowPrice) and not na(state.lastLowOriginBar) and (na(state.breakConsumedLowOriginBar) or state.breakConsumedLowOriginBar != state.lastLowOriginBar) and (config.bosRequireCloseBreak ? closePrice < state.lastLowPrice : lowPrice < state.lastLowPrice)
    bool breakBullEvent = false
    bool breakBearEvent = false
    string breakTypeThisBar = "NONE"
    string breakDirectionThisBar = "NONE"

    if confirmed and breakUp and not breakDown
        string eventType = priorBias == "BEARISH" ? "CHOCH" : priorBias == "BULLISH" or state.lastLowType == "HL" or state.lastHighType == "HH" ? "BOS" : "NONE"
        if eventType != "NONE"
            state.lastBreakType := eventType
            state.lastBreakDirection := "UP"
            state.lastBreakBar := currentBarIndex
            breakTypeThisBar := eventType
            breakDirectionThisBar := "UP"
            breakBullEvent := true
        state.marketBias := "BULLISH"
        state.breakConsumedHighOriginBar := state.lastHighOriginBar
    else if confirmed and breakDown and not breakUp
        string eventType = priorBias == "BULLISH" ? "CHOCH" : priorBias == "BEARISH" or state.lastHighType == "LH" or state.lastLowType == "LL" ? "BOS" : "NONE"
        if eventType != "NONE"
            state.lastBreakType := eventType
            state.lastBreakDirection := "DOWN"
            state.lastBreakBar := currentBarIndex
            breakTypeThisBar := eventType
            breakDirectionThisBar := "DOWN"
            breakBearEvent := true
        state.marketBias := "BEARISH"
        state.breakConsumedLowOriginBar := state.lastLowOriginBar

    bool mssBreakUp = configValid and not na(state.lastHighPrice) and not na(state.lastHighOriginBar) and (na(state.mssConsumedHighOriginBar) or state.mssConsumedHighOriginBar != state.lastHighOriginBar) and (config.mssRequireCloseBreak ? closePrice > state.lastHighPrice : highPrice > state.lastHighPrice)
    bool mssBreakDown = configValid and not na(state.lastLowPrice) and not na(state.lastLowOriginBar) and (na(state.mssConsumedLowOriginBar) or state.mssConsumedLowOriginBar != state.lastLowOriginBar) and (config.mssRequireCloseBreak ? closePrice < state.lastLowPrice : lowPrice < state.lastLowPrice)
    bool displacement = not na(atr14) and highPrice - lowPrice >= atr14 * config.mssDisplacementAtrMultiplier
    bool bullishMss = confirmed and mssBreakUp and not mssBreakDown and (not config.mssRequirePreviousOppositeBias or priorBias == "BEARISH") and (not config.mssRequireDisplacement or displacement)
    bool bearishMss = confirmed and mssBreakDown and not mssBreakUp and (not config.mssRequirePreviousOppositeBias or priorBias == "BULLISH") and (not config.mssRequireDisplacement or displacement)
    if bullishMss
        state.lastMssDirection := "BULLISH"
        state.lastMssBar := currentBarIndex
        state.mssConsumedHighOriginBar := state.lastHighOriginBar
    else if bearishMss
        state.lastMssDirection := "BEARISH"
        state.lastMssBar := currentBarIndex
        state.mssConsumedLowOriginBar := state.lastLowOriginBar

    mitigateZones(state.zones, confirmed and configValid, currentBarIndex, highPrice, lowPrice)

    if confirmed and configValid and currentBarIndex >= 2
        float bullishGap = lowPrice - highPrice[2]
        float bearishGap = lowPrice[2] - highPrice
        bool filterReady = not config.fvgUseAtrFilter or not na(atr14)
        float minimumGap = config.fvgUseAtrFilter ? atr14 * config.fvgMinSizeAtrMultiplier : 0.0
        bool bullishFvg = filterReady and bullishGap > 0.0 and bullishGap >= minimumGap
        bool bearishFvg = filterReady and bearishGap > 0.0 and bearishGap >= minimumGap
        if bullishFvg and not bearishFvg
            float strength = not na(atr14[2]) and atr14[2] > 0.0 ? math.min(100.0, bullishGap / atr14[2] * 100.0) : na
            bool afterDisplacement = not na(atr14) and atr14 > 0.0 and highPrice - lowPrice >= atr14
            string originPd = premiumDiscountAtOrigin((lowPrice + highPrice[2]) / 2.0, state.lastHighPrice, state.lastLowPrice)
            addBoundedZone(state.zones, ZoneFact.new(true, "FVG", "BULLISH", lowPrice, highPrice[2], currentBarIndex - 2, currentBarIndex, false, false, 0, 0.0, na, currentTime[2], currentVolume[2], averageVolume20[2], originPd, strength, afterDisplacement))
        else if bearishFvg and not bullishFvg
            float strength = not na(atr14[2]) and atr14[2] > 0.0 ? math.min(100.0, bearishGap / atr14[2] * 100.0) : na
            bool afterDisplacement = not na(atr14) and atr14 > 0.0 and highPrice - lowPrice >= atr14
            string originPd = premiumDiscountAtOrigin((lowPrice[2] + highPrice) / 2.0, state.lastHighPrice, state.lastLowPrice)
            addBoundedZone(state.zones, ZoneFact.new(true, "FVG", "BEARISH", lowPrice[2], highPrice, currentBarIndex - 2, currentBarIndex, false, false, 0, 0.0, na, currentTime[2], currentVolume[2], averageVolume20[2], originPd, strength, afterDisplacement))

    bool obBullTrigger = config.obRequireBosOrMss ? breakBullEvent or bullishMss : closePrice > openPrice and displacement
    bool obBearTrigger = config.obRequireBosOrMss ? breakBearEvent or bearishMss : closePrice < openPrice and displacement
    if confirmed and configValid and obBullTrigger != obBearTrigger
        bool bullishDirection = obBullTrigger
        bool found = false
        int lookback = boundedInt(config.obLookbackBars, 1, 48)
        for offset = 1 to lookback
            bool oppositeCandle = bullishDirection ? closePrice[offset] < openPrice[offset] : closePrice[offset] > openPrice[offset]
            if not found and oppositeCandle
                float zoneTop = config.obUseCandleBody ? math.max(openPrice[offset], closePrice[offset]) : highPrice[offset]
                float zoneBottom = config.obUseCandleBody ? math.min(openPrice[offset], closePrice[offset]) : lowPrice[offset]
                float strength = not na(atr14[offset]) and atr14[offset] > 0.0 ? math.min(100.0, math.abs(zoneTop - zoneBottom) / atr14[offset] * 100.0) : na
                string originPd = premiumDiscountAtOrigin((zoneTop + zoneBottom) / 2.0, state.lastHighPrice, state.lastLowPrice)
                addBoundedZone(state.zones, ZoneFact.new(true, "OB", bullishDirection ? "BULLISH" : "BEARISH", zoneTop, zoneBottom, currentBarIndex - offset, currentBarIndex, false, false, 0, 0.0, na, currentTime[offset], currentVolume[offset], averageVolume20[offset], originPd, strength, displacement))
                found := true

    bool bslSweep = confirmed and configValid and not na(state.highLevel) and not na(state.highOriginBar) and (na(state.consumedBslOriginBar) or state.consumedBslOriginBar != state.highOriginBar) and highPrice > state.highLevel and (not config.requireSweepCloseBackInside or closePrice < state.highLevel)
    bool sslSweep = confirmed and configValid and not na(state.lowLevel) and not na(state.lowOriginBar) and (na(state.consumedSslOriginBar) or state.consumedSslOriginBar != state.lowOriginBar) and lowPrice < state.lowLevel and (not config.requireSweepCloseBackInside or closePrice > state.lowLevel)
    if bslSweep and not sslSweep
        state.lastSweep := "BSL_SWEEP"
        state.lastSweepBar := currentBarIndex
        state.consumedBslOriginBar := state.highOriginBar
        state.highCollected := true
        state.highCollectedTime := currentTime
    else if sslSweep and not bslSweep
        state.lastSweep := "SSL_SWEEP"
        state.lastSweepBar := currentBarIndex
        state.consumedSslOriginBar := state.lowOriginBar
        state.lowCollected := true
        state.lowCollectedTime := currentTime

    [latestAny, latestBullish, latestBearish, fvgCount, obCount] = latestZones(state.zones)
    string currentStructure = classifyStructure(state.lastHighType, state.lastLowType)

    bool hasRangeHigh = array.size(state.swingHighPrices) > 0
    bool hasRangeLow = array.size(state.swingLowPrices) > 0
    float rangeHigh = hasRangeHigh ? array.get(state.swingHighPrices, array.size(state.swingHighPrices) - 1) : na
    float rangeLow = hasRangeLow ? array.get(state.swingLowPrices, array.size(state.swingLowPrices) - 1) : na
    int rangeHighBar = hasRangeHigh ? array.get(state.swingHighBars, array.size(state.swingHighBars) - 1) : na
    int rangeLowBar = hasRangeLow ? array.get(state.swingLowBars, array.size(state.swingLowBars) - 1) : na
    bool pdValid = not na(rangeHigh) and not na(rangeLow) and rangeHigh > rangeLow
    float equilibrium = pdValid ? (rangeHigh + rangeLow) / 2.0 : na
    float pdTolerance = not na(atr14) ? atr14 * 0.05 : na
    string pdZone = not pdValid or na(pdTolerance) ? "UNKNOWN" : math.abs(closePrice - equilibrium) <= pdTolerance ? "EQUILIBRIUM" : closePrice > equilibrium ? "PREMIUM" : "DISCOUNT"

    bool emaStackedUp = emaFast > emaMedium and emaMedium > emaSlow
    bool emaStackedDown = emaFast < emaMedium and emaMedium < emaSlow
    string emaTrend = na(emaSlow) ? "NEUTRAL" : closePrice >= emaSlow and emaStackedUp ? "BUY" : closePrice <= emaSlow and emaStackedDown ? "SELL" : closePrice >= emaSlow ? "BUY" : "SELL"
    string localBias = state.marketBias == "BULLISH" ? "BUY" : state.marketBias == "BEARISH" ? "SELL" : "NEUTRAL"
    bool correction = localBias != "NEUTRAL" and localBias != emaTrend or state.lastBreakType == "CHOCH"
    string currentBias = localBias == "NEUTRAL" ? "NEUTRAL" : correction ? localBias + "_CORRECTION" : localBias
    bool reversalWatch = state.lastBreakType == "CHOCH" or state.lastMssDirection == "BULLISH" and emaTrend == "SELL" or state.lastMssDirection == "BEARISH" and emaTrend == "BUY"
    string marketPhase = reversalWatch ? "REVERSAL_WATCH" : correction ? "PULLBACK" : emaTrend == "BUY" and state.marketBias == "BULLISH" and currentStructure == "UP" ? "TREND_UP" : emaTrend == "SELL" and state.marketBias == "BEARISH" and currentStructure == "DOWN" ? "TREND_DOWN" : "RANGE"
    int primaryScore = directionScore(mtfH4Trend) + directionScore(mtfH1Trend) + directionScore(emaTrend) + directionScore(currentStructure)
    string resolvedPrimaryTrend = primaryTrend(primaryScore)
    string resolvedPrimaryBias = mtfH1Bias == "NEUTRAL" ? "NEUTRAL" : marketPhase == "PULLBACK" ? mtfH1Bias + "_CORRECTION" : mtfH1Bias

    string fvgDirection = latestZoneDirection(state.zones, "FVG")
    string obDirection = latestZoneDirection(state.zones, "OB")
    int smartScore = directionScore(state.lastMssDirection) * 2
    smartScore += directionScore(state.lastBreakDirection)
    smartScore += directionScore(fvgDirection)
    smartScore += directionScore(obDirection)
    smartScore += state.lastSweep == "SSL_SWEEP" ? 1 : state.lastSweep == "BSL_SWEEP" ? -1 : 0
    string resolvedSmartMoney = smartMoney(smartScore)

    string liquidityContext = state.lastSweep != "NONE" ? "AFTER_SWEEP" : na(state.highLevel) or na(state.lowLevel) ? "NO_CLEAR_LIQUIDITY" : closePrice > state.highLevel ? "ABOVE_BSL" : closePrice < state.lowLevel ? "BELOW_SSL" : "INSIDE_RANGE"
    string momentum = marketPhase == "RANGE" or currentStructure == "MIXED" or currentStructure == "UNKNOWN" ? "RANGING" : marketPhase == "PULLBACK" or correction ? "CORRECTIVE" : emaStackedUp or emaStackedDown ? "IMPULSIVE" : "RANGING"

    int warmupBars = math.max(config.emaSlowLength - 1, config.swingLeftBars + config.swingRightBars)
    bool ready = configValid and confirmed and currentBarIndex >= warmupBars and not na(atr14) and not na(emaSlow)
    StructureFacts structureFacts = StructureFacts.new(ready, state.lastHighPrice, state.lastLowPrice, state.lastHighOriginBar, state.lastLowOriginBar, state.lastHighType, state.lastLowType, currentStructure, state.marketBias, state.lastBreakType, state.lastBreakDirection, state.lastBreakBar, state.lastMssDirection, state.lastMssBar)
    ZoneFacts zoneFacts = ZoneFacts.new(latestAny, latestBullish, latestBearish, fvgCount, obCount)
    LiquidityFacts liquidityFacts = LiquidityFacts.new(state.highPool, state.highLevel, state.highOriginBar, state.lowPool, state.lowLevel, state.lowOriginBar, state.highCollected, state.highCollectedTime, state.lowCollected, state.lowCollectedTime, state.lastSweep, state.lastSweepBar, pdValid, rangeHigh, rangeLow, rangeHighBar, rangeLowBar, equilibrium, pdZone)
    ContextFacts contextFacts = ContextFacts.new(emaTrend, currentBias, marketPhase, resolvedPrimaryTrend, resolvedPrimaryBias, resolvedSmartMoney, smartScore, liquidityContext, momentum)
    FactsSnapshot.new(ready, confirmed, PARITY_LEVEL, structureFacts, zoneFacts, liquidityFacts, contextFacts)

export snapshotValid(FactsSnapshot snapshot) =>
    snapshot.confirmedBar and snapshot.parityLevel == PARITY_LEVEL and
      (snapshot.structure.structure == "UP" or snapshot.structure.structure == "DOWN" or snapshot.structure.structure == "MIXED" or snapshot.structure.structure == "UNKNOWN") and
      (snapshot.context.emaTrend == "BUY" or snapshot.context.emaTrend == "SELL" or snapshot.context.emaTrend == "NEUTRAL") and
      snapshot.zones.fvgCount >= 0 and snapshot.zones.fvgCount <= 2 * MAX_ZONES_PER_KIND_DIRECTION and
      snapshot.zones.obCount >= 0 and snapshot.zones.obCount <= 2 * MAX_ZONES_PER_KIND_DIRECTION
````
