import numpy as np


def generate_signals(features, signal_params):
    n = features.market.size
    long_entries = np.zeros(n, dtype=np.bool_)
    long_exits = np.zeros(n, dtype=np.bool_)
    short_entries = np.zeros(n, dtype=np.bool_)
    short_exits = np.zeros(n, dtype=np.bool_)

    # READ 的選擇權進場篩選（POP、DTE、IV、選擇權成交量及履約價）
    # 不存在於 FRAMEWORK 的 MarketData，因此不產生不可證明的進場訊號。
    # B 是 entry 已選定且應保持不變的賣出 put 履約價；目前沒有來源。
    close = np.asarray(features.market.closes, dtype=np.float64)
    b = np.full(n, np.nan, dtype=np.float64)

    # SOP exit: cross_down(C, B)[t] := C[t] < B[t] and C[t-1] >= B[t-1].
    # 當任一必要輸入不是有限、已完成資料時，trigger 必須為 False。
    if n > 1:
        valid = (
            np.isfinite(close[1:])
            & np.isfinite(close[:-1])
            & np.isfinite(b[1:])
            & np.isfinite(b[:-1])
        )
        long_exits[1:] = valid & (close[1:] < b[1:]) & (close[:-1] >= b[:-1])

    return long_entries, long_exits, short_entries, short_exits


STRATEGY = {
    "strategy_id": "put_pop_monthly",
    "hypothesis": (
        "strategy_scope: directional\n"
        "source_product_background: 原始來源為賣出單一現金擔保 put；每張合約代表 100 股，"
        "賣方收取權利金，可能因標的低於履約價而被指派；來源偏好約 30–45 DTE，早期示例為 "
        "28/35 DTE，以 POP 70–80%（示例約 75%）、IV > 30%、選擇權成交量至少約 5,000,000 "
        "選擇賣出 put，並另以 put credit spread 作小帳戶替代執行。\n"
        "execution_context: 原始方向曝險映射為 long；來源的權利金、IV、POP、到期、指派、展期與 "
        "put credit spread 不作為本 FRAMEWORK 的訊號。\n"
        "actual_backtest_scope: 實際回測只涵蓋 FRAMEWORK 提供的標的 MarketData 行情序列與 long "
        "方向；不回測選擇權鏈、履約價選擇、權利金、IV、POP、到期、指派、展期或保證金。由於 "
        "FRAMEWORK 沒有選擇權資料，READ 的 POP、DTE、IV、選擇權成交量及 B 均無法在行情序列中 "
        "驗證，long entry 因而保持 False。\n"
        "entry_rules: 來源條件為 POP 70–80%（示例約 75%）AND DTE 約 30–45（早期示例 28/35） "
        "AND 選擇權 IV > 30% AND 選擇權成交量至少約 5,000,000，以賣出 put 進場；這些輸入不在 "
        "FRAMEWORK 可取得資料內，故不產生未經證明的進場訊號。\n"
        "exit_rules: long role=invalidate；C 為標的收盤價，B 為 entry 已選定且沿用的賣出 put 履約價； "
        "cross_down(C,B)[t] := C[t] < B[t] AND C[t-1] >= B[t-1]，必要輸入須為已完成且有限值， "
        "mode=close，action=exit_all。\n"
        "exit_origin: sop\n"
        "derived_exit: 依 SOP 4，將 entry 的有利狀態 C>B 反轉為 cross_down(C,B)；沿用相同的 C、B "
        "操作數與 entry 的約 30–45 DTE 選擇窗口，POP、IV 與選擇權成交量只保留為 entry filter。 "
        "因 B 未由 FRAMEWORK 提供，有限值資格條件使出場事件為 False。\n"
        "exit_derivation: 1. 命中 SOP 4（單序列狀態失效）。entry 的有利狀態 x>b 對應為 x=C、b=B； "
        "標的收盤價 C 維持在賣出 put 履約價 B 之上。exit 沿用相同操作數 C、基準 B、約 30–45 DTE "
        "的 entry 選擇窗口與既有履約價參數，布林結構由 C>B 反轉為 cross_down(C,B)[t]。POP 70–80%、 "
        "IV>30% 與選擇權成交量約 5,000,000 保持 entry filter 角色，不納入 exit trigger。\n"
        "position: long\n"
        "source_evidence: READ 行 151–167：POP 約 70–80%，示例約 75% 且約 28 DTE；READ 行 186–221： "
        "IV 高於 30%、選擇權成交量至少約 500 萬、約 35 DTE、約 75% POP 賣 put；READ 行 225–233： "
        "到期失效、買回、指派三種結果；READ 行 720–729：高履約價 short put 加低履約價 long put 的 "
        "put credit spread。"
    ),
    "position": "long",
    "generate_signals": generate_signals,
    "signal_parameter_names": [],
    "signal_parameter_sets": [{}],
}
