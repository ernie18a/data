<!-- tradingview-pine-id: PUB;a0389df26d2f4705a9ee33b40f9c3a90 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# MarketMaulers Volume Profile

Source: https://www.tradingview.com/script/1spDPQWg-MarketMaulers-Volume-Profile/

## Description

MarketMaulers Volume Profile is a volume profile that tells you how accurate it is.

Price tells you where the market went. Volume tells you where it mattered. A profile splits the window into horizontal rows and measures how much traded inside each one, so you can see where the auction did business and where it merely passed through. That part every profile tool does. This one adds the number none of them report.

THE ACCURACY PROBLEM NOBODY MENTIONS
A profile needs to know where INSIDE each bar the volume traded. On a 5m chart a single bar might cover twenty points, and dumping all of its volume at one price would be a lie.

So the tool requests intrabar data and distributes each bar's volume across the prices it actually visited. But TradingView limits how far back intrabar data reaches and how much a script may request. Past that limit the request comes back EMPTY. No error, no warning. Every volume profile then falls back to bar level volume, meaning the whole bar's volume at one price.

Most tools do this silently. The profile still draws, it just quietly becomes a sketch.

This one reports it. Two rows: how many bars used real intrabar distribution, and how many used the crude fallback. A profile that is mostly fallback is a rough sketch. One that is mostly intrabar is a measurement. Now you know which one you are looking at.

WHAT IT DRAWS
• VPOC. The row that traded the most volume, the fairest price the auction found
• Value Area. The band holding 70% of the window's volume by default, with VAH and VAL as its edges
• HVN and LVN. The shelves where price lingered and the air pockets it ran through
• Naked VPOC. A prior session's point of control that price has never traded back to

THREE WINDOWS
• Session. One trading auction, resetting daily. The default, and the one that matches how a day actually trades.
• Fixed lookback. A set number of bars. Stable and repeatable.
• Visible range. Whatever is on your screen, moving as you pan. Useful for exploring, and it moves by design.

IT TELLS YOU WHEN A SETTING DID NOT TAKE
Two settings can quietly mean something other than what you set.

Session mode needs your chart timeframe to fit inside a session. Set it on a 4H chart and a session spans days.

Ticks per row is a REQUEST. A wide window at a fine row height would need more rows than a script is allowed to draw, so the tool coarsens them. Ask for 20 ticks per row on a wide window and you might get 101.

A setting that quietly means something else is worse than one that is plainly wrong, because nothing tells you to look. So the panel defaults to Auto: hidden until something has actually diverged, then it appears with the offending row flagged. Quiet in normal use, loud exactly when it matters.

ALERTS
Three toggles, all off by default, produce five alert conditions: VPOC touch, VAH touch, VAL touch, Value Area edge touch, and naked VPOC touch.

Each one compares price against the PREVIOUS bar's level, so a level that moves onto price cannot fire by itself. Only price reaching the level fires it. The code for that is three lines and you can go read them.

These are LOCATION alerts, not signals. They tell you price has arrived somewhere structurally interesting. They make no claim about what happens next.

WHY IT DOES NOT REPAINT
A profile is a snapshot of the window it measured, rebuilt on the last bar. Nothing historical is rewritten and nothing is read from the future. There is no request.security anywhere in the script, so there is no lookahead question to answer. The one data request is request.security_lower_tf, which reads bars already inside the current one.

Visible range mode moves with your viewport because that is what you asked it to do, which is the mode working as designed rather than the tool repainting.

READ THE CODE
This one is published open source, so nothing above is a claim you have to take on trust. The header comment is written for exactly that: it states every convention the tool chose where no published source settles the question, and it says why.

• The value area expands ONE ROW AT A TIME from the VPOC, taking the heavier neighbour, and it INCLUDES the row that crosses the threshold. CQG, Sierra Chart and TradingView all add one row at a time. The Dalton books print a two row pair method instead. The original CBOT Liquidity Data Bank tables land between 70.3 and 73.7%, never under 70, which is why the crossing row is included.
• VAH sits at the TOP edge of the highest value area row and VAL at the BOTTOM edge of the lowest, so the band genuinely contains its rows. No vendor documents whether their line is the row's edge or its middle. This one does.
• The VPOC prints at its row's MIDPOINT, and ties go to the row nearest the profile's middle, with equidistant going to the lower row.
• A naked VPOC dies when a later bar's RANGE touches it, not on a close through, and the session that formed it never counts against itself.
• The 70% is a share of TOTAL VOLUME. Not of range, not of bars.

Disagree with any of those and the file is right there. That is the point of publishing it this way.

MADE TO FIT YOUR CHART
Window · Volume Engine · Profile · Value Area · Nodes and Naked VPOC · Style · Diagnostics · Alerts. Every element toggles independently, and every colour, size and position is exposed, the panel included. The defaults suit a dark chart.

HOW TRADERS ACTUALLY USE IT
Read the VPOC as the session's fair price and the value area edges as the boundary between acceptance and rejection. Price leaving the value area and holding outside is an auction trying to find business elsewhere. Price rejecting the edge and returning to the VPOC is the auction saying it already found it.

The LVNs are where the useful trades hide. An air pocket is a price range the market refused to do business in, so price tends to cross it quickly rather than grind. A naked VPOC on the other side of one is a magnet with nothing in the way.

Check the two accuracy rows first. A profile built mostly from the fallback still shows you the shape, but the exact VPOC row is a rounder number than it looks. Fix it with a shallower window or a lower chart timeframe, never by hiding the number.

WHAT IT WILL NOT CLAIM
You will not find a hit rate here for how often price returns to a VPOC, or how quickly an LVN gets crossed. Nobody has measured those on your instrument, your timeframe, and a sample worth the name.

It also will not tell you the value area is one standard deviation. That story is a hedged analogy, not a computation. This algorithm builds a modal, highest density region anchored on the POC. Mean plus or minus one sigma is a different object anchored on the mean. They agree only on symmetric profiles, which is to say not on the trend days profiling exists to identify.

Terms belonging to time based Market Profile, meaning single prints, tails, excess, poor highs and lows and day types, are not used here. They reference 30 minute sub periods a volume profile does not have. An LVN is the honest analogue of a single print.

This tool shows you the structure. What you do with it is yours.

Works on any market and any timeframe, though intrabar accuracy is best on liquid futures and on recent history.

Display only. This measures where volume traded, it does not fire buy/sell signals and it does not forecast. Educational tool, not financial advice.

Published OPEN SOURCE. The intrabar distribution engine, the row budget coarsening, the value area expansion, the naked VPOC carry forward and the divergence checks are all readable in the script, and the header comment documents the reasoning behind every one of them. Read it, check it, and change it if you disagree.

---

## Source Code

````pine
//@version=6
// ═══════════════════════════════════════════════════════════════════════
//  MarketMaulers Volume Profile  ·  v2.5
//  v2.5. THE STATS PANEL BECOMES A WARNING LIGHT, AND GETS ITS SETTINGS.
//    Two problems, one change. The panel reads like a diagnostic and has no
//    business sitting on every chart. But the v2.1 note below it is also right:
//    it exists because Row height and Range mode can SILENTLY differ from what
//    you set, and a default-off panel means the next 101-ticks-instead-of-20
//    goes unnoticed.
//    So it is three modes, not a toggle:
//      AUTO (default): invisible until something has actually diverged, then it
//        appears and says which setting is not what you asked for. Quiet in normal
//        use, loud exactly when the v2.1 comment says it needs to be.
//      ALWAYS: the old behaviour, for anyone who wants the readout up.
//      OFF: never draws.
//    MAX CUSTOMIZATION. All 13 cells were hardcoded:
//    white, gray, black, orange, with position pinned to top_right and size to
//    tiny, and zero inputs. This was the worst offender in the suite. Position,
//    text size and every colour are now exposed. If it can appear, it is yours.
//    Table position is fixed at creation in Pine, so changing Position takes a
//    chart refresh. Standard across the suite.
//  ────────────────────────────
//  v2.4: THE WINDOW GAINS A RIGHT EDGE. Every loop that built the profile ran
//  from the CURRENT bar back (`0 to nb`), so the window only ever had a left
//  edge. Two consequences, both silent:
//   · `Sessions back = 1` profiled yesterday's session **plus everything traded
//     since**. Yesterday's supposedly-settled VPOC/VAH/VAL drifted all day,
//     which is exactly what that setting exists to prevent.
//   · Visible-range mode leaked the same way. v2.0 had already worked out that
//     it needs to honour the rightmost visible bar and computed `endOff` for
//     precisely that, then never used it downstream. The value was calculated
//     and thrown away.
//  Fixed with `nbEnd`, the window's right edge as a bar offset: the target
//  session's last bar in Session mode, the rightmost visible bar in Visible
//  range, 0 in Fixed lookback. Every window loop now runs `nbEnd..nb` and the
//  level lines anchor to the window's own last bar instead of to "now".
//  Found 2026-08-10 while porting this session walk into MM Market Profile
//  (TPO), where the same hole was caught and fixed at build time.
//  `Sessions back = 0` and Fixed lookback were never affected, which is why
//  this survived three versions and a compile.
//  ────────────────────────────
//  A horizontal volume histogram over a price window: how much volume traded
//  at each price, with the VPOC (Volume Point of Control) and the Value Area
//  (VAH / VAL) that bound the chosen share of volume around it.
//
//  WHO THIS IS FOR: anyone who wants volume-at-price on a chart that does not
//  already carry a built-in volume profile, and anyone who would rather read the
//  calculation than take it on trust. Every convention it uses is stated in this
//  header, and every constant is either an input or listed below with its reason.
//
//  ─── v2.0, research-driven rebuild (2026-07-30) ───
//  VERIFIED AND UNCHANGED FROM v1.0: these were already right:
//   · Value Area expands ONE ROW AT A TIME from the VPOC, taking the heavier
//     neighbour. The Dalton books print a two-row PAIR method, but CQG, Sierra
//     Chart and TradingView all add one row at a time. Sierra ships the pair
//     method as a non-default toggle. We match the platforms.
//   · The threshold-crossing row is INCLUDED, so the VA lands at or just over
//     the target. This matches the primary literature: the original CBOT
//     Liquidity Data Bank tables run 70.3 to 73.7%, never under 70. Some
//     implementations stop BEFORE exceeding the target instead, which lands the
//     value area just under 70 rather than just over.
//   · 70% is a share of TOTAL VOLUME, not of range, not of bars.
//
//  WHAT'S NEW:
//   · SESSION scope (now the default). Session profiles are the intraday
//     standard because they reset with the auction and yesterday's VAH/VAL/POC
//     are levels other participants are also watching. A visible-range profile
//     changes every time you scroll, so its levels can't be marked or traded.
//   · TICKS-PER-ROW mode (now the default). Fixed row COUNT makes row height
//     depend on the window's price span, so a 100-point day and a 400-point day
//     produce non-comparable profiles. Fixed row SIZE keeps levels on stable
//     price increments. Both real futures platforms (Sierra, NinjaTrader) chose
//     ticks-per-row for exactly this reason.
//   · INTRABAR volume distribution via request.security_lower_tf(), with an
//     automatic fall back to bar-level spreading. See the ENGINE note below.
//   · NAKED VPOCs: prior sessions' POCs that price has not returned to. Absent
//     from every major platform built-in and one of the most-marked levels in
//     futures. Our test is stated, because no two sources agree on it.
//   · HVN / LVN node detection using Sierra Chart's peak/valley rule: the only
//     published algorithm that exists for this. v1.0's guide described nodes the
//     tool never computed.
//   · plot() outputs so VPOC/VAH/VAL reach the Data Window, screeners and other
//     scripts, plus alerts on level touches. No platform built-in has alerts.
//
//  FIXED IN v2.0:
//   · Visible-range mode ignored the right edge and assumed the last bar was
//     the rightmost visible one. TradingView's own docs say the opposite:
//     "We can never assume the rightmost visible bar is also the last bar."
//     Scrolled far enough right, the profile could collapse to a single bar.
//   · The up/down split was documented as "up-closes vs down-closes" but
//     classified on close-vs-OPEN, and counted a doji as UP.
//   · The VPOC highlight only existed in unsplit mode, while split is the
//     DEFAULT, so out of the box the guide promised a gold row that never drew.
//   · A flat window (rHi == rLo) silently drew nothing at all.
//
//  ─── ENGINE: how volume gets into rows, and what that costs ───
//  Pine gives one volume number per bar, but a bar spans a price range. Every
//  Pine volume profile is therefore an approximation, and the approximation
//  chosen IS the accuracy of the tool. Two tiers, automatic:
//   1. INTRABAR (preferred): pull lower-timeframe bars inside each chart bar
//      and spread each intrabar's volume across the rows it touches. A 1m NQ
//      bar usually spans 1 to 3 rows, so the error nearly vanishes. This is what
//      TradingView's own profile does.
//   2. BAR-LEVEL (fallback): spread the chart bar's own volume across the rows
//      spanned by its high and low, weighted by overlap. Cheaper and always available,
//      but it flattens real concentration and drifts toward a time-at-price
//      shape.
//  The intrabar cap is TIERED and Premium is NOT privileged: Basic, Essential,
//  Plus and Premium all get 100K intrabars; Expert 125K; Ultimate 200K. Past
//  that horizon the request returns an EMPTY ARRAY: no error, no warning. That
//  silent degradation is why the fallback branch is mandatory and why the stats
//  table reports how many bars used which tier. Trust the number.
//
//  ─── CONVENTIONS WE CHOSE (no source settles these: stated, not hidden) ───
//   · VAH sits at the TOP edge of the highest value-area row and VAL at the
//     BOTTOM edge of the lowest, so the value area genuinely contains its rows.
//     No vendor documents whether their line is the row's edge or its middle.
//   · VPOC prints at its row's MIDPOINT.
//   · VPOC ties go to the row closest to the profile's midpoint (CQG, Sierra
//     Chart and mypivots all agree); equidistant goes to the lower row.
//   · A naked VPOC dies when a later bar's RANGE touches it (vendors use range
//     intersection, not a close-through), and the session that formed it never
//     counts against itself.
//
//  ─── WHAT THIS TOOL DELIBERATELY DOES NOT CLAIM ───
//  The "70% ≈ one standard deviation" story is Dalton's hedged analogy, not a
//  computation. Steidlmayer's own book never uses the phrase, and the "70% is
//  a rounded 68.27%" derivation traces to no primary source. This algorithm
//  builds a modal, highest-density region anchored on the POC; mean ± 1σ is a
//  different object anchored on the mean. They agree only on symmetric profiles,
//  which is to say, not on the trend days profiling exists to identify.
//  Terms belonging to TIME-based Market Profile (single prints, tails, excess,
//  poor highs/lows, day types) are NOT used here: they reference 30-minute
//  sub-periods a volume profile does not have. An LVN is the honest analogue of
//  a single print.
//
//  Display only. NO buy/sell signals. VPOC/VAH/VAL are reference levels
//  (magnets and fair-value edges), not trade calls.
//
//  Non-repaint: the profile is a SNAPSHOT of its window, rebuilt on the last
//  bar. No historical bar is ever rewritten; nothing is read from the future.
//
//  Built by Market Maulers  ·  Free forever
// ═══════════════════════════════════════════════════════════════════════
indicator("MarketMaulers Volume Profile", shorttitle="MM VProfile", overlay=true,
     max_boxes_count=500, max_lines_count=500, max_labels_count=500, max_bars_back=5000)


// ═══════════════════════════════════════════════════════════════════════
//  LOCKED CALIBRATION (v2.0): constants, deliberately NOT inputs
// ═══════════════════════════════════════════════════════════════════════
int   GAP        = 2        // bars between the last candle and the profile's left edge
color COL_NONE   = #ffffff00
int   MAX_ROWS   = 150      // hard row ceiling. Box-per-row against a 500-box budget,
                            // leaving ~350 objects for levels, nodes and naked VPOCs.
int   MAX_SESS   = 20       // most prior sessions retained for naked-VPOC tracking
float SENTINEL   = -1.0     // "this side is exhausted" marker in the VA walk
// The profile draws to the RIGHT of price (in the future offset zone) so it never
// buries the candles. bar_index coords allow ~500 future bars. GAP + Profile
// Width + the label pad stays well under that.


// ═══════════════════════════════════════════════════════════════════════
//  INPUTS
// ═══════════════════════════════════════════════════════════════════════
string GRP_W = "Window"
string GRP_E = "Volume Engine"
string GRP_P = "Profile"
string GRP_V = "Value Area"
string GRP_N = "Nodes & Naked VPOC"
string GRP_S = "Style"
string GRP_D = "Diagnostics"
string GRP_A = "Alerts"

// ── Window ──
string rangeMode = input.string("Session", "Range Mode",
     options=["Session","Fixed lookback (N bars)","Visible range"], group=GRP_W,
     tooltip="What stretch of chart the profile measures.\n\nSession (default): profiles one trading session, resetting with the auction. This is the intraday standard, and it's the only mode whose levels are REPRODUCIBLE: your VPOC is the same one everyone else running a session profile sees, which is what makes it a level worth marking.\n\nFixed lookback: the last N bars. Stable and reproducible, but the window has no relationship to the auction.\n\nVisible range: exactly what's on screen. Recomputes every time you scroll or zoom, so the levels move with your viewport. Useful for studying a specific stretch; a poor source of levels to trade against tomorrow.")
string sessWin   = input.session("0930-1600", "  Session window (ET)", group=GRP_W,
     tooltip="The session to profile, in New York time. 09:30 to 16:00 is the RTH cash session.\n\nWhy RTH rather than the full 23-hour futures day: overnight volume on NQ is thin and algo-dominated, and folding it in drags the VPOC toward prices almost nobody transacted at in size. Widen this to 1800-1700 if you want the full Globex profile.")
int    sessBack  = input.int(0, "  Sessions back (0 = current)", minval=0, maxval=10, group=GRP_W,
     tooltip="0 profiles the session in progress. 1 profiles yesterday's completed session, 2 the day before, and so on: useful when you want a finished profile whose levels are settled rather than one still developing.")
int    lookback  = input.int(300, "Lookback (bars)", minval=10, maxval=2000, group=GRP_W,
     tooltip="Bars to profile in Fixed-lookback mode.")
int    maxBars   = input.int(500, "Max bars scanned (cap)", minval=50, maxval=2000, group=GRP_W,
     tooltip="Hard ceiling on bars scanned in ANY mode. This is the guard against a huge visible range blowing the execution budget, and that budget is 20 seconds on a Basic account, which is exactly who this tool is for. Lower it if the script feels heavy.")

// ── Volume Engine ──
bool   useLtf    = input.bool(true, "Use intrabar data (more accurate)", group=GRP_E,
     tooltip="ON: pulls lower-timeframe bars inside each chart bar and places their volume at the prices they actually traded. Substantially more accurate, and it's how TradingView's own profile works.\n\nOFF: spreads each chart bar's volume across its own high-to-low range. Less precise, but it uses no data requests at all, behaves identically on every TradingView plan, and can never silently run out.\n\nTurn this OFF if the script errors, feels slow, or if the stats table shows most bars falling back anyway.")
string ltfMode   = input.string("Auto", "  Intrabar timeframe", options=["Auto","1 min","5 min","15 min"], group=GRP_E,
     tooltip="Auto targets roughly 10 to 20 intrabars per chart bar, which is the sweet spot between accuracy and burning through the intrabar budget. Pick manually only if you know what you're doing.")
int    ltfDepth  = input.int(300, "  Intrabar depth (bars)", minval=20, maxval=1000, group=GRP_E,
     tooltip="How many recent bars use intrabar data. Older bars in the window fall back to bar-level spreading.\n\nThis exists because reaching back into intrabar history costs memory per bar. 300 is a safe balance. If the stats table shows a large fallback count, either lower the window or accept the approximation: do not just raise this until it breaks.")

// ── Profile ──
string rowMode   = input.string("Ticks per row", "Row sizing", options=["Ticks per row","Number of rows"], group=GRP_P,
     tooltip="Ticks per row (default): every row is a fixed number of ticks tall, so a row means the same thing on a quiet day and a wild one, and your levels land on stable price increments. Both dedicated futures platforms chose this.\n\nNumber of rows: the window's range is cut into N equal slices, so row height silently changes with volatility and two sessions aren't comparable. Better only when you want a consistent-looking histogram regardless of range.")
int    ticksRow  = input.int(20, "  Ticks per row", minval=1, maxval=500, group=GRP_P,
     tooltip="Row height in ticks. On NQ (0.25/tick) 20 ticks = 5 points per row, which is a readable granularity for a session profile. Halve it for finer detail, at the cost of more rows.")
int    nBins     = input.int(24, "  Number of rows", minval=6, maxval=150, group=GRP_P,
     tooltip="Rows to slice the range into, when Row sizing is set to Number of rows. Capped at 150: beyond that a box-per-row profile starts competing with the levels and nodes for TradingView's 500-drawing budget.")
int    profW     = input.int(60, "Profile width (bars)", minval=10, maxval=200, group=GRP_P,
     tooltip="On-screen width of the LONGEST row; every other row scales proportionally. Purely visual.")
bool   splitVol  = input.bool(true, "Split up/down volume", group=GRP_P,
     tooltip="Colors each row by volume that traded on up bars vs down bars.\n\nREAD THIS: this is NOT buy/sell volume. Real buy/sell classification needs bid-ask trade data that Pine cannot see on any plan below Premium. This is direction-inferred: an approximation, exactly like TradingView's own up/down split. Scripts that label this 'buying and selling volume' are overstating what the data supports.")

// ── Value Area ──
float  vaPct     = input.float(70, "Value Area %", minval=30, maxval=95, step=1, group=GRP_V,
     tooltip="Share of TOTAL VOLUME the value area must contain, expanded outward from the VPOC.\n\n70% is the convention every major platform defaults to. NinjaTrader ships 68% instead and calls it one standard deviation, that framing is a later analogy, not how the number was derived, so treat 70 as convention rather than mathematics. The difference is usually one row.")
bool   showPOC   = input.bool(true, "Show VPOC line", group=GRP_V)
bool   showVA    = input.bool(true, "Show VAH / VAL lines", group=GRP_V)
string extMode   = input.string("Both", "Extend levels", options=["Across window","Right to price","Both"], group=GRP_V,
     tooltip="Across window: levels run back over the bars they were measured from. Right to price: levels run forward to the current bar, which is what you want if you're trading against them. Both draws the full span.")

// ── Nodes & Naked VPOC ──
bool   showNodes = input.bool(true, "Mark HVN / LVN nodes", group=GRP_N,
     tooltip="High and Low Volume Nodes: rows that are a local peak or trough in the volume distribution. HVNs are prices the market accepted and tends to grind in; LVNs are prices it rejected and tends to travel through fast.\n\nThe detection is Sierra Chart's published peak/valley rule, which is the only real algorithm in print for this. Everyone else either eyeballs it or invents a threshold.")
int    nodeSens  = input.int(2, "  Node sensitivity (rows)", minval=1, maxval=10, group=GRP_N,
     tooltip="How many rows either side must be lower (for a peak) or higher (for a valley) to qualify. Higher = fewer, more significant nodes.")
bool   showNaked = input.bool(true, "Track naked VPOCs", group=GRP_N,
     tooltip="A naked (or virgin) VPOC is a prior session's point of control that price has NEVER returned to. They act as magnets, and no major platform's built-in profile marks them.\n\nOur test, stated because no two sources agree: a naked VPOC dies when any later bar's RANGE touches it: a wick counts, a close is not required. The session that formed it never counts against itself. Levels are tracked across sessions regardless of the hour, not RTH-only.")
int    nakedBack = input.int(10, "  Sessions to track", minval=1, maxval=20, group=GRP_N,
     tooltip="How many prior sessions' VPOCs to keep watching. Untouched ones stay on the chart; touched ones are dropped.")
bool   nakedRth  = input.bool(true, "  Test during session hours only", group=GRP_N,
     tooltip="Which trades count as 'price came back'.\n\nON (default): only trade inside your session window can retire a naked VPOC. This is the futures convention, and it's what makes the feature useful: NQ trades ~23 hours, so counting thin overnight rotation kills almost every level within a day or two and you end up with nothing on the chart.\n\nOFF: any trade at any hour retires it. Stricter, fewer surviving levels, and the reading some sources use.\n\nThe sources genuinely disagree on this one, which is why it's a switch rather than a decision we made for you.")

// ── Style ──
color  upCol     = input.color(color.new(#26a69a, 30), "Up volume", group=GRP_S, inline="ud")
color  dnCol     = input.color(color.new(#ef5350, 30), "Down volume", group=GRP_S, inline="ud")
color  neutCol   = input.color(color.new(#5b9cf6, 35), "Volume (unsplit)", group=GRP_S)
color  pocCol    = input.color(#f5a800, "VPOC", group=GRP_S,
     tooltip="Point-of-Control accent: the one warm colour in the palette, so the eye finds it first.")
color  vaEdge    = input.color(color.new(#b2b5be, 20), "VAH / VAL", group=GRP_S)
color  hvnCol    = input.color(color.new(#26a69a, 0), "HVN", group=GRP_S, inline="nd")
color  lvnCol    = input.color(color.new(#ef5350, 0), "LVN", group=GRP_S, inline="nd")
color  nakedCol  = input.color(color.new(#f5a800, 40), "Naked VPOC", group=GRP_S)
int    fadeOut   = input.int(62, "Outside-VA fade %", minval=40, maxval=90, group=GRP_S,
     tooltip="Extra transparency on rows outside the value area, so the value area reads first.")

// ── Diagnostics ──
// v2.5: this panel's whole job is telling you when a setting quietly meant
// something else. Auto keeps it out of the way until that happens.
string statsMode = input.string("Auto", "Settings panel", options=["Auto","Always","Off"], group=GRP_D,
     tooltip="Reports the row count, the achieved value-area percentage, and how many bars used intrabar data versus the bar-level fallback.\n\nAUTO (default): stays hidden until a setting has SILENTLY DIVERGED from what you asked for: the row height got coarsened, Session fell back on a high timeframe, or intrabar data was unavailable and it used bar-level volume. Then it appears and flags the row in the warning colour.\n\nALWAYS: keep it up permanently.\n\nOFF: never draw it. Note that turning it off also turns off the warning, so a profile built on coarser rows than you set will look correct and say nothing.")
string stPos     = input.string("Top Right", "  Position", options=["Top Right","Middle Right","Bottom Right","Top Left","Bottom Left"], group=GRP_D,
     tooltip="Pine fixes a table's position when it is created, so changing this takes a chart refresh to show.")
string stSz      = input.string("Tiny", "  Text size", options=["Tiny","Small","Normal"], group=GRP_D)
color  stBgA     = input.color(color.new(color.black, 20), "  Header / row background", inline="d1", group=GRP_D)
color  stBgB     = input.color(color.new(color.black, 40), "", inline="d1", group=GRP_D)
color  stKey     = input.color(color.gray, "  Key / value / warning", inline="d2", group=GRP_D)
color  stVal     = input.color(color.white, "", inline="d2", group=GRP_D)
color  stWarn    = input.color(color.orange, "", inline="d2", group=GRP_D,
     tooltip="Key text, value text, and the colour a value turns when that setting is not what you asked for.")

f_stPos() =>
    stPos == "Top Right" ? position.top_right :
     stPos == "Middle Right" ? position.middle_right :
     stPos == "Bottom Right" ? position.bottom_right :
     stPos == "Top Left" ? position.top_left : position.bottom_left

f_stSz() =>
    stSz == "Normal" ? size.normal : stSz == "Small" ? size.small : size.tiny

// ── Alerts ──
bool   alPoc     = input.bool(false, "Alert on VPOC touch", group=GRP_A)
bool   alVa      = input.bool(false, "Alert on VAH / VAL touch", group=GRP_A)
bool   alNaked   = input.bool(false, "Alert on naked VPOC touch", group=GRP_A,
     tooltip="Fires when price reaches a prior session's untouched point of control.")


// ═══════════════════════════════════════════════════════════════════════
//  GLOBALS: ta.*/request.* must live at global scope and run EVERY bar.
// ═══════════════════════════════════════════════════════════════════════
float tick = syminfo.mintick

// Session membership. Session mode needs the boundary; naked-VPOC tracking needs
// it in every mode, so this is computed unconditionally.
bool inSess    = not na(time(timeframe.period, sessWin, "America/New_York"))
bool sessOpen  = inSess and not inSess[1]      // rising edge = a new session began
bool sessClose = not inSess and inSess[1]      // falling edge = the session just ended

// Auto intrabar timeframe: target roughly 10 to 20 intrabars per chart bar. A finer
// LTF than this burns the intrabar budget for accuracy the row height can't show.
int    chartSec = timeframe.in_seconds(timeframe.period)
string autoLtf  = chartSec <= 60 ? "1" : chartSec <= 300 ? "1" : chartSec <= 900 ? "1" : chartSec <= 3600 ? "5" : "15"
string ltfTf    = ltfMode == "1 min" ? "1" : ltfMode == "5 min" ? "5" : ltfMode == "15 min" ? "15" : autoLtf
// Never request a timeframe at or above the chart's own, that is a runtime error.
bool   ltfOk    = useLtf and timeframe.in_seconds(ltfTf) < chartSec

// One unconditional request. Conditional request.*() is legal in v6 but costs
// predictability; filtering afterwards is cheaper and cannot surprise us.
// open/close come along because intrabar DIRECTION has to be judged the same way
// TradingView judges it: the intrabar's own close vs its own open, not guessed
// from where it sat inside the parent bar.
[ltfH, ltfL, ltfO, ltfC, ltfV] = request.security_lower_tf(syminfo.tickerid, ltfTf, [high, low, open, close, volume])

// A symbol with no volume feed reports na on some feeds and 0 on others: both
// must be caught or the profile renders an empty box with no explanation.
var float volSeen = 0.0
volSeen += nz(volume)


// ═══════════════════════════════════════════════════════════════════════
//  NAKED VPOC STORE: prior sessions' points of control, still untouched.
//  Parallel arrays; pushed and removed together so they cannot desync.
// ═══════════════════════════════════════════════════════════════════════
var array<float> nkPx  = array.new<float>()   // the POC price
var array<int>   nkT   = array.new<int>()     // the time it was formed (line anchor)
var array<int>   nkBar = array.new<int>()     // the bar it was formed on

// Rolling accumulation for the CURRENT session's profile, used only to compute a
// POC to retire into the naked store at the session close. Deliberately coarse:
// this is a level tracker, not the rendered profile.
var array<float> sPx  = array.new<float>()
var array<float> sVol = array.new<float>()


// ═══════════════════════════════════════════════════════════════════════
//  DRAWING POOL: wiped and rebuilt each render (a pure projection of data,
//  never a source of it: no coordinate is ever read back off a drawing).
// ═══════════════════════════════════════════════════════════════════════
var array<box>   vBoxes = array.new<box>()
var array<line>  vLines = array.new<line>()
var array<label> vLabs  = array.new<label>()

f_wipe() =>
    // Guard every loop. Pine runs `for size-1 to 0` (i.e. `0 to -1`) ONCE on empty.
    if array.size(vBoxes) > 0
        for i = array.size(vBoxes) - 1 to 0
            box.delete(array.get(vBoxes, i))
        array.clear(vBoxes)
    if array.size(vLines) > 0
        for i = array.size(vLines) - 1 to 0
            line.delete(array.get(vLines, i))
        array.clear(vLines)
    if array.size(vLabs) > 0
        for i = array.size(vLabs) - 1 to 0
            label.delete(array.get(vLabs, i))
        array.clear(vLabs)
    0

// Row index for a price, always clamped.
// v6 FOOTGUN, LOAD-BEARING: array.get/set now ACCEPT negative indices and wrap to
// the end of the array. In v5 a negative index threw immediately; in v6 it
// silently reads or writes the wrong end and quietly corrupts the top of the
// profile. Every computed index in this script goes through here.
f_row(float px, float lo, float h, int n) =>
    math.max(0, math.min(n - 1, int((px - lo) / h)))


// ═══════════════════════════════════════════════════════════════════════
//  SESSION POC TRACKING: feeds the naked-VPOC store. Runs every bar, cheaply:
//  one coarse bucket per price step, no rendering.
// ═══════════════════════════════════════════════════════════════════════
float nkStep = tick * ticksRow * 2   // coarser than the drawn profile on purpose

if showNaked and barstate.isconfirmed
    if sessOpen
        array.clear(sPx)
        array.clear(sVol)
    if inSess and not na(volume) and volume > 0
        float mid = math.round((hl2 / nkStep)) * nkStep
        int   at  = -1
        if array.size(sPx) > 0
            for i = 0 to array.size(sPx) - 1
                if math.abs(array.get(sPx, i) - mid) < nkStep * 0.5
                    at := i
                    break
        if at >= 0
            array.set(sVol, at, array.get(sVol, at) + volume)
        else
            array.push(sPx, mid)
            array.push(sVol, volume)
    // Session just ended: retire its POC into the naked store.
    if sessClose and array.size(sVol) > 0
        int   best = 0
        float bv   = array.get(sVol, 0)
        if array.size(sVol) > 1
            for i = 1 to array.size(sVol) - 1
                if array.get(sVol, i) > bv
                    bv := array.get(sVol, i)
                    best := i
        array.push(nkPx,  array.get(sPx, best))
        array.push(nkT,   time)
        array.push(nkBar, bar_index)
        while array.size(nkPx) > math.min(nakedBack, MAX_SESS)
            array.shift(nkPx)
            array.shift(nkT)
            array.shift(nkBar)

// Retire a naked VPOC the moment a LATER bar's range touches it. Range
// intersection, not a close-through, that is what the vendor implementations
// use, and a wick is a real trade at that price. The forming session is excluded
// by the bar_index check, so a level can never kill itself.
bool nakedHit = false
// v2.3: the touch test can be restricted to session hours. This is the setting
// that decides whether the feature produces anything at all. NQ trades ~23
// hours, so counting thin overnight rotation retires almost every level within a
// day and the chart ends up bare. Sources genuinely split on it, so it's a switch.
bool nakedTestOk = not nakedRth or inSess
if showNaked and barstate.isconfirmed and nakedTestOk and array.size(nkPx) > 0
    for i = array.size(nkPx) - 1 to 0
        float px = array.get(nkPx, i)
        if bar_index > array.get(nkBar, i) and low <= px and high >= px
            nakedHit := true
            array.remove(nkPx,  i)
            array.remove(nkT,   i)
            array.remove(nkBar, i)


// ═══════════════════════════════════════════════════════════════════════
//  PROFILE STATE: hoisted to globals so plot() and alertcondition() can read
//  them. Both must live at global scope, and neither can see a local.
// ═══════════════════════════════════════════════════════════════════════
var float gPoc  = na
var float gVah  = na
var float gVal  = na
var int   gRows = 0
var float gVaAct = 0.0      // the value area's ACTUAL achieved %: it overshoots
var int   gLtfN = 0         // bars distributed with intrabar data
var int   gBarN = 0         // bars that fell back to bar-level spreading
var float gBinH = 0.0       // v2.1: the row height ACTUALLY used, after any coarsening
var string gModeUsed = ""   // v2.1: the range mode actually used, after any TF fallback

// v2.1: Session scope needs an intraday chart. A 09:30 to 16:00 window does not
// divide into 4h bars, so the session walk finds no clean boundary and keeps
// going. A 4h test profiled 56 bars (about 9 days) instead of one session.
// Above 1h the mode silently meant something else, so now it falls back to
// fixed-lookback and SAYS SO in the stats table rather than quietly misbehaving.
bool sessTooHigh = rangeMode == "Session" and chartSec > 3600
string modeEff   = sessTooHigh ? "Fixed lookback (N bars)" : rangeMode


// ═══════════════════════════════════════════════════════════════════════
//  RENDER: one snapshot, on the last bar only.
//  Everything above is O(1) per bar; the heavy work happens exactly once.
// ═══════════════════════════════════════════════════════════════════════
if barstate.islast
    f_wipe()

    // ── 1. How far back, AND how far forward, does the window reach? ──
    //
    // v2.4: the window gained a right edge. Its absence cost both non-default modes.
    // v2.0 correctly worked out that visible-range mode needs to honour the
    // rightmost visible bar, computed `endOff` for exactly that... and then every
    // loop downstream ran `0 to nb`, from the CURRENT bar back, so the value was
    // calculated and thrown away. Session mode never had a right edge at all.
    // The result: `Sessions back = 1` profiled yesterday's session **plus
    // everything traded since**, so yesterday's supposedly-finished VPOC/VAH/VAL
    // kept moving all day, which is precisely what that setting exists to avoid.
    // Scrolled-back visible ranges had the same leak.
    // `nbEnd` is now the window's RIGHT edge as a bar offset, every downstream
    // loop runs `nbEnd..nb`, and the level lines anchor to the window's own last
    // bar instead of to "now". Found 2026-08-10 while porting this session walk
    // into MM Market Profile (TPO), where the same hole was fixed at build time.
    // Fixed-lookback mode is unaffected (its right edge genuinely is bar 0), and
    // `Sessions back = 0` is unaffected, which is why nobody had hit this.
    int nb    = 0
    int nbEnd = 0
    gModeUsed := sessTooHigh ? "Session → lookback" : rangeMode
    if modeEff == "Visible range"
        // v2.0 FIX: honour BOTH edges. TradingView's docs are explicit that the
        // rightmost visible bar is not necessarily the last bar, and v1.0 assumed
        // it was, so scrolling right could collapse the profile to one bar.
        int lT = chart.left_visible_bar_time
        int rT = chart.right_visible_bar_time
        if not na(rT)
            for i = 0 to maxBars
                if na(time[i]) or time[i] <= rT
                    nbEnd := i
                    break
        for i = nbEnd to maxBars
            if na(time[i]) or time[i] < lT
                break
            nb := i
    else if modeEff == "Session"
        // Walk back to the target session. sessBack=0 is the session in progress;
        // 1 is the last completed one, and so on.
        // v2.4: `nbEnd` is the offset of the target session's LAST bar: the first
        // in-session bar the backward walk meets once the counter reaches sessBack.
        // -1 means "not found yet", so the first hit wins and later (older) bars
        // only move `nb`.
        int  seen    = 0
        bool started = false
        nbEnd := -1
        for i = 0 to maxBars
            if na(time[i])
                break
            // History off the GLOBAL inSess series. Calling time(...) inside a
            // loop would evaluate a session function in local scope, which is
            // exactly the pattern that corrupts rolling state in Pine.
            bool wasIn = inSess[i]
            if wasIn
                started := true
                if seen == sessBack
                    if nbEnd < 0
                        nbEnd := i
                    nb := i
            else if started and seen == sessBack
                break
            else if started
                seen += 1
                started := false
        if nbEnd < 0
            nbEnd := 0
    else
        nb := math.min(lookback, maxBars)
    nb    := math.min(nb, bar_index)
    // Clamp so the window can never invert. A `for i = nbEnd to nb` with nb < nbEnd
    // counts DOWNWARD in Pine and would walk bars outside the window entirely,
    // a far worse failure than the empty profile it replaces.
    nb    := math.max(nb, nbEnd)

    // ── 2. Window price extremes ──
    float rHi = high[nb]
    float rLo = low[nb]
    for i = nbEnd to nb
        if not na(high[i])
            rHi := math.max(rHi, high[i])
            rLo := math.min(rLo, low[i])

    // v2.0 FIX: a flat window used to draw nothing at all, silently. Widen it to
    // one row so the user sees a profile and can tell the tool is alive.
    if rHi <= rLo
        rHi := rLo + tick * math.max(1, ticksRow)

    if volSeen <= 0
        label warn = label.new(bar_index, close, "MM VProfile: this symbol has no volume data",
             style=label.style_label_left, color=COL_NONE, textcolor=color.gray, size=size.small)
        array.push(vLabs, warn)
    else
        // ── 3. Bin geometry ──
        // Ticks-per-row anchors rows on absolute price increments, so the same
        // level lands on the same price tomorrow. Number-of-rows re-slices the
        // window every time its range changes.
        float binH = 0.0
        int   rows = 0
        if rowMode == "Ticks per row"
            binH := tick * ticksRow
            rows := int(math.ceil((rHi - rLo) / binH))
            if rows > MAX_ROWS
                // Too many rows for the drawing budget: coarsen rather than
                // silently truncate the profile's top (which is what TradingView's
                // garbage collector would do for us).
                rows := MAX_ROWS
                binH := (rHi - rLo) / rows
            // Snap the grid DOWN to the increment first, then re-derive the row
            // count from the snapped floor: otherwise the snap pushes rLo below
            // the original low and the top row ends up short of rHi.
            rLo  := math.floor(rLo / binH) * binH
            rows := math.max(1, math.min(MAX_ROWS, int(math.ceil((rHi - rLo) / binH))))
        else
            rows := math.min(nBins, MAX_ROWS)
            binH := (rHi - rLo) / rows
        gRows := rows
        gBinH := binH

        array<float> bTot = array.new<float>(rows, 0.0)
        array<float> bUp  = array.new<float>(rows, 0.0)
        array<float> bDn  = array.new<float>(rows, 0.0)

        int ltfUsed = 0
        int barUsed = 0

        // ── 4. Distribution: intrabar where available, bar-level otherwise ──
        // v2.4: nbEnd..nb, not 0..nb: see the window note in section 1.
        for i = nbEnd to nb
            if not na(high[i]) and not na(volume[i])
                bool didLtf = false
                if ltfOk and i <= ltfDepth
                    // Array history: ltfV[i] is the intrabar array as it was on bar
                    // i. An empty array is the DOCUMENTED failure mode when the
                    // intrabar horizon is exceeded: no error is raised, so this
                    // size check is the only thing standing between us and a
                    // silently half-built profile.
                    int m = array.size(ltfV[i])
                    if m > 0
                        didLtf := true
                        for k = 0 to m - 1
                            float iv = array.get(ltfV[i], k)
                            float ih = array.get(ltfH[i], k)
                            float il = array.get(ltfL[i], k)
                            float io = array.get(ltfO[i], k)
                            float ic = array.get(ltfC[i], k)
                            if not na(iv) and iv > 0 and not na(ih) and not na(il)
                                bool iup = ic > io
                                bool idn = ic < io
                                if ih <= il
                                    int r = f_row(ih, rLo, binH, rows)
                                    array.set(bTot, r, array.get(bTot, r) + iv)
                                    if iup
                                        array.set(bUp, r, array.get(bUp, r) + iv)
                                    else if idn
                                        array.set(bDn, r, array.get(bDn, r) + iv)
                                else
                                    int r1 = f_row(il, rLo, binH, rows)
                                    int r2 = f_row(ih, rLo, binH, rows)
                                    int span = r2 - r1 + 1
                                    float share = iv / span
                                    for r = r1 to r2
                                        array.set(bTot, r, array.get(bTot, r) + share)
                                        if iup
                                            array.set(bUp, r, array.get(bUp, r) + share)
                                        else if idn
                                            array.set(bDn, r, array.get(bDn, r) + share)
                if didLtf
                    ltfUsed += 1
                else if volume[i] > 0
                    // Bar-level fallback: overlap-weighted across the bar's own
                    // range, so partial top and bottom rows aren't over-credited.
                    barUsed += 1
                    float V  = volume[i]
                    float L  = low[i]
                    float H  = high[i]
                    // v2.0 FIX: v1.0's header claimed "up-closes vs down-closes"
                    // while the code classified on close-vs-OPEN, and counted a
                    // doji as UP. Body direction is the right test (it's what
                    // TradingView uses too), so the header was the wrong half.
                    // A true doji is now left out of BOTH sides rather than having
                    // a direction invented for it.
                    bool up  = close[i] > open[i]
                    bool dn  = close[i] < open[i]
                    if H <= L
                        int r = f_row(H, rLo, binH, rows)
                        array.set(bTot, r, array.get(bTot, r) + V)
                        if up
                            array.set(bUp, r, array.get(bUp, r) + V)
                        else if dn
                            array.set(bDn, r, array.get(bDn, r) + V)
                    else
                        int r1 = f_row(L, rLo, binH, rows)
                        int r2 = f_row(H, rLo, binH, rows)
                        float sp = H - L
                        for r = r1 to r2
                            float bBot = rLo + r * binH
                            float bTop = bBot + binH
                            float ov = math.min(H, bTop) - math.max(L, bBot)
                            if ov > 0
                                float w = V * (ov / sp)
                                array.set(bTot, r, array.get(bTot, r) + w)
                                if up
                                    array.set(bUp, r, array.get(bUp, r) + w)
                                else if dn
                                    array.set(bDn, r, array.get(bDn, r) + w)
        gLtfN := ltfUsed
        gBarN := barUsed

        // ── 5. VPOC + totals ──
        // Ties go to the row nearest the profile's midpoint. CQG, Sierra Chart
        // and mypivots all agree on that, and an equidistant tie takes the lower
        // row. v1.0's plain `>` silently handed every tie to the lowest row.
        float maxV = 0.0
        float totV = 0.0
        int   poc  = 0
        float midR = (rows - 1) / 2.0
        for b = 0 to rows - 1
            float v = array.get(bTot, b)
            totV += v
            if v > maxV
                maxV := v
                poc  := b
            else if v == maxV and v > 0
                if math.abs(b - midR) < math.abs(poc - midR)
                    poc := b

        if totV > 0 and maxV > 0
            // ── 6. Value Area ──
            // One row at a time, taking the heavier neighbour: matching CQG,
            // Sierra Chart and TradingView. The crossing row is INCLUDED (the stop
            // is tested before adding), so the area lands at or just over target,
            // which is what the original exchange data did: the CBOT tables run
            // 70.3 to 73.7%, never under 70.
            float target = totV * vaPct / 100.0
            int   loI = poc
            int   hiI = poc
            float vaV = array.get(bTot, poc)
            for _n = 0 to rows
                if vaV >= target
                    break
                float vAbove = hiI < rows - 1 ? array.get(bTot, hiI + 1) : SENTINEL
                float vBelow = loI > 0        ? array.get(bTot, loI - 1) : SENTINEL
                if vAbove < 0 and vBelow < 0
                    break
                if vAbove >= vBelow
                    hiI += 1
                    vaV += array.get(bTot, hiI)
                else
                    loI -= 1
                    vaV += array.get(bTot, loI)
            gVaAct := totV > 0 ? vaV / totV * 100.0 : 0.0

            // Stated convention: VAH is the TOP edge of the highest value row and
            // VAL the BOTTOM edge of the lowest, so the area contains its rows.
            // The VPOC prints at its row's midpoint. No vendor documents either
            // choice, so ours is written down rather than left implicit.
            gPoc := rLo + (poc + 0.5) * binH
            gVah := rLo + (hiI + 1) * binH
            gVal := rLo + loI * binH

            // ── 7. Coordinates ──
            int px0     = bar_index + GAP
            int labX    = px0 + profW + 2
            int leftBI  = bar_index - nb
            // v2.4: the window's own right edge, not "now". On a completed session
            // the levels must stop where the session did: a line that keeps
            // extending is a line that looks like it is still being computed.
            int rightBI = bar_index - nbEnd
            int levelL  = extMode == "Right to price" ? rightBI : leftBI
            int levelR  = extMode == "Across window"  ? rightBI : px0

            // ── 8. Rows ──
            for b = 0 to rows - 1
                float bBot = rLo + b * binH
                float bTop = bBot + binH
                bool  inVA = b >= loI and b <= hiI
                float tot  = array.get(bTot, b)
                if tot > 0
                    int trans = inVA ? 20 : fadeOut
                    if splitVol
                        int wUp = int(profW * array.get(bUp, b) / maxV)
                        int wDn = int(profW * array.get(bDn, b) / maxV)
                        // v2.0 FIX: the VPOC row now takes the gold accent in BOTH
                        // modes. v1.0 only highlighted it when the split was OFF:
                        // and the split ships ON, so the gold row the guide
                        // promised never appeared out of the box.
                        color uc = b == poc ? color.new(pocCol, 15) : color.new(upCol, trans)
                        color dc = b == poc ? color.new(pocCol, 35) : color.new(dnCol, trans)
                        if wUp > 0
                            array.push(vBoxes, box.new(px0, bTop, px0 + wUp, bBot,
                                 xloc=xloc.bar_index, border_color=COL_NONE, bgcolor=uc))
                        if wDn > 0
                            array.push(vBoxes, box.new(px0 + wUp, bTop, px0 + wUp + wDn, bBot,
                                 xloc=xloc.bar_index, border_color=COL_NONE, bgcolor=dc))
                    else
                        int wv = int(profW * tot / maxV)
                        color bc = b == poc ? color.new(pocCol, 15) : color.new(neutCol, trans)
                        if wv > 0
                            array.push(vBoxes, box.new(px0, bTop, px0 + wv, bBot,
                                 xloc=xloc.bar_index, border_color=COL_NONE, bgcolor=bc))

            // ── 9. HVN / LVN nodes ──
            // Sierra Chart's peak/valley rule, the only published algorithm for
            // this. The asymmetry is load-bearing: STRICT above, NON-STRICT below.
            // With a symmetric test a flat plateau fires on every row of itself;
            // this way it resolves to exactly one.
            if showNodes and rows > nodeSens * 2
                for b = nodeSens to rows - nodeSens - 1
                    float v = array.get(bTot, b)
                    if v > 0
                        bool peak = true
                        bool vall = true
                        for k = 1 to nodeSens
                            float a = array.get(bTot, b + k)
                            float c = array.get(bTot, b - k)
                            if not (a < v)
                                peak := false
                            if not (c <= v)
                                peak := false
                            if not (a > v)
                                vall := false
                            if not (c >= v)
                                vall := false
                        if peak or vall
                            float y = rLo + (b + 0.5) * binH
                            array.push(vLabs, label.new(px0 - 1, y, peak ? "◄" : "◄",
                                 xloc=xloc.bar_index, style=label.style_label_right,
                                 color=COL_NONE, textcolor=peak ? hvnCol : lvnCol,
                                 size=size.tiny, tooltip=peak ? "HVN: accepted price, expect grind" : "LVN: rejected price, expect fast travel"))

            // ── 10. Levels ──
            if showPOC
                array.push(vLines, line.new(levelL, gPoc, levelR, gPoc,
                     xloc=xloc.bar_index, color=pocCol, width=2))
                array.push(vLabs, label.new(labX, gPoc, "VPOC " + str.tostring(gPoc, format.mintick),
                     xloc=xloc.bar_index, style=label.style_label_left, color=COL_NONE,
                     textcolor=pocCol, size=size.small))
            if showVA
                array.push(vLines, line.new(levelL, gVah, levelR, gVah, xloc=xloc.bar_index,
                     color=vaEdge, width=1, style=line.style_dashed))
                array.push(vLines, line.new(levelL, gVal, levelR, gVal, xloc=xloc.bar_index,
                     color=vaEdge, width=1, style=line.style_dashed))
                array.push(vLabs, label.new(labX, gVah, "VAH " + str.tostring(gVah, format.mintick),
                     xloc=xloc.bar_index, style=label.style_label_left, color=COL_NONE,
                     textcolor=vaEdge, size=size.small))
                array.push(vLabs, label.new(labX, gVal, "VAL " + str.tostring(gVal, format.mintick),
                     xloc=xloc.bar_index, style=label.style_label_left, color=COL_NONE,
                     textcolor=vaEdge, size=size.small))

            // ── 11. Naked VPOCs from prior sessions ──
            // v2.2 FIX (runtime error RE10026): these MUST be time-anchored, not
            // bar-index anchored. A naked VPOC survives precisely BECAUSE price
            // never came back to it, so the longer it stays valid, the further its
            // origin drifts from the current bar, and bar_index drawing coordinates
            // have a limited reach. A 5m test anchored one about 19,000 bars back
            // and threw. Every other drawing here is bounded by the window
            // (≤ maxBars) so bar_index is safe for those; this one is unbounded by
            // its very nature. nkT was stored for exactly this and then not used.
            // v2.3: skip any VPOC formed INSIDE the window being profiled. The
            // session that just closed gets retired into the naked store within
            // minutes, so on a Session profile its level sat exactly on the VPOC
            // line already being drawn: a duplicate that looked like the feature
            // wasn't working. A naked VPOC is only interesting once it's history.
            if showNaked and array.size(nkPx) > 0
                for i = 0 to array.size(nkPx) - 1
                    if array.get(nkBar, i) >= bar_index - nb
                        continue
                    float px = array.get(nkPx, i)
                    array.push(vLines, line.new(array.get(nkT, i), px, time, px,
                         xloc=xloc.bar_time, color=nakedCol, width=1, style=line.style_dotted))
                    array.push(vLabs, label.new(time, px, "nVPOC",
                         xloc=xloc.bar_time, style=label.style_label_left, color=COL_NONE,
                         textcolor=nakedCol, size=size.tiny,
                         tooltip="Naked VPOC: a prior session's point of control price has not traded back to."))

            // ── 12. Stats ──
            // The fallback count is the honest measure of how accurate the profile
            // in front of you actually is. It is not decoration.
            // v2.1: Row height and the effective mode are here because BOTH can
            // silently differ from what you set. Ask for 20 ticks/row on a wide
            // window and you get 101; ask for Session on a 4h chart and you get
            // nine days. A setting that quietly means something else is worse
            // than one that's wrong, because nothing tells you to look.
            // v2.5: which is exactly why the default is AUTO and not OFF - the
            // panel is a warning light, so it earns its place by staying dark.
            int  effTicks  = int(math.round(binH / tick))
            bool coarsened = rowMode == "Ticks per row" and effTicks > ticksRow
            bool noIntra   = ltfUsed <= 0
            bool fellBack  = barUsed > ltfUsed
            bool diverged  = coarsened or sessTooHigh or noIntra or fellBack
            bool showDiag  = statsMode == "Always" or (statsMode == "Auto" and diverged)
            var table st = table.new(f_stPos(), 2, 6, border_width=1)
            if showDiag
                table.cell(st, 0, 0, "MM VProfile", text_color=stVal, text_size=f_stSz(), bgcolor=stBgA)
                table.cell(st, 1, 0, str.tostring(rows) + " rows", text_color=stVal, text_size=f_stSz(), bgcolor=stBgA)
                table.cell(st, 0, 1, "Row height", text_color=stKey, text_size=f_stSz(), bgcolor=stBgB)
                table.cell(st, 1, 1, str.tostring(effTicks) + "t / " + str.tostring(binH, format.mintick), text_color=coarsened ? stWarn : stVal, text_size=f_stSz(), bgcolor=stBgB)
                table.cell(st, 0, 2, "Range mode", text_color=stKey, text_size=f_stSz(), bgcolor=stBgB)
                table.cell(st, 1, 2, gModeUsed, text_color=sessTooHigh ? stWarn : stVal, text_size=f_stSz(), bgcolor=stBgB)
                table.cell(st, 0, 3, "Value area", text_color=stKey, text_size=f_stSz(), bgcolor=stBgB)
                table.cell(st, 1, 3, str.tostring(gVaAct, "#.#") + "%", text_color=stVal, text_size=f_stSz(), bgcolor=stBgB)
                table.cell(st, 0, 4, "Intrabar bars", text_color=stKey, text_size=f_stSz(), bgcolor=stBgB)
                table.cell(st, 1, 4, str.tostring(ltfUsed), text_color=noIntra ? stWarn : stVal, text_size=f_stSz(), bgcolor=stBgB)
                table.cell(st, 0, 5, "Fallback bars", text_color=stKey, text_size=f_stSz(), bgcolor=stBgB)
                table.cell(st, 1, 5, str.tostring(barUsed), text_color=fellBack ? stWarn : stVal, text_size=f_stSz(), bgcolor=stBgB)
            else
                table.clear(st, 0, 0, 1, 5)


// ═══════════════════════════════════════════════════════════════════════
//  PLOTS: v2.0. These are what put VPOC/VAH/VAL into the Data Window, make
//  them readable by other scripts, and let them drive screeners. v1.0 drew the
//  levels only as drawing objects, which are invisible to all three.
//  display.none keeps them out of the chart (the lines already draw them).
// ═══════════════════════════════════════════════════════════════════════
plot(gPoc, "VPOC", color=pocCol, display=display.data_window + display.price_scale)
plot(gVah, "VAH",  color=vaEdge, display=display.data_window + display.price_scale)
plot(gVal, "VAL",  color=vaEdge, display=display.data_window + display.price_scale)


// ═══════════════════════════════════════════════════════════════════════
//  ALERTS: no major platform's built-in volume profile offers these.
//  Compared against the PREVIOUS bar's level so a level that moves onto price
//  cannot fire by itself; only price reaching the level does.
// ═══════════════════════════════════════════════════════════════════════
bool touchPoc = alPoc and not na(gPoc[1]) and low <= gPoc[1] and high >= gPoc[1]
bool touchVah = alVa  and not na(gVah[1]) and low <= gVah[1] and high >= gVah[1]
bool touchVal = alVa  and not na(gVal[1]) and low <= gVal[1] and high >= gVal[1]

alertcondition(touchPoc, "VPOC touch", "Price reached the VPOC on {{ticker}} {{interval}}")
alertcondition(touchVah, "VAH touch",  "Price reached the Value Area High on {{ticker}} {{interval}}")
alertcondition(touchVal, "VAL touch",  "Price reached the Value Area Low on {{ticker}} {{interval}}")
alertcondition(touchVah or touchVal, "Value Area edge touch", "Price reached a Value Area edge on {{ticker}} {{interval}}")
alertcondition(alNaked and nakedHit, "Naked VPOC touch", "Price reached a naked VPOC on {{ticker}} {{interval}}")
````
