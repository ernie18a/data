# VWAP Anchored Kaufman Adaptive 

- url: https://www.tradingview.com/script/RnnXdlKK-VWAP-Anchored-Kaufman-Adaptive/
- type: indicator
- pine_id: PUB;09b1e93fc6174c9aada7678048ecc85e
- version: 1.0

## Description

The Anchored Kaufman Adaptive VWAP is a VWAP-inspired line that resets at the start of each anchor period (Session, Week, Month, and so on) but, unlike a standard VWAP, does not weight all bars of the period equally. Instead it uses Kaufman’s adaptive smoothing:

When price is trending efficiently, the line reacts faster.
When price is choppy and noisy, the line smooths out and flattens.

Around the line, adaptive volatility bands also respond to market efficiency.

⚙️ How it works

1) Anchor reset
At the start of each chosen period (Session, Week, Month, Quarter, Year, Decade, Century), the calculation restarts, seeded from the first bar of the new period.

2) Kaufman Efficiency Ratio (ER)
ER = |net price change over N bars| ÷ (sum of absolute bar-to-bar changes over N bars), using the chosen source (default HLC3).

ER near 1 means a clean, directional move.
ER near 0 means noise and chop.

3) Adaptive smoothing constant
The ER is mapped to a smoothing constant between a fastest and a slowest EMA equivalent (defaults 2 and 30, as in Kaufman’s AMA), then squared:
SC = (ER × (fastSC − slowSC) + slowSC)²

4) Volume-weighted adaptive mean
Both price × volume and volume are smoothed with this adaptive constant. The line is their ratio:
AKA-VWAP = smoothed(price × volume) ÷ smoothed(volume)
This is an exponentially weighted, volume-weighted mean whose speed adapts to market efficiency. It is not the cumulative volume-weighted average of a classic VWAP.

5) Adaptive bands
Band distance = ATR × multiplier × (2 − ER)

In chop (low ER) the bands are up to about 2× wider, so noise stays inside them.
In strong trends (high ER) the bands are about 1× tighter, so a stretch from the mean is easier to see.
These are ATR-based bands, not standard deviation bands.

6) Line color
The line is blue when the source is above it and red when the source is below it. This is a simple bias cue, not a trade signal.

🧭 How to use it (step by step)
Use a futures chart with real volume (for example ES1!, NQ1!, GC1!, CL1!).
Pick the anchor to match your timeframe:
1m to 15m charts: Session
30m to 4h charts: Week
Daily charts: Month or Quarter
Weekly and higher: Year, Decade or Century
The anchor period must be longer than the chart timeframe. For example, a Session anchor on a daily chart resets on every bar, and the line will just follow price.
Read the line’s behavior:
Sloped line with tight bands: efficient trend. Pullbacks to the line are often watched for continuation.
Flat line with wide bands: choppy, balanced market. Reaction at the outer bands is often watched for mean reversion.
Read price versus the line:
Price holding above (blue) suggests buyers are in control relative to the adaptive volume-weighted mean.
Price holding below (red) suggests sellers are in control.
Read the bands: price outside a band means it is stretched relative to current volatility and efficiency. A stretched price in a strong trend can stay stretched, so it is not a reversal signal on its own.
Confirm with your own tools (market structure, order flow, key levels, session context, risk rules) before acting.
🎯 Tips for best performance
Efficiency Ratio Length: lower values (5–10) react faster but are noisier. Higher values (20–30) are smoother and slower.
Fastest / Slowest EMA Equivalent: the defaults (2 / 30) are Kaufman’s classic values. Widen the gap for a more dramatic fast/slow switch, or narrow it for a steadier line.
Volatility Band Multiplier: raise it for fewer band touches, lower it for more.
Early in a period the line is seeded from the first bar, so it can sit close to the opening value until enough bars accumulate. Give it time before leaning on it.
Use the Offset setting only for visual alignment.
Compare behavior across anchors, for example Session for intraday decisions and Week for broader context.
🔍 Limitations (please read)
Not a standard VWAP. The adaptive smoothing gives recent bars more influence than early-period bars, so values will differ from a classic anchored VWAP.
Volume dependent. Poor, tick-based or missing volume produces unreliable output.
ER is not reset at the anchor. Its lookback can include bars from before the new period.
Decade and Century anchors only make sense on very high timeframes with long history.
No built-in alerts or signals. The script plots only. You can still create alerts on price crossing the line or bands from TradingView’s alert dialog.
Results vary by symbol, timeframe and data feed.  

This is NOT a holy grail. It does not predict price and does not generate buy or sell signals. It is a context and mean-reference tool that you combine with your own strategy, confirmation and risk management.
This is not a classic VWAP (see “How it works”). Do not expect it to match the built-in VWAP or your broker’s VWAP.
Nothing here is financial advice. Trading involves substantial risk of loss. Backtest and forward-test before using real money.

## Source Code

````pine
//@version=6
indicator(title="Anchored Kaufman Adaptive VWAP", shorttitle="AKA-VWAP", overlay=true, timeframe="", timeframe_gaps=true)

// --- SETTINGS GROUPS ---
VWAP_GROUP  = "VWAP Settings"
ADAPT_GROUP = "Kaufman ER Settings"
BANDS_GROUP = "Bands Settings"

hideonDWM = input(false, title="Hide VWAP on 1D or Above", group=VWAP_GROUP, display = display.none)
var anchor = input.string(defval = "Session", title="Anchor Period",
     options=["Session", "Week", "Month", "Quarter", "Year", "Decade", "Century"], group=VWAP_GROUP)
src = input(title = "Source", defval = hlc3, group=VWAP_GROUP, display = display.none)
offset = input.int(0, title="Offset", group=VWAP_GROUP, display = display.none)

adaptLen  = input.int(14, title="Efficiency Ratio Length", minval=1, group=ADAPT_GROUP)
fastEnd   = input.int(2, title="Fastest EMA Equivalent", minval=1, group=ADAPT_GROUP)
slowEnd   = input.int(30, title="Slowest EMA Equivalent", minval=2, group=ADAPT_GROUP)
bandMult  = input.float(2.0, title="Volatility Band Multiplier", minval=0.1, step=0.5, group=BANDS_GROUP)

cumVolume = ta.cum(volume)
if barstate.islast and cumVolume == 0
    runtime.error("No volume is provided by the data vendor.")

// --- ANCHOR PERIOD DETECTION ---
isNewPeriod = switch anchor
    "Session"   => timeframe.change("D")
    "Week"      => timeframe.change("W")
    "Month"     => timeframe.change("M")
    "Quarter"   => timeframe.change("3M")
    "Year"      => timeframe.change("12M")
    "Decade"    => timeframe.change("12M") and year % 10 == 0
    "Century"   => timeframe.change("12M") and year % 100 == 0
    => false

if na(src[1])
    isNewPeriod := true

// --- 1. KAUFMAN EFFICIENCY RATIO (ER) & SMOOTHING CONSTANT (SC) ---
netChange = math.abs(src - src[adaptLen])
sumChange = math.sum(math.abs(src - src[1]), adaptLen)
er        = sumChange != 0 ? netChange / sumChange : 0.0

fastSC    = 2.0 / (fastEnd + 1.0)
slowSC    = 2.0 / (slowEnd + 1.0)
sc        = math.pow(er * (fastSC - slowSC) + slowSC, 2)

// --- 2. ANCHORED & KAUFMAN-SMOOTHED VOLUME-WEIGHTED MATH ---
pv        = src * volume
var float smoothPV = na
var float smoothV  = na

if isNewPeriod or na(smoothPV[1])
    smoothPV := pv
    smoothV  := volume
else
    smoothPV := smoothPV[1] + sc * (pv - smoothPV[1])
    smoothV  := smoothV[1] + sc * (volume - smoothV[1])

kaVwap = smoothV != 0 ? smoothPV / smoothV : src

// --- 3. DYNAMIC ADAPTIVE BANDS ---
atrVal    = ta.atr(adaptLen)
bandDist  = atrVal * bandMult * (2.0 - er)

upperBand = kaVwap + bandDist
lowerBand = kaVwap - bandDist

// --- PLOTTING ---
vwapColor = src > kaVwap ? color.new(#2962FF, 0) : color.new(#FF5252, 0)
plot(kaVwap, title="Anchored KA-VWAP", color=vwapColor, linewidth=2, offset=offset)

p1 = plot(upperBand, title="Upper Adaptive Band", color=color.green, offset=offset)
p2 = plot(lowerBand, title="Lower Adaptive Band", color=color.red, offset=offset)
fill(p1, p2, title="Adaptive Band Fill", color=color.new(color.orange, 92))
````
