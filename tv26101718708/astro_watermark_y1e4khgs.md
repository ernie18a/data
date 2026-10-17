# Astro Watermark

- url: https://www.tradingview.com/script/y1e4KHgs-Astro-Watermark/
- type: indicator
- pine_id: PUB;d1a1abe001824d1baae6c5d3456261a9
- version: 1.0

## Description

Astro Watermark is a lightweight and elegant indicator that adds a stylish watermark to your chart, giving it a more professional and organized look.

It dynamically displays:

🌞 / 🌙 Day or night icon based on current chart time
🪙 Trading symbol (ticker)
⏱️ Shortened timeframe (e.g., 5m, 1h, 1D)
✨ Signature label: Astrological Trade
⚙️ Features:
Clean and minimal design
Transparent background that doesn’t interfere with price action
Automatically adapts to timeframe changes
Works on all markets (Crypto, Forex, Indices, etc.)
💡 Why use it?

This indicator is perfect if you:

Take chart screenshots
Share your analysis on social media
Want to add a unique visual identity to your charts
🚀 Note:

This is a visual-only indicator. It does not provide trading signals or affect your trading decisions.

## Source Code

````pine
//@version=5
indicator("Astro Watermark", overlay=true)

// دالة الإطار الزمني المختصر
getTimeFrameString() =>
    tf = timeframe.multiplier
    suffix = ""
    if timeframe.isseconds
        suffix := "s"
    else
        if timeframe.isminutes
            if tf >= 60
                tf := tf / 60
                suffix := "h"
            else
                suffix := "m"
        else
            if timeframe.isdaily
                suffix := "D"
            else
                if timeframe.isweekly
                    suffix := "W"
                else
                    if timeframe.ismonthly
                        suffix := "M"
    str.tostring(tf) + suffix

// الشمس أو القمر حسب الساعة
hour_now = hour(time)
emoji = (hour_now >= 6 and hour_now < 18) ? "☀️" : "🌙"

// رمز العملة والإطار الزمني المختصر
symbol = syminfo.ticker
tf_short = getTimeFrameString()

// نص العلامة المائية
watermark_text = emoji + "  " + symbol + "  " + tf_short + "  Astrological Trade"

// الخلفية سوداء شفافة 30%
bg_col = color.new(color.black, 70)

// رسم العلامة المائية
var tbl = table.new(position.bottom_right, 1, 1)
if barstate.islast
    table.cell(tbl, 0, 0, watermark_text, bgcolor=bg_col, text_color=color.white, text_size=size.large)
````
