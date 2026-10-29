Calculation: Opening range = high and low of the opening session interval; opening direction = its close compared with its open
Calculation: Noise bands = current day open plus or minus a scaled long-lookback average true range
Calculation: Relative volume = current volume divided by its moving average; strong relative volume = relative volume above its higher threshold; in-play = relative volume above its lower threshold
Calculation: Higher-timeframe trend = higher-timeframe 20-period EMA compared with 50-period EMA, using the last completed higher-timeframe bar
Calculation: Opening volatility = opening-range width greater than a multiple of current ATR
Calculation: Intraday return = (close − current day open) / current day open
Calculation: Primary signal = opening-range breakout or noise-band breakout; secondary signal = late-day momentum signal
Calculation: Quality score = points for relative-volume strength, trend regime, primary versus secondary signal, VWAP alignment, and higher-timeframe alignment
Calculation: Initial stop = opposite opening-range extreme for an opening-range breakout, otherwise entry price offset by a multiple of ATR; first and second targets = entry price offset by one and two initial risk distances; after the first target is reached, stop = entry price
Long: close > opening-range high AND close > open AND in-play AND (higher-timeframe EMA trend is bullish OR close > VWAP) AND opening range is complete AND within the morning entry window AND opening-range breakout has not fired that day
Short: close < opening-range low AND close < open AND in-play AND (higher-timeframe EMA trend is bearish OR close < VWAP) AND opening range is complete AND within the morning entry window AND opening-range breakout has not fired that day
Long: close crosses above the upper noise band AND within the morning entry window
Short: close crosses below the lower noise band AND within the morning entry window
Long: opening direction is bullish AND opening range is volatile AND close > VWAP AND volume > its moving average AND within the late-day momentum window
Short: opening direction is bearish AND opening range is volatile AND close < VWAP AND volume > its moving average AND within the late-day momentum window
Long: intraday return exceeds the positive threshold AND close > VWAP AND volume > its moving average AND within the late-day momentum window
Short: intraday return exceeds the negative threshold in magnitude AND close < VWAP AND volume > its moving average AND within the late-day momentum window
Long: primary or secondary long signal AND no gap-down block AND before hard exit AND cooldown elapsed AND quality score meets the entry threshold
Short: primary or secondary short signal AND no gap-up block AND before hard exit AND cooldown elapsed AND quality score meets the entry threshold
Exit: long, high reaches the second target OR low reaches the current stop OR bars held reaches the time limit OR hard-exit time is reached
Exit: short, low reaches the second target OR high reaches the current stop OR bars held reaches the time limit OR hard-exit time is reached