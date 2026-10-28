Calculation: Alligator jaw, teeth, and lips = smoothed moving averages of (high + low) / 2 with respectively longer, medium, and shorter lookbacks, each read at its corresponding forward offset (equivalently, the unshifted value from that many bars ago).
Calculation: Awesome Oscillator (AO) = short-lookback simple moving average of (high + low) / 2 minus its long-lookback simple moving average.
Calculation: Accelerator Oscillator (AC) = AO minus a short-lookback simple moving average of AO.
Calculation: Fractals = confirmed swing highs or lows: the pivot high is greater than the highs on the preceding lookback bars and meets the script’s right-side frontier rule; the pivot low is lower than the lows on the preceding lookback bars and meets the corresponding right-side frontier rule. A pivot is recognized after the lookahead bars complete.
Calculation: Candle thirds and midpoint = divide the current bar’s high-low range into three equal parts and find its midpoint.
Long: ((AO > 0 AND AO two bars ago > AO one bar ago AND AO > AO one bar ago) OR (AO one bar ago < 0 AND AO > 0)) AND close > jaw AND close > teeth AND close > lips
Long: ((AC > 0 AND AC > AC one bar ago AND AC one bar ago > AC two bars ago) OR (AC < 0 AND AC > AC one bar ago AND AC one bar ago > AC two bars ago AND AC two bars ago > AC three bars ago)) AND close > jaw AND close > teeth AND close > lips AND the same AC long condition with its Alligator filter was false on the previous bar
Long: bar range > 0 AND open and close are both in the upper third AND low < previous bar low AND high < jaw AND high < teeth AND high < lips
Long: bar range > 0 AND open and close are both in the upper third AND low > teeth
Long: a confirmed down fractal
Short: ((AO < 0 AND AO two bars ago < AO one bar ago AND AO < AO one bar ago) OR (AO one bar ago > 0 AND AO < 0)) AND close < jaw AND close < teeth AND close < lips
Short: ((AC < 0 AND AC < AC one bar ago AND AC one bar ago < AC two bars ago) OR (AC > 0 AND AC < AC one bar ago AND AC one bar ago < AC two bars ago AND AC two bars ago < AC three bars ago)) AND close < jaw AND close < teeth AND close < lips AND the same AC short condition with its Alligator filter was false on the previous bar
Short: bar range > 0 AND open and close are both in the lower third AND high > previous bar high AND low > jaw AND low > teeth AND low > lips
Short: bar range > 0 AND high > previous bar high AND close is at or below the midpoint AND low > jaw AND low > teeth AND low > lips AND the strong bearish condition is false
Short: bar range > 0 AND open and close are both in the lower third AND high < teeth
Short: a confirmed up fractal