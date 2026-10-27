# Order-Flow Profile  Microstructure & Calibrated Sweeps

- url: https://www.tradingview.com/script/PF7kVFtK-Order-Flow-Profile-Microstructure-Calibrated-Sweeps/
- type: indicator
- pine_id: PUB;1647ea7c49d142979d628df74d6ee425
- version: 1.0

## Description

Order-Flow Profile — Footprint, Microstructure & Calibrated Sweeps

A single-pane volume profile that reconstructs intrabar buy/sell activity, renders it as a footprint / delta heatmap with Point of Control and a 70% Value Area, layers a stack of market-microstructure factors over the same price bins, and then forward-tests every reversal signal it emits against realized outcomes. The dashboard reports measured edge with confidence intervals — not asserted edge.

It runs on any liquid symbol and any intraday timeframe. Defaults are tuned for index futures (e.g. NIFTY / BANKNIFTY); a few inputs adapt it to other instruments.


What it plots

Order-flow profile drawn to the right of price: each price bin colored by who controlled it (delta) with brightness scaled to volume, or a classic split footprint. The peak-volume row is the POC; a 70% Value Area is built outward from the POC.
Low-volume nodes / voids and four quadrant deltas that localize where buying and selling concentrated within the range.

A VPIN heat-glow background whose brightness rises with flow toxicity.
Sweep tags (ABS / EXH / DIV / REJ) at liquidity extremes, and a ⚡ reclaim-confirmed liquidity-sweep marker for the high-conviction stop-run-and-reclaim subset.
A calibration / key-reads dashboard (Compact by default, Pro on demand) that adapts its colors to your chart's background luminance.


Why these components belong in one script (component rationale)

This is not a bundle of unrelated indicators stacked together. Every component describes one object — the order-flow auction taking place inside the price profile — and each measures a different facet of it. They share one substrate (the price bins) and one validation spine (the calibration engine):


The profile says WHERE volume traded. POC, Value Area and voids are the structural skeleton — the price levels that matter.

Trade classification splits that volume into buy vs sell, giving every bin a delta. Bulk Volume Classification (a Student-t CDF on the standardized intrabar move) is used by default; on Premium plans, native bid/ask footprint can replace it, feeding the same bins. A tick rule classifies the same intrabars in parallel and the agreement % is reported, so you know when the trade-side read is fragile.

The microstructure factors qualify HOW that flow behaves at those levels. VPIN (informed vs balanced), multi-level OFI (depth-weighted imbalance across the bins), Kyle's λ and Amihud (price impact / illiquidity), and √-law absorption (flow soaked up vs fragile) each answer a question the raw profile cannot. They are computed over the very bins the profile draws.
The sweep layers detect reversals AT those levels — an order-flow taxonomy (absorption / exhaustion / divergence / rejection) plus a structural stop-run-and-reclaim. A Hawkes self-exciting intensity flags when sweeps are clustering (cascade risk).

A correlation-aware fusion (Kish design-effect shrinkage) combines the firing sweep's realized edge with the concurrent absorption and toxicity tells into a single reversal probability — shrinking redundant, correlated evidence so agreement among related signals cannot masquerade as independent confirmation.

The calibration spine forward-resolves every sweep and reports its hit rate versus base rate with a Wilson confidence interval. This is what ties the stack together: a factor only earns trust if the resolved outcomes say it does.

Remove any one layer and the others lose context: the profile without classification is just a volume histogram; the microstructure factors without the profile have no levels to attach to; the sweeps without calibration are unverified claims. Together they are a single, self-checking read of the auction.


How it works (mechanics)

Intrabar data. Lower-timeframe OHLCV is pulled with request.security_lower_tf (no lookahead). The lower timeframe is auto-derived from the chart timeframe or set manually.
Trade side. Bulk Volume Classification assigns each intrabar a buy fraction from a Student-t CDF of its standardized price change; delta = buy − sell. Where a Premium/Ultimate plan allows it, native request.footprint() real bid/ask volume per price replaces the reconstruction and feeds the identical bins.

Profile build. On the last bar, the chosen lookback of confirmed bars is accumulated into price bins; POC and the 70% Value Area are derived, voids and quadrant deltas computed.
VPIN. Volume is partitioned into equal-volume buckets; the average order imbalance across the last N buckets is the 0–1 toxicity read (with a percentile and background glow).
Impact factors. Stationarized (log-compressed, z-scored) OFI; depth-weighted multi-level OFI across the bins; Kyle's λ as the regression slope of return on signed flow; Amihud illiquidity as |return| per traded value.

Absorption. A displacement-normalized form and a √-law form (realized impact vs Y·ATR·√(|Δ|/V)): below the prediction = passive absorption / reversal candidate; above = fragile expansion.

Sweeps & fusion. At a swept extreme the bar is classified ABS / EXH / DIV / REJ; a Hawkes intensity tracks clustering; a Kish-decorrelated log-odds fusion outputs one reversal probability. Separately, a reclaim-confirmed liquidity sweep fires when price runs a confirmed swing pivot, closes back inside recovering a minimum fraction of the run, on a volume spike.

Calibration. Each sweep is queued and resolved a fixed horizon later against a moveATR·ATR threshold, recorded in R-multiples (MFE / MAE). The dashboard shows, per class: sample count, Hit% ± Wilson interval, Base% (the unconditional reversal rate over the same horizon), Edge (Hit − Base, starred at 95% significance), and average MFE / MAE.


Non-repaint: all detection is on confirmed bars, lower-timeframe arrays are confirmed intrabars, no dynamic-length built-ins are used, and the profile is drawn on the last bar from confirmed history. Pivots used by the liquidity sweep are confirmed before they can be swept.

What makes it original

It is built around calibration, not assertion. Most order-flow tools print a delta, a "confidence," or a footprint and leave it there. Here every reversal signal is forward-resolved against realized price and reported with a base rate and a Wilson interval, so the dashboard distinguishes a real edge from a small-sample illusion.

The agreement between Bulk Volume Classification and a tick rule is surfaced openly — a known weakness of reconstructed order flow is shown rather than hidden.
The microstructure factors are computed over the profile's own bins and decorrelated before fusion, so correlated flow signals don't inflate confidence.

It degrades gracefully from native exchange footprint (Premium) to reconstruction (every plan) with no change to the visual or the workflow.

All factor implementations are original Pine re-derivations of published methods; no code from other scripts is used.

How to use it

Apply to a liquid symbol on an intraday timeframe. Read the profile to see where volume concentrated (POC, Value Area, voids).

Watch the sweep tags and ⚡ liquidity-sweep markers at the edges of the range — these are reversal hypotheses, not guarantees.

Before trusting a sweep class, check its row in the calibration panel (switch the dashboard to Pro): is its Hit% above Base%, is the edge starred (significant), and is the Wilson interval tight enough to mean something?

Use the VPIN glow and fused reversal probability as context: bright background = one-sided / informed flow, which leans toward continuation and makes fades riskier.

The Compact dashboard summarizes the key reads (POC, VPIN, best calibrated edge, fused probability, liquidity-sweep status, auction efficiency); Pro expands the full per-class calibration table and every microstructure row.

Hidden EXP_* data-window series are provided for chaining into other scripts via input.source().

Data & markets

Works on whatever symbol the chart shows — nothing is hard-coded to an exchange or instrument. Defaults suit index futures on an intraday chart. For other instruments, adjust the Profile & Data Source group (lower-timeframe division, profile lookback) and, on a supporting plan, the native footprint settings. Reconstructed order flow is most reliable on liquid instruments with continuous volume.

Concept credits

This script operationalizes published methods; all implementations are original re-derivations.


Tick rule / trade sign — Lee & Ready (1991)
Bulk Volume Classification & flow toxicity (VPIN) — Easley, López de Prado & O'Hara (2012)
Order-Flow Imbalance — Cont, Kukanov & Stoikov (2014)
Multi-level / integrated OFI — Xu, Gould & Howison (2018)
Price impact (λ) — Kyle (1985)
Illiquidity ratio — Amihud (2002)
Self-exciting intensity — Hawkes (1971); Bacry, Muzy et al.
Square-root impact law — Almgren et al.; Tóth, Bouchaud et al.
Effective-sample decorrelation — Kish design effect
Market / auction profile (POC, Value Area) — Steidlmayer
Confidence interval — Wilson score interval (1927)

Disclaimer

For educational and informational purposes only. This is an analytical tool, not financial advice and not a solicitation to trade, and it is not a guarantee of future results. Order-flow classification from OHLCV is an estimate, not the true tape — without a Level-2 order book every delta here is a proxy (native footprint excepted). Always do your own research and manage risk; paper-trade before committing real capital.

## Source Code

````pine
// ══════════════════════════════════════════════════════════════════════════════
//  Order-Flow Profile — Footprint, Microstructure & Calibrated Sweeps         v3.0
// ──────────────────────────────────────────────────────────────────────────────
//  WHAT THIS IS
//    A single-pane volume PROFILE that reconstructs intrabar buy/sell activity,
//    renders it as a footprint / delta heatmap with POC and a 70% Value Area, and
//    layers a stack of market-microstructure factors over the same price bins.
//    Every reversal signal it emits is then FORWARD-TESTED against realized
//    outcomes, so the dashboard reports measured edge, not asserted edge.
//
//  WHY THIS IS ONE TOOL, NOT A BUNDLE (component rationale)
//    These pieces are not independent indicators stacked for show — they all
//    describe ONE object: the order-flow auction inside the price profile.
//      • The PROFILE says WHERE volume traded (POC / Value Area / voids).
//      • TRADE CLASSIFICATION (BVC, or native bid/ask footprint) splits that
//        volume buy vs sell, giving every bin a delta.
//      • The MICROSTRUCTURE factors (VPIN toxicity, multi-level OFI, Kyle's λ,
//        Amihud, Hawkes intensity, √-law absorption) qualify HOW that flow is
//        behaving at the profile's key levels — informed vs balanced, absorbed
//        vs fragile, clustering vs diffuse.
//      • The SWEEP layers detect reversals AT those levels — an order-flow
//        taxonomy (absorption / exhaustion / divergence / rejection) plus a
//        structural stop-run-and-reclaim.
//      • The CALIBRATION spine forward-resolves every sweep and reports its hit
//        rate vs base rate with a confidence interval, so redundant signals can't
//        masquerade as edge. One price-bin substrate, one calibration spine.
//
//  THE STACK
//    • Lower-timeframe aggregation (request.security_lower_tf) → intrabar OHLCV.
//    • Trade side: Bulk Volume Classification — buyFrac = Student-t CDF(ΔP/σ, ν);
//      delta = buy − sell. A tick rule classifies the same intrabars in parallel
//      and the AGREEMENT % is reported (BVC can be inferior to a tick rule — shown
//      openly). On Premium, native request.footprint() real bid/ask can replace
//      the reconstruction, feeding the SAME bins.
//    • Profile rendered as a delta HEATMAP (bin color = controlling side,
//      brightness = volume) or split footprint; POC = peak row; 70% Value Area
//      built POC-outward; LVN/voids; 4 quadrant deltas.
//    • VPIN flow toxicity (equal-volume buckets) with a heat-glow background.
//    • Stationarized OFI z-score, depth-weighted multi-level OFI across the bins,
//      Kyle's λ (price impact), Amihud illiquidity.
//    • Absorption: displacement-normalized and √-law (impact-theory) forms.
//    • Sweep taxonomy (ABS / EXH / DIV / REJ) + Hawkes self-exciting intensity
//      (cascade) + Kish-decorrelated log-odds fusion → one reversal probability.
//    • ⚡ reclaim-confirmed liquidity sweep: ran a confirmed swing pivot, closed
//      back inside recovering ≥X% of the run, on a volume spike (non-repaint).
//
//  THE DIFFERENTIATOR — CALIBRATION
//    Every sweep is a reversal hypothesis. It is queued and resolved a fixed
//    horizon later against a moveATR·ATR threshold, in R-multiples (MFE/MAE). The
//    dashboard shows, per class: n · Hit%±WilsonCI · Base% · Edge(Hit−Base,
//    *=95% z) · MFE/MAE(R). Base% is the unconditional reversal rate over the same
//    horizon; the Wilson interval shows how firm the estimate is. No naked
//    win-rates, nothing asserted that isn't measured.
//
//  CONCEPT CREDITS (methods operationalized — original Pine re-derivations)
//    Tick rule / trade sign ........ Lee & Ready (1991)
//    Bulk Volume Classification .... Easley, López de Prado & O'Hara (2012)
//    Flow toxicity (VPIN) .......... Easley, López de Prado & O'Hara (2012)
//    Order-Flow Imbalance .......... Cont, Kukanov & Stoikov (2014)
//    Multi-level / integrated OFI .. Xu, Gould & Howison (2018)
//    Price impact (λ) .............. Kyle (1985)
//    Illiquidity ratio ............. Amihud (2002)
//    Self-exciting intensity ....... Hawkes (1971); Bacry, Muzy et al.
//    Square-root impact law ........ Almgren et al.; Tóth, Bouchaud et al.
//    Effective-sample decorrelation  Kish design effect
//    Market / auction profile ...... Steidlmayer (POC / Value Area)
//    Wilson score interval ......... Wilson (1927)
//
//  DATA SOURCE — WORKS ON ANY MARKET
//    Runs on whatever symbol the chart shows. Defaults are tuned for index
//    futures on an intraday chart (e.g. NIFTY/BANKNIFTY); for other instruments
//    adjust the Data Source group (lower-timeframe division, profile lookback,
//    footprint mode). Nothing is hard-coded to a specific exchange or symbol.
//
//  NON-REPAINT
//    Detection on barstate.isconfirmed; LTF arrays are confirmed intrabars;
//    no dynamic-length ta(); profile drawn on the last bar from confirmed history.
//
//  EXPORTS (Data Window, Exports toggle) — consume via input.source() elsewhere:
//    EXP_Delta · EXP_CVD · EXP_Absorb · EXP_POC · EXP_SweepCls · EXP_ClsEdge ·
//    EXP_ClfAgree · EXP_VPIN · EXP_OFIz · EXP_KyleLambda · EXP_Amihud ·
//    EXP_Hawkes · EXP_FusedP · EXP_OFIml · EXP_AuctionEff · EXP_SqrtAbs ·
//    EXP_LiqSweep
//
//  DISCLAIMER
//    EDUCATIONAL / INFORMATIONAL only. NOT financial advice and NOT a solicitation
//    to trade. Past performance does not guarantee future results. Order-flow
//    classification from OHLCV is an ESTIMATE, not the true tape — without a
//    Level-2 book every delta here is a proxy (native footprint excepted). Do your
//    own research and manage risk; paper-trade before committing real capital.
// ══════════════════════════════════════════════════════════════════════════════

//@version=6
indicator("Order-Flow Profile — Footprint, Microstructure & Calibrated Sweeps", "OF Profile",
     overlay              = true,
     max_lines_count      = 500,
     max_labels_count     = 500,
     max_boxes_count      = 500,
     max_bars_back        = 5000,
     dynamic_requests     = true)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SECTION 1 — INPUTS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
g1 = "1 · Profile & Data Source"
g2 = "2 · Trade Classification (BVC)"
g3 = "4 · Order-Flow Sweeps"
gLS= "5 · Liquidity Sweep (Reclaim)"
g4 = "6 · Calibration"
gV = "3 · Microstructure"
g5 = "7 · Display"
gT = "8 · Theme"
gE = "9 · Exports"

profLen  = input.int(120, "Profile Lookback (bars)", minval = 20, maxval = 480, group = g1, tooltip = "How many chart bars feed the price profile, drawn on the last bar.")
rows     = input.int(24,  "Profile Rows",             minval = 8,  maxval = 60,  group = g1)
profW    = input.int(90,  "Profile Width (bars)",     minval = 20, maxval = 240, group = g1, tooltip = "Max horizontal extent of the profile, in bars, to the right of price.")
voidFrac = input.float(0.18, "Void Threshold (×peak)", minval = 0.02, maxval = 0.5, step = 0.02, group = g1, tooltip = "A row is a VOID/LVN if its volume is a local trough below this fraction of the peak row.")
showVA   = input.bool(true, "Show Value Area (70%)",   group = g1)
profStyle= input.string("Heatmap", "Profile Style", ["Heatmap", "Split Footprint"], group = g1, tooltip = "Heatmap: each price bin is colored by net delta (who controlled that price), brightness by volume traded there. Split Footprint: classic buy-inside / sell-outside bars.")
profSource = input.string("BVC Reconstruction", "Profile Data Source", ["BVC Reconstruction", "Native footprint (Premium)", "Auto"], group = g1, tooltip = "BVC Reconstruction (default): every plan — buy/sell split inferred from LTF price action. Native footprint: real exchange bid/ask volume per price via request.footprint() — Premium/Ultimate only, current chart timeframe. Auto: native where available, BVC fallback per bar. Native feeds the SAME bins/heatmap/POC/value-area and the live order-flow reads; the visual is unchanged, the data underneath gets real.")
fpTicks  = input.int(5,   "Native: ticks per row", minval = 1, maxval = 1000, group = g1, tooltip = "Price granularity of each native footprint row (1 tick = syminfo.mintick). ~5 for NIFTY; scale up for high-priced instruments.")
fpVA     = input.int(70,  "Native: Value Area %",  minval = 30, maxval = 90, group = g1)
fpImb    = input.int(300, "Native: imbalance % (300 = 3×)", minval = 100, maxval = 900, group = g1)

ltfMode  = input.string("Auto", "Lower Timeframe", ["Auto", "Manual"], group = g1, tooltip = "The lower timeframe whose intrabars reconstruct order flow. Auto derives it from the chart timeframe; Manual lets you pin it. This is the raw-data source — change it (and the divisor) for very fast or very slow instruments.")
ltfMan   = input.timeframe("1", "Manual LTF",        group = g1, tooltip = "Used when Lower Timeframe = Manual. Must be lower than the chart timeframe.")
ltfDiv   = input.int(12, "Auto LTF Divisor",         minval = 3, maxval = 60, group = g1, tooltip = "Auto LTF ≈ chart timeframe ÷ this. Higher = finer intrabars (heavier).")
clsMode  = input.string("Student-t", "Classifier",   ["Student-t", "Normal"], group = g2, tooltip = "Student-t CDF (fat-tailed, BVC-faithful) or Normal CDF (faster).")
crossChk = input.bool(true, "Tick-Rule Cross-Check", group = g2, tooltip = "Classify the same intrabars with a tick rule and report how often it AGREES with BVC. Low agreement means the trade-side read is unreliable on this symbol/timeframe — a known BVC weakness, surfaced honestly.")
tDf      = input.float(4.0, "Student-t ν (dof)",     minval = 1.0, maxval = 30.0, step = 0.5, group = g2, tooltip = "Degrees of freedom. Lower = fatter tails = sharper buy/sell split.")
sigLen   = input.int(100, "σ Estimation Length",     minval = 20, maxval = 300, group = g2, tooltip = "Fallback volatility for standardization when a bar has too few intrabars.")

swLook   = input.int(20, "Sweep Pivot Lookback",     minval = 5,  maxval = 80, group = g3, tooltip = "Bars used to define the prior swing high/low a sweep must exceed.")
volLen   = input.int(20, "Volume MA Length",         minval = 5,  maxval = 100, group = g3)
exhFrac  = input.float(0.75, "EXH Vol Ceiling (×MA)", minval = 0.2, maxval = 1.0, step = 0.05, group = g3, tooltip = "A dry sweep (EXH) requires bar volume below this multiple of its average.")
absFloor = input.float(1.5,  "ABS Absorption Floor",  minval = 0.5, maxval = 5.0, step = 0.1, group = g3, tooltip = "Minimum displacement-normalized absorption for an ABS classification.")
wickFrac = input.float(0.5,  "REJ Wick Ratio",        minval = 0.3, maxval = 0.8, step = 0.05, group = g3, tooltip = "Rejection wick must be at least this fraction of the bar range.")

// reclaim-confirmed liquidity sweep — classic stop-run + reclaim + volume spike
liqEnable   = input.bool(true,  "Enable ⚡ Liquidity Sweep", group = gLS, tooltip = "Marks the high-conviction reversal subset: price runs a recent swing pivot (where stops/breakout liquidity rest), then RECLAIMS — closes back inside, recovering a minimum % of the run — on a volume spike. Independent of the ABS/EXH/DIV/REJ taxonomy; this is the pure structural stop-hunt-and-reclaim.")
liqPivLeft  = input.int(5,   "Pivot left bars",        minval = 2, maxval = 20, group = gLS, tooltip = "Bars on the left of a swing pivot used to define the level being swept.")
liqPivRight = input.int(2,   "Pivot right bars",       minval = 1, maxval = 10, group = gLS, tooltip = "Bars on the right confirming the pivot (the level is fixed this many bars before it can be swept — keeps it non-repainting).")
liqLookback = input.int(20,  "Pivot search window",    minval = 5, maxval = 50, group = gLS, tooltip = "How far back to find the most recent swing high/low to test against.")
liqVolMul   = input.float(1.3, "Volume spike (×20-bar avg)", minval = 1.0, maxval = 3.0, step = 0.1, group = gLS, tooltip = "Bar volume must exceed this multiple of the 20-bar average to confirm a real sweep (not a quiet wick poke).")
liqReclaim  = input.float(0.4, "Min reclaim (% of run)", minval = 0.2, maxval = 0.8, step = 0.05, group = gLS, tooltip = "How much of the penetration beyond the level must be reclaimed by the close. 0.4 = close recovers 40%+ of the run back inside.")
liqMarkSize = input.string("Small", "⚡ marker size", ["Tiny", "Small", "Normal", "Large"], group = gLS)

horizon  = input.int(12,  "Eval Horizon (bars)",     minval = 3,  maxval = 60, group = g4, tooltip = "Bars ahead at which each sweep's reversal hypothesis is resolved.")
moveATR  = input.float(1.0, "Win Threshold (×ATR)",   minval = 0.2, maxval = 4.0, step = 0.1, group = g4, tooltip = "Reversal counts as a win if price travels this many ATR in the reversal direction within the horizon.")
atrLen   = input.int(14,  "ATR Length (R unit)",      minval = 5,  maxval = 50, group = g4)

showVPIN = input.bool(true, "VPIN Toxicity", group = gV, tooltip = "Volume-synchronized Probability of Informed trading (Easley, López de Prado, O'Hara). Volume is split into equal-volume BUCKETS; each bucket's |buy−sell|/volume imbalance is averaged over the last N buckets → a 0–1 toxicity read. High VPIN = one-sided, informed flow, which tends to precede directional continuation and unstable liquidity.")
vpinBuckets   = input.int(50, "VPIN Buckets (N)", minval = 5, maxval = 200, group = gV, tooltip = "How many equal-volume buckets the VPIN average spans.")
vpinBucketMlt = input.float(1.0, "Bucket Size (×volMA)", minval = 0.1, maxval = 10.0, step = 0.1, group = gV, tooltip = "Each bucket holds this multiple of the average bar volume. Smaller = finer/faster VPIN.")
vpinGlow      = input.bool(true, "VPIN Heat-Glow Background", group = gV, tooltip = "Tint the chart background by VPIN percentile — brighter = more toxic / one-sided flow.")
showOFI  = input.bool(true, "Stationarized OFI + Impact", group = gV, tooltip = "A log-compressed, z-scored Order-Flow Imbalance line (stationary, regime-comparable), plus Kyle's λ (price impact per unit signed flow) and Amihud illiquidity (|return| per traded value). Grounds absorption in impact theory rather than a raw ratio.")
ofiLen   = input.int(50, "OFI z-score Window", minval = 10, maxval = 300, group = gV)
kyleLen  = input.int(50, "Kyle λ / Amihud Window", minval = 10, maxval = 300, group = gV)
showFuse = input.bool(true, "Hawkes + Log-Odds Fusion", group = gV, tooltip = "Hawkes self-exciting sweep intensity (flags sweep CLUSTERING / cascade risk) and a Kish-decorrelated Bayesian LOG-ODDS fusion that combines the firing sweep class's realized edge with the concurrent absorption / divergence / toxicity tells into ONE calibrated reversal probability.")
hawkAlpha= input.float(1.0, "Hawkes Jump (α)", minval = 0.1, maxval = 5.0, step = 0.1, group = gV, tooltip = "Intensity added by each sweep event.")
hawkBeta = input.float(0.15, "Hawkes Decay (β)", minval = 0.01, maxval = 1.0, step = 0.01, group = gV, tooltip = "Per-bar exponential decay of intensity. Lower = longer memory / slower decay.")
ofiDecay = input.float(1.5,  "Multi-level OFI depth decay (bins)", minval = 0.5, maxval = 8.0, step = 0.5, group = gV, tooltip = "Depth-weighted OFI across the profile bins (Xu-Gould-Howison): bins near the current price carry full weight, deeper bins decay over this scale. Lower = only near-price levels matter.")
sqrtY    = input.float(1.0,  "√-law impact coefficient (Y)", minval = 0.2, maxval = 3.0, step = 0.1, group = gV, tooltip = "√-law absorption (Almgren / Tóth-Bouchaud): predicted impact = Y·ATR·√(|Δ|/V). Realized ÷ predicted < 1 = passive ABSORPTION (flow soaked, price held → reversal candidate); > 1 = fragile/thin expansion. Calibrate Y so the typical ratio ≈ 1.")

showProf = input.bool(true,  "Show Profile",          group = g5)
showQuad = input.bool(true,  "Show Quadrant Delta",   group = g5)
showVoid = input.bool(true,  "Show Voids / LVN",      group = g5)
showSwp  = input.bool(true,  "Show Sweep Tags",       group = g5)
showDash = input.bool(true,  "Show Dashboard",        group = g5)
dashMode = input.string("Compact", "Dashboard Mode",      ["Compact", "Pro"], group = g5, tooltip = "Compact: the key decision reads — flow direction, BVC↔Tick trust, POC, VPIN, best calibrated sweep edge, fused reversal probability, liquidity-sweep status. Pro: adds the full per-class calibration table and every microstructure row.")
dashPos  = input.string("Top Right", "Dashboard Position", ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = g5)

themeMode = input.string("Auto", "Theme", ["Auto", "Dark", "Light"], group = gT)
upColI    = input.color(#21D7AC, "Buy / Bull",  group = gT)
dnColI    = input.color(#F2547B, "Sell / Bear", group = gT)

showEXP  = input.bool(true, "Emit EXP_* exports", group = gE, tooltip = "Hidden data-window series for input.source() consumption. Turn off to reclaim plot slots.")

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SECTION 2 — THEME, HELPERS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
_bg     = chart.bg_color
_bgLum  = 0.299 * color.r(_bg) + 0.587 * color.g(_bg) + 0.114 * color.b(_bg)
isLight = themeMode == "Light" or (themeMode == "Auto" and _bgLum > 140)

darken(color c, float f) => color.rgb(color.r(c) * f, color.g(c) * f, color.b(c) * f, color.t(c))

cBull = isLight ? darken(upColI, 0.80) : upColI
cBear = isLight ? darken(dnColI, 0.80) : dnColI
cNeu  = isLight ? #57606A : #8B949E
cTxt  = isLight ? #0A0A0A : #E6EDF3
cDim  = isLight ? #9AA4B2 : #484F58
cPanel= isLight ? #F2F4F8 : #0D1117
cHead = isLight ? #E2E6ED : #161B22
cGrid = isLight ? #C4CAD4 : #21262D
cAcc  = isLight ? #1F6FEB : #58A6FF

fmtNum(float x) =>
    float a = math.abs(x)
    a >= 1e12 ? str.tostring(x / 1e12, "0.00") + "T" :
     a >= 1e9 ? str.tostring(x / 1e9,  "0.00") + "B" :
     a >= 1e6 ? str.tostring(x / 1e6,  "0.00") + "M" :
     a >= 1e3 ? str.tostring(x / 1e3,  "0.00") + "K" : str.tostring(x, "0.##")

f_dashPos(string s) =>
    s == "Top Left" ? position.top_left : s == "Bottom Right" ? position.bottom_right :
     s == "Bottom Left" ? position.bottom_left : s == "Middle Right" ? position.middle_right : position.top_right

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SECTION 3 — CLASSIFIER MATH  (Student-t CDF via incomplete beta; Normal via erf)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// positive-branch helper (x >= 0.5) — declared first; the reflection below calls it
f_lgammaPos(float xin) =>
    float x = xin - 1.0
    float a = 0.99999999999980993
    a += 676.5203681218851     / (x + 1.0)
    a += -1259.1392167224028   / (x + 2.0)
    a += 771.32342877765313    / (x + 3.0)
    a += -176.61502916214059   / (x + 4.0)
    a += 12.507343278686905    / (x + 5.0)
    a += -0.13857109526572012  / (x + 6.0)
    a += 9.9843695780195716e-6 / (x + 7.0)
    a += 1.5056327351493116e-7 / (x + 8.0)
    float t = x + 7.5
    0.5 * math.log(2.0 * math.pi) + (x + 0.5) * math.log(t) - t + math.log(a)

// log-gamma (Lanczos, g=7) with reflection for x < 0.5
f_lgamma(float xin) =>
    float res = 0.0
    if xin < 0.5
        res := math.log(math.pi / math.sin(math.pi * xin)) - f_lgammaPos(1.0 - xin)
    else
        res := f_lgammaPos(xin)
    res

// continued fraction for the incomplete beta (Lentz)
f_betacf(float a, float b, float x) =>
    float FPMIN = 1e-30
    float qab = a + b
    float qap = a + 1.0
    float qam = a - 1.0
    float c = 1.0
    float d = 1.0 - qab * x / qap
    if math.abs(d) < FPMIN
        d := FPMIN
    d := 1.0 / d
    float h = d
    bool done = false
    for m = 1 to 120
        if not done
            float em = m
            float m2 = 2.0 * em
            float aa = em * (b - em) * x / ((qam + m2) * (a + m2))
            d := 1.0 + aa * d
            if math.abs(d) < FPMIN
                d := FPMIN
            c := 1.0 + aa / c
            if math.abs(c) < FPMIN
                c := FPMIN
            d := 1.0 / d
            h *= d * c
            aa := -(a + em) * (qab + em) * x / ((a + m2) * (qap + m2))
            d := 1.0 + aa * d
            if math.abs(d) < FPMIN
                d := FPMIN
            c := 1.0 + aa / c
            if math.abs(c) < FPMIN
                c := FPMIN
            d := 1.0 / d
            float del = d * c
            h *= del
            if math.abs(del - 1.0) < 1e-8
                done := true
    h

// regularized incomplete beta I_x(a,b)
f_betai(float a, float b, float x) =>
    float r = 0.0
    if x <= 0.0
        r := 0.0
    else if x >= 1.0
        r := 1.0
    else
        float bt = math.exp(f_lgamma(a + b) - f_lgamma(a) - f_lgamma(b) + a * math.log(x) + b * math.log(1.0 - x))
        r := x < (a + 1.0) / (a + b + 2.0) ? bt * f_betacf(a, b, x) / a : 1.0 - bt * f_betacf(b, a, 1.0 - x) / b
    r

// Student-t CDF
f_tcdf(float t, float df) =>
    float x  = df / (df + t * t)
    float ib = 0.5 * f_betai(df / 2.0, 0.5, x)
    t > 0.0 ? 1.0 - ib : ib

// Normal CDF via Abramowitz-Stegun erf (7.1.26)
f_ncdf(float z) =>
    float zz = z / math.sqrt(2.0)
    float s  = zz < 0.0 ? -1.0 : 1.0
    float az = math.abs(zz)
    float tt = 1.0 / (1.0 + 0.3275911 * az)
    float y  = 1.0 - (((((1.061405429 * tt - 1.453152027) * tt) + 1.421413741) * tt - 0.284496736) * tt + 0.254829592) * tt * math.exp(-az * az)
    0.5 * (1.0 + s * y)

// buy fraction for a standardized move z
f_buyFrac(float z) =>
    clsMode == "Normal" ? f_ncdf(z) : f_tcdf(z, tDf)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SECTION 4 — LTF AGGREGATION (request.security_lower_tf)  + per-bar BVC totals
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// resolve the lower timeframe string
f_autoLtf() =>
    int sec    = timeframe.in_seconds(timeframe.period)
    int tgt    = math.max(1, int(math.round(sec / float(ltfDiv))))
    string res = "1"
    if tgt < 60
        int ss = tgt <= 1 ? 1 : tgt <= 5 ? 5 : tgt <= 10 ? 10 : tgt <= 15 ? 15 : 30
        res := str.tostring(ss) + "S"
    else if tgt < 86400
        res := str.tostring(math.max(1, int(tgt / 60)))
    else
        res := str.tostring(math.max(1, int(tgt / 86400))) + "D"
    res

string ltf = ltfMode == "Manual" ? ltfMan : f_autoLtf()

// confirmed intrabar arrays for the current chart bar
aClose = request.security_lower_tf(syminfo.tickerid, ltf, close)
aOpen  = request.security_lower_tf(syminfo.tickerid, ltf, open)
aVol   = request.security_lower_tf(syminfo.tickerid, ltf, volume)

// ── NATIVE FOOTPRINT SEAM (request.footprint — Premium/Ultimate; BVC fallback) ──
// One footprint request per script (the only one allowed). Returns na off-plan
// or on bars with no data, so every consumer falls back to BVC. We extract each
// bar's rows into primitive series-arrays (the same proven pattern as the LTF
// intrabars above) so the multi-bar profile can read history via [off] without
// relying on unproven historical object access.
bool wantNative = profSource != "BVC Reconstruction"
footprint fpObj = wantNative ? request.footprint(fpTicks, fpVA, fpImb) : na
bool natBar = not na(fpObj)
array<float> nPx   = array.new<float>()
array<float> nBuy  = array.new<float>()
array<float> nSell = array.new<float>()
if natBar
    array<volume_row> rws = fpObj.rows()
    if not na(rws)
        for vr in rws
            nPx.push((vr.up_price() + vr.down_price()) / 2.0)
            nBuy.push(nz(vr.buy_volume()))
            nSell.push(nz(vr.sell_volume()))

// fallback standardization scale (bar-to-bar), scaled toward intrabar magnitude
float sigBar = nz(ta.stdev(close - close[1], sigLen), syminfo.mintick)
float sigFb  = math.max(sigBar / math.sqrt(math.max(2.0, ltfDiv)), syminfo.mintick)

// per-bar buy/sell/delta from this bar's intrabars (cheap; used live for sweeps/CVD)
f_barFlow() =>
    float buy = 0.0
    float sell = 0.0
    int n = na(aClose) ? 0 : aClose.size()
    if n > 0
        // local sigma from intrabar returns
        float mean = 0.0
        int cnt = 0
        for k = 0 to n - 1
            float prev = k == 0 ? (aOpen.size() > 0 ? aOpen.get(0) : aClose.get(0)) : aClose.get(k - 1)
            mean += aClose.get(k) - prev
            cnt += 1
        mean := cnt > 0 ? mean / cnt : 0.0
        float varr = 0.0
        for k = 0 to n - 1
            float prev = k == 0 ? (aOpen.size() > 0 ? aOpen.get(0) : aClose.get(0)) : aClose.get(k - 1)
            float dpp = (aClose.get(k) - prev) - mean
            varr += dpp * dpp
        float sig = cnt > 1 ? math.sqrt(varr / (cnt - 1)) : sigFb
        sig := math.max(sig, sigFb * 0.25, syminfo.mintick)
        for k = 0 to n - 1
            float prev = k == 0 ? (aOpen.size() > 0 ? aOpen.get(0) : aClose.get(0)) : aClose.get(k - 1)
            float z = (aClose.get(k) - prev) / sig
            float bf = f_buyFrac(z)
            float v = nz(aVol.get(k))
            buy  += v * bf
            sell += v * (1.0 - bf)
    [buy, sell]

[barBuyR, barSellR] = f_barFlow()
float barBuy  = barBuyR
float barSell = barSellR
// native real bid/ask totals for the current bar take over when present
if natBar
    float nb = fpObj.buy_volume()
    float ns = fpObj.sell_volume()
    if not na(nb) and not na(ns) and (nb + ns) > 0
        barBuy  := nb
        barSell := ns
float barDelta = barBuy - barSell
float barVol   = barBuy + barSell

// TICK-RULE cross-classifier (Lee-Ready style). BVC can be inferior to a tick
// rule, and VPIN-style metrics can track volatility only via classification
// error — so we run the tick rule in parallel and report agreement. Low
// agreement = the trade-side read is fragile here; trust the profile shape,
// not the delta sign.
f_barFlowTick() =>
    float buy = 0.0
    float sell = 0.0
    int n = na(aClose) ? 0 : aClose.size()
    if n > 0
        for k = 0 to n - 1
            float prev = k == 0 ? (aOpen.size() > 0 ? aOpen.get(0) : aClose.get(0)) : aClose.get(k - 1)
            float d = aClose.get(k) - prev
            float v = nz(aVol.get(k))
            if d > 0
                buy += v
            else if d < 0
                sell += v
            else
                buy  += v * 0.5
                sell += v * 0.5
    [buy, sell]

[barBuyT, barSellT] = f_barFlowTick()
float barDeltaTick = barBuyT - barSellT

var int agN = 0
var int agW = 0
if barstate.isconfirmed and crossChk and barVol > 0
    agN += 1
    if (barDelta >= 0) == (barDeltaTick >= 0)
        agW += 1
float clfAgree = agN > 0 ? agW / float(agN) : na

var float cvd = 0.0
if barstate.isconfirmed
    cvd += barDelta

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SECTION 5 — CONTEXT (ATR, volume MA, displacement, absorption)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
float atr   = ta.atr(atrLen)
float volMA = ta.sma(volume, volLen)

float disp     = math.max(math.abs(close - open), syminfo.mintick)
float relVol   = volMA > 0 ? volume / volMA : 1.0
float relDisp  = atr > 0 ? disp / atr : 1.0
float absorb   = relVol / math.max(relDisp, 0.05)   // high = lots of volume, little travel
// √-law absorption (Almgren / Tóth-Bouchaud): realized impact vs √-law prediction.
// ratio < 1 = passive ABSORPTION (price held despite flow → reversal candidate);
// ratio > 1 = fragile/thin expansion. Runs parallel to the displacement measure
// so the ABS sweep gate + its calibration stay on their original definition.
float predImp  = (volMA > 0 and atr > 0) ? sqrtY * atr * math.sqrt(math.abs(barDelta) / volMA) : na
float realImp  = math.abs(close - open)
float sqrtAbsR = (not na(predImp) and predImp > 0) ? realImp / predImp : na

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SECTION 5b — MICROSTRUCTURE  (VPIN toxicity · stationarized OFI · impact)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// VPIN — Volume-synchronized Probability of Informed trading (Easley, López de
// Prado & O'Hara 2012). Volume is partitioned into EQUAL-VOLUME buckets; each
// bucket's order imbalance |buy−sell|/V is averaged over the last N buckets.
// This makes the "VPIN" in the title real: a 0–1 toxicity read on flow.
float volMAv  = ta.sma(volume, volLen)
float vBucket = math.max(nz(volMAv) * vpinBucketMlt, 1.0)
var float bkBuy  = 0.0
var float bkSell = 0.0
var float bkVol  = 0.0
var float[] vpinArr = array.new<float>(0)
if barstate.isconfirmed and barVol > 0 and vBucket > 0
    bkBuy  += barBuy
    bkSell += barSell
    bkVol  += barVol
    while bkVol >= vBucket
        float frac = vBucket / bkVol
        float bB   = bkBuy  * frac
        float bS   = bkSell * frac
        float imb  = (bB + bS) > 0 ? math.abs(bB - bS) / (bB + bS) : 0.0
        vpinArr.push(imb)
        while vpinArr.size() > vpinBuckets
            vpinArr.shift()
        bkBuy  -= bB
        bkSell -= bS
        bkVol  -= vBucket
float vpin = na
if vpinArr.size() > 0
    float s = 0.0
    for i = 0 to vpinArr.size() - 1
        s += vpinArr.get(i)
    vpin := s / vpinArr.size()
float vpinPct = na(vpin) ? na : ta.percentrank(vpin, 300)

// heat-glow: brighter background = more toxic / one-sided flow
color vpinGlowC = (vpinGlow and showVPIN and not na(vpinPct)) ? color.new(#E8A13C, math.max(60, 93 - int(nz(vpinPct) * 0.33))) : na
bgcolor(vpinGlowC, title = "VPIN heat-glow")

// Stationarized OFI — log-compressed, z-scored signed flow (regime-comparable)
float ofiRaw  = barDelta
float ofiC    = math.sign(ofiRaw) * math.log(1.0 + math.abs(ofiRaw))
float ofiMean = ta.sma(ofiC, ofiLen)
float ofiSd   = ta.stdev(ofiC, ofiLen)
float ofiZ    = ofiSd > 0 ? (ofiC - ofiMean) / ofiSd : 0.0

// Kyle's λ — price impact per unit signed flow (regression slope)
float dP    = close - close[1]
float kCorr = ta.correlation(dP, ofiRaw, kyleLen)
float kSdP  = ta.stdev(dP, kyleLen)
float kSdO  = ta.stdev(ofiRaw, kyleLen)
float kyle  = (not na(kCorr) and kSdO > 0) ? kCorr * kSdP / kSdO : na

// Amihud illiquidity — |return| per unit traded value
float retA   = close[1] != 0 ? math.abs(close / close[1] - 1.0) : na
float dvol   = volume * close
float illiq  = (not na(retA) and dvol > 0) ? retA / dvol : na
float amihud = ta.sma(nz(illiq), kyleLen) * 1e9

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SECTION 6 — PROFILE BUILD (last-bar pass over confirmed LTF history)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
float gridHi = ta.highest(high, profLen)
float gridLo = ta.lowest(low,  profLen)
float gridRng= math.max(gridHi - gridLo, syminfo.mintick)
float binSz  = gridRng / rows

var float[] buyBins  = array.new<float>(rows, 0.0)
var float[] sellBins = array.new<float>(rows, 0.0)

// accumulate one historical bar's intrabars into the bins (by reference)
f_accum(int off, float glo, float bs, float sigFallback) =>
    array<float> ac = aClose[off]
    array<float> ao = aOpen[off]
    array<float> av = aVol[off]
    int n = na(ac) ? 0 : ac.size()
    if n > 0
        float mean = 0.0
        int cnt = 0
        for k = 0 to n - 1
            float prev = k == 0 ? (na(ao) or ao.size() == 0 ? ac.get(0) : ao.get(0)) : ac.get(k - 1)
            mean += ac.get(k) - prev
            cnt += 1
        mean := cnt > 0 ? mean / cnt : 0.0
        float varr = 0.0
        for k = 0 to n - 1
            float prev = k == 0 ? (na(ao) or ao.size() == 0 ? ac.get(0) : ao.get(0)) : ac.get(k - 1)
            float dpp = (ac.get(k) - prev) - mean
            varr += dpp * dpp
        float sig = cnt > 1 ? math.sqrt(varr / (cnt - 1)) : sigFallback
        sig := math.max(sig, sigFallback * 0.25, syminfo.mintick)
        for k = 0 to n - 1
            float prev = k == 0 ? (na(ao) or ao.size() == 0 ? ac.get(0) : ao.get(0)) : ac.get(k - 1)
            float z  = (ac.get(k) - prev) / sig
            float bf = f_buyFrac(z)
            float v  = nz(av.get(k))
            int bin  = int(math.floor((ac.get(k) - glo) / bs))
            bin := math.max(0, math.min(rows - 1, bin))
            buyBins.set(bin,  buyBins.get(bin)  + v * bf)
            sellBins.set(bin, sellBins.get(bin) + v * (1.0 - bf))

// accumulate one historical bar's NATIVE footprint rows into the bins.
// returns the row count used (0 → caller falls back to BVC for that offset).
f_accumNative(int off, float glo, float bs) =>
    array<float> px = nPx[off]
    array<float> bb = nBuy[off]
    array<float> ss = nSell[off]
    int n = na(px) ? 0 : px.size()
    if n > 0
        for k = 0 to n - 1
            int bin = int(math.floor((px.get(k) - glo) / bs))
            bin := math.max(0, math.min(rows - 1, bin))
            buyBins.set(bin,  buyBins.get(bin)  + nz(bb.get(k)))
            sellBins.set(bin, sellBins.get(bin) + nz(ss.get(k)))
    n

// drawing pools
var box[]   pfBox  = array.new<box>()
var line[]  pfLine = array.new<line>()
var label[] pfLab  = array.new<label>()

f_clearDraw() =>
    for b in pfBox
        box.delete(b)
    for l in pfLine
        line.delete(l)
    for lb in pfLab
        label.delete(lb)
    pfBox.clear()
    pfLine.clear()
    pfLab.clear()

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SECTION 7 — CALIBRATION STATE  (per-class forward resolution)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// classes: 1 ABS · 2 EXH · 3 DIV · 4 REJ
int NCLS = 4

f_clsName(int id) => id == 1 ? "ABS" : id == 2 ? "EXH" : id == 3 ? "DIV" : id == 4 ? "REJ" : "—"
f_clsLong(int id) => id == 1 ? "Absorption" : id == 2 ? "Exhaustion" : id == 3 ? "Divergence" : id == 4 ? "Rejection" : "—"

type Pend
    int   cls
    int   dir
    float entry
    float atr0
    int   bidx
    float mfe
    float mae
    bool  done

type Base
    float entry
    float atr0
    int   bidx

var array<Pend> pend = array.new<Pend>()
var array<Base> bq   = array.new<Base>()

var int[]   clsN   = array.new<int>(NCLS + 1, 0)
var int[]   clsW   = array.new<int>(NCLS + 1, 0)
var float[] clsMFE = array.new<float>(NCLS + 1, 0.0)
var float[] clsMAE = array.new<float>(NCLS + 1, 0.0)
var bool[]  clsSig = array.new<bool>(NCLS + 1, false)

// reversal base rate: probability that price reverses moveATR·ATR within horizon
// (symmetric: sampled both sides, since sweeps occur on both extremes)
var int baseN = 0
var int baseW = 0

// one-sample z of a class hit-rate vs base prob
f_z(int w, int n, float p0) =>
    float r = na
    if n > 0 and not na(p0) and p0 > 0.0 and p0 < 1.0
        float ph = w / float(n)
        float se = math.sqrt(p0 * (1.0 - p0) / n)
        r := se > 0 ? (ph - p0) / se : na
    r

// Wilson score interval half-width (95%) on a hit-rate — honest stability of
// the estimate. "55 ±9%" tells you the estimate is shaky; "55 ±2%" it is firm.
f_wilsonHalf(int w, int n) =>
    float r = na
    if n > 0
        float zc = 1.96
        float p  = w / float(n)
        float den = 1.0 + zc * zc / n
        float marg = zc * math.sqrt(p * (1.0 - p) / n + zc * zc / (4.0 * n * n))
        r := (marg / den)
    r

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SECTION 8 — SWEEP DETECTION & EMISSION  (confirmed bars only — non-repaint)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
float priorHi = ta.highest(high, swLook)[1]
float priorLo = ta.lowest(low,  swLook)[1]

float upWick = high - math.max(open, close)
float dnWick = math.min(open, close) - low
float rng    = math.max(high - low, syminfo.mintick)

// a sweep requires taking out the prior extreme intrabar but the bar's body context matters
bool sweptHi = high > priorHi
bool sweptLo = low  < priorLo

int   sweepCls = 0
int   sweepDir = 0     // reversal direction: +1 expect up, -1 expect down
string sweepTxt = ""

if barstate.isconfirmed
    // --- upper-extreme sweeps → reversal DOWN (dir -1) ---
    if sweptHi and not sweptLo
        bool closedBack = close < priorHi
        bool deltaDiv   = barDelta < 0                 // pushed to new high but net selling
        bool dryVol     = volume < volMA * exhFrac
        bool absorbed   = absorb >= absFloor and closedBack
        bool rejected   = upWick / rng >= wickFrac and close < open
        if absorbed
            sweepCls := 1
        else if rejected
            sweepCls := 4
        else if deltaDiv and not dryVol
            sweepCls := 3
        else if dryVol
            sweepCls := 2
        if sweepCls != 0
            sweepDir := -1
    // --- lower-extreme sweeps → reversal UP (dir +1) ---
    else if sweptLo and not sweptHi
        bool closedBack = close > priorLo
        bool deltaDiv   = barDelta > 0
        bool dryVol     = volume < volMA * exhFrac
        bool absorbed   = absorb >= absFloor and closedBack
        bool rejected   = dnWick / rng >= wickFrac and close > open
        if absorbed
            sweepCls := 1
        else if rejected
            sweepCls := 4
        else if deltaDiv and not dryVol
            sweepCls := 3
        else if dryVol
            sweepCls := 2
        if sweepCls != 0
            sweepDir := 1

    if sweepCls != 0
        sweepTxt := f_clsName(sweepCls)
        pend.push(Pend.new(sweepCls, sweepDir, close, atr, bar_index, 0.0, 0.0, false))

// resolve pending sweeps
if barstate.isconfirmed and pend.size() > 0
    for i = pend.size() - 1 to 0
        Pend p = pend.get(i)
        if not p.done
            float favor   = p.dir > 0 ? (high - p.entry) : (p.entry - low)
            float adverse = p.dir > 0 ? (p.entry - low)  : (high - p.entry)
            p.mfe := math.max(p.mfe, favor   / p.atr0)
            p.mae := math.max(p.mae, adverse / p.atr0)
            if bar_index - p.bidx >= horizon
                p.done := true
                float fwd = p.dir > 0 ? (close - p.entry) : (p.entry - close)
                bool  win = fwd >= moveATR * p.atr0
                clsN.set(p.cls, clsN.get(p.cls) + 1)
                if win
                    clsW.set(p.cls, clsW.get(p.cls) + 1)
                clsMFE.set(p.cls, clsMFE.get(p.cls) + p.mfe)
                clsMAE.set(p.cls, clsMAE.get(p.cls) + p.mae)
                pend.remove(i)

// base-rate sampling (symmetric reversal opportunity)
if barstate.isconfirmed
    bq.push(Base.new(close, atr, bar_index))
    if bq.size() > 0
        for i = bq.size() - 1 to 0
            Base b = bq.get(i)
            if bar_index - b.bidx >= horizon
                float mvUp = high - b.entry
                float mvDn = b.entry - low
                // "a reversal-sized move occurred in either direction"
                bool any = math.max(mvUp, mvDn) >= moveATR * b.atr0
                baseN += 1
                if any
                    baseW += 1
                bq.remove(i)

float baseP = baseN > 0 ? baseW / float(baseN) : na

// newly-significant class (for alert)
int sigCls = 0
if barstate.isconfirmed
    for id = 1 to NCLS
        if clsN.get(id) >= 5 and not clsSig.get(id)
            float z = f_z(clsW.get(id), clsN.get(id), baseP)
            float hit = clsW.get(id) / float(clsN.get(id))
            if not na(z) and z > 1.96 and not na(baseP) and hit > baseP
                clsSig.set(id, true)
                sigCls := id

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SECTION 8b — HAWKES SWEEP-INTENSITY + KISH-DECORRELATED LOG-ODDS FUSION
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Hawkes: a self-exciting intensity that JUMPS on each sweep and decays between
// them — high intensity = sweeps are clustering (cascade / liquidity instability).
var float hawkInt = 0.0
if barstate.isconfirmed
    hawkInt := hawkInt * math.exp(-hawkBeta) + (sweepCls != 0 ? hawkAlpha : 0.0)
float hawkPct     = ta.percentrank(hawkInt, 300)
bool  hawkCascade = not na(hawkPct) and hawkPct >= 80

// Log-odds fusion: combine the firing class's realized edge with the concurrent
// absorption and toxicity tells into ONE calibrated reversal probability. Tells
// are decorrelated by a Kish design-effect shrink so correlated evidence can't
// stack. Sign convention: absorption supports the reversal; high VPIN (informed,
// one-sided flow) argues for continuation, i.e. AGAINST the fade.
f_logit(float p) =>
    float pc = math.max(0.001, math.min(0.999, p))
    math.log(pc / (1.0 - pc))

float rA12   = ta.correlation(ofiZ, nz(absorb), ofiLen)
float rA13   = ta.correlation(ofiZ, nz(vpin),   ofiLen)
float rA23   = ta.correlation(nz(absorb), nz(vpin), ofiLen)
float rhoBar = (math.abs(nz(rA12)) + math.abs(nz(rA13)) + math.abs(nz(rA23))) / 3.0
float kish   = (3.0 / (1.0 + 2.0 * rhoBar)) / 3.0    // effective-N / N ∈ (0,1]

float fusedP = na
if sweepCls != 0 and not na(baseP)
    float lo = f_logit(baseP)
    int   cn = clsN.get(sweepCls)
    if cn >= 5
        float chit = clsW.get(sweepCls) / float(cn)
        lo += kish * (f_logit(chit) - f_logit(baseP))
    float absLLR = math.max(-1.0, math.min(1.5, (nz(absorb) - absFloor) * 0.4))
    float toxLLR = na(vpin) ? 0.0 : -math.max(-1.0, math.min(1.0, (vpin - 0.5) * 2.0)) * 0.5
    float sqrtLLR = na(sqrtAbsR) ? 0.0 : math.max(-1.0, math.min(1.0, 1.0 - sqrtAbsR)) * 0.5
    lo += kish * (absLLR + toxLLR + sqrtLLR)
    fusedP := 1.0 / (1.0 + math.exp(-lo))

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SECTION 8c — RECLAIM-CONFIRMED LIQUIDITY SWEEP  (structural stop-run + reclaim)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// The high-conviction reversal subset, by the classic definition: price runs a
// recent confirmed swing pivot (resting stops / breakout liquidity), then
// RECLAIMS — closes back inside, recovering ≥ liqReclaim of the run — on a volume
// spike. Independent of the ABS/EXH/DIV/REJ taxonomy. Non-repaint: pivots confirm
// liqPivRight bars back, and the sweep commits only on a closed bar.
float pvHi  = ta.pivothigh(high, liqPivLeft, liqPivRight)
float pvLo  = ta.pivotlow(low,   liqPivLeft, liqPivRight)
float vol20 = ta.sma(volume, 20)

float liqRefHi = na
float liqRefLo = na
for k = 1 to liqLookback
    if na(liqRefHi)
        float ph = pvHi[k]
        if not na(ph)
            liqRefHi := ph
    if na(liqRefLo)
        float pl = pvLo[k]
        if not na(pl)
            liqRefLo := pl

bool  liqBull = false
bool  liqBear = false
float liqLvl  = na
if liqEnable and barstate.isconfirmed and not na(vol20) and volume > vol20 * liqVolMul
    // bull: ran the prior low, reclaimed back above → reversal UP
    if not na(liqRefLo)
        float runBelow  = liqRefLo - low
        bool  reclaimed = close > liqRefLo and (close - low) >= runBelow * (1.0 + liqReclaim)
        if low < liqRefLo and reclaimed
            liqBull := true
            liqLvl  := liqRefLo
    // bear: ran the prior high, reclaimed back below → reversal DOWN
    if not liqBull and not na(liqRefHi)
        float runAbove  = high - liqRefHi
        bool  reclaimed = close < liqRefHi and (high - close) >= runAbove * (1.0 + liqReclaim)
        if high > liqRefHi and reclaimed
            liqBear := true
            liqLvl  := liqRefHi
int liqDir = liqBull ? 1 : liqBear ? -1 : 0

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SECTION 9 — DRAW  (sweep tags live; profile/quadrants/voids on last bar)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// sweep tags (one label per event, pooled & capped)
if showSwp and barstate.isconfirmed and sweepCls != 0
    color sc = sweepDir > 0 ? cBull : cBear
    string arrow = sweepDir > 0 ? "▲" : "▼"
    label lb = label.new(bar_index, sweepDir > 0 ? low : high,
         sweepTxt + " " + arrow,
         style    = sweepDir > 0 ? label.style_label_up : label.style_label_down,
         color    = color.new(sc, 15),
         textcolor= isLight ? color.white : #0A0A0A,
         size     = size.small)
    pfLab.push(lb)
    while pfLab.size() > 60
        label.delete(pfLab.shift())

// ⚡ reclaim-confirmed liquidity sweep marker — own pool, profile visuals untouched
f_liqSize(string s) => s == "Tiny" ? size.tiny : s == "Small" ? size.small : s == "Normal" ? size.normal : size.large
var label[] liqLab = array.new<label>()
if liqEnable and barstate.isconfirmed and liqDir != 0
    label lz = label.new(bar_index,
         liqDir > 0 ? low - (high - low) * 0.10 : high + (high - low) * 0.10,
         "⚡",
         xloc      = xloc.bar_index,
         yloc      = yloc.price,
         style     = liqDir > 0 ? label.style_label_up : label.style_label_down,
         color     = color.new(liqDir > 0 ? cBull : cBear, 20),
         textcolor = color.white,
         size      = f_liqSize(liqMarkSize))
    liqLab.push(lz)
    while liqLab.size() > 80
        label.delete(liqLab.shift())

// profile + quadrants + voids — rebuilt on the last bar
float pocPrice = na
float vaH = na
float vaL = na
var float ofiMLv     = na
var float auctionEffv = na
float qd0 = 0.0
float qd1 = 0.0
float qd2 = 0.0
float qd3 = 0.0

if barstate.islast
    // clear only the profile structures (keep sweep labels)
    for b in pfBox
        box.delete(b)
    for l in pfLine
        line.delete(l)
    pfBox.clear()
    pfLine.clear()

    buyBins  := array.new<float>(rows, 0.0)
    sellBins := array.new<float>(rows, 0.0)
    int span = math.min(profLen, bar_index)
    for off = 0 to span - 1
        bool didNative = false
        if wantNative
            int nn = f_accumNative(off, gridLo, binSz)
            didNative := nn > 0
        if not didNative
            f_accum(off, gridLo, binSz, sigFb)

    // peak & totals
    float peak = 0.0
    float totV = 0.0
    int   pocBin = 0
    for i = 0 to rows - 1
        float v = buyBins.get(i) + sellBins.get(i)
        totV += v
        if v > peak
            peak := v
            pocBin := i
    pocPrice := gridLo + binSz * (pocBin + 0.5)

    // value area (70%) expanding from POC — computed always (draw still gated by showVA)
    if totV > 0
        float acc = buyBins.get(pocBin) + sellBins.get(pocBin)
        int lo = pocBin
        int hi = pocBin
        float target = totV * 0.70
        while acc < target and (lo > 0 or hi < rows - 1)
            float vBelow = lo > 0 ? buyBins.get(lo - 1) + sellBins.get(lo - 1) : -1.0
            float vAbove = hi < rows - 1 ? buyBins.get(hi + 1) + sellBins.get(hi + 1) : -1.0
            if vAbove >= vBelow
                hi += 1
                acc += vAbove
            else
                lo -= 1
                acc += vBelow
        vaL := gridLo + binSz * lo
        vaH := gridLo + binSz * (hi + 1)

    // multi-level OFI — depth-weighted signed imbalance across the profile bins,
    // near-price levels weighted highest (Cont-Kukanov-Stoikov / Xu-Gould-Howison).
    float ofiNum = 0.0
    float ofiDen = 0.0
    for i = 0 to rows - 1
        float binCtr = gridLo + binSz * (i + 0.5)
        float dist   = math.abs(binCtr - close) / binSz
        float w      = math.exp(-dist / ofiDecay)
        ofiNum += w * (buyBins.get(i) - sellBins.get(i))
        ofiDen += w * (buyBins.get(i) + sellBins.get(i))
    ofiMLv := ofiDen > 0 ? math.max(-1.0, math.min(1.0, ofiNum / ofiDen)) : 0.0

    // auction efficiency — value concentration: how tight the 70% value area is
    // relative to the whole profile range. High = volume accepted in a narrow band
    // (efficient/balanced auction); low = spread out (distribution / searching).
    auctionEffv := (not na(vaH) and not na(vaL) and gridRng > 0) ? math.max(0.0, math.min(1.0, 1.0 - (vaH - vaL) / gridRng)) : na

    int x0 = bar_index + 2
    // draw rows
    if showProf
        for i = 0 to rows - 1
            float bv = buyBins.get(i)
            float sv = sellBins.get(i)
            float tv = bv + sv
            float top = gridLo + binSz * (i + 1)
            float bot = gridLo + binSz * i
            int wTot = peak > 0 ? int((tv / peak) * profW) : 0
            int wBuy = tv > 0 ? int(wTot * (bv / tv)) : 0
            if wTot > 0
                if profStyle == "Heatmap"
                    // delta-lean color, brightness scaled by volume at this price
                    float dl   = tv > 0 ? (bv - sv) / tv : 0.0          // -1..+1
                    color binC = dl >= 0 ? cBull : cBear
                    int   tr   = 88 - int(math.min(72.0, (tv / peak) * 72.0))
                    box bx = box.new(x0, top, x0 + wTot, bot, border_color = na, bgcolor = color.new(binC, tr))
                    pfBox.push(bx)
                else
                    // split footprint: sell block (outer), buy block (inner)
                    box bxS = box.new(x0, top, x0 + wTot, bot, border_color = na, bgcolor = color.new(cBear, 60))
                    pfBox.push(bxS)
                    if wBuy > 0
                        box bxB = box.new(x0, top, x0 + wBuy, bot, border_color = na, bgcolor = color.new(cBull, 45))
                        pfBox.push(bxB)
            // void / LVN marker
            if showVoid and i > 0 and i < rows - 1
                float vPrev = buyBins.get(i - 1) + sellBins.get(i - 1)
                float vNext = buyBins.get(i + 1) + sellBins.get(i + 1)
                if tv < peak * voidFrac and tv <= vPrev and tv <= vNext
                    line vl = line.new(bar_index - span + 1, (top + bot) / 2, x0 + profW, (top + bot) / 2, color = color.new(cNeu, 35), style = line.style_dotted, width = 1)
                    pfLine.push(vl)

    // POC line
    if not na(pocPrice)
        line pl = line.new(bar_index - span + 1, pocPrice, x0 + profW, pocPrice, color = color.new(cNeu, 0), style = line.style_solid, width = 2)
        pfLine.push(pl)
        label plb = label.new(x0 + profW, pocPrice, "POC", style = label.style_label_left, color = color.new(cNeu, 80), textcolor = cTxt, size = size.tiny)
        pfLab.push(plb)

    // value-area edges
    if showVA and not na(vaH)
        line lh = line.new(bar_index - span + 1, vaH, x0 + profW, vaH, color = color.new(cNeu, 50), style = line.style_dashed, width = 1)
        line ll = line.new(bar_index - span + 1, vaL, x0 + profW, vaL, color = color.new(cNeu, 50), style = line.style_dashed, width = 1)
        pfLine.push(lh)
        pfLine.push(ll)

    // quadrant localized delta (4 vertical bands across the profile range)
    int per = int(math.ceil(rows / 4.0))
    for q = 0 to 3
        float qb = 0.0
        float qs = 0.0
        int qa = q * per
        int qe = math.min(rows - 1, (q + 1) * per - 1)
        if qa <= qe
            for i = qa to qe
                qb += buyBins.get(i)
                qs += sellBins.get(i)
        float qDelta = qb - qs
        if q == 0
            qd0 := qDelta
        else if q == 1
            qd1 := qDelta
        else if q == 2
            qd2 := qDelta
        else
            qd3 := qDelta
        if showQuad and (qb + qs) > 0
            float qtop = gridLo + binSz * (qe + 1)
            float qbot = gridLo + binSz * qa
            color qc = qDelta >= 0 ? cBull : cBear
            float conv = (qb + qs) > 0 ? math.abs(qDelta) / (qb + qs) : 0.0
            box qbx = box.new(x0 + profW + 4, qtop, x0 + profW + 4 + int(12 + conv * 24), qbot,
                 border_color = color.new(qc, 40), bgcolor = color.new(qc, 80))
            pfBox.push(qbx)
            label qlb = label.new(x0 + profW + 4 + int(12 + conv * 24), (qtop + qbot) / 2,
                 (qDelta >= 0 ? "+" : "") + fmtNum(qDelta),
                 style = label.style_label_left, color = color.new(qc, 70), textcolor = cTxt, size = size.tiny)
            pfLab.push(qlb)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SECTION 10 — DASHBOARD
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var table dash = table.new(f_dashPos(dashPos), 7, NCLS + 9, frame_color = cGrid, frame_width = 1, border_color = cGrid, border_width = 1)

f_cell(int c, int r, string txt, color tc, color bg, string sz) =>
    table.cell(dash, c, r, txt, text_color = tc, bgcolor = bg, text_size = sz, text_halign = text.align_center)

if showDash and barstate.islast
    string sz = "small"
    table.clear(dash, 0, 0, 6, NCLS + 8)

    // header
    f_cell(0, 0, "ORDER-FLOW PROFILE", cTxt, cHead, "normal")
    table.merge_cells(dash, 0, 0, 6, 0)

    // live row
    color dc = barDelta >= 0 ? cBull : cBear
    f_cell(0, 1, "LTF " + ltf, cNeu, cPanel, sz)
    f_cell(1, 1, "Δ " + fmtNum(barDelta), dc, cPanel, sz)
    table.merge_cells(dash, 1, 1, 2, 1)
    f_cell(3, 1, "CVD " + fmtNum(cvd), cvd >= 0 ? cBull : cBear, cPanel, sz)
    table.merge_cells(dash, 3, 1, 4, 1)
    f_cell(5, 1, crossChk and not na(clfAgree) ? "BVC↔Tick " + str.tostring(clfAgree * 100, "0") + "%" : "Absorb " + str.tostring(absorb, "0.0"), crossChk and not na(clfAgree) ? (clfAgree >= 0.6 ? cBull : cBear) : (absorb >= absFloor ? cBull : cNeu), cPanel, sz)
    table.merge_cells(dash, 5, 1, 6, 1)

    if dashMode == "Pro"
        // calibration header
        f_cell(0, 2, "CLASS", cNeu, cHead, sz)
        f_cell(1, 2, "n",     cNeu, cHead, sz)
        f_cell(2, 2, "Hit%",  cNeu, cHead, sz)
        f_cell(3, 2, "Base%", cNeu, cHead, sz)
        f_cell(4, 2, "Edge",  cNeu, cHead, sz)
        f_cell(5, 2, "MFE",   cNeu, cHead, sz)
        f_cell(6, 2, "MAE",   cNeu, cHead, sz)
        for id = 1 to NCLS
            int n = clsN.get(id)
            int r = 2 + id
            if n < 5
                f_cell(0, r, f_clsName(id), cTxt, cPanel, sz)
                f_cell(1, r, str.tostring(n), cNeu, cPanel, sz)
                f_cell(2, r, "·", cDim, cPanel, sz)
                f_cell(3, r, "·", cDim, cPanel, sz)
                f_cell(4, r, "warm", cDim, cPanel, sz)
                f_cell(5, r, "·", cDim, cPanel, sz)
                f_cell(6, r, "·", cDim, cPanel, sz)
            else
                float hit  = clsW.get(id) / float(n)
                float edge = na(baseP) ? na : hit - baseP
                float z    = f_z(clsW.get(id), n, baseP)
                float ciH  = f_wilsonHalf(clsW.get(id), n)
                bool  star = not na(z) and z > 1.96
                color ec   = na(edge) ? cNeu : edge > 0 ? cBull : cBear
                f_cell(0, r, f_clsName(id), cTxt, cPanel, sz)
                f_cell(1, r, str.tostring(n), cTxt, cPanel, sz)
                f_cell(2, r, str.tostring(hit * 100, "0") + (na(ciH) ? "" : "±" + str.tostring(ciH * 100, "0")), cTxt, cPanel, sz)
                f_cell(3, r, na(baseP) ? "·" : str.tostring(baseP * 100, "0") + "%", cNeu, cPanel, sz)
                f_cell(4, r, (na(edge) ? "·" : (edge >= 0 ? "+" : "") + str.tostring(edge * 100, "0") + "%") + (star ? "*" : ""), ec, cPanel, sz)
                f_cell(5, r, str.tostring(clsMFE.get(id) / n, "0.0") + "R", cBull, cPanel, sz)
                f_cell(6, r, str.tostring(clsMAE.get(id) / n, "0.0") + "R", cBear, cPanel, sz)
        // footer
        f_cell(0, NCLS + 3, "POC " + (na(pocPrice) ? "—" : str.tostring(pocPrice, format.mintick)), cNeu, cHead, sz)
        table.merge_cells(dash, 0, NCLS + 3, 3, NCLS + 3)
        f_cell(4, NCLS + 3, "base n=" + str.tostring(baseN), cDim, cHead, sz)
        table.merge_cells(dash, 4, NCLS + 3, 6, NCLS + 3)
        // microstructure reads
        // microstructure row 1 — VPIN toxicity + stationarized OFI / Kyle λ
        if showVPIN or showOFI
            string mTxt = (showVPIN and not na(vpin)) ? "VPIN " + str.tostring(vpin, "0.00") + (na(vpinPct) ? "" : " (" + str.tostring(vpinPct, "0") + "%)") : "VPIN —"
            color  mCol = (showVPIN and not na(vpinPct)) ? (vpinPct >= 70 ? cBear : vpinPct >= 40 ? cAcc : cBull) : cDim
            f_cell(0, NCLS + 4, mTxt, mCol, cHead, sz)
            table.merge_cells(dash, 0, NCLS + 4, 2, NCLS + 4)
            string oTxt = showOFI ? "OFI z " + str.tostring(nz(ofiZ), "0.0") + " · λ " + (na(kyle) ? "—" : str.tostring(kyle, "0.000")) : ""
            f_cell(3, NCLS + 4, oTxt, ofiZ >= 0 ? cBull : cBear, cHead, sz)
            table.merge_cells(dash, 3, NCLS + 4, 6, NCLS + 4)
        // microstructure row 2 — Hawkes cascade + fused reversal probability
        if showFuse
            string hTxt = "Hawkes " + str.tostring(nz(hawkInt), "0.0") + (hawkCascade ? " ⚠cascade" : "")
            f_cell(0, NCLS + 5, hTxt, hawkCascade ? cBear : cNeu, cHead, sz)
            table.merge_cells(dash, 0, NCLS + 5, 2, NCLS + 5)
            string fTxt = na(fusedP) ? "Fused P —" : "Fused P(rev) " + str.tostring(fusedP * 100, "0") + "%"
            color  fCol = na(fusedP) ? cDim : fusedP >= 0.55 ? cBull : fusedP <= 0.45 ? cBear : cNeu
            f_cell(3, NCLS + 5, fTxt, fCol, cHead, sz)
            table.merge_cells(dash, 3, NCLS + 5, 6, NCLS + 5)
        // microstructure row 3 — depth-weighted multi-level OFI + auction efficiency
        string olTxt = na(ofiMLv) ? "OFI(mlt) —" : "OFI(mlt) " + str.tostring(ofiMLv, "+0.00;-0.00")
        color  olCol = na(ofiMLv) ? cDim : ofiMLv > 0.15 ? cBull : ofiMLv < -0.15 ? cBear : cNeu
        f_cell(0, NCLS + 6, olTxt, olCol, cHead, sz)
        table.merge_cells(dash, 0, NCLS + 6, 2, NCLS + 6)
        string auTxt = na(auctionEffv) ? "Auction —" : "Auction " + str.tostring(auctionEffv * 100, "0") + "% " + (auctionEffv >= 0.55 ? "efficient" : auctionEffv <= 0.35 ? "spread" : "mixed")
        color  auCol = na(auctionEffv) ? cDim : auctionEffv >= 0.55 ? cBull : auctionEffv <= 0.35 ? cBear : cNeu
        f_cell(3, NCLS + 6, auTxt, auCol, cHead, sz)
        table.merge_cells(dash, 3, NCLS + 6, 6, NCLS + 6)
        // microstructure row 4 — √-law absorption + profile data source
        string saTxt = na(sqrtAbsR) ? "√-abs —" : "√-abs " + str.tostring(sqrtAbsR, "0.00") + "× " + (sqrtAbsR <= 0.6 ? "ABSORBED" : sqrtAbsR >= 1.6 ? "fragile" : "normal")
        color  saCol = na(sqrtAbsR) ? cDim : sqrtAbsR <= 0.6 ? cBull : sqrtAbsR >= 1.6 ? cBear : cNeu
        f_cell(0, NCLS + 7, saTxt, saCol, cHead, sz)
        table.merge_cells(dash, 0, NCLS + 7, 2, NCLS + 7)
        string dsTxt = wantNative ? (natBar ? "Source ◆ NATIVE" : "Source · BVC (no native)") : "Source · BVC"
        color  dsCol = (wantNative and natBar) ? cBull : cDim
        f_cell(3, NCLS + 7, dsTxt, dsCol, cHead, sz)
        table.merge_cells(dash, 3, NCLS + 7, 6, NCLS + 7)
    else
        // ── COMPACT: key decision reads only ──
        // best calibrated sweep class (highest edge with enough samples)
        int bestId = 0
        float bestEdge = -1e9
        for id = 1 to NCLS
            if clsN.get(id) >= 5 and not na(baseP)
                float e = clsW.get(id) / float(clsN.get(id)) - baseP
                if e > bestEdge
                    bestEdge := e
                    bestId := id
        // row 2 — POC + VPIN toxicity
        f_cell(0, 2, "POC " + (na(pocPrice) ? "—" : str.tostring(pocPrice, format.mintick)), cNeu, cPanel, sz)
        table.merge_cells(dash, 0, 2, 2, 2)
        string vTxt = (showVPIN and not na(vpin)) ? "VPIN " + str.tostring(vpin, "0.00") + (na(vpinPct) ? "" : " (" + str.tostring(vpinPct, "0") + "%)") : "VPIN —"
        color  vCol = (showVPIN and not na(vpinPct)) ? (vpinPct >= 70 ? cBear : vpinPct >= 40 ? cAcc : cBull) : cDim
        f_cell(3, 2, vTxt, vCol, cPanel, sz)
        table.merge_cells(dash, 3, 2, 6, 2)
        // row 3 — best calibrated sweep edge
        if bestId == 0
            f_cell(0, 3, "calibrating…", cDim, cPanel, sz)
            table.merge_cells(dash, 0, 3, 6, 3)
        else
            f_cell(0, 3, "Best edge · " + f_clsLong(bestId), cTxt, cPanel, sz)
            table.merge_cells(dash, 0, 3, 3, 3)
            f_cell(4, 3, (bestEdge >= 0 ? "+" : "") + str.tostring(bestEdge * 100, "0") + "%", bestEdge > 0 ? cBull : cBear, cPanel, sz)
            table.merge_cells(dash, 4, 3, 6, 3)
        // row 4 — fused reversal probability + depth-weighted OFI
        string fcTxt = (showFuse and not na(fusedP)) ? "Fused P(rev) " + str.tostring(fusedP * 100, "0") + "%" : "Fused P —"
        color  fcCol = (showFuse and not na(fusedP)) ? (fusedP >= 0.55 ? cBull : fusedP <= 0.45 ? cBear : cNeu) : cDim
        f_cell(0, 4, fcTxt, fcCol, cPanel, sz)
        table.merge_cells(dash, 0, 4, 2, 4)
        string omTxt = na(ofiMLv) ? "OFI(mlt) —" : "OFI(mlt) " + str.tostring(ofiMLv, "+0.00;-0.00")
        color  omCol = na(ofiMLv) ? cDim : ofiMLv > 0.15 ? cBull : ofiMLv < -0.15 ? cBear : cNeu
        f_cell(3, 4, omTxt, omCol, cPanel, sz)
        table.merge_cells(dash, 3, 4, 6, 4)
        // row 5 — liquidity sweep + auction efficiency
        string lqTxt = liqDir > 0 ? "⚡ Liq sweep ▲" : liqDir < 0 ? "⚡ Liq sweep ▼" : "Liq sweep —"
        color  lqCol = liqDir > 0 ? cBull : liqDir < 0 ? cBear : cDim
        f_cell(0, 5, lqTxt, lqCol, cPanel, sz)
        table.merge_cells(dash, 0, 5, 2, 5)
        string acTxt = na(auctionEffv) ? "Auction —" : "Auction " + str.tostring(auctionEffv * 100, "0") + "% " + (auctionEffv >= 0.55 ? "efficient" : auctionEffv <= 0.35 ? "spread" : "mixed")
        color  acCol = na(auctionEffv) ? cDim : auctionEffv >= 0.55 ? cBull : auctionEffv <= 0.35 ? cBear : cNeu
        f_cell(3, 5, acTxt, acCol, cPanel, sz)
        table.merge_cells(dash, 3, 5, 6, 5)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SECTION 11 — ALERTS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
alertcondition(sweepCls != 0, "New Sweep", "OF Profile: {{ticker}} order-flow sweep detected ({{interval}})")
alertcondition(sigCls != 0,   "New Significant-Edge Class", "OF Profile: a sweep class reached significant positive edge on {{ticker}}")
alertcondition(hawkCascade,   "Sweep Cascade (Hawkes)", "OF Profile: {{ticker}} sweep intensity in cascade regime ({{interval}})")
alertcondition(liqDir != 0,   "Liquidity Sweep (reclaim)", "OF Profile: {{ticker}} reclaim-confirmed liquidity sweep ({{interval}})")

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SECTION 12 — EXPORTS (Data Window)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
float expClsEdge = na
if not na(baseP) and sweepCls != 0 and clsN.get(sweepCls) >= 5
    expClsEdge := (clsW.get(sweepCls) / float(clsN.get(sweepCls)) - baseP) * 100.0

plot(showEXP ? barDelta : na,            "EXP_Delta",   color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? cvd : na,                 "EXP_CVD",     color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? absorb : na,              "EXP_Absorb",  color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? pocPrice : na,            "EXP_POC",     color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP and showVPIN ? vpin : na,   "EXP_VPIN",    color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP and showOFI  ? ofiZ : na,   "EXP_OFIz",    color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP and showOFI  ? kyle : na,   "EXP_KyleLambda", color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP and showOFI  ? amihud : na, "EXP_Amihud",  color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP and showFuse ? hawkInt : na,"EXP_Hawkes",  color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP and showFuse ? fusedP * 100 : na, "EXP_FusedP", color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? ofiMLv : na,              "EXP_OFIml",   color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? auctionEffv : na,         "EXP_AuctionEff", color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? sqrtAbsR : na,            "EXP_SqrtAbs", color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? float(liqDir) : na,       "EXP_LiqSweep",color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? float(sweepCls) : na,     "EXP_SweepCls",color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? expClsEdge : na,          "EXP_ClsEdge", color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP and crossChk ? clfAgree * 100 : na, "EXP_ClfAgree", color = color.new(color.gray, 100), display = display.data_window)
````
