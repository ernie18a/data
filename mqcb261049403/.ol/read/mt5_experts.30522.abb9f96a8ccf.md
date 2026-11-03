Calculation: Candle body = absolute difference between open and close
Calculation: Upper wick = high minus the greater of open and close
Calculation: Lower wick = the lesser of open and close minus low
Calculation: Candle range = high minus low
Long: On the latest completed chart bar, close > open AND the preceding completed chart bar has close < open AND (2 × latest body < latest lower wick AND latest lower wick > 3 × latest upper wick OR 2 × latest body < latest upper wick AND 3 × latest lower wick < latest upper wick)
Long: On the latest two completed chart bars, both close > open AND latest range > preceding range AND latest body >= 2 × preceding body
Short: On the latest completed chart bar, close < open AND the preceding completed chart bar has close > open AND (2 × latest body < latest upper wick AND 3 × latest lower wick < latest upper wick OR 2 × latest body < latest lower wick AND latest lower wick > 3 × latest upper wick)
Short: On the latest two completed chart bars, both close < open AND latest body > preceding body AND latest range >= 2 × preceding range
Exit: long, low <= the stop price set at entry to the lower low of the two signal bars
Exit: short, high >= the stop price set at entry to the higher high of the two signal bars