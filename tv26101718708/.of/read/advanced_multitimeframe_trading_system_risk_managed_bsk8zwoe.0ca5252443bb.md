Calculation: HTFHurst = on the last completed bar of a higher timeframe than the chart: mean = SMA(close, n); dev = close - mean; cumDev = sum of dev over the latest n bars (each dev uses that bar's own SMA); R = highest(cumDev, n) - lowest(cumDev, n); S = stdev(close, n); HTFHurst = ln(R/S) / ln(n), undefined if S is 0
Calculation: Fib618 = L + 0.618*(H - L), where H and L are the high and low of the last completed bar of a higher timeframe than the chart (this timeframe may differ from the one used for HTFHurst)
Calculation: Fib382 = L + 0.382*(H - L), with H and L defined as for Fib618
Long: close crosses above Fib618 (previous close <= Fib618 AND current close > Fib618) AND HTFHurst > 0.5
Short: close crosses below Fib382 (previous close >= Fib382 AND current close < Fib382) AND HTFHurst < 0.5
Exit: long, low <= entry price*(1 - r) OR high >= entry price*(1 + k*r), where r is a fixed fraction of entry price and k is a reward-to-risk multiple
Exit: short, high >= entry price*(1 + r) OR low <= entry price*(1 - k*r), with r and k as above