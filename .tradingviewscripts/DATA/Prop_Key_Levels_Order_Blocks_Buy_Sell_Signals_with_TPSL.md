<!-- tradingview-pine-id: PUB;9db07d7cf199477fa713226e2b55d6f9 -->
<!-- tradingviewscripts-format: 1 -->
# Prop Key Levels & Order Blocks - Buy Sell Signals with TP/SL

Source: https://www.tradingview.com/script/uLmzNNCQ-Prop-Key-Levels-Order-Blocks-Buy-Sell-Signals-with-TP-SL/

## Description

A complete intraday trading suite built around one idea: the decision candle.
Instead of guessing where price might turn, the script marks the exact candles
where the market already made a decision, and then tells you what happened when
price came back to them.

Everything is evaluated on closed bars. Printed signals never move.

━━ WHAT IT DRAWS ━━

MAJOR KEY DETECTION
The origin candle of an impulsive displacement leg. Its body becomes a level
that extends to the right. Green for bullish decisions, red for bearish ones.
When price closes clean through a key, the level is greyed out — it failed, and
you can see that it failed. The detection level (1–100) sets how far price must
travel out of a candidate before it is accepted, so you can go from "every small
turn" to "only the moves that really expanded".

MAJOR ORDER BLOCKS
The last opposing candle before a structural break. Drawn as a box that survives
until price closes through it.

TREND DETECTION
A volatility-scaled trailing line under price, green while bullish and red while
bearish. It is the filter one of the two entry engines uses, and a weighted
component of the other.

ORDER POOL
Price levels that were rejected repeatedly and still hold unfilled resting
orders. Each pool is parked as an arrow at the right edge of the chart. You
decide what happens once price trades through one: remove it (the orders are
spent) or keep it dimmed, so you can still trade the reaction after the sweep.

SMART FVGS
Three-candle imbalances, filtered by a minimum size so the chart is not buried
under meaningless micro-gaps.

━━ THE ENTRY ENGINE ━━

Two independent algorithms, selectable in the settings.

PROP MODE — conservative. A signal needs the trend filter, a key level or order
block, and a confirmation candle to agree, and price must not already be
extended. Fewer trades, built for accounts where a handful of clean entries
beats constant activity.

AI-MODE — adaptive. Trend, momentum, key level, order block, pool sweep, fair
value gap and candle quality each contribute a weighted score. The engine fires
when the combined score clears a threshold you control, so it also takes the
reversals the conservative mode filters away.

Every entry comes with three take profits (Minor, Major, Highest) and a stop.
All four are expressed in volatility units — one unit is the ATR at the signal
bar — so the distances breathe with the market instead of being a fixed point
value that is wrong on half the days.

The reward box, the risk box and the projection line are drawn forward from the
entry, so one glance tells you whether the trade is worth taking. Hover any
signal badge to read why it fired and every price it produced.

━━ COOLDOWN ━━

After a signal, the engine mutes itself for a configurable number of bars. This
is what stops it from firing ten entries into the same move — the single
fastest way to run into a daily loss limit.

━━ DASHBOARDS ━━

A trade metrics table in the corner lists the live entry, all three targets, the
stop, the reward-to-risk and the cooldown state — the numbers you copy into your
order ticket.

A cockpit panel shows the live checklist (trend, key level, order block, pool
sweep, candle, cooldown), the running position, and a hit count across the whole
loaded history: how often each target was reached and how often the stop came
first.

━━ ALERTS ━━

Entry, take-profit hit and stop hit, as readable text or as a JSON object
carrying side, entry, all three targets, the stop and the reward-to-risk — the
format execution bridges expect.

━━ SETTINGS ━━

① Engine Control — strategy type, score threshold, cooldown, metrics table
② Trade Config — Minor / Major / Highest TP, SL, volatility unit
③ Insight Matrix — key detection and its level, order blocks, trend
④ Orderflow & Smart FVGs — order pool, touch count, tolerance, fill handling
⑤ Visuals — theme, candle colouring, boxes, price lines, panel, drawing budget
⑥ Alerts — what to fire and in which format

Every input carries a tooltip explaining what it does and what changes when you
move it.

━━ NOTES ━━

Designed for intraday work on index CFDs, gold and FX. The defaults were set up
on 1- to 15-minute charts; on higher timeframes raise the cooldown and the key
detection level.

This is an analysis tool, not financial advice. Past behaviour of any level or
signal says nothing about future results. Test any configuration on your own
instrument and timeframe before trading it.

---

## Source Code

````pine
//@version=6
// ═══════════════════════════════════════════════════════════════════════════════
//   PROP KEY LEVELS & ORDER BLOCKS  —  v1.0
//   A complete decision-candle / key-level trading suite for prop-style intraday
//   trading (index CFDs, gold, FX) with a full entry engine, three take-profit
//   targets, a stop level, a cooldown throttle and a live metrics dashboard.
//
//   MODULES
//   ① Engine Control ....... two independent signal algorithms + cooldown throttle
//   ② Trade Config ......... Minor / Major / Highest TP and SL as volatility units
//   ③ Insight Matrix ....... Major Key Detection, Major Order Blocks, Trend Detection
//   ④ Orderflow ............ Order Pool (resting-liquidity map) + Smart FVGs
//   ⑤ Visuals .............. dark theme, TP/SL projection boxes, cockpit panel
//   ⑥ Alerts ............... entry, TP-hit and SL-hit alerts incl. webhook JSON
//
//   CORE IDEA — the "decision candle"
//   A major key is the candle at which the market made a decision: the origin of
//   an impulsive displacement leg. Its body becomes a level that price tends to
//   react to when it returns. Order blocks are the last opposing candle before a
//   structural break, order pools are price levels that were touched repeatedly
//   and still hold unfilled resting orders.
//
//   Everything is evaluated on closed bars, so printed signals never move.
// ═══════════════════════════════════════════════════════════════════════════════

indicator("Prop Key Levels & Order Blocks - Buy Sell Signals with TP/SL", "PROP KEY LEVELS",
     overlay = true, max_boxes_count = 500, max_labels_count = 500, max_lines_count = 500)

// ─────────────────────────────── PALETTE ───────────────────────────────────────
color COL_BG     = color.rgb(6, 17, 30)
color COL_PANEL  = color.rgb(10, 29, 46)
color COL_PANEL2 = color.rgb(15, 44, 66)
color COL_BULL   = color.rgb(126, 224, 208)
color COL_BEAR   = color.rgb(244, 44, 58)
color COL_CYAN   = color.rgb(53, 200, 255)
color COL_GOLD   = color.rgb(255, 215, 40)
color COL_PINK   = color.rgb(255, 62, 130)
color COL_LIME   = color.rgb(214, 228, 78)
color COL_POOL   = color.rgb(178, 74, 255)
color COL_KEYB   = color.rgb(64, 196, 140)
color COL_KEYS   = color.rgb(196, 66, 92)
color COL_SELLBG = color.rgb(126, 32, 36)
color COL_BUYBG  = color.rgb(120, 154, 52)
color COL_TXT    = color.rgb(235, 235, 235)
color COL_GREY   = color.rgb(176, 182, 192)
color COL_DEAD   = color.rgb(96, 104, 116)

// ═══════════════════════════════ INPUTS ════════════════════════════════════════

// ① ENGINE CONTROL ─────────────────────────────────────────────────────────────
grpE = "① Engine Control"
stratType = input.string("Prop Mode", "Strategy Type", options = ["Prop Mode", "AI-Mode"], group = grpE,
     tooltip = "Two independent entry algorithms.\n\nPROP MODE — the conservative one. A signal only fires when the trend filter, a key level or order block, and a confirmation candle all agree, and price is not already extended. Fewer trades, tighter clusters, built for funded-account rules where a handful of clean entries beats constant activity.\n\nAI-MODE — the adaptive one. Every module (trend, momentum, key level, order block, order pool sweep, fair value gap, candle quality) contributes a weighted score. The engine fires as soon as the combined score clears the threshold, so it also takes reversals that Prop Mode filters away. More signals, more variety, more noise.")
aiThresh  = input.float(4.5, "AI-Mode score threshold", minval = 2.0, maxval = 10.0, step = 0.5, group = grpE,
     tooltip = "Only used in AI-Mode. The confluence score needed to release a signal. Maximum reachable score is about 9.5. Raise it for fewer and stricter entries, lower it for more activity. 4.5 is a balanced default.")
cooldownMode = input.string("On", "Cooldown Mode", options = ["On", "Off"], group = grpE,
     tooltip = "The engine cooldown. After a signal fires, no new signal is released for the configured number of bars. This is what stops the indicator from machine-gunning ten entries into the same move — the single biggest reason intraday systems blow a daily loss limit.")
cooldownBars = input.int(15, "Cooldown Period (Bars)", minval = 0, maxval = 500, group = grpE,
     tooltip = "How many bars the engine stays muted after a signal. 15 is the default on the 1-minute chart. On 5-minute charts, 5 to 8 usually maps to the same clock time.")
showMetrics  = input.string("On", "Trade Metrics Table", options = ["On", "Off"], group = grpE,
     tooltip = "The compact table in the bottom-right corner listing the live entry, the three take-profit levels, the stop level and the cooldown state — the numbers you copy into your order ticket.")

// ② TRADE CONFIG ───────────────────────────────────────────────────────────────
grpT = "② Trade Config"
minorTP = input.float(2.0, "Minor TP", minval = 0.1, maxval = 50.0, step = 0.1, group = grpT,
     tooltip = "First take profit, expressed in volatility units. One unit is the ATR at the signal bar, so the targets breathe with the market instead of being a fixed point value. 2.0 means: two ATR away from entry.")
majorTP = input.float(3.0, "Major TP", minval = 0.1, maxval = 50.0, step = 0.1, group = grpT,
     tooltip = "Second take profit in volatility units. Usually where the bulk of a position is closed.")
highTP  = input.float(6.0, "Highest TP", minval = 0.1, maxval = 50.0, step = 0.1, group = grpT,
     tooltip = "Runner target in volatility units. Also defines the height of the green projection box on the chart.")
slMult  = input.float(3.0, "SL", minval = 0.1, maxval = 50.0, step = 0.1, group = grpT,
     tooltip = "Stop distance in volatility units. Together with the targets this fixes your reward-to-risk: Highest TP divided by SL. With the defaults (6.0 / 3.0) the runner is a clean 2R.")
unitLen = input.int(14, "Volatility unit (ATR length)", minval = 2, maxval = 200, group = grpT,
     tooltip = "The averaging length for the volatility unit that scales every target and the stop. 14 is standard. Shorten it to make the levels react faster to a volatility burst, lengthen it for steadier distances.")
unitMult = input.float(1.0, "Volatility unit multiplier", minval = 0.1, maxval = 10.0, step = 0.1, group = grpT,
     tooltip = "Global scaling of the volatility unit. Leave at 1.0 unless the instrument you trade needs all distances stretched or squeezed at once — this saves editing all four values above.")

// ③ INSIGHT MATRIX ─────────────────────────────────────────────────────────────
grpI = "③ Insight Matrix"
useKeys  = input.bool(true, "Major Key Detection", group = grpI,
     tooltip = "Finds the decision candle: the candle that started an impulsive displacement leg. Its body is drawn as a horizontal level that extends to the right. These are the places where the market already showed its hand, and where it tends to react again on the next visit.")
keyLevel = input.int(60, "Major Key Detection Level", minval = 1, maxval = 100, group = grpI,
     tooltip = "Strictness of the key detection, 1 to 100. It sets how far price must travel out of the origin candle before that candle is accepted as a major key. Low values mark many small keys, high values only the ones that produced a real expansion. 60 keeps the chart readable on the 1- and 5-minute charts.")
keyWin   = input.int(5, "Displacement window (bars)", minval = 2, maxval = 30, group = grpI,
     tooltip = "How many bars the engine looks over when measuring the displacement leg out of a candidate origin candle. Small windows catch fast impulses, larger ones require a sustained push.")
keyMax   = input.int(8, "Max keys on chart", minval = 1, maxval = 30, group = grpI,
     tooltip = "How many major keys stay on the chart at once. The oldest is dropped when a new one prints. TradingView limits every script to 500 drawings, so keeping this modest also protects your signals from being deleted.")
keyFade  = input.bool(true, "Grey out broken keys", group = grpI,
     tooltip = "When price closes clean through a key, the level has lost its meaning. ON greys it out so you can see it failed. OFF removes it from the chart entirely.")
useOB    = input.bool(true, "Major Order Blocks", group = grpI,
     tooltip = "The last opposing candle before a structural break. Institutions that pushed the break left unfilled orders in that candle, which is why price so often comes back to it before continuing. Drawn as a box that stays until price closes through it.")
obMax    = input.int(6, "Max order blocks on chart", minval = 1, maxval = 20, group = grpI)
useTrend = input.bool(true, "Trend Detection", group = grpI,
     tooltip = "The glowing trail under price. It is a volatility-scaled trailing line: green while the market is bullish, red while it is bearish. It is the trend filter Prop Mode uses, and the trend component of the AI-Mode score.")
trendLen  = input.int(10, "Trend ATR length", minval = 1, maxval = 100, group = grpI)
trendMult = input.float(3.0, "Trend factor", minval = 0.5, maxval = 20.0, step = 0.1, group = grpI,
     tooltip = "How much room the trailing line gives price before it flips. Higher values flip later and catch longer swings, lower values flip early and react to every pullback.")

// ④ ORDERFLOW & SMART FVGS ─────────────────────────────────────────────────────
grpO = "④ Orderflow & Smart FVGs"
usePool    = input.bool(true, "Activate Order Pool", group = grpO,
     tooltip = "The resting-liquidity map. Price levels that were rejected repeatedly collect unfilled orders — stops of trapped traders and limit orders waiting to be filled. Each pool is marked with a violet arrow at the right edge of the chart. They act as magnets: price reaches for them, and often reverses right after taking them.")
poolTouch  = input.int(2, "Minimum touches per pool", minval = 2, maxval = 10, group = grpO,
     tooltip = "How many swing points must line up at the same price before it counts as a pool. Two is the classic equal-high / equal-low. Three or more marks only the heaviest clusters.")
poolTol    = input.float(0.30, "Pool tolerance (volatility units)", minval = 0.02, maxval = 3.0, step = 0.02, group = grpO,
     tooltip = "How close two swing points must be to count as the same level. Measured in volatility units, so it adapts to the instrument automatically.")
poolDelete = input.bool(false, "Delete filled orders", group = grpO,
     tooltip = "What happens once price trades through a pool. ON removes it — the orders are filled, the level is spent. OFF keeps it on the chart, dimmed, so you can still see where the liquidity was taken. Traders who trade the reaction after a sweep usually leave this OFF.")
poolMax    = input.int(10, "Max pools on chart", minval = 1, maxval = 30, group = grpO)
poolOff    = input.int(8, "Pool marker offset (bars)", minval = 1, maxval = 80, group = grpO,
     tooltip = "How far to the right of the last bar the violet pool arrows are parked, so they never sit on top of the candles.")
useFVG     = input.bool(true, "Smart FVGs", group = grpO,
     tooltip = "Fair value gaps: a three-candle imbalance where the market moved so fast that it left a price range untraded. Only gaps wider than the filter below are drawn, which removes the dozens of meaningless micro-gaps every chart contains.")
fvgMin     = input.float(0.35, "Minimum FVG size (volatility units)", minval = 0.05, maxval = 5.0, step = 0.05, group = grpO)
fvgMax     = input.int(6, "Max FVGs on chart", minval = 1, maxval = 20, group = grpO)

// ⑤ VISUALS ────────────────────────────────────────────────────────────────────
grpV = "⑤ Visuals"
useTheme  = input.bool(true, "Dark chart theme", group = grpV,
     tooltip = "Paints the chart background and the candles in the suite's own colour scheme, so the levels and signals stay readable. Switch it off if you prefer your own chart styling.")
colorBars = input.bool(true, "Colour candles by trend", group = grpV)
showBoxes = input.bool(true, "TP / SL projection boxes", group = grpV,
     tooltip = "The green reward box and the red risk box that are drawn forward from every entry, plus the dashed line running from the entry to the runner target. One glance tells you whether the trade is worth taking.")
boxBars   = input.int(40, "Projection length (bars)", minval = 5, maxval = 300, group = grpV)
showLevels = input.bool(true, "Entry / TP / SL price lines", group = grpV,
     tooltip = "Dashed horizontal lines with price tags at the entry, all three targets and the stop.")
showPills = input.bool(true, "Signal pills", group = grpV,
     tooltip = "The two-line BUY / SELL badge at each signal, carrying the reward-to-risk and the reason the trade fired. Hover it to read the full breakdown.")
showPanel = input.bool(true, "Cockpit panel", group = grpV)
panelPos  = input.string("Middle Left", "Panel position", options = ["Middle Left", "Top Left", "Bottom Left", "Top Right", "Middle Right", "Bottom Right"], group = grpV)
maxTrades = input.int(15, "Keep drawings of last N trades", minval = 1, maxval = 60, group = grpV,
     tooltip = "Older trade drawings are removed to stay inside TradingView's 500-drawing budget. Raise it for a deeper visual history, lower it if levels start disappearing from the chart.")

// ⑥ ALERTS ─────────────────────────────────────────────────────────────────────
grpA = "⑥ Alerts"
alEntry  = input.bool(true, "Alert on entry", group = grpA)
alTP     = input.bool(true, "Alert on take profit hit", group = grpA)
alSL     = input.bool(true, "Alert on stop hit", group = grpA)
alJson   = input.bool(false, "Send alerts as JSON (webhook ready)", group = grpA,
     tooltip = "OFF sends a readable text line. ON sends a JSON object with side, entry, all three targets, the stop and the reward-to-risk — the format order-execution bridges expect.")

// ═══════════════════════════════ CORE ══════════════════════════════════════════

float atrRaw = ta.atr(unitLen)
float unit   = (na(atrRaw) or atrRaw <= 0 ? syminfo.mintick * 10 : atrRaw) * unitMult

// ── Trend Detection: volatility trailing line ─────────────────────────────────
[stRaw, stDir] = ta.supertrend(trendMult, trendLen)
bool trendUp   = stDir < 0
float trendLn  = ta.ema(stRaw, 3)

plot(useTrend ? trendLn : na, "Trend glow 4", color = color.new(trendUp ? COL_BULL : COL_BEAR, 90), linewidth = 8, display = display.pane)
plot(useTrend ? trendLn : na, "Trend glow 3", color = color.new(trendUp ? COL_BULL : COL_BEAR, 78), linewidth = 6, display = display.pane)
plot(useTrend ? trendLn : na, "Trend glow 2", color = color.new(trendUp ? COL_BULL : COL_BEAR, 55), linewidth = 4, display = display.pane)
plot(useTrend ? trendLn : na, "Trend line",   color = trendUp ? COL_BULL : COL_BEAR,                 linewidth = 2, display = display.pane)

// ── Chart theme ───────────────────────────────────────────────────────────────
bgcolor(useTheme ? color.new(COL_BG, 0) : na, title = "Theme background")
barcolor(useTheme and colorBars ? (trendUp ? COL_BULL : COL_BEAR) : na, title = "Trend candles")

// ── Momentum helpers ──────────────────────────────────────────────────────────
float rsi   = ta.rsi(close, 14)
float emaF  = ta.ema(close, 9)
float emaS  = ta.ema(close, 21)
float bodySz = math.abs(close - open)
float rng    = math.max(high - low, syminfo.mintick)
bool bullConf = close > open and bodySz > 0.35 * unit and (close - low) / rng > 0.55
bool bearConf = close < open and bodySz > 0.35 * unit and (high - close) / rng > 0.55

// ═══════════════════════ ③ MAJOR KEY DETECTION ═════════════════════════════════
// A decision candle is the origin of a displacement leg. keyLevel scales how far
// price has to travel out of it before the candle earns the "major key" label.

var array<box>   keyBox   = array.new<box>()
var array<float> keyTop   = array.new<float>()
var array<float> keyBot   = array.new<float>()
var array<int>   keyDir   = array.new<int>()
var array<int>   keyState = array.new<int>()   // 0 = fresh, 1 = tapped, 2 = broken

f_keyTrim(int maxN) =>
    while array.size(keyBox) > maxN
        box.delete(array.shift(keyBox))
        array.shift(keyTop)
        array.shift(keyBot)
        array.shift(keyDir)
        array.shift(keyState)
    array.size(keyBox)

// mark taps / breaks on the existing keys before adding new ones
bool tapBullKey = false
bool tapBearKey = false
if array.size(keyBox) > 0
    for i = 0 to array.size(keyBox) - 1
        float kt = array.get(keyTop, i)
        float kb = array.get(keyBot, i)
        int   kd = array.get(keyDir, i)
        int   ks = array.get(keyState, i)
        if ks < 2
            bool touched = low <= kt and high >= kb
            if kd > 0
                if touched
                    tapBullKey := true
                    if ks == 0
                        array.set(keyState, i, 1)
                if close < kb - 0.15 * unit
                    array.set(keyState, i, 2)
            else
                if touched
                    tapBearKey := true
                    if ks == 0
                        array.set(keyState, i, 1)
                if close > kt + 0.15 * unit
                    array.set(keyState, i, 2)

// repaint / drop broken keys
if array.size(keyBox) > 0
    for i = array.size(keyBox) - 1 to 0
        if array.get(keyState, i) == 2
            if keyFade
                box.set_bgcolor(array.get(keyBox, i), color.new(COL_DEAD, 92))
                box.set_border_color(array.get(keyBox, i), color.new(COL_DEAD, 55))
            else
                box.delete(array.get(keyBox, i))
                array.remove(keyBox, i)
                array.remove(keyTop, i)
                array.remove(keyBot, i)
                array.remove(keyDir, i)
                array.remove(keyState, i)

float dispThr = 1.0 + keyLevel / 100.0 * 3.0
float legUp   = (close - close[keyWin]) / unit
float legDn   = (close[keyWin] - close) / unit
bool newBullKey = useKeys and barstate.isconfirmed and legUp >= dispThr and legUp[1] < dispThr
bool newBearKey = useKeys and barstate.isconfirmed and legDn >= dispThr and legDn[1] < dispThr

// origin offsets are calculated on every bar so the series stay continuous
int lowOff  = -ta.lowestbars(low, keyWin + 1)
int highOff = -ta.highestbars(high, keyWin + 1)

if newBullKey or newBearKey
    int off = newBullKey ? lowOff : highOff
    off := math.max(0, math.min(off, keyWin))
    float ot = math.max(open[off], close[off])
    float ob = math.min(open[off], close[off])
    if ot - ob < 0.18 * unit
        float mid = (ot + ob) / 2.0
        ot := mid + 0.09 * unit
        ob := mid - 0.09 * unit
    // do not stack two keys on the same price
    bool dup = false
    if array.size(keyTop) > 0
        for i = 0 to array.size(keyTop) - 1
            if math.abs((array.get(keyTop, i) + array.get(keyBot, i)) / 2.0 - (ot + ob) / 2.0) < 0.6 * unit
                dup := true
    if not dup
        color kc = newBullKey ? COL_KEYB : COL_KEYS
        box nb = box.new(bar_index - off, ot, bar_index, ob, border_color = color.new(kc, 25),
             border_width = 1, bgcolor = color.new(kc, 72), extend = extend.right,
             text = "", text_color = color.new(kc, 20), text_size = size.tiny, text_halign = text.align_left)
        array.push(keyBox, nb)
        array.push(keyTop, ot)
        array.push(keyBot, ob)
        array.push(keyDir, newBullKey ? 1 : -1)
        array.push(keyState, 0)
        f_keyTrim(keyMax)

// ═══════════════════════ ③ MAJOR ORDER BLOCKS ══════════════════════════════════
var array<box>   obBox   = array.new<box>()
var array<float> obTop   = array.new<float>()
var array<float> obBot   = array.new<float>()
var array<int>   obDir   = array.new<int>()

f_obTrim(int maxN) =>
    while array.size(obBox) > maxN
        box.delete(array.shift(obBox))
        array.shift(obTop)
        array.shift(obBot)
        array.shift(obDir)
    array.size(obBox)

bool tapBullOB = false
bool tapBearOB = false
if array.size(obBox) > 0
    for i = array.size(obBox) - 1 to 0
        float bt = array.get(obTop, i)
        float bb = array.get(obBot, i)
        int   bd = array.get(obDir, i)
        bool  touched = low <= bt and high >= bb
        if bd > 0
            if touched
                tapBullOB := true
            if close < bb
                box.delete(array.get(obBox, i))
                array.remove(obBox, i)
                array.remove(obTop, i)
                array.remove(obBot, i)
                array.remove(obDir, i)
        else
            if touched
                tapBearOB := true
            if close > bt
                box.delete(array.get(obBox, i))
                array.remove(obBox, i)
                array.remove(obTop, i)
                array.remove(obBot, i)
                array.remove(obDir, i)

int   obLook  = 12
float prevHi  = ta.highest(high, 20)[1]
float prevLo  = ta.lowest(low, 20)[1]
bool  bullBrk = useOB and barstate.isconfirmed and close > prevHi and (close - open) > 0.9 * unit
bool  bearBrk = useOB and barstate.isconfirmed and close < prevLo and (open - close) > 0.9 * unit

if bullBrk or bearBrk
    int found = -1
    for k = 1 to obLook
        if found == -1
            if bullBrk and close[k] < open[k]
                found := k
            if bearBrk and close[k] > open[k]
                found := k
    if found > 0
        color oc = bullBrk ? COL_BULL : COL_BEAR
        box nb = box.new(bar_index - found, high[found], bar_index + 1, low[found],
             border_color = color.new(oc, 55), border_width = 1, bgcolor = color.new(oc, 90),
             extend = extend.right, text = "OB", text_color = color.new(oc, 40),
             text_size = size.tiny, text_halign = text.align_left, text_valign = text.align_center)
        array.push(obBox, nb)
        array.push(obTop, high[found])
        array.push(obBot, low[found])
        array.push(obDir, bullBrk ? 1 : -1)
        f_obTrim(obMax)

// ═══════════════════════ ④ ORDER POOL (resting liquidity) ══════════════════════
var array<float> poolLvl  = array.new<float>()
var array<int>   poolHits = array.new<int>()
var array<int>   poolDir  = array.new<int>()
var array<label> poolLab  = array.new<label>()
var array<line>  poolLn   = array.new<line>()
var array<bool>  poolFill = array.new<bool>()

int   pvLen = 3
float pvH   = ta.pivothigh(pvLen, pvLen)
float pvL   = ta.pivotlow(pvLen, pvLen)
float tol   = poolTol * unit

f_poolTrim(int maxN) =>
    while array.size(poolLvl) > maxN
        label.delete(array.shift(poolLab))
        line.delete(array.shift(poolLn))
        array.shift(poolLvl)
        array.shift(poolHits)
        array.shift(poolDir)
        array.shift(poolFill)
    array.size(poolLvl)

if usePool and barstate.isconfirmed and (not na(pvH) or not na(pvL))
    float lvl = na(pvH) ? pvL : pvH
    int   dir = na(pvH) ? 1 : -1        // pool below price = demand side, above = supply side
    int   idx = -1
    if array.size(poolLvl) > 0
        for i = 0 to array.size(poolLvl) - 1
            if idx == -1 and array.get(poolDir, i) == dir and math.abs(array.get(poolLvl, i) - lvl) <= tol
                idx := i
    if idx >= 0
        int h = array.get(poolHits, idx) + 1
        array.set(poolHits, idx, h)
        array.set(poolLvl, idx, (array.get(poolLvl, idx) * (h - 1) + lvl) / h)
    else
        array.push(poolLvl, lvl)
        array.push(poolHits, 1)
        array.push(poolDir, dir)
        array.push(poolFill, false)
        array.push(poolLab, label.new(bar_index + poolOff, lvl, "", style = label.style_none,
             textcolor = COL_POOL, size = size.large, text_font_family = font.family_default))
        array.push(poolLn, line.new(bar_index, lvl, bar_index + poolOff, lvl,
             color = color.new(COL_POOL, 62), style = line.style_dotted, width = 1))
        // candidates are kept far deeper than the draw limit: a level only becomes a
        // pool once it has been touched again, and that second touch can be far away
        f_poolTrim(poolMax * 5)

// sweep detection + fill bookkeeping
bool sweepBull = false
bool sweepBear = false
int  drawnPools = 0
if array.size(poolLvl) > 0
    for i = array.size(poolLvl) - 1 to 0
        float lv = array.get(poolLvl, i)
        int   hi = array.get(poolHits, i)
        int   dr = array.get(poolDir, i)
        bool  fl = array.get(poolFill, i)
        bool  live = hi >= poolTouch
        if not fl
            if dr == 1 and low <= lv and close > lv and live
                sweepBull := true
            if dr == -1 and high >= lv and close < lv and live
                sweepBear := true
        if (dr == 1 and close < lv - 0.1 * unit) or (dr == -1 and close > lv + 0.1 * unit)
            array.set(poolFill, i, true)
        // draw / refresh
        label lb = array.get(poolLab, i)
        line  ln = array.get(poolLn, i)
        bool  gone = array.get(poolFill, i) and poolDelete
        if gone
            label.delete(lb)
            line.delete(ln)
            array.remove(poolLvl, i)
            array.remove(poolHits, i)
            array.remove(poolDir, i)
            array.remove(poolFill, i)
            array.remove(poolLab, i)
            array.remove(poolLn, i)
        else if barstate.islast
            bool  wasFilled = array.get(poolFill, i)
            bool  show = live and drawnPools < poolMax
            if show
                drawnPools += 1
            color pc  = wasFilled ? color.new(COL_POOL, 68) : COL_POOL
            int   lnT = show ? (wasFilled ? 88 : 62) : 100
            label.set_x(lb, bar_index + poolOff)
            label.set_y(lb, lv)
            label.set_text(lb, show ? "◀" : "")
            label.set_textcolor(lb, pc)
            line.set_xy1(ln, bar_index - 2, lv)
            line.set_xy2(ln, bar_index + poolOff, lv)
            line.set_color(ln, color.new(COL_POOL, lnT))

// ═══════════════════════ ④ SMART FVGS ══════════════════════════════════════════
var array<box>   fvgBox = array.new<box>()
var array<float> fvgTop = array.new<float>()
var array<float> fvgBot = array.new<float>()
var array<int>   fvgDir = array.new<int>()

f_fvgTrim(int maxN) =>
    while array.size(fvgBox) > maxN
        box.delete(array.shift(fvgBox))
        array.shift(fvgTop)
        array.shift(fvgBot)
        array.shift(fvgDir)
    array.size(fvgBox)

bool inBullFVG = false
bool inBearFVG = false
if array.size(fvgBox) > 0
    for i = array.size(fvgBox) - 1 to 0
        float ft = array.get(fvgTop, i)
        float fb = array.get(fvgBot, i)
        int   fd = array.get(fvgDir, i)
        if low <= ft and high >= fb
            if fd > 0
                inBullFVG := true
            else
                inBearFVG := true
        if (fd > 0 and close < fb) or (fd < 0 and close > ft)
            box.delete(array.get(fvgBox, i))
            array.remove(fvgBox, i)
            array.remove(fvgTop, i)
            array.remove(fvgBot, i)
            array.remove(fvgDir, i)

if useFVG and barstate.isconfirmed
    bool bullGap = low > high[2] and (low - high[2]) >= fvgMin * unit
    bool bearGap = high < low[2] and (low[2] - high) >= fvgMin * unit
    if bullGap or bearGap
        float gt = bullGap ? low : low[2]
        float gb = bullGap ? high[2] : high
        color fc = bullGap ? COL_CYAN : COL_PINK
        box nb = box.new(bar_index - 2, gt, bar_index + 1, gb, border_color = color.new(fc, 55),
             border_width = 1, bgcolor = color.new(fc, 88), extend = extend.right,
             text = "FVG", text_color = color.new(fc, 45), text_size = size.tiny,
             text_halign = text.align_right, text_valign = text.align_center)
        array.push(fvgBox, nb)
        array.push(fvgTop, gt)
        array.push(fvgBot, gb)
        array.push(fvgDir, bullGap ? 1 : -1)
        f_fvgTrim(fvgMax)

// ═══════════════════════ ① SIGNAL ENGINES ══════════════════════════════════════

var int lastSigBar = na
bool coolOn   = cooldownMode == "On"
int  coolLeft = coolOn and not na(lastSigBar) ? math.max(0, cooldownBars - (bar_index - lastSigBar)) : 0
bool coolBlock = coolOn and coolLeft > 0

float extUp = (close - trendLn) / unit
float extDn = (trendLn - close) / unit

// ── Prop Mode ─────────────────────────────────────────────────────────────────
bool propLong  = trendUp and (tapBullKey or tapBullOB) and bullConf and rsi < 72 and extUp < 3.0
bool propShort = not trendUp and (tapBearKey or tapBearOB) and bearConf and rsi > 28 and extDn < 3.0

// ── AI-Mode ───────────────────────────────────────────────────────────────────
float scL = 0.0
scL += trendUp ? 2.0 : -2.0
scL += emaF > emaS ? 1.0 : -1.0
scL += tapBullKey ? 2.0 : 0.0
scL += tapBullOB ? 1.5 : 0.0
scL += sweepBull ? 1.5 : 0.0
scL += inBullFVG ? 1.0 : 0.0
scL += bullConf ? 1.0 : (bearConf ? -1.0 : 0.0)
scL += rsi < 35 ? 0.5 : 0.0

float scS = 0.0
scS += trendUp ? -2.0 : 2.0
scS += emaF < emaS ? 1.0 : -1.0
scS += tapBearKey ? 2.0 : 0.0
scS += tapBearOB ? 1.5 : 0.0
scS += sweepBear ? 1.5 : 0.0
scS += inBearFVG ? 1.0 : 0.0
scS += bearConf ? 1.0 : (bullConf ? -1.0 : 0.0)
scS += rsi > 65 ? 0.5 : 0.0

bool aiLong  = scL >= aiThresh and scL > scS
bool aiShort = scS >= aiThresh and scS > scL

bool rawLong  = stratType == "Prop Mode" ? propLong  : aiLong
bool rawShort = stratType == "Prop Mode" ? propShort : aiShort

// ═══════════════════════ TRADE STATE & DRAWINGS ════════════════════════════════
var float tEntry = na
var float tTP1   = na
var float tTP2   = na
var float tTP3   = na
var float tSL    = na
var int   tDir   = 0
var int   tBar   = na
var bool  tLive  = false
var string tRes  = "—"
var int   cTP1 = 0
var int   cTP2 = 0
var int   cTP3 = 0
var int   cSL  = 0
var int   cAll = 0
var float lastRR = na

var array<box>   tBoxes = array.new<box>()
var array<line>  tLines = array.new<line>()
var array<label> tLbls  = array.new<label>()

f_pushBox(box b, int maxN) =>
    array.push(tBoxes, b)
    while array.size(tBoxes) > maxN
        box.delete(array.shift(tBoxes))
    array.size(tBoxes)

f_pushLine(line l, int maxN) =>
    array.push(tLines, l)
    while array.size(tLines) > maxN
        line.delete(array.shift(tLines))
    array.size(tLines)

f_pushLbl(label l, int maxN) =>
    array.push(tLbls, l)
    while array.size(tLbls) > maxN
        label.delete(array.shift(tLbls))
    array.size(tLbls)

bool fireLong  = rawLong  and not coolBlock and not tLive and barstate.isconfirmed
bool fireShort = rawShort and not coolBlock and not tLive and barstate.isconfirmed

string reasonTxt = ""
if fireLong
    reasonTxt := tapBullKey ? "MAJOR KEY" : tapBullOB ? "ORDER BLOCK" : sweepBull ? "POOL SWEEP" : "MOMENTUM"
if fireShort
    reasonTxt := tapBearKey ? "MAJOR KEY" : tapBearOB ? "ORDER BLOCK" : sweepBear ? "POOL SWEEP" : "MOMENTUM"

if fireLong or fireShort
    tDir   := fireLong ? 1 : -1
    tEntry := close
    tTP1   := tEntry + tDir * minorTP * unit
    tTP2   := tEntry + tDir * majorTP * unit
    tTP3   := tEntry + tDir * highTP  * unit
    tSL    := tEntry - tDir * slMult  * unit
    tBar   := bar_index
    tLive  := true
    tRes   := "RUNNING"
    lastSigBar := bar_index
    lastRR := slMult > 0 ? highTP / slMult : na
    cAll += 1

    color sigCol = tDir > 0 ? COL_BULL : COL_BEAR
    color pillBg = tDir > 0 ? COL_BUYBG : COL_SELLBG

    if showBoxes
        float tpTop = tDir > 0 ? tTP3 : tEntry
        float tpBot = tDir > 0 ? tEntry : tTP3
        float slTop = tDir > 0 ? tEntry : tSL
        float slBot = tDir > 0 ? tSL : tEntry
        f_pushBox(box.new(bar_index, tpTop, bar_index + boxBars, tpBot,
             border_color = color.new(COL_BULL, 60), border_width = 1,
             bgcolor = color.new(COL_BULL, 86)), maxTrades * 2)
        f_pushBox(box.new(bar_index, slTop, bar_index + boxBars, slBot,
             border_color = color.new(COL_BEAR, 60), border_width = 1,
             bgcolor = color.new(COL_BEAR, 86)), maxTrades * 2)
        f_pushLine(line.new(bar_index, tEntry, bar_index + boxBars, tTP3,
             color = color.new(sigCol, 35), style = line.style_dashed, width = 1), maxTrades * 8)

    if showLevels
        f_pushLine(line.new(bar_index, tEntry, bar_index + boxBars, tEntry, color = COL_GOLD, style = line.style_dashed, width = 1), maxTrades * 8)
        f_pushLine(line.new(bar_index, tTP1,   bar_index + boxBars, tTP1,   color = color.new(COL_BULL, 30), style = line.style_dotted, width = 1), maxTrades * 8)
        f_pushLine(line.new(bar_index, tTP2,   bar_index + boxBars, tTP2,   color = color.new(COL_BULL, 15), style = line.style_dotted, width = 1), maxTrades * 8)
        f_pushLine(line.new(bar_index, tTP3,   bar_index + boxBars, tTP3,   color = COL_BULL, style = line.style_dashed, width = 1), maxTrades * 8)
        f_pushLine(line.new(bar_index, tSL,    bar_index + boxBars, tSL,    color = COL_PINK, style = line.style_dashed, width = 1), maxTrades * 8)
        f_pushLbl(label.new(bar_index + boxBars, tEntry, "ENTRY " + str.tostring(tEntry, format.mintick), style = label.style_label_left, color = color.new(COL_BG, 15), textcolor = COL_GOLD, size = size.tiny), maxTrades * 8)
        f_pushLbl(label.new(bar_index + boxBars, tTP3, "TP HIGHEST " + str.tostring(tTP3, format.mintick), style = label.style_label_left, color = color.new(COL_BG, 15), textcolor = COL_BULL, size = size.tiny), maxTrades * 8)
        f_pushLbl(label.new(bar_index + boxBars, tSL, "SL " + str.tostring(tSL, format.mintick), style = label.style_label_left, color = color.new(COL_BG, 15), textcolor = COL_PINK, size = size.tiny), maxTrades * 8)

    if showPills
        string pill = (tDir > 0 ? "  BUY ▲  " : "  SELL ▼  ") + "\n" +
             str.tostring(lastRR, "#.##") + "R · " + reasonTxt
        string tipTxt = (tDir > 0 ? "WHY THIS BUY?" : "WHY THIS SELL?") + "\n" +
             "1) Engine: " + stratType + (stratType == "AI-Mode" ? "  (score " + str.tostring(tDir > 0 ? scL : scS, "#.#") + " / " + str.tostring(aiThresh, "#.#") + ")" : "") + "\n" +
             "2) Trend filter: " + (trendUp ? "bullish" : "bearish") + "\n" +
             "3) Trigger: " + reasonTxt + "\n" +
             "4) Candle: " + (tDir > 0 ? (bullConf ? "bullish confirmation" : "neutral") : (bearConf ? "bearish confirmation" : "neutral")) + "\n" +
             "─────────────\n" +
             "Entry       " + str.tostring(tEntry, format.mintick) + "\n" +
             "TP Minor    " + str.tostring(tTP1, format.mintick) + "\n" +
             "TP Major    " + str.tostring(tTP2, format.mintick) + "\n" +
             "TP Highest  " + str.tostring(tTP3, format.mintick) + "\n" +
             "SL          " + str.tostring(tSL, format.mintick) + "\n" +
             "Volatility unit " + str.tostring(unit, format.mintick) + "  ·  R:R 1:" + str.tostring(lastRR, "#.##")
        f_pushLbl(label.new(bar_index, tDir > 0 ? low : high, pill,
             style = tDir > 0 ? label.style_label_up : label.style_label_down,
             color = pillBg, textcolor = COL_TXT, size = size.small,
             textalign = text.align_center, tooltip = tipTxt), maxTrades * 8)

plotshape(fireLong,  "Long Entry",  shape.triangleup,   location.belowbar, COL_BULL, size = size.tiny, display = display.pane)
plotshape(fireShort, "Short Entry", shape.triangledown, location.abovebar, COL_BEAR, size = size.tiny, display = display.pane)

// ── outcome tracking ──────────────────────────────────────────────────────────
bool hitTP1 = false
bool hitTP2 = false
bool hitTP3 = false
bool hitSL  = false
var bool got1 = false
var bool got2 = false

if tLive and not (fireLong or fireShort)
    if tDir > 0
        if not got1 and high >= tTP1
            got1 := true
            hitTP1 := true
            cTP1 += 1
        if not got2 and high >= tTP2
            got2 := true
            hitTP2 := true
            cTP2 += 1
        if high >= tTP3
            hitTP3 := true
            cTP3 += 1
            tRes := "TP HIGHEST"
            tLive := false
        else if low <= tSL
            hitSL := true
            cSL += 1
            tRes := "SL"
            tLive := false
    else
        if not got1 and low <= tTP1
            got1 := true
            hitTP1 := true
            cTP1 += 1
        if not got2 and low <= tTP2
            got2 := true
            hitTP2 := true
            cTP2 += 1
        if low <= tTP3
            hitTP3 := true
            cTP3 += 1
            tRes := "TP HIGHEST"
            tLive := false
        else if high >= tSL
            hitSL := true
            cSL += 1
            tRes := "SL"
            tLive := false

if fireLong or fireShort
    got1 := false
    got2 := false

// ═══════════════════════ ALERTS ════════════════════════════════════════════════
f_msg(string ev) =>
    string side = tDir > 0 ? "LONG" : "SHORT"
    string out = ""
    if alJson
        out := '{"event":"' + ev + '","symbol":"' + syminfo.ticker + '","tf":"' + timeframe.period + '"'
        out := out + ',"side":"' + side + '","entry":' + str.tostring(tEntry, format.mintick)
        out := out + ',"tp_minor":' + str.tostring(tTP1, format.mintick)
        out := out + ',"tp_major":' + str.tostring(tTP2, format.mintick)
        out := out + ',"tp_highest":' + str.tostring(tTP3, format.mintick)
        out := out + ',"sl":' + str.tostring(tSL, format.mintick)
        out := out + ',"rr":' + str.tostring(lastRR, "#.##") + '}'
    else
        out := ev + " " + side + " " + syminfo.ticker + " " + timeframe.period
        out := out + " | entry " + str.tostring(tEntry, format.mintick)
        out := out + " | TP " + str.tostring(tTP1, format.mintick) + " / " + str.tostring(tTP2, format.mintick) + " / " + str.tostring(tTP3, format.mintick)
        out := out + " | SL " + str.tostring(tSL, format.mintick) + " | R:R 1:" + str.tostring(lastRR, "#.##")
    out

if alEntry and (fireLong or fireShort)
    alert(f_msg("ENTRY"), alert.freq_once_per_bar_close)
if alTP and (hitTP1 or hitTP2 or hitTP3)
    alert(f_msg(hitTP3 ? "TP_HIGHEST" : hitTP2 ? "TP_MAJOR" : "TP_MINOR"), alert.freq_once_per_bar_close)
if alSL and hitSL
    alert(f_msg("SL_HIT"), alert.freq_once_per_bar_close)

alertcondition(fireLong,  "Long Entry",  "Prop Key Levels: LONG {{ticker}} @ {{close}}")
alertcondition(fireShort, "Short Entry", "Prop Key Levels: SHORT {{ticker}} @ {{close}}")
alertcondition(hitTP1 or hitTP2 or hitTP3, "Take Profit hit", "Prop Key Levels: take profit hit {{ticker}}")
alertcondition(hitSL, "Stop hit", "Prop Key Levels: stop hit {{ticker}}")

// ═══════════════════════ TRADE METRICS TABLE ═══════════════════════════════════
var table mt = na
if showMetrics == "On" and barstate.islast
    if na(mt)
        mt := table.new(position.bottom_right, 2, 8, bgcolor = color.new(COL_PANEL, 0),
             frame_color = color.new(COL_CYAN, 40), frame_width = 1,
             border_color = color.new(COL_CYAN, 82), border_width = 1)
    bool hasT = not na(tEntry)
    string sideTxt = na(tDir) or tDir == 0 ? "No Entry" : (tDir > 0 ? "Long Entry" : "Short Entry")
    color  sideCol = tDir > 0 ? COL_BULL : tDir < 0 ? COL_BEAR : COL_GREY
    table.cell(mt, 0, 0, sideTxt, text_color = sideCol, text_size = size.small, text_halign = text.align_left, bgcolor = color.new(COL_PANEL, 0))
    table.cell(mt, 1, 0, hasT ? str.tostring(tEntry, format.mintick) : "—", text_color = COL_TXT, text_size = size.small, text_halign = text.align_right, bgcolor = color.new(COL_PANEL, 0))
    table.cell(mt, 0, 1, "TP Minor", text_color = COL_GREY, text_size = size.small, text_halign = text.align_left, bgcolor = color.new(COL_PANEL, 0))
    table.cell(mt, 1, 1, hasT ? str.tostring(tTP1, format.mintick) : "—", text_color = COL_BULL, text_size = size.small, text_halign = text.align_right, bgcolor = color.new(COL_PANEL, 0))
    table.cell(mt, 0, 2, "TP Major", text_color = COL_GREY, text_size = size.small, text_halign = text.align_left, bgcolor = color.new(COL_PANEL, 0))
    table.cell(mt, 1, 2, hasT ? str.tostring(tTP2, format.mintick) : "—", text_color = COL_BULL, text_size = size.small, text_halign = text.align_right, bgcolor = color.new(COL_PANEL, 0))
    table.cell(mt, 0, 3, "TP Highest", text_color = COL_GREY, text_size = size.small, text_halign = text.align_left, bgcolor = color.new(COL_PANEL, 0))
    table.cell(mt, 1, 3, hasT ? str.tostring(tTP3, format.mintick) : "—", text_color = COL_BULL, text_size = size.small, text_halign = text.align_right, bgcolor = color.new(COL_PANEL, 0))
    table.cell(mt, 0, 4, "SL", text_color = COL_BEAR, text_size = size.small, text_halign = text.align_left, bgcolor = color.new(COL_PANEL, 0))
    table.cell(mt, 1, 4, hasT ? str.tostring(tSL, format.mintick) : "—", text_color = COL_BEAR, text_size = size.small, text_halign = text.align_right, bgcolor = color.new(COL_PANEL, 0))
    table.cell(mt, 0, 5, "R : R", text_color = COL_GREY, text_size = size.small, text_halign = text.align_left, bgcolor = color.new(COL_PANEL, 0))
    table.cell(mt, 1, 5, hasT ? "1 : " + str.tostring(lastRR, "#.##") : "—", text_color = COL_GOLD, text_size = size.small, text_halign = text.align_right, bgcolor = color.new(COL_PANEL, 0))
    table.cell(mt, 0, 6, "Status", text_color = COL_GREY, text_size = size.small, text_halign = text.align_left, bgcolor = color.new(COL_PANEL, 0))
    table.cell(mt, 1, 6, tRes, text_color = tRes == "SL" ? COL_BEAR : tRes == "RUNNING" ? COL_GOLD : tRes == "—" ? COL_GREY : COL_BULL, text_size = size.small, text_halign = text.align_right, bgcolor = color.new(COL_PANEL, 0))
    table.cell(mt, 0, 7, "Cooldown Mode", text_color = COL_GREY, text_size = size.small, text_halign = text.align_left, bgcolor = color.new(COL_PANEL, 0))
    table.cell(mt, 1, 7, coolOn ? (coolBlock ? "WAIT " + str.tostring(coolLeft) : "ON") : "OFF", text_color = coolOn ? (coolBlock ? COL_GOLD : COL_BULL) : COL_GREY, text_size = size.small, text_halign = text.align_right, bgcolor = color.new(COL_PANEL, 0))

// ═══════════════════════ COCKPIT PANEL ═════════════════════════════════════════
varip int glint = 0
if barstate.isrealtime
    glint += 1

f_pos() =>
    switch panelPos
        "Middle Left"  => position.middle_left
        "Top Left"     => position.top_left
        "Bottom Left"  => position.bottom_left
        "Top Right"    => position.top_right
        "Middle Right" => position.middle_right
        => position.bottom_right

f_check(table t, int r, string num, string title, string status, color stCol) =>
    table.cell(t, 0, r, num, text_color = COL_GOLD, text_size = size.small, bgcolor = color.new(COL_PANEL, 0), text_halign = text.align_center)
    table.cell(t, 1, r, title, text_color = COL_TXT, text_size = size.tiny, bgcolor = color.new(COL_PANEL, 0), text_halign = text.align_left)
    table.cell(t, 4, r, status, text_color = stCol, text_size = size.small, bgcolor = color.new(COL_PANEL, 0), text_halign = text.align_right)

int liveKeys  = 0
int liveOB    = array.size(obBox)
int liveFVG   = array.size(fvgBox)
int livePools = 0
if array.size(keyState) > 0
    for i = 0 to array.size(keyState) - 1
        if array.get(keyState, i) < 2
            liveKeys += 1
if array.size(poolHits) > 0
    for i = 0 to array.size(poolHits) - 1
        if array.get(poolHits, i) >= poolTouch and not array.get(poolFill, i)
            livePools += 1

var table pan = na
if showPanel and barstate.islast
    if na(pan)
        pan := table.new(f_pos(), 6, 24, bgcolor = color.new(COL_PANEL, 0),
             frame_color = COL_CYAN, frame_width = 2,
             border_color = color.new(COL_CYAN, 88), border_width = 1)
        for r = 0 to 23
            for c = 0 to 5
                table.cell(pan, c, r, "", bgcolor = color.new(COL_PANEL, 0), text_size = size.tiny)
        table.merge_cells(pan, 0, 0, 4, 0)
        table.merge_cells(pan, 0, 1, 5, 1)
        table.cell(pan, 0, 2, "", bgcolor = color.new(COL_BG, 0))
        table.merge_cells(pan, 0, 2, 5, 2)
        table.merge_cells(pan, 0, 4, 5, 4)
        table.cell(pan, 0, 5, "", bgcolor = color.new(COL_BG, 0))
        table.merge_cells(pan, 0, 5, 5, 5)
        table.merge_cells(pan, 1, 6, 2, 6)
        table.merge_cells(pan, 4, 6, 5, 6)
        table.merge_cells(pan, 1, 7, 2, 7)
        table.merge_cells(pan, 4, 7, 5, 7)
        table.cell(pan, 0, 8, "", bgcolor = color.new(COL_BG, 0))
        table.merge_cells(pan, 0, 8, 5, 8)
        table.merge_cells(pan, 0, 9, 5, 9)
        for r = 10 to 15
            table.merge_cells(pan, 1, r, 3, r)
            table.merge_cells(pan, 4, r, 5, r)
        table.cell(pan, 0, 16, "", bgcolor = color.new(COL_BG, 0))
        table.merge_cells(pan, 0, 16, 5, 16)
        table.merge_cells(pan, 0, 17, 5, 17)
        table.merge_cells(pan, 0, 18, 5, 18)
        table.cell(pan, 0, 19, "", bgcolor = color.new(COL_BG, 0))
        table.merge_cells(pan, 0, 19, 5, 19)
        table.merge_cells(pan, 0, 20, 5, 20)
        table.merge_cells(pan, 0, 21, 5, 21)
        table.merge_cells(pan, 0, 22, 5, 22)
        table.merge_cells(pan, 0, 23, 5, 23)

    // ── header ──
    table.cell(pan, 0, 0, "PROP KEY LEVEL ENGINE", text_color = COL_GOLD, text_size = size.normal,
         bgcolor = color.new(COL_PANEL, 0), text_halign = text.align_left, text_font_family = font.family_monospace)
    table.cell(pan, 5, 0, glint % 2 == 0 ? "●" : "○", text_color = COL_CYAN, text_size = size.small,
         bgcolor = color.new(COL_PANEL, 0), text_halign = text.align_right)
    table.cell(pan, 0, 1, "KEYS · ORDER BLOCKS · POOLS · FVG", text_color = COL_CYAN, text_size = size.tiny,
         bgcolor = color.new(COL_PANEL, 0), text_halign = text.align_center)

    // ── animated marker row ──
    int gcol = glint % 6
    for c = 0 to 5
        table.cell(pan, c, 3, c == gcol ? "▲" : "△",
             text_color = c == gcol ? COL_GOLD : color.new(COL_BULL, 45),
             text_size = size.tiny, bgcolor = color.new(COL_PANEL, 0), text_halign = text.align_center)

    // ── status chip ──
    string chip = tLive ? (tDir > 0 ? "◆  LONG POSITION RUNNING  ◆" : "◆  SHORT POSITION RUNNING  ◆")
         : coolBlock ? "◆  COOLDOWN · " + str.tostring(coolLeft) + " BARS  ◆"
         : "◆  SCANNING FOR SETUP  ◆"
    table.cell(pan, 0, 4, chip, text_color = tLive ? COL_GOLD : coolBlock ? COL_PINK : COL_CYAN,
         text_size = size.small, bgcolor = color.new(COL_PANEL2, 0), text_halign = text.align_center)

    // ── info grid ──
    table.cell(pan, 0, 6, "TF", text_color = COL_GREY, text_size = size.tiny, bgcolor = color.new(COL_PANEL, 0), text_halign = text.align_left)
    table.cell(pan, 1, 6, timeframe.period, text_color = COL_TXT, text_size = size.tiny, bgcolor = color.new(COL_PANEL, 0), text_halign = text.align_left)
    table.cell(pan, 3, 6, "SYMBOL", text_color = COL_GREY, text_size = size.tiny, bgcolor = color.new(COL_PANEL, 0), text_halign = text.align_right)
    table.cell(pan, 4, 6, syminfo.ticker, text_color = COL_TXT, text_size = size.tiny, bgcolor = color.new(COL_PANEL, 0), text_halign = text.align_right)
    table.cell(pan, 0, 7, "MODE", text_color = COL_GREY, text_size = size.tiny, bgcolor = color.new(COL_PANEL, 0), text_halign = text.align_left)
    table.cell(pan, 1, 7, stratType, text_color = COL_GOLD, text_size = size.tiny, bgcolor = color.new(COL_PANEL, 0), text_halign = text.align_left)
    table.cell(pan, 3, 7, "UNIT", text_color = COL_GREY, text_size = size.tiny, bgcolor = color.new(COL_PANEL, 0), text_halign = text.align_right)
    table.cell(pan, 4, 7, str.tostring(unit, format.mintick), text_color = COL_TXT, text_size = size.tiny, bgcolor = color.new(COL_PANEL, 0), text_halign = text.align_right)

    // ── checklist ──
    table.cell(pan, 0, 9, "CHECKLIST", text_color = COL_CYAN, text_size = size.tiny,
         bgcolor = color.new(COL_PANEL, 0), text_halign = text.align_left)
    f_check(pan, 10, "❶", "TREND", trendUp ? "BULL" : "BEAR", trendUp ? COL_BULL : COL_BEAR)
    f_check(pan, 11, "❷", "MAJOR KEY", tapBullKey ? "BULL TAP" : tapBearKey ? "BEAR TAP" : "‥", tapBullKey ? COL_BULL : tapBearKey ? COL_BEAR : COL_GREY)
    f_check(pan, 12, "❸", "ORDER BLOCK", tapBullOB ? "BULL TAP" : tapBearOB ? "BEAR TAP" : "‥", tapBullOB ? COL_BULL : tapBearOB ? COL_BEAR : COL_GREY)
    f_check(pan, 13, "❹", "ORDER POOL", sweepBull ? "SWEEP UP" : sweepBear ? "SWEEP DN" : "‥", sweepBull ? COL_BULL : sweepBear ? COL_BEAR : COL_GREY)
    f_check(pan, 14, "❺", "CANDLE", bullConf ? "BULL" : bearConf ? "BEAR" : "‥", bullConf ? COL_BULL : bearConf ? COL_BEAR : COL_GREY)
    f_check(pan, 15, "❻", "COOLDOWN", coolOn ? (coolBlock ? "WAIT " + str.tostring(coolLeft) : "READY") : "OFF", coolOn ? (coolBlock ? COL_PINK : COL_BULL) : COL_GREY)

    // ── position box ──
    table.cell(pan, 0, 17, "POSITION", text_color = COL_CYAN, text_size = size.tiny,
         bgcolor = color.new(COL_PANEL, 0), text_halign = text.align_left)
    string posTxt = na(tEntry) ? "NO POSITION"
         : (tDir > 0 ? "LONG  " : "SHORT ") + str.tostring(tEntry, format.mintick) +
           "   SL " + str.tostring(tSL, format.mintick) +
           "   TP " + str.tostring(tTP3, format.mintick)
    table.cell(pan, 0, 18, posTxt, text_color = na(tEntry) ? COL_GREY : COL_TXT, text_size = size.tiny,
         bgcolor = color.new(COL_PANEL2, 0), text_halign = text.align_left, text_font_family = font.family_monospace)

    // ── big signal row ──
    string bigTxt = tRes == "TP HIGHEST" ? "TP HIT" : tRes == "SL" ? "SL HIT" : tLive ? (tDir > 0 ? "LONG ACTIVE" : "SHORT ACTIVE") : "STANDBY"
    color  bigCol = tRes == "TP HIGHEST" ? COL_BULL : tRes == "SL" ? COL_BEAR : tLive ? COL_GOLD : COL_GREY
    table.cell(pan, 0, 20, bigTxt, text_color = bigCol, text_size = size.large,
         bgcolor = color.new(COL_PANEL, 0), text_halign = text.align_center, text_font_family = font.family_monospace)

    // ── counters + stats ──
    table.cell(pan, 0, 21, "KEYS " + str.tostring(liveKeys) + "  ·  OB " + str.tostring(liveOB) +
         "  ·  POOLS " + str.tostring(livePools) + "  ·  FVG " + str.tostring(liveFVG),
         text_color = COL_LIME, text_size = size.tiny, bgcolor = color.new(COL_PANEL, 0), text_halign = text.align_center)
    float wr = cAll > 0 ? (cTP3 * 100.0) / cAll : na
    table.cell(pan, 0, 22, "TP1 " + str.tostring(cTP1) + "  ·  TP2 " + str.tostring(cTP2) +
         "  ·  TP3 " + str.tostring(cTP3) + "  ·  SL " + str.tostring(cSL),
         text_color = COL_TXT, text_size = size.tiny, bgcolor = color.new(COL_PANEL, 0), text_halign = text.align_center)
    table.cell(pan, 0, 23, "● " + str.tostring(cAll) + " SIGNALS  ·  RUNNER HIT " +
         (na(wr) ? "—" : str.tostring(wr, "#.#") + "%"),
         text_color = COL_CYAN, text_size = size.tiny, bgcolor = color.new(COL_PANEL, 0), text_halign = text.align_center)
````
