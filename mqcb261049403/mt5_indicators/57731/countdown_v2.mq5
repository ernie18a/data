//+------------------------------------------------------------------+
//|                                                    Countdown.mq5 |
//|                  Copyright 2019-2025, Virologista Kerntopf Corp. |
//|                 https://www.mql5.com/pt/users/virologustavo/news |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019-2025, Virologista Kerntopf Corp."
#property link      "https://www.mql5.com/pt/users/virologustavo/news"
#property version   "2.0"
//--- Configurações do indicador
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots 0
//--- Parâmetros de entrada
enum DisplayPosition
  {
   CommentDisplay = 0, // Exibir no comentário
   ChartCorner = 1,    // Exibir nas bordas do gráfico
   NearPrice = 2,      // Exibir próximo ao preço
  };
input DisplayPosition InpTimerPosition = NearPrice;      // Posição do temporizador
input color InpTextColor = clrGoldenrod;                 // Cor do texto
input int InpFontSize = 8;                               // Tamanho da fonte
input ENUM_ANCHOR_POINT InpAnchorPoint = ANCHOR_LEFT_LOWER; // Ponto de ancoragem
input ENUM_BASE_CORNER InpCornerPosition = CORNER_LEFT_LOWER; // Canto de posicionamento
input string InpOpenMarket = "09:00";                    // Hora de abertura
input string InpCloseMarket = "18:30";                   // Hora de fechamento
//--- Variáveis globais
string countdownLabel = "lblNextCandle";
int openMarketHour, openingMinute;
int closeMarketHour, closingMinute;
datetime nextMarketOpen; // Armazena o próximo horário de abertura
//+------------------------------------------------------------------+
//| Função para obter o horário atual no fuso horário de Brasília    |
//+------------------------------------------------------------------+
datetime GetBrasiliaTime()
  {
   datetime gmtTime = TimeCurrent();
   int brasiliaOffset = -3 * 3600; // UTC-3 em segundos
   int currentOffset = TimeGMTOffset(); // Deslocamento automático (ajuste DST)
   return gmtTime + brasiliaOffset + currentOffset;
  }
//+------------------------------------------------------------------+
//| Função de inicialização do indicador                             |
//+------------------------------------------------------------------+
int OnInit()
  {
   ResetLastError(); // Reseta o último erro antes de iniciar
   if(!ParseTime(InpOpenMarket, openMarketHour, openingMinute))
     {
      Print("Erro: Formato de horário de abertura inválido. Use HH:MM (ex.: 09:00).");
      return INIT_FAILED;
     }
   if(!ParseTime(InpCloseMarket, closeMarketHour, closingMinute))
     {
      Print("Erro: Formato de horário de fechamento inválido. Use HH:MM (ex.: 18:30).");
      return INIT_FAILED;
     }
   return INIT_SUCCEEDED;
  }
//+------------------------------------------------------------------+
//| Função de desinicialização do indicador                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ResetLastError(); // Reseta o último erro antes de limpar
   Comment(""); // Limpa comentários
   if(ObjectFind(0, countdownLabel) != -1)
     {
      ObjectDelete(0, countdownLabel); // Remove o rótulo, se existir
     }
  }
//+------------------------------------------------------------------+
//| Função para processar strings de tempo no formato HH:MM          |
//+------------------------------------------------------------------+
bool ParseTime(string timeStr, int &hour, int &minute)
  {
   int colonIndex = StringFind(timeStr, ":");
   if(colonIndex == -1 || StringLen(timeStr) != 5)    // Verifica formato HH:MM
     {
      Print("Erro: Formato de hora inválido. Use HH:MM (ex.: 09:00).");
      return false;
     }
   hour = StringToInteger(StringSubstr(timeStr, 0, colonIndex));
   minute = StringToInteger(StringSubstr(timeStr, colonIndex + 1));
   if(hour < 0 || hour > 23 || minute < 0 || minute > 59)
     {
      Print("Erro: Horário fora do intervalo válido. Use 00:00 a 23:59.");
      return false;
     }
   return true;
  }
//+------------------------------------------------------------------+
//| Função para verificar se o mercado está aberto                   |
//+------------------------------------------------------------------+
bool IsMarketOpen(int openHour, int openMinute, int closeHour, int closeMinute)
  {
   datetime currentTime = GetBrasiliaTime();
   int rawDay = (int)MathMod((currentTime / 86400), 7); // Dia bruto (0=domingo, 1=segunda, ..., 6=sábado)
   int currentDay = (int)MathMod((rawDay + 3), 7); // Ajusta para Segunda-feira = 0, Domingo = 6
   if(currentDay >= 0 && currentDay <= 4)    // Segunda a Sexta-feira
     {
      datetime marketOpenTime = StringToTime(TimeToString(currentTime, TIME_DATE) + " " +
                                             IntegerToString(openHour, 2, '0') + ":" +
                                             IntegerToString(openMinute, 2, '0'));
      datetime marketCloseTime = StringToTime(TimeToString(currentTime, TIME_DATE) + " " +
                                              IntegerToString(closeHour, 2, '0') + ":" +
                                              IntegerToString(closeMinute, 2, '0'));
      if(currentDay == 4 && currentTime > marketCloseTime)    // Sexta-feira após o fechamento
        {
         return false; // Mercado fechado
        }
      if(currentTime >= marketOpenTime && currentTime < marketCloseTime)
        {
         return true; // Mercado aberto
        }
     }
   return false; // Mercado fechado
  }
//+------------------------------------------------------------------+
//| Função para calcular o próximo horário de abertura               |
//+------------------------------------------------------------------+
datetime CalculateNextMarketOpen(datetime currentTime, int openHour, int openMinute)
  {
   int rawDay = (int)MathMod((currentTime / 86400), 7); // Dia bruto (0=domingo, 1=segunda, ..., 6=sábado)
   int currentDay = (int)MathMod((rawDay + 3), 7); // Ajusta para Segunda-feira = 0, Domingo = 6
   datetime nextMarketOpen = StringToTime(TimeToString(currentTime, TIME_DATE) + " " +
                                          IntegerToString(openHour, 2, '0') + ":" +
                                          IntegerToString(openMinute, 2, '0'));
//--- Se for sábado ou domingo, ajusta para a próxima segunda-feira
   if(currentDay == 5 || currentDay == 6)  // Sábado (5) ou Domingo (6)
     {
      int daysUntilMonday = (7 - currentDay) % 7; // Dias até a próxima segunda-feira
      nextMarketOpen += daysUntilMonday * 24 * 3600; // Avança para segunda-feira
      nextMarketOpen = StringToTime(TimeToString(nextMarketOpen, TIME_DATE) + " " +
                                    IntegerToString(openHour, 2, '0') + ":" +
                                    IntegerToString(openMinute, 2, '0'));
     }
   else
     {
      //--- Se for dia de semana, avança para o próximo dia útil
      while(true)
        {
         if(currentDay >= 0 && currentDay <= 4)  // Verifica dias úteis (Segunda a Sexta)
           {
            if(currentTime < nextMarketOpen)
              {
               break; // Horário válido encontrado
              }
            nextMarketOpen += 24 * 3600; // Avança para o próximo dia
           }
         else
           {
            nextMarketOpen += 24 * 3600; // Avança para o próximo dia
           }
         currentDay = (int)MathMod(((nextMarketOpen / 86400) + 3), 7); // Atualiza o dia da semana
        }
     }
   return nextMarketOpen;
  }
//+------------------------------------------------------------------+
//| Função para criar e configurar o rótulo                          |
//+------------------------------------------------------------------+
void CreateLabel(string text, int x, int y, bool isLabel = true, color textColor = clrGoldenrod)
  {
   ResetLastError(); // Reseta o último erro antes de criar o objeto
   if(ObjectFind(0, countdownLabel) == -1)
     {
      if(isLabel)
        {
         ObjectCreate(0, countdownLabel, OBJ_LABEL, 0, 0, 0);
        }
      else
        {
         ObjectCreate(0, countdownLabel, OBJ_TEXT, 0, x, y);
        }
     }
   ObjectSetInteger(0, countdownLabel, OBJPROP_COLOR, textColor);
   ObjectSetString(0, countdownLabel, OBJPROP_TEXT, text);
   ObjectSetInteger(0, countdownLabel, OBJPROP_FONTSIZE, InpFontSize);
   ObjectSetString(0, countdownLabel, OBJPROP_FONT, "Arial");
   ObjectSetInteger(0, countdownLabel, OBJPROP_ANCHOR, InpAnchorPoint);
   ObjectSetInteger(0, countdownLabel, OBJPROP_CORNER, InpCornerPosition);
   ObjectSetInteger(0, countdownLabel, OBJPROP_SELECTABLE, true);
  }
//+------------------------------------------------------------------+
//| Função principal do indicador                                    |
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
   ArraySetAsSeries(close, true);
   ResetLastError();

   datetime currentTime = GetBrasiliaTime();

   if(!IsMarketOpen(openMarketHour, openingMinute, closeMarketHour, closingMinute))
     {
      //--- Calcula o próximo horário de abertura
      if(nextMarketOpen == 0 || currentTime >= nextMarketOpen)
        {
         nextMarketOpen = CalculateNextMarketOpen(currentTime, openMarketHour, openingMinute);
        }
      //--- Calcula o tempo restante até a próxima abertura
      long timeRemainingInSeconds = MathMax(0, nextMarketOpen - currentTime);
      int days = (int)(timeRemainingInSeconds / 86400); // Total de dias
      int hours = (int)((timeRemainingInSeconds % 86400) / 3600); // Horas restantes
      int minutes = (int)(((timeRemainingInSeconds % 86400) % 3600) / 60); // Minutos restantes
      int seconds = (int)(((timeRemainingInSeconds % 86400) % 3600) % 60); // Segundos restantes
      //--- Formata a mensagem com base no tempo restante
      string message;
      if(days > 0)
        {
         message = StringFormat("Falta %d dia(s), %02d:%02d:%02d", days, hours, minutes, seconds);
        }
      else
        {
         message = StringFormat("Próxima Abertura: %02d:%02d:%02d", hours, minutes, seconds);
        }
      //--- Exibe o cronômetro no formato escolhido
      switch(InpTimerPosition)
        {
         case CommentDisplay:
            Comment(message);
            break;
         case ChartCorner:
            CreateLabel(message, 0, 0, true, InpTextColor);
            break;
         case NearPrice:
            //--- Acompanha o preço em tempo real
            if(ObjectFind(0, countdownLabel) == -1)
              {
               ObjectCreate(0, countdownLabel, OBJ_TEXT, 0, time[0] + PeriodSeconds() * 2, close[0]);
              }
            ObjectSetInteger(0, countdownLabel, OBJPROP_COLOR, InpTextColor);
            ObjectSetString(0, countdownLabel, OBJPROP_TEXT, message);
            ObjectSetInteger(0, countdownLabel, OBJPROP_FONTSIZE, InpFontSize);
            ObjectSetString(0, countdownLabel, OBJPROP_FONT, "Arial");
            ObjectSetInteger(0, countdownLabel, OBJPROP_ANCHOR, InpAnchorPoint);
            ObjectMove(0, countdownLabel, 0, time[0] + PeriodSeconds() * 2, close[0]);
            break;
        }
      return rates_total;
     }
//--- Calcula o tempo restante até o próximo candlestick (mercado aberto)
   datetime nextCandleTime = iTime(Symbol(), Period(), 0) + PeriodSeconds();
   long timeRemainingInSeconds = MathMax(0, nextCandleTime - currentTime);
   int iH = (int)(timeRemainingInSeconds / 3600);
   int iM = (int)((timeRemainingInSeconds / 60) % 60);
   int iS = (int)(timeRemainingInSeconds % 60);
   string countdown = StringFormat("%02d:%02d:%02d", iH, iM, iS);
//--- Exibe o cronômetro no formato escolhido
   switch(InpTimerPosition)
     {
      case CommentDisplay:
         Comment("Contagem Regressiva: " + countdown);
         break;
      case ChartCorner:
         CreateLabel(countdown, 0, 0, true, InpTextColor);
         break;
      case NearPrice:
         //--- Acompanha o preço em tempo real
         if(ObjectFind(0, countdownLabel) == -1)
           {
            ObjectCreate(0, countdownLabel, OBJ_TEXT, 0, time[0] + PeriodSeconds() * 2, close[0]);
           }
         ObjectSetInteger(0, countdownLabel, OBJPROP_COLOR, InpTextColor);
         ObjectSetString(0, countdownLabel, OBJPROP_TEXT, countdown);
         ObjectSetInteger(0, countdownLabel, OBJPROP_FONTSIZE, InpFontSize);
         ObjectSetString(0, countdownLabel, OBJPROP_FONT, "Arial");
         ObjectSetInteger(0, countdownLabel, OBJPROP_ANCHOR, InpAnchorPoint);
         ObjectMove(0, countdownLabel, 0, time[0] + PeriodSeconds() * 2, close[0]);
         break;
     }
   return rates_total;
  }
//+------------------------------------------------------------------+
