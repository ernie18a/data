import numpy as np


def generate_signals(features, signal_params):
    n = features.market.size
    long_entries = np.zeros(n, dtype=np.bool_)
    long_exits = np.zeros(n, dtype=np.bool_)
    short_entries = np.zeros(n, dtype=np.bool_)
    short_exits = np.zeros(n, dtype=np.bool_)

    if n == 0:
        return long_entries, long_exits, short_entries, short_exits

    closes = features.market.closes
    sma10 = features.sma(10)
    sma200 = features.sma(200)
    std200 = features.std(200)

    daily_change = np.full(n, np.nan, dtype=np.float64)
    with np.errstate(divide="ignore", invalid="ignore"):
        daily_change[1:] = closes[1:] / closes[:-1] - 1.0

    sma10_falling = np.zeros(n, dtype=np.bool_)
    sma10_falling[1:] = sma10[1:] < sma10[:-1]

    lower_three_std = sma200 - 3.0 * std200
    avoid_region = (closes >= sma200 - std200) & (closes <= sma200)
    entry_valid = (
        np.isfinite(closes)
        & np.isfinite(sma10)
        & np.isfinite(sma200)
        & np.isfinite(std200)
        & np.isfinite(daily_change)
    )
    short_entries[:] = (
        entry_valid
        & sma10_falling
        & (closes < sma10)
        & (closes > lower_three_std)
        & (daily_change >= -0.01)
        & (daily_change <= 0.01)
        & ~avoid_region
    )

    cross_valid = (
        np.isfinite(closes[1:])
        & np.isfinite(sma10[1:])
        & np.isfinite(closes[:-1])
        & np.isfinite(sma10[:-1])
    )
    short_exits[1:] = (
        cross_valid
        & (closes[1:] > sma10[1:])
        & (closes[:-1] <= sma10[:-1])
    )

    return long_entries, long_exits, short_entries, short_exits


STRATEGY = {
    "strategy_id": "csct.bearish-call-credit",
    "hypothesis": (
        "strategy_scope: directional。"
        "來源商品背景（execution_context）: 偏空核心成立時建立 call credit spread，"
        "賣出最接近 9 日後到期的約 25 Delta call，買入高 1 美元履約價的 call；"
        "通用管理為 0.20–0.25 美元初始權利金、價差≤0.05 美元提前獲利，"
        "至到期或標的觸及賣方履約價時約 0.50 美元買回，部位風險以可接受連續虧損金額除以 7 決定。"
        "實際回測範圍: 僅回測偏空方向核心的標的 short 訊號；不回測選擇權商品、到期、權利金或部位管理。"
        "entry_rules: SMA(C,10)[t] < SMA(C,10)[t-1]；C[t] < SMA(C,10)[t]；"
        "C[t] > SMA(C,200)[t] - 3×Std(C,200)[t]；日變動介於 -1% 與 1%（含邊界）；"
        "避開 SMA(C,200)-Std(C,200) 至 SMA(C,200) 的區域；全部條件 AND。"
        "exit_rules: short role=invalidate；trigger=cross_up(C,SMA(C,10))[t]，即 C[t] > SMA(C,10)[t] 且 C[t-1] <= SMA(C,10)[t-1]；mode=close；action=exit_all。"
        "exit_origin: sop。"
        "推導出場（exit_derivation）: 命中 SOP 3 多序列關係失效；完全沿用 C、SMA(C,10) 與窗口 10，"
        "將空方核心 C < SMA10 的失效實作為 cross_up(C,SMA10)；SMA10 下降、標準差帶、日變動與區域迴避僅保留為進場資格 filters。"
        "position: short。"
        "source_evidence: READ 第 133–165 行含 SMA10 下降、價格低於 SMA10、價格高於 200 日 SMA 負 3 標準差、"
        "日變動介於 -1% 與 1%，及避開一標準差與 SMA200 間區域；第 173–177 行為 9 日、25 Delta、1 美元寬 call spread；"
        "第 221–245 行為通用權利金獲利／止損管理。"
    ),
    "position": "short",
    "generate_signals": generate_signals,
    "signal_parameter_names": [],
    "signal_parameter_sets": [{}],
}