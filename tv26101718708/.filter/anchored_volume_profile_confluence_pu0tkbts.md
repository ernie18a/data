# Anchored Volume Profile Confluence 

- url: https://www.tradingview.com/script/Pu0TkbTs-Anchored-Volume-Profile-Confluence/
- type: indicator
- pine_id: PUB;c500dd16982849b48caf2123c919c81c
- version: 3.0

## Description

ANCHORED VOLUME PROFILE CONFLUENCE — POC, Value Area, HVN/LVN & Value Migration

OVERVIEW
This is an anchored volume-at-price framework. From a chosen anchor — the session, a swing pivot, or a bar you click — it builds a volume profile and reads where trade actually happened: the POC (the most-traded price), the value area, and the high- and low-volume nodes. It overlays the anchored VWAP (the mean) on the same anchor, maintains a second time-decayed profile whose value migrates against the sticky POC, and calibrates its stretch signals against the symbol's own past. Everything is built from one idea — volume distributed across price — so the layers describe the same auction from different angles rather than competing for screen space.

WHY THESE COMPONENTS ARE COMBINED (and how they work together)
Price tells you where the market is; volume-at-price tells you where it agreed value was. A profile alone is a static picture, a VWAP alone is a single line, and neither tells you whether what you are seeing is reliable. Each layer here answers a different question, and they are meant to be read together as one object:

- VOLUME PROFILE (POC / VALUE AREA / HVN-LVN) is the distribution of volume across price since the anchor. The POC is the price with the most acceptance. The value area is the price range containing the chosen percentage of volume (default 70%). High-volume nodes (HVN) are acceptance shelves where price tends to stall and rotate; low-volume nodes (LVN) are rejection gaps price tends to move through quickly. This is the structural map.

- ANCHORED VWAP (MEAN) is the volume-weighted average price over the same anchor. The POC is the MODE of value (where most trade occurred) and the VWAP is the MEAN (the volume-weighted centre). Their relationship is information in itself: when VWAP sits above the POC the distribution is top-heavy, below it bottom-heavy. Showing both, anchored to the same event, is what turns a profile into a read on skew.

- VOLUME-WEIGHTED SIGMA measures dispersion around the mean, computed from the running second moment (sigma = square root of E[x^2] - (E[x])^2), so "stretched" means the same thing on any instrument. This is what makes the stretch signal comparable across assets and calibratable.

- VALUE MIGRATION is the original layer. A second profile is maintained with an exponential half-life applied to its volume, so it weights recent trade more heavily. Its value (the decayed POC or value-area midpoint) reacts to what is happening now, while the anchored POC stays sticky. When the fast value crosses the anchored POC, acceptance is shifting — buyers or sellers are building value away from the established centre. Because both are derived from the same volume data, this is a coherent structural signal, not two unrelated indicators stacked together.

- REGIME and CALIBRATION are the quality layer. An efficiency-ratio and ADX read labels the market trending, mixed or choppy for context. Separately, the script tracks — past-only — how often a stretch beyond the bands actually reverted toward value, reported as a percentage with a confidence interval. This is what separates a measured framework from a drawing: the signal is scored against the instrument's own history.

Read together: the profile shows the structure (where value is, where the shelves and gaps are), the POC-versus-VWAP skew shows how that value is distributed, the sigma bands show how far price has stretched from it, the migration shows whether acceptance is moving, the regime tells you whether to trust a signal, and the calibration shows how the stretch has behaved here before.

HOW TO USE IT
1. Pick an anchor mode in settings — Session, Pivot High, Pivot Low, Pivot High/Low (auto), or Manual (click a bar). The profile and VWAP rebuild from that point.
2. Read the histogram for structure: trade toward HVN shelves (acceptance) and expect quick travel through LVN gaps (rejection). The POC is the gravity centre.
3. Use the value area (VAH/VAL) as the fair-value range; price outside it is out of value and either trending or stretched.
4. Watch the VWAP-versus-POC skew for whether value is top- or bottom-heavy, and the sigma stretch rails for extension.
5. Watch the fast value crossing the POC (triangles) as a sign acceptance is migrating; the table and exports quantify the migration.
6. Treat a stretch (circles) into an LVN as more reversion-prone and a stretch into an HVN as a potential trap; the table's verdict and past-only reversion rate summarise this.

WHAT MAKES IT ORIGINAL
It is not a static volume profile. It pairs an anchored profile with the anchored VWAP so you read the mode and the mean together; it adds a decayed-profile value-migration signal against the sticky POC; it uses robust percentile-based HVN/LVN thresholds that self-scale instead of a fixed percentage of the POC; it refines the profile with lower-timeframe intrabar data where available; and it calibrates its stretch signal per symbol. The migration read and the per-symbol calibration in particular are not part of a standard volume profile.

WORKS ON ANY ASSET (universal)
The price SOURCE for the mean is selectable in the settings, so the engine runs on any market — futures, indices, FX, crypto, or stocks. The profile is built from each bar's true high-low range (and from lower-timeframe bars where available, for accuracy). Volume-at-price requires volume; on symbols that report none, you can borrow volume from a reference symbol. All thresholds are ATR- and sigma-relative, so nothing is tied to one instrument's price scale. A data-health row tells you whether volume is native, borrowed, or refined by lower-timeframe data.

SETTINGS SUMMARY
- Data Source: price source (default HLC3) and an optional volume-borrow symbol for no-volume instruments.
- Anchor: anchor mode, pivot left/right lengths, and a manual anchor time.
- Profile: resolution (rows per ATR), value-area percentage, lower-timeframe refinement and its resolution, robust percentile node thresholds, HVN/LVN levels, histogram width, and what to draw.
- Value Migration: enable the decayed profile, its half-life, and the fast-line definition (value-area midpoint or raw POC).
- Signals & Regime: stretch threshold in sigma.
- Calibration: enable tracking, evaluation horizon, and minimum reversion in ATR.
- Visuals: Auto/Dark/Light theme, colours, line glow, on-chart labels, legend, table and their positions, and a data-health row.

The script also prints its name, the symbol and the timeframe on the chart, and an on-chart legend names every plotted level, so it is always clear what is being viewed.

LIMITATIONS (please read)
- Pivot anchors confirm only after the right-pivot length in bars; the profile is seeded back to the true pivot bar, but a new pivot anchor appears with that delay.
- Lower-timeframe refinement depends on available intrabar history and is disabled when volume is borrowed; older bars fall back to bar-range distribution.
- The decayed profile re-weights every bin each bar, so it is heavier than a static profile on long anchors.
- Calibration is descriptive of past behaviour only and is not a forecast.
- Everything here is probabilistic context, not a prediction or a guarantee.

DISCLAIMER
This is a study / indicator for chart analysis and education only. It is NOT a strategy, NOT a recommendation, and NOT financial advice. It places no orders and guarantees no outcome. Trading involves risk. Do your own research and manage your own risk.

## Source Code

````pine
// =============================================================================
//  ANCHORED VOLUME PROFILE CONFLUENCE — POC, Value Area, HVN/LVN & Value Migration
//  shorttitle: AVP-C                                             Pine Script v6
// ------------------------------------------------------------------------
//  WHAT THIS IS
//    An anchored volume-at-price framework. It builds a volume profile from an
//    automatically chosen anchor (a swing pivot, dual-auto, or session) and reads
//    where trade actually happened — the POC (most-traded price), the value area,
//    and high/low-volume nodes — alongside the anchored VWAP (the mean). On top of
//    that it maintains a second, time-DECAYED profile whose value migrates
//    against the sticky anchored POC, and it CALIBRATES its stretch signals
//    against the current symbol's own past.
//
//  ANCHORING (adaptive, no manual setup)
//    The anchor is chosen automatically — there is no click-to-place step:
//      * Dual (auto)  — anchors to the most recent significant swing (low or
//                       high) and re-anchors as new structure forms. The default.
//      * Swing Low / Swing High — anchor to that pivot type only.
//      * Session      — re-anchors each new session (intraday volume profile).
//    Swing anchors are seeded back to the true pivot bar, so the profile starts
//    at the real swing, not at the (delayed) confirmation bar.
//
//  CHANGES IN THIS UPDATE
//    * Anchoring is now fully AUTOMATIC. The old click-to-place manual anchor and
//      its on-add setup prompt are removed. Modes: Dual (auto) — the default —
//      plus Swing Low, Swing High and Session. Dual re-anchors to the most recent
//      significant swing. On existing charts no action is needed; any manual
//      anchor placed in an earlier version no longer applies.
//    * Refreshed colour scheme: teal / magenta for acceptance/rejection and bias,
//      orange POC, blue value area, amber fast (migration) line, dark panel with a
//      blue title. Every colour remains editable in Settings.
//    * All analytics are unchanged — volume profile, POC / value area / HVN-LVN,
//      anchored VWAP, value migration, regime and past-only calibration.
//
//  WHY THE COMPONENTS ARE COMBINED  (mashup rationale)
//    Price shows where the market is; volume-at-price shows where it agreed value
//    was. Each layer answers a different question and they are read together as
//    one object, not stacked as separate studies:
//      * VOLUME PROFILE (POC / VALUE AREA / HVN-LVN) — the distribution of volume
//        across price since the anchor. The POC is the most-accepted price; the
//        value area is where the chosen % of volume traded; HVN are acceptance
//        shelves and LVN are rejection gaps price tends to move through quickly.
//      * ANCHORED VWAP (MEAN) — the volume-weighted average since the same anchor.
//        POC is the MODE of value, VWAP is the MEAN; their relationship (skew)
//        shows whether value is top- or bottom-heavy.
//      * VOLUME-WEIGHTED σ — dispersion around the mean from the running second
//        moment (σ = √(E[x²] − E[x]²)), so "stretched" is comparable across assets
//        and can be calibrated.
//      * VALUE MIGRATION (decayed profile) — a second profile with an exponential
//        half-life on its volume; its value reacts to recent trade while the
//        anchored POC stays sticky. When the fast value crosses the anchored POC,
//        acceptance is shifting — a structural change built from the same data.
//      * REGIME + CALIBRATION — an efficiency/strength read for context, and a
//        past-only hit-rate of how often a stretch reverted toward value.
//    Distribution, mean, dispersion, migration and proof — one engine, because a
//    trader reads acceptance, fair value and extension together, not separately.
//
//  HOW TO READ IT
//    * The histogram is the anchored volume profile; the orange POC line is its peak.
//    * The shaded band is the value area (VAH/VAL); HVN bins are tinted as
//      acceptance, LVN bins as rejection.
//    * The mean line is the anchored VWAP, with ±stretch rails marking extension.
//    * The amber fast line is the decayed (recent) value; the green/red fill
//      between it and the POC is the value migration. Triangles mark the cross.
//    * Circles mark ±σ stretches. The legend names every level with live values.
//    * The table reads POC, VWAP, skew, migration, value area, extension (z), the
//      node price is sitting in, a verdict, the past-only reversion rate, and a
//      data-health line.
//    Context for your own decision — not a signal to act on. Manage your risk.
//
//  UNIVERSAL — WORKS ON ANY ASSET
//    The price SOURCE for the mean is selectable in settings, so the engine runs
//    on any market (futures, indices, FX, crypto, stocks). The profile is built
//    from each bar's true high-low range (and lower-timeframe bars where
//    available, for accuracy). Volume-at-price needs volume; where a symbol
//    reports none, volume is borrowed from a reference symbol. All thresholds are
//    ATR/σ-relative, so nothing is tied to one instrument's price scale.
//
//  ORIGINALITY
//    Not a static volume profile: it pairs an anchored profile with the anchored
//    VWAP (mode vs mean), adds a decayed-profile VALUE MIGRATION read against the
//    sticky POC, uses robust percentile HVN/LVN thresholds, refines the profile
//    with lower-timeframe data, and calibrates its stretch signal per symbol.
//
//  LIMITATIONS (honest)
//    Swing anchors confirm only after the right-pivot length in bars (the profile
//    is seeded back to the true pivot bar); in Dual mode it re-bases when a newer
//    swing confirms. Lower-timeframe refinement is limited
//    by available intrabar history and is disabled when volume is borrowed. The
//    decayed profile is heavier than a static one. Calibration is past-only and
//    descriptive. Everything here is probabilistic context, not prediction.
//
//  DISCLAIMER
//    Study / indicator for analysis and education only. NOT a strategy, NOT a
//    recommendation, NOT financial advice. It places no orders and guarantees no
//    outcome. Markets carry risk. Do your own research and manage your own risk.
//    Update note: this version anchors automatically; manual-anchor settings from
//    earlier versions no longer apply and are no longer required.
// ==========================================================================

//@version=6
indicator("Anchored Volume Profile Confluence — POC, Value Area, HVN/LVN & Value Migration", "AVP-C", overlay = true, max_boxes_count = 300, max_lines_count = 20, max_labels_count = 20, max_bars_back = 2000)

// ───────────────────────────── INPUTS ──────────────────────────────────────
gSrc = "Data Source (any asset)"
src          = input.source(hlc3, "Source", group = gSrc)
volBorrowSym = input.symbol("", "Borrow volume from symbol (no-volume fix)", group = gSrc)

gAnc = "Anchor"
mode       = input.string("Dual (auto)", "Anchor mode", options = ["Session", "Swing Low", "Swing High", "Dual (auto)"], group = gAnc, tooltip = "Auto-anchors with no manual setup. Dual (auto) anchors to the most recent significant swing (low or high) and re-anchors as new structure forms.")
pivotLeft  = input.int(55, "Swing pivot left length (Fib)",  options = [21, 34, 55, 89], group = gAnc)
pivotRight = input.int(55, "Swing pivot right length (Fib)", options = [21, 34, 55, 89], group = gAnc, tooltip = "A swing confirms this many bars after it forms; the profile is seeded back to the true pivot bar.")

gProf = "Profile"
rowsPerATR = input.float(4.0, "Resolution (rows per ATR)", minval = 1.0, maxval = 12.0, step = 0.5, group = gProf, tooltip = "Bin height = ATR / this. Higher = finer (and heavier).")
vaPctIn    = input.float(70, "Value area %", minval = 50, maxval = 95, group = gProf)
useLTF     = input.bool(true, "LTF intrabar refinement (anchored)", group = gProf, tooltip = "Builds the anchored profile from lower-timeframe bars where available (more accurate). Falls back to bar-range on older bars / no intrabar data. Disabled when volume is borrowed.")
ltfRes     = input.timeframe("1", "  LTF resolution", group = gProf)
useRobustNodes = input.bool(true, "Robust node thresholds (percentile)", group = gProf, tooltip = "ON: HVN/LVN from the percentile of bin volumes (self-scaling). OFF: fixed % of the POC bin.")
hvnPctIn   = input.float(80, "HVN threshold (percentile / % of POC)", minval = 50, maxval = 100, group = gProf)
lvnPctIn   = input.float(20, "LVN threshold (percentile / % of POC)", minval = 1, maxval = 50, group = gProf)
widthBars  = input.int(60, "Profile width (bars)", minval = 10, maxval = 200, group = gProf)
showProfile= input.bool(true, "Draw profile histogram", group = gProf)
showVwapOv = input.bool(true, "Overlay anchored VWAP (mean)", group = gProf)
showVAfill = input.bool(true, "Shade value area", group = gProf)

gMig = "Value Migration (decayed profile)"
showMig  = input.bool(true, "Show value migration", group = gMig, tooltip = "Maintains a decayed (half-life) profile and compares its value to the anchored POC. Heavier than a static profile.")
profHL   = input.int(15, "Profile half-life (bars)", minval = 3, maxval = 200, group = gMig)
fastMode = input.string("VA-mid (smooth)", "Fast line", options = ["VA-mid (smooth)", "Raw POC (mode)"], group = gMig)

gSig = "Signals & Regime"
stretchZ  = input.float(2.0, "Stretch threshold (σ / z-score)", minval = 1.0, maxval = 4.0, step = 0.5, group = gSig)

gCal = "Calibration (past-only)"
calEnable  = input.bool(true, "Track stretch reversion follow-through", group = gCal)
calHorizon = input.int(20, "Evaluation horizon (bars)", minval = 3, maxval = 100, group = gCal)
calMoveATR = input.float(1.0, "Min reversion (x ATR)", minval = 0.2, maxval = 4.0, step = 0.1, group = gCal)

gV = "Visuals"
themeMode = input.string("Auto (match chart)", "Theme", options = ["Auto (match chart)", "Dark", "Light"], group = gV)
bullCol   = input.color(#21dfac, "Bullish / acceptance", group = gV)
bearCol   = input.color(#df216d, "Bearish / rejection", group = gV)
pocCol    = input.color(#ffa600, "POC", group = gV)
vaCol     = input.color(#79c0ff, "Value area", group = gV)
fastCol   = input.color(#ffd166, "Fast line (migration)", group = gV)
showGlow  = input.bool(true, "Line glow", group = gV)
showLabels= input.bool(true, "On-chart level labels", group = gV)
showLegend= input.bool(true, "On-chart legend key", group = gV)
legendPos = input.string("Bottom Left", "Legend position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = gV)
showTable = input.bool(true, "Confluence table", group = gV)
showHealth= input.bool(true, "Data-health row", group = gV)
dashPosStr= input.string("Top Right", "Table position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = gV)
showId    = input.bool(true, "Identity strip", group = gV)

vaPct  = vaPctIn / 100.0
lam    = math.pow(0.5, 1.0 / profHL)

// ───────────────────────────── HELPERS ─────────────────────────────────────
f_luma(color c) => na(c) ? 0.0 : color.r(c) * 0.299 + color.g(c) * 0.587 + color.b(c) * 0.114
f_pos(string s) =>
    switch s
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        "Middle Right" => position.middle_right
        => position.top_right
f_wilson(int hits, int total) =>
    float lo = na
    float hi = na
    if total >= 5
        float p = hits / float(total)
        float z = 1.96
        float den = 1.0 + z * z / total
        float c = (p + z * z / (2.0 * total)) / den
        float h = z * math.sqrt(p * (1.0 - p) / total + z * z / (4.0 * total * total)) / den
        lo := math.max(0.0, c - h)
        hi := math.min(1.0, c + h)
    [lo, hi]
f_add(m, hh, ll, vv, orig, bw) =>
    if not na(bw) and bw > 0 and vv > 0 and not na(hh) and not na(ll)
        int b0 = int(math.floor((ll - orig) / bw))
        int b1 = int(math.floor((hh - orig) / bw))
        int span = b1 - b0 + 1
        if span > 0 and span <= 300
            float each = vv / span
            for b = b0 to b1
                map.put(m, b, (map.contains(m, b) ? map.get(m, b) : 0.0) + each)
        else
            int bm = int(math.floor(((hh + ll) * 0.5 - orig) / bw))
            map.put(m, bm, (map.contains(m, bm) ? map.get(m, bm) : 0.0) + vv)
f_scan(m) =>
    float tot = 0.0
    float mx = 0.0
    int pk = na
    int mn = na
    int mxk = na
    keys = map.keys(m)
    if array.size(keys) > 0
        for idx = 0 to array.size(keys) - 1
            int k = array.get(keys, idx)
            float v = map.get(m, k)
            tot += v
            if v > mx
                mx := v
                pk := k
            mn := idx == 0 ? k : math.min(mn, k)
            mxk := idx == 0 ? k : math.max(mxk, k)
    [tot, mx, pk, mn, mxk]
// bounded value-area walk on a map → [vahPrice, valPrice, upK, dnK]
f_va(m, pocK, tot, mnK, mxK, orig, bw, pct) =>
    float vah = na
    float val = na
    int up = pocK
    int dn = pocK
    if not na(pocK) and tot > 0 and not na(mnK)
        float acc = map.contains(m, pocK) ? map.get(m, pocK) : 0.0
        while acc < pct * tot and (up < mxK or dn > mnK)
            float vU = up < mxK ? (map.contains(m, up + 1) ? map.get(m, up + 1) : 0.0) : -1.0
            float vD = dn > mnK ? (map.contains(m, dn - 1) ? map.get(m, dn - 1) : 0.0) : -1.0
            if vU >= vD
                up := up + 1
                acc += math.max(vU, 0.0)
            else
                dn := dn - 1
                acc += math.max(vD, 0.0)
        vah := orig + (up + 1) * bw
        val := orig + dn * bw
    [vah, val, up, dn]

// ───────────────────────────── THEME ───────────────────────────────────────
_luma  = f_luma(chart.bg_color)
uiDark = themeMode == "Dark" ? true : themeMode == "Light" ? false : (na(chart.bg_color) or _luma < 140)
uiBull = bullCol
uiBear = bearCol
cPanel = uiDark ? color.rgb(10, 14, 22)    : color.rgb(244, 246, 248)
cSub   = uiDark ? color.rgb(22, 27, 34)    : color.rgb(233, 237, 242)
cAlt   = uiDark ? color.rgb(16, 20, 32)    : color.rgb(238, 241, 245)
cTxt   = uiDark ? color.rgb(226, 232, 240) : color.rgb(20, 26, 38)
cDim   = uiDark ? color.rgb(194, 203, 214) : color.rgb(96, 104, 116)
cFrame = uiDark ? color.rgb(43, 51, 64)    : color.rgb(196, 204, 212)
cBord  = uiDark ? color.rgb(43, 51, 64)    : color.rgb(210, 216, 224)
cHdr   = uiDark ? color.rgb(22, 29, 43)   : color.rgb(210, 224, 255)

// ───────────────────────────── VOLUME BORROW ───────────────────────────────
var bool nativeVolSeen = false
if volume > 0
    nativeVolSeen := true
useBorrow = str.length(volBorrowSym) > 0 and not nativeVolSeen
volBorrowResolved = str.length(volBorrowSym) > 0 ? volBorrowSym : syminfo.tickerid
volBorrowRaw = request.security(volBorrowResolved, timeframe.period, volume, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
volEff = useBorrow and not na(volBorrowRaw) ? volBorrowRaw : volume

// ───────────────────────────── LTF INTRABAR ────────────────────────────────
ltfP = request.security_lower_tf(syminfo.tickerid, ltfRes, hlc3)
ltfV = request.security_lower_tf(syminfo.tickerid, ltfRes, volume)

// ───────────────────────────── DATA HEALTH ─────────────────────────────────
var int hVolPresent = 0
var int hVolTotal = 0
if barstate.isconfirmed
    hVolTotal += 1
    hVolPresent += volume > 0 ? 1 : 0
hVolRatio = hVolTotal > 0 ? hVolPresent / float(hVolTotal) : 0.0
volCumAll = ta.cum(nz(volEff, 0.0))
hClass = syminfo.type == "stock" or syminfo.type == "fund" ? "equity" : syminfo.type == "futures" ? "futures" : syminfo.type == "index" ? "index" : (syminfo.type == "forex" or syminfo.type == "cfd") ? "fx/cfd" : syminfo.type == "crypto" ? "crypto" : "generic"
hHealth = not (volCumAll > 0) ? "no volume" : hVolRatio < 0.80 ? "vol gaps" : "ok"

// ───────────────────────────── PER-BAR + ANCHOR ────────────────────────────
srcVol  = src * volEff
srcVol2 = src * src * volEff
float atr = ta.atr(14)
float atrSafe = atr > 0 ? atr : close * 0.001

dailyT     = time("D")
newSession = na(dailyT[1]) ? true : dailyT != dailyT[1]
ph = ta.pivothigh(pivotLeft, pivotRight)
pl = ta.pivotlow(pivotLeft, pivotRight)
int  seedLen  = 0
bool resetNow = false
if mode == "Session"
    resetNow := newSession
    seedLen  := 0
else if mode == "Swing High"
    resetNow := not na(ph)
    seedLen  := pivotRight
else if mode == "Swing Low"
    resetNow := not na(pl)
    seedLen  := pivotRight
else
    resetNow := not na(ph) or not na(pl)
    seedLen  := pivotRight

// ───────────────────────────── ANCHORED VWAP (MEAN) + σ ────────────────────
seedPV  = math.sum(srcVol,  seedLen + 1)
seedV   = math.sum(volEff,  seedLen + 1)
seedPV2 = math.sum(srcVol2, seedLen + 1)
var float vNum  = na
var float vDen  = na
var float vNum2 = na
if resetNow
    vNum  := seedPV
    vDen  := seedV
    vNum2 := seedPV2
else if not na(vDen)
    vNum  := vNum  + srcVol
    vDen  := vDen  + volEff
    vNum2 := vNum2 + srcVol2
vwap    = na(vDen) ? na : vNum / vDen
sigma   = na(vDen) ? na : math.sqrt(math.max(vNum2 / vDen - vwap * vwap, 0.0))
started = not na(vwap)
float zScore = (started and sigma > 0) ? (src - vwap) / sigma : 0.0

// ───────────────────────────── REGIME ──────────────────────────────────────
float erNum = math.abs(close - close[20])
float erDen = math.sum(math.abs(close - close[1]), 20)
float er = erDen > 0 ? erNum / erDen : 0.0
[dpR, dmR, adxR] = ta.dmi(14, 14)
bool trending = er > 0.35 and adxR > 20
string regimeTxt = trending ? "Trending" : er < 0.2 ? "Choppy" : "Mixed"

// ───────────────────────────── PROFILE STATE ───────────────────────────────
var map<int, float> anchMap = map.new<int, float>()
var map<int, float> decMap  = map.new<int, float>()
var float originP = na
var float binW    = na
var float anchTot = 0.0
var float anchMax = 0.0
var int   anchPOCk = na
var int   anchMinK = na
var int   anchMaxK = na
var float decTot = 0.0
var float decMax = 0.0
var int   decPOCk = na
var int   decMinK = na
var int   decMaxK = na

ltfOk = useLTF and not useBorrow and array.size(ltfP) > 0

if barstate.isconfirmed
    if resetNow
        map.clear(anchMap)
        map.clear(decMap)
        originP := src
        binW    := math.max(atr, syminfo.mintick) / rowsPerATR
        for i = 0 to seedLen
            f_add(anchMap, high[i], low[i], volEff[i], originP, binW)
            if showMig
                f_add(decMap, high[i], low[i], volEff[i] * math.pow(lam, i), originP, binW)
        [at, am, ap, amn, amx] = f_scan(anchMap)
        anchTot := at
        anchMax := am
        anchPOCk := ap
        anchMinK := amn
        anchMaxK := amx
        if showMig
            [dt, dm, dp, dmn0, dmx0] = f_scan(decMap)
            decTot := dt
            decMax := dm
            decPOCk := dp
            decMinK := dmn0
            decMaxK := dmx0
    else if not na(binW)
        int cb0 = int(math.floor((low  - originP) / binW))
        int cb1 = int(math.floor((high - originP) / binW))
        int cspan = cb1 - cb0 + 1
        bool bigspan = cspan > 300 or cspan < 1
        int cmid = int(math.floor(((high + low) * 0.5 - originP) / binW))
        float ceach = bigspan ? volEff : volEff / cspan
        // anchored: LTF refinement if available, else bar-range
        if ltfOk
            for li = 0 to array.size(ltfP) - 1
                float lp = array.get(ltfP, li)
                float lv = array.get(ltfV, li)
                if not na(lp) and not na(lv) and lv > 0
                    int k = int(math.floor((lp - originP) / binW))
                    float nv = (map.contains(anchMap, k) ? map.get(anchMap, k) : 0.0) + lv
                    map.put(anchMap, k, nv)
                    anchTot += lv
                    if nv > anchMax
                        anchMax := nv
                        anchPOCk := k
                    anchMinK := na(anchMinK) ? k : math.min(anchMinK, k)
                    anchMaxK := na(anchMaxK) ? k : math.max(anchMaxK, k)
        else if bigspan
            float nv = (map.contains(anchMap, cmid) ? map.get(anchMap, cmid) : 0.0) + volEff
            map.put(anchMap, cmid, nv)
            anchTot += volEff
            if nv > anchMax
                anchMax := nv
                anchPOCk := cmid
            anchMinK := na(anchMinK) ? cmid : math.min(anchMinK, cmid)
            anchMaxK := na(anchMaxK) ? cmid : math.max(anchMaxK, cmid)
        else
            for b = cb0 to cb1
                float nv = (map.contains(anchMap, b) ? map.get(anchMap, b) : 0.0) + ceach
                map.put(anchMap, b, nv)
                anchTot += ceach
                if nv > anchMax
                    anchMax := nv
                    anchPOCk := b
                anchMinK := na(anchMinK) ? b : math.min(anchMinK, b)
                anchMaxK := na(anchMaxK) ? b : math.max(anchMaxK, b)
        // decayed: decay all bins, then bar-range add
        if showMig
            decTot := 0.0
            decMax := 0.0
            int dmn = na
            int dmx = na
            kd = map.keys(decMap)
            if array.size(kd) > 0
                for idx = 0 to array.size(kd) - 1
                    int k = array.get(kd, idx)
                    float v = map.get(decMap, k) * lam
                    map.put(decMap, k, v)
                    decTot += v
                    if v > decMax
                        decMax := v
                        decPOCk := k
                    dmn := idx == 0 ? k : math.min(dmn, k)
                    dmx := idx == 0 ? k : math.max(dmx, k)
            if bigspan
                float nv = (map.contains(decMap, cmid) ? map.get(decMap, cmid) : 0.0) + volEff
                map.put(decMap, cmid, nv)
                decTot += volEff
                if nv > decMax
                    decMax := nv
                    decPOCk := cmid
                dmn := na(dmn) ? cmid : math.min(dmn, cmid)
                dmx := na(dmx) ? cmid : math.max(dmx, cmid)
            else
                for b = cb0 to cb1
                    float nv = (map.contains(decMap, b) ? map.get(decMap, b) : 0.0) + ceach
                    map.put(decMap, b, nv)
                    decTot += ceach
                    if nv > decMax
                        decMax := nv
                        decPOCk := b
                    dmn := na(dmn) ? b : math.min(dmn, b)
                    dmx := na(dmx) ? b : math.max(dmx, b)
            decMinK := dmn
            decMaxK := dmx

// ───────────────────────────── PER-BAR LEVELS (series) ─────────────────────
float anchPOC = (started and not na(anchPOCk) and not na(binW)) ? originP + (anchPOCk + 0.5) * binW : na
[anchVAH, anchVAL, vaUpK, vaDnK] = f_va(anchMap, anchPOCk, anchTot, anchMinK, anchMaxK, originP, binW, vaPct)

float decRawPOC = (showMig and not na(decPOCk) and not na(binW)) ? originP + (decPOCk + 0.5) * binW : na
[decVAH, decVAL, decUpK, decDnK] = f_va(decMap, decPOCk, decTot, decMinK, decMaxK, originP, binW, vaPct)
float decVAmid = (na(decVAH) or na(decVAL)) ? na : (decVAH + decVAL) * 0.5
float fastLine = fastMode == "Raw POC (mode)" ? decRawPOC : decVAmid
float migration = (na(fastLine) or na(anchPOC)) ? na : fastLine - anchPOC
migUp = ta.crossover(fastLine, anchPOC)
migDn = ta.crossunder(fastLine, anchPOC)

// ───────────────────────────── STRETCH + CALIBRATION ───────────────────────
stretchUp = started and zScore >= stretchZ
stretchDn = started and zScore <= -stretchZ
newStretchUp = stretchUp and not stretchUp[1]
newStretchDn = stretchDn and not stretchDn[1]
var int srTot = 0
var int srHit = 0
var int[] srBar = array.new_int(0)
var float[] srRef = array.new_float(0)
var int[] srDir = array.new_int(0)
if calEnable and barstate.isconfirmed and (newStretchUp or newStretchDn)
    array.push(srBar, bar_index)
    array.push(srRef, close)
    array.push(srDir, newStretchUp ? -1 : 1)
if calEnable and array.size(srBar) > 0
    int j = 0
    while j < array.size(srBar)
        if bar_index - array.get(srBar, j) >= calHorizon
            float p0 = array.get(srRef, j)
            int dr = array.get(srDir, j)
            float mv = close - p0
            bool hit = dr == 1 ? mv >= calMoveATR * atrSafe : mv <= -calMoveATR * atrSafe
            srTot += 1
            srHit += hit ? 1 : 0
            array.remove(srBar, j)
            array.remove(srRef, j)
            array.remove(srDir, j)
        else
            j += 1
    while array.size(srBar) > 300
        array.shift(srBar)
        array.shift(srRef)
        array.shift(srDir)

// ───────────────────────────── PLOTTED LEVELS (legend + glow + fills) ──────
// Value area band (shaded) — named in legend
pVAH = plot(started ? anchVAH : na, "VAH", color.new(vaCol, 0), 1)
pVAL = plot(started ? anchVAL : na, "VAL", color.new(vaCol, 0), 1)
fill(pVAH, pVAL, color.new(vaCol, showVAfill ? 91 : 100), "Value area")

// Anchored VWAP (mean) + glow
bull     = na(vwap) or na(vwap[1]) ? true : vwap >= vwap[1]
trendCol = bull ? uiBull : uiBear
vcore = showVwapOv and started ? vwap : na
plot(vcore, "VWAP glow", color.new(trendCol, showGlow ? 82 : 100), 6, display = display.pane)
plot(vcore, "Anchored VWAP (mean)", showVwapOv ? trendCol : na, 2)
plot(showVwapOv and started ? vwap + stretchZ * sigma : na, "+stretch", color.new(cDim, 60), 1)
plot(showVwapOv and started ? vwap - stretchZ * sigma : na, "-stretch", color.new(cDim, 60), 1)

// POC (mode) + glow  — also the slow reference for migration
plot(started ? anchPOC : na, "POC glow", color.new(pocCol, showGlow ? 78 : 100), 7, display = display.pane)
pPOC = plot(started ? anchPOC : na, "POC (mode)", color.new(pocCol, 0), 2)

// Fast value line (decayed) + glow, with green/red migration fill vs POC
plot(showMig and started ? fastLine : na, "Fast glow", color.new(fastCol, showGlow ? 80 : 100), 6, display = display.pane)
pFast = plot(showMig and started ? fastLine : na, "Fast value (migration)", color.new(fastCol, 0), 2)
plot(showMig and fastMode == "VA-mid (smooth)" and not na(decRawPOC) ? decRawPOC : na, "Decayed raw POC", color.new(fastCol, 55), 1, plot.style_circles)
fill(pPOC, pFast, color.new(migration >= 0 ? uiBull : uiBear, 86), "Value migration")

// markers
plotshape(showMig and started and migUp, "Value migrates ↑", shape.triangleup,   location.belowbar, color.new(uiBull, 0), size = size.small)
plotshape(showMig and started and migDn, "Value migrates ↓", shape.triangledown, location.abovebar, color.new(uiBear, 0), size = size.small)
plotshape(newStretchUp, "Stretch ↑", shape.circle, location.abovebar, color.new(#b5179e, 0), size = size.tiny)
plotshape(newStretchDn, "Stretch ↓", shape.circle, location.belowbar, color.new(#b5179e, 0), size = size.tiny)

if resetNow and mode != "Session"
    line.new(bar_index - seedLen, low, bar_index - seedLen, high, extend = extend.both, color = color.new(cDim, 40), style = line.style_dotted)

// ───────────────────────────── HISTOGRAM RENDER (throttled) ────────────────
var box[]   pBoxes = array.new<box>()
var label[] pLabs  = array.new<label>()
var string nodeTxt = "—"
var string verdictTxt = "—"

bool doRender = barstate.islast and (barstate.isconfirmed or barstate.isnew)
if doRender and started
    if array.size(pBoxes) > 0
        for k = 0 to array.size(pBoxes) - 1
            box.delete(array.get(pBoxes, k))
        array.clear(pBoxes)
    if array.size(pLabs) > 0
        for k = 0 to array.size(pLabs) - 1
            label.delete(array.get(pLabs, k))
        array.clear(pLabs)
    keys = map.keys(anchMap)
    if array.size(keys) > 0 and not na(binW) and not na(anchMinK)
        nzVol = array.new_float(0)
        for idx = 0 to array.size(keys) - 1
            array.push(nzVol, map.get(anchMap, array.get(keys, idx)))
        bool robustOK = useRobustNodes and array.size(nzVol) >= 5
        float hvnThr = robustOK ? array.percentile_linear_interpolation(nzVol, hvnPctIn) : (hvnPctIn / 100.0) * anchMax
        float lvnThr = robustOK ? array.percentile_linear_interpolation(nzVol, lvnPctIn) : (lvnPctIn / 100.0) * anchMax
        int rng = anchMaxK - anchMinK
        int rightX = bar_index + 2
        if showProfile and rng <= 280
            for kk = anchMinK to anchMaxK
                float vv = map.contains(anchMap, kk) ? map.get(anchMap, kk) : 0.0
                if vv > 0
                    float ratio = anchMax > 0 ? vv / anchMax : 0.0
                    int wb = int(math.round(ratio * widthBars))
                    if wb > 0
                        float yb = originP + kk * binW
                        bool inVA = not na(vaUpK) and kk >= vaDnK and kk <= vaUpK
                        color c = kk == anchPOCk ? color.new(pocCol, 12) : vv >= hvnThr ? color.new(uiBull, 55) : vv <= lvnThr ? color.new(uiBear, 50) : inVA ? color.new(vaCol, 70) : color.new(cDim, 70)
                        array.push(pBoxes, box.new(rightX - wb, yb + binW, rightX, yb, border_color = color.new(cDim, 88), bgcolor = c))
        if showLabels
            array.push(pLabs, label.new(bar_index + 9, anchPOC, "POC " + str.tostring(math.round_to_mintick(anchPOC)), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(pocCol, 10), textcolor = color.white, size = size.small))
            if not na(anchVAH)
                array.push(pLabs, label.new(bar_index + 9, anchVAH, "VAH " + str.tostring(math.round_to_mintick(anchVAH)), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(vaCol, 20), textcolor = color.white, size = size.small))
                array.push(pLabs, label.new(bar_index + 9, anchVAL, "VAL " + str.tostring(math.round_to_mintick(anchVAL)), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(vaCol, 20), textcolor = color.white, size = size.small))
            if showVwapOv and not na(vwap)
                array.push(pLabs, label.new(bar_index + 9, vwap, "VWAP " + str.tostring(math.round_to_mintick(vwap)), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(trendCol, 20), textcolor = color.white, size = size.small))
            if showMig and not na(fastLine)
                array.push(pLabs, label.new(bar_index + 9, fastLine, "FAST " + str.tostring(math.round_to_mintick(fastLine)), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(fastCol, 15), textcolor = color.white, size = size.small))
        int curK = int(math.floor((close - originP) / binW))
        float curV = map.contains(anchMap, curK) ? map.get(anchMap, curK) : 0.0
        nodeTxt := curV >= hvnThr ? "HVN (acceptance)" : curV <= lvnThr ? "LVN (rejection)" : "normal"
        bool stretched = math.abs(zScore) >= stretchZ
        verdictTxt := stretched and curV <= lvnThr ? "stretched + LVN → reversion" : stretched and curV >= hvnThr ? "stretched + HVN → trap" : stretched ? "stretched · neutral node" : "inside value"

// ───────────────────────────── TABLE ───────────────────────────────────────
[srLo, srHi] = f_wilson(srHit, srTot)
var table t = table.new(f_pos(dashPosStr), 2, 11, border_width = 1, frame_width = 1)
if showTable and barstate.islast and started
    table.set_bgcolor(t, cPanel)
    table.set_frame_color(t, cFrame)
    table.set_border_color(t, cBord)
    string skew = na(anchPOC) or na(vwap) ? "—" : vwap > anchPOC ? "VWAP > POC (top-heavy)" : vwap < anchPOC ? "VWAP < POC (bottom-heavy)" : "balanced"
    string band = zScore >= stretchZ ? "stretched up" : zScore <= -stretchZ ? "stretched down" : zScore > 0 ? "upper half" : "lower half"
    string migTxt = not showMig or na(migration) ? "—" : (migration > 0 ? "▲ value rising " : migration < 0 ? "▼ value falling " : "· balanced ") + str.tostring(math.round_to_mintick(math.abs(migration)))
    color migC = not showMig or na(migration) ? cTxt : migration > 0 ? uiBull : migration < 0 ? uiBear : cDim
    string srTxt = srTot < 5 ? "warming up" : str.tostring(math.round(srHit * 100.0 / srTot)) + "%  [" + (na(srLo) ? "—" : str.tostring(math.round(srLo * 100)) + "-" + str.tostring(math.round(srHi * 100))) + "]"
    color vCol = str.contains(verdictTxt, "reversion") ? uiBull : str.contains(verdictTxt, "trap") ? uiBear : cTxt
    int rr = 0
    table.cell(t, 0, rr, "AVP  •  " + mode, text_color = #79c0ff, bgcolor = cHdr, text_size = size.small, text_halign = text.align_left)
    table.cell(t, 1, rr, regimeTxt, text_color = trending ? uiBull : cDim, bgcolor = cHdr, text_size = size.small, text_halign = text.align_right)
    rr += 1
    table.cell(t, 0, rr, "POC (mode)", text_color = cDim, text_size = size.small, bgcolor = cSub)
    table.cell(t, 1, rr, na(anchPOC) ? "—" : str.tostring(math.round_to_mintick(anchPOC)), text_color = pocCol, text_size = size.small, bgcolor = cSub)
    rr += 1
    table.cell(t, 0, rr, "VWAP (mean)", text_color = cDim, text_size = size.small, bgcolor = cAlt)
    table.cell(t, 1, rr, str.tostring(vwap, format.mintick), text_color = cTxt, text_size = size.small, bgcolor = cAlt)
    rr += 1
    table.cell(t, 0, rr, "Skew", text_color = cDim, text_size = size.small, bgcolor = cSub)
    table.cell(t, 1, rr, skew, text_color = cTxt, text_size = size.small, bgcolor = cSub)
    rr += 1
    table.cell(t, 0, rr, "Value migration", text_color = cDim, text_size = size.small, bgcolor = cAlt)
    table.cell(t, 1, rr, migTxt, text_color = migC, text_size = size.small, bgcolor = cAlt)
    rr += 1
    table.cell(t, 0, rr, "Value area H/L", text_color = cDim, text_size = size.small, bgcolor = cSub)
    table.cell(t, 1, rr, na(anchVAH) ? "—" : str.tostring(math.round_to_mintick(anchVAH)) + " / " + str.tostring(math.round_to_mintick(anchVAL)), text_color = cTxt, text_size = size.small, bgcolor = cSub)
    rr += 1
    table.cell(t, 0, rr, "Extension (z)", text_color = cDim, text_size = size.small, bgcolor = cAlt)
    table.cell(t, 1, rr, str.tostring(math.round(zScore * 100) / 100.0) + "σ · " + band, text_color = math.abs(zScore) >= stretchZ ? #b5179e : cTxt, text_size = size.small, bgcolor = cAlt)
    rr += 1
    table.cell(t, 0, rr, "Price node", text_color = cDim, text_size = size.small, bgcolor = cSub)
    table.cell(t, 1, rr, nodeTxt, text_color = str.contains(nodeTxt, "HVN") ? uiBull : str.contains(nodeTxt, "LVN") ? uiBear : cTxt, text_size = size.small, bgcolor = cSub)
    rr += 1
    table.cell(t, 0, rr, "Verdict", text_color = cDim, text_size = size.small, bgcolor = cAlt)
    table.cell(t, 1, rr, verdictTxt, text_color = vCol, text_size = size.small, bgcolor = cAlt)
    rr += 1
    table.cell(t, 0, rr, "Stretch reversion", text_color = cDim, text_size = size.small, bgcolor = cSub, tooltip = "Past-only: ±" + str.tostring(stretchZ) + "σ stretch reverting " + str.tostring(calMoveATR) + "x ATR within " + str.tostring(calHorizon) + " bars. Wilson 95% CI.")
    table.cell(t, 1, rr, srTxt, text_color = srTot < 5 ? cDim : cTxt, text_size = size.small, bgcolor = cSub)
    if showHealth
        rr += 1
        string dataTxt = hHealth + (useBorrow and not na(volBorrowRaw) ? " · borrowed" : ltfOk ? " · LTF" : "") + " · " + hClass
        table.cell(t, 0, rr, "Data", text_color = cDim, text_size = size.small, bgcolor = cAlt)
        table.cell(t, 1, rr, dataTxt, text_color = hHealth == "ok" ? uiBull : hHealth == "no volume" ? uiBear : cDim, text_size = size.small, bgcolor = cAlt)

// ───────────────────────────── LEGEND KEY (on-chart) ──────────────────────
var table legT = table.new(f_pos(legendPos), 1, 8, border_width = 1, frame_width = 1)
if showLegend and barstate.islast and started
    table.set_bgcolor(legT, cPanel)
    table.set_frame_color(legT, cFrame)
    table.set_border_color(legT, cBord)
    table.cell(legT, 0, 0, "LEGEND", text_color = #79c0ff, bgcolor = cHdr, text_size = size.small, text_halign = text.align_left)
    table.cell(legT, 0, 1, "● POC — most-traded price", text_color = pocCol, bgcolor = cSub, text_size = size.small, text_halign = text.align_left)
    table.cell(legT, 0, 2, "● VWAP — mean / fair value", text_color = trendCol, bgcolor = cAlt, text_size = size.small, text_halign = text.align_left)
    table.cell(legT, 0, 3, "● Fast — recent (decayed) value", text_color = fastCol, bgcolor = cSub, text_size = size.small, text_halign = text.align_left)
    table.cell(legT, 0, 4, "● VAH / VAL — value area", text_color = vaCol, bgcolor = cAlt, text_size = size.small, text_halign = text.align_left)
    table.cell(legT, 0, 5, "▲ green / ▼ red — value migration", text_color = cDim, bgcolor = cSub, text_size = size.small, text_halign = text.align_left)
    table.cell(legT, 0, 6, "HVN green · LVN red (histogram)", text_color = cDim, bgcolor = cAlt, text_size = size.small, text_halign = text.align_left)
    table.cell(legT, 0, 7, "○ magenta — ±σ stretch", text_color = #b5179e, bgcolor = cSub, text_size = size.small, text_halign = text.align_left)

// ───────────────────────────── IDENTITY STRIP ──────────────────────────────
var table idTbl = table.new(position.bottom_center, 1, 1)
if showId and barstate.islast
    table.cell(idTbl, 0, 0, "AVP-C  /  " + syminfo.ticker + "  " + timeframe.period + "  /  " + mode, text_color = cDim, text_size = size.small, text_halign = text.align_center, bgcolor = color.new(cPanel, 20))

// ───────────────────────────── ALERTS ──────────────────────────────────────
alertcondition(migUp, "Value migration up", "Decayed value crossed ABOVE anchored POC")
alertcondition(migDn, "Value migration down", "Decayed value crossed BELOW anchored POC")
alertcondition(newStretchUp, "Stretched above +σ", "Price stretched above the upper band")
alertcondition(newStretchDn, "Stretched below -σ", "Price stretched below the lower band")

// ───────────────────────────── EXP_* EXPORTS ───────────────────────────────
float srRate = srTot > 0 ? srHit / float(srTot) : na
int nodeCode = str.contains(nodeTxt, "HVN") ? 1 : str.contains(nodeTxt, "LVN") ? -1 : 0
int migState = na(migration) ? 0 : migration > 0 ? 1 : migration < 0 ? -1 : 0
plot(vwap,            "EXP_VWAPmean",  color = color.new(color.gray, 100), display = display.data_window)
plot(anchPOC,         "EXP_POC",       color = color.new(color.gray, 100), display = display.data_window)
plot(fastLine,        "EXP_FastValue", color = color.new(color.gray, 100), display = display.data_window)
plot(migration,       "EXP_Migration", color = color.new(color.gray, 100), display = display.data_window)
plot(migState,        "EXP_MigState",  color = color.new(color.gray, 100), display = display.data_window)
plot(anchVAH,         "EXP_VAH",       color = color.new(color.gray, 100), display = display.data_window)
plot(anchVAL,         "EXP_VAL",       color = color.new(color.gray, 100), display = display.data_window)
plot(zScore,          "EXP_ZScore",    color = color.new(color.gray, 100), display = display.data_window)
plot(nodeCode,        "EXP_PriceNode", color = color.new(color.gray, 100), display = display.data_window)
plot(nz(srRate, -1),  "EXP_ReversionRate", color = color.new(color.gray, 100), display = display.data_window)
````
