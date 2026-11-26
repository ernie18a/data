# Trailing Drawdown Line Futures PropFirms

- url: https://www.tradingview.com/script/RvOQ6DXe-Trailing-Drawdown-Line-Futures-PropFirms/
- type: indicator
- pine_id: PUB;3160eb517aa74f83aa61ecf34d932cc7
- version: 1.0

## Description

See the exact price where your trailing drawdown gets hit — before it happens.

Built for futures prop-firm traders (Apex, Topstep, MyFundedFutures, Tradeify, BluSky and similar). Enter your firm's trailing DD size, your buffer at entry and your contract count, then click your entry point on the chart. The indicator draws your liquidation line — the price where the account would breach the trailing max drawdown — and ratchets it the way the firm actually does: it trails the implied equity peak at the FULL drawdown distance, and if you enter below your prior peak the line starts closer but does not move until price beats that peak.

Features
• Works on any futures symbol automatically — the contract's point value is read from the symbol (ES, NQ, MNQ, MES, GC, CL, ZB, …). Non-USD contracts (e.g. FDAX) display in their quote currency.
• Three trailing models: Intraday (trails every new high/low — real-time-trailing firms), Bar close, and End of day (EOD-trailing firms; needs an intraday or 1D chart).
• Live buffer readout — dollars and points left before the line — in a dark info table and an on-chart label.
• Breach is latched: once the line is touched the status stays BREACHED, because a trailing max-DD hit is terminal, not a temporary state. On historical bars the intraday model errs toward flagging (the path inside a bar is unknowable) — confirm on a lower timeframe.
• Lock support: enter the price where your firm freezes the DD (breakeven lock), or let the script derive it from your start balance + equity at entry. Status flips to LOCKED.
• Exit time: set it when you close the trade — the line and buffer freeze, because real DD levels stop moving while you're flat.
• Two alert conditions: buffer below warning level, and line touched.

How to use: add to chart → click your entry point → set contracts, firm DD size and buffer at entry (from your firm dashboard) → pick the trailing model that matches your firm → optionally create the two alerts. Re-anchor for every new trade.

Honest limitations: models ONE fixed-size position on THIS symbol. Scaling in/out or holding other instruments changes your real equity path and is not modeled. Anchor on a low timeframe (1–5 min) for precision. Educational risk-visualization tool — always confirm your firm's exact drawdown rule on their own site.

## Source Code

````pine
//@version=6
indicator('Trailing Drawdown Line — Futures Prop Firms', 'Trailing DD Line', overlay = true)

// ── Position & account ──
grpPos = 'Position & account'
dirIsLong = input.string('Long', 'Direction', options = ['Long', 'Short'], group = grpPos) == 'Long'
contracts = input.int(1, 'Contracts', minval = 1, group = grpPos)
fullDD = input.float(2500, 'Firm trailing DD size ($)', minval = 1, step = 50, group = grpPos, tooltip = 'The FIXED trailing distance from your firm rules — e.g. $2,500 on a $50K Apex account. This drives how far the line trails behind the equity peak.')
ddBuffer = input.float(2500, 'Buffer at entry ($)', minval = 1, step = 50, group = grpPos, tooltip = 'Equity minus your trailing DD level AT THE MOMENT OF ENTRY — from your firm dashboard. It equals the DD size only when you enter exactly on your equity peak. Example: peaked +$1,000 then closed +$600 → level = $48,500, equity = $50,600 → buffer = 2,100, not 2,500. Adding the indicator later? Still enter the buffer you had at entry — the script replays the trail from there. Buffer LARGER than the DD size means your drawdown has locked — set the lock too.')

// ── Anchor ──
grpAnc = 'Anchor — one click on your entry when loading'
anchorTime = input.time(timestamp('1 Jan 2026 00:00 +0000'), 'Entry time', confirm = true, inline = 'entry', group = grpAnc)
anchorPrice = input.price(0.0, 'Entry price', confirm = true, inline = 'entry', group = grpAnc, tooltip = 'Set by clicking the chart when the indicator loads; drag the point to adjust. Anchor on a LOW timeframe (1-5 min) — on big bars the whole entry bar range counts toward the trail.')
exitTime = input.time(timestamp('1 Jan 2099 00:00 +0000'), 'Exit time (leave far-future while open)', group = grpAnc, tooltip = 'When you close the trade, set this to the exit moment: the line freezes there — real DD levels stop moving while you are flat.')

// ── Trailing model ──
grpMod = 'Trailing model'
M_INTRA = 'Intraday — trails every new high/low'
M_CLOSE = 'Bar close — trails closed bars only'
M_EOD = 'End of day — ratchets once per daily close'
model = input.string(M_INTRA, 'Trail updates', options = [M_INTRA, M_CLOSE, M_EOD], group = grpMod, tooltip = 'Match your firm. Real-time/unrealized trailing (e.g. Apex-style) = Intraday. End-of-day trailing (e.g. Topstep-style) = End of day (needs an intraday or 1D chart).')
lockAt = input.float(0.0, 'Lock line at price (0 = off)', minval = 0, group = grpMod, tooltip = 'Many firms stop trailing once the level reaches breakeven (+ a small offset). Enter that price and the line will never trail past it. Or leave 0 and fill the Auto-lock group below.')

// ── Auto-lock (optional) ──
grpLock = 'Auto-lock (optional — computes the lock price for you)'
startBal = input.float(0, 'Account start balance ($) — 0 = off', minval = 0, group = grpLock)
entryEq = input.float(0, 'Equity at entry ($) — 0 = off', minval = 0, group = grpLock)
lockOffset = input.float(100, 'Lock level above start balance ($)', group = grpLock, tooltip = 'Apex-style: the DD stops trailing at start balance + $100. Set 0 if your firm locks exactly at breakeven.')

// ── Alerts & display ──
grpUI = 'Alerts & display'
warnUsd = input.float(500, 'Warn when buffer drops below ($)', minval = 0, group = grpUI)
showTbl = input.bool(true, 'Show info table', group = grpUI)
tblPos = input.string('Middle Left', 'Table position', options = ['Top Left', 'Top Right', 'Middle Left', 'Middle Right', 'Bottom Left', 'Bottom Right'], group = grpUI)

// ── Guards ──
if model == M_EOD and not(timeframe.isintraday or timeframe.isdaily and timeframe.multiplier == 1)
    runtime.error('End-of-day mode needs an intraday or 1D chart.')

// ── Core math — point value auto-detected per symbol ──
perPoint = syminfo.pointvalue * contracts // value of 1.00 point of price movement (quote currency)
distFull = fullDD / perPoint // firm trailing distance, in points
distBuf = ddBuffer / perPoint // buffer at entry, in points
ccy = syminfo.currency == 'USD' ? '$' : syminfo.currency + ' '

active = time >= anchorTime and anchorPrice > 0
inTrade = active and time <= exitTime
newDay = ta.change(time('D')) != 0

// peakRef = the implied equity peak in price terms; the line trails distFull behind it.
// Starts at anchor + (distFull - distBuf): if you enter below your peak, the line begins
// closer (your real buffer) but does NOT move until price beats the implied prior peak.
var float peakRef = na
var bool hit = false

if active and na(peakRef)
    peakRef := dirIsLong ? anchorPrice + distFull - distBuf : anchorPrice - (distFull - distBuf)
    peakRef
if inTrade and not hit
    // Anchor bar uses close (pre-entry wicks must not contaminate the trail);
    // EOD skips the pre-entry daily close when the entry lands on a session-open bar.
    float ref = model == M_INTRA ? time > anchorTime ? dirIsLong ? high : low : close : model == M_CLOSE ? close : newDay and time > anchorTime ? close[1] : float(na)
    if not na(ref)
        peakRef := dirIsLong ? math.max(peakRef, ref) : math.min(peakRef, ref)
        peakRef

float trailRaw = na(peakRef) ? float(na) : dirIsLong ? peakRef - distFull : peakRef + distFull

// Lock: manual price wins; otherwise derived from start balance + equity at entry.
// Line price for DD level X$ satisfies equity(line) = X$  →  line = anchor + (X$ - entryEq) / perPoint (long).
lockAuto = startBal > 0 and entryEq > 0 ? dirIsLong ? anchorPrice + (startBal + lockOffset - entryEq) / perPoint : anchorPrice - (startBal + lockOffset - entryEq) / perPoint : 0.0
effLock = lockAt > 0 ? lockAt : lockAuto
lockValid = effLock > 0 and (dirIsLong ? effLock >= anchorPrice - distBuf : effLock <= anchorPrice + distBuf)
if lockValid and not na(trailRaw)
    trailRaw := dirIsLong ? math.min(trailRaw, effLock) : math.max(trailRaw, effLock)
    trailRaw

// Snap to a real tick — rounded toward safety (long: up, short: down)
tick = syminfo.mintick
trailDisp = na(trailRaw) ? float(na) : dirIsLong ? math.ceil(trailRaw / tick) * tick : math.floor(trailRaw / tick) * tick

locked = lockValid and not na(trailRaw) and (dirIsLong ? trailRaw >= effLock : trailRaw <= effLock)
bufferPts = na(trailDisp) ? float(na) : dirIsLong ? close - trailDisp : trailDisp - close
bufferUsd = bufferPts * perPoint

// Breach — LATCHED (a trailing max-DD hit is terminal). Wick test vs the line in
// force during the bar: intraday & EOD use the current bar line (EOD is fixed at
// bar open; intraday errs toward flagging — the path inside a bar is unknowable),
// bar-close mode uses the previously committed line. Anchor bar: close test only,
// so pre-entry wicks cannot false-flag. Exit bar excluded: no flags while flat.
if inTrade and time_close <= exitTime and not na(trailDisp) and not hit
    closeTouch = dirIsLong ? close <= trailDisp : close >= trailDisp
    wickRef = model == M_CLOSE ? nz(trailDisp[1], trailDisp) : trailDisp
    wickTouch = time > anchorTime and (dirIsLong ? low <= wickRef : high >= wickRef)
    hit := closeTouch or wickTouch
    hit
breached = hit
warning = inTrade and not breached and not na(bufferUsd) and bufferUsd <= warnUsd

// Freeze the buffer readout once flat — equity stops moving with price
var float flatBufUsd = na
if active and not inTrade and na(flatBufUsd)
    flatBufUsd := nz(bufferUsd[1], bufferUsd)
    flatBufUsd
dispBufUsd = not inTrade and not na(flatBufUsd) ? flatBufUsd : bufferUsd
dispBufPts = na(dispBufUsd) ? float(na) : dispBufUsd / perPoint

// ── Colours (solid, dark-chart friendly) ──
COL_OK = #26a69a
COL_WARN = #ff9800
COL_HIT = #f23645
COL_LOCKD = #2e7d32
COL_FLAT = #37474b
COL_BG = #131722
COL_HEAD = #0f3d3a
COL_FRAME = #2a2e39

lineCol = breached ? COL_HIT : warning ? COL_WARN : COL_OK
plot(active ? trailDisp : float(na), 'Trailing DD line', color = lineCol, linewidth = 2, style = plot.style_linebr)

// Dotted ray + live label at the right edge
var line ray = na
var label lb = na
if barstate.islast and active and not na(trailDisp)
    if na(ray)
        ray := line.new(bar_index, trailDisp, bar_index + 1, trailDisp, extend = extend.right, style = line.style_dotted, width = 1, color = lineCol)
        lb := label.new(bar_index, trailDisp, '', textcolor = color.white, size = size.small)
        lb
    line.set_xy1(ray, bar_index, trailDisp)
    line.set_xy2(ray, bar_index + 1, trailDisp)
    line.set_color(ray, lineCol)
    label.set_xy(lb, bar_index, trailDisp)
    label.set_style(lb, dirIsLong ? label.style_label_upper_left : label.style_label_lower_left)
    label.set_color(lb, breached ? COL_HIT : warning ? COL_WARN : COL_BG)
    label.set_text(lb, (breached ? 'DD HIT · ' : locked ? 'LOCKED · ' : not inTrade ? 'FLAT · ' : '') + str.tostring(trailDisp, format.mintick) + ' · ' + ccy + str.tostring(math.max(dispBufUsd, 0), '#,###') + ' left')

// ── Info table ──
posMap = tblPos == 'Top Left' ? position.top_left : tblPos == 'Top Right' ? position.top_right : tblPos == 'Middle Right' ? position.middle_right : tblPos == 'Bottom Left' ? position.bottom_left : tblPos == 'Bottom Right' ? position.bottom_right : position.middle_left
var table t = table.new(posMap, 2, 5, border_width = 1, frame_color = COL_FRAME, frame_width = 1)

cell(int r, string a, string b, color bg) =>
    table.cell(t, 0, r, a, text_halign = text.align_left, text_size = size.small, text_color = color.white, bgcolor = bg)
    table.cell(t, 1, r, b, text_halign = text.align_right, text_size = size.small, text_color = color.white, bgcolor = bg)

if barstate.islast and showTbl
    if active and not na(trailDisp)
        statusTxt = breached ? 'BREACHED' : warning ? 'WARNING' : not inTrade ? 'FLAT' : locked ? 'LOCKED' : 'SAFE'
        statusBg = breached ? COL_HIT : warning ? COL_WARN : not inTrade ? COL_FLAT : locked ? COL_LOCKD : COL_HEAD
        cell(0, 'TRAILING DD LINE', statusTxt, statusBg)
        cell(1, 'Line', str.tostring(trailDisp, format.mintick), COL_BG)
        cell(2, 'Buffer', ccy + str.tostring(dispBufUsd, '#,###') + ' · ' + str.tostring(dispBufPts, '#.##') + ' pts', COL_BG)
        cell(3, 'Size', str.tostring(contracts) + ' × ' + ccy + str.tostring(syminfo.pointvalue, '#.##') + '/pt = ' + ccy + str.tostring(perPoint, '#.##') + '/pt', COL_BG)
        cell(4, 'Mode', (dirIsLong ? 'Long · ' : 'Short · ') + (model == M_INTRA ? 'Intraday' : model == M_CLOSE ? 'Bar close' : 'End of day'), COL_BG)
    else
        cell(0, 'TRAILING DD LINE', 'Click your entry on the chart to arm', COL_HEAD)

// ── Alerts ──
alertcondition(hit and not hit[1], 'Trailing DD line hit', 'Price touched the trailing drawdown line — this position would hit the account trailing max drawdown.')
alertcondition(warning, 'DD buffer warning', 'Drawdown buffer dropped below your warning level.')
````
