import numpy as np


def generate_signals(features, signal_params):
    size = features.market.size
    long_entries = np.zeros(size, dtype=np.bool_)
    long_exits = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    short_exits = np.zeros(size, dtype=np.bool_)
    return long_entries, long_exits, short_entries, short_exits


STRATEGY = {
    "strategy_id": "spx_support_hammer_break_long",
    "hypothesis": '{"strategy_scope":"directional","execution_context":"1.1. 原始執行為 SPX 0-DTE put credit spread；示例賣出 5775 put、買入 5770 put，5 點價差，六組，每組收取 155 美元權利金。來源以 SPX 上漲／守住支撐的方向假說承載此偏多曝險；本記錄僅回測 SPX 的 long 方向訊號，不回測選擇權權利金、到期、履約、指派或價差損益。","entry_rules":"1.3. 已確定核心：在長期趨勢向上且價格進入支撐區後，出現 hammer；下一根 30 分鐘 K 線向上突破該 hammer 的最高價時建立 SPX long。示例的支撐約為 5780、hammer 高點為 5777。未解條件：長期上升趨勢的可計算定義、支撐區的產生規則與寬度、hammer 的 OHLC 公式、支撐觸及與 hammer／突破的精確事件順序、30 分鐘時鐘相位；FRAMEWORK 未載入時間戳，無法表達來源的 11:00／11:30 條件。","exit_rules":"long: role=invalidate; inputs={C=entry 使用的 SPX 30 分鐘收盤價序列; B=進場所用 hammer K 線最高價}; state=none; update=none; trigger=cross_down(C,B)[t] := C[t] < B[t] && C[t-1] >= B[t-1]; mode=close; action=exit_all","exit_origin":"sop","exit_derivation":"唯一命中 SOP 2（價格突破失敗）。entry 的多方操作為 C 向上突破既存價格邊界 B，且 B=該 hammer 的最高價；exit 沿用相同 C、B、30 分鐘收盤窗口與既有事件順序，將 entry 的突破布林結構反向為 cross_down(C,B)。無新增參數；第 t 根收盤形成訊號，第 t+1 根 open 全數平倉。","position":"long","source_evidence":"1.2. READ 行 64-80：偏多方向、價格進入約 5780 支撐、11:00 hammer、等待下一根 11:30 K，突破前一根高點 5777 進場。READ 行 84-91：30 分鐘圖上，停損設在形成 K 線下方；示例為 5770。"}',
    "position": "long",
    "generate_signals": generate_signals,
    "signal_parameter_names": [],
    "signal_parameter_sets": [{}]
}
