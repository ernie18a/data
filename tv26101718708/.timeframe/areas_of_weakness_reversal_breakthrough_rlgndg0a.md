# Areas of Weakness - Reversal & Breakthrough

- url: https://www.tradingview.com/script/RLGNdg0a-Areas-of-Weakness-Reversal-Breakthrough/
- type: indicator
- pine_id: PUB;7a8dff2b841940f08e83450ee4b5a136
- version: 1.0

## Description

[b]Areas of Weakness v2 — Reversal / Breakthrough Classification[/b]
[i]A volume profile-based structural analysis tool that identifies "Low-Volume Pockets" (LVP) — thinly traded price zones where liquidity is absent — and classifies them as either Reversal barriers (price likely to reject) or Breakthrough zones (price likely to accelerate). Combines market microstructure physics with regime detection to predict whether price will bounce or slice through volume gaps.[/i]
[b]What It Does[/b]
AOW-RB constructs a dynamic volume profile histogram and scans for "pockets" — consecutive price bins with abnormally low volume surrounded by high-volume "walls." When price approaches these liquidity voids, the indicator evaluates five structural factors to predict the likely outcome:
[list]
[*][b]Reversal Pockets[/b] (Orange zones): Strong volume walls on both sides, high touch density (price has tested this area before), HTF confluence, and mean-reverting Hurst regime suggest price will reject and return to high-volume nodes.
[*][b]Breakthrough Pockets[/b] (Purple zones): Imbalanced walls (vacuum effect), trending Hurst regime, low touch density, and momentum alignment suggest price will slice through the gap and continue toward the weaker wall side.
[/list]
[b]The Five Classification Pillars[/b]
[list]
[*][b]Wall Strength[/b]: The volume density in nodes immediately surrounding the pocket. Thick walls (high volume neighbors) contain price and force reversal; thin walls allow breakthrough.
[*][b]Vacuum Effect[/b]: Asymmetry between the wall on the approach side versus the far side. A strong near-wall with weak far-wall creates suction that pulls price through the void (breakthrough). Balanced walls create containment (reversal).
[*][b]Regime (Hurst Exponent)[/b]: Rescaled-range calculation determines if the market is in persistent (H > 0.5, trend continuation likely) or mean-reverting (H < 0.5, rejection likely) mode.
[*][b]HTF Confluence[/b]: Checks if the pocket aligns with Daily/Weekly support-resistance levels. HTF alignment increases the probability that the pocket acts as a reversal pivot rather than a breakthrough gap.
[*][b]Touch Depletion[/b]: Counts how many times price has visited the pocket recently. High touch density without penetration suggests a tested barrier (reversal); virgin pockets suggest breakthrough potential.
[/list]
[b]Key Features[/b]
[list]
[*][b]Dynamic Volume Profile[/b]: Bar-spread binning with optional recency weighting (exponential decay) prioritizes recent volume over historical, adapting to shifting market structure.
[*][b]Intelligent Pocket Detection[/b]: Uses local minima ratio and percentile thresholds (not just "zero volume") to identify statistically significant weakness areas that matter.
[*][b]Distance-Prioritized Selection[/b]: When multiple pockets exist, selects the nearest one to current price for both above and below zones, ensuring relevant signals only.
[*][b]Dual Confirmation Logic[/b]: Signals require both price entry into the zone AND momentum/volume confirmation (rising volume for breakthrough, falling velocity for reversal).
[*][b]Hurst Regime Background[/b]: Subtle background tinting indicates underlying market persistence (blue) or mean-reversion (orange) independent of specific pocket signals.
[*][b]Higher Timeframe Overlay[/b]: Displays HTF levels as crosses and uses them as confluence modifiers in the classification algorithm.
[/list]
[b]Inputs & Parameters[/b]
[i]Volume Profile[/i]
[list]
[*]Lookback Period: Bars to include in volume histogram (20–500).
[*]Resolution: Number of price rows/bins in the histogram (40–3000). Higher resolution finds smaller pockets but increases computation.
[*]Value Area %: Percentage of total volume to define the Value Area High/Low (VAH/VAL) boundaries around the POC.
[*]Recency Weighting: Toggle exponential decay favoring recent volume; Decay Factor controls the speed of historical fade (0.90–1.0).
[/list]
[i]Higher Timeframe[/i]
[list]
[*]HTF-1 / HTF-2: Select timeframe strings (e.g., "D", "W") for confluence levels.
[*]Enable toggles: Turn individual HTF layers on/off.
[/list]
[i]Volatility & Zone Width[/i]
[list]
[*]ATR Length: Calculation period for zone width.
[*]Zone Half-Width: Multiplier applied to ATR to create the visual thickness of POC/VA/HVN zones.
[*]Confluence Window: ATR multiplier determining how close a pocket must be to an HTF level to register as "confluence."
[/list]
[i]Low-Volume Pocket Detection[/i]
[list]
[*]Weakness Percentile: Volume level below which bins are considered "low volume" (1–50%).
[*]Local-Min Ratio: Pocket must be at least this ratio lower than neighboring bins (0.1–0.9).
[*]Min Pocket Width: Minimum pocket size in bins and ATR multiples to filter noise.
[*]Wall Scan Depth: Percentage of resolution used to measure surrounding wall volume (2–20%).
[/list]
[i]Reversal vs Breakthrough Classification[/i]
[list]
[*]Component Weights: Individual scaling (0–1) for Wall, Vacuum, Hurst, HTF, and Touch factors.
[*]Hurst Proxy Length: Lookback for rescaled-range calculation (20–500).
[*]Touch Count Window: Bars to look back when calculating touch density (20–1000).
[/list]
[i]Signal Filters[/i]
[list]
[*]Momentum Filter: Requires price to be above/below EMA for bullish/bearish signals.
[*]EMA Length: Period for momentum trend filter.
[*]Approach Velocity Filter: Requires ROC (rate of change) confirmation.
[*]ROC Length: Period for velocity calculation.
[*]Confirm on Bar Close: If true, signals only trigger on confirmed close inside zone; if false, triggers on wick penetration (faster, more false positives).
[/list]
[i]Visual Settings[/i]
[list]
[*]Zone toggles and color selectors for POC (blue), VA (grey), HVN-2 (orange), Reversal (orange-red), and Breakthrough (purple).
[*]HTF line visibility and color.
[/list]
[b]How to Read It[/b]
[list]
[*][b]POC Zone (Blue Fill)[/b]: High-volume node — price equilibrium. Purple tint indicates HTF confluence at this level.
[*][b]VA Zones (Grey Fill)[/b]: Value Area High and Low — standard deviation boundaries of accepted value.
[*][b]HVN-2 (Orange Fill)[/b]: Secondary high-volume node — lesser magnet than POC but significant support/resistance.
[*][b]Reversal Pockets (Orange/Red Fill)[/b]: Located above price (RevAbove) or below price (RevBelow). Expect price to reject when entering these.
[*][b]Breakthrough Pockets (Purple Fill)[/b]: Located above (BrkAbove) or below (BrkBelow) price. Expect acceleration through these.
[*][b]Signal Markers:[/b]
[list]
[*][b]Orange Diamond REV↓[/b]: Entered Reversal zone above price — expect rejection downward (short signal).
[*][b]Orange Diamond REV↑[/b]: Entered Reversal zone below price — expect rejection upward (long signal).
[*][b]Purple Triangle BRK↑[/b]: Entered Breakthrough zone above price — expect continuation upward (long signal).
[*][b]Purple Triangle BRK↓[/b]: Entered Breakthrough zone below price — expect continuation downward (short signal).
[/list]
[*][b]Background Tint:[/b] Light blue = Hurst > 0.6 (trending, persistence favors breakthroughs). Light orange = Hurst < 0.4 (mean-reverting, favors reversals). No tint = neutral regime.
[/list]
[b]Signal Types & Alerts[/b]
[list]
[*][b]Reversal SHORT (Rev Above)[/b]: Price enters a classified reversal pocket above current levels with falling momentum/volume. Alert message includes pocket bounds and classification scores.
[*][b]Reversal LONG (Rev Below)[/b]: Price enters a classified reversal pocket below current levels.
[*][b]Breakthrough LONG (Brk Above)[/b]: Price enters a breakthrough pocket above with rising volume and bullish momentum.
[*][b]Breakthrough SHORT (Brk Below)[/b]: Price enters a breakthrough pocket below with rising volume and bearish momentum.
[*][b]Pocket Filled Alerts:[/b] Fires when price completely traverses a pocket from entry to exit (other side), indicating the zone was absorbed.
[*][b]VA/POC Zone Entry:[/b] Optional alerts for entering standard volume profile levels.
[*][b]HTF Cross:[/b] Optional alerts for crossing higher timeframe levels.
[/list]
[b]Practical Usage Guidelines[/b]
[i]Mean-Reversion Trading[/i]
[list]
[*]Wait for price to enter an [b]orange[/b] Reversal pocket (RevAbove or RevBelow).
[*]Confirm Hurst background is [b]orange[/b] (H < 0.4) or neutral, indicating mean-reverting regime.
[*]Confirm signal marker appears (REV↓ or REV↑).
[*]Enter counter-trend position targeting the nearest POC or HVN-2 node.
[*]Stop-loss beyond the far wall of the pocket.
[/list]
[i]Momentum/Breakout Trading[/i]
[list]
[*]Wait for price to enter a [b]purple[/b] Breakthrough pocket (BrkAbove or BrkBelow).
[*]Confirm Hurst background is [b]blue[/b] (H > 0.6), indicating persistent regime.
[*]Confirm rising volume (volRatio > 1.2) and momentum alignment (price > EMA for longs).
[*]Enter with-trend position expecting acceleration to the next HTF level or volume node.
[*]Trail stop aggressively as breakthrough pockets fill quickly.
[/list]
[i]Confluence Scalping[/i]
[list]
[*]When POC or HVN-2 zones overlap with HTF lines (indicated by purple tint in POC fill), these become high-probability reversal targets.
[*]Use Reversal signals at these confluences for tight-risk scalp entries.
[/list]
[b]Important Notes[/b]
[list]
[*][b]Classification Logic:[/b] The script uses a sigmoid-normalized wall ratio (2/(1+exp(-0.5×wr)) - 1) to squash extreme values into a comparable 0–1 range for fair weighting against other factors.
[*][b]Vacuum Calculation:[/b] Vacuum effect = 1 - min(wall_approach / wall_far, 1). A vacuum exists when the wall on the approach side is much thicker than the far side, creating pressure differential that sucks price through.
[*][b]Hurst Proxy:[/b] Uses simplified rescaled-range (R/S) over the specified window. Values clamped to 0.01–0.99 to prevent numerical errors. This is an approximation, not exact Hurst calculation.
[*][b]Recency Weighting:[/b] When enabled, volume from i bars ago is multiplied by decay^i. This creates an exponentially weighted volume profile where yesterday's volume matters more than volume from 50 bars ago. Useful for adapting to recent structural shifts.
[*][b]Touch Density:[/b] Pre-computed per bar by mapping recent closes to price bins and counting hits. Normalized by window length to give a 0–1 density score. High density = tested level (reversal likely); Low density = virgin level (breakthrough likely).
[*][b]Bar-Spread Binning:[/b] Unlike standard VP that uses close prices, this distributes each bar's volume across all price levels touched (high to low) to capture true traded volume distribution.
[*][b]No Repainting:[/b] Uses confirmed HTF data with gaps=off and lookahead=off. Signal confirmation depends on "Confirm on Bar Close" setting — when enabled, signals are lagged by 1 bar but guaranteed non-repainting.
[/list]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Cmo22

//@version=6
indicator("Areas of Weakness v2 – Reversal / Breakthrough Classification",
     shorttitle="AOW-RB", overlay=true, max_bars_back=2000,
     max_lines_count=200, max_boxes_count=200, max_labels_count=200)

// ─────────────────────────────────────────────────────────────────────────────
// UDT
// ─────────────────────────────────────────────────────────────────────────────
type LVPResult
    float lo             = na
    float hi             = na
    float mid            = na
    float depth          = na
    float farWall        = na
    float nearWall       = na
    float wallRatio      = na
    float vacuumRatio    = na
    float touchDensity   = na
    float reversalScore  = na
    float breakthroughScore = na
    bool  isReversal     = false

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS — Core VP
// ─────────────────────────────────────────────────────────────────────────────
grp_vp = "Volume Profile"
vpLookback      = input.int(50,  "Lookback Period",       minval=20,   group=grp_vp)
vpResolution    = input.int(100,   "Resolution (Rows)",     minval=40, maxval=3000, step=10, group=grp_vp)
vpValueAreaPct  = input.float(90., "Value Area %",          minval=1, maxval=100, step=1, group=grp_vp)
vpRecencyWeight = input.bool(true, "Recency Weighting",     group=grp_vp)
vpRecencyDecay  = input.float(0.99,"Recency Decay Factor",  minval=0.90, maxval=1.0, step=0.005, group=grp_vp)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS — HTF Confluence
// ─────────────────────────────────────────────────────────────────────────────
grp_htf = "Higher Timeframe"
htf1_tf      = input.timeframe("D", "HTF-1",          group=grp_htf)
htf1_on      = input.bool(true,     "Enable HTF-1",   group=grp_htf)
htf2_tf      = input.timeframe("W", "HTF-2",          group=grp_htf)
htf2_on      = input.bool(false,    "Enable HTF-2",   group=grp_htf)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS — Volatility / Zone Width
// ─────────────────────────────────────────────────────────────────────────────
grp_vol = "Volatility & Zone Width"
atrLen       = input.int(14,     "ATR Length",              minval=1,  group=grp_vol)
zoneATRMult  = input.float(0.25, "Zone Half-Width (×ATR)", minval=0.01, step=0.05, group=grp_vol)
confATRPct   = input.float(0.5,  "Confluence Window (×ATR)", minval=0.1, step=0.1, group=grp_vol)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS — LVP Detection
// ─────────────────────────────────────────────────────────────────────────────
grp_lvp = "Low-Volume Pocket Detection"
weakPctile   = input.float(35, "Weakness Percentile %",     minval=1, maxval=50, step=1,    group=grp_lvp)
weakRatio    = input.float(0.55,"Local-Min Ratio (vs nbrs)", minval=0.1, maxval=0.9, step=0.05, group=grp_lvp)
minPktBins   = input.int(5,     "Min Pocket Width (bins)",   minval=1, maxval=30,   group=grp_lvp)
minPktATR    = input.float(0.10,"Min Pocket Width (ATR)",    minval=0.0, step=0.05, group=grp_lvp)
wallLookMult = input.float(0.05,"Wall Scan Depth (% of res)",minval=0.02, maxval=0.20, step=0.01, group=grp_lvp)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS — Classification Weights
// ─────────────────────────────────────────────────────────────────────────────
grp_cls = "Reversal vs Breakthrough Classification"
wWall    = input.float(0.30, "Wall Strength Weight",    minval=0, maxval=1, step=0.05, group=grp_cls)
wVacuum  = input.float(0.25, "Vacuum Effect Weight",    minval=0, maxval=1, step=0.05, group=grp_cls)
wHurst   = input.float(0.15, "Regime (Hurst) Weight",   minval=0, maxval=1, step=0.05, group=grp_cls)
wHTF     = input.float(0.15, "HTF Confluence Weight",   minval=0, maxval=1, step=0.05, group=grp_cls)
wTouch   = input.float(0.15, "Touch Depletion Weight",  minval=0, maxval=1, step=0.05, group=grp_cls)
hurstLen = input.int(100,    "Hurst Proxy Length",       minval=20, maxval=500, group=grp_cls)
touchWin = input.int(200,    "Touch Count Window (bars)",minval=20, maxval=1000, group=grp_cls)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS — Signal Filters
// ─────────────────────────────────────────────────────────────────────────────
grp_sig = "Signal Filters"
useMom       = input.bool(true, "Momentum Filter (EMA)", group=grp_sig)
emaLen       = input.int(34,    "EMA Length",            minval=1, group=grp_sig)
useROC       = input.bool(true, "Approach Velocity Filter", group=grp_sig)
rocLen       = input.int(5,     "ROC Length",            minval=1, group=grp_sig)
confirmClose = input.bool(true, "Confirm on Bar Close",  group=grp_sig)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS — Visuals
// ─────────────────────────────────────────────────────────────────────────────
grp_vis = "Visual Settings"
showVAZones    = input.bool(true, "Show POC / VA Zones",     group=grp_vis)
pocColor       = input.color(color.new(color.blue,   0),  "POC Zone",          group=grp_vis)
vaClr          = input.color(color.new(color.gray,  85),  "Value Area Zone",   group=grp_vis)
showHVN2       = input.bool(true, "Show Secondary HVN",      group=grp_vis)
hvnClr         = input.color(color.new(color.orange,85),  "HVN-2 Zone",        group=grp_vis)
revAboveClr    = input.color(color.new(#FF6D00, 70),      "Reversal Above",    group=grp_vis)
revBelowClr    = input.color(color.new(#FF6D00, 70),      "Reversal Below",    group=grp_vis)
brkAboveClr    = input.color(color.new(#AA00FF, 70),      "Breakthrough Above",group=grp_vis)
brkBelowClr    = input.color(color.new(#AA00FF, 70),      "Breakthrough Below",group=grp_vis)
showHTFLines   = input.bool(true, "Show HTF Lines",          group=grp_vis)
htfLineClr     = input.color(color.new(color.teal, 50),   "HTF Line Color",    group=grp_vis)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS — Alerts
// ─────────────────────────────────────────────────────────────────────────────
grp_alrt = "Alerts"
alertOn       = input.bool(true,  "Enable Alerts",          group=grp_alrt)
alertRevEntry = input.bool(true,  "Alert: Reversal Entry",  group=grp_alrt)
alertBrkEntry = input.bool(true,  "Alert: Breakthrough Entry", group=grp_alrt)
alertFill     = input.bool(true,  "Alert: Pocket Filled",   group=grp_alrt)
alertVA       = input.bool(false, "Alert: VA Zone Enter",   group=grp_alrt)
alertHTFx     = input.bool(false, "Alert: HTF Cross",       group=grp_alrt)
alertFreqOpt  = input.string("Once Per Bar Close", "Frequency",
     options=["All","Once Per Bar","Once Per Bar Close"], group=grp_alrt)
alertFreq     = alertFreqOpt == "All" ? alert.freq_all :
                 alertFreqOpt == "Once Per Bar" ? alert.freq_once_per_bar :
                 alert.freq_once_per_bar_close

// ─────────────────────────────────────────────────────────────────────────────
// SAFE ARRAY HELPERS
// ─────────────────────────────────────────────────────────────────────────────
f_safeGet(array<float> arr, int idx) =>
    int sz = arr.size()
    idx >= 0 and idx < sz ? arr.get(idx) : 0.0

f_safeGetNa(array<float> arr, int idx) =>
    int sz = arr.size()
    idx >= 0 and idx < sz ? arr.get(idx) : na

f_safeSet(array<float> arr, int idx, float val) =>
    int sz = arr.size()
    if idx >= 0 and idx < sz
        arr.set(idx, val)

f_clampIdx(int idx, int sz) =>
    math.max(0, math.min(idx, sz - 1))

// ─────────────────────────────────────────────────────────────────────────────
// CORE SERIES
// ─────────────────────────────────────────────────────────────────────────────
atrVal   = ta.atr(atrLen)
zoneHalf = nz(atrVal) * zoneATRMult
confWin  = nz(atrVal) * confATRPct
emaTrend = ta.ema(close, emaLen)
rocVal   = ta.roc(close, rocLen)

// Minimum bars before full computation
bool dataReady = bar_index >= 50 and not na(atrVal) and not na(close) and atrVal > 0

// ─── Hurst proxy (rescaled range) ───
f_hurst(float src, int len) =>
    if bar_index < len or na(src)
        0.5
    else
        float m = nz(ta.sma(src, len))
        float s = nz(ta.stdev(src, len))
        float maxC = 0.0
        float minC = 0.0
        float cum  = 0.0
        int   n    = math.min(len, bar_index + 1)
        for i = 0 to n - 1
            cum += nz(src[i]) - m
            maxC := math.max(maxC, cum)
            minC := math.min(minC, cum)
        float R  = maxC - minC
        float rs = s > 0 ? R / s : 0.0
        float h  = rs > 0 and n > 2 ? math.log(rs) / math.log(n * 0.5) : 0.5
        math.max(0.01, math.min(0.99, h))

hurstH = f_hurst(close, hurstLen)

// ─── HTF Levels ───
f_htfLevels(string tf, bool on) =>
    float h = na
    float l = na
    if on
        h := request.security(syminfo.tickerid, tf, high[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
        l := request.security(syminfo.tickerid, tf, low[1],  gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
    [h, l]

[htf1H, htf1L] = f_htfLevels(htf1_tf, htf1_on)
[htf2H, htf2L] = f_htfLevels(htf2_tf, htf2_on)

htfArr = array.new<float>()
if htf1_on and not na(htf1H)
    htfArr.push(htf1H)
if htf1_on and not na(htf1L)
    htfArr.push(htf1L)
if htf2_on and not na(htf2H)
    htfArr.push(htf2H)
if htf2_on and not na(htf2L)
    htfArr.push(htf2L)

f_nearHTF(float level, float window) =>
    bool hit = false
    if not na(level) and not na(window) and htfArr.size() > 0
        for i = 0 to htfArr.size() - 1
            float hv = htfArr.get(i)
            if not na(hv) and math.abs(level - hv) <= window
                hit := true
                break
    hit

// ═════════════════════════════════════════════════════════════════════════════
// VOLUME PROFILE — bar-spread binning
// ═════════════════════════════════════════════════════════════════════════════
var volBins   = array.new<float>(vpResolution, 0.0)
var priceBins = array.new<float>(vpResolution, 0.0)

// Return values via series assignments
var float pocPx   = na
var float vahPx   = na
var float valPx   = na
var float hvn2Px  = na

if dataReady
    // ── Bounds ──
    int actualLB = math.min(vpLookback, bar_index + 1)
    float minPx  = ta.lowest(low, actualLB)
    float maxPx  = ta.highest(high, actualLB)

    if not na(minPx) and not na(maxPx)
        float rng  = math.max(maxPx - minPx, syminfo.mintick * 10)
        float bSz  = rng / vpResolution

        // ── Reset bins ──
        for j = 0 to vpResolution - 1
            priceBins.set(j, minPx + (j + 0.5) * bSz)
            volBins.set(j, 0.0)

        float totVol = 0.0

        // ── Fill histogram with bar-spread distribution ──
        for i = 0 to actualLB - 1
            float bL = nz(low[i],  minPx)
            float bH = nz(high[i], maxPx)
            float bV = nz(volume[i])
            if bV > 0 and bH >= bL
                float w  = vpRecencyWeight ? math.pow(vpRecencyDecay, float(i)) : 1.0
                float eV = bV * w
                float rawLo = (bL - minPx) / bSz
                float rawHi = (bH - minPx) / bSz
                if not na(rawLo) and not na(rawHi)
                    int lo_bin = f_clampIdx(int(math.floor(rawLo)), vpResolution)
                    int hi_bin = f_clampIdx(int(math.floor(rawHi)), vpResolution)
                    int span   = hi_bin - lo_bin + 1
                    float vPer = span > 0 ? eV / span : eV
                    for b = lo_bin to hi_bin
                        f_safeSet(volBins, b, f_safeGet(volBins, b) + vPer)
                    totVol += eV

        // ── POC & HVN-2 ──
        float maxV = 0.0
        float maxV2 = 0.0
        int   pocIdx = -1
        int   hvn2Idx = -1
        for j = 0 to vpResolution - 1
            float vj = f_safeGet(volBins, j)
            if vj > maxV
                maxV2   := maxV
                hvn2Idx := pocIdx
                maxV    := vj
                pocIdx  := j
            else if vj > maxV2
                maxV2   := vj
                hvn2Idx := j

        pocPx  := pocIdx >= 0 and pocIdx < vpResolution ? priceBins.get(pocIdx) : na
        hvn2Px := hvn2Idx >= 0 and hvn2Idx < vpResolution and hvn2Idx != pocIdx ? priceBins.get(hvn2Idx) : na

        // ── Value Area ──
        float target = totVol * (vpValueAreaPct / 100.0)
        float cum    = pocIdx >= 0 ? maxV : 0.0
        int   vaLo   = pocIdx
        int   vaHi   = pocIdx
        if pocIdx >= 0
            int safety = 0
            while cum < target and (vaLo > 0 or vaHi < vpResolution - 1) and safety < vpResolution
                safety += 1
                float below = vaLo > 0               ? f_safeGet(volBins, vaLo - 1) : 0.0
                float above = vaHi < vpResolution - 1 ? f_safeGet(volBins, vaHi + 1) : 0.0
                if below == 0.0 and above == 0.0
                    break
                if below > above
                    vaLo -= 1
                    cum  += below
                else
                    vaHi += 1
                    cum  += above

        valPx := vaLo >= 0 and vaLo < vpResolution ? f_safeGetNa(priceBins, vaLo) : na
        vahPx := vaHi >= 0 and vaHi < vpResolution ? f_safeGetNa(priceBins, vaHi) : na

// ═════════════════════════════════════════════════════════════════════════════
// LVP DETECTION + WALL ANALYSIS + CLASSIFICATION
// ═════════════════════════════════════════════════════════════════════════════

// Output series (flat floats — no UDT in plot paths)
var float revAboveLo  = na, var float revAboveHi  = na
var float revBelowLo  = na, var float revBelowHi  = na
var float brkAboveLo  = na, var float brkAboveHi  = na
var float brkBelowLo  = na, var float brkBelowHi  = na
var float revAboveRevS = na, var float revAboveBrkS = na
var float revBelowRevS = na, var float revBelowBrkS = na
var float brkAboveRevS = na, var float brkAboveBrkS = na
var float brkBelowRevS = na, var float brkBelowBrkS = na

if dataReady
    // Reset each bar
    revAboveLo := na, revAboveHi := na, revAboveRevS := na, revAboveBrkS := na
    revBelowLo := na, revBelowHi := na, revBelowRevS := na, revBelowBrkS := na
    brkAboveLo := na, brkAboveHi := na, brkAboveRevS := na, brkAboveBrkS := na
    brkBelowLo := na, brkBelowHi := na, brkBelowRevS := na, brkBelowBrkS := na

    int binCount = volBins.size()
    if binCount >= 3
        // ── Percentile threshold ──
        volSorted = volBins.copy()
        volSorted.sort(order.ascending)
        int sortSz   = volSorted.size()
        int pIdx     = f_clampIdx(int(math.floor(weakPctile / 100.0 * (sortSz - 1))), sortSz)
        float percTh = volSorted.get(pIdx)

        int wallBins = math.max(3, math.min(int(vpResolution * wallLookMult), vpResolution / 4))

        float bestRevAboveDist = 1e18
        float bestBrkAboveDist = 1e18
        float bestRevBelowDist = 1e18
        float bestBrkBelowDist = 1e18

        // ── Pre-compute touch map per bin (avoids nested loop explosion) ──
        int tWin = math.min(touchWin, bar_index)
        var touchCounts = array.new<int>(vpResolution, 0)
        // Rebuild touch counts
        if tWin > 0 and binCount > 0
            for j = 0 to binCount - 1
                touchCounts.set(j, 0)  // reset
            float bMinPx = f_safeGet(priceBins, 0)
            float bMaxPx = f_safeGet(priceBins, binCount - 1)
            float bSzTouch = binCount > 1 ? (bMaxPx - bMinPx) / (binCount - 1) : 1.0
            if bSzTouch > 0 and not na(bMinPx)
                for t = 0 to tWin - 1
                    float c = nz(close[t])
                    if c >= bMinPx and c <= bMaxPx
                        int tIdx = f_clampIdx(int(math.round((c - bMinPx) / bSzTouch)), binCount)
                        if tIdx >= 0 and tIdx < touchCounts.size()
                            touchCounts.set(tIdx, touchCounts.get(tIdx) + 1)

        float wSum  = wWall + wVacuum + wHurst + wHTF + wTouch
        float wNorm = wSum > 0 ? wSum : 1.0

        // ── Scan for pockets ──
        for k = 1 to binCount - 2
            float vk = f_safeGet(volBins, k)
            float vL = f_safeGet(volBins, k - 1)
            float vR = f_safeGet(volBins, k + 1)
            bool isMin   = vk < vL and vk < vR
            float nbrAvg = (vL + vR) * 0.5
            bool ratioOK = nbrAvg > 0 ? (vk / nbrAvg) <= weakRatio : false
            bool thinOK  = vk <= percTh

            if isMin and ratioOK and thinOK
                // ── Expand pocket ──
                int loIdx = k
                int hiIdx = k
                for a = k - 1 to 0
                    if f_safeGet(volBins, a) <= percTh
                        loIdx := a
                    else
                        break
                for b = k + 1 to binCount - 1
                    if f_safeGet(volBins, b) <= percTh
                        hiIdx := b
                    else
                        break

                int pktBins = hiIdx - loIdx + 1
                if pktBins >= minPktBins
                    float loPx  = f_safeGetNa(priceBins, loIdx)
                    float hiPx  = f_safeGetNa(priceBins, hiIdx)
                    if not na(loPx) and not na(hiPx)
                        float edgeLo = math.min(loPx, hiPx)
                        float edgeHi = math.max(loPx, hiPx)
                        float midPx  = (edgeLo + edgeHi) * 0.5
                        float span   = edgeHi - edgeLo
                        bool okSpan  = nz(atrVal) > 0 ? (span / atrVal) >= minPktATR : true

                        if okSpan
                            // ── Pocket depth ──
                            float depthSum = 0.0
                            for d = loIdx to hiIdx
                                depthSum += f_safeGet(volBins, d)
                            float depth    = pktBins > 0 ? depthSum / pktBins : 0.0
                            float depthSafe = math.max(depth, 1e-10)

                            // ── Wall analysis ──
                            float wallAboveSum = 0.0
                            int   wallAboveCnt = 0
                            float wallBelowSum = 0.0
                            int   wallBelowCnt = 0
                            for w = 1 to wallBins
                                int idxUp = hiIdx + w
                                int idxDn = loIdx - w
                                if idxUp >= 0 and idxUp < binCount
                                    wallAboveSum += f_safeGet(volBins, idxUp)
                                    wallAboveCnt += 1
                                if idxDn >= 0 and idxDn < binCount
                                    wallBelowSum += f_safeGet(volBins, idxDn)
                                    wallBelowCnt += 1
                            float wallAbove = wallAboveCnt > 0 ? wallAboveSum / wallAboveCnt : 0.0
                            float wallBelow = wallBelowCnt > 0 ? wallBelowSum / wallBelowCnt : 0.0

                            // ── Touch density from pre-computed map ──
                            int touchSum = 0
                            if touchCounts.size() >= binCount
                                for ti = loIdx to hiIdx
                                    if ti >= 0 and ti < touchCounts.size()
                                        touchSum += touchCounts.get(ti)
                            float tDensity = tWin > 0 ? float(touchSum) / float(tWin) : 0.0

                            // ── HTF confluence ──
                            bool htfConf = f_nearHTF(midPx, confWin)
                            float htfF   = htfConf ? 1.0 : 0.0

                            // ── Hurst components ──
                            float hurstRev = 1.0 - nz(hurstH, 0.5)
                            float hurstBrk = nz(hurstH, 0.5)
                            float touchRev = 1.0 - math.min(tDensity * 10.0, 1.0)
                            float touchBrk = math.min(tDensity * 10.0, 1.0)

                            // ── Classify: pocket ABOVE price ──
                            if midPx >= close
                                float dist = midPx - close
                                // far wall = wallAbove (beyond pocket away from price)
                                float wrA    = wallAbove / depthSafe
                                float wrNorm = 2.0 / (1.0 + math.exp(-0.5 * wrA)) - 1.0
                                float vacA   = wallAbove > 0 ? 1.0 - math.min(wallAbove / math.max(wallBelow, 1e-10), 1.0) : 1.0
                                float vacN   = math.max(0.0, math.min(1.0, vacA))
                                float rScore = (wWall * wrNorm + wVacuum * (1.0 - vacN) + wHurst * hurstRev + wHTF * htfF + wTouch * touchRev) / wNorm
                                float bScore = (wWall * (1.0 - wrNorm) + wVacuum * vacN + wHurst * hurstBrk + wTouch * touchBrk) / wNorm
                                bool isRev   = rScore >= bScore

                                if isRev and dist < bestRevAboveDist
                                    bestRevAboveDist := dist
                                    revAboveLo := edgeLo, revAboveHi := edgeHi
                                    revAboveRevS := rScore, revAboveBrkS := bScore
                                if not isRev and dist < bestBrkAboveDist
                                    bestBrkAboveDist := dist
                                    brkAboveLo := edgeLo, brkAboveHi := edgeHi
                                    brkAboveRevS := rScore, brkAboveBrkS := bScore

                            // ── Classify: pocket BELOW price ──
                            if midPx < close
                                float dist = close - midPx
                                // far wall = wallBelow (beyond pocket away from price)
                                float wrB    = wallBelow / depthSafe
                                float wrNormB = 2.0 / (1.0 + math.exp(-0.5 * wrB)) - 1.0
                                float vacB    = wallBelow > 0 ? 1.0 - math.min(wallBelow / math.max(wallAbove, 1e-10), 1.0) : 1.0
                                float vacNB   = math.max(0.0, math.min(1.0, vacB))
                                float rScoreB = (wWall * wrNormB + wVacuum * (1.0 - vacNB) + wHurst * hurstRev + wHTF * htfF + wTouch * touchRev) / wNorm
                                float bScoreB = (wWall * (1.0 - wrNormB) + wVacuum * vacNB + wHurst * hurstBrk + wTouch * touchBrk) / wNorm
                                bool isRevB   = rScoreB >= bScoreB

                                if isRevB and dist < bestRevBelowDist
                                    bestRevBelowDist := dist
                                    revBelowLo := edgeLo, revBelowHi := edgeHi
                                    revBelowRevS := rScoreB, revBelowBrkS := bScoreB
                                if not isRevB and dist < bestBrkBelowDist
                                    bestBrkBelowDist := dist
                                    brkBelowLo := edgeLo, brkBelowHi := edgeHi
                                    brkBelowRevS := rScoreB, brkBelowBrkS := bScoreB

// ═════════════════════════════════════════════════════════════════════════════
// APPROACH DYNAMICS
// ═════════════════════════════════════════════════════════════════════════════
float volSMA     = ta.sma(volume, 10)
float volRatio   = nz(volSMA) > 0 ? nz(volume) / volSMA : 1.0
bool  risingVol  = volRatio > 1.2
bool  fallingVol = volRatio < 0.8
bool  bullMom    = not useMom or close > emaTrend
bool  bearMom    = not useMom or close < emaTrend
bool  strongUp   = not useROC or nz(rocVal) > 0
bool  strongDn   = not useROC or nz(rocVal) < 0

// ═════════════════════════════════════════════════════════════════════════════
// SIGNAL GENERATION
// ═════════════════════════════════════════════════════════════════════════════

// ── Reversal Above: price rises into pocket → expect rejection DOWN ──
bool revAboveEntry = not na(revAboveLo) and
     (confirmClose ? ta.crossover(close, revAboveLo) : (low <= revAboveLo and close > revAboveLo))
bool revAboveConfirmed = revAboveEntry and (fallingVol or not strongUp)

// ── Breakthrough Above: price rises into pocket → expect acceleration UP ──
bool brkAboveEntry = not na(brkAboveLo) and bullMom and
     (confirmClose ? ta.crossover(close, brkAboveLo) : (low <= brkAboveLo and close > brkAboveLo))
bool brkAboveConfirmed = brkAboveEntry and (risingVol or strongUp)

// ── Reversal Below: price falls into pocket → expect rejection UP ──
bool revBelowEntry = not na(revBelowHi) and
     (confirmClose ? ta.crossunder(close, revBelowHi) : (high >= revBelowHi and close < revBelowHi))
bool revBelowConfirmed = revBelowEntry and (fallingVol or not strongDn)

// ── Breakthrough Below: price falls into pocket → expect acceleration DOWN ──
bool brkBelowEntry = not na(brkBelowHi) and bearMom and
     (confirmClose ? ta.crossunder(close, brkBelowHi) : (high >= brkBelowHi and close < brkBelowHi))
bool brkBelowConfirmed = brkBelowEntry and (risingVol or strongDn)

// ── Fill detection ──
bool revAboveFill = not na(revAboveHi) and (confirmClose ? ta.crossover(close, revAboveHi) : high >= revAboveHi)
bool brkAboveFill = not na(brkAboveHi) and (confirmClose ? ta.crossover(close, brkAboveHi) : high >= brkAboveHi)
bool revBelowFill = not na(revBelowLo) and (confirmClose ? ta.crossunder(close, revBelowLo) : low <= revBelowLo)
bool brkBelowFill = not na(brkBelowLo) and (confirmClose ? ta.crossunder(close, brkBelowLo) : low <= brkBelowLo)

// ═════════════════════════════════════════════════════════════════════════════
// VISUALIZATION
// ═════════════════════════════════════════════════════════════════════════════

// ── POC / VA zones ──
float pocU = showVAZones and not na(pocPx) ? pocPx + zoneHalf : na
float pocL = showVAZones and not na(pocPx) ? pocPx - zoneHalf : na
float vahU = showVAZones and not na(vahPx) ? vahPx + zoneHalf : na
float vahL = showVAZones and not na(vahPx) ? vahPx - zoneHalf : na
float valU = showVAZones and not na(valPx) ? valPx + zoneHalf : na
float valL = showVAZones and not na(valPx) ? valPx - zoneHalf : na

bool pocHTF = f_nearHTF(pocPx, confWin)
p1 = plot(pocU, "POC-U", display=display.none)
p2 = plot(pocL, "POC-L", display=display.none)
fill(p1, p2, color=pocHTF ? color.new(color.purple, 60) : pocColor, title="POC Fill")

p3 = plot(vahU, "VAH-U", display=display.none)
p4 = plot(vahL, "VAH-L", display=display.none)
fill(p3, p4, color=vaClr, title="VAH Fill")

p5 = plot(valU, "VAL-U", display=display.none)
p6 = plot(valL, "VAL-L", display=display.none)
fill(p5, p6, color=vaClr, title="VAL Fill")

float hvnU = showHVN2 and not na(hvn2Px) ? hvn2Px + zoneHalf : na
float hvnL = showHVN2 and not na(hvn2Px) ? hvn2Px - zoneHalf : na
p7 = plot(hvnU, "HVN2-U", display=display.none)
p8 = plot(hvnL, "HVN2-L", display=display.none)
fill(p7, p8, color=hvnClr, title="HVN2 Fill")

// ── Reversal pockets (orange) ──
rA1 = plot(revAboveHi, "RevAbove-Hi", display=display.none)
rA2 = plot(revAboveLo, "RevAbove-Lo", display=display.none)
fill(rA1, rA2, color=revAboveClr, title="Reversal Above Fill")

rB1 = plot(revBelowHi, "RevBelow-Hi", display=display.none)
rB2 = plot(revBelowLo, "RevBelow-Lo", display=display.none)
fill(rB1, rB2, color=revBelowClr, title="Reversal Below Fill")

// ── Breakthrough pockets (purple) ──
bA1 = plot(brkAboveHi, "BrkAbove-Hi", display=display.none)
bA2 = plot(brkAboveLo, "BrkAbove-Lo", display=display.none)
fill(bA1, bA2, color=brkAboveClr, title="Breakthrough Above Fill")

bB1 = plot(brkBelowHi, "BrkBelow-Hi", display=display.none)
bB2 = plot(brkBelowLo, "BrkBelow-Lo", display=display.none)
fill(bB1, bB2, color=brkBelowClr, title="Breakthrough Below Fill")

// ── HTF lines ──
plot(showHTFLines and htf1_on ? htf1H : na, "HTF1-H", color=htfLineClr, style=plot.style_cross)
plot(showHTFLines and htf1_on ? htf1L : na, "HTF1-L", color=htfLineClr, style=plot.style_cross)
plot(showHTFLines and htf2_on ? htf2H : na, "HTF2-H", color=htfLineClr, style=plot.style_cross)
plot(showHTFLines and htf2_on ? htf2L : na, "HTF2-L", color=htfLineClr, style=plot.style_cross)

// ── Signal markers ──
plotshape(revAboveConfirmed, "Rev Above", style=shape.diamond,
     size=size.small, location=location.abovebar, color=color.new(#FF6D00, 0), text="REV↓")
plotshape(revBelowConfirmed, "Rev Below", style=shape.diamond,
     size=size.small, location=location.belowbar, color=color.new(#FF6D00, 0), text="REV↑")
plotshape(brkAboveConfirmed, "Brk Above", style=shape.triangleup,
     size=size.small, location=location.belowbar, color=color.new(#AA00FF, 0), text="BRK↑")
plotshape(brkBelowConfirmed, "Brk Below", style=shape.triangledown,
     size=size.small, location=location.abovebar, color=color.new(#AA00FF, 0), text="BRK↓")

// ── Hurst regime background ──
bgcolor(hurstH > 0.6 ? color.new(color.blue, 95) : hurstH < 0.4 ? color.new(color.orange, 95) : na,
     title="Hurst Regime Tint")

// ═════════════════════════════════════════════════════════════════════════════
// ALERTS
// ═════════════════════════════════════════════════════════════════════════════
f_msg(string evt, string dir, float lo, float hi, float rS, float bS) =>
    str.format("{0} {1} | {2} {3} | Pocket {4}–{5} | R:{6} B:{7} | Close {8} ATR {9}",
         syminfo.ticker, timeframe.period, evt, dir,
         str.tostring(nz(lo), format.mintick), str.tostring(nz(hi), format.mintick),
         str.tostring(nz(rS), "#.##"), str.tostring(nz(bS), "#.##"),
         str.tostring(close, format.mintick), str.tostring(nz(atrVal), format.mintick))

if alertOn
    if alertRevEntry and revAboveConfirmed
        alert(f_msg("REVERSAL", "SHORT", revAboveLo, revAboveHi, revAboveRevS, revAboveBrkS), alertFreq)
    if alertRevEntry and revBelowConfirmed
        alert(f_msg("REVERSAL", "LONG", revBelowLo, revBelowHi, revBelowRevS, revBelowBrkS), alertFreq)
    if alertBrkEntry and brkAboveConfirmed
        alert(f_msg("BREAKTHROUGH", "LONG", brkAboveLo, brkAboveHi, brkAboveRevS, brkAboveBrkS), alertFreq)
    if alertBrkEntry and brkBelowConfirmed
        alert(f_msg("BREAKTHROUGH", "SHORT", brkBelowLo, brkBelowHi, brkBelowRevS, brkBelowBrkS), alertFreq)
    if alertFill and revAboveFill
        alert(f_msg("REV FILLED", "UP", revAboveLo, revAboveHi, revAboveRevS, revAboveBrkS), alertFreq)
    if alertFill and brkAboveFill
        alert(f_msg("BRK FILLED", "UP", brkAboveLo, brkAboveHi, brkAboveRevS, brkAboveBrkS), alertFreq)
    if alertFill and revBelowFill
        alert(f_msg("REV FILLED", "DN", revBelowLo, revBelowHi, revBelowRevS, revBelowBrkS), alertFreq)
    if alertFill and brkBelowFill
        alert(f_msg("BRK FILLED", "DN", brkBelowLo, brkBelowHi, brkBelowRevS, brkBelowBrkS), alertFreq)

bool inPOC = not na(pocL) and close >= pocL and close <= pocU
bool inVAH = not na(vahL) and close >= vahL and close <= vahU
bool inVAL = not na(valL) and close >= valL and close <= valU
if alertOn and alertVA
    if inPOC
        alert("Entered POC Zone", alertFreq)
    if inVAH
        alert("Entered VAH Zone", alertFreq)
    if inVAL
        alert("Entered VAL Zone", alertFreq)

if alertOn and alertHTFx
    if htf1_on and not na(htf1H) and ta.cross(close, htf1H)
        alert("Crossed HTF1 High", alertFreq)
    if htf1_on and not na(htf1L) and ta.cross(close, htf1L)
        alert("Crossed HTF1 Low", alertFreq)
    if htf2_on and not na(htf2H) and ta.cross(close, htf2H)
        alert("Crossed HTF2 High", alertFreq)
    if htf2_on and not na(htf2L) and ta.cross(close, htf2L)
        alert("Crossed HTF2 Low", alertFreq)

// ── alertcondition ──
alertcondition(revAboveConfirmed, "Reversal SHORT",       "Reversal pocket above — expect rejection down")
alertcondition(revBelowConfirmed, "Reversal LONG",        "Reversal pocket below — expect bounce up")
alertcondition(brkAboveConfirmed, "Breakthrough LONG",    "Breakthrough pocket above — expect continuation up")
alertcondition(brkBelowConfirmed, "Breakthrough SHORT",   "Breakthrough pocket below — expect continuation down")
alertcondition(revAboveFill,      "Rev Above Filled",     "Filled through reversal pocket above")
alertcondition(brkAboveFill,      "Brk Above Filled",     "Filled through breakthrough pocket above")
alertcondition(revBelowFill,      "Rev Below Filled",     "Filled through reversal pocket below")
alertcondition(brkBelowFill,      "Brk Below Filled",     "Filled through breakthrough pocket below")
````
