# Algomist.app v1.0

- url: https://www.tradingview.com/script/wp0V0TVO-Algomist-app-v1-0/
- type: strategy
- pine_id: PUB;ef89e009921b4f80bd34cef17b2d9a4a
- version: 4.0

## Description

🚀 WMA Crossover Momentum Scalper: Algomist.app AUTO-EXECUTION

This strategy is a momentum-based trend-following system optimized for fully automated, high-frequency trade execution via algomist.app webhooks. It systematically enters trades based on a powerful moving average crossover, confirmed by both volume and volatility filters.

⚙️ Core Strategy Logic
This script is designed to capture short- to medium-term moves in trending markets by combining three key indicators:

Trend Confirmation (WMA Crossover): The primary signal is generated when a Fast WMA (50-period) crosses the Slow WMA (100-period). This crossover confirms the shift in the prevailing trend direction.

Volume Filter (VWAP): The trade is only taken if the price is trading above the VWAP for Long entries, or below the VWAP for Short entries. This ensures the trade is aligned with the asset's average price relative to trading volume.

Volatility Filter (ATR): A minimum Average True Range (ATR) filter is applied. This is critical for avoiding entries during periods of extreme low volatility ("chop"), ensuring the market has enough movement to justify the trade.

🔗 Algomist.app Automation Ready
This is the most important feature. The script contains custom-coded alert() functions that output a perfect JSON payload, making it 100% compatible with the algomist.app webhook infrastructure.

Seamless Execution: The strategy instantly transmits all required parameters—symbol, side, entry_price, dynamic stop_loss, and dynamic take_profit—directly to your MT5 terminal through the algomist.app connector.

Simple Setup: To enable live automation, you only need to configure a TradingView alert using the provided webhook URL and the {{strategy.order.alert_message}} placeholder on the bar's close.

Default Asset: The webhook is pre-configured to trade the ETHUSDC symbol. This can be easily adapted to other crypto or Forex pairs within the algomist.app settings.

🛡️ Dynamic Risk Management (ATR-Based)
Risk management is dynamic, ensuring the Stop Loss and Take Profit levels automatically adapt to current market volatility:

Stop Loss (SL): Placed at a customizable (x) * ATR distance from the entry price. The default setting is 3.0x ATR.

Take Profit (TP): Placed at a customizable (x) * ATR distance from the entry price. The default setting is 9.0x ATR, offering a fixed Reward-to-Risk ratio of 3:1 (9.0 / 3.0).

Position Sizing: The script uses strategy.percent_of_equity = 10% for backtesting, but the algomist.app execution is based on an internal calculation using a small percentage (e.g., 5%) of a leveraged notional value for illustrative purposes. Users must set their risk size within the algomist.app platform.

Disclaimer: This script is provided as an example for Algomist.app users and is NOT financial advice. Backtest thoroughly across various assets and timeframes. Past performance is not indicative of future results. The user assumes all responsibility for live trading risk.

## Source Code

````pine
//@version=5
strategy("Algomist: Adaptive Velocity Cross", shorttitle="Algomist: Adaptive Velocity Cross", overlay=true, default_qty_type=strategy.percent_of_equity, default_qty_value=10, initial_capital = 100)

//This script implements an adaptive moving average crossover (using Hull MA for speed) filtered by a higher-timeframe trend and a velocity (separation) check.

// --- Strategy Inputs ---
fastLen = input.int(10, "Fast HMA Length", minval=1)
slowLen = input.int(50, "Slow HMA Length", minval=1)
ATRLength = input.int(14, title="ATR Length")
ATRMinFilter = input.float(5.5, title="Min ATR Filter (avoid low vol)", step=0.01)
higherATRTrendPeriod = input.string("60", "Higher ATR Trend Period")
higherATRMinFilter = input.float(14.0, title="ATR Length")
riskMultiplier   = input.float(3, title="Stop Loss (x ATR)")
rewardMultiplier = input.float(7, title="Take Profit (x ATR)")

// === Position Size Calculation ===
// Only for TradingView backtesting - Won't be sent to Algomist
initialCapital = 100
leverage = 125
qtyPercent = 0.05
positionValue = initialCapital * leverage * qtyPercent
qty = positionValue / close

// --- Hull Moving Average (HMA) Calculation Function ---
// HMA is used for its reduced lag
hma(src, length) =>
    wma1 = ta.wma(src, math.round(length / 2))
    wma2 = ta.wma(src, length)
    diff = 2 * wma1 - wma2
    ta.wma(diff, math.round(math.sqrt(length)))

fastHMA = hma(close, fastLen)
slowHMA = hma(close, slowLen)
atr = ta.atr(ATRLength)
atr_higher = request.security(syminfo.tickerid, higherATRTrendPeriod, atr[0])


// --- Trend Strenght Fitler ---
// Assure that ATR filters are Management
isVolatile = atr > ATRMinFilter
isTrending = atr_higher > higherATRMinFilter
isUp =  ta.crossover(fastHMA, slowHMA)
isDown = ta.crossover(slowHMA, fastHMA)

// --- Trading Logic ---
// When and why to place entries
longCondition = isUp and isVolatile and isTrending
shortCondition = isDown and isVolatile and isTrending

// === Risk Management ===
// Calculating stop-loss and take-proft
longSL = math.round(hl2 - atr * riskMultiplier, 1)
longTP = math.round(hl2 + atr * rewardMultiplier, 1)
shortSL = math.round(hl2 + atr * riskMultiplier, 1)
shortTP = math.round(hl2 - atr * rewardMultiplier, 1)

// === Trade Execution ===
// Sending out JSON formatted trading signals to Algomist
if (longCondition and strategy.position_size == 0)
    strategy.entry("Long", strategy.long)
    strategy.exit("Long Exit", from_entry="Long", stop=longSL, limit=longTP)
    alert('{ "symbol": "ETHUSDC", "side": "LONG", "entry_price": ' + str.tostring(close, "#.0") + 
          ', "stop_loss": ' + str.tostring(longSL, "#.0") + 
          ', "take_profit": ' + str.tostring(longTP, "#.0") +
          ', "timestamp": ' + str.tostring(timenow) + '}', alert.freq_once_per_bar_close)

if (shortCondition and strategy.position_size == 0)
    strategy.entry("Short", strategy.short)
    strategy.exit("Short Exit", from_entry="Short", stop=shortSL, limit=shortTP)
    alert('{ "symbol": "ETHUSDC", "side": "SHORT", "entry_price": ' + str.tostring(close, "#.0") + 
          ', "stop_loss": ' + str.tostring(shortSL, "#.0") + 
          ', "take_profit": ' + str.tostring(shortTP, "#.0") +
          ', "timestamp": ' + str.tostring(timenow) + '}', alert.freq_once_per_bar_close)
    
// --- Plotting and Visualization ---
pFast = plot(fastHMA, title="Fast HMA", color=color.new(#00b9ff, 0), linewidth=2)
pSlow = plot(slowHMA, title="Slow HMA", color=color.new(#ff14fb, 0), linewidth=2)

plot(atr, title="ATR", color=color.new(#00b9ff, 0), linewidth=1)
plot(atr_higher, title="Higher ATR", color=color.new(#ff14fb, 0), linewidth=1)

hmaFillColor = fastHMA > slowHMA ? #00b9ff : #ff14fb
hmaFillTransparency = 50
fill(pFast, pSlow, color=color.new(hmaFillColor, hmaFillTransparency))

if barstate.islast
    watermarkLabel = label.new(bar_index, high * 1.0005, 
         text="Algomist\nAutomate your edge", 
         xloc=xloc.bar_index, yloc=yloc.price, 
         style=label.style_none, 
         textcolor=color.new(color.gray, 60), 
         size=size.small)
````
