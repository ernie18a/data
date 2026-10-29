Calculation: MAMA = Mesa Adaptive Moving Average of close on the configured indicator timeframe (which may be higher or lower than the chart timeframe); use completed bars.
Calculation: FAMA = Following Adaptive Moving Average derived from MAMA on the same timeframe; use completed bars.
Long: MAMA on the latest completed bar > FAMA on the latest completed bar AND MAMA on the preceding completed bar < FAMA on the preceding completed bar
Short: MAMA on the latest completed bar < FAMA on the latest completed bar AND MAMA on the preceding completed bar > FAMA on the preceding completed bar
Exit: long, MAMA on the latest completed bar < FAMA on the latest completed bar
Exit: short, MAMA on the latest completed bar > FAMA on the latest completed bar