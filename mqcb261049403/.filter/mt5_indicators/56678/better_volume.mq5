//+------------------------------------------------------------------+
//|                                                 Better_Volume.mq5|
//|                  Copyright 2019-2025, Virologista Kerntopf Corp. |
//|                 https://www.mql5.com/pt/users/virologustavo/news |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019-2025, Virologista Kerntopf Corp."
#property link      "https://www.mql5.com/pt/users/virologustavo/news"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   2
#property indicator_minimum 0.0
//--- Plotagem do melhor volume
#property indicator_label1  "Better Volume"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrCrimson, clrDarkTurquoise, clrGold, clrLimeGreen, clrWhiteSmoke, clrMagenta
#property indicator_style1  STYLE_SOLID
#property indicator_width1  5
//--- Plotagem da média móvel
#property indicator_label2  "Média Móvel"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrMaroon
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2
//--- Parâmetros de entrada
input int InpMAPeriod = 100;           // Período da média móvel
input int InpLookBack = 20;            // Janela de lookback para comparações
input ENUM_APPLIED_VOLUME InpVolumeType = VOLUME_REAL; // Tipo de volume usado
//--- Buffers do indicador
double ExtBVBuffer[];
double ExtBVColors[];
double ExtMABuffer[];
//+------------------------------------------------------------------+
//| Função de inicialização do indicador personalizado               |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Mapeamento dos buffers do indicador
   SetIndexBuffer(0, ExtBVBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, ExtBVColors, INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2, ExtMABuffer, INDICATOR_DATA);
//--- Define o nome curto do indicador
   string short_name = StringFormat("Better Volume (%d,%d)", InpMAPeriod, InpLookBack);
   IndicatorSetString(INDICATOR_SHORTNAME, short_name);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Função de iteração do indicador personalizado                    |
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
//---
   int limit;
   int minbars = MathMax(20, MathMax(InpMAPeriod, InpLookBack));
//--- Define o ponto inicial para os cálculos
   if(prev_calculated == 0)
      limit = minbars;
   else
      limit = prev_calculated - 1;
//--- Itera da esquerda para a direita
   for(int i = limit; i < rates_total && !IsStopped(); i++)
     {
      //--- Obtém o volume com base no tipo selecionado
      double IntVolume = (InpVolumeType == VOLUME_TICK ? (double)tick_volume[i] : (double)volume[i]);
      //--- Reseta os buffers
      ExtBVBuffer[i] = IntVolume;
      ExtBVColors[i] = 1; // Cor padrão (Balanço de Volume)
      //--- Cálculos básicos
      double IntCandleRange = high[i] - low[i];
      double IntTimesRange = IntVolume * IntCandleRange;
      double IntDividedRange = IntCandleRange != 0 ? IntVolume / IntCandleRange : 0;
      //--- Média móvel
      double IntSumVolumes = 0;
      for(int n = i; n > i - InpMAPeriod; n--)
         IntSumVolumes += (InpVolumeType == VOLUME_TICK ? (double)tick_volume[n] : (double)volume[n]);
      ExtMABuffer[i] = NormalizeDouble(IntSumVolumes / InpMAPeriod, 0);
      //--- Encontra máximos e mínimos na janela de lookback
      double IntMaxTimesRange = 0, IntMaxDividedRange = 0, IntMinDividedRange = DBL_MAX;
      for(int n = i; n > i - InpLookBack; n--)
        {
         double IntVolTimesRange = (InpVolumeType == VOLUME_TICK ? (double)tick_volume[n] : (double)volume[n]) * (high[n] - low[n]);
         if(IntVolTimesRange > IntMaxTimesRange)
            IntMaxTimesRange = IntVolTimesRange;

         if(IntVolTimesRange != 0)
           {
            double IntVolDividedRange = (InpVolumeType == VOLUME_TICK ? (double)tick_volume[n] : (double)volume[n]) / (high[n] - low[n]);
            if(IntVolDividedRange > IntMaxDividedRange)
               IntMaxDividedRange = IntVolDividedRange;
            if(IntVolDividedRange < IntMinDividedRange)
               IntMinDividedRange = IntVolDividedRange;
           }
        }
      //--- Categorias de volume
      int minIndex = (InpVolumeType == VOLUME_TICK ? ArrayMinimum(tick_volume, i - 19, 20) : ArrayMinimum(volume, i - 19, 20));
      double IntMinVolume = (InpVolumeType == VOLUME_TICK ? (double)tick_volume[minIndex] : (double)volume[minIndex]);
      //--- Candle Fraco
      if(IntVolume == IntMinVolume)
         ExtBVColors[i] = 2;
      //--- Clímax de Compra
      if(IntTimesRange == IntMaxTimesRange && close[i] > (high[i] + low[i]) / 2)
         ExtBVColors[i] = 0;
      //--- Churn
      if(IntDividedRange == IntMaxDividedRange)
         ExtBVColors[i] = 3;
      //--- Clímax Churn
      if(IntTimesRange == IntMaxTimesRange && IntDividedRange == IntMaxDividedRange)
         ExtBVColors[i] = 5;
      //--- Clímax de Venda
      if(IntTimesRange == IntMaxTimesRange && close[i] <= (high[i] + low[i]) / 2)
         ExtBVColors[i] = 4;
      //--- Verificação adicional de churn
      double IntMiddlePrice = (high[i] + low[i]) / 2;
      if(IntCandleRange > IntMiddlePrice * 2 && IntDividedRange < IntMinDividedRange * 1.5)
         ExtBVColors[i] = 3;
     }
//--- Retorna o valor de prev_calculated para a próxima chamada
   return(rates_total);
  }
//+------------------------------------------------------------------+
