Calculation: Opening-range high = highest high of bars during the configured opening-range session, available after that session ends
Calculation: Opening-range low = lowest low of bars during the configured opening-range session, available after that session ends
Calculation: Long target = opening-range high + (opening-range high − opening-range low) × configured reward/risk ratio
Calculation: Short target = opening-range low − (opening-range high − opening-range low) × configured reward/risk ratio
Long: opening range is complete AND current bar is in the configured entry window AND no trade has been taken today AND no position is active AND high >= opening-range high
Short: opening range is complete AND current bar is in the configured entry window AND no trade has been taken today AND no position is active AND high < opening-range high AND low <= opening-range low
Exit: Long, bar is after the entry bar AND (high >= Long target OR low <= opening-range low OR bar closing time >= configured stop time in the instrument's timezone)
Exit: Short, bar is after the entry bar AND (low <= Short target OR high >= opening-range high OR bar closing time >= configured stop time in the instrument's timezone)