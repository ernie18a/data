# Aegis Volume Flow Stack [wjdtks255]

- url: https://www.tradingview.com/script/rPiuWFyS/
- type: indicator
- pine_id: PUB;692e8df27b0648a088c60e64cb6549a6
- version: 1.0

## Description

[Overview (개요)]
The Aegis Volume Flow Stack is a precision tool designed to visualize the internal composition of market volume. By analyzing the intra-bar price relationship (High/Low/Close), this indicator splits total volume into Buying and Selling pressure, providing an immediate snapshot of aggressive order flow.

Aegis Volume Flow Stack은 시장 거래량의 내부 구성을 시각화하기 위해 설계된 정밀 도구입니다. 봉 내부의 가격 관계(고가/저가/종가)를 분석하여 총 거래량을 매수 및 매도 압력으로 분할함으로써, 공격적인 주문 흐름을 즉각적으로 파악할 수 있게 합니다.

[Key Features (핵심 기능)]
Dynamic Volume Splitting: Automatically segments total volume into Buy/Sell components based on candle distribution.
(캔들 분포를 기반으로 총 거래량을 자동으로 매수/매도 구성 요소로 분할합니다.)

Visual Stacking: Displays Buy and Sell volume in a single stacked bar format for intuitive trend analysis.
(직관적인 추세 분석을 위해 매수량과 매도량을 하나의 스택 막대 형식으로 표시합니다.)

Institutional Insight: Helps identify hidden buying or selling dominance within high-volume spikes.
(대량 거래 발생 시, 숨겨진 매수 또는 매도 우위를 식별하는 데 도움을 줍니다.)

[How to Use (사용법)]
Green Dominance: Indicates strong buying pressure. Look for sustained green stacks during uptrends. (녹색 우위: 강력한 매수 압력을 나타냅니다. 상승 추세 중 지속적인 녹색 스택을 확인하십시오.)

Red Dominance: Indicates strong selling pressure. Look for red stack expansion during potential trend reversals or bearish moves. (빨간색 우위: 강력한 매도 압력을 나타냅니다. 잠재적 추세 반전이나 하락 움직임 시 빨간색 스택 확장을 확인하십시오.)

Best used as a secondary confirmation tool alongside your primary trend strategies (e.g., the Aegis SMRT System). (Aegis SMRT 시스템과 같은 주력 추세 전략과 함께 보조 확인 도구로 사용하는 것이 가장 좋습니다.)

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © wjdtks255
//@version=6
indicator("Aegis Volume Flow Stack [wjdtks255]", overlay=false)

// 1. 계산 로직
candle_range = high - low
buy_ratio = candle_range == 0 ? 0 : (close - low) / candle_range
buyVol = volume * buy_ratio
sellVol = volume - buyVol

// 2. 시각화 (스택 방식)
plot(volume, title="Sell Volume (매도량)", style=plot.style_columns, color=color.new(color.red, 0))
plot(buyVol, title="Buy Volume (매수량)", style=plot.style_columns, color=color.new(color.green, 0))
````
