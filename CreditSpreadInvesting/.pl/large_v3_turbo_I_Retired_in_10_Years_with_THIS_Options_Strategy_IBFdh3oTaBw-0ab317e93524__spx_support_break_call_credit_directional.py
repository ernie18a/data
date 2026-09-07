import numpy as np


def generate_signals(features, signal_params):
    size = features.market.size
    closes = np.asarray(features.market.closes, dtype=np.float64)

    long_entries = np.zeros(size, dtype=np.bool_)
    long_exits = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    short_exits = np.zeros(size, dtype=np.bool_)

    support_level = 4530.0
    valid = np.isfinite(closes)
    short_entries[:] = valid & (closes < support_level)

    if size > 1:
        short_exits[1:] = (
            valid[1:]
            & valid[:-1]
            & (closes[1:] > support_level)
            & (closes[:-1] <= support_level)
        )

    return long_entries, long_exits, short_entries, short_exits


STRATEGY = {
    'strategy_id': 'spx_support_break_call_credit_directional',
    'hypothesis': (
        'strategy_scope=directional; '
        'source_product_background=來源為SPX日線案例，採30至45 DTE call credit spread，'
        '案例腿位為4610/4615、到期日8/31、每組收取$180、$500保證金、四組；'
        '來源前支撐或價值區S約為4530，另提約4630作為提前平倉背景; '
        'actual_backtest_scope=僅使用FRAMEWORK提供的MarketData收盤序列回測SPX方向性short，'
        '訊號於第t根收盤形成並由FRAMEWORK於第t+1根open成交，不模擬選擇權腿、DTE、'
        '權利金、保證金、delta、ATR停損或選擇權損益，也不新增日線重採樣; '
        'execution_context=來源以技術分析而非delta進場，本模組只抽取SPX下行方向核心; '
        'entry_rules=以READ案例已給的S約4530作固定價格邊界，對有限收盤價C實作C<S的空方資格；'
        '人工辨識S與非常令人信服的跌破未定義演算法，因此不新增回看窗口、幅度、成交量、'
        'K線型態、ATR或連續期數條件; '
        'exit_rules=short role=invalidate，對有限C與S實作cross_up(C,S)，即C[t]>S且C[t-1]<=S，'
        '於第t根收盤形成並於第t+1根open全數平倉; '
        'exit_origin=sop; '
        'exit_derivation=SOP 2價格突破失敗，沿用entry的C與S，無新增窗口或參數，將不利方向的'
        '邊界失守反轉為cross_up(C,S); '
        'position=short; '
        'source_evidence=READ行56-79：4530為前支撐，收盤明確跌破後建立4610/4615 call credit spread；'
        '行8-16及56-58說明30至45 DTE與商品背景。'
    ),
    'position': 'short',
    'generate_signals': generate_signals,
    'signal_parameter_names': [],
    'signal_parameter_sets': [{}],
}
