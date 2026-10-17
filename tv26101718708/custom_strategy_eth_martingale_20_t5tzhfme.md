# Custom Strategy: ETH Martingale 2.0

- url: https://www.tradingview.com/script/t5TZHFmE/
- type: strategy
- pine_id: PUB;8e70c5dd1ca44a8986d49e9d26713d58
- version: 2.0

## Description

Strategic characteristics
ETH Little Martin 2.0 is a self-developed trading strategy based on the Martingale strategy, mainly used for trading ETH (Ethereum). The core idea of this strategy is to place orders in the same direction at a fixed price interval, and then use Martin's multiple investment principle to reduce losses, but this is also the main source of losses.

Parameter description:

1 Interval： The minimum spacing for taking profit, stop loss, and opening/closing of orders. Different targets have different spacing. Taking ETH as an example, it is generally recommended to have a spacing of 2% for fluctuations in the target.
2 Base Price： This is the price at which you triggered the first order. Similarly, I am using ETH as an example. If you have other targets, I suggest using the initial value of a price that can be backtesting. The Base Price is only an initial order price and has no impact on subsequent orders.
3 Initial Order Amount： Users can set an initial order amount to control the risk of each transaction. If the stop loss is reached, we will double the amount based on this value. This refers to the value of the position held, not the number of positions held.
4 Loss Multiplier： The strategy will increase the next order amount based on the set multiple after the stop loss, in order to make up for the previous losses through a larger position. Note that after taking profit, it will be reset to 1 times the Initial Order Amount.
5. Long Short Operation: The first order of the strategy is a multiple entry, and in subsequent orders, if the stop loss is reached, a reverse order will be opened. The position value of a one-way order is based on the Loss Multiplier multiple investment, so it is generally recommended that the Loss Multiplier default to 2.

Improvement direction
Although this strategy already has a certain trading logic, there are still some improvement directions that can be considered:

1. Dynamic adjustment of spacing: Currently, the spacing is fixed, and it can be considered to dynamically adjust the spacing based on market volatility to improve the adaptability of the strategy. Try using dynamic spacing, which may be more suitable for the actual market situation.
2. Filtering criteria: Orders and no orders can be optimized separately. The biggest problem with this strategy is that it will result in continuous losses during fluctuations, and eventually increase the investment amount. You can consider filtering out some fluctuations or only focusing on trend trends.
3. Risk management: Add more risk management measures, such as setting a maximum loss limit to avoid huge losses caused by continuous stop loss.
4. Optimize the stop loss multiple: Currently, the stop loss multiple is fixed, and it can be considered to dynamically adjust the multiple according to market conditions to reduce risk.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © zhiming
//@version=5
strategy(shorttitle="Custom Strategy: ETH Martingale 2.0",
         title="Custom Strategy: ETH Martingale 2.0",
         overlay=true,
         initial_capital=100,
         default_qty_type=strategy.cash,
         default_qty_value=100,
         commission_type=strategy.commission.percent,
         commission_value=0.03,
         pyramiding=1,
         close_entries_rule="FIFO",
         currency='USD',
         max_bars_back=1000)

interval=input.float(50,title = "Interval",group = "Base Parameters")
base_price=input.int(225,title = "Base Price",group = "Base Parameters")
initial_order_amount=input.int(100,title = 'Initial Order Amount',group = "Base Parameters")
loss_multiplier=input.float(2,title = "Loss Multiplier",group = "Base Parameters")

order_qty_1=initial_order_amount/close

var order_multiple=1.0
var price_base=0.0
var order_num=1

//======================================================================================================================================DPO

// DPO 指标参数
period_short = input.int(12, title="long_period", minval=1,group = "DPO",inline = "1")
period_long = input.int(26, title="short_period", minval=1,group = "DPO",inline = "1")
x_period = input.int(12, title="Difference", minval=1,group = "DPO",inline = "1")
smooth_period = input.int(5, title="smooth", minval=1,group = "DPO",inline = "2")
dpo_max=input.int(100,title = "MAX",group = "DPO",inline = "2")
dpo_min=input.int(0,title = "MIN",group = "DPO",inline = "2")
offset_long = math.floor(period_long / 2) + 1
offset_short = math.floor(period_short / 2) + 1
dpo_short_raw = close - ta.sma(close, period_short)[offset_short]
dpo_long_raw = close - ta.sma(close, period_long)[offset_long]
dpo_long = ta.sma(dpo_long_raw, smooth_period)
dpo_short = ta.sma(dpo_short_raw, smooth_period)
dpo_diff_raw = dpo_short - dpo_long 

// === 绘制 DPO 差值的最高点和最低点 ===

// 计算 DPO 差值的 X 周期最高点和最低点
dpo_diff_high_raw = ta.highest(dpo_diff_raw, x_period)
dpo_diff_low_raw = ta.lowest(dpo_diff_raw, x_period)

// 对最高点和最低点进行平滑
dpo_diff_high = ta.sma(dpo_diff_high_raw, smooth_period)
dpo_diff_low = ta.sma(dpo_diff_low_raw, smooth_period)


// === 计算 DPO 差值的中线 ===

// 中线计算公式：(最高点 + 最低点) / 2
dpo_diff_mid = (dpo_diff_high + dpo_diff_low) / 2

// Define golden cross condition
golden_cross = ta.crossover(close, base_price)
[macdLine, signalLine, histLine] = ta.macd(close, 12, 26, 9)
// Go long when golden cross condition is met

if strategy.opentrades==0 and macdLine>signalLine and dpo_diff_mid>dpo_min and dpo_diff_mid<dpo_max
    if (golden_cross) and strategy.opentrades==0 and price_base==0
        strategy.entry("L_"+str.tostring(order_num)+"_"+str.tostring(order_multiple), strategy.long,qty = order_qty_1,comment = "L_"+str.tostring(order_num)+"_"+str.tostring(order_multiple))
        price_base:=close
    // Add filter when there are no orders
    if price_base>0
        if close-price_base>=interval
            order_multiple:=order_multiple
            order_num:=order_num
            strategy.entry("L_"+str.tostring(order_num)+"_"+str.tostring(order_multiple), strategy.long,qty = order_qty_1*order_multiple,comment ="L_"+str.tostring(order_num)+"_"+str.tostring(order_multiple))
            price_base:=close
        if close-price_base<=(-interval)
            order_multiple:=order_multiple
            order_num:=order_num
            strategy.entry("S_"+str.tostring(order_num)+"_"+str.tostring(order_multiple),strategy.short,qty = order_qty_1*order_multiple,comment = "S_"+str.tostring(order_num)+"_"+str.tostring(order_multiple))
            price_base:=close

// Do not process if there are orders
if strategy.opentrades>=1
    if strategy.position_size>0
        if close>price_base+interval and close>strategy.position_avg_price
            strategy.close("L_"+str.tostring(order_num)+"_"+str.tostring(order_multiple),comment = "L_"+str.tostring(order_num)+"_"+str.tostring(order_multiple))
            price_base:=close
            order_multiple:=1
            order_num:=1
    if strategy.position_size<0
        if close<price_base-interval and close<strategy.position_avg_price
            strategy.close("S_"+str.tostring(order_num)+"_"+str.tostring(order_multiple),comment = "S_"+str.tostring(order_num)+"_"+str.tostring(order_multiple))
            order_multiple:=1
            order_num:=1
            price_base:=close
    if close-price_base>=interval
        order_multiple:=order_multiple*loss_multiplier
        order_num:=order_num+1
        strategy.entry("L_"+str.tostring(order_num)+"_"+str.tostring(order_multiple), strategy.long,qty = order_qty_1*order_multiple,comment = "L_"+str.tostring(order_num)+"_"+str.tostring(order_multiple))
        price_base:=close
    if close-price_base<=(-interval)
        order_multiple:=order_multiple*loss_multiplier
        order_num:=order_num+1
        strategy.entry("S_"+str.tostring(order_num)+"_"+str.tostring(order_multiple),strategy.short,qty = order_qty_1*order_multiple,comment = "S_"+str.tostring(order_num)+"_"+str.tostring(order_multiple))
        price_base:=close

if strategy.opentrades==0
    order_multiple:=1
    order_num:=1

plot(price_base+interval>interval?price_base+interval:na,color = color.red,force_overlay = true)
plot(price_base-interval>=interval?price_base-interval:na,color = color.green,force_overlay = true)
plot(price_base>0?price_base:na,force_overlay = true)
// plot(order_multiple>=1?order_multiple:na?order_multiple:na,force_overlay = false,color = color.black)
````
