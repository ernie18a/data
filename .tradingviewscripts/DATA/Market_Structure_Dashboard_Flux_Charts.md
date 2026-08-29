<!-- tradingview-pine-id: PUB;20572cf632f4435b9eb2a5551b4f5768 -->
<!-- tradingviewscripts-format: 1 -->
# Market Structure Dashboard | Flux Charts

Source: https://www.tradingview.com/script/vXui7vrm-Market-Structure-Dashboard-Flux-Charts/

## Description

GENERAL OVERVIEW
Market Structure Dashboard is a multi-timeframe market structure analysis indicator. It combines EMA trend detection, swing high/low tracking, market structure labels, Order Block detection, Fair Value Gap detection, liquidity sweep detection, volume analysis, volatility analysis, trading sessions, ICT killzones, a weighted trend bias system, and HTF levels into one unified dashboard. Each component is calculated independently across up to 7 configurable timeframes and displayed together in a single organized view.
https://www.tradingview.com/x/fEiIGQuW/ (Screenshot: Full dashboard overview - all sections visible)
https://www.tradingview.com/x/AdTvRgJO/ (Screenshot: Dashboard on a busy chart showing OB/FVG boxes, swing labels, HTF lines)

WHAT IS THE THEORY BEHIND THIS INDICATOR?
The core idea is that a trade setup becomes more reliable when multiple timeframes agree on direction. A bullish signal on a 5-minute chart carries more weight when the 15-minute, 1-hour, and daily timeframes also show bullish conditions. Analyzing each timeframe separately is both time-consuming and prone to error. The Market Structure Dashboard automates this process by calculating key metrics across all enabled timeframes and presenting them side by side.
The indicator draws from two established trading methodologies. Smart Money Concepts (SMC) focuses on identifying institutional footprints in price action through patterns like Order Blocks, Fair Value Gaps, and liquidity sweeps. Inner Circle Trader (ICT) methodology emphasizes time-based analysis through specific trading windows called killzones and the importance of previous day, week, and month highs and lows.

Rather than treating these concepts in isolation, the dashboard organizes them into a layered framework. Structure shows where the market has been. Zones show where it may react. Sessions and killzones show when activity tends to increase. The trend bias system combines all factors into a single weighted score, giving traders a quick read on overall market sentiment across timeframes.

The purpose of the Market Structure Dashboard is to present the current market activity across multiple timeframes and how these conditions relate to earlier market structure, volume, and timing.
https://www.tradingview.com/x/CwHOi6rG/ (Screenshot:  Multi-timeframe confluence example - all TFs showing bearish alignment)
https://www.tradingview.com/x/VcRl6bYw/ (Screenshot: Multi-timeframe disagreement example - mixed signals across TFs)

MARKET STRUCTURE DASHBOARD FEATURES
The Market Structure Dashboard indicator includes 14 main features:

[*]EMA Trend Detection
[*]Swing High/Low Tracking
[*]Market Structure Labels (HH/HL/LH/LL)
[*]Order Block Detection
[*]Fair Value Gap Detection
[*]Liquidity Sweep & Reclaim Detection
[*]Volume Analysis
[*]Volatility Analysis
[*]Trading Sessions
[*]ICT Killzones
[*]Trend Bias System
[*]HTF Levels (PDH/L, PWH/L, PMH/L)
[*]Visual Overlays
[*]Dashboard Customization

Each component operates independently while sharing the same underlying market structure logic. All features are calculated across up to 7 user-configurable timeframes and displayed in a unified dashboard. Detailed explanations for each component are provided in the sections that follow.

EMA TREND DETECTION
🔹 What is an EMA? 
An Exponential Moving Average (EMA) is a type of moving average that gives more weight to recent price data. Unlike a Simple Moving Average that weights all prices equally, the EMA responds faster to recent price changes while still considering historical data. Traders use EMAs to identify trend direction and dynamic support/resistance levels.

When price trades above the EMA, the short-term trend is considered bullish. When price trades below the EMA, the short-term trend is considered bearish. The distance between price and EMA can indicate trend strength, with larger distances suggesting stronger momentum.

🔹 How the Indicator Uses EMA
The dashboard calculates a 9-period EMA (configurable) for each enabled timeframe. The EMA Trend column displays both direction and distance.

◇ Direction is shown with an up arrow (↑) when price is above EMA, or a down arrow (↓) when price is below EMA.

◇ Distance is displayed as percentage, price, or pips based on the Distance Display setting. For example, "+0.45% ↑" means price is 0.45% above the EMA on that timeframe.

◇ Color coding shows green when price is above EMA (bullish) and red when price is below EMA (bearish).

The EMA can optionally be plotted as a visual overlay on the chart. It can also be included as a factor in the Trend Bias calculation, where each timeframe's EMA direction contributes to the overall bias score.
https://www.tradingview.com/x/ElVYVgws/ (Screenshot: EMA column showing bearish readings - red, ↓)

SWING HIGH/LOW TRACKING
🔹 What are Swing Highs and Lows?
 A swing high is a price peak where a candle's high is higher than the highs of surrounding candles. A swing low is a price trough where a candle's low is lower than the lows of surrounding candles. These points represent short-term reversals and define the boundaries of price movement.

Swing points are foundational to market structure analysis. Breaking a swing high suggests bullish momentum. Breaking a swing low suggests bearish momentum. The sequence of swing points creates market structure patterns that reveal trend direction.

🔹 How the Indicator Tracks Swing Highs/Lows?
The indicator detects swing points using a configurable Swing Length parameter (default: 5). A swing high is confirmed when a candle's high is higher than the specified number of candles on both sides. A swing low is confirmed when a candle's low is lower than the specified number of candles on both sides. This confirmation requirement means swing points are identified with a delay, ensuring they are valid pivots rather than temporary spikes. This same Swing Length setting is also used by Order Block detection and Market Structure labels, so adjusting it affects all three features.

◇ The Swing H/L column displays a visual position indicator showing where price sits within the current swing range. A dot moves along a bar between L (swing low) and H (swing high) to show exact position.

◇ When price breaks outside the range, arrows indicate the direction. An up arrow (↑) appears when price breaks above the swing high. A swing high break indicates that buyers have pushed price beyond the previous peak, suggesting bullish momentum and a potential continuation higher.
https://www.tradingview.com/x/jufBABKy/ (Screenshot: Price above Swing High)

A down arrow (↓) appears when price breaks below the swing low. A swing low break indicates that sellers have pushed price beyond the previous trough, suggesting bearish momentum and a potential continuation lower
https://www.tradingview.com/x/WJG4zmyW/ (Screenshot: Price breaks Swing Low)

When a liquidity sweep occurs (price breaks a level then reclaims it), special arrows appear: ⤴ for a swept and reclaimed low, ⤵ for a swept and reclaimed high. A swept and reclaimed swing means price broke beyond the level, likely triggering stop-loss orders resting beyond it, but then reversed back inside the range. This suggests the breakout was a false move and the opposite direction may follow. Liquidity sweeps are explained in detail in the Liquidity Sweep & Reclaim Detection section below.

◇ Color coding shows green when price is in the lower half of the range or breaks above the swing high, and red when price is in the upper half or breaks below the swing low.
https://www.tradingview.com/x/TBae5zXb/ (Screenshot)

◇ Tooltips provide additional context when hovering over any Swing H/L cell, such as "Price is nearing swing low on 15M" or "Price above swing high on 1H - swing high broken."

MARKET STRUCTURE LABELS (HH/HL/LH/LL)
🔹 What is Market Structure? 
Market structure refers to the pattern of swing highs and swing lows that price creates over time. By comparing consecutive swing points, each new swing can be classified into one of four types.

◇ HH (Higher High): A swing high that is higher than the previous swing high, indicating bullish momentum.

◇ HL (Higher Low): A swing low that is higher than the previous swing low, indicating bullish momentum.

◇ LH (Lower High): A swing high that is lower than the previous swing high, indicating bearish momentum.

◇ LL (Lower Low): A swing low that is lower than the previous swing low, indicating bearish momentum.
https://www.tradingview.com/x/WHjKexUq/ (Screenshot: Bullish and Bearish Swing Points)

Bullish structure consists of HH and HL patterns, where price makes higher highs and higher lows. Bearish structure consists of LH and LL patterns, where price makes lower highs and lower lows. Mixed structure contains conflicting patterns and indicates consolidation or potential trend change.

🔹 How the Indicator Displays Market Structure
The Structure column shows the last three structure labels in sequence along with an overall bias arrow.

◇ "LL-LH-HL →" indicates mixed structure with no clear direction.

◇ "HH-HL-HH ↑" indicates bullish structure with higher highs and higher lows.

◇ "LH-LL-LH ↓" indicates bearish structure with lower highs and lower lows.

https://www.tradingview.com/x/RdwkxkOR/ (Screenshot: Dashboard showing neutral, bearish and bullish indication across different timeframes)

The indicator tracks each new swing point as it forms, compares it to the previous swing of the same type, and assigns the appropriate label. Market Structure labels use the same Swing Length setting as Swing High/Low tracking, so both features stay synchronized. Structure bias is determined by the most recent high type and low type combined. If the last swing high was HH and the last swing low was HL, bias is bullish. If the last swing high was LH and the last swing low was LL, bias is bearish. Any other combination shows neutral.

Color coding shows green for bullish structure, red for bearish structure, and gray for mixed or neutral structure.

ORDER BLOCK DETECTION
🔹 What is an Order Block?
An Order Block is a concept from Smart Money analysis representing a candle or consolidation area where institutional orders may have been placed. In SMC methodology, Order Blocks are identified as the last opposing candle before a significant price move that breaks market structure.

◇ A Bullish Order Block is the last bearish candle before a rally that breaks a swing high. When price returns to this zone, it may find support.

◇ A Bearish Order Block is the last bullish candle before a drop that breaks a swing low. When price returns to this zone, it may find resistance.

Order Blocks are considered "mitigated" when price trades completely through them, suggesting the institutional orders have been filled.

🔹 How the Indicator Detects Order Blocks
The detection algorithm follows a specific sequence to identify valid Order Blocks.
◇ Step 1:  The indicator tracks swing highs and swing lows using the configured Swing Length setting (shared with Swing High/Low tracking and Market Structure labels).

◇ Step 2: When price breaks above a swing high, the indicator identifies a bullish breakout. When price breaks below a swing low, it identifies a bearish breakout.

◇ Step 3: For a bullish Order Block, the indicator finds the candle with the lowest low between the broken swing high and the current bar. For a bearish Order Block, it finds the candle with the highest high between the broken swing low and the current bar.

◇ Step 4: The Order Block zone is created spanning from that candle's low to its high.

◇ Step 5: Mitigation is applied when price closes through the Order Block. Bullish OBs are mitigated when price closes below the zone. Bearish OBs are mitigated when price closes above the zone.

The Order Block column shows the nearest unmitigated Order Block for each timeframe. "IN BULL OB ↑" means price is currently inside a bullish Order Block. "BULL OB (5.4%) ↑" means the nearest OB is bullish and 5.5% away. "NONE" means no unmitigated Order Blocks exist on that timeframe.
https://www.tradingview.com/x/muUn64MT/ (Screenshot: Nearest order block is Bull OB)
https://www.tradingview.com/x/SVIZDqnU/  (Screenshot: Price in Bear OB)

FAIR VALUE GAP DETECTION
🔹What is a Fair Value Gap? 
A Fair Value Gap (FVG), also called an imbalance, is a three-candle pattern where a gap exists between the first and third candle that the middle candle did not fill. This gap represents an area where price moved quickly, creating an imbalance in the market.

◇ A Bullish FVG forms when the first candle's high is lower than the third candle's low, creating an upward gap. When price returns to this gap, it may find support.

◇ A Bearish FVG forms when the first candle's low is higher than the third candle's high, creating a downward gap. When price returns to this gap, it may find resistance.

FVGs are considered mitigated when price wicks into the gap, filling the inefficiency.

🔹 How the Indicator Detects FVGs
The detection logic checks for the three-candle gap pattern with specific conditions.

◇ For a Bullish FVG, the current candle's low must be above the candle from three bars ago's high (gap exists), and the middle candle must be bullish (displacement candle).

◇ For a Bearish FVG, the current candle's high must be below the candle from three bars ago's low (gap exists), and the middle candle must be bearish (displacement candle).

◇ The FVG zone spans from the gap's bottom to its top.

◇ Mitigation occurs when price wicks below the gap bottom for bullish FVGs, or above the gap top for bearish FVGs. Note that FVG mitigation is more sensitive than Order Block mitigation.

FVGs only need a wick to touch them, while Order Blocks require a close through them.
The FVG column displays similarly to Order Blocks. "IN BULL FVG ↑" means price is inside a bullish Fair Value Gap. "BULL FVG (0.2%) ↑" means the nearest FVG is bullish and 0.2% away. "NONE" means no unmitigated FVGs exist on that timeframe.
https://www.tradingview.com/x/19r9fCyN/ (Screenshot: Price in Bull FVG)
https://www.tradingview.com/x/u8sEXFhQ/ (Screenshot: Bear FVG +3.4% away)

LIQUIDITY SWEEP & RECLAIM DETECTION
🔹 What is a Liquidity Sweep?
Liquidity refers to resting orders in the market, particularly stop-loss orders. Traders commonly place stops just beyond swing highs and swing lows, creating pools of liquidity at these levels. A liquidity sweep occurs when price breaks beyond a swing point, potentially triggering stops, but then reverses and closes back inside the range.

◇ A Bullish Liquidity Sweep occurs when price breaks below a swing low, then reverses and closes back above it. This pattern suggests potential buying interest after weak hands have been stopped out.

◇ A Bearish Liquidity Sweep occurs when price breaks above a swing high, then reverses and closes back below it. This pattern suggests potential selling interest after weak hands have been stopped out.

🔹 How the Indicator Detects Liquidity Sweeps
The indicator tracks whether each swing level has been broken and then reclaimed.

◇ A swing low is marked as broken when price trades below it. A swing high is marked as broken when price trades above it.

◇ A reclaim is detected when price closes back above a broken swing low (bullish) or back below a broken swing high (bearish).

◇ The break and reclaim flags reset when a new swing point forms, ensuring fresh detection for each level.

When a liquidity sweep is detected, the Swing H/L column displays special indicators. The ⤴ symbol indicates a bullish liquidity sweep where price swept the low and reclaimed. The ⤵ symbol indicates a bearish liquidity sweep where price swept the high and reclaimed. Tooltips provide additional context such as "Liquidity sweep - price swept swing low and reclaimed on 15M."
https://www.tradingview.com/x/HuAE6c5b/ (Screenshot: Swing High Swept)
https://www.tradingview.com/x/dZ1ewOOS/ (Screenshot: Previous Month Low Swept)

VOLUME ANALYSIS
🔹 What is Volume Analysis?
Volume represents the number of shares, contracts, or units traded during a given period. High volume suggests strong interest and participation behind a price move. Low volume suggests weak interest and moves may lack follow-through. Comparing current volume to average volume helps identify unusual activity.

🔹 How the Indicator Analyzes Volume The dashboard calculates current volume as a percentage of its 20-period simple moving average.

◇ The Volume column displays a visual bar using filled and empty blocks to represent volume level relative to average.

◇ Volume states are classified as EXTREME (over 200% of average), HIGH (over 120%), NORMAL (over 80%), LOW (over 50%), or VERY LOW (50% or less).

https://www.tradingview.com/x/9xDpCLto/ (Screenshot: Extreme Volume)
◇ Color coding shows yellow for extreme volume, orange for high volume, and gray for normal, low, and very low.

◇ Tooltips show the exact percentage, such as "Volume is currently at 145% of average."

VOLATILITY ANALYSIS
🔹 What is Volatility?
Volatility measures how much price fluctuates over a given period. High volatility means large price swings. Low volatility means small price movements. The Average True Range (ATR) is a common volatility measure that calculates the average of true ranges over a period.

🔹 How the Indicator Measures Volatility
The dashboard calculates a 14-period ATR and compares it to its own 20-period average (configurable).

◇ The Volatility column displays the current state as HIGH (ATR over 130% of average), NORMAL (ATR between 70-130% of average), or LOW (ATR under 70% of average).

◇ Color coding shows red for high volatility, gray for normal, and green for low volatility.

◇ Tooltips provide context such as "Volatility is currently high" or "Volatility is currently low."
Low volatility often precedes significant moves, making it a useful setup indicator when combined with price at key levels.
https://www.tradingview.com/x/2BSTKeV9/ (Screenshot: High Volatility)

TRADING SESSIONS
🔹 What are Trading Sessions?
Financial markets have varying activity levels throughout the day. Trading is typically divided into three major sessions based on which financial centers are open.

◇ Asian Session runs from 7:00 PM to 3:00 AM EST. It is characterized by generally lower volatility and ranging price action

◇ London Session runs from 3:00 AM to 12:00 PM EST. It is characterized by higher volatility and trending moves

◇ New York Session runs from 8:00 AM to 5:00 PM EST. It has high volatility especially during the London overlap from 8:00 AM to 12:00 PM EST, affecting USD pairs and all majors.

🔹 How the Indicator Displays Sessions
The Session column shows the current session name in the first row as ASIAN, LONDON, NEW YORK, or OFF HOURS (between sessions from 5:00 PM to 7:00 PM EST).

◇ The second row shows a progress bar that fills as the session advances, with each block representing approximately one hour.

◇ Sessions are color-coded as blue for Asian, green for London, orange for New York, and gray for off hours. These colors can be customized in the settings

◇ The indicator uses New York (EST) timezone for all session calculations and includes replay mode support.
https://www.tradingview.com/x/SZPmT4Y3/ (Asian Session and Killzone)

ICT KILLZONES
🔹 What are Killzones?
Killzones are specific time windows within each trading session when market activity tends to be higher. These windows are derived from ICT (Inner Circle Trader) methodology and represent times when significant moves are more likely to occur.

◇ Asian Killzone runs from 8:00 PM to 12:00 AM EST and often sets the initial range for the day.

◇ London Killzone runs from 2:00 AM to 5:00 AM EST and covers the London open when major moves are common.

◇ New York AM Killzone runs from 9:30 AM to 11:00 AM EST and covers the NYSE open, a high volume period.

◇ New York Lunch runs from 12:00 PM to 1:00 PM EST and typically has lower activity and consolidation.

◇ New York PM Killzone runs from 1:30 PM to 4:00 PM EST when afternoon continuation moves occur.

🔹 How the Indicator Displays Killzones
The Killzone column shows the current killzone in the first row as ASIAN KZ, LONDON KZ, NY AM KZ, NY LUNCH, NY PM KZ, or NO KILLZONE when outside all killzones.

◇ When outside a killzone, the second row shows a countdown to the next killzone, such as "NY AM KZ in 2h:15m."

◇ Killzones are color-coded as blue for Asian, green for London, orange for NY AM, gray for NY Lunch, and purple for NY PM. These colors can be customized in the settings

TREND BIAS SYSTEM
🔹 What is Trend Bias?
The Trend Bias System aggregates multiple factors across all enabled timeframes to produce a single directional bias score. Instead of analyzing each factor and timeframe separately, this system provides a weighted summary of overall market sentiment.

🔹 How the Indicator Calculates Trend Bias The calculation involves three components working together.
https://www.tradingview.com/x/ASWCwk0h/ (Screenshot: BTC Bearish Trend)

◇ Factors determine what contributes to bias. Users can enable or disable Structure (market structure bias), Order Block (direction of nearest OB), FVG (direction of nearest FVG), EMA Trend (price position relative to EMA), and Swing Position (where price sits in the swing range). Each enabled factor contributes +1 for bullish, -1 for bearish, or 0 for neutral per timeframe.

◇ Weights determine how much each timeframe matters. Each timeframe has a configurable weight from 0 to 10. Default weights are 1 for 1M and 5M, 2 for 15M, 1H, and 4H, 3 for Daily, and 4 for Weekly. Higher weights mean that timeframe contributes more to the final score.
https://www.tradingview.com/x/XNMnZHRI/ (Screenshot: Gold Bullish Trend)

◇ Score Calculation combines factors and weights. For each active timeframe, the sum of factor scores is multiplied by the timeframe's weight. The total score is the sum of all timeframe scores. The maximum possible score is the sum of each weight multiplied by the number of enabled factors. The bias percentage equals the total score divided by the maximum possible score, multiplied by 100.

◇ Bias Labels are assigned based on percentage. Over 50% shows BULLISH ↑. Between 20% and 50% shows LEAN BULL ↑. Between -20% and 20% shows NEUTRAL →. Between -50% and -20% shows LEAN BEAR ↓. Below -50% shows BEARISH ↓.

The Trend Bias column displays the bias label in the first row and the raw score in the second row, such as "+22/60" meaning 22 points out of 60 possible.

HTF LEVELS (PDH/L, PWH/L, PMH/L)
🔹 What are HTF Levels?
Higher Timeframe (HTF) Levels are significant price points from previous completed periods. These levels represent clear, objective reference points that many traders watch.

◇ PDH/PDL (Previous Day High/Low) are the high and low of the previous completed trading day and act as intraday support and resistance.

◇ PWH/PWL (Previous Week High/Low) are the high and low of the previous completed week and are significant levels for swing trading.

◇ PMH/PML (Previous Month High/Low) are the high and low of the previous completed month and are major levels for position trading.

🔹 How the Indicator Displays HTF Levels The HTF Levels Dashboard section (optional) shows a swing-style position bar for each enabled level, displaying where price sits within the previous day, week, or month range.

◇ The same liquidity sweep detection applies to HTF levels. If price sweeps PDL and reclaims, the ⤴ indicator appears.
https://www.tradingview.com/x/M87LfN5C/ (Screenshot: Previous Week Low Swept)

◇ Visual overlays can plot HTF level lines on the chart with customizable colors and line styles.

◇ When multiple levels are close together, labels automatically combine. For example, "PDH/PWH" appears when both levels are at similar prices, or "PDL/PWL/PML" when all three lows align.
https://www.tradingview.com/x/7jKcuuGC/  (Screenshot: PWH/PMH labels combined when Previous Week Low and Previous Month Low align)

VISUAL OVERLAYS
Beyond the dashboard, the indicator offers optional visual overlays that plot directly on the price chart.

🔹 Order Block Zones
When enabled, Order Blocks appear as semi-transparent rectangular boxes. Green boxes represent bullish Order Blocks and red boxes represent bearish Order Blocks. Boxes span from the OB candle's low to its high and extend forward based on the Extend setting. Optional labels show "OB ↑" or "OB ↓" inside the zones.

🔹 FVG Zones
Fair Value Gaps appear as boxes with dashed borders to distinguish them from Order Blocks. Green dashed boxes represent bullish FVGs and red dashed boxes represent bearish FVGs. They share the same extend and label options as Order Blocks.
https://www.tradingview.com/x/JqbhALMQ/ (Order Blocks & Fair Value Gaps)

🔹 Swing Labels
HH, HL, LH, and LL labels can be plotted directly at each swing point on the chart. Labels appear above swing highs and below swing lows. Green labels indicate bullish structure (HH, HL) and red labels indicate bearish structure (LH, LL). The Show Last setting controls how many labels appear.

🔹 Swing Lines
Horizontal lines can be drawn at the current swing high and swing low. A red line appears at the swing high and a green line at the swing low. Line styles are customizable as solid, dashed, or dotted.
https://www.tradingview.com/x/iaEDugrU/ (Swing Labels & Swing Lines)

🔹 HTF Level Lines
Horizontal lines can be plotted at Previous Day, Week, and Month highs and lows. Each level has a separate enable toggle with customizable colors and line styles. Labels auto-combine when levels are close together.

🔹 EMA Line
A standard EMA line can be plotted on the chart using the same EMA Length setting as the dashboard with customizable color.
DASHBOARD CUSTOMIZATION: 
The dashboard is highly customizable to fit different trading styles and screen setups.

🔹Dashboard Position
 Choose from 9 dashboard positions including top left, top center, top right, middle left, middle center, middle right, bottom left, bottom center, and bottom right.

🔹Dashboard Colors
Two color themes are available. Dark Mode has dark backgrounds with light text and is the default. Light Mode has light backgrounds with dark text.

🔹Column Toggles
 Enable or disable individual columns in each dashboard section to show only the information needed. The Market Structure Dashboard section can toggle EMA Trend, Swing H/L, Structure, Order Block, and FVG columns. The Current Timeframe Dashboard section can toggle Volume, Swing H/L, and Volatility columns. The Market Context Dashboard section can toggle Session, Killzone, and Trend Bias columns. The HTF Levels Dashboard section can toggle PDH/L, PWH/L, and PMH/L levels.

🔹Color Settings
Customize colors for trend colors (bull, bear, neutral), session colors (Asian, London, NY), and killzone colors (Asian KZ, London KZ, NY AM, Lunch, PM).

🔹Distance Display 
Choose how distances are shown. Percent shows values like "0.45%" and is the default. Price shows raw values like "45.50". Pips shows values like "45 pips" and is useful for forex.
SETTINGS:

🔹 Timeframes
Configure which timeframes are analyzed in the dashboard. Enable toggles turn each of the 7 timeframes on or off. Timeframe selection sets the specific timeframe for each slot (1M, 5M, 15M, 1H, 4H, D, W, M, or custom). Trend weight controls how much each timeframe contributes to the overall bias calculation (0-10), with higher values giving that timeframe more influence.

🔹 Market Structure Dashboard
Controls the main multi-timeframe dashboard section. The enable toggle turns the entire section on or off. Column toggles allow you to show or hide individual columns: EMA Trend, Swing H/L, Structure, Order Block, and FVG. Disabling columns you don't need reduces visual clutter and focuses the dashboard on the information most relevant to your trading style.

🔹 Current Timeframe Dashboard
Controls the current chart timeframe section that displays volume, swing position, and volatility data. The enable toggle turns the entire section on or off. Column toggles allow you to show or hide individual columns: Volume, Swing H/L, and Volatility. 

🔹 Market Context Dashboard
Controls the market context section that displays session, killzone, and trend bias information. The enable toggle turns the entire section on or off. Column toggles allow you to show or hide individual columns: Session, Killzone, and Trend Bias. 

🔹 HTF Levels Dashboard
Controls the higher timeframe levels section that displays previous day, week, and month high/low data. The enable toggle turns the entire section on or off. Level toggles allow you to show or hide individual levels: PDH/L, PWH/L, and PMH/L.

🔹 Trend Bias Settings
Controls which factors contribute to the trend bias calculation. Factor toggles allow you to include or exclude Structure, Order Block, FVG, EMA Trend, and Swing H/L from the bias score. Disabling factors you don't find relevant customizes how the overall bias is determined. 

🔹 Visual Overlays
Controls what is plotted directly on the price chart. Order Blocks and FVGs each have an enable toggle, bull/bear colors, show last count (how many zones to display), extend bars (how far zones project forward), and labels toggle. Swing Labels have an enable toggle, bull/bear colors, and show last count. Swing Lines have an enable toggle, high/low colors, line style (solid, dashed, dotted), and extend bars. HTF Level Lines for Previous Day, Week, and Month highs/lows each have an enable toggle, colors, and line style, with a shared extend setting for all HTF lines. EMA has an enable toggle and color setting.

🔹 General Settings
Core indicator parameters. EMA Length sets the period for EMA calculation (default 9). Swing Length sets how many bars are required to confirm a pivot and is used for Swing Point detection, Order Block detection, and Market Structure labels (default 5). Volatility Lookback sets the period for ATR averaging (default 20). Distance Display controls how distances are shown: Percent, Price, or Pips. Dashboard Position sets where the dashboard appears on the chart (9 options). Dashboard Theme switches between Dark Mode and Light Mode. Color settings allow customization of trend colors (bull, bear, neutral), session colors (Asian, London, NY), and killzone colors (Asian KZ, London KZ, NY AM, Lunch, PM).
https://www.tradingview.com/x/GkB4GocX/ (Full Dashboard)
https://www.tradingview.com/x/ycC6429z/ (Customized Display)

UNIQUENESS:
The Market Structure Dashboard focuses on multi-timeframe confluence by calculating and displaying the same analytical components across up to 7 timeframes simultaneously. Unlike indicators that show one timeframe at a time, each row in the dashboard represents a complete analysis of that timeframe's structure, zones, and trend state. This allows traders to observe alignment, disagreement, and transitions across timeframes within a single view.
The weighted Trend Bias System combines structure, zones, EMA, and swing position into a single score that accounts for timeframe importance. Higher timeframes can be weighted more heavily, reflecting their greater significance in establishing overall market direction.
The dashboard also integrates time-based context through session and killzone tracking, helping traders identify when market conditions align with historically active trading windows. All components coexist without overriding each other, providing a comprehensive framework for multi-timeframe market structure analysis.

---

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © fluxchart

//@version=6
indicator("Market Structure Dashboard | Flux Charts", overlay = true, max_boxes_count = 500, max_labels_count = 500, max_bars_back = 1000)

//#region CONSTANTS

// Base colors
GRAY                    = #787b86
ORANGE                  = #f97316
YELLOW                  = #fbbf24

// Trend colors (defaults)
BULL_COLOR              = #089981
BEAR_COLOR              = #f23645
NEUT_COLOR              = #b8b8b8

// Session colors (defaults)
SESSION_ASIAN           = #3b82f6
SESSION_LONDON          = #22c55e
SESSION_NY              = #f97316
SESSION_LUNCH           = #6b7280
SESSION_PM              = #a855f7

// Dashboard theme colors
BG_DARK_DARK            = color.rgb(30, 30, 30)
BG_DARK_LIGHT           = color.rgb(245, 245, 245)
BG_HEADER_DARK          = color.rgb(30, 30, 40)
BG_HEADER_LIGHT         = color.rgb(230, 230, 240)
BG_ROW_DARK             = #1a2332
BG_ROW_LIGHT            = #e8edf5
TEXT_DARK               = color.white
TEXT_LIGHT              = color.rgb(30, 30, 30)


// Group Headers
gTF                     = "Timeframes"
gMsd                    = "Market Structure Dashboard"
gCtfd                   = "Current Timeframe Dashboard"
gMcd                    = "Market Context Dashboard"
gHtf                    = "HTF Levels Dashboard"
gBias                   = "Trend Bias Settings"
gVO                     = "Visual Overlays"
gSettings               = "Settings"

gAlertMsd               = "Alerts: Market Structure Dashboard"
gAlertCtf               = "Alerts: Current Timeframe"
gAlertCtx               = "Alerts: Market Context"
gAlertHtf               = "Alerts: HTF Levels"
//#endregion CONSTANTS

//#region INPUTS

// Line style enum
enum lineStyle
    solid  = "────"
    dashed = "- - -"
    dotted = "····"

// Timeframes
bool    tf1Enabled = input.bool(true,       "",               group = gTF, inline = "tf1", display = display.none)
string  tf1        = input.timeframe("1",   "",               group = gTF, inline = "tf1", active = tf1Enabled, display = display.none)
int     tf1Weight  = input.int(1,           "Trend Weight",   group = gTF, inline = "tf1", minval = 0, maxval = 10, active = tf1Enabled, display = display.none)

bool    tf2Enabled = input.bool(true,       "",               group = gTF, inline = "tf2", display = display.none)
string  tf2        = input.timeframe("5",   "",               group = gTF, inline = "tf2", active = tf2Enabled, display = display.none)
int     tf2Weight  = input.int(1,           "Trend Weight",   group = gTF, inline = "tf2", minval = 0, maxval = 10, active = tf2Enabled, display = display.none)

bool    tf3Enabled = input.bool(true,       "",               group = gTF, inline = "tf3", display = display.none)
string  tf3        = input.timeframe("15",  "",               group = gTF, inline = "tf3", active = tf3Enabled, display = display.none)
int     tf3Weight  = input.int(2,           "Trend Weight",   group = gTF, inline = "tf3", minval = 0, maxval = 10, active = tf3Enabled, display = display.none)

bool    tf4Enabled = input.bool(true,       "",               group = gTF, inline = "tf4", display = display.none)
string  tf4        = input.timeframe("60",  "",               group = gTF, inline = "tf4", active = tf4Enabled, display = display.none)
int     tf4Weight  = input.int(2,           "Trend Weight",   group = gTF, inline = "tf4", minval = 0, maxval = 10, active = tf4Enabled, display = display.none)

bool    tf5Enabled = input.bool(true,       "",               group = gTF, inline = "tf5", display = display.none)
string  tf5        = input.timeframe("240", "",               group = gTF, inline = "tf5", active = tf5Enabled, display = display.none)
int     tf5Weight  = input.int(2,           "Trend Weight",   group = gTF, inline = "tf5", minval = 0, maxval = 10, active = tf5Enabled, display = display.none)

bool    tf6Enabled = input.bool(true,       "",               group = gTF, inline = "tf6", display = display.none)
string  tf6        = input.timeframe("D",   "",               group = gTF, inline = "tf6", active = tf6Enabled, display = display.none)
int     tf6Weight  = input.int(3,           "Trend Weight",   group = gTF, inline = "tf6", minval = 0, maxval = 10, active = tf6Enabled, display = display.none)

bool    tf7Enabled = input.bool(true,       "",               group = gTF, inline = "tf7", display = display.none)
string  tf7        = input.timeframe("W",   "",               group = gTF, inline = "tf7", active = tf7Enabled, display = display.none)
int     tf7Weight  = input.int(4,           "Trend Weight",   group = gTF, inline = "tf7", minval = 0, maxval = 10, active = tf7Enabled, display = display.none)

// Market Structure Dashboard
bool    showMSD        = input.bool(true, "Enable",         group = gMsd, display = display.none)
bool    showColEma     = input.bool(true, "EMA Trend",      group = gMsd, inline = "msdCols1", active = showMSD, display = display.none)
bool    showColSwing   = input.bool(true, "Swing H/L",      group = gMsd, inline = "msdCols1", active = showMSD, display = display.none)
bool    showColStruct  = input.bool(true, "Structure",      group = gMsd, inline = "msdCols1", active = showMSD, display = display.none)
bool    showColOB      = input.bool(true, "Order Block",    group = gMsd, inline = "msdCols2", active = showMSD, display = display.none)
bool    showColFVG     = input.bool(true, "FVG",            group = gMsd, inline = "msdCols2", active = showMSD, display = display.none)

// Current Timeframe Dashboard
bool    showCurrTF     = input.bool(true, "Enable",         group = gCtfd, display = display.none)
bool    showCurrSwing  = input.bool(true, "Swing H/L",      group = gCtfd, inline = "currCols", active = showCurrTF, display = display.none)
bool    showCurrVol    = input.bool(true, "Volume",         group = gCtfd, inline = "currCols", active = showCurrTF, display = display.none)
bool    showCurrAtr    = input.bool(true, "Volatility",     group = gCtfd, inline = "currCols", active = showCurrTF, display = display.none)

// Market Context Dashboard
bool    showContext    = input.bool(true, "Enable",         group = gMcd, display = display.none)
bool    showSession    = input.bool(true, "Session",        group = gMcd, inline = "ctxCols", active = showContext, display = display.none)
bool    showKillzone   = input.bool(true, "Killzone",       group = gMcd, inline = "ctxCols", active = showContext, display = display.none)
bool    showBias       = input.bool(true, "Trend Bias",     group = gMcd, inline = "ctxCols", active = showContext, display = display.none)

// HTF Levels Dashboard
bool    showHTFLevels  = input.bool(false, "Enable",        group = gHtf, display = display.none)
bool    showPDHL       = input.bool(true,  "PDH/L",         group = gHtf, inline = "htfCols", active = showHTFLevels, display = display.none) and timeframe.in_seconds() <= 86400
bool    showPWHL       = input.bool(true,  "PWH/L",         group = gHtf, inline = "htfCols", active = showHTFLevels, display = display.none) and timeframe.in_seconds() <= 86400 * 7
bool    showPMHL       = input.bool(false, "PMH/L",         group = gHtf, inline = "htfCols", active = showHTFLevels, display = display.none) and timeframe.in_seconds() <= 86400 * 31


// Trend Bias Settings
bool    biasUseStruct  = input.bool(true,  "Structure",     group = gBias, inline = "biasFactors1", display = display.none)
bool    biasUseOB      = input.bool(true,  "Order Block",   group = gBias, inline = "biasFactors1", display = display.none)
bool    biasUseFVG     = input.bool(true,  "FVG",           group = gBias, inline = "biasFactors1", display = display.none)
bool    biasUseEMA     = input.bool(false, "EMA Trend",     group = gBias, inline = "biasFactors2", display = display.none)
bool    biasUseSwing   = input.bool(true,  "Swing H/L",     group = gBias, inline = "biasFactors2", display = display.none)

// Settings
int     emaLength      = input.int(9,                   "EMA Length",           group = gSettings, minval = 1, display = display.none)
int     swingLength    = input.int(5,                   "Swing Length",         group = gSettings, minval = 1, tooltip = "Used for Swing H/L detection, Order Blocks, and Structure", display = display.none)
int     atrAvgLength   = input.int(20,                  "Volatility Lookback",  group = gSettings, minval = 1, tooltip = "Period for averaging ATR to determine volatility state", display = display.none)
string  distanceMode   = input.string("Percent",        "Distance Display",     group = gSettings, options = ["Percent", "Price", "Pips"], tooltip = "Show distances as percentage, price, or pips (forex)", display = display.none)
string  dashboardPos   = input.string("Top Right",      "Dashboard Position",   group = gSettings, options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], display = display.none)
string  dashboardTheme = input.string("Dark Mode",      "Dashboard Colors",     group = gSettings, options = ["Dark Mode", "Light Mode"], display = display.none)
color   bullColor      = input.color(BULL_COLOR,        "Trend Colors   ",      group = gSettings, inline = "trendColors", display = display.none)
color   bearColor      = input.color(BEAR_COLOR,        "",                     group = gSettings, inline = "trendColors", display = display.none)
color   neutColor      = input.color(NEUT_COLOR,        "",                     group = gSettings, inline = "trendColors", display = display.none)
color   sessAsianColor  = input.color(SESSION_ASIAN,    "Session Colors ",      group = gSettings, inline = "sessionColors", tooltip = "Colors for Asian, London, NY sessions", display = display.none)
color   sessLondonColor = input.color(SESSION_LONDON,   "",                     group = gSettings, inline = "sessionColors", display = display.none)
color   sessNyColor     = input.color(SESSION_NY,       "",                     group = gSettings, inline = "sessionColors", display = display.none)
color   kzAsianColor    = input.color(SESSION_ASIAN,    "Killzone Colors ",     group = gSettings, inline = "kzColors", tooltip = "Colors for Asian, London, NY AM, NY Lunch, NY PM killzones", display = display.none)
color   kzLondonColor   = input.color(SESSION_LONDON,   "",                     group = gSettings, inline = "kzColors", display = display.none)
color   kzNyAmColor     = input.color(SESSION_NY,       "",                     group = gSettings, inline = "kzColors", display = display.none)
color   kzLunchColor    = input.color(SESSION_LUNCH,    "",                     group = gSettings, inline = "kzColors", display = display.none)
color   kzPmColor       = input.color(SESSION_PM,       "",                     group = gSettings, inline = "kzColors", display = display.none)
string  tblTextSize    = size.small
// Dashboard position
tablePos = switch dashboardPos
    "Top Left"      => position.top_left
    "Top Center"    => position.top_center
    "Top Right"     => position.top_right
    "Middle Left"   => position.middle_left
    "Middle Center" => position.middle_center
    "Middle Right"  => position.middle_right
    "Bottom Left"   => position.bottom_left
    "Bottom Center" => position.bottom_center
    "Bottom Right"  => position.bottom_right

// Dashboard theme colors
color   bgDark   = dashboardTheme == "Dark Mode" ? BG_DARK_DARK   : BG_DARK_LIGHT
color   bgHeader = dashboardTheme == "Dark Mode" ? BG_HEADER_DARK : BG_HEADER_LIGHT
color   bgRow    = dashboardTheme == "Dark Mode" ? BG_ROW_DARK    : BG_ROW_LIGHT
color   textCol  = dashboardTheme == "Dark Mode" ? TEXT_DARK      : TEXT_LIGHT

// Visual Overlays
bool    showOB             = input.bool(false,              "Order Blocks",             group = gVO, inline = "ob", tooltip = "Display Order Block zones on chart", display = display.none)
color   obBullColor        = input.color(BULL_COLOR,        "",                         group = gVO, inline = "ob", active = showOB, display = display.none)
color   obBearColor        = input.color(BEAR_COLOR,        "",                         group = gVO, inline = "ob", active = showOB, display = display.none)
int     obLookback         = input.int(6,                   "└ Show Last",              group = gVO, inline = "obOpts", minval = 1, maxval = 20, active = showOB, tooltip = "Number of recent Order Blocks to display", display = display.none)
int     obExtend           = input.int(20,                  "Extend",                   group = gVO, inline = "obOpts", minval = 1, active = showOB, tooltip = "Bars to extend Order Block zones into the future", display = display.none)
bool    showOBLabels       = input.bool(false,              "└ Labels",                 group = gVO, active = showOB, tooltip = "Show OB labels inside Order Block zones", display = display.none)

bool    showFVG            = input.bool(false,              "FVGs       ",              group = gVO, inline = "fvg", tooltip = "Display Fair Value Gap zones on chart", display = display.none)
color   fvgBullColor       = input.color(BULL_COLOR,        "",                         group = gVO, inline = "fvg", active = showFVG, display = display.none)
color   fvgBearColor       = input.color(BEAR_COLOR,        "",                         group = gVO, inline = "fvg", active = showFVG, display = display.none)
int     fvgLookback        = input.int(6,                   "└ Show Last",              group = gVO, inline = "fvgOpts", minval = 1, maxval = 20, active = showFVG, tooltip = "Number of recent FVGs to display", display = display.none)
int     fvgExtend          = input.int(20,                  "Extend",                   group = gVO, inline = "fvgOpts", minval = 1, active = showFVG, tooltip = "Bars to extend FVG zones into the future", display = display.none)
bool    showFVGLabels      = input.bool(false,              "└ Labels",                 group = gVO, active = showFVG, tooltip = "Show FVG labels inside Fair Value Gap zones", display = display.none)

bool    showSwingLabels    = input.bool(false,              "Swing Labels",             group = gVO, inline = "swingLabels", tooltip = "Display HH/HL/LH/LL labels at swing points", display = display.none)
color   swingBullColor     = input.color(BULL_COLOR,        "",                         group = gVO, inline = "swingLabels", active = showSwingLabels, display = display.none)
color   swingBearColor     = input.color(BEAR_COLOR,        "",                         group = gVO, inline = "swingLabels", active = showSwingLabels, display = display.none)
int     swingLabelLookback = input.int(10,                  "└ Show Last",              group = gVO, minval = 1, maxval = 500, active = showSwingLabels, tooltip = "Number of recent swing labels to display", display = display.none)

bool    showSwingLines     = input.bool(false,              "Swing Lines ",             group = gVO, inline = "swingLines", tooltip = "Draw horizontal lines at recent swing high/low levels", display = display.none)
color   swingLineLowColor  = input.color(BULL_COLOR,        "",                         group = gVO, inline = "swingLines", active = showSwingLines, display = display.none)
color   swingLineHighColor = input.color(BEAR_COLOR,        "",                         group = gVO, inline = "swingLines", active = showSwingLines, display = display.none)
lineStyle swingLineStyle   = input.enum(lineStyle.dashed,   "",                         group = gVO, inline = "swingLines", active = showSwingLines, display = display.none)
int     swingLinesExtend   = input.int(20,                  "└ Extend",                 group = gVO, minval = 1, active = showSwingLines, tooltip = "Bars to extend swing lines into the future", display = display.none)

bool    plotPDHL           = input.bool(false,              "Previous Day High/Low  ",  group = gVO, inline = "pdhl", display = display.none)
color   pdlColor           = input.color(BULL_COLOR,        "",                         group = gVO, inline = "pdhl", active = plotPDHL, display = display.none)
color   pdhColor           = input.color(BEAR_COLOR,        "",                         group = gVO, inline = "pdhl", active = plotPDHL, display = display.none)
lineStyle pdhlLineStyle    = input.enum(lineStyle.dashed,   "",                         group = gVO, inline = "pdhl", active = plotPDHL, display = display.none)

bool    plotPWHL           = input.bool(false,              "Previous Week High/Low  ", group = gVO, inline = "pwhl", display = display.none)
color   pwlColor           = input.color(BULL_COLOR,        "",                         group = gVO, inline = "pwhl", active = plotPWHL, display = display.none)
color   pwhColor           = input.color(BEAR_COLOR,        "",                         group = gVO, inline = "pwhl", active = plotPWHL, display = display.none)
lineStyle pwhlLineStyle    = input.enum(lineStyle.dashed,   "",                         group = gVO, inline = "pwhl", active = plotPWHL, display = display.none)

bool    plotPMHL           = input.bool(false,              "Previous Month High/Low",  group = gVO, inline = "pmhl", tooltip = "Plot previous month high and low levels", display = display.none)
color   pmlColor           = input.color(BULL_COLOR,        "",                         group = gVO, inline = "pmhl", active = plotPMHL, display = display.none)
color   pmhColor           = input.color(BEAR_COLOR,        "",                         group = gVO, inline = "pmhl", active = plotPMHL, display = display.none)
lineStyle pmhlLineStyle    = input.enum(lineStyle.dashed,   "",                         group = gVO, inline = "pmhl", active = plotPMHL, display = display.none)

int     htfLevelExtend     = input.int(20,                  "└ HTF Extend",             group = gVO, minval = 1, active = plotPDHL or plotPWHL or plotPMHL, tooltip = "Bars to extend HTF level lines into the future. Labels auto-combine when levels are close.", display = display.none)

bool    showEMA            = input.bool(false,              "EMA",                      group = gVO, inline = "ema", display = display.none)
color   emaColor           = input.color(ORANGE,            "",                         group = gVO, inline = "ema", active = showEMA, display = display.none)



// Alerts: Market Structure Dashboard (MTF)
bool    alertMsdSwingBreak = input.bool(false, "Swing Breaks",                          group = gAlertMsd, inline = "aMsdSwing", display = display.none)
bool    alertMsdSwingSweep = input.bool(false, "Swing Sweeps",                          group = gAlertMsd, inline = "aMsdSwing", tooltip = "Alert when swing high/low is broken or swept & reclaimed on any active timeframe", display = display.none)

bool    alertMsdStruct     = input.bool(false, "Structure Bias Change",                 group = gAlertMsd, tooltip = "Alert when structure bias changes (Bullish/Bearish/Neutral) on any active timeframe", display = display.none)

bool    alertMsdOBEnter    = input.bool(false, "Price in OB",                           group = gAlertMsd, inline = "aMsdOB", display = display.none)
bool    alertMsdOBChange   = input.bool(false, "OB Direction Change",                   group = gAlertMsd, inline = "aMsdOB", tooltip = "Alert when price enters an OB zone or nearest OB direction changes on any active timeframe", display = display.none)

bool    alertMsdFVGEnter   = input.bool(false, "Price in FVG",                          group = gAlertMsd, inline = "aMsdFVG", display = display.none)
bool    alertMsdFVGChange  = input.bool(false, "FVG Direction Change",                  group = gAlertMsd, inline = "aMsdFVG", tooltip = "Alert when price enters an FVG zone or nearest FVG direction changes on any active timeframe", display = display.none)

bool    alertMsdEma        = input.bool(false, "EMA Trend Change",                      group = gAlertMsd, tooltip = "Alert when EMA trend direction flips on any active timeframe", display = display.none)

bool    alertCtfSwingBreak = input.bool(false, "Swing Breaks",                          group = gAlertCtf, inline = "aCtfSwing", display = display.none)
bool    alertCtfSwingSweep = input.bool(false, "Swing Sweeps",                          group = gAlertCtf, inline = "aCtfSwing", tooltip = "Alert when current TF swing high/low is broken or swept & reclaimed", display = display.none)

bool    alertCtfVolume     = input.bool(false, "Volume State Change",                   group = gAlertCtf, tooltip = "Alert when volume state changes (Extreme/High/Normal/Low/Very Low)", display = display.none)
bool    alertCtfVolatility = input.bool(false, "Volatility State Change",               group = gAlertCtf, tooltip = "Alert when volatility state changes (High/Normal/Low)", display = display.none)

bool    alertSession       = input.bool(false, "Session Change",                        group = gAlertCtx, inline = "aCtxSessKz", display = display.none)
bool    alertKillzone      = input.bool(false, "Killzone Change",                       group = gAlertCtx, inline = "aCtxSessKz", tooltip = "Alert when trading session or killzone changes", display = display.none)

bool    alertBiasChange    = input.bool(false, "Bias State Change",                     group = gAlertCtx, tooltip = "Alert when trend bias state changes (Bullish/Lean Bull/Neutral/Lean Bear/Bearish)", display = display.none)

bool    alertHtfPDBreak    = input.bool(false, "PDH/L Breaks",                          group = gAlertHtf, inline = "aHtfPD", display = display.none)
bool    alertHtfPDSweep    = input.bool(false, "PDH/L Sweeps",                          group = gAlertHtf, inline = "aHtfPD", tooltip = "Alert when Previous Day High/Low is broken or swept & reclaimed", display = display.none)

bool    alertHtfPWBreak    = input.bool(false, "PWH/L Breaks",                          group = gAlertHtf, inline = "aHtfPW", display = display.none)
bool    alertHtfPWSweep    = input.bool(false, "PWH/L Sweeps",                          group = gAlertHtf, inline = "aHtfPW", tooltip = "Alert when Previous Week High/Low is broken or swept & reclaimed", display = display.none)

bool    alertHtfPMBreak    = input.bool(false, "PMH/L Breaks",                          group = gAlertHtf, inline = "aHtfPM", display = display.none)
bool    alertHtfPMSweep    = input.bool(false, "PMH/L Sweeps",                          group = gAlertHtf, inline = "aHtfPM", tooltip = "Alert when Previous Month High/Low is broken or swept & reclaimed", display = display.none)

bool    alertDebugLabels   = false
//#endregion INPUTS

//#region GLOBALS
atrLength = 3
emaValue  = ta.ema(close, emaLength)
pivotHigh = ta.pivothigh(high, swingLength, swingLength)
pivotLow  = ta.pivotlow(low, swingLength, swingLength)
_green    = close > open or close > close[1]
_red      = close < open or close < close[1]
bullFVG   = low[1]  > high[3] and _green[2] and low[1] < high[2] and low[2] < high[3]
bearFVG   = high[1] < low[3]  and _red[2]   and high[1] > low[2] and high[2] > low[3]
//#endregion GLOBALS

//#region TYPES
type ZoneBlock
    int   dir
    float top
    float bottom
    int   barIdx

type SwingData
    float prevH
    float currH
    float prevL
    float currL

type PivotData
    float lastPH
    int   lastPHBar
    float lastPL
    int   lastPLBar

type SwingLineData
    line  highLine
    line  lowLine
    int   lastHBar
    int   lastLBar

type CandleSearch
    float price
    float otherPrice
    int   barIdx
    int   barsBack

type ZoneResult
    int   dir
    float top
    float bottom
    int   barIdx
    bool  isNew

type SwingLabel
    int   x
    float y
    string txt
    bool  isHigh
    color clr
    color textClr

type TfAlertState
    int swingSt  = 0
    int structSt  = 0
    int obIn     = 0
    int obDir    = 0
    int fvgIn    = 0
    int fvgDir   = 0
    int ema      = 0
//#endregion TYPES

//#region FUNCTIONS

getLineStyle(lineStyle ls) =>
    switch ls
        lineStyle.solid  => line.style_solid
        lineStyle.dashed => line.style_dashed
        lineStyle.dotted => line.style_dotted

pct(value, base)      => (value / base) * 100
priceToPct(priceVal)  => (priceVal / close) * 100
getPipSize()          => syminfo.mintick * (str.contains(syminfo.ticker, "JPY") ? 100 : 10)
priceToPips(priceVal) => priceVal / getPipSize()
isBreakAbove(level)   => not na(level) and close > level and close[1] <= level
isBreakBelow(level)   => not na(level) and close < level and close[1] >= level

calcTrend() =>
    trendDist = close - emaValue
    dir       = close > emaValue ? 1 : -1
    [dir, trendDist]

calcSwingHL() =>
    var SwingData swing = SwingData.new()
    var bool lowBroken = false
    var bool highBroken = false
    
    newSwingH = not na(pivotHigh)
    newSwingL = not na(pivotLow)
    
    if newSwingH
        swing.prevH := swing.currH
        swing.currH := pivotHigh
        highBroken := false  // Reset on new swing
    if newSwingL
        swing.prevL := swing.currL
        swing.currL := pivotLow
        lowBroken := false   // Reset on new swing
    
    // Track breaks
    if low < swing.currL
        lowBroken := true
    if high > swing.currH
        highBroken := true
    
    // Detect reclaims (broke and came back inside)
    reclaimedLow  = lowBroken and close > swing.currL
    reclaimedHigh = highBroken and close < swing.currH
    
    var int swingBias = 0
    if newSwingH
        swingBias := 1
    if newSwingL
        swingBias := -1
    
    [swing.currH, swing.currL, swingBias, newSwingH, newSwingL, swing.prevH, swing.prevL, reclaimedLow, reclaimedHigh]

// 3. Market Structure - tracks last 3 HH/HL/H/LL sequence
calcStructure() =>
    var SwingData swing = SwingData.new()
    
    // Track last 3 structure labels
    var string struct1  = "--"
    var string struct2  = "--"
    var string struct3  = "--"
    
    var int highType    = 0
    var int lowType     = 0
    
    if not na(pivotHigh)
        swing.prevH := swing.currH
        swing.currH := pivotHigh
        if not na(swing.prevH)
            highType := swing.currH > swing.prevH ? 1 : -1
            struct3 := struct2
            struct2 := struct1
            struct1 := highType > 0 ? "HH" : "LH"
    
    if not na(pivotLow)
        swing.prevL := swing.currL
        swing.currL := pivotLow
        if not na(swing.prevL)
            lowType := swing.currL > swing.prevL ? 1 : -1
            struct3 := struct2
            struct2 := struct1
            struct1 := lowType > 0 ? "HL" : "LL"
    
    // Real-time structure override
    rtHighType = highType
    rtLowType  = lowType
    rtStruct1  = struct1
    rtStruct2  = struct2
    rtStruct3  = struct3
    
    // If price breaks below previous swing low, that's a real-time LL
    if not na(swing.prevL) and close < swing.prevL
        rtLowType  := -1
        rtStruct3  := struct2
        rtStruct2  := struct1
        rtStruct1  := "LL"
    
    // If price breaks above previous swing high, that's a real-time HH
    if not na(swing.prevH) and close > swing.prevH
        rtHighType := 1
        rtStruct3  := struct2
        rtStruct2  := struct1
        rtStruct1  := "HH"
    
    structureBias = 0
    if rtHighType == 1 and rtLowType == 1
        structureBias := 1
    else if rtHighType == -1 and rtLowType == -1
        structureBias := -1
    
    [rtHighType, rtLowType, structureBias, rtStruct1, rtStruct2, rtStruct3]
findNearestZone(array<ZoneBlock> zones) =>
    nearestBullDist = 100000.0
    nearestBearDist = 100000.0
    
    zoneCount = zones.size()
    if zoneCount > 0
        for i = 0 to zoneCount - 1
            zone = zones.get(i)
            if zone.dir == 1
                dist = zone.top - close
                if math.abs(dist) < math.abs(nearestBullDist)
                    nearestBullDist := dist
            else
                dist = zone.bottom - close
                if math.abs(dist) < math.abs(nearestBearDist)
                    nearestBearDist := dist
    
    nearestDir  = 0
    nearestDist = 0.0
    
    if math.abs(nearestBullDist) < math.abs(nearestBearDist) and math.abs(nearestBullDist) < 100000.0
        nearestDir  := 1
        nearestDist := nearestBullDist
    else if math.abs(nearestBearDist) < 100000.0
        nearestDir  := -1
        nearestDist := nearestBearDist
    
    [nearestDir, nearestDist]

mitigateOBs(array<ZoneBlock> obs) =>
    obCount = obs.size()
    if obCount > 0
        for i = obCount - 1 to 0
            ob = obs.get(i)
            if ob.dir == 1 and close < ob.bottom
                obs.remove(i)
            else if ob.dir == -1 and close > ob.top
                obs.remove(i)

mitigateFVGs(array<ZoneBlock> fvgs) =>
    fvgCount = fvgs.size()
    if fvgCount > 0
        for i = fvgCount - 1 to 0
            fvg = fvgs.get(i)
            if fvg.dir == 1 and low < fvg.bottom
                fvgs.remove(i)
            else if fvg.dir == -1 and high > fvg.top
                fvgs.remove(i)

limitArraySize(array<ZoneBlock> arr, int maxSize) =>
    if arr.size() > maxSize
        arr.pop()

limitSwingLabels(array<SwingLabel> arr, int maxSize) =>
    if arr.size() > maxSize
        arr.shift()

findLowestCandle(int barsBack) =>
    search = CandleSearch.new(low, high, bar_index, barsBack)
    for i = 0 to math.max(0, math.min(barsBack, 50))
        if low[i] < search.price
            search.price      := low[i]
            search.otherPrice := high[i]
            search.barIdx     := bar_index - i
    search

findHighestCandle(int barsBack) =>
    search = CandleSearch.new(high, low, bar_index, barsBack)
    for i = 0 to math.max(0, math.min(barsBack, 50))
        if high[i] > search.price
            search.price      := high[i]
            search.otherPrice := low[i]
            search.barIdx     := bar_index - i
    search

hasOverlappingOB(int dir, float top, float bottom, array<ZoneBlock> obs) =>
    overlaps = false
    for ob in obs
        if ob.dir == dir and top >= ob.bottom and bottom <= ob.top
            overlaps := true
            break
    overlaps

detectOB(int dir, int pivotBar, array<ZoneBlock> obs, int maxOBs, ZoneResult result) =>
    barsBack = bar_index - pivotBar - 1
    search   = dir > 0 ? findLowestCandle(barsBack) : findHighestCandle(barsBack)
    
    newTop    = dir > 0 ? search.otherPrice : search.price
    newBottom = dir > 0 ? search.price      : search.otherPrice
    
    if not hasOverlappingOB(dir, newTop, newBottom, obs)
        result.dir    := dir
        result.top    := newTop
        result.bottom := newBottom
        result.barIdx := search.barIdx
        result.isNew  := true
        
        obs.unshift(ZoneBlock.new(dir, newTop, newBottom, search.barIdx))
        limitArraySize(obs, maxOBs)

detectOBSimple(int dir, int pivotBar, array<ZoneBlock> obs, int maxOBs) =>
    barsBack = bar_index - pivotBar - 1
    search   = dir > 0 ? findLowestCandle(barsBack) : findHighestCandle(barsBack)
    top      = dir > 0 ? search.otherPrice : search.price
    bottom   = dir > 0 ? search.price      : search.otherPrice
    
    if not hasOverlappingOB(dir, top, bottom, obs)
        obs.unshift(ZoneBlock.new(dir, top, bottom, search.barIdx))
        limitArraySize(obs, maxOBs)


trackPivotBreaks(PivotData pivot) =>
    bullBreak = false
    bearBreak = false
    bullBar   = 0
    bearBar   = 0
    
    // Track new pivots
    if not na(pivotHigh)
        pivot.lastPH    := pivotHigh
        pivot.lastPHBar := bar_index - swingLength
    
    if not na(pivotLow)
        pivot.lastPL    := pivotLow
        pivot.lastPLBar := bar_index - swingLength
    

    if isBreakAbove(pivot.lastPH) and not na(pivot.lastPHBar)
        bullBreak := true
        bullBar   := pivot.lastPHBar
        pivot.lastPH    := na
        pivot.lastPHBar := na
    
    if isBreakBelow(pivot.lastPL) and not na(pivot.lastPLBar)
        bearBreak := true
        bearBar   := pivot.lastPLBar
        pivot.lastPL    := na
        pivot.lastPLBar := na
    
    [bullBreak, bullBar, bearBreak, bearBar]


calcOrderBlock(maxOBs) =>
    var PivotData        pivot  = PivotData.new()
    var array<ZoneBlock> obs    = array.new<ZoneBlock>()
    var ZoneResult       result = ZoneResult.new()
    
    [bullBreak, bullBar, bearBreak, bearBar] = trackPivotBreaks(pivot)
    
    result.isNew := false
    
    if bullBreak
        detectOB(1, bullBar, obs, maxOBs, result)
    
    if bearBreak
        detectOB(-1, bearBar, obs, maxOBs, result)
    
    mitigateOBs(obs)
    [nearestDir, nearestDist] = findNearestZone(obs)
    
    [result.dir, result.top, result.bottom, result.isNew, nearestDir, nearestDist] 


detectFVGSignal() =>
    fvgDir    = 0
    fvgTop    = 0.0
    fvgBottom = 0.0
    fvgBar    = 0
    
    
    if bullFVG
        fvgDir    := 1
        fvgTop    := low[1]
        fvgBottom := high[3]
        fvgBar    := bar_index - 3
    
    // Bear FVG: gap down
    if bearFVG
        fvgDir    := -1
        fvgTop    := low[3]
        fvgBottom := high[1]
        fvgBar    := bar_index - 3
    
    [fvgDir, fvgTop, fvgBottom, fvgBar]

calcFVG(maxFVGs) =>
    var array<ZoneBlock> fvgs = array.new<ZoneBlock>()
    
    [fvgDir, fvgTop, fvgBottom, fvgBar] = detectFVGSignal()
    
    if fvgDir != 0
        fvgs.unshift(ZoneBlock.new(fvgDir, fvgTop, fvgBottom, fvgBar))
        limitArraySize(fvgs, maxFVGs)
    
    mitigateFVGs(fvgs)
    [nearestDir, nearestDist] = findNearestZone(fvgs)
    
    [fvgDir, fvgTop, fvgBottom, fvgDir != 0, nearestDir, nearestDist]

[currSwingH, currSwingL, _currSwingBias, currNewSwingH,     currNewSwingL,      currPrevSwingH,     currPrevSwingL, currReclaimLow, currReclaimHigh  ]   = calcSwingHL()
[currObDir,  currObTop,  currObBottom,   currNewOB,         _currObNearDir,     _currObNearDist ]                       = calcOrderBlock(obLookback)
[currFvgDir, currFvgTop, currFvgBottom,  currNewFVG,        _currFvgNearDir,    _currFvgNearDist]                       = calcFVG(fvgLookback)

var array<ZoneBlock> currTfOBs   = array.new<ZoneBlock>()
var array<box>       obBoxes     = array.new<box>()
var PivotData        currTfPivot = PivotData.new()

[currBullBreak, currBullBar, currBearBreak, currBearBar] = trackPivotBreaks(currTfPivot)

if currBullBreak
    detectOBSimple(1, currBullBar, currTfOBs, obLookback)

if currBearBreak
    detectOBSimple(-1, currBearBar, currTfOBs, obLookback)

mitigateOBs(currTfOBs)

var array<ZoneBlock> currTfFvgs = array.new<ZoneBlock>()
var array<box>       fvgBoxes   = array.new<box>()

[currFvgSigDir, currFvgSigTop, currFvgSigBottom, currFvgSigBar] = detectFVGSignal()

if currFvgSigDir != 0
    currTfFvgs.unshift(ZoneBlock.new(currFvgSigDir, currFvgSigTop, currFvgSigBottom, currFvgSigBar))
    limitArraySize(currTfFvgs, fvgLookback)

mitigateFVGs(currTfFvgs)

// Track swing labels
var SwingLineData     swingLines  = SwingLineData.new()
var array<SwingLabel> swingLabels = array.new<SwingLabel>()

if currNewSwingH
    swingLines.lastHBar := bar_index - swingLength
    
    labelText  = "HH"
    labelColor = color.new(swingBullColor, 80)
    labelTextColor = swingBullColor
    if not na(currPrevSwingH) and currSwingH < currPrevSwingH
        labelText  := "LH"
        labelColor := color.new(swingBearColor, 80)
        labelTextColor := swingBearColor
    swingLabels.push(SwingLabel.new(bar_index - swingLength, currSwingH, labelText, true, labelColor, labelTextColor))
    limitSwingLabels(swingLabels, swingLabelLookback)

if currNewSwingL
    swingLines.lastLBar := bar_index - swingLength
    
    labelText  = "HL"
    labelColor = color.new(swingBullColor, 80)
    labelTextColor = swingBullColor
    if not na(currPrevSwingL) and currSwingL < currPrevSwingL
        labelText  := "LL"
        labelColor := color.new(swingBearColor, 80)
        labelTextColor := swingBearColor
    swingLabels.push(SwingLabel.new(bar_index - swingLength, currSwingL, labelText, false, labelColor, labelTextColor))
    limitSwingLabels(swingLabels, swingLabelLookback)

calcAll() =>
    [trendDir, trendDist]                                                                               = calcTrend()
    [swingH, swingL, _swingBias, _newSwingH, _newSwingL, _prevSwingH, _prevSwingL, reclaimLow, reclaimHigh] = calcSwingHL()
    [_highType, _lowType, structBias, struct1, struct2, struct3]                                        = calcStructure()
    [_obDir,  _obTop,  _obBottom,  _newOB,  obNearDir,  obNearDist]                                     = calcOrderBlock(obLookback)
    [_fvgDir, _fvgTop, _fvgBottom, _newFVG, fvgNearDir, fvgNearDist]                                    = calcFVG(fvgLookback)
    [trendDir, trendDist, swingH, swingL, structBias, struct1, struct2, struct3, obNearDir, obNearDist, fvgNearDir, fvgNearDist, reclaimLow, reclaimHigh]

tfActive(enabled, tf) => enabled and timeframe.in_seconds() <= timeframe.in_seconds(tf)

// MTF data requests
[t1_trendDir, t1_trendDist, t1_swingH, t1_swingL, t1_structBias, t1_struct1, t1_struct2, t1_struct3, t1_obNearDir, t1_obNearDist, t1_fvgNearDir, t1_fvgNearDist, t1_reclaimLow, t1_reclaimHigh] = request.security(syminfo.tickerid, tfActive(tf1Enabled, tf1) ? tf1 : na, calcAll())
[t2_trendDir, t2_trendDist, t2_swingH, t2_swingL, t2_structBias, t2_struct1, t2_struct2, t2_struct3, t2_obNearDir, t2_obNearDist, t2_fvgNearDir, t2_fvgNearDist, t2_reclaimLow, t2_reclaimHigh] = request.security(syminfo.tickerid, tfActive(tf2Enabled, tf2) ? tf2 : na, calcAll())
[t3_trendDir, t3_trendDist, t3_swingH, t3_swingL, t3_structBias, t3_struct1, t3_struct2, t3_struct3, t3_obNearDir, t3_obNearDist, t3_fvgNearDir, t3_fvgNearDist, t3_reclaimLow, t3_reclaimHigh] = request.security(syminfo.tickerid, tfActive(tf3Enabled, tf3) ? tf3 : na, calcAll())
[t4_trendDir, t4_trendDist, t4_swingH, t4_swingL, t4_structBias, t4_struct1, t4_struct2, t4_struct3, t4_obNearDir, t4_obNearDist, t4_fvgNearDir, t4_fvgNearDist, t4_reclaimLow, t4_reclaimHigh] = request.security(syminfo.tickerid, tfActive(tf4Enabled, tf4) ? tf4 : na, calcAll())
[t5_trendDir, t5_trendDist, t5_swingH, t5_swingL, t5_structBias, t5_struct1, t5_struct2, t5_struct3, t5_obNearDir, t5_obNearDist, t5_fvgNearDir, t5_fvgNearDist, t5_reclaimLow, t5_reclaimHigh] = request.security(syminfo.tickerid, tfActive(tf5Enabled, tf5) ? tf5 : na, calcAll())
[t6_trendDir, t6_trendDist, t6_swingH, t6_swingL, t6_structBias, t6_struct1, t6_struct2, t6_struct3, t6_obNearDir, t6_obNearDist, t6_fvgNearDir, t6_fvgNearDist, t6_reclaimLow, t6_reclaimHigh] = request.security(syminfo.tickerid, tfActive(tf6Enabled, tf6) ? tf6 : na, calcAll())
[t7_trendDir, t7_trendDist, t7_swingH, t7_swingL, t7_structBias, t7_struct1, t7_struct2, t7_struct3, t7_obNearDir, t7_obNearDist, t7_fvgNearDir, t7_fvgNearDist, t7_reclaimLow, t7_reclaimHigh] = request.security(syminfo.tickerid, tfActive(tf7Enabled, tf7) ? tf7 : na, calcAll())

dirScore(dir) => dir > 0 ? 1 : dir < 0 ? -1 : 0

swingBiasDir(swingH, swingL) =>
    swingRange = math.max(swingH - swingL, syminfo.mintick)
    swingPct   = (close - swingL) / swingRange * 100
    swingPct < 0 ? -1 : swingPct > 100 ? 1 : swingPct < 30 ? 1 : swingPct > 70 ? -1 : 0

calcBiasForTf(structBias, obDir, fvgDir, trendDir, swingDir, weight) =>
    score = 0
    if biasUseStruct
        score += dirScore(structBias)
    if biasUseOB
        score += dirScore(obDir)
    if biasUseFVG
        score += dirScore(fvgDir)
    if biasUseEMA
        score += dirScore(trendDir)
    if biasUseSwing
        score += swingDir
    score * weight

// Count active factors for max score calculation
biasFactorCount() =>
    count = 0
    if biasUseStruct
        count += 1
    if biasUseOB
        count += 1
    if biasUseFVG
        count += 1
    if biasUseEMA
        count += 1
    if biasUseSwing
        count += 1
    count

dirColor(dir) => dir > 0 ? bullColor : dir < 0 ? bearColor : neutColor

fmtTF(tf) =>
    switch tf
        "1"   => "1M"
        "3"   => "3M"
        "5"   => "5M"
        "15"  => "15M"
        "30"  => "30M"
        "45"  => "45M"
        "60"  => "1H"
        "120" => "2H"
        "180" => "3H"
        "240" => "4H"
        "D"   => "D"
        "W"   => "W"
        "M"   => "M"
        => tf

fmtPct(dir, priceDist) =>
    arrow = dir > 0 ? " ↑" : " ↓"
    switch distanceMode
        "Price"   => str.tostring(math.abs(priceDist), "#.##") + arrow
        "Pips"    => str.tostring(math.abs(priceToPips(priceDist)), "#.#") + " pips" + arrow
        => str.tostring(priceToPct(priceDist), "#.##") + "%" + arrow

fmtSwingBar(swingH, swingL, reclaimLow, reclaimHigh) =>
    swingRange  = math.max(swingH - swingL, syminfo.mintick)
    rawPct      = pct(close - swingL, swingRange)
    bars        = 9
    
    barText     = ""
    barColor    = neutColor
    
    if rawPct < 0
        // Price below swing low - broke swing low
        barText  := "↓ L " + str.repeat("─", bars) + " H  "
        barColor := bearColor
    else if rawPct > 100
        // Price above swing high - broke swing high
        barText  := "  L " + str.repeat("─", bars) + " H ↑"
        barColor := bullColor
    else if reclaimLow
        // Swept low, back inside - bullish signal (liquidity grab)
        pos      = math.round(rawPct / 100 * (bars - 1))
        left     = str.repeat("─", pos)
        right    = str.repeat("─", bars - 1 - pos)
        barText  := "⤴ L " + left + "⬤" + right + " H  "
        barColor := bullColor
    else if reclaimHigh
        // Swept high, back inside - bearish signal (liquidity grab)
        pos      = math.round(rawPct / 100 * (bars - 1))
        left     = str.repeat("─", pos)
        right    = str.repeat("─", bars - 1 - pos)
        barText  := "  L " + left + "⬤" + right + " H ⤵"
        barColor := bearColor
    else
        // Price inside range
        pos      = math.round(rawPct / 100 * (bars - 1))
        left     = str.repeat("─", pos)
        right    = str.repeat("─", bars - 1 - pos)
        barText  := "  L " + left + "⬤" + right + " H  "
        barColor := rawPct >= 50 ? bearColor : bullColor
    
    [barText, barColor, rawPct]

fmtStructure(struct1, struct2, struct3, structBias) =>
    arrow = structBias == 1 ? " ↑" : structBias == -1 ? " ↓" : " →"
    struct3 + "-" + struct2 + "-" + struct1 + arrow

fmtZone(zoneType, nearestDir, nearestDist) =>
    if nearestDir == 0
        "NONE"
    else if nearestDir == 1
        if nearestDist >= 0
            "IN BULL " + zoneType + " ↑"
        else
            distStr = switch distanceMode
                "Price" => str.tostring(math.abs(nearestDist), "#.##")
                "Pips"  => str.tostring(math.abs(priceToPips(nearestDist)), "#.#") + " pips"
                => str.tostring(math.abs(priceToPct(nearestDist)), "#.#") + "%"
            "BULL " + zoneType + " (" + distStr + ") ↑"
    else
        if nearestDist <= 0
            "IN BEAR " + zoneType + " ↓"
        else
            distStr = switch distanceMode
                "Price" => str.tostring(nearestDist, "#.##")
                "Pips"  => str.tostring(priceToPips(nearestDist), "#.#") + " pips"
                => str.tostring(priceToPct(nearestDist), "#.#") + "%"
            "BEAR " + zoneType + " (+" + distStr + ") ↓"

fmtOB(nearestDir, nearestDist)  => fmtZone("OB", nearestDir, nearestDist)
fmtFVG(nearestDir, nearestDist) => fmtZone("FVG", nearestDir, nearestDist)


tipZone(zoneType, nearestDir, nearestDist, tf) =>
    tfStr = fmtTF(tf)
    distStr = switch distanceMode
        "Price" => str.tostring(math.abs(nearestDist), "#.##")
        "Pips"  => str.tostring(math.abs(priceToPips(nearestDist)), "#.#") + " pips"
        => str.tostring(math.abs(priceToPct(nearestDist)), "#.##") + "%"
    if nearestDir == 0
        "No unmitigated " + zoneType + "s on " + tfStr
    else if nearestDir == 1
        if nearestDist >= 0
            "Price is currently in bullish " + zoneType + " on " + tfStr
        else
            "Nearest " + zoneType + " is bullish, " + distStr + " away on " + tfStr
    else
        if nearestDist <= 0
            "Price is currently in bearish " + zoneType + " on " + tfStr
        else
            "Nearest " + zoneType + " is bearish, " + distStr + " away on " + tfStr

tipOB(nearestDir, nearestDist, tf)  => tipZone("OB", nearestDir, nearestDist, tf)
tipFVG(nearestDir, nearestDist, tf) => tipZone("FVG", nearestDir, nearestDist, tf)


tipEma(trendDir, trendDist, tf) =>
    tfStr = fmtTF(tf)
    distStr = switch distanceMode
        "Price" => str.tostring(math.abs(trendDist), "#.##")
        "Pips"  => str.tostring(math.abs(priceToPips(trendDist)), "#.#") + " pips"
        => str.tostring(math.abs(priceToPct(trendDist)), "#.##") + "%"
    if trendDir > 0
        "Price is " + distStr + " above EMA on " + tfStr
    else if trendDir < 0
        "Price is " + distStr + " below EMA on " + tfStr
    else
        "Price is at EMA on " + tfStr


tipSwing(swingPct, reclaimLow, reclaimHigh, tf) =>
    tfStr = fmtTF(tf)
    if reclaimLow
        "Liquidity sweep - price swept swing low and reclaimed on " + tfStr
    else if reclaimHigh
        "Liquidity sweep - price swept swing high and reclaimed on " + tfStr
    else if swingPct < 0
        "Price below swing low on " + tfStr + " - swing low broken"
    else if swingPct > 100
        "Price above swing high on " + tfStr + " - swing high broken"
    else if swingPct <= 30
        "Price nearing swing low on " + tfStr
    else if swingPct >= 70
        "Price nearing swing high on " + tfStr
    else
        "Price in mid-range on " + tfStr


tipStructure(structBias, tf) =>
    tfStr = fmtTF(tf)
    if structBias == 1
        "Bullish market structure on " + tfStr
    else if structBias == -1
        "Bearish market structure on " + tfStr
    else
        "Mixed market structure on " + tfStr


getSession(hr) =>
    sessName  = ""
    sessColor = GRAY
    sessStart = 0
    sessDur   = 0
    
    if hr >= 19 or hr < 3
        sessName  := "ASIAN"
        sessColor := sessAsianColor
        sessStart := 19
        sessDur   := 8
    else if hr >= 8 and hr < 17
        sessName  := "NEW YORK"
        sessColor := sessNyColor
        sessStart := 8
        sessDur   := 9
    else if hr >= 3 and hr < 8
        sessName  := "LONDON"
        sessColor := sessLondonColor
        sessStart := 3
        sessDur   := 9//9 for visual purpose only
    else
        sessName := "OFF HOURS"
    
    [sessName, sessColor, sessStart, sessDur]


getKillzone(hr, mins, neutralColor) =>
    kzName    = ""
    kzColor   = neutralColor
    nextText  = ""
    nextColor = neutralColor
    
    currentMins   = hr * 60 + mins
    
    // ICT Killzones
    asianKzStart  = 20 * 60           // 20:00
    asianKzEnd    = 24 * 60           // 00:00
    londonKzStart = 2 * 60            // 02:00
    londonKzEnd   = 5 * 60            // 05:00
    nyAmKzStart   = 9 * 60 + 30       // 09:30
    nyAmKzEnd     = 11 * 60           // 11:00
    nyLunchStart  = 12 * 60           // 12:00
    nyLunchEnd    = 13 * 60           // 13:00
    nyPmKzStart   = 13 * 60 + 30      // 13:30
    nyPmKzEnd     = 16 * 60           // 16:00
    
    if currentMins >= asianKzStart or currentMins < 0
        kzName    := "ASIAN KZ"
        kzColor   := kzAsianColor
        nextColor := kzAsianColor
    else if currentMins >= londonKzStart and currentMins < londonKzEnd
        kzName    := "LONDON KZ"
        kzColor   := kzLondonColor
        nextColor := kzLondonColor
    else if currentMins >= nyAmKzStart and currentMins < nyAmKzEnd
        kzName    := "NY AM KZ"
        kzColor   := kzNyAmColor
        nextColor := kzNyAmColor
    else if currentMins >= nyLunchStart and currentMins < nyLunchEnd
        kzName    := "NY LUNCH"
        kzColor   := kzLunchColor
        nextColor := kzLunchColor
    else if currentMins >= nyPmKzStart and currentMins < nyPmKzEnd
        kzName    := "NY PM KZ"
        kzColor   := kzPmColor
        nextColor := kzPmColor
    else
        kzName  := "NO KILLZONE"
        kzColor := neutColor
        
        nextKzName    = ""
        minutesToNext = 0
        
        if currentMins < londonKzStart
            nextKzName    := "LONDON KZ"
            minutesToNext := londonKzStart - currentMins
            nextColor     := kzLondonColor
        else if currentMins < nyAmKzStart
            nextKzName    := "NY AM KZ"
            minutesToNext := nyAmKzStart - currentMins
            nextColor     := kzNyAmColor
        else if currentMins < nyLunchStart
            nextKzName    := "NY LUNCH"
            minutesToNext := nyLunchStart - currentMins
            nextColor     := kzLunchColor
        else if currentMins < nyPmKzStart
            nextKzName    := "NY PM KZ"
            minutesToNext := nyPmKzStart - currentMins
            nextColor     := kzPmColor
        else if currentMins < asianKzStart
            nextKzName    := "ASIAN KZ"
            minutesToNext := asianKzStart - currentMins
            nextColor     := kzAsianColor
        
        nextKzHours = math.floor(minutesToNext / 60)
        nextKzMins  = minutesToNext % 60
        nextText    := nextKzName + " in " + str.tostring(nextKzHours) + "h:" + str.tostring(nextKzMins, "00") + "m"
    
    [kzName, kzColor, nextText, nextColor]


drawMsdRow(tbl, row, tfStr, trendDir, trendDist, swingBar, swingColor, swingPct, reclaimLow, reclaimHigh, structBias, struct1, struct2, struct3, obNearDir, obNearDist, fvgNearDir, fvgNearDist, tf) =>
    col = 0
    table.cell(tbl, col, row, tfStr, text_color = textCol, text_size = tblTextSize, bgcolor = color.new(bgRow, 15))
    if showColSwing
        col += 1
        table.cell(tbl, col, row, swingBar,                                             text_color = swingColor,           text_size = tblTextSize, tooltip = tipSwing(swingPct, reclaimLow, reclaimHigh, tf))
    if showColStruct
        col += 1
        table.cell(tbl, col, row, fmtStructure(struct1, struct2, struct3, structBias),  text_color = dirColor(structBias), text_size = tblTextSize, tooltip = tipStructure(structBias, tf))
    if showColOB
        col += 1
        table.cell(tbl, col, row, fmtOB(obNearDir, obNearDist),                         text_color = dirColor(obNearDir),  text_size = tblTextSize, tooltip = tipOB(obNearDir, obNearDist, tf))
    if showColFVG
        col += 1
        table.cell(tbl, col, row, fmtFVG(fvgNearDir, fvgNearDist),                      text_color = dirColor(fvgNearDir), text_size = tblTextSize, tooltip = tipFVG(fvgNearDir, fvgNearDist, tf))
    if showColEma
        col += 1
        table.cell(tbl, col, row, fmtPct(trendDir, trendDist),                           text_color = dirColor(trendDir),   text_size = tblTextSize, tooltip = tipEma(trendDir, trendDist, tf))


drawBottomHeaders(tbl, row) =>
    col = 0
    if showCurrTF
        if showCurrVol
            table.cell(tbl, col, row, "VOLUME",     text_color = textCol, text_size = size.normal, tooltip = "Current volume")
            col += 1
        if showCurrSwing
            table.cell(tbl, col, row, "SWING H/L",  text_color = textCol, text_size = size.normal, tooltip = "Price position within current swing range")
            col += 1
        if showCurrAtr
            table.cell(tbl, col, row, "VOLATILITY", text_color = textCol, text_size = size.normal, tooltip = "Current volatility")
            col += 1
    if showContext
        if showSession
            table.cell(tbl, col, row, "SESSION",    text_color = textCol, text_size = size.normal, tooltip = "Current trading session")
            col += 1
        if showKillzone
            table.cell(tbl, col, row, "KILLZONE",   text_color = textCol, text_size = size.normal, tooltip = "Current killzone")
            col += 1
        if showBias
            table.cell(tbl, col, row, "TREND BIAS", text_color = textCol, text_size = size.normal, tooltip = "Current trend bias")
            col += 1


drawBottomData1(tbl, row, swingText, swingColor, tipSwing, volBar, volColor, tipVol, volState, volStateColor, tipVolState, sessName, sessColor, tipSess, kzName, kzColor, tipKz, biasLbl, biasClr, tipBias) =>
    col = 0
    if showCurrTF
        if showCurrVol
            table.cell(tbl, col, row, volBar,    text_color = volColor,       text_size = tblTextSize, tooltip = tipVol)
            col += 1
        if showCurrSwing
            table.cell(tbl, col, row, swingText, text_color = swingColor,     text_size = tblTextSize, tooltip = tipSwing)
            col += 1
        if showCurrAtr
            table.cell(tbl, col, row, volState,  text_color = volStateColor,  text_size = tblTextSize, tooltip = tipVolState)
            col += 1
    if showContext
        if showSession
            table.cell(tbl, col, row, sessName,  text_color = sessColor,      text_size = tblTextSize, tooltip = tipSess)
            col += 1
        if showKillzone
            table.cell(tbl, col, row, kzName,    text_color = kzColor,        text_size = tblTextSize, tooltip = tipKz)
            col += 1
        if showBias
            table.cell(tbl, col, row, biasLbl,   text_color = biasClr,        text_size = tblTextSize, tooltip = tipBias)
            col += 1


drawBottomData2(tbl, row, swingColor, volState, volColor, sessProgress, sessColor, tipSessProg, nextKz, nextKzClr, tipNextKz, biasScr, biasClr) =>
    col = 0
    if showCurrTF
        if showCurrVol
            table.cell(tbl, col, row, volState,     text_color = volColor,   text_size = tblTextSize)
            col += 1
        if showCurrSwing
            table.cell(tbl, col, row, "",           text_color = swingColor, text_size = tblTextSize)
            col += 1
        if showCurrAtr
            table.cell(tbl, col, row, "",           text_color = volColor,   text_size = tblTextSize)
            col += 1
    if showContext
        if showSession
            table.cell(tbl, col, row, sessProgress, text_color = sessColor,  text_size = tblTextSize, tooltip = tipSessProg)
            col += 1
        if showKillzone
            table.cell(tbl, col, row, nextKz,       text_color = nextKzClr,  text_size = tblTextSize, tooltip = tipNextKz)
            col += 1
        if showBias
            table.cell(tbl, col, row, biasScr,      text_color = biasClr,    text_size = tblTextSize)
            col += 1


drawHTFRows(tbl, startRow, pdBar, pdColor, tipPD, pwBar, pwColor, tipPW, pmBar, pmColor, tipPM) =>
    row = startRow
    if showHTFLevels
        if showPDHL
            table.cell(tbl, 0, row, "PDH/L", text_color = textCol, text_size = tblTextSize, bgcolor = color.new(bgRow, 15))
            table.cell(tbl, 1, row, pdBar, text_color = pdColor, text_size = tblTextSize, tooltip = tipPD)
            row += 1
        if showPWHL
            table.cell(tbl, 0, row, "PWH/L", text_color = textCol, text_size = tblTextSize, bgcolor = color.new(bgRow, 15))
            table.cell(tbl, 1, row, pwBar, text_color = pwColor, text_size = tblTextSize, tooltip = tipPW)
            row += 1
        if showPMHL
            table.cell(tbl, 0, row, "PMH/L", text_color = textCol, text_size = tblTextSize, bgcolor = color.new(bgRow, 15))
            table.cell(tbl, 1, row, pmBar, text_color = pmColor, text_size = tblTextSize, tooltip = tipPM)



fireAlert(msg, dir) =>
    alert(msg, alert.freq_once_per_bar)
    if alertDebugLabels
        clr = dir > 0 ? bullColor : dir < 0 ? bearColor : neutColor
        label.new(bar_index, dir <= 0 ? high : low, msg,
             style     = dir <= 0 ? label.style_label_down : label.style_label_up,
             yloc      = dir <= 0 ? yloc.abovebar : yloc.belowbar,
             color     = color.new(clr, 80),
             textcolor = clr,
             size      = size.normal)


swingState(pct, reclaimLow, reclaimHigh) =>
    reclaimLow ? 2 : reclaimHigh ? -2 : pct < 0 ? -1 : pct > 100 ? 1 : 0

zoneInState(nearDir, nearDist) =>
    nearDir == 1 and nearDist >= 0 ? 1 : nearDir == -1 and nearDist <= 0 ? -1 : 0


barHour   = hour(time, "America/New_York")
barMinute = minute(time, "America/New_York")

[barSessionName,  _barSessColor, _barSessStart, _barSessDur]   = getSession(barHour)
[barKillzoneName, _barKzColor,   _barNextKz,    _barNextKzClr] = getKillzone(barHour, barMinute, neutColor)


msdAlerts(tfLabel, active, swingPct, reclaimLow, reclaimHigh, structBias, obNearDir, obNearDist, fvgNearDir, fvgNearDist, trendDir, TfAlertState prev) =>

    newSwingSt = swingState(swingPct, reclaimLow, reclaimHigh)
    newOBIn    = zoneInState(obNearDir, obNearDist)
    newFVGIn   = zoneInState(fvgNearDir, fvgNearDist)

    if active
        // Swing Breaks
        if alertMsdSwingBreak and newSwingSt != prev.swingSt
            if newSwingSt == 1
                fireAlert("⚡ [" + tfLabel + "] Swing High Broken", 1)
            if newSwingSt == -1
                fireAlert("⚡ [" + tfLabel + "] Swing Low Broken", -1)

        // Swing Sweeps
        if alertMsdSwingSweep and newSwingSt != prev.swingSt
            if newSwingSt == 2
                fireAlert("🔄 [" + tfLabel + "] Swing Low Swept & Reclaimed ⤴", 1)
            if newSwingSt == -2
                fireAlert("🔄 [" + tfLabel + "] Swing High Swept & Reclaimed ⤵", -1)

        // Structure Bias Change
        if alertMsdStruct and structBias != prev.structSt
            biasStr = structBias == 1 ? "Bullish ↑" : structBias == -1 ? "Bearish ↓" : "Neutral →"
            fireAlert("📊 [" + tfLabel + "] Structure → " + biasStr, structBias)

        // Price enters OB
        if alertMsdOBEnter and newOBIn != prev.obIn and newOBIn != 0
            obStr = newOBIn == 1 ? "IN BULL OB ↑" : "IN BEAR OB ↓"
            fireAlert("🟧 [" + tfLabel + "] " + obStr, newOBIn)

        // OB Direction Change
        if alertMsdOBChange and obNearDir != prev.obDir
            obDirStr = obNearDir == 1 ? "Bull OB ↑" : obNearDir == -1 ? "Bear OB ↓" : "None"
            fireAlert("🟧 [" + tfLabel + "] Nearest OB → " + obDirStr, obNearDir)

        // Price enters FVG
        if alertMsdFVGEnter and newFVGIn != prev.fvgIn and newFVGIn != 0
            fvgStr = newFVGIn == 1 ? "IN BULL FVG ↑" : "IN BEAR FVG ↓"
            fireAlert("🟪 [" + tfLabel + "] " + fvgStr, newFVGIn)

        // FVG Direction Change
        if alertMsdFVGChange and fvgNearDir != prev.fvgDir
            fvgDirStr = fvgNearDir == 1 ? "Bull FVG ↑" : fvgNearDir == -1 ? "Bear FVG ↓" : "None"
            fireAlert("🟪 [" + tfLabel + "] Nearest FVG → " + fvgDirStr, fvgNearDir)

        // EMA Trend Change
        if alertMsdEma and trendDir != prev.ema and prev.ema != 0
            emaStr = trendDir == 1 ? "Bullish ↑" : "Bearish ↓"
            fireAlert("📈 [" + tfLabel + "] EMA Trend → " + emaStr, trendDir)

    // Update state in place
    prev.swingSt := newSwingSt
    prev.structSt := structBias
    prev.obIn    := newOBIn
    prev.obDir   := obNearDir
    prev.fvgIn   := newFVGIn
    prev.fvgDir  := fvgNearDir
    prev.ema     := trendDir

//#endregion FUNCTIONS

//#region CALCULATIONS

[t1_swingBar, t1_swingColor, t1_swingPct] = fmtSwingBar(t1_swingH, t1_swingL, t1_reclaimLow, t1_reclaimHigh)
[t2_swingBar, t2_swingColor, t2_swingPct] = fmtSwingBar(t2_swingH, t2_swingL, t2_reclaimLow, t2_reclaimHigh)
[t3_swingBar, t3_swingColor, t3_swingPct] = fmtSwingBar(t3_swingH, t3_swingL, t3_reclaimLow, t3_reclaimHigh)
[t4_swingBar, t4_swingColor, t4_swingPct] = fmtSwingBar(t4_swingH, t4_swingL, t4_reclaimLow, t4_reclaimHigh)
[t5_swingBar, t5_swingColor, t5_swingPct] = fmtSwingBar(t5_swingH, t5_swingL, t5_reclaimLow, t5_reclaimHigh)
[t6_swingBar, t6_swingColor, t6_swingPct] = fmtSwingBar(t6_swingH, t6_swingL, t6_reclaimLow, t6_reclaimHigh)
[t7_swingBar, t7_swingColor, t7_swingPct] = fmtSwingBar(t7_swingH, t7_swingL, t7_reclaimLow, t7_reclaimHigh)


// Current TF swing bar
currSwingRange    = math.max(currSwingH - currSwingL, syminfo.mintick)
currSwingPct      = pct(close - currSwingL, currSwingRange)
currBars          = 9

currSwingBarText  = ""
currSwingBarColor = neutColor

if currSwingPct < 0
    // Price below swing low - swing low broken
    currSwingBarText  := "↓ L " + str.repeat("─", currBars) + " H  "
    currSwingBarColor := bearColor
else if currSwingPct > 100
    // Price above swing high - swing high broken
    currSwingBarText  := "  L " + str.repeat("─", currBars) + " H ↑"
    currSwingBarColor := bullColor
else if currReclaimLow
    // Swept low, back inside - bullish signal (liquidity grab)
    currPos           = math.round(currSwingPct / 100 * (currBars - 1))
    currLeft          = str.repeat("─", currPos)
    currRight         = str.repeat("─", currBars - 1 - currPos)
    currSwingBarText  := "⤴ L " + currLeft + "⬤" + currRight + " H  "
    currSwingBarColor := bullColor
else if currReclaimHigh
    // Swept high, back inside - bearish signal (liquidity grab)
    currPos           = math.round(currSwingPct / 100 * (currBars - 1))
    currLeft          = str.repeat("─", currPos)
    currRight         = str.repeat("─", currBars - 1 - currPos)
    currSwingBarText  := "  L " + currLeft + "⬤" + currRight + " H ⤵"
    currSwingBarColor := bearColor
else
    // Price inside range
    currPos           = math.round(currSwingPct / 100 * (currBars - 1))
    currLeft          = str.repeat("─", currPos)
    currRight         = str.repeat("─", currBars - 1 - currPos)
    currSwingBarText  := "  L " + currLeft + "⬤" + currRight + " H  "
    currSwingBarColor := currSwingPct >= 50 ? bearColor : bullColor

// Volume calculations
volumeLength    = 20
avgVolume       = ta.sma(volume, volumeLength)
volumePct       = pct(volume, avgVolume)
volumeState     = volumePct > 200 ? "EXTREME" : volumePct > 120 ? "HIGH" : volumePct > 80 ? "NORMAL" : volumePct > 50 ? "LOW" : "VERY LOW"
volumeBars      = volumePct > 200 ? 5 : volumePct > 120 ? 4 : volumePct > 80 ? 3 : volumePct > 50 ? 2 : 1
volumeBarString = str.repeat("█", volumeBars) + str.repeat("░", math.max(0, 5 - volumeBars))
volumeColor     = volumePct > 200 ? YELLOW : volumePct > 120 ? ORANGE : neutColor

// Volatility calculations
currentATR      = ta.atr(atrLength)
avgATR          = ta.sma(currentATR, atrAvgLength)
atrPct          = pct(currentATR, avgATR)

volatilityState = atrPct > 130 ? "HIGH"    : atrPct > 70 ? "NORMAL"  : "LOW"
volatilityColor = atrPct > 130 ? bearColor : atrPct > 70 ? neutColor : bullColor

// HTF Levels (PDH/L, PWH/L, PMH/L)
[pdHigh, pdLow] = request.security(syminfo.tickerid, "D", [high[1], low[1]], lookahead = barmerge.lookahead_on)
[pwHigh, pwLow] = request.security(syminfo.tickerid, "W", [high[1], low[1]], lookahead = barmerge.lookahead_on)
[pmHigh, pmLow] = request.security(syminfo.tickerid, "M", [high[1], low[1]], lookahead = barmerge.lookahead_on)

// HTF Levels reclaim tracking
// Track HTF level breaks and reclaims
trackHTFLevel(levelHigh, levelLow,  tf) =>
    var bool lowBroken  = false
    var bool highBroken = false
    
    if timeframe.change(tf)
        lowBroken  := false
        highBroken := false
    
    if low < levelLow
        lowBroken := true
    if high > levelHigh
        highBroken := true
    
    reclaimLow  = lowBroken and close > levelLow
    reclaimHigh = highBroken and close < levelHigh
    
    [reclaimLow, reclaimHigh]

// HTF Levels reclaim detection
[pdReclaimLow, pdReclaimHigh] = trackHTFLevel(pdHigh, pdLow, "D")
[pwReclaimLow, pwReclaimHigh] = trackHTFLevel(pwHigh, pwLow, "W")
[pmReclaimLow, pmReclaimHigh] = trackHTFLevel(pmHigh, pmLow, "M")

// Format HTF level bars
[pdSwingBar, pdSwingColor, pdSwingPct] = fmtSwingBar(pdHigh, pdLow, pdReclaimLow, pdReclaimHigh)
[pwSwingBar, pwSwingColor, pwSwingPct] = fmtSwingBar(pwHigh, pwLow, pwReclaimLow, pwReclaimHigh)
[pmSwingBar, pmSwingColor, pmSwingPct] = fmtSwingBar(pmHigh, pmLow, pmReclaimLow, pmReclaimHigh)

// HTF Levels tooltips
tipPD = pdReclaimLow ? "Liquidity sweep - price swept PDL and reclaimed" : pdReclaimHigh ? "Liquidity sweep - price swept PDH and reclaimed" : pdSwingPct < 0 ? "Price below PDL - previous day low broken" : pdSwingPct > 100 ? "Price above PDH - previous day high broken" : pdSwingPct <= 30 ? "Price nearing PDL" : pdSwingPct >= 70 ? "Price nearing PDH" : "Price in previous day range"
tipPW = pwReclaimLow ? "Liquidity sweep - price swept PWL and reclaimed" : pwReclaimHigh ? "Liquidity sweep - price swept PWH and reclaimed" : pwSwingPct < 0 ? "Price below PWL - previous week low broken" : pwSwingPct > 100 ? "Price above PWH - previous week high broken" : pwSwingPct <= 30 ? "Price nearing PWL" : pwSwingPct >= 70 ? "Price nearing PWH" : "Price in previous week range"
tipPM = pmReclaimLow ? "Liquidity sweep - price swept PML and reclaimed" : pmReclaimHigh ? "Liquidity sweep - price swept PMH and reclaimed" : pmSwingPct < 0 ? "Price below PML - previous month low broken" : pmSwingPct > 100 ? "Price above PMH - previous month high broken" : pmSwingPct <= 30 ? "Price nearing PML" : pmSwingPct >= 70 ? "Price nearing PMH" : "Price in previous month range"

// Session and killzone detection (with replay mode support)
isReplay        = (timenow - time) > timeframe.in_seconds() * 1000 and barstate.islast
sessionTime     = isReplay ? time : timenow
currentHour     = hour(sessionTime,   "America/New_York")
currentMinute   = minute(sessionTime, "America/New_York")

[sessionName, sessionColor, sessionStartHour, sessionDuration] = getSession(currentHour)
[killzoneName, killzoneColor, nextKzText, nextKzColor]         = getKillzone(currentHour, currentMinute, neutColor)

// Session progress bar (adds bar at 30 min mark)
hoursElapsed       = 0
sessionProgressBar = ""
if sessionName != "OFF HOURS"
    minsIntoSession    = sessionName == "ASIAN" and currentHour < 3 ? ((currentHour + 24 - sessionStartHour) * 60 + currentMinute) : ((currentHour - sessionStartHour) * 60 + currentMinute)
    hoursElapsed       := math.floor((minsIntoSession + 30) / 60)
    hoursElapsed       := math.min(hoursElapsed, sessionDuration)
    sessionProgressBar := str.repeat("█", hoursElapsed) + str.repeat("░", math.max(0, sessionDuration - hoursElapsed))

// Trend Bias Calculation (User Weighted)
tfWeights    = array.from(tf1Weight, tf2Weight, tf3Weight, tf4Weight, tf5Weight, tf6Weight, tf7Weight)
tfActives    = array.from(tfActive(tf1Enabled, tf1),    tfActive(tf2Enabled, tf2),  tfActive(tf3Enabled, tf3),  tfActive(tf4Enabled, tf4),  tfActive(tf5Enabled, tf5),  tfActive(tf6Enabled, tf6),  tfActive(tf7Enabled, tf7))
structBiases = array.from(t1_structBias, t2_structBias, t3_structBias, t4_structBias, t5_structBias, t6_structBias, t7_structBias)
obDirs       = array.from(t1_obNearDir,  t2_obNearDir,  t3_obNearDir,  t4_obNearDir,  t5_obNearDir,  t6_obNearDir,  t7_obNearDir)
fvgDirs      = array.from(t1_fvgNearDir, t2_fvgNearDir, t3_fvgNearDir, t4_fvgNearDir, t5_fvgNearDir, t6_fvgNearDir, t7_fvgNearDir)
trendDirs    = array.from(t1_trendDir,   t2_trendDir,   t3_trendDir,   t4_trendDir,   t5_trendDir,   t6_trendDir,   t7_trendDir)
swingDirs    = array.from(swingBiasDir(t1_swingH, t1_swingL), swingBiasDir(t2_swingH, t2_swingL), swingBiasDir(t3_swingH, t3_swingL), swingBiasDir(t4_swingH, t4_swingL), swingBiasDir(t5_swingH, t5_swingL), swingBiasDir(t6_swingH, t6_swingL), swingBiasDir(t7_swingH, t7_swingL))

// Calculate max possible score and bias points
factorCount = biasFactorCount()
maxScore    = 0
biasPoints  = 0
for i = 0 to 6
    weight = tfWeights.get(i)
    if tfActives.get(i) and weight > 0
        maxScore   += weight * factorCount
        biasPoints += calcBiasForTf(structBiases.get(i), obDirs.get(i), fvgDirs.get(i), trendDirs.get(i), swingDirs.get(i), weight)

// Format bias display
biasPct     = maxScore > 0 ? (biasPoints / maxScore) * 100 : 0
biasLabel   = maxScore == 0 ? "N/A" : biasPct > 50 ? "BULLISH ↑" : biasPct > 20 ? "LEAN BULL ↑" : biasPct < -50 ? "BEARISH ↓" : biasPct < -20 ? "LEAN BEAR ↓" : "NEUTRAL →"
biasScore   = maxScore == 0 ? "--" : (biasPoints >= 0 ? "+" : "") + str.tostring(biasPoints) + "/" + str.tostring(maxScore)
biasColor   = maxScore == 0 ? neutColor : biasPct > 20 ? bullColor : biasPct < -20 ? bearColor : neutColor

// Dynamic tooltips
tipKillzone    = killzoneName == "NO KILLZONE" ? "No active killzone"                     : "Currently in " + killzoneName
tipNextKz      = killzoneName == "NO KILLZONE" ? "Next killzone: " + nextKzText           : "Currently in " + killzoneName
tipSession     = sessionName  == "OFF HOURS"   ? "Market is currently not in any session" : "Currently in " + sessionName + " session"
tipSessionProg = sessionName  == "OFF HOURS"   ? "Market is currently not in any session" : str.tostring(hoursElapsed) + " of " + str.tostring(sessionDuration) + " hours elapsed in " + sessionName + " session"
tipBiasLabel   = "Current Trend Bias: " + (biasPct > 50 ? "Bullish" : biasPct > 20 ? "Leaning Bullish" : biasPct < -50 ? "Bearish" : biasPct < -20 ? "Leaning Bearish" : "Neutral") + " based on HTF analysis"
tipVolume      = "Volume is currently at " + str.tostring(volumePct, "#") + "% of average"
tipVolatility  = "Volatility is currently " + (atrPct > 130 ? "high" : atrPct > 70 ? "normal" : "low")
tipCurrSwing   = currReclaimLow ? "Liquidity sweep - price swept swing low and reclaimed" : currReclaimHigh ? "Liquidity sweep - price swept swing high and reclaimed" : currSwingPct < 0 ? "Price below swing low - swing low broken" : currSwingPct > 100 ? "Price above swing high - swing high broken" : currSwingPct <= 30 ? "Price is nearing swing low" : currSwingPct >= 70 ? "Price is nearing swing high" : "Price is in mid-range"
//#endregion CALCULATIONS

//#region VISUALIZATION
var table dashboard = table.new(tablePos, 7, 18, 
    bgcolor      = bgDark, 
    border_color = #3d3d3d, 
    border_width = 1)

if barstate.islast
    // Market Structure Dashboard section
    if showMSD
        // Calculate total columns for MSD
        msdCols = 1 + (showColEma ? 1 : 0) + (showColSwing ? 1 : 0) + (showColStruct ? 1 : 0) + (showColOB ? 1 : 0) + (showColFVG ? 1 : 0)
        
        // Header row
        table.cell(dashboard, 0, 0, "MARKET STRUCTURE DASHBOARD", text_color = textCol, text_size = size.normal, bgcolor = bgHeader, text_halign = text.align_center)
        if msdCols > 1
            table.merge_cells(dashboard, 0, 0, msdCols - 1, 0)
        
        // Column headers (row 1) - EMA moved to last
        col = 0
        table.cell(dashboard, col, 1, "TF", text_color = textCol, text_size = size.normal, width = 3)
        if showColSwing
            col += 1
            table.cell(dashboard, col, 1, "SWING H/L",                                 text_color = textCol, text_size = size.normal, tooltip = "Price position within swing range")
        if showColStruct
            col += 1
            table.cell(dashboard, col, 1, "STRUCTURE",                                 text_color = textCol, text_size = size.normal, tooltip = "Last 3 swing patterns (HH/HL/LH/LL)")
        if showColOB
            col += 1
            table.cell(dashboard, col, 1, "ORDER BLOCK",                               text_color = textCol, text_size = size.normal, tooltip = "Nearest unmitigated order block")
        if showColFVG
            col += 1
            table.cell(dashboard, col, 1, "FVG",                                       text_color = textCol, text_size = size.normal, tooltip = "Nearest unmitigated fair value gap")
        if showColEma
            col += 1
            table.cell(dashboard, col, 1, "EMA-" + str.tostring(emaLength) + " TREND", text_color = textCol, text_size = size.normal, tooltip = "Distance from EMA as percentage")
        
        // TF Rows
        if tfActive(tf1Enabled, tf1)
            drawMsdRow(dashboard, 2, fmtTF(tf1), t1_trendDir, t1_trendDist, t1_swingBar, t1_swingColor, t1_swingPct, t1_reclaimLow, t1_reclaimHigh, t1_structBias, t1_struct1, t1_struct2, t1_struct3, t1_obNearDir, t1_obNearDist, t1_fvgNearDir, t1_fvgNearDist, tf1)
        if tfActive(tf2Enabled, tf2)
            drawMsdRow(dashboard, 3, fmtTF(tf2), t2_trendDir, t2_trendDist, t2_swingBar, t2_swingColor, t2_swingPct, t2_reclaimLow, t2_reclaimHigh, t2_structBias, t2_struct1, t2_struct2, t2_struct3, t2_obNearDir, t2_obNearDist, t2_fvgNearDir, t2_fvgNearDist, tf2)
        if tfActive(tf3Enabled, tf3)
            drawMsdRow(dashboard, 4, fmtTF(tf3), t3_trendDir, t3_trendDist, t3_swingBar, t3_swingColor, t3_swingPct, t3_reclaimLow, t3_reclaimHigh, t3_structBias, t3_struct1, t3_struct2, t3_struct3, t3_obNearDir, t3_obNearDist, t3_fvgNearDir, t3_fvgNearDist, tf3)
        if tfActive(tf4Enabled, tf4)
            drawMsdRow(dashboard, 5, fmtTF(tf4), t4_trendDir, t4_trendDist, t4_swingBar, t4_swingColor, t4_swingPct, t4_reclaimLow, t4_reclaimHigh, t4_structBias, t4_struct1, t4_struct2, t4_struct3, t4_obNearDir, t4_obNearDist, t4_fvgNearDir, t4_fvgNearDist, tf4)
        if tfActive(tf5Enabled, tf5)
            drawMsdRow(dashboard, 6, fmtTF(tf5), t5_trendDir, t5_trendDist, t5_swingBar, t5_swingColor, t5_swingPct, t5_reclaimLow, t5_reclaimHigh, t5_structBias, t5_struct1, t5_struct2, t5_struct3, t5_obNearDir, t5_obNearDist, t5_fvgNearDir, t5_fvgNearDist, tf5)
        if tfActive(tf6Enabled, tf6)
            drawMsdRow(dashboard, 7, fmtTF(tf6), t6_trendDir, t6_trendDist, t6_swingBar, t6_swingColor, t6_swingPct, t6_reclaimLow, t6_reclaimHigh, t6_structBias, t6_struct1, t6_struct2, t6_struct3, t6_obNearDir, t6_obNearDist, t6_fvgNearDir, t6_fvgNearDist, tf6)
        if tfActive(tf7Enabled, tf7)
            drawMsdRow(dashboard, 8, fmtTF(tf7), t7_trendDir, t7_trendDist, t7_swingBar, t7_swingColor, t7_swingPct, t7_reclaimLow, t7_reclaimHigh, t7_structBias, t7_struct1, t7_struct2, t7_struct3, t7_obNearDir, t7_obNearDist, t7_fvgNearDir, t7_fvgNearDist, tf7)
    
    // Current TF & Market Context sections
    if showCurrTF or showContext
        // Calculate column counts
        ctfCols    = (showCurrVol ? 1 : 0) + (showCurrSwing ? 1 : 0) + (showCurrAtr ? 1 : 0)
        ctxCols    = (showSession ? 1 : 0) + (showKillzone ? 1 : 0) + (showBias ? 1 : 0)
        bottomCols = (showCurrTF  ? ctfCols : 0) + (showContext ? ctxCols : 0)
        
        // Row 9: Empty separator (only show if MSD is also visible)
        if showMSD
            table.cell(dashboard, 0, 9, "", bgcolor = bgDark)
            if bottomCols > 0
                table.merge_cells(dashboard, 0, 9, bottomCols - 1, 9)
        
        // Row 10: Section headers (start at col 0)
        col = 0
        if showCurrTF and ctfCols > 0
            table.cell(dashboard, col, 10, "CURRENT TIMEFRAME", text_color = textCol, text_size = size.normal, bgcolor = bgHeader, text_halign = text.align_center)
            if ctfCols > 1
                table.merge_cells(dashboard, col, 10, col + ctfCols - 1, 10)
            col += ctfCols
        
        if showContext and ctxCols > 0
            table.cell(dashboard, col, 10, "MARKET CONTEXT",    text_color = textCol, text_size = size.normal, bgcolor = bgHeader, text_halign = text.align_center)
            if ctxCols > 1
                table.merge_cells(dashboard, col, 10, col + ctxCols - 1, 10)
        
        // Row 11-13: Column headers and data rows
        drawBottomHeaders(dashboard, 11)
        drawBottomData1(dashboard,   12, currSwingBarText, currSwingBarColor, tipCurrSwing, volumeBarString, volumeColor, tipVolume, volatilityState, volatilityColor, tipVolatility, sessionName, sessionColor, tipSession, killzoneName, killzoneColor, tipKillzone, biasLabel, biasColor, tipBiasLabel)
        drawBottomData2(dashboard,   13, currSwingBarColor, volumeState, volumeColor, sessionProgressBar, sessionColor, tipSessionProg, nextKzText, nextKzColor, tipNextKz, biasScore, biasColor)
    
    // HTF Levels section
    if showHTFLevels
        htfRows = (showPDHL ? 1 : 0) + (showPWHL ? 1 : 0) + (showPMHL ? 1 : 0)
        
        if htfRows > 0
            // Row 14: Section header
            table.cell(dashboard, 0, 14, "HTF LEVELS", text_color = textCol, text_size = size.normal, bgcolor = bgHeader, text_halign = text.align_center)
            table.merge_cells(dashboard, 0, 14, 1, 14)
            
            // Rows 15+: HTF data
            drawHTFRows(dashboard, 15, pdSwingBar, pdSwingColor, tipPD, pwSwingBar, pwSwingColor, tipPW, pmSwingBar, pmSwingColor, tipPM)

// Plot EMA
plot(showEMA ? emaValue : na, "EMA", color = emaColor, linewidth = 2)

// Draw HTF Level Lines
var line pdhLine = na, var line pdlLine = na
var line pwhLine = na, var line pwlLine = na
var line pmhLine = na, var line pmlLine = na
var label pdhLabel = na, var label pdlLabel = na
var label pwhLabel = na, var label pwlLabel = na
var label pmhLabel = na, var label pmlLabel = na

// Segment-based threshold for combining labels
htfMaxHigh  = math.max(plotPDHL ? pdHigh : 0, plotPWHL ? pwHigh : 0, plotPMHL ? pmHigh : 0)
htfMinLow   = math.min(plotPDHL ? pdLow : 10e10, plotPWHL ? pwLow : 10e10, plotPMHL ? pmLow : 10e10)
segmentSize = (htfMaxHigh - htfMinLow) / 50
getSegment(price) => segmentSize > 0 ? math.floor((price - htfMinLow) / segmentSize) : 0

// Get segments for all levels (-1 if disabled)
pdhSeg = plotPDHL ? getSegment(pdHigh) : -1, pdlSeg = plotPDHL ? getSegment(pdLow) : -1
pwhSeg = plotPWHL ? getSegment(pwHigh) : -2, pwlSeg = plotPWHL ? getSegment(pwLow) : -2
pmhSeg = plotPMHL ? getSegment(pmHigh) : -3, pmlSeg = plotPMHL ? getSegment(pmLow) : -3

// Build combined labels - highs
pdhInPwh = pdhSeg == pwhSeg and plotPDHL and plotPWHL
pdhInPmh = pdhSeg == pmhSeg and plotPDHL and plotPMHL
pwhInPmh = pwhSeg == pmhSeg and plotPWHL and plotPMHL

pmhLbl = (pdhInPmh ? "PDH/" : "") + (pwhInPmh ? "PWH/" : "") + "PMH"
pwhLbl = (pdhInPwh and not pdhInPmh ? "PDH/" : "") + "PWH"
pdhLbl = "PDH"

// Build combined labels - lows
pdlInPwl = pdlSeg == pwlSeg and plotPDHL and plotPWHL
pdlInPml = pdlSeg == pmlSeg and plotPDHL and plotPMHL
pwlInPml = pwlSeg == pmlSeg and plotPWHL and plotPMHL

pmlLbl = (pdlInPml ? "PDL/" : "") + (pwlInPml ? "PWL/" : "") + "PML"
pwlLbl = (pdlInPwl and not pdlInPml ? "PDL/" : "") + "PWL"
pdlLbl = "PDL"

if barstate.islast
    // Delete all existing
    pdhLine.delete(), pdlLine.delete(), pwhLine.delete(), pwlLine.delete(), pmhLine.delete(), pmlLine.delete()
    pdhLabel.delete(), pdlLabel.delete(), pwhLabel.delete(), pwlLabel.delete(), pmhLabel.delete(), pmlLabel.delete()
    
    // Draw all lines at their actual prices (no merging)
    if plotPMHL
        pmhLine := line.new(bar_index - 1, pmHigh, bar_index + htfLevelExtend, pmHigh, color = pmhColor, style = getLineStyle(pmhlLineStyle), width = 1)
        pmlLine := line.new(bar_index - 1, pmLow, bar_index + htfLevelExtend, pmLow, color = pmlColor, style = getLineStyle(pmhlLineStyle), width = 1)
    if plotPWHL
        pwhLine := line.new(bar_index - 1, pwHigh, bar_index + htfLevelExtend, pwHigh, color = pwhColor, style = getLineStyle(pwhlLineStyle), width = 1)
        pwlLine := line.new(bar_index - 1, pwLow, bar_index + htfLevelExtend, pwLow, color = pwlColor, style = getLineStyle(pwhlLineStyle), width = 1)
    if plotPDHL
        pdhLine := line.new(bar_index - 1, pdHigh, bar_index + htfLevelExtend, pdHigh, color = pdhColor, style = getLineStyle(pdhlLineStyle), width = 1)
        pdlLine := line.new(bar_index - 1, pdLow, bar_index + htfLevelExtend, pdLow, color = pdlColor, style = getLineStyle(pdhlLineStyle), width = 1)
    
    // Draw labels (combined when in same segment, highest TF gets the label)
    if plotPMHL
        pmhLabel := label.new(bar_index + htfLevelExtend, pmHigh, pmhLbl, color = color.new(pmhColor, 100), textcolor = pmhColor, style = label.style_label_left, size = size.small)
        pmlLabel := label.new(bar_index + htfLevelExtend, pmLow, pmlLbl, color = color.new(pmlColor, 100), textcolor = pmlColor, style = label.style_label_left, size = size.small)
    if plotPWHL and not pwhInPmh
        pwhLabel := label.new(bar_index + htfLevelExtend, pwHigh, pwhLbl, color = color.new(pwhColor, 100), textcolor = pwhColor, style = label.style_label_left, size = size.small)
    if plotPWHL and not pwlInPml
        pwlLabel := label.new(bar_index + htfLevelExtend, pwLow, pwlLbl, color = color.new(pwlColor, 100), textcolor = pwlColor, style = label.style_label_left, size = size.small)
    if plotPDHL and not pdhInPmh and not pdhInPwh
        pdhLabel := label.new(bar_index + htfLevelExtend, pdHigh, pdhLbl, color = color.new(pdhColor, 100), textcolor = pdhColor, style = label.style_label_left, size = size.small)
    if plotPDHL and not pdlInPml and not pdlInPwl
        pdlLabel := label.new(bar_index + htfLevelExtend, pdLow, pdlLbl, color = color.new(pdlColor, 100), textcolor = pdlColor, style = label.style_label_left, size = size.small)

// Draw Order Blocks
if showOB and barstate.islast
    for b in obBoxes
        b.delete()
    obBoxes.clear()
    
    obCount = currTfOBs.size()
    for i = 0 to obCount - 1
        ob       = currTfOBs.get(i)
        obColor  = ob.dir > 0 ? color.new(obBullColor, 80) : color.new(obBearColor, 80)
        obBorder = ob.dir > 0 ? obBullColor : obBearColor
        
        newBox = box.new(
            left         = ob.barIdx,
            top          = ob.top,
            right        = bar_index + obExtend,
            bottom       = ob.bottom,
            border_color = obBorder,
            border_width = 1,
            bgcolor      = obColor,
            text         = showOBLabels ? (ob.dir > 0 ? "OB ↑" : "OB ↓") : "",
            text_color   = obBorder,
            text_halign  = text.align_right,
            text_valign  = text.align_center,
            text_size    = size.small
            )
        obBoxes.unshift(newBox)

// Draw FVGs
if showFVG and barstate.islast
    for b in fvgBoxes
        b.delete()
    fvgBoxes.clear()
    
    fvgCount = currTfFvgs.size()
    if fvgCount > 0
        for i = 0 to fvgCount - 1
            fvg       = currTfFvgs.get(i)
            fvgColorBg  = fvg.dir > 0 ? color.new(fvgBullColor, 85) : color.new(fvgBearColor, 85)
            fvgBorderClr = fvg.dir > 0 ? color.new(fvgBullColor, 60) : color.new(fvgBearColor, 60)
            
            fvgTextClr = fvg.dir > 0 ? fvgBullColor : fvgBearColor
            
            newBox = box.new(
                left         = fvg.barIdx,
                top          = fvg.top,
                right        = bar_index + fvgExtend,
                bottom       = fvg.bottom,
                bgcolor      = fvgColorBg,
                border_width = 1,
                border_style = line.style_dashed,
                border_color = fvgBorderClr,
                text         = showFVGLabels ? (fvg.dir > 0 ? "FVG ↑" : "FVG ↓") : "",
                text_color   = fvgTextClr,
                text_halign  = text.align_right,
                text_valign  = text.align_center,
                text_size    = size.small
                )
            fvgBoxes.unshift(newBox)

// Draw Swing Labels (from array on last bar)
var array<label> swingLabelObjs = array.new<label>()

if showSwingLabels and barstate.islast
    // Clear old labels
    for lbl in swingLabelObjs
        lbl.delete()
    swingLabelObjs.clear()
    
    // Draw labels from array
    for lbl in swingLabels
        newLabel = label.new(
            x         = lbl.x,
            y         = lbl.y,
            text      = lbl.txt,
            yloc      = lbl.isHigh ? yloc.abovebar          : yloc.belowbar,
            color     = lbl.clr,
            style     = lbl.isHigh ? label.style_label_down : label.style_label_up,
            textcolor = lbl.textClr,
            size      = size.small
            )
        swingLabelObjs.push(newLabel)

// Draw Swing Lines
if showSwingLines and barstate.islast
    swingLines.highLine.delete()
    swingLines.lowLine.delete()
    
    if not na(currSwingH) and not na(swingLines.lastHBar)
        swingLines.highLine := line.new(
            x1    = swingLines.lastHBar,
            y1    = currSwingH,
            x2    = bar_index + swingLinesExtend,
            y2    = currSwingH,
            color = color.new(swingLineHighColor, 30),
            style = getLineStyle(swingLineStyle),
            width = 1
            )
    
    if not na(currSwingL) and not na(swingLines.lastLBar)
        swingLines.lowLine := line.new(
            x1    = swingLines.lastLBar,
            y1    = currSwingL,
            x2    = bar_index + swingLinesExtend,
            y2    = currSwingL,
            color = color.new(swingLineLowColor, 30),
            style = getLineStyle(swingLineStyle),
            width = 1
            )
//#endregion VISUALIZATION



//#region Alerts
//#region Market Structure Dasboard Alerts  
var prevTf1 = TfAlertState.new()
var prevTf2 = TfAlertState.new()
var prevTf3 = TfAlertState.new()
var prevTf4 = TfAlertState.new()
var prevTf5 = TfAlertState.new()
var prevTf6 = TfAlertState.new()
var prevTf7 = TfAlertState.new()

msdAlerts(fmtTF(tf1), tfActive(tf1Enabled, tf1), t1_swingPct, t1_reclaimLow, t1_reclaimHigh, t1_structBias, t1_obNearDir, t1_obNearDist, t1_fvgNearDir, t1_fvgNearDist, t1_trendDir, prevTf1)
msdAlerts(fmtTF(tf2), tfActive(tf2Enabled, tf2), t2_swingPct, t2_reclaimLow, t2_reclaimHigh, t2_structBias, t2_obNearDir, t2_obNearDist, t2_fvgNearDir, t2_fvgNearDist, t2_trendDir, prevTf2)
msdAlerts(fmtTF(tf3), tfActive(tf3Enabled, tf3), t3_swingPct, t3_reclaimLow, t3_reclaimHigh, t3_structBias, t3_obNearDir, t3_obNearDist, t3_fvgNearDir, t3_fvgNearDist, t3_trendDir, prevTf3)
msdAlerts(fmtTF(tf4), tfActive(tf4Enabled, tf4), t4_swingPct, t4_reclaimLow, t4_reclaimHigh, t4_structBias, t4_obNearDir, t4_obNearDist, t4_fvgNearDir, t4_fvgNearDist, t4_trendDir, prevTf4)
msdAlerts(fmtTF(tf5), tfActive(tf5Enabled, tf5), t5_swingPct, t5_reclaimLow, t5_reclaimHigh, t5_structBias, t5_obNearDir, t5_obNearDist, t5_fvgNearDir, t5_fvgNearDist, t5_trendDir, prevTf5)
msdAlerts(fmtTF(tf6), tfActive(tf6Enabled, tf6), t6_swingPct, t6_reclaimLow, t6_reclaimHigh, t6_structBias, t6_obNearDir, t6_obNearDist, t6_fvgNearDir, t6_fvgNearDist, t6_trendDir, prevTf6)
msdAlerts(fmtTF(tf7), tfActive(tf7Enabled, tf7), t7_swingPct, t7_reclaimLow, t7_reclaimHigh, t7_structBias, t7_obNearDir, t7_obNearDist, t7_fvgNearDir, t7_fvgNearDist, t7_trendDir, prevTf7)
//#endregion

//#region Current TF Alerts 
var int    prevCtfSwingState = 0


currSwingSt = swingState(currSwingPct, currReclaimLow, currReclaimHigh)

// CTF Swing
if alertCtfSwingBreak and currSwingSt != prevCtfSwingState
    if currSwingSt == 1
        fireAlert("⚡ [CTF] Swing High Broken", 1)
    if currSwingSt == -1
        fireAlert("⚡ [CTF] Swing Low Broken", -1)


if alertCtfSwingSweep and currSwingSt != prevCtfSwingState
    if currSwingSt == 2
        fireAlert("🔄 [CTF] Swing Low Swept & Reclaimed ⤴", 1)
    if currSwingSt == -2
        fireAlert("🔄 [CTF] Swing High Swept & Reclaimed ⤵", -1)

prevCtfSwingState := currSwingSt
// Volume State Change
if alertCtfVolume and volumeState != volumeState[1] and not na(volumeState[1])
    volDir = volumeState == "EXTREME" or volumeState == "HIGH" ? 1 : volumeState == "LOW" or volumeState == "VERY LOW" ? -1 : 0
    fireAlert("🔊 Volume → " + volumeState + " (" + str.tostring(volumePct, "#") + "% of avg)", volDir)

// Volatility State Change
if alertCtfVolatility and volatilityState != volatilityState[1] and not na(volatilityState[1])
    volDir = volatilityState == "HIGH" ? -1 : volatilityState == "LOW" ? 1 : 0
    fireAlert("📉 Volatility → " + volatilityState, volDir)
    
//#endregion
//#region Market Context Alerts 


// Session Change
if alertSession and barSessionName != barSessionName[1] and not na(barSessionName[1])
    if barSessionName == "OFF HOURS"
        fireAlert("🕐 " + barSessionName[1] + " Session Ended", 0)
    else if barSessionName[1] == "OFF HOURS"
        fireAlert("🕐 " + barSessionName + " Session Started", 0)
    else
        fireAlert("🕐 " + barSessionName[1] + " → " + barSessionName, 0)

// Killzone Change (using bar time, not timenow)
if alertKillzone and barKillzoneName != barKillzoneName[1] and not na(barKillzoneName[1])
    kzMsg = barKillzoneName == "NO KILLZONE" ? "🎯 " + barKillzoneName[1] + " Ended" : "🎯 " + barKillzoneName + " Started"
    fireAlert(kzMsg, 0)


// Bias State Change
if alertBiasChange and biasLabel != biasLabel[1] and not na(biasLabel[1])
    bDir = str.contains(biasLabel, "↑") ? 1 : str.contains(biasLabel, "↓") ? -1 : 0
    fireAlert("📊 Trend Bias → " + biasLabel + " (" + biasScore + ")", bDir)

//#endregion
//#region HTF Level Alerts 
if alertHtfPDBreak
    if ta.crossover(close, pdHigh)
        fireAlert("⚡ PDH Broken", 1)
    if ta.crossunder(close, pdLow)
        fireAlert("⚡ PDL Broken", -1)

if alertHtfPDSweep
    if pdReclaimLow and not pdReclaimLow[1]
        fireAlert("🔄 PDL Swept & Reclaimed ⤴", 1)
    if pdReclaimHigh and not pdReclaimHigh[1]
        fireAlert("🔄 PDH Swept & Reclaimed ⤵", -1)

// PWH/L
if alertHtfPWBreak
    if ta.crossover(close, pwHigh)
        fireAlert("⚡ PWH Broken", 1)
    if ta.crossunder(close, pwLow)
        fireAlert("⚡ PWL Broken", -1)

if alertHtfPWSweep
    if pwReclaimLow and not pwReclaimLow[1]
        fireAlert("🔄 PWL Swept & Reclaimed ⤴", 1)
    if pwReclaimHigh and not pwReclaimHigh[1]
        fireAlert("🔄 PWH Swept & Reclaimed ⤵", -1)

// PMH/L
if alertHtfPMBreak
    if ta.crossover(close, pmHigh)
        fireAlert("⚡ PMH Broken", 1)
    if ta.crossunder(close, pmLow)
        fireAlert("⚡ PML Broken", -1)

if alertHtfPMSweep
    if pmReclaimLow and not pmReclaimLow[1]
        fireAlert("🔄 PML Swept & Reclaimed ⤴", 1)
    if pmReclaimHigh and not pmReclaimHigh[1]
        fireAlert("🔄 PMH Swept & Reclaimed ⤵", -1)
//#endregion
//#endregion Alerts
````
