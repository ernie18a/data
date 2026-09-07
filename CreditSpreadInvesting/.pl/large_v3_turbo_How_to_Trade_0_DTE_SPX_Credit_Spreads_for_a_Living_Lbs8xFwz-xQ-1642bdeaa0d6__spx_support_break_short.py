import numpy as np

def generate_signals(features, signal_params):
    n = int(features.market.size)
    long_entries = np.zeros(n, dtype=np.bool_)
    long_exits = np.zeros(n, dtype=np.bool_)
    short_entries = np.zeros(n, dtype=np.bool_)
    short_exits = np.zeros(n, dtype=np.bool_)
    if n == 0:
        return long_entries, long_exits, short_entries, short_exits

    highs = np.asarray(features.market.highs, dtype=np.float64)
    lows = np.asarray(features.market.lows, dtype=np.float64)
    closes = np.asarray(features.market.closes, dtype=np.float64)
    valid = np.isfinite(highs) & np.isfinite(lows) & np.isfinite(closes)

    state = 0
    first_high = np.nan
    first_low = np.nan
    active_support = np.nan

    for t in range(2, n):
        if not valid[t] or not valid[t - 1] or not valid[t - 2]:
            state = 0
            first_high = np.nan
            first_low = np.nan
            continue

        pivot = t - 1
        is_swing_high = (
            highs[pivot] > highs[pivot - 1]
            and highs[pivot] >= highs[t]
        )
        is_swing_low = (
            lows[pivot] < lows[pivot - 1]
            and lows[pivot] <= lows[t]
        )

        if is_swing_high and is_swing_low:
            is_swing_high = False
            is_swing_low = False

        if state == 0:
            if is_swing_high:
                first_high = highs[pivot]
                state = 1
        elif state == 1:
            if is_swing_low:
                first_low = lows[pivot]
                state = 2
            elif is_swing_high:
                first_high = highs[pivot]
        elif state == 2:
            if is_swing_high:
                if highs[pivot] < first_high:
                    state = 3
                else:
                    first_high = highs[pivot]
                    state = 1
            elif is_swing_low:
                first_low = lows[pivot]
        else:
            if is_swing_low:
                if lows[pivot] < first_low:
                    active_support = first_low
                    state = 0
                    first_high = np.nan
                    first_low = np.nan
                else:
                    state = 2
            elif is_swing_high and highs[pivot] >= first_high:
                first_high = highs[pivot]
                first_low = np.nan
                state = 1

        if np.isfinite(active_support):
            if closes[t] < active_support:
                short_entries[t] = True
            if (
                closes[t] > active_support
                and closes[t - 1] <= active_support
            ):
                short_exits[t] = True

    return long_entries, long_exits, short_entries, short_exits


STRATEGY = {
    'strategy_id': 'spx_support_break_short',
    'hypothesis': '{"strategy_scope":"directional","source_instrument_background":"來源為 SPX 0-DTE、接近 ATM 的 call credit spread；來源未完整指定履約價、到期以外條款或組數。","actual_backtest_scope":"僅回測 FRAMEWORK 提供行情序列的 SPX short 方向訊號；不回測選擇權腿、權利金、到期、價差損益或來源所稱的五分鐘時鐘相位。","execution_context":"2.1. 原始執行為 SPX 0-DTE、接近 ATM 的 call credit spread，藉由 SPX 下跌表達偏空曝險；來源未指定示例的完整履約價、到期以外的商品條款或組數。來源建議停損略高於突破 K 線，示例從 5221 設為 5224；本記錄僅回測 SPX 的 short 方向訊號，不回測選擇權腿、權利金、到期或價差損益。","entry_rules":"2.3. 已確定核心：當短期結構為 high→low→lower high→lower low，且五分鐘 K 線跌破已識別支撐並收於支撐下方時建立 SPX short。未解條件：swing high／low 的計算窗口與確認規則、支撐的產生規則與寬度、跌破是 low 穿越或 close 穿越、結構與跌破的事件順序，以及五分鐘 K 線的時鐘相位。","exit_rules":"short：role=invalidate；inputs=C（entry_rules 使用的五分鐘收盤價序列，C[t] 為第 t 根已完成 K 線收盤價）、B（entry_rules 所稱已識別支撐邊界，沿用同一支撐基準）；state=none；update=none；trigger=cross_up(C,B)[t] := C[t] > B[t] && C[t-1] <= B[t-1]；第 t 根尚未完成、t-1 不存在或必要的 C/B 值為 NaN 時 trigger=false；mode=close；action=exit_all；第 t 根收盤形成訊號，於第 t+1 根 open 將 short 全數平倉。","exit_origin":"sop","exit_derivation":"SOP 2（價格突破失敗）。entry 的操作數為 C 與已識別支撐基準 B；short entry 為價格跌破並收於 B 下方，exit 沿用同一 C、同一 B、同一五分鐘窗口，無新增參數與持倉狀態，將不利方向的收盤穿越對應為 cross_up(C,B)。來源中未定義的停損 K 線、5221→5224 偏移及實際觸價語意不納入；採固定 close signal→下一根 open exit_all。","position":"short","source_evidence":"2.2. READ 行 98-107：短期趨勢形成 high→low→lower high→lower low，支撐被跌破且收盤在其下時，在五分鐘圖進入 bear side 的 call credit spread。READ 行 108-111：停損略設於該 K 線上方；示例為 5221 上方的 5224。"}',
    'position': 'short',
    'generate_signals': generate_signals,
    'signal_parameter_names': [],
    'signal_parameter_sets': [{}],
}