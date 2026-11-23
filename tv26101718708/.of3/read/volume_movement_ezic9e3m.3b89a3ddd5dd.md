Calculation: Range = High - Low
Calculation: Typical range = Median(Range[1], history length)
Calculation: Range ratio = Range / Typical range
Calculation: Location = (Close - Low) / Range
Calculation: Lower wick ratio = (Min(Open, Close) - Low) / Range
Calculation: Matched values = Volume of full-length intraday bars on prior calendar days within matching lookback, at the same time of day in comparison clock, whose day class equals the current bar's day class, where day class is one class for all days, Monday-Friday vs Saturday vs Sunday, or the weekday, as set by day-matching mode
Calculation: Matching-time ready = matching-time baseline enabled AND Count(Matched values) >= minimum matches AND Median(Matched values) > 0
Calculation: Volume ratio = Volume / (Median(Matched values) IF Matching-time ready ELSE Median(Volume[1], history length))
Calculation: High volume = Volume > (Percentile(Matched values, high volume percentile) IF Matching-time ready ELSE Percentile(Volume[1], history length, high volume percentile)) AND Volume ratio >= high volume multiple
Calculation: Large range = Range >= Percentile(Range[1], history length, large range percentile)
Calculation: Anomaly class = none IF bars before the current bar are fewer than history length OR Volume is missing or negative on the current bar or on any of the history length prior bars OR |Open - Close[1]| / Typical range > gap threshold; ELSE stalled IF High volume AND Range <= Percentile(Range[1], history length, small range percentile) AND Range ratio <= small range ratio max AND |Close - Close[1]| / Typical range <= small progress ratio max; ELSE rejection IF High volume AND Range ratio >= rejection range ratio min AND ((Lower wick ratio >= wick min AND Location >= rejection close-location min) OR ((High - Max(Open, Close)) / Range >= wick min AND Location <= rejection close-location max)); ELSE advancing IF High volume AND Large range AND Range ratio >= large range ratio min AND |Close - Open| / Range >= body min AND (Location >= 1 - edge max OR Location <= edge max); ELSE large move IF Volume < (Percentile(Matched values, low volume percentile) IF Matching-time ready ELSE Percentile(Volume[1], history length, low volume percentile)) AND Volume ratio <= low volume multiple AND Large range AND Range ratio >= large range ratio min; ELSE none
Long: Anomaly class = advancing AND Close > Open
Long: Anomaly class = rejection AND Lower wick ratio >= wick min
Long: Anomaly class = large move AND Close > Open
Short: Anomaly class = advancing AND Close < Open
Short: Anomaly class = rejection AND Lower wick ratio < wick min
Short: Anomaly class = large move AND Close < Open