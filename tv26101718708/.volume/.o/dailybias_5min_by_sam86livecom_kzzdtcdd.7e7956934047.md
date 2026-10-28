Calculation: Daily trend = last completed daily close relative to its daily EMA, with daily ADX meeting the trend-strength threshold when that filter is enabled
Calculation: Momentum = EMA of the difference between close and its longer-lookback close
Calculation: Q-Trend direction = close/source crossing above or below the midpoint of its rolling high-low range offset by the prior bar’s ATR; a direction is fresh when it differs from the prior Q-Trend direction
Calculation: UT Bot trail = ATR-offset trailing stop that follows the source upward while the source stays above it and downward while below it
Calculation: Demand/supply zone = price range extending from a confirmed pivot low/high by an ATR-based depth; a bar is in a zone when its range overlaps that zone
Calculation: Delta = selected proxy for volume-weighted buying minus selling pressure; strong positive/negative delta means its absolute value meets or exceeds its rolling percentile threshold
Calculation: Volume spike = volume greater than its moving average times the spike threshold
Calculation: Long score = count of bullish daily trend, fast DEMA above slow DEMA, bullish Q-Trend direction, source above UT Bot trail, overlap with demand zone, strong positive delta, above session VWAP when enabled, above completed opening range when enabled, and positive momentum
Calculation: Short score = count of bearish daily trend, fast DEMA below slow DEMA, bearish Q-Trend direction, source below UT Bot trail, overlap with supply zone, strong negative delta, below session VWAP when enabled, below completed opening range when enabled, and negative momentum
Calculation: Market sentiment = average of the script’s eleven normalized technical indicator scores
Long: Fast DEMA crosses above slow DEMA during the enabled trading session
Long: Momentum crosses above zero
Long: Q-Trend direction changes to bullish
Long: UT Bot source crosses above its trail
Long: Bar overlaps a demand zone AND delta is positive and meets its rolling percentile threshold AND volume exceeds the volume-spike threshold when bubble volume confirmation is enabled
Long: At least the required number of bullish score components are true AND (bullish Q-Trend changes OR UT Bot source crosses above its trail OR fast DEMA crosses above slow DEMA) AND enabled-session condition AND cooldown since the prior long signal has elapsed AND volume confirmation passes AND daily trend is bullish
Long: Long signal condition AND RSI is below its long-entry ceiling AND position is flat or short
Long: Market sentiment exceeds its bullish threshold
Short: Fast DEMA crosses below slow DEMA during the enabled trading session
Short: Momentum crosses below zero
Short: Q-Trend direction changes to bearish
Short: UT Bot source crosses below its trail
Short: Bar overlaps a supply zone AND delta is negative and meets its rolling percentile threshold AND volume exceeds the volume-spike threshold when bubble volume confirmation is enabled
Short: At least the required number of bearish score components are true AND (bearish Q-Trend changes OR UT Bot source crosses below its trail OR fast DEMA crosses below slow DEMA) AND enabled-session condition AND cooldown since the prior short signal has elapsed AND volume confirmation passes AND daily trend is bearish
Short: Short signal condition AND RSI is above its short-entry floor AND position is flat or long
Short: Market sentiment is below its bearish threshold
Exit: long, low <= close minus ATR times stop multiple OR high >= close plus ATR times stop multiple times reward multiple OR a short entry condition occurs
Exit: short, high >= close plus ATR times stop multiple OR low <= close minus ATR times stop multiple times reward multiple OR a long entry condition occurs