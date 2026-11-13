Calculation: ATR = Wilder average true range over a fixed lookback
Calculation: window N = short lookback count; decay d < 1; weights wb, wu, wl >= 0; bins B
Calculation: per-bar ratios with range = high-low+tiny epsilon: body = (close-open)/range*wb; upper = (high-max(open,close))/range*wu; lower = (min(open,close)-low)/range*wl
Calculation: window values = for each of body/upper/lower, the value k bars ago (k=0..N-1) equals ratio(t-k)*d^k (missing history = 0)
Calculation: normEntropy: binSize = (2/B)*(1+ATR/SMA(ATR, same lookback as ATR)); for each of the N window entries and each of the 3 series, bin = clamp(floor((value+1)/binSize), 0, B-1); count entries per (body bin, upper bin, lower bin) triple; p = count/N; entropy = -sum(p*ln p); normEntropy = entropy/ln(B^3)
Calculation: momAdj = ((close-close[N])/close[N]) * (1 + RMA(max(close-prevClose,0),N)/RMA(max(prevClose-close,0),N)); the ratio is 1 when the denominator is 0
Calculation: trendStrength = s (constant > 1) if RMA(max(high-prevHigh,0),N)/ATR != RMA(max(prevLow-low,0),N)/ATR, else 1
Calculation: score = mean(body window values) * (1-normEntropy) * (k + momAdj*m) * trendStrength, with k, m > 0
Long: score > positive long threshold AND abs(score) > min strength AND stdev(close,M)/SMA(close,M)*100 < volatility limit AND (high-low) > a*ATR AND volume > v*SMA(volume,M) with v >= 1 AND abs(momAdj) > small positive value AND at least N bars of history; enter at the close of this bar, only if not already long (a short position is closed and reversed)
Short: score < negative short threshold AND abs(score) > min strength AND stdev(close,M)/SMA(close,M)*100 < volatility limit AND (high-low) > a*ATR AND volume > v*SMA(volume,M) with v >= 1 AND abs(momAdj) > small positive value AND at least N bars of history; enter at the close of this bar, only if not already short (a long position is closed and reversed)
Exit: long, the Short condition is true on the bar (reversal)
Exit: short, the Long condition is true on the bar (reversal)
Exit: long, low <= entryPrice*(1-stopPct/100) - ATRentry*stopMult (ATRentry = ATR on the entry bar)
Exit: short, high >= entryPrice*(1+stopPct/100) + ATRentry*stopMult
Exit: long, trailing stop active once high has reached entryPrice + ATRentry*trailMult, then low <= highest high since entry - entryPrice*trailOffsetPct/100
Exit: short, trailing stop active once low has reached entryPrice - ATRentry*trailMult, then high >= lowest low since entry + entryPrice*trailOffsetPct/100
Exit: long or short, bars held since entry (entry bar counts as 1) > max hold bars