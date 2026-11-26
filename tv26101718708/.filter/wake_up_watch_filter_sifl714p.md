# Wake Up watch Filter

- url: https://www.tradingview.com/script/sifL714p-Wake-Up-watch-Filter/
- type: indicator
- pine_id: PUB;6a7ce7303b8744f69adced3eda29e82c
- version: 1.0

## Description

Useful, gives you wake up call. Penny stocks could be boring for months, this one gives you pre alert, before they wake up.

## Source Code

````pine
//@version=6
indicator("Wake Up watch Filter", overlay=true, max_labels_count=500)

// --- Inputs ---
int volLength     = input.int(20, title="Volume Lookback Length")
float volThresh   = input.float(40.0, title="Volume Dry-Up Percentile Threshold", minval=1.0, maxval=100.0)
int atrLength     = input.int(14, title="ATR Length")
float keltMultiplier = input.float(1.5, title="Keltner Channel Multiplier")
int bbLength      = input.int(20, title="Bollinger Band Length")
float bbStdDev    = input.float(2.0, title="Bollinger Band Std Dev")

// --- Volatility Compression (The Squeeze) ---
// Using a classic Bollinger inside Keltner squeeze to identify coiling price
float atrValue = ta.atr(atrLength)
float basis    = ta.sma(close, bbLength)
float dev      = bbStdDev * ta.stdev(close, bbLength)
float upperBB  = basis + dev
float lowerBB  = basis - dev

float upperKelt = basis + (atrValue * keltMultiplier)
float lowerKelt = basis - (atrValue * keltMultiplier)

bool squeezeActive = (upperBB < upperKelt) and (lowerBB > lowerKelt)

// --- Relative Volume Dry-Up ---
// Instead of absolute volume, we rank the current volume against the lookback period
// to find where trading has completely dried up.
float volPercentile = ta.percentrank(volume, volLength)
bool volumeDriedUp  = volPercentile <= volThresh

// --- Trend Context (Ensuring we aren't catching a falling knife) ---
// We want price above a baseline medium-term trend or consolidating flat, not cascading down.
float maBaseline = ta.ema(close, 50)
bool trendValid  = close >= maBaseline or ta.change(maBaseline) >= 0

// --- The Wake Up Trigger ---
// Condition: Volume is dead, price is tightly squeezed, trend is stable.
bool wakeUpSignal = squeezeActive and volumeDriedUp and trendValid

// Only trigger on the very first bar the setup appears to avoid duplicate noise
bool cleanTrigger = wakeUpSignal and not wakeUpSignal[1]

// --- Visuals ---
// Highlight background during the dry-up squeeze zone
bgcolor(squeezeActive and volumeDriedUp ? color.new(color.blue, 90) : na)

// Plot the Entry Alert
plotshape(cleanTrigger, title="Wake Up Watch", style=shape.triangleup, location=location.belowbar, color=color.green, size=size.small, text="WAKE UP")

// Optional Dashboard Alert for Visual Confirmation
if cleanTrigger
    label.new(bar_index, high, text="Dry Up\nAlert", color=color.green, textcolor=color.white, style=label.style_label_down, size=size.small)
````
