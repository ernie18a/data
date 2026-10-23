//------------------------------------------------------------------
#property copyright "© mladen, 2019"
#property link      "mladenfx@gmail.com"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots   3
#property indicator_label1  "Zone"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  C'230,230,230'
#property indicator_label2  "Middle"
#property indicator_type2   DRAW_LINE
#property indicator_style2  STYLE_DOT
#property indicator_color2  clrGray
#property indicator_label3  "Double smoothed EMA"
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  clrDarkGray,clrLimeGreen,clrDeepPink
#property indicator_width3  2
//
//---
//

input double             inpPeriod     = 14;           // Period
input ENUM_APPLIED_PRICE inpPrice      = PRICE_MEDIAN; // Price
enum chgColor
{
   chg_onSlope,  // change color on slope change
   chg_onLevel,  // Change color on outer levels cross
   chg_onMiddle, // Change color on middle level cross
};
input int                inpFlPeriod         = 25;             // Period for finding floating levels
input double             inpFlUp             = 90;             // Upper level %
input double             inpFlDown           = 10;             // Lower level %
input chgColor           inpColorOn          = chg_onLevel;    // Color change on :

//
//---
//

double val[],valc[],work[],mid[],fup[],fdn[],_alpha;

//------------------------------------------------------------------ 
// Custom indicator initialization function                          
//------------------------------------------------------------------
//
//
//

int OnInit()
{
   //
   //--- indicator buffers mapping
   //
         SetIndexBuffer(0,fup  ,INDICATOR_DATA);
         SetIndexBuffer(1,fdn  ,INDICATOR_DATA);
         SetIndexBuffer(2,mid  ,INDICATOR_DATA);
         SetIndexBuffer(3,val  ,INDICATOR_DATA);
         SetIndexBuffer(4,valc ,INDICATOR_COLOR_INDEX);
         SetIndexBuffer(5,work ,INDICATOR_CALCULATIONS);
            _alpha = 2.0/(1.0+MathSqrt(MathMax(inpPeriod,1)));
   //         
   //--- indicator short name assignment
   //
   IndicatorSetString(INDICATOR_SHORTNAME,"Double smoothed EMA ("+(string)inpPeriod+")");
   return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason)
{
}

//------------------------------------------------------------------
// Custom indicator iteration function                              
//------------------------------------------------------------------
//
//
//

int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   static int    prev_i=-1;
   static double prev_max,prev_min;

   //
   //---
   //
   
   int i= prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      double price=getPrice(inpPrice,open,close,high,low,i);
      work[i] = (i>0) ? work[i-1] + _alpha*(price-work[i-1]) : price;
      val[i]  = (i>0) ? val[i-1] + _alpha*(work[i]-val[i-1]) : work[i];
      
      //
      //---
      //
            if (prev_i!=i)
            {
               prev_i = i; 
               int start    = i-inpFlPeriod+1; if (start<0) start=0;
                   prev_max = val[ArrayMaximum(val,start,inpFlPeriod-1)];
                   prev_min = val[ArrayMinimum(val,start,inpFlPeriod-1)];
            }
            double max   = (val[i] > prev_max) ? val[i] : prev_max;
            double min   = (val[i] < prev_min) ? val[i] : prev_min;
            double range = (max-min)/100.0;

                  fup[i] = min+inpFlUp  *range;
                  fdn[i] = min+inpFlDown*range;
                  mid[i] = min+     50.0*range;

            //
            //---
            //
                              
            switch (inpColorOn)
            {
               case chg_onLevel  : valc[i] = (val[i]>fup[i]) ? 1 : (val[i]<fdn[i])  ? 2 : (i>0) ? (val[i]==val[i-1]) ? valc[i-1] : 0 : 0; break;
               case chg_onMiddle : valc[i] = (val[i]>mid[i]) ? 1 : (val[i]<mid[i])  ? 2 : (i>0) ? (val[i]==val[i-1]) ? valc[i-1] : 0 : 0; break;
               default :           valc[i] = (i>0) ? (val[i]>val[i-1]) ? 1 : (val[i]<val[i-1]) ? 2 : valc[i-1] : 0;
            }                  
   }
   return(i);
}

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
//
//---
//

double getPrice(ENUM_APPLIED_PRICE tprice,const double &open[],const double &close[],const double &high[],const double &low[],int i)
{
      switch(tprice)
        {
         case PRICE_CLOSE:     return(close[i]);
         case PRICE_OPEN:      return(open[i]);
         case PRICE_HIGH:      return(high[i]);
         case PRICE_LOW:       return(low[i]);
         case PRICE_MEDIAN:    return((high[i]+low[i])/2.0);
         case PRICE_TYPICAL:   return((high[i]+low[i]+close[i])/3.0);
         case PRICE_WEIGHTED:  return((high[i]+low[i]+close[i]+close[i])/4.0);
        }
   return(0);
}
//------------------------------------------------------------------

