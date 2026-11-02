Calculation: Body low = min(open, close); body high = max(open, close).
Long: Volume is not missing AND close >= open.
Short: Volume is not missing AND close < open.
Long: The body low of the candidate bar is lower than the body low of every bar between the candidate and the current closed bar, inclusive, AND is lower than or equal to each body low in the equally long window immediately before the candidate; in strict equality mode, it is strictly lower than each instead.
Short: The body high of the candidate bar is higher than the body high of every bar between the candidate and the current closed bar, inclusive, AND is higher than or equal to each body high in the equally long window immediately before the candidate; in strict equality mode, it is strictly higher than each instead.