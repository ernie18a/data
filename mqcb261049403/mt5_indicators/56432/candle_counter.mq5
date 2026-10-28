//+------------------------------------------------------------------+
//|                                               Candle Counter.mq5 |
//|                   Copyright 2019-2025, Virologista Kerntopf Corp.|
//|                  https://www.mql5.com/pt/users/virologustavo/news|
//+------------------------------------------------------------------+
#property copyright "Copyright 2019-2025, Virologista Kerntopf Corp."
#property link      "https://www.mql5.com/pt/users/virologustavo/news"
#property version   "2.40"
#property description "Exibe a numeração sequencial dos candles da semana selecionada ou todos os candles"
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1
//--- Parâmetros de entrada
input double PriceOffsetFactor = 0.5;              // Fator dinâmico de espaçamento
input color InpTextColorAbove = clrSpringGreen;    // Cor do texto acima do candle
input color InpTextColorBelow = clrMediumOrchid;   // Cor do texto abaixo do candle
input string InpFont = "Arial";                    // Tipo de fonte
input int InpFontSize = 8;                         // Tamanho da fonte
input ENUM_ANCHOR_POINT Anchor = ANCHOR_CENTER;    // Tipo de âncora
input bool NumberFirstCandle = true;               // O primeiro candle a ser contado é o último?
input int SelectedWeek = 1;                        // Semana selecionada para contagem (0 = Todas as semanas)
//--- Buffers
double ExtCounterBuffer[];
//--- Variáveis globais
string ObjectPrefix = "Candle_Counter_";        // Prefixo único para evitar conflitos
//+------------------------------------------------------------------+
//| Função de inicialização do indicador                             |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, ExtCounterBuffer, INDICATOR_DATA);
   ArrayInitialize(ExtCounterBuffer, EMPTY_VALUE);
   string short_name = StringFormat("Bar Counter (%s)", NumberFirstCandle ? "First" : "Last");
   IndicatorSetString(INDICATOR_SHORTNAME, short_name);
   return INIT_SUCCEEDED;
  }
//+------------------------------------------------------------------+
//| Função chamada quando o indicador é removido                     |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   DeleteObjects();
  }
//+------------------------------------------------------------------+
//| Função para obter o dia a partir de um datetime                  |
//+------------------------------------------------------------------+
int GetDay(datetime time)
  {
   MqlDateTime dt;
   TimeToStruct(time, dt);
   return dt.day; // Retorna o dia
  }
//+------------------------------------------------------------------+
//| Função para obter a semana do mês                               |
//+------------------------------------------------------------------+
int GetWeekOfMonth(datetime time)
  {
   MqlDateTime dt;
   TimeToStruct(time, dt);
   int day_of_month = dt.day;
   int day_of_week = dt.day_of_week;
   int week_of_month = (day_of_month + (6 - day_of_week)) / 7 + 1;
   return week_of_month;
  }
//+------------------------------------------------------------------+
//| Função principal de iteração do indicador                        |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   ArraySetAsSeries(time, true);
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
//--- 
   DeleteObjects();
//--- 
   int to_copy = (prev_calculated > 0 && prev_calculated <= rates_total) 
               ? rates_total - prev_calculated + 1 
               : rates_total;
//--- 
   for(int i = rates_total - to_copy; i < rates_total && !IsStopped(); i++)
     {
      int currentWeek = GetWeekOfMonth(time[i]);
//--- Ignorar candles que não pertencem à semana selecionada (exceto quando SelectedWeek == 0)
      if(SelectedWeek != 0 && currentWeek != SelectedWeek)
         continue;
//--- 
      int candleDay = GetDay(time[i]);
      int previousDay = (i > 0) ? GetDay(time[i - 1]) : -1;
//--- Reiniciar contagem para o novo dia
      if(candleDay != previousDay)
        {
         ExtCounterBuffer[i] = NumberFirstCandle ? 1 : EMPTY_VALUE;
        }
      else
        {
         ExtCounterBuffer[i] = NumberFirstCandle ? ExtCounterBuffer[i - 1] + 1 : EMPTY_VALUE;
        }
//--- 
      if(ExtCounterBuffer[i] != EMPTY_VALUE)
        {
         string objectName = ObjectPrefix + TimeToString(time[i]);
         string text = IntegerToString((int)ExtCounterBuffer[i]);
//--- 
         double priceOffset = PriceOffsetFactor * Point() * (SymbolInfoInteger(_Symbol, SYMBOL_DIGITS) * 150);
         double price = (open[i] > close[i]) ? low[i] - priceOffset : high[i] + priceOffset;
         color textColor = (open[i] > close[i]) ? InpTextColorBelow : InpTextColorAbove;
         CreateText(0, objectName, 0, time[i], price, text, 0.0, InpFont, InpFontSize, textColor, Anchor);
        }
     }
//--- 
   if(!NumberFirstCandle)
     {
      for(int i = rates_total - 1; i >= 0 && !IsStopped(); i--)
        {
         int currentWeek = GetWeekOfMonth(time[i]);
//--- Ignorar candles que não pertencem à semana selecionada (exceto quando SelectedWeek == 0)
         if(SelectedWeek != 0 && currentWeek != SelectedWeek)
            continue;
//--- 
         int candleDay = GetDay(time[i]);
         int nextDay = (i < rates_total - 1) ? GetDay(time[i + 1]) : -1;
//--- 
         if(candleDay != nextDay)
           {
            ExtCounterBuffer[i] = 1;
            int count = 1;
            for(int j = i - 1; j >= 0 && GetDay(time[j]) == candleDay; j--)
              {
               ExtCounterBuffer[j] = ++count;
              }
           }
        }
//--- 
      for(int i = 0; i < rates_total && !IsStopped(); i++)
        {
         int currentWeek = GetWeekOfMonth(time[i]);
//--- Ignorar candles que não pertencem à semana selecionada (exceto quando SelectedWeek == 0)
         if(SelectedWeek != 0 && currentWeek != SelectedWeek)
            continue;
//--- 
         if(ExtCounterBuffer[i] != EMPTY_VALUE)
           {
            string objectName = ObjectPrefix + TimeToString(time[i]);
            string text = IntegerToString((int)ExtCounterBuffer[i]);
//--- 
            double priceOffset = PriceOffsetFactor * Point() * (SymbolInfoInteger(_Symbol, SYMBOL_DIGITS) * 150);
            double price = (open[i] > close[i]) ? low[i] - priceOffset : high[i] + priceOffset;
            color textColor = (open[i] > close[i]) ? InpTextColorBelow : InpTextColorAbove;
            CreateText(0, objectName, 0, time[i], price, text, 0.0, InpFont, InpFontSize, textColor, Anchor);
           }
        }
     }
   return rates_total;
  }
//+------------------------------------------------------------------+
//| Função para criar texto no gráfico                               |
//+------------------------------------------------------------------+
bool CreateText(const long chartID,
                const string name,
                const int subWindow,
                datetime time,
                double price,
                const string text,
                const double angle,
                const string font,
                const int size,
                const color clr,
                const ENUM_ANCHOR_POINT anchor)
  {
   ResetLastError();
   if(!ObjectCreate(chartID, name, OBJ_TEXT, subWindow, time, price))
     {
      Print(__FUNCTION__, ": Falha ao criar objeto '", name, "'. Erro: ", GetLastError());
      return false;
     }
   if(!ObjectSetString(chartID, name, OBJPROP_TEXT, text) ||
      !ObjectSetString(chartID, name, OBJPROP_FONT, font) ||
      !ObjectSetInteger(chartID, name, OBJPROP_FONTSIZE, size) ||
      !ObjectSetDouble(chartID, name, OBJPROP_ANGLE, angle) ||
      !ObjectSetInteger(chartID, name, OBJPROP_ANCHOR, anchor) ||
      !ObjectSetInteger(chartID, name, OBJPROP_COLOR, clr))
     {
      Print(__FUNCTION__, ": Falha ao configurar propriedades do objeto '", name, "'. Erro: ", GetLastError());
      ObjectDelete(chartID, name);
      return false;
     }
   ObjectSetInteger(chartID, name, OBJPROP_BACK, false);
   ObjectSetInteger(chartID, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(chartID, name, OBJPROP_HIDDEN, true);

   return true;
  }
//+------------------------------------------------------------------+
//| Função para excluir objetos                                      |
//+------------------------------------------------------------------+
void DeleteObjects()
  {
   ResetLastError();
   int totalObjects = ObjectsTotal(0, 0, OBJ_TEXT);
   for(int i = totalObjects - 1; i >= 0; i--)
     {
      string objectName = ObjectName(0, i, 0, OBJ_TEXT);
      if(StringFind(objectName, ObjectPrefix) == 0)
        {
         if(!ObjectDelete(0, objectName))
           {
            PrintFormat("Erro ao excluir objeto '%s'. Código: %i", objectName, GetLastError());
           }
        }
     }
  }
//+------------------------------------------------------------------+