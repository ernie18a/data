<!-- tradingview-pine-id: PUB;f045f2e5321b4715862cf1406a8e1f01 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# MNQ 1M INVERSE CHoCH - SESSION TOGGLE

Source: https://www.tradingview.com/script/ETihVT5z-Amit/

## Description

## Strategy Overview

This strategy is a price-action-based intraday trading system designed to identify high-probability entries using **market structure, CHoCH (Change of Character), BOS (Break of Structure), liquidity sweeps, and multi-timeframe confirmation**.

The strategy focuses on letting the market establish its direction first rather than entering immediately on a breakout. Once structure confirms the move, the lower timeframe is used to identify a more precise entry.

### How It Works

The strategy primarily follows this sequence:

**1. Higher-Timeframe Structure**

* Identifies a Change of Character (CHoCH) to establish a potential directional bias.
* Looks for confirmation through a Break of Structure (BOS).

**2. Lower-Timeframe Confirmation**

* After higher-timeframe confirmation, the strategy moves to the lower timeframe.
* A corresponding CHoCH is identified in the same direction.

**3. Liquidity Sweep**

* The strategy waits for price to sweep the relevant structure/liquidity.
* The sweep helps avoid entering immediately into a false breakout.

**4. Entry**

* Once the required structure and liquidity conditions are satisfied, the strategy generates a long or short signal.

### Trading Philosophy

The core idea is:

**Structure → Confirmation → Liquidity Sweep → Entry**

Instead of chasing price after a breakout, the strategy waits for the market to confirm its intention and then looks for an entry after liquidity has been taken.

### Important Note

This is a systematic strategy designed for backtesting and research. Results can vary depending on market conditions, execution, slippage, commissions, and the instrument being traded.

Past backtest performance does not guarantee future results. Always test the strategy thoroughly before using it with real capital.

---

## Source Code

````pine
//@version=6

strategy(
     "MNQ 1M INVERSE CHoCH - SESSION TOGGLE",
     overlay=true,
     initial_capital=50000,
     pyramiding=0,
     default_qty_type=strategy.fixed,
     default_qty_value=1,
     margin_long=5,
     margin_short=5,
     process_orders_on_close=true,
     calc_on_order_fills=false,
     calc_on_every_tick=false,
     calc_on_every_history_tick=false,
     commission_type=strategy.commission.cash_per_contract,
     commission_value=1.50)

//=====================================================
// SETTINGS
//=====================================================

int SWING = 2
float SL_POINTS = 15.0
float TP_POINTS = 15.0

//=====================================================
// SESSION FILTER TOGGLE
//=====================================================

bool useSessionFilter = input.bool(true, "Use US Session Filter")

bool morning =
     not na(time(
         timeframe.period,
         "0930-1200",
         "America/New_York"))

bool afternoon =
     not na(time(
         timeframe.period,
         "1330-1600",
         "America/New_York"))

bool allowedSession =
     not useSessionFilter or morning or afternoon

//=====================================================
// 5-MINUTE EMA TREND
//=====================================================

float ema20_5m =
     request.security(
         syminfo.tickerid,
         "5",
         ta.ema(close, 20)[1],
         lookahead=barmerge.lookahead_on)

float ema50_5m =
     request.security(
         syminfo.tickerid,
         "5",
         ta.ema(close, 50)[1],
         lookahead=barmerge.lookahead_on)

bool trendBull = ema20_5m > ema50_5m
bool trendBear = ema20_5m < ema50_5m

//=====================================================
// 1-MINUTE PIVOTS
//=====================================================

float pivotHigh = ta.pivothigh(high, SWING, SWING)
float pivotLow = ta.pivotlow(low, SWING, SWING)

var float lastSwingHigh = na
var float lastSwingLow = na

if not na(pivotHigh)
    lastSwingHigh := pivotHigh

if not na(pivotLow)
    lastSwingLow := pivotLow

//=====================================================
// MARKET STRUCTURE
//=====================================================

var int structure = 0

bool breakHigh =
     not na(lastSwingHigh) and
     close > lastSwingHigh

bool breakLow =
     not na(lastSwingLow) and
     close < lastSwingLow

if structure == 0
    if breakHigh
        structure := 1
    else if breakLow
        structure := -1

//=====================================================
// CHoCH
//=====================================================

bool bullishCHoCH =
     breakHigh and
     structure == -1

bool bearishCHoCH =
     breakLow and
     structure == 1

if bullishCHoCH
    structure := 1

if bearishCHoCH
    structure := -1

//=====================================================
// INVERSE CHoCH
//=====================================================

bool BUY =
     bearishCHoCH and
     trendBull and
     allowedSession

bool SELL =
     bullishCHoCH and
     trendBear and
     allowedSession

//=====================================================
// ENTRIES
//=====================================================

if BUY and strategy.position_size == 0
    strategy.entry("LONG", strategy.long)

if SELL and strategy.position_size == 0
    strategy.entry("SHORT", strategy.short)

//=====================================================
// FIXED 15 / 15
//=====================================================

if strategy.position_size > 0
    strategy.exit(
         "LONG EXIT",
         from_entry="LONG",
         stop=strategy.position_avg_price - SL_POINTS,
         limit=strategy.position_avg_price + TP_POINTS)

if strategy.position_size < 0
    strategy.exit(
         "SHORT EXIT",
         from_entry="SHORT",
         stop=strategy.position_avg_price + SL_POINTS,
         limit=strategy.position_avg_price - TP_POINTS)

//=====================================================
// SIGNALS
//=====================================================

plotshape(
     BUY,
     title="BUY",
     style=shape.triangleup,
     location=location.belowbar,
     size=size.small,
     text="BUY")

plotshape(
     SELL,
     title="SELL",
     style=shape.triangledown,
     location=location.abovebar,
     size=size.small,
     text="SELL")

//=====================================================
// 5M EMA
//=====================================================

plot(ema20_5m, title="5M EMA 20")
plot(ema50_5m, title="5M EMA 50")
````
