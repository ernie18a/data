import numpy as np

def generate_signals(features, signal_params):
    _ = signal_params
    market = features.market
    n = market.size
    long_entries = np.zeros(n, dtype=np.bool_)
    long_exits = np.zeros(n, dtype=np.bool_)
    short_entries = np.zeros(n, dtype=np.bool_)
    short_exits = np.zeros(n, dtype=np.bool_)
    if n == 0:
        return long_entries, long_exits, short_entries, short_exits
    sma20 = features.sma(20)
    valid = np.isfinite(sma20)
    if n >= 3:
        bearish_engulfing = (market.closes[1:-1] > market.opens[1:-1])
        bearish_engulfing &= market.closes[2:] < market.opens[2:]
        bearish_engulfing &= market.opens[2:] >= market.closes[1:-1]
        bearish_engulfing &= market.closes[2:] <= market.opens[1:-1]
        bearish_engulfing &= market.closes[1:-1] > market.closes[:-2]
        short_entries[2:] = bearish_engulfing & valid[2:]
    if n >= 1:
        short_exits = valid & (market.lows <= sma20)
    return long_entries, long_exits, short_entries, short_exits

STRATEGY = {'strategy_id': 'bearish_engulfing_call_credit_spread', 'hypothesis': '原文條件（READ 行 858-864）：市場先上行後出現 bearish engulfing，於 call side 進場做空；價格下跌觸及作為支撐的 20 期移動平均時出場。形式化解讀：前一根為陽線、當根為陰線，當根實體以 open >= 前一根 close 且 close <= 前一根 open 完整包覆前一根實體，並要求前一根 close > 再前一根 close 表示先上行；形態完成且 SMA20 有效時發出 short entry。原文的 get out when it gets to 4,000／3,500 是圖例價位，通用且可定位的出場依上下文採 20 期均線支撐，當 low <= SMA20 時 short exit；訊號在形態 K 線收盤後產生，依 FRAMEWORK 下一根開盤成交。', 'position': 'short', 'generate_signals': generate_signals, 'signal_parameter_names': [], 'signal_parameter_sets': [{}]}
