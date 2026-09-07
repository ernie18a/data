import numpy as np


def generate_signals(features, signal_params):
    n = int(features.market.size)
    long_entries = np.zeros(n, dtype=np.bool_)
    long_exits = np.zeros(n, dtype=np.bool_)
    short_entries = np.zeros(n, dtype=np.bool_)
    short_exits = np.zeros(n, dtype=np.bool_)

    closes = np.asarray(features.market.closes, dtype=np.float64)
    lows = np.asarray(features.market.lows, dtype=np.float64)
    boundary = 44.37

    support_qualified = False
    prior_low = np.nan

    for t in range(n):
        current_low = lows[t]

        if (
            support_qualified
            and np.isfinite(current_low)
            and np.isfinite(prior_low)
            and current_low < prior_low
        ):
            short_entries[t] = True

        if (
            t >= 1
            and np.isfinite(closes[t])
            and np.isfinite(closes[t - 1])
            and closes[t] < boundary
            and closes[t - 1] >= boundary
        ):
            support_qualified = True

        if np.isfinite(current_low):
            if not np.isfinite(prior_low) or current_low < prior_low:
                prior_low = current_low

    if n >= 2:
        current_close = closes[1:]
        previous_close = closes[:-1]
        short_exits[1:] = (
            np.isfinite(current_close)
            & np.isfinite(previous_close)
            & (current_close > boundary)
            & (previous_close <= boundary)
        )

    return long_entries, long_exits, short_entries, short_exits


STRATEGY = {
    'strategy_id': 'spx-bear-call-low-of-day',
    'hypothesis': (
        'strategy_scope=directional\n'
        'source_commodity_context=來源為 SPX／S&P 500 的 bear call credit spread：4420、4425 call 五點價差，收取總權利金 $85，後以 $50 買回；選擇權到期日、權利金與買回管理不納入標的方向回測。\n'
        'actual_backtest_scope=實際回測僅使用 FRAMEWORK 提供的各 bar_interval MarketData OHLCV 序列與當下已完成資料；來源的五分鐘圖描述是策略背景，非額外載入的選擇權或時間欄位。\n'
        'entry_rules=先以來源圖表判定長期上升、短期可能轉跌；價格以收盤價跌破來源前支撐 44.37 後，於行情序列出現低點低於此前已觀測低點時進入空方。\n'
        'exit_rules=short: role=invalidate; inputs=(C=entry_rules 使用的五分鐘收盤價序列, B=來源前支撐44.37); state=C[t-1]與固定B; update=第t根收盤完成後保存C[t]供下一根交叉判定; trigger=若t<1或C[t]、C[t-1]任一為NaN則false，否則cross_up(C,B)[t] := C[t] > B && C[t-1] <= B; mode=close; action=exit_all\n'
        'exit_origin=sop\n'
        'exit_derivation=命中且唯一命中SOP 2（價格突破失敗）。沿用entry的空方方向、操作數C、既存價格邊界B=44.37與五分鐘窗口；entry跌破B對應exit回穿B，將空方不利方向表達為cross_up(C,B)。第t根收盤完成形成訊號，第t+1根open全數平倉；不引入選擇權買回價、當日低點定義或其他持倉狀態。\n'
        'position=short\n'
        'source_evidence=L47-L50：SPX 4420/4425 call spread、收 $85、以 $50 買回；L70-L80：長期上升但短線可能轉跌，跌破前支撐 44.37 時考慮 bear；L91-L102：週四開低，並稱 if it breaks the low of the day, then I will decide to enter this trade，使用五分鐘圖。'
    ),
    'position': 'short',
    'generate_signals': generate_signals,
    'signal_parameter_names': [],
    'signal_parameter_sets': [{}],
}