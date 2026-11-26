# TTwinCloud W-D Dual Timeframe Ichimoku Cloud

- url: https://www.tradingview.com/script/7hTzidXV/
- type: indicator
- pine_id: PUB;328aba7ae22140d9b5f708a18e588db7
- version: 1.0

## Description

[i]As an example and for explanatory purposes, I use the Gold chart (XAU/USD) here.[/i]

[b]🗺️ OVERVIEW 🗺️[/b]

TTwinCloud W/D is a TradingView indicator that overlays two Ichimoku clouds on a single chart: a Weekly cloud and a Daily cloud. 
Two Weekly EMAs are added as a long-term trend filter.

The name breaks down as follows:
• TT — the author's TradingView handle (TT136 / TigerTwin136)
• win — Twin
• Cloud — the Ichimoku clouds
• W/D — Weekly / Daily
[image]https://www.tradingview.com/x/118Vxn2O/[/image]
[b]💡 THE IDEA BEHIND IT 💡[/b]

Standard Ichimoku shows only one cloud — the one belonging to your current chart timeframe. To see what a higher timeframe is doing, you have to switch charts.

TTwinCloud W/D solves this by showing both levels at once:

• The Weekly cloud shows the higher-level trend (the big picture).
• The Daily cloud shows the finer structure (closer to price action).

This enables cross-timeframe analysis without leaving the chart. 
It is particularly useful for Elliott Wave and MSB (Market Structure Break) analysis.

[b]☁️☁️ THE TWO CLOUDS ☁️☁️[/b]

Each cloud is built from two lines:

• Lead A (Leading Span A) — the average of Tenkan and Kijun.
• Lead B (Leading Span B) — the average of the highest high and lowest low over the Senkou B period.

The area between these two lines is filled — that is the cloud.

The Weekly cloud is always calculated from the 1W timeframe. 
The Daily cloud is always calculated from the 1D timeframe. 
This applies regardless of which chart timeframe you are currently viewing.
[image]https://www.tradingview.com/x/sPhhggLW/[/image]
[b]🔵🔴 COLOR LOGIC (DYNAMIC FILLS) 🟢🟠[/b]

The fill colors switch automatically depending on which line is on top:

• When Lead A is above Lead B → blue fill for Weekly, mint green for Daily.
• When Lead A is below Lead B → red fill for Weekly, orange for Daily.

This acts as a visual trend indicator:
• Blue / mint green → bullish condition.
• Red / orange → bearish condition.

An important difference: 
The Weekly fills are stronger (transparency 85), while the Daily fills are lighter (transparency 90). This is intentional — the Weekly level is more significant, so it visually dominates.

[b]⚙️ ICHIMOKU PRESETS (FIXED) ⚙️[/b]

Instead of letting the user adjust every single Ichimoku value, TTwinCloud W/D offers three fixed presets:

• Original Japanese (9 / 26 / 52)
• Western (8 / 22 / 44)
• Fibonacci (8 / 34 / 55)

Background:

• The original values (9 / 26 / 52) come from the Japanese trading calendar: 9 = 1.5 weeks, 26 = 1 month, 52 = 2 months — based on the historical 6-day trading week in Japan.
• The Western values (8 / 22 / 44) are the adaptation to the 5-day trading week used in Western markets.
• The Fibonacci values (8 / 34 / 55) follow the Fibonacci sequence.

Once a preset is selected, the values are applied firmly. 
There is no further room for adjustment. 
This is intentional, so that the clouds remain consistent.
[image]https://www.tradingview.com/x/yZhu31fR/[/image]
[b]⏩ CLOUD OFFSET ⏩[/b]

This is the only setting the user is free to adjust.

The offset determines how far the clouds are projected into the future:

• Standard Ichimoku uses an offset of 26 (the cloud extends 26 periods ahead).
• TTwinCloud W/D defaults to 1, keeping the cloud close to price action.

The user can shift this value freely from 0 to 200 — and both clouds (Weekly and Daily) move together.

[b]🟡🟣 WEEKLY EMAs 🟡🟣 [/b]

In addition to the clouds, two exponential moving averages run on a weekly basis:

• EMA 1: default 55, gold color (#ffd700), dotted.
• EMA 2: default 233, purple color (#b026ff), dotted.

These EMAs are freely adjustable — the user can change the periods.

They serve as trend confirmation: 
when price is above both EMAs, the long-term trend is intact.

[b]⏱️ TIMEFRAME LOGIC ⏱️[/b]

The clouds are automatically shown or hidden depending on your chart timeframe, because they are not useful on every level:
[image]https://www.tradingview.com/x/58mLJtSC/[/image]
• Monthly chart (1M): Weekly cloud ON, Daily cloud OFF.
[image]https://www.tradingview.com/x/YqZBnbwH/[/image]
• Weekly (1W), Daily (1D), 4H, 1H: both clouds ON.
[image]https://www.tradingview.com/x/jfQEkH7N/[/image]
• Below 60 minutes (30m, 15m, 5m, 1m): Weekly cloud OFF, Daily cloud ON.

The logic:

• On the Monthly chart, the Daily cloud is too fine-grained and distracts → it is hidden.
• Below 60 minutes, the Weekly cloud is too coarse → it is hidden.

This keeps the chart clean and shows only the relevant levels.

[b]🔍 SCALING 🔍[/b]

The indicator is attached to the main price scale. 
There is no separate scale, which means the clouds will not shift away when you move or zoom the chart.

[b]🛠️ STYLE & CUSTOMIZATION 🛠️[/b]

All colors and line styles in TTwinCloud W/D are fully customizable. 
The colors listed above are simply the author's default choices — they are not fixed.

The user has complete freedom to adjust:

• Line colors for Weekly Lead A, Weekly Lead B, Daily Lead A, Daily Lead B
• Fill colors for both clouds (bullish and bearish states)
• EMA colors
• Line thickness and line style (solid, dotted, dashed)
• Visibility of individual elements (lines can be turned on or off in the Style tab)

Every visual aspect can be tailored to personal preference. 
The defaults are only a starting point.
[image]https://www.tradingview.com/x/M4qgMzPf/[/image]
[b]📝 SUMMARY 📝[/b]

TTwinCloud W/D is a dual-timeframe Ichimoku indicator that displays the Weekly and Daily clouds simultaneously, with fixed presets for the Ichimoku values, a shared cloud offset, two Weekly EMAs as a trend filter, and an automatic timeframe logic that shows or hides each cloud depending on the chart level.

[b]⚠️ DISCLAIMER ⚠️[/b]

This indicator is provided for informational and educational purposes only. 
It does not constitute financial advice, investment recommendations, or a solicitation to buy or sell any instrument. 
Trading involves a high level of risk and may result in the loss of invested capital. 
Past performance does not guarantee future results. 
The user is solely responsible for their own trading decisions. 
Use this script at your own risk.

## Source Code

````pine
        
    //@version=6
indicator("TTwinCloud W-D", shorttitle="TTwinCloud W-D", overlay=true)

// © 2026 TT136 - TTwinCloud W/D
// Free for the TradingView community
// Elliott Wave & MSB analysis support

// ────── COLORS (user adjustable) ──────
colorWeeklyA = #3b82f6   // Weekly Lead A
colorWeeklyB = #c8102e   // Weekly Lead B
colorDailyA  = #3fffa2   // Daily Lead A
colorDailyB  = #ff8c38   // Daily Lead B
colorEMA1    = #ffd700   // Weekly EMA 1
colorEMA2    = #b026ff   // Weekly EMA 2
colorFillW0  = #1e90ff   // Fill Weekly 0 (A > B)
colorFillW1  = #f23645   // Fill Weekly 1 (A < B)
colorFillD0  = #3fffa2   // Fill Daily 0 (A > B)
colorFillD1  = #ff8c38   // Fill Daily 1 (A < B)

// ────── DISPLAY: price scale labels & status line off ──────
plotDisplay = display.all - display.price_scale - display.status_line

// Weekly Lead A/B: hidden by default, user can enable in Style tab
displayWeeklyLines = display.none

// ────── ICHIMOKU PRESET (fixed) ──────
preset = input.string("Original Japanese (9/26/52)", "Ichimoku Preset",
     options=["Original Japanese (9/26/52)", "Western (8/22/44)", "Fibonacci (8/34/55)"],
     tooltip="The classic Ichimoku values originate from the Japanese trading calendar: 9 = 1.5 weeks, 26 = 1 month, 52 = 2 months — based on the historical 6-day trading week in Japan. The Western calendar uses the 5-day week: 8 = 1.5 weeks, 22 = 1 month, 44 = 2 months. Fibonacci uses the sequence 8 / 34 / 55.")

tenkanPeriod  = preset == "Original Japanese (9/26/52)" ? 9  : preset == "Western (8/22/44)" ? 8  : 8
kijunPeriod   = preset == "Original Japanese (9/26/52)" ? 26 : preset == "Western (8/22/44)" ? 22 : 34
senkouBPeriod = preset == "Original Japanese (9/26/52)" ? 52 : preset == "Western (8/22/44)" ? 44 : 55

// ────── CLOUD OFFSET (shared, default 1) ──────
cloudOffset = input.int(1, "Cloud Offset (Periods into the Future)", minval=0, maxval=200,
     tooltip="Standard Ichimoku projects the cloud 26 periods into the future. This script defaults to 1 to keep the cloud close to price action. Increase this value to shift both clouds (Weekly and Daily) further ahead.")

// ────── ADJUSTABLE EMA PARAMETERS ──────
ema1_period = input.int(55, "Weekly EMA 1 (e.g. 50/55)", step=1)
ema2_period = input.int(233, "Weekly EMA 2 (e.g. 200/233)", step=1)

// ────── TIMEFRAME LOGIC ──────
tfSeconds  = timeframe.in_seconds(timeframe.period)
isMonthly  = timeframe.period == "1M"
isUnder1H  = tfSeconds < 60 * 60

showDaily  = not isMonthly      // Daily cloud hidden only on monthly chart
showWeekly = not isUnder1H      // Weekly cloud hidden below 60 minutes

// ═══════════════════════════════════════════════════════════════
// 1️⃣ WEEKLY BASE (1W) - fixed, realtime cloud
// ═══════════════════════════════════════════════════════════════
tenkan_w  = request.security(syminfo.tickerid, "W", (ta.highest(high, tenkanPeriod) + ta.lowest(low, tenkanPeriod)) / 2)
kijun_w   = request.security(syminfo.tickerid, "W", (ta.highest(high, kijunPeriod) + ta.lowest(low, kijunPeriod)) / 2)
senkouB_w = request.security(syminfo.tickerid, "W", (ta.highest(high, senkouBPeriod) + ta.lowest(low, senkouBPeriod)) / 2)

leadingA_w = request.security(syminfo.tickerid, "W", (tenkan_w + kijun_w) / 2)
leadingB_w = request.security(syminfo.tickerid, "W", senkouB_w)

// Weekly EMAs (adjustable, fixed to 1W)
ema1_weekly = request.security(syminfo.tickerid, "W", ta.ema(close, ema1_period))
ema2_weekly = request.security(syminfo.tickerid, "W", ta.ema(close, ema2_period))

// ═══════════════════════════════════════════════════════════════
// 2️⃣ DAILY BASE (1D) - fixed, realtime cloud
// ═══════════════════════════════════════════════════════════════
tenkan_d  = request.security(syminfo.tickerid, "D", (ta.highest(high, tenkanPeriod) + ta.lowest(low, tenkanPeriod)) / 2)
kijun_d   = request.security(syminfo.tickerid, "D", (ta.highest(high, kijunPeriod) + ta.lowest(low, kijunPeriod)) / 2)
senkouB_d = request.security(syminfo.tickerid, "D", (ta.highest(high, senkouBPeriod) + ta.lowest(low, senkouBPeriod)) / 2)

leadingA_d = request.security(syminfo.tickerid, "D", (tenkan_d + kijun_d) / 2)
leadingB_d = request.security(syminfo.tickerid, "D", senkouB_d)

// ═══════════════════════════════════════════════════════════════
// PLOTS - WEEKLY CLOUD
// ═══════════════════════════════════════════════════════════════
plotA_w = plot(showWeekly ? leadingA_w : na, "Weekly Lead A", colorWeeklyA, 1, offset = cloudOffset, display = displayWeeklyLines)
plotB_w = plot(showWeekly ? leadingB_w : na, "Weekly Lead B", colorWeeklyB, 1, offset = cloudOffset, display = displayWeeklyLines)
fill(plotA_w, plotB_w,
     color = leadingA_w > leadingB_w ? color.new(colorFillW0, 85) : color.new(colorFillW1, 85))

// ═══════════════════════════════════════════════════════════════
// PLOTS - DAILY CLOUD
// ═══════════════════════════════════════════════════════════════
plotA_d = plot(showDaily ? leadingA_d : na, "Daily Lead A", colorDailyA, 1, offset = cloudOffset, display = plotDisplay)
plotB_d = plot(showDaily ? leadingB_d : na, "Daily Lead B", colorDailyB, 1, offset = cloudOffset, display = plotDisplay)
fill(plotA_d, plotB_d,
     color = leadingA_d > leadingB_d ? color.new(colorFillD0, 90) : color.new(colorFillD1, 90))

// ═══════════════════════════════════════════════════════════════
// PLOTS - WEEKLY EMAS (both dotted, fixed to 1W)
// ═══════════════════════════════════════════════════════════════
plot(ema1_weekly, "EMA1 Weekly", colorEMA1, 1, plot.style_line, linestyle = plot.linestyle_dotted, display = plotDisplay)
plot(ema2_weekly, "EMA2 Weekly", colorEMA2, 1, plot.style_line, linestyle = plot.linestyle_dotted, display = plotDisplay)
````
