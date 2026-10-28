//+------------------------------------------------------------------+
//|                                         MACD_Color_Histogram.mq5 |
//|                  Copyright 2019-2025, Virologista Kerntopf Corp. |
//|                          https://www.mql5.com/en/users/gustavofk |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019-2025, Virologista Kerntopf Corp."
#property link      "https://www.mql5.com/en/users/gustavofk"
#property version   "1.00"
#property description "Histograma dinâmico popularizado por Thomas Aspray em 1986"
#property description "MACD-Histograma mede a distância entre o MACD e sua linha sinal"
#property description "A coloração das barras alterá-se conforme a inflexão das linhas MACD e sinal"
#property description "O alerta aciona conforme alternam-se as linhas MACD e sinal"

//--- Configurações do indicador
#property indicator_separate_window
#property indicator_buffers 8
#property indicator_plots   3

#include <MovingAverages.mqh>

//--- Tipos de plotagem
#property indicator_type1   DRAW_COLOR_LINE         // Linha MACD com cores dinâmicas
#property indicator_type2   DRAW_COLOR_LINE         // Linha Sinal com cores dinâmicas
#property indicator_type3   DRAW_COLOR_HISTOGRAM    // Histograma MACD com cores dinâmicas

//--- Largura das linhas e histograma
#property indicator_width1  1                       // Largura da linha MACD
#property indicator_width2  1                       // Largura da linha Sinal
#property indicator_width3  10                      // Largura do histograma

//--- Rótulos dos gráficos
#property indicator_label1  "Linha MACD"            // Rótulo da linha MACD
#property indicator_label2  "Linha Sinal"           // Rótulo da linha Sinal
#property indicator_label3  "Histograma MACD"       // Rótulo do histograma

//--- Estilos das linhas
#property indicator_style1  STYLE_SOLID             // Linha MACD sólida
#property indicator_style2  STYLE_DOT               // Linha Sinal pontilhada

//--- Parâmetros de entrada
input group "MACD Histograma"
input int InpFastEMA = 12;                          // Período da Média Móvel Curta
input int InpSlowEMA = 26;                          // Período da Média Móvel Longa
input int InpSignalSMA = 9;                         // Período da Média Móvel do Sinal
input ENUM_APPLIED_PRICE InpAppliedPrice = PRICE_CLOSE; // Preço aplicado ao cálculo

input group "Alarme"
input string InpSound = "alert.wav";                // Nome do arquivo de som para alertas
input uchar InpRepetitions = 1;                     // Número máximo de repetições do alerta
input uchar InpPause = 0;                           // Pausa entre alertas (em segundos)

//--- Buffers do indicador
double ExtMACDBuffer[];
double ExtMACDColors[];
double ExtSignalBuffer[];
double ExtSignalColors[];
double ExtHistogramBuffer[];
double ExtHistogramColors[];
double ExtOpenBuffer[];
double ExtHighBuffer[];
double ExtLowBuffer[];
double ExtCloseBuffer[];
double ExtFastMaBuffer[];
double ExtSlowMaBuffer[];

//--- Identificadores das médias móveis
int ExtFastMaHandle;
int ExtSlowMaHandle;

//--- Variáveis de controle para alarmes
datetime ExtSoundHandle = D'1970.01.01 00:00';      // Data/hora do último alerta sonoro
uchar ExtRepetitionsHandle = 0;                     // Contador de repetições do alerta
datetime ExtBarsHandle = D'1970.01.01 00:00';       // Data/hora da última barra processada

//+------------------------------------------------------------------+
//| Função de inicialização do indicador                             |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Verifica se os parâmetros de entrada são válidos
   if(InpFastEMA <= 0 || InpSlowEMA <= 0 || InpSignalSMA <= 0)
     {
      Print("Erro: Os períodos das médias móveis devem ser maiores que zero.");
      return(INIT_FAILED);
     }
   if(InpFastEMA >= InpSlowEMA)
     {
      Print("Erro: O período da média rápida deve ser menor que o da média lenta.");
      return(INIT_FAILED);
     }

//--- Mapeamento dos buffers
   SetIndexBuffer(0, ExtMACDBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, ExtMACDColors, INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2, ExtSignalBuffer, INDICATOR_DATA);
   SetIndexBuffer(3, ExtSignalColors, INDICATOR_COLOR_INDEX);
   SetIndexBuffer(4, ExtHistogramBuffer, INDICATOR_DATA);
   SetIndexBuffer(5, ExtHistogramColors, INDICATOR_COLOR_INDEX);
   SetIndexBuffer(6, ExtFastMaBuffer, INDICATOR_CALCULATIONS);
   SetIndexBuffer(7, ExtSlowMaBuffer, INDICATOR_CALCULATIONS);

//--- Define o número de cores indexadas e suas associações
   ConfigurePlotColors();

//--- Define o nome curto do indicador
   string short_name = StringFormat("MACD Histograma (%d,%d,%d)", InpFastEMA, InpSlowEMA, InpSignalSMA);
   IndicatorSetString(INDICATOR_SHORTNAME, short_name);

//--- Obtém os handles das médias móveis
   ExtFastMaHandle = iMA(Symbol(), Period(), InpFastEMA, 0, MODE_EMA, InpAppliedPrice);
   ExtSlowMaHandle = iMA(Symbol(), Period(), InpSlowEMA, 0, MODE_EMA, InpAppliedPrice);

   if(ExtFastMaHandle == INVALID_HANDLE || ExtSlowMaHandle == INVALID_HANDLE)
     {
      Print("Erro ao criar as médias móveis. Código de erro: ", GetLastError());
      return(INIT_FAILED);
     }

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Configura as cores dos gráficos                                 |
//+------------------------------------------------------------------+
void ConfigurePlotColors()
  {
//--- Cores para a linha MACD
   PlotIndexSetInteger(0, PLOT_COLOR_INDEXES, 4);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, 0, clrForestGreen);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, 1, clrDarkRed);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, 2, clrIndigo);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, 3, clrDarkCyan);

//--- Cores para a linha Sinal
   PlotIndexSetInteger(1, PLOT_COLOR_INDEXES, 4);
   PlotIndexSetInteger(1, PLOT_LINE_COLOR, 0, clrLime);
   PlotIndexSetInteger(1, PLOT_LINE_COLOR, 1, clrCrimson);
   PlotIndexSetInteger(1, PLOT_LINE_COLOR, 2, clrDarkViolet);
   PlotIndexSetInteger(1, PLOT_LINE_COLOR, 3, clrCyan);

//--- Cores para o histograma
   PlotIndexSetInteger(2, PLOT_COLOR_INDEXES, 9);
   PlotIndexSetInteger(2, PLOT_LINE_COLOR, 0, clrDarkCyan);
   PlotIndexSetInteger(2, PLOT_LINE_COLOR, 1, clrCyan);
   PlotIndexSetInteger(2, PLOT_LINE_COLOR, 2, clrForestGreen);
   PlotIndexSetInteger(2, PLOT_LINE_COLOR, 3, clrLime);
   PlotIndexSetInteger(2, PLOT_LINE_COLOR, 4, clrIndigo);
   PlotIndexSetInteger(2, PLOT_LINE_COLOR, 5, clrDarkViolet);
   PlotIndexSetInteger(2, PLOT_LINE_COLOR, 6, clrDarkRed);
   PlotIndexSetInteger(2, PLOT_LINE_COLOR, 7, clrCrimson);
   PlotIndexSetInteger(2, PLOT_LINE_COLOR, 8, clrWhite);
  }

//+------------------------------------------------------------------+
//| Função principal para cálculo do indicador                       |
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
//--- Verifica se há dados suficientes
   if(rates_total < InpSignalSMA)
      return(0);

//--- Calcula os dados das médias móveis
   if(!CalculateMAs(rates_total, prev_calculated))
      return(0);

//--- Calcula o MACD, a linha de sinal e o histograma
   CalculateMACDAndSignal(rates_total, prev_calculated);

//--- Verifica condições para disparar alertas
   CheckAlerts(rates_total, time);

   return(rates_total);
  }

//+------------------------------------------------------------------+
//| Calcula as médias móveis rápidas e lentas                       |
//+------------------------------------------------------------------+
bool CalculateMAs(const int rates_total, const int prev_calculated)
  {
   int to_copy = (prev_calculated > 0) ? rates_total - prev_calculated + 1 : rates_total;

   if(CopyBuffer(ExtFastMaHandle, 0, 0, to_copy, ExtFastMaBuffer) <= 0 ||
      CopyBuffer(ExtSlowMaHandle, 0, 0, to_copy, ExtSlowMaBuffer) <= 0)
     {
      Print("Erro ao copiar buffers das médias móveis. Código de erro: ", GetLastError());
      return(false);
     }

   return(true);
  }

//+------------------------------------------------------------------+
//| Calcula o MACD, a linha de sinal e o histograma                 |
//+------------------------------------------------------------------+
void CalculateMACDAndSignal(const int rates_total, const int prev_calculated)
  {
   int limit = (prev_calculated > 0) ? prev_calculated - 1 : 0;

   for(int i = limit; i < rates_total && !IsStopped(); i++)
     {
      //--- Calcula o MACD
      ExtMACDBuffer[i] = ExtFastMaBuffer[i] - ExtSlowMaBuffer[i];

      //--- Calcula a linha de sinal
      SimpleMAOnBuffer(rates_total, prev_calculated, 0, InpSignalSMA, ExtMACDBuffer, ExtSignalBuffer);

      //--- Calcula o histograma
      ExtHistogramBuffer[i] = ExtMACDBuffer[i] - ExtSignalBuffer[i];

      //--- Define as cores para o MACD, linha de sinal e histograma
      SetColors(i);
     }
  }

//+------------------------------------------------------------------+
//| Define as cores para o MACD, linha de sinal e histograma        |
//+------------------------------------------------------------------+
void SetColors(const int index)
  {
//--- Cores para a linha MACD
   ExtMACDColors[index] = (ExtMACDBuffer[index] > 0 && ExtMACDBuffer[index] > ExtSignalBuffer[index]) ? 3 :
                          (ExtMACDBuffer[index] > 0 && ExtMACDBuffer[index] < ExtSignalBuffer[index]) ? 2 :
                          (ExtMACDBuffer[index] < ExtSignalBuffer[index]) ? 1 : 0;

//--- Cores para a linha de sinal
   ExtSignalColors[index] = (ExtSignalBuffer[index] > 0 && ExtMACDBuffer[index] > ExtSignalBuffer[index]) ? 3 :
                            (ExtSignalBuffer[index] > 0 && ExtMACDBuffer[index] < ExtSignalBuffer[index]) ? 2 :
                            (ExtMACDBuffer[index] < ExtSignalBuffer[index]) ? 1 : 0;

//--- Cores para o histograma
   if(ExtHistogramBuffer[index] > 0 && ExtMACDBuffer[index] > 0 && ExtMACDBuffer[index] > ExtHistogramBuffer[index] && ExtSignalBuffer[index] < ExtHistogramBuffer[index])
      ExtHistogramColors[index] = 0;
   else
      if(ExtHistogramBuffer[index] > 0 && ExtMACDBuffer[index] > 0 && ExtMACDBuffer[index] > ExtHistogramBuffer[index] && ExtSignalBuffer[index] > ExtHistogramBuffer[index])
         ExtHistogramColors[index] = 1;
      else
         if(ExtHistogramBuffer[index] > 0 && ExtMACDBuffer[index] > 0 && ExtMACDBuffer[index] < ExtHistogramBuffer[index] && ExtSignalBuffer[index] < ExtHistogramBuffer[index])
            ExtHistogramColors[index] = 2;
         else
            if(ExtHistogramBuffer[index] > 0 && ExtMACDBuffer[index] < 0)
               ExtHistogramColors[index] = 3;
            else
               if(ExtHistogramBuffer[index] < 0 && ExtMACDBuffer[index] < 0 && ExtMACDBuffer[index] > ExtHistogramBuffer[index] && ExtSignalBuffer[index] > ExtHistogramBuffer[index])
                  ExtHistogramColors[index] = 4;
               else
                  if(ExtHistogramBuffer[index] < 0 && ExtMACDBuffer[index] > 0)
                     ExtHistogramColors[index] = 5;
                  else
                     if(ExtHistogramBuffer[index] < 0 && ExtMACDBuffer[index] < 0 && ExtMACDBuffer[index] < ExtHistogramBuffer[index] && ExtSignalBuffer[index] > ExtHistogramBuffer[index])
                        ExtHistogramColors[index] = 6;
                     else
                        if(ExtHistogramBuffer[index] < 0 && ExtMACDBuffer[index] < 0 && ExtMACDBuffer[index] < ExtHistogramBuffer[index] && ExtSignalBuffer[index] < ExtHistogramBuffer[index])
                           ExtHistogramColors[index] = 7;
                        else
                           ExtHistogramColors[index] = 8;
  }

//+------------------------------------------------------------------+
//| Verifica condições para disparar alertas                        |
//+------------------------------------------------------------------+
void CheckAlerts(const int rates_total, const datetime &time[])
  {
   datetime time_0 = time[rates_total - 1];
   if(time_0 != ExtBarsHandle)
     {
      ExtSoundHandle = D'1970.01.01 00:00';
      ExtRepetitionsHandle = 0;
      ExtBarsHandle = time_0;
     }

   int i = rates_total - 1;

   if((ExtMACDBuffer[i - 1] < ExtSignalBuffer[i - 1] && ExtMACDBuffer[i] > ExtSignalBuffer[i]) ||
      (ExtMACDBuffer[i - 1] > ExtSignalBuffer[i - 1] && ExtMACDBuffer[i] < ExtSignalBuffer[i]) ||
      (ExtMACDBuffer[i - 1] < 0.0 && ExtMACDBuffer[i] > 0.0) ||
      (ExtMACDBuffer[i - 1] > 0.0 && ExtMACDBuffer[i] < 0.0))
     {
      if(ExtRepetitionsHandle >= InpRepetitions)
         return;

      datetime time_current = TimeCurrent();
      if(time_current - ExtSoundHandle > InpPause)
        {
         if(ExtMACDBuffer[i - 1] < ExtSignalBuffer[i - 1] && ExtMACDBuffer[i] > ExtSignalBuffer[i])
           {
            PlaySound(InpSound);
            Alert("COMPRA - MACD cruzou a linha de sinal em ", TimeToString(time[i]));
            ExtSoundHandle = time_current;
            ExtRepetitionsHandle++;
           }
         else
            if(ExtMACDBuffer[i - 1] > ExtSignalBuffer[i - 1] && ExtMACDBuffer[i] < ExtSignalBuffer[i])
              {
               PlaySound(InpSound);
               Alert("VENDA - MACD cruzou a linha de sinal em ", TimeToString(time[i]));
               ExtSoundHandle = time_current;
               ExtRepetitionsHandle++;
              }
            else
               if(ExtMACDBuffer[i - 1] < 0.0 && ExtMACDBuffer[i] > 0.0)
                 {
                  PlaySound(InpSound);
                  Alert("COMPRA - MACD cruzou a região zero em ", TimeToString(time[i]));
                  ExtSoundHandle = time_current;
                  ExtRepetitionsHandle++;
                 }
               else
                  if(ExtMACDBuffer[i - 1] > 0.0 && ExtMACDBuffer[i] < 0.0)
                    {
                     PlaySound(InpSound);
                     Alert("VENDA - MACD cruzou a região zero em ", TimeToString(time[i]));
                     ExtSoundHandle = time_current;
                     ExtRepetitionsHandle++;
                    }
        }
     }
  }
//+------------------------------------------------------------------+
