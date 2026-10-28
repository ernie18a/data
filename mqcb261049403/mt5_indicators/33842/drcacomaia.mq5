//+------------------------------------------------------------------+
//|       MA_DR.mq5 Duplo rompimento de  candle em relação as médias |
//|                                 Copyright © 2021, Ronei Toporcov |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2021, Ronei Toporcov"
#property version   "1.0"
#property description "MA_DR = Double breaking of averages with a candle"
#property description "As described by Caco Maia"
#property description "buffer 0 - value > 0 - buy"
#property description "buffer 1 - value > 0 - sell"

#include <MovingAverages.mqh>
//--- indicator settings
#property indicator_chart_window
#property indicator_buffers 8
#property indicator_plots   2

//Media de Alta
#property indicator_label1  "Compra"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  4

// Media de baixa
#property indicator_label2  "Venda"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrBrown
#property indicator_style2  STYLE_SOLID
#property indicator_width2  4



//--- input parameters
input int                  InpFastMA=8;                 // Periodo da MA rápida
input int                  InpSlowMA=20;                // Periodo da MA lenta
input ENUM_APPLIED_PRICE   InpAppliedPrice=PRICE_CLOSE; // Applied price
//--- indicator buffers
double                     ExtBufferCompra[];
double                     ExtBufferVenda[];
double                     ExtFastMaBuffer[];
double                     ExtSlowMaBuffer[];
double                     ExtTrixSinal[];
double                     ExtTrixMedia[];
double                     ExtEstSinal[];
double                     ExtEstMedia[];

//--- MA handles
int                        ExtFastMaHandle;
int                        ExtSlowMaHandle;
int                        ExtTrixHandle;
int                        ExtMaTrixHandle;
int                        ExtEstHandle;

double                     point;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,ExtBufferCompra,INDICATOR_DATA);
   SetIndexBuffer(1,ExtBufferVenda,INDICATOR_DATA);
   SetIndexBuffer(2,ExtFastMaBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,ExtSlowMaBuffer,INDICATOR_CALCULATIONS);

   SetIndexBuffer(4,ExtTrixSinal,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,ExtTrixMedia,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,ExtEstSinal,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,ExtEstMedia,INDICATOR_CALCULATIONS);


//--- sets first bar from what index will be drawn
//--- An empty value
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);

   PlotIndexSetInteger(0,PLOT_ARROW,233);
   PlotIndexSetInteger(0,PLOT_SHOW_DATA,false);

   PlotIndexSetInteger(1,PLOT_ARROW,234);
   PlotIndexSetInteger(1,PLOT_SHOW_DATA,false);

//--- name for indicator subwindow label
   IndicatorSetString(INDICATOR_SHORTNAME,"MA_DR");
//--- get MA handles
   ExtFastMaHandle=iMA(NULL,0,InpFastMA,0,MODE_SMA,InpAppliedPrice);
   ExtSlowMaHandle=iMA(NULL,0,InpSlowMA,0,MODE_SMA,InpAppliedPrice);

   ExtEstHandle = iStochastic(NULL,0,14,3,3,MODE_SMA,STO_LOWHIGH);

   ExtTrixHandle = iTriX(NULL,0,7,InpAppliedPrice);
   ExtMaTrixHandle = iMA(NULL,0,4,0,MODE_SMA,ExtTrixHandle);

   point=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);


//--- initialization done
  }
//+------------------------------------------------------------------+
//| Moving Averages Convergence/Divergence                           |
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
//--- check for data
   if(rates_total<InpSlowMA)
      return(0);
//--- not all data may be calculated
   int calculated=BarsCalculated(ExtFastMaHandle);
   if(calculated<rates_total)
     {
      Print("ExtFastMaHandle data is not all calculated (",calculated," bar ). Erro",GetLastError());
      return(0);
     }
   calculated=BarsCalculated(ExtSlowMaHandle);
   if(calculated<rates_total)
     {
      Print("ExtSlowMaHandle data is not all calculated (",calculated," bar ). Erro",GetLastError());
      return(0);
     }
//--- we can copy not all data
   int to_copy;
   if(prev_calculated>rates_total || prev_calculated<0)
      to_copy=rates_total;
   else
     {
      to_copy=rates_total-prev_calculated;
      if(prev_calculated>0)
         to_copy++;
     }
//--- get Fast MA buffer
   if(IsStopped())
      return(0); //Checking for stop flag
   if(CopyBuffer(ExtFastMaHandle,0,0,to_copy,ExtFastMaBuffer)<=0)
     {
      Print("Copy fast MA fail! Erro",GetLastError());
      return(0);
     }
//--- get SlowSMA buffer
   if(IsStopped())
      return(0); //Checking for stop flag
   if(CopyBuffer(ExtSlowMaHandle,0,0,to_copy,ExtSlowMaBuffer)<=0)
     {
      Print("Copy slow MA fail! Erro",GetLastError());
      return(0);
     }

   if(IsStopped())
      return(0); //Checking for stop flag
   if(CopyBuffer(ExtEstHandle,0,0,to_copy,ExtEstSinal)<=0)
     {
      Print("Copy main Estocastic fail! Erro",GetLastError());
      return(0);
     }

   if(IsStopped())
      return(0); //Checking for stop flag
   if(CopyBuffer(ExtEstHandle,1,0,to_copy,ExtEstMedia)<=0)
     {
      Print("Copy signal Estocastic fail! Erro",GetLastError());
      return(0);
     }

   if(IsStopped())
      return(0); //Checking for stop flag
   if(CopyBuffer(ExtTrixHandle,0,0,to_copy,ExtTrixSinal)<=0)
     {
      Print("Copy signnal Trix fail! Erro",GetLastError());
      return(0);
     }

   if(IsStopped())
      return(0); //Checking for stop flag
   if(CopyBuffer(ExtMaTrixHandle,0,0,to_copy,ExtTrixMedia)<=0)
     {
      Print("Copy average Trix fail! Erro",GetLastError());
      return(0);
     }


//---
   int limit;
   if(prev_calculated==0)
      limit=0;
   else
      limit=prev_calculated-1;
//--- draw or move line
   for(int i=(int)MathMax(prev_calculated-1,1); i<rates_total; i++)
     {

      if(open[i] < close[i])
        {
         if((low[i] <= ExtSlowMaBuffer[i]) && (low[i] <= ExtFastMaBuffer[i]))
           {
            if((close[i] >= ExtSlowMaBuffer[i]) &&
               (close[i] >= ExtFastMaBuffer[i]) &&
               //filtros
               (ExtEstSinal[i] > ExtEstMedia[i]) &&
               (ExtTrixSinal[i] > ExtTrixMedia[i])
              )
               ExtBufferCompra[i]= high[i] + point;

            else
               ExtBufferCompra[i]= 0.0;
           }
         else
            ExtBufferCompra[i]= 0.0;

         ExtBufferVenda[i]= 0.0;

        }
      else
        {
         if(open[i] > close[i])
           {
            if((high[i] >= ExtSlowMaBuffer[i]) && (high[i] >= ExtFastMaBuffer[i]))
              {
               if((close[i] <= ExtSlowMaBuffer[i]) &&
                  (close[i] <= ExtFastMaBuffer[i]) &&
                  //filtros
                  (ExtEstSinal[i] < ExtEstMedia[i]) &&
                  (ExtTrixSinal[i] < ExtTrixMedia[i])
                 )
                  ExtBufferVenda[i]= low[i]  - point;
               else
                  ExtBufferVenda[i]= 0.0;
              }
            else
               ExtBufferVenda[i]= 0.0;

            ExtBufferCompra[i]= 0.0;

           }
         else
           {
            ExtBufferCompra[i] = 0.0;
            ExtBufferVenda[i]  = 0.0;
           }
        }

     }
//--- OnCalculate done. Return new prev_calculated.
   return(rates_total);
  }
//+------------------------------------------------------------------+
