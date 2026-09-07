import numpy as np


def generate_signals(features, signal_params):
    market = features.market
    n = market.size
    long_entries = np.zeros(n, dtype=np.bool_)
    long_exits = np.zeros(n, dtype=np.bool_)
    short_entries = np.zeros(n, dtype=np.bool_)
    short_exits = np.zeros(n, dtype=np.bool_)

    opens = market.opens
    highs = market.highs
    lows = market.lows
    closes = market.closes
    support_level = 5780.0

    valid_ohlc = (
        np.isfinite(opens)
        & np.isfinite(highs)
        & np.isfinite(lows)
        & np.isfinite(closes)
        & (highs >= lows)
    )
    body = np.abs(closes - opens)
    lower_wick = np.minimum(opens, closes) - lows
    upper_wick = highs - np.maximum(opens, closes)
    hammer = (
        valid_ohlc
        & (body > 0.0)
        & (lower_wick >= 2.0 * body)
        & (upper_wick <= body)
    )
    support_touch = valid_ohlc & (lows <= support_level) & (highs >= support_level)

    source_long_uptrend = np.ones(n, dtype=np.bool_)

    if n > 1:
        prior_valid = valid_ohlc[:-1]
        breakout_valid = valid_ohlc[1:] & np.isfinite(highs[:-1])
        long_entries[1:] = (
            source_long_uptrend[1:]
            & hammer[:-1]
            & support_touch[:-1]
            & prior_valid
            & breakout_valid
            & (closes[1:] > highs[:-1])
        )

    active = False
    entry_breakout_level = np.nan
    for t in range(1, n):
        exited = False
        if active:
            if (
                np.isfinite(entry_breakout_level)
                and np.isfinite(closes[t])
                and np.isfinite(closes[t - 1])
                and closes[t] < entry_breakout_level
                and closes[t - 1] >= entry_breakout_level
            ):
                long_exits[t] = True
                active = False
                entry_breakout_level = np.nan
                exited = True
        if not active and not exited and long_entries[t]:
            entry_breakout_level = highs[t - 1]
            active = np.isfinite(entry_breakout_level)
            if not active:
                long_entries[t] = False

    return long_entries, long_exits, short_entries, short_exits


STRATEGY = {
    'strategy_id': 'spx_put_credit_spread_support_bounce',
    'hypothesis': 'strategy_scope：directional。execution_context：來源以 SPX 0DTE put credit spread 表達偏多觀點：賣出 5775 put、買入 5770 put，寬度 5 點，交易 6 組，每組收取 155 美元權利金；預期 SPX 上漲，並以選擇權到期損益管理。此記錄僅回測 SPX 的方向性 long 訊號，不回測選擇權履約價、權利金、到期、組數或指派。entry_rules：已確定的方向核心：在來源判定為長期上升趨勢、價格進入人工辨識的支撐區後，30 分鐘圖出現 hammer；等待下一根 30 分鐘 K 棒形成，當該 K 棒向上突破前一根 K 棒高點時建立 long SPX 方向部位。示例中前一根高點為 5777，支撐約為 5780。exit_rules：long：role="invalidate"；inputs：C=entry_rules 使用的 30 分鐘收盤價序列，H=entry_rules 中 30 分鐘 K 棒高價序列，B=H[t_e-1]，其中 t_e 為建立 long 的突破訊號 K 棒，B 即 entry_rules 的「前一根 K 棒高點」（示例為 5777）；state：B_entry=B；update：於 t_e 收盤完成並確認 entry 訊號時，以已完成前一根 K 棒高價設定 B_entry，其後持倉期間保持不變；trigger：cross_down(C,B_entry)[t] := C[t] < B_entry && C[t-1] >= B_entry；mode="close"；action="exit_all"；訊號於第 t 根 30 分鐘 K 棒收盤後形成，於第 t+1 根 open 將 long 全數平倉；warm-up、NaN 或 B_entry 不可用時 trigger=false。exit_origin：sop。exit_derivation：唯一命中 SOP 2（價格突破失敗）：entry 的 long 方向是在下一根 30 分鐘 K 棒向上突破前一根 K 棒高點 B 時建立；B 沿用該前一根高價 H[t_e-1]，不重新辨識支撐、hammer 或趨勢。故突破後收盤價 C 自 B 上方或等於 B 回落至 B 下方時，以 cross_down(C,B_entry) 判定突破失敗。長期上升趨勢、支撐區與 hammer 保持 entry 資格條件，不納入 exit trigger。position：long。source_evidence：第 32–40 行：長期趨勢被描述為上升、30 分鐘趨勢為盤整。第 43–50 行：人工繪製約 5770/5775 與 5820 支撐。第 64–80 行：價格進入約 5780 支撐後，11:00 出現 hammer，等待 11:30 的下一根 30 分鐘 K 棒突破前一根高點 5777 時進場。第 82–86 行：以 5775/5770 的 put credit spread 執行。第 84–90 行：止損設於形成 K 棒下方、例示約 5770。scope_boundary：來源商品背景為 SPX 0DTE put credit spread；實際回測範圍僅為 SPX 方向性 long 訊號；出場採 SOP 推導的突破失敗，不採用來源敘述的 K 棒下方止損。',
    'position': 'long',
    'generate_signals': generate_signals,
    'signal_parameter_names': [],
    'signal_parameter_sets': [{}],
}