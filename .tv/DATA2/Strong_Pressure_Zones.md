<!-- tradingview-pine-id: PUB;2e99be6a2e0544b4bde261226e7db88d -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Strong Pressure Zones

Source: https://www.tradingview.com/script/27MBFCQ0-Strong-Pressure-Zones-ProjectSyndicate/

## Description

Strong Pressure Zones

Strong Pressure Zones maps where market pressure is concentrated — then waits for the trap. Every swing pivot becomes a volume-weighted pressure pool, drawn as a round heat bubble sized by how much pressure sits there and stamped with a live 0–10 strength rank inside it. Then the engine watches for the one event that flips an ordinary level into a high-conviction reversal: a sweep of the zone (the liquidity grab) followed by a reclaim back through it (the failed break). A pressure pool swept below and reclaimed is a bear trap. A pool swept above and reclaimed is a bull trap. Your chart stays clean — bubbles, level bands and a number, nothing else — while the engine tracks every grab-and-reclaim underneath.

Most level tools trade the bounce or trade the break. This one grades the pressure behind the level, and trades the trap.

GBPUSD
[image]https://www.tradingview.com/x/dITmd4rM/[/image]

🫧 Pressure Bubbles — the visual that carries the read

Each pressure pool is a filled circular bubble sitting on its level. Bubble size = pressure magnitude (volume × range concentrated there), so the heaviest pools are unmistakable at a glance. The number inside = live 0–10 strength. A soft glow halo gives every pool its heat. One look tells you where pressure is stacked, how heavy it is, and how strong the level rates — without reading a single line of text off to the side.

🌐 Pressure Fuel — native on every market, aggregated on BTC

On any symbol — Gold, Silver, Forex, Indices, Futures, stocks or crypto — pressure is measured from that market's own volume, so the read is correct everywhere out of the box. On Bitcoin pairs it goes a step further and aggregates Binance + Coinbase + Bitstamp into one deeper book, so BTC magnitude reflects the broader crypto tape instead of a single venue's slice. The switch is automatic: chart a BTC pair and the multi-exchange aggregation kicks in; chart anything else and it uses that instrument's native volume — nothing to toggle.

📊 Volume × Range Magnitude — real weight, not just a wick

A pool's magnitude is volume multiplied by the bar's range at formation — the classic footprint of a level where size actually traded and leveraged positions rest. Big participation on a wide bar builds a heavy pool; a thin, quiet pivot builds a light one. Magnitude is then ranked relative to the other live pools on your chart, so the heaviest pressure always reads at the top of the scale and the map re-ranks itself as new pools form.

🎯 The Reclaim Engine — the core

Each zone is treated as a pool of resting liquidity where the crowd parks its stops. A wick that pierces a zone border by your Min Sweep Depth is a sweep — a liquidity grab, not a normal touch. If price then closes back through the zone within the Reclaim Window, the breakout has failed: that's the reclaim, the contrarian event the whole tool is built around. Grab the stops, fail the break, reverse.

🟩🟥 Multi-Zone Pool — both sides, always live

Swing-low pivots build long-pressure pools below price (support); swing-high pivots build short-pressure pools above (resistance) — a full pool of levels tracked at once, not one per side. Overlap suppression keeps the read clean, a max-bubbles cap keeps it fast, and the oldest pools recycle automatically.

XTIUSD
[image]https://www.tradingview.com/x/1XJvS8iv/[/image]

🧲 Sweep vs. Hold — the separation that matters

A wick that dips into a zone and closes back inside is a hold — it strengthens the level (its retest count). A wick that pierces clean through it by the sweep depth is a grab. The engine never confuses the two, so a genuine liquidity raid is flagged the moment it happens.

♻️ Reclaim Confirmation — border, midline, or far side

Choose how far back through the zone price must close to confirm a reclaim: the near border (loose), the midline, or the far border (strict). Deeper confirmation means fewer, higher-quality reclaims. An optional RSI momentum-extreme filter only accepts a bullish reclaim while oversold and a bearish reclaim while overbought — strictly contrarian.

💥 Genuine Break & Flip — when it isn't a trap

If price accepts beyond the border — a decisive close through, or no reclaim inside the window — the level genuinely broke. The zone doesn't just vanish: it flips its side in place and becomes a breaker, ready for break-and-retest continuation.

⚡ Sweep-Defense Memory — defended levels get stronger

Every time a zone is swept, reclaims and holds, it logs a defended sweep and its strength rises. A pool that has trapped traders and survived is exactly the pool that matters — and the ranking reflects it. Defended counts persist; they never un-count to flatter the chart.

XAUUSD
[image]https://www.tradingview.com/x/IXDVKYQg/[/image]

🔢 0–10 Strength Ranking — printed inside every bubble

Each pool carries a live grade inside the bubble, blending its pressure magnitude (ranked against the other live pools) with defense quality — held retests, volume, rejection-wick depth and defended sweeps — with idle decay so stale, ignored levels fade back down. Magnitude is what makes a level matter even before it's tested; defense is what earns it the top of the scale. Set a strength floor and weak pools simply dim out, leaving only the levels that earned attention.

📏 Recent-Only Discipline — no stale rails from 90 bars ago

Pools older than your Max Level Age are removed, so the chart shows the pressure that's actually in play right now — not a graveyard of levels dragged forward as if they were still active. Widen it when you want deeper history; keep it tight for a pure recent read.

🎨 Fully Themed & Configurable

Vertical spectrum coloring by price height (the heat look) or clean by-side coloring (teal longs / magenta shorts); adjustable bubble size boost, score text size and number format; magnitude weight, contrast and lookback; strongest/weakest transparency and glow; thick level bands (width up to 10 so lines read as zones) with their own transparency, style and projection; plus the full detection, sweep/reclaim, strength-weight and decay controls.

🔒 Honest, Non-Repainting Core

Pools anchor to confirmed swing pivots — which, like all pivots, confirm a few bars after the fact; that is inherent, not a defect. A reclaim is evaluated on the reclaim bar's close and is fixed once that bar closes; on the live forming bar it can still flicker until close, as any close-based read does. Defended-sweep counts persist and never un-count. The 0–10 strength is a descriptive ranking framework for directing attention, not a backtested edge. Multi-exchange aggregation applies on BTC pairs; every other market ranks on its own native volume automatically.

NQ
[image]https://www.tradingview.com/x/TVvZUWva/[/image]

🔔 Native Alerts

Proximity to a long/short pressure pool and to a strong pool, zone touch/retest, zone sweep (liquidity grab), zone break (accepted), and the headline events: Bullish Reclaim, Bearish Reclaim, and Any Reclaim.

🎯 Why this is different

Bounce tools fade every touch and get run over on the break. Breakout tools buy the break and get trapped on the reclaim. Strong Pressure Zones measures the pressure behind each level first, ranks the heaviest pools, then waits for the market to show its hand — the stop-raid and the failed break — and only then frames the reversal. You react to the trap, at the level that had the weight to matter.

🎯 How To Trade It — Two Approaches

Everything hinges on one read: did a heavy, high-strength pool just get swept and reclaimed?

◾ 1) Fade the trap — trade the reclaim (the core thesis)

Use when a large, high-strength pool is swept and price closes back through it.

▪️ Mark the strong pools (7+) — big bubble, high number. These are the levels with the weight worth defending.
▪️ Wait for the sweep: price wicks clean through the pool, grabbing the liquidity resting beyond it (Zone Sweep alert).
▪️ Trigger: price closes back through the pool within the reclaim window (Bullish / Bearish Reclaim alert). The breakout failed.
▪️ Entry: on the reclaim, in the reclaim's direction — long when a long-pressure pool is swept low and reclaims, short when a short-pressure pool is swept high and reclaims.
▪️ Stop: beyond the sweep extreme; if price re-breaks and accepts there, it was real acceptance, not a trap — stand aside.
▪️ Target: the opposite side of the pool first, then the next pool / unswept level in your direction.

⚖️ The cleanest version: a heavy long-pressure pool (big bubble, 8/10, already carrying a defended sweep) gets raided — price spears below it and stops out the longs — then snaps back and closes above it within a couple of bars on a volume surge, RSI stretched oversold. Grab, fail, reverse. That is the exact event this tool is built to frame.

◾ 2) Stand down — the map says wait
▪️ Clean acceptance, not a reclaim — price closed and held beyond the border (Zone Break alert). The level genuinely broke; don't fade it.
▪️ Light, weak pools only — small bubbles and low numbers everywhere means nothing heavy worth defending. Let structure develop.
▪️ No sweep yet — a pool being approached is not a pool being reclaimed. Wait for the grab and the close back through.

Rule of thumb: heavy pool + strong number + sweep + reclaim in the same direction → fade the trap toward the pool's far side. Genuine break/acceptance, light/weak pools, or no reclaim yet → stand down until the map agrees.

🚀 Markets & Timeframes

Works on every market, on any timeframe — Gold (XAUUSD), Silver, Forex, Indices, Futures, stocks and Crypto. The pressure-and-reclaim logic is symbol-agnostic: each instrument is ranked on its own volume, so you get the same clean read on gold, the DAX, EURUSD or an equity that you get on BTC. Bitcoin pairs additionally benefit from multi-exchange (Binance + Coinbase + Bitstamp) aggregation for a deeper pressure picture — applied automatically, nothing to switch. Where a symbol carries little or no volume, magnitude leans on range and the sweep-and-reclaim engine still works in full.

💡 Cleanest Setup

Raise Min Sweep Depth and set Reclaim Confirmation to Midline or Far Border for fewer, cleaner traps; keep Max Level Age tight so only live pressure shows; nudge Magnitude Weight toward 0.8 if you want size to dominate the ranking, or down toward 0.5 to reward defended levels more; and keep the RSI filter on when you want strictly contrarian reclaims.

---

## Source Code

````pine
//@version=6
indicator("Strong Pressure Zones", overlay = true, max_labels_count = 500, max_lines_count = 500, max_bars_back = 2000)

// ─────────────────────────────────────────────────────────────────────────────────────────────
// EXCHANGE VOLUME (liquidation fuel)
// ─────────────────────────────────────────────────────────────────────────────────────────────
gX = "═══ Multi-Exchange Volume (BTC only) ═══"
useBinance  = input.bool(true,  "Binance BTCUSD",  group = gX, tooltip = "On BTC pairs, aggregate these venues' volume for a fuller pressure read. On Gold, FX, indices, futures and other crypto the indicator uses that market's own native chart volume automatically — these toggles are ignored there.")
useCoinbase = input.bool(true,  "Coinbase BTCUSD", group = gX)
useBitstamp = input.bool(true,  "Bitstamp BTCUSD", group = gX)

// ─────────────────────────────────────────────────────────────────────────────────────────────
// CLUSTER DETECTION
// ─────────────────────────────────────────────────────────────────────────────────────────────
gD = "═══ Cluster Detection ═══"
mode      = input.string("Both", "Cluster Side", options = ["Both", "Longs Only (below)", "Shorts Only (above)"], group = gD, tooltip = "Long-liquidation clusters form under price at swing lows; short-liquidation clusters form above at swing highs.")
leftBars  = input.int(12, "Pivot Left",  minval = 1, group = gD)
rightBars = input.int(4,  "Pivot Right", minval = 1, group = gD)
secPivot  = input.int(0,  "Secondary Pivot (0 = off)", minval = 0, maxval = 30, group = gD, tooltip = "Optional finer pivot pass for extra bubbles. Off by default to keep the chart clean.")
lookbackW = input.int(3000, "Lookback (bars, 0 = all)", minval = 0, group = gD)
maxZones  = input.int(40, "Max Live Bubbles", minval = 2, maxval = 60, group = gD, tooltip = "Oldest clusters recycle past this so the chart stays clean and fast.")
maxLife   = input.int(400, "Only Recent — Max Level Age (bars)", minval = 10, group = gD, tooltip = "Levels older than this are removed so only recent liquidation levels show. Raise it to keep older levels on the chart.")
minMag    = input.float(0.0, "Min Magnitude To Plot (0-1)", minval = 0.0, maxval = 1.0, step = 0.05, group = gD, tooltip = "Hide small clusters. 0 = show everything, higher = only the heaviest pools.")
hideOverlap = input.bool(true, "Merge Overlapping Clusters", group = gD)
overlapThr  = input.int(35, "Overlap Threshold (%)", minval = 1, maxval = 100, group = gD)

gBnd = "═══ Detection Band ═══"
bandMode = input.string("ATR Based", "Band Height", options = ["ATR Based", "Fixed %"], group = gBnd, tooltip = "Invisible band around each level used only for touch / sweep detection.")
bandATR  = input.float(0.5, "Band (ATR Mult)", minval = 0.05, maxval = 6.0, step = 0.05, group = gBnd)
bandPct  = input.float(0.25, "Band (% of Price)", minval = 0.01, maxval = 5.0, step = 0.05, group = gBnd)
atrLen   = input.int(200, "ATR Length", minval = 1, maxval = 500, group = gBnd)

// ─────────────────────────────────────────────────────────────────────────────────────────────
// SWEEP & RECLAIM (defense scoring)
// ─────────────────────────────────────────────────────────────────────────────────────────────
gSw = "═══ Sweep & Reclaim ═══"
alertRecl  = input.bool(true, "Fire Reclaim Alerts", group = gSw)
minDepth   = input.float(0.15, "Min Sweep Depth (ATR)", minval = 0.02, maxval = 4.0, step = 0.01, group = gSw, tooltip = "A wick must pierce THIS far past a band border to count as a liquidity sweep.")
reclaimWin = input.int(6, "Max Reclaim Window (bars)", minval = 1, maxval = 40, group = gSw)
reclaimDpt = input.string("Border", "Reclaim Confirmation", options = ["Border", "Midline", "Far Border"], group = gSw)
breakAtr   = input.float(0.9, "Decisive Break Acceptance (ATR)", minval = 0.1, maxval = 8.0, step = 0.1, group = gSw)
flipBroken = input.bool(true, "Flip Broken Clusters (breakers)", group = gSw)
useRsiConf = input.bool(false, "Require Momentum Extreme (RSI)", group = gSw)
rsiLen     = input.int(14, "RSI Length", minval = 2, maxval = 100, group = gSw)
rsiWin     = input.int(8, "RSI Extreme Window", minval = 1, maxval = 60, group = gSw)
rsiOs      = input.int(40, "RSI Oversold ≤", minval = 5, maxval = 50, group = gSw)
rsiOb      = input.int(60, "RSI Overbought ≥", minval = 50, maxval = 95, group = gSw)

// ─────────────────────────────────────────────────────────────────────────────────────────────
// STRENGTH (0-10) — the number inside each bubble
// ─────────────────────────────────────────────────────────────────────────────────────────────
gStr = "═══ Cluster Strength (0-10) ═══"
onlyStrong= input.bool(false, "Dim Weak Clusters", group = gStr)
strongThr = input.float(4.0, "Strong Threshold (score)", minval = 0, maxval = 10, step = 0.5, group = gStr)
volLen    = input.int(20, "Volume Baseline Length", minval = 1, group = gStr)
touchNorm = input.float(4.0, "Touches For Full Score", minval = 1, step = 0.5, group = gStr)
sweepNorm = input.float(2.0, "Defended Reclaims For Full Score", minval = 1, step = 0.5, group = gStr)
wTouch    = input.float(0.30, "Weight: Touches / Retests", minval = 0, maxval = 1, step = 0.05, group = gStr)
wVol      = input.float(0.20, "Weight: Volume", minval = 0, maxval = 1, step = 0.05, group = gStr)
wWick     = input.float(0.20, "Weight: Rejection Wick", minval = 0, maxval = 1, step = 0.05, group = gStr)
wSweep    = input.float(0.30, "Weight: Sweep Defense", minval = 0, maxval = 1, step = 0.05, group = gStr)
useDecay  = input.bool(true, "Decay Strength While Ignored", group = gStr)
decayBars = input.int(400, "Full Decay Over (idle bars)", minval = 20, maxval = 5000, group = gStr)
decayFloor= input.float(0.65, "Decay Floor", minval = 0.1, maxval = 1.0, step = 0.05, group = gStr)

// ─────────────────────────────────────────────────────────────────────────────────────────────
// HEAT BUBBLES
// ─────────────────────────────────────────────────────────────────────────────────────────────
gB = "═══ Bubbles ═══"
showBubbles = input.bool(true, "Show Bubbles", group = gB)
showGlow    = input.bool(true, "Soft Glow Halo", group = gB, tooltip = "A larger translucent circle behind each bubble for a soft glow.")
showScore   = input.bool(true, "Show Strength Inside Bubble", group = gB)
scoreTextSize = input.string("Normal", "Score Text Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = gB, tooltip = "Size of the strength number printed inside each bubble.")
scoreFmt      = input.bool(false, "Append /10 To Score", group = gB, tooltip = "Off = just the number (fits neatly inside the bubble). On = e.g. 8/10.")
bubbleBoost   = input.int(1, "Bubble Size Boost", minval = 0, maxval = 2, group = gB, tooltip = "Enlarge every bubble by this many size steps so the number always fits inside.")
magWeight     = input.float(0.7, "Magnitude Weight In Strength", minval = 0.0, maxval = 1.0, step = 0.05, group = gB, tooltip = "How much a cluster's size (liquidation magnitude, ranked vs the other live clusters) counts toward its 0-10 strength, vs. how well it has been defended (touches / sweeps / reclaims). At 0.7 the heaviest live pool reads ~7 on size alone and climbs toward 10 as it gets defended.")
weightLB    = input.int(1000, "Magnitude Lookback (bars)", minval = 100, maxval = 5000, group = gB, tooltip = "Window used to size and color bubbles by relative magnitude.")
magContrast = input.float(0.6, "Magnitude Contrast", minval = 0.1, maxval = 3.0, step = 0.05, group = gB, tooltip = "Higher = bigger gap between small and large bubbles.")
coreMinT    = input.int(20, "Strongest Bubble Transparency", minval = 0,  maxval = 90, group = gB)
coreMaxT    = input.int(66, "Weakest Bubble Transparency",   minval = 20, maxval = 98, group = gB)
glowExtra   = input.int(22, "Glow Extra Transparency", minval = 0, maxval = 60, group = gB)
dimTransp   = input.int(90, "Dimmed Transparency", minval = 60, maxval = 100, group = gB, tooltip = "Transparency used for weak clusters when 'Dim Weak Clusters' is on.")

// ─────────────────────────────────────────────────────────────────────────────────────────────
// LEVEL LINES  (thin horizontal level running right from each bubble → price, like the reference)
// ─────────────────────────────────────────────────────────────────────────────────────────────
gL = "═══ Level Lines ═══"
showLevels  = input.bool(true, "Show Horizontal Levels", group = gL, tooltip = "One thin heat-colored level per bubble, extending from the bubble toward current price. Count = number of bubbles, never more.")
levelWidth  = input.int(6, "Level Width", minval = 1, maxval = 10, group = gL, tooltip = "Thicker levels read as zone bands. Try 6, 8 or 10.")
levelTransp = input.int(66, "Level Transparency", minval = 0, maxval = 100, group = gL, tooltip = "Higher = fainter lines. Raise it if the levels feel busy.")
levelStyle  = input.string("Solid", "Level Style", options = ["Solid", "Dashed", "Dotted"], group = gL)
levelProj   = input.int(3, "Project Past Current Bar", minval = 0, maxval = 200, group = gL)
levelToPrice= input.bool(false, "Anchor Level At Price Instead Of Bubble", group = gL, tooltip = "On: level spans the whole visible width at the cluster price. Off: level starts at the bubble and runs right (reference look).")

// ─────────────────────────────────────────────────────────────────────────────────────────────
// STYLE
// ─────────────────────────────────────────────────────────────────────────────────────────────
gC = "═══ Style ═══"
colorMode = input.string("Spectrum (vertical)", "Color Mode", options = ["Spectrum (vertical)", "By Side"], group = gC, tooltip = "Spectrum = rainbow by price height (reference look). By Side = teal longs / magenta shorts.")
topCol    = input.color(#21c997, "Top / Long Tone",    group = gC)
midCol    = input.color(#5b6cff, "Mid Spectrum Tone",  group = gC)
botCol    = input.color(#cc24e2, "Bottom / Short Tone", group = gC)
numColor  = input.color(#ffffff, "Number Color", group = gC)

// ─────────────────────────────────────────────────────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────────────────────────────────────────────────────
gA = "═══ Alerts ═══"
alertProx = input.float(0.10, "Proximity (% of price)", minval = 0.0, step = 0.01, group = gA)
instThr   = input.float(7.0, "Strong / Institutional Score", minval = 0, maxval = 10, step = 0.5, group = gA)

// ══════════════════════════════════════════════════════════════════════════════════════════════
// HELPERS
// ══════════════════════════════════════════════════════════════════════════════════════════════
clamp01(x) => math.min(math.max(x, 0.0), 1.0)
f_tier(sc) => sc >= 8 ? "ELITE" : sc >= 6.5 ? "STRONG" : sc >= 5 ? "MODERATE" : sc >= 3 ? "WEAK" : "FORMING"
f_ageF(age) => not useDecay ? 1.0 : math.max(1.0 - (1.0 - decayFloor) * math.min(age / math.max(decayBars, 1), 1.0), decayFloor)
f_vis(sc)   => not onlyStrong or sc >= strongThr

f_rangeOverlap(float t1, float b1, float t2, float b2) =>
    float ov   = math.min(t1, t2) - math.max(b1, b2)
    float minH = math.min(t1 - b1, t2 - b2)
    ov > 0 and minH > 0 and ov / minH >= overlapThr / 100.0

// magnitude tier 0..3 → circle sizes
f_coreSize(int t) => t <= 0 ? size.small : t == 1 ? size.normal : t == 2 ? size.large : size.huge
f_glowSize(int t) => f_coreSize(t + 1)
f_numSize()       => scoreTextSize == "Tiny" ? size.tiny : scoreTextSize == "Small" ? size.small : scoreTextSize == "Large" ? size.large : scoreTextSize == "Huge" ? size.huge : size.normal
f_scoreTxt(float sc) => str.tostring(int(math.round(sc))) + (scoreFmt ? "/10" : "")
f_lineStyle()     => levelStyle == "Dashed" ? line.style_dashed : levelStyle == "Dotted" ? line.style_dotted : line.style_solid

// ══════════════════════════════════════════════════════════════════════════════════════════════
// SERIES
// ══════════════════════════════════════════════════════════════════════════════════════════════
n      = bar_index
atrRaw = math.max(nz(ta.atr(atrLen), ta.cum(high - low) / (n + 1)), syminfo.mintick)

// Multi-exchange aggregation only applies on BTC pairs; every other market (Gold, FX, indices,
// futures, other crypto) uses its own native chart volume automatically.
isBTC = syminfo.basecurrency == "BTC"
binV = useBinance  and isBTC ? request.security("BINANCE:BTCUSD",  timeframe.period, volume, gaps = barmerge.gaps_off) : 0.0
cbV  = useCoinbase and isBTC ? request.security("COINBASE:BTCUSD", timeframe.period, volume, gaps = barmerge.gaps_off) : 0.0
bsV  = useBitstamp and isBTC ? request.security("BITSTAMP:BTCUSD", timeframe.period, volume, gaps = barmerge.gaps_off) : 0.0
cumV = binV + cbV + bsV
volVal  = cumV > 0 ? cumV : volume
volBase = ta.sma(volVal, volLen)

liqWeight = volVal * (high - low) * 100.0
weightMax = math.min(ta.highest(liqWeight, weightLB), 1e10)
weightMinR= ta.lowest(liqWeight, weightLB)
weightMin = weightMinR == weightMax ? weightMax * 0.85 : weightMinR

rangeHi = ta.highest(high, weightLB)
rangeLo = ta.lowest(low,  weightLB)

rsiV   = ta.rsi(close, rsiLen)
rsiLoW = ta.lowest(rsiV, rsiWin)
rsiHiW = ta.highest(rsiV, rsiWin)
ph     = ta.pivothigh(leftBars, rightBars)
pl     = ta.pivotlow(leftBars, rightBars)
ph2    = secPivot > 0 ? ta.pivothigh(secPivot, secPivot) : na
pl2    = secPivot > 0 ? ta.pivotlow(secPivot, secPivot)  : na
inWin  = lookbackW <= 0 or (last_bar_index - n) <= lookbackW

bandH  = bandMode == "ATR Based" ? atrRaw * bandATR : close * (bandPct / 100.0)
supOn  = mode == "Both" or mode == "Longs Only (below)"
resOn  = mode == "Both" or mode == "Shorts Only (above)"

// 3-stop vertical spectrum: bottom → mid → top
f_spectrum(float t) =>
    float x = clamp01(t)
    color c = x < 0.5 ? color.from_gradient(x / 0.5, 0.0, 1.0, botCol, midCol) : color.from_gradient((x - 0.5) / 0.5, 0.0, 1.0, midCol, topCol)
    c

f_heat(float mid, int side) =>
    color c = na
    if colorMode == "By Side"
        c := side == 1 ? topCol : botCol
    else
        float vr = rangeHi - rangeLo
        float nv = vr > 0 ? clamp01((mid - rangeLo) / vr) : 0.5
        c := f_spectrum(nv)
    c

// magnitude → 0..1 and → tier
f_wnorm(float w) =>
    float den = weightMax - weightMin
    float nw  = den > 0 ? clamp01((w - weightMin) / den) : 0.5
    math.pow(nw, magContrast)

f_tierOf(float wn) => wn < 0.25 ? 0 : wn < 0.5 ? 1 : wn < 0.75 ? 2 : 3

// ══════════════════════════════════════════════════════════════════════════════════════════════
// CLUSTER TYPE
// ══════════════════════════════════════════════════════════════════════════════════════════════
type zone
    int   dir     = 1
    float top     = na
    float bot     = na
    float mid     = na
    int   bornBar = na
    int   lastBar = na
    int   touches = 0
    float volSum  = 0.0
    int   volN    = 0
    float wickSum = 0.0
    int   wickN   = 0
    int   sweeps  = 0
    int   phase   = 0
    int   swBar   = na
    float swExt   = na
    float score   = 0.0
    float weight  = 0.0
    float wNorm   = 0.0
    int   tier    = 0
    line  ln      = na
    label glow    = na
    label core    = na
    label num     = na
    bool  dead    = false

var array<zone> zones = array.new<zone>()

f_defense(zone z) =>
    tF   = math.min(z.touches / math.max(touchNorm, 1.0), 1.0)
    vF   = volBase > 0 and z.volN > 0 ? math.min((z.volSum / z.volN) / volBase, 1.0) : 0.0
    wF   = z.wickN > 0 ? math.min((z.wickSum / z.wickN) / atrRaw, 1.0) : 0.0
    sF   = math.min(z.sweeps / math.max(sweepNorm, 1.0), 1.0)
    dSum = wTouch + wVol + wWick + wSweep
    dSum > 0 ? (tF * wTouch + vF * wVol + wF * wWick + sF * wSweep) / dSum : 0.0

// build the round bubble (glow + core + number). Ends on a void setter → no CE10235.
method buildBubble(zone self) =>
    if not na(self.glow)
        label.delete(self.glow)
    if not na(self.core)
        label.delete(self.core)
    if not na(self.num)
        label.delete(self.num)
    self.glow := na
    self.core := na
    self.num  := na
    if showBubbles
        color base = f_heat(self.mid, self.dir)
        int   t    = math.min(self.tier + bubbleBoost, 3)
        if showGlow
            self.glow := label.new(self.bornBar, self.mid, "", xloc = xloc.bar_index, style = label.style_circle, color = color.new(base, math.min(coreMaxT + glowExtra, 98)), size = f_glowSize(t))
        self.core := label.new(self.bornBar, self.mid, "", xloc = xloc.bar_index, style = label.style_circle, color = color.new(base, coreMaxT), size = f_coreSize(t))
        if showScore
            self.num := label.new(self.bornBar, self.mid, "", xloc = xloc.bar_index, style = label.style_label_center, color = color.new(color.black, 100), textcolor = numColor, size = f_numSize())
    if not na(self.core)
        label.set_xy(self.core, self.bornBar, self.mid)

// live update of colour + number. Ends on a void setter → no CE10235.
method refresh(zone self, float sc, bool vis) =>
    color base = f_heat(self.mid, self.dir)
    float ctf  = vis ? (onlyStrong and not f_vis(sc) ? dimTransp : coreMaxT - (coreMaxT - coreMinT) * clamp01(sc / 10.0)) : 100.0
    int   ct   = int(math.round(ctf))
    // horizontal level line (from the bubble → right, toward price)
    if showLevels and vis
        int lx1  = levelToPrice ? math.max(0, bar_index - 4000) : self.bornBar
        int lx2  = n + levelProj
        int levT = onlyStrong and not f_vis(sc) ? math.min(levelTransp + 20, 100) : levelTransp
        if na(self.ln)
            self.ln := line.new(lx1, self.mid, lx2, self.mid, xloc = xloc.bar_index, color = color.new(base, levT), width = levelWidth, style = f_lineStyle())
        else
            line.set_xy1(self.ln, lx1, self.mid)
            line.set_xy2(self.ln, lx2, self.mid)
        if not na(self.ln)
            line.set_color(self.ln, color.new(base, levT))
            line.set_style(self.ln, f_lineStyle())
            line.set_width(self.ln, levelWidth)
    else if not na(self.ln)
        line.delete(self.ln)
        self.ln := na
    // bubble colours + size (tier is ranked live vs other clusters)
    int et = math.min(self.tier + bubbleBoost, 3)
    if not na(self.core)
        label.set_color(self.core, color.new(base, ct))
        label.set_size(self.core, f_coreSize(et))
    if not na(self.glow)
        label.set_color(self.glow, color.new(base, math.min(ct + glowExtra, 100)))
        label.set_size(self.glow, f_glowSize(et))
    if not na(self.num)
        label.set_text(self.num, vis ? f_scoreTxt(sc) : "")
        label.set_textcolor(self.num, color.new(numColor, ct >= 100 ? 100 : 0))
        label.set_size(self.num, f_numSize())
    if not na(self.core)
        label.set_xy(self.core, self.bornBar, self.mid)

method kill(zone self) =>
    if not na(self.ln)
        line.delete(self.ln)
    if not na(self.glow)
        label.delete(self.glow)
    if not na(self.core)
        label.delete(self.core)
    if not na(self.num)
        label.delete(self.num)
    self.dead := true

f_overlapsActive(float t, float b) =>
    bool hit = false
    if array.size(zones) > 0
        for z in zones
            if not z.dead and z.phase != 1 and f_rangeOverlap(t, b, z.top, z.bot)
                hit := true
                break
    hit

f_spawn(int side, float lvl, float w) =>
    float wn = f_wnorm(nz(w))
    float t  = lvl + bandH / 2.0
    float b  = lvl - bandH / 2.0
    if wn >= minMag and not (hideOverlap and f_overlapsActive(t, b))
        z = zone.new()
        z.dir     := side
        z.top     := t
        z.bot     := b
        z.mid     := lvl
        z.bornBar := n - rightBars
        z.lastBar := n - rightBars
        z.volSum  := nz(volVal)
        z.volN    := 1
        z.weight  := nz(w)
        z.wNorm   := wn
        z.tier    := f_tierOf(wn)
        z.buildBubble()
        array.push(zones, z)

if supOn and not na(pl) and inWin
    f_spawn(1, pl, liqWeight[rightBars])
if resOn and not na(ph) and inWin
    f_spawn(-1, ph, liqWeight[rightBars])
if supOn and secPivot > 0 and not na(pl2) and inWin
    f_spawn(1, pl2, liqWeight[secPivot])
if resOn and secPivot > 0 and not na(ph2) and inWin
    f_spawn(-1, ph2, liqWeight[secPivot])

while array.size(zones) > maxZones
    array.shift(zones).kill()

// ══════════════════════════════════════════════════════════════════════════════════════════════
// SWEEP / RECLAIM STATE MACHINE
// ══════════════════════════════════════════════════════════════════════════════════════════════
bool evTouch = false
bool evSweep = false
bool evBreak = false
bool recBull = false
bool recBear = false
reclaimDepthMul = reclaimDpt == "Far Border" ? 1.0 : reclaimDpt == "Midline" ? 0.5 : 0.0

// magnitude ranking is RELATIVE to the current live clusters (not the outlier per-bar max),
// so the heaviest live pool actually reaches 8-10 instead of everything compressing to 3-5.
float liveMaxW = 0.0
float liveMinW = 1e18
if array.size(zones) > 0
    for z in zones
        if not z.dead
            liveMaxW := math.max(liveMaxW, z.weight)
            liveMinW := math.min(liveMinW, z.weight)
if liveMaxW <= 0.0
    liveMaxW := 1.0
if liveMinW > liveMaxW
    liveMinW := 0.0

if array.size(zones) > 0
    for i = 0 to array.size(zones) - 1
        z = array.get(zones, i)
        if not z.dead
            z.volSum += nz(volVal)
            z.volN   += 1
            if n - z.bornBar >= maxLife
                z.kill()
            else
                if z.dir == 1
                    if z.phase == 0
                        if low <= z.top and low >= z.bot and close > z.bot
                            z.touches += 1
                            z.wickSum += math.max(z.top - low, 0)
                            z.wickN   += 1
                            z.lastBar := n
                            evTouch   := true
                        else if low < z.bot - minDepth * atrRaw
                            z.phase := 1
                            z.swBar := n
                            z.swExt := low
                            evSweep := true
                    else if z.phase == 1
                        z.swExt := math.min(z.swExt, low)
                        rcLvl    = z.bot + reclaimDepthMul * (z.top - z.bot)
                        accepted = close < z.bot - breakAtr * atrRaw or (n - z.swBar >= reclaimWin and close < z.bot)
                        if close > rcLvl
                            rsiOk = not useRsiConf or rsiLoW <= rsiOs
                            if alertRecl and rsiOk
                                recBull := true
                            z.sweeps  += 1
                            z.lastBar := n
                            z.phase   := 0
                        else if accepted
                            evBreak := true
                            if flipBroken
                                z.dir     := -1
                                z.touches := 0
                                z.wickSum := 0.0
                                z.wickN   := 0
                                z.phase   := 0
                                z.lastBar := n
                            else
                                z.kill()
                else
                    if z.phase == 0
                        if high >= z.bot and high <= z.top and close < z.top
                            z.touches += 1
                            z.wickSum += math.max(high - z.bot, 0)
                            z.wickN   += 1
                            z.lastBar := n
                            evTouch   := true
                        else if high > z.top + minDepth * atrRaw
                            z.phase := 1
                            z.swBar := n
                            z.swExt := high
                            evSweep := true
                    else if z.phase == 1
                        z.swExt := math.max(z.swExt, high)
                        rcLvl    = z.top - reclaimDepthMul * (z.top - z.bot)
                        accepted = close > z.top + breakAtr * atrRaw or (n - z.swBar >= reclaimWin and close > z.top)
                        if close < rcLvl
                            rsiOk = not useRsiConf or rsiHiW >= rsiOb
                            if alertRecl and rsiOk
                                recBear := true
                            z.sweeps  += 1
                            z.lastBar := n
                            z.phase   := 0
                        else if accepted
                            evBreak := true
                            if flipBroken
                                z.dir     := 1
                                z.touches := 0
                                z.wickSum := 0.0
                                z.wickN   := 0
                                z.phase   := 0
                                z.lastBar := n
                            else
                                z.kill()

                if not z.dead
                    float magN = liveMaxW > liveMinW ? clamp01((z.weight - liveMinW) / (liveMaxW - liveMinW)) : 0.5
                    magN := math.pow(magN, magContrast)
                    float defR = f_defense(z)
                    float sc   = math.min(math.max((magWeight * magN + (1.0 - magWeight) * defR * f_ageF(n - z.lastBar)) * 10.0, 1.0), 10.0)
                    z.score := sc
                    z.tier  := f_tierOf(magN)
                    vis = f_vis(sc) or z.phase == 1 or not onlyStrong
                    z.refresh(sc, vis)

if array.size(zones) > 0
    for i = array.size(zones) - 1 to 0
        if array.get(zones, i).dead
            array.remove(zones, i)

// ══════════════════════════════════════════════════════════════════════════════════════════════
// PROXIMITY ALERTS
// ══════════════════════════════════════════════════════════════════════════════════════════════
bool nearBull = false
bool nearBear = false
bool nearStrongBull = false
bool nearStrongBear = false
float prox = close * alertProx / 100.0

if array.size(zones) > 0
    for z in zones
        if not z.dead and math.abs(close - z.mid) <= prox
            if z.dir == 1
                nearBull := true
                nearStrongBull := nearStrongBull or z.score >= instThr
            else
                nearBear := true
                nearStrongBear := nearStrongBear or z.score >= instThr

// ══════════════════════════════════════════════════════════════════════════════════════════════
// ALERTS
// ══════════════════════════════════════════════════════════════════════════════════════════════
alertcondition(nearBull,       "Long-Liq Cluster Proximity",    "Price approaching a long-liquidation cluster (support).")
alertcondition(nearBear,       "Short-Liq Cluster Proximity",   "Price approaching a short-liquidation cluster (resistance).")
alertcondition(nearStrongBull, "Strong Long-Liq Proximity",     "Price approaching a STRONG long-liquidation cluster.")
alertcondition(nearStrongBear, "Strong Short-Liq Proximity",    "Price approaching a STRONG short-liquidation cluster.")
alertcondition(evTouch,        "Cluster Touch / Retest",        "Price tested and held a liquidation cluster.")
alertcondition(evSweep,        "Cluster Sweep (liquidity grab)","Price swept beyond a cluster — watch for a reclaim.")
alertcondition(evBreak,        "Cluster Break (accepted)",      "A liquidation cluster was genuinely broken / flipped.")
alertcondition(recBull,        "Bullish Reclaim",               "Sweep below a cluster was reclaimed — bullish.")
alertcondition(recBear,        "Bearish Reclaim",               "Sweep above a cluster was reclaimed — bearish.")
alertcondition(recBull or recBear, "Any Reclaim",               "A sweep-and-reclaim fired.")
````
