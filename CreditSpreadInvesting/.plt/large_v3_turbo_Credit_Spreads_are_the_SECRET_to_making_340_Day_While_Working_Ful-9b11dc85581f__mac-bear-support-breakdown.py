import numpy as np


def generate_signals(features, signal_params):
    market = features.market
    size = market.size
    opens = np.asarray(market.opens, dtype=np.float64)
    highs = np.asarray(market.highs, dtype=np.float64)
    lows = np.asarray(market.lows, dtype=np.float64)
    closes = np.asarray(market.closes, dtype=np.float64)

    long_entries = np.zeros(size, dtype=np.bool_)
    long_exits = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    short_exits = np.zeros(size, dtype=np.bool_)

    support = 44.37
    valid_ohlc = (
        np.isfinite(opens)
        & np.isfinite(highs)
        & np.isfinite(lows)
        & np.isfinite(closes)
    )

    if size > 1:
        valid_pair = valid_ohlc[1:] & valid_ohlc[:-1]
        structural_breakdown = closes[1:] < support
        higher_low = lows[1:] > lows[:-1]
        strong_bearish_engulfing = (
            (closes[:-1] > opens[:-1])
            & (closes[1:] < opens[1:])
            & (opens[1:] > closes[:-1])
            & (closes[1:] < opens[:-1])
        )

        short_entries[1:] = (
            valid_pair
            & structural_breakdown
            & (higher_low | strong_bearish_engulfing)
        )
        short_exits[1:] = (
            valid_pair
            & (closes[1:] > support)
            & (closes[:-1] <= support)
        )

    return long_entries, long_exits, short_entries, short_exits


STRATEGY = {
    "strategy_id": "mac-bear-support-breakdown",
    "hypothesis": "strategy_scope=directional；execution_context=來源以 SPX bear call credit spread 表達偏空觀點；bear call spread 的商品語意為賣出 call、買入較高履約價 call，標的下跌時有利。未指定本假說的履約價、到期日、權利金或部位大小。方向回測僅測試標的偏空訊號。來源商品背景為 SPX bear call credit spread，而非標的現貨或期貨的履約價、到期日、權利金或部位大小規則；實際回測範圍僅為標的的方向性 short 訊號；FRAMEWORK 於訊號後下一根 open 執行。entry_rules=偏空候選：價格跌破人工標示為前支撐的 44.37 後，在出現大幅結構跌破，且出現阻力／弱勢訊號時進場；來源列舉的弱勢訊號包括 higher low 或強勢 bearish engulfing candlestick。實作為 C[t] < 44.37 AND (L[t] > L[t-1] OR (C[t-1] > O[t-1] AND C[t] < O[t] AND O[t] > C[t-1] AND C[t] < O[t-1]))。exit_rules=short: role=invalidate; inputs=C,B=44.37; state=none; update=none; trigger=cross_up(C,B)[t] := C[t] > B && C[t-1] <= B; mode=close; action=exit_all。exit_origin=sop。exit_derivation=命中 SOP 2（價格突破失敗）：entry 的空方條件為價格跌破既存前支撐 B=44.37；沿用同一價格序列 C 與邊界 B，當 C 自下向上重越 B 時，於該根收盤形成空方失效訊號，下一根 open 全數平倉。derived_exit=short_exits[t] = C[t] > 44.37 AND C[t-1] <= 44.37；此為 SOP 推導出場，不是來源指定的選擇權履約或到期規則。position=short。source_evidence=READ 第77–90行：「if it ever breaks below this 44.37 level, which is the previous support, then we could trade in a bear direction」；要求「large break」、「some resistance or some form of weakness」、「higher low or very strong bearish engulfing candlestick」。",
    "position": "short",
    "generate_signals": generate_signals,
    "signal_parameter_names": [],
    "signal_parameter_sets": [{}],
}