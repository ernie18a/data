# OC Buy/Sell Signals

- url: https://www.tradingview.com/script/ftWk5mIS-OC-Buy-Sell-Signals/
- type: indicator
- pine_id: PUB;664624a4e19c4d2ea8484941d4baf3bc
- version: 26.0

## Description

OC BUY/SELL SIGNALS (Open-Close Body Break)

WHAT IT DOES
This indicator looks at one thing only: where each candle opens and where it closes. It ignores wicks, highs, and lows. When a candle has an unusually large body and closes past the previous candle's body, it prints a BUY or SELL label on the chart. Big, decisive candles that push through the prior candle's range are treated as momentum.

HOW A SIGNAL IS BUILT
1) Body size: the "body" is the distance between a candle's open and close. The script averages the bodies over the last 50 bars (adjustable).
2) BUY: a green candle (close above open) that closes ABOVE the previous candle's body high, with a body at least 3x the average body.
3) SELL: a red candle (close below open) that closes BELOW the previous candle's body low, with a body at least 3x the average body.
4) Signals alternate. After a BUY, the next signal can only be a SELL, and the reverse, so you never see a string of repeated BUY or SELL labels.

NON-REPAINT
With Non-Repaint ON (the default), a signal appears only after the candle closes. Once it prints, it never moves or disappears. With it OFF, signals can appear while the candle is still forming and may vanish or flip before the close.

THE INFO BOX
A table on the chart shows the current settings and how the signals have performed recently:
- Non-Repaint: ON or OFF
- Avg Body: the average body length setting
- Min Body: the minimum body multiple setting
- Trades Counted: how many closed trades are in the lookback window (for example 20 / 20)
- Net P/L: the combined result of those trades, compounded
- Win Rate: percent of winning trades, with the win and loss counts
- Avg Win / Loss: the average winning trade and the average losing trade
- Max Drawdown: the largest peak-to-trough drop across those trades
- Open Trade P/L: the current open position's unrealized result

HOW THE P/L IS CALCULATED
The stats use a simple stop-and-reverse model. Each signal closes the current trade and opens the opposite one: a SELL closes a long and opens a short, and a BUY closes a short and opens a long. Entry and exit prices are the close of the signal candle. Commissions, slippage, and spreads are NOT included. Only the most recent N closed trades are counted (default 20), so older trades drop out as new ones close.

SETTINGS
- Non-repaint (confirm signals on bar close): ON by default. Keeps signals from changing after they print.
- Average body length (default 50): how many bars are used to measure the average candle body. Longer = steadier baseline. No signals appear until this many bars of history exist.
- Min body vs average (default 3.0x, step 0.5): how big the signal candle's body must be compared to the average. Higher = fewer, stronger signals. Set to 0 to turn the size filter off.
- Buy color / Sell color: colors for the BUY and SELL labels.
- Show BUY/SELL labels: turns the chart labels on or off. Alerts and the info box still work with labels hidden.
- Lookback (last N closed trades, default 20): how many recent closed trades feed the info box stats.
- Show info box: turns the table on or off.
- Info box position: nine placements (top, middle, or bottom, each left, center, or right). Default is top right.
- Info box size: Tiny, Small, Normal, Large, or Huge. Default is Small.

ALERTS
Two alert conditions are included: "Buy Signal" and "Sell Signal". Create them from the alert dialog by selecting this indicator. Keep Non-Repaint ON when using alerts.

TIPS
- Works on any market and timeframe. Try different Min Body values for different instruments, since volatility varies.
- Because the size filter is strict, trades can last a long time until the opposite signal appears.
- A doji (open equal to close) can never trigger a signal.
- Raising Min Body gives fewer signals. Lowering it gives more signals, with less size confirmation.

IMPORTANT NOTES
The info box shows how past signals performed on the bars loaded on your chart. It is not a prediction of future results. Real fills would occur at or after the next bar's open, so live results can differ from the stats shown. This script is for educational and informational purposes and is not financial advice.

## Source Code

````pine
//@version=6
indicator("OC Buy/Sell Signals", shorttitle="OC Signals", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

// ── Inputs ────────────────────────────────────────────────
nonRepaint = input.bool(true, "Non-repaint (confirm signals on bar close)", tooltip="ON: signals appear only after the bar closes and never disappear or move. OFF: signals can appear while the bar is still forming and may vanish or flip before the bar closes (repainting). Alerts and the info box statistics are more reliable with this ON.")
grpSig   = "Signals"
bodyLen  = input.int(50, "Average body length", minval=1, group=grpSig, tooltip="Number of bars used to calculate the average candle body (absolute distance between open and close). The signal candle's body is compared against this average. No signals can appear until this many bars of history exist. The same length is used for the average volume.")
bodyMult = input.float(3.0, "Min body vs average (x)", minval=0.0, step=0.5, group=grpSig, tooltip="Minimum size of the signal candle's body as a multiple of the average body. 3.0 means the body must be at least 3 times the average. Higher values give fewer, stronger signals. Set to 0 to remove the size filter.")
volMult  = input.float(0.0, "Min volume vs average (x)", minval=0.0, step=0.5, group=grpSig, tooltip="Minimum volume of the signal candle as a multiple of its average volume (same averaging length as the body average). 1.5 means the signal bar needs at least 1.5 times average volume. Set to 0 to turn the volume filter off. Needs volume data on the symbol: if none is available, no signals appear while this is above 0.")
alternate = input.bool(true, "Alternate signals", group=grpSig, tooltip="ON: signals alternate BUY, SELL, BUY and so on. A signal in the same direction as the open trade is skipped. OFF: every qualifying candle fires a signal. A bullish breakout candle always gives a BUY and a bearish one always gives a SELL, even if the previous signal went the same way. A repeat signal in the same direction closes the open trade at the signal bar's close (counted as a Signal exit) and opens a new one with a fresh entry, SL and TP.")
noOverlap = input.bool(true, "Ignore signals while a trade is open", group=grpSig, tooltip="ON: no new BUY or SELL fires while a trade is still open, so setups never overlap. The next signal can only appear after the open trade has hit its SL or TP. OFF: a new signal can fire inside an open trade and closes it at the signal bar's close (counted as a Signal exit). Applies only when Enable SL/TP is ON and the trade has a way to end on its own. If the Stop loss mode is None or the Take profit mode is Opposite signal, the trade can also end on a signal, so only same-direction signals are blocked and an opposite signal still closes the trade and opens a new one. If neither a stop nor a target is active, the toggle does nothing.")

grpRisk  = "Stop Loss / Take Profit"
useRisk  = input.bool(true, "Enable SL/TP", group=grpRisk, tooltip="ON: the stop loss is placed using the Stop loss mode, Entry/SL/TP lines are drawn for the current open trade, and trades close when the SL or TP is hit. The info box statistics then include those exits. OFF: pure stop-and-reverse. No lines are drawn, trades only close on the opposite signal, and every other setting in this group is ignored.")
exitMode = input.string("Wick", "Exit trigger", options=["Wick", "Close"], group=grpRisk, tooltip="Wick: the SL or TP is hit as soon as the bar's high or low touches the level, and the trade exits at that exact price. Close: the SL or TP is hit only when a bar closes at or beyond the level, and the trade exits at that bar's close, so the result can be larger or smaller than the exact level. Ignored when Enable SL/TP is OFF.")
slMode   = input.string("Candle wick", "Stop loss mode", options=["ATR", "Candle wick", "Candle body", "None"], group=grpRisk, tooltip="ATR: the stop is placed at entry +/- ATR x the stop loss multiple. Candle wick: the stop is placed at the extreme of the signal candle, its low for a BUY and its high for a SELL. Candle body: the stop is placed at the signal candle's open (the far edge of its body). Candle modes give a different stop distance on every trade and ignore the Stop loss (x ATR) setting. The Stop buffer (x ATR) setting moves the candle stops further out. The info box shows the latest trade's stop size in ATR units (CW = candle wick, CB = candle body). None: no stop loss at all. No SL line or shading is drawn and trades are never stopped out. Take profit mode ATR target still works as a target only, and SL multiple has no stop distance to multiply so it behaves like Opposite signal. With None and Opposite signal, trades behave like Enable SL/TP OFF (stop-and-reverse), but the Entry line and label are still drawn for the open trade. Ignored when Enable SL/TP is OFF.")
slBuf    = input.float(0.0, "Stop buffer (x ATR)", minval=0.0, step=0.05, group=grpRisk, tooltip="Extra distance added beyond the stop in the Candle wick and Candle body stop loss modes, in ATR: below the stop for a BUY and above it for a SELL. 0 places the stop exactly on the candle wick or body edge. Uses the ATR length below. Ignored by the ATR and None stop loss modes, and when Enable SL/TP is OFF.")
tpMode   = input.string("SL multiple", "Take profit mode", options=["ATR target", "SL multiple", "Opposite signal"], group=grpRisk, tooltip="ATR target: the take profit is placed at entry +/- ATR x the take profit (x ATR) multiple. SL multiple: the take profit is placed at entry +/- the stop distance x the take profit (x SL) multiple, so 2.0 means a reward of 2 times the risk, whichever Stop loss mode is used. Opposite signal: no fixed take profit. The trade stays open until the opposite BUY/SELL signal fires (or the stop loss is hit), and no TP line is drawn. Ignored when Enable SL/TP is OFF.")
atrLen   = input.int(14, "ATR length", minval=1, group=grpRisk, tooltip="Number of bars used for the ATR value. ATR is read on the signal bar and locked in for that trade. Ignored when Enable SL/TP is OFF.")
slMult   = input.float(1.5, "Stop loss (x ATR)", minval=0.1, step=0.1, group=grpRisk, tooltip="Used only when Stop loss mode is ATR. Stop loss distance from entry as a multiple of ATR. Long: entry minus this distance. Short: entry plus this distance.")
tpMult   = input.float(3.0, "Take profit (x ATR)", minval=0.1, step=0.1, group=grpRisk, tooltip="Used only when Enable SL/TP is ON and Take profit mode is ATR target. Take profit distance from entry as a multiple of ATR. Long: entry plus this distance. Short: entry minus this distance.")
tpRMult  = input.float(2.0, "Take profit (x SL)", minval=0.1, step=0.1, group=grpRisk, tooltip="Used only when Enable SL/TP is ON and Take profit mode is SL multiple. Take profit distance from entry as a multiple of the stop loss distance. Long: entry plus this distance. Short: entry minus this distance.")

grpLB     = "Lookback P/L"
lookback  = input.int(20, "Lookback (last N closed trades)", minval=1, group=grpLB, tooltip="Number of most recent closed trades included in the info box statistics (the average time between signals uses the same count). Older trades drop out as new ones close. Each signal closes the open trade and opens a new one (the opposite direction when Alternate signals is ON), using the signal bar's close as the price. With SL/TP enabled, trades can also close at their SL or TP price.")
showTable = input.bool(true, "Show info box", group=grpLB, tooltip="Turns the lookback P/L info box on or off.")
tablePos  = input.string("Top Right", "Info box position", options=["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group=grpLB, tooltip="Chart location of the info box.")
tableSize = input.string("Small", "Info box size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group=grpLB, tooltip="Text size used inside the info box.")
showClosed = input.int(0, "Show closed trades", minval=0, maxval=50, group=grpLB, tooltip="Number of most recent closed trade setups kept on the chart. Each closed setup stays frozen from its entry bar to its exit bar (Entry, SL and TP lines, labels and shading), then the oldest one is removed when the limit is exceeded. 0 = off: only the current trade is drawn. When above 0, closed setups are kept even if Show exit X is OFF (the X itself still follows Show exit X). Uses the same drawing toggles as the current trade. Ignored when Enable SL/TP is OFF.")

grpDisp = "Display"
showLabels = input.bool(true, "Show BUY/SELL labels", group=grpDisp, tooltip="Shows or hides the BUY and SELL labels. Alerts and the info box are not affected.")
lblSize = input.string("Small", "BUY/SELL label size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group=grpDisp, tooltip="Size of the BUY and SELL labels on the chart. Used only when Show BUY/SELL labels is ON. Alerts and the info box are not affected.")
buyCol   = input.color(#4CAF50, "Buy color", group=grpDisp, tooltip="Color of the BUY label. A BUY fires when a bullish candle closes above the previous candle's body high and passes the body size filter.")
sellCol  = input.color(#F23645, "Sell color", group=grpDisp, tooltip="Color of the SELL label. A SELL fires when a bearish candle closes below the previous candle's body low and passes the body size filter.")
showEntryMark = input.bool(true, "Show entry marker (dot)", group=grpDisp, tooltip="Draws a small dot at the entry price on the signal candle, which is that candle's close. Shown even when the trade lines are off, and when Enable SL/TP is OFF.")
entryMarkCol = input.color(#2962FF, "Entry marker color", group=grpDisp, tooltip="Color of the entry dot. Used only when Show entry marker is ON.")
showTradeLines = input.bool(true, "Show trade lines", group=grpDisp, tooltip="ON: draws the Entry, SL and TP lines for the current trade. OFF: no lines are drawn. The price labels, shading and exit X have their own toggles and are not affected. Ignored when Enable SL/TP is OFF.")
entryCol = input.color(#2962FF, "Entry line color", group=grpDisp)
slCol    = input.color(#F23645, "SL line color", group=grpDisp)
tpCol    = input.color(#4CAF50, "TP line color", group=grpDisp)
showTradeLbl = input.bool(true, "Show trade labels", group=grpDisp, tooltip="ON: shows the Entry, SL and TP price labels attached to the trade lines. OFF: only the lines (and shading, if enabled) are drawn. Ignored when Enable SL/TP is OFF.")
showX    = input.bool(true, "Show exit X", group=grpDisp, tooltip="ON: when price hits the SL or TP, the lines and shading stay on the chart, stop at the exit bar, and an X marks the exit price. They are replaced when the next signal fires (or kept as history when Show closed trades is above 0). OFF: the lines and shading disappear as soon as the SL or TP is hit. No X is drawn for an opposite-signal exit, because the new BUY/SELL signal starts a new setup.")
xCol    = input.color(#2962FF, "Exit X color", group=grpDisp, tooltip="Color of the X drawn where price hits the SL or TP line. Used only when Show exit X is ON.")
showZone = input.bool(true, "Show trade zone shading", group=grpDisp, tooltip="ON: shades the area between entry and SL, and between entry and TP, for the current trade. The shading follows the lines: it stays after an SL or TP hit when Show exit X is ON, and is replaced by the next signal. There is no TP shading in Opposite signal mode. Ignored when Enable SL/TP is OFF.")
slZoneCol = input.color(color.new(#F23645, 85), "SL zone color", group=grpDisp, tooltip="Shading between entry and stop loss. Used only when Show trade zone shading is ON.")
tpZoneCol = input.color(color.new(#4CAF50, 85), "TP zone color", group=grpDisp, tooltip="Shading between entry and take profit. Used only when Show trade zone shading is ON.")
lineW    = input.int(1, "Line width", minval=1, maxval=4, group=grpDisp)

tpAtr    = tpMode == "ATR target"
tpRisk   = tpMode == "SL multiple"
hasSl    = slMode != "None"
hasTp    = tpMode != "Opposite signal" and not (tpMode == "SL multiple" and slMode == "None")
riskOn   = useRisk and (hasSl or hasTp)
slAtr    = slMode == "ATR"
slWick   = slMode == "Candle wick"
exitOnClose = exitMode == "Close"

tPos = switch tablePos
    "Top Left"      => position.top_left
    "Top Center"    => position.top_center
    "Middle Left"   => position.middle_left
    "Middle Center" => position.middle_center
    "Middle Right"  => position.middle_right
    "Bottom Left"   => position.bottom_left
    "Bottom Center" => position.bottom_center
    "Bottom Right"  => position.bottom_right
    => position.top_right

tSize = switch tableSize
    "Tiny"   => size.tiny
    "Normal" => size.normal
    "Large"  => size.large
    "Huge"   => size.huge
    => size.small

// ── Open/Close-only logic ─────────────────────────────────
bodyHi  = math.max(open, close)
bodyLo  = math.min(open, close)
body    = math.abs(close - open)
avgBody = ta.sma(body, bodyLen)
avgVol  = ta.sma(volume, bodyLen)
volOk   = volMult <= 0 or volume >= avgVol * volMult
atr     = ta.atr(atrLen)

// Bullish candle closing above the prior body, with a body at least the required size
bullBreak = close > open and close > bodyHi[1] and body >= avgBody * bodyMult and volOk
// Bearish candle closing below the prior body, with a body at least the required size
bearBreak = close < open and close < bodyLo[1] and body >= avgBody * bodyMult and volOk

// With Alternate signals ON, signals alternate (no repeated buys or sells); OFF, every qualifying candle fires. With non-repaint ON they fire on confirmed bars only
bool confirmed = not nonRepaint or barstate.isconfirmed
var int dir = 0
var bool inTrade = false
// A trade with both a stop and a target only ends at one of them, so every signal is blocked while it is open. Otherwise an opposite signal is its other way out, so only same-direction signals are blocked
blocked = noOverlap and riskOn and inTrade
bothExits = hasSl and hasTp
buy  = confirmed and bullBreak and not (blocked and (bothExits or dir == 1)) and (not alternate or dir != 1)
sell = confirmed and bearBreak and not (blocked and (bothExits or dir == -1)) and (not alternate or dir != -1)

// ── Trade state ───────────────────────────────────────────
var float entryPx = na
var float slPx = na
var float tpPx = na
var array<float> pnls = array.new_float(0)
var array<int> reasons = array.new_int(0)   // 1 = TP, -1 = SL, 0 = reversal
var array<float> gaps = array.new_float(0)   // milliseconds between consecutive signals
var int lastSigTime = na
var float slAtrX = na   // latest stop distance in ATR units (shown for the candle stop modes)

var line entryLn = na
var line slLn = na
var line tpLn = na
var label entryLbl = na
var label slLbl = na
var label tpLbl = na
var label xLbl = na
var box slBox = na
var box tpBox = na

type TradeViz
    line entryLn
    line slLn
    line tpLn
    label entryLbl
    label slLbl
    label tpLbl
    label xLbl
    box slBox
    box tpBox

var array<TradeViz> closedViz = array.new<TradeViz>()

deleteViz(TradeViz v) =>
    line.delete(v.entryLn)
    line.delete(v.slLn)
    line.delete(v.tpLn)
    label.delete(v.entryLbl)
    label.delete(v.slLbl)
    label.delete(v.tpLbl)
    label.delete(v.xLbl)
    box.delete(v.slBox)
    box.delete(v.tpBox)

// Freezes a closed trade's drawings at its exit bar and stores them as history (oldest removed beyond Show closed trades)
archiveTrade(line eLn, line sLn, line tLn, label eLb, label sLb, label tLb, label xLb, box sBx, box tBx, int endBar) =>
    if not (na(eLn) and na(sLn) and na(tLn) and na(eLb) and na(sLb) and na(tLb) and na(sBx) and na(tBx))
        if not na(eLn)
            line.set_extend(eLn, extend.none)
            line.set_x2(eLn, endBar)
        if not na(sLn)
            line.set_extend(sLn, extend.none)
            line.set_x2(sLn, endBar)
        if not na(tLn)
            line.set_extend(tLn, extend.none)
            line.set_x2(tLn, endBar)
        if not na(sBx)
            box.set_extend(sBx, extend.none)
            box.set_right(sBx, endBar)
        if not na(tBx)
            box.set_extend(tBx, extend.none)
            box.set_right(tBx, endBar)
        array.push(closedViz, TradeViz.new(eLn, sLn, tLn, eLb, sLb, tLb, xLb, sBx, tBx))
        while array.size(closedViz) > showClosed
            deleteViz(array.shift(closedViz))

recordTrade(float pnl, int reason) =>
    array.push(pnls, pnl)
    array.push(reasons, reason)
    while array.size(pnls) > lookback
        array.shift(pnls)
        array.shift(reasons)

clearLines() =>
    line.delete(entryLn)
    line.delete(slLn)
    line.delete(tpLn)
    label.delete(entryLbl)
    label.delete(slLbl)
    label.delete(tpLbl)
    label.delete(xLbl)
    box.delete(slBox)
    box.delete(tpBox)

// ── 1) SL / TP exit check on existing trade (before any new signal) ──
// If SL and TP are both touched on the same bar, SL is assumed first.
bool slHit = false
bool tpHit = false
if useRisk and inTrade and confirmed
    slHit := hasSl and (exitOnClose ? (dir == 1 ? close <= slPx : close >= slPx) : (dir == 1 ? low <= slPx : high >= slPx))
    tpHit := hasTp and not slHit and (exitOnClose ? (dir == 1 ? close >= tpPx : close <= tpPx) : (dir == 1 ? high >= tpPx : low <= tpPx))
    if slHit or tpHit
        float exitPx = exitOnClose ? close : (slHit ? slPx : tpPx)
        float exitPnl = dir == 1 ? (exitPx - entryPx) / entryPx * 100 : (entryPx - exitPx) / entryPx * 100
        recordTrade(exitPnl, slHit ? -1 : 1)
        inTrade := false
        if showX or showClosed > 0
            // Keep the lines: stop them at the exit bar and mark the exit with an X
            if not na(entryLn)
                line.set_extend(entryLn, extend.none)
                line.set_x2(entryLn, bar_index)
            if not na(slLn)
                line.set_extend(slLn, extend.none)
                line.set_x2(slLn, bar_index)
            if not na(tpLn)
                line.set_extend(tpLn, extend.none)
                line.set_x2(tpLn, bar_index)
            if not na(slBox)
                box.set_extend(slBox, extend.none)
                box.set_right(slBox, bar_index)
            if not na(tpBox)
                box.set_extend(tpBox, extend.none)
                box.set_right(tpBox, bar_index)
            if showX
                xLbl := label.new(bar_index, exitPx, "X", style=label.style_label_center, color=color.new(color.black, 100), textcolor=xCol, size=size.large)
            if showClosed > 0
                archiveTrade(entryLn, slLn, tpLn, entryLbl, slLbl, tpLbl, xLbl, slBox, tpBox, bar_index)
                entryLn := na
                slLn := na
                tpLn := na
                entryLbl := na
                slLbl := na
                tpLbl := na
                xLbl := na
                slBox := na
                tpBox := na
        else
            clearLines()

// ── 2) New signal: close open trade (reversal) and open the opposite one ──
if buy or sell
    if not na(lastSigTime)
        array.push(gaps, time - lastSigTime)
        while array.size(gaps) > lookback
            array.shift(gaps)
    lastSigTime := time
    if inTrade
        float revPnl = dir == 1 ? (close - entryPx) / entryPx * 100 : (entryPx - close) / entryPx * 100
        recordTrade(revPnl, 0)
        if showClosed > 0
            archiveTrade(entryLn, slLn, tpLn, entryLbl, slLbl, tpLbl, xLbl, slBox, tpBox, bar_index)
            entryLn := na
            slLn := na
            tpLn := na
            entryLbl := na
            slLbl := na
            tpLbl := na
            xLbl := na
            slBox := na
            tpBox := na
    clearLines()
    dir := buy ? 1 : -1
    entryPx := close
    inTrade := true
    float bufD = na(atr) ? 0.0 : slBuf * atr
    slPx := not hasSl ? na : slAtr ? (dir == 1 ? close - atr * slMult : close + atr * slMult) : slWick ? (dir == 1 ? low - bufD : high + bufD) : (dir == 1 ? open - bufD : open + bufD)
    float riskDist = math.abs(close - slPx)
    slAtrX := hasSl and not slAtr and atr > 0 ? riskDist / atr : na
    float tpDist = tpAtr ? atr * tpMult : riskDist * tpRMult
    tpPx := not hasTp ? na : dir == 1 ? close + tpDist : close - tpDist
    if useRisk and (not na(atr) or not riskOn)
        if showTradeLines
            entryLn := line.new(bar_index, entryPx, bar_index + 1, entryPx, extend=extend.right, color=entryCol, width=lineW)
            if hasSl
                slLn := line.new(bar_index, slPx,    bar_index + 1, slPx,    extend=extend.right, color=slCol,    width=lineW, style=line.style_dashed)
            if hasTp
                tpLn := line.new(bar_index, tpPx, bar_index + 1, tpPx, extend=extend.right, color=tpCol, width=lineW, style=line.style_dashed)
        if showTradeLbl
            entryLbl := label.new(bar_index, entryPx, "Entry " + str.tostring(entryPx, format.mintick), style=label.style_label_left, color=color.new(color.black, 100), textcolor=entryCol, size=size.small)
            if hasSl
                slLbl := label.new(bar_index, slPx,    "SL " + str.tostring(slPx, format.mintick),       style=label.style_label_left, color=color.new(color.black, 100), textcolor=slCol,    size=size.small)
            if hasTp
                tpLbl := label.new(bar_index, tpPx, "TP " + str.tostring(tpPx, format.mintick), style=label.style_label_left, color=color.new(color.black, 100), textcolor=tpCol, size=size.small)
        if showZone
            if hasSl
                slBox := box.new(bar_index, math.max(entryPx, slPx), bar_index + 1, math.min(entryPx, slPx), border_color=na, bgcolor=slZoneCol, extend=extend.right)
            if hasTp
                tpBox := box.new(bar_index, math.max(entryPx, tpPx), bar_index + 1, math.min(entryPx, tpPx), border_color=na, bgcolor=tpZoneCol, extend=extend.right)

// ── Plots ─────────────────────────────────────────────────
plotshape(showEntryMark and (buy or sell) ? entryPx : na, "Entry marker", shape.circle, location.absolute, entryMarkCol, size=size.tiny)
plotshape(showLabels and lblSize == "Tiny" and buy,  "Buy (Tiny)",  shape.labelup,   location.belowbar, buyCol,  text="BUY",  textcolor=color.white, size=size.tiny)
plotshape(showLabels and lblSize == "Tiny" and sell, "Sell (Tiny)", shape.labeldown, location.abovebar, sellCol, text="SELL", textcolor=color.white, size=size.tiny)
plotshape(showLabels and lblSize == "Small" and buy,  "Buy (Small)",  shape.labelup,   location.belowbar, buyCol,  text="BUY",  textcolor=color.white, size=size.small)
plotshape(showLabels and lblSize == "Small" and sell, "Sell (Small)", shape.labeldown, location.abovebar, sellCol, text="SELL", textcolor=color.white, size=size.small)
plotshape(showLabels and lblSize == "Normal" and buy,  "Buy (Normal)",  shape.labelup,   location.belowbar, buyCol,  text="BUY",  textcolor=color.white, size=size.normal)
plotshape(showLabels and lblSize == "Normal" and sell, "Sell (Normal)", shape.labeldown, location.abovebar, sellCol, text="SELL", textcolor=color.white, size=size.normal)
plotshape(showLabels and lblSize == "Large" and buy,  "Buy (Large)",  shape.labelup,   location.belowbar, buyCol,  text="BUY",  textcolor=color.white, size=size.large)
plotshape(showLabels and lblSize == "Large" and sell, "Sell (Large)", shape.labeldown, location.abovebar, sellCol, text="SELL", textcolor=color.white, size=size.large)
plotshape(showLabels and lblSize == "Huge" and buy,  "Buy (Huge)",  shape.labelup,   location.belowbar, buyCol,  text="BUY",  textcolor=color.white, size=size.huge)
plotshape(showLabels and lblSize == "Huge" and sell, "Sell (Huge)", shape.labeldown, location.abovebar, sellCol, text="SELL", textcolor=color.white, size=size.huge)
// ── Info box ──────────────────────────────────────────────
fmt(float x) =>
    na(x) ? "n/a" : (x >= 0 ? "+" : "") + str.tostring(x, "0.00") + "%"

posCol(float x) =>
    na(x) ? color.white : x >= 0 ? color.new(#4CAF50, 0) : color.new(#F23645, 0)

// Formats milliseconds in the largest unit that keeps the number at 1 or more
fmtDur(float ms) =>
    float unitMs = na(ms) ? 1.0 : ms < 60000.0 ? 1000.0 : ms < 3600000.0 ? 60000.0 : ms < 86400000.0 ? 3600000.0 : ms < 604800000.0 ? 86400000.0 : ms < 2629800000.0 ? 604800000.0 : ms < 31557600000.0 ? 2629800000.0 : 31557600000.0
    string unitTxt = na(ms) ? "" : ms < 60000.0 ? "sec" : ms < 3600000.0 ? "min" : ms < 86400000.0 ? "hr" : ms < 604800000.0 ? "days" : ms < 2629800000.0 ? "wks" : ms < 31557600000.0 ? "mo" : "yrs"
    na(ms) ? "n/a" : str.tostring(ms / unitMs, "0.0") + " " + unitTxt

tfTxt = timeframe.isseconds ? str.tostring(timeframe.multiplier) + "s" : timeframe.isminutes ? (timeframe.multiplier % 60 == 0 ? str.tostring(math.round(timeframe.multiplier / 60)) + "h" : str.tostring(timeframe.multiplier) + "m") : timeframe.isdaily ? (timeframe.multiplier == 1 ? "D" : str.tostring(timeframe.multiplier) + "D") : timeframe.isweekly ? (timeframe.multiplier == 1 ? "W" : str.tostring(timeframe.multiplier) + "W") : (timeframe.multiplier == 1 ? "M" : str.tostring(timeframe.multiplier) + "M")
sessTxt = str.upper(str.substring(syminfo.session, 0, 1)) + str.substring(syminfo.session, 1)
chartType = chart.is_heikinashi ? "Heikin Ashi" : chart.is_renko ? "Renko" : chart.is_kagi ? "Kagi" : chart.is_linebreak ? "Line Break" : chart.is_pnf ? "Point & Figure" : chart.is_range ? "Range" : "Standard"

var table infoBox = not showTable ? na : table.new(tPos, 2, 22, bgcolor=color.new(#131722, 10), frame_color=color.new(color.gray, 40), frame_width=1, border_color=color.new(color.gray, 60), border_width=1)

if barstate.isfirst and showTable
    table.merge_cells(infoBox, 0, 0, 1, 0)
    table.merge_cells(infoBox, 0, 12, 1, 12)

if showTable and barstate.islast
    int n = array.size(pnls)
    int winCnt = 0
    int lossCnt = 0
    int tpCnt = 0
    int slCnt = 0
    int revCnt = 0
    float winSum = 0.0
    float lossSum = 0.0
    float eq = 1.0
    float peak = 1.0
    float maxDD = 0.0

    if n > 0
        for i = 0 to n - 1
            float p = array.get(pnls, i)
            int r = array.get(reasons, i)
            if r == 1
                tpCnt += 1
            else if r == -1
                slCnt += 1
            else
                revCnt += 1
            if p > 0
                winCnt += 1
                winSum += p
            else if p < 0
                lossCnt += 1
                lossSum += p
            eq := eq * (1 + p / 100)
            peak := math.max(peak, eq)
            maxDD := math.min(maxDD, (eq / peak - 1) * 100)

    float netPnl = n > 0 ? (eq - 1) * 100 : na
    float winRate = n > 0 ? winCnt / n * 100 : na
    float avgWin = winCnt > 0 ? winSum / winCnt : na
    float avgLoss = lossCnt > 0 ? lossSum / lossCnt : na
    float openPnl = not inTrade ? na : dir == 1 ? (close - entryPx) / entryPx * 100 : (entryPx - close) / entryPx * 100

    table.cell(infoBox, 0, 0, "OC BUY/SELL SIGNALS", text_color=color.white, bgcolor=color.new(#3B5B92, 0), text_halign=text.align_center, text_size=tSize)

    table.cell(infoBox, 0, 1, "Chart Type", text_color=color.white, text_halign=text.align_left, text_size=tSize)
    table.cell(infoBox, 1, 1, chartType, text_color=chart.is_standard ? color.white : color.new(#F23645, 0), text_halign=text.align_right, text_size=tSize)

    table.cell(infoBox, 0, 2, "Timeframe / Session", text_color=color.white, text_halign=text.align_left, text_size=tSize)
    table.cell(infoBox, 1, 2, tfTxt + " / " + sessTxt, text_color=color.white, text_halign=text.align_right, text_size=tSize)

    table.cell(infoBox, 0, 3, "Non-Repaint", text_color=color.white, text_halign=text.align_left, text_size=tSize)
    table.cell(infoBox, 1, 3, nonRepaint ? "ON" : "OFF", text_color=nonRepaint ? color.new(#4CAF50, 0) : color.new(#F23645, 0), text_halign=text.align_right, text_size=tSize)

    table.cell(infoBox, 0, 7, "Alternate Signals", text_color=color.white, text_halign=text.align_left, text_size=tSize)
    table.cell(infoBox, 1, 7, alternate ? "ON" : "OFF", text_color=alternate ? color.new(#4CAF50, 0) : color.new(#F23645, 0), text_halign=text.align_right, text_size=tSize)

    table.cell(infoBox, 0, 4, "Avg Body Length", text_color=color.white, text_halign=text.align_left, text_size=tSize)
    table.cell(infoBox, 1, 4, str.tostring(bodyLen), text_color=color.white, text_halign=text.align_right, text_size=tSize)

    table.cell(infoBox, 0, 5, "Min Body", text_color=color.white, text_halign=text.align_left, text_size=tSize)
    table.cell(infoBox, 1, 5, str.tostring(bodyMult, "0.0") + "x", text_color=color.white, text_halign=text.align_right, text_size=tSize)

    table.cell(infoBox, 0, 6, "Min Volume", text_color=color.white, text_halign=text.align_left, text_size=tSize)
    table.cell(infoBox, 1, 6, volMult > 0 ? str.tostring(volMult, "0.0") + "x" : "OFF", text_color=volMult > 0 ? color.white : color.new(#F23645, 0), text_halign=text.align_right, text_size=tSize)

    table.cell(infoBox, 0, 8, "Ignore Signals in Trade", text_color=color.white, text_halign=text.align_left, text_size=tSize)
    table.cell(infoBox, 1, 8, noOverlap ? "ON" : "OFF", text_color=noOverlap ? color.new(#4CAF50, 0) : color.new(#F23645, 0), text_halign=text.align_right, text_size=tSize)

    table.cell(infoBox, 0, 9, "Exit Trigger", text_color=color.white, text_halign=text.align_left, text_size=tSize)
    table.cell(infoBox, 1, 9, riskOn ? exitMode : "-", text_color=color.white, text_halign=text.align_right, text_size=tSize)

    string slAtrTxt = na(slAtrX) ? "n/a" : str.tostring(slAtrX, "0.0") + "x ATR"
    string slTxt = slAtr ? str.tostring(slMult, "0.0") + "x ATR" : slWick ? "CW: " + slAtrTxt : hasSl ? "CB: " + slAtrTxt : "None"
    string tpTxt = tpAtr ? str.tostring(tpMult, "0.0") + "x ATR" : tpRisk and hasSl ? str.tostring(tpRMult, "0.0") + "x SL" : "Opp. Signal"
    table.cell(infoBox, 0, 10, "Stop Loss", text_color=color.white, text_halign=text.align_left, text_size=tSize)
    table.cell(infoBox, 1, 10, useRisk ? slTxt : "OFF", text_color=useRisk ? color.white : color.new(#F23645, 0), text_halign=text.align_right, text_size=tSize)

    table.cell(infoBox, 0, 11, "Take Profit", text_color=color.white, text_halign=text.align_left, text_size=tSize)
    table.cell(infoBox, 1, 11, useRisk ? tpTxt : "OFF", text_color=useRisk ? color.white : color.new(#F23645, 0), text_halign=text.align_right, text_size=tSize)

    table.cell(infoBox, 0, 12, "LOOKBACK P/L", text_color=color.white, bgcolor=color.new(#3B5B92, 0), text_halign=text.align_center, text_size=tSize)

    table.cell(infoBox, 0, 13, "Trades Counted", text_color=color.white, text_halign=text.align_left, text_size=tSize)
    table.cell(infoBox, 1, 13, str.tostring(n) + " / " + str.tostring(lookback), text_color=color.white, text_halign=text.align_right, text_size=tSize)

    table.cell(infoBox, 0, 14, "Exits TP / SL / Signal", text_color=color.white, text_halign=text.align_left, text_size=tSize)
    table.cell(infoBox, 1, 14, (useRisk and hasTp ? str.tostring(tpCnt) : "-") + " / " + (useRisk and hasSl ? str.tostring(slCnt) : "-") + " / " + str.tostring(revCnt), text_color=color.white, text_halign=text.align_right, text_size=tSize)

    table.cell(infoBox, 0, 15, "Net P/L", text_color=color.white, text_halign=text.align_left, text_size=tSize)
    table.cell(infoBox, 1, 15, fmt(netPnl), text_color=posCol(netPnl), text_halign=text.align_right, text_size=tSize)

    table.cell(infoBox, 0, 16, "Win Rate", text_color=color.white, text_halign=text.align_left, text_size=tSize)
    table.cell(infoBox, 1, 16, na(winRate) ? "n/a" : str.tostring(winRate, "0") + "% (" + str.tostring(winCnt) + "W/" + str.tostring(lossCnt) + "L)", text_color=color.white, text_halign=text.align_right, text_size=tSize)

    table.cell(infoBox, 0, 17, "Avg Win / Loss", text_color=color.white, text_halign=text.align_left, text_size=tSize)
    table.cell(infoBox, 1, 17, fmt(avgWin) + " / " + fmt(avgLoss), text_color=color.white, text_halign=text.align_right, text_size=tSize)

    table.cell(infoBox, 0, 18, "Max Drawdown", text_color=color.white, text_halign=text.align_left, text_size=tSize)
    table.cell(infoBox, 1, 18, n > 0 ? fmt(maxDD) : "n/a", text_color=maxDD < 0 ? color.new(#F23645, 0) : color.white, text_halign=text.align_right, text_size=tSize)

    table.cell(infoBox, 0, 19, "Open Trade P/L", text_color=color.white, text_halign=text.align_left, text_size=tSize)
    table.cell(infoBox, 1, 19, fmt(openPnl), text_color=posCol(openPnl), text_halign=text.align_right, text_size=tSize)

    // Time between signals and time since the last signal, both in the same auto-scaled unit
    float avgMs = array.size(gaps) > 0 ? array.avg(gaps) : na
    float sinceMs = na(lastSigTime) ? na : time - lastSigTime
    table.cell(infoBox, 0, 20, "Avg Time per Signal", text_color=color.white, text_halign=text.align_left, text_size=tSize)
    table.cell(infoBox, 1, 20, fmtDur(avgMs), text_color=color.white, text_halign=text.align_right, text_size=tSize)

    table.cell(infoBox, 0, 21, "Time Since Last Signal", text_color=color.white, text_halign=text.align_left, text_size=tSize)
    table.cell(infoBox, 1, 21, fmtDur(sinceMs), text_color=color.white, text_halign=text.align_right, text_size=tSize)

// ── Alerts ────────────────────────────────────────────────
alertcondition(buy,   "Buy Signal",  "BUY: close broke above the prior body")
alertcondition(sell,  "Sell Signal", "SELL: close broke below the prior body")
alertcondition(tpHit, "Take Profit Hit", "TP hit on the open trade")
alertcondition(slHit, "Stop Loss Hit",   "SL hit on the open trade")
````
