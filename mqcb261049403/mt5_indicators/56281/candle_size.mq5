//+------------------------------------------------------------------+
//|                                                  Candle_size.mq5 |
//|                   Copyright 2019-2025, Virologista Kerntopf Corp.|
//|                          https://www.mql5.com/en/users/gustavofk |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019-2025, Virologista Kerntopf Corp."
#property link      "https://www.mql5.com/en/users/gustavofk"
#property version   "1.00"
#property description "Exibe o tamanho dos candles no gráfico para um dia específico da semana usando enum."
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots 0

//--- Definição do enum para os dias da semana
enum DaysOfWeek
  {
   Domingo = 0,   // Domingo
   Segunda = 1,   // Segunda-feira
   Terca = 2,     // Terça-feira
   Quarta = 3,    // Quarta-feira
   Quinta = 4,    // Quinta-feira
   Sexta = 5,     // Sexta-feira
   Sabado = 6     // Sábado
  };

//--- Parâmetros de entrada
input bool ProcessarTodosDias = false; // Processar todos os dias? (true = Sim, false = Não)
input DaysOfWeek DiasSelecionados = Segunda; // Escolher o dia da semana a ser medido
input color CorPesoAlta = clrGoldenrod; // Cor para candles de alta
input color CorPesoBaixa = clrSlateGray; // Cor para candles de baixa
input bool Distanciar = false;         // Ativar deslocamento?
input double Deslocamento = 50.0;      // Valor de deslocamento em pontos
input string Fonte = "Lucida Console"; // Fonte do texto
input int TamanhoFonte = 8;            // Tamanho da fonte
input ENUM_ANCHOR_POINT Ancora = ANCHOR_UPPER; // Tipo de ancoragem

//--- Variáveis globais
string ObjectPrefix = "MedidorCandle_"; // Prefixo para objetos

//+------------------------------------------------------------------+
//| Função de inicialização do indicador                             |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(DiasSelecionados < Domingo || DiasSelecionados > Sabado)
     {
      Print("Erro: Valor inválido para DiasSelecionados. Use um valor entre 0 (Domingo) e 6 (Sábado).");
      return INIT_PARAMETERS_INCORRECT;
     }
   ObjectPrefix += EnumToString(Period()) + "_";
   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//| Função de desinicialização do indicador                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   DeleteObjects();
  }

//+------------------------------------------------------------------+
//| Função para calcular o dia da semana usando TimeToStruct         |
//+------------------------------------------------------------------+
int GetDayOfWeek(datetime time)
  {
   MqlDateTime dt;
   TimeToStruct(time, dt); // Preenche a estrutura MqlDateTime com os detalhes da data
   return dt.day_of_week;  // Retorna o dia da semana (0 = Domingo, ..., 6 = Sábado)
  }

//+------------------------------------------------------------------+
//| Função principal de cálculo                                      |
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

   int start = (prev_calculated == 0) ? 0 : prev_calculated - 1;

   for(int i = start; i < rates_total && !IsStopped(); i++)
     {
      int dayOfWeek = GetDayOfWeek(time[i]);

      // Verifica se o candle deve ser processado
      if(!ProcessarTodosDias && dayOfWeek != DiasSelecionados)
         continue;

      string objectName = ObjectPrefix + TimeToString(time[i]);
      string labelText = CalculateSize(high[i], low[i]);

      double anchorPrice;
      color textColor;
      ENUM_ANCHOR_POINT anchorType;

      if(open[i] > close[i]) // Candle de baixa
        {
         anchorPrice = low[i] - (Distanciar ? Deslocamento * Point() : 0);
         textColor = CorPesoBaixa;
         anchorType = ANCHOR_UPPER;
        }
      else if(open[i] < close[i]) // Candle de alta
        {
         anchorPrice = high[i] + (Distanciar ? Deslocamento * Point() : 0);
         textColor = CorPesoAlta;
         anchorType = ANCHOR_LOWER;
        }
      else // Candle doji
        {
         anchorPrice = (high[i] + low[i]) / 2.0;
         textColor = clrWhiteSmoke;
         anchorType = ANCHOR_CENTER;
        }

      // Ajusta o preço para garantir que esteja dentro dos limites do gráfico
      anchorPrice = AdjustPriceToChartLimits(anchorPrice);

      if(!CreateTextObject(0, objectName, 0, time[i], anchorPrice, labelText, 0.0, Fonte, TamanhoFonte, textColor, anchorType))
        {
         Print("Falha ao criar o objeto de texto para o candle em ", TimeToString(time[i]));
         return 0;
        }
     }
   return rates_total;
  }

//+------------------------------------------------------------------+
//| Função para calcular o tamanho do candle                        |
//+------------------------------------------------------------------+
string CalculateSize(const double high, const double low)
  {
   double size = MathAbs(high - low);
   double pointAdjustment = (Digits() == 3 || Digits() == 5) ? Point() * 1000 : Point();
   return DoubleToString(size / pointAdjustment, 1); // Fixado em 1 casa decimal
  }

//+------------------------------------------------------------------+
//| Função para criar um objeto de texto                            |
//+------------------------------------------------------------------+
bool CreateTextObject(const long chartID, const string name, const int subWindow, datetime time, double price,
                      const string text, const double angle, const string font, const int size, const color clr,
                      const ENUM_ANCHOR_POINT anchor)
  {
   ResetLastError();

   if(ObjectFind(chartID, name) != -1)
     {
      ObjectDelete(chartID, name); // Remove o objeto existente
     }

   if(!ObjectCreate(chartID, name, OBJ_TEXT, subWindow, time, price))
     {
      Print(__FUNCTION__, ": Falha ao criar o objeto de texto '", name, "' no tempo ", TimeToString(time), ". Erro: ", GetLastError());
      return false;
     }

   ObjectSetString(chartID, name, OBJPROP_TEXT, text);
   ObjectSetString(chartID, name, OBJPROP_FONT, font);
   ObjectSetInteger(chartID, name, OBJPROP_FONTSIZE, size);
   ObjectSetDouble(chartID, name, OBJPROP_ANGLE, angle);
   ObjectSetInteger(chartID, name, OBJPROP_ANCHOR, anchor);
   ObjectSetInteger(chartID, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(chartID, name, OBJPROP_BACK, false);
   ObjectSetInteger(chartID, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(chartID, name, OBJPROP_HIDDEN, true);

   return true;
  }

//+------------------------------------------------------------------+
//| Função para deletar objetos                                      |
//+------------------------------------------------------------------+
void DeleteObjects()
  {
   ObjectsDeleteAll(0, ObjectPrefix);
  }

//+------------------------------------------------------------------+
//| Função para ajustar o preço aos limites do gráfico               |
//+------------------------------------------------------------------+
double AdjustPriceToChartLimits(double price)
  {
   double chartMin = ChartGetDouble(0, CHART_PRICE_MIN, 0); // Preço mínimo visível no gráfico
   double chartMax = ChartGetDouble(0, CHART_PRICE_MAX, 0); // Preço máximo visível no gráfico
   if(price < chartMin)
      return chartMin; // Ajusta para o mínimo do gráfico
   if(price > chartMax)
      return chartMax; // Ajusta para o máximo do gráfico
   return price; // Retorna o preço original se estiver dentro dos limites
  }
//+------------------------------------------------------------------+