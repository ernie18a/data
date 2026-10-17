# Monte Carlo Risk Geometry Simulator [Aslan]

- url: https://www.tradingview.com/script/GFOnOSWj-Monte-Carlo-Risk-Geometry-Simulator-Aslan/
- type: indicator
- pine_id: PUB;5d99367aaebd4561b955f23aba2d2624
- version: 1.0

## Description

[b]Thanks to @KioseffTrading for the polyline retracing system and the plotting system as a whole🙏[/b]

♦️ [b]What This Script Does[/b]
This is a Monte Carlo simulator for visualising and calculating the probability of a return based on risk geometry of the model (Risk %, RR, WR). It assesses the probability of returns by generating hundreds or thousands of possible outcomes using your win rate, risk-reward, and position sizing. Each line you see is a different plausible “future,” showing how your account could realistically evolve.

🔶 [b]How To Use It[/b]
Input your strategy stats, run a large number of simulations, and focus on three things: how wide the equity curves spread, how deep drawdowns get, and the percentage of profitable outcomes. Then adjust your model [s][/s]and repeat.

🔷 [b]Application in Prop Firm evaluations[/b]
Using the threshold system, you can see what risk geometry is most likely to pass a prop firm evaluation. [b]Suprisingly, the most probable geometry for passing an eval can sometimes have a negative expected value![/b]

♦️ [b]Bottom Line[/b]
This script helps you move from “how much can I make?” to “how likely am I to profit?”

🔎 [b]Monte Carlo Simulations Explained[/b]
Monte Carlo simulations are a method of modeling uncertainty by running many random versions of the same system to see all possible outcomes. In trading, instead of assuming one fixed result, it repeatedly simulates sequences of wins and losses based on your strategy’s statistics (like win rate and risk-reward). This creates a distribution of potential equity curves, showing not just what did happen, but could happen. It’s essentially a way to test probability and survival under randomness rather than relying on a single backtest. Monte Carlo simulations are widely used on quant trading desks around the world to model uncertainty, test strategy robustness, and estimate the probability distribution of trading outcomes under real-world randomness.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/


// Thanks to @KioseffTrading for providing the excellent polyline retracing system and entire plotting framework.


//@version=5
indicator("Monte Carlo Risk Geometry Visualiser [Aslan]",
     max_lines_count     = 500,
     overlay             = false,
     max_labels_count    = 500,
     max_boxes_count     = 500,
     max_polylines_count = 100)

// ── Inputs ────────────────────────────────────────────────────────────────────
seed          = input.int   (defval = 0,     title = "Set Seed",              minval = 0)
distT         = input.string(defval = "Normal", title = "Type",
                              options = ["Normal", "Bootstrap"])
sims          = input.int   (defval = 1000,  title = "Simulations",           minval = 1, step = 100)
forx          = input.int   (defval = 100,   title = "Trades to Forecast",    maxval = 498, step = 5) + 1
only          = input.bool  (defval = false, title = "Show Best / Worst Only")
lineS         = input.string(defval = "Solid", title = "Line Style",
                              options = ["Solid", "Dotted", "Dashed"])
showScale     = input.bool  (defval = false, title = "Show Scale")
forceForecast = input.bool  (defval = false, title = "Force Script Load [Cuts Off Some Simulations]")

// ── Strategy parameters ───────────────────────────────────────────────────────
winRate    = input.float(defval = 50.0,  title = "Win Rate (%)",   minval = 0.1, maxval = 99.9, step = 0.5) / 100
rr         = input.float(defval = 2.0,  title = "Risk : Reward",  minval = 0.01, step = 0.1)
riskPct    = input.float(defval = 1.0,  title = "Risk per Trade (%)", minval = 0.01, step = 0.1) / 100

thresh1Type = input.string(defval = "Returns", title = "Threshold 1 Type",      options = ["Sharpe", "Sortino", "Returns"])
thresh1Dir  = input.string(defval = "Over",    title = "Threshold 1 Over/Under", options = ["Over", "Under"])
thresh1Val  = input.float (defval = 10.0,      title = "Threshold 1 Value",      step = 0.5)

thresh2Type = input.string(defval = "Sharpe",  title = "Threshold 2 Type",      options = ["Sharpe", "Sortino", "Returns"])
thresh2Dir  = input.string(defval = "Over",    title = "Threshold 2 Over/Under", options = ["Over", "Under"])
thresh2Val  = input.float (defval = 1.0,       title = "Threshold 2 Value",      step = 0.25)

thresh3Type = input.string(defval = "Sortino", title = "Threshold 3 Type",      options = ["Sharpe", "Sortino", "Returns"])
thresh3Dir  = input.string(defval = "Over",    title = "Threshold 3 Over/Under", options = ["Over", "Under"])
thresh3Val  = input.float (defval = 2.0,       title = "Threshold 3 Value",      step = 0.25)

// ── Styling ───────────────────────────────────────────────────────────────────
finS = switch lineS
    "Dotted" => line.style_dotted
    "Solid"  => line.style_solid
    "Dashed" => line.style_dashed

// ── Helpers ───────────────────────────────────────────────────────────────────

calcThresh(threshType, threshDir, threshVal, sharpe, sortino, endPts, sz) =>
    result = 0.0
    if threshType == "Returns"
        cnt = 0
        for ep in endPts
            r = ep - 100.0
            if threshDir == "Over" and r > threshVal
                cnt += 1
            else if threshDir == "Under" and r < threshVal
                cnt += 1
        result := sz > 0 ? (cnt / sz) * 100 : 0.0
    else if threshType == "Sharpe"
        result := threshDir == "Over" ? (sharpe  > threshVal ? 100.0 : 0.0) : (sharpe  < threshVal ? 100.0 : 0.0)
    else
        result := threshDir == "Over" ? (sortino > threshVal ? 100.0 : 0.0) : (sortino < threshVal ? 100.0 : 0.0)
    result

tradeReturn(win) =>
    win ? riskPct * rr : -riskPct

distMean = winRate * rr * riskPct - (1 - winRate) * riskPct
distStd  = math.sqrt(winRate * (1 - winRate)) * (rr + 1) * riskPct

// Historical trade return array (for Bootstrap)
var tradeRets = array.new<float>()   // ✅ was array.new_float()

if last_bar_index - bar_index <= input.int(defval = 200, title = "Bootstrap Sample Bars", minval = 5, step = 10)
    isWin = math.random(0, 1, seed) < winRate
    tradeRets.push(tradeReturn(isWin))

method bootTrade(array<float> id) =>   // ✅ was array id
    id.get(int(math.random(0, id.size(), seed)))

distribution() =>
    switch distT
        "Normal" =>
            r1 = math.random(0.01, 0.99, seed)
            r2 = math.random(0.01, 0.99, seed)
            z  = math.sqrt(-2.0 * math.log(r1)) * math.cos(2.0 * math.pi * r2)
            distMean + distStd * z
        =>
            tradeRets.bootTrade()

// ── State ─────────────────────────────────────────────────────────────────────
var endPoints = array.new<float>()          // ✅ was array.new_float()
bestWorst     = matrix.new<float>(forx, 2)  // ✅ was matrix.new(forx, 2)
bestWorst.set(0, 0, 100.0)
bestWorst.set(0, 1, 100.0)

// ── Core simulation loop ──────────────────────────────────────────────────────
var keyValues = map.new<string, float>()    // ✅ was map.new()
loopBreak(start, end) =>

    for i = start to end

        equity  = 100.0
        points  = array.new<chart.point>()
        col     = color.rgb(math.random(0, 255), math.random(0, 255), math.random(0, 255))

        points.push(chart.point.from_index(bar_index, equity))

        for x = 1 to forx - 1

            ret    = distribution()
            equity := equity * (1 + ret)
            equity := math.max(equity, 0)

            points.push(chart.point.from_index(bar_index + x, equity))

            keyValues.put("Max", math.max(nz(keyValues.get("Max")),        equity))
            keyValues.put("Min", math.min(nz(keyValues.get("Min"), 20e20), equity))

            if only
                bestWorst.set(x, 0, math.max(nz(bestWorst.get(x, 0)),         equity))
                bestWorst.set(x, 1, math.min(nz(bestWorst.get(x, 1), 20e20),  equity))

        if not only
            endPoints.push(equity)
            polyline.new(points, line_color = col, line_style = finS)

// ── Run on last confirmed bar ─────────────────────────────────────────────────
if barstate.islastconfirmedhistory

    div = math.floor(sims / 20)

    loopBreak(0,              div)
    loopBreak(div + 1,        div * 2)
    loopBreak(div * 2 + 1,    div * 3)
    loopBreak(div * 3 + 1,    div * 4)
    loopBreak(div * 4 + 1,    div * 5)
    loopBreak(div * 5 + 1,    div * 6)
    loopBreak(div * 6 + 1,    div * 7)
    loopBreak(div * 7 + 1,    div * 8)
    loopBreak(div * 8 + 1,    div * 9)
    loopBreak(div * 9 + 1,    div * 10)
    loopBreak(div * 10 + 1,   div * 11)
    loopBreak(div * 11 + 1,   div * 12)
    loopBreak(div * 12 + 1,   div * 13)
    loopBreak(div * 13 + 1,   div * 14)
    loopBreak(div * 14 + 1,   div * 15)
    loopBreak(div * 15 + 1,   div * 16)
    loopBreak(div * 16 + 1,   div * 17)
    loopBreak(div * 17 + 1,   div * 18)
    loopBreak(div * 18 + 1,   div * 19)
    loopBreak(div * 19 + 1,   sims)

    // ── Best / Worst overlay ──────────────────────────────────────────────────
    if only
        bestPoints = array.new<chart.point>()
        worstPoints = array.new<chart.point>()
        for i = 0 to bestWorst.rows() - 1
            bestPoints.push(chart.point.from_index(bar_index + i, bestWorst.get(i, 0)))
            worstPoints.push(chart.point.from_index(bar_index + i, bestWorst.get(i, 1)))
        polyline.new(bestPoints,  line_color = #74ffbc,                    line_style = finS)
        polyline.new(worstPoints, line_color = color.rgb(255, 116, 116),   line_style = finS)

    if showScale
        getMin  = math.max(keyValues.get("Min") - 5, 0)
        getMax  = keyValues.get("Max")
        divSc   = (getMax - getMin) / 10

        line.new(bar_index + forx + 5, getMax, bar_index + forx + 5, getMin, color = chart.fg_color)
        line.new(bar_index - 1, getMin, bar_index + forx + 5, getMin, color = chart.fg_color)
        line.new(bar_index - 1, 100.0, bar_index + forx + 5, 100.0, color = color.white, style = line.style_dashed, width = 1)

        for i = 0 to 10
            calc = getMin + (divSc * i)
            label.new(bar_index + forx + 5, calc,
                 str.tostring(calc - 100.0, "#.##") + "%",
                 textcolor = chart.fg_color,
                 color     = #00000000,
                 size      = size.small,
                 style     = label.style_label_left)

        for i = 0 to forx - 2
            label.new(bar_index + i, getMin,
                 "T" + str.tostring(i),
                 textcolor = chart.fg_color,
                 color     = #00000000,
                 style     = label.style_label_up,
                 size      = size.auto)
// ── Summary table ─────────────────────────────────────────────────────────
    tbl = table.new(position.bottom_right, 2, 20,
         bgcolor      = #20222C,
         border_color = #363843,
         frame_color  = #363843,
         border_width = 1,
         frame_width  = 1)

    sortedEP = endPoints.copy()
    sortedEP.sort()
    sz       = sortedEP.size()

    medianEq = sz > 0 ? sortedEP.get(int(sz * 0.50)) : 100.
    p10Eq    = sz > 0 ? sortedEP.get(int(sz * 0.10)) : 100.
    p90Eq    = sz > 0 ? sortedEP.get(int(sz * 0.90)) : 100.

    ruinCount = 0
    if sz > 0
        for ep in endPoints
            if ep < 1.0
                ruinCount += 1
    pctRuinFinal = sz > 0 ? (ruinCount / sz) * 100 : 0.

    avgReturn  = sz > 0 ? (endPoints.copy().sum() / sz) - 100.0 : 0.0
    maxReturn  = sz > 0 ? sortedEP.last()  - 100.0 : 0.0
    minReturn  = sz > 0 ? sortedEP.first() - 100.0 : 0.0
    avgWinrate = winRate * 100

    retAbove0 = 0
    for ep in endPoints
        if ep > 100.0
            retAbove0 += 1
    pctProfitable = sz > 0 ? (retAbove0 / sz) * 100 : 0.0

    avgTradeReturn = distMean
    sharpe         = distStd > 0 ? (avgTradeReturn / distStd)  * math.sqrt(forx - 1) : 0.0
    lossStd        = (1.0 - winRate) * riskPct
    sortino        = lossStd > 0  ? (avgTradeReturn / lossStd) * math.sqrt(forx - 1) : 0.0

    t1pct = calcThresh(thresh1Type, thresh1Dir, thresh1Val, sharpe, sortino, endPoints, sz)
    t2pct = calcThresh(thresh2Type, thresh2Dir, thresh2Val, sharpe, sortino, endPoints, sz)
    t3pct = calcThresh(thresh3Type, thresh3Dir, thresh3Val, sharpe, sortino, endPoints, sz)
// ── Profit Factor and Drawdown ────────────────────────────────────────────
    grossWin  = winRate * rr * riskPct * 100.0
    grossLoss = (1.0 - winRate) * riskPct * 100.0
    pf        = grossLoss > 0 ? grossWin / grossLoss : 0.0

    // Per-sim max drawdown average
    ddSum = 0.0
    ddMax = 0.0
    ddMin = 100.0
    for ep in endPoints
        dd = ((ep - 100.0) / 100.0) * 100.0
        if dd < 0
            ddSum += math.abs(dd)
        ddMax := math.max(ddMax, math.abs(dd))
        ddMin := math.min(ddMin, math.abs(dd))
    avgDD = sz > 0 ? ddSum / sz : 0.0

    // ── Stats table ───────────────────────────────────────────────────────────
    tbl5 = table.new(position.bottom_right, 4, 7,
         bgcolor      = #20222C,
         border_color = #363843,
         frame_color  = #363843,
         border_width = 1,
         frame_width  = 1)

    tbl5.cell(0, 0, "Metric",               text_color = color.yellow, bgcolor = #2d2f3d)
    tbl5.cell(1, 0, "AVG",            text_color = color.yellow, bgcolor = #2d2f3d)
  

    tbl5.cell(0, 1, "Return",         text_color = color.white)
    tbl5.cell(1, 1, str.tostring(avgReturn,  "#.##") + "%", text_color = avgReturn  > 0 ? color.green : color.red)
 
    tbl5.cell(0, 2, "Sharpe",         text_color = color.white)
    tbl5.cell(1, 2, str.tostring(sharpe,  "#.##"), text_color = sharpe  > 1 ? color.green : sharpe  > 0 ? color.yellow : color.red)
 
    tbl5.cell(0, 3, "Sortino",        text_color = color.white)
    tbl5.cell(1, 3, str.tostring(sortino, "#.##"), text_color = sortino > 1 ? color.green : sortino > 0 ? color.yellow : color.red)

    tbl5.cell(0, 4, "Profit Factor",  text_color = color.white)
    tbl5.cell(1, 4, str.tostring(pf,  "#.##"), text_color = pf > 1 ? color.green : color.red)

    tbl5.cell(0, 5, "Drawdown",       text_color = color.white)
    tbl5.cell(1, 5, str.tostring(avgDD, "#.##") + "%", text_color = color.red)

// ── Thresholds table ──────────────────────────────────────────────────────
    tbl2 = table.new(position.bottom_left, 2, 5,
         bgcolor      = #20222C,
         border_color = #363843,
         frame_color  = #363843,
         border_width = 1,
         frame_width  = 1)

    tbl2.cell(0, 0, "Threshold",                                                           text_color = color.yellow, bgcolor = #2d2f3d)
    tbl2.cell(1, 0, "% Sims",                                                              text_color = color.yellow, bgcolor = #2d2f3d)

    tbl2.cell(0, 1, thresh1Type + " " + thresh1Dir + " " + str.tostring(thresh1Val, "#.##"), text_color = color.white)
    tbl2.cell(1, 1, str.tostring(t1pct, "#.#") + "%",                                     text_color = t1pct > 50 ? color.green : color.red)

    tbl2.cell(0, 2, thresh2Type + " " + thresh2Dir + " " + str.tostring(thresh2Val, "#.##"), text_color = color.white)
    tbl2.cell(1, 2, str.tostring(t2pct, "#.#") + "%",                                     text_color = t2pct > 50 ? color.green : color.red)

    tbl2.cell(0, 3, thresh3Type + " " + thresh3Dir + " " + str.tostring(thresh3Val, "#.##"), text_color = color.white)
    tbl2.cell(1, 3, str.tostring(t3pct, "#.#") + "%",                                     text_color = t3pct > 50 ? color.green : color.red)
    
    tbl3 = table.new(position.bottom_center, 2, 1,
     bgcolor      = #20222C,
     border_color = #363843,
     frame_color  = #363843,
     border_width = 1,
     frame_width  = 1)

    tbl3.cell(0, 0, "% Profitable", text_color = color.white)
    tbl3.cell(1, 0, str.tostring(pctProfitable, "#.#") + "%", text_color = pctProfitable > 50 ? color.green : color.red)

    tbl4 = table.new(position.top_center, 2, 1, bgcolor      = #20222C, border_color = #363843, frame_color  = #363843, border_width = 1, frame_width  = 1)

    tbl4.cell(0, 0, str.tostring(forx, "#.#") + " Trades", text_color = color.white)
    tbl4.cell(1, 0, str.tostring(sims, "#.#") + " Simulations", text_color = color.white)
````
