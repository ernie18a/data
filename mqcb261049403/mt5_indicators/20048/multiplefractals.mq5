//+------------------------------------------------------------------+
//|                                             MultipleFractals.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 20
#property indicator_plots   20
//--- plot UP1
#property indicator_label1  "FractalUP1"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot DN1
#property indicator_label2  "FractalDN1"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot UP2
#property indicator_label3  "FractalUP2"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrRed
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot DN2
#property indicator_label4  "FractalDN2"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrBlue
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- plot UP3
#property indicator_label5  "FractalUP3"
#property indicator_type5   DRAW_ARROW
#property indicator_color5  clrRed
#property indicator_style5  STYLE_SOLID
#property indicator_width5  1
//--- plot DN3
#property indicator_label6  "FractalDN3"
#property indicator_type6   DRAW_ARROW
#property indicator_color6  clrBlue
#property indicator_style6  STYLE_SOLID
#property indicator_width6  1
//--- plot UP4
#property indicator_label7  "FractalUP4"
#property indicator_type7   DRAW_ARROW
#property indicator_color7  clrRed
#property indicator_style7  STYLE_SOLID
#property indicator_width7  1
//--- plot DN4
#property indicator_label8  "FractalDN4"
#property indicator_type8   DRAW_ARROW
#property indicator_color8  clrBlue
#property indicator_style8  STYLE_SOLID
#property indicator_width8  1
//--- plot UP5
#property indicator_label9  "FractalUP5"
#property indicator_type9   DRAW_ARROW
#property indicator_color9  clrRed
#property indicator_style9  STYLE_SOLID
#property indicator_width9  1
//--- plot DN5
#property indicator_label10  "FractalDN5"
#property indicator_type10   DRAW_ARROW
#property indicator_color10  clrBlue
#property indicator_style10  STYLE_SOLID
#property indicator_width10  1
//--- plot UP6
#property indicator_label11  "FractalUP6"
#property indicator_type11   DRAW_ARROW
#property indicator_color11  clrRed
#property indicator_style11  STYLE_SOLID
#property indicator_width11  1
//--- plot DN6
#property indicator_label12  "FractalDN6"
#property indicator_type12   DRAW_ARROW
#property indicator_color12  clrBlue
#property indicator_style12  STYLE_SOLID
#property indicator_width12  1
//--- plot UP7
#property indicator_label13  "FractalUP7"
#property indicator_type13   DRAW_ARROW
#property indicator_color13  clrRed
#property indicator_style13  STYLE_SOLID
#property indicator_width13  1
//--- plot DN7
#property indicator_label14  "FractalDN7"
#property indicator_type14   DRAW_ARROW
#property indicator_color14  clrBlue
#property indicator_style14  STYLE_SOLID
#property indicator_width14  1
//--- plot UP8
#property indicator_label15  "FractalUP8"
#property indicator_type15   DRAW_ARROW
#property indicator_color15  clrRed
#property indicator_style15  STYLE_SOLID
#property indicator_width15  1
//--- plot DN8
#property indicator_label16  "FractalDN8"
#property indicator_type16   DRAW_ARROW
#property indicator_color16  clrBlue
#property indicator_style16  STYLE_SOLID
#property indicator_width16  1
//--- plot UP9
#property indicator_label17  "FractalUP9"
#property indicator_type17   DRAW_ARROW
#property indicator_color17  clrRed
#property indicator_style17  STYLE_SOLID
#property indicator_width17  1
//--- plot DN9
#property indicator_label18  "FractalDN9"
#property indicator_type18   DRAW_ARROW
#property indicator_color18  clrBlue
#property indicator_style18  STYLE_SOLID
#property indicator_width18  1
//--- plot UP10
#property indicator_label19  "FractalUP10"
#property indicator_type19   DRAW_ARROW
#property indicator_color19  clrRed
#property indicator_style19  STYLE_SOLID
#property indicator_width19  1
//--- plot DN10
#property indicator_label20  "FractalDN10"
#property indicator_type20   DRAW_ARROW
#property indicator_color20  clrBlue
#property indicator_style20  STYLE_SOLID
#property indicator_width20  1
//--- enums
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1, // Yes
   INPUT_NO    =  0  // No
  };
//--- input parameters
input uint              InpMinFrame    =  2;          // Min dimension of a fractal
input uint              InpMaxFrame    =  10;         // Max dimension of a fractal
input ENUM_INPUT_YES_NO InpUseLastBar  =  INPUT_NO;   // Use last bar
input color             InpColorUP     =  clrRed;     // Upper fractals color 
input color             InpColorDN     =  clrBlue;    // Lower fractals color
//--- indicator buffers
struct SDataBuffer
  {
   double            BufferUP[];
   double            BufferDN[];
  }
Data[10];
//--- global variables
int            min_frame;
int            max_frame;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- setting global variables
   min_frame=int(InpMinFrame<1 ? 1 : InpMinFrame>9 ? 9 : InpMinFrame);
   max_frame=int(InpMaxFrame>10 ? 10 : (int)InpMaxFrame<=min_frame ? min_frame+1 : InpMaxFrame);
//--- setting buffers
   for(int i=0; i<10; i++)
     {
      int buff1=i*2,buff2=buff1+1,code=140+i;
      //--- indicator buffers mapping
      SetIndexBuffer(buff1,Data[i].BufferUP,INDICATOR_DATA);
      SetIndexBuffer(buff2,Data[i].BufferDN,INDICATOR_DATA);
      //--- setting a code from the Wingdings charset as the property of PLOT_ARROW
      PlotIndexSetInteger(buff1,PLOT_ARROW,code);
      PlotIndexSetInteger(buff2,PLOT_ARROW,code);
      //--- Set plot buffers colors
      PlotIndexSetInteger(buff1,PLOT_LINE_COLOR,InpColorUP);
      PlotIndexSetInteger(buff2,PLOT_LINE_COLOR,InpColorDN);
      PlotIndexSetString(buff1,PLOT_LABEL,string(i+1)+"-dimension up fractal");
      PlotIndexSetString(buff2,PLOT_LABEL,string(i+1)+"-dimension down fractal");
      //--- setting buffer arrays as timeseries
      ArraySetAsSeries(Data[i].BufferUP,true);
      ArraySetAsSeries(Data[i].BufferDN,true);
     }
//--- settings indicators parameters
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetString(INDICATOR_SHORTNAME,"Multiple fractals");
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
//--- Проверка на минимальное количество баров для расчёта
   if(rates_total<max_frame) return 0;
//--- Установка индексации массивов как таймсерий
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(time,true);
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-max_frame-1;
      for(int i=0; i<10; i++)
        {
         ArrayInitialize(Data[i].BufferUP,EMPTY_VALUE);
         ArrayInitialize(Data[i].BufferDN,EMPTY_VALUE);
        }
     }
//--- Расчёт индикатора
   int end=(InpUseLastBar ? 0 : 1);
   int begin=fmax(limit,max_frame);
   for(int i=begin; i>=end && !IsStopped(); i--)
     {
      for(int j=0; j<10; j++)
        {
         Data[j].BufferUP[i]=EMPTY_VALUE;
         Data[j].BufferDN[i]=EMPTY_VALUE;
        }
      int count=fmin(i-end,max_frame);
      if(count>=min_frame)
        {
         int UpFractalStatus=FindUP(i,count,high);
         if(UpFractalStatus>=min_frame)
            Data[UpFractalStatus-1].BufferUP[i]=high[i];
         int DnFractalStatus=FindDN(i,count,low);
         if(DnFractalStatus>=min_frame)
            Data[DnFractalStatus-1].BufferDN[i]=low[i];
        }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int FindUP(const int index,const int count,const double &high[])
  {
   for(int i=1; i<=count; i++)
     {
      if(high[index+i]>high[index] || high[index-i]>high[index])
         return (i-1);
     }
   return WRONG_VALUE;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int FindDN(const int index,const int count,const double &low[])
  {
   for(int i=1; i<=count; i++)
     {
      if(low[index+i]<low[index] || low[index-i]<low[index])
         return (i-1);
     }
   return WRONG_VALUE;
  }
//+------------------------------------------------------------------+
