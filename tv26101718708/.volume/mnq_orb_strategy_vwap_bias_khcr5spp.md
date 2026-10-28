# MNQ ORB Strategy - VWAP + Bias

- url: https://www.tradingview.com/script/khcR5SPp-MNQ-ORB-Strategy-VWAP-Bias/
- type: strategy
- pine_id: PUB;7f0d148da56d44db97c682ed14eb907a
- version: 1.0

## Description

MNQ ORB Strategy
VWAP Filter + Directional Bias + Overnight Levels
TradingView Pine Script v5 Strategy | Micro E-mini Nasdaq Futures (MNQ)

─────────────────────────────────────────────────────────────────────

OVERVIEW

This strategy applies Opening Range Breakout (ORB) methodology to the Micro E-mini Nasdaq futures contract (MNQ). It combines a configurable ORB window with a VWAP directional filter, a directional bias control, and overnight high/low level plotting to give traders both systematic entry signals and meaningful market context at the regular session open.

The strategy is designed for backtesting and live execution on a 1-minute chart. All inputs are fully configurable so traders can test different ORB windows, tick-based profit targets and stop losses, and VWAP exit behavior without modifying the code.

─────────────────────────────────────────────────────────────────────

HOW IT WORKS

STEP 1 — OPENING RANGE FORMATION (9:30 to 9:40 ET default)

The strategy tracks every 1-minute bar between 9:30 and 9:40 AM Eastern Time, recording the highest high and lowest low of that window. At 9:40 the ORB is locked in for the day and does not change. Two levels are derived from the ORB:

  - Buy Level: ORB High + buffer ticks — breakout level for longs
  - Sell Level: ORB Low - buffer ticks — breakdown level for shorts

STEP 2 — VWAP FILTER

The VWAP filter prevents entries that conflict with the intraday trend. This is the most important filter in the strategy because index futures respect VWAP heavily — institutions use it as their primary execution benchmark throughout the session.

  - Long entries only fire when price is above VWAP
  - Short entries only fire when price is below VWAP
  - The VWAP filter can be toggled off for backtesting without it

NOTE: If the ORB breaks but VWAP blocks the entry, the opportunity is marked as missed for the day. No re-entry is allowed after the initial breakout bar even if price later crosses VWAP. This prevents late, off-level entries that are a common source of poor fills in practice.

STEP 3 — FIRST DIRECTION LOCK

Once price breaks either the buy level or sell level, that direction is locked for the day. The opposite side cannot fire a signal after the first break. This prevents the common scenario where an instrument breaks one direction, reverses, and triggers a second trade in the opposite direction at a far worse price.

STEP 4 — DIRECTIONAL BIAS CONTROL

The bias dropdown allows traders to manually set the directional filter each morning based on their market analysis, stage analysis, or trend assessment:

  - Both       — strategy fires long and short signals (default)
  - Long Only  — only long breakouts above the ORB high are taken
  - Short Only — only short breakdowns below the ORB low are taken

This is particularly useful for traders who use a broader market framework (stage analysis, macro trend, sector strength) to determine daily directional bias before the open. On strongly trending days, running the strategy in one direction only significantly reduces false signals.

STEP 5 — OVERNIGHT HIGH/LOW REFERENCE LEVELS

The strategy plots the overnight high and low (6pm prior day to 9:30am current day) as visual reference lines on the chart. These levels are not used in entry logic by default — they are provided as context for manual observation.

  - Aqua line:    overnight session high
  - Fuchsia line: overnight session low

The info panel displays the opening context relative to the overnight range — whether price opened above the overnight high (bullish), below the overnight low (bearish), or inside the range (neutral). Traders can use this to inform their daily bias selection before the ORB window opens.

STEP 6 — EXIT MANAGEMENT

The strategy places OCO (one cancels other) exit orders immediately upon entry. Two exit modes are available:

  - Standard TP/SL:   fixed tick-based take profit and stop loss
  - Trailing Stop:    activates after price moves trail ticks in your favor,
                      then follows price dynamically with a hard stop as a
                      safety net

An optional VWAP cross exit can be enabled — this closes the position if price crosses back through VWAP against the trade direction. For longs, a cross below VWAP triggers a close. For shorts, a cross above VWAP triggers a close. This exit fires separately from the TP/SL and can reduce losses on failed breakouts significantly.

─────────────────────────────────────────────────────────────────────

INPUT REFERENCE

Input                    Default   Group             Description
─────────────────────────────────────────────────────────────────────
ORB Window (minutes)     10        ORB Settings      Length of opening range window in minutes
Buffer (ticks)           4         ORB Settings      Buffer added above ORB high and below ORB low
Contracts                2         Position Sizing   Number of MNQ contracts per trade
Take Profit (ticks)      300       Risk Management   Profit target in ticks from entry
Stop Loss (ticks)        150       Risk Management   Stop loss in ticks from entry
Use Trailing Stop        Off       Risk Management   Toggle trailing stop vs fixed TP/SL
Trailing Stop (ticks)    150       Risk Management   Trailing stop distance once activated
Use ATR Filter           On        Filters           Skip trade if ORB range exceeds ATR multiple
ATR Multiplier           1.5       Filters           Max ORB range as multiple of 14-day ATR
Use VWAP Filter          On        Filters           Long above VWAP only, short below VWAP only
Exit on VWAP Cross       On        Filters           Close position if price crosses VWAP against trade
Trade Direction          Both      Bias Settings     Both / Long Only / Short Only
Entry Window End         11        Session Settings  Hour ET when new entries stop for the day
Show ORB Levels          On        Display           Plot ORB high, low, buy and sell levels
Show VWAP                On        Display           Plot VWAP line and background shading
Show Overnight Levels    On        Display           Plot overnight high and low reference lines
Show Info Panel          On        Display           On-chart label showing current settings and status

─────────────────────────────────────────────────────────────────────

TICK MATH REFERENCE

MNQ tick size: 0.25 points
Point value:   $2.00 per contract
Tick value:    $0.50 per contract

TP Ticks   SL Ticks   TP $ (2 contracts)   SL $ (2 contracts)
─────────────────────────────────────────────────────────────────────
120        60         $120                 $60
200        100        $200                 $100
300        150        $300                 $150
400        200        $400                 $200

All configurations above maintain a 2:1 reward-to-risk ratio.
Break-even win rate at 2:1 R/R = 33.3%

─────────────────────────────────────────────────────────────────────

CHART VISUALS

  - Blue line         ORB High
  - Red line          ORB Low
  - Lime line         Buy Level (ORB High + buffer)
  - Orange line       Sell Level (ORB Low - buffer)
  - Purple line       VWAP
  - Green background  Price above VWAP (long bias)
  - Red background    Price below VWAP (short bias)
  - Aqua dashed       Overnight session high
  - Fuchsia dashed    Overnight session low
  - Green triangle    Long signal fired
  - Red triangle      Short signal fired
  - Yellow X          Breakout occurred but VWAP blocked entry
                      (entry missed for the day — no re-entry)

─────────────────────────────────────────────────────────────────────

INFO PANEL

The on-chart info panel displays real-time strategy status:

  - Current bias mode
  - Contracts and dollar value of TP and SL
  - ORB range in ticks
  - ATR filter status (PASS or FAIL)
  - VWAP side (ABOVE or BELOW)
  - Overnight context (opened above, below, or inside overnight range)
  - Whether long or short entry was missed due to VWAP filter
  - Whether the entry window is currently open

─────────────────────────────────────────────────────────────────────

BACKTESTING GUIDE

CHART SETUP
  - Set chart to MNQ1! or the current active front month contract
  - Set chart timeframe to 1 MINUTE — only timeframe that produces
    accurate results
  - Do not backtest on 5, 10, or 15 minute charts — signal detection
    will be delayed and fills will be unrealistic

STRATEGY TESTER SETTINGS
  - Commission: $0.35 per contract per side or $0.00 for comparison
  - Slippage:   1-2 ticks to simulate realistic market order fills
  - Capital:    set to your intended trading capital

SUGGESTED TEST MATRIX
ORB Window   TP Ticks   SL Ticks   VWAP Filter   VWAP Exit
─────────────────────────────────────────────────────────────────────
5 min        120        60         On            On
10 min       120        60         On            On
10 min       300        150        On            On
10 min       300        150        On            Off
15 min       300        150        On            On
10 min       300        150        Off           Off

─────────────────────────────────────────────────────────────────────

TRADERSPOST INTEGRATION

TradingView alert setup:
  - Condition:   MNQ ORB Strategy - VWAP + Bias
                 → alert() function calls only
  - Message:     {{strategy.order.alert_message}}
  - Webhook URL: your TradersPost strategy webhook URL
  - Trigger:     Once Per Bar Close

Three alert types are sent:
  - Buy signal:  entry long with quantity
  - Sell signal: entry short with quantity
  - Exit signal: closes open position when TP, SL, or VWAP cross fires

NOTE: TP and SL are managed by TradingView strategy exits, not by
TradersPost. Configure your TradersPost strategy subscription to not
override exit orders.

─────────────────────────────────────────────────────────────────────

IMPORTANT NOTES

  - This strategy is for MNQ futures only. Do not apply to stocks or
    other instruments without modification.
  - Always paper trade before going live.
  - Overnight range plots require extended hours data enabled on your
    TradingView plan.
  - Entry window closes at 11:00 AM ET by default. Adjust the Entry
    Window End input to test different cutoff times.
  - VWAP resets at 9:30 AM ET (regular session open). Extended hours
    VWAP behavior may differ from your broker's display.

─────────────────────────────────────────────────────────────────────

DISCLAIMER

This strategy is provided for educational and backtesting purposes
only. It does not constitute financial advice. Trading futures involves
substantial risk of loss and is not appropriate for all investors.
Always paper trade any new strategy before committing real capital.
Past performance does not guarantee future results.

## Source Code

````pine
//@version=5
strategy("MNQ ORB Strategy - VWAP + Bias", overlay=true,
         default_qty_type=strategy.fixed,
         default_qty_value=2,
         pyramiding=0,
         calc_on_order_fills=true,
         process_orders_on_close=false)

// ══════════════════════════════════════════════════════════════════════════════
// INPUTS
// ══════════════════════════════════════════════════════════════════════════════
orbMinutes      = input.int(10,    "ORB Window (minutes)",           minval=1,  step=5,   group="ORB Settings")
bufferTicks     = input.int(4,     "Buffer Above/Below ORB (ticks)", minval=0,  step=1,   group="ORB Settings")
numContracts    = input.int(2,     "Number of Contracts",            minval=1,  step=1,   group="Position Sizing")
tpTicks         = input.int(120,   "Take Profit (ticks)",            minval=4,  step=4,   group="Risk Management")
slTicks         = input.int(60,    "Stop Loss (ticks)",              minval=4,  step=4,   group="Risk Management")
useTrailingStop = input.bool(false,"Use Trailing Stop",              group="Risk Management")
trailTicks      = input.float(60,  "Trailing Stop (ticks)",          minval=4,  step=4,   group="Risk Management")
useATRFilter    = input.bool(true,  "Use ATR Range Filter",          group="Filters")
atrMultiplier   = input.float(1.5,  "Max ORB Range (x Daily ATR)",   minval=0.5, step=0.1, group="Filters")
useVWAPFilter   = input.bool(true,  "Use VWAP Filter",               group="Filters")
useVWAPExit     = input.bool(true,  "Exit on VWAP Cross",            group="Filters")
biasMode        = input.string("Both", "Trade Direction",
                  options=["Both", "Long Only", "Short Only"],       group="Bias Settings")
entryEnd        = input.int(11,    "Entry Window End (hour ET)",     minval=10, step=1,   group="Session Settings")
showLevels      = input.bool(true,  "Show ORB Levels",               group="Display")
showVWAP        = input.bool(true,  "Show VWAP",                     group="Display")
showInfo        = input.bool(true,  "Show Info Panel",               group="Display")

// ══════════════════════════════════════════════════════════════════════════════
// TICK MATH
// ══════════════════════════════════════════════════════════════════════════════
tickSize     = syminfo.mintick
pointValue   = syminfo.pointvalue
tickValue    = tickSize * pointValue

tpPoints     = tpTicks    * tickSize
slPoints     = slTicks    * tickSize
trailPoints  = trailTicks * tickSize
bufferPoints = bufferTicks * tickSize

// ══════════════════════════════════════════════════════════════════════════════
// VWAP
// ══════════════════════════════════════════════════════════════════════════════
vwap = ta.vwap(hlc3)
plot(showVWAP ? vwap : na, "VWAP", color=color.new(color.purple, 0), linewidth=2)

// ══════════════════════════════════════════════════════════════════════════════
// ATR FILTER
// ══════════════════════════════════════════════════════════════════════════════
dailyATR = request.security(syminfo.tickerid, "D", ta.atr(14), lookahead=barmerge.lookahead_off)

// ══════════════════════════════════════════════════════════════════════════════
// SESSION & ORB WINDOW LOGIC
// ══════════════════════════════════════════════════════════════════════════════
nyHour   = hour(time,   "America/New_York")
nyMinute = minute(time, "America/New_York")
nyMins   = nyHour * 60 + nyMinute

marketOpen    = 9 * 60 + 30
orbEnd        = marketOpen + orbMinutes
entryClose    = entryEnd * 60

isNewDay      = ta.change(time("D")) != 0
isInORB       = nyMins >= marketOpen and nyMins < orbEnd
isPostORB     = nyMins >= orbEnd
isEntryWindow = nyMins >= orbEnd and nyMins <= entryClose

// ══════════════════════════════════════════════════════════════════════════════
// STATE VARIABLES
// ══════════════════════════════════════════════════════════════════════════════
var float orbHigh              = na
var float orbLow               = na
var bool  orbSet               = false
var bool  signalFiredToday     = false
var bool  atrPassedToday       = false
var float trailActivationPrice = na
var bool  trailActivated       = false
var bool  orbBrokenLong        = false
var bool  orbBrokenShort       = false
var bool  longEntryMissed      = false
var bool  shortEntryMissed     = false

if isNewDay
    orbHigh              := na
    orbLow               := na
    orbSet               := false
    signalFiredToday     := false
    atrPassedToday       := false
    trailActivationPrice := na
    trailActivated       := false
    orbBrokenLong        := false
    orbBrokenShort       := false
    longEntryMissed      := false
    shortEntryMissed     := false

// ── Track ORB high/low ──────────────────────────────────────────────────────
if isInORB
    orbHigh := na(orbHigh) ? high : math.max(orbHigh, high)
    orbLow  := na(orbLow)  ? low  : math.min(orbLow,  low)

if isPostORB and not orbSet and not na(orbHigh)
    orbSet         := true
    orbRange       = orbHigh - orbLow
    atrPassedToday := not useATRFilter or (orbRange <= atrMultiplier * dailyATR)

buyLevel  = na(orbHigh) ? na : orbHigh + bufferPoints
sellLevel = na(orbLow)  ? na : orbLow  - bufferPoints

// ══════════════════════════════════════════════════════════════════════════════
// TRACK BREAKOUTS AND MISSED ENTRIES
// Key fix: if ORB breaks but VWAP blocks the entry, mark it as missed
// No further entry allowed in that direction for the rest of the day
// ══════════════════════════════════════════════════════════════════════════════
longBreakBar  = orbSet and isPostORB and not na(buyLevel)  and high > buyLevel  and not orbBrokenLong
shortBreakBar = orbSet and isPostORB and not na(sellLevel) and low  < sellLevel and not orbBrokenShort

if longBreakBar
    orbBrokenLong := true
    if useVWAPFilter and close < vwap
        longEntryMissed := true

if shortBreakBar
    orbBrokenShort := true
    if useVWAPFilter and close > vwap
        shortEntryMissed := true

// ══════════════════════════════════════════════════════════════════════════════
// VWAP FILTER
// ══════════════════════════════════════════════════════════════════════════════
aboveVWAP = close > vwap
belowVWAP = close < vwap

vwapLongOK  = not useVWAPFilter or aboveVWAP
vwapShortOK = not useVWAPFilter or belowVWAP

// ══════════════════════════════════════════════════════════════════════════════
// ENTRY SIGNALS
// Entry only allowed on the exact breakout bar
// If VWAP blocked the breakout bar, entry is missed for the day
// ══════════════════════════════════════════════════════════════════════════════
longSignal  = longBreakBar and not signalFiredToday
              and not orbBrokenShort and atrPassedToday
              and isEntryWindow and vwapLongOK
              and not longEntryMissed
              and (biasMode == "Both" or biasMode == "Long Only")

shortSignal = shortBreakBar and not signalFiredToday
              and not orbBrokenLong and atrPassedToday
              and isEntryWindow and vwapShortOK
              and not shortEntryMissed
              and (biasMode == "Both" or biasMode == "Short Only")

if longSignal
    strategy.entry("ORB Long", strategy.long, qty=numContracts, stop=buyLevel)
    signalFiredToday := true

if shortSignal
    strategy.entry("ORB Short", strategy.short, qty=numContracts, stop=sellLevel)
    signalFiredToday := true

// ══════════════════════════════════════════════════════════════════════════════
// EXITS
// ══════════════════════════════════════════════════════════════════════════════
if strategy.position_size > 0
    if useVWAPExit and ta.crossunder(close, vwap)
        strategy.close("ORB Long", comment="VWAP Cross Exit")

    if useTrailingStop
        if barstate.isconfirmed
            if na(trailActivationPrice)
                trailActivationPrice := strategy.position_avg_price + trailPoints
            if high >= trailActivationPrice
                trailActivated := true

        strategy.exit("TP", from_entry="ORB Long",
                      limit = strategy.position_avg_price + tpPoints)

        if trailActivated
            strategy.exit("Trail", from_entry="ORB Long",
                          trail_price  = trailActivationPrice,
                          trail_offset = math.round(trailPoints / tickSize),
                          stop         = strategy.position_avg_price - slPoints)
        else
            strategy.exit("Trail", from_entry="ORB Long",
                          stop = strategy.position_avg_price - slPoints)
    else
        strategy.exit("TP/SL", from_entry="ORB Long",
                      limit = strategy.position_avg_price + tpPoints,
                      stop  = strategy.position_avg_price - slPoints)

if strategy.position_size < 0
    if useVWAPExit and ta.crossover(close, vwap)
        strategy.close("ORB Short", comment="VWAP Cross Exit")

    if useTrailingStop
        if barstate.isconfirmed
            if na(trailActivationPrice)
                trailActivationPrice := strategy.position_avg_price - trailPoints
            if low <= trailActivationPrice
                trailActivated := true

        strategy.exit("TP", from_entry="ORB Short",
                      limit = strategy.position_avg_price - tpPoints)

        if trailActivated
            strategy.exit("Trail", from_entry="ORB Short",
                          trail_price  = trailActivationPrice,
                          trail_offset = math.round(trailPoints / tickSize),
                          stop         = strategy.position_avg_price + slPoints)
        else
            strategy.exit("Trail", from_entry="ORB Short",
                          stop = strategy.position_avg_price + slPoints)
    else
        strategy.exit("TP/SL", from_entry="ORB Short",
                      limit = strategy.position_avg_price - tpPoints,
                      stop  = strategy.position_avg_price + slPoints)

// ══════════════════════════════════════════════════════════════════════════════
// VISUALS
// ══════════════════════════════════════════════════════════════════════════════
plot(showLevels ? orbHigh   : na, "ORB High",   color=color.blue,   linewidth=1)
plot(showLevels ? orbLow    : na, "ORB Low",    color=color.red,    linewidth=1)
plot(showLevels ? buyLevel  : na, "Buy Level",  color=color.lime,   linewidth=2)
plot(showLevels ? sellLevel : na, "Sell Level", color=color.orange, linewidth=2)

plotshape(longSignal,  title="Long Signal",  style=shape.triangleup,
          location=location.belowbar, color=color.green, size=size.large, text="ORB L")
plotshape(shortSignal, title="Short Signal", style=shape.triangledown,
          location=location.abovebar, color=color.red,   size=size.large, text="ORB S")

// Missed entry markers — shows where VWAP blocked a breakout
plotshape(longBreakBar  and longEntryMissed,  title="Long Missed",  style=shape.xcross,
          location=location.belowbar, color=color.yellow, size=size.small, text="missed")
plotshape(shortBreakBar and shortEntryMissed, title="Short Missed", style=shape.xcross,
          location=location.abovebar, color=color.yellow, size=size.small, text="missed")

vwapColor = close > vwap ? color.new(color.green, 80) : color.new(color.red, 80)
bgcolor(showVWAP ? vwapColor : na, title="VWAP Background")

// ── Info panel ───────────────────────────────────────────────────────────────
if showInfo and barstate.islast
    tpDollars = tpTicks * tickValue * numContracts
    slDollars = slTicks * tickValue * numContracts
    orbRange  = na(orbHigh) or na(orbLow) ? 0.0 : orbHigh - orbLow
    orbTicks  = math.round(orbRange / tickSize)
    vwapSide  = close > vwap ? "ABOVE" : "BELOW"

    info  = "MNQ ORB — VWAP + Bias\n"
    info += "Bias       : " + biasMode + "\n"
    info += "Contracts  : " + str.tostring(numContracts) + "\n"
    info += "TP         : " + str.tostring(tpTicks) + " ticks ($" + str.tostring(tpDollars, "#") + ")\n"
    info += "SL         : " + str.tostring(slTicks) + " ticks ($" + str.tostring(slDollars, "#") + ")\n"
    info += "ORB Range  : " + str.tostring(orbTicks) + " ticks\n"
    info += "ATR Filter : " + (atrPassedToday ? "PASS" : "FAIL") + "\n"
    info += "VWAP       : Price " + vwapSide + "\n"
    info += "Long missed: " + (longEntryMissed  ? "YES — no re-entry" : "NO") + "\n"
    info += "Short missed: " + (shortEntryMissed ? "YES — no re-entry" : "NO") + "\n"
    info += "Entry OK   : " + (isEntryWindow ? "YES" : "NO")

    var label infoLabel = na
    label.delete(infoLabel)
    infoLabel := label.new(bar_index, high,
                  text=info,
                  style=label.style_label_left,
                  color=color.new(color.navy, 20),
                  textcolor=color.white,
                  size=size.normal)

// ══════════════════════════════════════════════════════════════════════════════
// TRADERSPOST ALERT
// ══════════════════════════════════════════════════════════════════════════════
if longSignal
    jsonMsg = '{"ticker":"MNQ1!",'   +
              '"action":"buy",'       +
              '"orderType":"market",' +
              '"quantity":'           + str.tostring(numContracts) + '}'
    alert(jsonMsg, alert.freq_once_per_bar_close)

if shortSignal
    jsonMsg = '{"ticker":"MNQ1!",'   +
              '"action":"sell",'      +
              '"orderType":"market",' +
              '"quantity":'           + str.tostring(numContracts) + '}'
    alert(jsonMsg, alert.freq_once_per_bar_close)

if strategy.position_size[1] > 0 and strategy.position_size == 0
    alert('{"ticker":"MNQ1!","action":"exit"}', alert.freq_once_per_bar_close)

if strategy.position_size[1] < 0 and strategy.position_size == 0
    alert('{"ticker":"MNQ1!","action":"exit"}', alert.freq_once_per_bar_close)
````
