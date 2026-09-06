import numpy as np

def generate_signals(features, signal_params):
    n = int(features.market.size)
    long_entries = np.zeros(n, dtype=np.bool_)
    long_exits = np.zeros(n, dtype=np.bool_)
    short_entries = np.zeros(n, dtype=np.bool_)
    short_exits = np.zeros(n, dtype=np.bool_)
    if n == 0:
        return long_entries, long_exits, short_entries, short_exits
    market = features.market
    opens = np.asarray(market.opens, dtype=np.float64)
    highs = np.asarray(market.highs, dtype=np.float64)
    lows = np.asarray(market.lows, dtype=np.float64)
    closes = np.asarray(market.closes, dtype=np.float64)
    atr = np.asarray(features.atr(14), dtype=np.float64)
    support = np.nan
    resistance = np.nan
    bounce_support = np.nan
    bounce_bar = -1
    short_open = False
    long_open = False
    short_stop = np.nan
    long_stop = np.nan
    for i in range(n):
        exited = False
        if short_open and np.isfinite(short_stop) and np.isfinite(highs[i]) and highs[i] >= short_stop:
            short_exits[i] = True
            short_open = False
            exited = True
        if long_open and np.isfinite(long_stop) and np.isfinite(lows[i]) and lows[i] <= long_stop:
            long_exits[i] = True
            long_open = False
            exited = True
        if i >= 2:
            if (np.isfinite(lows[i - 2]) and np.isfinite(lows[i - 1]) and np.isfinite(lows[i]) and lows[i - 1] <= lows[i - 2] and lows[i - 1] <= lows[i]):
                new_support = lows[i - 1]
                if not np.isfinite(support) or new_support != support:
                    support = new_support
                    bounce_support = np.nan
                    bounce_bar = -1
            if (np.isfinite(highs[i - 2]) and np.isfinite(highs[i - 1]) and np.isfinite(highs[i]) and highs[i - 1] >= highs[i - 2] and highs[i - 1] >= highs[i]):
                resistance = highs[i - 1]
        if bounce_bar >= 0 and bounce_bar < i - 1:
            bounce_support = np.nan
            bounce_bar = -1
        short_setup = False
        if i >= 1 and np.isfinite(support) and np.isfinite(resistance) and np.isfinite(atr[i]) and atr[i] > 0.0 and np.isfinite(closes[i - 1]) and np.isfinite(closes[i]) and closes[i - 1] >= support and closes[i] < support:
            short_setup = True
        long_setup = (bounce_bar == i - 1 and np.isfinite(support) and np.isfinite(bounce_support) and bounce_support == support and np.isfinite(opens[i - 1]) and np.isfinite(opens[i]) and np.isfinite(closes[i - 1]) and np.isfinite(closes[i]) and opens[i] > opens[i - 1] and closes[i] > closes[i - 1] and closes[i] > opens[i] and np.isfinite(atr[i]) and atr[i] > 0.0 and np.isfinite(lows[i - 1]))
        if not exited:
            if short_setup:
                short_entries[i] = True
                short_open = True
                short_stop = resistance + atr[i]
            elif long_setup:
                long_entries[i] = True
                long_open = True
                long_stop = lows[i - 1] - 0.5 * atr[i]
        if np.isfinite(support) and np.isfinite(lows[i]) and np.isfinite(opens[i]) and np.isfinite(closes[i]) and lows[i] <= support and closes[i] > support and closes[i] > opens[i]:
            bounce_support = support
            bounce_bar = i
    return long_entries, long_exits, short_entries, short_exits

STRATEGY = {
    'strategy_id': 'support_structure_credit_spread',
    'hypothesis': '原文條件（READ 第43-53、65-73、74-79、82-94行）：先理解上、下或盤整趨勢，在曾被測試的前支撐價值區，收盤有效跌破時做 bear-side call credit spread；由該區反彈時，第一根綠K不足，等待下一根開高、收高的強綠K後做 bullish put credit spread。原文出場是 bear trade 在前高上方約1 ATR失效時出場、bull trade 在前一日下方約0.5 ATR失效時出場。原文沒有趨勢的獨立數值判定，因此形式化時不新增代理趨勢濾網，方向由明示的跌破／反彈事件決定。形式化解讀：將最近確認的三棒局部低點作為可計算的前支撐測試點、最近確認的三棒局部高點作為前高；跌破定義為收盤由支撐上方或等於穿到下方；反彈候選定義為觸及支撐、收盤仍在支撐上方且為綠K，下一棒須開盤及收盤都高於候選棒且自身為綠K。ATR 使用 FRAMEWORK 可用的14期 ATR，非有限或非正值時抑制訊號。出場保留並按方向映射：選擇權 bear call 對應 short，short 的 entry-time 前高加1 ATR被當根 high 觸及；bull put 對應 long，long 的 entry-time 前一棒 low減0.5 ATR被當根 low 觸及。這不是整體條件取反，也沒有新增反向開倉。選擇權的30-45 DTE、權利金及到期結算沒有對應的 FRAMEWORK 欄位，未虛構價格或到期訊號。三棒／兩棒窗口不足時不發相關訊號。',
    'position': 'both',
    'generate_signals': generate_signals,
    'signal_parameter_names': [],
    'signal_parameter_sets': [{}],
}