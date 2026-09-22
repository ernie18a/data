<!-- tradingview-pine-id: PUB;2f3c2e59d39e40888cc706770b4fc9f5 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# FootprintKit

Source: https://www.tradingview.com/script/c7gwEeFB-FootprintKit/

## Description

Analysis toolkit for the native footprint API introduced in Pine v6. It turns a `footprint` object into aggregated row statistics, price-interval measurements, low and high volume node runs, stacked imbalances, unfinished auction reads, absorption reads and multi-bar composite profiles.

It is written for script authors who build their own footprint tools and who would otherwise re-implement the same row loops in every script.

WHY THE LIBRARY NEVER CALLS request.footprint()

Pine allows only one unique footprint request per script. If the library issued that request internally it would consume the caller's single slot, and the importing script could no longer query the footprint on its own terms. So the caller makes the one allowed call and passes the resulting object into every function.

The consequence is that the library performs no requests, draws nothing and keeps no persistent state outside the Profile object you create yourself. There is nothing in it that can repaint.

WHAT IT COMPUTES THAT THE API DOES NOT EXPOSE

- Stacked imbalances. The API flags imbalance per row; the stack of consecutive flagged rows is what carries meaning in footprint reading, and it has to be assembled.
- Unfinished auction at the extremes of a bar, i.e. an extreme row that still shows trade on both sides.
- Volume traded inside an arbitrary price interval, with rows that only partly overlap the interval counted pro rata.
- Runs of thin rows, the price pockets a move passed through without trade, and runs of heavy rows, the shelves inside the bar.
- A composite profile across several bars with its own point of control and value area. request.footprint() returns one bar at a time; feeding successive bars into a Profile builds the multi-bar picture the single call cannot give.
- Distribution shape metrics that read the whole profile rather than only its peak.

FORMULAS

Aggressive volume per row and per interval is derived from total volume V and delta D as buy = (V + D) / 2 and sell = (V - D) / 2. This is exact by the definition of delta and avoids depending on optional per-row accessors.

slice() weights each row by the fraction of its height that falls inside the requested interval, k = overlap / rowHeight, clamped to 1. Counting a boundary row either whole or not at all is the usual source of error in hand-written versions.

concentration() is POC row volume divided by mean row volume. A value near 1 means volume was spread evenly, a high value means one price row absorbed most of the activity.

dispersion() is the Shannon entropy of the row volume distribution, normalised by ln(n) to the 0 to 1 range: H = -sum(p * ln p) / ln(n), where p is a row's share of bar volume. Zero means all volume sat in one row, one means a perfectly even spread. Unlike concentration it distinguishes a bar with two heavy rows from a bar with one.

deltaCentroid() returns the centre of mass of absolute delta as a fraction of the bar range from the low, showing where aggression concentrated regardless of which side was aggressive.

absorption() splits the bar range into thirds, measures each extreme third with slice(), and reports absorption when a third holds at least the requested share of bar volume while its delta points against the direction of the bar. Aggression that meets size and fails to move price is the signature of a passive participant taking the other side.

The composite value area grows outward from the point of control, repeatedly taking the heavier of the two neighbouring buckets until the requested share of total volume is enclosed.

USAGE

    import Smart-Day-Trader/FootprintKit/1 as fpk

    footprint fp = request.footprint(4, 70, 300)
    fpk.RowStats s = fpk.stats(fp)

    float conc = fpk.concentration(s)
    float pos  = fpk.pocPosition(s, high, low)
    array<fpk.Span> voids = fpk.runs(fp, s, 0.4, 3, true)
    [upperWick, body, lowerWick] = fpk.wicks(fp, open, high, low, close)

NOTES

A plan with footprint data access is required for the data itself; the library compiles on any plan because it makes no requests.

Choose ticks per row relative to the instrument's tick size rather than copying a default. On NASDAQ 100 E-mini futures the tick is 0.25 points, so 4 ticks per row equals one point and yields roughly 20 to 30 rows on a 5 minute bar. A value of 20 there would collapse the same bar into 4 rows, at which point concentration, entropy and row runs stop carrying information.

All functions accept a na footprint and return empty or na results rather than failing, so they are safe to call on bars without data.

REFERENCE

stats(fp)
  Aggregates every row of a footprint in a single pass: totals, POC, delta,
imbalance counts and the price bounds actually covered by rows. Reading these values
one by one costs several loops over the same array; this does it once.
  Parameters:
    fp (footprint): Footprint object returned by request.footprint(). Safe to pass na.
  Returns: A RowStats object. When the footprint is na or empty, `n` is 0 and the
float fields are na.

concentration(s)
  Concentration of the bar's volume: POC row volume divided by the mean row
volume. A value near 1 means volume was spread evenly across the bar; a high value
means a single price row absorbed most of the activity.
  Parameters:
    s (RowStats): RowStats produced by stats().
  Returns: The ratio, or na when statistics are empty.

dispersion(fp, s)
  Normalised Shannon entropy of the volume distribution across rows, scaled to
0 to 1. Zero means all volume sat in one row, one means perfectly even spread. Unlike
concentration() this reads the whole shape rather than just the peak, so a bar with
two heavy rows is distinguished from a bar with one.
  Parameters:
    fp (footprint): Footprint object.
    s (RowStats): RowStats produced by stats() for the same footprint.
  Returns: Entropy in the 0 to 1 range, or na when fewer than two rows carry volume.

pocPosition(s, barHigh, barLow)
  Where the POC sits inside the bar's range, as a fraction from the low.
0 places the heaviest row at the low of the bar, 1 at the high.
  Parameters:
    s (RowStats): RowStats produced by stats().
    barHigh (float): High of the bar.
    barLow (float): Low of the bar.
  Returns: Position clamped to 0 to 1, or na when the range is degenerate.

deltaCentroid(fp, barHigh, barLow)
  Centre of mass of absolute delta inside the bar, as a fraction from the low.
Shows where aggression was concentrated regardless of which side was aggressive,
which often differs from where total volume sat.
  Parameters:
    fp (footprint): Footprint object.
    barHigh (float): High of the bar.
    barLow (float): Low of the bar.
  Returns: Position in the 0 to 1 range, or na when there is no delta to weight by.

slice(fp, priceA, priceB)
  Volume traded inside an arbitrary price interval. Rows that only partly
overlap the interval are counted in proportion to the overlapped fraction of their
height, so the result is correct even when the interval boundaries fall mid-row.
This is the primitive behind wick, zone and level measurements.
  Parameters:
    fp (footprint): Footprint object.
    priceA (float): One boundary of the interval. Order does not matter.
    priceB (float): The other boundary of the interval.
  Returns: A Slice object. All fields are 0 and `share` is na when nothing overlaps.

wicks(fp, o, h, l, c)
  Splits the bar's volume into upper wick, body and lower wick using slice(),
so partially overlapped rows are handled correctly. An empty upper wick slice on a
bar with a long upper shadow means price travelled there without trading size, which
reads very differently from a wick that carries volume.
  Parameters:
    fp (footprint): Footprint object.
    o (float): Open of the bar.
    h (float): High of the bar.
    l (float): Low of the bar.
    c (float): Close of the bar.
  Returns: A tuple [upperWick, body, lowerWick] of Slice objects.

runs(fp, s, ratio, minRun, below)
  Finds every group of consecutive rows whose volume is below or above a
multiple of the bar's mean row volume, and returns them as price spans. With
below = true this locates thin rows, the price pockets a move passed through without
trade; with below = false it locates the heavy shelves inside the bar.
  Parameters:
    fp (footprint): Footprint object.
    s (RowStats): RowStats produced by stats() for the same footprint.
    ratio (float): Multiplier applied to the mean row volume to form the threshold.
    minRun (int): Minimum number of consecutive rows required to report a span.
    below (bool): When true, keep rows at or below the threshold; when false, at or above.
  Returns: An array of Span objects, ordered as the rows are ordered. Empty when nothing
qualifies.

stacks(fp, minRun, buySide)
  Finds stacked imbalances: runs of consecutive rows all flagged on the same
side. The native API exposes the flag per row, but the stack is what carries meaning
in footprint reading, and stacks have to be assembled by hand.
  Parameters:
    fp (footprint): Footprint object.
    minRun (int): Minimum number of consecutive flagged rows to report, commonly 3.
    buySide (bool): When true, collect buy imbalance stacks; when false, sell imbalance stacks.
  Returns: An array of Span objects covering each stack. Empty when none reach minRun.

unfinished(fp, tol)
  Tests the extreme rows for an unfinished auction: an extreme that still shows
trade on both sides, meaning the move stopped before either side was cleared out.
A finished extreme has one side at or near zero.
  Parameters:
    fp (footprint): Footprint object.
    tol (float): Fraction of the extreme row's own volume below which a side counts as empty.
Use 0 for a strict test, or a small value such as 0.05 to tolerate noisy feeds.
  Returns: A tuple [atHigh, atLow] of booleans. Both false when the footprint is empty.

absorption(fp, s, o, c, minShare)
  Reads absorption at the extremes of the bar: one third of the bar's range
holding a large share of the volume with delta pointing against the bar's direction.
Aggression that meets size and fails to move price is the signature of a passive
participant taking the other side.
  Parameters:
    fp (footprint): Footprint object.
    s (RowStats): RowStats produced by stats() for the same footprint.
    o (float): Open of the bar.
    c (float): Close of the bar.
    minShare (float): Minimum share of bar volume the third must hold, for example 0.4.
  Returns: 1 when sellers were absorbed at the lows of an up bar, -1 when buyers were
absorbed at the highs of a down bar, 0 otherwise.

newProfile(step)
  Creates an empty composite profile. request.footprint() delivers one bar at a
time; feeding successive bars into a profile builds the multi-bar picture the single
call cannot give on its own.
  Parameters:
    step (float): Price bucket height. Use the row height from RowStats to keep the composite
at the same resolution as the footprint itself.
  Returns: An empty Profile object.

method feed(p, fp)
  Folds one bar's rows into the profile. Buckets are keyed by rounded row
midpoint and kept sorted, so repeated calls stay ordered and lookups stay cheap.
Call once per confirmed bar.
  Namespace types: Profile
  Parameters:
    p (Profile): Profile to update, modified in place.
    fp (footprint): Footprint object for the bar being added.
  Returns: Nothing. The profile is mutated.

method sum(p)
  Total volume held by the profile.
  Namespace types: Profile
  Parameters:
    p (Profile): Profile to read.
  Returns: Sum of all bucket volumes, or 0 when the profile is empty.

method poc(p)
  Point of control of the composite profile.
  Namespace types: Profile
  Parameters:
    p (Profile): Profile to read.
  Returns: Centre price of the heaviest bucket, or na when the profile is empty.

method valueArea(p, pct)
  Value area of the composite profile, grown outward from the point of control
by repeatedly taking the heavier neighbouring bucket until the requested share of
total volume is enclosed.
  Namespace types: Profile
  Parameters:
    p (Profile): Profile to read.
    pct (float): Share of total volume to enclose, expressed 0 to 1, for example 0.7.
  Returns: A tuple [vaHigh, vaLow] of prices, both na when the profile is empty.

method reset(p)
  Empties the profile while keeping its bucket size, ready for a new window.
  Namespace types: Profile
  Parameters:
    p (Profile): Profile to clear, modified in place.
  Returns: Nothing. The profile is mutated.

RowStats
  Aggregated statistics for every row of a single bar's footprint.
  Fields:
    n (series int): Number of rows. Zero when the footprint holds no data.
    total (series float): Sum of row volume across the bar.
    avg (series float): Mean volume per row.
    maxVol (series float): Volume of the heaviest row, i.e. the POC row.
    minVol (series float): Volume of the lightest row.
    pocVol (series float): Same as maxVol, kept for readability at call sites.
    pocTop (series float): Upper price bound of the POC row.
    pocBot (series float): Lower price bound of the POC row.
    pocMid (series float): Midpoint of the POC row.
    pocIdx (series int): Index of the POC row inside the rows array, -1 when empty.
    buy (series float): Aggressive buy volume of the bar, derived as (total + delta) / 2.
    sell (series float): Aggressive sell volume of the bar, derived as (total - delta) / 2.
    delta (series float): Net delta of the bar summed across rows.
    buyImb (series int): Count of rows flagged as buy imbalances.
    sellImb (series int): Count of rows flagged as sell imbalances.
    top (series float): Highest price covered by any row.
    bot (series float): Lowest price covered by any row.
    rowH (series float): Height of one row in price units.

Span
  A contiguous group of rows inside one bar, reported as a price span.
  Fields:
    top (series float): Upper price bound of the span.
    bot (series float): Lower price bound of the span.
    idxA (series int): Index of the first row of the span.
    idxB (series int): Index of the last row of the span.
    count (series int): Number of rows in the span.
    vol (series float): Total volume inside the span.
    delta (series float): Net delta inside the span.

Slice
  Volume measured over an arbitrary price interval, with partial rows counted pro rata.
  Fields:
    total (series float): Volume inside the interval.
    buy (series float): Aggressive buy volume inside the interval.
    sell (series float): Aggressive sell volume inside the interval.
    delta (series float): Net delta inside the interval.
    share (series float): Interval volume divided by the bar's total volume, 0 to 1.

Profile
  Composite volume profile accumulated from several bars' footprints.
  Fields:
    step (series float): Price bucket size. Rows are folded into buckets of this height.
    price (array<float>): Bucket centre prices, kept sorted ascending.
    vol (array<float>): Volume per bucket, index-aligned with `price`.
    dlt (array<float>): Delta per bucket, index-aligned with `price`.

---

## Source Code

````pine
//@version=6
// @description Analysis toolkit for the native Pine v6 footprint API. Turns a `footprint`
//   object into aggregated row statistics, price-interval measurements, low/high volume
//   node runs, stacked imbalances, unfinished auctions, absorption reads and multi-bar
//   composite profiles.
//
//   The library never calls request.footprint() itself. Pine allows only one unique
//   footprint request per script, so the caller makes that single call and passes the
//   resulting object in. Every function here is pure: no requests, no drawing, no
//   persistent state, nothing that can repaint.
//
//   Row buy/sell volume is derived from total volume and delta as
//   buy = (V + D) / 2 and sell = (V - D) / 2, which is exact by definition of delta.
//
//   Usage:
//     import Smart-Day-Trader/FootprintKit/1 as fpk
//     footprint fp = request.footprint(4, 70, 300)
//     fpk.RowStats s = fpk.stats(fp)
//     float conc = fpk.concentration(s)                    // POC row vs average row
//     array<fpk.Span> voids = fpk.runs(fp, s, 0.4, 3, true) // thin rows, 3+ in a row
library("FootprintKit", overlay = false)

// ═══════════════════════════════════════════════════════════════════════════
//  TYPES
// ═══════════════════════════════════════════════════════════════════════════

// @type Aggregated statistics for every row of a single bar's footprint.
// @field n Number of rows. Zero when the footprint holds no data.
// @field total Sum of row volume across the bar.
// @field avg Mean volume per row.
// @field maxVol Volume of the heaviest row, i.e. the POC row.
// @field minVol Volume of the lightest row.
// @field pocVol Same as maxVol, kept for readability at call sites.
// @field pocTop Upper price bound of the POC row.
// @field pocBot Lower price bound of the POC row.
// @field pocMid Midpoint of the POC row.
// @field pocIdx Index of the POC row inside the rows array, -1 when empty.
// @field buy Aggressive buy volume of the bar, derived as (total + delta) / 2.
// @field sell Aggressive sell volume of the bar, derived as (total - delta) / 2.
// @field delta Net delta of the bar summed across rows.
// @field buyImb Count of rows flagged as buy imbalances.
// @field sellImb Count of rows flagged as sell imbalances.
// @field top Highest price covered by any row.
// @field bot Lowest price covered by any row.
// @field rowH Height of one row in price units.
export type RowStats
    int   n       = 0
    float total   = 0.0
    float avg     = na
    float maxVol  = na
    float minVol  = na
    float pocVol  = na
    float pocTop  = na
    float pocBot  = na
    float pocMid  = na
    int   pocIdx  = -1
    float buy     = 0.0
    float sell    = 0.0
    float delta   = 0.0
    int   buyImb  = 0
    int   sellImb = 0
    float top     = na
    float bot     = na
    float rowH    = na

// @type A contiguous group of rows inside one bar, reported as a price span.
// @field top Upper price bound of the span.
// @field bot Lower price bound of the span.
// @field idxA Index of the first row of the span.
// @field idxB Index of the last row of the span.
// @field count Number of rows in the span.
// @field vol Total volume inside the span.
// @field delta Net delta inside the span.
export type Span
    float top   = na
    float bot   = na
    int   idxA  = -1
    int   idxB  = -1
    int   count = 0
    float vol   = 0.0
    float delta = 0.0

// @type Volume measured over an arbitrary price interval, with partial rows counted pro rata.
// @field total Volume inside the interval.
// @field buy Aggressive buy volume inside the interval.
// @field sell Aggressive sell volume inside the interval.
// @field delta Net delta inside the interval.
// @field share Interval volume divided by the bar's total volume, 0 to 1.
export type Slice
    float total = 0.0
    float buy   = 0.0
    float sell  = 0.0
    float delta = 0.0
    float share = na

// @type Composite volume profile accumulated from several bars' footprints.
// @field step Price bucket size. Rows are folded into buckets of this height.
// @field price Bucket centre prices, kept sorted ascending.
// @field vol Volume per bucket, index-aligned with `price`.
// @field dlt Delta per bucket, index-aligned with `price`.
export type Profile
    float        step  = na
    array<float> price = na
    array<float> vol   = na
    array<float> dlt   = na

// ═══════════════════════════════════════════════════════════════════════════
//  INTERNAL HELPERS
// ═══════════════════════════════════════════════════════════════════════════

// Position of `v` in a sorted ascending array. Returns the index when found,
// otherwise -(insertionPoint + 1), matching the usual binary-search convention.
bsearch(array<float> a, float v) =>
    int lo = 0
    int hi = array.size(a) - 1
    int res = -1
    bool done = false
    while lo <= hi and not done
        int mid = (lo + hi) / 2
        float mv = array.get(a, mid)
        if mv == v
            res  := mid
            done := true
        else if mv < v
            lo := mid + 1
        else
            hi := mid - 1
    done ? res : -(lo + 1)

// ═══════════════════════════════════════════════════════════════════════════
//  ROW STATISTICS
// ═══════════════════════════════════════════════════════════════════════════

// @function Aggregates every row of a footprint in a single pass: totals, POC, delta,
//   imbalance counts and the price bounds actually covered by rows. Reading these values
//   one by one costs several loops over the same array; this does it once.
// @param fp Footprint object returned by request.footprint(). Safe to pass na.
// @returns A RowStats object. When the footprint is na or empty, `n` is 0 and the
//   float fields are na.
export stats(footprint fp) =>
    RowStats s = RowStats.new()
    if not na(fp)
        array<volume_row> rows = fp.rows()
        int n = array.size(rows)
        if n > 0
            float mx  = -1.0
            float mn  = 1.0e30
            float hiP = -1.0e30
            float loP = 1.0e30
            for i = 0 to n - 1
                volume_row r = array.get(rows, i)
                float v  = r.total_volume()
                float d  = r.delta()
                float ru = r.up_price()
                float rd = r.down_price()
                s.total += v
                s.delta += d
                if r.has_buy_imbalance()
                    s.buyImb += 1
                if r.has_sell_imbalance()
                    s.sellImb += 1
                if v > mx
                    mx := v
                    s.pocIdx := i
                    s.pocTop := ru
                    s.pocBot := rd
                if v < mn
                    mn := v
                if ru > hiP
                    hiP := ru
                if rd < loP
                    loP := rd
            s.n      := n
            s.maxVol := mx
            s.minVol := mn
            s.pocVol := mx
            s.avg    := s.total / n
            s.pocMid := (s.pocTop + s.pocBot) / 2.0
            s.buy    := (s.total + s.delta) / 2.0
            s.sell   := (s.total - s.delta) / 2.0
            s.top    := hiP
            s.bot    := loP
            s.rowH   := s.pocTop - s.pocBot
    s

// @function Concentration of the bar's volume: POC row volume divided by the mean row
//   volume. A value near 1 means volume was spread evenly across the bar; a high value
//   means a single price row absorbed most of the activity.
// @param s RowStats produced by stats().
// @returns The ratio, or na when statistics are empty.
export concentration(RowStats s) =>
    na(s) or na(s.avg) or s.avg <= 0 ? na : s.pocVol / s.avg

// @function Normalised Shannon entropy of the volume distribution across rows, scaled to
//   0 to 1. Zero means all volume sat in one row, one means perfectly even spread. Unlike
//   concentration() this reads the whole shape rather than just the peak, so a bar with
//   two heavy rows is distinguished from a bar with one.
// @param fp Footprint object.
// @param s RowStats produced by stats() for the same footprint.
// @returns Entropy in the 0 to 1 range, or na when fewer than two rows carry volume.
export dispersion(footprint fp, RowStats s) =>
    float h = na
    if not na(fp) and not na(s) and s.n > 1 and s.total > 0
        array<volume_row> rows = fp.rows()
        float e = 0.0
        for i = 0 to s.n - 1
            float p = array.get(rows, i).total_volume() / s.total
            if p > 0
                e -= p * math.log(p)
        h := e / math.log(s.n)
    h

// @function Where the POC sits inside the bar's range, as a fraction from the low.
//   0 places the heaviest row at the low of the bar, 1 at the high.
// @param s RowStats produced by stats().
// @param barHigh High of the bar.
// @param barLow Low of the bar.
// @returns Position clamped to 0 to 1, or na when the range is degenerate.
export pocPosition(RowStats s, float barHigh, float barLow) =>
    float rng = barHigh - barLow
    na(s) or na(s.pocMid) or na(rng) or rng <= 0 ? na : math.max(0.0, math.min(1.0, (s.pocMid - barLow) / rng))

// @function Centre of mass of absolute delta inside the bar, as a fraction from the low.
//   Shows where aggression was concentrated regardless of which side was aggressive,
//   which often differs from where total volume sat.
// @param fp Footprint object.
// @param barHigh High of the bar.
// @param barLow Low of the bar.
// @returns Position in the 0 to 1 range, or na when there is no delta to weight by.
export deltaCentroid(footprint fp, float barHigh, float barLow) =>
    float pos = na
    float rng = barHigh - barLow
    if not na(fp) and not na(rng) and rng > 0
        array<volume_row> rows = fp.rows()
        int n = array.size(rows)
        if n > 0
            float wsum = 0.0
            float psum = 0.0
            for i = 0 to n - 1
                volume_row r = array.get(rows, i)
                float w = math.abs(r.delta())
                float m = (r.up_price() + r.down_price()) / 2.0
                wsum += w
                psum += w * m
            if wsum > 0
                pos := math.max(0.0, math.min(1.0, (psum / wsum - barLow) / rng))
    pos

// ═══════════════════════════════════════════════════════════════════════════
//  PRICE INTERVAL MEASUREMENT
// ═══════════════════════════════════════════════════════════════════════════

// @function Volume traded inside an arbitrary price interval. Rows that only partly
//   overlap the interval are counted in proportion to the overlapped fraction of their
//   height, so the result is correct even when the interval boundaries fall mid-row.
//   This is the primitive behind wick, zone and level measurements.
// @param fp Footprint object.
// @param priceA One boundary of the interval. Order does not matter.
// @param priceB The other boundary of the interval.
// @returns A Slice object. All fields are 0 and `share` is na when nothing overlaps.
export slice(footprint fp, float priceA, float priceB) =>
    Slice out = Slice.new()
    if not na(fp) and not na(priceA) and not na(priceB)
        array<volume_row> rows = fp.rows()
        int n = array.size(rows)
        if n > 0
            float lo = math.min(priceA, priceB)
            float hi = math.max(priceA, priceB)
            float tot = 0.0
            for i = 0 to n - 1
                volume_row r = array.get(rows, i)
                float rd = r.down_price()
                float ru = r.up_price()
                float v  = r.total_volume()
                tot += v
                float hgt = ru - rd
                float ov  = math.min(ru, hi) - math.max(rd, lo)
                if ov > 0 and hgt > 0
                    float k = math.min(1.0, ov / hgt)
                    out.total += v * k
                    out.delta += r.delta() * k
            out.buy   := (out.total + out.delta) / 2.0
            out.sell  := (out.total - out.delta) / 2.0
            out.share := tot > 0 ? out.total / tot : na
    out

// @function Splits the bar's volume into upper wick, body and lower wick using slice(),
//   so partially overlapped rows are handled correctly. An empty upper wick slice on a
//   bar with a long upper shadow means price travelled there without trading size, which
//   reads very differently from a wick that carries volume.
// @param fp Footprint object.
// @param o Open of the bar.
// @param h High of the bar.
// @param l Low of the bar.
// @param c Close of the bar.
// @returns A tuple [upperWick, body, lowerWick] of Slice objects.
export wicks(footprint fp, float o, float h, float l, float c) =>
    float bt = math.max(o, c)
    float bb = math.min(o, c)
    [slice(fp, bt, h), slice(fp, bb, bt), slice(fp, l, bb)]

// ═══════════════════════════════════════════════════════════════════════════
//  ROW RUNS
// ═══════════════════════════════════════════════════════════════════════════

// @function Finds every group of consecutive rows whose volume is below or above a
//   multiple of the bar's mean row volume, and returns them as price spans. With
//   below = true this locates thin rows, the price pockets a move passed through without
//   trade; with below = false it locates the heavy shelves inside the bar.
// @param fp Footprint object.
// @param s RowStats produced by stats() for the same footprint.
// @param ratio Multiplier applied to the mean row volume to form the threshold.
// @param minRun Minimum number of consecutive rows required to report a span.
// @param below When true, keep rows at or below the threshold; when false, at or above.
// @returns An array of Span objects, ordered as the rows are ordered. Empty when nothing
//   qualifies.
export runs(footprint fp, RowStats s, float ratio, int minRun, bool below) =>
    array<Span> out = array.new<Span>()
    if not na(fp) and not na(s) and s.n > 0 and not na(s.avg) and s.avg > 0
        array<volume_row> rows = fp.rows()
        float thr = s.avg * ratio
        int   st  = -1
        float acc = 0.0
        float dac = 0.0
        for i = 0 to s.n - 1
            volume_row r = array.get(rows, i)
            float v = r.total_volume()
            bool hit = below ? v <= thr : v >= thr
            if hit
                if st == -1
                    st  := i
                    acc := 0.0
                    dac := 0.0
                acc += v
                dac += r.delta()
            if not hit or i == s.n - 1
                int last = hit ? i : i - 1
                if st != -1 and last - st + 1 >= minRun
                    volume_row a = array.get(rows, st)
                    volume_row b = array.get(rows, last)
                    array.push(out, Span.new(
                         top   = math.max(a.up_price(), b.up_price()),
                         bot   = math.min(a.down_price(), b.down_price()),
                         idxA  = st, idxB = last, count = last - st + 1,
                         vol   = acc, delta = dac))
                st := -1
    out

// @function Finds stacked imbalances: runs of consecutive rows all flagged on the same
//   side. The native API exposes the flag per row, but the stack is what carries meaning
//   in footprint reading, and stacks have to be assembled by hand.
// @param fp Footprint object.
// @param minRun Minimum number of consecutive flagged rows to report, commonly 3.
// @param buySide When true, collect buy imbalance stacks; when false, sell imbalance stacks.
// @returns An array of Span objects covering each stack. Empty when none reach minRun.
export stacks(footprint fp, int minRun, bool buySide) =>
    array<Span> out = array.new<Span>()
    if not na(fp)
        array<volume_row> rows = fp.rows()
        int n = array.size(rows)
        if n > 0
            int   st  = -1
            float acc = 0.0
            float dac = 0.0
            for i = 0 to n - 1
                volume_row r = array.get(rows, i)
                bool hit = buySide ? r.has_buy_imbalance() : r.has_sell_imbalance()
                if hit
                    if st == -1
                        st  := i
                        acc := 0.0
                        dac := 0.0
                    acc += r.total_volume()
                    dac += r.delta()
                if not hit or i == n - 1
                    int last = hit ? i : i - 1
                    if st != -1 and last - st + 1 >= minRun
                        volume_row a = array.get(rows, st)
                        volume_row b = array.get(rows, last)
                        array.push(out, Span.new(
                             top   = math.max(a.up_price(), b.up_price()),
                             bot   = math.min(a.down_price(), b.down_price()),
                             idxA  = st, idxB = last, count = last - st + 1,
                             vol   = acc, delta = dac))
                    st := -1
    out

// ═══════════════════════════════════════════════════════════════════════════
//  BAR READS
// ═══════════════════════════════════════════════════════════════════════════

// @function Tests the extreme rows for an unfinished auction: an extreme that still shows
//   trade on both sides, meaning the move stopped before either side was cleared out.
//   A finished extreme has one side at or near zero.
// @param fp Footprint object.
// @param tol Fraction of the extreme row's own volume below which a side counts as empty.
//   Use 0 for a strict test, or a small value such as 0.05 to tolerate noisy feeds.
// @returns A tuple [atHigh, atLow] of booleans. Both false when the footprint is empty.
export unfinished(footprint fp, float tol) =>
    bool hi = false
    bool lo = false
    if not na(fp)
        array<volume_row> rows = fp.rows()
        int n = array.size(rows)
        if n > 0
            int   iHi = 0
            int   iLo = 0
            float pHi = -1.0e30
            float pLo = 1.0e30
            for i = 0 to n - 1
                volume_row r = array.get(rows, i)
                if r.up_price() > pHi
                    pHi := r.up_price()
                    iHi := i
                if r.down_price() < pLo
                    pLo := r.down_price()
                    iLo := i
            volume_row rh = array.get(rows, iHi)
            volume_row rl = array.get(rows, iLo)
            float vh = rh.total_volume()
            float vl = rl.total_volume()
            if vh > 0
                float b = (vh + rh.delta()) / 2.0
                float s = (vh - rh.delta()) / 2.0
                hi := math.min(b, s) > vh * tol
            if vl > 0
                float b = (vl + rl.delta()) / 2.0
                float s = (vl - rl.delta()) / 2.0
                lo := math.min(b, s) > vl * tol
    [hi, lo]

// @function Reads absorption at the extremes of the bar: one third of the bar's range
//   holding a large share of the volume with delta pointing against the bar's direction.
//   Aggression that meets size and fails to move price is the signature of a passive
//   participant taking the other side.
// @param fp Footprint object.
// @param s RowStats produced by stats() for the same footprint.
// @param o Open of the bar.
// @param c Close of the bar.
// @param minShare Minimum share of bar volume the third must hold, for example 0.4.
// @returns 1 when sellers were absorbed at the lows of an up bar, -1 when buyers were
//   absorbed at the highs of a down bar, 0 otherwise.
export absorption(footprint fp, RowStats s, float o, float c, float minShare) =>
    int res = 0
    if not na(fp) and not na(s) and s.n > 0 and not na(s.top) and not na(s.bot) and s.top > s.bot
        float third = (s.top - s.bot) / 3.0
        Slice botThird = slice(fp, s.bot, s.bot + third)
        Slice topThird = slice(fp, s.top - third, s.top)
        if c > o and not na(botThird.share) and botThird.share >= minShare and botThird.delta < 0
            res := 1
        else if c < o and not na(topThird.share) and topThird.share >= minShare and topThird.delta > 0
            res := -1
    res

// ═══════════════════════════════════════════════════════════════════════════
//  COMPOSITE PROFILE
// ═══════════════════════════════════════════════════════════════════════════

// @function Creates an empty composite profile. request.footprint() delivers one bar at a
//   time; feeding successive bars into a profile builds the multi-bar picture the single
//   call cannot give on its own.
// @param step Price bucket height. Use the row height from RowStats to keep the composite
//   at the same resolution as the footprint itself.
// @returns An empty Profile object.
export newProfile(float step) =>
    Profile.new(step = step, price = array.new<float>(), vol = array.new<float>(), dlt = array.new<float>())

// @function Folds one bar's rows into the profile. Buckets are keyed by rounded row
//   midpoint and kept sorted, so repeated calls stay ordered and lookups stay cheap.
//   Call once per confirmed bar.
// @param p Profile to update, modified in place.
// @param fp Footprint object for the bar being added.
// @returns Nothing. The profile is mutated.
export method feed(Profile p, footprint fp) =>
    if not na(p) and not na(fp) and not na(p.step) and p.step > 0
        array<volume_row> rows = fp.rows()
        int n = array.size(rows)
        if n > 0
            for i = 0 to n - 1
                volume_row r = array.get(rows, i)
                float mid = (r.up_price() + r.down_price()) / 2.0
                float key = math.round(mid / p.step) * p.step
                int   at  = bsearch(p.price, key)
                if at >= 0
                    array.set(p.vol, at, array.get(p.vol, at) + r.total_volume())
                    array.set(p.dlt, at, array.get(p.dlt, at) + r.delta())
                else
                    int ins = -at - 1
                    array.insert(p.price, ins, key)
                    array.insert(p.vol,   ins, r.total_volume())
                    array.insert(p.dlt,   ins, r.delta())

// @function Total volume held by the profile.
// @param p Profile to read.
// @returns Sum of all bucket volumes, or 0 when the profile is empty.
export method sum(Profile p) =>
    float t = 0.0
    if not na(p) and not na(p.vol)
        int n = array.size(p.vol)
        if n > 0
            for i = 0 to n - 1
                t += array.get(p.vol, i)
    t

// @function Point of control of the composite profile.
// @param p Profile to read.
// @returns Centre price of the heaviest bucket, or na when the profile is empty.
export method poc(Profile p) =>
    float res = na
    if not na(p) and not na(p.vol)
        int n = array.size(p.vol)
        if n > 0
            float mx = -1.0
            for i = 0 to n - 1
                float v = array.get(p.vol, i)
                if v > mx
                    mx  := v
                    res := array.get(p.price, i)
    res

// @function Value area of the composite profile, grown outward from the point of control
//   by repeatedly taking the heavier neighbouring bucket until the requested share of
//   total volume is enclosed.
// @param p Profile to read.
// @param pct Share of total volume to enclose, expressed 0 to 1, for example 0.7.
// @returns A tuple [vaHigh, vaLow] of prices, both na when the profile is empty.
export method valueArea(Profile p, float pct) =>
    float vaH = na
    float vaL = na
    if not na(p) and not na(p.vol)
        int n = array.size(p.vol)
        if n > 0
            float tot = p.sum()
            int   pi  = 0
            float mx  = -1.0
            for i = 0 to n - 1
                float v = array.get(p.vol, i)
                if v > mx
                    mx := v
                    pi := i
            int   up  = pi
            int   dn  = pi
            float acc = mx
            float need = tot * pct
            while acc < need and (up < n - 1 or dn > 0)
                float vUp = up < n - 1 ? array.get(p.vol, up + 1) : -1.0
                float vDn = dn > 0     ? array.get(p.vol, dn - 1) : -1.0
                if vUp >= vDn
                    up  += 1
                    acc += vUp
                else
                    dn  -= 1
                    acc += vDn
            float h = p.step / 2.0
            vaH := array.get(p.price, up) + h
            vaL := array.get(p.price, dn) - h
    [vaH, vaL]

// @function Empties the profile while keeping its bucket size, ready for a new window.
// @param p Profile to clear, modified in place.
// @returns Nothing. The profile is mutated.
export method reset(Profile p) =>
    if not na(p)
        array.clear(p.price)
        array.clear(p.vol)
        array.clear(p.dlt)
````
