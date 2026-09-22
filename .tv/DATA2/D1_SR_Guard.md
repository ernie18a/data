<!-- tradingview-pine-id: PUB;c55121eb86584b80bca2bf5a81717111 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# D1 S/R Guard

Source: https://www.tradingview.com/script/9HsDUedO-D1-Support-Resistance-Guard/

## Description

D1 S/R GUARD — HIGHER-TIMEFRAME ZONES WITH AN R-BASED ENTRY FILTER

Most support/resistance indicators draw lines. The problem is that by the time you are focused on a 5-minute entry trigger, you are no longer looking at the daily chart — and lines on a busy intraday chart become wallpaper. You end up entering three ticks under a level that has rejected price four times in the last year, and the trade turns against you immediately.

This script does two things about that. It builds daily support and resistance zones ranked by how many times price actually reacted at them, and it converts the distance to the nearest opposing level into R — multiples of your own stop size — so the question stops being the vague "am I near a level?" and becomes the concrete "does this trade have room to pay?"

WHAT IT PLOTS

- Clustered higher-timeframe S/R zones, drawn as boxes, labelled with a touch count
- Prior day high, low and close
- Prior week high and low
- Daily 50, 100 and 200 simple moving averages
- A dashboard showing the nearest level above and below price, the distance to each in price and in R, and a clear LONG / SHORT verdict

HOW THE ZONES ARE BUILT

Step 1 — Pivot detection. The script scans a rolling window of closed higher-timeframe bars (250 by default, roughly a year of daily data) and marks every swing high and swing low. Pivot strength is adjustable: a pivot high at strength 3 must be the highest of its own bar plus the three bars either side of it.

Step 2 — Clustering. Raw pivots are noisy and rarely land on exactly the same price twice. Any pivots falling within a tolerance of each other — expressed as a fraction of higher-timeframe ATR, so it scales across instruments and volatility regimes — are merged into a single zone. Each merge increments that zone's touch count and widens its boundaries to span the pivots inside it. The result is a zone with a real reaction history rather than a line through one arbitrary wick.

Step 3 — Ranking. Zones are scored on touch count plus a recency bonus, so a level that was defended four times including recently outranks one that was defended four times two years ago. Only the highest-scoring zones within a configurable distance of current price are drawn, which keeps the chart readable.

Step 4 — Filtering. A minimum touch threshold (default 2) discards one-off swings entirely.

THE ENTRY GUARD

This is the part that does the work. On every bar the script identifies the near edge of the closest level above price and the closest level below price, drawing from both the clustered zones and the discrete key levels. It then evaluates three blocking conditions:

1. Price is currently inside a zone.
2. The nearest opposing level is inside the danger band — a hard proximity threshold set as a fraction of higher-timeframe ATR.
3. There is less than a minimum number of R between price and that level.

The third condition is the useful one. You supply your stop size, either as a multiple of intraday ATR or as a fixed number of points, and the script divides the distance to the nearest level by it. If your stop is 1R and the nearest resistance is 0.8R above, that long cannot pay even if your read on direction is correct — the level will cap you before your target. The dashboard reports this as a number rather than a feeling.

When a direction is blocked, the dashboard cell turns red and reads STAND DOWN. The background can optionally tint. Alerts fire on the transition into and out of a blocked state, so you can be warned before you are staring at a setup rather than after.

Important: a blocked reading is not a signal to trade the other way. It means this particular entry, at this particular price, does not have the runway to justify the risk. Waiting for a better price or a break of the level are both valid responses.

DAILY MOVING AVERAGES

The 50, 100 and 200 daily SMAs are included as levels and feed the guard on equal footing with everything else. They are pulled as last-closed daily values, so they hold flat through the session instead of drifting as the current day's close moves — which is the correct behaviour for a level you intend to trade against.

They behave differently from pivot zones in one respect worth understanding. Pivot zones carry a touch history; the moving averages do not, so they are judged purely on distance. A rising 50 SMA that price is grinding above during a trend day will therefore block longs repeatedly. If that is too restrictive for how you trade, either narrow the danger band or switch the 50 off and keep the 100 and 200, which tend to be the more consequential levels.

HOW TO USE IT

Add it to your execution timeframe — it is designed for intraday charts, 1m through 15m. Set the stop sizing input to match how you actually size positions; every R figure the script produces depends on it. Then read the dashboard rather than the boxes. The boxes are context; the LONG and SHORT row is the decision.

The minimum-room default of 2R is a starting point, not a rule. Pull your own trade history, measure the distance from each entry to the nearest daily level, and find where your win rate falls off. That number is your threshold, and it will not be the same as anyone else's.

REPAINTING

All higher-timeframe data is requested using the expression[1] with lookahead_on construction, meaning every value comes from a closed higher-timeframe bar. Zones rebuild once per closed bar, not tick by tick. What you see on a historical bar is what you would have seen live. The drawn boxes are refreshed on the last bar for display purposes only; the underlying calculations and alert conditions evaluate on every bar from persistent data.

LIMITATIONS AND NOTES

- Requires sufficient history. The 200 SMA needs 200 daily bars, and the zone engine needs at least a few dozen. Newly listed symbols will show partial output.
- Zones are derived from price structure alone. Volume profile, options positioning and session boundaries are not considered.
- High touch counts cut both ways. A level defended four times is a high-probability reaction point right up until it breaks, and when it breaks the move through it is often larger for the same reason. A decisive close through a heavily-touched zone is information, not an indicator failure.
- The recency bonus is deliberately small relative to touch count. If you trade a fast-rotating instrument you may want structure weighted more toward recent action; adjust the lookback window down rather than the scoring.

All settings are documented with tooltips in the settings panel. Source is open — read it, modify it, tell me what you improve.

This script is a decision-support tool, not a trading system. It produces no buy or sell signals and makes no claim about future performance. Nothing here is financial advice. Test any configuration on your own instrument and timeframe before risking capital.

---

## Source Code

````pine
//@version=6
// ═══════════════════════════════════════════════════════════════════════════
//  D1 S/R GUARD
//  Projects clustered higher-timeframe (default D1) support/resistance zones
//  onto an intraday chart, and blocks entries that start too close to one.
//
//  Non-repainting: all HTF data is pulled with the [1] + lookahead_on idiom,
//  so every value is from a CLOSED higher-timeframe bar.
// ═══════════════════════════════════════════════════════════════════════════
indicator("D1 S/R Guard", "D1 S/R Guard", overlay = true, max_boxes_count = 500, max_labels_count = 500)

// ───────────────────────────── 1 · SOURCE & DETECTION ─────────────────────────────
gS = "1 · Source & detection"
htfTF    = input.timeframe("D", "Higher timeframe", group = gS, tooltip = "Timeframe the S/R is derived from.")
lookback = input.int(250, "HTF bars to scan", minval = 30, maxval = 2000, group = gS, tooltip = "250 daily bars ≈ 1 year.")
pivLen   = input.int(3, "Pivot strength (bars each side)", minval = 1, maxval = 10, group = gS, tooltip = "Higher = fewer, more significant swings.")
atrLen   = input.int(14, "HTF ATR length", minval = 2, group = gS)

// ───────────────────────────── 2 · CLUSTERING & RANKING ───────────────────────────
gC = "2 · Clustering & ranking"
clusterMult = input.float(0.25, "Merge levels within (× HTF ATR)", minval = 0.02, step = 0.01, group = gC, tooltip = "Pivots closer than this collapse into one zone and the touch count increments.")
minTouch    = input.int(2, "Min touches to plot", minval = 1, group = gC)
maxDraw     = input.int(10, "Max zones drawn", minval = 1, maxval = 50, group = gC)
drawRange   = input.float(4.0, "Draw only within (× HTF ATR) of price", minval = 0.5, step = 0.5, group = gC)

// ───────────────────────────── 3 · KEY LEVELS ─────────────────────────────────────
gK = "3 · Key levels"
usePDHL = input.bool(true,  "Prior day high / low",  group = gK)
usePDC  = input.bool(true,  "Prior day close",       group = gK)
usePWHL = input.bool(true,  "Prior week high / low", group = gK)
useSMA50  = input.bool(true, "D1 50 SMA",  group = gK)
useSMA100 = input.bool(true, "D1 100 SMA", group = gK)
useSMA200 = input.bool(true, "D1 200 SMA", group = gK)
smaSrc    = input.source(close, "SMA source", group = gK)

// ───────────────────────────── 4 · ENTRY GUARD ────────────────────────────────────
gG = "4 · Entry guard"
proxMult  = input.float(0.30, "Danger band (× HTF ATR)", minval = 0.02, step = 0.01, group = gG, tooltip = "Hard block: any entry starting this close to a level.")
stopMode  = input.string("Intraday ATR", "Stop sizing", options = ["Intraday ATR", "Fixed points"], group = gG)
stopATRm  = input.float(1.0, "Stop = × intraday ATR(14)", minval = 0.1, step = 0.1, group = gG)
stopPts   = input.float(1.0, "Stop = fixed points", minval = 0.0, step = 0.25, group = gG)
minRoomR  = input.float(2.0, "Min room to next level (R)", minval = 0.5, step = 0.5, group = gG, tooltip = "Soft block: skip if the nearest opposing level is closer than this many multiples of your stop.")
tintBg    = input.bool(true, "Tint background when blocked", group = gG)
showTable = input.bool(true, "Show dashboard", group = gG)

// ───────────────────────────── 5 · STYLE ──────────────────────────────────────────
gV = "5 · Style"
cRes   = input.color(color.new(#ef5350, 82), "Resistance zone", group = gV)
cSup   = input.color(color.new(#26a69a, 82), "Support zone",    group = gV)
cIn    = input.color(color.new(#ffa726, 78), "Price inside zone", group = gV)
cKey   = input.color(#787b86, "Key level lines", group = gV)
c50    = input.color(#42a5f5, "50 SMA",  group = gV)
c100   = input.color(#ab47bc, "100 SMA", group = gV)
c200   = input.color(#ffb300, "200 SMA", group = gV)
showLbl= input.bool(true, "Zone labels (touch count)", group = gV)

// ═══════════════════════════════ HTF DATA ═════════════════════════════════════════
[hH, hL, hATRv, hT] = request.security(syminfo.tickerid, htfTF,
     [high[1], low[1], ta.atr(atrLen)[1], time[1]], lookahead = barmerge.lookahead_on)

[pdH, pdL, pdC] = request.security(syminfo.tickerid, "D",
     [high[1], low[1], close[1]], lookahead = barmerge.lookahead_on)

[pwH, pwL] = request.security(syminfo.tickerid, "W",
     [high[1], low[1]], lookahead = barmerge.lookahead_on)

// Daily moving averages — [1] + lookahead_on = last CLOSED daily value, no repaint
[sma50, sma100, sma200, pdT] = request.security(syminfo.tickerid, "D",
     [ta.sma(smaSrc, 50)[1], ta.sma(smaSrc, 100)[1], ta.sma(smaSrc, 200)[1], time[1]],
     lookahead = barmerge.lookahead_on)

// Rolling history of closed HTF bars
var hiArr = array.new<float>()
var loArr = array.new<float>()

newHTF = not na(hT) and (na(hT[1]) or hT != hT[1])

if newHTF and not na(hH) and not na(hL)
    array.push(hiArr, hH)
    array.push(loArr, hL)
    if array.size(hiArr) > lookback
        array.shift(hiArr)
        array.shift(loArr)

// ═══════════════════════════ ZONE CONSTRUCTION ════════════════════════════════════
// Persistent zone store. Rebuilt once per closed HTF bar (cheap, and keeps the
// per-bar guard calculation allocation-free so alerts evaluate on every bar).
var zCtr = array.new<float>()   // volume-weighted centre
var zTop = array.new<float>()   // highest pivot in the cluster
var zBot = array.new<float>()   // lowest pivot in the cluster
var zTch = array.new<int>()     // touch count
var zAge = array.new<int>()     // HTF bars since most recent touch

if newHTF
    array.clear(zCtr), array.clear(zTop), array.clear(zBot), array.clear(zTch), array.clear(zAge)
    n   = array.size(hiArr)
    tol = na(hATRv) ? na : hATRv * clusterMult

    if n > 2 * pivLen and not na(tol) and tol > 0
        // Walk newest → oldest so recent structure anchors each cluster.
        for k = 0 to n - 1
            i = n - 1 - k
            if i >= pivLen and i <= n - 1 - pivLen
                ph   = array.get(hiArr, i)
                pl   = array.get(loArr, i)
                okH  = true
                okL  = true
                for j = 1 to pivLen
                    if array.get(hiArr, i - j) > ph or array.get(hiArr, i + j) > ph
                        okH := false
                    if array.get(loArr, i - j) < pl or array.get(loArr, i + j) < pl
                        okL := false
                age = n - 1 - i

                // Merge a pivot into an existing cluster, or open a new one.
                for pass = 0 to 1
                    doIt = pass == 0 ? okH : okL
                    p    = pass == 0 ? ph  : pl
                    if doIt
                        hit = -1
                        if array.size(zCtr) > 0
                            for m = 0 to array.size(zCtr) - 1
                                if hit < 0 and math.abs(array.get(zCtr, m) - p) <= tol
                                    hit := m
                        if hit >= 0
                            c = array.get(zTch, hit)
                            array.set(zCtr, hit, (array.get(zCtr, hit) * c + p) / (c + 1))
                            array.set(zTop, hit, math.max(array.get(zTop, hit), p))
                            array.set(zBot, hit, math.min(array.get(zBot, hit), p))
                            array.set(zTch, hit, c + 1)
                            array.set(zAge, hit, math.min(array.get(zAge, hit), age))
                        else if array.size(zCtr) < 200
                            array.push(zCtr, p), array.push(zTop, p), array.push(zBot, p)
                            array.push(zTch, 1), array.push(zAge, age)

// Discrete key levels kept in a parallel store (max 5, rebuilt with the zones)
var kPx  = array.new<float>()
var kNm  = array.new<string>()

// Refresh on a new HTF bar OR a new day, so the daily MAs stay current even if
// the zone timeframe is set to something slower than D.
newDay = not na(pdT) and (na(pdT[1]) or pdT != pdT[1])

if newHTF or newDay
    array.clear(kPx), array.clear(kNm)
    if usePDHL and not na(pdH)
        array.push(kPx, pdH), array.push(kNm, "PDH")
        array.push(kPx, pdL), array.push(kNm, "PDL")
    if usePDC and not na(pdC)
        array.push(kPx, pdC), array.push(kNm, "PDC")
    if usePWHL and not na(pwH)
        array.push(kPx, pwH), array.push(kNm, "PWH")
        array.push(kPx, pwL), array.push(kNm, "PWL")
    if useSMA50 and not na(sma50)
        array.push(kPx, sma50), array.push(kNm, "50 SMA")
    if useSMA100 and not na(sma100)
        array.push(kPx, sma100), array.push(kNm, "100 SMA")
    if useSMA200 and not na(sma200)
        array.push(kPx, sma200), array.push(kNm, "200 SMA")

// ═══════════════════════════ PROXIMITY GUARD ══════════════════════════════════════
BIG = 1e20
pad = na(hATRv) ? 0.0 : hATRv * clusterMult * 0.20   // min half-height for 1-touch zones

float rEdge = BIG      // near edge of nearest level ABOVE price
float sEdge = -BIG     // near edge of nearest level BELOW price
int   rTch  = 0
int   sTch  = 0
string rNm  = ""
string sNm  = ""
bool  inside = false

if array.size(zCtr) > 0
    for m = 0 to array.size(zCtr) - 1
        t = math.max(array.get(zTop, m), array.get(zCtr, m) + pad)
        b = math.min(array.get(zBot, m), array.get(zCtr, m) - pad)
        c = array.get(zTch, m)
        if c >= minTouch
            if close >= b and close <= t
                inside := true
            else if b > close and b < rEdge
                rEdge := b, rTch := c, rNm := str.tostring(c) + "× zone"
            else if t < close and t > sEdge
                sEdge := t, sTch := c, sNm := str.tostring(c) + "× zone"

if array.size(kPx) > 0
    for m = 0 to array.size(kPx) - 1
        p = array.get(kPx, m)
        if not na(p)
            if p > close and p < rEdge
                rEdge := p, rTch := 0, rNm := array.get(kNm, m)
            else if p < close and p > sEdge
                sEdge := p, sTch := 0, sNm := array.get(kNm, m)

// Risk unit
intraATR = ta.atr(14)
stopSize = stopMode == "Fixed points" ? stopPts : intraATR * stopATRm
stopSize := stopSize <= 0 or na(stopSize) ? syminfo.mintick : stopSize

distRes = rEdge >= BIG  ? na : rEdge - close
distSup = sEdge <= -BIG ? na : close - sEdge

roomLongR  = na(distRes) ? na : distRes / stopSize
roomShortR = na(distSup) ? na : distSup / stopSize

band = na(hATRv) ? na : hATRv * proxMult

// A setup is blocked if price sits inside a zone, is inside the danger band,
// or simply doesn't have enough runway to the next level to pay for the risk.
longBlocked  = inside or (not na(distRes) and not na(band) and distRes < band) or (not na(roomLongR)  and roomLongR  < minRoomR)
shortBlocked = inside or (not na(distSup) and not na(band) and distSup < band) or (not na(roomShortR) and roomShortR < minRoomR)

bgcolor(tintBg and inside ? color.new(color.orange, 90) : tintBg and longBlocked and shortBlocked ? color.new(color.orange, 93) : na, title = "Blocked tint")

// ═══════════════════════════ KEY LEVEL PLOTS ══════════════════════════════════════
plot(usePDHL ? pdH : na, "PDH", cKey, 1, plot.style_stepline)
plot(usePDHL ? pdL : na, "PDL", cKey, 1, plot.style_stepline)
plot(usePDC  ? pdC : na, "PDC", color.new(cKey, 40), 1, plot.style_stepline)
plot(usePWHL ? pwH : na, "PWH", color.new(cKey, 30), 2, plot.style_stepline)
plot(usePWHL ? pwL : na, "PWL", color.new(cKey, 30), 2, plot.style_stepline)

plot(useSMA50  ? sma50  : na, "D1 50 SMA",  c50,  2, plot.style_stepline)
plot(useSMA100 ? sma100 : na, "D1 100 SMA", c100, 2, plot.style_stepline)
plot(useSMA200 ? sma200 : na, "D1 200 SMA", c200, 3, plot.style_stepline)

// ═══════════════════════════ ZONE RENDERING ═══════════════════════════════════════
var zBoxes  = array.new<box>()
var zLabels = array.new<label>()

if barstate.islast
    if array.size(zBoxes) > 0
        for i = 0 to array.size(zBoxes) - 1
            box.delete(array.get(zBoxes, i))
        array.clear(zBoxes)
    if array.size(zLabels) > 0
        for i = 0 to array.size(zLabels) - 1
            label.delete(array.get(zLabels, i))
        array.clear(zLabels)

    nZ = array.size(zCtr)
    if nZ > 0 and not na(hATRv)
        scores = array.new<float>()
        for m = 0 to nZ - 1
            recency = 1.0 - array.get(zAge, m) / math.max(1.0, float(lookback))
            array.push(scores, array.get(zTch, m) + math.max(0.0, recency))
        ordered = array.sort_indices(scores, order.descending)

        int drawn = 0
        leftX = bar_index - math.min(bar_index, 400)
        for q = 0 to array.size(ordered) - 1
            if drawn < maxDraw
                m   = array.get(ordered, q)
                ctr = array.get(zCtr, m)
                if array.get(zTch, m) >= minTouch and math.abs(ctr - close) <= drawRange * hATRv
                    t  = math.max(array.get(zTop, m), ctr + pad)
                    b  = math.min(array.get(zBot, m), ctr - pad)
                    cl = close >= b and close <= t ? cIn : ctr > close ? cRes : cSup
                    bx = box.new(leftX, t, bar_index, b, border_color = color.new(cl, 40), border_width = 1, bgcolor = cl, extend = extend.right)
                    array.push(zBoxes, bx)
                    if showLbl
                        lb = label.new(bar_index + 6, t, str.tostring(array.get(zTch, m)) + "×",
                             style = label.style_label_left, color = color.new(color.black, 100),
                             textcolor = color.new(cl, 20), size = size.tiny)
                        array.push(zLabels, lb)
                    drawn := drawn + 1

// ═══════════════════════════ DASHBOARD ════════════════════════════════════════════
var table tb = table.new(position.top_right, 4, 6, border_width = 1)

f_r(v) => na(v) ? "—" : str.tostring(v, "#.##") + "R"
f_p(v) => na(v) ? "—" : str.tostring(v, format.mintick)

if showTable and barstate.islast
    okC  = color.new(#26a69a, 20)
    badC = color.new(#ef5350, 20)
    hdC  = color.new(#2a2e39, 10)
    txC  = color.white

    table.cell(tb, 0, 0, "D1 S/R GUARD", bgcolor = hdC, text_color = txC, text_size = size.small)
    table.cell(tb, 1, 0, "LEVEL",  bgcolor = hdC, text_color = txC, text_size = size.tiny)
    table.cell(tb, 2, 0, "DIST",   bgcolor = hdC, text_color = txC, text_size = size.tiny)
    table.cell(tb, 3, 0, "ROOM",   bgcolor = hdC, text_color = txC, text_size = size.tiny)

    table.cell(tb, 0, 1, "Resistance", bgcolor = hdC, text_color = txC, text_size = size.tiny)
    table.cell(tb, 1, 1, f_p(rEdge >= BIG ? na : rEdge) + (rNm == "" ? "" : "  " + rNm), bgcolor = hdC, text_color = txC, text_size = size.tiny)
    table.cell(tb, 2, 1, f_p(distRes), bgcolor = hdC, text_color = txC, text_size = size.tiny)
    table.cell(tb, 3, 1, f_r(roomLongR), bgcolor = hdC, text_color = txC, text_size = size.tiny)

    table.cell(tb, 0, 2, "Support", bgcolor = hdC, text_color = txC, text_size = size.tiny)
    table.cell(tb, 1, 2, f_p(sEdge <= -BIG ? na : sEdge) + (sNm == "" ? "" : "  " + sNm), bgcolor = hdC, text_color = txC, text_size = size.tiny)
    table.cell(tb, 2, 2, f_p(distSup), bgcolor = hdC, text_color = txC, text_size = size.tiny)
    table.cell(tb, 3, 2, f_r(roomShortR), bgcolor = hdC, text_color = txC, text_size = size.tiny)

    table.cell(tb, 0, 3, "1R = " + f_p(stopSize), bgcolor = hdC, text_color = color.new(txC, 30), text_size = size.tiny)
    table.cell(tb, 1, 3, "HTF ATR " + f_p(hATRv), bgcolor = hdC, text_color = color.new(txC, 30), text_size = size.tiny)
    table.cell(tb, 2, 3, "Band " + f_p(band), bgcolor = hdC, text_color = color.new(txC, 30), text_size = size.tiny)
    table.cell(tb, 3, 3, inside ? "IN ZONE" : "", bgcolor = inside ? badC : hdC, text_color = txC, text_size = size.tiny)

    table.cell(tb, 0, 4, "LONG",  bgcolor = longBlocked ? badC : okC, text_color = txC, text_size = size.small)
    table.cell(tb, 1, 4, longBlocked ? "STAND DOWN" : "CLEAR", bgcolor = longBlocked ? badC : okC, text_color = txC, text_size = size.small)
    table.cell(tb, 2, 4, "SHORT", bgcolor = shortBlocked ? badC : okC, text_color = txC, text_size = size.small)
    table.cell(tb, 3, 4, shortBlocked ? "STAND DOWN" : "CLEAR", bgcolor = shortBlocked ? badC : okC, text_color = txC, text_size = size.small)

// ═══════════════════════════ ALERTS ═══════════════════════════════════════════════
alertcondition(longBlocked  and not longBlocked[1],  "Long blocked",  "D1 S/R Guard: no room above — long entry blocked on {{ticker}}")
alertcondition(shortBlocked and not shortBlocked[1], "Short blocked", "D1 S/R Guard: no room below — short entry blocked on {{ticker}}")
alertcondition(inside and not inside[1],             "Price entered zone", "D1 S/R Guard: price entered a D1 S/R zone on {{ticker}}")
alertcondition(not longBlocked  and longBlocked[1],  "Long cleared",  "D1 S/R Guard: long path cleared on {{ticker}}")
alertcondition(not shortBlocked and shortBlocked[1], "Short cleared", "D1 S/R Guard: short path cleared on {{ticker}}")
````
