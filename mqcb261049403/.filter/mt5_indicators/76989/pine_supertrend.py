"""Pine semantics, copied as literally as I could manage.

This is the yardstick the MQL5 port gets measured against, so it deliberately
follows TradingView's own reference implementation of ta.supertrend instead of
anything cleaner. Three things here are the usual reason a port drifts:

  ta.rma is a Wilder average, alpha = 1/n, seeded with SMA(n). Not an EMA.
  ta.tr(handle_na=true) treats bar 0 as high-low, so the warm-up starts a bar
  earlier than iATR's.
  the bands are sticky.

Pure stdlib on purpose. Nobody should have to pip install anything to check
whether my numbers are real.
"""
from __future__ import annotations

import math

NAN = float("nan")


def is_na(x):
    return x is None or (isinstance(x, float) and math.isnan(x))


def true_range(high, low, close):
    out = []
    for i in range(len(high)):
        if i == 0:
            out.append(high[0] - low[0])         # no previous close yet
        else:
            pc = close[i - 1]
            out.append(max(high[i] - low[i], abs(high[i] - pc), abs(low[i] - pc)))
    return out


def rma(src, period):
    """Wilder smoothing the way Pine does it."""
    out = [NAN] * len(src)
    if period <= 0 or len(src) < period:
        return out
    prev = sum(src[:period]) / period           # the seed everyone forgets
    out[period - 1] = prev
    alpha = 1.0 / period
    for i in range(period, len(src)):
        prev = (src[i] - prev) * alpha + prev
        out[i] = prev
    return out


def ema_wrong_alpha(src, period):
    """The mis-port: alpha = 2/(n+1), seeded on bar 0. Here to be measured, not used."""
    out = [NAN] * len(src)
    if not src:
        return out
    alpha = 2.0 / (period + 1.0)
    prev = src[0]
    out[0] = prev
    for i in range(1, len(src)):
        prev = alpha * src[i] + (1.0 - alpha) * prev
        out[i] = prev
    return out


def sma_series(src, period):
    """The other stand-in people reach for."""
    out = [NAN] * len(src)
    run = 0.0
    for i, v in enumerate(src):
        run += v
        if i >= period:
            run -= src[i - period]
        if i >= period - 1:
            out[i] = run / period
    return out


def supertrend(high, low, close, factor=3.0, period=10, atr_mode="rma", sticky=True):
    """Returns (supertrend, direction, atr, upper, lower), NaN until warm.

    atr_mode/sticky exist so the harness can switch one mistake on at a time and
    price it. For the real thing leave them alone.
    """
    tr = true_range(high, low, close)
    if atr_mode == "rma":
        atr = rma(tr, period)
    elif atr_mode == "ema":
        atr = ema_wrong_alpha(tr, period)
    elif atr_mode == "sma":
        atr = sma_series(tr, period)
    else:
        raise ValueError("atr_mode: rma, ema or sma")

    n = len(close)
    st, direction = [NAN] * n, [NAN] * n
    ub, lb = [NAN] * n, [NAN] * n

    for i in range(n):
        a = atr[i]
        if is_na(a):
            continue

        mid = (high[i] + low[i]) / 2.0
        up = mid + factor * a
        dn = mid - factor * a

        p_ub = 0.0 if (i == 0 or is_na(ub[i - 1])) else ub[i - 1]     # nz()
        p_lb = 0.0 if (i == 0 or is_na(lb[i - 1])) else lb[i - 1]
        pc = close[i - 1] if i > 0 else NAN
        has_pc = not is_na(pc)

        if sticky:
            if not (dn > p_lb or (has_pc and pc < p_lb)):
                dn = p_lb
            if not (up < p_ub or (has_pc and pc > p_ub)):
                up = p_ub

        prev_atr = atr[i - 1] if i > 0 else NAN
        if is_na(prev_atr):
            d = 1
        elif not is_na(st[i - 1]) and st[i - 1] == ub[i - 1]:
            d = -1 if close[i] > up else 1
        else:
            d = 1 if close[i] < dn else -1

        ub[i], lb[i] = up, dn
        direction[i] = d
        st[i] = dn if d == -1 else up

    return st, direction, atr, ub, lb
