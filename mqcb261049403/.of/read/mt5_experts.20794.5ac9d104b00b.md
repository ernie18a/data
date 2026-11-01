Calculation: Selected price = a configurable choice of open, high, low, close, (high + low)/2, (high + low + close)/3, (high + low + 2*close)/4, (open + close)/2, (open + high + low + close)/4, trend-following price, or DeMark price; trend-following price is either high when close > open, low when close < open, and close otherwise, or (high + close)/2 when close > open, (low + close)/2 when close < open, and close otherwise; DeMark price is x - (high + low)/2, where x is (high + low + close + low)/2 when close < open, (high + low + close + high)/2 when close > open, and (high + low + 2*close)/2 otherwise.
Calculation: Double LWMA = a linear weighted moving average of a linear weighted moving average of selected price, both using the same lookback and giving the newest bar the greatest weight. For the indicator markings use chart bars; for the trading decisions use a configurable higher or lower timeframe, with the last completed bar by default or the still-forming bar if selected, and optionally an older completed bar.
Long: Chart-timeframe double LWMA > its previous-bar value.
Short: Chart-timeframe double LWMA < its previous-bar value.
Long: Selected trading-timeframe double LWMA > its previous-bar value AND its previous-bar value <= its value two bars before the selected bar.
Short: Selected trading-timeframe double LWMA < its previous-bar value AND its previous-bar value >= its value two bars before the selected bar.
Exit: long, selected trading-timeframe double LWMA < its previous-bar value.
Exit: short, selected trading-timeframe double LWMA > its previous-bar value.
Exit: long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance.
Exit: short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance.