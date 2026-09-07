import numpy as np


def generate_signals(features, signal_params):
    closes = np.asarray(features.market.closes, dtype=np.float64)
    size = features.market.size
    boundary = 44.60

    long_entries = np.zeros(size, dtype=np.bool_)
    long_exits = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    short_exits = np.zeros(size, dtype=np.bool_)

    breakout_seen = False
    retest_seen = False

    for t in range(1, size):
        previous = closes[t - 1]
        current = closes[t]
        valid = np.isfinite(previous) and np.isfinite(current)
        if not valid:
            continue

        crosses_up = current > boundary and previous <= boundary

        if not breakout_seen:
            if crosses_up:
                breakout_seen = True
            continue

        if not retest_seen:
            if current <= boundary:
                retest_seen = True
            continue

        if crosses_up:
            long_entries[t] = True
            breakout_seen = False
            retest_seen = False

    if size > 1:
        valid_exit = np.isfinite(closes[1:]) & np.isfinite(closes[:-1])
        long_exits[1:] = (
            valid_exit
            & (closes[1:] < boundary)
            & (closes[:-1] >= boundary)
        )

    return long_entries, long_exits, short_entries, short_exits


STRATEGY = {
    "strategy_id": "mac-bull-breakout-retest",
    "hypothesis": (
        "strategy_scope: directional\n"
        "execution_context: 來源以 SPX 選擇權 credit spread 表達偏多觀點；bull put spread 的商品語意為賣出 put、買入較低履約價 put，標的上漲時有利。未指定本假說的履約價、到期日、權利金或部位大小。方向回測僅測試標的偏多訊號。\n"
        "entry_rules: 偏多候選：價格突破人工標示的 44.60 阻力後，回測該水準，並確認突破有效時進場。\n"
        "exit_rules: long: role=invalidate; inputs=C, B=44.60; state=none; update=none; trigger=cross_down(C,B)[t] := C[t] < 44.60 && C[t-1] >= 44.60; mode=close; action=exit_all。\n"
        "exit_origin: sop\n"
        "exit_derivation: 命中 SOP 2（價格突破失敗）：entry 為偏多價格突破既存阻力邊界 B=44.60；沿用 entry 的收盤價序列 C 與同一固定邊界 B=44.60。偏多突破失敗定義為收盤價由 B 上方或等於 B 交叉至 B 下方，即 cross_down(C,B)；不引入回測、確認、持倉路徑或額外參數。\n"
        "position: long\n"
        "source_evidence: READ 第77–90行：「if it ever breaks past 44.60, we can look to take a bull trade」；「a very strong break of structure… coming back down to test and confirm」。"
    ),
    "position": "long",
    "generate_signals": generate_signals,
    "signal_parameter_names": [],
    "signal_parameter_sets": [{}],
}