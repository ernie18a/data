# Pivot Point 15/60 prd

- url: https://www.tradingview.com/script/OdCG4q5Y-Pivot-Point-15-60-prd/
- type: indicator
- pine_id: PUB;b4fb3b17efd9472e88a49a7bd2a75582
- version: 1.0

## Description

Hourly Pivot Point Crossover by 15-Minute Pivot Point is a multi-timeframe approach in technical analysis that combines pivot levels calculated on the hourly (H1) chart with those on the 15-minute (M15) chart. It helps intraday traders identify high-probability entries, confirm trend direction or reversals, and manage trades more effectively.
What Are Pivot Points?
Pivot points are calculated from the prior period's high, low, and close prices to generate a central Pivot (PP) and multiple support (S1, S2, S3) and resistance (R1, R2, R3) levels. The standard (floor) formula is:

PP = (High + Low + Close) / 3
R1 = (2 × PP) – Low
S1 = (2 × PP) – High
Higher/lower levels follow similar expansions.

These levels act as dynamic support/resistance. For hourly pivots, calculations use the previous hour's data (they update hourly). For 15-minute pivots, they update every 15 minutes, making them more responsive to short-term price action.
Understanding the "Crossover"
A "crossover" in this context typically refers to situations where:

Price or the 15-minute pivot levels (PP, R1/S1 etc.) interact with or break through the hourly pivot levels.
The shorter-term (M15) structure shifts relative to the higher-timeframe (H1) pivots, e.g., M15 PP crossing above/below H1 PP, or price on the 15-min chart breaking a key H1 level with confirmation from M15 pivots.
Alignment or divergence between the two timeframes (e.g., price holding above H1 PP while M15 shows bullish crossover of its own levels).

This is part of multi-timeframe analysis, where the hourly chart provides the broader intraday bias (trend/context), and the 15-minute chart offers precise entry timing and short-term signals.
How It Can Be Helpful in Trading

Trend Bias and Direction:
If price is above the hourly PP, it suggests a bullish bias on the H1 timeframe. Look for long opportunities on the 15-min chart when M15 pivots align or crossover positively (e.g., price reclaims M15 PP and pushes toward H1 R1).
Below hourly PP → bearish bias; favor shorts on M15 breakdowns.

Entry and Confirmation:
Bounce/Reclaim Setup: Price pulls back to an hourly support (e.g., H1 S1 or PP) and shows a bullish reversal on the 15-min chart (M15 PP crossover or price reclaiming M15 levels with volume/candlestick confirmation). This provides confluence for entries.
Breakout Setup: A decisive break of an hourly level (e.g., above H1 R1) confirmed by 15-min momentum or M15 pivot crossover reduces false breakouts. The faster 15-min pivots help time the entry precisely.

Support/Resistance Confluence:
When H1 and M15 levels cluster (e.g., H1 PP near M15 R1), it creates a stronger zone. Price reactions at these zones are often sharper.

Risk Management:
Stops can be placed just beyond the opposing pivot (e.g., below a support level).
Targets often use the next pivot levels on either timeframe (e.g., aim for H1 R1/R2 from an M15 entry).
Helps avoid trading against the higher-timeframe structure ("Never stand against the pivot" is a common rule).

Filtering Noise and Improving Probability:
The 15-min chart alone can be noisy; overlaying hourly pivots adds context and filters low-quality signals.
Common in forex, indices, and futures day trading/scalping on 5-15 min charts.


Practical Tips for Implementation

Chart Setup: Display both hourly and 15-min pivots on your 15-min trading chart (most platforms allow multi-timeframe pivots or indicators).
Combine with Other Tools: Use with candlestick patterns, volume, RSI/MACD for divergence, or moving averages for extra confirmation.
Best Sessions: Works well during active market hours (e.g., London/New York overlap) when liquidity supports pivot reactions.
Timeframe Alignment: Hourly provides the "bigger picture" for the session; 15-min for execution. Some traders also reference daily pivots for even higher context.
Limitations: Pivots are lagging in calculation but leading in projected levels. They work best in ranging or moderately trending markets; strong trends may ignore inner levels. Backtest and combine with price action.

## Source Code

````pine
//@version=6
indicator('Pivot Point 15/60 pd', overlay = true)
//akghuf19ag24@gmail.com
// Inputs for ema #1
len1 = input.int(20, minval = 5, step = 5, title = 'ema Fast')
//src1 = input(close, title = 'ema Source #1')
src = ohlc4
// ema Calculation #1
out1 = ta.ema(src, len1)

// Trend detection (slope of the ema itself)
trendColor1 = out1 > out1[1] ? color.rgb(148, 135, 20) : out1 < out1[1] ? color.rgb(114, 27, 113) :na 

// Plot ema #1
plot1 = plot(out1, title = 'ema #1', color = trendColor1, linewidth = 1)

// Inputs for ema #2
len2 = input.int(90, minval = 4, step = 4, title = 'ema Slow')
//src2 = input(close, title = 'ema Source #2')

// ema Calculation #2
out2 = ta.ema(src, len2)

// Trend detection (slope of the ema itself)
trendColor2 = out2 > out2[2] ? color.rgb(148, 135, 20) : out2 < out2[2] ? #9d0cb7cc :na 

// Plot ema #2
plot2 = plot(out2, title = 'ema #2', color = trendColor2, linewidth = 1)

// Cloud between ema #1 and ema #2
bullColor = #5fff3b40       // light aqua cloud
bearColor = color.rgb(96, 10, 57)        // light violet cloud
fill(plot1, plot2, color = out1 > out2 ? bullColor : bearColor, title = "Trend Cloud")


//p p p p p p p p p p p p p p p p

// Select timeframe for pivot calculation
tf = input.timeframe('5', 'Pivot Timeframe')
// User-selected color
ppColor = input.color(color.rgb(94, 236, 115), 'Pivot Color')

// Get previous period OHLC
[ph, pl, pc] = request.security(syminfo.tickerid, tf, [high[1], low[1], close[1]])

// Pivot Point formula
pp = (ph + pl + pc) / 3

// Plot Pivot Point
//plot(pp, title = 'PP 5', color=ppColor,linewidth = 2)

//####################22222222222

// Select timeframe for pivot calculation
tf1 = input.timeframe('15', 'Pivot Timeframe')
// User-selected color
ppColor1 = input.color(color.lime, 'Pivot Color')

// Get previous period OHLC
[ph1, p2, pc1] = request.security(syminfo.tickerid, tf1, [high[1], low[1], close[1]])

// Pivot Point formula
pp1 = (ph1 + p2 + pc1) / 3

// Plot Pivot Point
plot(pp1, title = 'PP 15', color=ppColor1,linewidth = 2)

//################3333333333333

tf2 = input.timeframe('15', 'Pivot Timeframe')
// User-selected color
ppColor2 = input.color(color.blue, 'Pivot Color')

// Get previous period OHLC
[ph2, p3, pc2] = request.security(syminfo.tickerid, tf2, [high[1], low[1], close[1]])

// Pivot Point formula
pp2 = (ph2 + p3 + pc2) / 3

// Plot Pivot Point
//plot(pp2, title = 'PP 15', color=ppColor2,linewidth = 1)

//#######################444444444444444

// Select timeframe for pivot calculation
tf3 = input.timeframe('20', 'Pivot Timeframe')
// User-selected color
ppColor3 = input.color(color.rgb(255, 235, 59, 46))

// Get previous period OHLC
[ph3, p4, pc3] = request.security(syminfo.tickerid, tf3, [high[1], low[1], close[1]])

// Pivot Point formula
pp3 = (ph3 + p4 + pc3) / 3

// Plot Pivot Point
//plot(pp3, title = 'PP 20',color=ppColor3, linewidth = 1)

//#############################555555555555555

// Select timeframe for pivot calculation
tf4 = input.timeframe('30', 'Pivot Timeframe')
// User-selected color
ppColor4 = input.color(color.orange)

// Get previous period OHLC
[ph4, p5, pc4] = request.security(syminfo.tickerid, tf4, [high[1], low[1], close[1]])

// Pivot Point formula
pp4 = (ph4 + p5 + pc4) / 3

// Plot Pivot Point
//plot(pp4, title = 'PP 30',color=ppColor4, linewidth = 2)

//#############################6666666666666666

// Select timeframe for pivot calculation
tf5 = input.timeframe('40', 'Pivot Timeframe')
// User-selected color
ppColor5 = input.color(color.orange)

// Get previous period OHLC
[ph5, p6, pc5] = request.security(syminfo.tickerid, tf5, [high[1], low[1], close[1]])

// Pivot Point formula
pp5 = (ph5 + p5 + pc5) / 3

// Plot Pivot Point
//plot(pp5, title = 'PP 40',color=ppColor5, linewidth = 1)

//#############################77777777777777777

// Select timeframe for pivot calculation
tf6 = input.timeframe('50', 'Pivot Timeframe')
// User-selected color
ppColor6 = input.color(color.orange)

// Get previous period OHLC
[ph6, p7, pc6] = request.security(syminfo.tickerid, tf6, [high[1], low[1], close[1]])

// Pivot Point formula
pp6 = (ph6 + p7 + pc6) / 3

// Plot Pivot Point
//plot(pp6, title = 'PP 50',color=ppColor6, linewidth = 1)

//#############################888888888888

// Select timeframe for pivot calculation
tf7 = input.timeframe('60', 'Pivot Timeframe')
// User-selected color
ppColor7 = input.color(color.red)

// Get previous period OHLC
[ph7, p8, pc7] = request.security(syminfo.tickerid, tf4, [high[1], low[1], close[1]])

// Pivot Point formula
pp7 = (ph7 + p8 + pc7) / 3

// Plot Pivot Point
plot(pp7, title = 'PP 60',color=ppColor7, linewidth = 3)


//#############################999999999999999

// Select timeframe for pivot calculation
tf8 = input.timeframe('25', 'Pivot Timeframe')
// User-selected color
ppColor8 = input.color(color.orange)

// Get previous period OHLC
[ph8, p9, pc8] = request.security(syminfo.tickerid, tf4, [high[1], low[1], close[1]])

// Pivot Point formula
pp8 = (ph8 + p9 + pc8) / 3

// Plot Pivot Point
//plot(pp8, title = 'PP 35',color=ppColor8, linewidth = 1)
````
