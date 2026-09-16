<!-- tradingview-pine-id: PUB;401e7b6dc92b46d887aaf42e09dde72f -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Outperformance Alpha

Source: https://www.tradingview.com/script/IrNuWGlY-Outperformance-Alpha/

## Description

Outperformance Alpha 

Relative Strength Engine – Alpha vs Benchmark

              This indicator calculates the rolling outperformance (alpha) of any symbol against a chosen benchmark and displays it in a separate pane. It offers both a simple excess-return mode and a full risk-adjusted (Jensen-style) alpha that incorporates rolling beta and a risk-free rate.

Default benchmark is set to CNX500. 

You can change it to any index or stock.

What the Indicator Shows
      •	Continuous alpha line with color-coded fill (positive = teal, negative = red)

      •	Automatic detection of short-term alpha peaks (selectable 9 / 21 / 50 bars)

      •	52-week alpha highs

      •	Special “Alpha Leads Price” signal (cyan diamonds) – appears when alpha makes a 
                new 52-week high while the stock price itself has not yet broken its own 52-week  
                high

      •	Optional soft background coloring based on alpha direction

      •	Real-time statistics table (Alpha, Stock Return, Benchmark Return, Beta, Risk-Free 
                Rate)

Calculation Modes:

	1.Simple Excess Return
		Stock return over the chosen period minus benchmark return.

	2.Risk-Adjusted
               Classic Jensen’s Alpha using rolling beta and a user-defined annual risk-free   
               rate(periodized automatically).

Key Inputs:
	1.Benchmark symbol (default: CNX500)

	2.Performance lookback period

	3.Alpha calculation mode

	4.Risk-free rate (annual %)

	5.Beta calculation window

	6.Short-term peak length

	7.Toggle for the early “Alpha Leads Price” diamonds

	8.Full color and display controls

Alerts Included:

       •	Alpha crosses above zero  
       •	Alpha crosses below zero   
       •	New 52-week alpha high  
       •	Alpha Leads Price signal

Recommended Usage:
	Works best on the daily timeframe. All length inputs are measured in bars. 
Use it as a relative-strength filter to identify stocks that are genuinely outperforming (or underperforming) their benchmark, especially when the cyan “Alpha Leads Price” diamonds appear.

Disclaimer:
	This tool is for educational and informational purposes only. It does not provide investment advice. 	Past relative performance is not a guarantee of future results. Always do your own research and risk management.

---

## Source Code

````pine
//@version=6
indicator("Outperformance Alpha", shorttitle="Outperf α", overlay=false, max_labels_count=500, max_lines_count=500)

// ═══════════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════════
grpRef     = "References"
benchSym   = input.symbol("NSE:CNX500", "Base Index (Benchmark)", group=grpRef)

grpCalc    = "Calculation Factors"
perfLen    = input.int(21, "Performance Period (Days)", minval=5, maxval=252, group=grpCalc)
alphaMode  = input.string("Risk-Adjusted", "Alpha Mode", options=["Risk-Adjusted", "Simple Excess Return"], group=grpCalc)
rfAnnual   = input.float(6.5, "Risk-Free Rate (annual %)", minval=0.0, step=0.1, group=grpCalc)
betaLen    = input.int(252, "Beta Lookback (Days)", minval=30, maxval=756, group=grpCalc)

grpHigh    = "Highlight"
shortPeak  = input.string("21", "Short Term Peak Performance (Days)", options=["9", "21", "50"], group=grpHigh)
showLead   = input.bool(true, "Alpha Breakout Before Price (cyan diamonds)", group=grpHigh)

grpStyle   = "Style"
lineColPos = input.color(color.new(#18e029, 0), "Positive Alpha Color", group=grpStyle)
lineColNeg = input.color(color.new(color.red, 0), "Negative Alpha Color", group=grpStyle)
showBg     = input.bool(true, "Show Background Tint", group=grpStyle)
showTable  = input.bool(true, "Show Stats Table", group=grpStyle)

// ═══════════════════════════════════════════════════════════════
// HELPER FUNCTIONS
// ═══════════════════════════════════════════════════════════════
f_pct(src, len) =>
    src[len] != 0 ? (src / src[len] - 1.0) * 100.0 : na

// Manual covariance (Pine Script has no ta.covariance)
f_covariance(x, y, len) =>
    ta.correlation(x, y, len) * ta.stdev(x, len) * ta.stdev(y, len)

f_beta(stockRet, benchRet, len) =>
    cov   = f_covariance(stockRet, benchRet, len)
    var_b = ta.variance(benchRet, len)
    var_b != 0 ? cov / var_b : na

// ═══════════════════════════════════════════════════════════════
// DATA
// ═══════════════════════════════════════════════════════════════
benchClose = request.security(benchSym, timeframe.period, close, barmerge.gaps_off, barmerge.lookahead_off)

// Daily simple returns (for beta)
stockRet1 = close[1] != 0 ? (close / close[1] - 1.0) : na
benchRet1 = benchClose[1] != 0 ? (benchClose / benchClose[1] - 1.0) : na

// Period returns (%)
stockRetPct = f_pct(close, perfLen)
benchRetPct = f_pct(benchClose, perfLen)

// Periodized risk-free rate
rfPeriod = rfAnnual / 100.0 * (perfLen / 252.0) * 100.0

// Rolling beta
beta = f_beta(stockRet1, benchRet1, betaLen)

// ═══════════════════════════════════════════════════════════════
// ALPHA CALCULATION
// ═══════════════════════════════════════════════════════════════
var float alpha = na

if alphaMode == "Simple Excess Return"
    alpha := stockRetPct - benchRetPct
else
    // Jensen's Alpha
    expected = rfPeriod + nz(beta) * (benchRetPct - rfPeriod)
    alpha := stockRetPct - expected

// ═══════════════════════════════════════════════════════════════
// PEAK DETECTION (ta.highest called unconditionally)
// ═══════════════════════════════════════════════════════════════
shortLen = shortPeak == "9" ? 9 : shortPeak == "21" ? 21 : 50

alphaShortHigh = ta.highest(alpha, shortLen)
alpha52High    = ta.highest(alpha, 252)
price52High    = ta.highest(high, 252)

isShortPeak     = not na(alpha) and alpha == alphaShortHigh
is52wHigh       = not na(alpha) and alpha == alpha52High
isPriceAt52High = high >= price52High

alphaLeads = is52wHigh and not isPriceAt52High

// ═══════════════════════════════════════════════════════════════
// PLOTTING
// ═══════════════════════════════════════════════════════════════
alphaColor = alpha >= 0 ? lineColPos : lineColNeg

plot(alpha, "Alpha", color=alphaColor, linewidth=2)
hline(0, "Zero", color=color.gray, linestyle=hline.style_dashed)

//fill(plot(alpha), plot(0), color = alpha >= 0 ? color.new(lineColPos, 75) : color.new(lineColNeg, 75), title="Alpha Fill")

//bgcolor(showBg ? (alpha >= 0 ? color.new(color.teal, 92) : color.new(color.red, 92)) : na)

// Markers (correctly placed on the alpha line)
plotshape(isShortPeak and not is52wHigh ? alpha : na, 
     title="Short-term Peak", 
     style=shape.circle, 
     location=location.absolute, 
     color=color.new(#dd9b1f, 0), 
     size=size.tiny)

plotshape(is52wHigh ? alpha : na, 
     title="52-week Alpha High", 
     style=shape.circle, 
     location=location.absolute, 
     color=color.new(color.yellow, 0), 
     size=size.tiny)

plotshape(showLead and alphaLeads ? alpha : na, 
     title="Alpha Leads Price", 
     style=shape.diamond, 
     location=location.absolute, 
     color=color.new(color.aqua, 0), 
     size=size.tiny)

// ═══════════════════════════════════════════════════════════════
// STATS TABLE
// ═══════════════════════════════════════════════════════════════
var table stats = table.new(position.top_right, 2, 7, border_width=1)

if showTable and barstate.islast
    table.cell(stats, 0, 0, "Metric",               text_color=color.white, bgcolor=color.gray)
    table.cell(stats, 1, 0, "Value",                text_color=color.white, bgcolor=color.gray)
    
    table.cell(stats, 0, 1, "Alpha (α)",            text_color=color.white)
    table.cell(stats, 1, 1, str.tostring(alpha, "#.##") + " %", text_color = alpha >= 0 ? color.teal : color.red)
    
    table.cell(stats, 0, 2, "Stock Return",         text_color=color.white)
    table.cell(stats, 1, 2, str.tostring(stockRetPct, "#.##") + " %")
    
    table.cell(stats, 0, 3, "Index Return",         text_color=color.white)
    table.cell(stats, 1, 3, str.tostring(benchRetPct, "#.##") + " %")
    
    table.cell(stats, 0, 4, "Beta (β)",             text_color=color.white)
    table.cell(stats, 1, 4, str.tostring(beta, "#.###"))
    
    table.cell(stats, 0, 5, "Risk-Free (period)",   text_color=color.white)
    table.cell(stats, 1, 5, str.tostring(rfPeriod, "#.##") + " %")
    
    table.cell(stats, 0, 6, "Chart TF",             text_color=color.white)
    table.cell(stats, 1, 6, timeframe.period + (not timeframe.isdaily ? " ⚠️" : ""), 
         text_color = timeframe.isdaily ? color.green : color.orange)

// ═══════════════════════════════════════════════════════════════
// ALERTS
// ═══════════════════════════════════════════════════════════════
alertcondition(ta.crossover(alpha, 0),  "Alpha crossed above zero",  "Outperformance Alpha crossed above zero")
alertcondition(ta.crossunder(alpha, 0), "Alpha crossed below zero",  "Outperformance Alpha crossed below zero")
alertcondition(is52wHigh,               "Fresh 52-week alpha high",  "Alpha printed a new 52-week high")
alertcondition(alphaLeads,              "Alpha leads price",         "Alpha leads price – relative strength breakout")
````
