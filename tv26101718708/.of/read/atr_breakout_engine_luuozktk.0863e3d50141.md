Calculation: ATR = Average True Range on the chart timeframe or a higher timeframe using its last completed bar, as selected.
Calculation: Selected reference = current session's first bar open, previous session's last bar close, or previous session's high for longs and low for shorts, as selected.
Calculation: Long trigger = selected long reference + distance multiple × ATR.
Calculation: Short trigger = selected short reference − distance multiple × ATR.
Calculation: Low-volatility threshold = nearest-rank percentile of ATR over the configured lookback.
Calculation: Fast and slow ATR = ATRs with shorter and longer lookbacks, respectively.
Calculation: Relative volume = volume ÷ its moving average.
Calculation: Narrow-range bar = current high − low is no greater than the lowest high − low over the configured lookback.
Long: high crosses above the long trigger AND, when enabled, the bar is inside the configured session AND ATR is at or below the low-volatility threshold AND volume is above its moving average AND close is above the current session open AND the prior bar closed above its open AND the selected advanced filters pass AND no long signal has already occurred in the session.
Short: low crosses below the short trigger AND, when enabled, the bar is inside the configured session AND ATR is at or below the low-volatility threshold AND volume is above its moving average AND close is below the current session open AND the prior bar closed below its open AND the selected advanced filters pass AND no short signal has already occurred in the session.
Calculation: Advanced filters pass = if enabled, fast ATR is below or above slow ATR as selected; ADX is rising, above its minimum, or within its configured band as selected; current bar is an inside bar or narrow-range bar as selected; and relative volume is at least its configured multiple.