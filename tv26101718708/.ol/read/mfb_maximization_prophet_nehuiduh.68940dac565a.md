Calculation: Bullish fair value gap = current low > high two bars ago; gap boundary = high two bars ago
Calculation: Bearish fair value gap = current high < low two bars ago; gap boundary = low two bars ago
Calculation: Key highs = previous completed daily high, previous completed weekly high, current-session highs for Asia (18:00–00:00 New York), London (00:00–06:00 New York), and the 09:30–09:45 New York opening range; daily and weekly levels use the last completed higher-timeframe bar, and session levels use chart-timeframe bars
Calculation: Key lows = corresponding previous completed daily and weekly lows, and current-session lows for Asia, London, and the 09:30–09:45 New York opening range
Calculation: Latest confirmed pivot high/low = most recently confirmed swing pivot, using equal lookbacks on both sides
Calculation: Initial stop = bullish gap boundary for a long, bearish gap boundary for a short
Calculation: Initial risk = absolute difference between entry price and initial stop
Calculation: Target = entry price plus the target risk multiple times initial risk for a long, or minus it for a short
Calculation: Trailing stop = when profit reaches the trigger risk multiple, select the recorded same-direction gap boundary nearest the trigger price on the protective side (if none qualify, use the latest recorded boundary); thereafter move the stop to each newer same-direction gap boundary that tightens it
Long: No open trade AND bullish fair value gap AND close > high two bars ago AND (close crosses above any key high OR close crosses above the latest confirmed pivot high)
Short: No open trade AND bearish fair value gap AND close < low two bars ago AND (close crosses below any key low OR close crosses below the latest confirmed pivot low)
Exit: Long, low <= current stop OR high >= target
Exit: Short, high >= current stop OR low <= target