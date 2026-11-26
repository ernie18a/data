//+------------------------------------------------------------------+
//|                                         VWAP_Custom_Position.mq5 |
//|                                           José Ricardo Magalhães |
//|                                            joserrrm@yahoo.com.br |
//+------------------------------------------------------------------+
#property copyright "José Ricardo Magalhães"
#property link      "joserrrm@yahoo.com.br"
#property version   "1.00"
#property description "The indicator VWAP_Custom_Position calculates standard VWAP line, with user defined start point."
#property description "The start point is defined by the (movable) ARROW created on chart."
#property description " "
#property description "VWAP means Volume Weighted Average Price."

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1
//--- plot vwap
#property indicator_label1  "VWAP Custom"
#property indicator_type1   DRAW_SECTION
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//---
enum PRICE_METHOD 
  {
   Close,
   Open,
   High,
   Low,
   Median,  // Median Price (HL/2)
   Typical, // Typical Price (HLC/3)
   Weighted // Weighted Close (HLCC/4)
  };
//--- input parameters
input string            vwapID    = "01";       // VWAP ID  (must be unique)
input PRICE_METHOD      Method    = Typical;    // Price Calculation Method
input color             vwapColor = Fuchsia;    // VWAP Color
input int               arrowSize = 3;          // Arrow Size
input ENUM_ARROW_ANCHOR Anchor    = ANCHOR_TOP; // Arrow Anchor Point
//--- indicator buffers
double         vwapBuffer[];
//--- global variables
int            startVWAP;
string         Prefix;
int            iRatesTotal;
datetime       iTime[];
double         iOpen[], iHigh[], iLow[], iClose[], iVolume[];
long           obj_time;
bool           first=true;
int            counter=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   // indicator buffers mapping
   SetIndexBuffer(0,vwapBuffer,INDICATOR_DATA);
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,vwapColor);
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
   
   Prefix = "Obj_"+vwapID;
   
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator Deinitialization function                       |
//+------------------------------------------------------------------+     
void OnDeinit(const int reason)
  {
   // Zera a VWAP
   ArrayInitialize(vwapBuffer,0.0);
   // Exclui o Objeto quando o indicador é excluído.
   if(reason != REASON_PARAMETERS && reason != REASON_CHARTCHANGE)
      {
      ObjectsDeleteAll(0,Prefix);
      ChartRedraw(0);
      }
  }
//+------------------------------------------------------------------+
//| Custom indicator Chart Event function                            |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
   if(sparam==Prefix) EventSetMillisecondTimer(100);
   else EventKillTimer();
  }
//+------------------------------------------------------------------+
//| Custom indicator TIMER function                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   // Identifica a posição horizontal do objeto   
   obj_time = ObjectGetInteger(0,Prefix,OBJPROP_TIME);
   for(int i=iRatesTotal-1; i>0; i--) { if(obj_time>=(long)iTime[i]) {startVWAP=i; break;} }
   // Zera a VWAP
   ArrayInitialize(vwapBuffer,0.0);
   // Refaz a VWAP
   CalculateVWAP();
  }   

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
   // Inicializa os Buffers
   if(first)
     {
      ArrayInitialize(vwapBuffer,0.0);
      ArrayResize(iTime,  rates_total,rates_total/2);
      ArrayResize(iOpen,  rates_total,rates_total/2);
      ArrayResize(iHigh,  rates_total,rates_total/2);
      ArrayResize(iLow,   rates_total,rates_total/2);
      ArrayResize(iClose, rates_total,rates_total/2);
      ArrayResize(iVolume,rates_total,rates_total/2);
     }
     
   // Carrega os vetores de preço
   counter = first ? 0 : MathMax(prev_calculated-1,0);
   for(int i=counter; i<rates_total; i++)
      {
      iRatesTotal=rates_total;
      iTime[i]=time[i];
      iOpen[i]=open[i];
      iHigh[i]=high[i];
      iLow[i]=low[i];
      iClose[i]=close[i];
      iVolume[i]=(double)volume[i];
      }
   // Criação do Objeto Referência
   if(ObjectFind(0,Prefix)!=0) CreateObject();
   // Parâmetros customizaveis do Objeto Referência
   if(first) { CustomizeObject(); first = false; }

   // Identifica a posição horizontal do objeto   
   obj_time = ObjectGetInteger(0,Prefix,OBJPROP_TIME);
   for(int i=iRatesTotal-1; i>0; i--) { if(obj_time>=(long)iTime[i]) {startVWAP=i; break;} }
   // Verifica se há dados no buffer da vwap à esquerda do objeto. Caso positivo zera o buffer
   if(vwapBuffer[startVWAP-1]!=0) ArrayInitialize(vwapBuffer,0.0);
   // Calcula a VWAP
   CalculateVWAP();
   
   return(rates_total);
  }
//+------------------------------------------------------------------+
void CalculateVWAP()
  {
   // Calcula a VWAP
   double sumPrice=0,sumVol=0;
   for(int i=startVWAP; i<iRatesTotal; i++)
     {
      sumPrice    += Price(iOpen,iHigh,iLow,iClose,i)*iVolume[i];
      sumVol      += iVolume[i];
      vwapBuffer[i]= sumPrice/sumVol;
     }
  }
//+------------------------------------------------------------------+
double Price(const double &open[],
             const double &high[],
             const double &low[],
             const double &close[],
             int          index )
  {
   double output;
   if(Method==Open)          output=open[index];
   else if(Method==High)     output=high[index];
   else if(Method==Low)      output=low[index];
   else if(Method==Median)   output=(high[index]+low[index])/2;
   else if(Method==Typical)  output=(high[index]+low[index]+close[index])/3;
   else if(Method==Weighted) output=(high[index]+low[index]+close[index]+close[index])/4;
   else                      output=close[index];
   return(output);
  }
//+------------------------------------------------------------------+
void CreateObject()
  {
   int      offset = (int)ChartGetInteger(0,CHART_FIRST_VISIBLE_BAR) - (int)ChartGetInteger(0,CHART_WIDTH_IN_BARS)/2;
   datetime Hposition = iTime[iRatesTotal-offset];
   double   Vposition;
   if(Anchor==ANCHOR_TOP) Vposition = iLow[iRatesTotal-offset];
   else                   Vposition = iHigh[iRatesTotal-offset];
   
   ObjectCreate(0,Prefix,OBJ_ARROW,0,Hposition,Vposition);
   //--- Código Wingdings 
   ObjectSetInteger(0,Prefix,OBJPROP_ARROWCODE,233); 
   //--- definir o estilo da linha da borda 
   ObjectSetInteger(0,Prefix,OBJPROP_STYLE,STYLE_DOT); 
   ObjectSetInteger(0,Prefix,OBJPROP_FILL,false); 
   //--- exibir em primeiro plano (false) ou fundo (true) 
   ObjectSetInteger(0,Prefix,OBJPROP_BACK,false); 
   //--- permitir (true) ou desabilitar (false) o modo de movimento do sinal com o mouse 
   //--- ao criar um objeto gráfico usando a função ObjectCreate, o objeto não pode ser 
   //--- destacado e movimentado por padrão. Dentro deste método, o parâmetro de seleção 
   //--- é verdade por padrão, tornando possível destacar e mover o objeto 
   ObjectSetInteger(0,Prefix,OBJPROP_SELECTABLE,true); 
   ObjectSetInteger(0,Prefix,OBJPROP_SELECTED,true); 
   //--- ocultar (true) ou exibir (false) o nome do objeto gráfico na lista de objeto  
   ObjectSetInteger(0,Prefix,OBJPROP_HIDDEN,false); 
   //--- definir a prioridade para receber o evento com um clique do mouse no gráfico 
   ObjectSetInteger(0,Prefix,OBJPROP_ZORDER,100);
   ObjectSetInteger(0,Prefix,OBJPROP_FILL,true);
  }
//+------------------------------------------------------------------+
void CustomizeObject()
  {
   //--- Tamanho do objeto
   ObjectSetInteger(0,Prefix,OBJPROP_WIDTH,arrowSize); 
   //--- Cor
   ObjectSetInteger(0,Prefix,OBJPROP_COLOR,vwapColor); 
   //--- Código Wingdings
   if(Anchor==ANCHOR_TOP)    ObjectSetInteger(0,Prefix,OBJPROP_ARROWCODE,233); 
   if(Anchor==ANCHOR_BOTTOM) ObjectSetInteger(0,Prefix,OBJPROP_ARROWCODE,234);
   //--- Ponto de Ancoragem
   ObjectSetInteger(0,Prefix,OBJPROP_ANCHOR,Anchor);
  }
