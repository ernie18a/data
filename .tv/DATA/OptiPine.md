<!-- tradingview-pine-id: PUB;09c3bfe4dd324c1f9df746c6bf127bdb -->
<!-- tradingviewscripts-format: 1 -->
# OptiPine

Source: https://www.tradingview.com/script/UiiesMWO-OptiPine-High-Performance-Caching-and-Data-Pipelines/

## Description

OptiPine is a high performance architecture library for Pine Script™, built for algorithms that push beyond ordinary indicator workloads. It turns caching, sparse updates, reusable storage and workload-aware data structures into practical APIs that stay small at the call site.

In a small indicator, optimization is often optional. In a rendering engine, machine learning library, simulation, dashboard or object system, it can determine whether a feature runs at all. The problem is rarely one slow formula. It is the thousands of unnecessary operations around it: recalculating unchanged results, shifting rolling arrays, scanning large collections for a few changes, and moving stored objects when one disappears.

OptiPine attacks that layer with techniques used in projects such as [Pine3D](https://www.tradingview.com/script/I2K4hIdP-Pine3D-A-Native-3D-Graphical-Rendering-Engine/) and [NeuraLib](https://www.tradingview.com/script/GewgOj30-NeuraLib-A-Native-AI-and-Deep-Learning-Runtime/). The idea is simple: do less work, move less data, and let the representation follow the workload.

Compared with conventional Pine implementations of the same task, OptiPine's optimized paths commonly ran 15% to 40% faster. Sparse updates and indexed lookups exceeded 90% when the alternative scanned or searched the full collection.

Most users can stay entirely within the high-level API. A Memo cache with several dependencies looks like this:

[pine]
// Pseudocode: trendRegime and volatilityRegime are floats;
// rebuildModel() is a pure calculation.
var op.FloatMemo model = op.floatMemo()

if model.staleOn(trendRegime, volatilityRegime)
    model.store(rebuildModel(trendRegime, volatilityRegime))

float result = model.get()

// Output: rebuildModel() runs once, then only when either regime changes.
[/pine]

Memo owns the previous dependencies, first-run state, validity and cached result. The caller only declares what the result depends on.

----------------------------------------------------------------------------------------------------------------

🔷 DO NOT CALCULATE THE SAME THING TWICE

The fastest expensive calculation is the one that never needed to run. Models, simulations and generated geometry often remain valid across many script executions.

Memo is the direct choice when the cached result is an int, float, bool, string or color. staleOn() checks up to four floats, two integers, one Boolean and one string; store() saves a rebuilt value, and get() returns it.

Many models respond to regimes rather than every tiny change in raw data. Round the inputs into meaningful regimes, pass them to staleOn(), and the model runs only when a regime changes.

In practice: Memo is useful for scenario models, parameter sweeps, numerical solvers and other expensive pure calculations that reduce to one primitive result. If its dependencies repeat on nine out of ten executions, it avoids roughly 90% of those model runs.

For collections or a variable dependency list, use Memo's explicit begin(), dependencies.watch*() and miss() lifecycle.

Keep guarded work pure: Stateful ta.* and similar history-dependent calls must remain outside Memo and Watch guards. Compute them every bar, then pass their results into the guarded calculation.

🔸 WATCH: CHANGE DETECTION WITHOUT RESULT STORAGE

Watch is the lighter choice when the caller already owns the result. Several consumers can observe the same producer independently by giving each its own Watch. changed() returns true on the first observation and whenever one scalar, primitive array or OptiPine row ring changes. Row rings expose an internal revision, so checking them is O(1).

For a single source, the dependency check should take less attention than the calculation it protects. Here another component supplies one caller-owned feature array:

[pine]
// Pseudocode: getFeatureSnapshot() supplies an array<float>.
array<float> features = getFeatureSnapshot()

var op.Watch featureWatch = op.watch()
var float modelScore = na

if featureWatch.changed(features)
    modelScore := evaluateModel(features)

// Output: modelScore is rebuilt only when the features array changes.
[/pine]

Because OptiPine does not own features, it compares the array with a retained snapshot and rewrites that snapshot only after a change. Supported row rings use their internal revision instead. The call stays the same, and this compare-first array pattern measured roughly 35% to 60% faster than rewriting the snapshot every time.

The array comparison is still O(N), so use it when the avoided calculation costs more than the comparison. If the producer already provides one reliable change flag, use the flag directly.

For several dependencies, use an explicit pass. begin() starts the comparison, the typed watch*() methods add dependencies, and finish() returns true if the completed set changed. A Watch remembers dependencies; it does not store the result.

[pine]
// Pseudocode dependencies: int length, float multiplier,
// and array<float> features.
var op.Watch settingsWatch = op.watch()
var float result = na

settingsWatch.begin()
settingsWatch.watchInt(length)
settingsWatch.watchFloat(multiplier)
settingsWatch.watchFloats(features)

bool dependenciesChanged = settingsWatch.finish()
if dependenciesChanged
    result := rebuild(length, multiplier, features)

// Output: result is rebuilt when any observed dependency changes.
[/pine]

Construct the Watch once with var, then run begin() and finish() on every comparison pass. For one dependency, changed(source) is the shorter path.

In practice: Watch fits module boundaries: a model can observe a feature array, a renderer can observe a managed ring, or a cache can observe several mixed settings without duplicating the producer's change logic.

CadenceGate limits how often work may run. due() is periodic; dueWhenChanged() also requires a producer revision and remembers changes until the cadence opens. Use it for intentionally delayed work such as periodic model fitting, not results that must update immediately.

----------------------------------------------------------------------------------------------------------------

🔷 ROLLING HISTORY WITHOUT SHIFTING IT

Rolling histories often perform work that adds nothing to the result. If an array keeps the latest 200 events, removing the oldest one and shifting the other 199 entries is unnecessary.

FloatRowRing and IntRowRing keep fixed-width rows in reusable storage. Once full, the next row overwrites the oldest physical slot while reads remain chronological.

[pine]
var op.FloatRowRing history = op.floatRowRing(200, 3)

float atr14 = ta.atr(14)

if barstate.isconfirmed
    history.push(array.from(close, volume, atr14))

float oldestPrice = history.at(0, 0)
float latestPrice = history.newestAt(0, 0)

// Output: after a confirmed push, these are the oldest and newest retained closes.
[/pine]

A push costs O(width), or O(1) through pushValue() for a width-one ring. Rings also provide chronological windows and gathered rows. When several producers can mutate a ring, a separate consumer can detect its revision with Watch.changed(ring) in O(1).

In practice: Row rings fit pivots, completed trades, sampled features and other fixed event histories.

Performance: A full ring overwrites one row instead of shifting every retained row. Its chronological output uses at most two native contiguous copies, which measured 90% faster than rebuilding a 512-cell, width-four output row by row.

Use RingCursor when several caller-owned arrays need the same circular layout. Ordinary series history such as close[50] should remain native Pine.

----------------------------------------------------------------------------------------------------------------

🔷 KEEP DYNAMIC OBJECTS STABLE

Dynamic objects become surprisingly expensive when identity is tied to array position. If one object is removed from several parallel arrays, every later entry shifts, every synchronized payload array needs the same removal, and every external reference to those positions becomes fragile.

StablePool is not the zone storage itself. It keeps one association: an object ID supplied by the script points to a reusable array slot. The ID answers "which zone is this?" while the slot answers "where is this zone's data stored?"

The example has three different logical zones named A, B and C. Their IDs, 1001, 1002 and 1003, are arbitrary unique values chosen for readability. Real IDs may come from a pivot bar, timestamp, order number or incrementing counter.

[pine]
const int ZONE_A_ID = 1001
const int ZONE_B_ID = 1002
const int ZONE_C_ID = 1003

var op.StablePool zonePool = op.stablePool()

// This example never has more than two active zones.
var array<float> prices = array.new<float>(2, na)

if barstate.isfirst
    // A receives slot 0. B receives slot 1.
    [slotA, _] = zonePool.acquire(ZONE_A_ID)
    [slotB, _] = zonePool.acquire(ZONE_B_ID)
    prices.set(slotA, 100.0)
    prices.set(slotB, 200.0)

    // Zone A no longer exists. Its slot becomes available.
    zonePool.release(ZONE_A_ID)

    // C is a new zone with a new identity, but it can reuse A's old slot.
    [slotC, _] = zonePool.acquire(ZONE_C_ID)
    prices.set(slotC, 300.0)

// Output: B keeps slot 1. C has ID 1003 but reuses A's released slot 0.
//         prices is [300.0, 200.0].
[/pine]

Why C needs a new ID: C is a different zone, even though it occupies the same array position A once used. Reusing 1001 would describe A returning, not a new zone C. IDs preserve object identity; slots are only reusable storage addresses.

Several fields, one slot: In production, the same slot usually addresses every field belonging to the object. Continuing the A, B and C lifecycle with four parallel arrays:

[pine]
const int ZONE_A_ID = 1001
const int ZONE_B_ID = 1002
const int ZONE_C_ID = 1003

var op.StablePool zonePool = op.stablePool()
var array<float> zonePrices = array.new<float>()
var array<int> zoneTimes = array.new<int>()
var array<float> zoneStrengths = array.new<float>()
var array<color> zoneColors = array.new<color>()

if barstate.isfirst
    [slotA, _] = zonePool.acquire(ZONE_A_ID)
    [slotB, _] = zonePool.acquire(ZONE_B_ID)

    // Grow every payload array to cover the allocated slots.
    int required = zonePool.slotCount()
    op.ensureSizeFloat(zonePrices, required, na)
    op.ensureSizeInt(zoneTimes, required, na)
    op.ensureSizeFloat(zoneStrengths, required, na)
    op.ensureSizeColor(zoneColors, required, na)

    zonePrices.set(slotA, 100.0)
    zoneTimes.set(slotA, 10)
    zoneStrengths.set(slotA, 0.40)
    zoneColors.set(slotA, color.blue)

    zonePrices.set(slotB, 200.0)
    zoneTimes.set(slotB, 20)
    zoneStrengths.set(slotB, 0.80)
    zoneColors.set(slotB, color.red)

    zonePool.release(ZONE_A_ID)
    [slotC, _] = zonePool.acquire(ZONE_C_ID)

    // C reuses A's slot, so every field at that slot must be overwritten.
    zonePrices.set(slotC, 300.0)
    zoneTimes.set(slotC, 30)
    zoneStrengths.set(slotC, 0.60)
    zoneColors.set(slotC, color.lime)

// Output: B keeps slot 1 in every array. C owns slot 0 in every array.
//         Nothing is removed or shifted.
[/pine]

acquire(id) returns the slot and whether the ID was newly added. Calling it again for an active ID returns the same slot. release(id) frees the slot, but does not erase its array data, so every field must be overwritten when that slot is reused.

The example preallocates two values because it has at most two active zones. A dynamic script can grow its payload arrays with ensureSize*() whenever acquire() reports a new ID. zonePool.slots() returns the currently active slots as a read-only view.

In practice: One zone slot can index its price, time, color, strength and line across several arrays. In the complete example later, the pivot bar and event type form each zone ID. Releasing one zone frees its slot without shifting other zones or breaking saved positions.

Performance: StablePool is independent of payload layout: its slots can index parallel arrays or one array of UDTs. acquire(), release() and find() are O(1), and releasing an object never shifts caller-owned payloads.

For a few fixed objects, manual indices are simpler. StablePool becomes useful when IDs appear and disappear over time, several payload arrays share the same slots, or other parts of the script retain those positions.

SlotCache is the frame-based alternative. Call begin(), acquire every active key, then call finish(); previously active keys that were not touched are retired automatically.

----------------------------------------------------------------------------------------------------------------

🔷 UPDATE ONLY WHAT CHANGED

Large state does not imply large change. A dashboard may contain 10,000 cells while only a few change on one bar, or a large object system may need to refresh only a handful of entries.

A conventional dirty-flag array must be cleared and scanned in full. DirtySet stores only the changed indices, removes duplicate marks and begins a new cycle without clearing the entire universe. It is a work list, not payload storage or an ID-to-slot map.

Here StablePool resolves zoneId, the arrays store zone data, and DirtySet schedules the slots that need rebuilding. The event values are pseudocode:

[pine]
int MAX_ZONES = 50000

var op.StablePool zones = op.stablePool()
var op.DirtySet dirtySlots = op.dirtySet(MAX_ZONES)

var array<float> tops = array.new<float>()
var array<float> bottoms = array.new<float>()
var array<float> midpoints = array.new<float>()

// Start this bar's sparse-work cycle.
dirtySlots.begin()

if zoneGeometryChanged
    // StablePool converts the logical ID into a reusable physical slot.
    [zoneSlot, created] = zones.acquire(zoneId)
    if created
        op.ensureSizeFloat(tops, zoneSlot + 1, na)
        op.ensureSizeFloat(bottoms, zoneSlot + 1, na)
        op.ensureSizeFloat(midpoints, zoneSlot + 1, na)

    tops.set(zoneSlot, newTop)
    bottoms.set(zoneSlot, newBottom)
    dirtySlots.mark(zoneSlot)

if zoneStyleChanged
    int styleSlot = zones.find(zoneId)
    if styleSlot >= 0
        dirtySlots.mark(styleSlot)  // A second mark of the same slot is ignored.

// Process only the distinct physical slots marked during this bar.
for dirtySlot in dirtySlots.values()
    float midpoint = (tops.get(dirtySlot) + bottoms.get(dirtySlot)) * 0.5
    midpoints.set(dirtySlot, midpoint)
    redrawZone(zones.keyAt(dirtySlot), midpoint)

// Output: one zone is rebuilt once even if geometry and style both mark it.
[/pine]

Repeated marks are deduplicated, and unmarked zones are never visited. Work scales with the number of changed slots, not the size of the collection. If the natural address is already a dense index, mark it directly without StablePool.

In practice: Several producers can mark work, then one consumer updates each affected cell, drawing or record once. With 1% of entries changed, this measured 93% faster than clearing and scanning the full universe.

----------------------------------------------------------------------------------------------------------------

🔷 KEYED LOOKUP WITHOUT GUESSWORK

Keyed lookup appears throughout object systems, caches and grouped data, but no structure fits every key set. Distribution, rebuild frequency and query volume change the best choice. OptiPine sees the completed keys at build(), then selects the lookup shape that fits them.

🔸 TYPED STORES: ONE VALUE PER KEY

A typed store maps each integer key to one primitive value. build() pairs entries at matching positions in the key and value arrays. Consecutive IDs allow direct addressing:

[pine]
var op.IntFloatStore scores = op.intFloatStore()

if barstate.isfirst
    // Four entries are shown for readability; both arrays may be much larger.
    scores.build(
      array.from(410, 411, 412, 413),
      array.from(0.80, 0.30, 0.95, 0.50))

float selected = scores.get(412)

// Output: integer key 412 resolves to float value 0.95.
[/pine]

Lookup is one-way: get(412) returns 0.95, but values may repeat, so get(0.95) has no general meaning.

What automatic mode chooses:

[*]Consecutive ascending keys: Direct arithmetic indexing.
[*]Compact key ranges: A dense lookup table.
[*]Other unordered keys: A native map when within Pine's map limit.
[*]Ascending sparse keys: Binary search, or a map within that limit when expectedQueries justifies its build cost.

Linear lookup remains available for unusual workloads that rebuild far more often than they query. Automatic mode only selects it for non-empty stores when linearMaxEntries is deliberately configured.

The same API avoids hashing when direct addressing fits, uses a map when it pays, and remains usable beyond Pine's map capacity. Automatic mode is the normal default. Use op.indexConfigDynamic() when future query volume is unknown and the store may need to promote itself later.

build(keys, values, expectedQueries) accepts two same-length arrays. The optional hint tells OptiPine how many lookups to expect before the next build. Stores support int, float, bool, string and color values. Use one IntIndex for several payload fields, or IntBuckets when a key owns several integers.

In practice: Batch-build IDs to scores, states or metadata, then query them without committing to a representation. Direct integer addressing measured 21% faster than a map, while a map measured 91% faster than repeated linear lookup with 32 entries.

🔸 INTBUCKETS: ONE KEY TO MANY INTEGER VALUES

A Store returns one value for each key. IntBuckets returns a group of integers, usually object IDs or physical slots. Repeating a key adds another member instead of replacing the previous one.

[pine]
var op.IntBuckets cellMembers = op.intBuckets()
var array<int> matches = array.new<int>()

if barstate.isfirst
    // Six (cell, object slot) pairs. Cell 7 appears three times.
    array<int> cellKeys = array.from(7, 2, 7, 5, 2, 7)
    array<int> objectSlots = array.from(101, 205, 412, 990, 777, 888)

    cellMembers.buildFromPairs(cellKeys, objectSlots)

    // Read cell 7's group from flat storage. matches is only demo output.
    [start, count] = cellMembers.rangeByKey(7)
    if count > 0
        for position = start to start + count - 1
            matches.push(cellMembers.valueAt(position))

// Output: matches contains [101, 412, 888], the object slots assigned to cell 7.
[/pine]

What happens: Each key is paired with the slot at the same array position. Cell 7 appears three times, so its group contains 101, 412 and 888. rangeByKey() returns where that group starts and how many values it contains. A missing key returns a count of 0.

Lifecycle: buildFromPairs() replaces all previous groups. Use buildBegin(), add() and buildFinish() only when pairs arrive one at a time.

In practice: A price cell can own several zone slots, a graph node can own several neighbors, or a category can own several record IDs. One query visits only that group.

Why use it: A native map stores one value per key, and Pine does not allow an array directly as that value. Giving one key several values therefore requires a small wrapper UDT containing an array. IntBuckets provides that relationship directly, packing every group into shared contiguous storage. It suits batch rebuilds followed by repeated traversal, while the wrapper approach is more convenient when individual groups change constantly. In the tested 64-key traversal workload, IntBuckets averaged 19% faster across four runs.

----------------------------------------------------------------------------------------------------------------

🔷 REUSE STATE INSTEAD OF REBUILDING IT

IntDoubleBuffer and FloatDoubleBuffer retain current and previous arrays. swap() exchanges their references in O(1), preserves the old result and clears the new current buffer for reuse. That clear still costs O(N).

This is useful when one pass must remain readable while the next is built. In this small search, node n has children 2n and 2n + 1. Each pass reads the active level and writes the next one:

[pine]
var op.IntDoubleBuffer searchFrontier = op.intDoubleBuffer()

if barstate.isfirst
    searchFrontier.current.push(1)

    for depth = 1 to 3
        [nextFrontier, activeFrontier] = searchFrontier.swap()

        for nodeId in activeFrontier
            nextFrontier.push(nodeId * 2)
            nextFrontier.push(nodeId * 2 + 1)

// Output: current contains [8, 9, 10, 11, 12, 13, 14, 15].
//         previous contains [4, 5, 6, 7].
[/pine]

What happens: swap() makes the completed level available as activeFrontier and returns the other retained array, already empty, as nextFrontier. No level is copied and no replacement array is created. The same pattern supports graph searches, flood fills, iterative clustering and simulations. Use swapSized() when every pass needs a fixed-size output.

A var array can also be reused. The ensureSize*(), resize*() and refill*() families modify existing storage, while sameExact*() compares primitive arrays without Pine's float-comparison rounding.

Revision handles caller-owned state that OptiPine cannot observe. The producer calls bump() after a change; each consumer compares its own saved token with changedSince() instead of keeping a snapshot.

----------------------------------------------------------------------------------------------------------------

🔷 WEIGHTED SELECTION FOR STATIC AND DYNAMIC SYSTEMS

Weighted selection chooses entries in proportion to their weights. It is useful in simulations, randomized search and priority sampling.

WeightedSampler is the high-level interface. Set weights, then supply a fraction to select a slot. The sampler does not generate randomness; use math.random() or a repeatable fraction sequence:

[pine]
var op.WeightedSampler sampler = op.weightedSampler(512)

if barstate.isfirst
    sampler.setWeight(10, 0.25)
    sampler.setWeight(11, 0.80)
    sampler.setWeight(12, 0.10)

float fraction = 0.50
int selected = sampler.sample(fraction)

// Output: selected is 11 for the supplied fraction of 0.50.
[/pine]

The default cumulative prefix suits stable weights. Pass op.weightConfigSparseUpdates() and the sampler can move to an update-friendly Fenwick tree as the workload changes. sample() stays the same. Use WeightedIndex for circular ranges or explicit policy control.

In practice: Each slot can represent a candidate model, simulation outcome or work item. Update its weight when its score changes, then sample repeatedly through the same interface.

----------------------------------------------------------------------------------------------------------------

🔷 THREE LEVELS OF CONTROL

OptiPine is layered so high-level code describes the problem rather than the mechanism. Start with Tier 1 and move deeper only when the workload requires more control:

[*]Tier 1, Quick: Ready-to-use APIs with automatic defaults, including Watch, Memo, CadenceGate, typed stores, StablePool, DirtySet, row rings, double buffers and WeightedSampler.
[*]Tier 2, Composable: Explicit lifecycles, configuration and representation policies through IntIndex, IntBuckets, SlotCache, RingCursor and Revision.
[*]Tier 3, Expert: Physical addressing, unchecked operations and scoped raw mutation for measured hot paths. Ordinary read-only views are not Tier 3.

Editor warnings: Methods such as get(), set(), push() and clear() intentionally match Pine's collection vocabulary. Any shadowing-method warning is cosmetic; the receiver's type determines which method runs.

----------------------------------------------------------------------------------------------------------------

🔷 COMPLETE, COPY-PASTE EXAMPLES

The fragments above isolate one idea at a time. These two copy-paste indicators combine them in practical workflows, using native Pine where it is simpler and OptiPine where it removes real work.

🔸 Complete example 1: high-level cached stress model

What it does: The indicator plots a probability-weighted downside estimate for the current trend and volatility regime, while exposing both regime values in the Data Window.

The EMA and ATR calculations run normally on every bar. Their rounded regimes change less often, so Memo recalculates the 401-scenario model only when one of those regimes changes and serves the cached result between changes.

[pine]
//@version=6
indicator("OptiPine - Cached Regime Stress", overlay = false)

import Alien_Algorithms/OptiPine/1 as op

// Test 401 possible moves, giving more weight to common moves.
// This function is pure: its result depends only on its inputs.
estimateDownside(float trendInAtr, float atrPercent) =>
    float result = na

    if not na(trendInAtr) and not na(atrPercent) and atrPercent > 0
        float weightedDownside = 0.0
        float totalWeight = 0.0

        for scenario = -200 to 200
            float standardShock = scenario / 40.0
            float weight = math.exp(-0.5 * standardShock * standardShock)
            float projectedMove = (trendInAtr + standardShock) * atrPercent
            float downside = math.max(-projectedMove, 0.0)

            weightedDownside += downside * weight
            totalWeight += weight

        result := totalWeight > 0 ? weightedDownside / totalWeight : na

    result

// Stateful Pine calculations stay outside the Memo guard.
float ema20 = ta.ema(close, 20)
float ema50 = ta.ema(close, 50)
float atr14 = ta.atr(14)

float trendInAtr = atr14 > 0 ? (ema20 - ema50) / atr14 : na
float atrPercent = close > 0 ? atr14 / close * 100.0 : na

// Quantization makes the dependencies describe a regime, not every tick.
float trendRegime = math.round(
  math.max(-3.0, math.min(3.0, trendInAtr)) * 10.0) / 10.0
float volatilityRegime = math.round(atrPercent * 4.0) / 4.0

var op.FloatMemo downsideStress = op.floatMemo()

if downsideStress.staleOn(trendRegime, volatilityRegime)
    downsideStress.store(
      estimateDownside(trendRegime, volatilityRegime))

float stress = downsideStress.get()

plot(stress, "Expected downside (%)", color.orange, linewidth = 2)
plot(trendRegime, "Trend regime (ATR units)", display = display.data_window)
plot(volatilityRegime, "Volatility regime (%)", display = display.data_window)
[/pine]

🔸 Complete example 2: advanced zone-cluster engine

What it does: The indicator draws recent pivot levels, thickens those near the current price, plots the strongest price cluster and reports its key statistics in the Data Window.

StablePool preserves drawing slots, the ring tracks retirement order, DirtySet queues redraws, IntBuckets forms price clusters and IntFloatStore looks up their strength.

Relevant benchmarks: These are component results, not a total for this 32-zone indicator. In larger matching workloads, DirtySet saved 93% at 1% dirty and IntBuckets averaged 19% with 64 keys. For typed lookup, direct addressing saved 21% over a map on compact keys, while a map saved 91% over linear search at 32 entries. Automatic mode selects the representation.

StablePool and the ring manage recycling. The script still scans live zones for proximity changes, then DirtySet avoids unnecessary drawing updates.

[pine]
//@version=6
indicator("OptiPine - Zone Cluster Engine", overlay = true, max_lines_count = 100)

import Alien_Algorithms/OptiPine/1 as op

int pivotLength = input.int(5, "Pivot length", minval = 1)
int maxZones = input.int(32, "Maximum zones", minval = 4, maxval = 100)
int bucketTicks = input.int(25, "Cluster size in ticks", minval = 1)
float bucketSize = syminfo.mintick * bucketTicks

// Stateful Pine calculations remain outside every conditional rebuild.
float pivotHigh = ta.pivothigh(high, pivotLength, pivotLength)
float pivotLow = ta.pivotlow(low, pivotLength, pivotLength)
float pivotStrength = math.max(nz(volume[pivotLength], 1.0), 1.0)
float highlightDistance = ta.atr(14)

var op.StablePool zones = op.stablePool()
var op.IntRowRing zoneOrder = op.intRowRing(maxZones, 1)
var op.DirtySet dirtyZones = op.dirtySet(maxZones)

var array<float> zonePrices = array.new<float>(maxZones, na)
var array<float> zoneStrengths = array.new<float>(maxZones, 0.0)
var array<int> zoneTimes = array.new<int>(maxZones, na)
var array<bool> resistance = array.new<bool>(maxZones, false)
var array<bool> highlighted = array.new<bool>(maxZones, false)
var array<line> zoneLines = array.new<line>(maxZones)

var op.IntBuckets zonesByBucket = op.intBuckets()
var op.IntFloatStore strengthByBucket = op.intFloatStore()

// Retained build storage is resized and overwritten, never cleared and repopulated.
var array<int> bucketKeyByPosition = array.new<int>()
var array<int> aggregateKeys = array.new<int>()
var array<float> aggregateStrengths = array.new<float>()
var int strongestBucketKey = na
var float strongestBucketStrength = na
var int strongestZoneCount = 0

dirtyZones.begin()
bool topologyChanged = barstate.isfirst

// Logical pivot IDs receive stable, reusable physical drawing slots.
for event = 0 to 1
    float level = event == 0 ? pivotHigh : pivotLow
    if barstate.isconfirmed and not na(level)
        int pivotBar = bar_index - pivotLength
        int pivotTime = time[pivotLength]
        int zoneId = pivotBar * 2 + event
        int slot = zones.find(zoneId)

        // Only a new logical pivot enters the retirement queue.
        if slot < 0
            if zoneOrder.rowCount() == maxZones
                int oldestId = zoneOrder.at(0, 0)
                zones.release(oldestId)

            [newSlot, _] = zones.acquire(zoneId)
            slot := newSlot
            zoneOrder.pushValue(zoneId)
            zonePrices.set(slot, level)
            zoneStrengths.set(slot, pivotStrength)
            zoneTimes.set(slot, pivotTime)
            resistance.set(slot, event == 0)
            highlighted.set(slot, false)
            dirtyZones.mark(slot)
            topologyChanged := true

// Proximity can mark a newly created slot again; DirtySet still stores it once.
for slot in zones.slots()
    bool isHighlighted = math.abs(close - zonePrices.get(slot)) <= highlightDistance
    if isHighlighted != highlighted.get(slot)
        highlighted.set(slot, isHighlighted)
        dirtyZones.mark(slot)

// Only changed drawings cross the line API boundary.
for slot in dirtyZones.values()
    float level = zonePrices.get(slot)
    color baseColor = resistance.get(slot) ? color.red : color.lime
    line zoneLine = zoneLines.get(slot)

    if na(zoneLine)
        zoneLine := line.new(zoneTimes.get(slot), level, time, level,
          xloc = xloc.bar_time)
        zoneLines.set(slot, zoneLine)

    line.set_xy1(zoneLine, zoneTimes.get(slot), level)
    line.set_xy2(zoneLine, time, level)
    line.set_extend(zoneLine, extend.right)
    line.set_width(zoneLine, highlighted.get(slot) ? 3 : 1)
    line.set_color(zoneLine,
      color.new(baseColor, highlighted.get(slot) ? 0 : 55))

// Rebuild grouped lookup only after the explicit creation event.
if topologyChanged
    array<int> liveSlots = zones.slots()
    int liveCount = liveSlots.size()

    op.resizeInt(bucketKeyByPosition, liveCount, 0)
    if liveCount > 0
        for position = 0 to liveCount - 1
            int slot = liveSlots.get(position)
            int bucketKey = int(math.round(zonePrices.get(slot) / bucketSize))
            bucketKeyByPosition.set(position, bucketKey)

    // Repeated bucket keys accumulate several physical zone slots.
    zonesByBucket.buildFromPairs(bucketKeyByPosition, liveSlots)

    int bucketCount = zonesByBucket.bucketCount()
    op.resizeInt(aggregateKeys, bucketCount, 0)
    op.resizeFloat(aggregateStrengths, bucketCount, 0.0)
    strongestBucketKey := na
    strongestBucketStrength := na
    strongestZoneCount := 0

    if bucketCount > 0
        for bucketSlot = 0 to bucketCount - 1
            int bucketKey = zonesByBucket.keyAt(bucketSlot)
            [start, count] = zonesByBucket.rangeBySlot(bucketSlot)
            float totalStrength = 0.0

            if count > 0
                for position = start to start + count - 1
                    int zoneSlot = zonesByBucket.valueAt(position)
                    totalStrength += zoneStrengths.get(zoneSlot)

            aggregateKeys.set(bucketSlot, bucketKey)
            aggregateStrengths.set(bucketSlot, totalStrength)
            if na(strongestBucketStrength) or totalStrength > strongestBucketStrength
                strongestBucketKey := bucketKey
                strongestBucketStrength := totalStrength
                strongestZoneCount := count

    strengthByBucket.build(aggregateKeys, aggregateStrengths)

// Query the current price cluster directly and display the strongest cluster.
int currentBucketKey = int(math.round(close / bucketSize))
float nearbyStrength = strengthByBucket.get(currentBucketKey, 0.0)

float strongestClusterPrice = na(strongestBucketKey) ?
  na : strongestBucketKey * bucketSize

plot(strongestClusterPrice, "Strongest zone cluster", color.orange,
  linewidth = 2, style = plot.style_stepline)
plot(nearbyStrength, "Strength near current price", display = display.data_window)
plot(strongestBucketStrength, "Strongest cluster strength",
  display = display.data_window)
plot(strongestZoneCount, "Zones in strongest cluster",
  display = display.data_window)
plot(dirtyZones.size(), "Drawings updated", display = display.data_window)
[/pine]

----------------------------------------------------------------------------------------------------------------

🔷 API REFERENCE

This is a compact index of the main public entry points.

🔸 Watch and Memo: changed(source) handles one scalar, primitive array or row ring. For several dependencies, use begin(), watch*() and finish(). Typed Memos add staleOn(), store(), get() and invalidate().

🔸 Revision and Cadence: revision() exposes bump(), current() and changedSince() for manual change tracking. cadenceGate() provides due() and change-aware dueWhenChanged() scheduling.

🔸 Row Rings: floatRowRing() and intRowRing() provide push(), width-one pushValue(), at(), setAt(), newestAt(), chronological() and gather().

🔸 RingCursor: Circular addressing for caller-owned arrays. Use reserve() to advance, physical() and logical() to translate positions, and newest() or oldest() to locate retained rows.

🔸 StablePool: acquire() and release() manage stable key-to-slot assignments. Lookup and traversal use find(), contains(), keyAt(), slots() and size(). Recycled slots retain their caller-owned payload until overwritten.

🔸 SlotCache: Frame-based stable allocation follows begin(), acquire(), finish(). active(), retired() and size() expose its state.

🔸 DirtySet: begin() starts a cycle; mark(), markMany() and markRange() add entries. Read the distinct work list with values() and size().

🔸 Typed Stores: intIntStore(), intFloatStore(), intBoolStore(), intStringStore() and intColorStore() map integer keys to primitive values. Build with build(), then use get(), set(), contains() or getMany().

🔸 IntIndex: A shared integer key-to-slot directory for custom payloads and explicit lookup policy. Build with buildBegin(), add() or addMany() and buildFinish(); query with find(), keyAt() and findMany(). IndexConfig controls representation and duplicate policy.

🔸 IntBuckets: A one-key-to-many-integers index. Build directly with buildFromPairs(), or incrementally with buildBegin(), add() or addMany() and buildFinish(). Read groups with rangeByKey() and valueAt().

🔸 Double Buffers: intDoubleBuffer() and floatDoubleBuffer() retain current and previous arrays. swap() exchanges them; swapSized() also sizes and refills the new current buffer.

🔸 Weighted Sampling: weightedSampler() provides weight updates, sample(), sampleMany(), probability() and total(). It maps caller-supplied fractions; it does not generate randomness. weightedIndex() adds circular ranges and explicit policy control.

🔸 Storage Utilities: ensureSize*(), resize*(), refill*() and sameExact*() handle primitive arrays. Other helpers cover flat/matrix conversion, transposition and bulk ring reads.

----------------------------------------------------------------------------------------------------------------

🔷 WHY OPTIPINE EXISTS

Pine's limits are real, but standard architecture often reaches them long before the idea itself has to. Repeating unchanged calculations, shifting rolling storage, scanning mostly untouched collections and rebuilding state all consume the same execution budget the feature needs to exist.

OptiPine reclaims that budget. Expensive models can run only when their inputs change. Large dashboards can refresh only what moved. Dynamic object systems can grow and recycle storage without reorganizing everything around them. The APIs stay approachable, while the architecture underneath is built for workloads that would normally force a Pine project to scale back.

At large scale, optimization is no longer simply about feature speed. It is the factor that dictates whether an ambitious idea can ship at all.

----------------------------------------------------------------------------------------------------------------

This work is licensed under [(CC BY-NC-SA 4.0)](https://creativecommons.org/licenses/by-nc-sa/4.0/), meaning usage is free for non-commercial purposes given that [Alien_Algorithms](https://www.tradingview.com/u/Alien_Algorithms/) is credited in the description for the underlying software. For commercial use licensing, contact [Alien_Algorithms](https://www.tradingview.com/u/Alien_Algorithms/)

The publication diagram has been rendered natively by [Pine3D](https://www.tradingview.com/script/I2K4hIdP-Pine3D-A-Native-3D-Graphical-Rendering-Engine/).

---

## Source Code

````pine
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0) https://creativecommons.org/licenses/by-nc-sa/4.0/
// For commercial use licensing, contact https://www.tradingview.com/u/Alien_Algorithms/

//@version=6

// @description OptiPine is a high-performance architecture library for Pine Script v6. It
//              provides caching, sparse updates, stable storage, rolling buffers, adaptive
//              keyed lookup and weighted selection for demanding scripts.
//
//              Tier 1, Quick: Watch, Memo, CadenceGate, typed stores, StablePool,
//              DirtySet, row rings, double buffers and WeightedSampler.
//              Tier 2, Composable: IntIndex, IntBuckets, SlotCache, RingCursor, Revision,
//              WeightedIndex, WeightedPrefix and FloatFenwick.
//              Tier 3, Expert: physical addressing, unchecked writes and scoped mutable
//              storage for specialized hot paths.

library("OptiPine", overlay = false)

const int _OP_MAX_ARRAY = 100000
const int _OP_MAX_MAP_PAIRS = 50000

const int _OP_MAX_GENERATION = 2000000000

const int _OP_STATE_EMPTY = 0
const int _OP_STATE_BUILDING = 1
const int _OP_STATE_SEALED = 2

_opSameFloat(float left, float right) =>
    bool leftNa = na(left)
    bool rightNa = na(right)
    leftNa and rightNa or not leftNa and not rightNa and math.sign(left - right) == 0

_opSameInt(int left, int right) =>
    bool leftNa = na(left)
    bool rightNa = na(right)
    leftNa and rightNa or not leftNa and not rightNa and left == right

_opSameString(string left, string right) =>
    bool leftNa = na(left)
    bool rightNa = na(right)
    leftNa and rightNa or not leftNa and not rightNa and left == right

_opSameColor(color left, color right) =>
    bool leftNa = na(left)
    bool rightNa = na(right)
    leftNa and rightNa or not leftNa and not rightNa and left == right

_opSameBoolValue(bool left, bool right) =>
    left == right

_opGrowInt(array<int> values, int targetSize, int fillValue = 0) =>
    int safeSize = math.max(targetSize, 0)
    int deficit = safeSize - values.size()
    if deficit > 0
        for _ = 0 to deficit - 1
            values.push(fillValue)
    values.size()

_opResizeInt(array<int> values, int targetSize, int fillValue = 0) =>
    int safeSize = math.max(targetSize, 0)
    int current = values.size()
    if safeSize > current
        for _ = 0 to safeSize - current - 1
            values.push(fillValue)
    else if safeSize < current
        for _ = 0 to current - safeSize - 1
            values.pop()
    values.size()

_opRefillInt(array<int> values, int targetSize, int fillValue) =>
    int safeSize = _opResizeInt(values, targetSize)
    if safeSize > 0
        values.fill(fillValue)
    safeSize

_opAliasInt(array<int> anchor, array<int> probe) =>
    bool aliased = false
    if not na(anchor) and not na(probe)
        int before = anchor.size()
        if probe.size() < _OP_MAX_ARRAY
            probe.push(0)
            aliased := anchor.size() != before
            probe.pop()
        else
            int tail = probe.pop()
            aliased := anchor.size() != before
            probe.push(tail)
    aliased

_opGrowFloat(array<float> values, int targetSize, float fillValue = 0.0) =>
    int safeSize = math.max(targetSize, 0)
    int deficit = safeSize - values.size()
    if deficit > 0
        for _ = 0 to deficit - 1
            values.push(fillValue)
    values.size()

_opResizeFloat(array<float> values, int targetSize, float fillValue = 0.0) =>
    int safeSize = math.max(targetSize, 0)
    int current = values.size()
    if safeSize > current
        for _ = 0 to safeSize - current - 1
            values.push(fillValue)
    else if safeSize < current
        for _ = 0 to current - safeSize - 1
            values.pop()
    values.size()

_opRefillFloat(array<float> values, int targetSize, float fillValue) =>
    int safeSize = _opResizeFloat(values, targetSize)
    if safeSize > 0
        values.fill(fillValue)
    safeSize

_opAliasFloat(array<float> anchor, array<float> probe) =>
    bool aliased = false
    if not na(anchor) and not na(probe)
        int before = anchor.size()
        if probe.size() < _OP_MAX_ARRAY
            probe.push(0.0)
            aliased := anchor.size() != before
            probe.pop()
        else
            float tail = probe.pop()
            aliased := anchor.size() != before
            probe.push(tail)
    aliased

_opGrowBool(array<bool> values, int targetSize, bool fillValue = false) =>
    int safeSize = math.max(targetSize, 0)
    int deficit = safeSize - values.size()
    if deficit > 0
        for _ = 0 to deficit - 1
            values.push(fillValue)
    values.size()

_opResizeBool(array<bool> values, int targetSize, bool fillValue = false) =>
    int safeSize = math.max(targetSize, 0)
    int current = values.size()
    if safeSize > current
        for _ = 0 to safeSize - current - 1
            values.push(fillValue)
    else if safeSize < current
        for _ = 0 to current - safeSize - 1
            values.pop()
    values.size()

_opRefillBool(array<bool> values, int targetSize, bool fillValue) =>
    int safeSize = _opResizeBool(values, targetSize)
    if safeSize > 0
        values.fill(fillValue)
    safeSize

_opAliasBool(array<bool> anchor, array<bool> probe) =>
    bool aliased = false
    if not na(anchor) and not na(probe)
        int before = anchor.size()
        if probe.size() < _OP_MAX_ARRAY
            probe.push(false)
            aliased := anchor.size() != before
            probe.pop()
        else
            bool tail = probe.pop()
            aliased := anchor.size() != before
            probe.push(tail)
    aliased

_opGrowColor(array<color> values, int targetSize, color fillValue = na) =>
    int safeSize = math.max(targetSize, 0)
    int deficit = safeSize - values.size()
    if deficit > 0
        for _ = 0 to deficit - 1
            values.push(fillValue)
    values.size()

_opResizeColor(array<color> values, int targetSize, color fillValue = na) =>
    int safeSize = math.max(targetSize, 0)
    int current = values.size()
    if safeSize > current
        for _ = 0 to safeSize - current - 1
            values.push(fillValue)
    else if safeSize < current
        for _ = 0 to current - safeSize - 1
            values.pop()
    values.size()

_opRefillColor(array<color> values, int targetSize, color fillValue) =>
    int safeSize = _opResizeColor(values, targetSize)
    if safeSize > 0
        values.fill(fillValue)
    safeSize

_opAliasColor(array<color> anchor, array<color> probe) =>
    bool aliased = false
    if not na(anchor) and not na(probe)
        int before = anchor.size()
        if probe.size() < _OP_MAX_ARRAY
            probe.push(na)
            aliased := anchor.size() != before
            probe.pop()
        else
            color tail = probe.pop()
            aliased := anchor.size() != before
            probe.push(tail)
    aliased

_opGrowString(array<string> values, int targetSize, string fillValue = na) =>
    int safeSize = math.max(targetSize, 0)
    int deficit = safeSize - values.size()
    if deficit > 0
        for _ = 0 to deficit - 1
            values.push(fillValue)
    values.size()

_opResizeString(array<string> values, int targetSize, string fillValue = na) =>
    int safeSize = math.max(targetSize, 0)
    int current = values.size()
    if safeSize > current
        for _ = 0 to safeSize - current - 1
            values.push(fillValue)
    else if safeSize < current
        for _ = 0 to current - safeSize - 1
            values.pop()
    values.size()

_opRefillString(array<string> values, int targetSize, string fillValue) =>
    int safeSize = _opResizeString(values, targetSize)
    if safeSize > 0
        values.fill(fillValue)
    safeSize

_opAliasString(array<string> anchor, array<string> probe) =>
    bool aliased = false
    if not na(anchor) and not na(probe)
        int before = anchor.size()
        if probe.size() < _OP_MAX_ARRAY
            probe.push(na)
            aliased := anchor.size() != before
            probe.pop()
        else
            string tail = probe.pop()
            aliased := anchor.size() != before
            probe.push(tail)
    aliased

_opSnapshotInt(
  array<int> source,
  array<int> output = na,
  string label = "OptiPine.snapshot") =>
    array<int> result = output
    if na(result)
        result := array.new<int>()
        if not na(source)
            result := source.copy()
    else
        if _opAliasInt(source, result)
            runtime.error(label + ": output must not alias the structure's own array.")
        result.clear()
        if not na(source)
            result.concat(source)
    result

_opSnapshotFloat(
  array<float> source,
  array<float> output = na,
  string label = "OptiPine.snapshot") =>
    array<float> result = output
    if na(result)
        result := array.new<float>()
        if not na(source)
            result := source.copy()
    else
        if _opAliasFloat(source, result)
            runtime.error(label + ": output must not alias the structure's own array.")
        result.clear()
        if not na(source)
            result.concat(source)
    result

//@function Grows `values` to at least `minimumSize` by appending `fillValue`.
//          Mutates in place, never shrinks, and preserves every existing
//          element. Tier 2.
//@param values Caller-owned array. Must already exist; a free function cannot
//       create ownership.
//@param minimumSize Lower bound for the resulting size. Values below the
//       current size are a no-op.
//@param fillValue Value appended to every added element.
//@returns The resulting size.
export ensureSizeInt(array<int> values, int minimumSize, int fillValue = 0) =>
    if na(values)
        runtime.error("OptiPine.ensureSizeInt: values cannot be na.")
    if minimumSize > _OP_MAX_ARRAY
        runtime.error("OptiPine.ensureSizeInt: size exceeds the 100,000-element array limit.")
    _opGrowInt(values, minimumSize, fillValue)

//@function Resizes `values` to exactly `size`, preserving retained elements.
//          Appends `fillValue` when growing and pops from the end when
//          shrinking. Mutates in place and retains the allocation. Tier 2.
//@param values Caller-owned array.
//@param size Exact resulting size.
//@param fillValue Value appended to elements added by growth.
//@returns The resulting size.
export resizeInt(array<int> values, int size, int fillValue = 0) =>
    if na(values)
        runtime.error("OptiPine.resizeInt: values cannot be na.")
    if size > _OP_MAX_ARRAY
        runtime.error("OptiPine.resizeInt: size exceeds the 100,000-element array limit.")
    _opResizeInt(values, size, fillValue)

//@function Resizes `values` to exactly `size` and overwrites every element
//          with `fillValue`. Retains the allocation. Tier 2.
//@param values Caller-owned array.
//@param size Exact resulting size.
//@param fillValue Value written to every element.
//@returns The resulting size.
export refillInt(array<int> values, int size, int fillValue = 0) =>
    if na(values)
        runtime.error("OptiPine.refillInt: values cannot be na.")
    if size > _OP_MAX_ARRAY
        runtime.error("OptiPine.refillInt: size exceeds the 100,000-element array limit.")
    _opRefillInt(values, size, fillValue)

//@function Exact element-by-element equality of two int arrays. Tier 2.
//@param left First array. na is treated as empty.
//@param right Second array. na is treated as empty.
//@returns true when both arrays hold exactly the same elements in order.
export sameExactInt(array<int> left, array<int> right) =>
    int leftCount = na(left) ? 0 : left.size()
    int rightCount = na(right) ? 0 : right.size()
    bool equal = leftCount == rightCount
    if equal and leftCount > 0
        int lastIndex = leftCount - 1
        for index = 0 to lastIndex
            if not _opSameInt(left.get(index), right.get(index))
                equal := false
                break
    equal

//@function Grows `values` to at least `minimumSize` by appending `fillValue`.
//          Mutates in place, never shrinks, and preserves every existing
//          element. Tier 2.
//@param values Caller-owned array. Must already exist; a free function cannot
//       create ownership.
//@param minimumSize Lower bound for the resulting size. Values below the
//       current size are a no-op.
//@param fillValue Value appended to every added element.
//@returns The resulting size.
export ensureSizeFloat(array<float> values, int minimumSize, float fillValue = 0.0) =>
    if na(values)
        runtime.error("OptiPine.ensureSizeFloat: values cannot be na.")
    if minimumSize > _OP_MAX_ARRAY
        runtime.error("OptiPine.ensureSizeFloat: size exceeds the 100,000-element array limit.")
    _opGrowFloat(values, minimumSize, fillValue)

//@function Resizes `values` to exactly `size`, preserving retained elements.
//          Appends `fillValue` when growing and pops from the end when
//          shrinking. Mutates in place and retains the allocation. Tier 2.
//@param values Caller-owned array.
//@param size Exact resulting size.
//@param fillValue Value appended to elements added by growth.
//@returns The resulting size.
export resizeFloat(array<float> values, int size, float fillValue = 0.0) =>
    if na(values)
        runtime.error("OptiPine.resizeFloat: values cannot be na.")
    if size > _OP_MAX_ARRAY
        runtime.error("OptiPine.resizeFloat: size exceeds the 100,000-element array limit.")
    _opResizeFloat(values, size, fillValue)

//@function Resizes `values` to exactly `size` and overwrites every element
//          with `fillValue`. Retains the allocation. Tier 2.
//@param values Caller-owned array.
//@param size Exact resulting size.
//@param fillValue Value written to every element.
//@returns The resulting size.
export refillFloat(array<float> values, int size, float fillValue = 0.0) =>
    if na(values)
        runtime.error("OptiPine.refillFloat: values cannot be na.")
    if size > _OP_MAX_ARRAY
        runtime.error("OptiPine.refillFloat: size exceeds the 100,000-element array limit.")
    _opRefillFloat(values, size, fillValue)

//@function Exact element-by-element equality of two float arrays. Tier 2.
//@param left First array. na is treated as empty.
//@param right Second array. na is treated as empty.
//@returns true when both arrays hold exactly the same elements in order.
export sameExactFloat(array<float> left, array<float> right) =>
    int leftCount = na(left) ? 0 : left.size()
    int rightCount = na(right) ? 0 : right.size()
    bool equal = leftCount == rightCount
    if equal and leftCount > 0
        int lastIndex = leftCount - 1
        for index = 0 to lastIndex
            if not _opSameFloat(left.get(index), right.get(index))
                equal := false
                break
    equal

//@function Grows `values` to at least `minimumSize` by appending `fillValue`.
//          Mutates in place, never shrinks, and preserves every existing
//          element. Tier 2.
//@param values Caller-owned array. Must already exist; a free function cannot
//       create ownership.
//@param minimumSize Lower bound for the resulting size. Values below the
//       current size are a no-op.
//@param fillValue Value appended to every added element.
//@returns The resulting size.
export ensureSizeBool(array<bool> values, int minimumSize, bool fillValue = false) =>
    if na(values)
        runtime.error("OptiPine.ensureSizeBool: values cannot be na.")
    if minimumSize > _OP_MAX_ARRAY
        runtime.error("OptiPine.ensureSizeBool: size exceeds the 100,000-element array limit.")
    _opGrowBool(values, minimumSize, fillValue)

//@function Resizes `values` to exactly `size`, preserving retained elements.
//          Appends `fillValue` when growing and pops from the end when
//          shrinking. Mutates in place and retains the allocation. Tier 2.
//@param values Caller-owned array.
//@param size Exact resulting size.
//@param fillValue Value appended to elements added by growth.
//@returns The resulting size.
export resizeBool(array<bool> values, int size, bool fillValue = false) =>
    if na(values)
        runtime.error("OptiPine.resizeBool: values cannot be na.")
    if size > _OP_MAX_ARRAY
        runtime.error("OptiPine.resizeBool: size exceeds the 100,000-element array limit.")
    _opResizeBool(values, size, fillValue)

//@function Resizes `values` to exactly `size` and overwrites every element
//          with `fillValue`. Retains the allocation. Tier 2.
//@param values Caller-owned array.
//@param size Exact resulting size.
//@param fillValue Value written to every element.
//@returns The resulting size.
export refillBool(array<bool> values, int size, bool fillValue = false) =>
    if na(values)
        runtime.error("OptiPine.refillBool: values cannot be na.")
    if size > _OP_MAX_ARRAY
        runtime.error("OptiPine.refillBool: size exceeds the 100,000-element array limit.")
    _opRefillBool(values, size, fillValue)

//@function Exact element-by-element equality of two bool arrays. Tier 2.
//@param left First array. na is treated as empty.
//@param right Second array. na is treated as empty.
//@returns true when both arrays hold exactly the same elements in order.
export sameExactBool(array<bool> left, array<bool> right) =>
    int leftCount = na(left) ? 0 : left.size()
    int rightCount = na(right) ? 0 : right.size()
    bool equal = leftCount == rightCount
    if equal and leftCount > 0
        int lastIndex = leftCount - 1
        for index = 0 to lastIndex
            if not _opSameBoolValue(left.get(index), right.get(index))
                equal := false
                break
    equal

//@function Grows `values` to at least `minimumSize` by appending `fillValue`.
//          Mutates in place, never shrinks, and preserves every existing
//          element. Tier 2.
//@param values Caller-owned array. Must already exist; a free function cannot
//       create ownership.
//@param minimumSize Lower bound for the resulting size. Values below the
//       current size are a no-op.
//@param fillValue Value appended to every added element.
//@returns The resulting size.
export ensureSizeColor(array<color> values, int minimumSize, color fillValue = na) =>
    if na(values)
        runtime.error("OptiPine.ensureSizeColor: values cannot be na.")
    if minimumSize > _OP_MAX_ARRAY
        runtime.error("OptiPine.ensureSizeColor: size exceeds the 100,000-element array limit.")
    _opGrowColor(values, minimumSize, fillValue)

//@function Resizes `values` to exactly `size`, preserving retained elements.
//          Appends `fillValue` when growing and pops from the end when
//          shrinking. Mutates in place and retains the allocation. Tier 2.
//@param values Caller-owned array.
//@param size Exact resulting size.
//@param fillValue Value appended to elements added by growth.
//@returns The resulting size.
export resizeColor(array<color> values, int size, color fillValue = na) =>
    if na(values)
        runtime.error("OptiPine.resizeColor: values cannot be na.")
    if size > _OP_MAX_ARRAY
        runtime.error("OptiPine.resizeColor: size exceeds the 100,000-element array limit.")
    _opResizeColor(values, size, fillValue)

//@function Resizes `values` to exactly `size` and overwrites every element
//          with `fillValue`. Retains the allocation. Tier 2.
//@param values Caller-owned array.
//@param size Exact resulting size.
//@param fillValue Value written to every element.
//@returns The resulting size.
export refillColor(array<color> values, int size, color fillValue = na) =>
    if na(values)
        runtime.error("OptiPine.refillColor: values cannot be na.")
    if size > _OP_MAX_ARRAY
        runtime.error("OptiPine.refillColor: size exceeds the 100,000-element array limit.")
    _opRefillColor(values, size, fillValue)

//@function Exact element-by-element equality of two color arrays. Tier 2.
//@param left First array. na is treated as empty.
//@param right Second array. na is treated as empty.
//@returns true when both arrays hold exactly the same elements in order.
export sameExactColor(array<color> left, array<color> right) =>
    int leftCount = na(left) ? 0 : left.size()
    int rightCount = na(right) ? 0 : right.size()
    bool equal = leftCount == rightCount
    if equal and leftCount > 0
        int lastIndex = leftCount - 1
        for index = 0 to lastIndex
            if not _opSameColor(left.get(index), right.get(index))
                equal := false
                break
    equal

//@function Grows `values` to at least `minimumSize` by appending `fillValue`.
//          Mutates in place, never shrinks, and preserves every existing
//          element. Tier 2.
//@param values Caller-owned array. Must already exist; a free function cannot
//       create ownership.
//@param minimumSize Lower bound for the resulting size. Values below the
//       current size are a no-op.
//@param fillValue Value appended to every added element.
//@returns The resulting size.
export ensureSizeString(array<string> values, int minimumSize, string fillValue = na) =>
    if na(values)
        runtime.error("OptiPine.ensureSizeString: values cannot be na.")
    if minimumSize > _OP_MAX_ARRAY
        runtime.error("OptiPine.ensureSizeString: size exceeds the 100,000-element array limit.")
    _opGrowString(values, minimumSize, fillValue)

//@function Resizes `values` to exactly `size`, preserving retained elements.
//          Appends `fillValue` when growing and pops from the end when
//          shrinking. Mutates in place and retains the allocation. Tier 2.
//@param values Caller-owned array.
//@param size Exact resulting size.
//@param fillValue Value appended to elements added by growth.
//@returns The resulting size.
export resizeString(array<string> values, int size, string fillValue = na) =>
    if na(values)
        runtime.error("OptiPine.resizeString: values cannot be na.")
    if size > _OP_MAX_ARRAY
        runtime.error("OptiPine.resizeString: size exceeds the 100,000-element array limit.")
    _opResizeString(values, size, fillValue)

//@function Resizes `values` to exactly `size` and overwrites every element
//          with `fillValue`. Retains the allocation. Tier 2.
//@param values Caller-owned array.
//@param size Exact resulting size.
//@param fillValue Value written to every element.
//@returns The resulting size.
export refillString(array<string> values, int size, string fillValue = na) =>
    if na(values)
        runtime.error("OptiPine.refillString: values cannot be na.")
    if size > _OP_MAX_ARRAY
        runtime.error("OptiPine.refillString: size exceeds the 100,000-element array limit.")
    _opRefillString(values, size, fillValue)

//@function Exact element-by-element equality of two string arrays. Tier 2.
//@param left First array. na is treated as empty.
//@param right Second array. na is treated as empty.
//@returns true when both arrays hold exactly the same elements in order.
export sameExactString(array<string> left, array<string> right) =>
    int leftCount = na(left) ? 0 : left.size()
    int rightCount = na(right) ? 0 : right.size()
    bool equal = leftCount == rightCount
    if equal and leftCount > 0
        int lastIndex = leftCount - 1
        for index = 0 to lastIndex
            if not _opSameString(left.get(index), right.get(index))
                equal := false
                break
    equal

_opWrapStart(int start, int capacity) =>
    capacity > 0 ? math.max(start, 0) % capacity : 0

_opInCircularRange(int physical, int start, int count, int capacity) =>
    bool inside = false
    if count > 0 and capacity > 0 and physical >= 0 and physical < capacity
        int offset = physical - start
        if offset < 0
            offset += capacity
        inside := offset < count
    inside

_opCircularPhysical(int logicalIndex, int start, int count, int capacity) =>
    logicalIndex >= 0 and logicalIndex < count and capacity > 0 ?
      (start + logicalIndex) % capacity : -1

_opCircularLogical(int physical, int start, int count, int capacity) =>
    int logicalIndex = -1
    if count > 0 and capacity > 0 and physical >= 0 and physical < capacity
        int offset = physical - start
        if offset < 0
            offset += capacity
        if offset < count
            logicalIndex := offset
    logicalIndex

_opNormalizeWeight(float weight, bool naToZero, bool negativeToZero) =>
    float result = weight
    if na(result)
        if not naToZero
            runtime.error("OptiPine.WeightedIndex: na weight rejected by the configured na policy.")
        result := 0.0
    else if math.sign(result) < 0
        if not negativeToZero
            runtime.error("OptiPine.WeightedIndex: negative weight rejected by the configured policy.")
        result := 0.0
    result

_opTransformWeight(float weight, float exponent, bool preserveZeros) =>
    float result = weight
    if exponent != 1.0
        if exponent == 0.0
            result := preserveZeros ? (math.sign(weight) > 0 ? 1.0 : 0.0) : 1.0
        else
            result := math.pow(weight, exponent)
    result

//@variable Maximum elements in one Pine array or matrix.
export const int MAX_ARRAY_ELEMENTS = 100000

//@variable Maximum key-value pairs in one Pine map. A pair counts as two
//          elements toward the 100,000-element collection ceiling.
export const int MAX_MAP_PAIRS = 50000

//@variable Highest generation or revision value before a structure recycles.
export const int MAX_GENERATION = 2000000000

//@type Monotonic invalidation token for state OptiPine cannot observe.
//      Producers call `bump()` after a meaningful state change; consumers store
//      the last observed value and compare with `changedSince()` instead of
//      rescanning the producer.
//      Tier: 2 (Composable) | Stability: Stable
//      Ownership: value semantics; the token holds no collections.
//      Complexity: all operations O(1). No allocation.
//      Limits: wraps to 0 after 2,000,000,000 bumps. A consumer holding a
//      snapshot taken exactly one full wrap earlier would miss the change.
//      That requires 2e9 bumps and is documented rather than guarded.
//@field value Current revision. Always >= 0.
export type Revision
    int value = 0

//@function Creates a revision token.
//@param initialValue Starting revision. Negative values are clamped to 0.
//@returns A new Revision.
export revision(int initialValue = 0) =>
    Revision.new(math.max(nz(initialValue, 0), 0))

//@function Advances the revision.
//@param self Revision receiver.
//@returns The new revision value.
export method bump(Revision self) =>
    self.value := self.value >= _OP_MAX_GENERATION ? 0 : self.value + 1
    self.value

//@function Reads the current revision without changing it.
//@param self Revision receiver.
//@returns The current revision value.
export method current(Revision self) =>
    self.value

//@function Tests a consumer snapshot against the current revision.
//@param self Revision receiver.
//@param snapshot Previously observed value. na always reports stale.
//@returns true when the snapshot is stale.
export method changedSince(Revision self, int snapshot) =>
    na(snapshot) or self.value != snapshot

//@function Assigns an explicit revision value.
//@param self Revision receiver.
//@param value New revision. Negative values are clamped to 0.
//@returns Self for chaining.
export method set(Revision self, int value) =>
    self.value := math.max(nz(value, 0), 0)
    self

//@function Returns the revision to 0.
//@param self Revision receiver.
//@returns Self for chaining.
export method reset(Revision self) =>
    self.value := 0
    self

//@enum How a watched collection treats na elements.
//@field exact na equals na, using OptiPine's exact comparators. Two passes
//        holding na in the same position report no change.
//@field alwaysChanged A collection containing any na element reports changed on
//        every pass. Use this when na means "not computable yet" and a cached
//        result derived from it must never be reused.
//@field reject Raise on the first na element.
export enum NaCollectionPolicy
    exact = "Exact"
    alwaysChanged = "Always changed"
    reject = "Reject"

//@type Remembers whether something changed since it last looked.
//@field intValues Retained int dependency values.
//@field floatValues Retained float dependency values.
//@field stringValues Retained string dependency values.
//@field colorValues Retained color dependency values.
//@field intCursor Position of the next int watch in the current pass.
//@field floatCursor Position of the next float watch in the current pass.
//@field stringCursor Position of the next string watch in the current pass.
//@field colorCursor Position of the next color watch in the current pass.
//@field lastIntCount Int arity of the previous completed pass.
//@field lastFloatCount Float arity of the previous completed pass.
//@field lastStringCount String arity of the previous completed pass.
//@field lastColorCount Color arity of the previous completed pass.
//@field passChanged Change flag for the explicit pass currently in progress.
//@field initialized False until the first `finish()` completes.
//@field quickKind Source type last observed by `changed()`, or 0 when none.
//@field quickInt Baseline for `changed(int)`, and for the row-ring overloads,
//       which store a revision.
//@field quickFloat Baseline for `changed(float)`.
//@field quickBool Baseline for `changed(bool)`.
//@field quickString Baseline for `changed(string)`.
//@field quickColor Baseline for `changed(color)`.
//@field quickInts Snapshot for `changed(array<int>)`.
//@field quickFloats Snapshot for `changed(array<float>)`.
//@field quickBools Snapshot for `changed(array<bool>)`.
//@field quickColors Snapshot for `changed(array<color>)`.
//@field quickStrings Snapshot for `changed(array<string>)`.
export type Watch
    array<int> intValues = na
    array<float> floatValues = na
    array<string> stringValues = na
    array<color> colorValues = na
    int intCursor = 0
    int floatCursor = 0
    int stringCursor = 0
    int colorCursor = 0
    int lastIntCount = 0
    int lastFloatCount = 0
    int lastStringCount = 0
    int lastColorCount = 0
    bool passChanged = true
    bool initialized = false
    array<int> intArrayPrevious = na
    array<int> intArrayCurrent = na
    array<int> intArrayPreviousStarts = na
    array<int> intArrayPreviousLengths = na
    array<int> intArrayStarts = na
    array<int> intArrayLengths = na
    int intArrayCursor = 0
    int intArrayFill = 0
    int lastIntArrayCount = 0
    array<float> floatArrayPrevious = na
    array<float> floatArrayCurrent = na
    array<int> floatArrayPreviousStarts = na
    array<int> floatArrayPreviousLengths = na
    array<int> floatArrayStarts = na
    array<int> floatArrayLengths = na
    int floatArrayCursor = 0
    int floatArrayFill = 0
    int lastFloatArrayCount = 0
    array<bool> boolArrayPrevious = na
    array<bool> boolArrayCurrent = na
    array<int> boolArrayPreviousStarts = na
    array<int> boolArrayPreviousLengths = na
    array<int> boolArrayStarts = na
    array<int> boolArrayLengths = na
    int boolArrayCursor = 0
    int boolArrayFill = 0
    int lastBoolArrayCount = 0
    array<color> colorArrayPrevious = na
    array<color> colorArrayCurrent = na
    array<int> colorArrayPreviousStarts = na
    array<int> colorArrayPreviousLengths = na
    array<int> colorArrayStarts = na
    array<int> colorArrayLengths = na
    int colorArrayCursor = 0
    int colorArrayFill = 0
    int lastColorArrayCount = 0
    array<string> stringArrayPrevious = na
    array<string> stringArrayCurrent = na
    array<int> stringArrayPreviousStarts = na
    array<int> stringArrayPreviousLengths = na
    array<int> stringArrayStarts = na
    array<int> stringArrayLengths = na
    int stringArrayCursor = 0
    int stringArrayFill = 0
    int lastStringArrayCount = 0
    int quickKind = 0
    int quickInt = na
    float quickFloat = na
    bool quickBool = false
    string quickString = na
    color quickColor = na
    array<int> quickInts = na
    array<float> quickFloats = na
    array<bool> quickBools = na
    array<color> quickColors = na
    array<string> quickStrings = na

//@function Creates an exact dependency watch.
//@returns A new Watch with empty retained storage.
export watch() =>
    Watch result = Watch.new()
    result.intValues := array.new<int>()
    result.floatValues := array.new<float>()
    result.stringValues := array.new<string>()
    result.colorValues := array.new<color>()
    result

_opEnsureWatch(Watch self) =>
    if na(self.intValues)
        self.intValues := array.new<int>()
    if na(self.floatValues)
        self.floatValues := array.new<float>()
    if na(self.stringValues)
        self.stringValues := array.new<string>()
    if na(self.colorValues)
        self.colorValues := array.new<color>()
    self

_opEnsureWatchIntArrays(Watch self) =>
    if na(self.intArrayPrevious)
        self.intArrayPrevious := array.new<int>()
        self.intArrayCurrent := array.new<int>()
        self.intArrayPreviousStarts := array.new<int>()
        self.intArrayPreviousLengths := array.new<int>()
        self.intArrayStarts := array.new<int>()
        self.intArrayLengths := array.new<int>()
    self

_opWatchIntArraysBegin(Watch self) =>
    if not na(self.intArrayPrevious)
        self.intArrayCursor := 0
        self.intArrayFill := 0
        self.intArrayStarts.clear()
        self.intArrayLengths.clear()
    self

_opWatchIntArraysFinish(Watch self) =>
    bool arityChanged = false
    if not na(self.intArrayPrevious)
        arityChanged := self.intArrayCursor != self.lastIntArrayCount
        array<int> retiredValues = self.intArrayPrevious
        self.intArrayPrevious := self.intArrayCurrent
        self.intArrayCurrent := retiredValues
        array<int> retiredStarts = self.intArrayPreviousStarts
        self.intArrayPreviousStarts := self.intArrayStarts
        self.intArrayStarts := retiredStarts
        array<int> retiredLengths = self.intArrayPreviousLengths
        self.intArrayPreviousLengths := self.intArrayLengths
        self.intArrayLengths := retiredLengths
    arityChanged

_opWatchIntArraysReset(Watch self) =>
    if not na(self.intArrayPrevious)
        self.intArrayPrevious.clear()
        self.intArrayCurrent.clear()
        self.intArrayPreviousStarts.clear()
        self.intArrayPreviousLengths.clear()
        self.intArrayStarts.clear()
        self.intArrayLengths.clear()
        self.intArrayCursor := 0
        self.intArrayFill := 0
    self

_opEnsureWatchFloatArrays(Watch self) =>
    if na(self.floatArrayPrevious)
        self.floatArrayPrevious := array.new<float>()
        self.floatArrayCurrent := array.new<float>()
        self.floatArrayPreviousStarts := array.new<int>()
        self.floatArrayPreviousLengths := array.new<int>()
        self.floatArrayStarts := array.new<int>()
        self.floatArrayLengths := array.new<int>()
    self

_opWatchFloatArraysBegin(Watch self) =>
    if not na(self.floatArrayPrevious)
        self.floatArrayCursor := 0
        self.floatArrayFill := 0
        self.floatArrayStarts.clear()
        self.floatArrayLengths.clear()
    self

_opWatchFloatArraysFinish(Watch self) =>
    bool arityChanged = false
    if not na(self.floatArrayPrevious)
        arityChanged := self.floatArrayCursor != self.lastFloatArrayCount
        array<float> retiredValues = self.floatArrayPrevious
        self.floatArrayPrevious := self.floatArrayCurrent
        self.floatArrayCurrent := retiredValues
        array<int> retiredStarts = self.floatArrayPreviousStarts
        self.floatArrayPreviousStarts := self.floatArrayStarts
        self.floatArrayStarts := retiredStarts
        array<int> retiredLengths = self.floatArrayPreviousLengths
        self.floatArrayPreviousLengths := self.floatArrayLengths
        self.floatArrayLengths := retiredLengths
    arityChanged

_opWatchFloatArraysReset(Watch self) =>
    if not na(self.floatArrayPrevious)
        self.floatArrayPrevious.clear()
        self.floatArrayCurrent.clear()
        self.floatArrayPreviousStarts.clear()
        self.floatArrayPreviousLengths.clear()
        self.floatArrayStarts.clear()
        self.floatArrayLengths.clear()
        self.floatArrayCursor := 0
        self.floatArrayFill := 0
    self

_opEnsureWatchBoolArrays(Watch self) =>
    if na(self.boolArrayPrevious)
        self.boolArrayPrevious := array.new<bool>()
        self.boolArrayCurrent := array.new<bool>()
        self.boolArrayPreviousStarts := array.new<int>()
        self.boolArrayPreviousLengths := array.new<int>()
        self.boolArrayStarts := array.new<int>()
        self.boolArrayLengths := array.new<int>()
    self

_opWatchBoolArraysBegin(Watch self) =>
    if not na(self.boolArrayPrevious)
        self.boolArrayCursor := 0
        self.boolArrayFill := 0
        self.boolArrayStarts.clear()
        self.boolArrayLengths.clear()
    self

_opWatchBoolArraysFinish(Watch self) =>
    bool arityChanged = false
    if not na(self.boolArrayPrevious)
        arityChanged := self.boolArrayCursor != self.lastBoolArrayCount
        array<bool> retiredValues = self.boolArrayPrevious
        self.boolArrayPrevious := self.boolArrayCurrent
        self.boolArrayCurrent := retiredValues
        array<int> retiredStarts = self.boolArrayPreviousStarts
        self.boolArrayPreviousStarts := self.boolArrayStarts
        self.boolArrayStarts := retiredStarts
        array<int> retiredLengths = self.boolArrayPreviousLengths
        self.boolArrayPreviousLengths := self.boolArrayLengths
        self.boolArrayLengths := retiredLengths
    arityChanged

_opWatchBoolArraysReset(Watch self) =>
    if not na(self.boolArrayPrevious)
        self.boolArrayPrevious.clear()
        self.boolArrayCurrent.clear()
        self.boolArrayPreviousStarts.clear()
        self.boolArrayPreviousLengths.clear()
        self.boolArrayStarts.clear()
        self.boolArrayLengths.clear()
        self.boolArrayCursor := 0
        self.boolArrayFill := 0
    self

_opEnsureWatchColorArrays(Watch self) =>
    if na(self.colorArrayPrevious)
        self.colorArrayPrevious := array.new<color>()
        self.colorArrayCurrent := array.new<color>()
        self.colorArrayPreviousStarts := array.new<int>()
        self.colorArrayPreviousLengths := array.new<int>()
        self.colorArrayStarts := array.new<int>()
        self.colorArrayLengths := array.new<int>()
    self

_opWatchColorArraysBegin(Watch self) =>
    if not na(self.colorArrayPrevious)
        self.colorArrayCursor := 0
        self.colorArrayFill := 0
        self.colorArrayStarts.clear()
        self.colorArrayLengths.clear()
    self

_opWatchColorArraysFinish(Watch self) =>
    bool arityChanged = false
    if not na(self.colorArrayPrevious)
        arityChanged := self.colorArrayCursor != self.lastColorArrayCount
        array<color> retiredValues = self.colorArrayPrevious
        self.colorArrayPrevious := self.colorArrayCurrent
        self.colorArrayCurrent := retiredValues
        array<int> retiredStarts = self.colorArrayPreviousStarts
        self.colorArrayPreviousStarts := self.colorArrayStarts
        self.colorArrayStarts := retiredStarts
        array<int> retiredLengths = self.colorArrayPreviousLengths
        self.colorArrayPreviousLengths := self.colorArrayLengths
        self.colorArrayLengths := retiredLengths
    arityChanged

_opWatchColorArraysReset(Watch self) =>
    if not na(self.colorArrayPrevious)
        self.colorArrayPrevious.clear()
        self.colorArrayCurrent.clear()
        self.colorArrayPreviousStarts.clear()
        self.colorArrayPreviousLengths.clear()
        self.colorArrayStarts.clear()
        self.colorArrayLengths.clear()
        self.colorArrayCursor := 0
        self.colorArrayFill := 0
    self

_opEnsureWatchStringArrays(Watch self) =>
    if na(self.stringArrayPrevious)
        self.stringArrayPrevious := array.new<string>()
        self.stringArrayCurrent := array.new<string>()
        self.stringArrayPreviousStarts := array.new<int>()
        self.stringArrayPreviousLengths := array.new<int>()
        self.stringArrayStarts := array.new<int>()
        self.stringArrayLengths := array.new<int>()
    self

_opWatchStringArraysBegin(Watch self) =>
    if not na(self.stringArrayPrevious)
        self.stringArrayCursor := 0
        self.stringArrayFill := 0
        self.stringArrayStarts.clear()
        self.stringArrayLengths.clear()
    self

_opWatchStringArraysFinish(Watch self) =>
    bool arityChanged = false
    if not na(self.stringArrayPrevious)
        arityChanged := self.stringArrayCursor != self.lastStringArrayCount
        array<string> retiredValues = self.stringArrayPrevious
        self.stringArrayPrevious := self.stringArrayCurrent
        self.stringArrayCurrent := retiredValues
        array<int> retiredStarts = self.stringArrayPreviousStarts
        self.stringArrayPreviousStarts := self.stringArrayStarts
        self.stringArrayStarts := retiredStarts
        array<int> retiredLengths = self.stringArrayPreviousLengths
        self.stringArrayPreviousLengths := self.stringArrayLengths
        self.stringArrayLengths := retiredLengths
    arityChanged

_opWatchStringArraysReset(Watch self) =>
    if not na(self.stringArrayPrevious)
        self.stringArrayPrevious.clear()
        self.stringArrayCurrent.clear()
        self.stringArrayPreviousStarts.clear()
        self.stringArrayPreviousLengths.clear()
        self.stringArrayStarts.clear()
        self.stringArrayLengths.clear()
        self.stringArrayCursor := 0
        self.stringArrayFill := 0
    self

//@function Adds one int collection dependency to the current pass. Tier 2.
//@param self Watch receiver.
//@param values Collection to watch. na is treated as an empty collection.
//@param naPolicy How na elements are treated.
//@returns Self for chaining.
export method watchInts(
  Watch self,
  array<int> values,
  NaCollectionPolicy naPolicy = NaCollectionPolicy.exact) =>
    _opEnsureWatchIntArrays(self)
    int count = na(values) ? 0 : values.size()
    int slot = self.intArrayCursor
    int writeStart = self.intArrayFill
    bool hasPrevious = slot < self.lastIntArrayCount
    int previousStart = 0
    int previousLength = -1
    if hasPrevious
        previousStart := self.intArrayPreviousStarts.get(slot)
        previousLength := self.intArrayPreviousLengths.get(slot)
    bool comparable = hasPrevious and previousLength == count
    if not comparable
        self.passChanged := true
    _opGrowInt(self.intArrayCurrent, writeStart + count)
    array<int> current = self.intArrayCurrent
    array<int> previous = self.intArrayPrevious
    bool sawNa = false
    if count > 0
        for index = 0 to count - 1
            int element = values.get(index)
            if na(element)
                sawNa := true
                if naPolicy == NaCollectionPolicy.reject
                    runtime.error("OptiPine.Watch.watchInts: na element at index " +
                      str.tostring(index) + " is rejected by NaCollectionPolicy.reject.")
            if comparable and not _opSameInt(previous.get(previousStart + index), element)
                comparable := false
                self.passChanged := true
            current.set(writeStart + index, element)
    if sawNa and naPolicy == NaCollectionPolicy.alwaysChanged
        self.passChanged := true
    self.intArrayStarts.push(writeStart)
    self.intArrayLengths.push(count)
    self.intArrayFill := writeStart + count
    self.intArrayCursor := slot + 1
    self

//@function Adds one float collection dependency to the current pass. Tier 2.
//@param self Watch receiver.
//@param values Collection to watch. na is treated as an empty collection.
//@param naPolicy How na elements are treated.
//@returns Self for chaining.
export method watchFloats(
  Watch self,
  array<float> values,
  NaCollectionPolicy naPolicy = NaCollectionPolicy.exact) =>
    _opEnsureWatchFloatArrays(self)
    int count = na(values) ? 0 : values.size()
    int slot = self.floatArrayCursor
    int writeStart = self.floatArrayFill
    bool hasPrevious = slot < self.lastFloatArrayCount
    int previousStart = 0
    int previousLength = -1
    if hasPrevious
        previousStart := self.floatArrayPreviousStarts.get(slot)
        previousLength := self.floatArrayPreviousLengths.get(slot)
    bool comparable = hasPrevious and previousLength == count
    if not comparable
        self.passChanged := true
    _opGrowFloat(self.floatArrayCurrent, writeStart + count)
    array<float> current = self.floatArrayCurrent
    array<float> previous = self.floatArrayPrevious
    bool sawNa = false
    if count > 0
        for index = 0 to count - 1
            float element = values.get(index)
            if na(element)
                sawNa := true
                if naPolicy == NaCollectionPolicy.reject
                    runtime.error("OptiPine.Watch.watchFloats: na element at index " +
                      str.tostring(index) + " is rejected by NaCollectionPolicy.reject.")
            if comparable and not _opSameFloat(previous.get(previousStart + index), element)
                comparable := false
                self.passChanged := true
            current.set(writeStart + index, element)
    if sawNa and naPolicy == NaCollectionPolicy.alwaysChanged
        self.passChanged := true
    self.floatArrayStarts.push(writeStart)
    self.floatArrayLengths.push(count)
    self.floatArrayFill := writeStart + count
    self.floatArrayCursor := slot + 1
    self

//@function Adds one color collection dependency to the current pass. Tier 2.
//@param self Watch receiver.
//@param values Collection to watch. na is treated as an empty collection.
//@param naPolicy How na elements are treated.
//@returns Self for chaining.
export method watchColors(
  Watch self,
  array<color> values,
  NaCollectionPolicy naPolicy = NaCollectionPolicy.exact) =>
    _opEnsureWatchColorArrays(self)
    int count = na(values) ? 0 : values.size()
    int slot = self.colorArrayCursor
    int writeStart = self.colorArrayFill
    bool hasPrevious = slot < self.lastColorArrayCount
    int previousStart = 0
    int previousLength = -1
    if hasPrevious
        previousStart := self.colorArrayPreviousStarts.get(slot)
        previousLength := self.colorArrayPreviousLengths.get(slot)
    bool comparable = hasPrevious and previousLength == count
    if not comparable
        self.passChanged := true
    _opGrowColor(self.colorArrayCurrent, writeStart + count)
    array<color> current = self.colorArrayCurrent
    array<color> previous = self.colorArrayPrevious
    bool sawNa = false
    if count > 0
        for index = 0 to count - 1
            color element = values.get(index)
            if na(element)
                sawNa := true
                if naPolicy == NaCollectionPolicy.reject
                    runtime.error("OptiPine.Watch.watchColors: na element at index " +
                      str.tostring(index) + " is rejected by NaCollectionPolicy.reject.")
            if comparable and not _opSameColor(previous.get(previousStart + index), element)
                comparable := false
                self.passChanged := true
            current.set(writeStart + index, element)
    if sawNa and naPolicy == NaCollectionPolicy.alwaysChanged
        self.passChanged := true
    self.colorArrayStarts.push(writeStart)
    self.colorArrayLengths.push(count)
    self.colorArrayFill := writeStart + count
    self.colorArrayCursor := slot + 1
    self

//@function Adds one string collection dependency to the current pass. Tier 2.
//@param self Watch receiver.
//@param values Collection to watch. na is treated as an empty collection.
//@param naPolicy How na elements are treated.
//@returns Self for chaining.
export method watchStrings(
  Watch self,
  array<string> values,
  NaCollectionPolicy naPolicy = NaCollectionPolicy.exact) =>
    _opEnsureWatchStringArrays(self)
    int count = na(values) ? 0 : values.size()
    int slot = self.stringArrayCursor
    int writeStart = self.stringArrayFill
    bool hasPrevious = slot < self.lastStringArrayCount
    int previousStart = 0
    int previousLength = -1
    if hasPrevious
        previousStart := self.stringArrayPreviousStarts.get(slot)
        previousLength := self.stringArrayPreviousLengths.get(slot)
    bool comparable = hasPrevious and previousLength == count
    if not comparable
        self.passChanged := true
    _opGrowString(self.stringArrayCurrent, writeStart + count)
    array<string> current = self.stringArrayCurrent
    array<string> previous = self.stringArrayPrevious
    bool sawNa = false
    if count > 0
        for index = 0 to count - 1
            string element = values.get(index)
            if na(element)
                sawNa := true
                if naPolicy == NaCollectionPolicy.reject
                    runtime.error("OptiPine.Watch.watchStrings: na element at index " +
                      str.tostring(index) + " is rejected by NaCollectionPolicy.reject.")
            if comparable and not _opSameString(previous.get(previousStart + index), element)
                comparable := false
                self.passChanged := true
            current.set(writeStart + index, element)
    if sawNa and naPolicy == NaCollectionPolicy.alwaysChanged
        self.passChanged := true
    self.stringArrayStarts.push(writeStart)
    self.stringArrayLengths.push(count)
    self.stringArrayFill := writeStart + count
    self.stringArrayCursor := slot + 1
    self

//@function Adds one bool collection dependency to the current pass. Tier 2.
//@param self Watch receiver.
//@param values Collection to watch. na is treated as an empty collection.
//@returns Self for chaining.
export method watchBools(Watch self, array<bool> values) =>
    _opEnsureWatchBoolArrays(self)
    int count = na(values) ? 0 : values.size()
    int slot = self.boolArrayCursor
    int writeStart = self.boolArrayFill
    bool hasPrevious = slot < self.lastBoolArrayCount
    int previousStart = 0
    int previousLength = -1
    if hasPrevious
        previousStart := self.boolArrayPreviousStarts.get(slot)
        previousLength := self.boolArrayPreviousLengths.get(slot)
    bool comparable = hasPrevious and previousLength == count
    if not comparable
        self.passChanged := true
    _opGrowBool(self.boolArrayCurrent, writeStart + count)
    array<bool> current = self.boolArrayCurrent
    array<bool> previous = self.boolArrayPrevious
    if count > 0
        for index = 0 to count - 1
            bool element = values.get(index)
            if comparable and previous.get(previousStart + index) != element
                comparable := false
                self.passChanged := true
            current.set(writeStart + index, element)
    self.boolArrayStarts.push(writeStart)
    self.boolArrayLengths.push(count)
    self.boolArrayFill := writeStart + count
    self.boolArrayCursor := slot + 1
    self

//@function Starts one dependency comparison pass.
//@param self Watch receiver.
//@returns Self for chaining.
export method begin(Watch self) =>
    _opEnsureWatch(self)
    self.intCursor := 0
    self.floatCursor := 0
    self.stringCursor := 0
    self.colorCursor := 0
    _opWatchIntArraysBegin(self)
    _opWatchFloatArraysBegin(self)
    _opWatchBoolArraysBegin(self)
    _opWatchColorArraysBegin(self)
    _opWatchStringArraysBegin(self)
    self.passChanged := not self.initialized
    self

//@function Adds one integer dependency to the current pass.
//@param self Watch receiver.
//@param value Dependency value.
//@returns Self for chaining.
export method watchInt(Watch self, int value) =>
    int position = self.intCursor
    if position >= self.intValues.size()
        self.intValues.push(value)
        self.passChanged := true
    else if not _opSameInt(self.intValues.get(position), value)
        self.intValues.set(position, value)
        self.passChanged := true
    self.intCursor += 1
    self

//@function Adds one Boolean dependency, stored as 0 or 1.
//          Pine v6 booleans are never na, so no na branch is needed here.
//@param self Watch receiver.
//@param value Dependency value.
//@returns Self for chaining.
export method watchBool(Watch self, bool value) =>
    self.watchInt(value ? 1 : 0)

//@function Adds one float dependency using exact na-aware equality.
//@param self Watch receiver.
//@param value Dependency value.
//@returns Self for chaining.
export method watchFloat(Watch self, float value) =>
    int position = self.floatCursor
    if position >= self.floatValues.size()
        self.floatValues.push(value)
        self.passChanged := true
    else if not _opSameFloat(self.floatValues.get(position), value)
        self.floatValues.set(position, value)
        self.passChanged := true
    self.floatCursor += 1
    self

//@function Adds one string dependency using exact na-aware equality.
//@param self Watch receiver.
//@param value Dependency value.
//@returns Self for chaining.
export method watchString(Watch self, string value) =>
    int position = self.stringCursor
    if position >= self.stringValues.size()
        self.stringValues.push(value)
        self.passChanged := true
    else if not _opSameString(self.stringValues.get(position), value)
        self.stringValues.set(position, value)
        self.passChanged := true
    self.stringCursor += 1
    self

//@function Adds one color dependency using exact na-aware equality.
//@param self Watch receiver.
//@param value Dependency value.
//@returns Self for chaining.
export method watchColor(Watch self, color value) =>
    int position = self.colorCursor
    if position >= self.colorValues.size()
        self.colorValues.push(value)
        self.passChanged := true
    else if not _opSameColor(self.colorValues.get(position), value)
        self.colorValues.set(position, value)
        self.passChanged := true
    self.colorCursor += 1
    self

//@function Completes the pass.
//@param self Watch receiver.
//@returns true when any dependency changed, when the dependency arity changed,
//         when this is the first pass, or when `invalidate()` was called.
export method finish(Watch self) =>
    if self.intCursor != self.lastIntCount or self.floatCursor != self.lastFloatCount or
      self.stringCursor != self.lastStringCount or self.colorCursor != self.lastColorCount
        self.passChanged := true
    bool intArrays = _opWatchIntArraysFinish(self)
    bool floatArrays = _opWatchFloatArraysFinish(self)
    bool boolArrays = _opWatchBoolArraysFinish(self)
    bool colorArrays = _opWatchColorArraysFinish(self)
    bool stringArrays = _opWatchStringArraysFinish(self)
    if intArrays or floatArrays or boolArrays or colorArrays or stringArrays
        self.passChanged := true
    self.lastIntArrayCount := self.intArrayCursor
    self.lastFloatArrayCount := self.floatArrayCursor
    self.lastBoolArrayCount := self.boolArrayCursor
    self.lastColorArrayCount := self.colorArrayCursor
    self.lastStringArrayCount := self.stringArrayCursor
    self.lastIntCount := self.intCursor
    self.lastFloatCount := self.floatCursor
    self.lastStringCount := self.stringCursor
    self.lastColorCount := self.colorCursor
    self.initialized := true
    self.passChanged

//@function Forces the next observation to report a change, whichever API the
//          caller uses.
//@param self Watch receiver.
//@returns Self for chaining.
export method invalidate(Watch self) =>
    self.initialized := false
    self.passChanged := true
    self.quickKind := 0
    self

//@function Reports whether the pass in progress has already seen a change.
//@param self Watch receiver.
//@returns The current pass change flag.
export method isChanged(Watch self) =>
    self.passChanged

//@function Discards every stored dependency value and arity, retaining the
//          array allocations. The next observation reports a change, through
//          either `finish()` or any `changed()` overload.
//@param self Watch receiver.
//@returns Self for chaining.
export method reset(Watch self) =>
    _opEnsureWatch(self)
    self.intValues.clear()
    self.floatValues.clear()
    self.stringValues.clear()
    self.colorValues.clear()
    self.intCursor := 0
    self.floatCursor := 0
    self.stringCursor := 0
    self.colorCursor := 0
    self.lastIntCount := 0
    self.lastFloatCount := 0
    self.lastStringCount := 0
    self.lastColorCount := 0
    _opWatchIntArraysReset(self)
    _opWatchFloatArraysReset(self)
    _opWatchBoolArraysReset(self)
    _opWatchColorArraysReset(self)
    _opWatchStringArraysReset(self)
    self.lastIntArrayCount := 0
    self.lastFloatArrayCount := 0
    self.lastBoolArrayCount := 0
    self.lastColorArrayCount := 0
    self.lastStringArrayCount := 0
    self.passChanged := true
    self.initialized := false
    self.quickKind := 0
    self

//@function Total number of dependencies recorded by the last completed pass.
//@param self Watch receiver.
//@returns The summed arity across every scalar type plus every watched
//         collection. One collection counts as one dependency regardless of
//         how many elements it holds.
export method arity(Watch self) =>
    self.lastIntCount + self.lastFloatCount + self.lastStringCount + self.lastColorCount +
      self.lastIntArrayCount + self.lastFloatArrayCount + self.lastBoolArrayCount +
      self.lastColorArrayCount + self.lastStringArrayCount

//@function Reports whether this int differs from the one last observed, and
//          adopts it as the new baseline. Tier 1.
//          Complexity: O(1). No allocation.
//@param self Watch receiver.
//@param value The value to observe.
//@returns true on the first observation and whenever `value` differs exactly
//         from the previously observed one.
export method changed(Watch self, int value) =>
    bool result = self.quickKind != 1 or not _opSameInt(self.quickInt, value)
    if result
        self.quickKind := 1
        self.quickInt := value
    result

//@function Reports whether this float differs from the one last observed, and
//          adopts it as the new baseline. Tier 1.
//          Complexity: O(1). No allocation.
//@param self Watch receiver.
//@param value The value to observe.
//@returns true on the first observation and whenever `value` differs exactly
//         from the previously observed one.
export method changed(Watch self, float value) =>
    bool result = self.quickKind != 2 or not _opSameFloat(self.quickFloat, value)
    if result
        self.quickKind := 2
        self.quickFloat := value
    result

//@function Reports whether this bool differs from the one last observed, and
//          adopts it as the new baseline. Tier 1.
//          Complexity: O(1). No allocation.
//@param self Watch receiver.
//@param value The value to observe.
//@returns true on the first observation and whenever `value` differs exactly
//         from the previously observed one.
export method changed(Watch self, bool value) =>
    bool result = self.quickKind != 3 or not _opSameBoolValue(self.quickBool, value)
    if result
        self.quickKind := 3
        self.quickBool := value
    result

//@function Reports whether this string differs from the one last observed, and
//          adopts it as the new baseline. Tier 1.
//          Complexity: O(1). No allocation.
//@param self Watch receiver.
//@param value The value to observe.
//@returns true on the first observation and whenever `value` differs exactly
//         from the previously observed one.
export method changed(Watch self, string value) =>
    bool result = self.quickKind != 4 or not _opSameString(self.quickString, value)
    if result
        self.quickKind := 4
        self.quickString := value
    result

//@function Reports whether this color differs from the one last observed, and
//          adopts it as the new baseline. Tier 1.
//          Complexity: O(1). No allocation.
//@param self Watch receiver.
//@param value The value to observe.
//@returns true on the first observation and whenever `value` differs exactly
//         from the previously observed one.
export method changed(Watch self, color value) =>
    bool result = self.quickKind != 5 or not _opSameColor(self.quickColor, value)
    if result
        self.quickKind := 5
        self.quickColor := value
    result

//@function Reports whether this int collection differs from the one last
//          observed, and adopts it as the new baseline. Tier 1.
//          Complexity: O(N) to compare. The O(N) copy is paid only on the
//          passes that report a change, so a steady collection costs one
//          comparison per bar and no writes.
//@param self Watch receiver.
//@param values The collection to observe. na is treated as empty.
//@returns true on the first observation and whenever the contents differ.
export method changed(Watch self, array<int> values) =>
    if na(self.quickInts)
        self.quickInts := array.new<int>()
    array<int> snapshot = self.quickInts
    bool result = self.quickKind != 6 or not sameExactInt(snapshot, values)
    if result
        self.quickKind := 6
        snapshot.clear()
        if not na(values)
            snapshot.concat(values)
    result

//@function Reports whether this float collection differs from the one last
//          observed, and adopts it as the new baseline. Tier 1.
//          Complexity: O(N) to compare. The O(N) copy is paid only on the
//          passes that report a change, so a steady collection costs one
//          comparison per bar and no writes.
//@param self Watch receiver.
//@param values The collection to observe. na is treated as empty.
//@returns true on the first observation and whenever the contents differ.
export method changed(Watch self, array<float> values) =>
    if na(self.quickFloats)
        self.quickFloats := array.new<float>()
    array<float> snapshot = self.quickFloats
    bool result = self.quickKind != 7 or not sameExactFloat(snapshot, values)
    if result
        self.quickKind := 7
        snapshot.clear()
        if not na(values)
            snapshot.concat(values)
    result

//@function Reports whether this bool collection differs from the one last
//          observed, and adopts it as the new baseline. Tier 1.
//          Complexity: O(N) to compare. The O(N) copy is paid only on the
//          passes that report a change, so a steady collection costs one
//          comparison per bar and no writes.
//@param self Watch receiver.
//@param values The collection to observe. na is treated as empty.
//@returns true on the first observation and whenever the contents differ.
export method changed(Watch self, array<bool> values) =>
    if na(self.quickBools)
        self.quickBools := array.new<bool>()
    array<bool> snapshot = self.quickBools
    bool result = self.quickKind != 8 or not sameExactBool(snapshot, values)
    if result
        self.quickKind := 8
        snapshot.clear()
        if not na(values)
            snapshot.concat(values)
    result

//@function Reports whether this color collection differs from the one last
//          observed, and adopts it as the new baseline. Tier 1.
//          Complexity: O(N) to compare. The O(N) copy is paid only on the
//          passes that report a change, so a steady collection costs one
//          comparison per bar and no writes.
//@param self Watch receiver.
//@param values The collection to observe. na is treated as empty.
//@returns true on the first observation and whenever the contents differ.
export method changed(Watch self, array<color> values) =>
    if na(self.quickColors)
        self.quickColors := array.new<color>()
    array<color> snapshot = self.quickColors
    bool result = self.quickKind != 9 or not sameExactColor(snapshot, values)
    if result
        self.quickKind := 9
        snapshot.clear()
        if not na(values)
            snapshot.concat(values)
    result

//@function Reports whether this string collection differs from the one last
//          observed, and adopts it as the new baseline. Tier 1.
//          Complexity: O(N) to compare. The O(N) copy is paid only on the
//          passes that report a change, so a steady collection costs one
//          comparison per bar and no writes.
//@param self Watch receiver.
//@param values The collection to observe. na is treated as empty.
//@returns true on the first observation and whenever the contents differ.
export method changed(Watch self, array<string> values) =>
    if na(self.quickStrings)
        self.quickStrings := array.new<string>()
    array<string> snapshot = self.quickStrings
    bool result = self.quickKind != 10 or not sameExactString(snapshot, values)
    if result
        self.quickKind := 10
        snapshot.clear()
        if not na(values)
            snapshot.concat(values)
    result

//@type One cached int plus an exact dependency Watch.
//      Tier: 1 through `staleOn()`; Tier 2 through the owned dependency Watch.
//      Stability: Stable
//      Ownership: owns its Watch. `get()` returns a value, never a reference.
//      Complexity: O(number of dependencies) per pass.
//      Empty value: na. Use `isValid()` to distinguish an empty memo from
//      a stored value equal to the empty value.
//@field dependencies Owned dependency watch.
//@field value Last stored value.
//@field valid False until the first `store()`.
export type IntMemo
    Watch dependencies = na
    int value = na
    bool valid = false

//@function Creates a memoized int holder.
//@returns A new IntMemo.
export intMemo() =>
    IntMemo result = IntMemo.new()
    result.dependencies := watch()
    result

_opEnsureIntMemo(IntMemo self) =>
    if na(self.dependencies)
        self.dependencies := watch()
    self

//@function Starts an explicit dependency pass. Tier 2.
//@param self IntMemo receiver.
//@returns Self for chaining.
export method begin(IntMemo self) =>
    _opEnsureIntMemo(self)
    self.dependencies.begin()
    self

//@function Completes an explicit pass. Tier 2.
//@param self IntMemo receiver.
//@returns true when the value must be recomputed.
export method miss(IntMemo self) =>
    self.dependencies.finish() or not self.valid

//@function One-call dependency check. Tier 1.
//          The watched arity is fixed at eight slots regardless of how many
//          arguments are supplied, so omitting trailing arguments does not
//          register as a dependency change.
//@param self IntMemo receiver.
//@param firstValue First float dependency.
//@param secondValue Second float dependency.
//@param thirdValue Third float dependency.
//@param fourthValue Fourth float dependency.
//@param firstKey First integer dependency.
//@param secondKey Second integer dependency.
//@param flag Boolean dependency. Defaults to false.
//@param tag String dependency.
//@returns true when the value must be recomputed.
export method staleOn(
  IntMemo self,
  float firstValue = na,
  float secondValue = na,
  float thirdValue = na,
  float fourthValue = na,
  int firstKey = na,
  int secondKey = na,
  bool flag = false,
  string tag = na) =>
    _opEnsureIntMemo(self)
    Watch dependencies = self.dependencies
    dependencies.begin()
    dependencies.watchFloat(firstValue)
    dependencies.watchFloat(secondValue)
    dependencies.watchFloat(thirdValue)
    dependencies.watchFloat(fourthValue)
    dependencies.watchInt(firstKey)
    dependencies.watchInt(secondKey)
    dependencies.watchBool(flag)
    dependencies.watchString(tag)
    dependencies.finish() or not self.valid

//@function Stores a recomputed value and marks the memo valid.
//@param self IntMemo receiver.
//@param value Value to cache.
//@returns Self for chaining.
export method store(IntMemo self, int value) =>
    self.value := value
    self.valid := true
    self

//@function Reads the cached value.
//@param self IntMemo receiver.
//@param fallback Returned before the first `store()`. Defaults to na.
//@returns The cached value, or `fallback`.
export method get(IntMemo self, int fallback = na) =>
    self.valid ? self.value : fallback

//@function Reports whether a value has been stored.
//@param self IntMemo receiver.
//@returns true once `store()` has been called and not invalidated since.
export method isValid(IntMemo self) =>
    self.valid

//@function Discards the cached value and forces the next check to miss.
//@param self IntMemo receiver.
//@returns Self for chaining.
export method invalidate(IntMemo self) =>
    _opEnsureIntMemo(self)
    self.dependencies.invalidate()
    self.valid := false
    self

//@type One cached float plus an exact dependency Watch.
//      Tier: 1 through `staleOn()`; Tier 2 through the owned dependency Watch.
//      Stability: Stable
//      Ownership: owns its Watch. `get()` returns a value, never a reference.
//      Complexity: O(number of dependencies) per pass.
//      Empty value: na. Use `isValid()` to distinguish an empty memo from
//      a stored value equal to the empty value.
//@field dependencies Owned dependency watch.
//@field value Last stored value.
//@field valid False until the first `store()`.
export type FloatMemo
    Watch dependencies = na
    float value = na
    bool valid = false

//@function Creates a memoized float holder.
//@returns A new FloatMemo.
export floatMemo() =>
    FloatMemo result = FloatMemo.new()
    result.dependencies := watch()
    result

_opEnsureFloatMemo(FloatMemo self) =>
    if na(self.dependencies)
        self.dependencies := watch()
    self

//@function Starts an explicit dependency pass. Tier 2.
//@param self FloatMemo receiver.
//@returns Self for chaining.
export method begin(FloatMemo self) =>
    _opEnsureFloatMemo(self)
    self.dependencies.begin()
    self

//@function Completes an explicit pass. Tier 2.
//@param self FloatMemo receiver.
//@returns true when the value must be recomputed.
export method miss(FloatMemo self) =>
    self.dependencies.finish() or not self.valid

//@function One-call dependency check. Tier 1.
//          The watched arity is fixed at eight slots regardless of how many
//          arguments are supplied, so omitting trailing arguments does not
//          register as a dependency change.
//@param self FloatMemo receiver.
//@param firstValue First float dependency.
//@param secondValue Second float dependency.
//@param thirdValue Third float dependency.
//@param fourthValue Fourth float dependency.
//@param firstKey First integer dependency.
//@param secondKey Second integer dependency.
//@param flag Boolean dependency. Defaults to false.
//@param tag String dependency.
//@returns true when the value must be recomputed.
export method staleOn(
  FloatMemo self,
  float firstValue = na,
  float secondValue = na,
  float thirdValue = na,
  float fourthValue = na,
  int firstKey = na,
  int secondKey = na,
  bool flag = false,
  string tag = na) =>
    _opEnsureFloatMemo(self)
    Watch dependencies = self.dependencies
    dependencies.begin()
    dependencies.watchFloat(firstValue)
    dependencies.watchFloat(secondValue)
    dependencies.watchFloat(thirdValue)
    dependencies.watchFloat(fourthValue)
    dependencies.watchInt(firstKey)
    dependencies.watchInt(secondKey)
    dependencies.watchBool(flag)
    dependencies.watchString(tag)
    dependencies.finish() or not self.valid

//@function Stores a recomputed value and marks the memo valid.
//@param self FloatMemo receiver.
//@param value Value to cache.
//@returns Self for chaining.
export method store(FloatMemo self, float value) =>
    self.value := value
    self.valid := true
    self

//@function Reads the cached value.
//@param self FloatMemo receiver.
//@param fallback Returned before the first `store()`. Defaults to na.
//@returns The cached value, or `fallback`.
export method get(FloatMemo self, float fallback = na) =>
    self.valid ? self.value : fallback

//@function Reports whether a value has been stored.
//@param self FloatMemo receiver.
//@returns true once `store()` has been called and not invalidated since.
export method isValid(FloatMemo self) =>
    self.valid

//@function Discards the cached value and forces the next check to miss.
//@param self FloatMemo receiver.
//@returns Self for chaining.
export method invalidate(FloatMemo self) =>
    _opEnsureFloatMemo(self)
    self.dependencies.invalidate()
    self.valid := false
    self

//@type One cached bool plus an exact dependency Watch.
//      Tier: 1 through `staleOn()`; Tier 2 through the owned dependency Watch.
//      Stability: Stable
//      Ownership: owns its Watch. `get()` returns a value, never a reference.
//      Complexity: O(number of dependencies) per pass.
//      Empty value: false. Use `isValid()` to distinguish an empty memo from
//      a stored value equal to the empty value.
//@field dependencies Owned dependency watch.
//@field value Last stored value.
//@field valid False until the first `store()`.
export type BoolMemo
    Watch dependencies = na
    bool value = false
    bool valid = false

//@function Creates a memoized bool holder.
//@returns A new BoolMemo.
export boolMemo() =>
    BoolMemo result = BoolMemo.new()
    result.dependencies := watch()
    result

_opEnsureBoolMemo(BoolMemo self) =>
    if na(self.dependencies)
        self.dependencies := watch()
    self

//@function Starts an explicit dependency pass. Tier 2.
//@param self BoolMemo receiver.
//@returns Self for chaining.
export method begin(BoolMemo self) =>
    _opEnsureBoolMemo(self)
    self.dependencies.begin()
    self

//@function Completes an explicit pass. Tier 2.
//@param self BoolMemo receiver.
//@returns true when the value must be recomputed.
export method miss(BoolMemo self) =>
    self.dependencies.finish() or not self.valid

//@function One-call dependency check. Tier 1.
//          The watched arity is fixed at eight slots regardless of how many
//          arguments are supplied, so omitting trailing arguments does not
//          register as a dependency change.
//@param self BoolMemo receiver.
//@param firstValue First float dependency.
//@param secondValue Second float dependency.
//@param thirdValue Third float dependency.
//@param fourthValue Fourth float dependency.
//@param firstKey First integer dependency.
//@param secondKey Second integer dependency.
//@param flag Boolean dependency. Defaults to false.
//@param tag String dependency.
//@returns true when the value must be recomputed.
export method staleOn(
  BoolMemo self,
  float firstValue = na,
  float secondValue = na,
  float thirdValue = na,
  float fourthValue = na,
  int firstKey = na,
  int secondKey = na,
  bool flag = false,
  string tag = na) =>
    _opEnsureBoolMemo(self)
    Watch dependencies = self.dependencies
    dependencies.begin()
    dependencies.watchFloat(firstValue)
    dependencies.watchFloat(secondValue)
    dependencies.watchFloat(thirdValue)
    dependencies.watchFloat(fourthValue)
    dependencies.watchInt(firstKey)
    dependencies.watchInt(secondKey)
    dependencies.watchBool(flag)
    dependencies.watchString(tag)
    dependencies.finish() or not self.valid

//@function Stores a recomputed value and marks the memo valid.
//@param self BoolMemo receiver.
//@param value Value to cache.
//@returns Self for chaining.
export method store(BoolMemo self, bool value) =>
    self.value := value
    self.valid := true
    self

//@function Reads the cached value.
//@param self BoolMemo receiver.
//@param fallback Returned before the first `store()`. Defaults to false.
//@returns The cached value, or `fallback`.
export method get(BoolMemo self, bool fallback = false) =>
    self.valid ? self.value : fallback

//@function Reports whether a value has been stored.
//@param self BoolMemo receiver.
//@returns true once `store()` has been called and not invalidated since.
export method isValid(BoolMemo self) =>
    self.valid

//@function Discards the cached value and forces the next check to miss.
//@param self BoolMemo receiver.
//@returns Self for chaining.
export method invalidate(BoolMemo self) =>
    _opEnsureBoolMemo(self)
    self.dependencies.invalidate()
    self.valid := false
    self

//@type One cached string plus an exact dependency Watch.
//      Tier: 1 through `staleOn()`; Tier 2 through the owned dependency Watch.
//      Stability: Stable
//      Ownership: owns its Watch. `get()` returns a value, never a reference.
//      Complexity: O(number of dependencies) per pass.
//      Empty value: na. Use `isValid()` to distinguish an empty memo from
//      a stored value equal to the empty value.
//@field dependencies Owned dependency watch.
//@field value Last stored value.
//@field valid False until the first `store()`.
export type StringMemo
    Watch dependencies = na
    string value = na
    bool valid = false

//@function Creates a memoized string holder.
//@returns A new StringMemo.
export stringMemo() =>
    StringMemo result = StringMemo.new()
    result.dependencies := watch()
    result

_opEnsureStringMemo(StringMemo self) =>
    if na(self.dependencies)
        self.dependencies := watch()
    self

//@function Starts an explicit dependency pass. Tier 2.
//@param self StringMemo receiver.
//@returns Self for chaining.
export method begin(StringMemo self) =>
    _opEnsureStringMemo(self)
    self.dependencies.begin()
    self

//@function Completes an explicit pass. Tier 2.
//@param self StringMemo receiver.
//@returns true when the value must be recomputed.
export method miss(StringMemo self) =>
    self.dependencies.finish() or not self.valid

//@function One-call dependency check. Tier 1.
//          The watched arity is fixed at eight slots regardless of how many
//          arguments are supplied, so omitting trailing arguments does not
//          register as a dependency change.
//@param self StringMemo receiver.
//@param firstValue First float dependency.
//@param secondValue Second float dependency.
//@param thirdValue Third float dependency.
//@param fourthValue Fourth float dependency.
//@param firstKey First integer dependency.
//@param secondKey Second integer dependency.
//@param flag Boolean dependency. Defaults to false.
//@param tag String dependency.
//@returns true when the value must be recomputed.
export method staleOn(
  StringMemo self,
  float firstValue = na,
  float secondValue = na,
  float thirdValue = na,
  float fourthValue = na,
  int firstKey = na,
  int secondKey = na,
  bool flag = false,
  string tag = na) =>
    _opEnsureStringMemo(self)
    Watch dependencies = self.dependencies
    dependencies.begin()
    dependencies.watchFloat(firstValue)
    dependencies.watchFloat(secondValue)
    dependencies.watchFloat(thirdValue)
    dependencies.watchFloat(fourthValue)
    dependencies.watchInt(firstKey)
    dependencies.watchInt(secondKey)
    dependencies.watchBool(flag)
    dependencies.watchString(tag)
    dependencies.finish() or not self.valid

//@function Stores a recomputed value and marks the memo valid.
//@param self StringMemo receiver.
//@param value Value to cache.
//@returns Self for chaining.
export method store(StringMemo self, string value) =>
    self.value := value
    self.valid := true
    self

//@function Reads the cached value.
//@param self StringMemo receiver.
//@param fallback Returned before the first `store()`. Defaults to na.
//@returns The cached value, or `fallback`.
export method get(StringMemo self, string fallback = na) =>
    self.valid ? self.value : fallback

//@function Reports whether a value has been stored.
//@param self StringMemo receiver.
//@returns true once `store()` has been called and not invalidated since.
export method isValid(StringMemo self) =>
    self.valid

//@function Discards the cached value and forces the next check to miss.
//@param self StringMemo receiver.
//@returns Self for chaining.
export method invalidate(StringMemo self) =>
    _opEnsureStringMemo(self)
    self.dependencies.invalidate()
    self.valid := false
    self

//@type One cached color plus an exact dependency Watch.
//      Tier: 1 through `staleOn()`; Tier 2 through the owned dependency Watch.
//      Stability: Stable
//      Ownership: owns its Watch. `get()` returns a value, never a reference.
//      Complexity: O(number of dependencies) per pass.
//      Empty value: na. Use `isValid()` to distinguish an empty memo from
//      a stored value equal to the empty value.
//@field dependencies Owned dependency watch.
//@field value Last stored value.
//@field valid False until the first `store()`.
export type ColorMemo
    Watch dependencies = na
    color value = na
    bool valid = false

//@function Creates a memoized color holder.
//@returns A new ColorMemo.
export colorMemo() =>
    ColorMemo result = ColorMemo.new()
    result.dependencies := watch()
    result

_opEnsureColorMemo(ColorMemo self) =>
    if na(self.dependencies)
        self.dependencies := watch()
    self

//@function Starts an explicit dependency pass. Tier 2.
//@param self ColorMemo receiver.
//@returns Self for chaining.
export method begin(ColorMemo self) =>
    _opEnsureColorMemo(self)
    self.dependencies.begin()
    self

//@function Completes an explicit pass. Tier 2.
//@param self ColorMemo receiver.
//@returns true when the value must be recomputed.
export method miss(ColorMemo self) =>
    self.dependencies.finish() or not self.valid

//@function One-call dependency check. Tier 1.
//          The watched arity is fixed at eight slots regardless of how many
//          arguments are supplied, so omitting trailing arguments does not
//          register as a dependency change.
//@param self ColorMemo receiver.
//@param firstValue First float dependency.
//@param secondValue Second float dependency.
//@param thirdValue Third float dependency.
//@param fourthValue Fourth float dependency.
//@param firstKey First integer dependency.
//@param secondKey Second integer dependency.
//@param flag Boolean dependency. Defaults to false.
//@param tag String dependency.
//@returns true when the value must be recomputed.
export method staleOn(
  ColorMemo self,
  float firstValue = na,
  float secondValue = na,
  float thirdValue = na,
  float fourthValue = na,
  int firstKey = na,
  int secondKey = na,
  bool flag = false,
  string tag = na) =>
    _opEnsureColorMemo(self)
    Watch dependencies = self.dependencies
    dependencies.begin()
    dependencies.watchFloat(firstValue)
    dependencies.watchFloat(secondValue)
    dependencies.watchFloat(thirdValue)
    dependencies.watchFloat(fourthValue)
    dependencies.watchInt(firstKey)
    dependencies.watchInt(secondKey)
    dependencies.watchBool(flag)
    dependencies.watchString(tag)
    dependencies.finish() or not self.valid

//@function Stores a recomputed value and marks the memo valid.
//@param self ColorMemo receiver.
//@param value Value to cache.
//@returns Self for chaining.
export method store(ColorMemo self, color value) =>
    self.value := value
    self.valid := true
    self

//@function Reads the cached value.
//@param self ColorMemo receiver.
//@param fallback Returned before the first `store()`. Defaults to na.
//@returns The cached value, or `fallback`.
export method get(ColorMemo self, color fallback = na) =>
    self.valid ? self.value : fallback

//@function Reports whether a value has been stored.
//@param self ColorMemo receiver.
//@returns true once `store()` has been called and not invalidated since.
export method isValid(ColorMemo self) =>
    self.valid

//@function Discards the cached value and forces the next check to miss.
//@param self ColorMemo receiver.
//@returns Self for chaining.
export method invalidate(ColorMemo self) =>
    _opEnsureColorMemo(self)
    self.dependencies.invalidate()
    self.valid := false
    self

//@type Two retained int arrays whose references swap without copying.
//      Tier: 1 (Quick) | Stability: Stable
//      Ownership: both arrays are structure-owned mutable views. A reference
//      obtained before a `swap()` points at what is now the other buffer, so
//      re-read the fields after every swap.
//      Complexity: `swap()` is O(1) plus the cost of clearing the new current.
//@field current Array written during the frame in progress.
//@field previous Array holding the values of the preceding frame.
export type IntDoubleBuffer
    array<int> current = na
    array<int> previous = na

//@function Creates a double buffer for int values.
//@returns A new IntDoubleBuffer with two empty retained arrays.
export intDoubleBuffer() =>
    IntDoubleBuffer.new(array.new<int>(), array.new<int>())

_opEnsureIntDouble(IntDoubleBuffer self) =>
    if na(self.current)
        self.current := array.new<int>()
    if na(self.previous)
        self.previous := array.new<int>()
    self

//@function Exchanges the two buffers and clears the new current buffer.
//@param self IntDoubleBuffer receiver.
//@returns [current, previous] as structure-owned mutable views.
export method swap(IntDoubleBuffer self) =>
    _opEnsureIntDouble(self)
    array<int> retired = self.current
    self.current := self.previous
    self.previous := retired
    self.current.clear()
    [self.current, self.previous]

//@function Exchanges the two buffers and resizes the new current buffer to a
//          fixed length, overwriting every element.
//@param self IntDoubleBuffer receiver.
//@param size Required element count of the new current buffer.
//@param fillValue Value written to every element of the new current buffer.
//@returns [current, previous] as structure-owned mutable views.
export method swapSized(IntDoubleBuffer self, int size, int fillValue = 0) =>
    _opEnsureIntDouble(self)
    array<int> retired = self.current
    self.current := self.previous
    self.previous := retired
    _opRefillInt(self.current, size, fillValue)
    [self.current, self.previous]

//@function Empties both buffers, retaining their allocations.
//@param self IntDoubleBuffer receiver.
//@returns Self for chaining.
export method clear(IntDoubleBuffer self) =>
    _opEnsureIntDouble(self)
    self.current.clear()
    self.previous.clear()
    self

//@type Two retained float arrays whose references swap without copying.
//      Tier: 1 (Quick) | Stability: Stable
//      Ownership: both arrays are structure-owned mutable views. A reference
//      obtained before a `swap()` points at what is now the other buffer, so
//      re-read the fields after every swap.
//      Complexity: `swap()` is O(1) plus the cost of clearing the new current.
//@field current Array written during the frame in progress.
//@field previous Array holding the values of the preceding frame.
export type FloatDoubleBuffer
    array<float> current = na
    array<float> previous = na

//@function Creates a double buffer for float values.
//@returns A new FloatDoubleBuffer with two empty retained arrays.
export floatDoubleBuffer() =>
    FloatDoubleBuffer.new(array.new<float>(), array.new<float>())

_opEnsureFloatDouble(FloatDoubleBuffer self) =>
    if na(self.current)
        self.current := array.new<float>()
    if na(self.previous)
        self.previous := array.new<float>()
    self

//@function Exchanges the two buffers and clears the new current buffer.
//@param self FloatDoubleBuffer receiver.
//@returns [current, previous] as structure-owned mutable views.
export method swap(FloatDoubleBuffer self) =>
    _opEnsureFloatDouble(self)
    array<float> retired = self.current
    self.current := self.previous
    self.previous := retired
    self.current.clear()
    [self.current, self.previous]

//@function Exchanges the two buffers and resizes the new current buffer to a
//          fixed length, overwriting every element.
//@param self FloatDoubleBuffer receiver.
//@param size Required element count of the new current buffer.
//@param fillValue Value written to every element of the new current buffer.
//@returns [current, previous] as structure-owned mutable views.
export method swapSized(FloatDoubleBuffer self, int size, float fillValue = 0.0) =>
    _opEnsureFloatDouble(self)
    array<float> retired = self.current
    self.current := self.previous
    self.previous := retired
    _opRefillFloat(self.current, size, fillValue)
    [self.current, self.previous]

//@function Empties both buffers, retaining their allocations.
//@param self FloatDoubleBuffer receiver.
//@returns Self for chaining.
export method clear(FloatDoubleBuffer self) =>
    _opEnsureFloatDouble(self)
    self.current.clear()
    self.previous.clear()
    self

//@type Deduplicated sparse integer set using generation stamps and a compact
//      discovery-order list.
//      Tier: 1 (Quick) | Stability: Stable
//      Ownership: `values()` returns a borrowed structure-owned view; see the
//      method for the full contract. `valuesCopy()` returns caller-owned
//      storage.
//      Complexity: `begin()` O(1) amortized (O(growth) when the universe
//      grows, O(universe) once per two billion cycles at rollover); `mark()`
//      O(1); `markMany()` O(batch); `values()` O(1) to obtain and O(dirty
//      count) to traverse, never O(universe).
//      Limits: the universe may not exceed 100,000 entries.
//@field stamps Per-index generation stamps. Size >= universeSize.
//@field dirty Discovery-order list of indices marked in the current cycle.
//@field generation Current cycle stamp. Starts at 0, first `begin()` makes 1.
//@field universeSize Number of valid indices. Marks outside are ignored.
export type DirtySet
    array<int> stamps = na
    array<int> dirty = na
    int generation = 0
    int universeSize = 0

//@function Creates a sparse dirty set.
//@param universeSize Number of tracked indices. Negative values become 0.
//@returns A new DirtySet with stamps preallocated.
export dirtySet(int universeSize = 0) =>
    int safeSize = math.max(nz(universeSize, 0), 0)
    if safeSize > _OP_MAX_ARRAY
        runtime.error("OptiPine.DirtySet: universe size exceeds the 100,000-element array limit.")
    DirtySet result = DirtySet.new()
    result.stamps := array.new<int>(safeSize, -1)
    result.dirty := array.new<int>()
    result.universeSize := safeSize
    result

//@function Starts a sparse-work cycle and optionally resizes the universe.
//          Growing the universe keeps existing stamps; shrinking it only
//          narrows the accepted index range and retains the allocation.
//@param self DirtySet receiver.
//@param universeSize New universe size, or na to keep the current one.
//@returns Self for chaining.
export method begin(DirtySet self, int universeSize = na) =>
    if na(self.stamps)
        self.stamps := array.new<int>()
    if na(self.dirty)
        self.dirty := array.new<int>()
    if not na(universeSize)
        int safeSize = math.max(universeSize, 0)
        if safeSize > _OP_MAX_ARRAY
            runtime.error("OptiPine.DirtySet: universe size exceeds the 100,000-element array limit.")
        self.universeSize := safeSize
    int required = self.universeSize - self.stamps.size()
    if required > 0
        for _ = 0 to required - 1
            self.stamps.push(-1)
    self.dirty.clear()
    if self.generation >= _OP_MAX_GENERATION
        if self.stamps.size() > 0
            self.stamps.fill(-1)
        self.generation := 0
    self.generation += 1
    self

//@function Marks one index for the current cycle.
//@param self DirtySet receiver.
//@param index Index to mark. Out-of-range values are ignored.
//@returns true only for the first mark of this index in this cycle.
export method mark(DirtySet self, int index) =>
    bool added = false
    if index >= 0 and index < self.universeSize and self.stamps.get(index) != self.generation
        self.stamps.set(index, self.generation)
        self.dirty.push(index)
        added := true
    added

//@function Marks every index in an array. Duplicate and out-of-range indices
//          are ignored. Tier 1.
//          Complexity: O(batch), independent of the universe size.
//@param self DirtySet receiver.
//@param indices Indices to mark. Out-of-range values are ignored. na is
//       treated as an empty batch.
//@returns The number of indices this call added to the dirty list, which is
//         the count of first marks and so excludes duplicates and rejects.
export method markMany(DirtySet self, array<int> indices) =>
    int total = na(indices) ? 0 : indices.size()
    int added = 0
    if total > 0
        if na(self.stamps)
            self.stamps := array.new<int>()
        if na(self.dirty)
            self.dirty := array.new<int>()
        int stamp = self.generation
        int universe = self.universeSize
        array<int> stamps = self.stamps
        array<int> dirty = self.dirty
        for index in indices
            if index >= 0 and index < universe and stamps.get(index) != stamp
                stamps.set(index, stamp)
                dirty.push(index)
                added += 1
    added

//@function Marks one index without bounds validation. Tier 3.
//@param self DirtySet receiver.
//@param index Index to mark. The caller guarantees 0 <= index < universeSize
//       and that `begin()` has run at least once. An out-of-range index raises
//       a Pine array error rather than being ignored.
//@returns true only for the first mark of this index in this cycle.
export method markUnchecked(DirtySet self, int index) =>
    bool added = false
    if self.stamps.get(index) != self.generation
        self.stamps.set(index, self.generation)
        self.dirty.push(index)
        added := true
    added

//@function Marks every index in an inclusive range, clipped to the universe.
//@param self DirtySet receiver.
//@param first One end of the range.
//@param last The other end of the range. Order does not matter.
//@returns Self for chaining.
export method markRange(DirtySet self, int first, int last) =>
    int lower = math.max(0, math.min(first, last))
    int upper = math.min(self.universeSize - 1, math.max(first, last))
    if lower <= upper
        int stamp = self.generation
        array<int> stamps = self.stamps
        array<int> dirty = self.dirty
        for index = lower to upper
            if stamps.get(index) != stamp
                stamps.set(index, stamp)
                dirty.push(index)
    self

//@function Tests whether an index was marked in the current cycle.
//@param self DirtySet receiver.
//@param index Index to test.
//@returns true when the index carries the current generation stamp.
export method contains(DirtySet self, int index) =>
    index >= 0 and index < self.universeSize and self.stamps.get(index) == self.generation

//@function The indices marked in the current cycle, in discovery order.
//          Tier 1.
//          Ownership: borrowed structure-owned view.
//          Mutation: read-only by contract; mutation is unsupported. The list
//          and the generation stamps describe each other, so appending or
//          clearing it corrupts both. Use `valuesCopy()` to own or modify it.
//          Lifetime: valid until the next `begin()` or `clear()`.
//          Persistence: do not retain it across that boundary; reacquire it.
//@param self DirtySet receiver.
//@returns The dirty indices in discovery order.
export method values(DirtySet self) =>
    if na(self.dirty)
        self.dirty := array.new<int>()
    self.dirty

//@function Copies the dirty indices into caller-owned storage.
//@param self DirtySet receiver.
//@param output Optional caller-owned array. It is cleared and refilled. When
//       na, a newly allocated array is returned.
//@returns The dirty indices in discovery order, owned by the caller.
export method valuesCopy(DirtySet self, array<int> output = na) =>
    _opSnapshotInt(self.dirty, output, "OptiPine.DirtySet.valuesCopy")

//@function Number of distinct indices marked in the current cycle.
//@param self DirtySet receiver.
//@returns The dirty count.
export method size(DirtySet self) =>
    na(self.dirty) ? 0 : self.dirty.size()

//@function Current universe size.
//@param self DirtySet receiver.
//@returns The number of tracked indices.
export method universe(DirtySet self) =>
    self.universeSize

//@function Current cycle stamp, mainly for diagnostics. Named distinctly from
//          the `generation` field so a method call is never mistaken for field
//          access.
//@param self DirtySet receiver.
//@returns The generation counter.
export method cycle(DirtySet self) =>
    self.generation

//@function Discards all marks and stamps while retaining the allocations.
//          The universe size is preserved.
//@param self DirtySet receiver.
//@returns Self for chaining.
export method clear(DirtySet self) =>
    if na(self.stamps)
        self.stamps := array.new<int>()
    if na(self.dirty)
        self.dirty := array.new<int>()
    if self.stamps.size() > 0
        self.stamps.fill(-1)
    self.dirty.clear()
    self.generation := 0
    self

//@type Stateful gate for work that should run at a minimum tick interval, and
//      optionally only when its producer changed as well.
//      Tier: 1 (Quick) | Stability: Stable
//      Ownership: value semantics; the gate holds no collections.
//      Complexity: O(1). No allocation.
//      Semantics: both methods consume the gate and record their state when
//      they return true. `peek()` answers the cadence question without
//      consuming.
//@field lastTick Tick recorded by the last consumed run.
//@field lastRevision Revision recorded by the last consumed run, or na when
//       the last run came through cadence-only `due()`.
//@field runCount Number of consumed runs since construction or reset.
//@field initialized False until the first consumed run.
export type CadenceGate
    int lastTick = na
    int lastRevision = na
    int runCount = 0
    bool initialized = false

//@function Creates a cadence gate that is due on its first check.
//@returns A new CadenceGate.
export cadenceGate() =>
    CadenceGate.new()

//@function Tests whether the cadence is open, without consuming the gate.
//@param self CadenceGate receiver.
//@param tick Current monotonic tick.
//@param interval Minimum tick distance between runs. Values below 1 become 1.
//@param force Report due regardless of cadence.
//@returns true when a `due()` call with the same arguments would run.
export method peek(CadenceGate self, int tick, int interval = 1, bool force = false) =>
    int safeInterval = math.max(nz(interval, 1), 1)
    force or not self.initialized or tick - self.lastTick >= safeInterval

//@function Consumes the gate and reports whether work is due. Tier 1.
//@param self CadenceGate receiver.
//@param tick Current monotonic tick.
//@param interval Minimum tick distance between runs. Values below 1 become 1.
//@param force Run regardless of cadence.
//@returns true when work should run now. The tick is recorded only when this
//         returns true, so a gate that stays closed does not drift.
export method due(CadenceGate self, int tick, int interval = 1, bool force = false) =>
    int safeInterval = math.max(nz(interval, 1), 1)
    bool ready = force or not self.initialized or tick - self.lastTick >= safeInterval
    if ready
        self.lastTick := tick
        self.lastRevision := na
        self.runCount += 1
        self.initialized := true
    ready

//@function Consumes the gate and reports whether work is due *and* the
//          producer changed since the last run. Tier 1.
//@param self CadenceGate receiver.
//@param tick Current monotonic tick.
//@param revision Current producer revision. na means "no revision available
//       yet" and leaves the decision to the cadence alone, so a producer that
//       has not started publishing never deadlocks the gate.
//@param interval Minimum tick distance between runs. Values below 1 become 1.
//@param force Run regardless of cadence and revision.
//@returns true when work should run now. The tick and revision are recorded
//         only when this returns true.
export method dueWhenChanged(
  CadenceGate self,
  int tick,
  int revision,
  int interval = 1,
  bool force = false) =>
    int safeInterval = math.max(nz(interval, 1), 1)
    bool tickReady = not self.initialized or tick - self.lastTick >= safeInterval
    bool revisionReady = na(revision) or not self.initialized or revision != self.lastRevision
    bool ready = force or tickReady and revisionReady
    if ready
        self.lastTick := tick
        self.lastRevision := revision
        self.runCount += 1
        self.initialized := true
    ready

//@function Number of consumed runs.
//@param self CadenceGate receiver.
//@returns The run counter.
export method runs(CadenceGate self) =>
    self.runCount

//@function Returns the gate to its initial state, so the next check is due.
//@param self CadenceGate receiver.
//@returns Self for chaining.
export method reset(CadenceGate self) =>
    self.lastTick := na
    self.lastRevision := na
    self.runCount := 0
    self.initialized := false
    self

//@enum Integer-key lookup representation.
//@field automatic Select a representation at `buildFinish()` from the observed
//       key layout and, when supplied, the expected query horizon.
//@field linear No build at all. Queries scan the insertion-order key array
//       with the native `indexof`/`lastindexof` built-ins. Correct for any key
//       layout and the cheapest choice when a directory is rebuilt far more
//       often than it is queried.
//@field sorted Native binary search. Strictly ascending builds search the key
//       array directly with no extra storage; any other order builds a sorted
//       key array plus a slot indirection array once.
//@field dictionary Map-backed directory. Limited to 50,000 keys by Pine.
//@field dense Direct addressing. A consecutive ascending run needs no table at
//       all; any other layout allocates a span-sized slot table.
export enum LookupPolicy
    automatic = "Automatic"
    linear = "Linear scan"
    sorted = "Sorted binary search"
    dictionary = "Map"
    dense = "Dense direct"

//@enum Behavior when the same key is added more than once.
//@field raiseError Always verify uniqueness at `buildFinish()` and stop with a
//       descriptive error when a duplicate is present. Every representation
//       checks; the method varies from a free adjacent scan to one native
//       sort, but the guarantee does not.
//@field firstWins Every lookup resolves to the slot of the first occurrence.
//@field lastWins Every lookup resolves to the slot of the last occurrence.
export enum DuplicatePolicy
    raiseError = "Raise error"
    firstWins = "First occurrence wins"
    lastWins = "Last occurrence wins"

//@type Configuration for `IntIndex` and every keyed store built on it.
//      Tier: 2 (Composable) | Stability: Stable
//      Ownership: caller-owned. One config object may be shared by several
//      indexes. Mirrored hot-path flags refresh at `buildBegin()` and
//      `buildFinish()`, so mutate a shared config between builds, not during
//      a query loop.
//@field policy Requested lookup representation.
//@field duplicates Duplicate-key behavior.
//@field promoteQueryRatio Query-to-entry ratio used to justify map construction.
//@field promoteMinQueries Minimum query count before promotion is allowed.
//@field autoPromote Allow a sorted index to promote to a map while queried.
//@field validateAscending Track and validate key order during construction.
//@field maxDenseSpan Largest span accepted by a forced dense representation.
//@field autoDenseSpanRatio In automatic mode, allow a dense slot table when
//       span <= entries * this ratio. 0 disables automatic dense tables.
//@field autoDenseMaxSpan Absolute span ceiling for automatic dense tables.
//@field linearMaxEntries Maximum entry count assigned to linear lookup in
//       automatic mode. 0 disables automatic linear selection.
//@field duplicateScanLimit Largest unordered build checked pairwise for
//       duplicates before using `sort_indices()`.
//@field collectStats Track queries, hits, misses and duplicates.
//@field strictLifecycle Raise on invalid construction and query order.
export type IndexConfig
    LookupPolicy policy = LookupPolicy.automatic
    DuplicatePolicy duplicates = DuplicatePolicy.raiseError
    float promoteQueryRatio = 0.10
    int promoteMinQueries = 32
    bool autoPromote = false
    bool validateAscending = true
    int maxDenseSpan = 100000
    float autoDenseSpanRatio = 2.0
    int autoDenseMaxSpan = 16384
    int linearMaxEntries = 0
    int duplicateScanLimit = 64
    bool collectStats = false
    bool strictLifecycle = true

//@type Snapshot of keyed-index telemetry.
//@field requested Policy asked for in the configuration.
//@field active Representation actually in use.
//@field entries Number of keys added.
//@field queries Lookups counted. Only maintained when `collectStats` is on or
//       online promotion is armed.
//@field hits Lookups that resolved to a slot. Requires `collectStats`.
//@field misses Lookups that returned -1. Requires `collectStats`.
//@field builds Completed `buildFinish()` calls.
//@field promotions Online sorted-to-map promotions.
//@field duplicates Extra keys beyond the unique count, or -1 when unknown.
//@field denseSpan maxKey - minKey + 1, or 0 when empty.
//@field ascending Whether keys were added strictly ascending.
//@field consecutive Whether keys form a consecutive ascending run.
//@field duplicatesChecked Whether the active representation actually verified
//       uniqueness. When false, `duplicates` is -1 and no guarantee is made.
export type IndexStats
    LookupPolicy requested = LookupPolicy.automatic
    LookupPolicy active = LookupPolicy.linear
    int entries = 0
    int queries = 0
    int hits = 0
    int misses = 0
    int builds = 0
    int promotions = 0
    int duplicates = 0
    int denseSpan = 0
    bool ascending = true
    bool consecutive = false
    bool duplicatesChecked = false

//@function Creates a keyed-index configuration. Tier 2.
//@param policy Requested lookup representation.
//@param duplicates Duplicate-key behavior.
//@param promoteQueryRatio Query fraction that justifies map construction.
//@param promoteMinQueries Minimum queries before promotion is considered.
//@param autoPromote Allow online sorted-to-map promotion.
//@param validateAscending Track key order during `add()`.
//@param maxDenseSpan Largest span accepted by a forced dense representation.
//@param autoDenseSpanRatio Automatic dense-table span budget per entry.
//@param autoDenseMaxSpan Absolute span ceiling for automatic dense tables.
//@param linearMaxEntries Automatic linear selection threshold.
//@param duplicateScanLimit Pairwise duplicate scan limit for linear mode.
//@param collectStats Track counters.
//@param strictLifecycle Raise on lifecycle violations.
//@returns A new IndexConfig with every argument clamped to a valid range.
export indexConfig(
  LookupPolicy policy = LookupPolicy.automatic,
  DuplicatePolicy duplicates = DuplicatePolicy.raiseError,
  float promoteQueryRatio = 0.10,
  int promoteMinQueries = 32,
  bool autoPromote = false,
  bool validateAscending = true,
  int maxDenseSpan = 100000,
  float autoDenseSpanRatio = 2.0,
  int autoDenseMaxSpan = 16384,
  int linearMaxEntries = 0,
  int duplicateScanLimit = 64,
  bool collectStats = false,
  bool strictLifecycle = true) =>
    IndexConfig.new(
      policy,
      duplicates,
      math.max(nz(promoteQueryRatio, 0.0), 0.0),
      math.max(nz(promoteMinQueries, 1), 1),
      autoPromote,
      validateAscending,
      math.min(math.max(nz(maxDenseSpan, 1), 1), _OP_MAX_ARRAY),
      math.max(nz(autoDenseSpanRatio, 0.0), 0.0),
      math.min(math.max(nz(autoDenseMaxSpan, 0), 0), _OP_MAX_ARRAY),
      math.max(nz(linearMaxEntries, 0), 0),
      math.max(nz(duplicateScanLimit, 0), 0),
      collectStats,
      strictLifecycle)

//@function Preset: a directory built once and queried across many bars.
//          Forces sorted binary search, which needs no extra storage for an
//          ascending build and never allocates a map.
//@returns An IndexConfig.
export indexConfigStaticSorted() =>
    indexConfig(policy = LookupPolicy.sorted)

//@function Preset: direct addressing for validated dense integer keys.
//          Raises when the key span exceeds `maxDenseSpan`.
//@returns An IndexConfig.
export indexConfigDense() =>
    indexConfig(policy = LookupPolicy.dense)

//@function Preset: a persistent map-backed directory for lookup-heavy workloads.
//@returns An IndexConfig.
export indexConfigDictionary() =>
    indexConfig(policy = LookupPolicy.dictionary)

//@function Preset: a very small directory rebuilt far more often than it is
//          queried. No build cost at all; queries use the native scan.
//@returns An IndexConfig.
export indexConfigTiny() =>
    indexConfig(policy = LookupPolicy.linear)

//@function Preset: automatic selection with online sorted-to-map promotion and
//          counters enabled, for directories whose query volume is unknown
//          until it happens.
//@returns An IndexConfig.
export indexConfigDynamic() =>
    indexConfig(autoPromote = true, collectStats = true)

//@type Universal integer-key directory.
//      Tier: 2 (Composable) | Stability: Stable
//      Ownership: `keysView()` returns a borrowed structure-owned view that is
//      read-only by contract. Every other accessor returns values. `findMany()`
//      writes into a caller-owned output array, or allocates one when none is
//      supplied.
//      Complexity: `add()` O(1). `buildFinish()` is O(entries) for dense, map
//      and ordered sorted builds; O(entries log entries) for unordered sorted
//      builds; and O(1) for permissive linear mode. Linear duplicate checking
//      may add O(entries squared) below `duplicateScanLimit` or O(entries log
//      entries) above it. `find()` is O(1) for dense and map, O(log entries)
//      for sorted, and O(entries) for linear.
//      Allocation: collection objects are reused across rebuilds.
//      Limits: 100,000 keys; 50,000 when the map representation is selected.
//@field settings Configuration reference.
//@field activePolicy Representation selected at `buildFinish()`.
//@field state Build lifecycle state. 0 empty, 1 building, 2 sealed.
//@field keys Insertion-order keys. Index equals slot.
//@field sortedKeys Ascending key copy for non-identity sorted mode.
//@field sortedSlots Slot for each position of `sortedKeys`.
//@field lookup Map representation.
//@field denseSlots Span-sized slot table for non-arithmetic dense mode.
//@field minKey Smallest key added, or na when empty.
//@field maxKey Largest key added, or na when empty.
//@field ascending Whether every key was strictly greater than the previous.
//@field nonDecreasing Whether no key was smaller than the previous.
//@field consecutive Whether keys form a consecutive ascending run.
//@field arithmeticDense Whether dense mode addresses without a table.
//@field sortedIdentity Whether sorted mode searches `keys` directly.
//@field linearLastWins Whether linear mode resolves to the last occurrence.
//@field trackQueries Whether `find()` must maintain the query counter.
//@field promotionArmed Whether online sorted-to-map promotion may still fire.
//@field duplicatesChecked Whether the build verified key uniqueness.
//@field duplicateCount Extra keys beyond the unique count, or -1 if unknown.
//@field queryCount Counted lookups.
//@field hitCount Counted hits.
//@field missCount Counted misses.
//@field buildCount Completed builds.
//@field promotionCount Online promotions performed.
//@field promotionThreshold Query count that triggers online promotion.
export type IntIndex
    IndexConfig settings = na
    LookupPolicy activePolicy = LookupPolicy.linear
    int state = 0
    array<int> keys = na
    array<int> sortedKeys = na
    array<int> sortedSlots = na
    map<int, int> lookup = na
    array<int> denseSlots = na
    int minKey = na
    int maxKey = na
    bool ascending = true
    bool nonDecreasing = true
    bool consecutive = false
    bool arithmeticDense = false
    bool sortedIdentity = true
    bool linearLastWins = false
    bool trackQueries = false
    bool promotionArmed = false
    bool duplicatesChecked = false
    int duplicateCount = 0
    int queryCount = 0
    int hitCount = 0
    int missCount = 0
    int buildCount = 0
    int promotionCount = 0
    int promotionThreshold = 0

//@function Creates an integer-key directory.
//@param settings Configuration, or na for the automatic defaults.
//@returns A new IntIndex in the empty state.
export intIndex(IndexConfig settings = na) =>
    IntIndex result = IntIndex.new()
    result.settings := na(settings) ? indexConfig() : settings
    result.keys := array.new<int>()
    result.sortedKeys := array.new<int>()
    result.sortedSlots := array.new<int>()
    result.lookup := map.new<int, int>()
    result.denseSlots := array.new<int>()
    result

_opEnsureIntIndex(IntIndex self) =>
    if na(self.settings)
        self.settings := indexConfig()
    if na(self.keys)
        self.keys := array.new<int>()
    if na(self.sortedKeys)
        self.sortedKeys := array.new<int>()
    if na(self.sortedSlots)
        self.sortedSlots := array.new<int>()
    if na(self.lookup)
        self.lookup := map.new<int, int>()
    if na(self.denseSlots)
        self.denseSlots := array.new<int>()
    self

_opIndexBuildMap(IntIndex self) =>
    int count = self.keys.size()
    if count > _OP_MAX_MAP_PAIRS
        runtime.error("OptiPine.IntIndex: map representation needs " + str.tostring(count) +
          " pairs, above Pine's 50,000-pair limit. Use LookupPolicy.sorted instead.")
    DuplicatePolicy duplicates = self.settings.duplicates
    map<int, int> lookup = self.lookup
    lookup.clear()
    if duplicates == DuplicatePolicy.firstWins
        for [slot, key] in self.keys
            if not lookup.contains(key)
                lookup.put(key, slot)
    else
        for [slot, key] in self.keys
            lookup.put(key, slot)
    int unique = lookup.size()
    if duplicates == DuplicatePolicy.raiseError and unique != count
        runtime.error("OptiPine.IntIndex: buildFinish found " + str.tostring(count - unique) +
          " duplicate key(s). Set IndexConfig.duplicates to firstWins or lastWins to allow them.")
    self.duplicateCount := count - unique
    self.duplicatesChecked := true
    self.activePolicy := LookupPolicy.dictionary
    self

_opIndexBuildDense(IntIndex self) =>
    int count = self.keys.size()
    int span = self.maxKey - self.minKey + 1
    if span > _OP_MAX_ARRAY
        runtime.error("OptiPine.IntIndex: dense span " + str.tostring(span) +
          " exceeds the 100,000-element array limit.")
    DuplicatePolicy duplicates = self.settings.duplicates
    array<int> dense = self.denseSlots
    _opRefillInt(dense, span, -1)
    int base = self.minKey
    int collisions = 0
    if duplicates == DuplicatePolicy.firstWins
        for [slot, key] in self.keys
            int offset = key - base
            if dense.get(offset) < 0
                dense.set(offset, slot)
            else
                collisions += 1
    else
        for [slot, key] in self.keys
            int offset = key - base
            if dense.get(offset) >= 0
                collisions += 1
            dense.set(offset, slot)
    if duplicates == DuplicatePolicy.raiseError and collisions > 0
        runtime.error("OptiPine.IntIndex: buildFinish found " + str.tostring(collisions) +
          " duplicate key(s). Set IndexConfig.duplicates to firstWins or lastWins to allow them.")
    self.duplicateCount := collisions
    self.duplicatesChecked := true
    self.arithmeticDense := false
    self.activePolicy := LookupPolicy.dense
    self

_opIndexBuildSorted(IntIndex self) =>
    int count = self.keys.size()
    DuplicatePolicy duplicates = self.settings.duplicates
    array<int> sortedKeys = self.sortedKeys
    array<int> sortedSlots = self.sortedSlots
    if self.ascending
        sortedKeys.clear()
        sortedSlots.clear()
        self.sortedIdentity := true
        self.duplicateCount := 0
        self.duplicatesChecked := true
    else
        self.sortedIdentity := false
        sortedKeys.clear()
        sortedSlots.clear()
        if self.nonDecreasing
            sortedKeys.concat(self.keys)
            if count > 0
                for slot = 0 to count - 1
                    sortedSlots.push(slot)
        else
            array<int> ranks = self.keys.sort_indices(order.ascending)
            sortedSlots.concat(ranks)
            for rank in ranks
                sortedKeys.push(self.keys.get(rank))
        int collisions = 0
        if count > 0
            bool takeLast = duplicates == DuplicatePolicy.lastWins
            int runStart = 0
            for position = 1 to count
                if position == count or sortedKeys.get(position) != sortedKeys.get(runStart)
                    int runLength = position - runStart
                    if runLength > 1
                        collisions += runLength - 1
                        int chosen = sortedSlots.get(runStart)
                        for scan = runStart + 1 to position - 1
                            int candidate = sortedSlots.get(scan)
                            chosen := takeLast ? math.max(chosen, candidate) : math.min(chosen, candidate)
                        for scan = runStart to position - 1
                            sortedSlots.set(scan, chosen)
                    runStart := position
        if duplicates == DuplicatePolicy.raiseError and collisions > 0
            runtime.error("OptiPine.IntIndex: buildFinish found " + str.tostring(collisions) +
              " duplicate key(s). Set IndexConfig.duplicates to firstWins or lastWins to allow them.")
        self.duplicateCount := collisions
        self.duplicatesChecked := true
    self.activePolicy := LookupPolicy.sorted
    self

_opIndexBuildLinear(IntIndex self) =>
    int count = self.keys.size()
    DuplicatePolicy duplicates = self.settings.duplicates
    self.linearLastWins := duplicates == DuplicatePolicy.lastWins
    self.sortedKeys.clear()
    self.sortedSlots.clear()
    self.denseSlots.clear()
    self.lookup.clear()
    int collisions = 0
    bool checked = false
    if duplicates == DuplicatePolicy.raiseError
        checked := true
        if count > 1
            if self.nonDecreasing
                for position = 1 to count - 1
                    if self.keys.get(position) == self.keys.get(position - 1)
                        collisions += 1
            else if count <= self.settings.duplicateScanLimit
                for outer = 0 to count - 2
                    int candidate = self.keys.get(outer)
                    for inner = outer + 1 to count - 1
                        if self.keys.get(inner) == candidate
                            collisions += 1
                            break
            else
                array<int> ranks = self.keys.sort_indices(order.ascending)
                for position = 1 to count - 1
                    if self.keys.get(ranks.get(position)) == self.keys.get(ranks.get(position - 1))
                        collisions += 1
    else if self.ascending
        checked := true
    if collisions > 0
        runtime.error("OptiPine.IntIndex: buildFinish found " + str.tostring(collisions) +
          " duplicate key(s). Set IndexConfig.duplicates to firstWins or lastWins to allow them.")
    self.duplicatesChecked := checked
    self.duplicateCount := checked ? collisions : -1
    self.activePolicy := LookupPolicy.linear
    self

_opIndexPromote(IntIndex self) =>
    if self.activePolicy == LookupPolicy.sorted and self.keys.size() <= _OP_MAX_MAP_PAIRS
        _opIndexBuildMap(self)
        self.promotionCount += 1
    self.promotionArmed := false
    self.trackQueries := self.settings.collectStats
    self

//@function Starts a build and clears prior key data, retaining every
//          allocation. Calling it on a sealed index restarts the build.
//@param self IntIndex receiver.
//@param expectedAscending Declares the intended key order. It only matters
//       when `IndexConfig.validateAscending` is false, in which case it is
//       trusted without verification.
//@returns Self for chaining.
export method buildBegin(IntIndex self, bool expectedAscending = true) =>
    _opEnsureIntIndex(self)
    self.keys.clear()
    self.sortedKeys.clear()
    self.sortedSlots.clear()
    self.lookup.clear()
    self.denseSlots.clear()
    self.state := _OP_STATE_BUILDING
    self.activePolicy := LookupPolicy.linear
    self.minKey := na
    self.maxKey := na
    self.ascending := expectedAscending
    self.nonDecreasing := expectedAscending
    self.consecutive := false
    self.arithmeticDense := false
    self.sortedIdentity := true
    self.linearLastWins := false
    self.trackQueries := false
    self.promotionArmed := false
    self.duplicatesChecked := false
    self.duplicateCount := 0
    self.queryCount := 0
    self.hitCount := 0
    self.missCount := 0
    self.promotionThreshold := 0
    self

//@function Adds one key and returns its payload slot.
//          Slots are assigned in insertion order starting at 0.
//@param self IntIndex receiver.
//@param key Integer key. na keys are rejected.
//@returns The slot for this key.
export method add(IntIndex self, int key) =>
    if self.state == _OP_STATE_SEALED
        if self.settings.strictLifecycle
            runtime.error("OptiPine.IntIndex: add() after buildFinish(). Call buildBegin() first.")
        self.buildBegin(true)
    else if self.state == _OP_STATE_EMPTY
        self.buildBegin(true)
    if na(key)
        runtime.error("OptiPine.IntIndex: na is not a valid key.")
    int slot = self.keys.size()
    if slot > 0 and self.settings.validateAscending
        int previous = self.keys.get(slot - 1)
        if key <= previous
            self.ascending := false
            if key < previous
                self.nonDecreasing := false
    self.keys.push(key)
    if slot == 0
        self.minKey := key
        self.maxKey := key
    else
        self.minKey := math.min(self.minKey, key)
        self.maxKey := math.max(self.maxKey, key)
    slot

//@function Adds every key of an array in order.
//@param self IntIndex receiver.
//@param keyBatch Keys to add. Must not be the index's own key array.
//@returns The slot of the first added key, or -1 for an empty batch.
export method addMany(IntIndex self, array<int> keyBatch) =>
    int total = na(keyBatch) ? 0 : keyBatch.size()
    int first = -1
    if total > 0
        if _opAliasInt(self.keys, keyBatch)
            runtime.error("OptiPine.IntIndex: addMany input must not be the index key array.")
        if self.state == _OP_STATE_SEALED
            if self.settings.strictLifecycle
                runtime.error("OptiPine.IntIndex: addMany() after buildFinish(). Call buildBegin() first.")
            self.buildBegin(true)
        else if self.state == _OP_STATE_EMPTY
            self.buildBegin(true)

        array<int> keys = self.keys
        bool validateAscending = self.settings.validateAscending
        int slot = keys.size()
        first := slot
        int previous = na
        if slot > 0
            previous := keys.get(slot - 1)
        int lowest = self.minKey
        int highest = self.maxKey
        int lastPosition = total - 1
        for position = 0 to lastPosition
            int key = keyBatch.get(position)
            if na(key)
                runtime.error("OptiPine.IntIndex: na is not a valid key.")
            if validateAscending and slot > 0
                if key <= previous
                    self.ascending := false
                    if key < previous
                        self.nonDecreasing := false
            keys.push(key)
            if slot == 0
                lowest := key
                highest := key
            else
                lowest := math.min(lowest, key)
                highest := math.max(highest, key)
            previous := key
            slot += 1
        self.minKey := lowest
        self.maxKey := highest
    first

//@function Completes construction and selects the lookup representation.
//          Calling it again on a sealed index is a no-op.
//@param self IntIndex receiver.
//@param expectedQueries Expected lookups before the next rebuild. Supplying it
//       lets automatic mode choose a map immediately when construction
//       amortizes, instead of relying on an online promotion that may not.
//       na leaves the horizon unknown and favours the cheaper build.
//@returns The active representation.
export method buildFinish(IntIndex self, int expectedQueries = na) =>
    _opEnsureIntIndex(self)
    if self.state != _OP_STATE_SEALED
        IndexConfig settings = self.settings
        int count = self.keys.size()
        int span = count > 0 ? self.maxKey - self.minKey + 1 : 0
        self.consecutive := count > 0 and self.ascending and span == count
        self.arithmeticDense := false
        self.promotionArmed := false
        LookupPolicy requested = settings.policy

        if requested == LookupPolicy.linear
            _opIndexBuildLinear(self)
        else if requested == LookupPolicy.dictionary
            _opIndexBuildMap(self)
        else if requested == LookupPolicy.sorted
            _opIndexBuildSorted(self)
        else if requested == LookupPolicy.dense
            if count == 0
                _opIndexBuildLinear(self)
            else if self.consecutive
                self.arithmeticDense := true
                self.duplicateCount := 0
                self.duplicatesChecked := true
                self.activePolicy := LookupPolicy.dense
            else if span > settings.maxDenseSpan
                runtime.error("OptiPine.IntIndex: dense policy needs a key span of at most " +
                  str.tostring(settings.maxDenseSpan) + " but the span is " + str.tostring(span) +
                  ". Raise IndexConfig.maxDenseSpan or use another policy.")
            else
                _opIndexBuildDense(self)
        else
            int horizon = math.max(settings.promoteMinQueries,
              int(math.ceil(count * settings.promoteQueryRatio)))
            if count == 0 or count <= settings.linearMaxEntries
                _opIndexBuildLinear(self)
            else if self.consecutive
                self.arithmeticDense := true
                self.duplicateCount := 0
                self.duplicatesChecked := true
                self.activePolicy := LookupPolicy.dense
            else if span > 0 and span <= settings.autoDenseMaxSpan and
              span <= count * settings.autoDenseSpanRatio
                _opIndexBuildDense(self)
            else if not self.ascending and count <= _OP_MAX_MAP_PAIRS
                _opIndexBuildMap(self)
            else if self.ascending and count <= _OP_MAX_MAP_PAIRS and
              not na(expectedQueries) and expectedQueries >= horizon
                _opIndexBuildMap(self)
            else
                _opIndexBuildSorted(self)
                self.promotionArmed := settings.autoPromote and count <= _OP_MAX_MAP_PAIRS

        self.promotionThreshold := math.max(settings.promoteMinQueries,
          int(math.ceil(count * settings.promoteQueryRatio)))
        self.trackQueries := settings.collectStats or self.promotionArmed
        self.state := _OP_STATE_SEALED
        self.buildCount += 1
    self.activePolicy

//@function Finds one key using the active lookup representation.
//@param self IntIndex receiver.
//@param key Key to look up.
//@returns The slot, or -1 on a miss.
export method find(IntIndex self, int key) =>
    int slot = -1
    if self.state == _OP_STATE_SEALED
        switch self.activePolicy
            LookupPolicy.dense =>
                if key >= self.minKey and key <= self.maxKey
                    if self.arithmeticDense
                        slot := key - self.minKey
                    else
                        slot := self.denseSlots.get(key - self.minKey)
            LookupPolicy.dictionary =>
                int mapped = self.lookup.get(key)
                if not na(mapped)
                    slot := mapped
            LookupPolicy.linear =>
                if self.linearLastWins
                    slot := self.keys.lastindexof(key)
                else
                    slot := self.keys.indexof(key)
            =>
                if self.sortedIdentity
                    slot := self.keys.binary_search(key)
                else
                    int position = self.sortedKeys.binary_search(key)
                    if position >= 0
                        slot := self.sortedSlots.get(position)
        if self.trackQueries
            self.queryCount += 1
            if self.settings.collectStats
                if slot >= 0
                    self.hitCount += 1
                else
                    self.missCount += 1
            if self.promotionArmed and self.queryCount >= self.promotionThreshold
                _opIndexPromote(self)
    else if self.settings.strictLifecycle
        runtime.error("OptiPine.IntIndex: find() before buildFinish().")
    slot

//@function Tests whether a key is present.
//@param self IntIndex receiver.
//@param key Key to test.
//@returns true when the key resolves to a slot.
export method contains(IntIndex self, int key) =>
    self.find(key) >= 0

//@function Resolves a batch of keys into slots, dispatching once.
//@param self IntIndex receiver.
//@param queryKeys Keys to resolve. Read only.
//@param output Optional caller-owned array. It is cleared and refilled. When
//       na, a newly allocated array is returned.
//@returns The slot for each query key, in query order. -1 marks a miss.
export method findMany(IntIndex self, array<int> queryKeys, array<int> output = na) =>
    array<int> result = output
    if na(result)
        result := array.new<int>()
    else
        if _opAliasInt(queryKeys, result)
            runtime.error("OptiPine.IntIndex: findMany output must not be the query array.")
        if _opAliasInt(self.keys, result)
            runtime.error("OptiPine.IntIndex: findMany output must not be the index key array.")
        result.clear()

    int querySize = na(queryKeys) ? 0 : queryKeys.size()
    if self.state == _OP_STATE_SEALED and querySize > 0
        if self.promotionArmed and self.queryCount + querySize >= self.promotionThreshold
            _opIndexPromote(self)
        int hits = 0
        switch self.activePolicy
            LookupPolicy.dense =>
                int lower = self.minKey
                int upper = self.maxKey
                bool arithmetic = self.arithmeticDense
                array<int> dense = self.denseSlots
                for key in queryKeys
                    int slot = -1
                    if key >= lower and key <= upper
                        if arithmetic
                            slot := key - lower
                        else
                            slot := dense.get(key - lower)
                    result.push(slot)
                    if slot >= 0
                        hits += 1
            LookupPolicy.dictionary =>
                map<int, int> lookup = self.lookup
                for key in queryKeys
                    int mapped = lookup.get(key)
                    int slot = -1
                    if not na(mapped)
                        slot := mapped
                    result.push(slot)
                    if slot >= 0
                        hits += 1
            LookupPolicy.linear =>
                array<int> keys = self.keys
                bool takeLast = self.linearLastWins
                for key in queryKeys
                    int slot = -1
                    if takeLast
                        slot := keys.lastindexof(key)
                    else
                        slot := keys.indexof(key)
                    result.push(slot)
                    if slot >= 0
                        hits += 1
            =>
                if self.sortedIdentity
                    array<int> keys = self.keys
                    for key in queryKeys
                        int slot = keys.binary_search(key)
                        result.push(slot)
                        if slot >= 0
                            hits += 1
                else
                    array<int> sortedKeys = self.sortedKeys
                    array<int> sortedSlots = self.sortedSlots
                    for key in queryKeys
                        int position = sortedKeys.binary_search(key)
                        int slot = -1
                        if position >= 0
                            slot := sortedSlots.get(position)
                        result.push(slot)
                        if slot >= 0
                            hits += 1
        self.queryCount += querySize
        if self.settings.collectStats
            self.hitCount += hits
            self.missCount += querySize - hits
    else if self.state != _OP_STATE_SEALED and self.settings.strictLifecycle
        runtime.error("OptiPine.IntIndex: findMany() before buildFinish().")
    result

//@function Reads the key stored in a slot.
//@param self IntIndex receiver.
//@param slot Slot index.
//@returns The key, or na when the slot does not exist.
export method keyAt(IntIndex self, int slot) =>
    int key = na
    if slot >= 0 and slot < self.keys.size()
        key := self.keys.get(slot)
    key

//@function Number of keys added.
//@param self IntIndex receiver.
//@returns The entry count.
export method entryCount(IntIndex self) =>
    na(self.keys) ? 0 : self.keys.size()

//@function Representation currently in use.
//@param self IntIndex receiver.
//@returns The active LookupPolicy. Never `automatic`.
export method mode(IntIndex self) =>
    self.activePolicy

//@function Whether the index is sealed and ready for queries.
//@param self IntIndex receiver.
//@returns true after `buildFinish()`.
export method sealed(IntIndex self) =>
    self.state == _OP_STATE_SEALED

//@function The insertion-order key array, indexed by slot. Tier 2.
//          Ownership: borrowed structure-owned view.
//          Mutation: read-only by contract. Rebuild to change the keys.
//          Lifetime: valid until the next `buildBegin()`, `clear()` or
//          `reset()`.
//          Persistence: reacquire after that boundary.
//@param self IntIndex receiver.
//@returns The keys, in insertion order, so element `slot` is `keyAt(slot)`.
export method keysView(IntIndex self) =>
    _opEnsureIntIndex(self)
    self.keys

//@function Snapshot of index telemetry.
//@param self IntIndex receiver.
//@returns A newly allocated IndexStats owned by the caller.
export method stats(IntIndex self) =>
    _opEnsureIntIndex(self)
    IndexStats.new(
      self.settings.policy,
      self.activePolicy,
      self.keys.size(),
      self.queryCount,
      self.hitCount,
      self.missCount,
      self.buildCount,
      self.promotionCount,
      self.duplicatesChecked ? self.duplicateCount : -1,
      self.keys.size() > 0 ? self.maxKey - self.minKey + 1 : 0,
      self.ascending,
      self.consecutive,
      self.duplicatesChecked)

//@function Empties the index, retaining every allocation. The configuration
//          and the cumulative build and promotion counters are preserved.
//@param self IntIndex receiver.
//@returns Self for chaining.
export method clear(IntIndex self) =>
    _opEnsureIntIndex(self)
    self.keys.clear()
    self.sortedKeys.clear()
    self.sortedSlots.clear()
    self.lookup.clear()
    self.denseSlots.clear()
    self.state := _OP_STATE_EMPTY
    self.activePolicy := LookupPolicy.linear
    self.minKey := na
    self.maxKey := na
    self.ascending := true
    self.nonDecreasing := true
    self.consecutive := false
    self.arithmeticDense := false
    self.sortedIdentity := true
    self.linearLastWins := false
    self.trackQueries := false
    self.promotionArmed := false
    self.duplicatesChecked := false
    self.duplicateCount := 0
    self.queryCount := 0
    self.hitCount := 0
    self.missCount := 0
    self.promotionThreshold := 0
    self

_opStoreBuildCount(array<int> keys, int valueCount) =>
    int keyCount = na(keys) ? 0 : keys.size()
    if keyCount != valueCount
        runtime.error("OptiPine.IntStore: build() expects exactly one value per key.")
    keyCount

//@function Replaces the configuration and empties the index.
//@param self IntIndex receiver.
//@param settings New configuration, or na for the automatic defaults.
//@returns Self for chaining.
export method reset(IntIndex self, IndexConfig settings = na) =>
    _opEnsureIntIndex(self)
    self.clear()
    self.settings := na(settings) ? indexConfig() : settings
    self.buildCount := 0
    self.promotionCount := 0
    self

//@type One key to many integer values, in contiguous flat storage.
//      Tier: 2 (Composable) | Stability: Stable
//      Ownership: every array is structure-owned. The `*View()` accessors
//      return borrowed read-only references valid until the next build or
//      clear; see each method for the full contract. None of them supports
//      mutation, so none is named as an unsafe path.
//      Complexity: build is O(pairs) plus the IntIndex build. `find()` is the
//      configured IntIndex lookup. `rangeByKey()` is that plus O(1).
//      Allocation: collection objects are reused across rebuilds.
//      Limits: 100,000 associations and 50,000 distinct keys.
//@field index Key directory. Assigns one slot per distinct key.
//@field offsets Bucket start positions, `bucketCount + 1` entries.
//@field values Flat values, grouped by bucket in slot order.
//@field counts Per-bucket pair counts. Build workspace.
//@field fill Per-bucket write cursors used by the second build pass. Build
//       workspace.
//@field pairSlots Bucket slot of every pair. Build workspace.
//@field buildSlots Key-to-bucket-slot map used by the first build pass.
//@field distinctKeys Distinct keys in first-appearance order; bucket slot i
//       owns `distinctKeys[i]`. Build workspace.
//@field pairKeys Recorded key of every pair, spanning the open build.
//@field pairValues Recorded value of every pair, spanning the open build.
//@field building True between `buildBegin()` and `buildFinish()`.
//@field sealed True once a build has completed.
//@field strictLifecycle Raise on lifecycle misuse instead of degrading.
export type IntBuckets
    IntIndex index = na
    array<int> offsets = na
    array<int> values = na
    array<int> counts = na
    array<int> fill = na
    array<int> pairSlots = na
    map<int, int> buildSlots = na
    array<int> distinctKeys = na
    array<int> pairKeys = na
    array<int> pairValues = na
    bool building = false
    bool sealed = false
    bool strictLifecycle = true

//@function Creates an empty bucket multimap. Tier 2.
//@param settings Optional key-directory configuration. na uses automatic
//       lookup. Repeated keys are grouped before the directory is built.
//@param strictLifecycle Raise on lifecycle misuse. Default true.
//@returns A new IntBuckets.
export intBuckets(IndexConfig settings = na, bool strictLifecycle = true) =>
    IndexConfig resolved = na(settings) ?
      indexConfig(LookupPolicy.automatic, DuplicatePolicy.firstWins) : settings
    IntBuckets result = IntBuckets.new()
    result.index := intIndex(resolved)
    result.offsets := array.new<int>()
    result.values := array.new<int>()
    result.counts := array.new<int>()
    result.fill := array.new<int>()
    result.pairSlots := array.new<int>()
    result.buildSlots := map.new<int, int>()
    result.distinctKeys := array.new<int>()
    result.pairKeys := array.new<int>()
    result.pairValues := array.new<int>()
    result.strictLifecycle := strictLifecycle
    result

_opEnsureBuckets(IntBuckets self) =>
    if na(self.index)
        self.index := intIndex(indexConfig(LookupPolicy.automatic, DuplicatePolicy.firstWins))
    if na(self.offsets)
        self.offsets := array.new<int>()
    if na(self.values)
        self.values := array.new<int>()
    if na(self.counts)
        self.counts := array.new<int>()
        self.fill := array.new<int>()
        self.pairSlots := array.new<int>()
        self.buildSlots := map.new<int, int>()
        self.distinctKeys := array.new<int>()
    if na(self.pairKeys)
        self.pairKeys := array.new<int>()
    if na(self.pairValues)
        self.pairValues := array.new<int>()
    self

//@function Opens an explicit build. Tier 2.
//@param self IntBuckets receiver.
//@returns Self for chaining.
export method buildBegin(IntBuckets self) =>
    _opEnsureBuckets(self)
    if self.building and self.strictLifecycle
        runtime.error("OptiPine.IntBuckets: buildBegin called while a build was already open.")
    self.building := true
    self.sealed := false
    self.pairKeys.clear()
    self.pairValues.clear()
    self

//@function Records one key/value pair. Tier 2.
//@param self IntBuckets receiver.
//@param key Bucket key. Repeated keys accumulate into one bucket.
//@param value Integer payload, typically a slot into a caller-owned array.
//@returns Self for chaining.
export method add(IntBuckets self, int key, int value) =>
    if not self.building
        if self.strictLifecycle
            runtime.error("OptiPine.IntBuckets: add called outside a build.")
        else
            self.buildBegin()
    if na(key)
        runtime.error("OptiPine.IntBuckets: na is not a valid key.")
    self.pairKeys.push(key)
    self.pairValues.push(value)
    self

//@function Records a batch of key/value pairs. Tier 2.
//@param self IntBuckets receiver.
//@param keyArray Keys. Must be the same length as `valueArray`.
//@param valueArray Values, positionally paired with `keyArray`.
//@returns Self for chaining.
export method addMany(IntBuckets self, array<int> keyArray, array<int> valueArray) =>
    if not self.building
        if self.strictLifecycle
            runtime.error("OptiPine.IntBuckets: addMany called outside a build.")
        else
            self.buildBegin()
    int keyCount = na(keyArray) ? 0 : keyArray.size()
    int valueCount = na(valueArray) ? 0 : valueArray.size()
    if keyCount != valueCount
        runtime.error("OptiPine.IntBuckets: keyArray and valueArray must be the same length.")
    if keyCount > 0
        array<int> pairKeys = self.pairKeys
        array<int> pairValues = self.pairValues
        int lastIndex = keyCount - 1
        for index = 0 to lastIndex
            int key = keyArray.get(index)
            if na(key)
                runtime.error("OptiPine.IntBuckets: na is not a valid key.")
            pairKeys.push(key)
            pairValues.push(valueArray.get(index))
    self

//@function Closes the build and packs every bucket into contiguous storage.
//          Tier 2.
//@param self IntBuckets receiver.
//@param expectedQueries Optional query-count hint forwarded to the key
//       directory so it can choose its representation.
//@returns Self for chaining.
export method buildFinish(IntBuckets self, int expectedQueries = na) =>
    _opEnsureBuckets(self)
    if not self.building
        if self.strictLifecycle and not self.sealed
            runtime.error("OptiPine.IntBuckets: buildFinish called without buildBegin.")
        self
    else
        array<int> pairKeys = self.pairKeys
        array<int> pairValues = self.pairValues
        int pairCount = pairKeys.size()
        if pairCount > _OP_MAX_ARRAY
            runtime.error("OptiPine.IntBuckets: pair count exceeds the 100,000-element limit.")

        map<int, int> buildSlots = self.buildSlots
        array<int> distinctKeys = self.distinctKeys
        array<int> counts = self.counts
        array<int> pairSlots = self.pairSlots
        buildSlots.clear()
        distinctKeys.clear()
        counts.clear()
        _opResizeInt(pairSlots, pairCount)

        if pairCount > 0
            int lastPair = pairCount - 1
            for index = 0 to lastPair
                int key = pairKeys.get(index)
                int existing = buildSlots.get(key)
                int slot = 0
                if na(existing)
                    slot := distinctKeys.size()
                    if slot >= _OP_MAX_MAP_PAIRS
                        runtime.error(
                          "OptiPine.IntBuckets: distinct key count exceeds the 50,000-pair map limit.")
                    distinctKeys.push(key)
                    buildSlots.put(key, slot)
                    counts.push(1)
                else
                    slot := existing
                    counts.set(slot, counts.get(slot) + 1)
                pairSlots.set(index, slot)

        self.index.clear()
        self.index.buildBegin(false)
        self.index.addMany(distinctKeys)
        self.index.buildFinish(expectedQueries)

        int bucketCount = counts.size()
        _opResizeInt(self.offsets, bucketCount + 1)
        array<int> fill = self.fill
        _opResizeInt(fill, bucketCount)
        int running = 0
        if bucketCount > 0
            array<int> offsets = self.offsets
            int lastSlot = bucketCount - 1
            for slot = 0 to lastSlot
                offsets.set(slot, running)
                fill.set(slot, running)
                running += counts.get(slot)
        self.offsets.set(bucketCount, running)

        _opResizeInt(self.values, pairCount)
        if pairCount > 0
            array<int> values = self.values
            int lastPair = pairCount - 1
            for index = 0 to lastPair
                int slot = pairSlots.get(index)
                int cursor = fill.get(slot)
                values.set(cursor, pairValues.get(index))
                fill.set(slot, cursor + 1)
        self.building := false
        self.sealed := true
        self

//@function Builds every bucket from two parallel arrays in one call. Tier 2.
//@param self IntBuckets receiver.
//@param keyArray Keys. Must be the same length as `valueArray`.
//@param valueArray Values, positionally paired with `keyArray`.
//@param expectedQueries Optional query-count hint for the key directory.
//@returns Self for chaining.
export method buildFromPairs(
  IntBuckets self,
  array<int> keyArray,
  array<int> valueArray,
  int expectedQueries = na) =>
    _opEnsureBuckets(self)
    int keyCount = na(keyArray) ? 0 : keyArray.size()
    int valueCount = na(valueArray) ? 0 : valueArray.size()
    if keyCount != valueCount
        runtime.error("OptiPine.IntBuckets: keyArray and valueArray must be the same length.")
    self.building := false
    self.buildBegin()
    self.addMany(keyArray, valueArray)
    self.buildFinish(expectedQueries)

//@function Resolves a key to its bucket slot. Tier 2.
//@param self IntBuckets receiver.
//@param key Key to look up.
//@returns The bucket slot, or -1 when the key has no bucket.
export method find(IntBuckets self, int key) =>
    na(self.index) ? -1 : self.index.find(key)

//@function Reports whether a key has a bucket. Tier 2.
//@param self IntBuckets receiver.
//@param key Key to test.
//@returns true when the key was seen during the build.
export method contains(IntBuckets self, int key) =>
    self.find(key) >= 0

//@function Contiguous value range of one bucket slot. Tier 2.
//@param self IntBuckets receiver.
//@param slot Bucket slot from `find()`.
//@returns [start, count] into the flat value array. [0, 0] for an invalid
//         slot. A zero count still needs a guard before a counted loop.
export method rangeBySlot(IntBuckets self, int slot) =>
    int start = 0
    int count = 0
    if not na(self.offsets) and slot >= 0 and slot + 1 < self.offsets.size()
        start := self.offsets.get(slot)
        count := self.offsets.get(slot + 1) - start
    [start, count]

//@function Contiguous value range of one key. Tier 2.
//@param self IntBuckets receiver.
//@param key Key to look up.
//@returns [start, count] into the flat value array, or [-1, 0] on a miss.
export method rangeByKey(IntBuckets self, int key) =>
    int slot = self.find(key)
    int start = -1
    int count = 0
    if slot >= 0
        [rangeStart, rangeCount] = self.rangeBySlot(slot)
        start := rangeStart
        count := rangeCount
    [start, count]

//@function Reads one value from the flat value array. Tier 2.
//@param self IntBuckets receiver.
//@param flatIndex Index into the flat values, typically `start + offset`.
//@returns The value, or na when the index is outside the built range.
export method valueAt(IntBuckets self, int flatIndex) =>
    int found = na
    if not na(self.values) and flatIndex >= 0 and flatIndex < self.values.size()
        found := self.values.get(flatIndex)
    found

//@function Reads one value from a bucket by its position within the bucket.
//          Tier 2.
//@param self IntBuckets receiver.
//@param slot Bucket slot.
//@param offset Position inside the bucket, 0-based.
//@returns The value, or na when either coordinate is out of range.
export method bucketValueAt(IntBuckets self, int slot, int offset) =>
    [start, count] = self.rangeBySlot(slot)
    int found = na
    if offset >= 0 and offset < count
        found := self.values.get(start + offset)
    found

//@function Number of values in one bucket. Tier 2.
//@param self IntBuckets receiver.
//@param slot Bucket slot.
//@returns The occupancy, or 0 for an invalid slot.
export method bucketSize(IntBuckets self, int slot) =>
    [start, count] = self.rangeBySlot(slot)
    count

//@function Number of distinct keys. Tier 2.
//@param self IntBuckets receiver.
//@returns The bucket count.
export method bucketCount(IntBuckets self) =>
    na(self.offsets) or self.offsets.size() == 0 ? 0 : self.offsets.size() - 1

//@function Total number of stored pairs. Tier 2.
//@param self IntBuckets receiver.
//@returns The flat value count.
export method pairCount(IntBuckets self) =>
    na(self.values) ? 0 : self.values.size()

//@function Key owning one bucket slot. Tier 2.
//@param self IntBuckets receiver.
//@param slot Bucket slot.
//@returns The key, or na for an invalid slot.
export method keyAt(IntBuckets self, int slot) =>
    na(self.index) ? na : self.index.keyAt(slot)

//@function Reports whether a build has completed. Tier 2.
//@param self IntBuckets receiver.
//@returns true once `buildFinish()` has run.
export method isSealed(IntBuckets self) =>
    self.sealed

//@function Empties every bucket while retaining all allocations. Tier 2.
//@param self IntBuckets receiver.
//@returns Self for chaining.
export method clear(IntBuckets self) =>
    _opEnsureBuckets(self)
    self.index.clear()
    self.offsets.clear()
    self.values.clear()
    self.counts.clear()
    self.fill.clear()
    self.pairSlots.clear()
    self.buildSlots.clear()
    self.distinctKeys.clear()
    self.pairKeys.clear()
    self.pairValues.clear()
    self.building := false
    self.sealed := false
    self

//@function The CSR bucket boundary array. Tier 2.
//          Ownership: borrowed structure-owned view.
//          Mutation: read-only by contract.
//          Lifetime: valid until the next `buildBegin()`, `buildFinish()`,
//          `buildFromPairs()` or `clear()`.
//          Persistence: reacquire after that boundary.
//@param self IntBuckets receiver.
//@returns The bucket boundaries, `bucketCount() + 1` elements long.
export method offsetsView(IntBuckets self) =>
    self.offsets

//@function The flat value array every bucket is packed into. Tier 2.
//          Ownership: borrowed structure-owned view.
//          Mutation: read-only by contract.
//          Lifetime: valid until the next `buildBegin()`, `buildFinish()`,
//          `buildFromPairs()` or `clear()`.
//          Persistence: reacquire after that boundary.
//@param self IntBuckets receiver.
//@returns Every bucket's values, grouped and contiguous, in slot order.
export method valuesView(IntBuckets self) =>
    self.values

//@function The key array of the underlying directory. Tier 2.
//          Ownership: borrowed structure-owned view from the nested `IntIndex`.
//          Mutation: read-only by contract.
//          Lifetime: valid until the next `buildBegin()`, `buildFinish()`,
//          `buildFromPairs()` or `clear()`.
//          Persistence: reacquire after that boundary.
//@param self IntBuckets receiver.
//@returns The distinct keys, in slot order.
export method keysView(IntBuckets self) =>
    self.index.keysView()

//@type Integer-keyed int store backed by an adaptive `IntIndex`.
//      Tier: 1 (Quick) | Stability: Stable
//      Ownership: `valuesView()` returns a borrowed read-only view whose
//      element order matches slot order. `getMany()` fills a caller-owned
//      array or allocates one.
//      Complexity: inherited from `IntIndex`, plus O(1) per value access.
//      `build()` is one index build plus one native payload refill.
//      Empty value: na. Use `read()` or `contains()` when a stored value
//      may equal the miss value.
//@field index Owned key directory.
//@field payload Values indexed by slot.
//@field contentRevision Advances on a successful `build()`, on a `set()` that
//       changes a value, and on a `clear()` that discarded content. Read it
//       with `revision()`.
export type IntIntStore
    IntIndex index = na
    array<int> payload = na
    int contentRevision = 0

_opBumpIntIntStore(IntIntStore self) =>
    self.contentRevision := self.contentRevision >= _OP_MAX_GENERATION ?
      0 : self.contentRevision + 1
    self

//@function Creates an integer-keyed int store.
//@param settings Index configuration, or na for the automatic defaults.
//@returns A new IntIntStore.
export intIntStore(IndexConfig settings = na) =>
    IntIntStore result = IntIntStore.new()
    result.index := intIndex(settings)
    result.payload := array.new<int>()
    result

_opEnsureIntIntStore(IntIntStore self) =>
    if na(self.index)
        self.index := intIndex()
    if na(self.payload)
        self.payload := array.new<int>()
    self

//@function Fills the store from parallel key and value arrays, replacing its
//          previous contents. Tier 1.
//          revision: bump.
//@param self IntIntStore receiver.
//@param keys Integer keys, one per value. Read only.
//@param values Values, one per key. Read only.
//@param expectedQueries Expected lookups before the next rebuild, or na.
//       Supplying it lets automatic mode pick a map immediately when
//       construction amortizes, instead of waiting for an online promotion.
//@returns The active representation the index selected.
export method build(
  IntIntStore self,
  array<int> keys,
  array<int> values,
  int expectedQueries = na) =>
    _opEnsureIntIntStore(self)
    int count = _opStoreBuildCount(keys, na(values) ? 0 : values.size())
    if count > 0
        if _opAliasInt(self.payload, values)
            runtime.error("OptiPine.IntIntStore: build values must not be the store's own value array.")
    self.index.buildBegin(true)
    self.payload.clear()
    if count > 0
        self.index.addMany(keys)
        self.payload.concat(values)
    LookupPolicy active = self.index.buildFinish(expectedQueries)
    _opBumpIntIntStore(self)
    active

//@function Current content revision. Tier 2.
//          Complexity: O(1).
//@param self IntIntStore receiver.
//@returns The current revision. Always >= 0.
export method revision(IntIntStore self) =>
    self.contentRevision

//@function Reads one value.
//@param self IntIntStore receiver.
//@param key Key to look up.
//@param fallback Returned on a miss. Defaults to na.
//@returns The stored value, or `fallback`.
export method get(IntIntStore self, int key, int fallback = na) =>
    int value = fallback
    int slot = self.index.find(key)
    if slot >= 0
        value := self.payload.get(slot)
    value

//@function Reads one value and reports whether it was present.
//@param self IntIntStore receiver.
//@param key Key to look up.
//@returns [found, value]. `value` is na on a miss.
export method read(IntIntStore self, int key) =>
    int value = na
    int slot = self.index.find(key)
    bool found = slot >= 0
    if found
        value := self.payload.get(slot)
    [found, value]

//@function Overwrites the value of an existing key. Keys cannot be added after
//          a build; only values may change. Call `build()` to change the key
//          set.
//          revision: bump-if-changed.
//@param self IntIntStore receiver.
//@param key Key to update.
//@param value New value.
//@returns true when the key existed. An identical value leaves the revision
//         unchanged.
export method set(IntIntStore self, int key, int value) =>
    int slot = self.index.find(key)
    bool found = slot >= 0
    if found
        if not _opSameInt(self.payload.get(slot), value)
            self.payload.set(slot, value)
            _opBumpIntIntStore(self)
    found

//@function Tests whether a key is present.
//@param self IntIntStore receiver.
//@param key Key to test.
//@returns true when the key resolves to a slot.
export method contains(IntIntStore self, int key) =>
    self.index.find(key) >= 0

//@function Resolves a batch of keys into values with one representation dispatch.
//@param self IntIntStore receiver.
//@param queryKeys Keys to resolve. Read only.
//@param output Optional caller-owned array. It is cleared and refilled. When
//       na, a newly allocated array is returned.
//@returns The value for each query key, in query order. na marks a miss.
export method getMany(
  IntIntStore self,
  array<int> queryKeys,
  array<int> output = na) =>
    array<int> slots = self.index.findMany(queryKeys)
    array<int> result = output
    if na(result)
        result := array.new<int>()
    else
        if _opAliasInt(self.payload, result)
            runtime.error("OptiPine.IntIntStore: getMany output must not be the value array.")
        result.clear()
    array<int> payload = self.payload
    for slot in slots
        if slot >= 0
            result.push(payload.get(slot))
        else
            result.push(na)
    result

//@function Number of stored entries.
//@param self IntIntStore receiver.
//@returns The entry count.
export method size(IntIntStore self) =>
    na(self.payload) ? 0 : self.payload.size()

//@function The stored values in slot order, without copying them. Tier 2.
//          Ownership: borrowed structure-owned view.
//          Mutation: read-only by contract. Use `set()` for writes.
//          Lifetime: valid until the next `build()` or `clear()`.
//          Persistence: do not retain it across that boundary; reacquire it.
//@param self IntIntStore receiver.
//@returns The values, indexed by slot.
export method valuesView(IntIntStore self) =>
    _opEnsureIntIntStore(self)
    self.payload

//@function Empties the store, retaining every allocation.
//          revision: bump-if-changed.
//@param self IntIntStore receiver.
//@returns Self for chaining.
export method clear(IntIntStore self) =>
    _opEnsureIntIntStore(self)
    bool hadContent = self.payload.size() > 0
    self.index.clear()
    self.payload.clear()
    if hadContent
        _opBumpIntIntStore(self)
    self

//@type Integer-keyed float store backed by an adaptive `IntIndex`.
//      Tier: 1 (Quick) | Stability: Stable
//      Ownership: `valuesView()` returns a borrowed read-only view whose
//      element order matches slot order. `getMany()` fills a caller-owned
//      array or allocates one.
//      Complexity: inherited from `IntIndex`, plus O(1) per value access.
//      `build()` is one index build plus one native payload refill.
//      Empty value: na. Use `read()` or `contains()` when a stored value
//      may equal the miss value.
//@field index Owned key directory.
//@field payload Values indexed by slot.
//@field contentRevision Advances on a successful `build()`, on a `set()` that
//       changes a value, and on a `clear()` that discarded content. Read it
//       with `revision()`.
export type IntFloatStore
    IntIndex index = na
    array<float> payload = na
    int contentRevision = 0

_opBumpIntFloatStore(IntFloatStore self) =>
    self.contentRevision := self.contentRevision >= _OP_MAX_GENERATION ?
      0 : self.contentRevision + 1
    self

//@function Creates an integer-keyed float store.
//@param settings Index configuration, or na for the automatic defaults.
//@returns A new IntFloatStore.
export intFloatStore(IndexConfig settings = na) =>
    IntFloatStore result = IntFloatStore.new()
    result.index := intIndex(settings)
    result.payload := array.new<float>()
    result

_opEnsureIntFloatStore(IntFloatStore self) =>
    if na(self.index)
        self.index := intIndex()
    if na(self.payload)
        self.payload := array.new<float>()
    self

//@function Fills the store from parallel key and value arrays, replacing its
//          previous contents. Tier 1.
//          revision: bump.
//@param self IntFloatStore receiver.
//@param keys Integer keys, one per value. Read only.
//@param values Values, one per key. Read only.
//@param expectedQueries Expected lookups before the next rebuild, or na.
//       Supplying it lets automatic mode pick a map immediately when
//       construction amortizes, instead of waiting for an online promotion.
//@returns The active representation the index selected.
export method build(
  IntFloatStore self,
  array<int> keys,
  array<float> values,
  int expectedQueries = na) =>
    _opEnsureIntFloatStore(self)
    int count = _opStoreBuildCount(keys, na(values) ? 0 : values.size())
    if count > 0
        if _opAliasFloat(self.payload, values)
            runtime.error("OptiPine.IntFloatStore: build values must not be the store's own value array.")
    self.index.buildBegin(true)
    self.payload.clear()
    if count > 0
        self.index.addMany(keys)
        self.payload.concat(values)
    LookupPolicy active = self.index.buildFinish(expectedQueries)
    _opBumpIntFloatStore(self)
    active

//@function Current content revision. Tier 2.
//          Complexity: O(1).
//@param self IntFloatStore receiver.
//@returns The current revision. Always >= 0.
export method revision(IntFloatStore self) =>
    self.contentRevision

//@function Reads one value.
//@param self IntFloatStore receiver.
//@param key Key to look up.
//@param fallback Returned on a miss. Defaults to na.
//@returns The stored value, or `fallback`.
export method get(IntFloatStore self, int key, float fallback = na) =>
    float value = fallback
    int slot = self.index.find(key)
    if slot >= 0
        value := self.payload.get(slot)
    value

//@function Reads one value and reports whether it was present.
//@param self IntFloatStore receiver.
//@param key Key to look up.
//@returns [found, value]. `value` is na on a miss.
export method read(IntFloatStore self, int key) =>
    float value = na
    int slot = self.index.find(key)
    bool found = slot >= 0
    if found
        value := self.payload.get(slot)
    [found, value]

//@function Overwrites the value of an existing key. Keys cannot be added after
//          a build; only values may change. Call `build()` to change the key
//          set.
//          revision: bump-if-changed.
//@param self IntFloatStore receiver.
//@param key Key to update.
//@param value New value.
//@returns true when the key existed. An identical value leaves the revision
//         unchanged.
export method set(IntFloatStore self, int key, float value) =>
    int slot = self.index.find(key)
    bool found = slot >= 0
    if found
        if not _opSameFloat(self.payload.get(slot), value)
            self.payload.set(slot, value)
            _opBumpIntFloatStore(self)
    found

//@function Tests whether a key is present.
//@param self IntFloatStore receiver.
//@param key Key to test.
//@returns true when the key resolves to a slot.
export method contains(IntFloatStore self, int key) =>
    self.index.find(key) >= 0

//@function Resolves a batch of keys into values with one representation dispatch.
//@param self IntFloatStore receiver.
//@param queryKeys Keys to resolve. Read only.
//@param output Optional caller-owned array. It is cleared and refilled. When
//       na, a newly allocated array is returned.
//@returns The value for each query key, in query order. na marks a miss.
export method getMany(
  IntFloatStore self,
  array<int> queryKeys,
  array<float> output = na) =>
    array<int> slots = self.index.findMany(queryKeys)
    array<float> result = output
    if na(result)
        result := array.new<float>()
    else
        if _opAliasFloat(self.payload, result)
            runtime.error("OptiPine.IntFloatStore: getMany output must not be the value array.")
        result.clear()
    array<float> payload = self.payload
    for slot in slots
        if slot >= 0
            result.push(payload.get(slot))
        else
            result.push(na)
    result

//@function Number of stored entries.
//@param self IntFloatStore receiver.
//@returns The entry count.
export method size(IntFloatStore self) =>
    na(self.payload) ? 0 : self.payload.size()

//@function The stored values in slot order, without copying them. Tier 2.
//          Ownership: borrowed structure-owned view.
//          Mutation: read-only by contract. Use `set()` for writes.
//          Lifetime: valid until the next `build()` or `clear()`.
//          Persistence: do not retain it across that boundary; reacquire it.
//@param self IntFloatStore receiver.
//@returns The values, indexed by slot.
export method valuesView(IntFloatStore self) =>
    _opEnsureIntFloatStore(self)
    self.payload

//@function Empties the store, retaining every allocation.
//          revision: bump-if-changed.
//@param self IntFloatStore receiver.
//@returns Self for chaining.
export method clear(IntFloatStore self) =>
    _opEnsureIntFloatStore(self)
    bool hadContent = self.payload.size() > 0
    self.index.clear()
    self.payload.clear()
    if hadContent
        _opBumpIntFloatStore(self)
    self

//@type Integer-keyed bool store backed by an adaptive `IntIndex`.
//      Tier: 1 (Quick) | Stability: Stable
//      Ownership: `valuesView()` returns a borrowed read-only view whose
//      element order matches slot order. `getMany()` fills a caller-owned
//      array or allocates one.
//      Complexity: inherited from `IntIndex`, plus O(1) per value access.
//      `build()` is one index build plus one native payload refill.
//      Empty value: false. Use `read()` or `contains()` when a stored value
//      may equal the miss value.
//@field index Owned key directory.
//@field payload Values indexed by slot.
//@field contentRevision Advances on a successful `build()`, on a `set()` that
//       changes a value, and on a `clear()` that discarded content. Read it
//       with `revision()`.
export type IntBoolStore
    IntIndex index = na
    array<bool> payload = na
    int contentRevision = 0

_opBumpIntBoolStore(IntBoolStore self) =>
    self.contentRevision := self.contentRevision >= _OP_MAX_GENERATION ?
      0 : self.contentRevision + 1
    self

//@function Creates an integer-keyed bool store.
//@param settings Index configuration, or na for the automatic defaults.
//@returns A new IntBoolStore.
export intBoolStore(IndexConfig settings = na) =>
    IntBoolStore result = IntBoolStore.new()
    result.index := intIndex(settings)
    result.payload := array.new<bool>()
    result

_opEnsureIntBoolStore(IntBoolStore self) =>
    if na(self.index)
        self.index := intIndex()
    if na(self.payload)
        self.payload := array.new<bool>()
    self

//@function Fills the store from parallel key and value arrays, replacing its
//          previous contents. Tier 1.
//          revision: bump.
//@param self IntBoolStore receiver.
//@param keys Integer keys, one per value. Read only.
//@param values Values, one per key. Read only.
//@param expectedQueries Expected lookups before the next rebuild, or na.
//       Supplying it lets automatic mode pick a map immediately when
//       construction amortizes, instead of waiting for an online promotion.
//@returns The active representation the index selected.
export method build(
  IntBoolStore self,
  array<int> keys,
  array<bool> values,
  int expectedQueries = na) =>
    _opEnsureIntBoolStore(self)
    int count = _opStoreBuildCount(keys, na(values) ? 0 : values.size())
    if count > 0
        if _opAliasBool(self.payload, values)
            runtime.error("OptiPine.IntBoolStore: build values must not be the store's own value array.")
    self.index.buildBegin(true)
    self.payload.clear()
    if count > 0
        self.index.addMany(keys)
        self.payload.concat(values)
    LookupPolicy active = self.index.buildFinish(expectedQueries)
    _opBumpIntBoolStore(self)
    active

//@function Current content revision. Tier 2.
//          Complexity: O(1).
//@param self IntBoolStore receiver.
//@returns The current revision. Always >= 0.
export method revision(IntBoolStore self) =>
    self.contentRevision

//@function Reads one value.
//@param self IntBoolStore receiver.
//@param key Key to look up.
//@param fallback Returned on a miss. Defaults to false.
//@returns The stored value, or `fallback`.
export method get(IntBoolStore self, int key, bool fallback = false) =>
    bool value = fallback
    int slot = self.index.find(key)
    if slot >= 0
        value := self.payload.get(slot)
    value

//@function Reads one value and reports whether it was present.
//@param self IntBoolStore receiver.
//@param key Key to look up.
//@returns [found, value]. `value` is false on a miss.
export method read(IntBoolStore self, int key) =>
    bool value = false
    int slot = self.index.find(key)
    bool found = slot >= 0
    if found
        value := self.payload.get(slot)
    [found, value]

//@function Overwrites the value of an existing key. Keys cannot be added after
//          a build; only values may change. Call `build()` to change the key
//          set.
//          revision: bump-if-changed.
//@param self IntBoolStore receiver.
//@param key Key to update.
//@param value New value.
//@returns true when the key existed. An identical value leaves the revision
//         unchanged.
export method set(IntBoolStore self, int key, bool value) =>
    int slot = self.index.find(key)
    bool found = slot >= 0
    if found
        if not _opSameBoolValue(self.payload.get(slot), value)
            self.payload.set(slot, value)
            _opBumpIntBoolStore(self)
    found

//@function Tests whether a key is present.
//@param self IntBoolStore receiver.
//@param key Key to test.
//@returns true when the key resolves to a slot.
export method contains(IntBoolStore self, int key) =>
    self.index.find(key) >= 0

//@function Resolves a batch of keys into values with one representation dispatch.
//@param self IntBoolStore receiver.
//@param queryKeys Keys to resolve. Read only.
//@param output Optional caller-owned array. It is cleared and refilled. When
//       na, a newly allocated array is returned.
//@returns The value for each query key, in query order. false marks a miss.
export method getMany(
  IntBoolStore self,
  array<int> queryKeys,
  array<bool> output = na) =>
    array<int> slots = self.index.findMany(queryKeys)
    array<bool> result = output
    if na(result)
        result := array.new<bool>()
    else
        if _opAliasBool(self.payload, result)
            runtime.error("OptiPine.IntBoolStore: getMany output must not be the value array.")
        result.clear()
    array<bool> payload = self.payload
    for slot in slots
        if slot >= 0
            result.push(payload.get(slot))
        else
            result.push(false)
    result

//@function Number of stored entries.
//@param self IntBoolStore receiver.
//@returns The entry count.
export method size(IntBoolStore self) =>
    na(self.payload) ? 0 : self.payload.size()

//@function The stored values in slot order, without copying them. Tier 2.
//          Ownership: borrowed structure-owned view.
//          Mutation: read-only by contract. Use `set()` for writes.
//          Lifetime: valid until the next `build()` or `clear()`.
//          Persistence: do not retain it across that boundary; reacquire it.
//@param self IntBoolStore receiver.
//@returns The values, indexed by slot.
export method valuesView(IntBoolStore self) =>
    _opEnsureIntBoolStore(self)
    self.payload

//@function Empties the store, retaining every allocation.
//          revision: bump-if-changed.
//@param self IntBoolStore receiver.
//@returns Self for chaining.
export method clear(IntBoolStore self) =>
    _opEnsureIntBoolStore(self)
    bool hadContent = self.payload.size() > 0
    self.index.clear()
    self.payload.clear()
    if hadContent
        _opBumpIntBoolStore(self)
    self

//@type Integer-keyed string store backed by an adaptive `IntIndex`.
//      Tier: 1 (Quick) | Stability: Stable
//      Ownership: `valuesView()` returns a borrowed read-only view whose
//      element order matches slot order. `getMany()` fills a caller-owned
//      array or allocates one.
//      Complexity: inherited from `IntIndex`, plus O(1) per value access.
//      `build()` is one index build plus one native payload refill.
//      Empty value: na. Use `read()` or `contains()` when a stored value
//      may equal the miss value.
//@field index Owned key directory.
//@field payload Values indexed by slot.
//@field contentRevision Advances on a successful `build()`, on a `set()` that
//       changes a value, and on a `clear()` that discarded content. Read it
//       with `revision()`.
export type IntStringStore
    IntIndex index = na
    array<string> payload = na
    int contentRevision = 0

_opBumpIntStringStore(IntStringStore self) =>
    self.contentRevision := self.contentRevision >= _OP_MAX_GENERATION ?
      0 : self.contentRevision + 1
    self

//@function Creates an integer-keyed string store.
//@param settings Index configuration, or na for the automatic defaults.
//@returns A new IntStringStore.
export intStringStore(IndexConfig settings = na) =>
    IntStringStore result = IntStringStore.new()
    result.index := intIndex(settings)
    result.payload := array.new<string>()
    result

_opEnsureIntStringStore(IntStringStore self) =>
    if na(self.index)
        self.index := intIndex()
    if na(self.payload)
        self.payload := array.new<string>()
    self

//@function Fills the store from parallel key and value arrays, replacing its
//          previous contents. Tier 1.
//          revision: bump.
//@param self IntStringStore receiver.
//@param keys Integer keys, one per value. Read only.
//@param values Values, one per key. Read only.
//@param expectedQueries Expected lookups before the next rebuild, or na.
//       Supplying it lets automatic mode pick a map immediately when
//       construction amortizes, instead of waiting for an online promotion.
//@returns The active representation the index selected.
export method build(
  IntStringStore self,
  array<int> keys,
  array<string> values,
  int expectedQueries = na) =>
    _opEnsureIntStringStore(self)
    int count = _opStoreBuildCount(keys, na(values) ? 0 : values.size())
    if count > 0
        if _opAliasString(self.payload, values)
            runtime.error("OptiPine.IntStringStore: build values must not be the store's own value array.")
    self.index.buildBegin(true)
    self.payload.clear()
    if count > 0
        self.index.addMany(keys)
        self.payload.concat(values)
    LookupPolicy active = self.index.buildFinish(expectedQueries)
    _opBumpIntStringStore(self)
    active

//@function Current content revision. Tier 2.
//          Complexity: O(1).
//@param self IntStringStore receiver.
//@returns The current revision. Always >= 0.
export method revision(IntStringStore self) =>
    self.contentRevision

//@function Reads one value.
//@param self IntStringStore receiver.
//@param key Key to look up.
//@param fallback Returned on a miss. Defaults to na.
//@returns The stored value, or `fallback`.
export method get(IntStringStore self, int key, string fallback = na) =>
    string value = fallback
    int slot = self.index.find(key)
    if slot >= 0
        value := self.payload.get(slot)
    value

//@function Reads one value and reports whether it was present.
//@param self IntStringStore receiver.
//@param key Key to look up.
//@returns [found, value]. `value` is na on a miss.
export method read(IntStringStore self, int key) =>
    string value = na
    int slot = self.index.find(key)
    bool found = slot >= 0
    if found
        value := self.payload.get(slot)
    [found, value]

//@function Overwrites the value of an existing key. Keys cannot be added after
//          a build; only values may change. Call `build()` to change the key
//          set.
//          revision: bump-if-changed.
//@param self IntStringStore receiver.
//@param key Key to update.
//@param value New value.
//@returns true when the key existed. An identical value leaves the revision
//         unchanged.
export method set(IntStringStore self, int key, string value) =>
    int slot = self.index.find(key)
    bool found = slot >= 0
    if found
        if not _opSameString(self.payload.get(slot), value)
            self.payload.set(slot, value)
            _opBumpIntStringStore(self)
    found

//@function Tests whether a key is present.
//@param self IntStringStore receiver.
//@param key Key to test.
//@returns true when the key resolves to a slot.
export method contains(IntStringStore self, int key) =>
    self.index.find(key) >= 0

//@function Resolves a batch of keys into values with one representation dispatch.
//@param self IntStringStore receiver.
//@param queryKeys Keys to resolve. Read only.
//@param output Optional caller-owned array. It is cleared and refilled. When
//       na, a newly allocated array is returned.
//@returns The value for each query key, in query order. na marks a miss.
export method getMany(
  IntStringStore self,
  array<int> queryKeys,
  array<string> output = na) =>
    array<int> slots = self.index.findMany(queryKeys)
    array<string> result = output
    if na(result)
        result := array.new<string>()
    else
        if _opAliasString(self.payload, result)
            runtime.error("OptiPine.IntStringStore: getMany output must not be the value array.")
        result.clear()
    array<string> payload = self.payload
    for slot in slots
        if slot >= 0
            result.push(payload.get(slot))
        else
            result.push(na)
    result

//@function Number of stored entries.
//@param self IntStringStore receiver.
//@returns The entry count.
export method size(IntStringStore self) =>
    na(self.payload) ? 0 : self.payload.size()

//@function The stored values in slot order, without copying them. Tier 2.
//          Ownership: borrowed structure-owned view.
//          Mutation: read-only by contract. Use `set()` for writes.
//          Lifetime: valid until the next `build()` or `clear()`.
//          Persistence: do not retain it across that boundary; reacquire it.
//@param self IntStringStore receiver.
//@returns The values, indexed by slot.
export method valuesView(IntStringStore self) =>
    _opEnsureIntStringStore(self)
    self.payload

//@function Empties the store, retaining every allocation.
//          revision: bump-if-changed.
//@param self IntStringStore receiver.
//@returns Self for chaining.
export method clear(IntStringStore self) =>
    _opEnsureIntStringStore(self)
    bool hadContent = self.payload.size() > 0
    self.index.clear()
    self.payload.clear()
    if hadContent
        _opBumpIntStringStore(self)
    self

//@type Integer-keyed color store backed by an adaptive `IntIndex`.
//      Tier: 1 (Quick) | Stability: Stable
//      Ownership: `valuesView()` returns a borrowed read-only view whose
//      element order matches slot order. `getMany()` fills a caller-owned
//      array or allocates one.
//      Complexity: inherited from `IntIndex`, plus O(1) per value access.
//      `build()` is one index build plus one native payload refill.
//      Empty value: na. Use `read()` or `contains()` when a stored value
//      may equal the miss value.
//@field index Owned key directory.
//@field payload Values indexed by slot.
//@field contentRevision Advances on a successful `build()`, on a `set()` that
//       changes a value, and on a `clear()` that discarded content. Read it
//       with `revision()`.
export type IntColorStore
    IntIndex index = na
    array<color> payload = na
    int contentRevision = 0

_opBumpIntColorStore(IntColorStore self) =>
    self.contentRevision := self.contentRevision >= _OP_MAX_GENERATION ?
      0 : self.contentRevision + 1
    self

//@function Creates an integer-keyed color store.
//@param settings Index configuration, or na for the automatic defaults.
//@returns A new IntColorStore.
export intColorStore(IndexConfig settings = na) =>
    IntColorStore result = IntColorStore.new()
    result.index := intIndex(settings)
    result.payload := array.new<color>()
    result

_opEnsureIntColorStore(IntColorStore self) =>
    if na(self.index)
        self.index := intIndex()
    if na(self.payload)
        self.payload := array.new<color>()
    self

//@function Fills the store from parallel key and value arrays, replacing its
//          previous contents. Tier 1.
//          revision: bump.
//@param self IntColorStore receiver.
//@param keys Integer keys, one per value. Read only.
//@param values Values, one per key. Read only.
//@param expectedQueries Expected lookups before the next rebuild, or na.
//       Supplying it lets automatic mode pick a map immediately when
//       construction amortizes, instead of waiting for an online promotion.
//@returns The active representation the index selected.
export method build(
  IntColorStore self,
  array<int> keys,
  array<color> values,
  int expectedQueries = na) =>
    _opEnsureIntColorStore(self)
    int count = _opStoreBuildCount(keys, na(values) ? 0 : values.size())
    if count > 0
        if _opAliasColor(self.payload, values)
            runtime.error("OptiPine.IntColorStore: build values must not be the store's own value array.")
    self.index.buildBegin(true)
    self.payload.clear()
    if count > 0
        self.index.addMany(keys)
        self.payload.concat(values)
    LookupPolicy active = self.index.buildFinish(expectedQueries)
    _opBumpIntColorStore(self)
    active

//@function Current content revision. Tier 2.
//          Complexity: O(1).
//@param self IntColorStore receiver.
//@returns The current revision. Always >= 0.
export method revision(IntColorStore self) =>
    self.contentRevision

//@function Reads one value.
//@param self IntColorStore receiver.
//@param key Key to look up.
//@param fallback Returned on a miss. Defaults to na.
//@returns The stored value, or `fallback`.
export method get(IntColorStore self, int key, color fallback = na) =>
    color value = fallback
    int slot = self.index.find(key)
    if slot >= 0
        value := self.payload.get(slot)
    value

//@function Reads one value and reports whether it was present.
//@param self IntColorStore receiver.
//@param key Key to look up.
//@returns [found, value]. `value` is na on a miss.
export method read(IntColorStore self, int key) =>
    color value = na
    int slot = self.index.find(key)
    bool found = slot >= 0
    if found
        value := self.payload.get(slot)
    [found, value]

//@function Overwrites the value of an existing key. Keys cannot be added after
//          a build; only values may change. Call `build()` to change the key
//          set.
//          revision: bump-if-changed.
//@param self IntColorStore receiver.
//@param key Key to update.
//@param value New value.
//@returns true when the key existed. An identical value leaves the revision
//         unchanged.
export method set(IntColorStore self, int key, color value) =>
    int slot = self.index.find(key)
    bool found = slot >= 0
    if found
        if not _opSameColor(self.payload.get(slot), value)
            self.payload.set(slot, value)
            _opBumpIntColorStore(self)
    found

//@function Tests whether a key is present.
//@param self IntColorStore receiver.
//@param key Key to test.
//@returns true when the key resolves to a slot.
export method contains(IntColorStore self, int key) =>
    self.index.find(key) >= 0

//@function Resolves a batch of keys into values with one representation dispatch.
//@param self IntColorStore receiver.
//@param queryKeys Keys to resolve. Read only.
//@param output Optional caller-owned array. It is cleared and refilled. When
//       na, a newly allocated array is returned.
//@returns The value for each query key, in query order. na marks a miss.
export method getMany(
  IntColorStore self,
  array<int> queryKeys,
  array<color> output = na) =>
    array<int> slots = self.index.findMany(queryKeys)
    array<color> result = output
    if na(result)
        result := array.new<color>()
    else
        if _opAliasColor(self.payload, result)
            runtime.error("OptiPine.IntColorStore: getMany output must not be the value array.")
        result.clear()
    array<color> payload = self.payload
    for slot in slots
        if slot >= 0
            result.push(payload.get(slot))
        else
            result.push(na)
    result

//@function Number of stored entries.
//@param self IntColorStore receiver.
//@returns The entry count.
export method size(IntColorStore self) =>
    na(self.payload) ? 0 : self.payload.size()

//@function The stored values in slot order, without copying them. Tier 2.
//          Ownership: borrowed structure-owned view.
//          Mutation: read-only by contract. Use `set()` for writes.
//          Lifetime: valid until the next `build()` or `clear()`.
//          Persistence: do not retain it across that boundary; reacquire it.
//@param self IntColorStore receiver.
//@returns The values, indexed by slot.
export method valuesView(IntColorStore self) =>
    _opEnsureIntColorStore(self)
    self.payload

//@function Empties the store, retaining every allocation.
//          revision: bump-if-changed.
//@param self IntColorStore receiver.
//@returns Self for chaining.
export method clear(IntColorStore self) =>
    _opEnsureIntColorStore(self)
    bool hadContent = self.payload.size() > 0
    self.index.clear()
    self.payload.clear()
    if hadContent
        _opBumpIntColorStore(self)
    self

//@type Configuration for frame-scoped and explicitly managed slot pools.
//      Tier: 2 (Composable) | Stability: Stable
//@field strictLifecycle Raise on lifecycle violations such as `finish()`
//       without `begin()`. When false those calls degrade to a defined
//       fallback instead.
//@field maxSlots Upper bound on the number of distinct slots ever allocated.
//       Values above 50,000 are clamped, because the key directory is a Pine
//       map and a map holds at most 50,000 pairs.
export type SlotPoolConfig
    bool strictLifecycle = true
    int maxSlots = 50000

//@function Creates a slot-pool configuration. Tier 2.
//@param strictLifecycle Raise on lifecycle violations.
//@param maxSlots Upper bound on allocated slots. Clamped to 50,000.
//@returns A new SlotPoolConfig.
export slotPoolConfig(bool strictLifecycle = true, int maxSlots = 50000) =>
    SlotPoolConfig.new(strictLifecycle,
      math.min(math.max(nz(maxSlots, 1), 1), _OP_MAX_MAP_PAIRS))

//@function Preset: slots live for exactly one frame unless re-acquired.
//@returns A SlotPoolConfig.
export poolConfigFrameRetained() =>
    slotPoolConfig()

//@function Preset: lifecycle violations degrade instead of raising, for
//          scripts that must never halt on a misuse.
//@returns A SlotPoolConfig.
export poolConfigLenient() =>
    slotPoolConfig(strictLifecycle = false)

//@type Maps integer keys to stable, reusable slots with frame-scoped lifetime.
//      Tier: 2 (Composable) | Stability: Stable
//      Ownership: `active()`, `retired()` and the list `finish()` returns are
//      borrowed structure-owned views; see those methods for the full
//      contract. `activeCopy()` and `retiredCopy()` return caller-owned
//      storage.
//      Complexity: `acquire()` O(1); `finish()` O(slots active in the previous
//      frame).
//      Recycling order: `finish()` retires the previous frame's slots in the
//      order they were acquired, and `acquire()` takes the most recently freed
//      slot first. This is deterministic and part of the contract, so a caller
//      may rely on it when reasoning about payload reuse.
//      Limits: 50,000 live keys, or `SlotPoolConfig.maxSlots` when lower.
//@field settings Configuration reference.
//@field keyToSlot Live key directory.
//@field slotKeys Key currently assigned to each slot.
//@field slotGeneration Frame in which each slot was last acquired.
//@field activeSlots Slots acquired during the frame in progress.
//@field previousSlots Slots acquired during the preceding frame.
//@field freeSlots Slots available for reuse.
//@field retiredSlots Slots retired by the most recent `finish()`.
//@field generation Current frame counter.
//@field frameOpen Whether a frame is currently open.
export type SlotCache
    SlotPoolConfig settings = na
    map<int, int> keyToSlot = na
    array<int> slotKeys = na
    array<int> slotGeneration = na
    array<int> activeSlots = na
    array<int> previousSlots = na
    array<int> freeSlots = na
    array<int> retiredSlots = na
    int generation = 0
    bool frameOpen = false

//@function Creates a frame-scoped slot cache.
//@param settings Configuration, or na for the defaults.
//@returns A new SlotCache.
export slotCache(SlotPoolConfig settings = na) =>
    SlotCache result = SlotCache.new()
    result.settings := na(settings) ? slotPoolConfig() : settings
    result.keyToSlot := map.new<int, int>()
    result.slotKeys := array.new<int>()
    result.slotGeneration := array.new<int>()
    result.activeSlots := array.new<int>()
    result.previousSlots := array.new<int>()
    result.freeSlots := array.new<int>()
    result.retiredSlots := array.new<int>()
    result

_opEnsureSlotCache(SlotCache self) =>
    if na(self.settings)
        self.settings := slotPoolConfig()
    if na(self.keyToSlot)
        self.keyToSlot := map.new<int, int>()
    if na(self.slotKeys)
        self.slotKeys := array.new<int>()
    if na(self.slotGeneration)
        self.slotGeneration := array.new<int>()
    if na(self.activeSlots)
        self.activeSlots := array.new<int>()
    if na(self.previousSlots)
        self.previousSlots := array.new<int>()
    if na(self.freeSlots)
        self.freeSlots := array.new<int>()
    if na(self.retiredSlots)
        self.retiredSlots := array.new<int>()
    self

_opSlotCacheRetire(SlotCache self) =>
    int previousCount = self.previousSlots.size()
    if previousCount > 0
        int stamp = self.generation
        array<int> previousSlots = self.previousSlots
        array<int> slotGeneration = self.slotGeneration
        array<int> slotKeys = self.slotKeys
        array<int> freeSlots = self.freeSlots
        array<int> retiredSlots = self.retiredSlots
        map<int, int> keyToSlot = self.keyToSlot
        for index = 0 to previousCount - 1
            int slot = previousSlots.get(index)
            if slotGeneration.get(slot) != stamp
                keyToSlot.remove(slotKeys.get(slot))
                freeSlots.push(slot)
                retiredSlots.push(slot)
    self.previousSlots.clear()
    self.frameOpen := false
    self

//@function Opens a frame. The slots active in the previous frame become the
//          retirement candidates, and the retired list is emptied.
//@param self SlotCache receiver.
//@returns Self for chaining.
export method begin(SlotCache self) =>
    _opEnsureSlotCache(self)
    if self.frameOpen
        if self.settings.strictLifecycle
            runtime.error("OptiPine.SlotCache: begin called while a frame was already open.")
        _opSlotCacheRetire(self)
        self.retiredSlots.clear()
    if self.generation >= _OP_MAX_GENERATION
        if self.slotGeneration.size() > 0
            self.slotGeneration.fill(-1)
        self.generation := 0
    self.generation += 1
    array<int> retiredActive = self.activeSlots
    self.activeSlots := self.previousSlots
    self.previousSlots := retiredActive
    self.activeSlots.clear()
    self.retiredSlots.clear()
    self.frameOpen := true
    self

//@function Gets or creates the stable slot for a key and marks it active.
//@param self SlotCache receiver.
//@param key Integer key. na keys are rejected.
//@returns [slot, created]. A created slot may be recycled storage whose
//         payload still holds the previous occupant's values.
export method acquire(SlotCache self, int key) =>
    if na(key)
        runtime.error("OptiPine.SlotCache: na is not a valid key.")
    if not self.frameOpen
        self.begin()
    int slot = self.keyToSlot.get(key)
    bool created = na(slot)
    if created
        if self.freeSlots.size() > 0
            slot := self.freeSlots.pop()
            self.slotKeys.set(slot, key)
        else
            if self.slotKeys.size() >= self.settings.maxSlots
                runtime.error("OptiPine.SlotCache: slot limit of " +
                  str.tostring(self.settings.maxSlots) + " reached.")
            slot := self.slotKeys.size()
            self.slotKeys.push(key)
            self.slotGeneration.push(-1)
        self.keyToSlot.put(key, slot)
    if self.slotGeneration.get(slot) != self.generation
        self.slotGeneration.set(slot, self.generation)
        self.activeSlots.push(slot)
    [slot, created]

//@function Closes the frame, retires every slot not acquired during it, and
//          returns the retired list so the caller can reset those payloads.
//          Ownership: borrowed structure-owned view. It is the same array
//          `retired()` returns.
//          Mutation: read-only by contract; mutation is unsupported.
//          Lifetime: valid until the next `begin()` or `clear()`.
//          Persistence: do not retain it across that boundary; use
//          `retiredCopy()` when the result must outlive the frame.
//@param self SlotCache receiver.
//@returns The slots retired by this call, in the order they were acquired.
//         Their payloads may be reset now or left intact for overwrite when
//         the slots are recycled.
export method finish(SlotCache self) =>
    _opEnsureSlotCache(self)
    if not self.frameOpen
        if self.settings.strictLifecycle
            runtime.error("OptiPine.SlotCache: finish called without begin.")
    else
        _opSlotCacheRetire(self)
    self.retiredSlots

//@function The slots acquired during the frame in progress. Tier 2.
//          Ownership: borrowed structure-owned view.
//          Mutation: read-only by contract; mutation is unsupported. This is
//          the array `finish()` reads to decide what survives the frame.
//          Lifetime: valid until the next `begin()` or `clear()`.
//          Persistence: do not retain it across that boundary; use
//          `activeCopy()` for an owned snapshot.
//@param self SlotCache receiver.
//@returns The active slots, in acquisition order.
export method active(SlotCache self) =>
    _opEnsureSlotCache(self)
    self.activeSlots

//@function The slots retired by the most recent `finish()`. Tier 2.
//          Ownership: borrowed structure-owned view.
//          Mutation: read-only by contract; mutation is unsupported.
//          Lifetime: valid until the next `begin()` or `clear()`.
//          Persistence: do not retain it across that boundary; use
//          `retiredCopy()` for an owned snapshot.
//@param self SlotCache receiver.
//@returns The retired slots, in retirement order.
export method retired(SlotCache self) =>
    _opEnsureSlotCache(self)
    self.retiredSlots

//@function Copies the active slot list into caller-owned storage.
//@param self SlotCache receiver.
//@param output Optional caller-owned array. It is cleared and refilled.
//@returns The active slots in acquisition order, owned by the caller.
export method activeCopy(SlotCache self, array<int> output = na) =>
    _opEnsureSlotCache(self)
    _opSnapshotInt(self.activeSlots, output, "OptiPine.SlotCache.activeCopy")

//@function Copies the retired slot list into caller-owned storage.
//@param self SlotCache receiver.
//@param output Optional caller-owned array. It is cleared and refilled.
//@returns The retired slots in retirement order, owned by the caller.
export method retiredCopy(SlotCache self, array<int> output = na) =>
    _opEnsureSlotCache(self)
    _opSnapshotInt(self.retiredSlots, output, "OptiPine.SlotCache.retiredCopy")

//@function Looks up a key without changing its active status.
//@param self SlotCache receiver.
//@param key Key to look up.
//@returns The slot, or -1 on a miss.
export method find(SlotCache self, int key) =>
    _opEnsureSlotCache(self)
    int slot = self.keyToSlot.get(key)
    int found = -1
    if not na(slot)
        found := slot
    found

//@function Tests whether a key is live.
//@param self SlotCache receiver.
//@param key Key to test.
//@returns true when the key currently owns a slot.
export method contains(SlotCache self, int key) =>
    _opEnsureSlotCache(self)
    self.keyToSlot.contains(key)

//@function Reads the key currently assigned to a slot.
//@param self SlotCache receiver.
//@param slot Slot index.
//@returns The key, or na when the slot does not exist. A retired slot still
//         reports its last key until it is recycled.
export method keyAt(SlotCache self, int slot) =>
    _opEnsureSlotCache(self)
    int key = na
    if slot >= 0 and slot < self.slotKeys.size()
        key := self.slotKeys.get(slot)
    key

//@function Total slots ever allocated, including free ones.
//@param self SlotCache receiver.
//@returns The slot count.
export method slotCount(SlotCache self) =>
    _opEnsureSlotCache(self)
    self.slotKeys.size()

//@function Number of live keys.
//@param self SlotCache receiver.
//@returns The live count.
export method size(SlotCache self) =>
    _opEnsureSlotCache(self)
    self.keyToSlot.size()

//@function Number of slots available for reuse.
//@param self SlotCache receiver.
//@returns The free count.
export method freeCount(SlotCache self) =>
    _opEnsureSlotCache(self)
    self.freeSlots.size()

//@function Current frame counter, mainly for diagnostics.
//@param self SlotCache receiver.
//@returns The generation.
export method frame(SlotCache self) =>
    self.generation

//@function Empties the cache, retaining every allocation.
//@param self SlotCache receiver.
//@returns Self for chaining.
export method clear(SlotCache self) =>
    _opEnsureSlotCache(self)
    self.keyToSlot.clear()
    self.slotKeys.clear()
    self.slotGeneration.clear()
    self.activeSlots.clear()
    self.previousSlots.clear()
    self.freeSlots.clear()
    self.retiredSlots.clear()
    self.generation := 0
    self.frameOpen := false
    self

//@type Maps integer keys to stable, reusable slots with explicit lifetime.
//      Tier: 1 (Quick) | Stability: Stable
//      Ownership: `slots()` returns a borrowed structure-owned view; see the
//      method for the full contract. Its order is unspecified after any
//      `release()`, because removal is a swap with the last element.
//      Complexity: `acquire()`, `release()`, `find()` are O(1); `slots()` is
//      O(1) to obtain and O(live count) to traverse.
//      Limits: 50,000 live keys, or `SlotPoolConfig.maxSlots` when lower.
//@field settings Configuration reference.
//@field keyToSlot Live key directory.
//@field slotKeys Key currently assigned to each slot.
//@field slotPosition Position of each live slot inside `liveSlots`, or -1.
//@field liveSlots Compact list of live slots, in unspecified order.
//@field freeSlots Slots available for reuse.
export type StablePool
    SlotPoolConfig settings = na
    map<int, int> keyToSlot = na
    array<int> slotKeys = na
    array<int> slotPosition = na
    array<int> liveSlots = na
    array<int> freeSlots = na

//@function Creates an explicitly managed slot pool.
//@param settings Configuration, or na for the defaults.
//@returns A new StablePool.
export stablePool(SlotPoolConfig settings = na) =>
    StablePool result = StablePool.new()
    result.settings := na(settings) ? slotPoolConfig() : settings
    result.keyToSlot := map.new<int, int>()
    result.slotKeys := array.new<int>()
    result.slotPosition := array.new<int>()
    result.liveSlots := array.new<int>()
    result.freeSlots := array.new<int>()
    result

_opEnsureStablePool(StablePool self) =>
    if na(self.settings)
        self.settings := slotPoolConfig()
    if na(self.keyToSlot)
        self.keyToSlot := map.new<int, int>()
    if na(self.slotKeys)
        self.slotKeys := array.new<int>()
    if na(self.slotPosition)
        self.slotPosition := array.new<int>()
    if na(self.liveSlots)
        self.liveSlots := array.new<int>()
    if na(self.freeSlots)
        self.freeSlots := array.new<int>()
    self

_opStablePoolDetach(StablePool self, int slot) =>
    array<int> liveSlots = self.liveSlots
    array<int> slotPosition = self.slotPosition
    int position = slotPosition.get(slot)
    if position >= 0
        int last = liveSlots.size() - 1
        int moved = liveSlots.get(last)
        liveSlots.set(position, moved)
        slotPosition.set(moved, position)
        liveSlots.pop()
        slotPosition.set(slot, -1)
    self

//@function Gets or creates the stable slot for a key.
//@param self StablePool receiver.
//@param key Integer key. na keys are rejected.
//@returns [slot, created]. A created slot may be recycled storage whose
//         payload still holds the previous occupant's values.
export method acquire(StablePool self, int key) =>
    _opEnsureStablePool(self)
    if na(key)
        runtime.error("OptiPine.StablePool: na is not a valid key.")
    int slot = self.keyToSlot.get(key)
    bool created = na(slot)
    if created
        if self.freeSlots.size() > 0
            slot := self.freeSlots.pop()
            self.slotKeys.set(slot, key)
        else
            if self.slotKeys.size() >= self.settings.maxSlots
                runtime.error("OptiPine.StablePool: slot limit of " +
                  str.tostring(self.settings.maxSlots) + " reached.")
            slot := self.slotKeys.size()
            self.slotKeys.push(key)
            self.slotPosition.push(-1)
        self.keyToSlot.put(key, slot)
        self.slotPosition.set(slot, self.liveSlots.size())
        self.liveSlots.push(slot)
    [slot, created]

//@function Releases the slot owned by a key and returns it to the free list.
//@param self StablePool receiver.
//@param key Key to release.
//@returns The released slot, or -1 when the key was not live.
export method release(StablePool self, int key) =>
    _opEnsureStablePool(self)
    int slot = self.keyToSlot.get(key)
    int released = -1
    if not na(slot)
        released := slot
        self.keyToSlot.remove(key)
        _opStablePoolDetach(self, released)
        self.freeSlots.push(released)
    released

//@function Releases a slot by index rather than by key.
//@param self StablePool receiver.
//@param slot Slot to release.
//@returns true when the slot was live and has been released.
export method releaseSlot(StablePool self, int slot) =>
    _opEnsureStablePool(self)
    bool ok = false
    if slot >= 0 and slot < self.slotKeys.size() and self.slotPosition.get(slot) >= 0
        ok := true
        self.keyToSlot.remove(self.slotKeys.get(slot))
        _opStablePoolDetach(self, slot)
        self.freeSlots.push(slot)
    ok

//@function Looks up a key.
//@param self StablePool receiver.
//@param key Key to look up.
//@returns The slot, or -1 on a miss.
export method find(StablePool self, int key) =>
    _opEnsureStablePool(self)
    int slot = self.keyToSlot.get(key)
    int found = -1
    if not na(slot)
        found := slot
    found

//@function Tests whether a key is live.
//@param self StablePool receiver.
//@param key Key to test.
//@returns true when the key currently owns a slot.
export method contains(StablePool self, int key) =>
    _opEnsureStablePool(self)
    self.keyToSlot.contains(key)

//@function Reads the key currently assigned to a slot.
//@param self StablePool receiver.
//@param slot Slot index.
//@returns The key, or na when the slot does not exist. A released slot still
//         reports its last key until it is recycled.
export method keyAt(StablePool self, int slot) =>
    _opEnsureStablePool(self)
    int key = na
    if slot >= 0 and slot < self.slotKeys.size()
        key := self.slotKeys.get(slot)
    key

//@function The slots currently live in the pool. Tier 1.
//          Ownership: borrowed structure-owned view.
//          Mutation: read-only by contract; mutation is unsupported. The pool
//          releases in O(1) by swapping with the last element and mirrors each
//          position in `slotPosition`, so reordering it desynchronizes both.
//          Lifetime: valid until the next `acquire()`, `release()`,
//          `releaseSlot()` or `clear()`.
//          Persistence: do not retain it across that boundary; reacquire it.
//          Order is unspecified, and a `release()` reorders the survivors.
//@param self StablePool receiver.
//@returns The live slots, in unspecified order.
export method slots(StablePool self) =>
    _opEnsureStablePool(self)
    self.liveSlots

//@function Number of live keys.
//@param self StablePool receiver.
//@returns The live count.
export method size(StablePool self) =>
    _opEnsureStablePool(self)
    self.liveSlots.size()

//@function Total slots ever allocated, including released ones.
//@param self StablePool receiver.
//@returns The slot count.
export method slotCount(StablePool self) =>
    _opEnsureStablePool(self)
    self.slotKeys.size()

//@function Number of slots available for reuse.
//@param self StablePool receiver.
//@returns The free count.
export method freeCount(StablePool self) =>
    _opEnsureStablePool(self)
    self.freeSlots.size()

//@function Empties the pool, retaining every allocation.
//@param self StablePool receiver.
//@returns Self for chaining.
export method clear(StablePool self) =>
    _opEnsureStablePool(self)
    self.keyToSlot.clear()
    self.slotKeys.clear()
    self.slotPosition.clear()
    self.liveSlots.clear()
    self.freeSlots.clear()
    self

//@type Configuration for row rings.
//      Tier: 2 (Composable) | Stability: Stable
//@field capacity Number of rows the ring can hold. Values below 1 become 1.
//@field width Values per row. Values below 1 become 1.
//@field preallocate Allocate `capacity * width` elements up front. When false
//       the backing array grows on demand and never shrinks, which trades a
//       smaller initial footprint for growth work during the first cycle.
export type RingConfig
    int capacity = 1
    int width = 1
    bool preallocate = true

//@function Creates a row-ring configuration. Tier 2.
//@param capacity Number of rows.
//@param width Values per row.
//@param preallocate Allocate the full backing array up front.
//@returns A new RingConfig with capacity and width clamped to at least 1.
export ringConfig(int capacity = 1, int width = 1, bool preallocate = true) =>
    RingConfig.new(math.max(nz(capacity, 1), 1), math.max(nz(width, 1), 1), preallocate)

//@type Ring-buffer layout independent of payload type.
//      Tier: 2 (Composable) | Stability: Stable
//      Ownership: value semantics; no collections.
//      Complexity: every operation O(1). No allocation.
//@field capacity Physical slot count. Always >= 1.
//@field size Occupied slots. Never exceeds capacity.
//@field head Physical slot holding logical index 0.
export type RingCursor
    int capacity = 1
    int size = 0
    int head = 0

//@function Creates a ring cursor.
//@param capacity Physical slot count. Values below 1 become 1.
//@returns A new empty RingCursor.
export ringCursor(int capacity) =>
    RingCursor.new(math.max(nz(capacity, 1), 1), 0, 0)

//@function Reserves the physical slot for one new newest item and advances the
//          ring. Once the ring is full this overwrites the oldest slot.
//@param self RingCursor receiver.
//@returns The physical slot to write.
export method reserve(RingCursor self) =>
    int slot = 0
    if self.size >= self.capacity
        slot := self.head
        self.head := (self.head + 1) % self.capacity
    else
        slot := self.size
        self.size += 1
    slot

//@function Maps a chronological logical index to a physical slot.
//@param self RingCursor receiver.
//@param logicalIndex 0 is the oldest occupied row.
//@returns The physical slot, or -1 when the logical index is not occupied.
export method physical(RingCursor self, int logicalIndex) =>
    _opCircularPhysical(logicalIndex, self.head, self.size, self.capacity)

//@function Maps a physical slot back to its chronological logical index.
//@param self RingCursor receiver.
//@param physicalSlot Physical slot index.
//@returns The logical index, or -1 when the slot is not occupied.
export method logical(RingCursor self, int physicalSlot) =>
    _opCircularLogical(physicalSlot, self.head, self.size, self.capacity)

//@function Physical slot at an offset back from the newest item.
//@param self RingCursor receiver.
//@param offset 0 is the newest row, 1 the one before it, and so on.
//@returns The physical slot, or -1 when the offset is out of range.
export method newest(RingCursor self, int offset = 0) =>
    _opCircularPhysical(self.size - 1 - math.max(nz(offset, 0), 0), self.head, self.size, self.capacity)

//@function Physical slot at an offset forward from the oldest item.
//@param self RingCursor receiver.
//@param offset 0 is the oldest row.
//@returns The physical slot, or -1 when the offset is out of range.
export method oldest(RingCursor self, int offset = 0) =>
    _opCircularPhysical(math.max(nz(offset, 0), 0), self.head, self.size, self.capacity)

//@function Whether every physical slot is occupied.
//@param self RingCursor receiver.
//@returns true when size has reached capacity.
export method full(RingCursor self) =>
    self.size >= self.capacity

//@function Number of occupied slots.
//@param self RingCursor receiver.
//@returns The occupied count.
export method count(RingCursor self) =>
    self.size

//@function Physical slot count.
//@param self RingCursor receiver.
//@returns The capacity.
export method limit(RingCursor self) =>
    self.capacity

//@function Empties the ring without touching any payload storage.
//@param self RingCursor receiver.
//@returns Self for chaining.
export method clear(RingCursor self) =>
    self.size := 0
    self.head := 0
    self

_opCopyCircularFloatRows(
  array<float> store,
  int width,
  RingCursor cursor,
  int startLogicalRow,
  int rowCount,
  array<float> output = na,
  string label = "OptiPine.ringWindow") =>
    if na(store)
        runtime.error(label + ": store cannot be na.")
    if width <= 0
        runtime.error(label + ": width must be positive.")
    int limit = 0
    int count = 0
    if not na(cursor)
        limit := cursor.limit()
        count := cursor.count()
    int safeRows = math.max(nz(rowCount, 0), 0)
    int safeStart = nz(startLogicalRow, 0)
    if safeRows > 0 and (safeStart < 0 or safeStart + safeRows > count)
        runtime.error(label + ": window is outside the retained range.")

    array<float> result = output
    if na(result)
        result := array.new<float>()
    else
        if _opAliasFloat(store, result)
            runtime.error(label + ": store and output must be different arrays.")
        result.clear()

    if safeRows > 0
        int firstPhysical = cursor.physical(safeStart)
        int leadingRows = math.min(safeRows, limit - firstPhysical)
        int leadingStart = firstPhysical * width
        int leadingEnd = leadingStart + leadingRows * width
        int trailingCells = (safeRows - leadingRows) * width
        if store.size() < math.max(leadingEnd, trailingCells)
            runtime.error(label + ": store does not cover the requested window.")
        if leadingEnd > leadingStart
            result.concat(store.slice(leadingStart, leadingEnd))
        if trailingCells > 0
            result.concat(store.slice(0, trailingCells))
    result

_opCopyCircularIntRows(
  array<int> store,
  int width,
  RingCursor cursor,
  int startLogicalRow,
  int rowCount,
  array<int> output = na,
  string label = "OptiPine.ringWindow") =>
    if na(store)
        runtime.error(label + ": store cannot be na.")
    if width <= 0
        runtime.error(label + ": width must be positive.")
    int limit = 0
    int count = 0
    if not na(cursor)
        limit := cursor.limit()
        count := cursor.count()
    int safeRows = math.max(nz(rowCount, 0), 0)
    int safeStart = nz(startLogicalRow, 0)
    if safeRows > 0 and (safeStart < 0 or safeStart + safeRows > count)
        runtime.error(label + ": window is outside the retained range.")

    array<int> result = output
    if na(result)
        result := array.new<int>()
    else
        if _opAliasInt(store, result)
            runtime.error(label + ": store and output must be different arrays.")
        result.clear()

    if safeRows > 0
        int firstPhysical = cursor.physical(safeStart)
        int leadingRows = math.min(safeRows, limit - firstPhysical)
        int leadingStart = firstPhysical * width
        int leadingEnd = leadingStart + leadingRows * width
        int trailingCells = (safeRows - leadingRows) * width
        if store.size() < math.max(leadingEnd, trailingCells)
            runtime.error(label + ": store does not cover the requested window.")
        if leadingEnd > leadingStart
            result.concat(store.slice(leadingStart, leadingEnd))
        if trailingCells > 0
            result.concat(store.slice(0, trailingCells))
    result

//@type Fixed-capacity ring of equal-width float rows in one flat array.
//      Tier: 1 scalar and row access; Tier 3 physical and unchecked access.
//      Stability: Stable
//      Ownership: `rawView()` and `rowView()` are borrowed read-only views.
//      `rawUnsafe()` is a borrowed mutable view and requires an open edit
//      scope. Copy methods fill a caller-owned array or allocate one.
//      Complexity: `push()` is O(width); `pushValue()` and every scalar
//      accessor are O(1); `revision()` is O(1).
//      Allocation: none at steady state when preallocated.
//      Limits: capacity * width may not exceed 100,000.
//@field cursor Owned ring layout.
//@field width Values per row. Always >= 1.
//@field data Row-major backing storage.
//@field preallocated Whether the backing array was sized at construction.
//@field contentRevision Advances when logical content or membership changes.
//@field editOpen Whether an `editBegin()` scope is open.
export type FloatRowRing
    RingCursor cursor = na
    int width = 1
    array<float> data = na
    bool preallocated = true
    int contentRevision = 0
    bool editOpen = false

_opBumpFloatRowRing(FloatRowRing self) =>
    self.contentRevision := self.contentRevision >= _OP_MAX_GENERATION ?
      0 : self.contentRevision + 1
    self

//@function Creates a flat float row ring.
//@param capacity Number of rows. Values below 1 become 1.
//@param width Values per row. Values below 1 become 1.
//@param preallocate Allocate `capacity * width` elements up front.
//@param fillValue Initial value for preallocated storage.
//@returns A new FloatRowRing.
export floatRowRing(int capacity, int width, bool preallocate = true, float fillValue = 0.0) =>
    int safeCapacity = math.max(nz(capacity, 1), 1)
    int safeWidth = math.max(nz(width, 1), 1)
    if safeCapacity * safeWidth > _OP_MAX_ARRAY
        runtime.error("OptiPine.FloatRowRing: capacity * width exceeds the 100,000-element array limit.")
    FloatRowRing result = FloatRowRing.new()
    result.cursor := ringCursor(safeCapacity)
    result.width := safeWidth
    result.preallocated := preallocate
    if preallocate
        result.data := array.new<float>(safeCapacity * safeWidth, fillValue)
    else
        result.data := array.new<float>()
    result

//@function Creates a flat float row ring from a configuration object. Tier 2.
//@param settings Ring configuration.
//@param fillValue Initial value for preallocated storage.
//@returns A new FloatRowRing.
export floatRowRingFrom(RingConfig settings, float fillValue = 0.0) =>
    RingConfig safeSettings = na(settings) ? ringConfig() : settings
    floatRowRing(safeSettings.capacity, safeSettings.width, safeSettings.preallocate, fillValue)

_opEnsureFloatRowRing(FloatRowRing self) =>
    if na(self.cursor)
        self.cursor := ringCursor(1)
    if na(self.data)
        self.data := array.new<float>()
    if self.width < 1
        self.width := 1
    self

//@function Appends one complete row as the newest row.
//          revision: bump.
//@param self FloatRowRing receiver.
//@param row Exactly `width` values.
//@returns The physical slot written.
export method push(FloatRowRing self, array<float> row) =>
    _opEnsureFloatRowRing(self)
    if na(row) or row.size() != self.width
        runtime.error("OptiPine.FloatRowRing: push expects a row of exactly " +
          str.tostring(self.width) + " values.")
    int width = self.width
    int slot = self.cursor.reserve()
    int base = slot * width
    array<float> data = self.data
    if data.size() < base + width
        _opGrowFloat(data, base + width)
    for column = 0 to width - 1
        data.set(base + column, row.get(column))
    _opBumpFloatRowRing(self)
    slot

//@function Appends one scalar as the newest row of a width-1 ring without
//          allocating a row array. Tier 1.
//          revision: bump.
//@param self FloatRowRing receiver. Its width must be 1.
//@param value The value to append.
//@returns The physical slot written.
export method pushValue(FloatRowRing self, float value) =>
    _opEnsureFloatRowRing(self)
    if self.width != 1
        runtime.error("OptiPine.FloatRowRing: pushValue requires width 1; this ring has width " +
          str.tostring(self.width) + ". Use push() with a full row.")
    int slot = self.cursor.reserve()
    array<float> data = self.data
    if data.size() < slot + 1
        _opGrowFloat(data, slot + 1)
    data.set(slot, value)
    _opBumpFloatRowRing(self)
    slot

//@function Advances the ring and returns the physical slot for the new newest
//          row without writing anything. Tier 3.
//          Precondition: write every column with `writeUnchecked()` before the
//          reserved row is observed.
//          revision: bump.
//@param self FloatRowRing receiver.
//@returns The physical slot to write.
export method reserveRowUnchecked(FloatRowRing self) =>
    _opEnsureFloatRowRing(self)
    int slot = self.cursor.reserve()
    int required = slot * self.width + self.width
    if self.data.size() < required
        _opGrowFloat(self.data, required)
    _opBumpFloatRowRing(self)
    slot

//@function Writes a complete row into an existing physical slot without
//          advancing the ring. Tier 3.
//          revision: bump on a valid write.
//@param self FloatRowRing receiver.
//@param slot Physical slot index.
//@param row Exactly `width` values.
//@returns true when the slot and row width were valid.
export method writePhysical(FloatRowRing self, int slot, array<float> row) =>
    _opEnsureFloatRowRing(self)
    bool ok = slot >= 0 and slot < self.cursor.capacity and not na(row) and row.size() == self.width
    if ok
        int width = self.width
        int base = slot * width
        array<float> data = self.data
        if data.size() < base + width
            _opGrowFloat(data, base + width)
        for column = 0 to width - 1
            data.set(base + column, row.get(column))
        _opBumpFloatRowRing(self)
    ok

//@function Writes one value by physical address with no validation. Tier 3.
//          revision: bump.
//@param self FloatRowRing receiver.
//@param slot Physical slot index. The caller guarantees it is in range and
//       that the backing storage already covers it.
//@param column Column index. The caller guarantees 0 <= column < width.
//@param value Value to write.
//@returns Self for chaining.
export method writeUnchecked(FloatRowRing self, int slot, int column, float value) =>
    self.data.set(slot * self.width + column, value)
    _opBumpFloatRowRing(self)
    self

//@function Reads one value by chronological row and column.
//@param self FloatRowRing receiver.
//@param logicalRow 0 is the oldest occupied row.
//@param column Column index.
//@returns The value, or na when the address is not occupied.
export method at(FloatRowRing self, int logicalRow, int column) =>
    float value = na
    if column >= 0 and column < self.width
        int physical = self.cursor.physical(logicalRow)
        if physical >= 0
            int index = physical * self.width + column
            if index < self.data.size()
                value := self.data.get(index)
    value

//@function Writes one value by chronological row and column.
//          revision: bump-if-changed.
//@param self FloatRowRing receiver.
//@param logicalRow 0 is the oldest occupied row.
//@param column Column index.
//@param value Value to write.
//@returns true when the address was occupied. An identical value leaves the
//         revision unchanged.
export method setAt(FloatRowRing self, int logicalRow, int column, float value) =>
    bool ok = false
    if column >= 0 and column < self.width
        int physical = self.cursor.physical(logicalRow)
        if physical >= 0
            int index = physical * self.width + column
            if index < self.data.size()
                if not _opSameFloat(self.data.get(index), value)
                    self.data.set(index, value)
                    _opBumpFloatRowRing(self)
                ok := true
    ok

//@function Reads one value at an offset back from the newest row.
//@param self FloatRowRing receiver.
//@param offset 0 is the newest row.
//@param column Column index.
//@returns The value, or na when the address is not occupied.
export method newestAt(FloatRowRing self, int offset, int column) =>
    float value = na
    if column >= 0 and column < self.width
        int physical = self.cursor.newest(offset)
        if physical >= 0
            int index = physical * self.width + column
            if index < self.data.size()
                value := self.data.get(index)
    value

//@function Gathers selected chronological rows into one flat array.
//@param self FloatRowRing receiver.
//@param logicalRows Chronological row indices to gather. Read only, and it
//       must not be the same array object as `output`.
//@param output Optional caller-owned array. It is cleared and refilled. When
//       na, a newly allocated array is returned.
//@returns The gathered rows concatenated in request order. Rows that are not
//         occupied contribute `width` na values.
export method gather(FloatRowRing self, array<int> logicalRows, array<float> output = na) =>
    _opEnsureFloatRowRing(self)
    int rowCount = na(logicalRows) ? 0 : logicalRows.size()
    array<float> result = output
    if na(result)
        result := array.new<float>()
    else
        if _opAliasFloat(self.data, result)
            runtime.error("OptiPine.FloatRowRing: gather output must not be the backing array.")
        result.clear()
        if rowCount > 0 and logicalRows.size() != rowCount
            runtime.error("OptiPine.FloatRowRing: gather output must not be the request array.")
    if rowCount > 0
        int width = self.width
        array<float> data = self.data
        int dataSize = data.size()
        for logicalRow in logicalRows
            int physical = self.cursor.physical(logicalRow)
            int sourceBase = physical * width
            if physical >= 0 and sourceBase + width <= dataSize
                result.concat(data.slice(sourceBase, sourceBase + width))
            else
                for column = 0 to width - 1
                    result.push(na)
    result

//@function Copies every occupied row in chronological order.
//@param self FloatRowRing receiver.
//@param output Optional caller-owned array. It is cleared and refilled. When
//       na, a newly allocated array is returned.
//@returns All occupied rows concatenated oldest to newest.
export method chronological(FloatRowRing self, array<float> output = na) =>
    _opEnsureFloatRowRing(self)
    _opCopyCircularFloatRows(self.data, self.width, self.cursor, 0, self.cursor.count(), output,
      "OptiPine.FloatRowRing.chronological")

//@function Copies a contiguous run of chronological rows.
//@param self FloatRowRing receiver.
//@param startLogicalRow First logical row. 0 is the oldest occupied row.
//@param rowCount Number of consecutive logical rows. 0 returns an empty array.
//@param output Optional caller-owned array. It is cleared and refilled. When
//       na, a newly allocated array is returned.
//@returns The requested rows concatenated oldest to newest, `rowCount * width`
//         elements long. Raises when the window is outside the retained range.
export method window(
  FloatRowRing self,
  int startLogicalRow,
  int rowCount,
  array<float> output = na) =>
    _opEnsureFloatRowRing(self)
    _opCopyCircularFloatRows(self.data, self.width, self.cursor, startLogicalRow, rowCount,
      output, "OptiPine.FloatRowRing.window")

//@function One chronological row, without copying it. Tier 2.
//          Ownership: borrowed read-only slice of the backing array.
//          Mutation: read-only by contract. Use `setAt()` or an edit scope.
//          Lifetime: valid until the backing array is resized.
//          Persistence: reacquire after that boundary.
//@param self FloatRowRing receiver.
//@param logicalRow 0 is the oldest occupied row.
//@returns The row's `width` values, or na when the row is not occupied.
export method rowView(FloatRowRing self, int logicalRow) =>
    _opEnsureFloatRowRing(self)
    array<float> view = na
    int physical = self.cursor.physical(logicalRow)
    if physical >= 0
        int base = physical * self.width
        if base + self.width <= self.data.size()
            view := self.data.slice(base, base + self.width)
    view

//@function The flat backing array, in row-major physical order. Tier 2.
//          Ownership: borrowed structure-owned view.
//          Mutation: read-only by contract. Use an edit scope for writes.
//          Lifetime: valid until the backing array is resized.
//          Persistence: reacquire after that boundary.
//@param self FloatRowRing receiver.
//@returns The backing storage.
export method rawView(FloatRowRing self) =>
    _opEnsureFloatRowRing(self)
    self.data

//@function Opens a scope in which `rawUnsafe()` may be called. Tier 3.
//          revision: caller-repairs. `editFinish()` performs the bump.
//@param self FloatRowRing receiver.
//@returns Self for chaining.
export method editBegin(FloatRowRing self) =>
    _opEnsureFloatRowRing(self)
    if self.editOpen
        runtime.error("OptiPine.FloatRowRing: editBegin called while an edit scope was already open.")
    self.editOpen := true
    self

//@function The flat backing array, for direct mutation. Tier 3.
//          Ownership: borrowed structure-owned mutable view.
//          Mutation: overwrite elements only inside an open edit scope. Do not
//          resize the array.
//          Lifetime: do not retain it past `editFinish()`.
//          Repair: `editFinish()` advances the content revision.
//          revision: caller-repairs.
//@param self FloatRowRing receiver.
//@returns The backing storage, in row-major physical order.
export method rawUnsafe(FloatRowRing self) =>
    if not self.editOpen
        runtime.error("OptiPine.FloatRowRing: rawUnsafe requires an open editBegin() scope. " +
          "Use rawView() to read.")
    self.data

//@function Closes the edit scope and performs the invalidation the raw writes
//          could not. Tier 3.
//          revision: bump.
//@param self FloatRowRing receiver.
//@returns Self for chaining.
export method editFinish(FloatRowRing self) =>
    if not self.editOpen
        runtime.error("OptiPine.FloatRowRing: editFinish called without editBegin.")
    self.editOpen := false
    _opBumpFloatRowRing(self)

//@function Physical slot for a chronological row. Tier 3.
//@param self FloatRowRing receiver.
//@param logicalRow 0 is the oldest occupied row.
//@returns The physical slot, or -1 when the row is not occupied.
export method physicalRow(FloatRowRing self, int logicalRow) =>
    _opEnsureFloatRowRing(self)
    self.cursor.physical(logicalRow)

//@function Number of occupied rows.
//@param self FloatRowRing receiver.
//@returns The row count.
export method rowCount(FloatRowRing self) =>
    na(self.cursor) ? 0 : self.cursor.size

//@function Values per row.
//@param self FloatRowRing receiver.
//@returns The row width.
export method rowWidth(FloatRowRing self) =>
    self.width

//@function Maximum number of rows.
//@param self FloatRowRing receiver.
//@returns The ring capacity.
export method rowCapacity(FloatRowRing self) =>
    na(self.cursor) ? 0 : self.cursor.capacity

//@function Empties the ring. Preallocated storage keeps its values until they
//          are overwritten; on-demand storage is released.
//          revision: bump-if-changed.
//@param self FloatRowRing receiver.
//@returns Self for chaining.
export method clear(FloatRowRing self) =>
    _opEnsureFloatRowRing(self)
    bool hadContent = self.cursor.size > 0
    self.cursor.clear()
    if not self.preallocated
        self.data.clear()
    if hadContent
        _opBumpFloatRowRing(self)
    self

//@function Current content revision. Tier 1.
//          Complexity: O(1).
//@param self FloatRowRing receiver.
//@returns The current revision. Always >= 0.
export method revision(FloatRowRing self) =>
    self.contentRevision

//@type Fixed-capacity ring of equal-width int rows in one flat array.
//      Tier: 1 scalar and row access; Tier 3 physical and unchecked access.
//      Stability: Stable
//      Ownership: `rawView()` and `rowView()` are borrowed read-only views.
//      `rawUnsafe()` is a borrowed mutable view and requires an open edit
//      scope. Copy methods fill a caller-owned array or allocate one.
//      Complexity: `push()` is O(width); `pushValue()` and every scalar
//      accessor are O(1); `revision()` is O(1).
//      Allocation: none at steady state when preallocated.
//      Limits: capacity * width may not exceed 100,000.
//@field cursor Owned ring layout.
//@field width Values per row. Always >= 1.
//@field data Row-major backing storage.
//@field preallocated Whether the backing array was sized at construction.
//@field contentRevision Advances when logical content or membership changes.
//@field editOpen Whether an `editBegin()` scope is open.
export type IntRowRing
    RingCursor cursor = na
    int width = 1
    array<int> data = na
    bool preallocated = true
    int contentRevision = 0
    bool editOpen = false

_opBumpIntRowRing(IntRowRing self) =>
    self.contentRevision := self.contentRevision >= _OP_MAX_GENERATION ?
      0 : self.contentRevision + 1
    self

//@function Creates a flat int row ring.
//@param capacity Number of rows. Values below 1 become 1.
//@param width Values per row. Values below 1 become 1.
//@param preallocate Allocate `capacity * width` elements up front.
//@param fillValue Initial value for preallocated storage.
//@returns A new IntRowRing.
export intRowRing(int capacity, int width, bool preallocate = true, int fillValue = 0) =>
    int safeCapacity = math.max(nz(capacity, 1), 1)
    int safeWidth = math.max(nz(width, 1), 1)
    if safeCapacity * safeWidth > _OP_MAX_ARRAY
        runtime.error("OptiPine.IntRowRing: capacity * width exceeds the 100,000-element array limit.")
    IntRowRing result = IntRowRing.new()
    result.cursor := ringCursor(safeCapacity)
    result.width := safeWidth
    result.preallocated := preallocate
    if preallocate
        result.data := array.new<int>(safeCapacity * safeWidth, fillValue)
    else
        result.data := array.new<int>()
    result

//@function Creates a flat int row ring from a configuration object. Tier 2.
//@param settings Ring configuration.
//@param fillValue Initial value for preallocated storage.
//@returns A new IntRowRing.
export intRowRingFrom(RingConfig settings, int fillValue = 0) =>
    RingConfig safeSettings = na(settings) ? ringConfig() : settings
    intRowRing(safeSettings.capacity, safeSettings.width, safeSettings.preallocate, fillValue)

_opEnsureIntRowRing(IntRowRing self) =>
    if na(self.cursor)
        self.cursor := ringCursor(1)
    if na(self.data)
        self.data := array.new<int>()
    if self.width < 1
        self.width := 1
    self

//@function Appends one complete row as the newest row.
//          revision: bump.
//@param self IntRowRing receiver.
//@param row Exactly `width` values.
//@returns The physical slot written.
export method push(IntRowRing self, array<int> row) =>
    _opEnsureIntRowRing(self)
    if na(row) or row.size() != self.width
        runtime.error("OptiPine.IntRowRing: push expects a row of exactly " +
          str.tostring(self.width) + " values.")
    int width = self.width
    int slot = self.cursor.reserve()
    int base = slot * width
    array<int> data = self.data
    if data.size() < base + width
        _opGrowInt(data, base + width)
    for column = 0 to width - 1
        data.set(base + column, row.get(column))
    _opBumpIntRowRing(self)
    slot

//@function Appends one scalar as the newest row of a width-1 ring without
//          allocating a row array. Tier 1.
//          revision: bump.
//@param self IntRowRing receiver. Its width must be 1.
//@param value The value to append.
//@returns The physical slot written.
export method pushValue(IntRowRing self, int value) =>
    _opEnsureIntRowRing(self)
    if self.width != 1
        runtime.error("OptiPine.IntRowRing: pushValue requires width 1; this ring has width " +
          str.tostring(self.width) + ". Use push() with a full row.")
    int slot = self.cursor.reserve()
    array<int> data = self.data
    if data.size() < slot + 1
        _opGrowInt(data, slot + 1)
    data.set(slot, value)
    _opBumpIntRowRing(self)
    slot

//@function Advances the ring and returns the physical slot for the new newest
//          row without writing anything. Tier 3.
//          Precondition: write every column with `writeUnchecked()` before the
//          reserved row is observed.
//          revision: bump.
//@param self IntRowRing receiver.
//@returns The physical slot to write.
export method reserveRowUnchecked(IntRowRing self) =>
    _opEnsureIntRowRing(self)
    int slot = self.cursor.reserve()
    int required = slot * self.width + self.width
    if self.data.size() < required
        _opGrowInt(self.data, required)
    _opBumpIntRowRing(self)
    slot

//@function Writes a complete row into an existing physical slot without
//          advancing the ring. Tier 3.
//          revision: bump on a valid write.
//@param self IntRowRing receiver.
//@param slot Physical slot index.
//@param row Exactly `width` values.
//@returns true when the slot and row width were valid.
export method writePhysical(IntRowRing self, int slot, array<int> row) =>
    _opEnsureIntRowRing(self)
    bool ok = slot >= 0 and slot < self.cursor.capacity and not na(row) and row.size() == self.width
    if ok
        int width = self.width
        int base = slot * width
        array<int> data = self.data
        if data.size() < base + width
            _opGrowInt(data, base + width)
        for column = 0 to width - 1
            data.set(base + column, row.get(column))
        _opBumpIntRowRing(self)
    ok

//@function Writes one value by physical address with no validation. Tier 3.
//          revision: bump.
//@param self IntRowRing receiver.
//@param slot Physical slot index. The caller guarantees it is in range and
//       that the backing storage already covers it.
//@param column Column index. The caller guarantees 0 <= column < width.
//@param value Value to write.
//@returns Self for chaining.
export method writeUnchecked(IntRowRing self, int slot, int column, int value) =>
    self.data.set(slot * self.width + column, value)
    _opBumpIntRowRing(self)
    self

//@function Reads one value by chronological row and column.
//@param self IntRowRing receiver.
//@param logicalRow 0 is the oldest occupied row.
//@param column Column index.
//@returns The value, or na when the address is not occupied.
export method at(IntRowRing self, int logicalRow, int column) =>
    int value = na
    if column >= 0 and column < self.width
        int physical = self.cursor.physical(logicalRow)
        if physical >= 0
            int index = physical * self.width + column
            if index < self.data.size()
                value := self.data.get(index)
    value

//@function Writes one value by chronological row and column.
//          revision: bump-if-changed.
//@param self IntRowRing receiver.
//@param logicalRow 0 is the oldest occupied row.
//@param column Column index.
//@param value Value to write.
//@returns true when the address was occupied. An identical value leaves the
//         revision unchanged.
export method setAt(IntRowRing self, int logicalRow, int column, int value) =>
    bool ok = false
    if column >= 0 and column < self.width
        int physical = self.cursor.physical(logicalRow)
        if physical >= 0
            int index = physical * self.width + column
            if index < self.data.size()
                if not _opSameInt(self.data.get(index), value)
                    self.data.set(index, value)
                    _opBumpIntRowRing(self)
                ok := true
    ok

//@function Reads one value at an offset back from the newest row.
//@param self IntRowRing receiver.
//@param offset 0 is the newest row.
//@param column Column index.
//@returns The value, or na when the address is not occupied.
export method newestAt(IntRowRing self, int offset, int column) =>
    int value = na
    if column >= 0 and column < self.width
        int physical = self.cursor.newest(offset)
        if physical >= 0
            int index = physical * self.width + column
            if index < self.data.size()
                value := self.data.get(index)
    value

//@function Gathers selected chronological rows into one flat array.
//@param self IntRowRing receiver.
//@param logicalRows Chronological row indices to gather. Read only, and it
//       must not be the same array object as `output`.
//@param output Optional caller-owned array. It is cleared and refilled. When
//       na, a newly allocated array is returned.
//@returns The gathered rows concatenated in request order. Rows that are not
//         occupied contribute `width` na values.
export method gather(IntRowRing self, array<int> logicalRows, array<int> output = na) =>
    _opEnsureIntRowRing(self)
    int rowCount = na(logicalRows) ? 0 : logicalRows.size()
    array<int> result = output
    if na(result)
        result := array.new<int>()
    else
        if _opAliasInt(self.data, result)
            runtime.error("OptiPine.IntRowRing: gather output must not be the backing array.")
        result.clear()
        if rowCount > 0 and logicalRows.size() != rowCount
            runtime.error("OptiPine.IntRowRing: gather output must not be the request array.")
    if rowCount > 0
        int width = self.width
        array<int> data = self.data
        int dataSize = data.size()
        for logicalRow in logicalRows
            int physical = self.cursor.physical(logicalRow)
            int sourceBase = physical * width
            if physical >= 0 and sourceBase + width <= dataSize
                result.concat(data.slice(sourceBase, sourceBase + width))
            else
                for column = 0 to width - 1
                    result.push(na)
    result

//@function Copies every occupied row in chronological order.
//@param self IntRowRing receiver.
//@param output Optional caller-owned array. It is cleared and refilled. When
//       na, a newly allocated array is returned.
//@returns All occupied rows concatenated oldest to newest.
export method chronological(IntRowRing self, array<int> output = na) =>
    _opEnsureIntRowRing(self)
    _opCopyCircularIntRows(self.data, self.width, self.cursor, 0, self.cursor.count(), output,
      "OptiPine.IntRowRing.chronological")

//@function Copies a contiguous run of chronological rows.
//@param self IntRowRing receiver.
//@param startLogicalRow First logical row. 0 is the oldest occupied row.
//@param rowCount Number of consecutive logical rows. 0 returns an empty array.
//@param output Optional caller-owned array. It is cleared and refilled. When
//       na, a newly allocated array is returned.
//@returns The requested rows concatenated oldest to newest, `rowCount * width`
//         elements long. Raises when the window is outside the retained range.
export method window(
  IntRowRing self,
  int startLogicalRow,
  int rowCount,
  array<int> output = na) =>
    _opEnsureIntRowRing(self)
    _opCopyCircularIntRows(self.data, self.width, self.cursor, startLogicalRow, rowCount,
      output, "OptiPine.IntRowRing.window")

//@function One chronological row, without copying it. Tier 2.
//          Ownership: borrowed read-only slice of the backing array.
//          Mutation: read-only by contract. Use `setAt()` or an edit scope.
//          Lifetime: valid until the backing array is resized.
//          Persistence: reacquire after that boundary.
//@param self IntRowRing receiver.
//@param logicalRow 0 is the oldest occupied row.
//@returns The row's `width` values, or na when the row is not occupied.
export method rowView(IntRowRing self, int logicalRow) =>
    _opEnsureIntRowRing(self)
    array<int> view = na
    int physical = self.cursor.physical(logicalRow)
    if physical >= 0
        int base = physical * self.width
        if base + self.width <= self.data.size()
            view := self.data.slice(base, base + self.width)
    view

//@function The flat backing array, in row-major physical order. Tier 2.
//          Ownership: borrowed structure-owned view.
//          Mutation: read-only by contract. Use an edit scope for writes.
//          Lifetime: valid until the backing array is resized.
//          Persistence: reacquire after that boundary.
//@param self IntRowRing receiver.
//@returns The backing storage.
export method rawView(IntRowRing self) =>
    _opEnsureIntRowRing(self)
    self.data

//@function Opens a scope in which `rawUnsafe()` may be called. Tier 3.
//          revision: caller-repairs. `editFinish()` performs the bump.
//@param self IntRowRing receiver.
//@returns Self for chaining.
export method editBegin(IntRowRing self) =>
    _opEnsureIntRowRing(self)
    if self.editOpen
        runtime.error("OptiPine.IntRowRing: editBegin called while an edit scope was already open.")
    self.editOpen := true
    self

//@function The flat backing array, for direct mutation. Tier 3.
//          Ownership: borrowed structure-owned mutable view.
//          Mutation: overwrite elements only inside an open edit scope. Do not
//          resize the array.
//          Lifetime: do not retain it past `editFinish()`.
//          Repair: `editFinish()` advances the content revision.
//          revision: caller-repairs.
//@param self IntRowRing receiver.
//@returns The backing storage, in row-major physical order.
export method rawUnsafe(IntRowRing self) =>
    if not self.editOpen
        runtime.error("OptiPine.IntRowRing: rawUnsafe requires an open editBegin() scope. " +
          "Use rawView() to read.")
    self.data

//@function Closes the edit scope and performs the invalidation the raw writes
//          could not. Tier 3.
//          revision: bump.
//@param self IntRowRing receiver.
//@returns Self for chaining.
export method editFinish(IntRowRing self) =>
    if not self.editOpen
        runtime.error("OptiPine.IntRowRing: editFinish called without editBegin.")
    self.editOpen := false
    _opBumpIntRowRing(self)

//@function Physical slot for a chronological row. Tier 3.
//@param self IntRowRing receiver.
//@param logicalRow 0 is the oldest occupied row.
//@returns The physical slot, or -1 when the row is not occupied.
export method physicalRow(IntRowRing self, int logicalRow) =>
    _opEnsureIntRowRing(self)
    self.cursor.physical(logicalRow)

//@function Number of occupied rows.
//@param self IntRowRing receiver.
//@returns The row count.
export method rowCount(IntRowRing self) =>
    na(self.cursor) ? 0 : self.cursor.size

//@function Values per row.
//@param self IntRowRing receiver.
//@returns The row width.
export method rowWidth(IntRowRing self) =>
    self.width

//@function Maximum number of rows.
//@param self IntRowRing receiver.
//@returns The ring capacity.
export method rowCapacity(IntRowRing self) =>
    na(self.cursor) ? 0 : self.cursor.capacity

//@function Empties the ring. Preallocated storage keeps its values until they
//          are overwritten; on-demand storage is released.
//          revision: bump-if-changed.
//@param self IntRowRing receiver.
//@returns Self for chaining.
export method clear(IntRowRing self) =>
    _opEnsureIntRowRing(self)
    bool hadContent = self.cursor.size > 0
    self.cursor.clear()
    if not self.preallocated
        self.data.clear()
    if hadContent
        _opBumpIntRowRing(self)
    self

//@function Current content revision. Tier 1.
//          Complexity: O(1).
//@param self IntRowRing receiver.
//@returns The current revision. Always >= 0.
export method revision(IntRowRing self) =>
    self.contentRevision

//@function Reports whether the ring's contents changed since last observed,
//          and adopts the current state as the new baseline. Tier 1.
//          Complexity: O(1), whatever the ring's capacity and width. The
//          backing array is never compared or copied.
//@param self Watch receiver.
//@param source The ring to observe. na reports no change after the first
//       observation, because a missing ring has no content to differ.
//@returns true on the first observation and whenever the ring's content
//         revision differs from the one last seen.
export method changed(Watch self, FloatRowRing source) =>
    int current = 0
    if not na(source)
        current := source.contentRevision
    bool result = self.quickKind != 11 or self.quickInt != current
    if result
        self.quickKind := 11
        self.quickInt := current
    result

//@function Reports whether the ring's contents changed since last observed,
//          and adopts the current state as the new baseline. Tier 1.
//          Complexity: O(1), whatever the ring's capacity and width. The
//          backing array is never compared or copied.
//@param self Watch receiver.
//@param source The ring to observe. na reports no change after the first
//       observation, because a missing ring has no content to differ.
//@returns true on the first observation and whenever the ring's content
//         revision differs from the one last seen.
export method changed(Watch self, IntRowRing source) =>
    int current = 0
    if not na(source)
        current := source.contentRevision
    bool result = self.quickKind != 12 or self.quickInt != current
    if result
        self.quickKind := 12
        self.quickInt := current
    result

//@function Copies one logical row into `output` at row `outputRow`. Tier 2.
//@param store Flat row-major store of at least `cursor.limit() * width`.
//@param width Elements per row. Must be positive.
//@param cursor Ring cursor describing the logical order. Not modified.
//@param logicalRow Logical row index, 0 = oldest.
//@param output Caller-owned destination, large enough to hold row `outputRow`.
//       Never allocated here.
//@param outputRow Destination row index.
//@returns The output array.
export copyLogicalFloatRow(
  array<float> store,
  int width,
  RingCursor cursor,
  int logicalRow,
  array<float> output,
  int outputRow = 0) =>
    if na(store) or na(output)
        runtime.error("OptiPine.copyLogicalFloatRow: store and output cannot be na.")
    if width <= 0
        runtime.error("OptiPine.copyLogicalFloatRow: width must be positive.")
    int count = cursor.count()
    if logicalRow < 0 or logicalRow >= count
        runtime.error("OptiPine.copyLogicalFloatRow: logical row is outside the retained range.")
    int sourceBase = cursor.physical(logicalRow) * width
    int targetBase = outputRow * width
    // range-guard: width > 0 is validated above.
    for column = 0 to width - 1
        output.set(targetBase + column, store.get(sourceBase + column))
    output

//@function Copies the rows named in `logicalRows`, in request order, into one
//          flat row-major array. Tier 2.
//@param store Flat row-major store.
//@param width Elements per row. Must be positive.
//@param cursor Ring cursor describing the logical order. Not modified.
//@param logicalRows Logical rows to collect. Every entry must be retained.
//@param output Optional caller-owned destination, reused when supplied.
//@returns The caller-owned output array, `logicalRows.size() * width` long.
export gatherLogicalFloatRows(
  array<float> store,
  int width,
  RingCursor cursor,
  array<int> logicalRows,
  array<float> output = na) =>
    if na(store)
        runtime.error("OptiPine.gatherLogicalFloatRows: store cannot be na.")
    if width <= 0
        runtime.error("OptiPine.gatherLogicalFloatRows: width must be positive.")
    array<float> destination = output
    if na(destination)
        destination := array.new<float>()
    else if _opAliasFloat(store, destination)
        runtime.error("OptiPine.gatherLogicalFloatRows: store and output must be different arrays.")
    int requested = na(logicalRows) ? 0 : logicalRows.size()
    int count = cursor.count()
    _opResizeFloat(destination, requested * width)
    if requested > 0
        int lastRow = requested - 1
        for row = 0 to lastRow
            int logicalRow = logicalRows.get(row)
            if logicalRow < 0 or logicalRow >= count
                runtime.error(
                  "OptiPine.gatherLogicalFloatRows: logical row is outside the retained range.")
            int sourceBase = cursor.physical(logicalRow) * width
            int targetBase = row * width
            // range-guard: width > 0 is validated above.
            for column = 0 to width - 1
                destination.set(targetBase + column, store.get(sourceBase + column))
    destination

//@function Copies `rowCount` consecutive logical rows starting at
//          `startLogicalRow` into one flat row-major array. Tier 2.
//@param store Flat row-major store.
//@param width Elements per row. Must be positive.
//@param cursor Ring cursor describing the logical order. Not modified.
//@param startLogicalRow First logical row, 0 = oldest.
//@param rowCount Number of consecutive logical rows.
//@param output Optional caller-owned destination, reused when supplied.
//@returns The caller-owned output array, `rowCount * width` long.
export copyLogicalFloatWindow(
  array<float> store,
  int width,
  RingCursor cursor,
  int startLogicalRow,
  int rowCount,
  array<float> output = na) =>
    _opCopyCircularFloatRows(store, width, cursor, startLogicalRow, rowCount, output,
      "OptiPine.copyLogicalFloatWindow")

//@function Copies every retained row, oldest first, into one flat row-major
//          array. Tier 2.
//@param store Flat row-major store.
//@param width Elements per row. Must be positive.
//@param cursor Ring cursor describing the logical order. Not modified.
//@param output Optional caller-owned destination, reused when supplied.
//@returns The caller-owned output array, `cursor.count() * width` long.
export copyChronologicalFloatRows(
  array<float> store,
  int width,
  RingCursor cursor,
  array<float> output = na) =>
    int rows = 0
    if not na(cursor)
        rows := cursor.count()
    _opCopyCircularFloatRows(store, width, cursor, 0, rows, output,
      "OptiPine.copyChronologicalFloatRows")

//@function Transposes a flat row-major matrix into a flat column-major one.
//          Tier 2.
//@param source Flat row-major array of at least `rows * columns` elements.
//@param rows Row count of the source.
//@param columns Column count of the source.
//@param output Optional caller-owned destination, reused when supplied. Must
//       not be `source`.
//@returns The caller-owned output array, `rows * columns` long, holding the
//         transposed matrix in row-major order.
export transposeFlatFloat(
  array<float> source,
  int rows,
  int columns,
  array<float> output = na) =>
    if na(source)
        runtime.error("OptiPine.transposeFlatFloat: source cannot be na.")
    if rows < 0 or columns < 0
        runtime.error("OptiPine.transposeFlatFloat: rows and columns cannot be negative.")
    int cells = rows * columns
    if source.size() < cells
        runtime.error("OptiPine.transposeFlatFloat: source is smaller than rows * columns.")
    array<float> destination = output
    if na(destination)
        destination := array.new<float>()
    else if _opAliasFloat(source, destination)
        runtime.error("OptiPine.transposeFlatFloat: source and output must be different arrays.")
    _opResizeFloat(destination, cells)
    if rows > 0
        if columns > 0
            int lastRow = rows - 1
            for row = 0 to lastRow
                int sourceBase = row * columns
                for column = 0 to columns - 1
                    destination.set(column * rows + row, source.get(sourceBase + column))
    destination

//@function Copies one logical row into `output` at row `outputRow`. Tier 2.
//@param store Flat row-major store of at least `cursor.limit() * width`.
//@param width Elements per row. Must be positive.
//@param cursor Ring cursor describing the logical order. Not modified.
//@param logicalRow Logical row index, 0 = oldest.
//@param output Caller-owned destination, large enough to hold row `outputRow`.
//       Never allocated here.
//@param outputRow Destination row index.
//@returns The output array.
export copyLogicalIntRow(
  array<int> store,
  int width,
  RingCursor cursor,
  int logicalRow,
  array<int> output,
  int outputRow = 0) =>
    if na(store) or na(output)
        runtime.error("OptiPine.copyLogicalIntRow: store and output cannot be na.")
    if width <= 0
        runtime.error("OptiPine.copyLogicalIntRow: width must be positive.")
    int count = cursor.count()
    if logicalRow < 0 or logicalRow >= count
        runtime.error("OptiPine.copyLogicalIntRow: logical row is outside the retained range.")
    int sourceBase = cursor.physical(logicalRow) * width
    int targetBase = outputRow * width
    // range-guard: width > 0 is validated above.
    for column = 0 to width - 1
        output.set(targetBase + column, store.get(sourceBase + column))
    output

//@function Copies the rows named in `logicalRows`, in request order, into one
//          flat row-major array. Tier 2.
//@param store Flat row-major store.
//@param width Elements per row. Must be positive.
//@param cursor Ring cursor describing the logical order. Not modified.
//@param logicalRows Logical rows to collect. Every entry must be retained.
//@param output Optional caller-owned destination, reused when supplied.
//@returns The caller-owned output array, `logicalRows.size() * width` long.
export gatherLogicalIntRows(
  array<int> store,
  int width,
  RingCursor cursor,
  array<int> logicalRows,
  array<int> output = na) =>
    if na(store)
        runtime.error("OptiPine.gatherLogicalIntRows: store cannot be na.")
    if width <= 0
        runtime.error("OptiPine.gatherLogicalIntRows: width must be positive.")
    array<int> destination = output
    if na(destination)
        destination := array.new<int>()
    else if _opAliasInt(store, destination)
        runtime.error("OptiPine.gatherLogicalIntRows: store and output must be different arrays.")
    int requested = na(logicalRows) ? 0 : logicalRows.size()
    int count = cursor.count()
    _opResizeInt(destination, requested * width)
    if requested > 0
        int lastRow = requested - 1
        for row = 0 to lastRow
            int logicalRow = logicalRows.get(row)
            if logicalRow < 0 or logicalRow >= count
                runtime.error(
                  "OptiPine.gatherLogicalIntRows: logical row is outside the retained range.")
            int sourceBase = cursor.physical(logicalRow) * width
            int targetBase = row * width
            // range-guard: width > 0 is validated above.
            for column = 0 to width - 1
                destination.set(targetBase + column, store.get(sourceBase + column))
    destination

//@function Copies `rowCount` consecutive logical rows starting at
//          `startLogicalRow` into one flat row-major array. Tier 2.
//@param store Flat row-major store.
//@param width Elements per row. Must be positive.
//@param cursor Ring cursor describing the logical order. Not modified.
//@param startLogicalRow First logical row, 0 = oldest.
//@param rowCount Number of consecutive logical rows.
//@param output Optional caller-owned destination, reused when supplied.
//@returns The caller-owned output array, `rowCount * width` long.
export copyLogicalIntWindow(
  array<int> store,
  int width,
  RingCursor cursor,
  int startLogicalRow,
  int rowCount,
  array<int> output = na) =>
    _opCopyCircularIntRows(store, width, cursor, startLogicalRow, rowCount, output,
      "OptiPine.copyLogicalIntWindow")

//@function Copies every retained row, oldest first, into one flat row-major
//          array. Tier 2.
//@param store Flat row-major store.
//@param width Elements per row. Must be positive.
//@param cursor Ring cursor describing the logical order. Not modified.
//@param output Optional caller-owned destination, reused when supplied.
//@returns The caller-owned output array, `cursor.count() * width` long.
export copyChronologicalIntRows(
  array<int> store,
  int width,
  RingCursor cursor,
  array<int> output = na) =>
    int rows = 0
    if not na(cursor)
        rows := cursor.count()
    _opCopyCircularIntRows(store, width, cursor, 0, rows, output,
      "OptiPine.copyChronologicalIntRows")

//@function Transposes a flat row-major matrix into a flat column-major one.
//          Tier 2.
//@param source Flat row-major array of at least `rows * columns` elements.
//@param rows Row count of the source.
//@param columns Column count of the source.
//@param output Optional caller-owned destination, reused when supplied. Must
//       not be `source`.
//@returns The caller-owned output array, `rows * columns` long, holding the
//         transposed matrix in row-major order.
export transposeFlatInt(
  array<int> source,
  int rows,
  int columns,
  array<int> output = na) =>
    if na(source)
        runtime.error("OptiPine.transposeFlatInt: source cannot be na.")
    if rows < 0 or columns < 0
        runtime.error("OptiPine.transposeFlatInt: rows and columns cannot be negative.")
    int cells = rows * columns
    if source.size() < cells
        runtime.error("OptiPine.transposeFlatInt: source is smaller than rows * columns.")
    array<int> destination = output
    if na(destination)
        destination := array.new<int>()
    else if _opAliasInt(source, destination)
        runtime.error("OptiPine.transposeFlatInt: source and output must be different arrays.")
    _opResizeInt(destination, cells)
    if rows > 0
        if columns > 0
            int lastRow = rows - 1
            for row = 0 to lastRow
                int sourceBase = row * columns
                for column = 0 to columns - 1
                    destination.set(column * rows + row, source.get(sourceBase + column))
    destination

//@function Converts a contiguous flat float range into a matrix by adding one
//          native row and reshaping.
//@param source Flat row-major source. Read only.
//@param rows Matrix row count. Negative values become 0.
//@param columns Matrix column count. Negative values become 0.
//@param startIndex First source index of the range.
//@returns A newly allocated caller-owned matrix. When the requested range is
//         not fully present in `source`, a zero-filled matrix of the requested
//         shape is returned instead.
export matrixFromFlat(array<float> source, int rows, int columns, int startIndex = 0) =>
    int safeRows = math.max(nz(rows, 0), 0)
    int safeColumns = math.max(nz(columns, 0), 0)
    int count = safeRows * safeColumns
    int safeStart = math.max(nz(startIndex, 0), 0)
    if count > _OP_MAX_ARRAY
        runtime.error("OptiPine.matrixFromFlat: rows * columns exceeds the 100,000-element limit.")
    matrix<float> result = matrix.new<float>()
    bool complete = count > 0 and not na(source) and source.size() >= safeStart + count
    if complete
        result.add_row(0, source.slice(safeStart, safeStart + count))
        result.reshape(safeRows, safeColumns)
    else
        result := matrix.new<float>(safeRows, safeColumns, 0.0)
    result

//@function Copies a matrix into caller-owned flat row-major storage.
//@param source Matrix to read.
//@param output Optional caller-owned array. It is cleared and refilled. When
//       na, a newly allocated array is returned.
//@returns The matrix contents in row-major order.
export flatFromFloatMatrix(matrix<float> source, array<float> output = na) =>
    array<float> result = output
    if na(result)
        result := array.new<float>()
    else
        result.clear()
    if not na(source)
        int rows = source.rows()
        int columns = source.columns()
        if rows > 0 and columns > 0
            for row = 0 to rows - 1
                for column = 0 to columns - 1
                    result.push(source.get(row, column))
    result

//@function Converts a contiguous flat int range into a matrix by adding one
//          native row and reshaping.
//@param source Flat row-major source. Read only.
//@param rows Matrix row count. Negative values become 0.
//@param columns Matrix column count. Negative values become 0.
//@param startIndex First source index of the range.
//@returns A newly allocated caller-owned matrix. When the requested range is
//         not fully present in `source`, a zero-filled matrix of the requested
//         shape is returned instead.
export intMatrixFromFlat(array<int> source, int rows, int columns, int startIndex = 0) =>
    int safeRows = math.max(nz(rows, 0), 0)
    int safeColumns = math.max(nz(columns, 0), 0)
    int count = safeRows * safeColumns
    int safeStart = math.max(nz(startIndex, 0), 0)
    if count > _OP_MAX_ARRAY
        runtime.error("OptiPine.intMatrixFromFlat: rows * columns exceeds the 100,000-element limit.")
    matrix<int> result = matrix.new<int>()
    bool complete = count > 0 and not na(source) and source.size() >= safeStart + count
    if complete
        result.add_row(0, source.slice(safeStart, safeStart + count))
        result.reshape(safeRows, safeColumns)
    else
        result := matrix.new<int>(safeRows, safeColumns, 0)
    result

//@function Copies a matrix into caller-owned flat row-major storage.
//@param source Matrix to read.
//@param output Optional caller-owned array. It is cleared and refilled. When
//       na, a newly allocated array is returned.
//@returns The matrix contents in row-major order.
export flatFromIntMatrix(matrix<int> source, array<int> output = na) =>
    array<int> result = output
    if na(result)
        result := array.new<int>()
    else
        result.clear()
    if not na(source)
        int rows = source.rows()
        int columns = source.columns()
        if rows > 0 and columns > 0
            for row = 0 to rows - 1
                for column = 0 to columns - 1
                    result.push(source.get(row, column))
    result

//@enum Cumulative-weight representation.
//@field automatic Start with the linear prefix and promote to a Fenwick tree
//       once the exponent has been stable and updates have stayed sparse.
//@field prefix Rebuilt left-to-right cumulative sums. This is the
//       deterministic baseline: it preserves the exact addition order a hand
//       written prefix implementation would use.
//@field fenwick Binary indexed tree. Point updates and selection are
//       O(log N), but its summation order differs from a linear prefix and can
//       therefore change bit-exact selections at tie boundaries.
export enum WeightPolicy
    automatic = "Automatic"
    prefix = "Linear prefix"
    fenwick = "Fenwick tree"

//@enum Behavior for an na weight.
//@field treatAsZero Store 0.0, making the entry unselectable.
//@field raiseError Stop with a descriptive error.
export enum NaWeightPolicy
    treatAsZero = "Treat as zero"
    raiseError = "Raise error"

//@enum Behavior for a negative weight.
//@field clampToZero Store 0.0, making the entry unselectable.
//@field raiseError Stop with a descriptive error.
export enum NegativeWeightPolicy
    clampToZero = "Clamp to zero"
    raiseError = "Raise error"

//@enum Meaning of a zero selection exponent.
//@field uniform Every entry gets weight 1.0, including zero-weight entries.
//       This is the mathematical result of `pow(w, 0)` and gives uniform
//       sampling across the whole prepared range.
//@field preserveZeros Strictly positive weights get 1.0 and zero weights stay
//       0.0, so a zero-weight entry remains unselectable at every exponent.
export enum ExponentZeroPolicy
    uniform = "Uniform"
    preserveZeros = "Preserve zeros"

//@type Configuration for weighted selection.
//      Tier: 2 (Composable) | Stability: Stable
//      Ownership: caller-owned; one config may be shared.
//@field policy Requested cumulative representation.
//@field naWeights Behavior for an na weight.
//@field negativeWeights Behavior for a negative weight.
//@field exponentZero Meaning of a zero selection exponent.
//@field promoteAfterCycles Consecutive prepares with an unchanged exponent
//       before automatic mode promotes to a Fenwick tree.
//@field sparseUpdateRatio Fraction of the prepared range that may change
//       between prepares while still counting as sparse. Automatic mode falls
//       back to the linear prefix above this density.
export type WeightConfig
    WeightPolicy policy = WeightPolicy.prefix
    NaWeightPolicy naWeights = NaWeightPolicy.treatAsZero
    NegativeWeightPolicy negativeWeights = NegativeWeightPolicy.clampToZero
    ExponentZeroPolicy exponentZero = ExponentZeroPolicy.uniform
    int promoteAfterCycles = 2
    float sparseUpdateRatio = 0.05

//@function Creates a weighted-selection configuration. Tier 2.
//@param policy Requested cumulative representation.
//@param naWeights Behavior for an na weight.
//@param negativeWeights Behavior for a negative weight.
//@param exponentZero Meaning of a zero selection exponent.
//@param promoteAfterCycles Stable prepares before automatic promotion.
//@param sparseUpdateRatio Sparse-update density ceiling.
//@returns A new WeightConfig with every argument clamped to a valid range.
export weightConfig(
  WeightPolicy policy = WeightPolicy.prefix,
  NaWeightPolicy naWeights = NaWeightPolicy.treatAsZero,
  NegativeWeightPolicy negativeWeights = NegativeWeightPolicy.clampToZero,
  ExponentZeroPolicy exponentZero = ExponentZeroPolicy.uniform,
  int promoteAfterCycles = 2,
  float sparseUpdateRatio = 0.05) =>
    WeightConfig.new(
      policy,
      naWeights,
      negativeWeights,
      exponentZero,
      math.max(nz(promoteAfterCycles, 1), 1),
      math.max(nz(sparseUpdateRatio, 0.0), 0.0))

//@function Preset: bit-reproducible selection. Forces the linear prefix, whose
//          left-to-right addition order never changes.
//@returns A WeightConfig.
export weightConfigDeterministic() =>
    weightConfig(policy = WeightPolicy.prefix)

//@function Preset: weights that rarely change under a stable exponent, where
//          an O(log N) tree pays for itself across many draws.
//@returns A WeightConfig.
export weightConfigStatic() =>
    weightConfig(policy = WeightPolicy.fenwick)

//@function Preset: automatic promotion for sparse point updates, such as a
//          prioritized replay buffer whose priorities change a few at a time.
//@returns A WeightConfig.
export weightConfigSparseUpdates() =>
    weightConfig(policy = WeightPolicy.automatic)

//@function Preset: reject na and negative weights instead of clamping them,
//          for callers that want a bad weight to surface immediately.
//@returns A WeightConfig.
export weightConfigStrict() =>
    weightConfig(
      naWeights = NaWeightPolicy.raiseError,
      negativeWeights = NegativeWeightPolicy.raiseError)

//@type Reusable left-to-right cumulative weights over a circular range.
//      Tier: 2 (Composable) | Stability: Stable
//      Ownership: `cumulativeView()` returns a borrowed read-only view valid
//      until the next build; see the method for the full contract. Mutation is
//      unsupported, so it is not named as an unsafe path.
//      Complexity: build O(count); `lowerBound()` O(log count).
//@field cumulative Running totals in logical order.
//@field totalWeight Sum of every transformed weight in the built range.
//@field entryCount Number of logical entries in the built range.
export type WeightedPrefix
    array<float> cumulative = na
    float totalWeight = 0.0
    int entryCount = 0

//@function Creates an empty prefix index.
//@returns A new WeightedPrefix.
export weightedPrefix() =>
    WeightedPrefix.new(array.new<float>(), 0.0, 0)

_opEnsureWeightedPrefix(WeightedPrefix self) =>
    if na(self.cumulative)
        self.cumulative := array.new<float>()
    self

//@function Rebuilds cumulative weights over a circular logical range.
//@param self WeightedPrefix receiver.
//@param weights Physical weights. Read only.
//@param startPhysical Physical slot holding logical index 0.
//@param count Number of logical entries. Clipped to the weight array size.
//@param exponent Power transform applied before accumulation. Values below 0
//       become 0.
//@param preserveZeroExponent At exponent 0, keep zero weights unselectable
//       instead of making every entry uniform.
//@returns Self for chaining.
export method buildCircular(
  WeightedPrefix self,
  array<float> weights,
  int startPhysical,
  int count,
  float exponent = 1.0,
  bool preserveZeroExponent = false) =>
    _opEnsureWeightedPrefix(self)
    array<float> cumulative = self.cumulative
    cumulative.clear()
    float running = 0.0
    int available = na(weights) ? 0 : weights.size()
    int safeCount = math.min(math.max(nz(count, 0), 0), available)
    int safeStart = _opWrapStart(nz(startPhysical, 0), available)
    float safeExponent = math.max(nz(exponent, 1.0), 0.0)
    if safeCount > 0
        bool unitExponent = safeExponent == 1.0
        bool zeroExponent = safeExponent == 0.0
        int leading = math.min(safeCount, available - safeStart)
        int trailing = safeCount - leading
        for segment = 0 to 1
            int segmentStart = segment == 0 ? safeStart : 0
            int segmentCount = segment == 0 ? leading : trailing
            if segmentCount > 0
                for physical = segmentStart to segmentStart + segmentCount - 1
                    float raw = weights.get(physical)
                    float base = 0.0
                    if not na(raw) and math.sign(raw) >= 0
                        base := raw
                    float transformed = base
                    if not unitExponent
                        if zeroExponent
                            transformed := 1.0
                            if preserveZeroExponent and math.sign(base) <= 0
                                transformed := 0.0
                        else
                            transformed := math.pow(base, safeExponent)
                    running += transformed
                    cumulative.push(running)
    self.totalWeight := running
    self.entryCount := safeCount
    self

//@function Rebuilds cumulative weights over a non-circular range starting at
//          physical slot 0.
//@param self WeightedPrefix receiver.
//@param weights Physical weights. Read only.
//@param count Number of entries, or na for every weight.
//@param exponent Power transform applied before accumulation.
//@param preserveZeroExponent At exponent 0, keep zero weights unselectable.
//@returns Self for chaining.
export method build(
  WeightedPrefix self,
  array<float> weights,
  int count = na,
  float exponent = 1.0,
  bool preserveZeroExponent = false) =>
    int available = na(weights) ? 0 : weights.size()
    int requested = na(count) ? available : count
    self.buildCircular(weights, 0, requested, exponent, preserveZeroExponent)

//@function Selects the smallest logical index whose cumulative sum reaches a
//          threshold.
//@param self WeightedPrefix receiver.
//@param threshold Target sum.
//@returns The logical index, or -1 when the range is empty or its total is 0.
export method lowerBound(WeightedPrefix self, float threshold) =>
    int result = -1
    if self.entryCount > 0 and math.sign(self.totalWeight) > 0
        array<float> cumulative = self.cumulative
        float requested = nz(threshold, 0.0)
        bool selectFirstPositive = math.sign(requested) <= 0
        float target = requested
        if math.sign(requested - self.totalWeight) > 0
            target := self.totalWeight
        int lowIndex = 0
        int highIndex = self.entryCount - 1
        while lowIndex < highIndex
            int middle = int((lowIndex + highIndex) / 2)
            float value = cumulative.get(middle)
            bool reached = selectFirstPositive ? math.sign(value) > 0 :
              math.sign(value - target) >= 0
            if reached
                highIndex := middle
            else
                lowIndex := middle + 1
        result := lowIndex
    result

//@function Transformed probability of one logical index in the built range.
//@param self WeightedPrefix receiver.
//@param logicalIndex Logical index inside the built range.
//@returns The probability, or 0.0 when the index is outside the range or the
//         total is 0.
export method probability(WeightedPrefix self, int logicalIndex) =>
    float result = 0.0
    if logicalIndex >= 0 and logicalIndex < self.entryCount and math.sign(self.totalWeight) > 0
        float upper = self.cumulative.get(logicalIndex)
        float lower = 0.0
        if logicalIndex > 0
            lower := self.cumulative.get(logicalIndex - 1)
        result := (upper - lower) / self.totalWeight
    result

//@function Sum of every transformed weight in the built range.
//@param self WeightedPrefix receiver.
//@returns The total.
export method total(WeightedPrefix self) =>
    self.totalWeight

//@function Number of logical entries in the built range.
//@param self WeightedPrefix receiver.
//@returns The entry count.
export method count(WeightedPrefix self) =>
    self.entryCount

//@function The running cumulative totals, in logical order. Tier 2.
//          Ownership: borrowed structure-owned view.
//          Mutation: read-only by contract. Rebuild to change the weights.
//          Lifetime: valid until the next `build()`, `buildCircular()` or
//          `clear()`.
//          Persistence: reacquire after that boundary.
//@param self WeightedPrefix receiver.
//@returns The cumulative totals, `count()` elements long.
export method cumulativeView(WeightedPrefix self) =>
    _opEnsureWeightedPrefix(self)
    self.cumulative

//@function Empties the index, retaining the allocation.
//@param self WeightedPrefix receiver.
//@returns Self for chaining.
export method clear(WeightedPrefix self) =>
    _opEnsureWeightedPrefix(self)
    self.cumulative.clear()
    self.totalWeight := 0.0
    self.entryCount := 0
    self

//@type Dynamic prefix-sum index over non-negative float weights.
//      Tier: 2 (Composable) | Stability: Stable
//      Ownership: no accessor returns a reference to internal storage.
//      Complexity: `reset()` and `build()` O(N); `set()`, `add()`, `prefix()`
//      and `lowerBound()` O(log N).
//      Limits: at most 99,999 weights, because the tree uses a sentinel slot.
//@field size Number of weights.
//@field tree Fenwick partial sums, 1-based.
//@field values Current transformed weights, 1-based.
//@field lowBits Precomputed low bit of every 1-based index.
//@field topBit Largest power of two not greater than `size`.
export type FloatFenwick
    int size = 0
    array<float> tree = na
    array<float> values = na
    array<int> lowBits = na
    int topBit = 0

_opEnsureFenwick(FloatFenwick self) =>
    if na(self.tree)
        self.tree := array.new<float>()
    if na(self.values)
        self.values := array.new<float>()
    if na(self.lowBits)
        self.lowBits := array.new<int>()
    self

//@function Resizes the tree and clears every weight to 0.
//@param self FloatFenwick receiver.
//@param size Number of weights. Negative values become 0.
//@returns Self for chaining.
export method reset(FloatFenwick self, int size) =>
    _opEnsureFenwick(self)
    int count = math.max(nz(size, 0), 0)
    if count > _OP_MAX_ARRAY - 1
        runtime.error("OptiPine.FloatFenwick: supports at most 99,999 weights because the tree uses a sentinel slot.")
    self.size := count
    _opRefillFloat(self.tree, count + 1, 0.0)
    _opRefillFloat(self.values, count + 1, 0.0)
    _opRefillInt(self.lowBits, count + 1, 0)
    int top = 0
    if count > 0
        top := 1
        while top * 2 <= count
            top *= 2
        array<int> lowBits = self.lowBits
        lowBits.set(1, 1)
        if count > 1
            for index = 2 to count
                int bit = 1
                if index % 2 == 0
                    bit := lowBits.get(int(index / 2)) * 2
                lowBits.set(index, bit)
    self.topBit := top
    self

//@function Creates a Fenwick tree.
//@param size Number of weights.
//@returns A new FloatFenwick with every weight at 0.
export floatFenwick(int size = 0) =>
    int slots = math.min(math.max(nz(size, 0), 0), _OP_MAX_ARRAY - 1) + 1
    FloatFenwick result = FloatFenwick.new()
    result.tree := array.new<float>(slots, 0.0)
    result.values := array.new<float>(slots, 0.0)
    result.lowBits := array.new<int>(slots, 0)
    result.reset(size)
    result

_opFenwickBuildTransformedCircular(
  FloatFenwick tree,
  array<float> source,
  int startPhysical,
  int count,
  float exponent,
  bool preserveZeros) =>
    _opEnsureFenwick(tree)
    int available = na(source) ? 0 : source.size()
    int total = math.min(math.max(nz(count, 0), 0), available)
    if tree.size != total
        tree.reset(total)
    else
        if tree.tree.size() > 0
            tree.tree.fill(0.0)
        if tree.values.size() > 0
            tree.values.fill(0.0)
    if total > 0
        int start = _opWrapStart(nz(startPhysical, 0), available)
        array<float> nodes = tree.tree
        array<float> values = tree.values
        array<int> lowBits = tree.lowBits
        bool unitExponent = exponent == 1.0
        bool zeroExponent = exponent == 0.0
        int leading = math.min(total, available - start)
        int trailing = total - leading
        int logicalIndex = 0
        for segment = 0 to 1
            int segmentStart = segment == 0 ? start : 0
            int segmentCount = segment == 0 ? leading : trailing
            if segmentCount > 0
                for physical = segmentStart to segmentStart + segmentCount - 1
                    float raw = source.get(physical)
                    float base = 0.0
                    if not na(raw) and math.sign(raw) >= 0
                        base := raw
                    float transformed = base
                    if not unitExponent
                        if zeroExponent
                            transformed := 1.0
                            if preserveZeros and math.sign(base) <= 0
                                transformed := 0.0
                        else
                            transformed := math.pow(base, exponent)
                    int position = logicalIndex + 1
                    values.set(position, transformed)
                    float node = nodes.get(position) + transformed
                    nodes.set(position, node)
                    int parent = position + lowBits.get(position)
                    if parent <= total
                        nodes.set(parent, nodes.get(parent) + node)
                    logicalIndex += 1
    tree

//@function Rebuilds the whole tree from a weight array in O(N).
//@param self FloatFenwick receiver.
//@param weights Non-negative weights. na and negative values become 0.
//@param count Number of weights to read, or na for the whole array.
//@returns Self for chaining.
export method build(FloatFenwick self, array<float> weights, int count = na) =>
    int requested = count
    if na(requested)
        requested := na(weights) ? 0 : weights.size()
    _opFenwickBuildTransformedCircular(self, weights, 0, requested, 1.0, false)

//@function Sets one zero-based weight.
//@param self FloatFenwick receiver.
//@param index Zero-based weight index.
//@param value New weight. na and negative values become 0.
//@returns true when the index was in range.
export method set(FloatFenwick self, int index, float value) =>
    bool ok = index >= 0 and index < self.size
    if ok
        float safeValue = na(value) or math.sign(value) < 0 ? 0.0 : value
        int position = index + 1
        array<float> tree = self.tree
        array<float> values = self.values
        array<int> lowBits = self.lowBits
        float delta = safeValue - values.get(position)
        values.set(position, safeValue)
        int limit = self.size
        while position <= limit
            tree.set(position, tree.get(position) + delta)
            position += lowBits.get(position)
    ok

//@function Adds a delta to one zero-based weight, clamping the result at 0.
//@param self FloatFenwick receiver.
//@param index Zero-based weight index.
//@param delta Amount to add.
//@returns true when the index was in range.
export method add(FloatFenwick self, int index, float delta) =>
    bool ok = index >= 0 and index < self.size
    if ok
        float current = self.values.get(index + 1)
        float target = current + nz(delta, 0.0)
        self.set(index, math.sign(target) < 0 ? 0.0 : target)
    ok

//@function Reads one zero-based weight.
//@param self FloatFenwick receiver.
//@param index Zero-based weight index.
//@returns The stored weight, or na when the index is out of range.
export method get(FloatFenwick self, int index) =>
    float value = na
    if index >= 0 and index < self.size
        value := self.values.get(index + 1)
    value

//@function Sum of weights in [0, endExclusive).
//@param self FloatFenwick receiver.
//@param endExclusive Exclusive upper bound, clamped to [0, size].
//@returns The prefix sum.
export method prefix(FloatFenwick self, int endExclusive) =>
    int position = math.min(math.max(nz(endExclusive, 0), 0), self.size)
    float result = 0.0
    if position > 0
        array<float> tree = self.tree
        array<int> lowBits = self.lowBits
        while position > 0
            result += tree.get(position)
            position -= lowBits.get(position)
    result

//@function Sum of weights in [startInclusive, endExclusive).
//@param self FloatFenwick receiver.
//@param startInclusive Inclusive lower bound.
//@param endExclusive Exclusive upper bound.
//@returns The range sum.
export method rangeSum(FloatFenwick self, int startInclusive, int endExclusive) =>
    int left = math.min(math.max(nz(startInclusive, 0), 0), self.size)
    int right = math.min(math.max(nz(endExclusive, left), left), self.size)
    self.prefix(right) - self.prefix(left)

//@function Sum of every weight.
//@param self FloatFenwick receiver.
//@returns The total.
export method total(FloatFenwick self) =>
    self.prefix(self.size)

//@function Number of weights.
//@param self FloatFenwick receiver.
//@returns The weight count.
export method count(FloatFenwick self) =>
    self.size

//@function Selects the smallest zero-based index whose prefix sum reaches a
//          threshold, using binary lifting over the tree.
//@param self FloatFenwick receiver.
//@param threshold Target sum.
//@returns The index, or -1 when the tree is empty or its total is 0.
export method lowerBound(FloatFenwick self, float threshold) =>
    int result = -1
    float totalWeight = self.total()
    if self.size > 0 and math.sign(totalWeight) > 0
        float requested = nz(threshold, 0.0)
        bool selectFirstPositive = math.sign(requested) <= 0
        float target = requested
        if math.sign(requested - totalWeight) > 0
            target := totalWeight
        array<float> tree = self.tree
        int index = 0
        float accumulated = 0.0
        int bit = self.topBit
        int limit = self.size
        while bit > 0
            int candidate = index + bit
            if candidate <= limit
                float node = tree.get(candidate)
                float advanced = accumulated + node
                bool step = selectFirstPositive ? math.sign(advanced) <= 0 :
                  math.sign(advanced - target) < 0
                if step
                    accumulated := advanced
                    index := candidate
            bit := int(bit / 2)
        result := math.min(index, limit - 1)
    result

//@function Exact total over a circular physical range.
//@param self FloatFenwick receiver.
//@param startPhysical Physical slot holding logical index 0.
//@param count Number of logical entries. Clipped to `size`.
//@returns The exact total. Complexity O(count).
export method circularTotal(FloatFenwick self, int startPhysical, int count) =>
    int limit = self.size
    int safeCount = math.min(math.max(nz(count, 0), 0), limit)
    float totalWeight = 0.0
    if safeCount > 0
        int start = _opWrapStart(nz(startPhysical, 0), limit)
        array<float> values = self.values
        float correction = 0.0
        int leading = math.min(safeCount, limit - start)
        int trailing = safeCount - leading
        for segment = 0 to 1
            int segmentStart = segment == 0 ? start : 0
            int segmentCount = segment == 0 ? leading : trailing
            if segmentCount > 0
                for physical = segmentStart to segmentStart + segmentCount - 1
                    float weight = values.get(physical + 1)
                    float adjusted = weight - correction
                    float advanced = totalWeight + adjusted
                    correction := (advanced - totalWeight) - adjusted
                    totalWeight := advanced
    totalWeight

//@function Selects over a circular physical range.
//@param self FloatFenwick receiver.
//@param threshold Target sum inside the circular range.
//@param startPhysical Physical slot holding logical index 0.
//@param count Number of logical entries. Clipped to `size`.
//@returns The selected physical slot, or -1 when the range is empty or its
//         total is 0.
export method lowerBoundCircular(
  FloatFenwick self,
  float threshold,
  int startPhysical,
  int count) =>
    int result = -1
    int limit = self.size
    int safeCount = math.min(math.max(nz(count, 0), 0), limit)
    if safeCount > 0
        float totalWeight = self.circularTotal(startPhysical, safeCount)
        if math.sign(totalWeight) > 0
            int start = _opWrapStart(nz(startPhysical, 0), limit)
            array<float> values = self.values
            float requested = nz(threshold, 0.0)
            if math.sign(requested - totalWeight) > 0
                requested := totalWeight
            float running = 0.0
            float correction = 0.0
            int firstPositive = -1
            int leading = math.min(safeCount, limit - start)
            int trailing = safeCount - leading
            for segment = 0 to 1
                int segmentStart = segment == 0 ? start : 0
                int segmentCount = segment == 0 ? leading : trailing
                if result < 0 and segmentCount > 0
                    for physical = segmentStart to segmentStart + segmentCount - 1
                        float weight = values.get(physical + 1)
                        if math.sign(weight) > 0
                            if firstPositive < 0
                                firstPositive := physical
                            float adjusted = weight - correction
                            float advanced = running + adjusted
                            correction := (advanced - running) - adjusted
                            running := advanced
                            if math.sign(running - requested) >= 0
                                result := physical
                                break
            if result < 0
                result := firstPositive
    result

//@function Clears every weight to 0, retaining the allocation and size.
//@param self FloatFenwick receiver.
//@returns Self for chaining.
export method clear(FloatFenwick self) =>
    _opEnsureFenwick(self)
    if self.tree.size() > 0
        self.tree.fill(0.0)
    if self.values.size() > 0
        self.values.fill(0.0)
    self

//@type Reusable weighted-selection index over a circular physical range.
//      Tier: 2 (Composable) | Stability: Stable
//      Ownership: `weightsUnsafe()` returns a structure-owned mutable view and
//      is only available inside a `weightsEditBegin()` / `weightsEditFinish()`
//      scope. `weightsCopy()` returns caller-owned storage.
//      Complexity: `setWeight()` O(1) in prefix mode and O(log N) while a
//      Fenwick tree is valid. `draw()` O(log N) plus an O(N) refresh on the
//      first read after a weight change in prefix mode.
//      Limits: at most 99,999 weights.
//@field settings Configuration reference.
//@field activePolicy Representation selected by the last `prepare()`.
//@field weights Normalized non-negative weights by physical slot.
//@field prefixIndex Owned linear prefix index.
//@field fenwickIndex Owned Fenwick tree.
//@field capacity Number of physical slots.
//@field exponent Exponent fixed by the last `prepare()`.
//@field weightsRevision Bumped by every effective weight mutation.
//@field prefixValid Whether the prefix index matches the current weights.
//@field prefixExponent Exponent the prefix index was built with.
//@field prefixStart Range start the prefix index was built with.
//@field prefixCount Range count the prefix index was built with.
//@field fenwickValid Whether the tree matches the current weights.
//@field fenwickExponent Exponent the tree was built with.
//@field fenwickStart Window start the tree was built for.
//@field fenwickCount Window length the tree was built for.
//@field prepared Whether `prepare()` has run.
//@field preparedStart Range start fixed by the last `prepare()`.
//@field preparedCount Range count fixed by the last `prepare()`.
//@field preparedTotal Cached total for the prepared range.
//@field preparedTotalValid Whether `preparedTotal` is current.
//@field prepareCycles Completed `prepare()` calls.
//@field stableCycles Consecutive prepares with an unchanged exponent.
//@field updatesSincePrepare Effective weight mutations since the last prepare.
//@field editOpen Whether an unsafe weights edit scope is open.
export type WeightedIndex
    WeightConfig settings = na
    WeightPolicy activePolicy = WeightPolicy.prefix
    array<float> weights = na
    WeightedPrefix prefixIndex = na
    FloatFenwick fenwickIndex = na
    int capacity = 1
    float exponent = na
    int weightsRevision = 0
    bool prefixValid = false
    float prefixExponent = na
    int prefixStart = 0
    int prefixCount = 0
    bool fenwickValid = false
    float fenwickExponent = na
    int fenwickStart = 0
    int fenwickCount = 0
    bool prepared = false
    int preparedStart = 0
    int preparedCount = 0
    float preparedTotal = 0.0
    bool preparedTotalValid = false
    int prepareCycles = 0
    int stableCycles = 0
    int updatesSincePrepare = 0
    bool editOpen = false

//@function Creates a weighted index with every weight at 0.
//@param capacity Number of physical slots. Values below 1 become 1.
//@param settings Configuration, or na for the deterministic prefix defaults.
//@returns A new WeightedIndex.
export weightedIndex(int capacity, WeightConfig settings = na) =>
    int safeCapacity = math.max(nz(capacity, 1), 1)
    if safeCapacity > _OP_MAX_ARRAY - 1
        runtime.error("OptiPine.WeightedIndex: supports at most 99,999 weights.")
    WeightedIndex result = WeightedIndex.new()
    result.settings := na(settings) ? weightConfig() : settings
    result.weights := array.new<float>(safeCapacity, 0.0)
    result.prefixIndex := weightedPrefix()
    result.fenwickIndex := floatFenwick(safeCapacity)
    result.capacity := safeCapacity
    result.activePolicy := result.settings.policy == WeightPolicy.fenwick ?
      WeightPolicy.fenwick : WeightPolicy.prefix
    result

_opEnsureWeightedIndex(WeightedIndex self) =>
    if na(self.settings)
        self.settings := weightConfig()
    if na(self.weights)
        self.weights := array.new<float>(math.max(self.capacity, 1), 0.0)
    if na(self.prefixIndex)
        self.prefixIndex := weightedPrefix()
    if na(self.fenwickIndex)
        self.fenwickIndex := floatFenwick(self.weights.size())
    if self.capacity != self.weights.size()
        self.capacity := self.weights.size()
    self

_opWeightedRebuildFenwick(WeightedIndex self, float exponent, int start, int count) =>
    _opFenwickBuildTransformedCircular(self.fenwickIndex, self.weights, start, count, exponent,
      self.settings.exponentZero == ExponentZeroPolicy.preserveZeros)
    self.fenwickValid := true
    self.fenwickExponent := exponent
    self.fenwickStart := start
    self.fenwickCount := count
    self.preparedTotalValid := false
    self

_opWeightedRebuildPrefix(WeightedIndex self, float exponent, int start, int count) =>
    bool preserveZeros = self.settings.exponentZero == ExponentZeroPolicy.preserveZeros
    self.prefixIndex.buildCircular(self.weights, start, count, exponent, preserveZeros)
    self.prefixValid := true
    self.prefixExponent := exponent
    self.prefixStart := start
    self.prefixCount := count
    self.preparedTotalValid := false
    self

_opWeightedRefresh(WeightedIndex self) =>
    if self.activePolicy == WeightPolicy.fenwick
        if not self.fenwickValid or not _opSameFloat(self.fenwickExponent, self.exponent) or
          self.fenwickStart != self.preparedStart or self.fenwickCount != self.preparedCount
            _opWeightedRebuildFenwick(self, self.exponent, self.preparedStart, self.preparedCount)
    else
        if not self.prefixValid or not _opSameFloat(self.prefixExponent, self.exponent) or
          self.prefixStart != self.preparedStart or self.prefixCount != self.preparedCount
            _opWeightedRebuildPrefix(self, self.exponent, self.preparedStart, self.preparedCount)
    self

_opWeightedTotal(WeightedIndex self) =>
    if not self.preparedTotalValid
        float computed = 0.0
        if self.activePolicy == WeightPolicy.fenwick
            computed := self.fenwickIndex.total()
        else
            computed := self.prefixIndex.total()
        self.preparedTotal := computed
        self.preparedTotalValid := true
    self.preparedTotal

_opWeightedInvalidate(WeightedIndex self, int physicalIndex) =>
    if self.prefixValid and _opInCircularRange(physicalIndex, self.prefixStart, self.prefixCount, self.capacity)
        self.prefixValid := false
    if self.prepared and _opInCircularRange(physicalIndex, self.preparedStart, self.preparedCount, self.capacity)
        self.preparedTotalValid := false
    self

_opWeightedWriteBatch(WeightedIndex self, array<int> slots, array<float> incoming) =>
    _opEnsureWeightedIndex(self)
    if self.editOpen
        runtime.error("OptiPine.WeightedIndex: bulk weight write during an open weights edit scope.")
    bool positional = na(slots)
    int supplied = 0
    if not na(incoming)
        supplied := incoming.size()
    int expected = self.capacity
    if not positional
        expected := slots.size()
    if supplied != expected
        runtime.error("OptiPine.WeightedIndex: a weight batch needs one weight per slot" +
          " - positionally that is exactly capacity values.")
    WeightConfig settings = self.settings
    bool naToZero = settings.naWeights == NaWeightPolicy.treatAsZero
    bool negativeToZero = settings.negativeWeights == NegativeWeightPolicy.clampToZero
    array<float> weights = self.weights
    int limit = self.capacity
    int applied = 0
    if supplied > 0
        if _opAliasFloat(weights, incoming)
            runtime.error("OptiPine.WeightedIndex: a weight batch must not be the index's own weight array.")
        int lastIndex = supplied - 1
        for position = 0 to lastIndex
            int slot = position
            if not positional
                slot := slots.get(position)
            if slot >= 0 and slot < limit
                weights.set(slot,
                  _opNormalizeWeight(incoming.get(position), naToZero, negativeToZero))
                applied += 1
    if applied > 0
        self.weightsRevision += 1
        self.updatesSincePrepare += applied
        self.prefixValid := false
        self.fenwickValid := false
        self.preparedTotalValid := false
    applied

//@function Sets one physical weight.
//          Writing the value it already holds is a no-op and does not
//          invalidate any derived state.
//@param self WeightedIndex receiver.
//@param physicalIndex Physical slot.
//@param weight New weight. na and negative values follow the configured
//       policies.
//@returns true when the slot was in range.
export method setWeight(WeightedIndex self, int physicalIndex, float weight) =>
    _opEnsureWeightedIndex(self)
    if self.editOpen
        runtime.error("OptiPine.WeightedIndex: setWeight during an open weights edit scope." +
          " Call weightsEditFinish() first.")
    bool ok = physicalIndex >= 0 and physicalIndex < self.capacity
    if ok
        WeightConfig settings = self.settings
        float safeWeight = _opNormalizeWeight(weight,
          settings.naWeights == NaWeightPolicy.treatAsZero,
          settings.negativeWeights == NegativeWeightPolicy.clampToZero)
        if not _opSameFloat(self.weights.get(physicalIndex), safeWeight)
            self.weights.set(physicalIndex, safeWeight)
            self.weightsRevision += 1
            self.updatesSincePrepare += 1
            if self.activePolicy == WeightPolicy.fenwick and self.fenwickValid and
              not na(self.fenwickExponent)
                int logicalIndex = _opCircularLogical(physicalIndex, self.fenwickStart,
                  self.fenwickCount, self.capacity)
                if logicalIndex >= 0
                    self.fenwickIndex.set(logicalIndex,
                      _opTransformWeight(safeWeight, self.fenwickExponent,
                        settings.exponentZero == ExponentZeroPolicy.preserveZeros))
            else
                self.fenwickValid := false
            _opWeightedInvalidate(self, physicalIndex)
    ok

//@function Sets one physical weight without bounds checking or weight
//          normalization. Tier 3.
//@param self WeightedIndex receiver.
//@param physicalIndex Physical slot.
//@param weight New weight.
//@returns Self for chaining.
export method setWeightUnchecked(WeightedIndex self, int physicalIndex, float weight) =>
    self.weights.set(physicalIndex, weight)
    self.weightsRevision += 1
    self.updatesSincePrepare += 1
    if self.activePolicy == WeightPolicy.fenwick and self.fenwickValid and
      not na(self.fenwickExponent)
        int logicalIndex = _opCircularLogical(physicalIndex, self.fenwickStart,
          self.fenwickCount, self.capacity)
        if logicalIndex >= 0
            self.fenwickIndex.set(logicalIndex,
              _opTransformWeight(weight, self.fenwickExponent,
                self.settings.exponentZero == ExponentZeroPolicy.preserveZeros))
    else
        self.fenwickValid := false
    _opWeightedInvalidate(self, physicalIndex)
    self

//@function Reads one stored physical weight.
//@param self WeightedIndex receiver.
//@param physicalIndex Physical slot.
//@returns The normalized weight, or na when the slot is out of range.
export method getWeight(WeightedIndex self, int physicalIndex) =>
    float value = na
    if physicalIndex >= 0 and physicalIndex < self.capacity
        value := self.weights.get(physicalIndex)
    value

//@function Sets every weight to one value.
//@param self WeightedIndex receiver.
//@param weight Value written to every slot.
//@returns Self for chaining.
export method fill(WeightedIndex self, float weight) =>
    _opEnsureWeightedIndex(self)
    WeightConfig settings = self.settings
    float safeWeight = _opNormalizeWeight(weight,
      settings.naWeights == NaWeightPolicy.treatAsZero,
      settings.negativeWeights == NegativeWeightPolicy.clampToZero)
    if self.weights.size() > 0
        self.weights.fill(safeWeight)
    self.weightsRevision += 1
    self.updatesSincePrepare += self.capacity
    self.prefixValid := false
    self.fenwickValid := false
    self.preparedTotalValid := false
    self

//@function Sets every weight to 0 and forgets the prepared exponent, range and
//          representation. Capacity and allocations are retained.
//@param self WeightedIndex receiver.
//@returns Self for chaining.
export method clear(WeightedIndex self) =>
    _opEnsureWeightedIndex(self)
    if self.weights.size() > 0
        self.weights.fill(0.0)
    self.prefixIndex.clear()
    self.fenwickIndex.clear()
    self.exponent := na
    self.weightsRevision += 1
    self.prefixValid := false
    self.prefixExponent := na
    self.prefixStart := 0
    self.prefixCount := 0
    self.fenwickValid := false
    self.fenwickExponent := na
    self.fenwickStart := 0
    self.fenwickCount := 0
    self.prepared := false
    self.preparedStart := 0
    self.preparedCount := 0
    self.preparedTotal := 0.0
    self.preparedTotalValid := false
    self.prepareCycles := 0
    self.stableCycles := 0
    self.updatesSincePrepare := 0
    self.editOpen := false
    self.activePolicy := self.settings.policy == WeightPolicy.fenwick ?
      WeightPolicy.fenwick : WeightPolicy.prefix
    self

//@function Opens a scope in which `weightsUnsafe()` may be called. Tier 3.
//@param self WeightedIndex receiver.
//@returns Self for chaining.
export method weightsEditBegin(WeightedIndex self) =>
    _opEnsureWeightedIndex(self)
    if self.editOpen
        runtime.error("OptiPine.WeightedIndex: weightsEditBegin called while an edit scope was already open.")
    self.editOpen := true
    self

//@function Returns the backing weight array for direct mutation. Tier 3.
//          Ownership: borrowed structure-owned mutable view.
//          Mutation: supported only inside an open `weightsEditBegin()` scope.
//          Retaining the reference past `weightsEditFinish()` is a contract
//          violation: the structure has no way to observe later writes, and
//          every derived total would silently go stale.
//          Lifetime: do not retain it past `weightsEditFinish()`.
//          Repair: `weightsEditFinish()` normalizes the array and rebuilds
//          every derived structure. `touchWeights()` does the same without
//          closing a scope.
//@param self WeightedIndex receiver.
//@returns The weights, indexed by physical slot.
export method weightsUnsafe(WeightedIndex self) =>
    if not self.editOpen
        runtime.error("OptiPine.WeightedIndex: weightsUnsafe requires an open weightsEditBegin() scope.")
    self.weights

//@function Announces that the backing weight array changed and repairs every
//          derived structure. Safe to call without an open edit scope.
//@param self WeightedIndex receiver.
//@param normalize Rescan the array and clamp na and negative values. Pass
//       false only when the caller guarantees every value is already valid.
//@returns Self for chaining.
export method touchWeights(WeightedIndex self, bool normalize = true) =>
    _opEnsureWeightedIndex(self)
    if normalize
        WeightConfig settings = self.settings
        bool naToZero = settings.naWeights == NaWeightPolicy.treatAsZero
        bool negativeToZero = settings.negativeWeights == NegativeWeightPolicy.clampToZero
        array<float> weights = self.weights
        int count = weights.size()
        if count > 0
            for index = 0 to count - 1
                float raw = weights.get(index)
                if na(raw) or math.sign(raw) < 0
                    weights.set(index, _opNormalizeWeight(raw, naToZero, negativeToZero))
    self.weightsRevision += 1
    self.updatesSincePrepare += self.capacity
    self.prefixValid := false
    self.fenwickValid := false
    self.preparedTotalValid := false
    self

//@function Closes the unsafe edit scope and repairs every derived structure.
//@param self WeightedIndex receiver.
//@param normalize Rescan the array and clamp na and negative values.
//@returns Self for chaining.
export method weightsEditFinish(WeightedIndex self, bool normalize = true) =>
    if not self.editOpen
        runtime.error("OptiPine.WeightedIndex: weightsEditFinish called without weightsEditBegin.")
    self.editOpen := false
    self.touchWeights(normalize)

//@function Copies the weights into caller-owned storage.
//@param self WeightedIndex receiver.
//@param output Optional caller-owned array. It is cleared and refilled. When
//       na, a newly allocated array is returned.
//@returns The weights by physical slot.
export method weightsCopy(WeightedIndex self, array<float> output = na) =>
    _opEnsureWeightedIndex(self)
    _opSnapshotFloat(self.weights, output, "OptiPine.WeightedIndex.weightsCopy")

//@function Fixes the selection exponent, the circular range and the
//          representation policy.
//@param self WeightedIndex receiver.
//@param exponent Power transform applied to every weight. Values below 0
//       become 0.
//@param startPhysical Physical slot holding logical index 0.
//@param count Number of logical entries. Clipped to capacity.
//@returns Self for chaining.
export method prepare(WeightedIndex self, float exponent, int startPhysical, int count) =>
    _opEnsureWeightedIndex(self)
    if self.editOpen
        runtime.error("OptiPine.WeightedIndex: prepare during an open weights edit scope." +
          " Call weightsEditFinish() first.")
    WeightConfig settings = self.settings
    float safeExponent = math.max(nz(exponent, 1.0), 0.0)
    int safeCount = math.min(math.max(nz(count, 0), 0), self.capacity)
    int safeStart = _opWrapStart(nz(startPhysical, 0), self.capacity)
    bool exponentChanged = na(self.exponent) or not _opSameFloat(self.exponent, safeExponent)

    self.prepareCycles += 1
    self.stableCycles := exponentChanged ? 0 : self.stableCycles + 1

    if settings.policy == WeightPolicy.prefix
        self.activePolicy := WeightPolicy.prefix
    else if settings.policy == WeightPolicy.fenwick
        self.activePolicy := WeightPolicy.fenwick
    else
        int sparseLimit = int(math.ceil(math.max(safeCount, 1) * settings.sparseUpdateRatio))
        bool denseUpdates = self.updatesSincePrepare > sparseLimit
        if denseUpdates or self.stableCycles < settings.promoteAfterCycles
            self.activePolicy := WeightPolicy.prefix
        else
            self.activePolicy := WeightPolicy.fenwick

    self.exponent := safeExponent
    self.prepared := true
    self.preparedStart := safeStart
    self.preparedCount := safeCount
    self.preparedTotalValid := false
    self.updatesSincePrepare := 0
    _opWeightedRefresh(self)
    self

//@function Prepares selection over every physical slot.
//@param self WeightedIndex receiver.
//@param exponent Power transform applied to every weight.
//@returns Self for chaining.
export method prepareAll(WeightedIndex self, float exponent = 1.0) =>
    self.prepare(exponent, 0, self.capacity)

//@function Draws one physical slot from a fraction in [0, 1).
//@param self WeightedIndex receiver.
//@param fraction Selection fraction. Any real value is wrapped into [0, 1),
//       so 1.0 selects the same slot as 0.0.
//@returns The selected physical slot, or -1 when the prepared range has no
//         positive total weight or `prepare()` has not run.
export method draw(WeightedIndex self, float fraction) =>
    int result = -1
    if self.prepared
        _opWeightedRefresh(self)
        float totalWeight = _opWeightedTotal(self)
        if math.sign(totalWeight) > 0
            float wrapped = nz(fraction, 0.0)
            wrapped := wrapped - math.floor(wrapped)
            int logicalIndex = -1
            if self.activePolicy == WeightPolicy.fenwick
                logicalIndex := self.fenwickIndex.lowerBound(wrapped * totalWeight)
            else
                logicalIndex := self.prefixIndex.lowerBound(wrapped * totalWeight)
            if logicalIndex >= 0
                result := (self.preparedStart + logicalIndex) % self.capacity
    result

//@function Draws a batch of physical slots, refreshing derived state once.
//@param self WeightedIndex receiver.
//@param fractions Selection fractions. Read only.
//@param output Optional caller-owned array. It is cleared and refilled. When
//       na, a newly allocated array is returned.
//@returns One physical slot per fraction, in request order. -1 marks a range
//         with no positive total weight.
export method drawMany(
  WeightedIndex self,
  array<float> fractions,
  array<int> output = na) =>
    int requestCount = na(fractions) ? 0 : fractions.size()
    array<int> result = output
    if na(result)
        result := array.new<int>()
    else
        result.clear()
    if requestCount > 0 and self.prepared
        _opWeightedRefresh(self)
        float totalWeight = _opWeightedTotal(self)
        int start = self.preparedStart
        int capacity = self.capacity
        if math.sign(totalWeight) <= 0
            for _ = 0 to requestCount - 1
                result.push(-1)
        else if self.activePolicy == WeightPolicy.fenwick
            FloatFenwick tree = self.fenwickIndex
            for fraction in fractions
                float wrapped = nz(fraction, 0.0)
                wrapped := wrapped - math.floor(wrapped)
                int logicalIndex = tree.lowerBound(wrapped * totalWeight)
                if logicalIndex >= 0
                    result.push((start + logicalIndex) % capacity)
                else
                    result.push(-1)
        else
            WeightedPrefix prefixIndex = self.prefixIndex
            for fraction in fractions
                float wrapped = nz(fraction, 0.0)
                wrapped := wrapped - math.floor(wrapped)
                int logicalIndex = prefixIndex.lowerBound(wrapped * totalWeight)
                if logicalIndex >= 0
                    result.push((start + logicalIndex) % capacity)
                else
                    result.push(-1)
    else if requestCount > 0
        for _ = 0 to requestCount - 1
            result.push(-1)
    result

//@function Transformed total weight of the prepared range.
//@param self WeightedIndex receiver.
//@returns The total, or 0.0 when `prepare()` has not run.
export method total(WeightedIndex self) =>
    float result = 0.0
    if self.prepared
        _opWeightedRefresh(self)
        result := _opWeightedTotal(self)
    result

//@function Transformed selection probability of one physical slot.
//@param self WeightedIndex receiver.
//@param physicalIndex Physical slot.
//@returns The probability in [0, 1], or 0.0 when the slot is outside the
//         prepared range or the range has no positive total weight.
export method probability(WeightedIndex self, int physicalIndex) =>
    float result = 0.0
    if self.prepared and
      _opInCircularRange(physicalIndex, self.preparedStart, self.preparedCount, self.capacity)
        _opWeightedRefresh(self)
        float totalWeight = _opWeightedTotal(self)
        if math.sign(totalWeight) > 0
            float transformed = _opTransformWeight(self.weights.get(physicalIndex), self.exponent,
              self.settings.exponentZero == ExponentZeroPolicy.preserveZeros)
            result := transformed / totalWeight
    result

//@function Representation currently in use.
//@param self WeightedIndex receiver.
//@returns The active WeightPolicy. Never `automatic`.
export method mode(WeightedIndex self) =>
    self.activePolicy

//@function Number of physical slots.
//@param self WeightedIndex receiver.
//@returns The capacity.
export method limit(WeightedIndex self) =>
    self.capacity

//@function Whether `prepare()` has run.
//@param self WeightedIndex receiver.
//@returns true once a range has been prepared.
export method isPrepared(WeightedIndex self) =>
    self.prepared

//@function Exponent fixed by the last `prepare()`.
//@param self WeightedIndex receiver.
//@returns The exponent, or na before the first prepare.
export method currentExponent(WeightedIndex self) =>
    self.exponent

//@function Circular range fixed by the last `prepare()`.
//@param self WeightedIndex receiver.
//@returns [startPhysical, count].
export method preparedRange(WeightedIndex self) =>
    [self.preparedStart, self.preparedCount]

//@function Weight mutations counted since the last `prepare()`. Named
//          distinctly from the `updatesSincePrepare` field.
//@param self WeightedIndex receiver.
//@returns The update count.
export method pendingUpdates(WeightedIndex self) =>
    self.updatesSincePrepare

//@function Monotonic weight revision, for callers that cache derived results.
//          Named distinctly from the free `revision()` constructor.
//@param self WeightedIndex receiver.
//@returns The revision.
export method weightRevision(WeightedIndex self) =>
    self.weightsRevision

//@type Tier 1 facade over `WeightedIndex` for the common non-circular case.
//      Stability: Stable
//      Ownership: `indexView()` returns the owned `WeightedIndex`. Mutating it
//      through that object's own API is supported; the sampler re-prepares
//      whenever its own exponent or capacity no longer matches.
//      Complexity: inherited from `WeightedIndex`. `setWeight()` is O(1)
//      under the prefix policy and O(log N) while a Fenwick tree is active;
//      `setWeights()` and `setMany()` are one batch each.
//@field index Owned weighted index.
//@field exponent Selection exponent applied to every draw.
export type WeightedSampler
    WeightedIndex index = na
    float exponent = 1.0

//@function Creates a weighted sampler.
//@param capacity Number of slots. Values below 1 become 1.
//@param exponent Selection exponent. Values below 0 become 0.
//@param settings Weight configuration, or na for the deterministic prefix
//       defaults.
//@returns A new WeightedSampler.
export weightedSampler(int capacity, float exponent = 1.0, WeightConfig settings = na) =>
    WeightedSampler result = WeightedSampler.new()
    result.index := weightedIndex(capacity, settings)
    result.exponent := math.max(nz(exponent, 1.0), 0.0)
    result

_opEnsureSampler(WeightedSampler self) =>
    if na(self.index)
        self.index := weightedIndex(1)
    if na(self.exponent)
        self.exponent := 1.0
    self

_opSamplerReady(WeightedSampler self) =>
    WeightedIndex index = self.index
    bool automatic = false
    if not na(index.settings)
        automatic := index.settings.policy == WeightPolicy.automatic
    if automatic or not index.prepared or not _opSameFloat(index.exponent, self.exponent) or
      index.preparedStart != 0 or index.preparedCount != index.capacity
        index.prepare(self.exponent, 0, index.capacity)
    self

//@function Sets one slot weight.
//@param self WeightedSampler receiver.
//@param slot Slot index.
//@param weight New weight. na and negative values follow the configured
//       policies.
//@returns true when the slot was in range.
export method setWeight(WeightedSampler self, int slot, float weight) =>
    _opEnsureSampler(self)
    self.index.setWeight(slot, weight)

//@function Replaces every slot weight from one array. Tier 1.
//          Complexity: O(capacity), plus one rebuild of the selection
//          structure on the next draw.
//@param self WeightedSampler receiver.
//@param weights Exactly `size()` values, indexed by slot. na and negative
//       values follow the configured policies.
//@returns Self for chaining.
export method setWeights(WeightedSampler self, array<float> weights) =>
    _opEnsureSampler(self)
    _opWeightedWriteBatch(self.index, na, weights)
    self

//@function Writes weights into selected slots. Tier 1.
//          Complexity: O(batch), plus one rebuild of the selection structure
//          on the next draw.
//@param self WeightedSampler receiver.
//@param slots Slot indices to write. Out-of-range slots are ignored.
//@param weights One weight per slot, in the same order.
//@returns The number of slots actually written, so out-of-range entries are
//         visible to the caller rather than silent.
export method setMany(WeightedSampler self, array<int> slots, array<float> weights) =>
    _opEnsureSampler(self)
    _opWeightedWriteBatch(self.index, na(slots) ? array.new<int>() : slots, weights)

//@function Reads one stored slot weight.
//@param self WeightedSampler receiver.
//@param slot Slot index.
//@returns The normalized weight, or na when the slot is out of range.
export method weight(WeightedSampler self, int slot) =>
    _opEnsureSampler(self)
    self.index.getWeight(slot)

//@function Sets every slot weight to one value.
//@param self WeightedSampler receiver.
//@param weight Value written to every slot.
//@returns Self for chaining.
export method fill(WeightedSampler self, float weight) =>
    _opEnsureSampler(self)
    self.index.fill(weight)
    self

//@function Changes the selection exponent.
//@param self WeightedSampler receiver.
//@param exponent New exponent. Values below 0 become 0.
//@returns Self for chaining.
export method setExponent(WeightedSampler self, float exponent) =>
    _opEnsureSampler(self)
    self.exponent := math.max(nz(exponent, 1.0), 0.0)
    self

//@function Draws one slot from a fraction in [0, 1).
//@param self WeightedSampler receiver.
//@param fraction Selection fraction. Any real value is wrapped into [0, 1).
//@returns The selected slot, or -1 when every weight is 0.
export method sample(WeightedSampler self, float fraction) =>
    _opEnsureSampler(self)
    _opSamplerReady(self)
    self.index.draw(fraction)

//@function Draws a batch of slots, refreshing derived state once.
//@param self WeightedSampler receiver.
//@param fractions Selection fractions. Read only.
//@param output Optional caller-owned array. It is cleared and refilled. When
//       na, a newly allocated array is returned.
//@returns One slot per fraction, in request order.
export method sampleMany(
  WeightedSampler self,
  array<float> fractions,
  array<int> output = na) =>
    _opEnsureSampler(self)
    _opSamplerReady(self)
    self.index.drawMany(fractions, output)

//@function Selection probability of one slot.
//@param self WeightedSampler receiver.
//@param slot Slot index.
//@returns The probability in [0, 1], or 0.0 when every weight is 0.
export method probability(WeightedSampler self, int slot) =>
    _opEnsureSampler(self)
    _opSamplerReady(self)
    self.index.probability(slot)

//@function Transformed total weight across every slot.
//@param self WeightedSampler receiver.
//@returns The total.
export method total(WeightedSampler self) =>
    _opEnsureSampler(self)
    _opSamplerReady(self)
    self.index.total()

//@function Number of slots.
//@param self WeightedSampler receiver.
//@returns The capacity.
export method size(WeightedSampler self) =>
    _opEnsureSampler(self)
    self.index.capacity

//@function Representation currently in use.
//@param self WeightedSampler receiver.
//@returns The active WeightPolicy.
export method mode(WeightedSampler self) =>
    _opEnsureSampler(self)
    self.index.activePolicy

//@function The owned weighted index, for circular ranges, forced policies and
//          scoped weight editing. Tier 2.
//          Ownership: borrowed structure-owned object, not a raw collection.
//          Mutation: supported through the `WeightedIndex` API.
//          Lifetime: valid for the lifetime of the sampler.
//@param self WeightedSampler receiver.
//@returns The owned WeightedIndex.
export method indexView(WeightedSampler self) =>
    _opEnsureSampler(self)
    self.index

//@function Sets every weight to 0 and forgets prepared state.
//@param self WeightedSampler receiver.
//@returns Self for chaining.
export method clear(WeightedSampler self) =>
    _opEnsureSampler(self)
    self.index.clear()
    self
````
