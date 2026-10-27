# Phase Oscillator Momentum Strategy

- url: https://www.tradingview.com/script/bwmZOabG-Phase-Oscillator-Momentum-Strategy/
- type: strategy
- pine_id: PUB;fd062e2144af47109700981e431aeccc
- version: 1.0

## Description

📌 OVERVIEW
I wanted a clean way to test what happens when NQ gets really stretched on the Saty Phase Oscillator, so I turned its ±100 readings into a rules based strategy. It enters on the thrust during the morning session and is flat by the close. Everything else in here is a switch you can flip and test yourself.

🙏 CREDIT
The oscillator is Saty Mahajan's work, and he publishes it on TradingView as the Saty Phase Oscillator. I rebuilt it from his formula to use as the entry trigger, so all credit for the oscillator itself goes to him. What this script adds is the strategy around it.

📐 HOW THE OSCILLATOR WORKS
It measures how far price has stretched from its 21 period EMA, scaled by volatility:
- Distance = close minus the 21 period EMA
- Raw value = distance ÷ (3 × ATR 14) × 100
- Oscillator = 3 period EMA of the raw value
So +100 means price is three ATRs above the 21 EMA, and -100 means three ATRs below. You'll see it in its own pane with reference lines at ±100, ±61.8 and zero. Before you trust any signal, drop Saty's original indicator on the same chart and make sure the two lines match.

⚙️ DEFAULT RULES
1. NQ futures, 10 minute chart, full Globex session.
2. Long when the oscillator crosses above +100, short when it crosses below -100.
3. New entries only between 09:30 and 11:00 New York time.
4. A long exits when the oscillator crosses below -100 and a short exits when it crosses above +100. If that happens inside the entry window, the position flips.
5. Anything still open gets closed at 16:00 New York time, so nothing is held overnight. There's also a safety check that closes any position it finds outside the session, which covers early close days.
6. One contract per trade. No stop loss, no profit target.

🧰 WHAT THE SCRIPT ADDS
All of this is off by default. None of it has been validated out of sample, so test it before you trust it.
- Signal level. Trade the ±100 extreme (the default), the ±61.8 level, or the zero line. The lower you go, the more often it trades and the less stretched price is when it enters.
- Full session entries, which let trades start anywhere between 09:30 and 16:00 instead of just the morning window.
- An overnight hold that skips the 16:00 close and waits for the exit signal instead. Expect gap risk and bigger drawdowns if you turn this on.
- Three exit rules to choose from: the opposite level cross (default), a return to zero, or leaving the entry zone.
- A VWAP filter that skips entries when price is already more than a set number of ATRs away from session VWAP.
- A hard stop and a trailing stop, both set as a percent of the entry price. The trail only kicks in once the trade is up by the trail distance, then follows the best price by that same amount.
- From and To dates, so you can tune on one stretch of history and check the result on a stretch you never touched.

🚀 HOW TO USE IT
Put it on an NQ 10 minute chart and check the oscillator lines up with the original. Set commission and slippage to whatever your broker actually charges. If you change any of the optional settings, run them through the date window on data you didn't tune on before relying on them.

📊 STRATEGY PROPERTIES USED FOR THE REPORT
- Initial capital: 100,000 USD, a realistic account size for holding one NQ contract
- Order size: 1 contract
- Commission: 2.10 USD per contract per side
- Slippage: 1 tick per fill (0.25 points, or 5 USD on NQ)
- Margin: 10% for longs and shorts, a conservative estimate of exchange margin for one NQ contract
- Fills happen at the open of the bar after the signal. There's no lookahead, no higher timeframe data and no bar magnifier.
With these defaults, NQ 10 minute history gives well over 100 trades.

⚠️ LIMITATIONS
- The ±100 threshold is tuned for NQ on the 10 minute chart. On another symbol or timeframe the same reading means a different sized move, so test it again before using it there.
- Your results will depend on how much history your plan loads, how the continuous contract rolls, and your real costs.
- Stops are simulated on bar data, so live fills can be different.
- A backtest doesn't tell you what happens next. This script is for research and education only. It isn't financial advice.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © DefinedEdge

//@version=6

// =============================================================================
//  Phase Oscillator Momentum Strategy
//
//  Credit: the entry signal is the Saty Phase Oscillator, created by Saty
//  Mahajan. This script re-implements the oscillator's formula and adds the
//  strategy logic around it. Full credit for the oscillator concept belongs
//  to its author.
//
//  Oscillator as implemented here (ATR = Wilder's):
//      pivot = EMA(close, 21)
//      osc   = EMA((close - pivot) / (3 * ATR(14)) * 100, 3)
//      +100 / -100 = price is three ATRs above / below the 21 EMA
//
//  Default configuration (NQ futures, 10-minute chart):
//      Long when the oscillator crosses above +100, short when it crosses
//      below -100. New entries only 09:30-11:00 New York time. Exit on the
//      opposite extreme cross or at the 16:00 flat. One contract, no stop,
//      no target.
//
//  Optional layers (all OFF by default, not validated out of sample):
//      signal level dial, full-session entries, overnight hold, exit rule
//      variants, VWAP distance filter, hard and trailing stops, date window.
// =============================================================================
strategy("Phase Oscillator Momentum Strategy", shorttitle = "PO Momentum",
     overlay                 = false,
     pyramiding              = 0,
     initial_capital         = 100000,
     default_qty_type        = strategy.fixed,
     default_qty_value       = 1,
     commission_type         = strategy.commission.cash_per_contract,
     commission_value        = 2.1,
     slippage                = 1,
     margin_long             = 10,
     margin_short            = 10,
     process_orders_on_close = false)

// ----------------------------------------------------------------- inputs
GRP_PO    = "Phase Oscillator (match the original indicator)"
emaLen    = input.int(21, "Pivot EMA length", minval = 1, group = GRP_PO)
atrLen    = input.int(14, "ATR length", minval = 1, group = GRP_PO)
atrMult   = input.float(3.0, "ATR multiple equal to 100", minval = 0.1, step = 0.1, group = GRP_PO)
smoothLen = input.int(3, "Smoothing EMA length", minval = 1, group = GRP_PO)

GRP_SIG = "Signal"
MODE_X  = "Extreme (+/-100)"
MODE_E  = "Extended (+/-61.8)"
MODE_Z  = "Zero line (0)"
sigMode = input.string(MODE_X, "Signal level", options = [MODE_X, MODE_E, MODE_Z], group = GRP_SIG, tooltip = "Level the oscillator must cross to enter. Lower levels trade more often with lower conviction.")

GRP_SES       = "Session (New York time)"
entrySess     = input.session("0930-1100", "Entry window", group = GRP_SES)
fullSession   = input.bool(false, "Allow entries 09:30-16:00 instead", group = GRP_SES)
flatH         = input.int(16, "Flat time  hour", minval = 0, maxval = 23, group = GRP_SES, inline = "flat")
flatM         = input.int(0, "minute", minval = 0, maxval = 59, group = GRP_SES, inline = "flat")
holdOvernight = input.bool(false, "Hold overnight (skip the flat)", group = GRP_SES, tooltip = "Holds until the exit signal instead of closing at the flat time. Adds gap risk and larger drawdowns.")

GRP_DIR    = "Direction and exit"
allowLong  = input.bool(true, "Allow longs", group = GRP_DIR)
allowShort = input.bool(true, "Allow shorts", group = GRP_DIR)
EXIT_OPP   = "Opposite level cross"
EXIT_ZERO  = "Return to zero"
EXIT_ZONE  = "Leave the entry zone"
exitMode   = input.string(EXIT_OPP, "Exit rule", options = [EXIT_OPP, EXIT_ZERO, EXIT_ZONE], group = GRP_DIR, tooltip = "Opposite level cross: a long exits when the oscillator crosses below the negative level. Return to zero: exits on the zero cross. Leave the entry zone: exits when the oscillator crosses back through the entry level.")

GRP_VW   = "VWAP filter"
useVwap  = input.bool(false, "Skip entries far from session VWAP", group = GRP_VW)
vwapMult = input.float(2.5, "Max distance from VWAP (x ATR)", minval = 0.1, step = 0.1, group = GRP_VW)

GRP_STOP    = "Protective stops (percent of entry price)"
useHardStop = input.bool(false, "Hard stop", group = GRP_STOP, inline = "hard")
hardPct     = input.float(1.0, "%", minval = 0.05, step = 0.05, group = GRP_STOP, inline = "hard")
useTrail    = input.bool(false, "Trailing stop", group = GRP_STOP, inline = "trail")
trailPct    = input.float(0.75, "%", minval = 0.05, step = 0.05, group = GRP_STOP, inline = "trail", tooltip = "Activates once the trade is up by this percent, then follows the best price by the same distance.")

GRP_WIN  = "Backtest window"
fromDate = input.time(timestamp("01 Jan 2000 00:00 +0000"), "From", group = GRP_WIN)
toDate   = input.time(timestamp("31 Dec 2099 23:59 +0000"), "To", group = GRP_WIN)

// ----------------------------------------------------------------- oscillator
pivot  = ta.ema(close, emaLen)
atrVal = ta.atr(atrLen)
rawOsc = atrVal > 0 ? (close - pivot) / (atrMult * atrVal) * 100.0 : 0.0
po     = ta.ema(rawOsc, smoothLen)

upper = sigMode == MODE_X ? 100.0 : sigMode == MODE_E ? 61.8 : 0.0
lower = -upper

// ----------------------------------------------------------------- time gates
TZ          = "America/New_York"
inWindow    = not na(time(timeframe.period, entrySess, TZ))
inRTH       = not na(time(timeframe.period, "0930-1600", TZ))
etMin       = hour(time, TZ) * 60 + minute(time, TZ)
tfMin       = math.max(1, math.round(timeframe.in_seconds() / 60))
barCloseMin = etMin + tfMin
flatMin     = flatH * 60 + flatM
flattenNow  = barCloseMin >= flatMin and (na(barCloseMin[1]) or barCloseMin[1] < flatMin)
forceFlat   = strategy.position_size != 0 and not inRTH and not inWindow
inDateRange = time >= fromDate and time <= toDate
entryTime   = (fullSession ? inRTH : inWindow) and (holdOvernight or barCloseMin < flatMin)

// ----------------------------------------------------------------- signals
crossUp   = ta.crossover(po, upper)
crossDown = ta.crossunder(po, lower)
xUpZero   = ta.crossover(po, 0.0)
xDnZero   = ta.crossunder(po, 0.0)
xUpLower  = ta.crossover(po, lower)
xDnUpper  = ta.crossunder(po, upper)

vwapVal     = ta.vwap(hlc3)
farFromVwap = useVwap and math.abs(close - vwapVal) > vwapMult * atrVal
vwapOK      = not farFromVwap

enterLong  = entryTime and inDateRange and allowLong and crossUp and vwapOK
enterShort = entryTime and inDateRange and allowShort and crossDown and vwapOK

longExitSig  = exitMode == EXIT_ZERO ? xDnZero : exitMode == EXIT_ZONE ? xDnUpper : crossDown
shortExitSig = exitMode == EXIT_ZERO ? xUpZero : exitMode == EXIT_ZONE ? xUpLower : crossUp

// ----------------------------------------------------------------- orders
if enterLong
    strategy.entry("Long", strategy.long)
if enterShort
    strategy.entry("Short", strategy.short)

inLong  = strategy.position_size > 0
inShort = strategy.position_size < 0

if inLong and longExitSig and not enterShort
    strategy.close("Long", comment = "Signal exit")
if inShort and shortExitSig and not enterLong
    strategy.close("Short", comment = "Signal exit")

// optional protective stops: sized from the signal close until filled, then from the average entry price
if useHardStop or useTrail
    if enterLong or inLong
        refL  = inLong ? strategy.position_avg_price : close
        stopL = useHardStop ? refL * (1 - hardPct / 100) : na
        actL  = useTrail ? refL * (1 + trailPct / 100) : na
        offL  = useTrail ? math.max(1.0, math.round(refL * trailPct / 100 / syminfo.mintick)) : na
        strategy.exit("Long Stop", from_entry = "Long", stop = stopL, trail_price = actL, trail_offset = offL, comment_loss = "Hard stop", comment_trailing = "Trail stop")
    if enterShort or inShort
        refS  = inShort ? strategy.position_avg_price : close
        stopS = useHardStop ? refS * (1 + hardPct / 100) : na
        actS  = useTrail ? refS * (1 - trailPct / 100) : na
        offS  = useTrail ? math.max(1.0, math.round(refS * trailPct / 100 / syminfo.mintick)) : na
        strategy.exit("Short Stop", from_entry = "Short", stop = stopS, trail_price = actS, trail_offset = offS, comment_loss = "Hard stop", comment_trailing = "Trail stop")

// flat at the close (plus a safety net for early closes), unless holding overnight
if not holdOvernight and strategy.position_size != 0 and (flattenNow or forceFlat)
    strategy.close_all(comment = "Session flat")

// close anything still open once the backtest window ends
if not inDateRange and strategy.position_size != 0
    strategy.close_all(comment = "Window end")

// ----------------------------------------------------------------- plots
plot(po, "Phase Oscillator", color = po >= 0 ? color.teal : color.orange, linewidth = 2)
hline(100, "+100", color = color.new(color.gray, 20), linestyle = hline.style_dashed)
hline(61.8, "+61.8", color = color.new(color.gray, 60), linestyle = hline.style_dotted)
hline(0, "Zero", color = color.new(color.gray, 40), linestyle = hline.style_solid)
hline(-61.8, "-61.8", color = color.new(color.gray, 60), linestyle = hline.style_dotted)
hline(-100, "-100", color = color.new(color.gray, 20), linestyle = hline.style_dashed)
plotshape(enterLong, "Long signal", shape.triangleup, location.bottom, color.green, size = size.tiny)
plotshape(enterShort, "Short signal", shape.triangledown, location.top, color.red, size = size.tiny)
bgcolor(entryTime ? color.new(color.blue, 92) : na, title = "Entry window")
````
