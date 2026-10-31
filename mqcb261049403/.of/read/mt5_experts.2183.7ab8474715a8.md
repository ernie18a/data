Calculation: Smoothed stochastic lines = apply the same selected moving-average method, length, and phase independently to the main and signal lines of a slow stochastic oscillator; the stochastic uses a configurable lookback, slowing period, signal period, averaging method, and high/low or close/close price range. Calculate on a configurable indicator timeframe that may be higher or lower than the chart timeframe, using either the last completed indicator bar or the still-forming indicator bar as the selected bar; previous values refer to preceding indicator bars.
Long: breakdown mode AND selected main line > oscillator midpoint AND previous main line <= midpoint
Short: breakdown mode AND selected main line < oscillator midpoint AND previous main line >= midpoint
Exit: short, breakdown mode AND selected main line > oscillator midpoint
Exit: long, breakdown mode AND selected main line < oscillator midpoint
Long: direction-change mode AND selected main line > previous main line AND previous main line < main line two indicator bars earlier
Short: direction-change mode AND selected main line < previous main line AND previous main line > main line two indicator bars earlier
Exit: short, direction-change mode AND selected main line > previous main line
Exit: long, direction-change mode AND selected main line < previous main line
Long: cloud-change mode AND selected main line > selected signal line AND previous main line <= previous signal line
Short: cloud-change mode AND selected main line < selected signal line AND previous main line >= previous signal line
Exit: short, cloud-change mode AND selected main line > selected signal line
Exit: long, cloud-change mode AND selected main line < selected signal line
Exit: long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance
Exit: short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance