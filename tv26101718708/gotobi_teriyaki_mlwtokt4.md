# Gotobi Teriyaki

- url: https://www.tradingview.com/script/MlWTOkt4/
- type: strategy
- pine_id: PUB;825969dd961b48568607fd735b5042ce
- version: 2.0

## Description

USDJPY Anomaly.

This anomaly originated in Japan.

Buy from 2:00 pm Japan time.

Sell at 9:55 Japan time.

Japanese importers often settle payments to suppliers in dollars, and exchange yen for dollars on settlement days (days falling on a 5 or 10, so-called goto days).

Therefore, on goto days, there is sometimes a shortage of dollars held by financial institutions. This is called the "middle price shortage," and financial institutions purchase dollars through the foreign exchange market to resolve the middle price shortage.

As a result, the dollar currency is bought and USD/JPY depreciates against the yen. Since the yen has historically appreciated against the dollar, exporting companies make forward exchange contracts with financial institutions as a risk hedge.

Financial institutions are therefore forced to procure dollars in the market because they do not have enough dollars in their balance sheets to deliver to exporters.

Five days is called "GO" in Japanese.

Ten days is called "TO" in Japanese.

In Japanese, a day is called "BI".

Now I can eat teriyaki all day long :)

ドル円ゴトー日ストラテジーを作ってみました。

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © hosono_p

//@version=5
strategy("Gotobi Teriyaki", overlay=true)

current_day= dayofmonth(time("1"), "Asia/Tokyo")
saturday = dayofmonth(time("1")+ 1000*60*60*24 , "Asia/Tokyo")
sunday = dayofmonth(time("1")+ 1000*60*60*48, "Asia/Tokyo")
is_5day_10day= current_day % 5==0
flyday = dayofweek(time("1"), "Asia/Tokyo") == 6
flyday_5day_10day = (flyday and saturday % 5==0) or (flyday and sunday % 5==0)

buy_time = time("1", "0200-0955:23456","Asia/Tokyo") and is_5day_10day or time("1", "0200-0955:23456","Asia/Tokyo") and flyday_5day_10day
bgcolor(buy_time ? color.new(color.green, 90) : na)

sell_time = time("1", "0955-1500:23456","Asia/Tokyo") and is_5day_10day or time("1", "0955-1500:23456","Asia/Tokyo") and flyday_5day_10day
bgcolor(sell_time ? color.new(color.red, 90) : na)

if strategy.position_size > 0
    if not buy_time
        strategy.close_all()
if strategy.position_size < 0
    if not sell_time
        strategy.close_all() 

if strategy.position_size == 0
    if buy_time
        strategy.entry("buy",strategy.long)
    if sell_time
        strategy.entry("sell",strategy.short)
````
