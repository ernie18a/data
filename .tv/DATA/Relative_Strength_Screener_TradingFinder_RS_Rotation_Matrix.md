<!-- tradingview-pine-id: PUB;d28e01e764dd4a39b4cad63ad5022f36 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Relative Strength Screener [TradingFinder] RS Rotation Matrix

Source: https://www.tradingview.com/script/ePkzYxM8-Relative-Strength-Screener-TradingFinder-RS-Rotation-Matrix/

## Description

🔵Introduction

There are times when several markets or symbols move higher at the same time, but that does not mean they are showing the same level of strength. An asset may rise and appear strong at first glance, while its benchmark has performed even better over the same period. In that situation, simply knowing which symbol is moving higher is not enough. The more important question is which asset is actually outperforming the market and which one is beginning to lose relative strength.

[image]https://www.tradingview.com/x/OkErQKYo/[/image]

This is where Relative Strength analysis becomes useful. Instead of evaluating each symbol independently, a group of assets can be compared against the same benchmark to identify where relative strength is concentrated. This approach can be applied to stocks, indices, funds, currencies, commodities, cryptocurrencies, or any other comparable group of symbols.
 
Alongside Relative Strength, Relative Momentum adds another important layer because a current leader may still look strong while its relative momentum is starting to weaken, while a weaker symbol may already be entering an improving phase.

The Relative Strength Screener [TradingFinder] is designed to make these changes easier to identify. It compares multiple symbols against a common benchmark, ranks them using Relative Strength and Relative Momentum, and organizes the results inside a Ranking Dashboard. At the same time, the Rotation Matrix classifies each symbol as Leading, Improving, Weakening, or Lagging, making it easier to distinguish current leaders, emerging strength, weakening leadership, and persistent relative weakness.

This structure helps traders understand where relative strength is currently concentrated and where that strength may be moving next without manually reviewing a large number of charts. The purpose of the screener is not to generate direct Buy or Sell signals. Its main role is to support asset selection, Market Leadership analysis, Market Rotation analysis, and the creation of a more focused watchlist for further technical analysis.

🔵How to Use

After adding the Relative Strength Screener to the chart, the first step is to define the group of assets that will be compared with one another. This group, or universe, should ideally contain instruments that make sense to evaluate within the same context. For example, users can compare stocks from the same industry, different market indices, funds, commodities, currencies, cryptocurrencies, or any other group of related assets. The indicator supports between 2 and 10 active symbols, and all Relative Strength and Relative Momentum calculations are based on this selected universe. 

[image]https://www.tradingview.com/x/eQIw8lfx/[/image]

By default, the screener includes 10 sector funds from the US stock market and uses [symbol="AMEX:SPY"]AMEX:SPY[/symbol]  as the Benchmark. This setup provides a practical example of Sector Rotation analysis. [symbol="AMEX:XLK"]AMEX:XLK[/symbol]  represents Technology, [symbol="AMEX:XLF"]AMEX:XLF[/symbol]  represents Financials, [symbol="AMEX:XLE"]AMEX:XLE[/symbol]  represents Energy, [symbol="AMEX:XLV"]AMEX:XLV[/symbol]  represents Health Care, and [symbol="AMEX:XLY"]AMEX:XLY[/symbol]  represents Consumer Discretionary. The remaining symbols are [symbol="AMEX:XLP"]AMEX:XLP[/symbol]  for Consumer Staples, [symbol="AMEX:XLI"]AMEX:XLI[/symbol]  for Industrials, [symbol="AMEX:XLB"]AMEX:XLB[/symbol]  for Materials, [symbol="AMEX:XLU"]AMEX:XLU[/symbol]  for Utilities, and [symbol="AMEX:XLRE"]AMEX:XLRE[/symbol]  for Real Estate.

These default symbols are only an example universe. The Relative Strength Screener is not limited to sector funds or the US market. Users can replace every symbol and the Benchmark to build a universe that matches their own analysis. 

For example, several stocks from the same industry can be compared against a sector index, global equity indices can be compared against a broader market benchmark, or a group of cryptocurrencies can be evaluated relative to a selected crypto market reference. The important point is that all selected instruments should belong to a meaningful comparison framework.

🟣Benchmark and Scan Timeframe

The Benchmark is the reference point for all Relative Strength calculations. With the default settings, SPY serves as this reference. This means the screener does not simply measure whether a symbol has risen or fallen. Instead, it evaluates how that symbol performed relative to SPY.

For example, an asset may gain 3 percent during the selected period and appear strong when viewed independently. However, if the Benchmark gains 5 percent over the same period, the asset has still underperformed the broader market. This distinction separates Absolute Performance from Relative Performance and helps identify assets that are truly gaining leadership rather than simply moving in the same direction as the market.

The Scan Timeframe determines the timeframe used by the ranking engine. If the Scan Timeframe is set to Daily, for example, the Performance Length and Momentum Length are calculated using daily scan bars. When the Scan Timeframe is equal to or higher than the chart timeframe, the screener uses confirmed scan data. When the Scan Timeframe is lower than the chart timeframe, the indicator uses the latest available intrabar information to create the current snapshot.

[image]https://www.tradingview.com/x/5qS7uCCe/[/image]

The current data mode is displayed directly in the Ranking Dashboard. If lower timeframe data is unavailable or incomplete, the screener displays a visible NO DATA or LIMITED DATA message rather than presenting a potentially misleading ranking. 

🟣Relative Strength and Relative Momentum
The core model of the screener is built around two measurements: Relative Strength and Relative Momentum.

Relative Strength measures how each symbol has performed compared with the Benchmark over the selected Performance Length. A positive Relative Return means the symbol has outperformed the Benchmark, while a negative value means the symbol has underperformed it. This information is displayed directly in the vs Benchmark column. 

For example, if the dashboard shows 0.80% ahead, the symbol has delivered approximately 0.80 percent more relative performance than the Benchmark over the selected period. If the table shows 0.45% behind, the symbol has underperformed the Benchmark by approximately 0.45 percent on a relative basis.

[image]https://www.tradingview.com/x/a89tL21P/[/image]

Relative Strength describes the current position of an asset, but that alone does not show whether the situation is improving or deteriorating. This is why the indicator also calculates Relative Momentum. Relative Momentum measures how Relative Return has changed compared with its value a specified number of scan bars earlier.

A symbol can therefore remain ahead of the Benchmark while its Relative Momentum becomes negative. In this case, the asset is still an outperformer, but its previous advantage is beginning to fade. In the opposite situation, a symbol may still be behind the Benchmark while Relative Momentum becomes positive. This can be an early sign that its previous weakness is starting to reverse.

[image]https://www.tradingview.com/x/3oe40PKO/[/image]

🟣Ranking Dashboard
The Ranking Dashboard is the main analytical component of the Relative Strength Screener. It ranks the selected symbols using a combination of Relative Strength and Relative Momentum, while also showing the evidence behind each position.

The purpose of the table is not simply to tell the user which symbol ranks first or last. It is designed to answer several more useful questions. Which assets deserve further attention? Which leaders are maintaining their strength? Which symbols are improving? Which leaders are beginning to fade? And how persistent has the current relative strength been? 

🟣Rank

The Rank column shows the current position of each valid symbol within the selected universe.
If a symbol displays 1 of 10, it currently has the highest Composite Score among the 10 valid symbols. A reading of 6 of 10 means that five other assets currently have a higher score.

Rank is useful for quickly identifying the strongest members of the universe, but it should not be interpreted in isolation. Ranking is relative to the selected symbols. A symbol can rank first and still be underperforming the Benchmark if the entire universe is weak.
For this reason, Rank should normally be analyzed together with the vs Benchmark column. 

🟣Takeaway and Evidence

The Takeaway / Evidence column converts several underlying calculations into a more readable conclusion. Instead of requiring the user to interpret Relative Return, Momentum, Rank, Rank Change, and Persistence separately, the screener combines these conditions into descriptive states.

Sustained Leadership indicates that the symbol is ahead of the Benchmark, its Relative Momentum is not negative, it is ranked inside the top group, and it has maintained that position for the required Leadership Confirmation period. This condition represents established relative leadership and can identify assets that deserve further technical analysis.

Outperforming, Fading appears when the symbol is still ahead of the Benchmark but its Relative Momentum has turned negative. The asset remains relatively strong, but its advantage is shrinking. This can provide an early warning that an existing market leader is losing strength.

Climbing the Ranks indicates positive Relative Momentum together with an improvement in Rank. A symbol that moves from Rank 8 to Rank 6 and then to Rank 4 is progressively strengthening compared with the other members of the universe.

Recovering, Still Behind describes a symbol that continues to underperform the Benchmark but is showing positive Relative Momentum and improving Rank. This is not confirmed leadership. Instead, it represents an early recovery phase that may justify placing the asset on a watchlist.

[image]https://www.tradingview.com/x/QH04FZ2K/[/image]

Behind, No Recovery indicates that the symbol is behind the Benchmark and is not showing meaningful improvement in either Momentum or Rank. In a Relative Strength based selection process, these assets would normally receive lower priority.

[image]https://www.tradingview.com/x/lwm04c9N/[/image]

Mixed Evidence is displayed when the available signals do not point in the same direction. Momentum may be improving while Rank remains weak, or other confirmation conditions may not yet be satisfied. The indicator intentionally keeps the conclusion neutral in these situations rather than forcing a stronger interpretation.

If one or more symbols in the universe lack valid data, the dashboard can display Incomplete Comparison. If the individual symbol itself does not have enough valid history, the result becomes Insufficient Data. Since Percentile and Rank calculations depend on cross sectional comparison, the indicator avoids producing strong conclusions when the available universe is incomplete. 

🟣vs Benchmark

The vs Benchmark column shows the actual relative performance of each symbol against the selected Benchmark.

An ahead value means the asset has outperformed the Benchmark over the configured Performance Length. A behind value means it has underperformed.

This column is especially important because it prevents a high Rank from being mistaken for genuine market outperformance. A symbol may rank first among the selected assets while still showing 0.20% behind. In that case, it is the strongest member of the selected universe, but it has not yet outperformed the Benchmark itself.

🟣Score

The Score column combines Strength Percentile and Momentum Percentile into a single comparison score.

With the default settings, 65 percent of the score is assigned to Strength and 35 percent is assigned to Momentum. A higher score means the symbol has a stronger combination of Relative Strength and Relative Momentum compared with the other members of the universe. 

The score is not a probability measurement. A value of 90 does not mean there is a 90 percent probability of a profitable trade, a 90 percent win rate, or a 90 percent probability that the asset will rise. It is simply a relative comparison metric used to rank the selected symbols.

🟣Top Group Streak

The Top Group Streak shows how long a symbol has remained inside the strongest portion of the selected universe.

The top group is defined using the top quartile. In a universe of 10 symbols, this generally corresponds to the top three ranked assets.

If a symbol displays 8 scans, it means that the asset has remained in the top group for eight consecutive ranking checks. This helps distinguish a temporary jump in Rank from more persistent market leadership.

Top Group Streak does not count how many consecutive times a symbol has outperformed the Benchmark. It only measures persistence inside the top ranking group. 

🟣Rank Change

The Rank Change column shows how the position of a symbol has changed since the previous completed ranking check.

A value such as ↑ 2 places means the symbol improved by two ranking positions. A value of ↓ 2 places means it dropped by two positions. Unchanged means the ranking remained the same.
Current Rank shows where the asset is now, while Rank Change helps show the direction in which it is moving.

For example, a symbol currently ranked fifth may have improved from Rank 9 over the previous scans. This can indicate strengthening relative performance. Another symbol may still hold Rank 3 but may have fallen from Rank 1, suggesting that its leadership is beginning to deteriorate.

🟣Rotation Matrix

The Rotation Matrix provides a faster and more visual summary of the entire universe. While the Ranking Dashboard shows detailed numerical evidence for every symbol, the Rotation Matrix focuses on the relationship between Strength and Momentum.

The matrix compares Strength Percentile and Momentum Percentile using the 50th percentile as the default boundary. Every valid symbol is then classified as Leading, Improving, Weakening, or Lagging. 

A symbol in the Leading state has both Strength and Momentum in the stronger half of the universe. These assets represent the current relative leaders. If a symbol remains in Leading for several scans and the Ranking Dashboard also confirms Benchmark outperformance and a strong Top Group Streak, the evidence for persistent leadership becomes stronger.

An Improving symbol still has Strength in the weaker half of the universe, but its Momentum has moved into the stronger half. This state is particularly useful for identifying Emerging Leadership. The asset is not yet a confirmed leader, but its Relative Performance has started to improve.

One of the most important positive rotation sequences is: Lagging → Improving → Leading

This progression shows an asset moving from relative weakness into improving momentum and eventually into relative leadership.

A Weakening symbol still has above median Strength but below median Momentum. The asset remains relatively strong, but the quality of that strength is deteriorating. 

A Leader moving into Weakening may be showing the first signs of losing its previous advantage.

If the deterioration continues, the sequence may become: Leading → Weakening → Lagging

However, a Weakening symbol can also return to Leading if Momentum recovers. For this reason, Weakening should be treated as a change in relative conditions rather than an automatic Sell signal.

A Lagging symbol has both Strength and Momentum in the weaker half of the universe. These assets usually receive lower priority in a Relative Strength selection process. However, movement out of Lagging can be important. A transition from Lagging to Improving can be the first indication that the relative trend is beginning to change.

🟣Combining the Ranking Dashboard and Rotation Matrix

The most useful way to analyze the indicator is to read the Rotation Matrix and Ranking Dashboard together.

The Rotation Matrix provides the first overview. It shows where Relative Strength is concentrated and which assets are currently Leading, Improving, Weakening, or Lagging. The Ranking Dashboard then provides the numerical evidence needed to understand the quality of each state.

For example, if a symbol appears in Leading, the trader can check the Dashboard to determine whether it is actually ahead of the Benchmark, how high it ranks, how strong its Score is, how long it has remained in the top group, and whether its Rank is improving or deteriorating.

Two symbols can both appear in Leading while having very different profiles. One may be ahead of the Benchmark, ranked first, and have a long Top Group Streak. Another may have only recently entered the stronger half of the universe and have little persistence. The Rotation Matrix places both in the same broad state, while the Ranking Dashboard explains the difference between them.

The same principle applies to Improving. A symbol may be improving while still remaining behind the Benchmark. Another may already have crossed into relative outperformance. Rank Change can then show whether the improvement in Momentum is also beginning to affect its broader ranking.

For Weakening assets, the combination of negative Relative Momentum, declining Rank, and lower persistence can provide stronger evidence that leadership is deteriorating. If Rank remains stable and Momentum weakness is temporary, the condition may simply represent a short pause in relative strength.

It is important to understand that the Dashboard conclusions and Rotation Matrix do not use identical logic. The Rotation Matrix is based only on Strength Percentile and Momentum Percentile. The Dashboard also considers Relative Return, Relative Momentum, Rank Change, and Persistence. 

For this reason, a symbol can appear as Improving in the Rotation Matrix while its Dashboard conclusion still shows Mixed Evidence. These outputs are not contradictory. They describe different dimensions of the same relative strength analysis. 

🟣Practical Workflow

A practical workflow begins by selecting a meaningful universe and an appropriate Benchmark. The Scan Timeframe, Performance Length, and Momentum Length can then be adjusted according to the intended analysis horizon.

The Rotation Matrix can first be used to identify current leaders, emerging strength, weakening leadership, and persistent laggards. The Ranking Dashboard can then be used to verify Benchmark Relative Performance, Rank, Score, Rank Change, and leadership persistence.

Symbols in Leading can be examined for current market leadership. Improving assets can be monitored for emerging Relative Strength. Weakening can help identify existing leaders that are beginning to lose Momentum, while Lagging identifies the weaker part of the selected universe.

The strongest or most interesting candidates can then be moved into a focused watchlist for further analysis of Price Structure, Trend, Liquidity, Entry Conditions, and Risk Management.

🔵Settings

Number of Symbols: Determines how many symbols are included in the Relative Strength Screener. Users can select between 2 and 10 symbols. Only the first selected number of symbol inputs will be included in the Ranking Dashboard and Rotation Matrix.

Symbol 1 to Symbol 10: Defines the assets used in the Relative Strength comparison. Each symbol can be replaced with any preferred stock, index, fund, currency, commodity, cryptocurrency, or other supported TradingView symbol. For more meaningful results, the selected symbols should belong to a logically comparable market universe. 

Benchmark: Defines the reference asset used for all Relative Strength calculations. Each selected symbol is compared with this Benchmark to determine whether it is outperforming or underperforming the reference market. The default Benchmark is SPY.

Scan Timeframe: Determines the timeframe used by the Relative Strength ranking engine. The Scan Timeframe can be higher than, equal to, or lower than the chart timeframe. Higher and equal timeframe calculations use confirmed data, while lower timeframe settings use the latest available intrabar data.

Performance Length: Defines the number of Scan Timeframe bars used to calculate Benchmark Relative Performance. Higher values measure Relative Strength over a longer period, while lower values make the calculation more responsive to recent performance changes.

Momentum Length: Determines the period used to measure changes in Relative Performance. It compares the current Relative Return with its previous value to identify whether Relative Strength is improving or deteriorating.

Momentum Weight %: Defines how much influence Relative Momentum has on the final Score. The remaining percentage is automatically assigned to Relative Strength. For example, the default value of 35 percent creates a Score based on 35 percent Momentum and 65 percent Strength.

Leadership Confirmation: Defines how many consecutive Top Group checks are required before a symbol can be classified as having Sustained Leadership. Higher values require longer persistence before leadership is confirmed. 

Symbol: Selects the asset displayed in the Relative Performance Oscillator. The selected symbol should be one of the active screener symbols. If another symbol is selected, Symbol 1 is used automatically.

Performance Length: Determines the lookback period used to calculate the selected symbol's performance relative to the Benchmark in the oscillator. Unlike the Ranking Dashboard, this setting is calculated using chart timeframe bars.

Smoothing: Defines the smoothing period applied to the Relative Performance line. Higher values create a smoother oscillator with less short term fluctuation, while lower values make the line more responsive.

Signal Length: Determines the EMA period used for the oscillator Signal Line. The relationship between the Relative Performance line and its Signal Line can be used to evaluate short term acceleration or deceleration in relative performance.

Show Signal: Enables or disables the oscillator Signal Line and the Relative Acceleration ribbon.

Show Last Value: Enables or disables the label showing the selected Symbol and Benchmark pair together with the latest Relative Performance value. 

Send Alerts: Enables or disables the Relative Strength event engine. When enabled, alerts can be generated for Leader Group entries, Rotation State changes, Leadership Loss, and Leadership Confirmation events.

Leader Rank: Defines the Top N ranking group used for Leader Entry and Leadership Loss alerts. For example, when this value is set to 3, a symbol entering the Top 3 can trigger a Leader Entry event, while leaving the Top 3 can trigger a Leadership Loss event. 

Show Ranking Table: Shows or hides the Relative Strength Ranking Dashboard on the chart.

Ranking Table Size: Adjusts the visual size of the Ranking Dashboard. Available options include Tiny, Small, Normal, and Large.

Ranking Table Position: Determines where the Ranking Dashboard appears on the chart. Users can select from nine positions using Top, Middle, or Bottom combined with Left, Center, or Right.

Show Rotation Matrix: Shows or hides the Rotation Matrix on the chart.
Matrix Table Size: Adjusts the visual size of the Rotation Matrix. Available options include Tiny, Small, Normal, and Large.

Matrix Table Position: Determines where the Rotation Matrix appears on the chart. Users can select from nine available positions. A different position from the Ranking Dashboard should be selected when both tables are enabled to prevent overlap.

🔵Conclusion

Markets rarely move in a perfectly uniform way. While one group of assets is gaining leadership, another may be losing momentum, and somewhere else a previously weak symbol may already be starting to recover. Looking at price alone can make these shifts difficult to recognize, especially when several assets are moving in the same direction at the same time.

The Relative Strength Screener [TradingFinder] is built to make that rotation easier to see. By comparing a selected group of symbols against a common Benchmark, the indicator helps reveal which assets are truly outperforming, which ones are improving, and which current leaders are beginning to fade. The Ranking Dashboard adds the numerical evidence behind that comparison, while the Rotation Matrix turns the same market into a clearer picture of Leading, Improving, Weakening, and Lagging assets. 

The goal is not to replace chart analysis or generate an automatic Buy or Sell signal. The value of the screener comes earlier in the decision process, when the trader is still asking which symbols deserve attention in the first place. Once the stronger, improving, or weakening assets have been identified, the next step is to return to the chart and evaluate Price Structure, Trend, Liquidity, Entry Conditions, and Risk Management.

---

## Source Code

````pine
//@version=6
indicator("Relative Strength Screener [TradingFinder] RS Rotation Matrix", "RS Rotation", overlay = false, max_bars_back = 5000, dynamic_requests = true)



symbolLimitInput = input.int(10, "Number of Symbols", options = [2, 3, 4, 5, 6, 7, 8, 9, 10], group = "Symbols")
symbol01 = input.symbol("AMEX:XLK", "Symbol 1", group = "Symbols")
symbol02 = input.symbol("AMEX:XLF", "Symbol 2", group = "Symbols")
symbol03 = input.symbol("AMEX:XLE", "Symbol 3", group = "Symbols")
symbol04 = input.symbol("AMEX:XLV", "Symbol 4", group = "Symbols")
symbol05 = input.symbol("AMEX:XLY", "Symbol 5", group = "Symbols")
symbol06 = input.symbol("AMEX:XLP", "Symbol 6", group = "Symbols")
symbol07 = input.symbol("AMEX:XLI", "Symbol 7", group = "Symbols")
symbol08 = input.symbol("AMEX:XLB", "Symbol 8", group = "Symbols")
symbol09 = input.symbol("AMEX:XLU", "Symbol 9", group = "Symbols")
symbol10 = input.symbol("AMEX:XLRE", "Symbol 10", group = "Symbols")

benchmarkInput = input.symbol("AMEX:SPY", "Benchmark", group = "Calculation Settings")
scanTfInput = input.timeframe("D", "Scan Timeframe", tooltip = "Can be above, equal to, or below the chart timeframe. Lower settings use intrabar data.", group = "Calculation Settings")
rsLookbackInput = input.int(63, "Performance Length", minval = 5, maxval = 500, tooltip = "Number of Scan Timeframe bars used to compare each symbol with the benchmark.", group = "Calculation Settings")
momentumLookbackInput = input.int(21, "Momentum Length", minval = 1, maxval = 250, tooltip = "Measures how benchmark-relative performance changed over this many Scan Timeframe bars.", group = "Calculation Settings")
momentumWeightPctInput = input.float(35.0, "Momentum Weight %", minval = 0.0, maxval = 100.0, step = 5.0, tooltip = "The remaining weight is assigned to relative strength.", group = "Calculation Settings")
persistenceThresholdInput = input.int(3, "Leadership Confirmation", minval = 1, maxval = 50, tooltip = "Number of consecutive top-group checks required for Sustained Leadership.", group = "Calculation Settings")

focusSymbolInput = input.symbol("AMEX:XLK", "Symbol", tooltip = "Choose one of the active screener symbols. Otherwise, Symbol 1 is used.", group = "Oscillator Settings")
oscLookbackInput = input.int(63, "Performance Length", minval = 5, maxval = 500, tooltip = "Oscillator length in chart bars.", group = "Oscillator Settings")
oscSmoothInput = input.int(5, "Smoothing", minval = 1, maxval = 50, group = "Oscillator Settings")
oscSignalInput = input.int(13, "Signal Length", minval = 2, maxval = 100, group = "Oscillator Settings")
oscShowSignalInput = input.bool(true, "Show Signal", group = "Oscillator Settings")
oscShowLabelInput = input.bool(true, "Show Last Value", group = "Oscillator Settings")

sendAlertsInput = input.bool(true, "Send Alerts", group = "Alert Settings")
alertRankLevelInput = input.int(3, "Leader Rank", minval = 1, maxval = 10, tooltip = "Alerts when a symbol enters or leaves this leader group.", group = "Alert Settings")

showDashboardInput = input.bool(true, "Show Ranking Table", group = "Table Settings")
dashboardSizeInput = input.string(size.small, "Ranking Table Size", options = [size.tiny, size.small, size.normal, size.large], group = "Table Settings")
dashboardPositionInput = input.string(position.top_right, "Ranking Table Position", options = [position.top_left, position.top_center, position.top_right, position.middle_left, position.middle_center, position.middle_right, position.bottom_left, position.bottom_center, position.bottom_right], tooltip = "Choose a different position from the Rotation Matrix to prevent overlap.", group = "Table Settings")
showMatrixInput = input.bool(true, "Show Rotation Matrix", group = "Table Settings")
matrixSizeInput = input.string(size.small, "Matrix Table Size", options = [size.tiny, size.small, size.normal, size.large], group = "Table Settings")
matrixPositionInput = input.string(position.bottom_right, "Matrix Table Position", options = [position.top_left, position.top_center, position.top_right, position.middle_left, position.middle_center, position.middle_right, position.bottom_left, position.bottom_center, position.bottom_right], tooltip = "Choose a different position from the Ranking Table to prevent overlap.", group = "Table Settings")





f_shortSymbol(string tickerId) =>
    parts = str.split(tickerId, ":")
    array.size(parts) > 1 ? array.get(parts, array.size(parts) - 1) : tickerId

f_timeframeLabel(timeframeValue) =>
    label = timeframeValue
    if str.contains(timeframeValue, "S")
        amountS = str.replace_all(timeframeValue, "S", "")
        label := (amountS == "" ? "1" : amountS) + "s"
    else if str.contains(timeframeValue, "D")
        amountD = str.replace_all(timeframeValue, "D", "")
        label := (amountD == "" ? "1" : amountD) + "D"
    else if str.contains(timeframeValue, "W")
        amountW = str.replace_all(timeframeValue, "W", "")
        label := (amountW == "" ? "1" : amountW) + "W"
    else if str.contains(timeframeValue, "M")
        amountM = str.replace_all(timeframeValue, "M", "")
        label := (amountM == "" ? "1" : amountM) + "M"
    else
        float totalSeconds = timeframe.in_seconds(timeframeValue)
        if not na(totalSeconds)
            int totalMinutes = int(totalSeconds / 60)
            label := totalMinutes >= 1440 and totalMinutes % 1440 == 0 ? str.tostring(int(totalMinutes / 1440)) + "D" :
                     totalMinutes >= 60 and totalMinutes % 60 == 0 ? str.tostring(int(totalMinutes / 60)) + "h" :
                     str.tostring(totalMinutes) + "m"
    label

f_percentile(array<float> values, int index) =>
    float target = array.get(values, index)
    int valid = 0
    int below = 0
    int tiedOthers = 0
    if not na(target)
        for j = 0 to array.size(values) - 1
            float candidate = array.get(values, j)
            if not na(candidate)
                valid += 1
                if candidate < target
                    below += 1
                else if j != index and candidate == target
                    tiedOthers += 1
    valid <= 1 or na(target) ? (na(target) ? na : 50.0) : 100.0 * (below + 0.5 * tiedOthers) / (valid - 1)

f_ordinalRank(array<float> values, int index) =>
    float target = array.get(values, index)
    int rank = na
    if not na(target)
        rank := 1
        for j = 0 to array.size(values) - 1
            float candidate = array.get(values, j)
            if not na(candidate) and candidate > target
                rank += 1
    rank

f_state(float strengthPct, float momentumPct, float strengthCut, float momentumCut) =>
    string state = "N/A"
    if not na(strengthPct) and not na(momentumPct)
        state := strengthPct >= strengthCut and momentumPct >= momentumCut ? "Leading" :
                 strengthPct < strengthCut and momentumPct >= momentumCut ? "Improving" :
                 strengthPct >= strengthCut and momentumPct < momentumCut ? "Weakening" : "Lagging"
    state

f_stateColor(string state) =>
    state == "Leading" ? color.rgb(0, 145, 110) :
     state == "Improving" ? color.rgb(20, 105, 190) :
     state == "Weakening" ? color.rgb(224, 145, 0) :
     state == "Lagging" ? color.rgb(185, 50, 65) : color.rgb(90, 95, 105)

f_lastFloat(array<float> values) =>
    array.size(values) > 0 ? array.last(values) : na

f_lastInt(array<int> values) =>
    array.size(values) > 0 ? array.last(values) : na

f_heatColor(float value) =>
    na(value) ? color.new(color.gray, 80) :
     value >= 75 ? color.new(color.rgb(0, 145, 110), 15) :
     value >= 50 ? color.new(color.rgb(85, 150, 95), 30) :
     value >= 25 ? color.new(color.rgb(210, 145, 30), 30) : color.new(color.rgb(185, 50, 65), 15)

f_appendEvent(string message, string eventText) =>
    message == "" ? eventText : message + "\n" + eventText




var array<string> symbols = array.new_string()
if barstate.isfirst
    array.push(symbols, symbol01)
    array.push(symbols, symbol02)
    if symbolLimitInput >= 3
        array.push(symbols, symbol03)
    if symbolLimitInput >= 4
        array.push(symbols, symbol04)
    if symbolLimitInput >= 5
        array.push(symbols, symbol05)
    if symbolLimitInput >= 6
        array.push(symbols, symbol06)
    if symbolLimitInput >= 7
        array.push(symbols, symbol07)
    if symbolLimitInput >= 8
        array.push(symbols, symbol08)
    if symbolLimitInput >= 9
        array.push(symbols, symbol09)
    if symbolLimitInput >= 10
        array.push(symbols, symbol10)

symbolCount = array.size(symbols)
scanIsLower = timeframe.in_seconds(scanTfInput) < timeframe.in_seconds(timeframe.period)
leaderCount = math.min(alertRankLevelInput, symbolCount)
topQuartile = math.max(1, int(math.ceil(symbolCount * 0.25)))
momentumWeight = momentumWeightPctInput / 100.0
strengthWeight = 1.0 - momentumWeight
strengthCut = 50.0
momentumCut = 50.0



float benchNow = na
float benchPast = na
float benchMom = na
float benchMomPast = na
int scanStamp = na

if scanIsLower
    [benchNowBars, benchPastBars, benchMomBars, benchMomPastBars, benchTimeBars] = request.security_lower_tf(
         benchmarkInput,
         scanTfInput,
         [close, close[rsLookbackInput], close[momentumLookbackInput], close[rsLookbackInput + momentumLookbackInput], time],
         ignore_invalid_symbol = true,
         ignore_invalid_timeframe = true,
         calc_bars_count = 5000)
    benchNow := f_lastFloat(benchNowBars)
    benchPast := f_lastFloat(benchPastBars)
    benchMom := f_lastFloat(benchMomBars)
    benchMomPast := f_lastFloat(benchMomPastBars)
    scanStamp := f_lastInt(benchTimeBars)
else
    [benchNowHtf, benchPastHtf, benchMomHtf, benchMomPastHtf, benchTimeHtf] = request.security(
         benchmarkInput,
         scanTfInput,
         [close[1], close[rsLookbackInput + 1], close[momentumLookbackInput + 1], close[rsLookbackInput + momentumLookbackInput + 1], time[1]],
         gaps = barmerge.gaps_off,
         lookahead = barmerge.lookahead_on,
         ignore_invalid_symbol = true,
         calc_bars_count = 5000)
    benchNow := benchNowHtf
    benchPast := benchPastHtf
    benchMom := benchMomHtf
    benchMomPast := benchMomPastHtf
    scanStamp := benchTimeHtf

bool newScan = not na(scanStamp) and (not scanIsLower or barstate.isconfirmed) and (na(scanStamp[1]) or scanStamp != scanStamp[1])


relativeReturns = array.new_float(symbolCount, na)
relativeMomentum = array.new_float(symbolCount, na)

for i = 0 to symbolCount - 1
    string symbolId = array.get(symbols, i)
    float symbolNow = na
    float symbolPast = na
    float symbolMom = na
    float symbolMomPast = na
    int symbolStamp = na
    if scanIsLower
        [symbolNowBars, symbolPastBars, symbolMomBars, symbolMomPastBars, symbolTimeBars] = request.security_lower_tf(
             symbolId,
             scanTfInput,
             [close, close[rsLookbackInput], close[momentumLookbackInput], close[rsLookbackInput + momentumLookbackInput], time],
             ignore_invalid_symbol = true,
             ignore_invalid_timeframe = true,
             calc_bars_count = 5000)
        symbolNow := f_lastFloat(symbolNowBars)
        symbolPast := f_lastFloat(symbolPastBars)
        symbolMom := f_lastFloat(symbolMomBars)
        symbolMomPast := f_lastFloat(symbolMomPastBars)
        symbolStamp := f_lastInt(symbolTimeBars)
    else
        [symbolNowHtf, symbolPastHtf, symbolMomHtf, symbolMomPastHtf, symbolTimeHtf] = request.security(
             symbolId,
             scanTfInput,
             [close[1], close[rsLookbackInput + 1], close[momentumLookbackInput + 1], close[rsLookbackInput + momentumLookbackInput + 1], time[1]],
             gaps = barmerge.gaps_off,
             lookahead = barmerge.lookahead_on,
             ignore_invalid_symbol = true,
             calc_bars_count = 5000)
        symbolNow := symbolNowHtf
        symbolPast := symbolPastHtf
        symbolMom := symbolMomHtf
        symbolMomPast := symbolMomPastHtf
        symbolStamp := symbolTimeHtf

    timestampsMatch = not na(scanStamp) and symbolStamp == scanStamp
    validNow = timestampsMatch and not na(symbolNow) and not na(symbolPast) and not na(benchNow) and not na(benchPast) and symbolPast != 0 and benchPast != 0 and benchNow != 0
    validPrevious = timestampsMatch and not na(symbolMom) and not na(symbolMomPast) and not na(benchMom) and not na(benchMomPast) and symbolMomPast != 0 and benchMomPast != 0 and benchMom != 0
    currentRelativeReturn = validNow ? 100.0 * ((symbolNow / symbolPast) / (benchNow / benchPast) - 1.0) : na
    previousRelativeReturn = validPrevious ? 100.0 * ((symbolMom / symbolMomPast) / (benchMom / benchMomPast) - 1.0) : na
    momentum = not na(currentRelativeReturn) and not na(previousRelativeReturn) ? currentRelativeReturn - previousRelativeReturn : na
    array.set(relativeReturns, i, currentRelativeReturn)
    array.set(relativeMomentum, i, momentum)


strengthPercentiles = array.new_float(symbolCount, na)
momentumPercentiles = array.new_float(symbolCount, na)
compositeScores = array.new_float(symbolCount, na)

for i = 0 to symbolCount - 1
    strengthPct = f_percentile(relativeReturns, i)
    momentumPct = f_percentile(relativeMomentum, i)
    score = not na(strengthPct) and not na(momentumPct) ? strengthPct * strengthWeight + momentumPct * momentumWeight : na
    array.set(strengthPercentiles, i, strengthPct)
    array.set(momentumPercentiles, i, momentumPct)
    array.set(compositeScores, i, score)

currentRanks = array.new_int(symbolCount, na)
currentStates = array.new_string(symbolCount, "N/A")

for i = 0 to symbolCount - 1
    array.set(currentRanks, i, f_ordinalRank(compositeScores, i))
    array.set(currentStates, i, f_state(array.get(strengthPercentiles, i), array.get(momentumPercentiles, i), strengthCut, momentumCut))


var  previousRanks = array.new_int()
var  previousStates = array.new_string()
var  persistenceCounts = array.new_int()
var  latestRankChanges = array.new_int()

if barstate.isfirst
    for i = 0 to symbolCount - 1
        array.push(previousRanks, na)
        array.push(previousStates, "N/A")
        array.push(persistenceCounts, 0)
        array.push(latestRankChanges, na)

bool anyLeaderEntry = false
bool anyQuadrantTransition = false
bool anyLeadershipLoss = false
bool anyPersistenceHit = false
string eventMessage = ""

if newScan
    for i = 0 to symbolCount - 1
        string symbolName = f_shortSymbol(array.get(symbols, i))
        int rankNow = array.get(currentRanks, i)
        int rankBefore = array.get(previousRanks, i)
        string stateNow = array.get(currentStates, i)
        string stateBefore = array.get(previousStates, i)
        int persistenceBefore = array.get(persistenceCounts, i)
        int persistenceNow = not na(rankNow) and rankNow <= topQuartile ? persistenceBefore + 1 : 0
        array.set(persistenceCounts, i, persistenceNow)
        array.set(latestRankChanges, i, not na(rankNow) and not na(rankBefore) ? rankBefore - rankNow : na)

        bool leaderEntry = sendAlertsInput and not na(rankBefore) and not na(rankNow) and rankBefore > leaderCount and rankNow <= leaderCount
        bool quadrantTransition = sendAlertsInput and stateBefore != "N/A" and stateNow != "N/A" and stateBefore != stateNow
        bool leadershipLoss = sendAlertsInput and not na(rankBefore) and not na(rankNow) and rankBefore <= leaderCount and rankNow > leaderCount
        bool persistenceHit = sendAlertsInput and persistenceBefore < persistenceThresholdInput and persistenceNow >= persistenceThresholdInput

        if leaderEntry
            anyLeaderEntry := true
            eventMessage := f_appendEvent(eventMessage, symbolName + " entered Top " + str.tostring(leaderCount))
        if quadrantTransition
            anyQuadrantTransition := true
            eventMessage := f_appendEvent(eventMessage, symbolName + ": " + stateBefore + " → " + stateNow)
        if leadershipLoss
            anyLeadershipLoss := true
            eventMessage := f_appendEvent(eventMessage, symbolName + " left Top " + str.tostring(leaderCount))
        if persistenceHit
            anyPersistenceHit := true
            eventMessage := f_appendEvent(eventMessage, symbolName + " reached " + str.tostring(persistenceThresholdInput) + " top-quartile scans")

        array.set(previousRanks, i, rankNow)
        array.set(previousStates, i, stateNow)

    if eventMessage != ""
        alert("TF Relative Strength Screener | " + str.format_time(scanStamp, "yyyy-MM-dd HH:mm") + "\n" + eventMessage, alert.freq_once_per_bar)

bool anyEvent = anyLeaderEntry or anyQuadrantTransition or anyLeadershipLoss or anyPersistenceHit
alertcondition(anyLeaderEntry, "RS leader entry", "A symbol entered the selected leader group. Use an 'Any alert() function call' alert for symbol details.")
alertcondition(anyQuadrantTransition, "RS rotation change", "A symbol changed rotation state. Use an 'Any alert() function call' alert for symbol details.")
alertcondition(anyLeadershipLoss, "RS leadership loss", "A symbol left the Top-N group. Use an 'Any alert() function call' alert for symbol details.")
alertcondition(anyPersistenceHit, "RS leadership confirmed", "A symbol reached the selected leadership-confirmation count. Use an 'Any alert() function call' alert for symbol details.")
alertcondition(anyEvent, "Any RS screener event", "The Relative Strength Screener generated an event. Use an 'Any alert() function call' alert for symbol details.")




int requestedFocusIndex = array.indexof(symbols, focusSymbolInput)
int focusIndex = requestedFocusIndex >= 0 ? requestedFocusIndex : 0
string oscSymbol = array.get(symbols, focusIndex)
[oscClose, oscTime] = request.security(oscSymbol, timeframe.period, [close[1], time[1]], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
[oscBenchmark, oscBenchTime] = request.security(benchmarkInput, timeframe.period, [close[1], time[1]], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)

bool oscAligned = not na(oscClose) and not na(oscBenchmark) and oscBenchmark > 0 and oscTime == oscBenchTime
float oscRatio = oscAligned ? oscClose / oscBenchmark : na
float oscRaw = not na(oscRatio[oscLookbackInput]) and oscRatio[oscLookbackInput] > 0 ? 100.0 * (oscRatio / oscRatio[oscLookbackInput] - 1.0) : na
float oscSmoothed = ta.ema(oscRaw, oscSmoothInput)
float oscSignalBase = ta.ema(oscSmoothed, oscSignalInput)
float oscValue = not na(oscRaw) ? oscSmoothed : na
float oscSignal = not na(oscRaw) ? oscSignalBase : na
color oscColor = oscValue >= 0 ? #26d6ad : #f16b82
color ribbonColor = oscValue >= oscSignal ? color.new(#26d6ad, 88) : color.new(#f16b82, 88)
hline(0, "Benchmark parity • 0%", color = color.new(#b0bec5, 45), linestyle = hline.style_dashed)
oscPlot = plot(oscValue, "Relative performance % (smoothed)", color = oscColor, linewidth = 3, style = plot.style_linebr)
signalPlot = plot(oscShowSignalInput ? oscSignal : na, "Relative performance signal", color = color.new(#c8d0df, 35), linewidth = 1, style = plot.style_linebr, display = display.pane)
fill(oscPlot, signalPlot, color = oscShowSignalInput ? ribbonColor : na, title = "Relative acceleration ribbon", fillgaps = false)
plot(oscRaw, "Unsmoothed benchmark-relative return %", display = display.data_window)
var label oscEndLabel = na
if barstate.islast
    label.delete(oscEndLabel)
    if oscShowLabelInput
        string oscName = f_shortSymbol(oscSymbol) + " / " + f_shortSymbol(benchmarkInput)
        string oscText = oscName + (na(oscValue) ? " • No aligned data" : "  " + str.tostring(oscValue, "+#.##;-#.##") + "%")
        oscEndLabel := label.new(bar_index + 2, nz(oscValue, 0), oscText, style = label.style_label_left, color = color.new(#0d1a3f, 100), textcolor = na(oscValue) ? color.gray : oscColor, size = size.small, tooltip = "Smoothed relative return over " + str.tostring(oscLookbackInput) + " chart bars. Above zero: outperforming the benchmark. Below zero: underperforming. Ribbon: line versus EMA signal, not a buy/sell recommendation. Confirmed data: one chart bar late.")


var table dashboard = table.new(dashboardPositionInput, 7, 14, bgcolor = #0d1a3f, border_width = 1, frame_width = 1, frame_color = #1c306d, border_color = #1c306d, force_overlay = true)
var table matrix = table.new(matrixPositionInput, 2, 5, bgcolor = #0d1a3f, border_width = 1, frame_width = 1, frame_color = #1c306d, border_color = #1c306d, force_overlay = true)

if barstate.islast
    table.clear(dashboard, 0, 0, 6, 13)
    table.clear(matrix, 0, 0, 1, 4)

    if showDashboardInput
        color headerBg = #1c306d
        color headerFg = color.white
        int rankedCount = 0
        for i = 0 to symbolCount - 1
            if not na(array.get(compositeScores, i))
                rankedCount += 1
        bool completeUniverse = rankedCount == symbolCount
        bool lowerTfNoData = scanIsLower and rankedCount == 0
        bool lowerTfLimited = scanIsLower and rankedCount > 0 and not completeUniverse
        string scanLabel = f_timeframeLabel(scanTfInput)
        string chartLabel = f_timeframeLabel(timeframe.period)
        table.cell(dashboard, 0, 0, "♦ TradingFinder ♦", text_color = #56cfe0, text_size = dashboardSizeInput, bgcolor = #0d1a3f)
        table.merge_cells(dashboard, 0, 0, 6, 0)
        string checkUnit = scanIsLower ? "chart checks" : "scans"
        string scanMode = scanIsLower ? "Intrabar snapshot" : "Confirmed bars"
        string contextText = str.tostring(symbolCount) + " symbols vs " + f_shortSymbol(benchmarkInput) + " | Scan " + scanLabel + " | " + scanMode
        if scanIsLower
            contextText := "Scan " + scanLabel + " < Chart " + chartLabel + " | " + scanMode
        if lowerTfNoData
            contextText := "NO DATA — Scan " + scanLabel + " is below Chart " + chartLabel
        else if lowerTfLimited
            contextText := "LIMITED DATA — Scan " + scanLabel + " is below Chart " + chartLabel + " | " + str.tostring(rankedCount) + "/" + str.tostring(symbolCount) + " symbols"
        else if not completeUniverse
            contextText += " | Data: " + str.tostring(rankedCount) + "/" + str.tostring(symbolCount)
        string contextTip = scanIsLower ? "The table uses the latest available lower-timeframe intrabar. Historical rank changes and streaks advance once per completed chart bar." : "The table uses the previous confirmed Scan Timeframe bar."
        if lowerTfNoData or lowerTfLimited
            contextTip := "The Scan Timeframe is lower than the Chart Timeframe. TradingView may have limited lower-timeframe intrabar history, so the request did not return usable data for every selected symbol. Use a lower chart timeframe for fuller history."
        table.cell(dashboard, 0, 1, contextText, text_color = completeUniverse ? #c6d4eb : #ffbf69, text_size = dashboardSizeInput, bgcolor = lowerTfNoData ? color.new(#b93241, 35) : lowerTfLimited ? color.new(#e09100, 50) : #111d3a, tooltip = contextTip + " Latest data: " + (na(scanStamp) ? "Waiting" : str.format_time(scanStamp, "yyyy-MM-dd HH:mm")))
        table.merge_cells(dashboard, 0, 1, 6, 1)
        array<string> headers = array.from("Rank", "Symbol", "Takeaway / Evidence", "vs Benchmark", "Score / 100", "Top-group streak", "Rank change")
        array<string> tips = array.from("Position among symbols with valid scores. Ties share a rank.", "Selected watchlist symbol.", "Descriptive screening conclusion, not an entry or exit signal. Momentum below is the change in benchmark-relative return over the configured Momentum Length, in percentage points.", "Relative wealth-factor return. Positive = ahead of benchmark; negative = behind.", "Weighted strength and momentum percentiles. A comparison score, NOT a probability of profit.", "Consecutive " + checkUnit + " ranked in the top " + str.tostring(topQuartile) + " of " + str.tostring(symbolCount) + " selected symbols. This does not count benchmark outperformance.", "Change since the previous " + (scanIsLower ? "completed chart check" : "confirmed scan") + ". Up means a better rank.")
        for col = 0 to 6
            table.cell(dashboard, col, 2, array.get(headers, col), text_color = headerFg, text_size = dashboardSizeInput, bgcolor = headerBg, tooltip = array.get(tips, col))
        array<float> sortableScores = array.copy(compositeScores)
        for i = 0 to symbolCount - 1
            if na(array.get(sortableScores, i))
                array.set(sortableScores, i, -1e10)
        array<int> sortedIndices = array.sort_indices(sortableScores, order.descending)
        for row = 0 to symbolCount - 1
            int i = array.get(sortedIndices, row)
            int rankNow = array.get(currentRanks, i)
            float rel = array.get(relativeReturns, i)
            float mom = array.get(relativeMomentum, i)
            float score = array.get(compositeScores, i)
            int persistence = array.get(persistenceCounts, i)
            int deltaRank = array.get(latestRankChanges, i)
            bool valid = not na(rankNow) and not na(rel) and not na(mom)
            // Priority matters: a deteriorating leader must not be called durable.
            bool fading = valid and rel > 0 and mom < 0
            bool durable = valid and rel > 0 and mom >= 0 and rankNow <= topQuartile and persistence >= persistenceThresholdInput
            bool improving = valid and mom > 0 and not na(deltaRank) and deltaRank > 0
            bool behind = valid and rel < 0 and mom <= 0 and (na(deltaRank) or deltaRank <= 0)
            string takeaway = "Mixed evidence"
            color conclusionColor = #b5c3d8
            if not valid
                takeaway := "Insufficient data"
            else if not completeUniverse
                takeaway := "Incomplete comparison"
                conclusionColor := #ffbf69
            else if fading
                takeaway := "Outperforming, fading"
                conclusionColor := #ffbf69
            else if durable
                takeaway := "Sustained leadership"
                conclusionColor := #26d6ad
            else if improving
                takeaway := rel < 0 ? "Recovering, still behind" : "Climbing the ranks"
                conclusionColor := #56cfe0
            else if behind
                takeaway := "Behind, no recovery"
                conclusionColor := #f16b82
            string evidence = not valid ? "More history required" : "Relative change " + str.tostring(mom, "+#.##;-#.##") + " pp"
            string explanation = "Classification priority: incomplete data; outperforming with negative relative momentum; positive relative return + nonnegative momentum + top-group rank for at least " + str.tostring(persistenceThresholdInput) + " " + checkUnit + "; positive momentum + rising rank; negative relative return without improvement; otherwise mixed. These summaries differ from the matrix's cross-sectional quadrants."
            string relativeText = na(rel) ? "No data" : str.tostring(math.abs(rel), "#.##") + (rel > 0 ? "% ahead" : rel < 0 ? "% behind" : "% · On par")
            string deltaText = na(deltaRank) ? "No prior check" : deltaRank > 0 ? "↑ " + str.tostring(deltaRank) + " places" : deltaRank < 0 ? "↓ " + str.tostring(math.abs(deltaRank)) + " places" : "Unchanged"
            color rowBg = row % 2 == 0 ? #111d3a : #0d1732
            color deltaColor = na(deltaRank) or deltaRank == 0 ? #b5c3d8 : deltaRank > 0 ? #26d6ad : #f16b82
            int tableRow = row + 3
            table.cell(dashboard, 0, tableRow, na(rankNow) ? "—" : str.tostring(rankNow) + " of " + str.tostring(rankedCount), text_color = headerFg, text_size = dashboardSizeInput, bgcolor = rowBg)
            table.cell(dashboard, 1, tableRow, f_shortSymbol(array.get(symbols, i)), text_color = headerFg, text_size = dashboardSizeInput, bgcolor = rowBg)
            table.cell(dashboard, 2, tableRow, takeaway + "\n" + evidence, text_color = conclusionColor, text_size = dashboardSizeInput, bgcolor = color.new(conclusionColor, 90), text_halign = text.align_left, tooltip = explanation)
            table.cell(dashboard, 3, tableRow, relativeText, text_color = na(rel) or rel == 0 ? #b5c3d8 : rel > 0 ? #26d6ad : #f16b82, text_size = dashboardSizeInput, bgcolor = rowBg)
            table.cell(dashboard, 4, tableRow, na(score) ? "—" : str.tostring(score, "#.0") + " / 100", text_color = headerFg, text_size = dashboardSizeInput, bgcolor = f_heatColor(score), tooltip = "Comparison score only. Not win rate or confidence.")
            table.cell(dashboard, 5, tableRow, not valid ? "—" : str.tostring(persistence) + " " + checkUnit, text_color = valid and persistence >= persistenceThresholdInput ? #26d6ad : #b5c3d8, text_size = dashboardSizeInput, bgcolor = rowBg)
            table.cell(dashboard, 6, tableRow, deltaText, text_color = deltaColor, text_size = dashboardSizeInput, bgcolor = rowBg)
        int footerRow = symbolCount + 3
        table.cell(dashboard, 0, footerRow, "Compare → Shortlist → Check price setup | Score ≠ win probability", text_color = #b5c3d8, text_size = dashboardSizeInput, bgcolor = #0d1a3f)
        table.merge_cells(dashboard, 0, footerRow, 6, footerRow)

    if showMatrixInput
        string improvingList = ""
        string leadingList = ""
        string laggingList = ""
        string weakeningList = ""
        array<float> matrixSortableScores = array.copy(compositeScores)
        for i = 0 to symbolCount - 1
            if na(array.get(matrixSortableScores, i))
                array.set(matrixSortableScores, i, -1e10)
        array<int> matrixOrder = array.sort_indices(matrixSortableScores, order.descending)
        for row = 0 to symbolCount - 1
            int i = array.get(matrixOrder, row)
            string name = f_shortSymbol(array.get(symbols, i))
            string state = array.get(currentStates, i)
            if state == "Improving"
                improvingList += (improvingList == "" ? "" : "\n") + name
            else if state == "Leading"
                leadingList += (leadingList == "" ? "" : "\n") + name
            else if state == "Lagging"
                laggingList += (laggingList == "" ? "" : "\n") + name
            else if state == "Weakening"
                weakeningList += (weakeningList == "" ? "" : "\n") + name
        table.cell(matrix, 0, 0, "ROTATION MATRIX", text_color = #56cfe0, text_size = matrixSizeInput, bgcolor = #0d1a3f)
        table.merge_cells(matrix, 0, 0, 1, 0)
        table.cell(matrix, 0, 1, "IMPROVING  ↑", text_color = f_stateColor("Improving"), text_size = matrixSizeInput, bgcolor = #0d1732)
        table.cell(matrix, 1, 1, "LEADING  ◆", text_color = f_stateColor("Leading"), text_size = matrixSizeInput, bgcolor = #0d1732)
        table.cell(matrix, 0, 2, improvingList == "" ? "—" : improvingList, text_color = color.white, text_size = matrixSizeInput, bgcolor = color.new(f_stateColor("Improving"), 58), text_halign = text.align_left)
        table.cell(matrix, 1, 2, leadingList == "" ? "—" : leadingList, text_color = color.white, text_size = matrixSizeInput, bgcolor = color.new(f_stateColor("Leading"), 58), text_halign = text.align_left)
        table.cell(matrix, 0, 3, "LAGGING  ↓", text_color = f_stateColor("Lagging"), text_size = matrixSizeInput, bgcolor = #0d1732)
        table.cell(matrix, 1, 3, "WEAKENING  ◇", text_color = f_stateColor("Weakening"), text_size = matrixSizeInput, bgcolor = #0d1732)
        table.cell(matrix, 0, 4, laggingList == "" ? "—" : laggingList, text_color = color.white, text_size = matrixSizeInput, bgcolor = color.new(f_stateColor("Lagging"), 58), text_halign = text.align_left)
        table.cell(matrix, 1, 4, weakeningList == "" ? "—" : weakeningList, text_color = color.white, text_size = matrixSizeInput, bgcolor = color.new(f_stateColor("Weakening"), 58), text_halign = text.align_left)
````
