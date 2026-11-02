Incomplete: The adaptive Fourier model, confidence score, projected levels, and trade targets require additional definitions before this framework can reproduce READ's decisions.
Long: Fourier oscillator > 0
Short: Fourier oscillator <= 0
Long: Fourier momentum >= 0
Short: Fourier momentum < 0
Long: Forecast direction is up AND projected movement > 0 AND bullish phase AND (weak cycles allowed OR cycle stability >= minimum stability) AND (ZLEMA confirmation disabled OR close > ZLEMA) AND bullish volume filter passes AND close - ZLEMA <= maximum ATR extension AND cyclic value <= upper amplitude threshold AND higher-timeframe filter passes AND long confidence >= entry threshold AND previous raw signal was not long AND bars since last entry signal >= cooldown AND monitored trade side is not long
Short: Forecast direction is down AND projected movement < 0 AND bearish phase AND (weak cycles allowed OR cycle stability >= minimum stability) AND (ZLEMA confirmation disabled OR close < ZLEMA) AND bearish volume filter passes AND ZLEMA - close <= maximum ATR extension AND cyclic value >= lower amplitude threshold AND higher-timeframe filter passes AND short confidence >= entry threshold AND previous raw signal was not short AND bars since last entry signal >= cooldown AND monitored trade side is not short
Exit: long, bar is after entry bar AND (low <= entry-time stop OR high >= entry-time third target OR bars since entry > expiry)
Exit: short, bar is after entry bar AND (high >= entry-time stop OR low <= entry-time third target OR bars since entry > expiry)