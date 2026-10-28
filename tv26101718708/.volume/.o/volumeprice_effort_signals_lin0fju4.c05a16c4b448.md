Calculation: volume ratio = current volume / simple moving average of volume over the volume lookback, including the current bar
Calculation: bar return (%) = (current close / previous bar close − 1) × 100
Calculation: close position = (close − low) / (high − low), or 0.5 when high equals low
Calculation: near key-position low = current close ≤ lowest low over the key-position lookback × (1 + near-extreme fraction); the key-position lookback is longer than the trend lookback
Calculation: near key-position high = current close ≥ highest high over the key-position lookback × (1 − near-extreme fraction)
Calculation: downtrend = current close < close trend-lookback bars ago
Calculation: uptrend = current close > close trend-lookback bars ago
Long: volume ratio ≥ high-volume multiple AND bar return ≥ −small-move threshold AND bar return ≤ 0 AND close position ≥ bullish close-position threshold
Long: volume ratio ≤ low-volume multiple AND bar return ≥ large-move threshold AND close position ≥ bullish close-position threshold
Long: downtrend AND near key-position low AND volume ratio ≤ low-volume multiple AND current volume < previous-bar volume AND previous-bar volume < volume two bars ago AND bar return > −1% AND close position ≥ 0.6
Long: stopping-volume condition occurred 1 through the sequence-window bars ago AND bar return ≥ sequence-confirmation move AND close > previous-bar high AND close position ≥ bullish close-position threshold AND (near key-position low OR downtrend)
Short: volume ratio ≥ high-volume multiple AND bar return ≥ 0 AND bar return ≤ small-move threshold AND close position ≤ bearish close-position threshold
Short: volume ratio ≤ low-volume multiple AND bar return ≤ −large-move threshold AND close position ≤ bearish close-position threshold
Short: downtrend AND bar return ≥ large-move threshold AND volume ratio ≤ low-volume multiple
Short: upthrust condition occurred 1 through the sequence-window bars ago AND bar return ≤ −sequence-confirmation move AND close < previous-bar low AND close position ≤ bearish close-position threshold AND (near key-position high OR uptrend)