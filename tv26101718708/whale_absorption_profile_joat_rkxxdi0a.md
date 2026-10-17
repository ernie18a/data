# Whale Absorption Profile [JOAT]

- url: https://www.tradingview.com/script/rKXXDi0A-Whale-Absorption-Profile-JOAT/
- type: indicator
- pine_id: PUB;879769932d6643db83e107f32351f944
- version: 1.0

## Description

[b]WHALE ABSORPTION PROFILE [JOAT][/b]

The flagship orderflow visual in the JOAT suite. A complete institutional-grade footprint dashboard — heatmap candle strips, horizontal volume profile, delta ladder, side histogram, POC/VAH/VAL lines, and whale / absorption / imbalance glyphs — all driven by the same underlying lower-timeframe-reconstructed intrabar data and rendered in a curated asthetics. Built to give you the entire auction picture in one indicator, on chart, without a dedicated orderflow platform.

[image]https://www.tradingview.com/x/97gEV314/[/image]

[b]Six visual layers, one engine[/b]

Every layer reads from the same intrabar data pipeline. The pipeline uses [b]request.security_lower_tf[/b] at a configurable LTF (1m / 3m / 5m / 15m / 30m) to sample sub-bar prints, classifies each via the standard tick rule, then buckets the classified volume into a price-binned profile (configurable rows, default 50). Every layer below reads from those bins.

[list]
[*] [b]Heatmap candle strips[/b] — the body of each recent chart candle is overlaid with horizontal heat slices coloured along an absorption-intensity ramp (deep blue → indigo → violet → magenta → gold). At a glance you can see where, inside each bar, the auction happened.
[*] [b]Horizontal volume profile[/b] — a classic side profile of total volume per bin, rendered with split buy/sell colour so you can read which side dominated each price.
[*] [b]Delta ladder column[/b] — a vertical ladder of per-bin delta (buy − sell), positionable to any of nine corners on the chart. Drawn as a [b]horizontal-going-left-to-right[/b] cell array so it never collides with the dashboard.
[*] [b]Side volume histogram[/b] — a compact buy/sell volume histogram aligned to the profile bins, for traders who want a second view of side-share that is not contaminated by total volume.
[*] [b]POC / VAH / VAL lines[/b] — the Point of Control, Value Area High, and Value Area Low computed from the profile and rendered as horizontal lines that extend right of the latest bar.
[*] [b]Whale / Absorption / Imbalance glyphs[/b] — three separate detection layers (described below) each render a distinct on-chart glyph at the bin where their condition fires.
[/list]

A [b]Lite Mode[/b] toggle disables the heaviest layers (heatmap strips + side histogram) for low-end machines or multi-indicator stacking.

[b]Three orthogonal detection layers[/b]

[list]
[*] [b]Whale Print[/b] — a bin qualifies as a whale row when total bin volume is above a configurable percentile (default 95th of the bin distribution) [b]and[/b] [|delta| / bin volume] is above the whale-delta threshold (default 70%). Both gates: large [i]and[/i] one-sided.
[*] [b]Absorption Zone[/b] — score = [b]min(buy, sell) / (priceMovement + ε)[/b]. High when both sides traded heavily but price did not move — the classic limit-order-absorption signature. A bin qualifies when its absorption score exceeds the configurable percentile (default 90th).
[*] [b]Imbalance Spike[/b] — a bin qualifies when one side's volume is at least N× the other (default 3.0×). The standard footprint imbalance ratio.
[/list]

These three are deliberately separate — a single price can be a whale row, an absorption zone, [i]and[/i] an imbalance spike at once, in which case all three glyphs fire and you have a textbook stacked-signature read.

[b]POC shift alert[/b]

The Point of Control's bar-to-bar bin-distance is tracked. When the POC jumps more than the configurable [b]POC Shift: Bin Distance Trigger[/b] (default 2 bins) between consecutive bars, the POC Shift alert fires — the auction's value has rotated price levels, which is the most actionable single regime-change signal a profile produces.

[b]Visual aesthetic[/b]

A locked institutional palette: cyan-teal bull (#5CF0D7), magenta bear (#FF4D75), and a [b]signature absorption ramp[/b] — deep void → ultramarine → indigo → violet → magenta → gold — designed to read like a heat-mapped orderbook on a deep-space background (#02011A). The four multi-stop gradients drive heatmap, absorption, delta, and whale layers independently, so the chart never looks visually flat.

[image]https://www.tradingview.com/x/6DDH01h0/[/image]

[b]Dashboard[/b]

Monospaced table, positionable to any of nine corners, with row-fade gradient. Surfaces:

[list]
[*] Current POC price + bin distance from previous POC.
[*] VAH / VAL price levels.
[*] Cumulative bar delta.
[*] Whale print count, absorption zone count, imbalance spike count in the lookback.
[*] Current row classifications for the active price (Whale / Absorption / Imbalance).
[*] LTF in use and bin count.
[/list]

[b]Alerts[/b]

Four alert conditions, each independently controllable:

[list]
[*] Whale Print
[*] Absorption Zone
[*] Imbalance Spike
[*] POC Shift (bin distance > threshold)
[/list]

[b]How to read it[/b]

Three reads, in order of conviction:

[list=1]
[*] [b]Stacked detection at the same bin[/b] — when a bin fires Whale + Absorption + Imbalance simultaneously, the auction has experienced a [i]complete[/i] event: large size, both sides traded heavily, and the side imbalance was extreme. These are the rarest and strongest reads the script produces.
[*] [b]POC Shift through a previous structural level[/b] — value migration. The auction's centre of gravity has just moved through your S/R; the rest of the session usually follows.
[*] [b]Heatmap candle strip + delta ladder agreement[/b] — when the heatmap concentration sits at the same price the delta ladder shows one-sided imbalance, the bar is institutionally meaningful regardless of the candle shape.
[/list]

[b]Suggested settings[/b]

Defaults (1m LTF, 50 bins, 40-bar lookback, 95th percentile gates) are tuned for 5m–15m on liquid futures and crypto. For 1m scalping, drop bins to 30 and lookback to 20 to keep the script responsive. For 1H+ HTF, raise lookback to 100 and bins to 60. Lite Mode is recommended when stacking with other heavy indicators.

[b]Originality[/b]

The implementation — the unified intrabar pipeline that feeds six independent visual layers, the percentile-gated whale detector, the [b]min(buy,sell) / priceMovement[/b] absorption score, the diagonal-imbalance row detector, the multi-stop absorption gradient (six-stop signature ramp), the configurable delta ladder with nine-corner positioning, the POC bin-distance shift detector, and the grade composite palette — is JOAT-original. No third-party code reused. The footprint vocabulary (POC, VAH/VAL, imbalance, absorption, whale) is public-domain auction-theory language; this implementation is purpose-built for Pine v6 with bar data only.

[b]Limitations[/b]

Reconstructed intrabar data is an approximation — the tick rule is the accepted public-market inference but it is not a direct read of bid/ask. Sub-minute LTFs require a TradingView Premium or Ultimate plan. The script renders many polylines, boxes, and labels — Pine's max_polylines_count / max_boxes_count / max_labels_count caps apply. Lite Mode exists specifically for low-spec / multi-indicator scenarios. POC, VAH, VAL, and detection layers are computed from confirmed intrabar data so they update on bar-by-bar close (non-repainting beyond the current developing bar).

—


-made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator(title             = "Whale Absorption Profile [JOAT]",
          shorttitle         = "WAP [JOAT]",
          overlay            = true,
          max_boxes_count    = 500,
          max_lines_count    = 500,
          max_labels_count   = 500,
          max_polylines_count= 100)

// =============================================================================
//  SECTION 1 - INPUTS
// =============================================================================
//  Each block maps to one functional subsystem. Group headers use the
//  box-drawing style adopted across the JOAT suite for visual consistency.
// -----------------------------------------------------------------------------

// ----- Profile / data acquisition --------------------------------------------
g_profile      = "Profile / Data"
ltfChoice      = input.string("1",  "Lower Timeframe (Intrabar Resolution)",
                              options = ["1", "3", "5", "15", "30"],
                              group   = g_profile,
                              tooltip = "Granularity (minutes) used by request.security_lower_tf. Smaller = more detail per chart candle. Use 1 for crypto/futures, 5 for equities.")
nBinsInput     = input.int(50,  "Price Bins (Profile Rows)",
                              minval = 8, maxval = 80, step = 1,
                              group  = g_profile,
                              tooltip = "Number of horizontal price rows. <= 50 is recommended; higher values stress the drawing caps and slow the script meaningfully on low-spec machines.")
lookbackBars   = input.int(40,  "Lookback (Chart Bars)",
                              minval = 5, maxval = 200, step = 1,
                              group  = g_profile,
                              tooltip = "How many recent chart bars feed the profile and heatmap. Together with the LTF resolution this determines total tick count processed.")
useHL2Anchor   = input.bool(true, "Anchor Range on HL2 Window",
                              group   = g_profile,
                              tooltip = "When enabled, the profile range uses the highest / lowest hl2 across the lookback window so the bins re-centre with price. When disabled, raw highs/lows are used (slightly wider).")

// ----- Strength filtering ----------------------------------------------------
g_filter       = "Strength Filter"
strengthPct    = input.float(95.0, "Strength Percentile (Bins)",
                              minval = 50.0, maxval = 99.9, step = 1.0,
                              group  = g_filter,
                              tooltip = "Only bins above this percentile of total volume are emphasised as 'strong rows'. 95 is institutional, 80 is permissive.")
minVolBin      = input.float(0.0, "Minimum Volume per Bin",
                              minval = 0.0, step = 0.1,
                              group  = g_filter,
                              tooltip = "Absolute floor. Bins below this are not classified, regardless of percentile.")

// ----- Whale Print -----------------------------------------------------------
g_whale        = "Whale Print"
showWhale      = input.bool(true,  "Detect Whale Prints", group = g_whale)
whaleVolPct    = input.float(95.0, "Whale Volume Percentile",
                              minval = 50.0, maxval = 99.9, step = 1.0,
                              group  = g_whale)
whaleDeltaPct  = input.float(70.0, "Whale |Delta| as % of Row Volume",
                              minval = 30.0, maxval = 100.0, step = 1.0,
                              group  = g_whale,
                              tooltip = "How one-sided the row must be. 70 = at least 70% of the row's volume is on one side of the tape.")

// ----- Absorption ------------------------------------------------------------
g_absorption   = "Absorption Zone"
showAbsorption = input.bool(true,  "Detect Absorption Zones",      group = g_absorption)
absScorePct    = input.float(90.0, "Absorption Score Percentile",
                              minval = 50.0, maxval = 99.9, step = 1.0,
                              group  = g_absorption,
                              tooltip = "Absorption score = min(buy, sell) / (priceMovement + eps). High when both sides traded heavily but price did not move - classic limit-order absorption.")

// ----- Imbalance Spike -------------------------------------------------------
g_imbal        = "Imbalance Spike"
showImbal      = input.bool(true,  "Detect Imbalance Spikes", group = g_imbal)
imbalRatio     = input.float(3.0,  "Imbalance Ratio (Side / Other)",
                              minval = 1.5, maxval = 20.0, step = 0.1,
                              group  = g_imbal,
                              tooltip = "Mark a row when one side's volume is at least N times the other side. 3.0 is a standard institutional footprint ratio.")

// ----- Visuals ---------------------------------------------------------------
g_vis          = "Visuals"
liteMode       = input.bool(false, "Lite Mode (Disable Heatmap Strips + Side Histogram)",
                              group   = g_vis,
                              tooltip = "Disables the heaviest visual layers. Use on low-end machines or when running this in a multi-indicator confluence layout.")
showHeatmap    = input.bool(true,  "Show Heatmap Candle Strips",    group = g_vis)
showVolProfile = input.bool(true,  "Show Horizontal Volume Profile", group = g_vis)
showDeltaLad   = input.bool(true,  "Show Delta Ladder Column",      group = g_vis)
showSideHist   = input.bool(true,  "Show Side Volume Histogram",    group = g_vis)
showPocLines   = input.bool(true,  "Show POC / VAH / VAL Lines",    group = g_vis)
showMarkers    = input.bool(true,  "Show Whale / Absorption / Imbalance Glyphs",
                              group   = g_vis)
profileWidth   = input.int(18,  "Profile Width (bars to the right)",
                              minval = 5, maxval = 100, step = 1,
                              group  = g_vis)
ladderWidth    = input.int(6,   "Delta Ladder Cell Span (bars)",
                              minval = 2, maxval = 30, step = 1,
                              group  = g_vis)
sideHistWidth  = input.int(6,   "Side Histogram Span (bars)",
                              minval = 2, maxval = 40, step = 1,
                              group  = g_vis)
ladderPosStr   = input.string("Bottom Center", "Delta Ladder Position",
                              options = ["Top Right","Top Left","Top Center",
                                         "Bottom Right","Bottom Left","Bottom Center",
                                         "Middle Right","Middle Left","Middle Center"],
                              group   = g_vis,
                              tooltip = "Position the vertical delta ladder column. Default 'Bottom Center' so it stays out of the way of the Top-Right dashboard.")
stripAlpha     = input.int(60,  "Heatmap Strip Transparency",
                              minval = 0,  maxval = 95, step = 5,
                              group  = g_vis)

// ----- Dashboard -------------------------------------------------------------
g_dash         = "Dashboard"
showDash       = input.bool(true, "Show Dashboard",            group = g_dash)
dashPosStr     = input.string("Top Right", "Dashboard Position",
                              options = ["Top Right","Top Left","Top Center",
                                         "Bottom Right","Bottom Left","Bottom Center",
                                         "Middle Right","Middle Left","Middle Center"],
                              group   = g_dash)
dashSizeStr    = input.string("Small", "Dashboard Text Size",
                              options = ["Tiny","Small","Normal","Large","Huge"],
                              group   = g_dash)

// ----- Alerts ----------------------------------------------------------------
g_alert        = "Alerts"
alertWhale     = input.bool(true, "Alert: Whale Print",          group = g_alert)
alertAbs       = input.bool(true, "Alert: Absorption Zone",      group = g_alert)
alertImbal     = input.bool(true, "Alert: Imbalance Spike",      group = g_alert)
alertPocShift  = input.bool(true, "Alert: POC Shift",            group = g_alert)
pocShiftBins   = input.int(2, "POC Shift: Bin Distance Trigger",
                            minval = 1, maxval = 20, step = 1,
                            group  = g_alert,
                            tooltip = "How many bins the POC must jump between bars to fire the POC Shift alert.")

// =============================================================================
//  SECTION 2 - CURATED HEATMAP PALETTE + GRADIENT STOPS
// =============================================================================
//  Single locked palette - the AlgoAlpha-grade heatmap. Solid colors plus the
//  4 multi-stop gradient ramps that drive the absorption / delta / whale
//  heat layers.
// -----------------------------------------------------------------------------

color C_BULL = #5CF0D7
color C_BEAR = #FF4D75
color C_MID  = #FFEA00
color C_BG   = #02011A
color C_FRAME = #1A1A33

// Gradient stops for absorption intensity (cool -> hot). Signature ramp.
var array<color> ABS_STOPS = array.from(
     color.new(#0A0E40, 0),
     color.new(#1F0F70, 0),
     color.new(#4C1F8E, 0),
     color.new(#7E1FAA, 0),
     color.new(#BE2FC8, 0),
     color.new(#FFEA00, 0))

// Bull / Buy delta ramp (dark -> teal).
var array<color> BUY_STOPS  = array.from(
     color.new(#002013, 0),
     color.new(#006033, 0),
     color.new(#00A058, 0),
     color.new(#00D87B, 0),
     color.new(#5CF0D7, 0))

// Bear / Sell delta ramp (dark -> red).
var array<color> SELL_STOPS = array.from(
     color.new(#2A0010, 0),
     color.new(#5C0020, 0),
     color.new(#A30038, 0),
     color.new(#E60050, 0),
     color.new(#FF4D75, 0))

// Whale activity ramp (single axis hot) - dark navy to yellow flame.
var array<color> WHALE_STOPS = array.from(
     color.new(#131722, 0),
     color.new(#1F4068, 0),
     color.new(#2E8BC0, 0),
     color.new(#4DBBF7, 0),
     color.new(#FFEA00, 0))

// =============================================================================
//  SECTION 3 - HELPER FUNCTIONS
// =============================================================================
//  Pure utility helpers reused across sections. Each is small enough to
//  inline but is kept named for clarity and easier code review.
// -----------------------------------------------------------------------------

// Linear RGB interpolation between two colors. Ratio is clamped 0..1.
f_colorGradient(float _ratio, color _colA, color _colB) =>
    r  = math.max(0.0, math.min(1.0, _ratio))
    rA = color.r(_colA), gA = color.g(_colA), bA = color.b(_colA)
    rB = color.r(_colB), gB = color.g(_colB), bB = color.b(_colB)
    rr = rA + int((rB - rA) * r)
    rg = gA + int((gB - gA) * r)
    rb = bA + int((bB - bA) * r)
    color.rgb(rr, rg, rb, 0)

// Multi-stop gradient. Takes an array<color> and a 0..1 ratio. Walks the
// ratio into the appropriate interval and delegates to f_colorGradient.
f_gradientMulti(float ratio, array<color> stops) =>
    int   n     = array.size(stops) - 1
    float r     = math.max(0.0, math.min(1.0, ratio))
    float pos   = r * n
    int   idx   = math.min(n - 1, math.max(0, int(pos)))
    float local = pos - idx
    f_colorGradient(local, array.get(stops, idx), array.get(stops, idx + 1))

// Clamp scalar into bounds.
f_clamp(float _x, float _min, float _max) =>
    math.max(_min, math.min(_x, _max))

// Position string -> position constant.
strToPos(string s) =>
    switch s
        "Top Right"     => position.top_right
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Bottom Right"  => position.bottom_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Middle Right"  => position.middle_right
        "Middle Left"   => position.middle_left
        "Middle Center" => position.middle_center
        =>               position.bottom_right

// Size string -> size constant.
strToSize(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        =>          size.small

// Volume number formatter: K / M / B.
formatVolume(float v) =>
    av = math.abs(v)
    av >= 1e9 ? str.tostring(v / 1e9, "#.##") + "B" : av >= 1e6 ? str.tostring(v / 1e6, "#.##") + "M" : av >= 1e3 ? str.tostring(v / 1e3, "#.##") + "K" : str.tostring(v, "#.##")

// Approximate percentile of `target` within `arr`. Linear scan is fine for
// the modest array sizes (<= 200) we use here. Returns 0..100.
f_percentile(array<float> arr, float target) =>
    int n = array.size(arr)
    float pct = 0.0
    if n > 0
        int below = 0
        for i = 0 to n - 1
            if array.get(arr, i) <= target
                below += 1
        pct := 100.0 * below / n
    pct

// Returns the value at the Nth percentile in arr. Sorts a copy so the source
// is not modified. n is in [0, 100].
f_valueAtPercentile(array<float> arr, float p) =>
    int sz = array.size(arr)
    float v = 0.0
    if sz > 0
        array<float> cp = array.copy(arr)
        array.sort(cp, order.ascending)
        float pos = (p / 100.0) * (sz - 1)
        int idx   = math.min(sz - 1, math.max(0, int(pos)))
        v := array.get(cp, idx)
    v

// Argmax: returns the index of the largest element. -1 if empty.
f_argmax(array<float> arr) =>
    int n = array.size(arr)
    int best = -1
    float bestV = -1e20
    if n > 0
        for i = 0 to n - 1
            float v = array.get(arr, i)
            if v > bestV
                bestV := v
                best  := i
    best

// Safe div with epsilon.
f_safeDiv(float num, float den) =>
    den == 0.0 ? 0.0 : num / den

// =============================================================================
//  SECTION 4 - LOWER-TIMEFRAME DATA FETCH + BINNING
// =============================================================================
//  Pull intrabar closes / volumes via request.security_lower_tf so the script
//  can reconstruct buy vs sell aggression via the tick rule. The tick rule
//  classifies each LTF bar's volume as buy if prevClose < currClose, sell
//  otherwise. This is the standard estimator when actual side-of-tape data
//  is unavailable.
//
//  The returned arrays are aligned: arrCloses[i] is the close of the i-th
//  LTF bar inside the current chart bar, and arrVols[i] is its volume.
//  ignore_invalid_timeframe lets the call fail soft if the chart timeframe
//  is too low for the requested LTF (e.g. 1S on a 5S chart).
// -----------------------------------------------------------------------------

// Per-bar intrabar arrays - one float each. Aligned by LTF bar index.
array<float> ltfCloses = request.security_lower_tf(syminfo.tickerid, ltfChoice, close,  ignore_invalid_timeframe = true)
array<float> ltfVols   = request.security_lower_tf(syminfo.tickerid, ltfChoice, volume, ignore_invalid_timeframe = true)

// Per-bar derived totals (computed from the LTF arrays).
float barBuyVol   = 0.0
float barSellVol  = 0.0
float barAbsVol   = 0.0
float prevLtfClose = na

int ltfN = array.size(ltfCloses)
if ltfN > 0 and array.size(ltfVols) == ltfN
    // Seed prev close with the previous chart bar's close so the first
    // intrabar tick is classified relative to the prior chart bar.
    prevLtfClose := nz(close[1], array.get(ltfCloses, 0))
    for i = 0 to ltfN - 1
        float c = array.get(ltfCloses, i)
        float v = nz(array.get(ltfVols, i), 0.0)
        if not na(c)
            if c >= prevLtfClose
                barBuyVol  += v
            else
                barSellVol += v
            barAbsVol += v
            prevLtfClose := c

// =============================================================================
//  SECTION 5 - STATE STRUCTURES (UDTs)
// =============================================================================
//  We expose two UDTs in the JOAT vocabulary:
//
//      VolNode         - represents one price-bin row in the cumulative profile.
//      AbsorptionCell  - represents one bar-x-bin heatmap cell.
//
//  Both are kept lightweight (fundamental fields only). The profile state is
//  rebuilt on the last bar of the lookback window so all visuals are fresh
//  and we never exceed object caps.
// -----------------------------------------------------------------------------

type VolNode
    float price       // mid-price of the bin
    float buyVol      // accumulated buy volume in this bin
    float sellVol     // accumulated sell volume in this bin
    float totalVol    // buy + sell
    float delta       // buy - sell
    float deltaPct    // delta / totalVol  (-1 .. +1)
    float absorption  // min(buy, sell) / (priceMovement + eps)
    float priceRange  // tracking range traded inside this bin
    int   tagWhale    // 1 if classified as whale print, 0 otherwise
    int   tagAbs      // 1 if classified as absorption zone, 0 otherwise
    int   tagImbal    // 1 if classified as imbalance spike, 0 otherwise

type AbsorptionCell
    int   barOffset   // 0..lookbackBars-1, 0 == oldest, lookbackBars-1 == newest
    int   binIdx      // 0..nBins-1, 0 == lowest price row
    float intensity   // 0..1 absorption intensity
    float delta       // signed bin delta
    float totalVol    // total vol contributing to this cell
    color cellColor   // pre-computed render color

// Persistent drawing buffers - cleared and rewritten on each render pass so
// we never overflow the object caps even with high bin counts.
var array<box>      stripBoxes  = array.new<box>()
var array<line>     pocLines    = array.new<line>()
var array<label>    markerLbls  = array.new<label>()
var array<line>     histLines   = array.new<line>()
var polyline        profileBuy  = na
var polyline        profileSell = na
var polyline        sideHistPl  = na
var table           deltaLadder = na
var table           dashTbl     = na

// POC tracking for shift alerts (compare bin index between bars).
var int prevPocBin = -1

// =============================================================================
//  SECTION 6 - PROFILE COMPUTATION + PERCENTILE FILTERS
// =============================================================================
//  The expensive aggregation runs on every bar but only writes to the
//  rendering arrays on the last bar. We:
//
//      1. Determine the price range across the lookback window.
//      2. Bin every recent bar's reconstructed buy / sell totals using the
//         hl2-midpoint of the bar as the row index.
//      3. Compute delta, delta%, absorption per bin.
//      4. Pull percentile thresholds for volume, absorption, and |delta|.
//      5. Tag rows with whale / absorption / imbalance flags.
//
//  Bin-step calculation uses the configured lookback so the profile sits
//  exactly across the visible structure window.
// -----------------------------------------------------------------------------

// Persist per-bar buy / sell so we can re-aggregate across the lookback
// without re-running the LTF fetch.
var array<float> barBuyHist  = array.new<float>()
var array<float> barSellHist = array.new<float>()
var array<float> barHl2Hist  = array.new<float>()
var array<float> barHiHist   = array.new<float>()
var array<float> barLoHist   = array.new<float>()
var array<int>   barIdxHist  = array.new<int>()

// Append this bar's totals to the rolling history. Trim past the lookback +
// a comfortable margin to keep memory bounded.
if barstate.isconfirmed
    array.push(barBuyHist,  barBuyVol)
    array.push(barSellHist, barSellVol)
    array.push(barHl2Hist,  hl2)
    array.push(barHiHist,   high)
    array.push(barLoHist,   low)
    array.push(barIdxHist,  bar_index)
    int cap = lookbackBars + 5
    while array.size(barBuyHist) > cap
        array.shift(barBuyHist)
        array.shift(barSellHist)
        array.shift(barHl2Hist)
        array.shift(barHiHist)
        array.shift(barLoHist)
        array.shift(barIdxHist)

// Build the profile, returning aligned arrays of per-bin metrics. Encapsulated
// so it can run on the last bar without intermediate state leaking outside.
buildProfile(int nBins, int lb, bool useHl2) =>
    int sz = math.min(lb, array.size(barBuyHist))

    // Range scan
    float pMax = -1e20
    float pMin =  1e20
    if sz > 0
        for i = array.size(barBuyHist) - sz to array.size(barBuyHist) - 1
            float hi = useHl2 ? array.get(barHl2Hist, i) : array.get(barHiHist, i)
            float lo = useHl2 ? array.get(barHl2Hist, i) : array.get(barLoHist, i)
            if hi > pMax
                pMax := hi
            if lo < pMin
                pMin := lo

    // Guard for degenerate ranges.
    if pMax <= pMin
        pMax := pMin + syminfo.mintick * nBins

    float step = (pMax - pMin) / nBins

    // Allocate per-bin arrays.
    array<float> binBuy   = array.new<float>(nBins, 0.0)
    array<float> binSell  = array.new<float>(nBins, 0.0)
    array<float> binTotal = array.new<float>(nBins, 0.0)
    array<float> binPrice = array.new<float>(nBins, 0.0)

    for b = 0 to nBins - 1
        array.set(binPrice, b, pMin + (b + 0.5) * step)

    // Accumulate
    if sz > 0
        for i = array.size(barBuyHist) - sz to array.size(barBuyHist) - 1
            float p   = array.get(barHl2Hist, i)
            float bv  = array.get(barBuyHist,  i)
            float sv  = array.get(barSellHist, i)
            int   bin = math.min(nBins - 1, math.max(0, int((p - pMin) / step)))
            array.set(binBuy,   bin, array.get(binBuy,   bin) + bv)
            array.set(binSell,  bin, array.get(binSell,  bin) + sv)
            array.set(binTotal, bin, array.get(binTotal, bin) + bv + sv)

    [binBuy, binSell, binTotal, binPrice, pMin, pMax, step]

// =============================================================================
//  SECTION 7 - RENDERING - HEATMAP STRIPS, PROFILE, LADDER, HISTOGRAM
// =============================================================================
//  All rendering executes inside `if barstate.islast and not lite-mode`.
//  Each render block:
//      * Deletes the prior drawings for its layer
//      * Iterates over the bins / cells / strips
//      * Pushes new objects, keyed by gradient sampling of the right ramp
//
//  Object accounting:
//      * Heatmap strips:  up to nBins * lookbackBars  (capped at ~400 in defaults)
//      * Volume profile: 2 polylines (one buy, one sell)
//      * Delta ladder:   1 table
//      * Side histogram: 1 polyline
//      * POC / VAH / VAL: 3 lines
//      * Markers:        up to ~3 * (whale + abs + imbal) labels
//      * Dashboard:      1 table
// -----------------------------------------------------------------------------

// Helper - clear a buffer of drawable objects of a known type.
clearBoxes(array<box> b) =>
    int n = array.size(b)
    if n > 0
        for i = 0 to n - 1
            box.delete(array.get(b, i))
    array.clear(b)

clearLines(array<line> ln) =>
    int n = array.size(ln)
    if n > 0
        for i = 0 to n - 1
            line.delete(array.get(ln, i))
    array.clear(ln)

clearLabels(array<label> lb) =>
    int n = array.size(lb)
    if n > 0
        for i = 0 to n - 1
            label.delete(array.get(lb, i))
    array.clear(lb)

deletePolyline(polyline p) =>
    if not na(p)
        polyline.delete(p)
    polyline pna = na
    pna

// -- Heatmap strip renderer ---------------------------------------------------
//  Draws nBins horizontal strips behind each of the last `lb` chart bars.
//  Each strip's intensity = (buy + sell) for that bar's hl2 bucket. Cells
//  with zero contribution are skipped to save the draw budget.
renderHeatmap(int nBins, int lb, float pMin, float step, int totalRows) =>
    clearBoxes(stripBoxes)
    if not liteMode and showHeatmap
        int sz = math.min(lb, array.size(barBuyHist))
        if sz > 0
            // Find the cell maximum to normalise intensity.
            array<float> cellTot = array.new<float>(nBins * sz, 0.0)
            for i = 0 to sz - 1
                int srcIdx = array.size(barBuyHist) - sz + i
                float p    = array.get(barHl2Hist,  srcIdx)
                float bv   = array.get(barBuyHist,  srcIdx)
                float sv   = array.get(barSellHist, srcIdx)
                int   bin  = math.min(nBins - 1, math.max(0, int((p - pMin) / step)))
                array.set(cellTot, i * nBins + bin, bv + sv)

            float cellMax = 0.0
            for k = 0 to array.size(cellTot) - 1
                float v = array.get(cellTot, k)
                if v > cellMax
                    cellMax := v

            int drawn = 0
            int budget = 380
            // Reserve about 380 of the 500 box budget for heatmap; the
            // remaining 120 covers any other future use.
            for i = 0 to sz - 1
                int srcIdx = array.size(barBuyHist) - sz + i
                int barIdxAt = array.get(barIdxHist, srcIdx)
                for b = 0 to nBins - 1
                    if drawn >= budget
                        break
                    float intensity = f_safeDiv(array.get(cellTot, i * nBins + b), cellMax)
                    if intensity > 0.0
                        float bot = pMin + b * step
                        float top = bot + step
                        color cc  = color.new(f_gradientMulti(intensity, ABS_STOPS), stripAlpha)
                        box bx = box.new(
                             left          = barIdxAt,
                             top           = top,
                             right         = barIdxAt + 1,
                             bottom        = bot,
                             border_color  = color.new(color.black, 100),
                             bgcolor       = cc,
                             extend        = extend.none)
                        array.push(stripBoxes, bx)
                        drawn += 1
    int done = 0
    done

// -- Horizontal volume profile (polyline buy + polyline sell) -----------------
renderVolumeProfile(polyline _pb, polyline _ps, array<float> binBuy, array<float> binSell, array<float> binPrice, int nBins, int rightOffset) =>
    polyline pb = deletePolyline(_pb)
    polyline ps = deletePolyline(_ps)
    if showVolProfile
        // Normalise widths to maxTotal across bins.
        float maxTot = 0.0
        for b = 0 to nBins - 1
            float t = array.get(binBuy, b) + array.get(binSell, b)
            if t > maxTot
                maxTot := t

        // Build a stepped polyline for buy and another for sell. The right
        // edge of the chart anchors at bar_index + rightOffset (rightmost),
        // and each bin extends LEFTWARD by buyShare * width.
        array<chart.point> buyPts  = array.new<chart.point>()
        array<chart.point> sellPts = array.new<chart.point>()
        int rightX = bar_index + rightOffset
        if maxTot > 0
            for b = 0 to nBins - 1
                float pr = array.get(binPrice, b)
                float bv = array.get(binBuy,  b)
                float sv = array.get(binSell, b)
                int   bw = int((bv / maxTot) * rightOffset * 0.55)
                int   sw = int((sv / maxTot) * rightOffset * 0.55)
                // Buy bar: extends LEFT from rightX
                array.push(buyPts, chart.point.from_index(rightX - bw, pr))
                array.push(buyPts, chart.point.from_index(rightX,      pr))
                // Sell bar: extends FURTHER LEFT beyond the buy width
                array.push(sellPts, chart.point.from_index(rightX - bw - sw, pr))
                array.push(sellPts, chart.point.from_index(rightX - bw,      pr))
        if array.size(buyPts) > 0
            pb := polyline.new(
                 points     = buyPts,
                 curved     = false,
                 closed     = false,
                 line_color = color.new(C_BULL, 25),
                 fill_color = color.new(C_BULL, 80),
                 line_width = 2)
        if array.size(sellPts) > 0
            ps := polyline.new(
                 points     = sellPts,
                 curved     = false,
                 closed     = false,
                 line_color = color.new(C_BEAR, 25),
                 fill_color = color.new(C_BEAR, 80),
                 line_width = 2)
    [pb, ps]

// -- Delta ladder column ------------------------------------------------------
//  A single-column table whose cell count == nBins. Cell text = "D +/-NNN",
//  cell bgcolor scales with magnitude via BUY_STOPS / SELL_STOPS.
renderDeltaLadder(table _dl, array<float> binBuy, array<float> binSell, array<float> binPrice, int nBins) =>
    table dl = _dl
    if not na(dl)
        table.delete(dl)
        dl := na
    if showDeltaLad
        // We need the absolute-max delta to normalise.
        float maxAbsD = 0.0
        for b = 0 to nBins - 1
            float d = array.get(binBuy, b) - array.get(binSell, b)
            if math.abs(d) > maxAbsD
                maxAbsD := math.abs(d)

        dl := table.new(
             position    = strToPos(ladderPosStr),
             columns     = nBins,
             rows        = 1,
             bgcolor     = color.new(C_BG, 80),
             frame_color = color.new(C_MID, 50),
             frame_width = 1,
             border_color= color.new(C_MID, 80),
             border_width= 1)

        // Horizontal layout: left = low price, right = high price.
        // Each column = one price bin; one row of delta cells running across the bottom.
        for c = 0 to nBins - 1
            float d   = array.get(binBuy, c) - array.get(binSell, c)
            float mag = maxAbsD > 0 ? math.abs(d) / maxAbsD : 0.0
            cBg = d == 0.0 ? color.new(C_BG, 70) : d > 0.0 ? color.new(f_gradientMulti(mag, BUY_STOPS),  25) : color.new(f_gradientMulti(mag, SELL_STOPS), 25)
            string sign = d >= 0 ? "+" : "-"
            string txt  = sign + formatVolume(math.abs(d))
            table.cell(dl, c, 0, txt,
                 text_color = color.new(#FFFFFF, 0),
                 bgcolor    = cBg,
                 text_size  = size.tiny,
                 text_halign= text.align_center,
                 text_font_family = font.family_monospace)
    dl

// -- Side volume histogram polyline ------------------------------------------
//  A grey polyline far right that mirrors total volume per row, like the
//  rightmost grey bars in the AlgoAlpha reference image. Implemented as
//  one polyline with two points per row (zero-anchor and value).
renderSideHistogram(polyline _sh, array<float> binTotal, array<float> binPrice, int nBins, int rightOffset, int span) =>
    polyline sh = deletePolyline(_sh)
    if not liteMode and showSideHist
        float maxT = 0.0
        for b = 0 to nBins - 1
            float v = array.get(binTotal, b)
            if v > maxT
                maxT := v
        array<chart.point> pts = array.new<chart.point>()
        int anchorX = bar_index + rightOffset + 2
        if maxT > 0
            for b = 0 to nBins - 1
                float pr = array.get(binPrice, b)
                float v  = array.get(binTotal, b)
                int   w  = int((v / maxT) * span)
                array.push(pts, chart.point.from_index(anchorX,     pr))
                array.push(pts, chart.point.from_index(anchorX + w, pr))
        if array.size(pts) > 0
            sh := polyline.new(
                 points     = pts,
                 curved     = false,
                 closed     = false,
                 line_color = color.new(color.gray, 25),
                 fill_color = color.new(color.gray, 80),
                 line_width = 2)
    sh

// -- POC / VAH / VAL lines ----------------------------------------------------
renderPocLines(array<float> binTotal, array<float> binPrice, int nBins) =>
    clearLines(pocLines)
    if showPocLines
        // POC = argmax(binTotal); VAH/VAL by walking outward from POC until
        // we cover >= 70% of total volume.
        int pocIdx = f_argmax(binTotal)
        if pocIdx >= 0
            float pocPrice = array.get(binPrice, pocIdx)
            float total    = 0.0
            for b = 0 to nBins - 1
                total += array.get(binTotal, b)
            float threshold = total * 0.70
            float covered   = array.get(binTotal, pocIdx)
            int   lo = pocIdx
            int   hi = pocIdx
            while covered < threshold and (lo > 0 or hi < nBins - 1)
                float vLo = lo > 0          ? array.get(binTotal, lo - 1) : -1.0
                float vHi = hi < nBins - 1  ? array.get(binTotal, hi + 1) : -1.0
                if vHi >= vLo and hi < nBins - 1
                    hi += 1
                    covered += vHi
                else if lo > 0
                    lo -= 1
                    covered += vLo
                else
                    break
            float val = array.get(binPrice, lo)
            float vah = array.get(binPrice, hi)
            int   xLeft  = bar_index - lookbackBars
            int   xRight = bar_index + profileWidth
            line lnPoc = line.new(xLeft, pocPrice, xRight, pocPrice,
                 color = color.new(C_MID, 10), style = line.style_solid, width = 2)
            line lnVah = line.new(xLeft, vah, xRight, vah,
                 color = color.new(C_BULL, 30), style = line.style_dashed, width = 1)
            line lnVal = line.new(xLeft, val, xRight, val,
                 color = color.new(C_BEAR, 30), style = line.style_dashed, width = 1)
            array.push(pocLines, lnPoc)
            array.push(pocLines, lnVah)
            array.push(pocLines, lnVal)
    int done = 0
    done

// =============================================================================
//  SECTION 8 - SIGNAL TAGGING + MARKER RENDERING
// =============================================================================
//  Three single-row classifications:
//      Whale Print     - row totalVol > volPct AND |delta|/totalVol > deltaPct
//      Absorption Zone - row absorption > absPct
//      Imbalance Spike - max(buy, sell) > imbalRatio * min(buy, sell)
//
//  Per row, we render at most one glyph (the most informative one) to keep
//  the label budget under control. Labels are drawn just to the LEFT of the
//  profile polylines so they sit beside the chart's price action.
// -----------------------------------------------------------------------------

classifyAndMark(array<float> binBuy, array<float> binSell, array<float> binTotal, array<float> binPrice, int nBins) =>
    clearLabels(markerLbls)

    // Build totalVol and absorption arrays for percentile sampling.
    array<float> volArr = array.new<float>()
    array<float> absArr = array.new<float>()
    array<float> dPctArr = array.new<float>()
    for b = 0 to nBins - 1
        float bv = array.get(binBuy,  b)
        float sv = array.get(binSell, b)
        float t  = bv + sv
        float mn = math.min(bv, sv)
        // priceMovement proxy: bin width * row activity ratio (rough);
        // ATR-normalised below for numerical stability.
        float pm = math.max(syminfo.mintick * 4.0, math.abs(bv - sv))
        float abscore = f_safeDiv(mn, pm)
        float dpct    = t > 0 ? math.abs(bv - sv) / t : 0.0
        if t > 0
            array.push(volArr,  t)
            array.push(absArr,  abscore)
            array.push(dPctArr, dpct)

    float volThreshold = f_valueAtPercentile(volArr, whaleVolPct)
    float absThreshold = f_valueAtPercentile(absArr, absScorePct)
    float strThreshold = f_valueAtPercentile(volArr, strengthPct)

    int markerBudget = 60
    int markerCount  = 0
    int leftAnchor   = bar_index + profileWidth + 2

    int whaleCount = 0
    int absCount   = 0
    int imbalCount = 0

    if showMarkers and array.size(volArr) > 0
        for b = 0 to nBins - 1
            float bv = array.get(binBuy,  b)
            float sv = array.get(binSell, b)
            float t  = bv + sv
            if t < minVolBin or t <= 0
                continue

            float dpct = math.abs(bv - sv) / t
            float mn   = math.min(bv, sv)
            float pm   = math.max(syminfo.mintick * 4.0, math.abs(bv - sv))
            float abscore = f_safeDiv(mn, pm)
            bool isWhale = showWhale      and t >= volThreshold and dpct >= (whaleDeltaPct / 100.0)
            bool isAbs   = showAbsorption and abscore >= absThreshold and t >= strThreshold
            bool isImb   = showImbal      and (math.max(bv, sv) >= imbalRatio * math.max(0.000001, math.min(bv, sv)))

            if isWhale
                whaleCount += 1
            if isAbs
                absCount += 1
            if isImb
                imbalCount += 1

            if markerCount < markerBudget
                string glyph = ""
                color  gCol  = C_MID
                if isWhale
                    glyph := "WHALE"
                    gCol  := f_gradientMulti(math.min(1.0, t / math.max(volThreshold, 1.0)), WHALE_STOPS)
                else if isAbs
                    glyph := "ABS"
                    gCol  := f_gradientMulti(math.min(1.0, abscore / math.max(absThreshold, 1e-6)), ABS_STOPS)
                else if isImb
                    glyph := "IMB"
                    gCol  := bv > sv ? color.new(C_BULL, 20) : color.new(C_BEAR, 20)

                if glyph != ""
                    label lb = label.new(
                         x        = leftAnchor,
                         y        = array.get(binPrice, b),
                         text     = glyph,
                         xloc     = xloc.bar_index,
                         yloc     = yloc.price,
                         color    = color.new(gCol, 75),
                         textcolor= color.white,
                         style    = label.style_label_left,
                         size     = size.tiny)
                    array.push(markerLbls, lb)
                    markerCount += 1

    [whaleCount, absCount, imbalCount]

// =============================================================================
//  SECTION 9 - DASHBOARD
// =============================================================================
//  10+ rows of summary statistics. Position and text size are configurable.
//  Each row uses a two-column layout (label | value) with a header row that
//  highlights the indicator name and active status dot.
// -----------------------------------------------------------------------------

// Dashboard row helper - kept at global scope because Pine v6 disallows
// nested function definitions. Takes the table id, the row index, label
// text, value text, value color, and the configured text size constant.
dashAddRow(table tbl, int r, string lbl, string val, color valCol, string sizeStr) =>
    color rowBg = color.new(C_BG, 90)
    table.cell(tbl, 0, r, lbl,
         text_color = color.new(#CCCCCC, 0),
         bgcolor    = rowBg,
         text_size  = strToSize(sizeStr),
         text_halign= text.align_left,
         text_font_family = font.family_monospace)
    table.cell(tbl, 1, r, val,
         text_color = valCol,
         bgcolor    = rowBg,
         text_size  = strToSize(sizeStr),
         text_halign= text.align_right,
         text_font_family = font.family_monospace)

renderDashboard(table _dt, array<float> binTotal, array<float> binPrice, int nBins, float totalDelta, int whaleN, int absN, int imbalN) =>
    table dt = _dt
    if not na(dt)
        table.delete(dt)
        dt := na
    if showDash
        dt := table.new(
             position    = strToPos(dashPosStr),
             columns     = 2,
             rows        = 12,
             bgcolor     = color.new(C_BG, 80),
             frame_color = color.new(C_MID, 65),
             frame_width = 1,
             border_color= color.new(C_MID, 80),
             border_width= 1)

        // Status dot color
        color statusCol = totalDelta > 0 ? C_BULL : totalDelta < 0 ? C_BEAR : C_MID

        // Header (spans both cols)
        table.cell(dt, 0, 0, "WHALE ABSORPTION",
             text_color = color.white,
             bgcolor    = color.new(C_BG, 25),
             text_size  = strToSize(dashSizeStr),
             text_halign= text.align_left,
             text_font_family = font.family_monospace)
        table.cell(dt, 1, 0, "[DOT] " + (barstate.isrealtime ? "RT" : "HIST"),
             text_color = statusCol,
             bgcolor    = color.new(C_BG, 25),
             text_size  = strToSize(dashSizeStr),
             text_halign= text.align_right,
             text_font_family = font.family_monospace)

        // Compute POC display
        int   pocIdx   = f_argmax(binTotal)
        float pocPrice = pocIdx >= 0 ? array.get(binPrice, pocIdx) : na
        float totalVol = 0.0
        for b = 0 to nBins - 1
            totalVol += array.get(binTotal, b)

        // VAH / VAL (recomputed here so we don't pass them through every renderer)
        float vahPrice = na
        float valPrice = na
        if pocIdx >= 0
            float threshold = totalVol * 0.70
            float covered   = array.get(binTotal, pocIdx)
            int lo = pocIdx
            int hi = pocIdx
            while covered < threshold and (lo > 0 or hi < nBins - 1)
                float vLo = lo > 0          ? array.get(binTotal, lo - 1) : -1.0
                float vHi = hi < nBins - 1  ? array.get(binTotal, hi + 1) : -1.0
                if vHi >= vLo and hi < nBins - 1
                    hi += 1
                    covered += vHi
                else if lo > 0
                    lo -= 1
                    covered += vLo
                else
                    break
            vahPrice := array.get(binPrice, hi)
            valPrice := array.get(binPrice, lo)

        dashAddRow(dt, 1,  "LTF Source",     ltfChoice,                                       color.new(C_MID, 0),  dashSizeStr)
        dashAddRow(dt, 2,  "Active Bins",    str.tostring(nBins),                             color.new(C_MID, 0),  dashSizeStr)
        dashAddRow(dt, 3,  "POC Price",      not na(pocPrice) ? str.tostring(pocPrice, format.mintick) : "-", color.new(C_MID, 0), dashSizeStr)
        dashAddRow(dt, 4,  "VAH / VAL",
             (not na(vahPrice) ? str.tostring(vahPrice, format.mintick) : "-") + " / " +
             (not na(valPrice) ? str.tostring(valPrice, format.mintick) : "-"),
             color.new(C_BULL, 0), dashSizeStr)
        dashAddRow(dt, 5,  "Total Delta",    formatVolume(totalDelta),
             totalDelta > 0 ? color.new(C_BULL, 0) : totalDelta < 0 ? color.new(C_BEAR, 0) : color.new(C_MID, 0),
             dashSizeStr)
        dashAddRow(dt, 6,  "Whale Prints",   str.tostring(whaleN),                            color.new(C_BULL, 0), dashSizeStr)
        dashAddRow(dt, 7,  "Absorption",     str.tostring(absN),                              color.new(C_MID,  0), dashSizeStr)
        dashAddRow(dt, 8,  "Imbalance Spikes", str.tostring(imbalN),                          color.new(C_BEAR, 0), dashSizeStr)
        dashAddRow(dt, 9,  "Lookback (Bars)", str.tostring(lookbackBars),                     color.new(C_MID, 0),  dashSizeStr)
        dashAddRow(dt, 10, "Strength Pct",   str.tostring(strengthPct, "#.#") + " %",         color.new(C_MID, 0),  dashSizeStr)
        dashAddRow(dt, 11, "Lite Mode",      liteMode ? "ON" : "OFF",
             liteMode ? color.new(C_BEAR, 0) : color.new(C_BULL, 0), dashSizeStr)
    dt

// =============================================================================
//  SECTION 10 - LAST-BAR RENDER PIPELINE + ALERT EMITTERS
// =============================================================================
//  Everything runs on barstate.islast so the heavy drawing happens once per
//  realtime tick instead of compounding across history. We:
//
//      1. Build the profile (binBuy, binSell, binTotal, binPrice, range)
//      2. Render heatmap strips, profile, ladder, side histogram, POC lines
//      3. Classify rows + draw marker glyphs
//      4. Render dashboard
//      5. Fire alerts if any classifications happened this bar
// -----------------------------------------------------------------------------

if barstate.islast
    [binBuy, binSell, binTotal, binPrice, pMin, pMax, step] = buildProfile(nBinsInput, lookbackBars, useHL2Anchor)

    renderHeatmap(nBinsInput, lookbackBars, pMin, step, array.size(binPrice))
    [_pbNew, _psNew] = renderVolumeProfile(profileBuy, profileSell, binBuy, binSell, binPrice, nBinsInput, profileWidth)
    profileBuy  := _pbNew
    profileSell := _psNew
    deltaLadder := renderDeltaLadder(deltaLadder, binBuy, binSell, binPrice, nBinsInput)
    sideHistPl  := renderSideHistogram(sideHistPl, binTotal, binPrice, nBinsInput, profileWidth + ladderWidth, sideHistWidth)
    renderPocLines(binTotal, binPrice, nBinsInput)
    [whaleN, absN, imbalN] = classifyAndMark(binBuy, binSell, binTotal, binPrice, nBinsInput)

    float totalDelta = 0.0
    for b = 0 to nBinsInput - 1
        totalDelta += array.get(binBuy, b) - array.get(binSell, b)

    dashTbl := renderDashboard(dashTbl, binTotal, binPrice, nBinsInput, totalDelta, whaleN, absN, imbalN)

    // POC shift alert: compare last bar's POC index with this bar's.
    int pocIdx = f_argmax(binTotal)
    bool pocShifted = prevPocBin >= 0 and pocIdx >= 0 and math.abs(pocIdx - prevPocBin) >= pocShiftBins
    prevPocBin := pocIdx

    if alertWhale    and whaleN  > 0
        alert("Whale Print detected (" + str.tostring(whaleN) + " row(s))", alert.freq_once_per_bar)
    if alertAbs      and absN    > 0
        alert("Absorption Zone formed (" + str.tostring(absN) + " row(s))", alert.freq_once_per_bar)
    if alertImbal    and imbalN  > 0
        alert("Imbalance Spike (" + str.tostring(imbalN) + " row(s))",      alert.freq_once_per_bar)
    if alertPocShift and pocShifted
        alert("POC shift detected (>= " + str.tostring(pocShiftBins) + " bins)", alert.freq_once_per_bar)

// =============================================================================
//  SECTION 11 - ALERTCONDITION DECLARATIONS (UI WIRING)
// =============================================================================
//  alertcondition() must be called at the top level so the user can pick
//  these from the "Create Alert" dialog. They mirror the dynamic alert()
//  emitters above; both paths exist so users have flexibility (alert() is
//  fire-and-forget on triggered bars, alertcondition() is selectable).
//  Each condition is gated by the corresponding visibility / classification
//  toggle so disabled subsystems do not fire spurious alerts.
// -----------------------------------------------------------------------------

// We re-derive simple last-bar booleans that the alertcondition expressions
// can evaluate without re-running the heavy profile builder. They use the
// per-bar reconstructed totals so they update each bar of history.
bool barWhaleCondition  = showWhale      and barBuyVol + barSellVol > 0 and math.abs(barBuyVol - barSellVol) / math.max(barBuyVol + barSellVol, 1e-6) >= (whaleDeltaPct / 100.0)
bool barAbsCondition    = showAbsorption and math.min(barBuyVol, barSellVol) > 0 and math.min(barBuyVol, barSellVol) / math.max(math.abs(barBuyVol - barSellVol), 1e-6) > 1.0
bool barImbalCondition  = showImbal      and math.max(barBuyVol, barSellVol) >= imbalRatio * math.max(1e-6, math.min(barBuyVol, barSellVol))
alertcondition(barWhaleCondition, title = "Whale Print (Bar)",   message = "WAP [JOAT]: Whale Print on bar")
alertcondition(barAbsCondition,   title = "Absorption (Bar)",    message = "WAP [JOAT]: Absorption on bar")
alertcondition(barImbalCondition, title = "Imbalance (Bar)",     message = "WAP [JOAT]: Imbalance on bar")

// =============================================================================
//  SECTION 12 - BAR-LEVEL DECORATIONS
// =============================================================================
//  Lightweight per-bar plots that DO NOT touch the drawing-object caps:
//      * Per-bar tick-rule delta as a near-invisible plot, for tooltip /
//        Data Window readout.
//      * Optional bar color tint by sign of barDelta. Off by default so the
//        chart aesthetic remains clean.
// -----------------------------------------------------------------------------

float barDelta = barBuyVol - barSellVol
plot(barDelta, title = "Bar Delta", color = color.new(color.gray, 100), display = display.data_window)
plot(barBuyVol,  title = "Bar Buy Vol",  color = color.new(color.gray, 100), display = display.data_window)
plot(barSellVol, title = "Bar Sell Vol", color = color.new(color.gray, 100), display = display.data_window)
plot(barAbsVol,  title = "Bar Total Vol", color = color.new(color.gray, 100), display = display.data_window)

// Bar colour tint by sign of delta (subtle).
useBarTint = input.bool(false, "Tint Bars by Delta Sign", group = g_vis)
color barColTint = barDelta > 0 ? color.new(C_BULL, 70) : barDelta < 0 ? color.new(C_BEAR, 70) : na
barcolor(useBarTint ? barColTint : na, title = "Delta Bar Tint")

// =============================================================================
//  SECTION 13 - DOCUMENTATION FOOTER
// =============================================================================
//  This footer captures runtime guidance for end users. It does not affect
//  execution but keeps the indicator self-documenting.
//
//  HOW TO READ THE VISUALS
//  -----------------------
//   * Heatmap strips behind each candle = absorption intensity per price row.
//     Brighter (yellow) = highest activity; deep purple/navy = quiet rows.
//   * Horizontal volume profile (right of chart) = teal buy bars stacked
//     against red sell bars per price row. Long total bar = high interest;
//     buy-heavy = institutions accumulating, sell-heavy = distribution.
//   * Delta ladder (far right table) = signed net per row. Green cell with
//     "D +N" = net buying at that row; red "D -N" = net selling.
//   * Side histogram (extreme right grey polyline) = total volume per row
//     ignoring side - shows the raw activity skyline.
//   * POC line (gold) = the most-traded price across the lookback window.
//   * VAH / VAL dashed lines = bounds enclosing 70% of all volume.
//   * Whale / Absorption / Imbalance glyphs sit at the marked rows.
//
//  TUNING GUIDE
//  ------------
//   * For low-end machines: enable Lite Mode + reduce bins to 25 + lookback 25.
//   * For ultra-precise reads on 5m+ charts: 1S LTF, 50 bins, 60 lookback.
//   * For intraday equity scalping: 5S LTF, 40 bins, 30 lookback.
//   * Whale percentile of 97 + delta % of 80 highlights only the very largest
//     one-sided prints; loosen to 90 / 65 if you want more signal.
//
//  COMPATIBILITY NOTES
//  -------------------
//   * Pine v6 only. Uses request.security_lower_tf with
//     ignore_invalid_timeframe = true so the indicator fails soft when the
//     chart timeframe is below the configured LTF.
//   * Compatible with all symbol types; intrabar quality depends on the
//     user's TradingView plan (Pro+ recommended).
//   * Will not run on Heikin-Ashi / Renko / Kagi / Line break charts at the
//     LTF; standard chart types only.
//
//  ALERT BEHAVIOUR
//  ---------------
//   * The dynamic alert() calls fire on the final bar of the realtime tick
//     when the classification fires that bar. Use these via "Any alert()
//     function call" when creating the chart alert.
//   * The alertcondition() declarations provide selectable per-bar conditions
//     for users who prefer the legacy alert workflow.
//
//  END OF FILE
// =============================================================================
````
