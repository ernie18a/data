Calculation: Fast midpoint = mean of a fast EMA of close and an HMA of close with a shorter lookback than that EMA; slow midpoint = mean of a slow EMA of close and an HMA of close with a shorter lookback than that EMA. The slow EMA and HMA have longer lookbacks than their fast counterparts.
Calculation: Regime strength = clamp to the oscillator range the weighted sum of the absolute fast-to-slow midpoint spread divided by ATR and the absolute distance of range position from its midpoint. Range position is close within the rolling high-low range, expressed on the oscillator scale. A zero denominator produces zero; use a positive price increment as the minimum range denominator.
Calculation: Regime persistence = number of consecutive bars for which the truth value of fast midpoint > slow midpoint has remained unchanged, reset to zero when it changes.
Calculation: Liquidity bias = (volume on bars with close >= open minus volume on bars with close < open) divided by the greater of their combined volume and a positive volume floor, over a rolling lookback; it is zero when the rolling high-low range is zero.
Calculation: Support = the most recent confirmed pivot low, using equal left and right confirmation lengths, or the rolling lowest low if no pivot is available. Resistance = the equivalent confirmed pivot high or rolling highest high.
Calculation: Pressure = RSI of close momentum. Displacement = clamp to the oscillator range the weighted sum of absolute fast EMA minus slow EMA divided by ATR and absolute pressure distance from the oscillator midpoint; zero ATR gives a zero ratio.
Calculation: Bull gap = low > high two bars ago AND previous high > high two bars ago AND (low minus high two bars ago) divided by the greater of its rolling standard deviation and a positive price increment > gap threshold. Bear gap = high < low two bars ago AND previous low < low two bars ago AND (low two bars ago minus high) divided by the greater of its rolling standard deviation and a positive price increment > gap threshold.
Calculation: Bull shift = displacement >= displacement threshold AND pressure > upper shift threshold AND close > fast EMA AND fast midpoint > slow midpoint. Bear shift = displacement >= displacement threshold AND pressure < lower shift threshold AND close < fast EMA AND fast midpoint < slow midpoint. The shift thresholds lie on opposite sides of the oscillator midpoint.
Calculation: Bull continuation = continuation enabled AND pressure >= continuation threshold AND close > fast midpoint AND low <= fast EMA. Bear continuation = continuation enabled AND pressure <= oscillator maximum minus continuation threshold AND close < fast midpoint AND high >= fast EMA.
Calculation: Bull trigger = bull gap OR bull shift OR bull continuation. Bear trigger = bear gap OR bear shift OR bear continuation.
Calculation: Long context = fast midpoint > slow midpoint AND regime strength >= regime threshold AND regime persistence >= persistence threshold AND liquidity bias > positive bias threshold AND close >= reference EMA AND close > support AND close > slow EMA. Short context = fast midpoint <= slow midpoint AND regime strength >= regime threshold AND regime persistence >= persistence threshold AND liquidity bias < negative bias threshold AND close <= reference EMA AND close < resistance AND close < slow EMA. The bias thresholds are equal in magnitude.
Calculation: At a long entry, initial stop = min(entry-signal close minus ATR times stop multiplier, min(support, entry-signal low) minus ATR times invalidation multiplier); at a short entry, initial stop = max(entry-signal close plus ATR times stop multiplier, max(resistance, entry-signal high) plus ATR times invalidation multiplier). Freeze initial risk as the greater of the distance from entry-signal close to initial stop and a positive minimum price distance. Freeze two targets at entry-signal close plus initial risk times each target multiplier for a long, or minus that amount for a short. The second target multiplier is greater than the first.
Calculation: Active stop starts at initial stop. After each completed bar in a position, if trailing is enabled AND regime strength >= trailing threshold, update the long stop to the greater of its previous value and rolling lowest low minus ATR times trailing multiplier, or the short stop to the lesser of its previous value and rolling highest high plus ATR times trailing multiplier. The updated stop applies to subsequent bars.
Long: long context AND bull trigger AND position side is flat or short.
Short: short context AND bear trigger AND position side is flat or long.
Long: long context.
Short: short context.
Long: bull trigger.
Short: bear trigger AND bull trigger is false.
Long: bull continuation.
Short: bear continuation AND bull continuation is false.
Long: bull shift.
Short: bear shift.
Long: liquidity bias >= zero.
Short: liquidity bias < zero.
Long: pressure >= oscillator midpoint.
Short: pressure < oscillator midpoint.
Exit: long, low <= active stop OR high >= first target for the first half of the position OR high >= second target for the second half of the position OR short entry condition is true.
Exit: short, high >= active stop OR low <= first target for the first half of the position OR low <= second target for the second half of the position OR long entry condition is true.