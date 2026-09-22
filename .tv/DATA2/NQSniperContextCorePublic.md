<!-- tradingview-pine-id: PUB;bd7dd29d7d3a44e8a916fc75da97d867 -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# NQSniperContextCorePublic

Source: https://www.tradingview.com/script/4dyXV5r6-NQSniperPathCorePublic/

## Description

Library  "NQSniperPathCorePublic"
Public-safe NQ Sniper path/reaction utilities.
Generic state-machine helpers only: obstacle reaction, draw reaction,
ordered next-obstacle selection, and narrative text.
No proprietary candidate discovery, entry logic, scoring, stops, or automation.

obstacleReaction(enabled, delivery, pTop, pBottom, pMid, pType, oTop, oBottom, oMid, oType, oDelivery, oState, bullDisp, bearDisp)
  Updates the active obstacle-reaction state.
  Parameters:
    enabled (bool)
    delivery (int)
    pTop (float)
    pBottom (float)
    pMid (float)
    pType (string)
    oTop (float)
    oBottom (float)
    oMid (float)
    oType (string)
    oDelivery (int)
    oState (int)
    bullDisp (bool)
    bearDisp (bool)

drawReaction(enabled, delivery, selectedDraw, oldPrice, oldDelivery, oldState, bullDisp, bearDisp, mergePoints)
  Updates primary draw reaction state and lock lifecycle.
  Parameters:
    enabled (bool)
    delivery (int)
    selectedDraw (float)
    oldPrice (float)
    oldDelivery (int)
    oldState (int)
    bullDisp (bool)
    bearDisp (bool)
    mergePoints (simple float)

nextPathObstacle(delivery, currentMid, primaryDraw, c1, t1, c2, t2, mergePoints)
  Selects the next obstacle farther along the current path, never behind CURRENT or beyond PRIMARY.
  Parameters:
    delivery (int)
    currentMid (float)
    primaryDraw (float)
    c1 (float)
    t1 (string)
    c2 (float)
    t2 (string)
    mergePoints (simple float)

pathStateName(state)
  Converts path state to a compact diagnostic label.
  Parameters:
    state (int)

narrative(delivery, drawState, obstacleState, primaryPrice)
  Builds the generic narrative string used by the debugger.
delivery: 1 bullish, -1 bearish, 0 neutral.
  Parameters:
    delivery (int)
    drawState (int)
    obstacleState (int)
    primaryPrice (float)

---

## Source Code

````pine
//@version=6
library("NQSniperContextCorePublic", overlay=false)

// Public-safe classification helpers only.
// No proprietary candidate discovery, scoring, entries, exits, stops, or automation.

// Returns a role for an already-discovered active 5M order block.
export obRole(bool activeExists, bool invalid, bool touched, bool raidContext, bool displacementContext, bool mssContext) =>
    string role = "NONE"
    if activeExists
        role := invalid ? "INVALID" :
             raidContext and displacementContext and mssContext ? "RAID ORIGIN" :
             displacementContext and mssContext ? "DISPLACEMENT ORIGIN" :
             touched ? "REACTED" :
             "CONTINUATION"
    role

// Classifies interaction with an already-discovered Major S/R coordinate.
export srState(float currentClose, float previousClose, float currentHigh, float currentLow,
     float majorSR, float atrValue, float minTick) =>
    string state = "DISTANT"
    if not na(majorSR)
        float band = math.max(minTick * 4.0, atrValue * 0.20)
        bool testing = math.abs(currentClose - majorSR) <= band
        bool crossUp = currentClose > majorSR and previousClose <= majorSR
        bool crossDown = currentClose < majorSR and previousClose >= majorSR
        bool rejectedBelow = currentHigh >= majorSR - band and currentClose < majorSR - band
        bool rejectedAbove = currentLow <= majorSR + band and currentClose > majorSR + band
        state := testing ? "TESTING" :
             crossUp ? "ACCEPTED ABOVE" :
             crossDown ? "ACCEPTED BELOW" :
             rejectedBelow ? "REJECTED BELOW" :
             rejectedAbove ? "REJECTED ABOVE" :
             currentClose > majorSR ? "ABOVE" : "BELOW"
    state

// Rates how obstructed the route is from current price to the supplied primary draw.
export pathQuality(float currentClose, float primaryDraw, float currentObstacleMid, float nextObstacleMid) =>
    bool hasCurrent = not na(currentObstacleMid)
    bool hasNext = not na(nextObstacleMid)
    float drawDistance = na(primaryDraw) ? na : math.abs(primaryDraw - currentClose)
    float currentDistance = hasCurrent ? math.abs(currentObstacleMid - currentClose) : na
    bool compressed = hasCurrent and not na(drawDistance) and drawDistance > 0 and currentDistance / drawDistance < 0.33
    string quality = not hasCurrent ? "CLEAN" :
         hasCurrent and hasNext ? "CONGESTED" :
         compressed ? "CONGESTED" :
         "MODERATE"
    quality

// Rates location context from already-computed structural facts.
export locationQuality(bool hasLiquidityContext, bool hasValidStructure, bool nearMajorSR, bool hasConfirmation) =>
    string quality = hasLiquidityContext and hasValidStructure and hasConfirmation ? "STRONG" :
         (hasValidStructure and hasConfirmation) or (hasLiquidityContext and nearMajorSR) ? "GOOD" :
         hasValidStructure or hasLiquidityContext or nearMajorSR ? "DEVELOPING" :
         "WEAK"
    quality
````
