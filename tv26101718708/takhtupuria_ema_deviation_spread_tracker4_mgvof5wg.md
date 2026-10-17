# Takhtupuria EMA Deviation & Spread Tracker..4

- url: https://www.tradingview.com/script/Mgvof5wg-Takhtupuria-EMA-Deviation-Spread-Tracker-4/
- type: indicator
- pine_id: PUB;d4809a0650334e5cbd7d5965c806b938
- version: 1.0

## Description

Takhtupuria EMA Deviation & Spread Tracker
This precision tool is designed for professional scalpers and trend traders who monitor the relationship between the 21 EMA and 200 EMA. It calculates the real-time spread and deviation, providing critical data for identifying mean reversion and momentum shifts.
Key Features:
 Precision Spread Tracking: Real-time calculation of the deviation between your Fast and Slow EMAs.
 Visual Analysis: Clean, integrated tables and pane labels that show the current spread value, helping you identify if the price is over-extended from the mean.
 Customizable Parameters: Full control over Fast and Slow EMA inputs. Adapt the tool to your specific trading pair or time frame.
 Institutional Clarity: Helps traders visualize where the price stands relative to the institutional 200 EMA baseline.
How to Use:
 Inputs: Set your preferred EMA lengths (default 21/200).
 Dashboard: Use the integrated tables to track the spread in real-time.
 Style: Fully customizable line colors and table visibility to suit your trading workspace.
Designed by Takhtupuria to add an extra layer of quantitative analysis to your chart.

## Source Code

````pine
//@version=5
indicator("EMA Deviation & Spread Tracker", overlay=true)

// ਇੰਡੀਕੇਟਰ ਇਨਪੁਟਸ
emaFastLen = input.int(21, "Fast EMA")
emaSlowLen = input.int(200, "Slow EMA")

ema21 = ta.ema(close, emaFastLen)
ema200 = ta.ema(close, emaSlowLen)

// 1. ਕੈਂਡਲ ਦੀ 21 EMA ਤੋਂ ਦੂਰੀ
deviation = ((close - ema21) / ema21) * 100

// ਕੈਂਡਲ ਉੱਤੇ ਲੇਬਲ ਲਗਾਉਣਾ
if (math.abs(deviation) > 0.1) // ਸਿਰਫ ਉਦੋਂ ਜਦੋਂ 0.1% ਤੋਂ ਵੱਧ ਦੂਰੀ ਹੋਵੇ
    label.new(bar_index, high, text=str.tostring(math.round(deviation, 2)) + "%", 
         color=deviation > 0 ? color.green : color.red, 
         textcolor=color.white, 
         style=label.style_label_down, size=size.tiny)

// 2. 21 EMA ਅਤੇ 200 EMA ਦਾ ਸਪ੍ਰੈਡ (Spread)
spread = ((ema21 - ema200) / ema200) * 100

// ਸਕ੍ਰੀਨ ਤੇ ਟੇਬਲ ਦਿਖਾਉਣਾ
var table dash = table.new(position.top_right, 2, 2, border_width = 1)
if barstate.islast
    table.cell(dash, 0, 0, "Spread (21 vs 200 EMA)", bgcolor = color.gray, text_color = color.white)
    table.cell(dash, 1, 0, str.tostring(math.round(spread, 2)) + "%", bgcolor = spread > 0 ? color.green : color.red, text_color = color.white)

plot(ema21, color=color.blue, linewidth=2, title="21 EMA")
plot(ema200, color=color.orange, linewidth=2, title="200 EMA")
````
