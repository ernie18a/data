# Webhook Alert Strategy Template

- url: https://www.tradingview.com/script/zrDoqm9F-Webhook-Alert-Strategy-Template/
- type: strategy
- pine_id: PUB;0a61832175414858b80f2cc1401eda05
- version: 1.0

## Description

Educational strategy shell that builds webhook-ready alert messages from strategy order fills.

Why this exists
Most traders can write an entry condition. The hard part is packaging a clean, risk-defined exit and a stable alert string that an external webhook receiver can parse. This template is a starting shell for that workflow.

What it does
- Demo entry: MA crossover (EMA/SMA/WMA/RMA selectable). Replace this with your own logic.
- Risk exits: ATR-based stop distance (or fixed pip distance), take-profit from risk:reward.
- Alert messages: attaches comma-separated command strings to strategy entries and exits using alert_message.

Message format examples
BUY,XAUUSD,VOL=0.01,SL=120.5,TP=241,TPSLTYPE=PIPS
SELL,XAUUSD,VOL=0.01,SL=120.5,TP=241,TPSLTYPE=PIPS
CLOSE,XAUUSD

How to use
1. Add the strategy to a standard chart (gold/forex/indices work well).
2. Set VOL, ATR stop, and RR in inputs.
3. Create one alert on this strategy.
4. Choose order fills and alert() function calls.
5. Set the alert message field to exactly: {{strategy.order.alert_message}}
6. Enable webhook URL notifications and paste your own webhook endpoint.

What this is not
This is not a signal service and not financial advice. Default MA entry is only a placeholder so the shell compiles and can be tested. Backtest results with the demo entry are not a performance claim.

Originality
The useful part is the combination of risk-defined strategy exits plus explicit webhook command string generation on fills, so users can learn alert_message plumbing without rebuilding exits from scratch.

Defaults used for this publication
- Symbol: XAUUSD (OANDA)
- Timeframe: 1D
- Initial capital: 10000
- Position size: 2% of equity
- Commission: 0.02%
- Slippage: 2 ticks

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © trade-wzrd
//
// Webhook Alert Strategy Template
// Educational shell for building webhook-ready alert messages from strategy fills.
// Alert strings use a simple comma-separated command format:
//   BUY,SYMBOL,VOL=0.01,SL=100,TP=200,TPSLTYPE=PIPS
//   SELL,SYMBOL,VOL=0.01,SL=100,TP=200,TPSLTYPE=PIPS
//   CLOSE,SYMBOL
//
// This is a template, not a signal service. Replace the demo MA entry with your own logic.

//@version=6
strategy(
     title              = "Webhook Alert Strategy Template",
     shorttitle         = "Webhook Strat",
     overlay            = true,
     initial_capital    = 10000,
     default_qty_type   = strategy.percent_of_equity,
     default_qty_value  = 2,
     commission_type    = strategy.commission.percent,
     commission_value   = 0.02,
     slippage           = 2,
     pyramiding         = 0,
     process_orders_on_close = true,
     calc_on_every_tick = false
 )

// ─── Inputs ──────────────────────────────────────────────────────────────────
grpEntry = "Demo entry (replace with your logic)"
fastLen  = input.int(20, "Fast MA length", minval=1, group=grpEntry)
slowLen  = input.int(50, "Slow MA length", minval=1, group=grpEntry)
maType   = input.string("EMA", "MA type", options=["EMA", "SMA", "WMA", "RMA"], group=grpEntry)

grpRisk = "Risk / exits"
useAtrStop = input.bool(true, "Use ATR stop distance", group=grpRisk)
atrLen     = input.int(14, "ATR length", minval=1, group=grpRisk)
atrMult    = input.float(1.5, "ATR stop multiplier", minval=0.1, step=0.1, group=grpRisk)
fixedPips  = input.float(100, "Fixed SL distance (if ATR off)", minval=0.1, group=grpRisk)
rr         = input.float(2.0, "Risk:Reward for TP", minval=0.1, step=0.1, group=grpRisk)
tpslType   = input.string("PIPS", "TPSLTYPE tag in alert", options=["PIPS", "PRICE", "TICKS"], group=grpRisk)

grpAlert = "Webhook alert message"
useChartSymbol = input.bool(true, "Use chart symbol in alert", group=grpAlert)
customSymbol   = input.string("XAUUSD", "Custom symbol if chart symbol off", group=grpAlert)
vol            = input.float(0.01, "VOL in alert message", minval=0.01, step=0.01, group=grpAlert)
showLabels     = input.bool(true, "Show entry labels", group=grpAlert)

// ─── Helpers ─────────────────────────────────────────────────────────────────
ma(src, len) =>
    switch maType
        "SMA" => ta.sma(src, len)
        "WMA" => ta.wma(src, len)
        "RMA" => ta.rma(src, len)
        => ta.ema(src, len)

pipSize() =>
    // FX/metals style: if mintick is tiny, use 10*mintick as pip, else mintick
    syminfo.mintick < 0.01 ? syminfo.mintick * 10.0 : syminfo.mintick

toPips(priceDist) =>
    priceDist / pipSize()

sym = useChartSymbol ? str.replace_all(syminfo.ticker, "!", "") : customSymbol

buildEntryMsg(side, slPips, tpPips) =>
    side + "," + sym + ",VOL=" + str.tostring(vol) + ",SL=" + str.tostring(slPips, "#.##") + ",TP=" + str.tostring(tpPips, "#.##") + ",TPSLTYPE=" + tpslType

buildCloseMsg() =>
    "CLOSE," + sym

// ─── Demo entry ──────────────────────────────────────────────────────────────
fast = ma(close, fastLen)
slow = ma(close, slowLen)
longCond  = ta.crossover(fast, slow)
shortCond = ta.crossunder(fast, slow)

plot(fast, "Fast MA", color=color.new(color.teal, 0))
plot(slow, "Slow MA", color=color.new(color.orange, 0))

atr = ta.atr(atrLen)
slDist = useAtrStop ? atr * atrMult : fixedPips * pipSize()
tpDist = slDist * rr
slPips = toPips(slDist)
tpPips = toPips(tpDist)

// ─── Strategy + webhook messages ─────────────────────────────────────────────
if longCond and strategy.position_size <= 0
    longSl = close - slDist
    longTp = close + tpDist
    msg = buildEntryMsg("BUY", slPips, tpPips)
    strategy.entry("Long", strategy.long, alert_message=msg)
    strategy.exit("Long Exit", from_entry="Long", stop=longSl, limit=longTp, alert_message=buildCloseMsg())
    if showLabels
        label.new(bar_index, low, msg, style=label.style_label_up, color=color.new(color.teal, 15), textcolor=color.white, size=size.small)

if shortCond and strategy.position_size >= 0
    shortSl = close + slDist
    shortTp = close - tpDist
    msg = buildEntryMsg("SELL", slPips, tpPips)
    strategy.entry("Short", strategy.short, alert_message=msg)
    strategy.exit("Short Exit", from_entry="Short", stop=shortSl, limit=shortTp, alert_message=buildCloseMsg())
    if showLabels
        label.new(bar_index, high, msg, style=label.style_label_down, color=color.new(color.red, 15), textcolor=color.white, size=size.small)
````
