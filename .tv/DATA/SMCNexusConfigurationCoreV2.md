<!-- tradingview-pine-id: PUB;6f88a209daf0472eac5b37e6d173e174 -->
<!-- tradingviewscripts-format: 1 -->
# SMCNexusConfigurationCoreV2

Source: https://www.tradingview.com/script/T1uHDgKr/

## Description

SMCNexusConfigurationCoreV2 is an open-source, non-visual Pine Script library for resolving deterministic indicator configuration profiles and bounded visibility settings.

The library separates pure configuration decisions from market detection, chart state and presentation code. It does not generate signals, place orders or draw objects.

The importing indicator supplies its saved manual settings, chart timeframe and supported-symbol state. The library returns typed effective configuration records without calling input functions, requesting external timeframes or changing the importing script's saved settings.

ORIGINAL CONCEPT AND PURPOSE

The library implements three explicit configuration modes:

• MANUAL — preserves every value supplied by the importing indicator.  
• AUTO — applies an exact predefined profile only when the supplied symbol and timeframe combination is explicitly supported.  
• HYBRID — applies automatic values only to individually selected categories while preserving manual values for all other categories.

The implementation does not use nearest-timeframe guessing. An unsupported symbol or timeframe falls back to the supplied manual settings.

Detection parameters and visual settings are resolved separately. This prevents a visibility option from unintentionally disabling the underlying analytical calculation. For example, hiding a market-structure label does not remove the structure state used elsewhere by the importing indicator.

SUPPORTED PROFILE CONTEXT

The profile resolver distinguishes exact chart timeframes:

• M1  
• M5  
• M15  
• M30  
• H1  
• H4  
• D1  
• W1

The importing indicator decides whether the current symbol is supported. If the symbol or timeframe is unsupported, the automatic profile is not applied.

CONFIGURATION CATEGORIES

The resolved configuration includes separate categories for:

• swing structure,  
• Market Structure Shift requirements,  
• Fair Value Gap parameters,  
• Order Block parameters,  
• liquidity and sweep parameters,  
• volume-profile range settings,  
• structure visibility,  
• zone visibility,  
• liquidity and Premium/Discount visibility,  
• EMA, pivot and volume-marker visibility,  
• panel and Trade Plan visibility,  
• trendline and volume-profile visibility.

ADAPTIVE GRID RESOLUTION

The library also contains a bounded adaptive-grid resolver for importing scripts that build a volume-profile approximation.

The resolver receives:

• the manual tick floor,  
• the instrument minimum tick,  
• the current range low and high,  
• the requested target number of bins.

It calculates:

• whether the result is valid,  
• effective ticks per bin,  
• effective bin size,  
• maximum permitted span,  
• actual span in ticks,  
• applied scale.

The effective tick step is never lower than the supplied manual floor. The resolver increases the step using a power-of-two scale when the requested price span would exceed the bounded target. Invalid or incomplete inputs return an unavailable result instead of an invented value.

PUBLIC API

Typed result records:

• ProfileContext  
• CoreConfiguration  
• StructureVisibility  
• ZoneVisibility  
• ContextVisibility  
• OverlayVisibility  
• PanelVisibility  
• AuxiliaryVisibility  
• AdaptiveGridResolution

Exported resolvers:

• resolveAdaptiveGrid(...)  
• resolveProfileContext(...)  
• resolveCoreConfiguration(...)  
• resolveStructureVisibility(...)  
• resolveZoneVisibility(...)  
• resolveContextVisibility(...)  
• resolveOverlayVisibility(...)  
• resolvePanelVisibility(...)  
• resolveAuxiliaryVisibility(...)

INTENDED USE

An importing indicator first creates a ProfileContext. It then passes that context together with its saved manual settings to the required resolver.

Conceptual example:

```pine
import AreXoN_/SMCNexusConfigurationCoreV2/1 as config

config.ProfileContext profile = config.resolveProfileContext(
    configurationMode,
    supportedSymbol,
    timeframe.period,
    autoStructure,
    autoMss,
    autoFvg,
    autoOb,
    autoLiquidity,
    autoVolumeProfile,
    autoVisibility)

config.CoreConfiguration effective = config.resolveCoreConfiguration(
    profile,
    manualSwingLeft,
    manualSwingRight,
    manualRequireCloseBreak,
    manualRequireOppositeBias,
    manualRequireDisplacement,
    manualDisplacementAtr,
    manualFvgCount,
    manualFvgAtrFilter,
    manualFvgAtrSize,
    manualObCount,
    manualObLookback,
    manualObStructureRequirement,
    manualObBodyMode,
    manualLiquidityLookback,
    manualEqualLevelTolerance,
    manualSweepCloseBack,
    manualProfileMode,
    manualProfileBars)
```

The example import path should be replaced with the exact path assigned by TradingView after publication.

WHY THE CHART IS CLEAN

This is a non-visual configuration library. It intentionally creates no plots, labels, tables, lines or boxes.

The publication chart is therefore intentionally clean and contains no additional indicators, drawings or unexplained visual elements. An importing indicator is responsible for presenting the resolved settings.

LIMITATIONS

• Automatic profiles are applied only to exact supported combinations.  
• The library does not optimize settings or claim that a profile is profitable.  
• It does not independently inspect a symbol or identify a broker feed.  
• It does not read live market data.  
• It does not preserve state between executions.  
• It does not place, modify or close orders.  
• It produces no chart output by itself.

This library is a reusable software-development component. It is not investment advice, a trading signal or an automated trading system.

---

## Source Code

````pine
//@version=6
library("SMCNexusConfigurationCoreV2", overlay = true)

// Open-source non-visual configuration library. See docs/TRADINGVIEW_LIBRARY_REPUBLICATION.md.
// It contains the accepted M39 profile/effective-value resolution and the
// pure M40 adaptive-grid resolver introduced for the future published v2.
// Saved inputs and live chart identity are supplied by the importing script.

export type ProfileContext
    bool useStructureProfile
    bool useMssProfile
    bool useFvgProfile
    bool useObProfile
    bool useLiquidityProfile
    bool useVolumeProfile
    bool useVisibilityProfile
    int autoSwingBars
    float autoMssAtr
    float autoFvgAtr
    int autoObLookback
    int autoProfileBars
    bool visLow
    bool visMid
    bool visHtf
    bool visDailyWeekly
    bool visIntraday
    bool visMidOrHtf
    bool visHtfOrHigher

export type CoreConfiguration
    int swingLeftBars
    int swingRightBars
    bool mssRequireCloseBreak
    bool mssRequirePreviousOppositeBias
    bool mssRequireDisplacementCandle
    float mssDisplacementAtrMultiplier
    int fvgMaxActiveBoxes
    bool fvgUseAtrFilter
    float fvgMinSizeAtrMultiplier
    int obMaxActiveBoxes
    int obLookbackBars
    bool obRequireBosOrMss
    bool obUseCandleBody
    int liquidityLookbackSwings
    float equalHighLowToleranceAtrMultiplier
    bool requireSweepCloseBackInside
    string profileRangeMode
    int profileRollingBars

export type StructureVisibility
    bool showSwingPoints
    bool showSwingLabels
    bool showSwingStructureLabels
    bool showHH
    bool showHL
    bool showLH
    bool showLL
    bool showBOS
    bool showCHoCH
    bool showBosChochLines
    bool showBosChochLabels
    bool showMssLines
    bool showMssLabels

export type ZoneVisibility
    bool showBullishFvg
    bool showBearishFvg
    bool showFvgLabels
    bool showFvgMitigationLabels
    bool extendFvgBoxes
    bool showBullishOb
    bool showBearishOb
    bool showObLabels
    bool showObMitigationLabels
    bool extendObBoxes

export type ContextVisibility
    bool showLiquidityHigh
    bool showLiquidityLow
    bool showSweeps
    bool showLiquidityLines
    bool showLiquidityLabels
    bool showPremiumDiscountRange
    bool showPremiumZone
    bool showDiscountZone
    bool showEquilibrium
    bool showPremiumDiscountLabels

export type OverlayVisibility
    bool showEmaFast
    bool showEmaMedium
    bool showEmaSlow
    bool showPivotLines
    bool showPivotLabels
    bool extendPivotLines
    bool showPivotR3
    bool showPivotS3
    bool showVolumeMarkers
    bool showVolumeLabels

export type PanelVisibility
    bool compactMtfPanel
    bool showMtfH4
    bool showMtfH1
    bool showMtfM15
    bool showMtfCurrentTf
    bool compactPanel
    bool showPanelStructure
    bool showPanelScore
    bool showPanelTradePlan
    bool showPanelVolume
    bool showTp3
    bool showPlanLabels
    bool extendPlanLines

export type AuxiliaryVisibility
    bool showUpperTrendline
    bool showLowerTrendline
    bool trendlineExtendRight
    bool showProfilePoc
    bool showProfileVahVal
    bool showProfileValueArea
    bool showProfileHistogram

export type AdaptiveGridResolution
    bool valid
    int effectiveTicks
    float binSize
    int hardSpanCap
    int spanTicks
    int scale

export resolveAdaptiveGrid(int manualTicks, float minimumTick, float rangeLow, float rangeHigh, int targetBins) =>
    bool manualValid = manualTicks >= 1 and manualTicks <= 100000 and not na(minimumTick) and minimumTick > 0.0
    bool targetValid = targetBins >= 256 and targetBins <= 8192
    bool rangeValid = not na(rangeLow) and not na(rangeHigh) and rangeHigh >= rangeLow
    bool validInputs = manualValid and targetValid and rangeValid
    int spanTicks = validInputs ? int(math.ceil(math.max(rangeHigh - rangeLow, minimumTick) / minimumTick)) : 0
    int rawTicksPerBin = validInputs and spanTicks > 0 ? int(math.ceil(float(spanTicks) / targetBins)) : 0
    int requiredScale = validInputs and rawTicksPerBin > 0 ? int(math.ceil(float(rawTicksPerBin) / manualTicks)) : 0
    int scale = 1
    int scaleSteps = 0
    while scale < requiredScale and scaleSteps < 30
        scale := scale * 2
        scaleSteps := scaleSteps + 1
    bool resolved = validInputs and spanTicks > 0 and requiredScale > 0 and scale >= requiredScale
    int effectiveTicks = resolved ? manualTicks * scale : manualTicks
    float resolvedBinSize = resolved ? minimumTick * effectiveTicks : manualValid ? minimumTick * manualTicks : na
    int hardSpanCap = targetValid ? math.min(8192, 2 * targetBins) : 0
    AdaptiveGridResolution.new(resolved and effectiveTicks > 0 and not na(resolvedBinSize) and resolvedBinSize > 0.0,
     effectiveTicks, resolvedBinSize, hardSpanCap, spanTicks, scale)

export resolveProfileContext(string configurationMode, bool supportedSymbol, string chartTimeframe, bool hybridStructure, bool hybridMss, bool hybridFvg, bool hybridOb, bool hybridLiquidity, bool hybridVolumeProfile, bool hybridVisibility) =>
    bool tfM1 = chartTimeframe == "1"
    bool tfM5 = chartTimeframe == "5"
    bool tfM15 = chartTimeframe == "15"
    bool tfM30 = chartTimeframe == "30"
    bool tfH1 = chartTimeframe == "60"
    bool tfH4 = chartTimeframe == "240"
    bool tfD1 = chartTimeframe == "D" or chartTimeframe == "1D"
    bool tfW1 = chartTimeframe == "W" or chartTimeframe == "1W"
    bool available = supportedSymbol and (tfM1 or tfM5 or tfM15 or tfM30 or tfH1 or tfH4 or tfD1 or tfW1)
    bool autoAll = configurationMode == "AUTO" and available
    bool hybridActive = configurationMode == "HYBRID" and available
    bool visLow = tfM1 or tfM5
    bool visMid = tfM15 or tfM30
    bool visHtf = tfH1 or tfH4
    bool visDailyWeekly = tfD1 or tfW1
    ProfileContext.new(autoAll or hybridActive and hybridStructure,
     autoAll or hybridActive and hybridMss,
     autoAll or hybridActive and hybridFvg,
     autoAll or hybridActive and hybridOb,
     autoAll or hybridActive and hybridLiquidity,
     autoAll or hybridActive and hybridVolumeProfile,
     autoAll or hybridActive and hybridVisibility,
     tfM15 or tfM30 ? 4 : tfH1 or tfH4 ? 5 : 3,
     tfM1 ? 1.2 : tfM5 ? 1.3 : tfM15 or tfM30 ? 1.4 : 1.5,
     tfM1 or tfM5 ? 0.2 : tfM15 or tfM30 or tfH1 ? 0.25 : 0.3,
     tfH1 or tfH4 ? 25 : 20,
     tfM1 or tfM5 or tfD1 ? 120 : tfM15 or tfM30 ? 160 : tfW1 ? 104 : 200,
     visLow, visMid, visHtf, visDailyWeekly,
     visLow or visMid or visHtf, visMid or visHtf,
     visHtf or visDailyWeekly)

export resolveCoreConfiguration(ProfileContext profile, int manualSwingLeftBars, int manualSwingRightBars, bool manualMssRequireCloseBreak, bool manualMssRequirePreviousOppositeBias, bool manualMssRequireDisplacementCandle, float manualMssDisplacementAtrMultiplier, int manualFvgMaxActiveBoxes, bool manualFvgUseAtrFilter, float manualFvgMinSizeAtrMultiplier, int manualObMaxActiveBoxes, int manualObLookbackBars, bool manualObRequireBosOrMss, bool manualObUseCandleBody, int manualLiquidityLookbackSwings, float manualEqualHighLowToleranceAtrMultiplier, bool manualRequireSweepCloseBackInside, string manualProfileRangeMode, int manualProfileRollingBars) =>
    CoreConfiguration.new(profile.useStructureProfile ? profile.autoSwingBars : manualSwingLeftBars,
     profile.useStructureProfile ? profile.autoSwingBars : manualSwingRightBars,
     profile.useMssProfile ? true : manualMssRequireCloseBreak,
     profile.useMssProfile ? true : manualMssRequirePreviousOppositeBias,
     profile.useMssProfile ? true : manualMssRequireDisplacementCandle,
     profile.useMssProfile ? profile.autoMssAtr : manualMssDisplacementAtrMultiplier,
     profile.useFvgProfile ? 6 : manualFvgMaxActiveBoxes,
     profile.useFvgProfile ? true : manualFvgUseAtrFilter,
     profile.useFvgProfile ? profile.autoFvgAtr : manualFvgMinSizeAtrMultiplier,
     profile.useObProfile ? 6 : manualObMaxActiveBoxes,
     profile.useObProfile ? profile.autoObLookback : manualObLookbackBars,
     profile.useObProfile ? true : manualObRequireBosOrMss,
     profile.useObProfile ? true : manualObUseCandleBody,
     profile.useLiquidityProfile ? 8 : manualLiquidityLookbackSwings,
     profile.useLiquidityProfile ? 0.1 : manualEqualHighLowToleranceAtrMultiplier,
     profile.useLiquidityProfile ? true : manualRequireSweepCloseBackInside,
     profile.useVolumeProfile ? "Rolling Window" : manualProfileRangeMode,
     profile.useVolumeProfile ? profile.autoProfileBars : manualProfileRollingBars)

export resolveStructureVisibility(ProfileContext profile, bool manualShowSwingPoints, bool manualShowSwingLabels, bool manualShowSwingStructureLabels, bool manualShowHH, bool manualShowHL, bool manualShowLH, bool manualShowLL, bool manualShowBOS, bool manualShowCHoCH, bool manualShowBosChochLines, bool manualShowBosChochLabels, bool manualShowMssLines, bool manualShowMssLabels) =>
    StructureVisibility.new(profile.useVisibilityProfile ? false : manualShowSwingPoints,
     profile.useVisibilityProfile ? false : manualShowSwingLabels,
     profile.useVisibilityProfile ? true : manualShowSwingStructureLabels,
     profile.useVisibilityProfile ? true : manualShowHH,
     profile.useVisibilityProfile ? true : manualShowHL,
     profile.useVisibilityProfile ? true : manualShowLH,
     profile.useVisibilityProfile ? true : manualShowLL,
     profile.useVisibilityProfile ? true : manualShowBOS,
     profile.useVisibilityProfile ? true : manualShowCHoCH,
     profile.useVisibilityProfile ? true : manualShowBosChochLines,
     profile.useVisibilityProfile ? true : manualShowBosChochLabels,
     profile.useVisibilityProfile ? not profile.visDailyWeekly : manualShowMssLines,
     profile.useVisibilityProfile ? not profile.visDailyWeekly : manualShowMssLabels)

export resolveZoneVisibility(ProfileContext profile, bool manualShowBullishFvg, bool manualShowBearishFvg, bool manualShowFvgLabels, bool manualShowFvgMitigationLabels, bool manualExtendFvgBoxes, bool manualShowBullishOb, bool manualShowBearishOb, bool manualShowObLabels, bool manualShowObMitigationLabels, bool manualExtendObBoxes) =>
    ZoneVisibility.new(profile.useVisibilityProfile ? true : manualShowBullishFvg,
     profile.useVisibilityProfile ? true : manualShowBearishFvg,
     profile.useVisibilityProfile ? not profile.visDailyWeekly : manualShowFvgLabels,
     profile.useVisibilityProfile ? false : manualShowFvgMitigationLabels,
     profile.useVisibilityProfile ? true : manualExtendFvgBoxes,
     profile.useVisibilityProfile ? true : manualShowBullishOb,
     profile.useVisibilityProfile ? true : manualShowBearishOb,
     profile.useVisibilityProfile ? not profile.visDailyWeekly : manualShowObLabels,
     profile.useVisibilityProfile ? false : manualShowObMitigationLabels,
     profile.useVisibilityProfile ? true : manualExtendObBoxes)

export resolveContextVisibility(ProfileContext profile, bool manualShowLiquidityHigh, bool manualShowLiquidityLow, bool manualShowSweeps, bool manualShowLiquidityLines, bool manualShowLiquidityLabels, bool manualShowPremiumDiscountRange, bool manualShowPremiumZone, bool manualShowDiscountZone, bool manualShowEquilibrium, bool manualShowPremiumDiscountLabels) =>
    ContextVisibility.new(profile.useVisibilityProfile ? profile.visIntraday : manualShowLiquidityHigh,
     profile.useVisibilityProfile ? profile.visIntraday : manualShowLiquidityLow,
     profile.useVisibilityProfile ? profile.visIntraday : manualShowSweeps,
     profile.useVisibilityProfile ? profile.visIntraday : manualShowLiquidityLines,
     profile.useVisibilityProfile ? not profile.visDailyWeekly : manualShowLiquidityLabels,
     profile.useVisibilityProfile ? not profile.visLow : manualShowPremiumDiscountRange,
     profile.useVisibilityProfile ? not profile.visLow : manualShowPremiumZone,
     profile.useVisibilityProfile ? not profile.visLow : manualShowDiscountZone,
     profile.useVisibilityProfile ? not profile.visLow : manualShowEquilibrium,
     profile.useVisibilityProfile ? profile.visMidOrHtf : manualShowPremiumDiscountLabels)

export resolveOverlayVisibility(ProfileContext profile, bool manualShowEmaFast, bool manualShowEmaMedium, bool manualShowEmaSlow, bool manualShowPivotLines, bool manualShowPivotLabels, bool manualExtendPivotLines, bool manualShowPivotR3, bool manualShowPivotS3, bool manualShowVolumeMarkers, bool manualShowVolumeLabels) =>
    OverlayVisibility.new(profile.useVisibilityProfile ? true : manualShowEmaFast,
     profile.useVisibilityProfile ? true : manualShowEmaMedium,
     profile.useVisibilityProfile ? true : manualShowEmaSlow,
     profile.useVisibilityProfile ? profile.visMidOrHtf : manualShowPivotLines,
     profile.useVisibilityProfile ? profile.visMidOrHtf : manualShowPivotLabels,
     profile.useVisibilityProfile ? profile.visMidOrHtf : manualExtendPivotLines,
     profile.useVisibilityProfile ? profile.visMidOrHtf : manualShowPivotR3,
     profile.useVisibilityProfile ? profile.visMidOrHtf : manualShowPivotS3,
     profile.useVisibilityProfile ? profile.visIntraday : manualShowVolumeMarkers,
     profile.useVisibilityProfile ? false : manualShowVolumeLabels)

export resolvePanelVisibility(ProfileContext profile, bool manualCompactMtfPanel, bool manualShowMtfH4, bool manualShowMtfH1, bool manualShowMtfM15, bool manualShowMtfCurrentTf, bool manualCompactPanel, bool manualShowPanelStructure, bool manualShowPanelScore, bool manualShowPanelTradePlan, bool manualShowPanelVolume, bool manualShowTp3, bool manualShowPlanLabels, bool manualExtendPlanLines) =>
    PanelVisibility.new(profile.useVisibilityProfile ? true : manualCompactMtfPanel,
     profile.useVisibilityProfile ? profile.visIntraday : manualShowMtfH4,
     profile.useVisibilityProfile ? profile.visIntraday : manualShowMtfH1,
     profile.useVisibilityProfile ? profile.visIntraday : manualShowMtfM15,
     profile.useVisibilityProfile ? profile.visIntraday : manualShowMtfCurrentTf,
     profile.useVisibilityProfile ? true : manualCompactPanel,
     profile.useVisibilityProfile ? true : manualShowPanelStructure,
     profile.useVisibilityProfile ? true : manualShowPanelScore,
     profile.useVisibilityProfile ? false : manualShowPanelTradePlan,
     profile.useVisibilityProfile ? true : manualShowPanelVolume,
     profile.useVisibilityProfile ? false : manualShowTp3,
     profile.useVisibilityProfile ? false : manualShowPlanLabels,
     profile.useVisibilityProfile ? false : manualExtendPlanLines)

export resolveAuxiliaryVisibility(ProfileContext profile, bool manualShowUpperTrendline, bool manualShowLowerTrendline, bool manualTrendlineExtendRight, bool manualShowProfilePoc, bool manualShowProfileVahVal, bool manualShowProfileValueArea, bool manualShowProfileHistogram) =>
    AuxiliaryVisibility.new(profile.useVisibilityProfile ? profile.visMidOrHtf : manualShowUpperTrendline,
     profile.useVisibilityProfile ? profile.visMidOrHtf : manualShowLowerTrendline,
     profile.useVisibilityProfile ? profile.visMidOrHtf : manualTrendlineExtendRight,
     profile.useVisibilityProfile ? profile.visHtfOrHigher : manualShowProfilePoc,
     profile.useVisibilityProfile ? profile.visHtfOrHigher : manualShowProfileVahVal,
     profile.useVisibilityProfile ? profile.visHtfOrHigher : manualShowProfileValueArea,
     profile.useVisibilityProfile ? profile.visHtfOrHigher : manualShowProfileHistogram)
````
