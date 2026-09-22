<!-- tradingview-pine-id: PUB;1ec8b3007e1a43f39f76c9e83494bec7 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# NQSniperDeliveryCore

Source: https://www.tradingview.com/script/u8X31M4g-NQSniperDeliveryCore/

## Description

Library  "NQSniperDeliveryCore"
NQ Sniper Delivery / Structural Bias core.
Stable market-intelligence module extracted from the V8.8.140F/G branch.
This library has no chart drawings, no entries, no stops, and no automation.

evaluate(marketBias, bullBiasScore, bearBiasScore, trendState, bullDisp, bearDisp, bullCHoCH, bearCHoCH, bullBOS, bearBOS, c0, c1, c2, lastStructureLow, lastStructureHigh)
  Evaluates the structural bias and active 5M delivery state.
  Parameters:
    marketBias (int): Higher-level bias from the main NQ Sniper engine: 1 bull, -1 bear, 0 neutral.
    bullBiasScore (float): Existing bullish bias score.
    bearBiasScore (float): Existing bearish bias score.
    trendState (int): Existing 5M trend state: 1 bull, -1 bear, 0 neutral.
    bullDisp (bool): Bullish displacement event.
    bearDisp (bool): Bearish displacement event.
    bullCHoCH (bool): Bullish change-of-character event.
    bearCHoCH (bool): Bearish change-of-character event.
    bullBOS (bool): Bullish break-of-structure event.
    bearBOS (bool): Bearish break-of-structure event.
    c0 (float): Current 5M close.
    c1 (float): Previous 5M close.
    c2 (float): Close two 5M bars ago.
    lastStructureLow (float): Most recent protected / structural low.
    lastStructureHigh (float): Most recent protected / structural high.
  Returns: [structuralBias, activeDeliveryLabel]

---

## Source Code

````pine
//@version=6
// @description NQ Sniper Delivery / Structural Bias core.
// Stable market-intelligence module extracted from the V8.8.140F/G branch.
// This library has no chart drawings, no entries, no stops, and no automation.
library("NQSniperDeliveryCore", overlay=false)

// @function Evaluates the structural bias and active 5M delivery state.
// @param marketBias Higher-level bias from the main NQ Sniper engine: 1 bull, -1 bear, 0 neutral.
// @param bullBiasScore Existing bullish bias score.
// @param bearBiasScore Existing bearish bias score.
// @param trendState Existing 5M trend state: 1 bull, -1 bear, 0 neutral.
// @param bullDisp Bullish displacement event.
// @param bearDisp Bearish displacement event.
// @param bullCHoCH Bullish change-of-character event.
// @param bearCHoCH Bearish change-of-character event.
// @param bullBOS Bullish break-of-structure event.
// @param bearBOS Bearish break-of-structure event.
// @param c0 Current 5M close.
// @param c1 Previous 5M close.
// @param c2 Close two 5M bars ago.
// @param lastStructureLow Most recent protected / structural low.
// @param lastStructureHigh Most recent protected / structural high.
// @returns [structuralBias, activeDeliveryLabel]
export evaluate(
    series int marketBias,
    series float bullBiasScore,
    series float bearBiasScore,
    series int trendState,
    series bool bullDisp,
    series bool bearDisp,
    series bool bullCHoCH,
    series bool bearCHoCH,
    series bool bullBOS,
    series bool bearBOS,
    series float c0,
    series float c1,
    series float c2,
    series float lastStructureLow,
    series float lastStructureHigh) =>

    bool bullBiasInvalid = marketBias == 1 and trendState == -1 and
         (bearDisp or bearBOS or c0 < nz(lastStructureLow, c0))

    bool bearBiasInvalid = marketBias == -1 and trendState == 1 and
         (bullDisp or bullBOS or c0 > nz(lastStructureHigh, c0))

    int structuralBias =
         bullBiasInvalid ? (bearBiasScore >= bullBiasScore ? -1 : 0) :
         bearBiasInvalid ? (bullBiasScore >= bearBiasScore ? 1 : 0) :
         marketBias

    bool up = bullDisp or bullCHoCH or bullBOS or (c0 > c1 and c1 >= c2)
    bool dn = bearDisp or bearCHoCH or bearBOS or (c0 < c1 and c1 <= c2)

    string activeDelivery =
         structuralBias == 1 ?
             (dn ? ((bearCHoCH or bearBOS) ? "BEARISH DELIVERY" : "BEARISH RETRACEMENT") :
              up ? "BULLISH DELIVERY" : "TRANSITION") :
         structuralBias == -1 ?
             (up ? ((bullCHoCH or bullBOS) ? "BULLISH DELIVERY" : "BULLISH RETRACEMENT") :
              dn ? "BEARISH DELIVERY" : "TRANSITION") :
         up and not dn ? "BULLISH DELIVERY" :
         dn and not up ? "BEARISH DELIVERY" :
         "RANGE / NEUTRAL"

    [structuralBias, activeDelivery]
````
