# TL Space Concept Pro - Three Finger Spread Breakout Engine

- url: https://www.tradingview.com/script/mLrUb6ZP-TL-Space-Concept-Pro-Three-Finger-Spread-Breakout-Engine/
- type: indicator
- pine_id: PUB;d25ce35a5d7f4d48a8662aacb323cdc1
- version: 5.0

## Description

SPACE CONCEPT PRO - THE THREE-FINGER SPREAD ENGINE

Some of the most consistent discretionary traders never look at a chart without two moving averages on it: the 20 SMA and the 200 SMA. Add price itself and you have THREE ITEMS - three "fingers". The distance between them is called SPACE, and space tells you when a market is about to explode and when a move is about to die. This indicator turns that entire concept into a fully mechanical engine with signals, trade management and webhook automation.

=== THE CONCEPT ===

THE THREE ITEMS
1. Price
2. The 20 period simple moving average
3. The 200 period simple moving average

NARROW STATE - all three items clustered together. The market has reset itself. An explosive move is loading, direction unknown. You do not need to predict it: you simply wait for the biggest bar to emerge.

SPACE ZONE 1 - the space between the 20 SMA and the 200 SMA.

SPACE ZONE 2 - price accelerating away from the 20 SMA. Sometimes the underlying moves faster than the moving average can keep up, creating a second layer of space.

DUAL SPACE / THREE-FINGER SPREAD - both zones open at the same time, all three fingers clearly separated and stacked in order. This is where moves get exhausted.

THE RAILROAD RULE - if price runs parallel to the 20 SMA like railroad tracks, that is NOT a spread. Price has to ACCELERATE away from the moving average. The engine checks this automatically.

THE WIDEST SPREAD - the widest three-finger spread of the lookback window finds you the temporary top or bottom 8 to 9 times out of 10. When it prints, the reversal watch arms and the extreme that must hold is marked on the chart.

NARROW TO NARROW - when the spread collapses from the widest state back to narrow WITHOUT breaking the extreme, the next direction is the reversal. Confirmed by a power bar: a three-finger spread reversing with a power bar is the creme de la creme of this method.

=== THE SIGNALS ===

1. BREAKOUT - power bar (biggest bar of the window) exploding out of a narrow state. Entry inside the bar, stop beyond the bar.
2. SPREAD REVERSAL - widest spread found the extreme, spread collapsed back toward narrow without breaking it, power bar confirms. Target follows the 50 percent rule.
3. EARLY REVERSAL - first strong color change directly at the widest spread (the bottoming tail bar play). Stop beyond the extreme.
4. TAIL BAR - optional: bottoming/topping tail bars near narrow states as early entries (markers by default).

Every signal prints as a two-line pill with the setup name, and every pill carries a WHY tooltip that explains the exact chain of logic behind the trade - plus entry, stop, target and R:R.

=== TRADE MANAGEMENT (AS TAUGHT) ===

- ADD on the first color change after entry ("always adding on the first color change")
- TP at the 50 percent mark of the move - the pros are satisfied with the halfway mark, do not get greedy
- After the partial: bar-by-bar trailing stop until the market takes you out
- Hard stop beyond the power bar / spread extreme with an ATR buffer
- Full position box and live status in the cockpit panel

=== THE COCKPIT ===

An animated terminal-style panel shows everything at a glance:
- Animated 3D gold pixel logo with a moving light sweep (live ticks)
- State chip: NARROW STATE / 3-FINGER SPREAD / WIDEST SPREAD / REVERSAL WATCH
- Spread rank 0-100 plus live ZONE 1 / ZONE 2 meter bars in ATR
- 7-step SPACE CHECKLIST mirroring the method: items stacked, zone 1, zone 2, acceleration (railroad filter), widest-spread watch, power bar, management
- Position box, big signal line, spread/reset/signal counters

On the chart: shaded zone 1 and zone 2 fills, narrow-state boxes, MARKET RESET tags, 3-FINGER SPREAD labels, gold WIDEST SPREAD stars with vertical measuring lines (exactly how it is drawn when taught), the must-hold extreme line, TAIL tags and lightning power-bar markers. Everything is explained on the chart - hover any label for the reasoning.

=== AUTOMATION / WEBHOOK ===

Create ONE alert with condition "Any alert() function call" and paste your webhook URL. The indicator sends ready-to-use JSON for every event:

{"id":"TL-SPACE-CONCEPT","symbol":"BTCUSD","action":"BUY","setup":"BREAKOUT","price":64100.5,"sl":63900.0,"tp":64500.0,"tf":"15","time":"2026-07-18 16:30"}

Actions: BUY, SELL, ADD, TP_50, TRAIL_EXIT, SL_HIT, NARROW_STATE, WIDEST_SPREAD. Classic alertconditions for BUY / SELL / Narrow State / Widest Spread are included as well.

=== SELF-CALIBRATING ===

The spread is ranked against its own history (percentile engine) and all distances are measured in ATR - so the indicator works out of the box on any market (crypto, forex, gold, indices, stocks, futures) and any timeframe from 1 minute to weekly. Practice finding three-finger spreads everywhere - that is the homework.

=== SETTINGS ===

Every input is documented with a tooltip quoting the original rule it implements. Adjust the narrow/wide percentiles, power-bar size, dual-space minimum, acceleration window, 50 percent rule targets and the SL buffer to fit your market and style.

=== DISCLAIMER ===

Educational tool, not financial advice. No indicator wins every trade - prepare for the 1-2 times out of 10 the concept is wrong: keep your risk unit small compared to your profit unit. That is how you stay in business.

## Source Code

````pine
//@version=6
// ═══════════════════════════════════════════════════════════════════════════════
//   SPACE CONCEPT PRO  v1.0
//  1:1 rebuild of the "Space Concept / Three-Finger Spread" method
//  (taught live on a 15m BTC + 2m NVDA/MSFT/META/MU charts) as a
//  TradingView indicator in a dark cockpit design.
//
//  The three items (video): ① PRICE  ② 20 SMA  ③ 200 SMA
//  Rules from the video:
//   • NARROW STATE   = all three items clustered together -> market reset,
//                      an explosive move is loading. Direction unknown until
//                      the biggest bar (POWER BAR) emerges.
//   • SPACE ZONE 1   = space between the 20 SMA and the 200 SMA
//   • SPACE ZONE 2   = price ACCELERATES away from the 20 SMA
//   • DUAL SPACE     = zone 1 + zone 2 together = THREE-FINGER SPREAD
//   • RAILROAD RULE  = price running parallel to the 20 SMA is NOT a spread —
//                      price must accelerate away from the moving average
//   • WIDEST SPREAD  = 8-9 times out of 10 you are at / near a temporary
//                      top or bottom -> reversal watch armed
//   • NARROW→NARROW  = spread collapses back to narrow WITHOUT breaking the
//                      extreme -> next direction is the reversal. Confirmed
//                      by a power bar ("three-finger spread reversing with a
//                      power bar — the creme de la creme")
//   • ENTRY          = inside the power bar, stop beyond the power bar
//   • ADD-ON         = "always adding on the first color change"
//   • 50% RULE       = pros take profit at the halfway mark of the move —
//                      "don't get greedy like a little tiny piggy"
//   • EXITS          = incremental: partial at 50%, rest bar-by-bar trailing
//   • TAIL BAR       = bottoming/topping tail bar at a narrow state = early play
// ═══════════════════════════════════════════════════════════════════════════════

//  v2 - House Rules compliance: no logo, no brand or company names, no external links.

//  v3 - Fix: the theme margin box no longer stretches the price scale.
indicator("Three Finger Spread Breakout", "3F SPREAD BREAKOUT", overlay = true,
     max_boxes_count = 500, max_labels_count = 500, max_lines_count = 500)

// ─────────────────────────────── PALETTE ───────────────────────────────────
color COL_BG     = color.rgb(6, 17, 30)      // navy outer
color COL_PANEL  = color.rgb(10, 29, 46)     // panel glass
color COL_PANEL2 = color.rgb(15, 44, 66)     // panel section
color COL_BULL   = color.rgb(126, 224, 208)  // mint
color COL_BEAR   = color.rgb(244, 44, 58)    // red
color COL_CYAN   = color.rgb(53, 200, 255)
color COL_GOLD   = color.rgb(255, 215, 40)
color COL_GOLD2  = color.rgb(255, 236, 130)
color COL_GOLD3  = color.rgb(238, 190, 30)
color COL_GOLD4  = color.rgb(210, 160, 20)
color COL_GOLD5  = color.rgb(170, 125, 12)
color COL_GLINT  = color.rgb(255, 252, 214)
color COL_PINK   = color.rgb(255, 62, 130)
color COL_LIME   = color.rgb(214, 228, 78)
color COL_SELLBG = color.rgb(126, 32, 36)
color COL_BUYBG  = color.rgb(120, 154, 52)
color COL_TXT    = color.rgb(235, 235, 235)
color COL_GREY   = color.rgb(176, 182, 192)

// ─────────────────────────────── INPUTS ───────────────────────────────────────
grpM = "① The Three Items (video: price + 20 SMA + 200 SMA)"
len20      = input.int(20, "Fast SMA (item ②)", minval = 2, group = grpM, tooltip = "Video: 'The blue line is the 20 period moving average. I do not ever look at a chart without these two moving averages.'")
len200     = input.int(200, "Slow SMA (item ③)", minval = 20, group = grpM, tooltip = "Video: 'And of course, the red one is the 200 period moving average. A chart is not a chart unless I'm looking at it through the eyes of these two moving averages.'")
showZones  = input.bool(true, "Shade space zone 1 + zone 2", group = grpM, tooltip = "Zone 1 = space between 20 and 200 SMA. Zone 2 = space between price and the 20 SMA ('sometimes your stock accelerates faster than the moving average can keep up — a second layer of space').")

grpE = "② Space Engine (narrow / wide / widest)"
rankLB     = input.int(250, "Spread ranking lookback (bars)", minval = 50, maxval = 500, group = grpE, tooltip = "The total spread (zone1 + zone2) is ranked against this many past bars so the engine self-calibrates on every symbol and timeframe.")
narrowPct  = input.int(25, "NARROW state: spread rank below (%)", minval = 5, maxval = 45, group = grpE, tooltip = "Video: 'Here all three of them are close. That is what we call a narrow state.' The market resets itself here — the explosive move loads. 'They don't have to be touching, they just have to be relatively close.'")
widePct    = input.int(75, "WIDE state: spread rank above (%)", minval = 55, maxval = 95, group = grpE, tooltip = "Video: 'Here none of them are close. This is what we call a wide state with two zones of space. We call this dual space.'")
dualMinATR = input.float(0.75, "Dual space: min zone width (ATR)", minval = 0.1, step = 0.05, group = grpE, tooltip = "BOTH zones (20↔200 and price↔20) must be at least this wide (in ATR) before it counts as a three-finger spread. 'They don't have to be touching, they just have to be relatively close' — and for a spread, clearly apart.")
accelBars  = input.int(3, "Acceleration check (bars)", minval = 1, maxval = 10, group = grpE, tooltip = "RAILROAD RULE — video: 'If your moving average is almost parallel with the stock, that's NOT a spread. Your stock has to ACCELERATE away from that moving average.' Zone 2 must be wider now than it was this many bars ago.")
widestLB   = input.int(200, "WIDEST spread lookback (bars)", minval = 50, maxval = 500, group = grpE, tooltip = "A new maximum of the total spread inside this window = the WIDEST three-finger spread. Video: 'The widest three-finger spread will 8 to 9 times out of every 10 find you the bottom and the top.'")
showMeasure = input.bool(true, "Draw spread measuring lines (like in the video)", group = grpE, tooltip = "Vertical gold line through price → 200 SMA at every fresh widest spread — exactly how it was drawn on the whiteboard chart.")

grpP = "③ Power Bar + Tail Bar"
pbMult     = input.float(1.5, "Power bar: min size (x avg range)", minval = 1.0, step = 0.1, group = grpP, tooltip = "Video: 'You just have to see when the biggest bar emerges. Look at when the biggest red bar of the day occurs — it's bigger than all of them.'")
pbLook     = input.int(10, "Power bar: biggest of last N bars", minval = 3, maxval = 100, group = grpP)
brkWin     = input.int(8, "Breakout window after narrow (bars)", minval = 1, maxval = 20, group = grpP, tooltip = "A power bar within this many bars after a narrow state = breakout play ('out of this narrow state, what bar emerges as the most powerful? Boom.').")
revEarly   = input.bool(true, "Early reversal: first color change at widest spread", group = grpP, tooltip = "Video: the traders enter right AT the widest spread — bottoming tail bar / 'they add on the first color change'. First strong candle flipping against the spread direction within a few bars of the widest spread fires an early reversal signal.")
earlyWin   = input.int(8, "Early reversal window (bars after widest)", minval = 2, maxval = 30, group = grpP)
tailPct    = input.float(0.6, "Tail bar: wick ≥ (fraction of range)", minval = 0.3, maxval = 0.9, step = 0.05, group = grpP, tooltip = "Video: 'A bunch of traders took the bottoming tail bar play' — a long tail at/near a narrow state.")
showTail   = input.bool(true, "Mark tail bars near narrow states", group = grpP)
tailEntry  = input.bool(false, "Tail bar = early entry signal", group = grpP, tooltip = "OFF = marker only (default). ON = the bottoming/topping tail bar near a narrow state fires an early BUY/SELL like the traders in the video did.")

grpT = "④ Signals & Trade Management (50% rule + trailing)"
showSignals = input.bool(true, "BUY/SELL signals active", group = grpT)
tpR        = input.float(2.0, "Breakout play: TP distance (R)", minval = 0.5, step = 0.25, group = grpT, tooltip = "Target for narrow-state breakout plays, measured in risk units. Video: 'How many of those risk units fit inside of your reward unit? A lot of them. That's how you stay in business.'")
useAdd     = input.bool(true, "ADD on first color change", group = grpT, tooltip = "Video: 'Always adding on the first color change.' After entry, the first candle that flips back into trade direction (after at least one opposing candle) prints an ADD.")
useTrail   = input.bool(true, "Bar-by-bar trailing after 50% TP", group = grpT, tooltip = "Video: Ari 'takes two off and the other one follows a bar-by-bar trailing stop. Boom. Out right there.'")
slBufATR   = input.float(0.15, "SL buffer (ATR)", minval = 0.0, step = 0.05, group = grpT, tooltip = "Stop goes beyond the power bar / beyond the spread extreme, plus this buffer.")

grpD = "⑤ Design"
useTheme    = input.bool(true, "Dark chart theme (navy + mint/red candles)", group = grpD)
showPanel   = input.bool(true, "Show Cockpit panel", group = grpD)
panelPos    = input.string("Middle Left", "Panel position", options = ["Middle Left", "Top Left", "Bottom Left", "Top Right", "Middle Right", "Bottom Right"], group = grpD)

grpA = "⑥ Alerts & Webhook (Automation)"
alSignals   = input.bool(true, "Alert on BUY/SELL (webhook JSON)", group = grpA, tooltip = "Create an alert with condition 'Any alert() function call' and paste your webhook URL into the alert. The message is ready-to-use JSON for bots/bridges.")
alState     = input.bool(false, "Alert on NARROW / WIDEST spread", group = grpA)
alManage    = input.bool(true, "Alert on ADD / TP50 / TRAIL / SL", group = grpA)
whId        = input.string("SPACE-CONCEPT", "Webhook strategy ID", group = grpA)

// ─────────────────────────────── BASICS ────────────────────────────────────────
float atrN = ta.atr(14)
float slBuffer = math.max(slBufATR * atrN, syminfo.mintick * 2)
bool proc = barstate.isconfirmed

// Chart theme + navy future margin (paints the area right of the last candle)
bgcolor(useTheme ? color.new(COL_BG, 0) : na)
barcolor(useTheme ? (close >= open ? COL_BULL : COL_BEAR) : na)
float hh500 = ta.highest(high, 500)
float ll500 = ta.lowest(low, 500)

var box marginBox = na
if useTheme and na(marginBox)
    marginBox := box.new(bar_index + 1, high * 1.02, bar_index + 500, low * 0.98, border_color = color.new(COL_BG, 0), border_width = 1, bgcolor = color.new(COL_BG, 0))
if useTheme and not na(marginBox) and barstate.islast
    box.set_left(marginBox, bar_index + 1)
    box.set_right(marginBox, bar_index + 500)
    box.set_top(marginBox, hh500 * 1.02)
    box.set_bottom(marginBox, ll500 * 0.98)

// ─────────────────────────── SPACE ENGINE ─────────────────────────────────────
float ma20  = ta.sma(close, len20)
float ma200 = ta.sma(close, len200)

// the two zones of space (video: zone 1 = 20↔200, zone 2 = price↔20)
float z1 = math.abs(ma20 - ma200)
float z2 = math.abs(close - ma20)
float spreadTotal = z1 + z2

// three fingers stacked in order = a real spread direction
bool stackBull = close > ma20 and ma20 > ma200
bool stackBear = close < ma20 and ma20 < ma200

// self-calibrating rank of the total spread (works on any symbol / timeframe)
float spreadRank = ta.percentrank(spreadTotal, rankLB)

// RAILROAD RULE: price must accelerate away from the 20 — parallel is NOT a spread
bool accelOK = z2 > z2[accelBars] and z2 > 0.25 * atrN

// states
bool narrowState = spreadRank <= narrowPct
bool wideState   = spreadRank >= widePct and (stackBull or stackBear)
bool dualSpace   = wideState and z1 >= dualMinATR * atrN and z2 >= dualMinATR * atrN
bool threeFinger = dualSpace and accelOK
float hiSpread   = ta.highest(spreadTotal, widestLB)   // hoisted: must run on every bar
bool widestNow   = threeFinger and spreadTotal >= hiSpread

// power bar (video: "the biggest bar emerges")
float barRange = high - low
float avgRange = ta.sma(barRange, 20)
float hiRange     = ta.highest(barRange, pbLook)       // hoisted: must run on every bar
bool powerBar     = barRange >= pbMult * avgRange and barRange >= hiRange
bool powerBull    = powerBar and close > open
bool powerBear    = powerBar and close < open
// strong bar = softer confirmation for reversal plays (first color change with conviction)
bool strongBull   = close > open and barRange >= 1.2 * avgRange and close > close[1]
bool strongBear   = close < open and barRange >= 1.2 * avgRange and close < close[1]

// tail bars (video: bottoming tail bar play)
bool tailBull = barRange > 0 and (math.min(open, close) - low) >= tailPct * barRange and close >= open
bool tailBear = barRange > 0 and (high - math.max(open, close)) >= tailPct * barRange and close <= open

// breakout window: power bar shortly after / inside a narrow state
int sinceNarrow = ta.barssince(narrowState)
bool narrowRecent = narrowState or (not na(sinceNarrow) and sinceNarrow <= brkWin)

// remember where the move started (last narrow price) for the 50% rule
var float lastNarrowPrice = na
var int   lastNarrowBar   = na
if proc and narrowState
    lastNarrowPrice := close
    lastNarrowBar   := bar_index

// ─────────────────────── STATE VISUALS + ANNOTATIONS ──────────────────────────
// MA plots — item ② cyan, item ③ gold (theme colors; video used blue/red)
plot(ma20,  "20 SMA (item 2)",  color = COL_CYAN, linewidth = 2)
plot(ma200, "200 SMA (item 3)", color = COL_GOLD, linewidth = 2)
pP20  = plot(ma20,  "z2 edge", color = na, display = display.none, editable = false)
pP200 = plot(ma200, "z1 edge", color = na, display = display.none, editable = false)
pPx   = plot(close, "price edge", color = na, display = display.none, editable = false)
// zone 1 shading (20↔200) + zone 2 shading (price↔20)
color z1col = not showZones ? na : stackBull ? color.new(COL_BULL, 88) : stackBear ? color.new(COL_BEAR, 90) : color.new(COL_GREY, 94)
color z2col = not showZones ? na : threeFinger ? color.new(COL_CYAN, 82) : (stackBull or stackBear) ? color.new(COL_CYAN, 92) : na
fill(pP20, pP200, z1col, "Zone 1 (20↔200)")
fill(pPx,  pP20,  z2col, "Zone 2 (price↔20)")

// narrow state = soft cyan glow on the background
bgcolor(narrowState ? color.new(COL_CYAN, 88) : na)

// narrow-state boxes with label (drawn once per narrow phase)
var box narrowBox = na
var int cntNarrow = 0
if proc
    if narrowState and not narrowState[1]
        narrowBox := box.new(bar_index, math.max(high, ma200 + atrN * 0.3), bar_index, math.min(low, ma200 - atrN * 0.3), border_color = color.new(COL_CYAN, 45), border_width = 1, border_style = line.style_dotted, bgcolor = color.new(COL_CYAN, 93), text = "NARROW STATE", text_size = size.tiny, text_color = color.new(COL_CYAN, 25), text_halign = text.align_center, text_valign = text.align_top)
        cntNarrow += 1
    if narrowState and not na(narrowBox)
        box.set_right(narrowBox, bar_index)
        box.set_top(narrowBox, math.max(box.get_top(narrowBox), high))
        box.set_bottom(narrowBox, math.min(box.get_bottom(narrowBox), low))
    if not narrowState and narrowState[1] and not na(narrowBox)
        label.new(bar_index - 1, box.get_top(narrowBox), "MARKET RESET", style = label.style_label_down, color = color.new(COL_PANEL, 20), textcolor = COL_CYAN, size = size.tiny, tooltip = "NARROW STATE (video)\nAll three items — price, 20 SMA, 200 SMA — clustered together.\n'It is at the narrow state that you explode out again. The market resets itself. It could go this way or this way — you don't have to know in advance. You just have to see when the biggest bar emerges.'")

// three-finger spread + widest spread annotations
var int cntSpread = 0
var int lastSpreadLabBar = -99999
if proc and threeFinger and not threeFinger[1] and bar_index - lastSpreadLabBar > 10
    lastSpreadLabBar := bar_index
    cntSpread += 1
    bool up = stackBull
    label.new(bar_index, up ? high : low, "3-FINGER SPREAD", style = up ? label.style_label_down : label.style_label_up, color = color.new(COL_PANEL, 15), textcolor = up ? COL_BULL : COL_PINK, size = size.small, tooltip = "THREE-FINGER SPREAD (video)\n① price  ② 20 SMA  ③ 200 SMA — none of them close = DUAL SPACE.\nZone 1 (20↔200): " + str.tostring(z1, format.mintick) + "\nZone 2 (price↔20): " + str.tostring(z2, format.mintick) + "\nAcceleration check passed — this is NOT a railroad track.\n'Whenever they move apart to have a wide space, that is significant.'")

// widest spread: measuring line + reversal watch
var int   revWatch   = 0          // 1 = watch for bottom->BUY, -1 = watch for top->SELL
var float armExtreme = na
var float moveOrigin = na
var line  floorLine  = na
var label floorLab   = na
var array<line> measureLines = array.new<line>()
var int lastWidestBar = -99999
var int lastWidestAnyBar = -99999
bool widestEvent = false

if proc and widestNow
    lastWidestAnyBar := bar_index
    // (re)arm the reversal watch in the direction against the spread
    int newWatch = stackBear ? 1 : -1
    float ext = stackBear ? low : high
    if revWatch != newWatch or na(armExtreme)
        revWatch := newWatch
        armExtreme := ext
        moveOrigin := lastNarrowPrice
    else
        armExtreme := stackBear ? math.min(armExtreme, ext) : math.max(armExtreme, ext)
    if bar_index - lastWidestBar > 10
        lastWidestBar := bar_index
        widestEvent := true
        if showMeasure
            ml = line.new(bar_index, stackBear ? low : high, bar_index, ma200, color = color.new(COL_GOLD, 20), width = 2)
            array.push(measureLines, ml)
            while array.size(measureLines) > 30
                line.delete(array.shift(measureLines))
        label.new(bar_index, stackBear ? low : high, "★ WIDEST SPREAD", style = stackBear ? label.style_label_up : label.style_label_down, color = color.new(COL_GOLD, 10), textcolor = COL_BG, size = size.small, tooltip = "WIDEST THREE-FINGER SPREAD (video)\nBiggest total spread of the last " + str.tostring(widestLB) + " bars.\n'The widest three-finger spread will 8 to 9 times out of every 10 find you the bottom and the top.'\nReversal watch is now ARMED: if the spread collapses back to narrow WITHOUT breaking this extreme, the next direction is " + (stackBear ? "UP." : "DOWN.") + "\nExtreme to hold: " + str.tostring(ext, format.mintick))
    // floor / ceiling line that must hold
    if na(floorLine)
        floorLine := line.new(bar_index, armExtreme, bar_index + 15, armExtreme, color = color.new(COL_PINK, 20), style = line.style_dashed, width = 1)
        floorLab  := label.new(bar_index + 15, armExtreme, revWatch == 1 ? "LOW MUST HOLD" : "HIGH MUST HOLD", style = label.style_label_left, color = color.new(COL_PANEL, 20), textcolor = COL_PINK, size = size.tiny, tooltip = "Video: 'Narrow to narrow WITHOUT breaking the low of the three-finger spread — you're near your reversal.'\nIf this level breaks while still wide, the watch simply follows the new extreme.")

// keep the must-hold line alive & updated
if proc and revWatch != 0 and not na(floorLine)
    // extreme keeps following while the move extends
    if revWatch == 1 and low < armExtreme
        armExtreme := low
    if revWatch == -1 and high > armExtreme
        armExtreme := high
    line.set_y1(floorLine, armExtreme)
    line.set_y2(floorLine, armExtreme)
    line.set_x2(floorLine, bar_index + 15)
    label.set_y(floorLab, armExtreme)
    label.set_x(floorLab, bar_index + 15)
    label.set_text(floorLab, revWatch == 1 ? "LOW MUST HOLD" : "HIGH MUST HOLD")

// tail bar markers near narrow states
if proc and showTail and narrowRecent
    if tailBull and not tailBull[1]
        label.new(bar_index, low, "TAIL", style = label.style_label_up, color = color.new(COL_PANEL, 20), textcolor = COL_BULL, size = size.tiny, tooltip = "BOTTOMING TAIL BAR (video)\nLong lower tail at/near a narrow state.\n'A bunch of traders took the bottoming tail bar play... they add on the first color change.'")
    if tailBear and not tailBear[1]
        label.new(bar_index, high, "TAIL", style = label.style_label_down, color = color.new(COL_PANEL, 20), textcolor = COL_PINK, size = size.tiny, tooltip = "TOPPING TAIL BAR (video)\nLong upper tail at/near a narrow state — the mirror of the bottoming tail bar play.")

// power bar markers
if proc and powerBar and (narrowRecent or threeFinger or revWatch != 0)
    label.new(bar_index, powerBull ? low : high, "⚡", style = powerBull ? label.style_label_up : label.style_label_down, color = color.new(COL_BG, 100), textcolor = COL_GOLD, size = size.small, tooltip = "POWER BAR\nRange " + str.tostring(barRange, format.mintick) + " = biggest bar of the last " + str.tostring(pbLook) + " bars (≥ " + str.tostring(pbMult, "#.#") + "x avg).\nVideo: 'You just have to see when the biggest bar emerges.'")

// ─────────────────────────── SIGNAL ENGINE ────────────────────────────────────
var int    tradeDir  = 0
var float  tEntry    = na
var float  tSL       = na
var float  tTP       = na
var bool   halfTaken = false
var bool   addDone   = false
var bool   sawOpp    = false      // saw at least one opposing candle since entry (for ADD)
var float  tTrail    = na
var string sigTxt    = "FLAT"
var string setupTxt  = "—"
var int    cntSignals = 0

bool buySignal   = false
bool sellSignal  = false
bool addEvent    = false
bool tp50Event   = false
bool trailEvent  = false
bool slEvent     = false

f_tradeLines(float e, float s, float t, string tpTag) =>
    line.new(bar_index, e, bar_index + 25, e, color = COL_GOLD, style = line.style_dashed, width = 1)
    line.new(bar_index, s, bar_index + 25, s, color = COL_PINK, style = line.style_dashed, width = 1)
    line.new(bar_index, t, bar_index + 25, t, color = COL_BULL, style = line.style_dashed, width = 1)
    label.new(bar_index + 25, e, "ENTRY", style = label.style_label_left, color = color.new(COL_PANEL, 20), textcolor = COL_GOLD, size = size.tiny)
    label.new(bar_index + 25, s, "SL · beyond the bar", style = label.style_label_left, color = color.new(COL_PANEL, 20), textcolor = COL_PINK, size = size.tiny)
    label.new(bar_index + 25, t, tpTag, style = label.style_label_left, color = color.new(COL_PANEL, 20), textcolor = COL_BULL, size = size.tiny)

// Pine gotcha: global vars must not be mutated inside functions — the entry
// branches only COLLECT parameters, one shared block below applies them.
int    sigDir   = 0
float  sigSL    = na
float  sigTP    = na
string sigSetup = ""
string sigWhyT  = ""
string sigPill  = ""
bool   clearWatch = false

if proc and showSignals and tradeDir == 0
    // ── SETUP A: NARROW-STATE BREAKOUT (power bar out of narrow) ──
    if narrowRecent and powerBull
        sigDir := 1
        sigSL := low - slBuffer
        sigTP := close + tpR * (close - sigSL)
        sigSetup := "BREAKOUT"
        sigPill := "POWER BAR out of NARROW"
        sigWhyT := "WHY THIS BUY?\n1) NARROW STATE — all three items reset ('the market resets itself')\n2) POWER BAR up — the biggest bar emerged, direction chosen\n3) Entry inside the bar, stop below it (video play)"
    else if narrowRecent and powerBear
        sigDir := -1
        sigSL := high + slBuffer
        sigTP := close - tpR * (sigSL - close)
        sigSetup := "BREAKOUT"
        sigPill := "POWER BAR out of NARROW"
        sigWhyT := "WHY THIS SELL?\n1) NARROW STATE — all three items reset\n2) POWER BAR down — the biggest bar emerged, direction chosen\n3) Entry inside the bar, stop above it ('stop above the high')"
    // ── SETUP B: SPREAD REVERSAL — creme de la creme ──
    // trigger zone: fully narrow again OR spread clearly contracting with price back over the 20
    else if revWatch == 1 and (narrowState or (spreadRank <= 55 and close > ma20)) and (powerBull or strongBull) and not na(armExtreme)
        sigDir := 1
        sigSL := armExtreme - slBuffer
        float base = na(moveOrigin) ? close + 4 * atrN : moveOrigin
        sigTP := math.max(close + atrN, armExtreme + 0.5 * (base - armExtreme))
        sigSetup := "REVERSAL"
        sigPill := "SPREAD REVERSAL · 50% RULE"
        sigWhyT := "WHY THIS BUY?\n1) WIDEST 3-finger spread found the bottom (8-9/10 rule)\n2) Spread collapsed NARROW-to-NARROW without breaking the low\n3) POWER BAR up confirms — 'three-finger spread reversing with a power bar: the creme de la creme'\nTP = 50% rule: 'the pros are satisfied with the halfway mark'"
        clearWatch := true
    else if revWatch == -1 and (narrowState or (spreadRank <= 55 and close < ma20)) and (powerBear or strongBear) and not na(armExtreme)
        sigDir := -1
        sigSL := armExtreme + slBuffer
        float base = na(moveOrigin) ? close - 4 * atrN : moveOrigin
        sigTP := math.min(close - atrN, armExtreme - 0.5 * (armExtreme - base))
        sigSetup := "REVERSAL"
        sigPill := "SPREAD REVERSAL · 50% RULE"
        sigWhyT := "WHY THIS SELL?\n1) WIDEST 3-finger spread found the top (8-9/10 rule)\n2) Spread collapsed NARROW-to-NARROW without breaking the high\n3) POWER BAR down confirms — the creme de la creme setup\nTP = 50% rule: 'don't get greedy like a little tiny piggy'"
        clearWatch := true
    // ── SETUP B2: EARLY REVERSAL — first color change right at the widest spread ──
    else if revEarly and revWatch == 1 and bar_index - lastWidestAnyBar <= earlyWin and strongBull and not na(armExtreme)
        sigDir := 1
        sigSL := armExtreme - slBuffer
        float base = na(moveOrigin) ? close + 4 * atrN : moveOrigin
        sigTP := math.max(close + atrN, armExtreme + 0.5 * (base - armExtreme))
        sigSetup := "EARLY REV"
        sigPill := "1st COLOR CHANGE @ WIDEST"
        sigWhyT := "WHY THIS BUY?\n1) WIDEST 3-finger spread just printed — 8-9 out of 10 it finds the bottom\n2) First color change: strong bull bar right off the extreme ('they take the bottoming tail bar play... always adding on the first color change')\n3) Stop below the extreme — TP = 50% rule"
    else if revEarly and revWatch == -1 and bar_index - lastWidestAnyBar <= earlyWin and strongBear and not na(armExtreme)
        sigDir := -1
        sigSL := armExtreme + slBuffer
        float base = na(moveOrigin) ? close - 4 * atrN : moveOrigin
        sigTP := math.min(close - atrN, armExtreme - 0.5 * (armExtreme - base))
        sigSetup := "EARLY REV"
        sigPill := "1st COLOR CHANGE @ WIDEST"
        sigWhyT := "WHY THIS SELL?\n1) WIDEST 3-finger spread just printed — 8-9 out of 10 it finds the top\n2) First color change: strong bear bar right off the extreme\n3) Stop above the extreme — TP = 50% rule"
    // ── SETUP C (optional): TAIL BAR early entry ──
    else if tailEntry and narrowRecent and tailBull
        sigDir := 1
        sigSL := low - slBuffer
        sigTP := close + tpR * (close - sigSL)
        sigSetup := "TAIL BAR"
        sigPill := "BOTTOMING TAIL BAR"
        sigWhyT := "WHY THIS BUY?\n1) Bottoming TAIL BAR at a narrow state (video early play)\n2) 'They take the bottoming tail bar play, they add on the first color change'"
    else if tailEntry and narrowRecent and tailBear
        sigDir := -1
        sigSL := high + slBuffer
        sigTP := close - tpR * (sigSL - close)
        sigSetup := "TAIL BAR"
        sigPill := "TOPPING TAIL BAR"
        sigWhyT := "WHY THIS SELL?\n1) Topping TAIL BAR at a narrow state (mirror of the video play)"

// apply the collected entry (global scope — safe to mutate)
if sigDir != 0
    tradeDir := sigDir
    tEntry := close
    tSL := sigSL
    tTP := sigTP
    halfTaken := false
    addDone := false
    sawOpp := false
    tTrail := na
    setupTxt := sigSetup
    cntSignals += 1
    float rr = sigDir == 1 ? (tTP - close) / math.max(close - tSL, syminfo.mintick) : (close - tTP) / math.max(tSL - close, syminfo.mintick)
    sigTxt := (sigDir == 1 ? "BUY " : "SELL ") + str.tostring(close, format.mintick) + "  " + str.tostring(rr, "#.#") + "R"
    string pillTip = sigWhyT + "\nEntry " + str.tostring(tEntry, format.mintick) + "\nSL " + str.tostring(tSL, format.mintick) + "\nTP " + str.tostring(tTP, format.mintick) + "\nR:R " + str.tostring(rr, "#.##")
    if sigDir == 1
        buySignal := true
        label.new(bar_index, low, "  BUY ▲  \n" + sigPill, style = label.style_label_up, color = COL_BUYBG, textcolor = COL_TXT, size = size.normal, tooltip = pillTip)
    else
        sellSignal := true
        label.new(bar_index, high, "  SELL ▼  \n" + sigPill, style = label.style_label_down, color = COL_SELLBG, textcolor = COL_TXT, size = size.normal, tooltip = pillTip)
    f_tradeLines(tEntry, tSL, tTP, sigSetup == "REVERSAL" ? "TP · 50% RULE" : "TP · " + str.tostring(tpR, "#.#") + "R")
    if clearWatch
        revWatch := 0
        line.delete(floorLine)
        label.delete(floorLab)
        floorLine := na
        floorLab := na

// ── trade management: ADD on first color change · 50% TP · bar-by-bar trail ──
if proc and tradeDir != 0
    bool candleWith = tradeDir == 1 ? close > open : close < open
    bool candleOpp  = tradeDir == 1 ? close < open : close > open
    if candleOpp
        sawOpp := true
    // ADD on first color change back into trade direction
    if useAdd and not addDone and sawOpp and candleWith
        addDone := true
        addEvent := true
        if tradeDir == 1
            label.new(bar_index, low, " ADD + ", style = label.style_label_up, color = color.new(COL_CYAN, 15), textcolor = COL_BG, size = size.small, tooltip = "ADD-ON (video)\n'Always adding on the first color change.'\nFirst candle flipping back into trade direction after a pullback candle.")
        else
            label.new(bar_index, high, " ADD + ", style = label.style_label_down, color = color.new(COL_CYAN, 15), textcolor = COL_BG, size = size.small, tooltip = "ADD-ON (video)\n'Always adding on the first color change.'")
    // 50% / R target: partial out, then trail bar-by-bar
    if not halfTaken and (tradeDir == 1 ? high >= tTP : low <= tTP)
        halfTaken := true
        tp50Event := true
        tTrail := tradeDir == 1 ? low : high
        sigTxt := "TP HIT ✔ partial out"
        if tradeDir == 1
            label.new(bar_index, high, " TP ✔ 50% ", style = label.style_label_down, color = color.new(COL_BULL, 15), textcolor = COL_BG, size = size.small, tooltip = "PROFIT TAKE (video 50% rule)\n'The pros are satisfied with the halfway mark. Incrementally exiting like I teach you.'\nRest of the position now follows a bar-by-bar trailing stop.")
        else
            label.new(bar_index, low, " TP ✔ 50% ", style = label.style_label_up, color = color.new(COL_BULL, 15), textcolor = COL_BG, size = size.small, tooltip = "PROFIT TAKE (video 50% rule)\nRest trails bar-by-bar.")
        if not useTrail
            tradeDir := 0
            sigTxt := "TP HIT ✔"
    // trailing bar-by-bar after the partial
    else if halfTaken and useTrail
        if tradeDir == 1
            if low <= tTrail
                trailEvent := true
                tradeDir := 0
                sigTxt := "TRAIL EXIT ✔"
                label.new(bar_index, low, " OUT ✔ ", style = label.style_label_up, color = color.new(COL_BULL, 15), textcolor = COL_BG, size = size.small, tooltip = "BAR-BY-BAR TRAILING STOP (video)\n'One following a bar-by-bar trailing stop. Boom. Out right there.'")
            else
                tTrail := math.max(tTrail, low[1])
        else
            if high >= tTrail
                trailEvent := true
                tradeDir := 0
                sigTxt := "TRAIL EXIT ✔"
                label.new(bar_index, high, " OUT ✔ ", style = label.style_label_down, color = color.new(COL_BULL, 15), textcolor = COL_BG, size = size.small, tooltip = "BAR-BY-BAR TRAILING STOP (video)\n'Boom. Out right there.'")
            else
                tTrail := math.min(tTrail, high[1])
    // hard stop
    if tradeDir != 0 and (tradeDir == 1 ? low <= tSL : high >= tSL)
        slEvent := true
        tradeDir := 0
        sigTxt := "SL HIT ✖"
        label.new(bar_index, tradeDir[1] == 1 ? low : high, " SL ✖ ", style = label.style_label_center, color = color.new(COL_BEAR, 15), textcolor = COL_TXT, size = size.small, tooltip = "STOP HIT — 'You can't predict with 100% accuracy anything. Prepare for that one to two times out of every 10 you're wrong.'\nRisk unit stays small vs. the profit unit — that's how you stay in business.")

// big MT5-style arrows on signal bars
plotshape(sellSignal, "SELL arrow", shape.triangledown, location.abovebar, COL_BEAR, size = size.small, display = display.pane)
plotshape(buySignal, "BUY arrow", shape.triangleup, location.belowbar, COL_BULL, size = size.small, display = display.pane)

// ─────────────────────────── ALERTS / WEBHOOK ─────────────────────────────────
f_json(string action, float px, float sl, float tp) =>
    '{"id":"' + whId + '","symbol":"' + syminfo.ticker + '","action":"' + action + '","setup":"' + setupTxt + '","price":' + str.tostring(px, format.mintick) + ',"sl":' + str.tostring(na(sl) ? px : sl, format.mintick) + ',"tp":' + str.tostring(na(tp) ? px : tp, format.mintick) + ',"tf":"' + timeframe.period + '","time":"' + str.format_time(time, "yyyy-MM-dd HH:mm", "GMT") + '"}'

if alSignals and buySignal
    alert(f_json("BUY", tEntry, tSL, tTP), alert.freq_once_per_bar_close)
if alSignals and sellSignal
    alert(f_json("SELL", tEntry, tSL, tTP), alert.freq_once_per_bar_close)
if alState and narrowState and not narrowState[1]
    alert(f_json("NARROW_STATE", close, na, na), alert.freq_once_per_bar_close)
if alState and widestEvent
    alert(f_json("WIDEST_SPREAD", close, na, na), alert.freq_once_per_bar_close)
if alManage and addEvent
    alert(f_json("ADD", close, tSL, tTP), alert.freq_once_per_bar_close)
if alManage and tp50Event
    alert(f_json("TP_50", tTP, na, na), alert.freq_once_per_bar_close)
if alManage and trailEvent
    alert(f_json("TRAIL_EXIT", close, na, na), alert.freq_once_per_bar_close)
if alManage and slEvent
    alert(f_json("SL_HIT", tSL, na, na), alert.freq_once_per_bar_close)

alertcondition(buySignal, "BUY Signal", "Space Concept: BUY {{ticker}} @ {{close}}")
alertcondition(sellSignal, "SELL Signal", "Space Concept: SELL {{ticker}} @ {{close}}")
alertcondition(narrowState and not narrowState[1], "Narrow State", "Space Concept: NARROW STATE {{ticker}} {{interval}} — explosive move loading")
alertcondition(widestEvent, "Widest Spread", "Space Concept: WIDEST 3-FINGER SPREAD {{ticker}} {{interval}} — reversal watch armed")

// ───────────── PANEL — CRT-Scalper-style cockpit (MT5 look) ─────────────────
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




f_spacer(table t, int r) =>
    table.cell(t, 0, r, "", bgcolor = color.new(COL_BG, 0), text_size = size.tiny)

f_check(table t, int r, string num, string title, string sub, string status, color stCol) =>
    table.cell(t, 0, r, num, text_color = COL_GOLD, text_size = size.small, bgcolor = color.new(COL_PANEL, 0), text_halign = text.align_center)
    table.cell(t, 1, r, title + "\n" + sub, text_color = COL_TXT, text_size = size.tiny, bgcolor = color.new(COL_PANEL, 0), text_halign = text.align_left)
    table.cell(t, 6, r, status, text_color = stCol, text_size = size.small, bgcolor = color.new(COL_PANEL, 0), text_halign = text.align_right)

// spread meter: 6 blocks scaled in ATR
f_meter(float v) =>
    int blocks = math.min(6, math.max(0, math.round(v / atrN * 2)))
    string s = ""
    for i = 1 to 6
        s += i <= blocks ? "▰" : "▱"
    s

var table pan = na
if showPanel and barstate.islast
    if na(pan)
        pan := table.new(f_pos(), 8, 30, bgcolor = color.new(COL_PANEL, 0), frame_color = COL_CYAN, frame_width = 2, border_color = color.new(COL_CYAN, 88), border_width = 1)
        for r = 0 to 29
            for c = 0 to 7
                table.cell(pan, c, r, "", bgcolor = color.new(COL_PANEL, 0), text_size = size.tiny)
        table.merge_cells(pan, 0, 5, 6, 5)
        table.cell(pan, 0, 6, "", bgcolor = color.rgb(6, 17, 30))
        table.merge_cells(pan, 0, 6, 7, 6)
        table.merge_cells(pan, 0, 8, 7, 8)
        table.merge_cells(pan, 0, 9, 7, 9)
        table.merge_cells(pan, 0, 10, 7, 10)
        table.merge_cells(pan, 0, 11, 3, 11)
        table.merge_cells(pan, 4, 11, 7, 11)
        table.merge_cells(pan, 0, 12, 3, 12)
        table.merge_cells(pan, 4, 12, 7, 12)
        table.merge_cells(pan, 0, 13, 7, 13)
        table.merge_cells(pan, 0, 14, 7, 14)
        for r = 15 to 21
            table.merge_cells(pan, 1, r, 5, r)
            table.merge_cells(pan, 6, r, 7, r)
        table.merge_cells(pan, 0, 22, 7, 22)
        table.merge_cells(pan, 0, 23, 7, 23)
        table.merge_cells(pan, 0, 24, 7, 24)
        table.merge_cells(pan, 0, 25, 7, 25)
        table.merge_cells(pan, 0, 26, 7, 26)
        table.cell(pan, 0, 27, "", bgcolor = color.rgb(6, 17, 30))
        table.merge_cells(pan, 0, 27, 7, 27)
        table.cell(pan, 0, 28, "", bgcolor = color.rgb(6, 17, 30))
        table.merge_cells(pan, 0, 28, 7, 28)
        table.cell(pan, 0, 29, "", bgcolor = color.rgb(6, 17, 30))
        table.merge_cells(pan, 0, 29, 7, 29)
    int gcol = glint % 8
    for r = 0 to 4
        for c = 0 to 7
            table.cell(pan, c, r, "", bgcolor = color.new(COL_PANEL, 0), text_size = size.tiny)
    // ── header ──
    table.cell(pan, 0, 5, "3F SPREAD BREAKOUT", text_color = COL_GOLD, text_size = size.normal, bgcolor = color.new(COL_PANEL, 0), text_halign = text.align_left, text_font_family = font.family_monospace)
    table.cell(pan, 7, 5, glint % 2 == 0 ? "●" : "○", text_color = COL_CYAN, text_size = size.small, bgcolor = color.new(COL_PANEL, 0), text_halign = text.align_right)
    // ── row 7: animated star row (space theme) ──
    for c = 0 to 7
        table.cell(pan, c, 7, "✦", text_color = c == gcol ? COL_GOLD : color.new(COL_BULL, 35), text_size = size.small, bgcolor = color.new(COL_PANEL, 0), text_halign = text.align_center)
    f_spacer(pan, 8)
    // ── row 9: state chip ──
    string chipTxt = narrowState ? "NARROW STATE ● RESET" : widestNow ? "★ WIDEST SPREAD ★" : threeFinger ? "3-FINGER SPREAD ●" : revWatch != 0 ? (revWatch == 1 ? "REVERSAL WATCH · UP" : "REVERSAL WATCH · DOWN") : "TRANSITION"
    color chipCol = narrowState ? COL_CYAN : widestNow ? COL_GOLD : threeFinger ? (stackBull ? COL_BULL : COL_PINK) : revWatch != 0 ? COL_GOLD : COL_GREY
    table.cell(pan, 0, 9, chipTxt, text_color = chipCol, text_size = size.small, bgcolor = color.new(COL_PANEL2, 0), text_halign = text.align_center, text_font_family = font.family_monospace)
    f_spacer(pan, 10)
    // ── rows 11-12: info grid ──
    table.cell(pan, 0, 11, "CHART\n" + timeframe.period + "  " + syminfo.ticker, text_color = COL_CYAN, text_size = size.tiny, bgcolor = color.new(COL_PANEL2, 0), text_halign = text.align_left)
    table.cell(pan, 4, 11, "THE 3 ITEMS\nPRICE · " + str.tostring(len20) + " SMA · " + str.tostring(len200) + " SMA", text_color = COL_CYAN, text_size = size.tiny, bgcolor = color.new(COL_PANEL2, 0), text_halign = text.align_left)
    table.cell(pan, 0, 12, "SPREAD RANK\n" + str.tostring(spreadRank, "#") + " / 100", text_color = COL_GOLD, text_size = size.tiny, bgcolor = color.new(COL_PANEL2, 0), text_halign = text.align_left)
    table.cell(pan, 4, 12, "ZONE1 " + f_meter(z1) + "\nZONE2 " + f_meter(z2), text_color = COL_GOLD, text_size = size.tiny, bgcolor = color.new(COL_PANEL2, 0), text_halign = text.align_left, text_font_family = font.family_monospace)
    f_spacer(pan, 13)
    // ── checklist (the video rules) ──
    table.cell(pan, 0, 14, "SPACE-CHECKLIST (VIDEO RULES)", text_color = COL_CYAN, text_size = size.tiny, bgcolor = color.new(COL_PANEL, 0), text_halign = text.align_left)
    f_check(pan, 15, "❶", "THREE ITEMS STACKED", stackBull ? "price > 20 > 200 — bullish" : stackBear ? "price < 20 < 200 — bearish" : "items crossed / mixed", stackBull or stackBear ? "OK" : "‥", stackBull or stackBear ? COL_BULL : COL_GREY)
    f_check(pan, 16, "❷", "ZONE 1 · 20 ↔ 200", str.tostring(z1, format.mintick) + " (" + str.tostring(z1 / atrN, "#.#") + " ATR)", z1 >= dualMinATR * atrN ? "OK" : "‥", z1 >= dualMinATR * atrN ? COL_BULL : COL_GREY)
    f_check(pan, 17, "❸", "ZONE 2 · PRICE ↔ 20", str.tostring(z2, format.mintick) + " (" + str.tostring(z2 / atrN, "#.#") + " ATR)", z2 >= dualMinATR * atrN ? "OK" : "‥", z2 >= dualMinATR * atrN ? COL_BULL : COL_GREY)
    f_check(pan, 18, "❹", "ACCELERATION", accelOK ? "pulling away from the 20" : "railroad track — no spread", accelOK ? "OK" : "✖", accelOK ? COL_BULL : COL_GREY)
    f_check(pan, 19, "❺", "WIDEST SPREAD WATCH", revWatch == 0 ? "waiting for widest spread" : (revWatch == 1 ? "low must hold " : "high must hold ") + str.tostring(armExtreme, format.mintick), revWatch != 0 ? "ARMED" : "‥", revWatch != 0 ? COL_GOLD : COL_GREY)
    f_check(pan, 20, "❻", "POWER BAR", powerBar ? "biggest bar emerged!" : "waiting for the biggest bar", powerBar ? "OK" : "‥", powerBar ? COL_BULL : COL_GREY)
    f_check(pan, 21, "❼", "MANAGEMENT", "ADD on color flip · TP 50% · trail", tradeDir != 0 ? (halfTaken ? "TRAIL" : addDone ? "ADD✔" : "RUN") : "—", tradeDir != 0 ? (halfTaken ? COL_CYAN : COL_GOLD) : COL_GREY)
    f_spacer(pan, 22)
    // ── position box ──
    string posTxt = tradeDir == 0 ? "NO POSITION   — —" : (tradeDir == 1 ? "LONG " : "SHORT ") + str.tostring(tEntry, format.mintick) + " · SL " + str.tostring(tSL, format.mintick) + " · TP " + str.tostring(tTP, format.mintick)
    table.cell(pan, 0, 23, posTxt, text_color = tradeDir == 0 ? COL_GREY : tradeDir == 1 ? COL_BULL : COL_PINK, text_size = size.small, bgcolor = color.new(COL_PANEL2, 0), text_halign = text.align_center, text_font_family = font.family_monospace)
    // ── big signal row ──
    color bigCol = str.contains(sigTxt, "TP HIT") or str.contains(sigTxt, "TRAIL EXIT") ? COL_BULL : str.contains(sigTxt, "SL HIT") ? COL_BEAR : tradeDir != 0 ? COL_GOLD : COL_GREY
    table.cell(pan, 0, 24, sigTxt, text_color = bigCol, text_size = size.large, bgcolor = color.new(COL_PANEL2, 0), text_halign = text.align_center, text_font_family = font.family_monospace)
    table.cell(pan, 0, 25, str.tostring(cntSpread) + " SPREADS · " + str.tostring(cntNarrow) + " RESETS · " + str.tostring(cntSignals) + " SIGNALS", text_color = color.new(COL_GREY, 20), text_size = size.tiny, bgcolor = color.new(COL_PANEL, 0), text_halign = text.align_center)
    f_spacer(pan, 26)
    // ── buttons (links shown in tooltip — TradingView tables are not clickable) ──
````
