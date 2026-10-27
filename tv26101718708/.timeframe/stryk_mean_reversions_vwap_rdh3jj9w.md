# STRYK: MEAN REVERSIONS VWAP

- url: https://www.tradingview.com/script/RDH3jj9w-STRYK-MEAN-REVERSIONS-VWAP/
- type: indicator
- pine_id: PUB;b439048d204e463eaef79ed2b5b92f34
- version: 2.0

## Description

# STRYK: MEAN REVERSIONS VWAP (STRYK:MRV) v4.14

🔹 One VWAP indicator in place of five. A single VWAP ENGINE drives the line, three σ bands with a hyper-detailed gradient fill, the mean-reversion and break / reclaim signals, the VWAP candle colours and a side volume profile that always covers the same bars as the VWAP. Session levels, the opening box with extension targets, MDP candles and the 233 EMA with 20-week bands sit on the same chart, each with its own switch in the master section. Anything switched off is not drawn at all, so the chart stays light.

🔹 Eight anchors in one dropdown: rVWAP (rolling N candles of any timeframe, default 23 × 1 hour = one futures day, measured in elapsed clock time so it is the same window on every chart timeframe and across session breaks), Prev session 17:00, Prev-day 08:30, Weekday 08:30 (any weekday, N back), 2 weeks, Month, Prev month and 3 months. Lines can be drawn raw, stepped or with x8 double-pass smoothing (display only; signals always use the raw values). In a 2-year ES study (Oct 2024 – Oct 2026, 9 contracts, 5-minute bars, 2σ → 1σ rules, before costs) the rolling 23-hour VWAP led at +0.079R per trade over 698 trades, positive on 8 of 9 contracts. The edges are small; the built-in anchor test lets you check every anchor on your own chart, net of your own costs.

🔹 Signals read whichever engine you choose. Mean reversion: the original rule (touch band 2, close back inside band 1, target the VWAP) plus rule sets A and B, tested on all eight anchors at once. BREAK and RECLAIM at the VWAP and every band, graded by five gates (A acceptance, S size against same-time-of-day volume, F candle delta flow, P higher-timeframe pressure, T trend) with a gates-needed setting and confirmation bars. CE reversion triangles on the same engine. Marks are small text glyphs with their own shape, size and colour section, so they go smaller than TradingView's "tiny".

🔹 Anchor test table, net of costs: every row shows trades, win %, net R, R per trade, profit factor, max drawdown in R and the exit split (target / stop / timeout) after a cost-per-trade setting in ticks, with a low-sample flag under 30 trades. The same rules and the same costs apply to every anchor, so the ranking is a fair one.

🔹 Side profile: one centre axis, every bar grows to the right. Volume, Buy vs sell (green buying then red selling on one bar) or Delta, built from chart bars or intrabar tick data that scales with the chart timeframe. Row tags show delta, buy / sell, both, or imbalanced rows only (your × ratio, ▲ / ▼ marks, other rows dimmed). The POC, VAH and VAL of the engine window, the prior session's VAH / VAL and the naked POCs all draw across the profile with price tags at its right end, never across the candles. Gap and length from the last candle are adjustable.

🔹 Opening box: the 08:30–09:30 range with its 50 %, POC and value area, extension targets from 0.5× to 10× revealed one at a time as price reaches them, each with its own toggle, and the anchor box (previous day) with its own extend switches. Candle engines: σ distance, price vs VWAP, 3-state bands, VWAP reversion, Delta size HTF, Delta % and Fuel × Δ; Max Delta Print candles paint over any of them.

🔹 Clean chart: every line tag goes through one placer that sorts them and pushes them apart so nothing overlaps, in short-hand right next to the line ends, with a distance and gap setting. One section holds every line's colour, width and style; one section holds every signal's shape, size and colour with a legend of what each mark means. Every setting has a plain-English tooltip. Decisions are made on confirmed bars and nothing repaints. Replay mode keeps Bar Replay smooth. No performance claim is made or implied; not financial advice.

## Source Code

````pine
// =============================================================================
// STRYK: MEAN REVERSIONS VWAP v4.16 — one VWAP indicator: engine, bands, signals,
// candle engines, volume profile, session levels, opening box, delta top-down
// (short title STRYK:MRV)
// =============================================================================
// One VWAP ENGINE drives everything: the line, its three bands and gradient
// fill, the reversion and break / reclaim signals, the candle colours that read
// the VWAP, and the volume profile, which always covers the same bars as the
// VWAP. Eight anchors: Prev session 17:00, Prev-day 08:30, Weekday 08:30,
// 2 weeks, Month, Prev month, 3 months and rVWAP (rolling: N bars of any
// timeframe, 23 × 1 hour by default = one futures day).
//
// 2-year ES study (Oct 2024 – Oct 2026, 9 contracts, 5-minute bars, original
// 2σ → 1σ rules, R per trade before costs): Rolling 23h +0.079 (8 of 9
// contracts positive), Rolling 46h +0.059, Prev session 17:00 +0.055, Month
// +0.049, Prev-day 08:30 +0.048. That is why rVWAP 23 × 1h is the default.
// Small edges, no costs: test on your own chart with the anchor test table.
//
// Built from STRYK:MRV v3.2, STRYK:VBS, STRYK:CE (delta top-down), STRYK: OP
// (opening box, live table), STRYK: SVP (session levels) and STRYK:DRE (EMAs,
// 20-week bands, MDP levels). Decisions on confirmed bars; nothing repaints.
// No performance claim is made or implied; not financial advice.
// =============================================================================

//@version=6
indicator("STRYK: MEAN REVERSIONS VWAP", "STRYK:MRV", overlay = true, max_bars_back = 500, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500, max_polylines_count = 100, dynamic_requests = true)

string G0 = "1 · MASTER"
string GB = "2 · VWAP line & bands"
string GLN = "3 · Lines"
string GS = "4 · Signals"
string GP = "5 · Volume profile & session levels"
string GM = "6 · MDP candles, EMAs & 20-week"
string GT = "7 · Anchor test & alerts"

// ---------------------------------------------------------------- 1 · MASTER
mMaster = input.bool(true, "MASTER SWITCH — everything on", group = G0,
     tooltip = "The one switch above all others. Off leaves the script loaded but completely silent: no VWAP, bands or fills, no signals, no profile, no boxes, no top-down delta, no tables, no candle colour and no alerts.")
devMode = input.string("PC", "DEVICE", options = ["PC", "Mobile"], group = G0,
     tooltip = "PC: everything as set below. MOBILE: the same settings, but the side profile, its POC / VAH / VAL lines and every end-of-line tag are switched off so a phone screen stays readable, and the live info table goes to its compact layout. Everything the profile and tags showed is read out in the table instead (Profile, Node, pVA and nPOC rows).")
modeIn  = input.string("Full", "MODE", options = ["Full", "Clean (candles only)", "Replay"], group = G0,
     tooltip = "FULL: everything you have switched on.\nCLEAN (CANDLES ONLY): one click to a bare chart, only the coloured candles stay. Switch back to Full and everything returns as you had it.\nREPLAY: for TradingView Bar Replay. Stops the intrabar data requests and the heavy profiles so replay steps smoothly; candles colour with Delta % from bar direction. Use Full for live trading.")
vwEng   = input.string("Weekday 08:30", "VWAP ENGINE", options = ["rVWAP (rolling)", "Prev session 17:00", "Prev-day 08:30", "Weekday 08:30", "2 weeks", "Month", "Prev month", "3 months"], group = G0,
     tooltip = "Which VWAP runs the chart. The line, its bands and fill, the signals, the trade lines, the VWAP candle engines and the volume profile all follow this one choice; the profile covers the same bars as the VWAP.\n\nrVWAP (ROLLING, default): the last N candles of the timeframe below, always sliding forward. 23 × 1 hour = one full futures day, the best anchor in the 2-year ES test (+0.079R per trade, 698 trades, positive on 8 of 9 contracts). 46 × 1 hour = two days (+0.059R). 10 × 1 day = two weeks.\nPREV SESSION 17:00: from the start of YESTERDAY's 17:00 CT session to now (two sessions). +0.055R.\nPREV-DAY 08:30: from yesterday's 08:30 CT cash open through all of today; it moves to today's 08:30 when the next session opens at 17:00 (same as STRYK: OP). +0.048R.\nWEEKDAY 08:30: locked to the 08:30 open of the weekday you pick below, N of them back.\n2 WEEKS: from the start of the current two-week block.\nMONTH: from the first bar of this month. +0.049R.\nPREV MONTH: from the first bar of LAST month (two months of volume).\n3 MONTHS: from the first bar of the month two months ago (this month and the two before it).")
rvN     = input.int(23, "rVWAP: N", minval = 1, maxval = 2000, group = G0, inline = "rv")
rvTf    = input.timeframe("60", "×", group = G0, inline = "rv")
rvMode  = input.string("Elapsed time", "window", options = ["Elapsed time", "Chart bars"], group = G0, inline = "rv")
rvHist  = input.int(2000, "history (bars)", minval = 50, maxval = 20000, group = G0, inline = "rv",
     tooltip = "rVWAP WINDOW = N candles of this timeframe. N (default 23) is how many; the timeframe (default 1 hour) is how long each one is. 23 × 1 hour = 23 hours = one futures day. Every timeframe works: 1 minute, 5 minutes, 15 minutes, 1 hour, 4 hours, 1 day, 1 week. WINDOW: ELAPSED TIME (default) = the bars whose time is inside the last N × timeframe of clock time, so the window is the same real hours on every chart timeframe and across session breaks and holidays. CHART BARS = a fixed bar count (23 hours on a 5-minute chart = 276 bars), which drifts across gaps. Both are capped at 20,000 bars. \nHISTORY: how many bars back the rolling line, its bands and fill are drawn (2000 = about a week of 5-minute bars). A rolling VWAP never re-anchors, so its past is drawn too: on every past bar the line is the VWAP of the N candles before that bar. Signals and the test table always use the full history whatever this is set to. Only used when VWAP ENGINE is rVWAP.")
wdDay   = input.string("Monday", "Weekday 08:30: day", options = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"], group = G0, inline = "wd")
wdBack  = input.int(1, "back", minval = 1, maxval = 20, group = G0, inline = "wd",
     tooltip = "Only used by VWAP ENGINE Weekday 08:30. DAY: which weekday's 08:30 CT cash open the VWAP locks to. BACK: how many of those days back it starts (1 = the most recent one, 2 = the one before it). The VWAP runs from there to now and only moves when a newer one of that weekday opens.")
srcIn   = input.string("HLC3", "Price source", options = ["HLC3", "Close", "OHLC4"], group = G0,
     tooltip = "The price each bar adds to the VWAP. HLC3 (high + low + close) / 3 is the standard and what every test in this script used. CLOSE uses only the close. OHLC4 averages all four prices.")
lineShp = input.string("Smooth x8 (double pass)", "Line shape", options = ["Raw", "Smooth x8 (double pass)", "Stepped"], group = G0, inline = "ls")
lineCol = input.string("Solid", "colour", options = ["Solid", "VWAP slope", "Price side"], group = G0, inline = "ls",
     tooltip = "LINE SHAPE, universal: the VWAP and its bands (Current anchor only), and the 233 EMA, 20W EMA and 20W bands. RAW = exactly as calculated. SMOOTH x8 (DOUBLE PASS) = each line smoothed 8 times forward and backward, very smooth with no lag, so the weekly steps of the 20W lines become a curve; display only, signals use the raw values. STEPPED = holds flat, then steps, like a staircase.\nCOLOUR of the VWAP line: SOLID = the VWAP colour in section 2. VWAP SLOPE = rising / falling / flat colours. PRICE SIDE = bull colour while price closes above it, bear colour below.")
mrRules = input.string("Original: 2σ → 1σ", "SIGNALS: mean reversion", options = ["Original: 2σ → 1σ", "A: stretch 3σ → 2σ", "B: cross 1σ", "A + B", "Off"], group = G0,
     tooltip = "The mean-reversion trade on the VWAP ENGINE, with entry / stop / target lines and alerts. Shorts are the mirror of longs.\nORIGINAL (tested): price touches band 2, then a candle closes back inside band 1: target the VWAP, stop one tick past the extreme of the stretch. The 2-year ES result in the header comes from these rules.\nA · STRETCH: closes beyond band 3, then a candle closes back inside band 2. Risk to band 3; target the A reward (section 4) or exit early if band 1 rejects it. Lost on every anchor in the 7-month test.\nB · CROSS: a candle closes back through band 1 from the outside. Risk to band 2; target the B reward or the opposite band 1. Flat to slightly positive on Rolling 23h only.\nA + B: both run side by side.\nOFF: no reversion signals.")
engine  = input.string("Delta size HTF", "CANDLE ENGINE", group = G0,
     options = ["σ distance (VWAP engine)", "Price vs VWAP", "VWAP bands (3-state)", "VWAP reversion (2σ → 1σ)", "Delta size HTF", "Delta % (imbalance)", "Fuel × Δ (Truth Line)"],
     tooltip = "Pick the engine that colours the candles. Green = bull, blue = neutral, red = bear; brighter = stronger.\n\nVWAP (all on the VWAP ENGINE above)\n• σ distance: how far the close is from the VWAP in its own standard deviations. Brighter further out, amber once past band 2, full green / red on a reversion trigger. (Merges MR stretch, VWAP σ-distance and Sigma gradient, which were the same reading.)\n• Price vs VWAP: green above the line, red below.\n• VWAP bands (3-state): green above +1σ, red below −1σ, blue between.\n• VWAP reversion (2σ → 1σ): blue normally, dim amber out at ±2σ (setup), bright green / red on the candle that closes back inside ±1σ.\n\nDELTA (buying minus selling)\n• Delta size HTF: price against the value area of the last N higher-timeframe candles: blue inside, green above, red below, brighter with distance, acceptance, size and POC migration.\n• Delta % (imbalance): buying minus selling as a share of volume, self-calibrated, size-gated, with a streak boost.\n• Fuel × Δ: is the move paid for? Delta direction × participation × trend.\n• Participation band: how busy the market is: purple quiet, gold average, cyan busy.")
htfTf   = input.timeframe("60", "Higher timeframe", group = G0, inline = "htf")
lenN    = input.int(23, "candles", minval = 2, maxval = 200, group = G0, inline = "htf",
     tooltip = "ONE higher timeframe for the engines that read one: Delta size HTF (value area of the last N candles), Delta % scale, the P (pressure) gate. Default 1 hour × 23 = one futures day. If the chart is above this timeframe, the chart timeframe is used.")
dSrcIn  = input.string("Footprint, fall back to estimate", "Delta source", options = ["Footprint, fall back to estimate", "Estimate only", "Bar direction only (weak)"], group = G0,
     tooltip = "Where every delta number in the core comes from (candles, gates, profile buy vs sell).\nFOOTPRINT, FALL BACK TO ESTIMATE (best): TradingView footprint buy / sell volume where your plan and symbol have it, otherwise an estimate from 1-minute bars.\nESTIMATE ONLY: always the 1-minute estimate, one consistent method over all history.\nBAR DIRECTION ONLY: each bar's whole volume counted as buying if it closed up, selling if down (the old candle-colour method). Weakest; kept for comparison.")
tblMode = input.string("Live info", "TABLE", options = ["Live info", "Anchor test", "Both", "Off"], group = G0, inline = "tb")
tblPosLive = input.string("Bottom right", "live", options = ["Top right", "Middle right", "Bottom right", "Top left", "Middle left", "Bottom left"], group = G0, inline = "tb")
tblPosTest = input.string("Top right", "test", options = ["Top right", "Middle right", "Bottom right", "Top left", "Middle left", "Bottom left"], group = G0, inline = "tb",
     tooltip = "LIVE INFO: volume, participation, Fuel × Δ, HTF delta, VWAP position, box status, box delta, buy / sell and the last signal (rows in section 9).\nANCHOR TEST: the same trade rules run on all eight VWAP anchors over the loaded history (trades, win %, net R, R per trade) plus the break / reclaim results on the chart anchor.\nBOTH: two tables. OFF: none. The two boxes after it are where each table sits; keep them apart.")
// ---- SHOW — one switch for every element on the chart. Each row's tooltip explains it.
mVwap   = input.bool(true, "VWAP line", group = G0, inline = "sh1")
mBands  = input.bool(true, "bands 1-2", group = G0, inline = "sh1")
b3On    = input.bool(true, "band 3", group = G0, inline = "sh1")
mFill   = input.bool(true, "fill", group = G0, inline = "sh1")
curOnly = input.bool(true, "current anchor only", group = G0, inline = "sh1",
     tooltip = "VWAP LINE: the engine line. BANDS 1-2: its ±1σ and ±2σ bands (widths and colours in section 2). BAND 3: the ±3σ band. FILL: the gradient shading between the bands. CURRENT ANCHOR ONLY (default ON): only the VWAP running now is drawn, from its anchor to the last bar, with no old VWAPs and no jumps further back (the rolling rVWAP never re-anchors, so it is drawn back over its History setting). OFF: the full history of every past VWAP and band.")
labOnIn = input.bool(true, "Labels", group = G0, inline = "sh2")
labPrice = input.bool(true, "price", group = G0, inline = "sh2")
labBand = input.bool(true, "band tags", group = G0, inline = "sh2",
     tooltip = "LABELS: the master switch for every text label this script draws; off hides all of them at once. PRICE: add the price to every right-edge tag. BAND TAGS: +1σ, −2σ and so on at the end of the bands. Tag size, distance and short / full text are in the RIGHT EDGE row.")
brkOn   = input.bool(true, "Break signals", group = G0, inline = "sh3")
rclOn   = input.bool(true, "Reclaim signals", group = G0, inline = "sh3")
mCeTri  = input.bool(true, "CE marks", group = G0, inline = "sh3")
mPaintIn = input.bool(true, "Colour candles", group = G0, inline = "sh4")
mMdpIn  = input.bool(true, "MDP candles", group = G0, inline = "sh4")
vpOnIn  = input.bool(true, "Profile", group = G0, inline = "sh4")
vpNum   = input.bool(true, "numbers", group = G0, inline = "sh4",
     tooltip = "COLOUR CANDLES: paint the whole candle (body, wicks, border) with the CANDLE ENGINE above; hide the chart's own candles (eye icon beside the ticker) for the cleanest look. MDP CANDLES: the candle that becomes the session's Max Delta Print is painted orange (aggression) or purple (absorption) over the engine. PROFILE: the volume profile beside the last candle, always covering the same bars as the VWAP ENGINE (what the bars show, volume / buy vs sell / delta, and the data they are built from are in section 5). NUMBERS: the tag at the end of each row (what it shows is in section 5), always right of the centre axis.")
mSessLv = input.bool(true, "Session levels", group = G0, inline = "sh5")
pPocOn  = input.bool(true, "naked POCs", group = G0, inline = "sh5")
pVaOn   = input.bool(true, "prior VA", group = G0, inline = "sh5")
r80On   = input.bool(true, "80% rule", group = G0, inline = "sh5")
slLab   = input.bool(true, "tags", group = G0, inline = "sh5",
     tooltip = "SESSION LEVELS: the master switch for this row. NAKED POCs: prior-session POCs that price has not traded back through (up to 20). PRIOR VA: the previous session's VAH and VAL. Both are drawn across the SIDE PROFILE only, never across the candles, with their tag at the profile's right end. 80% RULE: the Market Profile 80% rule target line on the chart (settings in section 5). TAGS: the labels for all of these. Colours, widths and styles are in section 3.")
mIbIn   = input.bool(true, "Opening box", group = G0, inline = "sh6")
ib_midOn   = input.bool(true, "50%", group = G0, inline = "sh6")
ib_pocOn   = input.bool(true, "POC", group = G0, inline = "sh6")
ib_vaOn    = input.bool(true, "VAH/VAL", group = G0, inline = "sh6")
ib_extOn   = input.bool(true, "extensions", group = G0, inline = "sh6")
ib_xLab    = input.bool(true, "level tags", group = G0, inline = "sh6",
     tooltip = "OPENING BOX: the master switch for the 08:30–09:30 CT box drawn every day (section 8). 50%: the box midpoint line. POC and VAH/VAL: the box's own volume profile levels from intrabar volume. EXTENSIONS: the 0.5× to 6× box-height levels above and below today's box, revealed one at a time as price reaches them. LEVEL TAGS: labels on the extension levels and extended box lines. The next row extends the VWAP ANCHOR BOX's lines.")
ib_xAncHL  = input.bool(true, "Anchor box lines: high / low", group = G0, inline = "sh6b")
ib_xAncMid = input.bool(true, "50%", group = G0, inline = "sh6b")
ib_xAncPoc = input.bool(true, "POC", group = G0, inline = "sh6b")
ib_xAncVA  = input.bool(true, "VAH / VAL", group = G0, inline = "sh6b")
ib_ancTgt  = input.bool(true, "targets", group = G0, inline = "sh6b",
     tooltip = "The VWAP ANCHOR BOX is the first opening box at or after the VWAP ENGINE's anchor (yesterday's box for Prev-day 08:30, Monday's for Weekday 08:30, the month's first for Month). Each switch extends one of its lines from the box to the tags: HIGH / LOW, 50%, POC, VAH / VAL. TARGETS: its extension levels (0.5× to 6× the box height, revealed one at a time as price reaches them) drawn from the box to the tags, like today's box has.")
ib_labMode = input.string("Latest box only", "Box labels", options = ["Every box", "Latest box only", "None"], group = G0, inline = "sh7")
ib_mkRE    = input.bool(true, "range-ext marks", group = G0, inline = "sh7")
ib_mkX     = input.bool(true, "ext-level marks", group = G0, inline = "sh7",
     tooltip = "BOX LABELS: the IBH / IBL / 50% tags on every box, the latest box only, or none. RANGE-EXT MARKS: a small mark on the first candle that trades beyond the box high or low. EXT-LEVEL MARKS: a mark each time price reaches a new extension level. Mark size, how many to keep and their distance from the candle are in section 8.")
mEmaIn  = input.bool(true, "EMAs", group = G0, inline = "sh9")
ema1On  = input.bool(true, "233 EMA", group = G0, inline = "sh9")
ema2On  = input.bool(true, "20W EMA", group = G0, inline = "sh9")
w20On   = input.bool(true, "20W bands", group = G0, inline = "sh9")
w20Fill = input.bool(true, "20W fills", group = G0, inline = "sh9")
emaLab  = input.bool(true, "tags", group = G0, inline = "sh9",
     tooltip = "EMAs: the master switch for this row. 233 EMA: the 233-period EMA of the chart, the line the EMA trend candle engine reads. 20W EMA: the 20-week EMA built from weekly bars, the same level on any timeframe. 20W BANDS: bands at 1, 2 and 3 weekly ATRs around it; OFF by default because on an intraday chart they sit hundreds of points away and squash the price scale (turn them on for the big-picture stretch). 20W FILLS: shading between band 2 and band 3. TAGS: right-edge labels for the lines. Colours and multipliers are in section 6.")

// ---------------------------------------------------------------- 2 · VWAP LINE & BANDS
b1      = input.float(1.0, "Band 1  ±σ", minval = 0.25, maxval = 5.0, step = 0.25, group = GB, inline = "bs")
b2      = input.float(2.0, "Band 2", minval = 0.25, maxval = 6.0, step = 0.25, group = GB, inline = "bs")
b3      = input.float(3.0, "Band 3", minval = 0.5, maxval = 8.0, step = 0.25, group = GB, inline = "bs",
     tooltip = "How far each band sits from the VWAP, in standard deviations (σ). Band 1 is the TRIGGER band (the original reversion fires on the close back inside it), band 2 the SETUP band (price must touch it to arm), band 3 the extreme stretch. Colours, widths and styles are in section 3 · Lines.")
fillMode = input.string("Hyper gradient", "Fill", options = ["Hyper gradient", "Zone gradient", "Flat"], group = GB, inline = "f")
fillStr = input.int(35, "strength", minval = 5, maxval = 95, group = GB, inline = "f")
fillSteps = input.int(6, "steps per zone", minval = 2, maxval = 8, group = GB, inline = "f",
     tooltip = "FILL between the bands.\nHYPER GRADIENT (Current anchor only): every zone is cut into thin slices that fade smoothly from clear at the VWAP to full strength at the outer band, blending from each band's colour into the next. STEPS PER ZONE = how many slices in each zone (more = smoother; 6 × 6 zones = 36 slices).\nZONE GRADIENT: one flat shade per zone, deeper the further from the VWAP.\nFLAT: only the stretch zone between band 1 and band 2, one even shade.\nSTRENGTH: how strong the shading is at the outer band, 5 faint to 95 solid. With Current anchor only off, Hyper gradient draws as Zone gradient.")
fillCurve = input.float(1.4, "Fill curve", minval = 0.5, maxval = 3.0, step = 0.1, group = GB,
     tooltip = "How the hyper gradient deepens with distance. 1 = straight, even ramp. Above 1 (default 1.4) = stays light near the VWAP and deepens quickly near the outer band, so the stretch zones stand out. Below 1 = deepens early.")
minBars = input.int(12, "Ignore first bars after anchor", minval = 1, maxval = 200, group = GB,
     tooltip = "Right after an anchor the σ is built on too few bars and jumps around, so no signals and no bands in that window (12 = the first hour on 5 minutes).")

// ---------------------------------------------------------------- 3 · LINES
// one row per line: colour · width · style (styles apply to drawn lines; plotted history lines draw solid)
cVw     = input.color(#FFFFFF, "VWAP", group = GLN, inline = "L0")
wVw     = input.int(4, "", minval = 1, maxval = 6, group = GLN, inline = "L0")
sVwSt   = input.string("Solid", "", options = ["Solid", "Dashed", "Dotted"], group = GLN, inline = "L0",
     tooltip = "The VWAP ENGINE line: colour, width (1 thin to 6 thick) and style. Dashed and dotted apply in Current anchor only mode; the full-history plot draws solid.")
cVwUp   = input.color(#00E676, "VWAP slope / side: up", group = GLN, inline = "L1")
cVwDn   = input.color(#FF5252, "down", group = GLN, inline = "L1")
cVwFl   = input.color(#90A4AE, "flat", group = GLN, inline = "L1",
     tooltip = "Used when the VWAP line colour (master, Line shape row) is VWAP slope or Price side. Flat = the line moved less than one tick over 5 bars.")
cU1     = input.color(#EF5350, "Band 1  upper", group = GLN, inline = "L2")
cL1     = input.color(#26A69A, "lower", group = GLN, inline = "L2")
wB1     = input.int(1, "", minval = 1, maxval = 6, group = GLN, inline = "L2")
sB1     = input.string("Solid", "", options = ["Solid", "Dashed", "Dotted"], group = GLN, inline = "L2",
     tooltip = "Band 1 (±1σ, the trigger band): upper colour, lower colour, width, style.")
cU2     = input.color(#EF5350, "Band 2  upper", group = GLN, inline = "L3")
cL2     = input.color(#26A69A, "lower", group = GLN, inline = "L3")
wB2     = input.int(2, "", minval = 1, maxval = 6, group = GLN, inline = "L3")
sB2     = input.string("Solid", "", options = ["Solid", "Dashed", "Dotted"], group = GLN, inline = "L3",
     tooltip = "Band 2 (±2σ, the setup band): upper colour, lower colour, width, style.")
cU3     = input.color(color.new(#EF5350, 40), "Band 3  upper", group = GLN, inline = "L4")
cL3     = input.color(color.new(#26A69A, 40), "lower", group = GLN, inline = "L4")
wB3     = input.int(1, "", minval = 1, maxval = 6, group = GLN, inline = "L4")
sB3     = input.string("Solid", "", options = ["Solid", "Dashed", "Dotted"], group = GLN, inline = "L4",
     tooltip = "Band 3 (±3σ, the extreme): upper colour, lower colour, width, style.")
cPPoc   = input.color(#FFB74D, "Naked POC", group = GLN, inline = "L7")
wPPoc   = input.int(1, "", minval = 1, maxval = 5, group = GLN, inline = "L7")
sPPoc   = input.string("Dashed", "", options = ["Solid", "Dashed", "Dotted"], group = GLN, inline = "L7",
     tooltip = "Prior-session POCs that have not been tested yet: colour, width, style.")
cPVa    = input.color(color.new(#42A5F5, 0), "Prior VAH / VAL", group = GLN, inline = "L8")
wPVa    = input.int(1, "", minval = 1, maxval = 5, group = GLN, inline = "L8")
sPVa    = input.string("Dotted", "", options = ["Solid", "Dashed", "Dotted"], group = GLN, inline = "L8")
cR80    = input.color(#E040FB, "80% target", group = GLN, inline = "L8",
     tooltip = "The previous session's value area high and low (colour, width, style) and the 80% rule target line colour.")
cPrPoc  = input.color(color.new(#FFEB3B, 0), "Profile POC", group = GLN, inline = "L9")
wPrPoc  = input.int(2, "", minval = 1, maxval = 5, group = GLN, inline = "L9")
sPrPoc  = input.string("Solid", "", options = ["Solid", "Dashed", "Dotted"], group = GLN, inline = "L9")
cPrVa   = input.color(color.new(#5C6BC0, 0), "VAH / VAL", group = GLN, inline = "L9")
wPrVa   = input.int(1, "", minval = 1, maxval = 5, group = GLN, inline = "L9")
sPrVa   = input.string("Dashed", "", options = ["Solid", "Dashed", "Dotted"], group = GLN, inline = "L9",
     tooltip = "The side profile's own POC and value-area high / low — the POC / VAH / VAL of the VWAP ENGINE window (or the last N bars, see section 5). Always drawn across the side profile with a price tag at its right end: colour, width, style for the POC and for VAH / VAL.")
cEma1   = input.color(#FFD54F, "233 EMA", group = GLN, inline = "La")
wEma1   = input.int(4, "", minval = 1, maxval = 5, group = GLN, inline = "La")
sEma1   = input.string("Solid", "", options = ["Solid", "Dashed", "Dotted"], group = GLN, inline = "La")
cEma2   = input.color(#2962FF, "20W EMA", group = GLN, inline = "La")
wEma2   = input.int(4, "", minval = 1, maxval = 5, group = GLN, inline = "La")
sEma2   = input.string("Solid", "", options = ["Solid", "Dashed", "Dotted"], group = GLN, inline = "La",
     tooltip = "The 233 EMA and the 20-week EMA: colour, width, style each. Styles apply with Smooth x8 line shape (drawn lines); Raw and Stepped are plotted and draw solid.")
cW20    = input.color(#FFFFFF, "20W bands", group = GLN, inline = "Lb")
wW20    = input.int(1, "", minval = 1, maxval = 5, group = GLN, inline = "Lb")
sW20    = input.string("Solid", "", options = ["Solid", "Dashed", "Dotted"], group = GLN, inline = "Lb")
cW20Up  = input.color(color.new(#00FF88, 92), "fill up", group = GLN, inline = "Lb")
cW20Dn  = input.color(color.new(#FF1744, 92), "down", group = GLN, inline = "Lb",
     tooltip = "The 20W ATR bands: line colour, width, style, and the fill colours between band 2 and band 3 above (up) and below (down) the line. Transparency lives in the colour picker.")

// ---------------------------------------------------------------- 4 · SIGNALS
// ---- marks: what each symbol and colour means
// MR LONG / SHORT: the mean-reversion trade of the SIGNALS dropdown (entry, stop, target lines follow it).
// CE: the STRYK:CE reversion read on the same VWAP ENGINE, a second opinion with no trade lines.
// BREAK: a close through the VWAP or a band moving away from it, graded by the gates. RECLAIM: a close back inside a band toward the VWAP.
mrShape = input.string("Triangle", "MR mark", options = ["Triangle", "Arrow", "Circle", "Diamond", "Flag", "Square", "Dot"], group = GS, inline = "mk1")
mrSz    = input.string("Small", "size", options = ["Tiny", "Small", "Normal", "Large", "Shape (large)"], group = GS, inline = "mk1")
cMrUp   = input.color(#26A69A, "long", group = GS, inline = "mk1")
cMrDn   = input.color(#EF5350, "short", group = GS, inline = "mk1",
     tooltip = "MR LONG / SHORT MARK, under the candle for long and over it for short: the mean-reversion trade from the SIGNALS dropdown in master. Shape, size (Tiny to Large are small text glyphs that scale with the chart text; Shape (large) is TradingView's big label shape) and the two colours. This is the signal the entry / stop / target lines, the test table and the MR alerts follow.")
ceShape = input.string("Triangle", "CE mark", options = ["Triangle", "Arrow", "Circle", "Diamond", "Flag", "Square", "Dot"], group = GS, inline = "mk2")
ceSz    = input.string("Small", "size", options = ["Tiny", "Small", "Normal", "Large", "Shape (large)"], group = GS, inline = "mk2")
cCeUp   = input.color(#4ade80, "long", group = GS, inline = "mk2")
cCeDn   = input.color(#e63030, "short", group = GS, inline = "mk2",
     tooltip = "CE MARK: the STRYK:CE reversion read on the same VWAP ENGINE (touch band 2, close back inside band 1), a second opinion with no trade lines. When an MR mark and a CE mark print on the same candle, both engines agree.")
brShape = input.string("Diamond", "BREAK mark", options = ["Triangle", "Arrow", "Circle", "Diamond", "Flag", "Square", "Dot"], group = GS, inline = "mk3")
rcShape = input.string("Diamond", "RECLAIM mark", options = ["Triangle", "Arrow", "Circle", "Diamond", "Flag", "Square", "Dot"], group = GS, inline = "mk3")
sigSzIn = input.string("Tiny", "size", options = ["Tiny", "Small", "Normal", "Large", "Shape (large)"], group = GS, inline = "mk3",
     tooltip = "BREAK MARK: a close through the VWAP or a band moving AWAY from the VWAP (trend). RECLAIM MARK: a close back inside a band moving TOWARD the VWAP (return to value). Under the candle = up, over it = down. One size for both.")
cBrkUp  = input.color(#00E676, "Break / reclaim: up", group = GS, inline = "mk4")
cBrkDn  = input.color(#FF5252, "down", group = GS, inline = "mk4")
cBrkWk  = input.color(#9598A1, "weak", group = GS, inline = "mk4",
     tooltip = "Break / reclaim colours. UP / DOWN: the signal passed the gates needed (section 4 gates). WEAK (grey): fewer gates passed than needed; only shown when Gates needed is 0. Tick 'signal text' in the master SHOW list to write the band, grade and gate letters on each mark instead of a bare symbol.")
// a mark is a text glyph (scales down to really small) unless the size is Shape, which uses TradingView's big label shapes
f_glyph(string nm, bool up) =>
    nm == "Triangle" ? (up ? "▲" : "▼") : nm == "Arrow" ? (up ? "↑" : "↓") : nm == "Circle" ? "●" : nm == "Diamond" ? "◆" : nm == "Flag" ? "⚑" : nm == "Dot" ? "·" : "■"
f_shape(string nm, bool up) =>
    nm == "Triangle" ? (up ? label.style_triangleup : label.style_triangledown) : nm == "Arrow" ? (up ? label.style_arrowup : label.style_arrowdown) : nm == "Circle" ? label.style_circle : nm == "Diamond" ? label.style_diamond : nm == "Flag" ? label.style_flag : label.style_square
f_mkSz(string sz) => sz == "Shape (large)" ? size.large : sz == "Large" ? size.large : sz == "Normal" ? size.normal : sz == "Small" ? size.small : size.tiny
f_mark(array<label> arr, int x, float y, bool up, string nm, string sz, color c, int keep) =>
    bool shp = sz == "Shape (large)"
    array.push(arr, label.new(x, y, shp ? "" : f_glyph(nm, up), yloc = up ? yloc.belowbar : yloc.abovebar, style = shp ? f_shape(nm, up) : label.style_none, color = c, textcolor = c, size = f_mkSz(sz)))
    while array.size(arr) > keep
        label.delete(array.shift(arr))
armBars = input.int(20, "Setup lasts (bars)", minval = 2, maxval = 200, group = GS, inline = "a")
stopTk  = input.int(1, "Stop ticks past extreme", minval = 0, maxval = 100, group = GS, inline = "a",
     tooltip = "SETUP LASTS: a setup-band touch stays armed this many bars waiting for the trigger. STOP: this many ticks beyond the most extreme price of the stretch (original rules) or beyond the signal candle (break / reclaim).")
tgtMode = input.string("VWAP", "MR target", options = ["VWAP", "Opposite trigger band"], group = GS, inline = "t")
mrGateF = input.bool(false, "MR needs gate F", group = GS, inline = "t",
     tooltip = "ORIGINAL RULES. TARGET: the VWAP (the classic, tested target) or the trigger band on the other side (bigger reward, lower hit rate). MR NEEDS GATE F: the trigger candle's delta must point the trade's way (replaces 'delta must agree').")
rrA     = input.float(2.0, "A reward (R)", minval = 0.5, maxval = 10.0, step = 0.5, group = GS, inline = "rr")
rrB     = input.float(5.0, "B reward (R)", minval = 0.5, maxval = 20.0, step = 0.5, group = GS, inline = "rr",
     tooltip = "A REWARD: the profit target of setup A in multiples of its risk (2 = 1:2). B REWARD: the profit target of setup B (5 = 1:5).")
dirMode = input.string("Both", "Direction", options = ["Both", "Shorts only", "Longs only"], group = GS, inline = "dm")
sessOn  = input.bool(false, "Only in session", group = GS, inline = "dm")
sigSess = input.session("0830-1500", "", group = GS, inline = "dm",
     tooltip = "DIRECTION: which side every signal engine trades. ONLY IN SESSION: signals trigger only inside this Chicago-time window (0830-1500 = the cash session); setups can still arm outside it. Applies to every anchor in the test table so the comparison stays fair.")
brkVw   = input.bool(true, "at VWAP", group = GS, inline = "bt")
brkB1   = input.bool(true, "±1σ", group = GS, inline = "bt")
brkB2   = input.bool(true, "±2σ", group = GS, inline = "bt")
brkB3   = input.bool(true, "±3σ", group = GS, inline = "bt",
     tooltip = "Which break / reclaim signals print and at which lines. BREAK = a close through the line moving away from the VWAP: trade with the break, target the next band out. RECLAIM = a close back inside a band moving toward the VWAP: target the next band in. The VWAP line only gives breaks (crossing it is both away and toward).")
gNeed   = input.int(3, "Gates needed", minval = 0, maxval = 5, group = GS, inline = "gn")
confN   = input.int(0, "confirmation bars", minval = 0, maxval = 5, group = GS, inline = "gn",
     tooltip = "GATES NEEDED: how many of the switched-on gates below must pass for a break / reclaim to print (0 = every cross, graded). The grade, e.g. 3/5, is written on each signal either way.\nCONFIRMATION BARS: after the signal candle, this many more candles must also close on the signal side of the line before the signal prints (0 = print on the signal candle). Confirmed signals are later but fail less.")
gA      = input.bool(true, "A · Acceptance", group = GS, inline = "ga")
accTk   = input.int(2, "beyond by (ticks)", minval = 0, maxval = 100, group = GS, inline = "ga")
accPct  = input.int(60, "close in outer %", minval = 0, maxval = 100, group = GS, inline = "ga",
     tooltip = "A · ACCEPTANCE (price only, was C · close strength): the candle closes past the line by at least this many ticks AND closes in the outer part of its own range in the signal's direction (60 = top 60% of the candle for an up cross). Throws out wicks and weak closes that poke through and give it back.")
gS      = input.bool(true, "S · Size", group = GS, inline = "gs")
sizeK   = input.float(1.2, "volume ≥ × normal", minval = 0.5, maxval = 5.0, step = 0.1, group = GS, inline = "gs",
     tooltip = "S · SIZE (volume only, was V · volume): the candle's volume is at least this multiple of NORMAL volume, where normal = the average volume at this same time of day over recent sessions (so an 08:30 candle is compared with other 08:30 candles, not with the quiet overnight). 1.2 = 20% bigger than normal.")
gF      = input.bool(true, "F · Flow", group = GS, inline = "gf")
flowPct = input.int(10, "delta ≥ % of volume", minval = 0, maxval = 100, group = GS, inline = "gf",
     tooltip = "F · FLOW (this candle's delta, was D · delta agrees): the candle's delta points the signal's way and is at least this share of its volume. 10 = at least 10% more buying than selling for an up signal. Delta comes from the Delta source in section 1.")
gP      = input.bool(true, "P · Pressure", group = GS, inline = "gp")
pressPct = input.int(0, "HTF delta ≥ %", minval = 0, maxval = 100, group = GS, inline = "gp",
     tooltip = "P · PRESSURE (higher-timeframe delta): the delta building inside the current higher-timeframe candle (section 1, 1 hour by default) points the signal's way and is at least this share of that candle's volume. 0 = only the direction must agree. Asks: is the bigger picture pushing the same way?")
gT      = input.bool(true, "T · Trend", group = GS, inline = "gt")
trdSrc  = input.string("VWAP slope", "", options = ["VWAP slope", "EMA vote"], group = GS, inline = "gt")
trdN    = input.int(12, "bars", minval = 2, maxval = 100, group = GS, inline = "gt",
     tooltip = "T · TREND (off by default; it hurt results in testing): VWAP SLOPE = the VWAP ENGINE line is rising for an up signal (falling for down) over this many bars. EMA VOTE = price is on the signal's side of most of the 233 EMA and the 20-week EMA (was the DRE bias filter).")


// ---------------------------------------------------------------- 4 · VOLUME PROFILE & SESSION LEVELS
vpSel   = input.string("Buy vs sell", "Bars show", options = ["Volume", "Buy vs sell", "Delta"], group = GP, inline = "pm")
vpSrc   = input.string("Tick data (1-minute)", "data", options = ["Chart bars", "Tick data (1-minute)"], group = GP, inline = "pm",
     tooltip = "BARS SHOW. Every bar starts at the centre axis and grows to the right. VOLUME: one bar per row. BUY VS SELL: one bar per row on the volume scale, the green part is the buying and the red part is the selling. DELTA: the net of buying minus selling per row, green when buying won and red when selling won.\nDATA. CHART BARS spreads each candle's volume across its high-low range and splits buy / sell by the candle's own delta (fast). TICK DATA (1-MINUTE) uses the intrabar closes and volume inside each candle (1-minute up to the 1-hour chart, 5-minute up to 4 hours, 30-minute on daily, 4-hour on weekly), so the rows show where the volume really traded and buy / sell comes from each intrabar's direction (finer, a little heavier).")
vpTag   = input.string("Delta", "Tags show", options = ["Delta", "Buy / sell", "Delta + buy / sell", "Imbalanced rows only"], group = GP, inline = "pt")
vpImb   = input.float(3.0, "imbalance ×", minval = 1.1, maxval = 20, step = 0.1, group = GP, inline = "pt",
     tooltip = "The number at the end of each bar. DELTA: buying minus selling for the row (+ green, − red). BUY / SELL: buy volume / sell volume. DELTA + BUY / SELL: both. IMBALANCED ROWS ONLY: tags only on the rows where one side is at least IMBALANCE × the other (3 = buying is 3× the selling or the reverse), marked ▲ buy imbalance or ▼ sell imbalance; the other rows are dimmed so the imbalances stand out.")
vpCover = input.string("VWAP engine window", "Covers", options = ["VWAP engine window", "Last N bars"], group = GP, inline = "p0")
vpN     = input.int(276, "N", minval = 2, maxval = 20000, group = GP, inline = "p0",
     tooltip = "COVERS: the same bars as the VWAP ENGINE on the chart (default), or a fixed number of the last N bars (276 = 23 hours of 5-minute bars).")
vpRows  = input.int(70, "Rows", minval = 10, maxval = 150, group = GP, inline = "p1")
vpHvn   = input.int(60, "high volume at %", minval = 10, maxval = 100, group = GP, inline = "p1")
vpVaPct = input.int(50, "value area %", minval = 50, maxval = 95, group = GP, inline = "p1")
vpVaShade = input.bool(true, "shade VA rows", group = GP, inline = "p1",
     tooltip = "ROWS: how many price rows the profile is split into (more = finer). HIGH VOLUME: a row with at least this % of the POC row's volume is coloured as high volume. VALUE AREA: the share of the window's volume inside the value area, grown from the POC toward the heavier side; 70% is the market-profile standard. SHADE VA ROWS: rows inside the value area take the value-area colour, so the POC (yellow), the value area and the high-volume rows all read from the profile itself. Length and gap are in the RIGHT EDGE row of the master section.")
vpTagMin = input.int(2, "Tags: at least", minval = 0, maxval = 100, group = GP, inline = "p3")
vpTagSz  = input.string("Tiny", "size", options = ["Tiny", "Small", "Normal"], group = GP, inline = "p3",
     tooltip = "The row numbers. AT LEAST: tags never sit closer to the centre axis than this many bars, so a tiny bar, a zero bar or a zero bar still has its tag just right of the centre; a longer bar carries its tag along with it. SIZE: tag text size. Tags on / off is in the master SHOW list.")
cVpRow  = input.color(color.new(#2962FF, 45), "Rows", group = GP, inline = "v3")
cVpHvn  = input.color(color.new(#FF9800, 20), "high volume", group = GP, inline = "v3")
cVpVa   = input.color(color.new(#5C6BC0, 35), "value area", group = GP, inline = "v3")
cVpPoc  = input.color(color.new(#FFEB3B, 0), "POC", group = GP, inline = "v3",
     tooltip = "Profile colours: normal rows, high-volume rows, value-area rows, and the POC row (the price with the most volume). Buy vs sell and Delta use the engine Bull / Bear colours for the bars; the POC row keeps a POC-colour border. The POC / VAH / VAL lines across the profile have their own colour, width and style in section 3.")
r80Need = input.int(2, "80% rule: 30-min closes inside prior value", minval = 1, maxval = 6, group = GP,
     tooltip = "Market Profile 80% rule: the session opens outside the prior session's value area, then price closes back inside it for this many consecutive 30-minute periods. A target line is then drawn at the opposite edge of that value area (colour in section 3). The name is a label, not a measured win rate.")

// ---------------------------------------------------------------- 6 · MDP CANDLES, EMAs & 20-WEEK
mdSensIn = input.string("Average", "MDP sensitivity", options = ["Fast", "Average", "Slow"], group = GM, inline = "md")
mdTypeIn = input.string("Both", "type", options = ["Both", "Aggression only", "Absorption only"], group = GM, inline = "md",
     tooltip = "MAX DELTA PRINT: the session's most extreme delta candle. SENSITIVITY: Fast finds more prints, Slow only the biggest. TYPE: aggression (delta far beyond normal on heavy volume), absorption (heavy volume that barely moved price), or both.")
mdReset = input.bool(true, "restart each session", group = GM, inline = "md2")
mdConfirm = input.bool(true, "confirm on close", group = GM, inline = "md2",
     tooltip = "RESTART EACH SESSION: each 17:00 session starts a fresh record, so the first big print of a new session can qualify. CONFIRM ON CLOSE: a print only counts once its candle has closed (no flicker while it forms).")
w20M1   = input.float(1.0, "×", minval = 0.25, maxval = 10.0, step = 0.25, group = GM, inline = "w1")
w20M2   = input.float(2.0, "", minval = 0.25, maxval = 10.0, step = 0.25, group = GM, inline = "w1")
w20M3   = input.float(3.0, "", minval = 0.25, maxval = 10.0, step = 0.25, group = GM, inline = "w1",
     tooltip = "Bands around the 20-week EMA at these multiples of the weekly ATR (14), the STRYK:20W method. Price out at band 2–3 is a big weekly stretch.")

// ---------------------------------------------------------------- 6 · ANCHOR TEST & ALERTS
tblSzIn = input.string("Tiny", "Test table text", options = ["Tiny", "Small", "Normal"], group = GT, inline = "tt")
costTk  = input.float(2.0, "cost per trade (ticks)", minval = 0, maxval = 100, step = 0.5, group = GT, inline = "tt",
     tooltip = "TEXT: size of the anchor test table.\nCOST PER TRADE: commission + slippage for the whole round trip, in ticks, taken off every test trade before it is counted (2 ticks on MES = about $1 commission + 1 tick of slip). It is converted to R from each trade's own stop distance, so a tight stop pays more R in costs than a wide one. The table then shows NET results: Net R, R / trade, win %, profit factor and max drawdown are all after this cost. 0 = gross.")
alVw    = input.bool(true, "Alert: price crosses the VWAP", group = GT, inline = "a1")
alBand  = input.string("Any", "band cross", options = ["Any", "Close outside", "Close back inside", "Off"], group = GT, inline = "a1",
     tooltip = "VWAP CROSS: a candle closes on the other side of the VWAP ENGINE line. BAND CROSS: a candle closes outside a band (Close outside), back inside one (Close back inside), or either (Any). Create the alert on the indicator with 'Any alert() function call'.")
alSig   = input.bool(true, "Alert: MR / break-reclaim / triangle signals", group = GT,
     tooltip = "One alert for every signal the chart prints: mean-reversion entries, target and stop hits, break / reclaim signals (at the gates needed) and CE triangles.")
alSess  = input.bool(true, "Alert: naked POC touch, leaving value, 80% rule", group = GT,
     tooltip = "Session-level alerts: price trades into a naked prior POC, price closes outside the developing value area after being inside it, and the 80% rule triggers.")

// ---- RIGHT EDGE — where everything after the last candle sits, in bars, so nothing runs into anything else
vpOff   = input.int(25, "RIGHT EDGE: profile gap", minval = 0, maxval = 300, group = G0, inline = "re")
vpWid   = input.int(40, "profile length", minval = 5, maxval = 300, group = G0, inline = "re")
labOff  = input.int(2, "tags at", minval = 0, maxval = 400, group = G0, inline = "re")
labGapTk = input.int(0, "tag gap (ticks)", minval = 0, maxval = 1000, group = G0, inline = "re")
txtSz   = input.string("Tiny", "tag size", options = ["Tiny", "Small", "Normal", "Large"], group = G0, inline = "re")
tagMode = input.string("Short", "tag text", options = ["Short", "Full"], group = G0, inline = "re")
// effective switches
bool   isMob   = devMode == "Mobile"
bool   labOn   = labOnIn and not isMob
bool   vpOn    = vpOnIn and not isMob
bool   mClean  = modeIn == "Clean (candles only)"
bool   memSaver = modeIn == "Replay"
bool   showAll = mMaster and not mClean
bool   mPaint  = mMaster and mPaintIn
bool   mMdp    = mMaster and mMdpIn
bool   mVp     = vpOn
string vpMode  = vpSel
float  setK    = b2
float  trigK   = b1
bool   mIbOn   = showAll and mIbIn
color  cTgt    = #26A69A      // test-table win / loss colours
color  cStp    = #EF5350
string TZ      = "America/Chicago"
f_sz(string s) => s == "Large" ? size.large : s == "Normal" ? size.normal : s == "Small" ? size.small : size.tiny
f_pos(string s) => s == "Top right" ? position.top_right : s == "Middle right" ? position.middle_right : s == "Bottom right" ? position.bottom_right : s == "Top left" ? position.top_left : s == "Middle left" ? position.middle_left : position.bottom_left
f_ls(string st) => st == "Dashed" ? line.style_dashed : st == "Dotted" ? line.style_dotted : line.style_solid
f_stamp(int t) => ""
// right-edge label queue: every element queues its level labels here; the core
// places them all at the end of the script, sorted and pushed apart
var array<float>  rqP = array.new_float()
var array<string> rqT = array.new_string()
var array<color>  rqC = array.new_color()
f_rq(float p, string t, color c) =>
    if labOn and not na(p)
        array.push(rqP, p)
        array.push(rqT, t)
        array.push(rqC, c)
// side-profile line queue: every POC / VAH / VAL level is drawn across the side
// profile (axis to its right end), never across the candles, tag at the right end
var array<float>  spP = array.new_float()
var array<string> spT = array.new_string()
var array<color>  spC = array.new_color()
var array<int>    spW = array.new_int()
var array<string> spS = array.new_string()
f_pq(float p, string t, color c, int w, string st) =>
    if not na(p)
        array.push(spP, p)
        array.push(spT, t)
        array.push(spC, c)
        array.push(spW, w)
        array.push(spS, st)
bool drawNow = barstate.islastconfirmedhistory or (barstate.isrealtime and barstate.isconfirmed)
f_blk1() =>
    if drawNow
        array.clear(rqP)
        array.clear(rqT)
        array.clear(rqC)
        array.clear(spP)
        array.clear(spT)
        array.clear(spC)
        array.clear(spW)
        array.clear(spS)
    true
f_blk1()
var string lastSigTxt = ""
// tuned defaults copied from the source scripts
string replayPaint = "Delta % (imbalance)"
string deltaSrc = dSrcIn == "Footprint, fall back to estimate" ? "Auto (footprint → estimate)" : "Estimate only"
int fpTicks = 4
bool autoRaiseTf = true
int vwapSmooth = 5
int emaLen = 233
float emaSrc = close
int emaSmooth = 3
color colBull = #4ade80
color colNeut = #3b82f6
color colBear = #e63030
float paintSens = 1.5
string paintCurve = "Boosted"
float paintFloor = 0.0
bool dpctCalib = true
int dpctCalibLook = 100
bool dpctGateOn = true
int dpctGateFloor = 30
bool dpctTrajOn = true
float dpctTrajTilt = 0.65
bool dpctStreakOn = true
int dpctStreakThresh = 60
float dpctStreakBoost = 0.15
int dpctStreakCap = 5
int partEmaLen = 8
int partLook = 100
bool partFast = true
int bellPeak = 60
int bellWidth = 30
bool climaxCuts = false
float climaxDecay = 0.07
bool useAgree = true
float agreePen = 0.35
bool fuelEmaOn = true
float fuelEmaBoost = 0.25
int bandClimax = 85
int pocBinTicks = 4
string pocBandMode = "Value area (VAH/VAL)"
string htfRefMode = "HTF window (N candles)"
float htfInsideLean = 0.35
string htfIntMode = "Blend"
int htfAccBars = 3
float htfSizeFull = 2.0
int htfMigK = 3
float pocBandPct = 25
float pocRampPct = 25
float pocAlignBoost = 0.35
int ptCalibLook = 100
float ptAlignBoost = 0.3
float ptPrevBoost = 0.25
bool ptVaGate = true
int vaPct = 70
float vaRampPct = 50
float vaAlignBoost = 0.3
float drRampPct = 50
float drAlignBoost = 0.0
int rsiLen = 14
bool rsiCalib = true
int rsiCalibLook = 100
int rsiVelLen = 3
float rsiVelBoost = 0.25
int rsiFastLen = 7
int rsiSlowLen = 21
float rsiFsBoost = 0.25
color rsiDivBearCol = #ff6a00
color rsiDivBullCol = #00bcd4
bool arCalib = true
int arCalibLook = 100
float arAlignBoost = 0.3
float arTightBoost = 0.25
int arRangeLook = 20
float vwAlignBoost = 0.3
int vwSlopeLen = 5
float vwExhaustSigma = 2.0
color vwExhaustCol = #ffb300
bool ccCalib = true
int ccCalibLook = 100
int ccGateFloor = 30
float ccAlignBoost = 0.25
float ccStreakBoost = 0.15
int ccStreakCap = 5
string weekStartDay = "Sunday"
string sessDetect = "Auto (symbol session)"
int sessOpenHr = 17
string asianStart = "2000"
string asianEnd = "0400"
int ptMigBack = 3
string mdSens = mdSensIn
string mdType = mdTypeIn
string mdSessStr = "1700-1600:1234567"
string mdTzIn = "America/Chicago"
float mdMinDelta = 0.0
float mdBaseHours = 8.0
int mdTodSess = 20
int mdTodWarm = 5
string mdAbsMode = "Either"
color mdColAgg = #ff7b00
color mdColAbs = #a855f7

// ── Resolution: delta TF, chart seconds, auto intrabar ladder ────────────────
int chartSec = timeframe.in_seconds(timeframe.period)
string dTf = autoRaiseTf and timeframe.in_seconds(htfTf) < chartSec ? timeframe.period : htfTf
f_blk2() =>
    if not autoRaiseTf and timeframe.in_seconds(htfTf) < chartSec
        runtime.error("Delta timeframe is below the chart timeframe. Raise the delta timeframe or enable auto-raise.")
    true
f_blk2()
// intrabar timeframe scales with the chart so every chart bar holds at most ~60 intrabars:
// 1-minute up to the 1-hour chart, 5-minute to 4 hours, 30-minute on daily, 4-hour on weekly.
// A fixed 1-minute pull gave 240–1440 intrabars per bar on 4h / daily charts and every per-bar
// loop over them (delta, bar profile, session profile, tick arrays) ran that many times → timeouts.
// memory saver: requesting the CHART timeframe from security_lower_tf returns a
// one-element array per bar — no intrabar data is fetched or held at all.
string ltfAuto = chartSec <= 3600 ? "1" : chartSec <= 14400 ? "5" : chartSec <= 86400 ? "30" : "240"
string ltf = memSaver or timeframe.in_seconds(ltfAuto) >= chartSec ? timeframe.period : ltfAuto
signedVol() =>
    float v = nz(volume)
    float out = 0.0
    if close > open
        out := v
    else if close < open
        out := -v
    else if close > close[1]
        out := v
    else if close < close[1]
        out := -v
    out

// footprint first (unconditional); estimate requested only when needed (dynamic request)
// unconditional: this exact call is compiler-proven on the account. In
// "Estimate only" mode the result is simply ignored (fpOk gates it below).
footprint fp = request.footprint(fpTicks, 70, 300)
bool fpOk = deltaSrc != "Estimate only" and not na(fp)
// ONE intrabar pull serves everything: signed volume (estimate-path delta),
// close + volume (POC profiles). Three separate calls previously fetched the
// same intrabars three times over — this is a 3× saving on the intrabar budget.
[ivS, pocIvC, pocIvV] = request.security_lower_tf(syminfo.tickerid, ltf, [signedVol(), close, nz(volume)])

// ── Per-bar delta ────────────────────────────────────────────────────────────
float barBuy  = 0.0
float barSell = 0.0
if fpOk
    barBuy  := nz(fp.buy_volume())
    barSell := nz(fp.sell_volume())
else
    int nIB = array.size(ivS)
    if nIB > 0
        for i = 0 to nIB - 1
            float sv = nz(array.get(ivS, i))
            if sv > 0
                barBuy += sv
            else
                barSell -= sv
    else
        float v0 = nz(volume)
        barBuy  := close > open ? v0 : 0.0
        barSell := close < open ? v0 : 0.0
if dSrcIn == "Bar direction only (weak)"
    float v1 = nz(volume)
    barBuy  := close > open ? v1 : close == open and close > nz(close[1]) ? v1 : 0.0
    barSell := close < open ? v1 : close == open and close < nz(close[1]) ? v1 : 0.0
float barDelta = barBuy - barSell
f_secMdp() =>
    // ── MDP engine — candle override, rides on whichever paint mode is active ────
    bool mdpPaintOn = true   // detection always runs (MDP lines + MDP range engine); paint override gated by mMdp at output

    string mdTz = mdTzIn == "Exchange" ? syminfo.timezone : mdTzIn
    bool mdInSess = not na(time(timeframe.period, mdSessStr, mdTz))
    // session open is read from the CLOCK: on a 17:00-16:00 session every bar is
    // inside the session, so "inSess turned on" would fire once and never again
    int mdOpenMin = int(nz(str.tonumber(str.substring(mdSessStr, 0, 2)), 17)) * 60 +
         int(nz(str.tonumber(str.substring(mdSessStr, 2, 4)), 0))
    int mdMinOfDay = hour(time, mdTz) * 60 + minute(time, mdTz)
    bool mdDailyPlus = timeframe.in_seconds() >= 86400
    bool mdNewSess = mdDailyPlus ? barstate.isnew :
         mdMinOfDay >= mdOpenMin and (mdMinOfDay[1] < mdOpenMin or mdMinOfDay[1] > mdMinOfDay)
    // slot comes from the clock, not a bar counter: a chart with missing bars would
    // drift a counter out of alignment, so the same session minute would stop
    // mapping to the same bucket
    int mdTfSec = math.max(1, timeframe.in_seconds())
    int mdElapsed = (mdMinOfDay - mdOpenMin) * 60
    if mdElapsed < 0
        mdElapsed += 86400
    int mdSlot = mdInSess ? math.min(4999, math.max(0, int(math.floor(mdElapsed / mdTfSec)))) : -1

    float mdVol = barBuy + barSell > 0 ? barBuy + barSell : nz(volume)
    float mdAbs = math.abs(nz(barDelta))
    float mdEffPct = mdVol > 0 ? mdAbs / mdVol : na

    // rolling baseline — set in hours so it spans the same market time on any chart
    // clamped at 300: eight rolling medians run off this length on every bar. A
    // median over 300 samples is stable; longer windows cost real memory to move the
    // number by noise. Matches max_bars_back, so the buffer reserved and the history
    // requested are the same size.
    int mdBaseBars = math.min(300, math.max(20, int(math.round(mdBaseHours * 3600 / timeframe.in_seconds()))))
    // modified z (median/MAD): the outlier being measured barely moves the yardstick,
    // where a mean/stdev z is inflated by the very print it is meant to flag
    float mdMed = ta.median(barDelta, mdBaseBars)
    float mdMad = ta.median(math.abs(barDelta - mdMed), mdBaseBars)
    float mdVolSma = ta.sma(mdVol, mdBaseBars)
    float mdZ = not na(mdMad) and mdMad > 0 ? math.abs(0.6745 * (barDelta - mdMed) / mdMad) : na

    // time-of-day slots: one per bar-of-session, EMA of volume and |delta|.
    // ORDER MATTERS: the baseline is READ before this bar is folded into it. Doing
    // it the other way lets a huge bar inflate the very average it is measured
    // against, which quietly hides the prints this engine exists to find — the same
    // masking the modified z-score avoids on the delta side.
    var array<float> mdTodVol = array.new_float(0)
    var array<float> mdTodDel = array.new_float(0)
    var array<int> mdTodN = array.new_int(0)
    if mdTodSess > 0 and mdInSess and mdSlot >= 0
        while array.size(mdTodVol) <= mdSlot
            array.push(mdTodVol, na)
            array.push(mdTodDel, na)
            array.push(mdTodN, 0)
    bool mdSlotReady = mdTodSess > 0 and mdSlot >= 0 and mdSlot < array.size(mdTodN) and array.get(mdTodN, mdSlot) >= mdTodWarm
    float mdSlotVol = mdSlotReady ? array.get(mdTodVol, mdSlot) : na
    float mdSlotDel = mdSlotReady ? array.get(mdTodDel, mdSlot) : na
    float mdRelVol = mdSlotReady and mdSlotVol > 0 ? mdVol / mdSlotVol : (not na(mdVolSma) and mdVolSma > 0 ? mdVol / mdVolSma : na)
    float mdRelDel = mdSlotReady and mdSlotDel > 0 ? mdAbs / mdSlotDel : na
    // now fold this bar into its slot, after it has been judged against the others
    if mdTodSess > 0 and mdInSess and mdSlot >= 0
        int mn = array.get(mdTodN, mdSlot)
        float mAlpha = 2.0 / (math.min(mdTodSess, mn + 1) + 1.0)
        float mpv = array.get(mdTodVol, mdSlot)
        float mpd = array.get(mdTodDel, mdSlot)
        array.set(mdTodVol, mdSlot, na(mpv) ? mdVol : mpv + mAlpha * (mdVol - mpv))
        array.set(mdTodDel, mdSlot, na(mpd) ? mdAbs : mpd + mAlpha * (mdAbs - mpd))
        array.set(mdTodN, mdSlot, mn + 1)

    // effort vs result: volume per tick of range. Huge size that barely moves price
    // is absorption — someone large filling passively while the aggressor exhausts.
    float mdRngTicks = math.max(1.0, (high - low) / syminfo.mintick)
    float mdEffort = mdVol / mdRngTicks
    float mdMedEffort = ta.median(mdEffort, mdBaseBars)
    float mdMedRng = ta.median(mdRngTicks, mdBaseBars)
    float mdMedAbs = ta.median(mdAbs, mdBaseBars)
    float mdMedEffPct = ta.median(mdEffPct, mdBaseBars)
    float mdEffortRatio = not na(mdMedEffort) and mdMedEffort > 0 ? mdEffort / mdMedEffort : na
    float mdRangeRatio = not na(mdMedRng) and mdMedRng > 0 ? mdRngTicks / mdMedRng : na
    // body measure: a bar that travels hard both ways and closes near its open is
    // absorption with a WIDE range — the range test alone never sees it
    float mdBodyTicks = math.max(1.0, math.abs(close - open) / syminfo.mintick)
    float mdEffortB = mdVol / mdBodyTicks
    float mdMedEffortB = ta.median(mdEffortB, mdBaseBars)
    float mdMedBody = ta.median(mdBodyTicks, mdBaseBars)
    float mdEffortBRatio = not na(mdMedEffortB) and mdMedEffortB > 0 ? mdEffortB / mdMedEffortB : na
    float mdBodyRatio = not na(mdMedBody) and mdMedBody > 0 ? mdBodyTicks / mdMedBody : na
    // every part is a multiple of its own baseline, so nothing caps: a print twice
    // as extreme as the incumbent scores twice as high instead of tying at the top
    float mdMagRatio = not na(mdMedAbs) and mdMedAbs > 0 ? mdAbs / mdMedAbs : na
    float mdEffRatio = not na(mdMedEffPct) and mdMedEffPct > 0 ? mdEffPct / mdMedEffPct : na
    float mdAnomRatio = mdSlotReady and not na(mdRelDel) ? mdRelDel : mdZ
    float mdComposite = (0.40 * nz(mdMagRatio) + 0.30 * nz(mdAnomRatio) + 0.30 * nz(mdEffRatio))

    float mdMinZ = switch mdSens
        "Fast"    => 2.0
        "Average" => 3.5
        => 5.0
    float mdMinEffort = switch mdSens
        "Fast"    => 1.5
        "Average" => 2.0
        => 3.0
    float mdMaxRange = switch mdSens
        "Fast"    => 0.85
        "Average" => 0.70
        => 0.55
    float mdMinRelVol = switch mdSens
        "Fast"    => 1.2
        "Average" => 1.6
        => 2.5

    bool mdStatsReady = not na(mdZ) and not na(mdRelVol) and not na(mdComposite)
    bool mdAggrPass = mdStatsReady and mdZ >= mdMinZ and mdRelVol >= mdMinRelVol and mdAbs >= mdMinDelta
    bool mdAbsByRange = mdAbsMode != "Body" and not na(mdEffortRatio) and not na(mdRangeRatio) and
         mdEffortRatio >= mdMinEffort and mdRangeRatio <= mdMaxRange
    bool mdAbsByBody = mdAbsMode != "Range" and not na(mdEffortBRatio) and not na(mdBodyRatio) and
         mdEffortBRatio >= mdMinEffort and mdBodyRatio <= mdMaxRange
    bool mdAbsPass = mdStatsReady and mdRelVol >= mdMinRelVol and (mdAbsByRange or mdAbsByBody)
    // an absorption print is ranked on whichever measure it actually qualified on
    float mdAbsEffort = mdAbsByRange and mdAbsByBody ? math.max(nz(mdEffortRatio), nz(mdEffortBRatio)) :
         mdAbsByBody ? nz(mdEffortBRatio) : nz(mdEffortRatio)
    bool mdOkAggr = mdType != "Absorption only"
    bool mdOkAbs = mdType != "Aggression only"
    bool mdAbsOnly = mdAbsPass and mdOkAbs and not (mdAggrPass and mdOkAggr)
    bool mdBoth = mdAbsPass and mdOkAbs and mdAggrPass and mdOkAggr
    bool mdIsAbs = mdAbsOnly or (mdBoth and mdAbsEffort > nz(mdComposite))
    bool mdQualified = mdpPaintOn and mdInSess and ((mdAggrPass and mdOkAggr) or (mdAbsPass and mdOkAbs))
    float mdCandScore = mdIsAbs ? mdAbsEffort : mdComposite

    // Each type keeps its OWN incumbent. The two scores are not on one scale — a
    // composite (aggression) runs about 5.7 where an effort ratio (absorption) runs
    // about 3.7 — so a single incumbent let the first aggression print of the session
    // lock absorption out for the rest of it: a qualifying absorption bar cleared a
    // typical aggression incumbent only 20% of the time. Competing like against like
    // removes the comparison instead of trying to rescale one into the other.
    var float mdScoreAgg = na
    var float mdScoreAbs = na
    if mdNewSess and mdReset
        mdScoreAgg := na
        mdScoreAbs := na
    float mdIncumbent = mdIsAbs ? mdScoreAbs : mdScoreAgg
    // >= not > : ties go to the newer print, which is the more relevant one
    bool mdBetter = na(mdIncumbent) or mdCandScore >= mdIncumbent
    bool mdAccept = mdQualified and mdBetter and (mdConfirm ? barstate.isconfirmed : true)
    if mdAccept
        if mdIsAbs
            mdScoreAbs := mdCandScore
        else
            mdScoreAgg := mdCandScore
    [mdAccept, mdIsAbs, mdRelVol]
[mdAccept, mdIsAbs, mdRelVol] = f_secMdp()
// ── POC profile engine (Delta size / Delta size HTF) — intrabar volume-at-price,
// independent of footprint availability (see tooltip above). ────────────────
int nPocIB = memSaver ? 0 : math.min(array.size(pocIvC), array.size(pocIvV))
float pocBinSize = pocBinTicks * syminfo.mintick
addBin(map<int, float> m, int k, float v) =>
    map.put(m, k, (map.contains(m, k) ? map.get(m, k) : 0.0) + v)
pocOf(map<int, float> m) =>
    float best = -1.0
    int bestK = 0
    array<int> ks = map.keys(m)
    for k in ks
        float v = map.get(m, k)
        if v > best
            best := v
            bestK := k
    best > 0 ? bestK * pocBinSize : na
f_binProfile(map<int, float> m, int startBack, simple int n) =>
    // n = 0 must do nothing: `for i = 0 to -1` counts DOWN in Pine and would read high[-1]
    if n > 0
        for i = startBack to startBack + n - 1
            float hi = high[i]
            float lo = low[i]
            float vo = nz(volume[i])
            if not na(hi) and not na(lo) and vo > 0
                int bHi = math.round(hi / pocBinSize)
                int bLo = math.round(lo / pocBinSize)
                // 60 slices per bar instead of 200: this loop runs for every bar of every
                // window profile inside three request contexts, so it is the heaviest thing
                // in the script. Past ~60 slices the POC and value area stop moving.
                int span = math.max(1, bHi - bLo + 1)
                int steps = math.min(span, 60)
                float per = vo / steps
                float stepSz = span * 1.0 / steps
                for k = 0 to steps - 1
                    int b = bLo + math.round(k * stepSz)
                    map.put(m, b, (map.contains(m, b) ? map.get(m, b) : 0.0) + per)
// value area: expand from the POC bin toward the heavier side until vaPct of
// the session's volume is inside. Returns [VAH, VAL] in price.
f_valueArea(map<int, float> m, int pct) =>
    float vah = na
    float val = na
    array<int> ks = map.keys(m)
    int n = array.size(ks)
    if n > 0
        array.sort(ks)
        array<float> vs = array.new_float(n, 0.0)
        float total = 0.0
        int pocIdx = 0
        float best = -1.0
        for i = 0 to n - 1
            float v = map.get(m, array.get(ks, i))
            array.set(vs, i, v)
            total += v
            if v > best
                best := v
                pocIdx := i
        float acc = array.get(vs, pocIdx)
        int up = pocIdx + 1
        int dn = pocIdx - 1
        float target = total * pct / 100.0
        while acc < target and (up < n or dn >= 0)
            float vUp = up < n ? array.get(vs, up) : -1.0
            float vDn = dn >= 0 ? array.get(vs, dn) : -1.0
            if vUp >= vDn
                acc += vUp
                up += 1
            else
                acc += vDn
                dn -= 1
        vah := array.get(ks, up - 1) * pocBinSize
        val := array.get(ks, dn + 1) * pocBinSize
        if vah <= val
            vah := vah + pocBinSize / 2.0
            val := val - pocBinSize / 2.0
    [vah, val]
// current window's [poc, vah, val], the POC of the same-sized window migBack
// bars back, and the POC of the previous non-overlapping window — all built in
// ONE request context, returned as floats only (never a map across the boundary).
f_windowProfile(simple int n, simple int migBack, simple bool wantPrev) =>
    map<int, float> prof = map.new<int, float>()
    f_binProfile(prof, 0, n)
    float poc = pocOf(prof)
    [vah, val] = f_valueArea(prof, vaPct)
    // migration reference: same-sized window migBack bars back (skipped if 0)
    float pocBack = na
    if migBack > 0
        map<int, float> profBack = map.new<int, float>()
        f_binProfile(profBack, migBack, n)
        pocBack := pocOf(profBack)
    // prior-period reference: the PREVIOUS non-overlapping window (shifted by n)
    float pocPrevWin = na
    if wantPrev
        map<int, float> profPrev = map.new<int, float>()
        f_binProfile(profPrev, n, n)
        pocPrevWin := pocOf(profPrev)
    [poc, vah, val, pocBack, pocPrevWin]
// this single chart bar's own POC (for the "Delta size" bar-level mode)
var map<int, float> barProf = map.new<int, float>()
map.clear(barProf)
f_blk5() =>
    if nPocIB > 0
        for i = 0 to nPocIB - 1
            float pc = array.get(pocIvC, i)
            float vv = nz(array.get(pocIvV, i))
            if not na(pc)
                addBin(barProf, math.round(pc / pocBinSize), vv)
    else if not memSaver
        addBin(barProf, math.round(close / pocBinSize), nz(volume))
    true
f_blk5()
float barPocNow = pocOf(barProf)
[barVahNow, barValNow] = f_valueArea(barProf, vaPct)
f_pocColor(float px, float anchor, float rng, float dlt, float avgAbs) =>
    color result = colNeut
    if not na(anchor) and not na(rng) and rng > 0
        float bandW = rng * (pocBandPct / 100.0)
        float rampW = rng * (pocRampPct / 100.0)
        float dist = px - anchor
        if math.abs(dist) <= bandW
            float centering = 1.0 - math.abs(dist) / bandW
            float dq = avgAbs > 0 ? 1.0 - math.min(1.0, math.abs(dlt) / avgAbs) : 0.5
            float depth = math.max(0.0, math.min(1.0, (centering + dq) / 2.0))
            int transp = int(math.round(70 - depth * 70))
            result := color.new(colNeut, transp)
        else
            float beyond = math.abs(dist) - bandW
            float frac = math.max(0.0, math.min(1.0, beyond / math.max(syminfo.mintick, rampW)))
            bool greenZone = dist > 0
            bool aligned = (greenZone and dlt > 0) or (not greenZone and dlt < 0)
            float adj = aligned ? math.min(1.0, frac + pocAlignBoost) : frac * (1.0 - pocAlignBoost)
            result := greenZone ? color.from_gradient(adj, 0, 1, colNeut, colBull) : color.from_gradient(adj, 0, 1, colNeut, colBear)
    result

// ── Delta-TF candle state ────────────────────────────────────────────────────
var float liveDelta = 0.0
var float liveBuy   = 0.0
var float liveSell  = 0.0
var float htfOpen   = na
var array<float> deltaHist = array.new_float()
var float htfHiPoc = na
var float htfLoPoc = na
var float prevHtfPocVal = na
var float prevHtfRangeVal = na
var float prevHtfVah = na
var float prevHtfVal = na
var map<int, float> htfProf = map.new<int, float>()
bool htfRoll = timeframe.change(dTf)
if htfRoll
    if not na(htfOpen)
        array.push(deltaHist, liveDelta)
        if array.size(deltaHist) > lenN
            array.shift(deltaHist)
        prevHtfPocVal := pocOf(htfProf)
        prevHtfRangeVal := (na(htfHiPoc) or na(htfLoPoc)) ? na : (htfHiPoc - htfLoPoc)
        [hv, lv] = f_valueArea(htfProf, vaPct)
        prevHtfVah := hv
        prevHtfVal := lv
    liveDelta := 0.0
    liveBuy := 0.0
    liveSell := 0.0
    htfOpen := open
    htfHiPoc := na
    htfLoPoc := na
    htfProf := map.new<int, float>()
liveDelta += nz(barDelta)
liveBuy   += nz(barBuy)
liveSell  += nz(barSell)
htfHiPoc := na(htfHiPoc) ? high : math.max(htfHiPoc, high)
htfLoPoc := na(htfLoPoc) ? low : math.min(htfLoPoc, low)
f_blk6() =>
    if nPocIB > 0
        for i = 0 to nPocIB - 1
            float pc3 = array.get(pocIvC, i)
            float vv3 = nz(array.get(pocIvV, i))
            if not na(pc3)
                addBin(htfProf, math.round(pc3 / pocBinSize), vv3)
    else if not memSaver
        addBin(htfProf, math.round(close / pocBinSize), nz(volume))

    true
f_blk6()
// ── EMA + smoothing MA (TradingView standard) ────────────────────────────────
float emaRaw = ta.ema(emaSrc, emaLen)
float emaOut = ta.ema(emaRaw, emaSmooth)

// ── DWM period detection (intraday: session-open hour; D+: symbol session) ──
int hrNow = hour(time, syminfo.timezone)
bool newDManual = hrNow == sessOpenHr and (na(hrNow[1]) or hrNow[1] != sessOpenHr)
bool newD = chartSec <= 3600 ? (sessDetect == "Manual hour" ? newDManual : session.isfirstbar) : timeframe.change("D")
// Intraday: week/month boundaries derive from the session-open day (week-start
// input honoured). Daily and above: use TradingView's own W/M boundaries, which
// are correct regardless of how the exchange stamps daily bar times.
bool dailyPlus = chartSec >= 86400
int dowNow = dayofweek(time, syminfo.timezone)
bool newW = dailyPlus ? timeframe.change("W") : newD and dowNow == (weekStartDay == "Sunday" ? dayofweek.sunday : dayofweek.monday)
var int lastMo = na
bool newM = false
if dailyPlus
    newM := timeframe.change("M")
else if newD
    int moNow = month(time, syminfo.timezone)
    newM := not na(lastMo) and moNow != lastMo
    lastMo := moNow

// period high/low tracking → previous completed values
var float curDH = na
var float curDL = na
var float prevDH = na
var float prevDL = na
var float curWH = na
var float curWL = na
var float prevWH = na
var float prevWL = na
var float curMH = na
var float curML = na
var float prevMH = na
var float prevML = na
var int curDStart = na
var int prevDStart = na
var int curWStart = na
var int prevWStart = na
var int curMStart = na
var int prevMStart = na
var map<int, float> sessProf = map.new<int, float>()
var float prevSessPoc = na
var float prevSessVah = na
var float prevSessVal = na
var array<float> nakedPocs = array.new_float()
var array<int> nakedBars = array.new_int()
var float sessBuyT = 0.0
var float sessSellT = 0.0
if newD
    if map.size(sessProf) > 0
        prevSessPoc := pocOf(sessProf)
        [psh, psl] = f_valueArea(sessProf, vaPct)
        prevSessVah := psh
        prevSessVal := psl
        if not na(prevSessPoc)
            array.push(nakedPocs, prevSessPoc)
            array.push(nakedBars, nz(curDStart, bar_index))
            if array.size(nakedPocs) > 20
                array.shift(nakedPocs)
                array.shift(nakedBars)
    sessBuyT := 0.0
    sessSellT := 0.0
    prevDH := curDH
    prevDL := curDL
    prevDStart := curDStart
    curDStart := bar_index
    curDH := high
    curDL := low
    sessProf := map.new<int, float>()
else
    curDH := na(curDH) ? high : math.max(curDH, high)
    curDL := na(curDL) ? low : math.min(curDL, low)
sessBuyT += nz(barBuy)
sessSellT += nz(barSell)
f_blk7() =>
    if nPocIB > 0
        for i = 0 to nPocIB - 1
            float pcS = array.get(pocIvC, i)
            float vvS = nz(array.get(pocIvV, i))
            if not na(pcS)
                addBin(sessProf, math.round(pcS / pocBinSize), vvS)
    else if not memSaver
        addBin(sessProf, math.round(close / pocBinSize), nz(volume))
    true
f_blk7()
float sessPoc = pocOf(sessProf)


// Delta size HTF reference: one profile over the last N candles of the DELTA
// timeframe — the same 1H × N the VWAP window and the paint scale already use,
// so changing either in the Delta Engine moves this band with it.
[hwPoc, hwVah, hwVal, hwBack, hwPrev] = request.security(syminfo.tickerid, memSaver ? timeframe.period : dTf, f_windowProfile(memSaver ? 0 : lenN, htfMigK, false), lookahead = barmerge.lookahead_off)

[sessVah, sessVal] = f_valueArea(sessProf, vaPct)
// ── Candle engines kept in v4 (all ta.* calls unconditional) ─────────────────
string paintModeEff = memSaver ? replayPaint : engine
float atrV = ta.atr(14)
// Truth Line fuel: spike-aware participation → plateau bell → agreement
float pVolEma = ta.ema(nz(volume), partEmaLen)
float prankEma = ta.percentrank(pVolEma, partLook)
float prankBar = ta.percentrank(nz(volume), partLook)
float part = partFast ? math.max(nz(prankEma, 50.0), nz(prankBar, 50.0)) : nz(prankEma, 50.0)
// Participation band: smooth two-stage gradient across the full 0-100 rank —
// red at 0, gold at 50, cyan at 100, continuously interpolated (no hard bands).
float bell = part >= bellPeak ? 1.0 : math.exp(-math.pow(part - bellPeak, 2) / (2.0 * bellWidth * bellWidth))
float climaxF = climaxCuts and part > bandClimax ? math.max(0.15, 1.0 - climaxDecay * (part - bandClimax)) : 1.0
float mvBar = close - open
bool sameSide = (barDelta > 0 and mvBar > 0) or (barDelta < 0 and mvBar < 0) or mvBar == 0
float agree = useAgree and fpOk and not sameSide ? agreePen : 1.0
float fuelVal = bell * climaxF * agree
bool emaSideUp = close > emaOut
bool emaAlign = (barDelta > 0 and emaSideUp) or (barDelta < 0 and not emaSideUp)
float emaMult = fuelEmaOn and not na(emaOut) ? (emaAlign ? 1.0 + fuelEmaBoost : 1.0 - fuelEmaBoost) : 1.0
fuelVal := math.max(0.0, math.min(1.0, fuelVal * emaMult))
// ── Candle paint (mode → normalized −1..+1 → curve → floor → gradient) ──────
float avgAbsD = 0.0
if array.size(deltaHist) > 0
    for d in deltaHist
        avgAbsD += math.abs(nz(d))
    avgAbsD /= array.size(deltaHist)
float totVLive = liveBuy + liveSell
float dPctRaw  = totVLive > 0 ? nz(liveDelta) / totVLive : 0.0

// ── Delta % (imbalance) — trajectory → self-calibration → size gate → streak ──
// Trajectory needs intrabar granularity, only present on the estimate path
// (ivS holds signed volume per intrabar; empty when footprint supplied barDelta).
// trajectory: the developing-hour ratio tilted toward the CURRENT bar's own
// ratio — same horizon on every data path (the earlier version swapped to a
// chart-bar-only measure on the estimate path, changing what the colour meant)
float barTot = nz(barBuy) + nz(barSell)
float barImb = barTot > 0 ? (nz(barBuy) - nz(barSell)) / barTot : 0.0
float dpctBase = dpctTrajOn ? (1.0 - dpctTrajTilt) * dPctRaw + dpctTrajTilt * barImb : dPctRaw

// self-calibration: percentile rank of |imbalance| vs its own recent history
float dpctRank = ta.percentrank(math.abs(dpctBase), dpctCalibLook)
float volRankPct = ta.percentrank(totVLive, dpctCalibLook)
float calibN = dpctCalib ? math.sign(dpctBase) * (nz(dpctRank, 50.0) / 100.0) : math.max(-1.0, math.min(1.0, dpctBase * paintSens / 0.15))
// size gate: tapers intensity below the volume-percentile floor
float gateMult = 1.0
if dpctGateOn
    float vr = nz(volRankPct, 50.0)
    gateMult := vr <= dpctGateFloor ? math.max(0.0, vr / math.max(1.0, dpctGateFloor)) : 1.0
float dPctGated = calibN * gateMult
// persistence streak: advances only on confirmed (completed) bars
var int dpctStreak = 1
var int dpctLastDir = 0
int dpctCurDir = dPctGated > 0.02 ? 1 : dPctGated < -0.02 ? -1 : 0
if dpctStreakOn and barstate.isconfirmed
    bool sigNow = nz(dpctRank, 50.0) >= dpctStreakThresh
    if sigNow and dpctCurDir != 0 and dpctCurDir == dpctLastDir
        dpctStreak := math.min(dpctStreakCap, dpctStreak + 1)
    else if sigNow and dpctCurDir != 0
        dpctStreak := 1
    else
        dpctStreak := 1
    dpctLastDir := dpctCurDir
float dpctStreakMult = dpctStreakOn and dpctCurDir == dpctLastDir ? 1.0 + dpctStreakBoost * (dpctStreak - 1) : 1.0
float dPctFinal = math.sign(dPctGated) * math.min(1.0, math.abs(dPctGated) * dpctStreakMult)
// VA-band variant of f_pocColor: blue between VAL and VAH (deepest at the POC and
// on quiet delta), green/red beyond, ramp = pocRampPct of the value-area width.
f_pocVaColor(float px, float poc, float vah, float val, float dlt, float avgAbs, float extra) =>
    color result = colNeut
    if not na(poc) and not na(vah) and not na(val) and vah > val
        float w = vah - val
        float rampW = math.max(syminfo.mintick, w * pocRampPct / 100.0)
        if px > vah or px < val
            float beyond = px > vah ? px - vah : val - px
            float fracD = math.min(1.0, beyond / rampW)
            // distance alone, distance averaged with the other factors, or
            // whichever single factor reads highest
            float frac = na(extra) or htfIntMode == "Distance only" ? fracD :
                 htfIntMode == "Strongest" ? math.max(fracD, extra) : (fracD + extra) / 2.0
            bool greenZone = px > vah
            bool aligned = (greenZone and dlt > 0) or (not greenZone and dlt < 0)
            float adj = aligned ? math.min(1.0, frac + pocAlignBoost) : frac * (1.0 - pocAlignBoost)
            result := greenZone ? color.from_gradient(adj, 0, 1, colNeut, colBull) : color.from_gradient(adj, 0, 1, colNeut, colBear)
        else
            float halfW = math.max(syminfo.mintick, math.max(vah - poc, poc - val))
            float centering = 1.0 - math.min(1.0, math.abs(px - poc) / halfW)
            float dq = avgAbs > 0 ? 1.0 - math.min(1.0, math.abs(dlt) / avgAbs) : 0.5
            float depth = math.max(0.0, math.min(1.0, (centering + dq) / 2.0))
            int transp = int(math.round(70 - depth * 70))
            // inside value, lean by which side of the POC price is accepting:
            // neutral on the POC, tilting toward bull/bear out at the VA edge
            float lean = htfInsideLean * math.min(1.0, math.abs(px - poc) / halfW)
            color leanCol = px > poc ? color.from_gradient(lean, 0, 1, colNeut, colBull) : color.from_gradient(lean, 0, 1, colNeut, colBear)
            result := color.new(htfInsideLean > 0 ? leanCol : colNeut, transp)
    result
bool pocUseVa = pocBandMode == "Value area (VAH/VAL)"
color deltaSizeCol = pocUseVa ? f_pocVaColor(close, barPocNow[1], barVahNow[1], barValNow[1], barDelta, avgAbsD, na) : f_pocColor(close, barPocNow[1], high[1] - low[1], barDelta, avgAbsD)
bool htfWinRef = htfRefMode == "HTF window (N candles)" and not na(hwPoc) and not na(hwVah) and not na(hwVal)
float htfRefPoc = htfWinRef ? hwPoc : prevHtfPocVal
float htfRefVah = htfWinRef ? hwVah : prevHtfVah
float htfRefVal = htfWinRef ? hwVal : prevHtfVal
float htfRefRng = htfWinRef ? (na(hwVah) or na(hwVal) ? na : hwVah - hwVal) : prevHtfRangeVal
// ACCEPTANCE — consecutive closes beyond the edge; a return inside collapses it
var int htfAccCnt = 0
bool htfBeyondUp = not na(htfRefVah) and close > htfRefVah
bool htfBeyondDn = not na(htfRefVal) and close < htfRefVal
if barstate.isconfirmed
    htfAccCnt := htfBeyondUp or htfBeyondDn ?
         ((htfBeyondUp and htfBeyondUp[1]) or (htfBeyondDn and htfBeyondDn[1]) ? htfAccCnt + 1 : 1) : 0
float htfAccF = math.min(1.0, htfAccCnt / math.max(1.0, htfAccBars))
// RELATIVE SIZE — this bar's volume against what this time of day normally trades
float htfSizeF = na(mdRelVol) ? 0.0 : math.max(0.0, math.min(1.0, (mdRelVol - 1.0) / math.max(0.1, htfSizeFull - 1.0)))
// MIGRATION — is accepted value itself moving the way price broke
float htfVaW = (na(htfRefVah) or na(htfRefVal)) ? na : htfRefVah - htfRefVal
float htfMig = (na(hwPoc) or na(hwBack) or na(htfVaW) or htfVaW <= 0) ? 0.0 : (hwPoc - hwBack) / htfVaW
bool htfMigAligned = (htfBeyondUp and htfMig > 0) or (htfBeyondDn and htfMig < 0)
float htfMigF = htfMigAligned ? math.min(1.0, math.abs(htfMig)) : 0.0
// combined: averaged with distance, or the strongest single reading
float htfExtraF = htfIntMode == "Strongest" ? math.max(htfAccF, math.max(htfSizeF, htfMigF)) :
     (htfAccF + htfSizeF + htfMigF) / 3.0

color deltaSizeHtfCol = pocUseVa ? f_pocVaColor(close, htfRefPoc, htfRefVah, htfRefVal, liveDelta, avgAbsD, htfExtraF) : f_pocColor(close, htfRefPoc, htfRefRng, liveDelta, avgAbsD)
// boosted gradient, the same curve the STRYK:M engines use
f_g(float n) =>
    float x = math.max(-1.0, math.min(1.0, nz(n)))
    float cv = math.sign(x) * math.pow(math.abs(x), 0.55)
    cv >= 0 ? color.from_gradient(cv, 0, 1, colNeut, colBull) : color.from_gradient(cv, -1, 0, colBear, colNeut)
float svAvgAbsD = ta.sma(math.abs(nz(barDelta)), 50)
// naked POCs: a prior-session POC stays naked until a bar trades through it
f_blk8() =>
    if array.size(nakedPocs) > 0
        for i = array.size(nakedPocs) - 1 to 0
            float np = array.get(nakedPocs, i)
            if not newD and low <= np and high >= np
                array.remove(nakedPocs, i)
                array.remove(nakedBars, i)
    true
f_blk8()

// =============================================================================
// VWAP ENGINE — eight anchors from ONE set of running (cumulative) sums.
// Any anchor's VWAP from bar a to bar t = (sums at t − sums before a) / volume,
// so every anchor, the test table and the drawing read the same numbers.
// =============================================================================
float mrTp  = srcIn == "Close" ? close : srcIn == "OHLC4" ? ohlc4 : hlc3
float mrV   = nz(volume)
int   mrSec = math.max(1, timeframe.in_seconds())
int   mrMin = hour(time, TZ) * 60 + minute(time, TZ)
bool  mrNewDay = ta.change(dayofmonth(time, TZ)) != 0
bool  is830 = mrMin >= 510 and (nz(mrMin[1], 0) < 510 or mrNewDay) and mrMin < 1020
bool  newSess = timeframe.change("D")
bool  newWeek = timeframe.change("W")
bool  newMonth = timeframe.change("M")

int CAP = 20000
int DRAWMAX = 9900   // drawings with xloc.bar_index cannot sit more than ~10,000 bars behind the last bar (RE10026)
int TRIM = 2000      // arrays are trimmed in chunks: one O(n) copy every 2000 bars instead of an O(n) shift on every bar
var array<float> cV  = array.new_float()
var array<float> cPV = array.new_float()
var array<float> cP2 = array.new_float()
var array<int>   cT  = array.new_int()
int   cN0 = array.size(cV)
float cLV  = cN0 > 0 ? array.get(cV, cN0 - 1) : 0.0
float cLPV = cN0 > 0 ? array.get(cPV, cN0 - 1) : 0.0
float cLP2 = cN0 > 0 ? array.get(cP2, cN0 - 1) : 0.0
array.push(cV, cLV + mrV)
array.push(cPV, cLPV + mrTp * mrV)
array.push(cP2, cLP2 + mrTp * mrTp * mrV)
array.push(cT, time)
if array.size(cV) > CAP
    int nTr = array.size(cV)
    cV  := array.copy(array.slice(cV, TRIM, nTr))
    cPV := array.copy(array.slice(cPV, TRIM, nTr))
    cP2 := array.copy(array.slice(cP2, TRIM, nTr))
    cT  := array.copy(array.slice(cT, TRIM, nTr))
int cBase = bar_index - (array.size(cV) - 1)      // bar_index of slot 0

// VWAP, σ and bar count from start bar a to bar t (t defaults to this bar)
f_vwAt(int a, int t) =>
    float vw = na
    float sd = na
    int   nb = 0
    if not na(a) and not na(t)
        int ia = math.max(0, a - cBase)
        int it = t - cBase
        if it >= ia and it < array.size(cV)
            float v  = array.get(cV, it) - (ia > 0 ? array.get(cV, ia - 1) : 0.0)
            float pv = array.get(cPV, it) - (ia > 0 ? array.get(cPV, ia - 1) : 0.0)
            float p2 = array.get(cP2, it) - (ia > 0 ? array.get(cP2, ia - 1) : 0.0)
            if v > 0
                vw := pv / v
                sd := math.sqrt(math.max(0.0, p2 / v - vw * vw))
            nb := it - ia + 1
    [vw, sd, nb]
f_tAt(int a) =>
    int r = na
    if not na(a)
        int ia = math.max(0, a - cBase)
        r := ia < array.size(cT) ? array.get(cT, ia) : na
    r

// ---- anchor starts
var int sessS = na
var int prevSessS = na
var int last830 = na
var int pdS = na
if newSess
    prevSessS := sessS
    sessS := bar_index
    pdS := last830           // the 08:30 open of the day that just ended (same as STRYK: OP)
if is830
    last830 := bar_index
int wdNum = wdDay == "Monday" ? dayofweek.monday : wdDay == "Tuesday" ? dayofweek.tuesday : wdDay == "Wednesday" ? dayofweek.wednesday : wdDay == "Thursday" ? dayofweek.thursday : dayofweek.friday
var array<int> wdArr = array.new_int()
f_blk10() =>
    if is830 and dayofweek(time, TZ) == wdNum
        array.push(wdArr, bar_index)
        while array.size(wdArr) > wdBack
            array.shift(wdArr)
    true
f_blk10()
int wdS = array.size(wdArr) > 0 ? array.get(wdArr, 0) : na
var int weekCount = 0
var int w2S = na
if newWeek
    weekCount += 1
    if weekCount % 2 == 0
        w2S := bar_index
var int moS = na
var int pmS = na
var array<int> m3Arr = array.new_int()
if newMonth
    pmS := moS
    moS := bar_index
    array.push(m3Arr, bar_index)
    while array.size(m3Arr) > 3
        array.shift(m3Arr)
int m3S = array.size(m3Arr) > 0 ? array.get(m3Arr, 0) : na
int nRoll = math.min(CAP, math.max(2, int(math.round(rvN * timeframe.in_seconds(rvTf) / mrSec))))
int rvMs = rvN * timeframe.in_seconds(rvTf) * 1000
// rolling window start for bar t: first bar whose time is inside the last N × tf of clock time (or a fixed bar count)
f_rvAt(int t) =>
    int out = t - nRoll + 1
    if rvMode == "Elapsed time"
        int it = t - cBase
        if it >= 0 and it < array.size(cT)
            int tgt = array.get(cT, it) - rvMs + 1
            int ix = array.binary_search_leftmost(cT, tgt)
            ix := ix < 0 ? 0 : ix
            if array.get(cT, ix) < tgt
                ix += 1
            out := math.max(cBase + ix, t - CAP + 1)
    out
int rvS = f_rvAt(bar_index)

f_tfLab(string tf) =>
    int s = timeframe.in_seconds(tf)
    s % 604800 == 0 ? str.tostring(s / 604800) + "W" : s % 86400 == 0 ? str.tostring(s / 86400) + "D" : s % 3600 == 0 ? str.tostring(s / 3600) + "h" : s % 60 == 0 ? str.tostring(s / 60) + "m" : str.tostring(s) + "s"
int NA = 8
string rvName = "rVWAP " + str.tostring(rvN) + " × " + f_tfLab(rvTf)
var array<string> anName = array.from("rVWAP", "Prev session 17:00", "Prev-day 08:30", "Weekday 08:30", "2 weeks", "Month", "Prev month", "3 months")
array<int> anS = array.from(rvS, prevSessS, pdS, wdS, w2S, moS, pmS, m3S)
int selIdx = vwEng == "rVWAP (rolling)" ? 0 : vwEng == "Prev session 17:00" ? 1 : vwEng == "Prev-day 08:30" ? 2 : vwEng == "Weekday 08:30" ? 3 : vwEng == "2 weeks" ? 4 : vwEng == "Month" ? 5 : vwEng == "Prev month" ? 6 : 7

// ---- the anchor on the chart
int anStartBar = array.get(anS, selIdx)
[sVw0, sSd0, selN0] = f_vwAt(anStartBar, bar_index)
int   selN = selN0
bool  sOk = not na(sVw0) and not na(sSd0) and sSd0 > 0 and selN >= 2
float sVw = sOk ? sVw0 : na
float sSd = sOk ? sSd0 : na
int   anStartTime = f_tAt(anStartBar)
bool  anchorJump = not na(anStartBar[1]) and anStartBar != anStartBar[1] and selIdx != 0
bool  sigOk = sOk and selN >= minBars

// =============================================================================
// CE TRIANGLES — VWAP reversion on the VWAP ENGINE: setup at band 2, trigger on the close back through band 1
// =============================================================================
float rvU1 = sVw + b1 * sSd
float rvL1 = sVw - b1 * sSd
float rvU2 = sVw + b2 * sSd
float rvL2 = sVw - b2 * sSd
bool  rvOk = sigOk and not anchorJump
var int rvShortArm = na
var int rvLongArm = na
bool rvInUp = rvOk and high >= rvU2
bool rvInDn = rvOk and low <= rvL2
var float rvShortExt = na
var float rvLongExt = na
if rvInUp
    rvShortExt := na(rvShortArm) ? high : math.max(rvShortExt, high)
    rvShortArm := bar_index
if rvInDn
    rvLongExt := na(rvLongArm) ? low : math.min(rvLongExt, low)
    rvLongArm := bar_index
if not na(rvShortArm) and bar_index - rvShortArm > armBars
    rvShortArm := na
if not na(rvLongArm) and bar_index - rvLongArm > armBars
    rvLongArm := na
bool rvShort = rvOk and not na(rvShortArm) and close < rvU1 and nz(close[1]) >= nz(rvU1[1]) and barstate.isconfirmed
bool rvLong  = rvOk and not na(rvLongArm) and close > rvL1 and nz(close[1]) <= nz(rvL1[1]) and barstate.isconfirmed
float rvShortStop = rvShortExt + syminfo.mintick
float rvLongStop = rvLongExt - syminfo.mintick
// each outer-band visit pays once
if rvShort
    rvShortArm := na
if rvLong
    rvLongArm := na
color cRev = not rvOk ? colNeut : rvLong ? colBull : rvShort ? colBear : (rvInUp or rvInDn) ? color.new(#FFB300, 45) : colNeut


// ---- higher-timeframe and weekly series used by the gates and section 6
[w20Ema, w20Atr] = request.security(syminfo.tickerid, "W", [ta.ema(close, 20), ta.atr(14)], lookahead = barmerge.lookahead_off)

// =============================================================================
// MEAN REVERSION — the same rules run on all eight anchors (test table); the
// chart anchor's events drive the lines, labels and alerts.
// =============================================================================
int NT = NA
var array<int>   armUp = array.new_int(NT, -1)
var array<int>   armDn = array.new_int(NT, -1)
var array<float> extUp = array.new_float(NT, na)
var array<float> extDn = array.new_float(NT, na)
var array<float> pTrU = array.new_float(NT, na)
var array<float> pTrD = array.new_float(NT, na)
var array<float> pCl  = array.new_float(NT, na)
var array<float> tPU2 = array.new_float(NT, na)
var array<float> tPD2 = array.new_float(NT, na)
var array<int>   tDir = array.new_int(NT * 2, 0)
var array<float> tEnt = array.new_float(NT * 2, na)
var array<float> tStp = array.new_float(NT * 2, na)
var array<float> tTgt = array.new_float(NT * 2, na)
var array<float> tRsk = array.new_float(NT * 2, na)
var array<int>   tBar = array.new_int(NT * 2, 0)
var array<int>   stN = array.new_int(NT, 0)
var array<int>   stW = array.new_int(NT, 0)
var array<int>   stL = array.new_int(NT, 0)
var array<float> stR = array.new_float(NT, 0.0)
// extra stats per row: gross profit, gross loss, running equity, equity peak, max drawdown, exits by target / stop / timeout
var array<float> stGP = array.new_float(NT + 2, 0.0)
var array<float> stGL = array.new_float(NT + 2, 0.0)
var array<float> stEq = array.new_float(NT + 2, 0.0)
var array<float> stPk = array.new_float(NT + 2, 0.0)
var array<float> stDD = array.new_float(NT + 2, 0.0)
var array<int>   stXT = array.new_int(NT + 2, 0)
var array<int>   stXS = array.new_int(NT + 2, 0)
var array<int>   stXO = array.new_int(NT + 2, 0)
f_stat(int row, float xR, int res) =>
    if xR > 0
        array.set(stGP, row, array.get(stGP, row) + xR)
    else
        array.set(stGL, row, array.get(stGL, row) - xR)
    float eq = array.get(stEq, row) + xR
    array.set(stEq, row, eq)
    float pk = math.max(array.get(stPk, row), eq)
    array.set(stPk, row, pk)
    array.set(stDD, row, math.max(array.get(stDD, row), pk - eq))
    if res == 1
        array.set(stXT, row, array.get(stXT, row) + 1)
    else if res == -1
        array.set(stXS, row, array.get(stXS, row) + 1)
    else
        array.set(stXO, row, array.get(stXO, row) + 1)
bool  inWin = not sessOn or not na(time(timeframe.period, sigSess, TZ))
bool  allowL = dirMode != "Shorts only"
bool  allowS = dirMode != "Longs only"
float mrTick = syminfo.mintick
bool  modeO = mrRules == "Original: 2σ → 1σ"
bool  modeA = mrRules == "A + B" or mrRules == "A: stretch 3σ → 2σ"
bool  modeB = mrRules == "A + B" or mrRules == "B: cross 1σ"
bool  mrOn  = mrRules != "Off"
// flow gate pieces (also used by the break / reclaim gates below)
float mdVolF = barBuy + barSell > 0 ? barBuy + barSell : nz(volume)
float dShare = mdVolF > 0 ? nz(barDelta) / mdVolF : 0.0
bool  fUp = dShare > 0 and dShare * 100 >= flowPct
bool  fDn = dShare < 0 and -dShare * 100 >= flowPct
int evSig = 0
int evRes = 0
float evEnt = na
float evStp = na
float evTgt = na
string evTxt = ""

f_gb1() =>
    evEnt_L = evEnt
    evRes_L = evRes
    evSig_L = evSig
    evStp_L = evStp
    evTgt_L = evTgt
    evTxt_L = evTxt
    if barstate.isconfirmed and mrOn
        for k = 0 to NT - 1
            [vw, sd, nb] = f_vwAt(array.get(anS, k), bar_index)
            bool ok = not na(vw) and not na(sd) and sd > 0 and nb >= minBars
            float u1 = ok ? vw + b1 * sd : na
            float d1 = ok ? vw - b1 * sd : na
            float u2 = ok ? vw + b2 * sd : na
            float d2 = ok ? vw - b2 * sd : na
            float u3 = ok ? vw + b3 * sd : na
            float d3 = ok ? vw - b3 * sd : na
            float pc = array.get(pCl, k)
            // ---- manage open trades (both slots)
            for sl = 0 to 1
                int j = k * 2 + sl
                int d = array.get(tDir, j)
                if d != 0 and bar_index > array.get(tBar, j)
                    float en = array.get(tEnt, j)
                    float rk = math.max(mrTick, array.get(tRsk, j))
                    float tg = array.get(tTgt, j)
                    float st = array.get(tStp, j)
                    float xR = na
                    int   res = 0
                    if modeO and sl == 0
                        bool hs = d == 1 ? low <= st : high >= st
                        bool ht = d == 1 ? high >= tg : low <= tg
                        if hs
                            xR := -1.0
                            res := -1
                        else if ht
                            xR := math.abs(tg - en) / rk
                            res := 1
                    else
                        float stopBand = sl == 0 ? (d == 1 ? d3 : u3) : (d == 1 ? d2 : u2)
                        bool cStop = ok and (d == 1 ? close < stopBand : close > stopBand)
                        float tgB = sl == 1 and ok ? (d == 1 ? math.min(tg, u1) : math.max(tg, d1)) : tg
                        bool ht = d == 1 ? high >= tgB : low <= tgB
                        bool rej = sl == 0 and ok and (d == 1 ? high >= d1 and close < d1 : low <= u1 and close > u1)
                        if cStop
                            xR := d * (close - en) / rk
                            res := -1
                        else if ht
                            xR := d * (tgB - en) / rk
                            res := 1
                        else if rej
                            xR := d * (close - en) / rk
                            res := xR > 0 ? 1 : -1
                    if res == 0 and bar_index - array.get(tBar, j) >= 100
                        xR := modeO and sl == 0 ? 0.0 : d * (close - en) / rk
                        res := 2
                    if res != 0
                        xR -= costTk * mrTick / rk
                        array.set(stR, k, array.get(stR, k) + xR)
                        f_stat(k, xR, res)
                        if not (res == 2 and modeO and sl == 0)
                            if xR > 0
                                array.set(stW, k, array.get(stW, k) + 1)
                            else
                                array.set(stL, k, array.get(stL, k) + 1)
                        if k == selIdx
                            evRes_L := res == 2 ? 2 : xR > 0 ? 1 : -1
                        array.set(tDir, j, 0)
            if ok
                // ---- slot 0: Original or A (arm, then trigger on a close back inside)
                if modeO or modeA
                    float aU = modeO ? vw + setK * sd : u3
                    float aD = modeO ? vw - setK * sd : d3
                    bool armHitU = modeO ? high >= aU : close > aU
                    bool armHitD = modeO ? low <= aD : close < aD
                    if armHitU
                        array.set(extUp, k, array.get(armUp, k) >= 0 ? math.max(array.get(extUp, k), high) : high)
                        array.set(armUp, k, bar_index)
                    if armHitD
                        array.set(extDn, k, array.get(armDn, k) >= 0 ? math.min(array.get(extDn, k), low) : low)
                        array.set(armDn, k, bar_index)
                    if array.get(armUp, k) >= 0 and bar_index - array.get(armUp, k) > armBars
                        array.set(armUp, k, -1)
                    if array.get(armDn, k) >= 0 and bar_index - array.get(armDn, k) > armBars
                        array.set(armDn, k, -1)
                    float trU = modeO ? vw + trigK * sd : u2
                    float trD = modeO ? vw - trigK * sd : d2
                    float pTU = modeO ? array.get(pTrU, k) : array.get(tPU2, k)
                    float pTD = modeO ? array.get(pTrD, k) : array.get(tPD2, k)
                    bool free0 = array.get(tDir, k * 2) == 0
                    bool gfS = not mrGateF or fDn
                    bool gfL = not mrGateF or fUp
                    bool sS = allowS and gfS and array.get(armUp, k) >= 0 and close < trU and nz(pc) >= nz(pTU) and close > vw and inWin and free0
                    bool sL = allowL and gfL and array.get(armDn, k) >= 0 and close > trD and nz(pc) <= nz(pTD, 1e12) and close < vw and inWin and free0
                    if sS or sL
                        int dd = sS ? -1 : 1
                        float stp = modeO ? (sS ? array.get(extUp, k) + stopTk * mrTick : array.get(extDn, k) - stopTk * mrTick) : (sS ? u3 : d3)
                        float rsk = math.abs(close - stp)
                        float tgt = modeO ? (tgtMode == "VWAP" ? vw : sS ? d1 : u1) : close + dd * rrA * rsk
                        if rsk > 0 and ((sS and tgt < close and stp > close) or (sL and tgt > close and stp < close))
                            int j = k * 2
                            array.set(tDir, j, dd)
                            array.set(tEnt, j, close)
                            array.set(tStp, j, stp)
                            array.set(tTgt, j, tgt)
                            array.set(tRsk, j, rsk)
                            array.set(tBar, j, bar_index)
                            array.set(stN, k, array.get(stN, k) + 1)
                            if k == selIdx
                                evSig_L := dd
                                evEnt_L := close
                                evStp_L := stp
                                evTgt_L := tgt
                                evTxt_L := modeO ? (tgtMode == "VWAP" ? " → VWAP" : " → band") : " · A"
                        if sS
                            array.set(armUp, k, -1)
                        if sL
                            array.set(armDn, k, -1)
                // ---- slot 1: B, a close back through band 1 from the outside
                if modeB
                    bool free1 = array.get(tDir, k * 2 + 1) == 0
                    bool bL = allowL and free1 and inWin and not na(pc) and not na(array.get(pTrD, k)) and pc <= array.get(pTrD, k) and close > d1 and close < u1
                    bool bS = allowS and free1 and inWin and not na(pc) and not na(array.get(pTrU, k)) and pc >= array.get(pTrU, k) and close < u1 and close > d1
                    if bL or bS
                        int dd = bS ? -1 : 1
                        float stp = bS ? u2 : d2
                        float rsk = math.abs(close - stp)
                        float tgt = close + dd * rrB * rsk
                        if rsk > 0 and ((bS and stp > close) or (bL and stp < close))
                            int j = k * 2 + 1
                            array.set(tDir, j, dd)
                            array.set(tEnt, j, close)
                            array.set(tStp, j, stp)
                            array.set(tTgt, j, tgt)
                            array.set(tRsk, j, rsk)
                            array.set(tBar, j, bar_index)
                            array.set(stN, k, array.get(stN, k) + 1)
                            if k == selIdx and evSig_L == 0
                                evSig_L := dd
                                evEnt_L := close
                                evStp_L := stp
                                evTgt_L := bS ? math.max(tgt, d1) : math.min(tgt, u1)
                                evTxt_L := " · B"
            array.set(pCl, k, close)
            array.set(pTrU, k, u1)
            array.set(pTrD, k, d1)
            array.set(tPU2, k, u2)
            array.set(tPD2, k, d2)

    [evEnt_L, evRes_L, evSig_L, evStp_L, evTgt_L, evTxt_L]
[evEnt_G1, evRes_G1, evSig_G1, evStp_G1, evTgt_G1, evTxt_G1] = f_gb1()
evEnt := evEnt_G1
evRes := evRes_G1
evSig := evSig_G1
evStp := evStp_G1
evTgt := evTgt_G1
evTxt := evTxt_G1
int mrSig = evSig
// =============================================================================
// BREAK + RECLAIM — on the chart anchor, graded by five gates (A·S·F·P·T)
// =============================================================================
float u1L = sOk ? sVw + b1 * sSd : na
float d1L = sOk ? sVw - b1 * sSd : na
float u2L = sOk ? sVw + b2 * sSd : na
float d2L = sOk ? sVw - b2 * sSd : na
float u3L = sOk ? sVw + b3 * sSd : na
float d3L = sOk ? sVw - b3 * sSd : na
float rngB = high - low
bool  upCl = rngB > 0 ? (close - low) / rngB >= accPct / 100.0 : true
bool  dnCl = rngB > 0 ? (high - close) / rngB >= accPct / 100.0 : true
bool  sPass = nz(mdRelVol, 1.0) >= sizeK
float htfVolT = liveBuy + liveSell
float htfShare = htfVolT > 0 ? liveDelta / htfVolT : 0.0
bool  pUp = htfShare > 0 and htfShare * 100 >= pressPct
bool  pDn = htfShare < 0 and -htfShare * 100 >= pressPct
float vwSl = sVw - sVw[trdN]
int   emaVotes = (close > emaOut ? 1 : -1) + (not na(w20Ema) ? (close > w20Ema ? 1 : -1) : 0)
bool  tUp = trdSrc == "VWAP slope" ? nz(vwSl) > 0 : emaVotes > 0
bool  tDn = trdSrc == "VWAP slope" ? nz(vwSl) < 0 : emaVotes < 0
int   gOnN = (gA ? 1 : 0) + (gS ? 1 : 0) + (gF ? 1 : 0) + (gP ? 1 : 0) + (gT ? 1 : 0)
int   gReq = math.min(gNeed, gOnN)
f_grade(int d, float lvl) =>
    bool a = gA and (d == 1 ? close >= lvl + accTk * syminfo.mintick and upCl : close <= lvl - accTk * syminfo.mintick and dnCl)
    bool s = gS and sPass
    bool f = gF and (d == 1 ? fUp : fDn)
    bool p = gP and (d == 1 ? pUp : pDn)
    bool t = gT and (d == 1 ? tUp : tDn)
    int  n = (a ? 1 : 0) + (s ? 1 : 0) + (f ? 1 : 0) + (p ? 1 : 0) + (t ? 1 : 0)
    string lt = (gA ? (a ? "A" : "·") + " " : "") + (gS ? (s ? "S" : "·") + " " : "") + (gF ? (f ? "F" : "·") + " " : "") + (gP ? (p ? "P" : "·") + " " : "") + (gT ? (t ? "T" : "·") : "")
    [n, str.trim(lt)]

// pending signal (confirmation bars) and its trade
var int   pdDir = 0
var int   pdTyp = 0          // 1 = break, 2 = reclaim
var float pdLvl = na
var float pdTgt = na
var float pdStp = na
var int   pdBar = na
var int   pdGr = 0
var string pdLt = ""
var string pdNm = ""
int   brSig = 0              // +1 / −1 when a break / reclaim prints this bar
int   brTyp = 0
float brLvl = na
string brTxt = ""
int   brGr = 0
var int   btDir = 0          // open break / reclaim trade (one at a time per type)
var int   btTyp = 0
var float btEnt = na
var float btStp = na
var float btTgt = na
var int   btBar = na
var array<int>   bsN = array.new_int(2, 0)
var array<int>   bsW = array.new_int(2, 0)
var array<int>   bsL = array.new_int(2, 0)
var array<float> bsR = array.new_float(2, 0.0)
float recLo = ta.lowest(low, 5)
float recHi = ta.highest(high, 5)
bool  brOn = brkOn or rclOn

f_gb2() =>
    brGr_L = brGr
    brLvl_L = brLvl
    brSig_L = brSig
    brTxt_L = brTxt
    brTyp_L = brTyp
    btBar_L = btBar
    btDir_L = btDir
    btEnt_L = btEnt
    btStp_L = btStp
    btTgt_L = btTgt
    btTyp_L = btTyp
    evEnt_L = evEnt
    evSig_L = evSig
    evStp_L = evStp
    evTgt_L = evTgt
    evTxt_L = evTxt
    pdBar_L = pdBar
    pdDir_L = pdDir
    pdGr_L = pdGr
    pdLt_L = pdLt
    pdLvl_L = pdLvl
    pdNm_L = pdNm
    pdStp_L = pdStp
    pdTgt_L = pdTgt
    pdTyp_L = pdTyp
    if barstate.isconfirmed and brOn and sigOk and not anchorJump and inWin
        // manage the open break / reclaim trade (stop first, 100-bar timeout)
        if btDir_L != 0 and bar_index > btBar_L
            bool hs = btDir_L == 1 ? low <= btStp_L : high >= btStp_L
            bool ht = btDir_L == 1 ? high >= btTgt_L : low <= btTgt_L
            float rk = math.max(syminfo.mintick, math.abs(btEnt_L - btStp_L))
            float xR = hs ? -1.0 : ht ? math.abs(btTgt_L - btEnt_L) / rk : bar_index - btBar_L >= 100 ? btDir_L * (close - btEnt_L) / rk : na
            if not na(xR)
                xR -= costTk * syminfo.mintick / rk
                int ix = btTyp_L - 1
                array.set(bsR, ix, array.get(bsR, ix) + xR)
                f_stat(NT + ix, xR, hs ? -1 : ht ? 1 : 2)
                if xR > 0
                    array.set(bsW, ix, array.get(bsW, ix) + 1)
                else
                    array.set(bsL, ix, array.get(bsL, ix) + 1)
                btDir_L := 0
        float pc = close[1]
        float pv = sVw[1]
        float pu1 = u1L[1]
        float pd1 = d1L[1]
        float pu2 = u2L[1]
        float pd2 = d2L[1]
        float pu3 = u3L[1]
        float pd3 = d3L[1]
        int   nd = 0
        int   nt = 0
        float lv = na
        float tg = na
        string nm = ""
        // BREAK: highest line crossed, moving away from the VWAP
        if brkOn
            if allowL
                if brkB3 and b3On and pc <= pu3 and close > u3L
                    nd := 1
                    lv := u3L
                    tg := u3L + b1 * sSd
                    nm := "+3σ"
                else if brkB2 and pc <= pu2 and close > u2L
                    nd := 1
                    lv := u2L
                    tg := b3On ? u3L : u2L + b1 * sSd
                    nm := "+2σ"
                else if brkB1 and pc <= pu1 and close > u1L
                    nd := 1
                    lv := u1L
                    tg := u2L
                    nm := "+1σ"
                else if brkVw and pc <= pv and close > sVw
                    nd := 1
                    lv := sVw
                    tg := u1L
                    nm := "VWAP"
            if nd == 0 and allowS
                if brkB3 and b3On and pc >= pd3 and close < d3L
                    nd := -1
                    lv := d3L
                    tg := d3L - b1 * sSd
                    nm := "−3σ"
                else if brkB2 and pc >= pd2 and close < d2L
                    nd := -1
                    lv := d2L
                    tg := b3On ? d3L : d2L - b1 * sSd
                    nm := "−2σ"
                else if brkB1 and pc >= pd1 and close < d1L
                    nd := -1
                    lv := d1L
                    tg := d2L
                    nm := "−1σ"
                else if brkVw and pc >= pv and close < sVw
                    nd := -1
                    lv := sVw
                    tg := d1L
                    nm := "VWAP"
            if nd != 0
                nt := 1
        // RECLAIM: deepest band reclaimed, moving back toward the VWAP
        if nd == 0 and rclOn
            if allowL and close < sVw
                if brkB3 and b3On and pc <= pd3 and close > d3L
                    nd := 1
                    lv := d3L
                    tg := d2L
                    nm := "−3σ"
                else if brkB2 and pc <= pd2 and close > d2L
                    nd := 1
                    lv := d2L
                    tg := d1L
                    nm := "−2σ"
                else if brkB1 and pc <= pd1 and close > d1L
                    nd := 1
                    lv := d1L
                    tg := sVw
                    nm := "−1σ"
            if nd == 0 and allowS and close > sVw
                if brkB3 and b3On and pc >= pu3 and close < u3L
                    nd := -1
                    lv := u3L
                    tg := u2L
                    nm := "+3σ"
                else if brkB2 and pc >= pu2 and close < u2L
                    nd := -1
                    lv := u2L
                    tg := u1L
                    nm := "+2σ"
                else if brkB1 and pc >= pu1 and close < u1L
                    nd := -1
                    lv := u1L
                    tg := sVw
                    nm := "+1σ"
            if nd != 0
                nt := 2
        if nd != 0
            [gr, lt] = f_grade(nd, lv)
            float stp = nt == 1 ? (nd == 1 ? low - stopTk * syminfo.mintick : high + stopTk * syminfo.mintick) : (nd == 1 ? recLo - stopTk * syminfo.mintick : recHi + stopTk * syminfo.mintick)
            if gr >= gReq and (nd == 1 ? tg > close and stp < close : tg < close and stp > close)
                pdDir_L := nd
                pdTyp_L := nt
                pdLvl_L := lv
                pdTgt_L := tg
                pdStp_L := stp
                pdBar_L := bar_index
                pdGr_L := gr
                pdLt_L := lt
                pdNm_L := nm
        // confirmation: the pending signal prints once confN more closes hold beyond its line
        if pdDir_L != 0
            bool hold = pdDir_L == 1 ? close > pdLvl_L : close < pdLvl_L
            if bar_index - pdBar_L >= confN and (hold or bar_index == pdBar_L)
                brSig_L := pdDir_L
                brTyp_L := pdTyp_L
                brLvl_L := pdLvl_L
                brGr_L := pdGr_L
                brTxt_L := (pdTyp_L == 1 ? "BREAK " : "RECLAIM ") + pdNm_L + " " + str.tostring(pdGr_L) + "/" + str.tostring(gOnN) + (pdLt_L != "" ? " " + pdLt_L : "")
                if btDir_L == 0
                    btDir_L := pdDir_L
                    btTyp_L := pdTyp_L
                    btEnt_L := close
                    btStp_L := pdStp_L
                    btTgt_L := pdTgt_L
                    btBar_L := bar_index
                    array.set(bsN, pdTyp_L - 1, array.get(bsN, pdTyp_L - 1) + 1)
                    if evSig_L == 0
                        evSig_L := pdDir_L
                        evEnt_L := close
                        evStp_L := pdStp_L
                        evTgt_L := pdTgt_L
                        evTxt_L := pdTyp_L == 1 ? " · break" : " · reclaim"
                pdDir_L := 0
            else if not hold
                pdDir_L := 0

    [brGr_L, brLvl_L, brSig_L, brTxt_L, brTyp_L, btBar_L, btDir_L, btEnt_L, btStp_L, btTgt_L, btTyp_L, evEnt_L, evSig_L, evStp_L, evTgt_L, evTxt_L, pdBar_L, pdDir_L, pdGr_L, pdLt_L, pdLvl_L, pdNm_L, pdStp_L, pdTgt_L, pdTyp_L]
[brGr_G2, brLvl_G2, brSig_G2, brTxt_G2, brTyp_G2, btBar_G2, btDir_G2, btEnt_G2, btStp_G2, btTgt_G2, btTyp_G2, evEnt_G2, evSig_G2, evStp_G2, evTgt_G2, evTxt_G2, pdBar_G2, pdDir_G2, pdGr_G2, pdLt_G2, pdLvl_G2, pdNm_G2, pdStp_G2, pdTgt_G2, pdTyp_G2] = f_gb2()
brGr := brGr_G2
brLvl := brLvl_G2
brSig := brSig_G2
brTxt := brTxt_G2
brTyp := brTyp_G2
btBar := btBar_G2
btDir := btDir_G2
btEnt := btEnt_G2
btStp := btStp_G2
btTgt := btTgt_G2
btTyp := btTyp_G2
evEnt := evEnt_G2
evSig := evSig_G2
evStp := evStp_G2
evTgt := evTgt_G2
evTxt := evTxt_G2
pdBar := pdBar_G2
pdDir := pdDir_G2
pdGr := pdGr_G2
pdLt := pdLt_G2
pdLvl := pdLvl_G2
pdNm := pdNm_G2
pdStp := pdStp_G2
pdTgt := pdTgt_G2
pdTyp := pdTyp_G2
if evSig != 0
    lastSigTxt := (evSig == 1 ? "LONG ▲" : "SHORT ▼") + evTxt
if brSig != 0
    lastSigTxt := (brSig == 1 ? "▲ " : "▼ ") + str.replace_all(brTxt, "\n", " ")

// σ distance candle engine on the VWAP ENGINE
float mrZ = sOk ? (close - sVw) / sSd : 0.0
color cMR = evSig == 1 ? colBull : evSig == -1 ? colBear : math.abs(mrZ) >= setK ? #FFB300 : f_g(mrZ / setK)
color cSide = not sOk ? colNeut : close > sVw ? colBull : close < sVw ? colBear : colNeut
color cBand3 = not sOk ? colNeut : mrZ > b1 ? colBull : mrZ < -b1 ? colBear : colNeut

// =============================================================================
// VWAP LINE, BANDS AND FILL
// =============================================================================
float vwSlope5 = sVw - sVw[5]
color cVwNow = lineCol == "VWAP slope" ? (nz(vwSlope5) > syminfo.mintick ? cVwUp : nz(vwSlope5) < -syminfo.mintick ? cVwDn : cVwFl) : lineCol == "Price side" ? (close >= nz(sVw, close) ? cVwUp : cVwDn) : cVw
bool  histOn = not curOnly
bool  hOk = showAll and histOn and sOk and not anchorJump
float pVw = hOk and mVwap ? sVw : na
float pU1 = hOk and mBands ? u1L : na
float pL1 = hOk and mBands ? d1L : na
float pU2 = hOk and mBands ? u2L : na
float pL2 = hOk and mBands ? d2L : na
float pU3 = hOk and mBands and b3On ? u3L : na
float pL3 = hOk and mBands and b3On ? d3L : na
pvw = plot(pVw, "VWAP", color = cVwNow, linewidth = wVw, style = plot.style_linebr, display = display.pane)
pu1 = plot(pU1, "+1σ", color = cU1, linewidth = wB1, style = plot.style_linebr, display = display.pane)
pl1 = plot(pL1, "−1σ", color = cL1, linewidth = wB1, style = plot.style_linebr, display = display.pane)
pu2 = plot(pU2, "+2σ", color = cU2, linewidth = wB2, style = plot.style_linebr, display = display.pane)
pl2 = plot(pL2, "−2σ", color = cL2, linewidth = wB2, style = plot.style_linebr, display = display.pane)
pu3 = plot(pU3, "+3σ", color = cU3, linewidth = wB3, style = plot.style_linebr, display = display.pane)
pl3 = plot(pL3, "−3σ", color = cL3, linewidth = wB3, style = plot.style_linebr, display = display.pane)
bool  fOn  = showAll and mFill and mBands
bool  fGr  = fillMode != "Flat"
float fMax = b3On ? b3 : b2
f_ft(float k) => int(math.round(100 - fillStr * math.pow(math.min(1.0, k / fMax), fillCurve)))
color fU1 = color.new(cU1, f_ft(b1))
color fL1 = color.new(cL1, f_ft(b1))
color fU2 = color.new(cU2, f_ft(b2))
color fL2 = color.new(cL2, f_ft(b2))
color fU3 = color.new(cU3, f_ft(b3))
color fL3 = color.new(cL3, f_ft(b3))
color fUF = color.new(cU2, 100 - fillStr)
color fLF = color.new(cL2, 100 - fillStr)
// full-history mode: one shade per zone (TradingView plot fills)
fill(pvw, pu1, color = fOn and fGr ? fU1 : na, title = "Fill VWAP → +1σ")
fill(pl1, pvw, color = fOn and fGr ? fL1 : na, title = "Fill VWAP → −1σ")
fill(pu1, pu2, color = fOn ? (fGr ? fU2 : fUF) : na, title = "Fill +1σ → +2σ")
fill(pl2, pl1, color = fOn ? (fGr ? fL2 : fLF) : na, title = "Fill −1σ → −2σ")
fill(pu2, pu3, color = fOn and fGr ? fU3 : na, title = "Fill +2σ → +3σ")
fill(pl3, pl2, color = fOn and fGr ? fL3 : na, title = "Fill −2σ → −3σ")

// zero-lag smoothing: an EMA forward, then backward over the result, 8 times
f_smooth(array<float> a) =>
    int n = array.size(a)
    if n > 2
        float al = 2.0 / (8 + 1)
        for pass = 1 to 8
            float e = array.get(a, 0)
            for i = 1 to n - 1
                e := e + al * (array.get(a, i) - e)
                array.set(a, i, e)
            e := array.get(a, n - 1)
            for i = n - 2 to 0
                e := e + al * (array.get(a, i) - e)
                array.set(a, i, e)
    a
// points for value + k × sd; stepped mode holds each value until the next sample
f_build(array<int> ts, array<float> vs, array<float> sds, float k) =>
    array<chart.point> pts = array.new<chart.point>()
    int n = array.size(ts)
    float prev = na
    for i = 0 to n - 1
        float v = array.get(vs, i) + k * array.get(sds, i)
        int t = array.get(ts, i)
        if lineShp == "Stepped" and not na(prev)
            array.push(pts, chart.point.from_index(t, prev))
        array.push(pts, chart.point.from_index(t, v))
        prev := v
    pts
var array<polyline> myPl = array.new<polyline>()
f_poly(array<chart.point> pts, color c, int w, string st) =>
    if array.size(pts) >= 2 and not na(c)
        array.push(myPl, polyline.new(pts, curved = false, closed = false, xloc = xloc.bar_index, line_color = c, line_width = w, line_style = f_ls(st)))
// a filled slice between two band multiples kA (inner edge) and kB (outer edge)
f_band(array<int> ts, array<float> vs, array<float> sds, float kA, float kB, color c) =>
    if not na(c)
        array<chart.point> pts = array.new<chart.point>()
        int n = array.size(ts)
        for i = 0 to n - 1
            array.push(pts, chart.point.from_index(array.get(ts, i), array.get(vs, i) + kB * array.get(sds, i)))
        for i = n - 1 to 0
            array.push(pts, chart.point.from_index(array.get(ts, i), array.get(vs, i) + kA * array.get(sds, i)))
        if array.size(pts) >= 3
            array.push(myPl, polyline.new(pts, curved = false, closed = true, xloc = xloc.bar_index, line_color = color.new(c, 100), fill_color = c))
// hyper gradient colour at distance k (σ) on one side: blends band colours, deepens with distance
f_hgCol(float k, color c1, color c2, color c3) =>
    color base = k <= b1 ? c1 : k <= b2 ? color.from_gradient(k, b1, b2, c1, c2) : color.from_gradient(k, b2, b3, c2, c3)
    color.new(base, f_ft(k))

f_blk11() =>
    if drawNow
        for p in myPl
            polyline.delete(p)
        array.clear(myPl)
        if showAll and curOnly and sOk
            // the engine line and its bands from the anchor to the last bar, rebuilt from the running sums
            int a0 = anStartBar
            int tFrom = selIdx == 0 ? math.max(cBase, bar_index - math.min(rvHist, DRAWMAX) + 1) : math.max(a0, cBase, bar_index - DRAWMAX + 1)
            int nC = bar_index - tFrom + 1
            int stepC = math.max(1, int(math.ceil(nC / 400.0)))
            array<int>   cts = array.new<int>()
            array<float> cvw = array.new<float>()
            array<float> csd = array.new<float>()
            int t = tFrom
            while t <= bar_index
                int aT = selIdx == 0 ? f_rvAt(t) : a0
                [v0, s0, n0] = f_vwAt(aT, t)
                if not na(v0) and n0 >= 2
                    array.push(cts, t)
                    array.push(cvw, v0)
                    array.push(csd, nz(s0))
                t := t == bar_index ? bar_index + 1 : math.min(bar_index, t + stepC)
            if array.size(cts) >= 2
                if lineShp == "Smooth x8 (double pass)"
                    f_smooth(cvw)
                    f_smooth(csd)
                array<float> zsd = array.new_float(array.size(cts), 0.0)
                if mBands and mFill
                    if fillMode == "Hyper gradient"
                        float kTop = b3On ? b3 : b2
                        int   zN = b3On ? 3 : 2
                        for z = 0 to zN - 1
                            float zA = z == 0 ? 0.0 : z == 1 ? b1 : b2
                            float zB = z == 0 ? b1 : z == 1 ? b2 : b3
                            for s = 0 to fillSteps - 1
                                float ka = zA + (zB - zA) * s / fillSteps
                                float kb = zA + (zB - zA) * (s + 1) / fillSteps
                                float km = (ka + kb) / 2
                                f_band(cts, cvw, csd, ka, kb, f_hgCol(km, cU1, cU2, cU3))
                                f_band(cts, cvw, csd, -kb, -ka, f_hgCol(km, cL1, cL2, cL3))
                    else
                        f_band(cts, cvw, csd, 0.0, b1, fGr ? fU1 : na)
                        f_band(cts, cvw, csd, -b1, 0.0, fGr ? fL1 : na)
                        f_band(cts, cvw, csd, b1, b2, fGr ? fU2 : fUF)
                        f_band(cts, cvw, csd, -b2, -b1, fGr ? fL2 : fLF)
                        if b3On and fGr
                            f_band(cts, cvw, csd, b2, b3, fU3)
                            f_band(cts, cvw, csd, -b3, -b2, fL3)
                if mBands
                    f_poly(f_build(cts, cvw, csd, b1), cU1, wB1, sB1)
                    f_poly(f_build(cts, cvw, csd, -b1), cL1, wB1, sB1)
                    f_poly(f_build(cts, cvw, csd, b2), cU2, wB2, sB2)
                    f_poly(f_build(cts, cvw, csd, -b2), cL2, wB2, sB2)
                    if b3On
                        f_poly(f_build(cts, cvw, csd, b3), cU3, wB3, sB3)
                        f_poly(f_build(cts, cvw, csd, -b3), cL3, wB3, sB3)
                if mVwap
                    f_poly(f_build(cts, cvw, zsd, 0.0), cVwNow, wVw, sVwSt)
        // right-edge labels for the line and bands
        if showAll and sOk
            if mBands and labBand
                f_rq(u1L, "+" + str.tostring(b1) + "σ", cU1)
                f_rq(d1L, "−" + str.tostring(b1) + "σ", cL1)
                f_rq(u2L, "+" + str.tostring(b2) + "σ", cU2)
                f_rq(d2L, "−" + str.tostring(b2) + "σ", cL2)
                if b3On
                    f_rq(u3L, "+" + str.tostring(b3) + "σ", cU3)
                    f_rq(d3L, "−" + str.tostring(b3) + "σ", cL3)

    // =============================================================================
    // TRADE LINES (latest trades of the chart anchor: MR and break / reclaim)
    // =============================================================================
    true
f_blk11()
var array<label> brLabs = array.new<label>()
f_blk13() =>
    if showAll and brSig != 0
        bool strong = brGr >= math.max(1, gReq)
        color bc = not strong ? cBrkWk : brSig == 1 ? cBrkUp : cBrkDn
        f_mark(brLabs, bar_index, brSig == 1 ? low : high, brSig == 1, brTyp == 1 ? brShape : rcShape, sigSzIn, bc, 80)

    // =============================================================================
    // VOLUME PROFILE — right of the last candle, snapped to the VWAP ENGINE bars
    // =============================================================================
    true
f_blk13()
var array<float> vhH = array.new_float()
var array<float> vhL = array.new_float()
var array<float> vhV = array.new_float()
var array<float> vhB = array.new_float()
// 1-minute data for the profile: every intrabar's close, volume and signed volume, flat, with a count per chart bar
var array<float> vIvP = array.new_float()
var array<float> vIvV = array.new_float()
var array<float> vIvS = array.new_float()
var array<int>   vIvN = array.new_int()
array.push(vhH, high)
array.push(vhL, low)
array.push(vhV, nz(volume))
array.push(vhB, nz(barBuy))
int nIvHere = 0
if vpSrc == "Tick data (1-minute)" and not memSaver and nPocIB > 0
    int nS = array.size(ivS)
    for i = 0 to nPocIB - 1
        float pc = array.get(pocIvC, i)
        float vv = nz(array.get(pocIvV, i))
        if not na(pc) and vv > 0
            array.push(vIvP, pc)
            array.push(vIvV, vv)
            array.push(vIvS, i < nS ? nz(array.get(ivS, i)) : 0.0)
            nIvHere += 1
array.push(vIvN, nIvHere)
if array.size(vhH) > CAP
    int nTr = array.size(vhH)
    int nIvTr = 0
    for i = 0 to TRIM - 1
        nIvTr += array.get(vIvN, i)
    vhH := array.copy(array.slice(vhH, TRIM, nTr))
    vhL := array.copy(array.slice(vhL, TRIM, nTr))
    vhV := array.copy(array.slice(vhV, TRIM, nTr))
    vhB := array.copy(array.slice(vhB, TRIM, nTr))
    vIvN := array.copy(array.slice(vIvN, TRIM, nTr))
    if nIvTr > 0
        int nIv = array.size(vIvP)
        vIvP := array.copy(array.slice(vIvP, nIvTr, nIv))
        vIvV := array.copy(array.slice(vIvV, nIvTr, nIv))
        vIvS := array.copy(array.slice(vIvS, nIvTr, nIv))
// the 1-minute arrays have up to (chart minutes) entries per bar, so they hit Pine's 100k array limit long
// before the bar arrays do: drop the oldest bars' minutes (their per-bar counts go to 0, so the bar arrays stay aligned)
if array.size(vIvP) > 80000
    int nIv = array.size(vIvP)
    int nDrop = 0
    int k = 0
    while nDrop < 30000 and k < array.size(vIvN)
        nDrop += array.get(vIvN, k)
        array.set(vIvN, k, 0)
        k += 1
    vIvP := array.copy(array.slice(vIvP, nDrop, nIv))
    vIvV := array.copy(array.slice(vIvV, nDrop, nIv))
    vIvS := array.copy(array.slice(vIvS, nDrop, nIv))
f_k(float v) => v >= 1e6 ? str.tostring(v / 1e6, "#.#") + "M" : v >= 1e3 ? str.tostring(v / 1e3, "#.#") + "k" : str.tostring(v, "#")
var array<box>   vpBoxes = array.new<box>()
var array<label> vpLabs  = array.new<label>()
var array<line>  vpLines = array.new<line>()
// profile over array slots iA..iB: price floor, row height, volume + buying per row, POC row, value-area rows, max row volume
f_vpCalc(int iA, int iB) =>
    float hi = -1e300
    float lo = 1e300
    for i = iA to iB
        hi := math.max(hi, array.get(vhH, i))
        lo := math.min(lo, array.get(vhL, i))
    float rh = (hi - lo) / vpRows
    array<float> rv = array.new_float(vpRows, 0.0)     // volume per row
    array<float> rb = array.new_float(vpRows, 0.0)     // buying per row
    float mx = 0.0
    int poc = 0
    int vaUp = 0
    int vaDn = 0
    float mxD = 0.0
    if rh > 0
        if vpSrc == "Tick data (1-minute)" and array.size(vIvN) == array.size(vhH)
            int k0 = 0
            for i = 0 to iA - 1
                k0 += array.get(vIvN, i)
            int k1 = k0
            for i = iA to iB
                k1 += array.get(vIvN, i)
            int nIv = array.size(vIvP)
            if k1 > k0 and k1 <= nIv
                for k = k0 to k1 - 1
                    float p = array.get(vIvP, k)
                    float v = array.get(vIvV, k)
                    float sv = array.get(vIvS, k)
                    int r = math.max(0, math.min(vpRows - 1, int(math.floor((p - lo) / rh))))
                    array.set(rv, r, array.get(rv, r) + v)
                    array.set(rb, r, array.get(rb, r) + (sv > 0 ? sv : 0.0))
        else
            for i = iA to iB
                float h = array.get(vhH, i)
                float l = array.get(vhL, i)
                float v = array.get(vhV, i)
                float bfr = v > 0 ? math.max(0.0, math.min(1.0, array.get(vhB, i) / v)) : 0.5
                int r0 = math.max(0, math.min(vpRows - 1, int(math.floor((l - lo) / rh))))
                int r1 = math.max(0, math.min(vpRows - 1, int(math.floor((h - lo) / rh))))
                float span = math.max(h - l, syminfo.mintick)
                for r = r0 to r1
                    float rLo = lo + r * rh
                    float ov = h > l ? math.max(0.0, math.min(h, rLo + rh) - math.max(l, rLo)) / span : 1.0 / (r1 - r0 + 1)
                    array.set(rv, r, array.get(rv, r) + v * ov)
                    array.set(rb, r, array.get(rb, r) + v * ov * bfr)
        mx := array.max(rv)
        poc := array.indexof(rv, mx)
        // value area: grow from the POC toward the heavier side until vpVaPct of the volume is inside
        float total = array.sum(rv)
        vaUp := poc
        vaDn := poc
        float acc = mx
        while acc < total * vpVaPct / 100.0 and (vaUp < vpRows - 1 or vaDn > 0)
            float vU = vaUp < vpRows - 1 ? array.get(rv, vaUp + 1) : -1.0
            float vD = vaDn > 0 ? array.get(rv, vaDn - 1) : -1.0
            if vU >= vD
                vaUp += 1
                acc += vU
            else
                vaDn -= 1
                acc += vD
        // delta scale: the biggest |delta| of any row, so delta bars use the same length as the volume bars
        for r = 0 to vpRows - 1
            mxD := math.max(mxD, math.abs(2 * array.get(rb, r) - array.get(rv, r)))
    [lo, rh, rv, rb, poc, vaUp, vaDn, mx, mxD]
// draw one profile over array slots iA..iB, its centre axis at bar x0
f_vpDraw(int iA, int iB, int x0) =>
    [lo, rh, rv, rb, poc, vaUp, vaDn, mx, mxD] = f_vpCalc(iA, iB)
    if mx > 0
        // centre axis
        array.push(vpLines, line.new(x0, lo, x0, lo + vpRows * rh, color = color.new(#787B86, 20), width = 1))
        for r = 0 to vpRows - 1
            float v = array.get(rv, r)
            if v > 0
                float top = lo + (r + 1) * rh
                float bot = lo + r * rh
                float mid = (top + bot) / 2
                float b = array.get(rb, r)
                float sl = v - b
                float d = b - sl
                bool isPoc = r == poc
                bool inVa = r >= vaDn and r <= vaUp
                bool isHvn = v >= mx * vpHvn / 100.0
                bool imbB = b >= sl * vpImb and sl >= 0
                bool imbS = sl >= b * vpImb and b >= 0
                bool imb = imbB or imbS
                bool onlyImb = vpTag == "Imbalanced rows only"
                int dim = onlyImb and not imb ? 75 : 30
                color cRow = isPoc ? cVpPoc : isHvn ? cVpHvn : inVa and vpVaShade ? cVpVa : cVpRow
                int rightEnd = x0
                if vpMode == "Volume"
                    int len = math.max(1, int(math.round(vpWid * v / mx)))
                    array.push(vpBoxes, box.new(x0, top, x0 + len, bot, border_color = cRow, bgcolor = onlyImb and not imb ? color.new(cRow, 80) : cRow, border_width = 0))
                    rightEnd := x0 + len
                else if vpMode == "Buy vs sell"
                    // one bar on the volume scale: green buying first, red selling after it
                    int len = math.max(1, int(math.round(vpWid * v / mx)))
                    int lb = int(math.round(len * b / v))
                    if lb > 0
                        array.push(vpBoxes, box.new(x0, top, x0 + lb, bot, border_color = isPoc ? cVpPoc : color.new(colBull, dim), bgcolor = color.new(colBull, dim), border_width = isPoc ? 1 : 0))
                    if len - lb > 0
                        array.push(vpBoxes, box.new(x0 + lb, top, x0 + len, bot, border_color = isPoc ? cVpPoc : color.new(colBear, dim), bgcolor = color.new(colBear, dim), border_width = isPoc ? 1 : 0))
                    rightEnd := x0 + len
                else
                    // net delta: bar length = |delta|, green when buying won, red when selling won
                    int ld = mxD > 0 ? math.max(1, int(math.round(vpWid * math.abs(d) / mxD))) : 1
                    color cD = d >= 0 ? color.new(colBull, dim) : color.new(colBear, dim)
                    array.push(vpBoxes, box.new(x0, top, x0 + ld, bot, border_color = isPoc ? cVpPoc : cD, bgcolor = cD, border_width = isPoc ? 1 : 0))
                    rightEnd := x0 + ld
                // the tag at the end of the bar
                string tx = ""
                color cTg = color.new(#D1D4DC, 10)
                if vpNum
                    string sD = (d >= 0 ? "+" : "−") + f_k(math.abs(d))
                    string sBS = f_k(b) + " / " + f_k(sl)
                    if vpTag == "Delta"
                        tx := sD
                        cTg := d >= 0 ? colBull : colBear
                    else if vpTag == "Buy / sell"
                        tx := sBS
                    else if vpTag == "Delta + buy / sell"
                        tx := sD + "  " + sBS
                        cTg := d >= 0 ? colBull : colBear
                    else if imb
                        tx := (imbB ? "▲ " : "▼ ") + sD
                        cTg := imbB ? colBull : colBear
                if tx != ""
                    int xT = math.max(rightEnd, x0 + vpTagMin)
                    array.push(vpLabs, label.new(xT, mid, tx, style = label.style_label_left, color = #00000000, textcolor = isPoc ? cVpPoc : cTg, size = f_sz(vpTagSz)))
        // POC / VAH / VAL of the window → side-profile line queue (always on; colour / width / style in section 3)
        f_pq(lo + (poc + 0.5) * rh, "POC", cPrPoc, wPrPoc, sPrPoc)
        f_pq(lo + (vaUp + 1) * rh, "VAH", cPrVa, wPrVa, sPrVa)
        f_pq(lo + vaDn * rh, "VAL", cPrVa, wPrVa, sPrVa)
f_blk15() =>
    if drawNow
        for bx in vpBoxes
            box.delete(bx)
        array.clear(vpBoxes)
        for lb in vpLabs
            label.delete(lb)
        array.clear(vpLabs)
        for ln in vpLines
            line.delete(ln)
        array.clear(vpLines)
        int nSz = array.size(vhH)
        if mVp and showAll and not memSaver and nSz >= 2
            int n = vpCover == "VWAP engine window" ? math.min(nSz, math.max(2, selN)) : math.min(nSz, math.max(2, vpN))
            int x0 = bar_index + vpOff
            f_vpDraw(nSz - n, nSz - 1, x0)
    true

f_blk15()
bool slOn = showAll and mSessLv and not memSaver
string brTf = timeframe.in_seconds("30") < timeframe.in_seconds() ? timeframe.period : "30"
bool  brRoll = timeframe.change(brTf)
var bool  r80Armed = false
var bool  r80Trig = false
var int   r80Cnt = 0
var int   r80Side = 0
var float r80Vah = na
var float r80Val = na
var float r80Tgt = na
var int   r80Bar = na
bool r80Event = false
float r80Prev = close[1]
if newD
    r80Trig := false
    r80Cnt := 0
    r80Tgt := na
    r80Armed := not na(prevSessVah) and not na(prevSessVal) and (open > prevSessVah or open < prevSessVal)
    r80Side := open > nz(prevSessVah) ? 1 : -1
    r80Vah := prevSessVah
    r80Val := prevSessVal
else if r80Armed and not r80Trig and brRoll
    r80Cnt := r80Prev <= r80Vah and r80Prev >= r80Val ? r80Cnt + 1 : 0
    if r80Cnt >= r80Need
        r80Trig := true
        r80Tgt := r80Side == 1 ? r80Val : r80Vah
        r80Bar := bar_index
        r80Event := true
var array<line> slLines = array.new<line>()
f_blk16() =>
    if drawNow
        for ln in slLines
            line.delete(ln)
        array.clear(slLines)
        if slOn
            int x1 = bar_index + labOff
            if pVaOn and not na(prevSessVah)
                f_pq(prevSessVah, slLab ? "pVAH" : "", cPVa, wPVa, sPVa)
                f_pq(prevSessVal, slLab ? "pVAL" : "", cPVa, wPVa, sPVa)
            if pPocOn
                int nk = array.size(nakedPocs)
                if nk > 0
                    for i = 0 to nk - 1
                        float np = array.get(nakedPocs, i)
                        int   nbx = array.get(nakedBars, i)
                        if bar_index - nbx < 4900
                            f_pq(np, slLab ? "nPOC" : "", cPPoc, wPPoc, sPPoc)
            if r80On and r80Trig and not na(r80Tgt) and not na(r80Bar)
                array.push(slLines, line.new(r80Bar, r80Tgt, x1, r80Tgt, color = cR80, width = 2, style = line.style_dashed))
                if slLab
                    f_rq(r80Tgt, "80% target", cR80)
    // session alerts
    true
f_blk16()
int   nkNow = array.size(nakedPocs)
bool  nakedTouch = not newD and nkNow < nz(nkNow[1])
bool  inDevVa = not na(sessVah) and close <= sessVah and close >= sessVal
bool  leftVa = barstate.isconfirmed and not inDevVa and inDevVa[1] and not newD

// =============================================================================
// EMAs AND 20-WEEK BANDS
// =============================================================================
bool emOn = showAll and mEmaIn
bool w20Ok = emOn and w20On and not na(w20Ema) and not na(w20Atr)
// Smooth x8 draws these as polylines (below); the plots carry Raw and Stepped
bool emPlot = lineShp != "Smooth x8 (double pass)"
plot(emPlot and emOn and ema1On ? emaOut : na, "233 EMA", color = cEma1, linewidth = wEma1, display = display.pane)
plot(emPlot and emOn and ema2On ? w20Ema : na, "20W EMA", color = cEma2, linewidth = wEma2, display = display.pane)
pw1u = plot(emPlot and w20Ok ? w20Ema + w20M1 * w20Atr : na, "20W +1", color = cW20, linewidth = wW20, display = display.pane)
pw1d = plot(emPlot and w20Ok ? w20Ema - w20M1 * w20Atr : na, "20W −1", color = cW20, linewidth = wW20, display = display.pane)
pw2u = plot(emPlot and w20Ok ? w20Ema + w20M2 * w20Atr : na, "20W +2", color = cW20, linewidth = wW20, display = display.pane)
pw2d = plot(emPlot and w20Ok ? w20Ema - w20M2 * w20Atr : na, "20W −2", color = cW20, linewidth = wW20, display = display.pane)
pw3u = plot(emPlot and w20Ok ? w20Ema + w20M3 * w20Atr : na, "20W +3", color = cW20, linewidth = wW20, display = display.pane)
pw3d = plot(emPlot and w20Ok ? w20Ema - w20M3 * w20Atr : na, "20W −3", color = cW20, linewidth = wW20, display = display.pane)
fill(pw2u, pw3u, color = emPlot and w20Ok and w20Fill ? cW20Up : na, title = "20W fill up")
fill(pw3d, pw2d, color = emPlot and w20Ok and w20Fill ? cW20Dn : na, title = "20W fill down")
// history of the three series for the smoothed drawing
var array<float> hEma = array.new_float()
var array<float> hW20 = array.new_float()
var array<float> hAtr = array.new_float()
array.push(hEma, emaOut)
array.push(hW20, w20Ema)
array.push(hAtr, nz(w20Atr))
if array.size(hEma) > CAP
    int nTr = array.size(hEma)
    hEma := array.copy(array.slice(hEma, TRIM, nTr))
    hW20 := array.copy(array.slice(hW20, TRIM, nTr))
    hAtr := array.copy(array.slice(hAtr, TRIM, nTr))
var array<polyline> emPl = array.new<polyline>()
f_emPoly(array<chart.point> pts, color c, int w, string st) =>
    if array.size(pts) >= 2
        array.push(emPl, polyline.new(pts, curved = false, closed = false, xloc = xloc.bar_index, line_color = c, line_width = w, line_style = f_ls(st)))
f_blkEm() =>
    if drawNow
        for p in emPl
            polyline.delete(p)
        array.clear(emPl)
        if not emPlot and emOn and (ema1On or ema2On or w20Ok)
            // EMAs and 20-week lines go back over the whole kept history (up to 20,000 bars), not just the rVWAP history
            int nH = array.size(hEma)
            int nC = math.min(nH, DRAWMAX)
            int i0 = nH - nC
            int stepC = math.max(1, int(math.ceil(nC / 600.0)))
            array<int>   ts = array.new<int>()
            array<float> ve = array.new<float>()
            array<float> vw = array.new<float>()
            array<float> va = array.new<float>()
            int ii = i0
            while ii <= nH - 1
                float e0 = array.get(hEma, ii)
                float w0 = array.get(hW20, ii)
                if not na(e0) and not na(w0)
                    array.push(ts, bar_index - (nH - 1 - ii))
                    array.push(ve, e0)
                    array.push(vw, w0)
                    array.push(va, array.get(hAtr, ii))
                ii := ii == nH - 1 ? nH : math.min(nH - 1, ii + stepC)
            if array.size(ts) >= 2
                f_smooth(ve)
                f_smooth(vw)
                f_smooth(va)
                array<float> z0 = array.new_float(array.size(ts), 0.0)
                if w20Ok and w20Fill
                    f_band(ts, vw, va, w20M2, w20M3, cW20Up)
                    f_band(ts, vw, va, -w20M3, -w20M2, cW20Dn)
                if ema1On
                    f_emPoly(f_build(ts, ve, z0, 0.0), cEma1, wEma1, sEma1)
                if ema2On
                    f_emPoly(f_build(ts, vw, z0, 0.0), cEma2, wEma2, sEma2)
                if w20Ok
                    f_emPoly(f_build(ts, vw, va, w20M1), cW20, wW20, sW20)
                    f_emPoly(f_build(ts, vw, va, -w20M1), cW20, wW20, sW20)
                    f_emPoly(f_build(ts, vw, va, w20M2), cW20, wW20, sW20)
                    f_emPoly(f_build(ts, vw, va, -w20M2), cW20, wW20, sW20)
                    f_emPoly(f_build(ts, vw, va, w20M3), cW20, wW20, sW20)
                    f_emPoly(f_build(ts, vw, va, -w20M3), cW20, wW20, sW20)
    true
f_blkEm()
f_blk19() =>
    if drawNow and emOn and emaLab
        if ema1On
            f_rq(emaOut, "233 EMA", cEma1)
        if ema2On
            f_rq(w20Ema, "20W EMA", cEma2)
        if w20Ok
            f_rq(w20Ema + w20M2 * w20Atr, "20W +" + str.tostring(w20M2), cW20)
            f_rq(w20Ema - w20M2 * w20Atr, "20W −" + str.tostring(w20M2), cW20)
    true
f_blk19()
// =============================================================================
// MODULE ib_ · STRYK:MRV v4.0 — Opening box (IB), IB / volume marks, live info table
// Moved from STRYK: OP v2.0 (cash open box engine, box delta profile, volume engines,
// volume table). Paste after the core; no //@version or indicator() here.
//
// What it does
//   • 08:30–09:30 CT opening box every day: shade, outline, 50% level, box POC / VAH /
//     VAL from the window's own intrabar volume, extension levels 0.5×–3× (one at a
//     time reveal), extend untested / previous / every box, brighten the box closest
//     to price, extend switches for the VWAP anchor box and the latest box, a second
//     set of targets from the VWAP anchor box, box labels with dates.
//     The anchor box = the first opening box that starts at or after the core's
//     VWAP anchor start (anStartTime).
//   • Marks (small labels): range extension, extension level reached, volume flips.
//   • Alerts: box complete, range extension up / down, extension level, volume flip
//     (all through ib_alert(), silenced when mMaster is off).
//   • Live info table (shown when tblMode is Live info or Both) at f_pos(tblPosLive).
//
// request.* calls: 1 (request.security_lower_tf for the box delta profile;
//   asks for the chart timeframe instead when memSaver is on, and its data is ignored)
// Drawings worst case (own objects):
//   boxes  : ib_maxBox   (default 40, max 200)
//   lines  : ib_maxLn    (default 150, max 400)
//   labels : ib_maxLab + ib_mkMax (defaults 40 + 60, max 200 + 200)
//   tables : 1
//   f_rq() right-edge labels queued to the core per redraw: at most 52
//     (24 targets, 12 extended box lines, 16 IBH/IBL on boxes that reach the edge)
// Plots used: 0.   alert() call sites: 1 helper, 5 alert messages. alertcondition: 0.
// Inline input rows carry one tooltip on the last field of the row (covers the row).
//
// Core names used: mMaster, mClean (via showAll), memSaver, showAll, barDelta,
//   colBull, colNeut, colBear, drawNow, TZ, sVw, sSd, sOk, b1, b2, b3, b3On,
//   anStartTime, lastSigTxt, f_sz, labOff, labOn, labPrice, f_stamp (labDate /
//   labTime), f_rq, tblMode, tblPosLive, f_pos
// =============================================================================

string ib_G9  = "8 · Opening box (IB)"
string ib_G10 = "9 · Live info table"

// --- 9 · opening box ----------------------------------------------------------
bool ib_on = mIbOn
ib_winIn   = input.session("0830-0930", "Opening window (open – close)", group = ib_G9,
     tooltip = "The start and end of the opening range that each box covers, read in the script's exchange timezone (America/Chicago, the CME clock). 08:30 to 09:30 is the first hour of the cash session, the classic initial balance (IB). 08:30 to 09:00 gives the 30-minute opening range. The box's top is the high of this window and its bottom is the low.")
ib_days    = input.int(10, "Boxes to show (days)", minval = 1, maxval = 200, group = ib_G9,
     tooltip = "How many days of opening boxes stay on the chart, counting today. More boxes means more history but a busier chart. The VWAP anchor box is always drawn, even if it is older than this. Default 10, about two trading weeks.")
ib_maxBox  = input.int(40, "Max drawn: boxes", minval = 2, maxval = 200, group = ib_G9, inline = "mx")
ib_maxLn   = input.int(150, "lines", minval = 20, maxval = 400, group = ib_G9, inline = "mx")
ib_maxLab  = input.int(40, "labels", minval = 0, maxval = 200, group = ib_G9, inline = "mx",
     tooltip = "Hard limits on how many boxes, lines and box labels this section may draw at once. TradingView allows 500 of each type for the whole indicator, shared with every other part, so these keep the opening boxes from crowding the rest out. When a limit is hit, the boxes nearest to today are kept first. Defaults 40 / 150 / 40.")
ib_cFill   = input.color(color.new(#FFEB3B, 85), "Box shade", group = ib_G9,
     tooltip = "Fill colour of each box. Use the opacity slider in the colour picker to make it lighter or darker; fully transparent leaves just the outline.")
ib_cOut    = input.color(#FFEB3B, "Box outline", group = ib_G9, inline = "ib")
ib_wOut    = input.int(2, "", minval = 0, maxval = 5, group = ib_G9, inline = "ib")
ib_sOut    = input.string("Dotted", "", options = ["Solid", "Dashed", "Dotted"], group = ib_G9, inline = "ib",
     tooltip = "Outline of each box: colour, width and line style. Width 0 removes the outline. The high / low lines and box labels use this colour too.")
ib_cMid    = input.color(color.new(#FFFFFF, 30), "", group = ib_G9, inline = "im")
ib_wMid    = input.int(1, "", minval = 1, maxval = 5, group = ib_G9, inline = "im")
ib_sMid    = input.string("Dashed", "", options = ["Solid", "Dashed", "Dotted"], group = ib_G9, inline = "im")
ib_midLab  = input.bool(true, "label", group = ib_G9, inline = "im",
     tooltip = "A line through the middle of each box, halfway between its high and low: on/off, colour, width, style, and a price label at the right edge when the line is extended (see the extend switches below). The midpoint of the open is a common balance level: above it buyers have the upper hand for the day, below it sellers do.")
ib_cPoc    = input.color(#FF9800, "", group = ib_G9, inline = "bp")
ib_wPoc    = input.int(2, "", minval = 1, maxval = 5, group = ib_G9, inline = "bp")
ib_sPoc    = input.string("Solid", "", options = ["Solid", "Dashed", "Dotted"], group = ib_G9, inline = "bp")
ib_pocLab  = input.bool(true, "label", group = ib_G9, inline = "bp",
     tooltip = "POC (point of control): the price where the most volume traded during the opening window, drawn inside its box. On/off, colour, width, style, and a label at the right edge when the line is extended. Price returning to the box POC is returning to the open's fair price.")
ib_cVa     = input.color(color.new(#42A5F5, 0), "", group = ib_G9, inline = "bv")
ib_wVa     = input.int(1, "", minval = 1, maxval = 5, group = ib_G9, inline = "bv")
ib_sVa     = input.string("Dashed", "", options = ["Solid", "Dashed", "Dotted"], group = ib_G9, inline = "bv")
ib_vaLab   = input.bool(true, "label", group = ib_G9, inline = "bv",
     tooltip = "VAH / VAL: the top and bottom of the value area, the range that holds most of the window's volume (the % is set below). On/off, colour, width, style, and labels at the right edge when the lines are extended. Acceptance above the VAH or below the VAL shows the market leaving the open's value.")
ib_wHL     = input.int(1, "Box high / low lines", minval = 1, maxval = 5, group = ib_G9, inline = "hl")
ib_sHL     = input.string("Dashed", "", options = ["Solid", "Dashed", "Dotted"], group = ib_G9, inline = "hl")
ib_hlLab   = input.bool(true, "label", group = ib_G9, inline = "hl",
     tooltip = "Width, style and labels of the high and low lines drawn when a box's High/Low extend switch is on (below). They always use the box outline colour. With the label on, the box's own IBH / IBL labels are replaced by these.")
ib_extAll  = input.bool(false, "Extend every box to the chart edge", group = ib_G9,
     tooltip = "Stretches every box on the chart, with its 50% level and profile lines, to the right edge instead of stopping when its window ends.")
ib_extPrev = input.bool(false, "Extend the previous day's box to the chart edge", group = ib_G9,
     tooltip = "Stretches only yesterday's box (the most recent completed one) to the right edge. Older boxes stay inside their window.")
ib_extUnt  = input.bool(false, "Extend untested boxes to the chart edge", group = ib_G9,
     tooltip = "Any past opening box that later days never traded back into keeps stretching to the right edge of the chart, so you can see open gaps in value. The moment price trades inside it, it stops at that bar.")
ib_fadeOn  = input.bool(false, "Brighten the box closest to price, fade the rest", group = ib_G9, inline = "fd")
ib_fade    = input.int(70, "fade %", minval = 0, maxval = 95, group = ib_G9, inline = "fd",
     tooltip = "Keeps the box nearest to price at full colour and fades the others step by step the further away they are, so the level that matters now stands out. Fade % is how faint the furthest box gets. Default 70.")
ib_xLatPoc = input.bool(true, "Latest box: extend POC", group = ib_G9, inline = "xl")
ib_xLatMid = input.bool(true, "50%", group = ib_G9, inline = "xl")
ib_xLatVA  = input.bool(true, "VAH/VAL", group = ib_G9, inline = "xl")
ib_xLatHL  = input.bool(true, "High/Low", group = ib_G9, inline = "xl",
     tooltip = "The same four switches for the most recent box (today's, the one forming during 08:30–09:30, or yesterday's before the open), independent of the anchor box switches. Only the lines stretch; the box keeps its size.")
ib_extProg = input.bool(true, "Reveal levels one at a time", group = ib_G9, inline = "xp")
ib_cHit    = input.color(color.new(#9E9E9E, 30), "reached", group = ib_G9, inline = "xp",
     tooltip = "ON: only the next target is drawn on each side. 0.5× shows first; once price reaches it, 1× appears, then 1.5×, and so on through the levels switched on below. Levels already reached stay on the chart in the REACHED colour (with a ✓ on the label) so you can see how far the day has stretched. Up and down sides advance on their own.\nOFF: every level switched on below is drawn from the start.")
ib_x05     = input.bool(true, "0.5×", group = ib_G9, inline = "ix")
ib_x1      = input.bool(true, "1×", group = ib_G9, inline = "ix")
ib_x15     = input.bool(true, "1.5×", group = ib_G9, inline = "ix")
ib_x2      = input.bool(true, "2×", group = ib_G9, inline = "ix")
ib_x25     = input.bool(true, "2.5×", group = ib_G9, inline = "ix")
ib_x3      = input.bool(true, "3×", group = ib_G9, inline = "ix")
ib_x35     = input.bool(true, "3.5×", group = ib_G9, inline = "ix2")
ib_x4      = input.bool(true, "4×", group = ib_G9, inline = "ix2")
ib_x45     = input.bool(true, "4.5×", group = ib_G9, inline = "ix2")
ib_x5      = input.bool(true, "5×", group = ib_G9, inline = "ix2")
ib_x55     = input.bool(true, "5.5×", group = ib_G9, inline = "ix2")
ib_x6      = input.bool(true, "6×", group = ib_G9, inline = "ix2")
ib_x65     = input.bool(true, "6.5×", group = ib_G9, inline = "ix3")
ib_x7      = input.bool(true, "7×", group = ib_G9, inline = "ix3")
ib_x75     = input.bool(true, "7.5×", group = ib_G9, inline = "ix3")
ib_x8      = input.bool(true, "8×", group = ib_G9, inline = "ix3")
ib_x85     = input.bool(true, "8.5×", group = ib_G9, inline = "ix3")
ib_x9      = input.bool(true, "9×", group = ib_G9, inline = "ix3")
ib_x95     = input.bool(true, "9.5×", group = ib_G9, inline = "ix4")
ib_x10     = input.bool(true, "10×", group = ib_G9, inline = "ix4",
     tooltip = "Which multiples of the box height to draw beyond its high and low, 0.5× up to 10×. With REVEAL LEVELS ONE AT A TIME on, only the levels price has reached plus the next one show, so the extra targets only appear on big days. The same switches decide which levels count for the 'extension level reached' marks and alert.")
ib_cUp     = input.color(color.new(#26A69A, 20), "Up", group = ib_G9, inline = "ic")
ib_cDn     = input.color(color.new(#EF5350, 20), "Down", group = ib_G9, inline = "ic")
ib_wExt    = input.int(1, "", minval = 1, maxval = 5, group = ib_G9, inline = "ic")
ib_sExt    = input.string("Dotted", "", options = ["Solid", "Dashed", "Dotted"], group = ib_G9, inline = "ic",
     tooltip = "Colours, width and style of the up and down extension levels. The range extension and extension level marks use the same up / down colours.")
ib_cAncUp  = input.color(color.new(#80CBC4, 10), "up", group = ib_G9, inline = "ia")
ib_cAncDn  = input.color(color.new(#EF9A9A, 10), "down", group = ib_G9, inline = "ia",
     tooltip = "Adds a second set of extension targets (0.5× to 3× the box height) measured from the VWAP anchor box, starting where that box ends and running to the chart edge, labelled 'Anchor IB'. They reveal one at a time from the highest high / lowest low traded since that box closed and use the same multiples, width, style and labels as today's targets. Needs 'Extension levels on today's box' on.")
ib_labSz   = input.string("Tiny", "", options = ["Tiny", "Small", "Normal", "Large"], group = ib_G9, inline = "ibl",
     tooltip = "IBH (high) and IBL (low) labels at the right end of each box, and their text size. Older boxes get their date when the global date / time label switches are on. A box that reaches the chart edge has its labels placed in the right-edge stack so they never overlap. Price is added when the global price switch is on.")
ib_ltfMode = input.string("Auto", "Box profile: intrabar data", options = ["Auto", "1 second", "5 seconds", "15 seconds", "30 seconds", "1 minute", "5 minutes"], group = ib_G9,
     tooltip = "Each chart candle inside the opening window is broken into smaller candles of this size to build the box volume profile (POC, VAH, VAL) and its delta. Each small candle that closes up counts its volume as buying, down as selling. Finer is more accurate but loads less history. AUTO picks 1 minute on intraday charts. Seconds need a plan that allows them. In replay / memory saver mode no intrabar data is fetched and each candle counts as one block.")
ib_binTk   = input.int(4, "Box profile: price bin (ticks)", minval = 1, maxval = 100, group = ib_G9, inline = "bn")
ib_vaPct   = input.int(70, "value area %", minval = 50, maxval = 95, group = ib_G9, inline = "bn",
     tooltip = "PRICE BIN: how finely the box volume profile is split, in ticks per row. 4 ticks on ES / MES is 1 point. Smaller is more detailed but slower.\nVALUE AREA %: the share of the window's volume inside VAH–VAL. 70% is the market-profile standard.")
ib_pxSrc   = input.string("Spread across bar range", "Box profile: volume placement", options = ["Spread across bar range", "HLC3", "OHLC4", "Close"], group = ib_G9,
     tooltip = "Where each small candle's volume is placed in the box profile. SPREAD ACROSS BAR RANGE (recommended, default): shared evenly over every price it traded. The others put it all on one price.")
ib_mkSz    = input.string("Tiny", "Mark size", options = ["Tiny", "Small", "Normal", "Large", "Shape (large)"], group = ib_G9, inline = "ms")
ib_mkMax   = input.int(60, "keep last", minval = 5, maxval = 200, group = ib_G9, inline = "ms",
     tooltip = "Size of the marks, and how many of the most recent marks stay on the chart (all three kinds together). Older ones are removed. Default 60.")
ib_mkGap   = input.int(0, "distance from candle (ticks)", minval = 0, maxval = 200, group = ib_G9, inline = "mt",
     tooltip = "TEXT: writes a short name next to each mark (RE for range extension, X for an extension level, Vol for a volume flip) plus the date / time when the global label switches ask for it.\nDISTANCE: 0 places each mark just above or below its candle automatically; a higher number places it that many ticks away from the candle's high or low.")
ib_alDone  = input.bool(false, "Alert: box complete", group = ib_G9, inline = "al1")
ib_alBreak = input.bool(true, "range extension", group = ib_G9, inline = "al1",
     tooltip = "BOX COMPLETE: alerts when the opening window closes, with the box high and low.\nRANGE EXTENSION: alerts the first time each day price trades above the box high or below the box low after the window closes.\nTo receive alerts, create one on the chart with the condition set to this indicator and 'Any alert() function call'. The master switch silences all of them.")
ib_alExt   = input.bool(false, "Alert: extension level reached", group = ib_G9, inline = "al2",
     tooltip = "Alert when price reaches a new extension level of today's box. Create the alert with Any alert() function call.")

// --- 10 · live info table -------------------------------------------------------
ib_vtLay   = input.string("Mobile (compact)", "Layout", options = ["Desktop", "Mobile (compact)"], group = ib_G10, inline = "vl")
ib_vtSzM   = input.string("Tiny", "mobile text", options = ["Tiny", "Small", "Normal"], group = ib_G10, inline = "vl",
     tooltip = "DESKTOP: three columns with full names, values and a short explanation. MOBILE (COMPACT): two narrow columns with short names and one-word readings, sized for a phone, with its own text size. The table shows only when the table mode in the core settings is Live info or Both, in the corner chosen there.")
ib_vtView  = input.string("Everything", "Table shows", options = ["Everything", "Volume & flow", "Higher-timeframe delta", "Open box delta profile", "VWAP & signals"], group = ib_G10,
     tooltip = "Picks which part of the table is on screen, so a phone only has to show one small block at a time.\nEVERYTHING: every row switched on below.\nVOLUME & FLOW: volume vs normal, participation and Fuel × Δ.\nHIGHER-TIMEFRAME DELTA: the HTF delta rows.\nOPEN BOX DELTA PROFILE: the opening box status, its buying vs selling and the delta profile of the opening window.\nVWAP & SIGNALS: VWAP position and the last signal.")
ib_vtSz    = input.string("Small", "Desktop text size", options = ["Tiny", "Small", "Normal", "Large"], group = ib_G10,
     tooltip = "Text size for the desktop layout. The mobile layout uses its own size above.")
ib_volBase = input.string("Same time of day", "Normal volume", options = ["Same time of day", "Last N bars"], group = ib_G10, inline = "vb")
ib_todDays = input.int(10, "days", minval = 2, maxval = 60, group = ib_G10, inline = "vb",
     tooltip = "What 'normal volume' means for the table and the volume flip marks.\nSAME TIME OF DAY (recommended): the average volume of candles at this exact time on the last N days (default 10). The cash open is always the busiest part of the day, so comparing an 08:30 candle with the previous 20 overnight candles makes it look huge every day. This compares it with other 08:30 candles instead.\nLAST N BARS: the plain moving average below. Also used automatically until there are at least 3 days of history for a time of day.")
ib_avgLen  = input.int(20, "Last N bars", minval = 2, maxval = 500, group = ib_G10, inline = "va")
ib_avgTyp  = input.string("SMA", "", options = ["SMA", "EMA"], group = ib_G10, inline = "va",
     tooltip = "The plain average used by LAST N BARS and as the fallback. SMA treats the last N candles equally; EMA leans toward the most recent ones. Default 20 SMA.")
ib_cols    = input.int(1, "Mobile: columns", minval = 1, maxval = 4, group = ib_G10, inline = "mc")
ib_maxRows = input.int(0, "max rows", minval = 0, maxval = 40, group = ib_G10, inline = "mc",
     tooltip = "Squash the mobile table. COLUMNS: the rows flow into this many side-by-side column pairs, so 16 rows in 2 columns is 8 tall, in 3 columns 6 tall — a short wide rectangle along the bottom of the phone. MAX ROWS: stop after this many rows (0 = all), in the order below. Switch off the rows you never read with the toggles.")
ib_rowVol  = input.bool(true, "Rows: Volume", group = ib_G10, inline = "r1")
ib_rowAvg  = input.bool(true, "Avg", group = ib_G10, inline = "r1")
ib_rowPart = input.bool(true, "Part", group = ib_G10, inline = "r1")
ib_rowFuel = input.bool(true, "Fuel", group = ib_G10, inline = "r1",
     tooltip = "Row toggles, part 1. VOLUME: this candle\'s volume and % of normal. AVG: above or below the average, and when it last flipped. PART: participation score. FUEL: Fuel × Δ, whether the delta is paid or unpaid. Untick a row and it is gone from the table.")
ib_rowVw   = input.bool(true, "VWAP", group = ib_G10, inline = "r2")
ib_rowProf = input.bool(true, "Profile", group = ib_G10, inline = "r2")
ib_rowNode = input.bool(true, "Node", group = ib_G10, inline = "r2")
ib_rowPva  = input.bool(true, "pVA", group = ib_G10, inline = "r2")
ib_rowNpoc = input.bool(true, "nPOC", group = ib_G10, inline = "r2")
ib_rowIB   = input.bool(true, "Box", group = ib_G10, inline = "r3")
ib_rowBuy  = input.bool(true, "Buy/Sell", group = ib_G10, inline = "r3")
ib_rowPoc  = input.bool(true, "POC/Imb", group = ib_G10, inline = "r3")
ib_rowRead = input.bool(true, "Box read", group = ib_G10, inline = "r3")
ib_rowSig  = input.bool(true, "Sig", group = ib_G10, inline = "r3",
     tooltip = "Row toggles, part 2. VWAP: which σ zone price is in. PROFILE: price vs the engine-profile POC and value area. NODE: HVN / LVN at price. pVA: price vs the prior session value area. nPOC: nearest naked POC and distance. BOX: above / inside / below the opening box. BUY/SELL: buyers vs sellers % in the box. POC/IMB: box POC and most one-sided bin. BOX READ: AGREE / ABSORB ▲▼, candle vs delta. SIG: last signal. Untick what you never read.")
ib_rowIBD  = input.bool(true, "Box Δ", group = ib_G10,
     tooltip = "Buying and selling inside the opening window, from closed candles: the net delta and its share of the window's volume, buyers vs sellers as percentages, the busiest price (POC) and the price where buyers or sellers were most one-sided (the biggest imbalance). Before today's open it shows yesterday's window.")
ib_h1On    = input.bool(true, "HTF delta 1", group = ib_G10, inline = "h1")
ib_h1Tf    = input.timeframe("60", "", group = ib_G10, inline = "h1",
     tooltip = "Up to four higher-timeframe delta rows. Each one shows the delta (buying minus selling volume) building inside the current candle of that timeframe, as a number, a share of that candle's volume, and an arrow, coloured by how strong it is against that timeframe's average. 60 minutes is the default; add 15m, 4h or D to see the bigger picture.")
ib_h2On    = input.bool(false, "HTF delta 2", group = ib_G10, inline = "h2")
ib_h2Tf    = input.timeframe("15", "", group = ib_G10, inline = "h2",
     tooltip = "Second higher-timeframe delta row: on/off and its timeframe (default 15 minutes).")
ib_h3On    = input.bool(false, "HTF delta 3", group = ib_G10, inline = "h3")
ib_h3Tf    = input.timeframe("240", "", group = ib_G10, inline = "h3",
     tooltip = "Third higher-timeframe delta row: on/off and its timeframe (default 4 hours).")
ib_h4On    = input.bool(false, "HTF delta 4", group = ib_G10, inline = "h4")
ib_h4Tf    = input.timeframe("D", "", group = ib_G10, inline = "h4",
     tooltip = "Fourth higher-timeframe delta row: on/off and its timeframe (default one day). A timeframe lower than or equal to the chart uses the chart's own candles.")
ib_htfN    = input.int(20, "HTF delta: candles in the average", minval = 3, maxval = 100, group = ib_G10,
     tooltip = "How many completed candles of each higher timeframe make its 'normal' delta, used to colour the HTF delta rows. Default 20.")
ib_pEmaLen = input.int(8, "Participation: volume EMA", minval = 1, maxval = 100, group = ib_G10, inline = "pe")
ib_pLook   = input.int(100, "rank over", minval = 20, maxval = 500, group = ib_G10, inline = "pe")
ib_pFast   = input.bool(true, "spike-aware", group = ib_G10, inline = "pe",
     tooltip = "Participation is where a short average of volume ranks against the last N candles, from 0 (quietest) to 100 (busiest). SPIKE-AWARE also ranks the candle itself and takes the higher of the two, so the first big candle of a move counts straight away. 8 and 100 are the STRYK: Momentum defaults.")
ib_pClimax = input.int(90, "Climax at participation ≥", minval = 60, maxval = 100, group = ib_G10,
     tooltip = "Participation at or above this level reads CLIMAX: an unusually heavy burst, often near the end of a move. Default 90.")
ib_bellPk  = input.int(60, "Fuel: full at participation", minval = 30, maxval = 90, group = ib_G10, inline = "fb")
ib_bellW   = input.int(30, "bell width", minval = 5, maxval = 50, group = ib_G10, inline = "fb",
     tooltip = "Fuel grows as participation rises and is full at this level and above (default 60). A wider bell gives some fuel further below the peak.")
ib_fEmaLen = input.int(233, "Fuel: trend EMA", minval = 2, maxval = 1000, group = ib_G10, inline = "fe")
ib_fBoost  = input.float(0.25, "boost / damp", minval = 0.0, maxval = 0.6, step = 0.05, group = ib_G10, inline = "fe",
     tooltip = "Buying while price is above this EMA, or selling while below it, adds this much fuel (going with the trend). Going against the trend takes the same amount away. 233 is the STRYK: Momentum default.")
ib_cVtUp   = input.color(#26A69A, "Above average", group = ib_G10, inline = "vc")
ib_cVtDn   = input.color(#787B86, "Below average", group = ib_G10, inline = "vc",
     tooltip = "Colours for volume above and below its average, in the table and on the volume flip marks.")
ib_panelBg = input.color(#0C0E12, "Background", group = ib_G10, inline = "pb")
ib_panelT  = input.int(10, "", minval = 0, maxval = 100, group = ib_G10, inline = "pb")
ib_panelTx = input.color(#D1D4DC, "text", group = ib_G10, inline = "pb",
     tooltip = "Table background colour and transparency (0 = solid, 100 = invisible), and the colour of its labels.")

// =============================================================================
// HELPERS
// =============================================================================
// Every alert goes through here so the master switch silences all of them.
ib_alert(string ib_msg) =>
    if mMaster
        alert(ib_msg, alert.freq_once_per_bar_close)

ib_style(string ib_s) =>
    ib_s == "Dashed" ? line.style_dashed : ib_s == "Dotted" ? line.style_dotted : line.style_solid

ib_vol(float ib_v) =>
    float ib_a = math.abs(ib_v)
    ib_a >= 1000000 ? str.tostring(ib_v / 1000000.0, "#.##") + "M"
     : ib_a >= 1000 ? str.tostring(ib_v / 1000.0, "#.#") + "K"
     : str.tostring(ib_v, "#")

ib_tfName(string ib_tf) =>
    ib_tf == "D" or ib_tf == "1D" ? "D" : ib_tf == "W" or ib_tf == "1W" ? "W" : ib_tf == "M" or ib_tf == "1M" ? "M"
     : timeframe.in_seconds(ib_tf) >= 3600 and timeframe.in_seconds(ib_tf) % 3600 == 0 ? str.tostring(timeframe.in_seconds(ib_tf) / 3600) + "h"
     : str.tostring(timeframe.in_seconds(ib_tf) / 60) + "m"

ib_grad(float ib_n) =>
    ib_n >= 0 ? color.from_gradient(ib_n, 0, 1, colNeut, colBull) : color.from_gradient(ib_n, -1, 0, colBear, colNeut)

ib_px(float ib_p) =>
    labPrice ? "  " + str.tostring(ib_p, format.mintick) : ""

ib_stampSfx(int ib_t) =>
    string ib_s = f_stamp(ib_t)
    ib_s != "" ? " · " + ib_s : ""

int ib_chartSec = timeframe.in_seconds()
int ib_barMs = ib_chartSec * 1000

// =============================================================================
// INTRABAR DATA — one request, five series, only for the box delta profile.
// Each intrabar's volume is signed by its own direction: up-close = buying.
// =============================================================================
string ib_ltfAuto = ib_chartSec <= 3600 ? "1" : ib_chartSec <= 14400 ? "5" : ib_chartSec <= 86400 ? "30" : "240"
string ib_ltfStr = ib_ltfMode == "1 second" ? "1S" : ib_ltfMode == "5 seconds" ? "5S"
     : ib_ltfMode == "15 seconds" ? "15S" : ib_ltfMode == "30 seconds" ? "30S"
     : ib_ltfMode == "1 minute" ? "1" : ib_ltfMode == "5 minutes" ? "5" : ib_ltfAuto
// Memory saver asks for the chart's own timeframe, so there is no intrabar fetch.
string ib_ltfReq = memSaver or timeframe.in_seconds(ib_ltfStr) >= ib_chartSec ? timeframe.period : ib_ltfStr
[ib_lC, ib_lH, ib_lL, ib_lV, ib_lS] = request.security_lower_tf(syminfo.tickerid, ib_ltfReq,
     [ib_pxSrc == "HLC3" ? hlc3 : ib_pxSrc == "OHLC4" ? ohlc4 : close, high, low, volume,
     close > open ? volume : close < open ? -volume : 0.0])
bool ib_haveLtf = not memSaver and not na(ib_lC) and not na(ib_lH) and not na(ib_lL) and not na(ib_lV) and not na(ib_lS)
     and array.size(ib_lC) > 0
     and array.size(ib_lH) == array.size(ib_lC)
     and array.size(ib_lL) == array.size(ib_lC)
     and array.size(ib_lV) == array.size(ib_lC)
     and array.size(ib_lS) == array.size(ib_lC)
bool  ib_spread = ib_pxSrc == "Spread across bar range"
float ib_binPx = syminfo.mintick * ib_binTk
ib_bin(float ib_p) =>
    na(ib_p) or ib_binPx <= 0 ? na : math.round(ib_p / ib_binPx) * ib_binPx

// POC / value area of a price-bin map (unchanged from OP).
ib_analyseMap(map<float, float> ib_m, map<float, float> ib_bm) =>
    float ib_poc = na
    float ib_pocV = 0.0
    float ib_tot = 0.0
    float ib_buy = 0.0
    float ib_vah = na
    float ib_val = na
    if map.size(ib_m) > 0
        array<float> ib_occ = map.keys(ib_m)
        array.sort(ib_occ, order.ascending)
        float ib_firstK = array.get(ib_occ, 0)
        float ib_lastK = array.get(ib_occ, array.size(ib_occ) - 1)
        int ib_n = int(math.round((ib_lastK - ib_firstK) / ib_binPx)) + 1
        array<float> ib_ks = array.new<float>(ib_n, na)
        array<float> ib_vs = array.new<float>(ib_n, 0.0)
        int ib_pi = 0
        for ib_i = 0 to ib_n - 1
            float ib_k = math.round(ib_firstK / ib_binPx + ib_i) * ib_binPx
            float ib_v = nz(map.get(ib_m, ib_k))
            array.set(ib_ks, ib_i, ib_k)
            array.set(ib_vs, ib_i, ib_v)
            ib_tot += ib_v
            ib_buy += nz(map.get(ib_bm, ib_k))
            if ib_v > ib_pocV
                ib_pocV := ib_v
                ib_poc := ib_k
                ib_pi := ib_i
        float ib_target = ib_tot * ib_vaPct / 100.0
        float ib_acc = ib_pocV
        int ib_aLo = ib_pi
        int ib_aHi = ib_pi
        while ib_acc < ib_target and (ib_aLo > 0 or ib_aHi < ib_n - 1)
            float ib_below = ib_aLo > 0 ? array.get(ib_vs, ib_aLo - 1) : -1.0
            float ib_above = ib_aHi < ib_n - 1 ? array.get(ib_vs, ib_aHi + 1) : -1.0
            if ib_above >= ib_below
                ib_aHi += 1
                ib_acc += ib_above
            else
                ib_aLo -= 1
                ib_acc += ib_below
        ib_vah := array.get(ib_ks, ib_aHi) + ib_binPx / 2
        ib_val := array.get(ib_ks, ib_aLo) - ib_binPx / 2
    [ib_poc, ib_pocV, ib_tot, ib_buy, ib_vah, ib_val]

// =============================================================================
// VOLUME ENGINES — HTF delta, average volume, participation, Fuel × Δ
// Per-bar delta comes from the core (barDelta: footprint or LTF estimate).
// =============================================================================
float ib_bd = nz(barDelta)

// Higher-timeframe delta: closed candles are committed once, the live candle is
// added on top for display. Returns [live delta, live volume, average |delta|].
ib_htfD(simple string ib_tf, int ib_n) =>
    string ib_tfE = timeframe.in_seconds(ib_tf) <= ib_chartSec ? timeframe.period : ib_tf
    bool ib_roll = timeframe.change(ib_tfE)
    var float ib_d = 0.0
    var float ib_v = 0.0
    var array<float> ib_hist = array.new<float>()
    if ib_roll
        if ib_v > 0
            ib_hist.push(ib_d)
            while ib_hist.size() > ib_n
                ib_hist.shift()
        ib_d := 0.0
        ib_v := 0.0
    if barstate.isconfirmed and not na(barDelta)
        ib_d += barDelta
        ib_v += nz(volume)
    float ib_liveD = ib_d + (barstate.isconfirmed ? 0.0 : ib_bd)
    float ib_liveV = ib_v + (barstate.isconfirmed ? 0.0 : nz(volume))
    float ib_avgAbs = 0.0
    if ib_hist.size() > 0
        for ib_x in ib_hist
            ib_avgAbs += math.abs(nz(ib_x))
        ib_avgAbs /= ib_hist.size()
    [ib_liveD, ib_liveV, ib_avgAbs]

[ib_h1D, ib_h1V, ib_h1A] = ib_htfD(ib_h1Tf, ib_htfN)
[ib_h2D, ib_h2V, ib_h2A] = ib_htfD(ib_h2Tf, ib_htfN)
[ib_h3D, ib_h3V, ib_h3A] = ib_htfD(ib_h3Tf, ib_htfN)
[ib_h4D, ib_h4V, ib_h4A] = ib_htfD(ib_h4Tf, ib_htfN)

float ib_volSma = ta.sma(nz(volume), ib_avgLen)
float ib_volEma = ta.ema(nz(volume), ib_avgLen)
float ib_barAvg = ib_avgTyp == "EMA" ? ib_volEma : ib_volSma
// Time-of-day baseline: one small history per minute of the day (exchange
// timezone). Prior days only, so the live candle never counts itself.
type ib_TodSlot
    array<float> vals
var map<int, ib_TodSlot> ib_todMap = map.new<int, ib_TodSlot>()
int   ib_todKey = hour(time, TZ) * 60 + minute(time, TZ)
float ib_todAvg = na
if ib_volBase == "Same time of day"
    ib_TodSlot ib_sl = map.get(ib_todMap, ib_todKey)
    if not na(ib_sl) and ib_sl.vals.size() >= 3
        ib_todAvg := ib_sl.vals.avg()
    if barstate.isconfirmed and not na(volume)
        if na(ib_sl)
            ib_sl := ib_TodSlot.new(array.new<float>())
            map.put(ib_todMap, ib_todKey, ib_sl)
        ib_sl.vals.push(volume)
        while ib_sl.vals.size() > ib_todDays
            ib_sl.vals.shift()
float ib_vtAvg = nz(ib_todAvg, ib_barAvg)
bool  ib_vtAbove = nz(volume) > nz(ib_vtAvg)
var bool ib_vtState = false
var int  ib_vtFlipT = na
var int  ib_vtFlipDir = 0
bool ib_vtFlip = false
if barstate.isconfirmed and not na(ib_vtAvg)
    if ib_vtAbove != ib_vtState
        ib_vtFlip := true
        ib_vtFlipDir := ib_vtAbove ? 1 : -1
        ib_vtFlipT := time
    ib_vtState := ib_vtAbove
float  ib_pVolEma = ta.ema(nz(volume), ib_pEmaLen)
float  ib_prankEma = ta.percentrank(ib_pVolEma, ib_pLook)
float  ib_prankBar = ta.percentrank(nz(volume), ib_pLook)
float  ib_part = ib_pFast ? math.max(nz(ib_prankEma, 50.0), nz(ib_prankBar, 50.0)) : nz(ib_prankEma, 50.0)
string ib_partTxt = ib_part >= ib_pClimax ? "CLIMAX" : ib_part >= 70 ? "HEAVY" : ib_part >= 40 ? "AVERAGE" : ib_part >= 20 ? "THIN" : "DEAD"
color  ib_partCol = ib_part >= 50 ? color.from_gradient(ib_part, 50, 100, #FFD700, #00BCD4) : color.from_gradient(ib_part, 0, 50, #9C27B0, #FFD700)
float  ib_fEma = ta.ema(close, ib_fEmaLen)
float  ib_bell = ib_part >= ib_bellPk ? 1.0 : math.exp(-math.pow(ib_part - ib_bellPk, 2) / (2.0 * ib_bellW * ib_bellW))
bool   ib_fAlign = (ib_bd > 0 and close > ib_fEma) or (ib_bd < 0 and close < ib_fEma)
float  ib_fuelVal = math.max(0.0, math.min(1.0, ib_bell * (ib_fAlign ? 1.0 + ib_fBoost : 1.0 - ib_fBoost)))
int    ib_fuelDir = ib_bd > 0 ? 1 : ib_bd < 0 ? -1 : 0

// =============================================================================
// CASH OPEN BOX (IB) ENGINE — one box per day on its own clock
// =============================================================================
bool ib_drawOn = showAll and ib_on
bool ib_inWin = not na(time(timeframe.period, ib_winIn, TZ))
bool ib_start = ib_inWin and not ib_inWin[1]
bool ib_end   = not ib_inWin and ib_inWin[1]
// the window's own volume / delta per price bin (filled below)
var map<float, float> ib_vm = map.new<float, float>()
var map<float, float> ib_dm = map.new<float, float>()
var float ib_volT = 0.0
var float ib_delT = 0.0
var array<float> ib_hPoc = array.new<float>()
var array<float> ib_xH = array.new<float>()    // highest high since each completed box closed
var array<float> ib_xL = array.new<float>()    // lowest low since
var array<float> ib_hVah = array.new<float>()
var array<float> ib_hVal = array.new<float>()
var float ib_hi = na
var float ib_lo = na
var int   ib_t0 = na
var int   ib_t1 = na
var bool  ib_done = false
var float ib_bo = na      // price at the window open
var float ib_bc = na      // last close inside the window
var bool  ib_up = false
var bool  ib_dn = false
var float ib_maxUp = 0.0
var float ib_maxDn = 0.0
var array<float> ib_hH = array.new<float>()     // completed boxes, newest first
var array<float> ib_hL = array.new<float>()
var array<int>   ib_hT0 = array.new<int>()
var array<int>   ib_hT1 = array.new<int>()
var array<int>   ib_tz = array.new<int>()       // when a later day first traded inside (na = untested)
// start of the current trading day (17:00 CT on CME), to tell today's box from yesterday's
var int ib_tdStart = na
bool ib_chD = timeframe.change("D")
if ib_chD
    ib_tdStart := time
bool ib_doneEv = false
bool ib_brkUpEv = false
bool ib_brkDnEv = false
int  ib_extHit = 0
if ib_start
    ib_hi := high
    ib_lo := low
    ib_bo := open
    ib_bc := close
    ib_t0 := time
    ib_t1 := na
    ib_done := false
    ib_up := false
    ib_dn := false
    ib_maxUp := 0.0
    ib_maxDn := 0.0
else if ib_inWin and not na(ib_t0) and not ib_done
    ib_hi := math.max(ib_hi, high)
    ib_lo := math.min(ib_lo, low)
    ib_bc := close
if ib_end and not na(ib_t0) and not ib_done
    ib_done := true
    ib_doneEv := true
    ib_t1 := time
    ib_hH.unshift(ib_hi)
    ib_hL.unshift(ib_lo)
    ib_hT0.unshift(ib_t0)
    ib_hT1.unshift(ib_t1)
    ib_tz.unshift(na)
    [ib_bp0, ib_bp1, ib_bp2, ib_bp3, ib_bp4, ib_bp5] = ib_analyseMap(ib_vm, ib_dm)
    ib_hPoc.unshift(ib_bp0)
    ib_xH.unshift(high)
    ib_xL.unshift(low)
    ib_hVah.unshift(ib_bp4)
    ib_hVal.unshift(ib_bp5)
    if ib_hH.size() > 200
        ib_hH.pop()
        ib_hL.pop()
        ib_hT0.pop()
        ib_hT1.pop()
        ib_tz.pop()
        ib_hPoc.pop()
        ib_xH.pop()
        ib_xL.pop()
        ib_hVah.pop()
        ib_hVal.pop()
// running extremes since each completed box closed (for the anchor box targets)
f_blk44() =>
    if ib_xH.size() > 0
        for ib_i = 0 to ib_xH.size() - 1
            if high > ib_xH.get(ib_i)
                ib_xH.set(ib_i, high)
            if low < ib_xL.get(ib_i)
                ib_xL.set(ib_i, low)
    // a box counts as tested once a later day trades anywhere inside it
    true
f_blk44()
f_blk45() =>
    if barstate.isconfirmed and ib_hH.size() > 0 and not na(ib_t0)
        for ib_i = 0 to ib_hH.size() - 1
            if ib_hT0.get(ib_i) < ib_t0
                if na(ib_tz.get(ib_i)) and high >= ib_hL.get(ib_i) and low <= ib_hH.get(ib_i)
                    ib_tz.set(ib_i, time)
    // range extension on today's box: trade beyond it after it is set
    true
f_blk45()
if ib_done and not na(ib_hi) and ib_hi > ib_lo
    float ib_R = ib_hi - ib_lo
    if high > ib_hi
        if not ib_up
            ib_brkUpEv := true
        ib_up := true
        float ib_xu = (high - ib_hi) / ib_R
        if math.floor(ib_xu * 2) > math.floor(ib_maxUp * 2) and ib_xu >= 0.5
            ib_extHit := 1
        ib_maxUp := math.max(ib_maxUp, ib_xu)
    if low < ib_lo
        if not ib_dn
            ib_brkDnEv := true
        ib_dn := true
        float ib_xd = (ib_lo - low) / ib_R
        if math.floor(ib_xd * 2) > math.floor(ib_maxDn * 2) and ib_xd >= 0.5
            ib_extHit := -1
        ib_maxDn := math.max(ib_maxDn, ib_xd)

// =============================================================================
// OPEN BOX DELTA PROFILE — volume and signed volume per price bin inside the
// opening window, from closed candles. Reset at each window open.
// Without intrabar data (memory saver) each candle counts as one block at HLC3.
// =============================================================================
if ib_start
    map.clear(ib_vm)
    map.clear(ib_dm)
    ib_volT := 0.0
    ib_delT := 0.0
if mMaster and ib_inWin and barstate.isconfirmed
    if ib_haveLtf
        for ib_i = 0 to array.size(ib_lC) - 1
            float ib_v = array.get(ib_lV, ib_i)
            float ib_sg = array.get(ib_lS, ib_i)
            if ib_v > 0
                ib_volT += ib_v
                ib_delT += ib_sg
                if ib_spread
                    float ib_k0 = ib_bin(array.get(ib_lL, ib_i))
                    float ib_k1 = ib_bin(array.get(ib_lH, ib_i))
                    if not na(ib_k0) and not na(ib_k1)
                        int ib_nb = math.max(1, math.min(400, int(math.round((ib_k1 - ib_k0) / ib_binPx)) + 1))
                        for ib_j = 0 to ib_nb - 1
                            float ib_k = math.round(ib_k0 / ib_binPx + ib_j) * ib_binPx
                            map.put(ib_vm, ib_k, nz(map.get(ib_vm, ib_k)) + ib_v / ib_nb)
                            map.put(ib_dm, ib_k, nz(map.get(ib_dm, ib_k)) + ib_sg / ib_nb)
                else
                    float ib_k = ib_bin(array.get(ib_lC, ib_i))
                    if not na(ib_k)
                        map.put(ib_vm, ib_k, nz(map.get(ib_vm, ib_k)) + ib_v)
                        map.put(ib_dm, ib_k, nz(map.get(ib_dm, ib_k)) + ib_sg)
    else if nz(volume) > 0
        float ib_k = ib_bin(hlc3)
        ib_volT += volume
        ib_delT += ib_bd
        if not na(ib_k)
            map.put(ib_vm, ib_k, nz(map.get(ib_vm, ib_k)) + volume)
            map.put(ib_dm, ib_k, nz(map.get(ib_dm, ib_k)) + ib_bd)

// =============================================================================
// BOX DRAWING — everything is rebuilt on drawNow from the module's own arrays.
// =============================================================================
var array<line>  ib_lns = array.new<line>()
var array<label> ib_lbs = array.new<label>()
var array<box>   ib_bxs = array.new<box>()

// One line, only while under the user's line cap.
ib_addLn(int ib_ax1, float ib_ay1, int ib_ax2, float ib_ay2, color ib_c, int ib_w, string ib_st) =>
    if ib_lns.size() < ib_maxLn
        ib_lns.push(line.new(ib_ax1, ib_ay1, ib_ax2, ib_ay2, xloc = xloc.bar_time, color = ib_c, width = ib_w, style = ib_style(ib_st)))

// Extension targets for one box: start at the box's right edge, run to the chart
// edge, revealed one at a time per side from how far price has gone (ib_mxU /
// ib_mxD in multiples of the box height). Labels go to the core's right-edge stack.
ib_extSet(int ib_tA, float ib_h, float ib_l, float ib_mxU, float ib_mxD, string ib_pfx, color ib_cu0, color ib_cd0, bool ib_lab) =>
    float ib_r = ib_h - ib_l
    int ib_xe = time + labOff * ib_barMs
    array<float> ib_ks = array.from(0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0, 5.5, 6.0, 6.5, 7.0, 7.5, 8.0, 8.5, 9.0, 9.5, 10.0)
    array<bool>  ib_xon = array.from(ib_x05, ib_x1, ib_x15, ib_x2, ib_x25, ib_x3, ib_x35, ib_x4, ib_x45, ib_x5, ib_x55, ib_x6, ib_x65, ib_x7, ib_x75, ib_x8, ib_x85, ib_x9, ib_x95, ib_x10)
    bool ib_nextU = false
    bool ib_nextD = false
    for ib_i = 0 to 19
        if ib_xon.get(ib_i)
            float ib_k = ib_ks.get(ib_i)
            string ib_kt = str.tostring(ib_k) + "×"
            float ib_yu = ib_h + ib_k * ib_r
            float ib_yd = ib_l - ib_k * ib_r
            bool ib_hitU = ib_mxU >= ib_k
            bool ib_hitD = ib_mxD >= ib_k
            bool ib_showU = not ib_extProg or ib_hitU or not ib_nextU
            bool ib_showD = not ib_extProg or ib_hitD or not ib_nextD
            if not ib_hitU
                ib_nextU := true
            if not ib_hitD
                ib_nextD := true
            color ib_cu = ib_extProg and ib_hitU ? ib_cHit : ib_cu0
            color ib_cd = ib_extProg and ib_hitD ? ib_cHit : ib_cd0
            if ib_showU
                ib_addLn(ib_tA, ib_yu, ib_xe, ib_yu, ib_cu, ib_wExt, ib_sExt)
                if ib_lab
                    f_rq(ib_yu, ib_pfx + " +" + ib_kt + (ib_extProg and ib_hitU ? " ✓" : ""), ib_cu)
            if ib_showD
                ib_addLn(ib_tA, ib_yd, ib_xe, ib_yd, ib_cd, ib_wExt, ib_sExt)
                if ib_lab
                    f_rq(ib_yd, ib_pfx + " −" + ib_kt + (ib_extProg and ib_hitD ? " ✓" : ""), ib_cd)

f_blk46() =>
    if drawNow
        for ib_o in ib_lns
            line.delete(ib_o)
        for ib_o in ib_lbs
            label.delete(ib_o)
        for ib_o in ib_bxs
            box.delete(ib_o)
        ib_lns.clear()
        ib_lbs.clear()
        ib_bxs.clear()
        if ib_drawOn
            bool ib_labAll = ib_labMode == "Every box"
            bool ib_labLast = ib_labMode != "None"
            bool ib_formNow = not na(ib_t0) and not ib_done
            int  ib_keepDone = ib_formNow ? ib_days - 1 : ib_days
            int  ib_xEdge = time + labOff * ib_barMs
            // the VWAP anchor box: the oldest box starting at or after the core's anchor start
            int ib_anc = na
            if not na(anStartTime)
                if ib_formNow and ib_t0 >= anStartTime
                    ib_anc := -1
                if ib_hT0.size() > 0
                    for ib_i = 0 to ib_hT0.size() - 1
                        if ib_hT0.get(ib_i) >= anStartTime
                            ib_anc := ib_i
            bool ib_ancDone = not na(ib_anc) and ib_anc >= 0
            // targets first, so the line cap never cuts them
            // today's targets once its box is complete; while the next box is still
            // forming (08:30-09:30) the previous box keeps its targets on the chart,
            // and they are replaced only when the new box closes at 09:30
            bool ib_tLab = labOn and ib_xLab
            bool ib_prevTg = not ib_done and ib_hH.size() > 0
            if ib_extOn and ib_done and ib_hi > ib_lo
                ib_extSet(ib_t1, ib_hi, ib_lo, ib_maxUp, ib_maxDn, "IB", ib_cUp, ib_cDn, ib_tLab)
            else if ib_extOn and ib_prevTg and ib_hH.get(0) > ib_hL.get(0)
                float ib_ph = ib_hH.get(0)
                float ib_pl = ib_hL.get(0)
                float ib_pr = ib_ph - ib_pl
                ib_extSet(ib_hT1.get(0), ib_ph, ib_pl, math.max(0.0, (ib_xH.get(0) - ib_ph) / ib_pr), math.max(0.0, (ib_pl - ib_xL.get(0)) / ib_pr), "IB", ib_cUp, ib_cDn, ib_tLab)
            // second set from the VWAP anchor box (skipped when it is the box already targeted above)
            if ib_extOn and ib_ancTgt and ib_ancDone and ib_anc < ib_hH.size()
                if ib_hT0.get(ib_anc) != ib_t0 and not (ib_prevTg and ib_anc == 0)
                    float ib_ah = ib_hH.get(ib_anc)
                    float ib_al = ib_hL.get(ib_anc)
                    if ib_ah > ib_al
                        float ib_ar = ib_ah - ib_al
                        float ib_aU = math.max(0.0, (ib_xH.get(ib_anc) - ib_ah) / ib_ar)
                        float ib_aD = math.max(0.0, (ib_al - ib_xL.get(ib_anc)) / ib_ar)
                        ib_extSet(ib_hT1.get(ib_anc), ib_ah, ib_al, ib_aU, ib_aD, "Anchor IB" + ib_stampSfx(ib_hT0.get(ib_anc)), ib_cAncUp, ib_cAncDn, ib_tLab)
            // candidates: -1 = the box forming now, 0.. = completed (newest first)
            array<int>   ib_cIdx = array.new<int>()
            array<float> ib_cDist = array.new<float>()
            int ib_cap = ib_maxBox - (ib_ancDone ? 1 : 0)
            if ib_formNow
                ib_cIdx.push(-1)
                ib_cDist.push(close > ib_hi ? close - ib_hi : close < ib_lo ? ib_lo - close : 0.0)
            if ib_hH.size() > 0
                for ib_i = 0 to ib_hH.size() - 1
                    bool ib_unt = ib_extUnt and na(ib_tz.get(ib_i))
                    bool ib_isAncI = ib_ancDone and ib_i == ib_anc
                    if ib_isAncI or ((ib_i < ib_keepDone or ib_unt) and ib_cIdx.size() < ib_cap)
                        float ib_h = ib_hH.get(ib_i)
                        float ib_l = ib_hL.get(ib_i)
                        ib_cIdx.push(ib_i)
                        ib_cDist.push(close > ib_h ? close - ib_h : close < ib_l ? ib_l - close : 0.0)
            int ib_nC = ib_cIdx.size()
            int ib_rqN = 0      // box IBH / IBL labels sent to the right-edge stack
            if ib_nC > 0
                for ib_j = 0 to ib_nC - 1
                    int ib_rank = 0
                    for ib_q = 0 to ib_nC - 1
                        if ib_q != ib_j and (ib_cDist.get(ib_q) < ib_cDist.get(ib_j) or (ib_cDist.get(ib_q) == ib_cDist.get(ib_j) and ib_q < ib_j))
                            ib_rank += 1
                    int   ib_fadeT = ib_fadeOn and ib_nC > 1 ? int(math.round(ib_fade * ib_rank / (ib_nC - 1))) : 0
                    color ib_lc = color.new(ib_cOut, math.min(100, color.t(ib_cOut) + ib_fadeT))
                    color ib_fc = color.new(ib_cFill, math.min(100, color.t(ib_cFill) + ib_fadeT))
                    color ib_mc = color.new(ib_cMid, math.min(100, color.t(ib_cMid) + ib_fadeT))
                    int   ib_i = ib_cIdx.get(ib_j)
                    bool  ib_forming = ib_i < 0
                    int   ib_t0i = ib_forming ? ib_t0 : ib_hT0.get(ib_i)
                    float ib_h = ib_forming ? ib_hi : ib_hH.get(ib_i)
                    float ib_l = ib_forming ? ib_lo : ib_hL.get(ib_i)
                    bool  ib_todayDone = not ib_formNow and ib_done and not na(ib_tdStart) and ib_t0 >= ib_tdStart
                    bool  ib_isToday = not ib_forming and ib_i == 0 and ib_todayDone
                    bool  ib_isPrev = not ib_forming and ib_i == (ib_todayDone ? 1 : 0)
                    bool  ib_isLatest = ib_forming or (ib_i == 0 and not ib_formNow)
                    int   ib_xEnd = ib_forming ? time : ib_hT1.get(ib_i)
                    int   ib_xR = not ib_forming and (ib_extAll or (ib_isPrev and ib_extPrev)) ? ib_xEdge : ib_xEnd
                    if ib_extUnt and not ib_forming
                        ib_xR := na(ib_tz.get(ib_i)) ? ib_xEdge : math.max(ib_xR, ib_tz.get(ib_i))
                    ib_bxs.push(box.new(ib_t0i, ib_h, ib_xR, ib_l, xloc = xloc.bar_time, bgcolor = ib_fc, border_color = ib_lc,
                         border_width = ib_wOut, border_style = ib_style(ib_sOut)))
                    bool ib_isAnc = not na(ib_anc) and ib_i == ib_anc
                    // extend switches: anchor box and latest box each have their own set
                    bool ib_exPoc = (ib_isAnc and ib_xAncPoc) or (ib_isLatest and ib_xLatPoc)
                    bool ib_exMid = (ib_isAnc and ib_xAncMid) or (ib_isLatest and ib_xLatMid)
                    bool ib_exVA  = (ib_isAnc and ib_xAncVA) or (ib_isLatest and ib_xLatVA)
                    bool ib_exHL  = (ib_isAnc and ib_xAncHL) or (ib_isLatest and ib_xLatHL)
                    string ib_stp = ib_isToday or ib_forming ? "" : ib_stampSfx(ib_t0i)
                    string ib_bTag = (ib_isAnc and not ib_isLatest ? "Anchor box" : "Box") + ib_stp
                    if ib_midOn
                        float ib_m = (ib_h + ib_l) / 2
                        ib_addLn(ib_t0i, ib_m, ib_exMid ? ib_xEdge : ib_xR, ib_m, ib_mc, ib_wMid, ib_sMid)
                        if ib_exMid and ib_midLab and labOn
                            f_rq(ib_m, ib_bTag + " 50%", ib_mc)
                    if ib_exHL
                        ib_addLn(ib_t0i, ib_h, ib_xEdge, ib_h, ib_lc, ib_wHL, ib_sHL)
                        ib_addLn(ib_t0i, ib_l, ib_xEdge, ib_l, ib_lc, ib_wHL, ib_sHL)
                        if ib_hlLab and labOn
                            f_rq(ib_h, ib_bTag + " high", ib_lc)
                            f_rq(ib_l, ib_bTag + " low", ib_lc)
                    if ib_pocOn or ib_vaOn
                        float ib_bPoc = na
                        float ib_bVah = na
                        float ib_bVal = na
                        if ib_forming
                            [ib_q0, ib_q1, ib_q2, ib_q3, ib_q4, ib_q5] = ib_analyseMap(ib_vm, ib_dm)
                            ib_bPoc := ib_q0
                            ib_bVah := ib_q4
                            ib_bVal := ib_q5
                        else if ib_i < ib_hPoc.size()
                            ib_bPoc := ib_hPoc.get(ib_i)
                            ib_bVah := ib_hVah.get(ib_i)
                            ib_bVal := ib_hVal.get(ib_i)
                        color ib_pocC = color.new(ib_cPoc, math.min(100, color.t(ib_cPoc) + ib_fadeT))
                        color ib_vaC = color.new(ib_cVa, math.min(100, color.t(ib_cVa) + ib_fadeT))
                        if ib_pocOn and not na(ib_bPoc)
                            ib_addLn(ib_t0i, ib_bPoc, ib_exPoc ? ib_xEdge : ib_xR, ib_bPoc, ib_pocC, ib_wPoc, ib_sPoc)
                            if ib_exPoc and ib_pocLab and labOn
                                f_rq(ib_bPoc, ib_bTag + " POC", ib_pocC)
                        if ib_vaOn and not na(ib_bVah)
                            ib_addLn(ib_t0i, ib_bVah, ib_exVA ? ib_xEdge : ib_xR, ib_bVah, ib_vaC, ib_wVa, ib_sVa)
                            if ib_exVA and ib_vaLab and labOn
                                f_rq(ib_bVah, ib_bTag + " VAH", ib_vaC)
                        if ib_vaOn and not na(ib_bVal)
                            ib_addLn(ib_t0i, ib_bVal, ib_exVA ? ib_xEdge : ib_xR, ib_bVal, ib_vaC, ib_wVa, ib_sVa)
                            if ib_exVA and ib_vaLab and labOn
                                f_rq(ib_bVal, ib_bTag + " VAL", ib_vaC)
                    bool ib_lab = labOn and (ib_labAll or (ib_isLatest and ib_labLast)) and not (ib_exHL and ib_hlLab)
                    if ib_lab
                        string ib_sfx = ib_forming ? " (forming)" : ib_stp
                        color  ib_tc = color.new(ib_cOut, math.min(100, ib_fadeT))
                        if ib_xR == ib_xEdge
                            if ib_rqN + 2 <= 16
                                f_rq(ib_h, "IBH" + ib_sfx, ib_tc)
                                f_rq(ib_l, "IBL" + ib_sfx, ib_tc)
                                ib_rqN += 2
                        else if ib_lbs.size() + 2 <= ib_maxLab
                            ib_lbs.push(label.new(ib_xR, ib_h, "IBH" + ib_sfx + ib_px(ib_h), xloc = xloc.bar_time,
                                 style = label.style_label_left, color = color.new(ib_lc, 100), textcolor = ib_tc, size = f_sz(ib_labSz)))
                            ib_lbs.push(label.new(ib_xR, ib_l, "IBL" + ib_sfx + ib_px(ib_l), xloc = xloc.bar_time,
                                 style = label.style_label_left, color = color.new(ib_lc, 100), textcolor = ib_tc, size = f_sz(ib_labSz)))

    // =============================================================================
    // MARKS — range extension, extension level reached, volume flips (small labels)
    // =============================================================================
    true
f_blk46()
var array<label> ib_mks = array.new<label>()
ib_mark(bool ib_below, string ib_sty, color ib_c, string ib_t) =>
    bool   ib_useGap = ib_mkGap > 0
    float  ib_py = ib_useGap ? (ib_below ? low - ib_mkGap * syminfo.mintick : high + ib_mkGap * syminfo.mintick) : (ib_below ? low : high)
    string ib_yl = ib_useGap ? yloc.price : ib_below ? yloc.belowbar : yloc.abovebar
    bool   ib_shp = ib_mkSz == "Shape (large)"
    string ib_g = ib_sty == "tri" ? f_glyph("Triangle", ib_below) : ib_sty == "dia" ? "◆" : "●"
    string ib_tx = ib_shp ? "" : ib_g
    string ib_st = ib_shp ? (ib_sty == "tri" ? (ib_below ? label.style_triangleup : label.style_triangledown) : ib_sty == "dia" ? label.style_diamond : label.style_circle) : label.style_none
    ib_mks.push(label.new(bar_index, ib_py, ib_tx, yloc = ib_yl, style = ib_st, color = ib_c, textcolor = ib_c, size = f_mkSz(ib_mkSz)))
    while ib_mks.size() > ib_mkMax
        label.delete(ib_mks.shift())

f_blk47() =>
    if showAll and barstate.isconfirmed
        if ib_on and ib_mkRE and ib_brkUpEv
            ib_mark(true, "tri", ib_cUp, "RE")
        if ib_on and ib_mkRE and ib_brkDnEv
            ib_mark(false, "tri", ib_cDn, "RE")
        if ib_on and ib_mkX and ib_extHit > 0
            ib_mark(false, "dia", ib_cUp, "X")
        if ib_on and ib_mkX and ib_extHit < 0
            ib_mark(true, "dia", ib_cDn, "X")

    // =============================================================================
    // ALERTS — on closed candles only, silenced by mMaster through ib_alert()
    // =============================================================================
    true
f_blk47()
f_blk48() =>
    if barstate.isconfirmed and ib_on
        if ib_alDone and ib_doneEv
            ib_alert("STRYK:MRV " + syminfo.ticker + " — opening box set: " + str.tostring(ib_lo, format.mintick) + " – " + str.tostring(ib_hi, format.mintick))
        if ib_alBreak and ib_brkUpEv
            ib_alert("STRYK:MRV " + syminfo.ticker + " — range extension UP: traded above the box high " + str.tostring(ib_hi, format.mintick))
        if ib_alBreak and ib_brkDnEv
            ib_alert("STRYK:MRV " + syminfo.ticker + " — range extension DOWN: traded below the box low " + str.tostring(ib_lo, format.mintick))
        if ib_alExt and ib_extHit != 0
            ib_alert("STRYK:MRV " + syminfo.ticker + " — reached an opening-box " + (ib_extHit > 0 ? "up" : "down") + " extension level")
    true
f_blk48()
f_blk49() =>
    // =============================================================================
    // LIVE INFO TABLE
    // =============================================================================
    // When the core's last signal text changes, remember the time (for 'bars ago').
    true
f_blk49()
var string ib_sigPrev = ""
var int    ib_sigT = na
if lastSigTxt != ib_sigPrev
    ib_sigPrev := lastSigTxt
    ib_sigT := lastSigTxt != "" ? time : na

ib_htfCell(float ib_d, float ib_v, float ib_a) =>
    float ib_pct = ib_v > 0 ? ib_d / ib_v * 100 : 0.0
    float ib_n = ib_a > 0 ? math.max(-1.0, math.min(1.0, ib_d / (ib_a * 1.5))) : 0.0
    color ib_c = ib_grad(ib_n)
    [ib_pct, ib_c]

string ib_hName1 = ib_tfName(ib_h1Tf)
string ib_hName2 = ib_tfName(ib_h2Tf)
string ib_hName3 = ib_tfName(ib_h3Tf)
string ib_hName4 = ib_tfName(ib_h4Tf)
var table ib_vt = table.new(position.bottom_right, 12, 40, border_width = 1)
// grid layout: table row r goes to column group (r mod columns), table row (r div columns)
int ib_colsEff = isMob or ib_vtLay == "Mobile (compact)" ? ib_cols : 1
ib_gc(int r) => 3 * (r % ib_colsEff)
ib_gr(int r) => int(r / ib_colsEff)
f_blk50() =>
    if barstate.islast
        table.clear(ib_vt, 0, 0, 11, 39)
        table.set_position(ib_vt, f_pos(tblPosLive))
        table.set_bgcolor(ib_vt, color.new(ib_panelBg, ib_panelT))
        if showAll and (tblMode == "Live info" or tblMode == "Both")
            bool   ib_mob = isMob or ib_vtLay == "Mobile (compact)"
            string ib_tsz = ib_mob ? f_sz(ib_vtSzM) : f_sz(ib_vtSz)
            int    ib_r = 0
            bool   ib_vAll = ib_vtView == "Everything"
            bool   ib_vVol = ib_vAll or ib_vtView == "Volume & flow"
            bool   ib_vHtf = ib_vAll or ib_vtView == "Higher-timeframe delta"
            bool   ib_vIb  = ib_vAll or ib_vtView == "Open box delta profile"
            bool   ib_vVw  = ib_vAll or ib_vtView == "VWAP & signals"
            color  ib_tx2 = color.new(ib_panelTx, 30)
            if not ib_mob
                table.cell(ib_vt, ib_gc(ib_r), ib_gr(ib_r), "STRYK:MRV", text_color = ib_panelTx, text_size = ib_tsz, text_halign = text.align_left)
                table.cell(ib_vt, ib_gc(ib_r) + 1, ib_gr(ib_r), syminfo.ticker, text_color = ib_tx2, text_size = ib_tsz)
                table.cell(ib_vt, ib_gc(ib_r) + 2, ib_gr(ib_r), ib_vAll ? "" : ib_vtView, text_color = ib_tx2, text_size = ib_tsz, text_halign = text.align_left)
                ib_r += 1
            if ib_rowVol and ib_vVol
                float ib_pctNow = ib_vtAvg > 0 ? volume / ib_vtAvg * 100 : na
                color ib_cNow = ib_vtAbove ? ib_cVtUp : ib_cVtDn
                string ib_pctTx = na(ib_pctNow) ? "–" : str.tostring(ib_pctNow, "#") + "%"
                table.cell(ib_vt, ib_gc(ib_r), ib_gr(ib_r), ib_mob ? "Vol" : "Volume", text_color = ib_panelTx, text_size = ib_tsz, text_halign = text.align_left)
                table.cell(ib_vt, ib_gc(ib_r) + 1, ib_gr(ib_r), ib_vol(volume) + (ib_mob ? " " + ib_pctTx : ""), text_color = ib_cNow, text_size = ib_tsz)
                if not ib_mob
                    table.cell(ib_vt, ib_gc(ib_r) + 2, ib_gr(ib_r), ib_pctTx + " of normal " + ib_vol(ib_vtAvg), text_color = ib_cNow, text_size = ib_tsz, text_halign = text.align_left)
                ib_r += 1
            if ib_rowAvg and ib_vVol
                int    ib_agoFlip = na(ib_vtFlipT) ? na : int(math.round((time - ib_vtFlipT) / ib_barMs))
                string ib_fl = na(ib_agoFlip) ? "" : ib_agoFlip <= 0 ? "just flipped " + (ib_vtFlipDir > 0 ? "▲" : "▼") : "flipped " + str.tostring(ib_agoFlip) + " bars ago"
                table.cell(ib_vt, ib_gc(ib_r), ib_gr(ib_r), ib_mob ? "Avg" : "vs average", text_color = ib_panelTx, text_size = ib_tsz, text_halign = text.align_left)
                table.cell(ib_vt, ib_gc(ib_r) + 1, ib_gr(ib_r), ib_mob ? (ib_vtState ? "▲ above" : "▼ below") : ib_vtState ? "ABOVE" : "BELOW", text_color = ib_vtState ? ib_cVtUp : ib_cVtDn, text_size = ib_tsz)
                if not ib_mob
                    table.cell(ib_vt, ib_gc(ib_r) + 2, ib_gr(ib_r), ib_fl, text_color = ib_tx2, text_size = ib_tsz, text_halign = text.align_left)
                ib_r += 1
            if ib_rowPart and ib_vVol
                table.cell(ib_vt, ib_gc(ib_r), ib_gr(ib_r), ib_mob ? "Part" : "Participation", text_color = ib_panelTx, text_size = ib_tsz, text_halign = text.align_left)
                table.cell(ib_vt, ib_gc(ib_r) + 1, ib_gr(ib_r), ib_mob ? str.tostring(ib_part, "#") + " " + ib_partTxt : str.tostring(ib_part, "#"), text_color = ib_partCol, text_size = ib_tsz)
                if not ib_mob
                    table.cell(ib_vt, ib_gc(ib_r) + 2, ib_gr(ib_r), ib_partTxt, text_color = ib_partCol, text_size = ib_tsz, text_halign = text.align_left)
                ib_r += 1
            if ib_rowFuel and ib_vVol
                bool   ib_paid = ib_fuelVal >= 0.5 and ib_fuelDir != 0
                color  ib_fcl = not ib_paid ? ib_cVtDn : ib_fuelDir > 0 ? colBull : colBear
                string ib_ft = ib_fuelDir == 0 ? "no delta" : (ib_paid ? "PAID " : "UNPAID ") + (ib_fuelDir > 0 ? "buying" : "selling") + (ib_fAlign ? " · with trend" : " · vs trend")
                string ib_fm = ib_fuelDir == 0 ? "–" : (ib_paid ? "PAID " : "UNPAID ") + (ib_fuelDir > 0 ? "▲" : "▼")
                table.cell(ib_vt, ib_gc(ib_r), ib_gr(ib_r), ib_mob ? "Fuel" : "Fuel × Δ", text_color = ib_panelTx, text_size = ib_tsz, text_halign = text.align_left)
                table.cell(ib_vt, ib_gc(ib_r) + 1, ib_gr(ib_r), ib_mob ? ib_fm : str.tostring(ib_fuelVal * 100, "#") + "%", text_color = ib_fcl, text_size = ib_tsz)
                if not ib_mob
                    table.cell(ib_vt, ib_gc(ib_r) + 2, ib_gr(ib_r), ib_ft, text_color = ib_fcl, text_size = ib_tsz, text_halign = text.align_left)
                ib_r += 1
            array<bool>   ib_hOn = array.from(ib_h1On, ib_h2On, ib_h3On, ib_h4On)
            array<string> ib_hNm = array.from(ib_hName1, ib_hName2, ib_hName3, ib_hName4)
            array<float>  ib_hD  = array.from(ib_h1D, ib_h2D, ib_h3D, ib_h4D)
            array<float>  ib_hVv = array.from(ib_h1V, ib_h2V, ib_h3V, ib_h4V)
            array<float>  ib_hA  = array.from(ib_h1A, ib_h2A, ib_h3A, ib_h4A)
            for ib_q = 0 to 3
                if ib_hOn.get(ib_q) and ib_vHtf
                    float ib_d = ib_hD.get(ib_q)
                    [ib_pct, ib_hc] = ib_htfCell(ib_d, ib_hVv.get(ib_q), ib_hA.get(ib_q))
                    string ib_ar = ib_d > 0 ? "▲" : ib_d < 0 ? "▼" : "•"
                    table.cell(ib_vt, ib_gc(ib_r), ib_gr(ib_r), "Δ " + ib_hNm.get(ib_q), text_color = ib_panelTx, text_size = ib_tsz, text_halign = text.align_left)
                    table.cell(ib_vt, ib_gc(ib_r) + 1, ib_gr(ib_r), (ib_d > 0 ? "+" : "") + ib_vol(ib_d) + (ib_mob ? " " + ib_ar : ""), text_color = ib_hc, text_size = ib_tsz)
                    if not ib_mob
                        table.cell(ib_vt, ib_gc(ib_r) + 2, ib_gr(ib_r), ib_ar + " " + str.tostring(ib_pct, "#") + "% of volume", text_color = ib_hc, text_size = ib_tsz, text_halign = text.align_left)
                    ib_r += 1
            if ib_rowVw and ib_vVw and sOk and not na(sVw)
                float  ib_z = sSd > 0 ? (close - sVw) / sSd : 0.0
                string ib_k1 = str.tostring(b1, "#.##")
                string ib_k2 = str.tostring(b2, "#.##")
                string ib_k3 = str.tostring(b3, "#.##")
                string ib_zone = ib_z >= b3 and b3On ? "above +" + ib_k3 + "σ" : ib_z >= b2 ? "above +" + ib_k2 + "σ" : ib_z >= b1 ? "above +" + ib_k1 + "σ"
                     : ib_z <= -b3 and b3On ? "below −" + ib_k3 + "σ" : ib_z <= -b2 ? "below −" + ib_k2 + "σ" : ib_z <= -b1 ? "below −" + ib_k1 + "σ" : "inside ±" + ib_k1 + "σ"
                color  ib_zc = ib_z >= b1 ? colBull : ib_z <= -b1 ? colBear : colNeut
                table.cell(ib_vt, ib_gc(ib_r), ib_gr(ib_r), "VWAP", text_color = ib_panelTx, text_size = ib_tsz, text_halign = text.align_left)
                table.cell(ib_vt, ib_gc(ib_r) + 1, ib_gr(ib_r), ib_mob ? ib_zone : str.tostring(sVw, format.mintick), text_color = ib_mob ? ib_zc : ib_panelTx, text_size = ib_tsz)
                if not ib_mob
                    table.cell(ib_vt, ib_gc(ib_r) + 2, ib_gr(ib_r), ib_zone + " · " + (ib_z >= 0 ? "+" : "") + str.tostring(ib_z, "#.##") + "σ", text_color = ib_zc, text_size = ib_tsz, text_halign = text.align_left)
                ib_r += 1
            // ---- engine-profile read-out (replaces the side profile on mobile): price vs POC, value area, node, prior VA, naked POC
            if ib_vVw and array.size(vhH) >= 2 and not memSaver
                int nSzT = array.size(vhH)
                int nT = vpCover == "VWAP engine window" ? math.min(nSzT, math.max(2, selN)) : math.min(nSzT, math.max(2, vpN))
                [pLo, pRh, pRv, pRb, pPocR, pVaUp, pVaDn, pMx, pMxD] = f_vpCalc(nSzT - nT, nSzT - 1)
                if pRh > 0 and pMx > 0
                    float pPoc = pLo + (pPocR + 0.5) * pRh
                    float pVahP = pLo + (pVaUp + 1) * pRh
                    float pValP = pLo + pVaDn * pRh
                    float pRng = pRh * vpRows
                    float pPct = (close - pPoc) / pRng * 100
                    int   pRow = math.max(0, math.min(vpRows - 1, int(math.floor((close - pLo) / pRh))))
                    float pRowV = array.get(pRv, pRow)
                    float pRowB = array.get(pRb, pRow)
                    float pRowD = 2 * pRowB - pRowV
                    float pNodePct = pRowV / pMx * 100
                    string pVaTx = close > pVahP ? "above VAH" : close < pValP ? "below VAL" : "in VA"
                    color  pVaC = close > pVahP ? colBull : close < pValP ? colBear : ib_panelTx
                    string pPosTx = (pPct >= 0 ? "+" : "") + str.tostring(pPct, "#") + "% " + (pPct >= 0 ? "▲" : "▼") + " POC"
                    string pNode = pNodePct >= vpHvn ? "HVN" : pNodePct <= 25 ? "LVN" : "mid"
                    color  pNodeC = pNodePct >= vpHvn ? cVpHvn : pNodePct <= 25 ? ib_tx2 : ib_panelTx
                    if ib_rowProf
                        table.cell(ib_vt, ib_gc(ib_r), ib_gr(ib_r), ib_mob ? "Profile" : "Engine profile", text_color = ib_panelTx, text_size = ib_tsz, text_halign = text.align_left)
                        table.cell(ib_vt, ib_gc(ib_r) + 1, ib_gr(ib_r), pPosTx + " · " + pVaTx, text_color = pVaC, text_size = ib_tsz)
                        if not ib_mob
                            table.cell(ib_vt, ib_gc(ib_r) + 2, ib_gr(ib_r), "POC " + str.tostring(pPoc, format.mintick) + " · VAH " + str.tostring(pVahP, format.mintick) + " / VAL " + str.tostring(pValP, format.mintick), text_color = ib_tx2, text_size = ib_tsz, text_halign = text.align_left)
                        ib_r += 1
                    if ib_rowNode
                        table.cell(ib_vt, ib_gc(ib_r), ib_gr(ib_r), "Node", text_color = ib_panelTx, text_size = ib_tsz, text_halign = text.align_left)
                        table.cell(ib_vt, ib_gc(ib_r) + 1, ib_gr(ib_r), pNode + " " + str.tostring(pNodePct, "#") + "% · Δ" + (pRowD >= 0 ? "+" : "−") + f_k(math.abs(pRowD)), text_color = pNodeC, text_size = ib_tsz)
                        if not ib_mob
                            table.cell(ib_vt, ib_gc(ib_r) + 2, ib_gr(ib_r), (pNode == "HVN" ? "high-volume node: price tends to hold / rotate here" : pNode == "LVN" ? "low-volume node: price tends to move through fast" : "normal volume at this price") + " · row " + (pRowD >= 0 ? "net buying" : "net selling"), text_color = ib_tx2, text_size = ib_tsz, text_halign = text.align_left)
                        ib_r += 1
            if ib_vVw and mSessLv
                if ib_rowPva and not na(prevSessVah) and not na(prevSessVal)
                    string pvTx = close > prevSessVah ? "above pVAH" : close < prevSessVal ? "below pVAL" : "in prior VA"
                    color  pvC = close > prevSessVah ? colBull : close < prevSessVal ? colBear : ib_panelTx
                    table.cell(ib_vt, ib_gc(ib_r), ib_gr(ib_r), "pVA", text_color = ib_panelTx, text_size = ib_tsz, text_halign = text.align_left)
                    table.cell(ib_vt, ib_gc(ib_r) + 1, ib_gr(ib_r), pvTx, text_color = pvC, text_size = ib_tsz)
                    if not ib_mob
                        table.cell(ib_vt, ib_gc(ib_r) + 2, ib_gr(ib_r), "pVAH " + str.tostring(prevSessVah, format.mintick) + " / pVAL " + str.tostring(prevSessVal, format.mintick) + (r80Trig and not na(r80Tgt) ? " · 80% rule → " + str.tostring(r80Tgt, format.mintick) : ""), text_color = ib_tx2, text_size = ib_tsz, text_halign = text.align_left)
                    ib_r += 1
                int nkT = array.size(nakedPocs)
                if ib_rowNpoc and nkT > 0
                    float npNear = na
                    for i = 0 to nkT - 1
                        float npv = array.get(nakedPocs, i)
                        if na(npNear) or math.abs(npv - close) < math.abs(npNear - close)
                            npNear := npv
                    float npDist = npNear - close
                    table.cell(ib_vt, ib_gc(ib_r), ib_gr(ib_r), "nPOC", text_color = ib_panelTx, text_size = ib_tsz, text_halign = text.align_left)
                    table.cell(ib_vt, ib_gc(ib_r) + 1, ib_gr(ib_r), str.tostring(npNear, format.mintick) + " " + (npDist >= 0 ? "▲" : "▼") + str.tostring(math.abs(npDist), "#.##"), text_color = cPPoc, text_size = ib_tsz)
                    if not ib_mob
                        table.cell(ib_vt, ib_gc(ib_r) + 2, ib_gr(ib_r), "nearest untested prior-session POC, " + str.tostring(math.abs(npDist), "#.##") + " pts " + (npDist >= 0 ? "above" : "below") + (nkT > 1 ? " · " + str.tostring(nkT) + " open" : ""), text_color = ib_tx2, text_size = ib_tsz, text_halign = text.align_left)
                    ib_r += 1
            if ib_rowIB and ib_vIb and ib_on and not na(ib_hi)
                string ib_bst = close > ib_hi ? "above IBH" : close < ib_lo ? "below IBL" : "inside box"
                color  ib_bsc = close > ib_hi ? ib_cUp : close < ib_lo ? ib_cDn : ib_cOut
                string ib_rg = str.tostring(ib_hi - ib_lo, format.mintick) + " pts" + (ib_done ? "" : " (forming)")
                table.cell(ib_vt, ib_gc(ib_r), ib_gr(ib_r), ib_mob ? "Box" : "Open box", text_color = ib_panelTx, text_size = ib_tsz, text_halign = text.align_left)
                table.cell(ib_vt, ib_gc(ib_r) + 1, ib_gr(ib_r), ib_bst, text_color = ib_bsc, text_size = ib_tsz)
                if not ib_mob
                    table.cell(ib_vt, ib_gc(ib_r) + 2, ib_gr(ib_r), ib_rg, text_color = ib_tx2, text_size = ib_tsz, text_halign = text.align_left)
                ib_r += 1
            if ib_vIb and ib_volT > 0 and (ib_rowIBD or ib_rowBuy or ib_rowPoc or ib_rowRead)
                float ib_bPct = (ib_volT + ib_delT) / 2 / ib_volT * 100
                float ib_dPct = ib_delT / ib_volT * 100
                color ib_dc = ib_delT >= 0 ? colBull : colBear
                // busiest bin and most one-sided bin
                float ib_pocK = na
                float ib_pocV = 0.0
                float ib_imbK = na
                float ib_imbD = 0.0
                array<float> ib_keys = map.keys(ib_vm)
                for ib_k in ib_keys
                    float ib_v = nz(map.get(ib_vm, ib_k))
                    float ib_dd = nz(map.get(ib_dm, ib_k))
                    if ib_v > ib_pocV
                        ib_pocV := ib_v
                        ib_pocK := ib_k
                    if math.abs(ib_dd) > math.abs(ib_imbD)
                        ib_imbD := ib_dd
                        ib_imbK := ib_k
                string ib_wnd = ib_done ? (not na(ib_t0) ? str.format_time(ib_t0, "EEE", TZ) + " window" : "window") : "window (forming)"
                if ib_rowIBD
                    table.cell(ib_vt, ib_gc(ib_r), ib_gr(ib_r), ib_mob ? "Box Δ" : "Box delta", text_color = ib_panelTx, text_size = ib_tsz, text_halign = text.align_left)
                    table.cell(ib_vt, ib_gc(ib_r) + 1, ib_gr(ib_r), (ib_delT > 0 ? "+" : "") + ib_vol(ib_delT) + (ib_mob ? " " + str.tostring(ib_dPct, "#") + "%" : ""), text_color = ib_dc, text_size = ib_tsz)
                    if not ib_mob
                        table.cell(ib_vt, ib_gc(ib_r) + 2, ib_gr(ib_r), str.tostring(ib_dPct, "#") + "% of " + ib_vol(ib_volT) + " · " + ib_wnd, text_color = ib_dc, text_size = ib_tsz, text_halign = text.align_left)
                    ib_r += 1
                if ib_rowBuy
                    table.cell(ib_vt, ib_gc(ib_r), ib_gr(ib_r), ib_mob ? "Buy/Sell" : "Buyers / sellers", text_color = ib_panelTx, text_size = ib_tsz, text_halign = text.align_left)
                    table.cell(ib_vt, ib_gc(ib_r) + 1, ib_gr(ib_r), str.tostring(ib_bPct, "#") + "% / " + str.tostring(100 - ib_bPct, "#") + "%", text_color = ib_dc, text_size = ib_tsz)
                    if not ib_mob
                        table.cell(ib_vt, ib_gc(ib_r) + 2, ib_gr(ib_r), ib_bPct >= 60 ? "buyers in control" : ib_bPct <= 40 ? "sellers in control" : "two-sided", text_color = ib_dc, text_size = ib_tsz, text_halign = text.align_left)
                    ib_r += 1
                if ib_rowPoc and not na(ib_pocK)
                    table.cell(ib_vt, ib_gc(ib_r), ib_gr(ib_r), ib_mob ? "POC/Imb" : "Box POC / imbalance", text_color = ib_panelTx, text_size = ib_tsz, text_halign = text.align_left)
                    table.cell(ib_vt, ib_gc(ib_r) + 1, ib_gr(ib_r), str.tostring(ib_pocK, format.mintick) + (ib_mob ? " · " + str.tostring(ib_imbK, format.mintick) + (ib_imbD >= 0 ? "▲" : "▼") : ""), text_color = ib_cOut, text_size = ib_tsz)
                    if not ib_mob
                        table.cell(ib_vt, ib_gc(ib_r) + 2, ib_gr(ib_r), "imbalance " + str.tostring(ib_imbK, format.mintick) + " " + (ib_imbD >= 0 ? "▲ +" : "▼ ") + ib_vol(ib_imbD), text_color = ib_imbD >= 0 ? colBull : colBear, text_size = ib_tsz, text_halign = text.align_left)
                    ib_r += 1
                // box read: does the box candle agree with its delta? candle = close vs open of the window, delta = box delta %
                if ib_rowRead and not na(ib_bo) and not na(ib_bc) and ib_hi > ib_lo
                    float ib_cMove = (ib_bc - ib_bo) / (ib_hi - ib_lo)
                    int   ib_cDir = ib_cMove >= 0.1 ? 1 : ib_cMove <= -0.1 ? -1 : 0
                    int   ib_dDir = ib_dPct >= 3 ? 1 : ib_dPct <= -3 ? -1 : 0
                    string ib_rd = ib_cDir == 0 and ib_dDir == 0 ? "FLAT" : ib_dDir == 0 ? "no delta" : ib_cDir == 0 ? "one-sided " + (ib_dDir > 0 ? "▲" : "▼") : ib_cDir == ib_dDir ? "AGREE " + (ib_dDir > 0 ? "▲" : "▼") : "ABSORB " + (ib_dDir > 0 ? "▲" : "▼")
                    color  ib_rdc = ib_dDir > 0 ? colBull : ib_dDir < 0 ? colBear : ib_panelTx
                    string ib_rdLong = ib_cDir == ib_dDir and ib_cDir != 0 ? "candle and delta point the same way" : ib_cDir != 0 and ib_dDir != 0 ? (ib_cDir < 0 ? "box closed down but delta is buying: sellers absorbed, lean ▲" : "box closed up but delta is selling: buyers absorbed, lean ▼") : ib_cDir == 0 and ib_dDir != 0 ? "flat candle, one-sided delta: lean with the delta" : "no read"
                    table.cell(ib_vt, ib_gc(ib_r), ib_gr(ib_r), ib_mob ? "Box read" : "Box candle vs delta", text_color = ib_panelTx, text_size = ib_tsz, text_halign = text.align_left)
                    table.cell(ib_vt, ib_gc(ib_r) + 1, ib_gr(ib_r), ib_rd, text_color = ib_rdc, text_size = ib_tsz)
                    if not ib_mob
                        table.cell(ib_vt, ib_gc(ib_r) + 2, ib_gr(ib_r), ib_rdLong, text_color = ib_rdc, text_size = ib_tsz, text_halign = text.align_left)
                    ib_r += 1
            if ib_rowSig and ib_vVw and lastSigTxt != ""
                int   ib_agoS = na(ib_sigT) ? na : int(math.round((time - ib_sigT) / ib_barMs))
                bool  ib_sUp = str.contains(lastSigTxt, "▲") or str.contains(lastSigTxt, "UP")
                bool  ib_sDn = str.contains(lastSigTxt, "▼") or str.contains(lastSigTxt, "DOWN")
                color ib_sc = ib_sUp and not ib_sDn ? colBull : ib_sDn and not ib_sUp ? colBear : ib_panelTx
                table.cell(ib_vt, ib_gc(ib_r), ib_gr(ib_r), ib_mob ? "Sig" : "Last signal", text_color = ib_panelTx, text_size = ib_tsz, text_halign = text.align_left)
                table.cell(ib_vt, ib_gc(ib_r) + 1, ib_gr(ib_r), lastSigTxt, text_color = ib_sc, text_size = ib_tsz)
                if not ib_mob
                    table.cell(ib_vt, ib_gc(ib_r) + 2, ib_gr(ib_r), na(ib_agoS) ? "" : str.tostring(ib_agoS) + " bars ago", text_color = ib_tx2, text_size = ib_tsz, text_halign = text.align_left)
                ib_r += 1
            int ib_maxEff = ib_mob and ib_maxRows > 0 ? ib_maxRows : 999
            if ib_r > ib_maxEff
                for ib_x = ib_maxEff to ib_r - 1
                    table.clear(ib_vt, ib_gc(ib_x), ib_gr(ib_x), ib_gc(ib_x) + 2, ib_gr(ib_x))

    // =============================================================================
    // ANCHOR TEST TABLE — MR rules on all eight anchors + break / reclaim on the chart anchor
    // =============================================================================
    true
f_blk50()
bool showTest = showAll and (tblMode == "Anchor test" or tblMode == "Both")
var table tt = table.new(f_pos(tblPosTest), 9, NA + 4, bgcolor = color.new(#0C0E12, 12), border_width = 1, border_color = color.new(#787B86, 70))
f_tc(int c, int r, string s, color col, bool hl) =>
    table.cell(tt, c, r, s, text_color = col, text_size = f_sz(tblSzIn), bgcolor = hl ? color.new(#FFB300, 80) : na, text_halign = c == 0 ? text.align_left : text.align_right)
f_trow(int r, string nm, int w, int l, float nr, bool hl, int sr) =>
    int n = w + l
    color c = nr >= 0 ? cTgt : cStp
    float gp = array.get(stGP, sr)
    float gl = array.get(stGL, sr)
    float pf = gl > 0 ? gp / gl : na
    f_tc(0, r, nm + (hl ? "  ◀" : ""), hl ? #FFFFFF : #D1D4DC, hl)
    f_tc(1, r, str.tostring(n), #D1D4DC, hl)
    f_tc(2, r, n > 0 ? str.tostring(100.0 * w / n, "#") + "%" : "–", #D1D4DC, hl)
    f_tc(3, r, str.tostring(nr, "#.#"), c, hl)
    f_tc(4, r, n > 0 ? str.tostring(nr / n, "#.###") : "–", c, hl)
    f_tc(5, r, na(pf) ? (gp > 0 ? "∞" : "–") : str.tostring(pf, "#.##"), na(pf) ? #D1D4DC : pf >= 1 ? cTgt : cStp, hl)
    f_tc(6, r, str.tostring(-array.get(stDD, sr), "#.#"), cStp, hl)
    f_tc(7, r, str.tostring(array.get(stXT, sr)) + " / " + str.tostring(array.get(stXS, sr)) + " / " + str.tostring(array.get(stXO, sr)), #D1D4DC, hl)
    f_tc(8, r, n < 30 ? "low n" : "", #FFB300, hl)
var bool ttMerged = false
f_blk51() =>
    if barstate.islast and not showTest
        table.clear(tt, 0, 0, 8, NA + 3)
    if barstate.islast
        if showTest
            color hd = #9598A1
            f_tc(0, 0, "VWAP ANCHOR TEST", #D1D4DC, false)
            f_tc(1, 0, "Trades", hd, false)
            f_tc(2, 0, "Win %", hd, false)
            f_tc(3, 0, "Net R", hd, false)
            f_tc(4, 0, "R / trade", hd, false)
            f_tc(5, 0, "PF", hd, false)
            f_tc(6, 0, "Max DD", hd, false)
            f_tc(7, 0, "T / S / X", hd, false)
            f_tc(8, 0, "", hd, false)
            for k = 0 to NA - 1
                string nm = k == 0 ? rvName : array.get(anName, k)
                f_trow(k + 1, nm, array.get(stW, k), array.get(stL, k), array.get(stR, k), k == selIdx, k)
            f_trow(NA + 1, "Break (chart anchor)", array.get(bsW, 0), array.get(bsL, 0), array.get(bsR, 0), false, NT)
            f_trow(NA + 2, "Reclaim (chart anchor)", array.get(bsW, 1), array.get(bsL, 1), array.get(bsR, 1), false, NT + 1)
            f_tc(0, NA + 3, "MR rules: " + mrRules + " · same for every anchor · gates needed " + str.tostring(gReq) + " · net of " + str.tostring(costTk, "#.#") + " ticks per trade · PF = gross win ÷ gross loss · Max DD in R · exits Target / Stop / timeout · low n = under 30 trades", hd, false)
            if not ttMerged
                table.merge_cells(tt, 0, NA + 3, 8, NA + 3)

    // =============================================================================
    // CANDLES, TRIANGLES, ALERTS
    // =============================================================================
    true
f_blk51()
if barstate.islast
    ttMerged := ttMerged or showTest
color engFinal = switch paintModeEff
    "σ distance (VWAP engine)"   => cMR
    "Price vs VWAP"              => cSide
    "VWAP bands (3-state)"       => cBand3
    "VWAP reversion (2σ → 1σ)"   => cRev
    "Delta size HTF"             => deltaSizeHtfCol
    "Delta % (imbalance)"        => f_g(dPctFinal)
    "Fuel × Δ (Truth Line)"      => f_g(math.sign(nz(barDelta)) * fuelVal)
    => colNeut
bool  mdpHit = mMdp and mdAccept
color outCol = mdpHit ? (mdIsAbs ? mdColAbs : mdColAgg) : engFinal
bool  paintAny = mPaint and not na(outCol)
plotcandle(paintAny ? open : na, paintAny ? high : na, paintAny ? low : na, paintAny ? close : na, "Engine candles", color = outCol, wickcolor = outCol, bordercolor = outCol, display = display.pane)
var array<label> mrLabs = array.new<label>()
var array<label> ceLabs = array.new<label>()
f_blkMarks() =>
    if showAll and mrSig != 0
        f_mark(mrLabs, bar_index, mrSig == 1 ? low : high, mrSig == 1, mrShape, mrSz, mrSig == 1 ? cMrUp : cMrDn, 100)
    if showAll and mCeTri and (rvLong or rvShort)
        f_mark(ceLabs, bar_index, rvLong ? low : high, rvLong, ceShape, ceSz, rvLong ? cCeUp : cCeDn, 100)
    true
f_blkMarks()

// alerts — create the alert on the indicator with 'Any alert() function call'
bool  vwX = barstate.isconfirmed and sOk and not anchorJump and ((close > sVw and close[1] <= sVw[1]) or (close < sVw and close[1] >= sVw[1]))
bool  bOut = barstate.isconfirmed and sOk and not anchorJump and ((close > u1L and close[1] <= u1L[1]) or (close > u2L and close[1] <= u2L[1]) or (close < d1L and close[1] >= d1L[1]) or (close < d2L and close[1] >= d2L[1]))
bool  bIn  = barstate.isconfirmed and sOk and not anchorJump and ((close < u1L and close[1] >= u1L[1]) or (close < u2L and close[1] >= u2L[1]) or (close > d1L and close[1] <= d1L[1]) or (close > d2L and close[1] <= d2L[1]))
f_blk52() =>
    if mMaster and barstate.isconfirmed
        string tk = syminfo.ticker
        if alVw and vwX
            alert("STRYK:MRV " + tk + " — price crossed the VWAP (" + vwEng + ") at " + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)
        if (alBand == "Any" or alBand == "Close outside") and bOut
            alert("STRYK:MRV " + tk + " — close outside a VWAP band at " + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)
        if (alBand == "Any" or alBand == "Close back inside") and bIn
            alert("STRYK:MRV " + tk + " — close back inside a VWAP band at " + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)
        if alSig
            if mrSig != 0
                alert("STRYK:MRV " + tk + " — MR " + (mrSig == 1 ? "LONG" : "SHORT") + " at " + str.tostring(close, format.mintick) + ", stop " + str.tostring(evStp, format.mintick) + ", target " + str.tostring(evTgt, format.mintick), alert.freq_once_per_bar_close)
            if evRes == 1 or evRes == -1
                alert("STRYK:MRV " + tk + " — MR " + (evRes == 1 ? "target" : "stop") + " hit", alert.freq_once_per_bar_close)
            if brSig != 0
                alert("STRYK:MRV " + tk + " — " + (brSig == 1 ? "UP " : "DOWN ") + str.replace_all(brTxt, "\n", " ") + " at " + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)
            if mCeTri and (rvLong or rvShort)
                alert("STRYK:MRV " + tk + " — CE triangle " + (rvLong ? "LONG" : "SHORT") + " at " + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)
        if alSess and mSessLv
            if nakedTouch
                alert("STRYK:MRV " + tk + " — price traded into a naked prior-session POC", alert.freq_once_per_bar_close)
            if leftVa
                alert("STRYK:MRV " + tk + " — price closed outside the developing value area", alert.freq_once_per_bar_close)
            if r80On and r80Event
                alert("STRYK:MRV " + tk + " — 80% rule triggered, target " + str.tostring(r80Tgt, format.mintick), alert.freq_once_per_bar_close)

    // =============================================================================
    // RIGHT-EDGE LABEL PLACER — every queued level label, sorted by price and
    // pushed apart so no two overlap
    // =============================================================================
    true
f_blk52()
// short-hand for the right-edge tags
f_short(string t) =>
    string r = t
    r := str.replace_all(r, "Anchor IB", "aIB")
    r := str.replace_all(r, "Weekday 08:30", "wD")
    r := str.replace_all(r, "Prev session 17:00", "pS")
    r := str.replace_all(r, "Prev-day 08:30", "pD")
    r := str.replace_all(r, "Prev month", "pM")
    r := str.replace_all(r, "3 months", "3M")
    r := str.replace_all(r, "2 weeks", "2W")
    r := str.replace_all(r, "Month", "M")
    r := str.replace_all(r, "rVWAP ", "rV")
    r := str.replace_all(r, " × 1h", "")
    r := str.replace_all(r, " × ", "x")
    r := str.replace_all(r, "profile ", "pf")
    r := str.replace_all(r, "233 EMA", "E233")
    r := str.replace_all(r, "20W EMA", "E20W")
    r := str.replace_all(r, "20W ", "W")
    r := str.replace_all(r, "MDP 50%", "M50")
    r := str.replace_all(r, "MDP POC", "MPOC")
    r := str.replace_all(r, "80% target", "80%")
    r := str.replace_all(r, "dVAH", "dVAH")
    r := str.replace_all(r, "nPOC", "nPOC")
    r := str.replace_all(r, " · ", " ")
    r := str.replace_all(r, "  ", " ")
    r
float rqRng = ta.highest(high, 100) - ta.lowest(low, 100)
var array<label> rqLabs = array.new<label>()
f_blk53() =>
    if drawNow
        for lb in rqLabs
            label.delete(lb)
        array.clear(rqLabs)
        int nq = array.size(rqP)
        if nq > 0 and showAll and labOn
            float gap = labGapTk > 0 ? labGapTk * syminfo.mintick : math.max(syminfo.mintick, nz(rqRng) / 45.0)
            array<int> ix = array.sort_indices(rqP, order.ascending)
            // place upward from the lowest, then shift the stack back down so it stays centred on the real prices
            array<float> ys = array.new_float(nq, 0.0)
            float lastY = na
            float drift = 0.0
            for i = 0 to nq - 1
                float y = array.get(rqP, array.get(ix, i))
                float yy = na(lastY) ? y : math.max(y, lastY + gap)
                array.set(ys, i, yy)
                drift += yy - y
                lastY := yy
            float shift = drift / nq / 2.0
            for i = 0 to nq - 1
                int j = array.get(ix, i)
                float y = array.get(rqP, j)
                string tx = (tagMode == "Short" ? f_short(array.get(rqT, j)) : array.get(rqT, j)) + (labPrice ? " " + str.tostring(y, format.mintick) : "")
                array.push(rqLabs, label.new(bar_index + labOff, array.get(ys, i) - shift, tx, style = label.style_label_left, color = #00000000, textcolor = array.get(rqC, j), size = f_sz(txtSz)))

    true
f_blk53()

// =============================================================================
// SIDE-PROFILE LINE PLACER — every queued POC / VAH / VAL level, drawn across the
// side profile only (axis to right end), tags sorted and pushed apart at the end
// =============================================================================
var array<line>  spLines = array.new<line>()
var array<label> spLabs  = array.new<label>()
f_blk54() =>
    if drawNow
        for ln in spLines
            line.delete(ln)
        array.clear(spLines)
        for lb in spLabs
            label.delete(lb)
        array.clear(spLabs)
        int nq = array.size(spP)
        if nq > 0 and showAll and not isMob
            int xA = bar_index + vpOff
            int xB = xA + vpWid
            float gap = labGapTk > 0 ? labGapTk * syminfo.mintick : math.max(syminfo.mintick, nz(rqRng) / 45.0)
            array<int> ix = array.sort_indices(spP, order.ascending)
            array<float> ys = array.new_float(nq, 0.0)
            float lastY = na
            float drift = 0.0
            for i = 0 to nq - 1
                float y = array.get(spP, array.get(ix, i))
                float yy = na(lastY) ? y : math.max(y, lastY + gap)
                array.set(ys, i, yy)
                drift += yy - y
                lastY := yy
            float shift = drift / nq / 2.0
            for i = 0 to nq - 1
                int j = array.get(ix, i)
                float y = array.get(spP, j)
                color c = array.get(spC, j)
                array.push(spLines, line.new(xA, y, xB, y, color = c, width = array.get(spW, j), style = f_ls(array.get(spS, j))))
                if labOn and array.get(spT, j) != ""
                    string tx = array.get(spT, j) + (labPrice ? "  " + str.tostring(y, format.mintick) : "")
                    array.push(spLabs, label.new(xB + 1, array.get(ys, i) - shift, tx, style = label.style_label_left, color = #00000000, textcolor = c, size = f_sz(txtSz)))

    true
f_blk54()
````
