import numpy as np


def generate_signals(features, signal_params):
    size = features.market.size
    closes = np.asarray(features.market.closes, dtype=np.float64)
    support_level = 4530.0

    long_entries = np.zeros(size, dtype=np.bool_)
    long_exits = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    short_exits = np.zeros(size, dtype=np.bool_)

    valid_close = np.isfinite(closes)
    short_entries[:] = valid_close & (closes < support_level)
    if size > 1:
        valid_cross = valid_close[1:] & valid_close[:-1]
        short_exits[1:] = (
            valid_cross
            & (closes[1:] > support_level)
            & (closes[:-1] <= support_level)
        )

    return long_entries, long_exits, short_entries, short_exits


STRATEGY = {
    "strategy_id": "spx_support_break_call_credit_directional",
    "hypothesis": """{\"strategy_scope\": \"directional\", \"execution_context\": \"來源商品背景：SPX 30–45 DTE call credit spread；案例為賣出 4610 call、買入 4615 call、約 30 日後於 8/31 到期，每組收取 $180 權利金、寬度／保證金 $500、共四組。來源以先前高點 4607 上方約一個 ATR 的約 4630 作商品風險停損，並稱可於最大損失前出場。實際回測範圍：僅回測標的的偏空方向核心，不回測選擇權權利金、到期、履約、腿部或部位數。\", \"entry_rules\": \"偏空方向核心：在日線上，價格對預先辨識的先前支撐 L 出現「convincing」跌破，且當日收盤 C_t < L 時建立 short。來源案例 L 約為 4530，並稱 A2 已明確跌破且收在其下。實作固定 L=4530，僅在收盤有限且 C_t < L 時產生 short entry。\", \"exit_rules\": \"short：role=`invalidate`；inputs=`C`（entry_rules 使用的日線收盤價序列）、`L`（entry_rules 中預先辨識的先前支撐）；state=`none`；update=`none`；trigger=`cross_up(C,L)[t] := C[t] > L && C[t-1] <= L`；第 t 根收盤完成後形成訊號，於第 t+1 根 open 全數平倉；mode=`close`；action=`exit_all`。warm-up、NaN 或必要輸入不可用時 trigger=false。\", \"exit_origin\": \"sop\", \"exit_derivation\": \"推導出場：命中 SOP 2「價格突破失敗」；entry 的偏空方向為收盤 C 跌破既存價格邊界 L（C<L）；故出場沿用相同操作數與邊界，在 C 自下向上穿越 L 時以 `cross_up(C,L)` 使偏空突破假說失效。未引入 ATR、先前高點或任何新窗口、參數、持倉狀態。\", \"position\": \"short\", \"source_evidence\": \"READ 第 56–80 行：日線圖、先前支撐約 4530；「convincing break of structure」後進 bear-side call credit spread；A2 收盤跌破；先前高點 4607 上方約一 ATR、約 4630 為停損。\"}""",
    "position": "short",
    "generate_signals": generate_signals,
    "signal_parameter_names": [],
    "signal_parameter_sets": [{}],
}
