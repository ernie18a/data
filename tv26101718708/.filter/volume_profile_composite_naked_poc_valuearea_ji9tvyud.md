# Volume Profile  Composite, Naked POC & Value-Area

- url: https://www.tradingview.com/script/JI9tVYUd-Volume-Profile-Composite-Naked-POC-Value-Area/
- type: indicator
- pine_id: PUB;e5c15b6b3b714f0688af037361b45dac
- version: 4.0

## Description

Volume Profile — Composite, Naked POC & Value-Area
==================================================

WHAT IT IS

A volume-at-price profile built for depth and decisions. It measures where trade
actually concentrated across the loaded history, distils that distribution into
the levels traders use — Point of Control (POC), Value Area (VAH/VAL), High and
Low Volume Nodes (HVN/LVN), and untested "naked" prior-session POCs — and then
converts those levels into a plain-language read of where price sits in the
auction (premium, discount, or inside value; balancing or migrating).

It is a study for chart analysis and education. It plots levels and context; it
does not place orders and does not output buy/sell signals.


HOW IT WORKS (ENGINE)

Volume is accumulated bar by bar into a price-keyed map on a fine grid (the
symbol's minimum tick multiplied by a user factor), then re-aggregated to the
chosen number of display rows. Because the engine uses a map rather than a fixed
lookback array, the profile can span every loaded bar instead of only a recent
window, and it is not limited by the historical bar-reference ceiling.

Each bar's volume is distributed across that bar's high-low range over a capped
number of samples, and tagged buy or sell by bar direction, producing a two-tone
histogram and a per-level delta. Where intrabar (lower-timeframe) data is
available, recent history can optionally be refined from it; older bars fall back
to the bar-range method. The Value Area is grown outward from the POC bin until
the chosen percentage of total volume is captured. Prior-day, prior-week and
full-history composite levels reuse the same value-area routine on their own maps.
The heavy redraw runs on bar open/close rather than on every realtime tick, to
keep live charts responsive.


WHY THESE COMPONENTS ARE COMBINED (MASHUP JUSTIFICATION)

This is one volume-profile engine, not a stack of independent indicators. Every
layer is computed FROM THE SAME accumulated volume map, and each one exists to
remove a specific blind spot of the raw histogram. A bare histogram only answers
"where did volume happen"; it cannot tell you whether price is rich or cheap,
which level matters next, or whether the market is balancing or trending. The
combined layers answer those questions, and they work together as follows:

- POC and Value Area transform the raw distribution into a fair-value frame, so
  every other reading can be expressed as premium, discount, or inside value.

- HVN and LVN classify each price level produced by that same distribution as
  acceptance (a volume shelf where reactions are more likely) or a thin gap
  (where price tends to move quickly). This tells you how a level is likely to
  behave, which the POC/Value Area alone do not.

- Naked prior-session POCs carry acceptance forward in time: they are POCs from
  earlier sessions that price has not yet traded back through, derived from the
  same per-session maps, and they act as revisit references.

- Value migration is simply the sequence of those session POCs read as a
  direction, turning the profile history into a balancing-versus-trending read.

- The composite overlay keeps the full-history POC and Value Area in view while
  you work a shorter, more legible recent window, so context is never lost.

- VWAP, Initial Balance, an expected-move band, and cumulative-volume-delta
  divergence are confluence layers. They are optional and each degrades
  gracefully if its data is absent. They are included because volume-profile
  levels are used in context: VWAP gives the session's volume-weighted mean,
  Initial Balance gives the opening reference, the expected-move band frames a
  realistic day's range, and CVD-versus-price flags exhaustion. Each one answers
  "does independent volume/price information agree with what the profile shows
  here?", which is exactly how these levels are traded in practice.

- The Auto-Read is the synthesis step: it does not add new data, it ranks the
  levels the engine already produced by distance to price and states the auction
  context in words.

In short, the histogram is the raw material and every other element is a
transformation of that same data into a level, a classification, a confluence
check, or a written read. That shared derivation is the reason they belong in a
single script rather than as separate indicators.


WHAT IT PLOTS

- Buy/sell two-tone histogram, drawn in the clear space to the right of price so
  candles stay visible.
- POC, Value Area (VAH/VAL, adjustable percentage), HVN/LVN nodes.
- Naked daily POCs, with a creation-time check that skips levels already traded
  through and an optional age-out so the list stays meaningful.
- Polarity flip: a prior-day Value Area edge that price closes decisively beyond
  and holds changes role (broken VAH becomes support; broken VAL becomes
  resistance) and feeds the support/resistance read.
- Prior-day and prior-week POC/Value Area, full-history composite overlay,
  developing POC.
- VWAP with standard-deviation bands, Initial Balance, expected-move band,
  cumulative-volume-delta divergence, buy/sell imbalance shelves, poor highs/lows,
  single-print gaps.
- Higher-timeframe POC bias (a light proxy — see Limitations).
- Auto-Read dashboard (full or compact), one-line headline, and an on-chart
  identity strip showing the script name, symbol and timeframe.


HOW TO USE

1. Choose a scope: Rolling (default), Composite (all history), From date, or
   Fixed range. The composite overlay keeps the big-picture levels visible.
2. Read location first from the headline or dashboard: inside value, premium, or
   discount, and whether value is migrating up, down, or flat.
3. Treat the levels as a map, not a signal. POC acts as a mean-revert magnet;
   Value Area edges are balance boundaries; HVN suggests stalls; LVN suggests
   fast moves; a naked POC is a revisit reference.
4. Look for confluence with VWAP, Initial Balance, and prior-session levels, and
   treat CVD divergence as a caution flag.
5. Detail presets (Simple / Standard / Pro) gate how much is shown. A compact
   dashboard toggle trims the table to the key decision fields.


WHAT MAKES IT ORIGINAL

- Full-history depth via the price-keyed map, beyond a fixed lookback window.
- A built-in, past-only calibration of the profile's own claims: it logs
  value-edge and POC-stretch reversion events against the prior-day Value Area
  (which exists on every bar, so the measurement backfills over history), waits a
  fixed horizon, and reports the realised hit-rate with a 95% confidence
  interval. This is descriptive of past behaviour on the specific instrument; it
  is explicitly not a backtest and not a forecast.
- A decision-ordered, plain-language Auto-Read derived entirely from the engine's
  own levels.


DATA SOURCE AND ANY-MARKET USE

The volume source is user-selectable (Settings > Data source), so the profile can
be built from the symbol's own volume or from any other series your feed
provides. For symbols that report no native volume (some cash indices and FX
feeds), an optional "borrow volume" field lets you supply a volume-bearing proxy
for the same instrument; it only activates when the charted symbol genuinely has
no volume. The volatility-index symbol for the expected-move band is also
user-set and falls back to a daily-ATR band when left blank. An optional
asset-class auto-tune adapts the grid and node percentiles to the detected class.
All of these are blank or off by default, so nothing is tied to one market.


CALIBRATION NOTE

The calibration panel is descriptive only. It reports how often, in the past, on
the current symbol, price followed through after the logged events. Small samples
are flagged. It is not a probability of future results.


LIMITATIONS (HONEST)

- This uses a BAR-RANGE volume distribution (optionally refined by lower-timeframe
  bars). It approximates where volume traded within each bar. It is NOT exchange
  price-by-price volume, tick data, or order-flow/footprint, and it cannot see
  bid/ask.
- It needs real volume. Cash indices often report none — use the matching future
  or continuous contract, or the borrow-volume field.
- The higher-timeframe POC is a light single-bar proxy (the price of the
  highest-volume higher-timeframe bar over a lookback), not a full higher-
  timeframe profile.
- All readings are probabilistic context, not predictions.


DISCLAIMER

This script is a study/indicator for chart analysis and education only. It is NOT
a strategy, NOT a recommendation, and NOT financial advice. It places no orders
and guarantees no result. Trading involves substantial risk; a level's past
behaviour does not assure future behaviour. Do your own research and manage your
own risk.

## Source Code

````pine
// =============================================================================
// Auction Volume Profile — Composite POC, Value Area & Order-Flow      Pine v6
// =============================================================================
// OVERVIEW
//   A full-depth volume-at-price engine. It reads where trade actually happened
//   across all loaded history, distils that into the levels traders act on —
//   Point of Control, Value Area, High/Low-Volume Nodes and untested ("naked")
//   POCs — and turns them into a plain-language read of where price sits in the
//   auction. It runs on any volume-bearing symbol in any market; the volume
//   source and every optional reference feed are user-selectable in Settings.
//   Defaults are tuned for NSE NIFTY index futures (intraday); change the data
//   source and the session window for other instruments.
//
// WHAT IT PLOTS
//   - Buy/sell two-tone volume profile, drawn in the clear space right of price.
//   - POC (most-traded price / fair-value magnet) and Value Area (VAH / VAL).
//   - HVN / LVN nodes (acceptance shelves vs thin, fast-move gaps).
//   - Untested ("naked") prior-session POCs price has not traded back through.
//   - Optional reference layers: prior-day / prior-week POC & value area, a
//     full-history composite overlay, an auto-anchored VWAP with sigma bands,
//     Initial Balance, poor highs/lows, an expected-move band, developing POC.
//   - Order-flow layer: a probabilistic buy/sell split (Bulk Volume
//     Classification), cumulative-volume-delta divergence, and an optional
//     volume-bucket order-imbalance toxicity read (VPIN).
//   - Auto-Read dashboard + one-line headline: context, value-migration trend,
//     nearest support / resistance, shape and stretch from POC.
//   - Optional PAST-ONLY calibration panel: measured hit-rate, base rate and the
//     resulting EDGE of the reversion / continuation reads on THIS symbol.
//
// WHY THESE PARTS ARE COMBINED (mashup rationale)
//   A raw volume histogram only answers "where did volume happen". It cannot say
//   whether price is rich or cheap, which level matters next, or whether the
//   auction is balancing or trending. This is ONE volume-profile engine whose
//   layers each remove a specific blind spot of the raw histogram, and EVERY
//   layer is derived from the SAME accumulated volume map — they are not
//   independent indicators stacked together:
//     * Value Area + POC          -> a fair-value frame (premium / discount /
//                                    in-value).
//     * HVN / LVN                 -> classify each price as acceptance (likely
//                                    reaction) or gap (likely fast move).
//     * Naked POCs                -> carry acceptance across sessions as magnets.
//     * Value migration           -> the sequence of daily POCs becomes a trend.
//     * Composite overlay         -> keep long-term structure visible inside a
//                                    recent window.
//     * Buy/sell split, CVD, VPIN -> order-flow context on the same volume: who
//                                    is in control and whether flow is one-sided.
//     * VWAP / IB / expected move -> independent confluence: a session/swing
//                                    mean, the opening balance, a realistic range.
//     * Auto-Read                 -> the synthesis: ranks the engine's own levels
//                                    by distance to price and states the read.
//     * Calibration               -> measures, on PAST data only, whether those
//                                    reads actually carried an edge on this symbol.
//   The histogram is the raw material; every other layer is a transformation of
//   that same data into a level, a classification or a read. That is why they
//   live in one script rather than as separate indicators.
//
// HOW IT WORKS (engine)
//   Volume is accumulated bar-by-bar into a price-keyed map, so the profile can
//   span every loaded bar and is not limited by the historical bar-reference
//   ceiling. Accumulation runs on a fine grid (mintick x factor) and is
//   re-aggregated to the chosen display rows. Each bar's volume is distributed
//   across its high-low range and split into buy / sell with Bulk Volume
//   Classification — a probabilistic share Phi(dP / sigma_dP) instead of a
//   binary up-bar / down-bar flag. Where lower-timeframe data is available,
//   recent history is refined from intrabar bars. The Value Area is grown
//   outward from the POC until the target share of volume is captured; naked /
//   prior / weekly levels reuse the same routine on per-day and per-week maps.
//   The profile can optionally be smoothed with a Gaussian (KDE) kernel before
//   node detection so single-bar spikes do not create false nodes.
//
// HOW TO USE
//   1. Pick a scope: Rolling (default), Composite (all history), From date or
//      Fixed range. The composite overlay keeps big-picture levels in view.
//   2. Read location first (headline / dashboard): in value, premium or
//      discount, and whether value is migrating up / down / flat.
//   3. Use levels as a map, not a signal: POC = mean-revert magnet; VA edges =
//      balance boundaries; HVN = expect stalls; LVN = expect fast moves; naked
//      POC = revisit magnet.
//   4. Seek confluence with VWAP / IB / prior-session levels; treat CVD
//      divergence and a high VPIN reading as caution flags.
//   5. Detail presets (Simple / Standard / Pro) gate how much is shown.
//   6. The Calibration panel (optional) is a PAST-ONLY sanity check: read the
//      EDGE column (hit-rate minus the unconditional base rate), never the
//      hit-rate alone, and never tune parameters to make it green.
//
// SETTINGS FOR ANY MARKET
//   "Volume source" selects the raw series the profile is built from, so the
//   script runs on any instrument. Optional reference feeds (e.g. a
//   volatility-index symbol) are blank by default. A volume-bearing symbol is
//   required; cash indices often report no volume, so use the matching futures /
//   continuous contract, or borrow volume from a proxy symbol in Settings.
//
// CONCEPT CREDIT (techniques, not code — original implementation)
//   - Market Profile / value-area / auction framing: J. P. Steidlmayer (CBOT)
//     and J. F. Dalton ("Mind Over Markets").
//   - Probabilistic buy/sell split (Bulk Volume Classification) and the order-
//     flow toxicity reading (VPIN): Easley, Lopez de Prado & O'Hara (2012, 2016).
//   - First-touch outcome labelling (triple-barrier method): Lopez de Prado.
//   - Binomial confidence interval: Wilson score interval.
//   - Trend / regime read: Wilder's ADX and a Kaufman-style efficiency ratio.
//   The price-keyed full-history map, the EDGE-based calibration harness and the
//   plain-language Auto-Read are this script's own implementation.
//
// ORIGINALITY
//   Original implementation. The price-keyed map gives full-history depth beyond
//   a fixed lookback; the Auto-Read converts the engine's own levels into a
//   ranked, plain-language decision view; the calibration harness reports a real
//   EDGE (hit-rate minus base rate), not a bare hit-rate. The on-chart identity
//   strip always shows script name + symbol + timeframe.
//
// NON-REPAINT
//   The profile, POC / VA and Auto-Read DEVELOP intrabar on the last bar and
//   settle on close — they do not repaint history. Calibration events are logged
//   and resolved on CONFIRMED bars only and resolve on bars AFTER their trigger,
//   so the hit / base / edge figures use no look-ahead. The VWAP swing anchor
//   confirms one pivot-length after the swing; the HTF POC uses the last
//   confirmed higher-timeframe bar.
//
// LIMITATIONS (honest)
//   Uses a BAR-RANGE volume distribution (refined by lower-timeframe bars where
//   available). It approximates where volume traded within each bar; it is NOT
//   exchange price-by-price volume, tick data or order-flow / footprint, and it
//   cannot see bid/ask. The buy/sell split is a probabilistic ESTIMATE from bar
//   data, not classified order flow, and the published evidence on it is mixed.
//   It needs real volume. All reads are probabilistic context, not predictions.
//   Calibration is descriptive of PAST behaviour only — a measured edge is what
//   a level did historically on THIS symbol, not a backtest or a probability of
//   future results.
//
// DISCLAIMER
//   Study / indicator for chart analysis and education only. NOT a strategy, NOT
//   a recommendation and NOT financial advice. It places no orders and
//   guarantees no result. Markets involve risk; a level's past behaviour does
//   not assure future behaviour. Do your own research and manage your own risk.
// =============================================================================

//@version=6
indicator("Auction Volume Profile — Composite POC, Value Area & Order-Flow", shorttitle="Auction VP", overlay=true,
     max_boxes_count=500, max_lines_count=500, max_labels_count=200, max_bars_back=5000)

// =============================================================================
// HELPERS
// =============================================================================
f_clamp(x, lo, hi) => math.max(lo, math.min(hi, x))
// Perceived luminance (0-255) — used to pick dark/white text on a coloured chip.
f_lum(color cc) => na(cc) ? 0.0 : (0.299 * color.r(cc) + 0.587 * color.g(cc) + 0.114 * color.b(cc))
// History-scan ceiling for the From-date / Fixed-range / Rolling fallback loops.
// Kept just under max_bars_back (5000) so the two can never silently drift apart.
int MAXLB = 4900
f_pos(s) => s=="top_left"?position.top_left : s=="bottom_right"?position.bottom_right : s=="bottom_left"?position.bottom_left : s=="top_right"?position.top_right : position.top_right
f_nearAbove(arr, ref, excl) =>
    int best = -1
    float bd = 1e20
    for i = 0 to array.size(arr) - 1
        if i != excl
            d = array.get(arr, i) - ref
            if d > 0 and d < bd
                bd := d
                best := i
    best
f_nearBelow(arr, ref, excl) =>
    int best = -1
    float bd = 1e20
    for i = 0 to array.size(arr) - 1
        if i != excl
            d = ref - array.get(arr, i)
            if d > 0 and d < bd
                bd := d
                best := i
    best
f_lvl(px, ty, ref) =>
    ty + " " + str.tostring(px, format.mintick)
// Glow level line: faint wide underlay + a thicker opaque core (one shade
// thicker than before). Both objects are pushed to the supplied line array so
// the existing teardown still cleans them up. col may already carry alpha; the
// underlay forces a high transparency to read as a soft glow on dark themes.
f_glowLine(larr, x1, x2, y, col, w, sty) =>
    array.push(larr, line.new(x1, y, x2, y, color=color.new(col, 82), width=w + 5, style=sty))
    array.push(larr, line.new(x1, y, x2, y, color=color.new(col, 0), width=w, style=sty))
// Glow legend label (f_glowLab) is defined AFTER the inputs/palette block, so it
// can read the lblSz legend-size input and the f_lum contrast helper.
// Score-based 95% CI for a binomial proportion -> [lo,hi] in [0,1]; [na,na] if N<5.
f_propCI(int hits, int total) =>
    float lo = na
    float hi = na
    if total >= 5
        float p   = hits / float(total)
        float z   = 1.96
        float den = 1.0 + z*z/total
        float cen = (p + z*z/(2.0*total)) / den
        float hw  = z*math.sqrt(p*(1.0-p)/total + z*z/(4.0*total*total)) / den
        lo := math.max(0.0, cen - hw)
        hi := math.min(1.0, cen + hw)
    [lo, hi]
// Logistic approximation to the standard-normal CDF (used by Bulk Volume Classification).
f_normcdf(x) => 1.0 / (1.0 + math.exp(-1.702 * f_clamp(x, -8.0, 8.0)))
// Append one calibration event to the six parallel pending-event arrays (by reference).
f_pushEvt(int[] aB, float[] aP, float[] aA, int[] aD, int[] aT, int[] aR, int bi, float px, float atr, int dir, int typ, int reg) =>
    array.push(aB, bi)
    array.push(aP, px)
    array.push(aA, atr)
    array.push(aD, dir)
    array.push(aT, typ)
    array.push(aR, reg)
f_mapVA(m, st, pct) =>
    ks = map.keys(m)
    int nK = array.size(ks)
    float tot = 0.0
    float bestV = -1.0
    int bestK = 0
    int minK = nK>0 ? array.get(ks,0) : 0
    int maxK = nK>0 ? array.get(ks,0) : 0
    for i = 0 to nK - 1
        kk = array.get(ks, i)
        vv = map.get(m, kk)
        tot += vv
        if vv > bestV
            bestV := vv
            bestK := kk
        minK := math.min(minK, kk)
        maxK := math.max(maxK, kk)
    float acc = bestV
    int up = bestK
    int dn = bestK
    float target = tot * pct / 100.0
    span = maxK - minK + 2
    for n = 0 to span
        if acc >= target
            break
        upCan = up < maxK
        dnCan = dn > minK
        if not upCan and not dnCan
            break
        uV = upCan and map.contains(m, up+1) ? map.get(m, up+1) : 0.0
        dV = dnCan and map.contains(m, dn-1) ? map.get(m, dn-1) : 0.0
        if (uV >= dV and upCan) or not dnCan
            up += 1
            acc += uV
        else
            dn -= 1
            acc += dV
    [ (bestK + 0.5) * st, (up + 1) * st, dn * st ]

// =============================================================================
// INPUTS
// =============================================================================
gScope  = "01 · Profile scope & range"
scopeMode= input.string("Rolling (recent sessions)", "Profile scope", options=["Rolling (recent sessions)","Composite (all history)","From date","Fixed range"], group=gScope, tooltip="Rolling = the last N sessions (default — legible & relevant to recent price). Composite = every loaded bar (max history). From date / Fixed range = custom windows.")
rollN    = input.int(5, "Rolling sessions", minval=1, maxval=120, group=gScope, tooltip="How many recent sessions the drawn profile covers in Rolling mode.")
showCompLevels=input.bool(true, "Composite key-levels overlay", group=gScope, tooltip="Always draw the full-history composite POC / value area as reference lines, even when the histogram is a recent window — so you keep the big-picture context.")
anchTime = input.time(timestamp("01 Jan 2020 00:00"), "Anchor / range start", group=gScope)
endTime  = input.time(timestamp("01 Jan 2027 00:00"), "Range end (Fixed range)", group=gScope)

gRes    = "02 · Profile resolution"
rows    = input.int(150, "Display rows", minval=20, maxval=200, group=gRes, tooltip="Number of horizontal bins drawn. Accumulation runs at a finer grid and is aggregated to this.")
fineTks = input.int(10,  "Fine grid (ticks per accumulation bin)", minval=1, maxval=500, group=gRes, tooltip="Accumulation resolution = mintick × this, so it adapts to any instrument automatically. Smaller = finer but heavier on wide-range symbols; raise it on very wide-range instruments to keep the map light.")
subMax  = input.int(16, "Max samples per bar", minval=2, maxval=40, group=gRes, tooltip="How many price levels each bar's volume is spread over. Caps work per bar so long histories stay fast.")
vaPct   = input.float(70, "Value-area %", minval=30, maxval=95, group=gRes)

gShow   = "03 · Display & style"
showSplit= input.bool(true, "Buy / sell split (two-tone)", group=gShow)
showVA  = input.bool(true, "Value area + POC lines", group=gShow)
showNodes=input.bool(true, "HVN / LVN nodes", group=gShow)
useRobustNodes=input.bool(true, "  Robust node thresholds (percentile)", group=gShow, tooltip="ON (recommended): HVN = bins above the upper percentile of bin volumes, LVN = bins below the lower percentile — self-scales to the profile's shape so the node read does not collapse on peaked profiles or vanish on flat ones. OFF: fixed × average (the two values below).")
hvnPct  = input.float(80, "  HVN percentile", minval=50, maxval=99, step=1, group=gShow, tooltip="When robust thresholds are ON: a bin is an HVN if its volume is above this percentile of all non-empty bins.")
lvnPct  = input.float(25, "  LVN percentile", minval=1,  maxval=50, step=1, group=gShow, tooltip="When robust thresholds are ON: a bin is an LVN if its volume is below this percentile of all non-empty bins.")
hvnK    = input.float(1.4, "  HVN threshold (× avg, fallback)", minval=1.0, maxval=4.0, step=0.1, group=gShow, tooltip="Used when robust thresholds are OFF (or while the profile has too few bins to take a percentile).")
lvnK    = input.float(0.5, "  LVN threshold (× avg, fallback)", minval=0.1, maxval=1.0, step=0.05, group=gShow)
useKDE  = input.bool(true, "Smooth profile (KDE)", group=gShow, tooltip="ON (default): convolve the profile with a Gaussian kernel before POC / value-area / HVN / LVN detection, so single-bar volume spikes do not create false nodes. Affects the displayed two-tone profile and every level derived from it (POC, VAH/VAL, HVN/LVN, the Auto-Read). Turn OFF for the raw histogram. Does NOT touch the prior-day value area or the calibration engine, which are built from the daily map.")
kdeBw   = input.float(2.0, "  KDE bandwidth (bins)", minval=0.5, maxval=10.0, step=0.5, group=gShow, tooltip="Gaussian standard deviation in price-bins. Larger = smoother profile, broader nodes. The kernel window is 3 bandwidths each side.")
showNaked=input.bool(true, "Untested (naked) daily POCs", group=gShow)
maxNaked= input.int(25, "  Keep last N daily POCs", minval=2, maxval=120, group=gShow)
nakedMaxAgeBars=input.int(0, "  Naked POC max age (bars, 0=off)", minval=0, maxval=20000, group=gShow, tooltip="Retire a naked POC after this many bars even if still untested, so stale levels don't accumulate. 0 disables the age-out.")
straddleLook=input.int(20, "  Straddle look-back at creation (bars)", minval=0, maxval=100, group=gShow, tooltip="When a day's POC is captured, if price already traded through that level within this many recent bars it was effectively tested — so it is NOT logged as naked. 0 disables the check.")
profW   = input.int(70, "Profile width (bars)", minval=10, maxval=300, group=gShow)
profGap = input.int(6,  "Gap from last bar (bars)", minval=0, maxval=50, group=gShow)
sideRight=input.bool(true, "Draw on right side (overlay mode)", group=gShow)
rightOfPrice=input.bool(true, "Profile in clear space right of price", group=gShow, tooltip="Recommended. Draws the histogram in the blank area to the right of the last bar so candles stay fully visible. Uncheck to overlay the histogram on price.")
profTr  = input.int(45, "Profile transparency", minval=0, maxval=90, group=gShow)
vaShade = input.bool(true, "Shade the value area", group=gShow)
showTbl = input.bool(true, "Dashboard", group=gShow)
tblCompact = input.bool(false, "  Compact dashboard (key fields only)", group=gShow, tooltip="OFF (default) = the full decision table. ON = a trimmed table with only the fields needed to act: context, nearest support/resistance, price, POC, location, stretch, reversion R:R, trend and data health. Useful on small screens or for a clean publish.")
tblTheme= input.string("Auto","Dashboard theme", options=["Auto","Dark","Light"], group=gShow)
palette = input.string("Blue / Orange", "Colour scheme", options=["Blue / Orange","Teal / Magenta"], group=gShow, tooltip="Blue / Orange (default): blue buy / orange sell two-tone, yellow POC, teal HVN / grey LVN nodes, green & red imbalance and delta, navy zero-volume gaps, flat lines and right-anchored bars. Teal / Magenta: the alternative scheme with a soft glow line style and tick-mark nodes. Colours and bar styling only; every level, value and calculation is identical.")
tblPos  = input.string("top_right","Dashboard position", options=["top_right","top_left","bottom_right","bottom_left"], group=gShow)
showId  = input.bool(true, "Identity label", group=gShow)
lvlSize = input.string("Small", "Legend text size", options=["Tiny","Small","Normal"], group=gShow, tooltip="Text size of the on-chart level chips (POC / VAH / VAL / PD / PW / HTF / IB / EM / S-R / MAG …).")
lnWidth = input.int(2, "Line thickness", minval=1, maxval=5, group=gShow, tooltip="Core width of every level line; the soft glow underlay is drawn 5px wider, matching the suite's ORB / TPO line style.")
showKey = input.bool(true, "Legend key (decode lines)", group=gShow, tooltip="A small colour-coded key that decodes every drawn level: POC, value-area edges, HVN/LVN nodes, naked POC, prior day / week, composite, HTF POC, VWAP, Initial Balance, expected move, auto S/R and polarity-flip.")
keyPos  = input.string("bottom_left", "Legend key position", options=["top_left","top_right","bottom_left","bottom_right"], group=gShow)
preset  = input.string("Pro", "Detail preset", options=["Simple","Standard","Pro"], group=gShow, tooltip="Simple = profile + POC/value area + nearest S/R + headline. Standard = adds Auto-Read, composite levels, prior-day, naked POC, CVD, VWAP, poor H/L. Pro = everything (IB, expected-move, delta panel, prior-week, imbalance, gaps, developing POC). Individual toggles still apply within the chosen preset.")
showHeadline=input.bool(true, "Headline banner (one-look read)", group=gShow)
gRead   = "04 · Auto-Read (decision layer)"
showRead= input.bool(true, "Auto-Read panel", group=gRead, tooltip="Plain-language read of the profile: nearest support/resistance, auction context, value-migration trend, shape and stretch — all derived from the levels the profile already computes.")
showKeyLines=input.bool(true, "S/R 1·2 + magnet lines on chart", group=gRead)
showRR  = input.bool(true, "Reversion R:R row (reference only)", group=gRead, tooltip="Reports the reward:risk of the textbook value-edge rotation — from the near VA edge back to the POC, with a stop a fixed ATR multiple beyond the edge. Reference geometry only; the script places no orders.")
rrStopATR=input.float(0.5, "  Reversion stop (× ATR beyond edge)", minval=0.1, maxval=3.0, step=0.1, group=gRead)
usePolarityFlip=input.bool(true, "Polarity flip (broken VA edge changes role)", group=gRead, tooltip="A prior-day VAH that price closes decisively ABOVE (and holds) flips to support; a prior-day VAL closed decisively BELOW flips to resistance. The flipped level is drawn and fed into the S/R read. Cleared when price closes back through it.")
flipThr =input.float(0.3, "  Flip threshold (% past the edge)", minval=0.05, maxval=3.0, step=0.05, group=gRead)
flipBars=input.int(2, "  Flip confirmation (closes)", minval=1, maxval=10, group=gRead)

gT1     = "05 · Layers — core"
showPriorDay=input.bool(true, "Prior-day POC / VAH / VAL", group=gT1)
showPriorWk =input.bool(true, "Prior-week POC / VAH / VAL", group=gT1)
showDevPOC  =input.bool(true, "Developing POC line", group=gT1, tooltip="Plots how the Point of Control migrated over time — visualises value migration / trend.")
useLTF      =input.bool(false,"LTF refinement (precise recent volume)", group=gT1, tooltip="Optional. Builds volume-at-price from lower-timeframe bars where available (finer for recent history). Heavier and depends on intrabar data availability for your symbol/plan; older bars fall back to the bar-range method. Off by default for fast, universal first load.")
ltfRes      =input.timeframe("1","  LTF resolution", group=gT1)
showCVD     =input.bool(true, "CVD divergence", group=gT1, tooltip="Cumulative volume delta vs price; flags exhaustion when price and delta disagree.")
cvdLen      =input.int(20,    "  CVD divergence lookback", minval=3, maxval=200, group=gT1)
useVPIN     =input.bool(true, "VPIN toxicity (volume-bucket imbalance)", group=gT1, tooltip="Volume-Synchronised Probability of Informed Trading. Splits volume into equal-volume buckets, measures |buy-sell| order imbalance per bucket (buy/sell taken from the BVC split), and averages it over a rolling window. High VPIN = one-sided, 'toxic' flow that often precedes volatility. A descriptive estimate from BAR data, not exchange-classified order flow.")
vpinBars    =input.int(30,    "  VPIN bars per bucket (volume)", minval=2, maxval=500, group=gT1, tooltip="Equal-volume bucket size as a multiple of average bar volume: bucket volume = avg bar volume x this. Larger = smoother, slower VPIN.")
vpinN       =input.int(50,    "  VPIN rolling buckets", minval=5, maxval=250, group=gT1, tooltip="Number of most-recent buckets averaged into the VPIN reading.")
showImb     =input.bool(true, "Buy/sell imbalance shelves", group=gT1)
imbRatio    =input.float(2.5, "  Imbalance ratio", minval=1.0, maxval=10.0, step=0.1, group=gT1)
showGaps    =input.bool(true, "Volume gaps (single prints)", group=gT1)
gT2     = "06 · Layers — confluence"
showVWAP    =input.bool(true, "VWAP", group=gT2)
vwMode      =input.string("Dual (auto)","  VWAP anchor", options=["Session","Swing Low","Swing High","Dual (auto)"], group=gT2, tooltip="Adaptive auto-anchor, no manual date. Session = resets each day. Swing Low / Swing High = anchor to that pivot. Dual (auto) = anchor to the more recent of the last swing low / high and re-anchor as new structure forms. Swing anchors confirm one pivot-length after the swing.")
vwPivLen    =input.int(21, "  Swing pivot length (bars)", options=[8,13,21,34,55,89], group=gT2)
vwMinBars   =input.int(10, "  VWAP min bars between re-anchors", minval=0, maxval=200, group=gT2, tooltip="Thrash guard for Swing / Dual anchors: ignore a new swing if fewer than this many bars have passed since the last re-anchor, so the VWAP does not whipsaw on clustered pivots. 0 = re-anchor on every confirmed pivot (old behaviour). Session resets are never blocked.")
showVwBands =input.bool(true, "  VWAP bands", group=gT2)
vwMult      =input.float(2.0,"  VWAP band σ", minval=0.5, maxval=4.0, step=0.5, group=gT2)
showVwGlow  =input.bool(true, "  VWAP line glow", group=gT2)
showIB      =input.bool(true, "Initial Balance (first session range)", group=gT2)
ibMin       =input.int(60,   "  IB minutes", minval=5, maxval=240, group=gT2)
showPoor    =input.bool(true, "Poor highs / lows", group=gT2)
poorK       =input.float(0.6,"  Poor H/L threshold (× avg)", minval=0.1, maxval=2.0, step=0.1, group=gT2)
gT3     = "07 · Layers — advanced"
emVixSym    =input.symbol("","Volatility index symbol (expected move)", group=gT3, tooltip="Optional. Enter your market's volatility-index symbol (the implied-volatility index for the instrument you are charting) to draw the day's expected-move band around the session open. Leave blank to fall back to a daily-ATR band, which works on any instrument out of the box.")
showEM      =input.bool(true,"  Show expected-move band", group=gT3)
showDeltaPanel=input.bool(true,"Delta summary panel", group=gT3)
deltaSecN   =input.int(12,   "  Delta sections", minval=2, maxval=40, group=gT3)
deltaPanelW =input.int(30,   "  Delta panel width (bars)", minval=5, maxval=120, group=gT3)

gCtx    = "08 · Context (read sharpeners)"
showRegime  = input.bool(true, "Regime read (trend / range / volatile)", group=gCtx, tooltip="ADX + efficiency-ratio + volatility-cluster read that sharpens the Auto-Read: in a range expect rotation / fade at value edges; in a trend expect acceptance and value migration. Context only — it does NOT change the profile.")
emAtrMult   = input.float(1.0, "Expected-move = daily ATR × (when no vol-index)", minval=0.25, maxval=4.0, step=0.25, group=gCtx, tooltip="If the volatility-index symbol is blank, the expected-move band is built from this × the symbol's daily ATR, so the band works on any instrument out of the box.")
showHealth  = input.bool(true, "Data-health read (volume reliability)", group=gCtx, tooltip="Reports whether the feed's volume is reliable and the detected asset class. A volume profile is only as trustworthy as its volume.")
autoTune    = input.bool(true, "Auto-tune grid & nodes by asset class", group=gCtx, tooltip="On by default. Adjusts the accumulation grid (ticks per bin) and the HVN/LVN percentiles to the detected asset class — coarser on wide-range crypto, finer elsewhere — so one instrument's settings don't have to fit them all. Off keeps your manual Resolution / node settings exactly. Shown as ·tuned in the DATA row.")

gHTF    = "09 · Higher-timeframe confluence"
showHTFpoc  = input.bool(true, "Higher-timeframe POC bias", group=gHTF, tooltip="Marks the highest-volume price of a higher timeframe over a lookback (a light HTF point-of-control proxy, one security call — NOT a full HTF profile). Adds a confluence row and an S/R candidate. Honest: it is the modal HTF bar's price, not an exchange HTF profile.")
htfRes1     = input.timeframe("D", "  HTF resolution", group=gHTF)
htfLook     = input.int(30, "  HTF lookback (HTF bars)", minval=3, maxval=300, group=gHTF, tooltip="How many higher-timeframe bars back to search for the highest-volume bar.")

gCal    = "10 · Calibration (past-only)"
calEnable   = input.bool(true, "Log & evaluate reversion (background)", group=gCal, tooltip="Logs each reversion event when it fires and scores it after the horizon. Lightweight — leave on even if the panel is hidden. Events are anchored on the prior-day value area, which exists on every bar, so the hit-rate backfills over loaded history. Descriptive of the PAST only; NOT a backtest or forward prediction.")
calShowPanel= input.bool(false, "Show calibration panel", group=gCal, tooltip="Off by default. Reports measured past hit-rate by event type with a 95% confidence interval (score method).")
calPos      = input.string("bottom_right", "Calibration panel position", options=["top_left","top_right","bottom_left","bottom_right"], group=gCal)
calHorizon  = input.int(20, "Evaluation horizon (bars)", minval=3, maxval=200, group=gCal, tooltip="How many bars after an event to measure follow-through.")
calFavATR   = input.float(0.5, "Min follow-through (× ATR) to count a hit", minval=0.1, maxval=3.0, step=0.1, group=gCal, tooltip="Reversion must move at least this × ATR in the expected direction (back toward value / POC) within the horizon to count as respected.")
calStretchATR=input.float(1.0, "POC-stretch trigger (× ATR)", minval=0.25, maxval=5.0, step=0.25, group=gCal, tooltip="A POC-reversion event is logged when price first becomes stretched this many ATRs from the prior-day POC.")
calAtrLen   = input.int(14, "ATR length (calibration + stretch)", minval=1, maxval=200, group=gCal)

gSrc    = "11 · Data source (any market)"
volSrcRaw = input.source(volume, "Volume source", group=gSrc, tooltip="The raw-data series the profile is built from — lets the script run on any instrument in any market. Default is the symbol's own volume; substitute another series (e.g. a volume study's plot) if your feed's volume is unreliable. A volume-bearing symbol is required for a meaningful profile.")
volBorrowSym = input.symbol("", "Borrow volume from symbol (no-volume fix)", group=gSrc, tooltip="Optional, for symbols with no native volume (e.g. cash indices and some FX feeds). Enter a volume-bearing proxy for the same instrument (its future or continuous contract) and the profile is built from that proxy's volume. It only activates when the charted symbol truly has no native volume — on any volume-bearing symbol it does nothing. Blank = never borrow.")
enableExports = input.bool(false, "Export levels (data window)", group=gSrc, tooltip="Publishes POC / VAH / VAL / prior-day POC / composite POC / HTF POC plus the regime code, developing POC, VWAP and VPIN as hidden Data-Window plots (EXP_*) so another script can read them via request.security(). EXP_REGIME (0 range · 1 trend-up · 2 trend-down · 3 volatile) lets this act as a shared regime source for the rest of the suite. Off-chart; no visual change.")
useBVC = input.bool(true, "Bulk Volume Classification (BVC) buy/sell split", group=gSrc, tooltip="ON (recommended): split each bar's volume into buy/sell with Bulk Volume Classification - buy fraction = Phi(dP / sigma_dP), a probabilistic split, instead of the binary up-bar=all-buy rule. Feeds the two-tone histogram, CVD, imbalance, delta panel and buy/sell %. OFF reproduces the original binary split exactly. Honest: BVC evidence is mixed (some studies find it no better than a tick rule on tick data); on BAR data it is still a finer estimate than a binary flag, but it is an estimate, not exchange-classified order flow.")
bvcWin = input.int(20, "  BVC volatility window (bars)", minval=5, maxval=200, group=gSrc, tooltip="Lookback for the volume-weighted standard deviation of bar-to-bar price changes used to standardise dP.")
useSession = input.bool(false, "Restrict to session (RTH only)", group=gSrc, tooltip="OFF (default): use every bar's volume. ON: count only volume inside the session below, excluding extended / overnight hours from the WHOLE engine - profile, CVD, VPIN, naked POCs and the daily value area. Bars outside the session still display; they just contribute no volume.")
sessSpec   = input.session("0915-1530", "  Session (exchange time)", group=gSrc, tooltip="Regular-trading-hours window in the exchange's own time, HHMM-HHMM. Default 0915-1530 is NSE cash/index-futures RTH. Only used when 'Restrict to session' is on and the chart is intraday.")
// borrow only when the chart has no NATIVE volume (latched: once seen, never borrow)
var bool nativeVolSeen = false
if volume > 0
    nativeVolSeen := true
useBorrow = str.length(volBorrowSym) > 0 and not nativeVolSeen
volBorrowRaw = useBorrow ? request.security(volBorrowSym, timeframe.period, volume, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true) : na
// Effective volume the WHOLE engine consumes: borrow when a valid proxy is set.
volSrc = useBorrow and not na(volBorrowRaw) ? volBorrowRaw : volSrcRaw
// C3: optional session restriction — exclude out-of-session (e.g. ETH) volume from the whole engine
if useSession and timeframe.isintraday and na(time(timeframe.period, sessSpec))
    volSrc := 0.0

// --- Bulk Volume Classification: probabilistic buy fraction of each bar's volume ---
// buyFrac in [0,1]; with BVC off it collapses to the original binary up/down rule, so the
// engine is byte-for-byte backward compatible. sigma_dP = volume-weighted RMS of bar moves.
bvcDP    = close - close[1]
bvcNum   = ta.sma(nz(volSrc, 0.0) * bvcDP * bvcDP, bvcWin)
bvcDen   = ta.sma(nz(volSrc, 0.0), bvcWin)
bvcSigVW = bvcDen > 0 ? math.sqrt(math.max(bvcNum / bvcDen, 0.0)) : na
bvcSigFb = ta.stdev(bvcDP, bvcWin)
bvcSig   = not na(bvcSigVW) and bvcSigVW > 0 ? bvcSigVW : bvcSigFb
buyFrac  = useBVC and not na(bvcSig) and bvcSig > 0 ? f_clamp(f_normcdf(bvcDP / bvcSig), 0.0, 1.0) : (close >= open ? 1.0 : 0.0)

// --- palette ---------------------------------------------------------------
bool pZ = palette == "Blue / Orange"
color hBull = pZ ? #2962ff : #21dfac   // buy / bull hue
color hBear = pZ ? #ff9800 : #df216d   // sell / bear hue
color hPoc  = pZ ? #ffd600 : #ffa600   // POC / magnet
color hVa   = pZ ? #5b9cf6 : #79c0ff   // value-area lines
color hHvn  = pZ ? #00b8a3 : #b07cff   // high-volume nodes
color hLvn  = pZ ? #787b86 : #6b7480   // low-volume nodes
color hImbB = pZ ? #00e676 : #21dfac   // buy imbalance / +delta
color hImbS = pZ ? #f23645 : #df216d   // sell imbalance / -delta
color hGap  = pZ ? #1f3a93 : #79c0ff   // zero-volume gaps (navy in Z)
cBuy = color.new(hBull, 35)
cSell= color.new(hBear, 35)
cPoc = color.new(hPoc, 0)
cVa  = color.new(hVa, 0)
cVaFill = color.new(hVa, 90)
cHvn = color.new(hHvn, 0)
cLvn = color.new(hLvn, 0)
cNak = color.new(pZ ? #ffa726 : #ff9d3b, 0)
cR1L = color.new(#f23645, 0)   // resistance = red
cR2L = color.new(#f23645, 45)
cS1L = color.new(#089981, 0)   // support = green
cS2L = color.new(#089981, 45)
cMagL= color.new(hPoc, 0)
cPDay= color.new(#00bcd4, 0)
cPWk = color.new(#e879f9, 0)
cDev = color.new(hPoc, 35)
cImbB= color.new(hImbB, 0)
cImbS= color.new(hImbS, 0)
cGap = color.new(hGap, pZ ? 55 : 80)
famBull = hBull
famBear = hBear
cIB   = color.new(#ffca28, 0)
cEM   = color.new(#26c6da, 0)
cPoor = color.new(#ff7043, 0)
cComp = color.new(hPoc, 55)
cCompVa= color.new(#9aa3b2, 35)

// legend chip size token + bold chip label (relocated here so it can read lblSz
// and f_lum). Filled colour-coded chip; text auto-contrasts (dark on light hues,
// white on dark) exactly like the suite's ORB / TPO level chips. Pushed to parr
// so the existing teardown still cleans it up.
lblSz = lvlSize=="Tiny" ? size.tiny : lvlSize=="Normal" ? size.normal : size.small
f_glowLab(parr, x, y, txt, sty, col) =>
    array.push(parr, label.new(x, y, txt, style=sty, color=color.new(col, 0), textcolor=(f_lum(col) > 140 ? color.rgb(10,10,10) : color.white), size=lblSz))

// effective layer flags (preset gates the user toggles)
pLvl = preset=="Simple" ? 0 : preset=="Pro" ? 2 : 1
eRead  = showRead and pLvl>=1
eComp  = showCompLevels and pLvl>=1
ePDay  = showPriorDay and pLvl>=1
ePWk   = showPriorWk and pLvl>=2
eNaked = showNaked and pLvl>=1
eCVD   = showCVD and pLvl>=1
eVWAP  = showVWAP and pLvl>=1
eIB    = showIB and pLvl>=2
eEM    = showEM and pLvl>=1
eDelta = showDeltaPanel and pLvl>=1
eImb   = showImb and pLvl>=2
eGaps  = showGaps and pLvl>=2
eDev   = showDevPOC and pLvl>=2
ePoor  = showPoor and pLvl>=1

// =============================================================================
// SCOPE + ACCUMULATION (per-bar, price-keyed maps → max history)
// =============================================================================
// optional asset-class auto-tune of the accumulation grid (opt-in; constant per symbol, no repaint)
fineTksEff = autoTune ? (syminfo.type=="crypto" ? fineTks*3 : syminfo.type=="index" ? fineTks*2 : (syminfo.type=="forex" or syminfo.type=="cfd") ? math.max(1, fineTks) : fineTks) : fineTks
step = syminfo.mintick * fineTksEff
// Composite map is only built when something actually consumes it: Composite
// scope, the composite key-levels overlay, or the developing-POC plot. In Rolling
// / From-date / Fixed-range with the overlay off this whole pass (incl. the LTF
// loop) is skipped — the histogram there is built from bar history, not vMap.
inScope = scopeMode == "Composite (all history)" or eComp or eDev

var map<int, float> vMap = map.new<int, float>()
var map<int, float> bMap = map.new<int, float>()
var float scopeVol  = 0.0
volCumAll = ta.cum(nz(volSrc, 0.0))
var float scopeBuy  = 0.0
var int   scopeBars = 0
var int   curPocK = na
var float curPocV = 0.0
var float cvd = 0.0
var float pdPOC = na
var float pdVAH = na
var float pdVAL = na
var float pwPOC = na
var float pwVAH = na
var float pwVAL = na
ltfP = request.security_lower_tf(syminfo.tickerid, ltfRes, hlc3)
ltfV = request.security_lower_tf(syminfo.tickerid, ltfRes, volume)
ltfS = request.security_lower_tf(syminfo.tickerid, ltfRes, close >= open ? 1.0 : -1.0)
cvd := cvd + (2.0 * nz(buyFrac, 0.5) - 1.0) * nz(volSrc, 0.0)

// ---- Regime context (ADX + efficiency ratio + volatility cluster) ----
rgChg = math.abs(close - close[14])
rgVol = math.sum(math.abs(close - close[1]), 14)
rgER  = rgVol == 0 ? 0.0 : rgChg / rgVol
[rgDiP, rgDiM, rgADX] = ta.dmi(14, 14)
rgMa   = ta.ema(close, 50)
rgBull = close > rgMa
rgLogRet = math.abs(nz(ta.change(math.log(close))))
var float rgHawk = 0.0
rgHawk := rgHawk * math.exp(-0.20) + rgLogRet
rgHMean = ta.sma(rgHawk, 100)
rgHStd  = ta.stdev(rgHawk, 100)
rgHawkZ = rgHStd == 0 ? 0.0 : (rgHawk - rgHMean) / rgHStd
rgVolClust = rgHawkZ > 1.5
rgTrending = rgADX > 20.0 and rgER > 0.35
rgRegime = not showRegime ? "off" : rgVolClust and not rgTrending ? "volatile" : rgTrending ? (rgBull ? "trend up" : "trend down") : "range"
rgPct = math.round(f_clamp((rgADX/40.0)*50 + rgER*50, 0, 100))

// ---- Data health (volume reliability + asset class) ----
hVolOK = not na(volSrc) and volSrc > 0
var int hVolPresent = 0
var int hVolTotal = 0
if barstate.isconfirmed
    hVolTotal += 1
    hVolPresent += hVolOK ? 1 : 0
hVolRatio = hVolTotal > 0 ? hVolPresent / float(hVolTotal) : 0.0
hVolReliable = hVolRatio >= 0.80
hClass = syminfo.type == "stock" or syminfo.type == "fund" ? "equity" : syminfo.type == "futures" ? "futures" : syminfo.type == "index" ? "index" : syminfo.type == "forex" or syminfo.type == "cfd" ? "fx/cfd" : syminfo.type == "crypto" ? "crypto" : "generic"
hHealth = not (volCumAll > 0) ? "no volume" : not hVolReliable ? "vol gaps" : "ok"
// asset-class node-percentile tuning (opt-in)
hvnPctEff = autoTune ? (hClass=="crypto" ? 85.0 : hClass=="fx/cfd" ? 78.0 : hvnPct) : hvnPct
lvnPctEff = autoTune ? (hClass=="crypto" ? 20.0 : 25.0) : lvnPct

if inScope and step > 0
    if useLTF and array.size(ltfP) > 0
        for li = 0 to array.size(ltfP) - 1
            lp = array.get(ltfP, li)
            lv = array.get(ltfV, li)
            if not na(lp) and not na(lv) and lv > 0
                lu = array.get(ltfS, li) >= 0
                k = int(math.floor(lp / step))
                pv = map.contains(vMap, k) ? map.get(vMap, k) : 0.0
                nv = pv + lv
                map.put(vMap, k, nv)
                if nv > curPocV
                    curPocV := nv
                    curPocK := k
                if lu
                    pb = map.contains(bMap, k) ? map.get(bMap, k) : 0.0
                    map.put(bMap, k, pb + lv)
                scopeVol += lv
                scopeBuy += lu ? lv : 0.0
        scopeBars += 1
    else if high >= low and not na(volSrc)
        vol = nz(volSrc)
        rng = high - low
        sub = rng <= 0 ? 1 : int(math.min(subMax, int(rng/step) + 1))
        vper = vol / sub
        for sI = 0 to sub - 1
            px = sub == 1 ? (high+low)/2.0 : low + rng * sI / (sub - 1)
            k = int(math.floor(px / step))
            pv = map.contains(vMap, k) ? map.get(vMap, k) : 0.0
            nv = pv + vper
            map.put(vMap, k, nv)
            if nv > curPocV
                curPocV := nv
                curPocK := k
            bpb = map.contains(bMap, k) ? map.get(bMap, k) : 0.0
            map.put(bMap, k, bpb + vper * nz(buyFrac, 0.5))
        scopeVol += vol
        scopeBuy += vol * nz(buyFrac, 0.5)
        scopeBars += 1
devPOC = not na(curPocK) ? (curPocK + 0.5) * step : na
cvdRising = cvd > nz(cvd[cvdLen], cvd)
priceRising = close > nz(close[cvdLen], close)
cvdBearDiv = priceRising and not cvdRising
cvdBullDiv = (not priceRising) and cvdRising
cvdState = cvdBearDiv ? "bear div ⚠" : cvdBullDiv ? "bull div ⚠" : "in line"

// --- VPIN: volume-bucket order-imbalance toxicity -----------------------------
// Fill equal-volume buckets from BVC buy/sell volume; carry the overflow forward.
var float vpBuyAcc  = 0.0
var float vpSellAcc = 0.0
var float vpVolAcc  = 0.0
var float[] vpImb   = array.new_float(0)
// During the SMA's 50-bar warmup ta.sma is na; fall back to the current bar's
// volume so the bucket size is never the 1.0 floor (which would make the loop
// below iterate hundreds of thousands of times on a single high-volume bar).
float vpAvgVol  = nz(ta.sma(nz(volSrc, 0.0), 50), nz(volSrc, 0.0))
float vpBucketV = math.max(vpAvgVol * vpinBars, 1.0)
if useVPIN and barstate.isconfirmed and not na(volSrc) and volSrc > 0 and vpBucketV > 0
    float bvv = nz(buyFrac, 0.5) * volSrc
    vpBuyAcc  += bvv
    vpSellAcc += volSrc - bvv
    vpVolAcc  += volSrc
    int vpGuard = 0
    while vpVolAcc >= vpBucketV and vpGuard < 4
        float carry = (vpVolAcc - vpBucketV) / vpVolAcc
        float bBuy  = vpBuyAcc  * (1.0 - carry)
        float bSell = vpSellAcc * (1.0 - carry)
        array.push(vpImb, math.abs(bBuy - bSell))
        if array.size(vpImb) > vpinN
            array.shift(vpImb)
        vpBuyAcc  := vpBuyAcc  * carry
        vpSellAcc := vpSellAcc * carry
        vpVolAcc  := vpVolAcc - vpBucketV
        vpGuard   += 1
    // hard safety: at most 4 bucket closes per bar; drop any residual so the
    // loop can never run long and the accumulator can never grow without bound
    if vpVolAcc >= vpBucketV
        vpBuyAcc  := 0.0
        vpSellAcc := 0.0
        vpVolAcc  := 0.0
float vpin = (useVPIN and array.size(vpImb) >= 5 and vpBucketV > 0) ? array.sum(vpImb) / (array.size(vpImb) * vpBucketV) : na

// =============================================================================
// NAKED DAILY POC  (per-day mini-profile → store POC → mark tested)
// =============================================================================
newDay = ta.change(time("D")) != 0
var int[] sessBar = array.new_int(0)
if newDay
    array.push(sessBar, bar_index)
    if array.size(sessBar) > 300
        array.shift(sessBar)
var map<int, float> dMap = map.new<int, float>()
var float[] nakPx   = array.new_float(0)
var bool[]  nakLive = array.new_bool(0)
var int[]   nakBar  = array.new_int(0)     // creation bar (age-out)
var int[]   nakState= array.new_int(0)     // 0 live · 1 tested · 4 aged-out

// dMap / prior-day VA are also needed by the calibration tracker, so build
// them whenever naked, prior-day OR calibration is active.
if (showNaked or showPriorDay or calEnable) and newDay and map.size(dMap) > 0
    [dP, dH, dL] = f_mapVA(dMap, step, vaPct)
    pdPOC := dP
    pdVAH := dH
    pdVAL := dL
    if showNaked
        // straddle look-back: if price already traded through this POC in the
        // recent past it was effectively tested — don't log it as naked.
        bool straddled = false
        if straddleLook > 0
            int lbk = math.min(straddleLook, bar_index)
            for kk = 0 to lbk
                if low[kk] <= dP and high[kk] >= dP
                    straddled := true
                    break
        if not straddled
            array.push(nakPx, dP)
            array.push(nakLive, true)
            array.push(nakBar, bar_index)
            array.push(nakState, 0)
            if array.size(nakPx) > maxNaked
                array.shift(nakPx)
                array.shift(nakLive)
                array.shift(nakBar)
                array.shift(nakState)
    map.clear(dMap)

if (showNaked or showPriorDay or calEnable) and step > 0 and high >= low and not na(volSrc)
    rng2 = high - low
    sub2 = rng2 <= 0 ? 1 : int(math.min(subMax, int(rng2/step) + 1))
    vper2 = nz(volSrc) / sub2
    for sI = 0 to sub2 - 1
        px2 = sub2 == 1 ? (high+low)/2.0 : low + rng2 * sI / (sub2 - 1)
        k2 = int(math.floor(px2 / step))
        pv2 = map.contains(dMap, k2) ? map.get(dMap, k2) : 0.0
        map.put(dMap, k2, pv2 + vper2)

newWeek = ta.change(time("W")) != 0
var map<int, float> wMap = map.new<int, float>()
if showPriorWk and newWeek and map.size(wMap) > 0
    [wP, wH, wL] = f_mapVA(wMap, step, vaPct)
    pwPOC := wP
    pwVAH := wH
    pwVAL := wL
    map.clear(wMap)
if showPriorWk and step > 0 and high >= low and not na(volSrc)
    rngW = high - low
    subW = rngW <= 0 ? 1 : int(math.min(subMax, int(rngW/step) + 1))
    vperW = nz(volSrc) / subW
    for sI = 0 to subW - 1
        pxW = subW == 1 ? (high+low)/2.0 : low + rngW * sI / (subW - 1)
        kW = int(math.floor(pxW / step))
        pvW = map.contains(wMap, kW) ? map.get(wMap, kW) : 0.0
        map.put(wMap, kW, pvW + vperW)

// VWAP + bands — adaptive auto-anchor (no manual date)
vwapSrc = hlc3
vwPL = ta.pivotlow(low, vwPivLen, vwPivLen)
vwPH = ta.pivothigh(high, vwPivLen, vwPivLen)
bool vwNewLo = not na(vwPL)
bool vwNewHi = not na(vwPH)
// Dual: re-anchor whenever either pivot confirms -> tracks the most recent swing.
bool vwAnchorRaw = vwMode=="Session" ? newDay : vwMode=="Swing Low" ? vwNewLo : vwMode=="Swing High" ? vwNewHi : (vwNewLo or vwNewHi)
// thrash guard: in swing / dual modes require a minimum gap since the last re-anchor (session resets always pass)
var int vwLastAnchorBar = na
bool vwGuardOK = vwMode=="Session" or na(vwLastAnchorBar) or (bar_index - vwLastAnchorBar) >= vwMinBars
bool vwAnchor = vwAnchorRaw and vwGuardOK
if vwAnchor
    vwLastAnchorBar := bar_index
[vwVal, vwUp, vwDn] = ta.vwap(vwapSrc, vwAnchor, vwMult)

// Initial Balance (first IB minutes of each session)
var float ibHi = na
var float ibLo = na
var int   ibOpenT = na
var float dayOpen = na
if newDay
    ibHi := na
    ibLo := na
    ibOpenT := time
    dayOpen := open
inIB = timeframe.isintraday and not na(ibOpenT) and time <= ibOpenT + ibMin * 60 * 1000
if inIB
    ibHi := na(ibHi) ? high : math.max(ibHi, high)
    ibLo := na(ibLo) ? low  : math.min(ibLo, low)

// Volatility-index expected-move band (optional)
emHasVix = str.length(emVixSym) > 0
emSymUse = emHasVix ? emVixSym : syminfo.tickerid
emRaw = request.security(emSymUse, "D", close, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
emVix = emHasVix ? emRaw : na
emDayATR = request.security(syminfo.tickerid, "D", ta.atr(14), lookahead=barmerge.lookahead_off)

// HTF POC proxy: price (hlc3) of the highest-volume HTF bar over the lookback.
// One security call; honest light proxy for a higher-timeframe point of control.
eHTF = showHTFpoc and pLvl>=1
htfPOC1 = eHTF ? request.security(syminfo.tickerid, htfRes1, ta.valuewhen(volume == ta.highest(volume, htfLook), hlc3, 0)[1], lookahead=barmerge.lookahead_off) : na
emVixLive = not na(emVix)
emPct = emVixLive ? emVix / 100.0 / math.sqrt(252) : na
float emAbs = emVixLive and not na(dayOpen) ? dayOpen * emPct : (not na(emDayATR) ? emDayATR * emAtrMult : na)
emLive = not na(emAbs) and not na(dayOpen)
emUp = emLive ? dayOpen + emAbs : na
emDn = emLive ? dayOpen - emAbs : na

// =============================================================================
// NAKED POC MAINTENANCE  (tag → tested, optional age-out)
// =============================================================================
if showNaked and array.size(nakPx) > 0
    for i = 0 to array.size(nakPx) - 1
        if array.get(nakLive, i)
            if low <= array.get(nakPx, i) and high >= array.get(nakPx, i)
                array.set(nakLive, i, false)
                array.set(nakState, i, 1)
            else if nakedMaxAgeBars > 0 and (bar_index - array.get(nakBar, i)) > nakedMaxAgeBars
                array.set(nakLive, i, false)
                array.set(nakState, i, 4)

// =============================================================================
// POLARITY FLIP  (prior-day VA edge changes role when closed decisively beyond)
// =============================================================================
var float flipSupPx = na   // broken-above VAH now acting as support
var float flipResPx = na   // broken-below VAL now acting as resistance
var int   flipUpC = 0
var int   flipDnC = 0
if usePolarityFlip and barstate.isconfirmed and not na(pdVAH) and not na(pdVAL)
    if close > pdVAH * (1.0 + flipThr/100.0)
        flipUpC += 1
        if flipUpC >= flipBars
            flipSupPx := pdVAH
    else
        flipUpC := 0
    if close < pdVAL * (1.0 - flipThr/100.0)
        flipDnC += 1
        if flipDnC >= flipBars
            flipResPx := pdVAL
    else
        flipDnC := 0
    // invalidate when price closes back through the flipped level
    if not na(flipSupPx) and close < flipSupPx
        flipSupPx := na
    if not na(flipResPx) and close > flipResPx
        flipResPx := na

// =============================================================================
// CALIBRATION TRACKER  (past-only · descriptive · score-interval CI)
//   Anchored on the prior-day value area (available on every bar), so the
//   hit-rate backfills over loaded history. Two event types:
//     0 = VA-edge reversion  : fresh excursion beyond PD VAH/VAL → expect a
//         move back toward PD POC (down from above, up from below).
//     1 = POC-stretch reversion : price first stretched ≥ calStretchATR × ATR
//         from PD POC → expect a move back toward PD POC.
//   A hit = the expected-direction move reaches calFavATR × ATR within horizon.
// =============================================================================
calATR = ta.atr(calAtrLen)
// class ids:  0 VA-edge reversion · 1 POC-stretch reversion · 2 VA-breakout continuation
int NCAL = 3
int NREG = 4    // regime buckets: 0 range · 1 trend-up · 2 trend-down · 3 volatile
int NHYP = 2    // hypothesis groups for the regime footer: 0 reversion (cls 0,1) · 1 continuation (cls 2)
// per-class tallies (main panel)
var int[] calTot = array.new_int(NCAL, 0)
var int[] calHit = array.new_int(NCAL, 0)
var int[] calUpN = array.new_int(NCAL, 0)   // resolved events expecting UP   (base = baseUp)
var int[] calDnN = array.new_int(NCAL, 0)   // resolved events expecting DOWN (base = baseDn)
// hypothesis × regime tallies (regime footer) — index = hyp*NREG + reg
var int[] hypTot = array.new_int(NHYP*NREG, 0)
var int[] hypHit = array.new_int(NHYP*NREG, 0)
var int[] hypUpN = array.new_int(NHYP*NREG, 0)
var int[] hypDnN = array.new_int(NHYP*NREG, 0)
// pending events (resolved by first-touch triple barrier)
var int[]   pgBar = array.new_int(0)
var float[] pgPx  = array.new_float(0)
var float[] pgAtr = array.new_float(0)
var int[]   pgDir = array.new_int(0)        // +1 expect up · -1 expect down
var int[]   pgTyp = array.new_int(0)        // class id
var int[]   pgReg = array.new_int(0)        // regime bucket at event time
// unconditional base-rate sampler (every confirmed bar) — first-touch up vs down
var int baseN  = 0
var int baseUp = 0
var int baseDn = 0
var int[]   bqBar = array.new_int(0)
var float[] bqPx  = array.new_float(0)
var float[] bqAtr = array.new_float(0)
var int[]   bqReg = array.new_int(0)
// regime-conditioned base sampler (for the regime-footer edge) — index = reg
var int[] baseRegN  = array.new_int(NREG, 0)
var int[] baseRegUp = array.new_int(NREG, 0)
var int[] baseRegDn = array.new_int(NREG, 0)

// regime -> bucket id (default range bucket 0)
regNow = rgRegime == "trend up" ? 1 : rgRegime == "trend down" ? 2 : rgRegime == "volatile" ? 3 : 0

if calEnable and barstate.isconfirmed and not na(calATR) and calATR > 0
    // ---- resolve pending EVENTS first (an event never resolves on its own bar) ----
    int qi = 0
    while qi < array.size(pgBar)
        int age = bar_index - array.get(pgBar, qi)
        if age >= 1
            float p0 = array.get(pgPx, qi)
            float a0 = array.get(pgAtr, qi)
            int   dr = array.get(pgDir, qi)
            int   ty = array.get(pgTyp, qi)
            int   rg = array.get(pgReg, qi)
            float fav = dr > 0 ? p0 + calFavATR*a0 : p0 - calFavATR*a0
            float adv = dr > 0 ? p0 - calFavATR*a0 : p0 + calFavATR*a0
            bool favHit = dr > 0 ? high >= fav : low  <= fav
            bool advHit = dr > 0 ? low  <= adv : high >= adv
            bool resolved = false
            bool win = false
            if favHit and advHit
                resolved := true
                win := false                 // ambiguous same-bar touch -> conservative miss
            else if favHit
                resolved := true
                win := true
            else if advHit
                resolved := true
                win := false
            else if age >= calHorizon
                resolved := true
                win := false                 // timeout -> no follow-through
            if resolved
                array.set(calTot, ty, array.get(calTot, ty) + 1)
                if win
                    array.set(calHit, ty, array.get(calHit, ty) + 1)
                if dr > 0
                    array.set(calUpN, ty, array.get(calUpN, ty) + 1)
                else
                    array.set(calDnN, ty, array.get(calDnN, ty) + 1)
                int hy  = ty == 2 ? 1 : 0
                int hix = hy*NREG + rg
                array.set(hypTot, hix, array.get(hypTot, hix) + 1)
                if win
                    array.set(hypHit, hix, array.get(hypHit, hix) + 1)
                if dr > 0
                    array.set(hypUpN, hix, array.get(hypUpN, hix) + 1)
                else
                    array.set(hypDnN, hix, array.get(hypDnN, hix) + 1)
                array.remove(pgBar, qi)
                array.remove(pgPx, qi)
                array.remove(pgAtr, qi)
                array.remove(pgDir, qi)
                array.remove(pgTyp, qi)
                array.remove(pgReg, qi)
            else
                qi += 1
        else
            qi += 1

    // ---- resolve pending BASE samples (unconditional + regime-conditioned) ----
    int bi = 0
    while bi < array.size(bqBar)
        int age2 = bar_index - array.get(bqBar, bi)
        if age2 >= 1
            float bp0 = array.get(bqPx, bi)
            float ba0 = array.get(bqAtr, bi)
            int   brg = array.get(bqReg, bi)
            float upB = bp0 + calFavATR*ba0
            float dnB = bp0 - calFavATR*ba0
            bool upHit = high >= upB
            bool dnHit = low  <= dnB
            bool bres = false
            int  oc = 0                       // 0 none/ambiguous · 1 up-first · 2 dn-first
            if upHit and dnHit
                bres := true
                oc := 0
            else if upHit
                bres := true
                oc := 1
            else if dnHit
                bres := true
                oc := 2
            else if age2 >= calHorizon
                bres := true
                oc := 0
            if bres
                baseN += 1
                array.set(baseRegN, brg, array.get(baseRegN, brg) + 1)
                if oc == 1
                    baseUp += 1
                    array.set(baseRegUp, brg, array.get(baseRegUp, brg) + 1)
                else if oc == 2
                    baseDn += 1
                    array.set(baseRegDn, brg, array.get(baseRegDn, brg) + 1)
                array.remove(bqBar, bi)
                array.remove(bqPx, bi)
                array.remove(bqAtr, bi)
                array.remove(bqReg, bi)
            else
                bi += 1
        else
            bi += 1

    // ---- log NEW events on this confirmed bar ----
    if not na(pdVAH) and not na(pdVAL) and not na(pdPOC)
        bool freshAbove = close > pdVAH and not (close[1] > pdVAH)
        bool freshBelow = close < pdVAL and not (close[1] < pdVAL)
        if freshAbove
            f_pushEvt(pgBar, pgPx, pgAtr, pgDir, pgTyp, pgReg, bar_index, close, calATR, -1, 0, regNow)  // 0 revert down toward POC
            f_pushEvt(pgBar, pgPx, pgAtr, pgDir, pgTyp, pgReg, bar_index, close, calATR,  1, 2, regNow)  // 2 continue up away
        else if freshBelow
            f_pushEvt(pgBar, pgPx, pgAtr, pgDir, pgTyp, pgReg, bar_index, close, calATR,  1, 0, regNow)  // 0 revert up toward POC
            f_pushEvt(pgBar, pgPx, pgAtr, pgDir, pgTyp, pgReg, bar_index, close, calATR, -1, 2, regNow)  // 2 continue down away
        float trig = calStretchATR * calATR
        bool stretchNow  = math.abs(close - pdPOC) >= trig
        bool stretchPrev = math.abs(close[1] - pdPOC) >= trig
        if stretchNow and not stretchPrev
            int edir = close > pdPOC ? -1 : 1
            f_pushEvt(pgBar, pgPx, pgAtr, pgDir, pgTyp, pgReg, bar_index, close, calATR, edir, 1, regNow)

    // ---- log one unconditional base sample every confirmed bar ----
    array.push(bqBar, bar_index)
    array.push(bqPx, close)
    array.push(bqAtr, calATR)
    array.push(bqReg, regNow)

    // ---- caps (bound memory) ----
    while array.size(pgBar) > 400
        array.shift(pgBar)
        array.shift(pgPx)
        array.shift(pgAtr)
        array.shift(pgDir)
        array.shift(pgTyp)
        array.shift(pgReg)
    while array.size(bqBar) > 400
        array.shift(bqBar)
        array.shift(bqPx)
        array.shift(bqAtr)
        array.shift(bqReg)

// =============================================================================
// BUILD + DRAW on last bar
// =============================================================================
var box[]   vBoxes = array.new_box()
var box[]   sBoxes = array.new_box()
var line[]  vLines = array.new_line()
var label[] vLabels= array.new_label()

// outputs persisted for dashboard
var float oPOC = na
var float oVAH = na
var float oVAL = na
var string oShape = "—"
var string oLoc = "—"
var string oCtx = "building…"
var string oNode = "—"
var string oMigr = "building…"
var string oShapeN = "—"
var string oR1 = "—"
var string oR2 = "—"
var string oS1 = "—"
var string oS2 = "—"
var string oMag = "—"
var string oStretch = "—"
var string oRR = "—"
var int oImb = 0
var int oGap = 0
var float oBars = na
var float oBuyPct = na
var string oScope = "—"
var float compPOC = na
var float compVAH = na
var float compVAL = na
var string oHead = "—"
var int oHeadDir = 0

// Per-tick redraw throttle: rebuild on bar open / close only. On a live
// chart barstate.islast is true every tick, so without this the full histogram
// teardown + value-area expansion + Auto-Read re-ran many times per second.
var bool profDrawnOnce = false
bool rebuildHeavy = barstate.islast and (barstate.isconfirmed or not profDrawnOnce)
// In Composite mode the draw needs a populated map; other scopes draw from bar
// history, so they only need to be on the last bar.
bool canDraw = scopeMode == "Composite (all history)" ? map.size(vMap) > 0 : bar_index > 0

if rebuildHeavy and canDraw
    profDrawnOnce := true
    for bx in vBoxes
        box.delete(bx)
    for bx in sBoxes
        box.delete(bx)
    for ln in vLines
        line.delete(ln)
    for lb in vLabels
        label.delete(lb)
    array.clear(vBoxes)
    array.clear(sBoxes)
    array.clear(vLines)
    array.clear(vLabels)

    bool useMap = scopeMode == "Composite (all history)"
    bool isFixed = scopeMode == "Fixed range"
    volA = array.new_float(rows, 0.0)
    buyA = array.new_float(rows, 0.0)
    float pLo = na
    float pHi = na
    float binSz = step
    int   dispBars = 0
    float dispVol = 0.0
    float dispBuy = 0.0
    string dispName = "composite"
    if useMap
        keys = map.keys(vMap)
        int kMin = array.get(keys, 0)
        int kMax = array.get(keys, 0)
        for i = 0 to array.size(keys) - 1
            kk = array.get(keys, i)
            kMin := math.min(kMin, kk)
            kMax := math.max(kMax, kk)
        pLo := kMin * step
        pHi := (kMax + 1) * step
        binSz := (pHi - pLo) / rows
        binSz := binSz <= 0 ? step : binSz
        for i = 0 to array.size(keys) - 1
            kk = array.get(keys, i)
            px = (kk + 0.5) * step
            di = int(f_clamp(math.floor((px - pLo) / binSz), 0, rows - 1))
            array.set(volA, di, array.get(volA, di) + map.get(vMap, kk))
            if map.contains(bMap, kk)
                array.set(buyA, di, array.get(buyA, di) + map.get(bMap, kk))
        dispBars := scopeBars
        dispVol := scopeVol
        dispBuy := scopeBuy
    else
        int lb = 0
        if scopeMode == "Rolling (recent sessions)"
            ns = array.size(sessBar)
            startB = ns >= rollN ? array.get(sessBar, ns - rollN) : (ns > 0 ? array.get(sessBar, 0) : 0)
            lb := bar_index - startB
            dispName := "rolling " + str.tostring(rollN) + "d"
        else if scopeMode == "From date"
            for i = 0 to MAXLB
                if i <= bar_index and time[i] >= anchTime
                    lb := i
                else
                    break
            dispName := "from date"
        else
            for i = 0 to MAXLB
                if i <= bar_index and time[i] >= anchTime
                    lb := i
                else
                    break
            dispName := "fixed range"
        lb := math.max(1, math.min(lb, MAXLB))
        float rHi = high
        float rLo = low
        for i = 0 to lb
            okR = (not isFixed) or time[i] <= endTime
            if okR
                rHi := math.max(rHi, high[i])
                rLo := math.min(rLo, low[i])
        pLo := rLo
        pHi := rHi
        binSz := (pHi - pLo) / rows
        binSz := binSz <= 0 ? step : binSz
        for i = 0 to lb
            okR = (not isFixed) or time[i] <= endTime
            vv = nz(volSrc[i])
            if okR and vv > 0 and high[i] >= low[i]
                bfi = useBVC ? nz(buyFrac[i], 0.5) : (close[i] >= open[i] ? 1.0 : 0.0)
                rg = high[i] - low[i]
                sbn = rg <= 0 ? 1 : int(math.min(subMax, int(rg / binSz) + 1))
                vp = vv / sbn
                for sj = 0 to sbn - 1
                    pxi = sbn == 1 ? (high[i] + low[i]) / 2.0 : low[i] + rg * sj / (sbn - 1)
                    di = int(f_clamp(math.floor((pxi - pLo) / binSz), 0, rows - 1))
                    array.set(volA, di, array.get(volA, di) + vp)
                    array.set(buyA, di, array.get(buyA, di) + vp * bfi)
                dispVol += vv
                dispBuy += vv * bfi
                dispBars += 1

    // B3: optional Gaussian (KDE) smoothing of the profile before node detection.
    // Smooth volA and buyA with the same kernel so the buy share stays <= total.
    if useKDE and kdeBw > 0 and rows > 2
        int kwin = math.min(int(math.ceil(kdeBw * 3.0)), rows - 1)
        // precompute the kernel once (depends only on offset) so the inner loop
        // does no exp() per bin — this is what keeps it under Pine's 500 ms limit
        kern = array.new_float(2 * kwin + 1, 0.0)
        for k = -kwin to kwin
            array.set(kern, k + kwin, math.exp(-(k * k) / (2.0 * kdeBw * kdeBw)))
        sVolA = array.new_float(rows, 0.0)
        sBuyA = array.new_float(rows, 0.0)
        for i = 0 to rows - 1
            float acc  = 0.0
            float accB = 0.0
            float wsum = 0.0
            int j0 = math.max(0, i - kwin)
            int j1 = math.min(rows - 1, i + kwin)
            for j = j0 to j1
                float wj = array.get(kern, j - i + kwin)
                acc  += array.get(volA, j) * wj
                accB += array.get(buyA, j) * wj
                wsum += wj
            array.set(sVolA, i, wsum > 0 ? acc  / wsum : array.get(volA, i))
            array.set(sBuyA, i, wsum > 0 ? accB / wsum : array.get(buyA, i))
        for i = 0 to rows - 1
            array.set(volA, i, array.get(sVolA, i))
            array.set(buyA, i, array.get(sBuyA, i))

    // POC + totals (+ collect non-empty bin volumes for robust thresholds)
    float maxV = 0.0
    int   pocI = 0
    float tot  = 0.0
    nzVol = array.new_float(0)
    for i = 0 to rows - 1
        v = array.get(volA, i)
        tot += v
        if v > 0
            array.push(nzVol, v)
        if v > maxV
            maxV := v
            pocI := i
    avgV = rows > 0 ? tot / rows : 0.0
    // Robust node thresholds: percentile of bin volumes (self-scales to the
    // profile's shape), falling back to × average on tiny profiles or when off.
    bool robustOK = useRobustNodes and array.size(nzVol) >= 5
    float hvnThr = robustOK ? array.percentile_linear_interpolation(nzVol, hvnPctEff) : avgV*hvnK
    float lvnThr = robustOK ? array.percentile_linear_interpolation(nzVol, lvnPctEff) : avgV*lvnK
    hvnLvls = array.new_float(0)

    // value area expansion from POC
    float acc = array.get(volA, pocI)
    int vaU = pocI
    int vaD = pocI
    target = tot * vaPct / 100.0
    for n = 0 to rows
        if acc >= target
            break
        upV = vaU < rows - 1 ? array.get(volA, vaU + 1) : -1.0
        dnV = vaD > 0 ? array.get(volA, vaD - 1) : -1.0
        if upV < 0 and dnV < 0
            break
        if upV >= dnV
            vaU += 1
            acc += math.max(0.0, upV)
        else
            vaD -= 1
            acc += math.max(0.0, dnV)

    pocPx = pLo + (pocI + 0.5) * binSz
    vahPx = pLo + (vaU + 1) * binSz
    valPx = pLo + vaD * binSz
    if eComp and not useMap and map.size(vMap) > 0
        [cpP, cpH, cpL] = f_mapVA(vMap, step, vaPct)
        compPOC := cpP
        compVAH := cpH
        compVAL := cpL

    // geometry
    bool rop = rightOfPrice
    int rX  = rop ? bar_index + profGap : (sideRight ? bar_index + profGap : bar_index - profGap)
    int dir = rop ? 1 : (sideRight ? -1 : 1)
    int xEnd = rop ? rX + profW : rX
    int xLab = rop ? rX + profW + 2 : rX
    labStyle = rop ? label.style_label_right : label.style_label_left
    int xLab2 = xLab
    int lineL = bar_index - math.min(math.max(dispBars, 30), 4500)
    buyCol = color.new(hBull, profTr)
    selCol = color.new(hBear, profTr)
    if showVA and vaShade
        vaBx = box.new(lineL, vahPx, xEnd + 4, valPx, border_width=0, bgcolor=cVaFill)
        array.push(vBoxes, vaBx)
    int imbCnt = 0
    int gapCnt = 0

    // profile bars
    for i = 0 to rows - 1
        v = array.get(volA, i)
        topP = pLo + (i + 1) * binSz
        botP = pLo + i * binSz
        if v > 0 and maxV > 0
            rbv = array.get(buyA, i)
            rsv = math.max(0.0, v - rbv)
            int totLen = int(math.round(profW * v / maxV))
            // node classification (collected for Auto-Read in both styles)
            bool isHVNc = false
            bool isLVNc = false
            if i>0 and i<rows-1
                vL = array.get(volA,i-1)
                vR = array.get(volA,i+1)
                isHVNc := v > vL and v > vR and v > hvnThr
                isLVNc := v < vL and v < vR and v < lvnThr
                if isHVNc
                    array.push(hvnLvls, (topP+botP)/2)
            bool buyImb = eImb and rbv > 0 and rsv > 0 and rbv / rsv > imbRatio
            bool selImb = eImb and rbv > 0 and rsv > 0 and rsv / rbv > imbRatio
            if buyImb or selImb
                imbCnt += 1
            if pZ
                // Blue/Orange style: bars flush at the far edge growing toward price; colour
                // encodes HVN (teal/maroon) / LVN (grey) / imbalance (lime/red).
                float strength = v / maxV
                int trz = 80 - int(strength * 55)
                color bcol = color.new(hBull, trz)
                color scol = color.new(hBear, trz)
                if isLVNc
                    bcol := color.new(hLvn, 78)
                    scol := color.new(hLvn, 78)
                if isHVNc
                    bcol := color.new(#00897b, 30)
                    scol := color.new(#8e2440, 30)
                if buyImb
                    bcol := color.new(hImbB, 10)
                if selImb
                    scol := color.new(hImbS, 10)
                color bordz = i==pocI ? color.new(hPoc, 0) : color.new(chart.fg_color, 90)
                int bLenz = showSplit ? int(math.round(profW * rbv / maxV)) : totLen
                int xlz = xEnd - dir * totLen
                int xmz = xlz + dir * bLenz
                bb = box.new(math.min(xlz,xmz), topP, math.max(xlz,xmz), botP, border_color=bordz, bgcolor=(showSplit ? bcol : (rbv>=v/2?bcol:scol)))
                array.push(vBoxes, bb)
                if showSplit and (totLen - bLenz) > 0
                    sb = box.new(math.min(xmz,xEnd), topP, math.max(xmz,xEnd), botP, border_color=bordz, bgcolor=scol)
                    array.push(sBoxes, sb)
            else
                // right-anchored layout (flush at the far edge, grows toward price)
                int xlA = xEnd - dir * totLen
                if showSplit
                    int bLen = int(math.round(profW * rbv / maxV))
                    int xmA = xlA + dir * bLen
                    bb = box.new(math.min(xlA,xmA), topP, math.max(xlA,xmA), botP, border_width=0, bgcolor=(i==pocI?color.new(hBull,10):buyCol))
                    array.push(vBoxes, bb)
                    sb = box.new(math.min(xmA,xEnd), topP, math.max(xmA,xEnd), botP, border_width=0, bgcolor=(i==pocI?color.new(hBear,10):selCol))
                    array.push(sBoxes, sb)
                else
                    col = i==pocI ? cPoc : (rbv >= v/2 ? buyCol : selCol)
                    bb = box.new(math.min(xlA,xEnd), topP, math.max(xlA,xEnd), botP, border_width=0, bgcolor=col)
                    array.push(vBoxes, bb)
                if eImb and buyImb and imbCnt <= 80
                    array.push(vLines, line.new(xEnd, (topP+botP)/2, xEnd - dir*int(profW*0.10), (topP+botP)/2, color=cImbB, width=2))
                else if eImb and selImb and imbCnt <= 80
                    array.push(vLines, line.new(xEnd, (topP+botP)/2, xEnd - dir*int(profW*0.10), (topP+botP)/2, color=cImbS, width=2))
                if showNodes and isHVNc
                    array.push(vLines, line.new(xEnd, (topP+botP)/2, xEnd - dir*int(profW*0.12), (topP+botP)/2, color=cHvn, width=2))
                if showNodes and isLVNc
                    array.push(vLines, line.new(xEnd, (topP+botP)/2, xEnd - dir*int(profW*0.12), (topP+botP)/2, color=cLvn, width=2, style=line.style_dotted))
        else if eGaps and maxV > 0
            gapCnt += 1
            if gapCnt <= 60
                gb = box.new(lineL, topP, xEnd + 4, botP, border_width=0, bgcolor=cGap)
                array.push(vBoxes, gb)

    oImb := imbCnt
    oGap := gapCnt
    // POC + VA lines (extend left across the scope) — glow + bold chip in both palettes
    if showVA
        f_glowLine(vLines, lineL, xEnd + 40, pocPx, cPoc, lnWidth, line.style_solid)
        f_glowLine(vLines, lineL, xEnd + 4, vahPx, cVa, lnWidth, line.style_solid)
        f_glowLine(vLines, lineL, xEnd + 4, valPx, cVa, lnWidth, line.style_solid)
        f_glowLab(vLabels, xLab, pocPx, "POC " + str.tostring(pocPx, format.mintick), labStyle, cPoc)
        f_glowLab(vLabels, xLab, vahPx, "VAH " + str.tostring(vahPx, format.mintick), labStyle, cVa)
        f_glowLab(vLabels, xLab, valPx, "VAL " + str.tostring(valPx, format.mintick), labStyle, cVa)

    // naked daily POCs — thicker + glow
    if eNaked and array.size(nakPx) > 0
        for i = 0 to array.size(nakPx) - 1
            if array.get(nakLive, i)
                yv = array.get(nakPx, i)
                f_glowLine(vLines, lineL, xEnd + 4, yv, cNak, lnWidth, line.style_dashed)

    // prior-session reference levels — thicker + glow
    if ePDay and not na(pdPOC)
        f_glowLine(vLines, lineL, xEnd+4, pdPOC, cPDay, lnWidth, line.style_dashed)
        f_glowLab(vLabels, xLab2, pdPOC, "PD POC " + str.tostring(pdPOC, format.mintick), labStyle, cPDay)
        f_glowLine(vLines, lineL, xEnd+4, pdVAH, cPDay, lnWidth, line.style_dotted)
        f_glowLine(vLines, lineL, xEnd+4, pdVAL, cPDay, lnWidth, line.style_dotted)
    if ePWk and not na(pwPOC)
        f_glowLine(vLines, lineL, xEnd+4, pwPOC, cPWk, lnWidth, line.style_dashed)
        f_glowLab(vLabels, xLab2, pwPOC, "PW POC " + str.tostring(pwPOC, format.mintick), labStyle, cPWk)
        f_glowLine(vLines, lineL, xEnd+4, pwVAH, cPWk, lnWidth, line.style_dotted)
        f_glowLine(vLines, lineL, xEnd+4, pwVAL, cPWk, lnWidth, line.style_dotted)
    // composite key-levels overlay (full-history reference while in a recent scope) — thicker + glow
    if eComp and not useMap and not na(compPOC)
        f_glowLine(vLines, lineL, xEnd+4, compPOC, cComp, lnWidth, line.style_dashed)
        f_glowLab(vLabels, xLab2, compPOC, "COMP POC " + str.tostring(compPOC, format.mintick), labStyle, color.new(#ffa600, 12))
        f_glowLine(vLines, lineL, xEnd+4, compVAH, cCompVa, lnWidth, line.style_dotted)
        f_glowLine(vLines, lineL, xEnd+4, compVAL, cCompVa, lnWidth, line.style_dotted)
    // HTF POC proxy line — thicker + glow
    if eHTF and not na(htfPOC1)
        f_glowLine(vLines, lineL, xEnd+4, htfPOC1, color.new(#7e57c2, 0), lnWidth, line.style_dashed)
        f_glowLab(vLabels, xLab2, htfPOC1, "HTF POC " + str.tostring(htfPOC1, format.mintick), labStyle, color.new(#7e57c2, 0))
    // polarity-flipped levels (broken VA edge now acting with reversed role) — thicker + glow
    if usePolarityFlip and not na(flipSupPx)
        f_glowLine(vLines, lineL, xEnd+4, flipSupPx, cS1L, lnWidth, line.style_dotted)
        f_glowLab(vLabels, xLab2, flipSupPx, "S-FLIP " + str.tostring(flipSupPx, format.mintick), labStyle, cS1L)
    if usePolarityFlip and not na(flipResPx)
        f_glowLine(vLines, lineL, xEnd+4, flipResPx, cR1L, lnWidth, line.style_dotted)
        f_glowLab(vLabels, xLab2, flipResPx, "R-FLIP " + str.tostring(flipResPx, format.mintick), labStyle, cR1L)
    // Initial Balance — thicker + glow
    if eIB and not na(ibHi)
        f_glowLine(vLines, lineL, xEnd+4, ibHi, cIB, lnWidth, line.style_solid)
        f_glowLine(vLines, lineL, xEnd+4, ibLo, cIB, lnWidth, line.style_solid)
        f_glowLab(vLabels, xLab2, ibHi, "IB H " + str.tostring(ibHi, format.mintick), labStyle, cIB)
        f_glowLab(vLabels, xLab2, ibLo, "IB L " + str.tostring(ibLo, format.mintick), labStyle, cIB)
    // expected-move band — thicker + glow
    if eEM and not na(emUp)
        f_glowLine(vLines, lineL, xEnd+4, emUp, cEM, lnWidth, line.style_dashed)
        f_glowLine(vLines, lineL, xEnd+4, emDn, cEM, lnWidth, line.style_dashed)
        f_glowLab(vLabels, xLab2, emUp, "EM+ " + str.tostring(emUp, format.mintick), labStyle, cEM)
        f_glowLab(vLabels, xLab2, emDn, "EM− " + str.tostring(emDn, format.mintick), labStyle, cEM)
    // poor highs / lows (no excess at the extreme)
    if ePoor
        int hiRow = -1
        int loRow = -1
        for i = rows - 1 to 0
            if hiRow < 0 and array.get(volA, i) > 0
                hiRow := i
        for i = 0 to rows - 1
            if loRow < 0 and array.get(volA, i) > 0
                loRow := i
        if hiRow >= 0 and array.get(volA, hiRow) > avgV * poorK
            yph = pLo + (hiRow + 0.5) * binSz
            f_glowLine(vLines, lineL, xEnd+4, yph, cPoor, lnWidth, line.style_dotted)
            f_glowLab(vLabels, xLab2, yph, "POOR H " + str.tostring(yph, format.mintick), labStyle, cPoor)
        if loRow >= 0 and array.get(volA, loRow) > avgV * poorK
            ypl = pLo + (loRow + 0.5) * binSz
            f_glowLine(vLines, lineL, xEnd+4, ypl, cPoor, lnWidth, line.style_dotted)
            f_glowLab(vLabels, xLab2, ypl, "POOR L " + str.tostring(ypl, format.mintick), labStyle, cPoor)
    // delta summary panel
    if eDelta
        int secRows = math.max(1, int(rows / deltaSecN))
        int pLp = xEnd + 8
        int pRp = pLp + deltaPanelW
        for sIdx = 0 to deltaSecN - 1
            sStart = sIdx * secRows
            sEnd = sIdx == deltaSecN - 1 ? rows - 1 : math.min(rows - 1, (sIdx + 1) * secRows - 1)
            if sStart <= sEnd
                float ssv = 0.0
                float ssb = 0.0
                for j = sStart to sEnd
                    ssv += array.get(volA, j)
                    ssb += array.get(buyA, j)
                if ssv > 0
                    dl = (ssb - (ssv - ssb)) / ssv * 100.0
                    segT = pLo + (sEnd + 1) * binSz
                    segB = pLo + sStart * binSz
                    if pZ
                        array.push(vBoxes, box.new(pLp, segT, pRp, segB, border_color=color.new(chart.fg_color,70), bgcolor=color.new(#808080,90)))
                        float dfrac = math.max(0.12, math.min(1.0, math.abs(dl)/100.0))
                        int dLen = int((pRp - pLp) * dfrac)
                        color dcz = dl >= 0 ? color.new(hImbB, 15) : color.new(hImbS, 15)
                        db = box.new(pLp, segT, pLp + dLen, segB, border_color=color.new(chart.fg_color,20), bgcolor=dcz)
                        box.set_text(db, "Δ " + str.tostring(dl,"#.0") + "%")
                        box.set_text_color(db, color.white)
                        box.set_text_halign(db, text.align_center)
                        box.set_text_valign(db, text.align_center)
                        box.set_text_size(db, size.small)
                        array.push(vBoxes, db)
                    else
                        dcol = dl >= 0 ? color.new(hImbB, 25) : color.new(hImbS, 25)
                        array.push(vBoxes, box.new(pLp, segT, pRp, segB, border_color=color.new(#888888,60), bgcolor=dcol))
                        array.push(vLabels, label.new(int((pLp+pRp)/2), (segT+segB)/2.0, str.tostring(dl,"0")+"%", style=label.style_none, textcolor=color.white, size=size.small))
    // persist outputs + shape/location
    oPOC := pocPx
    oVAH := vahPx
    oVAL := valPx
    // --- B4: real distribution moments of the binned profile (volume-weighted) ---
    float shW  = 0.0
    float shWX = 0.0
    for mi = 0 to rows - 1
        float wv = array.get(volA, mi)
        shW  += wv
        shWX += wv * mi
    float shMean = shW > 0 ? shWX / shW : (rows - 1) / 2.0
    float shM2 = 0.0
    float shM3 = 0.0
    float shM4 = 0.0
    for mi = 0 to rows - 1
        float wv = array.get(volA, mi)
        float dv = mi - shMean
        shM2 += wv * dv * dv
        shM3 += wv * dv * dv * dv
        shM4 += wv * dv * dv * dv * dv
    float shVar = shW > 0 ? shM2 / shW : 0.0
    float shSd  = math.sqrt(math.max(shVar, 0.0))
    float oSkew = (shW > 0 and shSd > 0) ? (shM3 / shW) / (shSd * shSd * shSd) : 0.0
    float oKurt = (shW > 0 and shVar > 0) ? (shM4 / shW) / (shVar * shVar) - 3.0 : 0.0
    // bimodality coefficient (excess-kurtosis form); > ~0.555 hints at a double distribution
    float oBC = (oKurt + 3.0) != 0 ? (oSkew * oSkew + 1.0) / (oKurt + 3.0) : na
    // +skew = mass low / tail up = low POC, thin above;  -skew = high POC, thin below
    oShape := oSkew > 0.35 ? "b (low POC)" : oSkew < -0.35 ? "P (high POC)" : "D (balanced)"
    oLoc := close > vahPx ? "premium (above VA)" : close < valPx ? "discount (below VA)" : "inside value"
    oBars := dispBars
    oBuyPct := dispVol > 0 ? dispBuy / dispVol * 100.0 : na
    oScope := dispName

    // ---------- AUTO-READ ----------
    lvPx = array.new_float(0)
    lvTy = array.new_string(0)
    array.push(lvPx, pocPx)
    array.push(lvTy, "POC")
    array.push(lvPx, vahPx)
    array.push(lvTy, "VAH")
    array.push(lvPx, valPx)
    array.push(lvTy, "VAL")
    for i = 0 to array.size(hvnLvls) - 1
        array.push(lvPx, array.get(hvnLvls, i))
        array.push(lvTy, "HVN")
    for i = 0 to array.size(nakPx) - 1
        if array.get(nakLive, i)
            array.push(lvPx, array.get(nakPx, i))
            array.push(lvTy, "nPOC")
    // HTF POC participates in the S/R read
    if eHTF and not na(htfPOC1)
        array.push(lvPx, htfPOC1)
        array.push(lvTy, "HTFpoc")
    // flipped levels participate in the S/R read
    if usePolarityFlip and not na(flipSupPx)
        array.push(lvPx, flipSupPx)
        array.push(lvTy, "S-flip")
    if usePolarityFlip and not na(flipResPx)
        array.push(lvPx, flipResPx)
        array.push(lvTy, "R-flip")
    r1 = f_nearAbove(lvPx, close, -1)
    r2 = f_nearAbove(lvPx, close, r1)
    s1 = f_nearBelow(lvPx, close, -1)
    s2 = f_nearBelow(lvPx, close, s1)
    oR1 := r1>=0 ? f_lvl(array.get(lvPx,r1), array.get(lvTy,r1), close) : "—"
    oR2 := r2>=0 ? f_lvl(array.get(lvPx,r2), array.get(lvTy,r2), close) : "—"
    oS1 := s1>=0 ? f_lvl(array.get(lvPx,s1), array.get(lvTy,s1), close) : "—"
    oS2 := s2>=0 ? f_lvl(array.get(lvPx,s2), array.get(lvTy,s2), close) : "—"
    ci = int(f_clamp(math.floor((close - pLo)/binSz), 0, rows-1))
    cv = array.get(volA, ci)
    cvL = ci>0 ? array.get(volA, ci-1) : cv
    cvR = ci<rows-1 ? array.get(volA, ci+1) : cv
    atHVN = cv > hvnThr and cv>=cvL and cv>=cvR
    inLVN = cv < lvnThr
    oCtx := rgRegime=="off" ? (oLoc=="inside value" ? "rotate to POC" : oLoc=="premium (above VA)" ? "above value" : "below value") : rgTrending ? (rgBull ? "trend up · ride" : "trend dn · ride") : rgVolClust ? "volatile · wait" : (oLoc=="inside value" ? "range · rotate" : oLoc=="premium (above VA)" ? "range · fade hi" : "range · fade lo")
    oNode := atHVN ? "HVN · stall" : inLVN ? "LVN · fast" : "mid-node"
    nN = array.size(nakPx)
    oMigr := "building…"
    oHeadDir := 0
    if nN >= 4
        int hh = math.max(1, math.min(3, int(nN/2)))
        float rec = 0.0
        float old = 0.0
        for i = 0 to hh-1
            rec += array.get(nakPx, nN-1-i)
            old += array.get(nakPx, i)
        rec := rec/hh
        old := old/hh
        diff = rec - old
        thr = pocPx*0.002
        oHeadDir := diff > thr ? 1 : diff < -thr ? -1 : 0
        oMigr := oHeadDir>0 ? "rising · up" : oHeadDir<0 ? "falling · down" : "flat · range"
    string shBase = oShape=="P (high POC)" ? "P · thin below" : oShape=="b (low POC)" ? "b · thin above" : "D · balanced"
    bool shBimodal = not na(oBC) and oBC > 0.555 and shW > 0
    oShapeN := shBase + (shBimodal ? " · bimodal" : "") + " (sk " + str.tostring(oSkew,"0.0") + ")"
    // stretch from POC in % AND ATR units (so "stretched" is comparable across symbols)
    stretch = pocPx!=0 ? (close - pocPx)/pocPx*100.0 : 0.0
    float stretchA = (not na(calATR) and calATR>0) ? (close - pocPx)/calATR : na
    oStretch := (stretch>=0?"+":"") + str.tostring(stretch,"0.0") + "%" + (na(stretchA)?"":" ("+(stretchA>=0?"+":"")+str.tostring(stretchA,"0.0")+" ATR)")
    // reversion R:R (reference geometry only): near VA edge → POC, stop a fixed ATR beyond the edge
    float rrStop = rrStopATR * ((not na(calATR) and calATR>0) ? calATR : pocPx*0.003)
    if showRR and rrStop > 0
        if close <= pocPx
            oRR := "VAL→POC " + str.tostring((pocPx - valPx)/rrStop, "0.0") + "R"
        else
            oRR := "VAH→POC " + str.tostring((vahPx - pocPx)/rrStop, "0.0") + "R"
    else
        oRR := "—"
    int mIdx = -1
    float md = 1e20
    for i = 0 to array.size(nakPx) - 1
        if array.get(nakLive, i)
            dd = math.abs(array.get(nakPx, i) - close)
            if dd < md
                md := dd
                mIdx := i
    oMag := mIdx>=0 ? str.tostring(array.get(nakPx,mIdx), format.mintick) : "none live"
    locShort = oLoc=="premium (above VA)" ? "PREMIUM" : oLoc=="discount (below VA)" ? "DISCOUNT" : "IN VALUE"
    trShort = oHeadDir>0 ? "UPTREND" : oHeadDir<0 ? "DOWNTREND" : "BALANCE"
    sTxtH = s1>=0 ? str.tostring(array.get(lvPx,s1), format.mintick) : "–"
    rTxtH = r1>=0 ? str.tostring(array.get(lvPx,r1), format.mintick) : "–"
    oHead := locShort + "    ·    " + trShort + "    ·    SUP " + sTxtH + "    ·    RES " + rTxtH
    if showKeyLines
        int xl = lineL
        if r1>=0
            pr1 = array.get(lvPx,r1)
            f_glowLine(vLines, xl, xEnd+4, pr1, cR1L, lnWidth, line.style_solid)
            f_glowLab(vLabels, xLab, pr1, "R1 " + str.tostring(pr1, format.mintick), labStyle, cR1L)
        if r2>=0
            pr2 = array.get(lvPx,r2)
            f_glowLine(vLines, xl, xEnd+4, pr2, cR2L, lnWidth, line.style_solid)
        if s1>=0
            ps1 = array.get(lvPx,s1)
            f_glowLine(vLines, xl, xEnd+4, ps1, cS1L, lnWidth, line.style_solid)
            f_glowLab(vLabels, xLab, ps1, "S1 " + str.tostring(ps1, format.mintick), labStyle, cS1L)
        if s2>=0
            ps2 = array.get(lvPx,s2)
            f_glowLine(vLines, xl, xEnd+4, ps2, cS2L, lnWidth, line.style_solid)
        if mIdx>=0
            pm = array.get(nakPx, mIdx)
            f_glowLine(vLines, xl, xEnd+4, pm, cMagL, lnWidth, line.style_dashed)
            f_glowLab(vLabels, xLab, pm, "MAG " + str.tostring(pm, format.mintick), labStyle, cMagL)

// =============================================================================
// ALERTS
// =============================================================================
alertcondition(not na(oPOC) and ta.cross(close, oPOC), "Price crossed POC", "Auction VP: price crossed the Point of Control")
alertcondition(not na(oVAH) and ta.crossover(close, oVAH), "Entered premium (above VAH)", "Auction VP: price above value area")
alertcondition(not na(oVAL) and ta.crossunder(close, oVAL), "Entered discount (below VAL)", "Auction VP: price below value area")
alertcondition(eCVD and cvdBearDiv and not cvdBearDiv[1], "CVD bearish divergence", "Auction VP: price up, delta not confirming")
alertcondition(eCVD and cvdBullDiv and not cvdBullDiv[1], "CVD bullish divergence", "Auction VP: price down, delta not confirming")
plot(eDev ? devPOC : na, "Developing POC", color=cDev, linewidth=1, style=plot.style_stepline)
vwBull = not na(vwVal) and close >= vwVal
vwTrendCol = vwBull ? #089981 : #f23645
plot(eVWAP ? vwVal : na, "VWAP glow outer", color=color.new(vwTrendCol, showVwGlow ? 88 : 100), linewidth=8)
plot(eVWAP ? vwVal : na, "VWAP glow inner", color=color.new(vwTrendCol, showVwGlow ? 65 : 100), linewidth=4)
plot(eVWAP ? vwVal : na, "VWAP", color=eVWAP ? vwTrendCol : na, linewidth=2)
uBp = plot(eVWAP and showVwBands ? vwUp : na, "VWAP +band", color=color.new(vwTrendCol, 72))
lBp = plot(eVWAP and showVwBands ? vwDn : na, "VWAP -band", color=color.new(vwTrendCol, 72))
fill(uBp, lBp, color = eVWAP and showVwBands ? color.new(vwTrendCol, 92) : na)

// hidden exports for downstream request.security() consumers (Data Window only)
plot(enableExports ? oPOC : na, "EXP_POC", display=display.data_window)
plot(enableExports ? oVAH : na, "EXP_VAH", display=display.data_window)
plot(enableExports ? oVAL : na, "EXP_VAL", display=display.data_window)
plot(enableExports and not na(pdPOC) ? pdPOC : na, "EXP_PD_POC", display=display.data_window)
plot(enableExports ? compPOC : na, "EXP_COMP_POC", display=display.data_window)
plot(enableExports and not na(htfPOC1) ? htfPOC1 : na, "EXP_HTF_POC", display=display.data_window)
// suite bus: this script doubles as the Shared-Regime source + a value/flow feed
plot(enableExports ? regNow : na, "EXP_REGIME", display=display.data_window)
plot(enableExports and not na(devPOC) ? devPOC : na, "EXP_DEV_POC", display=display.data_window)
plot(enableExports and eVWAP and not na(vwVal) ? vwVal : na, "EXP_VWAP", display=display.data_window)
plot(enableExports and not na(vpin) ? vpin : na, "EXP_VPIN", display=display.data_window)

// =============================================================================
// SHARED UI THEME  (one adaptive, luma-based palette for every table)
//   Auto mode picks dark / light from the chart-background luminance, so the
//   dashboard, legend key and calibration panel stay readable on ANY theme.
// =============================================================================
bool  uiDark  = tblTheme=="Dark" ? true : tblTheme=="Light" ? false : f_lum(chart.bg_color) < 140
color uiPanel = uiDark ? color.rgb(17, 22, 28)    : color.rgb(244, 246, 248)
color uiRowA  = uiDark ? color.rgb(25, 31, 39)    : color.rgb(232, 236, 240)
color uiTxt   = uiDark ? color.white              : color.rgb(16, 20, 24)
color uiSub   = uiDark ? color.rgb(154, 166, 178) : color.rgb(74, 82, 91)
color uiMut   = uiDark ? color.rgb(110, 120, 132) : color.rgb(140, 148, 156)
color uiFrame = uiDark ? color.rgb(58, 70, 84)    : color.rgb(196, 204, 212)
color uiUp    = uiDark ? #21dfac : color.rgb(14, 124, 90)
color uiDn    = uiDark ? #df216d : color.rgb(198, 40, 40)

// =============================================================================
// DASHBOARD
// =============================================================================
var table dash = table.new(f_pos(tblPos), 2, 40, frame_width=1, border_width=1)
setrow(tbl, r, lbl, val, vc, lc, bg) =>
    rbg = r % 2 == 1 ? uiPanel : uiRowA
    table.cell(tbl, 0, r, lbl, text_color=lc, text_size=size.small, text_halign=text.align_left,  bgcolor=rbg)
    table.cell(tbl, 1, r, val, text_color=vc, text_size=size.small, text_halign=text.align_right, bgcolor=rbg)

if showTbl and barstate.islast
    tIsDark = uiDark
    tBg   = uiPanel
    tBord = uiFrame
    tLbl  = uiSub
    tVal  = uiTxt
    cB    = uiUp
    cS    = uiDn
    cM    = uiMut
    table.set_frame_color(dash, tBord)
    table.set_border_color(dash, tBord)
    locCol = oLoc=="premium (above VA)"?cB : oLoc=="discount (below VA)"?cS : cM
    buyPct = oBuyPct
    noVol = not (volCumAll > 0)
    migrCol = oHeadDir>0?cB : oHeadDir<0?cS : cM
    ctxCol  = str.contains(rgRegime,"up")?cB : str.contains(rgRegime,"down")?cS : cM
    nodeCol = str.contains(oNode,"LVN")?cB : cM
    hlDir = oHeadDir<0 ? "↓" : oHeadDir>0 ? "↑" : "→"
    hlLoc = oLoc=="inside value" ? "IN VALUE" : oLoc=="premium (above VA)" ? "PREMIUM" : "DISCOUNT"
    hlBg = noVol ? cS : migrCol
    // live naked count (excludes tested / aged-out)
    int nakLiveN = 0
    if array.size(nakLive) > 0
        for i = 0 to array.size(nakLive) - 1
            if array.get(nakLive, i)
                nakLiveN += 1
    table.cell(dash, 0, 0, noVol ? " NO VOLUME " : " " + hlDir + " " + hlLoc + " ", text_color=color.white, text_size=size.normal, text_halign=text.align_left, bgcolor=color.new(hlBg,0))
    table.cell(dash, 1, 0, noVol ? "USE FUTURES " : str.upper(oScope) + " ", text_color=color.white, text_size=size.normal, text_halign=text.align_right, bgcolor=color.new(hlBg,0))
    rr = 0
    full = not tblCompact
    // ── READ: what the auction is telling you to do ──
    if eRead
        rr += 1
        setrow(dash, rr, "CONTEXT", oCtx, ctxCol, tLbl, tBg)
    // ── S/R decision ladder (resistance above → price → support below) ──
    if eRead and full
        rr += 1
        setrow(dash, rr, "RES 2", oR2, cS, tLbl, tBg)
    if eRead
        rr += 1
        setrow(dash, rr, "RES 1", oR1, cS, tLbl, tBg)
    rr += 1
    setrow(dash, rr, "→ PRICE", str.tostring(close, format.mintick), tVal, tLbl, tBg)
    if eRead
        rr += 1
        setrow(dash, rr, "SUP 1", oS1, cB, tLbl, tBg)
    if eRead and full
        rr += 1
        setrow(dash, rr, "SUP 2", oS2, cB, tLbl, tBg)
    if eRead and full
        rr += 1
        setrow(dash, rr, "MAGNET", oMag, cM, tLbl, tBg)
    // ── value frame ──
    rr += 1
    setrow(dash, rr, "POC",  na(oPOC)?"…":str.tostring(oPOC, format.mintick), cVa, tLbl, tBg)
    if full
        rr += 1
        setrow(dash, rr, "VAH",  na(oVAH)?"…":str.tostring(oVAH, format.mintick), tVal, tLbl, tBg)
    if full
        rr += 1
        setrow(dash, rr, "VAL",  na(oVAL)?"…":str.tostring(oVAL, format.mintick), tVal, tLbl, tBg)
    rr += 1
    setrow(dash, rr, "PRICE", oLoc=="inside value"?"in value":oLoc=="premium (above VA)"?"premium":"discount", locCol, tLbl, tBg)
    // ── trade framing ──
    if eRead
        rr += 1
        setrow(dash, rr, "STRETCH", oStretch, cM, tLbl, tBg)
    if eRead and showRR
        rr += 1
        setrow(dash, rr, "REVERSION", oRR, cM, tLbl, tBg)
    if eRead and full
        rr += 1
        setrow(dash, rr, "AT PRICE", oNode, nodeCol, tLbl, tBg)
    // ── bias / flow ──
    if eRead
        rr += 1
        setrow(dash, rr, "TREND", oMigr, migrCol, tLbl, tBg)
    if eRead and full
        rr += 1
        setrow(dash, rr, "SHAPE", oShapeN, tVal, tLbl, tBg)
    if full
        rr += 1
        setrow(dash, rr, "BUY/SELL", na(buyPct)?"n/a":(str.tostring(math.round(buyPct))+"% / "+str.tostring(math.round(100-buyPct))+"%"), na(buyPct)?cM:(buyPct>=50?cB:cS), tLbl, tBg)
    if full and eCVD
        rr += 1
        setrow(dash, rr, "CVD", cvdState, str.contains(cvdState,"bear")?cS:str.contains(cvdState,"bull")?cB:cM, tLbl, tBg)
    if useVPIN
        rr += 1
        string vpTxt = na(vpin) ? "warming" : str.tostring(vpin, "0.00") + (vpin>=0.5?" · toxic":vpin>=0.3?" · elevated":" · calm")
        setrow(dash, rr, "VPIN", vpTxt, na(vpin)?cM:(vpin>=0.5?cS:vpin>=0.3?cM:cB), tLbl, tBg)
    if full and usePolarityFlip
        rr += 1
        string flipTxt = (not na(flipSupPx) ? "S " + str.tostring(flipSupPx, format.mintick) : "") + (not na(flipResPx) ? ((not na(flipSupPx))?" · ":"") + "R " + str.tostring(flipResPx, format.mintick) : "")
        flipTxt := flipTxt == "" ? "none" : flipTxt
        setrow(dash, rr, "FLIP", flipTxt, (not na(flipSupPx))?cB:(not na(flipResPx))?cS:cM, tLbl, tBg)
    // ── confluence ──
    if full and eVWAP
        rr += 1
        setrow(dash, rr, "VWAP", not na(vwVal) ? (close>vwVal?"above":"below") : "off", not na(vwVal)?(close>vwVal?cB:cS):cM, tLbl, tBg)
    if full and eHTF
        rr += 1
        string htfTxt = na(htfPOC1) ? "…" : str.tostring(htfPOC1, format.mintick) + " · " + (close>htfPOC1?"above":close<htfPOC1?"below":"at")
        setrow(dash, rr, "HTF POC", htfTxt, na(htfPOC1)?cM:(close>htfPOC1?cB:cS), tLbl, tBg)
    if full
        rr += 1
        setrow(dash, rr, "NAKED", eNaked?str.tostring(nakLiveN):"off", tVal, tLbl, tBg)
    if full
        rr += 1
        setrow(dash, rr, "IMB/GAP", (eImb?str.tostring(oImb):"–")+" / "+(eGaps?str.tostring(oGap):"–"), tVal, tLbl, tBg)
    // ── context / meta ──
    if full and showRegime
        rr += 1
        setrow(dash, rr, "REGIME", rgRegime=="off"?"off":(rgRegime+" "+str.tostring(rgPct)+"%"), str.contains(rgRegime,"up")?cB:str.contains(rgRegime,"down")?cS:cM, tLbl, tBg)
    if showHealth
        rr += 1
        setrow(dash, rr, "DATA", hHealth + (useBorrow and not na(volBorrowRaw) ? " · borrowed" : "") + " · " + hClass + (autoTune ? " · tuned" : ""), hHealth=="ok"?cB:hHealth=="no volume"?cS:cM, tLbl, tBg)
    if full
        rr += 1
        setrow(dash, rr, "BARS", na(oBars)?"…":str.tostring(int(oBars)), tVal, tLbl, tBg)


// =============================================================================
// LEGEND KEY  (what every line means · ORB-style)
// =============================================================================
// shared ORB-style theme palette (matches the suite's dashboard / key look)
// (legend key reuses the SHARED UI THEME palette defined above)
var table keyT = table.new(f_pos(keyPos), 2, 20, frame_width=1, border_width=1)
f_key(int r, string sym, color sc, string meaning) =>
    table.cell(keyT, 0, r, sym,     text_color=sc,      text_size=size.tiny, text_halign=text.align_center, bgcolor=uiPanel)
    table.cell(keyT, 1, r, meaning, text_color=uiSub, text_size=size.tiny, text_halign=text.align_left,   bgcolor=uiPanel)
if showKey and barstate.islast
    table.set_bgcolor(keyT, uiPanel)
    table.set_frame_color(keyT, uiFrame)
    table.set_border_color(keyT, uiFrame)
    table.cell(keyT, 0, 0, "KEY", text_color=uiTxt, text_size=size.tiny, text_halign=text.align_center, bgcolor=uiRowA)
    table.cell(keyT, 1, 0, "signal / line", text_color=uiSub, text_size=size.tiny, text_halign=text.align_left, bgcolor=uiRowA)
    int kr = 0
    kr += 1
    f_key(kr, "▬", color.new(cPoc, 0),  "Point of control  (POC)")
    kr += 1
    f_key(kr, "▬", color.new(cVa, 0),   "Value-area edges  (VAH / VAL)")
    if showNodes
        kr += 1
        f_key(kr, "▬", color.new(cHvn, 0), "High-volume node  (HVN)")
        kr += 1
        f_key(kr, "▬", color.new(cLvn, 0), "Low-volume node  (LVN)")
    if eNaked
        kr += 1
        f_key(kr, "▬", color.new(cNak, 0), "Untested (naked) POC")
    if ePDay
        kr += 1
        f_key(kr, "▬", color.new(cPDay, 0), "Prior day  (PD POC / VA)")
    if ePWk
        kr += 1
        f_key(kr, "▬", color.new(cPWk, 0), "Prior week  (PW POC / VA)")
    if eComp
        kr += 1
        f_key(kr, "▬", color.new(cComp, 0), "Composite  (COMP POC / VA)")
    if eHTF
        kr += 1
        f_key(kr, "▬", color.new(#7e57c2, 0), "Higher-timeframe POC  (HTF)")
    if eVWAP
        kr += 1
        f_key(kr, "▬", color.new(#089981, 0), "VWAP  (mean ± σ bands)")
    if eIB
        kr += 1
        f_key(kr, "▬", color.new(cIB, 0), "Initial balance  (IB)")
    if eEM
        kr += 1
        f_key(kr, "▬", color.new(cEM, 0), "Expected-move band  (EM)")
    if eRead and showKeyLines
        kr += 1
        f_key(kr, "▬", color.new(cR1L, 0), "Auto resistance  (R1 / R2)")
        kr += 1
        f_key(kr, "▬", color.new(cS1L, 0), "Auto support  (S1 / S2)")
        kr += 1
        f_key(kr, "▬", color.new(cMagL, 0), "Nearest magnet  (MAG)")
    if usePolarityFlip
        kr += 1
        f_key(kr, "▬", color.new(cS1L, 0), "Polarity flip  (role reversed)")


// =============================================================================
// CALIBRATION PANEL  (optional · past-only)
// =============================================================================
var table calT = table.new(f_pos(calPos), 6, 10, frame_width=1, border_width=1)
if calEnable and calShowPanel and barstate.islast
    cdDark = uiDark
    cdBg = cdDark ? color.new(#0a0e16,0) : color.new(#ffffff,0)
    cdHd = cdDark ? color.new(#161b22,0) : color.new(#dee6f1,0)
    cdTx = cdDark ? #c2cbd6 : #141a26
    cdDm = cdDark ? #8b949e : #5c6470
    cdOk = cdDark ? #21dfac : #0e9e76
    cdBd = cdDark ? #df216d : #d32f2f
    cdWn = cdDark ? #e3b341 : #b07800
    table.set_bgcolor(calT, cdBg)
    table.set_frame_color(calT, cdDm)
    table.set_border_color(calT, cdHd)
    // unconditional base rates (direction-split)
    float buR = baseN > 0 ? baseUp / float(baseN) : na
    float bdR = baseN > 0 ? baseDn / float(baseN) : na
    table.cell(calT,0,0,"Calibration (past · Edge)", text_color=cdTx, bgcolor=cdHd, text_size=size.tiny, text_halign=text.align_left, tooltip="Descriptive, past-only. Each event is resolved by FIRST TOUCH over " + str.tostring(calHorizon) + " bars: a HIT = price reaches +" + str.tostring(calFavATR) + "×ATR in the expected direction BEFORE the opposite barrier. BASE = the unconditional rate of that same move (direction-weighted). EDGE = Hit − Base; only a positive Edge beats chance. NOT a backtest or forward prediction.")
    table.cell(calT,1,0,"N",     text_color=cdTx, bgcolor=cdHd, text_size=size.tiny, text_halign=text.align_center)
    table.cell(calT,2,0,"Hit",   text_color=cdTx, bgcolor=cdHd, text_size=size.tiny, text_halign=text.align_center)
    table.cell(calT,3,0,"Base",  text_color=cdTx, bgcolor=cdHd, text_size=size.tiny, text_halign=text.align_center)
    table.cell(calT,4,0,"Edge",  text_color=cdTx, bgcolor=cdHd, text_size=size.tiny, text_halign=text.align_center)
    table.cell(calT,5,0,"95% CI",text_color=cdTx, bgcolor=cdHd, text_size=size.tiny, text_halign=text.align_right)
    rl = array.from("VA reversion","POC reversion","VA continuation","All")
    for r = 0 to 3
        int tt = 0
        int hh = 0
        int un = 0
        int dn = 0
        if r < 3
            tt := array.get(calTot, r)
            hh := array.get(calHit, r)
            un := array.get(calUpN, r)
            dn := array.get(calDnN, r)
        else
            tt := array.get(calTot,0)+array.get(calTot,1)+array.get(calTot,2)
            hh := array.get(calHit,0)+array.get(calHit,1)+array.get(calHit,2)
            un := array.get(calUpN,0)+array.get(calUpN,1)+array.get(calUpN,2)
            dn := array.get(calDnN,0)+array.get(calDnN,1)+array.get(calDnN,2)
        float hr = tt>0 ? hh*100.0/tt : na
        float wb = (un+dn)>0 and not na(buR) ? (un*buR + dn*bdR)/(un+dn)*100.0 : na
        float edge = (not na(hr) and not na(wb)) ? hr - wb : na
        [lo, hi] = f_propCI(hh, tt)
        string hTxt  = tt==0 ? "—" : tt<5 ? "warm" : str.tostring(hr,"0")+"%"
        string bTxt  = na(wb) ? "—" : str.tostring(wb,"0")+"%"
        string eTxt  = na(edge) ? "—" : (edge>=0?"+":"")+str.tostring(edge,"0")
        string ciTxt = na(lo) ? "—" : str.tostring(math.round(lo*100))+"–"+str.tostring(math.round(hi*100))
        color eCol = na(edge) ? cdDm : edge>0 ? cdOk : edge<0 ? cdBd : cdWn
        color hCol = tt<5 ? cdDm : cdTx
        table.cell(calT,0,r+1, array.get(rl,r), text_color=cdTx, bgcolor=cdBg, text_size=size.tiny, text_halign=text.align_left)
        table.cell(calT,1,r+1, str.tostring(tt), text_color=cdTx, bgcolor=cdBg, text_size=size.tiny, text_halign=text.align_center)
        table.cell(calT,2,r+1, hTxt,  text_color=hCol, bgcolor=cdBg, text_size=size.tiny, text_halign=text.align_center)
        table.cell(calT,3,r+1, bTxt,  text_color=cdDm, bgcolor=cdBg, text_size=size.tiny, text_halign=text.align_center)
        table.cell(calT,4,r+1, eTxt,  text_color=eCol, bgcolor=cdBg, text_size=size.tiny, text_halign=text.align_center)
        table.cell(calT,5,r+1, ciTxt, text_color=cdTx, bgcolor=cdBg, text_size=size.tiny, text_halign=text.align_right)
    // regime footer header
    table.cell(calT,0,5,"by regime", text_color=cdTx, bgcolor=cdHd, text_size=size.tiny, text_halign=text.align_left, tooltip="Regime-conditioned EDGE. Rev = reversion hypotheses (VA + POC); Con = continuation. Reversion tends to earn its edge in range, continuation in trend. Base here is regime-conditioned. The trend row merges trend-up and trend-down.")
    table.cell(calT,1,5,"",     bgcolor=cdHd)
    table.cell(calT,2,5,"RevN", text_color=cdTx, bgcolor=cdHd, text_size=size.tiny, text_halign=text.align_center)
    table.cell(calT,3,5,"RevE", text_color=cdTx, bgcolor=cdHd, text_size=size.tiny, text_halign=text.align_center)
    table.cell(calT,4,5,"ConN", text_color=cdTx, bgcolor=cdHd, text_size=size.tiny, text_halign=text.align_center)
    table.cell(calT,5,5,"ConE", text_color=cdTx, bgcolor=cdHd, text_size=size.tiny, text_halign=text.align_right)
    rgLab = array.from("range","trend","volatile")
    for rr = 0 to 2
        int rTot = 0
        int rHit = 0
        int rUp  = 0
        int rDn  = 0
        int cTot = 0
        int cHit = 0
        int cUp  = 0
        int cDn  = 0
        int bN   = 0
        int bU   = 0
        int bD   = 0
        if rr == 0
            rTot := array.get(hypTot,0)
            rHit := array.get(hypHit,0)
            rUp  := array.get(hypUpN,0)
            rDn  := array.get(hypDnN,0)
            cTot := array.get(hypTot,NREG)
            cHit := array.get(hypHit,NREG)
            cUp  := array.get(hypUpN,NREG)
            cDn  := array.get(hypDnN,NREG)
            bN := array.get(baseRegN,0)
            bU := array.get(baseRegUp,0)
            bD := array.get(baseRegDn,0)
        else if rr == 1
            rTot := array.get(hypTot,1)+array.get(hypTot,2)
            rHit := array.get(hypHit,1)+array.get(hypHit,2)
            rUp  := array.get(hypUpN,1)+array.get(hypUpN,2)
            rDn  := array.get(hypDnN,1)+array.get(hypDnN,2)
            cTot := array.get(hypTot,NREG+1)+array.get(hypTot,NREG+2)
            cHit := array.get(hypHit,NREG+1)+array.get(hypHit,NREG+2)
            cUp  := array.get(hypUpN,NREG+1)+array.get(hypUpN,NREG+2)
            cDn  := array.get(hypDnN,NREG+1)+array.get(hypDnN,NREG+2)
            bN := array.get(baseRegN,1)+array.get(baseRegN,2)
            bU := array.get(baseRegUp,1)+array.get(baseRegUp,2)
            bD := array.get(baseRegDn,1)+array.get(baseRegDn,2)
        else
            rTot := array.get(hypTot,3)
            rHit := array.get(hypHit,3)
            rUp  := array.get(hypUpN,3)
            rDn  := array.get(hypDnN,3)
            cTot := array.get(hypTot,NREG+3)
            cHit := array.get(hypHit,NREG+3)
            cUp  := array.get(hypUpN,NREG+3)
            cDn  := array.get(hypDnN,NREG+3)
            bN := array.get(baseRegN,3)
            bU := array.get(baseRegUp,3)
            bD := array.get(baseRegDn,3)
        float buRr = bN>0 ? bU/float(bN) : na
        float bdRr = bN>0 ? bD/float(bN) : na
        float revE = (rTot>0 and (rUp+rDn)>0 and not na(buRr)) ? (rHit*100.0/rTot) - (rUp*buRr+rDn*bdRr)/(rUp+rDn)*100.0 : na
        float conE = (cTot>0 and (cUp+cDn)>0 and not na(buRr)) ? (cHit*100.0/cTot) - (cUp*buRr+cDn*bdRr)/(cUp+cDn)*100.0 : na
        color revC = na(revE)?cdDm: revE>0?cdOk: revE<0?cdBd:cdWn
        color conC = na(conE)?cdDm: conE>0?cdOk: conE<0?cdBd:cdWn
        table.cell(calT,0,rr+6, array.get(rgLab,rr), text_color=cdTx, bgcolor=cdBg, text_size=size.tiny, text_halign=text.align_left)
        table.cell(calT,1,rr+6, "", bgcolor=cdBg)
        table.cell(calT,2,rr+6, str.tostring(rTot), text_color=cdDm, bgcolor=cdBg, text_size=size.tiny, text_halign=text.align_center)
        table.cell(calT,3,rr+6, na(revE)?"—":(revE>=0?"+":"")+str.tostring(revE,"0"), text_color=revC, bgcolor=cdBg, text_size=size.tiny, text_halign=text.align_center)
        table.cell(calT,4,rr+6, str.tostring(cTot), text_color=cdDm, bgcolor=cdBg, text_size=size.tiny, text_halign=text.align_center)
        table.cell(calT,5,rr+6, na(conE)?"—":(conE>=0?"+":"")+str.tostring(conE,"0"), text_color=conC, bgcolor=cdBg, text_size=size.tiny, text_halign=text.align_right)

// =============================================================================
// HEADLINE BANNER
// =============================================================================
var table headTbl = table.new(position.top_center, 1, 1)
if showHeadline and barstate.islast
    hbg = oHeadDir>0 ? color.new(#0e7a5f, 0) : oHeadDir<0 ? color.new(#9e2a2a, 0) : color.new(#3a4250, 0)
    table.cell(headTbl, 0, 0, "   " + oHead + "   ", text_color=color.white, text_size=size.normal, text_halign=text.align_center, bgcolor=hbg)

// =============================================================================
// IDENTITY
// =============================================================================
var table idTbl = table.new(position.bottom_center, 1, 1)
if showId and barstate.islast
    table.cell(idTbl, 0, 0, "Auction Volume Profile   ·   " + syminfo.ticker + "   ·   " + timeframe.period, text_color=color.new(#8a929e, 20), text_size=size.small, text_halign=text.align_center, bgcolor=color.new(color.gray, 100))
````
