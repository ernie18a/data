import numpy as np

def generate_signals(features, signal_params):
    n = int(features.market.size)
    long_entries = np.zeros(n, dtype=np.bool_)
    long_exits = np.zeros(n, dtype=np.bool_)
    short_entries = np.zeros(n, dtype=np.bool_)
    short_exits = np.zeros(n, dtype=np.bool_)

    if n < 14:
        return long_entries, long_exits, short_entries, short_exits

    highs = np.asarray(features.market.highs, dtype=np.float64)
    lows = np.asarray(features.market.lows, dtype=np.float64)
    closes = np.asarray(features.market.closes, dtype=np.float64)
    atr14 = np.asarray(features.atr(14), dtype=np.float64)

    pivot_lows = np.zeros(n, dtype=np.bool_)
    pivot_highs = np.zeros(n, dtype=np.bool_)
    for i in range(2, n):
        pivot = i - 1
        if (
            np.isfinite(lows[pivot])
            and np.isfinite(lows[pivot - 1])
            and np.isfinite(lows[i])
            and lows[pivot] <= lows[pivot - 1]
            and lows[pivot] <= lows[i]
        ):
            pivot_lows[pivot] = True
        if (
            np.isfinite(highs[pivot])
            and np.isfinite(highs[pivot - 1])
            and np.isfinite(highs[i])
            and highs[pivot] >= highs[pivot - 1]
            and highs[pivot] >= highs[i]
        ):
            pivot_highs[pivot] = True

    prior_low = -1
    latest_low = -1
    prior_high = -1
    latest_high = -1
    active_strike = np.nan
    entry_signal_bar = -1

    for i in range(2, n):
        confirmed_bar = i - 1
        if pivot_lows[confirmed_bar]:
            prior_low = latest_low
            latest_low = confirmed_bar
        if pivot_highs[confirmed_bar]:
            prior_high = latest_high
            latest_high = confirmed_bar

        exited_now = False
        if (
            np.isfinite(active_strike)
            and i > entry_signal_bar
            and np.isfinite(closes[i - 1])
            and np.isfinite(closes[i])
            and closes[i - 1] >= active_strike
            and closes[i] < active_strike
        ):
            long_exits[i] = True
            active_strike = np.nan
            entry_signal_bar = -1
            exited_now = True

        has_uptrend = (
            prior_low >= 0
            and latest_low >= 0
            and prior_high >= 0
            and latest_high >= 0
            and lows[latest_low] > lows[prior_low]
            and highs[latest_high] > highs[prior_high]
        )
        if (
            not exited_now
            and not np.isfinite(active_strike)
            and has_uptrend
            and pivot_lows[confirmed_bar]
            and latest_low == confirmed_bar
            and np.isfinite(lows[latest_low])
            and np.isfinite(closes[i])
            and np.isfinite(atr14[i])
            and atr14[i] > 0.0
        ):
            support = lows[latest_low]
            sell_put_strike = support - atr14[i]
            if (
                np.isfinite(sell_put_strike)
                and sell_put_strike > 0.0
                and closes[i] > support
                and closes[i] > sell_put_strike
            ):
                long_entries[i] = True
                active_strike = sell_put_strike
                entry_signal_bar = i

    return long_entries, long_exits, short_entries, short_exits

STRATEGY = {
    "strategy_id": "credit_spread_trend_support_atr",
    "hypothesis": "原文條件（READ L145-L151、L153-L173、L179-L183）：順著趨勢交易；Amazon 的上升趨勢以 higher high／higher low 描述，故採 bullish 方向並賣 put credit spread；以支撐／阻力的價格行為確認支撐被尊重，並用 14 日 ATR 在支撐下 1 ATR 設定賣出 put 參考位。形式化解讀：只用當下已完成 K 棒，以相鄰三根 K 棒確認局部 swing low／swing high；最新兩個 swing low 與 swing high 都抬高才算上升趨勢；新確認的 swing low 後，下一根收盤高於該支撐視為 bounce／respect；賣 put 參考位為 support - ATR(14)，因此用 framework 的 long 訊號表達其 bullish put-spread 方向。原文另提到接近到期且任一腿進入價內時關閉（READ L63-L66），但沒有可計算的接近期限或選擇權腿資料；L12-L13、L174-L180 的 30／32 日、5 點寬度與信用金額是示例／合約設定，不作未公開的訊號或風控選值。推導出場：進場核心要求價格在同一賣 put 參考位上方，故以同一筆進場時凍結的 support - ATR(14) 作參考，收盤由上向下跌破該值時發出 long_exit；這只鏡像價格方向，不把上升趨勢資格搬到出場、不取整體條件 NOT，也不開反向空倉。",
    "position": "long",
    "generate_signals": generate_signals,
    "signal_parameter_names": [],
    "signal_parameter_sets": [{}],
}