Calculation: Alligator = three lines Jaw, Teeth, Lips; each is the smoothed moving average (SMMA, Wilder; seeded with SMA, then (prev*(length-1)+src)/length) of (high+low)/2; lengths Jaw > Teeth > Lips; the value used on the current bar is the line value computed a fixed number of bars earlier, with shift Jaw > Teeth > Lips; all comparisons below use these shifted values
Calculation: AO = SMA((high+low)/2, short length) - SMA((high+low)/2, long length)
Calculation: AC = AO - SMA(AO, same length as AO's short length)
Calculation: Range = high - low, valid only if Range > minimum tick; BottomThird = low + Range/3; TopThird = low + 2*Range/3; Mid = low + Range/2
Long: ((AO > 0 AND AO[2 bars ago] > AO[1 bar ago] AND AO > AO[1 bar ago]) OR (AO[1 bar ago] < 0 AND AO > 0)) AND close > Jaw AND close > Teeth AND close > Lips
Long: ((AC > 0 AND AC > AC[1] AND AC[1] > AC[2]) OR (AC < 0 AND AC > AC[1] AND AC[1] > AC[2] AND AC[2] > AC[3])) AND close > Jaw AND close > Teeth AND close > Lips AND NOT (that same AC-and-Alligator condition was true on the previous bar)
Long: valid bar AND low < previous bar's low AND close >= Mid AND high < Jaw AND high < Teeth AND high < Lips
Long: valid bar AND open >= TopThird AND close >= TopThird AND low > Teeth
Short: ((AO < 0 AND AO[2 bars ago] < AO[1 bar ago] AND AO < AO[1 bar ago]) OR (AO[1 bar ago] > 0 AND AO < 0)) AND close < Jaw AND close < Teeth AND close < Lips
Short: ((AC < 0 AND AC < AC[1] AND AC[1] < AC[2]) OR (AC > 0 AND AC < AC[1] AND AC[1] < AC[2] AND AC[2] < AC[3])) AND close < Jaw AND close < Teeth AND close < Lips AND NOT (that same AC-and-Alligator condition was true on the previous bar)
Short: valid bar AND high > previous bar's high AND close <= Mid AND low > Jaw AND low > Teeth AND low > Lips
Short: valid bar AND open <= BottomThird AND close <= BottomThird AND high < Teeth