<!-- tradingview-pine-id: PUB;e0fdfd2ba7a4487188069bff74eb4fcb -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# NQSniperLiquidityCorePublic

Source: https://www.tradingview.com/script/ecaEwj8t-NQSniperLiquidityCorePublic/

## Description

Library  "NQSniperLiquidityCorePublic"

duplicateActive(price, prices, active, tolerance)
  Parameters:
    price (float)
    prices (array<float>)
    active (array<bool>)
    tolerance (float)

hasActive(active)
  Parameters:
    active (array<bool>)

nearestBelow(price, prices, active)
  Parameters:
    price (float)
    prices (array<float>)
    active (array<bool>)

nearestAbove(price, prices, active)
  Parameters:
    price (float)
    prices (array<float>)
    active (array<bool>)

clearRegistry(regPrice, regSide, regCount, regClass, regSources)
  Parameters:
    regPrice (array<float>)
    regSide (array<int>)
    regCount (array<int>)
    regClass (array<int>)
    regSources (array<string>)

addRegistry(enabled, px, side, sourceName, kind, mergePoints, maxClusters, regPrice, regSide, regCount, regClass, regSources)
  Parameters:
    enabled (bool)
    px (float)
    side (int)
    sourceName (string)
    kind (string)
    mergePoints (float)
    maxClusters (int)
    regPrice (array<float>)
    regSide (array<int>)
    regCount (array<int>)
    regClass (array<int>)
    regSources (array<string>)

selectDrawCandidates(delivery, currentPrice, maxDistance, mergePoints, regPrice, regSide, regClass, regSources)
  Parameters:
    delivery (int)
    currentPrice (float)
    maxDistance (float)
    mergePoints (float)
    regPrice (array<float>)
    regSide (array<int>)
    regClass (array<int>)
    regSources (array<string>)

---

## Source Code

````pine
//@version=6
library("NQSniperLiquidityCorePublic", overlay=false)

// Public-safe generic liquidity memory helpers.
// No proprietary setup scoring, entries, exits, stops, targets, or automation.

f_class(string kind) =>
    kind == "EXTERNAL" ? 4 : kind == "SESSION" ? 3 : kind == "EQ" ? 2 : kind == "MAJOR" ? 1 : 0

export duplicateActive(float price, array<float> prices, array<bool> active, float tolerance) =>
    bool duplicate = false
    if array.size(prices) > 0
        for i = 0 to array.size(prices)-1
            if array.get(active,i) and math.abs(array.get(prices,i)-price) <= tolerance
                duplicate := true
    duplicate

export hasActive(array<bool> active) =>
    bool found = false
    if array.size(active) > 0
        for i = 0 to array.size(active)-1
            if array.get(active,i)
                found := true
    found

export nearestBelow(float price, array<float> prices, array<bool> active) =>
    float result = na
    if array.size(prices) > 0
        for i = 0 to array.size(prices)-1
            float level = array.get(prices,i)
            if array.get(active,i) and level < price and (na(result) or level > result)
                result := level
    result

export nearestAbove(float price, array<float> prices, array<bool> active) =>
    float result = na
    if array.size(prices) > 0
        for i = 0 to array.size(prices)-1
            float level = array.get(prices,i)
            if array.get(active,i) and level > price and (na(result) or level < result)
                result := level
    result

export clearRegistry(array<float> regPrice, array<int> regSide, array<int> regCount, array<int> regClass, array<string> regSources) =>
    array.clear(regPrice)
    array.clear(regSide)
    array.clear(regCount)
    array.clear(regClass)
    array.clear(regSources)

export addRegistry(bool enabled, float px, int side, string sourceName, string kind,
     float mergePoints, int maxClusters,
     array<float> regPrice, array<int> regSide, array<int> regCount, array<int> regClass, array<string> regSources) =>
    if enabled and not na(px)
        int best = -1
        float bestD = 1e10
        if array.size(regPrice) > 0
            for i = 0 to array.size(regPrice)-1
                float d = math.abs(array.get(regPrice,i)-px)
                if d <= mergePoints and d < bestD
                    bestD := d
                    best := i
        int cls = f_class(kind)
        if best == -1
            if array.size(regPrice) < maxClusters
                array.push(regPrice,px)
                array.push(regSide,side)
                array.push(regCount,1)
                array.push(regClass,cls)
                array.push(regSources,sourceName)
        else
            int oldCls = array.get(regClass,best)
            if cls > oldCls
                array.set(regPrice,best,px)
            int oldSide = array.get(regSide,best)
            int mergedSide = oldSide == 0 ? side : side == 0 ? oldSide : oldSide == side ? oldSide : 0
            array.set(regSide,best,mergedSide)
            array.set(regCount,best,array.get(regCount,best)+1)
            array.set(regClass,best,math.max(oldCls,cls))
            string src = array.get(regSources,best)
            if not str.contains(src,sourceName)
                array.set(regSources,best,src + " + " + sourceName)

export selectDrawCandidates(int delivery, float currentPrice, float maxDistance, float mergePoints,
     array<float> regPrice, array<int> regSide, array<int> regClass, array<string> regSources) =>
    float p1 = na
    float p2 = na
    string s1 = "NONE"
    string s2 = "NONE"
    float d1 = 1e10
    float d2 = 1e10
    if delivery != 0 and array.size(regPrice) > 0
        for i = 0 to array.size(regPrice)-1
            float px = array.get(regPrice,i)
            int side = array.get(regSide,i)
            int cls = array.get(regClass,i)
            float d = math.abs(px-currentPrice)
            bool directionOK = delivery == 1 ? (px > currentPrice and side >= 0) : (px < currentPrice and side <= 0)
            if directionOK and cls >= 2 and d <= maxDistance and d < d1
                d1 := d
                p1 := px
                s1 := array.get(regSources,i)

        if not na(p1)
            for i = 0 to array.size(regPrice)-1
                float px = array.get(regPrice,i)
                int side = array.get(regSide,i)
                int cls = array.get(regClass,i)
                float d = math.abs(px-currentPrice)
                bool beyondPrimary = delivery == 1 ? px > p1 + mergePoints : px < p1 - mergePoints
                bool directionOK = delivery == 1 ? side >= 0 : side <= 0
                if directionOK and beyondPrimary and cls >= 2 and d <= maxDistance and d < d2
                    d2 := d
                    p2 := px
                    s2 := array.get(regSources,i)

        if na(p1)
            for i = 0 to array.size(regPrice)-1
                float px = array.get(regPrice,i)
                int cls = array.get(regClass,i)
                float d = math.abs(px-currentPrice)
                bool directionOK = delivery == 1 ? px > currentPrice : px < currentPrice
                if directionOK and cls == 1 and d <= maxDistance and d < d1
                    d1 := d
                    p1 := px
                    s1 := "STRUCTURAL FALLBACK: " + array.get(regSources,i)

        if not na(p1) and na(p2)
            for i = 0 to array.size(regPrice)-1
                float px = array.get(regPrice,i)
                int cls = array.get(regClass,i)
                float d = math.abs(px-currentPrice)
                bool beyondPrimary = delivery == 1 ? px > p1 + mergePoints : px < p1 - mergePoints
                if beyondPrimary and cls == 1 and d <= maxDistance and d < d2
                    d2 := d
                    p2 := px
                    s2 := "NEXT MAJOR: " + array.get(regSources,i)
    [p1,s1,p2,s2]
````
