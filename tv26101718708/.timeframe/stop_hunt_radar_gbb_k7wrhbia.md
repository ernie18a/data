# Stop Hunt Radar [GBB]

- url: https://www.tradingview.com/script/k7wRHBia-Stop-Hunt-Radar-GBB/
- type: indicator
- pine_id: PUB;86fe1c37ee9145b1a366a42f15f0bbf1
- version: 1.0

## Description

STOP HUNT RADAR [GBB]

Have you ever placed a stop loss under a swing low, watched price come down, take out your stop to the tick, and then run exactly where you said it would? That's not bad luck and it's not a conspiracy. Below every obvious low sits a cluster of sell orders — your stop, my stop, the breakout traders' sell-stops — and for anyone who needs to buy size, that cluster is the only spot on the chart with guaranteed forced selling waiting at a known price. Your stop wasn't hunted out of malice. Your stop was the liquidity.
This indicator maps those clusters in real time, classifies what happens when they get hit, and keeps honest records. That last part matters more than you think.

How is works

The shaded bands are stop pools. "Sell stops · 60,621" means stop losses from longs are probably resting under that level; the shading shows the pocket where they sit. Color is a ranking, not a direction: gray is a minor fresh swing, pink is the most loaded level currently on your screen. Hover any level and it tells you in plain words why it's ranked — "3 equal lows · yesterday's low · 4.2× volume". No codes to memorize. (If you prefer compact BSL/SSL labels, switch Label Style to Pro.)

When price hits a pool, the radar decides what happened by fixed rules, on closed bars, with no repainting:
⚡ swept — price wicked through and closed back. The marker stays on the chart with the measured raid depth ("⚡ 2.4 ATR").
✕ broken — price closed through and stayed.
⌛ undecided — price closed through but might come back. The radar waits a few bars before calling it instead of guessing. Capitulation V-reversals get correctly labeled as sweeps because of this.

The dotted lines near ranked pools are the part I'm most proud of: depth guides. They're measured from this chart's own history — "typical sweep · 63,955" marks how far the median raid ran past that level, "1-in-20 sweep" marks the bad case. Now look where the textbook stop placement is. Usually inside the typical zone. That's the whole point of this tool in one picture.

IMPORTANT

Every channel that shows you stop hunts follows up with the same pitch: buy the sweep, ride the reversal. Before publishing this, I tested that. Properly — the engine was rebuilt in Python, verified bar-for-bar identical against this script, and run through a pre-registered study on 24 months of BTC, ETH and SOL. The final test ran exactly once, on 21,813 sweeps of held-out data the tuning never touched.

Result: after a sweep, the average forward move is statistically indistinguishable from entering at a random moment. The strongest-ranked pools did not reverse harder — if anything slightly worse. The dramatic panic-volume wicks leaned toward continuation, not reversal.

So no, the lightning bolts are not buy signals, and I won't pretend otherwise. The live tally on your own chart will show you the same thing — reclaim rates around 55–60%, a coin flip with commission. This is why the radar prints the losses too. If someone shows you this pattern with only winning examples, you now know what got cropped.

WHAT IT'S ACTUALLY FOR

Stop placement, mostly. The depth guides answer "is my stop sitting in the feeding zone?" before you find out the expensive way. Either place it past the typical-sweep line or size down knowing the risk. Second: when a level gets hit you get a rule-based verdict — swept or broken — instead of arguing with yourself, and alerts fire on those events so it watches the levels while you don't. Third: the receipt trail audits your beliefs. You think "they always sweep the lows here"? Scroll back. The chart kept score.

ANY MARKET, ANY TIMEFRAME

The geometry is ATR-scaled and the tolerances are percentage-based, so it self-adapts. The stats are measured per chart — a Gold chart shows Gold's raid depths, not Bitcoin's. Auto-Adapt handles the asset-specific details: forex gets proper big-figure/half-figure round numbers (159.50 on USDJPY, 1.0850 on EURUSD), and symbols without volume data get the volume factor switched off. When an adaptation is active, the legend says so. One honest caveat: the validation study was crypto on 5m. Other markets run the same mechanics but ship with their own live base rates instead of borrowed claims. Stocks gap — gap-throughs get adjudicated by the same waiting rule, but read markers around opens with some skepticism.

GOOD TO KNOW
Colors are relative: a pool's color can shift as stronger or weaker pools appear on screen. That's ranking, not repainting — the absolute score lives in the tooltip and never changes retroactively. Depth guides appear once the chart has logged at least 10 classified sweeps per side, because statistics from three events aren't statistics. If another indicator ever squashes your chart, right-click the price scale and enable "Scale price chart only" — worth doing in general. The optional dashboard (off by default) adds the nearest pools and the rolling base rates in a corner panel.

THE SETTINGS

You don't need to touch any of this — the defaults are the validated configuration and what I run myself. But it's all there if you want it. The settings are grouped the same way the panel is.

Display — the stuff you'll actually use. Min Score To Display hides weak pools (0 shows everything). Display Radius (default 3%) hides pools too far from price; they're still tracked, they just reappear when price comes back. Show Pool Labels, Show Radar Dashboard (off by default — the corner panel with nearest pools and base rates), Show Legend, Show Sweep Base Rates. Label Style is the big one: Beginner spells everything out, Pro uses compact BSL/SSL codes. UI Text Size and Label Size — bump these up for screenshots and video. Sweep Depth Guides plus "Hide Guides For Gray Pools" (rank 0–10, default 3): raise it to only annotate the strongest levels, lower it to 0 to guide every pool. Auto-Adapt To Asset Class — leave this on unless you have a reason.

Swing Detection — how a level is found. Pivot Left / Pivot Right define how many bars each side make a swing (8/3 default — bigger = fewer, more significant levels). Max Armed Life retires a level that's gone untested for too long.

Pool Geometry — ATR Length drives all the scaling. Pocket Depth sets how thick the shaded stop pocket is. EQ Merge Tolerance controls how close two swings must be to count as the "same" level and cluster together — by % of price (default) or ATR.

Sweep / Outcome — the classification rules. Min Sweep Penetration is how far past a level a wick must go to count as a touch. Multi-Bar Sweep Grace (default 10 bars) is the window where a close-through can still turn back into a sweep — this is what catches capitulation reversals instead of mislabeling them as breaks; set it to 0 for strict single-bar sweeps only. Reclaim Confirmation and Outcome Watch Window define what counts as a confirmed reclaim and how long the radar watches before giving up.

Scoring & Heat Weights — what makes a level rank high. Four weights: EQ Cluster Size, Untested Age, Confluence, Formation Volume. The "Norm" values are how much of each earns a full score (e.g. 3 equal pivots = full cluster score). Session Confluence toggles the prior day/week levels; Round Number Confluence and its step (0 = auto, and auto is asset-aware) toggle round-number weighting. Fair warning: the study found the heat score doesn't predict sweep outcomes, so retuning these changes what looks prominent, not what works. I left mine at default and I'd suggest you do too.

Heat Palette & Receipts — looks. Heat Color Scale is Relative by default (the ramp stretches across the pools currently on screen); switch to Absolute if you want a fixed 0–10 meaning. The four color stops (Cold / Warm / Hot / Prime) are the ramp. Outcome Receipts: show Wins + Losses (default — the point), Wins Only, or None.

Alerts — High-Rank Pool Score is the threshold for the "approaching a strong pool" alerts (it's on the absolute score, where pools typically sit around 1–4). Proximity is how close counts as "approaching". The sweep and break alerts themselves fire on the events directly — add them from the alerts dialog.

## Source Code

````pine
//@version=6
// ═══════════════════════════════════════════════════════════════════════════
//  STOP HUNT RADAR [GBB] v3.7 — Asset Auto-Adapt

indicator("Stop Hunt Radar [GBB]", "SHR", overlay = true, max_boxes_count = 500, max_labels_count = 500, max_lines_count = 500)

// ═══════════════════════════════════════════════════════════════════════════
//                               INPUTS
// ═══════════════════════════════════════════════════════════════════════════
gD = "═══ Display ═══"
showThr   = input.float(0.0, "Min Score To Display", minval = 0, maxval = 10, step = 0.5, group = gD, tooltip = "Pools scoring below this are tracked invisibly and appear once their score grows.")
dispRad   = input.float(3.0, "Display Radius (% of price, 0 = off)", minval = 0.0, step = 0.25, group = gD, tooltip = "Pools farther than this from current price are tracked invisibly (and still feed the dashboard) but not drawn. They reappear when price approaches.")
maxLive   = input.int(6, "Max Armed Pools Per Side", minval = 1, maxval = 15, group = gD, tooltip = "When the cap is hit, the farthest out-of-radius pool is dropped first; otherwise the lowest-scoring one.")
maxKept   = input.int(40, "Max Outcome Markers Kept", minval = 0, maxval = 100, group = gD, tooltip = "Resolved-pool receipts (⚡ / ✕) stay on chart up to this many.")
showTags  = input.bool(true, "Show Pool Labels", group = gD, tooltip = "Compact price tags. Hover a tag for the full heat breakdown.")
showDash  = input.bool(false, "Show Radar Dashboard", group = gD, tooltip = "Optional corner panel: nearest pool each side with distance, rank, drivers, plus the sweep base rates. Off by default — the chart carries the essentials (labels, depth guides, receipts).")
dashTitle = input.string("STOP HUNT RADAR [GBB]", "Dashboard Title", group = gD)
dashPos   = input.string("Top Right", "Dashboard Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = gD)
showRates = input.bool(true, "Show Sweep Base Rates", group = gD, tooltip = "Rolling outcome stats over the last N classified sweeps on this chart: ⚡ reclaim rate, median and 95th-percentile sweep depth. Descriptive — your chart's own base rates, kept honest automatically.")
baseN     = input.int(50, "Base-Rate Window (sweeps)", minval = 10, maxval = 200, group = gD)
labMode   = input.string("Beginner (plain words)", "Label Style", options = ["Beginner (plain words)", "Pro (compact)"], group = gD, tooltip = "Beginner spells it out on-chart ('Sell stops · 61,330'); Pro uses compact codes (BSL/SSL, ◆ rank marks). Hover tooltips are plain-language in both modes.")
uiScale   = input.string("Normal", "UI Text Size", options = ["Compact", "Normal", "Large"], group = gD, tooltip = "Scales the dashboard, legend, depth-guide labels, and outcome receipts together. Pool labels are sized separately via Label Size.")
labSizeS  = input.string("Normal", "Label Size", options = ["Tiny", "Small", "Normal", "Large"], group = gD)
showGuides= input.bool(true, "Sweep Depth Guides", group = gD, tooltip = "For every visible ranked pool: dotted lines in the pool's color showing how deep the typical and the 1-in-20 sweep wick reached on this chart (from the base-rate journal). Each label names its pool's price. The on-chart answer to 'is my stop too close?'")
guideMinHv= input.float(3.0, "Hide Guides For Gray Pools (min rank 0–10)", minval = 0, maxval = 10, step = 0.5, group = gD, tooltip = "Guides are drawn only for pools whose on-screen rank (the color) is at least this. 0 = guides on every visible pool; raise it to annotate only the strongest levels. Default keeps gray minor swings clean.")
showLegend= input.bool(true, "Show Legend", group = gD)
autoAsset = input.bool(true, "Auto-Adapt To Asset Class", group = gD, tooltip = "Adjusts the asset-specific details automatically: forex symbols get big-figure/half-figure round numbers (e.g. 1.0850 steps on EURUSD instead of nonsense), and symbols without volume data (indices, some CFDs) get the volume factor switched off instead of polluting the rank. Crypto behavior is unchanged — that is the validated configuration. Active adaptations are listed in the legend. Most of the indicator self-scales anyway (ATR geometry, %-based tolerances, per-chart base rates).")
plainMode = labMode == "Beginner (plain words)"
lookbackBars = input.int(3000, "Lookback (bars, 0 = all loaded)", minval = 0, group = gD)

gS = "═══ Swing Detection ═══"
leftBars  = input.int(8, "Pivot Left",  minval = 2, group = gS)
rightBars = input.int(3, "Pivot Right", minval = 1, group = gS, tooltip = "Higher = sturdier swings, slower confirmation. Sweeps are validated against close-back, so confirmation lag does not repaint sweep events.")
maxLife   = input.int(1500, "Max Armed Life (bars)", minval = 50, group = gS, tooltip = "Pools never swept within this window are silently retired.")

gZ = "═══ Pool Geometry ═══"
atrLen    = input.int(100, "ATR Length", minval = 1, maxval = 500, group = gZ)
depthMult = input.float(0.50, "Pocket Depth (ATR mult)", minval = 0.1, maxval = 5.0, step = 0.05, group = gZ, tooltip = "How far beyond the swing level the stop pocket is drawn.")
eqTolMode = input.string("% of Price", "EQ Merge Tolerance Mode", options = ["ATR", "% of Price"], group = gZ, tooltip = "ATR mode is too tight on LTF crypto for levels formed hours apart — % of price clusters more naturally.")
eqTolMult = input.float(0.25, "EQ Tolerance (ATR mult)", minval = 0.05, maxval = 2.0, step = 0.05, group = gZ)
eqTolPct  = input.float(0.15, "EQ Tolerance (% of price)", minval = 0.01, maxval = 2.0, step = 0.01, group = gZ)

gW = "═══ Sweep / Outcome ═══"
penMult   = input.float(0.05, "Min Sweep Penetration (ATR mult)", minval = 0.0, step = 0.01, group = gW, tooltip = "Wick must pierce at least this far beyond the level to count as a sweep — filters equal-touch noise.")
graceBars = input.int(10, "Multi-Bar Sweep Grace (bars, 0 = off)", minval = 0, maxval = 50, group = gW, tooltip = "When price CLOSES through a pool, wait this many bars for a re-close back across the level before confirming a clean break. Captures multi-bar capitulation sweeps (V-reversals).")
confMult  = input.float(0.50, "Reclaim Confirmation (ATR mult)", minval = 0.1, step = 0.05, group = gW, tooltip = "After a sweep, a close this far back beyond the level confirms the reversal.")
watchBars = input.int(30, "Outcome Watch Window (bars)", minval = 3, maxval = 300, group = gW, tooltip = "Bars after a sweep to wait for reclaim or break before fading the pool out.")

gStr = "═══ Pool Heat Scoring (0–10) ═══"
wEQ     = input.float(0.45, "Weight: EQ Cluster Size", minval = 0, maxval = 1, step = 0.05, group = gStr)
wAge    = input.float(0.25, "Weight: Untested Age", minval = 0, maxval = 1, step = 0.05, group = gStr)
wConf   = input.float(0.30, "Weight: Confluence (Session + Round)", minval = 0, maxval = 1, step = 0.05, group = gStr)
wVol    = input.float(0.25, "Weight: Formation Volume", minval = 0, maxval = 1, step = 0.05, group = gStr, tooltip = "Pools born on a volume spike (capitulation flush, climax bar) carry dense fresh stops — they heat up immediately instead of waiting on age/cluster.")
eqNorm  = input.float(3.0, "Pivots For Full EQ Score", minval = 1, step = 0.5, group = gStr)
volNorm = input.float(2.5, "Rel. Volume For Full Score (× baseline)", minval = 1.0, step = 0.25, group = gStr)
volLen  = input.int(20, "Volume Baseline Length", minval = 1, group = gStr)
ageNorm = input.int(300, "Bars For Full Age Score", minval = 10, group = gStr, tooltip = "Untested age saturates here — stops accumulate, but not forever.")
useSess = input.bool(true, "Session Confluence (PDH/PDL/PWH/PWL)", group = gStr)
useRound= input.bool(true, "Round Number Confluence", group = gStr)
roundStep = input.float(0.0, "Round Number Step (0 = auto)", minval = 0.0, group = gStr, tooltip = "Auto picks a step from price magnitude (e.g. 1000 on BTC at 60k). Set manually for FX (e.g. 0.005).")

gC = "═══ Heat Palette & Receipts ═══"
heatScale = input.string("Relative (rank among pools)", "Heat Color Scale", options = ["Relative (rank among pools)", "Absolute (0–10)"], group = gC, tooltip = "Relative stretches the color ramp across the currently tracked pools, so the hottest pool on the chart always renders hot. Absolute maps the raw 0–10 score directly. Tooltip and dashboard NUMBERS are always the absolute score either way.")
colCold   = input.color(#5d6b7d, "Cold (0)", group = gC, inline = "p1")
colWarm   = input.color(#21c997, "Warm (5)", group = gC, inline = "p1")
colHot    = input.color(#f5a623, "Hot (8)", group = gC, inline = "p2")
colPrime  = input.color(#ff3b6b, "Prime (10)", group = gC, inline = "p2")
pocketInt = input.int(6, "Pocket Fill Strength", minval = 1, maxval = 10, group = gC)
showGlow  = input.bool(true, "Glow On HOT Pools", group = gC)
receiptMode = input.string("Wins + Losses", "Outcome Receipts", options = ["Wins + Losses", "Wins Only", "None"], group = gC, tooltip = "Descriptive event markers: ⚡ = sweep that was reclaimed (label shows sweep depth in ATR); ✕ = level broken cleanly. These record what happened — they are NOT performance claims; the validation study found post-sweep returns indistinguishable from random. Default shows both outcomes; that is the point.")
colWin    = input.color(#2bd9a3, "⚡ Receipt", group = gC, inline = "p3")
colLoss   = input.color(#6b7480, "✕ Marker", group = gC, inline = "p3")

gA = "═══ Alerts ═══"
hotThr    = input.float(3.5, "High-Rank Pool Score (absolute)", minval = 0, maxval = 10, step = 0.5, group = gA, tooltip = "Raw heat scores typically range ~1–4 with default weights; this threshold is on the absolute score, not the relative color. (Pre-v3.2 default of 7 was effectively unreachable, so these alerts never fired.)")
alertProx = input.float(0.25, "Proximity (% of price)", minval = 0.0, step = 0.01, group = gA, tooltip = "Proximity alerts fire when price is within this % of a high-rank pool's level.")
// ═══════════════════════════════════════════════════════════════════════════
//                               HELPERS
// ═══════════════════════════════════════════════════════════════════════════
int NSLICE = 4   // gradient slices per pocket

f_size(s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.small

// UI text scale: A = secondary text (headers, legend, guides, ✕ markers),
// B = primary text (dashboard data, ⚡ receipts)
f_szA() => uiScale == "Compact" ? size.tiny : uiScale == "Normal" ? size.small : size.normal
f_szB() => uiScale == "Compact" ? size.small : uiScale == "Normal" ? size.normal : size.large

f_tier(sc) => sc >= 8 ? "MAX" : sc >= 6.5 ? "HIGH" : sc >= 5 ? "MODERATE" : sc >= 3 ? "LOW" : "MINIMAL"

// The defining visual: heat → color ramp (cold slate → brand teal → amber → prime).
// Pure ramp over 0–10; f_heatColor below applies relative/absolute scaling first.
f_heatRamp(float v) => v <= 5.0 ? color.from_gradient(v, 0, 5, colCold, colWarm) : v <= 8.0 ? color.from_gradient(v, 5, 8, colWarm, colHot) : color.from_gradient(v, 8, 10, colHot, colPrime)

// Slice transparency: densest at the level line, fading into the pocket;
// hotter pools are more opaque overall.
f_sliceTransp(int i, float sc) => math.min(math.max(94 - pocketInt * 2.0 - sc * 2.0 + i * 4.0, 45), 97)

f_heatBar(float sc) =>
    string s = ""
    int f = int(math.min(math.max(math.round(sc / 2.0), 0), 5))
    for i = 1 to 5
        s += i <= f ? "█" : "░"
    s

f_dashCorner() =>
    switch dashPos
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        => position.top_right

// ═══════════════════════════════════════════════════════════════════════════
//                               TYPES + RECEIPT ARCHIVE
// ═══════════════════════════════════════════════════════════════════════════
type liqZone
    array<box> slices  = na
    line       lvlLn   = na
    line       glowLn  = na
    label      tag     = na
    int        phase   = 1        // 1 = armed, 2 = swept (watch), 3 = broken (reclaim watch)
    int        side    = 1        // 1 = SSL (below swing lows), -1 = BSL (above swing highs)
    float      level   = na
    float      edge    = na
    int        bornBar = na
    int        sweepBar= na
    int        breakBar= na
    float      ext     = na       // max excursion beyond the level
    int        cluster = 1
    float      sweepPen= 0.0
    float      volF    = 1.0
    float      score   = 0.0
    int        heatKey = -1       // render cache: skip repaint when nothing changed

type zoneRec
    label t
    line  l

var array<zoneRec> kept = array.new<zoneRec>()

f_keep(label t, line l) =>
    if maxKept <= 0
        label.delete(t)
        line.delete(l)
    else
        array.push(kept, zoneRec.new(t, l))
        while array.size(kept) > maxKept
            zoneRec r = array.shift(kept)
            label.delete(r.t)
            line.delete(r.l)

// Rolling sweep-outcome base rates (descriptive; per side, last baseN sweeps)
var array<float> bslOut = array.new<float>()
var array<float> bslDep = array.new<float>()
var array<float> sslOut = array.new<float>()
var array<float> sslDep = array.new<float>()

f_recBase(int side, float win, float dAtr) =>
    array<float> outs = side == 1 ? sslOut : bslOut
    array<float> deps = side == 1 ? sslDep : bslDep
    array.push(outs, win)
    array.push(deps, dAtr)
    while array.size(outs) > baseN
        array.shift(outs)
        array.shift(deps)

// Delete every drawing of a pool.
method kill(liqZone self) =>
    if not na(self.slices)
        for b in self.slices
            box.delete(b)
    line.delete(self.lvlLn)
    line.delete(self.glowLn)
    label.delete(self.tag)
    self.tag := na

// ═══════════════════════════════════════════════════════════════════════════
//                               STATE
// ═══════════════════════════════════════════════════════════════════════════
n        = bar_index
atrRaw   = nz(ta.atr(atrLen), ta.cum(high - low) / (n + 1))
volBase  = ta.sma(volume, volLen)
ph       = ta.pivothigh(leftBars, rightBars)
pl       = ta.pivotlow(leftBars, rightBars)
eqTolAbs = eqTolMode == "ATR" ? atrRaw * eqTolMult : close * eqTolPct / 100.0
minPen   = atrRaw * penMult
inWindow = lookbackBars <= 0 or (last_bar_index - n) <= lookbackBars

// session reference levels (prior, completed periods — no repaint with [1] + lookahead_on)
pdh = request.security(syminfo.tickerid, "D", high[1], lookahead = barmerge.lookahead_on)
pdl = request.security(syminfo.tickerid, "D", low[1],  lookahead = barmerge.lookahead_on)
pwh = request.security(syminfo.tickerid, "W", high[1], lookahead = barmerge.lookahead_on)
pwl = request.security(syminfo.tickerid, "W", low[1],  lookahead = barmerge.lookahead_on)

var array<liqZone> ssl = array.new<liqZone>()
var array<liqZone> bsl = array.new<liqZone>()

// ── asset auto-detection ────────────────────────────────────────────────────
bool isForex = syminfo.type == "forex"
var bool hasVol = false
if not hasVol and nz(volume) > 0
    hasVol := true
// ═══════════════════════════════════════════════════════════════════════════
//                               SCORING
// ═══════════════════════════════════════════════════════════════════════════
f_roundStepAuto() =>
    float mag = math.pow(10, math.floor(math.log10(math.max(close, 1e-10))))
    // FX round numbers are big figures / half figures: EURUSD 1.0850 (mag/200),
    // USDJPY 150.50 (mag/200). Everything else keeps the validated mag/10.
    autoAsset and isForex ? mag / 200.0 : mag / 10.0

f_isRound(float lvl) =>
    bool r = false
    if useRound
        float stp = roundStep > 0 ? roundStep : f_roundStepAuto()
        r := math.abs(lvl - math.round(lvl / stp) * stp) <= eqTolAbs * 0.5
    r

f_hasSession(float lvl) =>
    bool s = false
    if useSess
        s := math.abs(lvl - pdh) <= eqTolAbs or math.abs(lvl - pdl) <= eqTolAbs or math.abs(lvl - pwh) <= eqTolAbs or math.abs(lvl - pwl) <= eqTolAbs
    s

// Pool heat 0–10: EQ cluster + untested age + confluence + formation volume.
f_heat(int cluster, int age, bool sess, bool rnd, float volF) =>
    float wV = autoAsset and not hasVol ? 0.0 : wVol
    eF = math.min(cluster / math.max(eqNorm, 1.0), 1.0)
    aF = math.min(age / math.max(ageNorm, 1), 1.0)
    cF = math.min((sess ? 0.6 : 0.0) + (rnd ? 0.5 : 0.0), 1.0)
    vF = math.min(volF / math.max(volNorm, 1.0), 1.0)
    wSum = wEQ + wAge + wConf + wV
    raw  = wSum > 0 ? (eF * wEQ + aF * wAge + cF * wConf + vF * wV) / wSum : 0.0
    math.min(math.max(raw * 10.0, 0.0), 10.0)


f_comps(int cluster, bool sess, bool rnd, float volF) =>
    string s = cluster > 1 ? "EQ×" + str.tostring(cluster) : "swing"
    s += sess ? " · SESS" : ""
    s += rnd ? " · RN" : ""
    s += volF >= 1.5 ? " · V×" + str.tostring(math.round(volF * 10) / 10) : ""
    s

// Which session level matched (plain words), "" if none
f_sessWhich(float lvl) =>
    string s = ""
    if useSess
        s := math.abs(lvl - pdh) <= eqTolAbs ? "yesterday's high" : math.abs(lvl - pdl) <= eqTolAbs ? "yesterday's low" : math.abs(lvl - pwh) <= eqTolAbs ? "last week's high" : math.abs(lvl - pwl) <= eqTolAbs ? "last week's low" : ""
    s

// Plain-language drivers: "3 equal lows · yesterday's low · round number · 1.9× volume"
f_compsPlain(int cluster, int side, bool rnd, float volF, float lvl) =>
    string s = cluster > 1 ? str.tostring(cluster) + " equal " + (side == 1 ? "lows" : "highs") : "swing " + (side == 1 ? "low" : "high")
    string st = f_sessWhich(lvl)
    s += st != "" ? " · " + st : ""
    s += rnd ? " · round number" : ""
    s += volF >= 1.5 ? " · " + str.tostring(math.round(volF * 10) / 10) + "× volume" : ""
    s

// ── Relative heat normalization ────────────────────────────────────────────

float heatLo = 10.0
float heatHi = 0.0
if array.size(ssl) > 0
    for z in ssl
        if dispRad <= 0 or math.abs(close - z.level) <= close * dispRad / 100.0
            heatLo := math.min(heatLo, z.score)
            heatHi := math.max(heatHi, z.score)
if array.size(bsl) > 0
    for z in bsl
        if dispRad <= 0 or math.abs(close - z.level) <= close * dispRad / 100.0
            heatLo := math.min(heatLo, z.score)
            heatHi := math.max(heatHi, z.score)

f_heatVal(float sc) => heatScale == "Absolute (0–10)" or heatHi - heatLo < 0.5 ? sc : math.min(math.max((sc - heatLo) / (heatHi - heatLo) * 10.0, 0.0), 10.0)
f_heatColor(float sc) => f_heatRamp(f_heatVal(sc))

// ═══════════════════════════════════════════════════════════════════════════
//                               RENDERING
// ═══════════════════════════════════════════════════════════════════════════

method build(liqZone self) =>
    self.slices := array.new<box>()
    float h = math.abs(self.level - self.edge) / NSLICE
    for i = 0 to NSLICE - 1
        float yT = self.side == 1 ? self.level - i * h : self.level + (i + 1) * h
        float yB = self.side == 1 ? self.level - (i + 1) * h : self.level + i * h
        array.push(self.slices, box.new(self.bornBar, yT, n, yB, bgcolor = na, border_color = na, extend = extend.right))
    self.lvlLn  := line.new(self.bornBar, self.level, n, self.level, extend = extend.right, color = color.new(colCold, 100), width = 1)
    self.glowLn := line.new(self.bornBar, self.level, n, self.level, extend = extend.right, color = color.new(colCold, 100), width = 7)

// Re-fit geometry after an EQ merge moved the level.
method regeo(liqZone self) =>
    float h = math.abs(self.level - self.edge) / NSLICE
    for i = 0 to NSLICE - 1
        box b = array.get(self.slices, i)
        box.set_top(b, self.side == 1 ? self.level - i * h : self.level + (i + 1) * h)
        box.set_bottom(b, self.side == 1 ? self.level - (i + 1) * h : self.level + i * h)
    line.set_y1(self.lvlLn, self.level)
    line.set_y2(self.lvlLn, self.level)
    line.set_y1(self.glowLn, self.level)
    line.set_y2(self.glowLn, self.level)
    self.heatKey := -1   // force repaint

// Apply heat color, width, glow, and the compact label (+ hover tooltip).
// heatKey caching skips redundant drawing updates for performance.
method paint(liqZone self, bool visOk, bool sess, bool rnd) =>
    float hv = f_heatVal(self.score)
    color hc = f_heatRamp(hv)
    int key = int(math.round(hv * 10)) + self.phase * 1000 + (visOk ? 100000 : 0)
    if key != self.heatKey
        self.heatKey := key
        for i = 0 to NSLICE - 1
            box.set_bgcolor(array.get(self.slices, i), visOk ? color.new(hc, f_sliceTransp(i, hv)) : na)
        line.set_color(self.lvlLn, color.new(hc, visOk ? 0 : 100))
        line.set_width(self.lvlLn, hv >= 8 ? 3 : hv >= 5 ? 2 : 1)
        line.set_style(self.lvlLn, self.phase == 2 ? line.style_dashed : self.phase == 3 ? line.style_dotted : line.style_solid)
        line.set_color(self.glowLn, color.new(hc, visOk and showGlow and hv >= 7.5 ? 82 : 100))
    if showTags
        if na(self.tag)
            self.tag := label.new(n, self.level, "", style = label.style_label_right, color = color.new(#000000, 55), textcolor = hc, size = f_size(labSizeS))
        string stat = self.phase == 2 ? (plainMode ? "⚡ SWEPT · " : "⚡ ") : self.phase == 3 ? (plainMode ? "⌛ breaking? · " : "⌛ ") : ""
        string mark = plainMode ? "" : (hv >= 8 ? "  ◆◆◆" : hv >= 6.5 ? "  ◆◆" : hv >= 5 ? "  ◆" : "")
        string core = (plainMode ? (self.side == 1 ? "Sell stops · " : "Buy stops · ") : "") + str.tostring(self.level, format.mintick)
        label.set_text(self.tag, visOk ? stat + core + mark : "")
        label.set_color(self.tag, color.new(#000000, visOk ? 55 : 100))
        label.set_xy(self.tag, n, self.level)
        label.set_textcolor(self.tag, hc)
        string tip = (self.side == 1 ? "Sell-side stop cluster — stop-losses likely resting BELOW this swing low" : "Buy-side stop cluster — stop-losses likely resting ABOVE this swing high") + "\nWhy it matters: " + f_compsPlain(self.cluster, self.side, rnd, self.volF, self.level) + "\nRank: " + str.tostring(math.round(self.score * 10) / 10) + "/10 — relative prominence on this chart, NOT a prediction (validated)" + "\nUntested for " + str.tostring(n - self.bornBar) + " bars" + (self.phase == 2 ? "\n⚡ SWEPT — wick pierced " + str.tostring(math.round(self.sweepPen * 100) / 100) + "× ATR through, watching for a confirming close back" : self.phase == 3 ? "\n⌛ BROKEN — waiting to see if price closes back across (that would make it a sweep, not a break)" : "")
        label.set_tooltip(self.tag, tip)

// Retire a pool and print its outcome receipt.
//   "⚡" reclaim confirmed: measured move at the sweep extreme + raid line
//   "✕" clean break: small marker at the level
//   "—" faded out: no marker
method resolve(liqZone self, string glyph) =>
    int   sBar = self.sweepBar
    float sExt = self.ext
    float lvl  = self.level
    int   side = self.side
    self.kill()
    // base-rate journal: only classified sweeps (sweepBar set); ⚡ = 1, ✕/— = 0
    if not na(sBar)
        f_recBase(side, glyph == "⚡" ? 1.0 : 0.0, atrRaw > 0 ? math.abs(lvl - sExt) / atrRaw : 0.0)
    if glyph == "⚡" and receiptMode != "None"
        float depthAtr = atrRaw > 0 ? math.abs(lvl - sExt) / atrRaw : 0.0
        label rl = label.new(sBar, sExt, "⚡ " + str.tostring(math.round(depthAtr * 10) / 10) + " ATR", style = side == 1 ? label.style_label_up : label.style_label_down, color = color.new(#000000, 45), textcolor = colWin, size = f_szB(), tooltip = "Sweep: price wicked " + str.tostring(math.round(depthAtr * 10) / 10) + "× the average bar range (ATR) past the level, then closed back across it. Descriptive record — not a buy/sell signal.")
        line  rn = line.new(sBar, lvl, sBar, sExt, color = color.new(colWin, 40), style = line.style_dotted, width = 1)
        f_keep(rl, rn)
    else if glyph == "✕" and receiptMode == "Wins + Losses"
        label rl = label.new(n, lvl, "✕", style = side == 1 ? label.style_label_up : label.style_label_down, color = color.new(#000000, 100), textcolor = colLoss, size = f_szA(), tooltip = "Clean break: price closed through this level and did not reclaim it.")
        f_keep(rl, na)

// ═══════════════════════════════════════════════════════════════════════════
//                               POOL ENGINE
//
//  step() event codes: 0 none · 1 SWEEP (stays, watch opens) ·
//  2 clean break (removed) · 3 retired/faded (removed) · 4 reclaim (removed)
// ═══════════════════════════════════════════════════════════════════════════
method step(liqZone self) =>
    int  ev    = 0
    bool isSSL = self.side == 1

    if self.phase == 1
        if n - self.bornBar >= maxLife
            self.kill()
            ev := 3
        else
            bool broke = isSSL ? close < self.level : close > self.level
            bool swept = isSSL ? (low < self.level - minPen and close > self.level) : (high > self.level + minPen and close < self.level)
            if broke
                if graceBars > 0
                    self.phase    := 3
                    self.breakBar := n
                    self.ext      := isSSL ? low : high
                else
                    self.resolve("✕")
                    ev := 2
            else if swept
                self.phase    := 2
                self.sweepBar := n
                self.ext      := isSSL ? low : high
                self.sweepPen := atrRaw > 0 ? (isSSL ? (self.level - low) : (high - self.level)) / atrRaw : 0.0
                ev := 1

    else if self.phase == 2
        self.ext := isSSL ? math.min(nz(self.ext, low), low) : math.max(nz(self.ext, high), high)
        bool broke     = isSSL ? close < self.level : close > self.level
        bool reclaimed = isSSL ? close > self.level + confMult * atrRaw : close < self.level - confMult * atrRaw
        if broke
            self.resolve("✕")
            ev := 2
        else if reclaimed
            self.resolve("⚡")
            ev := 4
        else if n - self.sweepBar >= watchBars
            self.resolve("—")
            ev := 3

    else if self.phase == 3
        // broken — reclaim watch: a close back across the level within the
        // grace window reclassifies the break as a multi-bar sweep
        self.ext := isSSL ? math.min(self.ext, low) : math.max(self.ext, high)
        bool reclaimed = isSSL ? close > self.level : close < self.level
        if reclaimed
            self.phase    := 2
            self.sweepBar := n
            self.sweepPen := atrRaw > 0 ? (isSSL ? (self.level - self.ext) : (self.ext - self.level)) / atrRaw : 0.0
            ev := 1
        else if n - self.breakBar >= graceBars
            self.resolve("✕")
            ev := 2

    // live refresh for pools still on the board
    if ev == 0 or ev == 1
        bool sess = f_hasSession(self.level)
        bool rnd  = f_isRound(self.level)
        self.score := f_heat(self.cluster, n - self.bornBar, sess, rnd, self.volF)
        bool inRad = dispRad <= 0 or math.abs(close - self.level) <= close * dispRad / 100.0
        self.paint(self.score >= showThr and inRad, sess, rnd)
    ev

// Make room: drop the farthest out-of-radius pool first; weakest as fallback.
f_evictWeakest(array<liqZone> arr) =>
    if array.size(arr) >= maxLive
        int worst = -1
        if dispRad > 0
            float wd = -1.0
            for i = 0 to array.size(arr) - 1
                liqZone z = array.get(arr, i)
                float d = math.abs(close - z.level)
                if d > close * dispRad / 100.0 and d > wd
                    wd    := d
                    worst := i
        if worst < 0
            float ws = 1e20
            for i = 0 to array.size(arr) - 1
                liqZone z = array.get(arr, i)
                if z.score < ws
                    ws    := z.score
                    worst := i
        liqZone z = array.get(arr, worst)
        z.kill()
        array.remove(arr, worst)

// New pivot: merge into a nearby armed pool (EQH/EQL) or open a new one.
f_addPivot(array<liqZone> arr, int side, float pivot) =>
    float rv = volBase > 0 ? nz(volume[rightBars]) / volBase : 1.0
    bool merged = false
    if array.size(arr) > 0
        for z in arr
            if not merged and z.phase == 1 and math.abs(pivot - z.level) <= eqTolAbs
                z.cluster += 1
                z.level   := (z.level * (z.cluster - 1) + pivot) / z.cluster
                z.edge    := side == 1 ? z.level - atrRaw * depthMult : z.level + atrRaw * depthMult
                z.volF    := math.max(z.volF, rv)
                z.regeo()
                merged := true
    if not merged
        f_evictWeakest(arr)
        float edge = side == 1 ? pivot - atrRaw * depthMult : pivot + atrRaw * depthMult
        liqZone z = liqZone.new(phase = 1, side = side, level = pivot, edge = edge, bornBar = n - rightBars, volF = rv)
        z.build()
        array.push(arr, z)

// ═══════════════════════════════════════════════════════════════════════════
//                               MAIN LOOP
// ═══════════════════════════════════════════════════════════════════════════
bool evSweepSSL = false
bool evSweepBSL = false
bool evRevBull  = false
bool evRevBear  = false
bool evBroke    = false


if array.size(ssl) > 0
    for i = array.size(ssl) - 1 to 0
        liqZone z = array.get(ssl, i)
        int ev = z.step()
        if ev == 1
            evSweepSSL := true
        if ev == 2
            evBroke := true
        if ev == 4
            evRevBull := true
        if ev >= 2
            array.remove(ssl, i)

if array.size(bsl) > 0
    for i = array.size(bsl) - 1 to 0
        liqZone z = array.get(bsl, i)
        int ev = z.step()
        if ev == 1
            evSweepBSL := true
        if ev == 2
            evBroke := true
        if ev == 4
            evRevBear := true
        if ev >= 2
            array.remove(bsl, i)

if not na(pl) and inWindow
    f_addPivot(ssl, 1, pl)
if not na(ph) and inWindow
    f_addPivot(bsl, -1, ph)

// ═══════════════════════════════════════════════════════════════════════════
//                               RADAR DASHBOARD
// ═══════════════════════════════════════════════════════════════════════════
var table dash = table.new(f_dashCorner(), 5, 7, bgcolor = color.new(#0b0e14, 20), border_width = 1, border_color = color.new(color.gray, 80))

if showDash and barstate.islast
    string bslNm = plainMode ? "Buy stops ▲" : "BSL ▲"
    string sslNm = plainMode ? "Sell stops ▼" : "SSL ▼"
    table.clear(dash, 0, 0, 4, 6)
    table.cell(dash, 0, 0, dashTitle, text_color = #eef2f6, text_size = f_szB(), bgcolor = color.new(colWarm, 70))
    table.merge_cells(dash, 0, 0, 4, 0)
    table.cell(dash, 0, 1, "POOL",  text_color = color.gray, text_size = f_szA())
    table.cell(dash, 1, 1, "PRICE", text_color = color.gray, text_size = f_szA())
    table.cell(dash, 2, 1, "DIST",  text_color = color.gray, text_size = f_szA())
    table.cell(dash, 3, 1, "HEAT",  text_color = color.gray, text_size = f_szA())
    table.cell(dash, 4, 1, "WHY",   text_color = color.gray, text_size = f_szA())

    // nearest armed BSL above price
    liqZone upZ = na
    if array.size(bsl) > 0
        for z in bsl
            if z.phase == 1 and z.level > close and (na(upZ) or z.level < upZ.level)
                upZ := z
    if not na(upZ)
        color hcU = f_heatColor(upZ.score)
        table.cell(dash, 0, 2, bslNm, text_color = hcU, text_size = f_szB())
        table.cell(dash, 1, 2, str.tostring(upZ.level, format.mintick), text_color = #eef2f6, text_size = f_szB())
        table.cell(dash, 2, 2, str.tostring(math.round((upZ.level - close) / close * 10000) / 100) + "%", text_color = #aeb6c2, text_size = f_szB())
        table.cell(dash, 3, 2, f_heatBar(upZ.score) + " " + str.tostring(math.round(upZ.score * 10) / 10), text_color = #f5f8fa, text_size = f_szB(), bgcolor = color.new(hcU, 45))
        table.cell(dash, 4, 2, plainMode ? f_compsPlain(upZ.cluster, -1, f_isRound(upZ.level), upZ.volF, upZ.level) : f_comps(upZ.cluster, f_hasSession(upZ.level), f_isRound(upZ.level), upZ.volF), text_color = hcU, text_size = f_szB())
    else
        table.cell(dash, 0, 2, bslNm, text_color = color.gray, text_size = f_szB())
        table.cell(dash, 1, 2, "—", text_color = color.gray, text_size = f_szB())

    // nearest armed SSL below price
    liqZone dnZ = na
    if array.size(ssl) > 0
        for z in ssl
            if z.phase == 1 and z.level < close and (na(dnZ) or z.level > dnZ.level)
                dnZ := z
    if not na(dnZ)
        color hcD = f_heatColor(dnZ.score)
        table.cell(dash, 0, 3, sslNm, text_color = hcD, text_size = f_szB())
        table.cell(dash, 1, 3, str.tostring(dnZ.level, format.mintick), text_color = #eef2f6, text_size = f_szB())
        table.cell(dash, 2, 3, str.tostring(math.round((close - dnZ.level) / close * 10000) / 100) + "%", text_color = #aeb6c2, text_size = f_szB())
        table.cell(dash, 3, 3, f_heatBar(dnZ.score) + " " + str.tostring(math.round(dnZ.score * 10) / 10), text_color = #f5f8fa, text_size = f_szB(), bgcolor = color.new(hcD, 45))
        table.cell(dash, 4, 3, plainMode ? f_compsPlain(dnZ.cluster, 1, f_isRound(dnZ.level), dnZ.volF, dnZ.level) : f_comps(dnZ.cluster, f_hasSession(dnZ.level), f_isRound(dnZ.level), dnZ.volF), text_color = hcD, text_size = f_szB())
    else
        table.cell(dash, 0, 3, sslNm, text_color = color.gray, text_size = f_szB())
        table.cell(dash, 1, 3, "—", text_color = color.gray, text_size = f_szB())

    // sweep base rates — this chart's own outcome journal
    if showRates
        table.cell(dash, 0, 4, "LAST " + str.tostring(baseN) + " SWEEPS (this chart)", text_color = color.gray, text_size = f_szA(), bgcolor = color.new(#1a2027, 20))
        table.merge_cells(dash, 0, 4, 4, 4)
        int nB = array.size(bslOut)
        if nB > 0
            table.cell(dash, 0, 5, "BSL ▲", text_color = #aeb6c2, text_size = f_szB())
            table.cell(dash, 1, 5, "⚡ " + str.tostring(math.round(array.sum(bslOut) / nB * 100)) + "%", text_color = colWin, text_size = f_szB())
            table.cell(dash, 2, 5, "med " + str.tostring(math.round(array.median(bslDep) * 10) / 10) + " ATR", text_color = #aeb6c2, text_size = f_szB())
            table.cell(dash, 3, 5, "p95 " + str.tostring(math.round(array.percentile_nearest_rank(bslDep, 95) * 10) / 10), text_color = #aeb6c2, text_size = f_szB())
            table.cell(dash, 4, 5, "n=" + str.tostring(nB), text_color = color.gray, text_size = f_szB())
        else
            table.cell(dash, 0, 5, "BSL ▲", text_color = color.gray, text_size = f_szB())
            table.cell(dash, 1, 5, "—", text_color = color.gray, text_size = f_szB())
        int nS = array.size(sslOut)
        if nS > 0
            table.cell(dash, 0, 6, "SSL ▼", text_color = #aeb6c2, text_size = f_szB())
            table.cell(dash, 1, 6, "⚡ " + str.tostring(math.round(array.sum(sslOut) / nS * 100)) + "%", text_color = colWin, text_size = f_szB())
            table.cell(dash, 2, 6, "med " + str.tostring(math.round(array.median(sslDep) * 10) / 10) + " ATR", text_color = #aeb6c2, text_size = f_szB())
            table.cell(dash, 3, 6, "p95 " + str.tostring(math.round(array.percentile_nearest_rank(sslDep, 95) * 10) / 10), text_color = #aeb6c2, text_size = f_szB())
            table.cell(dash, 4, 6, "n=" + str.tostring(nS), text_color = color.gray, text_size = f_szB())
        else
            table.cell(dash, 0, 6, "SSL ▼", text_color = color.gray, text_size = f_szB())
            table.cell(dash, 1, 6, "—", text_color = color.gray, text_size = f_szB())

// ═══════════════════════════════════════════════════════════════════════════
//          SWEEP-DEPTH GUIDES (every ranked pool; gray pools stay clean)
//  The base-rate journal made visible where the decision happens: for each
//  visible pool whose on-screen rank clears the threshold, dotted lines in
//  the pool's own color showing how deep the typical and the 1-in-20 sweep
//  wick reached on this chart. Rebuilt each update.
// ═══════════════════════════════════════════════════════════════════════════
var array<line>  gLines = array.new<line>()
var array<label> gLabs  = array.new<label>()

f_drawGuide(float y, color col, string txt) =>
    array.push(gLines, line.new(n, y, n + 14, y, color = color.new(col, 45), style = line.style_dotted, width = 1))
    array.push(gLabs, label.new(n + 14, y, txt, style = label.style_label_left, color = color.new(#000000, 100), textcolor = color.new(col, 20), size = f_szA()))

if barstate.islast and showGuides
    while array.size(gLines) > 0
        line.delete(array.pop(gLines))
    while array.size(gLabs) > 0
        label.delete(array.pop(gLabs))
    if array.size(sslDep) >= 10
        float mD = array.median(sslDep)
        float pD = array.percentile_nearest_rank(sslDep, 95)
        for z in ssl
            if z.phase == 1 and z.level < close and z.score >= showThr and (dispRad <= 0 or close - z.level <= close * dispRad / 100.0) and f_heatVal(z.score) >= guideMinHv
                color hc = f_heatColor(z.score)
                f_drawGuide(z.level - mD * atrRaw, hc, "typical sweep · " + str.tostring(z.level, format.mintick))
                f_drawGuide(z.level - pD * atrRaw, hc, "1-in-20 sweep · " + str.tostring(z.level, format.mintick))
    if array.size(bslDep) >= 10
        float mU = array.median(bslDep)
        float pU = array.percentile_nearest_rank(bslDep, 95)
        for z in bsl
            if z.phase == 1 and z.level > close and z.score >= showThr and (dispRad <= 0 or z.level - close <= close * dispRad / 100.0) and f_heatVal(z.score) >= guideMinHv
                color hc = f_heatColor(z.score)
                f_drawGuide(z.level + mU * atrRaw, hc, "typical sweep · " + str.tostring(z.level, format.mintick))
                f_drawGuide(z.level + pU * atrRaw, hc, "1-in-20 sweep · " + str.tostring(z.level, format.mintick))

// ═══════════════════════════════════════════════════════════════════════════
//                               LEGEND
// ═══════════════════════════════════════════════════════════════════════════
var table lgd = table.new(position.bottom_right, 1, 5, bgcolor = color.new(#0b0e14, 35), border_width = 1, border_color = color.new(color.gray, 85))
if barstate.islast
    table.clear(lgd, 0, 0, 0, 4)
    if showLegend
        table.cell(lgd, 0, 0, "⚡ swept & reclaimed", text_color = colWin, text_size = f_szA(), text_halign = text.align_left)
        table.cell(lgd, 0, 1, "✕ broken through", text_color = colLoss, text_size = f_szA(), text_halign = text.align_left)
        table.cell(lgd, 0, 2, "⌛ break being confirmed", text_color = #aeb6c2, text_size = f_szA(), text_halign = text.align_left)
        table.cell(lgd, 0, 3, "color = rank · pink = strongest on screen", text_color = #aeb6c2, text_size = f_szA(), text_halign = text.align_left)
        string ap = ""
        if autoAsset
            ap += isForex ? "auto: FX round numbers" : ""
            ap += not hasVol ? (ap != "" ? " · " : "") + "auto: volume factor off (no volume data)" : ""
        if ap != ""
            table.cell(lgd, 0, 4, ap, text_color = color.new(#8a93a0, 20), text_size = f_szA(), text_halign = text.align_left)

// ═══════════════════════════════════════════════════════════════════════════
//                               ALERTS
// ═══════════════════════════════════════════════════════════════════════════
bool nearHotBSL = false
bool nearHotSSL = false
float prox = close * alertProx / 100.0

if array.size(bsl) > 0
    for z in bsl
        if z.phase == 1 and z.score >= hotThr and math.abs(close - z.level) <= prox
            nearHotBSL := true
if array.size(ssl) > 0
    for z in ssl
        if z.phase == 1 and z.score >= hotThr and math.abs(close - z.level) <= prox
            nearHotSSL := true

alertcondition(evSweepSSL, "Sell-Side Liquidity Sweep",       "Price wicked below a swing-low pool and closed back above it.")
alertcondition(evSweepBSL, "Buy-Side Liquidity Sweep",        "Price wicked above a swing-high pool and closed back below it.")
alertcondition(evRevBull,  "SSL Sweep + Reclaim Close",       "A sell-side sweep was followed by a confirming close back above the level (descriptive event, not a signal).")
alertcondition(evRevBear,  "BSL Sweep + Reclaim Close",       "A buy-side sweep was followed by a confirming close back below the level (descriptive event, not a signal).")
alertcondition(evBroke,    "Pool Broken (clean break)",       "Price closed through a liquidity pool without reclaiming it.")
alertcondition(nearHotBSL, "Approaching High-Rank Buy-Side Pool",  "Price is closing in on a high-prominence buy-side liquidity pool.")
alertcondition(nearHotSSL, "Approaching High-Rank Sell-Side Pool", "Price is closing in on a high-prominence sell-side liquidity pool.")
````
