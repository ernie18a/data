# ICT Pullback Setup | Smart OTE Fibonacci Levels [RadixAlgo] 

- url: https://www.tradingview.com/script/gkbKRAe1-ICT-Pullback-Setup-Smart-OTE-Fibonacci-Levels-RadixAlgo/
- type: indicator
- pine_id: PUB;1004fcced8a4427980e193286869ae78
- version: 1.0

## Description

🔶[b]About the Indicator[/b]

A strong price move rarely travels in a perfectly straight line. Markets expand, create directional displacement, reach temporary extremes, and then retrace before deciding whether the original move still has enough strength to continue. For traders using ICT concepts, Smart Money Concepts, Fibonacci retracement, OTE trading, and price action, this pullback phase is often where the most useful information appears.

[image]https://www.tradingview.com/x/EYai5Xvu/[/image]

The challenge is not simply drawing a Fibonacci retracement between two visible points. The more difficult part is identifying which swing actually represents the active move, where the impulse begins, how far the displacement has extended, and whether the current retracement still belongs to the same market structure.

ICT Pullback Setup | Smart OTE Fibonacci Levels [RadixAlgo] was built to simplify this process. Instead of relying on a static Fibonacci tool drawn manually between two swing points, the indicator analyzes directional price movement, identifies the active origin and destination, and creates an adaptive Fibonacci retracement structure around the developing impulse.

As the market continues expanding, the destination can update with new highs or lows. This keeps the Fibonacci retracement levels and selected OTE entry aligned with the latest extension of the move rather than leaving the setup anchored to an older swing that may no longer represent current price action.

The indicator combines displacement analysis, Fibonacci retracement, pullback detection, ATR-based stop-loss placement, and reward-to-risk visualization in one chart-based framework. Bullish and bearish setups are treated separately, allowing traders to follow the complete sequence from the initial impulse to the retracement, entry area, stop-loss, and potential target.

This is not simply a Fibonacci drawing tool. It is designed to give traders more context around ICT pullbacks, Optimal Trade Entry zones, Smart Money price action, market structure, trend continuation, and retracement behavior while keeping the entire setup visible directly on the chart.

🔶[b]How It Works[/b]

The indicator begins by identifying the market structure behind a potential pullback. Confirmed pivot highs and pivot lows are treated as possible origins for directional movement, but a pivot alone is not enough to activate a setup. The script evaluates how far price moves away from the structural point relative to ATR and the number of candles involved, helping distinguish meaningful directional displacement from smaller or slower price fluctuations.

Once sufficient displacement is detected, the indicator defines an origin and a destination for the active impulse. The origin represents the structural point from which the move develops, while the destination represents the furthest price reached in the direction of that movement. The destination remains dynamic and can continue updating as price creates new highs or lows.

This allows the Fibonacci retracement and selected entry level to remain connected to the latest extension of the active move rather than an earlier swing. Once the origin and destination are established, the indicator calculates the main Fibonacci retracement levels, including 23.6%, 38.2%, 50.0%, 61.8%, and 78.6%. Traders can select one of these levels as the active entry, ranging from shallower retracements to deeper OTE-style pullback zones.

🔹[b]Bullish Pullback Setup[/b]

A bullish setup begins from a confirmed structural low. The indicator monitors the upward movement developing from that point and waits for sufficient displacement relative to ATR and the number of candles involved. Once the condition is satisfied, the structural low becomes the bullish origin and the highest price reached during the move becomes the destination.

[image]https://www.tradingview.com/x/k8hH548w/[/image]

If the bullish impulse continues creating new highs, the destination updates automatically. The Fibonacci retracement and selected entry level are recalculated with each new extension, keeping the setup aligned with the developing bullish move rather than an earlier high.    

[image]https://www.tradingview.com/x/OoBwC0Or/[/image]

The entry becomes relevant when price retraces to the selected Fibonacci level. Instead of entering during the initial upward displacement, the setup waits for price to return into the active impulse. A shallower Fibonacci level requires a smaller pullback, while levels such as 61.8% or 78.6% require price to retrace deeper toward the bullish origin.

[image]https://www.tradingview.com/x/pj8T7KjS/[/image]

Once the bullish entry is triggered, the stop-loss is positioned below the structural origin with an ATR-based buffer. The distance between the entry and stop-loss defines the initial risk, which is then used to calculate the reward levels above the entry.



🔹[b]Bearish Pullback Setup[/b]

A bearish setup follows the same process in the opposite direction. It begins from a confirmed structural high, and the indicator monitors the downside movement developing from that point. Once sufficient bearish displacement is detected, the structural high becomes the bearish origin and the lowest price reached during the move becomes the destination.

[image]https://www.tradingview.com/x/h986pwSt/[/image]

If price continues creating lower lows, the destination updates automatically. The Fibonacci retracement and selected entry level are recalculated with each extension, allowing the setup to remain aligned with the latest bearish expansion.   

[image]https://www.tradingview.com/x/HlhHaq7X/[/image]

The entry becomes relevant when price retraces upward to the selected Fibonacci level. A shallow retracement reaches the entry earlier, while a deeper level requires price to move further back toward the bearish origin before the setup is triggered.

[image]https://www.tradingview.com/x/fHcjY1ns/[/image]

Once the bearish entry is triggered, the stop-loss is positioned above the structural origin with an ATR-based buffer. The distance between the entry and stop-loss defines the initial risk, and the reward levels are then projected below the entry according to the selected Reward / Risk setting.

🔹[b]Pending Entry & Intrabar Resolution[/b]

Once a valid bullish or bearish setup becomes active, the selected Fibonacci level is treated as a pending entry. If the impulse extends again before price reaches that level, the destination changes and the Fibonacci entry is recalculated automatically. The pending entry therefore continues adapting to the active price move until it is triggered or reaches its expiration limit.

Historical candles can create an additional challenge when the same candle both extends the destination and touches a Fibonacci entry. A standard OHLC candle cannot always reveal whether the extension occurred before or after the retracement.

When the optional historical intrabar check is enabled, the indicator uses lower-timeframe data to inspect this sequence in greater detail. It can evaluate whether the previous entry was reached first, whether the destination extended before the retracement, or whether the newly calculated entry was reached after that extension.   

This provides a more detailed reconstruction of historical entries than relying only on the high and low of the chart candle, particularly when extension and retracement occur within the same bar.

🔹[b]Risk & Reward Management[/b]

After an entry is triggered, the indicator creates a reward-to-risk structure directly on the chart. The entry becomes the central reference point, while the structural stop-loss defines the initial risk distance.

Each reward level is calculated from that same risk distance. With a Reward / Risk setting of 2, for example, the indicator displays an intermediate 1R level and a final 2R target. Bullish reward levels are projected above the entry, while bearish reward levels are projected below it.   

The indicator continues monitoring the active R/R structure after entry. A position can reach the stop-loss, reach the take-profit, expire after the maximum number of position bars, or close because of an opposite entry when that option is enabled. When historical price data cannot reliably determine the sequence between stop-loss and target events, the result can also be classified as Ambiguous.  

The Fibonacci structure is intended to organize the relationship between displacement, retracement, entry, invalidation, and reward. The selected retracement depth defines where the pullback entry is placed, while broader price action and market context can be used separately when evaluating the significance of the setup.

🔶[b]Input Parameters[/b]

🔹Entry Fibonacci Level
Selects the Fibonacci retracement level used as the active pullback entry. Available options are 23.6%, 38.2%, 50.0%, 61.8%, and 78.6%. Lower levels create shallower entry areas, while higher values require price to retrace deeper into the original displacement before the entry is triggered.

🔹Entry Expiration Bars
Defines how long the pending Fibonacci entry remains active after the latest extension of the move. If price does not reach the selected entry within the specified number of bars, the pending entry expires.

🔹Reward / Risk
Controls the final reward target relative to the distance between the entry and stop-loss. For example, a value of 2 places the final target at 2R, meaning twice the original risk distance from the entry.

🔹Stop-Loss ATR Threshold
Controls the ATR-based buffer added beyond the structural origin of the setup. Higher values place the stop-loss farther beyond the swing point, while lower values keep the stop closer to the original structure.

🔹Use Intrabar Historical Check
Enables lower-timeframe analysis for historical entry detection. This helps the indicator determine the sequence of events when a candle both extends the destination and reaches a Fibonacci entry level.

🔹Historical Intrabar Timeframe
Selects the lower timeframe used for historical intrabar analysis. Smaller timeframes provide more detailed information about the movement inside each chart candle when sufficient lower-timeframe data is available.

🔹Block New Same-Type Position While Open
Prevents the indicator from activating another position in the same direction while an existing position of that type is still active.

🔹Close Opposite Position On New Entry
Allows a newly triggered entry in the opposite direction to close the currently active position. When disabled, opposite setups can be handled independently according to the existing position logic.

🔹Delete Previous R/R
Controls whether the previous reward-to-risk visualization is removed when a new R/R setup is created. Enabling this option keeps the chart focused on the most recent trade structure.

🔹Position Expiration Bars
Defines the maximum number of bars an active R/R setup can remain unresolved. If neither the stop-loss nor the take-profit is reached during this period, the position is marked as expired.

🔶[b]Summary[/b]

ICT Pullback Setup | Smart OTE Fibonacci Levels [RadixAlgo] combines market structure, directional displacement, Fibonacci retracement, OTE-style pullback entries, ATR-based stop-loss placement, and reward-to-risk analysis in one adaptive framework.

Instead of requiring traders to manually select two fixed swing points, the indicator identifies the active origin and destination of the move and continues updating the destination while price expands. This allows the Fibonacci retracement levels to remain connected to the current impulse as market structure develops.

The selected Fibonacci entry gives traders a structured way to monitor shallow or deep pullbacks, while the historical intrabar system helps improve the interpretation of situations where extension and entry occur inside the same candle.

After an entry is triggered, the built-in R/R visualization connects the setup with its structural stop-loss and potential reward levels, allowing traders to follow the entire process from displacement and retracement to entry, risk, and possible continuation.

The indicator can be used alongside ICT concepts, Smart Money Concepts, market structure analysis, liquidity, fair value gaps, order blocks, trend-following strategies, and price action trading. Rather than replacing trader judgment with a rigid signal system, it provides a visual framework for understanding how price moves from impulse to pullback and from pullback toward potential continuation.

⚠️[b]Disclaimer[/b]

This indicator is designed for educational and analytical purposes only and should not be considered financial advice or a recommendation to enter any trade. Every signal should be evaluated by the trader based on their own market analysis, strategy, risk tolerance, and trading plan. The decision to use or ignore a signal always remains with the trader.

Not every signal will result in a profitable trade, and losing setups are a normal part of market participation. Historical performance, Fibonacci retracement behavior, OTE-style setups, and reward-to-risk projections do not guarantee future results. Traders should apply appropriate risk management and use the indicator as a supporting analytical tool rather than as an automatic decision-making system.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © RadixAlgo
//@version=6
indicator("ICT Pullback Setup | Smart OTE Fibonacci Levels [RadixAlgo] ", "RadixAlgo | ICT PS",max_bars_back = 5000, overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)
//Input
Entry_Fib = input.string('78.6%', 'Entry Fibonacci Level', options = ['23.6%', '38.2%', '50.0%', '61.8%', '78.6%'], group = 'Trade Setup')
Entry_Expiration = input.int(50, 'Entry Expiration Bars', minval = 1, group = 'Trade Setup')
Reward_Risk = input.int(2, 'Reward / Risk', minval = 1, maxval = 10, group = 'Trade Setup')
SL_ATR_Threshold = input.float(2, 'Stop-Loss ATR Threshold', minval = 0, step = 0.1, group = 'Trade Setup')
Use_Intrabar = input.bool(true, 'Use Intrabar Historical Check', group = 'Trade Setup')
Intrabar_Timeframe = input.timeframe('', 'Historical Intrabar Timeframe', group = 'Trade Setup')
Block_Same_Type_Position = input.bool(false, 'Block New Same-Type Position While Open', group = 'Position Management')
Close_Opposite_Position = input.bool(false, 'Close Opposite Position On New Entry', group = 'Position Management')
Delete_Previous_RR = input.bool(false, 'Delete Previous R/R', group = 'Position Management')
Position_Expiration = input.int(200, 'Position Expiration Bars', minval = 1, group = 'Position Management')
ATR_SL = ta.atr(25)
Entry_Fib_Coe = switch Entry_Fib
    '23.6%' => 0.236
    '38.2%' => 0.382
    '50.0%' => 0.500
    '61.8%' => 0.618
    '78.6%' => 0.786
    => 0.618
[Intra_High, Intra_Low] = request.security_lower_tf(syminfo.tickerid, Intrabar_Timeframe, [high, low], ignore_invalid_timeframe = true)
//Fibonacci
Fibonacci(float Y_0, float Y_1, float Y_x) =>
    Fib_Coe = array.from(0, 0.236, 0.382, 0.5, 0.618, 0.786, 1, Y_x)
    Fib_Lvl = array.new_float(8)
    for i = 0 to 7 by 1
        array.set(Fib_Lvl, i, (Y_0 + (Y_1 - Y_0) * Fib_Coe.get(i)))
    [Fib_Lvl]
FibonacciPlot(Y_0, Y_1, X_0, X_1, Y_x, Show) =>
    var Lines  = array.new_line(7)
    var Labels = array.new_label(7)
    var Fill   = array.new_linefill(6)
    var line Lines_Y_x = na
    var label Labels_Y_x = na
    var int X_0_Fix = na
    var int X_1_Fix = na
    var float Y_0_Prev = na
    var float Y_1_Prev = na
    Fib_Coe = array.from(0, 0.236, 0.382, 0.5, 0.618, 0.786, 1)
    Fib_Colors = array.from(#808080, #f23645, #ff9800, #4caf50, #089981, #00bcd4, #808080)
    Fib_Fills = array.from(color.new(#f23645, 80), color.new(#ff9800, 80), color.new(#4caf50, 80), color.new(#089981, 80), color.new(#00bcd4, 80), color.new(#808080, 80))
    [Fibo_Lvl] = Fibonacci(Y_0, Y_1, Y_x)
    if barstate.islast
        if na(X_0_Fix)
            X_0_Fix := X_0
            X_1_Fix := X_1
            Y_0_Prev := Y_0
            Y_1_Prev := Y_1
        else if Y_1 != Y_1_Prev
            X_0_Fix := X_0
            X_1_Fix := X_1
            Y_0_Prev := Y_0
            Y_1_Prev := Y_1
        else if Y_0 != Y_0_Prev
            X_1_Fix := X_1
            Y_0_Prev := Y_0
        for i = 0 to 6
            Line  = array.get(Lines, i)
            Label = array.get(Labels, i)
            if na(Line)
                Line := line.new(X_0_Fix, Fibo_Lvl.get(i), X_1_Fix, Fibo_Lvl.get(i), color = Show ? Fib_Colors.get(i) : color.new(Fib_Colors.get(i), 100), style = line.style_dotted)
                array.set(Lines, i, Line)
            else
                line.set_xy1(Line, X_0_Fix, Fibo_Lvl.get(i))
                line.set_xy2(Line, X_1_Fix, Fibo_Lvl.get(i))
                line.set_color(Line, Show ? Fib_Colors.get(i) : color.new(Fib_Colors.get(i), 100))
            Label_X = Y_0 > Y_1 ? X_0_Fix - 4 : X_1_Fix + 2
            Label_Text = str.tostring(Fib_Coe.get(i)) + ' (' + str.tostring(Fibo_Lvl.get(i), "#.##") + ')'
            if na(Label)
                Label := label.new(Label_X, Fibo_Lvl.get(i), Label_Text, color = na, textcolor = Show ? #8d8d8d : color.new(#8d8d8d, 100), style = label.style_label_center)
                array.set(Labels, i, Label)
            else
                label.set_xy(Label, Label_X, Fibo_Lvl.get(i))
                label.set_text(Label, Label_Text)
                label.set_textcolor(Label, Show ? #8d8d8d : color.new(#8d8d8d, 100))
        for i = 0 to 5
            Fib_Fill = array.get(Fill, i)
            if na(Fib_Fill)
                Fib_Fill := linefill.new(array.get(Lines, i), array.get(Lines, i + 1), Show ? Fib_Fills.get(i) : color.new(Fib_Fills.get(i), 100))
                array.set(Fill, i, Fib_Fill)
            else
                linefill.set_color(Fib_Fill, Show ? Fib_Fills.get(i) : color.new(Fib_Fills.get(i), 100))
FibonacciEntry(float Destination, float Origin, float Coe) =>
    Entry_Level = Destination + ((Origin - Destination) * Coe)
    Entry_Level
HistoricalEntryResolver(bool Is_Buy, float Previous_Destination, float Current_Destination, float Origin, float Fib_Coe) =>
    int Result = 0
    float Entry_Price = na
    int Entry_Index = -1
    float Sim_Destination = Previous_Destination
    Intrabar_Count = array.size(Intra_High)
    if Use_Intrabar and Intrabar_Count > 0
        for i = 0 to Intrabar_Count - 1
            Intra_H = array.get(Intra_High, i)
            Intra_L = array.get(Intra_Low , i)
            Old_Entry = FibonacciEntry(Sim_Destination, Origin, Fib_Coe)
            Extension = Is_Buy ?
                 Intra_H > Sim_Destination :
                 Intra_L < Sim_Destination
            New_Destination = Extension ?
                 (Is_Buy ? math.max(Sim_Destination, Intra_H) : math.min(Sim_Destination, Intra_L)) :
                 Sim_Destination
            New_Entry = FibonacciEntry(New_Destination, Origin, Fib_Coe)
            Old_Entry_Touched = Is_Buy ?
                 Intra_L <= Old_Entry :
                 Intra_H >= Old_Entry
            New_Entry_Touched = Is_Buy ?
                 Intra_L <= New_Entry :
                 Intra_H >= New_Entry
            if Extension and New_Entry_Touched
                Result      := 1
                Entry_Price := New_Entry
                Entry_Index := i
                break
            else if Old_Entry_Touched
                Result      := 1
                Entry_Price := Old_Entry
                Entry_Index := i
                break
            else if Extension
                Sim_Destination := New_Destination
    else
        Old_Entry = FibonacciEntry(Previous_Destination, Origin, Fib_Coe)
        New_Entry = FibonacciEntry(Current_Destination, Origin, Fib_Coe)
        Extension = Current_Destination != Previous_Destination
        if not Extension
            Entry_Touched = Is_Buy ?
                 low <= Old_Entry :
                 high >= Old_Entry
            if Entry_Touched
                Result      := 1
                Entry_Price := Old_Entry
        else
            Same_Bar_Entry_Touched = Is_Buy ?
                 low <= New_Entry :
                 high >= New_Entry
            if Same_Bar_Entry_Touched
                Result      := 1
                Entry_Price := New_Entry
    [Result, Entry_Price, Entry_Index]
TradeBarResolver(bool Is_Buy, float Entry, float Stop, float Target, float Risk, int RR_Limit, bool Entry_Bar, int Entry_Index) =>
    int Exit_Result = 0
    int Max_R_Bar   = 0
    Intrabar_Count = array.size(Intra_High)
    Can_Use_Intrabar =
         Use_Intrabar and
         Intrabar_Count > 0
    if Entry_Bar
        if Can_Use_Intrabar and Entry_Index >= 0 and Entry_Index < Intrabar_Count
            Entry_Intra_H = array.get(Intra_High, Entry_Index)
            Entry_Intra_L = array.get(Intra_Low , Entry_Index)
            Entry_Intra_Stop = Is_Buy ?
                 Entry_Intra_L <= Stop :
                 Entry_Intra_H >= Stop
            Entry_Intra_Target = Is_Buy ?
                 Entry_Intra_H >= Target :
                 Entry_Intra_L <= Target
            if Entry_Intra_Stop and Entry_Intra_Target
                Exit_Result := 2
            else if Entry_Intra_Stop
                Exit_Result := -1
            else if Entry_Intra_Target
                Exit_Result := 2
            if Exit_Result == 0 and Entry_Index + 1 < Intrabar_Count
                for i = Entry_Index + 1 to Intrabar_Count - 1
                    Intra_H = array.get(Intra_High, i)
                    Intra_L = array.get(Intra_Low , i)
                    Stop_Hit = Is_Buy ?
                         Intra_L <= Stop :
                         Intra_H >= Stop
                    Target_Hit = Is_Buy ?
                         Intra_H >= Target :
                         Intra_L <= Target
                    if Stop_Hit and Target_Hit
                        Exit_Result := 2
                        break
                    else if Stop_Hit
                        Exit_Result := -1
                        break
                    else
                        Current_R = Is_Buy ?
                             (Intra_H - Entry) / Risk :
                             (Entry - Intra_L) / Risk
                        Current_R_Int = int(math.floor(math.max(Current_R, 0)))
                        Max_R_Bar := math.max(Max_R_Bar, math.min(Current_R_Int, RR_Limit))
                        if Target_Hit
                            Exit_Result := 1
                            Max_R_Bar   := RR_Limit
                            break
        else
            Entry_Bar_Stop = Is_Buy ?
                 low <= Stop :
                 high >= Stop
            Entry_Bar_Target = Is_Buy ?
                 high >= Target :
                 low <= Target
            if Entry_Bar_Stop and Entry_Bar_Target
                Exit_Result := 2
            else if Entry_Bar_Stop
                Exit_Result := -1
            else if Entry_Bar_Target
                Exit_Result := 2
    else
        if Can_Use_Intrabar
            for i = 0 to Intrabar_Count - 1
                Intra_H = array.get(Intra_High, i)
                Intra_L = array.get(Intra_Low , i)
                Stop_Hit = Is_Buy ?
                     Intra_L <= Stop :
                     Intra_H >= Stop
                Target_Hit = Is_Buy ?
                     Intra_H >= Target :
                     Intra_L <= Target
                if Stop_Hit and Target_Hit
                    Exit_Result := 2
                    break
                else if Stop_Hit
                    Exit_Result := -1
                    break
                else
                    Current_R = Is_Buy ?
                         (Intra_H - Entry) / Risk :
                         (Entry - Intra_L) / Risk
                    Current_R_Int = int(math.floor(math.max(Current_R, 0)))
                    Max_R_Bar := math.max(Max_R_Bar, math.min(Current_R_Int, RR_Limit))
                    if Target_Hit
                        Exit_Result := 1
                        Max_R_Bar   := RR_Limit
                        break
        else
            Stop_Hit = Is_Buy ?
                 low <= Stop :
                 high >= Stop
            Target_Hit = Is_Buy ?
                 high >= Target :
                 low <= Target
            if Stop_Hit and Target_Hit
                Exit_Result := 2
            else if Stop_Hit
                Exit_Result := -1
            else
                Current_R = Is_Buy ?
                     (high - Entry) / Risk :
                     (Entry - low) / Risk
                Current_R_Int = int(math.floor(math.max(Current_R, 0)))
                Max_R_Bar := math.max(Max_R_Bar, math.min(Current_R_Int, RR_Limit))
                if Target_Hit
                    Exit_Result := 1
                    Max_R_Bar   := RR_Limit
    [Exit_Result, Max_R_Bar]
RewardRiskPlot(bool Trigger, bool Force_Close, bool Is_Buy, float Entry, float Stop, int RR, int Entry_Intrabar_Index) =>
    var string RR_Status = 'Deactive'
    var int RR_Bar         = na
    var int RR_Entry_Index = -1
    var float RR_Entry  = na
    var float RR_Stop   = na
    var float RR_Risk   = na
    var float RR_Target = na
    var int RR_Limit       = 0
    var int RR_Max_Reached = 0
    var line Entry_Line  = na
    var line Stop_Line   = na
    var line Target_Line = na
    var linefill Reward_Fill = na
    var linefill Risk_Fill   = na
    var Reward_Lines = array.new_line()
    Reward_Color = #7ED6A5
    Risk_Color = #FF8F9C
    Neutral_Color = #A8B3C7
    Entry_Color = #747A82
    varip int RR_RT_Bar       = na
    varip int RR_RT_Trade_Bar = na
    varip int RR_RT_Exit      = 0
    varip int RR_RT_Max_R     = 0
    varip bool RR_RT_Force_Close = false
    if na(RR_RT_Bar) or RR_RT_Bar != bar_index
        RR_RT_Bar         := bar_index
        RR_RT_Exit        := 0
        RR_RT_Max_R       := 0
        RR_RT_Force_Close := false
    if Trigger and RR_RT_Trade_Bar != bar_index
        RR_RT_Trade_Bar   := bar_index
        RR_RT_Exit        := 0
        RR_RT_Max_R       := 0
        RR_RT_Force_Close := false
    if barstate.isrealtime and Force_Close and RR_Status == 'Active'
        RR_RT_Force_Close := true
    if Trigger
        if Delete_Previous_RR
            if not na(Reward_Fill)
                linefill.delete(Reward_Fill)
            if not na(Risk_Fill)
                linefill.delete(Risk_Fill)
            if not na(Entry_Line)
                line.delete(Entry_Line)
            if not na(Stop_Line)
                line.delete(Stop_Line)
            if not na(Target_Line)
                line.delete(Target_Line)
            if array.size(Reward_Lines) > 0
                for i = 0 to array.size(Reward_Lines) - 1
                    line.delete(array.get(Reward_Lines, i))
        array.clear(Reward_Lines)
        RR_Status      := 'Active'
        RR_Bar         := bar_index
        RR_Entry_Index := Entry_Intrabar_Index
        RR_Entry := Entry
        RR_Stop  := Stop
        RR_Risk := math.abs(RR_Entry - RR_Stop)
        RR_Limit := RR
        RR_Max_Reached := 0
        RR_Target := Is_Buy ?
             RR_Entry + (RR_Risk * RR_Limit) :
             RR_Entry - (RR_Risk * RR_Limit)
        Right_Bar = RR_Bar + 5
        Entry_Line := line.new(RR_Bar, RR_Entry, Right_Bar, RR_Entry, color = Entry_Color, style = line.style_solid, width = 2)
        Stop_Line := line.new(RR_Bar, RR_Stop, Right_Bar, RR_Stop, color = Risk_Color, width = 1)
        Target_Line := line.new(RR_Bar, RR_Target, Right_Bar, RR_Target, color = Reward_Color, width = 1)
        Reward_Fill := linefill.new(Entry_Line, Target_Line, color.new(Reward_Color, 84))
        Risk_Fill := linefill.new(Entry_Line, Stop_Line, color.new(Risk_Color, 84))
        for i = 1 to RR_Limit
            Reward_Price = Is_Buy ?
                 RR_Entry + (RR_Risk * i) :
                 RR_Entry - (RR_Risk * i)
            Reward_Line_Color = i == RR_Limit ? Reward_Color : color.new(Neutral_Color, 35)
            Reward_Line_Style = i == RR_Limit ? line.style_solid : line.style_dotted
            Reward_Line = line.new(RR_Bar, Reward_Price, Right_Bar, Reward_Price, color = Reward_Line_Color, style = Reward_Line_Style, width = 1)
            array.push(Reward_Lines, Reward_Line)
    if RR_Status == 'Active' and RR_Risk > 0
        Right_Bar = math.max(RR_Bar + 5, bar_index + 1)
        line.set_x2(Entry_Line , Right_Bar)
        line.set_x2(Stop_Line  , Right_Bar)
        line.set_x2(Target_Line, Right_Bar)
        if array.size(Reward_Lines) > 0
            for i = 0 to array.size(Reward_Lines) - 1
                Reward_Line = array.get(Reward_Lines, i)
                line.set_x2(Reward_Line, Right_Bar)
        int Exit_Result = 0
        int Max_R_Bar   = 0
        if barstate.isrealtime
            Current_R_Tick = Is_Buy ?
                 (close - RR_Entry) / RR_Risk :
                 (RR_Entry - close) / RR_Risk
            Current_R_Tick_Int = int(math.floor(math.max(Current_R_Tick, 0)))
            RR_RT_Max_R := math.max(RR_RT_Max_R, math.min(Current_R_Tick_Int, RR_Limit))
            if RR_RT_Exit == 0
                Stop_Touched_Now = Is_Buy ?
                     low <= RR_Stop :
                     high >= RR_Stop
                Target_Touched_Now = Is_Buy ?
                     high >= RR_Target :
                     low <= RR_Target
                if Stop_Touched_Now and Target_Touched_Now
                    RR_RT_Exit := 2
                else if Stop_Touched_Now
                    RR_RT_Exit := -1
                else if Target_Touched_Now
                    RR_RT_Exit  := 1
                    RR_RT_Max_R := RR_Limit
            Exit_Result := RR_RT_Force_Close ? 3 : RR_RT_Exit
            Max_R_Bar   := RR_RT_Max_R
        else
            [Historical_Exit_Result, Historical_Max_R_Bar] = TradeBarResolver(Is_Buy, RR_Entry, RR_Stop, RR_Target, RR_Risk, RR_Limit, bar_index == RR_Bar, RR_Entry_Index)
            Exit_Result := Force_Close ? 3 : Historical_Exit_Result
            Max_R_Bar   := Historical_Max_R_Bar
        RR_Max_Reached := math.max(RR_Max_Reached, Max_R_Bar)
        if Exit_Result == 0 and bar_index - RR_Bar >= Position_Expiration
            Exit_Result := 4
        if Exit_Result != 0
            Final_Right_Bar = math.max(RR_Bar + 5, bar_index)
            line.set_x2(Entry_Line , Final_Right_Bar)
            line.set_x2(Stop_Line  , Final_Right_Bar)
            line.set_x2(Target_Line, Final_Right_Bar)
            if array.size(Reward_Lines) > 0
                for i = 0 to array.size(Reward_Lines) - 1
                    Reward_Line = array.get(Reward_Lines, i)
                    line.set_x2(Reward_Line, Final_Right_Bar)
            if Exit_Result == -1
                RR_Status := 'Stop-Loss'
            else if Exit_Result == 1
                RR_Status := 'Take-Profit'
                RR_Max_Reached := RR_Limit
            else if Exit_Result == 2
                RR_Status := 'Ambiguous'
            else if Exit_Result == 3
                RR_Status := 'Opposite-Entry Close'
            else if Exit_Result == 4
                RR_Status := 'Position-Expired'
    [RR_Status, RR_Max_Reached]
High_Pivot = not na(ta.pivothigh(3, 2)) and barstate.isconfirmed
Low_Pivot  = not na(ta.pivotlow(3, 2)) and barstate.isconfirmed
ATR = ta.atr(34)
Bull_Bar = close > open
Bear_Bar = close < open
BodytoShadow = (math.abs(close - open) / (high - low)) * 100
var int LP_Bar = 0  , var float LP_Price = 0.0, var float LP_ATR = 0.0
var int HP_Bar = 0  , var float HP_Price = 0.0, var float HP_ATR = 0.0
var int   Buy_Bar_Origin        = 0   , var int   Buy_Bar_Destination    = 0
var float Buy_Price_Origin      = 0.0 , var float Buy_Price_Destination  = 0.0
var int   Sell_Bar_Origin       = 0   , var int   Sell_Bar_Destination   = 0
var float Sell_Price_Origin     = 0.0 , var float Sell_Price_Destination = 0.0
var string Buy_Status  = 'Deactive'
var string Sell_Status = 'Deactive'
varip string Buy_Terminal_Status  = ''
varip string Sell_Terminal_Status = ''
var string Priority = ''
if Buy_Terminal_Status == 'Loss'
    Buy_Status := 'Loss'
if Sell_Terminal_Status == 'Loss'
    Sell_Status := 'Loss'
if Low_Pivot
    LP_Bar   := bar_index[2]
    LP_Price := low[2]
    LP_ATR   := ATR
if High_Pivot
    HP_Bar   := bar_index[2]
    HP_Price := high[2]
    HP_ATR   := ATR
if low < LP_Price
    LP_Bar   := bar_index
    LP_Price := low
if high > HP_Price
    HP_Bar   := bar_index
    HP_Price := high
First_Buy_Cond =
     bar_index - LP_Bar >= 4 and
     (close - LP_Price) / (bar_index - LP_Bar) >= LP_ATR * 1.35
First_Sell_Cond =
     bar_index - HP_Bar >= 4 and
     (HP_Price - close) / (bar_index - HP_Bar) >= HP_ATR * 1.35
if First_Buy_Cond and (Buy_Status == 'Deactive' or Buy_Status == 'Loss')
    Buy_Bar_Origin        := LP_Bar
    Buy_Price_Origin      := LP_Price
    Buy_Bar_Destination   := bar_index
    Buy_Price_Destination := high
    for i = 0 to (bar_index - LP_Bar) by 1
        if Buy_Price_Destination < high[i + 1]
            Buy_Bar_Destination   := bar_index[i + 1]
            Buy_Price_Destination := high[i + 1]
    Buy_Terminal_Status := ''
    Buy_Status := 'Active'
if First_Sell_Cond and (Sell_Status == 'Deactive' or Sell_Status == 'Loss')
    Sell_Bar_Origin        := HP_Bar
    Sell_Price_Origin      := HP_Price
    Sell_Bar_Destination   := bar_index
    Sell_Price_Destination := low
    for i = 0 to (bar_index - HP_Bar) by 1
        if Sell_Price_Destination > low[i + 1]
            Sell_Bar_Destination   := bar_index[i + 1]
            Sell_Price_Destination := low[i + 1]
    Sell_Terminal_Status := ''
    Sell_Status := 'Active'
if Buy_Status == 'Active'
    if high > Buy_Price_Destination
        Buy_Bar_Destination   := bar_index
        Buy_Price_Destination := high
if Sell_Status == 'Active'
    if low < Sell_Price_Destination
        Sell_Bar_Destination   := bar_index
        Sell_Price_Destination := low
varip string Buy_Entry_Status  = 'Deactive'
varip string Sell_Entry_Status = 'Deactive'
varip bool Buy_Position_Open  = false
varip bool Sell_Position_Open = false
varip int Buy_Position_Bar  = na
varip int Sell_Position_Bar = na
varip float Buy_Position_Entry   = na
varip float Buy_Position_Stop    = na
varip float Buy_Position_Target  = na
varip float Sell_Position_Entry  = na
varip float Sell_Position_Stop   = na
varip float Sell_Position_Target = na
if Buy_Position_Open and not na(Buy_Position_Stop) and not na(Buy_Position_Target)
    Buy_Position_Resolved = false
    if barstate.isrealtime and bar_index == Buy_Position_Bar
        Buy_Position_Resolved :=
             low <= Buy_Position_Stop or
             high >= Buy_Position_Target
    else if bar_index > Buy_Position_Bar
        Buy_Position_Resolved :=
             low <= Buy_Position_Stop or
             high >= Buy_Position_Target
    if Buy_Position_Resolved
        Buy_Position_Open := false
if Sell_Position_Open and not na(Sell_Position_Stop) and not na(Sell_Position_Target)
    Sell_Position_Resolved = false
    if barstate.isrealtime and bar_index == Sell_Position_Bar
        Sell_Position_Resolved :=
             high >= Sell_Position_Stop or
             low <= Sell_Position_Target
    else if bar_index > Sell_Position_Bar
        Sell_Position_Resolved :=
             high >= Sell_Position_Stop or
             low <= Sell_Position_Target
    if Sell_Position_Resolved
        Sell_Position_Open := false
Buy_Position_Open_Before  = Buy_Position_Open
Sell_Position_Open_Before = Sell_Position_Open
varip float Buy_Entry_Price  = na
varip float Sell_Entry_Price = na
varip int Buy_Entry_Last_Extension_Bar  = na
varip int Sell_Entry_Last_Extension_Bar = na
var line Buy_Entry_Line  = na
var line Sell_Entry_Line = na
bool Buy_Trade_Trigger  = false
bool Sell_Trade_Trigger = false
float Buy_Trade_Entry  = na
float Sell_Trade_Entry = na
int Buy_Trade_Entry_Index  = -1
int Sell_Trade_Entry_Index = -1
New_Buy_Setup =
     Buy_Status == 'Active' and
     Buy_Status[1] != 'Active'
New_Sell_Setup =
     Sell_Status == 'Active' and
     Sell_Status[1] != 'Active'
Buy_Fibo_Extended =
     Buy_Status == 'Active' and
     (Buy_Bar_Destination != Buy_Bar_Destination[1] or Buy_Price_Destination != Buy_Price_Destination[1])
Sell_Fibo_Extended =
     Sell_Status == 'Active' and
     (Sell_Bar_Destination != Sell_Bar_Destination[1] or Sell_Price_Destination != Sell_Price_Destination[1])
varip int Realtime_Bar = na
varip bool Buy_RT_Entry_Latched  = false
varip bool Sell_RT_Entry_Latched = false
varip float Buy_RT_Entry_Price  = na
varip float Sell_RT_Entry_Price = na
varip float Buy_RT_ATR_SL  = na
varip float Sell_RT_ATR_SL = na
varip int Buy_RT_Setup_Bar  = na
varip int Sell_RT_Setup_Bar = na
if na(Realtime_Bar) or Realtime_Bar != bar_index
    Realtime_Bar := bar_index
    Buy_RT_Entry_Latched  := false
    Sell_RT_Entry_Latched := false
    Buy_RT_Entry_Price  := na
    Sell_RT_Entry_Price := na
    Buy_RT_ATR_SL  := na
    Sell_RT_ATR_SL := na
if New_Buy_Setup and (not barstate.isrealtime or Buy_RT_Setup_Bar != bar_index)
    Buy_RT_Setup_Bar := bar_index
    Buy_Entry_Status := 'Pending'
    Buy_Entry_Price := FibonacciEntry(Buy_Price_Destination, Buy_Price_Origin, Entry_Fib_Coe)
    Buy_Entry_Last_Extension_Bar := bar_index
    if not na(Buy_Entry_Line)
        line.delete(Buy_Entry_Line)
    Buy_Entry_Line := line.new(Buy_Bar_Destination, Buy_Entry_Price, bar_index + 1, Buy_Entry_Price, color = #747A82, style = line.style_solid, width = 2)
else if Buy_Entry_Status == 'Pending'
    if na(Buy_Entry_Line)
        Buy_Entry_Line := line.new(Buy_Bar_Destination, Buy_Entry_Price, bar_index + 1, Buy_Entry_Price, color = #747A82, style = line.style_solid, width = 2)
    int Buy_Entry_Result = 0
    float Buy_Resolved_Entry = na
    int Buy_Resolved_Index = -1
    if barstate.isrealtime
        if Buy_Fibo_Extended
            Buy_Entry_Price := FibonacciEntry(Buy_Price_Destination, Buy_Price_Origin, Entry_Fib_Coe)
            Buy_Entry_Last_Extension_Bar := bar_index
            line.set_xy1(Buy_Entry_Line, Buy_Bar_Destination, Buy_Entry_Price)
            line.set_y2(Buy_Entry_Line, Buy_Entry_Price)
        if not Buy_RT_Entry_Latched and low <= Buy_Entry_Price
            Buy_RT_Entry_Latched := true
            Buy_RT_Entry_Price   := Buy_Entry_Price
            Buy_RT_ATR_SL        := ATR_SL
        if Buy_RT_Entry_Latched
            Buy_Entry_Result   := 1
            Buy_Resolved_Entry := Buy_RT_Entry_Price
    else
        [Buy_Historical_Result, Buy_Historical_Entry, Buy_Historical_Index] = HistoricalEntryResolver(true, Buy_Price_Destination[1], Buy_Price_Destination, Buy_Price_Origin, Entry_Fib_Coe)
        Buy_Entry_Result   := Buy_Historical_Result
        Buy_Resolved_Entry := Buy_Historical_Entry
        Buy_Resolved_Index := Buy_Historical_Index
        if Buy_Entry_Result == 0 and Buy_Fibo_Extended
            Buy_Entry_Price := FibonacciEntry(Buy_Price_Destination, Buy_Price_Origin, Entry_Fib_Coe)
            Buy_Entry_Last_Extension_Bar := bar_index
            line.set_xy1(Buy_Entry_Line, Buy_Bar_Destination, Buy_Entry_Price)
            line.set_y2(Buy_Entry_Line, Buy_Entry_Price)
    line.set_x2(Buy_Entry_Line, bar_index + 1)
    if Buy_Entry_Result == 1
        Buy_Entry_Stop_ATR = barstate.isrealtime and Buy_RT_Entry_Latched and not na(Buy_RT_ATR_SL) ?
             Buy_RT_ATR_SL :
             ATR_SL
        Buy_Entry_Stop =
             Buy_Price_Origin -
             (Buy_Entry_Stop_ATR * SL_ATR_Threshold)
        Buy_Stop_Distance_Allowed =
             math.abs(Buy_Resolved_Entry - Buy_Entry_Stop) <=
             (Buy_Entry_Stop_ATR * 10)
        Buy_Position_Allowed =
             Buy_Stop_Distance_Allowed and
             (not Block_Same_Type_Position or not Buy_Position_Open)
        if Buy_Position_Allowed
            Buy_Entry_Status := 'Triggered'
            Buy_Trade_Trigger := true
            Buy_Trade_Entry := Buy_Resolved_Entry
            Buy_Trade_Entry_Index := Buy_Resolved_Index
            Buy_Position_Open := true
        else
            Buy_Entry_Status := 'Blocked'
            Buy_RT_Entry_Latched := false
        if not na(Buy_Entry_Line)
            line.delete(Buy_Entry_Line)
            Buy_Entry_Line := na
    else if Buy_Entry_Result == -1
        Buy_Entry_Status := 'Ambiguous'
        line.set_x2(Buy_Entry_Line, bar_index)
        line.set_color(Buy_Entry_Line, #ff9800)
    else if bar_index - Buy_Entry_Last_Extension_Bar >= Entry_Expiration
        Buy_Entry_Status := 'Expired'
        line.set_x2(Buy_Entry_Line, bar_index)
        line.set_color(Buy_Entry_Line, color.new(#787b86, 55))
if New_Sell_Setup and (not barstate.isrealtime or Sell_RT_Setup_Bar != bar_index)
    Sell_RT_Setup_Bar := bar_index
    Sell_Entry_Status := 'Pending'
    Sell_Entry_Price := FibonacciEntry(Sell_Price_Destination, Sell_Price_Origin, Entry_Fib_Coe)
    Sell_Entry_Last_Extension_Bar := bar_index
    if not na(Sell_Entry_Line)
        line.delete(Sell_Entry_Line)
    Sell_Entry_Line := line.new(Sell_Bar_Destination, Sell_Entry_Price, bar_index + 1, Sell_Entry_Price, color = #747A82, style = line.style_solid, width = 2)
else if Sell_Entry_Status == 'Pending'
    if na(Sell_Entry_Line)
        Sell_Entry_Line := line.new(Sell_Bar_Destination, Sell_Entry_Price, bar_index + 1, Sell_Entry_Price, color = #747A82, style = line.style_solid, width = 2)
    int Sell_Entry_Result = 0
    float Sell_Resolved_Entry = na
    int Sell_Resolved_Index = -1
    if barstate.isrealtime
        if Sell_Fibo_Extended
            Sell_Entry_Price := FibonacciEntry(Sell_Price_Destination, Sell_Price_Origin, Entry_Fib_Coe)
            Sell_Entry_Last_Extension_Bar := bar_index
            line.set_xy1(Sell_Entry_Line, Sell_Bar_Destination, Sell_Entry_Price)
            line.set_y2(Sell_Entry_Line, Sell_Entry_Price)
        if not Sell_RT_Entry_Latched and high >= Sell_Entry_Price
            Sell_RT_Entry_Latched := true
            Sell_RT_Entry_Price   := Sell_Entry_Price
            Sell_RT_ATR_SL        := ATR_SL
        if Sell_RT_Entry_Latched
            Sell_Entry_Result   := 1
            Sell_Resolved_Entry := Sell_RT_Entry_Price
    else
        [Sell_Historical_Result, Sell_Historical_Entry, Sell_Historical_Index] = HistoricalEntryResolver(false, Sell_Price_Destination[1], Sell_Price_Destination, Sell_Price_Origin, Entry_Fib_Coe)
        Sell_Entry_Result   := Sell_Historical_Result
        Sell_Resolved_Entry := Sell_Historical_Entry
        Sell_Resolved_Index := Sell_Historical_Index
        if Sell_Entry_Result == 0 and Sell_Fibo_Extended
            Sell_Entry_Price := FibonacciEntry(Sell_Price_Destination, Sell_Price_Origin, Entry_Fib_Coe)
            Sell_Entry_Last_Extension_Bar := bar_index
            line.set_xy1(Sell_Entry_Line, Sell_Bar_Destination, Sell_Entry_Price)
            line.set_y2(Sell_Entry_Line, Sell_Entry_Price)
    line.set_x2(Sell_Entry_Line, bar_index + 1)
    if Sell_Entry_Result == 1
        Sell_Entry_Stop_ATR = barstate.isrealtime and Sell_RT_Entry_Latched and not na(Sell_RT_ATR_SL) ?
             Sell_RT_ATR_SL :
             ATR_SL
        Sell_Entry_Stop =
             Sell_Price_Origin +
             (Sell_Entry_Stop_ATR * SL_ATR_Threshold)
        Sell_Stop_Distance_Allowed =
             math.abs(Sell_Resolved_Entry - Sell_Entry_Stop) <=
             (Sell_Entry_Stop_ATR * 10)
        Sell_Position_Allowed =
             Sell_Stop_Distance_Allowed and
             (not Block_Same_Type_Position or not Sell_Position_Open)
        if Sell_Position_Allowed
            Sell_Entry_Status := 'Triggered'
            Sell_Trade_Trigger := true
            Sell_Trade_Entry := Sell_Resolved_Entry
            Sell_Trade_Entry_Index := Sell_Resolved_Index
            Sell_Position_Open := true
        else
            Sell_Entry_Status := 'Blocked'
            Sell_RT_Entry_Latched := false
        if not na(Sell_Entry_Line)
            line.delete(Sell_Entry_Line)
            Sell_Entry_Line := na
    else if Sell_Entry_Result == -1
        Sell_Entry_Status := 'Ambiguous'
        line.set_x2(Sell_Entry_Line, bar_index)
        line.set_color(Sell_Entry_Line, #ff9800)
    else if bar_index - Sell_Entry_Last_Extension_Bar >= Entry_Expiration
        Sell_Entry_Status := 'Expired'
        line.set_x2(Sell_Entry_Line, bar_index)
        line.set_color(Sell_Entry_Line, color.new(#787b86, 55))
if barstate.isrealtime
    Buy_Trade_Trigger :=
         Buy_Trade_Trigger or
         (Buy_RT_Entry_Latched and Buy_Entry_Status == 'Triggered')
    Sell_Trade_Trigger :=
         Sell_Trade_Trigger or
         (Sell_RT_Entry_Latched and Sell_Entry_Status == 'Triggered')
    if Buy_RT_Entry_Latched and Buy_Entry_Status == 'Triggered'
        Buy_Trade_Entry := Buy_RT_Entry_Price
    if Sell_RT_Entry_Latched and Sell_Entry_Status == 'Triggered'
        Sell_Trade_Entry := Sell_RT_Entry_Price
if Buy_Entry_Status == 'Triggered' and not na(Buy_Entry_Line)
    line.delete(Buy_Entry_Line)
    Buy_Entry_Line := na
if Sell_Entry_Status == 'Triggered' and not na(Sell_Entry_Line)
    line.delete(Sell_Entry_Line)
    Sell_Entry_Line := na
Buy_Stop_ATR = barstate.isrealtime and Buy_RT_Entry_Latched and not na(Buy_RT_ATR_SL) ?
     Buy_RT_ATR_SL :
     ATR_SL
Sell_Stop_ATR = barstate.isrealtime and Sell_RT_Entry_Latched and not na(Sell_RT_ATR_SL) ?
     Sell_RT_ATR_SL :
     ATR_SL
Buy_Stop_Loss = Buy_Trade_Trigger ?
     Buy_Price_Origin - (Buy_Stop_ATR * SL_ATR_Threshold) :
     na
Sell_Stop_Loss = Sell_Trade_Trigger ?
     Sell_Price_Origin + (Sell_Stop_ATR * SL_ATR_Threshold) :
     na
if Buy_Trade_Trigger
    Buy_Position_Bar   := bar_index
    Buy_Position_Entry := Buy_Trade_Entry
    Buy_Position_Stop  := Buy_Stop_Loss
    Buy_Position_Target :=
         Buy_Position_Entry +
         (math.abs(Buy_Position_Entry - Buy_Position_Stop) * Reward_Risk)
if Sell_Trade_Trigger
    Sell_Position_Bar   := bar_index
    Sell_Position_Entry := Sell_Trade_Entry
    Sell_Position_Stop  := Sell_Stop_Loss
    Sell_Position_Target :=
         Sell_Position_Entry -
         (math.abs(Sell_Position_Entry - Sell_Position_Stop) * Reward_Risk)
Buy_Force_Close =
     Close_Opposite_Position and
     Sell_Trade_Trigger and
     Buy_Position_Open_Before
Sell_Force_Close =
     Close_Opposite_Position and
     Buy_Trade_Trigger and
     Sell_Position_Open_Before
[Buy_RR_Status, Buy_Max_R] = RewardRiskPlot(Buy_Trade_Trigger, Buy_Force_Close, true, Buy_Trade_Entry, Buy_Stop_Loss, Reward_Risk, Buy_Trade_Entry_Index)
[Sell_RR_Status, Sell_Max_R] = RewardRiskPlot(Sell_Trade_Trigger, Sell_Force_Close, false, Sell_Trade_Entry, Sell_Stop_Loss, Reward_Risk, Sell_Trade_Entry_Index)
varip int Alert_Bar = na
varip bool Buy_Pending_Alert_Sent = false
varip bool Sell_Pending_Alert_Sent = false
varip bool Buy_Entry_Alert_Sent = false
varip bool Sell_Entry_Alert_Sent = false
varip bool Buy_Exit_Alert_Sent = false
varip bool Sell_Exit_Alert_Sent = false
if na(Alert_Bar) or Alert_Bar != bar_index
    Alert_Bar := bar_index
    Buy_Pending_Alert_Sent := false
    Sell_Pending_Alert_Sent := false
    Buy_Entry_Alert_Sent := false
    Sell_Entry_Alert_Sent := false
    Buy_Exit_Alert_Sent := false
    Sell_Exit_Alert_Sent := false
Buy_Pending_Alert = New_Buy_Setup and Buy_Entry_Status == 'Pending'
Sell_Pending_Alert = New_Sell_Setup and Sell_Entry_Status == 'Pending'
Buy_Entry_Alert = Buy_Trade_Trigger and Buy_Entry_Status == 'Triggered'
Sell_Entry_Alert = Sell_Trade_Trigger and Sell_Entry_Status == 'Triggered'
Buy_Exit_Alert = (Buy_Position_Open_Before or Buy_Trade_Trigger) and Buy_RR_Status != 'Active' and Buy_RR_Status != 'Deactive'
Sell_Exit_Alert = (Sell_Position_Open_Before or Sell_Trade_Trigger) and Sell_RR_Status != 'Active' and Sell_RR_Status != 'Deactive'
if Buy_Pending_Alert and not Buy_Pending_Alert_Sent
    alert('ICT Pullback Setup | ' + syminfo.ticker + ' | ' + timeframe.period + ' | BUY PENDING | Fib: ' + Entry_Fib + ' | Entry: ' + str.tostring(Buy_Entry_Price, format.mintick), alert.freq_all)
    Buy_Pending_Alert_Sent := true
if Sell_Pending_Alert and not Sell_Pending_Alert_Sent
    alert('ICT Pullback Setup | ' + syminfo.ticker + ' | ' + timeframe.period + ' | SELL PENDING | Fib: ' + Entry_Fib + ' | Entry: ' + str.tostring(Sell_Entry_Price, format.mintick), alert.freq_all)
    Sell_Pending_Alert_Sent := true
if Buy_Entry_Alert and not Buy_Entry_Alert_Sent
    alert('ICT Pullback Setup | ' + syminfo.ticker + ' | ' + timeframe.period + ' | BUY ENTRY | Entry: ' + str.tostring(Buy_Trade_Entry, format.mintick) + ' | SL: ' + str.tostring(Buy_Stop_Loss, format.mintick) + ' | TP: ' + str.tostring(Buy_Position_Target, format.mintick), alert.freq_all)
    Buy_Entry_Alert_Sent := true
if Sell_Entry_Alert and not Sell_Entry_Alert_Sent
    alert('ICT Pullback Setup | ' + syminfo.ticker + ' | ' + timeframe.period + ' | SELL ENTRY | Entry: ' + str.tostring(Sell_Trade_Entry, format.mintick) + ' | SL: ' + str.tostring(Sell_Stop_Loss, format.mintick) + ' | TP: ' + str.tostring(Sell_Position_Target, format.mintick), alert.freq_all)
    Sell_Entry_Alert_Sent := true
if Buy_Exit_Alert and not Buy_Exit_Alert_Sent
    alert('ICT Pullback Setup | ' + syminfo.ticker + ' | ' + timeframe.period + ' | BUY EXIT | Reason: ' + Buy_RR_Status + ' | Max R: ' + str.tostring(Buy_Max_R), alert.freq_all)
    Buy_Exit_Alert_Sent := true
if Sell_Exit_Alert and not Sell_Exit_Alert_Sent
    alert('ICT Pullback Setup | ' + syminfo.ticker + ' | ' + timeframe.period + ' | SELL EXIT | Reason: ' + Sell_RR_Status + ' | Max R: ' + str.tostring(Sell_Max_R), alert.freq_all)
    Sell_Exit_Alert_Sent := true
Buy_Position_Open  := Buy_RR_Status  == 'Active'
Sell_Position_Open := Sell_RR_Status == 'Active'
if not Buy_Position_Open
    Buy_Position_Bar    := na
    Buy_Position_Entry  := na
    Buy_Position_Stop   := na
    Buy_Position_Target := na
if not Sell_Position_Open
    Sell_Position_Bar    := na
    Sell_Position_Entry  := na
    Sell_Position_Stop   := na
    Sell_Position_Target := na
if bar_index - Buy_Bar_Origin >= 50
    Buy_Status := 'Deactive'
if bar_index - Sell_Bar_Origin >= 50
    Sell_Status := 'Deactive'
if Buy_RR_Status == 'Stop-Loss' and Buy_Entry_Status == 'Triggered'
    Buy_Status          := 'Loss'
    Buy_Terminal_Status := 'Loss'
if Sell_RR_Status == 'Stop-Loss' and Sell_Entry_Status == 'Triggered'
    Sell_Status          := 'Loss'
    Sell_Terminal_Status := 'Loss'
if Buy_Status == 'Active' and Sell_Status == 'Active'
    if Buy_Bar_Origin < Sell_Bar_Origin
        Priority := 'Buy Setup'
    else
        Priority := 'Sell Setup'
else if Buy_Status == 'Active'
    Priority := 'Buy Setup'
else
    Priority := 'Sell Setup'
FibonacciPlot(Buy_Price_Destination, Buy_Price_Origin, Buy_Bar_Origin, Buy_Bar_Destination, 0.85, Buy_Entry_Status != 'Triggered' and Buy_Entry_Status != 'Blocked')
FibonacciPlot(Sell_Price_Destination, Sell_Price_Origin, Sell_Bar_Origin, Sell_Bar_Destination, 0.85, Sell_Entry_Status != 'Triggered' and Sell_Entry_Status != 'Blocked')
Fibo_Tracing(Bar_Origin, Price_Origin, Bar_Destination, Price_Destination, Custom_Coe) =>
    var Fibo_Lines = array.new_line()
    [Fibo_Lvl] = Fibonacci(Price_Origin, Price_Destination, Custom_Coe)
````
