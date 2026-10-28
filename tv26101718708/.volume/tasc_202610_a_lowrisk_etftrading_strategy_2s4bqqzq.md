# TASC 2026.10 A Low-Risk ETF-Trading Strategy

- url: https://www.tradingview.com/script/2S4BqQzQ-TASC-2026-10-A-Low-Risk-ETF-Trading-Strategy/
- type: indicator
- pine_id: PUB;0c046a416ae540a58d3e8a394a718f76
- version: 1.0

## Description

[b]█ OVERVIEW[/b]

This script implements concepts from a short-term ETF investment strategy outlined by Markos Katsanos in the article "Selecting Strong ETFs While Avoiding Sharp Overbought Reversals" from the [url=https://traders.com/Documentation/FEEDbk_docs/2026/10/TradersTips.html]October 2026 edition of TASC Traders' Tips[/url]. The strategy analyzes Katsanos' custom relative strength indicator, [i]RSMK[/i], alongside momentum and correlation to identify entry and exit conditions across a diverse set of ETFs. This script is an indicator designed for scanning for the strategy's conditions in the [url=https://www.tradingview.com/pine-screener/]Pine Screener[/url]. 


[b]█ CONCEPTS[/b]

Risk-adjusted performance refers to a strategy's profitability relative to the risk required to achieve it. In his article, Katsanos explains that many trading strategies offer promising returns but poor risk-adjusted performance due to high volatility or drawdowns. In other words, the returns from such strategies may not justify the risk.

A common technique to help mitigate these market risks is to build a diversified trading portfolio across a broad range of different markets. However, Katsanos states that simply selecting a set of sectors or asset classes alone is not enough to achieve superior risk-adjusted returns. He proposes that a rules-based framework is required to identify high performers, avoid poor market timing, adapt to changing regimes, and systematically manage downside risk. 

Katsanos' strategy scans a diverse set of exchange-traded funds (ETFs) for strict entry and exit criteria based on relative strength, momentum, and correlation with a benchmark index. The objective is to achieve returns comparable to a buy-and-hold portfolio, while reducing downside risks for better risk-adjusted performance. The strategy operates on ETFs because they're well-suited for short-term investing. Their diversified holdings offer broad market exposure, and often high liquidity and relatively lower volatility. 

[b]Note:[/b]
[i]This methodology was designed for and tested on [b]non-leveraged[/b] ETFs only. The author recommends that traders avoid applying it to leveraged ETFs, because their structural characteristics (e.g., daily rebalancing and volatility) can adversely affect results and risk behaviors.[/i] 

At its core, the strategy uses a modified relative strength indicator named [i]RSMK[/i], which Katsanos originally introduced in the March 2020 issue of TASC Traders' Tips. His RSMK aims to address the shortcomings of traditional relative strength (RS) analysis. While traditional RS calculates the ratio between two instruments' prices, the RSMK calculates the smoothed change in the natural logarithm of the ratio and scales it as a percentage. The formula is as follows:

RS1 = ln(C / SEC2) – ln(C / SEC2)[RSBARS] 
RSMK = EMA(RS1, 4) * 100

Where:
[list]
[*]ln() refers to the natural logarithm.
[*]C is the closing price of the ETF.
[*]SEC2 is the price of a benchmark index, such as SPY.
[*]RSBARS is the lookback length.
[*]EMA() refers to an Exponential Moving Average.
[/list]


[b]█ WATCHLIST[/b]

Katsanos demonstrates his strategy on 80 ETFs selected based on class, sector, region, theme, liquidity, and available history. Most of the selected ETFs have at least 10 years of historical data, with a few exceptions. The author notes that he did not attempt to optimize this portfolio; he constructed it simply to form a broad universe of instruments for testing.

Because the strategy operates on multiple instruments rather than a single one, this script is implemented as an [i]indicator[/i] designed to scan the entry and exit criteria with the [i]Pine Screener[/i]. Select this indicator from the screener's menu and apply it to a selected watchlist. We've also prepared [url=https://www.tradingview.com/watchlists/341036576/]this watchlist[/url] for analyzing the same set of instruments referenced in the article. 


[b]█ THE RULES[/b]

[b]▌ Entry conditions[/b]

The author's strategy relies on the following sets of conditions to determine entry points. Users can customize these conditions, as well as the exit conditions, in the "Settings/Inputs" tab. An entry signal occurs only if all of the conditions are true: 

[list=1]
[*]RSMK strength
[list]
[*]The 35-day RSMK is above its 50-day moving average.
[*]The RSMK is greater than +3. 
[*]The RSMK is at a new four-day high.
[/list]
[*]Oversold pullback
[list]
[*]The 10-length RSI was below 35 at least once over the last 20 days.
[*]The RSI is rising over the last three days.
[/list]
[*]Overbought protection
[list]
[*]The RSMK is less than 25.
[/list]
[*]Short-term trend confirmation
[list]
[*]The 5-length EMA is above the 15-day SMA from five days ago. 
[/list]
[*]Market risk filter
[list]
[*]The six-day rate of change in the SPY price is greater than -6%, and the ETF has sufficient positive correlation with SPY, or
[*]The rate of change in SPY is less than -6%, and the ETF has sufficient negative correlation with SPY.
[/list]
[*]Volume confirmation
[list]
[*]The five-day SMA of volume is above the minimum threshold.
[/list]
[/list]

[b]▌ Exit conditions[/b]

The following criteria determine when to close a position. An exit signal occurs if any of these conditions are true:

[list=1]
[*]Relative strength deterioration
[list]
[*]The ETF has a strong correlation with SPY, and the RSMK crosses below -3. 
[/list]
[*]Time-based rebalancing
[list]
[*]The position has remained open for 30 days (six weeks).
[/list]
[*]Profit target
[list]
[*]The position reaches a profit of 25%. 
[/list]
[/list]


[b]█ USAGE[/b]

This script is intended for use with the Pine Screener and our ETF watchlist. When the script runs in the screener using the watchlist, the screener displays the symbol for each ETF in the first column and the values of the script's plots in subsequent columns. The top of the screener's table displays each plot's name:

[image]https://www.tradingview.com/x/qWFqwkt0/[/image]

When an entry signal occurs for any symbol, the "Entry" column on that symbol's row shows a value of 1. When an exit signal occurs, the "Exit" column shows a value of -1. If neither signal occurs, neither column displays a value. After an entry signal occurs, the "Entry price" and "Position performance" columns display the entry price and current percentage return until the exit signal occurs. 

When the script runs on a chart, it displays a green triangle on each entry bar and a dotted line indicating the position's entry price in the main chart pane. It also shows a green or red fill between the current price and the entry price while the position is active. When an exit condition occurs, the script displays a red "X" above the exit bar. In a separate pane, the script displays the RSMK indicator alongside its moving average: 

[image]https://www.tradingview.com/x/1B4D1lGG/[/image]


[b]█ INPUTS[/b]

The script's "Settings/Inputs" tab includes the following inputs for customizing the condition calculations:

[list]
[*][b]RSMK length:[/b] Lookback length for the RSMK.
[*][b]RSI length:[/b] The length value for the RSI.
[*][b]RS MA length:[/b] The length of the SMA of the RSMK.
[*][b]RS entry level:[/b] The minimum RSMK value required for entry.
[*][b]Minimum volume:[/b] The minimum volume moving average value required for entry.
[*][b]RSI oversold:[/b] The oversold level for the RSI entry condition. 
[*][b]MA bars:[/b] The length of the SMA whose value from five days ago must be below the current five-length EMA. 
[*][b]Minimum correlation:[/b] The minimum correlation with the benchmark index required for entry conditions.
[*][b]Rebalance period:[/b] The maximum number of bars over which a position remains open. 
[*][b]Benchmark symbol:[/b] The symbol of the instrument or index to use as the benchmark.
[/list]

The script's default settings correspond to those described in the article. By default, the script uses SPY as the benchmark index for its conditions. Users can change the benchmark while running the script on a chart. However, at the time of publishing, users [i]cannot[/i] adjust the benchmark in the Pine Screener. When running in the screener, the script consistently uses SPY.

## Source Code

````pine
//  TASC Issue: October 2026
//     Article: Selecting Strong ETFs While Avoiding
//               Sharp Overbought Reversals
//              A Low-Risk ETF Trading Strategy
//  Article By: Markos Katsanos
//    Language: TradingView's Pine Script™ v6
// Provided By: PineCoders, for tradingview.com

// Use this watchlist with the Pine Screener to 
// show signals across the universe of ETFs for
// this strategy.
// Watchlist:
// https://www.tradingview.com/watchlists/341036576/
// Pine Screener:
// https://www.tradingview.com/pine-screener/

//@version=6
TITLE = "TASC 2026.10 A Low-Risk ETF-Trading Strategy"
SHORTTITLE = "LRETF-Strat"
indicator(TITLE, SHORTTITLE)

//#region Functions

// 2023.12
// @function Custom Relative Strength Indicator (RSMK)
// @param base     Input time series
// @param im       Reference time series
// @param bars     N bars for RS calculation
// @param sk       Smoothing constant
// @returns        Relative Strength
RS (float _base, float _im, int _bars, int _sk) =>
    float r12 = _base/_im
    float rs1 = (math.log(r12) 
         - math.log(nz(r12[_bars], 0.0)))
    ta.ema(rs1, _sk)*100.0

//#endregion
//#region Inputs

//Calculation Parameters
G1 = "RS Parameters"
int rsBars = input.int(35, "RSMK length", group = G1)  
int rsiBars = input.int(10, "RSI length", group = G1)

//Entry Parameters
G2 = "Entry/Exit Parameters"
int mar = input.int(50, "RS MA length", group = G2)
float rsCrit = input.float(3.0, "RS entry level", group = G2)
int maB = 4 //input.int(4, "Smoothing Constant", 1, 50)
int minVol = input.int(100000, "Minimum volume", 
     minval = 0, maxval = 1000000, group = G2)

float rsiOS = input.float(35.0, "RSI oversold", group = G2)
int maBars = input.int(15, "MA bars", group = G2)
float corMin = input.float(0.6, "Minimum correlation", group = G2)

int timeExit = input.int(30, "Rebalance period", group = G2) 

string bSym = input.symbol("AMEX:SPY", "Benchmark symbol")

//#endregion
//#region Calculations

float bench = 
     request.security(bSym, timeframe.period, close)

float cor = ta.correlation(close, bench, 100)
float rsmk = RS(close, bench, rsBars, maB)
float mars = ta.sma(rsmk, mar)
float hhRsmk = ta.highest(rsmk, 4)
float rocInd = (ta.change(bench, 6)/bench[6])*100
float rsi = ta.rsi(close, rsiBars)
float llRsi = ta.lowest(rsi, 20)
float ema5 = ta.ema(close, 5) 
float sma5 = ta.sma(close, maBars)

//#endregion
//#region Conditions

bool gotVol = ta.sma(volume, 5) > minVol
bool rsmkSignal = (rsmk > mars and rsmk > rsCrit and 
     rsmk == hhRsmk and rsmk < 25)

bool rocSignal = ((rocInd > -6 and cor > corMin) or 
     (rocInd < -6 and cor < -corMin))

bool rsiSignal = llRsi < rsiOS and rsi > rsi[3]
bool momSignal = ema5 > sma5[5]

var int pos = 0
var float ep = close
var int eb = bar_index

bool isBuy = (gotVol and rsmkSignal and 
     rocSignal and rsiSignal and 
     momSignal and pos == 0)

bool isSell = rsmk < -rsCrit and cor > 0.8 and pos == 1
bool perExit = pos == 1 and close >= ep*1.25
bool reBal = pos == 1 and bar_index - eb >= timeExit

exit = isSell or perExit or reBal

pos := isBuy?1:(exit?0:pos)
ep := isBuy?close:ep
eb := isBuy?bar_index:eb

posProf = pos == 1 ? (close - ep)/ep*100 : na

//#endregion
//#region Plots

e = plot(pos == 1 or  pos[1] == 1?ep:na, "Entry Price",
     color.yellow, style = plot.style_linebr, 
     force_overlay = true, 
     linestyle = plot.linestyle_dotted)

c = plot(close, "Close plot for fill", 
     display = display.none, force_overlay = true, 
     editable = false)


posCol = (close[1] > ep ? 
     color.new(color.teal,80) : 
     color.new(color.red,80)) 

plot(posProf, "Position Performance", posCol, 
     display = display.all - display.pane, 
     format = format.percent)

fill(c,e, posCol, "Position Colors")

plot(rsmk, "RSMK", color = rsmk>0?color.lime:color.red)

plot(mars, "RS MA", color.blue, 
     linestyle = plot.linestyle_dashed)

hline(0, linestyle = hline.style_solid)

plotshape(isBuy?1:na, "Enter", shape.triangleup, 
     location.belowbar, color.green, 
     size = size.small, force_overlay = true)

plotshape(exit?-1:na, "Exit", shape.xcross, 
     location.abovebar, color.red, 
     size = size.small, force_overlay = true)

//#endregion
//#region Alerts

alertcondition(isBuy, "Enter Alert")
alertcondition(exit, "Exit Alert")

//#endregion
````
