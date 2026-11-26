# Aurora: Order Flow Liquidity Heatshelves

- url: https://www.tradingview.com/script/A7BJhu8b-Aurora-Order-Flow-Liquidity-Heatshelves/
- type: indicator
- pine_id: PUB;1a078b682f9a430f9d28e572855f71dc
- version: 1.0

## Description

[b]Aurora — Order-Flow Liquidity Heat Shelves [GBB]
[/b]
Aurora reads the volume footprint inside each bar and marks the price levels where order flow actually concentrated. Not at pivots and not at round numbers like we Traders normally like to do manually. It marks the rows where real volume traded, sorted into two honest categories and tracked across their whole life until they break.

Most "liquidity" indicators draw a box wherever volume was high and call it support. Aurora splits that into two things that behave very differently.

[i]Absorption walls[/i] are high volume with balanced delta, printed in the extreme third of the bar. That signature is passive limit orders eating aggression. These are the levels worth calling support and resistance. Demand below, supply above.

[i]Initiative node[/i]s are the rows with the largest one-sided delta. That is aggressor commitment, market orders pushing a direction. It often gets defended, but it is not resting liquidity, so Aurora labels it separately and never pretends it is the same thing. If you only want the genuine walls, turn initiative detection off.

Rows are volume-gated first, then candidates are picked. A row has to clear a fraction of the bar's busiest row before it is even considered.

[b]Levels have a lifecycle, not just a birthday[/b]

Every bar, each active shelf gets one of three verdicts:

[list=1]
[*]Defended. A wick enters the band and the bar closes back on the correct side. Touch count goes up, the level stays.
[*]Broken. Price closes beyond the far edge by a configurable ATR buffer. The buffer kills noise breaks and is gap proof. Closes inside the buffer stay pending, no verdict.
[*]Flipped. A broken wall retested from the other side and rejected is reborn with inverted polarity. Broken demand that starts acting as resistance becomes supply. Once per shelf.
[*]
[/list]

Overlapping same-side, same-type nodes merge instead of stacking. Volume and delta accumulate, the band widens to the union, and the activity clock resets so a level that keeps getting defended outlives the memory window.

[b]Key walls are chosen by strength divided by distance, not distance alone[/b]

A triple-defended level two ATR away can outrank a fresh weak node sitting right next to price. Spotlighted walls on the same side are forced apart by a minimum gap so two adjacent shelves cannot both burn a spotlight on the same zone. Brightness scales with the strength percentile, so the strongest shelf on screen glows hardest and the rest fall off from there.

[b]The cockpit[/b]

Shows the nearest spotlighted supply and demand with live ATR distance, window cumulative delta, current bar delta, and the session POC. The distances re-evaluate every tick, so price running through a wall intrabar just promotes the next one rather than printing a negative number. The break and flip verdicts still wait for the bar to close.

[b]Alerts[/b]

Four classic alertcondition hooks for new wall, defended, broken, and flipped. There is also an optional JSON webhook mode that emits one structured payload per event, built for piping into your own backend.

[b]IMPORANT, PLEASE READ THIS:[/b]

This needs footprint data, which means a TradingView Premium or Ultimate plan. Free and Essential plans cannot access it.

`request.footprint()` reconstructs historical bars from lower timeframe data using tick-rule delta classification. That means historical shelves are approximations. Live shelves, forming in front of you, are the real thing. Treat the history as a decent estimate of where flow clustered, not as tick-exact truth. That means in replay mode Aurora will not show you the truth!

Aurora is a map of where liquidity sat and how it held up. It is not a buy or sell signal and it will not tell you direction. A defended wall can still break on the next bar. Use it for context, for where you expect reactions, and for where your stop is sitting relative to real volume.

[b]Settings[/b]

Footprint Engine

Ticks per footprint row. The price height of each volume node, measured in ticks. Smaller values cut the bar into finer price slices and give you more precise levels, at the cost of more rows to chew through. Bump it up on high-priced or volatile symbols where one tick is tiny.

Value Area %. The share of volume counted as the value area when the footprint is built. Standard is 70. Leave it unless you know why you are changing it.

Shelf memory (bars). How many bars of inactivity a shelf can sit through before it gets dropped. This counts inactivity, not age. Every defense or merge resets the clock, so a level that keeps getting respected can live far longer than this number suggests.

Volume gate. A row has to hold at least this fraction of the bar's busiest row to be considered at all. This runs before any candidate is picked, so it is your first filter against noise. Raise it to keep only the heaviest rows, lower it to catch more.

Max shelves. A hard cap on stored shelves. When you hit it, the weakest broken shelves get evicted first, then the weakest overall. Mostly a performance guard.

[b]Node Detection[/b]

Detect absorption walls: Turns on the genuine walls, the high volume balanced delta rows in a bar's extreme third. If you only trust passive liquidity, this is the one to keep.

Absorption max delta over volume: The strictness dial for what counts as absorption. A row qualifies only if its absolute delta divided by total volume is at or below this. Lower means stricter, demanding more balanced two-sided flow. Raise it if you are getting too few walls and want to loosen the definition.

Detect initiative nodes: Turns on the max delta rows, the aggressor commitment levels. Useful context, but remember these are not resting liquidity. Turn this off if you want a cleaner chart with walls only.

Break buffer (×ATR): How far past a band's far edge price has to close before the level is called broken, in ATR. This kills noise breaks. Closes inside the buffer stay pending with no verdict. Widen it on choppy symbols to stop premature breaks, tighten it if breaks feel too slow to register.

Allow S/R flips: Lets a broken wall that gets retested from the other side and rejected come back with inverted polarity. One flip per shelf. Turn it off if you would rather a broken level just stay dead.

[b]Visuals[/b]

The four color inputs: set absorption demand, absorption supply, initiative buying, and initiative selling. They are kept distinct on purpose so you can read kind and side at a glance.

Key walls per side: How many walls to spotlight above and below price. These are ranked by strength divided by distance, not distance alone.

Min gap between key walls (×ATR): Spotlighted walls on the same side have to sit at least this far apart. Inside a cluster the strongest one wins the slot and the next distinct level gets promoted, so two adjacent shelves cannot both burn a spotlight on the same zone. Set it to 0 to switch this off.

Glow zone height (×ATR): The vertical size of the glow around a key wall. Pure cosmetics, set it to whatever reads well on your chart.

Max core brightness: How bright the strongest shelf's core line gets. Weaker shelves scale down from here by strength percentile, so this is really the top of the brightness range.

Show minor walls: Draws the faint background walls that did not earn a spotlight. Turn it off for a minimal chart with key walls only.

Minor wall thickness (ticks): The drawn height of those faint minor walls. Display only, it does not change detection.

Project forward (bars): How far the walls and labels extend to the right of the current bar. Set to 0 to stop at the live bar.

Hide walls beyond % from price: A render-time filter that hides walls farther than this percent from current price, so the price scale stays near the action. Set to 0 to show everything.

Fade broken walls: Draws broken walls more transparently than active ones. Off draws them at the same weight.

[b]Alerts[/b]

Fire JSON webhook alerts: Emits one structured JSON payload per event, new wall, defended, broken, or flipped, on bar close. This is the one for piping into your own backend. The four classic alertcondition hooks fire regardless of this toggle, so leave it off if you just want plain TradingView alerts.

[b]Dashboard[/b]

Show order-flow cockpit: Toggles the live panel showing nearest supply and demand, window and bar delta, and POC.

Text size:  Sizing for the cockpit text, tiny through large.

## Source Code

````pine
//@version=6
indicator("Aurora: Order Flow Liquidity Heatshelves", "Aurora v2",
     overlay              = true,
     max_boxes_count      = 500,
     max_lines_count      = 50,
     max_labels_count     = 60,
     max_polylines_count  = 5,
     max_bars_back        = 600)


// ─────────────────────────────  INPUTS  ────────────────────────────────────
var string GFP = "▸ Footprint Engine"
ticksPerRow = input.int(25, "Ticks per footprint row", minval = 1, group = GFP,
     tooltip = "Price height of each volume node, in ticks (1 tick = mintick). Smaller = finer levels.")
vaPercent   = input.int(70, "Value Area %", minval = 10, maxval = 100, group = GFP)
lookback    = input.int(180, "Shelf memory (bars)", minval = 20, maxval = 500, group = GFP,
     tooltip = "Bars of INACTIVITY before a shelf is dropped. Defenses and merges reset the clock, so a live level can outlive this window.")
volFrac     = input.float(0.55, "Volume gate", minval = 0.0, maxval = 1.0, step = 0.05, group = GFP,
     tooltip = "A row must hold at least this fraction of the bar's busiest row to be considered at all. Applied BEFORE candidate selection.")
maxShelves  = input.int(250, "Max shelves", minval = 20, maxval = 400, group = GFP,
     tooltip = "Hard cap on stored shelves. Weakest broken shelves are evicted first.")

var string GDT = "▸ Node Detection"
showAbsorb  = input.bool(true, "Detect absorption walls", group = GDT,
     tooltip = "High volume + balanced delta in the bar's extreme third = passive limit orders absorbing aggression. The genuine walls.")
absorbRatio = input.float(0.25, "Absorption max |Δ|/volume", minval = 0.02, maxval = 0.9, step = 0.01, group = GDT,
     tooltip = "A row qualifies as absorption only if |delta| ÷ total volume is at or below this. Lower = stricter (more balanced flow required).")
showInit    = input.bool(true, "Detect initiative nodes", group = GDT,
     tooltip = "Max-|delta| rows = aggressive market orders. Committed inventory, often defended — but NOT resting liquidity. Labelled separately.")
breakBuf    = input.float(0.10, "Break buffer (×ATR)", minval = 0.0, maxval = 1.0, step = 0.05, group = GDT,
     tooltip = "Close must exceed the band's far edge by this many ATRs to count as broken. Kills noise breaks; closes inside the buffer are 'pending'.")
allowFlip   = input.bool(true, "Allow S/R flips", group = GDT,
     tooltip = "A broken wall retested from the other side and rejected is reborn with inverted polarity (broken demand → supply). One flip per shelf.")

var string GVZ = "▸ Visuals"
buyCol      = input.color(color.rgb(0, 235, 175),  "Absorption demand",  group = GVZ)
sellCol     = input.color(color.rgb(230, 40, 150), "Absorption supply",  group = GVZ)
iBuyCol     = input.color(color.rgb(80, 170, 255), "Initiative buying",  group = GVZ)
iSellCol    = input.color(color.rgb(255, 150, 40), "Initiative selling", group = GVZ)
keyPerSide  = input.int(2, "Key walls per side", minval = 1, maxval = 5, group = GVZ,
     tooltip = "How many walls to spotlight above and below price. Ranked by strength ÷ distance, not distance alone.")
minGapATR   = input.float(0.6, "Min gap between key walls (×ATR)", minval = 0.0, maxval = 3.0, step = 0.1, group = GVZ,
     tooltip = "Spotlighted walls on the same side must be at least this far apart. Within a cluster the strongest wins and the slot promotes the next DISTINCT level — stops two adjacent shelves from burning both spotlights on one zone. 0 = off.")
zoneMult    = input.float(0.75, "Glow zone height (×ATR)", minval = 0.1, maxval = 4.0, step = 0.05, group = GVZ)
glow        = input.int(82, "Max core brightness", minval = 40, maxval = 95, group = GVZ,
     tooltip = "Brightness of the strongest shelf's core line. Weaker shelves scale down from here by strength percentile.")
showMinor   = input.bool(true, "Show minor walls (faint)", group = GVZ)
minTicks    = input.int(30, "Minor wall thickness (ticks)", minval = 1, maxval = 300, group = GVZ)
extendFwd   = input.int(8, "Project forward (bars)", minval = 0, maxval = 50, group = GVZ)
maxDistPct  = input.float(3.0, "Hide walls beyond % from price", minval = 0.0, maxval = 50.0, step = 0.5, group = GVZ,
     tooltip = "Walls farther than this % from current price are hidden at render time. 0 = show all.")
fadeBroken  = input.bool(true, "Fade broken walls", group = GVZ)

var string GAL = "▸ Alerts"
useJson     = input.bool(false, "Fire JSON webhook alerts", group = GAL,
     tooltip = "Emits one JSON payload per event (new wall / defended / broken / flipped) on bar close via alert(). Schema documented in the script header. Also exposes four classic alertcondition() hooks.")

var string GDS = "▸ Dashboard"
showDash    = input.bool(true, "Show order-flow cockpit", group = GDS)
dashSize    = input.string(size.normal, "Text size",
     options = [size.tiny, size.small, size.normal, size.large], group = GDS)

// Anchor to the chart's price scale (Aurora plots no series otherwise).
plot(close, "scale anchor", color = color.new(color.gray, 100), editable = false)

// ───────────────────────────  FOOTPRINT CALL  ──────────────────────────────
// Platform rule: a script may contain exactly ONE request.footprint() call.
footprint fp = request.footprint(ticksPerRow, vaPercent)

// Volatility unit (glow height, break buffer, key-wall distance metric).
float atrZone = ta.atr(14)
float atrSafe = na(atrZone) ? 10 * syminfo.mintick : atrZone

// ─────────────────────────────  SHELF STATE  ───────────────────────────────
var array<int>   sOrig  = array.new<int>()    // birth bar (left edge of drawing)
var array<int>   sLast  = array.new<int>()    // last activity bar (prune clock)
var array<float> sTop   = array.new<float>()  // top of the band
var array<float> sBot   = array.new<float>()  // bottom of the band
var array<float> sVol   = array.new<float>()  // accumulated volume
var array<float> sDel   = array.new<float>()  // accumulated delta
var array<bool>  sBuy   = array.new<bool>()   // true = demand side
var array<bool>  sAbs   = array.new<bool>()   // true = absorption, false = initiative
var array<bool>  sBrk   = array.new<bool>()   // broken?
var array<int>   sEnd   = array.new<int>()    // right bar when broken
var array<int>   sTouch = array.new<int>()    // defenses + merges (reinforcement count)
var array<bool>  sFlp   = array.new<bool>()   // already flipped once?

// ─────────────────────  BAR-LEVEL STATE (dashboard)  ───────────────────────
var array<int>   bIdx = array.new<int>()
var array<float> bDel = array.new<float>()
var float lastPoc = na

// ───────────────────────────  HELPERS  ─────────────────────────────────────

// Remove shelf i from every parallel array.
f_remove(int _i) =>
    array.remove(sOrig, _i)
    array.remove(sLast, _i)
    array.remove(sTop, _i)
    array.remove(sBot, _i)
    array.remove(sVol, _i)
    array.remove(sDel, _i)
    array.remove(sBuy, _i)
    array.remove(sAbs, _i)
    array.remove(sBrk, _i)
    array.remove(sEnd, _i)
    array.remove(sTouch, _i)
    array.remove(sFlp, _i)

// Effective strength: accumulated volume reinforced by defenses/merges.
f_strength(int _i) =>
    array.get(sVol, _i) * (1.0 + 0.25 * array.get(sTouch, _i))

// Percentile rank of shelf strength among all ACTIVE shelves (0..1).
f_rank(int _i) =>
    int n = array.size(sOrig)
    float s = f_strength(_i)
    int cnt = 0
    int tot = 0
    if n > 0
        for j = 0 to n - 1
            if not array.get(sBrk, j)
                tot += 1
                if f_strength(j) <= s
                    cnt += 1
    tot > 0 ? cnt / float(tot) : 0.5

// Key-wall score: strength discounted by ATR-distance from price.
// A triple-defended monster 2 ATR away outranks a fresh weak node nearby.
f_score(int _i) =>
    float mid = (array.get(sTop, _i) + array.get(sBot, _i)) / 2.0
    float dAtr = math.abs(mid - close) / atrSafe
    f_strength(_i) / (1.0 + dAtr)

// Render-time distance filter (keeps the price scale near the action).
f_inRange(int _i) =>
    float m = (array.get(sTop, _i) + array.get(sBot, _i)) / 2.0
    maxDistPct <= 0 or math.abs(m - close) / close <= maxDistPct / 100.0

// First ACTIVE same-side, same-kind shelf overlapping this band, or -1.
f_overlapIdx(float _t, float _b, bool _isBuy, bool _isAbs) =>
    int found = -1
    int n = array.size(sOrig)
    if n > 0
        for i = 0 to n - 1
            if found < 0 and not array.get(sBrk, i) and array.get(sBuy, i) == _isBuy and array.get(sAbs, i) == _isAbs
                if _b <= array.get(sTop, i) and _t >= array.get(sBot, i)
                    found := i
    found

// Add a node, or merge it into an overlapping live shelf (reinforcement).
// Returns true when a NEW shelf was created.
f_addOrMerge(float _t, float _b, float _v, float _d, bool _isBuy, bool _isAbs) =>
    int j = f_overlapIdx(_t, _b, _isBuy, _isAbs)
    bool isNew = j < 0
    if isNew
        array.push(sOrig, bar_index)
        array.push(sLast, bar_index)
        array.push(sTop, _t)
        array.push(sBot, _b)
        array.push(sVol, _v)
        array.push(sDel, _d)
        array.push(sBuy, _isBuy)
        array.push(sAbs, _isAbs)
        array.push(sBrk, false)
        array.push(sEnd, bar_index)
        array.push(sTouch, 0)
        array.push(sFlp, false)
    else
        array.set(sVol, j, array.get(sVol, j) + _v)
        array.set(sDel, j, array.get(sDel, j) + _d)
        array.set(sTop, j, math.max(array.get(sTop, j), _t))
        array.set(sBot, j, math.min(array.get(sBot, j), _b))
        array.set(sTouch, j, array.get(sTouch, j) + 1)
        array.set(sLast, j, bar_index)
    isNew

// JSON payload for the Python harness / webhooks. Built by concatenation —
// str.format() applies locale digit grouping, which corrupts JSON numbers.
f_json(string _ev, int _i) =>
    string side = array.get(sBuy, _i) ? "buy" : "sell"
    string kind = array.get(sAbs, _i) ? "absorption" : "initiative"
    string p1 = '{"event":"' + _ev + '","side":"' + side + '","kind":"' + kind + '"'
    string p2 = ',"top":' + str.tostring(array.get(sTop, _i), format.mintick) + ',"bot":' + str.tostring(array.get(sBot, _i), format.mintick)
    string p3 = ',"vol":' + str.tostring(array.get(sVol, _i), "#.##") + ',"delta":' + str.tostring(array.get(sDel, _i), "#.##")
    string p4 = ',"touches":' + str.tostring(array.get(sTouch, _i)) + ',"sym":"' + syminfo.ticker + '","tf":"' + timeframe.period + '","time":' + str.tostring(time) + '}'
    p1 + p2 + p3 + p4

// Vertical gradient glow around a key wall (8 fading layers + bright core).
f_glow(array<box> _store, int _L, int _R, float _mid, color _hue, int _coreTp, float _zoneHalf) =>
    int LAY = 8
    for k = 0 to LAY - 1
        float halfH = _zoneHalf * (LAY - k) / LAY
        int   ltp   = int(math.round(96 - (96 - (_coreTp + 4)) * k / (LAY - 1)))
        array.push(_store, box.new(_L, _mid + halfH, _R, _mid - halfH,
             border_width = 0, bgcolor = color.new(_hue, math.min(99, ltp)), xloc = xloc.bar_index))
    float coreHalf = math.max(syminfo.mintick, _zoneHalf * 0.04)
    array.push(_store, box.new(_L, _mid + coreHalf, _R, _mid - coreHalf,
         border_width = 0, bgcolor = color.new(_hue, _coreTp), xloc = xloc.bar_index))

// Pick the `cnt` highest-SCORING shelves from a candidate pool, enforcing a
// minimum vertical gap between picks so one price zone can't hog every slot.
f_selectKeys(array<int> _pool, int _cnt, float _minGap) =>
    array<int> out = array.new<int>()
    int sz = array.size(_pool)
    array<bool> used = array.new<bool>(sz, false)
    int take = math.min(_cnt, sz)
    if take > 0
        for s = 0 to take - 1
            float best = -1.0
            int   bp   = -1
            for p = 0 to sz - 1
                if not array.get(used, p)
                    int idx = array.get(_pool, p)
                    float m = (array.get(sTop, idx) + array.get(sBot, idx)) / 2.0
                    bool clustered = false
                    if _minGap > 0 and array.size(out) > 0
                        for q in out
                            float mq = (array.get(sTop, q) + array.get(sBot, q)) / 2.0
                            if math.abs(m - mq) < _minGap
                                clustered := true
                    if not clustered
                        float sc = f_score(idx)
                        if sc > best
                            best := sc
                            bp := p
            if bp >= 0
                array.set(used, bp, true)
                array.push(out, array.get(_pool, bp))
    out

// ───────────────────  EVENT FLAGS (for alertcondition)  ────────────────────
bool evtNewWall = false
bool evtDefend  = false
bool evtBreak   = false
bool evtFlip    = false

// ───────────────────────────  CAPTURE (on close)  ──────────────────────────
if barstate.isconfirmed and not na(fp)
    volume_row poc = fp.poc()
    lastPoc := na(poc) ? lastPoc : (poc.up_price() + poc.down_price()) / 2.0
    array.push(bIdx, bar_index)
    array.push(bDel, fp.delta())

    float buf = atrSafe * breakBuf

    // 1) DEFEND / BREAK / FLIP pass over existing shelves
    int sz = array.size(sOrig)
    if sz > 0
        for i = 0 to sz - 1
            float t = array.get(sTop, i)
            float b = array.get(sBot, i)
            bool  touched = low <= t and high >= b
            if not array.get(sBrk, i)
                bool buyShelf = array.get(sBuy, i)
                if buyShelf and close < b - buf
                    array.set(sBrk, i, true)
                    array.set(sEnd, i, bar_index)
                    evtBreak := true
                    if useJson
                        alert(f_json("broken", i), alert.freq_once_per_bar_close)
                else if not buyShelf and close > t + buf
                    array.set(sBrk, i, true)
                    array.set(sEnd, i, bar_index)
                    evtBreak := true
                    if useJson
                        alert(f_json("broken", i), alert.freq_once_per_bar_close)
                else if touched and (buyShelf ? close > t : close < b)
                    // wick pierced the band, close rejected back out → defended
                    array.set(sTouch, i, array.get(sTouch, i) + 1)
                    array.set(sLast, i, bar_index)
                    evtDefend := true
                    if useJson
                        alert(f_json("defended", i), alert.freq_once_per_bar_close)
                // close INSIDE band or inside buffer → pending, no verdict
            else if allowFlip and not array.get(sFlp, i)
                // FLIP: broken shelf retested from the far side and rejected.
                // Broken demand (price below): wick up into band, close back
                // below → band acted as resistance → reborn as supply.
                bool buyShelf = array.get(sBuy, i)
                if buyShelf and touched and close < b
                    array.set(sBuy, i, false)
                    array.set(sBrk, i, false)
                    array.set(sFlp, i, true)
                    array.set(sTouch, i, 1)
                    array.set(sDel, i, 0.0)
                    array.set(sOrig, i, bar_index)
                    array.set(sLast, i, bar_index)
                    evtFlip := true
                    if useJson
                        alert(f_json("flipped", i), alert.freq_once_per_bar_close)
                else if not buyShelf and touched and close > t
                    array.set(sBuy, i, true)
                    array.set(sBrk, i, false)
                    array.set(sFlp, i, true)
                    array.set(sTouch, i, 1)
                    array.set(sDel, i, 0.0)
                    array.set(sOrig, i, bar_index)
                    array.set(sLast, i, bar_index)
                    evtFlip := true
                    if useJson
                        alert(f_json("flipped", i), alert.freq_once_per_bar_close)

    // 2) NODE DETECTION — volume-gate FIRST, then pick candidates
    array<volume_row> rows = fp.rows()
    int rn = array.size(rows)
    if rn > 0
        float bMax = 0.0
        for r in rows
            bMax := math.max(bMax, r.total_volume())
        float volGate = bMax * volFrac
        float third   = (high - low) / 3.0

        // best absorption candidate per side (by volume, in the extreme third)
        float bestAbsB = 0.0
        float bestAbsS = 0.0
        volume_row absB = na
        volume_row absS = na
        // best initiative candidate per side (by |delta|)
        float bestIniB = 0.0
        float bestIniS = 0.0
        volume_row iniB = na
        volume_row iniS = na

        for r in rows
            float tv = r.total_volume()
            if tv >= volGate
                float dd    = r.delta()
                float mid   = (r.up_price() + r.down_price()) / 2.0
                float ratio = math.abs(dd) / math.max(tv, 1e-10)
                if ratio <= absorbRatio
                    // balanced flow at an extreme = passive absorption
                    if mid <= low + third and tv > bestAbsB
                        bestAbsB := tv
                        absB := r
                    else if mid >= high - third and tv > bestAbsS
                        bestAbsS := tv
                        absS := r
                else
                    // one-sided flow = initiative
                    if dd > 0 and dd > bestIniB
                        bestIniB := dd
                        iniB := r
                    else if dd < 0 and -dd > bestIniS
                        bestIniS := -dd
                        iniS := r

        if showAbsorb and not na(absB)
            if f_addOrMerge(absB.up_price(), absB.down_price(), absB.total_volume(), absB.delta(), true, true)
                evtNewWall := true
                if useJson
                    alert(f_json("new_wall", array.size(sOrig) - 1), alert.freq_once_per_bar_close)
        if showAbsorb and not na(absS)
            if f_addOrMerge(absS.up_price(), absS.down_price(), absS.total_volume(), absS.delta(), false, true)
                evtNewWall := true
                if useJson
                    alert(f_json("new_wall", array.size(sOrig) - 1), alert.freq_once_per_bar_close)
        if showInit and not na(iniB)
            if f_addOrMerge(iniB.up_price(), iniB.down_price(), iniB.total_volume(), iniB.delta(), true, false)
                evtNewWall := true
                if useJson
                    alert(f_json("new_wall", array.size(sOrig) - 1), alert.freq_once_per_bar_close)
        if showInit and not na(iniS)
            if f_addOrMerge(iniS.up_price(), iniS.down_price(), iniS.total_volume(), iniS.delta(), false, false)
                evtNewWall := true
                if useJson
                    alert(f_json("new_wall", array.size(sOrig) - 1), alert.freq_once_per_bar_close)

    // 3) PRUNE by INACTIVITY (sLast, not birth — defended levels stay alive).
    //    sLast refreshes out of order, so scan instead of front-shifting.
    int cut = bar_index - lookback
    int pi = array.size(sOrig) - 1
    while pi >= 0
        if array.get(sLast, pi) < cut
            f_remove(pi)
        pi -= 1

    // 4) HARD CAP — evict weakest broken first, then weakest overall.
    while array.size(sOrig) > maxShelves
        int   victim  = -1
        float weakest = 1e18
        int   nn      = array.size(sOrig)
        for i = 0 to nn - 1
            if array.get(sBrk, i) and f_strength(i) < weakest
                weakest := f_strength(i)
                victim := i
        if victim < 0
            for i = 0 to nn - 1
                if f_strength(i) < weakest
                    weakest := f_strength(i)
                    victim := i
        f_remove(victim)

    // trim dashboard history
    while array.size(bIdx) > lookback
        array.shift(bIdx)
        array.shift(bDel)

// classic alert hooks (static messages; use JSON alerts for payloads)
alertcondition(evtNewWall, "Aurora: new wall",      "Aurora — new liquidity shelf formed")
alertcondition(evtDefend,  "Aurora: wall defended", "Aurora — shelf defended (wick rejection)")
alertcondition(evtBreak,   "Aurora: wall broken",   "Aurora — shelf broken (close beyond buffer)")
alertcondition(evtFlip,    "Aurora: wall flipped",  "Aurora — broken shelf flipped polarity (S/R flip)")

// ─────────────────────────────  RENDER  ────────────────────────────────────
var array<box>   minorBoxes = array.new<box>()
var array<box>   keyBoxes   = array.new<box>()
var array<label> tags       = array.new<label>()
var array<float> keySupMids = array.new<float>()   // spotlighted supply mids
var array<float> keyDemMids = array.new<float>()   // spotlighted demand mids

// Full redraw only when a bar confirms (or history ends). Realtime ticks
// take the light path below — no 500-box delete/recreate per tick.
bool fullRedraw = (barstate.islast and barstate.isconfirmed) or barstate.islastconfirmedhistory

if fullRedraw
    for bx in minorBoxes
        box.delete(bx)
    array.clear(minorBoxes)
    for bx in keyBoxes
        box.delete(bx)
    array.clear(keyBoxes)
    for lb in tags
        label.delete(lb)
    array.clear(tags)
    array.clear(keySupMids)
    array.clear(keyDemMids)

    int n = array.size(sOrig)
    if n > 0
        float zoneHalf = atrSafe * zoneMult / 2.0
        int   tpBright = 100 - glow      // strongest shelf's core transparency
        int   tpDim    = 55              // weakest shelf's core transparency

        // candidate pools: active, in-range, split by side of price
        array<int> supPool = array.new<int>()
        array<int> demPool = array.new<int>()
        for i = 0 to n - 1
            if not array.get(sBrk, i) and f_inRange(i)
                float m = (array.get(sTop, i) + array.get(sBot, i)) / 2.0
                if array.get(sBuy, i) and m < close
                    array.push(demPool, i)
                else if not array.get(sBuy, i) and m > close
                    array.push(supPool, i)

        // key walls = top score (strength ÷ distance) per side, de-clustered
        array<int> supKeys = f_selectKeys(supPool, keyPerSide, minGapATR * atrSafe)
        array<int> demKeys = f_selectKeys(demPool, keyPerSide, minGapATR * atrSafe)

        // stash the spotlighted mids — the cockpit re-evaluates these LIVE
        // every tick, so an intrabar run-over wall can never print a
        // negative distance (the wall's break/defend verdict still waits
        // for bar close)
        for p in supKeys
            array.push(keySupMids, (array.get(sTop, p) + array.get(sBot, p)) / 2.0)
        for p in demKeys
            array.push(keyDemMids, (array.get(sTop, p) + array.get(sBot, p)) / 2.0)
        array<int> keys = array.new<int>()
        for k in supKeys
            array.push(keys, k)
        for k in demKeys
            array.push(keys, k)

        // drawing budget: 9 boxes per key glow, minors get the remainder
        int glowReserve = array.size(keys) * 9
        int minorBudget = 500 - glowReserve - 4
        int minorsDrawn = 0

        // — KEY WALLS —
        for i in keys
            int   L   = math.max(array.get(sOrig, i), bar_index - 590)
            int   R   = bar_index + extendFwd
            float mid = (array.get(sTop, i) + array.get(sBot, i)) / 2.0
            bool  buy = array.get(sBuy, i)
            bool  abs_ = array.get(sAbs, i)
            color hue = abs_ ? (buy ? buyCol : sellCol) : (buy ? iBuyCol : iSellCol)

            // brightness by strength percentile
            float rk     = f_rank(i)
            int   coreTp = int(math.round(tpDim - (tpDim - tpBright) * rk))
            f_glow(keyBoxes, L, R, mid, hue, coreTp, zoneHalf)

            float d   = array.get(sDel, i)
            string sgn = d >= 0 ? "+" : "−"
            bool   flp = array.get(sFlp, i)
            string kindTxt = abs_ ? (buy ? "DEMAND " : "SUPPLY ") : (buy ? "INIT ▲ " : "INIT ▼ ")
            // flipped walls had their delta zeroed (it belonged to the old
            // polarity), so the Δ term is meaningless noise — show the flip
            // marker instead.
            string dTxt = flp ? "" : "  Δ" + sgn + str.tostring(int(math.round(math.abs(d))))
            string lab = kindTxt + str.tostring(mid, format.mintick) + dTxt +
                 (array.get(sTouch, i) > 0 ? "  ×" + str.tostring(array.get(sTouch, i)) : "") +
                 (flp ? "  ⟲FLIP" : "")
            array.push(tags, label.new(R, mid, lab,
                 xloc = xloc.bar_index, yloc = yloc.price,
                 style = label.style_label_left, color = color.new(hue, 8),
                 textcolor = color.white, size = size.small))

        // — MINOR WALLS — actives first, then brokens; newest first; budgeted
        if showMinor
            float mh = math.max(syminfo.mintick, minTicks * syminfo.mintick / 2.0)
            // pass 1: active minors
            for i = n - 1 to 0
                if minorsDrawn < minorBudget and not array.get(sBrk, i) and not array.includes(keys, i) and f_inRange(i)
                    int   L   = math.max(array.get(sOrig, i), bar_index - 590)
                    int   R   = bar_index + extendFwd
                    float mid = (array.get(sTop, i) + array.get(sBot, i)) / 2.0
                    bool  buy = array.get(sBuy, i)
                    color hue = array.get(sAbs, i) ? (buy ? buyCol : sellCol) : (buy ? iBuyCol : iSellCol)
                    array.push(minorBoxes, box.new(L, mid + mh, R, mid - mh,
                         border_width = 0, bgcolor = color.new(hue, 84), xloc = xloc.bar_index))
                    minorsDrawn += 1
            // pass 2: broken minors (faded) with whatever budget remains
            for i = n - 1 to 0
                if minorsDrawn < minorBudget and array.get(sBrk, i) and f_inRange(i)
                    int   L   = math.max(array.get(sOrig, i), bar_index - 590)
                    int   R   = array.get(sEnd, i)
                    float mid = (array.get(sTop, i) + array.get(sBot, i)) / 2.0
                    bool  buy = array.get(sBuy, i)
                    color hue = array.get(sAbs, i) ? (buy ? buyCol : sellCol) : (buy ? iBuyCol : iSellCol)
                    array.push(minorBoxes, box.new(L, mid + mh, R, mid - mh,
                         border_width = 0, bgcolor = color.new(hue, fadeBroken ? 92 : 84), xloc = xloc.bar_index))
                    minorsDrawn += 1

// LIGHT PATH — realtime ticks: just slide right edges, no delete/recreate.
else if barstate.islast
    for bx in keyBoxes
        box.set_right(bx, bar_index + extendFwd)
    for lb in tags
        label.set_x(lb, bar_index + extendFwd)

// ────────────────────────────  DASHBOARD  ──────────────────────────────────
var table dash = table.new(position.top_right, 2, 6,
     bgcolor = color.new(color.black, 12), frame_color = color.new(color.gray, 50),
     frame_width = 1, border_color = color.new(color.gray, 70), border_width = 1)

if showDash and barstate.islast
    // live nearest spotlighted wall per side — only walls still on the
    // correct side of the CURRENT price qualify; price running through a
    // wall intrabar simply promotes the next one until the close verdict
    float liveSup = na
    float liveDem = na
    float bdS = 1e18
    float bdD = 1e18
    for m in keySupMids
        if m > close and m - close < bdS
            bdS := m - close
            liveSup := m
    for m in keyDemMids
        if m < close and close - m < bdD
            bdD := close - m
            liveDem := m

    int   bn     = array.size(bDel)
    float barDel = bn > 0 ? array.get(bDel, bn - 1) : 0.0
    float winCum = 0.0
    if bn > 0
        for i = 0 to bn - 1
            winCum += array.get(bDel, i)
    color bias = winCum >= 0 ? buyCol : sellCol
    color barC = barDel >= 0 ? buyCol : sellCol

    table.cell(dash, 0, 0, "AURORA FLOW", text_color = color.white, text_size = dashSize,
         bgcolor = color.new(color.gray, 80))
    table.cell(dash, 1, 0, winCum >= 0 ? "▲ BUYERS" : "▼ SELLERS",
         text_color = color.white, text_size = dashSize, bgcolor = color.new(bias, 40))

    table.cell(dash, 0, 1, "Supply ↑", text_color = color.silver, text_size = dashSize)
    table.cell(dash, 1, 1, na(liveSup) ? "—" :
         str.tostring(liveSup, format.mintick) + "  (" + str.tostring((liveSup - close) / atrSafe, "#.#") + " ATR)",
         text_color = sellCol, text_size = dashSize)

    table.cell(dash, 0, 2, "Demand ↓", text_color = color.silver, text_size = dashSize)
    table.cell(dash, 1, 2, na(liveDem) ? "—" :
         str.tostring(liveDem, format.mintick) + "  (" + str.tostring((close - liveDem) / atrSafe, "#.#") + " ATR)",
         text_color = buyCol, text_size = dashSize)

    table.cell(dash, 0, 3, "Window ΣΔ", text_color = color.silver, text_size = dashSize)
    table.cell(dash, 1, 3, str.tostring(winCum, format.volume), text_color = bias, text_size = dashSize)

    table.cell(dash, 0, 4, "Bar Δ", text_color = color.silver, text_size = dashSize)
    table.cell(dash, 1, 4, str.tostring(barDel, format.volume), text_color = barC, text_size = dashSize)

    table.cell(dash, 0, 5, "POC", text_color = color.silver, text_size = dashSize)
    table.cell(dash, 1, 5, na(lastPoc) ? "—" : str.tostring(lastPoc, format.mintick),
         text_color = color.white, text_size = dashSize)
````
