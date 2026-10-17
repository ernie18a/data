# Takhtupuria Triple Candle Pattern Alert..5

- url: https://www.tradingview.com/script/pM5Oaj9c-Takhtupuria-Triple-Candle-Pattern-Alert-5/
- type: indicator
- pine_id: PUB;b9064f96bd2740beac916d56c8cc962f
- version: 1.0

## Description

Takhtupuria Triple Candle Pattern Alert
This professional-grade tool is designed to identify specific Triple Candle Patterns in the market. By highlighting these formations, the indicator helps traders spot potential trend reversals or continuations before they fully develop.
Key Features:
 Automated Pattern Detection: Instantly highlights triple candle formations directly on your chart, removing the need for manual scanning.
 Visual Confirmation: Uses clear Bar Color changes to mark the specific candles that complete the identified pattern.
 Pane Labels: Integrated labels provide quick visual confirmation of the pattern, keeping your chart clean and easy to read.
 Real-time Alerts: Designed for speed, perfect for scalpers and intraday traders who need to react quickly to price action.
How to Use:
 Style: Customize the Bar Color to highlight patterns in a color that stands out against your chart background.
 Precision: Toggle the Pane labels to keep your workspace clutter-free while still receiving vital pattern data.
 Strategy: Combine this with other trend-following tools to confirm if the detected pattern aligns with the overall market direction.
Designed by Takhtupuria to bring advanced price action analysis to every trader's arsenal.

## Source Code

````pine
//@version=5
indicator("Triple Candle Pattern Alert", overlay=true)

// ਪੈਟਰਨ ਦੀ ਪਰਿਭਾਸ਼ਾ
isBullish = close > open and close[1] > open[1] and close[2] > open[2]
isBearish = close < open and close[1] < open[1] and close[2] < open[2]

// ਕੈਂਡਲਾਂ ਦਾ ਰੰਗ ਬਦਲਣਾ (Yellow)
barcolor(isBullish or isBearish ? color.yellow : na)

// ਸਿਗਨਲ ਅਤੇ ਲੇਬਲ
if isBullish
    label.new(bar_index, high, "BUY", color=color.green, textcolor=color.white, style=label.style_label_up)
    alert("Buy Signal: Triple Bullish Pattern", alert.freq_once_per_bar_close)

if isBearish
    label.new(bar_index, low, "SELL", color=color.red, textcolor=color.white, style=label.style_label_down)
    alert("Sell Signal: Triple Bearish Pattern", alert.freq_once_per_bar_close)
````
