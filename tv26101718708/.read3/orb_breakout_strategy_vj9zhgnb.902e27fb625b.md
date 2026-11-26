Calculation: Opening Range High = highest T1 high during the opening-range window of each session
Calculation: Opening Range Low = lowest T1 low during the opening-range window of each session
Calculation: Long entry price = Opening Range High
Calculation: Short entry price = Opening Range Low
Calculation: Long stop = min(low[2] on the setup bar, Long entry price - minimum tick)
Calculation: Short stop = max(high[2] on the setup bar, Short entry price + minimum tick)
Calculation: Long target = Long entry price + reward/risk parameter × (Long entry price - Long stop)
Calculation: Short target = Short entry price - reward/risk parameter × (Short stop - Short entry price)
Long: On T1 bars, close > Opening Range High AND low > high[2] AND after the opening-range window AND during the regular-session and entry windows AND no open position AND no trade opened that session day AND no active entry setup
Short: On T1 bars, close < Opening Range Low AND high < low[2] AND after the opening-range window AND during the regular-session and entry windows AND no open position AND no trade opened that session day AND no active entry setup
Exit: Long, low <= Long stop OR high >= Long target OR during the flat window
Exit: Short, high >= Short stop OR low <= Short target OR during the flat window