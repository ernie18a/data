# Automate on Hyperliquid - Strategy Webhook Template [HYPR-run]

- url: https://www.tradingview.com/script/KHBR2H0R-Automate-on-Hyperliquid-Strategy-Webhook-Template-HYPR-run/
- type: strategy
- pine_id: PUB;f3fc1917e2bf46838d4ef0de60f99628
- version: 3.0

## Description

DESCRIPTION
You define the entry signal. The system manages everything after the fill. This is a production-grade trade system for automating strategies on Hyperliquid using TradingView webhooks. Five-level priority chain trade system. Four ATR trailing architectures including volume-weighted ATR with Efficiency Ratio scaling and ratchet floor. Smart stops that exit when a trade is invalidated. Pyramid scaling into winners and a redundant failsafe stop.

Three signal systems are included ready to backtest and deploy (EMA crossover, Turtle breakout, SFP - Swing Failure Pattern) that you can toggle on/off independently; replace or extend them with your own logic in three places: the input toggle, the signal condition, and the priority chain entry call. There are clear landmarks in the code to make it as straightforward as possible. 

This strategy is built for you to hit the ground running backtesting or automating with a systematic framework to execute around your entry logic or the example signals provided.  All signals fire on confirmed bar closes only. Entries, exits, pyramids, and stops are evaluated at close, not during the bar, so intrabar wick spikes do not trigger the system. This is by design. No lookahead bias: all highest/lowest references use prior-bar offsets, LinReg is calculated with offset=1, and no security() calls are used. The script does not repaint or compound returns.

WHAT THE STRATEGY SYSTEMIZES
1. Five-Level Priority Action Chain
Entries fire first. Pyramids fire second and block exits on the same bar. Trailing exits ride winners. Smart stops catch failing trades early. Failsafe stop is the absolute floor. The if/else order is intentional and prevents conflicts so that every action occurs only when it should.

2. Four ATR Trailing Stop Modes
Select from a dropdown. All use separate long/short look backs and multipliers because drops are faster than rallies; the defaults reflect this asymmetry.
• A3.1: LinReg + plain ATR, no ratchet. Baseline for comparison.
• A4.0 (default): LinReg + volume-weighted ATR + Efficiency Ratio + ratchet. VWATR discounts low-volume bars. ER tightens in chop (0.8x), widens in trend (1.2x). Ratchet means the stop only moves in your favor.
• A4.1: Chandelier + VWATR + ratchet + first-bar multiplier for tighter initial protection.
• A4.2: LinReg + VWATR, no ratchet or ER. Stop moves freely with projection.

***The multipliers determine how much room the stop gives price before triggering. They have the greatest influence on overall system performance and must be tuned to the asset and timeframe being traded. Default values are a starting point, not final settings.
• L Multi: 4.0 (long stop distance). Wider because uptrends are slower and require more room.
• S Multi: 2.0 (short stop distance). Tighter because drops are faster and corrections are sharper.
• Long LB: 14 bars. ATR lookback for long stops.
• Short LB: 26 bars. ATR lookback for short stops; longer lookback smooths volatile short-side moves.
• LinReg LB: 10 bars. LinReg projection window (A3.1, A4.0, A4.2).
• First Bar Mult: 1.5x (A4.1 only). Tighter stop on the entry bar; expands to standard multiplier after.

3. Smart Stops
Two trigger paths, both requiring open P&L below threshold (default -3.5%): (1) price crosses under the trailing stop while losing, or (2) price breaks the entry bar’s structure while losing. Either path exits the trade before the failsafe would trigger. The P&L condition on both paths prevents exits on noise when the trade is still within normal range.

4. Pyramid Entries
Scales into winning trades on 5-bar extremes. Requires full bar confirmation and must be within 13 bars of the initial entry. 

5. Basic Entry Quality Filters
Applied automatically to every entry:
• Wick nullification: bars with wicks > 38.2% of range block entries in that direction
• SFP nullification: active reversal patterns block opposing entries
• Full bar filter: candle body must be >= 66.6% of total range
• Bar confirmation: entries only fire on confirmed bars

THREE SIGNALS INCLUDED (replace or extend)
• XO/XU: EMA crossover with four configurable pairs (5/13, 9/26, 12/25, 26/128). Requires price above swing high (longs) or below swing low (shorts) plus volume spike (Dropdown Selection).
• Turtle: 13/26 bar breakout with Lost Trade System logic. First breakout after an opposing signal gets priority.
• SFP: Swing Failure Pattern. Longs fire on either 5/5 with full-body confirmation or 5/2 with bullish candle confirmation and strong volume spike (1.618x average). Shorts fire on 5/5 with full-body or 13/3 with bearish candle confirmation. Dual-path per direction allows the signal to catch both high-conviction structure failures and high-volume reversals. The function accepts any left/right look back combination, making it straightforward to adapt.[i] (#/# refers to pivot look back left and right)[/i]

Each has its own toggle. Enable one, combine them, or swap in your own signals.

WEBHOOK AUTOMATION
Every fill event fires through TradingView’s built-in webhook system when enabled: entries, exits, pyramids, smart stops, and failsafe closes. To execute those webhooks on Hyperliquid, an intermediary service (execution layer) that accepts TradingView webhooks and routes orders to Hyperliquid's API is required.

Setup:
1. Create an alert on this strategy
2. Set trigger to "Order fills only"
3. Check Webhook URL, paste your endpoint
4. Message box: {"ticker":"{{ticker}}","position":"{{strategy.market_position}}"}
5. Set expiration to Open-ended

The snippet will most likely require customization depending on your execution layer. The {{ticker}} and {{strategy.market_position}} fields are TradingView placeholders that auto-populate when a strategy signal fires.

We recommend referencing TradingView’s Strategy Alerts documentation to fully understand placeholder use and function when setting up your snippet for your execution layer: https://www.tradingview.com/support/solutions/43000481368/

BUILDING WITH YOUR OWN SIGNALS
The most straightforward path is adding your own entry logic. The ATR module, smart stops, and pyramids can also be edited to preferred logic while still leveraging the systemized structure for clean execution when automating on an exchange.

Option 1: Replace an existing signal. Find its section under the SIGNALS header (look for "EXAMPLE 1", "EXAMPLE 2", or "EXAMPLE 3"). Delete the example code and write your condition in its place. Find the matching entry in the STRATEGY CALLS priority chain and swap the condition variable. The toggle still works; rename its label in the input line. Everything downstream works automatically.

Option 2: Add a new signal. Three places to touch:
1. Copy a strategy toggle line from the STRATEGIES input group, change the variable name and label
2. Add your signal logic in the SIGNALS section as a boolean
3. Add an else-if block in the STRATEGY CALLS priority chain using your toggle as the gate

Two test switches (Tsw1, Tsw2) are reserved in Settings for custom signals.

READING THE CHART
Candles are colored by direction: black bodies up, gray bodies down (Quant Filter toggle).

The trailing stop draws as a colored line following your position: green below price when long, red/orange above price when short. A gradient fill shades the zone between price and the stop; it intensifies as price approaches the exit level.

Green dots on the long stop line and red dots on the short stop line are ratchet markers (A4.0 and A4.1 only). Each dot means the stop locked in a new level and will not pull back.

Entry labels appear at each fill: "xoL" (EMA long), "xuS" (EMA short), "tL" (Turtle long), "tS" (Turtle short), "sfpL"/"sfpS" (SFP entries), "pyrL"/"pyrS" (pyramid adds). Exit labels: "Cl"/"Cs" (trailing close long/short), "smrtstp" (smart stop), "fstp" (failsafe).

SFP candle wicks are color-coded by lookback: 5/5 bull wick = bright green, 5/2 bull wick = dark green, 5/5 bear wick = bright red, 13/3 bear wick = dark red. The shade tells you which configuration triggered â€” brighter means the more common 5/5 detection, darker means the secondary lookback fired.

Horizontal lines extending from entry price are the Late Entry Window: white solid line is entry price, green dashed line is entry + ATR window, red dashed line is entry - ATR window. Visual reference only; does not affect trade logic. Useful when away from the screen to quickly see if a missed entry is still within a safe ATR range.

Market structure labels (HH, LH, HL, LL) appear at swing pivots when the Structure toggle is enabled.

RISK MATH
Order size is fixed at $5,000 (50% of starting capital). That means it's always a flat $5k order, no compounding. With the failsafe at -5.25%, maximum loss per trade is $262.50, or 2.625% of the $10,000 starting balance. 

*Because order size is fixed in dollars while equity grows, risk as a percentage of equity decreases over time: 2.625% at start, 2.1% at $12,500, 1.75% at $15,000. The smart stop triggers before the failsafe in most cases, reducing average realized loss further.

STRATEGY PROPERTIES (What's used in the chart published here)
Strategies (all off by default - toggle on to activate):
• XO/XU: on
• Turtle: on
• SFP: on

Settings:
• Mode: Historical (switch to Bot Mode for live automation - limits calculation depth for speed)
• EMA Pair: 9/26

Risk Management:
• Smart Stop: on | -3.5%
• Failsafe Stop: on | -5.25%
• Mech TP/Cls: on

ATR Trailing Exits:
• Mode: A4.0
• L Multi: 4.0 | S Multi: 2.0
• Lng LB: 14 | Shrt LB: 26
• LinReg: 10 | First Bar: 1.5 (A4.1 only)

Backtest Properties:
• Initial capital: $10,000
• Commission: 0.05%
• Slippage: 2 ticks
• Order size: $5,000 (cash, fixed)
• Fill limit assumption: 5 ticks
• Max risk per trade: $262.50 (2.625% of starting equity)

CREDITS
ATR: J. Welles Wilder (1978). 
Efficiency Ratio: Perry Kaufman. 
Turtle breakout concept: Richard Donchian.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © HYPR-run

//@version=6
strategy(title = 'Automate ST - [HYPR-run]', initial_capital = 10000, default_qty_type = strategy.cash, default_qty_value = 5000, calc_on_every_tick = false, process_orders_on_close = true, backtest_fill_limits_assumption = 5, precision = 2, overlay = true, commission_type = strategy.commission.percent, commission_value = 0.05, slippage = 2, margin_long = 0, margin_short = 0, pyramiding = 2)
// DEFAULT PROPERTIES:
// Initial capital: $10,000 | Commission: 0.05% | Slippage: 2 ticks
// Order size: $5,000 (cash, fixed) | Failsafe: -8.5% | Fill assumption: 5 ticks

// ═══════════════════════════════════════════════════════════════════════
//                             INPUTS
// ═══════════════════════════════════════════════════════════════════════
// --- CHART VISUALS ---
cdse = input.bool(true, 'Quant Filter', inline = 'qf', group = 'Chart Visuals')
asw = input.bool(true, 'Symbols', inline = 'qf', group = 'Chart Visuals')
strc = input(false, title = 'Structure', inline = 'qf', group = 'Chart Visuals')

// --- ANALYSIS TOOLS ---
Tswxx = input.bool(true, 'Longs', inline = 'u', group = 'Analysis Tools')
Tswxs = input.bool(true, 'Shorts', inline = 'u', group = 'Analysis Tools')
Tsw1 = input.bool(false, 'Entries Only (Flip)', inline = 'u', group = 'Analysis Tools', tooltip = 'Will not close position until a flip signal is generated. For use with a webhook trade engine that automates trade management.')
// Tsw2 = input.bool(false, 'Test Switch 2', inline = 'u', group = 'Analysis Tools')

// --- STRATEGIES ---
xoxusw = input.bool(false, 'XO/XU', inline = 'str', group = 'Strategies', tooltip = 'EMA crossover strategy. Configure pair in Settings.')
turtsw = input.bool(false, 'Turtle', inline = 'str', group = 'Strategies', tooltip = 'Turtle breakout with volume and body confirmation.')
SFPsw = input.bool(false, 'SFP', inline = 'str', group = 'Strategies', tooltip = 'Swing Failure Pattern with multi-lookback detection.')

// --- SETTINGS ---
i_mode = input.string('Historical', title = 'Mode', inline = 'set', options = ['Bot Mode', 'Historical'], group = 'Settings')
MAsw = input.string('9/26', inline = 'set', options = ['5/13', '9/26', '12/25', '26/128'], group = 'Settings')

// --- RISK MANAGEMENT ---
livesw = input.bool(true, 'Smart Stop', inline = 'rsk', group = 'Risk Management')
Stpsw = input.bool(true, 'Failsafe Stop', inline = 'rsk', group = 'Risk Management')
Tsww = input.bool(true, 'Mech TP/Cls', inline = 'rsk', group = 'Risk Management')
stp = input.float(-0.085, title = 'Fail Safe  %', inline = 'stp', step = 0.005, group = 'Risk Management')
smrtstp = input.float(-0.035, title = 'Smart Stop %', inline = 'stp', step = 0.005, group = 'Risk Management')
swinglbL = 5 //input.int(5, title = 'Swing LB L', inline = 'swlb', step = 1, group = 'Risk Management')
swinglbR = 5 //input.int(5, title = 'Swing LB R', inline = 'swlb', step = 1, group = 'Risk Management')

// --- ATR TRAILING EXITS ---
atrMode = input.string('A4.0', title = 'Mode', inline = 'amode', options = ['A3.1', 'A4.0', 'A4.1', 'A4.2'], group = 'ATR Trailing Exits', tooltip = 'A3.1: LinReg + plain ATR, no ratchet. A4.0: LinReg + VWATR + ER + ratchet. A4.1: Chandelier + VWATR + ratchet + first-bar. A4.2: LinReg + VWATR, no ratchet.')
firstMult = input.float(1.5, title = 'First Bar', inline = 'amode', step = 0.1, group = 'ATR Trailing Exits', tooltip = 'A4.1 only. Tighter stop on first bar, then standard multiplier.')
lrlb = input.int(10, title = 'LinReg', inline = 'amode', step = 1, group = 'ATR Trailing Exits')
atrml = input.float(4.0, title = 'L Multi', inline = 'amult', step = 0.1, group = 'ATR Trailing Exits')
atrms = input.float(2.0, title = 'S Multi', inline = 'amult', step = 0.1, group = 'ATR Trailing Exits')
atrlb_long = input.int(14, title = 'Lng LB', inline = 'alb', step = 1, group = 'ATR Trailing Exits')
atrlb_short = input.int(26, title = 'Shrt LB', inline = 'alb', step = 1, group = 'ATR Trailing Exits')
atr_entry_mult = input.float(0.618, 'ATR Window', inline = 'aref', minval = 0.25, maxval = 2.0, step = 0.10, group = 'LATE ENTRY WINDOW', tooltip = 'Window for late entries. 0.5=tight, 1.0=standard, 1.5=loose')
line_extension = input.int(30, 'Line Ext (bars)', inline = 'aref', minval = 10, maxval = 200, group = 'LATE ENTRY WINDOW')

// ═══════════════════════════════════════════════════════════════════════
//                            COLORS
// ═══════════════════════════════════════════════════════════════════════
color green = color.rgb(0, 180, 0)
color red = color.red
color darkgreen = color.rgb(0, 145, 0)
color darkred = color.rgb(175, 0, 0)
color brightgreen = color.rgb(29, 255, 37)
color brightred = #ff1100
color buTrapClr = color.orange
color brTrapClr = color.lime
color black = color.black
color yellow = color.yellow
color white = #FFFFFFff
color textc = color.rgb(217, 217, 217)
color textColor = black

// ═══════════════════════════════════════════════════════════════════════
//                       FUNCTION DECLARATIONS
// ═══════════════════════════════════════════════════════════════════════
// SFP detector — used by the SFP example signal below.
// If you remove SFP from your signals, you can remove this function.
detectSFP(sfplbL, sfplbR) =>
    swinghir = na(ta.pivothigh(high, sfplbL, sfplbR)) ? false : true
    swinglor = na(ta.pivotlow(low, sfplbL, sfplbR)) ? false : true
    swhr = ta.valuewhen(swinghir, high[sfplbR], 0)
    swlr = ta.valuewhen(swinglor, low[sfplbR], 0)
    llstr = low < ta.lowest(low, sfplbR)[1]
    hhstr = high > ta.highest(high, sfplbR)[1]
    sfpbucandler = low < swlr and open > swlr and close > swlr and llstr
    sfpbrcandler = high > swhr and open < swhr and close < swhr and hhstr
    sfpbucandlerl = ta.valuewhen(sfpbucandler, low, 0)
    sfpbrcandlerh = ta.valuewhen(sfpbrcandler, high, 0)
    sfpbunulr = fixnan(close < sfpbucandlerl ? 1 : sfpbucandlerl > ta.lowest(close, 2)[1] ? 1 : sfpbucandler ? 0 : na)
    sfpbrnulr = fixnan(close > sfpbrcandlerh ? 1 : sfpbrcandlerh < ta.highest(close, 2)[1] ? 1 : sfpbrcandler ? 0 : na)
    sfpcr = fixnan(sfpbucandler ? 1 : sfpbrcandler ? -1 : na)
    sfpbuvalidr = sfpcr == 1 and sfpbunulr != 1
    sfpbrvalidr = sfpcr == -1 and sfpbrnulr != 1
    h1_local = close >= (1 + 0.0005) * high[1]
    l1_local = close <= (1 - 0.0005) * low[1]
    sfpLcfmr = close > ta.valuewhen(sfpbucandler, high, 0)
    sfpScfmr = close < ta.valuewhen(sfpbrcandler, low, 0)
    sfpbarbur = ta.barssince(sfpbucandler) <= 5
    sfpbarbrr = ta.barssince(sfpbrcandler) <= 5
    sfpbuc = sfpbucandler and sfpbuvalidr
    sfpbrc = sfpbrcandler and sfpbrvalidr
    sfplr = not sfpbrcandler ? sfpbarbur and sfpbuvalidr and sfpLcfmr and h1_local : false
    sfpsr = not sfpbucandler ? sfpbarbrr and sfpbrvalidr and sfpScfmr and l1_local : false
    sfplongr = fixnan(sfplr ? 1 : sfpsr ? -1 : sfpbucandler or sfpbrcandler ? 0 : na)[1] != 1 and sfplr
    sfpshortr = fixnan(sfplr ? 1 : sfpsr ? -1 : sfpbucandler or sfpbrcandler ? 0 : na)[1] != -1 and sfpsr
    [sfplongr, sfpshortr, sfpbuc, sfpbrc]

// ═══════════════════════════════════════════════════════════════════════
//                          CALCULATIONS
// ═══════════════════════════════════════════════════════════════════════
// ── CORE ──────────────────────────────────────────────────────────────
// Throttle — limits calculation depth in Bot Mode for speed
throttle = i_mode == 'Bot Mode' ? last_bar_index - bar_index <= 300 : true
es3 = throttle

// Open P&L as percentage of entry
OpenGL = es3 ? strategy.openprofit / math.abs(strategy.opentrades.entry_price(0) * strategy.position_size) : na
// Bars since last entry
bsle = strategy.opentrades > 0 ? bar_index - strategy.opentrades.entry_bar_index(strategy.opentrades - 1) : 0

// Volume
v = ta.sma(volume, 13)
vspike = volume > volume[1] and volume > v
vspike5 = volume > 1.618 * v

// Swing detection for smart stops and structure labels
swinghi = na(ta.pivothigh(high, swinglbL, swinglbR)) ? false : true
swinglo = na(ta.pivotlow(low, swinglbL, swinglbR)) ? false : true
swh = ta.valuewhen(swinghi, high[swinglbR], 0)
swl = ta.valuewhen(swinglo, low[swinglbR], 0)
LL = low[swinglbR] < ta.valuewhen(swinglo, low[swinglbR], 1) and swinglo
HL = low[swinglbR] > ta.valuewhen(swinglo, low[swinglbR], 1) and swinglo
HH = high[swinglbR] > ta.valuewhen(swinghi, high[swinglbR], 1) and swinghi
LH = high[swinglbR] < ta.valuewhen(swinghi, high[swinglbR], 1) and swinghi
swing = fixnan(HH ? 2 : HL ? 1 : LL ? -2 : LH ? -1 : na)

// ═══════════════════════════════════════════════════════════════════════
//                        CANDLE ANALYSIS
// ═══════════════════════════════════════════════════════════════════════
float fuz = 0.00005
float hammerp = 0.4
up = close > open
dn = close < open
h = high >= high[1]
l = low <= low[1]
h5 = close > ta.highest(high, 5)[1]
l5 = close < ta.lowest(low, 5)[1]
tdu = close > close[1]
tdd = close < close[1]

full_size = high - low
body_high = math.max(close, open)
body_low = math.min(close, open)
body_size = body_high - body_low
wick_high_size = high - body_high
wick_low_size = body_low - low

// Inlined fullmom candle functions
full = math.abs(open - close) >= full_size * 0.666


bearwg = wick_high_size > .382 * full_size
bullwg = wick_low_size > .382 * full_size
bearwtr = wick_high_size > 0.55 * full_size
bullwtr = wick_low_size > 0.55 * full_size
bullw2 = wick_low_size > 0.25 * full_size and wick_high_size < 0.1 * full_size
bearw2 = wick_high_size > 0.25 * full_size and wick_low_size < 0.1 * full_size
bullw3g = wick_low_size > 0.275 * full_size and wick_high_size < 0.1 * full_size
bearw3g = wick_high_size > 0.275 * full_size and wick_low_size < 0.1 * full_size

buc = full and up or bullw2 or bullw3g or bullwtr or wick_low_size > 0.5 * full_size
brc = full and dn or bearw2 or bearw3g or bearwtr or wick_high_size > 0.5 * full_size

// ═══════════════════════════════════════════════════════════════════════
//                             SIGNALS
// ═══════════════════════════════════════════════════════════════════════
// The trade engine reads four booleans from this section:
//   Long   — primary long entry condition
//   Short  — primary short entry condition
//   pLong  — pyramid long condition (optional)
//   pShort — pyramid short condition (optional)
//
// Three example signal systems are included below. Each has its own
// toggle in Settings > Strategies. Replace or extend them with your
// own signals using the same pattern:
//   1. Calculate your indicator/condition
//   2. Define a boolean (e.g., mySignalL = [your condition])
//   3. Wire it into the priority chain (Section: Strategy Calls)
// ═══════════════════════════════════════════════════════════════════════

// ── EXAMPLE 1: EMA CROSSOVER (XO/XU) ─────────────────────────────────
ma5 = ta.ema(close, 5)
ma9 = ta.ema(close, 9)
ma12 = ta.ema(close, 12)
ma13 = ta.ema(close, 13)
ma25 = ta.ema(close, 25)
ma26 = ta.ema(close, 26)
ma50 = ta.ema(close, 50)
ma128 = ta.ema(close, 128)
ma200 = ta.ema(close, 200)
tf513 = ma5 > ma13 ? 1 : -1
xo513 = ta.crossover(ma5, ma13)
xu513 = ta.crossunder(ma5, ma13)
tf926 = ma9 > ma26 ? 1 : -1
xo926 = ta.crossover(ma9, ma26)
xu926 = ta.crossunder(ma9, ma26)
xo1225 = ta.crossover(ma12, ma25)
xu1225 = ta.crossunder(ma12, ma25)
tf1225 = ma12 > ma25 ? 1 : -1
tf50200 = ma50 > ma200 ? 1 : -1
tf26128 = ma26 > ma128 ? 1 : -1
xo26128 = ta.crossover(ma26, ma128)
xu26128 = ta.crossunder(ma26, ma128)
xosw = MAsw == '5/13' ? xo513 : MAsw == '9/26' ? xo926 : MAsw == '12/25' ? xo1225 : MAsw == '26/128' ? xo26128 : xo926
xusw = MAsw == '5/13' ? xu513 : MAsw == '9/26' ? xu926 : MAsw == '12/25' ? xu1225 : MAsw == '26/128' ? xu26128 : xu926

// ── EXAMPLE 2: TURTLE BREAKOUT ────────────────────────────────────────
turtle13 = 13
turtle26 = 26
h26 = ta.highest(high, turtle26)[1]
h13 = ta.highest(high, turtle13)[1]
l13 = ta.lowest(low, turtle13)[1]
l26 = ta.lowest(low, turtle26)[1]
turtleL9 = close > ta.highest(high, 9)[1] and tdu
turtleS9 = close <  ta.lowest(low, 9)[1] and tdd
turtleL13 = ta.crossover(close, h13) and tdu
turtleL26 = ta.crossover(close, h26) and tdu
turtleS13 = ta.crossunder(close, l13) and tdd
turtleS26 = ta.crossunder(close, l26) and tdd
turt = fixnan(turtleL26 ? 2 : turtleS26 ? -2 : turtleL13 ? 1 : turtleS13 ? -1 : na)
tL = (ta.valuewhen(turtleL13, high, 1) > high or turt[1] < 0) and turtleL13 ? true : turt[1] == 1 and turtleL26 ? false : false
tS = (ta.valuewhen(turtleS13, low, 1) < low or turt[1] > 0) and turtleS13 ? true : false
tltsL = fixnan(turtleL13 ? 1 : turtleS26 ? -1 : na)[1] < 0 and tL
tltsS = fixnan(turtleS13 ? -1 : turtleL26 ? 1 : na)[1] > 0 and tS

// ── EXAMPLE 3: SWING FAILURE PATTERN ──────────────────────────────────
[sfpL52, sfpS52, sfpbuc52, sfpbrc52] = detectSFP(5, 2)
[sfpL55, sfpS55, sfpbuc55, sfpbrc55] = detectSFP(5, 5)
[sfpL133, sfpS133, sfpbuc133, sfpbrc133] = detectSFP(13, 3)


// ── EXAMPLE 4: VOLATILITY BREAKOUT ──────────────────────────────────
VBL2 = open + 1.5 * ta.atr(5) < high
VBS2 = open - 1.5 * ta.atr(5) > low

// ── NULLIFICATION GATES ───────────────────────────────────────────────
nulL = not(sfpbrc55 or sfpbrc133 or bearwg)
nulS = not(sfpbuc55 or sfpbuc133 or bullwg)

// ═══════════════════════════════════════════════════════════════════════
// ── SIGNAL DEFINITIONS ────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════
// These feed into the priority chain. Replace with your own conditions.
xoL = (xosw or xo26128) and vspike and close > swh and nulL
xuS = ta.barssince(VBS2) <= 3 and xusw and vspike and nulS //and close < swl
turtL = turtleL9 and not(tf1225 < 0) and buc and vspike5
turtS = ta.barssince(VBS2 and vspike5) <= 3 and turtleS9 and turt[1] > 0 and brc and nulS
sfpL = (sfpL55 and full or sfpL52 and buc and vspike5) and nulL
sfpS = (sfpS55 and full or sfpS133 and brc) and nulS

// ── PYRAMID SIGNALS ───────────────────────────────────────────────────
bsle_pyramid_valid = bsle <= 13
FBLp = es3 and h5 and full and bsle_pyramid_valid and nulL
FTSp = es3 and l5 and full and bsle_pyramid_valid and nulS

// ── POSITION STATE + SMART STOPS ──────────────────────────────────────
bool has_no_position = strategy.opentrades == 0
bool has_position = strategy.position_size != 0
bool inlong = strategy.position_size > 0
bool inshrt = strategy.position_size < 0
single_position = strategy.opentrades == 1
first_bar_entry = single_position and bsle == 1
inlong_single = inlong and single_position
inshrt_single = inshrt and single_position
entryh = ta.valuewhen(first_bar_entry, high[1], 0)
entryl = ta.valuewhen(first_bar_entry, low[1], 0)
opengl_invld = OpenGL <= smrtstp
entryh_broken = entryh < close
entryl_broken = entryl > close

// ═══════════════════════════════════════════════════════════════════════
// ── ATR TRAILING STOP MODULE — DROP-IN BLOCK ─────────────────────────
// ═══════════════════════════════════════════════════════════════════════
// Self-contained trailing stop engine. Reads: atrMode, atrml, atrms,
// atrlb_long, atrlb_short, lrlb, firstMult from inputs.
// Exports: longStop, shrtStop, xuls, xoss, ClsL, ClsS for downstream.
// Plots: regime-colored stop lines, gradient fill, ratchet markers.
// Drop this entire block into any strategy; wire xuls/xoss into your
// exit logic and ClsL/ClsS into your close calls.
// ═══════════════════════════════════════════════════════════════════════

// Plain ATR — separate lookbacks (A3.1)
atr_plain_long = ta.atr(atrlb_long)
atr_plain_short = ta.atr(atrlb_short)

// Volume-weighted ATR — separate lookbacks (A4.0, A4.1, A4.2)
tr = ta.tr(true)
volAvg_long = ta.sma(volume, atrlb_long)
volWt_long = volAvg_long > 0 ? volume / volAvg_long : 1.0
vwtr_long = tr * volWt_long
atr_vw_long = ta.sma(vwtr_long, atrlb_long)
volAvg_short = ta.sma(volume, atrlb_short)
volWt_short = volAvg_short > 0 ? volume / volAvg_short : 1.0
vwtr_short = tr * volWt_short
atr_vw_short = ta.sma(vwtr_short, atrlb_short)

// ATR for downstream use (entry level lines, etc.)
atr = atrMode == 'A3.1' ? atr_plain_long : atr_vw_long

// LinReg projection (A3.1, A4.0, A4.2)
lgg = ta.linreg(close, lrlb, 1)
lg = es3 ? lgg : na

// A3.1 — plain ATR, LinReg, no ratchet
longStop_31 = lg - atrml * atr_plain_long
shrtStop_31 = lg + atrms * atr_plain_short

// A4.0 — VWATR, LinReg, ER, ratchet
er = math.sum(math.abs(close - close[1]), atrlb_short)
erRatio = er > 0 ? math.abs(close - close[atrlb_short]) / er : 0.5
regimeScale = 0.8 + erRatio * 0.4
rawLongStop_40 = lg - atrml * regimeScale * atr_vw_long
rawShrtStop_40 = lg + atrms * regimeScale * atr_vw_short
var float longStop_40 = na
var float shrtStop_40 = na
longStop_40 := na(longStop_40[1]) or close[1] <= longStop_40[1] ? rawLongStop_40 : math.max(rawLongStop_40, longStop_40[1])
shrtStop_40 := na(shrtStop_40[1]) or close[1] >= shrtStop_40[1] ? rawShrtStop_40 : math.min(rawShrtStop_40, shrtStop_40[1])

// A4.1 — VWATR, Chandelier, ratchet, first-bar
var float longStop_41 = na
var float shrtStop_41 = na
if na(longStop_41[1]) or close[1] <= longStop_41[1]
    longStop_41 := high - firstMult * atr_vw_long
    longStop_41
else
    longStop_41 := math.max(longStop_41[1], high - atrml * atr_vw_long)
    longStop_41
if na(shrtStop_41[1]) or close[1] >= shrtStop_41[1]
    shrtStop_41 := low + firstMult * atr_vw_short
    shrtStop_41
else
    shrtStop_41 := math.min(shrtStop_41[1], low + atrms * atr_vw_short)
    shrtStop_41

// A4.2 — VWATR, LinReg, no ratchet
longStop_42 = lg - atrml * atr_vw_long
shrtStop_42 = lg + atrms * atr_vw_short

// Mode selector
longStop = atrMode == 'A3.1' ? longStop_31 : atrMode == 'A4.0' ? longStop_40 : atrMode == 'A4.1' ? longStop_41 : longStop_42
shrtStop = atrMode == 'A3.1' ? shrtStop_31 : atrMode == 'A4.0' ? shrtStop_40 : atrMode == 'A4.1' ? shrtStop_41 : shrtStop_42
xuls = ta.crossunder(close, longStop) and bsle >= 5
xoss = ta.crossover(close, shrtStop) and bsle >= 5

// VWATR regime
atr_ref_long = atrMode == 'A3.1' ? atr_plain_long : atr_vw_long
atr_ref_short = atrMode == 'A3.1' ? atr_plain_short : atr_vw_short
atrPct_long = atr_ref_long / close * 100
atrPct_short = atr_ref_short / close * 100
atrSma_L = ta.ema(atr_ref_long, 14)
atrSma_S = ta.ema(atr_ref_short, 14)
atrRatio_L = atrSma_L > 0 ? atr_ref_long / atrSma_L : 1.0
atrRatio_S = atrSma_S > 0 ? atr_ref_short / atrSma_S : 1.0

// Stop line color by ATR regime (green/red stable → amber expanding)
longStopClr = color.from_gradient(atrRatio_L, 0.8, 1.2, color.new(green, 50), color.new(color.orange, 30))
shrtStopClr = color.from_gradient(atrRatio_S, 0.8, 1.2, color.new(red, 50), color.new(color.orange, 30))

// Stop line plots
pL = plot(inlong ? longStop : na, title = 'Trailing Stop L', style = plot.style_linebr, linewidth = 1, color = longStopClr)
pS = plot(inshrt ? shrtStop : na, title = 'Trailing Stop S', style = plot.style_linebr, linewidth = 1, color = shrtStopClr)

// Gradient fill between price and stop
pMid = plot(close, title = 'Price', display = display.none)
longGapPct = longStop > 0 ? (close - longStop) / close * 100 : 10.0
shrtGapPct = shrtStop > 0 ? (shrtStop - close) / close * 100 : 10.0
longMaxGap = atrml * atrPct_long
shrtMaxGap = atrms * atrPct_short
longFillClr = color.from_gradient(longGapPct, 0, longMaxGap, color.new(green, 55), color.new(brightgreen, 95))
shrtFillClr = color.from_gradient(shrtGapPct, 0, shrtMaxGap, color.new(red, 55), color.new(brightred, 95))
fill(pMid, pL, color = inlong and close > longStop ? longFillClr : na, title = 'Long Safety Zone')
fill(pMid, pS, color = inshrt and close < shrtStop ? shrtFillClr : na, title = 'Short Safety Zone')

// Ratchet markers (A4.0, A4.1 only)
ratchetL = (atrMode == 'A4.0' or atrMode == 'A4.1') and not na(longStop[1]) and longStop > longStop[1] and close > longStop
ratchetS = (atrMode == 'A4.0' or atrMode == 'A4.1') and not na(shrtStop[1]) and shrtStop < shrtStop[1] and close < shrtStop
plot(ratchetL and inlong ? longStop : na, title = 'Ratchet L', style = plot.style_circles, linewidth = 1, color = color.new(green, 30))
plot(ratchetS and inshrt ? shrtStop : na, title = 'Ratchet S', style = plot.style_circles, linewidth = 1, color = color.new(red, 30))
// ═══════════════════════════════════════════════════════════════════════
// ── END ATR TRAILING STOP MODULE ─────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════

smrtstpL = es3 and inlong_single and xuls and opengl_invld or es3 and inlong_single and entryl_broken and opengl_invld
smrtstpS = es3 and inshrt and xoss and opengl_invld or es3 and inshrt and entryh_broken and opengl_invld

// ── MECHANICAL TRAILING EXITS ─────────────────────────────────────────
min_bars_exit = 5
ClsL = (xuls[1] and close < longStop or xuls) and bsle >= min_bars_exit
ClsS = (xoss[1] and close > shrtStop or xoss) and bsle >= min_bars_exit

// ═══════════════════════════════════════════════════════════════════════
//                         STRATEGY CALLS
// ═══════════════════════════════════════════════════════════════════════
// Entry gates — control what's allowed to trade
es3_confirmed = es3 and barstate.isconfirmed 
bsle_valid = bsle >= 0
entry_gate_L = es3_confirmed and bsle_valid and Tswxx
entry_gate_S = es3_confirmed and bsle_valid and Tswxs
tengl = entry_gate_L and (inshrt or has_no_position)
tengs = entry_gate_S and (inlong or has_no_position)
pyramid_gate_L = es3_confirmed and Tswxx and inlong and has_position
pyramid_gate_S = es3_confirmed and Tswxs and inshrt and has_position
close_gate = es3_confirmed and not(Tsw1)
trade_qty = 5000 / close

// ── PRIORITY CHAIN ──────────────────────────────────────────────────
// This if/else chain is intentional. Order matters:
// 1. Entries fire first
// 2. Trailing exits
// 3. Pyramids 
// 4. Smart stops
// 5. Failsafe stop (last resort)

// 1. PRIMARY ENTRIES
if tengl and xoL and xoxusw
    strategy.entry('xoL', strategy.long)
else if tengs and xuS and xoxusw
    strategy.entry('xuS', strategy.short)
else if tengl and turtL and turtsw
    strategy.entry('tL', strategy.long)
else if tengs and turtS and turtsw
    strategy.entry('tS', strategy.short)
else if tengl and sfpL and SFPsw
    strategy.entry('sfpL', strategy.long)
else if tengs and sfpS and SFPsw
    strategy.entry('sfpS', strategy.short)

// 2. TRAILING EXITS
else if close_gate and inlong and ClsL and Tsww
    strategy.close_all(comment = 'Cl')
else if close_gate and inshrt and ClsS and Tsww
    strategy.close_all(comment = 'Cs')

// 3. PYRAMID ENTRIES
else if pyramid_gate_L and FBLp
    strategy.entry('pyrL', strategy.long, qty = trade_qty)
else if pyramid_gate_S and FTSp
    strategy.entry('pyrS', strategy.short, qty = trade_qty)

// 4. SMART STOPS
else if close_gate and livesw and (smrtstpL or smrtstpS)
    strategy.close_all(comment = 'smrtstp')

// 5. FAILSAFE STOP
else if close_gate and Stpsw and OpenGL < stp
    strategy.close_all(comment = 'fstp')


// ═══════════════════════════════════════════════════════════════════════
//                            VISUALS
// ═══════════════════════════════════════════════════════════════════════
// Candle coloring
wckclr = sfpbuc55 ? brightgreen : sfpbuc52 ? darkgreen : sfpbrc55 ? brightred : sfpbrc133 ? darkred : cdse and up ? black : cdse and dn ? color.gray : cdse and h ? black : na
nqclr = cdse and up ? black : cdse and dn ? color.gray : cdse and h ? black : na
brdrclr = nqclr
plotcandle(open, high, low, close, 'Candles', color = nqclr, bordercolor = brdrclr, wickcolor = wckclr, force_overlay = true, editable = false, display = display.all - display.status_line - display.data_window)

// Signal markers
plotchar(asw ? tltsL : false, 'Turtle L', '▵', location.belowbar, color = darkgreen, size = size.tiny, editable = true, display = display.none)
plotchar(asw ? tltsS : false, 'Turtle S', '▿', location.abovebar, color = darkred, size = size.tiny, editable = true, display = display.none)
plotchar(asw ? sfpL : false, 'SFP L', '⏶', location = location.belowbar, color = green, size = size.tiny, editable = true, display = display.none)
plotchar(asw ? sfpS55 or sfpS133 : false, 'SFP S', '⏷', location = location.abovebar, color = red, size = size.tiny, editable = true, display = display.none)

// Trailing stops — see ATR TRAILING STOP MODULE above (self-contained plots)

// Market structure labels
plotshape(asw and strc and HH, title = 'HH', style = shape.labeldown, text = 'HH', textcolor = black, size = size.auto, location = location.abovebar, color = green, display = display.all - display.status_line - display.data_window, offset = -swinglbR, editable = false)
plotshape(asw and strc and LH, title = 'LH', style = shape.labeldown, text = 'LH', textcolor = black, size = size.auto, location = location.abovebar, color = buTrapClr, display = display.all - display.status_line - display.data_window, offset = -swinglbR, editable = false)
plotshape(asw and strc and HL, title = 'HL', style = shape.labelup, text = 'HL', textcolor = black, size = size.auto, location = location.belowbar, color = brTrapClr, display = display.all - display.status_line - display.data_window, offset = -swinglbR, editable = false)
plotshape(asw and strc and LL, title = 'LL', style = shape.labelup, text = 'LL', textcolor = black, size = size.auto, location = location.belowbar, color = red, display = display.all - display.status_line - display.data_window, offset = -swinglbR, editable = false)

// Entry level reference lines
var line entry_line = na
var line upper_limit_line = na
var line loer_limit_line = na
if last_bar_index - bar_index <= 300
    float entry_level = has_position ? strategy.opentrades.entry_price(0) : na
    float atr_window = atr_entry_mult * atr
    float upper_limit = has_position ? entry_level + atr_window : na
    float loer_limit = has_position ? entry_level - atr_window : na
    int raw_entry_bar = strategy.opentrades > 0 ? strategy.opentrades.entry_bar_index(0) : na
    int entry_bar = not na(raw_entry_bar) ? math.max(raw_entry_bar, bar_index - 500) : na
    line.delete(entry_line)
    line.delete(upper_limit_line)
    line.delete(loer_limit_line)
    if has_position and not na(entry_level) and not na(entry_bar)
        entry_line := line.new(entry_bar, entry_level, bar_index + line_extension, entry_level, color = color.white, style = line.style_solid, width = 1)
        upper_limit_line := line.new(entry_bar, upper_limit, bar_index + line_extension, upper_limit, color = color.green, style = line.style_dashed, width = 1)
        loer_limit_line := line.new(entry_bar, loer_limit, bar_index + line_extension, loer_limit, color = color.red, style = line.style_dashed, width = 1)
        loer_limit_line
    else
        entry_line := na
        upper_limit_line := na
        loer_limit_line := na
        loer_limit_line
````
