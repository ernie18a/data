# Volume Profile Multi-Mode

- url: https://www.tradingview.com/script/xMuJN845-Volume-Profile-Multi-Mode/
- type: indicator
- pine_id: PUB;bed1058fb820432e899f5b1fc3960bf1
- version: 2.0

## Description

DESCRIPTION
VP Multi-Mode builds a volume-by-price profile from REAL traded volume and lets you choose, from one dropdown, what stretch of the chart each profile covers.

WHAT A VOLUME PROFILE IS (skip if you know) A normal chart shows how much volume traded per unit of TIME — the bars along the bottom. A volume profile flips that: it shows how much volume traded at each PRICE. The result is a sideways histogram. Long bars are prices where a lot of business got done; short bars are prices the market passed through quickly. Traders use the fat areas as reference (price tends to revisit and pause there) and the thin areas as places price tends to move through fast.

Three levels come out of it:

POC (Point of Control) — the single price bin with the most volume. The fairest price of that range by traded-volume consensus.
VAH / VAL (Value Area High / Low) — the band around the POC containing a chosen share of the range's volume (70% by default, the Market Profile convention). Inside the value area = accepted price; outside = the market is exploring.
WHAT MAKES THIS ONE DIFFERENT

Real volume, not an approximation. Each chart bar is decomposed into intrabar sub-bars (1-minute by default) via request.security_lower_tf(), and each sub-bar's ACTUAL reported volume is distributed into the price grid. It does not use tick data and it does not use the up/down-tick estimate that the built-in SVP relies on. You can also choose how a sub-bar's volume is spread:

Range/Uniform (default, the honest one) — spread evenly over every bin the sub-bar's low-to-high touched.
Close — dump the whole sub-bar's volume in its closing-price bin.
Five range modes in one script. Most profile tools pick one anchoring scheme. This one lets you switch:

Time Window — any HHMM start/end, wraps past midnight.
Session Open->Close — Asia / London / US, each with editable open and close times. One profile per selected session per day.
External Swing — anchors between an external higher-high (a pivot high above the previous pivot high, i.e. liquidity taken above) and an external lower-low. Strictly point-in-time: a pivot is only used once confirmed.
Manual Drag — two click-to-place time handles, the Pine analog of dragging the built-in SVP's handles.
Weekly + N Days — anchored at the Monday 09:30 ET cash open and running to (that Monday + 7 + N) days. Rolling, so these profiles deliberately overlap.
Optional volume delta, labelled honestly. Turn on Show Volume Delta and each bin is coloured by net buying vs selling, with the profile's total delta printed on the POC label. This is a BAR-CLASSIFIED PROXY: each 1-minute sub-bar's real volume is signed by its own close-vs-open direction. It is NOT true aggressor / bid-ask delta — no tick or order-book data is used, and it cannot tell who lifted the offer from who hit the bid inside a sub-bar. It is stated that way in the tooltip too.

Placement that sits on the price action. The histogram is anchored to the range's right edge and grows LEFT across the candles by default, so it overlays the bars it was built from instead of being parked in the right margin. Anchor edge, direction, width and offset are all inputs. Everything is drawn on bar_index, so it does not drift when you zoom.

HOW TO USE

Quick start: add it to the chart and leave everything alone. You get the US cash session (09:30-16:00 ET) profiled once per day for the last 12 days, POC as a solid red line, VAH/VAL as dashed orange lines, and the value area shaded.

Then adjust in this order:

Pick the range that matches your question (Range Mode group).

"Where is value for today's session?" -> Session Open->Close, US.
"What did the overnight build?" -> Session Open->Close, Asia (or Time Window with your own hours).
"Where did volume sit across this leg up?" -> External Swing.
"Just profile this bit here" -> Manual Drag, then click the two handles on the chart when prompted.
"Where is the week's value, with carry-over into the next few days?" -> Weekly + N Days.
Set resolution and detail (Engine group).

Intrabar resolution: 1 minute is the default and works on most charts. Finer (e.g. 1S) is more faithful but TradingView only serves intrabar data for a limited number of recent bars, so finer settings shorten how far back profiles can be built.
Price bins: 25 default. More bins = finer profile, but see the limit below.
Value Area %: 70 is the convention; lower it to see a tighter core of value.
Timezone: America/New_York by default, since the session presets are ET.
Fit it to your chart (Display group). Profile extension sets how many bars wide the POC bin is drawn; the rest scale to their volume. Profile offset nudges the whole thing left or right. Extend direction flips it between overlaying the candles and sitting in the empty margin.

Optional: turn on Show Volume Delta to colour bins green/red by net direction and read the range's total delta off the POC label — bearing in mind the proxy caveat above.

READING IT

Price accepted inside the value area, POC flat and centred -> balanced/rotational; the edges (VAH/VAL) are the reference for fading.
Price leaving the value area and holding outside -> the market is seeking new value; the old VAH or VAL often becomes the level that has to hold on a retest.
A thin patch in the histogram is a price the market moved through with little business done. Revisits often travel across it quickly.
A POC that migrates day over day in one direction is a trend in where business is being done, not just in price.
The script draws levels and volume. It gives no buy/sell signals and makes no performance claims — it is a context tool.

IMPORTANT LIMIT (please read before reporting a bug)

TradingView caps a script at 500 boxes, 500 lines and 500 labels. Each profile costs roughly (bins + 1) boxes. With the defaults, 25 bins x 12 profiles is about 312 boxes. The script auto-clamps the number of profiles it draws to whichever is smaller: your "Max profiles back" setting, or floor(490 / (bins + 1)).

So: painting every session across all history is not possible in Pine, by any script. You always see the most recent N. If you raise the bin count, the number of visible profiles automatically drops to compensate.

Similarly, intrabar data is only available for a limited number of recent chart bars. Older profiles may thin out or stop — that is a data-availability limit, not a fault in the script.

Open source. Comments in the code explain the engine, the delta proxy, and the object budget.

## Source Code

````pine
//@version=6
// Volume Profile Multi-Mode — real-volume Volume-By-Price with 5 range modes
// ----------------------------------------------------------------------------
// Builds a volume-by-price profile from ACTUAL traded volume, NOT tick data and
// NOT TradingView's SVP up/down-tick approximation. For every chart bar it pulls
// an intrabar resolution (default 1m) of [open, high, low, close, volume] via
// request.security_lower_tf() and distributes each sub-bar's REAL volume into a
// fixed grid of price bins spanning the active range. From that grid it computes
// the POC (max-volume bin), and a Value Area (default 70%) expanded outward from
// the POC to VAH/VAL. The same engine feeds all five range modes.
//
// Volume distribution (input "Volume distribution"):
//   Range/Uniform (default, honest) — each sub-bar's volume is spread UNIFORMLY
//                 across every bin its low->high spans.
//   Close         — all of a sub-bar's volume is dropped in its close-price bin.
//
// Volume Delta (optional, input "Show Volume Delta"):
//   A BAR-CLASSIFIED delta PROXY, NOT true aggressor / bid-ask delta. Each 1m
//   sub-bar's REAL volume is signed by its OWN direction (close>open = buy,
//   close<open = sell, close==open = neutral) and accumulated per bin as
//   buy-sell. No tick data is used. It cannot see who lifted the offer vs hit the
//   bid within a sub-bar — it only classifies the net move of each sub-bar.
//
// FIVE RANGE MODES (dropdown "Profile Range Mode"; only the selected mode's
// sub-inputs apply):
//   1 Time Window       — HHMM start/end (wraps past midnight); 1 profile/day.
//   2 Session Open->Close— Asia / London / US, each with editable open+close;
//                          1 profile per selected session per day.
//   3 External Swing     — anchor between an external higher-high (pivot high >
//                          prior pivot high = took external liquidity) and an
//                          external lower-low (pivot low < prior pivot low).
//                          Point-in-time: pivots only known after confirmation.
//   4 Manual Drag        — two input.time(confirm=true) handles (start/stop); the
//                          Pine analog of dragging TV's SVP handles; 1 profile.
//   5 Weekly + N Days    — anchored at the weekly CASH open (Mon 09:30 ET) and
//                          spanning to (that Monday + 7 + N days) 09:29. Rolling;
//                          profiles OVERLAP in time by design (N-day carryover).
//
// PLACEMENT: by default each profile is anchored to the LEFT edge of its own range
// (the range's first bar) and grows RIGHT across that range's candles. This keeps the
// still-building profile parked at the session's open rather than at bar_index, so it
// never covers the live edge, and it keeps the deliberately-overlapping Weekly mode
// ranges from stacking on top of each other. Anchor edge / direction / extension /
// offset are all inputs (Display group) if you want the profile on the right instead.
// All drawing is on xloc.bar_index so it does not drift off-screen when zoomed.
//
// OBJECT BUDGET (critical Pine constraint):
//   Pine caps max_boxes/lines/labels at 500 each. Each profile draws ~binCount+1
//   boxes, up to 3 lines and 1 label. So bins x profiles must stay under budget:
//   with the defaults 25 bins x 12 profiles = ~312 boxes (< 500). The script
//   auto-clamps the number of drawn profiles to floor(490 / (bins+1)) and to the
//   "Max profiles back" input, whichever is smaller. "Print over EVERY day across
//   ALL history" is IMPOSSIBLE in Pine — the tool shows the most recent N only.
//
// Visual legend:
//   Visual element        ;    Meaning
//   Horizontal bin box     ;   Volume traded in that price bin (width proportional to volume)
//   Highlighted bin (POC)  ;   Point of Control — highest-volume price bin
//   Green / red bin (delta);   Buy- / sell-dominant bin when Show Volume Delta is on
//   Dashed lines (VAH/VAL) ;   Value Area high / low (default 70% of volume)
//   Shaded VA box          ;   Value-area price band
// ----------------------------------------------------------------------------

indicator("VP Multi-Mode", "VPMM", overlay = true,
     max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500,
     max_bars_back = 5000)

// ============================================================
// INPUT GROUPS  (Pine has no real tabs — these prefixes make
// collapsed sections cluster by module in the Settings panel)
// ============================================================
var string GEN = "Engine"
var string GMD = "Range Mode"
var string GT1 = "Mode 1 · Time Window"
var string GT2 = "Mode 2 · Session Open→Close"
var string GT3 = "Mode 3 · External Swing"
var string GT4 = "Mode 4 · Manual Drag"
var string GT5 = "Mode 5 · Weekly + N Days"
var string GDS = "Display"
var string GDE = "Volume Delta"
var string GCL = "Colors"

// ============================================================
// INPUTS — Engine (shared by all modes)
// ============================================================
intrabarRes = input.timeframe("1", "Intrabar resolution", group = GEN,
     tooltip = "Lower timeframe pulled per chart bar for REAL volume. 1 = 1 minute. Finer (e.g. 1S) = more faithful but request.security_lower_tf only returns intrabar data for a limited number of recent chart bars, so finer res shortens how far back the profile can be built.")
binCount    = input.int(25, "Price bins", minval = 2, maxval = 200, group = GEN,
     tooltip = "Number of horizontal price bins spanning the range hi->lo. More bins = finer profile but larger object budget (bins x profiles must stay < ~490 boxes).")
distMode    = input.string("Range/Uniform", "Volume distribution", options = ["Range/Uniform", "Close"], group = GEN,
     tooltip = "Range/Uniform (default, honest): spread each sub-bar's volume uniformly across every bin its low->high spans. Close: dump all of a sub-bar's volume in its close-price bin.")
vaPct       = input.float(70, "Value Area %", minval = 1, maxval = 99, step = 1, group = GEN,
     tooltip = "Percent of total volume that defines the Value Area, expanded outward from the POC. 70% is the CBOT/Market-Profile convention.")
tzInput     = input.string("America/New_York", "Timezone", group = GEN,
     tooltip = "IANA timezone for all time-of-day / session / weekly logic. MNQ trades on ET.")
maxProfiles = input.int(12, "Max profiles back", minval = 1, maxval = 60, group = GEN,
     tooltip = "How many recent profile instances to keep drawn. Auto-clamped down if bins x this would blow the 500-box budget. Pine CANNOT draw every day over all history.")

// ============================================================
// INPUTS — Range Mode selector
// ============================================================
rangeMode = input.string("Session Open→Close", "Profile Range Mode",
     options = ["Time Window", "Session Open→Close", "External Swing", "Manual Drag", "Weekly + N Days"], group = GMD,
     tooltip = "Selects which range definition builds the profiles. Only the matching mode's sub-inputs below apply.")

// ── Mode 1 · Time Window ─────────────────────────────────────
winStart = input.int(0,    "Window start (HHMM)", minval = 0, maxval = 2359, group = GT1,
     tooltip = "e.g. 0 = 00:00. If start > end the window WRAPS past midnight (e.g. 0930 start / 0929 end = a near-24h window).")
winEnd   = input.int(1159, "Window end (HHMM)",   minval = 0, maxval = 2359, group = GT1)

// ── Mode 2 · Session Open→Close ──────────────────────────────
sessSel  = input.string("US", "Session", options = ["Asia", "London", "US"], group = GT2,
     tooltip = "Which session to profile (one profile per selected session per day). Open/close times below are editable ET defaults.")
asiaOpen  = input.int(1800, "Asia open (HHMM)",   minval = 0, maxval = 2359, group = GT2)
asiaClose = input.int(300,  "Asia close (HHMM)",  minval = 0, maxval = 2359, group = GT2)
lonOpen   = input.int(300,  "London open (HHMM)", minval = 0, maxval = 2359, group = GT2)
lonClose  = input.int(930,  "London close (HHMM)",minval = 0, maxval = 2359, group = GT2)
usOpen    = input.int(930,  "US open (HHMM)",     minval = 0, maxval = 2359, group = GT2)
usClose   = input.int(1600, "US close (HHMM)",    minval = 0, maxval = 2359, group = GT2)

// ── Mode 3 · External Swing ──────────────────────────────────
pivLen   = input.int(10, "Pivot lookback", minval = 2, maxval = 100, group = GT3,
     tooltip = "Bars on each side for pivot high/low. A pivot is only CONFIRMED this many bars after it prints (point-in-time), so the profile begins accumulating at confirmation.")
swingDir = input.string("Ext-HH → Ext-LL", "Anchor direction", options = ["Ext-HH → Ext-LL", "Ext-LL → Ext-HH"], group = GT3,
     tooltip = "Ext-HH -> Ext-LL: open the range on an external higher-high, close it on the next external lower-low. Ext-LL -> Ext-HH: the reverse.")

// ── Mode 4 · Manual Drag ─────────────────────────────────────
dragStart = input.time(timestamp("2024-01-01 00:00"), "Range start (drag)", confirm = true, group = GT4,
     tooltip = "Click to place the LEFT edge of the range on the chart (Pine's analog of dragging an SVP handle).")
dragStop  = input.time(timestamp("2024-12-31 00:00"), "Range stop (drag)",  confirm = true, group = GT4,
     tooltip = "Click to place the RIGHT edge of the range on the chart.")

// ── Mode 5 · Weekly + N Days ─────────────────────────────────
extraDays = input.int(2, "Extra days after week (N)", minval = 0, maxval = 14, group = GT5,
     tooltip = "Range spans Monday 09:30 ET cash open to (that Monday + 7 + N days) 09:29. N=2 => Mon 09:30 to the following Wednesday 09:29. Weekly profiles overlap by design.")

// ============================================================
// INPUTS — Display / placement
// ============================================================
profExt    = input.int(50, "Profile extension (bars)", minval = 5, maxval = 300, group = GDS,
     tooltip = "How many bars the POC (widest) bin spans; other bins scale to their volume. Raise this to make the profile reach farther across the candles.")
profOffset = input.int(0, "Profile offset (bars)", minval = -300, maxval = 300, group = GDS,
     tooltip = "Shift the whole profile left (-) or right (+) in bars from its anchor. Use +N to nudge it into the right margin, -N to pull it deeper into the session.")
anchorMode = input.string("Range left edge", "Profile anchor", options = ["Range left edge", "Range right edge"], group = GDS,
     tooltip = "Which edge of the range the histogram's axis sits on. Left edge (default) parks each profile at the START of its own range, so the building profile never covers the live edge and overlapping ranges (Weekly mode) do not stack on top of each other. Right edge anchors to the range's close instead — with several profiles on screen this can pile them up.")
growDir    = input.string("Grow right", "Extend direction", options = ["Grow right", "Grow left"], group = GDS,
     tooltip = "Which way the bins extend from the anchor. Grow right (default) pairs with the left-edge anchor to draw each profile left-to-right across its own range.")
showHist   = input.bool(true, "Show histogram bins", group = GDS)
showPOC    = input.bool(true, "Show POC",            group = GDS)
showVA     = input.bool(true, "Show VAH/VAL",        group = GDS)
showVAFill = input.bool(true, "Value-area fill",     group = GDS)
showActive = input.bool(true, "Preview building (active) profile", group = GDS,
     tooltip = "Rebuild and draw the currently-accumulating profile on the last bar so you can watch it form in real time.")

// ============================================================
// INPUTS — Volume Delta (no-tick, bar-classified proxy)
// ============================================================
showDelta   = input.bool(false, "Show Volume Delta", group = GDE,
     tooltip = "Color each bin by net delta (buy-sell) and show the profile's TOTAL net delta in the POC label. BAR-CLASSIFIED PROXY: each 1m sub-bar's real volume is signed by its own close-vs-open direction. NOT true aggressor / bid-ask delta and uses NO tick data.")
deltaBuyCol  = input.color(color.new(#26a69a, 25), "Delta buy-dominant bin",  group = GDE)
deltaSellCol = input.color(color.new(#ef5350, 25), "Delta sell-dominant bin", group = GDE)

// ============================================================
// INPUTS — Colors
// ============================================================
histCol   = input.color(color.new(#2962ff, 70), "Histogram bin", group = GCL)
pocCol    = input.color(#ff5252,                 "POC",          group = GCL)
vaCol     = input.color(#ffb74d,                 "VAH / VAL",    group = GCL)
vaFillCol = input.color(color.new(#2962ff, 90),  "Value-area fill", group = GCL)

// ============================================================
// PROFILE TYPE + STATE
// ============================================================
// A Profile owns its raw sub-bar accumulation arrays (while active), the finished
// bin volumes + per-bin net delta, the derived POC/VAH/VAL, and every drawing
// object it created.
type Profile
    bool  active   = false
    float hi       = na
    float lo       = na
    int   sBar     = na
    int   eBar     = na
    int   eTime    = na
    array<float> rLo  = na
    array<float> rHi  = na
    array<float> rCl  = na
    array<float> rVol = na
    array<float> rDel = na
    array<float> bins = na
    array<float> dBins = na
    float poc = na
    float vah = na
    float val = na
    float totDelta = na
    array<box> boxes = na
    line  pocLn = na
    line  vahLn = na
    line  valLn = na
    box   vaBx  = na
    label lbl   = na

// ── State ─────────────────────────────────────────────────────
var array<Profile> profs = array.new<Profile>()

// ============================================================
// HELPERS
// ============================================================
// True when HHMM `cur` is inside [st, en); if st > en the window wraps midnight.
f_inWin(int cur, int st, int en) =>
    st <= en ? (cur >= st and cur < en) : (cur >= st or cur < en)

// Create a fresh active profile anchored at the current bar.
f_newProfile(int b, int et) =>
    Profile p = Profile.new()
    p.active := true
    p.sBar   := b
    p.eTime  := et
    p.rLo    := array.new<float>()
    p.rHi    := array.new<float>()
    p.rCl    := array.new<float>()
    p.rVol   := array.new<float>()
    p.rDel   := array.new<float>()
    p.boxes  := array.new<box>()
    p

// Append the current chart bar's intrabar sub-bars into profile `p`, grow its
// running hi/lo, and store each sub-bar's REAL volume + its bar-classified signed
// delta. (array.push on an object's field arrays is allowed inside a fn.)
// DELTA IS A NO-TICK PROXY: sign = close>open ? +vol : close<open ? -vol : 0.
f_accum(Profile p, array<float> aOpen, array<float> aLo, array<float> aHi, array<float> aCl, array<float> aVol) =>
    n = array.size(aVol)
    if n > 0
        for i = 0 to n - 1
            v = array.get(aVol, i)
            if not na(v) and v > 0
                sop = array.get(aOpen, i)
                slo = array.get(aLo, i)
                shi = array.get(aHi, i)
                scl = array.get(aCl, i)
                if not na(slo) and not na(shi)
                    d = na(sop) or na(scl) ? 0.0 : scl > sop ? v : scl < sop ? -v : 0.0
                    array.push(p.rLo, slo)
                    array.push(p.rHi, shi)
                    array.push(p.rCl, scl)
                    array.push(p.rVol, v)
                    array.push(p.rDel, d)
                    p.hi := na(p.hi) ? shi : math.max(p.hi, shi)
                    p.lo := na(p.lo) ? slo : math.min(p.lo, slo)
    0

// Build the fixed bin grid (volume + net delta) from the raw sub-bars using the
// chosen distribution.
f_buildBins(Profile p, int nBins, string dm) =>
    if not na(p.hi) and not na(p.lo) and p.hi > p.lo
        p.bins  := array.new<float>(nBins, 0.0)
        p.dBins := array.new<float>(nBins, 0.0)
        bw  = (p.hi - p.lo) / nBins
        cnt = array.size(p.rVol)
        if cnt > 0
            for i = 0 to cnt - 1
                v = array.get(p.rVol, i)
                d = array.get(p.rDel, i)
                if dm == "Close"
                    cl  = array.get(p.rCl, i)
                    idx = math.max(0, math.min(nBins - 1, int(math.floor((cl - p.lo) / bw))))
                    array.set(p.bins,  idx, array.get(p.bins,  idx) + v)
                    array.set(p.dBins, idx, array.get(p.dBins, idx) + d)
                else
                    slo  = array.get(p.rLo, i)
                    shi  = array.get(p.rHi, i)
                    iLo  = math.max(0, math.min(nBins - 1, int(math.floor((slo - p.lo) / bw))))
                    iHi  = math.max(0, math.min(nBins - 1, int(math.floor((shi - p.lo) / bw))))
                    span = iHi - iLo + 1
                    share  = v / span
                    dshare = d / span
                    for j = iLo to iHi
                        array.set(p.bins,  j, array.get(p.bins,  j) + share)
                        array.set(p.dBins, j, array.get(p.dBins, j) + dshare)
        p.totDelta := array.sum(p.dBins)
    0

// Derive POC + Value Area (expand outward from POC to vaP% of total volume).
// Pine has no break/continue, so expansion uses a `done` guard.
f_valueArea(Profile p, int nBins, float vaP) =>
    if not na(p.bins) and array.size(p.bins) == nBins and not na(p.hi) and p.hi > p.lo
        bw  = (p.hi - p.lo) / nBins
        tot = array.sum(p.bins)
        pocIdx = 0
        maxv   = -1.0
        for i = 0 to nBins - 1
            bv = array.get(p.bins, i)
            if bv > maxv
                maxv   := bv
                pocIdx := i
        p.poc := p.lo + (pocIdx + 0.5) * bw
        target = tot * vaP / 100.0
        acc  = array.get(p.bins, pocIdx)
        loI  = pocIdx
        hiI  = pocIdx
        done = false
        for _i = 0 to nBins - 1
            if not done
                if acc >= target
                    done := true
                else
                    below = loI > 0          ? array.get(p.bins, loI - 1) : -1.0
                    above = hiI < nBins - 1  ? array.get(p.bins, hiI + 1) : -1.0
                    if below < 0 and above < 0
                        done := true
                    else if above >= below
                        hiI := hiI + 1
                        acc := acc + above
                    else
                        loI := loI - 1
                        acc := acc + below
        p.val := p.lo + loI * bw
        p.vah := p.lo + (hiI + 1) * bw
    0

// Delete every drawing object the profile owns (called before a redraw or prune).
f_clearDraw(Profile p) =>
    if not na(p.boxes)
        sz = array.size(p.boxes)
        if sz > 0
            for i = 0 to sz - 1
                box.delete(array.get(p.boxes, i))
        array.clear(p.boxes)
    if not na(p.pocLn)
        line.delete(p.pocLn)
        p.pocLn := na
    if not na(p.vahLn)
        line.delete(p.vahLn)
        p.vahLn := na
    if not na(p.valLn)
        line.delete(p.valLn)
        p.valLn := na
    if not na(p.vaBx)
        box.delete(p.vaBx)
        p.vaBx := na
    if not na(p.lbl)
        label.delete(p.lbl)
        p.lbl := na
    0

// Draw the profile as horizontal boxes (POC highlighted, or delta-signed when
// Show Volume Delta is on) + POC/VAH/VAL + VA fill. Boxes/lines are used (NOT
// plots) because hidden plots still count to the 64-plot cap; boxes/lines respect
// the max_boxes/lines_count header limits instead.
// PLACEMENT: axis sits on the chosen range edge (+offset); bins grow left into the
// session (default) or right into the margin. All on xloc.bar_index so it will not
// drift off-screen when zoomed.
f_render(Profile p, int nBins) =>
    f_clearDraw(p)
    if not na(p.bins) and array.size(p.bins) == nBins and not na(p.hi) and p.hi > p.lo
        bw = (p.hi - p.lo) / nBins
        mx = 0.0
        for i = 0 to nBins - 1
            mx := math.max(mx, array.get(p.bins, i))
        xR = na(p.eBar) ? bar_index : p.eBar
        xL = p.sBar
        ax = (anchorMode == "Range left edge" ? xL : xR) + profOffset
        toRight = growDir == "Grow right"
        footL = toRight ? ax : ax - profExt
        footR = toRight ? ax + profExt : ax
        pocIdx = math.max(0, math.min(nBins - 1, int(math.floor((p.poc - p.lo) / bw))))
        // VA fill first so bins render on top of it
        if showVAFill and not na(p.vah) and not na(p.val)
            p.vaBx := box.new(footL, p.vah, footR, p.val, border_color = na, bgcolor = vaFillCol, xloc = xloc.bar_index)
        if showHist and mx > 0
            for i = 0 to nBins - 1
                bv = array.get(p.bins, i)
                w  = math.max(1, int(math.round(bv / mx * profExt)))
                bBot = p.lo + i * bw
                bTop = p.lo + (i + 1) * bw
                bxL = toRight ? ax : ax - w
                bxR = toRight ? ax + w : ax
                dv  = array.size(p.dBins) == nBins ? array.get(p.dBins, i) : 0.0
                col = showDelta ? (dv > 0 ? deltaBuyCol : dv < 0 ? deltaSellCol : color.new(color.gray, 40)) : (i == pocIdx ? pocCol : histCol)
                brd = i == pocIdx ? pocCol : col
                bx  = box.new(bxL, bTop, bxR, bBot, border_color = brd, bgcolor = col, xloc = xloc.bar_index)
                array.push(p.boxes, bx)
        lblX     = toRight ? footR : footL
        lblStyle = toRight ? label.style_label_left : label.style_label_right
        if showPOC and not na(p.poc)
            p.pocLn := line.new(footL, p.poc, footR, p.poc, color = pocCol, width = 2, xloc = xloc.bar_index)
            pocTxt  = showDelta and not na(p.totDelta) ? "POC   Δ " + str.tostring(p.totDelta, format.volume) : "POC"
            p.lbl   := label.new(lblX, p.poc, pocTxt, style = lblStyle,
                 color = color.new(pocCol, 100), textcolor = pocCol, size = size.tiny, xloc = xloc.bar_index)
        if showVA and not na(p.vah) and not na(p.val)
            p.vahLn := line.new(footL, p.vah, footR, p.vah, color = vaCol, style = line.style_dashed, xloc = xloc.bar_index)
            p.valLn := line.new(footL, p.val, footR, p.val, color = vaCol, style = line.style_dashed, xloc = xloc.bar_index)
    0

// Finalize an active profile: build bins, derive VA, draw once, free raw arrays.
f_finalize(Profile p) =>
    p.active := false
    p.eBar   := bar_index
    f_buildBins(p, binCount, distMode)
    f_valueArea(p, binCount, vaPct)
    f_render(p, binCount)
    array.clear(p.rLo)
    array.clear(p.rHi)
    array.clear(p.rCl)
    array.clear(p.rVol)
    array.clear(p.rDel)
    0

// Finalize every currently-active profile (used by edge-close + single-active modes).
f_finalizeAllActive() =>
    sz = array.size(profs)
    if sz > 0
        for i = 0 to sz - 1
            p = array.get(profs, i)
            if p.active
                f_finalize(p)
    0

// ============================================================
// TIME / MODE SIGNALS  (all evaluated every bar at top scope so
// the [1] history references stay valid)
// ============================================================
hh   = hour(time, tzInput)
mm   = minute(time, tzInput)
dow  = dayofweek(time, tzInput)
hhmm = hh * 100 + mm
tmin = hh * 60 + mm

// Selected session's editable open/close
sessOpen = switch sessSel
    "Asia"   => asiaOpen
    "London" => lonOpen
    =>          usOpen
sessClose = switch sessSel
    "Asia"   => asiaClose
    "London" => lonClose
    =>          usClose

// Window / session / drag "inside" flag for the active mode
inWindow = switch rangeMode
    "Time Window"        => f_inWin(hhmm, winStart, winEnd)
    "Session Open→Close" => f_inWin(hhmm, sessOpen, sessClose)
    "Manual Drag"        => (time >= dragStart and time <= dragStop)
    =>                      false
inWinStart = inWindow and not inWindow[1]
inWinExit  = (not inWindow) and inWindow[1]

// Weekly cash-open edge (Monday 09:30 ET)
monOpenNow = dow == dayofweek.monday and tmin >= 570
monStart   = monOpenNow and not monOpenNow[1]

// External swing pivots (point-in-time: confirmed pivLen bars late)
ph = ta.pivothigh(pivLen, pivLen)
pl = ta.pivotlow(pivLen, pivLen)
var float lastPH = na
var float lastPL = na
extHH = false
extLL = false
if not na(ph)
    extHH  := not na(lastPH) and (ph > lastPH)
    lastPH := ph
if not na(pl)
    extLL  := not na(lastPL) and (pl < lastPL)
    lastPL := pl
swingStart = swingDir == "Ext-HH → Ext-LL" ? extHH : extLL
swingClose = swingDir == "Ext-HH → Ext-LL" ? extLL : extHH

// Consolidated start / close / end-time for the selected mode
startNew = switch rangeMode
    "Time Window"        => inWinStart
    "Session Open→Close" => inWinStart
    "Manual Drag"        => inWinStart
    "External Swing"     => swingStart
    =>                      monStart
closeEdge = switch rangeMode
    "Time Window"        => inWinExit
    "Session Open→Close" => inWinExit
    "Manual Drag"        => inWinExit
    "External Swing"     => swingClose
    =>                      false
int startEndTime = (rangeMode == "Weekly + N Days" and monStart) ? time + (7 + extraDays) * 86400000 - 60000 : na

singleActive = rangeMode != "Weekly + N Days"

// Object budget: ~ (binCount+1) boxes per profile; keep total under ~490.
boxesPer = binCount + 1
effMax   = math.max(1, math.min(maxProfiles, int(math.floor(490.0 / boxesPer))))

// ============================================================
// MAIN — build / accumulate / finalize / prune / preview
// ============================================================
// Pull REAL per-bar intrabar OHLCV (arrays for this chart bar). `open` is included
// so the no-tick delta proxy can sign each sub-bar. Deep indexing of these arrays
// is why the header sets max_bars_back.
[lopen, llo, lhi, lcl, lvol] = request.security_lower_tf(syminfo.tickerid, intrabarRes, [open, low, high, close, volume])

// A. Time-based ends (Mode 5 rolling weekly) — finalize BEFORE this bar is added.
szA = array.size(profs)
if szA > 0
    for i = 0 to szA - 1
        p = array.get(profs, i)
        if p.active and not na(p.eTime) and time >= p.eTime
            f_finalize(p)

// B. Edge close (window / session / drag exit, swing opposite extreme).
if closeEdge
    f_finalizeAllActive()

// C. Start a new profile.
if startNew
    if singleActive
        f_finalizeAllActive()
    array.push(profs, f_newProfile(bar_index, startEndTime))

// D. Accumulate this bar's real volume + signed delta into every active profile.
szD = array.size(profs)
if szD > 0
    for i = 0 to szD - 1
        p = array.get(profs, i)
        if p.active
            f_accum(p, lopen, llo, lhi, lcl, lvol)

// E. Prune to the object budget — delete oldest instances' drawings.
while array.size(profs) > effMax
    Profile old = array.shift(profs)
    f_clearDraw(old)

// F. Live preview: rebuild + draw the active (building) profile on the last bar.
if barstate.islast and showActive
    szF = array.size(profs)
    if szF > 0
        for i = 0 to szF - 1
            p = array.get(profs, i)
            if p.active
                f_buildBins(p, binCount, distMode)
                f_valueArea(p, binCount, vaPct)
                f_render(p, binCount)
````
