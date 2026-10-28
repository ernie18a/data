//+------------------------------------------------------------------+
//|                                             BB_CCI_CrossOver.mq4 |
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
   SetIndexArrow(0,228);
   SetIndexBuffer(0,compra);
   SetIndexStyle(1,DRAW_ARROW,EMPTY);
   SetIndexArrow(1,230);
   SetIndexBuffer(1,venda);
//---- indicators
   ArraySetAsSeries(CCI,true);
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

   int xsize=ArraySize(compra);

// seto o tamanho das listas
   ArrayResize(CCI,xsize);
   ArrayResize(MM,xsize);
   ArrayResize(BB_UP,xsize);
   ArrayResize(BB_LOW,xsize);
   i=limite;
   while(i>0)
     {
      Counter  =0;
      Range    =0;
      AvgRange =0;

      for(Counter=i; Counter>=i+9; Counter--)
         AvgRange=AvgRange+MathAbs(High[Counter]-Low[Counter]);
      Range=AvgRange/10;

      CCI[i]   = iCCI(NULL, 0, CCI_Periodo, PRICE_WEIGHTED, i);
      MM[i]    = iMAOnArray(CCI, limite, MM_Periodo, 0, MODE_EMA, i);
      BB_UP[i] = iBands(NULL, 0, BB_Periodo, BB_Desvio, 0, PRICE_WEIGHTED, MODE_UPPER, i);
      BB_LOW[i]= iBands(NULL, 0, BB_Periodo, BB_Desvio, 0, PRICE_WEIGHTED, MODE_LOWER, i);
      // primeiro verifica se CCI estб acima do nivel positivo
      if(CCI[i]>NivelCCI_MAX)
        {
         if(CCI[i]<MM[i])
            // verifica se o preзo estб dentro da banda superior
            if(High[i]<=BB_UP[i])
              {
               // verifica se a mбxima й menor que a mбxima anterior
               // o motivo й para ratificar a confirmaзгo da tendкncia
               if(High[i+1]>High[i])
                  // verifica a distвncia entre a o preзo mбximo e a banda de bollinger
                  // sу se posiciona se a distвncia for considerбvel, ou seja, nгo tгo distante
                  if((BB_UP[i]-High[i])<=PIP_DesvioMAX)
                     venda[i]=High[i]+Range*0.10;
              }
         else
         // quando o preзo estб fora da banda superior
         if(High[i]>=BB_UP[i])
           {
            // verifica se a mбxima й menor que a mбxima anterior
            // o motivo й para ratificar a confirmaзгo da tendкncia
            if(High[i+1]>High[i])
               venda[i]=High[i]+Range*0.10;
           }

        }
      else
      // verifica se o nivel de CCI estб abaixo da mнnima
      if(CCI[i]<NivelCCI_MIN)
        {
         if(CCI[i]>MM[i])
            // quando o preзo estб dentro da banda inferior
            if(Low[i]>=BB_LOW[i])
              {
               // verifica se a mнnima й maior que a mнnima anterior
               // o motivo й para ratificar a confirmaзгo da tendкncia
               if(Low[i+1]<Low[i])
                  compra[i]=Low[i]-Range*0.10;
              }
         else
         // quando o preзo ainda se encontra fora da banda inferior
         if(Low[i]<=BB_LOW[i])
           {
            if(Low[i+1]<Low[i])
               compra[i]=Low[i]-Range*0.10;
           }
        }
      i--;
     }
   return(0);
  }
//+------------------------------------------------------------------+
