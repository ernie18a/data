import numpy as np

def generate_signals(features, signal_params):
    n = int(features.market.size)
    long_entries = np.zeros(n, dtype=np.bool_)
    long_exits = np.zeros(n, dtype=np.bool_)
    short_entries = np.zeros(n, dtype=np.bool_)
    short_exits = np.zeros(n, dtype=np.bool_)
    if n < 3:
        return long_entries, long_exits, short_entries, short_exits

    opens = features.market.opens
    highs = features.market.highs
    lows = features.market.lows
    closes = features.market.closes
    atr = features.atr(14)
    sma_200 = features.sma(200)

    last_swing_high = np.nan
    last_swing_low = np.nan
    resistance_touched = False
    setup_armed = False
    break_level = np.nan
    resistance = np.nan
    setup_bar = -1
    in_position = False
    stop_price = np.nan

    for i in range(1, n):
        lower_high_event = False
        if i >= 2:
            pivot = i - 1
            if np.isfinite(highs[pivot - 1]) and np.isfinite(highs[pivot]) and np.isfinite(highs[pivot + 1]):
                if highs[pivot] > highs[pivot - 1] and highs[pivot] >= highs[pivot + 1]:
                    lower_high_event = np.isfinite(last_swing_high) and highs[pivot] < last_swing_high
                    last_swing_high = highs[pivot]
            if np.isfinite(lows[pivot - 1]) and np.isfinite(lows[pivot]) and np.isfinite(lows[pivot + 1]):
                if lows[pivot] < lows[pivot - 1] and lows[pivot] <= lows[pivot + 1]:
                    last_swing_low = lows[pivot]

        if in_position:
            if np.isfinite(stop_price) and np.isfinite(highs[i]) and highs[i] >= stop_price:
                short_exits[i] = True
                in_position = False
            elif np.isfinite(sma_200[i]) and np.isfinite(lows[i]) and lows[i] <= sma_200[i]:
                short_exits[i] = True
                in_position = False
            elif np.isfinite(last_swing_low) and np.isfinite(lows[i]) and lows[i] < last_swing_low:
                if np.isfinite(last_swing_high) and np.isfinite(atr[i]) and atr[i] > 0.0:
                    trailed_stop = last_swing_high + atr[i]
                    if np.isfinite(trailed_stop):
                        stop_price = min(stop_price, trailed_stop)
            continue

        if not setup_armed and np.isfinite(last_swing_high) and np.isfinite(highs[i]) and highs[i] >= last_swing_high:
            resistance_touched = True
            resistance = last_swing_high

        bearish_engulfing = False
        if i >= 1 and np.isfinite(opens[i - 1]) and np.isfinite(closes[i - 1]) and np.isfinite(opens[i]) and np.isfinite(closes[i]):
            bearish_engulfing = (
                closes[i - 1] > opens[i - 1]
                and closes[i] < opens[i]
                and opens[i] >= closes[i - 1]
                and closes[i] <= opens[i - 1]
            )

        if not setup_armed and resistance_touched and (bearish_engulfing or lower_high_event) and np.isfinite(last_swing_low):
            setup_armed = True
            break_level = last_swing_low
            setup_bar = i

        if setup_armed and i > setup_bar and np.isfinite(break_level) and np.isfinite(lows[i]) and lows[i] < break_level:
            if np.isfinite(resistance) and np.isfinite(atr[i]) and atr[i] > 0.0:
                short_entries[i] = True
                in_position = True
                stop_price = resistance + atr[i]
                setup_armed = False
                resistance_touched = False
                break_level = np.nan
                resistance = np.nan

    return long_entries, long_exits, short_entries, short_exits

STRATEGY = {
    'strategy_id': 'spx_0dte_resistance_bearish_break',
    'hypothesis': '原文條件（READ 第50-80、82-87行）：價格進入阻力區後觀察 bearish engulfing、lower high 或結構跌破；案例在 bearish engulfing／lower high 獲確認後等待跌破前低才做空。READ 第61行的 bullish 依 bear-side 上下文及第64、68行明示的 bearish 修正為 bearish。原文出場：上破前高加1ATR離場，形成 lower low 後將停損移到前一高加1ATR，200-period moving average 為較寬鬆獲利區（第78-87行）。形式化解讀：阻力區是最近已確認的三根局部 swing high，觸及定義為當根 high >= 該高點；bearish engulfing 是前一根陽線且當根陰線實體包住前一根，lower high 是新確認 swing high < 前一確認 swing high，兩者以 OR 作為 setup，並以之後 low < setup 前最近 swing low 的事件順序觸發 short。框架用完成當根訊號、下一根 open 成交（engine 第337-417行）；ATR 使用框架固定 ATR(14)，200 SMA 未成熟或數值無效時不觸發該目標出場。推導出場：無額外推導，程式僅保留上述原文出場。',
    'position': 'short',
    'generate_signals': generate_signals,
    'signal_parameter_names': [],
    'signal_parameter_sets': [{}],
}
