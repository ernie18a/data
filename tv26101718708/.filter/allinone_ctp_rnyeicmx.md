# All-in-One (CTP)

- url: https://www.tradingview.com/script/rnyeIcMX-All-in-One-CTP/
- type: indicator
- pine_id: PUB;5c4cf1f9e0194a76a215dc6d7b45235c
- version: 16.0

## Description

This script is a professional-grade institutional trading overlay for TradingView that combines 8 tools into one clean indicator:

Structure Analysis

BOS & CHoCH detection with volume filtering and ATR sensitivity to identify market structure shifts
Swing Failure Pattern (SFP) detection that catches liquidity sweeps at highs/lows

Key Levels

Volume Profile with both session (96 bar) and multi-day (384 bar) POC/VAH/VAL levels
Previous Day High/Low lines extending to the right

Trend Tools

Auto-drawing trendlines connecting the last two swing highs and lows
EMA with dynamic color based on price position

Session Context

Range boxes for Sydney, Tokyo, London and New York sessions with bull/bear coloring

Dashboard

Top-right table showing bias, BOS/CHoCH trend, all key levels and live price at a glance

Live Price Tracker

Customizable emoji marker with bubble style and color options

It's essentially a one-script solution that replaces what most traders would need 4-5 separate indicators to achieve — built around institutional concepts like market structure, liquidity sweeps, and volume-based value areas. Clean, well-organized code with proper input groups, ATR-based filtering, and confirmation logic to reduce noise.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © hotchkiss27 — All-In-One (CTP)
//
// v8.1
//   • ORB on by default with all four sessions enabled, projecting 8
//     hours right. Boxes-to-Show raised to 4 so one day of four session
//     boxes survives instead of three being discarded.
//   • Volume Profile defaults to the Weekly profile; Day profile off.
//   • Removed the Previous Day High/Low section. The daily security
//     call it shared is kept in reduced form because the Day profile
//     uses yesterday's range to size its rows.
//
// v8 — CHANGE LOG vs v7
// ─────────────────────────────────────────────────────────────
// VOLUME PROFILE (rebuilt)
//   • Absolute price grid. Rows are now indexed by floor(price/height)
//     and held in a map, so a row covers the same prices for the whole
//     life of a profile. The old engine stretched a fixed row COUNT
//     across a range that kept growing, and re-dumped every row's
//     volume into new rows on each new extreme — lossy, and it
//     compounded across the session.
//   • No rebucketing pass, no full-array scans, POC tracked
//     incrementally as volume is added.
//   • Value area now uses the standard two-rows-at-a-time expansion
//     from the POC rather than one row at a time.
//   • Long-term POC is a true rolling window built from completed
//     DAILY bars: one add and one subtract per day, identical result
//     on every chart timeframe. It used to count chart bars and reset
//     hard, so the level jumped and changed with the timeframe.
//   • Settings consolidated into one group. Removed the duplicate
//     per-profile Rows and Value Area % inputs, and removed the
//     "Lock to Higher Timeframe" switch, which existed to work around
//     the grid problem that no longer exists.
//
// REMOVED
//   • Buy/Sell Walls (HTF consolidation scan) and its whole input group.
//
// ─────────────────────────────────────────────────────────────
// v7 — CHANGE LOG vs v6
// ─────────────────────────────────────────────────────────────
// SESSIONS (major fix)
//   • Every session is now defined in its OWN local timezone with an
//     hour AND minute (Australia/Sydney, Asia/Tokyo, Europe/London,
//     America/New_York). v6 expressed all four in Eastern Time, which
//     silently broke Tokyo and Sydney for ~half the year because Japan
//     has no DST and Australia's DST runs opposite to the US.
//   • ORB now reads its open time straight from the session block, so
//     the separate "Open Minute" ORB inputs are gone (they were a
//     second, conflicting source of truth).
//   • ORB open detection changed from exact-minute equality to a
//     crossing test — it no longer misses the open on timeframes that
//     don't line up exactly with the open minute (e.g. 9:30 on a 1H or
//     10m chart).
//   • ORB window is now measured in real elapsed time (ms) instead of
//     minute-of-day arithmetic, so it can't drift over DST or midnight.
//
// TRENDLINES (rewritten)
//   • Break detection / break colouring / break labels removed.
//   • Now a multi-line engine: keeps up to 5 support + 5 resistance
//     lines at once, selected by scoring candidate anchor pairs on
//     touch count and length, rejecting lines that cut through pivots.
//
// REMOVED
//   • Golden Pocket section (inputs, box, drawing).
//   • The lookahead_on daily OHLC request that fed it — that call was
//     leaking future data onto historical bars.
//
// FIXES
//   • f_findConsolidationWalls: "for m = 1 to maxEach - 1" ran backwards
//     and read out of bounds when Max Walls Each Side = 1 (Pine loops
//     count DOWN when to < from). Now guarded.
//   • Session dashboard computed time-left-in-session and never showed
//     it. Now displayed.
//   • Volume-dependent filters no longer disable themselves on symbols
//     that report no volume.
//   • Level alerts converted from state ("close > VAH") to crossings,
//     so they fire once instead of on every bar.
//   • f_splitLine no longer returns a dummy third line object; all the
//     unused ln_*2 variables deleted.
//   • Golden Cross marker is a triangle, matching its description.

//@version=6
indicator("All-In-One",
     shorttitle       = "All-In-One",
     overlay          = true,
     max_lines_count  = 500,
     max_labels_count = 500,
     max_boxes_count  = 500)

// ══════════════════════════════════════════════════════════════
// ░░  USER TYPES
// ══════════════════════════════════════════════════════════════
type TLine
    line  ln
    label lb

type VProfile
    map<int, float> bins
    float binSz
    int   minBin
    int   maxBin
    int   anchor
    int   pocBin
    float pocVol
    float total
    float poc
    float vah
    float val

// ══════════════════════════════════════════════════════════════
// ░░  INPUTS
// ══════════════════════════════════════════════════════════════

grpMS          = "② Market Structure — BOS & CHoCH"
i_showMS       = input.bool(true,  "Show BOS / CHoCH",                             group=grpMS,
     tooltip="Master toggle for market-structure break detection and drawing.")
i_showMSLbls   = input.bool(true,  "Show Labels",                                  group=grpMS)
i_msLen        = input.int(8,      "Pivot Length",     minval=1,  maxval=50,       group=grpMS)
i_msVolFilt    = input.bool(true,  "Volume Filter",                                 group=grpMS,
     tooltip="Require volume above 1.1x its 20-bar average for a break to count. Filters out low-conviction breaks. Automatically ignored on symbols that report no volume.")
i_msATRMult    = input.float(1.0,  "ATR Sensitivity",  minval=0.1,maxval=5.0,
                 step=0.1,                                                           group=grpMS,
     tooltip="Minimum pivot size relative to ATR for a swing high/low to qualify as valid structure. Higher = only major swings count.")
i_msDisplace   = input.float(0.2,  "Min Break Displacement (× ATR)", minval=0.0, maxval=2.0,
                 step=0.05,                                                          group=grpMS,
     tooltip="How far beyond the swing level (in ATR units) the close must travel to confirm a break. 0 = any close beyond the level counts.")
i_msSwingFilt  = input.bool(true,  "Swing Size Filter",                             group=grpMS,
     tooltip="When enabled, pivots must also clear the Min Swing Size threshold below to be considered valid structure.")
i_msSwingMult  = input.float(1.2,  "  Min Swing Size (× avg swing)", minval=0.5, maxval=5.0,
                 step=0.1,                                                           group=grpMS,
     tooltip="Pivot must be at least this many times the recent average swing size. Filters out minor wiggles from being marked as structure.")
i_colBull      = input.color(#089981, "Bullish Color",                              group=grpMS)
i_colBear      = input.color(#f23645, "Bearish Color",                              group=grpMS)
i_msMode       = input.string("Historical", "Structure Mode",
     options=["Historical","Present"],                                               group=grpMS,
     tooltip="Historical: all BOS/CHoCH lines stay on the chart. Present: each new signal removes the previous line in that direction, keeping the chart focused on current structure only.")
i_showInternalMS  = input.bool(true,  "Show Internal Structure",                    group=grpMS,
     tooltip="Runs a second, faster BOS/CHoCH engine alongside the main swing structure. Internal breaks use a shorter pivot length and draw as dashed lines — they often fire before the main structure, giving earlier signals. Internal CHoCH is a strong leading indicator of swing CHoCH.")
i_msInternalLen   = input.int(3,      "  Internal Pivot Length", minval=1, maxval=20, group=grpMS,
     tooltip="Bars on each side to define an internal pivot. Default 3 — much shorter than swing to catch intra-leg structure.")
i_colInternalBull = input.color(color.new(#089981, 50), "  Internal Bull",          group=grpMS, inline="intcol")
i_colInternalBear = input.color(color.new(#f23645, 50), "  Internal Bear",          group=grpMS, inline="intcol")

grpSFP             = "② Market Structure — Swing Failure Pattern"
i_showSFP          = input.bool(true,  "Show SFP",                                        group=grpSFP,
     tooltip="Master toggle for Swing Failure Pattern detection (liquidity sweep + rejection).")
i_sfpLen           = input.int(10,     "Pivot Length",          minval=2,  maxval=50,     group=grpSFP)
i_sfpLookbk        = input.int(100,    "Swing Lookback Bars",   minval=5,  maxval=300,    group=grpSFP)
i_sfpATRMult       = input.float(0.5,  "Min Wick ATR",          minval=0.0,maxval=3.0,
                     step=0.1,                                                              group=grpSFP,
     tooltip="Minimum size of the rejection wick, in ATR units. Lower values catch smaller sweeps.")
i_sfpWickPct       = input.float(0.25, "Min Wick % of Range",   minval=0.05,maxval=0.9,
                     step=0.05,                                                             group=grpSFP,
     tooltip="The rejection wick must be at least this fraction of the candle's total high-low range.")
i_sfpVolConf       = input.bool(true,  "Volume Confirmation",                              group=grpSFP,
     tooltip="Require the sweep candle's volume to exceed its 20-bar average. Automatically ignored on symbols with no volume.")
i_sfpCISD          = input.bool(true,  "CISD Confirmation (next bar closes back in range)",group=grpSFP,
     tooltip="Change in State of Delivery: requires the bar AFTER the sweep to close back inside the prior range, confirming the rejection rather than firing on the wick alone.")
i_sfpTrend         = input.bool(false, "Trend Alignment Filter (EMA)",                    group=grpSFP,
     tooltip="Only allow bearish SFPs when price is above EMA 1 (uptrend) and bullish SFPs when below it. Reduces signals but improves alignment with the prevailing trend.")
i_sfpBosConfluence = input.bool(false, "Require BOS/CHoCH Confluence",              group=grpSFP,
     tooltip="Only show an SFP if a CHoCH or BOS in the SAME direction fires within a few bars (before or after). This is the strongest filter for reversal probability. Requires ② BOS/CHoCH to be enabled.")
i_sfpConfluenceBars = input.int(5, "  Confluence Window (bars)", minval=1, maxval=20,  group=grpSFP,
     tooltip="How many bars before/after the SFP to look for a matching BOS/CHoCH event.")
i_sfpSweepMult     = input.float(0.0, "Min Sweep Depth (× ATR)", minval=0.0, maxval=2.0, step=0.1, group=grpSFP,
     tooltip="How far the wick must travel BEYOND the swing level (in ATR units), not just the wick's total size. A deeper sweep suggests a larger liquidity pool was taken. 0 = disabled.")
i_sfpBullCol       = input.color(color.new(#089981, 60), "Bull SFP Dot",                  group=grpSFP)
i_sfpBearCol       = input.color(color.new(#f23645, 60), "Bear SFP Dot",                  group=grpSFP)
i_sfpStrongCol     = input.color(color.new(#FFD700, 0),  "Strong SFP Marker",             group=grpSFP,
     tooltip="Color for SFPs that also pass the BOS/CHoCH Confluence filter — marked with a star instead of a circle.")

// ─────────────────────────────────────────────────────────────
// ② TRENDLINES — MULTI-LINE ENGINE (v7 rewrite)
// Break detection removed. Instead of one ascending + one descending
// line, the engine now keeps a pool of up to 5 support and 5
// resistance lines drawn between scored pivot pairs.
//
// How a line is chosen: on every confirmed pivot, each earlier pivot in
// memory is tested as a possible anchor. A candidate is thrown out if
// any pivot between the two anchors sits on the wrong side of the line
// (more than the tolerance allows). Surviving candidates are scored on
// touch count first, then length, and the winner is drawn.
// ─────────────────────────────────────────────────────────────
grpTL          = "② Market Structure — Trendlines"
i_showTL       = input.bool(true, "Show Trendlines",                                group=grpTL,
     tooltip="Draws multiple support and resistance trendlines between scored swing-pivot pairs. Lines extend right and are retired oldest-first once the maximum is reached.")
i_tlPivLen     = input.int(10,   "Pivot Length",    minval=2, maxval=50,            group=grpTL,
     tooltip="Bars on each side required to qualify a swing high/low as a pivot point. Higher = fewer, more significant anchors.")
i_tlMaxEach    = input.int(1,    "Max Lines Each Side", minval=1, maxval=5,         group=grpTL,
     tooltip="How many support lines and how many resistance lines can be on the chart at once. 4 each = up to 8 lines total. Oldest is deleted when a new one is added.")
i_tlPool       = input.int(10,   "Pivot Memory",    minval=3, maxval=25,            group=grpTL,
     tooltip="How many past pivots the engine keeps as possible anchor points. Higher = the engine can reach further back for a longer, better-fitting line, at the cost of more computation.")
i_tlMinBars    = input.int(15,   "Min Bars Between Anchors", minval=3, maxval=300,  group=grpTL,
     tooltip="Two anchors must be at least this many bars apart. Stops the engine drawing steep, meaningless lines between two pivots that are right next to each other.")
i_tlTolATR     = input.float(0.4,"Touch Tolerance (× ATR)", minval=0.05, maxval=2.0, step=0.05, group=grpTL,
     tooltip="How close a pivot has to come to the line to count as a touch, and how far it may poke through before the line is rejected. In ATR units, so it scales with volatility.")
i_tlMaxViol    = input.int(1,    "Max Violating Pivots",  minval=0, maxval=5,       group=grpTL,
     tooltip="How many pivots between the two anchors may break through the line before the candidate is discarded. 0 = perfectly clean lines only (fewest lines, highest quality). 1-2 is a good balance.")
i_tlMinTouch   = input.int(2,    "Min Touches",     minval=2, maxval=6,             group=grpTL,
     tooltip="Minimum pivots the line must pass through, including its own two anchors. 2 = any valid pair. 3+ = only lines confirmed by a third swing point.")
i_tlDirOnly    = input.bool(true, "Classic Direction Only",                         group=grpTL,
     tooltip="On: resistance lines connect lower highs and support lines connect higher lows (classic descending resistance / ascending support). Off: any pivot pair qualifies, so rising channel tops and falling channel bottoms get drawn too.")
i_tlBullCol    = input.color(color.new(#00E676, 20), "Support Color",               group=grpTL, inline="tlcol",
     tooltip="Color for trendlines drawn through swing lows.")
i_tlBearCol    = input.color(color.new(#ef5350, 20), "Resistance Color",            group=grpTL, inline="tlcol",
     tooltip="Color for trendlines drawn through swing highs.")
i_tlWidth      = input.int(1, "Width",     minval=1, maxval=4,                      group=grpTL, inline="tlstyle")
i_tlStyle      = input.string("Dashed", "Style",
     options=["Solid","Dashed","Dotted"],                                            group=grpTL, inline="tlstyle")
i_tlExtend     = input.bool(false, "Extend Right",                                  group=grpTL,
     tooltip="Project each line forward past its second anchor. Turn off to show only the segment between the two pivots.")
i_tlShowTouch  = input.bool(true, "Show Touch Count",                               group=grpTL,
     tooltip="Small label at the end of each line showing how many pivots it connects. 2T is a basic line; 3T or 4T is a well-tested one.")

// ─────────────────────────────────────────────────────────────
// ② OPENING RANGE BREAKOUT (ORB)
// Open times come from ⑤ Session Times — each session in its own
// local timezone, so opens stay correct through every DST change.
// ─────────────────────────────────────────────────────────────
grpORB         = "② Opening Range Breakout (ORB)"
i_showORB      = input.bool(true,  "Show ORB Boxes",                                group=grpORB,
     tooltip="Draws a box around the first N minutes of the selected session(s), then colors it green/red on the first breakout close. Open times are taken from ⑤ Session Times.")
i_orbRange     = input.string("15 min", "Opening Range",
     options=["5 min","15 min","30 min","60 min"],                                   group=grpORB,
     tooltip="Length of the opening range window, measured from each session's open time.")
i_orbNY        = input.bool(true,  "NY",      group=grpORB, inline="orbsess1",
     tooltip="Pick any combination of sessions to get an opening-range box.")
i_orbLon       = input.bool(true,  "London",  group=grpORB, inline="orbsess1")
i_orbSyd       = input.bool(true,  "Sydney",  group=grpORB, inline="orbsess2")
i_orbTok       = input.bool(true,  "Tokyo",   group=grpORB, inline="orbsess2")
i_orbExtendHrs = input.float(8, "Extend Box Right (hours)", minval=0, maxval=24, step=0.5, group=grpORB,
     tooltip="How far past the end of the opening range the box and midline project forward. Measured in real hours, so 4 stays 4 whether you are on a 1-minute or a 1-hour chart. 0 draws the box only across the range itself.")
i_orbLtf       = input.timeframe("1", "Range Precision Timeframe", group=grpORB,
     tooltip="The opening range is measured from bars of THIS timeframe, not your chart's. That is what keeps a 15-minute range a true 15 minutes when you switch the chart to 1H or 4H — otherwise the range would silently become whatever that single big candle did. Set it to 1 for exact ranges. If you set it above your chart timeframe it falls back to chart bars. Very old history has no intrabar data available, in which case the chart bar is used instead.")
i_orbMid       = input.bool(false, "Show Midline",                                  group=grpORB,
     tooltip="Draws the 50% level of the opening range. Price reclaiming or losing the midline is often the first tell on which way the range will resolve.")
i_orbFillCol   = input.color(color.new(#9C27B0, 80), "Box Fill (default)",          group=grpORB)
i_orbBullCol   = input.color(color.new(#00E676, 80), "Box Fill (bullish break)",    group=grpORB)
i_orbBearCol   = input.color(color.new(#ef5350, 80), "Box Fill (bearish break)",    group=grpORB)
i_orbBordCol   = input.color(color.new(#9C27B0, 70), "Border (default)",            group=grpORB)
i_orbBullBord  = input.color(color.new(#00E676, 70), "Border (bullish break)",      group=grpORB)
i_orbBearBord  = input.color(color.new(#ef5350, 70), "Border (bearish break)",      group=grpORB)
i_orbMidCol    = input.color(color.new(#9C27B0, 40), "Midline Color",               group=grpORB)
i_orbCount     = input.int(1,  "Boxes to Show", minval=1, maxval=50,                group=grpORB,
     tooltip="How many ORB boxes remain on the chart before older ones are deleted. This counts boxes, not days — with all four sessions enabled a single day produces four boxes, so 1 shows only the most recently opened session and 4 keeps roughly a full day.")

// ══════════════════════════════════════════════════════════════
// ③ VOLUME PROFILE
// ══════════════════════════════════════════════════════════════
// ══════════════════════════════════════════════════════════════
// ③ VOLUME PROFILE
// ══════════════════════════════════════════════════════════════
// One settings group drives every profile: one row-size rule, one value
// area percentage, one distribution method. The Profiles group below is
// nothing but on/off switches and anchors. Previously the Day profile
// carried its own duplicate Rows and Value Area %, the 250-Day profile
// carried a third, and a "Lock to Higher Timeframe" switch tried to
// paper over a grid problem that no longer exists.
// ══════════════════════════════════════════════════════════════
grpVP = "③ Volume Profile"
i_vpEnabled      = input.bool(true, "Enable Volume Profile Engine", group=grpVP,
     tooltip="Master switch. Turn off to skip all profile computation.")
i_vpRowMode      = input.string("Auto (Rows)", "Row Size Mode",
     options=["Auto (Rows)","Fixed Ticks per Row"], group=grpVP,
     tooltip="Auto: each profile picks a row height when it starts, sized so a typical range fills roughly the Rows count below. Fixed: every row is exactly N ticks tall on every profile and every symbol — the more rigorous choice if you compare levels across days, because a row means the same thing every time.")
i_vpRows         = input.int(60, "  Rows (Auto mode)", minval=10, maxval=300, group=grpVP,
     tooltip="Target number of rows. This now sets the row HEIGHT at the moment a profile starts rather than forcing a fixed row count onto a range that keeps changing, so a wide day simply uses more rows instead of rescaling everything that came before it.")
i_vpTicksPerRow  = input.int(10, "  Ticks per Row (Fixed mode)", minval=1, maxval=5000, group=grpVP,
     tooltip="Row height in ticks. On ES one tick is 0.25, so 10 gives 2.5-point rows. Lower = finer detail and more computation.")
i_vpValueAreaPct = input.float(70, "Value Area %", minval=50, maxval=95, step=5, group=grpVP,
     tooltip="Share of total volume enclosed between VAH and VAL. 70% is the market-profile standard.")
i_vpCalcMethod   = input.string("Distributed (Hi-Lo)", "Volume Distribution",
     options=["Distributed (Hi-Lo)","Single Price (HLC3)"], group=grpVP,
     tooltip="Distributed: each bar's volume is spread across every row its high-low range covered, weighted by overlap. Single Price: the whole bar's volume lands on one row at HLC3 — cruder, but much lighter on very long profiles.")

grpVPProfiles = "③ Volume Profile — Profiles"
i_showSessionVP = input.bool(false, "Day Profile — POC / VAH / VAL", group=grpVPProfiles,
     tooltip="The current day's profile. Also needs the engine switch above.")
i_dayVPDays     = input.int(1, "  Days per Profile", minval=1, maxval=30, group=grpVPProfiles,
     tooltip="Calendar days each profile spans before it resets. 1 is the classic daily POC/VAH/VAL. Measured in days, not bars, so it holds across chart timeframes.")
i_showPrevVP    = input.bool(false, "Previous Profile — pPOC / pVAH / pVAL", group=grpVPProfiles,
     tooltip="Levels from the profile that just closed, frozen at its final values.")
i_showWeeklyVP  = input.bool(true,  "Weekly Profile", group=grpVPProfiles)
i_showStructVP  = input.bool(false, "Structure Profile (anchored to BOS/CHoCH)", group=grpVPProfiles,
     tooltip="Restarts on every swing structure break, so it shows where volume built up during the current leg only.")
i_showYearlyPOC = input.bool(true,  "Long-Term POC", group=grpVPProfiles,
     tooltip="A true rolling profile built from completed DAILY bars, so it reads identically on a 1-minute chart and a 4-hour chart. The old version counted chart bars, which meant its answer changed every time you switched timeframe.")
i_ltDays        = input.int(250, "  Long-Term Lookback (days)", minval=20, maxval=500, group=grpVPProfiles,
     tooltip="How many completed daily bars stay in the rolling window. Each new day is added and the oldest day is subtracted, so the level drifts smoothly instead of jumping when the window resets.")

grpVWAP        = "④ VWAP"
i_showVWAP     = input.bool(true,  "Show VWAP",                                     group=grpVWAP)
i_vwapType     = input.string("Session", "Anchor Period",
     options=["Session","Week","Month"],                                              group=grpVWAP,
     tooltip="When VWAP resets and starts recalculating from zero. Session = every new day (most common for intraday). Week/Month for swing analysis.")
i_showVWAPBands = input.bool(false, "Show Bands (±1 / ±2 StdDev)",                  group=grpVWAP)
i_vwapCol      = input.color(#2196F3,                    "VWAP Color",               group=grpVWAP)
i_vwapBull     = input.color(color.new(#FFA726, 0),      "Bull Color (above VWAP)",  group=grpVWAP)
i_vwapBear     = input.color(color.new(#E64A19, 0),      "Bear Color (below VWAP)",  group=grpVWAP)
i_vwap1Col     = input.color(color.new(#2196F3, 60),     "Band ±1 Color",            group=grpVWAP)
i_vwap2Col     = input.color(color.new(#2196F3, 80),     "Band ±2 Color",            group=grpVWAP)
i_vwapLW       = input.int(2, "Line Width", minval=1, maxval=4,                      group=grpVWAP)
i_vwapSource   = input.string("HLC3", "Source",
     options=["HLC3","Close","OHLC4"],                                                group=grpVWAP,
     tooltip="HLC3 (High+Low+Close)/3 is the industry standard. Close uses closing price only. OHLC4 averages all four OHLC values.")
i_vwapZoneFill = input.bool(false, "Show Value Zone Fill (VWAP to ±1σ)",             group=grpVWAP,
     tooltip="Shades the area between VWAP and the ±1σ band — the statistical fair value zone where price spends about 68% of the session. Requires bands to be enabled.")
i_vwapZoneCol  = input.color(color.new(#2196F3, 92), "Value Zone Fill Color",        group=grpVWAP)

// ══════════════════════════════════════════════════════════════
// ⑤ SESSION TIMES — each session in its OWN local timezone
// ══════════════════════════════════════════════════════════════
// This is the v7 fix. Expressing Tokyo and Sydney in Eastern Time can
// only ever be right for part of the year: Japan runs no DST at all,
// Australia's DST runs opposite to the northern hemisphere, and the UK
// and US switch on different dates. Anchoring each session to its own
// IANA timezone means TradingView resolves the offset per bar and the
// opens stay correct year-round with no manual adjustment.
//
// Defaults are the real cash-market hours:
//   Sydney  ASX  10:00 – 16:00  Australia/Sydney
//   Tokyo   TSE   9:00 – 15:00  Asia/Tokyo
//   London  LSE   8:00 – 16:30  Europe/London
//   NY      NYSE  9:30 – 16:00  America/New_York
// For 24h FX conventions instead, common settings are
//   Sydney 17:00–02:00 (as seen in Sydney: 07:00–16:00),
//   Tokyo 9:00–18:00, London 8:00–17:00, NY 8:00–17:00.
// ══════════════════════════════════════════════════════════════
grpST = "⑤ Session Times (local to each market)"

i_sydSH = input.int(10, "Sydney Open  (Australia/Sydney)", minval=0, maxval=23, group=grpST, inline="sydO")
i_sydSM = input.int(0,  ":",                               minval=0, maxval=59, group=grpST, inline="sydO")
i_sydEH = input.int(16, "Sydney Close (Australia/Sydney)", minval=0, maxval=23, group=grpST, inline="sydC")
i_sydEM = input.int(0,  ":",                               minval=0, maxval=59, group=grpST, inline="sydC")

i_tokSH = input.int(9,  "Tokyo Open   (Asia/Tokyo)",       minval=0, maxval=23, group=grpST, inline="tokO")
i_tokSM = input.int(0,  ":",                               minval=0, maxval=59, group=grpST, inline="tokO")
i_tokEH = input.int(15, "Tokyo Close  (Asia/Tokyo)",       minval=0, maxval=23, group=grpST, inline="tokC")
i_tokEM = input.int(0,  ":",                               minval=0, maxval=59, group=grpST, inline="tokC")

i_lonSH = input.int(8,  "London Open  (Europe/London)",    minval=0, maxval=23, group=grpST, inline="lonO")
i_lonSM = input.int(0,  ":",                               minval=0, maxval=59, group=grpST, inline="lonO")
i_lonEH = input.int(16, "London Close (Europe/London)",    minval=0, maxval=23, group=grpST, inline="lonC")
i_lonEM = input.int(30, ":",                               minval=0, maxval=59, group=grpST, inline="lonC")

i_nySH  = input.int(9,  "NY Open      (America/New_York)", minval=0, maxval=23, group=grpST, inline="nyO")
i_nySM  = input.int(30, ":",                               minval=0, maxval=59, group=grpST, inline="nyO")
i_nyEH  = input.int(16, "NY Close     (America/New_York)", minval=0, maxval=23, group=grpST, inline="nyC")
i_nyEM  = input.int(0,  ":",                               minval=0, maxval=59, group=grpST, inline="nyC")

i_sessSkipWknd = input.bool(true, "Ignore Weekends", group=grpST,
     tooltip="Treat Saturday and Sunday in each market's own local calendar as closed. Turn off for crypto or any 7-day market where you still want session windows highlighted.")

grpPrice       = "⑥ Live Price Bubble"
i_showPrice    = input.bool(false, "Show Price Bubble",                               group=grpPrice)
i_priceEmoji   = input.string("💰", "Price Emoji",
     options=["💰","🎯","⚡","🔵","📍","🔥"],                                       group=grpPrice)
i_priceStyle   = input.string("label_left", "Bubble Style",
     tooltip="Shape/position of the live price marker relative to the current bar.",
     options=["label_left","label_right","label_up","label_down",
              "label_center","label_upper_left","label_upper_right",
              "label_lower_left","label_lower_right",
              "circle","square","diamond","triangleup","triangledown",
              "flag","xcross","cross","arrowup","arrowdown","none"],                  group=grpPrice)
i_priceBg      = input.color(color.new(#21446c, 10), "Bubble Color",                group=grpPrice)

grpSD      = "⑦ Session Dashboard"
i_showSD   = input.bool(true, "Show Session Dashboard", group=grpSD,
     tooltip="Small table showing the active session, how long until it closes, the session high/low, and which session opens next.")
i_sdPos    = input.string("top_right", "Table Position",
     options=["top_right","top_left","bottom_right","bottom_left"], group=grpSD,
     tooltip="Corner of the chart where the session dashboard table appears.")
i_sdTxtSz  = input.string(size.tiny, "Text Size",
     options=[size.tiny, size.small, size.normal], group=grpSD)
i_sdLocalTZ = input.string("America/Denver", "Your Timezone (for 'Your Time' row)",
     options=["America/New_York","America/Chicago","America/Denver","America/Los_Angeles",
              "America/Anchorage","Pacific/Honolulu","UTC","Europe/London","Europe/Berlin",
              "Asia/Tokyo","Asia/Shanghai","Asia/Kolkata","Australia/Sydney"],
     group=grpSD,
     tooltip="Timezone for the 'Your Time' row. Defaults to America/Denver (Mountain Time, used in New Mexico). Does NOT affect session detection — each session uses its own market timezone.")

grpEMA         = "⑧ Trend Analysis"
i_showDX       = input.bool(false, "Show Death / Golden Cross",                     group=grpEMA,
     tooltip="Enables EMA 1 (fast) and EMA 2 (slow) together as a linked death/golden cross system. Both lines show the same color based on which is dominant.")
i_dxFastLen    = input.int(50,  "  Fast EMA (1)", minval=1, maxval=500,             group=grpEMA, inline="dxlen",
     tooltip="Shorter-period EMA. Default 50. The classic death/golden cross pair is 50/200.")
i_dxSlowLen    = input.int(200, "  Slow EMA (2)", minval=1, maxval=500,             group=grpEMA, inline="dxlen",
     tooltip="Longer-period EMA. Default 200. When the fast EMA crosses below this, a Death Cross fires.")
i_dxBullCol    = input.color(color.new(#00E676, 0), "  Bull Color",                 group=grpEMA, inline="dxcol")
i_dxBearCol    = input.color(color.new(#FF5252, 0), "  Bear Color",                 group=grpEMA, inline="dxcol")
i_showDXMarker = input.bool(true, "  Show Cross Markers",                           group=grpEMA,
     tooltip="Draws a red ✕ at every Death Cross and a green triangle at every Golden Cross.")
i_dxDeathCol   = input.color(color.new(#FF0000, 0), "  Death ✕ Color",             group=grpEMA, inline="dxmark")
i_dxGoldCol    = input.color(color.new(#00E676, 0), "  Golden ▲ Color",            group=grpEMA, inline="dxmark")
i_showEma3     = input.bool(false, "Show EMA 3",                                    group=grpEMA,
     tooltip="Third, typically longer-period EMA for higher-timeframe bias (e.g. 100 or 200).")
i_ema3Len      = input.int(100,    "  Length",              minval=1, maxval=500,   group=grpEMA)
i_ema3BullCol  = input.color(color.new(#795548, 0), "  Bull Color",                 group=grpEMA, inline="e3col")
i_ema3BearCol  = input.color(color.new(#795548, 0), "  Bear Color",                 group=grpEMA, inline="e3col")

grpVPC = "⑨ VP Colors"
i_sessPOCCol  = input.color(#FFFFFF,               "Daily POC",      group=grpVPC, inline="sess")
i_sessVAHCol  = input.color(#ef5350,               "  VAH",          group=grpVPC, inline="sess")
i_sessVALCol  = input.color(#00E676,               "  VAL",          group=grpVPC, inline="sess")
i_prevPOCCol  = input.color(color.new(#FFFFFF,40), "Prev pPOC",      group=grpVPC, inline="prev")
i_prevVAHCol  = input.color(color.new(#ef5350,40), "  pVAH",         group=grpVPC, inline="prev")
i_prevVALCol  = input.color(color.new(#00E676,40), "  pVAL",         group=grpVPC, inline="prev")
i_weekPOCCol  = input.color(color.new(#B0BEC5,20), "Weekly POC",     group=grpVPC, inline="week")
i_weekVAHCol  = input.color(color.new(#ef5350,40), "  VAH",          group=grpVPC, inline="week")
i_weekVALCol  = input.color(color.new(#00E676,40), "  VAL",          group=grpVPC, inline="week")
i_struPOCCol  = input.color(color.new(#90A4AE, 0), "Struct POC",     group=grpVPC, inline="stru")
i_struVAHCol  = input.color(color.new(#ef5350,60), "  VAH",          group=grpVPC, inline="stru")
i_struVALCol  = input.color(color.new(#00E676,60), "  VAL",          group=grpVPC, inline="stru")
i_yearlyPOCCol = input.color(color.new(#FF9800, 0),"Long-Term POC",  group=grpVPC)

i_sessLineStyle = input.string("Solid",  "Daily Line Style",
     options=["Solid","Dashed","Dotted"], group=grpVPC, inline="sessstyle")
i_sessLineWidth = input.int(1, "Width", minval=1, maxval=4, group=grpVPC, inline="sessstyle")
i_prevLineStyle = input.string("Dotted", "Previous Line Style",
     options=["Solid","Dashed","Dotted"], group=grpVPC, inline="prevstyle")
i_prevLineWidth = input.int(2, "Width", minval=1, maxval=4, group=grpVPC, inline="prevstyle")
i_weekLineStyle = input.string("Dashed", "Weekly Line Style",
     options=["Solid","Dashed","Dotted"], group=grpVPC, inline="weekstyle")
i_weekLineWidth = input.int(1, "Width", minval=1, maxval=4, group=grpVPC, inline="weekstyle")
i_struLineStyle = input.string("Dotted", "Structure Line Style",
     options=["Solid","Dashed","Dotted"], group=grpVPC, inline="strustyle")
i_struLineWidth = input.int(1, "Width", minval=1, maxval=4, group=grpVPC, inline="strustyle")
i_yearLineStyle = input.string("Solid",  "Long-Term Line Style",
     options=["Solid","Dashed","Dotted"], group=grpVPC, inline="yearstyle")
i_yearLineWidth = input.int(1, "Width", minval=1, maxval=4, group=grpVPC, inline="yearstyle")

i_lblLaneWidth = input.int(10, "Label Spacing Between Profiles", minval=2, maxval=60, group=grpVPC,
     tooltip="Daily, Previous, Weekly, Structure and 250-Day each get their own horizontal column for their POC/VAH/VAL labels, spaced this many BARS apart. Keep this small. A bar offset is a fixed number of bars, not a fixed screen distance, so a large value looks fine zoomed out but throws the labels off-screen when you zoom in. 10 puts the furthest label 50 bars past the last candle.")
i_lblRightPad  = input.int(3, "Label Offset From Last Bar", minval=0, maxval=30, group=grpVPC,
     tooltip="How far past the most recent candle the first label column sits.")

// ══════════════════════════════════════════════════════════════
// ░░  HELPER FUNCTIONS
// ══════════════════════════════════════════════════════════════
f_lineStyle(s) => s == "Dashed" ? line.style_dashed : s == "Dotted" ? line.style_dotted : line.style_solid

f_labelStyle(s) =>
    s == "label_left"         ? label.style_label_left        :
     s == "label_right"       ? label.style_label_right       :
     s == "label_up"          ? label.style_label_up          :
     s == "label_down"        ? label.style_label_down        :
     s == "label_center"      ? label.style_label_center      :
     s == "label_upper_left"  ? label.style_label_upper_left  :
     s == "label_upper_right" ? label.style_label_upper_right :
     s == "label_lower_left"  ? label.style_label_lower_left  :
     s == "label_lower_right" ? label.style_label_lower_right :
     s == "circle"            ? label.style_circle            :
     s == "square"            ? label.style_square            :
     s == "diamond"           ? label.style_diamond           :
     s == "triangleup"        ? label.style_triangleup        :
     s == "triangledown"      ? label.style_triangledown      :
     s == "flag"              ? label.style_flag              :
     s == "xcross"            ? label.style_xcross            :
     s == "cross"             ? label.style_cross             :
     s == "arrowup"           ? label.style_arrowup           :
     s == "arrowdown"         ? label.style_arrowdown         :
     label.style_none

// Is nowM inside [sM, eM)? Handles windows that wrap past local midnight.
f_sessActive(nowM, sM, eM) =>
    sM <= eM ? (nowM >= sM and nowM < eM) : (nowM >= sM or nowM < eM)

// Minutes from now until the next occurrence of tgtM on the same clock.
f_minsUntil(nowM, tgtM) => (tgtM - nowM + 1440) % 1440

f_fmtMins(m) =>
    int hrs  = int(m / 60)
    int mins = m - hrs * 60
    m <= 0  ? "now" :
     m < 60 ? str.tostring(m) + "m" :
     str.tostring(hrs) + "h " + str.tostring(mins) + "m"

f_fmtClock(h, m) =>
    int    h12  = h % 12 == 0 ? 12 : h % 12
    string ampm = h < 12 ? "AM" : "PM"
    string mStr = m < 10 ? "0" + str.tostring(m) : str.tostring(m)
    str.tostring(h12) + ":" + mStr + " " + ampm

f_sdTblPos(p) =>
    p == "top_right"    ? position.top_right    :
     p == "top_left"    ? position.top_left     :
     p == "bottom_left" ? position.bottom_left  :
     position.bottom_right

// ══════════════════════════════════════════════════════════════
// ░░  SECTION 1 — SHARED CALCULATIONS
// ══════════════════════════════════════════════════════════════
atr   = ta.atr(14)

// Symbols without volume (many FX and index feeds) report na. Fall back
// to a flat 1.0 so the profile engine still builds a price-time profile,
// and disable the volume filters rather than letting them block signals.
bool  hasVol = not na(volume) and volume > 0
float vpVol  = hasVol ? volume : 1.0
volMA = ta.sma(vpVol, 20)

// Yesterday's completed range, used only to size the Day profile's rows.
// [1] with lookahead_on is the safe idiom — a completed prior period,
// no future leak.
float prevDayRange = request.security(syminfo.tickerid, "D", high[1] - low[1],
     lookahead = barmerge.lookahead_on)

bool isNewSession = ta.change(time("D")) != 0
bool isNewWeek    = ta.change(time("W")) != 0

// ══════════════════════════════════════════════════════════════
// ░░  SECTION 2 — EMAs + DEATH / GOLDEN CROSS
// ══════════════════════════════════════════════════════════════
ema1 = ta.ema(close, i_dxFastLen)
ema2 = ta.ema(close, i_dxSlowLen)

color dxZoneCol = ema1 >= ema2 ? i_dxBullCol : i_dxBearCol

plot(i_showDX ? ema1 : na, "Fast EMA", color=dxZoneCol, linewidth=1)
plot(i_showDX ? ema2 : na, "Slow EMA", color=dxZoneCol, linewidth=2)

bool deathCross  = ta.crossunder(ema1, ema2)
bool goldenCross = ta.crossover(ema1, ema2)

plotshape(i_showDX and i_showDXMarker and deathCross  ? ema2 : na, "Death Cross ✕",
     style=shape.xcross, location=location.absolute,
     color=i_dxDeathCol, size=size.small)

plotshape(i_showDX and i_showDXMarker and goldenCross ? ema2 : na, "Golden Cross ▲",
     style=shape.triangleup, location=location.absolute,
     color=i_dxGoldCol, size=size.small)

ema3     = ta.ema(close, i_ema3Len)
ema3Col  = close >= ema3 ? i_ema3BullCol : i_ema3BearCol
plot(i_showEma3 ? ema3 : na, "EMA 3", color=ema3Col, linewidth=2)

// ══════════════════════════════════════════════════════════════
// ░░  SECTION 3 — BOS & CHoCH (swing structure)
// ══════════════════════════════════════════════════════════════
float ph_ms = ta.pivothigh(high, i_msLen, i_msLen)
float pl_ms = ta.pivotlow (low,  i_msLen, i_msLen)

float avgSwing    = ta.sma(ta.atr(i_msLen), 20)
float msLowest    = ta.lowest(low,   i_msLen * 2)
float msHighest   = ta.highest(high, i_msLen * 2)
float swingHgt_ph = not na(ph_ms) ? ph_ms - msLowest : 0.0
float swingHgt_pl = not na(pl_ms) ? msHighest - pl_ms : 0.0
bool swingSzOk_ph = not i_msSwingFilt or swingHgt_ph >= avgSwing * i_msSwingMult * i_msLen * 0.1
bool swingSzOk_pl = not i_msSwingFilt or swingHgt_pl >= avgSwing * i_msSwingMult * i_msLen * 0.1

bool phValid = not na(ph_ms) and (ph_ms - low[i_msLen])  > atr * i_msATRMult and swingSzOk_ph
bool plValid = not na(pl_ms) and (high[i_msLen] - pl_ms) > atr * i_msATRMult and swingSzOk_pl

var int msTrend = 0

var line  ms_lastBullLine   = na
var label ms_lastBullLabel  = na
var line  ms_lastBearLine   = na
var label ms_lastBearLabel  = na

var float inBreakHiLevel = na
var float inBreakLoLevel = na
var int   inBreakHiBar   = na
var int   inBreakLoBar   = na
var int   inTrend        = 0
var line  ms_lastInBullLine   = na
var label ms_lastInBullLabel  = na
var line  ms_lastInBearLine   = na
var label ms_lastInBearLabel  = na

bool msVolOk = not i_msVolFilt or not hasVol or volume > volMA * 1.1

var float breakHiLevel = na
var float breakLoLevel = na
var int   breakHiBar   = na
var int   breakLoBar   = na

if phValid
    breakHiLevel := high[i_msLen]
    breakHiBar   := bar_index[i_msLen]

if plValid
    breakLoLevel := low[i_msLen]
    breakLoBar   := bar_index[i_msLen]

var int chochUpCount   = 0
var int chochDnCount   = 0

var bool bosEvent   = false
var bool chochEvent = false
bosEvent   := false
chochEvent := false

if i_showMS
    float dispUp = not na(breakHiLevel) ? breakHiLevel + atr * i_msDisplace : na
    float dispDn = not na(breakLoLevel) ? breakLoLevel - atr * i_msDisplace : na

    // ── BULLISH BREAK ──────────────────────────────────────
    if not na(breakHiLevel) and close > dispUp and msVolOk
        if msTrend == -1
            chochUpCount += 1
            if chochUpCount >= 2
                if i_msMode == "Present"
                    line.delete(ms_lastBullLine)
                    label.delete(ms_lastBullLabel)
                ms_lastBullLine := line.new(breakHiBar, breakHiLevel, bar_index, breakHiLevel,
                     color=i_colBull, style=line.style_solid, width=1)
                if i_showMSLbls
                    ms_lastBullLabel := label.new(int(math.avg(breakHiBar, bar_index)), breakHiLevel,
                         text="CHoCH", style=label.style_label_down,
                         color=color.new(color.white, 100),
                         textcolor=i_colBull, size=size.tiny)
                chochEvent    := true
                msTrend       := 1
                breakHiLevel  := na
                chochUpCount  := 0
        else
            chochUpCount := 0
            if i_msMode == "Present"
                line.delete(ms_lastBullLine)
                label.delete(ms_lastBullLabel)
            ms_lastBullLine := line.new(breakHiBar, breakHiLevel, bar_index, breakHiLevel,
                 color=i_colBull, style=line.style_solid, width=1)
            if i_showMSLbls
                ms_lastBullLabel := label.new(int(math.avg(breakHiBar, bar_index)), breakHiLevel,
                     text="BOS", style=label.style_label_down,
                     color=color.new(color.white, 100),
                     textcolor=i_colBull, size=size.tiny)
            bosEvent     := true
            msTrend      := 1
            breakHiLevel := na
    else
        chochUpCount := 0

    // ── BEARISH BREAK ──────────────────────────────────────
    if not na(breakLoLevel) and close < dispDn and msVolOk
        if msTrend == 1
            chochDnCount += 1
            if chochDnCount >= 2
                if i_msMode == "Present"
                    line.delete(ms_lastBearLine)
                    label.delete(ms_lastBearLabel)
                ms_lastBearLine := line.new(breakLoBar, breakLoLevel, bar_index, breakLoLevel,
                     color=i_colBear, style=line.style_solid, width=1)
                if i_showMSLbls
                    ms_lastBearLabel := label.new(int(math.avg(breakLoBar, bar_index)), breakLoLevel,
                         text="CHoCH", style=label.style_label_up,
                         color=color.new(color.white, 100),
                         textcolor=i_colBear, size=size.tiny)
                chochEvent    := true
                msTrend       := -1
                breakLoLevel  := na
                chochDnCount  := 0
        else
            chochDnCount := 0
            if i_msMode == "Present"
                line.delete(ms_lastBearLine)
                label.delete(ms_lastBearLabel)
            ms_lastBearLine := line.new(breakLoBar, breakLoLevel, bar_index, breakLoLevel,
                 color=i_colBear, style=line.style_solid, width=1)
            if i_showMSLbls
                ms_lastBearLabel := label.new(int(math.avg(breakLoBar, bar_index)), breakLoLevel,
                     text="BOS", style=label.style_label_up,
                     color=color.new(color.white, 100),
                     textcolor=i_colBear, size=size.tiny)
            bosEvent     := true
            msTrend      := -1
            breakLoLevel := na
    else
        chochDnCount := 0

// ══════════════════════════════════════════════════════════════
// ░░  SECTION 3A — INTERNAL STRUCTURE
// ══════════════════════════════════════════════════════════════
float ph_in = i_showInternalMS and i_showMS ? ta.pivothigh(high, i_msInternalLen, i_msInternalLen) : na
float pl_in = i_showInternalMS and i_showMS ? ta.pivotlow (low,  i_msInternalLen, i_msInternalLen) : na

if not na(ph_in)
    bool notDuplicate = na(breakHiLevel) or math.abs(high[i_msInternalLen] - breakHiLevel) > atr * 0.5
    if notDuplicate
        inBreakHiLevel := high[i_msInternalLen]
        inBreakHiBar   := bar_index[i_msInternalLen]

if not na(pl_in)
    bool notDuplicate = na(breakLoLevel) or math.abs(low[i_msInternalLen] - breakLoLevel) > atr * 0.5
    if notDuplicate
        inBreakLoLevel := low[i_msInternalLen]
        inBreakLoBar   := bar_index[i_msInternalLen]

var bool inBosEvent   = false
var bool inChochEvent = false
inBosEvent   := false
inChochEvent := false

if i_showInternalMS and i_showMS
    float inDispUp = not na(inBreakHiLevel) ? inBreakHiLevel + atr * i_msDisplace : na
    float inDispDn = not na(inBreakLoLevel) ? inBreakLoLevel - atr * i_msDisplace : na

    if not na(inBreakHiLevel) and close > inDispUp and msVolOk and not bosEvent and not chochEvent
        string inTag = inTrend == -1 ? "iCHoCH" : "iBOS"
        if i_msMode == "Present"
            line.delete(ms_lastInBullLine)
            label.delete(ms_lastInBullLabel)
        ms_lastInBullLine := line.new(inBreakHiBar, inBreakHiLevel, bar_index, inBreakHiLevel,
             color=i_colInternalBull, style=line.style_dashed, width=1)
        if i_showMSLbls
            ms_lastInBullLabel := label.new(int(math.avg(inBreakHiBar, bar_index)), inBreakHiLevel,
                 text=inTag, style=label.style_label_down,
                 color=color.new(color.white, 100),
                 textcolor=i_colInternalBull, size=size.tiny)
        inTrend        := 1
        inBreakHiLevel := na
        inBosEvent     := inTag == "iBOS"
        inChochEvent   := inTag == "iCHoCH"

    if not na(inBreakLoLevel) and close < inDispDn and msVolOk and not bosEvent and not chochEvent
        string inTag = inTrend == 1 ? "iCHoCH" : "iBOS"
        if i_msMode == "Present"
            line.delete(ms_lastInBearLine)
            label.delete(ms_lastInBearLabel)
        ms_lastInBearLine := line.new(inBreakLoBar, inBreakLoLevel, bar_index, inBreakLoLevel,
             color=i_colInternalBear, style=line.style_dashed, width=1)
        if i_showMSLbls
            ms_lastInBearLabel := label.new(int(math.avg(inBreakLoBar, bar_index)), inBreakLoLevel,
                 text=inTag, style=label.style_label_up,
                 color=color.new(color.white, 100),
                 textcolor=i_colInternalBear, size=size.tiny)
        inTrend        := -1
        inBreakLoLevel := na
        inBosEvent     := inTag == "iBOS"
        inChochEvent   := inTag == "iCHoCH"

// ══════════════════════════════════════════════════════════════
// ░░  SECTION 3B — SWING FAILURE PATTERN (SFP)
// ══════════════════════════════════════════════════════════════
float candleRange = math.max(high - low, syminfo.mintick)
float upperWick   = high - math.max(open, close)
float lowerWick   = math.min(open, close) - low

float ph_sfp = i_showSFP ? ta.pivothigh(high, i_sfpLen, i_sfpLen) : na
float pl_sfp = i_showSFP ? ta.pivotlow (low,  i_sfpLen, i_sfpLen) : na

float sfpRefHi = ta.valuewhen(not na(ph_sfp), ph_sfp, 0)
float sfpRefLo = ta.valuewhen(not na(pl_sfp), pl_sfp, 0)

int   sfpRefHiBar = ta.valuewhen(not na(ph_sfp), bar_index[i_sfpLen], 0)
int   sfpRefLoBar = ta.valuewhen(not na(pl_sfp), bar_index[i_sfpLen], 0)

bool sfpHiValid = not na(sfpRefHi) and (bar_index - sfpRefHiBar) <= i_sfpLookbk
bool sfpLoValid = not na(sfpRefLo) and (bar_index - sfpRefLoBar) <= i_sfpLookbk

bool trendOkBear = not i_sfpTrend or close > ema1
bool trendOkBull = not i_sfpTrend or close < ema1
bool sfpVolOk    = not i_sfpVolConf or not hasVol or volume > volMA

bool sweepDepthOkBear = i_sfpSweepMult <= 0 or (high - sfpRefHi) > atr * i_sfpSweepMult
bool sweepDepthOkBull = i_sfpSweepMult <= 0 or (sfpRefLo - low)  > atr * i_sfpSweepMult

bool sfpBearRaw = i_showSFP
     and sfpHiValid
     and high      >  sfpRefHi
     and close     <  sfpRefHi
     and upperWick >  atr * i_sfpATRMult
     and upperWick >  candleRange * i_sfpWickPct
     and sweepDepthOkBear
     and trendOkBear
     and sfpVolOk

bool sfpBullRaw = i_showSFP
     and sfpLoValid
     and low       <  sfpRefLo
     and close     >  sfpRefLo
     and lowerWick >  atr * i_sfpATRMult
     and lowerWick >  candleRange * i_sfpWickPct
     and sweepDepthOkBull
     and trendOkBull
     and sfpVolOk

var bool  pendingBearSFP  = false
var bool  pendingBullSFP  = false
var int   pendingBearBar  = na
var int   pendingBullBar  = na
var float pendingBearRef  = na
var float pendingBullRef  = na

bool sfpBear = false
bool sfpBull = false

if i_sfpCISD
    if sfpBearRaw and not pendingBearSFP
        pendingBearSFP  := true
        pendingBearBar  := bar_index
        pendingBearRef  := sfpRefHi
    if sfpBullRaw and not pendingBullSFP
        pendingBullSFP  := true
        pendingBullBar  := bar_index
        pendingBullRef  := sfpRefLo
    if pendingBearSFP and bar_index == pendingBearBar + 1
        sfpBear        := close < pendingBearRef
        pendingBearSFP := false
    if pendingBullSFP and bar_index == pendingBullBar + 1
        sfpBull        := close > pendingBullRef
        pendingBullSFP := false
else
    sfpBear := sfpBearRaw
    sfpBull := sfpBullRaw

int barsSinceBosUp = ta.barssince(bosEvent   and msTrend == 1)
int barsSinceCHUp  = ta.barssince(chochEvent and msTrend == 1)
int barsSinceBosDn = ta.barssince(bosEvent   and msTrend == -1)
int barsSinceCHDn  = ta.barssince(chochEvent and msTrend == -1)

bool bullStructNearby = barsSinceBosUp <= i_sfpConfluenceBars or barsSinceCHUp <= i_sfpConfluenceBars
bool bearStructNearby = barsSinceBosDn <= i_sfpConfluenceBars or barsSinceCHDn <= i_sfpConfluenceBars

bool sfpBearStrong = sfpBear and bearStructNearby
bool sfpBullStrong = sfpBull and bullStructNearby

bool sfpBearShow = i_sfpBosConfluence ? sfpBearStrong : sfpBear
bool sfpBullShow = i_sfpBosConfluence ? sfpBullStrong : sfpBull

plotshape(sfpBearShow ? high : na, "Bear SFP Dot",
     style=shape.circle, location=location.absolute,
     color=i_sfpBearCol, size=size.small)

plotshape(sfpBullShow ? low : na, "Bull SFP Dot",
     style=shape.circle, location=location.absolute,
     color=i_sfpBullCol, size=size.small)

plotshape(sfpBearStrong ? high : na, "Bear SFP Star (Strong)",
     style=shape.labelup, location=location.absolute,
     text="★", color=color.new(color.white, 100), textcolor=i_sfpStrongCol, size=size.small)

plotshape(sfpBullStrong ? low : na, "Bull SFP Star (Strong)",
     style=shape.labeldown, location=location.absolute,
     text="★", color=color.new(color.white, 100), textcolor=i_sfpStrongCol, size=size.small)

if sfpBearShow
    int midX = int(math.avg(sfpRefHiBar, bar_index))
    line.new(sfpRefHiBar, sfpRefHi, bar_index, sfpRefHi,
         color=color.new(#f2da06, 0), style=line.style_solid, width=1)
    label.new(midX, sfpRefHi, text=sfpBearStrong ? "SFP ★" : "SFP",
         color=color.new(#ff4c4c, 100), style=label.style_label_up,
         textcolor=#f2da06, size=size.tiny)

if sfpBullShow
    int midX = int(math.avg(sfpRefLoBar, bar_index))
    line.new(sfpRefLoBar, sfpRefLo, bar_index, sfpRefLo,
         color=color.new(#ffffff, 0), style=line.style_solid, width=1)
    label.new(midX, sfpRefLo, text=sfpBullStrong ? "SFP ★" : "SFP",
         color=color.new(#ffffff, 100), style=label.style_label_up,
         textcolor=#ffffff, size=size.tiny)

// ══════════════════════════════════════════════════════════════
// ░░  SECTION 3C — VWAP
// ══════════════════════════════════════════════════════════════
bool vwapNewAnchor =
     i_vwapType == "Week"  ? isNewWeek    :
     i_vwapType == "Month" ? ta.change(time("M")) != 0 :
     isNewSession

float vwapSrc = i_vwapSource == "Close" ? close : i_vwapSource == "OHLC4" ? ohlc4 : hlc3

var float vwap_cumPV  = 0.0
var float vwap_cumV   = 0.0
var float vwap_cumPV2 = 0.0
if vwapNewAnchor
    vwap_cumPV  := vwapSrc * vpVol
    vwap_cumV   := vpVol
    vwap_cumPV2 := vwapSrc * vwapSrc * vpVol
else
    vwap_cumPV  += vwapSrc * vpVol
    vwap_cumV   += vpVol
    vwap_cumPV2 += vwapSrc * vwapSrc * vpVol

float vwapVal    = vwap_cumV > 0 ? vwap_cumPV / vwap_cumV : hlc3
float vwapVar    = vwap_cumV > 0 ? math.max(vwap_cumPV2 / vwap_cumV - vwapVal * vwapVal, 0.0) : 0.0
float vwapStdDev = math.sqrt(vwapVar)

float vwapUp1 = vwapVal + vwapStdDev
float vwapDn1 = vwapVal - vwapStdDev
float vwapUp2 = vwapVal + vwapStdDev * 2
float vwapDn2 = vwapVal - vwapStdDev * 2

color vwapLineCol = i_showVWAP ? (close >= vwapVal ? i_vwapBull : i_vwapBear) : na

pVwap   = plot(i_showVWAP ? vwapVal : na, "VWAP",    color=vwapLineCol,  linewidth=i_vwapLW, style=plot.style_line)
pVwapU1 = plot(i_showVWAP and i_showVWAPBands ? vwapUp1 : na, "VWAP +1σ", color=i_vwap1Col, linewidth=1, style=plot.style_line)
pVwapD1 = plot(i_showVWAP and i_showVWAPBands ? vwapDn1 : na, "VWAP -1σ", color=i_vwap1Col, linewidth=1, style=plot.style_line)
plot(i_showVWAP and i_showVWAPBands ? vwapUp2 : na, "VWAP +2σ", color=i_vwap2Col, linewidth=1, style=plot.style_line)
plot(i_showVWAP and i_showVWAPBands ? vwapDn2 : na, "VWAP -2σ", color=i_vwap2Col, linewidth=1, style=plot.style_line)

fill(pVwap, pVwapU1, i_showVWAP and i_showVWAPBands and i_vwapZoneFill ? i_vwapZoneCol : na)
fill(pVwap, pVwapD1, i_showVWAP and i_showVWAPBands and i_vwapZoneFill ? i_vwapZoneCol : na)

// ══════════════════════════════════════════════════════════════
// ░░  SECTION 5 — VOLUME PROFILE ENGINE
// ══════════════════════════════════════════════════════════════
// WHY THIS WAS REBUILT
//
// The old engine kept a fixed-length array of rows stretched across the
// profile's current high-low range. Every time price made a new
// extreme, the range grew, every row changed height, and f_vpRebucket()
// dumped each old row's volume into whichever new row its midpoint
// happened to land in. That is lossy, and it compounds: a trending day
// might rebucket twenty times, and by the close the early volume has
// been smeared across rows it never traded in. Worse, volume added at
// 9:30 was binned at a different row height than volume added at 15:30,
// so the profile was not internally consistent.
//
// This version uses an ABSOLUTE price grid. Row index is simply
// floor(price / rowHeight), so a row covers the same prices from the
// first bar to the last and no rebucketing ever happens. Rows are held
// in a map keyed by that index, which means only rows price actually
// traded in consume memory and the grid can extend in either direction
// without limit. Row height is chosen once when a profile starts and
// then frozen.
//
// Net effect: zero smearing, no rebucket pass, no full-array scans, and
// the POC is tracked incrementally as volume is added rather than being
// re-derived by looping every row on every bar.
// ══════════════════════════════════════════════════════════════

f_vpNew() =>
    VProfile.new(bins = map.new<int, float>(), binSz = syminfo.mintick, pocVol = 0.0, total = 0.0)

f_vpReset(VProfile p, float binSz, int anchorBar) =>
    map.clear(p.bins)
    p.binSz  := math.max(binSz, syminfo.mintick)
    p.minBin := na
    p.maxBin := na
    p.pocBin := na
    p.pocVol := 0.0
    p.total  := 0.0
    p.anchor := anchorBar
    p.poc    := na
    p.vah    := na
    p.val    := na

// Signed, so the same routine both adds a bar and removes one that has
// aged out of a rolling window.
f_vpPut(VProfile p, int k, float v) =>
    if v != 0
        float nv = nz(map.get(p.bins, k)) + v
        if nv <= 1e-9
            map.remove(p.bins, k)
        else
            map.put(p.bins, k, nv)
        p.total := math.max(p.total + v, 0.0)
        if v > 0
            p.minBin := na(p.minBin) ? k : math.min(p.minBin, k)
            p.maxBin := na(p.maxBin) ? k : math.max(p.maxBin, k)
            if nv > p.pocVol
                p.pocVol := nv
                p.pocBin := k

f_vpAdd(VProfile p, float hi, float lo, float vol, float px) =>
    float bs = p.binSz
    if bs > 0 and vol != 0 and not na(hi) and not na(lo)
        if i_vpCalcMethod == "Single Price (HLC3)"
            f_vpPut(p, int(math.floor(px / bs)), vol)
        else
            int kL = int(math.floor(lo / bs))
            int kH = int(math.floor(hi / bs))
            if kH <= kL
                f_vpPut(p, kL, vol)
            else if kH - kL > 1000
                // Absurd row height relative to the bar; collapse rather
                // than run a million-iteration loop.
                f_vpPut(p, int(math.floor(math.avg(hi, lo) / bs)), vol)
            else
                float rng = math.max(hi - lo, syminfo.mintick)
                for k = kL to kH
                    float bLo  = k * bs
                    float ovLo = math.max(lo, bLo)
                    float ovHi = math.min(hi, bLo + bs)
                    if ovHi > ovLo
                        f_vpPut(p, k, vol * (ovHi - ovLo) / rng)

// Only needed after a subtraction, since removing volume can invalidate
// a POC that was tracked as a running maximum.
f_vpRescan(VProfile p) =>
    p.pocBin := na
    p.pocVol := 0.0
    p.minBin := na
    p.maxBin := na
    array<int> ks = map.keys(p.bins)
    if array.size(ks) > 0
        for i = 0 to array.size(ks) - 1
            int   k = array.get(ks, i)
            float v = nz(map.get(p.bins, k))
            p.minBin := na(p.minBin) ? k : math.min(p.minBin, k)
            p.maxBin := na(p.maxBin) ? k : math.max(p.maxBin, k)
            if v > p.pocVol
                p.pocVol := v
                p.pocBin := k

// Value area by the standard market-profile rule: from the POC, compare
// the next TWO rows above against the next TWO rows below and take the
// heavier pair. The old code compared one row at a time, which drifts
// from the conventional VAH/VAL that every other profile tool reports.
f_vpCompute(VProfile p, float vaPct) =>
    if not na(p.pocBin) and p.total > 0
        float bs = p.binSz
        p.poc := (p.pocBin + 0.5) * bs
        float tgt = p.total * vaPct / 100.0
        float acc = p.pocVol
        int   hiK = p.pocBin
        int   loK = p.pocBin
        int   guard = math.min(p.maxBin - p.minBin + 2, 2000)
        if guard > 0
            for _i = 1 to guard
                if acc >= tgt
                    break
                bool canUp = hiK < p.maxBin
                bool canDn = loK > p.minBin
                if not canUp and not canDn
                    break
                float up = 0.0
                if canUp
                    up := nz(map.get(p.bins, hiK + 1)) + (hiK + 2 <= p.maxBin ? nz(map.get(p.bins, hiK + 2)) : 0.0)
                float dn = 0.0
                if canDn
                    dn := nz(map.get(p.bins, loK - 1)) + (loK - 2 >= p.minBin ? nz(map.get(p.bins, loK - 2)) : 0.0)
                if canUp and (not canDn or up >= dn)
                    hiK += 1
                    acc += nz(map.get(p.bins, hiK))
                    if acc < tgt and hiK < p.maxBin
                        hiK += 1
                        acc += nz(map.get(p.bins, hiK))
                else if canDn
                    loK -= 1
                    acc += nz(map.get(p.bins, loK))
                    if acc < tgt and loK > p.minBin
                        loK -= 1
                        acc += nz(map.get(p.bins, loK))
                else
                    break
        p.vah := (hiK + 1) * bs
        p.val := loK * bs

// Row height is picked once per profile and frozen. In Auto mode it is
// derived from a representative range for that profile so "60 rows"
// still means roughly what you expect, but because the grid is absolute
// an unusually wide session just uses more rows instead of forcing every
// earlier row to be recalculated.
f_binSize(float seedRange) =>
    float r = na(seedRange) or seedRange <= 0 ? atr * 20 : seedRange
    i_vpRowMode == "Fixed Ticks per Row" ? syminfo.mintick * i_vpTicksPerRow
         : math.max(r / i_vpRows, syminfo.mintick)

// ── Reference ranges used to size rows, and the daily bars that feed
//    the long-term profile. [1] with lookahead_on gives the completed
//    previous period, which is the safe idiom.
float prevWeekRange = request.security(syminfo.tickerid, "W", high[1] - low[1], lookahead = barmerge.lookahead_on)
[dHi1, dLo1, dVol1] = request.security(syminfo.tickerid, "D", [high[1], low[1], volume[1]], lookahead = barmerge.lookahead_on)
float ltSeedRange   = request.security(syminfo.tickerid, "D",
     ta.highest(high, i_ltDays) - ta.lowest(low, i_ltDays), lookahead = barmerge.lookahead_on)


var VProfile dayProf  = f_vpNew()
var VProfile weekProf = f_vpNew()
var VProfile struProf = f_vpNew()
var VProfile ltProf   = f_vpNew()

// ── A) DAY PROFILE ─────────────────────────────────────────────
var int   sess_dayCount = 0
var float prev_POC      = na
var float prev_VAH      = na
var float prev_VAL      = na
var int   prev_anchor   = na

if i_vpEnabled and (i_showSessionVP or i_showPrevVP) and barstate.isconfirmed
    bool dayBoundary = false
    if isNewSession
        sess_dayCount += 1
        if sess_dayCount >= i_dayVPDays
            dayBoundary   := true
            sess_dayCount := 0

    if dayBoundary or na(dayProf.anchor)
        if not na(dayProf.poc)
            prev_POC    := dayProf.poc
            prev_VAH    := dayProf.vah
            prev_VAL    := dayProf.val
            prev_anchor := dayProf.anchor
        f_vpReset(dayProf, f_binSize(prevDayRange), bar_index)

    f_vpAdd(dayProf, high, low, vpVol, hlc3)
    f_vpCompute(dayProf, i_vpValueAreaPct)

// ── B) WEEKLY PROFILE ──────────────────────────────────────────
if i_vpEnabled and i_showWeeklyVP and barstate.isconfirmed
    if isNewWeek or na(weekProf.anchor)
        f_vpReset(weekProf, f_binSize(prevWeekRange), bar_index)
    f_vpAdd(weekProf, high, low, vpVol, hlc3)
    f_vpCompute(weekProf, i_vpValueAreaPct)

// ── C) STRUCTURE PROFILE ───────────────────────────────────────
if i_vpEnabled and i_showStructVP and barstate.isconfirmed
    if bosEvent or chochEvent or na(struProf.anchor)
        f_vpReset(struProf, f_binSize(atr * 20), bar_index)
    f_vpAdd(struProf, high, low, vpVol, hlc3)
    f_vpCompute(struProf, i_vpValueAreaPct)

// ── D) LONG-TERM ROLLING POC ───────────────────────────────────
// Built from completed DAILY bars rather than chart bars. One value is
// added per day and the day that falls out of the window is subtracted,
// so this is a genuine rolling profile: it drifts instead of jumping,
// it costs one update per day instead of one per bar, and it returns
// the same price on every chart timeframe.
var array<float> ltHi  = array.new<float>()
var array<float> ltLo  = array.new<float>()
var array<float> ltVol = array.new<float>()

if i_vpEnabled and i_showYearlyPOC and barstate.isconfirmed and isNewSession and not na(dHi1)
    if na(ltProf.anchor)
        f_vpReset(ltProf, f_binSize(ltSeedRange), bar_index)

    float dv = nz(dVol1, 1.0) <= 0 ? 1.0 : nz(dVol1, 1.0)
    f_vpAdd(ltProf, dHi1, dLo1, dv, math.avg(dHi1, dLo1))
    array.push(ltHi,  dHi1)
    array.push(ltLo,  dLo1)
    array.push(ltVol, dv)

    if array.size(ltHi) > i_ltDays
        float oH = array.shift(ltHi)
        float oL = array.shift(ltLo)
        float oV = array.shift(ltVol)
        f_vpAdd(ltProf, oH, oL, -oV, math.avg(oH, oL))
        f_vpRescan(ltProf)

    ltProf.poc := na(ltProf.pocBin) ? na : (ltProf.pocBin + 0.5) * ltProf.binSz

// ── Aliases used by the drawing and alert sections ─────────────
float sess_POC = dayProf.poc
float sess_VAH = dayProf.vah
float sess_VAL = dayProf.val
float week_POC = weekProf.poc
float week_VAH = weekProf.vah
float week_VAL = weekProf.val
float stru_POC = struProf.poc
float stru_VAH = struProf.vah
float stru_VAL = struProf.val
float year_POC = ltProf.poc
int   sess_anchor = dayProf.anchor
int   week_anchor = weekProf.anchor
int   stru_anchor = struProf.anchor

// ══════════════════════════════════════════════════════════════
// ░░  DRAWING HELPER — f_splitLine
// ══════════════════════════════════════════════════════════════
f_splitLine(y, lft, col, sty, lwd, txt, xOff) =>
    int _maxBack  = math.max(bar_index - 500, 0)
    int _safeLft  = lft < _maxBack ? _maxBack : (lft > bar_index ? bar_index : lft)
    line l1 = line.new(_safeLft, y, bar_index, y,
         xloc   = xloc.bar_index,
         color  = col,
         style  = sty,
         width  = lwd,
         extend = extend.right)
    label lb = label.new(bar_index + xOff, y,
         text      = txt,
         xloc      = xloc.bar_index,
         style     = label.style_none,
         textcolor = col,
         size      = size.tiny)
    [l1, lb]

int LANE_DAY    = i_lblRightPad
int LANE_PREV   = i_lblRightPad + i_lblLaneWidth
int LANE_WEEK   = i_lblRightPad + i_lblLaneWidth * 2
int LANE_STRUCT = i_lblRightPad + i_lblLaneWidth * 3
int LANE_YEAR   = i_lblRightPad + i_lblLaneWidth * 4

var line  ln_sPOC  = na
var label lb_sPOC  = na
var line  ln_sVAH  = na
var label lb_sVAH  = na
var line  ln_sVAL  = na
var label lb_sVAL  = na
var line  ln_pPOC  = na
var label lb_pPOC  = na
var line  ln_pVAH  = na
var label lb_pVAH  = na
var line  ln_pVAL  = na
var label lb_pVAL  = na
var line  ln_wPOC  = na
var label lb_wPOC  = na
var line  ln_wVAH  = na
var label lb_wVAH  = na
var line  ln_wVAL  = na
var label lb_wVAL  = na
var line  ln_tPOC  = na
var label lb_tPOC  = na
var line  ln_tVAH  = na
var label lb_tVAH  = na
var line  ln_tVAL  = na
var label lb_tVAL  = na
var line  ln_yPOC  = na
var label lb_yPOC  = na

if barstate.islast and i_vpEnabled
    line.delete(ln_sPOC)
    label.delete(lb_sPOC)
    line.delete(ln_sVAH)
    label.delete(lb_sVAH)
    line.delete(ln_sVAL)
    label.delete(lb_sVAL)
    line.delete(ln_pPOC)
    label.delete(lb_pPOC)
    line.delete(ln_pVAH)
    label.delete(lb_pVAH)
    line.delete(ln_pVAL)
    label.delete(lb_pVAL)
    line.delete(ln_wPOC)
    label.delete(lb_wPOC)
    line.delete(ln_wVAH)
    label.delete(lb_wVAH)
    line.delete(ln_wVAL)
    label.delete(lb_wVAL)
    line.delete(ln_tPOC)
    label.delete(lb_tPOC)
    line.delete(ln_tVAH)
    label.delete(lb_tVAH)
    line.delete(ln_tVAL)
    label.delete(lb_tVAL)
    line.delete(ln_yPOC)
    label.delete(lb_yPOC)

    int _maxLookback = math.max(bar_index - 500, 0)
    int sessLeft = na(sess_anchor) ? bar_index : (sess_anchor < _maxLookback ? _maxLookback : sess_anchor)
    int prevLeft = na(prev_anchor) ? bar_index : (prev_anchor < _maxLookback ? _maxLookback : prev_anchor)
    int weekLeft = na(week_anchor) ? bar_index : (week_anchor < _maxLookback ? _maxLookback : week_anchor)
    int struLeft = na(stru_anchor) ? bar_index : (stru_anchor < _maxLookback ? _maxLookback : stru_anchor)

    // ── Day profile ──────────────────────────────────────────
    if i_showSessionVP and not na(sess_POC)
        [a1, b1] = f_splitLine(sess_VAH, sessLeft, color.new(i_sessVAHCol,0), f_lineStyle(i_sessLineStyle), i_sessLineWidth, "VAH", LANE_DAY)
        ln_sVAH := a1
        lb_sVAH := b1
        [a2, b2] = f_splitLine(sess_POC, sessLeft, color.new(i_sessPOCCol,0), f_lineStyle(i_sessLineStyle), i_sessLineWidth + 1, "POC", LANE_DAY)
        ln_sPOC := a2
        lb_sPOC := b2
        [a3, b3] = f_splitLine(sess_VAL, sessLeft, color.new(i_sessVALCol,0), f_lineStyle(i_sessLineStyle), i_sessLineWidth, "VAL", LANE_DAY)
        ln_sVAL := a3
        lb_sVAL := b3

    // ── Previous session ─────────────────────────────────────
    if i_showPrevVP and not na(prev_POC)
        [a4, b4] = f_splitLine(prev_VAH, prevLeft, color.new(i_prevVAHCol,0), f_lineStyle(i_prevLineStyle), i_prevLineWidth, "pVAH", LANE_PREV)
        ln_pVAH := a4
        lb_pVAH := b4
        [a5, b5] = f_splitLine(prev_POC, prevLeft, color.new(i_prevPOCCol,0), f_lineStyle(i_prevLineStyle), i_prevLineWidth + 1, "pPOC", LANE_PREV)
        ln_pPOC := a5
        lb_pPOC := b5
        [a6, b6] = f_splitLine(prev_VAL, prevLeft, color.new(i_prevVALCol,0), f_lineStyle(i_prevLineStyle), i_prevLineWidth, "pVAL", LANE_PREV)
        ln_pVAL := a6
        lb_pVAL := b6

    // ── Weekly ───────────────────────────────────────────────
    if i_showWeeklyVP and not na(week_POC)
        [a7, b7] = f_splitLine(week_VAH, weekLeft, i_weekVAHCol, f_lineStyle(i_weekLineStyle), i_weekLineWidth, "Wk VAH", LANE_WEEK)
        ln_wVAH := a7
        lb_wVAH := b7
        [a8, b8] = f_splitLine(week_POC, weekLeft, i_weekPOCCol, f_lineStyle(i_weekLineStyle), i_weekLineWidth + 1, "Wk POC", LANE_WEEK)
        ln_wPOC := a8
        lb_wPOC := b8
        [a9, b9] = f_splitLine(week_VAL, weekLeft, i_weekVALCol, f_lineStyle(i_weekLineStyle), i_weekLineWidth, "Wk VAL", LANE_WEEK)
        ln_wVAL := a9
        lb_wVAL := b9

    // ── Structure ────────────────────────────────────────────
    if i_showStructVP and not na(stru_POC)
        [aA, bA] = f_splitLine(stru_VAH, struLeft, i_struVAHCol, f_lineStyle(i_struLineStyle), i_struLineWidth, "Str VAH", LANE_STRUCT)
        ln_tVAH := aA
        lb_tVAH := bA
        [aB, bB] = f_splitLine(stru_POC, struLeft, i_struPOCCol, f_lineStyle(i_struLineStyle), i_struLineWidth + 1, "Str POC", LANE_STRUCT)
        ln_tPOC := aB
        lb_tPOC := bB
        [aC, bC] = f_splitLine(stru_VAL, struLeft, i_struVALCol, f_lineStyle(i_struLineStyle), i_struLineWidth, "Str VAL", LANE_STRUCT)
        ln_tVAL := aC
        lb_tVAL := bC

    // ── 250-Day POC ──────────────────────────────────────────
    if i_showYearlyPOC and not na(year_POC)
        [aD, bD] = f_splitLine(year_POC, _maxLookback, i_yearlyPOCCol, f_lineStyle(i_yearLineStyle), i_yearLineWidth + 1, str.tostring(i_ltDays) + "D POC", LANE_YEAR)
        ln_yPOC := aD
        lb_yPOC := bD

// ══════════════════════════════════════════════════════════════
// ░░  LIVE PRICE BUBBLE
// ══════════════════════════════════════════════════════════════
var label lbl_price = na
label.delete(lbl_price)
if i_showPrice
    lbl_price := label.new(bar_index + 2, close,
         text      = i_priceEmoji,
         xloc      = xloc.bar_index,
         style     = f_labelStyle(i_priceStyle),
         color     = i_priceBg,
         textcolor = color.white,
         size      = size.normal)

// ══════════════════════════════════════════════════════════════
// ░░  SECTION 6 — MULTI-TRENDLINE ENGINE
// ══════════════════════════════════════════════════════════════
// Pivot memory: the last i_tlPool confirmed swing highs and lows, kept
// as (bar, price) pairs. On every new pivot the engine tests each older
// pivot as a possible anchor, discards candidates that cut through the
// pivots in between, scores the survivors on touches then length, and
// draws the winner. A pool of up to i_tlMaxEach lines is kept per side;
// the oldest is deleted when a new one arrives.
// ══════════════════════════════════════════════════════════════
var array<int>   tlPhBar = array.new<int>()
var array<float> tlPhPx  = array.new<float>()
var array<int>   tlPlBar = array.new<int>()
var array<float> tlPlPx  = array.new<float>()

var array<TLine> tlResArr = array.new<TLine>()
var array<TLine> tlSupArr = array.new<TLine>()

float ph_tl = ta.pivothigh(high, i_tlPivLen, i_tlPivLen)
float pl_tl = ta.pivotlow (low,  i_tlPivLen, i_tlPivLen)

float tlTol = atr * i_tlTolATR

// ── RESISTANCE (through swing highs) ────────────────────────
if not na(ph_tl)
    int   bNew = bar_index - i_tlPivLen
    float pNew = ph_tl
    int   n    = array.size(tlPhBar)

    int   bestOldBar = na
    float bestOldPx  = na
    float bestScore  = -1.0
    int   bestTouch  = 0

    if i_showTL and n > 0
        for j = 0 to n - 1
            int   bOld = array.get(tlPhBar, j)
            float pOld = array.get(tlPhPx,  j)
            int   dx   = bNew - bOld
            bool  dirOk = not i_tlDirOnly or pOld > pNew
            if dx >= i_tlMinBars and dirOk
                float sl    = (pNew - pOld) / dx
                int   touch = 0
                int   viol  = 0
                for k = 0 to n - 1
                    int   bk = array.get(tlPhBar, k)
                    float pk = array.get(tlPhPx,  k)
                    if bk >= bOld and bk <= bNew
                        float lv = pOld + sl * (bk - bOld)
                        float d  = pk - lv
                        if d > tlTol
                            viol += 1
                        else if math.abs(d) <= tlTol
                            touch += 1
                touch += 1  // count the new pivot itself
                if viol <= i_tlMaxViol and touch >= i_tlMinTouch
                    float score = touch * 100000.0 + dx
                    if score > bestScore
                        bestScore  := score
                        bestOldBar := bOld
                        bestOldPx  := pOld
                        bestTouch  := touch

    if i_showTL and not na(bestOldBar)
        line nl = line.new(bestOldBar, bestOldPx, bNew, pNew,
             xloc   = xloc.bar_index,
             color  = i_tlBearCol,
             width  = i_tlWidth,
             style  = f_lineStyle(i_tlStyle),
             extend = i_tlExtend ? extend.right : extend.none)
        label nlb = na
        if i_tlShowTouch
            nlb := label.new(bNew, pNew, text=str.tostring(bestTouch) + "T",
                 xloc      = xloc.bar_index,
                 style     = label.style_none,
                 textcolor = i_tlBearCol,
                 size      = size.tiny)
        array.push(tlResArr, TLine.new(ln = nl, lb = nlb))
        if array.size(tlResArr) > i_tlMaxEach
            TLine drop = array.shift(tlResArr)
            line.delete(drop.ln)
            label.delete(drop.lb)

    array.push(tlPhBar, bNew)
    array.push(tlPhPx,  pNew)
    if array.size(tlPhBar) > i_tlPool
        array.shift(tlPhBar)
        array.shift(tlPhPx)

// ── SUPPORT (through swing lows) ────────────────────────────
if not na(pl_tl)
    int   bNew = bar_index - i_tlPivLen
    float pNew = pl_tl
    int   n    = array.size(tlPlBar)

    int   bestOldBar = na
    float bestOldPx  = na
    float bestScore  = -1.0
    int   bestTouch  = 0

    if i_showTL and n > 0
        for j = 0 to n - 1
            int   bOld = array.get(tlPlBar, j)
            float pOld = array.get(tlPlPx,  j)
            int   dx   = bNew - bOld
            bool  dirOk = not i_tlDirOnly or pOld < pNew
            if dx >= i_tlMinBars and dirOk
                float sl    = (pNew - pOld) / dx
                int   touch = 0
                int   viol  = 0
                for k = 0 to n - 1
                    int   bk = array.get(tlPlBar, k)
                    float pk = array.get(tlPlPx,  k)
                    if bk >= bOld and bk <= bNew
                        float lv = pOld + sl * (bk - bOld)
                        float d  = lv - pk
                        if d > tlTol
                            viol += 1
                        else if math.abs(d) <= tlTol
                            touch += 1
                touch += 1
                if viol <= i_tlMaxViol and touch >= i_tlMinTouch
                    float score = touch * 100000.0 + dx
                    if score > bestScore
                        bestScore  := score
                        bestOldBar := bOld
                        bestOldPx  := pOld
                        bestTouch  := touch

    if i_showTL and not na(bestOldBar)
        line nl = line.new(bestOldBar, bestOldPx, bNew, pNew,
             xloc   = xloc.bar_index,
             color  = i_tlBullCol,
             width  = i_tlWidth,
             style  = f_lineStyle(i_tlStyle),
             extend = i_tlExtend ? extend.right : extend.none)
        label nlb = na
        if i_tlShowTouch
            nlb := label.new(bNew, pNew, text=str.tostring(bestTouch) + "T",
                 xloc      = xloc.bar_index,
                 style     = label.style_none,
                 textcolor = i_tlBullCol,
                 size      = size.tiny)
        array.push(tlSupArr, TLine.new(ln = nl, lb = nlb))
        if array.size(tlSupArr) > i_tlMaxEach
            TLine drop = array.shift(tlSupArr)
            line.delete(drop.ln)
            label.delete(drop.lb)

    array.push(tlPlBar, bNew)
    array.push(tlPlPx,  pNew)
    if array.size(tlPlBar) > i_tlPool
        array.shift(tlPlBar)
        array.shift(tlPlPx)

// Clear everything if the user switches the feature off mid-session.
if not i_showTL and barstate.islast
    if array.size(tlResArr) > 0
        for ci = 0 to array.size(tlResArr) - 1
            TLine t = array.get(tlResArr, ci)
            line.delete(t.ln)
            label.delete(t.lb)
        array.clear(tlResArr)
    if array.size(tlSupArr) > 0
        for ci = 0 to array.size(tlSupArr) - 1
            TLine t = array.get(tlSupArr, ci)
            line.delete(t.ln)
            label.delete(t.lb)
        array.clear(tlSupArr)

// ══════════════════════════════════════════════════════════════
// ░░  SECTION 7 — SESSION CLOCKS (each in its own timezone)
// ══════════════════════════════════════════════════════════════
string TZ_SYD = "Australia/Sydney"
string TZ_TOK = "Asia/Tokyo"
string TZ_LON = "Europe/London"
string TZ_NY  = "America/New_York"

int sydNow = hour(time, TZ_SYD) * 60 + minute(time, TZ_SYD)
int tokNow = hour(time, TZ_TOK) * 60 + minute(time, TZ_TOK)
int lonNow = hour(time, TZ_LON) * 60 + minute(time, TZ_LON)
int nyNow  = hour(time, TZ_NY)  * 60 + minute(time, TZ_NY)

int sydOpenM  = i_sydSH * 60 + i_sydSM
int sydCloseM = i_sydEH * 60 + i_sydEM
int tokOpenM  = i_tokSH * 60 + i_tokSM
int tokCloseM = i_tokEH * 60 + i_tokEM
int lonOpenM  = i_lonSH * 60 + i_lonSM
int lonCloseM = i_lonEH * 60 + i_lonEM
int nyOpenM   = i_nySH  * 60 + i_nySM
int nyCloseM  = i_nyEH  * 60 + i_nyEM

int sydDow = dayofweek(time, TZ_SYD)
int tokDow = dayofweek(time, TZ_TOK)
int lonDow = dayofweek(time, TZ_LON)
int nyDow  = dayofweek(time, TZ_NY)

bool sydWkOk = not i_sessSkipWknd or (sydDow != dayofweek.saturday and sydDow != dayofweek.sunday)
bool tokWkOk = not i_sessSkipWknd or (tokDow != dayofweek.saturday and tokDow != dayofweek.sunday)
bool lonWkOk = not i_sessSkipWknd or (lonDow != dayofweek.saturday and lonDow != dayofweek.sunday)
bool nyWkOk  = not i_sessSkipWknd or (nyDow  != dayofweek.saturday and nyDow  != dayofweek.sunday)

bool sydActive = sydWkOk and f_sessActive(sydNow, sydOpenM, sydCloseM)
bool tokActive = tokWkOk and f_sessActive(tokNow, tokOpenM, tokCloseM)
bool lonActive = lonWkOk and f_sessActive(lonNow, lonOpenM, lonCloseM)
bool nyActive  = nyWkOk  and f_sessActive(nyNow,  nyOpenM,  nyCloseM)

// Each session's open as an ABSOLUTE timestamp for the current day in
// its own timezone. Working in timestamps rather than in minute-of-day
// is what makes the open independent of chart timeframe: a bar-start
// comparison fires late on any timeframe coarser than the open minute
// (on 1H the 9:00 bar contains a 9:30 open but its start minute is 0,
// so the old test only fired on the 10:00 bar, an hour late).
int sydOpenT = timestamp(TZ_SYD, year(time, TZ_SYD), month(time, TZ_SYD), dayofmonth(time, TZ_SYD), i_sydSH, i_sydSM, 0)
int tokOpenT = timestamp(TZ_TOK, year(time, TZ_TOK), month(time, TZ_TOK), dayofmonth(time, TZ_TOK), i_tokSH, i_tokSM, 0)
int lonOpenT = timestamp(TZ_LON, year(time, TZ_LON), month(time, TZ_LON), dayofmonth(time, TZ_LON), i_lonSH, i_lonSM, 0)
int nyOpenT  = timestamp(TZ_NY,  year(time, TZ_NY),  month(time, TZ_NY),  dayofmonth(time, TZ_NY),  i_nySH,  i_nySM,  0)

// Fires on the bar that CONTAINS the open, whatever size that bar is.
bool sydOpenTrig = sydWkOk and time_close > sydOpenT and time_close[1] <= sydOpenT
bool tokOpenTrig = tokWkOk and time_close > tokOpenT and time_close[1] <= tokOpenT
bool lonOpenTrig = lonWkOk and time_close > lonOpenT and time_close[1] <= lonOpenT
bool nyOpenTrig  = nyWkOk  and time_close > nyOpenT  and time_close[1] <= nyOpenT

// ══════════════════════════════════════════════════════════════
// ░░  SECTION 8 — OPENING RANGE BREAKOUT (ORB)
// ══════════════════════════════════════════════════════════════
// The opening range is built from bars of i_orbLtf rather than from the
// chart's own bars, so a 15-minute range stays a true 15 minutes on a
// 1H or 4H chart instead of collapsing into whatever that one large
// candle happened to do. The window itself is a pair of absolute
// timestamps, so nothing about it depends on chart timeframe.
//
// request.security_lower_tf returns every intrabar inside the current
// chart bar; we keep only those whose timestamp falls inside the
// window. TradingView serves intrabar data for recent history only, so
// when the arrays come back empty the chart bar is used as a fallback.
// ══════════════════════════════════════════════════════════════
int orbWindowMins = i_orbRange == "5 min" ? 5 : i_orbRange == "30 min" ? 30 : i_orbRange == "60 min" ? 60 : 15
int orbWindowMs   = orbWindowMins * 60000
int orbExtendMs   = int(i_orbExtendHrs * 3600000)

// Clamp: request.security_lower_tf rejects a timeframe above the chart's.
string orbLtfEff = timeframe.in_seconds(i_orbLtf) <= timeframe.in_seconds() ? i_orbLtf : timeframe.period
[orbLtfH, orbLtfL, orbLtfT] = request.security_lower_tf(syminfo.tickerid, orbLtfEff, [high, low, time])

// High/low of everything that traded between wStart and wEnd on this bar.
f_orbRange(int wStart, int wEnd) =>
    float rh = na
    float rl = na
    int   n  = array.size(orbLtfT)
    if n > 0
        for i = 0 to n - 1
            int t = array.get(orbLtfT, i)
            if t >= wStart and t < wEnd
                float h = array.get(orbLtfH, i)
                float l = array.get(orbLtfL, i)
                rh := na(rh) ? h : math.max(rh, h)
                rl := na(rl) ? l : math.min(rl, l)
    else if time < wEnd and time_close > wStart
        rh := high
        rl := low
    [rh, rl]

bool orbFired =
     (i_orbNY  and nyOpenTrig)  or
     (i_orbLon and lonOpenTrig) or
     (i_orbSyd and sydOpenTrig) or
     (i_orbTok and tokOpenTrig)

int orbFiredOpenT =
     (i_orbNY  and nyOpenTrig)  ? nyOpenT  :
     (i_orbLon and lonOpenTrig) ? lonOpenT :
     (i_orbSyd and sydOpenTrig) ? sydOpenT :
     (i_orbTok and tokOpenTrig) ? tokOpenT : int(na)

var box[]   orbBoxes    = array.new_box()
var line[]  orbMidLines = array.new_line()
var float[] orbHighs    = array.new_float()
var float[] orbLows     = array.new_float()
var int[]   orbStates   = array.new_int()
var int[]   orbStartT   = array.new_int()
var bool[]  orbLocked   = array.new_bool()

if i_showORB and orbFired and not na(orbFiredOpenT)
    int   startT = orbFiredOpenT
    int   rightT = startT + orbWindowMs + orbExtendMs
    [ih, il] = f_orbRange(startT, startT + orbWindowMs)
    float h0 = na(ih) ? high : ih
    float l0 = na(il) ? low  : il
    array.push(orbBoxes, box.new(startT, h0, rightT, l0,
         xloc         = xloc.bar_time,
         bgcolor      = i_orbFillCol,
         border_color = i_orbBordCol,
         border_width = 1))
    array.push(orbMidLines, line.new(startT, math.avg(h0, l0), rightT, math.avg(h0, l0),
         xloc  = xloc.bar_time,
         color = i_orbMid ? i_orbMidCol : color.new(color.white, 100),
         style = line.style_dashed,
         width = 1))
    array.push(orbHighs,  h0)
    array.push(orbLows,   l0)
    array.push(orbStates, 0)
    array.push(orbStartT, startT)
    array.push(orbLocked, false)

if i_showORB and array.size(orbBoxes) > 0
    for idx = 0 to array.size(orbBoxes) - 1
        int   st     = array.get(orbStates, idx)
        float orH    = array.get(orbHighs,  idx)
        float orL    = array.get(orbLows,   idx)
        int   startT = array.get(orbStartT, idx)
        bool  locked = array.get(orbLocked, idx)
        bx           = array.get(orbBoxes,  idx)
        ml           = array.get(orbMidLines, idx)

        int  endT       = startT + orbWindowMs
        bool windowOver = time >= endT

        if not locked
            // Only the high/low still move; the right edge was set to its
            // final projected position when the box was created.
            [wh, wl] = f_orbRange(startT, endT)
            if not na(wh)
                float newH = math.max(orH, wh)
                float newL = math.min(orL, wl)
                array.set(orbHighs, idx, newH)
                array.set(orbLows,  idx, newL)
                box.set_top(bx,    newH)
                box.set_bottom(bx, newL)
                line.set_y1(ml, math.avg(newH, newL))
                line.set_y2(ml, math.avg(newH, newL))
            if windowOver
                array.set(orbLocked, idx, true)
                locked := true

        if locked and st == 0
            if close > orH
                array.set(orbStates, idx, 1)
                box.set_bgcolor(bx,      i_orbBullCol)
                box.set_border_color(bx, i_orbBullBord)
            else if close < orL
                array.set(orbStates, idx, -1)
                box.set_bgcolor(bx,      i_orbBearCol)
                box.set_border_color(bx, i_orbBearBord)

while array.size(orbBoxes) > i_orbCount
    box.delete(array.shift(orbBoxes))
    line.delete(array.shift(orbMidLines))
    array.shift(orbHighs)
    array.shift(orbLows)
    array.shift(orbStates)
    array.shift(orbStartT)
    array.shift(orbLocked)

// ══════════════════════════════════════════════════════════════
// ░░  SECTION 9 — SESSION DASHBOARD
// ══════════════════════════════════════════════════════════════
int sd_localH = hour(time,   i_sdLocalTZ)
int sd_localM = minute(time, i_sdLocalTZ)
string sd_localTimeStr = f_fmtClock(sd_localH, sd_localM)

string sd_activeName  = "Off Hours"
color  sd_activeColor = color.new(#888888, 0)

if lonActive and nyActive
    sd_activeName  := "London / NY"
    sd_activeColor := color.new(#9C71F7, 0)
else if nyActive
    sd_activeName  := "New York"
    sd_activeColor := color.new(#81C784, 0)
else if lonActive
    sd_activeName  := "London"
    sd_activeColor := color.new(#4FC3F7, 0)
else if tokActive
    sd_activeName  := "Tokyo"
    sd_activeColor := color.new(#FF6B6B, 0)
else if sydActive
    sd_activeName  := "Sydney"
    sd_activeColor := color.new(#FFD700, 0)

// Minutes remaining in whichever session is active. All four clocks
// describe the same instant, so each session's own local arithmetic is
// directly comparable.
int sd_minsLeft =
     (lonActive and nyActive) ? f_minsUntil(nyNow,  nyCloseM)  :
     nyActive                ? f_minsUntil(nyNow,  nyCloseM)   :
     lonActive               ? f_minsUntil(lonNow, lonCloseM)  :
     tokActive               ? f_minsUntil(tokNow, tokCloseM)  :
     sydActive               ? f_minsUntil(sydNow, sydCloseM)  : int(na)

string sd_timeLeft = na(sd_minsLeft) ? "—" : f_fmtMins(sd_minsLeft)

// Next session to open. An already-open session returns a full-day
// figure here, so it can never win the comparison.
int toSyd = sydActive ? 9999 : f_minsUntil(sydNow, sydOpenM)
int toTok = tokActive ? 9999 : f_minsUntil(tokNow, tokOpenM)
int toLon = lonActive ? 9999 : f_minsUntil(lonNow, lonOpenM)
int toNY  = nyActive  ? 9999 : f_minsUntil(nyNow,  nyOpenM)

string sd_nextName  = "—"
color  sd_nextColor = color.new(#888888, 0)
int    sd_nextMins  = 9999

if toSyd < sd_nextMins
    sd_nextMins  := toSyd
    sd_nextName  := "Sydney"
    sd_nextColor := color.new(#FFD700, 0)
if toTok < sd_nextMins
    sd_nextMins  := toTok
    sd_nextName  := "Tokyo"
    sd_nextColor := color.new(#FF6B6B, 0)
if toLon < sd_nextMins
    sd_nextMins  := toLon
    sd_nextName  := "London"
    sd_nextColor := color.new(#4FC3F7, 0)
if toNY < sd_nextMins
    sd_nextMins  := toNY
    sd_nextName  := lonActive ? "London / NY" : "New York"
    sd_nextColor := color.new(#81C784, 0)

string sd_timeNext = sd_nextName == "—" ? "—" : f_fmtMins(sd_nextMins)

var float sd_sessHi     = na
var float sd_sessLo     = na
var int   sd_prevSessId = -2

int sd_sessId =
     (lonActive and nyActive) ? 10 :
     nyActive  ? 3 :
     lonActive ? 2 :
     tokActive ? 1 :
     sydActive ? 0 : -1

if sd_sessId != sd_prevSessId
    sd_sessHi     := high
    sd_sessLo     := low
    sd_prevSessId := sd_sessId
else if sd_sessId != -1
    sd_sessHi := math.max(sd_sessHi, high)
    sd_sessLo := math.min(sd_sessLo, low)

string sd_hiStr = sd_sessId == -1 ? "—" : str.tostring(sd_sessHi, format.mintick)
string sd_loStr = sd_sessId == -1 ? "—" : str.tostring(sd_sessLo, format.mintick)

var table sd_tbl = na

if i_showSD and barstate.islast
    if na(sd_tbl)
        sd_tbl := table.new(f_sdTblPos(i_sdPos), 2, 7,
             bgcolor      = color.new(#0d1117, 10),
             border_color = color.new(color.white, 70),
             border_width = 1,
             frame_color  = color.new(color.white, 50),
             frame_width  = 1)

    table.cell(sd_tbl, 0, 0, "SESSION",   text_color=color.new(color.white,20), text_size=i_sdTxtSz, bgcolor=color.new(#1a2332,0))
    table.cell(sd_tbl, 1, 0, "DASHBOARD", text_color=color.new(color.white,20), text_size=i_sdTxtSz, bgcolor=color.new(#1a2332,0))
    table.cell(sd_tbl, 0, 1, "Your Time", text_color=color.new(color.white,40), text_size=i_sdTxtSz, bgcolor=color.new(#0d1117,30))
    table.cell(sd_tbl, 1, 1, sd_localTimeStr, text_color=color.new(color.white,10), text_size=i_sdTxtSz, bgcolor=color.new(#0d1117,30))
    table.cell(sd_tbl, 0, 2, "Active",    text_color=color.new(color.white,40), text_size=i_sdTxtSz, bgcolor=color.new(#0d1117,30))
    table.cell(sd_tbl, 1, 2, sd_activeName, text_color=sd_activeColor,          text_size=i_sdTxtSz, bgcolor=color.new(#0d1117,30))
    table.cell(sd_tbl, 0, 3, "Closes In", text_color=color.new(color.white,40), text_size=i_sdTxtSz, bgcolor=color.new(#0d1117,30))
    table.cell(sd_tbl, 1, 3, sd_timeLeft, text_color=color.new(color.white,10), text_size=i_sdTxtSz, bgcolor=color.new(#0d1117,30))
    table.cell(sd_tbl, 0, 4, "Sess High", text_color=color.new(color.white,40), text_size=i_sdTxtSz, bgcolor=color.new(#0d1117,30))
    table.cell(sd_tbl, 1, 4, sd_hiStr,   text_color=color.new(#26ba9f,0),       text_size=i_sdTxtSz, bgcolor=color.new(#0d1117,30))
    table.cell(sd_tbl, 0, 5, "Sess Low",  text_color=color.new(color.white,40), text_size=i_sdTxtSz, bgcolor=color.new(#0d1117,30))
    table.cell(sd_tbl, 1, 5, sd_loStr,   text_color=color.new(#f23645,0),       text_size=i_sdTxtSz, bgcolor=color.new(#0d1117,30))
    table.cell(sd_tbl, 0, 6, "Next → " + sd_nextName, text_color=sd_nextColor,  text_size=i_sdTxtSz, bgcolor=color.new(#1a2332,0))
    table.cell(sd_tbl, 1, 6, "in " + sd_timeNext,     text_color=color.new(color.white,30), text_size=i_sdTxtSz, bgcolor=color.new(#1a2332,0))

// ══════════════════════════════════════════════════════════════
// ░░  SECTION 10 — ALERTS
// ══════════════════════════════════════════════════════════════
// Level alerts use crossings rather than state, so each one fires once
// at the moment of the event instead of on every bar that stays beyond
// the level.
alertcondition(ta.crossover(close,  sess_VAH), "Cross Above Sess VAH", "Price crossed above Session VAH")
alertcondition(ta.crossunder(close, sess_VAL), "Cross Below Sess VAL", "Price crossed below Session VAL")
alertcondition(ta.crossover(close,  sess_POC), "Cross Above Sess POC", "Price crossed above Session POC")
alertcondition(ta.crossunder(close, sess_POC), "Cross Below Sess POC", "Price crossed below Session POC")
alertcondition(ta.crossover(close,  week_VAH), "Cross Above Week VAH", "Price crossed above Weekly VAH")
alertcondition(ta.crossunder(close, week_VAL), "Cross Below Week VAL", "Price crossed below Weekly VAL")
alertcondition(ta.crossover(close,  stru_POC), "Cross Above Stru POC", "Price crossed above Structure POC")
alertcondition(ta.crossunder(close, stru_POC), "Cross Below Stru POC", "Price crossed below Structure POC")
alertcondition(ta.crossover(close,  year_POC), "Cross Above LT POC",   "Price crossed above the long-term POC")
alertcondition(ta.crossunder(close, year_POC), "Cross Below LT POC",   "Price crossed below the long-term POC")
alertcondition(ta.crossover(close,  ema1),     "Above Fast EMA",       "Price crossed above Fast EMA")
alertcondition(ta.crossunder(close, ema1),     "Below Fast EMA",       "Price crossed below Fast EMA")
alertcondition(ta.crossover(close,  ema2),     "Above Slow EMA",       "Price crossed above Slow EMA")
alertcondition(ta.crossunder(close, ema2),     "Below Slow EMA",       "Price crossed below Slow EMA")
alertcondition(deathCross,                     "Death Cross",          "Death Cross: Fast EMA crossed below Slow EMA")
alertcondition(goldenCross,                    "Golden Cross",         "Golden Cross: Fast EMA crossed above Slow EMA")
alertcondition(sfpBearShow,                    "Bearish SFP",          "Bearish Swing Failure Pattern detected")
alertcondition(sfpBullShow,                    "Bullish SFP",          "Bullish Swing Failure Pattern detected")
alertcondition(sfpBearStrong,                  "Bearish SFP (Strong)", "Bearish SFP with BOS/CHoCH confluence")
alertcondition(sfpBullStrong,                  "Bullish SFP (Strong)", "Bullish SFP with BOS/CHoCH confluence")
alertcondition(ta.crossover(close,  vwapVal),  "Above VWAP",           "Price crossed above VWAP")
alertcondition(ta.crossunder(close, vwapVal),  "Below VWAP",           "Price crossed below VWAP")
alertcondition(bosEvent,                       "BOS",                  "Swing Break of Structure detected")
alertcondition(chochEvent,                     "CHoCH",                "Swing Change of Character detected")
alertcondition(inBosEvent,                     "Internal BOS",         "Internal Break of Structure (early signal)")
alertcondition(inChochEvent,                   "Internal CHoCH",       "Internal Change of Character — leading reversal signal")
alertcondition(nyOpenTrig,                     "NY Open",              "New York session open")
alertcondition(lonOpenTrig,                    "London Open",          "London session open")
alertcondition(tokOpenTrig,                    "Tokyo Open",           "Tokyo session open")
alertcondition(sydOpenTrig,                    "Sydney Open",          "Sydney session open")
````
