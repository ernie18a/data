import numpy as np


def generate_signals(features, signal_params):
    market = features.market
    size = int(market.size)

    long_entries = np.zeros(size, dtype=np.bool_)
    long_exits = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    short_exits = np.zeros(size, dtype=np.bool_)

    closes = np.asarray(market.closes, dtype=np.float64)
    lows = np.asarray(market.lows, dtype=np.float64)

    # B is the prior completed bar's support boundary; C is the close series.
    support = np.full(size, np.nan, dtype=np.float64)
    if size > 1:
        support[1:] = lows[:-1]

        current_valid = np.isfinite(closes[1:]) & np.isfinite(support[1:])
        previous_valid = np.isfinite(closes[:-1]) & np.isfinite(support[:-1])

        # Entry: C[t] < B[t] and C[t-1] >= B[t-1].
        short_entries[1:] = (
            current_valid
            & previous_valid
            & (closes[1:] < support[1:])
            & (closes[:-1] >= support[:-1])
        )

        # Exit: C[t] > B[t] and C[t-1] <= B[t-1].
        short_exits[1:] = (
            current_valid
            & previous_valid
            & (closes[1:] > support[1:])
            & (closes[:-1] <= support[:-1])
        )

    return long_entries, long_exits, short_entries, short_exits


STRATEGY = {
    "strategy_id": "spx_0dte_support_to_resistance_rejection_short",
    "hypothesis": (
        "strategy_scope=directional; "
        "source_product_background=原始執行為0DTE SPX 4195/4220 call credit spread，"
        "每組收取130美元權利金並於65美元debit平倉，來源描述為50%獲利；"
        "這些選擇權腿、履約價、權利金、到期與價差管理不納入本方向性回測； "
        "actual_backtest_scope=僅以FRAMEWORK傳入的features.market行情序列回測空方方向訊號，"
        "C為該序列的收盤價，成交由FRAMEWORK安排於訊號後下一根open；"
        "來源敘述的5分鐘圖是商品背景，FRAMEWORK本身提供的各bar_interval序列即為實際回測範圍； "
        "entry_rules=價格跌破前一支撐邊界後形成空方訊號，"
        "以B[t]=前一根已完成K棒low作為前一支撐價格邊界，"
        "並以cross_down(C,B)[t]（C[t] < B[t] and C[t-1] >= B[t-1]）表示支撐轉壓力與拒絕/弱勢； "
        "exit_rules=short: role=invalidate; inputs=C,B; state=none; update=none; "
        "trigger=cross_up(C,B)[t] := C[t] > B[t] && C[t-1] <= B[t-1]; mode=close; action=exit_all; "
        "exit_origin=sop; "
        "exit_derivation=唯一命中SOP 2（價格突破失敗）。沿用entry的5分鐘收盤序列C、"
        "既存前一支撐價格邊界B、同一窗口與既有參數；entry為C跌破B，"
        "exit為C向上穿越同一B，布林結構由突破失敗反向映射為cross_up(C,B)； "
        "position=short; "
        "source_evidence=READ第97–111行（離開30分鐘價值區後改看5分鐘區域、"
        "4,214前高與4,190前支撐、支撐轉壓力、4,195拒絕後於下一根開盤進場、"
        "1 ATR停損與下移）；第112–123行（約10:30–10:35停損並以50%出場）；"
        "第10–12行（第二筆SPX call credit spread商品與結果）。"
    ),
    "position": "short",
    "generate_signals": generate_signals,
    "signal_parameter_names": [],
    "signal_parameter_sets": [{}],
}
