Calculation: current bar = the last completed bar
Calculation: spread ratio = (current bar high - current bar low) / ((sum of (high - low) over the current bar and the spread period - 1 bars before it) / (spread period - 1))
Calculation: spread class = WIDE if spread ratio >= wide spread threshold; NARROW if spread ratio <= narrow spread threshold; otherwise MID
Calculation: volume average = (sum of volume over the current bar and the volume period - 1 bars before it) / (volume period - 1)
Calculation: volume class = HIGH if current bar volume >= volume average; otherwise LOW
Calculation: close zone = DOWN if current bar close <= current bar low + lower close fraction * (current bar high - current bar low); otherwise UP if current bar close >= current bar high - upper close fraction * (current bar high - current bar low); otherwise MID
Calculation: bar direction = UP if current bar close > previous bar close; DOWN if current bar close < previous bar close; otherwise the bar direction of the previous bar
Calculation: bar label = first of: UPTHRUST if spread class = WIDE AND volume class = HIGH AND close zone = DOWN AND previous bar close > close of the bar before the previous bar AND current bar high > previous bar high; NO DEMAND if spread class = NARROW AND (volume class = LOW OR current bar volume < previous bar volume) AND (close zone = DOWN OR close zone = MID) AND bar direction = UP; STOPPING VOLUME if volume class = HIGH AND close zone = UP AND bar direction = DOWN; REVERSE UPTHRUST if spread class = WIDE AND volume class = HIGH AND close zone = UP AND bar direction = UP AND current bar low < previous bar low; NO SUPPLY if spread class = NARROW AND volume class = LOW AND close zone = DOWN AND bar direction = DOWN; EFFORT TO MOVE UP if spread class = WIDE AND bar direction = UP AND close zone = UP AND (volume class = HIGH OR current bar volume > previous bar volume); EFFORT TO MOVE DOWN if spread class = WIDE AND bar direction = DOWN AND close zone = DOWN AND (volume class = HIGH OR current bar volume > previous bar volume); otherwise NONE
Short: bar label = UPTHRUST AND previous bar label != UPTHRUST
Short: bar label = NO DEMAND AND previous bar label != NO DEMAND
Long: bar label = STOPPING VOLUME AND previous bar label != STOPPING VOLUME
Long: bar label = REVERSE UPTHRUST AND previous bar label != REVERSE UPTHRUST
Long: bar label = NO SUPPLY AND previous bar label != NO SUPPLY
Long: bar label = EFFORT TO MOVE UP AND previous bar label != EFFORT TO MOVE UP
Short: bar label = EFFORT TO MOVE DOWN AND previous bar label != EFFORT TO MOVE DOWN