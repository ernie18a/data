Calculation: TrendHMA = Hull moving average of close (shorter lookback)
Calculation: BaseHMA = Hull moving average of close (longer lookback than TrendHMA)
Calculation: BodyAvg = simple average of |close-open| over the N bars before the current bar (current bar excluded)
Calculation: HH = highest high of the M bars before the current bar (current bar excluded); HH_prev = HH as of the previous bar
Calculation: LL = lowest low of the M bars before the current bar (current bar excluded); LL_prev = LL as of the previous bar
Long: close > TrendHMA AND close > HH AND close[1] <= HH_prev AND volume > K * simple average of volume over the last N2 bars (current bar included; K > 1) AND |close-open| > BodyAvg AND close > BaseHMA AND the previously executed entry signal was not Long (no earlier signal counts as not Long)
Short: close < TrendHMA AND close < LL AND close[1] >= LL_prev AND volume > K * simple average of volume over the last N2 bars (current bar included; K > 1) AND |close-open| > BodyAvg AND close < BaseHMA AND the previously executed entry signal was not Short (no earlier signal counts as not Short)
Exit: Long, high >= entry price + tpMult * ATR (ATR measured on the entry bar) [take profit] OR low <= entry-bar low - slMult * ATR (ATR measured on the entry bar) [stop loss]
Exit: Short, low <= entry price - tpMult * ATR (ATR measured on the entry bar) [take profit] OR high >= entry-bar high + slMult * ATR (ATR measured on the entry bar) [stop loss]