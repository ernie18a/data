Calculation: Trend(X) = +1 if EMA(close, shorter lookback, X, last completed bar) > EMA(close, longer lookback, X, last completed bar), otherwise -1, for X in {chart, T1..Tn}
Calculation: Overall = +1 if sum of Trend(X) over X in {chart, T1..Tn} > 0, -1 if that sum < 0, otherwise Trend(chart)
Calculation: Agreement = round(100 * (sum of ADX(ADX period, X, bar still forming) over X in {chart, T1..Tn} where Trend(X) = Overall) / (sum of ADX(ADX period, X, bar still forming) over X in {chart, T1..Tn}))
Long: Trend(X) = +1
Short: Trend(X) = -1
Long: close(X, last completed bar) > EMA(close, longer lookback, X, last completed bar)
Short: close(X, last completed bar) <= EMA(close, longer lookback, X, last completed bar)
Long: Agreement >= strong threshold AND Overall = +1
Long: Agreement >= moderate threshold AND Agreement < strong threshold AND Overall = +1
Short: Agreement >= strong threshold AND Overall = -1
Short: Agreement >= moderate threshold AND Agreement < strong threshold AND Overall = -1
Long: Trend(chart) = +1 AND Trend(T1) = +1 AND ... AND Trend(Tn) = +1
Short: Trend(chart) = -1 AND Trend(T1) = -1 AND ... AND Trend(Tn) = -1