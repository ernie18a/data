# TrendScope EMA Dashboard [CLEVER]

- url: https://www.tradingview.com/script/3nwV8vuc-TrendScope-EMA-Dashboard-CLEVER/
- type: indicator
- pine_id: PUB;9f5edc766ff2450bb145d1945da28a4e
- version: 1.0

## Description

📊 Overview of “TrendScope EMA Dashboard [CLEVER]”

This script is an advanced EMA-based multi-timeframe trend analysis system that helps traders understand overall market direction using Fast, Medium, Slow, and Long EMAs. It is designed to simplify trend identification by showing whether the market is in a strong uptrend, downtrend, or sideways phase across different timeframes.

It visually enhances chart analysis using a color-coded structure. Uptrend, downtrend, and sideways conditions are clearly highlighted, making it easier to read market sentiment at a glance without complex manual analysis. This improves decision-making speed and clarity during trading.

The script also generates buy and sell signals when strong EMA alignment or trend shifts occur. In addition, it detects sideways market conditions to help traders avoid low-quality or uncertain market phases where false signals are more common.

A key feature is its multi-timeframe dashboard, which displays trend status from lower timeframes like 1-minute and 5-minute up to higher timeframes such as 1-hour, 4-hour, and daily charts. This gives traders a complete market overview and helps confirm trades based on higher timeframe direction.

Overall, this is a structured trend-following indicator built for educational and analytical purposes. It supports traders in understanding market structure more clearly, but it is not a guaranteed profit system and should always be used with proper risk management.

🧠 Core Concept 

This script is built on a multi-layer EMA trend structure, where the core idea is to analyze market direction through the alignment of four exponential moving averages: Fast (9), Medium (21), Slow (50), and Long (200). The main logic is simple but powerful — when these EMAs are perfectly stacked in order (fast above medium above slow above long), the market is considered in a strong bullish trend, and the opposite stacking indicates a bearish trend. Any disruption in this alignment signals a transition or uncertainty phase.

A key concept of this system is trend hierarchy confirmation. Instead of relying on a single timeframe, it compares trends across multiple timeframes (from 1-minute to daily). This ensures that trades are not based on isolated signals but are aligned with broader market structure. The idea is to trade with the dominant trend rather than against it, reducing noise and improving probability-based decision making.

Another important concept is market state classification. The script does not only show buy or sell signals, but also categorizes the market into three states: uptrend, downtrend, and sideways. The sideways condition is especially important because it represents consolidation or indecision, where most false breakouts occur. By identifying this phase, the system helps avoid low-quality trades.

The signal generation logic is based on trend transition detection, meaning signals are triggered when the EMA structure changes from one state to another rather than continuously firing. This reduces overtrading and focuses only on meaningful market shifts. Along with this, visual coloring of candles, EMAs, and background reinforces emotional clarity, allowing traders to quickly interpret market behavior.

At a deeper level, this script follows a probability and structure-based trading philosophy, not prediction. It assumes that trends persist until broken and that higher timeframe direction has more weight than lower timeframe noise. Therefore, it is designed as a decision-support tool that enhances analysis, not as a standalone guaranteed system.

Overall, the core concept is to combine EMA structure + multi-timeframe confirmation + market state filtering into one unified framework that helps traders stay aligned with institutional-style trend flow while reducing emotional and random trading decisions.

⚙️ Key Features

⚙️ 1. EMA Structure (Core Trend Engine)

This script is built on a 4-layer EMA system (9, 21, 50, 200) which defines the core market structure. When these EMAs are perfectly aligned in order, the market is considered in a strong trend. If the alignment breaks, it signals weakness or possible trend change. This layered structure works as the foundation of the entire indicator.

📊 2. Trend Detection System

The script continuously analyzes EMA alignment to classify the market into three states: uptrend, downtrend, and sideways. This classification helps traders clearly understand whether the market is trending or consolidating. Sideways detection is especially important to avoid low-quality or uncertain market conditions.

⚡ 3. Signal Generation Logic

Buy and sell signals are generated only when there is a clear transition in trend structure, not randomly. For example, signals appear when the market shifts from sideways to trending or reverses direction. This makes the system more selective and reduces unnecessary trades caused by noise.

🌐 4. Multi-Timeframe Analysis

A key feature is the multi-timeframe dashboard that shows trend conditions from 1-minute up to daily charts. This allows traders to understand both short-term and long-term market direction at the same time. It helps ensure that entries are aligned with higher timeframe bias.

🎨 5. Visual Trend Mapping

The script uses color-coded visuals for EMAs, candles, and background to represent market direction. This makes trend reading faster and more intuitive. Traders can instantly see whether the market is bullish, bearish, or sideways without deep technical analysis.

📈 6. Dashboard & Signal Tracking

A structured dashboard displays trend status across multiple timeframes along with counts of bullish and bearish signals. This gives a clear overview of market behavior and helps traders track performance and consistency of trend conditions.

🧠 7. Core Trading Philosophy

The system follows a trend-following, probability-based approach rather than prediction. It assumes that trends continue until broken and prioritizes alignment with the dominant market direction. The goal is to support disciplined decision-making, not to guarantee outcomes.

 HOW ITS WORK

⚙️ 1. Data Input & Price Tracking System
This script continuously reads live market price (open, high, low, close) and volume data. Every new candle updates the system in real time. The purpose is to keep analysis dynamic so the trend is always based on the latest market behavior instead of old data.

📊 2. EMA-Based Core Calculation Logic
It calculates four exponential moving averages (Fast 9, Medium 21, Slow 50, Long 200). These EMAs smooth price action and remove noise. The relationship between them forms the base structure of the system, which defines whether momentum is strong, weak, or transitioning.

📉 3. Market Structure Detection System
The script checks EMA alignment to identify structure. If EMAs are stacked in upward order, it confirms bullish structure. If stacked downward, it confirms bearish structure. If EMAs are mixed or broken, it marks the market as sideways or indecisive.

🚦 4. Trend State Engine (Classification Logic)
Based on EMA structure, the market is classified into three states: uptrend, downtrend, or sideways. This classification updates every candle, ensuring the system reacts instantly to market changes and avoids confusion during consolidation phases.

⚡ 5. Signal Trigger Mechanism
Buy and sell signals are not random; they trigger only when the market transitions from one structured state to another. For example, a buy signal appears when the system confirms a shift into a new uptrend phase. This reduces noise and improves signal quality.

🌐 6. Multi-Timeframe Confirmation Layer
The script applies the same EMA logic across multiple timeframes (1m, 5m, 15m, 1H, 4H, 1D). This allows comparison between short-term and long-term trends. When multiple timeframes agree, trend confidence becomes stronger.

🎨 7. Visual Mapping & Color Intelligence System
All trends are displayed using colors for EMAs, candles, and background. This visual system helps traders instantly understand market direction without deep technical analysis. Uptrend, downtrend, and sideways phases are clearly separated.

📈 8. Dashboard Monitoring & Performance Tracking
A built-in dashboard shows real-time trend status across all timeframes along with signal counts. This gives a complete overview of market behavior in one place, making it easier to track structure, momentum, and consistency.

🧠 9. Core Trading Philosophy (House Rule Logic)
The system follows a strict trend-following and probability-based logic. It assumes that trends continue until broken and prioritizes higher timeframe direction over lower timeframe noise. It is designed for structured decision-making, not prediction or guaranteed outcomes.

HOW TO USED

🧠 1. Understand the Core Structure Before Using
This indicator is built on EMA alignment logic (9, 21, 50, 200). Before using it, you must understand that it does not predict the market — it only shows trend structure. Your first rule is: only trade when EMAs are clearly aligned, not when they are mixed or flat.

📊 2. Use Trend Direction as Primary Filter
The main rule is to always follow the trend shown by the EMAs. If the system shows an uptrend, you only look for buy opportunities. If it shows a downtrend, you only look for sell opportunities. In sideways conditions, you should avoid trading because the system is indicating market confusion or consolidation.

⚡ 3. Take Signals Only on Trend Transition
Buy and sell signals are strongest when the market changes structure, not when it is already moving. For example, a buy signal after sideways turning into uptrend is stronger than a signal in an already running trend. This reduces false entries and improves quality.

🌐 4. Confirm with Multi-Timeframe Alignment
Before entering any trade, check the dashboard. If higher timeframes (1H, 4H, 1D) agree with lower timeframe direction, the trade is stronger. If timeframes conflict, you should avoid trading or reduce risk. Higher timeframe trend always has more weight.

🎨 5. Use Visual Cues for Fast Decisions
Use the colors of EMAs, candles, and background as quick market guidance. Bright bullish colors mean strong buying pressure, while bearish colors show selling pressure. Sideways colors indicate no clear direction — this is where patience is required.

📈 6. Risk Management is Mandatory Rule
This system is not a guaranteed profit tool. Always use proper stop loss and fixed risk per trade. Never rely only on signals. Even strong trends can fail, so risk control is a non-negotiable rule in this system.

🧠 7. Avoid Overtrading Condition
One of the key rules is patience. Do not take every signal. Only trade when:


Trend is clear


Timeframes are aligned


Market is not sideways
If conditions are not perfect, staying out is also a valid trade decision.



🏁 8. Final House Rule (Most Important)
This system works best when used as a trend confirmation tool, not a prediction tool. Follow structure, respect higher timeframe direction, and only act when market conditions are clean. Discipline matters more than signals in this system.

 Settings & Customization

⚙️ 1. Moving Average Settings (Core Behavior Control)
The most important customization in this script is the EMA lengths (9, 21, 50, 200). These settings control how fast or slow the system reacts. If you lower the lengths, the indicator becomes more sensitive and gives faster signals but with more noise. If you increase them, the system becomes slower but more stable and reliable. This setting directly defines the trading style (scalping, intraday, or swing).

🎨 2. Visual Theme Customization (Market Readability)
The color settings allow you to control how the market structure is visually displayed. You can adjust bullish, bearish, and sideways colors according to your preference. This does not change logic, but it improves clarity. Traders often customize colors to make trend direction easier to see at a glance and reduce chart confusion during fast market movement.

⚡ 3. Signal Appearance Settings (Trade Visibility Control)
Signal customization allows you to control how buy and sell markers appear on the chart. You can change size, color, and visibility style. This helps you avoid clutter if you prefer a clean chart, or make signals more visible if you rely heavily on visual entries. However, signal logic remains unchanged regardless of appearance settings.

🌐 4. Multi-Timeframe Dashboard Configuration
The dashboard section can be enabled or disabled depending on your trading style. If enabled, it shows trend status across multiple timeframes. This feature is important for confirmation trading. Advanced users often keep it on, while minimal traders may turn it off for a cleaner interface.

📊 5. Volume & Background Settings
The volume-based background feature helps highlight market pressure. You can adjust intensity or disable it completely. Higher intensity makes trend background more visible, while lower intensity keeps the chart clean. This setting is useful for traders who want extra confirmation of momentum without using additional indicators.

🚦 6. Trend Sensitivity Adjustment (Indirect Control)
Although there is no direct “signal sensitivity” button, EMA lengths indirectly control sensitivity. Short EMAs = fast signals, long EMAs = slow confirmation. This is the most important hidden customization rule. Always adjust EMAs based on market volatility and your trading timeframe.

🧠 7. Safe Customization Rule (House Rule)
Never change settings randomly. Every adjustment must follow a purpose: either to increase clarity, reduce noise, or match your trading style. Over-customization can break system consistency. The safest approach is to change one setting at a time and observe its effect before making further adjustments.

🏁 8. Final Customization Philosophy
This system is designed to be flexible but structured. The goal of customization is not to “improve signals blindly” but to match the indicator with your trading behavior. Keep logic stable, adjust only visualization and sensitivity, and always test before using in real trading conditions.

🔗 1. What “Mashup Combine” Means in This Script

“Mashup combine” here means the fusion of multiple trading layers into one system. Instead of using only one indicator (like EMA or volume alone), this script combines EMA structure + trend states + multi-timeframe analysis + visual mapping + dashboard tracking into a single unified framework. The goal is to reduce confusion and give one clear market view.

📊 2. EMA Structure + Trend Logic Merge

The first combination is between four EMAs (9, 21, 50, 200) and trend classification logic. EMAs create the raw structure, while the logic converts that structure into readable states (uptrend, downtrend, sideways). This mashup turns raw price data into a structured trend decision system instead of just lines on a chart.

🌐 3. Multi-Timeframe + Single Trend System Merge

Another important combine is multiple timeframe analysis (1m to 1D) with the same EMA rules. This means every timeframe is calculated separately but displayed together in one dashboard. This mashup helps you see both micro trends and macro trend direction at the same time, creating a full market perspective.

🎨 4. Visual Layer + Logic Layer Fusion

The script also combines technical logic with visual intelligence. EMAs, candles, and background colors are not just decoration — they are directly linked to trend states. So when logic changes, visuals automatically change. This mashup makes the system readable without needing deep analysis every time.

⚡ 5. Signals + Trend Transition Combine

Buy and sell signals are not independent; they are combined with trend state changes. This means signals only appear when structure changes (not random price movement). This mashup connects “trend detection” with “entry timing”, making signals more meaningful and filtered.

📈 6. Dashboard + Real-Time Market Combine

The dashboard is another mashup layer where live EMA states + multi-timeframe trends + signal counts are combined in one table. Instead of analyzing multiple charts separately, everything is merged into a single view for faster decision-making.

🧠 7. Final Core Idea of Mashup System

The main idea of this mashup system is confluence through combination. Instead of relying on one signal type, it combines structure (EMA), direction (trend), timing (signals), confirmation (multi-timeframe), and readability (visuals). This reduces randomness and creates a more disciplined trading environment.

🏁 8. Final House Rule (Most Important)

This mashup only works properly when you understand that no single part is enough alone. Real strength comes when all layers agree together: EMA alignment + timeframe confirmation + trend state + visual clarity. If any layer conflicts, you reduce risk or avoid trade.

🏁 Final Note (Deep House Rules — Safe Summary)
This EMA Trend Dashboard system is designed as a structured, probability-based trading tool that helps you read market direction using EMA alignment, trend states, and multi-timeframe confirmation. Its core purpose is not to predict the market, but to filter price action into clear conditions so you can trade only when the structure is strong and meaningful. The most important rule is discipline—always follow the trend shown by EMA alignment, respect higher timeframe direction, and avoid trading during sideways or unclear market conditions. Signals should only be considered as trend transition confirmations, not random entry points, and every decision must be supported by proper risk management. In simple terms, this system only works effectively when you wait for full confluence—trend, structure, and timeframe all agreeing together—and avoid forcing trades when the market does not present a clean setup.

⚠️ Disclaimer 

This trading indicator is developed for educational and informational purposes only and should not be considered financial advice or a guaranteed profit system. It is based on EMA (Exponential Moving Average) trend logic and multi-timeframe analysis, which are probabilistic in nature and can lag or produce false signals in fast or volatile market conditions. The market is unpredictable, and no indicator can ensure accuracy, consistency, or profitability in all situations.

Users are fully responsible for their own trading decisions. This tool should only be used as a support system for analysis and decision-making, not as a standalone trading strategy. Proper risk management, including stop-loss usage, position sizing, and capital protection, is essential at all times. Over-reliance on signals or ignoring market conditions can lead to financial loss.

Past performance or trend signals do not guarantee future results. Market behavior can change suddenly due to news, volatility, or liquidity shifts. Always test the system on demo accounts before using real funds, and ensure it fits your personal trading style and risk tolerance.

By using this script, you acknowledge that trading involves risk, and you accept full responsibility for any outcomes.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TheCleverTraders

//@version=5
indicator("TrendScope EMA Dashboard [CLEVER]", overlay=true, max_lines_count=500, max_labels_count=500)

// Disclaimer:
// This script is for educational purposes only.
// It does not provide financial advice.
// Signals are based on EMA trend logic and do not guarantee results.
// Signals are based on EMA alignment and may lag in fast market conditions.
// Use proper risk management before trading.

// ======================
// Input Parameters
// ======================

// --- Moving Averages ---
grp_ma = "📊 Moving Averages"
fastLength = input.int(9, "Fast EMA Length", minval=1, group=grp_ma)
medLength  = input.int(21, "Medium EMA Length", minval=1, group=grp_ma)
slowLength = input.int(50, "Slow EMA Length", minval=1, group=grp_ma)
longLength = input.int(200, "Long EMA Length", minval=1, group=grp_ma)

// --- Visual Theme & Colors ---
grp_visual = "🎨 Visual Theme & Colors"
upTrendColor        = input.color(color.rgb(2, 251, 255), "Up Trend Color", group=grp_visual)
downTrendColor      = input.color(color.rgb(217, 0, 250), "Down Trend Color", group=grp_visual)
sidewaysTrendColor  = input.color(color.yellow, "Sideways Color", group=grp_visual)
colorBarsByTrend    = input.bool(true, "Color Price Bars by Trend", group=grp_visual)
trendBarTransparency = input.int(0, "Bar Color Transparency", minval=0, maxval=100, group=grp_visual)
colorEMAsByTrend    = input.bool(true, "Color EMAs by Trend", group=grp_visual)
showVolume          = input.bool(true, "Show Volume-Based Background", group=grp_visual)
bgIntensity         = input.int(90, "Background Intensity (%)", minval=0, maxval=100, group=grp_visual, tooltip="Higher = More Transparent")
colorVolumeBgByTrend = input.bool(true, "Color Volume BG by Trend", group=grp_visual)

// --- Signal Settings ---
grp_signals = "⚡ Signal Aesthetics"
useRejectionFilter  = input.bool(true, "Require EMA Alignment for Signals", group=grp_signals)
showSidewaysFromUpArrow = input.bool(true, "Show 'SIDE' After Up Trend", group=grp_signals)
showSidewaysFromDownArrow = input.bool(true, "Show 'SIDE' After Down Trend", group=grp_signals)
buy_col      = input.color(color.rgb(7, 251, 255, 30), "Buy Marker Color", inline="Buy", group=grp_signals)
buy_txt_col  = input.color(color.white, "Text", inline="Buy", group=grp_signals)
sell_col     = input.color(color.rgb(217, 5, 250, 30), "Sell Marker Color", inline="Sell", group=grp_signals)
sell_txt_col = input.color(color.white, "Text", inline="Sell", group=grp_signals)

// --- Dashboard Settings ---
grp_dash = "📈 Dashboard Settings"
showDashboard = input.bool(true, "Show Trend Dashboard", group=grp_dash)
dashPos       = input.string("Top Right", "Dashboard Position", options=["Top Right", "Bottom Right", "Top Left", "Bottom Left", "Bottom Center"], group=grp_dash)
useThemeColorsForPoints = input.bool(true, "Apply Theme Colors to Dashboard", group=grp_dash)

// Internal conversion for dashboard position
getDashPos(pos) =>
    pos == "Top Right" ? position.top_right :
     pos == "Bottom Right" ? position.bottom_right :
     pos == "Top Left" ? position.top_left :
     pos == "Bottom Left" ? position.bottom_left :
     position.bottom_center

volumeLength = 20

// ======================
// Calculations
// ======================

// Moving Averages
fastMA = ta.ema(close, fastLength)
medMA = ta.ema(close, medLength)
slowMA = ta.ema(close, slowLength)
longMA = ta.ema(close, longLength)

// Volume
volMA = ta.sma(volume, volumeLength)
volColor = close > close[1] ? color.green : color.red

// Trend Detection
trendUp = fastMA > medMA and medMA > slowMA and slowMA > longMA
trendDown = fastMA < medMA and medMA < slowMA and slowMA < longMA

sidewaysTrend = not trendUp and not trendDown
sidewaysStart = sidewaysTrend and not sidewaysTrend[1]
sidewaysFromUpStart = sidewaysStart and trendUp[1]
sidewaysFromDownStart = sidewaysStart and trendDown[1]

buySignal  = trendUp and not trendUp[1]
sellSignal = trendDown and not trendDown[1]
var int buyTrades = 0
var int sellTrades = 0
if buySignal
    buyTrades += 1
if sellSignal
    sellTrades += 1
// ======================
// Plots
// ======================

// Moving Averages
fastColor = colorEMAsByTrend ? (trendUp ? upTrendColor : trendDown ? downTrendColor : sidewaysTrendColor) : color.blue
medColor  = colorEMAsByTrend ? (trendUp ? upTrendColor : trendDown ? downTrendColor : sidewaysTrendColor) : color.orange
slowColor = colorEMAsByTrend ? (trendUp ? upTrendColor : trendDown ? downTrendColor : sidewaysTrendColor) : color.purple
longColor = colorEMAsByTrend ? (trendUp ? upTrendColor : trendDown ? downTrendColor : sidewaysTrendColor) : color.red

plot(fastMA, "Fast EMA", color=fastColor, linewidth=2)
plot(medMA,  "Medium EMA", color=medColor,  linewidth=2)
plot(slowMA, "Slow EMA", color=slowColor, linewidth=2)
plot(longMA, "Long EMA", color=longColor, linewidth=2)

// Volume
trendBarUpColor   = color.new(upTrendColor, trendBarTransparency)
trendBarDownColor = color.new(downTrendColor, trendBarTransparency)
trendBarSideColor = color.new(sidewaysTrendColor, trendBarTransparency)
trendBarColor     = trendUp ? trendBarUpColor : trendDown ? trendBarDownColor : trendBarSideColor
barcolor(colorBarsByTrend ? trendBarColor : na, title="Trend Bar Color")
volumeBgTrendColor   = trendUp ? color.new(upTrendColor, bgIntensity) : trendDown ? color.new(downTrendColor, bgIntensity) : color.new(sidewaysTrendColor, bgIntensity)
volumeBgDefaultColor = close > close[1] ? color.new(color.green, bgIntensity) : color.new(color.red, bgIntensity)
volumeBgColor        = colorVolumeBgByTrend ? volumeBgTrendColor : volumeBgDefaultColor
bgcolor(showVolume ? volumeBgColor : na, title="Volume Background")

plotshape(buySignal,  title="Buy Signal",  style=shape.triangleup, location=location.belowbar, color=buy_col, size=size.small,  text="BUY", textcolor=buy_txt_col)
plotshape(sellSignal, title="Sell Signal", style=shape.triangledown, location=location.abovebar, color=sell_col, size=size.small,  text="SELL", textcolor=sell_txt_col)

sidewaysArrowColor = useThemeColorsForPoints ? sidewaysTrendColor : color.orange
plotshape(showSidewaysFromUpArrow and sidewaysFromUpStart, title="Sideways Signal (from Up)", style=shape.arrowdown, location=location.abovebar, color=sidewaysArrowColor, size=size.tiny, text="SIDE", textcolor=sidewaysArrowColor)
plotshape(showSidewaysFromDownArrow and sidewaysFromDownStart, title="Sideways Signal (from Down)", style=shape.arrowup, location=location.belowbar, color=sidewaysArrowColor, size=size.tiny, text="SIDE", textcolor=sidewaysArrowColor)

alertcondition(buySignal,  title="EMA Trend Signal (Bullish)",  message="EMA Trend Condition: Bullish")
alertcondition(sellSignal, title="EMA Trend Signal (Bearish)", message="EMA Trend Condition: Bearish")

emaTrendLabel(isUp, isDown) =>
    isUp ? "UP" : isDown ? "DOWN" : "SIDE"

emaTrendColor(isUp, isDown) =>
    up   = useThemeColorsForPoints ? upTrendColor : color.lime
    down = useThemeColorsForPoints ? downTrendColor : color.red
    side = useThemeColorsForPoints ? sidewaysTrendColor : color.orange
    isUp ? up : isDown ? down : side

fastEmaUp = fastMA > fastMA[1]
fastEmaDown = fastMA < fastMA[1]
medEmaUp = medMA > medMA[1]
medEmaDown = medMA < medMA[1]
slowEmaUp = slowMA > slowMA[1]
slowEmaDown = slowMA < slowMA[1]
longEmaUp = longMA > longMA[1]
longEmaDown = longMA < longMA[1]

fastEmaLabel = emaTrendLabel(fastEmaUp, fastEmaDown)
fastEmaColor = emaTrendColor(fastEmaUp, fastEmaDown)
medEmaLabel = emaTrendLabel(medEmaUp, medEmaDown)
medEmaColor = emaTrendColor(medEmaUp, medEmaDown)
slowEmaLabel = emaTrendLabel(slowEmaUp, slowEmaDown)
slowEmaColor = emaTrendColor(slowEmaUp, slowEmaDown)
longEmaLabel = emaTrendLabel(longEmaUp, longEmaDown)
longEmaColor = emaTrendColor(longEmaUp, longEmaDown)

fastMA_D = request.security(syminfo.tickerid, "D", ta.ema(close, fastLength))
medMA_D = request.security(syminfo.tickerid, "D", ta.ema(close, medLength))
slowMA_D = request.security(syminfo.tickerid, "D", ta.ema(close, slowLength))
longMA_D = request.security(syminfo.tickerid, "D", ta.ema(close, longLength))
trendUp_D = fastMA_D > medMA_D and medMA_D > slowMA_D and slowMA_D > longMA_D
trendDown_D = fastMA_D < medMA_D and medMA_D < slowMA_D and slowMA_D < longMA_D
trendLabel_D = emaTrendLabel(trendUp_D, trendDown_D)
trendColor_D = emaTrendColor(trendUp_D, trendDown_D)

fastMA_4H = request.security(syminfo.tickerid, "240", ta.ema(close, fastLength))
medMA_4H = request.security(syminfo.tickerid, "240", ta.ema(close, medLength))
slowMA_4H = request.security(syminfo.tickerid, "240", ta.ema(close, slowLength))
longMA_4H = request.security(syminfo.tickerid, "240", ta.ema(close, longLength))
trendUp_4H = fastMA_4H > medMA_4H and medMA_4H > slowMA_4H and slowMA_4H > longMA_4H
trendDown_4H = fastMA_4H < medMA_4H and medMA_4H < slowMA_4H and slowMA_4H < longMA_4H
trendLabel_4H = emaTrendLabel(trendUp_4H, trendDown_4H)
trendColor_4H = emaTrendColor(trendUp_4H, trendDown_4H)

fastMA_1H = request.security(syminfo.tickerid, "60", ta.ema(close, fastLength))
medMA_1H = request.security(syminfo.tickerid, "60", ta.ema(close, medLength))
slowMA_1H = request.security(syminfo.tickerid, "60", ta.ema(close, slowLength))
longMA_1H = request.security(syminfo.tickerid, "60", ta.ema(close, longLength))
trendUp_1H = fastMA_1H > medMA_1H and medMA_1H > slowMA_1H and slowMA_1H > longMA_1H
trendDown_1H = fastMA_1H < medMA_1H and medMA_1H < slowMA_1H and slowMA_1H < longMA_1H
trendLabel_1H = emaTrendLabel(trendUp_1H, trendDown_1H)
trendColor_1H = emaTrendColor(trendUp_1H, trendDown_1H)

fastMA_15m = request.security(syminfo.tickerid, "15", ta.ema(close, fastLength))
medMA_15m = request.security(syminfo.tickerid, "15", ta.ema(close, medLength))
slowMA_15m = request.security(syminfo.tickerid, "15", ta.ema(close, slowLength))
longMA_15m = request.security(syminfo.tickerid, "15", ta.ema(close, longLength))
trendUp_15m = fastMA_15m > medMA_15m and medMA_15m > slowMA_15m and slowMA_15m > longMA_15m
trendDown_15m = fastMA_15m < medMA_15m and medMA_15m < slowMA_15m and slowMA_15m < longMA_15m
trendLabel_15m = emaTrendLabel(trendUp_15m, trendDown_15m)
trendColor_15m = emaTrendColor(trendUp_15m, trendDown_15m)

fastMA_5m = request.security(syminfo.tickerid, "5", ta.ema(close, fastLength))
medMA_5m = request.security(syminfo.tickerid, "5", ta.ema(close, medLength))
slowMA_5m = request.security(syminfo.tickerid, "5", ta.ema(close, slowLength))
longMA_5m = request.security(syminfo.tickerid, "5", ta.ema(close, longLength))
trendUp_5m = fastMA_5m > medMA_5m and medMA_5m > slowMA_5m and slowMA_5m > longMA_5m
trendDown_5m = fastMA_5m < medMA_5m and medMA_5m < slowMA_5m and slowMA_5m < longMA_5m
trendLabel_5m = emaTrendLabel(trendUp_5m, trendDown_5m)
trendColor_5m = emaTrendColor(trendUp_5m, trendDown_5m)

fastMA_1m = request.security(syminfo.tickerid, "1", ta.ema(close, fastLength))
medMA_1m = request.security(syminfo.tickerid, "1", ta.ema(close, medLength))
slowMA_1m = request.security(syminfo.tickerid, "1", ta.ema(close, slowLength))
longMA_1m = request.security(syminfo.tickerid, "1", ta.ema(close, longLength))
trendUp_1m = fastMA_1m > medMA_1m and medMA_1m > slowMA_1m and slowMA_1m > longMA_1m
trendDown_1m = fastMA_1m < medMA_1m and medMA_1m < slowMA_1m and slowMA_1m < longMA_1m
trendLabel_1m = emaTrendLabel(trendUp_1m, trendDown_1m)
trendColor_1m = emaTrendColor(trendUp_1m, trendDown_1m)

var table trendTable = table.new(getDashPos(dashPos), 2, 13, frame_color=color.white, frame_width=1, border_color=color.gray, border_width=1)

if barstate.isfirst and showDashboard
    table.cell(trendTable, 0, 0, "Item", text_color=color.white, text_size=size.normal)
    table.cell(trendTable, 1, 0, "Value", text_color=color.white, text_size=size.normal)

if showDashboard
    table.cell(trendTable, 0, 1, "Fast EMA", text_color=color.white, text_size=size.normal)
    table.cell(trendTable, 1, 1, fastEmaLabel, text_color=fastEmaColor, text_size=size.normal)
    table.cell(trendTable, 0, 2, "Medium EMA", text_color=color.white, text_size=size.normal)
    table.cell(trendTable, 1, 2, medEmaLabel, text_color=medEmaColor, text_size=size.normal)
    table.cell(trendTable, 0, 3, "Slow EMA", text_color=color.white, text_size=size.normal)
    table.cell(trendTable, 1, 3, slowEmaLabel, text_color=slowEmaColor, text_size=size.normal)
    table.cell(trendTable, 0, 4, "Long EMA", text_color=color.white, text_size=size.normal)
    table.cell(trendTable, 1, 4, longEmaLabel, text_color=longEmaColor, text_size=size.normal)
    
    table.cell(trendTable, 0, 5, "Bullish Signals", text_color=useThemeColorsForPoints ? upTrendColor : color.lime, text_size=size.normal)
    table.cell(trendTable, 1, 5, str.tostring(buyTrades), text_color=useThemeColorsForPoints ? upTrendColor : color.lime, text_size=size.normal)
    table.cell(trendTable, 0, 6, "Bearish Signals", text_color=useThemeColorsForPoints ? downTrendColor : color.red, text_size=size.normal)
    table.cell(trendTable, 1, 6, str.tostring(sellTrades), text_color=useThemeColorsForPoints ? downTrendColor : color.red, text_size=size.normal)
    
    table.cell(trendTable, 0, 7, "Trend 1D", text_color=color.white, text_size=size.normal)
    table.cell(trendTable, 1, 7, trendLabel_D, text_color=trendColor_D, text_size=size.normal)
    table.cell(trendTable, 0, 8, "Trend 4H", text_color=color.white, text_size=size.normal)
    table.cell(trendTable, 1, 8, trendLabel_4H, text_color=trendColor_4H, text_size=size.normal)
    table.cell(trendTable, 0, 9, "Trend 1H", text_color=color.white, text_size=size.normal)
    table.cell(trendTable, 1, 9, trendLabel_1H, text_color=trendColor_1H, text_size=size.normal)
    table.cell(trendTable, 0, 10, "Trend 15m", text_color=color.white, text_size=size.normal)
    table.cell(trendTable, 1, 10, trendLabel_15m, text_color=trendColor_15m, text_size=size.normal)
    table.cell(trendTable, 0, 11, "Trend 5m", text_color=color.white, text_size=size.normal)
    table.cell(trendTable, 1, 11, trendLabel_5m, text_color=trendColor_5m, text_size=size.normal)
    table.cell(trendTable, 0, 12, "Trend 1m", text_color=color.white, text_size=size.normal)
    table.cell(trendTable, 1, 12, trendLabel_1m, text_color=trendColor_1m, text_size=size.normal)
````
