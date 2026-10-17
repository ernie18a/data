# umbul98-Doji RSI with Divergence

- url: https://www.tradingview.com/script/niqFCEiC/
- type: indicator
- pine_id: PUB;71a1a44c7fc54885aa96a1bfca11af79
- version: 1.0

## Description

🔹 1. Basic Logic

This indicator combines two things:

🕯 Doji candlestick pattern → Indecision/reversal signal

📈 RSI (Relative Strength Index) → Overbought/oversold condition

👉 So instead of a Doji alone:

It produces a more filtered signal with “Doji + RSI position”.

🔹 2. How is a Doji Detected?

The indicator defines a classic Doji as follows:

The candle body is very small.

The upper and lower wicks are close together (balance exists).

In the code:

Body = less than 5% of the total range.

Wicks are approximately equal.

👉 This allows:

True indecision candles are filtered out (junk Dojis are eliminated).

🔹 3. RSI Integration (The most critical part)

It divides Dojis into 3 categories according to RSI:

🟢 1. Lower Boundary Doji (RSI ≤ 30)

Oversold zone

Doji = selling pressure may be weakening

👉 Interpretation: Possibility of an uptrend

🔴 2. Upper Boundary Doji (RSI ≥ 70)

Overbought zone

Doji = buying pressure may be weakening

👉 Interpretation: Possibility of a downtrend

⚪ 3. Neutral Doji (30 < (RSI < 70)

Uncertain market

👉 Comment: Wait / direction unclear

🔹 What does the 4th chart show?
✔️ "D" label on the candle

Marks the bar where a Doji is forming

Meaning changes according to color:

🟢 Green → Possible upward reversal

🔴 Red → Possible downward reversal

⚪ Gray → Undecided

✔️ Background Colors

Green → RSI low + Doji

Red → RSI high + Doji

Gray → Neutral

👉 This is a very good visual filter 👍

✔️ Tooltip (explanation when hovered over)

Each label has a comment:

“May show an upward trend”

“May show a downward trend”

✔️ Alarm System

There are 3 different alarms:

RSI ≤ 30 + Doji

RSI ≥ 70 + Doji

Neutral Doji

👉 Can be linked to TradingView alarm

🔹 5. Purpose of Use

This indicator is especially useful for: Ideal:

✅ Bottom capture (reversal)

RSI below 30 + Doji → strong signal

✅ Top capture

RSI above 70 + Doji → selling opportunity

✅ Fake signal filtering

Confirmation with RSI instead of Doji alone

🔹 6. Strengths

✔ Noise-reduced Doji detection
✔ Smart filtering with RSI
✔ Visually very clear (label + background)
✔ Alarm supported
✔ Simple but effective strategy infrastructure

🔹 7. Weaknesses (Important ⚠️)

❗ If used alone:

Can mislead in trend market

Constantly generates Doji (especially low timeframe)

👉 Therefore, best use:

With EMA trend filter

With support/resistance

Consolidation breakout island

## Source Code

````pine
//@version=6
indicator("umbul98-Doji RSI with Divergence", shorttitle = "umbul98-Doji RSI", overlay=true)

// Doji İndikatörü Parametreleri
C_Len = 14 // ta.ema depth for bodyAvg
C_ShadowPercent = 5.0 // size of shadows
C_ShadowEqualsPercent = 100.0
C_DojiBodyPercent = 5.0
C_Factor = 2.0 // shows the number of times the shadow dominates the candlestick body

C_BodyHi = math.max(close, open)
C_BodyLo = math.min(close, open)
C_Body = C_BodyHi - C_BodyLo
C_BodyAvg = ta.ema(C_Body, C_Len)
C_SmallBody = C_Body < C_BodyAvg
C_LongBody = C_Body > C_BodyAvg
C_UpShadow = high - C_BodyHi
C_DnShadow = C_BodyLo - low
C_HasUpShadow = C_UpShadow > C_ShadowPercent / 100 * C_Body
C_HasDnShadow = C_DnShadow > C_ShadowPercent / 100 * C_Body
C_WhiteBody = open < close
C_BlackBody = open > close
C_Range = high-low
C_IsInsideBar = C_BodyHi[1] > C_BodyHi and C_BodyLo[1] < C_BodyLo
C_BodyMiddle = C_Body / 2 + C_BodyLo
C_ShadowEquals = C_UpShadow == C_DnShadow or (math.abs(C_UpShadow - C_DnShadow) / C_DnShadow * 100) < C_ShadowEqualsPercent and (math.abs(C_DnShadow - C_UpShadow) / C_UpShadow * 100) < C_ShadowEqualsPercent
C_IsDojiBody = C_Range > 0 and C_Body <= C_Range * C_DojiBodyPercent / 100
C_Doji = C_IsDojiBody and C_ShadowEquals
hideWatermark = input.bool(false, title = 'Hide Watermark', group = 'Visual Settings')

// RSI Parametreleri (Kullanıcı Seçimi)
RSI_Length = input.int(14, title="RSI Periyodu", minval=1)  // RSI periyodunun kullanıcı tarafından belirlenmesi
RSI_Upper = input.float(70, title="RSI Üst Sınır", minval=1, maxval=100)  // RSI üst sınır
RSI_Lower = input.float(30, title="RSI Alt Sınır", minval=0, maxval=100)  // RSI alt sınır
RSI_Value = ta.rsi(close, RSI_Length)

// Doji Türü Seçimleri (Kullanıcı Girdisi)
showDoji = input(true, title="Normal Doji Göster")
showDojiLower = input(true, title="Alt Sınır (RSI <= 30) Doji Göster")
showDojiUpper = input(true, title="Üst Sınır (RSI >= 70) Doji Göster")
showDojiNeutral = input(true, title="Normal (RSI 30-70) Doji Göster")

// Doji Türlerine Ait Koşullar
C_NormalDoji = C_IsDojiBody and not (C_UpShadow <= C_Body or C_DnShadow <= C_Body)  // Normal Doji (ne Dragonfly, ne Gravestone)

// Doji RSI Eşleşme Koşulları
Doji_RSI_Condition_Lower = C_Doji and RSI_Value <= RSI_Lower  // Alt sınırda Doji
Doji_RSI_Condition_Upper = C_Doji and RSI_Value >= RSI_Upper  // Üst sınırda Doji
Doji_RSI_Condition_Neutral = C_Doji and RSI_Value > RSI_Lower and RSI_Value < RSI_Upper // 30-70 arasında Doji

// Etiket Renkleri Kullanıcı Girdisi
labelColorLower = input.color(color.green, "Alt Sınır Rengi (RSI <= 30)")  // Alt sınır (RSI <= 30) rengi
labelColorUpper = input.color(color.red, "Üst Sınır Rengi (RSI >= 70)")  // Üst sınır (RSI >= 70) rengi
labelColorNeutral = input.color(color.gray, "Diğer Durumlar İçin Etiket Rengi")  // 30-70 arası için

//Watermark
if not hideWatermark
    var tableData = table.new(position = position.top_right, columns = 1, rows = 1, frame_color = color.orange, frame_width = 0)
    table.cell(tableData, 0, 0, 'umbul98', text_color = color.new(color.orange, 0), text_size = size.large)


// Etiket Renkleri Koşul Tabanlı
color labelColor = na
if Doji_RSI_Condition_Lower
    labelColor := labelColorLower
else if Doji_RSI_Condition_Upper
    labelColor := labelColorUpper
else if Doji_RSI_Condition_Neutral
    labelColor := labelColorNeutral

// İleriye Dönük Uyarılar
alertcondition(Doji_RSI_Condition_Lower, title = "Doji RSI Alt Sınır", message = "Doji pattern detected with RSI <= 30!")
alertcondition(Doji_RSI_Condition_Upper, title = "Doji RSI Üst Sınır", message = "Doji pattern detected with RSI >= 70!")
alertcondition(Doji_RSI_Condition_Neutral, title = "Doji RSI Diğer Durum", message = "Doji pattern detected with RSI between 30 and 70!")

// Etiketler ve Arka Plan Rengi
patternLabelPosLow = low - (ta.atr(30) * 0.6)
patternLabelPosHigh = high + (ta.atr(30) * 0.6)

// Seçilen Doji türlerini gösterme
if showDoji and C_NormalDoji
    if showDojiLower and Doji_RSI_Condition_Lower
        var ttLowerDoji = "Alt Sınır Doji (RSI <= 30): Yükseliş eğilimi gösterebilir."
        label.new(bar_index, patternLabelPosLow, text="D", style=label.style_label_up, color = labelColor, textcolor=color.white, tooltip = ttLowerDoji)

    if showDojiUpper and Doji_RSI_Condition_Upper
        var ttUpperDoji = "Üst Sınır Doji (RSI >= 70): Düşüş eğilimi gösterebilir."
        label.new(bar_index, patternLabelPosLow, text="D", style=label.style_label_up, color = labelColor, textcolor=color.white, tooltip = ttUpperDoji)

    if showDojiNeutral and Doji_RSI_Condition_Neutral
        var ttNeutralDoji = "Normal Doji (RSI 30-70): Kararsızlık durumu."
        label.new(bar_index, patternLabelPosLow, text="D", style=label.style_label_up, color = labelColor, textcolor=color.white, tooltip = ttNeutralDoji)

// Arka Plan Rengini Güncelleme
bgcolor(Doji_RSI_Condition_Lower ? color.new(color.green, 90) :
       Doji_RSI_Condition_Upper ? color.new(color.red, 90) :
       Doji_RSI_Condition_Neutral ? color.new(color.gray, 90) : na)
````
