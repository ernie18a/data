# Trade Wzrd - Session Open Strategy Shell

- url: https://www.tradingview.com/script/9pgLP2QW-Trade-Wzrd-Session-Open-Strategy-Shell/
- type: strategy
- pine_id: PUB;e7b23688f27e451aa065682f39595a67
- version: 1.0

## Description

Trade Wzrd - Session Open Strategy Shell

WHAT IT IS
Educational strategy shell that only allows new entries while price is inside a user-defined session window. Optional modes: break of the developing session high/low, or a simple MA cross for baseline testing. Orders carry webhook-ready alert_message strings built through a shared open-source string library.

This is a template for learning session-filtered automation wiring. It is not a signal service.

WHY IT EXISTS (ORIGINALITY)
Many public strategies fire all day. Prop and desk workflows usually care about a session (for example cash open or London/NY window) and need clean entry/exit alert text for external execution. This script combines:
1) a session gate
2) optional session-range break entries
3) ATR or fixed risk exits with R-multiple targets
4) structured alert_message strings for BUY/SELL and CLOSE

HOW IT WORKS
1) Session input defines when entries are allowed (chart/exchange timezone rules apply as on TradingView).
2) While in session, the script tracks session high and low.
3) Entry mode A: break above session high or below session low.
4) Entry mode B: EMA cross (for simple tests when break mode is off).
5) Optional max one entry per session day.
6) Stop distance uses ATR multiplier or a fixed distance; take-profit uses risk:reward.
7) alert_message values use comma-separated command text (BUY/SELL with VOL or RISK, SL, TP, TPSLTYPE; CLOSE on exits).

HOW TO USE
1) Add to a clean chart (defaults intended for liquid FX/metals such as XAUUSD).
2) Set the session window to the hours you actually trade.
3) Choose break mode or MA mode under Entry logic.
4) Set Trade Wzrd Automation size mode (VOL or RISK), size value, and TPSLTYPE.
5) Create a strategy alert; set the message to:
   {{strategy.order.alert_message}}
6) Point the alert webhook field at whatever endpoint you already use.
7) Use Symbol override when your broker symbol differs from the chart ticker.

DEFAULTS
- Commission and slippage are set in strategy properties for more realistic tests
- Position sizing default is percent of equity for the strategy tester (separate from alert VOL/RISK text)
- Magic default example tag is provided and can be cleared

LIMITATIONS
- Session range break is a simple educational structure, not a complete prop system
- Past results do not predict future results
- Not intended for buy/sell use on non-standard chart types
- You own risk, symbol mapping, and execution choices

No external links are required to understand or use this script.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © trade-wzrd
//
// Trade Wzrd - Session Open Strategy Shell
// Educational strategy: only evaluates entries inside a user session window.
// Webhook strings via TradeWzrdAlerts library. Not a signal service.

//@version=6
strategy(
     title                   = "Trade Wzrd - Session Open Strategy Shell",
     shorttitle              = "TW Session",
     overlay                 = true,
     initial_capital         = 10000,
     default_qty_type        = strategy.percent_of_equity,
     default_qty_value       = 2,
     commission_type         = strategy.commission.percent,
     commission_value        = 0.02,
     slippage                = 2,
     pyramiding              = 0,
     process_orders_on_close = true,
     calc_on_every_tick      = false,
     max_labels_count        = 50
 )

import trade-wzrd/TradeWzrdAlerts/1 as TW

// ── Trade Wzrd Automation ─────────────────────────────────────────────────
grpTW = "Trade Wzrd Automation"
twEnabled   = input.bool(true, "Enable automation messages", group=grpTW)
twSymbol    = input.string("", "Symbol override (blank = chart)", group=grpTW)
twSizeMode  = input.string("VOL", "Size mode", options=["VOL", "RISK"], group=grpTW)
twSizeVal   = input.float(0.01, "Size value (lots or risk %)", minval=0.01, step=0.01, group=grpTW)
twTpslType  = input.string("PIPS", "TPSLTYPE", options=["PIPS", "PRICE", "TICKS"], group=grpTW)
twMagic     = input.string("301", "Magic", group=grpTW)
twComment   = input.string("SessionOpen", "Comment", group=grpTW)
twLabels    = input.bool(true, "Show message labels", group=grpTW)

// ── Risk / exits ──────────────────────────────────────────────────────────
grpRisk    = "Risk / exits"
useAtrStop = input.bool(true, "Use ATR stop distance", group=grpRisk)
atrLen     = input.int(14, "ATR length", minval=1, group=grpRisk)
atrMult    = input.float(1.5, "ATR stop multiplier", minval=0.1, step=0.1, group=grpRisk)
fixedDist  = input.float(100.0, "Fixed SL distance if ATR off", minval=0.1, group=grpRisk)
rr         = input.float(2.0, "Risk:Reward for TP", minval=0.1, step=0.1, group=grpRisk)

// ── Entry: session window + structure demo ────────────────────────────────
grpEntry = "Entry logic (session)"
sess     = input.session("0000-2359", "Session (exchange timezone)", group=grpEntry)
useBreak = input.bool(false, "Enter on session-range break (else MA cross)", group=grpEntry)
fastLen  = input.int(20, "Fast MA (if MA mode)", minval=1, group=grpEntry)
slowLen  = input.int(50, "Slow MA (if MA mode)", minval=1, group=grpEntry)
onePerSession = input.bool(false, "Max one entry per session day", group=grpEntry)

inSession = not na(time(timeframe.period, sess))
// Session range: track high/low while in session; break after first bars
var float sessHi = na
var float sessLo = na
var int   sessEntries = 0
var int   lastSessId = na

// session id = day of year * 10 + week roughly via time
sessId = year(time) * 1000 + month(time) * 50 + dayofmonth(time)
if sessId != lastSessId
    lastSessId := sessId
    sessEntries := 0
    sessHi := na
    sessLo := na

if inSession
    sessHi := na(sessHi) ? high : math.max(sessHi, high)
    sessLo := na(sessLo) ? low : math.min(sessLo, low)
else
    // keep last range for break logic on re-entry; optional reset off-session
    sessHi := sessHi
    sessLo := sessLo

fast = ta.ema(close, fastLen)
slow = ta.ema(close, slowLen)
plot(fast, "Fast MA", color=color.new(color.teal, inSession ? 0 : 70))
plot(slow, "Slow MA", color=color.new(color.orange, inSession ? 0 : 70))
plot(sessHi, "Session high", color=color.new(color.green, 60), style=plot.style_linebr)
plot(sessLo, "Session low", color=color.new(color.red, 60), style=plot.style_linebr)

bgcolor(inSession ? color.new(color.blue, 92) : na, title="In session")

canEnter = inSession and (not onePerSession or sessEntries == 0)
longBreak  = useBreak and canEnter and not na(sessHi) and ta.crossover(close, sessHi)
shortBreak = useBreak and canEnter and not na(sessLo) and ta.crossunder(close, sessLo)
longMa     = not useBreak and canEnter and ta.crossover(fast, slow)
shortMa    = not useBreak and canEnter and ta.crossunder(fast, slow)
longCond   = longBreak or longMa
shortCond  = shortBreak or shortMa

// ── Messages + orders ─────────────────────────────────────────────────────
sym = TW.resolveSymbol(twSymbol)
pipSize() =>
    syminfo.mintick < 0.01 ? syminfo.mintick * 10.0 : syminfo.mintick

atr = ta.atr(atrLen)
slDistPrice = useAtrStop ? atr * atrMult : fixedDist * (twTpslType == "PRICE" ? 1.0 : pipSize())
tpDistPrice = slDistPrice * rr

slForMsg() =>
    twTpslType == "PRICE" ? slDistPrice : (useAtrStop ? slDistPrice / pipSize() : fixedDist)
tpForMsg() =>
    twTpslType == "PRICE" ? tpDistPrice : slForMsg() * rr

buildEntry(string side) =>
    TW.entryDist(side, sym, slForMsg(), tpForMsg(), twTpslType, twSizeVal, twSizeMode, twMagic, twComment)

if longCond and strategy.position_size <= 0
    longSl = close - slDistPrice
    longTp = close + tpDistPrice
    msg = buildEntry("BUY")
    if twEnabled and str.length(msg) > 0
        strategy.entry("Long", strategy.long, alert_message=msg)
        strategy.exit("Long Exit", from_entry="Long", stop=longSl, limit=longTp, alert_message=TW.closeFull(sym, "BUY", twMagic))
        sessEntries += 1
        if twLabels
            label.new(bar_index, low, msg, style=label.style_label_up, color=color.new(color.teal, 15), textcolor=color.white, size=size.small)
    else if not twEnabled
        strategy.entry("Long", strategy.long)
        strategy.exit("Long Exit", from_entry="Long", stop=longSl, limit=longTp)
        sessEntries += 1

if shortCond and strategy.position_size >= 0
    shortSl = close + slDistPrice
    shortTp = close - tpDistPrice
    msg = buildEntry("SELL")
    if twEnabled and str.length(msg) > 0
        strategy.entry("Short", strategy.short, alert_message=msg)
        strategy.exit("Short Exit", from_entry="Short", stop=shortSl, limit=shortTp, alert_message=TW.closeFull(sym, "SELL", twMagic))
        sessEntries += 1
        if twLabels
            label.new(bar_index, high, msg, style=label.style_label_down, color=color.new(color.red, 15), textcolor=color.white, size=size.small)
    else if not twEnabled
        strategy.entry("Short", strategy.short)
        strategy.exit("Short Exit", from_entry="Short", stop=shortSl, limit=shortTp)
        sessEntries += 1
````
