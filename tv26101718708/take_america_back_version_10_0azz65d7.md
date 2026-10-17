# Take America Back Version 1.0

- url: https://www.tradingview.com/script/0aZz65d7-Take-America-Back-Version-1-0/
- type: strategy
- pine_id: PUB;7oZiAoRB3fN0icwIV8KQdlFMygBtnKfN
- version: 1.0

## Description

So basically, the when the price goes down a little, it buys, and when it goes up a little it buys. The only indicators are account balances, and the price, that’s it. Now I wish that Pine Script had a function or variable in which I could recall the balances of specific portions of the portfolio, but it doesn’t. So, I had to improvise. Now for this to work accurately, all of the money needs to be in the “base” side before the bot can begin. Now, the thing about this is that it does not re-invest the amount that is “saved” to all but guarantee the balance will go up. However, as this goes up it will not add up as quickly in order to allow more wiggle room so that the bot does not work itself into a corner. If you want to keep some of your base, enter how much you want to keep it in the initial “saved” setting, as long as you allow at least enough to be equal to the default quantity value. Also, I recommend you setting the pyramiding setting to the result of the base value divided by the default quantity value. The default quantity value is how much you invest, measured in the base currency.

This would have been sooooo much easier if pine script could allow me to recall specific balances, but maybe a future one will.

Finally, THIS is why I made this program, I wanted to create something that would prevent the little ones from being stepped on by the big players who don't always play fair.

Besides, cryptocurrencies were made in response to the 2008 financial meltdown that caused a global recession. This decentralized currency is not just the money of the banks, the corporations, or the governments, but the money of the people. Use this tool to level the massive wealth inequality in my country and take America Back.

I will post more links and updates later once my reputation score goes up. I will discuss more about what influenced me to make this program and as some advise and possible future improvements as well.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Crystal_Catalyst

//@version=4
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Crystal_Catalyst

//@version=4
strategy("Take America Back Version 1.0", close_entries_rule="ANY")
default_qty_value=input(defval=20, title="Quantity Value")
var float saved=input(defval=0, title="Saved")
var price = close
var float asset = na
var float base = na
var float ratio = na
fees = input(defval=.0025, title="Fees")
asset := (strategy.opentrades*default_qty_value+strategy.openprofit)/open
base := strategy.initial_capital-strategy.opentrades*default_qty_value+strategy.netprofit
ratio := asset*open/(default_qty_value*strategy.opentrades)
if ratio>1
    ratio := 1
var initial_asset = asset
var initial_base = base
var previous_asset = asset
var previous_base = base
if strategy.opentrades != strategy.opentrades[1]
    price := open[1]
if strategy.netprofit>strategy.netprofit[1]
    saved := saved+(strategy.netprofit-strategy.netprofit[1])*(base-saved)/base
buy = "Take America Back" + tostring(strategy.opentrades)
sell = "Take America Back" + tostring(strategy.opentrades-1)
if open>price and asset*open<default_qty_value
    price := open
if open<price and base<default_qty_value+saved
    price := open
if open>(asset*price+default_qty_value*2*fees)/(asset*ratio) and asset*open>default_qty_value
    strategy.exit(sell, limit=open, stop=open)
if open<price*(1-2*fees/(base/default_qty_value)) and base>default_qty_value+saved
    strategy.entry(buy, true, limit=open, stop=open, qty=default_qty_value/close, when = close<price*(1-fees))
plot(saved, title="Saved", color=color.black, style=plot.style_line)
````
