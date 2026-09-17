<!-- tradingview-pine-id: PUB;5eae4188ded54b0c8392141ee3cab163 -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# TradeManagement

Source: https://www.tradingview.com/script/EMHm5fgY-TradeManagement/

## Description

TradeManagement is a Pine Script® library designed to simplify common trade-management and position-sizing calculations in TradingView strategies.

The library provides reusable functions for calculating:
Take-profit prices
Stop-loss prices
Risk/reward-based take-profit prices
Position size based on monetary risk
Position size based on risk per unit/contract
Current strategy entry price

Features
[pine]tpPrice()[/pine]
Calculates a take-profit price using a percentage.
You can specify whether the trade is long or short.

[pine]slPrice()[/pine]
Calculates a stop-loss price using a percentage.
You can specify whether the trade is long or short.

[pine]tpRiskReward()[/pine]
Calculates a take-profit price based on the distance between the entry price and stop-loss price, using a selected risk/reward multiplier.
For example, you can use a 2 multiplier for a 1:2 risk/reward target.

[pine]positionSize()[/pine]
Calculates the position quantity based on:
Entry price
Stop-loss price
Maximum monetary risk
The calculation uses TradingView's symbol-specific syminfo.pointvalue.

[pine]positionSizeByRiskQuantity()[/pine]
Calculates the position quantity based on:
Entry price
Stop-loss price
Risk amount per unit/contract
Use this when you want to specify risk per contract (e.g., "Risk 0.01 per contract") rather than total monetary risk.

[pine]entryPrice()[/pine]
Returns the current strategy's average entry price when a position is open.
This allows you to keep your strategy code clean while using the same trade-management functions across multiple strategies.

Important Note About Position Risk
The positionSize() function calculates the position quantity based on the specified monetary risk. However, the final risk may not always exactly match the risk amount entered.
This is because some markets or trading environments only allow specific quantity increments, such as whole-number quantities:
1, 2, 3, ...
For example, you may enter $5 as your maximum intended risk, but the calculated position size could result in an actual risk of $3.79.
This happens because the required position size might be something like 1.3, but the market or broker may only allow a quantity such as 1 or 2.
Therefore, the risk input should be considered the maximum intended risk, while the actual risk depends on the quantity precision or increment supported by the specific symbol and trading environment.

Strategy Compatibility
This library is intended primarily for use with TradingView strategies.
The position-sizing and entry-price functions rely on TradingView strategy information and symbol-specific properties.

Risk Disclaimer
This library provides calculation tools and does not guarantee a specific trading result or risk outcome.
Always verify the calculated position size, stop-loss distance, quantity rules, and actual monetary risk for the specific market, broker, or exchange before using the calculations in live trading.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ChartTrader-X

//@version=6
library("TradeManagement", overlay = false)

//@function Calculates take-profit price using a percentage.
//@param entryPrice Entry price.
//@param percent Take-profit percentage.
//@param isLong true for long, false for short.
//@returns Take-profit price.
export tpPrice(float entryPrice, float percent, bool isLong) =>
    isLong ? entryPrice * (1 + percent / 100) : entryPrice * (1 - percent / 100)


//@function Calculates stop-loss price using a percentage.
//@param entryPrice Entry price.
//@param percent Stop-loss percentage.
//@param isLong true for long, false for short.
//@returns Stop-loss price.
export slPrice(float entryPrice, float percent, bool isLong) =>
    isLong ? entryPrice * (1 - percent / 100) : entryPrice * (1 + percent / 100)


//@function Calculates take-profit price from risk/reward.
//@param entryPrice Entry price.
//@param slPrice Stop-loss price.
//@param riskReward Risk/reward multiplier.
//@param isLong true for long, false for short.
//@returns Take-profit price.
export tpRiskReward(float entryPrice, float slPrice, float riskReward, bool isLong) =>
    risk = isLong ? entryPrice - slPrice : slPrice - entryPrice
    isLong ? entryPrice + risk * riskReward : entryPrice - risk * riskReward


//@function Calculates position size based on monetary risk.
//@param entryPrice Entry price.
//@param slPrice Stop-loss price.
//@param riskMoney Maximum money to risk.
//@returns Position quantity.
export positionSize(float entryPrice, float slPrice, float riskMoney) =>
    riskMoneySymbol = strategy.convert_to_symbol(riskMoney)
    riskPerUnit = math.abs(entryPrice - slPrice) * syminfo.pointvalue
    rawQty = riskPerUnit > 0 ? riskMoneySymbol / riskPerUnit : 0
    rawQty


//@function Returns the current strategy entry price.
//@returns Average entry price or na.
export entryPrice() =>
    strategy.position_size != 0 ? strategy.position_avg_price : na
````
