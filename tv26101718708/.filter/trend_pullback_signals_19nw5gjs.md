# Trend Pullback Signals

- url: https://www.tradingview.com/script/19nw5gJS-Trend-Pullback-Signals/
- type: indicator
- pine_id: PUB;d49aa8b40b5644c295746bdf6d378f05
- version: 1.0

## Description

*Trend Pullback Signals**

A clean, rules-based BUY/SELL signal tool built on one of the most durable ideas in trading: trade pullbacks in the direction of the higher-timeframe trend, only during high-participation hours, with a fixed stop and defined targets. No clutter, no guessing — the chart tells you the trend, the window, and the exact level for your stop and targets.

**How it works**

Three filters have to line up before a signal fires:

- **Trend** — the indicator reads a higher timeframe (default 30m) and only allows longs when that timeframe is above a rising EMA, shorts when it's below a falling one. When the higher timeframe is flat, it stays silent.
- **Window** — signals are limited to a session window you choose (default 08:30–10:30 Central), so you skip the low-participation chop.
- **Pullback reclaim** — in an uptrend, price has to pull back to VWAP (or an EMA) and then close back above it; the mirror applies in a downtrend.

When all three align, a BUY or SELL prints on the bar close, and three lines are drawn automatically: a stop placed beyond the recent swing (red dashed), Target 1 at 1.5R (green dotted), and Target 2 at 3R (green dashed). A suggested management approach is to take partial profit at Target 1, move the stop to breakeven, and let the remainder run toward Target 2.

**On-chart guidance**

The background tints green or red to show the active trend direction, and shades the trade window in blue, so you can see at a glance why a signal is or isn't allowed. A status box summarizes the current trend, whether the window is open, and whether a trade is active. Only one signal runs at a time — a new one won't appear until the current one resolves at its stop or Target 2 — which keeps the chart readable.

**Repaint disclosure**

Signals print on bar close and do not repaint — once a BUY or SELL appears, it stays on that bar, and the stop and target levels are fixed at entry. The higher-timeframe trend filter is non-repainting: it reads the last *closed* higher-timeframe bar, so no future data is used. Stop and target lines extend forward as the trade stays open; that is the active trade being tracked, not the signal moving.

**Key settings**

- *Trend timeframe / EMA length* — the higher timeframe and moving average that define direction.
- *Trade window / Timezone* — when signals are allowed.
- *Pullback reference* — VWAP or EMA.
- *Stop basis, lookback, buffer* — how the stop is placed.
- *Target 1 / Target 2 (R)* — where the profit targets sit relative to risk.

**How to use**

Trade only in the direction the trend tint allows, only while the window is open. When a signal fires, the stop and targets are already drawn — manage partials at Target 1 and trail or exit the rest at Target 2. The signal tells you when conditions align; your risk management does the rest.

A clean chart of past signals always looks good in hindsight. Before risking real capital, forward-test on a simulator and confirm the targets actually fill the way the lines suggest. This is an analysis tool, not financial advice — trends and edges change with market conditions. Trade your own plan and manage your risk.

---

Want a one-line preview hook for the top? Something like "Trade pullbacks with the trend, only when the odds favor it — BUY/SELL signals with stops and targets built in" reads well as the scroll-by line if you publish it publicly.

## Source Code

````pine
//@version=6
indicator("Trend Pullback Signals", "TPB Signals", overlay=true, max_lines_count=500, max_labels_count=500)

// ===== INPUTS =====
gB = "① Trend (HTF)"
biasTF  = input.timeframe("30", "Trend timeframe", group=gB)
biasLen = input.int(50, "Trend EMA length", group=gB)

gW = "② When to trade (CT)"
tz        = input.string("America/Chicago", "Timezone", group=gW)
tradeSess = input.session("0830-1030", "Trade window", group=gW)

gE = "③ Entry"
refType   = input.string("VWAP", "Pullback to", options=["VWAP","EMA"], group=gE)
pullEmaLen= input.int(20, "EMA length (if EMA)", group=gE)
needClose = input.bool(true, "Require close in trend direction", group=gE)

gR = "④ Stop & Targets"
stopMode    = input.string("Swing", "Stop basis", options=["Swing","ATR"], group=gR)
swingLook   = input.int(5, "Swing lookback (bars)", group=gR)
atrLen      = input.int(14, "ATR length", group=gR)
atrStopMult = input.float(1.0, "ATR stop ×", step=0.1, group=gR)
stopBufTks  = input.int(2, "Stop buffer (ticks)", group=gR)
tp1R        = input.float(1.5, "Target 1 (R)", step=0.1, group=gR)
tp2R        = input.float(3.0, "Target 2 (R)", step=0.1, group=gR)

gV = "⑤ Visuals"
showBias = input.bool(true, "Tint trend", group=gV)
showWin  = input.bool(true, "Shade trade window", group=gV)
showTbl  = input.bool(true, "Show status box", group=gV)

// ===== CALCS =====
atr  = ta.atr(atrLen)
tick = syminfo.mintick

// Non-repainting 30m trend (last CLOSED bar)
[htfEma, htfEmaPrev, htfClose] = request.security(syminfo.tickerid, biasTF,
     [ta.ema(close, biasLen)[1], ta.ema(close, biasLen)[2], close[1]],
     lookahead=barmerge.lookahead_on)
bullBias = htfClose > htfEma and htfEma > htfEmaPrev
bearBias = htfClose < htfEma and htfEma < htfEmaPrev

refLine = refType == "VWAP" ? ta.vwap(hlc3) : ta.ema(close, pullEmaLen)
inWin   = not na(time(timeframe.period, tradeSess, tz))

// Pullback reclaim triggers
tagBull  = low  <= refLine or low[1]  <= refLine[1]
tagBear  = high >= refLine or high[1] >= refLine[1]
trigBull = bullBias and inWin and tagBull and close > refLine and (not needClose or close > open)
trigBear = bearBias and inWin and tagBear and close < refLine and (not needClose or close < open)

longStopRaw  = stopMode == "Swing" ? ta.lowest(low,  swingLook) - stopBufTks * tick : close - atr * atrStopMult
shortStopRaw = stopMode == "Swing" ? ta.highest(high, swingLook) + stopBufTks * tick : close + atr * atrStopMult

// ===== SIGNAL STATE (one at a time) =====
var int   sig    = 0
var float slP    = na
var float tp1P   = na
var float tp2P   = na
var line  lnSL   = na
var line  lnT1   = na
var line  lnT2   = na

bool buySig  = false
bool sellSig = false

// resolve / reset at new day
if timeframe.change("D")
    sig := 0

if barstate.isconfirmed
    // resolve active signal
    if sig == 1
        if low <= slP or high >= tp2P
            sig := 0
    else if sig == -1
        if high >= slP or low <= tp2P
            sig := 0

    // new BUY
    if sig == 0 and trigBull and (close - longStopRaw) > tick
        sig  := 1
        risk = close - longStopRaw
        slP  := longStopRaw
        tp1P := close + tp1R * risk
        tp2P := close + tp2R * risk
        buySig := true
        lnSL := line.new(bar_index, slP,  bar_index, slP,  color=color.new(color.red, 0),   width=1, style=line.style_dashed)
        lnT1 := line.new(bar_index, tp1P, bar_index, tp1P, color=color.new(color.green, 0), width=1, style=line.style_dotted)
        lnT2 := line.new(bar_index, tp2P, bar_index, tp2P, color=color.new(color.green, 0), width=1, style=line.style_dashed)
    // new SELL
    else if sig == 0 and trigBear and (shortStopRaw - close) > tick
        sig  := -1
        risk = shortStopRaw - close
        slP  := shortStopRaw
        tp1P := close - tp1R * risk
        tp2P := close - tp2R * risk
        sellSig := true
        lnSL := line.new(bar_index, slP,  bar_index, slP,  color=color.new(color.red, 0),   width=1, style=line.style_dashed)
        lnT1 := line.new(bar_index, tp1P, bar_index, tp1P, color=color.new(color.green, 0), width=1, style=line.style_dotted)
        lnT2 := line.new(bar_index, tp2P, bar_index, tp2P, color=color.new(color.green, 0), width=1, style=line.style_dashed)

// extend active lines forward
if sig != 0
    if not na(lnSL)
        line.set_x2(lnSL, bar_index)
        line.set_x2(lnT1, bar_index)
        line.set_x2(lnT2, bar_index)

// ===== DRAW =====
plotshape(buySig,  "BUY",  style=shape.labelup,   location=location.belowbar, color=color.new(color.green, 0), text="BUY",  textcolor=color.white, size=size.small)
plotshape(sellSig, "SELL", style=shape.labeldown, location=location.abovebar, color=color.new(color.red, 0),   text="SELL", textcolor=color.white, size=size.small)

plot(refType == "VWAP" ? refLine : na, "VWAP", color=color.new(color.orange, 0))
plot(refType == "EMA"  ? refLine : na, "EMA",  color=color.new(color.orange, 0))
bgcolor(showBias and bullBias ? color.new(color.green, 93) : showBias and bearBias ? color.new(color.red, 93) : na)
bgcolor(showWin and inWin ? color.new(color.blue, 92) : na)

alertcondition(buySig,  "BUY",  "Trend Pullback BUY")
alertcondition(sellSig, "SELL", "Trend Pullback SELL")

// ===== STATUS BOX =====
if showTbl and barstate.islast
    var table t = na
    if not na(t)
        table.delete(t)
    t := table.new(position.top_right, 2, 3, border_width=1, frame_width=1, frame_color=color.gray)
    biasTxt = bullBias ? "LONG only" : bearBias ? "SHORT only" : "FLAT — no trades"
    biasCol = bullBias ? color.new(color.green, 30) : bearBias ? color.new(color.red, 30) : color.new(color.gray, 30)
    table.cell(t, 0, 0, "30m Trend", text_color=color.white, bgcolor=color.new(color.teal, 20), text_size=size.small)
    table.cell(t, 1, 0, biasTxt, text_color=color.white, bgcolor=biasCol, text_size=size.small)
    table.cell(t, 0, 1, "Window", text_color=color.white, bgcolor=color.new(color.teal, 20), text_size=size.small)
    table.cell(t, 1, 1, inWin ? "OPEN" : "closed", text_color=chart.fg_color, text_size=size.small)
    table.cell(t, 0, 2, "Setup", text_color=color.white, bgcolor=color.new(color.teal, 20), text_size=size.small)
    table.cell(t, 1, 2, sig != 0 ? "IN TRADE" : "waiting", text_color=chart.fg_color, text_size=size.small)
````
