Calculation: Heiken Ashi candle = haClose=(open+high+low+close)/4; haOpen=(previous haOpen+previous haClose)/2, initialized to (open+close)/2; bullish if haClose>haOpen, bearish if haClose<haOpen
Calculation: UT Bot trailing stop = ATR-based trailing stop calculated from Heiken Ashi close; bullish if Heiken Ashi close>stop, bearish if Heiken Ashi close<stop
Calculation: Signal score = sum of enabled filter votes: +1 for bullish and −1 for bearish Heiken Ashi, Supertrend, and UT Bot; 0 for neutral filters
Long: MA 1 crosses above MA 2 OR MA 2 crosses above MA 3 OR Signal score>0 OR Signal score>0 AND previous Signal score<=0
Short: MA 1 crosses below MA 2 OR MA 2 crosses below MA 3 OR Signal score<0 OR Signal score<0 AND previous Signal score>=0