# M15_Scalp_V1

- url: https://www.tradingview.com/script/Y1fNDvvc-M15-Scalp-V1/
- type: strategy
- pine_id: PUB;4285e8fa5b42403d8b653c078a79dd46
- version: 1.0

## Description

This is how I set up my M15 scalping for EURUSD. I made it so that it looks for one strong trend reversal every day, especially during the London/NY overlap. How it works:  Selective Entry: Uses a tight SuperTrend and RSI filter to find reversals early without having to buy at the top. Institutional Filter: I added a volume check so that it only goes off when there is real money moving the market. Risk First: It figures out the lot sizes for me based on a 2% risk of my total balance. One Shot: Only one setup can be traded per day between 11:00 AM and 10:00 PM IST to keep people from overtrading and trading during high-spread hours. Preparation: The [b]M15[/b] timeframe is best for this.

## Source Code

````pine
//@version=5
strategy("M15_Scalp_V1", overlay=true, initial_capital=10000, pyramiding=1, default_qty_type=strategy.cash, currency=currency.USD, process_orders_on_close=true, commission_type=strategy.commission.percent, commission_value=0.003, slippage=1)

// inputs
m = input.float(0.7, "multiplier")
p = input.int(10, "period")
risk_pc = input.float(2.0, "risk %")
limit = input.int(1, "max trades daily")
lookback = input.int(60, "backtest days")

// exit settings
tp = input.int(150, "trail profit") 
sl = input.int(125, "stop loss")      
trail = input.int(75, "trail offset")
ist_session = input.session("0530-1630", "session")

// indicators
[st_line, st_dir] = ta.supertrend(m, p)
my_rsi = ta.rsi(close, 14)
v_ma = ta.sma(volume, 20)

// trade tracker
var int today_count = 0
if ta.change(time("D"))
    today_count := 0

start_date = timenow - (lookback * 86400000)
time_ok = not na(time(timeframe.period, ist_session, "UTC"))
check_vol = volume > v_ma

// 2% risk math
allowed_loss = strategy.equity * (risk_pc / 100)
my_qty = math.floor(allowed_loss / (sl * syminfo.mintick * syminfo.pointvalue))

can_trade = time >= start_date and strategy.position_size == 0 and time_ok and check_vol and today_count < limit

if can_trade and ta.change(st_dir) < 0 and my_rsi < 60
    strategy.entry("Long", strategy.long, qty=my_qty)
    label.new(bar_index, low, "BUY\n" + str.tostring(my_qty, "#"), color=color.green, textcolor=color.white, style=label.style_label_up, yloc=yloc.belowbar, size=size.small)
    today_count += 1 

if can_trade and ta.change(st_dir) > 0 and my_rsi > 40
    strategy.entry("Short", strategy.short, qty=my_qty)
    label.new(bar_index, high, "SELL\n" + str.tostring(my_qty, "#"), color=color.red, textcolor=color.white, style=label.style_label_down, yloc=yloc.abovebar, size=size.small)
    today_count += 1 

strategy.exit("x", from_entry="Long", loss=sl, trail_points=tp, trail_offset=trail)
strategy.exit("x", from_entry="Short", loss=sl, trail_points=tp, trail_offset=trail)

plot(st_line, color = st_dir < 0 ? color.green : color.red, display=display.none)
````
