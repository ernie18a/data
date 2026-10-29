Calculation: Volume ratio = current volume / moving average of volume over a lookback
Calculation: One-bar return (%) = (current close / previous bar close - 1) × 100
Calculation: Close position = (close - low) / (high - low); use 0.5 when high equals low
Calculation: Near long-term low = close <= lowest low over a lookback × (1 + proximity threshold)
Calculation: Near long-term high = close >= highest high over a lookback × (1 - proximity threshold)
Calculation: Downtrend = close < close from a lookback ago; uptrend = close > close from a lookback ago. The key-position lookback is longer than the trend lookback.
Long: volume ratio >= high-volume threshold AND one-bar return >= negative small-move threshold AND one-bar return <= 0 AND close position >= bullish close-position threshold
Long: volume ratio <= low-volume threshold AND one-bar return >= large-move threshold AND close position >= bullish close-position threshold
Long: downtrend AND near long-term low AND volume ratio <= low-volume threshold AND current volume < previous bar volume AND previous bar volume < volume two bars ago AND one-bar return > negative return cutoff AND close position >= bullish close-position threshold
Long: a stopping-volume condition occurred 1 to sequence-window bars earlier AND one-bar return >= sequence-confirmation threshold AND close > previous bar high AND close position >= bullish close-position threshold AND (near long-term low OR downtrend)
Short: volume ratio >= high-volume threshold AND one-bar return <= small-move threshold AND one-bar return >= 0 AND close position <= bearish close-position threshold
Short: volume ratio <= low-volume threshold AND one-bar return <= negative large-move threshold AND close position <= bearish close-position threshold
Short: downtrend AND one-bar return >= large-move threshold AND volume ratio <= low-volume threshold
Short: an upthrust condition occurred 1 to sequence-window bars earlier AND one-bar return <= negative sequence-confirmation threshold AND close < previous bar low AND close position <= bearish close-position threshold AND (near long-term high OR uptrend)