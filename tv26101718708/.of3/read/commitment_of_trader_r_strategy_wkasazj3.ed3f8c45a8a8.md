Long: Williams %R > upper threshold
Short: Williams %R < lower threshold
Exit: long, Williams %R < upper threshold
Exit: short, Williams %R > lower threshold
Long: Williams %R(COT positions selected by CFTC code, trader group, position statistic, and contract basis at T1, period P1) > upper threshold AND (SMA filter disabled OR close > SMA(close, period P2))
Short: Williams %R(COT positions selected by CFTC code, trader group, position statistic, and contract basis at T1, period P1) < lower threshold AND (SMA filter disabled OR close < SMA(close, period P2))
Exit: Long, Williams %R(COT positions selected by CFTC code, trader group, position statistic, and contract basis at T1, period P1) < upper threshold
Exit: Short, Williams %R(COT positions selected by CFTC code, trader group, position statistic, and contract basis at T1, period P1) > lower threshold