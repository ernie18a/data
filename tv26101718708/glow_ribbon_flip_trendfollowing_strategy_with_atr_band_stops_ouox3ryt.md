# Glow Ribbon Flip | Trend-Following Strategy with ATR Band Stops

- url: https://www.tradingview.com/script/OUOx3rYT-Glow-Ribbon-Flip-Trend-Following-Strategy-with-ATR-Band-Stops/
- type: strategy
- pine_id: PUB;2ec0156c07724595b1f9a29a4a1abde3
- version: 1.0

## Description

Glow Ribbon Flip is a trend-following strategy built around a single idea: follow the trend with an ATR band that only moves in your favor, and take more than one trade per trend.
An EMA sets the basis of the trend. An ATR band sits below it in uptrends and above it in downtrends, and it only ratchets in the trend’s direction. A close beyond the band flips the trend, and the strategy reverses into the new direction. Between flips, it can re-enter on pullbacks, so one long trend can produce several trades instead of one.

[b]How it works[/b]
[list]
[*]Basis and band. An EMA (default 21) is the trend basis. The band is the EMA ± ATR × multiplier (default 10 × 2.0).
[*]Ratcheting. The lower band only rises in an uptrend and the upper band only falls in a downtrend. They reset when the trend flips.
[*]Flip entries. A close beyond the band reverses the position (long to short or short to long).
[*]Pullback re-entries. When the strategy is flat inside an established trend, a close back across the EMA in the trend’s direction opens a new trade.
[*]Exits. The band is an intrabar stop that is re-armed each bar as it moves. An optional profit target (default 2R, where R is the entry-to-band distance at entry) takes profit with a limit order. After a target or stop-out, pullbacks can re-enter if the trend is still intact.
[*]Position sizing. Each trade risks a set percentage of equity (default 1%), divided by the distance from entry to the band, and capped by a maximum leverage setting (default 3x).
[/list]

[b]Features[/b]
[list]
[*]Stop-and-reverse flips plus pullback re-entries, so it trades far more often than a pure flip system
[*]Real intrabar band stop and optional R-multiple target
[*]Risk-based position sizing with a leverage cap
[*]Long-only and short-only toggles
[*]Glowing band that brightens as price approaches it, so a trend under pressure stands out
[*]Shaded ribbon between the EMA and the band showing the room left in the trade
[*]Diamonds at each flip, small dots at pullback entries, and optional BUY/SELL tags
[*]Compact stats panel: trend, position with live R, trade count and win rate, net return
[*]Alerts for flips and pullback entries
[*]Every visual element can be turned off
[/list]

[b]Settings and tips[/b]
[list]
[*]More trades: lower the band width toward 1.5, shorten the EMA to about 13, or keep pullbacks on.
[*]Fewer, larger trades: raise the band width toward 3, lengthen the EMA, or turn pullbacks off.
[*]Trending markets suit this approach. If the equity curve looks choppy on your symbol, try turning the target off so winners can run, or use a higher timeframe.
[*]Match the settings to the timeframe. The defaults are a starting point, not an optimized preset. Check a few symbols and timeframes before judging.
[*]Use realistic costs. The strategy ships with 0.04% commission and 2 ticks of slippage. Change them to match your broker and market.
[*]Test across market regimes (trending, ranging, high volatility) rather than one lucky period.
[*]Avoid over-tuning. If results only look good at one exact setting, that is a sign of curve-fitting.
[/list]

[b]Warnings[/b]
[list]
[*]This is not financial advice. Backtest results are hypothetical and do not guarantee future performance.
[*]Orders fill on the next bar. Size is computed from the signal bar’s close, so real risk at the actual fill price can differ from the intended risk, especially on gaps or fast markets.
[*]Flip systems suffer in sideways markets. Expect clusters of small losses when price chops around the EMA, and the pullback entries can add to that.
[*]A tight profit target with pullbacks can churn. It can exit and re-enter repeatedly in a range.
[*]Leverage and sizing assume simple instruments. The sizing uses the instrument’s point value, so check the quantity it produces on futures, forex, and stocks before trusting it.
[*]Strategy Tester limits apply. Intrabar fills are approximated from bar data, so a bar that touches both the stop and the target is ambiguous.
[*]Use proper risk management and paper-trade before committing real capital.
[/list]

## Source Code

````pine
//@version=6
// ============================================================================
//  Glow Ribbon Flip Strategy
// ----------------------------------------------------------------------------
//  Trend engine: an EMA basis with an ATR band that ratchets in the trend's
//  direction. A close beyond the band flips the trend (stop-and-reverse).
//  Extra trades: while in a trend and flat, a close back across the EMA
//  (a pullback) re-enters in the trend's direction.
//  Exits: the band acts as a real intrabar stop; an optional R target banks
//  profit, after which pullbacks can re-enter.
//
//  Size = risk % of equity / distance from entry to the band, capped by leverage.
//  Signals are decided on closed bars; orders fill on the next bar's open.
// ============================================================================
strategy("Glow Ribbon Flip", "Ribbon Flip", overlay = true,
     initial_capital = 10000, default_qty_type = strategy.fixed, default_qty_value = 1,
     commission_type = strategy.commission.percent, commission_value = 0.04, slippage = 2,
     pyramiding = 0, calc_on_every_tick = false, margin_long = 0, margin_short = 0)

// ─────────────────────────────────────────────────────────────────────────
//  INPUTS
// ─────────────────────────────────────────────────────────────────────────
gS = "Trend"
baseLen = input.int(21, "EMA basis length", minval = 2, maxval = 300, group = gS)
atrLen  = input.int(10, "ATR length", minval = 2, maxval = 100, group = gS)
mult    = input.float(2.0, "Band width (× ATR)", minval = 0.5, step = 0.25, group = gS, tooltip = "Lower = tighter band, more flips and more trades.")
longsOn  = input.bool(true, "Take longs", group = gS)
shortsOn = input.bool(true, "Take shorts", group = gS)

gT = "Entries and exits"
pullOn = input.bool(true, "Pullback re-entries", group = gT, tooltip = "When flat inside a trend, a close back across the EMA enters in the trend's direction.")
tpOn   = input.bool(true, "Take profit at R target", group = gT)
tpR    = input.float(2.0, "Target (R)", minval = 0.25, maxval = 20, step = 0.25, group = gT, tooltip = "R = distance from entry to the band at the time of entry.")

gR = "Risk"
riskPct = input.float(1.0, "Risk per trade % of equity", minval = 0.01, maxval = 10, step = 0.1, group = gR)
maxLev  = input.float(3.0, "Max leverage (position value / equity)", minval = 0.1, maxval = 50, step = 0.1, group = gR)

gV = "Visuals"
bullCol    = input.color(#19f5c6, "Bullish color", group = gV)
bearCol    = input.color(#ff3d81, "Bearish color", group = gV)
showGlow   = input.bool(true, "Band glow", group = gV)
showRibbon = input.bool(true, "Ribbon fill (EMA to band)", group = gV)
showMarks  = input.bool(true, "Flip diamonds and pullback dots", group = gV)
showLabels = input.bool(true, "BUY / SELL labels on flips", group = gV)
colorBars  = input.bool(false, "Color bars by trend", group = gV)
showPanel  = input.bool(true, "Show stats panel", group = gV)

// ─────────────────────────────────────────────────────────────────────────
//  TREND ENGINE
//  lo = lower band (support in an uptrend), hi = upper band (resistance in a
//  downtrend). Each only moves in the trend's favour until price closes through.
// ─────────────────────────────────────────────────────────────────────────
float basis = ta.ema(close, baseLen)
float atrV  = ta.atr(atrLen)
float loNew = basis - mult * atrV
float hiNew = basis + mult * atrV

var float lo  = na
var float hi  = na
var int   dir = 0
float pLo = lo[1]
float pHi = hi[1]
lo := na(pLo) ? loNew : (loNew > pLo or close[1] < pLo) ? loNew : pLo
hi := na(pHi) ? hiNew : (hiNew < pHi or close[1] > pHi) ? hiNew : pHi

if dir == 0 and not na(lo) and not na(hi)
    dir := close > basis ? 1 : -1
else if dir == 1 and close < pLo
    dir := -1
else if dir == -1 and close > pHi
    dir := 1

int   prevDir  = nz(dir[1])
bool  flipBull = dir == 1 and prevDir != 1
bool  flipBear = dir == -1 and prevDir != -1
float stopLine = dir == 1 ? lo : dir == -1 ? hi : na

bool pullBull = pullOn and dir == 1 and prevDir == 1 and close > basis and close[1] <= basis[1] and strategy.position_size == 0 and longsOn
bool pullBear = pullOn and dir == -1 and prevDir == -1 and close < basis and close[1] >= basis[1] and strategy.position_size == 0 and shortsOn

// ─────────────────────────────────────────────────────────────────────────
//  TRADES
// ─────────────────────────────────────────────────────────────────────────
var float entryDist = na

float dist      = math.abs(close - stopLine)
float riskMoney = strategy.equity * riskPct / 100.0
float qRisk     = dist > 0 ? riskMoney / (dist * syminfo.pointvalue) : 0.0
float qCap      = strategy.equity * maxLev / (close * syminfo.pointvalue)
float qty       = math.min(qRisk, qCap)
bool  canSize   = not na(stopLine) and qty > 0

if canSize
    if flipBull
        if longsOn
            strategy.entry("Long", strategy.long, qty = qty, comment = "Flip")
            entryDist := dist
        else
            strategy.close("Short")
    else if flipBear
        if shortsOn
            strategy.entry("Short", strategy.short, qty = qty, comment = "Flip")
            entryDist := dist
        else
            strategy.close("Long")
    else if pullBull
        strategy.entry("Long", strategy.long, qty = qty, comment = "Pullback")
        entryDist := dist
    else if pullBear
        strategy.entry("Short", strategy.short, qty = qty, comment = "Pullback")
        entryDist := dist

// the band is a real stop (re-armed each bar as it ratchets); the target is a limit
float refPx = strategy.position_size != 0 ? strategy.position_avg_price : close
bool  hasR  = tpOn and not na(entryDist)
if dir == 1
    strategy.exit("Exit L", "Long", stop = lo, limit = hasR ? refPx + tpR * entryDist : na)
if dir == -1
    strategy.exit("Exit S", "Short", stop = hi, limit = hasR ? refPx - tpR * entryDist : na)

// ─────────────────────────────────────────────────────────────────────────
//  VISUALS — glowing band, ribbon back to the EMA, flip diamonds
//  The glow brightens as price closes in on the band.
// ─────────────────────────────────────────────────────────────────────────
color trendCol = dir == 1 ? bullCol : dir == -1 ? bearCol : chart.fg_color
bool  same     = dir == prevDir
float pressure = math.max(0.0, math.min(1.0, nz(1.0 - dir * (close - stopLine) / (mult * atrV))))
bool  stopAbove = stopLine > basis

plot(showGlow ? stopLine : na, "Band halo", same ? color.new(trendCol, 90 - 15 * pressure) : na, 12, display = display.pane, editable = false)
plot(showGlow ? stopLine : na, "Band glow", same ? color.new(trendCol, 76 - 28 * pressure) : na, 6, display = display.pane, editable = false)
plot(stopLine, "Band", same ? trendCol : na, 2, display = display.pane)

basisPlot = plot(basis, "EMA basis", color.new(trendCol, 72), 1, display = display.pane)
edgePlot  = plot(same ? stopLine : na, "Band edge", display = display.none, editable = false)
strong = color.new(trendCol, showRibbon ? 70 : 100)
faint  = color.new(trendCol, 100)
fill(basisPlot, edgePlot, top_value = math.max(basis, nz(stopLine, basis)), bottom_value = math.min(basis, nz(stopLine, basis)), top_color = stopAbove ? strong : faint, bottom_color = stopAbove ? faint : strong, title = "Ribbon")

plotshape(showMarks and flipBull ? stopLine : na, "Bull flip", shape.diamond, location.absolute, bullCol, size = size.small)
plotshape(showMarks and flipBear ? stopLine : na, "Bear flip", shape.diamond, location.absolute, bearCol, size = size.small)
plotshape(showMarks and pullBull, "Pullback long", shape.circle, location.belowbar, bullCol, size = size.tiny)
plotshape(showMarks and pullBear, "Pullback short", shape.circle, location.abovebar, bearCol, size = size.tiny)
plotshape(showLabels and flipBull, "Buy", shape.labelup, location.belowbar, bullCol, text = "BUY", textcolor = #04110e, size = size.small)
plotshape(showLabels and flipBear, "Sell", shape.labeldown, location.abovebar, bearCol, text = "SELL", textcolor = #ffffff, size = size.small)

barcolor(colorBars and dir != 0 ? trendCol : na, title = "Trend bar color")

// ─────────────────────────────────────────────────────────────────────────
//  STATS PANEL
// ─────────────────────────────────────────────────────────────────────────
var table hud = table.new(position.bottom_right, 2, 4, bgcolor = #10161F, border_color = #26303D, border_width = 1)
if showPanel and barstate.islast
    float pos   = strategy.position_size
    float openR = pos != 0 and entryDist > 0 ? (close - strategy.position_avg_price) * math.sign(pos) / entryDist : na
    int   nTr   = strategy.closedtrades
    float winP  = nTr > 0 ? strategy.wintrades / nTr * 100.0 : na
    float netP  = strategy.netprofit / strategy.initial_capital * 100.0
    color posCol = pos > 0 ? bullCol : pos < 0 ? bearCol : #8793A4
    table.cell(hud, 0, 0, "  Trend", text_color = #8793A4, text_halign = text.align_left)
    table.cell(hud, 1, 0, (dir == 1 ? "UP" : dir == -1 ? "DOWN" : "—") + "  ", text_color = trendCol, text_halign = text.align_right)
    table.cell(hud, 0, 1, "  Position", text_color = #8793A4, text_halign = text.align_left)
    table.cell(hud, 1, 1, (pos > 0 ? "LONG" : pos < 0 ? "SHORT" : "FLAT") + (na(openR) ? "" : "  " + (openR >= 0 ? "+" : "") + str.tostring(openR, "0.0") + " R") + "  ", text_color = posCol, text_halign = text.align_right)
    table.cell(hud, 0, 2, "  Trades", text_color = #8793A4, text_halign = text.align_left)
    table.cell(hud, 1, 2, str.tostring(nTr) + (na(winP) ? "" : "  ·  " + str.tostring(winP, "0") + "% win") + "  ", text_color = #E6EDF5, text_halign = text.align_right)
    table.cell(hud, 0, 3, "  Net", text_color = #8793A4, text_halign = text.align_left)
    table.cell(hud, 1, 3, (netP >= 0 ? "+" : "") + str.tostring(netP, "0.0") + "%  ", text_color = netP >= 0 ? bullCol : bearCol, text_halign = text.align_right)

// ─────────────────────────────────────────────────────────────────────────
//  ALERTS (alert() because alertcondition() is indicator-only)
// ─────────────────────────────────────────────────────────────────────────
if barstate.isconfirmed and (flipBull or pullBull)
    alert("Ribbon Flip: BUY " + syminfo.ticker + " " + timeframe.period + (flipBull ? " (flip)" : " (pullback)") + " · band " + str.tostring(stopLine, format.mintick), alert.freq_once_per_bar_close)
if barstate.isconfirmed and (flipBear or pullBear)
    alert("Ribbon Flip: SELL " + syminfo.ticker + " " + timeframe.period + (flipBear ? " (flip)" : " (pullback)") + " · band " + str.tostring(stopLine, format.mintick), alert.freq_once_per_bar_close)
````
