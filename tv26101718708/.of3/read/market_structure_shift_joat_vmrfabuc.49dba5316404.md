Calculation: Swing bullish break = (close when close confirmation is selected, otherwise high) > latest unbroken Pivot high(high, swing pivot length, swing pivot length)
Calculation: Swing bearish break = (close when close confirmation is selected, otherwise low) < latest unbroken Pivot low(low, swing pivot length, swing pivot length)
Calculation: Internal bullish break = internal tracking enabled AND (close when close confirmation is selected, otherwise high) > latest unbroken Pivot high(high, internal pivot length, internal pivot length)
Calculation: Internal bearish break = internal tracking enabled AND (close when close confirmation is selected, otherwise low) < latest unbroken Pivot low(low, internal pivot length, internal pivot length)
Long: Swing bullish break AND prior swing state is bearish
Long: Swing bullish break AND prior swing state is bullish or range
Short: Swing bearish break AND prior swing state is bullish
Short: Swing bearish break AND prior swing state is bearish or range
Long: Internal bullish break AND prior internal state is bearish
Long: Internal bullish break AND prior internal state is bullish or range
Short: Internal bearish break AND prior internal state is bullish
Short: Internal bearish break AND prior internal state is bearish or range
Calculation: Bullish signal candidate = (signal source includes swing AND ((CHoCH signals enabled AND Swing bullish break AND prior swing state is bearish) OR (BOS signals enabled AND Swing bullish break AND prior swing state is bullish or range))) OR (signal source includes internal AND Internal bullish break AND ((CHoCH signals enabled AND prior internal state is bearish) OR (BOS signals enabled AND prior internal state is bullish or range)))
Calculation: Bearish signal candidate = (signal source includes swing AND ((CHoCH signals enabled AND Swing bearish break AND prior swing state is bullish) OR (BOS signals enabled AND Swing bearish break AND prior swing state is bearish or range))) OR (signal source includes internal AND Internal bearish break AND ((CHoCH signals enabled AND prior internal state is bullish) OR (BOS signals enabled AND prior internal state is bearish or range)))
Long: Bullish signal candidate AND NOT Bearish signal candidate
Short: Bearish signal candidate AND NOT Bullish signal candidate
Long: latest confirmed swing pivot high > latest confirmed swing pivot low AND close < (latest confirmed swing pivot high + latest confirmed swing pivot low) / 2 - (latest confirmed swing pivot high - latest confirmed swing pivot low) * equilibrium-band parameter
Short: latest confirmed swing pivot high > latest confirmed swing pivot low AND close > (latest confirmed swing pivot high + latest confirmed swing pivot low) / 2 + (latest confirmed swing pivot high - latest confirmed swing pivot low) * equilibrium-band parameter