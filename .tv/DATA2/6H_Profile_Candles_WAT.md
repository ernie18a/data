<!-- tradingview-pine-id: PUB;4aa76c19e1cf40bca96f641555cb6eb7 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# 6H Profile Candles — WAT

Source: https://www.tradingview.com/script/enZm3cyv-6H-Profile-Candles/

## Description

6H Profile Candles — WAT

A simple, lightweight indicator designed to highlight the opening candles of each 6-hour profile based on West Africa Time (WAT).

The indicator identifies the 6-hour profile starting points at:

• 1:00 AM WAT
• 7:00 AM WAT
• 1:00 PM WAT
• 7:00 PM WAT

These profile-opening candles are highlighted in gold, making the 6-hour structure easier to visualize directly on the chart.

Features

• Uses Africa/Lagos timezone (WAT)
• Highlights 6-hour profile opening candles
• Supports 1H, 15M, and 5M charts
• Includes an adjustable Time Offset input
• Lightweight and designed for clean chart visualization

This tool is intended to help traders visually organize price action into consistent 6-hour time profiles and study how price behaves around these key opening periods.

Note: This indicator is a visual timing tool and does not generate buy or sell signals. It should be used alongside your own analysis and trading framework.

---

## Source Code

````pine
//@version=6
indicator("6H Profile Candles — WAT", overlay=true)

// Nigerian time
string tz = "Africa/Lagos"

// Time offset
int timeOffset = input.int(
     0,
     "Time Offset",
     minval = -12,
     maxval = 12
)

// Current Nigerian hour
int h = hour(time, tz)

// Apply offset
int adjustedHour = (h + timeOffset + 24) % 24

// Six-hour starting hours
bool sixHourStart =
     adjustedHour == 1 or
     adjustedHour == 7 or
     adjustedHour == 13 or
     adjustedHour == 19

// Supported charts
bool validTF =
     timeframe.isminutes and
     (timeframe.multiplier == 60 or
      timeframe.multiplier == 15 or
      timeframe.multiplier == 5)

// Gold
bool goldCandle =
     validTF and sixHourStart

barcolor(goldCandle ? #FFD700 : na)
````
