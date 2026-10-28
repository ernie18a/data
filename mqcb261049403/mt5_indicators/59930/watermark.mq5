//+------------------------------------------------------------------+
//|                                                    Watermark.mq5 |
//|                  Copyright 2019-2025, Virologista Kerntopf Corp. |
//|                 https://www.mql5.com/pt/users/virologustavo/news |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019-2025, Virologista Kerntopf Corp."
#property link      "https://www.mql5.com/pt/users/virologustavo/news"
#property version   "1.0"
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots 0
//--- Parâmetros de entrada
input color InpTextColor = C'25,25,25,150';        // Cor da marca d'água
input int InpFontSize = 70;                        // Tamanho base da fonte
//--- Variáveis globais
string wmSymbolLabel = "Ticker Symbol Name";       // Rótulo principal (símbolo + período)
string wmDescLabel = "Ticker Symbol Description";  // Descrição do ativo
string wmLabels[] = {wmSymbolLabel, wmDescLabel};  // Usado para exclusão em lote
long wmScreenWidth = 0;                            // Largura atual do gráfico
long wmScreenHeight = 0;                           // Altura atual do gráfico
long wmFontSize = 0;                               // Tamanho da fonte ajustado
//--- Protótipos das funções auxiliares
void wmCreateLabel(string wmName, string wmLabel);
void wmResizeLabel(string wmName, float wmRatio);
void wmPositionLabel(string wmName, long wmOffset);
string wmGetTimeframe(ENUM_TIMEFRAMES wmPeriod);
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Criar rótulos
   wmCreateLabel(wmSymbolLabel, StringFormat("📈%s :⏱%s", _Symbol, wmGetTimeframe(_Period)));
   wmCreateLabel(wmDescLabel, SymbolInfoString(_Symbol, SYMBOL_DESCRIPTION));

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Função principal do indicador                                   |
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
//--- Atualiza as dimensões do gráfico
   long wmChartWidth = ChartGetInteger(0, CHART_WIDTH_IN_PIXELS, 0);
   long wmChartHeight = ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS, 0);

   if(wmScreenWidth != wmChartWidth || wmScreenHeight != wmChartHeight)
     {
      wmScreenWidth = wmChartWidth;
      wmScreenHeight = wmChartHeight;
      wmFontSize = (InpFontSize * wmScreenWidth) / 1000;
      //--- Redimensiona os rótulos
      wmResizeLabel(wmSymbolLabel, 0.75);
      wmResizeLabel(wmDescLabel, 0.5);
      //--- Reposiciona os rótulos centralizados
      wmPositionLabel(wmSymbolLabel, 0);
      wmPositionLabel(wmDescLabel, wmFontSize + 5);

      ChartRedraw();
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Clean up objects created when removing the indicator             |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
//--- Garantir exclusão prévia (para evitar duplicados)
  {
   for(int i = 0; i < ArraySize(wmLabels); i++)
     {
      if(ObjectFind(0, wmLabels[i]) != -1)
         ObjectDelete(0, wmLabels[i]);
     }
  }
//+------------------------------------------------------------------+
//| Convert ENUM_TIMEFRAMES to string without prefix                 |
//+------------------------------------------------------------------+
string wmGetTimeframe(ENUM_TIMEFRAMES wmPeriod)
  {
//--- 
   string wmResult = EnumToString(wmPeriod);
   if(StringFind(wmResult, "PERIOD_", 0) == 0)
      return StringSubstr(wmResult, 7);
   else
      return "Unknown";
  }
//+------------------------------------------------------------------+
//| Create a label on the chart                                      |
//+------------------------------------------------------------------+
void wmCreateLabel(string wmName, string wmLabel)
  {
//--- 
   if(ObjectFind(0, wmName) != -1)
      ObjectDelete(0, wmName);

   ObjectCreate(0, wmName, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, wmName, OBJPROP_COLOR, InpTextColor);
   ObjectSetInteger(0, wmName, OBJPROP_ANCHOR, ANCHOR_CENTER);
   ObjectSetInteger(0, wmName, OBJPROP_FONTSIZE, InpFontSize);
   ObjectSetInteger(0, wmName, OBJPROP_BACK, true);
   ObjectSetString(0, wmName, OBJPROP_TEXT, wmLabel);
  }
//+------------------------------------------------------------------+
//| Resize the font size of a label                                  |
//+------------------------------------------------------------------+
void wmResizeLabel(string wmName, float wmRatio)
  {
   int wmFinalSize = MathMax(10, (int)(wmFontSize * wmRatio));
   if(ObjectFind(0, wmName) != -1)
     {
      if(!ObjectSetInteger(0, wmName, OBJPROP_FONTSIZE, wmFinalSize))
         Print("Erro ao redimensionar fonte do objeto: ", wmName);
     }
  }
//+------------------------------------------------------------------+
//| Position a label in the center of the chart                      |
//+------------------------------------------------------------------+
void wmPositionLabel(string wmName, long wmOffset)
  {
//--- 
   if(ObjectFind(0, wmName) == -1)
      return;

   int x = (int)(wmScreenWidth / 2);
   int y = (int)(wmScreenHeight / 2 + wmOffset);

   ObjectSetInteger(0, wmName, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, wmName, OBJPROP_YDISTANCE, y);
  }
//+------------------------------------------------------------------+
