# Prop Firm Risk Guard I EonMetrics 

- url: https://www.tradingview.com/script/yEFeQV2Q-Prop-Firm-Risk-Guard-I-EonMetrics/
- type: indicator
- pine_id: PUB;d5787f4feed947428a2d45d2e64e716e
- version: 1.0

## Description

Prop Firm Risk Guard

Prop Firm Risk Guard is a risk dashboard and position size calculator for prop firm challenge and funded-account traders. It keeps the numbers that decide whether your account survives — the Daily Loss Limit, the Max Drawdown floor and the size of your next trade — on one screen, derived from one shared account state.

https://www.tradingview.com/x/lGhsKF1W/

Stated plainly up front: TradingView cannot see your broker account. Your balance and today's P&L are MANUAL inputs — you type them in, the script does the limit math and the sizing math. Entry, Stop and Take Profit are also yours: the script never calculates or suggests any of them, it only draws the levels you decided on and does the arithmetic. The only live, price-driven element is the Entry/SL/TP lines and their cross alerts. No signals, no trade suggestions.

🔶[b]WHY ONE SCRIPT[/b]

A challenge usually fails through one compounding mistake: a trade sized without checking how much of today's loss allowance is actually left, so a routine stop-out becomes a daily breach. That check only works when the daily limit, the drawdown floor and the position size are computed from the same account state at the same moment — which is why they are one dashboard instead of separate tools you would have to cross-reference by hand. The last sizing row makes the link explicit: it compares one full stop-out against your remaining daily room and turns red BEFORE the trade if it doesn't fit.

🔶[b]WHAT IT DOES[/b]

Daily Loss Limit — enter your firm's daily loss % and its basis (starting or current balance). Today's P&L is a NET number, wins offset losses. Because firms word this rule two ways, both models are supported: Floor (the day has a fixed equity floor, so intraday profit adds room before it — the common model) and Hard Cap (the allowed loss is fixed, profit does not extend it). The table shows the remaining allowance in money and a status ladder: OK → CAUTION (50% used) → DANGER (80%) → BREACHED.

Max Drawdown — Static (floor fixed below the starting balance) or Trailing (floor follows the equity high-water mark). Shows the floor as an actual money level and the buffer above it, with the same status ladder.

Position sizing — risk per trade as % of balance or a fixed amount, planned entry (or live price) and stop. Returns the size in units, the forex conversion to 100k lots and the notional value. A Contract Multiplier input keeps the math correct on futures (e.g. ES = 50, GC = 100) as well as stocks, crypto and forex.

Take Profit (optional) — add your own TP price to see the R:R ratio and the money gain if it hits, using the same calculated size. If the TP sits on the wrong side of entry for your direction, the cell flags it instead of showing a meaningless ratio.

Entry / SL / TP lines — your levels drawn on the chart, with three alert conditions that fire when price crosses any of them.

https://www.tradingview.com/x/RtoZd1i6/

🔶[b]HOW TO USE[/b]

1. Settings → Account: starting balance, current balance; high-water mark for trailing-drawdown firms (0 = auto).
2. Prop Firm Rules: copy the exact numbers and models from your firm's dashboard.
3. During the session, keep Today's P&L updated — the daily section only knows what you tell it.
4. Before a trade: set risk, entry and stop; read the size; make sure the last row is not red.
5. Optional: add a TP for R:R, and set alerts on the three price-cross conditions.

🔶[b]SETTINGS[/b]
Account (balances, high-water mark) · Prop Firm Rules (daily loss % + basis + Floor/Hard Cap, max drawdown % + Static/Trailing, profit target) · Today's P&L · Position Sizing (risk mode, entry/stop/TP, contract multiplier, lines toggle) · Table (position, text size).

This tool does the arithmetic of your firm's rules and your own trade plan. It does not know your account, does not predict anything and does not tell you what to trade.

Part of the EonMetrics toolset.

## Source Code

````pine
//@version=6
indicator('EonMetrics Prop Firm Risk Guard', 'Prop Risk Guard by EonMetrics', overlay=true)

// Prop Firm Risk Guard by EonMetrics — challenge risk dashboard + position size
// calculator (open-source).
//
// Tracks the two numbers every funded/challenge trader lives and dies by:
//   • Daily Loss Limit  — how much of today's allowance is left, with status color
//   • Max Drawdown      — the equity floor (static or trailing) and the buffer above it
// plus a market-agnostic position size calculator (risk % or fixed $, contract
// multiplier aware) and Entry/SL lines drawn from your own planned levels, with
// price-cross alerts.
//
// HONESTY BY DESIGN: TradingView cannot see your broker account. Balance and
// today's P&L are MANUAL inputs — this is a calculator that does the limit math
// and sizing arithmetic for you, not a tool that monitors your account. The only
// live element is price: the Entry/SL lines and their cross alerts follow the chart.
// No signals, no targets, no trade suggestions.

// ═════════════════════════════════════════════════════════════════════════════
//  ACCOUNT
// ═════════════════════════════════════════════════════════════════════════════
grpAcc = 'Account'

accCur = input.string('USD', 'Account Currency (label)', group=grpAcc,
  tooltip = 'Cosmetic only — shown in the table header. All money values below are in this currency.')

startBal = input.float(100000, 'Starting Balance', minval=0.01, group=grpAcc,
  tooltip = 'The balance your challenge / funded account started with. Limits based on "Starting Balance" use this number.')

curBal = input.float(100000, 'Current Balance', minval=0.01, group=grpAcc,
  tooltip = 'Your balance right now (realized). Update it as the challenge progresses — TradingView cannot read it from your broker.')

hwmInp = input.float(0, 'Equity High-Water Mark', minval=0, group=grpAcc,
  tooltip = 'Highest balance the account has reached — the anchor for TRAILING drawdown rules. Leave 0 to use the higher of Starting/Current Balance automatically.')

// ═════════════════════════════════════════════════════════════════════════════
//  PROP FIRM RULES
// ═════════════════════════════════════════════════════════════════════════════
grpRules = 'Prop Firm Rules'

dlPct = input.float(5.0, 'Daily Loss Limit %', minval=0.1, maxval=100, step=0.5, group=grpRules,
  tooltip = 'Maximum loss allowed in a single day before the account fails. Copy the exact number from your firm\'s rules.')

dlBasis = input.string('Starting Balance', 'Daily Limit Based On', options=['Starting Balance', 'Current Balance'], group=grpRules,
  tooltip = 'What the daily percentage is measured against. Most firms use the starting/initial balance; some use the balance at the start of the day — check your rules.')

dlModel = input.string('Floor (profit adds room)', 'Daily Loss Model', options=['Floor (profit adds room)', 'Hard Cap (profit ignored)'], group=grpRules,
  tooltip = 'How intraday PROFIT interacts with the daily limit.\nFloor: the day has a fixed equity floor (day-start balance minus the limit) — being in profit adds that profit to the room you have before hitting it. This is how most firms work (FTMO-style).\nHard Cap: the allowed loss is a fixed amount regardless of how far in profit you were — profit does not add room. Check your firm\'s exact wording.')

ddPct = input.float(10.0, 'Max Drawdown %', minval=0.1, maxval=100, step=0.5, group=grpRules,
  tooltip = 'Maximum total drawdown before the account fails.')

ddType = input.string('Static', 'Drawdown Type', options=['Static', 'Trailing'], group=grpRules,
  tooltip = 'Static: the floor sits below the STARTING balance and never moves. Trailing: the floor follows the equity high-water mark upward. Check which model your firm uses.')

tgtPct = input.float(10.0, 'Profit Target % (0 = hide)', minval=0, maxval=100, step=0.5, group=grpRules,
  tooltip = 'Challenge profit target. Shows your progress toward it; set 0 to hide the row.')

// ═════════════════════════════════════════════════════════════════════════════
//  TODAY
// ═════════════════════════════════════════════════════════════════════════════
grpDay = 'Today'

dayPnl = input.float(0, 'Today\'s P&L', group=grpDay,
  tooltip = 'Your running P&L for TODAY, including floating positions if your firm counts equity (most do). Negative values eat into the daily allowance. Update it manually during the session.')

// ═════════════════════════════════════════════════════════════════════════════
//  POSITION SIZING
// ═════════════════════════════════════════════════════════════════════════════
grpSize = 'Position Sizing'

riskMode = input.string('% of Balance', 'Risk Mode', options=['% of Balance', 'Fixed $'], group=grpSize,
  tooltip = 'How the risk for one trade is defined: a percentage of the Current Balance, or a fixed money amount.')

riskPct = input.float(1.0, 'Risk per Trade %', minval=0.01, maxval=100, step=0.25, group=grpSize,
  tooltip = 'Used in "% of Balance" mode.')

riskFix = input.float(1000, 'Risk per Trade $ (Fixed)', minval=0.01, group=grpSize,
  tooltip = 'Used in "Fixed $" mode.')

entryInp = input.float(0, 'Entry Price (0 = current)', minval=0, group=grpSize,
  tooltip = 'Your planned entry. Leave 0 to use the live price of the chart symbol.')

stopInp = input.float(0, 'Stop Price (0 = sizing off)', minval=0, group=grpSize,
  tooltip = 'Your planned stop-loss PRICE on this chart\'s symbol. The sizing rows and the Entry/SL lines only appear when this is set. Stop below entry = long, above = short.')

tpInp = input.float(0, 'Take Profit Price (0 = hide)', minval=0, group=grpSize,
  tooltip = 'Your own planned take-profit PRICE — not calculated or suggested by the script. Leave 0 to hide the TP line and the R:R row. Must be on the correct side of entry for your direction (above entry when long, below when short) or the R:R cell flags it instead of showing a misleading ratio.')

multInp = input.float(1.0, 'Contract Multiplier', minval=0.000001, group=grpSize,
  tooltip = 'Money value of a 1.0 price move for ONE unit of what you trade.\nStocks / crypto spot: 1.\nFutures: the contract multiplier (e.g. ES = 50, NQ = 20, GC = 100).\nForex: 1 per base-currency unit — the table converts units to standard 100k lots for you.')

showLines = input.bool(true, 'Draw Entry / SL / TP Lines', group=grpSize,
  tooltip = 'Draws your planned entry, stop and (if set) take-profit as horizontal lines on the chart, with price-cross alert conditions.')

// ═════════════════════════════════════════════════════════════════════════════
//  TABLE
// ═════════════════════════════════════════════════════════════════════════════
grpTbl = 'Table'

tablePosInp = input.string('Top Right', 'Position', options=['Top Left', 'Top Right', 'Bottom Left', 'Bottom Right', 'Middle Right'], group=grpTbl)
tableSize   = input.string('Small', 'Text Size', options=['Tiny', 'Small', 'Normal'], group=grpTbl)

// ═════════════════════════════════════════════════════════════════════════════
//  DERIVED
// ═════════════════════════════════════════════════════════════════════════════
okC     = color.new(#089981, 0)
warnC   = color.new(#ff9800, 0)
dngC    = color.new(#f23645, 0)
neutC   = color.new(#9598a1, 0)
headBg  = color.new(color.gray, 60)
secBg   = color.new(#2a2e39, 25)

tsize = tableSize == 'Tiny' ? size.tiny : tableSize == 'Normal' ? size.normal : size.small

tablePos = tablePosInp == 'Top Left' ? position.top_left : tablePosInp == 'Bottom Left' ? position.bottom_left : tablePosInp == 'Bottom Right' ? position.bottom_right : tablePosInp == 'Middle Right' ? position.middle_right : position.top_right

f_usd(float x) =>
    (x < 0 ? '-' : '') + str.tostring(math.abs(x), '#,###.##')

f_pct(float x) =>
    str.tostring(x, '#.##') + '%'

// ── account ──────────────────────────────────────────────────────────────────
hwm      = hwmInp > 0 ? math.max(hwmInp, curBal) : math.max(startBal, curBal)
totPnl   = curBal - startBal
totPnlPc = totPnl / startBal * 100

tgtProg  = tgtPct > 0 ? totPnl / (startBal * tgtPct / 100) * 100 : na

// ── daily loss ───────────────────────────────────────────────────────────────
dlBase   = dlBasis == 'Current Balance' ? curBal : startBal
dlLimit  = dlBase * dlPct / 100
dlUsed   = math.max(0, -dayPnl)
// Floor model: profit adds to the room before the day's equity floor (limit + net P&L).
// Hard Cap model: the allowance is fixed; profit never extends it.
dlLeft   = dlModel == 'Floor (profit adds room)' ? dlLimit + dayPnl : dlLimit - dlUsed
dlUsedPc = dlLimit > 0 ? dlUsed / dlLimit * 100 : 0

// ── max drawdown ─────────────────────────────────────────────────────────────
ddAnchor = ddType == 'Trailing' ? hwm : startBal
ddFloor  = ddAnchor * (1 - ddPct / 100)
ddAllow  = ddAnchor * ddPct / 100
ddBuffer = curBal - ddFloor
ddUsedPc = ddAllow > 0 ? math.max(0, ddAllow - ddBuffer) / ddAllow * 100 : 0

// status: <50% used = OK · 50-80% = CAUTION · 80-100% = DANGER · ≥100% = BREACHED
f_status(float usedPc) =>
    usedPc >= 100 ? 'BREACHED' : usedPc >= 80 ? 'DANGER' : usedPc >= 50 ? 'CAUTION' : 'OK'

f_statusCol(float usedPc) =>
    usedPc >= 80 ? dngC : usedPc >= 50 ? warnC : okC

// ── position sizing ──────────────────────────────────────────────────────────
entryP  = entryInp > 0 ? entryInp : close
haveSl  = stopInp > 0
slDist  = haveSl ? math.abs(entryP - stopInp) : na
isLong  = haveSl and stopInp < entryP
riskUsd = riskMode == 'Fixed $' ? riskFix : curBal * riskPct / 100

units    = haveSl and slDist > 0 ? riskUsd / (slDist * multInp) : na
fxLots   = na(units) ? na : units / 100000
notional = na(units) ? na : units * entryP * multInp

// risk sanity vs the two limits (is one stop-out more than what's left today?)
riskVsDay = dlLeft > 0 ? riskUsd / dlLeft * 100 : 999

// ── take profit (manual, like Entry/SL — never calculated or suggested) ─────
haveTp  = tpInp > 0
tpValid = haveTp and haveSl and (isLong ? tpInp > entryP : tpInp < entryP)
tpDist  = tpValid ? math.abs(tpInp - entryP) : na
rr      = tpValid and slDist > 0 ? tpDist / slDist : na
tpGain  = tpValid and not na(units) ? units * tpDist * multInp : na

// ═════════════════════════════════════════════════════════════════════════════
//  ENTRY / SL LINES + CROSS ALERTS (the only live, price-driven part)
// ═════════════════════════════════════════════════════════════════════════════
var line entryLn = na
var line slLn    = na
var line tpLn    = na
var label entryLb = na
var label slLb    = na
var label tpLb    = na

drawLines   = showLines and haveSl
drawTpLine  = drawLines and haveTp

if barstate.islast
    if drawLines
        if na(entryLn)
            entryLn := line.new(bar_index - 1, entryP, bar_index, entryP, extend=extend.both, color=color.new(#2196f3, 0), style=line.style_dashed, width=1)
            slLn    := line.new(bar_index - 1, stopInp, bar_index, stopInp, extend=extend.both, color=dngC, style=line.style_solid, width=1)
            entryLb := label.new(bar_index, entryP, 'Entry', style=label.style_label_left, color=color.new(#2196f3, 20), textcolor=color.white, size=size.small)
            slLb    := label.new(bar_index, stopInp, 'SL', style=label.style_label_left, color=color.new(#f23645, 20), textcolor=color.white, size=size.small)
        line.set_xy1(entryLn, bar_index - 1, entryP)
        line.set_xy2(entryLn, bar_index, entryP)
        line.set_xy1(slLn, bar_index - 1, stopInp)
        line.set_xy2(slLn, bar_index, stopInp)
        label.set_xy(entryLb, bar_index, entryP)
        label.set_xy(slLb, bar_index, stopInp)
    else
        if not na(entryLn)
            line.delete(entryLn)
            line.delete(slLn)
            label.delete(entryLb)
            label.delete(slLb)
            entryLn := na
            slLn    := na
            entryLb := na
            slLb    := na

    if drawTpLine
        if na(tpLn)
            tpLn := line.new(bar_index - 1, tpInp, bar_index, tpInp, extend=extend.both, color=okC, style=line.style_solid, width=1)
            tpLb := label.new(bar_index, tpInp, 'TP', style=label.style_label_left, color=color.new(#089981, 20), textcolor=color.white, size=size.small)
        line.set_xy1(tpLn, bar_index - 1, tpInp)
        line.set_xy2(tpLn, bar_index, tpInp)
        label.set_xy(tpLb, bar_index, tpInp)
    else
        if not na(tpLn)
            line.delete(tpLn)
            label.delete(tpLb)
            tpLn := na
            tpLb := na

// ta.cross must run unconditionally in global scope (execution-model rule)
crossSl    = ta.cross(close, stopInp)
crossEntry = ta.cross(close, entryInp)
crossTp    = ta.cross(close, tpInp)

alertcondition(stopInp > 0 and crossSl, title='Price crossed Stop level',
  message='Prop Firm Risk Guard: price crossed your STOP level.')
alertcondition(entryInp > 0 and crossEntry, title='Price crossed Entry level',
  message='Prop Firm Risk Guard: price crossed your ENTRY level.')
alertcondition(tpInp > 0 and crossTp, title='Price crossed Take Profit level',
  message='Prop Firm Risk Guard: price crossed your TAKE PROFIT level.')

// ═════════════════════════════════════════════════════════════════════════════
//  TABLE
// ═════════════════════════════════════════════════════════════════════════════
var table tbl = table.new(tablePos, 2, 23, bgcolor=color.new(#111318, 8), border_color=color.new(color.gray, 65), border_width=1, frame_color=color.new(color.gray, 55), frame_width=1)

var bool tblMerged = false
if barstate.islast and not tblMerged
    tblMerged := true
    table.merge_cells(tbl, 0, 0, 1, 0)
    table.merge_cells(tbl, 0, 1, 1, 1)
    table.merge_cells(tbl, 0, 6, 1, 6)
    table.merge_cells(tbl, 0, 11, 1, 11)
    table.merge_cells(tbl, 0, 15, 1, 15)

f_sec(int row, string txt) =>
    table.cell(tbl, 0, row, txt, text_color=color.new(color.white, 15), bgcolor=secBg, text_halign=text.align_left, text_size=tsize)

f_kv(int row, string k, string v, color vCol, color vBg) =>
    table.cell(tbl, 0, row, k, text_color=neutC, text_halign=text.align_left, text_size=tsize)
    table.cell(tbl, 1, row, v, text_color=vCol, bgcolor=vBg, text_halign=text.align_right, text_size=tsize)

if barstate.islast
    table.cell(tbl, 0, 0, 'PROP FIRM RISK GUARD · ' + accCur, text_color=color.white, bgcolor=color.new(#111318, 0), text_size=tsize)

    f_sec(1, 'ACCOUNT')
    f_kv(2, 'Starting Balance', f_usd(startBal), color.white, na)
    f_kv(3, 'Current Balance', f_usd(curBal), color.white, na)
    f_kv(4, 'Total P&L', f_usd(totPnl) + '  (' + f_pct(totPnlPc) + ')', totPnl >= 0 ? okC : dngC, na)
    f_kv(5, 'Target Progress', na(tgtProg) ? '—' : f_pct(math.max(0, tgtProg)) + ' of ' + f_pct(tgtPct), na(tgtProg) ? neutC : tgtProg >= 100 ? okC : color.white, na(tgtProg) ? na : tgtProg >= 100 ? color.new(okC, 70) : na)

    f_sec(6, 'DAILY LOSS LIMIT')
    f_kv(7, 'Today\'s P&L', f_usd(dayPnl), dayPnl >= 0 ? okC : dngC, na)
    f_kv(8, 'Daily Limit (' + f_pct(dlPct) + ')', f_usd(dlLimit), color.white, na)
    f_kv(9, 'Remaining Today', f_usd(dlLeft), dlLeft <= 0 ? color.white : f_statusCol(dlUsedPc), dlLeft <= 0 ? dngC : na)
    f_kv(10, 'Status', f_status(dlUsedPc) + '  (' + f_pct(math.min(999, dlUsedPc)) + ' used)', dlUsedPc >= 100 ? color.white : f_statusCol(dlUsedPc), dlUsedPc >= 100 ? dngC : na)

    f_sec(11, 'MAX DRAWDOWN (' + ddType + ')')
    f_kv(12, 'Equity Floor', f_usd(ddFloor), color.white, na)
    f_kv(13, 'Buffer Left', f_usd(ddBuffer), ddBuffer <= 0 ? color.white : f_statusCol(ddUsedPc), ddBuffer <= 0 ? dngC : na)
    f_kv(14, 'Status', f_status(ddUsedPc) + '  (' + f_pct(math.min(999, ddUsedPc)) + ' used)', ddUsedPc >= 100 ? color.white : f_statusCol(ddUsedPc), ddUsedPc >= 100 ? dngC : na)

    f_sec(15, 'POSITION SIZING')
    f_kv(16, 'Risk per Trade', f_usd(riskUsd) + (riskMode == '% of Balance' ? '  (' + f_pct(riskPct) + ')' : ''), color.white, na)
    if haveSl
        f_kv(17, 'Direction / SL Distance', (isLong ? 'LONG · ' : 'SHORT · ') + str.tostring(slDist, format.mintick), isLong ? okC : dngC, na)
        f_kv(18, 'Position Size (units)', na(units) ? '—' : str.tostring(units, '#,###.####'), color.white, na)
        f_kv(19, 'FX Lots (100k)', na(fxLots) ? '—' : str.tostring(fxLots, '#.###'), color.white, na)
        f_kv(20, 'Notional / 1-stop vs day left', (na(notional) ? '—' : f_usd(notional)) + '  ·  ' + f_pct(math.min(999, riskVsDay)), riskVsDay > 100 ? dngC : riskVsDay > 50 ? warnC : okC, na)
    else
        f_kv(17, 'Direction / SL Distance', 'set Stop Price', neutC, na)
        f_kv(18, 'Position Size (units)', '—', neutC, na)
        f_kv(19, 'FX Lots (100k)', '—', neutC, na)
        f_kv(20, 'Notional / 1-stop vs day left', '—', neutC, na)

    if not haveTp
        f_kv(21, 'R:R (Take Profit)', 'set Take Profit', neutC, na)
        f_kv(22, 'Gain if TP hit', '—', neutC, na)
    else if not tpValid
        f_kv(21, 'R:R (Take Profit)', 'TP on wrong side of Entry', dngC, na)
        f_kv(22, 'Gain if TP hit', '—', neutC, na)
    else
        f_kv(21, 'R:R (Take Profit)', str.tostring(rr, '#.##') + 'R', rr >= 2 ? okC : rr >= 1 ? warnC : dngC, na)
        f_kv(22, 'Gain if TP hit', na(tpGain) ? '—' : f_usd(tpGain), okC, na)
````
