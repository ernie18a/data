# STRYK: DELTA-RVWAP-EMA'S

- url: https://www.tradingview.com/script/pfcxXpXw-STRYK-DELTA-RVWAP-EMA-S/
- type: indicator
- pine_id: PUB;d47024af6bf94f9d8803efd2eee6fb63
- version: 1.0

## Description

Stryk: Delta-RVWAP-EMAs puts three reads on one overlay: where price is relative to value, what order flow is doing, and the higher-timeframe backdrop.

Rolling VWAP built for futures sessions
TradingView's Rolling VWAP measures its window in clock time. This version counts trading time, so "1 session" is always one full 23-hour futures session of bars, across the daily halt and the weekend. You can also use a fixed bar count, clock time, TradingView's automatic period, or an anchored VWAP that resets each session, week or month. A session filter lets only regular hours, overnight, Asia, London or a custom window feed the calculation. Three standard-deviation bands are drawn around the VWAP.

Delta candles
Candles are colored by the Delta size HTF engine. Each bar is compared with the value area of the last N higher-timeframe candles (1 hour x 23 by default). Inside value is neutral, above is bullish, below is bearish, and the color strengthens with acceptance, relative volume and movement of the point of control. Four simpler VWAP-based color modes are also available.

Max Delta Prints (MDP)
A bar is marked as an aggression print when its delta is far from its own baseline on heavier volume than that time of day normally sees, and as an absorption print when heavy volume produces unusually little movement. Each print can be tagged by where it happened relative to the VWAP: continuation, reversal or raw. Optional reversal and trend markers build on that tag. They are off by default and are context to study, not trade signals.

Delta source
Delta uses TradingView footprint data where your plan and symbol provide it. That data is classified from lower-timeframe price action. Where it is unavailable, the script estimates delta from the direction of lower-timeframe bars. Neither is exchange aggressor data.

Higher-timeframe lines
A chart EMA (233 bars), a daily EMA (50 days) and a weekly EMA (20 weeks), each with editable length and type. The daily and weekly lines are requested from their own timeframes, so the level is the same on every chart. Three weekly-ATR bands sit around the weekly line. A bias row shows how many lines price is above or below.

Line shape
One control sets how every line is drawn: Smooth (multi-pass smoothing), Raw, or Stepped.

How to use it
Start with the defaults on an intraday futures chart. Group 0 holds a master switch for every block, so turn off what you do not need. The tooltips in each group explain its settings.

Notes
- The VWAP and the EMAs include the forming bar. The daily and weekly lines can include the forming day or week, or use completed bars only.
- Alerts fire on bar close.
- Delta, value-area and absorption reads are estimates built from the data described above.
- Replay mode reduces the data the script requests so it fits Bar Replay.

Credit: the rolling VWAP concept and the automatic time period come from TradingView's built-in Rolling VWAP.

## Source Code

````pine
//@version=6
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// Based on TradingView's built-in "Rolling VWAP" (© TradingView). Modified by Stryk.
// ─────────────────────────────────────────────────────────────────────────────
// STRYK: DELTA-RVWAP-EMA'S ("STRYK:DRE") — TradingView's Rolling VWAP rebuilt
// around the 23-hour futures session, with every visual under your control.
//
// WHY THE LOOKBACK CHANGED: the stock script measures its window in CLOCK time.
// A "1 day" window is 24 clock hours, so across the daily one-hour halt it holds
// a slightly different slice of trading every bar, and on a Sunday open it holds
// almost nothing. Here the default window is counted in TRADING time: one ETH
// session is 23 hours of bars (276 on a 5-minute chart), so the window always
// holds exactly one full session no matter where the halt or the weekend falls.
//
// LOOKBACK MODES
//   ETH sessions     — N sessions of trading time (presets or custom).
//   Fixed bars       — a plain bar count.
//   Clock time       — days / hours / minutes of clock time (TradingView's rule).
//   Auto             — TradingView's automatic clock period for the timeframe.
//   Anchored         — no rolling: resets at the session, week or month start.
//
// SESSION WINDOW: choose which bars are allowed to feed the VWAP — every bar,
// RTH only, overnight only, Asia, London or a custom window. Session times and
// timezone are editable. With a window selected, "1 session" means one pass of
// that window (6.5 hours for the default RTH).
//
// CANDLE PAINT: the STRYK:M delta engine, carried over unchanged. Delta size HTF
// colours each candle against the volume profile of the last N delta-timeframe
// candles (1 hour × 23 by default): blue inside value, green above, red below,
// brighter with acceptance, relative size and POC migration. The MDP engine
// rides on top as an override: a Max Delta Print bar is painted orange for
// aggression or purple for absorption, with its signal and optional level
// ladder. Delta comes from request.footprint() where TradingView supplies it,
// otherwise an ESTIMATE from lower-timeframe bar polarity.
//
// MDP × VWAP CONTEXT: a read-only layer on top of the MDP engine. MDP says WHAT
// happened, the rolling VWAP says WHERE, and this layer says how the two line
// up. It never changes which bar qualifies, how it is ranked or how it is
// painted. Each print is typed CONTINUATION (aggression on the VWAP's side),
// REVERSAL (a print at the edge of value with the flow failing there) or RAW,
// and scored out of 3. Two setups follow from it: a reversal print that then
// reclaims the band, and a continuation print that then holds the VWAP.
//
// EMA BIAS LINES: a chart EMA (233 bars), a daily EMA (50 days) and a weekly
// EMA (20 weeks). Every length is editable. The daily and weekly lines are
// pulled from their own timeframes, so the level is the same on every chart.
//
// 20-WEEK BANDS: three rings either side of the weekly EMA at multiples of the
// WEEKLY ATR, from STRYK:20W (or of the weekly standard deviation, selectable). Distance in weekly ATR means the same thing
// on any instrument and in any volatility regime.
//
// LINE SHAPE: one control for every line. Smooth runs multi-pass smoothing and
// ramps the daily / weekly lines between values so nothing stair-steps. Raw
// draws the values as computed. Stepped (forced) makes every line hold and jump.
//
// CONTEXT RESEARCH (private, off by default): follows every print and setup
// forward and compares it with ordinary bars, so the context reads can be
// judged on your own chart's footprint data before they are trusted.
//
// Every block has a master switch in group 0.
//
// The line includes the forming bar, as any VWAP does. Alerts fire on closed bars.
// ─────────────────────────────────────────────────────────────────────────────
indicator("STRYK: DELTA-RVWAP-EMA'S", "STRYK:DRE", overlay = true, max_bars_back = 300, max_lines_count = 200, max_labels_count = 300, dynamic_requests = true)

string G0  = "0 · Master Switches"
string G1  = "1 · Lookback"
string G2  = "2 · Session Window"
string G3  = "3 · Line Shape & Smoothing (all lines)"
string G4  = "4 · VWAP Line"
string G5  = "5 · Deviation Bands"
string G6  = "6 · Fills"
string G7  = "7 · Candle Paint"
string GD  = "8 · Delta Engine (candle paint source)"
string GP  = "9 · Delta Size HTF"
string GM  = "10 · MDP Highlight"
string G8  = "11 · Background"
string G9  = "12 · Session Shading"
string G10 = "13 · Price Labels"
string G11 = "14 · Info Box"
string G12 = "15 · Alerts"
string G13 = "16 · MDP × VWAP Context & Setups"
string G14 = "17 · EMA Bias Lines"
string G15 = "18 · 20-Week ATR Bands"
string G16 = "19 · Context Research (private)"

// ── 0 · Master switches ──────────────────────────────────────────────────────
bool mVwap      = input.bool(true,  "VWAP line", group = G0, inline = "m1")
bool mBands     = input.bool(true,  "Band lines", group = G0, inline = "m1")
bool mFills     = input.bool(true,  "Fills", group = G0, inline = "m1", tooltip = "Master switches. Each one forces its block off regardless of its own settings, and hands control back with the settings intact.")
bool mEma1      = input.bool(true,  "Chart EMA (233)", group = G0, inline = "m1b")
bool mEma2      = input.bool(true,  "Daily EMA (50D)", group = G0, inline = "m1b")
bool mEma3      = input.bool(true,  "Weekly EMA (20W)", group = G0, inline = "m1b", tooltip = "The three EMA bias lines from group 17. A line that is switched off is not drawn, not labelled and casts no vote in the bias stack.")
bool mW20Bands  = input.bool(true,  "20W ATR bands", group = G0, inline = "m1c")
bool mW20Fills  = input.bool(true,  "20W band fills", group = G0, inline = "m1c", tooltip = "The weekly-ATR bands around the weekly EMA and the shading between them (group 18). They work with the Weekly EMA line itself switched off.")
bool mSmooth    = input.bool(true,  "Smoothing", group = G0, inline = "m2")
bool mWinFilter = input.bool(true,  "Session window filter", group = G0, inline = "m2", tooltip = "Smoothing OFF removes the smoothing passes from every line whatever group 3 says. Session window filter OFF feeds every bar into the VWAP whatever group 2 says.")
bool mPaint     = input.bool(true,  "Candle paint", group = G0, inline = "m3")
bool mMdp       = input.bool(true,  "MDP highlight", group = G0, inline = "m3", tooltip = "Candle paint = the mode chosen in group 7, Delta size HTF by default.\n\nMDP highlight = the Max Delta Print engine as a candle override. Whatever the paint mode is, a bar that qualifies as a print is painted in the MDP colors instead: orange for aggression, purple for absorption. It keeps working with Candle paint OFF, so you can run prints only.")
bool mdSigOn    = input.bool(true,  "MDP signals", group = G0, inline = "m4")
bool mMdpLines  = input.bool(false, "MDP levels", group = G0, inline = "m4", tooltip = "Signals = the AGG / ABS label under each print. Levels = the ratio ladder on the CURRENT print only: its high and low, the ratios between them and the extensions beyond, cleared and redrawn when a new print takes over. Both need MDP highlight ON.")
bool mCtx       = input.bool(true,  "MDP × VWAP context", group = G0, inline = "m4b")
bool mCtxLbl    = input.bool(true,  "Context labels", group = G0, inline = "m4b")
bool mSetups    = input.bool(false, "Setups", group = G0, inline = "m4b", tooltip = "UNTESTED, so OFF by default: on the data available the setups showed no reliable edge (see the group 16 tooltips).\n\nMDP × VWAP context = types and scores each MDP print against the rolling VWAP (group 16). Context labels = the small tag above the print. Setups = the reversal and trend setups built on that context. None of the three can change an MDP print; they only read it. All need MDP highlight ON.")
bool mCtxResearch = input.bool(false, "Context research panel", group = G0, tooltip = "PRIVATE measurement, off by default. Follows every MDP print (by context type) and every setup forward and compares the result with ordinary bars over the same window (group 19). It only measures: nothing in it feeds back into prints, context or setups. Keep it off, or remove it, in anything you publish.")
bool mdReset    = input.bool(true,  "MDP: restart each session", group = G0, inline = "m5")
bool mdConfirm  = input.bool(true,  "MDP: confirm on close", group = G0, inline = "m5", tooltip = "Restart each session = every session hunts its own biggest print; OFF holds the incumbent until something beats it.\n\nConfirm on close = a bar can only claim the print once it has closed, so live behavior matches history; OFF lets it claim mid-bar.")
bool mBg        = input.bool(false, "Background", group = G0, inline = "m6")
bool mSessBg    = input.bool(false, "Session shading", group = G0, inline = "m6")
bool mLabels    = input.bool(true,  "Price labels", group = G0, inline = "m7")
bool mBox       = input.bool(true,  "Info box", group = G0, inline = "m7")
bool mAlerts    = input.bool(true,  "Alerts", group = G0, inline = "m7")
bool memSaver   = input.bool(false, "Replay mode", group = G0, tooltip = "Keep OFF for live. Turn ON when you enter Bar Replay: the delta engine stops pulling intrabar data and volume profiles so the script fits Replay's smaller memory allowance. The rolling VWAP, bands and fills are unaffected.\n\nDelta size HTF needs those profiles, so while this is ON the candles fall back to Sigma gradient. MDP keeps running on bar-level delta.")

// ── 1 · Lookback ─────────────────────────────────────────────────────────────
float  src      = input.source(hlc3, "Source", group = G1, tooltip = "The price the VWAP is built from. HLC3 is the convention.")
string lbMode   = input.string("ETH sessions", "Lookback mode", options = ["ETH sessions", "Fixed bars", "Clock time", "Auto (TradingView)", "Anchored"], group = G1, tooltip = "ETH sessions (default): the window is counted in TRADING time, so one session is always one full 23-hour session of bars. Built for futures.\n\nFixed bars: a plain bar count.\n\nClock time: days / hours / minutes of clock time, the way TradingView's Rolling VWAP measures it.\n\nAuto (TradingView): TradingView's automatic clock period for your chart timeframe.\n\nAnchored: no rolling window. The VWAP resets at the anchor below and builds from there.")
string lbPreset = input.string("1 session", "Sessions preset", options = ["Custom", "¼ session", "½ session", "1 session", "2 sessions", "3 sessions", "1 week (5 sessions)", "2 weeks (10 sessions)", "1 month (21 sessions)", "1 quarter (63 sessions)"], group = G1, active = lbMode == "ETH sessions", tooltip = "How many sessions of trading the window holds. On a 5-minute chart with a 23-hour session: 1 session = 276 bars, 2 sessions = 552, 1 week = 1,380. Pick Custom to type your own below.")
float  cSess    = input.float(1.0, "Custom: sessions", minval = 0.0, step = 0.25, group = G1, inline = "cs", active = lbMode == "ETH sessions" and lbPreset == "Custom")
float  cHours   = input.float(0.0, "+ hours", minval = 0.0, step = 0.5, group = G1, inline = "cs", active = lbMode == "ETH sessions" and lbPreset == "Custom")
int    cMins    = input.int(0, "+ min", minval = 0, maxval = 59, group = G1, inline = "cs", active = lbMode == "ETH sessions" and lbPreset == "Custom", tooltip = "Used when the preset is Custom. All three add together as trading time: 1 session + 11.5 hours = one and a half 23-hour sessions.")
float  ethHours = input.float(23.0, "ETH session length (hours)", minval = 0.25, maxval = 24.0, step = 0.25, group = G1, tooltip = "Trading hours in one full session. 23 for CME index, metals and energy futures. Use 24 for crypto, 6.5 for US stocks. Only used when the session window below is All bars; a selected window uses its own length.")
int    fixBars  = input.int(276, "Fixed bars", minval = 1, maxval = 50000, group = G1, active = lbMode == "Fixed bars")
int    ckDays   = input.int(1, "Clock time: days", minval = 0, group = G1, inline = "ck", active = lbMode == "Clock time")
int    ckHours  = input.int(0, "hours", minval = 0, maxval = 23, group = G1, inline = "ck", active = lbMode == "Clock time")
int    ckMins   = input.int(0, "min", minval = 0, maxval = 59, group = G1, inline = "ck", active = lbMode == "Clock time")
string ancType  = input.string("Session start", "Anchor", options = ["Session start", "Week", "Month"], group = G1, active = lbMode == "Anchored", tooltip = "Anchored mode only. Session start = the exchange session open (17:00 Central for CME futures), or the start of the selected session window when one is chosen below.")
int    minBars  = input.int(10, "Minimum bars", minval = 1, maxval = 5000, group = G1, tooltip = "The window never holds fewer bars than this. In the clock-time modes it stops a long gap between bars, such as a weekend, from emptying the window.")

// ── 2 · Session window ───────────────────────────────────────────────────────
string winSel  = input.string("All bars (ETH)", "Bars that feed the VWAP", options = ["All bars (ETH)", "RTH", "Overnight (outside RTH)", "Asia", "London", "Custom"], group = G2, tooltip = "All bars (default): the full 23-hour session.\n\nAny other choice lets only bars inside that window into the calculation. RTH gives a VWAP built purely from cash-hours volume; Overnight gives the opposite. The window times are set below.")
string tzSel   = input.string("America/Chicago", "Timezone", options = ["Exchange", "America/Chicago", "America/New_York", "America/Los_Angeles", "UTC", "Europe/London", "Europe/Berlin", "Asia/Tokyo", "Asia/Hong_Kong", "Asia/Singapore", "Australia/Sydney"], group = G2, tooltip = "The timezone the four windows below are written in. Exchange uses the symbol's own timezone.")
string sRth    = input.session("0830-1500", "RTH", group = G2, inline = "s1")
string sAsia   = input.session("1700-0200", "Asia", group = G2, inline = "s1")
string sLon    = input.session("0200-0830", "London", group = G2, inline = "s2")
string sCus    = input.session("0830-1100", "Custom", group = G2, inline = "s2", tooltip = "Edit any window. Defaults are Central time: RTH 08:30-15:00, Asia 17:00-02:00, London 02:00-08:30. These same windows drive the session shading in group 12.")
string outMode = input.string("Hold the line", "Outside the window", options = ["Hold the line", "Hide the line"], group = G2, tooltip = "What to draw while price is outside the selected window. Hold keeps the last value on the chart as a level. Hide removes the line and bands until the window opens again.")

// ── 3 · Line shape and smoothing — one system for every line ─────────────────
string shapeMode = input.string("Smooth", "Line shape", options = ["Smooth", "Raw", "Stepped (forced)"], group = G3, tooltip = "Applies to the VWAP, its bands and all three EMA lines.\n\nSmooth (default): multi-pass smoothing. The daily and weekly EMAs are also ramped between their values across the day or week, so they glide instead of stair-stepping on an intraday chart.\n\nRaw: every line exactly as computed, no smoothing. Daily and weekly values that only change once per day or week will show their natural steps.\n\nStepped (forced): every line holds its value and jumps. The VWAP, bands and chart EMA step once per 'Step every' period below; the daily EMA steps once a day and the weekly once a week. This changes the DRAWING only: bands, alerts, context and setups keep measuring from the live values.")
int    smPass    = input.int(2, "Smoothing passes", minval = 1, maxval = 3, group = G3, inline = "sm1")
int    smLen     = input.int(3, "base length (bars)", minval = 2, maxval = 100, group = G3, inline = "sm1")
float  smMult    = input.float(1.0, "Multiplier ×", minval = 0.25, maxval = 20.0, step = 0.25, group = G3, tooltip = "Passes: how many times each line is run through the smoother. More passes smooth harder than more length for the same lag.\n\nBase length × Multiplier = the length of each pass for the VWAP, bands and chart EMA. Raise the multiplier to make every line glassier in one move.\n\nThe daily and weekly EMAs size their passes from the chart timeframe instead (a quarter of one day or week of bars), and the multiplier scales that too.")
string stepTf    = input.timeframe("60", "Stepped: step every", group = G3, tooltip = "Stepped (forced) only. How often the VWAP, bands and chart EMA are allowed to update. 60 = once an hour. Must be above the chart timeframe to have any effect.")
bool   shapeStep = shapeMode == "Stepped (forced)"
int    smPassEff = mSmooth and shapeMode == "Smooth" ? smPass : 0
int    smLenEff  = math.max(2, int(math.round(smLen * smMult)))

// ── 4 · VWAP line ────────────────────────────────────────────────────────────
string vwColMode = input.string("Solid", "Color mode", options = ["Solid", "VWAP slope", "Price side"], group = G4, tooltip = "Solid: one color.\n\nVWAP slope: rising / falling / flat colors, from the slope settings below.\n\nPrice side: one color while price closes above the line, another while below.")
color  vwCol     = input.color(#FF9800, "Solid", group = G4, inline = "v1")
int    vwW       = input.int(3, "w", minval = 1, maxval = 10, group = G4, inline = "v1")
string vwSty     = input.string("Solid", "", options = ["Solid", "Stepline", "Dotted", "Cross"], group = G4, inline = "v1")
color  vwUpCol   = input.color(#26A69A, "Up", group = G4, inline = "v2")
color  vwDnCol   = input.color(#EF5350, "Down", group = G4, inline = "v2")
color  vwFlatCol = input.color(#787B86, "Flat", group = G4, inline = "v2", tooltip = "Used by the VWAP slope and Price side color modes.")
int    slopeLen  = input.int(5, "Slope: over (bars)", minval = 1, maxval = 250, group = G4, inline = "v3")
float  flatTicks = input.float(1.0, "flat under (ticks)", minval = 0.0, step = 0.5, group = G4, inline = "v3", tooltip = "The slope compares the VWAP now with the VWAP this many bars ago. A change smaller than the tick threshold reads as flat. These also drive the slope modes for candles and background.")

// ── 5 · Deviation bands ──────────────────────────────────────────────────────
bool   b1On   = input.bool(true, "Band 1", group = G5, inline = "b1a")
float  b1Mult = input.float(1.0, "×", minval = 0.05, step = 0.25, group = G5, inline = "b1a")
bool   b1Line = input.bool(true, "draw line", group = G5, inline = "b1a", tooltip = "Each band sits this many volume-weighted standard deviations from the VWAP. Untick the band to remove it entirely. Untick 'draw line' to hide the line but keep its fills, labels and alerts.")
color  b1UpC  = input.color(#4C8DFF, "upper", group = G5, inline = "b1b")
color  b1LoC  = input.color(#4C8DFF, "lower", group = G5, inline = "b1b")
int    b1W    = input.int(2, "w", minval = 1, maxval = 10, group = G5, inline = "b1b")
string b1Sty  = input.string("Solid", "", options = ["Solid", "Stepline", "Dotted", "Cross"], group = G5, inline = "b1b")
bool   b2On   = input.bool(true, "Band 2", group = G5, inline = "b2a")
float  b2Mult = input.float(2.0, "×", minval = 0.05, step = 0.25, group = G5, inline = "b2a")
bool   b2Line = input.bool(true, "draw line", group = G5, inline = "b2a")
color  b2UpC  = input.color(color.new(#4C8DFF, 40), "upper", group = G5, inline = "b2b")
color  b2LoC  = input.color(color.new(#4C8DFF, 40), "lower", group = G5, inline = "b2b")
int    b2W    = input.int(1, "w", minval = 1, maxval = 10, group = G5, inline = "b2b")
string b2Sty  = input.string("Solid", "", options = ["Solid", "Stepline", "Dotted", "Cross"], group = G5, inline = "b2b")
bool   b3On   = input.bool(true, "Band 3", group = G5, inline = "b3a")
float  b3Mult = input.float(3.0, "×", minval = 0.05, step = 0.25, group = G5, inline = "b3a")
bool   b3Line = input.bool(true, "draw line", group = G5, inline = "b3a")
color  b3UpC  = input.color(#FF5252, "upper", group = G5, inline = "b3b")
color  b3LoC  = input.color(#FF5252, "lower", group = G5, inline = "b3b")
int    b3W    = input.int(1, "w", minval = 1, maxval = 10, group = G5, inline = "b3b")
string b3Sty  = input.string("Solid", "", options = ["Solid", "Stepline", "Dotted", "Cross"], group = G5, inline = "b3b", tooltip = "Upper and lower colors are separate so the two sides can read differently. Styles are the four that plot() provides; Pine has no true dashed plot line.")

// ── 6 · Fills ────────────────────────────────────────────────────────────────
bool  fInOn   = input.bool(true, "VWAP to band 1", group = G6, inline = "f1")
color fInUpC  = input.color(color.new(#2962FF, 88), "upper", group = G6, inline = "f1")
color fInDnC  = input.color(color.new(#2962FF, 88), "lower", group = G6, inline = "f1", tooltip = "The value area. Upper and lower halves take their own color. Transparency lives in each color picker.")
bool  fMidOn  = input.bool(false, "Band 1 to band 2", group = G6, inline = "f2")
color fMidUpC = input.color(color.new(#26A69A, 92), "upper", group = G6, inline = "f2")
color fMidDnC = input.color(color.new(#EF5350, 92), "lower", group = G6, inline = "f2")
bool  fOutOn  = input.bool(true, "Band 2 to band 3", group = G6, inline = "f3")
color fOutUpC = input.color(color.new(#26A69A, 88), "upper", group = G6, inline = "f3")
color fOutDnC = input.color(color.new(#EF5350, 88), "lower", group = G6, inline = "f3", tooltip = "A fill needs both of its bands switched on in group 5. The band lines themselves can be hidden.")

// ── 7 · Candle paint ─────────────────────────────────────────────────────────
string cMode   = input.string("Delta size HTF", "Candle mode", options = ["Delta size HTF", "Sigma gradient", "Price vs VWAP", "Outside band only", "VWAP slope"], group = G7, tooltip = "Delta size HTF (default): the STRYK:M engine. Each candle is colored against the volume profile of the last N delta-timeframe candles: blue inside the value area, green above it, red below, brighter with acceptance, relative size and POC migration. Its settings and colors are in groups 8 and 9.\n\nThe other four are read off this script's own rolling VWAP and use the colors below.\n\nSigma gradient: shades from the base color at the VWAP to the hot color as price stretches away, in standard deviations.\n\nPrice vs VWAP: one color above the line, another below.\n\nOutside band only: paints only bars that close outside the chosen band.\n\nVWAP slope: colors by whether the VWAP is rising, falling or flat.\n\nMDP prints override any of them while MDP highlight is ON.")
color  cUpC    = input.color(#2E7D52, "VWAP modes: above", group = G7, inline = "c1")
color  cUpHotC = input.color(#00FF88, "hot", group = G7, inline = "c1")
color  cDnC    = input.color(#8C2F2F, "VWAP modes: below", group = G7, inline = "c2")
color  cDnHotC = input.color(#FF1744, "hot", group = G7, inline = "c2")
color  cNeuC   = input.color(#2F6FED, "VWAP modes: neutral", group = G7, inline = "c3")
bool   cWicks  = input.bool(true, "paint wicks and borders too", group = G7, inline = "c3", tooltip = "The five colors apply to the four VWAP-based modes and to the Zone row of the info box. Delta size HTF has its own Bull / Neutral / Bear colors in group 9. The wick switch applies to every mode, MDP prints included.")
float  zFull   = input.float(2.0, "Sigma gradient: full color at (σ)", minval = 0.25, step = 0.25, group = G7, tooltip = "The distance from the VWAP, in standard deviations, at which a candle reaches the full hot color.")
int    cBand   = input.int(1, "Outside band only: band", minval = 1, maxval = 3, group = G7, tooltip = "Which band a close must be outside of to get painted in that mode. Uses the hot colors.")

// ── 8 · Delta engine (STRYK:M) ───────────────────────────────────────────────
deltaSrc = input.string("Auto (footprint → estimate)", "Delta source", group = GD,
     options = ["Auto (footprint → estimate)", "Estimate only"],
     tooltip = "Auto: uses request.footprint() buy/sell volume whenever TradingView supplies it (classified from lower-timeframe price action, not exchange aggressor data) for the bar, otherwise the polarity estimate. Estimate only: ignores footprint. Footprint availability depends on plan and symbol; the footprint is built from TradingView's own tick feed, so a 'Delayed' chip on the chart means the colours are delayed by the same amount.")
fpTicks  = input.int(4, "Footprint row size (ticks)", minval = 1, group = GD,
     tooltip = "Row height for request.footprint(). Bar delta is the same at any row size; 4 ticks = 1 point on ES/NQ.")
htfTf    = input.timeframe("60", "Delta timeframe", group = GD,
     tooltip = "The candle delta accumulates into: candle color follows this candle's LIVE delta, and the Delta size HTF value area is built from the last N of these. Must be ≥ the chart timeframe; with auto-raise ON it is lifted to the chart timeframe when you go higher. Independent of the rolling VWAP lookback in group 1.")
autoRaiseTf = input.bool(true, "Auto-raise delta timeframe to chart", group = GD,
     tooltip = "ON: when the chart timeframe is above the delta timeframe, the delta timeframe becomes the chart timeframe for that session with the same lookback N — no error, same rule as Stryk: ΔC. OFF: strict, the script halts with an error.")
lenN     = input.int(23, "Lookback N (delta candles)", minval = 1, maxval = 200, group = GD,
     tooltip = "Completed delta-timeframe candles in the Delta size HTF profile window and in the average |Δ| the paint scale normalises to. 23 on a 60-minute delta timeframe = one 23-hour session, the same span as the default VWAP lookback.")
useAutoLtf = input.bool(true, "Auto intrabar resolution (estimate path)", group = GD,
     tooltip = "Estimate path only. Picks the finest lower-timeframe resolution whose data budget still covers N candles × the history multiple. Same rule as Stryk: ΔC.")
dataBudget = input.string("100K (Basic–Premium)", "Intrabar budget (your plan)", group = GD,
     options = ["25K (memory saver)", "50K (replay-safe)", "100K (Basic–Premium)", "125K (Expert)", "200K (Ultimate)"],
     tooltip = "TradingView's cap on lower-timeframe bars a script may pull, by plan. The auto ladder uses it to pick the finest intrabar resolution that still covers your history window — this sets RESOLUTION, not memory (the cap is what it is). For Bar Replay's smaller memory allowance use the Replay / memory saver master switch in group 0 instead.")
histMult = input.float(3.0, "History coverage (× N candles)", minval = 1.0, maxval = 10.0, step = 0.5, group = GD,
     tooltip = "Multiples of N candles the estimate path must cover before accepting a resolution.")
manualLtf = input.timeframe("1", "Manual intrabar resolution", group = GD,
     tooltip = "Used when auto is OFF. Must be below the chart timeframe.")

// ── 9 · Delta size HTF (STRYK:M paint engine) ────────────────────────────────
colBull = input.color(#4ade80, "Bull", group = GP, inline = "c")
colNeut = input.color(#3b82f6, "Neutral", group = GP, inline = "c")
colBear = input.color(#e63030, "Bear", group = GP, inline = "c")
// — POC band (Delta size / Delta size HTF) —
pocBinTicks = input.int(4, "POC: bin size (ticks)", minval = 1, group = GP,
     tooltip = "Price bucket width for the intrabar volume-at-price profile that locates POC for Delta size / Delta size HTF. Computed from intrabar volume binned by price (the same lower-timeframe technique used on the estimate delta path), independent of whether the bar's own delta figure came from footprint or the estimate — This script bins each intrabar's volume at its close, so the profile is a distribution of intrabar closes — an approximation of volume at price, finer with finer intrabars. 4 ticks = 1 point on ES/NQ.")
pocBandMode = input.string("Value area (VAH/VAL)", "POC: blue band", options = ["Value area (VAH/VAL)", "25% of range"], group = GP,
     tooltip = "What counts as 'at the POC' (blue) for Delta size and Delta size HTF. Value area (default): the band is the VAH/VAL of the reference profile — the prior bar's own profile for Delta size, the last completed delta-timeframe candle's for Delta size HTF — where the volume actually traded. 25% of range: the older fixed band, ±25% of the reference high-low around the POC. Beyond the band the ramp and align rules below apply either way.")
htfRefMode = input.string("HTF window (N candles)", "POC: HTF reference", options = ["HTF window (N candles)", "Last HTF candle"], group = GP,
     tooltip = "What Delta size HTF measures against. HTF window (default): one profile built from the last N candles of the DELTA TIMEFRAME — your Delta Engine settings, so 1 hour × N 23 means the POC and value area of the last 23 hours, and changing either there moves this with it. Last HTF candle: the older behaviour, the single most recent completed candle's own profile, which is faster to shift and noisier.")
htfInsideLean = input.float(0.35, "POC: inside-value lean by POC side", minval = 0.0, maxval = 0.8, step = 0.05, group = GP,
     tooltip = "Inside the value area the paint is neutral by default, which hides the session's own lean. This tilts it toward bull above the POC and bear below it, strongest at the value-area edge and fading to neutral at the POC itself. 0 = the old flat neutral.")
htfIntMode = input.string("Blend", "POC: intensity from", options = ["Distance only", "Blend", "Strongest"], group = GP,
     tooltip = "What drives colour intensity outside value. Distance only: the original — how far beyond the edge price is, as a share of value-area width. Blend: distance averaged with the three factors below, so all four have to agree for full colour. Strongest: whichever of the four reads highest wins, so one decisive factor can carry the bar on its own. Blend is the conservative read, Strongest the early one.")
htfAccBars = input.int(3, "POC: acceptance (closes beyond)", minval = 1, maxval = 20, group = GP, inline = "hi1")
htfSizeFull = input.float(2.0, "size at × rel vol", minval = 1.1, maxval = 6.0, step = 0.1, group = GP, inline = "hi1",
     tooltip = "Acceptance: consecutive CLOSES beyond the edge, full at this many — one bar wicking through no longer reads like the tenth bar holding. A close back inside collapses it to zero. Size: the bar's own volume against what that time of day normally trades, full colour at this multiple — the figure the MDP engine already measures.")
htfMigK = input.int(3, "POC: migration (candles back)", minval = 1, maxval = 50, group = GP,
     tooltip = "The third factor: whether accepted value is MOVING the same way price broke. Compares the window POC against itself this many delta-timeframe candles ago; full weight once it has migrated a whole value-area width. Price above a rising POC and price above a stalling one stop looking identical.")
pocBandPct = input.float(25, "POC: band width (%)", minval = 5, maxval = 50, step = 5, group = GP, inline = "pocb")
pocRampPct = input.float(25, "ramp width (%)", minval = 5, maxval = 75, step = 5, group = GP, inline = "pocb",
     tooltip = "Band = how close to POC still counts as neutral (blue), as a % of the reference range (prior bar's high-low for Delta size, prior HTF candle's high-low for Delta size HTF). Ramp = how much FURTHER beyond the band price must travel to reach full colour. Defaults 25 + 25 = full green/red at 50% of the range beyond POC.")
pocAlignBoost = input.float(0.35, "POC: align boost", minval = 0.0, maxval = 0.6, step = 0.05, group = GP,
     tooltip = "Outside the band: when that bar's own delta (bar-level mode) or the live forming HTF candle's delta (HTF mode) agrees with the price zone — positive delta above POC, negative below — intensity is boosted by this much (capped at full). When price and delta DISAGREE, intensity is reduced by the same amount instead — a visible divergence tell, effort fighting result.")
vaPct = input.int(70, "Value area (% of window volume)", minval = 50, maxval = 95, group = GP,
     tooltip = "The value area is the band around the POC holding this share of the window's volume (70% is the standard), expanded bin by bin toward whichever side has more volume.")
vaRule = input.string("STRYK:M (at least)", "Value area rule", options = ["STRYK:M (at least)", "TradingView (at most)"], group = GP,
     tooltip = "How the value area stops growing. STRYK:M (default): rows are added until the area holds AT LEAST the percentage above, the classic market-profile rule and the one STRYK:M uses, so both scripts paint the same. TradingView: a row that would push the area PAST the percentage is not added, which is how TradingView documents its own volume profile; the area then holds slightly less than the percentage. The two differ by one price row at most.")
bool vaStrict = vaRule == "TradingView (at most)"

// ── 10 · MDP highlight (Max Delta Print engine — candle override only) ───────
// The same qualification maths as STRYK: MDP: a bar becomes the print either by
// AGGRESSION (delta far from normal on heavier volume than that slot usually
// sees) or by ABSORPTION (heavy volume, unusually little movement for the size
// traded). Here it only decides candle colour and the signal underneath.
mdMode = input.string("Session record", "Prints shown", options = ["Session record", "Every qualifying bar"], group = GM,
     tooltip = "Session record (default, the STRYK:M behavior): a bar only becomes a print if it beats the strongest print of its type so far this session, so each session shows its few biggest events.\n\nEvery qualifying bar: every bar that passes the aggression or absorption test is a print, whether or not it sets a record. More prints, and a fairer sample for the context research panel, because record-only prints are a hand-picked subset.")
mdSens = input.string("Average", "Sensitivity", options = ["Fast", "Average", "Slow"], group = GM,
     tooltip = "How extreme a bar must be to claim the print. Fast marks more bars, Slow only the rarest. Every threshold is a multiple of the bar's own baseline, so it means the same thing on any timeframe.")
mdType = input.string("Both", "Print type", options = ["Both", "Aggression only", "Absorption only"], group = GM,
     tooltip = "AGGRESSION = someone crossed the spread in size and price moved. ABSORPTION = heavy volume with almost no movement, which is passive size filling into the aggression. They are different events, so both paths run.")
mdSessStr = input.string("1700-1600:1234567", "Session", group = GM, inline = "ms")
mdTzIn = input.string("America/Chicago", "tz", options = ["Exchange", "America/Chicago", "America/New_York", "Europe/London", "Asia/Tokyo", "UTC"], group = GM, inline = "ms",
     tooltip = "The search restarts at this session open. On daily charts and above one bar is one session, so it restarts each bar instead.")
mdMinDelta = input.float(0.0, "Minimum |delta|", minval = 0.0, group = GM,
     tooltip = "Hard floor in contracts for the aggression path. 0 = off. Absorption ignores it, since a balanced bar is the point.")
mdBaseHours = input.float(8.0, "Baseline hours", minval = 1.0, maxval = 200.0, step = 0.5, group = GM, inline = "mb")
mdTodSess = input.int(20, "time-of-day sessions", minval = 0, maxval = 60, group = GM, inline = "mb",
     tooltip = "Baseline hours = the flat rolling window. Time-of-day sessions = how many past sessions feed the per-slot baseline, so a bar is judged against the same minute on previous days rather than against a quiet overnight average. 0 turns the slots off.")
mdTodWarm = input.int(5, "Slot warmup (sessions)", minval = 1, maxval = 30, group = GM,
     tooltip = "How many observations a slot needs before it is trusted. Until then that bar falls back to the flat rolling baseline.")
mdAbsMode = input.string("Either", "Absorption measures", options = ["Range", "Body", "Either"], group = GM,
     tooltip = "What counts as 'little movement for the size traded'. Range: volume against the bar's full high-to-low. Body: volume against open-to-close. Either (default): a bar qualifies on whichever fits.\n\nBody matters because a bar that runs hard both ways and closes near its open has enormous rotation but a wide range, so the range test throws it out. On the test data, body-based absorption caught 1,748 bars the range test missed — median body 0.31x normal against a range of 1.08x. That is the rejection bar, and it was invisible.")
mdAbsDebug = input.bool(false, "Absorption debug", group = GM, inline = "mdbg")
mdAbsDebugN = input.int(20, "keep", minval = 5, maxval = 60, group = GM, inline = "mdbg",
     tooltip = "Grey labels, so they never read as prints. Shows the three absorption readings under every bar that had the volume to be a candidate but failed — effort ratio, range/body ratio, relative volume, each ticked or crossed. Shows which gate is actually blocking instead of leaving you to guess from an empty chart.")
mdColAgg = input.color(#ff7b00, "Aggression", group = GM, inline = "mc")
mdColAbs = input.color(#a855f7, "Absorption", group = GM, inline = "mc")
mdSigStyle = input.string("Short", "Signal text", options = ["Short", "Full", "Marker only"], group = GM, inline = "mg")
mdSigSize = input.string("Tiny", "size", options = ["Tiny", "Small", "Normal", "Large"], group = GM, inline = "mg",
     tooltip = "Short: AGG Δ▲ / ABS Δ▼. Full: the whole word with the same arrow. Marker only: a coloured triangle. Δ▲ / Δ▼ is the side that aggressed, not the candle direction.")
mdLevels = input.string("-0.625, -0.5, -0.375, 0, 0.375, 0.5, 0.625, 1, 1.375, 1.5, 1.625", "Levels (ratios)", group = GM,
     tooltip = "Comma-separated ratios of the print's own range. 0 = the print's low, 1 = its high, so 0.5 is its midpoint; anything below 0 or above 1 is an extension beyond the bar. Blank entries and anything that is not a number are skipped.")
mdLnAbove = input.color(#4ade80, "Above 1", group = GM, inline = "ml")
mdLnInside = input.color(#e0b042, "inside", group = GM, inline = "ml")
mdLnBelow = input.color(#e24b4a, "below 0", group = GM, inline = "ml")
mdLnW = input.int(1, "Line width", minval = 1, maxval = 4, group = GM, inline = "ml2")
mdLnLbl = input.bool(true, "ratio labels", group = GM, inline = "ml2",
     tooltip = "Extensions above the print take the first colour, levels between its high and low the second, extensions below it the third. Lines extend right until a new print replaces them.")
mdSigText = input.int(20, "Signals with text", minval = 0, maxval = 200, group = GM,
     tooltip = "The newest prints carry the full AGG / ABS reading. Older ones keep their marker and colour but drop the text, so the chart stays legible when you scroll back and the label budget goes further.")
mdSigKeep = input.int(60, "Signals kept on chart", minval = 0, maxval = 190, group = GM,
     tooltip = "How many past MDP markers stay on the chart, text or not. The script reserves 200 labels in total and the ladder's ratio labels and the debug labels come out of the same pool, so 60 leaves room without reserving memory you are not using. The candle colour itself is permanent, painted on the bar that qualified, so prints stay findable however far back you scroll.")

// ── 11 · Background ──────────────────────────────────────────────────────────
string bgMode  = input.string("Outside band only", "Background mode", options = ["Price vs VWAP", "Outside band only", "VWAP slope", "Bias stack"], group = G8, tooltip = "The VWAP reads as a background tint, or Bias stack: Up when most of the enabled EMA lines vote up, Down when most vote down, Neutral when they are split. Needs the Background master switch on.")
color  bgUpC   = input.color(color.new(#26A69A, 90), "Up", group = G8, inline = "bg1")
color  bgDnC   = input.color(color.new(#EF5350, 90), "Down", group = G8, inline = "bg1")
color  bgNeuC  = input.color(color.new(#787B86, 100), "Neutral", group = G8, inline = "bg1")
int    bgBand  = input.int(1, "Outside band only: band", minval = 1, maxval = 3, group = G8)

// ── 12 · Session shading ─────────────────────────────────────────────────────
bool  shRth   = input.bool(true, "RTH", group = G9, inline = "h1")
color shRthC  = input.color(color.new(#F5D547, 94), "", group = G9, inline = "h1")
bool  shAsia  = input.bool(false, "Asia", group = G9, inline = "h1")
color shAsiaC = input.color(color.new(#B388FF, 94), "", group = G9, inline = "h1")
bool  shLon   = input.bool(false, "London", group = G9, inline = "h2")
color shLonC  = input.color(color.new(#4C8DFF, 94), "", group = G9, inline = "h2")
bool  shCus   = input.bool(false, "Custom", group = G9, inline = "h2")
color shCusC  = input.color(color.new(#FF9800, 94), "", group = G9, inline = "h2", tooltip = "Shades the session windows set in group 2. Independent of which window feeds the VWAP. Where windows overlap, the order is Custom, RTH, London, Asia. Needs the Session shading master switch on.")

// ── 13 · Price labels ────────────────────────────────────────────────────────
string lblSize  = input.string("Small", "Text size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = G10, inline = "l1")
int    lblOff   = input.int(3, "offset (bars)", minval = 0, maxval = 200, group = G10, inline = "l1")
bool   lblPrice = input.bool(true, "show the price", group = G10, inline = "l2")
bool   lblBands = input.bool(true, "label the bands", group = G10, inline = "l2", tooltip = "Labels at the right edge for the VWAP and each band whose line is drawn. Each label takes its line's color.")

// ── 14 · Info box ────────────────────────────────────────────────────────────
string boxPos  = input.string("Top right", "Position", options = ["Top left", "Top center", "Top right", "Middle left", "Middle right", "Bottom left", "Bottom center", "Bottom right"], group = G11)
string boxSize = input.string("Small", "Text size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = G11)
color  boxTxtC = input.color(#C9D1DC, "Text", group = G11, inline = "bx")
color  boxLblC = input.color(#8B8B98, "labels", group = G11, inline = "bx")
color  boxBgC  = input.color(color.new(#0D0D12, 15), "bg", group = G11, inline = "bx")
color  boxFrC  = input.color(#3A3F4B, "frame", group = G11, inline = "bx")

// ── 15 · Alerts ──────────────────────────────────────────────────────────────
bool aCross = input.bool(true, "Price crosses the VWAP", group = G12)
bool aOut   = input.bool(true, "Close outside the band", group = G12)
bool aIn    = input.bool(true, "Close back inside the band", group = G12)
bool aMdp   = input.bool(true, "MDP print", group = G12)
bool aCtx   = input.bool(false, "MDP × VWAP context print (at or above the minimum score)", group = G12)
bool aSetup = input.bool(true, "Setup triggered", group = G12)
int  aBand  = input.int(1, "Alert band", minval = 1, maxval = 3, group = G12, tooltip = "Which band the outside / back-inside alerts watch. All alerts fire once, on the bar close.")

// ── 16 · MDP × VWAP context and setups ───────────────────────────────────────
// Read-only on the MDP engine. Nothing in this group feeds back into which bar
// qualifies as a print, how prints are ranked, or how they are painted.
float  ctxSigma   = input.float(1.5, "Edge of value (σ)", minval = 0.25, maxval = 5.0, step = 0.25, group = G13, inline = "x1")
float  ctxClose   = input.float(0.6, "strong close at", minval = 0.5, maxval = 1.0, step = 0.05, group = G13, inline = "x1", tooltip = "Edge of value = how many standard deviations from the VWAP a print has to reach, with its high or its low, to count as being at the edge. It is also the level a reversal setup has to reclaim.\n\nDefault 1.5 from one year of MES 5-minute bars on a 1-session VWAP: price closes outside 1σ on 53% of bars, outside 1.5σ on 30%, outside 2σ on 14% and outside 3σ on 2%. A first close outside 1σ or 1.5σ drifted back by about a third of an ATR over the next three hours on average; outside 2σ and 3σ it did not. 1σ is too common to call an edge, so 1.5σ is the default.\n\nStrong close = how far through its own range a bar must close to count as closing with conviction. 0.6 means the top 40% of the bar for an up read and the bottom 40% for a down read.")
int    ctxMin     = input.int(2, "Minimum score to label / alert", minval = 1, maxval = 3, group = G13, tooltip = "CONTINUATION is aggression only, one point each for: price closed on the delta's side of the VWAP, the VWAP is sloping that way, the bar closed strongly that way.\n\nREVERSAL is any print at the edge of value, one point each for: it reached the band, the flow failed there, the bar closed back toward value. 'The flow failed' means absorption with the delta pushing INTO the edge (sellers hitting the lower band and getting filled), or aggression pointing back toward value.\n\nAnything else is RAW: a valid print with no VWAP reason to rank it higher.")
string ctxTxt     = input.string("Short", "Label text", options = ["Short", "Full"], group = G13, inline = "x2")
string ctxLblSize = input.string("Tiny", "size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = G13, inline = "x2")
color  ctxContC   = input.color(#00897B, "Continuation", group = G13, inline = "x3")
color  ctxRevC    = input.color(#C2185B, "reversal", group = G13, inline = "x3")
color  ctxRawC    = input.color(#555B66, "raw", group = G13, inline = "x3")
color  ctxTextC   = input.color(color.white, "text", group = G13, inline = "x3")
bool   ctxShowRaw = input.bool(false, "label raw prints too", group = G13, inline = "x4")
int    ctxKeep    = input.int(60, "labels kept", minval = 0, maxval = 150, group = G13, inline = "x4", tooltip = "Context labels sit above the bar so they never cover the AGG / ABS signal underneath it.")
bool   ctxLine    = input.bool(true, "Draw the edge-of-value lines", group = G13, inline = "x5")
color  ctxLineC   = input.color(color.new(#C2185B, 30), "", group = G13, inline = "x5")
int    ctxLineW   = input.int(1, "w", minval = 1, maxval = 6, group = G13, inline = "x5")
bool   suRevOn    = input.bool(true, "Reversal setups", group = G13, inline = "s1")
bool   suTrendOn  = input.bool(true, "Trend setups", group = G13, inline = "s1", tooltip = "UNTESTED. In 16 sessions of 1-minute-estimated delta the reversal setup fired about once a week and moved against itself on average; the trend setup fired about once a session with the right sign but well inside the noise. A year of bar data shows no continuation from VWAP side and slope alone. Treat both as ideas to watch, not signals.\n\nReversal: a REVERSAL print at the edge of value, then a close back inside the edge within the window below. Cancelled if price closes beyond the print's own extreme first.\n\nTrend: a CONTINUATION print with the VWAP sloping its way, then the following closes hold the VWAP.")
string suRevSrc   = input.string("Absorption prints only", "Reversal: armed by", options = ["Absorption prints only", "Any reversal print"], group = G13, tooltip = "Absorption prints only (default): the reversal setup needs an absorption print at the edge. Any reversal print also lets an aggression print pointing back toward value arm it.")
int    suMinScore = input.int(2, "Minimum context score to arm", minval = 1, maxval = 3, group = G13)
int    suWindow   = input.int(12, "Reversal: bars allowed to reclaim", minval = 0, maxval = 200, group = G13, inline = "s2")
string suSlope    = input.string("Turning", "VWAP slope", options = ["Off", "Turning", "Aligned"], group = G13, inline = "s2", tooltip = "How long after the print price has to close back inside the band. 0 = the print bar itself must do it.\n\nVWAP slope rule for the reversal. Off: ignored. Turning (default): the slope is already the trade's way OR is improving that way against the slope setting in group 4. Aligned: the VWAP must already be sloping the trade's way, which is rare at the edge of value.")
int    suHold     = input.int(3, "Trend: closes that must hold the VWAP", minval = 0, maxval = 50, group = G13, tooltip = "After a continuation print, this many closes in a row have to stay on the print's side of the VWAP, with the slope not turning against it. 0 = the setup triggers on the print bar.")
string suBias     = input.string("Off", "Bias filter", options = ["Off", "Majority of EMA lines", "All EMA lines"], group = G13, tooltip = "Only let a setup trigger when its direction agrees with the EMA bias stack (group 17). Majority = more than half of the enabled lines. All = every enabled line. Off by default: in testing the EMA lines separated quiet markets from volatile ones far better than they predicted direction.")
string suTxtLong  = input.string("STRYK LONG", "Text: reversal long", group = G13, inline = "t1")
string suTxtShort = input.string("STRYK SHORT", "short", group = G13, inline = "t1")
string suTxtTL    = input.string("TREND LONG", "Text: trend long", group = G13, inline = "t2")
string suTxtTS    = input.string("TREND SHORT", "short", group = G13, inline = "t2")
color  suLongC    = input.color(#26A69A, "Long", group = G13, inline = "t3")
color  suShortC   = input.color(#EF5350, "short", group = G13, inline = "t3")
color  suTextC    = input.color(color.white, "text", group = G13, inline = "t3")
string suStyle    = input.string("Label", "Marker", options = ["Label", "Triangle", "Arrow"], group = G13, inline = "t4")
string suSize     = input.string("Small", "size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = G13, inline = "t4")
float  suOff      = input.float(1.0, "Marker offset (ATR)", minval = 0.0, maxval = 10.0, step = 0.25, group = G13, inline = "t5")
int    suKeep     = input.int(40, "kept", minval = 0, maxval = 150, group = G13, inline = "t5", tooltip = "Setup markers sit this many ATRs beyond the bar so they clear the MDP signal label. Hover a marker to see its invalidation level.")
bool   suInvLine  = input.bool(true, "Reversal: draw the invalidation level", group = G13, inline = "t6")
color  suInvC     = input.color(#787B86, "", group = G13, inline = "t6")
int    suInvW     = input.int(1, "w", minval = 1, maxval = 4, group = G13, inline = "t6", tooltip = "A dotted line at the print's own extreme while a reversal setup is armed. A close beyond it cancels the setup and removes the line.")

// ── 17 · EMA bias lines ──────────────────────────────────────────────────────
int    e1Len    = input.int(233, "Chart EMA: length (bars)", minval = 1, maxval = 5000, group = G14, inline = "e1a")
string e1Type   = input.string("EMA", "", options = ["EMA", "SMA", "RMA", "WMA"], group = G14, inline = "e1a")
float  e1Src    = input.source(close, "", group = G14, inline = "e1a", tooltip = "Built from the bars of whatever chart you are on. 233 bars on a 5-minute chart is about 19.4 hours, close to one futures session.")
string e1ColM   = input.string("Solid", "color by", options = ["Solid", "Price side", "Slope"], group = G14, inline = "e1b")
color  e1Col    = input.color(#FFFFFF, "", group = G14, inline = "e1b")
color  e1UpC    = input.color(#26A69A, "up", group = G14, inline = "e1b")
color  e1DnC    = input.color(#EF5350, "down", group = G14, inline = "e1b")
int    e1W      = input.int(2, "w", minval = 1, maxval = 10, group = G14, inline = "e1c")
string e1Sty    = input.string("Solid", "", options = ["Solid", "Stepline", "Dotted", "Cross"], group = G14, inline = "e1c")
int    e1SlopeN = input.int(12, "slope over (bars)", minval = 1, maxval = 250, group = G14, inline = "e1c")
int    e2Len    = input.int(50, "Daily EMA: length (days)", minval = 1, maxval = 1000, group = G14, inline = "e2a")
string e2Type   = input.string("EMA", "", options = ["EMA", "SMA", "RMA", "WMA"], group = G14, inline = "e2a")
string e2Src    = input.string("Close", "", options = ["Close", "HLC3", "OHLC4"], group = G14, inline = "e2a", tooltip = "Built from DAILY bars, never from chart bars, so the level is identical on a 1-minute chart and a daily one.")
bool   e2Live   = input.bool(true, "include the forming day", group = G14, inline = "e2d", tooltip = "ON: today's price moves the line, exactly as a daily chart shows it, so the level shifts during the day.\n\nOFF: only completed days count. The level is fixed for the whole session and never changes afterwards.")
string e2ColM   = input.string("Solid", "color by", options = ["Solid", "Price side", "Slope"], group = G14, inline = "e2b")
color  e2Col    = input.color(#00BCD4, "", group = G14, inline = "e2b")
color  e2UpC    = input.color(#26A69A, "up", group = G14, inline = "e2b")
color  e2DnC    = input.color(#EF5350, "down", group = G14, inline = "e2b")
int    e2W      = input.int(2, "w", minval = 1, maxval = 10, group = G14, inline = "e2c")
string e2Sty    = input.string("Solid", "", options = ["Solid", "Stepline", "Dotted", "Cross"], group = G14, inline = "e2c")
int    e2SlopeN = input.int(3, "slope over (days)", minval = 1, maxval = 100, group = G14, inline = "e2c")
int    e3Len    = input.int(20, "Weekly EMA: length (weeks)", minval = 1, maxval = 500, group = G14, inline = "e3a")
string e3Type   = input.string("EMA", "", options = ["EMA", "SMA", "RMA", "WMA"], group = G14, inline = "e3a")
string e3Src    = input.string("Close", "", options = ["Close", "HLC3", "OHLC4"], group = G14, inline = "e3a", tooltip = "Built from WEEKLY bars. Switch the type to SMA to match the 20-week line in STRYK:20W; over 26 years of daily ES the two sat on the same side of price 96% of the time.")
bool   e3Live   = input.bool(true, "include the forming week", group = G14, inline = "e3d")
string e3ColM   = input.string("Solid", "color by", options = ["Solid", "Price side", "Slope"], group = G14, inline = "e3b")
color  e3Col    = input.color(#FFD700, "", group = G14, inline = "e3b")
color  e3UpC    = input.color(#26A69A, "up", group = G14, inline = "e3b")
color  e3DnC    = input.color(#EF5350, "down", group = G14, inline = "e3b")
int    e3W      = input.int(3, "w", minval = 1, maxval = 10, group = G14, inline = "e3c")
string e3Sty    = input.string("Solid", "", options = ["Solid", "Stepline", "Dotted", "Cross"], group = G14, inline = "e3c")
int    e3SlopeN = input.int(2, "slope over (weeks)", minval = 1, maxval = 52, group = G14, inline = "e3c")
bool   biasSlope = input.bool(false, "Bias vote needs the line's slope to agree", group = G14, tooltip = "Each enabled line votes UP when price is above it and DOWN when below. With this ON a vote also needs that line to be sloping the same way, otherwise it abstains. The votes make the Bias stack row of the info box, the Bias stack background mode and the setups' bias filter.")
bool   biasConfirmed = input.bool(true, "Bias votes use completed days / weeks only", group = G14, tooltip = "ON (default): the daily and weekly votes are taken against the last COMPLETED day and week, so the bias stack, the bias background and the setups' bias filter cannot shift while a day or week is still forming. The drawn lines still follow their own 'include the forming day / week' setting.\n\nOFF: the votes follow the lines exactly as drawn.\n\nOn historical bars a completed value is one extra day or week old compared with live bars. For a 50-day or 20-week average that difference is negligible.")
bool   eLabels  = input.bool(true, "Label the EMA lines at the right edge", group = G14, tooltip = "Uses the size and offset from the Price labels group and its master switch.")


// ── 18 · 20-week ATR bands (from STRYK:20W) ──────────────────────────────────
string wBasis  = input.string("Weekly ATR", "Band width from", options = ["Weekly ATR", "Weekly standard deviation"], group = G15, tooltip = "Weekly ATR (default): the STRYK:20W method. Each band sits a multiple of the weekly ATR from the line.\n\nWeekly standard deviation: each band sits a multiple of the standard deviation of weekly prices over the same number of weeks as the line, the way a Bollinger band is built.")
int    wAtrLen = input.int(14, "Weekly ATR length", minval = 1, maxval = 100, group = G15, tooltip = "ATR of the WEEKLY bars. Each band sits a multiple of it away from the weekly EMA set in group 17, so the bands follow that line's length, type, source and forming-week setting. The line shape in group 3 applies to these bands too: Smooth glides them, Raw shows the weekly steps, Stepped (forced) holds and jumps once a week.")
bool   w1On    = input.bool(true, "Band 1", group = G15, inline = "w1a")
float  w1Mult  = input.float(1.0, "×", minval = 0.1, maxval = 20.0, step = 0.25, group = G15, inline = "w1a")
bool   w1Line  = input.bool(true, "draw line", group = G15, inline = "w1a", tooltip = "Untick the band to remove it entirely. Untick 'draw line' to hide the line but keep its fills and label.")
color  w1UpC   = input.color(#4A5568, "upper", group = G15, inline = "w1b")
color  w1LoC   = input.color(#4A5568, "lower", group = G15, inline = "w1b")
int    w1W     = input.int(1, "w", minval = 1, maxval = 10, group = G15, inline = "w1b")
string w1Sty   = input.string("Solid", "", options = ["Solid", "Stepline", "Dotted", "Cross"], group = G15, inline = "w1b")
bool   w2On    = input.bool(true, "Band 2", group = G15, inline = "w2a")
float  w2Mult  = input.float(2.0, "×", minval = 0.1, maxval = 20.0, step = 0.25, group = G15, inline = "w2a")
bool   w2Line  = input.bool(true, "draw line", group = G15, inline = "w2a")
color  w2UpC   = input.color(#5A6578, "upper", group = G15, inline = "w2b")
color  w2LoC   = input.color(#5A6578, "lower", group = G15, inline = "w2b")
int    w2W     = input.int(1, "w", minval = 1, maxval = 10, group = G15, inline = "w2b")
string w2Sty   = input.string("Solid", "", options = ["Solid", "Stepline", "Dotted", "Cross"], group = G15, inline = "w2b")
bool   w3On    = input.bool(true, "Band 3", group = G15, inline = "w3a")
float  w3Mult  = input.float(3.0, "×", minval = 0.1, maxval = 20.0, step = 0.25, group = G15, inline = "w3a")
bool   w3Line  = input.bool(true, "draw line", group = G15, inline = "w3a")
color  w3UpC   = input.color(#6A7588, "upper", group = G15, inline = "w3b")
color  w3LoC   = input.color(#6A7588, "lower", group = G15, inline = "w3b")
int    w3W     = input.int(1, "w", minval = 1, maxval = 10, group = G15, inline = "w3b")
string w3Sty   = input.string("Solid", "", options = ["Solid", "Stepline", "Dotted", "Cross"], group = G15, inline = "w3b", tooltip = "Every band takes its own upper color, lower color, width and style.")
bool   wfInOn   = input.bool(false, "Fill: line to band 1", group = G15, inline = "wf1")
color  wfInUpC  = input.color(color.new(#2F6FED, 94), "upper", group = G15, inline = "wf1")
color  wfInDnC  = input.color(color.new(#2F6FED, 94), "lower", group = G15, inline = "wf1")
bool   wfMidOn  = input.bool(false, "Fill: band 1 to band 2", group = G15, inline = "wf2")
color  wfMidUpC = input.color(color.new(#00FF88, 95), "upper", group = G15, inline = "wf2")
color  wfMidDnC = input.color(color.new(#FF1744, 95), "lower", group = G15, inline = "wf2")
bool   wfOutOn  = input.bool(true, "Fill: band 2 to band 3", group = G15, inline = "wf3")
color  wfOutUpC = input.color(color.new(#00FF88, 92), "upper", group = G15, inline = "wf3")
color  wfOutDnC = input.color(color.new(#FF1744, 92), "lower", group = G15, inline = "wf3", tooltip = "Six separate fills, each with its own color; transparency lives in the color picker. A fill needs both of its bands switched on. The band 2 to band 3 zone is where price is getting far from the weekly line.")
bool   wLabels  = input.bool(true, "Label the bands at the right edge", group = G15, tooltip = "Uses the size and offset from the Price labels group and its master switch.")


// ── 19 · Context research (private) ──────────────────────────────────────────
int    cxRFwdBars = input.int(36, "Forward bars", minval = 1, maxval = 500, group = G16, inline = "r1")
int    cxRMaxOpen = input.int(150, "max open events", minval = 10, maxval = 500, group = G16, inline = "r1", tooltip = "How many bars each event is followed for (36 = three hours on a 5-minute chart) and how many can be tracked at once. Events beyond the cap are dropped oldest-first and never counted.")
int    cxRCtrlN   = input.int(25, "Control: sample every N bars", minval = 0, maxval = 500, group = G16, tooltip = "The column that makes the others mean something. Ordinary bars are sampled at this interval and measured the same way, in the direction of their own delta. A print column only tells you something where it differs from the control by more than its ± error. 0 turns the control off.")
string cxRPos     = input.string("Bottom left", "Position", options = ["Top left", "Top center", "Top right", "Middle left", "Middle right", "Bottom left", "Bottom center", "Bottom right"], group = G16, inline = "r2")
string cxRSize    = input.string("Tiny", "size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = G16, inline = "r2", tooltip = "Every event is measured from its own bar close, in ATR(14) at the time it fired, in the direction of its read: reversal and continuation prints in the context direction, raw prints in the delta direction for aggression and against it for absorption, setups in the setup direction. Setup columns only fill while the Setups master switch is ON.")


// ── Helpers ──────────────────────────────────────────────────────────────────
f_size(string s) =>
    s == "Tiny" ? size.tiny : s == "Small" ? size.small : s == "Large" ? size.large : s == "Huge" ? size.huge : size.normal

f_pos(string p) =>
    p == "Top left" ? position.top_left : p == "Top center" ? position.top_center : p == "Top right" ? position.top_right : p == "Middle left" ? position.middle_left : p == "Middle right" ? position.middle_right : p == "Bottom left" ? position.bottom_left : p == "Bottom center" ? position.bottom_center : position.bottom_right

// length of a session string such as "0830-1500", in hours (wraps past midnight)
f_sessHours(string s) =>
    float h1 = str.tonumber(str.substring(s, 0, 2))
    float m1 = str.tonumber(str.substring(s, 2, 4))
    float h2 = str.tonumber(str.substring(s, 5, 7))
    float m2 = str.tonumber(str.substring(s, 7, 9))
    float d  = (h2 * 60.0 + m2 - h1 * 60.0 - m1) / 60.0
    float r  = d <= 0 ? d + 24.0 : d
    na(r) ? 23.0 : r

// TradingView's automatic clock period for the chart timeframe, in milliseconds
f_autoMs() =>
    int tfMs = timeframe.in_seconds() * 1000
    float stepMs = tfMs <= 60000 ? 3600000.0 : tfMs <= 300000 ? 14400000.0 : tfMs <= 3600000 ? 86400000.0 : tfMs <= 14400000 ? 259200000.0 : tfMs <= 43200000 ? 604800000.0 : tfMs <= 86400000 ? 2629800000.0 : tfMs <= 604800000 ? 7776000000.0 : 31536000000.0
    stepMs

// a clock span written out as days / hours / minutes
f_spanText(float ms) =>
    int totalMin = int(ms / 60000.0)
    int d  = int(totalMin / 1440)
    int hh = int((totalMin % 1440) / 60)
    int mm = totalMin % 60
    string out = (d > 0 ? str.tostring(d) + "D " : "") + (hh > 0 ? str.tostring(hh) + "H " : "") + (mm > 0 ? str.tostring(mm) + "min" : "")
    out == "" ? "0min" : out

// one EMA pass with no ta.* state, safe to chain and safe through na gaps
f_ema(float x, int len) =>
    float a = 2.0 / (len + 1)
    float e = na
    e := na(x) ? e[1] : na(e[1]) ? x : a * x + (1.0 - a) * e[1]
    e

// multi-pass smoothing: every pass runs on every bar, the settings select one
f_multi(float x, int len) =>
    float p1 = f_ema(x, len)
    float p2 = f_ema(p1, len)
    float p3 = f_ema(p2, len)
    smPassEff == 0 ? x : smPassEff == 1 ? p1 : smPassEff == 2 ? p2 : p3

f_smooth(float x) =>
    f_multi(x, smLenEff)

// sample-and-hold: takes a new value only when `roll` is true (forced steps)
f_hold(float x, bool roll) =>
    var float hv = na
    if roll or na(hv)
        hv := x
    hv

// a straight line from the previous higher-timeframe value to the current one,
// drawn across that timeframe's bar in proportion to progress through it
f_ramp(float raw, bool roll, float barsPer) =>
    var float prev = na
    var int   startBar = na
    if roll or na(startBar)
        prev := na(prev) ? raw : nz(raw[1], prev)
        startBar := bar_index
    float frac = na(startBar) ? 1.0 : math.min(1.0, (bar_index - startBar) / math.max(1.0, barsPer))
    na(prev) or na(raw) ? raw : prev + (raw - prev) * frac

// moving average by type: all four run on every bar, the input selects one
f_maSel(float s, simple int len, simple string typ) =>
    float mE = ta.ema(s, len)
    float mS = ta.sma(s, len)
    float mR = ta.rma(s, len)
    float mW = ta.wma(s, len)
    typ == "SMA" ? mS : typ == "RMA" ? mR : typ == "WMA" ? mW : mE

// higher-timeframe average: live value, last completed value, and both slopes
f_htfMa(simple string srcSel, simple int len, simple string typ, simple int slopeN) =>
    float px = srcSel == "HLC3" ? hlc3 : srcSel == "OHLC4" ? ohlc4 : close
    float ma = f_maSel(px, len, typ)
    [ma, ma[1], ma - ma[slopeN], ma[1] - ma[1 + slopeN]]

// weekly average plus the weekly ATR, from ONE weekly request so the two can
// never disagree about which week they describe
f_htfMaAtr(simple string srcSel, simple int len, simple string typ, simple int slopeN, simple int atrLen) =>
    float px = srcSel == "HLC3" ? hlc3 : srcSel == "OHLC4" ? ohlc4 : close
    float ma = f_maSel(px, len, typ)
    float av = ta.atr(atrLen)
    float sv = ta.stdev(px, len)
    [ma, ma[1], ma - ma[slopeN], ma[1] - ma[1 + slopeN], av, av[1], sv, sv[1]]


// ── Session windows (every time() call runs on every bar) ────────────────────
string winEff = mWinFilter ? winSel : "All bars (ETH)"
string tz     = tzSel == "Exchange" ? syminfo.timezone : tzSel
bool   inRth  = not na(time(timeframe.period, sRth, tz))
bool   inAsia = not na(time(timeframe.period, sAsia, tz))
bool   inLon  = not na(time(timeframe.period, sLon, tz))
bool   inCus  = not na(time(timeframe.period, sCus, tz))
bool   allBars = winEff == "All bars (ETH)"
bool   inWin  = winEff == "RTH" ? inRth : winEff == "Overnight (outside RTH)" ? not inRth : winEff == "Asia" ? inAsia : winEff == "London" ? inLon : winEff == "Custom" ? inCus : true

// hours of trading in one pass of the selected window
float winHours = winEff == "RTH" ? f_sessHours(sRth) : winEff == "Overnight (outside RTH)" ? math.max(0.25, ethHours - f_sessHours(sRth)) : winEff == "Asia" ? f_sessHours(sAsia) : winEff == "London" ? f_sessHours(sLon) : winEff == "Custom" ? f_sessHours(sCus) : ethHours

// ── Lookback → window size ───────────────────────────────────────────────────
const int MAXQ = 50000
int   tfSec = math.max(1, timeframe.in_seconds())
// chart bars in one session: trading hours on intraday charts, calendar units above
float barsPerSess = timeframe.isintraday ? winHours * 3600.0 / tfSec : timeframe.isdaily ? 1.0 / timeframe.multiplier : timeframe.isweekly ? 1.0 / (5.0 * timeframe.multiplier) : 1.0 / (21.0 * timeframe.multiplier)
float sessN = lbPreset == "¼ session" ? 0.25 : lbPreset == "½ session" ? 0.5 : lbPreset == "1 session" ? 1.0 : lbPreset == "2 sessions" ? 2.0 : lbPreset == "3 sessions" ? 3.0 : lbPreset == "1 week (5 sessions)" ? 5.0 : lbPreset == "2 weeks (10 sessions)" ? 10.0 : lbPreset == "1 month (21 sessions)" ? 21.0 : lbPreset == "1 quarter (63 sessions)" ? 63.0 : cSess + (cHours + cMins / 60.0) / winHours
int   sessBars = int(math.round(sessN * barsPerSess))
bool  useTime  = lbMode == "Clock time" or lbMode == "Auto (TradingView)"
bool  isAnch   = lbMode == "Anchored"
int   winBars  = math.min(MAXQ, math.max(minBars, lbMode == "Fixed bars" ? fixBars : sessBars))
float winMs    = lbMode == "Clock time" ? ckDays * 86400000.0 + ckHours * 3600000.0 + ckMins * 60000.0 : f_autoMs()

// anchors (every timeframe.change() runs on every bar; the input selects one)
bool newSess   = timeframe.change("D")
bool newWeek   = timeframe.change("W")
bool newMonth  = timeframe.change("M")
bool winStart  = inWin and not inWin[1]
bool anchorNow = ancType == "Week" ? newWeek : ancType == "Month" ? newMonth : allBars ? newSess : winStart

// ── Rolling engine — one queue, running sums ─────────────────────────────────
// Closed bars are stored once. The forming bar is added on top without touching
// the stored state, so the live value is always the exact window and nothing is
// double-counted between ticks. Prices are stored as an offset from the first
// bar's price, which keeps the variance arithmetic precise at index-level prices.
var array<float> qV  = array.new_float()
var array<float> qPV = array.new_float()
var array<float> qP2 = array.new_float()
var array<int>   qT  = array.new_int()
var int   qHead = 0
var float sV   = 0.0
var float sPV  = 0.0
var float sP2  = 0.0
var float pBase = na
if na(pBase) and not na(src)
    pBase := src

float vNow = nz(volume)
float pNow = nz(src - pBase)
bool  inc  = inWin and not na(src) and not na(pBase)
int   qAdd  = inc ? 1 : 0
int   qN    = qT.size() - qHead

// how many of the oldest stored bars fall out of the window on this bar
int   qDrop = 0
float dV   = 0.0
float dPV  = 0.0
float dP2  = 0.0
if isAnch and anchorNow
    qDrop := qN
else
    int keep = isAnch or useTime ? MAXQ : winBars
    while qDrop < qN
        int  i      = qHead + qDrop
        int  left   = qN - qDrop + qAdd
        bool byTime = useTime and time - qT.get(i) >= winMs and left > minBars
        if not (byTime or left > keep)
            break
        dV  += qV.get(i)
        dPV += qPV.get(i)
        dP2 += qP2.get(i)
        qDrop += 1

bool  emptied = qDrop >= qN
float lV  = (emptied ? 0.0 : sV  - dV)  + (inc ? vNow : 0.0)
float lPV = (emptied ? 0.0 : sPV - dPV) + (inc ? pNow * vNow : 0.0)
float lP2 = (emptied ? 0.0 : sP2 - dP2) + (inc ? pNow * pNow * vNow : 0.0)
int   nWin = qN - qDrop + qAdd

if barstate.isconfirmed
    qHead += qDrop
    if inc
        qV.push(vNow)
        qPV.push(pNow * vNow)
        qP2.push(pNow * pNow * vNow)
        qT.push(time)
    sV  := lV
    sPV := lPV
    sP2 := lP2
    // every so often, discard the dead front of the queue and rebuild the sums
    // from scratch so rounding can never build up over a long chart
    if qHead >= 5000
        if qHead >= qT.size()
            qV.clear()
            qPV.clear()
            qP2.clear()
            qT.clear()
        else
            qV  := qV.slice(qHead, qV.size()).copy()
            qPV := qPV.slice(qHead, qPV.size()).copy()
            qP2 := qP2.slice(qHead, qP2.size()).copy()
            qT  := qT.slice(qHead, qT.size()).copy()
        qHead := 0
        sV  := nz(qV.sum())
        sPV := nz(qPV.sum())
        sP2 := nz(qP2.sum())

var float cumVol = 0.0
cumVol += vNow
if barstate.islast and cumVol == 0
    runtime.error("STRYK:DRE needs volume. This symbol has no volume data.")

float mean  = lV > 0 ? lPV / lV : na
float vwRaw = pBase + mean
float sdRaw = lV > 0 ? math.sqrt(math.max(lP2 / lV - mean * mean, 0.0)) : na

// smoothing runs every bar; hiding outside the window gates the result
float vwS = f_smooth(vwRaw)
float sdS = f_smooth(sdRaw)
bool  showLine = outMode == "Hold the line" or inWin
float vw = showLine ? vwS : na
float sd = showLine ? sdS : na
bool  has = not na(vw) and not na(sd)

// ── Bands, distance, slope ───────────────────────────────────────────────────
float u1 = vw + b1Mult * sd
float l1 = vw - b1Mult * sd
float u2 = vw + b2Mult * sd
float l2 = vw - b2Mult * sd
float u3 = vw + b3Mult * sd
float l3 = vw - b3Mult * sd
float z  = has and sd > 0 ? (close - vw) / sd : na

float slope   = vw - vw[slopeLen]
float flatPts = flatTicks * syminfo.mintick
bool  rising  = not na(slope) and slope > flatPts
bool  falling = not na(slope) and slope < -flatPts

// ── Display values — the forced-step shape changes the drawing, not the maths ─
bool  stepRoll = timeframe.change(stepTf)
float hVw = f_hold(vw, stepRoll)
float hSd = f_hold(sd, stepRoll)
float dVw = shapeStep ? hVw : vw
float dSd = shapeStep ? hSd : sd
float dU1 = dVw + b1Mult * dSd
float dL1 = dVw - b1Mult * dSd
float dU2 = dVw + b2Mult * dSd
float dL2 = dVw - b2Mult * dSd
float dU3 = dVw + b3Mult * dSd
float dL3 = dVw - b3Mult * dSd

// ── EMA bias lines ───────────────────────────────────────────────────────────
// chart bars in one trading day and one trading week, from the session length
float barsDay  = timeframe.isintraday ? math.max(1.0, ethHours * 3600.0 / tfSec) : 1.0
float barsWeek = timeframe.isintraday ? barsDay * 5.0 : timeframe.isdaily ? math.max(1.0, 5.0 / timeframe.multiplier) : 1.0
int   lenDay   = math.min(1000, math.max(2, int(math.round(0.25 * barsDay * smMult))))
int   lenWeek  = math.min(1000, math.max(2, int(math.round(0.25 * barsWeek * smMult))))

// chart EMA
float e1Raw   = f_maSel(e1Src, e1Len, e1Type)
float e1Sm    = f_smooth(e1Raw)
float e1Hold  = f_hold(e1Raw, stepRoll)
float e1Plot  = shapeStep ? e1Hold : e1Sm
float e1Slope = e1Raw - e1Raw[e1SlopeN]

// daily and weekly EMAs: one request each. lookahead_off never shows a future
// value; the completed-bar mode reads one bar back inside the request.
[e2LiveV, e2PrevV, e2LiveS, e2PrevS] = request.security(syminfo.tickerid, "D", f_htfMa(e2Src, e2Len, e2Type, e2SlopeN), lookahead = barmerge.lookahead_off)
[e3LiveV, e3PrevV, e3LiveS, e3PrevS, wAtrLive, wAtrPrev, wSdLive, wSdPrev] = request.security(syminfo.tickerid, "W", f_htfMaAtr(e3Src, e3Len, e3Type, e3SlopeN, wAtrLen), lookahead = barmerge.lookahead_off)
float e2Raw   = e2Live ? e2LiveV : e2PrevV
float e2Slope = e2Live ? e2LiveS : e2PrevS
float e3Raw   = e3Live ? e3LiveV : e3PrevV
float e3Slope = e3Live ? e3LiveS : e3PrevS
bool  dayRollE  = timeframe.change("D")
bool  weekRollE = timeframe.change("W")
float e2Ramp  = f_ramp(e2Raw, dayRollE, barsDay)
float e3Ramp  = f_ramp(e3Raw, weekRollE, barsWeek)
float e2Sm    = f_multi(e2Ramp, lenDay)
float e3Sm    = f_multi(e3Ramp, lenWeek)
float e2Hold  = f_hold(e2Raw, dayRollE)
float e3Hold  = f_hold(e3Raw, weekRollE)
bool  shapeSmooth = shapeMode == "Smooth" and mSmooth
float e2Plot  = shapeStep ? e2Hold : shapeSmooth ? e2Sm : e2Raw
float e3Plot  = shapeStep ? e3Hold : shapeSmooth ? e3Sm : e3Raw

// weekly ATR bands around the weekly EMA: the ATR is shaped by the same rule as
// the line, or the bands would still step every week while the line glides
bool   wUseAtr = wBasis == "Weekly ATR"
string wUnit   = wUseAtr ? "ATR" : "σ"
float wAtrRaw  = wUseAtr ? (e3Live ? wAtrLive : wAtrPrev) : (e3Live ? wSdLive : wSdPrev)
float wAtrRamp = f_ramp(wAtrRaw, weekRollE, barsWeek)
float wAtrSm   = f_multi(wAtrRamp, lenWeek)
float wAtrHold = f_hold(wAtrRaw, weekRollE)
float wAtrPlot = shapeStep ? wAtrHold : shapeSmooth ? wAtrSm : wAtrRaw
bool  wHave    = not na(e3Plot) and not na(wAtrPlot) and wAtrPlot > 0
bool  wAny     = mW20Bands or mW20Fills
float wU1 = e3Plot + w1Mult * wAtrPlot
float wL1 = e3Plot - w1Mult * wAtrPlot
float wU2 = e3Plot + w2Mult * wAtrPlot
float wL2 = e3Plot - w2Mult * wAtrPlot
float wU3 = e3Plot + w3Mult * wAtrPlot
float wL3 = e3Plot - w3Mult * wAtrPlot
// distance from the weekly line in weekly ATR, measured from the live values
float wStretch = not na(e3Raw) and not na(wAtrRaw) and wAtrRaw > 0 ? (close - e3Raw) / wAtrRaw : na

// bias stack: one vote per enabled line
f_vote(float ln, float sl) =>
    na(ln) ? 0 : close > ln and (not biasSlope or nz(sl) > 0) ? 1 : close < ln and (not biasSlope or nz(sl) < 0) ? -1 : 0
int  bV1 = mEma1 ? f_vote(e1Raw, e1Slope) : 0
float e2Sig  = biasConfirmed ? e2PrevV : e2Raw
float e2SigS = biasConfirmed ? e2PrevS : e2Slope
float e3Sig  = biasConfirmed ? e3PrevV : e3Raw
float e3SigS = biasConfirmed ? e3PrevS : e3Slope
int  bV2 = mEma2 ? f_vote(e2Sig, e2SigS) : 0
int  bV3 = mEma3 ? f_vote(e3Sig, e3SigS) : 0
int  biasCnt = (mEma1 ? 1 : 0) + (mEma2 ? 1 : 0) + (mEma3 ? 1 : 0)
int  biasUp  = (bV1 == 1 ? 1 : 0) + (bV2 == 1 ? 1 : 0) + (bV3 == 1 ? 1 : 0)
int  biasDn  = (bV1 == -1 ? 1 : 0) + (bV2 == -1 ? 1 : 0) + (bV3 == -1 ? 1 : 0)
int  biasMaj = biasCnt == 0 ? 0 : biasUp * 2 > biasCnt ? 1 : biasDn * 2 > biasCnt ? -1 : 0
int  biasAll = biasCnt == 0 ? 0 : biasUp == biasCnt ? 1 : biasDn == biasCnt ? -1 : 0
f_biasOk(int d) =>
    suBias == "Off" or biasCnt == 0 ? true : suBias == "All EMA lines" ? biasAll == d : biasMaj == d

f_lineCol(string mode, color solid, color upC, color dnC, float ln, float sl) =>
    mode == "Price side" ? (close >= ln ? upC : dnC) : mode == "Slope" ? (nz(sl) > 0 ? upC : nz(sl) < 0 ? dnC : solid) : solid
color e1ColNow = f_lineCol(e1ColM, e1Col, e1UpC, e1DnC, e1Raw, e1Slope)
color e2ColNow = f_lineCol(e2ColM, e2Col, e2UpC, e2DnC, e2Raw, e2Slope)
color e3ColNow = f_lineCol(e3ColM, e3Col, e3UpC, e3DnC, e3Raw, e3Slope)


// ── VWAP, bands, fills ───────────────────────────────────────────────────────
color vwColor = vwColMode == "VWAP slope" ? (rising ? vwUpCol : falling ? vwDnCol : vwFlatCol) : vwColMode == "Price side" ? (close > vw ? vwUpCol : close < vw ? vwDnCol : vwFlatCol) : vwCol
pVw = plot(dVw, "Rolling VWAP", color = mVwap ? vwColor : color.new(vwColor, 100), linewidth = vwW, style = shapeStep or vwSty == "Stepline" ? plot.style_stepline : vwSty == "Dotted" ? plot.style_circles : vwSty == "Cross" ? plot.style_cross : plot.style_line)
pU1 = plot(b1On ? dU1 : na, "Upper band 1", color = mBands and b1Line ? b1UpC : color.new(b1UpC, 100), linewidth = b1W, style = shapeStep or b1Sty == "Stepline" ? plot.style_stepline : b1Sty == "Dotted" ? plot.style_circles : b1Sty == "Cross" ? plot.style_cross : plot.style_line)
pL1 = plot(b1On ? dL1 : na, "Lower band 1", color = mBands and b1Line ? b1LoC : color.new(b1LoC, 100), linewidth = b1W, style = shapeStep or b1Sty == "Stepline" ? plot.style_stepline : b1Sty == "Dotted" ? plot.style_circles : b1Sty == "Cross" ? plot.style_cross : plot.style_line)
pU2 = plot(b2On ? dU2 : na, "Upper band 2", color = mBands and b2Line ? b2UpC : color.new(b2UpC, 100), linewidth = b2W, style = shapeStep or b2Sty == "Stepline" ? plot.style_stepline : b2Sty == "Dotted" ? plot.style_circles : b2Sty == "Cross" ? plot.style_cross : plot.style_line)
pL2 = plot(b2On ? dL2 : na, "Lower band 2", color = mBands and b2Line ? b2LoC : color.new(b2LoC, 100), linewidth = b2W, style = shapeStep or b2Sty == "Stepline" ? plot.style_stepline : b2Sty == "Dotted" ? plot.style_circles : b2Sty == "Cross" ? plot.style_cross : plot.style_line)
pU3 = plot(b3On ? dU3 : na, "Upper band 3", color = mBands and b3Line ? b3UpC : color.new(b3UpC, 100), linewidth = b3W, style = shapeStep or b3Sty == "Stepline" ? plot.style_stepline : b3Sty == "Dotted" ? plot.style_circles : b3Sty == "Cross" ? plot.style_cross : plot.style_line)
pL3 = plot(b3On ? dL3 : na, "Lower band 3", color = mBands and b3Line ? b3LoC : color.new(b3LoC, 100), linewidth = b3W, style = shapeStep or b3Sty == "Stepline" ? plot.style_stepline : b3Sty == "Dotted" ? plot.style_circles : b3Sty == "Cross" ? plot.style_cross : plot.style_line)

fill(pVw, pU1, color = mFills and fInOn ? fInUpC : color(na), title = "Fill · VWAP to upper band 1")
fill(pVw, pL1, color = mFills and fInOn ? fInDnC : color(na), title = "Fill · VWAP to lower band 1")
fill(pU1, pU2, color = mFills and fMidOn ? fMidUpC : color(na), title = "Fill · upper band 1 to 2")
fill(pL1, pL2, color = mFills and fMidOn ? fMidDnC : color(na), title = "Fill · lower band 1 to 2")
fill(pU2, pU3, color = mFills and fOutOn ? fOutUpC : color(na), title = "Fill · upper band 2 to 3")
fill(pL2, pL3, color = mFills and fOutOn ? fOutDnC : color(na), title = "Fill · lower band 2 to 3")
plot(mEma1 ? e1Plot : na, "Chart EMA", color = e1ColNow, linewidth = e1W, style = shapeStep or e1Sty == "Stepline" ? plot.style_stepline : e1Sty == "Dotted" ? plot.style_circles : e1Sty == "Cross" ? plot.style_cross : plot.style_line)
plot(mEma2 ? e2Plot : na, "Daily EMA", color = e2ColNow, linewidth = e2W, style = shapeStep or e2Sty == "Stepline" ? plot.style_stepline : e2Sty == "Dotted" ? plot.style_circles : e2Sty == "Cross" ? plot.style_cross : plot.style_line)
pE3  = plot(mEma3 or wAny ? e3Plot : na, "Weekly EMA", color = mEma3 ? e3ColNow : color.new(e3ColNow, 100), linewidth = e3W, style = shapeStep or e3Sty == "Stepline" ? plot.style_stepline : e3Sty == "Dotted" ? plot.style_circles : e3Sty == "Cross" ? plot.style_cross : plot.style_line)
pWU1 = plot(wAny and wHave and w1On ? wU1 : na, "20W upper ATR band 1", color = mW20Bands and w1Line ? w1UpC : color.new(w1UpC, 100), linewidth = w1W, style = shapeStep or w1Sty == "Stepline" ? plot.style_stepline : w1Sty == "Dotted" ? plot.style_circles : w1Sty == "Cross" ? plot.style_cross : plot.style_line)
pWL1 = plot(wAny and wHave and w1On ? wL1 : na, "20W lower ATR band 1", color = mW20Bands and w1Line ? w1LoC : color.new(w1LoC, 100), linewidth = w1W, style = shapeStep or w1Sty == "Stepline" ? plot.style_stepline : w1Sty == "Dotted" ? plot.style_circles : w1Sty == "Cross" ? plot.style_cross : plot.style_line)
pWU2 = plot(wAny and wHave and w2On ? wU2 : na, "20W upper ATR band 2", color = mW20Bands and w2Line ? w2UpC : color.new(w2UpC, 100), linewidth = w2W, style = shapeStep or w2Sty == "Stepline" ? plot.style_stepline : w2Sty == "Dotted" ? plot.style_circles : w2Sty == "Cross" ? plot.style_cross : plot.style_line)
pWL2 = plot(wAny and wHave and w2On ? wL2 : na, "20W lower ATR band 2", color = mW20Bands and w2Line ? w2LoC : color.new(w2LoC, 100), linewidth = w2W, style = shapeStep or w2Sty == "Stepline" ? plot.style_stepline : w2Sty == "Dotted" ? plot.style_circles : w2Sty == "Cross" ? plot.style_cross : plot.style_line)
pWU3 = plot(wAny and wHave and w3On ? wU3 : na, "20W upper ATR band 3", color = mW20Bands and w3Line ? w3UpC : color.new(w3UpC, 100), linewidth = w3W, style = shapeStep or w3Sty == "Stepline" ? plot.style_stepline : w3Sty == "Dotted" ? plot.style_circles : w3Sty == "Cross" ? plot.style_cross : plot.style_line)
pWL3 = plot(wAny and wHave and w3On ? wL3 : na, "20W lower ATR band 3", color = mW20Bands and w3Line ? w3LoC : color.new(w3LoC, 100), linewidth = w3W, style = shapeStep or w3Sty == "Stepline" ? plot.style_stepline : w3Sty == "Dotted" ? plot.style_circles : w3Sty == "Cross" ? plot.style_cross : plot.style_line)
fill(pE3, pWU1, color = mW20Fills and wfInOn ? wfInUpC : color(na), title = "20W fill · line to upper band 1")
fill(pE3, pWL1, color = mW20Fills and wfInOn ? wfInDnC : color(na), title = "20W fill · line to lower band 1")
fill(pWU1, pWU2, color = mW20Fills and wfMidOn ? wfMidUpC : color(na), title = "20W fill · upper band 1 to 2")
fill(pWL1, pWL2, color = mW20Fills and wfMidOn ? wfMidDnC : color(na), title = "20W fill · lower band 1 to 2")
fill(pWU2, pWU3, color = mW20Fills and wfOutOn ? wfOutUpC : color(na), title = "20W fill · upper band 2 to 3")
fill(pWL2, pWL3, color = mW20Fills and wfOutOn ? wfOutDnC : color(na), title = "20W fill · lower band 2 to 3")
plot(mCtx and ctxLine ? dVw + ctxSigma * dSd : na, "Edge of value upper", color = ctxLineC, linewidth = ctxLineW, style = plot.style_circles)
plot(mCtx and ctxLine ? dVw - ctxSigma * dSd : na, "Edge of value lower", color = ctxLineC, linewidth = ctxLineW, style = plot.style_circles)

// ═════════════════════════════════════════════════════════════════════════════
//  STRYK:M engines — delta, MDP, volume profile, Delta size HTF. Carried over
//  from STRYK: MOMENTUM without changes to the maths.
// ═════════════════════════════════════════════════════════════════════════════
// ── Resolution: delta TF, chart seconds, auto intrabar ladder ────────────────
int chartSec = timeframe.in_seconds(timeframe.period)
string dTf = autoRaiseTf and timeframe.in_seconds(htfTf) < chartSec ? timeframe.period : htfTf
if not autoRaiseTf and timeframe.in_seconds(htfTf) < chartSec
    runtime.error("Delta timeframe is below the chart timeframe. Raise the delta timeframe or enable auto-raise.")
tfStrOf(int sec) =>
    sec < 60 ? str.tostring(sec) + "S" : str.tostring(sec / 60)
int budgetBars = dataBudget == "200K (Ultimate)" ? 200000 : dataBudget == "125K (Expert)" ? 125000 : dataBudget == "50K (replay-safe)" ? 50000 : dataBudget == "25K (memory saver)" ? 25000 : 100000
int needSec = math.max(int(lenN * timeframe.in_seconds(dTf) * histMult), 172800)
var int[] ladder = array.from(1, 5, 10, 15, 30, 60, 300, 900)
int autoSec = 0
for c in ladder
    if autoSec == 0 and budgetBars * c >= needSec and c < chartSec
        autoSec := c
// memory saver: requesting the CHART timeframe from security_lower_tf returns a
// one-element array per bar — no intrabar data is fetched or held at all.
string ltf = memSaver ? timeframe.period : (useAutoLtf ? (autoSec > 0 ? tfStrOf(autoSec) : "1") : manualLtf)
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
float barDelta = barBuy - barSell

// ── MDP engine — candle override, rides on whichever paint mode is active ────
bool mdpPaintOn = mMdp

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
bool mdBetter = mdMode == "Every qualifying bar" or na(mdIncumbent) or mdCandScore >= mdIncumbent
bool mdAccept = mdQualified and mdBetter and (mdConfirm ? barstate.isconfirmed : true)
if mdAccept
    if mdIsAbs
        mdScoreAbs := mdCandScore
    else
        mdScoreAgg := mdCandScore

// level ladder on the current print — cleared and rebuilt when a print lands
var array<line> mdLnArr = array.new_line(0)
var array<label> mdLnLbls = array.new_label(0)
var float mdHi = na
var float mdLo = na
if mdAccept
    mdHi := high
    mdLo := low
    while array.size(mdLnArr) > 0
        line.delete(array.shift(mdLnArr))
    while array.size(mdLnLbls) > 0
        label.delete(array.shift(mdLnLbls))
    if mMdpLines and mdpPaintOn
        float rng = mdHi - mdLo
        if rng > 0
            array<string> parts = str.split(mdLevels, ",")
            int np = array.size(parts)
            if np > 0
                for i = 0 to np - 1
                    float r = str.tonumber(str.trim(array.get(parts, i)))
                    if not na(r)
                        float px = mdLo + rng * r
                        color lc = r > 1.0 ? mdLnAbove : r < 0.0 ? mdLnBelow : mdLnInside
                        array.push(mdLnArr, line.new(bar_index, px, bar_index + 1, px, color = lc, width = mdLnW, extend = extend.right))
                        if mdLnLbl
                            array.push(mdLnLbls, label.new(bar_index + 1, px, str.tostring(r), style = label.style_none,
                                 textcolor = lc, size = size.tiny))
// lines carry extend.right, so they reach the newest bar without being rewritten
// every bar; only the ratio labels need repositioning, and only on the last bar
if barstate.islast and array.size(mdLnLbls) > 0
    for i = 0 to array.size(mdLnLbls) - 1
        label.set_x(array.get(mdLnLbls, i), bar_index + 1)

// signals under the qualifying candle — colour follows the print's own type
var array<label> mdSigs = array.new_label(0)
if mdAccept and mdSigOn and mdSigKeep > 0
    // the arrow is the DELTA side, not the candle direction. On an absorption bar
    // delta is small by definition, so it reads as a lean rather than conviction.
    string mdSide = barDelta > 0 ? " Δ▲" : barDelta < 0 ? " Δ▼" : " Δ="
    string mdTxt = mdSigStyle == "Marker only" ? "" :
         (mdIsAbs ? (mdSigStyle == "Short" ? "ABS" : "ABSORPTION") :
         (mdSigStyle == "Short" ? "AGG" : "AGGRESSION")) + mdSide
    array.push(mdSigs, label.new(bar_index, low, mdTxt, xloc = xloc.bar_index, yloc = yloc.belowbar,
         style = mdSigStyle == "Marker only" ? label.style_triangleup : label.style_label_up,
         color = mdIsAbs ? mdColAbs : mdColAgg, textcolor = color.white,
         size = mdSigSize == "Tiny" ? size.tiny : mdSigSize == "Small" ? size.small : mdSigSize == "Normal" ? size.normal : size.large))
// the print that just fell out of the text window keeps its marker, loses its text
if mdAccept and array.size(mdSigs) > mdSigText
    label old = array.get(mdSigs, array.size(mdSigs) - 1 - mdSigText)
    label.set_text(old, "")
    label.set_style(old, label.style_triangleup)
while array.size(mdSigs) > mdSigKeep
    label.delete(array.shift(mdSigs))


// ── Absorption debug — why a candidate failed ────────────────────────────────
// A candidate is any bar with the volume to be absorption. If it did not print,
// the three readings say which gate blocked it, so tuning is reading rather than
// guessing from an empty chart.
var array<label> mdDbg = array.new_label(0)
if mdAbsDebug and mdpPaintOn and barstate.isconfirmed and not mdAbsPass and mdRelVol >= mdMinRelVol and not na(mdEffortRatio)
    bool okE = mdAbsMode == "Body" ? nz(mdEffortBRatio) >= mdMinEffort : nz(mdEffortRatio) >= mdMinEffort
    bool okR = mdAbsMode == "Body" ? nz(mdBodyRatio, 99) <= mdMaxRange : nz(mdRangeRatio, 99) <= mdMaxRange
    string dTxt = "ER " + str.tostring(mdAbsMode == "Body" ? nz(mdEffortBRatio) : nz(mdEffortRatio), "#.##") + (okE ? " ✓" : " ✗") +
         "\n" + (mdAbsMode == "Body" ? "BR " : "RR ") + str.tostring(mdAbsMode == "Body" ? nz(mdBodyRatio) : nz(mdRangeRatio), "#.##") + (okR ? " ✓" : " ✗") +
         "\nRV " + str.tostring(nz(mdRelVol), "#.##") + " ✓"
    array.push(mdDbg, label.new(bar_index, low, dTxt, xloc = xloc.bar_index, yloc = yloc.belowbar,
         style = label.style_label_up, color = color.new(color.gray, 55), textcolor = color.new(color.white, 20), size = size.tiny))
while array.size(mdDbg) > (mdAbsDebug ? mdAbsDebugN : 0)
    label.delete(array.shift(mdDbg))


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
            // TradingView rule: a row that would push the total past the target is not added
            if vaStrict and acc + math.max(vUp, vDn) > target
                break
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
if nPocIB > 0
    for i = 0 to nPocIB - 1
        float pc3 = array.get(pocIvC, i)
        float vv3 = nz(array.get(pocIvV, i))
        if not na(pc3)
            addBin(htfProf, math.round(pc3 / pocBinSize), vv3)
else if not memSaver
    addBin(htfProf, math.round(close / pocBinSize), nz(volume))


// Delta size HTF reference: one profile over the last N candles of the DELTA
// timeframe — the same 1H × N the VWAP window and the paint scale already use,
// so changing either in the Delta Engine moves this band with it.
[hwPoc, hwVah, hwVal, hwBack, hwPrev] = request.security(syminfo.tickerid, memSaver ? timeframe.period : dTf, f_windowProfile(memSaver ? 0 : lenN, htfMigK, false), lookahead = barmerge.lookahead_off)

float avgAbsD = 0.0
if array.size(deltaHist) > 0
    for d in deltaHist
        avgAbsD += math.abs(nz(d))
    avgAbsD /= array.size(deltaHist)
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

// ═════════════════════════════════════════════════════════════════════════════
//  MDP × VWAP context and setups. READ-ONLY on the MDP engine: nothing below
//  feeds back into which bar qualifies, how it is ranked or how it is painted.
// ═════════════════════════════════════════════════════════════════════════════
float cxAtr   = ta.atr(14)
float cxU     = vw + ctxSigma * sd
float cxL     = vw - ctxSigma * sd
// the side that aggressed on this bar
int   cxDelta = barDelta > 0 ? 1 : barDelta < 0 ? -1 : 0
// where the bar closed inside its own range: 0 = on the low, 1 = on the high
float cxRng   = high - low
float cxPos   = cxRng > 0 ? (close - low) / cxRng : 0.5
// which edge of value the bar reached; a bar spanning both edges reads as neither
bool  cxHiTag = has and high >= cxU
bool  cxLoTag = has and low <= cxL
int   cxEdge  = cxHiTag and not cxLoTag ? 1 : cxLoTag and not cxHiTag ? -1 : 0

// CONTINUATION — aggression only: price side, VWAP slope, strong close
bool cxSide   = has and (cxDelta == 1 ? close > vw : cxDelta == -1 ? close < vw : false)
bool cxSlope  = cxDelta == 1 ? rising : cxDelta == -1 ? falling : false
bool cxStrong = cxDelta == 1 ? cxPos >= ctxClose : cxDelta == -1 ? cxPos <= 1.0 - ctxClose : false
int  cxContScore = (cxSide ? 1 : 0) + (cxSlope ? 1 : 0) + (cxStrong ? 1 : 0)

// REVERSAL — a print at the edge of value with the flow failing there.
// Absorption: the aggressor pushed INTO the edge and was filled (sellers at the
// lower band, buyers at the upper). Aggression: the aggressor hit back TOWARD value.
int  cxRevDir = -cxEdge
bool cxFlow   = cxEdge != 0 and cxDelta != 0 and (mdIsAbs ? cxDelta == cxEdge : cxDelta == cxRevDir)
bool cxReject = cxRevDir == 1 ? cxPos >= ctxClose : cxRevDir == -1 ? cxPos <= 1.0 - ctxClose : false
int  cxRevScore = cxEdge != 0 ? 1 + (cxFlow ? 1 : 0) + (cxReject ? 1 : 0) : 0

// type: 2 = reversal, 1 = continuation, 0 = raw
bool cxPrint = mdAccept and has
int  cxType  = not cxPrint ? 0 : cxFlow ? 2 : not mdIsAbs and cxSide ? 1 : 0
int  cxScore = cxType == 2 ? cxRevScore : cxType == 1 ? cxContScore : 0
int  cxDir   = cxType == 2 ? cxRevDir : cxType == 1 ? cxDelta : 0

var int  cxLastType  = 0
var int  cxLastDir   = 0
var int  cxLastScore = 0
var int  cxLastBar   = na
var bool cxLastAbs   = false
if cxPrint and barstate.isconfirmed
    cxLastType  := cxType
    cxLastDir   := cxDir
    cxLastScore := cxScore
    cxLastBar   := bar_index
    cxLastAbs   := mdIsAbs

// context tag above the print (the AGG / ABS signal keeps the space below it)
var array<label> cxLbls = array.new_label(0)
bool cxShow = cxType != 0 ? cxScore >= ctxMin : ctxShowRaw
if cxPrint and barstate.isconfirmed and mCtx and mCtxLbl and ctxKeep > 0 and cxShow
    string cxArrow = cxDir == 1 ? " ▲" : cxDir == -1 ? " ▼" : ""
    string cxName  = cxType == 2 ? (ctxTxt == "Short" ? "REV" : "REVERSAL") : cxType == 1 ? (ctxTxt == "Short" ? "CONT" : "CONTINUATION") : "RAW"
    string cxTxt   = cxType == 0 ? cxName : cxName + cxArrow + "  " + str.tostring(cxScore) + "/3"
    color  cxCol   = cxType == 2 ? ctxRevC : cxType == 1 ? ctxContC : ctxRawC
    array.push(cxLbls, label.new(bar_index, high, cxTxt, xloc = xloc.bar_index, yloc = yloc.abovebar, style = label.style_label_down, color = cxCol, textcolor = ctxTextC, size = f_size(ctxLblSize)))
while array.size(cxLbls) > ctxKeep
    label.delete(array.shift(cxLbls))

// ── Setups — closed bars only ────────────────────────────────────────────────
float cxSlopeChg = slope - slope[slopeLen]
bool  cxTurnUp   = rising or (not na(cxSlopeChg) and cxSlopeChg > 0)
bool  cxTurnDn   = falling or (not na(cxSlopeChg) and cxSlopeChg < 0)

var int   rvDir  = 0
var int   rvBar  = na
var float rvInv  = na
var line  rvLine = na
var int   trDir  = 0
var int   trHeld = 0
int   evRev = 0
int   evTr  = 0
float evInv = na
if barstate.isconfirmed and mSetups
    // REVERSAL: a reversal print at the edge of value, then a close back inside the band
    if suRevOn and cxPrint and cxType == 2 and cxScore >= suMinScore and (suRevSrc == "Any reversal print" or mdIsAbs)
        if rvDir != 0 and not na(rvLine)
            line.delete(rvLine)
        rvDir  := cxDir
        rvBar  := bar_index
        rvInv  := cxDir == 1 ? low : high
        rvLine := suInvLine ? line.new(bar_index, rvInv, bar_index + 1, rvInv, color = suInvC, width = suInvW, style = line.style_dotted) : na
    if rvDir != 0
        bool rvExpired = bar_index - rvBar > suWindow
        bool rvBroke   = rvDir == 1 ? close < rvInv : close > rvInv
        bool rvReclaim = rvDir == 1 ? close > cxL : close < cxU
        bool rvSlopeOk = suSlope == "Off" ? true : suSlope == "Aligned" ? (rvDir == 1 ? rising : falling) : (rvDir == 1 ? cxTurnUp : cxTurnDn)
        if not na(rvLine)
            line.set_x2(rvLine, bar_index)
        if rvBroke or rvExpired
            if not na(rvLine)
                line.delete(rvLine)
            rvLine := na
            rvDir  := 0
        else if rvReclaim and rvSlopeOk and f_biasOk(rvDir)
            evRev  := rvDir
            evInv  := rvInv
            rvLine := na
            rvDir  := 0
    // TREND: a continuation print with the VWAP sloping its way, then price holds the VWAP
    bool trArm = suTrendOn and cxPrint and cxType == 1 and cxScore >= suMinScore and (cxDir == 1 ? rising : falling) and f_biasOk(cxDir)
    if trArm
        trDir  := cxDir
        trHeld := 0
        if suHold == 0
            evTr  := trDir
            evInv := vw
            trDir := 0
    else if trDir != 0
        bool trHolds = trDir == 1 ? close > vw and not falling : close < vw and not rising
        if not trHolds
            trDir := 0
        else
            trHeld += 1
            if trHeld >= suHold
                evTr  := trDir
                evInv := vw
                trDir := 0

var array<label> suLbls = array.new_label(0)
f_setupLabel(int d, string txt, float inv) =>
    float  y   = d == 1 ? low - suOff * nz(cxAtr) : high + suOff * nz(cxAtr)
    string sty = suStyle == "Triangle" ? (d == 1 ? label.style_triangleup : label.style_triangledown) : suStyle == "Arrow" ? (d == 1 ? label.style_arrowup : label.style_arrowdown) : (d == 1 ? label.style_label_up : label.style_label_down)
    string tip = txt + "\nInvalid on a close " + (d == 1 ? "below " : "above ") + str.tostring(inv, format.mintick)
    suLbls.push(label.new(bar_index, y, suStyle == "Label" ? txt : "", xloc = xloc.bar_index, yloc = yloc.price, style = sty, color = d == 1 ? suLongC : suShortC, textcolor = suTextC, size = f_size(suSize), tooltip = tip))
if evRev != 0 and suKeep > 0
    f_setupLabel(evRev, evRev == 1 ? suTxtLong : suTxtShort, evInv)
if evTr != 0 and suKeep > 0
    f_setupLabel(evTr, evTr == 1 ? suTxtTL : suTxtTS, evInv)
while array.size(suLbls) > suKeep
    label.delete(array.shift(suLbls))

// ═════════════════════════════════════════════════════════════════════════════
//  Context research — PRIVATE measurement. It follows events forward and never
//  feeds back into prints, context or setups. Kinds: 0 control, 1 reversal
//  print, 2 continuation print, 3 raw print, 4 reversal setup, 5 trend setup.
// ═════════════════════════════════════════════════════════════════════════════
var array<int>   cxEBar  = array.new_int()
var array<float> cxEOrig = array.new_float()
var array<float> cxEUnit = array.new_float()
var array<int>   cxEDir  = array.new_int()
var array<int>   cxEKind = array.new_int()
var array<float> cxEMfe  = array.new_float()
var array<float> cxEMae  = array.new_float()
var array<int>   cxEAge  = array.new_int()
var array<int>   cxRN    = array.new_int(6, 0)
var array<float> cxRMfe  = array.new_float(6, 0.0)
var array<float> cxRMae  = array.new_float(6, 0.0)
var array<float> cxRFin  = array.new_float(6, 0.0)
var array<float> cxRFin2 = array.new_float(6, 0.0)
var array<int>   cxRWin  = array.new_int(6, 0)
f_cxPush(int kind, int dir) =>
    array.push(cxEBar, bar_index)
    array.push(cxEOrig, close)
    array.push(cxEUnit, math.max(syminfo.mintick, nz(cxAtr, high - low)))
    array.push(cxEDir, dir)
    array.push(cxEKind, kind)
    array.push(cxEMfe, 0.0)
    array.push(cxEMae, 0.0)
    array.push(cxEAge, 0)
if mCtxResearch and not memSaver and barstate.isconfirmed
    // age the open events first, so no event ever measures its own bar
    int cxJ = array.size(cxEBar) - 1
    while cxJ >= 0
        int   cxAge  = array.get(cxEAge, cxJ) + 1
        float cxOrig = array.get(cxEOrig, cxJ)
        float cxUnit = array.get(cxEUnit, cxJ)
        int   cxD    = array.get(cxEDir, cxJ)
        float cxFav  = cxD > 0 ? (high - cxOrig) / cxUnit : (cxOrig - low) / cxUnit
        float cxAdv  = cxD > 0 ? (cxOrig - low) / cxUnit : (high - cxOrig) / cxUnit
        array.set(cxEAge, cxJ, cxAge)
        array.set(cxEMfe, cxJ, math.max(array.get(cxEMfe, cxJ), cxFav))
        array.set(cxEMae, cxJ, math.max(array.get(cxEMae, cxJ), cxAdv))
        if cxAge >= cxRFwdBars
            int   cxK   = array.get(cxEKind, cxJ)
            float cxFin = cxD * (close - cxOrig) / cxUnit
            array.set(cxRN, cxK, array.get(cxRN, cxK) + 1)
            array.set(cxRMfe, cxK, array.get(cxRMfe, cxK) + array.get(cxEMfe, cxJ))
            array.set(cxRMae, cxK, array.get(cxRMae, cxK) + array.get(cxEMae, cxJ))
            array.set(cxRFin, cxK, array.get(cxRFin, cxK) + cxFin)
            array.set(cxRFin2, cxK, array.get(cxRFin2, cxK) + cxFin * cxFin)
            if cxFin > 0
                array.set(cxRWin, cxK, array.get(cxRWin, cxK) + 1)
            array.remove(cxEBar, cxJ)
            array.remove(cxEOrig, cxJ)
            array.remove(cxEUnit, cxJ)
            array.remove(cxEDir, cxJ)
            array.remove(cxEKind, cxJ)
            array.remove(cxEMfe, cxJ)
            array.remove(cxEMae, cxJ)
            array.remove(cxEAge, cxJ)
        cxJ -= 1
    // new events on this bar
    if cxPrint
        int cxRawDir = mdIsAbs ? -cxDelta : cxDelta
        int cxNewDir = cxType == 0 ? cxRawDir : cxDir
        if cxNewDir != 0
            f_cxPush(cxType == 2 ? 1 : cxType == 1 ? 2 : 3, cxNewDir)
    if evRev != 0
        f_cxPush(4, evRev)
    if evTr != 0
        f_cxPush(5, evTr)
    if cxRCtrlN > 0 and not cxPrint and cxDelta != 0 and bar_index % cxRCtrlN == 0
        f_cxPush(0, cxDelta)
    while array.size(cxEBar) > cxRMaxOpen
        array.shift(cxEBar)
        array.shift(cxEOrig)
        array.shift(cxEUnit)
        array.shift(cxEDir)
        array.shift(cxEKind)
        array.shift(cxEMfe)
        array.shift(cxEMae)
        array.shift(cxEAge)

var table cxRT = na
if mCtxResearch and not memSaver and barstate.islast
    if na(cxRT)
        cxRT := table.new(f_pos(cxRPos), 7, 7, bgcolor = boxBgC, frame_color = boxFrC, frame_width = 1, border_color = boxFrC, border_width = 1)
    string cxRs = f_size(cxRSize)
    table.cell(cxRT, 0, 0, "CONTEXT RESEARCH · " + str.tostring(cxRFwdBars) + " bars · ATR", text_color = color.white, text_size = cxRs, text_halign = text.align_left)
    table.cell(cxRT, 1, 0, "REV", text_color = ctxRevC, text_size = cxRs)
    table.cell(cxRT, 2, 0, "CONT", text_color = ctxContC, text_size = cxRs)
    table.cell(cxRT, 3, 0, "RAW", text_color = boxTxtC, text_size = cxRs)
    table.cell(cxRT, 4, 0, "REV setup", text_color = boxTxtC, text_size = cxRs)
    table.cell(cxRT, 5, 0, "TREND setup", text_color = boxTxtC, text_size = cxRs)
    table.cell(cxRT, 6, 0, "control", text_color = boxLblC, text_size = cxRs)
    table.cell(cxRT, 0, 1, "Completed", text_color = boxLblC, text_size = cxRs, text_halign = text.align_left)
    table.cell(cxRT, 0, 2, "Avg best move", text_color = boxLblC, text_size = cxRs, text_halign = text.align_left)
    table.cell(cxRT, 0, 3, "Avg worst move", text_color = boxLblC, text_size = cxRs, text_halign = text.align_left)
    table.cell(cxRT, 0, 4, "Avg final", text_color = boxLblC, text_size = cxRs, text_halign = text.align_left)
    table.cell(cxRT, 0, 5, "± error", text_color = boxLblC, text_size = cxRs, text_halign = text.align_left)
    table.cell(cxRT, 0, 6, "Final > 0", text_color = boxLblC, text_size = cxRs, text_halign = text.align_left)
    for cxKd = 0 to 5
        int   cxCol = cxKd == 0 ? 6 : cxKd
        int   cxCnt = array.get(cxRN, cxKd)
        float cxAvF = cxCnt > 0 ? array.get(cxRFin, cxKd) / cxCnt : na
        float cxSe  = cxCnt > 1 ? math.sqrt(math.max(0.0, array.get(cxRFin2, cxKd) / cxCnt - cxAvF * cxAvF) / cxCnt) : na
        color cxFc  = na(cxAvF) ? boxTxtC : cxAvF > 0 ? suLongC : cxAvF < 0 ? suShortC : boxTxtC
        table.cell(cxRT, cxCol, 1, str.tostring(cxCnt), text_color = boxTxtC, text_size = cxRs)
        table.cell(cxRT, cxCol, 2, cxCnt > 0 ? str.tostring(array.get(cxRMfe, cxKd) / cxCnt, "#.##") : "—", text_color = boxTxtC, text_size = cxRs)
        table.cell(cxRT, cxCol, 3, cxCnt > 0 ? str.tostring(array.get(cxRMae, cxKd) / cxCnt, "#.##") : "—", text_color = boxTxtC, text_size = cxRs)
        table.cell(cxRT, cxCol, 4, na(cxAvF) ? "—" : str.tostring(cxAvF, "#.##"), text_color = cxFc, text_size = cxRs)
        table.cell(cxRT, cxCol, 5, na(cxSe) ? "—" : str.tostring(cxSe, "#.##"), text_color = boxTxtC, text_size = cxRs)
        table.cell(cxRT, cxCol, 6, cxCnt > 0 ? str.tostring(array.get(cxRWin, cxKd) * 100.0 / cxCnt, "#.0") + "%" : "—", text_color = boxTxtC, text_size = cxRs)


// ── Candle paint — one base mode, MDP print overrides it ─────────────────────
// Delta size HTF needs the profiles Replay mode switches off, so it falls back
string cModeEff = cMode == "Delta size HTF" and memSaver ? "Sigma gradient" : cMode
float ramp   = math.min(1.0, math.abs(nz(z)) / zFull)
float cRefUp = cBand == 1 ? u1 : cBand == 2 ? u2 : u3
float cRefLo = cBand == 1 ? l1 : cBand == 2 ? l2 : l3
color rvCol = na
if has
    if cModeEff == "Price vs VWAP"
        rvCol := close > vw ? cUpC : close < vw ? cDnC : cNeuC
    else if cModeEff == "Sigma gradient"
        rvCol := nz(z) >= 0 ? color.from_gradient(ramp, 0, 1, cUpC, cUpHotC) : color.from_gradient(ramp, 0, 1, cDnC, cDnHotC)
    else if cModeEff == "Outside band only"
        rvCol := close > cRefUp ? cUpHotC : close < cRefLo ? cDnHotC : na
    else if cModeEff == "VWAP slope"
        rvCol := rising ? cUpC : falling ? cDnC : cNeuC
color baseCol = cModeEff == "Delta size HTF" ? deltaSizeHtfCol : rvCol
bool  paintOn = mPaint and not na(baseCol)
// the bar that claimed the print is painted in its own color and keeps it: the
// paint is decided on the bar that qualified, so it never changes afterwards
bool  mdpHit   = mdpPaintOn and mdAccept
color outCol   = mdpHit ? (mdIsAbs ? mdColAbs : mdColAgg) : baseCol
bool  paintAny = paintOn or mdpHit
barcolor(paintAny ? outCol : na, title = "Candle paint")
plotcandle(open, high, low, close, "Painted candles", color = paintAny ? outCol : na, wickcolor = paintAny and cWicks ? outCol : na, bordercolor = paintAny and cWicks ? outCol : na)

// ── Background ───────────────────────────────────────────────────────────────
float bgRefUp = bgBand == 1 ? u1 : bgBand == 2 ? u2 : u3
float bgRefLo = bgBand == 1 ? l1 : bgBand == 2 ? l2 : l3
color bgCol = na
if mBg and bgMode == "Bias stack"
    bgCol := biasMaj == 1 ? bgUpC : biasMaj == -1 ? bgDnC : bgNeuC
else if mBg and has
    if bgMode == "Price vs VWAP"
        bgCol := close > vw ? bgUpC : close < vw ? bgDnC : bgNeuC
    else if bgMode == "Outside band only"
        bgCol := close > bgRefUp ? bgUpC : close < bgRefLo ? bgDnC : na
    else
        bgCol := rising ? bgUpC : falling ? bgDnC : bgNeuC
bgcolor(bgCol, title = "RVWAP background")

// ── Session shading ──────────────────────────────────────────────────────────
// one bgcolor for all four windows: every bgcolor() call counts toward the
// 64-plot limit. Where windows overlap the order is Custom, RTH, London, Asia.
color sessCol = not mSessBg ? na : shCus and inCus ? shCusC : shRth and inRth ? shRthC : shLon and inLon ? shLonC : shAsia and inAsia ? shAsiaC : na
bgcolor(sessCol, title = "Session shading")

// ── Price labels at the right edge ───────────────────────────────────────────
var array<label> endLbls = array.new<label>()
f_endLabel(float y, string name, color col) =>
    if not na(y)
        string txt = lblPrice ? name + "  " + str.tostring(y, format.mintick) : name
        endLbls.push(label.new(bar_index + lblOff, y, txt, style = label.style_label_left, color = color(na), textcolor = col, size = f_size(lblSize)))

if barstate.islast
    for lb in endLbls
        label.delete(lb)
    endLbls.clear()
    if mLabels
        if eLabels and mEma1
            f_endLabel(e1Plot, e1Type + " " + str.tostring(e1Len), e1ColNow)
        if eLabels and mEma2
            f_endLabel(e2Plot, str.tostring(e2Len) + "D " + e2Type, e2ColNow)
        if eLabels and mEma3
            f_endLabel(e3Plot, str.tostring(e3Len) + "W " + e3Type, e3ColNow)
        if wLabels and mW20Bands and wHave
            if w1On and w1Line
                f_endLabel(wU1, "20W +" + str.tostring(w1Mult) + " " + wUnit, w1UpC)
                f_endLabel(wL1, "20W −" + str.tostring(w1Mult) + " " + wUnit, w1LoC)
            if w2On and w2Line
                f_endLabel(wU2, "20W +" + str.tostring(w2Mult) + " " + wUnit, w2UpC)
                f_endLabel(wL2, "20W −" + str.tostring(w2Mult) + " " + wUnit, w2LoC)
            if w3On and w3Line
                f_endLabel(wU3, "20W +" + str.tostring(w3Mult) + " " + wUnit, w3UpC)
                f_endLabel(wL3, "20W −" + str.tostring(w3Mult) + " " + wUnit, w3LoC)
        if mVwap
            f_endLabel(dVw, "VWAP", vwColor)
        if lblBands and mBands
            if b1On and b1Line
                f_endLabel(dU1, "+" + str.tostring(b1Mult) + "σ", b1UpC)
                f_endLabel(dL1, "−" + str.tostring(b1Mult) + "σ", b1LoC)
            if b2On and b2Line
                f_endLabel(dU2, "+" + str.tostring(b2Mult) + "σ", b2UpC)
                f_endLabel(dL2, "−" + str.tostring(b2Mult) + "σ", b2LoC)
            if b3On and b3Line
                f_endLabel(dU3, "+" + str.tostring(b3Mult) + "σ", b3UpC)
                f_endLabel(dL3, "−" + str.tostring(b3Mult) + "σ", b3LoC)

// ── Info box ─────────────────────────────────────────────────────────────────
string lbTxt = lbMode == "ETH sessions" ? str.tostring(sessN, "#.##") + " × " + str.tostring(winHours, "#.##") + "h session" : lbMode == "Fixed bars" ? str.tostring(fixBars) + " bars" : lbMode == "Clock time" ? "Clock " + f_spanText(winMs) : lbMode == "Auto (TradingView)" ? "Auto " + f_spanText(winMs) : "Anchored · " + ancType
float az = math.abs(nz(z))
string zoneTxt = not has ? "—" : az <= b1Mult ? "IN VALUE" : az <= b2Mult ? (z > 0 ? "EXTENDED ▲" : "EXTENDED ▼") : az <= b3Mult ? (z > 0 ? "STRETCHED ▲" : "STRETCHED ▼") : (z > 0 ? "EXTREME ▲" : "EXTREME ▼")
color  zoneCol = not has ? boxTxtC : az <= b1Mult ? cNeuC : z > 0 ? (az <= b2Mult ? cUpC : cUpHotC) : (az <= b2Mult ? cDnC : cDnHotC)
var table box = na
if mBox and barstate.islast
    if na(box)
        box := table.new(f_pos(boxPos), 2, 14, bgcolor = boxBgC, frame_color = boxFrC, frame_width = 1, border_color = boxFrC, border_width = 1)
    string sz = f_size(boxSize)
    table.cell(box, 0, 0, "STRYK:DRE", text_color = color.white, text_size = sz, text_halign = text.align_left)
    table.cell(box, 1, 0, lbTxt, text_color = color.white, text_size = sz, text_halign = text.align_right)
    table.cell(box, 0, 1, "Window", text_color = boxLblC, text_size = sz, text_halign = text.align_left)
    table.cell(box, 1, 1, winEff + " · " + str.tostring(nWin) + " bars", text_color = boxTxtC, text_size = sz, text_halign = text.align_right)
    table.cell(box, 0, 2, "VWAP", text_color = boxLblC, text_size = sz, text_halign = text.align_left)
    table.cell(box, 1, 2, has ? str.tostring(vw, format.mintick) : "—", text_color = vwColor, text_size = sz, text_halign = text.align_right)
    table.cell(box, 0, 3, "Distance", text_color = boxLblC, text_size = sz, text_halign = text.align_left)
    table.cell(box, 1, 3, na(z) ? "—" : (z > 0 ? "+" : "") + str.tostring(z, "#.##") + "σ   " + str.tostring(close - vw, format.mintick), text_color = zoneCol, text_size = sz, text_halign = text.align_right)
    table.cell(box, 0, 4, "Zone", text_color = boxLblC, text_size = sz, text_halign = text.align_left)
    table.cell(box, 1, 4, zoneTxt, text_color = zoneCol, text_size = sz, text_halign = text.align_right)
    table.cell(box, 0, 5, "Slope", text_color = boxLblC, text_size = sz, text_halign = text.align_left)
    table.cell(box, 1, 5, not has ? "—" : rising ? "RISING ▲" : falling ? "FALLING ▼" : "FLAT ▶", text_color = rising ? vwUpCol : falling ? vwDnCol : boxTxtC, text_size = sz, text_halign = text.align_right)
    table.cell(box, 0, 6, "Δ " + dTf, text_color = boxLblC, text_size = sz, text_halign = text.align_left)
    table.cell(box, 1, 6, str.tostring(liveDelta, "#") + (fpOk ? "  footprint" : "  estimate"), text_color = liveDelta > 0 ? colBull : liveDelta < 0 ? colBear : boxTxtC, text_size = sz, text_halign = text.align_right)
    string bxPrint = na(cxLastBar) ? "—" : (cxLastAbs ? "ABS" : "AGG") + " · " + (cxLastType == 2 ? "REV" : cxLastType == 1 ? "CONT" : "RAW") + (cxLastDir == 1 ? " ▲" : cxLastDir == -1 ? " ▼" : "") + (cxLastType != 0 ? " " + str.tostring(cxLastScore) + "/3" : "") + " · " + str.tostring(bar_index - cxLastBar) + " bars"
    color  bxPrintC = na(cxLastBar) ? boxTxtC : cxLastType == 2 ? ctxRevC : cxLastType == 1 ? ctxContC : boxTxtC
    string bxSetup = not mSetups ? "OFF" : rvDir != 0 ? "REV " + (rvDir == 1 ? "LONG" : "SHORT") + " armed · close " + (rvDir == 1 ? "> " + str.tostring(cxL, format.mintick) : "< " + str.tostring(cxU, format.mintick)) : trDir != 0 ? "TREND " + (trDir == 1 ? "LONG" : "SHORT") + " hold " + str.tostring(trHeld) + "/" + str.tostring(suHold) : "—"
    color  bxSetupC = rvDir == 1 or trDir == 1 ? suLongC : rvDir == -1 or trDir == -1 ? suShortC : boxTxtC
    table.cell(box, 0, 7, "Last print", text_color = boxLblC, text_size = sz, text_halign = text.align_left)
    table.cell(box, 1, 7, mCtx ? bxPrint : "OFF", text_color = mCtx ? bxPrintC : boxTxtC, text_size = sz, text_halign = text.align_right)
    table.cell(box, 0, 8, "Setup", text_color = boxLblC, text_size = sz, text_halign = text.align_left)
    table.cell(box, 1, 8, bxSetup, text_color = bxSetupC, text_size = sz, text_halign = text.align_right)
    table.cell(box, 0, 9, e1Type + " " + str.tostring(e1Len), text_color = boxLblC, text_size = sz, text_halign = text.align_left)
    table.cell(box, 1, 9, not mEma1 ? "OFF" : na(e1Raw) ? "—" : (close > e1Raw ? "above" : "below") + (e1Slope > 0 ? " ▲  " : e1Slope < 0 ? " ▼  " : " ▶  ") + str.tostring(e1Raw, format.mintick), text_color = not mEma1 or na(e1Raw) ? boxTxtC : close > e1Raw ? e1UpC : e1DnC, text_size = sz, text_halign = text.align_right)
    table.cell(box, 0, 10, str.tostring(e2Len) + "D " + e2Type, text_color = boxLblC, text_size = sz, text_halign = text.align_left)
    table.cell(box, 1, 10, not mEma2 ? "OFF" : na(e2Raw) ? "—" : (close > e2Raw ? "above" : "below") + (e2Slope > 0 ? " ▲  " : e2Slope < 0 ? " ▼  " : " ▶  ") + str.tostring(e2Raw, format.mintick), text_color = not mEma2 or na(e2Raw) ? boxTxtC : close > e2Raw ? e2UpC : e2DnC, text_size = sz, text_halign = text.align_right)
    table.cell(box, 0, 11, str.tostring(e3Len) + "W " + e3Type, text_color = boxLblC, text_size = sz, text_halign = text.align_left)
    table.cell(box, 1, 11, not mEma3 ? "OFF" : na(e3Raw) ? "—" : (close > e3Raw ? "above" : "below") + (e3Slope > 0 ? " ▲  " : e3Slope < 0 ? " ▼  " : " ▶  ") + str.tostring(e3Raw, format.mintick), text_color = not mEma3 or na(e3Raw) ? boxTxtC : close > e3Raw ? e3UpC : e3DnC, text_size = sz, text_halign = text.align_right)
    table.cell(box, 0, 12, "Bias stack", text_color = boxLblC, text_size = sz, text_halign = text.align_left)
    table.cell(box, 1, 12, (biasCnt == 0 ? "OFF" : biasMaj == 1 ? "UP " + str.tostring(biasUp) + "/" + str.tostring(biasCnt) : biasMaj == -1 ? "DOWN " + str.tostring(biasDn) + "/" + str.tostring(biasCnt) : "MIXED " + str.tostring(biasUp) + "▲ " + str.tostring(biasDn) + "▼") + (biasConfirmed and biasCnt > 0 ? "  conf" : ""), text_color = biasMaj == 1 ? e1UpC : biasMaj == -1 ? e1DnC : boxTxtC, text_size = sz, text_halign = text.align_right)
    table.cell(box, 0, 13, str.tostring(e3Len) + "W stretch", text_color = boxLblC, text_size = sz, text_halign = text.align_left)
    table.cell(box, 1, 13, na(wStretch) ? "—" : (wStretch > 0 ? "+" : "") + str.tostring(wStretch, "#.##") + " " + wUnit + "   width " + str.tostring(wAtrRaw, format.mintick), text_color = na(wStretch) ? boxTxtC : wStretch > 0 ? e3UpC : e3DnC, text_size = sz, text_halign = text.align_right)

// ── Alerts — closed bars, on the change ──────────────────────────────────────
// ta.* crossovers always run; the result is gated, never the call
float aRefUp = aBand == 1 ? u1 : aBand == 2 ? u2 : u3
float aRefLo = aBand == 1 ? l1 : aBand == 2 ? l2 : l3
bool xUp    = ta.crossover(close, nz(vw, close))
bool xDn    = ta.crossunder(close, nz(vw, close))
bool outUp  = has and close > aRefUp
bool outDn  = has and close < aRefLo
bool leftUp = outUp and not outUp[1]
bool leftDn = outDn and not outDn[1]
bool backUp = has and not outUp and outUp[1]
bool backDn = has and not outDn and outDn[1]
bool alertOk = mAlerts and barstate.isconfirmed and has
if alertOk
    if aCross and xUp
        alert("STRYK:DRE " + syminfo.ticker + " " + timeframe.period + " — price closed ABOVE the rolling VWAP at " + str.tostring(close, format.mintick) + ".", alert.freq_once_per_bar_close)
    if aCross and xDn
        alert("STRYK:DRE " + syminfo.ticker + " " + timeframe.period + " — price closed BELOW the rolling VWAP at " + str.tostring(close, format.mintick) + ".", alert.freq_once_per_bar_close)
    if aOut and leftUp
        alert("STRYK:DRE " + syminfo.ticker + " " + timeframe.period + " — closed above band " + str.tostring(aBand) + " (" + str.tostring(z, "#.##") + "σ).", alert.freq_once_per_bar_close)
    if aOut and leftDn
        alert("STRYK:DRE " + syminfo.ticker + " " + timeframe.period + " — closed below band " + str.tostring(aBand) + " (" + str.tostring(z, "#.##") + "σ).", alert.freq_once_per_bar_close)
    if aIn and backUp
        alert("STRYK:DRE " + syminfo.ticker + " " + timeframe.period + " — closed back inside from above band " + str.tostring(aBand) + ".", alert.freq_once_per_bar_close)
    if aIn and backDn
        alert("STRYK:DRE " + syminfo.ticker + " " + timeframe.period + " — closed back inside from below band " + str.tostring(aBand) + ".", alert.freq_once_per_bar_close)
if mAlerts and aMdp and mdAccept and barstate.isconfirmed
    alert("STRYK:DRE " + syminfo.ticker + " " + timeframe.period + " — MDP " + (mdIsAbs ? "ABSORPTION" : "AGGRESSION") + " print at " + str.tostring(close, format.mintick) + ", delta " + str.tostring(barDelta, "#") + ".", alert.freq_once_per_bar_close)
bool cxAlertHit = cxPrint and cxType != 0 and cxScore >= ctxMin and aCtx and mCtx and mAlerts
if cxAlertHit and barstate.isconfirmed
    alert("STRYK:DRE " + syminfo.ticker + " " + timeframe.period + " — " + (mdIsAbs ? "ABS" : "AGG") + " print, " + (cxType == 2 ? "REVERSAL" : "CONTINUATION") + (cxDir == 1 ? " up " : " down ") + str.tostring(cxScore) + "/3 at " + str.tostring(close, format.mintick) + ".", alert.freq_once_per_bar_close)
if mAlerts and aSetup and barstate.isconfirmed
    if evRev != 0
        alert("STRYK:DRE " + syminfo.ticker + " " + timeframe.period + " — " + (evRev == 1 ? suTxtLong : suTxtShort) + " at " + str.tostring(close, format.mintick) + ". Invalid on a close " + (evRev == 1 ? "below " : "above ") + str.tostring(evInv, format.mintick) + ".", alert.freq_once_per_bar_close)
    if evTr != 0
        alert("STRYK:DRE " + syminfo.ticker + " " + timeframe.period + " — " + (evTr == 1 ? suTxtTL : suTxtTS) + " at " + str.tostring(close, format.mintick) + ". Invalid on a close " + (evTr == 1 ? "below " : "above ") + "the VWAP, " + str.tostring(evInv, format.mintick) + ".", alert.freq_once_per_bar_close)
// Named alert entries are merged into three because every alertcondition() counts
// toward the 64-plot limit. "Any alert() function call" still sends each event
// separately, with its own message and live values.
alertcondition((((xUp or xDn) and aCross) or ((leftUp or leftDn) and aOut) or ((backUp or backDn) and aIn)) and mAlerts, "VWAP — line or band event", "STRYK:DRE {{ticker}} {{interval}} — price crossed the rolling VWAP or closed through the alert band at {{close}}.")
alertcondition((mdAccept and aMdp and mAlerts) or cxAlertHit, "MDP — print or context print", "STRYK:DRE {{ticker}} {{interval}} — new Max Delta Print at {{close}}.")
alertcondition((evRev != 0 or evTr != 0) and aSetup and mAlerts, "Setup — triggered", "STRYK:DRE {{ticker}} {{interval}} — setup triggered at {{close}}.")
````
