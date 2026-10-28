# Volatility-Adjusted Supply & Demand Zones [Footprint]

- url: https://www.tradingview.com/script/fTVJsjx5-Volatility-Adjusted-Supply-Demand-Zones-Footprint/
- type: indicator
- pine_id: PUB;0e7d28b6db8d433a9c18aa092ec5e288
- version: 1.0

## Description

[b]Volatility-Adjusted Supply & Demand Zones [Footprint][/b]

[b]Overview[/b]

Most supply and demand indicators draw zones based on price structure alone — a strong candle appears, a box gets painted, and every zone looks equally valid. This indicator takes a different approach: it sizes and scores every zone using ATR-based volatility, then validates each zone using real order flow data pulled from the bar's volume footprint. The result is a layer of institutional context that price-only zone detectors cannot provide.

The indicator detects displacement candles whose bodies exceed a user-defined ATR multiple, assigns each zone a composite strength score derived from body size and relative volume, and then cross-references the zone's origin bar against footprint delta — the net difference between aggressive buying and aggressive selling — to classify each zone as confirmed, weak, or mitigated. Zones where order flow agreed with the directional move are rendered at full opacity. Zones where delta contradicted the move are faded, acting as a caution signal rather than a confident level. A built-in performance heatmap tracks historical win rates and delta confirmation rates across five strength bins so you can calibrate inputs to your instrument over time.

[b]How it works[/b]

[b]Zone detection[/b]

On each bar the indicator computes ATR and compares the candle body size against it. If the body exceeds the displacement threshold (ATR × Displacement Multiplier), the bar is flagged as a displacement move. A pending zone is created at the candle's proximal edge and held in a queue. The zone is only confirmed after price has moved away cleanly for a user-defined number of bars without re-entering the candidate range. If price re-enters during the waiting period, the candidate is discarded.

[pine]
bodySize     = math.abs(close - open)
dispRatio    = bodySize / atr
isStrongMove = dispRatio > displacementMult
[/pine]

Zone height is fixed at the time of detection: ATR × Zone Width Multiplier, measured from the proximal edge of the displacement candle inward. Demand zones extend downward from the candle high; supply zones extend upward from the candle low.

[b]Strength score[/b]

Each zone carries a strength score calculated from the body-to-ATR ratio and the bar's relative volume (volume divided by its moving average). Multiplying these two factors rewards moves that were both large in price terms and accompanied by elevated volume.

[pine]
relVol        = volume / ta.sma(volume, volLengthInput)
strengthScore = dispRatio * math.sqrt(relVol)
[/pine]

The score is displayed on the zone label and used to bin zones into the statistics table.

[b]Footprint delta confirmation[/b]

The indicator calls [pine]request.footprint()[/pine] once per bar to obtain the volume footprint for the displacement candle. It reads the bar-level delta (net aggressive buying minus selling), and also inspects the Point of Control (POC) row for directional imbalance. A demand zone is delta-confirmed when the origin bar shows net buying (delta > 0). A supply zone is confirmed when the origin bar shows net selling (delta < 0). When delta contradicts the zone direction, the zone is rendered at the Weak Zone Transparency level as a visual warning.

Zones whose POC row has a confirming buy or sell imbalance are marked with a ⚡ symbol on their label, indicating that the most-traded price level within the bar showed a pronounced one-sided order flow skew.

[b]Visual encoding[/b]

[list]
[*][b]Full-opacity zone[/b] — footprint delta confirmed the zone direction. Treat as a standard level.
[*][b]Faded zone (Weak Zone Transparency)[/b] — delta contradicted the zone direction. Approach with caution; order flow did not support the move.
[*][b]Heavily faded zone (Mitigated Transparency)[/b] — price has since closed through the far edge of the zone. The level has been invalidated.
[*][b]⚡ label marker[/b] — the POC row of the origin bar showed a confirming imbalance, suggesting concentrated institutional activity at the most-traded price.
[/list]

[b]Inputs[/b]

[b]Detection[/b]

[list=1]
[*][b]ATR Length[/b] — lookback period for ATR, which controls zone width, displacement sensitivity, and reaction targets across the entire indicator. Lower values (e.g. 7) make ATR respond faster to recent volatility, producing narrower zones on quiet bars. Higher values (e.g. 21) smooth out spikes for more consistent sizing. Default: 14.
[*][b]Displacement Multiplier[/b] — minimum candle body size as a multiple of ATR required to qualify as a displacement move. Lower values (e.g. 0.5) detect more zones including smaller impulses. Higher values (e.g. 1.5–2.0) filter down to only the most explosive candles. Default: 1.0.
[*][b]Volume MA Length[/b] — lookback period for the volume simple moving average used to compute relative volume. Lower values (e.g. 10) make the baseline adapt quickly so only larger surges register. Higher values (e.g. 50) treat moderate volume increases as more significant. Affects the strength score only, not zone placement. Default: 20.
[*][b]Zone Width ATR Multiplier[/b] — height of each zone expressed as a multiple of ATR at detection. Lower values (e.g. 0.3) produce tight zones that require a precise re-entry. Higher values (e.g. 1.0) tolerate wider wicks before a touch is registered. Default: 0.5.
[*][b]Confirmation Bars[/b] — number of bars price must hold outside the zone after the displacement candle before the zone is drawn. Lower values (e.g. 1–2) capture zones faster but allow more false starts. Higher values (e.g. 5+) require a sustained move away and reduce noise. Default: 3.
[/list]

[b]Volume Footprint[/b]

[list=1]
[*][b]Ticks Per Footprint Row[/b] — price range of each footprint row in ticks. Smaller values (e.g. 10–25) produce more granular rows and more detailed POC detection. Larger values (e.g. 200–500) aggregate into fewer rows and run faster. Match to your instrument: for ES futures (0.25 pts/tick), 100 ticks = 25 points per row; for BTC (0.10/tick), 1000 ticks ≈ $100 per row. Default: 100.
[*][b]Value Area %[/b] — percentage of total bar volume that defines the Value Area, following standard market profile convention. Raising this widens the VA; lowering it tightens it. Default: 70.
[*][b]Imbalance Threshold %[/b] — how much a row's buy volume must exceed the row below's sell volume (or vice versa) to be flagged as imbalanced. At 300%, buy volume must be 3× the adjacent row's sell volume. Lower values (e.g. 150%) flag more imbalances; higher values (e.g. 500%) flag only extreme skews. Default: 300.
[*][b]Show Delta on Zone[/b] — when enabled, the zone label includes the footprint delta direction (▲/▼) and size in thousands at the origin bar. Disable to show only the strength score. Default: on.
[*][b]Highlight Imbalanced Zones[/b] — when enabled, zones whose origin bar POC row has a confirming directional imbalance are marked with ⚡ in the label. Disable to suppress imbalance detection entirely. Default: on.
[/list]

[b]Statistics[/b]

[list=1]
[*][b]Show Performance Heatmap[/b] — toggles the heatmap table in the top-right corner. The table groups zones into five strength bins and shows demand win rate, supply win rate, total zone count, and delta confirmation rate per bin, colour-coded from red (low) to green (high). Default: on.
[*][b]Reaction Target (ATR)[/b] — how far price must move away from a zone after touching it to count as a successful reaction, in ATR multiples. Lower values (e.g. 0.5) count small bounces as wins; higher values (e.g. 2.5–3.0) require meaningful moves. Affects statistics only — does not resize zones. Default: 1.5.
[/list]

[b]Style[/b]

[list=1]
[*][b]Demand Color[/b] — fill and border colour for demand zones. The opacity set in the colour picker controls baseline transparency; delta-confirmed zones render at this opacity while weak zones are additionally faded. Default: green at 60% transparency.
[*][b]Supply Color[/b] — fill and border colour for supply zones. The same transparency layering applies as demand zones. Default: red at 60% transparency.
[*][b]Weak Zone Transparency[/b] — transparency applied to zones where footprint delta contradicts the zone direction. Higher values (closer to 100) make weak zones nearly invisible. Lower values keep them visible as a caution marker. Default: 82.
[*][b]Mitigated Transparency[/b] — transparency applied after a zone is invalidated by price closing through its far edge. Higher values clean up the chart; lower values retain mitigated zones as historical context. Default: 90.
[/list]

[b]Usage notes[/b]

[list]
[*]Before trusting any zone, check the label: a ▼ delta on a demand zone or ▲ delta on a supply zone means aggressive order flow did not support the move. Wait for additional confirmation before entering against the zone.
[*]The ⚡ marker identifies zones where the most-traded price level within the displacement bar showed a one-sided imbalance. These levels represent potential areas of concentrated institutional activity and may produce stronger reactions than unmarked zones.
[*]Use the performance heatmap to calibrate your displacement and volume inputs. If the highest-scoring bins (6–8, 8+) are showing low win rates for your instrument, the displacement multiplier may be too low and is capturing impulsive but unsustained moves.
[*]The Δ Conf% column in the heatmap shows what fraction of zones in each strength bin had confirming delta. If high-strength zones show low confirmation rates on your instrument, consider whether a different timeframe or session gives more reliable footprint data.
[*]Footprint data requires a TradingView subscription tier that provides volume footprint access. On instruments or timeframes where footprint is unavailable, delta values display as "Δ n/a" and all zones default to confirmed status so zone detection still functions.
[*]Ticks Per Footprint Row is the most instrument-sensitive input. Set it too small and computation overhead increases; set it too large and POC imbalance detection loses resolution. For equity index futures, 50–100 ticks per row is a reasonable starting range.
[*]Mitigated zones (heavily faded) mark levels where price has already broken through. They are kept visible by default as historical reference but can be hidden completely by setting Mitigated Transparency to 100.
[*]This indicator does not generate entry signals. It identifies structural levels with order flow context. Combine it with a trigger mechanism — a lower-timeframe confirmation candle, a momentum signal, or a volume surge — before committing to a trade.
[/list]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © jabez4jc
//@version=6
indicator("Volatility-Adjusted Supply & Demand Zones [Footprint]", overlay = true, max_boxes_count = 500)

// ─── Detection ────────────────────────────────────────────────────────────────
atrLengthInput   = input.int(14,  "ATR Length", minval = 1, group = "Detection",
     tooltip = "Number of bars used to calculate the Average True Range (ATR). ATR is the volatility baseline for the entire indicator — it controls zone width, displacement sensitivity, and reaction targets. Lower values (e.g. 7) make ATR react faster to recent volatility, producing narrower zones on quiet bars and wider zones after big swings. Higher values (e.g. 21) smooth out volatility spikes and give more consistent zone sizing across market conditions.")
displacementMult = input.float(1.0, "Displacement Multiplier", minval = 0.1, step = 0.1, group = "Detection",
     tooltip = "Minimum candle body size, expressed as a multiple of ATR, required to create a zone candidate. A body must be at least (ATR × this value) to qualify as a displacement move. Lower values (e.g. 0.5) detect more zones including smaller impulses — useful on higher timeframes where strong moves are rarer. Higher values (e.g. 1.5–2.0) filter down to only the most explosive displacement candles, producing fewer but potentially higher-quality zones. Too low = chart noise; too high = almost no zones.")
volLengthInput   = input.int(20,  "Volume MA Length", minval = 1, group = "Detection",
     tooltip = "Lookback period for the simple moving average of volume used to calculate relative volume. Each bar's volume is divided by this average to produce a 'relative volume' ratio, which feeds into the zone strength score alongside body size. Lower values (e.g. 10) make the average adapt quickly so that a volume spike must be larger to stand out. Higher values (e.g. 50) use a longer baseline, meaning moderate volume surges register as more significant. Does not affect zone placement, only the strength score shown on each zone label.")
zoneWidthMult    = input.float(0.5, "Zone Width ATR Multiplier", minval = 0.1, step = 0.1, group = "Detection",
     tooltip = "Defines the height (price range) of each zone as a multiple of ATR at the time of detection. Demand zones extend downward from the displacement candle's high; supply zones extend upward from the low. Smaller values (e.g. 0.3) produce tighter, more precise zones that are harder for price to re-enter cleanly. Larger values (e.g. 1.0) create wider zones with more tolerance — price can wick into the zone without immediately triggering a mitigation. Tune to your instrument's typical wick size relative to ATR.")
confirmationBars = input.int(3,   "Confirmation Bars", minval = 1, maxval = 10, group = "Detection",
     tooltip = "Number of bars price must hold away from the zone after the displacement candle before the zone is drawn. This prevents zones from forming on moves that immediately reverse. Lower values (e.g. 1–2) draw zones faster and capture more of them, but some will be false starts. Higher values (e.g. 5+) require a longer sustained move away, reducing noise but potentially missing zones on fast-moving instruments. If price re-enters the zone during this waiting period, the candidate is discarded entirely.")

// ─── Volume Footprint ─────────────────────────────────────────────────────────
ticksPerRow      = input.int(100, "Ticks Per Footprint Row", minval = 1, group = "Volume Footprint",
     tooltip = "Sets the price range of each footprint row in ticks. Smaller values (e.g. 10–25) create more granular rows, revealing detailed buy/sell distribution within the bar at the cost of more computation. Larger values (e.g. 200–500) aggregate volume into fewer, broader rows — faster but less precise. The POC (Point of Control) row and its imbalance detection both depend on this granularity. Match to your instrument: for ES futures one tick = 0.25 pts, so 100 ticks = 25 points per row. For BTC, one tick = $0.10, so 1000 ticks ≈ $100 per row.")
vaPercent        = input.int(70,  "Value Area %", minval = 1, maxval = 100, group = "Volume Footprint",
     tooltip = "The percentage of a bar's total volume that defines the Value Area (VA) — the price range containing the most traded volume. Defaults to 70 (the standard in market profile theory). The VA boundaries (VAH and VAL) are used internally to identify whether the POC sits within a high-activity cluster. Raising this value widens the VA; lowering it tightens it. For most users the default of 70 is appropriate — only change this if you specifically want a non-standard value area definition.")
imbalancePct     = input.float(300, "Imbalance Threshold %", minval = 50, step = 10, group = "Volume Footprint",
     tooltip = "Controls how aggressive the buy/sell imbalance detection is on each footprint row. A buy imbalance exists when a row's buy volume exceeds the sell volume of the row directly below it by at least this percentage. A sell imbalance is the mirror. At 300% (the default), buy volume must be 3× the row below's sell volume to flag as imbalanced. Lower values (e.g. 150%) flag more imbalances — useful if you want to catch moderate order flow skews. Higher values (e.g. 500%) only flag extreme imbalances. Imbalanced zones show a ⚡ on their label when 'Highlight Imbalanced Zones' is enabled.")
showDeltaLabel   = input.bool(true, "Show Delta on Zone", group = "Volume Footprint",
     tooltip = "When enabled, each zone label shows the footprint delta (▲ for net buying, ▼ for net selling) and the delta size in thousands (K) at the time the displacement candle formed. Example: '2.3  ▲ 14.5K' means strength 2.3, net buy delta of 14,500 contracts/shares. Disable this to keep zone labels minimal if you only want the strength score.")
showImbalance    = input.bool(true, "Highlight Imbalanced Zones", group = "Volume Footprint",
     tooltip = "When enabled, zones whose displacement bar POC row has a confirming footprint imbalance are marked with ⚡ in their label. A demand zone is confirming-imbalanced when the POC row has a buy imbalance (aggressive buyers at the most-traded price). A supply zone is confirming-imbalanced when the POC has a sell imbalance. These zones represent areas where institutional order flow was heavily one-sided, potentially indicating stronger support or resistance. Disable to suppress imbalance detection and the ⚡ marker entirely.")

// ─── Statistics ───────────────────────────────────────────────────────────────
showDashboard    = input.bool(true, "Show Performance Heatmap", group = "Statistics",
     tooltip = "Toggles the performance heatmap table in the top-right corner. The table groups all historical zones into 5 strength bins (0–2, 2–4, 4–6, 6–8, 8+) and shows the win rate for demand zones, supply zones, total zone count, and the delta confirmation rate per bin. Green cells = high win/confirmation rate, red = low. Use this to identify which strength scores have historically produced the best reactions, and whether footprint-confirmed zones outperform unconfirmed ones.")
reactionMult     = input.float(1.5, "Reaction Target (ATR)", minval = 0.1, step = 0.1, group = "Statistics",
     tooltip = "Determines how far price must move away from a zone after touching it to count as a successful reaction, measured in ATR multiples. For a demand zone: price must rally at least (ATR × this value) above the zone top after touching it. For a supply zone: price must fall at least (ATR × this value) below the zone bottom. Lower values (e.g. 0.5) count small bounces as wins, inflating win rates. Higher values (e.g. 2.5–3.0) require meaningful moves, giving a stricter and more tradeable win rate. This only affects the statistics table — it does not move or resize zone boxes.")

// ─── Style ────────────────────────────────────────────────────────────────────
bullColorInput   = input.color(color.new(#089981, 60), "Demand Color", inline = "Colors", group = "Style",
     tooltip = "Fill and border color for demand (support) zones. The number in the color picker's opacity field controls how strongly the zone fills the chart. Delta-confirmed demand zones render at full opacity; delta-contradicted zones are additionally faded by the 'Weak Zone Transparency' setting. Mitigated demand zones fade further using 'Mitigated Transparency'.")
bearColorInput   = input.color(color.new(#f23645, 60), "Supply Color", inline = "Colors", group = "Style",
     tooltip = "Fill and border color for supply (resistance) zones. The same transparency layering as demand zones applies: full color = delta confirmed, faded = delta contradicted (weak), heavily faded = mitigated (broken).")
weakAlpha        = input.int(82, "Weak Zone Transparency", minval = 0, maxval = 100, group = "Style",
     tooltip = "Transparency level applied to zones where the footprint delta contradicts the zone direction — net selling on a demand zone, or net buying on a supply zone. Higher values (closer to 100) make weak zones nearly invisible. Lower values (closer to 0) make them nearly as visible as confirmed zones. At 82 (default), weak zones are clearly faded but still visible as a caution signal. Set to 100 to completely hide delta-contradicted zones.")
mitigatedAlpha   = input.int(90, "Mitigated Transparency", minval = 0, maxval = 100, group = "Style",
     tooltip = "Transparency applied to a zone after it has been mitigated — i.e. price has closed through the far edge of the zone, invalidating it as support or resistance. Higher values make mitigated zones nearly invisible (cleaner chart). Lower values keep them visible as historical reference. At 90 (default), mitigated zones are barely visible. Set to 100 to hide them completely, or lower to 70–80 to keep them as faint context markers.")

// ─── Footprint Request (one per script) ───────────────────────────────────────
//@variable Live footprint object for the current bar. na when data is unavailable.
footprint fp = request.footprint(ticksPerRow, vaPercent, imbalancePct)

// Unpack bar-level footprint values into plain series so they can be referenced
// in arrays / lookbacks later (footprint objects cannot be stored in arrays).
float fpDelta     = not na(fp) ? fp.delta()      : na
float fpBuyVol    = not na(fp) ? fp.buy_volume()  : na
float fpSellVol   = not na(fp) ? fp.sell_volume() : na

// POC row data (price range + imbalance flag)
float fpPocUp     = na
float fpPocDn     = na
bool  fpPocBuyImb = false
bool  fpPocSelImb = false
if not na(fp)
    volume_row pocRow = fp.poc()
    if not na(pocRow)
        fpPocUp     := pocRow.up_price()
        fpPocDn     := pocRow.down_price()
        fpPocBuyImb := pocRow.has_buy_imbalance()
        fpPocSelImb := pocRow.has_sell_imbalance()

// ─── Types ────────────────────────────────────────────────────────────────────
type Zone
    int   startBar
    box   boxId
    float top
    float bottom
    bool  isDemand
    bool  isMitigated
    float strength
    bool  wasTouched
    bool  hasReacted
    // footprint fields
    float delta           // bar delta at zone origin bar
    float buyVol          // buy volume at zone origin bar
    float sellVol         // sell volume at zone origin bar
    bool  deltaConfirmed  // delta direction agrees with zone type
    bool  pocImbalance    // POC row has a confirming imbalance
    float pocUp           // POC upper price at origin
    float pocDn           // POC lower price at origin

type PendingZone
    int   startBar
    float top
    float bottom
    bool  isDemand
    float strength
    int   barsPassed
    // footprint snapshot (captured at detection bar)
    float delta
    float buyVol
    float sellVol
    bool  pocImbalance
    float pocUp
    float pocDn

// ─── Storage ──────────────────────────────────────────────────────────────────
var demandZones  = array.new<Zone>()
var supplyZones  = array.new<Zone>()
var pendingZones = array.new<PendingZone>()

// Stats counters — bins: 0-2, 2-4, 4-6, 6-8, 8+
var totalDemand  = array.new_int(5, 0)
var winsDemand   = array.new_int(5, 0)
var totalSupply  = array.new_int(5, 0)
var winsSupply   = array.new_int(5, 0)

getBin(float strength) =>
    strength < 2.0 ? 0 : strength < 4.0 ? 1 : strength < 6.0 ? 2 : strength < 8.0 ? 3 : 4

// ─── Calculations ─────────────────────────────────────────────────────────────
atr      = ta.atr(atrLengthInput)
avgVol   = ta.sma(volume, volLengthInput)
bodySize = math.abs(close - open)

relVol       = not na(avgVol) and avgVol > 0 ? volume / avgVol : 1.0
dispRatio    = not na(atr) and atr > 0 ? bodySize / atr : 0.0
strengthScore = dispRatio * math.sqrt(relVol)
isStrongMove  = dispRatio > displacementMult

// ─── Detection: Push Pending Zones ────────────────────────────────────────────
// Capture footprint snapshot at the detection bar so it travels with the zone.
if isStrongMove and close > open
    // Demand zone: displacement candle is bullish → expect positive delta
    bool pocImb = showImbalance ? fpPocBuyImb : false
    pendingZones.push(PendingZone.new(
         bar_index,
         high, high - (atr * zoneWidthMult),
         true,
         strengthScore, 0,
         fpDelta, fpBuyVol, fpSellVol,
         pocImb, fpPocUp, fpPocDn))

if isStrongMove and close < open
    // Supply zone: displacement candle is bearish → expect negative delta
    bool pocImb = showImbalance ? fpPocSelImb : false
    pendingZones.push(PendingZone.new(
         bar_index,
         low + (atr * zoneWidthMult), low,
         false,
         strengthScore, 0,
         fpDelta, fpBuyVol, fpSellVol,
         pocImb, fpPocUp, fpPocDn))

// ─── Process Pending Zones → Confirmed Zones ──────────────────────────────────
if pendingZones.size() > 0
    for i = pendingZones.size() - 1 to 0
        PendingZone p = pendingZones.get(i)
        if bar_index > p.startBar
            p.barsPassed += 1

            // Invalidate if price re-enters the zone before confirmation
            if (p.isDemand and low < p.bottom) or (not p.isDemand and high > p.top)
                pendingZones.remove(i)
                continue

            if p.barsPassed >= confirmationBars
                // ── Delta confirmation logic ──────────────────────────────
                // Demand confirmed when buyers dominated (delta > 0)
                // Supply confirmed when sellers dominated (delta < 0)
                bool deltaOk = na(p.delta) ? true :
                     p.isDemand ? p.delta > 0 : p.delta < 0

                // Build label text
                string deltaStr = na(p.delta) ? "Δ n/a" :
                     (p.delta >= 0 ? "▲ " : "▼ ") + str.format("{0,number,#.##K}", p.delta / 1000)
                string imbalStr = p.pocImbalance ? " ⚡" : ""
                string scoreTxt = str.format("{0,number,#.#}", p.strength) + "  " + deltaStr + imbalStr

                // ── Zone color: dim weak zones (delta disagrees with type) ─
                color baseColor  = p.isDemand ? bullColorInput : bearColorInput
                color zoneColor  = deltaOk ? baseColor : color.new(baseColor, weakAlpha)
                color borderColor = color.new(zoneColor, 50)

                box b = box.new(
                     p.startBar, p.top, bar_index, p.bottom,
                     bgcolor      = zoneColor,
                     border_color = borderColor,
                     text         = scoreTxt,
                     text_size    = size.normal,
                     text_color   = color.new(p.isDemand ? bullColorInput : bearColorInput, 0),
                     text_halign  = text.align_right,
                     text_valign  = p.isDemand ? text.align_bottom : text.align_top)

                int bin = getBin(p.strength)
                if p.isDemand
                    totalDemand.set(bin, totalDemand.get(bin) + 1)
                    demandZones.push(Zone.new(
                         p.startBar, b, p.top, p.bottom, true, false, p.strength,
                         false, false,
                         p.delta, p.buyVol, p.sellVol, deltaOk, p.pocImbalance,
                         p.pocUp, p.pocDn))
                else
                    totalSupply.set(bin, totalSupply.get(bin) + 1)
                    supplyZones.push(Zone.new(
                         p.startBar, b, p.top, p.bottom, false, false, p.strength,
                         false, false,
                         p.delta, p.buyVol, p.sellVol, deltaOk, p.pocImbalance,
                         p.pocUp, p.pocDn))
                pendingZones.remove(i)

// ─── Update Active Zones + Track Statistics ────────────────────────────────────
processActiveZones(array<Zone> zoneArray, bool isDemand) =>
    if zoneArray.size() > 0
        for i = zoneArray.size() - 1 to 0
            Zone z = zoneArray.get(i)
            if not z.isMitigated
                z.boxId.set_right(bar_index)

                // Touch detection
                if not z.wasTouched
                    if (isDemand and low <= z.top) or (not isDemand and high >= z.bottom)
                        z.wasTouched := true

                // Reaction (success) detection
                if z.wasTouched and not z.hasReacted
                    float target = isDemand ? z.top + (atr * reactionMult) : z.bottom - (atr * reactionMult)
                    if (isDemand and high >= target) or (not isDemand and low <= target)
                        z.hasReacted := true
                        int bin = getBin(z.strength)
                        if isDemand
                            winsDemand.set(bin, winsDemand.get(bin) + 1)
                        else
                            winsSupply.set(bin, winsSupply.get(bin) + 1)

                // Mitigation (failure) detection
                if (isDemand and low < z.bottom) or (not isDemand and high > z.top)
                    z.isMitigated := true
                    color mc = isDemand ? bullColorInput : bearColorInput
                    z.boxId.set_bgcolor(color.new(mc, mitigatedAlpha))
                    z.boxId.set_border_color(color.new(mc, 100))

processActiveZones(demandZones, true)
processActiveZones(supplyZones, false)

// ─── Dashboard ────────────────────────────────────────────────────────────────
// Columns: Rating | Dmd Win% | Sup Win% | Total | Δ-Confirmed%
var table statsTable = table.new(
     position.top_right, 5, 6,
     bgcolor      = color.new(chart.bg_color, 10),
     border_width = 1,
     border_color = color.new(chart.fg_color, 50))

if showDashboard and barstate.islast
    // Header row
    table.cell(statsTable, 0, 0, "Rating",   text_color = chart.fg_color, bgcolor = color.new(chart.fg_color, 80))
    table.cell(statsTable, 1, 0, "Dmd Win%", text_color = chart.fg_color, bgcolor = color.new(chart.fg_color, 80))
    table.cell(statsTable, 2, 0, "Sup Win%", text_color = chart.fg_color, bgcolor = color.new(chart.fg_color, 80))
    table.cell(statsTable, 3, 0, "Total",    text_color = chart.fg_color, bgcolor = color.new(chart.fg_color, 80))
    table.cell(statsTable, 4, 0, "Δ Conf%",  text_color = chart.fg_color, bgcolor = color.new(chart.fg_color, 80),
         tooltip = "% of zones in this strength bin whose footprint delta agreed with the zone direction")

    string[] labels = array.from("0-2", "2-4", "4-6", "6-8", "8+")

    // Count delta-confirmed zones per bin by iterating stored zones
    int[] dConfirmed = array.new_int(5, 0)
    int[] sConfirmed = array.new_int(5, 0)
    for z in demandZones
        if z.deltaConfirmed
            int b = getBin(z.strength)
            dConfirmed.set(b, dConfirmed.get(b) + 1)
    for z in supplyZones
        if z.deltaConfirmed
            int b = getBin(z.strength)
            sConfirmed.set(b, sConfirmed.get(b) + 1)

    for i = 0 to 4
        int   dTot  = totalDemand.get(i)
        int   sTot  = totalSupply.get(i)
        float dWin  = dTot > 0 ? (winsDemand.get(i) / dTot) * 100 : 0.0
        float sWin  = sTot > 0 ? (winsSupply.get(i) / sTot) * 100 : 0.0

        // Delta confirmation rate (demand + supply combined for that bin)
        int   totBin    = dTot + sTot
        int   confBin   = dConfirmed.get(i) + sConfirmed.get(i)
        float confPct   = totBin > 0 ? (confBin / totBin) * 100 : 0.0

        color dColor    = color.from_gradient(dWin,   0, 100, color.new(#f23645, 50), color.new(#089981, 50))
        color sColor    = color.from_gradient(sWin,   0, 100, color.new(#f23645, 50), color.new(#089981, 50))
        color confColor = color.from_gradient(confPct, 0, 100, color.new(#f23645, 50), color.new(#089981, 50))

        table.cell(statsTable, 0, i + 1, labels.get(i),                          text_color = chart.fg_color)
        table.cell(statsTable, 1, i + 1, str.format("{0,number,#.#}%", dWin),    bgcolor = dColor,    text_color = chart.fg_color)
        table.cell(statsTable, 2, i + 1, str.format("{0,number,#.#}%", sWin),    bgcolor = sColor,    text_color = chart.fg_color)
        table.cell(statsTable, 3, i + 1, str.tostring(totBin),                   text_color = chart.fg_color)
        table.cell(statsTable, 4, i + 1, str.format("{0,number,#.#}%", confPct), bgcolor = confColor, text_color = chart.fg_color)
````
