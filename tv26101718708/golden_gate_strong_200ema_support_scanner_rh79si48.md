# Golden Gate Strong 200EMA Support Scanner

- url: https://www.tradingview.com/script/Rh79SI48-Golden-Gate-Strong-200EMA-Support-Scanner/
- type: indicator
- pine_id: PUB;93cb86e653d2467f985a413663d206b1
- version: 1.0

## Description

Golden Gate Strong 200EMA Support Scanner
This is a custom Pine Script scanner designed for swing trading based on the Golden Gate strategy. It identifies fresh crossovers where the 20 EMA moves above the 50 EMA and 100 EMA, ensuring that the exponential moving averages are perfectly aligned in a bullish sequence (20 > 50 > 100 > 200). 

Additionally, it features a unique filter to detect a flat 200 EMA over the last 15 bars, which acts as a major, rock-solid support and magnet for the price. To prevent chasing overextended trends, the script restricts signals if the price is more than 3% away from the 20 EMA line, catching early breakouts with high win probability and tight stop losses.

## Source Code

````pine
//@version=6
indicator("Golden Gate Strong 200EMA Support Scanner", shorttitle="GG 200EMA Scanner", overlay=true)

// મુવિંગ એવરેજના ઇનપુટ્સ
ema20_len  = input.int(20, title="EMA 20")
ema50_len  = input.int(50, title="EMA 50")
ema100_len = input.int(100, title="EMA 100")
ema200_len = input.int(200, title="EMA 200")

// ફિલ્ટર સેટિંગ્સ
lookback   = input.int(5, title="Lookback Bars")
max_dist   = input.float(3.0, title="Max Distance From EMA 20 (%)")
flat_depth = input.int(15, title="Flat 200 EMA Bars")
flat_thres = input.float(0.5, title="Flat 200 EMA Threshold (%)")

// EMA ની ગણતરી
ema20  = ta.ema(close, ema20_len)
ema50  = ta.ema(close, ema50_len)
ema100 = ta.ema(close, ema100_len)
ema200 = ta.ema(close, ema200_len)

// ચાર્ટ પર મુવિંગ એવરેજ પ્લોટ કરવી
plot(ema20, color=color.orange, title="EMA 20", linewidth=1)
plot(ema50, color=color.red, title="EMA 50", linewidth=1)
plot(ema100, color=color.blue, title="EMA 100", linewidth=1)
plot(ema200, color=color.navy, title="EMA 200", linewidth=2)

// ૧. બધી એવરેજ ક્રમમાં હોવી જોઈએ (સિક્વન્સ)
is_aligned = (ema20 > ema50) and (ema50 > ema100) and (ema100 > ema200)

// ૨. ફ્રેશ ક્રોસઓવર કન્ડિશન
fresh_ema_cross = ta.barssince(ta.crossover(ema20, ema50)) <= lookback or ta.barssince(ta.crossover(ema20, ema100)) <= lookback

// ૩. કિંમત ૨૦ EMA થી બહુ દૂર ન હોવી જોઈએ
price_distance = ((close - ema20) / ema20) * 100
price_dist_ok = price_distance <= max_dist and close > ema20

// ૪. ૨૦૦ EMA એકદમ સીધી (Flat) હોવી જોઈએ
ema200_highest = ta.highest(ema200, flat_depth)
ema200_lowest  = ta.lowest(ema200, flat_depth)
ema200_change  = ((ema200_highest - ema200_lowest) / ema200_lowest) * 100
ema200_is_flat = ema200_change <= flat_thres

// ૫. પ્રાઈસ બ્રેકઆઉટ કન્ડિશન
price_breakout = ta.crossover(close, ema20) or (close > ema20 and ta.barssince(ta.crossover(close, ema20)) <= lookback)

// બધી શરતો સાથે ફાઇનલ સિગ્નલ
final_golden_gate = is_aligned and fresh_ema_cross and price_dist_ok and ema200_is_flat and price_breakout

// ચાર્ટ પર સિગ્નલ બતાવવા માટે (મોટો લીલો ત્રિકોણ)
plotshape(series=final_golden_gate, title="Strong Support Golden Gate", style=shape.triangleup, location=location.belowbar, color=color.green, size=size.large)

// એલર્ટ સેટ કરવા માટે
alertcondition(final_golden_gate, title="Flat 200EMA Golden Gate Setup!", message="Golden Gate Setup Found: {{ticker}}")
````
