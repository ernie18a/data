import numpy as np

def generate_signals(features, signal_params):
    size = features.market.size
    closes = features.market.closes
    mean_200 = features.sma(200)
    std_200 = features.std(200)
    lower_band = mean_200 - 3.8 * std_200

    valid = (
        np.isfinite(closes)
        & np.isfinite(mean_200)
        & np.isfinite(std_200)
        & np.isfinite(lower_band)
    )
    valid_pair = np.zeros(size, dtype=np.bool_)
    valid_pair[1:] = valid[1:] & valid[:-1]

    cross_down = np.zeros(size, dtype=np.bool_)
    cross_down[1:] = (
        valid_pair[1:]
        & (closes[1:] < lower_band[1:])
        & (closes[:-1] >= lower_band[:-1])
    )

    cross_up = np.zeros(size, dtype=np.bool_)
    cross_up[1:] = (
        valid_pair[1:]
        & (closes[1:] > lower_band[1:])
        & (closes[:-1] <= lower_band[:-1])
    )

    prior_down_break = np.zeros(size, dtype=np.bool_)
    prior_down_break[1:] = np.cumsum(cross_down[:-1]) > 0

    long_entries = cross_up & prior_down_break
    long_exits = cross_down
    short_entries = np.zeros(size, dtype=np.bool_)
    short_exits = np.zeros(size, dtype=np.bool_)
    return long_entries, long_exits, short_entries, short_exits

STRATEGY = {
    "strategy_id": "winning-whale-dip-recovery-put-credit",
    "hypothesis": "strategy_scope=directional。來源商品背景：原始商品為偏多 put credit spread，賣出約收盤價×0.96、四捨五入的 put，買入下一檔較低履約價，寬度 $1，14 日後向上取至下一個週五到期，至少收取 $0.15 權利金。實際回測範圍：僅實作方向核心；收盤價先向下突破 B[t]=200-day SMA[t]-3.8×200-day close standard deviation[t]，其後向上突破並收於 B 上方時建立 long。entry_rules=已知方向條件：價格先向下突破「200-day moving average 下方 3.8 standard deviations」下黃線；在已位於該線下方後，價格再向上突破並收於該線上方時建立 long 方向訊號。exit_rules=long：role=\"invalidate\"；inputs=C 與 B；trigger=cross_down(C,B)[t]，即 C[t]<B[t] 且 C[t-1]>=B[t-1]；200 日必要資料未完成或任一必要輸入為 NaN 時為 false；mode=close；action=exit_all；第 t 根收盤形成訊號，於第 t+1 根 open 全數平倉。exit_origin=sop。推導出場：exit_derivation=命中 SOP 4 單序列狀態失效；持倉有利狀態為 C>B，故以同一 200-day 與 3.8 standard deviations 基準的 cross_down(C,B) 失效出場；先跌破後收復僅為 entry 資格與事件順序，不另引入持倉狀態。position=long。source_evidence=READ L344-L349：跌破 200 日均線下方 3.8 個標準差後，再突破並收於該線上方即為 dip-buy entry；L351-L357：0.96 put spread；L361-L363：14 日並取下一個週五。",
    "position": "long",
    "generate_signals": generate_signals,
    "signal_parameter_names": [],
    "signal_parameter_sets": [{}],
}