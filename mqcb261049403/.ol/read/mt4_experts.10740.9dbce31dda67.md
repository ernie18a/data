Long: fast EMA > slow SMA on the last completed bar AND fast EMA < slow SMA on the preceding completed bar AND fast EMA > slow SMA on the forming bar
Short: fast EMA < slow SMA on the last completed bar AND fast EMA > slow SMA on the preceding completed bar AND fast EMA < slow SMA on the forming bar
Exit: Long, low <= stop-loss level OR high >= take-profit level OR (fast EMA crosses below middle SMA AND close < entry price)
Exit: Short, high >= stop-loss level OR low <= take-profit level OR (fast EMA crosses above middle SMA AND close > entry price)