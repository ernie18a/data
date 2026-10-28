Calculation: Compression percentage = (highest of the short-, medium-, and long-lookback close SMAs − lowest of those SMAs) / close × 100
Calculation: Price-to-average percentage = absolute(close − mean of the short-, medium-, and long-lookback close SMAs) / close × 100
Calculation: Short-MA flatness = mean of (standard deviation of each of the short- and medium-lookback SMAs over a shorter lookback / mean of that SMA over the same lookback × 100)
Calculation: Long-MA flatness = standard deviation of the long-lookback SMA over a longer lookback / mean of that SMA over the same lookback × 100
Calculation: Volume ratio = volume / moving average of volume
Calculation: ATR change percentage = (current ATR − ATR from a prior lookback) / ATR from that prior lookback × 100
Calculation: Compression score = max(0, compression-score weight × (1 − compression percentage / compression threshold))
Calculation: Proximity score = max(0, proximity-score weight × (1 − price-to-average percentage / proximity threshold))
Calculation: Short-MA flatness score = max(0, short-flatness-score weight × (1 − short-MA flatness / short-flatness threshold))
Calculation: Long-MA flatness score = max(0, long-flatness-score weight × (1 − long-MA flatness / long-flatness threshold))
Calculation: Volume score = volume-below-average ? volume-score weight : max(0, volume-score weight × (1 − (volume ratio − 1) / volume scaling factor))
Calculation: ATR score = ATR change percentage < 0 ? ATR-score weight : max(0, ATR-score weight × (1 + ATR change percentage / ATR scaling factor))
Calculation: Launchpad active = at least four of these six comparisons are true: compression percentage < compression threshold; price-to-average percentage < proximity threshold; short-MA flatness < short-flatness threshold; long-MA flatness < long-flatness threshold; volume < its moving average; ATR change percentage < 0; AND the sum of the six scores ≥ minimum score
Calculation: Consecutive active-bar count = number of consecutive completed bars for which launchpad active was true
Long: launchpad active AND launchpad active was false on the previous bar OR previous bar's consecutive active-bar count ≥ minimum compression duration AND close > the previous bar's highest short-, medium-, and long-lookback close SMA AND volume ≥ previous bar's volume moving average × activation volume multiple