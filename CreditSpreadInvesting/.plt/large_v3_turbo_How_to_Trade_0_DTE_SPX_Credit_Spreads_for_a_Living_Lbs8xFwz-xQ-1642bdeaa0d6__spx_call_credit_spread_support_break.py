import numpy as np


def generate_signals(features, signal_params):
    market = features.market
    size = market.size
    long_entries = np.zeros(size, dtype=np.bool_)
    long_exits = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    short_exits = np.zeros(size, dtype=np.bool_)
    return long_entries, long_exits, short_entries, short_exits


STRATEGY = {
    "strategy_id": "spx_call_credit_spread_support_break",
    "hypothesis": "strategy_scope：directional\nexecution_context：來源以 SPX 0DTE call credit spread 表達偏空觀點，於支撐跌破後在接近平值處建立 call credit spread；來源未列出此示例的確切履約價、到期、權利金或組數。此記錄僅回測 SPX 的方向性 short 訊號，不回測選擇權腿、權利金、到期或選擇權部位管理。\nentry_rules：已確定的方向核心：在來源判定的短期盤整支撐被跌破後，切換至 5 分鐘圖；當價格跌破該支撐且該 5 分鐘 K 棒收盤低於支撐時，建立 short SPX 方向部位。來源將此後續價格行為描述為高點、低點、較低高點、較低低點的短期下跌趨勢。\nexit_rules：short：role=invalidate；inputs=C（entry 使用的 5 分鐘 K 棒收盤價序列）, B（entry 的短期盤整支撐）；state=none；update=none；trigger=cross_up(C,B)[t]，其中 cross_up(C,B)[t] := C[t] > B[t] && C[t-1] <= B[t-1]；mode=close；action=exit_all。\nexit_origin：sop\nexit_derivation：命中 SOP 2「價格突破失敗」：entry 的 short 方向由 5 分鐘收盤 C 跌破既存支撐邊界 B（C<B）確認；出場沿用相同 C、同一支撐 B、相同 5 分鐘資料聚合與收盤確認語意，當 C 重新向上穿越 B 時，以 cross_up(C,B) 使空方突破假說失效。訊號於第 t 根收盤形成，於第 t+1 根 open 全數平倉。\nposition：short\nsource_evidence：第 98–103 行：短期盤整若跌破支撐，形成 high-to-low、lower-high、lower-low 的下跌描述；使用相同 MAC 原則。第 103–107 行：切換至 5 分鐘圖，支撐被跌破且 K 棒收於支撐下方時，建立偏空 call credit spread。第 108–111 行：止損設於該 K 棒稍上方，例示價格 52.21 時設為 52.24。\nsource_instrument_context：SPX 0DTE call credit spread 的偏空來源商品背景。\nactual_backtest_scope：僅限 SPX 方向性 short 訊號；FRAMEWORK 未提供 5 分鐘市場、時間戳或短期盤整支撐 B 的公式、窗口與辨識規則，因此不可忠實建立 entry 或 derived exit。\nderived_exit：若未來提供 B 的明確定義與 5 分鐘資料，short exit 應為 C[t] > B[t] 且 C[t-1] <= B[t-1]。",
    "position": "short",
    "generate_signals": generate_signals,
    "signal_parameter_names": [],
    "signal_parameter_sets": [{}],
}
