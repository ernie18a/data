# Gate Levels (S/R Zones)

- url: https://www.tradingview.com/script/QfO9AQ8f-Gate-Levels-S-R-Zones/
- type: indicator
- pine_id: PUB;42232b98ff084485ba9b4fce7c729c0a
- version: 1.0

## Description

Gate Levels (S/R Zones) — True Swing-Pivot Zones

OVERVIEW
This indicator draws dynamic support and resistance bands from real swing pivots in price. It walks the chart with a percentage zigzag, saves every significant reversal origin, clusters nearby pivots into zones, ranks them by recency-weighted swing force, and extends the strongest + nearest-to-price levels as horizontal bands across the entire chart.


HOW IT WORKS

1. Percent zigzag swing detection
The script scans the last N bars and builds alternating up/down legs. A leg continues until price gives back a configurable percentage against the running extreme. When that happens:
   - the completed leg's origin is saved as a candidate pivot
   - a new opposite-direction leg is seeded from the extreme
This produces a clean sequence of true swing lows (up-leg origins) and true swing highs (down-leg origins), where each pivot is validated by an actual X% opposing move.

2. Provisional running pivot
The still-open leg's current extreme is also added as a candidate. This keeps the nearest developing level alive even before the swing fully matures.

3. Recency decay
Every pivot starts with a raw score equal to the size of the move that created it (in percent). That score is then decayed by the bar's age:
   decayed_score = raw_score * decayBase ^ (bars_ago / 365.25)
The default base is 0.85, normalized to ~365 bars of the active timeframe. Recent swings outrank old ones, so the zones stay relevant to current market structure instead of being dominated by ancient history.

4. Clustering into zones
Pivots are sorted by price and merged when one lies within the Cluster merge % of the previous cluster's midpoint. The merged midpoint becomes a running average of the clustered pivots. Each zone tracks its high/low extremes, total decayed score, and number of touches.

5. Filtering and ranking
Zones with fewer than Min touches per zone are discarded. Remaining zones are ranked by total decayed score, and the top Top-ranked zones are selected.

6. Nearest-to-price guarantee
Even if the highest-score zones are far away, the script also forces the 2 nearest zones above price and the 2 nearest zones below price into the visible set. This ensures you always see the levels actually in play around current price.

7. Band drawing
Each selected zone is drawn as three horizontal lines (top, midpoint, bottom) that extend infinitely left and right. The midpoint is dashed; the upper/lower borders define the zone thickness.
   - Zones above current price are tinted red (resistance)
   - Zones below current price are tinted green (support)

TIMEFRAME HANDLING
 A fixed 7% swing threshold produces almost nothing on low timeframes and too few levels on very high timeframes. To solve this, the script includes ATR-scaled swing mode (on by default):
   effective_swing_pct = ATR(14) / close * 100 * ATR multiplier
Because ATR naturally scales with timeframe and volatility, the indicator produces meaningful zones on 15m, 1H, 4H, daily, and weekly charts without retuning.

INPUTS
Lookback bars          : How many bars to scan for swing pivots. Limited to 500 by Pine's loop cap.
Fixed swing zigzag %   : Manual swing threshold when ATR scaling is off.
Use ATR-scaled swing % : Auto-scale the threshold by volatility/timeframe.
ATR multiplier         : Multiplier applied to the ATR%-of-price reading.
Cluster merge %        : Maximum distance between two pivots to merge into the same zone.
Band thickness %       : Half-thickness of each drawn band, as % of the zone midpoint.
Min touches per zone   : Minimum clustered pivots before a zone is valid.
Top-ranked zones       : How many top-scored zones to keep.
Recency decay base     : Decay factor; higher = older pivots matter more.

HOW TO USE
1. Add the indicator to any chart.
2. Set the timeframe to the one you trade.
3. If no levels appear:
   - lower ATR multiplier for smaller/more frequent levels
   - lower Min touches per zone to 1
   - increase Lookback bars to 500
4. Strong, widely-separated zones are high-probability S/R.
5. The nearest zones above and below current price are the most immediately relevant.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © The_Universe_Told_Me_So_GROWTH

//@version=6
indicator("Gate Levels (S/R Zones)", overlay=true, max_lines_count=500)

lookback  = input.int(500,   "Lookback bars",          minval=100, maxval=500)
swingPct  = input.float(7.0, "Fixed swing zigzag %",   minval=0.1, step=0.5)
useAtr    = input.bool(true,  "Use ATR-scaled swing % (recommended)")
atrMult   = input.float(2.5,  "ATR multiplier",       minval=0.1, step=0.1)
clusterPct= input.float(2.0,  "Cluster merge %",        minval=0.1, step=0.1)
zonePct   = input.float(0.65, "Band thickness %",       minval=0.05, step=0.05)
minHits   = input.int(2,     "Min touches per zone",   minval=1)
topN      = input.int(8,     "Top-ranked zones",       minval=1)
decayBase = input.float(0.85,"Recency decay base",     minval=0.0, maxval=1.0, step=0.01)

var line[] lines = array.new_line(0)
decay(idx, total) => math.pow(decayBase, (total - 1 - idx) / 365.25)

effSwing() =>
    useAtr ? ta.atr(14) / close * 100.0 * atrMult : swingPct

if barstate.islast
    for old in lines
        line.delete(old)
    array.clear(lines)

    n = lookback
    highs = array.new_float(n)
    lows  = array.new_float(n)
    for i = 0 to n - 1
        array.set(highs, i, high[n - 1 - i])
        array.set(lows,  i, low[n - 1 - i])

    pct = effSwing() / 100.0

    pivPx  = array.new_float(0)
    pivIdx = array.new_int(0)
    pivRaw = array.new_float(0)

    var int   d      = 0
    var int   org_i  = 0
    var float org    = 0.0
    var int   ext_i  = 0
    var float ext    = 0.0
    var int   hi_i   = 0
    var float hi_run = array.get(highs, 0)
    var int   lo_i   = 0
    var float lo_run = array.get(lows,  0)

    for j = 1 to n - 1
        float hj = array.get(highs, j)
        float lj = array.get(lows,  j)

        if d > 0
            if lj <= ext * (1.0 - pct)
                array.push(pivPx,  org)
                array.push(pivIdx, org_i)
                array.push(pivRaw, math.abs(ext / org - 1.0) * 100.0)
                if hj > ext
                    org_i := j
                    org   := hj
                else
                    org_i := ext_i
                    org   := ext
                ext_i := j
                ext   := lj
                d     := -1
            else if hj > ext
                ext_i := j
                ext   := hj

        else if d < 0
            if hj >= ext * (1.0 + pct)
                array.push(pivPx,  org)
                array.push(pivIdx, org_i)
                array.push(pivRaw, math.abs(ext / org - 1.0) * 100.0)
                if lj < ext
                    org_i := j
                    org   := lj
                else
                    org_i := ext_i
                    org   := ext
                ext_i := j
                ext   := hj
                d     := 1
            else if lj < ext
                ext_i := j
                ext   := lj

        else
            if lj < lo_run
                lo_i   := j
                lo_run := lj
            if hj > hi_run
                hi_i   := j
                hi_run := hj
            if hj >= lo_run * (1.0 + pct)
                org_i := lo_i
                org   := lo_run
                ext_i := j
                ext   := hj
                d     := 1
            else if lj <= hi_run * (1.0 - pct)
                org_i := hi_i
                org   := hi_run
                ext_i := j
                ext   := lj
                d     := -1

    if d != 0
        array.push(pivPx,  ext)
        array.push(pivIdx, ext_i)
        array.push(pivRaw, math.abs(ext / org - 1.0) * 100.0)

    int np = array.size(pivPx)
    if np > 0
        pivForce = array.new_float(np)
        for i = 0 to np - 1
            array.set(pivForce, i, array.get(pivRaw, i) * decay(array.get(pivIdx, i), n))

        if np > 1
            for i = 0 to np - 2
                for k = i + 1 to np - 1
                    if array.get(pivPx, i) > array.get(pivPx, k)
                        tmpPx = array.get(pivPx, i)
                        array.set(pivPx, i, array.get(pivPx, k))
                        array.set(pivPx, k, tmpPx)

                        tmpF = array.get(pivForce, i)
                        array.set(pivForce, i, array.get(pivForce, k))
                        array.set(pivForce, k, tmpF)

        zMid   = array.new_float(0)
        zHi    = array.new_float(0)
        zLo    = array.new_float(0)
        zScore = array.new_float(0)
        zN     = array.new_int(0)
        cl = clusterPct / 100.0

        for i = 0 to np - 1
            float px = array.get(pivPx, i)
            float f  = array.get(pivForce, i)
            int nz = array.size(zMid)

            if nz > 0
                float mid = array.get(zMid, nz - 1)
                if px - mid <= cl * px
                    int nn = array.get(zN, nz - 1)
                    array.set(zMid,   nz - 1, (mid * nn + px) / (nn + 1))
                    array.set(zHi,    nz - 1, math.max(array.get(zHi, nz - 1), px))
                    array.set(zLo,    nz - 1, math.min(array.get(zLo, nz - 1), px))
                    array.set(zScore, nz - 1, array.get(zScore, nz - 1) + f)
                    array.set(zN,     nz - 1, nn + 1)
                else
                    array.push(zMid,   px)
                    array.push(zHi,    px)
                    array.push(zLo,    px)
                    array.push(zScore, f)
                    array.push(zN,     1)
            else
                array.push(zMid,   px)
                array.push(zHi,    px)
                array.push(zLo,    px)
                array.push(zScore, f)
                array.push(zN,     1)

        kMid   = array.new_float(0)
        kScore = array.new_float(0)
        int nzones = array.size(zMid)
        if nzones > 0
            for i = 0 to nzones - 1
                if array.get(zN, i) >= minHits
                    array.push(kMid,   array.get(zMid, i))
                    array.push(kScore, array.get(zScore, i))

        int nk = array.size(kMid)
        if nk > 0
            if nk > 1
                for i = 0 to nk - 2
                    for j = i + 1 to nk - 1
                        if array.get(kScore, i) < array.get(kScore, j)
                            tmpMid = array.get(kMid, i)
                            array.set(kMid, i, array.get(kMid, j))
                            array.set(kMid, j, tmpMid)

                            tmpSc = array.get(kScore, i)
                            array.set(kScore, i, array.get(kScore, j))
                            array.set(kScore, j, tmpSc)

            bool[] picked = array.new_bool(nk, false)
            int take = int(math.min(nk, topN))
            if take > 0
                for i = 0 to take - 1
                    array.set(picked, i, true)

            float lastPx = close

            if nk > 0
                for rep = 0 to 1
                    float bestA = na
                    int   bestI = -1
                    for i = 0 to nk - 1
                        float mid = array.get(kMid, i)
                        if mid > lastPx and not array.get(picked, i) and (na(bestA) or mid < bestA)
                            bestA := mid
                            bestI := i
                    if bestI >= 0
                        array.set(picked, bestI, true)

                for rep = 0 to 1
                    float bestB = na
                    int   bestI = -1
                    for i = 0 to nk - 1
                        float mid = array.get(kMid, i)
                        if mid <= lastPx and not array.get(picked, i) and (na(bestB) or mid > bestB)
                            bestB := mid
                            bestI := i
                    if bestI >= 0
                        array.set(picked, bestI, true)

                for i = 0 to nk - 1
                    if array.get(picked, i)
                        float mid  = array.get(kMid, i)
                        float half = zonePct / 200.0 * mid
                        float top  = mid + half
                        float bot  = mid - half
                        color c    = mid > lastPx ? color.new(color.red, 70) : color.new(color.green, 70)

                        line lTop = line.new(bar_index, top, bar_index + 1, top,
                                             color=c, width=1, extend=extend.both)
                        line lBot = line.new(bar_index, bot, bar_index + 1, bot,
                                             color=c, width=1, extend=extend.both)
                        line lMid = line.new(bar_index, mid, bar_index + 1, mid,
                                             color=c, width=2, style=line.style_dashed, extend=extend.both)
                        array.push(lines, lTop)
                        array.push(lines, lBot)
                        array.push(lines, lMid)
````
