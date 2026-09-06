import numpy as np

def generate_signals(features, signal_params):
    n = int(features.market.size)
    long_entries = np.zeros(n, dtype=np.bool_)
    long_exits = np.zeros(n, dtype=np.bool_)
    short_entries = np.zeros(n, dtype=np.bool_)
    short_exits = np.zeros(n, dtype=np.bool_)

    if n == 0:
        return long_entries, long_exits, short_entries, short_exits

    try:
        support = float(signal_params['support_level'])
        resistance = float(signal_params['resistance_level'])
    except (KeyError, TypeError, ValueError):
        return long_entries, long_exits, short_entries, short_exits
    if not np.isfinite(support) or not np.isfinite(resistance) or support >= resistance:
        return long_entries, long_exits, short_entries, short_exits

    highs = np.asarray(features.market.highs, dtype=np.float64)
    lows = np.asarray(features.market.lows, dtype=np.float64)
    closes = np.asarray(features.market.closes, dtype=np.float64)
    if highs.size != n or lows.size != n or closes.size != n:
        return long_entries, long_exits, short_entries, short_exits

    valid = np.isfinite(highs) & np.isfinite(lows) & np.isfinite(closes)
    resistance_touched = False
    resistance_peak = np.nan
    lower_high_seen = False
    support_touched = False
    support_trough = np.nan
    higher_low_seen = False

    for i in range(n):
        if not valid[i]:
            resistance_touched = False
            resistance_peak = np.nan
            lower_high_seen = False
            support_touched = False
            support_trough = np.nan
            higher_low_seen = False
            continue

        lower_high_before_bar = lower_high_seen
        higher_low_before_bar = higher_low_seen

        if highs[i] >= resistance:
            if not resistance_touched:
                if i >= 1 and highs[i] > highs[i - 1] and lows[i] > lows[i - 1]:
                    resistance_touched = True
                    resistance_peak = highs[i]
                    lower_high_seen = False
            elif highs[i] > resistance_peak:
                resistance_peak = highs[i]
                lower_high_seen = False

        if i >= 2 and resistance_touched:
            pivot_high = highs[i - 1]
            is_local_high = pivot_high > highs[i - 2] and pivot_high >= highs[i]
            if is_local_high and pivot_high < resistance_peak and pivot_high > support:
                lower_high_seen = True

        if lower_high_before_bar and closes[i] < support:
            short_entries[i] = True
            resistance_touched = False
            resistance_peak = np.nan
            lower_high_seen = False

        if lows[i] <= support:
            if not support_touched:
                support_touched = True
                support_trough = lows[i]
                higher_low_seen = False
            elif lows[i] < support_trough:
                support_trough = lows[i]
                higher_low_seen = False

        if i >= 2 and support_touched:
            pivot_low = lows[i - 1]
            is_local_low = pivot_low < lows[i - 2] and pivot_low <= lows[i]
            if is_local_low and pivot_low > support and pivot_low > support_trough:
                higher_low_seen = True

        if higher_low_before_bar and closes[i] > resistance:
            short_exits[i] = True
            support_touched = False
            support_trough = np.nan
            higher_low_seen = False

    return long_entries, long_exits, short_entries, short_exits


STRATEGY = {
    'strategy_id': 'mac_bear_call_reversal',
    'hypothesis': '原文條件（READ 第252-285、289-386行）：價格進入約45.80阻力區後，不採第一個弱勢訊號；先形成 lower high，再等待結構被跌破且K線收在支撐下方，採 bear call 的下跌方向。口語形式化解讀：以觸及阻力當根相對前一根形成 higher high 與 higher low，作為原文上升結構的最小可計算前置條件；再以 high[i] >= resistance_level 記錄阻力觸及，並以觸及後的局部高點 high[i-1] > high[i-2]、high[i-1] >= high[i] 且低於先前阻力峰值確認 lower high；下一個事件才以 close[i] < support_level 確認 break-and-close-below，支撐與阻力分別使用原文明示的45.30與45.80。原文出場（第384-386行）是此案例數分鐘後、收盤前的操作，框架沒有日界線或可用交易時刻，無法忠實換成固定根數；依規約鏡像進場核心，推導出場為先觸及同一45.30支撐、形成高於支撐的局部 higher low，再以 close[i] > 45.80 突破並收上同一阻力，保留AND與事件先後。',
    'position': 'short',
    'generate_signals': generate_signals,
    'signal_parameter_names': ['support_level', 'resistance_level'],
    'signal_parameter_sets': [{'support_level': 45.30, 'resistance_level': 45.80}],
}