Calculation: T1 ΔqADR% = ((T1 close − T1 open) / ((SMA(((T1 high / T1 low) − 1) × 100, ADR lookback, T1, including the still-forming bar) / 100) × T1 close)) × 100, calculated on chart bars using still-forming T1 values
Long: T1 ΔqADR% ≥ conviction threshold OR (chart timeframe = T1 AND T1 ΔqADR% > 0)
Short: T1 ΔqADR% ≤ −conviction threshold OR (chart timeframe = T1 AND T1 ΔqADR% ≤ 0)
Long: On chart bars using still-forming T1 values, T1 close ≥ MA(close, MA lookback, selected MA type, T1, still-forming bar)
Short: On chart bars using still-forming T1 values, T1 close < MA(close, MA lookback, selected MA type, T1, still-forming bar)
Long: On chart bars using the still-forming T1 bar, RSI(close, daily RSI lookback, T1, still-forming bar) ≥ RSI color cutoff
Short: On chart bars using the still-forming T1 bar, RSI(close, daily RSI lookback, T1, still-forming bar) < RSI color cutoff
Long: On chart bars using the still-forming T2 bar, ROC(close, ROC lookback, T2, still-forming bar) > ROC absolute cutoff
Short: On chart bars using the still-forming T2 bar, ROC(close, ROC lookback, T2, still-forming bar) < −ROC absolute cutoff
Long: On chart bars using the still-forming T2 bar, RSI(close, weekly RSI lookback, T2, still-forming bar) ≥ RSI color cutoff
Short: On chart bars using the still-forming T2 bar, RSI(close, weekly RSI lookback, T2, still-forming bar) < RSI color cutoff