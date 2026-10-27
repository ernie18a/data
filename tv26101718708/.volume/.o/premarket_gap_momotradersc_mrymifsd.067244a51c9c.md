計算：漲幅＝(close－前一根close)／前一根close
計算：實體占比＝abs(close－open)／(high－low)
做多：漲幅達門檻且 close > open 且 volume 達門檻且實體占比達門檻，且 datetime 屬於允許交易時段且當日尚未進場
出場：多單，close <= open 或 (close > open 且 volume <= 前一根持倉K棒的volume)