# Optimal F by Ralph Vince. Position Sizing and Risk Analysis

- url: https://www.tradingview.com/script/b4HV7iJR-Optimal-F-by-Ralph-Vince-Position-Sizing-and-Risk-Analysis/
- type: strategy
- pine_id: PUB;c09f5b8c59224ecaa26edf37a0850272
- version: 1.0

## Description

Even a profitable strategy can produce weak results when position sizing is poorly calibrated. A position that is too small limits capital growth, while excessive exposure can turn an ordinary losing streak into a severe drawdown. MM: Optimal F analyzes the actual trade results of your strategy and identifies the historical risk level that produced the highest geometric capital growth.

The script implements the Optimal F concept developed by Ralph Vince. The method searches for the fraction of capital that maximizes the compounded result of the complete trade sequence, represented by Terminal Wealth Relative, or `G(f)`. Optimal F is not designed to maximize the profit of an individual trade. Its purpose is to optimize the long-term compounded growth of the entire system.

[b]How the Script Works[/b]

The strategy must first be tested using a fixed position size of one contract or one unit of the traded instrument.
For every closed trade, the script calculates the financial result per contract. It then identifies the largest historical losing trade: Max Loss per Contract
Every trade is normalized relative to this loss: R = Profit per Contract / Max Loss per Contract
The script then tests values of `f` from 0.00 to 1.00 and calculates the following result for each value: G(f) = Π(1 + f × R)

A curve showing the relationship between `f` and `G(f)` is displayed on the chart.
The script reports four main values:
[list]
[*]Best F — the value of `f` that produced the highest historical geometric growth.
[*]Best G(f) — the maximum theoretical growth multiplier for the analyzed trade sequence.
[*]Max Loss — the largest closed loss per contract.
[*]Recommended Contracts — the calculated position size based on the current account equity.
[/list]
The number of contracts is calculated using: Contracts = Equity × Selected F / Max Loss per Contract

[i]Example:
Equity = 100,000
Selected F = 0.21
Max Loss per Contract = 9,775
Contracts = 100,000 × 0.21 / 9,775
Contracts = 2.15[/i]

For futures trading, the result is rounded down:  2 contracts
The table displays the value in the following format:  2 (2.15)
The first number is the whole-contract position size. The value in parentheses is the exact calculated position size before rounding.

[b]What Optimal F Actually Means[/b]
A result such as: Best F = 0.21
does not mean that the strategy should enter a position using 21% of account equity as the nominal position value.

It means that the position size should be calculated so that a repetition of the largest historical loss per contract would represent approximately 21% of the current account equity.
For this reason, Optimal F cannot be replicated by simply setting:
Order size = 21% of equity
in the TradingView strategy settings.

The percentage of equity used as nominal position value and the percentage of equity exposed to the largest historical loss are different measurements.

[b]Full F and Fractional F[/b]
Full Optimal F maximizes historical geometric growth, but it usually produces aggressive position sizing, large equity fluctuations, and deep drawdowns. It does not optimize equity-curve smoothness and does not impose a maximum drawdown limit.

Ralph Vince specifically discussed Half F, or 50% of the calculated Optimal F, as an attractive practical compromise. In his example, Half F reduced variability and expected drawdown by approximately half, although more trades were required to reach the same capital objective. He also noted that using a smaller fraction of Optimal F generally produces a smoother equity curve.

[i]Example:
Best F = 0.21
Full F    = 0.21
Half F    = 0.105
Quarter F = 0.0525[/i]

Half F is calculated as:
Selected F = Best F × 0.50

This should not be treated as a universal rule. Half F is a more conservative starting point that can be compared with Full F and other fractional values.

[b]How to Use the Script[/b]
1. Insert your own strategy code into the designated strategy section.
2. Disable: "Enable Optimal F Position Sizing"
In this mode, the strategy should be tested using one contract.
3. Verify that the following strategy properties are configured correctly:[list]
[*]Initial Capital
[*]Commission
[*]Slippage
[*]Margin
[/list]
These parameters directly affect trade results, the largest losing trade, and the calculated Optimal F.
4. Run the backtest and record:[list]
[*]Best F
[*]Max Loss per Contract
[*]Recommended Contracts
[/list]
5. Select the fraction of Optimal F that you intend to apply:[list]
[*]Full F
[*]Half F
[*]Quarter F
[/list]
A more conservative starting point is:  Selected F = Best F × 0.50
6. Enter the selected value into:  [b]Optimal F[/b]
7. Enter the calculated maximum loss per contract into:  [b]Max Loss[/b]
8. Enable:  "Enable Optimal F Position Sizing"
The strategy will now dynamically recalculate its position size before every new trade using the current account equity.
9. For futures trading, enable:  Rounds contracts number

The calculated position size will be rounded down to a whole number of contracts. When the calculated size is below one contract, the strategy will continue trading one contract.

[b]Important Limitations[/b]
Optimal F is calculated from historical trades. A future loss may exceed the largest loss observed in the backtest.
Full Optimal F often creates excessive exposure. Results should therefore be evaluated using more than Net Profit alone. Important metrics include:[list]
[*]Maximum Drawdown
[*]Recovery Factor
[*]Equity Curve Stability
[*]Largest Losing Trade
[*]Maximum Losing Streak
[/list]
For a more objective evaluation, calculate Optimal F on one section of historical data and apply the fixed values to a separate out-of-sample period.

[b]Insert your own strategy into MM: Optimal F, run the analysis using one contract, and determine the level of risk that is actually supported by the historical structure of your strategy’s profits and losses.[/b]

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Smollet

//@version=6
strategy('MM: Optimal F', max_labels_count = 500, max_lines_count = 500, max_polylines_count = 100, initial_capital = 100000, margin_long = 0, margin_short = 0)

optF_on = input.bool(false, "Enable Optimal F Position Sizing")
i_optF = input.float(0.21, "Optimal F", minval = 0.0, maxval = 1.0, step = 0.01)
i_maxLossPerContract = input.float(9794.92, "Max Loss", minval = 0.0)
floor_on = input.bool(false, "Rounds contracts number")

//Optimal f
var tb = table.new(position.top_center, 6, 6, na, na, 0, na)
var the_curve = array.new<chart.point>(100 + 1, na)
var trades_pl = array.new<float>(0, 0)
var arr_r = array.new<float>(0, 0)
var arr_gr = array.new<float>(0, 0)

var float max_loss = 0
var float best_gr = 0
var float best_f = 0

curve_clr = #3333ff



poly(_arr, _col, _t, _tr) =>
    for t = 1 to _t by 1
        polyline.new(_arr, false, false, xloc.bar_index, color.new(_col, 0 + t * _tr), line_width = t)



f_G_function(R_array, f, NEG_INF) =>
    float G = 1
    int N = array.size(R_array)

    G := 1
    if array.size(R_array) > 0
        for i = 0 to N - 1
            float R = array.get(R_array, i)
            float val = 1 + f * R

            // If val <= 0 → bankruptcy → G = 0
            if val <= 0
                G := NEG_INF
                break

            G := G * val
    G


method t_c(table _id, int _c, int _r, string _txt, float _val, color _col) =>
    _id.cell(_c, _r, _txt, 0, 0, color.gray)
    _id.cell(_c + 1, _r, str.tostring(_val, '#.##'), 0, 0, _col)


method t_c_str(table _id, int _c, int _r, string _txt, string _val, color _col) =>
    _id.cell(_c, _r, _txt, 0, 0, color.gray)
    _id.cell(_c + 1, _r, _val, 0, 0, _col)





//Filling the trades result into the array
var int processedClosedTrades = 0

if strategy.closedtrades > processedClosedTrades
    for tradeIndex = processedClosedTrades to strategy.closedtrades - 1
        float tradeProfit = strategy.closedtrades.profit(tradeIndex)
        float tradeSize = math.abs(strategy.closedtrades.size(tradeIndex))

        if tradeSize > 0
            float profitPerContract = tradeProfit / tradeSize
            trades_pl.push(profitPerContract)

    processedClosedTrades := strategy.closedtrades
//Filling the trades result into the array


//Position sizing
var float positionSize = 0
rawPositionSize = optF_on ? i_maxLossPerContract > 0 ? strategy.equity * i_optF / i_maxLossPerContract : 0.0 : 1.0
positionSize := floor_on ? math.max(math.floor(rawPositionSize), 1.0) : math.max(rawPositionSize, 0.0)


//Main logic
if barstate.islastconfirmedhistory
    tradesCount = trades_pl.size()
    worstTrade = tradesCount > 0 ? array.min(trades_pl) : na
    hasLosingTrade = not na(worstTrade) and worstTrade < 0

    best_gr := 0
    best_f := 0

    if hasLosingTrade
        max_loss := math.abs(worstTrade)

        arr_r.clear()
        arr_gr.clear()

        for i = 0 to tradesCount - 1
            float r = trades_pl.get(i) / max_loss
            arr_r.push(r)

        float f = 0
        float gr_min = 0

        for i = 0 to 100
            f := i / 100.0

            g_r = f_G_function(arr_r, f, gr_min)

            the_curve.set(i, chart.point.from_index(bar_index - 100 + i, g_r))
            arr_gr.push(g_r)

            if g_r > best_gr
                best_gr := g_r
                best_f := f

        max = arr_gr.max()
        min = arr_gr.min()

        vertical_step = 5

        f := 0
        for i = 0 to 100 by vertical_step
            label.new(bar_index - 100 + i, min, str.tostring(f, '#.##'), style = label.style_label_up, textcolor = color.gray, color = color.rgb(255, 255, 255, 100))
            line.new(bar_index - 100 + i, min, bar_index - 100 + i, max, color = color.new(color.gray, 80), style = line.style_dashed)
            f := f + vertical_step / 100

        linesCount = 20
        y_range = math.abs(max - min)

        if y_range > 0
            horizontal_step = y_range / (linesCount - 1)

            for i = 0 to linesCount - 1
                y = min + horizontal_step * i
                line.new(bar_index - 100, y, bar_index, y, extend = extend.none, style = line.style_dashed, color = color.new(color.gray, 80))
                label.new(bar_index - 100, y, str.tostring(y, '#.##'), style = label.style_label_right, color = color.rgb(255, 255, 255, 100), textcolor = color.gray)


        //Draw Curve Line and Box window
        poly(the_curve, curve_clr, 2, 10)
        box.new(bar_index - 100, max + 0.15, bar_index, min, color.gray, 1, bgcolor = na, text_color = color.black)

    else
        max_loss := na


    //Table in the middle with Best Results
    if optF_on == false and hasLosingTrade
        recommendedContractsRaw = strategy.equity * best_f / max_loss
        recommendedContractsRounded = math.max(math.floor(recommendedContractsRaw), 1.0)
        recommendedContractsText = str.tostring(recommendedContractsRounded, '#') + ' (' + str.tostring(recommendedContractsRaw, '#.##') + ')'

        tb.t_c(0, 0, 'Best F:', best_f, color.green)
        tb.t_c(0, 1, 'Best G(f):', best_gr, curve_clr)
        tb.t_c(0, 2, 'Max Loss:', max_loss, color.red)
        tb.t_c_str(0, 3, 'Recommended Contracts [Equity * Best F / Max Loss]:', recommendedContractsText, color.black)

//END Optimal f









//Insert your Strategy code here --------------------------------------------------------
//Super Trend Strategy code
atrPeriod = 20
factor = 1

[supertrend, direction] = ta.supertrend(factor, atrPeriod)

supertrend := barstate.isfirst ? na : supertrend
upTrend = plot(direction < 0 ? supertrend : na, "Up Trend", color = color.green, style = plot.style_linebr, force_overlay = true)
downTrend = plot(direction < 0 ? na : supertrend, "Down Trend", color = color.red, style = plot.style_linebr, force_overlay = true)
bodyMiddle = plot(barstate.isfirst ? na : (open + close) / 2, "Body Middle", display = display.none, force_overlay = true)

fill(bodyMiddle, upTrend, title = "Uptrend background", color = color.new(color.green, 90), fillgaps = false)
fill(bodyMiddle, downTrend, title = "Downtrend background", color = color.new(color.red, 90), fillgaps = false)

le = direction < 0 and direction[1] > 0
se = direction > 0 and direction[1] < 0

if le and strategy.position_size <= 0 and positionSize > 0
    strategy.entry("Long", strategy.long, positionSize)

if se
    strategy.close("Long", "Long Exit")
//END Super Trend Strategy code
//Insert your Strategy code here --------------------------------------------------------
````
