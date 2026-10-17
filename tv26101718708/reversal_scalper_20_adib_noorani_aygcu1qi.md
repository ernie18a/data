# Reversal Scalper 2.0- Adib Noorani

- url: https://www.tradingview.com/script/aYGCu1qi-Reversal-Scalper-2-0-Adib-Noorani/
- type: indicator
- pine_id: PUB;7bad296e761248c9801c167abbbf11c3
- version: 1.0

## Description

Reversal Scalper - Smoothed Stoch & ATR Trend Filter

Hey everyone, I originally put this script together to help me scalp XAUUSD and Indian equities on lower timeframes, specifically to solve a problem I was having with standard momentum oscillators.

We all know the main issue with using a regular Stochastic for scalping: it’s great for spotting exhaustion, but when a strong trend kicks in, the oscillator just stays pegged in the overbought or oversold zones. If you try to trade those reversal signals blindly, you just get run over by the trend.

To fix this, I created a mashup that combines a smoothed Stochastic with a custom ATR-based structural trend ribbon. The whole point of combining these two indicators is to use the ATR bands to define the actual market structure, and only take the Stochastic reversal signals when the trend filter confirms that the push is actually exhausted.

How the math works:
First, the bottom oscillator (what I call the Reversal Strength Meter) is based on a standard 8-period Stochastic. But to cut out the erratic noise you usually get on the 1m or 5m charts, I ran it through a 5-period Simple Moving Average. It gives a much cleaner read on momentum.

Second, the background trend filter uses a long-term ATR (100-period, halved) multiplied by a deviation factor (default is 3). The script looks back at recent swing highs and lows to project a volatility channel. I linked this channel to the bar colors so you don't need to look at messy lines on your chart.

How to trade with it:
If the price breaks hard outside the ATR channel, the candles change color (white for a strong push up, black for a strong push down). When you see this, it means the trend is expanding—do not look for reversals, even if the Stochastic is at an extreme.

For Longs: Wait for a strong downward push that turns the candles black. Let the smoothed Stochastic dip below the 20 level. You only enter long when the candles go back to their normal color (showing the structural selling pressure has stopped) AND the stochastic crosses firmly back up above 20.

For Shorts: Wait for a bullish push that turns the candles white. Let the stochastic ride up above 80. Your short trigger is when the candles return to normal and the stochastic crosses back down below 80.

I left the inputs open so you can adjust the Stochastic lengths and the ATR deviation factor depending on what timeframe or asset you are trading. Hope this helps you guys filter out the fake outs.

## Source Code

````pine
//@version=6
indicator('Reversal Scalper 2.0- Adib Noorani', overlay = false, shorttitle="RevScalper")

// ==========================================
// 1. OSCILLATOR SECTION (MOMENTUM & EXHAUSTION)
// ==========================================
kLength     = input.int(8, title="Stochastic K Length", group="Oscillator Settings")
kSmoothing  = input.int(5, title="Stochastic Smoothing SMA", group="Oscillator Settings")

// Calculate the smoothed Stochastic to measure momentum exhaustion
reversalStrength = ta.sma(ta.stoch(close, high, low, kLength), kSmoothing)
revStrengthColor = input.color(color.rgb(17, 14, 209, 4), title = 'Reversal Strength Meter Color', group="Visual Settings")

plot(reversalStrength, title = 'Reversal Strength Meter', color = revStrengthColor, linewidth = 2)

// Custom Zone Labels for extreme exhaustion levels
supplyZone = plot(80, 'Potential Supply Zone', color = color.black, linewidth = 2)
demandZone = plot(20, 'Potential Demand Zone', color = color.black, linewidth = 2)
fill(supplyZone, demandZone, color = color.new(#0fc5dd, 90), title = 'Zone Fill')

// ==========================================
// 2. TREND RIBBON SECTION (VOLATILITY-BASED FILTER)
// ==========================================
amp       = input.int(3, title="Amplitude (Highest/Lowest Bars)", group="Trend Ribbon Settings")
devFactor = input.float(3.0, title="ATR Deviation Factor", group="Trend Ribbon Settings")

var int t = 0
var int nt = 0
var float maxLow = na(low[1]) ? low : low[1]
var float minHigh = na(high[1]) ? high : high[1]

var float u = 0.0
var float d = 0.0
float hiBand = 0.0
float loBand = 0.0

// Calculate volatility channel using a modified half-ATR baseline
halfATR = ta.atr(100) / 2
dev = devFactor * halfATR

hPrice = high[math.abs(ta.highestbars(amp))]
lPrice = low[math.abs(ta.lowestbars(amp))]
hAvg = ta.sma(high, amp)
lAvg = ta.sma(low, amp)

// Trend tracking switch mechanism
if nt == 1
    maxLow := math.max(lPrice, maxLow)
    if hAvg < maxLow and close < low[1]
        t := 1
        nt := 0
        minHigh := hPrice
else
    minHigh := math.min(hPrice, minHigh)
    if lAvg > minHigh and close > high[1]
        t := 0
        nt := 1
        maxLow := lPrice

// Dynamic dynamic channel band adjustments based on the dominant trend side
if t == 0
    u := (not na(t[1]) and t[1] != 0) ? (na(d[1]) ? d : d[1]) : (na(u[1]) ? maxLow : math.max(maxLow, u[1]))
    hiBand := u + dev
    loBand := u - dev
else
    d := (not na(t[1]) and t[1] != 1) ? (na(u[1]) ? u : u[1]) : (na(d[1]) ? minHigh : math.min(minHigh, d[1]))
    hiBand := d + dev
    loBand := d - dev

center = t == 0 ? u : d

buyCol  = input.color(color.rgb(76, 175, 80, 85), title = 'Buy Ribbon Color', group="Visual Settings")
sellCol = input.color(color.rgb(255, 82, 82, 85), title = 'Sell Ribbon Color', group="Visual Settings")

// Hidden baseline plots to facilitate visual fill adjustments on overlay execution
hiBandPlot = plot(hiBand, title = 'High Band (Internal)', style = plot.style_circles, color = sellCol, display = display.none, force_overlay = true)
loBandPlot = plot(loBand, title = 'Low Band (Internal)', style = plot.style_circles, color = buyCol, display = display.none, force_overlay = true)
centerPlot = plot(center, title = 'Center Baseline (Internal)', display = display.none, force_overlay = true)

// Dynamic Bar Coloring based on breakout parameters of the hidden volatility bands
barcolor(close < loBand ? color.black : close > hiBand ? color.white : na)

// Fill execution for sub-window visual context
fill(centerPlot, hiBandPlot, title = 'High Ribbon Fill', color = sellCol)
fill(centerPlot, loBandPlot, title = 'Low Ribbon Fill', color = buyCol)
````
