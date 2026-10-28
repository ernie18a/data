Long: close > open OR current confirmed price pivot low < previous confirmed price pivot low AND current confirmed volume pivot low > previous confirmed volume pivot low
Short: close <= open OR current confirmed price pivot high > previous confirmed price pivot high AND current confirmed volume pivot high < previous confirmed volume pivot high
Exit: Long, high >= entry price × (1 + configured target percentage) OR low <= entry price × (1 − configured stop percentage)
Exit: Short, low <= entry price × (1 − configured target percentage) OR high >= entry price × (1 + configured stop percentage)