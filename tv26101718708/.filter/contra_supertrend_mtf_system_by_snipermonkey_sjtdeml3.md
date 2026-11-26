# Contra Supertrend MTF System by SNIPERMONKEY

- url: https://www.tradingview.com/script/SjTDEmL3-Contra-Supertrend-MTF-System-by-SNIPERMONKEY/
- type: indicator
- pine_id: PUB;caa7b53e408647eca829cfacf75fdfcc
- version: 2.0

## Description

Contra Supertrend MTF System

A dual-timeframe Supertrend indicator built for a contrarian (mean-reversion) entry model: it looks for the lower timeframe to reverse against the prevailing direction of a higher timeframe, then rides the trade using the lower timeframe alone for the exit.

Core Logic

Most multi-timeframe Supertrend setups look for both timeframes to agree before entering. This one does the opposite on purpose — it enters when they disagree:

Long entry — the higher (confirmation) timeframe Supertrend is still in a downtrend, and the lower (entry) timeframe Supertrend flips into an uptrend. The lower-TF flip is read as an early reversal signal against the higher-TF trend.
Short entry — the mirror case: higher timeframe still in an uptrend, lower timeframe flips into a downtrend.
Exit — once in a trade, only the entry (lower) timeframe governs the exit. The position closes on the next opposite flip of the entry-timeframe Supertrend, regardless of what the higher timeframe is doing by then. A configurable force-exit time also flattens any open position at end of session.

If both timeframes are already aligned in the same direction, no signal fires — the indicator waits for a genuine contra setup rather than trading with the trend.

Signals

Exactly four, plotted on the chart and available as alerts:

BUY — contra long entry
SELL — contra short entry
BUY EXIT — long position closed
SELL EXIT — short position closed

Key Features

Fully independent timeframe settings — separate timeframe, ATR length and factor for the entry (lower) and confirmation (higher) Supertrend, so any combination (1m/5m, 3m/15m, 5m/1H, etc.) can be configured without touching the chart's own timeframe.
Non-repainting MTF data — both Supertrend calculations are pulled through request.security with barmerge.gaps_off and barmerge.lookahead_off, and all signals are gated on barstate.isconfirmed, so nothing fires early or repaints after the fact.
Session entry window — configurable start/end time restricts new entries to a defined trading window.
Forced flat time — a separate configurable time forces any open position closed, independent of the Supertrend signal.
Carry-forward on session open — if the contra condition (opposite-direction Supertrends) is already true the moment the entry window opens, a signal fires immediately rather than waiting for a fresh flip.

Inputs

Entry Timeframe group: timeframe, ATR length, factor
Confirmation Timeframe group: timeframe, ATR length, factor, toggle to show/hide its plot
Session Settings: entry window start/end (hour/minute), forced exit time (hour/minute)

How to Use

Add to any chart — the chart's own timeframe doesn't need to match either Supertrend setting, since both are fetched independently. Set your entry (lower) and confirmation (higher) timeframes, tune ATR length/factor per side, and set your session window to match your trading hours. Use the four alert conditions to automate notifications.

Disclaimer

This is a technical analysis tool, not financial advice. Backtest and forward-test thoroughly on your instrument and timeframe combination before using in live trading. Past behavior of any indicator does not guarantee future results. Trade at your own risk.

## Source Code

````pine
//@version=6
indicator("Contra Supertrend MTF System by SNIPERMONKEY", overlay=true)

// ============ ENTRY TF (LOWER) SETTINGS ============
grpEntry    = "Entry Timeframe (Lower)"
entryTF     = input.timeframe("1", "Timeframe", group=grpEntry)
atrLenEntry = input.int(10, "ATR Length", group=grpEntry)
factorEntry = input.float(3.0, "Factor", step=0.1, group=grpEntry)

// ============ CONFIRM TF (HIGHER) SETTINGS ============
grpConfirm      = "Confirmation Timeframe (Higher)"
confirmTF       = input.timeframe("5", "Timeframe", group=grpConfirm)
atrLenConfirm   = input.int(10, "ATR Length", group=grpConfirm)
factorConfirm   = input.float(3.0, "Factor", step=0.1, group=grpConfirm)
showConfirmLine = input.bool(true, "Plot Confirmation Supertrend", group=grpConfirm)

grpSession   = "Session Settings"
sessStartH   = input.int(9,  "Entry Start Hour",   group=grpSession)
sessStartM   = input.int(25, "Entry Start Minute", group=grpSession)
sessEndH     = input.int(15, "Entry End Hour",     group=grpSession)
sessEndM     = input.int(0,  "Entry End Minute",   group=grpSession)
exitH        = input.int(15, "Force Exit Hour",    group=grpSession)
exitM        = input.int(10, "Force Exit Minute",  group=grpSession)

// ============ SESSION TIME GATING (minutes-since-midnight) ============
curMin      = hour * 60 + minute
sessStartMn = sessStartH * 60 + sessStartM
sessEndMn   = sessEndH * 60 + sessEndM
exitMn      = exitH * 60 + exitM

inEntryWindow = curMin >= sessStartMn and curMin < sessEndMn
atForceExit   = curMin >= exitMn

// ============ SUPERTREND — ENTRY TF (confirmed-only MTF fetch) ============
get1() =>
    [_st, _dir] = ta.supertrend(factorEntry, atrLenEntry)
    [_st, _dir]
[st1, dir1] = request.security(syminfo.tickerid, entryTF, get1(), barmerge.gaps_off, barmerge.lookahead_off)

// ============ SUPERTREND — CONFIRM TF (confirmed-only MTF fetch) ============
get5() =>
    [_st, _dir] = ta.supertrend(factorConfirm, atrLenConfirm)
    [_st, _dir]
[st5, dir5] = request.security(syminfo.tickerid, confirmTF, get5(), barmerge.gaps_off, barmerge.lookahead_off)

bull1 = dir1 < 0
bear1 = dir1 > 0
bull5 = dir5 < 0
bear5 = dir5 > 0

flippedBull1 = bull1 and dir1[1] > 0
flippedBear1 = bear1 and dir1[1] < 0

sessionJustOpened = inEntryWindow and not inEntryWindow[1]

// ============ STATE ============
var int posState = 0   // 0 = flat, 1 = long, -1 = short

canEnterLong  = inEntryWindow and posState == 0 and flippedBull1 and bear5
canEnterShort = inEntryWindow and posState == 0 and flippedBear1 and bull5

carryLong  = sessionJustOpened and posState == 0 and bull1 and bear5
carryShort = sessionJustOpened and posState == 0 and bear1 and bull5

buySignal  = barstate.isconfirmed and (canEnterLong  or carryLong)
sellSignal = barstate.isconfirmed and (canEnterShort or carryShort)

buyExitSignal  = barstate.isconfirmed and posState == 1  and (flippedBear1 or atForceExit)
sellExitSignal = barstate.isconfirmed and posState == -1 and (flippedBull1 or atForceExit)

if buySignal
    posState := 1
if sellSignal
    posState := -1
if buyExitSignal
    posState := 0
if sellExitSignal
    posState := 0

// ============ PLOTS ============
plot(st1, "Supertrend (Entry TF)", color = bull1 ? color.green : color.red)
plot(showConfirmLine ? st5 : na, "Supertrend (Confirm TF)", color = bull5 ? color.new(color.green, 60) : color.new(color.red, 60), style=plot.style_circles)

bgcolor(inEntryWindow ? color.new(color.blue, 92) : na, title="Entry Window")

plotshape(buySignal,  "BUY",       shape.triangleup,   location.belowbar, color.new(color.green, 0), size=size.small, text="BUY")
plotshape(sellSignal, "SELL",      shape.triangledown, location.abovebar, color.new(color.red, 0),   size=size.small, text="SELL")
plotshape(buyExitSignal,  "BUY EXIT",  shape.xcross, location.abovebar, color.new(color.orange, 0), size=size.tiny, text="BUY EXIT")
plotshape(sellExitSignal, "SELL EXIT", shape.xcross, location.belowbar, color.new(color.orange, 0), size=size.tiny, text="SELL EXIT")

alertcondition(buySignal,  "Contra BUY",  "Contra Supertrend BUY")
alertcondition(sellSignal, "Contra SELL", "Contra Supertrend SELL")
alertcondition(buyExitSignal,  "BUY EXIT",  "Contra Supertrend BUY EXIT")
alertcondition(sellExitSignal, "SELL EXIT", "Contra Supertrend SELL EXIT")
````
