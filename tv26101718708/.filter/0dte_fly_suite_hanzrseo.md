# 0DTE Fly Suite

- url: https://www.tradingview.com/script/hANzrsEO-0DTE-Fly-Suite/
- type: indicator
- pine_id: PUB;be6c233820ca4cfd98bd03a0e1671c45
- version: 4.0

## Description

WHY THIS EXISTS
Multi-entry 0DTE iron butterfly strategies on SPX need three things on screen at once: what kind of day it is (pinning, drifting, trending or whipsawing), where the strategy is on its clock and whether something abrupt just happened, and how each open fly is doing against price. I used to run three separate indicators for that: "0DTE Fly Monitor", "0DTE Clock & Shocks" and "My Theta Fly's". This script merges all three into one overlay with one shared session, one set of daily resets and one input panel, and adds the pieces I kept wishing the separate scripts had. Every part has its own on/off switch under "Suite sections", so you can run only what you need.

WHAT IT SHOWS
Expected move. Taken from VIX1D shortly after the open (09:31 ET by default, with VIX as a fallback) and converted to a one-day point range: open × VIX1D/100 × √(1/252). Lines at the open, ±0.5 EM and ±1 EM. The value is latched so it does not move during the day.

Session VWAP with ±1 and ±2 standard-deviation bands. SPX has no volume, so SPY volume is used as the weighting (selectable), with an HLC3 fallback.

Opening range (09:30–10:30 ET by default) with a state of Inside, Broke Up or Broke Down. A break only counts when a bar closes a set distance outside the range.

Day type, in the table and as a faint background color:
PIN/RANGE (green): low directional efficiency and price within ±1 SD of VWAP.
DRIFT (orange): everything in between.
TREND (red): high efficiency and price held beyond ±1 SD on one side for 30 minutes.
WIDE CHOP (purple): low efficiency, but the session range has already reached 100% of the expected move.
WHIPSAW (fuchsia): any non-trend day whose range has passed 150% of the expected move. These are the days that look calm on a snapshot and cost flies the most.

Bot clock. Dashed vertical lines with labels for the phases of the day: Entry, Late, Tight, Late tight, Land, plus an optional entry-stop line (with light shading after it) and an optional close-all line. Choose "Custom" to set your own times, or pick a bot preset to load a fixed schedule. The presets match the automated fly bots I run (the Theta Fly Trap variants and Iron Squadron). The Iron Squadron times are not confirmed, so check them against your own bot before relying on them. An alert can fire at each clock time.

Shocks. A marker on the bar and a table update when:
Rapid move: SPX moves 25 points in 1 minute or 40 points in 2 minutes (measured on 1-minute data).
VIX warning: VIX up 2 points or 10% from the open (or the prior close).
VIX breaker: VIX up 15 points from the open, the level at which some fly bots close everything for the day.
A "VIX above 30" note also shows before 13:30 when a preset that delays entries on high VIX is selected.

Pre-market rows: gap versus the prior close as a share of EM, overnight range as a share of EM, where the open sits inside the overnight range, and VIX1D ÷ VIX at the open. The overnight rows need a symbol with overnight bars such as SPCFD; CBOE:SPX has none.

Event day. TradingView cannot read an economic calendar, so you set FOMC, CPI, NFP, OpEx or Other by hand and it shows in the table. Early-close days (prefilled with 2026-11-27 and 2026-12-24 at 13:00) end the session, the clock lines and the minutes-to-close count early.

MY FLIES
Up to 10 slots. For each fly enter the center strike, credit received, wing width and a label, and optionally the entry and exit time (New York, e.g. 10:35) and the P/L in dollars. While a fly is open, its center and breakeven lines are drawn. Once it has an exit time, it is drawn as a box from entry to exit, colored and tagged with the P/L. The table shows, per fly: distance from the center, room to the touch level, room to the nearer breakeven, the value per contract if SPX settled here, and the maximum risk per contract. Touch levels are drawn at a set percentage of the credit (95% by default). With a Theta Fly Trap preset, touch zones are hidden and the breakeven alert fires as soon as price crosses, because that bot exits intrabar.

OPTIONAL, OFF BY DEFAULT
Levels: prior-day high, low and close (the gap-fill level), plus overnight high and low.
Key strikes: paste your own levels, one per line or comma separated, e.g. "7800 call wall".
Bias block: smoothed NYSE TICK, ADD and VOLD, plus the VIX1D change since the open. Each scores +1, 0 or -1, and a total of ±2 or more reads Up or Down. Context only. If your account has no USI data these rows show n/a.

HOW TO READ THE TABLE
EM used %: distance from the open as a share of the expected move.
Range vs EM %: session high minus low as a share of the expected move. A low "EM used" with a high "Range vs EM" means price has travelled a long way and come back.
EM left (approx): VIX1D now, scaled by the square root of the minutes left, as a rough guide to how much movement is still priced in.
Price vs VWAP σ: distance from VWAP in standard deviations.
Session ER and Rolling ER: Kaufman efficiency ratio (net move ÷ total path) since the open and over the last 60 minutes. Near 0 is chop, near 1 is a straight line.
Swing from extreme: points from the current price back to the farther session extreme.

HOW I USE IT
I run it on SPX 1-minute with my bot's preset selected. Before a first entry and before any late-day stacking I check the day type and Range vs EM. The shock and breakeven alerts are the ones I keep armed. Alerts included: clock times, rapid move (up, down, either), VIX warning, VIX breaker, day type changing to TREND, WIDE CHOP or WHIPSAW, opening-range break, close outside ±2 SD, EM used crossing 100%, and fly touch and breakeven crosses. The clock and shock messages use "Any alert() function call"; the rest are listed individually under Add alert.

SETTINGS TO CHECK FIRST
Bot preset (top of the inputs). Keep the timezone on America/New_York even if your chart clock is set elsewhere. Re-enter your flies in the slots each day. With every section on, the context table gets long; each table's position and text size are under "Tables".

LIMITS
This is a context display with alerts. It is not a signal generator and it places no orders. All thresholds (efficiency 0.25 and 0.45, 100% and 150% of EM, the 30-minute hold, the shock sizes) are inputs and untested starting values, not optimized ones. TradingView has no options data, so nothing here uses gamma exposure or live option prices: the expected move is an approximation from VIX1D, and fly values assume settlement at the current price. Data for VIX, VIX1D, SPY and the USI symbols may be delayed depending on your subscription. Built for CBOE:SPX and SPCFD during the 09:30–16:00 New York session. State updates on confirmed bars and uses no lookahead. Not financial advice.

## Source Code

````pine
// 0DTE Fly Suite v1.1 (2026-10-13): the slot date follows the chart's latest trading day by default.
// 0DTE Fly Suite v1 (2026-10-09)
// One script for the three companion indicators, built from the versions live on 2026-10-09:
//   0DTE Clock & Shocks v3, 0DTE Fly Monitor improved-v2 and My Flies improved-v2.
// Every section has an on/off switch under "Suite sections". Notes: indicators/0dte-fly-suite/notes.md
//
// New vs the three separate scripts:
//   - Bot preset (Custom / TFT v31 control and its variants / Iron Squadron v15) sets the clock lines,
//     the VIX breaker and the My Flies exit mode. Custom keeps the manual clock inputs.
//   - VIX shock split into a warning (+2 pts / +10%, as before) and the bot breaker (+15 pts from the
//     open, TFT). A "VIX above 30" note shows before 13:30 with a TFT preset.
//   - Entry-stop and close-all clock lines, light shading after the entry stop, alerts at clock times.
//   - Early-close days listed in one input end the session, the clock lines and Mins to close early.
//   - Day type: WIDE CHOP now starts at 100% of EM (was 75%) and a new WHIPSAW state starts at 150%.
//   - Fly Monitor table: "EM left" row (approximate expected move remaining).
//   - Event-day flag and pre-market rows (gap, overnight range, open within it, VIX1D / VIX).
//   - Off by default: prior-day / overnight / gap-fill lines, Key strikes, Bias block.
//   - Every daily reset uses the New York date, so it works on SPCFD (overnight bars) and CBOE:SPX alike.
//   - My Flies with a TFT preset: touch zones off, breakeven alert fires as soon as price crosses (TFT
//     exits intrabar). With Iron Squadron: touch level moves to breakeven - 3 pts from 15:55.
//@version=6
indicator("0DTE Fly Suite", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500, max_bars_back=2000)

// ─────────────────────────────────────────────────────────────────────────────
// Inputs: suite
// ─────────────────────────────────────────────────────────────────────────────
string GSUITE = "Suite"
string GSEC   = "Suite sections"
string GSESS  = "Session"
string GCLK   = "Bot clock"
string GSHK   = "Shocks"
string GVWAP  = "VWAP bands"
string GEM    = "Expected move"
string GOR    = "Opening range"
string GTC    = "Day type"
string GFLY   = "My Flies: settings"
string GKEY   = "Key strikes"
string GBIAS  = "Bias block"
string GDISP  = "Tables"

string botPreset = input.string("Custom", "Bot preset", options=["Custom", "TFT v31 control", "TF Noon", "TF 1330 Start", "TF 30 Cutoff", "TF Exit1515", "TF Exit1530", "Iron Squadron v15"], group=GSUITE, tooltip="Sets the clock lines, the VIX breaker and the My Flies exit mode to match an Option Alpha bot. Custom uses the manual clock times below. TFT presets: Entry 10:35 (Noon 12:00, 1330 Start 13:30), Delayed 13:30, Tight 14:00, Late tight 15:30, Entry stop 15:50 (30 Cutoff and Exit1530 15:30, Exit1515 15:15), Monitor 15:55; touch zones off. Iron Squadron (unconfirmed values): Scanner 10:30, Load the boat 14:00, Landing gear 15:55.")
string eventDay = input.string("Normal", "Event day (set by hand)", options=["Normal", "FOMC", "CPI", "NFP", "OpEx", "Other event"], group=GSUITE, tooltip="TradingView can't read an economic calendar. FOMC: TFT and Iron Squadron both skip the day. The others: Iron Squadron skips, TFT trades.")

bool secClock  = input.bool(true, "Clock & Shocks (clock lines, shocks, context table)", group=GSEC)
bool secVwap   = input.bool(true, "Fly Monitor: VWAP bands", group=GSEC)
bool secEm     = input.bool(true, "Fly Monitor: expected move lines", group=GSEC)
bool secOr     = input.bool(true, "Fly Monitor: opening range", group=GSEC)
bool secFm     = input.bool(true, "Fly Monitor: table and day-type tint", group=GSEC)
bool secFlies  = input.bool(true, "My Flies", group=GSEC)
bool secPremkt = input.bool(true, "Pre-market rows (gap, overnight range, VIX1D / VIX)", group=GSEC)
bool secLevels = input.bool(false, "Prior day high/low/close, overnight high/low, gap fill", group=GSEC)
bool secKeys   = input.bool(false, "Key strikes", group=GSEC)
bool secBias   = input.bool(false, "Bias block (TICK, ADD, VOLD, VIX1D)", group=GSEC)

string tzInput = input.string("America/New_York", "Timezone", group=GSESS, tooltip="All times in the script are in this timezone. Keep New York even if the chart clock is Pacific.")
string regSession = input.session("0930-1600", "Regular session", group=GSESS)
string earlyCloseTxt = input.string("2026-11-27 13:00, 2026-12-24 13:00", "Early-close days", group=GSESS, tooltip="Date and close time (New York), separated by commas, e.g. 2026-11-27 13:00. On these days the session, the clock lines and Mins to close end at that time.")

// Bot clock. The times are used with the Custom preset only; the other settings apply to every preset.
bool clockShow = input.bool(true, "Show clock lines", group=GCLK)
color clockColor = input.color(color.gray, "Clock line colour", group=GCLK)
bool clockAlerts = input.bool(true, "Alert at each clock time", group=GCLK, tooltip="Needs a TradingView alert set to 'Any alert() function call'.")
bool shadeAfterStop = input.bool(true, "Shade the chart after the entry stop", group=GCLK)
int c1h = input.int(10, "Custom: Entry", minval=0, maxval=23, inline="m1", group=GCLK, tooltip="The Custom times are ignored when a bot preset is picked.")
int c1m = input.int(30, ":", minval=0, maxval=59, inline="m1", group=GCLK)
int c2h = input.int(13, "Custom: Late", minval=0, maxval=23, inline="m2", group=GCLK)
int c2m = input.int(30, ":", minval=0, maxval=59, inline="m2", group=GCLK)
int c3h = input.int(14, "Custom: Tight", minval=0, maxval=23, inline="m3", group=GCLK)
int c3m = input.int(0, ":", minval=0, maxval=59, inline="m3", group=GCLK)
int c4h = input.int(15, "Custom: L.Tight", minval=0, maxval=23, inline="m4", group=GCLK)
int c4m = input.int(30, ":", minval=0, maxval=59, inline="m4", group=GCLK)
int c5h = input.int(15, "Custom: Land", minval=0, maxval=23, inline="m5", group=GCLK)
int c5m = input.int(55, ":", minval=0, maxval=59, inline="m5", group=GCLK)
bool c6on = input.bool(true, "Custom: Entry stop", inline="m6", group=GCLK)
int c6h = input.int(15, "at", minval=0, maxval=23, inline="m6", group=GCLK)
int c6m = input.int(50, ":", minval=0, maxval=59, inline="m6", group=GCLK)
bool c7on = input.bool(false, "Custom: Close all", inline="m7", group=GCLK)
int c7h = input.int(15, "at", minval=0, maxval=23, inline="m7", group=GCLK)
int c7m = input.int(15, ":", minval=0, maxval=59, inline="m7", group=GCLK)

float shockMove1m = input.float(25.0, "Rapid move: 1-minute points", minval=0.0, step=1.0, group=GSHK)
float shockMove2m = input.float(40.0, "Rapid move: 2-minute points", minval=0.0, step=1.0, group=GSHK)
string vixSymbol = input.symbol("CBOE:VIX", "VIX symbol", group=GSHK)
string vixBaseInput = input.string("Session open", "VIX warning baseline", options=["Session open", "Prior close"], group=GSHK, tooltip="Session open = close of the first 1-minute VIX bar of the regular session. Prior close = yesterday's daily close.")
float shockVixPts = input.float(2.0, "VIX warning: points", minval=0.0, step=0.1, group=GSHK)
float shockVixPct = input.float(10.0, "VIX warning: percent", minval=0.0, step=0.5, group=GSHK)
float vixBreakPts = input.float(15.0, "VIX breaker: points from the open", minval=0.0, step=0.5, group=GSHK, tooltip="Theta Fly Trap closes everything and stops for the day when VIX is up this much from the session open.")
float vixMaxEntry = input.float(30.0, "VIX max for entries", minval=0.0, step=0.5, group=GSHK, tooltip="Theta Fly Trap opens no fly while VIX is above this, until it drops or 13:30.")
bool shockMarkBars = input.bool(true, "Show shock markers", group=GSHK)

string volumeSymbol = input.symbol("AMEX:SPY", "Volume source symbol", group=GVWAP, tooltip="External symbol used as a proxy for SPX volume. If unavailable, the script falls back to hlc3.")
float band1Mult = input.float(1.0, "Band 1 stdev multiplier", minval=0.0, step=0.25, group=GVWAP)
float band2Mult = input.float(2.0, "Band 2 stdev multiplier", minval=0.0, step=0.25, group=GVWAP)

string volSymbolPrimary = input.symbol("CBOE:VIX1D", "Primary volatility symbol", group=GEM)
string volSymbolFallback = input.symbol("CBOE:VIX", "Fallback volatility symbol", group=GEM, tooltip="Used when the primary has no usable data. VIX is a 30-day vol, so its EM is only a rough stand-in.")
int emLatchDelay = input.int(1, "Latch EM at open + (minutes)", minval=0, maxval=30, group=GEM, tooltip="EM uses the vol index value printed this many minutes after the session open (1 = the 09:31 print). Skips the first print, which can still be yesterday's close.")

int orStartHour = input.int(9, "Start hour", minval=0, maxval=23, group=GOR)
int orStartMin = input.int(30, "Start minute", minval=0, maxval=59, group=GOR)
int orEndHour = input.int(10, "End hour", minval=0, maxval=23, group=GOR)
int orEndMin = input.int(30, "End minute", minval=0, maxval=59, group=GOR)
float orBreakPts = input.float(2.0, "Breakout threshold (points)", minval=0.0, step=0.25, group=GOR, tooltip="A break only registers when a bar CLOSES at least this many points beyond the opening range.")

int erRollMinutes = input.int(60, "Rolling ER window (minutes)", minval=1, maxval=390, group=GTC)
float erPinThresh = input.float(0.25, "PIN/RANGE efficiency threshold", minval=0.0, maxval=1.0, step=0.01, group=GTC, tooltip="Session efficiency BELOW this (and price inside +/-1 SD of VWAP) classifies the day as PIN/RANGE.")
float erWideChopThresh = input.float(100.0, "WIDE CHOP: Range vs EM % from", minval=0.0, step=1.0, group=GTC, tooltip="Low efficiency but a range already this big a share of EM = WIDE CHOP instead of PIN/RANGE. Was 75 in the Fly Monitor; at 75 it fired on every day of the week of 10/5, because a normal day's range is about one EM.")
float erWhipsawThresh = input.float(150.0, "WHIPSAW: Range vs EM % from", minval=0.0, step=5.0, group=GTC, tooltip="Any day that is not TREND with a range this big a share of EM. On 10/5 and 10/8 (the two losing days of that week) the range passed 150% of EM; on the two winning days it stayed near 110%.")
float erTrendThresh = input.float(0.45, "TREND efficiency threshold", minval=0.0, maxval=1.0, step=0.01, group=GTC)
int erTrendHoldMin = input.int(30, "TREND hold (minutes)", minval=1, maxval=390, group=GTC)
color erColorTrend = input.color(color.new(color.red, 90), "TREND", group=GTC, inline="tc1")
color erColorPin = input.color(color.new(color.green, 90), "PIN/RANGE", group=GTC, inline="tc1")
color erColorDrift = input.color(color.new(color.orange, 90), "DRIFT", group=GTC, inline="tc1")
color erColorWideChop = input.color(color.new(color.purple, 90), "WIDE CHOP", group=GTC, inline="tc2")
color erColorWhipsaw = input.color(color.new(color.fuchsia, 85), "WHIPSAW", group=GTC, inline="tc2")
bool erShowBg = input.bool(true, "Show day-type background", group=GTC)

// ─────────────────────────────────────────────────────────────────────────────
// Inputs: My Flies slots (inputs must be declared one by one at global scope)
// ─────────────────────────────────────────────────────────────────────────────
string TIME_TIP = "Optional. Entry and exit are clock TIMES, not prices: HH:MM in New York time, e.g. 10:35 or 1035. Leave Exit empty if the fly is still open or expired. Leave both empty and the fly counts as live all session. P/L (dollars, optional) colors the trade box and shows in its tag; a P/L with no exit marks the fly closed."
string WING_TIP = "Distance from the center to each wing, e.g. 50 for 7745/7795/7845. Used for Risk $ and At expiry $. 0 = hide those columns for this fly."

slot1Enabled = input.bool(false, "Enabled", group="Slot 1")
slot1Center  = input.float(7600.0, "Center strike", minval=0.0, step=5.0, group="Slot 1")
slot1Credit  = input.float(25.0, "Credit received (points)", minval=0.0, step=0.5, group="Slot 1")
slot1Wing    = input.float(50.0, "Wing width (points)", minval=0.0, step=5.0, group="Slot 1", tooltip=WING_TIP)
slot1Label   = input.string("Fly 1", "Label", group="Slot 1")
slot1Entry   = input.string("", "Entry", inline="t1", group="Slot 1", tooltip=TIME_TIP)
slot1Exit    = input.string("", "Exit", inline="t1", group="Slot 1")
slot1Pl      = input.float(0.0, "P/L $", inline="t1", group="Slot 1")

slot2Enabled = input.bool(false, "Enabled", group="Slot 2")
slot2Center  = input.float(7650.0, "Center strike", minval=0.0, step=5.0, group="Slot 2")
slot2Credit  = input.float(25.0, "Credit received (points)", minval=0.0, step=0.5, group="Slot 2")
slot2Wing    = input.float(50.0, "Wing width (points)", minval=0.0, step=5.0, group="Slot 2", tooltip=WING_TIP)
slot2Label   = input.string("Fly 2", "Label", group="Slot 2")
slot2Entry   = input.string("", "Entry", inline="t2", group="Slot 2", tooltip=TIME_TIP)
slot2Exit    = input.string("", "Exit", inline="t2", group="Slot 2")
slot2Pl      = input.float(0.0, "P/L $", inline="t2", group="Slot 2")

slot3Enabled = input.bool(false, "Enabled", group="Slot 3")
slot3Center  = input.float(7700.0, "Center strike", minval=0.0, step=5.0, group="Slot 3")
slot3Credit  = input.float(25.0, "Credit received (points)", minval=0.0, step=0.5, group="Slot 3")
slot3Wing    = input.float(50.0, "Wing width (points)", minval=0.0, step=5.0, group="Slot 3", tooltip=WING_TIP)
slot3Label   = input.string("Fly 3", "Label", group="Slot 3")
slot3Entry   = input.string("", "Entry", inline="t3", group="Slot 3", tooltip=TIME_TIP)
slot3Exit    = input.string("", "Exit", inline="t3", group="Slot 3")
slot3Pl      = input.float(0.0, "P/L $", inline="t3", group="Slot 3")

slot4Enabled = input.bool(false, "Enabled", group="Slot 4")
slot4Center  = input.float(7550.0, "Center strike", minval=0.0, step=5.0, group="Slot 4")
slot4Credit  = input.float(25.0, "Credit received (points)", minval=0.0, step=0.5, group="Slot 4")
slot4Wing    = input.float(50.0, "Wing width (points)", minval=0.0, step=5.0, group="Slot 4", tooltip=WING_TIP)
slot4Label   = input.string("Fly 4", "Label", group="Slot 4")
slot4Entry   = input.string("", "Entry", inline="t4", group="Slot 4", tooltip=TIME_TIP)
slot4Exit    = input.string("", "Exit", inline="t4", group="Slot 4")
slot4Pl      = input.float(0.0, "P/L $", inline="t4", group="Slot 4")

slot5Enabled = input.bool(false, "Enabled", group="Slot 5")
slot5Center  = input.float(7625.0, "Center strike", minval=0.0, step=5.0, group="Slot 5")
slot5Credit  = input.float(25.0, "Credit received (points)", minval=0.0, step=0.5, group="Slot 5")
slot5Wing    = input.float(50.0, "Wing width (points)", minval=0.0, step=5.0, group="Slot 5", tooltip=WING_TIP)
slot5Label   = input.string("Fly 5", "Label", group="Slot 5")
slot5Entry   = input.string("", "Entry", inline="t5", group="Slot 5", tooltip=TIME_TIP)
slot5Exit    = input.string("", "Exit", inline="t5", group="Slot 5")
slot5Pl      = input.float(0.0, "P/L $", inline="t5", group="Slot 5")

slot6Enabled = input.bool(false, "Enabled", group="Slot 6")
slot6Center  = input.float(7675.0, "Center strike", minval=0.0, step=5.0, group="Slot 6")
slot6Credit  = input.float(25.0, "Credit received (points)", minval=0.0, step=0.5, group="Slot 6")
slot6Wing    = input.float(50.0, "Wing width (points)", minval=0.0, step=5.0, group="Slot 6", tooltip=WING_TIP)
slot6Label   = input.string("Fly 6", "Label", group="Slot 6")
slot6Entry   = input.string("", "Entry", inline="t6", group="Slot 6", tooltip=TIME_TIP)
slot6Exit    = input.string("", "Exit", inline="t6", group="Slot 6")
slot6Pl      = input.float(0.0, "P/L $", inline="t6", group="Slot 6")

slot7Enabled = input.bool(false, "Enabled", group="Slot 7")
slot7Center  = input.float(7600.0, "Center strike", minval=0.0, step=5.0, group="Slot 7")
slot7Credit  = input.float(25.0, "Credit received (points)", minval=0.0, step=0.5, group="Slot 7")
slot7Wing    = input.float(50.0, "Wing width (points)", minval=0.0, step=5.0, group="Slot 7", tooltip=WING_TIP)
slot7Label   = input.string("Fly 7", "Label", group="Slot 7")
slot7Entry   = input.string("", "Entry", inline="t7", group="Slot 7", tooltip=TIME_TIP)
slot7Exit    = input.string("", "Exit", inline="t7", group="Slot 7")
slot7Pl      = input.float(0.0, "P/L $", inline="t7", group="Slot 7")

slot8Enabled = input.bool(false, "Enabled", group="Slot 8")
slot8Center  = input.float(7650.0, "Center strike", minval=0.0, step=5.0, group="Slot 8")
slot8Credit  = input.float(25.0, "Credit received (points)", minval=0.0, step=0.5, group="Slot 8")
slot8Wing    = input.float(50.0, "Wing width (points)", minval=0.0, step=5.0, group="Slot 8", tooltip=WING_TIP)
slot8Label   = input.string("Fly 8", "Label", group="Slot 8")
slot8Entry   = input.string("", "Entry", inline="t8", group="Slot 8", tooltip=TIME_TIP)
slot8Exit    = input.string("", "Exit", inline="t8", group="Slot 8")
slot8Pl      = input.float(0.0, "P/L $", inline="t8", group="Slot 8")

slot9Enabled = input.bool(false, "Enabled", group="Slot 9")
slot9Center  = input.float(7700.0, "Center strike", minval=0.0, step=5.0, group="Slot 9")
slot9Credit  = input.float(25.0, "Credit received (points)", minval=0.0, step=0.5, group="Slot 9")
slot9Wing    = input.float(50.0, "Wing width (points)", minval=0.0, step=5.0, group="Slot 9", tooltip=WING_TIP)
slot9Label   = input.string("Fly 9", "Label", group="Slot 9")
slot9Entry   = input.string("", "Entry", inline="t9", group="Slot 9", tooltip=TIME_TIP)
slot9Exit    = input.string("", "Exit", inline="t9", group="Slot 9")
slot9Pl      = input.float(0.0, "P/L $", inline="t9", group="Slot 9")

slot10Enabled = input.bool(false, "Enabled", group="Slot 10")
slot10Center  = input.float(7550.0, "Center strike", minval=0.0, step=5.0, group="Slot 10")
slot10Credit  = input.float(25.0, "Credit received (points)", minval=0.0, step=0.5, group="Slot 10")
slot10Wing    = input.float(50.0, "Wing width (points)", minval=0.0, step=5.0, group="Slot 10", tooltip=WING_TIP)
slot10Label   = input.string("Fly 10", "Label", group="Slot 10")
slot10Entry   = input.string("", "Entry", inline="t10", group="Slot 10", tooltip=TIME_TIP)
slot10Exit    = input.string("", "Exit", inline="t10", group="Slot 10")
slot10Pl      = input.float(0.0, "P/L $", inline="t10", group="Slot 10")

float touchPct = input.float(95.0, "Touch zone percent of credit", minval=0.0, maxval=100.0, step=1.0, group=GFLY, tooltip="The touch level sits this far out toward the breakeven. Not drawn with a TFT preset (TFT has no touch exits).")
int lineWidth = input.int(2, "Line width", minval=1, maxval=5, group=GFLY)
bool showTouchInput = input.bool(true, "Show touch zones", group=GFLY)
bool flyDateAuto = input.bool(true, "Slots follow the latest trading day", group=GFLY, tooltip="On: the slots count, draw and alert on the newest trading day on the chart (New York date), so there is no date to set each morning. Off: they use the date typed below.")
string flyDateTxt = input.string("", "Trade date for the slots (when auto is off)", group=GFLY, tooltip="New York date as YYYY-MM-DD, e.g. 2026-10-13. Plain text, so it can't shift with the chart's timezone. Empty or unreadable falls back to the latest trading day.")
bool keepAfterClose = input.bool(true, "Keep drawings after the close", group=GFLY)
string styleInput = input.string("Both", "Fly drawing style", options=["Levels", "Trade boxes", "Both"], group=GFLY, tooltip="Levels: center, breakeven and touch lines. Trade boxes: one box per fly from entry to exit, top and bottom at the breakevens. Both: levels while a fly is open, only its box once closed. Boxes need an entry time.")
int boxTransp = input.int(80, "Trade box fill transparency", minval=0, maxval=100, group=GFLY)
bool showTags = input.bool(true, "Show fly name on chart", group=GFLY)
bool alertsInSessionOnly = input.bool(true, "Alert only during the session", group=GFLY)

string keyTxt = input.text_area("", "Levels", group=GKEY, tooltip="One level per line (or comma separated): price and an optional name, e.g.\n7800 call wall\n7750 put wall\nDrawn from today's open. Turn on 'Key strikes' under Suite sections.")
color keyColor = input.color(color.new(color.yellow, 0), "Line colour", group=GKEY)

string tickSym = input.symbol("USI:TICK", "TICK symbol", group=GBIAS)
string addSym = input.symbol("USI:ADD", "ADD symbol", group=GBIAS)
string voldSym = input.symbol("USI:VOLD", "VOLD symbol", group=GBIAS)
int biasMins = input.int(30, "Smoothing / trend window (minutes)", minval=1, maxval=120, group=GBIAS)
float tickTh = input.float(150.0, "TICK: smoothed level that counts", minval=0.0, step=10.0, group=GBIAS, tooltip="Smoothed TICK above +this scores Up, below -this scores Down.")
float vixBiasPts = input.float(0.5, "VIX1D: change since open that counts", minval=0.0, step=0.1, group=GBIAS, tooltip="VIX1D down this much since the open scores Up, up this much scores Down.")

string ctxPos = input.string("Middle left", "Clock & context table", options=["Top left", "Middle left", "Bottom left", "Top right", "Middle right", "Bottom right"], group=GDISP, inline="d1")
string ctxSize = input.string("Small", "", options=["Tiny", "Small", "Normal"], group=GDISP, inline="d1")
string fmPos = input.string("Top right", "Fly Monitor table", options=["Top left", "Middle left", "Bottom left", "Top right", "Middle right", "Bottom right"], group=GDISP, inline="d2")
string fmSize = input.string("Small", "", options=["Tiny", "Small", "Normal"], group=GDISP, inline="d2")
string flyPos = input.string("Bottom right", "My Flies table", options=["Top left", "Middle left", "Bottom left", "Top right", "Middle right", "Bottom right"], group=GDISP, inline="d3")
string flySize = input.string("Small", "", options=["Tiny", "Small", "Normal"], group=GDISP, inline="d3")

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────
f_pos(string s) =>
    switch s
        "Top left" => position.top_left
        "Middle left" => position.middle_left
        "Bottom left" => position.bottom_left
        "Top right" => position.top_right
        "Middle right" => position.middle_right
        => position.bottom_right

f_size(string s) =>
    switch s
        "Tiny" => size.tiny
        "Normal" => size.normal
        => size.small

f_fmt(float x) =>
    na(x) ? "n/a" : str.tostring(x, format.mintick)

f_fmt2(float x) =>
    na(x) ? "n/a" : str.tostring(x, "0.00")

f_signed(float x) =>
    na(x) ? "n/a" : (x >= 0 ? "+" : "") + str.tostring(x, "0.00")

f_pct(float x) =>
    na(x) ? "n/a" : str.tostring(x, "0.0") + "%"

f_clock(int t) =>
    na(t) ? "n/a" : str.format_time(t, "HH:mm", tzInput)

// Minutes after midnight -> "HH:MM".
f_hm(int mod) =>
    str.format("{0,number,00}:{1,number,00}", int(math.floor(mod / 60)), mod % 60)

// "0930-1600" -> minutes after midnight for the start (offset 0) or end (offset 5).
f_parseSess(string s, int offset) =>
    int(str.tonumber(str.substring(s, offset, offset + 2))) * 60 + int(str.tonumber(str.substring(s, offset + 2, offset + 4)))

// "HH:MM" or "HHMM" -> minutes after midnight, or na if empty or not a clock time
// (a price such as 7792.52 is rejected rather than read as a time).
f_parseHM(string s) =>
    string t = str.replace_all(s, " ", "")
    float h = na
    float m = na
    if str.contains(t, ":")
        array<string> parts = str.split(t, ":")
        if parts.size() == 2 and not str.contains(t, ".")
            h := str.tonumber(parts.get(0))
            m := str.tonumber(parts.get(1))
    else if str.length(t) >= 3 and str.length(t) <= 4 and not str.contains(t, ".")
        float n = str.tonumber(t)
        if not na(n)
            h := math.floor(n / 100)
            m := n % 100
    float mins = na
    if not na(h) and not na(m) and h >= 0 and h <= 23 and m >= 0 and m <= 59
        mins := h * 60 + m
    mins

// True when something was typed but it isn't a clock time.
f_badTime(string s) =>
    str.replace_all(s, " ", "") != "" and na(f_parseHM(s))

// A number that changes when the calendar day changes in tzInput (e.g. 20261009).
dayKey(int t) =>
    year(t, tzInput) * 10000 + month(t, tzInput) * 100 + dayofmonth(t, tzInput)

f_mod(int t) =>
    hour(t, tzInput) * 60 + minute(t, tzInput)

// Minutes after midnight -> timestamp on the current bar's date.
f_tsToday(int mod) =>
    timestamp(tzInput, year(time, tzInput), month(time, tzInput), dayofmonth(time, tzInput), int(math.floor(mod / 60)), mod % 60, 0)

// One table row: name on the left, value on the right. Returns the next row number.
f_row(table tb, int r, string k, string v, color vc, string sz) =>
    table.cell(tb, 0, r, k, text_color=color.white, text_size=sz, text_halign=text.align_left)
    table.cell(tb, 1, r, v, text_color=vc, text_size=sz, text_halign=text.align_left)
    r + 1

// Converts a duration in minutes to a bar count on the current chart timeframe.
float tfSec = timeframe.in_seconds()
f_minsToBars(simple int mins) =>
    math.max(1, int(math.ceil(mins * 60.0 / tfSec)))

// ─────────────────────────────────────────────────────────────────────────────
// Session, early closes and the daily reset
// ─────────────────────────────────────────────────────────────────────────────
if timeframe.in_seconds() < 60
    runtime.error("0DTE Fly Suite needs a 1-minute or higher chart: shocks are measured on 1-minute bars.")

int sessStartMod = f_parseSess(regSession, 0)
int sessEndDefault = f_parseSess(regSession, 5)

// Early-close days: date key -> close time in minutes after midnight.
var map<int, int> earlyClose = map.new<int, int>()
if barstate.isfirst
    array<string> toks = str.split(str.replace_all(str.replace_all(earlyCloseTxt, "\n", " "), ",", " "), " ")
    int pendingDate = na
    for tk in toks
        if str.contains(tk, "-")
            pendingDate := int(str.tonumber(str.replace_all(tk, "-", "")))
        else if tk != "" and not na(pendingDate)
            float em = f_parseHM(tk)
            if not na(em)
                earlyClose.put(pendingDate, int(em))
            pendingDate := na

f_sessEnd(int t) =>
    int dk = dayKey(t)
    earlyClose.contains(dk) ? earlyClose.get(dk) : sessEndDefault

// Is a given timestamp (e.g. a 1-minute bar's open) inside the regular session?
inRegSession(int t) =>
    int mod = f_mod(t)
    mod >= sessStartMod and mod < f_sessEnd(t)

int barMod = f_mod(time)
int todayKey = dayKey(time)
int sessEndMod = f_sessEnd(time)
bool inSession = not na(time(timeframe.period, regSession, tzInput)) and barMod < sessEndMod
bool newDay = na(time[1]) or todayKey != dayKey(time[1])
// The date check catches a new session on charts with no out-of-session bars (CBOE:SPX),
// where yesterday's last bar was also "in session".
bool newSession = inSession and (not inSession[1] or newDay)
bool endSession = not inSession and inSession[1]

var int sessStartT = na
if newSession
    sessStartT := time

// ─────────────────────────────────────────────────────────────────────────────
// Bot preset: clock times and modes
// ─────────────────────────────────────────────────────────────────────────────
bool isIS = botPreset == "Iron Squadron v15"
bool isTFT = botPreset != "Custom" and not isIS

var array<int> clkMod = array.new<int>()
var array<string> clkName = array.new<string>()
var int entryStopMod = na
var int closeAllMod = na

if barstate.isfirst
    if isTFT
        int entryM = botPreset == "TF Noon" ? 720 : botPreset == "TF 1330 Start" ? 810 : 635
        int stopM = botPreset == "TF Exit1515" ? 915 : botPreset == "TF 30 Cutoff" or botPreset == "TF Exit1530" ? 930 : 950
        bool closesAll = botPreset == "TF Exit1515" or botPreset == "TF Exit1530"
        clkMod.push(entryM)
        clkName.push("Entry")
        if entryM < 810
            clkMod.push(810)
            clkName.push("Delayed")
        clkMod.push(840)
        clkName.push("Tight")
        if stopM > 930
            clkMod.push(930)
            clkName.push("Late tight")
        clkMod.push(stopM)
        clkName.push(closesAll ? "Entry stop + close all" : "Entry stop")
        entryStopMod := stopM
        if closesAll
            closeAllMod := stopM
        else
            clkMod.push(955)
            clkName.push("Monitor")
    else if isIS
        clkMod.push(630)
        clkName.push("Scanner")
        clkMod.push(840)
        clkName.push("Load the boat")
        clkMod.push(955)
        clkName.push("Landing gear")
    else
        clkMod.push(c1h * 60 + c1m)
        clkName.push("Entry")
        clkMod.push(c2h * 60 + c2m)
        clkName.push("Late")
        clkMod.push(c3h * 60 + c3m)
        clkName.push("Tight")
        clkMod.push(c4h * 60 + c4m)
        clkName.push("L.Tight")
        clkMod.push(c5h * 60 + c5m)
        clkName.push("Land")
        if c6on
            clkMod.push(c6h * 60 + c6m)
            clkName.push("Entry stop")
            entryStopMod := c6h * 60 + c6m
        if c7on
            clkMod.push(c7h * 60 + c7m)
            clkName.push("Close all")
            closeAllMod := c7h * 60 + c7m

// Iron Squadron's Landing Gear: from 15:55 the touch exit sits 3 points inside the breakeven (unconfirmed).
bool landingNow = isIS and barMod >= 955
bool showTouch = showTouchInput and not isTFT

// ─────────────────────────────────────────────────────────────────────────────
// Clock lines, labels, alerts
// Lines for the whole day are drawn at the first bar of the day, so upcoming
// times are visible ahead of time (xloc.bar_time allows future x).
// ─────────────────────────────────────────────────────────────────────────────
var array<line> clockLines = array.new<line>()
int nClk = clkMod.size()

if newDay
    for ln in clockLines
        line.delete(ln)
    clockLines.clear()
    if secClock and clockShow and nClk > 0
        for i = 0 to nClk - 1
            int m = clkMod.get(i)
            // On an early-close day, clock times after the close are skipped.
            if m < sessEndMod
                int ts = f_tsToday(m)
                bool stopLine = m == entryStopMod or m == closeAllMod
                clockLines.push(line.new(ts, low, ts, high, xloc=xloc.bar_time, extend=extend.both, color=stopLine ? color.new(color.orange, 30) : clockColor, style=line.style_dashed, width=stopLine ? 2 : 1))

if secClock and clockShow and inSession and nClk > 0
    for i = 0 to nClk - 1
        int ts = f_tsToday(clkMod.get(i))
        if time <= ts and time_close > ts
            label.new(bar_index, low, clkName.get(i), yloc=yloc.belowbar, style=label.style_label_up, color=color.new(clockColor, 100), textcolor=color.silver, size=size.small)
            if clockAlerts
                alert("0DTE Fly Suite: " + clkName.get(i) + " " + f_hm(clkMod.get(i)) + " (" + botPreset + ") on " + syminfo.ticker, alert.freq_once_per_bar)

bgcolor(secClock and shadeAfterStop and inSession and not na(entryStopMod) and barMod >= entryStopMod ? color.new(color.gray, 88) : na, title="After entry stop")

// ─────────────────────────────────────────────────────────────────────────────
// 1-minute data: one array element per 1m bar inside the current chart bar
// ─────────────────────────────────────────────────────────────────────────────
[spxT, spxC] = request.security_lower_tf(syminfo.tickerid, "1", [time, close])
[vixT, vixC] = request.security_lower_tf(vixSymbol, "1", [time, close])
// Newest 1m VIX bar available now. Live with a delayed feed this lags the chart,
// so it catches 1m bars that request.security_lower_tf missed.
[vixLatestT, vixLatestC] = request.security(vixSymbol, "1", [time, close], lookahead=barmerge.lookahead_off)
// Prior close: if the VIX daily bar is still open (today's), use its close[1]. If it has already
// closed, the feed is still on yesterday's daily bar, so that bar's own close is the prior close.
[vixDayTC, vixDayC, vixDayC1] = request.security(vixSymbol, "D", [time_close, close, close[1]], lookahead=barmerge.lookahead_on)
float vixPrevClose = not na(vixDayTC) and vixDayTC <= time ? vixDayC : vixDayC1

// ─────────────────────────────────────────────────────────────────────────────
// Rapid moves (1-minute closes, never across the overnight gap)
// ─────────────────────────────────────────────────────────────────────────────
var float p1 = na
var float p2 = na
var int spxDay = na

bool rapidUp = false
bool rapidDn = false
float rapidPts = na
int rapidTime = na

for [i, c] in spxC
    int bt = array.get(spxT, i)
    int dk = dayKey(bt)
    if not inRegSession(bt) or na(spxDay) or dk != spxDay
        p1 := na
        p2 := na
        spxDay := dk
    if inRegSession(bt)
        float d1 = na(p1) ? na : c - p1
        float d2 = na(p2) ? na : c - p2
        bool hit1 = not na(d1) and math.abs(d1) >= shockMove1m
        bool hit2 = not na(d2) and math.abs(d2) >= shockMove2m
        if hit1 or hit2
            float mv = hit1 ? d1 : d2
            if mv >= 0
                rapidUp := true
            else
                rapidDn := true
            if na(rapidPts) or math.abs(mv) > math.abs(rapidPts)
                rapidPts := mv
                rapidTime := bt
        p2 := p1
        p1 := c

bool rapidMove = rapidUp or rapidDn

var float lastRapidPts = na
var int lastRapidTime = na
if rapidMove
    lastRapidPts := rapidPts
    lastRapidTime := rapidTime

// ─────────────────────────────────────────────────────────────────────────────
// VIX: warning (as Clock & Shocks v3) and the TFT breaker (+15 pts from the open)
// ─────────────────────────────────────────────────────────────────────────────
var float vixBase = na
var float vixLast = na
var float vixOpen = na      // first in-session 1m print today
var int vixDay = na
var bool vixAbove = false   // warning: currently at/above the threshold
var bool vixBreaker = false // breaker tripped today
var int lastVixTime = na
var int vixSeenT = na
var float vixPrior = na

bool vixEvent = false
bool vixBreakEvent = false

array<int> vixTs = array.copy(vixT)
array<float> vixCs = array.copy(vixC)
if not na(vixLatestT) and (array.size(vixTs) == 0 or vixLatestT > array.last(vixTs))
    array.push(vixTs, vixLatestT)
    array.push(vixCs, vixLatestC)

for [i, c] in vixCs
    int bt = array.get(vixTs, i)
    if inRegSession(bt) and (na(vixSeenT) or bt > vixSeenT) and not na(c)
        vixSeenT := bt
        int dk = dayKey(bt)
        if na(vixDay) or dk != vixDay
            vixDay := dk
            vixPrior := vixPrevClose
            vixOpen := c
            vixBase := vixBaseInput == "Prior close" ? vixPrior : c
            vixAbove := false
            vixBreaker := false
        vixLast := c
        float chg = na(vixBase) ? na : c - vixBase
        float pct = na(chg) or vixBase == 0 ? na : chg / vixBase * 100.0
        // Only an UP move in VIX counts.
        bool above = (not na(chg) and chg >= shockVixPts) or (not na(pct) and pct >= shockVixPct)
        if above and not vixAbove
            vixEvent := true
            lastVixTime := bt
        vixAbove := above
        if not vixBreaker and c - vixOpen >= vixBreakPts
            vixBreaker := true
            vixBreakEvent := true

float vixChg = na(vixLast) or na(vixBase) ? na : vixLast - vixBase
float vixChgPct = na(vixChg) or vixBase == 0 ? na : vixChg / vixBase * 100.0
float vixDispChg = na(vixLast) or na(vixPrior) ? na : vixLast - vixPrior
float vixDispPct = na(vixDispChg) or vixPrior == 0 ? na : vixDispChg / vixPrior * 100.0
float vixFromOpen = na(vixLast) or na(vixOpen) ? na : vixLast - vixOpen

plotshape(secClock and shockMarkBars and rapidUp, title="Rapid move up", style=shape.triangleup, location=location.belowbar, color=color.lime, size=size.tiny)
plotshape(secClock and shockMarkBars and rapidDn, title="Rapid move down", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.tiny)
plotshape(secClock and shockMarkBars and vixEvent, title="VIX warning", style=shape.circle, location=location.top, color=color.fuchsia, size=size.tiny)
plotshape(secClock and shockMarkBars and vixBreakEvent, title="VIX breaker", style=shape.xcross, location=location.top, color=color.red, size=size.small)

alertcondition(rapidMove, title="Shock: rapid move", message="0DTE Fly Suite: RAPID MOVE on {{ticker}} at {{close}}")
alertcondition(rapidUp, title="Shock: rapid move up", message="0DTE Fly Suite: RAPID MOVE UP on {{ticker}} at {{close}}")
alertcondition(rapidDn, title="Shock: rapid move down", message="0DTE Fly Suite: RAPID MOVE DOWN on {{ticker}} at {{close}}")
alertcondition(vixEvent, title="Shock: VIX warning", message="0DTE Fly Suite: VIX crossed its warning threshold")
alertcondition(vixBreakEvent, title="Shock: VIX breaker (TFT closes all)", message="0DTE Fly Suite: VIX is up 15+ points from the open, Theta Fly Trap closes everything")

if secClock and rapidMove
    alert("0DTE Fly Suite: rapid move " + f_signed(rapidPts) + " pts on " + syminfo.ticker + " at " + f_clock(rapidTime), alert.freq_once_per_bar)
if secClock and vixEvent
    alert("0DTE Fly Suite: VIX warning, " + f_fmt2(vixLast) + " (" + f_signed(vixChg) + " pts / " + f_signed(vixChgPct) + "% vs " + vixBaseInput + ")", alert.freq_once_per_bar)
if secClock and vixBreakEvent
    alert("0DTE Fly Suite: VIX breaker, " + f_fmt2(vixLast) + " is " + f_signed(vixFromOpen) + " pts from the open. TFT would close all and stop for the day.", alert.freq_once_per_bar)

// ─────────────────────────────────────────────────────────────────────────────
// Fly Monitor 1: session VWAP bands
// SPX has no native volume, so an external proxy volume symbol is used when available.
// ─────────────────────────────────────────────────────────────────────────────
float extVol = request.security(volumeSymbol, timeframe.period, volume, lookahead=barmerge.lookahead_off)
bool volUsable = inSession and not na(extVol) and extVol > 0

var bool vwapUseVolume = false
var float sumPV = na
var float sumV = na
var float sumVP2 = na
var float sumP = na
var float sumP2 = na
var int vwapBars = na
var float vwapVal = na
var float vwapStd = na
var int sessBars = 0

if newSession
    vwapUseVolume := volUsable
    sumPV := 0.0
    sumV := 0.0
    sumVP2 := 0.0
    sumP := 0.0
    sumP2 := 0.0
    vwapBars := 0
    sessBars := 0

if inSession
    sessBars += 1
    float price = hlc3
    if vwapUseVolume
        float v = nz(extVol)
        sumPV += price * v
        sumV += v
        sumVP2 += price * price * v
        vwapVal := sumV > 0 ? sumPV / sumV : na
        vwapStd := sumV > 0 and not na(vwapVal) ? math.sqrt(math.max(0.0, sumVP2 / sumV - vwapVal * vwapVal)) : na
    else
        sumP += price
        sumP2 += price * price
        vwapBars += 1
        vwapVal := vwapBars > 0 ? sumP / vwapBars : na
        vwapStd := vwapBars > 0 and not na(vwapVal) ? math.sqrt(math.max(0.0, sumP2 / vwapBars - vwapVal * vwapVal)) : na
else
    vwapVal := na
    vwapStd := na

float band1Upper = not na(vwapVal) and not na(vwapStd) ? vwapVal + band1Mult * vwapStd : na
float band1Lower = not na(vwapVal) and not na(vwapStd) ? vwapVal - band1Mult * vwapStd : na
float band2Upper = not na(vwapVal) and not na(vwapStd) ? vwapVal + band2Mult * vwapStd : na
float band2Lower = not na(vwapVal) and not na(vwapStd) ? vwapVal - band2Mult * vwapStd : na

pVwap = plot(secVwap ? vwapVal : na, "Session VWAP", color=color.new(color.white, 0), linewidth=2, style=plot.style_linebr)
pU1 = plot(secVwap ? band1Upper : na, "+1 Band", color=color.new(color.aqua, 0), linewidth=1, style=plot.style_linebr)
pL1 = plot(secVwap ? band1Lower : na, "-1 Band", color=color.new(color.aqua, 0), linewidth=1, style=plot.style_linebr)
pU2 = plot(secVwap ? band2Upper : na, "+2 Band", color=color.new(color.blue, 0), linewidth=1, style=plot.style_linebr)
pL2 = plot(secVwap ? band2Lower : na, "-2 Band", color=color.new(color.blue, 0), linewidth=1, style=plot.style_linebr)
fill(pU1, pL1, color=color.new(color.aqua, 88), title="VWAP 1σ Fill")

// ─────────────────────────────────────────────────────────────────────────────
// Fly Monitor 2: expected move
// The vol value is taken from the vol index's own bar stamped at or after (open + latch delay),
// so a delayed feed still on yesterday's bar at 09:30 can't be latched.
// ─────────────────────────────────────────────────────────────────────────────
[volOpenPrimary, volTimePrimary, volClosePrimary] = request.security(volSymbolPrimary, timeframe.period, [open, time, close], lookahead=barmerge.lookahead_off)
[volOpenFallback, volTimeFallback, volCloseFallback] = request.security(volSymbolFallback, timeframe.period, [open, time, close], lookahead=barmerge.lookahead_off)
int emLatchTs = f_tsToday(sessStartMod) + emLatchDelay * 60000
bool primaryOk = not na(volOpenPrimary) and volOpenPrimary > 0 and not na(volTimePrimary) and volTimePrimary >= emLatchTs
bool fallbackOk = not na(volOpenFallback) and volOpenFallback > 0 and not na(volTimeFallback) and volTimeFallback >= emLatchTs
// Give the primary 20 minutes to print before falling back (covers a 15-minute delayed feed).
bool fallbackAllowed = time >= emLatchTs + 20 * 60000 and fallbackOk
string volSymbolUsed = primaryOk ? volSymbolPrimary : volSymbolFallback
float volOpenUsed = primaryOk ? volOpenPrimary : fallbackAllowed ? volOpenFallback : na

var float sessionOpen = na
var float sessionHigh = na
var float sessionLow = na
var float emLatched = na
var float emBaseOpen = na
var string emSymUsed = na
var float emVolUsed = na

// Prior day and overnight, captured before today's values reset.
var float lastSessClose = na
var float pdHigh = na
var float pdLow = na
var float pdClose = na
var float onHi = na     // running overnight high/low (bars outside the session)
var float onLo = na
var float onHigh = na   // overnight high/low frozen at today's open
var float onLow = na
var int onBarsRun = 0   // out-of-session bars since the last close
// CBOE:SPX prints a stray bar or two outside 09:30-16:00; an overnight range needs at least an hour of bars.
int onMinBars = f_minsToBars(60)

if newSession
    pdHigh := sessionHigh
    pdLow := sessionLow
    pdClose := lastSessClose
    onHigh := onBarsRun >= onMinBars ? onHi : na
    onLow := onBarsRun >= onMinBars ? onLo : na
    onHi := na
    onLo := na
    onBarsRun := 0
if not inSession
    if inSession[1]
        onHi := high
        onLo := low
        onBarsRun := 1
    else
        onBarsRun += 1
        onHi := na(onHi) ? high : math.max(onHi, high)
        onLo := na(onLo) ? low : math.min(onLo, low)
else
    lastSessClose := close

if newSession
    sessionOpen := open
    sessionHigh := high
    sessionLow := low
    emLatched := na
    emBaseOpen := na
    emSymUsed := na
    emVolUsed := na
else if inSession
    sessionHigh := math.max(nz(sessionHigh, high), high)
    sessionLow := math.min(nz(sessionLow, low), low)

if inSession and na(emLatched) and not na(volOpenUsed) and volOpenUsed > 0 and not na(sessionOpen)
    emBaseOpen := sessionOpen
    emLatched := sessionOpen * (volOpenUsed / 100.0) * math.sqrt(1.0 / 252.0)
    emSymUsed := volSymbolUsed
    emVolUsed := volOpenUsed

float emUsedPct = not na(emLatched) and emLatched != 0 ? math.abs(close - emBaseOpen) / emLatched * 100.0 : na
float rangeVsEmPct = not na(emLatched) and emLatched != 0 ? (sessionHigh - sessionLow) / emLatched * 100.0 : na
bool emFromPrimary = not na(emSymUsed) and emSymUsed == volSymbolPrimary
float volNowUsed = na(emSymUsed) ? na : emFromPrimary ? volClosePrimary : volCloseFallback
// Approximate EM left: vol now x sqrt(minutes left), over vol at the latch x sqrt(session minutes).
int minsLeftBar = sessEndMod - f_mod(time_close)
float emLeftPct = inSession and not na(emVolUsed) and emVolUsed > 0 and not na(volNowUsed) and minsLeftBar >= 0 ? volNowUsed * math.sqrt(minsLeftBar) / (emVolUsed * math.sqrt(sessEndDefault - sessStartMod)) * 100.0 : na

var line emLine0 = na
var line emLineP05 = na
var line emLineM05 = na
var line emLineP1 = na
var line emLineM1 = na
var label emLab0 = na
var label emLabP05 = na
var label emLabM05 = na
var label emLabP1 = na
var label emLabM1 = na

if newSession
    line.delete(emLine0)
    line.delete(emLineP05)
    line.delete(emLineM05)
    line.delete(emLineP1)
    line.delete(emLineM1)
    label.delete(emLab0)
    label.delete(emLabP05)
    label.delete(emLabM05)
    label.delete(emLabP1)
    label.delete(emLabM1)
    emLine0 := na
    emLineP05 := na
    emLineM05 := na
    emLineP1 := na
    emLineM1 := na
    emLab0 := na
    emLabP05 := na
    emLabM05 := na
    emLabP1 := na
    emLabM1 := na

if secEm and inSession and not na(emLatched) and not na(emBaseOpen)
    if na(emLine0)
        emLine0 := line.new(bar_index, emBaseOpen, bar_index, emBaseOpen, extend=extend.right, color=color.new(color.yellow, 0), width=2)
        emLineP05 := line.new(bar_index, emBaseOpen + emLatched * 0.5, bar_index, emBaseOpen + emLatched * 0.5, extend=extend.right, color=color.new(color.green, 0), width=1)
        emLineM05 := line.new(bar_index, emBaseOpen - emLatched * 0.5, bar_index, emBaseOpen - emLatched * 0.5, extend=extend.right, color=color.new(color.red, 0), width=1)
        emLineP1 := line.new(bar_index, emBaseOpen + emLatched, bar_index, emBaseOpen + emLatched, extend=extend.right, color=color.new(color.green, 0), width=2)
        emLineM1 := line.new(bar_index, emBaseOpen - emLatched, bar_index, emBaseOpen - emLatched, extend=extend.right, color=color.new(color.red, 0), width=2)
        emLab0 := label.new(bar_index, emBaseOpen, "Open " + f_fmt(emBaseOpen), style=label.style_label_left, textcolor=color.white, color=color.new(color.yellow, 70), yloc=yloc.price, tooltip="EM is latched once per session from the " + emSymUsed + " value printed at open + " + str.tostring(emLatchDelay) + " min (" + str.tostring(emVolUsed, "0.00") + ") and does not move intraday.")
        emLabP05 := label.new(bar_index, emBaseOpen + emLatched * 0.5, "+0.5 EM " + f_fmt(emBaseOpen + emLatched * 0.5), style=label.style_label_left, textcolor=color.white, color=color.new(color.green, 75), yloc=yloc.price)
        emLabM05 := label.new(bar_index, emBaseOpen - emLatched * 0.5, "-0.5 EM " + f_fmt(emBaseOpen - emLatched * 0.5), style=label.style_label_left, textcolor=color.white, color=color.new(color.red, 75), yloc=yloc.price)
        emLabP1 := label.new(bar_index, emBaseOpen + emLatched, "+1 EM " + f_fmt(emBaseOpen + emLatched), style=label.style_label_left, textcolor=color.white, color=color.new(color.green, 70), yloc=yloc.price)
        emLabM1 := label.new(bar_index, emBaseOpen - emLatched, "-1 EM " + f_fmt(emBaseOpen - emLatched), style=label.style_label_left, textcolor=color.white, color=color.new(color.red, 70), yloc=yloc.price)
    else
        for ln in array.from(emLine0, emLineP05, emLineM05, emLineP1, emLineM1)
            line.set_x2(ln, bar_index)
else if endSession
    for ln in array.from(emLine0, emLineP05, emLineM05, emLineP1, emLineM1)
        line.set_extend(ln, extend.none)

// ─────────────────────────────────────────────────────────────────────────────
// Fly Monitor 3: opening range (with N-point breakout threshold)
// ─────────────────────────────────────────────────────────────────────────────
string orSession = str.format("{0,number,00}{1,number,00}-{2,number,00}{3,number,00}", orStartHour, orStartMin, orEndHour, orEndMin)
bool inOR = inSession and not na(time(timeframe.period, orSession, tzInput))
bool newOR = inOR and (not inOR[1] or newDay)
bool endOR = not inOR and inOR[1]

var float orHigh = na
var float orLow = na
var bool orLocked = false
var string orState = "Inside"
var int reenterUpCount = 0
var int reenterDownCount = 0
var box orBox = na
var line orHighLine = na
var line orLowLine = na

if newSession
    orHigh := na
    orLow := na
    orLocked := false
    orState := "Inside"
    reenterUpCount := 0
    reenterDownCount := 0
    box.delete(orBox)
    line.delete(orHighLine)
    line.delete(orLowLine)
    orBox := na
    orHighLine := na
    orLowLine := na

if newOR
    orHigh := high
    orLow := low
    orLocked := false
    orState := "Inside"
    box.delete(orBox)
    line.delete(orHighLine)
    line.delete(orLowLine)
    orHighLine := na
    orLowLine := na
    orBox := secOr ? box.new(bar_index, high, bar_index, low, bgcolor=color.new(color.orange, 88), border_color=color.new(color.orange, 40)) : na

if inOR
    orHigh := na(orHigh) ? high : math.max(orHigh, high)
    orLow := na(orLow) ? low : math.min(orLow, low)
    if not na(orBox)
        box.set_right(orBox, bar_index)
        box.set_top(orBox, orHigh)
        box.set_bottom(orBox, orLow)

if endOR and not na(orHigh) and not na(orLow)
    orLocked := true
    if secOr and na(orHighLine)
        orHighLine := line.new(bar_index, orHigh, bar_index, orHigh, extend=extend.right, color=color.new(color.orange, 0), width=2)
        orLowLine := line.new(bar_index, orLow, bar_index, orLow, extend=extend.right, color=color.new(color.orange, 0), width=2)

if endSession and not na(orHighLine)
    line.set_extend(orHighLine, extend.none)
    line.set_extend(orLowLine, extend.none)
    line.set_x2(orHighLine, bar_index - 1)
    line.set_x2(orLowLine, bar_index - 1)

// ─────────────────────────────────────────────────────────────────────────────
// Fly Monitor 4: day type
// ─────────────────────────────────────────────────────────────────────────────
int erRollBars = f_minsToBars(erRollMinutes)
int holdBars = f_minsToBars(erTrendHoldMin)

// The first session bar uses close - open so the overnight gap is not counted as movement.
float stepMove = newSession ? math.abs(close - open) : math.abs(close - close[1])

var float erSumMove = 0.0
var float erSessionER = na
var float rollingER = na
var string dayType = "n/a"
var int consecAbove = 0
var int consecBelow = 0

if newSession
    erSumMove := 0.0
    erSessionER := na
    dayType := "n/a"
    consecAbove := 0
    consecBelow := 0
    rollingER := na

if inSession
    erSumMove += stepMove
    erSessionER := erSumMove != 0.0 and not na(sessionOpen) ? math.abs(close - sessionOpen) / erSumMove : na
    // Rolling ER never reaches back into the previous session; until the window is full it equals the session ER.
    if sessBars > erRollBars
        float rollDen = erSumMove - erSumMove[erRollBars]
        rollingER := rollDen != 0.0 ? math.abs(close - close[erRollBars]) / rollDen : na
    else
        rollingER := erSessionER

    bool above1 = not na(vwapVal) and not na(vwapStd) and close > vwapVal + band1Mult * vwapStd
    bool below1 = not na(vwapVal) and not na(vwapStd) and close < vwapVal - band1Mult * vwapStd
    consecAbove := above1 ? consecAbove + 1 : 0
    consecBelow := below1 ? consecBelow + 1 : 0

    if barstate.isconfirmed and not na(vwapVal) and not na(vwapStd) and not na(erSessionER)
        bool withinOneSD = math.abs(close - vwapVal) <= band1Mult * vwapStd
        bool belowPinER = erSessionER < erPinThresh
        bool rangeKnown = not na(rangeVsEmPct)
        bool isTrend = erSessionER > erTrendThresh and (consecAbove >= holdBars or consecBelow >= holdBars)
        bool isWhipsaw = not isTrend and rangeKnown and rangeVsEmPct >= erWhipsawThresh
        bool isWideChop = belowPinER and rangeKnown and rangeVsEmPct >= erWideChopThresh
        bool isPin = belowPinER and rangeKnown and rangeVsEmPct < erWideChopThresh and withinOneSD
        dayType := isTrend ? "TREND" : isWhipsaw ? "WHIPSAW" : isWideChop ? "WIDE CHOP" : isPin ? "PIN/RANGE" : "DRIFT"

if barstate.isconfirmed and inSession and orLocked and not na(orHigh) and not na(orLow)
    bool brokeUp = close >= orHigh + orBreakPts
    bool brokeDown = close <= orLow - orBreakPts
    bool backInside = close < orHigh and close > orLow
    if orState == "Inside"
        if brokeUp
            orState := "Broke Up"
        else if brokeDown
            orState := "Broke Down"
    else if orState == "Broke Up"
        if backInside
            reenterUpCount += 1
            orState := "Inside"
        else if brokeDown
            reenterUpCount += 1
            orState := "Broke Down"
    else if orState == "Broke Down"
        if backInside
            reenterDownCount += 1
            orState := "Inside"
        else if brokeUp
            reenterDownCount += 1
            orState := "Broke Up"

bool dayTypeTurnedTrend = dayType == "TREND" and dayType[1] != "TREND"
bool dayTypeTurnedWideChop = dayType == "WIDE CHOP" and dayType[1] != "WIDE CHOP"
bool dayTypeTurnedWhipsaw = dayType == "WHIPSAW" and dayType[1] != "WHIPSAW"
bool orBreakAlert = orState != orState[1] and (orState == "Broke Up" or orState == "Broke Down")
bool closeOutside2sd = barstate.isconfirmed and not na(band2Upper) and not na(band2Lower) and (close > band2Upper or close < band2Lower)
bool emUsedCross100 = barstate.isconfirmed and not na(emUsedPct) and not na(emUsedPct[1]) and emUsedPct[1] <= 100.0 and emUsedPct > 100.0
alertcondition(dayTypeTurnedTrend, title="Day type -> TREND", message="0DTE Fly Suite: day type changed to TREND")
alertcondition(dayTypeTurnedWideChop, title="Day type -> WIDE CHOP", message="0DTE Fly Suite: day type changed to WIDE CHOP")
alertcondition(dayTypeTurnedWhipsaw, title="Day type -> WHIPSAW", message="0DTE Fly Suite: day type changed to WHIPSAW (range past 150% of EM)")
alertcondition(orBreakAlert, title="Opening range break", message="0DTE Fly Suite: opening range break")
alertcondition(closeOutside2sd, title="Close outside 2 SD", message="0DTE Fly Suite: close outside +/-2 SD of VWAP")
alertcondition(emUsedCross100, title="EM used % crossed 100", message="0DTE Fly Suite: EM used % crossed 100")

color bgCol = na
if secFm and inSession
    if erShowBg and dayType == "TREND"
        bgCol := erColorTrend
    else if erShowBg and dayType == "WHIPSAW"
        bgCol := erColorWhipsaw
    else if erShowBg and dayType == "WIDE CHOP"
        bgCol := erColorWideChop
    else if erShowBg and dayType == "PIN/RANGE"
        bgCol := erColorPin
    else if erShowBg and dayType == "DRIFT"
        bgCol := erColorDrift
    else
        bgCol := color.new(color.green, 95)
bgcolor(bgCol, title="Day type")

// ─────────────────────────────────────────────────────────────────────────────
// Prior day, overnight and gap-fill lines; key strikes
// ─────────────────────────────────────────────────────────────────────────────
var array<line> lvlLines = array.new<line>()
var array<label> lvlLabels = array.new<label>()

f_level(array<line> ls, array<label> lbs, float y, string name, color c, string st) =>
    if not na(y)
        ls.push(line.new(bar_index, y, bar_index + 1, y, extend=extend.right, color=c, style=st, width=1))
        lbs.push(label.new(bar_index, y, name + " " + str.tostring(y, format.mintick), style=label.style_label_right, color=color(na), textcolor=c, size=size.small))
    true

if newSession
    for ln in lvlLines
        line.delete(ln)
    for lb in lvlLabels
        label.delete(lb)
    lvlLines.clear()
    lvlLabels.clear()
    if secLevels
        color lvlCol = color.new(color.silver, 20)
        f_level(lvlLines, lvlLabels, pdHigh, "PDH", lvlCol, line.style_dotted)
        f_level(lvlLines, lvlLabels, pdLow, "PDL", lvlCol, line.style_dotted)
        f_level(lvlLines, lvlLabels, pdClose, "PDC / gap fill", color.new(color.teal, 0), line.style_dotted)
        f_level(lvlLines, lvlLabels, onHigh, "ON high", color.new(color.gray, 10), line.style_dotted)
        f_level(lvlLines, lvlLabels, onLow, "ON low", color.new(color.gray, 10), line.style_dotted)
    if secKeys
        for raw in str.split(str.replace_all(keyTxt, ",", "\n"), "\n")
            float kpx = na
            string kname = ""
            for tk in str.split(raw, " ")
                if tk != ""
                    if na(kpx)
                        kpx := str.tonumber(tk)
                    else
                        kname := kname == "" ? tk : kname + " " + tk
            f_level(lvlLines, lvlLabels, kpx, kname == "" ? "Key" : kname, keyColor, line.style_solid)

if endSession
    for ln in lvlLines
        line.set_extend(ln, extend.none)
        line.set_x2(ln, bar_index - 1)

// ─────────────────────────────────────────────────────────────────────────────
// Bias block (context only). When the block is off, the chart's own symbol is requested
// instead, so a missing breadth feed can never break the script.
// ─────────────────────────────────────────────────────────────────────────────
int biasBars = f_minsToBars(biasMins)
float tickC = request.security(secBias ? tickSym : syminfo.tickerid, timeframe.period, close, lookahead=barmerge.lookahead_off)
float addC = request.security(secBias ? addSym : syminfo.tickerid, timeframe.period, close, lookahead=barmerge.lookahead_off)
float voldC = request.security(secBias ? voldSym : syminfo.tickerid, timeframe.period, close, lookahead=barmerge.lookahead_off)
float tickSm = ta.ema(tickC, biasBars)
float addChg = addC - addC[biasBars]
float voldChg = voldC - voldC[biasBars]
float vix1dChg = emFromPrimary and not na(emVolUsed) ? volClosePrimary - emVolUsed : na

int sTick = na(tickSm) ? 0 : tickSm >= tickTh ? 1 : tickSm <= -tickTh ? -1 : 0
// ADD and VOLD count when the level and its recent change point the same way.
int sAdd = na(addChg) ? 0 : addC > 0 and addChg > 0 ? 1 : addC < 0 and addChg < 0 ? -1 : 0
int sVold = na(voldChg) ? 0 : voldC > 0 and voldChg > 0 ? 1 : voldC < 0 and voldChg < 0 ? -1 : 0
int sVix = na(vix1dChg) ? 0 : vix1dChg <= -vixBiasPts ? 1 : vix1dChg >= vixBiasPts ? -1 : 0
int biasScore = sTick + sAdd + sVold + sVix

f_score(int s) =>
    s > 0 ? "Up" : s < 0 ? "Down" : "Neutral"

f_scoreCol(int s) =>
    s > 0 ? color.lime : s < 0 ? color.red : color.white

// ─────────────────────────────────────────────────────────────────────────────
// My Flies
// ─────────────────────────────────────────────────────────────────────────────
bool showLevels = styleInput != "Trade boxes"
bool showBoxes = styleInput != "Levels"
// Typed date "YYYY-MM-DD" -> 20261013, or na if it is not a date.
f_dateKey(string s) =>
    float n = str.tonumber(str.replace_all(str.trim(s), "-", ""))
    na(n) or n < 19000101 or n > 29991231 ? int(na) : int(n)
int typedDayKey = f_dateKey(flyDateTxt)
int flyDayKey = flyDateAuto or na(typedDayKey) ? dayKey(last_bar_time) : typedDayKey
bool isFlyDay = todayKey == flyDayKey

type Fly
    bool   enabled
    float  center
    float  credit
    string name
    float  wing
    color  col
    float  entryMin = na
    float  exitMin  = na
    float  pl       = 0.0
    bool   badTime  = false
    line   centerLine = na
    line   beUpLine   = na
    line   beDnLine   = na
    box    upBox      = na
    box    dnBox      = na
    label  tag        = na
    box    tradeBox   = na
    line   tradeMid   = na
    label  tradeTag   = na
    bool   tradeDone  = false

f_today(float mins) =>
    int t = na
    if not na(mins)
        t := f_tsToday(int(mins))
    t

method touchDist(Fly f) => landingNow ? math.max(f.credit - 3.0, 0.0) : f.credit * touchPct / 100.0
method touchUp(Fly f) => f.center + f.touchDist()
method touchDn(Fly f) => f.center - f.touchDist()
method beUp(Fly f) => f.center + f.credit
method beDn(Fly f) => f.center - f.credit

// Signed room: positive = points of cushion left, negative = points beyond the level.
method touchRoom(Fly f, float px) => f.touchDist() - math.abs(px - f.center)
method beRoom(Fly f, float px) => f.credit - math.abs(px - f.center)
method isHot(Fly f, float px) => showTouch ? f.touchRoom(px) < 0 : f.beRoom(px) < 0
// Dollars per contract: max loss, and the value at expiry if SPX settled at px.
method riskUsd(Fly f) => (f.wing - f.credit) * 100
method expiryPl(Fly f, float px) => (f.credit - math.min(math.abs(px - f.center), f.wing)) * 100
method entryTime(Fly f) => f_today(f.entryMin)
method exitTime(Fly f) => f_today(f.exitMin)

// Live = between entry and exit. No times entered = live all session.
// A P/L entered with no exit time also counts as closed.
method isLive(Fly f) =>
    // Only on the trade date set in the inputs.
    int eT = f.entryTime()
    int xT = f.exitTime()
    bool closedByPl = f.pl != 0 and na(xT)
    f.enabled and isFlyDay and not closedByPl and (na(eT) or time >= eT) and (na(xT) or time < xT)

method clearLevels(Fly f) =>
    line.delete(f.centerLine)
    line.delete(f.beUpLine)
    line.delete(f.beDnLine)
    box.delete(f.upBox)
    box.delete(f.dnBox)
    label.delete(f.tag)
    f.centerLine := na
    f.beUpLine := na
    f.beDnLine := na
    f.upBox := na
    f.dnBox := na
    f.tag := na

method clearDrawings(Fly f) =>
    f.clearLevels()
    box.delete(f.tradeBox)
    line.delete(f.tradeMid)
    label.delete(f.tradeTag)
    f.tradeBox := na
    f.tradeMid := na
    f.tradeTag := na
    f.tradeDone := false

// Level lines run from the entry (or the session open) to the exit; while the fly is open they
// also extend to the right edge.
method draw(Fly f, float px) =>
    color c  = f.isHot(px) ? color.red : f.col
    color bg = color.new(c, 85)
    int eT = f.entryTime()
    int xT = f.exitTime()
    int startT = na(eT) ? sessStartT : na(sessStartT) ? eT : math.max(eT, sessStartT)
    bool exited = not na(xT) and time >= xT
    int endT = exited ? xT : time
    string ext = exited ? extend.none : extend.right
    if na(f.centerLine)
        f.centerLine := line.new(startT, f.center, endT, f.center, xloc=xloc.bar_time, color=c, style=line.style_solid, width=lineWidth)
        f.beUpLine := line.new(startT, f.beUp(), endT, f.beUp(), xloc=xloc.bar_time, color=c, style=line.style_dashed, width=lineWidth)
        f.beDnLine := line.new(startT, f.beDn(), endT, f.beDn(), xloc=xloc.bar_time, color=c, style=line.style_dashed, width=lineWidth)
        if showTouch
            f.upBox := box.new(startT, f.beUp(), endT, f.touchUp(), xloc=xloc.bar_time, border_width=0, bgcolor=bg)
            f.dnBox := box.new(startT, f.touchDn(), endT, f.beDn(), xloc=xloc.bar_time, border_width=0, bgcolor=bg)
        if showTags
            f.tag := label.new(endT, f.center, f.name, xloc=xloc.bar_time, style=label.style_label_lower_left, color=color(na), textcolor=c, size=size.small)
    for l in array.from(f.centerLine, f.beUpLine, f.beDnLine)
        line.set_x1(l, startT)
        line.set_x2(l, endT)
        line.set_extend(l, ext)
        line.set_color(l, c)
    // The touch band follows the touch level (it moves at 15:55 with Iron Squadron).
    box.set_bottom(f.upBox, f.touchUp())
    box.set_top(f.dnBox, f.touchDn())
    for b in array.from(f.upBox, f.dnBox)
        box.set_left(b, startT)
        box.set_right(b, endT)
        box.set_extend(b, ext)
        box.set_bgcolor(b, bg)
    label.set_x(f.tag, exited ? xT : time + 2 * timeframe.in_seconds() * 1000)
    label.set_textcolor(f.tag, c)

method boxFill(Fly f, float px, bool closed) =>
    bool win = f.pl != 0 ? f.pl > 0 : closed ? f.beRoom(px) >= 0 : not f.isHot(px)
    color.new(win ? color.green : color.red, boxTransp)

method boxTagText(Fly f) =>
    f.pl != 0 ? f.name + " " + (f.pl > 0 ? "+" : "") + str.tostring(f.pl, "#") : f.name

// One box from entry to exit (or to the current bar while the fly is open); frozen once exited.
method drawBox(Fly f, float px) =>
    int eT = f.entryTime()
    if not na(eT) and time >= eT and not f.tradeDone
        int xT = f.exitTime()
        bool exited = not na(xT) and time >= xT
        int rightT = exited ? xT : time
        if na(f.tradeBox)
            f.tradeBox := box.new(eT, f.beUp(), rightT, f.beDn(), xloc=xloc.bar_time, border_color=f.col, border_width=1)
            f.tradeMid := line.new(eT, f.center, rightT, f.center, xloc=xloc.bar_time, color=f.col, style=line.style_dashed, width=1)
            if showTags
                f.tradeTag := label.new(eT, f.beUp(), f.boxTagText(), xloc=xloc.bar_time, style=label.style_label_lower_left, color=color(na), textcolor=f.col, size=size.small)
        box.set_right(f.tradeBox, rightT)
        line.set_x2(f.tradeMid, rightT)
        box.set_bgcolor(f.tradeBox, f.boxFill(px, exited))
        if exited
            f.tradeDone := true

var array<Fly> flies = array.from(
     Fly.new(slot1Enabled, slot1Center, slot1Credit, slot1Label, slot1Wing, #2962ff, f_parseHM(slot1Entry), f_parseHM(slot1Exit), slot1Pl, f_badTime(slot1Entry) or f_badTime(slot1Exit)),
     Fly.new(slot2Enabled, slot2Center, slot2Credit, slot2Label, slot2Wing, #ff9800, f_parseHM(slot2Entry), f_parseHM(slot2Exit), slot2Pl, f_badTime(slot2Entry) or f_badTime(slot2Exit)),
     Fly.new(slot3Enabled, slot3Center, slot3Credit, slot3Label, slot3Wing, #089981, f_parseHM(slot3Entry), f_parseHM(slot3Exit), slot3Pl, f_badTime(slot3Entry) or f_badTime(slot3Exit)),
     Fly.new(slot4Enabled, slot4Center, slot4Credit, slot4Label, slot4Wing, #9c27b0, f_parseHM(slot4Entry), f_parseHM(slot4Exit), slot4Pl, f_badTime(slot4Entry) or f_badTime(slot4Exit)),
     Fly.new(slot5Enabled, slot5Center, slot5Credit, slot5Label, slot5Wing, #00bcd4, f_parseHM(slot5Entry), f_parseHM(slot5Exit), slot5Pl, f_badTime(slot5Entry) or f_badTime(slot5Exit)),
     Fly.new(slot6Enabled, slot6Center, slot6Credit, slot6Label, slot6Wing, #e91e63, f_parseHM(slot6Entry), f_parseHM(slot6Exit), slot6Pl, f_badTime(slot6Entry) or f_badTime(slot6Exit)),
     Fly.new(slot7Enabled, slot7Center, slot7Credit, slot7Label, slot7Wing, #795548, f_parseHM(slot7Entry), f_parseHM(slot7Exit), slot7Pl, f_badTime(slot7Entry) or f_badTime(slot7Exit)),
     Fly.new(slot8Enabled, slot8Center, slot8Credit, slot8Label, slot8Wing, #3f51b5, f_parseHM(slot8Entry), f_parseHM(slot8Exit), slot8Pl, f_badTime(slot8Entry) or f_badTime(slot8Exit)),
     Fly.new(slot9Enabled, slot9Center, slot9Credit, slot9Label, slot9Wing, #8bc34a, f_parseHM(slot9Entry), f_parseHM(slot9Exit), slot9Pl, f_badTime(slot9Entry) or f_badTime(slot9Exit)),
     Fly.new(slot10Enabled, slot10Center, slot10Credit, slot10Label, slot10Wing, #607d8b, f_parseHM(slot10Entry), f_parseHM(slot10Exit), slot10Pl, f_badTime(slot10Entry) or f_badTime(slot10Exit)))

// A new session on the trade date starts clean. Any later session keeps the trade date's boxes
// but takes off its open-ended level lines, so nothing from an old date runs into today.
if (newSession and isFlyDay) or (not inSession and not keepAfterClose) or not secFlies
    for f in flies
        f.clearDrawings()
else if newSession
    for f in flies
        f.clearLevels()

if secFlies and inSession and isFlyDay
    for f in flies
        if f.enabled
            // With boxes on, a closed fly keeps only its box; its levels come off the chart.
            if showLevels and (f.isLive() or not showBoxes)
                f.draw(close)
            else
                f.clearLevels()
            if showBoxes
                f.drawBox(close)

// Alerts. With a TFT preset the breakeven alert fires as soon as price crosses (TFT exits intrabar
// on a tick past breakeven); otherwise it waits for the bar to close.
float prevClose = close[1]
string touchMsg = ""
string beMsg = ""
for f in flies
    if f.isLive()
        if showTouch
            if close > f.touchUp() and prevClose <= f.touchUp()
                touchMsg += f.name + " above upper touch " + f_fmt(f.touchUp()) + ". "
            if close < f.touchDn() and prevClose >= f.touchDn()
                touchMsg += f.name + " below lower touch " + f_fmt(f.touchDn()) + ". "
        if close > f.beUp() and prevClose <= f.beUp()
            beMsg += f.name + " above upper breakeven " + f_fmt(f.beUp()) + (isTFT ? " (TFT exit level)" : "") + ". "
        if close < f.beDn() and prevClose >= f.beDn()
            beMsg += f.name + " below lower breakeven " + f_fmt(f.beDn()) + (isTFT ? " (TFT exit level)" : "") + ". "

bool canAlert = secFlies and (inSession or not alertsInSessionOnly)
bool anyTouchCross = canAlert and touchMsg != ""
bool anyBreakevenCross = canAlert and beMsg != ""

alertcondition(anyTouchCross, title="My Flies: touch level crossed", message="0DTE Fly Suite: price crossed a fly touch level at {{close}}")
alertcondition(anyBreakevenCross, title="My Flies: breakeven crossed", message="0DTE Fly Suite: price crossed a fly breakeven at {{close}}")

if anyTouchCross
    alert("My Flies: " + touchMsg + "Price " + f_fmt(close), alert.freq_once_per_bar_close)
if anyBreakevenCross
    alert("My Flies: " + beMsg + "Price " + f_fmt(close), isTFT ? alert.freq_once_per_bar : alert.freq_once_per_bar_close)

// ─────────────────────────────────────────────────────────────────────────────
// Tables
// ─────────────────────────────────────────────────────────────────────────────
var table ctxTbl = table.new(f_pos(ctxPos), 2, 26, bgcolor=color.black, frame_color=color.new(color.gray, 70), frame_width=1, border_color=color.new(color.gray, 70), border_width=1)
var table fmTbl = table.new(f_pos(fmPos), 2, 16, bgcolor=color.new(color.black, 75), frame_color=color.new(color.gray, 70), frame_width=1)
var table flyTbl = table.new(f_pos(flyPos), 6, 12, bgcolor=color.new(color.black, 85), frame_color=color.new(color.gray, 80), frame_width=1, border_color=color.new(color.gray, 80), border_width=1)

if barstate.islast
    // ── Clock & context table
    table.clear(ctxTbl, 0, 0, 1, 25)
    if secClock or secPremkt or secBias or eventDay != "Normal"
        string sz = f_size(ctxSize)
        color headBg = color.new(color.gray, 85)
        table.cell(ctxTbl, 0, 0, "0DTE Fly Suite", text_color=color.white, text_size=sz, bgcolor=headBg, text_halign=text.align_left)
        table.cell(ctxTbl, 1, 0, botPreset, text_color=color.white, text_size=sz, bgcolor=headBg, text_halign=text.align_left)
        int r = 1
        if eventDay != "Normal"
            string evTxt = eventDay == "FOMC" ? "FOMC: TFT and IS skip today" : eventDay + ": IS skips, TFT trades"
            r := f_row(ctxTbl, r, "Event day", evTxt, color.orange, sz)
        if secClock
            r := f_row(ctxTbl, r, "VIX", f_fmt2(vixLast), color.white, sz)
            string vixChgTxt = na(vixDispChg) ? "n/a" : f_signed(vixDispChg) + " pts (" + f_signed(vixDispPct) + "%)"
            r := f_row(ctxTbl, r, "VIX chg (vs prior close)", vixChgTxt, vixAbove ? color.red : color.white, sz)
            string brkTxt = na(vixFromOpen) ? "n/a" : f_signed(vixFromOpen) + " pts (breaker +" + str.tostring(vixBreakPts, "#.#") + ")"
            if vixBreaker
                brkTxt := "BREAKER HIT: TFT closes all"
            r := f_row(ctxTbl, r, "VIX vs open", brkTxt, vixBreaker ? color.red : vixAbove ? color.orange : color.white, sz)
            if isTFT and not na(vixLast) and vixLast > vixMaxEntry
                r := f_row(ctxTbl, r, "VIX above " + str.tostring(vixMaxEntry, "#"), barMod < 810 ? "TFT first entry waits to 13:30" : "TFT entries allowed from 13:30", color.orange, sz)
            string shockTxt = vixBreaker ? "VIX breaker" : rapidMove and vixAbove ? "Rapid + VIX" : rapidMove ? "Rapid move" : vixAbove ? "VIX warning" : "None"
            if isIS and shockTxt != "None"
                shockTxt += " (IS has no breaker)"
            color shockCol = shockTxt == "None" ? color.white : vixBreaker or (rapidMove and vixAbove) ? color.red : color.orange
            r := f_row(ctxTbl, r, "Shock", shockTxt, shockCol, sz)
            bool rapidToday = not na(lastRapidTime) and dayKey(lastRapidTime) == todayKey
            string lastTxt = rapidToday ? f_clock(lastRapidTime) + "  " + f_signed(lastRapidPts) + " pts" : "None today"
            r := f_row(ctxTbl, r, "Last rapid", lastTxt, rapidToday ? (lastRapidPts >= 0 ? color.lime : color.red) : color.white, sz)
            int nextTs = na
            string nextName = ""
            if nClk > 0
                for i = 0 to nClk - 1
                    int m = clkMod.get(i)
                    int ts = f_tsToday(m)
                    if m < sessEndMod and ts > timenow and (na(nextTs) or ts < nextTs)
                        nextTs := ts
                        nextName := clkName.get(i)
            string nextTxt = na(nextTs) ? "Done for today" : nextName + " " + f_clock(nextTs) + " (in " + str.tostring(math.ceil((nextTs - timenow) / 60000.0)) + "m)"
            r := f_row(ctxTbl, r, "Next clock", nextTxt, color.white, sz)
            if sessEndMod != sessEndDefault
                r := f_row(ctxTbl, r, "Early close", f_hm(sessEndMod), color.orange, sz)
        if secPremkt
            float gapPts = not na(sessionOpen) and not na(pdClose) ? sessionOpen - pdClose : na
            float gapPctEm = not na(gapPts) and not na(emLatched) and emLatched > 0 ? gapPts / emLatched * 100.0 : na
            string gapTxt = na(gapPts) ? "n/a" : f_signed(gapPts) + (na(gapPctEm) ? "" : " (" + str.tostring(gapPctEm, "0") + "% EM)")
            r := f_row(ctxTbl, r, "Gap vs prior close", gapTxt, color.white, sz)
            float onRange = not na(onHigh) and not na(onLow) ? onHigh - onLow : na
            float onPctEm = not na(onRange) and not na(emLatched) and emLatched > 0 ? onRange / emLatched * 100.0 : na
            string onTxt = na(onRange) ? "n/a (no overnight bars)" : f_fmt(onRange) + (na(onPctEm) ? "" : " (" + str.tostring(onPctEm, "0") + "% EM)")
            r := f_row(ctxTbl, r, "Overnight range", onTxt, color.white, sz)
            string openTxt = na(onRange) or na(sessionOpen) ? "n/a" : sessionOpen > onHigh ? "above the ON high" : sessionOpen < onLow ? "below the ON low" : onRange > 0 ? str.tostring((sessionOpen - onLow) / onRange * 100.0, "0") + "% up the ON range" : "n/a"
            r := f_row(ctxTbl, r, "Open in ON range", openTxt, color.white, sz)
            float v1dRatio = emFromPrimary and not na(vixOpen) and vixOpen > 0 ? emVolUsed / vixOpen : na
            r := f_row(ctxTbl, r, "VIX1D / VIX at open", na(v1dRatio) ? "n/a" : str.tostring(emVolUsed, "0.00") + " / " + str.tostring(vixOpen, "0.00") + " = " + str.tostring(v1dRatio, "0.00"), na(v1dRatio) or v1dRatio < 1 ? color.white : color.orange, sz)
        if secBias
            r := f_row(ctxTbl, r, "TICK (" + str.tostring(biasMins) + "m avg)", na(tickSm) ? "n/a" : str.tostring(tickSm, "0") + "  " + f_score(sTick), f_scoreCol(sTick), sz)
            r := f_row(ctxTbl, r, "ADD (" + str.tostring(biasMins) + "m chg)", na(addC) ? "n/a" : str.tostring(addC, "0") + " (" + (addChg >= 0 ? "+" : "") + str.tostring(addChg, "0") + ")  " + f_score(sAdd), f_scoreCol(sAdd), sz)
            r := f_row(ctxTbl, r, "VOLD (" + str.tostring(biasMins) + "m chg)", na(voldC) ? "n/a" : str.tostring(voldC / 1e6, "0.0") + "M (" + (voldChg >= 0 ? "+" : "") + str.tostring(voldChg / 1e6, "0.0") + "M)  " + f_score(sVold), f_scoreCol(sVold), sz)
            r := f_row(ctxTbl, r, "VIX1D since open", na(vix1dChg) ? "n/a" : f_signed(vix1dChg) + "  " + f_score(sVix), f_scoreCol(sVix), sz)
            string biasTxt = (biasScore >= 2 ? "Up" : biasScore <= -2 ? "Down" : "Neutral") + " (" + (biasScore > 0 ? "+" : "") + str.tostring(biasScore) + " of 4)"
            r := f_row(ctxTbl, r, "Bias (context only)", biasTxt, biasScore >= 2 ? color.lime : biasScore <= -2 ? color.red : color.white, sz)

    // ── Fly Monitor table
    table.clear(fmTbl, 0, 0, 1, 15)
    if secFm
        string fsz = f_size(fmSize)
        // Close time from the session (or today's early close) on the date of the last bar.
        int sessCloseTs = f_tsToday(sessEndMod)
        bool sessionLive = inSession and timenow < sessCloseTs
        float minsToClose = sessionLive ? (sessCloseTs - timenow) / 60000.0 : na
        float priceVsVwapSigma = not na(vwapVal) and not na(vwapStd) and vwapStd != 0 ? (close - vwapVal) / vwapStd : na
        float swingFromExtreme = not na(sessionHigh) and not na(sessionLow) ? math.max(sessionHigh - close, close - sessionLow) : na
        color dtCol = dayType == "TREND" ? color.red : dayType == "WHIPSAW" ? color.fuchsia : dayType == "WIDE CHOP" ? color.purple : dayType == "PIN/RANGE" ? color.green : dayType == "DRIFT" ? color.orange : color.white
        int q = 0
        q := f_row(fmTbl, q, "Day type", dayType, dtCol, fsz)
        q := f_row(fmTbl, q, "VIX symbol", na(emSymUsed) ? volSymbolUsed + " (waiting)" : emSymUsed + " " + str.tostring(emVolUsed, "0.00"), color.white, fsz)
        q := f_row(fmTbl, q, "EM points", f_fmt(emLatched), color.white, fsz)
        q := f_row(fmTbl, q, "EM used %", f_pct(emUsedPct), color.white, fsz)
        q := f_row(fmTbl, q, "Range vs EM %", f_pct(rangeVsEmPct), not na(rangeVsEmPct) and rangeVsEmPct >= erWhipsawThresh ? color.fuchsia : color.white, fsz)
        q := f_row(fmTbl, q, "EM left (approx)", f_pct(emLeftPct), color.white, fsz)
        q := f_row(fmTbl, q, "Price vs VWAP σ", na(priceVsVwapSigma) ? "n/a" : (priceVsVwapSigma > 0 ? "+" : "") + str.tostring(priceVsVwapSigma, "#.##") + " σ", color.white, fsz)
        q := f_row(fmTbl, q, "OR state", orState, color.white, fsz)
        q := f_row(fmTbl, q, "Re-enter up/down", str.tostring(reenterUpCount) + " / " + str.tostring(reenterDownCount), color.white, fsz)
        q := f_row(fmTbl, q, "Session ER", na(erSessionER) ? "n/a" : str.tostring(erSessionER, "0.00"), color.white, fsz)
        q := f_row(fmTbl, q, "Rolling ER " + str.tostring(erRollMinutes) + "m", na(rollingER) ? "n/a" : str.tostring(rollingER, "0.00"), color.white, fsz)
        q := f_row(fmTbl, q, "Swing from extreme", f_fmt(swingFromExtreme), color.white, fsz)
        q := f_row(fmTbl, q, "Mins to close", na(minsToClose) ? "Closed" : str.tostring(math.floor(minsToClose)) + " min", color.white, fsz)
        q := f_row(fmTbl, q, "VWAP mode", vwapUseVolume ? "Volume proxy" : "HLC3 proxy", color.white, fsz)

    // ── My Flies table
    table.clear(flyTbl, 0, 0, 5, 11)
    if secFlies
        string txtSize = f_size(flySize)
        color headBg2 = color.new(color.gray, 80)
        color rowBg = color.new(color.black, 0)
        table.cell(flyTbl, 0, 0, "Fly", text_color=color.white, text_size=txtSize, bgcolor=headBg2)
        table.cell(flyTbl, 1, 0, "vs center", text_color=color.white, text_size=txtSize, bgcolor=headBg2, tooltip="Price minus center strike. Positive = price above center.")
        table.cell(flyTbl, 2, 0, showTouch ? "Touch room" : "-", text_color=color.white, text_size=txtSize, bgcolor=headBg2, tooltip="Points left before the nearer touch level. Negative = price is past it. Hidden with a TFT preset.")
        table.cell(flyTbl, 3, 0, "BE room", text_color=color.white, text_size=txtSize, bgcolor=headBg2, tooltip="Points left before the nearer breakeven. Negative = price is past it.")
        table.cell(flyTbl, 4, 0, "At expiry $", text_color=color.white, text_size=txtSize, bgcolor=headBg2, tooltip="P/L per contract if SPX settled at the current price. Not the live P/L.")
        table.cell(flyTbl, 5, 0, "Risk $", text_color=color.white, text_size=txtSize, bgcolor=headBg2, tooltip="Max loss per contract: (wing width - credit) x 100.")
        int row = 1
        bool anyOn = false
        for f in flies
            anyOn := anyOn or f.enabled
        if anyOn and not isFlyDay
            table.cell(flyTbl, 0, row, "Slots are dated " + str.format("{0,number,#}-{1,number,00}-{2,number,00}", math.floor(flyDayKey / 10000), math.floor(flyDayKey / 100) % 100, flyDayKey % 100) + ". Turn on 'Slots follow the latest trading day' or type today's date.", text_color=color.orange, text_size=txtSize, bgcolor=rowBg)
            table.merge_cells(flyTbl, 0, row, 5, row)
            row += 1
        for f in flies
            if f.enabled and isFlyDay
                float tRoom = f.touchRoom(close)
                float bRoom = f.beRoom(close)
                table.cell(flyTbl, 0, row, f.name, text_color=f.col, text_size=txtSize, bgcolor=rowBg)
                table.cell(flyTbl, 1, row, f_signed(close - f.center), text_color=color.white, text_size=txtSize, bgcolor=rowBg)
                if f.isLive()
                    table.cell(flyTbl, 2, row, showTouch ? f_signed(tRoom) : "", text_color=tRoom < 0 ? color.red : color.white, text_size=txtSize, bgcolor=rowBg)
                    table.cell(flyTbl, 3, row, f_signed(bRoom), text_color=bRoom < 0 ? color.red : color.white, text_size=txtSize, bgcolor=rowBg)
                    if f.wing > 0
                        float ePl = f.expiryPl(close)
                        table.cell(flyTbl, 4, row, (ePl >= 0 ? "+" : "") + str.tostring(ePl, "#"), text_color=ePl < 0 ? color.red : color.green, text_size=txtSize, bgcolor=rowBg)
                else
                    string st = not na(f.entryTime()) and time < f.entryTime() ? "not in yet" : "closed"
                    table.cell(flyTbl, 2, row, st, text_color=color.gray, text_size=txtSize, bgcolor=rowBg)
                    if f.pl != 0
                        table.cell(flyTbl, 3, row, f.boxTagText(), text_color=f.pl > 0 ? color.green : color.red, text_size=txtSize, bgcolor=rowBg)
                if f.badTime
                    table.cell(flyTbl, 2, row, "Entry/Exit must be a time, e.g. 10:35", text_color=color.orange, text_size=txtSize, bgcolor=rowBg)
                if f.wing > 0
                    table.cell(flyTbl, 5, row, str.tostring(f.riskUsd(), "#"), text_color=color.white, text_size=txtSize, bgcolor=rowBg)
                row += 1
        if row == 1
            table.cell(flyTbl, 0, 1, "No slots enabled", text_color=color.white, text_size=txtSize, bgcolor=rowBg)
````
