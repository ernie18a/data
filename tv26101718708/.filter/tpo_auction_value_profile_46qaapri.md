# TPO Auction & Value Profile

- url: https://www.tradingview.com/script/46QaaPri-TPO-Auction-Value-Profile/
- type: indicator
- pine_id: PUB;37cf717d0eda4a81b0a0f4579ab06971
- version: 2.0

## Description

TPO Auction & Value Profile 

Overview

A complete intraday auction-profile engine. For each session it counts how much time price spent at each level — the Time-Price-Opportunity (TPO) distribution — and reads off what an auction cares about: Point of Control (most-traded price), Value Area (central band holding ~70% of activity, with VAH/VAL edges), Initial Balance (the open's framing range), excess tails vs poor unfinished extremes, single prints, and naked POCs (prior fair-value magnets price hasn't revisited). It then layers what a profile alone can't show: the volume POC beside the time POC, an optional buy/sell delta tint per level, prior-day value projected forward, a rolling composite (multi-day) value, and a decision dashboard that turns it all into one at-a-glance verdict. Sessions auto-detect from the instrument's own trading day — no setup.

What makes it different — why these pieces are ONE engine (mashup rationale)

This is the part TradingView asks publishers to justify, so here it is explicitly. Every component answers a different question about the same auction, and each is only meaningful in the presence of the others:


The TPO distribution is the substrate (where did the auction spend time?). POC + Value Area summarise agreed value; Initial Balance frames the open; excess / poor / single prints read the auction's completeness at the edges; naked POCs carry unfinished value forward.
The volume POC is laid over the time POC because time and volume don't always agree on fair value — their divergence is information a pure TPO profile cannot show.
The delta-per-level tint adds who was active (buyers vs sellers) at each price — the order-flow dimension behind the time distribution, reconstructed from lower-timeframe bars.
Prior-day and composite (multi-day) value place today in context: initiative vs responsive, value migration (higher/lower/overlapping) and failed auctions are only definable relative to those references.
The dashboard fuses location, migration, range extension, open type, day type and the rotational TPO count into one bias — the synthesis a stack of separate indicators leaves you to do by eye.


Split apart, each piece is a fragment; together they describe one thing — the shape, location and completeness of the auction. That interdependence is why it's a single engine, not a bundle.

What this adds over a standard TPO / Market Profile script

Most profile scripts stop at drawing the TPO letters/rows, POC, value area and IB. This engine goes well beyond that, and these additions are what make it original:


Auto-session that works where others break. New-session detection keys off a calendar-day change in the instrument's own timezone, so it resets correctly on feeds that have no out-of-session bars (NSE index futures only print 09:15–15:30) — where edge-detection-based scripts silently fail and pile every day into one profile. Zero setup, adapts to any market.
Time POC vs Volume POC divergence. It overlays the volume point of control on the time POC and flags when they disagree — a tradeable tell a time-only profile can't surface.
Delta-per-level (order flow at price). An optional row-colour mode tints each level by net buy/sell delta, reconstructed from lower-timeframe signed volume — showing who was active at each price, not just how long. Rare on TPO tools.
Excess vs poor, done rigorously. A single-print run of ≥ N rows at an extreme is flagged excess (strong rejection / completed auction); a flat multi-TPO extreme is flagged poor (unfinished). Most scripts conflate the two; here they're distinct and coloured differently.
Prior-day value, projected forward. Yesterday's POC/VAH/VAL extend into today as labelled reference lines — the levels every auction trader marks pre-session.
Rolling composite (multi-day) value. A composite POC/VAH/VAL across the last N sessions shows the longer-timeframe balance single-day profiles miss.
Fused decision dashboard. Open type (drive / reject-reverse / auction), day type (balanced … trend), value migration vs prior, range extension vs IB, the rotational TPO count, failed-auction state and a colour-coded bias headline — turning raw structure into one at-a-glance verdict, theme-adaptive to your chart.
Failed-auction detection + alerts. Fires when price breaks prior-day value and closes back inside — the high-probability fade auction theory points to.
Split-profile time colouring. Rows tinted by the bracket that first reached them, exposing migration and double distributions at a glance.


How it works

Session: Auto groups each profile by the instrument's trading day in its native timezone (first/last bars = detected open/close); Manual pins a window. Rows: price is binned (tick multiple, ATR fraction, or fixed step); each bar adds a TPO + its volume + its delta to every row it covered; rows can be coloured by time bracket (split profile), delta, or value area. Value Area grows from the POC to the richer neighbour until the chosen % is enclosed. Structure: a single-print run ≥ N rows at an extreme is excess (strong rejection); a flat multi-TPO extreme is poor (unfinished); TPO count sums TPOs above vs below POC (singles excluded). Analytics: open type, day type, value migration, range extension, failed auctions. Developing vs completed: the live session updates on the forming bar and settles on close; finished sessions are drawn once; naked POCs extend until filled.

How to use

Lead with the dashboard's bias headline, then confirm with structure: value-area edges are acceptance/rejection levels; POC, volume POC and naked POCs are magnets; excess marks completed auctions, poor extremes mark unfinished business price tends to revisit; prior-day and composite value say where today sits; a failed auction back inside value is a high-odds fade. Context for your decisions — not a standalone trigger.

Originality

The auction concepts are public (credited below); the original work is the assembly and the code — auto-session detection that works on instruments with no out-of-session bars, the time-vs-volume POC divergence read, an original delta-per-level reconstruction, the rolling composite, the excess-vs-poor logic, and the fused decision dashboard. No third-party code is reused.

Concept credit

The auction / Market-Profile framework (time-price opportunities, value area, point of control, initial balance, excess, single prints, day/open types) originates with J. Peter Steidlmayer at the Chicago Board of Trade and was developed for traders by James Dalton. Volume-at-price is standard volume-profile practice. Buy/sell classification uses the tick rule (Lee & Ready, 1991).

Honesty / limitations

A TPO profile measures time at price, not size; the volume POC and delta add the volume view, but the delta is a tick-rule estimate from lower-timeframe bars, not true bid/ask data. The composite is a rolling window that refreshes periodically, not a fixed calendar range. Open type and day type are transparent heuristics. Row size changes the picture. Descriptive auction context — it does not predict price.

Disclaimer

Research / educational only. NOT financial advice; no guarantee of profitability. Indicators describe past behaviour. Trading carries risk of loss. Test out-of-sample. The author accepts no liability.

## Source Code

````pine
//@version=6
// ══════════════════════════════════════════════════════════════════════════════════════════════
// © Market_Logic_India                                                       MPL-2.0
// TPO AUCTION & VALUE PROFILE                                                             v1.0
// ────────────────────────────────────────────────────────────────────────────────────────────
// OVERVIEW
//   A complete intraday auction-profile engine. For each session it counts how much TIME price
//   spent at each level (the Time-Price-Opportunity, or TPO, distribution) and reads off the
//   levels an auction actually cares about - POINT OF CONTROL (the most-traded price), VALUE AREA
//   (the central band holding a chosen share of activity, default 70%, with its VAH / VAL edges),
//   INITIAL BALANCE (the open's framing range), EXCESS tails vs POOR / unfinished extremes, SINGLE
//   PRINTS, and NAKED POCs (prior fair-value magnets price has not revisited). It then layers the
//   reads a profile alone can't give: the VOLUME point of control beside the time POC, an optional
//   BUY/SELL DELTA tint per level, the PRIOR-DAY value projected forward, a rolling COMPOSITE
//   (multi-day) value, and a decision dashboard that turns all of it into one at-a-glance verdict.
//   Sessions are detected automatically from the instrument's own trading day - no setup required.
//
// WHAT MAKES IT DIFFERENT  (why these pieces are ONE engine, not many overlays)
//   Every part here answers a different question about the SAME auction, and each only means
//   something in the presence of the others - which is precisely why they belong in one tool:
//     - The TPO DISTRIBUTION is the substrate (where did the auction spend time?). POC + VALUE AREA
//       summarise agreed value; INITIAL BALANCE frames the open; EXCESS / POOR / SINGLE PRINTS read
//       the completeness of the auction at the edges; NAKED POCs carry unfinished value forward.
//     - The VOLUME POC is laid over the TIME POC because time and volume do not always agree on
//       fair value; their DIVERGENCE is information a pure TPO profile cannot show.
//     - The DELTA-per-level tint adds who was active (buyers vs sellers) at each price - the order-
//       flow dimension behind the time distribution, reconstructed from lower-timeframe bars.
//     - PRIOR-DAY value and the COMPOSITE (multi-day) value place today inside its larger context;
//       initiative vs responsive, higher/lower/overlapping migration, and failed auctions are only
//       definable RELATIVE to those references.
//     - The DASHBOARD fuses location, migration, range extension, open type, day type and the
//       rotational TPO count into a single bias - the synthesis a stack of separate indicators
//       leaves the trader to do by eye.
//   Split apart, each piece is a fragment; together they describe one thing - the shape, location
//   and completeness of the auction - which is why this is a single engine rather than a mashup.
//
// HOW IT WORKS
//   - SESSION: Auto mode groups each profile by the instrument's own trading day in its native
//     timezone (first/last bars = detected open/close); Manual mode pins an explicit window.
//   - ROWS: price is binned into rows sized by tick multiple, ATR fraction, or fixed step; each bar
//     adds one TPO (and its volume / delta) to every row it covered. Optional row colouring: time
//     bracket (split profile), buy/sell delta, or value-area.
//   - VALUE AREA: grows from the POC to the richer neighbour until the chosen % of TPOs is enclosed;
//     a parallel VOLUME value area (VVAH / VVAL) is built the same way from traded size, so time and
//     volume can be compared - when they shift apart, the two disagree on fair value.
//   - NODES: the developing volume profile is scanned for High-Volume Nodes (acceptance magnets) and
//     Low-Volume Nodes (thin, fast-move gaps price travels through quickly).
//   - STRUCTURE: a single-print run of >= N rows at an extreme is EXCESS (strong rejection); a flat
//     multi-TPO extreme is POOR (unfinished). TPO count sums TPOs above vs below POC (singles
//     excluded) for the rotational read.
//   - ANALYTICS: open type (drive / reject-reverse / auction), day type (balanced ... trend), value
//     migration vs prior, range extension vs IB, failed auctions vs prior value, the 80% rule, the
//     profile SHAPE (Normal/D, P short-covering, b long-liquidation, double-distribution trend), and
//     Dalton's ROTATION FACTOR - per-bracket directional conviction summed across the session.
//   - CALIBRATION: a value-edge acceptance harness logs every tag of prior-day VAH / VAL and reports
//     how often it rejected back to POC before accepting beyond - an honest, in-sample Hit % / Edge.
//   - DEVELOPING vs COMPLETED: the live session updates on the forming bar and settles on close;
//     finished sessions are drawn once and kept. Naked POCs extend right until price trades through.
//
// HOW TO USE
//   Start with the dashboard's bias headline, then confirm with the structure: value-area edges are
//   acceptance/rejection levels; POC, volume POC, HVNs and naked POCs are magnets while LVNs are
//   raced through; a TPO-vs-volume value shift flags disagreement; excess marks completed auctions,
//   poor extremes mark unfinished business price tends to revisit; prior-day and composite value say
//   where today sits; a failed auction back inside value is a high-odds fade, and the 80% rule
//   projects a rotation target. Read the profile SHAPE and ROTATION FACTOR for conviction (P/b warn
//   of short-covering / long-liquidation; a double distribution is a trend day), and let the VA-edge
//   fade Hit % / Edge tell you whether fading value edges has actually paid on this instrument. This
//   engine describes auction STRUCTURE and is context - not a standalone trade trigger.
//
// UNIVERSAL ACROSS MARKETS  (configurable data source)
//   High / low / close sources, the session mode/window/timezone, and the row method are all inputs,
//   so the engine runs on any instrument and timeframe. Defaults target NSE NIFTY index futures
//   intraday; change the sources and session for any other market. Use an intraday chart. The delta
//   tint needs a real volume feed and a lower timeframe; without them it degrades gracefully.
//
// NON-REPAINT
//   Completed-session profiles are computed from confirmed bars and never change once drawn. The
//   developing session updates with the forming bar and settles on close. No higher-timeframe
//   lookahead is used; the delta uses lower-timeframe bars of the same symbol.
//
// CONCEPT CREDIT
//   The auction / Market-Profile framework - time-price opportunities, value area, point of control,
//   initial balance, excess, single prints, day and open types, profile shapes, the rotation factor,
//   the 80% rule - originates with J. Peter Steidlmayer at the Chicago Board of Trade and was
//   developed further for traders by James Dalton. Volume-at-price, the volume value area and high/
//   low volume nodes are standard volume-profile practice. Buy/sell classification uses the tick rule
//   (Lee & Ready, 1991). All implementation is original; not affiliated with, nor endorsed by, any
//   third party, and no third-party code is reused.
//
// HONESTY / LIMITATIONS
//   A TPO profile measures TIME at price, not traded size; the volume POC and delta add the volume
//   view but the delta is a tick-rule ESTIMATE from lower-timeframe bars, not true bid/ask data. The
//   composite is a rolling window that refreshes periodically, not a fixed calendar range. Open type
//   and day type are transparent heuristics, not the final word. Row size changes the picture. This
//   is descriptive auction context; it does not predict price.
//
// DISCLAIMER
//   Research and educational tool only. NOT financial advice and NO guarantee of profitability or
//   accuracy. Indicators describe past behaviour; they do not predict the future. Trading carries
//   risk of loss. Test out-of-sample and make your own decisions. The author accepts no liability
//   for any use of this script.
// ══════════════════════════════════════════════════════════════════════════════════════════════
indicator("TPO Auction & Value Profile", "TPO Engine", overlay = true, dynamic_requests = true,
     max_boxes_count = 500, max_lines_count = 500, max_labels_count = 300)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                          INPUTS
// ═════════════════════════════════════════════════════════════════════════════════════════

// ── 01 · DATA & SESSION ────────────────────────────────────────────────────────────────────
g01 = "01 · Data & session"
srcHigh = input.source(high,  "High source", group = g01)
srcLow  = input.source(low,   "Low source",  group = g01)
srcCls  = input.source(close, "Close source (naked-POC fill test)", group = g01)
sesMode = input.string("Auto (from chart)", "Session detection", options = ["Auto (from chart)","Manual session"], group = g01,
     tooltip = "Auto groups each profile by the instrument's own trading day in its native timezone - the first and last bars of each day ARE the detected open and close, so it adapts to any market with no setup. Manual pins an explicit intraday window.")
sesStr  = input.session("0915-1530", "Manual session window", group = g01,
     tooltip = "Used only in Manual mode. Default 09:15-15:30 suits NSE cash/futures RTH; change for other markets.")
sesTz   = input.string("Asia/Kolkata", "Manual session timezone", group = g01,
     tooltip = "Used only in Manual mode.")
showSessions = input.int(5, "Sessions to keep", minval = 1, maxval = 30, group = g01,
     tooltip = "How many recent completed-session profiles to keep drawn. Older ones are removed.")

// ── 02 · PROFILE RESOLUTION ────────────────────────────────────────────────────────────────
g02 = "02 · Profile resolution"
rowMode = input.string("ATR fraction", "Row-size method", options = ["ATR fraction","Ticks","Fixed price"], group = g02,
     tooltip = "Height of each price row. ATR fraction adapts to volatility; Ticks / Fixed price are absolute.")
rowATR  = input.float(0.10, "Row = ATR x", minval = 0.02, step = 0.02, group = g02, inline = "r1")
atrLen  = input.int(14, "ATR len", minval = 2, group = g02, inline = "r1")
rowTk   = input.int(20, "Row = ticks", minval = 1, group = g02)
rowPx   = input.float(5.0, "Row = price", minval = 0.0, step = 0.5, group = g02)
maxRows = input.int(80, "Max rows per profile", minval = 10, maxval = 200, group = g02,
     tooltip = "Safety cap. If a session's range needs more rows than this, the row size is widened so the profile still fits.")
profWidth = input.int(40, "Profile width (bars)", minval = 5, maxval = 200, group = g02,
     tooltip = "Bar-width the widest (POC) row is drawn to; other rows scale by their TPO count.")
profRight = input.bool(false, "Draw profile to the right of session", group = g02,
     tooltip = "Off: profile grows rightward from the session's first bar (overlaps price). On: profile is offset to the right of the session.")
rowColor = input.string("Bracket (time)", "Row colouring", options = ["Bracket (time)","Delta (buy/sell)","Value area"], group = g02,
     tooltip = "How developing TPO rows are tinted. Bracket = the classic split-profile time gradient. Delta = net buy/sell volume at each level (intraday; uses the delta timeframe below). Value area = simple in / out-of-value colouring.")
bracketMin = input.int(30, "Bracket size (minutes)", minval = 5, maxval = 240, group = g02,
     tooltip = "Minutes per TPO bracket (Market Profile convention is 30).")
ltfDelta = input.timeframe("1", "Delta intrabar timeframe", group = g02,
     tooltip = "Lower timeframe used to estimate buy/sell delta per level when Row colouring = Delta. Intraday only; ignored otherwise.")

// ── 03 · VALUE AREA & POC ──────────────────────────────────────────────────────────────────
g03 = "03 · Value area & POC"
vaPct   = input.float(70, "Value-area %", minval = 30, maxval = 95, step = 1, group = g03)
showPOC = input.bool(true, "Show POC", group = g03)
showVA  = input.bool(true, "Show VAH / VAL", group = g03)
showProfile = input.bool(true, "Draw TPO profile boxes", group = g03)
showPrior = input.bool(true, "Overlay prior-day value (POC / VAH / VAL)", group = g03,
     tooltip = "Projects the previous completed session's POC, VAH and VAL forward as reference levels - the first thing auction traders mark pre-session.")
showVPOC = input.bool(true, "Show volume POC (vs time POC)", group = g03,
     tooltip = "Draws the volume point of control alongside the time (TPO) POC. When they diverge, time and volume disagree on fair value - a tradeable tell.")
showVVA = input.bool(true, "Show volume value area (VVAH / VVAL)", group = g03,
     tooltip = "Draws the value area computed from VOLUME, not time. When the volume value area is shifted from the TPO value area, volume and time disagree on fair value - the 'use both perspectives' confirmation practitioners favour.")
showComposite = input.bool(true, "Show composite (multi-day) value", group = g03,
     tooltip = "Overlays the rolling multi-session balance: composite POC / VAH / VAL across the last N sessions - the longer-timeframe value structure single-day profiles miss.")
compSessions = input.int(5, "Composite sessions", minval = 2, maxval = 30, group = g03)

// ── 04 · INITIAL BALANCE ───────────────────────────────────────────────────────────────────
g04 = "04 · Initial balance"
showIB  = input.bool(true, "Show initial balance", group = g04)
ibBars  = input.int(12, "IB length (bars from open)", minval = 1, maxval = 120, group = g04,
     tooltip = "Number of bars from the session open that define the Initial Balance range.")

// ── 05 · STRUCTURE ─────────────────────────────────────────────────────────────────────────
g05 = "05 · Structure"
showSP   = input.bool(true, "Mark single prints", group = g05,
     tooltip = "Rows touched by only one TPO - thin, raced-through zones the market often retests.")
showPoor = input.bool(true, "Flag poor / unfinished highs & lows", group = g05)
poorMin  = input.int(2, "Poor extreme min TPOs", minval = 2, maxval = 10, group = g05,
     tooltip = "An extreme row touched by at least this many TPOs (no single-print excess) is flagged poor / unfinished.")
excessMin = input.int(2, "Excess tail min single prints", minval = 2, maxval = 12, group = g05,
     tooltip = "A run of this many single-print TPOs at an extreme is a tail / excess - strong rejection that completes the auction (distinct from a flat, poor extreme).")
showNPOC = input.bool(true, "Show naked POCs (magnets)", group = g05)
npocKeep = input.int(20, "Naked POCs to track", minval = 1, maxval = 60, group = g05)
showNodes = input.bool(true, "Show volume nodes (HVN / LVN)", group = g05,
     tooltip = "Marks High-Volume Nodes (acceptance / magnets) and Low-Volume Nodes (thin, fast-move gaps price travels through quickly) in the developing volume profile.")
nodeFrac = input.float(0.7, "HVN threshold (x peak vol)", minval = 0.3, maxval = 0.95, step = 0.05, group = g05)
lvnFrac  = input.float(0.25, "LVN threshold (x peak vol)", minval = 0.05, maxval = 0.5, step = 0.05, group = g05)
showEighty = input.bool(true, "80% rule flag", group = g05,
     tooltip = "Auction-theory rule: when price re-enters the prior session's value area and holds (~2 brackets), it tends to rotate across to the far value-area edge. Flags it and projects the target edge.")
showShape = input.bool(true, "Classify profile shape (D / P / b / double)", group = g05,
     tooltip = "Reads the developing distribution's shape: Normal/D (balanced), P (short-covering - POC high, thin tail below), b (long-liquidation - POC low, thin tail above), or double-distribution (two balances split by a low-volume gap = trend day).")
veOn = input.bool(true, "Value-edge acceptance harness", group = g05,
     tooltip = "Calibrates, on THIS instrument, how often a tag of prior-day VAH / VAL rejects back to the prior POC before price accepts beyond the edge. Reports Hit %, a 50% coin-flip base, and Edge = Hit - 50.")
veAcc = input.float(0.5, "Acceptance distance (x ATR beyond edge)", minval = 0.1, step = 0.1, group = g05,
     tooltip = "How far beyond the edge counts as acceptance (a failed fade) rather than a rejection.")
veHorizon = input.int(40, "Edge-test horizon (bars)", minval = 5, maxval = 300, group = g05)

// ── 06 · DASHBOARD & THEME ─────────────────────────────────────────────────────────────────
g06 = "06 · Dashboard & theme"
showTable = input.bool(true, "Show dashboard", group = g06)
tblPos    = input.string("Top Right", "Dashboard position", options = ["Top Right","Top Left","Bottom Right","Bottom Left"], group = g06)
dashTheme = input.string("Auto (match chart)", "Dashboard theme", options = ["Auto (match chart)","Dark","Light"], group = g06)

// ── 07 · COLORS ────────────────────────────────────────────────────────────────────────────
g07 = "07 · Colors"
colVA   = input.color(#3a7bd5, "Value-area rows", group = g07)
colOut  = input.color(#8a93a3, "Outside-VA rows", group = g07)
colPOC  = input.color(#f7c948, "POC", group = g07)
colVAed = input.color(#2ebd85, "VAH / VAL", group = g07)
colIB   = input.color(#b07cff, "Initial balance", group = g07)
colSP   = input.color(#f6465d, "Single prints / poor", group = g07)
colNP   = input.color(#f7c948, "Naked POC", group = g07)
colPrior = input.color(#9aa6b2, "Prior-day value", group = g07)
colVPOC  = input.color(#ff9800, "Volume POC", group = g07)
colExc   = input.color(#2ebd85, "Excess / tails", group = g07)
colBkt1  = input.color(#3a7bd5, "Bracket early", inline = "bk", group = g07)
colBkt2  = input.color(#f6465d, "Bracket late", inline = "bk", group = g07)
colDBuy  = input.color(#2ebd85, "Delta buy", inline = "dl", group = g07)
colDSell = input.color(#f6465d, "Delta sell", inline = "dl", group = g07)
colComp  = input.color(#ffd54f, "Composite value", group = g07)
colHVN   = input.color(#26a69a, "HVN node", inline = "nd", group = g07)
colLVN   = input.color(#7e57c2, "LVN node", inline = "nd", group = g07)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                          HELPERS
// ═════════════════════════════════════════════════════════════════════════════════════════
f_pos(string s) =>
    s == "Top Left" ? position.top_left : s == "Bottom Right" ? position.bottom_right : s == "Bottom Left" ? position.bottom_left : position.top_right

f_hm(int m) =>
    na(m) ? "--:--" : str.tostring(int(m / 60), "00") + ":" + str.tostring(m % 60, "00")

f_cnt(map<int, float> m, int k) =>
    float v = m.get(k)
    na(v) ? 0.0 : v

// argmax key of a map (used for the volume POC)
f_pocOnly(map<int, float> m) =>
    array<int> ks = m.keys()
    int best = na
    float bc = -1.0
    if ks.size() > 0
        for i = 0 to ks.size() - 1
            int k = ks.get(i)
            float c = m.get(k)
            if c > bc
                bc := c
                best := k
    best

// length of the consecutive single-print run starting at an extreme (a tail / excess)
f_tailLen(map<int, float> m, int extK, int otherK) =>
    int dir = extK >= otherK ? -1 : 1
    int lo = math.min(extK, otherK)
    int hi = math.max(extK, otherK)
    int len = 0
    int k = extK
    bool go = not na(extK) and not na(otherK)
    while go and len < 200
        if k < lo or k > hi
            go := false
        else if f_cnt(m, k) == 1.0
            len += 1
            k += dir
        else
            go := false
    len

// TPO count above vs below the POC, excluding single prints (rotational factor)
f_tpoCount(map<int, float> m, int pocK, int minK, int maxK) =>
    float ab = 0.0
    float bl = 0.0
    if not na(pocK) and not na(minK) and not na(maxK)
        for k = minK to maxK
            float c = f_cnt(m, k)
            if c > 1.0
                if k > pocK
                    ab += c
                else if k < pocK
                    bl += c
    [ab, bl]

// maximum absolute value across a map (delta-gradient scale)
f_maxAbs(map<int, float> m) =>
    array<float> vs = m.values()
    float mx = 0.0
    if vs.size() > 0
        for i = 0 to vs.size() - 1
            mx := math.max(mx, math.abs(vs.get(i)))
    mx

// profile statistics from a TPO map -> [pocKey, vaTopKey, vaBotKey, minKey, maxKey, total]
f_stats(map<int, float> m, float vapct) =>
    array<int> keys = m.keys()
    int n = keys.size()
    int pocK = na
    int minK = na
    int maxK = na
    float pocC = -1.0
    float tot = 0.0
    if n > 0
        for i = 0 to n - 1
            int k = keys.get(i)
            float c = m.get(k)
            tot += c
            if c > pocC
                pocC := c
                pocK := k
            if na(minK) or k < minK
                minK := k
            if na(maxK) or k > maxK
                maxK := k
    int vaT = pocK
    int vaB = pocK
    if not na(pocK)
        float acc = m.get(pocK)
        float target = tot * vapct / 100.0
        while acc < target and (vaT < maxK or vaB > minK)
            float up   = vaT < maxK ? f_cnt(m, vaT + 1) : -1.0
            float down = vaB > minK ? f_cnt(m, vaB - 1) : -1.0
            if up >= down and vaT < maxK
                vaT += 1
                acc += f_cnt(m, vaT)
            else if vaB > minK
                vaB -= 1
                acc += f_cnt(m, vaB)
            else if vaT < maxK
                vaT += 1
                acc += f_cnt(m, vaT)
    [pocK, vaT, vaB, minK, maxK, tot]

// classify the developing distribution shape (auction grammar)
f_shape(map<int, float> m, int pocK, int minK, int maxK) =>
    string sh = "-"
    if not na(pocK) and not na(minK) and not na(maxK) and maxK > minK
        int rng = maxK - minK
        float pocPos = (pocK - minK) / float(rng)
        float peak = f_cnt(m, pocK)
        float tot2 = 0.0
        for k = minK to maxK
            tot2 += f_cnt(m, k)
        float valley = peak
        int valK = na
        if rng >= 6
            for k = minK + 2 to maxK - 2
                float c = f_cnt(m, k)
                if c < valley
                    valley := c
                    valK := k
        bool dbl = false
        if not na(valK) and peak > 0 and valley <= 0.30 * peak
            float above = 0.0
            float below = 0.0
            for k = minK to maxK
                if k > valK
                    above += f_cnt(m, k)
                else if k < valK
                    below += f_cnt(m, k)
            if tot2 > 0 and above >= 0.30 * tot2 and below >= 0.30 * tot2
                dbl := true
        sh := dbl ? "Double (trend)" : pocPos >= 0.62 ? "P (short-cover)" : pocPos <= 0.38 ? "b (long-liq.)" : "Normal (D)"
    sh

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                       SESSION STATE
// ═════════════════════════════════════════════════════════════════════════════════════════
float atrV = ta.atr(atrLen)

// lower-timeframe signed volume (tick-rule) for the optional delta-per-level colouring
array<float> ltfSig = request.security_lower_tf(syminfo.tickerid, ltfDelta, volume * math.sign(close - close[1]))
float barDelta = 0.0
if not na(ltfSig) and array.size(ltfSig) > 0
    for v in ltfSig
        barDelta += nz(v)
else
    barDelta := nz(volume) * math.sign(close - close[1])

// session detection
bool   autoSes = sesMode == "Auto (from chart)"
string dtz     = autoSes ? syminfo.timezone : sesTz
float sesTime = time(timeframe.period, sesStr, sesTz)
bool  inSes   = autoSes ? true : not na(sesTime)
var bool wasIn = false
// New-session detection robust on instruments with NO out-of-session bars (NSE index futures
// only print 09:15-15:30): a session = one trading day, detected by a calendar-day change in
// the relevant timezone. Auto uses the instrument's own timezone, so the engine adapts to any
// market's real hours - the first and last bars of each day are the detected open and close.
int   sesDom  = dayofmonth(time, dtz)
bool  dayChg  = sesDom != sesDom[1]
bool  newSes  = inSes and (not wasIn or dayChg)
bool  endSes  = (not inSes) and wasIn
wasIn := inSes
// detected open / close (minutes-of-day) - last completed session, shown in the dashboard
var int sesOpenMin  = na
var int sesLastMin  = na
var int prevOpenMin = na
var int prevCloseMin = na
if newSes
    prevOpenMin  := sesOpenMin
    prevCloseMin := sesLastMin
    sesOpenMin   := hour(time, dtz) * 60 + minute(time, dtz)
if inSes
    sesLastMin   := hour(time, dtz) * 60 + minute(time, dtz)
// current time-bracket index within the developing session (for split-profile colouring)
int curBkt = (na(sesOpenMin) or na(sesLastMin)) ? 0 : int(math.max(0, sesLastMin - sesOpenMin) / math.max(1, bracketMin))

var map<int, float> curTpo = map.new<int, float>()
var map<int, float> curVol = map.new<int, float>()
var map<int, float> curDelta = map.new<int, float>()
var map<int, int>   rowBkt = map.new<int, int>()
var map<int, float> compTpo = map.new<int, float>()
var float compRowSz = na
var int   compCount = 0
var float rowSz   = na
var int   sesBar0 = na
var int   sesT0   = na
var int   ibCount = 0
var float ibHi    = na
var float ibLo    = na
// prior completed session's value (for migration / prior-value reads)
var float prevPoc = na
var float prevVah = na
var float prevVal = na
// open-type excursions and failed-auction state (reset each session)
var float sesOpenPx = na
var float upExc = na
var float dnExc = na
var bool  brokeAbove = false
var bool  brokeBelow = false
// 80% rule state: time spent back inside prior-day value, and the side entered from
var int   pvInside = 0
var int   pvFrom = 0
// rotation factor: per-bracket directional conviction
var int   rotFactor = 0
var int   rotBktTrack = -1
var float bHi = na
var float bLo = na
var float pHiR = na
var float pLoR = na
// value-edge acceptance harness state
var int   veN = 0
var int   veHit = 0
var bool  vePend = false
var int   veDir = 0
var float veTgt = na
var float veInval = na
var int   veBars = 0

// developing-profile drawables (redrawn on the last bar)
var array<box>  devBoxes = array.new<box>()
var array<line> devLines = array.new<line>()
var array<label> devLabs = array.new<label>()

// naked-POC pool
var array<line>  npLines = array.new<line>()
var array<float> npPrice = array.new<float>()
var array<bool>  npFilled = array.new<bool>()

// bar duration in ms - used to anchor all drawings by time (no bar-index distance limit)
int barMs = timeframe.in_seconds() * 1000

f_rowSize() =>
    float r = rowMode == "Ticks" ? rowTk * syminfo.mintick : rowMode == "Fixed price" ? rowPx : (not na(atrV) and atrV > 0 ? atrV * rowATR : syminfo.mintick * 10)
    r <= 0 ? syminfo.mintick : r

// finalize a completed session: compute stats, draw the kept profile, push naked POC
f_finalize() =>
    [pocK, vaT, vaB, minK, maxK, tot] = f_stats(curTpo, vaPct)
    float rpoc = na
    float rvah = na
    float rval = na
    if not na(pocK) and not na(rowSz) and tot > 0
        float pocPrice = (pocK + 0.5) * rowSz
        float vahPrice = (vaT + 1) * rowSz
        float valPrice = vaB * rowSz
        rpoc := pocPrice
        rvah := vahPrice
        rval := valPrice
        int   t0 = na(sesT0) ? time : sesT0
        int   t1 = time
        // completed profile drawn compactly as VA box + POC line (kept; auto-GC oldest)
        if showProfile
            box.new(t0, vahPrice, t1, valPrice, xloc = xloc.bar_time, border_color = color.new(colVA, 40), bgcolor = color.new(colVA, 88))
        if showPOC
            line.new(t0, pocPrice, t1, pocPrice, xloc = xloc.bar_time, color = color.new(colPOC, 0), width = 2)
        if showVA
            line.new(t0, vahPrice, t1, vahPrice, xloc = xloc.bar_time, color = color.new(colVAed, 30), style = line.style_dashed)
            line.new(t0, valPrice, t1, valPrice, xloc = xloc.bar_time, color = color.new(colVAed, 30), style = line.style_dashed)
        // excess (single-print tails at extremes = strong rejection) vs poor (flat = unfinished)
        int topTail = f_tailLen(curTpo, maxK, minK)
        int botTail = f_tailLen(curTpo, minK, maxK)
        if showPoor
            if topTail >= excessMin
                label.new(t1, (maxK + 1) * rowSz, "excess", xloc = xloc.bar_time, style = label.style_label_down, color = color.new(colExc, 25), textcolor = color.white, size = size.tiny)
            else if f_cnt(curTpo, maxK) >= poorMin
                label.new(t1, (maxK + 1) * rowSz, "poor high", xloc = xloc.bar_time, style = label.style_label_down, color = color.new(colSP, 30), textcolor = color.white, size = size.tiny)
            if botTail >= excessMin
                label.new(t1, minK * rowSz, "excess", xloc = xloc.bar_time, style = label.style_label_up, color = color.new(colExc, 25), textcolor = color.white, size = size.tiny)
            else if f_cnt(curTpo, minK) >= poorMin
                label.new(t1, minK * rowSz, "poor low", xloc = xloc.bar_time, style = label.style_label_up, color = color.new(colSP, 30), textcolor = color.white, size = size.tiny)
        // single prints (those forming an excess tail drawn brighter in the excess colour)
        if showSP
            for k = minK to maxK
                if f_cnt(curTpo, k) == 1.0
                    bool inTail = (topTail >= excessMin and k >= maxK - topTail + 1) or (botTail >= excessMin and k <= minK + botTail - 1)
                    color spc = inTail ? colExc : colSP
                    box.new(t0, (k + 1) * rowSz, t1, k * rowSz, xloc = xloc.bar_time, border_color = color.new(spc, inTail ? 55 : 82), bgcolor = color.new(spc, inTail ? 78 : 90))
        // volume POC marker when it diverges from the time POC
        if showVPOC
            int vk = f_pocOnly(curVol)
            if not na(vk) and vk != pocK
                line.new(t0, (vk + 0.5) * rowSz, t1, (vk + 0.5) * rowSz, xloc = xloc.bar_time, color = color.new(colVPOC, 20), width = 1, style = line.style_dotted)
        // register naked POC (extends right until filled)
        if showNPOC
            line npl = line.new(t1, pocPrice, t1 + barMs, pocPrice, xloc = xloc.bar_time, color = color.new(colNP, 20), width = 1, extend = extend.right)
            npLines.push(npl)
            npPrice.push(pocPrice)
            npFilled.push(false)
            while npLines.size() > npocKeep
                line.delete(npLines.shift())
                npPrice.shift()
                npFilled.shift()
    [rpoc, rvah, rval]

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                  ACCUMULATE / SESSION LOOP
// ═════════════════════════════════════════════════════════════════════════════════════════
if newSes
    // finalize the prior session (if any rows accumulated), store its value, then reset
    if curTpo.size() > 0
        [fpoc, fvah, fval] = f_finalize()
        if not na(fpoc)
            prevPoc := fpoc
            prevVah := fvah
            prevVal := fval
    curTpo.clear()
    curVol.clear()
    curDelta.clear()
    rowBkt.clear()
    rowSz   := f_rowSize()
    sesBar0 := bar_index
    sesT0   := time
    ibCount := 0
    ibHi    := srcHigh
    ibLo    := srcLow
    sesOpenPx := open
    upExc   := 0.0
    dnExc   := 0.0
    brokeAbove := false
    brokeBelow := false
    pvInside := 0
    pvFrom := 0
    rotFactor := 0
    rotBktTrack := -1
    bHi := na
    bLo := na
    pHiR := na
    pLoR := na
    // composite (multi-day) window: refresh every compSessions sessions on a fixed bin size
    compCount += 1
    if na(compRowSz) or compCount > compSessions
        compTpo.clear()
        compRowSz := f_rowSize()
        compCount := 1

// accumulate TPOs for the current bar across its price span
if inSes and not na(rowSz)
    int kLo = int(math.floor(srcLow / rowSz))
    int kHi = int(math.floor(srcHigh / rowSz))
    // widen row size if a session ever needs more than maxRows (keeps the profile bounded)
    if (kHi - kLo) > maxRows
        rowSz := rowSz * math.ceil(float(kHi - kLo + 1) / maxRows)
        kLo := int(math.floor(srcLow / rowSz))
        kHi := int(math.floor(srcHigh / rowSz))
    for k = kLo to kHi
        curTpo.put(k, f_cnt(curTpo, k) + 1.0)
        curVol.put(k, f_cnt(curVol, k) + nz(volume) / math.max(1, kHi - kLo + 1))
        curDelta.put(k, f_cnt(curDelta, k) + barDelta / math.max(1, kHi - kLo + 1))
        if not rowBkt.contains(k)
            rowBkt.put(k, curBkt)
    // composite (multi-day) accumulation on the fixed composite bin size
    if not na(compRowSz)
        int cLo = int(math.floor(srcLow / compRowSz))
        int cHi = int(math.floor(srcHigh / compRowSz))
        if (cHi - cLo) <= maxRows * 4
            for k = cLo to cHi
                compTpo.put(k, f_cnt(compTpo, k) + 1.0)
    // initial balance
    if ibCount < ibBars
        ibHi := na(ibHi) ? srcHigh : math.max(ibHi, srcHigh)
        ibLo := na(ibLo) ? srcLow  : math.min(ibLo, srcLow)
        ibCount += 1
    // open-type excursions from the session open
    if not na(sesOpenPx)
        upExc := math.max(nz(upExc), srcHigh - sesOpenPx)
        dnExc := math.max(nz(dnExc), sesOpenPx - srcLow)
    // failed-auction tracking vs prior-day value (a break of prior value that fails back inside)
    if not na(prevVah) and srcHigh > prevVah
        brokeAbove := true
    if not na(prevVal) and srcLow < prevVal
        brokeBelow := true
    // 80% rule: count time spent back inside prior-day value, and record the side entered from
    bool inPV0 = not na(prevVah) and not na(prevVal) and srcCls <= prevVah and srcCls >= prevVal
    if inPV0
        if pvInside == 0
            pvFrom := srcCls[1] > prevVah ? 1 : srcCls[1] < prevVal ? -1 : pvFrom
        pvInside += 1
    else
        pvInside := 0
    // rotation factor: each completed bracket scores +/-1 for a higher/lower high and low
    if curBkt != rotBktTrack
        if not na(bHi) and not na(pHiR)
            rotFactor += (bHi > pHiR ? 1 : bHi < pHiR ? -1 : 0) + (bLo > pLoR ? 1 : bLo < pLoR ? -1 : 0)
        pHiR := bHi
        pLoR := bLo
        bHi := srcHigh
        bLo := srcLow
        rotBktTrack := curBkt
    else
        bHi := na(bHi) ? srcHigh : math.max(bHi, srcHigh)
        bLo := na(bLo) ? srcLow : math.min(bLo, srcLow)

// naked-POC fill test: a POC is "filled" once price trades through it
if showNPOC and npLines.size() > 0
    for i = 0 to npLines.size() - 1
        if not npFilled.get(i)
            float p = npPrice.get(i)
            if srcHigh >= p and srcLow <= p
                npFilled.set(i, true)
                line.set_extend(npLines.get(i), extend.none)
                line.set_x2(npLines.get(i), time)
                line.set_color(npLines.get(i), color.new(colNP, 70))

// value-edge acceptance harness: does a tag of prior VAH/VAL reject to POC before accepting beyond?
bool veRejNow = false
if veOn and not na(prevVah) and not na(prevVal) and not na(prevPoc) and not na(atrV) and atrV > 0
    if vePend
        veBars += 1
        if veDir == 1
            if srcLow <= veTgt
                veHit += 1
                vePend := false
                veRejNow := true
            else if srcHigh >= veInval or veBars > veHorizon
                vePend := false
        else
            if srcHigh >= veTgt
                veHit += 1
                vePend := false
                veRejNow := true
            else if srcLow <= veInval or veBars > veHorizon
                vePend := false
    if not vePend
        if srcHigh >= prevVah and srcHigh[1] < prevVah
            vePend := true
            veDir := 1
            veTgt := prevPoc
            veInval := prevVah + veAcc * atrV
            veBars := 0
            veN += 1
        else if srcLow <= prevVal and srcLow[1] > prevVal
            vePend := true
            veDir := -1
            veTgt := prevPoc
            veInval := prevVal - veAcc * atrV
            veBars := 0
            veN += 1

// 80% rule flag and rotation target (far value-area edge)
float tfMin = timeframe.in_seconds() / 60.0
int barsPerBkt = math.max(1, int(math.round(bracketMin / math.max(tfMin, 1.0))))
bool eighty = showEighty and not na(prevVah) and not na(prevVal) and srcCls <= prevVah and srcCls >= prevVal and pvInside >= barsPerBkt * 2 and pvFrom != 0
float eightyTgt = not eighty ? na : pvFrom > 0 ? prevVal : prevVah

// ═════════════════════════════════════════════════════════════════════════════════════════
//                         DEVELOPING PROFILE  (redrawn on the last bar)
// ═════════════════════════════════════════════════════════════════════════════════════════
if barstate.islast and inSes and curTpo.size() > 0 and not na(rowSz)
    // clear previous developing drawables
    while devBoxes.size() > 0
        box.delete(devBoxes.shift())
    while devLines.size() > 0
        line.delete(devLines.shift())
    while devLabs.size() > 0
        label.delete(devLabs.shift())

    [pocK, vaT, vaB, minK, maxK, tot] = f_stats(curTpo, vaPct)
    if not na(pocK)
        float pocC = curTpo.get(pocK)
        int   anchorT = profRight ? time + 2 * barMs : (na(sesT0) ? time : sesT0)
        int maxBkt = math.max(1, curBkt)
        bool deltaMode = rowColor == "Delta (buy/sell)"
        bool brktMode  = rowColor == "Bracket (time)"
        float maxAbsD = math.max(f_maxAbs(curDelta), 1.0)
        for k = minK to maxK
            float c = f_cnt(curTpo, k)
            if c > 0
                bool inVA = k <= vaT and k >= vaB
                int  w    = int(math.max(1.0, math.round(profWidth * c / math.max(pocC, 1.0))))
                color fillC = deltaMode ? color.from_gradient(nz(curDelta.get(k), 0.0), -maxAbsD, maxAbsD, colDSell, colDBuy) : brktMode ? color.from_gradient(nz(rowBkt.get(k), 0), 0, maxBkt, colBkt1, colBkt2) : (inVA ? colVA : colOut)
                color bc  = k == pocK ? colPOC : fillC
                int   op  = k == pocK ? 35 : (deltaMode or brktMode) ? (inVA ? 66 : 80) : (inVA ? 70 : 84)
                box b = box.new(anchorT, (k + 1) * rowSz, anchorT + w * barMs, k * rowSz, xloc = xloc.bar_time, border_color = color.new(bc, 65), bgcolor = color.new(bc, op))
                devBoxes.push(b)
                if showSP and c == 1.0
                    box sp = box.new(anchorT, (k + 1) * rowSz, anchorT + w * barMs, k * rowSz, xloc = xloc.bar_time, border_color = color.new(colSP, 40), bgcolor = color.new(colSP, 80))
                    devBoxes.push(sp)
        // developing excess / poor extremes
        int dTop = f_tailLen(curTpo, maxK, minK)
        int dBot = f_tailLen(curTpo, minK, maxK)
        if showPoor
            if dTop >= excessMin
                devLabs.push(label.new(time, (maxK + 1) * rowSz, "excess", xloc = xloc.bar_time, style = label.style_label_down, color = color.new(colExc, 25), textcolor = color.white, size = size.tiny))
            else if f_cnt(curTpo, maxK) >= poorMin
                devLabs.push(label.new(time, (maxK + 1) * rowSz, "poor high", xloc = xloc.bar_time, style = label.style_label_down, color = color.new(colSP, 30), textcolor = color.white, size = size.tiny))
            if dBot >= excessMin
                devLabs.push(label.new(time, minK * rowSz, "excess", xloc = xloc.bar_time, style = label.style_label_up, color = color.new(colExc, 25), textcolor = color.white, size = size.tiny))
            else if f_cnt(curTpo, minK) >= poorMin
                devLabs.push(label.new(time, minK * rowSz, "poor low", xloc = xloc.bar_time, style = label.style_label_up, color = color.new(colSP, 30), textcolor = color.white, size = size.tiny))
        int tL = na(sesT0) ? time : sesT0
        if showPOC
            devLines.push(line.new(tL, (pocK + 0.5) * rowSz, time, (pocK + 0.5) * rowSz, xloc = xloc.bar_time, color = colPOC, width = 2))
        if showVA
            devLines.push(line.new(tL, (vaT + 1) * rowSz, time, (vaT + 1) * rowSz, xloc = xloc.bar_time, color = color.new(colVAed, 25), style = line.style_dashed))
            devLines.push(line.new(tL, vaB * rowSz, time, vaB * rowSz, xloc = xloc.bar_time, color = color.new(colVAed, 25), style = line.style_dashed))
        if showIB and not na(ibHi) and not na(ibLo)
            devLines.push(line.new(tL, ibHi, time, ibHi, xloc = xloc.bar_time, color = color.new(colIB, 0), width = 1))
            devLines.push(line.new(tL, ibLo, time, ibLo, xloc = xloc.bar_time, color = color.new(colIB, 0), width = 1))
        // volume POC (developing)
        if showVPOC
            int vkD = f_pocOnly(curVol)
            if not na(vkD)
                devLines.push(line.new(tL, (vkD + 0.5) * rowSz, time, (vkD + 0.5) * rowSz, xloc = xloc.bar_time, color = color.new(colVPOC, 0), width = 2, style = line.style_dotted))
        // volume value area (developing) - value computed from volume, not time
        if showVVA
            [vpk, vvt, vvb, vmn, vmx, vtt] = f_stats(curVol, vaPct)
            if not na(vpk)
                devLines.push(line.new(tL, (vvt + 1) * rowSz, time, (vvt + 1) * rowSz, xloc = xloc.bar_time, color = color.new(colVPOC, 55), style = line.style_dotted))
                devLines.push(line.new(tL, vvb * rowSz, time, vvb * rowSz, xloc = xloc.bar_time, color = color.new(colVPOC, 55), style = line.style_dotted))
        // volume nodes: HVN (acceptance magnets) and LVN (thin, fast-move gaps)
        if showNodes
            float vmax = 0.0
            for k = minK to maxK
                vmax := math.max(vmax, f_cnt(curVol, k))
            if vmax > 0
                for k = minK to maxK
                    float vk2 = f_cnt(curVol, k)
                    if vk2 > 0
                        float vup = k < maxK ? f_cnt(curVol, k + 1) : 0.0
                        float vdn = k > minK ? f_cnt(curVol, k - 1) : 0.0
                        bool isHVN = vk2 >= nodeFrac * vmax and vk2 >= vup and vk2 >= vdn
                        bool isLVN = vk2 <= lvnFrac * vmax and vk2 <= vup and vk2 <= vdn and vup > 0 and vdn > 0
                        if isHVN
                            devLines.push(line.new(time - 3 * barMs, (k + 0.5) * rowSz, time, (k + 0.5) * rowSz, xloc = xloc.bar_time, color = color.new(colHVN, 0), width = 3))
                        else if isLVN
                            devLines.push(line.new(time - 3 * barMs, (k + 0.5) * rowSz, time, (k + 0.5) * rowSz, xloc = xloc.bar_time, color = color.new(colLVN, 25), width = 1, style = line.style_dotted))
        // 80% rule rotation target (far prior-value edge)
        if eighty and not na(eightyTgt)
            devLines.push(line.new(tL, eightyTgt, time, eightyTgt, xloc = xloc.bar_time, color = color.new(colComp, 0), width = 2, style = line.style_solid, extend = extend.right))
            devLabs.push(label.new(time, eightyTgt, " 80% target", xloc = xloc.bar_time, style = label.style_none, textcolor = color.new(colComp, 0), size = size.tiny))
        // prior-day value overlay, projected forward as reference levels
        if showPrior
            if not na(prevPoc)
                devLines.push(line.new(tL, prevPoc, time, prevPoc, xloc = xloc.bar_time, color = color.new(colPrior, 15), width = 1, extend = extend.right))
                devLabs.push(label.new(time, prevPoc, " yPOC", xloc = xloc.bar_time, style = label.style_none, textcolor = color.new(colPrior, 0), size = size.tiny))
            if not na(prevVah)
                devLines.push(line.new(tL, prevVah, time, prevVah, xloc = xloc.bar_time, color = color.new(colPrior, 45), style = line.style_dotted, extend = extend.right))
                devLabs.push(label.new(time, prevVah, " yVAH", xloc = xloc.bar_time, style = label.style_none, textcolor = color.new(colPrior, 30), size = size.tiny))
            if not na(prevVal)
                devLines.push(line.new(tL, prevVal, time, prevVal, xloc = xloc.bar_time, color = color.new(colPrior, 45), style = line.style_dotted, extend = extend.right))
                devLabs.push(label.new(time, prevVal, " yVAL", xloc = xloc.bar_time, style = label.style_none, textcolor = color.new(colPrior, 30), size = size.tiny))
        // composite (multi-day) value structure
        if showComposite and compTpo.size() > 0 and not na(compRowSz)
            [cpoc, cvt, cvb, cmn, cmx, ctt] = f_stats(compTpo, vaPct)
            if not na(cpoc)
                devLines.push(line.new(tL, (cpoc + 0.5) * compRowSz, time, (cpoc + 0.5) * compRowSz, xloc = xloc.bar_time, color = color.new(colComp, 0), width = 2, extend = extend.right))
                devLines.push(line.new(tL, (cvt + 1) * compRowSz, time, (cvt + 1) * compRowSz, xloc = xloc.bar_time, color = color.new(colComp, 55), style = line.style_dotted, extend = extend.right))
                devLines.push(line.new(tL, cvb * compRowSz, time, cvb * compRowSz, xloc = xloc.bar_time, color = color.new(colComp, 55), style = line.style_dotted, extend = extend.right))
                devLabs.push(label.new(time, (cpoc + 0.5) * compRowSz, " Cmp POC", xloc = xloc.bar_time, style = label.style_none, textcolor = color.new(colComp, 0), size = size.tiny))

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                       DASHBOARD
// ═════════════════════════════════════════════════════════════════════════════════════════
var table st = table.new(f_pos(tblPos), 2, 21, frame_width = 1, border_width = 1)
if showTable and barstate.islast
    color bgc    = chart.bg_color
    float luma   = na(bgc) ? 0.0 : color.r(bgc) * 0.299 + color.g(bgc) * 0.587 + color.b(bgc) * 0.114
    bool  darkUI = dashTheme == "Dark" ? true : dashTheme == "Light" ? false : (na(bgc) or luma < 140)
    color panelBg = darkUI ? color.rgb(17, 22, 28)    : color.rgb(244, 246, 248)
    color rowAlt  = darkUI ? color.rgb(25, 31, 39)    : color.rgb(232, 236, 240)
    color txtMain = darkUI ? color.white              : color.rgb(16, 20, 24)
    color txtSub  = darkUI ? color.rgb(154, 166, 178) : color.rgb(74, 82, 91)
    color frameC  = darkUI ? color.rgb(58, 70, 84)    : color.rgb(196, 204, 212)
    color upC     = darkUI ? color.new(colVAed, 0)    : color.rgb(14, 124, 90)
    color dnC     = darkUI ? color.new(colSP, 0)      : color.rgb(198, 40, 40)
    color hdr     = color.new(colVA, 0)
    table.set_bgcolor(st, panelBg)
    table.set_frame_color(st, frameC)
    table.set_border_color(st, frameC)

    [pocK, vaT, vaB, minK, maxK, tot] = f_stats(curTpo, vaPct)
    float pocP  = na(pocK) or na(rowSz) ? na : (pocK + 0.5) * rowSz
    float vahP  = na(vaT)  or na(rowSz) ? na : (vaT + 1) * rowSz
    float valP  = na(vaB)  or na(rowSz) ? na : vaB * rowSz
    float sesHi = na(maxK) or na(rowSz) ? na : (maxK + 1) * rowSz
    float sesLo = na(minK) or na(rowSz) ? na : minK * rowSz

    // profile shape, rotation factor, value-edge acceptance
    string shapeTxt = showShape ? f_shape(curTpo, pocK, minK, maxK) : "-"
    color  shapeCol = shapeTxt == "P (short-cover)" ? color.new(colVAed, 0) : shapeTxt == "b (long-liq.)" ? color.new(colSP, 0) : shapeTxt == "Double (trend)" ? color.new(colComp, 0) : txtMain
    color  rotCol = rotFactor > 2 ? upC : rotFactor < -2 ? dnC : txtMain
    float  veHitP = veOn and veN >= 10 ? veHit * 100.0 / veN : na
    float  veEdge = na(veHitP) ? na : veHitP - 50.0
    string veTxt = not veOn ? "off" : veN < 10 ? "warming (" + str.tostring(veN) + ")" : str.tostring(veHitP, "0") + "% / " + str.tostring(veEdge, "+0;-0") + " (" + str.tostring(veN) + ")"
    color  veCol = (not veOn or veN < 10 or na(veEdge)) ? txtSub : veEdge > 5 ? upC : veEdge < -5 ? dnC : txtMain

    // price vs developing value
    string posTxt = na(pocP) ? "-" : srcCls > vahP ? "above value" : srcCls < valP ? "below value" : "in value"
    color  posCol = na(pocP) ? txtSub : srcCls > vahP ? upC : srcCls < valP ? dnC : txtMain

    // value migration vs the prior completed session
    string migTxt = "-"
    color  migCol = txtSub
    int    migScore = 0
    if not na(vahP) and not na(prevVah) and not na(valP) and not na(prevVal)
        if valP > prevVah
            migTxt := "higher"
            migCol := upC
            migScore := 1
        else if vahP < prevVal
            migTxt := "lower"
            migCol := dnC
            migScore := -1
        else
            migTxt := "overlapping"
            migCol := txtMain

    // range extension vs initial balance
    string rext = "-"
    int    extScore = 0
    if not na(ibHi) and not na(ibLo) and not na(sesHi) and not na(sesLo)
        bool upExt = sesHi > ibHi
        bool dnExt = sesLo < ibLo
        rext := upExt and dnExt ? "both ways" : upExt ? "up" : dnExt ? "down" : "within IB"
        extScore := upExt and not dnExt ? 1 : dnExt and not upExt ? -1 : 0

    // day type (fuller taxonomy; large-range days are trend days in the dominant direction)
    string dtype = "-"
    color  dtypeCol = txtMain
    if not na(ibHi) and not na(ibLo) and not na(sesHi) and not na(sesLo)
        float ibW  = math.max(ibHi - ibLo, syminfo.mintick)
        float rngW = sesHi - sesLo
        bool both  = sesHi > ibHi and sesLo < ibLo
        float upX  = math.max(0.0, sesHi - ibHi)
        float dnX  = math.max(0.0, ibLo - sesLo)
        bool bigRange = rngW >= ibW * 2.5
        dtype := bigRange ? (upX >= dnX ? "trend up" : "trend down") : rngW <= ibW * 1.25 ? "balanced" : (both and rngW < ibW * 1.8) ? "neutral" : rngW >= ibW * 1.6 ? "normal" : "normal var"
        dtypeCol := dtype == "trend up" ? upC : dtype == "trend down" ? dnC : txtMain

    // open type (heuristic from the open and its excursions)
    string openType = "-"
    color  openCol = txtSub
    if not na(sesOpenPx) and not na(ibHi) and not na(ibLo)
        float ibW2 = math.max(ibHi - ibLo, syminfo.mintick)
        float netM = srcCls - sesOpenPx
        float minExc = math.min(nz(upExc), nz(dnExc))
        float maxExc = math.max(nz(upExc), nz(dnExc))
        bool drove = math.abs(netM) >= ibW2 and minExc <= ibW2 * 0.4
        bool revsd = minExc >= ibW2 * 0.6 and math.abs(netM) < maxExc * 0.5
        openType := drove ? (netM > 0 ? "drive up" : "drive down") : revsd ? "reject-reverse" : "auction"
        openCol  := drove ? (netM > 0 ? upC : dnC) : txtMain

    // TPO count (rotational factor): TPOs above vs below POC, single prints excluded
    [tpoAb, tpoBl] = f_tpoCount(curTpo, pocK, minK, maxK)
    float tpoSum = tpoAb + tpoBl
    string tpoTxt = tpoSum <= 0 ? "-" : str.tostring(int(tpoAb)) + " : " + str.tostring(int(tpoBl))
    color  tpoCol = tpoSum <= 0 ? txtSub : tpoAb > tpoBl * 1.2 ? upC : tpoBl > tpoAb * 1.2 ? dnC : txtMain

    // volume POC vs time POC divergence
    int vpocK = f_pocOnly(curVol)
    float vpocP = na(vpocK) or na(rowSz) ? na : (vpocK + 0.5) * rowSz
    string vpocTxt = na(vpocP) ? "-" : str.tostring(vpocP, format.mintick) + (na(pocP) ? "" : (math.abs(vpocP - pocP) <= rowSz * 1.5 ? " (aligned)" : vpocP > pocP ? " (>TPOC)" : " (<TPOC)"))
    color  vpocCol = (na(vpocP) or na(pocP)) ? txtSub : math.abs(vpocP - pocP) <= rowSz * 1.5 ? txtMain : color.new(colVPOC, 0)

    // volume value area vs TPO value area
    [vvk, vvtt, vvbb, vvmn, vvmx, vvtot] = f_stats(curVol, vaPct)
    float vvahP = na(vvtt) or na(rowSz) ? na : (vvtt + 1) * rowSz
    float vvalP = na(vvbb) or na(rowSz) ? na : vvbb * rowSz
    bool vvAligned = (not na(vvahP)) and (not na(vahP)) and math.abs(vvahP - vahP) <= rowSz * 1.5 and math.abs(vvalP - valP) <= rowSz * 1.5
    string vvaTxt = (na(vvahP) or na(vvalP)) ? "-" : str.tostring(vvahP, format.mintick) + " / " + str.tostring(vvalP, format.mintick) + (vvAligned ? " (aligned)" : " (shifted)")
    color  vvaCol = na(vvahP) or na(vahP) ? txtSub : vvAligned ? txtMain : color.new(colVPOC, 0)

    // 80% rule status
    string eightyTxt = eighty and not na(eightyTgt) ? "active to " + str.tostring(eightyTgt, format.mintick) : (pvInside > 0 and not na(prevVah)) ? "building (" + str.tostring(pvInside) + "b)" : "-"
    color  eightyCol = eighty ? color.new(colComp, 0) : txtSub

    // failed auction vs prior-day value
    string failTxt = "-"
    color  failCol = txtSub
    if brokeAbove and not na(prevVah) and srcCls < prevVah
        failTxt := "failed high"
        failCol := dnC
    else if brokeBelow and not na(prevVal) and srcCls > prevVal
        failTxt := "failed low"
        failCol := upC

    // composite bias (price location + value migration + range extension)
    int bull = (na(pocP) ? 0 : srcCls > vahP ? 1 : srcCls < valP ? -1 : 0) + migScore + extScore
    string biasTxt = bull >= 2 ? "Bullish" : bull <= -2 ? "Bearish" : bull == 1 ? "Lean bull" : bull == -1 ? "Lean bear" : "Balanced"
    color  biasCol = bull >= 2 ? upC : bull <= -2 ? dnC : bull == 1 ? color.new(upC, 30) : bull == -1 ? color.new(dnC, 30) : txtMain
    color  biasBg  = bull >= 2 ? color.new(colVAed, 78) : bull <= -2 ? color.new(colSP, 78) : rowAlt

    int nakedN = 0
    if npFilled.size() > 0
        for i = 0 to npFilled.size() - 1
            if not npFilled.get(i)
                nakedN += 1

    // composite (multi-day) POC for the dashboard
    string compTxt = "-"
    color  compCol = txtSub
    if showComposite and compTpo.size() > 0 and not na(compRowSz)
        int cpk = f_pocOnly(compTpo)
        if not na(cpk)
            compTxt := str.tostring((cpk + 0.5) * compRowSz, format.mintick)
            compCol := color.new(colComp, 0)

    table.cell(st, 0, 0, "TPO AUCTION", text_color = color.white, bgcolor = hdr, text_size = size.tiny)
    table.cell(st, 1, 0, inSes ? "LIVE" : "closed", text_color = color.white, bgcolor = hdr, text_size = size.tiny)
    table.cell(st, 0, 1, "Bias", text_color = txtMain, bgcolor = biasBg, text_size = size.tiny)
    table.cell(st, 1, 1, biasTxt, text_color = biasCol, bgcolor = biasBg, text_size = size.tiny)
    table.cell(st, 0, 2, "Open type", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
    table.cell(st, 1, 2, openType, text_color = openCol, bgcolor = panelBg, text_size = size.tiny)
    table.cell(st, 0, 3, "Price vs value", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(st, 1, 3, posTxt, text_color = posCol, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(st, 0, 4, "Value vs prior", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
    table.cell(st, 1, 4, migTxt, text_color = migCol, bgcolor = panelBg, text_size = size.tiny)
    table.cell(st, 0, 5, "Day type", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(st, 1, 5, dtype, text_color = dtypeCol, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(st, 0, 6, "Range ext.", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
    table.cell(st, 1, 6, rext, text_color = txtMain, bgcolor = panelBg, text_size = size.tiny)
    table.cell(st, 0, 7, "TPO count (a:b)", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(st, 1, 7, tpoTxt, text_color = tpoCol, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(st, 0, 8, "Failed auction", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
    table.cell(st, 1, 8, failTxt, text_color = failCol, bgcolor = panelBg, text_size = size.tiny)
    table.cell(st, 0, 9, "POC (time)", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(st, 1, 9, na(pocP) ? "-" : str.tostring(pocP, format.mintick), text_color = color.new(colPOC, 0), bgcolor = rowAlt, text_size = size.tiny)
    table.cell(st, 0, 10, "VAH / VAL", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
    table.cell(st, 1, 10, (na(vahP) ? "-" : str.tostring(vahP, format.mintick)) + " / " + (na(valP) ? "-" : str.tostring(valP, format.mintick)), text_color = txtMain, bgcolor = panelBg, text_size = size.tiny)
    table.cell(st, 0, 11, "POC (volume)", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(st, 1, 11, vpocTxt, text_color = vpocCol, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(st, 0, 12, "Initial balance", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
    table.cell(st, 1, 12, (na(ibHi) ? "-" : str.tostring(ibHi, format.mintick)) + " / " + (na(ibLo) ? "-" : str.tostring(ibLo, format.mintick)), text_color = color.new(colIB, 0), bgcolor = panelBg, text_size = size.tiny)
    table.cell(st, 0, 13, "Naked POCs", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(st, 1, 13, str.tostring(nakedN), text_color = color.new(colNP, 0), bgcolor = rowAlt, text_size = size.tiny)
    table.cell(st, 0, 14, "Composite POC", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
    table.cell(st, 1, 14, compTxt, text_color = compCol, bgcolor = panelBg, text_size = size.tiny)
    table.cell(st, 0, 15, "Vol value", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(st, 1, 15, vvaTxt, text_color = vvaCol, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(st, 0, 16, "80% rule", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
    table.cell(st, 1, 16, eightyTxt, text_color = eightyCol, bgcolor = panelBg, text_size = size.tiny)
    table.cell(st, 0, 17, "Profile shape", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(st, 1, 17, shapeTxt, text_color = shapeCol, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(st, 0, 18, "Rotation factor", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
    table.cell(st, 1, 18, str.tostring(rotFactor), text_color = rotCol, bgcolor = panelBg, text_size = size.tiny)
    table.cell(st, 0, 19, "VA-edge fade", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(st, 1, 19, veTxt, text_color = veCol, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(st, 0, 20, "Session", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
    table.cell(st, 1, 20, f_hm(prevOpenMin) + "-" + f_hm(prevCloseMin), text_color = txtMain, bgcolor = panelBg, text_size = size.tiny)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                          ALERTS
// ═════════════════════════════════════════════════════════════════════════════════════════
[pocKa, vaTa, vaBa, minKa, maxKa, tota] = f_stats(curTpo, vaPct)
float vahA = na(vaTa) or na(rowSz) ? na : (vaTa + 1) * rowSz
float valA = na(vaBa) or na(rowSz) ? na : vaBa * rowSz
bool xAccept = ta.crossover(srcCls, vahA)
bool xReject = ta.crossunder(srcCls, valA)
alertcondition(not na(vahA) and xAccept, "Accept above value", "TPO Auction: close accepted above the value-area high")
alertcondition(not na(valA) and xReject, "Reject below value",  "TPO Auction: close rejected below the value-area low")
bool failHi = brokeAbove and not na(prevVah) and srcCls < prevVah and srcCls[1] >= prevVah
bool failLo = brokeBelow and not na(prevVal) and srcCls > prevVal and srcCls[1] <= prevVal
alertcondition(failHi, "Failed auction high", "TPO Auction: failed breakout above prior-day value")
alertcondition(failLo, "Failed auction low",  "TPO Auction: failed breakdown below prior-day value")
bool eightyTrig = eighty and not (eighty[1])
alertcondition(eightyTrig, "80% rule active", "TPO Auction: price accepted back inside prior value - 80% rule favours rotation to the far edge")
alertcondition(veRejNow, "Value-edge rejection", "TPO Auction: a tag of prior-day value rejected back toward POC (responsive fade played out)")
alertcondition(endSes, "Session profile complete", "TPO Auction: session profile completed")
````
