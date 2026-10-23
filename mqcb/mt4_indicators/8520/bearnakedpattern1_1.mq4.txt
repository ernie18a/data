//+------------------------------------------------------------------+
//|                                                 BearNaked1.1.mq4 |
//|                                              Daniel Vieira Costa |
//|                                         seilatrader.blogspot.com |
//+------------------------------------------------------------------+
#property copyright "Daniel Vieira Costa"
#property link      "seilatrader.blogspot.com"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 DarkTurquoise
#property indicator_color2 Red

//--
extern int    CCI_Periodo   = 21;
extern double NivelCCI_MIN  = -80;
extern double NivelCCI_MAX  = 80;
extern int    MM_Periodo    = 14;
extern int    BB_Periodo    = 21;
extern int    BB_Desvio     = 2;
extern double PIP_DesvioMAX = 0.0010;
extern double PIP_Oscilacao = 0.0015;
extern bool   CCISetup2     = false;
extern bool   FuraBollinger = false;
//---
double compra[];
double venda[];
//--
double CCI[];
double MM[];
double BB_UP[],BB_LOW[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   SetIndexStyle(0,DRAW_ARROW,EMPTY);
   SetIndexArrow(0,221);
   SetIndexBuffer(0,compra);
   SetIndexStyle(1,DRAW_ARROW,EMPTY);
   SetIndexArrow(1,222);
   SetIndexBuffer(1,venda);
   ArraySetAsSeries(CCI,true);

//---- indicators
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
// indicadores
   double mm,cci,Range,AvgRange;
   int i,limite,Counter;

   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   limite=Bars-counted_bars;
   if(counted_bars==0) limite-=1+9;

// seto o tamanho das listas
   int xsize=ArraySize(compra);

// seto o tamanho das listas
   ArrayResize(CCI,xsize);
   ArrayResize(MM,xsize);
   ArrayResize(BB_UP,xsize);
   ArrayResize(BB_LOW,xsize);
// load first the CCI values
   for(i=0; i<=limite; i++)
      CCI[i]=iCCI(NULL,0,CCI_Periodo,PRICE_WEIGHTED,i);
// load the Moving Average with the values of the CCI
   for(i=0; i<=limite; i++)
      MM[i]=iMAOnArray(CCI,limite,MM_Periodo,0,MODE_EMA,i);
   for(i=0; i<=limite; i++)
     {
      Counter  =0;
      Range    =0;
      AvgRange =0;

      for(Counter=i; Counter<=i+9; Counter++)
         AvgRange=AvgRange+MathAbs(High[Counter]-Low[Counter]);
      Range=AvgRange/10;

      BB_UP[i] = iBands(NULL, 0, BB_Periodo, BB_Desvio, 0, PRICE_WEIGHTED, MODE_UPPER, i);
      BB_LOW[i]= iBands(NULL, 0, BB_Periodo, BB_Desvio, 0, PRICE_WEIGHTED, MODE_LOWER, i);
      // primeiro verifica se CCI estб acima do nivel mбximo
      if(CCI[i]>NivelCCI_MAX)
        {
         // se o CCI cruzou a MM pra baixo
         if(CCI[i]<MM[i])
            // verifica se o preзo estб dentro da banda superior
            if(High[i]<=BB_UP[i])
              {
               // verifica se a mбxima й menor que a mбxima anterior
               // o motivo й para ratificar a confirmaзгo da tendкncia
               if(High[i]<=High[i+1])
                  // verifica a distвncia entre a o preзo mбximo e a banda de bollinger
                  // sу se posiciona se a distвncia for considerбvel, ou seja, nгo tгo distante
                  if((BB_UP[i]-High[i])<=PIP_DesvioMAX)
                     // sу se posiciona se a oscilaзгo nгo for tгo alta
                     if(High[i]-Low[i]<=PIP_Oscilacao)
                        venda[i]=High[i]+Range*0.5;

              }
         else
         // se considerar o furo da banda de bollinger
         if(FuraBollinger==true)
         // se o preзo furar a banda de bollinger            
         if(High[i]>=BB_UP[i])
                     // se a mбxima for menor que a mбxima anterior
                     if(High[i]<=High[i+1])
                     // se oscilar menos do que o mбximo permitido
                     if(High[i]-Low[i]<=PIP_Oscilacao)
                     venda[i]=High[i]+Range*0.5;
        }
      else
      // verifica se o nivel de CCI estб abaixo da mнnima
      if(CCI[i]<NivelCCI_MIN)
        {
         // verifica se o CCI cruzou a MM pra cima
         if(CCI[i]>MM[i])
            // verifica se o preзo mнnimo estб dentro da banda
            if(Low[i]>=BB_LOW[i])
              {
               // verifica se a mнnima й maior que a mнnima anterior
               // o motivo й para confirmar a tendкncia de alta
               if(Low[i]>=Low[i+1])
                  // verifica a distвncia entre a mнnima e a banda de bollinger
                  // se posiciona se a distвncia for considerбvel
                  if(Low[i]-BB_LOW[i]<=PIP_DesvioMAX)
                     // verifica se o preзo nгo oscilou mais do que PIP_Oscilacao
                     if(High[i]-Low[i]<=PIP_Oscilacao)
                        compra[i]=Low[i]-Range*0.5;
              }
         else
         // se considera valor que ultrapassou a banda de bollinger
         if(FuraBollinger==true)
         // se furou
         if(Low[i]<=BB_LOW[i])
                    // se a mнnima for maior que a mнnima anterior
                    if(Low[i]>=Low[i+1])
                    // verifica se o preзo nгo oscilou mais do que o Pip mбximo permitido
                    if(High[i]-Low[i]<=PIP_Oscilacao)
                    compra[i]=Low[i]-Range*0.5;
        }
      else
      // se quiser considerar o setup2. O setup2 consiste em uma situaзгo na qual o CCI cruzou a 
      // Mйdia Movel porйm, a MM se encontra acima ou abaixo do nнvel limite(MAX/MIN)
      if(CCISetup2==true)
      if((CCI[i]<NivelCCI_MAX) && (MM[i]>NivelCCI_MAX))
         venda[i]=High[i]+Range*0.5;
      else
      if((CCI[i]>NivelCCI_MIN) && (MM[i]<NivelCCI_MIN))
         compra[i]=Low[i]-Range*0.5;
     }
   return(0);
  }
//+------------------------------------------------------------------+
