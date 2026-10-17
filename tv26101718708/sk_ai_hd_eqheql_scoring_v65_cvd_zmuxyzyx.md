# SK AI + HD + EQH/EQL Scoring v6.5 CVD 

- url: https://www.tradingview.com/script/zmUXYZyx/
- type: indicator
- pine_id: PUB;02010176a6fa45989e2e963fd580d051
- version: 20.0

## Description

SK AI + HD + EQH/EQL Scoring v6.5 CVD 

ist ein fortgeschrittener Multi-Faktor TradingView-Indikator für Crypto-Scalping und Intraday-Trading. Das Script kombiniert AI-Trendlogik, adaptive SuperTrend-/LuxAlgo-ähnliche Trailing-Systeme, EQH/EQL-Liquidity Sweeps, Liquidity-Delta-Reversal-Erkennung, CVD-/Moneyflow-Analyse sowie VWAP-, POC-, Fibonacci- und MTF-Trendfilter zu einem gewichteten Scoring-System.

Hauptfunktionen:

AI Neural Trend Engine als primärer Trendfilter
Adaptiver HD/Lux SuperTrend mit Volatilitätsanpassung
EQH/EQL Liquidity Sweep & Reversal Detection
Liquidity Delta Profiler mit Rejection-, Divergence-, Absorption- und Exhaustion-Erkennung
Spot-/Futures-CVD und Moneyflow-Analyse
Multi-Timeframe EMA- und ADX-Bias
VWAP-, POC- und Fibonacci-Konfluenz-Scoring
Dynamisches Score-System für Long-/Short-Signale
Signalqualitäten: WEAK / GOOD / STRONG
Integriertes Risiko-Management mit:
Entry
Stop Loss
Break-Even
TP1 / TP2
Kapitalrisiko %
Dashboard mit Live-Marktstatus und Signalbewertung
Alert-System für TradingView/WunderTrading-Webhooks

Das Script ist darauf ausgelegt, Fehlsignale durch Konfluenz mehrerer Marktstrukturen und Orderflow-/Liquidity-Faktoren zu reduzieren und qualitativ hochwertige Long-/Short-Setups visuell und automatisiert bereitzustellen.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © biogartenbauneckar2026

//@version=6
indicator("Mein Skript")
plot(close)
````
