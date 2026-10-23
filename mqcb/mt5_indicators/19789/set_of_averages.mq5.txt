//+------------------------------------------------------------------+
//|                                              Set_Of_Averages.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright     "Copyright 2018, MetaQuotes Software Corp."
#property link          "https://mql5.com"
#property version       "1.00"
#property description   "Draws the sets of Moving Averages"
#property indicator_chart_window
#property indicator_buffers 8
#property indicator_plots   8
//--- plot MA1
#property indicator_label1  "MA1"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot MA2
#property indicator_label2  "MA2"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot MA3
#property indicator_label3  "MA3"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrGreen
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot MA4
#property indicator_label4  "MA4"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrNavy
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- plot MA5
#property indicator_label5  "MA5"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrCyan
#property indicator_style5  STYLE_SOLID
#property indicator_width5  1
//--- plot MA6
#property indicator_label6  "MA6"
#property indicator_type6   DRAW_LINE
#property indicator_color6  clrMagenta
#property indicator_style6  STYLE_SOLID
#property indicator_width6  1
//--- plot MA7
#property indicator_label7  "MA7"
#property indicator_type7   DRAW_LINE
#property indicator_color7  clrGold
#property indicator_style7  STYLE_SOLID
#property indicator_width7  1
//--- plot MA8
#property indicator_label8  "MA8"
#property indicator_type8   DRAW_LINE
#property indicator_color8  clrTomato
#property indicator_style8  STYLE_SOLID
#property indicator_width8  1
//--- input parameters
input ENUM_MA_METHOD       InpMethod   =  MODE_SMA;                  // Calculated method MA
input ENUM_APPLIED_PRICE   InpPrice    =  PRICE_CLOSE;               // Calculated price MA
input string               InpPeriods  =  "10,20,30,40,50,60,70,80"; // Periods of all MA
//--- global variables
int         MAPeriods[];
int         total;
//--- indicator buffers and datas
struct SDataMA
  {
   double            buffer[];   // MA buffer
   int               period;     // MA period
   int               handle;     // MA handle
  } data_ma[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set indicators short name
   IndicatorSetString(INDICATOR_SHORTNAME,"Set of averages");
//--- set parameters of MA Periods
   total=StringValueToArray(InpPeriods,",",MAPeriods);
   if(total<1)
     {
      Print("An error occurred while retrieving the MA periods data. Check settings \"Periods of all MA\"");
      return INIT_FAILED;
     }
//--- indicator buffers mapping
   ArrayResize(data_ma,total);
   for(int i=0; i<total; i++)
     {
      data_ma[i].period=MAPeriods[i];
      data_ma[i].handle=iMA(Symbol(),PERIOD_CURRENT,MAPeriods[i],0,InpMethod,InpPrice);
      if(data_ma[i].handle==INVALID_HANDLE)
        {
         Print("Error creating MA",i," handle");
         return INIT_FAILED;
        }
      SetIndexBuffer(i,data_ma[i].buffer,INDICATOR_DATA);
     }
//---
   return INIT_SUCCEEDED;
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
//--- Checking for minimum number of bars
   if(rates_total<data_ma[total-1].period) return 0;
//--- Check for limits
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      for(int i=0; i<total; i++)
         ArrayInitialize(data_ma[i].buffer,EMPTY_VALUE);
     }
//--- calculating Moving Averages
   for(int i=0; i<total; i++)
     {
      if(BarsCalculated(data_ma[i].handle)<0) continue;
      if(CopyBuffer(data_ma[i].handle,0,0,(limit==0 ? 1 : limit),data_ma[i].buffer)<0) continue;
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Fills an array from a string                                     |
//+------------------------------------------------------------------+
int StringValueToArray(const string string_value,const string separator,int &array_dest[])
  {
   string tmp[];
   int num=StringSplit(string_value,StringGetCharacter(separator,0),tmp);
   if(num>0)
     {
      ArrayResize(array_dest,num);
      for(int i=0; i<num; i++)
        {
         int value=(int)StringToInteger(tmp[i]);
         array_dest[i]=(value==0 ? 1 : value);
        }
     }
   return num;
  }
//+------------------------------------------------------------------+
