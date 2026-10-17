# Limit Ladder Planner [Zen]

- url: https://www.tradingview.com/script/lyeHcJpX-Limit-Ladder-Planner-Zen/
- type: indicator
- pine_id: PUB;f4e10f80bbd04214aae3bbef5122b555
- version: 1.0

## Description

Limit Ladder Planner [Zen] plans an entry with one to five equal limit orders inside one price zone. You set the zone, the stop and the target on the chart. The script sizes the orders so that the loss with every order filled and the stop hit equals your risk, fees included, and shows what you lose or make if only part of the ladder fills.

WHAT IS ORIGINAL
Position size and risk/reward calculators are standard tools. This one is built for a plan with several limit orders inside a zone, where you do not know in advance how many of them will fill:
- The total size is set for the worst case: every order filled and the stop hit. That loss, with the entry fees and the stop fee, equals the risk you set.
- The table shows every partial fill: L1 only, L1-L2 and so on. For each one: average entry, size, loss at the stop, profit at the target and R. You see how the reward-to-risk changes as more orders fill.
- Limit order fees are applied to the entries and the take profit, the market fee to the stop.
- Open source: the formulas below are the ones in the code.

HOW IT CALCULATES
- Direction comes from the stop: below the zone = long, above the zone = short. A stop inside the zone or exactly on its edge gives no plan.
- N orders (1 to 5) of equal size are spread evenly from the near edge of the zone to the far edge: for a long from the top edge down, for a short from the bottom edge up. L1 is the order at the near edge. With one order, L1 is the middle of the zone. Order prices are rounded to the symbol's price step.
- Risk = balance x risk %.
- Total size Q = Risk / ((sum of |entry - stop| + limit fee x sum of entries) / N + market fee x stop), with fees as decimals (0.02% = 0.0002). Each order = Q / N.
- Scenario "the first k orders filled", with q = Q / N:
  loss at the stop = q x sum of |entry - stop| + limit fee x q x sum of entries + market fee x k x q x stop
  profit at the target = q x sum of |target - entry| - limit fee x q x sum of entries - limit fee x k x q x target
  R = profit / loss
- Leverage only changes the margin shown (position value / leverage). It does not change the size or the risk.

ON THE CHART
- Nothing is drawn until the zone is set and the stop is outside it.
- The zone as a shaded area without a border: blue for a long, orange for a short. The first and the last order lines are its edges.
- A dashed line for each order, a red line for the stop and a green line for the target. They start 20 candles back and end one candle after the last candle. The target is drawn only when it is beyond the zone on the other side from the stop; otherwise the table asks you to move it.
- Short tags (L1, L2, ..., SL, TP) right after the last candle, where there are no candles.
- The price of every level is shown on the price scale: the orders in dark, the stop in red, the target in green. If you do not see these labels, turn on the indicator value labels in the chart's price scale settings.

TABLE (bottom right by default)
- Header: script name and timeframe.
- Plan: direction, risk in the symbol's quote currency and as % of the balance, number of orders x size of one order.
- One row per scenario (L1, L1-L2, ...): Avg entry, Size, Loss, Profit, R. Profit and R show a dash until the target is beyond the zone.
- All filled: position value and margin at your leverage.
- The fees used and "estimates only".
- Until the zone and the stop are set, or while the stop is inside the zone, the table shows what to fix instead of numbers.

ALERTS
- "Any alert() function call": a message as soon as the price touches the zone (L1), the stop or the target on the open candle, not at the candle close. Example: "BTCUSD 15m: price reached the zone, L1 83694.52." Each event is sent at most once per candle; events from the same price update come in one message.
- Three alert conditions: "Zone reached (L1)", "Stop reached" and "Target reached". Their messages include the exchange, ticker and timeframe. They follow the frequency you choose when you create the alert: once per bar fires on the touch, once per bar close at the candle close.
- A level counts as reached when the current candle touches it and the previous candle did not. When a later candle reaches it again after a candle that did not, the alert fires again.
- The zone alert uses L1: the near edge, or the middle of the zone with one order.
- An alert keeps the prices it was created with. After you move a line or change a setting, delete the alert and create it again.
- The script does not know whether your orders filled.

HOW TO USE
1. Add the script to the chart. TradingView asks you to click four prices: zone edge 1, zone edge 2, stop loss, take profit.
2. In the settings, set your balance, risk %, number of orders, leverage and your exchange's fees.
3. To change a price, drag its line on the chart or type it in the settings.
4. Check the table, then place the orders on your exchange yourself. The script does not place or track orders.
The levels are yours: the script does not suggest a zone, a stop or a target.

INPUTS (defaults)
- Zone edge 1, Zone edge 2, Stop loss, Take profit: set by clicks when the script is added
- Limit orders: 3 (1 to 5)
- Account balance: 1000
- Risk per trade %: 1 (0.01 to 100)
- Leverage: 10 (1 to 200)
- Limit order fee %: 0.02
- Stop (market) fee %: 0.06
- Table position: bottom right (also bottom center, top right, bottom left, top left)

LIMITS
- Estimates only. Slippage, spread, funding and liquidation are not included. Check on your exchange that the liquidation price is beyond your stop.
- For linear contracts (USDT-margined perpetuals) and spot, where profit = size x price change. Not for inverse (coin-margined) contracts.
- The balance and all results are in the symbol's quote currency, shown in the table.
- Sizes are in units of the base asset and are not rounded to your exchange's lot size or minimum order. The table shows them rounded (4 decimals, up to 8 below 0.01), so a row total can differ from the sum of the rounded order sizes in the last digit.
- Scenarios assume the orders fill in order from the near edge and the take profit is a limit order.
- In a very narrow zone several orders can get the same rounded price, and their tags can overlap. The prices stay on the price scale.
- If the table covers part of the plan, move it with Table position.
- Colours follow the chart theme (light or dark) automatically.

Not financial advice.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ChartZenFX
//@version=6
indicator("Limit Ladder Planner [Zen]", overlay = true, max_lines_count = 20, max_labels_count = 20, max_boxes_count = 2)

// Limit Ladder Planner [Zen]
// A plan for 1–5 equal limit orders spread across a POI zone, a stop and a target.
// The total size is set so that the loss with every order filled and the stop hit equals the risk, fees included.

// ---------- inputs ----------
gP = "Plan"
zA     = input.price(0.0, "Zone edge 1", confirm = true, group = gP, display = display.none, tooltip = "One edge of the entry zone. Click the chart when the script is added, type a price, or drag the line. The order of the two edges does not matter.")
zB     = input.price(0.0, "Zone edge 2", confirm = true, group = gP, display = display.none, tooltip = "The other edge of the entry zone.")
stopP  = input.price(0.0, "Stop loss", confirm = true, group = gP, display = display.none, tooltip = "Below the zone = long plan, above the zone = short plan.")
tgtP   = input.price(0.0, "Take profit", confirm = true, group = gP, display = display.none, tooltip = "Must be beyond the zone on the other side from the stop.")
nOrd   = input.int(3, "Limit orders", minval = 1, maxval = 5, group = gP, display = display.none, tooltip = "Equal-size orders spread evenly from the near edge of the zone to the far edge. One order sits in the middle of the zone.")
gR = "Risk"
bal    = input.float(1000.0, "Account balance", minval = 0.0, group = gR, display = display.none)
riskPc = input.float(1.0, "Risk per trade %", minval = 0.01, maxval = 100.0, step = 0.1, group = gR, display = display.none, tooltip = "The loss if every order fills and the stop is hit, fees included.")
lev    = input.float(10.0, "Leverage", minval = 1.0, maxval = 200.0, group = gR, display = display.none, tooltip = "Used only to show the margin: position value / leverage. It does not change the size or the risk.")
feeMk  = input.float(0.02, "Limit order fee %", minval = 0.0, step = 0.01, group = gR, display = display.none, tooltip = "Charged on the entries and on the take profit (limit orders).")
feeTk  = input.float(0.06, "Stop (market) fee %", minval = 0.0, step = 0.01, group = gR, display = display.none, tooltip = "Charged on the stop exit (market order).")
tblPosIn = input.string("Bottom right", "Table position", options = ["Bottom right", "Bottom center", "Top right", "Bottom left", "Top left"], group = "Display", display = display.none, tooltip = "If the table covers part of the plan, move it here. The prices of all levels stay on the price scale.")

// ---------- ChartZenFX palette (auto light / dark) ----------
bool isLight = (color.r(chart.bg_color) + color.g(chart.bg_color) + color.b(chart.bg_color)) / 3 > 128
color cHI     = isLight ? #AD4A12 : #D9703A
color cLO     = isLight ? #1B46B4 : #6F88EE
color cMUTED  = isLight ? #505C69 : #9AA3B2
color cINK    = isLight ? #1F2937 : #D1D4DC
color cPANEL  = isLight ? #F4F5F7 : #1E222D
color cHEAD   = #2A2E39
color cHEADTX = isLight ? #FFFFFF : #D1D4DC
color cBORDER = isLight ? #C4C8CE : #363A45
color cRISK   = isLight ? #B8404C : #E5707B
color cREW    = isLight ? #2E8A57 : #4FC27F

// ---------- plan ----------
float zTop = math.max(zA, zB)
float zBot = math.min(zA, zB)
bool isLong  = stopP < zBot
bool isShort = stopP > zTop
bool okStop  = (isLong or isShort) and zBot > 0 and stopP > 0
bool okTgt   = okStop and tgtP > 0 and (isLong ? tgtP > zTop : tgtP < zBot)
float mk = feeMk / 100.0
float tk = feeTk / 100.0

// limit prices: nearest edge first, evenly spread to the far edge (one order = middle of the zone), rounded to the price step
f_entry(int i) =>
    float near = isLong ? zTop : zBot
    float far  = isLong ? zBot : zTop
    math.round_to_mintick(nOrd == 1 ? (zTop + zBot) / 2 : near + (far - near) * i / (nOrd - 1))

// total size: loss with all orders filled and the stop hit = risk (entry fees + stop fee included)
float riskAmt = bal * riskPc / 100.0
float sumDist = 0.0
float sumE    = 0.0
for i = 0 to nOrd - 1
    float e = f_entry(i)
    sumDist += math.abs(e - stopP)
    sumE    += e
float lossPerUnit = (sumDist + mk * sumE) / nOrd + tk * stopP
float qTot = okStop and lossPerUnit > 0 ? riskAmt / lossPerUnit : na
float qOne = qTot / nOrd

// scenario k = the first k orders filled
f_scen(int k) =>
    float sE = 0.0
    float sD = 0.0
    float sG = 0.0
    for i = 0 to k - 1
        float e = f_entry(i)
        sE += e
        sD += math.abs(e - stopP)
        sG += math.abs(tgtP - e)
    float q = qOne * k
    float avg = sE / k
    float loss = qOne * sD + qOne * sE * mk + q * stopP * tk
    float gain = qOne * sG - qOne * sE * mk - q * tgtP * mk
    [avg, q, loss, gain, loss > 0 ? gain / loss : na, qOne * sE]

// ---------- drawing ----------
f_tf() => timeframe.isminutes ? (timeframe.multiplier % 60 == 0 ? str.tostring(int(timeframe.multiplier / 60)) + "H" : str.tostring(timeframe.multiplier) + "m") : timeframe.period
f_px(float x) => na(x) ? "—" : str.tostring(x, format.mintick)
f_qty(float x) => na(x) ? "—" : x < 0.01 ? str.tostring(x, "0.########") : str.tostring(x, "#,##0.####")
f_usd(float x) => na(x) ? "—" : str.tostring(x, "#,##0.00")

// the price of every level sits on the price scale: never cut by the chart edge, never under candles, buttons or the table
plot(okStop ? f_entry(0) : na, "L1", color = cINK, display = display.price_scale)
plot(okStop and nOrd >= 2 ? f_entry(1) : na, "L2", color = cINK, display = display.price_scale)
plot(okStop and nOrd >= 3 ? f_entry(2) : na, "L3", color = cINK, display = display.price_scale)
plot(okStop and nOrd >= 4 ? f_entry(3) : na, "L4", color = cINK, display = display.price_scale)
plot(okStop and nOrd >= 5 ? f_entry(4) : na, "L5", color = cINK, display = display.price_scale)
plot(okStop ? stopP : na, "SL", color = cRISK, display = display.price_scale)
plot(okTgt ? tgtP : na, "TP", color = cREW, display = display.price_scale)

var array<line>  lns = array.new<line>()
var array<label> lbs = array.new<label>()
var box zoneBox = na

if barstate.islast
    for l in lns
        line.delete(l)
    for b in lbs
        label.delete(b)
    array.clear(lns)
    array.clear(lbs)
    box.delete(zoneBox)
    if okStop
        int x1 = math.max(0, bar_index - 20)
        int x2 = bar_index + 1
        color cS = isLong ? cLO : cHI
        // zone: fill only, no border, so the L1 line and the last order line are the zone edges
        zoneBox := box.new(x1, zTop, x2, zBot, border_color = color.new(cS, 100), border_width = 0, bgcolor = color.new(cS, 85))
        // short tags right of the last candle (no candles there); prices are on the price scale
        for i = 0 to nOrd - 1
            float e = f_entry(i)
            array.push(lns, line.new(x1, e, x2, e, color = cINK, width = 1, style = line.style_dashed))
            array.push(lbs, label.new(x2, e, "L" + str.tostring(i + 1), style = label.style_label_left, color = cPANEL, textcolor = cINK, size = size.small))
        array.push(lns, line.new(x1, stopP, x2, stopP, color = cRISK, width = 2))
        array.push(lbs, label.new(x2, stopP, "SL", style = label.style_label_left, color = cPANEL, textcolor = cRISK, size = size.small))
        if okTgt
            array.push(lns, line.new(x1, tgtP, x2, tgtP, color = cREW, width = 2))
            array.push(lbs, label.new(x2, tgtP, "TP", style = label.style_label_left, color = cPANEL, textcolor = cREW, size = size.small))

// ---------- alerts: price reaches the zone (L1), the stop or the target ----------
float nearP = okStop ? f_entry(0) : na
bool evZone = okStop and (isLong ? low <= nearP and low[1] > nearP : high >= nearP and high[1] < nearP)
bool evStop = okStop and (isLong ? low <= stopP and low[1] > stopP : high >= stopP and high[1] < stopP)
bool evTgt  = okTgt and (isLong ? high >= tgtP and high[1] < tgtP : low <= tgtP and low[1] > tgtP)
string pre = syminfo.ticker + " " + f_tf() + ": "
// each event is sent once per bar; events of the same update go in one message
varip int aZone = -1
varip int aStop = -1
varip int aTgt  = -1
string msg = ""
if evZone and aZone != bar_index
    aZone := bar_index
    msg := "price reached the zone, L1 " + f_px(nearP)
if evStop and aStop != bar_index
    aStop := bar_index
    msg := (msg == "" ? "" : msg + "; ") + "price reached the stop " + f_px(stopP)
if evTgt and aTgt != bar_index
    aTgt := bar_index
    msg := (msg == "" ? "" : msg + "; ") + "price reached the target " + f_px(tgtP)
if msg != ""
    alert(pre + msg + ".", alert.freq_all)
alertcondition(evZone, "Zone reached (L1)", "{{exchange}}:{{ticker}} {{interval}} Limit Ladder Planner: price reached the zone (L1)")
alertcondition(evStop, "Stop reached", "{{exchange}}:{{ticker}} {{interval}} Limit Ladder Planner: price reached the stop")
alertcondition(evTgt, "Target reached", "{{exchange}}:{{ticker}} {{interval}} Limit Ladder Planner: price reached the target")

// ---------- table ----------
tblPos = switch tblPosIn
    "Bottom center" => position.bottom_center
    "Top right"    => position.top_right
    "Bottom right" => position.bottom_right
    "Bottom left"  => position.bottom_left
    => position.top_left

var table tb = table.new(tblPos, 6, 11, bgcolor = cPANEL, frame_color = cBORDER, frame_width = 1, border_width = 0)

// table rows (all of them depend only on the inputs, so the layout is fixed for the whole run)
int rWarn = okStop and not okTgt ? 2 : -1
int rHead = rWarn > 0 ? 3 : 2
int rF1   = rHead + nOrd + 1
if barstate.isfirst
    table.merge_cells(tb, 0, 0, 5, 0)
    table.merge_cells(tb, 0, 1, 5, 1)
    if not okStop
        table.merge_cells(tb, 0, 2, 5, 2)
    else
        if rWarn > 0
            table.merge_cells(tb, 0, rWarn, 5, rWarn)
        table.merge_cells(tb, 0, rF1, 5, rF1)
        table.merge_cells(tb, 0, rF1 + 1, 5, rF1 + 1)

f_cell(int col, int row, string t, color tc, bool num) =>
    table.cell(tb, col, row, t, text_color = tc, text_size = size.small, text_halign = num ? text.align_right : text.align_left, text_font_family = num ? font.family_monospace : font.family_default)

if barstate.islast
    string cur = syminfo.currency
    table.cell(tb, 0, 0, "Limit Ladder Planner [Zen] · " + f_tf(), text_color = cHEADTX, bgcolor = cHEAD, text_size = size.small)
    if not okStop
        bool unset = zBot <= 0 or stopP <= 0
        f_cell(0, 1, unset ? "Set the zone edges, the stop and the target:" : "Set the stop outside the zone:", cRISK, false)
        f_cell(0, 2, unset ? "open the settings and type the prices in Inputs." : "below it for a long, above it for a short.", cRISK, false)
    else
        f_cell(0, 1, (isLong ? "Long" : "Short") + " · risk " + f_usd(riskAmt) + " " + cur + " (" + str.tostring(riskPc, "#.##") + "%) · " + str.tostring(nOrd) + " × " + f_qty(qOne), cINK, false)
        if rWarn > 0
            f_cell(0, rWarn, "Set the target beyond the zone.", cRISK, false)
        f_cell(0, rHead, "Filled", cMUTED, false)
        f_cell(1, rHead, "Avg entry", cMUTED, true)
        f_cell(2, rHead, "Size", cMUTED, true)
        f_cell(3, rHead, "Loss", cMUTED, true)
        f_cell(4, rHead, "Profit", cMUTED, true)
        f_cell(5, rHead, "R", cMUTED, true)
        for k = 1 to nOrd
            int r = rHead + k
            [avg, q, loss, gain, rr, notional] = f_scen(k)
            f_cell(0, r, k == 1 ? "L1" : "L1–L" + str.tostring(k), cINK, false)
            f_cell(1, r, f_px(avg), cINK, true)
            f_cell(2, r, f_qty(q), cINK, true)
            f_cell(3, r, f_usd(loss), cINK, true)
            f_cell(4, r, okTgt ? f_usd(gain) : "—", okTgt ? cINK : cMUTED, true)
            f_cell(5, r, okTgt and not na(rr) ? str.tostring(rr, "0.00") : "—", cINK, true)
        float notAll = qOne * sumE
        f_cell(0, rF1, "All filled: " + f_usd(notAll) + " " + cur + " · margin " + f_usd(notAll / lev) + " (" + str.tostring(lev, "#.#") + "x)", cMUTED, false)
        f_cell(0, rF1 + 1, "Fees " + str.tostring(feeMk, "#.###") + "% limit / " + str.tostring(feeTk, "#.###") + "% stop · estimates only", cMUTED, false)
````
