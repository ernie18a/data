<!-- tradingview-pine-id: PUB;38e17c107d1d46c596314dc2ea82016b -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# THMA MTF

Source: https://www.tradingview.com/script/Ztw4SESJ/

## Description

THMA MTF

This indicator plots the Triangular Hull Moving Average (THMA), a smooth and responsive moving average based on the Hull concept. The formula follows the standard THMA definition used across multiple public TradingView scripts and libraries:

THMA = WMA( 3*WMA(src, L/3) - WMA(src, L/2) - WMA(src, L), L )

The idea behind THMA comes from the broader Hull Moving Average family, adapted with a triangular weighting scheme to reduce lag while keeping the line smooth. This implementation is my own Pine Script version, built from publicly available documentation and open-source THMA scripts on TradingView.

Features:
- Source and length are configurable (default length: 21).
- Line color changes depending on price position:
  - Green when close is above THMA.
  - Red when close is below THMA.
- Optional higher timeframe mode: you can calculate THMA on a higher timeframe (e.g., 5 min, 15 min, 1h) and display it on your current chart.

Use it as a trend filter or dynamic support/resistance level. As with any indicator, it’s best combined with your own price action and risk management rules.

---

## Source Code

````pine
//@version=6
indicator("THMA MTF", overlay=true, shorttitle="THMA")

// ─────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────
srcInput    = input.source(close, "Source")
lengthInput = input.int(21, "THMA Length", minval=3)

useMTF      = input.bool(false, "Use Higher Timeframe?")
htfInput    = input.timeframe("", "Higher Timeframe",
                              tooltip="Leave empty = current chart TF. Enter e.g. '5' for 5 min, '60' for 1 h, etc.")

// ─────────────────────────────────────────────────────────────
// THMA FUNCTION
// THMA = WMA( 3*WMA(src, L/3) - WMA(src, L/2) - WMA(src, L), L )
// ─────────────────────────────────────────────────────────────
thma(_src, _len) =>
    // ensure integer lengths
    len3 = math.round(_len / 3)
    len2 = math.round(_len / 2)
    len1 = _len

    wma1 = ta.wma(_src, len3)
    wma2 = ta.wma(_src, len2)
    wma3 = ta.wma(_src, len1)

    raw = 3 * wma1 - wma2 - wma3
    ta.wma(raw, len1)

// ─────────────────────────────────────────────────────────────
// CALCULATION
// If useMTF = false → htfInput ignored, liczymy na bieżącym TF
// ─────────────────────────────────────────────────────────────
thmaValue = useMTF and htfInput != "" ? request.security(syminfo.tickerid, htfInput, thma(srcInput, lengthInput)) : thma(srcInput, lengthInput)

// ─────────────────────────────────────────────────────────────
// COLOR LOGIC
// Zielony, gdy cena (close) nad THMA; czerwony, gdy pod THMA
// ─────────────────────────────────────────────────────────────
thmaColor = close > thmaValue ? color.green : color.red

// ─────────────────────────────────────────────────────────────
// PLOT
// ─────────────────────────────────────────────────────────────
plot(thmaValue, "THMA", color=thmaColor, linewidth=2)
````
