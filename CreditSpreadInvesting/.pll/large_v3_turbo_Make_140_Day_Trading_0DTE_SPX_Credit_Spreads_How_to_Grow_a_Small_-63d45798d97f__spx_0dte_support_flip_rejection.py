import numpy as np

def generate_signals(features, signal_params):
    n = int(features.market.size)
    long_entries = np.zeros(n, dtype=np.bool_)
    long_exits = np.zeros(n, dtype=np.bool_)
    short_entries = np.zeros(n, dtype=np.bool_)
    short_exits = np.zeros(n, dtype=np.bool_)
    if n < 3:
        return long_entries, long_exits, short_entries, short_exits

    highs = features.market.highs
    lows = features.market.lows
    closes = features.market.closes
    atr = features.atr(14)
    last_swing_high = np.nan
    last_swing_low = np.nan
    support_broken = False
    support_level = np.nan
    break_bar = -1
    in_position = False
    stop_price = np.nan

    for i in range(1, n):
        if i >= 2:
            pivot = i - 1
            if np.isfinite(highs[pivot - 1]) and np.isfinite(highs[pivot]) and np.isfinite(highs[pivot + 1]):
                if highs[pivot] > highs[pivot - 1] and highs[pivot] >= highs[pivot + 1]:
                    last_swing_high = highs[pivot]
            if np.isfinite(lows[pivot - 1]) and np.isfinite(lows[pivot]) and np.isfinite(lows[pivot + 1]):
                if lows[pivot] < lows[pivot - 1] and lows[pivot] <= lows[pivot + 1]:
                    last_swing_low = lows[pivot]

        if in_position:
            if np.isfinite(stop_price) and np.isfinite(highs[i]) and highs[i] >= stop_price:
                short_exits[i] = True
                in_position = False
            elif np.isfinite(last_swing_low) and np.isfinite(lows[i]) and lows[i] < last_swing_low:
                if np.isfinite(last_swing_high) and np.isfinite(atr[i]) and atr[i] > 0.0:
                    trailed_stop = last_swing_high + atr[i]
                    if np.isfinite(trailed_stop):
                        stop_price = min(stop_price, trailed_stop)
            continue

        if support_broken and np.isfinite(support_level) and np.isfinite(closes[i]) and closes[i] > support_level:
            support_broken = False
            support_level = np.nan
            break_bar = -1

        if not support_broken and np.isfinite(last_swing_low) and np.isfinite(lows[i]) and lows[i] < last_swing_low:
            support_broken = True
            support_level = last_swing_low
            break_bar = i
            continue

        rejection = (
            support_broken
            and i > break_bar
            and np.isfinite(support_level)
            and np.isfinite(highs[i])
            and np.isfinite(closes[i])
            and highs[i] >= support_level
            and closes[i] < support_level
        )
        if rejection and np.isfinite(last_swing_high) and np.isfinite(atr[i]) and atr[i] > 0.0:
            short_entries[i] = True
            in_position = True
            stop_price = last_swing_high + atr[i]
            support_broken = False
            support_level = np.nan
            break_bar = -1

    return long_entries, long_exits, short_entries, short_exits

STRATEGY = {
    'strategy_id': 'spx_0dte_support_flip_rejection',
    'hypothesis': '原文條件（READ 第96-113行）：在前一支撐被跌破、轉成阻力的區域觀察 weakness；價格回測該位後拒絕並收在其下，於下一根 K 開盤做空（第100-105行）。原文出場：初始停損為前高上方1ATR，價格下行後持續下移停損，突破該停損即出場（第106-111行）；原文未提供獨立的獲利目標。形式化解讀：支撐是最近已確認的三根局部 swing low，跌破是後續 low < 該低點；回測拒絕是跌破後的後續 bar high >= 支撐且 close < 支撐，並在有可用前一 swing high 與 ATR(14) 時才觸發 short。框架以完成當根訊號、下一根 open 成交（engine 第337-417行）。推導出場：無；未把第一個 setup 的200 SMA或框架風控網格新增到本策略。',
    'position': 'short',
    'generate_signals': generate_signals,
    'signal_parameter_names': [],
    'signal_parameter_sets': [{}],
}
