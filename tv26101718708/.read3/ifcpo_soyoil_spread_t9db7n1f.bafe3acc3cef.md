Calculation: spread z-score = Z-score(log(primary close(T1, last completed bar) / paired close(T1, last completed bar)), lookback), calculated on chart bars using T1 values
Long: spread z-score <= -threshold
Short: spread z-score >= threshold
Long: z-score of log(traded-instrument T1 close / soybean oil T1 close) over P1 bars <= -P2
Short: z-score of log(traded-instrument T1 close / soybean oil T1 close) over P1 bars >= P2