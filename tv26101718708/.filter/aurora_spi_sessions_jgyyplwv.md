# Aurora SPI Sessions

- url: https://www.tradingview.com/script/JGyYPLWv-Aurora-SPI-Sessions/
- type: indicator
- pine_id: PUB;93f4db57e4d046a6b7bb20ca4a012516
- version: 1.0

## Description

[b]Aurora Session Profiles[/b]

[b]█ Overview[/b]

Aurora Session Profiles maps volume separately for the Asia/Tokyo, London/Europe, and US/New York sessions. It works as a standalone indicator or as an overlay with Aurora SPI, adding session-specific volume context to SPI’s structure and zones.

Each session builds its own price-row profile and can display POC, VAH, and VAL. The indicator also identifies Low Volume Nodes (LVNs) and High Volume Nodes (HVNs) and extends their zones through the current Tokyo cycle.

[b]█ How It Works[/b]

[b]⚪ Session Profiles[/b]

Candle volume is distributed across the price rows crossed by each sampled candle. Complete lower-timeframe samples are used when available; otherwise, the indicator uses chart candles. Profiles use 200 rows by default, with up to 250 configurable rows.

[pine]
rowVolume += candleVolume × priceOverlap(candle, row) ÷ candleRange
[/pine]

[b]⚪ LVN and HVN Zones[/b]

The indicator searches each profile for volume valleys and peaks on both sides of price. LVNs represent relatively thin volume corridors; HVNs represent concentrated activity. Box boundaries follow the calculated corridor. Nearby gaps are not filled simply to create a larger zone.

A confirmed zone can remain visible after its session ends. When the developing profile confirms the same node again, its boundaries update to the newly calculated corridor. Older, distant zones that are no longer confirmed are cleared gradually. The next Tokyo session starts a new cycle.

[b]⚪ Volume Strength and Row Lines[/b]

Volume strength is measured against the strongest row in that session’s profile. A thinner LVN valley or fuller HVN peak produces a stronger color tint. Optional lines mark the lowest- and highest-volume row within each calculated zone.

[pine]
LVN strength = 1 − average zone-row volume ÷ peak profile-row volume
HVN strength = average zone-row volume ÷ peak profile-row volume
[/pine]

[b]⚪ Age and Price Heat[/b]

New zones are more transparent. As they age, they become more visible; volume affects their color tint, not their age-based transparency.

Zones above the recent price range shift toward a configurable warm color as their distance increases. Zones below that range shift toward a configurable cool color. The distance is scaled by ATR so the heat responds to the chart’s volatility.

[b]█ How to Use[/b]

[b]⚪ Standalone[/b]

Compare the three session profiles to see where volume was concentrated or thin. Use POC and value-area levels as session references, then inspect the LVN and HVN corridors in the context of price action.

[b]⚪ Alongside Aurora SPI[/b]

Overlay Aurora Session Profiles with Aurora SPI to compare session-specific volume areas with SPI’s broader zones and structure. The session zones use borderless, transparent boxes so both indicators can remain readable on the same chart.

[b]⚪ Heat Timing[/b]

• [b]Scalp 1m:[/b] A shorter, more responsive age and price-range view.  
• [b]Swing 5–15m:[/b] A middle horizon.  
• [b]Slower:[/b] A broader age and price-range view.  
• [b]Custom:[/b] Manual timing controls.

These modes change the heat display. They do not change the underlying LVN/HVN detection rules.

[b]█ Settings[/b]

• [b]Market windows:[/b] Choose Berlin session windows or each market’s local clock, and enable sessions individually.  
• [b]Profile detail:[/b] Set the number of price rows and lower analysis timeframe.  
• [b]LVN/HVN detection:[/b] Adjust node count, smoothing, prominence, and corridor width.  
• [b]Heat and age:[/b] Set the recent price range, ATR distance, colors, and the increase in visibility as zones age.  
• [b]Volume-row lines:[/b] Show the lowest row, highest row, or both for LVNs and HVNs.

[b]█ Data Notes[/b]

The profiles estimate price-level volume from candle ranges and the symbol’s available volume feed. They do not record individual trades at each price. Zones provide market context, not automatic entry or exit signals.

Aurora Session Profiles is derived from Aurora SPI by Drizzle_Algo56 and is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International.

## Source Code

````pine
// Derived from Aurora SPI by Drizzle_Algo56.
// Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International.
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © Drizzle_Algo56
//@version=6
indicator("Aurora SPI Sessions", shorttitle = "SPI Sessions", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 100, max_polylines_count = 10)

string gSessions = "1. Market windows"
string sessionClock = input.string("Berlin windows", "Session clock", options = ["Berlin windows", "Local market clocks"], tooltip = "Berlin windows match the example's 00:00 / 08:00 / 14:00 starts. Local clocks use Tokyo 09:00-16:00, London 08:00-16:00, and New York 09:30-16:00 with automatic DST.", group = gSessions)
bool showAsia = input.bool(true, "Asia / Tokyo", group = gSessions)
string asiaHours = input.session("0000-0800", "Asia hours (Berlin clock)", group = gSessions)
bool showEurope = input.bool(true, "London / Europe", group = gSessions)
string europeHours = input.session("0800-1400", "Europe hours (Berlin clock)", group = gSessions)
bool showUS = input.bool(true, "US / New York", group = gSessions)
string usHours = input.session("1400-2000", "US hours (Berlin clock)", group = gSessions)
string sessionDays = input.string("Weekdays", "Session days", options = ["Weekdays", "Every day"], group = gSessions)
color asiaColor = input.color(color.rgb(114, 121, 207), "Asia color", group = gSessions)
color europeColor = input.color(color.rgb(24, 165, 156), "London color", group = gSessions)
color usColor = input.color(color.rgb(231, 147, 65), "US color", group = gSessions)

string gProfile = "2. Session profiles"
bool showProfiles = input.bool(true, "Show session volume profiles", group = gProfile)
bool showRange = input.bool(true, "Show each session range backdrop", group = gProfile)
color rangeColor = input.color(color.rgb(128, 128, 128), "Session backdrop gray", group = gProfile)
int rows = input.int(200, "Price rows per session", minval = 30, maxval = 250, group = gProfile)
float profileWidth = input.float(25, "Profile width (% of session duration)", minval = 5, maxval = 50, group = gProfile)
color profileColor = input.color(color.rgb(76, 207, 224), "Profile volume color", group = gProfile)
bool showPOC = input.bool(true, "Show session POC", group = gProfile)
bool showVA = input.bool(true, "Show session VAH / VAL", group = gProfile)
float vaPercent = input.float(70, "Value area volume (%)", minval = 1, maxval = 100, group = gProfile)
bool useLowerTF = input.bool(true, "Use complete lower-timeframe candles", group = gProfile)
string analysisTF = input.timeframe("1", "Analysis timeframe", group = gProfile)
int extensionBars = input.int(50, "Extend levels and zones (chart candles)", minval = 2, maxval = 500, group = gProfile)
bool extendToNow = input.bool(true, "Carry session levels to the latest candle", group = gProfile)

string gZones = "3. LVN / HVN (Aurora SPI rules)"
bool showZones = input.bool(true, "Show profile LVN / HVN", group = gZones)
string zoneMode = input.string("LVN + HVN", "Zone mode", options = ["LVN", "HVN", "LVN + HVN"], group = gZones)
int maxZones = input.int(6, "Maximum nodes per side and type", minval = 1, maxval = 30, tooltip = "Selects the strongest LVN/HVN corridors on either side of price; raise it to display more calculated nodes.", group = gZones)
int minimumBars = input.int(20, "Minimum chart candles per session", minval = 5, maxval = 300, group = gZones)
int detectionEvery = input.int(1, "Rescan every N chart candles", minval = 1, maxval = 30, tooltip = "Also rescans immediately when the session price range expands.", group = gZones)
int matchGapRows = input.int(1, "Same-node tracking tolerance (rows)", minval = 0, maxval = 3, tooltip = "Tracks a node as its profile changes; box edges always use the newly calculated LVN/HVN corridor, without added padding.", group = gZones)
int maxTrackedZones = input.int(160, "Maximum zones stored per session", minval = 10, maxval = 160, tooltip = "Allows as many as 480 source zones across three sessions; rendered blocks merge to avoid visual clutter.", group = gZones)
int retainZones = input.int(80, "Zones to retain before gradual cleanup", minval = 10, maxval = 160, tooltip = "At most one old, distant zone is removed per 10 chart candles when no longer confirmed by its profile or when above this count. Recent price visits protect it.", group = gZones)
int smoothRadius = input.int(0, "Smoothing radius (rows)", minval = 0, maxval = 4, group = gZones)
int peakWindow = input.int(8, "Side peak / valley search (rows)", minval = 2, maxval = 20, group = gZones)
float minDepth = input.float(25, "LVN depth / HVN prominence (%)", minval = 5, maxval = 95, group = gZones)
float minHVN = input.float(10, "HVN minimum (% of strongest row)", minval = 1, maxval = 100, group = gZones)
float zoneRise = input.float(20, "HVN width (% node-to-shoulder)", minval = 0, maxval = 70, group = gZones)
int maxZoneRows = input.int(4, "Maximum HVN height (rows)", minval = 1, maxval = 10, group = gZones)
int maxLVNRows = input.int(14, "Maximum LVN corridor height (rows)", minval = 2, maxval = 20, group = gZones)
int maxEdgeLVNRows = input.int(2, "Maximum edge LVN height (rows)", minval = 1, maxval = 8, group = gZones)
float lvnCorridorRise = input.float(50, "LVN width (% valley-to-shoulder)", minval = 10, maxval = 90, group = gZones)
int zoneOpacity = input.int(82, "New zone transparency", minval = 40, maxval = 95, group = gZones)
color lvnColor = input.color(color.rgb(220, 220, 220), "LVN gray", group = gZones)
color hvnColor = input.color(color.rgb(165, 165, 165), "HVN gray", group = gZones)

string gHeat = "4. Zone age and price heat"
bool useHeat = input.bool(true, "Color zones by age and distance", group = gHeat)
string heatMode = input.string("Swing 5-15m", "Heat timing", options = ["Scalp 1m", "Swing 5-15m", "Slower", "Custom"], tooltip = "Presets change age, price-range, and ATR horizons. Custom uses the three timing inputs below.", group = gHeat)
color olderColor = input.color(color.rgb(204, 190, 169), "Older zone tint", group = gHeat)
int ageFullBars = input.int(120, "Custom: full age tint (chart candles)", minval = 10, maxval = 2000, group = gHeat)
int ageOpacityGain = input.int(25, "Reduce transparency as zones age", minval = 0, maxval = 50, tooltip = "New zones use the transparency above. Older zones become more opaque by up to this many points.", group = gHeat)
int heatLookback = input.int(20, "Custom: price range (chart candles)", minval = 2, maxval = 200, group = gHeat)
float heatDistanceATR = input.float(3.0, "Custom: full heat distance (ATR)", minval = 0.25, maxval = 20, step = 0.25, group = gHeat)
color aboveHeatColor = input.color(color.rgb(236, 105, 55), "Far above range: hot", group = gHeat)
color belowHeatColor = input.color(color.rgb(69, 145, 216), "Far below range: cool", group = gHeat)
int heatBlend = input.int(85, "Maximum heat color blend (%)", minval = 0, maxval = 100, group = gHeat)
color strongVolumeColor = input.color(color.rgb(225, 190, 125), "Strong profile volume tint", tooltip = "LVN: the thinner the volume valley, the stronger the tint. HVN: the fuller the volume peak, the stronger the tint.", group = gHeat)
int volumeBlend = input.int(28, "Maximum volume color blend (%)", minval = 0, maxval = 70, group = gHeat)
bool showLVNLowest = input.bool(true, "LVN: lowest-volume row line", group = gHeat)
bool showLVNHighest = input.bool(true, "LVN: highest-volume row line", group = gHeat)
bool showHVNLowest = input.bool(true, "HVN: lowest-volume row line", group = gHeat)
bool showHVNHighest = input.bool(true, "HVN: highest-volume row line", group = gHeat)
color rowLineColor = input.color(color.rgb(190, 190, 190), "Volume-row line color", group = gHeat)

// Separate sessions are intentional: London and New York may overlap.
type SessionNode
    float bottom
    float top
    int kind
    int bornTime
    int bornBar
    int lastSeenBar
    int lastTouchBar
    float volumeStrength

type ZoneBlock
    float bottom
    float top
    int kind
    int bornTime
    int bornBar
    int lastSeenBar
    float volumeStrength
    int profileIndex

type Profile
    int market
    int sessionKey
    int left
    int right
    int lastChartBar
    int chartBars
    float lowPrice
    float highPrice
    float lastPrice
    array<float> highs
    array<float> lows
    array<float> volumes
    array<float> totals
    array<SessionNode> nodes
    int lastScanCount
    int lastRangeBar

type Candidate
    float bottom
    float top
    int kind
    float volumeStrength

f_sessionKey(int t, string hours, string zone) =>
    int hh = int(str.tonumber(str.substring(hours, 0, 2)))
    int mm = int(str.tonumber(str.substring(hours, 2, 4)))
    int today = timestamp(zone, year(t, zone), month(t, zone), dayofmonth(t, zone), hh, mm)
    t >= today ? today : timestamp(zone, year(t, zone), month(t, zone), dayofmonth(t, zone) - 1, hh, mm)

f_binCandle(array<float> totals, float base, float step, float h, float l, float v) =>
    int n = array.size(totals)
    int first = math.max(0, math.min(n - 1, int(math.floor((l - base) / step))))
    int last = math.max(0, math.min(n - 1, int(math.floor((h - base) / step))))
    for r = first to last
        float bottom = base + r * step
        float top = bottom + step
        float share = h > l ? v * math.max(0.0, math.min(h, top) - math.max(l, bottom)) / (h - l) : v
        array.set(totals, r, array.get(totals, r) + share)
    0

// Complete range rebins use boundary updates plus one pass across the rows.
f_rebin(Profile p) =>
    array.fill(p.totals, 0.0)
    int n = array.size(p.totals)
    float base = p.lowPrice
    float step = math.max(p.highPrice - base, syminfo.mintick) / n
    array<float> delta = array.new<float>(n + 1, 0.0)
    array<int> activeDelta = array.new<int>(n + 1, 0)
    int count = array.size(p.volumes)
    if count > 0
        for b = 0 to count - 1
            float h = array.get(p.highs, b)
            float l = array.get(p.lows, b)
            float v = array.get(p.volumes, b)
            int first = math.max(0, math.min(n - 1, int(math.floor((l - base) / step))))
            int last = math.max(0, math.min(n - 1, int(math.floor((h - base) / step))))
            float bottom = base + first * step
            float firstShare = h > l ? v * math.max(0.0, math.min(h, bottom + step) - math.max(l, bottom)) / (h - l) : v
            array.set(p.totals, first, array.get(p.totals, first) + firstShare)
            if last > first
                float lastBottom = base + last * step
                float lastShare = v * math.max(0.0, math.min(h, lastBottom + step) - math.max(l, lastBottom)) / (h - l)
                array.set(p.totals, last, array.get(p.totals, last) + lastShare)
                if last > first + 1
                    float interior = v * step / (h - l)
                    array.set(delta, first + 1, array.get(delta, first + 1) + interior)
                    array.set(delta, last, array.get(delta, last) - interior)
                    array.set(activeDelta, first + 1, array.get(activeDelta, first + 1) + 1)
                    array.set(activeDelta, last, array.get(activeDelta, last) - 1)
        float running = 0.0
        int active = 0
        for r = 0 to n - 1
            running += array.get(delta, r)
            active += array.get(activeDelta, r)
            if active == 0
                running := 0.0
            array.set(p.totals, r, array.get(p.totals, r) + math.max(0.0, running))
    0

f_profile(array<Profile> allProfiles, int market, int key, int t) =>
    Profile found = na
    int i = array.size(allProfiles) - 1
    while i >= 0
        Profile item = array.get(allProfiles, i)
        if item.market == market and item.sessionKey == key
            found := item
            break
        i -= 1
    if na(found)
        found := Profile.new(market, key, t, t, -1, 0, na, na, na, array.new<float>(), array.new<float>(), array.new<float>(), array.new<float>(rows, 0.0), array.new<SessionNode>(), 0, -1)
        array.push(allProfiles, found)
    found

f_addSample(Profile p, float h, float l, float v, float sampleClose, int t, int durationMs) =>
    if array.size(p.volumes) >= 20000
        runtime.error("Session exceeds 20,000 analysis candles. Increase the analysis timeframe.")
    if p.lastChartBar != bar_index
        p.chartBars += 1
        p.lastChartBar := bar_index
    bool newLow = na(p.lowPrice) or l < p.lowPrice
    bool newHigh = na(p.highPrice) or h > p.highPrice
    if newLow
        p.lowPrice := l
    if newHigh
        p.highPrice := h
    if newLow or newHigh
        p.lastRangeBar := bar_index
    array.push(p.highs, h)
    array.push(p.lows, l)
    array.push(p.volumes, math.max(v, 0.0))
    p.lastPrice := sampleClose
    p.right := t + durationMs
    if newLow or newHigh
        f_rebin(p)
    else
        float step = math.max(p.highPrice - p.lowPrice, syminfo.mintick) / rows
        f_binCandle(p.totals, p.lowPrice, step, h, l, math.max(v, 0.0))
    0

f_smooth(array<float> totals, int radius) =>
    int n = array.size(totals)
    array<float> result = array.copy(totals)
    if radius > 0
        for r = 0 to n - 1
            float weighted = 0.0
            float weights = 0.0
            for k = math.max(0, r - radius) to math.min(n - 1, r + radius)
                float w = radius + 1 - math.abs(k - r)
                weighted += array.get(totals, k) * w
                weights += w
            array.set(result, r, weighted / weights)
    result

// The LVN/HVN candidate function is copied from Aurora SPI below. Its search,
// side split, prominence thresholds, corridor width, and tie order are shared.
f_candidates(array<float> sm, float base, float step, int kind, float currentPrice) =>
    int n = array.size(sm)
    float maximum = array.max(sm)
    array<float> scores = array.new<float>(n, 0.0)
    array<float> shoulders = array.new<float>(n, 0.0)
    array<Candidate> result = array.new<Candidate>()
    if maximum > 0
        for zoneSide = -1 to 1 by 2
            array.fill(scores, 0.0)
            array.fill(shoulders, 0.0)
            for r = 0 to n - 1
                float node = array.get(sm, r)
                float nodePrice = base + (r + 0.5) * step
                bool onSide = zoneSide == -1 ? nodePrice < currentPrice : nodePrice >= currentPrice
                bool extremum = kind == -1 ? (r == 0 ? node <= array.get(sm, 1) : r == n - 1 ? node < array.get(sm, n - 2) : node < array.get(sm, r - 1) and node <= array.get(sm, r + 1)) : (r == 0 ? node >= array.get(sm, 1) : r == n - 1 ? node > array.get(sm, n - 2) : node > array.get(sm, r - 1) and node >= array.get(sm, r + 1))
                if onSide and extremum
                    float left = kind == -1 ? 0.0 : maximum
                    float right = kind == -1 ? 0.0 : maximum
                    if r > 0
                        for k = math.max(0, r - peakWindow) to r - 1
                            left := kind == -1 ? math.max(left, array.get(sm, k)) : math.min(left, array.get(sm, k))
                    if r < n - 1
                        for k = r + 1 to math.min(n - 1, r + peakWindow)
                            right := kind == -1 ? math.max(right, array.get(sm, k)) : math.min(right, array.get(sm, k))
                    float shoulder = r == 0 ? right : r == n - 1 ? left : kind == -1 ? math.min(left, right) : math.max(left, right)
                    float depth = kind == -1 ? (shoulder > 0 ? (shoulder - node) / shoulder : 0.0) : (node > 0 ? (node - shoulder) / node : 0.0)
                    if depth >= minDepth / 100 and (kind == -1 or node >= maximum * minHVN / 100)
                        array.set(scores, r, depth)
                        array.set(shoulders, r, shoulder)
            int selected = 0
            for attempt = 0 to n - 1
                float best = array.max(scores)
                if best <= 0 or selected >= maxZones
                    break
                int center = array.indexof(scores, best)
                float node = array.get(sm, center)
                float shoulder = array.get(shoulders, center)
                float cutoff = kind == -1 ? node + (shoulder - node) * lvnCorridorRise / 100 : node + (shoulder - node) * zoneRise / 100
                int widthLimit = kind == -1 ? (center == 0 or center == n - 1 ? maxEdgeLVNRows : maxLVNRows) : maxZoneRows
                int lo = center
                int hi = center
                while hi - lo + 1 < widthLimit
                    float below = lo > 0 ? array.get(sm, lo - 1) : na
                    float above = hi < n - 1 ? array.get(sm, hi + 1) : na
                    bool canDown = not na(below) and (kind == -1 ? below <= cutoff : below >= cutoff)
                    bool canUp = not na(above) and (kind == -1 ? above <= cutoff : above >= cutoff)
                    if not canDown and not canUp
                        break
                    if canDown and (not canUp or (kind == -1 ? below <= above : below >= above))
                        lo -= 1
                    else
                        hi += 1
                // Like SPI's zone row analysis, use the volume contained in
                // the calculated corridor, normalized by the profile peak.
                float corridorVolume = 0.0
                for r = lo to hi
                    corridorVolume += array.get(sm, r)
                float relativeVolume = math.min(1.0, corridorVolume / ((hi - lo + 1) * maximum))
                float strength = kind == -1 ? 1.0 - relativeVolume : relativeVolume
                array.push(result, Candidate.new(base + lo * step, base + (hi + 1) * step, kind, strength))
                selected += 1
                for k = math.max(0, lo - 1) to math.min(n - 1, hi + 1)
                    array.set(scores, k, 0.0)
    result

// A later scan tracks the same node but replaces its bounds with the exact
// current LVN/HVN corridor. Old unmatched nodes keep their last valid bounds.
f_reconcile(Profile p, array<Candidate> candidates, int confirmedTime, int confirmedBar, float rowStep) =>
    array<bool> used = array.new<bool>(array.size(p.nodes), false)
    for c in candidates
        int match = -1
        float nearest = 1e20
        if array.size(p.nodes) > 0
            for i = 0 to array.size(p.nodes) - 1
                SessionNode prior = array.get(p.nodes, i)
                float gap = math.max(0.0, math.max(prior.bottom - c.top, c.bottom - prior.top))
                float centerShift = math.abs((prior.bottom + prior.top) / 2 - (c.bottom + c.top) / 2)
                if not array.get(used, i) and prior.kind == c.kind and gap <= matchGapRows * rowStep and centerShift <= 3 * rowStep and centerShift < nearest
                    match := i
                    nearest := centerShift
        if match >= 0
            array.set(used, match, true)
            SessionNode prior = array.get(p.nodes, match)
            prior.bottom := c.bottom
            prior.top := c.top
            prior.lastSeenBar := confirmedBar
            prior.volumeStrength := c.volumeStrength
        else if array.size(p.nodes) < maxTrackedZones
            array.push(p.nodes, SessionNode.new(c.bottom, c.top, c.kind, confirmedTime, confirmedBar, confirmedBar, confirmedBar, c.volumeStrength))
            array.push(used, true)
    0

// Price revisits refresh a zone. Only an older, distant zone can be retired,
// at most one every ten chart candles, when the collection grows crowded.
f_refreshAndPrune(Profile p, float currentPrice, float candleHigh, float candleLow, int confirmedBar) =>
    for node in p.nodes
        if candleHigh >= node.bottom and candleLow <= node.top
            node.lastTouchBar := confirmedBar
    if confirmedBar % 10 == 0 and array.size(p.nodes) > 0
        int oldest = -1
        float worst = -1.0
        float step = math.max(p.highPrice - p.lowPrice, syminfo.mintick) / rows
        for i = 0 to array.size(p.nodes) - 1
            SessionNode node = array.get(p.nodes, i)
            int age = confirmedBar - math.max(node.lastSeenBar, node.lastTouchBar)
            float distance = math.max(0.0, math.max(node.bottom - currentPrice, currentPrice - node.top)) / step
            bool missingFromProfile = node.lastSeenBar < p.lastChartBar - detectionEvery * 3
            if age >= 30 and distance >= 8 and (missingFromProfile or array.size(p.nodes) > retainZones)
                float score = age + distance
                if score > worst
                    worst := score
                    oldest := i
        if oldest >= 0
            array.remove(p.nodes, oldest)
    0

// Suppress only nearly identical overlaps. Never fill the gap between two
// distinct calculated corridors, even when they are close in price.
f_addBlock(array<ZoneBlock> blocks, SessionNode node, int profileIndex) =>
    int match = -1
    if array.size(blocks) > 0
        for i = 0 to array.size(blocks) - 1
            ZoneBlock block = array.get(blocks, i)
            float overlap = math.max(0.0, math.min(block.top, node.top) - math.max(block.bottom, node.bottom))
            float shorter = math.min(block.top - block.bottom, node.top - node.bottom)
            float taller = math.max(block.top - block.bottom, node.top - node.bottom)
            if block.kind == node.kind and shorter > 0 and overlap / shorter >= 0.8 and taller / shorter <= 1.5
                match := i
                break
    if match >= 0
        ZoneBlock block = array.get(blocks, match)
        block.bornTime := math.min(block.bornTime, node.bornTime)
        block.bornBar := math.min(block.bornBar, node.bornBar)
        if node.lastSeenBar > block.lastSeenBar
            block.bottom := node.bottom
            block.top := node.top
            block.lastSeenBar := node.lastSeenBar
            block.volumeStrength := node.volumeStrength
            block.profileIndex := profileIndex
    else
        array.push(blocks, ZoneBlock.new(node.bottom, node.top, node.kind, node.bornTime, node.bornBar, node.lastSeenBar, node.volumeStrength, profileIndex))
    0

f_smoothedRow(array<float> totals, int row, int radius) =>
    float weighted = 0.0
    float weightSum = 0.0
    for k = math.max(0, row - radius) to math.min(array.size(totals) - 1, row + radius)
        float weight = radius + 1 - math.abs(k - row)
        weighted += array.get(totals, k) * weight
        weightSum += weight
    weighted / weightSum

f_valueArea(array<float> totals, float fraction) =>
    int n = array.size(totals)
    int poc = array.indexof(totals, array.max(totals))
    int lo = poc
    int hi = poc
    float included = array.get(totals, poc)
    float target = array.sum(totals) * fraction
    while included < target and (lo > 0 or hi < n - 1)
        float below = lo > 0 ? array.get(totals, lo - 1) : -1.0
        float above = hi < n - 1 ? array.get(totals, hi + 1) : -1.0
        bool takeAbove = above > below or (above == below and hi - poc <= poc - lo)
        if takeAbove
            hi += 1
            included += above
        else
            lo -= 1
            included += below
    [poc, lo, hi]

if not timeframe.isintraday or not chart.is_standard
    runtime.error("Use standard time-based intraday candles.")

string days = sessionDays == "Weekdays" ? ":23456" : ":1234567"
string asiaWindow = sessionClock == "Berlin windows" ? asiaHours : "0900-1600"
string europeWindow = sessionClock == "Berlin windows" ? europeHours : "0800-1600"
string usWindow = sessionClock == "Berlin windows" ? usHours : "0930-1600"
string asiaSpec = asiaWindow + days
string europeSpec = europeWindow + days
string usSpec = usWindow + days
string asiaTZ = sessionClock == "Berlin windows" ? "Europe/Berlin" : "Asia/Tokyo"
string europeTZ = sessionClock == "Berlin windows" ? "Europe/Berlin" : "Europe/London"
string usTZ = sessionClock == "Berlin windows" ? "Europe/Berlin" : "America/New_York"

f_lowerSample() =>
    [high, low, math.max(nz(volume, 0), 0), close, time,
     not na(time(timeframe.period, asiaSpec, asiaTZ)),
     not na(time(timeframe.period, europeSpec, europeTZ)),
     not na(time(timeframe.period, usSpec, usTZ))]

[ltfH, ltfL, ltfV, ltfC, ltfT, ltfAsia, ltfEurope, ltfUS] = request.security_lower_tf(syminfo.tickerid, analysisTF, f_lowerSample(), ignore_invalid_timeframe = true)
bool lowerEligible = useLowerTF and timeframe.in_seconds(analysisTF) < timeframe.in_seconds()
// Tokyo is the cycle anchor even when its own drawings are switched off.
bool chartTokyoOpen = not na(time(timeframe.period, asiaSpec, asiaTZ))
bool chartAsia = showAsia and chartTokyoOpen
bool chartEurope = showEurope and not na(time(timeframe.period, europeSpec, europeTZ))
bool chartUS = showUS and not na(time(timeframe.period, usSpec, usTZ))

var array<Profile> profiles = array.new<Profile>()
var int tokyoCycleKey = na
float chartVolume = math.max(nz(volume, 0), 0)
int intrabars = array.size(ltfV)
float intrabarVolume = intrabars > 0 ? array.sum(ltfV) : 0.0
bool complete = lowerEligible and intrabars > 0 and intrabarVolume > 0 and chartVolume > 0 and math.abs(intrabarVolume - chartVolume) / chartVolume <= 0.02
if complete
    for k = 0 to intrabars - 1
        int t = array.get(ltfT, k)
        if t < time or t >= time_close
            complete := false

if complete
    float scale = chartVolume / intrabarVolume
    int sampleDuration = int(timeframe.in_seconds(analysisTF) * 1000)
    for k = 0 to intrabars - 1
        int t = array.get(ltfT, k)
        // Clear before routing this first Tokyo sample into the new profile.
        // Later London and US profiles therefore belong to the same cycle.
        int cycle = f_sessionKey(t, asiaWindow, asiaTZ)
        if na(tokyoCycleKey) or cycle != tokyoCycleKey
            array.clear(profiles)
            tokyoCycleKey := cycle
        float h = array.get(ltfH, k)
        float l = array.get(ltfL, k)
        float v = array.get(ltfV, k) * scale
        float c = array.get(ltfC, k)
        if showAsia and array.get(ltfAsia, k)
            int key = f_sessionKey(t, asiaWindow, asiaTZ)
            Profile p = f_profile(profiles, 0, key, t)
            f_addSample(p, h, l, v, c, t, sampleDuration)
        if showEurope and array.get(ltfEurope, k)
            int key = f_sessionKey(t, europeWindow, europeTZ)
            Profile p = f_profile(profiles, 1, key, t)
            f_addSample(p, h, l, v, c, t, sampleDuration)
        if showUS and array.get(ltfUS, k)
            int key = f_sessionKey(t, usWindow, usTZ)
            Profile p = f_profile(profiles, 2, key, t)
            f_addSample(p, h, l, v, c, t, sampleDuration)
else
    // One full chart candle per qualifying session; never append a partial
    // lower-timeframe batch alongside a duplicated chart-candle volume.
    int duration = int(timeframe.in_seconds() * 1000)
    int cycle = f_sessionKey(time, asiaWindow, asiaTZ)
    if na(tokyoCycleKey) or cycle != tokyoCycleKey
        array.clear(profiles)
        tokyoCycleKey := cycle
    if chartAsia
        Profile p = f_profile(profiles, 0, f_sessionKey(time, asiaWindow, asiaTZ), time)
        f_addSample(p, high, low, chartVolume, close, time, duration)
    if chartEurope
        Profile p = f_profile(profiles, 1, f_sessionKey(time, europeWindow, europeTZ), time)
        f_addSample(p, high, low, chartVolume, close, time, duration)
    if chartUS
        Profile p = f_profile(profiles, 2, f_sessionKey(time, usWindow, usTZ), time)
        f_addSample(p, high, low, chartVolume, close, time, duration)

// Refresh every session's zones on each close, including completed sessions.
// The Tokyo-cycle reset above clears all boxes for the previous day.
if barstate.isconfirmed and showZones
    for p in profiles
        f_refreshAndPrune(p, close, high, low, bar_index)
        bool due = p.chartBars >= minimumBars and (p.lastScanCount == 0 or p.chartBars - p.lastScanCount >= detectionEvery or p.lastRangeBar == bar_index)
        if p.lastChartBar == bar_index and due and array.max(p.totals) > 0
            float base = p.lowPrice
            float step = math.max(p.highPrice - base, syminfo.mintick) / rows
            array<float> sm = f_smooth(p.totals, smoothRadius)
            array<Candidate> current = array.new<Candidate>()
            for kind = -1 to 1 by 2
                bool enabled = kind == -1 ? zoneMode != "HVN" : zoneMode != "LVN"
                if enabled
                    array<Candidate> candidates = f_candidates(sm, base, step, kind, p.lastPrice)
                    array.concat(current, candidates)
            f_reconcile(p, current, time, bar_index, step)
            p.lastScanCount := p.chartBars

var array<box> drawings = array.new<box>()
var array<line> levels = array.new<line>()
var array<label> names = array.new<label>()
var array<polyline> profilesDrawn = array.new<polyline>()
int effectiveAgeBars = heatMode == "Scalp 1m" ? 45 : heatMode == "Swing 5-15m" ? 120 : heatMode == "Slower" ? 300 : ageFullBars
int effectiveRangeBars = heatMode == "Scalp 1m" ? 12 : heatMode == "Swing 5-15m" ? 20 : heatMode == "Slower" ? 60 : heatLookback
float effectiveHeatATR = heatMode == "Scalp 1m" ? 1.5 : heatMode == "Swing 5-15m" ? 3.0 : heatMode == "Slower" ? 5.0 : heatDistanceATR
float atrFast = ta.atr(7)
float atrMid = ta.atr(14)
float atrSlow = ta.atr(21)
float selectedATR = heatMode == "Scalp 1m" ? atrFast : heatMode == "Slower" ? atrSlow : atrMid
float recentRangeHigh = ta.highest(high, effectiveRangeBars)
float recentRangeLow = ta.lowest(low, effectiveRangeBars)
float heatUnit = math.max(nz(selectedATR, high - low), syminfo.mintick)
if barstate.islast
    while array.size(drawings) > 0
        box.delete(array.pop(drawings))
    while array.size(levels) > 0
        line.delete(array.pop(levels))
    while array.size(names) > 0
        label.delete(array.pop(names))
    while array.size(profilesDrawn) > 0
        polyline.delete(array.pop(profilesDrawn))
    int sessionCount = array.size(profiles)
    if sessionCount > 0
        // At most nine profile polylines and nine backdrops. Polylines keep
        // every price row visible while the boxes remain available for nodes.
        int candleMs = int(timeframe.in_seconds() * 1000)
        array<ZoneBlock> combined = array.new<ZoneBlock>()
        int profileIndex = 0
        for p in profiles
            float peak = array.max(p.totals)
            if peak > 0
                float base = p.lowPrice
                float step = math.max(p.highPrice - base, syminfo.mintick) / rows
                int extendedRight = extendToNow ? math.max(p.right + extensionBars * candleMs, time_close) : p.right + extensionBars * candleMs
                color marketColor = p.market == 0 ? asiaColor : p.market == 1 ? europeColor : usColor
                string marketName = p.market == 0 ? "ASIA" : p.market == 1 ? "LONDON" : "US"
                if showRange
                    array.push(drawings, box.new(p.left, p.highPrice, p.right, p.lowPrice, xloc = xloc.bar_time, border_color = na, bgcolor = color.new(rangeColor, 94)))
                if showProfiles
                    int widthMs = math.max(1, int((p.right - p.left) * profileWidth / 100))
                    array<chart.point> outline = array.new<chart.point>()
                    array.push(outline, chart.point.from_time(p.left, base))
                    for r = 0 to rows - 1
                        float activity = array.get(p.totals, r)
                        int edge = p.left + int(widthMs * activity / peak)
                        array.push(outline, chart.point.from_time(edge, base + r * step))
                        array.push(outline, chart.point.from_time(edge, base + (r + 1) * step))
                    array.push(outline, chart.point.from_time(p.left, base + rows * step))
                    array.push(profilesDrawn, polyline.new(outline, closed = true, xloc = xloc.bar_time, line_color = na, fill_color = color.new(profileColor, 35)))
                if showPOC or showVA
                    [poc, vaLo, vaHi] = f_valueArea(p.totals, vaPercent / 100)
                    if showPOC
                        float y = base + (poc + 0.5) * step
                        array.push(levels, line.new(p.left, y, extendedRight, y, xloc = xloc.bar_time, color = marketColor, style = line.style_solid, width = 2))
                        array.push(names, label.new(extendedRight, y, marketName + " POC", xloc = xloc.bar_time, style = label.style_label_left, color = na, textcolor = marketColor, size = size.small))
                    if showVA
                        float vah = base + (vaHi + 1) * step
                        float val = base + vaLo * step
                        array.push(levels, line.new(p.left, vah, extendedRight, vah, xloc = xloc.bar_time, color = marketColor, style = line.style_solid))
                        array.push(levels, line.new(p.left, val, extendedRight, val, xloc = xloc.bar_time, color = marketColor, style = line.style_solid))
                if showZones and array.size(p.nodes) > 0
                    for node in p.nodes
                        f_addBlock(combined, node, profileIndex)
            profileIndex += 1
        if showZones
            for block in combined
                color baseColor = block.kind == -1 ? lvnColor : hvnColor
                float age = math.min(1.0, math.max(0.0, (bar_index - block.bornBar) * 1.0 / effectiveAgeBars))
                color agedColor = useHeat ? color.from_gradient(age, 0.0, 1.0, baseColor, olderColor) : baseColor
                float volumeStrength = math.max(0.0, math.min(1.0, block.volumeStrength))
                color volumeColor = useHeat ? color.from_gradient(volumeStrength * volumeBlend / 100, 0.0, 1.0, agedColor, strongVolumeColor) : agedColor
                float aboveDistance = math.max(0.0, block.bottom - recentRangeHigh)
                float belowDistance = math.max(0.0, recentRangeLow - block.top)
                float heat = math.min(1.0, math.max(aboveDistance, belowDistance) / (heatUnit * effectiveHeatATR)) * heatBlend / 100
                color targetColor = aboveDistance > 0 ? aboveHeatColor : belowHeatColor
                color zoneColor = useHeat and heat > 0 ? color.from_gradient(heat, 0.0, 1.0, volumeColor, targetColor) : volumeColor
                int transparency = useHeat ? math.max(0, zoneOpacity - int(math.round(age * ageOpacityGain))) : zoneOpacity
                array.push(drawings, box.new(block.bornTime, block.top, time_close, block.bottom, xloc = xloc.bar_time, border_color = na, border_width = 0, bgcolor = color.new(zoneColor, transparency)))
                bool wantLowest = block.kind == -1 ? showLVNLowest : showHVNLowest
                bool wantHighest = block.kind == -1 ? showLVNHighest : showHVNHighest
                if (wantLowest or wantHighest) and array.size(levels) < 498
                    Profile source = array.get(profiles, block.profileIndex)
                    float rowStep = math.max(source.highPrice - source.lowPrice, syminfo.mintick) / rows
                    int firstRow = math.max(0, math.min(rows - 1, int(math.floor((block.bottom - source.lowPrice) / rowStep))))
                    int lastRow = math.max(0, math.min(rows - 1, int(math.ceil((block.top - source.lowPrice) / rowStep)) - 1))
                    float lowestVolume = na
                    float highestVolume = na
                    float lowestPrice = na
                    float highestPrice = na
                    if firstRow <= lastRow
                        for r = firstRow to lastRow
                            float rowBottom = source.lowPrice + r * rowStep
                            float rowTop = rowBottom + rowStep
                            if rowTop > block.bottom and rowBottom < block.top
                                float rowVolume = f_smoothedRow(source.totals, r, smoothRadius)
                                if na(lowestVolume) or rowVolume < lowestVolume
                                    lowestVolume := rowVolume
                                    lowestPrice := rowBottom + rowStep * 0.5
                                if na(highestVolume) or rowVolume > highestVolume
                                    highestVolume := rowVolume
                                    highestPrice := rowBottom + rowStep * 0.5
                    if wantLowest and not na(lowestPrice) and array.size(levels) < 500
                        array.push(levels, line.new(block.bornTime, lowestPrice, time_close, lowestPrice, xloc = xloc.bar_time, color = color.new(rowLineColor, 25), style = line.style_dashed))
                    if wantHighest and not na(highestPrice) and (not wantLowest or highestPrice != lowestPrice) and array.size(levels) < 500
                        array.push(levels, line.new(block.bornTime, highestPrice, time_close, highestPrice, xloc = xloc.bar_time, color = color.new(rowLineColor, 25), style = line.style_dashed))
````
