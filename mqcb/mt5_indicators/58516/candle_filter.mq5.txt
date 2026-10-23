//+------------------------------------------------------------------+
//|                                                Candle Filter.mq5 |
//|                  Copyright 2019-2025, Virologista Kerntopf Corp. |
//|                 https://www.mql5.com/pt/users/virologustavo/news |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019-2025, Virologista Kerntopf Corp."
#property link      "https://www.mql5.com/pt/users/virologustavo/news"
#property version   "1.00"
//--- Configuração do indicador
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   1
//--- Configuração dos candles
#property indicator_label1  "Candle Filter"
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  clrForestGreen, clrDarkRed, clrGold, clrBlack
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- Enum para controle da exibição dos candles
enum DisplayCandle
  {
   ShowBullish   = 0, // Exibir apenas os candles de alta
   ShowBearish   = 1, // Exibir apenas os candles de baixa
   ShowDoji      = 2, // Exibir apenas os candles tipo doji
   ShowAllCandle = 3  // Exibir todos os candles
  };
//--- Parâmetros de entrada
input DisplayCandle InpCandleShow = ShowBullish; // Tipo de candle a exibir
input color InpBullishColor = clrForestGreen;   // Cor dos candles de alta
input color InpBearishColor = clrDarkRed;       // Cor dos candles de baixa
input color InpDojiColor    = clrGold;          // Cor dos candles tipo Doji
input color InpBackgroundColor = clrBlack;      // Cor de fundo no gráfico
input double InpDojiThreshold = 0.1;            // Limite para detecção de candles Doji (em %)
//--- Buffers dos candles
double ExtOpenBuffer[];    // Buffer para valores de abertura
double ExtHighBuffer[];    // Buffer para valores de máxima
double ExtLowBuffer[];     // Buffer para valores de mínima
double ExtCloseBuffer[];   // Buffer para valores de fechamento
double ExtFilterColors[];  // Buffer para cores
//+------------------------------------------------------------------+
//| Função de inicialização                                          |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Mapeamento dos buffers do indicador
   SetIndexBuffer(0, ExtOpenBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, ExtHighBuffer, INDICATOR_DATA);
   SetIndexBuffer(2, ExtLowBuffer, INDICATOR_DATA);
   SetIndexBuffer(3, ExtCloseBuffer, INDICATOR_DATA);
   SetIndexBuffer(4, ExtFilterColors, INDICATOR_COLOR_INDEX);
//--- Define o nome curto do indicador
   string short_name = StringFormat("Candle Filter",InpBackgroundColor);
   IndicatorSetString(INDICATOR_SHORTNAME, short_name);
//--- Define o número de cores indexadas, usado para plotar no gráfico
   PlotIndexSetInteger(0, PLOT_COLOR_INDEXES, 4); // 4 cores: ShowBullish, ShowBearish, ShowDoji, fundo
//--- Configuração das cores padrão
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, 0, InpBullishColor); // Define a cor dos candles de alta
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, 1, InpBearishColor); // Define a cor dos candles de baixa
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, 2, InpDojiColor);    // Define a cor dos candles tipo Doji
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, 3, InpBackgroundColor); // Cor do fundo (preto)
//--- Configuração dos valores vazios
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Função de cálculo principal                                      |
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
   int to_copy;
//--- Ponto de partida
   to_copy = (prev_calculated < 1) ? 1 : (rates_total != prev_calculated) ? prev_calculated : prev_calculated - 1;
//--- Loop principal
   for(int i = to_copy; i < rates_total && !IsStopped(); i++)
     {
      //--- Valores atuais
      double current_open = open[i];
      double current_close = close[i];
      double current_high = high[i];
      double current_low = low[i];
      //--- Calcula o valor de Point dinamicamente
      double point_value = SymbolInfoDouble(Symbol(), SYMBOL_POINT);
      //--- Verifica o tipo de candle
      bool is_doji = false;
      double candle_body = MathAbs(current_close - current_open);
      double candle_range = current_high - current_low;
      if(candle_range > 0) // Evita divisão por zero
         is_doji = (candle_body / candle_range) <= (InpDojiThreshold / 100.0);
      bool is_bullish = current_close > current_open;
      bool is_bearish = current_close < current_open;
      //--- Limpa os buffers para este índice
      ExtOpenBuffer[i] = EMPTY_VALUE;
      ExtHighBuffer[i] = EMPTY_VALUE;
      ExtLowBuffer[i] = EMPTY_VALUE;
      ExtCloseBuffer[i] = EMPTY_VALUE;
      ExtFilterColors[i] = EMPTY_VALUE;
      //--- Lógica para exibir candles com base no input InpCandleShow
      switch(InpCandleShow)
        {
         case ShowBullish:
            if(is_bullish)
              {
               ExtOpenBuffer[i] = current_open;
               ExtHighBuffer[i] = current_high;
               ExtLowBuffer[i] = current_low;
               ExtCloseBuffer[i] = current_close;
               ExtFilterColors[i] = 0; // Índice da cor verde (ShowBullish)
              }
            else
              {
               ExtOpenBuffer[i] = current_open;
               ExtHighBuffer[i] = current_high;
               ExtLowBuffer[i] = current_low;
               ExtCloseBuffer[i] = current_close;
               ExtFilterColors[i] = 3; // Índice da cor do fundo (preto)
              }
            break;
         case ShowBearish:
            if(is_bearish)
              {
               ExtOpenBuffer[i] = current_open;
               ExtHighBuffer[i] = current_high;
               ExtLowBuffer[i] = current_low;
               ExtCloseBuffer[i] = current_close;
               ExtFilterColors[i] = 1; // Índice da cor vermelha (ShowBearish)
              }
            else
              {
               ExtOpenBuffer[i] = current_open;
               ExtHighBuffer[i] = current_high;
               ExtLowBuffer[i] = current_low;
               ExtCloseBuffer[i] = current_close;
               ExtFilterColors[i] = 3; // Índice da cor do fundo (preto)
              }
            break;
         case ShowDoji:
            if(is_doji)
              {
               ExtOpenBuffer[i] = current_open;
               ExtHighBuffer[i] = current_high;
               ExtLowBuffer[i] = current_low;
               ExtCloseBuffer[i] = current_close;
               ExtFilterColors[i] = 2; // Índice da cor dourada (ShowDoji)
              }
            else
              {
               ExtOpenBuffer[i] = current_open;
               ExtHighBuffer[i] = current_high;
               ExtLowBuffer[i] = current_low;
               ExtCloseBuffer[i] = current_close;
               ExtFilterColors[i] = 3; // Índice da cor do fundo (preto)
              }
            break;
         case ShowAllCandle:
            if(is_bullish)
               ExtFilterColors[i] = 0; // Verde
            else
               if(is_bearish)
                  ExtFilterColors[i] = 1; // Vermelho
               else
                  if(is_doji)
                     ExtFilterColors[i] = 2; // Dourado
            ExtOpenBuffer[i] = current_open;
            ExtHighBuffer[i] = current_high;
            ExtLowBuffer[i] = current_low;
            ExtCloseBuffer[i] = current_close;
            break;
        }
     }
//--- Retorno do valor de prev_calculated para a próxima chamada
   return(rates_total);
  }
//+------------------------------------------------------------------+
