//+------------------------------------------------------------------+
//|                                                  MarketInfo.mq5  |
//|                                 Musa Khunarikov, Copyright 2026. |
//|                      https://www.mql5.com/ru/users/musa1994/news |
//+------------------------------------------------------------------+
#property copyright "Musa Khunarikov, 2026"
#property link      "https://www.mql5.com/ru/users/musa1994/news"
#property version   "1.00"
#property script_show_inputs

#property description "MarketInfo — скрипт анализа рынка."
#property description "Выводит спред, ATR, время до закрытия бара, статистику за N баров."

//--- Настройки
input int    BarsToAnalyze = 20;      // Сколько баров анализировать
input int    ATRPeriod     = 14;      // Период ATR

//+------------------------------------------------------------------+
//| Точка входа скрипта (ФИКСИРОВАННАЯ функция)                      |
//+------------------------------------------------------------------+
void OnStart()
{
   Print("=== MarketInfo запущен ===");
   Print("Символ: ", _Symbol, " | Период: ", _Period, " | Время: ", TimeToString(TimeCurrent()));

   //--- 1. Цены и спред
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   int    spreadPoints = (int)MathRound((ask - bid) / _Point);

   Print("Bid: ", DoubleToString(bid, _Digits),
         " | Ask: ", DoubleToString(ask, _Digits),
         " | Спред: ", spreadPoints, " пунктов");

   //--- 2. Спецификация символа
   double minLot  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxLot  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   int    digits  = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);

   Print("Лот: мин=", minLot, " макс=", maxLot, " шаг=", lotStep);
   Print("Знаков после запятой: ", digits);

   //--- 3. Волатильность (ATR)
   int atrHandle = iATR(_Symbol, _Period, ATRPeriod);
   if(atrHandle == INVALID_HANDLE) {
      Print("Ошибка создания ATR. Код: ", GetLastError());
      return;
   }

   double atr[1];
   if(CopyBuffer(atrHandle, 0, 0, 1, atr) > 0) {
      Print("ATR(", ATRPeriod, "): ", DoubleToString(atr[0], _Digits),
            " (", (int)MathRound(atr[0] / _Point), " пунктов)");
   }
   IndicatorRelease(atrHandle);

   //--- 4. Время до закрытия текущего бара
   datetime barTime   = iTime(_Symbol, _Period, 0);
   int      periodSec = PeriodSeconds(_Period);
   int      elapsed   = (int)(TimeCurrent() - barTime);
   int      remaining = periodSec - elapsed;

   Print("Бар открыт: ", TimeToString(barTime),
         " | Осталось: ", remaining / 60, " мин ", remaining % 60, " сек");

   //--- 5. Статистика за N баров
   if(Bars(_Symbol, _Period) < BarsToAnalyze) {
      Print("Недостаточно баров для анализа (нужно ", BarsToAnalyze, ")");
      return;
   }

   double highMax = iHigh(_Symbol, _Period, iHighest(_Symbol, _Period, MODE_HIGH, BarsToAnalyze, 0));
   double lowMin  = iLow(_Symbol, _Period, iLowest(_Symbol, _Period, MODE_LOW, BarsToAnalyze, 0));

   double closeSum = 0;
   long   volSum   = 0;
   for(int i = 0; i < BarsToAnalyze; i++) {
      closeSum += iClose(_Symbol, _Period, i);
      volSum   += iVolume(_Symbol, _Period, i);
   }
   double avgClose = closeSum / BarsToAnalyze;
   double avgVol   = (double)volSum / BarsToAnalyze;

   Print("--- Статистика за ", BarsToAnalyze, " баров ---");
   Print("Максимум: ", DoubleToString(highMax, _Digits));
   Print("Минимум:  ", DoubleToString(lowMin, _Digits));
   Print("Средний Close: ", DoubleToString(avgClose, _Digits));
   Print("Средний Volume: ", DoubleToString(avgVol, 0));
   Print("Диапазон: ", (int)MathRound((highMax - lowMin) / _Point), " пунктов");

   //--- 6. Определение тренда
   double firstClose = iClose(_Symbol, _Period, BarsToAnalyze - 1);
   double lastClose  = iClose(_Symbol, _Period, 0);

   string trend = "Боковик";
   if(lastClose > firstClose * 1.001)      trend = "Восходящий";
   else if(lastClose < firstClose * 0.999) trend = "Нисходящий";

   Print("Тренд за ", BarsToAnalyze, " баров: ", trend);

   Comment("MarketInfo: ", _Symbol,
           " | Спред: ", spreadPoints, " пт",
           " | ATR: ", (int)MathRound(atr[0] / _Point), " пт",
           " | Тренд: ", trend);

   Print("=== MarketInfo завершён ===");
}
//+------------------------------------------------------------------+