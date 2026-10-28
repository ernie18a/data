# OTE Sweep Signal + MTF Bias + VWAP + DR

- url: https://www.tradingview.com/script/PLPzu2NU-OTE-Sweep-Signal-MTF-Bias-VWAP-DR/
- type: indicator
- pine_id: PUB;a8d921ae5046491b9f3670032185b4cc
- version: 1.0

## Description

# OTE Sweep Signal + MTF Bias + VWAP + DR

## Overview

A comprehensive  intraday trading system that combines four core concepts into one indicator: **Dealing Range (DR) session boxes**, **Optimal Trade Entry (OTE) sweep signals**, **Multi-Timeframe (MTF) bias**, and **VWAP**. Designed for futures traders (NQ, MNQ, ES, MES) but works on any liquid intraday instrument.

The indicator automatically identifies when price sweeps liquidity above or below a prior HTF candle's high or low, pulls back into the 50–61.8% retracement zone (the OTE), and fires an entry signal — all filtered by session time, swing structure, range limits, VWAP, and a confirmed Dealing Range bias.

---

## How It Works

### 1. HTF Sweep Detection
On each new bar of your chosen Signal Timeframe (default 60m), the indicator locks in the prior candle's high and low as liquidity targets. If price sweeps above the prior high without taking the prior low (bull sweep), or below the prior low without taking the prior high (bear sweep), the sweep is locked in and the OTE zone is drawn.

### 2. OTE Zone
Once a sweep is detected, the indicator calculates the retracement zone between the 50% and your chosen OTE level (default 61.8%) of the swept candle's range. When price closes back inside this zone for the first time, an entry signal fires.

### 3. Entry, Stop, BE, and Target
- **Entry**: Top of OTE zone (bull) or bottom (bear)
- **Stop**: Prior candle high/low OR OTE zone buffer (selectable)
- **Break Even (BE)**: HTF candle open price
- **Target**: Prior candle H/L, next HTF swing H/L, or a fixed R:R multiplier

Each signal draws a label showing all four levels.

---

## Settings Groups

### Timeframe
- **Signal Timeframe** — The HTF used to identify sweeps and draw the OTE zone. Default 60m. Works on any intraday TF (5m, 15m, 30m, 60m, 240m).
- **Auto Sweep Window** — Automatically sets the window for valid sweeps to 1/3 of the signal TF duration. Turn off to set manually.
- **Sweep Window (minutes)** — Manual sweep window when Auto is off.

---

### OTE Zone
- **OTE Level (%)** — The deep retracement level that defines the bottom of the OTE zone. Default 61.8%. Range: 55–79%.
- **Show OTE Zone** — Toggle the shaded OTE box on/off.
- **Show Key Levels** — Toggle individual level lines (prior H/L, open, stop, target).

---

### Signals
- **Show Entry Arrows** — LONG/SHORT arrows plotted at the signal bar.
- **Show Stop & Target Label** — Detailed label with Entry, Stop, BE, and Target levels.
- **Stop Method** — *Prior Candle High/Low*: stop at the swept candle's opposite extreme. *OTE Zone Buffer*: stop just beyond the OTE deep level by a % of range.
- **OTE Stop Buffer** — Buffer percentage when using OTE Zone Buffer stop method.
- **Max Prior Candle Range (pts)** — Filters out signals where the swept candle's range is too large to produce a clean OTE setup. Default 100 pts.
- **Enable Max Range Filter** — Toggle the range filter on/off.
- **Target Method** — *Prior Candle H/L*: target the opposite extreme of the swept candle. *Next Swing H/L*: target the nearest HTF swing high/low beyond the sweep. *Fixed R:R*: target = entry ± (risk × multiplier).
- **Fixed R:R Multiplier** — Used only when Target Method is Fixed R:R. 2.0 = 2:1 reward to risk.

---

### Swing Filter
Filters out signals where price has swept through an intermediate HTF swing high or low between the prior candle extreme and the current bar. This prevents chasing signals that are actually breaking through multi-bar structure, not just taking a liquidity sweep.
- **Enable Swing Filter** — Toggle on/off.
- **Show Swing Levels** — Plots the four most recent HTF swing highs and lows as reference lines.
- **Show Blocked Signals** — Shows faded X arrows where a signal was detected but blocked by the swing filter or range filter.

---

### Session Filter
- **Enable Session Filter** — Only fire OTE signals during your defined trading hours.
- **Session Start Hour (ET)** — Default 9 (9 AM ET).
- **Session End Hour (ET)** — Default 16 (4 PM ET).

---

### Dealing Range (DR)
The Dealing Range (also called the Initial Balance) is the high/low established during each session's opening window. Three sessions are tracked independently.

**Session Times (all ET):**
| Session | Build Window | Extend Window |
|---|---|---|
| Asia | 7:00 PM – 8:00 PM | 8:00 PM – 2:00 AM |
| London | 3:00 AM – 4:00 AM | 4:00 AM – 8:30 AM |
| New York | 9:30 AM – 10:30 AM | 10:30 AM – 4:00 PM |

**Display options:**
- **Show Asia / London / New York DR** — Toggle each session independently.
- **DR Time / Extend** — Fully customizable session windows for each.
- **Show DR Box (build window only)** — Shaded box that spans only the DR build period. Updates live as price builds the range and freezes when the session ends.
- **Show DR High/Low Lines** — Horizontal lines at the DR high and low. Can extend into the session extend window.
- **Extend H/L Lines into session** — When on, H/L lines extend to the end of the session extend window.
- **Show DR Open Line** — Dashed line at the first price of the DR session.
- **Show 25 / 50 / 75% Levels** — Internal DR levels at 25%, 50%, and 75% of the DR range. Update live during the build window and freeze when the DR closes. Labeled at the right edge.
- **Extend % Lines into session** — When on, the 25/50/75% lines also extend into the extend window.
- **Show % Level Labels** — Small text labels at the right edge of each % line.
- **Line Width** — Width of all DR lines (1–4 px).

**Per-session colors:** Each session (Asia, London, NY) has three separate color pickers — Box fill, High/Low line, and % lines — so you can distinguish sessions at a glance.

**DR Open Line Color** — Shared color for the open line across all sessions.

**NY DR Break + Day Bias Filter:**
Once the NY DR build window closes (10:30 AM), the indicator watches for price to close outside the NY DR high or low. When confirmed, it locks in the day's directional bias and fires a labeled arrow on the chart.
- **Filter OTE by NY DR Break Direction** — When on, only takes OTE longs when day bias is BULL, only takes OTE shorts when day bias is BEAR.
- **Show DR Break Label on Chart** — Arrow label showing "BULL DR" or "BEAR DR" with timestamp at the confirmation bar.
- **Confirmation Closes Required** — Number of consecutive closes beyond the DR high/low needed to confirm (1–3). Default 1.
- **Enable Time Gate** — Prevents the DR bias filter from activating before a set time. Avoids pre-market fakeouts locking you into one direction all day. Default 10:30 AM ET.
- **Gate Hour / Gate Minute** — The time gate threshold.
- **Block All Signals Before Gate Time** — When on, no OTE signals fire at all until the gate time passes.
- **Break Bull / Bear Color** — Colors for the DR break label and bias display.

---

### VWAP
- **Show VWAP Line** — Plots the session VWAP. Color and width adjustable.
- **Enable VWAP Filter** — When on, only takes long OTE signals when price is above VWAP, and short signals when below. Defaults to OFF — use the Results Table to A/B test its effect.
- **Show VWAP Distance in Bias Table** — Adds a row to the MTF Bias Table showing how many points price is currently above or below VWAP.

---

### HTF Range Box
Draws a shaded box for every bar of your Signal Timeframe, spanning the full high-to-low range. The box updates live as the HTF candle builds and the color reflects the current candle's direction (green if close ≥ open, red if not). These boxes give immediate visual context for where the HTF candle is relative to its own range.
- **Show HTF Range Box** — Toggle on/off.
- **Bull / Bear Fill Color** — Box fill colors for bullish and bearish HTF candles.
- **Bull / Bear Border Color** — Border colors.
- **Border Width** — 0–4 px.
- **Extend Current Box Right** — When on, the active box projects one bar to the right.

---

### MTF Bias Table
A live bias dashboard showing whether each of your seven chosen timeframes is currently Bullish, Bearish, or Neutral — based on whether the current bar has broken above the prior bar's high or below the prior bar's low.

- **Show MTF Bias Table** — Toggle on/off.
- **TF 1–7** — Set any seven timeframes to monitor. Defaults: 1, 5, 15, 30, 60, 240, D.
- **Bias Table Position** — Top Right, Top Left, Bottom Right, Bottom Left.
- **Bias Table Size** — Tiny, Small, Normal, Large.
- **Show Bull/Bear Score Row** — Summary row showing count of bullish vs bearish TFs (e.g. "4B / 3S").
- **Show Accuracy (n / %)** — For each TF, tracks how often the bias signal correctly predicted the following bar's close direction. Shows percentage and sample count. Each TF accumulates at its own rate — a 1m TF will have far more samples than a Daily.
- **All color options** — Separate colors for bullish fill/text, bearish fill/text, neutral fill/text, header fill/text, score row fill/text.

The table also includes a **NY DR BIAS** row at the bottom showing the current day's confirmed Dealing Range direction and whether the filter is active.

---

### Colors
- **Bullish / Bearish Color** — Main signal colors used for OTE zone fills and entry arrows.
- **Zone Transparency %** — How transparent the OTE zone fill is (60–95%).

---

### Results Table (Table 1 — Summary)
A compact performance summary. Position is independently configurable.
- **Show Results Table** — Toggle on/off.
- **Summary Table Position** — Where to anchor Table 1 (settings + stats + P&L).
- **Table Size** — Tiny, Small, Normal, Large.
- **Timezone** — ET by default.
- **$ Per Point** — Set to 20 for NQ, 2 for MNQ, 50 for ES, 5 for MES.
- **Number of Contracts** — Scales all dollar P&L figures.

**Table 1 shows:**
- Active filter settings (stop method, swing filter, session, max range, target, VWAP, DR)
- Trades, Wins, Break Evens, Losses, Blocked signals, Win Rate
- Avg Win (pts + $), Avg Loss (pts + $), Total Won, Total Lost
- Net P&L (pts + $)

---

### Results Table (Table 2 — Hour/Slot Breakdown)
Separate table showing performance broken down by time slot. Works correctly for any signal timeframe — a 30m signal TF shows `9:30AM-10:00AM` style slots, not just hourly.
- **Hour Table Position** — Where to anchor Table 2. Default: Bottom Left (separate from Table 1).
- **Columns**: Time slot | W | BE | L | Net Pts

---

## Signal Logic Summary

A signal fires when ALL of the following are true:
1. Price swept the prior HTF candle's high (long) or low (short) within the sweep window
2. Price closed back inside the OTE zone for the first time
3. Within the session filter hours
4. Prior candle range did not exceed the max range filter
5. No intermediate HTF swing high/low was breached (swing filter)
6. VWAP filter passed (if enabled)
7. NY DR bias filter passed (if enabled and confirmed)
8. Past the time gate (if block-before-gate is enabled)

Signals blocked by filters 4–8 are shown as faded X arrows so you can visually audit what the filters are doing.

---

## Notes
- Works best on 1m and 5m charts with the Signal Timeframe set to 30m, 60m, or 240m.
- The indicator uses `max_bars_back=5000` to support longer lookback periods.
- DR boxes and lines use `xloc.bar_time` for precise timestamp-based placement.
- On chart timeframes below 5 minutes, a 5m security request is used for DR calculations to match the original DR/Initial Balance convention.
- All dollar P&L figures are estimates based on your $ Per Point and contract count settings — not a substitute for actual brokerage records.

## Source Code

````pine
//@version=6
indicator("OTE Sweep Signal + MTF Bias + VWAP + DR", overlay=true, max_bars_back=5000, max_lines_count=500, max_boxes_count=500, max_labels_count=500)

// ═══════════════════════════════════════════
//  INPUTS — TIMEFRAME
// ═══════════════════════════════════════════
var string G_TF = "Timeframe"
htfTF      = input.timeframe("60",  "Signal Timeframe",       group=G_TF)
autoWindow = input.bool(true,       "Auto Sweep Window",      group=G_TF)
sweepMin   = input.int(20,          "Sweep Window (minutes)", minval=1, maxval=240, group=G_TF)

// ═══════════════════════════════════════════
//  INPUTS — OTE ZONE
// ═══════════════════════════════════════════
var string G_OTE = "OTE Zone"
oteLevel = input.float(61.8, "OTE Level (%)",   minval=55.0, maxval=79.0, step=0.1, group=G_OTE)
showZone = input.bool(true,  "Show OTE Zone",   group=G_OTE)
showLvls = input.bool(true,  "Show Key Levels", group=G_OTE)

// ═══════════════════════════════════════════
//  INPUTS — SIGNALS
// ═══════════════════════════════════════════
var string G_SIG = "Signals"
showSig   = input.bool(true,  "Show Entry Arrows",            group=G_SIG)
showLbl   = input.bool(true,  "Show Stop & Target Label",     group=G_SIG)
stopMode  = input.string("Prior Candle High/Low", "Stop Method", options=["Prior Candle High/Low","OTE Zone Buffer"], group=G_SIG)
stopPct   = input.float(0.10, "OTE Stop Buffer (% of range)", minval=0.0, maxval=0.5, step=0.05, group=G_SIG)
maxRange  = input.float(100.0,"Max Prior Candle Range (pts)", minval=10.0, maxval=500.0, step=5.0, group=G_SIG)
useMaxRng = input.bool(true,  "Enable Max Range Filter",      group=G_SIG)
tgtMode   = input.string("Prior Candle H/L", "Target Method", options=["Prior Candle H/L","Next Swing H/L","Fixed R:R"], group=G_SIG)
rrMult    = input.float(2.0,  "Fixed R:R Multiplier", minval=0.5, maxval=10.0, step=0.5, group=G_SIG)

// ═══════════════════════════════════════════
//  INPUTS — SWING FILTER
// ═══════════════════════════════════════════
var string G_FLT = "Swing Filter"
useSwingFilter = input.bool(true, "Enable Swing Filter",  group=G_FLT)
showSwingLvls  = input.bool(true, "Show Swing Levels",    group=G_FLT)
showBlocked    = input.bool(true, "Show Blocked Signals", group=G_FLT)

// ═══════════════════════════════════════════
//  INPUTS — SESSION FILTER
// ═══════════════════════════════════════════
var string G_SES = "Session Filter"
useSession   = input.bool(true, "Enable Session Filter",   group=G_SES)
sessionStart = input.int(9,  "Session Start Hour (ET)", minval=0, maxval=23, group=G_SES)
sessionEnd   = input.int(16, "Session End Hour (ET)",   minval=0, maxval=23, group=G_SES)

// ═══════════════════════════════════════════
//  INPUTS — DR (DEALING RANGE)
// ═══════════════════════════════════════════
var string G_DR = "Dealing Range (DR)"
showAsia        = input.bool(true,  "Show Asia DR",                group=G_DR)
asiaTime        = input.session("1900-2000", "Asia DR Time",       group=G_DR, tooltip="7:00 PM - 8:00 PM ET")
asiaExtTime     = input.session("2000-0200", "Asia Extend",        group=G_DR)
showLondon      = input.bool(true,  "Show London DR",              group=G_DR)
londonTime      = input.session("0300-0400", "London DR Time",     group=G_DR, tooltip="3:00 AM - 4:00 AM ET")
londonExtTime   = input.session("0400-0830", "London Extend",      group=G_DR)
showNY          = input.bool(true,  "Show New York DR",            group=G_DR)
nyTime          = input.session("0930-1030", "NY DR Time",         group=G_DR, tooltip="9:30 AM - 10:30 AM ET")
nyExtTime       = input.session("1030-1600", "NY Extend",          group=G_DR)
drBoxShow       = input.bool(true,  "Show DR Box (build window only)", group=G_DR)
drLinesShow     = input.bool(true,  "Show DR High/Low Lines",      group=G_DR)
drExtendLines   = input.bool(true,  "Extend H/L Lines into session",group=G_DR)
drOpenShow      = input.bool(true,  "Show DR Open Line",           group=G_DR)
drPctShow       = input.bool(true,  "Show 25 / 50 / 75% Levels",  group=G_DR, tooltip="Internal DR levels. Update live as price builds the DR.")
drPctExtend     = input.bool(false, "Extend % Lines into session", group=G_DR, tooltip="When ON: 25/50/75% lines extend into the DR extend window alongside the H/L lines. When OFF: % lines stop at the end of the build window.")
drPctLabels     = input.bool(true,  "Show % Level Labels",         group=G_DR)
drLinesWidth    = input.int(1, "Line Width", minval=1, maxval=4,   group=G_DR)
// Colors
asiaBoxColor    = input.color(color.new(#9C27B0, 85), "Asia Box",         group=G_DR, inline="ac")
asiaLineColor   = input.color(color.new(#9C27B0,  0), "Line",             group=G_DR, inline="ac")
asiaPctColor    = input.color(color.new(#9C27B0, 30), "% Lines",          group=G_DR, inline="ac")
londonBoxColor  = input.color(color.new(#2196F3, 85), "London Box",       group=G_DR, inline="lc")
londonLineColor = input.color(color.new(#2196F3,  0), "Line",             group=G_DR, inline="lc")
londonPctColor  = input.color(color.new(#2196F3, 30), "% Lines",          group=G_DR, inline="lc")
nyBoxColor      = input.color(color.new(#FF9800, 85), "NY Box",           group=G_DR, inline="nc")
nyLineColor     = input.color(color.new(#FF9800,  0), "Line",             group=G_DR, inline="nc")
nyPctColor      = input.color(color.new(#FF9800, 30), "% Lines",          group=G_DR, inline="nc")
drOpenColor     = input.color(color.new(#FFD700,  0), "Open Line Color",  group=G_DR)
// DR Day Bias
useDrFilter     = input.bool(true,  "Filter OTE by NY DR Break Direction",group=G_DR)
showDrLabel     = input.bool(true,  "Show DR Break Label on Chart",        group=G_DR)
drConfirmBars   = input.int(1, "Confirmation Closes Required", minval=1, maxval=3, group=G_DR)
useTimeGate     = input.bool(true,  "Enable Time Gate",                    group=G_DR)
gateHour        = input.int(10, "Gate Hour (ET)",   minval=0, maxval=23,   group=G_DR)
gateMinute      = input.int(30, "Gate Minute",      minval=0, maxval=59,   group=G_DR)
blockBeforeGate = input.bool(false, "Block All Signals Before Gate Time",  group=G_DR)
drBullCol       = input.color(color.new(#00C853, 0), "Break Bull Color",  group=G_DR, inline="dc")
drBearCol       = input.color(color.new(#D50000, 0), "Break Bear Color",  group=G_DR, inline="dc")

// ═══════════════════════════════════════════
//  INPUTS — VWAP
// ═══════════════════════════════════════════
var string G_VW = "VWAP"
showVwap     = input.bool(true,  "Show VWAP Line",                               group=G_VW)
useVwap      = input.bool(false, "Enable VWAP Filter (bull above / bear below)", group=G_VW)
vwapCol      = input.color(color.new(#FF6F00, 0), "VWAP Color",                  group=G_VW)
vwapWidth    = input.int(1, "VWAP Width", minval=1, maxval=4,                    group=G_VW)
showVwapDist = input.bool(true, "Show VWAP Distance in Bias Table",              group=G_VW)

// ═══════════════════════════════════════════
//  INPUTS — HTF RANGE BOX
// ═══════════════════════════════════════════
var string G_BOX = "HTF Range Box"
showHtfBox     = input.bool(true,  "Show HTF Range Box",   group=G_BOX)
htfBoxBullFill = input.color(color.new(#00E676, 82), "Bull Fill Color",   group=G_BOX)
htfBoxBearFill = input.color(color.new(#FF1744, 82), "Bear Fill Color",   group=G_BOX)
htfBoxBullBord = input.color(color.new(#00E676, 30), "Bull Border Color", group=G_BOX)
htfBoxBearBord = input.color(color.new(#FF1744, 30), "Bear Border Color", group=G_BOX)
htfBoxBordW    = input.int(1, "Border Width (px)", minval=0, maxval=4,    group=G_BOX)
htfBoxExtend   = input.bool(false, "Extend Current Box Right",            group=G_BOX)

// ═══════════════════════════════════════════
//  INPUTS — MTF BIAS TABLE
// ═══════════════════════════════════════════
var string G_MTF = "MTF Bias Table"
showBias     = input.bool(true,  "Show MTF Bias Table", group=G_MTF)
biasTF1      = input.timeframe("1",   "TF 1", group=G_MTF)
biasTF2      = input.timeframe("5",   "TF 2", group=G_MTF)
biasTF3      = input.timeframe("15",  "TF 3", group=G_MTF)
biasTF4      = input.timeframe("30",  "TF 4", group=G_MTF)
biasTF5      = input.timeframe("60",  "TF 5", group=G_MTF)
biasTF6      = input.timeframe("240", "TF 6", group=G_MTF)
biasTF7      = input.timeframe("D",   "TF 7", group=G_MTF)
biasPos      = input.string("Top Left", "Bias Table Position", options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=G_MTF)
biasSize     = input.string("Small",    "Bias Table Size",     options=["Tiny","Small","Normal","Large"], group=G_MTF)
showScore    = input.bool(true, "Show Bull/Bear Score Row", group=G_MTF)
showAccuracy = input.bool(true, "Show Accuracy (n / %)",   group=G_MTF)
biasBullFill = input.color(color.new(#00C853, 0), "Bullish Fill",   group=G_MTF)
biasBearFill = input.color(color.new(#D50000, 0), "Bearish Fill",   group=G_MTF)
biasNeutFill = input.color(color.new(#455A64, 0), "Neutral Fill",   group=G_MTF)
biasHdrFill  = input.color(color.new(#1A237E, 0), "Header Fill",    group=G_MTF)
biasBullTxt  = input.color(color.new(#E8F5E9, 0), "Bullish Text",   group=G_MTF)
biasBearTxt  = input.color(color.new(#FFEBEE, 0), "Bearish Text",   group=G_MTF)
biasNeutTxt  = input.color(color.new(#ECEFF1, 0), "Neutral Text",   group=G_MTF)
biasHdrTxt   = input.color(color.new(#E8EAF6, 0), "Header Text",    group=G_MTF)
biasScoreFill= input.color(color.new(#263238, 0), "Score Row Fill", group=G_MTF)
biasScoreTxt = input.color(color.new(#CFD8DC, 0), "Score Row Text", group=G_MTF)

// ═══════════════════════════════════════════
//  INPUTS — OTE COLORS + RESULTS TABLE
// ═══════════════════════════════════════════
var string G_COL = "Colors"
bullCol = input.color(color.new(#00E676, 0), "Bullish Color", group=G_COL)
bearCol = input.color(color.new(#FF1744, 0), "Bearish Color", group=G_COL)
zAlpha  = input.int(85, "Zone Transparency %", minval=60, maxval=95, group=G_COL)

var string G_TBL = "Results Table"
showTable    = input.bool(true, "Show Results Table", group=G_TBL)
tablePos     = input.string("Bottom Right", "Summary Table Position",  options=["Top Right","Bottom Right","Top Left","Bottom Left"], group=G_TBL)
tablePos2    = input.string("Bottom Left",  "Hour Table Position",     options=["Top Right","Bottom Right","Top Left","Bottom Left"], group=G_TBL)
tableSize    = input.string("Small", "Table Size", options=["Tiny","Small","Normal","Large"], group=G_TBL)
tzSession    = input.string("America/New_York", "Timezone", group=G_TBL)
pointValue   = input.float(2.0, "$ Per Point (NQ=20, MNQ=2)", minval=1.0, step=1.0, group=G_TBL)
numContracts = input.int(1, "Number of Contracts", minval=1, maxval=100, group=G_TBL)

// ═══════════════════════════════════════════
//  ADAPTIVE THEME
// ═══════════════════════════════════════════
_br        = color.r(chart.bg_color)
_bg        = color.g(chart.bg_color)
_bb        = color.b(chart.bg_color)
isDark     = (_br * 299 + _bg * 587 + _bb * 114) / 1000 < 128
c_tblBg    = isDark ? color.new(#1a1a2e, 10) : color.new(#f0f2fa, 10)
c_headerBg = isDark ? color.new(#2a2a4e,  0) : color.new(#c8cde8,  0)
c_rowBgA   = isDark ? color.new(#1e1e3a,  0) : color.new(#ffffff,  0)
c_rowBgB   = isDark ? color.new(#222240,  0) : color.new(#eaecf5,  0)
c_border   = isDark ? color.new(#444466,  0) : color.new(#9999bb,  0)
c_title    = isDark ? color.new(#ffffff,  0) : color.new(#111133,  0)
c_label    = isDark ? color.new(#aaaacc,  0) : color.new(#44446a,  0)
c_gold     = isDark ? color.new(#FFD700,  0) : color.new(#b88a00,  0)
c_blue     = isDark ? color.new(#2196F3,  0) : color.new(#1565C0,  0)
c_grey     = isDark ? color.new(#888888,  0) : color.new(#666688,  0)
c_winTxt   = color.new(#00C853, 0)
c_lossTxt  = color.new(#D50000, 0)

// ═══════════════════════════════════════════
//  CONSTANTS + TIMING
// ═══════════════════════════════════════════
TIMEZONE     = "America/New_York"
tfMinutes    = timeframe.in_seconds(htfTF) / 60
autoWin      = math.max(1, math.round(tfMinutes / 3))
activeWin    = autoWindow ? autoWin : sweepMin
current_hour = hour(time, tzSession)
current_min  = minute(time, tzSession)
in_session   = not useSession or (current_hour >= sessionStart and current_hour < sessionEnd)

var bool use_m5 = false
if barstate.isfirst
    use_m5 := timeframe.in_seconds() < 300

[m5_open, m5_high, m5_low, m5_close] = request.security(syminfo.tickerid, "5",
     [open, high, low, close], lookahead=barmerge.lookahead_on)

ov = use_m5 ? m5_open  : open
hv = use_m5 ? m5_high  : high
lv = use_m5 ? m5_low   : low
cv = use_m5 ? m5_close : close

// ═══════════════════════════════════════════
//  SESSION HELPERS
// ═══════════════════════════════════════════
f_inSess(sess) => not na(time(timeframe.period, sess, TIMEZONE))

f_sessEndMS(sess) =>
    parts = str.split(sess, "-")
    en    = array.get(parts, 1)
    h     = int(str.tonumber(str.substring(en, 0, 2)))
    m     = int(str.tonumber(str.substring(en, 2, 4)))
    timestamp(TIMEZONE, year, month, dayofmonth, h, m)

// ═══════════════════════════════════════════
//  DR SESSION BOOLEANS
// ═══════════════════════════════════════════
inAsia      = f_inSess(asiaTime)    and showAsia
inAsiaExt   = f_inSess(asiaExtTime) and showAsia
inLondon    = f_inSess(londonTime)    and showLondon
inLondonExt = f_inSess(londonExtTime) and showLondon
inNY        = f_inSess(nyTime)    and showNY
inNYExt     = f_inSess(nyExtTime) and showNY

enterAsia   = inAsia   and not inAsia[1]
enterLondon = inLondon and not inLondon[1]
enterNY     = inNY     and not inNY[1]

leaveAsia   = not inAsia   and inAsia[1]
leaveLondon = not inLondon and inLondon[1]
leaveNY     = not inNY     and inNY[1]

// ═══════════════════════════════════════════
//  DR DRAWING HELPERS
// ═══════════════════════════════════════════
f_drLine(col) =>
    line.new(na, na, na, na, xloc=xloc.bar_time, color=col, style=line.style_solid, width=drLinesWidth)

f_drDashLine(col) =>
    line.new(na, na, na, na, xloc=xloc.bar_time, color=col, style=line.style_dashed, width=drLinesWidth)

f_drBox(col) =>
    box.new(na, na, na, na, xloc=xloc.bar_time, bgcolor=col, border_width=0)

f_setLine(ln, x1, y, x2) =>
    line.set_xy1(ln, x1, y)
    line.set_xy2(ln, x2, y)

f_setBox(bx, x1, top, x2, bot) =>
    box.set_lefttop(bx, x1, top)
    box.set_rightbottom(bx, x2, bot)

f_pctLabel(x, y, txt, col) =>
    label.new(x, y, txt,
         xloc      = xloc.bar_time,
         yloc      = yloc.price,
         style     = label.style_label_left,
         color     = color(na),
         textcolor = col,
         size      = size.small)

// ═══════════════════════════════════════════
//  DR STATE — Asia
// ═══════════════════════════════════════════
var int   asia_start  = na
var float asia_high   = na
var float asia_low    = na
var float asia_open   = na
var box   asia_box    = na
var line  asia_hline  = na
var line  asia_lline  = na
var line  asia_opline = na
var line  asia_l25    = na
var line  asia_l50    = na
var line  asia_l75    = na
var label asia_lbl25  = na
var label asia_lbl50  = na
var label asia_lbl75  = na

// ─── Asia build window ───────────────────
if timeframe.isintraday and inAsia
    if enterAsia
        asia_start  := time
        asia_open   := ov
        asia_high   := hv
        asia_low    := lv
        if drBoxShow
            asia_box    := f_drBox(asiaBoxColor)
        if drLinesShow
            asia_hline  := f_drLine(asiaLineColor)
            asia_lline  := f_drLine(asiaLineColor)
        if drOpenShow
            asia_opline := f_drDashLine(drOpenColor)
        if drPctShow
            asia_l25 := f_drDashLine(asiaPctColor)
            asia_l50 := f_drDashLine(asiaPctColor)
            asia_l75 := f_drDashLine(asiaPctColor)

    // Update range live as price builds DR
    asia_high := math.max(asia_high, hv)
    asia_low  := math.min(asia_low,  lv)

    float asia_rng = asia_high - asia_low
    float a25 = asia_low  + asia_rng * 0.25
    float a50 = asia_low  + asia_rng * 0.50
    float a75 = asia_low  + asia_rng * 0.75

    // Box — only during build window, right edge follows price
    if drBoxShow and not na(asia_box)
        f_setBox(asia_box, asia_start, asia_high, time, asia_low)

    // H/L lines — update during build
    if drLinesShow and not na(asia_hline)
        f_setLine(asia_hline,  asia_start, asia_high, time)
        f_setLine(asia_lline,  asia_start, asia_low,  time)

    if drOpenShow and not na(asia_opline)
        f_setLine(asia_opline, asia_start, asia_open, time)

    // % lines — live update during build only
    if drPctShow and not na(asia_l25)
        f_setLine(asia_l25, asia_start, a25, time)
        f_setLine(asia_l50, asia_start, a50, time)
        f_setLine(asia_l75, asia_start, a75, time)

// ─── Freeze box + % lines at end of Asia build window ───
if leaveAsia
    float asia_rng = asia_high - asia_low
    float a25 = asia_low  + asia_rng * 0.25
    float a50 = asia_low  + asia_rng * 0.50
    float a75 = asia_low  + asia_rng * 0.75
    int   endT = time
    if drBoxShow and not na(asia_box)
        f_setBox(asia_box, asia_start, asia_high, endT, asia_low)
    if drPctShow and not na(asia_l25)
        f_setLine(asia_l25, asia_start, a25, endT)
        f_setLine(asia_l50, asia_start, a50, endT)
        f_setLine(asia_l75, asia_start, a75, endT)
        if drPctLabels
            if not na(asia_lbl25)
                label.delete(asia_lbl25)
            if not na(asia_lbl50)
                label.delete(asia_lbl50)
            if not na(asia_lbl75)
                label.delete(asia_lbl75)
            asia_lbl25 := f_pctLabel(endT, a25, " 25%", asiaLineColor)
            asia_lbl50 := f_pctLabel(endT, a50, " 50%", asiaLineColor)
            asia_lbl75 := f_pctLabel(endT, a75, " 75%", asiaLineColor)

// ─── Extend H/L + open lines into Asia extend window ───
if timeframe.isintraday and drExtendLines and inAsiaExt and not inAsia
    int extEndT = f_sessEndMS(asiaExtTime)
    if drLinesShow and not na(asia_hline)
        f_setLine(asia_hline,  asia_start, asia_high, extEndT)
        f_setLine(asia_lline,  asia_start, asia_low,  extEndT)
    if drOpenShow and not na(asia_opline)
        f_setLine(asia_opline, asia_start, asia_open, extEndT)
    if drPctShow and drPctExtend and not na(asia_l25)
        float asia_rng = asia_high - asia_low
        f_setLine(asia_l25, asia_start, asia_low + asia_rng * 0.25, extEndT)
        f_setLine(asia_l50, asia_start, asia_low + asia_rng * 0.50, extEndT)
        f_setLine(asia_l75, asia_start, asia_low + asia_rng * 0.75, extEndT)

// ═══════════════════════════════════════════
//  DR STATE — London
// ═══════════════════════════════════════════
var int   lon_start   = na
var float lon_high    = na
var float lon_low     = na
var float lon_open    = na
var box   lon_box     = na
var line  lon_hline   = na
var line  lon_lline   = na
var line  lon_opline  = na
var line  lon_l25     = na
var line  lon_l50     = na
var line  lon_l75     = na
var label lon_lbl25   = na
var label lon_lbl50   = na
var label lon_lbl75   = na

if timeframe.isintraday and inLondon
    if enterLondon
        lon_start  := time
        lon_open   := ov
        lon_high   := hv
        lon_low    := lv
        if drBoxShow
            lon_box    := f_drBox(londonBoxColor)
        if drLinesShow
            lon_hline  := f_drLine(londonLineColor)
            lon_lline  := f_drLine(londonLineColor)
        if drOpenShow
            lon_opline := f_drDashLine(drOpenColor)
        if drPctShow
            lon_l25 := f_drDashLine(londonPctColor)
            lon_l50 := f_drDashLine(londonPctColor)
            lon_l75 := f_drDashLine(londonPctColor)

    lon_high := math.max(lon_high, hv)
    lon_low  := math.min(lon_low,  lv)

    float lon_rng = lon_high - lon_low
    float l25 = lon_low  + lon_rng * 0.25
    float l50 = lon_low  + lon_rng * 0.50
    float l75 = lon_low  + lon_rng * 0.75

    if drBoxShow and not na(lon_box)
        f_setBox(lon_box, lon_start, lon_high, time, lon_low)

    if drLinesShow and not na(lon_hline)
        f_setLine(lon_hline,  lon_start, lon_high, time)
        f_setLine(lon_lline,  lon_start, lon_low,  time)

    if drOpenShow and not na(lon_opline)
        f_setLine(lon_opline, lon_start, lon_open, time)

    if drPctShow and not na(lon_l25)
        f_setLine(lon_l25, lon_start, l25, time)
        f_setLine(lon_l50, lon_start, l50, time)
        f_setLine(lon_l75, lon_start, l75, time)

if leaveLondon
    float lon_rng = lon_high - lon_low
    float l25 = lon_low  + lon_rng * 0.25
    float l50 = lon_low  + lon_rng * 0.50
    float l75 = lon_low  + lon_rng * 0.75
    int   endT = time
    if drBoxShow and not na(lon_box)
        f_setBox(lon_box, lon_start, lon_high, endT, lon_low)
    if drPctShow and not na(lon_l25)
        f_setLine(lon_l25, lon_start, l25, endT)
        f_setLine(lon_l50, lon_start, l50, endT)
        f_setLine(lon_l75, lon_start, l75, endT)
        if drPctLabels
            if not na(lon_lbl25)
                label.delete(lon_lbl25)
            if not na(lon_lbl50)
                label.delete(lon_lbl50)
            if not na(lon_lbl75)
                label.delete(lon_lbl75)
            lon_lbl25 := f_pctLabel(endT, l25, " 25%", londonLineColor)
            lon_lbl50 := f_pctLabel(endT, l50, " 50%", londonLineColor)
            lon_lbl75 := f_pctLabel(endT, l75, " 75%", londonLineColor)

if timeframe.isintraday and drExtendLines and inLondonExt and not inLondon
    int extEndT = f_sessEndMS(londonExtTime)
    if drLinesShow and not na(lon_hline)
        f_setLine(lon_hline,  lon_start, lon_high, extEndT)
        f_setLine(lon_lline,  lon_start, lon_low,  extEndT)
    if drOpenShow and not na(lon_opline)
        f_setLine(lon_opline, lon_start, lon_open, extEndT)
    if drPctShow and drPctExtend and not na(lon_l25)
        float lon_rng = lon_high - lon_low
        f_setLine(lon_l25, lon_start, lon_low + lon_rng * 0.25, extEndT)
        f_setLine(lon_l50, lon_start, lon_low + lon_rng * 0.50, extEndT)
        f_setLine(lon_l75, lon_start, lon_low + lon_rng * 0.75, extEndT)

// ═══════════════════════════════════════════
//  DR STATE — New York
// ═══════════════════════════════════════════
var int   ny_start    = na
var float ny_high     = na
var float ny_low      = na
var float ny_open     = na
var box   ny_box      = na
var line  ny_hline    = na
var line  ny_lline    = na
var line  ny_opline   = na
var line  ny_l25      = na
var line  ny_l50      = na
var line  ny_l75      = na
var label ny_lbl25    = na
var label ny_lbl50    = na
var label ny_lbl75    = na

if timeframe.isintraday and inNY
    if enterNY
        ny_start  := time
        ny_open   := ov
        ny_high   := hv
        ny_low    := lv
        if drBoxShow
            ny_box    := f_drBox(nyBoxColor)
        if drLinesShow
            ny_hline  := f_drLine(nyLineColor)
            ny_lline  := f_drLine(nyLineColor)
        if drOpenShow
            ny_opline := f_drDashLine(drOpenColor)
        if drPctShow
            ny_l25 := f_drDashLine(nyPctColor)
            ny_l50 := f_drDashLine(nyPctColor)
            ny_l75 := f_drDashLine(nyPctColor)

    ny_high := math.max(ny_high, hv)
    ny_low  := math.min(ny_low,  lv)

    float ny_rng = ny_high - ny_low
    float n25 = ny_low  + ny_rng * 0.25
    float n50 = ny_low  + ny_rng * 0.50
    float n75 = ny_low  + ny_rng * 0.75

    if drBoxShow and not na(ny_box)
        f_setBox(ny_box, ny_start, ny_high, time, ny_low)

    if drLinesShow and not na(ny_hline)
        f_setLine(ny_hline,  ny_start, ny_high, time)
        f_setLine(ny_lline,  ny_start, ny_low,  time)

    if drOpenShow and not na(ny_opline)
        f_setLine(ny_opline, ny_start, ny_open, time)

    if drPctShow and not na(ny_l25)
        f_setLine(ny_l25, ny_start, n25, time)
        f_setLine(ny_l50, ny_start, n50, time)
        f_setLine(ny_l75, ny_start, n75, time)

// Lock NY DR levels + freeze box + % lines when NY session ends
var float ny_dr_high_lock = na
var float ny_dr_low_lock  = na

if leaveNY
    ny_dr_high_lock := ny_high
    ny_dr_low_lock  := ny_low
    float ny_rng = ny_high - ny_low
    float n25 = ny_low  + ny_rng * 0.25
    float n50 = ny_low  + ny_rng * 0.50
    float n75 = ny_low  + ny_rng * 0.75
    int   endT = time
    if drBoxShow and not na(ny_box)
        f_setBox(ny_box, ny_start, ny_high, endT, ny_low)
    if drPctShow and not na(ny_l25)
        f_setLine(ny_l25, ny_start, n25, endT)
        f_setLine(ny_l50, ny_start, n50, endT)
        f_setLine(ny_l75, ny_start, n75, endT)
        if drPctLabels
            if not na(ny_lbl25)
                label.delete(ny_lbl25)
            if not na(ny_lbl50)
                label.delete(ny_lbl50)
            if not na(ny_lbl75)
                label.delete(ny_lbl75)
            ny_lbl25 := f_pctLabel(endT, n25, " 25%", nyLineColor)
            ny_lbl50 := f_pctLabel(endT, n50, " 50%", nyLineColor)
            ny_lbl75 := f_pctLabel(endT, n75, " 75%", nyLineColor)

if timeframe.isintraday and drExtendLines and inNYExt and not inNY
    int extEndT = f_sessEndMS(nyExtTime)
    if drLinesShow and not na(ny_hline)
        f_setLine(ny_hline,  ny_start, ny_high, extEndT)
        f_setLine(ny_lline,  ny_start, ny_low,  extEndT)
    if drOpenShow and not na(ny_opline)
        f_setLine(ny_opline, ny_start, ny_open, extEndT)
    if drPctShow and drPctExtend and not na(ny_l25)
        float ny_rng = ny_high - ny_low
        f_setLine(ny_l25, ny_start, ny_low + ny_rng * 0.25, extEndT)
        f_setLine(ny_l50, ny_start, ny_low + ny_rng * 0.50, extEndT)
        f_setLine(ny_l75, ny_start, ny_low + ny_rng * 0.75, extEndT)

// ═══════════════════════════════════════════
//  NY DR BREAK + CONFIRMATION (day bias)
// ═══════════════════════════════════════════
is_new_day = ta.change(time("D")) != 0

var int   day_bias       = 0
var bool  bias_confirmed = false
var int   bull_cnt       = 0
var int   bear_cnt       = 0

if is_new_day
    day_bias       := 0
    bias_confirmed := false
    bull_cnt       := 0
    bear_cnt       := 0
    ny_dr_high_lock := na
    ny_dr_low_lock  := na

past_gate = not useTimeGate or current_hour > gateHour or (current_hour == gateHour and current_min >= gateMinute)

if not bias_confirmed and not na(ny_dr_high_lock) and not na(ny_dr_low_lock) and inNYExt
    if close > ny_dr_high_lock
        bull_cnt := bull_cnt + 1
        bear_cnt := 0
    else if close < ny_dr_low_lock
        bear_cnt := bear_cnt + 1
        bull_cnt := 0
    else
        bull_cnt := 0
        bear_cnt := 0
    if bull_cnt >= drConfirmBars
        day_bias       := 1
        bias_confirmed := true
    else if bear_cnt >= drConfirmBars
        day_bias       := -1
        bias_confirmed := true

bias_just_confirmed = bias_confirmed and not bias_confirmed[1]

if showDrLabel and bias_just_confirmed
    string db_txt  = day_bias == 1 ? "BULL DR" : "BEAR DR"
    color  db_col  = day_bias == 1 ? drBullCol : drBearCol
    string hh = str.tostring(current_hour < 12 ? (current_hour == 0 ? 12 : current_hour) : (current_hour == 12 ? 12 : current_hour - 12))
    string mm = (current_min < 10 ? "0" : "") + str.tostring(current_min)
    string ap = current_hour < 12 ? "AM" : "PM"
    // Offset the label by half the NY DR range so it clears the candles
    float  drOff = math.abs(ny_dr_high_lock - ny_dr_low_lock) * 0.5
    float  yPos  = day_bias == 1 ? low  - drOff : high + drOff
    string lStyle = day_bias == 1 ? label.style_label_up : label.style_label_down
    label.new(bar_index, yPos,
         db_txt + "\n" + hh + ":" + mm + ap,
         xloc=xloc.bar_index, yloc=yloc.price,
         color=db_col, textcolor=color.white,
         style=lStyle, size=size.normal)

db_active         = bias_confirmed and past_gate
day_bull_ok       = not useDrFilter or not db_active or day_bias == 1
day_bear_ok       = not useDrFilter or not db_active or day_bias == -1
before_gate_block = blockBeforeGate and not past_gate

// ═══════════════════════════════════════════
//  VWAP
// ═══════════════════════════════════════════
vwap_val   = ta.vwap(hlc3)
above_vwap = close > vwap_val
below_vwap = close < vwap_val
vwap_dist  = math.round(close - vwap_val, 1)

// ═══════════════════════════════════════════
//  MTF BIAS
// ═══════════════════════════════════════════
calcBias(tf) =>
    [ph, pl, ch, cl, co, cc] = request.security(syminfo.tickerid, tf,
         [high[1], low[1], high, low, open, close],
         barmerge.gaps_off, barmerge.lookahead_on)
    bh = ch > ph
    bl = cl < pl
    bh and not bl ? 1 : bl and not bh ? -1 : bh and bl ? (cc >= co ? 1 : -1) : 0

b1 = calcBias(biasTF1)
b2 = calcBias(biasTF2)
b3 = calcBias(biasTF3)
b4 = calcBias(biasTF4)
b5 = calcBias(biasTF5)
b6 = calcBias(biasTF6)
b7 = calcBias(biasTF7)

// ─── Accuracy: did bar N-2's break of bar N-3 predict bar N-1's direction? ───
// Uses lookahead_off so values are CONFIRMED bars only (no replication bug).
// New-bar detection is done at chart level via ta.change() on each TF's time.
calcAccuracy(tf) =>
    [sigH, sigL, sigBH, sigBL, nextO, nextC] = request.security(
         syminfo.tickerid, tf,
         [high[3], low[3], high[2], low[2], open[1], close[1]],
         barmerge.gaps_off, barmerge.lookahead_off)
    brokeH  = sigBH > sigH
    brokeL  = sigBL < sigL
    bdir    = brokeH and not brokeL ? 1 : brokeL and not brokeH ? -1 : 0
    nextDir = nextC >= nextO ? 1 : -1
    [bdir != 0, bdir != 0 and bdir == nextDir]

// Per-TF new-bar detection at chart level — avoids the lookahead_on replication
// bug that made every TF show the same n count
tfT1 = request.security(syminfo.tickerid, biasTF1, time, barmerge.gaps_off, barmerge.lookahead_off)
tfT2 = request.security(syminfo.tickerid, biasTF2, time, barmerge.gaps_off, barmerge.lookahead_off)
tfT3 = request.security(syminfo.tickerid, biasTF3, time, barmerge.gaps_off, barmerge.lookahead_off)
tfT4 = request.security(syminfo.tickerid, biasTF4, time, barmerge.gaps_off, barmerge.lookahead_off)
tfT5 = request.security(syminfo.tickerid, biasTF5, time, barmerge.gaps_off, barmerge.lookahead_off)
tfT6 = request.security(syminfo.tickerid, biasTF6, time, barmerge.gaps_off, barmerge.lookahead_off)
tfT7 = request.security(syminfo.tickerid, biasTF7, time, barmerge.gaps_off, barmerge.lookahead_off)
newBar1 = ta.change(tfT1) != 0
newBar2 = ta.change(tfT2) != 0
newBar3 = ta.change(tfT3) != 0
newBar4 = ta.change(tfT4) != 0
newBar5 = ta.change(tfT5) != 0
newBar6 = ta.change(tfT6) != 0
newBar7 = ta.change(tfT7) != 0

[a1d, a1h] = calcAccuracy(biasTF1)
[a2d, a2h] = calcAccuracy(biasTF2)
[a3d, a3h] = calcAccuracy(biasTF3)
[a4d, a4h] = calcAccuracy(biasTF4)
[a5d, a5h] = calcAccuracy(biasTF5)
[a6d, a6h] = calcAccuracy(biasTF6)
[a7d, a7h] = calcAccuracy(biasTF7)

var int acc1_n = 0
var int acc1_h = 0
var int acc2_n = 0
var int acc2_h = 0
var int acc3_n = 0
var int acc3_h = 0
var int acc4_n = 0
var int acc4_h = 0
var int acc5_n = 0
var int acc5_h = 0
var int acc6_n = 0
var int acc6_h = 0
var int acc7_n = 0
var int acc7_h = 0

if barstate.isconfirmed
    if newBar1 and a1d
        acc1_n += 1
        if a1h
            acc1_h += 1
    if newBar2 and a2d
        acc2_n += 1
        if a2h
            acc2_h += 1
    if newBar3 and a3d
        acc3_n += 1
        if a3h
            acc3_h += 1
    if newBar4 and a4d
        acc4_n += 1
        if a4h
            acc4_h += 1
    if newBar5 and a5d
        acc5_n += 1
        if a5h
            acc5_h += 1
    if newBar6 and a6d
        acc6_n += 1
        if a6h
            acc6_h += 1
    if newBar7 and a7d
        acc7_n += 1
        if a7h
            acc7_h += 1

// ═══════════════════════════════════════════
//  HTF DATA (OTE)
// ═══════════════════════════════════════════
[htf_t, htf_o, prev_h, prev_l] = request.security(
     syminfo.tickerid, htfTF,
     [time, open, high[1], low[1]],
     barmerge.gaps_off, barmerge.lookahead_on)

[htf_h, htf_l, htf_c] = request.security(
     syminfo.tickerid, htfTF,
     [high, low, close],
     barmerge.gaps_off, barmerge.lookahead_on)

[htf_sh2, htf_sh3, htf_sh4, htf_sh5] = request.security(
     syminfo.tickerid, htfTF,
     [high[2]>high[1] and high[2]>high[3] ? high[2] : na,
      high[3]>high[2] and high[3]>high[4] ? high[3] : na,
      high[4]>high[3] and high[4]>high[5] ? high[4] : na,
      high[5]>high[4] and high[5]>high[6] ? high[5] : na],
     barmerge.gaps_off, barmerge.lookahead_on)

[htf_sl2, htf_sl3, htf_sl4, htf_sl5] = request.security(
     syminfo.tickerid, htfTF,
     [low[2]<low[1] and low[2]<low[3] ? low[2] : na,
      low[3]<low[2] and low[3]<low[4] ? low[3] : na,
      low[4]<low[3] and low[4]<low[5] ? low[4] : na,
      low[5]<low[4] and low[5]<low[6] ? low[5] : na],
     barmerge.gaps_off, barmerge.lookahead_on)

// ═══════════════════════════════════════════
//  HTF TIMING + HTF RANGE BOX
// ═══════════════════════════════════════════
new_htf_bar  = ta.change(htf_t) > 0
elapsed_min  = (time - htf_t) / 60000.0
in_window    = elapsed_min <= activeWin

var box htf_box_active = na
htf_is_bull  = htf_c >= htf_o
htf_fillCol  = htf_is_bull ? htfBoxBullFill : htfBoxBearFill
htf_bordCol  = htf_is_bull ? htfBoxBullBord : htfBoxBearBord
htf_boxRight = htfBoxExtend ? bar_index + 1 : bar_index

if showHtfBox
    if new_htf_bar
        htf_box_active := box.new(
             left         = bar_index,
             top          = htf_h,
             right        = htf_boxRight,
             bottom       = htf_l,
             border_color = htf_bordCol,
             border_width = htfBoxBordW,
             bgcolor      = htf_fillCol)
    if not na(htf_box_active)
        box.set_right(htf_box_active,        htf_boxRight)
        box.set_top(htf_box_active,          htf_h)
        box.set_bottom(htf_box_active,       htf_l)
        box.set_bgcolor(htf_box_active,      htf_fillCol)
        box.set_border_color(htf_box_active, htf_bordCol)
        box.set_border_width(htf_box_active, htfBoxBordW)

// ═══════════════════════════════════════════
//  SWEEP DETECTION
// ═══════════════════════════════════════════
bull_sweep_raw = in_window and high > prev_h and not (low < prev_l)
bear_sweep_raw = in_window and low  < prev_l and not (high > prev_h)

// ═══════════════════════════════════════════
//  LOCKED STATE
// ═══════════════════════════════════════════
var bool  bull_locked       = false
var bool  bear_locked       = false
var bool  signal_fired      = false
var bool  lk_swing_h_breach = false
var bool  lk_swing_l_breach = false
var bool  lk_range_breach   = false
var float lk_prev_h         = na
var float lk_prev_l         = na
var float lk_htf_o          = na
var float lk_next_sh        = na
var float lk_next_sl        = na

if new_htf_bar and barstate.isconfirmed
    bull_locked       := false
    bear_locked       := false
    signal_fired      := false
    lk_swing_h_breach := false
    lk_swing_l_breach := false
    lk_range_breach   := false
    lk_prev_h         := na
    lk_prev_l         := na
    lk_htf_o          := na
    lk_next_sh        := na
    lk_next_sl        := na

nextSwingHigh(float lvl) =>
    float r = na
    if not na(htf_sh2) and htf_sh2 > lvl
        r := htf_sh2
    if not na(htf_sh3) and htf_sh3 > lvl and (na(r) or htf_sh3 < r)
        r := htf_sh3
    if not na(htf_sh4) and htf_sh4 > lvl and (na(r) or htf_sh4 < r)
        r := htf_sh4
    if not na(htf_sh5) and htf_sh5 > lvl and (na(r) or htf_sh5 < r)
        r := htf_sh5
    r

nextSwingLow(float lvl) =>
    float r = na
    if not na(htf_sl2) and htf_sl2 < lvl
        r := htf_sl2
    if not na(htf_sl3) and htf_sl3 < lvl and (na(r) or htf_sl3 > r)
        r := htf_sl3
    if not na(htf_sl4) and htf_sl4 < lvl and (na(r) or htf_sl4 > r)
        r := htf_sl4
    if not na(htf_sl5) and htf_sl5 < lvl and (na(r) or htf_sl5 > r)
        r := htf_sl5
    r

if bull_sweep_raw and not bull_locked and not signal_fired
    bull_locked       := true
    bear_locked       := false
    lk_prev_h         := prev_h
    lk_prev_l         := prev_l
    lk_htf_o          := htf_o
    lk_next_sh        := nextSwingHigh(high)
    lk_next_sl        := na
    lk_range_breach   := useMaxRng and (prev_h - prev_l) > maxRange
    lk_swing_l_breach := false
    lk_swing_h_breach := not lk_range_breach and useSwingFilter and (
         (not na(htf_sh2) and high > htf_sh2 and htf_sh2 > prev_h and htf_sh2 != prev_h) or
         (not na(htf_sh3) and high > htf_sh3 and htf_sh3 > prev_h and htf_sh3 != prev_h) or
         (not na(htf_sh4) and high > htf_sh4 and htf_sh4 > prev_h and htf_sh4 != prev_h) or
         (not na(htf_sh5) and high > htf_sh5 and htf_sh5 > prev_h and htf_sh5 != prev_h))

if bear_sweep_raw and not bear_locked and not signal_fired
    bear_locked       := true
    bull_locked       := false
    lk_prev_h         := prev_h
    lk_prev_l         := prev_l
    lk_htf_o          := htf_o
    lk_next_sl        := nextSwingLow(low)
    lk_next_sh        := na
    lk_range_breach   := useMaxRng and (prev_h - prev_l) > maxRange
    lk_swing_h_breach := false
    lk_swing_l_breach := not lk_range_breach and useSwingFilter and (
         (not na(htf_sl2) and low < htf_sl2 and htf_sl2 < prev_l and htf_sl2 != prev_l) or
         (not na(htf_sl3) and low < htf_sl3 and htf_sl3 < prev_l and htf_sl3 != prev_l) or
         (not na(htf_sl4) and low < htf_sl4 and htf_sl4 < prev_l and htf_sl4 != prev_l) or
         (not na(htf_sl5) and low < htf_sl5 and htf_sl5 < prev_l and htf_sl5 != prev_l))

// ═══════════════════════════════════════════
//  OTE ZONE LEVELS
// ═══════════════════════════════════════════
float prev_rng  = not na(lk_prev_h) and not na(lk_prev_l) ? lk_prev_h - lk_prev_l : na
float bull_z_hi = not na(prev_rng) and bull_locked ? lk_prev_h - prev_rng * 0.500            : na
float bull_z_lo = not na(prev_rng) and bull_locked ? lk_prev_h - prev_rng * (oteLevel/100.0) : na
float bear_z_lo = not na(prev_rng) and bear_locked ? lk_prev_l + prev_rng * 0.500            : na
float bear_z_hi = not na(prev_rng) and bear_locked ? lk_prev_l + prev_rng * (oteLevel/100.0) : na

bull_active = bull_locked and not signal_fired
bear_active = bear_locked and not signal_fired

// ═══════════════════════════════════════════
//  SIGNAL CONDITIONS
// ═══════════════════════════════════════════
bull_in_ote  = bull_active and not na(bull_z_hi) and low  <= bull_z_hi and close >= bull_z_lo
bear_in_ote  = bear_active and not na(bear_z_hi) and high >= bear_z_lo and close <= bear_z_hi
bull_entry   = bull_in_ote and not bull_in_ote[1] and in_session
bear_entry   = bear_in_ote and not bear_in_ote[1] and in_session

vwap_bull_ok = not useVwap or above_vwap
vwap_bear_ok = not useVwap or below_vwap

bull_sig     = bull_entry and not lk_swing_h_breach and not lk_range_breach and vwap_bull_ok and day_bull_ok and not before_gate_block
bear_sig     = bear_entry and not lk_swing_l_breach and not lk_range_breach and vwap_bear_ok and day_bear_ok and not before_gate_block
bull_blocked = bull_entry and not bull_sig
bear_blocked = bear_entry and not bear_sig

if bull_sig or bear_sig or bull_blocked or bear_blocked
    signal_fired := true

// ═══════════════════════════════════════════
//  STOP / TARGET
// ═══════════════════════════════════════════
usePriorStop        = stopMode == "Prior Candle High/Low"
float bull_stop_lvl = usePriorStop ? lk_prev_l : not na(prev_rng) ? bull_z_lo - prev_rng * stopPct : na
float bear_stop_lvl = usePriorStop ? lk_prev_h : not na(prev_rng) ? bear_z_hi + prev_rng * stopPct : na

calcBullTgt(float ep, float sp) =>
    float r = na
    if tgtMode == "Prior Candle H/L"
        r := lk_prev_h
    else if tgtMode == "Next Swing H/L"
        r := not na(lk_next_sh) ? lk_next_sh : lk_prev_h
    else
        r := ep + (ep - sp) * rrMult
    r

calcBearTgt(float ep, float sp) =>
    float r = na
    if tgtMode == "Prior Candle H/L"
        r := lk_prev_l
    else if tgtMode == "Next Swing H/L"
        r := not na(lk_next_sl) ? lk_next_sl : lk_prev_l
    else
        r := ep - (sp - ep) * rrMult
    r

// ═══════════════════════════════════════════
//  TRADE TRACKING
// ═══════════════════════════════════════════
var int   total_trades   = 0
var int   total_wins     = 0
var int   total_be       = 0
var int   total_losses   = 0
var int   total_blocked  = 0
var float total_pts_won  = 0.0
var float total_pts_lost = 0.0
var bool  in_trade       = false
var bool  is_long        = false
var bool  be_reached     = false
var bool  entry_bar      = false
var float trade_entry    = na
var float trade_stop     = na
var float trade_be       = na
var float trade_target   = na
var int   trade_slot     = na   // slot index = (hour*60 + minute) / tfMin

// Slot resolution: sized for 15m and above (96 slots = 24h / 15m)
// Sub-15m HTF is unusual -- slots cap gracefully at index 95
int    tfMin       = math.max(1, math.round(tfMinutes))
int    maxSlots    = 96
var array<int>   hour_wins   = array.new_int(maxSlots, 0)
var array<int>   hour_be     = array.new_int(maxSlots, 0)
var array<int>   hour_losses = array.new_int(maxSlots, 0)
var array<float> hour_pts    = array.new_float(maxSlots, 0.0)

if bull_blocked or bear_blocked
    total_blocked += 1

if bull_sig and not na(bull_stop_lvl) and not na(lk_htf_o) and not na(bull_z_hi)
    float en     = bull_z_hi
    float st     = bull_stop_lvl
    in_trade    := true
    is_long     := true
    be_reached  := false
    entry_bar   := true
    trade_entry := en
    trade_stop  := st
    trade_be    := lk_htf_o
    trade_target:= calcBullTgt(en, st)
    trade_slot  := math.min(maxSlots - 1, int(math.floor((hour(htf_t, tzSession) * 60 + minute(htf_t, tzSession)) / tfMin)))

if bear_sig and not na(bear_stop_lvl) and not na(lk_htf_o) and not na(bear_z_lo)
    float en     = bear_z_lo
    float st     = bear_stop_lvl
    in_trade    := true
    is_long     := false
    be_reached  := false
    entry_bar   := true
    trade_entry := en
    trade_stop  := st
    trade_be    := lk_htf_o
    trade_target:= calcBearTgt(en, st)
    trade_slot  := math.min(maxSlots - 1, int(math.floor((hour(htf_t, tzSession) * 60 + minute(htf_t, tzSession)) / tfMin)))

if entry_bar and not (bull_sig or bear_sig)
    entry_bar := false

if in_trade and not na(trade_slot) and not entry_bar
    if is_long
        if not be_reached and high >= trade_be
            be_reached := true
        if high >= trade_target
            float pts  = trade_target - trade_entry
            total_trades  += 1
            total_wins    += 1
            total_pts_won += pts
            array.set(hour_wins, trade_slot, array.get(hour_wins, trade_slot) + 1)
            array.set(hour_pts,  trade_slot, array.get(hour_pts,  trade_slot) + pts)
            in_trade := false
        else if low <= trade_stop
            total_trades += 1
            if be_reached
                total_be += 1
                array.set(hour_be, trade_slot, array.get(hour_be, trade_slot) + 1)
            else
                float pts      = trade_entry - trade_stop
                total_losses   += 1
                total_pts_lost += pts
                array.set(hour_losses, trade_slot, array.get(hour_losses, trade_slot) + 1)
                array.set(hour_pts,    trade_slot, array.get(hour_pts,    trade_slot) - pts)
            in_trade := false
    else
        if not be_reached and low <= trade_be
            be_reached := true
        if low <= trade_target
            float pts  = trade_entry - trade_target
            total_trades  += 1
            total_wins    += 1
            total_pts_won += pts
            array.set(hour_wins, trade_slot, array.get(hour_wins, trade_slot) + 1)
            array.set(hour_pts,  trade_slot, array.get(hour_pts,  trade_slot) + pts)
            in_trade := false
        else if high >= trade_stop
            total_trades += 1
            if be_reached
                total_be += 1
                array.set(hour_be, trade_slot, array.get(hour_be, trade_slot) + 1)
            else
                float pts      = trade_stop - trade_entry
                total_losses   += 1
                total_pts_lost += pts
                array.set(hour_losses, trade_slot, array.get(hour_losses, trade_slot) + 1)
                array.set(hour_pts,    trade_slot, array.get(hour_pts,    trade_slot) - pts)
            in_trade := false

float win_rate    = total_trades > 0 ? math.round((total_wins  / total_trades) * 100, 1) : 0.0
float avg_win_pts = total_wins   > 0 ? math.round(total_pts_won  / total_wins,   1) : 0.0
float avg_los_pts = total_losses > 0 ? math.round(total_pts_lost / total_losses, 1) : 0.0
float net_pts     = math.round(total_pts_won - total_pts_lost, 1)
float net_dollars = math.round(net_pts * pointValue * numContracts, 0)

// ═══════════════════════════════════════════
//  HOUR ROWS
// ═══════════════════════════════════════════
var array<int>   active_hours  = array.new_int(0)
var array<int>   active_wins   = array.new_int(0)
var array<int>   active_be     = array.new_int(0)
var array<int>   active_losses = array.new_int(0)
var array<float> active_pts    = array.new_float(0)

if barstate.islast
    array.clear(active_hours)
    array.clear(active_wins)
    array.clear(active_be)
    array.clear(active_losses)
    array.clear(active_pts)
    for s = 0 to maxSlots - 1
        int   w  = array.get(hour_wins,   s)
        int   b  = array.get(hour_be,     s)
        int   l  = array.get(hour_losses, s)
        float pt = array.get(hour_pts,    s)
        if w + b + l > 0
            array.push(active_hours,  s)
            array.push(active_wins,   w)
            array.push(active_be,     b)
            array.push(active_losses, l)
            array.push(active_pts,    math.round(pt, 1))

// ═══════════════════════════════════════════
//  MTF BIAS TABLE
// ═══════════════════════════════════════════
var table bias_tbl = na
string bPos = biasPos == "Top Right" ? position.top_right : biasPos == "Bottom Right" ? position.bottom_right : biasPos == "Top Left" ? position.top_left : position.bottom_left
string bSz  = biasSize == "Tiny" ? size.tiny : biasSize == "Normal" ? size.normal : biasSize == "Large" ? size.large : size.small

if showBias and barstate.islast
    int extraRows = (showScore ? 1 : 0) + (showVwapDist ? 1 : 0) + 1
    int cols      = showAccuracy ? 3 : 2
    int rows      = 9 + extraRows

    if not na(bias_tbl)
        table.delete(bias_tbl)

    bias_tbl := table.new(bPos, cols, rows,
         bgcolor=c_tblBg, border_color=c_border, border_width=1, frame_color=c_border, frame_width=1)

    table.cell(bias_tbl, 0, 0, "TIMEFRAME", text_color=biasHdrTxt, bgcolor=biasHdrFill, text_size=bSz)
    table.cell(bias_tbl, 1, 0, "BIAS",      text_color=biasHdrTxt, bgcolor=biasHdrFill, text_size=bSz)
    if showAccuracy
        table.cell(bias_tbl, 2, 0, "ACCURACY", text_color=biasHdrTxt, bgcolor=biasHdrFill, text_size=bSz)

    string[] tfNames = array.from(biasTF1, biasTF2, biasTF3, biasTF4, biasTF5, biasTF6, biasTF7)
    int[]    bVals   = array.from(b1, b2, b3, b4, b5, b6, b7)
    int[]    aNs     = array.from(acc1_n, acc2_n, acc3_n, acc4_n, acc5_n, acc6_n, acc7_n)
    int[]    aHs     = array.from(acc1_h, acc2_h, acc3_h, acc4_h, acc5_h, acc6_h, acc7_h)

    for i = 0 to 6
        int    row   = i + 1
        int    bv    = array.get(bVals, i)
        int    an    = array.get(aNs,   i)
        int    ah    = array.get(aHs,   i)
        color  rowBg = i % 2 == 0 ? c_rowBgA : c_rowBgB
        string bLbl  = bv ==  1 ? "UP  BULL" : bv == -1 ? "DN  BEAR" : "-- NEUT"
        color  bBg   = bv ==  1 ? biasBullFill : bv == -1 ? biasBearFill : biasNeutFill
        color  bTx   = bv ==  1 ? biasBullTxt  : bv == -1 ? biasBearTxt  : biasNeutTxt
        float  aPct  = an > 0 ? math.round((ah / an) * 100.0, 1) : 0.0
        string aStr  = an > 0 ? str.tostring(aPct) + "% n=" + str.tostring(an) : "n/a"
        color  aCol  = an > 0 and aPct >= 50.0 ? c_winTxt : an > 0 ? c_lossTxt : c_grey
        table.cell(bias_tbl, 0, row, array.get(tfNames, i), text_color=c_label, bgcolor=rowBg, text_size=bSz)
        table.cell(bias_tbl, 1, row, bLbl, text_color=bTx, bgcolor=bBg, text_size=bSz)
        if showAccuracy
            table.cell(bias_tbl, 2, row, aStr, text_color=aCol, bgcolor=rowBg, text_size=bSz)

    if showScore
        int   bulls = (b1==1?1:0)+(b2==1?1:0)+(b3==1?1:0)+(b4==1?1:0)+(b5==1?1:0)+(b6==1?1:0)+(b7==1?1:0)
        int   bears = (b1==-1?1:0)+(b2==-1?1:0)+(b3==-1?1:0)+(b4==-1?1:0)+(b5==-1?1:0)+(b6==-1?1:0)+(b7==-1?1:0)
        color scBg  = bulls > bears ? color.new(#1B5E20, 0) : bears > bulls ? color.new(#7B1414, 0) : biasScoreFill
        table.cell(bias_tbl, 0, 8, "SCORE", text_color=biasScoreTxt, bgcolor=biasScoreFill, text_size=bSz)
        table.cell(bias_tbl, 1, 8, str.tostring(bulls) + "B / " + str.tostring(bears) + "S", text_color=biasScoreTxt, bgcolor=scBg, text_size=bSz)
        if showAccuracy
            table.cell(bias_tbl, 2, 8, "", bgcolor=biasScoreFill)

    if showVwapDist
        int    vRow = showScore ? 9 : 8
        string vStr = (vwap_dist >= 0 ? "+" : "") + str.tostring(vwap_dist) + " pts"
        color  vCol = vwap_dist >= 0 ? c_winTxt : c_lossTxt
        color  vBg  = useVwap ? (vwap_dist >= 0 ? color.new(#1B5E20, 60) : color.new(#7B1414, 60)) : c_rowBgB
        table.cell(bias_tbl, 0, vRow, "vs VWAP", text_color=c_label, bgcolor=vBg, text_size=bSz)
        table.cell(bias_tbl, 1, vRow, vStr, text_color=vCol, bgcolor=vBg, text_size=bSz)
        if showAccuracy
            table.cell(bias_tbl, 2, vRow, useVwap ? "ON" : "OFF", text_color=useVwap ? c_winTxt : c_grey, bgcolor=vBg, text_size=bSz)

    int    drRow  = (showScore ? 9 : 8) + (showVwapDist ? 1 : 0)
    string drStr  = not bias_confirmed ? "No Break" : day_bias == 1 ? "BULL DR" : "BEAR DR"
    color  drBg   = not bias_confirmed ? biasNeutFill : day_bias == 1 ? color.new(#1B5E20, 0) : color.new(#7B1414, 0)
    color  drTx   = not bias_confirmed ? biasNeutTxt  : color.white
    string drFlt  = useDrFilter ? (db_active ? "Filter ON" : "Pending") : "Filter OFF"
    color  drFltC = useDrFilter ? (db_active ? c_winTxt : c_gold) : c_grey
    table.cell(bias_tbl, 0, drRow, "NY DR BIAS", text_color=biasHdrTxt, bgcolor=biasHdrFill, text_size=bSz)
    table.cell(bias_tbl, 1, drRow, drStr,         text_color=drTx,       bgcolor=drBg,        text_size=bSz)
    if showAccuracy
        table.cell(bias_tbl, 2, drRow, drFlt, text_color=drFltC, bgcolor=biasHdrFill, text_size=bSz)

// ═══════════════════════════════════════════
//  OTE RESULTS TABLE
// ═══════════════════════════════════════════
var table ote_tbl  = na   // Table 1: settings + stats + P&L
var table hour_tbl = na   // Table 2: per-slot hour breakdown

string oPos  = tablePos  == "Top Right" ? position.top_right : tablePos  == "Bottom Right" ? position.bottom_right : tablePos  == "Top Left" ? position.top_left : position.bottom_left
string oPos2 = tablePos2 == "Top Right" ? position.top_right : tablePos2 == "Bottom Right" ? position.bottom_right : tablePos2 == "Top Left" ? position.top_left : position.bottom_left
string oSz   = tableSize == "Tiny" ? size.tiny : tableSize == "Normal" ? size.normal : tableSize == "Large" ? size.large : size.small

if showTable and barstate.islast

    // ── TABLE 1: Summary (settings + stats + P&L) ──────────────
    if not na(ote_tbl)
        table.delete(ote_tbl)

    ote_tbl := table.new(oPos, 5, 20,
         bgcolor=c_tblBg, border_color=c_border, border_width=1, frame_color=c_border, frame_width=1)

    table.cell(ote_tbl, 0, 0, "OTE RESULTS", text_color=c_title, bgcolor=c_headerBg, text_size=oSz)
    table.cell(ote_tbl, 1, 0, "",             bgcolor=c_headerBg)
    table.cell(ote_tbl, 2, 0, "",             bgcolor=c_headerBg)
    table.cell(ote_tbl, 3, 0, "",             bgcolor=c_headerBg)
    table.cell(ote_tbl, 4, 0, "",             bgcolor=c_headerBg)

    string s1 = usePriorStop   ? "Stop: Prior H/L"    : "Stop: OTE Buffer"
    string s2 = useSwingFilter ? "Swing Filter: ON"   : "Swing Filter: OFF"
    string s3 = useSession ? "Session: " + str.tostring(sessionStart) + "-" + str.tostring(sessionEnd) + "ET" : "Session: All Hours"
    string s4 = useMaxRng  ? "Max Range: " + str.tostring(maxRange) + "pts" : "Max Range: OFF"
    string s5 = tgtMode == "Fixed R:R" ? "Target: " + str.tostring(rrMult, "#.#") + ":1 R:R" : "Target: " + tgtMode
    string s6 = useVwap    ? "VWAP Filter: ON"    : "VWAP Filter: OFF"
    string s7 = useDrFilter ? "DR Filter: ON | Gate: " + str.tostring(gateHour) + ":" + (gateMinute < 10 ? "0" : "") + str.tostring(gateMinute) + "ET" : "DR Filter: OFF"

    table.cell(ote_tbl, 0, 1, s1, text_color=c_gold,                              bgcolor=c_tblBg, text_size=oSz)
    table.cell(ote_tbl, 1, 1, "", bgcolor=c_tblBg)
    table.cell(ote_tbl, 2, 1, "", bgcolor=c_tblBg)
    table.cell(ote_tbl, 3, 1, "", bgcolor=c_tblBg)
    table.cell(ote_tbl, 4, 1, "", bgcolor=c_tblBg)
    table.cell(ote_tbl, 0, 2, s2, text_color=useSwingFilter ? c_winTxt : c_lossTxt, bgcolor=c_tblBg, text_size=oSz)
    table.cell(ote_tbl, 1, 2, "", bgcolor=c_tblBg)
    table.cell(ote_tbl, 2, 2, "", bgcolor=c_tblBg)
    table.cell(ote_tbl, 3, 2, "", bgcolor=c_tblBg)
    table.cell(ote_tbl, 4, 2, "", bgcolor=c_tblBg)
    table.cell(ote_tbl, 0, 3, s3, text_color=useSession ? c_winTxt : c_grey,        bgcolor=c_tblBg, text_size=oSz)
    table.cell(ote_tbl, 1, 3, "", bgcolor=c_tblBg)
    table.cell(ote_tbl, 2, 3, "", bgcolor=c_tblBg)
    table.cell(ote_tbl, 3, 3, "", bgcolor=c_tblBg)
    table.cell(ote_tbl, 4, 3, "", bgcolor=c_tblBg)
    table.cell(ote_tbl, 0, 4, s4, text_color=useMaxRng ? c_winTxt : c_grey,         bgcolor=c_tblBg, text_size=oSz)
    table.cell(ote_tbl, 1, 4, "", bgcolor=c_tblBg)
    table.cell(ote_tbl, 2, 4, "", bgcolor=c_tblBg)
    table.cell(ote_tbl, 3, 4, "", bgcolor=c_tblBg)
    table.cell(ote_tbl, 4, 4, "", bgcolor=c_tblBg)
    table.cell(ote_tbl, 0, 5, s5, text_color=c_blue,                                bgcolor=c_tblBg, text_size=oSz)
    table.cell(ote_tbl, 1, 5, "", bgcolor=c_tblBg)
    table.cell(ote_tbl, 2, 5, "", bgcolor=c_tblBg)
    table.cell(ote_tbl, 3, 5, "", bgcolor=c_tblBg)
    table.cell(ote_tbl, 4, 5, "", bgcolor=c_tblBg)
    table.cell(ote_tbl, 0, 6, s6, text_color=useVwap ? color.new(#FF6F00, 0) : c_grey, bgcolor=c_tblBg, text_size=oSz)
    table.cell(ote_tbl, 1, 6, "", bgcolor=c_tblBg)
    table.cell(ote_tbl, 2, 6, "", bgcolor=c_tblBg)
    table.cell(ote_tbl, 3, 6, "", bgcolor=c_tblBg)
    table.cell(ote_tbl, 4, 6, "", bgcolor=c_tblBg)
    table.cell(ote_tbl, 0, 7, s7, text_color=useDrFilter ? c_winTxt : c_grey,       bgcolor=c_tblBg, text_size=oSz)
    table.cell(ote_tbl, 1, 7, "", bgcolor=c_tblBg)
    table.cell(ote_tbl, 2, 7, "", bgcolor=c_tblBg)
    table.cell(ote_tbl, 3, 7, "", bgcolor=c_tblBg)
    table.cell(ote_tbl, 4, 7, "", bgcolor=c_tblBg)

    table.cell(ote_tbl, 0, 8,  "Trades",     text_color=c_label,  bgcolor=c_rowBgB, text_size=oSz)
    table.cell(ote_tbl, 1, 8,  str.tostring(total_trades), text_color=c_title,   bgcolor=c_rowBgB, text_size=oSz)
    table.cell(ote_tbl, 2, 8,  "", bgcolor=c_rowBgB)
    table.cell(ote_tbl, 3, 8,  "", bgcolor=c_rowBgB)
    table.cell(ote_tbl, 4, 8,  "", bgcolor=c_rowBgB)
    table.cell(ote_tbl, 0, 9,  "Wins",       text_color=c_label,  bgcolor=c_rowBgA, text_size=oSz)
    table.cell(ote_tbl, 1, 9,  str.tostring(total_wins),   text_color=c_winTxt,  bgcolor=c_rowBgA, text_size=oSz)
    table.cell(ote_tbl, 2, 9,  "", bgcolor=c_rowBgA)
    table.cell(ote_tbl, 3, 9,  "", bgcolor=c_rowBgA)
    table.cell(ote_tbl, 4, 9,  "", bgcolor=c_rowBgA)
    table.cell(ote_tbl, 0, 10, "Break Even", text_color=c_label,  bgcolor=c_rowBgB, text_size=oSz)
    table.cell(ote_tbl, 1, 10, str.tostring(total_be),     text_color=c_gold,    bgcolor=c_rowBgB, text_size=oSz)
    table.cell(ote_tbl, 2, 10, "", bgcolor=c_rowBgB)
    table.cell(ote_tbl, 3, 10, "", bgcolor=c_rowBgB)
    table.cell(ote_tbl, 4, 10, "", bgcolor=c_rowBgB)
    table.cell(ote_tbl, 0, 11, "Losses",     text_color=c_label,  bgcolor=c_rowBgA, text_size=oSz)
    table.cell(ote_tbl, 1, 11, str.tostring(total_losses), text_color=c_lossTxt, bgcolor=c_rowBgA, text_size=oSz)
    table.cell(ote_tbl, 2, 11, "", bgcolor=c_rowBgA)
    table.cell(ote_tbl, 3, 11, "", bgcolor=c_rowBgA)
    table.cell(ote_tbl, 4, 11, "", bgcolor=c_rowBgA)
    table.cell(ote_tbl, 0, 12, "Blocked",    text_color=c_label,  bgcolor=c_rowBgB, text_size=oSz)
    table.cell(ote_tbl, 1, 12, str.tostring(total_blocked),text_color=c_grey,    bgcolor=c_rowBgB, text_size=oSz)
    table.cell(ote_tbl, 2, 12, "", bgcolor=c_rowBgB)
    table.cell(ote_tbl, 3, 12, "", bgcolor=c_rowBgB)
    table.cell(ote_tbl, 4, 12, "", bgcolor=c_rowBgB)
    table.cell(ote_tbl, 0, 13, "Win Rate",   text_color=c_label,  bgcolor=c_rowBgA, text_size=oSz)
    table.cell(ote_tbl, 1, 13, str.tostring(win_rate) + "%", text_color=win_rate >= 50 ? c_winTxt : c_lossTxt, bgcolor=c_rowBgA, text_size=oSz)
    table.cell(ote_tbl, 2, 13, "", bgcolor=c_rowBgA)
    table.cell(ote_tbl, 3, 13, "", bgcolor=c_rowBgA)
    table.cell(ote_tbl, 4, 13, "", bgcolor=c_rowBgA)

    table.cell(ote_tbl, 0, 14, "P&L SUMMARY", text_color=c_title,  bgcolor=c_headerBg, text_size=oSz)
    table.cell(ote_tbl, 1, 14, "Points",       text_color=c_label,  bgcolor=c_headerBg, text_size=oSz)
    table.cell(ote_tbl, 2, 14, "$",            text_color=c_label,  bgcolor=c_headerBg, text_size=oSz)
    table.cell(ote_tbl, 3, 14, "",             bgcolor=c_headerBg)
    table.cell(ote_tbl, 4, 14, "",             bgcolor=c_headerBg)

    float aw_dol = math.round(avg_win_pts * pointValue * numContracts, 0)
    table.cell(ote_tbl, 0, 15, "Avg Win",  text_color=c_label,  bgcolor=c_rowBgB, text_size=oSz)
    table.cell(ote_tbl, 1, 15, "+" + str.tostring(avg_win_pts), text_color=c_winTxt, bgcolor=c_rowBgB, text_size=oSz)
    table.cell(ote_tbl, 2, 15, "$" + str.tostring(aw_dol),      text_color=c_winTxt, bgcolor=c_rowBgB, text_size=oSz)
    table.cell(ote_tbl, 3, 15, "", bgcolor=c_rowBgB)
    table.cell(ote_tbl, 4, 15, "", bgcolor=c_rowBgB)
    float al_dol = math.round(avg_los_pts * pointValue * numContracts, 0)
    table.cell(ote_tbl, 0, 16, "Avg Loss", text_color=c_label,   bgcolor=c_rowBgA, text_size=oSz)
    table.cell(ote_tbl, 1, 16, "-" + str.tostring(avg_los_pts),  text_color=c_lossTxt, bgcolor=c_rowBgA, text_size=oSz)
    table.cell(ote_tbl, 2, 16, "-$" + str.tostring(al_dol),      text_color=c_lossTxt, bgcolor=c_rowBgA, text_size=oSz)
    table.cell(ote_tbl, 3, 16, "", bgcolor=c_rowBgA)
    table.cell(ote_tbl, 4, 16, "", bgcolor=c_rowBgA)
    float tw_dol = math.round(total_pts_won * pointValue * numContracts, 0)
    table.cell(ote_tbl, 0, 17, "Total Won",  text_color=c_label,  bgcolor=c_rowBgB, text_size=oSz)
    table.cell(ote_tbl, 1, 17, "+" + str.tostring(math.round(total_pts_won,  1)), text_color=c_winTxt,  bgcolor=c_rowBgB, text_size=oSz)
    table.cell(ote_tbl, 2, 17, "$" + str.tostring(tw_dol),                        text_color=c_winTxt,  bgcolor=c_rowBgB, text_size=oSz)
    table.cell(ote_tbl, 3, 17, "", bgcolor=c_rowBgB)
    table.cell(ote_tbl, 4, 17, "", bgcolor=c_rowBgB)
    float tl_dol = math.round(total_pts_lost * pointValue * numContracts, 0)
    table.cell(ote_tbl, 0, 18, "Total Lost", text_color=c_label,   bgcolor=c_rowBgA, text_size=oSz)
    table.cell(ote_tbl, 1, 18, "-" + str.tostring(math.round(total_pts_lost, 1)), text_color=c_lossTxt, bgcolor=c_rowBgA, text_size=oSz)
    table.cell(ote_tbl, 2, 18, "-$" + str.tostring(tl_dol),                       text_color=c_lossTxt, bgcolor=c_rowBgA, text_size=oSz)
    table.cell(ote_tbl, 3, 18, "", bgcolor=c_rowBgA)
    table.cell(ote_tbl, 4, 18, "", bgcolor=c_rowBgA)

    color  netCol    = net_pts >= 0 ? c_winTxt : c_lossTxt
    string netPtsStr = net_pts >= 0 ? "+" + str.tostring(net_pts) : str.tostring(net_pts)
    string netDolStr = net_dollars >= 0 ? "$" + str.tostring(net_dollars) : "-$" + str.tostring(math.abs(net_dollars))
    table.cell(ote_tbl, 0, 19, "NET P&L",  text_color=c_title,  bgcolor=c_headerBg, text_size=oSz)
    table.cell(ote_tbl, 1, 19, netPtsStr,   text_color=netCol,   bgcolor=c_headerBg, text_size=oSz)
    table.cell(ote_tbl, 2, 19, netDolStr,   text_color=netCol,   bgcolor=c_headerBg, text_size=oSz)
    table.cell(ote_tbl, 3, 19, "",          bgcolor=c_headerBg)
    table.cell(ote_tbl, 4, 19, "",          bgcolor=c_headerBg)

    // ── TABLE 2: Hour / slot breakdown ─────────────────────────
    int hourCount = array.size(active_hours)

    if not na(hour_tbl)
        table.delete(hour_tbl)

    hour_tbl := table.new(oPos2, 5, hourCount + 1,
         bgcolor=c_tblBg, border_color=c_border, border_width=1, frame_color=c_border, frame_width=1)

    table.cell(hour_tbl, 0, 0, "SLOT",  text_color=c_title,   bgcolor=c_headerBg, text_size=oSz)
    table.cell(hour_tbl, 1, 0, "W",     text_color=c_winTxt,  bgcolor=c_headerBg, text_size=oSz)
    table.cell(hour_tbl, 2, 0, "BE",    text_color=c_gold,    bgcolor=c_headerBg, text_size=oSz)
    table.cell(hour_tbl, 3, 0, "L",     text_color=c_lossTxt, bgcolor=c_headerBg, text_size=oSz)
    table.cell(hour_tbl, 4, 0, "Pts",   text_color=c_title,   bgcolor=c_headerBg, text_size=oSz)

    for i = 0 to hourCount - 1
        int   row  = i + 1
        int   s    = array.get(active_hours,  i)
        int   w    = array.get(active_wins,   i)
        int   b    = array.get(active_be,     i)
        int   l    = array.get(active_losses, i)
        float pt   = array.get(active_pts,    i)
        int   totMin  = s * tfMin
        int   startH  = totMin / 60
        int   startM  = totMin % 60
        int   endMin  = totMin + tfMin
        int   endH    = endMin / 60
        int   endM    = endMin % 60
        string sh = str.tostring(startH < 12 ? (startH == 0 ? 12 : startH) : (startH == 12 ? 12 : startH - 12))
        string sm = (startM < 10 ? "0" : "") + str.tostring(startM)
        string sa = startH < 12 ? "AM" : "PM"
        string eh = str.tostring(endH < 12 ? (endH == 0 ? 12 : endH) : (endH == 12 ? 12 : endH - 12))
        string em = (endM < 10 ? "0" : "") + str.tostring(endM)
        string ea = endH < 12 ? "AM" : "PM"
        string lbl = tfMin >= 60 ? sh + sa : sh + ":" + sm + sa + "-" + eh + ":" + em + ea
        color  ptC = pt >= 0 ? c_winTxt : c_lossTxt
        string ptS = pt >= 0 ? "+" + str.tostring(pt) : str.tostring(pt)
        color  rbg = i % 2 == 0 ? c_rowBgA : c_rowBgB
        table.cell(hour_tbl, 0, row, lbl,             text_color=c_label,   bgcolor=rbg, text_size=oSz)
        table.cell(hour_tbl, 1, row, str.tostring(w), text_color=c_winTxt,  bgcolor=rbg, text_size=oSz)
        table.cell(hour_tbl, 2, row, str.tostring(b), text_color=c_gold,    bgcolor=rbg, text_size=oSz)
        table.cell(hour_tbl, 3, row, str.tostring(l), text_color=c_lossTxt, bgcolor=rbg, text_size=oSz)
        table.cell(hour_tbl, 4, row, ptS,             text_color=ptC,       bgcolor=rbg, text_size=oSz)

// ═══════════════════════════════════════════
//  PLOTS
// ═══════════════════════════════════════════
plot(showVwap ? vwap_val : na, "VWAP", color=vwapCol, linewidth=vwapWidth)

p_bz_hi = plot(showZone and bull_active ? bull_z_hi : na, "Bull OTE hi", color.new(bullCol, 70), 1, plot.style_linebr)
p_bz_lo = plot(showZone and bull_active ? bull_z_lo : na, "Bull OTE lo", color.new(bullCol, 70), 1, plot.style_linebr)
fill(p_bz_hi, p_bz_lo, color.new(bullCol, zAlpha))
p_rz_hi = plot(showZone and bear_active ? bear_z_hi : na, "Bear OTE hi", color.new(bearCol, 70), 1, plot.style_linebr)
p_rz_lo = plot(showZone and bear_active ? bear_z_lo : na, "Bear OTE lo", color.new(bearCol, 70), 1, plot.style_linebr)
fill(p_rz_hi, p_rz_lo, color.new(bearCol, zAlpha))

plot(showLvls and bull_active ? lk_prev_h : na, "Prior High",    color.new(#2196F3, 50), 1, plot.style_linebr)
plot(showLvls and bull_active ? lk_htf_o  : na, "Bull Open BE",  color.new(#FFD700, 40), 1, plot.style_linebr)
plot(showLvls and bull_active ? bull_z_lo : na, "Bull OTE Deep", color.new(bullCol,  40), 1, plot.style_linebr)
plot(showLvls and bull_active and usePriorStop ? lk_prev_l : na, "Bull Stop", color.new(#FF1744, 40), 1, plot.style_linebr)
plot(showLvls and bull_active and tgtMode == "Next Swing H/L" ? lk_next_sh : na, "Next Swing High", color.new(#2196F3, 10), 2, plot.style_linebr)
plot(showLvls and bear_active ? lk_prev_l : na, "Prior Low",     color.new(#9C27B0, 50), 1, plot.style_linebr)
plot(showLvls and bear_active ? lk_htf_o  : na, "Bear Open BE",  color.new(#FFD700, 40), 1, plot.style_linebr)
plot(showLvls and bear_active ? bear_z_hi : na, "Bear OTE Deep", color.new(bearCol,  40), 1, plot.style_linebr)
plot(showLvls and bear_active and usePriorStop ? lk_prev_h : na, "Bear Stop", color.new(#FF1744, 40), 1, plot.style_linebr)
plot(showLvls and bear_active and tgtMode == "Next Swing H/L" ? lk_next_sl : na, "Next Swing Low", color.new(#9C27B0, 10), 2, plot.style_linebr)

plot(showSwingLvls ? htf_sh2 : na, "Swing High 1", color.new(#FF9800, 30), 1, plot.style_linebr)
plot(showSwingLvls ? htf_sh3 : na, "Swing High 2", color.new(#FF9800, 55), 1, plot.style_linebr)
plot(showSwingLvls ? htf_sh4 : na, "Swing High 3", color.new(#FF9800, 70), 1, plot.style_linebr)
plot(showSwingLvls ? htf_sh5 : na, "Swing High 4", color.new(#FF9800, 80), 1, plot.style_linebr)
plot(showSwingLvls ? htf_sl2 : na, "Swing Low 1",  color.new(#9C27B0, 30), 1, plot.style_linebr)
plot(showSwingLvls ? htf_sl3 : na, "Swing Low 2",  color.new(#9C27B0, 55), 1, plot.style_linebr)
plot(showSwingLvls ? htf_sl4 : na, "Swing Low 3",  color.new(#9C27B0, 70), 1, plot.style_linebr)
plot(showSwingLvls ? htf_sl5 : na, "Swing Low 4",  color.new(#9C27B0, 80), 1, plot.style_linebr)

plotshape(showSig and bull_sig,         title="Long Entry",    style=shape.triangleup,   location=location.belowbar, color=bullCol,                text="LONG",  textcolor=bullCol,                size=size.normal)
plotshape(showSig and bear_sig,         title="Short Entry",   style=shape.triangledown, location=location.abovebar, color=bearCol,                text="SHORT", textcolor=bearCol,                size=size.normal)
plotshape(showBlocked and bull_blocked, title="Long Blocked",  style=shape.triangleup,   location=location.belowbar, color=color.new(bullCol, 70), text="X",     textcolor=color.new(bullCol, 50), size=size.small)
plotshape(showBlocked and bear_blocked, title="Short Blocked", style=shape.triangledown, location=location.abovebar, color=color.new(bearCol, 70), text="X",     textcolor=color.new(bearCol, 50), size=size.small)

if showLbl and bull_sig and not na(bull_stop_lvl) and not na(lk_htf_o) and not na(bull_z_hi)
    float  tgt = calcBullTgt(bull_z_hi, bull_stop_lvl)
    string txt = "LONG\nEntry  " + str.tostring(math.round(bull_z_hi,     2)) +
                 "\nStop   "     + str.tostring(math.round(bull_stop_lvl, 2)) +
                 "\nBE     "     + str.tostring(math.round(lk_htf_o,      2)) +
                 "\nTarget "     + str.tostring(math.round(tgt,           2))
    label.new(bar_index, low, txt, xloc=xloc.bar_index, yloc=yloc.price,
         color=color.new(#1B5E20, 0), textcolor=color.new(#A5D6A7, 0),
         style=label.style_label_up, size=size.small)

if showLbl and bear_sig and not na(bear_stop_lvl) and not na(lk_htf_o) and not na(bear_z_lo)
    float  tgt = calcBearTgt(bear_z_lo, bear_stop_lvl)
    string txt = "SHORT\nEntry  " + str.tostring(math.round(bear_z_lo,     2)) +
                 "\nStop   "      + str.tostring(math.round(bear_stop_lvl, 2)) +
                 "\nBE     "      + str.tostring(math.round(lk_htf_o,      2)) +
                 "\nTarget "      + str.tostring(math.round(tgt,           2))
    label.new(bar_index, high, txt, xloc=xloc.bar_index, yloc=yloc.price,
         color=color.new(#7B1414, 0), textcolor=color.new(#EF9A9A, 0),
         style=label.style_label_down, size=size.small)

// ═══════════════════════════════════════════
//  ALERTS
// ═══════════════════════════════════════════
alertcondition(bull_sig, "OTE Long Entry",  "OTE Long - Bull sweep confirmed.")
alertcondition(bear_sig, "OTE Short Entry", "OTE Short - Bear sweep confirmed.")
alertcondition(bull_sig or bear_sig, "OTE Entry (Any)", "OTE Sweep Signal fired.")
alertcondition(bias_just_confirmed and day_bias == 1,  "NY DR Bull Break", "NY DR confirmed BULL - longs only.")
alertcondition(bias_just_confirmed and day_bias == -1, "NY DR Bear Break", "NY DR confirmed BEAR - shorts only.")
````
