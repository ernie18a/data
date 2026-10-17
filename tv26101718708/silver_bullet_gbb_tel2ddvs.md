# Silver Bullet [GBB]

- url: https://www.tradingview.com/script/teL2dDvS-Silver-Bullet-GBB/
- type: indicator
- pine_id: PUB;7aeeaeee22e543f5960f07e52ad47bd7
- version: 1.0

## Description

Silver Bullet [GBB] draws ICT's Silver Bullet model on your chart with every step written down as an exact rule, tracks each setup to its result, and keeps score in net R after costs. A second mode, Hour Scan, runs the identical rules in every clock hour of the day, so you can check on your own chart whether the Silver Bullet hours behave any differently from the rest.

[b]THE MODEL[/b]

The Silver Bullet trades three one-hour windows, New York time: LDN 03:00-04:00, AM 10:00-11:00 and PM 14:00-15:00. Inside a window the indicator looks for this sequence:

1. Sweep. A candle trades at least one tick through an untouched liquidity level (a wick is enough, an exact touch is not). Levels: swing highs and lows (5 bars either side, strictly higher or lower, kept for 300 bars), the Asia high / low (20:00-24:00), the London high / low (02:00-05:00), the previous day's high / low, and the range of the hour before the window. Each level can be swept once. A swept high looks for a short, a swept low for a long.
2. Displacement. A fair value gap in the opposite direction: three candles inside the window, starting at or after the sweep, with a middle candle whose body is at least 1.0 x ATR(14) and a gap of at least 0.1 x ATR (and 2 ticks). The first such gap per direction in a window arms the setup.
3. Entry. A limit order at the gap's near edge. It fills only if price trades at least one tick through it before the window ends. It is cancelled if price reaches the target first or the window ends unfilled.
4. Stop. One tick beyond the sweep's extreme (the highest high for a short, the lowest low for a long, from the sweep candle to the end of the gap).
5. Target. The nearest untouched liquidity level on the other side. If it is closer than 1.5 R the setup is skipped (SKIP); if there is none, the target is 2 R.
6. Exit. Target, stop, or the time stop at window end + 60 minutes (never past 17:00), whichever comes first. If stop and target are hit in the same candle, it counts as a stop. One trade per window.

[b]WHAT YOU SEE[/b]

• Each window framed and tinted in its own colour, with its name and time.
• Live liquidity levels as dotted lines with a short name (PDH, London high, Asia low, 1H low ...). A level disappears when it is swept, except the window's first sweep, which is marked with ✕ and named ("swing low swept").
• The FVG box, dashed while the order is waiting, solid once it fills. The displacement candle can be painted.
• Risk and reward zones from the fill to the exit, entry / stop / target prices, and a result chip: TP, SL or TIME with the R.
• A live status pill next to the last bar: window live with minutes left, setup armed, open trade with its running R, or the next window.
• Stats panel: per window the number of trades, win rate and average net R, the total net R, a small equity curve of the last 30 trades, and the cost per trade in points. In Hour Scan it can show one row per clock hour with a bar either side of zero.

[b]HOUR SCAN[/b]

Hour Scan applies exactly the same rules to every clock hour from 18:00 to 16:00 New York time, each hour on its own. The Silver Bullet hours stay framed, so they can be compared directly with the other 20 hours. Chart text switches to a minimal style there, because setups every hour would overlap.

WHAT THE 16-YEAR TEST FOUND

These rules were tested on Sierra Chart 1-minute data from 2011 to 2026 on ES, NQ, YM and GC futures, in all 23 hours, with 2 ticks of slippage and $4.50 commission per round trip. Results are in R (the distance from entry to stop).

• After costs the model lost money in every hour on every market: 92 of 92 hour-market combinations. Before costs it was flat to negative.
• About one trade in four wins; roughly 73% of filled trades hit the stop.
• The Silver Bullet hours look better than the average hour only because they are busy hours: wider stops make the fixed costs a smaller part of each trade. Against hours that move just as much, they were no better on ES, NQ or YM. The one exception, gold's 10:00 hour, beat its comparable hours but still lost money, and was not confirmed.
• Of the armed setups whose limit order never filled, 70-76% reached the target before the stop. The orders that fill tend to be the losing ones.
• Placing the stop beyond the sweep's extreme was the one variant that improved results on both ES and NQ in the held-out years, which is why it is the default. It did not make the model profitable.

In short: with these rules, the Silver Bullet hours are not special, and the model is not a profitable strategy on its own. The indicator is published so you can see the rules at work, check the result on your own markets, and use parts of it (the sweep detection, the levels, the gaps) in your own work.

[b]SETTINGS[/b]

• Mode: Silver Bullet or Hour Scan. LDN / AM / PM on or off, plus one custom window.
• Liquidity: which levels count, pivot size and lookback.
• Sweep: required or not, optional close-back filter.
• Displacement: ATR length, body multiple, minimum gap.
• Entry: near edge or 50% of the gap (CE), trade-through or touch fill, grace bars, one trade per window or one per direction.
• Risk: stop beyond the sweep extreme or beyond the gap's first candle, stop buffer, minimum target in points and in R, fallback target, time stop (window end + 60 min, minutes after fill, or 17:00).
• Costs: slippage in ticks and commission per round trip, used for the net R in the panel.
• Display: Neon, GBB or Mono palette, number of days drawn (default 3), text size, and each drawing on or off.
• Stats panel: position, all loaded history or the last N days, rows per window or per hour.
• Alerts: window open, sweep, setup armed, entry filled, target, stop, time exit, setup cancelled; plus alert() messages with window, direction, entry, stop, target and R.
[b]
NOTES[/b]

• Built for 1-minute and 5-minute charts; signals are off outside 1m to 15m. The first load can take a while.
• Everything is calculated on closed candles and nothing repaints. Fills and exits are resolved on the chart's candles, so a 5m chart is coarser than the 1m test.
• The LDN window and Hour Scan need electronic (overnight) trading hours; on a regular-hours chart the panel shows a warning.
• The panel counts only the history TradingView has loaded. It is a description of that history, not a backtest, and a positive number there says nothing about the 16-year result.
• The Data Window shows the state, last outcome, last R and window id, plus the armed and closed values per bar, for use in other scripts.
• Runs on a free TradingView plan.

This is a tool for studying the Silver Bullet, not a buy or sell signal.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © GBB — "no hype, just data"
//@version=6
indicator("Silver Bullet [GBB]", shorttitle = "SB [GBB]", overlay = true, behind_chart = false,
     max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500, max_bars_back = 500)

// ---------------------------------------------------------------------------
// 1. Inputs
// ---------------------------------------------------------------------------
const string TZ = "America/New_York"

g_win  = "Windows (New York time)"
g_liq  = "Liquidity"
g_swp  = "Sweep"
g_dsp  = "Displacement"
g_ent  = "Entry"
g_risk = "Risk"
g_cost = "Costs (stats only)"
g_look = "Display"
g_tab  = "Stats panel"
g_alr  = "Alerts"

modeIn   = input.string("Silver Bullet", "Mode", options = ["Silver Bullet", "Hour Scan"], group = g_win,
     tooltip = "Silver Bullet: only the windows below. Hour Scan: the identical rules run in every clock hour of the session, each hour on its own, so the Silver Bullet hours can be compared with all the others.")
ldnOn    = input.bool(true, "LDN 03:00-04:00", group = g_win)
amOn     = input.bool(true, "AM 10:00-11:00", group = g_win)
pmOn     = input.bool(true, "PM 14:00-15:00", group = g_win)
cusOn    = input.bool(false, "Custom", inline = "cus", group = g_win)
cusSess  = input.session("0930-1030", "", inline = "cus", group = g_win,
     tooltip = "Silver Bullet mode only. New York time; must not cross midnight. The study tested clock hours only.")

useSwing = input.bool(true, "Swing highs / lows", group = g_liq)
pivL     = input.int(5, "Pivot left", minval = 1, inline = "piv", group = g_liq)
pivR     = input.int(5, "right", minval = 1, inline = "piv", group = g_liq)
pivLook  = input.int(300, "Swing lookback (bars)", minval = 10, group = g_liq)
useAsia  = input.bool(true, "Asia high / low (20:00-24:00)", group = g_liq)
useLdn   = input.bool(true, "London high / low (02:00-05:00)", group = g_liq)
usePd    = input.bool(true, "Previous day high / low", group = g_liq)
usePre   = input.bool(true, "Pre-window range (previous clock hour)", group = g_liq)

swReqIn  = input.string("Required", "Sweep", options = ["Required", "Not required"], group = g_swp,
     tooltip = "Required: the FVG must follow a sweep of a buy-side (for shorts) or sell-side (for longs) level in the same window.")
closeBk  = input.bool(false, "Sweep bar must close back", group = g_swp)

atrLen   = input.int(14, "ATR length", minval = 1, group = g_dsp)
kBody    = input.float(1.0, "Middle candle body >= ATR x", minval = 0, step = 0.1, group = g_dsp)
gapAtr   = input.float(0.1, "Min gap (ATR x)", minval = 0, step = 0.05, inline = "gap", group = g_dsp)
gapTicks = input.int(2, "and ticks", minval = 1, inline = "gap", group = g_dsp)

entryIn  = input.string("Proximal edge", "Entry", options = ["Proximal edge", "CE (50%)"], group = g_ent)
fillIn   = input.string("Trade through", "Fill", options = ["Trade through", "Touch"], group = g_ent,
     tooltip = "Trade through: price must trade one tick beyond the limit (conservative, as in the study). Touch: reaching the price fills.")
graceN   = input.int(0, "Grace bars after the window", minval = 0, group = g_ent)
perWin   = input.string("One", "Trades per window", options = ["One", "One per direction"], group = g_ent)

stopIn   = input.string("Sweep extreme", "Stop beyond", options = ["Sweep extreme", "FVG candle 1"], group = g_risk,
     tooltip = "Sweep extreme is the default because it was the one variant that improved results out of sample on both ES and NQ in the study.")
bufTicks = input.int(1, "Stop buffer (ticks)", minval = 0, group = g_risk)
minPts   = input.float(0.0, "Min target distance (points)", minval = 0, group = g_risk)
minR     = input.float(1.5, "Min target distance (R)", minval = 0, step = 0.1, group = g_risk,
     tooltip = "The target is the nearest unswept opposite liquidity. If it is closer than this, the setup is skipped (SKIP).")
fbR      = input.float(2.0, "Fallback target (R)", minval = 0.1, step = 0.1, group = g_risk,
     tooltip = "Used only when no opposite liquidity level exists.")
tsIn     = input.string("Window end + 60 min", "Time stop", options = ["Window end + 60 min", "Minutes after fill", "End of day (17:00)"], group = g_risk)
tsMin    = input.int(120, "Minutes after fill", minval = 1, group = g_risk)

slipTk   = input.float(2.0, "Slippage per round trip (ticks)", minval = 0, group = g_cost)
commRT   = input.float(4.50, "Commission per round trip", minval = 0, group = g_cost,
     tooltip = "In the symbol's currency, per contract. Converted to points with the point value.")

palIn    = input.string("Neon", "Palette", options = ["Neon", "GBB", "Mono"], group = g_look,
     tooltip = "Neon: each window gets its own color (LDN violet, AM cyan, PM gold). GBB: the v0.2 look. Mono: grey.")
showBg   = input.bool(true, "Window background glow", group = g_look,
     tooltip = "Full-height tint behind each Silver Bullet window, in the window's color.")
showHud  = input.bool(true, "Live status pill", group = g_look,
     tooltip = "A pill next to the last bar: window live and minutes left, armed setup, open trade with running R, or the next window.")
showDisp = input.bool(true, "Paint displacement candle", group = g_look,
     tooltip = "Colors the middle candle of the FVG that armed a setup.")
histDays = input.int(3, "Draw the last N days", minval = 1, maxval = 30, group = g_look,
     tooltip = "Older history is still computed for the stats panel but not drawn, so the chart never runs out of drawing objects.")
txtSize  = input.string("Normal", "Text size", options = ["Small", "Normal", "Large"], group = g_look,
     tooltip = "Size of all chart text: tags, level names, result chips and window titles. Large for video.")
showWin  = input.bool(true, "Window frames", group = g_look,
     tooltip = "A faint box around each Silver Bullet window's price range. In Hour Scan only the LDN / AM / PM hours are framed.")
showLvl  = input.bool(true, "Liquidity levels", group = g_look,
     tooltip = "Live session levels with a short name. A level disappears when it is swept, except the window's first sweep, which is marked.")
lvlAtr   = input.float(20, "Show levels within (ATR x)", minval = 0, step = 1, group = g_look,
     tooltip = "Levels farther than this from the close are tracked but not drawn, so they do not stretch the price scale. 0 = all.")
showFvg  = input.bool(true, "FVG boxes", group = g_look)
showTrd  = input.bool(true, "Trade zones", group = g_look,
     tooltip = "Risk (entry to stop) and reward (entry to target) zones from the fill to the exit.")
showTag  = input.bool(true, "Price tags and result chips", group = g_look)
chartTxt = input.string("Auto", "Chart text", options = ["Auto", "Full", "Minimal"], group = g_look,
     tooltip = "Full: sweep names, entry / stop / target prices and result chips with the exit price. Minimal: the cross, the zones and a short result chip. Auto: Full in Silver Bullet mode, Minimal in Hour Scan, where setups every hour would overlap.")

tabOn    = input.bool(true, "Show", group = g_tab)
tabPos   = input.string("Top right", "Position", options = ["Top right", "Bottom right", "Top left", "Bottom left"], group = g_tab)
tabScope = input.string("All loaded history", "Scope", options = ["All loaded history", "Last N days"], group = g_tab)
tabDays  = input.int(20, "N days", minval = 1, group = g_tab)
tabRows  = input.string("Auto", "Rows", options = ["Auto", "Windows", "Every hour"], group = g_tab,
     tooltip = "Auto: the windows in Silver Bullet mode, one row per clock hour in Hour Scan mode.")
tabSize  = input.string("Normal", "Panel text", options = ["Small", "Normal", "Large"], group = g_tab)

alertOn  = input.bool(true, "Send alert() messages", group = g_alr,
     tooltip = "Create an alert with 'Any alert() function call'. All messages fire on bar close.")

// ---------------------------------------------------------------------------
// 2. Constants
// ---------------------------------------------------------------------------
const color C_NEUTRAL = #787B86
const color C_BUY     = #00E676
const color C_SELL    = #FF3D71
const color C_CALM    = #2979FF
const color C_AMBER   = #FFB000
const color C_PANEL   = #1E222D
const color C_TEXT    = #D1D4DC
const color C_BG      = #131722
const color C_INK     = #0B0E14
const color C_ROW     = #12161F
const color C_EDGE    = #2E3445
const color N_UP      = #00FFA3
const color N_DN      = #FF2E63
const color N_LDN     = #A78BFA
const color N_AM      = #22D3EE
const color N_PM      = #FFC53D
const color N_CUS     = #F472B6
const color N_ASIA    = #60A5FA

const int K_PIV  = 0
const int K_ASIA = 1
const int K_LDN  = 2
const int K_PDAY = 3
const int K_PRE  = 4
const int NEVER  = 2000000000

const int ST_PEND  = 0
const int ST_TRADE = 1
const int ST_DONE  = 2

const int OUT_TP     = 1
const int OUT_SL     = 2
const int OUT_TIME   = 3
const int OUT_NOFILL = 4
const int OUT_SKIP   = 5
const int OUT_CANCEL = 6      // target reached before the entry filled
const int OUT_LOST   = 7      // the window's one trade was taken by the other direction (not counted)

const int CAP_L = 320          // finished lines kept (oldest deleted first)
const int CAP_T = 400          // finished labels kept
const int CAP_B = 380          // finished boxes kept
const int ROWS  = 25           // stats rows: clock hours 0-23, 24 = custom window

bool  hourScan  = modeIn == "Hour Scan"
bool  fullTxt   = chartTxt == "Full" or (chartTxt == "Auto" and not hourScan)
bool  sweepReq  = swReqIn == "Required"
bool  fillTouch = fillIn == "Touch"
float tick      = syminfo.mintick
float half      = tick / 2.0
float costPts   = slipTk * tick + commRT / syminfo.pointvalue
int   tfSec     = timeframe.in_seconds()
int   tfMs      = tfSec * 1000
bool  tfOk      = timeframe.isintraday and tfSec >= 60 and tfSec <= 900
bool  drawOn    = time >= last_bar_time - histDays * 86400000

bool  neon = palIn == "Neon"
color cUp  = neon ? N_UP : palIn == "GBB" ? C_BUY  : C_TEXT
color cDn  = neon ? N_DN : palIn == "GBB" ? C_SELL : C_NEUTRAL
color cWin = palIn == "Mono" ? #9598A1 : C_CALM

int cusS = int(str.tonumber(str.substring(cusSess, 0, 2))) * 60 + int(str.tonumber(str.substring(cusSess, 2, 4)))
int cusE = int(str.tonumber(str.substring(cusSess, 5, 7))) * 60 + int(str.tonumber(str.substring(cusSess, 7, 9)))
bool cusValid = cusE > cusS

// ---------------------------------------------------------------------------
// 3. Clock and window (New York wall clock; DST handled by the time zone)
// ---------------------------------------------------------------------------
int yNY     = year(time, TZ)
int moNY    = month(time, TZ)
int dNY     = dayofmonth(time, TZ)
int hNY     = hour(time, TZ)
int mNY     = minute(time, TZ)
int tod     = hNY * 60 + mNY
int hrStart = timestamp(TZ, yNY, moNY, dNY, hNY, 0)
int t6      = time + 6 * 3600000                         // the session opening at 18:00 belongs to the next date
int tdk     = year(t6, TZ) * 10000 + month(t6, TZ) * 100 + dayofmonth(t6, TZ)
int dayEnd  = timestamp(TZ, yNY, moNY, dNY, 17, 0) + (tod >= 1080 ? 86400000 : 0)

bool sbHour = (ldnOn and hNY == 3) or (amOn and hNY == 10) or (pmOn and hNY == 14)
int  winStart = na
int  winEnd   = na
int  winRow   = -1
if hourScan
    if hNY != 17
        winStart := hrStart
        winEnd   := hrStart + 3600000
        winRow   := hNY
else
    if sbHour
        winStart := hrStart
        winEnd   := hrStart + 3600000
        winRow   := hNY
    else if cusOn and cusValid and tod >= cusS and tod < cusE
        winStart := timestamp(TZ, yNY, moNY, dNY, int(math.floor(cusS / 60)), cusS % 60)
        winEnd   := timestamp(TZ, yNY, moNY, dNY, int(math.floor(cusE / 60)), cusE % 60)
        winRow   := 24
bool inWin  = tfOk and not na(winStart)
int  winKey = inWin ? winStart : -1

float atrV = ta.atr(atrLen)

// regular-hours-only chart: no overnight bar in the loaded history (syminfo.session is "regular" for CME futures
// even with electronic trading hours, so it cannot tell)
var bool sawNight = false
if hNY >= 18 or hNY < 8
    sawNight := true

// ---------------------------------------------------------------------------
// 4. Types and state
// ---------------------------------------------------------------------------
type Level
    float price
    int   side            // +1 buy-side (a high), -1 sell-side (a low)
    int   fromBar         // first bar that can sweep it
    int   knownBar        // known at this bar's close (usable as a target)
    int   expBar          // swing levels expire after this bar
    int   kind
    int   originTime
    line  ln              // drawn only while near the price
    label lb

type Setup
    int   winStart
    int   winEnd
    int   row
    int   dir             // +1 long (bullish FVG), -1 short (bearish FVG)
    int   armBar
    int   armTime
    float entry
    float stop
    float target
    int   tkind           // level kind of the target, -1 = fallback R
    int   fillEnd
    int   dlWin
    int   dayEnd
    int   status = 0
    int   outcome = 0
    int   fillTime
    float fillPx
    int   deadline
    bool  draw = false
    box   bx              // FVG
    box   zR              // risk zone (entry to stop)
    box   zW              // reward zone (entry to target)
    line  lE
    line  lS
    line  lT
    label tE
    label tS
    label tT

type State
    int   curWin = -1
    int   swBear
    int   swBull
    bool  armBear = false
    bool  armBull = false
    bool  winTraded = false
    int   tdKey
    float dayHi
    float dayLo
    int   dayMin = 0
    float pdHi
    float pdLo
    float asiaHi
    float asiaLo
    bool  asiaPub = true
    float ldnHi
    float ldnLo
    bool  ldnPub = true
    int   hourStart
    float hourHi
    float hourLo
    int   firstTime
    int   nBars = 0
    int   nDays = 0
    int   lastOutcome = 0
    float lastR
    bool  evWin = false
    bool  evSweep = false
    bool  evArm = false
    bool  evFill = false
    bool  evTP = false
    bool  evSL = false
    bool  evTime = false
    bool  evCancel = false
    int   pArmDir = 0
    float pArmEntry
    float pArmStop
    float pArmTarget
    int   pExit = 0
    float pExitR
    box   fBox            // the current window's frame
    line  fTop            // its accent edge
    label fLbl
    float fHi
    float fLo

var State         S      = State.new()
var array<Level>  levels = array.new<Level>()
var array<Setup>  setups = array.new<Setup>()
var array<line>   keepL  = array.new<line>()
var array<label>  keepT  = array.new<label>()
var array<box>    keepB  = array.new<box>()

var array<int>    stN      = array.new<int>(ROWS, 0)
var array<int>    stWin    = array.new<int>(ROWS, 0)
var array<float>  stNet    = array.new<float>(ROWS, 0.0)
var array<float>  spark    = array.new<float>()          // last 30 net R values in scope (equity sparkline)

// ---------------------------------------------------------------------------
// 5. Helpers
// ---------------------------------------------------------------------------
f_sz(string base, int step) =>
    int i = (base == "Small" ? 1 : base == "Large" ? 3 : 2) + step
    i <= 0 ? size.tiny : i == 1 ? size.small : i == 2 ? size.normal : i == 3 ? size.large : size.huge

f_size() =>
    f_sz(txtSize, 0)

f_winCol(int row) =>
    not neon ? cWin : row == 3 ? N_LDN : row == 10 ? N_AM : row == 14 ? N_PM : row == 24 ? N_CUS : cWin

f_lvlCol(int kind) =>
    not neon ? #B2B5BE : kind == K_PDAY ? N_PM : kind == K_ASIA ? N_ASIA : kind == K_LDN ? N_LDN : #B2B5BE

f_rowName(int row) =>
    row == 24 ? "Custom" : row == 3 ? "LDN" : row == 10 ? "AM" : row == 14 ? "PM" : (row < 10 ? "0" : "") + str.tostring(row) + ":00"

f_inScope(int t) =>
    tabScope == "All loaded history" or t >= last_bar_time - tabDays * 86400000

// drawing budget: finished objects go into FIFOs, the oldest is deleted first
f_keepLine(line l) =>
    if not na(l)
        keepL.push(l)
        if keepL.size() > CAP_L
            line.delete(keepL.shift())

f_keepLabel(label l) =>
    if not na(l)
        keepT.push(l)
        if keepT.size() > CAP_T
            label.delete(keepT.shift())

f_keepBox(box b) =>
    if not na(b)
        keepB.push(b)
        if keepB.size() > CAP_B
            box.delete(keepB.shift())

f_lvlName(int kind, int side) =>
    string hl = side > 0 ? "high" : "low"
    kind == K_PDAY ? (side > 0 ? "PDH" : "PDL") : kind == K_ASIA ? "Asia " + hl : kind == K_LDN ? "London " + hl : kind == K_PRE ? "1H " + hl : "swing " + hl

// small text to the right of a point (price tags, level names)
f_tag(int t, float y, string txt, color tc) =>
    label.new(t, y, txt, xloc = xloc.bar_time, style = label.style_label_left, color = color.new(C_INK, 8),
         textcolor = tc, size = f_sz(txtSize, 0))

// a session level replaces the previous one of its kind and side; a NaN price only clears (no pre-window range)
f_publish(float price, int side, int kind) =>
    if levels.size() > 0
        for i = levels.size() - 1 to 0
            Level lv = levels.get(i)
            if lv.kind == kind and lv.side == side
                line.delete(lv.ln)
                label.delete(lv.lb)
                levels.remove(i)
    if not na(price)
        levels.push(Level.new(price, side, bar_index, bar_index, NEVER, kind, time, na, na))

// the window's first sweep: the level from where it formed to the sweep, a cross and its name
f_sweepMark(Level lv, float price, color c) =>
    f_keepLine(line.new(lv.originTime, price, time, price, xloc = xloc.bar_time, color = color.new(c, 35), style = line.style_dashed))
    f_keepLabel(label.new(time, price, "✕", xloc = xloc.bar_time, style = label.style_none, textcolor = c, size = f_sz(txtSize, 2)))
    if fullTxt
        f_keepLabel(label.new(time + 3 * tfMs, price, f_lvlName(lv.kind, lv.side) + " swept", xloc = xloc.bar_time,
             style = label.style_label_left, color = color.new(c, 78), textcolor = c, size = f_size()))

// nearest unswept opposite-side level beyond the entry, known at this bar's close
f_target(int d, float entry, float R) =>
    float best = na
    int   bk   = -1
    for lv in levels
        if lv.knownBar <= bar_index
            if d < 0 and lv.side == -1 and lv.price < entry - 1e-9
                if na(best) or lv.price > best
                    best := lv.price
                    bk   := lv.kind
            else if d > 0 and lv.side == 1 and lv.price > entry + 1e-9
                if na(best) or lv.price < best
                    best := lv.price
                    bk   := lv.kind
    float tg   = best
    bool  skip = false
    if na(best)
        tg := entry + d * fbR * math.abs(R)
        bk := -1
    else if math.abs(best - entry) < math.max(minPts, minR * R) - 1e-9
        skip := true
    [tg, bk, skip]

f_dirTxt(int d) =>
    d > 0 ? "long" : "short"

f_alert(string what, Setup s) =>
    if alertOn
        float R = math.abs(s.entry - s.stop)
        alert(str.format("SB [GBB] {0} {1}: {2} {3} | entry {4} | stop {5} | target {6} | {7}R", syminfo.ticker,
             f_rowName(s.row), what, f_dirTxt(s.dir), str.tostring(s.entry, format.mintick),
             str.tostring(s.stop, format.mintick), str.tostring(s.target, format.mintick),
             str.tostring(math.abs(s.target - s.entry) / R, "0.0")), alert.freq_once_per_bar_close)

f_tagTxt(int outcome) =>
    outcome == OUT_TP ? "TP" : outcome == OUT_SL ? "SL" : outcome == OUT_TIME ? "TIME" : outcome == OUT_SKIP ? "SKIP" : "NO FILL"

// close a setup: stats, events, drawings
f_finish(Setup s, int outcome, float px, int xt) =>
    s.status  := ST_DONE
    s.outcome := outcome
    bool  traded = outcome == OUT_TP or outcome == OUT_SL or outcome == OUT_TIME
    float R      = math.abs(s.entry - s.stop)
    float netR   = na
    color col    = s.dir > 0 ? cUp : cDn
    if traded
        float gross = s.dir * (px - s.fillPx)
        netR := (gross - costPts) / R
        if f_inScope(xt)
            stN.set(s.row, stN.get(s.row) + 1)
            stWin.set(s.row, stWin.get(s.row) + (netR > 0 ? 1 : 0))
            stNet.set(s.row, stNet.get(s.row) + netR)
            spark.push(netR)
            if spark.size() > 30
                spark.shift()
        S.lastR  := netR
        S.pExit  := outcome
        S.pExitR := netR
        S.evTP   := S.evTP or outcome == OUT_TP
        S.evSL   := S.evSL or outcome == OUT_SL
        S.evTime := S.evTime or outcome == OUT_TIME
        f_alert(f_tagTxt(outcome) + " " + str.tostring(netR, "+0.00;-0.00") + "R (net)", s)
    else if outcome == OUT_NOFILL or outcome == OUT_CANCEL
        S.pExit    := outcome
        S.pExitR   := na
        S.evCancel := true
        f_alert(outcome == OUT_CANCEL ? "cancelled (target reached before the fill)" : "cancelled (no fill in the window)", s)
    if outcome != OUT_LOST
        S.lastOutcome := outcome
    // drawings: an order that never filled leaves nothing on the chart
    if not traded
        box.delete(s.bx)
    else
        f_keepBox(s.bx)
        for b in array.from(s.zR, s.zW)
            if not na(b)
                box.set_right(b, xt)
                f_keepBox(b)
        for l in array.from(s.lE, s.lS, s.lT)
            if not na(l)
                line.set_x2(l, xt)
                f_keepLine(l)
        if outcome == OUT_TP                                // the chip replaces the tag of the line it closed on
            label.delete(s.tT)
            s.tT := label(na)
        else if outcome == OUT_SL
            label.delete(s.tS)
            s.tS := label(na)
        else                                                // time exit: drop the tag nearest the exit price
            float dE = math.abs(px - s.entry)
            float dS = math.abs(px - s.stop)
            float dT = math.abs(px - s.target)
            if dS <= dE and dS <= dT
                label.delete(s.tS)
                s.tS := label(na)
            else if dT <= dE
                label.delete(s.tT)
                s.tT := label(na)
            else
                label.delete(s.tE)
                s.tE := label(na)
        for t in array.from(s.tE, s.tS, s.tT)
            if not na(t)
                label.set_x(t, xt)
                f_keepLabel(t)
        if s.draw and showTag
            color cb = outcome == OUT_TP ? cUp : outcome == OUT_SL ? cDn : color.new(netR > 0 ? cUp : cDn, 55)
            color ct = outcome == OUT_TIME ? color.white : C_INK
            string ic = outcome == OUT_TP ? "✓ " : outcome == OUT_SL ? "✕ " : "◷ "
            string chip = " " + ic + f_tagTxt(outcome) + "  " + str.tostring(netR, "+0.0;-0.0") + "R" +
                 (fullTxt ? "  ·  " + str.tostring(px, format.mintick) : "") + " "
            f_keepLabel(label.new(xt, px, chip, xloc = xloc.bar_time, style = label.style_label_left,
                 color = cb, textcolor = ct, size = f_sz(txtSize, outcome == OUT_TP ? 1 : 0)))
    true

// entry filled: deadline, drawings, one trade per window
f_fill(Setup s, float fp) =>
    s.status   := ST_TRADE
    s.fillPx   := fp
    s.fillTime := time
    s.deadline := tsIn == "Window end + 60 min" ? s.dlWin : tsIn == "Minutes after fill" ? math.min(time + tsMin * 60000, s.dayEnd) : s.dayEnd
    S.evFill   := true
    if s.winStart == S.curWin
        S.winTraded := true
    if perWin == "One"
        for o in setups
            if o.status == ST_PEND and o.winStart == s.winStart and o.dir != s.dir
                f_finish(o, OUT_LOST, na, time)
    color col = s.dir > 0 ? cUp : cDn
    if not na(s.bx)                                        // the FVG box ends at the fill and turns solid
        box.set_right(s.bx, time)
        box.set_border_style(s.bx, line.style_solid)
        box.set_border_color(s.bx, color.new(col, 20))
        box.set_bgcolor(s.bx, color.new(col, 70))
    if s.draw and showTrd
        float rr = math.abs(s.target - s.entry) / math.abs(s.entry - s.stop)
        s.zR := box.new(time, math.max(s.entry, s.stop), time, math.min(s.entry, s.stop), xloc = xloc.bar_time,
             border_color = color.new(cDn, 55), border_width = 1, bgcolor = color.new(cDn, 80))
        s.zW := box.new(time, math.max(s.entry, s.target), time, math.min(s.entry, s.target), xloc = xloc.bar_time,
             border_color = color.new(cUp, 55), border_width = 1, bgcolor = color.new(cUp, 84))
        s.lE := line.new(time, s.entry, time, s.entry, xloc = xloc.bar_time, color = color.new(color.white, 5), width = 2)
        s.lS := line.new(time, s.stop, time, s.stop, xloc = xloc.bar_time, color = cDn, width = 2)
        s.lT := line.new(time, s.target, time, s.target, xloc = xloc.bar_time, color = cUp, width = 2)
        if showTag
            f_keepLabel(label.new(time, s.entry, " " + (s.dir > 0 ? "▲ LONG" : "▼ SHORT") + "   1 : " + str.tostring(rr, "0.0") + " ",
                 xloc = xloc.bar_time, style = label.style_label_right, color = col, textcolor = C_INK, size = f_size()))
        if showTag and fullTxt
            s.tE := f_tag(time, s.entry, "entry " + str.tostring(s.entry, format.mintick), color.white)
            s.tS := f_tag(time, s.stop, "stop " + str.tostring(s.stop, format.mintick) + "   −1R", cDn)
            s.tT := f_tag(time, s.target, "target " + str.tostring(s.target, format.mintick) + "   +" + str.tostring(rr, "0.0") + "R", cUp)
    f_alert("entry filled", s)
    true

// one bar of a live setup (protocol 2.5-2.8): pending -> fill / cancel; in trade -> stop / target / time
f_step(Setup s) =>
    if s.status == ST_PEND
        if time >= s.fillEnd
            f_finish(s, OUT_NOFILL, na, time[1])
        else
            bool tgtHit = s.dir < 0 ? low <= s.target + half : high >= s.target - half
            if tgtHit
                f_finish(s, OUT_CANCEL, na, time)
            else
                float fp  = na
                float thr = fillTouch ? 0.0 : tick
                if s.dir < 0
                    if open > s.entry + half
                        fp := open
                    else if high >= s.entry - half + thr
                        fp := s.entry
                else
                    if open < s.entry - half
                        fp := open
                    else if low <= s.entry + half - thr
                        fp := s.entry
                if not na(fp)
                    f_fill(s, fp)
                    bool sh = s.dir < 0 ? high >= s.stop - half : low <= s.stop + half
                    if sh
                        f_finish(s, OUT_SL, s.dir < 0 ? math.max(s.stop, fp) : math.min(s.stop, fp), time)
                    else if time_close >= s.deadline
                        f_finish(s, OUT_TIME, close, time)
                else if not na(s.bx)
                    box.set_right(s.bx, time)
    else if s.status == ST_TRADE
        if time >= s.deadline
            f_finish(s, OUT_TIME, close[1], time[1])          // the last bar before the time stop (a gap in the bars)
        else
            bool sh = s.dir < 0 ? high >= s.stop - half : low <= s.stop + half
            bool th = s.dir < 0 ? low <= s.target + half : high >= s.target - half
            if sh                                              // stop and target in one bar: the stop
                f_finish(s, OUT_SL, s.dir < 0 ? math.max(s.stop, open) : math.min(s.stop, open), time)
            else if th
                f_finish(s, OUT_TP, s.target, time)
            else if time_close >= s.deadline
                f_finish(s, OUT_TIME, close, time)
            else
                for b in array.from(s.zR, s.zW)
                    if not na(b)
                        box.set_right(b, time)
                for l in array.from(s.lE, s.lS, s.lT)
                    if not na(l)
                        line.set_x2(l, time)
                for t in array.from(s.tE, s.tS, s.tT)
                    if not na(t)
                        label.set_x(t, time)
    true

// arm a setup on this bar's FVG (c = this bar, a = 2 bars back)
f_arm(int d) =>
    int   sw    = d < 0 ? S.swBear : S.swBull
    float entry = d < 0 ? high : low
    if entryIn == "CE (50%)"
        float mid = d < 0 ? (low[2] + high) / 2.0 : (high[2] + low) / 2.0
        entry := d < 0 ? math.ceil(mid / tick - 1e-9) * tick : math.floor(mid / tick + 1e-9) * tick
    float buf  = bufTicks * tick
    float stop = d < 0 ? high[2] + buf : low[2] - buf
    if stopIn == "Sweep extreme" and not na(sw)
        float ext = d < 0 ? high : low
        for k = 0 to bar_index - sw
            ext := d < 0 ? math.max(ext, high[k]) : math.min(ext, low[k])
        stop := d < 0 ? ext + buf : ext - buf
    float R = math.abs(entry - stop)
    [tg, tk, skip] = f_target(d, entry, R)
    Setup s = Setup.new(winStart = winStart, winEnd = winEnd, row = winRow, dir = d, armBar = bar_index, armTime = time,
         entry = entry, stop = stop, target = tg, tkind = tk, fillEnd = winEnd + graceN * tfMs,
         dlWin = math.min(winEnd + 3600000, dayEnd), dayEnd = dayEnd, status = ST_PEND, draw = drawOn)
    color col = d > 0 ? cUp : cDn
    float gTop = d < 0 ? low[2] : low
    float gBot = d < 0 ? high : high[2]
    bool lost = not skip and perWin == "One" and S.winTraded
    if s.draw and showFvg and not lost and not skip
        s.bx := box.new(time[2], gTop, time, gBot, xloc = xloc.bar_time, border_color = color.new(col, 35),
             border_width = 1, border_style = line.style_dashed, bgcolor = color.new(col, 82))
    if not lost                                        // one setup per bar at most: the two gap conditions exclude each other
        S.pArmDir    := d
        S.pArmEntry  := entry
        S.pArmStop   := stop
        S.pArmTarget := tg
    if skip
        f_finish(s, OUT_SKIP, na, time)
        S.pExit    := OUT_SKIP
        S.pExitR   := na
        S.evCancel := true
        f_alert("skipped (target closer than the minimum)", s)
    else if lost
        s.status  := ST_DONE
        s.outcome := OUT_LOST
    else
        setups.push(s)
        S.evArm := true
        f_alert("setup armed", s)
    true

// ---------------------------------------------------------------------------
// 6. Per-bar engine (confirmed bars only)
// ---------------------------------------------------------------------------
if barstate.isconfirmed and tfOk and hNY != 17         // the study's data has no 17:00 bars
    S.evWin     := false
    S.evSweep   := false
    S.evArm     := false
    S.evFill    := false
    S.evTP      := false
    S.evSL      := false
    S.evTime    := false
    S.evCancel  := false
    S.pArmDir   := 0
    S.pArmEntry := na
    S.pArmStop  := na
    S.pArmTarget := na
    S.pExit     := 0
    S.pExitR    := na
    if na(S.firstTime)
        S.firstTime := time
    S.nBars := S.nBars + 1

    // 1. live setups: fill, cancel, exit (a setup armed on this bar is first stepped on the next one)
    if setups.size() > 0
        for s in setups
            if s.status != ST_DONE
                f_step(s)
        for i = setups.size() - 1 to 0
            if setups.get(i).status == ST_DONE
                setups.remove(i)

    // 2. session levels (from bars before this one), then add this bar to the running ranges
    if na(S.tdKey) or tdk != S.tdKey
        if not na(S.tdKey) and S.dayMin >= 300
            S.pdHi := S.dayHi
            S.pdLo := S.dayLo
        if usePd and not na(S.pdHi)
            f_publish(S.pdHi, 1, K_PDAY)
            f_publish(S.pdLo, -1, K_PDAY)
        S.tdKey   := tdk
        S.nDays   := S.nDays + 1
        S.dayHi   := na
        S.dayLo   := na
        S.dayMin  := 0
        S.asiaHi  := na
        S.asiaLo  := na
        S.asiaPub := false
        S.ldnHi   := na
        S.ldnLo   := na
        S.ldnPub  := false
    if not S.asiaPub and tod < 1080 and not na(S.asiaHi)
        if useAsia
            f_publish(S.asiaHi, 1, K_ASIA)
            f_publish(S.asiaLo, -1, K_ASIA)
        S.asiaPub := true
    if not S.ldnPub and tod >= 300 and tod < 1080 and not na(S.ldnHi)
        if useLdn
            f_publish(S.ldnHi, 1, K_LDN)
            f_publish(S.ldnLo, -1, K_LDN)
        S.ldnPub := true
    if na(S.hourStart) or hrStart != S.hourStart
        if usePre
            bool contiguous = not na(S.hourStart) and hrStart - S.hourStart == 3600000
            if hNY != 18 and contiguous and not na(S.hourHi)
                f_publish(S.hourHi, 1, K_PRE)
                f_publish(S.hourLo, -1, K_PRE)
            else
                f_publish(na, 1, K_PRE)
                f_publish(na, -1, K_PRE)
        S.hourStart := hrStart
        S.hourHi    := na
        S.hourLo    := na
    S.dayHi  := na(S.dayHi) ? high : math.max(S.dayHi, high)
    S.dayLo  := na(S.dayLo) ? low : math.min(S.dayLo, low)
    S.dayMin := S.dayMin + int(tfSec / 60)
    if tod >= 1200
        S.asiaHi := na(S.asiaHi) ? high : math.max(S.asiaHi, high)
        S.asiaLo := na(S.asiaLo) ? low : math.min(S.asiaLo, low)
    if tod >= 120 and tod < 300
        S.ldnHi := na(S.ldnHi) ? high : math.max(S.ldnHi, high)
        S.ldnLo := na(S.ldnLo) ? low : math.min(S.ldnLo, low)
    S.hourHi := na(S.hourHi) ? high : math.max(S.hourHi, high)
    S.hourLo := na(S.hourLo) ? low : math.min(S.hourLo, low)

    // 3. window change
    if winKey != S.curWin
        S.curWin    := winKey
        S.swBear    := na
        S.swBull    := na
        S.armBear   := false
        S.armBull   := false
        S.winTraded := false
        S.fBox      := box(na)
        S.fLbl      := label(na)
        S.fTop      := line(na)
        if inWin
            S.evWin := true
            if alertOn
                alert(str.format("SB [GBB] {0} {1}: window open", syminfo.ticker, f_rowName(winRow)), alert.freq_once_per_bar_close)
            if showWin and drawOn and (not hourScan or sbHour)
                color wc = f_winCol(winRow)
                S.fHi  := high
                S.fLo  := low
                S.fBox := box.new(winStart, high, winEnd, low, xloc = xloc.bar_time, border_color = color.new(wc, 45),
                     border_width = 1, bgcolor = color.new(wc, 90))
                S.fTop := line.new(winStart, high, winEnd, high, xloc = xloc.bar_time, color = wc, width = 3)
                S.fLbl := label.new(winStart, high + 0.15 * nz(atrV), " " + f_rowName(winRow) + "   " + str.format_time(winStart, "HH:mm", TZ) + "–" +
                     str.format_time(winEnd, "HH:mm", TZ) + " NY ", xloc = xloc.bar_time, style = label.style_label_lower_left,
                     color = wc, textcolor = C_INK, size = f_size())
                f_keepBox(S.fBox)
                f_keepLine(S.fTop)
                f_keepLabel(S.fLbl)
    else if inWin and not na(S.fBox)                       // the frame follows the window's high and low
        S.fHi := math.max(S.fHi, high)
        S.fLo := math.min(S.fLo, low)
        box.set_top(S.fBox, S.fHi)
        box.set_bottom(S.fBox, S.fLo)
        line.set_y1(S.fTop, S.fHi)
        line.set_y2(S.fTop, S.fHi)
        label.set_y(S.fLbl, S.fHi + 0.15 * nz(atrV))

    // 4. sweeps: a level is spent by the first bar that trades through it by a tick
    bool  bearHit = false
    bool  bullHit = false
    float maxSw   = na
    float minSw   = na
    Level topLv   = na
    Level botLv   = na
    if levels.size() > 0
        for i = levels.size() - 1 to 0
            Level lv = levels.get(i)
            if lv.expBar < bar_index
                line.delete(lv.ln)
                levels.remove(i)
                continue
            if lv.fromBar > bar_index
                continue
            if lv.side == 1 and high > lv.price + half
                bearHit := true
                if na(maxSw) or lv.price > maxSw
                    maxSw := lv.price
                    topLv := lv
                line.delete(lv.ln)
                label.delete(lv.lb)
                levels.remove(i)
            else if lv.side == -1 and low < lv.price - half
                bullHit := true
                if na(minSw) or lv.price < minSw
                    minSw := lv.price
                    botLv := lv
                line.delete(lv.ln)
                label.delete(lv.lb)
                levels.remove(i)

    // live session levels: drawn (dotted, with a name) only while near the price
    if drawOn and showLvl and levels.size() > 0
        float band = lvlAtr > 0 and not na(atrV) ? lvlAtr * atrV : na
        for lv in levels
            if lv.kind != K_PIV
                bool near = na(band) or math.abs(lv.price - close) <= band
                if near and na(lv.ln)
                    lv.ln := line.new(lv.originTime, lv.price, time, lv.price, xloc = xloc.bar_time,
                         color = color.new(f_lvlCol(lv.kind), 30), style = lv.kind == K_PDAY ? line.style_dashed : line.style_dotted)
                    lv.lb := f_tag(time, lv.price, f_lvlName(lv.kind, lv.side), f_lvlCol(lv.kind))
                else if near
                    line.set_x2(lv.ln, time)
                    label.set_x(lv.lb, time)
                else if not na(lv.ln)
                    line.delete(lv.ln)
                    label.delete(lv.lb)
                    lv.ln := line(na)
                    lv.lb := label(na)

    // 5. swing pivot confirmed at this bar's close (strict on both sides, as the study)
    if useSwing and bar_index >= pivL + pivR
        bool  ph = true
        bool  pl = true
        float hj = high[pivR]
        float lj = low[pivR]
        for q = 0 to pivL + pivR
            if q != pivR
                if high[q] >= hj
                    ph := false
                if low[q] <= lj
                    pl := false
        if ph
            levels.push(Level.new(hj, 1, bar_index + 1, bar_index, bar_index - pivR + pivLook, K_PIV, time[pivR], na, na))
        if pl
            levels.push(Level.new(lj, -1, bar_index + 1, bar_index, bar_index - pivR + pivLook, K_PIV, time[pivR], na, na))

    // 6. the window's first sweep per side
    bool warm = S.nDays > 5                            // the study skipped its first 5 trading days
    if inWin and warm
        if bearHit and na(S.swBear) and (not closeBk or close < maxSw)
            S.swBear  := bar_index
            S.evSweep := true
            if drawOn and showLvl
                f_sweepMark(topLv, maxSw, cDn)
            if alertOn
                alert(str.format("SB [GBB] {0} {1}: buy-side liquidity swept at {2}", syminfo.ticker, f_rowName(winRow), str.tostring(maxSw, format.mintick)), alert.freq_once_per_bar_close)
        if bullHit and na(S.swBull) and (not closeBk or close > minSw)
            S.swBull  := bar_index
            S.evSweep := true
            if drawOn and showLvl
                f_sweepMark(botLv, minSw, cUp)
            if alertOn
                alert(str.format("SB [GBB] {0} {1}: sell-side liquidity swept at {2}", syminfo.ticker, f_rowName(winRow), str.tostring(minSw, format.mintick)), alert.freq_once_per_bar_close)

    // 7. displacement FVG with candle 3 = this bar; all three candles inside the window
    if inWin and warm and bar_index >= 2 and winKey[2] == winKey and atrV[2] > 0
        float A      = atrV[2]
        float minGap = math.max(gapAtr * A, gapTicks * tick) - 1e-9
        bool  bodyOk = math.abs(close[1] - open[1]) >= kBody * A - 1e-9
        if bodyOk
            if not S.armBear and low[2] - high >= minGap and (not sweepReq or (not na(S.swBear) and bar_index - 2 >= S.swBear))
                f_arm(-1)
                S.armBear := true
            if not S.armBull and low - high[2] >= minGap and (not sweepReq or (not na(S.swBull) and bar_index - 2 >= S.swBull))
                f_arm(1)
                S.armBull := true

// ---------------------------------------------------------------------------
// 6b. Window glow, displacement candle, live status pill
// ---------------------------------------------------------------------------
bgcolor(showBg and drawOn and inWin and (not hourScan or sbHour) ? color.new(f_winCol(winRow), 94) : na, title = "Window glow")
barcolor(showDisp and drawOn and barstate.isconfirmed and S.pArmDir != 0 ? (S.pArmDir > 0 ? cUp : cDn) : na, offset = -1, title = "Displacement candle")

var label hud = na
if barstate.islast
    label.delete(hud)
    hud := label(na)
    if showHud and tfOk
        string ht    = ""
        color  hc    = cWin
        bool   solid = true
        Setup  live  = na
        for s in setups
            if s.status == ST_TRADE
                live := s
            else if s.status == ST_PEND and na(live)
                live := s
        string dot = int(timenow / 1000) % 2 == 0 ? "● " : "○ "
        if not na(live) and live.status == ST_TRADE
            float uR = live.dir * (close - live.fillPx) / math.abs(live.entry - live.stop)
            hc := uR >= 0 ? cUp : cDn
            ht := dot + "IN TRADE  " + (live.dir > 0 ? "LONG" : "SHORT") + "   " + str.tostring(uR, "+0.00;-0.00") + "R"
        else if not na(live)
            hc := live.dir > 0 ? cUp : cDn
            ht := dot + "ARMED  " + (live.dir > 0 ? "LONG" : "SHORT") + " @ " + str.tostring(live.entry, format.mintick)
        else if inWin
            hc := f_winCol(winRow)
            int mLeft = math.max(0, int(math.ceil((winEnd - time_close) / 60000.0)))
            ht := dot + f_rowName(winRow) + " LIVE  ·  " + str.tostring(mLeft) + "m left" + (not na(S.swBear) or not na(S.swBull) ? "  ·  swept" : "")
        else if not hourScan
            int best = NEVER
            int bRow = -1
            for h in array.from(3, 10, 14)
                bool on = h == 3 ? ldnOn : h == 10 ? amOn : pmOn
                int  dm = (h * 60 - tod + 1440) % 1440
                if on and dm > 0 and dm < best
                    best := dm
                    bRow := h
            if cusOn and cusValid
                int dc = (cusS - tod + 1440) % 1440
                if dc > 0 and dc < best
                    best := dc
                    bRow := 24
            if bRow >= 0
                solid := false
                hc := f_winCol(bRow)
                ht := "◷ next  " + f_rowName(bRow) + "  in " + (best >= 60 ? str.tostring(int(math.floor(best / 60))) + "h " : "") + str.tostring(best % 60) + "m"
        if ht != ""
            hud := label.new(bar_index + 2, close, " " + ht + " ", style = label.style_label_left,
                 color = solid ? hc : color.new(C_INK, 5), textcolor = solid ? C_INK : hc, size = f_sz(txtSize, 1))

// ---------------------------------------------------------------------------
// 7. Stats panel
// ---------------------------------------------------------------------------
f_pos() =>
    tabPos == "Top right" ? position.top_right : tabPos == "Bottom right" ? position.bottom_right : tabPos == "Top left" ? position.top_left : position.bottom_left

var table tbl = table.new(f_pos(), 5, 36, bgcolor = C_INK, border_width = 1, border_color = C_INK, frame_color = C_EDGE, frame_width = 1)
var bool  tblMerged = false
string tabSz     = f_sz(tabSize, 0)
string tabSm     = f_sz(tabSize, -1)
bool   everyHour = tabRows == "Every hour" or (tabRows == "Auto" and hourScan)
int    nCols     = everyHour ? 5 : 4

f_cell(int c, int r, string txt, color tc, color bg, string sz, string ha) =>
    table.cell(tbl, c, r, txt, text_color = tc, bgcolor = bg, text_size = sz, text_halign = ha)

f_stats(array<int> hrs) =>
    int   n   = 0
    int   w   = 0
    float net = 0.0
    for h in hrs
        n   += stN.get(h)
        w   += stWin.get(h)
        net += stNet.get(h)
    [n, w, net]

f_rText(int n, float e) =>
    n > 0 ? str.tostring(e, "+0.00;-0.00") : "—"

f_rCol(int n, float e) =>
    n > 0 ? (e > 0 ? cUp : cDn) : C_NEUTRAL

// window rows: colored name pill, trades, win % with a 5-step meter, average net R on a tinted cell
f_winRow(int r, string name, array<int> hrs, int colRow) =>
    [n, w, net] = f_stats(hrs)
    bool  pill = colRow >= 0
    float e    = n > 0 ? net / n : na
    color rc   = f_rCol(n, e)
    int   fil  = n > 0 ? int(math.round(5.0 * w / n)) : 0
    f_cell(0, r, " " + name + " ", pill ? C_INK : C_TEXT, pill ? f_winCol(colRow) : C_ROW, tabSz, text.align_center)
    f_cell(1, r, str.tostring(n), C_TEXT, C_ROW, tabSz, text.align_right)
    f_cell(2, r, n > 0 ? str.tostring(100.0 * w / n, "0") + "%  " + str.repeat("▰", fil) + str.repeat("▱", 5 - fil) : "—", C_TEXT, C_ROW, tabSz, text.align_right)
    f_cell(3, r, f_rText(n, e), rc, n > 0 ? color.new(rc, 82) : C_ROW, tabSz, text.align_right)

// hour rows: trades, average net R and a bar either side of zero
f_hourRow(int r, int h, float mx) =>
    [n, w, net] = f_stats(array.from(h))
    bool  isSb = h == 3 or h == 10 or h == 14
    float e    = n > 0 ? net / n : na
    int   nb   = n > 0 ? int(math.round(8 * math.abs(e) / mx)) : 0
    f_cell(0, r, (h < 10 ? "0" : "") + str.tostring(h) + ":00" + (isSb ? "  " + f_rowName(h) : ""), isSb ? C_INK : C_TEXT, isSb ? f_winCol(h) : C_ROW, tabSz, text.align_left)
    f_cell(1, r, str.tostring(n), C_TEXT, C_ROW, tabSz, text.align_right)
    f_cell(2, r, f_rText(n, e), f_rCol(n, e), C_ROW, tabSz, text.align_right)
    f_cell(3, r, n > 0 and e < 0 and nb > 0 ? str.repeat("█", nb) : "", cDn, C_ROW, tabSz, text.align_right)
    f_cell(4, r, n > 0 and e > 0 and nb > 0 ? str.repeat("█", nb) : "", cUp, C_ROW, tabSz, text.align_left)

string warnTxt = not tfOk ? "use a 1m to 15m chart: signals off" : (not sawNight and (ldnOn or hourScan)) ? "regular-hours chart: overnight\nwindows need electronic hours" : ""

if barstate.islast and tabOn
    table.clear(tbl, 0, 0, 4, 35)
    string scope = tabScope == "All loaded history" ? (na(S.firstTime) ? "no bars yet" : "since " + str.format_time(S.firstTime, "yyyy-MM-dd", TZ)) : "last " + str.tostring(tabDays) + " days"
    f_cell(0, 0, "◆ SILVER BULLET  [GBB]", color.white, C_INK, f_sz(tabSize, 1), text.align_left)
    f_cell(0, 1, (hourScan ? "Hour Scan" : "SB windows") + "  ·  " + scope, C_NEUTRAL, C_INK, tabSm, text.align_left)
    int r = 3
    if everyHour
        f_cell(0, 2, "hour", C_NEUTRAL, C_INK, tabSm, text.align_left)
        f_cell(1, 2, "trades", C_NEUTRAL, C_INK, tabSm, text.align_right)
        f_cell(2, 2, "avg R", C_NEUTRAL, C_INK, tabSm, text.align_right)
        f_cell(3, 2, "", C_NEUTRAL, C_INK, tabSm, text.align_right)
        f_cell(4, 2, "", C_NEUTRAL, C_INK, tabSm, text.align_left)
        array<int> order = array.from(18, 19, 20, 21, 22, 23, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16)
        float mx = 0.25
        for h in order
            int n = stN.get(h)
            if n > 0
                mx := math.max(mx, math.abs(stNet.get(h) / n))
        for h in order
            f_hourRow(r, h, mx)
            r += 1
    else
        f_cell(0, 2, "window", C_NEUTRAL, C_INK, tabSm, text.align_center)
        f_cell(1, 2, "trades", C_NEUTRAL, C_INK, tabSm, text.align_right)
        f_cell(2, 2, "win", C_NEUTRAL, C_INK, tabSm, text.align_right)
        f_cell(3, 2, "avg R", C_NEUTRAL, C_INK, tabSm, text.align_right)
        if ldnOn or hourScan
            f_winRow(r, "LDN", array.from(3), 3)
            r += 1
        if amOn or hourScan
            f_winRow(r, "AM", array.from(10), 10)
            r += 1
        if pmOn or hourScan
            f_winRow(r, "PM", array.from(14), 14)
            r += 1
        if hourScan
            f_winRow(r, "Other hours", array.from(18, 19, 20, 21, 22, 23, 0, 1, 2, 4, 5, 6, 7, 8, 9, 11, 12, 13, 15, 16), -1)
            r += 1
        else if cusOn
            f_winRow(r, "Custom", array.from(24), 24)
            r += 1
    // hero: total net R across every row
    int   tN   = 0
    float tNet = 0.0
    for i = 0 to ROWS - 1
        tN   += stN.get(i)
        tNet += stNet.get(i)
    color tc = tN > 0 ? (tNet > 0 ? cUp : cDn) : C_NEUTRAL
    f_cell(0, r, "NET  ·  " + str.tostring(tN) + " trades", C_NEUTRAL, C_INK, tabSm, text.align_left)
    f_cell(1, r, tN > 0 ? str.tostring(tNet, "+0.0;-0.0") + "R" : "—", tc, C_INK, f_sz(tabSize, 2), text.align_right)
    int rHero = r
    r += 1
    // equity sparkline of the last 30 trades
    string sp  = ""
    color  spc = C_NEUTRAL
    if spark.size() > 1
        float cum = 0.0
        array<float> cs = array.new<float>()
        for v in spark
            cum += v
            cs.push(cum)
        float lo = math.min(cs.min(), 0.0)
        float hi = math.max(cs.max(), 0.0)
        string blk = "▁▂▃▄▅▆▇█"
        for v in cs
            int k = hi > lo ? int(math.round(7 * (v - lo) / (hi - lo))) : 3
            sp := sp + str.substring(blk, k, k + 1)
        spc := cum > 0 ? cUp : cDn
    f_cell(0, r, sp == "" ? "equity curve appears after 2 trades" : sp, spc, C_INK, sp == "" ? tabSm : tabSz, text.align_center)
    int rSpark = r
    r += 1
    f_cell(0, r, "net of " + str.tostring(costPts, "0.00") + " pts / trade", C_NEUTRAL, C_INK, tabSm, text.align_left)
    int rFoot = r
    r += 1
    f_cell(0, r, "loaded history only, not a backtest", C_NEUTRAL, C_INK, tabSm, text.align_left)
    int rFoot2 = r
    r += 1
    f_cell(0, r, "16-year study: see the video", color.new(C_NEUTRAL, 30), C_INK, tabSm, text.align_left)
    int rNote = r
    if warnTxt != ""
        r += 1
        f_cell(0, r, warnTxt, C_AMBER, C_INK, tabSm, text.align_left)
    if not tblMerged                                   // merges survive table.clear; do them once
        table.merge_cells(tbl, 0, 0, nCols - 1, 0)
        table.merge_cells(tbl, 0, 1, nCols - 1, 1)
        table.merge_cells(tbl, 1, rHero, nCols - 1, rHero)
        table.merge_cells(tbl, 0, rSpark, nCols - 1, rSpark)
        table.merge_cells(tbl, 0, rFoot, nCols - 1, rFoot)
        table.merge_cells(tbl, 0, rFoot2, nCols - 1, rFoot2)
        table.merge_cells(tbl, 0, rNote, nCols - 1, rNote)
        if warnTxt != ""
            table.merge_cells(tbl, 0, r, nCols - 1, r)
        tblMerged := true

// warnings
var label warnLbl = na
if barstate.islast
    label.delete(warnLbl)
    string w = tabOn or warnTxt == "" ? "" : "SB [GBB]: " + warnTxt
    warnLbl := w != "" ? label.new(bar_index, high, w, style = label.style_label_down, color = color.new(C_PANEL, 10), textcolor = C_AMBER, size = size.small) : na

// ---------------------------------------------------------------------------
// 8. Data window (state for other scripts and the parity export) and alerts
// ---------------------------------------------------------------------------
int stateCode = 0
if tfOk
    bool anyTrade = false
    bool anyPend  = false
    for s in setups
        anyTrade := anyTrade or s.status == ST_TRADE
        anyPend  := anyPend or s.status == ST_PEND
    stateCode := anyTrade ? 4 : anyPend ? 3 : inWin and (not na(S.swBear) or not na(S.swBull)) ? 2 : inWin ? 1 : 0

plot(stateCode, "State: 0 idle 1 window 2 swept 3 armed 4 trade", precision = 0, display = display.data_window)
plot(S.lastOutcome, "Last outcome: 1 TP 2 SL 3 TIME 4 NOFILL 5 SKIP 6 CANCEL", precision = 0, display = display.data_window)
plot(S.lastR, "Last R (net)", display = display.data_window)
plot(inWin ? winRow : -1, "Window: NY hour, 24 custom, -1 none", precision = 0, display = display.data_window)
plot(S.pArmDir, "Armed this bar: +1 long, -1 short", precision = 0, display = display.data_window)
plot(S.pArmEntry, "Armed this bar: entry", display = display.data_window)
plot(S.pArmStop, "Armed this bar: stop", display = display.data_window)
plot(S.pArmTarget, "Armed this bar: target", display = display.data_window)
plot(S.pExit, "Closed this bar: outcome", precision = 0, display = display.data_window)
plot(S.pExitR, "Closed this bar: R (net)", display = display.data_window)

bool aWin    = S.evWin
bool aSweep  = S.evSweep
bool aArm    = S.evArm
bool aFill   = S.evFill
bool aTP     = S.evTP
bool aSL     = S.evSL
bool aTime   = S.evTime
bool aCancel = S.evCancel
alertcondition(aWin,    "Window open",      "SB [GBB] {{ticker}}: window open")
alertcondition(aSweep,  "Sweep detected",   "SB [GBB] {{ticker}}: liquidity swept in the window")
alertcondition(aArm,    "Setup armed",      "SB [GBB] {{ticker}}: setup armed (FVG)")
alertcondition(aFill,   "Entry filled",     "SB [GBB] {{ticker}}: entry filled")
alertcondition(aTP,     "Target hit",       "SB [GBB] {{ticker}}: target hit")
alertcondition(aSL,     "Stop hit",         "SB [GBB] {{ticker}}: stop hit")
alertcondition(aTime,   "Time exit",        "SB [GBB] {{ticker}}: time exit")
alertcondition(aCancel, "Setup cancelled",  "SB [GBB] {{ticker}}: setup cancelled or skipped")
````
