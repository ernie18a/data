import numpy as np


def generate_signals(features, signal_params):
    size = features.market.size
    long_entries = np.zeros(size, dtype=np.bool_)
    long_exits = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    short_exits = np.zeros(size, dtype=np.bool_)
    return long_entries, long_exits, short_entries, short_exits


STRATEGY = {
    "strategy_id": "social_sentiment_daily_qcut_long_short",
    "hypothesis": """{\"strategy_scope\":\"directional\",\"execution_context\":\"來源為每日股票橫斷面多空投組：在來源所選的大型股股票池內，做多情緒最高四分位、做空情緒最低四分位；未指定權重、槓桿、個別標的部位上限或再平衡成交方式。本記錄僅保留其方向核心，不將其轉換為單一 TX 行情的商品策略。\",\"entry_rules\":\"每個交易日 d：在當日來源股票池中，先將每檔股票 d 日的 StockTwits 社群情緒觀測彙整為該股票的日情緒值；對全股票池的日情緒值做 N=4 的橫斷面 Q cut。進入多頭：股票落入最高情緒四分位。進入空頭：股票落入最低情緒四分位。中間兩個四分位不持倉。\",\"exit_rules\":{\"long\":{\"role\":\"invalidate\",\"inputs\":\"S_i[t]=股票 i 於 t 日的日情緒值；U_t=當日來源股票池；Q_i[t]=qcut_4({S_j[t] | j∈U_t}) 對股票 i 指派的由低至高四分位 bucket，N=4\",\"state\":\"none\",\"update\":\"none\",\"trigger\":\"cross_down(Q_i,4)[t]\",\"mode\":\"close\",\"action\":\"exit_all\",\"execution\":\"第 t 根收盤形成訊號，於第 t+1 根 open 全數平多倉\"},\"short\":{\"role\":\"invalidate\",\"inputs\":\"S_i[t]=股票 i 於 t 日的日情緒值；U_t=當日來源股票池；Q_i[t]=qcut_4({S_j[t] | j∈U_t}) 對股票 i 指派的由低至高四分位 bucket，N=4\",\"state\":\"none\",\"update\":\"none\",\"trigger\":\"cross_up(Q_i,1)[t]\",\"mode\":\"close\",\"action\":\"exit_all\",\"execution\":\"第 t 根收盤形成訊號，於第 t+1 根 open 全數平空倉\"}},\"exit_origin\":\"sop\",\"exit_derivation\":\"命中 SOP 4（單序列狀態失效）。entry 的既有 N=4 橫斷面 qcut 產生 Q_i[t]：多方有利狀態為 Q_i[t]=4，等價於 Q_i[t]>=4，因此以 cross_down(Q_i,4) 偵測離開最高四分位；空方有利狀態為 Q_i[t]=1，等價於 Q_i[t]<=1，因此以 cross_up(Q_i,1) 偵測離開最低四分位。沿用相同股票日情緒值、當日股票池、N=4 與日頻事件順序。\",\"position\":\"both\",\"source_evidence\":\"READ 第150–155行：每日對情緒做 Q cut 並按 bucket 計算日報酬；第167–171行：「every day long the top bucket and short the bottom bucket」、「Q cut」、「long the top quartile ... short the bottom quartile」；第164–166、173–174行明示資料為 contemporaneous、不可交易。\",\"source_product_context\":\"來源商品背景為每日大型股股票池的 StockTwits 橫斷面情緒多空投組。\",\"actual_backtest_scope\":\"FRAMEWORK 的 FeatureStore 僅提供單一 MarketData 行情序列，未提供當日股票池、逐股 StockTwits 日情緒值或橫斷面資料；因此無法忠實形成 Q_i[t]，本模組不將來源策略轉換為單一行情商品策略，所有訊號均為 False。\",\"derived_exit\":\"出場為 SOP 推導；其原子條件須依同一股票池的 Q_i[t] 計算，現有單一行情執行範圍不具備該資料。\"}""",
    "position": "both",
    "generate_signals": generate_signals,
    "signal_parameter_names": [],
    "signal_parameter_sets": [{}]
}