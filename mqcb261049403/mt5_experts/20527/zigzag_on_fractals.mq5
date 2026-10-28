//+------------------------------------------------------------------+
//|                                           ZigZag on Fractals.mq5 |
//|                              Copyright © 2018, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2018, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "2.000"
#property description "\"ZigZag\" on the indicator \"Fractals\""
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   1
//---- plot Zigzag  on Fractals
#property indicator_label1  "Zigzag on Fractals"
#property indicator_type1   DRAW_SECTION
#property indicator_color1  clrMediumVioletRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- indicator buffers
double         ZigzagBuffer[];      // main buffer
double         FractalUpBuffer[];   // fractals up
double         FractalDownBuffer[]; // fractals down
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,ZigzagBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,FractalUpBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,FractalDownBuffer,INDICATOR_CALCULATIONS);
//--- show the symbol/timeframe the Fractals indicator is calculated for 
   string short_name=StringFormat("ZigZag on Fractals(%s/%s)",Symbol(),EnumToString(Period()));
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//---- sets drawing line empty value--
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- set accuracy
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
   int i,limit;
//---
   if(rates_total<5)
      return(0);
//---
   if(prev_calculated<7)
     {
      limit=2;
      //--- clean up arrays
      ArrayInitialize(ZigzagBuffer,EMPTY_VALUE);
      ArrayInitialize(FractalUpBuffer,EMPTY_VALUE);
      ArrayInitialize(FractalDownBuffer,EMPTY_VALUE);
     }
   else
      limit=rates_total-5;

   for(i=limit;i<rates_total-3 && !IsStopped();i++)
     {
      //--- Upper Fractal
      if(high[i]>high[i+1] && high[i]>high[i+2] && high[i]>=high[i-1] && high[i]>=high[i-2])
        {
         FractalUpBuffer[i]=high[i];
         int      fractal_buffer=INT_MAX;
         double   price=0.0;
         int      index_last_zigzag=SearchLastZigzag(i,fractal_buffer,price);
         if(index_last_zigzag==-1 && (fractal_buffer!=0 || fractal_buffer!=INT_MAX))
            ZigzagBuffer[i]=FractalUpBuffer[i];
         if(index_last_zigzag!=-1)
           {
            if(fractal_buffer==1 && price<FractalUpBuffer[i])
              {
               //---  move ZigZag above
               ZigzagBuffer[index_last_zigzag]=EMPTY_VALUE;
               ZigzagBuffer[i]=FractalUpBuffer[i];
              }
            if(fractal_buffer==-1)
               ZigzagBuffer[i]=FractalUpBuffer[i];
           }
        }
      else
         FractalUpBuffer[i]=EMPTY_VALUE;
      //--- Lower Fractal
      if(low[i]<low[i+1] && low[i]<low[i+2] && low[i]<=low[i-1] && low[i]<=low[i-2])
        {
         FractalDownBuffer[i]=low[i];
         int      fractal_buffer=INT_MAX;
         double   price=0.0;
         int      index_last_zigzag=SearchLastZigzag(i,fractal_buffer,price);
         if(index_last_zigzag==-1 && (fractal_buffer!=0 || fractal_buffer!=INT_MAX))
            ZigzagBuffer[i]=FractalDownBuffer[i];
         if(index_last_zigzag!=-1)
           {
            if(fractal_buffer==-1 && price>FractalDownBuffer[i])
              {
               //---  move ZigZag below
               ZigzagBuffer[index_last_zigzag]=EMPTY_VALUE;
               ZigzagBuffer[i]=FractalDownBuffer[i];
              }
            if(fractal_buffer==1)
               ZigzagBuffer[i]=FractalDownBuffer[i];
           }
        }
      else
         FractalDownBuffer[i]=EMPTY_VALUE;
      //---
      if((FractalUpBuffer[i]==EMPTY_VALUE || FractalUpBuffer[i]==0.0) && (FractalDownBuffer[i]==EMPTY_VALUE || FractalDownBuffer[i]==0.0))
        {
         ZigzagBuffer[i]=EMPTY_VALUE;
        }
     }
//---
   ZigzagBuffer[rates_total-3]=EMPTY_VALUE;
   ZigzagBuffer[rates_total-2]=EMPTY_VALUE;
   ZigzagBuffer[rates_total-1]=EMPTY_VALUE;
//--- OnCalculate done. Return new prev_calculated.
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Search of the last Zigzag                                        |
//|   "-1" ->  zigzag isn't found or error                           |
//|   fractal_buffer:  UP ->  "1", DOWN -> "-1", UP and DOWN -> "0"  |
//+------------------------------------------------------------------+
int SearchLastZigzag(const int start,int &fractal_buffer,double &price)
  {
//--- search from "start" value to zero (from the right part of the shart to the left part)
   if(start<=0)
     {
      Print("Parameter \"start\" can't be less or is equal to zero");
      return(-1);
     }
   for(int i=start;i>=0;i--)
     {
      if(ZigzagBuffer[i]!=EMPTY_VALUE && ZigzagBuffer[i]!=0.0)
        {
         if(FractalUpBuffer[i]!=EMPTY_VALUE && FractalUpBuffer[i]!=0.0)
           {
            fractal_buffer=1;
            price=FractalUpBuffer[i];
           }
         if(FractalDownBuffer[i]!=EMPTY_VALUE && FractalDownBuffer[i]!=0.0)
           {
            fractal_buffer=-1;
            price=FractalDownBuffer[i];
           }
         if((FractalUpBuffer[i]!=EMPTY_VALUE && FractalUpBuffer[i]!=0.0) && (FractalDownBuffer[i]!=EMPTY_VALUE && FractalDownBuffer[i]!=0.0))
           {
            fractal_buffer=0;
            return(-1);
           }
         return(i);
        }
     }
//---
   return(-1);
  }
//+------------------------------------------------------------------+ 
//| Indicator deinitialization function                              | 
//+------------------------------------------------------------------+ 
void OnDeinit(const int reason)
  {
//--- clear the chart after deleting the indicator 
   Comment("");
  }
//+------------------------------------------------------------------+
