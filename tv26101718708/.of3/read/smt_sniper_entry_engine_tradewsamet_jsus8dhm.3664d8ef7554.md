Calculation: ChartAtr = ATR(chart high, chart low, chart close, ATR length)
Calculation: CompAtr = ATR(comparison high, comparison low, comparison close, ATR length)
Calculation: ChartPriorLow = Lowest(chart low over reference lookback bars before the current bar)
Calculation: ChartPriorHigh = Highest(chart high over reference lookback bars before the current bar)
Calculation: CompPriorLow = Lowest(comparison low over reference lookback bars before the current bar)
Calculation: CompPriorHigh = Highest(comparison high over reference lookback bars before the current bar)
Calculation: ContextPosition(p) = (p - Lowest(chart low over context lookback bars before the current bar)) / (Highest(chart high over context lookback bars before the current bar) - Lowest(chart low over context lookback bars before the current bar))
Calculation: PairCorr = Correlation(ln(chart close / chart close[1]), ln(comparison close / comparison close[1]), correlation length)
Calculation: LowSweepAtr = max((ChartPriorLow - chart low) / ChartAtr, (CompPriorLow - comparison low) / CompAtr)
Calculation: HighSweepAtr = max((chart high - ChartPriorHigh) / ChartAtr, (comparison high - CompPriorHigh) / CompAtr)
Calculation: LowGapAtr = max((chart low - ChartPriorLow) / ChartAtr, (comparison low - CompPriorLow) / CompAtr)
Calculation: HighGapAtr = max((ChartPriorHigh - chart high) / ChartAtr, (CompPriorHigh - comparison high) / CompAtr)
Calculation: BullSniper = base weight * 100 + correlation weight * PairCorr + location weight + gap weight + (full sweep weight if LowSweepAtr >= sweep tier factor * minimum sweep depth, else partial sweep weight)
Calculation: BearSniper = base weight * 100 + correlation weight * PairCorr + location weight + gap weight + (full sweep weight if HighSweepAtr >= sweep tier factor * minimum sweep depth, else partial sweep weight)
Calculation: BullDisp = bar is closed AND chart close > chart open AND chart close - chart open >= body ATR threshold * ChartAtr AND (chart close - chart open) / (chart high - chart low) >= body ratio threshold AND (chart high - max(chart open, chart close)) / (chart high - chart low) <= wick ratio threshold
Calculation: BearDisp = bar is closed AND chart close < chart open AND chart open - chart close >= body ATR threshold * ChartAtr AND (chart open - chart close) / (chart high - chart low) >= body ratio threshold AND (min(chart open, chart close) - chart low) / (chart high - chart low) <= wick ratio threshold
Calculation: BullFvg = chart low > chart high[2]
Calculation: BearFvg = chart high < chart low[2]
Calculation: BullBreak = chart close > Highest(chart high over micro-structure lookback bars before the current bar)
Calculation: BearBreak = chart close < Lowest(chart low over micro-structure lookback bars before the current bar)
Calculation: BullSmt = bar is closed AND exactly one of (chart low < ChartPriorLow, comparison low < CompPriorLow) holds AND ((chart low < ChartPriorLow AND chart close > ChartPriorLow) OR (comparison low < CompPriorLow AND comparison close > CompPriorLow)) AND LowSweepAtr >= minimum sweep depth AND chart close > chart open AND (chart close - chart low) / (chart high - chart low) >= minimum close location AND (chart high - chart low) / ChartAtr >= minimum range AND PairCorr >= minimum correlation AND ContextPosition(chart low) <= bull maximum position AND LowGapAtr >= minimum divergence separation AND BullSniper >= minimum sniper score AND BullSmt = false on each of the previous directional cooldown bars
Calculation: BearSmt = bar is closed AND exactly one of (chart high > ChartPriorHigh, comparison high > CompPriorHigh) holds AND ((chart high > ChartPriorHigh AND chart close < ChartPriorHigh) OR (comparison high > CompPriorHigh AND comparison close < CompPriorHigh)) AND HighSweepAtr >= minimum sweep depth AND chart close < chart open AND (chart close - chart low) / (chart high - chart low) <= 1 - minimum close location AND (chart high - chart low) / ChartAtr >= minimum range AND PairCorr >= minimum correlation AND ContextPosition(chart high) >= bear minimum position AND HighGapAtr >= minimum divergence separation AND BearSniper >= minimum sniper score AND BearSmt = false on each of the previous directional cooldown bars
Calculation: LastSmtBar = most recent bar, up to and including the current bar, on which BullSmt = true or BearSmt = true
Calculation: SetupWindow = bars from LastSmtBar + minimum delay through the current bar
Calculation: EntryRisk = stop multiple * ATR(chart high, chart low, chart close, trade ATR length), evaluated on the entry bar
Calculation: UpSignal = bar is closed AND BullSmt = true on LastSmtBar AND current bar - LastSmtBar >= minimum delay AND current bar - LastSmtBar <= confirmation window AND UpSignal = false on each bar after LastSmtBar and before the current bar AND chart close >= (chart low - invalidation buffer * ChartAtr), both evaluated on LastSmtBar, on every bar after LastSmtBar through the current bar AND BullDisp = true on some bar in SetupWindow AND chart close > chart high evaluated on LastSmtBar on some bar in SetupWindow AND required evidence count <= the number of these that hold: (BullFvg = true on some bar in SetupWindow), (BullBreak = true on some bar in SetupWindow) AND UpSignal = false and DownSignal = false on each of the previous signal cooldown bars
Calculation: DownSignal = bar is closed AND BearSmt = true on LastSmtBar AND current bar - LastSmtBar >= minimum delay AND current bar - LastSmtBar <= confirmation window AND DownSignal = false on each bar after LastSmtBar and before the current bar AND chart close <= (chart high + invalidation buffer * ChartAtr), both evaluated on LastSmtBar, on every bar after LastSmtBar through the current bar AND BearDisp = true on some bar in SetupWindow AND chart close < chart low evaluated on LastSmtBar on some bar in SetupWindow AND required evidence count <= the number of these that hold: (BearFvg = true on some bar in SetupWindow), (BearBreak = true on some bar in SetupWindow) AND UpSignal = false and DownSignal = false on each of the previous signal cooldown bars
Long: BullSmt = true
Long: BullDisp = true
Long: UpSignal = true
Short: BearSmt = true
Short: BearDisp = true
Short: DownSignal = true
Exit: long, bar is closed AND current bar > entry bar AND (chart low <= entry price - EntryRisk OR chart high >= entry price + target multiple * EntryRisk)
Exit: short, bar is closed AND current bar > entry bar AND (chart high >= entry price + EntryRisk OR chart low <= entry price - target multiple * EntryRisk)