<!-- tradingview-pine-id: PUB;8318a7521fc44ad49d8ef805a240a8d7 -->
<!-- tradingviewscripts-format: 1 -->
# SMCNexusScoringCoreV2

Source: https://www.tradingview.com/script/YIos5MSE/

## Description

SMCNexusScoringCoreV2 is an open-source, non-visual Pine Script library that calculates a deterministic Smart Money Concepts evidence score from market facts supplied by an importing indicator.

The library does not independently read chart state, request other timeframes, generate trading signals, place orders or draw chart objects. Its purpose is to separate the scoring calculation from detection and presentation code, making every component reusable and independently auditable.

ORIGINAL CONCEPT AND PURPOSE

The library combines twelve bounded Smart Money Concepts evidence components into one normalized 0–100 result while retaining each individual component in the returned ScoreResult record.

It also provides optional event-age decay for selected structural evidence. This prevents an old BOS, CHoCH, MSS or liquidity sweep from retaining the same influence indefinitely.

The importing indicator is responsible for detecting and confirming market events. This library receives those facts through typed parameters and performs deterministic calculations only. It does not infer missing events or substitute unknown data.

CALCULATION METHOD

The twelve components are:

1. Market Structure Shift
2. Break of Structure
3. Change of Character
4. Fair Value Gap
5. Order Block
6. Liquidity context
7. Liquidity sweep
8. Premium or Discount location
9. Volume state
10. Momentum state
11. Local Smart Money context
12. Primary trend

Each component contributes a bounded value based on the supplied state. The component total is divided by twelve and normalized to a value from 0 to 100.

The resulting descriptive classes are:

• VERY WEAK  
• WEAK  
• NEUTRAL  
• STRONG  
• ELITE

These classes describe the supplied analytical evidence. They are not trading recommendations and do not predict future performance.

AGE DECAY

When age decay is enabled, the selected structural and sweep components use a linear age factor.

The factor:

• remains at 1.0 until the configured full-strength age,  
• decreases linearly between the full-strength and zero-strength ages,  
• reaches 0.0 at or beyond the configured zero-strength age.

If the supplied age window is invalid, the calculation fails safely to full strength instead of producing a negative or undefined weight.

PUBLIC API

ScoreResult

The returned record contains:

• all twelve effective components,  
• effective MSS age factor,  
• effective BOS/CHoCH age factor,  
• effective sweep age factor,  
• component total,  
• normalized score,  
• descriptive class,  
• compact text representation.

calculate(...)

This function accepts typed, confirmed market facts and returns one ScoreResult record.

INTENDED USE

An importing indicator should:

1. Detect and confirm its own market-structure events.
2. Determine its current FVG, Order Block, liquidity, volume, momentum and trend states.
3. Pass those facts to calculate().
4. Read the normalized result or inspect the individual returned components for a complete breakdown.

Conceptual example:

```pine
import AreXoN_/SMCNexusScoringCoreV2/1 as scoring

scoring.ScoreResult result = scoring.calculate(
    scoringEnabled,
    ageDecayEnabled,
    bar_index,
    lastMssBar,
    lastBreakBar,
    lastSweepBar,
    structureFullStrengthBars,
    structureZeroStrengthBars,
    sweepFullStrengthBars,
    sweepZeroStrengthBars,
    mssDirection,
    breakType,
    breakDirection,
    fvgType,
    fvgMitigated,
    obType,
    obMitigated,
    liquidityContext,
    sweepType,
    premiumDiscountZone,
    volumeState,
    momentumState,
    smartMoneyState,
    primaryTrendState)
```

The example import path should be replaced with the exact path assigned by TradingView after publication.

WHY THE CHART IS CLEAN

This is a non-visual calculation library. It intentionally creates no plots, labels, tables, lines or boxes. Visual output is the responsibility of an importing indicator.

The publication chart is therefore intentionally clean and contains no additional indicators or unexplained drawings.

LIMITATIONS

• Output quality depends on the facts supplied by the importing indicator.  
• The library does not independently verify market events.  
• It does not provide native bid/ask order flow or broker execution data.  
• It does not account for spread, slippage or broker restrictions.  
• It does not place, modify or close orders.  
• It produces no chart output by itself.  
• A score or class is not a guarantee of future market behavior.

This library is an analytical and software-development component. It is not investment advice or an automated trading system.

---

## Source Code

````pine
//@version=6
library("SMCNexusScoringCoreV2", overlay = true)

// Open-source non-visual calculation library. See docs/TRADINGVIEW_LIBRARY_REPUBLICATION.md.
// It contains only the accepted M13/M31 scoring calculation. All live market
// state is supplied by the importing indicator through typed parameters.

export type ScoreResult
    float mssComponent
    float bosComponent
    float chochComponent
    float fvgComponent
    float obComponent
    float liquidityComponent
    float sweepComponent
    float premiumDiscountComponent
    float volumeComponent
    float momentumComponent
    float smartMoneyContextComponent
    float primaryTrendComponent
    float mssEffectiveFactor
    float breakEffectiveFactor
    float sweepEffectiveFactor
    float componentTotal
    int score
    string className
    string barText

ageDecayFactor(int currentBarIndex, int eventBarIndex, int fullStrengthBars, int zeroStrengthBars) =>
    float factor = 0.0
    if not na(eventBarIndex)
        int eventAge = math.max(0, currentBarIndex - eventBarIndex)
        factor := zeroStrengthBars <= fullStrengthBars ? 1.0 : eventAge <= fullStrengthBars ? 1.0 : eventAge >= zeroStrengthBars ? 0.0 : 1.0 - float(eventAge - fullStrengthBars) / float(zeroStrengthBars - fullStrengthBars)
    factor

localSmartMoneyComponent(string mssDirection, string breakType, string breakDirection, string fvgType, string obType, string sweepType, float mssFactor, float breakFactor, float sweepFactor) =>
    float localValue = (mssDirection == "bullish" ? 2.0 : mssDirection == "bearish" ? -2.0 : 0.0) * mssFactor
    localValue += (breakDirection == "up" ? 1.0 : breakDirection == "down" ? -1.0 : 0.0) * breakFactor
    localValue += (breakType == "CHoCH" and breakDirection == "up" ? 1.0 : breakType == "CHoCH" and breakDirection == "down" ? -1.0 : 0.0) * breakFactor
    localValue += fvgType == "B-FVG" ? 1.0 : fvgType == "S-FVG" ? -1.0 : 0.0
    localValue += obType == "B-OB" ? 1.0 : obType == "S-OB" ? -1.0 : 0.0
    localValue += (sweepType == "SSL SWEEP" ? 1.0 : sweepType == "BSL SWEEP" ? -1.0 : 0.0) * sweepFactor
    localValue >= 4.0 or localValue <= -4.0 ? 1.0 : localValue != 0.0 ? 0.5 : 0.0

export calculate(bool enabled, bool ageDecayEnabled, int currentBarIndex, int mssEventBarIndex, int breakEventBarIndex, int sweepEventBarIndex, int structureFullStrengthBars, int structureZeroStrengthBars, int sweepFullStrengthBars, int sweepZeroStrengthBars, string mssDirection, string breakType, string breakDirection, string fvgType, bool fvgMitigated, string obType, bool obMitigated, string liquidityContext, string sweepType, string premiumDiscountZone, string volumeState, string momentumState, string smartMoneyState, string primaryTrendState) =>
    float mssAgeFactor = ageDecayFactor(currentBarIndex, mssEventBarIndex, structureFullStrengthBars, structureZeroStrengthBars)
    float breakAgeFactor = ageDecayFactor(currentBarIndex, breakEventBarIndex, structureFullStrengthBars, structureZeroStrengthBars)
    float sweepAgeFactor = ageDecayFactor(currentBarIndex, sweepEventBarIndex, sweepFullStrengthBars, sweepZeroStrengthBars)
    float mssEffectiveFactor = ageDecayEnabled ? mssAgeFactor : 1.0
    float breakEffectiveFactor = ageDecayEnabled ? breakAgeFactor : 1.0
    float sweepEffectiveFactor = ageDecayEnabled ? sweepAgeFactor : 1.0

    float mssBaseComponent = enabled ? (mssDirection == "bullish" or mssDirection == "bearish" ? 1.0 : 0.0) : na
    float bosBaseComponent = enabled ? (breakType == "BOS" ? 1.0 : 0.0) : na
    float chochBaseComponent = enabled ? (breakType == "CHoCH" ? 0.5 : 0.0) : na
    float mssComponent = enabled ? mssBaseComponent * mssEffectiveFactor : na
    float bosComponent = enabled ? bosBaseComponent * breakEffectiveFactor : na
    float chochComponent = enabled ? chochBaseComponent * breakEffectiveFactor : na
    float fvgComponent = enabled ? (fvgType == "B-FVG" or fvgType == "S-FVG" ? (fvgMitigated ? 0.5 : 1.0) : 0.0) : na
    float obComponent = enabled ? (obType == "B-OB" or obType == "S-OB" ? (obMitigated ? 0.5 : 1.0) : 0.0) : na
    float liquidityComponent = enabled ? (liquidityContext == "NO CLEAR LIQUIDITY" ? 0.0 : liquidityContext == "AFTER SWEEP" ? 0.5 : 1.0) : na
    float sweepBaseComponent = enabled ? (sweepType == "BSL SWEEP" or sweepType == "SSL SWEEP" ? 1.0 : 0.0) : na
    float sweepComponent = enabled ? sweepBaseComponent * sweepEffectiveFactor : na
    float premiumDiscountComponent = enabled ? (premiumDiscountZone == "PREMIUM" or premiumDiscountZone == "DISCOUNT" ? 1.0 : premiumDiscountZone == "EQUILIBRIUM" ? 0.5 : 0.0) : na
    float volumeComponent = enabled ? (volumeState == "CONFIRMED" ? 1.0 : volumeState == "WEAK" ? 0.5 : 0.0) : na
    float momentumComponent = enabled ? (momentumState == "IMPULSIVE" ? 1.0 : momentumState == "CORRECTIVE" ? 0.5 : 0.0) : na
    float smartMoneyContextBaseComponent = enabled ? (smartMoneyState == "STRONG BULLISH" or smartMoneyState == "STRONG BEARISH" ? 1.0 : smartMoneyState == "BULLISH" or smartMoneyState == "BEARISH" ? 0.5 : 0.0) : na
    float smartMoneyContextDecayedComponent = enabled ? localSmartMoneyComponent(mssDirection, breakType, breakDirection, fvgType, obType, sweepType, mssEffectiveFactor, breakEffectiveFactor, sweepEffectiveFactor) : na
    float smartMoneyContextComponent = enabled ? (ageDecayEnabled ? smartMoneyContextDecayedComponent : smartMoneyContextBaseComponent) : na
    float primaryTrendComponent = enabled ? (primaryTrendState == "STRONG BUY" or primaryTrendState == "STRONG SELL" ? 1.0 : primaryTrendState == "BUY" or primaryTrendState == "SELL" ? 0.5 : 0.0) : na

    float componentTotal = enabled ? mssComponent + bosComponent + chochComponent + fvgComponent + obComponent + liquidityComponent + sweepComponent + premiumDiscountComponent + volumeComponent + momentumComponent + smartMoneyContextComponent + primaryTrendComponent : na
    int score = enabled ? math.round(componentTotal / 12.0 * 100.0) : na
    string className = not enabled ? "DISABLED" : score <= 20 ? "VERY WEAK" : score <= 40 ? "WEAK" : score <= 60 ? "NEUTRAL" : score <= 80 ? "STRONG" : "ELITE"
    string barText = not enabled ? "" : score <= 20 ? "##--------" : score <= 40 ? "####------" : score <= 60 ? "######----" : score <= 80 ? "########--" : "##########"

    ScoreResult.new(mssComponent, bosComponent, chochComponent, fvgComponent, obComponent, liquidityComponent, sweepComponent, premiumDiscountComponent, volumeComponent, momentumComponent, smartMoneyContextComponent, primaryTrendComponent, mssEffectiveFactor, breakEffectiveFactor, sweepEffectiveFactor, componentTotal, score, className, barText)
````
