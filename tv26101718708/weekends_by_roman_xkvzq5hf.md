# Weekends [by Roman]

- url: https://www.tradingview.com/script/XKvzQ5hf-Weekends-by-Roman/
- type: indicator
- pine_id: PUB;49b9c6b6f8114c54ac5afe0d857943bb
- version: 1.0

## Description

Weekends [by Roman] highlights Saturday and Sunday sessions directly on the chart using a subtle grey background.

The indicator is designed for traders who want cleaner visual separation between trading and non-trading periods, especially when analyzing:
• Crypto markets
• Weekend volatility
• Gaps and low-liquidity conditions
• Session behavior around Monday opens

Features:
• Automatically highlights Saturdays and Sundays
• Displays only the last 10 weeks to keep charts clean
• Minimalistic transparent grey background
• Uses traders's timezone 
• Lightweight and optimized for all timeframes

Useful for:
• ICT / Smart Money Concepts traders
• Session-based analysis
• Weekend liquidity studies
• Identifying low-volume periods
• Cleaner chart structure and visual organization

The script helps quickly distinguish active market conditions from weekend trading behavior without cluttering the chart.

## Source Code

````pine
//@version=5
indicator("Weekends [by Roman]", overlay=true)

// === SETTINGS ===
timezoneInput = input.string("UTC+5", "Timezone")

// === TIMEZONE ===
dayTZ = dayofweek(time, timezoneInput)

// === WEEKEND DETECTION ===
isWeekend = dayTZ == dayofweek.saturday or dayTZ == dayofweek.sunday

// === LIMIT TO LAST 10 WEEKS ===
tenWeeksMs = 10 * 7 * 24 * 60 * 60 * 1000
isLast10Weeks = time >= timenow - tenWeeksMs

// === BACKGROUND ===
bgcolor(isWeekend and isLast10Weeks? color.new(color.gray, 95): na)
````
