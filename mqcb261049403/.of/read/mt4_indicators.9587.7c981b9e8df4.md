Calculation: TrendAngle = degrees of arctan((EMA(close)[t] - EMA(close)[t-1]) / S), computed on chart timeframe bars, S = fixed positive price-scale constant
Calculation: HTFTrendAngle = degrees of arctan((EMA(close)[now] - EMA(close)[k bars earlier]) / (S*k)), computed on bars of a higher timeframe than the chart, where 'now' is the still-forming higher-timeframe bar and k counts higher-timeframe bars; same S as TrendAngle
Long: (close[t-1] < EMA(low)[t-1] AND close[t] > EMA(low)[t]) OR (close[t-1] < EMA(high)[t-1] AND close[t] > EMA(high)[t]), with EMA(low) and EMA(high) of the same period on chart timeframe bars (price crosses up through either EMA band)
Long: TrendAngle > +T
Long: HTFTrendAngle > +T
Short: (close[t-1] > EMA(high)[t-1] AND close[t] < EMA(high)[t]) OR (close[t-1] > EMA(low)[t-1] AND close[t] < EMA(low)[t]), with EMA(high) and EMA(low) of the same period on chart timeframe bars (price crosses down through either EMA band)
Short: TrendAngle < -T
Short: HTFTrendAngle < -T