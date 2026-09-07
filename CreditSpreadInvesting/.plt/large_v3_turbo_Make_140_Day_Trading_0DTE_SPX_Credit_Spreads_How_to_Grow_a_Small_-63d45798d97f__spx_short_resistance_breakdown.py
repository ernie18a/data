import numpy as np


def generate_signals(features, signal_params):
    market = features.market
    size = market.size
    closes = np.asarray(market.closes, dtype=np.float64)
    lows = np.asarray(market.lows, dtype=np.float64)

    long_entries = np.zeros(size, dtype=np.bool_)
    long_exits = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    short_exits = np.zeros(size, dtype=np.bool_)

    prior_low = np.full(size, np.nan, dtype=np.float64)
    if size > 1:
        prior_low[1:] = lows[:-1]

    active_boundary = np.nan
    for t in range(2, size):
        close_now = closes[t]
        close_previous = closes[t - 1]

        if np.isfinite(active_boundary):
            if (
                np.isfinite(close_now)
                and np.isfinite(close_previous)
                and close_now > active_boundary
                and close_previous <= active_boundary
            ):
                short_exits[t] = True
                active_boundary = np.nan
            continue

        boundary_now = prior_low[t]
        boundary_previous = prior_low[t - 1]
        if (
            np.isfinite(close_now)
            and np.isfinite(close_previous)
            and np.isfinite(boundary_now)
            and np.isfinite(boundary_previous)
            and close_now < boundary_now
            and close_previous >= boundary_previous
        ):
            short_entries[t] = True
            active_boundary = boundary_now

    return long_entries, long_exits, short_entries, short_exits


STRATEGY = {
    "strategy_id": "spx_short_resistance_breakdown",
    "hypothesis": """strategy_scope: directional
source_product_background: 來源以 0DTE SPX 4220/4225 call credit spread 表達偏空：賣出 4220 call、買入 4225 call，收取每組 95 美元權利金；持有兩組，後以每組 20 美元 debit 平倉。價差履約價設在前高上方；權利金、到期、價差損益與平倉均屬原始選擇權執行。
actual_backtest_scope: 僅回測 FRAMEWORK 提供之單一標的行情序列的偏空方向核心；不回測 SPX 選擇權履約價、權利金、到期或價差損益。
execution_context: 來源以 0DTE SPX 4220/4225 call credit spread 表達偏空：賣出 4220 call、買入 4225 call，收取每組 95 美元權利金；持有兩組，後以每組 20 美元 debit 平倉。價差履約價設在前高上方；權利金、到期、價差損益與平倉均屬原始選擇權執行，不納入本標的方向回測。本記錄僅抽取 SPX 下跌方向核心。
entry_rules: 已確定的方向核心：先在 30 分鐘圖辨識阻力／價值區，價格進入該區後轉至 5 分鐘圖；觀察偏空吞沒形態、較低高點或結構跌破。此實例中，作者未在第一個偏空吞沒候選處進場，而是等待指定的前低被跌破，於跌破所在 K 棒進場，建立 SPX 偏空曝險。此模組以每根已完成 K 棒的前一根 low 作為指定前低邊界 B，並以 close 對 B 的向下穿越作為可回測的結構跌破。
exit_rules: short：role=\"invalidate\"；inputs：C=entry_rules 用於「前低被跌破」判定的收盤價序列，B=entry_rules 中指定的前低價格邊界；state=\"none\"；update=\"none\"；trigger=\"cross_up(C,B)[t] := C[t] > B[t] && C[t-1] <= B[t-1]\"；mode=\"close\"；action=\"exit_all\"。第 t 根收盤形成訊號，第 t+1 根 open 全數平倉；warm-up、NaN 或必要輸入不可用時 trigger=false。
exit_origin: sop
exit_derivation: 命中 SOP 2「價格突破失敗」：entry 的偏空方向是在指定前低 B 被跌破時建立，故沿用相同 B，當收盤價序列 C 向上重新突破 B 時，以 cross_up(C,B) 使偏空突破失效；未引入 ATR、移動停損、200 期均線、持倉路徑或其他新參數。
position: short
source_evidence: READ 第 7–12 行記錄兩筆 SPX call credit spread；第 59–76 行說明價格跳空進入 4200–4230 阻力區後，等待偏空訊號及前低跌破，並於 8:15 跌破時建立 4220/4225 call credit spread；第 78–88 行說明以前高上方 1 ATR 為停損、形成更低低點後下移停損。""",
    "position": "short",
    "generate_signals": generate_signals,
    "signal_parameter_names": [],
    "signal_parameter_sets": [{}],
}