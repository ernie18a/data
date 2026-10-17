# TASC 2026.08 An Ag Selling Model

- url: https://www.tradingview.com/script/VFzCk3HX-TASC-2026-08-An-Ag-Selling-Model/
- type: strategy
- pine_id: PUB;270bed499bf1478bb90dfcc10de129d3
- version: 1.0

## Description

[b]█ OVERVIEW[/b]

This strategy implements the "Ag Selling Model" as presented by Perry J. Kaufman in the [url=https://traders.com/Documentation/FEEDbk_docs/2026/08/TradersTips.html]August 2026 edition of the TASC Traders' Tips[/url] "Identifying The Best Price Levels For Selling Commodity Futures". The article describes a long-hold selling strategy for agricultural commodity futures based around the seasonal harvest timing of crops, mainly US grains traded on the CBOT and KCBOT, both which have been acquired by CME.

[b]█ CONCEPTS[/b]

This model was originally presented in 1978 by the author to a group of commodity producers as an attempt to identify the best price levels to sell their products.

The core idea is that if there is only one crop per year, crop prices will be lowest around harvest and highest around peak growing season. Based on this timing, the strategy spaces out its sell orders up to three times throughout the year, and covers its position at harvest.

The goal of this strategy is simply to beat the average price. Since selling at harvest should typically provide a lower-than-average price exit, success for this strategy means having the average of its entries above the average price.

The level to sell at can be determined by finding a moving average that reflects seasonal changes. Once found, we measure volatility using Average True Range (ATR).
With these two figures, the volatility is added to the average based on a multiplication factor.
This creates a reasonable extreme at which to position short entries.

[image]https://www.tradingview.com/x/FjCBMNxq/[/image]

[b]█ THE RULES[/b]

[list=1]
[*]Sell short at the selling level. 
[*]Delay these sells to ensure two sells are not in the same rally.
[*]Avoid selling immediately after harvest, as a long period of low prices typically follows.
[*]Exit positions (cover shorts) at harvest.
[/list]
[b]▌Properties[/b]

[b]IMPORTANT NOTE:[/b] The strategy parameters have been adjusted specifically for Corn Futures (ZC1!). This ticker operates in Cents (USX) rather than Dollars (USD); all the strategy values have been translated to account for this. To apply this strategy to other markets it is important to properly adjust the strategy parameters to simulate realistic conditions.

[list]
[*][b]Initial Capital[/b]: 15,000,000¢ == $150,000; see note above.
[*][b]Position Sizing[/b]: This strategy sells in one-contract increments up to three times per year.
[*][b]Commissions[/b]: Commission value is set to 300¢ ($3) per order, which is a generous estimate.
[*][b]Slippage[/b]: Slippage is set to one tick to simulate reasonable execution conditions.
[/list]

[b]█ INPUTS[/b]

[list]
[*][b]Source[/b]: Source for calculations.
[*][b]MA length[/b]: Moving Average length (Simple Moving Average). A 20 to 60 day range is recommended; with 40 as a starting point.
[*][b]ATR length[/b]: Average True Range length.
[*][b]ATR factor[/b]: Factor by which to multiply ATR when calculating selling level. 2.5 to 3.5 is generally recommended but higher has been seen for more volatile grains.
[*][b]Month of Harvest[/b]: Set the month of harvest for the crop being traded, which changes depending on the seasonality of the commodity.
[*][b]Delay in months after harvest[/b]: Set this to the typical downtime after harvest where prices are typically lowest. This can vary per instrument but 2 months is the suggested point for tuning.
[*][b]Days between trades[/b]: Days to wait between sales.
[/list]

## Source Code

````pine
//  TASC Issue: August 2026
//     Article: Identifying The Best Price Levels For 
//               Selling Commodity Futures
//              An Ag Selling Model
//  Article By: Perry J Kaufman
//    Language: TradingView's Pine Script® v6
// Provided By: PineCoders, for tradingview.com


//@version=6
string TITLE      = "TASC 2026.08 An Ag Selling Model"
string SHORTTITLE = "ASM"

strategy(
    TITLE, SHORTTITLE, true, 
    initial_capital = 15000000,
    pyramiding = 3,
    slippage = 1,
    commission_type = strategy.commission.cash_per_contract,
    commission_value = 300
)


//#region --- Inputs ---

string G1 = "Average & sell level settings"
float src      = input.source(close, "Source", group = G1)
int   len      = input.int(40, "MA length", group = G1)
int   atrLen   = input.int(20, "ATR length", group = G1)
float atrMulti = input.float(2.5, "ATR factor", group = G1)

string G2 = "Strategy settings"
int startCropYear = input.int(
    11, "Month of harvest", 1, 12, group = G2
)
int delayMonths = input.int(
    2, "Delay in months after harvest", 0, 11, group = G2
)
int dBetween = input.int(
    30, "Days between trades", 1, group = G2
)
//#endregion


//#region --- Strategy logic ---

// State-tracking variables
var bool active = false
var int  dSince = 0
// Count the days since the last sale.
if strategy.opentrades > 0
    dSince += 1

// Calculate the average and sell levels.
float trend     = ta.sma(src, len)
float atr       = ta.atr(atrLen)
float sellLevel = trend + atr * atrMulti

// @variable `true` on harvest month, `false` otherwise.
bool isHarvestMonth = month == startCropYear
// @variable `true` on the first bar in the crop year.
bool newCropYr = isHarvestMonth and not isHarvestMonth[1]
// @variable The month where sales begin.
int beginSaleMonth = (startCropYear + delayMonths + 1) % 12
if beginSaleMonth == 0
    beginSaleMonth := 12

// Reset state-tracking variables when new harvest begins.
if newCropYr
    active := false
    dSince := 0

// Allow trades starting on the target month.
if month == beginSaleMonth and month[1] != beginSaleMonth
    active := true

// Place entry orders in the active period, up to the 
// specified limit, on bars whose `high` value is above 
// the sell level.
if active and high >= sellLevel
    if strategy.opentrades == 0
        strategy.entry("First sale", strategy.short)
        dSince := 0
    else if dSince >= dBetween
        strategy.entry("Sell", strategy.short)
        dSince := 0

// Close all open trades at harvest.
if not active
    strategy.close_all("Cover")
//#endregion


//#region --- Visuals ---

// Background highlights
bgcolor(
    newCropYr ? color.rgb(255, 255, 255, 50) : na, 
    title = "New crop year"
)
bgcolor(
    isHarvestMonth ? #ffeb3b1a : na, 
    title = "Harvest month"
)
bgcolor(
    active and not isHarvestMonth ? na : #ff52521a, 
    title = "No trades allowed"
)
// Average and sell levels
plot(trend, "Average", color.orange)
plot(sellLevel, "Sell level", color.blue)
//#endregion
````
