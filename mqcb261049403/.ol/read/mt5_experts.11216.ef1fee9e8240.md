Calculation: CCI = Commodity Channel Index of the selected applied price on the configured indicator timeframe (which may be higher or lower than the chart timeframe).
Calculation: TSI-CCI = 100 × twice-smoothed CCI momentum / twice-smoothed absolute CCI momentum; momentum = CCI − CCI from the momentum lookback bars earlier. Apply the same short smoothing lookback and then the same longer smoothing lookback to momentum and absolute momentum; use zero if the smoothed absolute momentum is zero.
Calculation: TSI-CCI signal = TSI-CCI smoothed with its signal lookback.
Long: On the latest completed indicator-timeframe bar, TSI-CCI > TSI-CCI signal AND on the preceding completed bar, TSI-CCI ≤ TSI-CCI signal
Short: On the latest completed indicator-timeframe bar, TSI-CCI < TSI-CCI signal AND on the preceding completed bar, TSI-CCI ≥ TSI-CCI signal
Exit: short, TSI-CCI > TSI-CCI signal on the latest completed indicator-timeframe bar
Exit: long, TSI-CCI < TSI-CCI signal on the latest completed indicator-timeframe bar