<!-- tradingview-pine-id: PUB;2c55a7e911c449df85e15c3504336e18 -->
<!-- tradingviewscripts-format: 1 -->
# Setup123Lib

Source: https://www.tradingview.com/script/mTVbwUuI-Setup123Lib/

## Description

Library  "Setup123Lib"

calcularSetup(_margemStopPct, _riscoMaximoPct, _distanciaMaximaPct, _distanciaPrecoEma200MaxPct, _riscoRetorno, _isDiario)
  Parameters:
    _margemStopPct (float)
    _riscoMaximoPct (float)
    _distanciaMaximaPct (float)
    _distanciaPrecoEma200MaxPct (float)
    _riscoRetorno (float)
    _isDiario (bool)

---

## Source Code

````pine
//@version=6
library("Setup123Lib", overlay=true)

// ============================================================================
// NÚCLEO DO SETUP 123
// Centraliza as regras que são compartilhadas pelo indicador e pelo scanner.
// ============================================================================
export calcularSetup(float _margemStopPct, float _riscoMaximoPct, float _distanciaMaximaPct, float _distanciaPrecoEma200MaxPct, float _riscoRetorno, bool _isDiario) =>
    // Médias
    float ema8 = ta.ema(close, 8)
    float ema21 = ta.ema(close, 21)
    float ema80 = ta.ema(close, 80)
    float ema200 = ta.ema(close, 200)

    // Distância das médias
    // Diário: EMA 8 até EMA 80
    // Demais: EMA 8 até EMA 200
    float distanciaMediasPct = _isDiario ? math.abs(ema8 - ema80) / close * 100.0 : math.abs(ema8 - ema200) / close * 100.0
    bool mediasCompactas = distanciaMediasPct <= _distanciaMaximaPct

    // Distância do preço até EMA 200
    float distanciaPrecoEma200Pct = math.abs(close - ema200) / ema200 * 100.0
    bool precoNaoEsticadoEma200 = distanciaPrecoEma200Pct <= _distanciaPrecoEma200MaxPct

    // Estrutura 123
    bool fundo123 = low[1] < low[2] and low[1] < low
    bool topo123 = high[1] > high[2] and high[1] > high

    // Alinhamento LONG: 8 > 21 > 80 > 200 em C1, C2 e C3
    bool mediasLongC1 = ema8[2] > ema21[2] and ema21[2] > ema80[2] and ema80[2] > ema200[2]
    bool mediasLongC2 = ema8[1] > ema21[1] and ema21[1] > ema80[1] and ema80[1] > ema200[1]
    bool mediasLongC3 = ema8 > ema21 and ema21 > ema80 and ema80 > ema200
    bool mediasLong123 = mediasLongC1 and mediasLongC2 and mediasLongC3

    // Alinhamento SHORT: 8 < 21 < 80 < 200 em C1, C2 e C3
    bool mediasShortC1 = ema8[2] < ema21[2] and ema21[2] < ema80[2] and ema80[2] < ema200[2]
    bool mediasShortC2 = ema8[1] < ema21[1] and ema21[1] < ema80[1] and ema80[1] < ema200[1]
    bool mediasShortC3 = ema8 < ema21 and ema21 < ema80 and ema80 < ema200
    bool mediasShort123 = mediasShortC1 and mediasShortC2 and mediasShortC3

    // Confirmação do C3 somente em relação à EMA 8
    bool c3AcimaEma8 = close > ema8
    bool c3AbaixoEma8 = close < ema8

    // LONG: entrada máxima C3 / stop mínima C2
    float novaEntradaLong = high
    float novoStopLong = low[1] * (1.0 - _margemStopPct / 100.0)
    float novoRiscoLong = novaEntradaLong - novoStopLong
    float novoRiscoLongPct = novaEntradaLong > novoStopLong ? novoRiscoLong / novaEntradaLong * 100.0 : na
    bool novoRiscoLongValido = not na(novoRiscoLongPct) and novoRiscoLongPct <= _riscoMaximoPct
    bool novoSetupLongValido = fundo123 and mediasLong123 and c3AcimaEma8 and mediasCompactas and precoNaoEsticadoEma200 and novoRiscoLong > syminfo.mintick and novoRiscoLongValido
    float alvoLong = novaEntradaLong + novoRiscoLong * _riscoRetorno

    // SHORT: entrada mínima C3 / stop máxima C2
    float novaEntradaShort = low
    float novoStopShort = high[1] * (1.0 + _margemStopPct / 100.0)
    float novoRiscoShort = novoStopShort - novaEntradaShort
    float novoRiscoShortPct = novoStopShort > novaEntradaShort ? novoRiscoShort / novaEntradaShort * 100.0 : na
    bool novoRiscoShortValido = not na(novoRiscoShortPct) and novoRiscoShortPct <= _riscoMaximoPct
    bool novoSetupShortValido = topo123 and mediasShort123 and c3AbaixoEma8 and mediasCompactas and precoNaoEsticadoEma200 and novoRiscoShort > syminfo.mintick and novoRiscoShortValido
    float alvoShort = novaEntradaShort - novoRiscoShort * _riscoRetorno

    [novoSetupLongValido, novoSetupShortValido, novaEntradaLong, novoStopLong, alvoLong, novoRiscoLongPct, novaEntradaShort, novoStopShort, alvoShort, novoRiscoShortPct, distanciaMediasPct, distanciaPrecoEma200Pct, ema8, ema21, ema80, ema200]
````
