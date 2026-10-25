//+------------------------------------------------------------------+
//| SimpleTradeStats.mq5                                             |
//| Copyright 2024                                                   |
//| https://forge.mql5.io                                            |
//+------------------------------------------------------------------+
#property copyright "MTR - торговый эксперт для тех кто хочет иметь здоровый сон, 1-2 сделки в месяц, 2-10% профит при минимальной просадке."
#property link "https://www.mql5.com/ru/market/product/161700"
#property version "1.01"
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots 0

input bool   FilterCurrentMagic = true;  // Фильтровать по текущему Magic
input int    CurrentMagicNumber = 0;     // Magic номер (0 = авто)
input color  ProfitColor = clrLime;      // Цвет прибыли
input color  LossColor   = clrRed;       // Цвет убытков
input color  NeutralColor = clrGray;     // Цвет нейтральный
input int    HistoryDays  = 0;           // Период истории (0 = всё время)
input int    VertOffset   = 0;           // Смещение по вертикали
input int    FontSize     = 10;          // Размер шрифта
input string FontName     = "Arial";     // Название шрифта
input bool   ShowDateTime = true;        // Показывать дату/время

struct MagicStats
{
   int      magic;
   double   totalProfit;
   double   totalLoss;
   int      tradeCount;
   datetime lastTradeTime;
};

MagicStats statsArray[];
int statsCount = 0;
datetime lastUpdate = 0;
int detectedMagic = 0;
bool magicDetected = false;
bool currentFilterState;

//+------------------------------------------------------------------+
//| OnInit                                                           |
//+------------------------------------------------------------------+
int OnInit()
{
   IndicatorSetString(INDICATOR_SHORTNAME, "Simple Trade Stats");
   IndicatorSetInteger(INDICATOR_DIGITS, 2);

   ArrayResize(statsArray, 50);
   statsCount = 0;

   currentFilterState = FilterCurrentMagic;

   if (CurrentMagicNumber == 0)
      DetectCurrentMagic();
   else
   {
      detectedMagic = CurrentMagicNumber;
      magicDetected = true;
   }

   Print("Simple Trade Stats MT5 инициализирован");
   Print("Detected Magic: ", detectedMagic);
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| OnDeinit                                                         |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, "STS_");
   Comment("");
   Print("Simple Trade Stats деинициализирован");
}

//+------------------------------------------------------------------+
//| OnCalculate                                                      |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
{
   if (TimeCurrent() - lastUpdate < 30)
      return rates_total;

   lastUpdate = TimeCurrent();
   CollectStats();
   DisplayStats();

   return rates_total;
}

//+------------------------------------------------------------------+
//| Определение Magic                                                |
//+------------------------------------------------------------------+
void DetectCurrentMagic()
{
   for (int i = 0; i < PositionsTotal(); i++)
   {
      ulong ticket = PositionGetTicket(i);
      if (ticket > 0 && PositionSelectByTicket(ticket))
      {
         if (PositionGetString(POSITION_SYMBOL) == _Symbol)
         {
            detectedMagic = (int)PositionGetInteger(POSITION_MAGIC);
            magicDetected = true;
            Print("Magic определен (позиция): ", detectedMagic);
            return;
         }
      }
   }

   HistorySelect(0, TimeCurrent());
   int total = HistoryDealsTotal();
   for (int i = total - 1; i >= 0; i--)
   {
       ulong ticket = HistoryDealGetTicket(i);
      if (ticket > 0)
      {
         if (HistoryDealGetString(ticket, DEAL_SYMBOL) == _Symbol)
         {
            long type = HistoryDealGetInteger(ticket, DEAL_TYPE);
            if (type == DEAL_TYPE_BUY || type == DEAL_TYPE_SELL)
            {
               detectedMagic = (int)HistoryDealGetInteger(ticket, DEAL_MAGIC);
               magicDetected = true;
               Print("Magic определен (история): ", detectedMagic);
               return;
            }
         }
      }
   }

   magicDetected = false;
   Print("Magic не определен");
}

//+------------------------------------------------------------------+
//| Сбор статистики                                                  |
//+------------------------------------------------------------------+
void CollectStats()
{
   statsCount = 0;

   datetime fromTime = (HistoryDays > 0) ? TimeCurrent() - HistoryDays * 86400 : 0;
   HistorySelect(fromTime, TimeCurrent());
   int totalDeals = HistoryDealsTotal();
   if (totalDeals == 0)
   {
      Print("Нет сделок за период");
      return;
   }
   Print("Сделок: ", totalDeals, HistoryDays > 0 ? " за " + IntegerToString(HistoryDays) + " дн." : " за всё время");

   int magicNumbers[];
   double magicProfits[];
   double magicLosses[];
   int magicCounts[];
   datetime magicLastTimes[];
   int uniqueMagics = 0;

   for (int i = 0; i < totalDeals; i++)
   {
      ulong ticket = HistoryDealGetTicket(i);
      if (ticket <= 0) continue;

      string symbol = HistoryDealGetString(ticket, DEAL_SYMBOL);
      if (symbol != _Symbol) continue;

      long type = HistoryDealGetInteger(ticket, DEAL_TYPE);
      if (type != DEAL_TYPE_BUY && type != DEAL_TYPE_SELL) continue;

      long entry = HistoryDealGetInteger(ticket, DEAL_ENTRY);
      if (entry != DEAL_ENTRY_IN && entry != DEAL_ENTRY_OUT) continue;

      int magic = (int)HistoryDealGetInteger(ticket, DEAL_MAGIC);
      if (currentFilterState && magicDetected && magic != detectedMagic) continue;

      double profit = HistoryDealGetDouble(ticket, DEAL_PROFIT)
                    + HistoryDealGetDouble(ticket, DEAL_COMMISSION)
                    + HistoryDealGetDouble(ticket, DEAL_SWAP);
      datetime closeTime = (datetime)HistoryDealGetInteger(ticket, DEAL_TIME);

      int idx = -1;
      for (int j = 0; j < uniqueMagics; j++)
      {
         if (magicNumbers[j] == magic) { idx = j; break; }
      }

      if (idx == -1)
      {
         ArrayResize(magicNumbers, uniqueMagics + 1);
         ArrayResize(magicProfits, uniqueMagics + 1);
         ArrayResize(magicLosses, uniqueMagics + 1);
         ArrayResize(magicCounts, uniqueMagics + 1);
         ArrayResize(magicLastTimes, uniqueMagics + 1);

         magicNumbers[uniqueMagics] = magic;
         magicProfits[uniqueMagics] = 0;
         magicLosses[uniqueMagics] = 0;
         magicCounts[uniqueMagics] = 0;
         magicLastTimes[uniqueMagics] = closeTime;
         idx = uniqueMagics;
         uniqueMagics++;
      }

      if (entry == DEAL_ENTRY_OUT)
         magicCounts[idx]++;

      if (profit > 0)
         magicProfits[idx] += profit;
      else
         magicLosses[idx] += MathAbs(profit);

      if (closeTime > magicLastTimes[idx])
         magicLastTimes[idx] = closeTime;
   }

   for (int i = 0; i < uniqueMagics; i++)
   {
      MagicStats s;
      s.magic = magicNumbers[i];
      s.totalProfit = magicProfits[i];
      s.totalLoss = magicLosses[i];
      s.tradeCount = magicCounts[i];
      s.lastTradeTime = magicLastTimes[i];

      if (statsCount >= ArraySize(statsArray))
         ArrayResize(statsArray, statsCount + 10);

      statsArray[statsCount] = s;
      statsCount++;
   }

   for (int i = 0; i < statsCount - 1; i++)
   {
      for (int j = i + 1; j < statsCount; j++)
      {
         if (statsArray[j].magic < statsArray[i].magic)
         {
            MagicStats t = statsArray[i];
            statsArray[i] = statsArray[j];
            statsArray[j] = t;
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Отображение                                                      |
//+------------------------------------------------------------------+
void DisplayStats()
{
   ObjectsDeleteAll(0, "STS_");

   int chartH = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
   if (chartH < 100) chartH = 400;
   int rows = 10 + MathMin(statsCount, 10);
   int blockH = rows * 20;
   int yPos = MathMax(5, (chartH - blockH) / 2 + VertOffset);
   int lineH = 20;

   string header = "СТАТИСТИКА ПО MAGIC";
   if (currentFilterState && magicDetected)
      header += " [Только " + IntegerToString(detectedMagic) + "]";

   CreateLabel("STS_Header", header, 10, yPos, clrYellow);
   yPos += lineH + 5;

   int colMagic = 10;
   int colProfit = 80;
   int colLoss = 180;
   int colCount = 280;
   int colTime = 360;

   CreateLabel("STS_ColMagic", "Magic", colMagic, yPos, clrWhite);
   CreateLabel("STS_ColProfit", "Прибыль", colProfit, yPos, clrWhite);
   CreateLabel("STS_ColLoss", "Убыток", colLoss, yPos, clrWhite);
   CreateLabel("STS_ColCount", "Сделки", colCount, yPos, clrWhite);
   if (ShowDateTime)
      CreateLabel("STS_ColTime", "Время", colTime, yPos, clrWhite);

   yPos += lineH;

   double totalProfit = 0;
   double totalLoss = 0;
   int totalTrades = 0;

   for (int i = 0; i < statsCount; i++)
   {
      MagicStats s = statsArray[i];

      CreateLabel("STS_Magic_" + IntegerToString(i), IntegerToString(s.magic), colMagic, yPos, NeutralColor);

      string pt = DoubleToString(s.totalProfit, 2);
      if (s.totalProfit > 0) pt = "+" + pt;
      CreateLabel("STS_Profit_" + IntegerToString(i), pt, colProfit, yPos,
                 (s.totalProfit > 0) ? ProfitColor : NeutralColor);

      string lt = DoubleToString(s.totalLoss, 2);
      if (s.totalLoss > 0) lt = "-" + lt;
      CreateLabel("STS_Loss_" + IntegerToString(i), lt, colLoss, yPos,
                 (s.totalLoss > 0) ? LossColor : NeutralColor);

      CreateLabel("STS_Count_" + IntegerToString(i), IntegerToString(s.tradeCount), colCount, yPos, NeutralColor);

      if (ShowDateTime)
      {
         string tt = (s.lastTradeTime > 0) ? TimeToString(s.lastTradeTime, TIME_DATE | TIME_MINUTES) : "N/A";
         CreateLabel("STS_Time_" + IntegerToString(i), tt, colTime, yPos, NeutralColor);
      }

      totalProfit += s.totalProfit;
      totalLoss += s.totalLoss;
      totalTrades += s.tradeCount;

      yPos += lineH;
      if (yPos > 400 && i < statsCount - 1)
      {
         CreateLabel("STS_More", "...", colMagic, yPos, NeutralColor);
         break;
      }
   }

   yPos += 5;
   CreateLabel("STS_Separator", "--------------------------", colMagic, yPos, clrSilver);
   yPos += lineH;

   CreateLabel("STS_TotalLabel", "ИТОГО:", colMagic, yPos, clrWhite);

   string tpt = DoubleToString(totalProfit, 2);
   if (totalProfit > 0) tpt = "+" + tpt;
   CreateLabel("STS_TotalProfit", tpt, colProfit, yPos,
              (totalProfit > 0) ? ProfitColor : ((totalProfit < 0) ? LossColor : NeutralColor));

   string tlt = DoubleToString(totalLoss, 2);
   if (totalLoss > 0) tlt = "-" + tlt;
   CreateLabel("STS_TotalLoss", tlt, colLoss, yPos,
              (totalLoss > 0) ? LossColor : NeutralColor);

   CreateLabel("STS_TotalCount", IntegerToString(totalTrades), colCount, yPos, clrWhite);

   yPos += lineH;
   double net = totalProfit - totalLoss;
   string nt = "Чистая прибыль: " + DoubleToString(net, 2);
   if (net > 0) nt = "+" + nt;
   CreateLabel("STS_NetProfit", nt, colMagic, yPos,
              (net > 0) ? ProfitColor : ((net < 0) ? LossColor : NeutralColor));

   yPos += lineH + 10;
   string periodStr = "За всё время";
   if (HistoryDays > 0) periodStr = "За " + IntegerToString(HistoryDays) + " дн.";
   CreateLabel("STS_Period", periodStr, colMagic + 150, yPos, clrSilver);
   CreateLabel("STS_UpdateTime", "Обновлено: " + TimeToString(TimeCurrent(), TIME_SECONDS), colMagic, yPos, clrSilver);

   yPos += lineH;
   string fi = "Фильтр: ";
   if (currentFilterState && magicDetected)
      fi += "ВКЛ (Magic " + IntegerToString(detectedMagic) + ")";
   else if (currentFilterState && !magicDetected)
      fi += "ВКЛ (Magic не найден)";
   else
      fi += "ВЫКЛ (все Magic)";
   CreateLabel("STS_FilterInfo", fi, colMagic, yPos, clrSilver);

   yPos += lineH + 5;
   string btnName = "STS_Link2";
  
}

//+------------------------------------------------------------------+
//| OnChartEvent                                                      |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
   if (id == CHARTEVENT_OBJECT_CLICK && sparam == "STS_Link2")
   {
       }
}

//+------------------------------------------------------------------+
//| Создание метки (MQL5)                                            |
//+------------------------------------------------------------------+
void CreateLabel(string name, string text, int x, int y, color clr)
{
   ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetString(0, name, OBJPROP_FONT, FontName);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, FontSize);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
}

//+------------------------------------------------------------------+
//| Ручное обновление                                                |
//+------------------------------------------------------------------+
void UpdateStats()
{
   CollectStats();
   DisplayStats();
   Print("Статистика обновлена");
}

//+------------------------------------------------------------------+
//| Переключение фильтра                                             |
//+------------------------------------------------------------------+
void ToggleFilter()
{
   currentFilterState = !currentFilterState;
   CollectStats();
   DisplayStats();
   Print("Фильтр ", currentFilterState ? "ВКЛ" : "ВЫКЛ");
}

//+------------------------------------------------------------------+
//| Установка Magic                                                  |
//+------------------------------------------------------------------+
void SetMagic(int magic)
{
   detectedMagic = magic;
   magicDetected = true;
   CollectStats();
   DisplayStats();
   Print("Magic установлен: ", magic);
}
//+------------------------------------------------------------------+
