# J12Matic Builder by galgoom

- url: https://www.tradingview.com/script/2K6lt61r-J12Matic-Builder-by-galgoom/
- type: strategy
- pine_id: PUB;69b1491d92b943f79f6437369d1bb4d2
- version: 8.0

## Description

A flexible Renko/tick strategy that lets you choose between two entry engines (Multi-Source 3-way or QBand+Moneyball), with a unified trailing/TP exit engine, NY-time trading windows with auto-flatten, daily profit/loss and trade-count limits (HALT mode), and clean webhook routing using {{strategy.order.alert_message}}.

Highlights

Two entry engines

Multi-Source (3): up to three long/short sources with Single / Dual / Triple logic and optional lookback.

QBand + Moneyball: Gate → Trigger workflow with timing windows, OR/AND trigger modes, per-window caps, optional same-bar fire.

Unified exit engine: Trailing by Bricks or Ticks, plus optional static TP/SL.

Session control (NY time): Evening / Overnight / NY Session windows; auto-flatten at end of any enabled window.

Day controls: Profit/Loss (USD) and Trade-count limits. When hit, strategy HALTS new entries, shows an on-chart label/background.

Alert routing designed for webhooks: Every order sets alert_message= so you can run alerts with:

Condition: this strategy

Notify on: Order fills only

Message: {{strategy.order.alert_message}}

Default JSONs or Custom payloads: If a Custom field is blank, a sensible default JSON is sent. Fill a field to override.

How to set up alerts (the 15-second version)

Create a TradingView alert with this strategy as Condition.

Notify on: Order fills only.

Message: {{strategy.order.alert_message}} (exactly).

If you want your own payloads, paste them into Inputs → 08) Custom Alert Payloads.

Leave blank → the strategy sends a default JSON.

Fill in → your text is sent as-is.

Note: Anything you type into the alert dialog’s Message box is ignored except the {{strategy.order.alert_message}} token, which forwards the payload supplied by the strategy at order time.

Publishing notes / best practices

Renko users: Make sure “Renko Brick Size” in Inputs matches your chart’s brick size exactly.

Ticks vs Bricks: Exit distances switch instantly when you toggle Exit Units.

Same-bar flips: If enabled, a new opposite signal will first close the open trade (with its exit payload), then enter the new side.

HALT mode: When day profit/loss limit or trade-count limit triggers, new entries are blocked for the rest of the session day. You’ll see a label and a soft background tint.

Session end flatten: Auto-closes positions at window ends; these exits use the “End of Session Window Exit” payload.

Bar magnifier: Strategy is configured for on-close execution; you can enable Bar Magnifier in Properties if needed.

Default JSONs (used when a Custom field is empty)

Open: {"event":"open","side":"long|short","symbol":"<ticker>"}

Close: {"event":"close","side":"long|short|flat","reason":"tp|sl|flip|session|limit_profit|limit_loss","symbol":"<ticker>"}

You can paste any text/JSON into the Custom fields; it will be forwarded as-is when that event occurs.

Input sections — user guide
01) Entries & Signals

Entry Logic: Choose Multi-Source (3) or QBand + Moneyball (pick one).

Enable Long/Short Signals: Master on/off switches for entering long/short.

Flip on opposite signal: If enabled, a new opposite signal will close the current position first, then open the other side.

Signal Logic (Multi-Source):

Single: any 1 of the 3 sources > 0

Dual: Source1 AND Source2 > 0

Triple (default): 1 AND 2 AND 3 > 0

Long/Short Signal Sources 1–3: Provide up to three series (often indicators). A positive value (> 0) is treated as a “pulse”.

Use Lookback: Keeps a source “true” for N bars after it pulses (helps catch late triggers).

Long/Short Lookback (bars): How many bars to remember that pulse.

01b) QBands + Moneyball (Gate -> Trigger)

Allow same-bar Gate->Trigger: If ON, a trigger can fire on the same bar as the gate pulse.

Trigger must fire within N bars after Gate: Size of the gate window (in bars).

Max signals per window (0 = unlimited): Cap the number of entries allowed while a gate window is open.

Buy/Sell Source 1 – Gate: Gate pulse sources that open the buy/sell window (often a regime/zone, e.g., QBands bull/bear).

Trigger Pulse Mode (Buy/Sell): How to detect a trigger pulse from the trigger sources (Change / Appear / Rise>0 / Fall<0).

Trigger A/B sources + Extend Bars: Primary/secondary triggers plus optional extension to persist their pulse for N bars.

Trigger Mode: Pick S2 only, S3 only, S2 OR S3, or S2 AND S3. AND mode remembers both pulses inside the window before firing.

02) Exit Units (Trailing/TP)

Exit Units: Choose Bricks (Renko) or Ticks. All distances below switch accordingly.

03) Tick-based Trailing / Stops (active when Exit Units = Ticks)

Initial SL (ticks): Starting stop distance from entry.

Start Trailing After (ticks): Start trailing once price moves this far in your favor.

Trailing Distance (ticks): Offset of the trailing stop from peak/trough once trailing begins.

Take Profit (ticks): Optional static TP distance.

Stop Loss (ticks): Optional static SL distance (overrides trailing if enabled).

04) Brick-based Trailing / Stops (active when Exit Units = Bricks)

Renko Brick Size: Must match your chart’s brick size.

Initial SL / Start Trailing After / Trailing Distance (bricks): Same definitions as tick mode, measured in bricks.

Take Profit / Stop Loss (bricks): Optional static distances.

05) TP / SL Switch

Enable Static Take Profit: If ON, closes the trade at the fixed TP distance.

Enable Static Stop Loss (Overrides Trailing): If ON, trailing is disabled and a fixed SL is used.

06) Trading Windows (NY time)

Use Trading Windows: Master toggle for all windows.

Evening / Overnight / NY Session: Define each session in NY time.

Flatten at End of [Window]: Auto-close any open position when a window ends (sends the Session Exit payload).

07) Day Controls & Limits

Enable Profit Limits / Profit Limit (Dollars): When daily net PnL ≥ limit → auto-flatten and HALT.

Enable Loss Limits / Loss Limit (Dollars): When daily net PnL ≤ −limit → auto-flatten and HALT.

Enable Trade Count Limits / Number of Trades Allowed: After N entries, HALT new entries (does not auto-flatten).

On-chart HUD: A label and soft background tint appear when HALTED; a compact status table shows Day PnL, trade count, and mode.

08) Custom Alert Payloads (used as strategy.order.alert_message)

Long/Short Entry: Payload sent on entries (if blank, a default open JSON is sent).

Regular Long/Short Exit: Payload sent on closes from SL/TP/flip (if blank, a default close JSON is sent).

End of Session Window Exit: Payload sent when any enabled window ends and positions are flattened.

Profit/Loss/Trade Limit Close: Payload sent when daily profit/loss limit causes auto-flatten.

Tip: Any tokens you include here are forwarded “as is”. If your downstream expects variables, do the substitution on the receiver side.

Known limitations

No bracket orders from Pine: This strategy doesn’t create OCO/attached brackets on the broker; it simulates exits with strategy logic and forwards your payloads for external automation.

alert_message is per order only: Alerts fire on order events. General status pings aren’t sent unless you wire a separate indicator/alert.

Renko specifics: Backtests on synthetic Renko can differ from live execution. Always forward-test on your instrument and settings.

Quick checklist before you publish

✅ Brick size in Inputs matches your Renko chart

✅ Exit Units set to Bricks or Ticks as you intend

✅ Day limits/Windows toggled as you want

✅ Custom payloads filled (or leave blank to use defaults)

✅ Your alert uses Order fills only + {{strategy.order.alert_message}}

## Source Code

````pine
//@version=6
strategy("Galgoom Alert Builder (w/ MG)",
     overlay=true,
     default_qty_type=strategy.fixed,
     default_qty_value=1,
     calc_on_every_tick=false,
     use_bar_magnifier=true,
     calc_on_order_fills=true,
     process_orders_on_close=true,
     fill_orders_on_standard_ohlc=true,
     initial_capital=10000000000)


// ============================================================================
// QUICK GUIDE (read-me)
// - Use ONE entry engine at a time: Multi-Source(3) OR Gate + Trigger.
// - TP and SL are placed as a single OCO strategy.exit() order per side so
//   both levels are always active simultaneously. Bar Magnifier fills them
//   intrabar the moment price reaches either level.
// - Windows (NY time): auto-flatten at the end of enabled windows.
// - Day limits: Profit/Loss (USD) + Trade-count. When hit -> HALT new entries.
// - Alerts: create alert with this strategy, choose "Order fills only",
//   and set Message to:  {{strategy.order.alert_message}}
// ============================================================================


// ------------------------------
// 01) ENTRIES & SIGNALS
// ------------------------------
gEntries = "01) Entries & Signals"

entryLogicMode = input.string(
     "Multi-Source (3)", "Entry Logic",
     options=["Multi-Source (3)", "Gate + Trigger"],
     group=gEntries,
     tooltip="Choose the entry engine:\n- Multi-Source(3): combine up to 3 long/short sources with Single/Dual/Triple logic.\n- Gate + Trigger: gate -> trigger model with configurable open/close detection.")

enableBuy  = input.bool(true,  "Enable Long Signals",  group=gEntries)
enableSell = input.bool(true,  "Enable Short Signals", group=gEntries)

flipOnOpposite = input.bool(true, "Flip on opposite signal (same bar)", group=gEntries)

signalLogic = input.string(
     "Triple", "Signal Logic (for Multi-Source)",
     options=["Single","Dual","Triple"], group=gEntries)

buySignalSource1  = input.source(close, "Long Signal Source 1",  group=gEntries)
buySignalMode1    = input.string("Pulse > 0", "Long Signal Source 1 Mode", options=["Pulse > 0","Crossing Up Level","Crossing Down Level","Crossing Level (Either)","Disabled"], group=gEntries)
buySignalLevel1   = input.float(0.0, "Long Signal Source 1 Level", step=0.1, group=gEntries)
buySignalSource2  = input.source(close, "Long Signal Source 2",  group=gEntries)
buySignalMode2    = input.string("Pulse > 0", "Long Signal Source 2 Mode", options=["Pulse > 0","Crossing Up Level","Crossing Down Level","Crossing Level (Either)","Disabled"], group=gEntries)
buySignalLevel2   = input.float(0.0, "Long Signal Source 2 Level", step=0.1, group=gEntries)
buySignalSource3  = input.source(close, "Long Signal Source 3",  group=gEntries)
buySignalMode3    = input.string("Pulse > 0", "Long Signal Source 3 Mode", options=["Pulse > 0","Crossing Up Level","Crossing Down Level","Crossing Level (Either)","Disabled"], group=gEntries)
buySignalLevel3   = input.float(0.0, "Long Signal Source 3 Level", step=0.1, group=gEntries)

sellSignalSource1 = input.source(close, "Short Signal Source 1", group=gEntries)
sellSignalMode1   = input.string("Pulse > 0", "Short Signal Source 1 Mode", options=["Pulse > 0","Crossing Up Level","Crossing Down Level","Crossing Level (Either)","Disabled"], group=gEntries)
sellSignalLevel1  = input.float(0.0, "Short Signal Source 1 Level", step=0.1, group=gEntries)
sellSignalSource2 = input.source(close, "Short Signal Source 2", group=gEntries)
sellSignalMode2   = input.string("Pulse > 0", "Short Signal Source 2 Mode", options=["Pulse > 0","Crossing Up Level","Crossing Down Level","Crossing Level (Either)","Disabled"], group=gEntries)
sellSignalLevel2  = input.float(0.0, "Short Signal Source 2 Level", step=0.1, group=gEntries)
sellSignalSource3 = input.source(close, "Short Signal Source 3", group=gEntries)
sellSignalMode3   = input.string("Pulse > 0", "Short Signal Source 3 Mode", options=["Pulse > 0","Crossing Up Level","Crossing Down Level","Crossing Level (Either)","Disabled"], group=gEntries)
sellSignalLevel3  = input.float(0.0, "Short Signal Source 3 Level", step=0.1, group=gEntries)

useSignalLookback = input.bool(true, "Use Lookback for Entry Signals? (Multi-Source)", group=gEntries)
longLookbackBars  = input.int(10, "Long Signal Lookback (bars)",  minval=1, group=gEntries)
shortLookbackBars = input.int(10, "Short Signal Lookback (bars)", minval=1, group=gEntries)


// ============================================================================
// 01b) GATE + TRIGGER
// ============================================================================
gQBM = "01b) Gate + Trigger"

qbm_enableSameBar = input.bool(true, "Allow same-bar Gate->Trigger", group=gQBM)
qbm_maxPerWin     = input.int(0, "Max signals per window (0 = unlimited)", minval=0, group=gQBM)
qbm_winN      = input.int(0, "Trigger Window (bars, 0 = unlimited)", minval=0, group=gQBM, tooltip="How many bars after the gate pulse a trigger is still valid.\n0 = unlimited (window stays open until Gate Close Mode closes it).\n1 = trigger must fire on the same bar as the gate (or next bar if same-bar is ON).\nUse a small number like 1-3 for near-immediate entry confirmation.")

gateNeutralSrc = input.source(close, "Gate Neutral Source", group=gQBM,
     tooltip="Source for the NEUTRAL / NO TRADE state. Used when Gate Close Mode = 'Neutral Signal Fires'.")
gateNeutralActiveMode = input.string("Source > 0", "Gate Neutral Active Mode",
     options=["Source > 0","Source < 0","Source ≠ 0","Not NA"], group=gQBM,
     tooltip="Defines what 'neutral is currently active' means — evaluated every bar.\nWhen neutral becomes active a LATCH is set; gate stays locked until a fresh gate pulse fires.")

b1_src         = input.source(close, "Buy Gate Source (Bull)", group=gQBM)
bGateOpenMode  = input.string("Rise > 0", "Buy Gate Open Mode",  options=["Change","Appear (NA->value)","Rise > 0","Fall < 0"], group=gQBM)
bGateCloseMode = input.string("Source ≤ 0", "Buy Gate Close Mode", options=["Opposite Gate Only","Source ≤ 0","Source < 0","Neutral Signal Fires"], group=gQBM)

bTrigPulseMode = input.string("Rise > 0", "Buy Trigger Pulse Mode", options=["Change","Appear (NA->value)","Rise > 0","Fall < 0"], group=gQBM)
b2_src    = input.source(close, "Buy Trigger Source A", group=gQBM)
b2_ext    = input.int(0, "Extend Bars (Trigger A)", minval=0, group=gQBM)
b3_src    = input.source(close, "Buy Trigger Source B (optional)", group=gQBM)
b3_ext    = input.int(0, "Extend Bars (Trigger B)", minval=0, group=gQBM)
bTrigMode = input.string("S2 only", "Buy Trigger Mode", options=["S2 only","S3 only","S2 OR S3","S2 AND S3"], group=gQBM)

s1_src         = input.source(close, "Sell Gate Source (Bear)", group=gQBM)
sGateOpenMode  = input.string("Rise > 0", "Sell Gate Open Mode",  options=["Change","Appear (NA->value)","Rise > 0","Fall < 0"], group=gQBM)
sGateCloseMode = input.string("Source ≤ 0", "Sell Gate Close Mode", options=["Opposite Gate Only","Source ≤ 0","Source < 0","Neutral Signal Fires"], group=gQBM)

sTrigPulseMode = input.string("Rise > 0", "Sell Trigger Pulse Mode", options=["Change","Appear (NA->value)","Rise > 0","Fall < 0"], group=gQBM)
s2_src    = input.source(close, "Sell Trigger Source A", group=gQBM)
s2_ext    = input.int(0, "Extend Bars (Trigger A)", minval=0, group=gQBM)
s3_src    = input.source(close, "Sell Trigger Source B (optional)", group=gQBM)
s3_ext    = input.int(0, "Extend Bars (Trigger B)", minval=0, group=gQBM)
sTrigMode = input.string("S2 only", "Sell Trigger Mode", options=["S2 only","S3 only","S2 OR S3","S2 AND S3"], group=gQBM)


// Strong-trend filter
gTrend = "01c) Strong Trend Filter"
enableStrongTrendFilter = input.bool(false, "Enable Strong Trend Filter", group=gTrend)
trendFilterEMALength    = input.int(34,    "Trend EMA Length",  minval=1,   group=gTrend)
trendFilterDILength     = input.int(14,    "ADX DI Length",     minval=1,   group=gTrend)
trendFilterADXSmoothing = input.int(14,    "ADX Smoothing",     minval=1,   group=gTrend)
trendFilterADXThreshold = input.float(25.0,"ADX Threshold",     minval=1.0, step=0.5, group=gTrend)


// 02-05) EXIT / TP / SL
gUnits    = "02) Exit Units (Trailing/TP)"
exitUnits = input.string("Bricks", "Use Bricks or Ticks for exits?", options=["Bricks","Ticks"], group=gUnits,
     tooltip="TP and SL are placed as a single OCO order (one-cancels-other) so both levels are always active at the same time.\nBoth fill intrabar with Bar Magnifier enabled.")

gTicks             = "03) Tick-based Trailing / Stops"
initialSLTicks     = input.int(40, "Initial SL (ticks)",          minval=1, group=gTicks)
trailStartTicks    = input.int(10, "Start Trailing After (ticks)", minval=1, group=gTicks)
trailDistanceTicks = input.int(20, "Trailing Distance (ticks)",    minval=1, group=gTicks)
takeProfitTicks    = input.int(40, "Take Profit (ticks)",          minval=1, group=gTicks)
stopLossTicks      = input.int(50, "Stop Loss (ticks)",            minval=1, group=gTicks)

gBricks             = "04) Brick-based Trailing / Stops"
renkoBrickSize      = input.float(5.0,"Renko Brick Size (must match chart)", minval=0.1, group=gBricks)
initialSLBricks     = input.int(2,  "Initial SL (bricks)",          minval=1, group=gBricks)
trailStartBricks    = input.int(1,  "Start Trailing After (bricks)", minval=1, group=gBricks)
trailDistanceBricks = input.int(2,  "Trailing Distance (bricks)",    minval=1, group=gBricks)
takeProfitBricks    = input.int(2,  "Take Profit (bricks)",          minval=1, group=gBricks)
stopLossBricks      = input.int(2,  "Stop Loss (bricks)",            minval=1, group=gBricks)

gStatic                   = "05) TP / SL Switch"
enableStaticTP            = input.bool(true,  "Enable Static Take Profit",                    group=gStatic)
enableStaticSL            = input.bool(false, "Enable Static Stop Loss (Overrides Trailing)", group=gStatic)
freezeTrailingAtBE        = input.bool(false, "Freeze Trailing At Break Even",                group=gStatic)
breakEvenOffsetTicks      = input.int(0,  "Break Even Offset (ticks)",       minval=0, group=gStatic)
enablePostBEStepTrail     = input.bool(false, "Enable Post-BE Step Trail",                    group=gStatic)
postBEStartAfterTicks     = input.int(80, "Post-BE Start After (ticks)",     minval=0, group=gStatic)
postBETrailFrequencyTicks = input.int(80, "Post-BE Trail Frequency (ticks)", minval=1, group=gStatic)
postBETrailStepTicks      = input.int(40, "Post-BE Trail Step (ticks)",      minval=1, group=gStatic)


// 06) TRADING WINDOWS
gWin                  = "06) Trading Windows (NY time)"
useTradingWindow      = input.bool(true,  "Use Trading Windows?",          group=gWin)
enableEveningWindow   = input.bool(true,  "Enable Evening Window",         group=gWin)
eveningSessionStr     = input.session("1800-2359", "Evening Window",       group=gWin)
flattenAtEveningEnd   = input.bool(true,  "Flatten at End of Evening?",    group=gWin)
enableOvernightWindow = input.bool(true,  "Enable Overnight Window",       group=gWin)
overnightSessionStr   = input.session("0000-0800", "Overnight Window",     group=gWin)
flattenAtOvernightEnd = input.bool(true,  "Flatten at End of Overnight?",  group=gWin)
enableNYWindow        = input.bool(true,  "Enable NY Session Window",      group=gWin)
nySessionStr          = input.session("0930-1600", "NY Session",           group=gWin)
flattenAtNYEnd        = input.bool(true,  "Flatten at End of NY Session?", group=gWin)


// 07) DAY LIMITS
gRisk              = "07) Day Controls & Limits"
enableProfitLimit  = input.bool(false,   "Enable Profit Limits?",      group=gRisk)
profitLimitDollars = input.float(2000.0, "Profit Limit (Dollars)",     minval=0.0, group=gRisk)
enableLossLimit    = input.bool(false,   "Enable Loss Limits?",        group=gRisk)
lossLimitDollars   = input.float(1000.0, "Loss Limit (Dollars)",       minval=0.0, group=gRisk)
enableTradeLimit   = input.bool(false,   "Enable Trade Count Limits?", group=gRisk)
maxTradesPerDay    = input.int(3,        "Number of Trades Allowed",   minval=1,   group=gRisk)

gCooldown                    = "07b) Same-Direction Re-entry Cooldown"
enableReentryCooldownAfterSL = input.bool(false, "Enable Same-Direction Re-entry Cooldown After SL", group=gCooldown)
longReentryCooldownBars      = input.int(3, "Long Re-entry Cooldown After SL (bars)",  minval=1, group=gCooldown)
shortReentryCooldownBars     = input.int(3, "Short Re-entry Cooldown After SL (bars)", minval=1, group=gCooldown)


// 08) ALERTS
gCustom           = "08) Custom Alert Payloads"
customLongEntry   = input.string("", "Long Entry",                    group=gCustom)
customLongExit    = input.string("", "Long Exit (TP or SL)",          group=gCustom,
     tooltip="Sent when a long trade closes via TP or SL. TP and SL share one OCO exit order so they share one payload. Leave blank for default JSON.")
customShortEntry  = input.string("", "Short Entry",                   group=gCustom)
customShortExit   = input.string("", "Short Exit (TP or SL)",         group=gCustom,
     tooltip="Sent when a short trade closes via TP or SL.")
customSessionExit = input.string("", "End of Session Window Exit",    group=gCustom)
customLimitClose  = input.string("", "Profit/Loss/Trade Limit Close", group=gCustom)

defaultOpen(side) =>
    "{\"event\":\"open\",\"side\":\"" + side + "\",\"symbol\":\"" + syminfo.ticker + "\"}"
defaultClose(side, reason) =>
    "{\"event\":\"close\",\"side\":\"" + side + "\",\"reason\":\"" + reason + "\",\"symbol\":\"" + syminfo.ticker + "\"}"
pick(txt, fallback) =>
    (str.length(txt) > 0) ? txt : fallback


// 09) MARTINGALE
gMart = "09) Martingale (Qty Multiplier)"

var float mart_baseQty       = na
var float mart_nextQty       = na
var float mart_curTradeQty   = na
var float mart_tradeStartNet = na
var float mgOverride         = na
var bool  mgForceBase        = false

enableMartingale = input.bool(false, "Martingale: On/Off", group=gMart)
martMultiplier   = input.float(2.0,  "Multiplier",    minval=0.1, step=0.1, group=gMart)
martMaxContracts = input.float(4.0,  "Max contracts", minval=0.0, step=0.1, group=gMart)

var int closedCountPrev = 0
tradeClosedNow = (strategy.closedtrades > closedCountPrev)
if tradeClosedNow
    idx     = strategy.closedtrades - 1
    lastQty = math.abs(strategy.closedtrades.size(idx))
    lastPL  = strategy.closedtrades.profit(idx)
    if na(mart_baseQty)
        mart_baseQty := lastQty
    mart_nextQty    := (lastPL < 0) ? math.min(lastQty * martMultiplier, martMaxContracts) : na
    closedCountPrev := strategy.closedtrades

mgQty = enableMartingale ? (na(mart_nextQty) ? na : int(math.round(mart_nextQty))) : na


// SESSION FLAGS
evTime  = time(timeframe.period, eveningSessionStr,   "America/New_York")
ovTime  = time(timeframe.period, overnightSessionStr, "America/New_York")
nyTime  = time(timeframe.period, nySessionStr,        "America/New_York")

inEveningRaw   = not na(evTime)
inOvernightRaw = not na(ovTime)
inNYRaw        = not na(nyTime)

inEvening   = useTradingWindow and enableEveningWindow   ? inEveningRaw   : false
inOvernight = useTradingWindow and enableOvernightWindow ? inOvernightRaw : false
inNY        = useTradingWindow and enableNYWindow        ? inNYRaw        : false
inAnyWindow = useTradingWindow ? (inEvening or inOvernight or inNY) : true

endOfEvening   = useTradingWindow and enableEveningWindow   and bar_index > 0 and inEvening[1]   and not inEvening
endOfOvernight = useTradingWindow and enableOvernightWindow and bar_index > 0 and inOvernight[1] and not inOvernight
endOfNY        = useTradingWindow and enableNYWindow        and bar_index > 0 and inNY[1]        and not inNY


// HELPERS
f_extend(sig, n) =>
    bs = ta.barssince(sig)
    n <= 0 ? sig : (sig or (not na(bs) and bs <= n))

f_pulse_change(src)   => not na(src) and (na(src[1]) or src != src[1])
f_pulse_appear(src)   => not na(src) and na(src[1])
f_pulse_rise_pos(src) => src > 0 and nz(src[1]) <= 0
f_pulse_fall_neg(src) => src < 0 and nz(src[1]) >= 0

f_pulse_by_mode(src, mode) =>
    if mode == "Change"
        f_pulse_change(src)
    else if mode == "Appear (NA->value)"
        f_pulse_appear(src)
    else if mode == "Rise > 0"
        f_pulse_rise_pos(src)
    else
        f_pulse_fall_neg(src)

f_multiSourceSignal(src, mode, level) =>
    if mode == "Disabled"
        false
    else if mode == "Crossing Up Level"
        ta.crossover(src, level)
    else if mode == "Crossing Down Level"
        ta.crossunder(src, level)
    else if mode == "Crossing Level (Either)"
        ta.cross(src, level)
    else
        src > 0

_tick               = syminfo.mintick
f_bricksToPrice(b)  => b * renkoBrickSize
f_ticksToPrice(t)   => t * _tick
f_initialSL_d()     => exitUnits == "Bricks" ? f_bricksToPrice(initialSLBricks)     : f_ticksToPrice(initialSLTicks)
f_trailDistance_d() => exitUnits == "Bricks" ? f_bricksToPrice(trailDistanceBricks) : f_ticksToPrice(trailDistanceTicks)
f_staticTP_d()      => exitUnits == "Bricks" ? f_bricksToPrice(takeProfitBricks)    : f_ticksToPrice(takeProfitTicks)
f_staticSL_d()      => exitUnits == "Bricks" ? f_bricksToPrice(stopLossBricks)      : f_ticksToPrice(stopLossTicks)
f_trailStart_threshold() => exitUnits == "Bricks" ? trailStartBricks : trailStartTicks

f_trailStart_moved(entry, peak, trough, isLong) =>
    float move = na
    if exitUnits == "Bricks"
        move := isLong ? (peak - entry) / renkoBrickSize : (entry - trough) / renkoBrickSize
    else
        move := isLong ? (peak - entry) / _tick : (entry - trough) / _tick
    move


// ===========================================================================
// ENTRY LOGIC A — Multi-Source (3)
// ===========================================================================
buy1_now  = f_multiSourceSignal(buySignalSource1, buySignalMode1, buySignalLevel1)
buy2_now  = f_multiSourceSignal(buySignalSource2, buySignalMode2, buySignalLevel2)
buy3_now  = f_multiSourceSignal(buySignalSource3, buySignalMode3, buySignalLevel3)
sell1_now = f_multiSourceSignal(sellSignalSource1, sellSignalMode1, sellSignalLevel1)
sell2_now = f_multiSourceSignal(sellSignalSource2, sellSignalMode2, sellSignalLevel2)
sell3_now = f_multiSourceSignal(sellSignalSource3, sellSignalMode3, sellSignalLevel3)

var int lb_b1 = 0
var int lb_b2 = 0
var int lb_b3 = 0
var int lb_s1 = 0
var int lb_s2 = 0
var int lb_s3 = 0

lb_b1 := useSignalLookback ? (buy1_now  ? longLookbackBars  : math.max(lb_b1 - 1, 0)) : (buy1_now  ? 1 : 0)
lb_b2 := useSignalLookback ? (buy2_now  ? longLookbackBars  : math.max(lb_b2 - 1, 0)) : (buy2_now  ? 1 : 0)
lb_b3 := useSignalLookback ? (buy3_now  ? longLookbackBars  : math.max(lb_b3 - 1, 0)) : (buy3_now  ? 1 : 0)
lb_s1 := useSignalLookback ? (sell1_now ? shortLookbackBars : math.max(lb_s1 - 1, 0)) : (sell1_now ? 1 : 0)
lb_s2 := useSignalLookback ? (sell2_now ? shortLookbackBars : math.max(lb_s2 - 1, 0)) : (sell2_now ? 1 : 0)
lb_s3 := useSignalLookback ? (sell3_now ? shortLookbackBars : math.max(lb_s3 - 1, 0)) : (sell3_now ? 1 : 0)

buy1_ok  = lb_b1 > 0
buy2_ok  = lb_b2 > 0
buy3_ok  = lb_b3 > 0
sell1_ok = lb_s1 > 0
sell2_ok = lb_s2 > 0
sell3_ok = lb_s3 > 0

bool _buyCond  = false
bool _sellCond = false
if signalLogic == "Single"
    _buyCond  := buy1_ok or buy2_ok or buy3_ok
    _sellCond := sell1_ok or sell2_ok or sell3_ok
else if signalLogic == "Dual"
    _buyCond  := buy1_ok and buy2_ok
    _sellCond := sell1_ok and sell2_ok
else
    _buyCond  := buy1_ok and buy2_ok and buy3_ok
    _sellCond := sell1_ok and sell2_ok and sell3_ok

buyConditionMulti  = _buyCond
sellConditionMulti = _sellCond


// ===========================================================================
// ENTRY LOGIC B — Gate + Trigger
// ===========================================================================

neutralIsActive =
     gateNeutralActiveMode == "Source > 0" ? gateNeutralSrc > 0  :
     gateNeutralActiveMode == "Source < 0" ? gateNeutralSrc < 0  :
     gateNeutralActiveMode == "Source ≠ 0" ? gateNeutralSrc != 0 :
     not na(gateNeutralSrc)

b1_pulse = f_pulse_by_mode(b1_src, bGateOpenMode)
s1_pulse = f_pulse_by_mode(s1_src, sGateOpenMode)

b2_pulse_ext = f_extend(f_pulse_by_mode(b2_src, bTrigPulseMode), b2_ext)
b3_pulse_ext = f_extend(f_pulse_by_mode(b3_src, bTrigPulseMode), b3_ext)
s2_pulse_ext = f_extend(f_pulse_by_mode(s2_src, sTrigPulseMode), s2_ext)
s3_pulse_ext = f_extend(f_pulse_by_mode(s3_src, sTrigPulseMode), s3_ext)

b2_evt = f_pulse_by_mode(b2_src, bTrigPulseMode)
b3_evt = f_pulse_by_mode(b3_src, bTrigPulseMode)
s2_evt = f_pulse_by_mode(s2_src, sTrigPulseMode)
s3_evt = f_pulse_by_mode(s3_src, sTrigPulseMode)

var bool buyNeutralLatch  = false
var bool sellNeutralLatch = false

if bGateCloseMode == "Neutral Signal Fires" and neutralIsActive
    buyNeutralLatch := true
if sGateCloseMode == "Neutral Signal Fires" and neutralIsActive
    sellNeutralLatch := true

if b1_pulse
    buyNeutralLatch := false
if s1_pulse
    sellNeutralLatch := false

var int lastBuyGate  = na
var int lastSellGate = na
if b1_pulse
    lastBuyGate  := bar_index
if s1_pulse
    lastSellGate := bar_index

bullActive = not na(lastBuyGate)  and (na(lastSellGate) or lastBuyGate  > lastSellGate)
bearActive = not na(lastSellGate) and (na(lastBuyGate)  or lastSellGate > lastBuyGate)

f_gateForceClose_buy() =>
    if bGateCloseMode == "Source ≤ 0"
        b1_src <= 0
    else if bGateCloseMode == "Source < 0"
        b1_src < 0
    else if bGateCloseMode == "Neutral Signal Fires"
        neutralIsActive
    else
        false

f_gateForceClose_sell() =>
    if sGateCloseMode == "Source ≤ 0"
        s1_src <= 0
    else if sGateCloseMode == "Source < 0"
        s1_src < 0
    else if sGateCloseMode == "Neutral Signal Fires"
        neutralIsActive
    else
        false

gateForceClosedBuy  = f_gateForceClose_buy()
gateForceClosedSell = f_gateForceClose_sell()

withinBuyWin  = (qbm_winN == 0) or (not na(lastBuyGate)  and (bar_index - lastBuyGate  <= qbm_winN))
withinSellWin = (qbm_winN == 0) or (not na(lastSellGate) and (bar_index - lastSellGate <= qbm_winN))
inBuyWindow   = bullActive and not gateForceClosedBuy  and not buyNeutralLatch  and withinBuyWin
inSellWindow  = bearActive and not gateForceClosedSell and not sellNeutralLatch and withinSellWin

inBuyWindowAdj  = qbm_enableSameBar ? inBuyWindow  : (inBuyWindow  and not b1_pulse)
inSellWindowAdj = qbm_enableSameBar ? inSellWindow : (inSellWindow and not s1_pulse)

var int buyCount  = 0
var int sellCount = 0
if b1_pulse
    buyCount  := 0
if s1_pulse
    sellCount := 0

var int buyStage  = 0
var int sellStage = 0
var int buyS2TTL  = 0
var int sellS2TTL = 0

if b1_pulse
    buyStage := 0
    buyS2TTL := 0
if s1_pulse
    sellStage := 0
    sellS2TTL := 0

if gateForceClosedBuy or buyNeutralLatch
    buyStage := 0
    buyS2TTL := 0
if gateForceClosedSell or sellNeutralLatch
    sellStage := 0
    sellS2TTL := 0

bool buyTriggerPulse  = false
bool sellTriggerPulse = false

if bTrigMode == "S2 only"
    buyTriggerPulse := inBuyWindowAdj and b2_pulse_ext
else if bTrigMode == "S3 only"
    buyTriggerPulse := inBuyWindowAdj and b3_pulse_ext
else if bTrigMode == "S2 OR S3"
    buyTriggerPulse := inBuyWindowAdj and (b2_pulse_ext or b3_pulse_ext)
else
    buyTriggerPulse := false
    if inBuyWindowAdj
        if buyStage == 0 and b2_evt
            buyStage := 1
            buyS2TTL := math.max(0, b2_ext)
        if buyStage == 1
            if b3_evt
                buyTriggerPulse := true
                buyStage        := 0
                buyS2TTL        := 0
            else
                if buyS2TTL <= 0
                    buyStage := 0
                else
                    buyS2TTL -= 1
    else
        buyStage := 0
        buyS2TTL := 0

if sTrigMode == "S2 only"
    sellTriggerPulse := inSellWindowAdj and s2_pulse_ext
else if sTrigMode == "S3 only"
    sellTriggerPulse := inSellWindowAdj and s3_pulse_ext
else if sTrigMode == "S2 OR S3"
    sellTriggerPulse := inSellWindowAdj and (s2_pulse_ext or s3_pulse_ext)
else
    sellTriggerPulse := false
    if inSellWindowAdj
        if sellStage == 0 and s2_evt
            sellStage := 1
            sellS2TTL := math.max(0, s2_ext)
        if sellStage == 1
            if s3_evt
                sellTriggerPulse := true
                sellStage        := 0
                sellS2TTL        := 0
            else
                if sellS2TTL <= 0
                    sellStage := 0
                else
                    sellS2TTL -= 1
    else
        sellStage := 0
        sellS2TTL := 0

canBuyMore  = (qbm_maxPerWin == 0) or (buyCount  < qbm_maxPerWin)
canSellMore = (qbm_maxPerWin == 0) or (sellCount < qbm_maxPerWin)

buyEventQBM  = enableBuy  and canBuyMore  and buyTriggerPulse
sellEventQBM = enableSell and canSellMore and sellTriggerPulse
if buyEventQBM
    buyCount  += 1
if sellEventQBM
    sellCount += 1

useMulti         = entryLogicMode == "Multi-Source (3)"
buySignalChosen  = useMulti ? buyConditionMulti  : buyEventQBM
sellSignalChosen = useMulti ? sellConditionMulti : sellEventQBM

trendEMA = ta.ema(close, trendFilterEMALength)
[trendPlusDI, trendMinusDI, trendADX] = ta.dmi(trendFilterDILength, trendFilterADXSmoothing)
strongTrendActive  = enableStrongTrendFilter and trendADX >= trendFilterADXThreshold
bullTrendBias      = close > trendEMA and trendPlusDI >= trendMinusDI
bearTrendBias      = close < trendEMA and trendMinusDI >= trendPlusDI
buySignalFiltered  = strongTrendActive ? (buySignalChosen  and bullTrendBias) : buySignalChosen
sellSignalFiltered = strongTrendActive ? (sellSignalChosen and bearTrendBias) : sellSignalChosen

buyEdge  = buySignalFiltered  and (nz(buySignalFiltered[1]  ? 1 : 0, 0) == 0)
sellEdge = sellSignalFiltered and (nz(sellSignalFiltered[1] ? 1 : 0, 0) == 0)


// DAILY LIMITS
var int    dailyTradeCount = 0
var int    lastTradeDay    = na
var float  dayStartNet     = na
var bool   dayHalted       = false
var string haltReason      = ""
var table  statusTbl  = table.new(position.top_right, 1, 1, border_width=1)
var label  haltLbl    = na
var string _haltText  = ""
var color  _haltColor = na
var int    lastLongSLBar  = na
var int    lastShortSLBar = na

today    = timestamp("GMT-0", year, month, dayofmonth)
isNewDay = na(lastTradeDay) or (today != lastTradeDay)
if isNewDay
    lastTradeDay    := today
    dailyTradeCount := 0
    dayStartNet     := strategy.netprofit
    dayHalted       := false
    haltReason      := ""
    if not na(haltLbl)
        label.delete(haltLbl)
        haltLbl := na
    lastLongSLBar  := na
    lastShortSLBar := na

dayPnl = strategy.netprofit - nz(dayStartNet, strategy.netprofit)

if not dayHalted
    if enableProfitLimit and dayPnl >= profitLimitDollars
        dayHalted  := true
        haltReason := "PROFIT LIMIT"
        strategy.close_all(comment="Daily Profit Limit Hit", alert_message=pick(customLimitClose, defaultClose("flat","limit_profit")))
    if enableLossLimit and dayPnl <= -lossLimitDollars
        dayHalted  := true
        haltReason := "LOSS LIMIT"
        strategy.close_all(comment="Daily Loss Limit Hit", alert_message=pick(customLimitClose, defaultClose("flat","limit_loss")))

canTradeToday       = (not enableTradeLimit or (dailyTradeCount < maxTradesPerDay)) and (not dayHalted)
canEnterNow         = canTradeToday and inAnyWindow
longCooldownActive  = enableReentryCooldownAfterSL and not na(lastLongSLBar)  and (bar_index - lastLongSLBar  < longReentryCooldownBars)
shortCooldownActive = enableReentryCooldownAfterSL and not na(lastShortSLBar) and (bar_index - lastShortSLBar < shortReentryCooldownBars)
canEnterLongNow     = canEnterNow and not longCooldownActive
canEnterShortNow    = canEnterNow and not shortCooldownActive


// ENTRIES
if enableBuy and buyEdge and canEnterLongNow
    if flipOnOpposite and strategy.position_size < 0
        if enableMartingale
            prevQty = math.abs(strategy.position_size)
            isLoss  = close > strategy.position_avg_price
            if isLoss
                mgOverride  := math.min(prevQty * martMultiplier, martMaxContracts)
                mgForceBase := false
            else
                mgOverride  := na
                mgForceBase := true
        strategy.close("Short", alert_message=pick(customShortExit, defaultClose("short","flip")))
    useQty = enableMartingale ? (mgForceBase ? na : (na(mgOverride) ? mgQty : int(math.round(mgOverride)))) : mgQty
    strategy.entry("Long", strategy.long, qty=useQty, alert_message=pick(customLongEntry, defaultOpen("long")))
    mgOverride  := na
    mgForceBase := false
    dailyTradeCount += 1
    if enableTradeLimit and dailyTradeCount >= maxTradesPerDay and not dayHalted
        dayHalted  := true
        haltReason := "TRADE LIMIT"

if enableSell and sellEdge and canEnterShortNow
    if flipOnOpposite and strategy.position_size > 0
        if enableMartingale
            prevQty = math.abs(strategy.position_size)
            isLoss  = close < strategy.position_avg_price
            if isLoss
                mgOverride  := math.min(prevQty * martMultiplier, martMaxContracts)
                mgForceBase := false
            else
                mgOverride  := na
                mgForceBase := true
        strategy.close("Long", alert_message=pick(customLongExit, defaultClose("long","flip")))
    useQty = enableMartingale ? (mgForceBase ? na : (na(mgOverride) ? mgQty : int(math.round(mgOverride)))) : mgQty
    strategy.entry("Short", strategy.short, qty=useQty, alert_message=pick(customShortEntry, defaultOpen("short")))
    mgOverride  := na
    mgForceBase := false
    dailyTradeCount += 1
    if enableTradeLimit and dailyTradeCount >= maxTradesPerDay and not dayHalted
        dayHalted  := true
        haltReason := "TRADE LIMIT"


// ===========================================================================
// EXIT ENGINE
// ===========================================================================
// TP and SL are placed as a SINGLE strategy.exit() OCO order per side.
// This is the only reliable way to keep both levels active simultaneously.
// When one fills, TradingView automatically cancels the other.
// The trailing stop updates every bar by re-issuing the same exit order ID
// with the new stop price — Pine Script replaces the previous stop in-place.
// ===========================================================================

var float entryPrice      = na
var float trailStop       = na
var float peakPrice       = na
var float troughPrice     = na
var bool  trailFrozenAtBE = false
var int   prevPosSign     = 0

curPosSign       = strategy.position_size > 0 ? 1 : strategy.position_size < 0 ? -1 : 0
directionChanged = curPosSign != 0 and prevPosSign != 0 and curPosSign != prevPosSign

if directionChanged
    entryPrice         := na
    trailStop          := na
    peakPrice          := na
    troughPrice        := na
    trailFrozenAtBE    := false
    mart_curTradeQty   := na
    mart_tradeStartNet := na

if strategy.opentrades > 0
    if na(entryPrice)
        entryPrice      := strategy.position_avg_price
        peakPrice       := close
        troughPrice     := close
        trailStop       := na
        trailFrozenAtBE := false
        if enableMartingale
            if na(mart_curTradeQty)
                mart_curTradeQty := math.abs(strategy.position_size)
                if na(mart_baseQty)
                    mart_baseQty := mart_curTradeQty
            if na(mart_tradeStartNet)
                mart_tradeStartNet := strategy.netprofit

    // Use high/low so intrabar wicks correctly trigger trail start and BE freeze.
    // If price wicks into profit and pulls back within the same bar, the peak
    // is still captured and the trail/BE activates on the next bar's exit order.
    peakPrice   := math.max(peakPrice,   high)
    troughPrice := math.min(troughPrice, low)

    // ── LONG ──────────────────────────────────────────────────────────────
    if strategy.position_size > 0
        moved       = f_trailStart_moved(entryPrice, peakPrice, troughPrice, true)
        beLockPrice = entryPrice + f_ticksToPrice(breakEvenOffsetTicks)

        // Compute effective stop level
        float effectiveStop = na
        if enableStaticSL
            effectiveStop := entryPrice - f_staticSL_d()
        else
            if trailFrozenAtBE
                trailStop := beLockPrice
                if enablePostBEStepTrail
                    favTicks = (peakPrice - beLockPrice) / _tick
                    if favTicks >= postBEStartAfterTicks
                        steps     = math.floor((favTicks - postBEStartAfterTicks) / postBETrailFrequencyTicks) + 1
                        trailStop := math.max(trailStop, beLockPrice + steps * postBETrailStepTicks * _tick)
            else
                if moved >= f_trailStart_threshold()
                    newTS     = peakPrice - f_trailDistance_d()
                    trailStop := na(trailStop) ? newTS : math.max(trailStop, newTS)
                    if freezeTrailingAtBE and trailStop >= beLockPrice
                        trailStop       := beLockPrice
                        trailFrozenAtBE := true
                else
                    trailStop := entryPrice - f_initialSL_d()
            effectiveStop := trailStop

        // Single OCO exit: both limit (TP) and stop (SL) in one call.
        // Pine Script keeps whichever hits first and cancels the other.
        float tpLevel = enableStaticTP ? entryPrice + f_staticTP_d() : na
        if not na(effectiveStop) or not na(tpLevel)
            strategy.exit("Long Exit", "Long",
                 stop          = effectiveStop,
                 limit         = tpLevel,
                 alert_message = pick(customLongExit, defaultClose("long","exit")))

    // ── SHORT ─────────────────────────────────────────────────────────────
    if strategy.position_size < 0
        moved       = f_trailStart_moved(entryPrice, peakPrice, troughPrice, false)
        beLockPrice = entryPrice - f_ticksToPrice(breakEvenOffsetTicks)

        float effectiveStop = na
        if enableStaticSL
            effectiveStop := entryPrice + f_staticSL_d()
        else
            if trailFrozenAtBE
                trailStop := beLockPrice
                if enablePostBEStepTrail
                    favTicks = (beLockPrice - troughPrice) / _tick
                    if favTicks >= postBEStartAfterTicks
                        steps     = math.floor((favTicks - postBEStartAfterTicks) / postBETrailFrequencyTicks) + 1
                        trailStop := math.min(trailStop, beLockPrice - steps * postBETrailStepTicks * _tick)
            else
                if moved >= f_trailStart_threshold()
                    newTS     = troughPrice + f_trailDistance_d()
                    trailStop := na(trailStop) ? newTS : math.min(trailStop, newTS)
                    if freezeTrailingAtBE and trailStop <= beLockPrice
                        trailStop       := beLockPrice
                        trailFrozenAtBE := true
                else
                    trailStop := entryPrice + f_initialSL_d()
            effectiveStop := trailStop

        float tpLevel = enableStaticTP ? entryPrice - f_staticTP_d() : na
        if not na(effectiveStop) or not na(tpLevel)
            strategy.exit("Short Exit", "Short",
                 stop          = effectiveStop,
                 limit         = tpLevel,
                 alert_message = pick(customShortExit, defaultClose("short","exit")))

// SL cooldown: detect SL exits by checking if trade closed at a loss
if tradeClosedNow
    _idx = strategy.closedtrades - 1
    _pl  = strategy.closedtrades.profit(_idx)
    _dir = strategy.closedtrades.size(_idx)
    if _pl < 0
        if _dir > 0
            lastLongSLBar  := bar_index
        else
            lastShortSLBar := bar_index

// Reset when flat
if strategy.opentrades == 0
    entryPrice         := na
    trailStop          := na
    peakPrice          := na
    troughPrice        := na
    trailFrozenAtBE    := false
    mart_curTradeQty   := na
    mart_tradeStartNet := na


// PER-WINDOW FLATTEN
if flattenAtEveningEnd and endOfEvening
    strategy.close_all(comment="Flatten: End of Evening",    alert_message=pick(customSessionExit, defaultClose("flat","session")))
if flattenAtOvernightEnd and endOfOvernight
    strategy.close_all(comment="Flatten: End of Overnight",  alert_message=pick(customSessionExit, defaultClose("flat","session")))
if flattenAtNYEnd and endOfNY
    strategy.close_all(comment="Flatten: End of NY Session", alert_message=pick(customSessionExit, defaultClose("flat","session")))

prevPosSign := curPosSign


// HALT DISPLAY
if dayHalted and not dayHalted[1]
    _haltText  := "TRADING HALTED: " + haltReason
    _haltColor := haltReason == "PROFIT LIMIT" ? color.new(color.green, 0) :
                  haltReason == "LOSS LIMIT"   ? color.new(color.red,   0) : color.new(color.orange, 0)
    haltLbl    := label.new(bar_index, close, _haltText, xloc=xloc.bar_index, yloc=yloc.price,
                  color=_haltColor, style=label.style_label_down, textcolor=color.white)

var color _bg = na
_bg := na
if dayHalted
    _bg := haltReason == "PROFIT LIMIT" ? color.new(color.green, 85) :
           haltReason == "LOSS LIMIT"   ? color.new(color.red,   85) : color.new(color.orange, 85)
bgcolor(_bg)

if barstate.islast
    table.clear(statusTbl, 0, 0, 0, 0)
    txt    = "Galgoom - Status\n" +
             "Day PnL: " + str.tostring(strategy.netprofit - nz(dayStartNet, strategy.netprofit)) + "\n" +
             "Trades: "  + str.tostring(dailyTradeCount) +
             (enableTradeLimit ? "/" + str.tostring(maxTradesPerDay) : "/unlimited") + "\n" +
             (dayHalted ? "HALTED (" + haltReason + ")" : "Active")
    _tblBg = dayHalted ? color.new(color.gray, 20) : color.new(color.silver, 80)
    table.cell(statusTbl, 0, 0, txt, text_color=color.white, bgcolor=_tblBg)

plotshape(endOfEvening,   title="End of Evening",   style=shape.flag, location=location.top, size=size.tiny, text="EoE")
plotshape(endOfOvernight, title="End of Overnight", style=shape.flag, location=location.top, size=size.tiny, text="EoO")
plotshape(endOfNY,        title="End of NY",        style=shape.flag, location=location.top, size=size.tiny, text="EoN")
````
