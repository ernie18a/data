# HAP + Sniper Combined 

- url: https://www.tradingview.com/script/dgwLsJGV/
- type: indicator
- pine_id: PUB;d4f28a74b9f0452d9e10346cfd811621
- version: 1.0

## Description

trend regime filtering with normalized price positioning.

The first component, the EMA Cage, is built using three exponential moving averages (14, 50, and 100 periods). It defines dynamic trend zones based on the relative alignment of short, medium, and long-term EMAs. When the EMAs are aligned upward or downward, the structure highlights directional trend phases through adaptive coloring and band visualization.

The second component, the Sniper Band, transforms price behavior into normalized oscillatory values using both range-based and mean-reversion calculations. It compares short-term price distribution against a smoothed percentage deviation from a moving average. These two normalized signals are then mapped back onto the price scale to create a structured dual-band system.

The interaction between these two lines defines market state:

When both normalized components converge closely, it indicates equilibrium or compression zones.
When separation increases, it reflects directional expansion and trend development.
Color transitions represent relative dominance between the two normalized measures.

This combined structure is designed to visualize both trend direction (EMA Cage) and internal price pressure (Sniper Band) within the same framework, enabling clearer identification of market phases such as consolidation, expansion, and directional bias shifts.

## Source Code

````pine
//@version=6
indicator("HAP + Sniper Combined Overlay (Original Colors Restored)", overlay=true)

//────────────────────────────
// EMA CAGE (ORİJİNAL)
//────────────────────────────
fast = ta.ema(close, 14)
mid  = ta.ema(close, 50)
slow = ta.ema(close, 100)

upperBand = math.max(fast, math.max(mid, slow))
lowerBand = math.min(fast, math.min(mid, slow))

trendUp   = fast > mid and mid > slow
trendDown = fast < mid and mid < slow

color cageBandColor = color.gray
color cageFillColor = color.new(color.gray, 90)

if trendUp
    cageBandColor := color.green
    cageFillColor := color.new(color.green, 85)
else if trendDown
    cageBandColor := color.red
    cageFillColor := color.new(color.red, 85)

//────────────────────────────
// SNIPER BAND (ORİJİNAL RENK MANTIĞI)
//────────────────────────────
len    = input.int(20, "Referans Uzunluğu", minval=5)
smooth = input.int(3, "Yumuşatma", minval=1)

priceMin = ta.lowest(close, len)
priceMax = ta.highest(close, len)
rangePrice = priceMax - priceMin

priceRaw  = rangePrice != 0 ? ((close - priceMin) / rangePrice) * 100 : 50
priceLine = ta.ema(priceRaw, smooth)

base = ta.sma(close, len)
percentRaw = base != 0 ? ((close - base) / base) * 100 : 0

pctMin = ta.lowest(percentRaw, len)
pctMax = ta.highest(percentRaw, len)
rangePct = pctMax - pctMin

percentNorm = rangePct != 0 ? ((percentRaw - pctMin) / rangePct) * 100 : 50
percentLine = ta.ema(percentNorm, smooth)

//────────────────────────────
// MAP TO PRICE SCALE
//────────────────────────────
priceMinP = ta.lowest(close, len)
priceMaxP = ta.highest(close, len)
rangeP = priceMaxP - priceMinP

p1 = priceMinP + (priceLine / 100) * rangeP
p2 = priceMinP + (percentLine / 100) * rangeP

//────────────────────────────
// ORİJİNAL STATE
//────────────────────────────
distance = math.abs(priceLine - percentLine)

isBull = priceLine > percentLine
isBear = priceLine < percentLine
touch  = distance < 3

// çizgiler üst üste → yeşil
color sniperColor = color.gray

if touch
    sniperColor := color.green
else if isBull
    sniperColor := color.lime
else if isBear
    sniperColor := color.red
else
    sniperColor := color.gray

upper = math.max(p1, p2)
lower = math.min(p1, p2)

//────────────────────────────
// EMA CAGE PLOTS
//────────────────────────────
pc1 = plot(upperBand, color=cageBandColor, linewidth=2)
pc2 = plot(lowerBand, color=cageBandColor, linewidth=2)
fill(pc1, pc2, color=cageFillColor)

//────────────────────────────
// SNIPER BAND PLOTS
//────────────────────────────
ps1 = plot(p1, color=sniperColor, linewidth=2)
ps2 = plot(p2, color=sniperColor, linewidth=2)
fill(ps1, ps2, color=color.new(sniperColor, 85))
````
