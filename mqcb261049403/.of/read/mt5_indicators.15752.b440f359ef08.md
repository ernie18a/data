Calculation: RSI oscillator = short-period moving average of RSI of the selected price minus a longer-period moving average of that short-period moving average; both use the same smoothing method and smoothing parameter.
Calculation: Signal = moving average of the RSI oscillator, using a separately selected smoothing method and parameters.
Long: chart-timeframe RSI oscillator > 0 AND chart-timeframe RSI oscillator != its previous-bar value
Short: chart-timeframe RSI oscillator < 0 AND chart-timeframe RSI oscillator != its previous-bar value
Long: chart-timeframe RSI oscillator > previous-bar signal
Short: chart-timeframe RSI oscillator < previous-bar signal
Long: higher-timeframe forming-bar RSI oscillator > 0 AND higher-timeframe forming-bar RSI oscillator != previous higher-timeframe bar's RSI oscillator AND (chart bar is the first in the higher-timeframe bar OR repeat-display option is enabled)
Short: higher-timeframe forming-bar RSI oscillator < 0 AND higher-timeframe forming-bar RSI oscillator != previous higher-timeframe bar's RSI oscillator AND (chart bar is the first in the higher-timeframe bar OR repeat-display option is enabled)
Long: higher-timeframe forming-bar RSI oscillator > higher-timeframe forming-bar signal AND (chart bar is the first in the higher-timeframe bar OR repeat-display option is enabled)
Short: higher-timeframe forming-bar RSI oscillator < higher-timeframe forming-bar signal AND (chart bar is the first in the higher-timeframe bar OR repeat-display option is enabled)