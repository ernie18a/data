import numpy as np

def generate_signals(features, signal_params):
    market = features.market
    n = market.size
    highs = np.asarray(market.highs, dtype=np.float64)
    lows = np.asarray(market.lows, dtype=np.float64)
    closes = np.asarray(market.closes, dtype=np.float64)

    long_entries = np.zeros(n, dtype=np.bool_)
    long_exits = np.zeros(n, dtype=np.bool_)
    short_entries = np.zeros(n, dtype=np.bool_)
    short_exits = np.zeros(n, dtype=np.bool_)

    previous_high = np.nan
    previous_support = np.nan
    latest_pivot_low = np.nan
    resistance = np.nan
    candidate_support = np.nan
    active_support = np.nan

    for t in range(2, n):
        if not (
            np.isfinite(highs[t - 2])
            and np.isfinite(highs[t - 1])
            and np.isfinite(highs[t])
            and np.isfinite(lows[t - 2])
            and np.isfinite(lows[t - 1])
            and np.isfinite(lows[t])
            and np.isfinite(closes[t - 1])
            and np.isfinite(closes[t])
        ):
            continue

        if np.isfinite(active_support):
            if closes[t] > active_support and closes[t - 1] <= active_support:
                short_exits[t] = True
                active_support = np.nan
            continue

        pivot_low = lows[t - 1] < lows[t - 2] and lows[t - 1] <= lows[t]
        pivot_high = highs[t - 1] > highs[t - 2] and highs[t - 1] >= highs[t]

        if pivot_low:
            latest_pivot_low = lows[t - 1]

        if not pivot_high:
            continue

        lower_high = False
        if np.isfinite(previous_high) and np.isfinite(previous_support):
            if (
                np.isfinite(latest_pivot_low)
                and highs[t - 1] > previous_high
                and latest_pivot_low > previous_support
            ):
                resistance = highs[t - 1]
                candidate_support = latest_pivot_low
            elif (
                np.isfinite(resistance)
                and np.isfinite(candidate_support)
                and highs[t - 1] < resistance
            ):
                lower_high = True

        previous_high = highs[t - 1]
        previous_support = latest_pivot_low

        if (
            lower_high
            and closes[t] < candidate_support
            and closes[t - 1] >= candidate_support
        ):
            short_entries[t] = True
            active_support = candidate_support

    return long_entries, long_exits, short_entries, short_exits


STRATEGY = {
    "strategy_id": "credit_spread_resistance_reversal",
    "hypothesis": "strategy_scope: directional\n來源商品背景與 execution_context: 原始交易是在阻力區附近建立 bear call credit spread；文稿稱中午賣出 45.70/45.75 的 at-the-money call credit spread、收取 $290，後以 $140 買回獲利 $150，並提及進場後 5 至 10 分鐘、接近收盤時平倉及 $100 選擇權停損。\n實際回測範圍: 僅回測 FRAMEWORK 行情序列上的標的偏空反轉方向；不回測 call 腿、權利金、到期、買回、選擇權停損或 iron condor 組合部位。來源規則使用 5 分鐘週期，訊號由 FRAMEWORK 提供的已完成 K 棒序列計算。\nentry_rules: 價格在原上升結構形成的阻力後形成 lower high，且其後一根 K 棒跌破既有結構支撐 B 並收於 B 下方時偏空進場；不以第一個疲弱訊號進場，須等待結構破壞。程式以已確認的局部高低點辨識較高高點／較高低點結構，將該結構高點作阻力、較高低點作 B，並以後續較低的已確認局部高點作 lower high。\nexit_rules: short: role=\"invalidate\"; inputs=\"C, B=原上升結構的支撐\"; state=\"none\"; update=\"none\"; trigger=\"cross_up(C,B)\"; mode=\"close\"; action=\"exit_all\"。\nexit_origin: sop\nexit_derivation: 命中 SOP 2（價格突破失敗）；偏空 entry 使用既有結構支撐 B，於 C 跌破且 C<B 時進場；退出沿用同一 B，當 C[t] > B[t] 且 C[t-1] <= B[t-1] 時產生出場訊號，由 FRAMEWORK 於下一根 open 全數平倉。\nposition: short\nsource_evidence: [567.62s→618.56s] 定義阻力約 45.80，進入阻力區且 C 條件成立時可 trade down；[647.80s→653.14s] 反轉可尋找 lower high 或 break of structure；[829.68s→855.10s] lower high 後，等待蠟燭跌破並收於支撐下方才進場；[858.70s→886.08s] 5–10 分鐘後平倉，未如預期以 $100 停損。",
    "position": "short",
    "generate_signals": generate_signals,
    "signal_parameter_names": [],
    "signal_parameter_sets": [{}],
}