<!-- tradingview-pine-id: PUB;79e63665c72d460ca87d14840026dc02 -->
<!-- tradingviewscripts-format: 1 -->
# Modified Mannarino Market Risk Indicator

Source: https://www.tradingview.com/script/snuFoPT6-Modified-Mannarino-Market-Risk-Indicator-MMMRI-MMRI/

## Description

Modified Mannarino Market Risk Indicator MMMRI was developed by "Nobody Special Finance" as an enhancement to the original MMRI developed by Gregory Mannarino. The original and modified version were created as a way to gauge current level of risk in the market. This published indicator includes both versions along with ability to customize the symbols, denominators, and ratio factors that are used within their formulas. Additional options have been included to colorize the candles, plot, and level fills, as well as the option to show or hide a table containing the realtime values for both versions, along with the current dollar strength and 10Y yield.

Levels of market risk are denoted by dashed lines which represent the following levels:  0-50 slight risk, 50-100 low risk, 100-200 moderate risk, 200-300 high risk, 300+ extreme risk. The plot displays whichever of the following two formulas has been selected in the indicator settings, the default choice has been set to MMMRI:

MMRI = (USD Strength * USD Interest Rate) / 1.61

MMMRI = (Debt / GDP) * (USD Strength * USD Interest Rate) / 1.61

NOTICE: This is an example script and not meant to be used as an actual strategy. By using this script or any portion thereof, you acknowledge that you have read and understood that this is for research purposes only and I am not responsible for any financial losses you may incur by using this script!

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © allanster

// MMRI Gregory Mannarino: https://www.mannarino-market-risk-indicator.com/
// MMRI = (USD Strength * USD Interest Rate) / 1.61

// MMMRI Nobody Special Finance: https://www.mannarino-market-risk-indicator.com/MMMRI/ 
// MMMRI = (Debt / GDP) * (USD Strength * USD Interest Rate) / 1.61

//@version=5
indicator("Modified Mannarino Market Risk Indicator")

i_fiat = input.symbol('TVC:DXY',         'USD Strength')
i_intr = input.symbol('TVC:US10Y',       '10 Year Yield')
i_dgmr = input.float (1.61,              'Denominator', minval = 0.01)
i_nsff = input.bool  (true,              'Use Modified MMRI')
i_dgdp = input.symbol('ECONOMICS:USGDG', 'Debt To GDP Ratio')
i_fctr = input.bool  (false,             'Use Custom Ratio Below')
i_debt = input.symbol('ECONOMICS:USGD',  'Debt')
i_tgdp = input.symbol('ECONOMICS:USGDP', 'GDP')
i_bars = input.bool  (true,              'Color Bars')
i_plot = input.bool  (true,              'Color Plot')
i_fill = input.bool  (true,              'Color Fills')
i_tabl = input.bool  (true,              'Show Values')

repaint(_symbol) => nz(request.security(_symbol, timeframe.period, close, ignore_invalid_symbol = true),
 request.security(_symbol, timeframe.isintraday ? 'D' : timeframe.period, close))

dollar = repaint(i_fiat)
intrst = repaint(i_intr)
usdebt = repaint(i_debt)
ustgdp = repaint(i_tgdp)
dbtgdp = repaint(i_dgdp)

mmriGM = (dollar * intrst) / i_dgmr
fctrNS = i_fctr ? usdebt / ustgdp : dbtgdp / 100  // use custom (usdebt / ustgdp) or (dbtgdp / 100)
mmriNS = fctrNS * mmriGM
pcntNS = fctrNS * 100

output = i_nsff ? mmriNS : mmriGM

// 0-50 slight risk, 50-100 low risk, 100-200 moderate risk, 200-300 high risk, 300+ extreme risk
colrSR = #00ffff, colrLR = #00ff00, colrMR = #ffff00, colrHR = #ff7f00, colrER = #ff0000

colors(_valu) =>
    colors =
     _valu <  050                 ? colrSR :
     _valu >= 050 and _valu < 100 ? colrLR :
     _valu >= 100 and _valu < 200 ? colrMR :
     _valu >= 200 and _valu < 300 ? colrHR : colrER

plot(output, 'Plot', i_plot ? colors(output) : #ffffff)

h0 = hline(0), h1 = hline(50), h2 = hline(100), h3 = hline(200), h4 = hline(300), h5 = hline(400)
fill(h5, h4, i_fill ? color.new(colrER, 90) : na)
fill(h4, h3, i_fill ? color.new(colrHR, 90) : na)
fill(h3, h2, i_fill ? color.new(colrMR, 90) : na)
fill(h2, h1, i_fill ? color.new(colrLR, 90) : na)
fill(h1, h0, i_fill ? color.new(colrSR, 90) : na)

barcolor(i_bars ? colors(output) : na)

if i_tabl
    coltxt = #ffffff, alignL = text.align_left, alignR = text.align_right, coltbl = #150042
    var table t = table.new(position.middle_right, 2, 5, coltbl, #7f7f7f, 2, #7f7f7f, 1)
    table.cell(t, 0, 0, 'MMRI:',                                  0, 0, coltxt,         alignR)
    table.cell(t, 1, 0, str.format('{0, number, 0.00}',  mmriGM), 0, 0, colors(mmriGM), alignL)
    table.cell(t, 0, 1, 'MMMRI:',                                 0, 0, coltxt,         alignR)
    table.cell(t, 1, 1, str.format('{0, number, 0.00}',  mmriNS), 0, 0, colors(mmriNS), alignL)
    table.cell(t, 0, 2, str.format('{0}:', i_fiat),               0, 0, coltxt,         alignR)
    table.cell(t, 1, 2, str.format('{0, number, 0.00}',  dollar), 0, 0, coltxt,         alignL)
    table.cell(t, 0, 3, str.format('{0}:', i_intr),               0, 0, coltxt,         alignR)
    table.cell(t, 1, 3, str.format('{0, number, 0.00}%', intrst), 0, 0, coltxt,         alignL)
    table.cell(t, 0, 4, 'Debt To GDP:',                           0, 0, coltxt,         alignR)
    table.cell(t, 1, 4, str.format('{0, number, 0.00}%', pcntNS), 0, 0, coltxt,         alignL)
````
