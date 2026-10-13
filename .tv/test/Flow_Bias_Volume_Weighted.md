<!-- tradingview-pine-id: PUB;febe566590c74818a8d9f42d76c953c5 -->
<!-- tradingviewscripts-format: 1 -->
# Flow Bias — Volume Weighted

Source: https://www.tradingview.com/script/vrVMfkBW-Flow-Bias-Volume-Weighted/

## Description

## Flow Bias — Volume Weighted

Flow Bias is a volume-weighted market structure indicator built around a dynamic liquidity cloud.

The cloud highlights areas where price and volume tend to concentrate, helping identify zones of liquidity, balance, and potential reaction.

**Blue** — bullish bias
**Red** — bearish bias
**Gray** — neutral / balanced conditions

These liquidity zones can act as dynamic areas of support, resistance, acceptance, or rejection as market conditions change.

Flow Bias is designed to reduce visual noise and provide a cleaner view of directional pressure and market structure.

Best used together with Price Action, Volume Profile, and Order Flow.

For educational purposes only. Not financial advice.

---

## Source Code

````pine
//@version=6
indicator("Flow Bias — Volume Weighted", overlay=true)

// =====================================================
// CONFIGURAÇÕES
// =====================================================

smoothLen = input.int(
     5,
     title="Suavização",
     minval=1
)

directionLen = input.int(
     3,
     title="Sensibilidade da Direção",
     minval=1
)

neutralATR = input.float(
     0.03,
     title="Zona Neutra (ATR)",
     minval=0.0,
     step=0.01
)

transparency = input.int(
     55,
     title="Transparência da Nuvem",
     minval=0,
     maxval=100
)

// =====================================================
// VWAP HIGH / LOW
// =====================================================

vwapHigh = ta.vwap(high)
vwapLow  = ta.vwap(low)

// =====================================================
// SUAVIZAÇÃO PONDERADA POR VOLUME
// =====================================================

smoothHigh = ta.vwma(vwapHigh, smoothLen)
smoothLow  = ta.vwma(vwapLow, smoothLen)

// Centro da nuvem
cloudMid = (smoothHigh + smoothLow) / 2.0

// =====================================================
// DIREÇÃO
// =====================================================

slope = cloudMid - cloudMid[directionLen]

atr = ta.atr(14)

neutralZone = atr * neutralATR

bullish = slope > neutralZone
bearish = slope < -neutralZone

// =====================================================
// CORES
// =====================================================

// AZUL     = subindo
// VERMELHO = caindo
// CINZA    = neutro

cloudColor =
     bullish ? color.new(color.blue, transparency) :
     bearish ? color.new(color.red, transparency) :
               color.new(color.gray, transparency)

// =====================================================
// LIMITES DA NUVEM
// =====================================================

// IMPORTANTE:
// As linhas continuam existindo e participam da escala.
// Apenas ficam 100% transparentes.

upperCloud = plot(
     smoothHigh,
     title="VWAP High",
     color=color.new(color.white, 100),
     linewidth=1,
     editable=false
)

lowerCloud = plot(
     smoothLow,
     title="VWAP Low",
     color=color.new(color.white, 100),
     linewidth=1,
     editable=false
)

// =====================================================
// CORPO DA NUVEM
// =====================================================

fill(
     upperCloud,
     lowerCloud,
     color=cloudColor,
     title="VWAP Cloud"
)
````
