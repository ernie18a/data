import numpy as np


def _a(obj, *names):
    for name in names:
        if hasattr(obj, name):
            return np.asarray(getattr(obj, name), dtype=float)
    raise AttributeError("missing series: " + ", ".join(names))


def _mean(x, n):
    out = np.full(len(x), np.nan)
    for i in range(n - 1, len(x)):
        z = x[i - n + 1:i + 1]
        if np.all(np.isfinite(z)):
            out[i] = np.mean(z)
    return out


def _ext(x, n, high=True):
    out = np.full(len(x), np.nan)
    for i in range(n, len(x)):
        z = x[i - n:i]
        if np.all(np.isfinite(z)):
            out[i] = np.max(z) if high else np.min(z)
    return out


def _ema(x, n):
    out = np.full(len(x), np.nan)
    alpha = 2.0 / (n + 1.0)
    value = np.nan
    for i, v in enumerate(x):
        if np.isfinite(v):
            value = v if not np.isfinite(value) else alpha * v + (1.0 - alpha) * value
            out[i] = value
    return out


def _atr(h, l, c, n):
    pc = np.r_[c[0], c[:-1]]
    return _mean(np.maximum(h - l, np.maximum(abs(h - pc), abs(l - pc))), n)


def _rsi(c, n=14):
    d = np.diff(c, prepend=c[0])
    gain, loss = _mean(np.maximum(d, 0.0), n), _mean(np.maximum(-d, 0.0), n)
    out = np.full(len(c), np.nan)
    ok = np.isfinite(gain) & np.isfinite(loss)
    out[ok & (loss == 0.0)] = 100.0
    mask = ok & (loss > 0.0)
    out[mask] = 100.0 - 100.0 / (1.0 + gain[mask] / loss[mask])
    return out


def _cci(h, l, c, n=20):
    tp = (h + l + c) / 3.0
    ma = _mean(tp, n)
    out = np.full(len(c), np.nan)
    for i in range(n - 1, len(c)):
        z = tp[i - n + 1:i + 1]
        dev = np.mean(abs(z - ma[i])) if np.all(np.isfinite(z)) else 0.0
        if dev > 0.0:
            out[i] = (tp[i] - ma[i]) / (0.015 * dev)
    return out


def _micro_retest(o, h, l, c, atr, lookback=5, expiry=6):
    out = np.zeros(len(c), dtype=np.bool_)
    last_break, level = -1, np.nan
    for i in range(lookback, len(c)):
        previous_low = np.min(l[i - lookback:i])
        if np.isfinite(previous_low) and c[i] < previous_low and c[i] < o[i]:
            last_break, level = i, previous_low
        if last_break >= 0 and 0 < i - last_break <= expiry:
            tolerance = 0.15 * max(float(atr[i]) if np.isfinite(atr[i]) else 0.0, 0.0)
            out[i] = h[i] >= level - tolerance and c[i] < level and c[i] < o[i]
    return out


def _bullish_opposite(o, h, l, c, atr, fast, slow, rsi, rsi_signal, cci, cci_signal):
    out = np.zeros(len(c), dtype=np.bool_)
    support = _ext(l, 20, False)
    for i in range(2, len(c)):
        rng, body = max(h[i] - l[i], 1e-12), max(abs(c[i] - o[i]), 1e-12)
        prev_body = max(abs(c[i - 1] - o[i - 1]), 1e-12)
        lower = min(o[i], c[i]) - l[i]
        engulf = c[i] > o[i] and c[i - 1] < o[i - 1] and o[i] <= c[i - 1] and c[i] >= o[i - 1] and body >= 0.90 * prev_body
        hammer = lower >= 2.0 * body and h[i] - max(o[i], c[i]) <= 0.25 * rng and c[i] >= l[i] + 0.60 * rng
        sweep = np.isfinite(support[i]) and l[i] < support[i] and c[i] > support[i] and c[i] > o[i]
        momentum = int(rsi[i] > rsi_signal[i]) + int(cci[i] > cci_signal[i]) + int(fast[i] > slow[i]) >= 2
        near_support = np.isfinite(support[i]) and l[i] <= support[i] + 0.45 * max(atr[i], 0.0)
        out[i] = (engulf or hammer or sweep) and momentum and near_support
    return out


def _short_exits(features, entries, opposite, atr, p):
    m = features.market
    h, l, c = _a(m, "highs", "high"), _a(m, "lows", "low"), _a(m, "closes", "close")
    n = int(m.size)
    out = np.zeros(n, dtype=np.bool_)
    base = float(p.get("management_base_atr_multiplier", 2.15))
    be_r = float(p.get("management_breakeven_r", 0.95))
    tighten_r = float(p.get("management_tighten_r", 1.75))
    max_bars = int(p.get("management_max_bars", 160))
    resistance, wide = _ext(h, 20), _ext(h, 50)
    fast, slow = _ema(c, 20), _ema(c, 50)
    htf_fast, htf_slow = _ema(c, 50), _ema(c, 100)
    active, entry, trail, risk, best, start, stage = False, 0.0, 0.0, 1.0, 0.0, -1, 1
    for i in range(n):
        a = max(float(atr[i]) if np.isfinite(atr[i]) else 0.0, 1e-12)
        if active:
            mfe = (entry - best) / max(risk, 1e-12)
            risk_off = ((np.isfinite(htf_fast[i]) and np.isfinite(htf_slow[i]) and htf_fast[i] > htf_slow[i]) or (np.isfinite(fast[i]) and np.isfinite(slow[i]) and abs(fast[i] - slow[i]) < 0.30 * a) or (np.isfinite(resistance[i]) and h[i] >= resistance[i] - 0.45 * a))
            if (i > start and h[i] > trail) or bool(opposite[i]) or i - start > max_bars:
                out[i], active = True, False
            else:
                best = min(best, l[i])
                mfe = (entry - best) / max(risk, 1e-12)
                trend_hold = np.isfinite(htf_fast[i]) and np.isfinite(htf_slow[i]) and htf_fast[i] < htf_slow[i]
                mult = base + (0.25 if trend_hold else 0.0) - (0.30 if np.isfinite(fast[i]) and np.isfinite(slow[i]) and abs(fast[i] - slow[i]) < 0.30 * a else 0.0) - (0.35 if risk_off else 0.0) - (0.30 if mfe >= tighten_r else 0.0)
                mult = float(np.clip(mult, 1.15, 3.40))
                candidate = (h[i] + l[i]) / 2.0 + a * mult
                if np.isfinite(resistance[i]):
                    candidate = min(candidate, resistance[i] + 0.08 * a)
                if np.isfinite(wide[i]):
                    candidate = min(candidate, wide[i] + 0.08 * a)
                stage = max(stage, 3 if risk_off or mfe >= tighten_r else 2 if mfe >= be_r else 1)
                if mfe >= be_r:
                    candidate = min(candidate, entry - 0.03 * risk)
                if stage == 3 and mfe >= 1.0:
                    lock = min(max(mfe * (0.42 if risk_off else 0.30), 0.30 if risk_off else 0.20), 1.50 if risk_off else 1.00)
                    candidate = min(candidate, entry - lock * risk)
                trail = min(trail, max(candidate, c[i] + 0.08 * a))
        if not active and entries[i] and not bool(opposite[i]):
            entry = c[i]
            levels = [h[i]] + [x for x in (resistance[i], wide[i]) if np.isfinite(x)]
            level = min(x for x in levels if x >= entry) if any(x >= entry for x in levels) else entry
            risk = float(np.clip(max(level - entry + 0.08 * a, 0.35 * a), 0.35 * a, 2.50 * a))
            trail, best, start, stage, active = entry + risk, entry, i, 1, True
    return out


def generate_signals(features, signal_params):
    m, p = features.market, signal_params or {}
    n = int(m.size)
    o, h, l, c = _a(m, "opens", "open"), _a(m, "highs", "high"), _a(m, "lows", "low"), _a(m, "closes", "close")
    has_volume = hasattr(m, "volumes") or hasattr(m, "volume")
    v = _a(m, "volumes", "volume") if has_volume else np.ones(n)
    atr = _atr(h, l, c, int(p.get("atr_period", 14)))
    rsi, cci = _rsi(c), _cci(h, l, c)
    rsi_signal, cci_signal = _ema(rsi, 5), _ema(cci, 13)
    fast, slow = _ema(c, 20), _ema(c, 50)
    htf_fast, htf_slow = _ema(c, 50), _ema(c, 100)
    volume_mean = _mean(v, 20)
    hi20, lo20, hi50, lo50 = _ext(h, 20), _ext(l, 20, False), _ext(h, 50), _ext(l, 50, False)
    micro = _micro_retest(o, h, l, c, atr)
    short = np.zeros(n, dtype=np.bool_)
    threshold = float(p.get("candle_confirm_threshold", 68.0))
    pivot_threshold = float(p.get("pivot_watch_threshold", 60.0))
    volume_limit = float(p.get("volume_counter_flow_limit", 35.0))
    location_block = float(p.get("location_block_atr", 0.50))
    opposite = _bullish_opposite(o, h, l, c, atr, fast, slow, rsi, rsi_signal, cci, cci_signal)
    for i in range(n):
        rng, body = max(h[i] - l[i], 1e-12), max(abs(c[i] - o[i]), 1e-12)
        prev_body = max(abs(c[i - 1] - o[i - 1]), 1e-12) if i else np.nan
        upper = h[i] - max(o[i], c[i])
        engulf = i >= 1 and c[i] < o[i] and c[i - 1] > o[i - 1] and o[i] >= c[i - 1] and c[i] <= o[i - 1] and body >= 0.90 * prev_body
        evening = i >= 2 and c[i - 2] > o[i - 2] and abs(c[i - 1] - o[i - 1]) <= 0.55 * abs(c[i - 2] - o[i - 2]) and c[i] < o[i] and c[i] <= 0.50 * (o[i - 2] + c[i - 2])
        shooting = upper >= 2.0 * body and l[i] - min(o[i], c[i]) <= 0.25 * rng and c[i] <= l[i] + 0.40 * rng
        dark_cloud = i >= 1 and c[i - 1] > o[i - 1] and c[i] < o[i] and o[i] >= c[i - 1] and c[i] <= 0.50 * (o[i - 1] + c[i - 1]) and c[i] > o[i - 1]
        pattern = engulf or evening or shooting or dark_cloud
        quality = 35.0 if engulf or evening else 28.0 if shooting or dark_cloud else 0.0
        sweep = np.isfinite(hi20[i]) and h[i] > hi20[i] and c[i] < hi20[i] and c[i] < o[i]
        major_ready = np.isfinite(fast[i]) and np.isfinite(slow[i]) and np.isfinite(hi50[i]) and np.isfinite(lo50[i])
        swing_ready = np.isfinite(fast[i]) and np.isfinite(hi20[i]) and np.isfinite(lo20[i])
        major_risk = np.clip(100.0 * (h[i] - lo50[i]) / max(hi50[i] - lo50[i], 1e-12), 0.0, 100.0) if major_ready else np.nan
        swing_risk = np.clip(100.0 * (h[i] - lo20[i]) / max(hi20[i] - lo20[i], 1e-12), 0.0, 100.0) if swing_ready else np.nan
        context = ((major_ready and fast[i] >= slow[i] and major_risk >= pivot_threshold and h[i] >= hi50[i] - 0.45 * max(atr[i], 0.0)) or (swing_ready and c[i] >= fast[i] and swing_risk >= pivot_threshold and h[i] >= hi20[i] - 0.45 * max(atr[i], 0.0)))
        rsi_ok = np.isfinite(rsi[i]) and np.isfinite(rsi_signal[i])
        cci_ok = np.isfinite(cci[i]) and np.isfinite(cci_signal[i])
        qqe_down = i > 0 and rsi_ok and np.isfinite(rsi[i - 1]) and rsi[i] <= rsi[i - 1]
        bear_votes = int(qqe_down) + int(rsi_ok and rsi[i] < rsi_signal[i]) + int(cci_ok and cci[i] < cci_signal[i])
        bull_votes = int(rsi_ok and rsi[i] > rsi_signal[i]) + int(cci_ok and cci[i] > cci_signal[i]) + int(np.isfinite(fast[i]) and np.isfinite(slow[i]) and fast[i] > slow[i])
        momentum_ok = bear_votes >= 2 and bear_votes > bull_votes
        if has_volume and np.isfinite(volume_mean[i]) and volume_mean[i] > 0.0:
            j = max(0, i - 19)
            flow = np.sum(np.sign(c[j:i + 1] - o[j:i + 1]) * v[j:i + 1]) / max(np.sum(v[j:i + 1]), 1e-12)
            volume_ok = 50.0 - 50.0 * np.clip(flow, -1.0, 1.0) >= volume_limit
        else:
            volume_ok = True
        location = 100.0 * (c[i] - lo50[i]) / max(hi50[i] - lo50[i], 1e-12) if major_ready else np.nan
        room = (c[i] - lo50[i]) / max(float(atr[i]) if np.isfinite(atr[i]) else 1e-12, 1e-12) if major_ready else np.nan
        location_ok = not swing_ready or (np.isfinite(location) and location >= 30.0 and (not np.isfinite(room) or room >= 0.70 * location_block))
        regime_block = np.isfinite(fast[i]) and np.isfinite(slow[i]) and np.isfinite(atr[i]) and fast[i] > slow[i] and fast[i] - slow[i] >= 0.50 * atr[i]
        regime_ok = not (regime_block and not (major_ready and major_risk >= 80.0))
        htf_block = np.isfinite(htf_fast[i]) and np.isfinite(htf_slow[i]) and np.isfinite(atr[i]) and htf_fast[i] > htf_slow[i] and htf_fast[i] - htf_slow[i] >= 0.50 * atr[i]
        htf_ok = not (htf_block and not sweep and not micro[i])
        micro_ok = i < 10 or bool(micro[i])
        score = max(quality, 30.0 if micro[i] else 0.0) + (20.0 if sweep else 0.0) + 20.0 * bear_votes / 3.0 + (25.0 if context else 0.0) + (10.0 if major_ready and (not fast[i] >= slow[i] or context) else 0.0) + (10.0 if swing_ready and (not c[i] >= fast[i] or context) else 0.0) + (8.0 if np.isfinite(location) and location >= 70.0 else -8.0 if np.isfinite(location) and location < 35.0 else 0.0) + (14.0 if micro[i] else -10.0 if i >= 10 else 0.0)
        valid = np.isfinite(atr[i]) and atr[i] > 0.0 and np.isfinite(c[i]) and np.isfinite(o[i])
        short[i] = bool(valid and (pattern or sweep or micro[i]) and context and momentum_ok and volume_ok and regime_ok and htf_ok and location_ok and micro_ok and score >= threshold)
    long = np.zeros(n, dtype=np.bool_)
    exits = _short_exits(features, short, opposite, atr, p)
    return long, np.zeros(n, dtype=np.bool_), short, exits


STRATEGY = {
    "strategy_id": "zz_reversal_short",
    "hypothesis": "高位 ZigZag 反轉上下文中的空方形態、動能、量能與 Micro 回測共振後做空，以自適應結構 ATR 管理出場。",
    "position": "short",
    "generate_signals": generate_signals,
    "signal_parameter_names": ["atr_period", "candle_confirm_threshold", "pivot_watch_threshold", "volume_counter_flow_limit", "location_block_atr", "management_base_atr_multiplier", "management_breakeven_r", "management_tighten_r", "management_max_bars"],
    "signal_parameter_sets": [{"atr_period": 14, "candle_confirm_threshold": 68.0, "pivot_watch_threshold": 60.0, "volume_counter_flow_limit": 35.0, "location_block_atr": 0.50, "management_base_atr_multiplier": 2.15, "management_breakeven_r": 0.95, "management_tighten_r": 1.75, "management_max_bars": 160}]
}
