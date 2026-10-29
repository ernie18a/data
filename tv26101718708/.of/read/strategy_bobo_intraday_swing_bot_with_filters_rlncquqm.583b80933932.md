Calculation: Pivot = (high + low + close) / 3 on the last completed bar of the selected pivot timeframe (higher or lower than the chart timeframe)
Calculation: Upper band = Pivot + ATR / divisor; Lower band = Pivot - ATR / divisor, where ATR is calculated on the selected ATR timeframe (higher or lower than the chart timeframe) using its last completed bar
Calculation: Directional Trend Index = 100 × EMA(EMA(EMA(DIU − DID, slow lookback), fast lookback), smoothing lookback) / EMA(EMA(EMA(abs(DIU − DID), slow lookback), fast lookback), smoothing lookback)
Calculation: DIU = 100 × RMA(upward directional movement, momentum lookback) / RMA(true range, momentum lookback); upward directional movement is high − prior high when that exceeds prior low − low and is positive, otherwise 0
Calculation: DID = 100 × RMA(downward directional movement, momentum lookback) / RMA(true range, momentum lookback); downward directional movement is prior low − low when that exceeds high − prior high and is positive, otherwise 0
Calculation: Signal = EMA(Directional Trend Index, signal lookback)
Long: (low <= Lower band OR open <= Lower band) AND close > Lower band AND ATR(3 bars) > ATR(50 bars) AND Signal > Signal 3 bars ago AND flat
Short: (high >= Upper band OR open >= Upper band) AND close < Upper band AND ATR(3 bars) > ATR(50 bars) AND Signal < Signal 3 bars ago AND flat
Exit: long, high > Pivot OR high >= entry price + configured take-profit distance OR low <= entry price - configured stop-loss distance
Exit: short, low < Pivot OR low <= entry price - configured take-profit distance OR high >= entry price + configured stop-loss distance