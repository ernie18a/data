# Wake Up watch Filter

- url: https://www.tradingview.com/script/XfbwIWms-Wake-Up-watch-Filter/
- type: indicator
- pine_id: PUB;083f67dbb79f478dbc5c6fd4d6c0476e
- version: 1.0

## Description

consolidation Spotting the Spark: 
Catching Reversals at the Absolute End of Consolidation In the financial markets, the most explosive moves do not happen during active trends; they are born in the quietest moments of consolidation. When a market moves sideways, retail volume drains out and standard indicators lag, making it easy to fall asleep at the wheel. 

The Wake Up Watch Filter is engineered specifically to fix this, acting as a direct wake-up call to alert you precisely when a tight consolidation is exhausting its energy and preparing to break out. Instead of guessing when a sideways market will end, the algorithm uses a highly responsive combination of volatility compression and volume dry-up to clock the exact moment of peak saturation:  [ TIGHT SIDEWAYS DRIFT ]  ──>  [ VOLUME DRIES UP ]  ──>  [ 🟢 WAKE UP SIGNAL! ] ( Bollinger inside Keltner)     (Transaction Percentile < 40%)   (Explosive Turn Imminent)

Why the Timing is Precise The Absolute Apex of the Squeeze: By monitoring when Bollinger Bands compress completely inside the Keltner Channels, the script mathematically maps when the market has coiled as tightly as possible.

The Institutional Clue: It overlays a relative volume percentile rank (ta.percentrank <= 40%). When volume drops into this extreme lower tier, it proves that retail selling pressure has completely dried up and market makers have finished gathering their orders.The Instant Trigger: The script uses a clean state constraint (wakeUpSignal and not wakeUpSignal[1]). 

This ensures that it ignores the boring, early phases of a consolidation and fires a single, high-impact "WAKE UP" arrow right at the very edge of the range—giving you the exact heads-up you need to position your entries right before the next major market wave takes off.

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
