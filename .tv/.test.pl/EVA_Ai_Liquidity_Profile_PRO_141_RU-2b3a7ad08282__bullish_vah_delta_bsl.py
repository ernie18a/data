import numpy as np


def generate_signals(features, signal_params):
    size = features.market.size
    closes = np.asarray(features.market.closes, dtype=float)
    vah = np.asarray(features.vah, dtype=float)
    val = np.asarray(features.val, dtype=float)
    delta = np.asarray(features.delta, dtype=float)
    bsl = np.asarray(features.bsl, dtype=float)
    bsl_swept = np.asarray(features.bsl_swept, dtype=bool)
    atr = np.asarray(features.atr(14), dtype=float)
    atr_radius = float(signal_params.get("atr_radius", 1.0))

    long_entries = np.zeros(size, dtype=np.bool_)
    long_exits = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    short_exits = np.zeros(size, dtype=np.bool_)

    valid = (
        np.isfinite(closes)
        & np.isfinite(vah)
        & np.isfinite(val)
        & np.isfinite(delta)
        & np.isfinite(bsl)
        & np.isfinite(atr)
        & (atr > 0.0)
    )
    bsl_nearby = (bsl > closes) & ((bsl - closes) <= atr_radius * atr)
    if size > 1:
        long_entries[1:] = (
            valid[1:]
            & valid[:-1]
            & (closes[1:] > vah[1:])
            & (closes[:-1] <= vah[:-1])
            & (delta[1:] > 0.0)
            & bsl_nearby[1:]
            & ~bsl_swept[1:]
        )
        long_exits[1:] = (
            valid[1:]
            & valid[:-1]
            & (closes[1:] <= vah[1:])
            & (closes[1:] >= val[1:])
            & (closes[:-1] > vah[:-1])
        )

    return long_entries, long_exits, short_entries, short_exits


STRATEGY = {
    "strategy_id": "bullish_vah_delta_bsl",
    "hypothesis": "上穿動態 VAH 且 Delta 為正，並有近距離有效 BSL 時做多。",
    "position": "long",
    "generate_signals": generate_signals,
    "signal_parameter_names": ["atr_radius"],
    "signal_parameter_sets": [{"atr_radius": 1.0}],
}
