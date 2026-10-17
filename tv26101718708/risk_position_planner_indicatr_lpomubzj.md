# Risk & Position Planner [Indicatr]

- url: https://www.tradingview.com/script/lpomUBzj-Risk-Position-Planner-Indicatr/
- type: indicator
- pine_id: PUB;8e2064767c6d4c04903a40898a0f85b4
- version: 1.0

## Description

[b]Risk & Position Planner[/b] turns a trade idea into numbers before you enter: position size for a fixed risk, risk : reward before and after costs, the win rate you need to break even, how wide your stop is compared to normal volatility, and what a losing streak would do to your account - for long and short.

[b]WHAT IT DOES[/b]
Most traders know their entry and stop, but not their position size, their real risk after costs or how many trades they could lose in a row. This tool shows all of it in one table and draws the trade as risk and reward zones on the chart.

[b]HOW IT WORKS[/b]
[list=1]
[*][b]Set the trade:[/b] when the script is added, click the entry point, the stop and the target on the chart. Direction is detected automatically (stop below entry = long, stop above entry = short). The target can also be set as an R multiple.
[*][b]Position size:[/b] risk amount (percent of account or a fixed amount) divided by the risk per unit. Risk per unit = stop distance x point value of the symbol + round-trip costs per unit. The size is rounded down to the size step (auto: 0.0001 for crypto, 1 for everything else), so the real risk never exceeds your limit.
[*][b]Costs:[/b] commission per side in percent and spread/slippage in ticks are included. The table shows risk : reward and the break-even win rate both gross and net of costs.
[*][b]Break-even win rate[/b] = 1 / (1 + R). At 1 : 2 you need just over 33 percent winners before costs.
[*][b]Stop check:[/b] the stop distance is expressed in ATR. Below 1 ATR the stop sits inside normal noise and is flagged; 1 to 3 ATR is typical; above 3 ATR is wide.
[*][b]Loss streak preview:[/b] shows how much of the account a series of losses at this risk would cost (default 10 trades, compounded).
[*][b]Since entry:[/b] after the entry time, the script tracks which level was reached first - stop or target - and ends the zones there.
[/list]

[b]HOW TO USE[/b]
[list]
[*]Plan before you click buy or sell: check size, net R and break-even win rate.
[*]If the stop is flagged as inside normal noise, consider a wider stop with a smaller position instead of a tight stop with a large one.
[*]Change account size, risk and costs in the inputs; move entry, stop and target by dragging the points or in the settings.
[*]Alerts: stop level reached, target level reached, price crossed entry.
[/list]

[b]THE CHART[/b]
BTCUSD daily. Long planned at the last close with a stop 1.56 ATR below and the target at 2R. Account 10,000, risk 1 percent, no costs entered. The table shows position size 0.0294 BTC, risk 99.69 USD, risk : reward 1 : 2, break-even win rate 33.3 percent and a 10-trade losing streak of about -9.5 percent.

[b]WHAT IS ORIGINAL[/b]
Position size calculators already exist. This one combines sizing with three checks that are usually missing: the cost-adjusted break-even win rate, the stop distance measured in ATR with a noise warning, and a compounded losing-streak preview. It also tracks whether stop or target was reached first after the entry.

[b]LIMITATIONS[/b]
[list]
[*]Amounts are shown in the currency of the symbol. If your account currency is different, convert the risk amount yourself.
[*]Point value comes from the symbol information; check contract specs with your broker, especially for CFDs and forex lot sizes.
[*]The outcome check uses bar highs and lows. If stop and target are both touched in the same bar, the stop is counted first (conservative).
[*]The tool does not place orders and gives no trade signals.
[/list]

[b]Disclaimer[/b]
For educational and analytical purposes only. Not financial advice. Marks and signals are not buy or sell recommendations. Past behaviour does not guarantee future results.

## Source Code

````pine
//@version=6
indicator("Risk & Position Planner [Indicatr]", shorttitle="Risk Planner [Indicatr]", overlay=true, max_boxes_count=10, max_lines_count=10, max_labels_count=10)

// ===== Inputs =====
grpT = "Trade (click entry, stop and target on the chart)"
entryTime = input.time(0, "Entry", confirm=true, group=grpT, inline="Entry")
entry     = input.price(0.0, "", confirm=true, group=grpT, inline="Entry")
stopP     = input.price(0.0, "Stop", confirm=true, group=grpT)
tgtMode   = input.string("Target price", "Target from", options=["Target price", "R multiple"], group=grpT)
tgtP      = input.price(0.0, "Target price", confirm=true, group=grpT)
tgtR      = input.float(2.0, "Target in R", minval=0.1, step=0.1, group=grpT)

grpA = "Account and risk"
acct     = input.float(10000, "Account size", minval=1, group=grpA)
riskMode = input.string("% of account", "Risk per trade", options=["% of account", "Fixed amount"], group=grpA)
riskPct  = input.float(1.0, "Risk %", minval=0.01, maxval=100, step=0.25, group=grpA)
riskFix  = input.float(100, "Risk amount", minval=0.01, group=grpA)
sizeIn   = input.float(0, "Size step (0 = auto: crypto 0.0001, others 1)", minval=0, group=grpA)
fxLots   = input.bool(false, "Show forex lots (1 lot = 100,000 units)", group=grpA)

grpC = "Costs (round trip)"
commPct = input.float(0.0, "Commission per side (% of trade value)", minval=0, step=0.01, group=grpC)
slipTk  = input.float(0.0, "Spread + slippage (ticks, total)", minval=0, step=1, group=grpC)

grpX = "Checks"
atrLen   = input.int(14, "ATR length (stop distance check)", minval=1, group=grpX)
streakN  = input.int(10, "Loss streak preview (trades)", minval=1, maxval=50, group=grpX)

grpD = "Display"
colRisk = input.color(color.new(#C0412F, 80), "Risk zone", group=grpD, inline="z")
colRew  = input.color(color.new(#1B5E40, 80), "Reward zone", group=grpD, inline="z")
zoneBars = input.int(25, "Zone length (bars to the right)", minval=1, group=grpD)
tblPos  = input.string("Top right", "Table position", options=["Top right", "Bottom right", "Top left", "Bottom left"], group=grpD)

// ===== Calculation =====
sizeStep = sizeIn > 0 ? sizeIn : syminfo.type == "crypto" ? 0.0001 : 1.0
pv     = syminfo.pointvalue
atr    = ta.atr(atrLen)
valid  = entry > 0 and stopP > 0 and entry != stopP
isLong = stopP < entry
dir    = isLong ? 1.0 : -1.0
riskPx = math.abs(entry - stopP)
target = tgtMode == "R multiple" ? entry + dir * tgtR * riskPx : tgtP
tgtOk  = valid and target > 0 and (isLong ? target > entry : target < entry)
rewPx  = tgtOk ? math.abs(target - entry) : na

riskMoney = riskMode == "% of account" ? acct * riskPct / 100 : riskFix

// costs per unit for one round trip
exitRef     = tgtOk ? target : stopP
costPerUnit = (entry + exitRef) * commPct / 100 * pv + slipTk * syminfo.mintick * pv

riskPerUnit = riskPx * pv + costPerUnit
rawSize     = valid and riskPerUnit > 0 ? riskMoney / riskPerUnit : na
size        = na(rawSize) ? na : math.floor(rawSize / sizeStep) * sizeStep

actRisk   = size * riskPerUnit
actRiskPc = actRisk / acct * 100
rewMoney  = tgtOk ? size * (rewPx * pv - costPerUnit) : na
rrGross   = tgtOk ? rewPx / riskPx : na
rrNet     = tgtOk ? (rewPx * pv - costPerUnit) / riskPerUnit : na
beGross   = tgtOk ? 100 / (1 + rrGross) : na
beNet     = tgtOk and rrNet > 0 ? 100 / (1 + rrNet) : na
stopATR   = riskPx / math.max(atr, syminfo.mintick)
streakDD  = (1 - math.pow(1 - actRiskPc / 100, streakN)) * 100
notional  = size * entry * pv

// ===== Outcome tracking (which level was reached first after entry) =====
var int   outcome = 0      // 0 = open, 1 = target first, -1 = stop first
var int   outTime = na
started = valid and entryTime > 0 and time > entryTime
upTouch = isLong ? high >= target : low <= target
dnTouch = isLong ? low <= stopP : high >= stopP
if started and outcome == 0
    if dnTouch
        outcome := -1
        outTime := time
    else if tgtOk and upTouch
        outcome := 1
        outTime := time

// ===== Helpers =====
fmtM(float x) => str.tostring(x, "#,##0.00") + " " + syminfo.currency
fmtP(float x) => str.tostring(x, format.mintick)
fmtS(float x) => str.tostring(x, sizeStep >= 1 ? "#,##0" : "#,##0.########")

tPos = switch tblPos
    "Top right"    => position.top_right
    "Bottom right" => position.bottom_right
    "Top left"     => position.top_left
    => position.bottom_left

// ===== Drawing (last bar only) =====
var box  bRisk = na
var box  bRew  = na
var line lE = na
var line lS = na
var line lT = na
var table tb = table.new(tPos, 2, 12, bgcolor=color.new(color.white, 8), border_color=color.new(color.gray, 75), border_width=1)

row(int r, string k, string v, color c = color.black) =>
    table.cell(tb, 0, r, k, text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(tb, 1, r, v, text_color=c, text_size=size.small, text_halign=text.align_right)

if barstate.islast
    box.delete(bRisk)
    box.delete(bRew)
    line.delete(lE)
    line.delete(lS)
    line.delete(lT)
    table.clear(tb, 0, 0, 1, 11)
    if not valid
        row(0, "Risk & Position Planner", "")
        row(1, "Set entry and stop", "Entry and stop must differ", color.new(#C0412F, 0))
    else
        msPerBar = timeframe.in_seconds() * 1000
        x1 = entryTime > 0 ? entryTime : time
        x2 = outcome != 0 ? outTime : math.max(x1, time) + zoneBars * msPerBar
        bRisk := box.new(x1, entry, x2, stopP, xloc=xloc.bar_time, bgcolor=colRisk, border_color=color.new(colRisk, 40))
        lE := line.new(x1, entry, x2, entry, xloc=xloc.bar_time, color=color.gray, width=1)
        lS := line.new(x1, stopP, x2, stopP, xloc=xloc.bar_time, color=color.new(#C0412F, 0), width=1)
        if tgtOk
            bRew := box.new(x1, target, x2, entry, xloc=xloc.bar_time, bgcolor=colRew, border_color=color.new(colRew, 40))
            lT := line.new(x1, target, x2, target, xloc=xloc.bar_time, color=color.new(#1B5E40, 0), width=1)

        dirCol  = isLong ? #1B5E40 : #C0412F
        sizeTxt = fmtS(size) + (fxLots ? " (" + str.tostring(size / 100000, "#.##") + " lots)" : "")
        noise   = stopATR < 1 ? "inside normal noise" : stopATR <= 3 ? "typical" : "wide"
        noiseC  = stopATR < 1 ? color.new(#C0412F, 0) : color.black
        row(0, "Direction", isLong ? "Long" : "Short", dirCol)
        row(1, "Position size", size > 0 ? sizeTxt : "0 (risk too small)", size > 0 ? color.black : color.new(#C0412F, 0))
        row(2, "Position value", fmtM(notional))
        row(3, "Risk if stopped", fmtM(actRisk) + " (" + str.tostring(actRiskPc, "#.##") + " %)")
        row(4, "Reward at target", tgtOk ? fmtM(rewMoney) : "set a valid target")
        row(5, "Risk : reward", tgtOk ? "1 : " + str.tostring(rrGross, "#.##") + "  (net 1 : " + str.tostring(rrNet, "#.##") + ")" : "-")
        row(6, "Break-even win rate", tgtOk ? str.tostring(beGross, "#.#") + " %  (net " + (na(beNet) ? "n/a" : str.tostring(beNet, "#.#") + " %") + ")" : "-")
        row(7, "Stop distance", fmtP(riskPx) + " = " + str.tostring(stopATR, "#.##") + " ATR (" + noise + ")", noiseC)
        row(8, "Costs per unit", fmtM(costPerUnit))
        row(9, str.tostring(streakN) + " losses in a row", "-" + str.tostring(streakDD, "#.#") + " % of account")
        row(11, "Since entry", outcome == 1 ? "Target reached first" : outcome == -1 ? "Stop reached first" : "Open (no level reached)", outcome == 1 ? #1B5E40 : outcome == -1 ? #C0412F : color.gray)
        row(10, "Entry / stop / target", fmtP(entry) + " / " + fmtP(stopP) + " / " + (tgtOk ? fmtP(target) : "-"))

// ===== Alerts =====
active  = valid and time >= entryTime
hitStop = active and (isLong ? low <= stopP : high >= stopP)
hitTgt  = active and tgtOk and (isLong ? high >= target : low <= target)
crossE  = ta.cross(close, entry)
hitEnt  = active and crossE
alertcondition(hitStop, "Stop level reached",   "Risk Planner {{ticker}} {{interval}}: stop level reached at {{close}}")
alertcondition(hitTgt,  "Target level reached", "Risk Planner {{ticker}} {{interval}}: target level reached at {{close}}")
alertcondition(hitEnt,  "Price crossed entry",  "Risk Planner {{ticker}} {{interval}}: price crossed the entry level ({{close}})")
````
