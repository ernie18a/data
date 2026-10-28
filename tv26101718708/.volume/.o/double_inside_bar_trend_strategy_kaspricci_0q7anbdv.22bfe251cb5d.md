Calculation: Trend MA = configured EMA, HMA, SMA, SWMA, VWMA, or WMA of the configured source over the configured length
Calculation: Stop distance = configured fixed distance, or ATR over the configured lookback × configured factor
Calculation: Target distance = configured fixed target distance in fixed mode, or stop distance × configured target ratio in ATR mode
Long: high[2] > high[1] AND high[2] > high AND low[2] < low[1] AND low[2] < low AND close > Trend MA AND bar is confirmed AND no trade is open AND date/session filters pass; place a stop entry at the second inside bar's high
Short: high[2] > high[1] AND high[2] > high AND low[2] < low[1] AND low[2] < low AND close < Trend MA AND bar is confirmed AND no trade is open AND date/session filters pass; place a stop entry at the second inside bar's low
Exit: Long, high >= entry price + Target distance OR low <= entry price − Stop distance
Exit: Short, low <= entry price − Target distance OR high >= entry price + Stop distance