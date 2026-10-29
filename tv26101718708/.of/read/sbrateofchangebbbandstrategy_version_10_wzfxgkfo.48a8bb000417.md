Calculation: MFI band state = +1 when MFI is below its lower Bollinger Band, −1 when above its upper Bollinger Band, and 0 otherwise; when the current value is 0 and the previous state is positive or negative, carry its sign and increase its magnitude by 1; reset to 0 if its magnitude exceeds 10.
Long: ROC crosses above its lower Bollinger Band AND MFI band state > 0
Short: ROC crosses below its upper Bollinger Band AND MFI band state < 0
Exit: Short, ROC crosses above its lower Bollinger Band AND MFI band state > 0
Exit: Long, ROC crosses below its upper Bollinger Band AND MFI band state < 0