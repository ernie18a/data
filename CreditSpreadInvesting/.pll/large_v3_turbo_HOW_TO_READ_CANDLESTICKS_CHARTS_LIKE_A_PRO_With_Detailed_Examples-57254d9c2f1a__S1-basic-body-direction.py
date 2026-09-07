import numpy as np

def generate_signals(features, signal_params):
    market = features.market
    size = market.size
    opens = np.asarray(market.opens)
    closes = np.asarray(market.closes)
    valid = np.isfinite(opens) & np.isfinite(closes)

    long_entries = valid & (closes > opens)
    long_exits = valid & (closes <= opens)
    short_entries = valid & (closes < opens)
    short_exits = valid & (closes >= opens)

    return long_entries, long_exits, short_entries, short_exits


STRATEGY = {
    "strategy_id": "S1-basic-body-direction",
    "hypothesis": '''
strategy_scope: source
execution_context: 
source_product_background: READ 來源僅提供以 O、C 判定 bull candle 與 bear candle 的策略背景；C>O 為 positive signal，C<O 為 negative signal。
actual_backtest_scope: FRAMEWORK run.py L26-L31 的 1m、3m、10m、30m、2h；策略使用每根完成 bar 的 OHLC，bar t 收盤後產生訊號，由 FRAMEWORK 於 bar t+1 open 執行；固定進場與出場滑價 1.0，每筆完成交易費用 0.5。
entry_rules: 1.1 對每個完成的市場 bar t，取 O_t=open[t]、C_t=close[t]。1.2 long_entry[t] = (C_t > O_t)；short_entry[t] = (C_t < O_t)；C_t = O_t 時不產生新進場。1.3 規則套用於 FRAMEWORK run.py L26-L31 的 1m、3m、10m、30m、2h 全部週期，不使用額外窗口、指標、成交量、session 或 regime filter。1.4 訊號於 bar t 收盤後產生，於 bar t+1 開盤執行；僅在 flat 狀態進場、不加碼。long 與 short 訊號若同時為真則不進場。1.5 FRAMEWORK 固定進場滑價為 1.0 價格單位：long 成交價為 O_{t+1}+1.0，short 成交價為 O_{t+1}-1.0。
exit_rules: 2.1 既有 long 的 long_exit[t] = (C_t <= O_t)；既有 short 的 short_exit[t] = (C_t >= O_t)。因此 doji 會退出現有方向，但不會建立新部位。2.2 出場訊號於 bar t 收盤後產生，於 bar t+1 開盤執行；FRAMEWORK 先檢查出場，出場後同一執行 bar 不反向進場。2.3 long 出場成交價為 O_{t+1}-1.0，short 出場成交價為 O_{t+1}+1.0；每筆完成交易扣除固定費用 0.5。2.4 沒有來源定義的停利、停損或時間出場；若直到資料結束仍未觸發鏡像條件，FRAMEWORK 不強制平倉，未平倉盈虧不計入 realized net_pnl。
exit_origin: mirrored
derived_exit: 出場規則不是來源明確提供，而是依 exit_derivation 的方向原子嚴格鏡像推導；long 進場原子 E_L=(C_t>O_t) 的失效為 (C_t<=O_t)，short 進場原子 E_S=(C_t<O_t) 的失效為 (C_t>=O_t)；等號歸入既有部位出場，且不跨方向重組布林條件。
exit_derivation: 3.1 來源未提供明確出場規則，依方向原子建立嚴格鏡像。3.2 long 進場原子 E_L=(C_t>O_t)，其失效為 not E_L=(C_t<=O_t)；short 進場原子 E_S=(C_t<O_t)，其失效為 not E_S=(C_t>=O_t)。3.3 long 與 short 為互斥的雙向分支，不跨方向重組布林條件；等號歸入既有部位的出場。
position: both
source_evidence: 1.1 READ L30-L52：以開盤價 O、收盤價 C 定義 bull candle 與 bear candle，並明確稱 C>O 為 positive signal、C<O 為 negative signal。1.2 FRAMEWORK engine.py L31-L63 提供逐 bar 的 OHLCV 行情；run.py L158-L172 要求四個等長布林訊號陣列。1.3 FRAMEWORK engine.py L324-L359 將 bar t 的訊號於 bar t+1 開盤執行。
''',
    "position": "both",
    "generate_signals": generate_signals,
    "signal_parameter_names": [],
    "signal_parameter_sets": [{}],
}