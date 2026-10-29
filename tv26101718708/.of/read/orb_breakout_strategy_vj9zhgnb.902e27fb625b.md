Calculation: Opening Range High = highest high during the opening range
Calculation: Opening Range Low = lowest low during the opening range
Calculation: Long stop = low two bars before the breakout, capped below the Opening Range High
Calculation: Short stop = high two bars before the breakdown, floored above the Opening Range Low
Calculation: Long target = entry price + reward-risk multiple × (entry price − Long stop)
Calculation: Short target = entry price − reward-risk multiple × (Short stop − entry price)
Long: opening range complete AND regular session AND entry window AND no trade yet today AND flat AND no active setup AND close > Opening Range High AND low > high two bars earlier
Short: opening range complete AND regular session AND entry window AND no trade yet today AND flat AND no active setup AND close < Opening Range Low AND high < low two bars earlier
Exit: long, low <= Long stop OR high >= Long target OR datetime in flat window
Exit: short, high >= Short stop OR low <= Short target OR datetime in flat window