//+------------------------------------------------------------------
#property copyright   "mladen"
#property link        "mladenfx@gmail.com"
#property link        "https://forge.mql5.io"
#property description "Dev-stops"
//+------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 9
#property indicator_plots   4
#property indicator_label1  "Dev-stop 1"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrSkyBlue,clrSandyBrown
#property indicator_width1  2
#property indicator_label2  "Dev-stop 2"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrDarkGray,clrSkyBlue,clrSandyBrown
#property indicator_style2  STYLE_DOT
#property indicator_label3  "Dev-stop 3"
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  clrDarkGray,clrSkyBlue,clrSandyBrown
#property indicator_style3  STYLE_DOT
#property indicator_label4  "Dev-stop 4"
#property indicator_type4   DRAW_COLOR_LINE
#property indicator_color4  clrDarkGray,clrSkyBlue,clrSandyBrown
#property indicator_width4  2
//--- input parameters
input int                inpDesPeriod  = 20;          // Dev-stop period
input int                inpHilPeriod  = 2;           // Dev-stop high/low period
input double             inpStdDev2    = 2.2;         // Deviation 2
input double             inpStdDev3    = 3.6;         // Deviation 3

//--- buffers and global variables declarations
double val1[],val1c[],val2[],val2c[],val3[],val3c[],val4[],val4c[],range[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,val1,INDICATOR_DATA);
   SetIndexBuffer(1,val1c,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,val2,INDICATOR_DATA);
   SetIndexBuffer(3,val2c,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(4,val3,INDICATOR_DATA);
   SetIndexBuffer(5,val3c,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(6,val4,INDICATOR_DATA);
   SetIndexBuffer(7,val4c,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(8,range,INDICATOR_CALCULATIONS);
//---
   IndicatorSetString(INDICATOR_SHORTNAME,"Kase dev-stop ("+(string)inpDesPeriod+","+(string)inpHilPeriod+")");
   return (INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator de-initialization function                      |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
double values[][4];
//+------------------------------------------------------------------+
//|                                                                  |
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
   if(Bars(_Symbol,_Period)<rates_total) return(prev_calculated);
   if(ArrayRange(values,0)!=rates_total) ArrayResize(values,rates_total);

   int i=(int)MathMax(prev_calculated-1,1); for(; i<rates_total && !_StopFlag; i++)
     {
      int _start=MathMax(0,i-inpHilPeriod);
      range[i]=high[ArrayMaximum(high,_start,inpHilPeriod)]-low[ArrayMinimum(low,_start,inpHilPeriod)];
      double avg=range[i];
      int n=1; for(; n<inpDesPeriod && (i-n)>=0; n++) avg+=range[i-n]; avg/=n;
      double dev=MathPow(range[i]-avg,2);
      for(n=1; n<inpDesPeriod && (i-n)>=0; n++) dev+=(range[i-n]-avg)*(range[i-n]-avg); dev=MathSqrt(dev/n);

      values[i][0] = high[i]-avg-dev*inpStdDev3;
      values[i][1] = high[i]-avg-dev*inpStdDev2;
      values[i][2] = high[i]-avg-dev;
      values[i][3] = high[i]-avg;

      val1[i] = values[i][0];
      val2[i] = values[i][1];
      val3[i] = values[i][2];
      val4[i] = values[i][3];
      for(n=1; n<inpDesPeriod && (i-n)>=0; n++)
        {
         val1[i] = MathMax(val1[i],values[i-n][0]);
         val2[i] = MathMax(val2[i],values[i-n][1]);
         val3[i] = MathMax(val3[i],values[i-n][2]);
         val4[i] = MathMax(val4[i],values[i-n][3]);
        }
      val1c[i] = (i>0) ? (val1[i]>val1[i-1]) ? 1 : (val1[i]<val1[i-1]) ? 2 : val1c[i-1] : 0;
      val2c[i] = (i>0) ? (val2[i]>val2[i-1]) ? 1 : (val2[i]<val2[i-1]) ? 2 : val2c[i-1] : 0;
      val3c[i] = (i>0) ? (val3[i]>val3[i-1]) ? 1 : (val3[i]<val3[i-1]) ? 2 : val3c[i-1] : 0;
      val4c[i] = (i>0) ? (val4[i]>val4[i-1]) ? 1 : (val4[i]<val4[i-1]) ? 2 : val4c[i-1] : 0;
     }
   return (i);
  }
//+------------------------------------------------------------------+
