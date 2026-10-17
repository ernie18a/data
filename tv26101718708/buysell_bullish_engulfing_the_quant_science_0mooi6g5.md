# Buy&Sell Bullish Engulfing - The Quant Science

- url: https://www.tradingview.com/script/0moOi6G5-Buy-Sell-Bullish-Engulfing-The-Quant-Science/
- type: strategy
- pine_id: PUB;5567e83af3be4e7087b78cd9ffb1a5df
- version: 4.0

## Description

🇺🇸
[b]GENERAL OVERVIEW[/b]
[i][b]Buy&Sell Bullish Engulfing - The Quant Science[/b][/I] It is a Buy&Sell strategy based on the 'Bullish Engulfing' candlestick pattern. The main goal of the strategy is to achieve a consistent and sustainable return over time, with a manageable level of risk.

[b]Bullish Engulfing[/b]
The template was developed at the top of the Indicator provided by TradingView called 'Engulfing - Bullish'.

[url=https://www.tradingview.com/x/cjRw2X62/]https://www.tradingview.com/x/cjRw2X62/[/url]

[b]ENTRY AND EXIT CRITERIA[/b]
[i][b]Entry:[/b][/I] A single long order is opened when the candlestick pattern is formed, and the percentage size of the order (%) is fixed by the trader through the user interface.

[url=https://www.tradingview.com/x/GIv7bbrg/]https://www.tradingview.com/x/GIv7bbrg/[/url]

[i][b]Exit:[/b][/i] The long trade is closed on a percentage equity take profit-stop loss.

[url=https://www.tradingview.com/x/VhNkbjne/]https://www.tradingview.com/x/VhNkbjne/[/url]

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

🇮🇹
[b]PANORAMICA GENERALE[/b]
[i][b]Buy&Sell Bullish Engulfing - The Quant Science[/b][/i] è una strategia Buy&Sell basata sul candlestick pattern 'Bullish Engulfing'. L'obiettivo principale della strategia è ottenere un ritorno costante e sostenibile nel tempo, con un livello gestibile di rischio.

[b]Bullish Engulfing[/b]
Il template è stato sviluppato al top dell' Indicatore fornito da Trading View chiamato 'Engulfing - Bullish'.

[url=https://www.tradingview.com/x/cjRw2X62/]https://www.tradingview.com/x/cjRw2X62/[/url]

[b]CRITERI DI ENTRATA E USCITA[/b]
[i][b]Entrata:[/b][/i] viene aperto un singolo ordine long quando si forma il candlestick pattern, la size percentuale dell'ordine (%) viene selezionato tramite l'interfaccia utente dal trader.

[url=https://www.tradingview.com/x/GIv7bbrg/]https://www.tradingview.com/x/GIv7bbrg/[/url]

[i][b]Uscita:[/b][/i] la chiusura della posizione avviene unicamente tramite un take profit-stop loss percentuale calcolato sul capitale. 

[url=https://www.tradingview.com/x/VhNkbjne/]https://www.tradingview.com/x/VhNkbjne/[/url]

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © thequantscience

//@version=6
strategy(
     "Buy&Sell Bullish Engulfing Strategy [The Quant Science]",
     overlay = true,
     default_qty_type = strategy.percent_of_equity, 
     default_qty_value = 100,
     pyramiding = 1,
     currency = currency.USDT,
     initial_capital = 10000,
     commission_type = strategy.commission.percent,
     commission_value = 0.07,
     process_orders_on_close = true, 
     close_entries_rule = "ANY"
     )

profit = input.float(2.0, title = "Target profit [%]", minval = 0, step = 0.10, group = "Settings")
stoploss = input.float(2.0, title = "Stop Loss [%]", minval = 0, step = 0.10, group = "Settings")

t_ordersize = "Percentage size of each order calculated based on starting initial capital."
orders_size = input.float(30.0, title = "Position Order Size [%]", minval = 0.10, maxval = 100, step = 0.10, group = "Settings", tooltip = t_ordersize)

show_bg = input.bool(true, title = "Highlight Pattern Background", group = "Design Settings")
color_bull = input.color(color.rgb(59, 255, 69), title = "Color: Bullish Signal", group = "Design Settings")
color_bg = input.color(color.new(color.rgb(59, 255, 69), 85), title = "Background Color Pattern", group = "Design Settings")

var float equity_trades = strategy.initial_capital
qty_order = ((equity_trades * orders_size) / 100) / close

trend_rule_1 = "SMA50"
trend_rule_2 = "SMA50, SMA200"
trend_rule = input.string(trend_rule_1, title = "Detect Trends Based On", options = [trend_rule_1, trend_rule_2, "No detection"], group = "Design Settings")

bool c_down_trend = true
bool c_up_trend = true

if trend_rule == trend_rule_1
    price_avg = ta.sma(close, 50)
    c_down_trend := close < price_avg
    c_up_trend := close > price_avg

else if trend_rule == trend_rule_2
    sma200 = ta.sma(close, 200)
    sma50 = ta.sma(close, 50)
    c_down_trend := close < sma50 and sma50 < sma200
    c_up_trend := close > sma50 and sma50 > sma200

c_len = 14
c_shadow_percent = 5.0 

c_body_hi = math.max(close, open)
c_body_lo = math.min(close, open)
c_body = c_body_hi - c_body_lo
c_body_avg = ta.ema(c_body, c_len)

c_small_body = c_body < c_body_avg
c_long_body = c_body > c_body_avg
c_white_body = open < close
c_black_body = open > close

engulfing_bullish = c_down_trend and c_white_body and c_long_body and c_black_body[1] and c_small_body[1] and close >= open[1] and open <= close[1] and (close > open[1] or open < close[1])

var float equity = 0.0
var float o_price = 0.0
var float c_exit = 0.0
var float c_stopl = 0.0

if engulfing_bullish and strategy.opentrades == 0
    equity := strategy.equity
    o_price := close
    c_exit := equity + (equity * profit / 100)
    c_stopl := equity - (equity * stoploss / 100)
    strategy.entry("#ENTRY", strategy.long, qty = qty_order, limit = o_price)

if ta.crossover(strategy.equity, c_exit)
    strategy.exit("#TP", from_entry = "#ENTRY", limit = close)

if ta.crossunder(strategy.equity, c_stopl)
    strategy.exit("#SL", from_entry = "#ENTRY", limit = close)

plotshape(
     engulfing_bullish and strategy.opentrades == 0, 
     title="Bullish Engulfing Detection", 
     style=shape.triangledown, 
     location=location.abovebar, 
     color=color_bull, 
     size=size.tiny, 
     text="BULLISH ENGULFING", 
     textcolor=color_bull
     )

bgcolor(show_bg and engulfing_bullish and strategy.opentrades == 0 ? color_bg : na)
````
