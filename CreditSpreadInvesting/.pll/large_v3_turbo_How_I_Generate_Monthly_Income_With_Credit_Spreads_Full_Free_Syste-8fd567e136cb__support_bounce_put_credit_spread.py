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
    sma50 = features.sma(50)
    sma200 = features.sma(200)
    valid = np.isfinite(sma20) & np.isfinite(sma50) & np.isfinite(sma200)
    if n >= 2:
        rising = valid[1:] & valid[:-1]
        rising &= sma20[1:] > sma20[:-1]
        rising &= sma50[1:] > sma50[:-1]
        rising &= sma200[1:] > sma200[:-1]
        long_entries[1:] = rising & (market.lows[1:] <= sma200[1:]) & (market.closes[1:] > sma200[1:])
        long_exits[1:] = (valid[1:] & valid[:-1] & (market.highs[1:] >= sma200[1:]) & (market.closes[1:] < sma200[1:]))
    return long_entries, long_exits, short_entries, short_exits

STRATEGY = {'strategy_id': 'support_bounce_put_credit_spread', 'hypothesis': '原文條件（READ 行 668-686、930-958）：以動能與可預測的上升走勢交易上行，價格落入並反彈離開 200 期均線支撐；同段補充 20、50、200 期均線斜率向上，並描述反彈後持續賣 put credit spread。形式化解讀：資料足夠且 20、50、200 SMA 當期與前一期有效、三者均上升時，若當期 low <= SMA200 且 close > SMA200，發出 long entry。原文另有以期權權利金為基準的 50% stop，但 FRAMEWORK 沒有期權權利金序列；推導出場因此只鏡像反彈核心，當 high >= SMA200 且 close < SMA200 時 long exit，未把入場斜率資格移入出場。訊號在反彈 K 線收盤後產生，依 FRAMEWORK 下一根開盤成交。', 'position': 'long', 'generate_signals': generate_signals, 'signal_parameter_names': [], 'signal_parameter_sets': [{}]}
