//+------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "MACD of RSI adaptive EMA - floating levels"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 8
#property indicator_plots   5
#property indicator_label1  "Upper level"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGray
#property indicator_style1  STYLE_DOT
#property indicator_label2  "Middle level"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGray
#property indicator_style2  STYLE_DOT
#property indicator_label3  "Lower level"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrGray
#property indicator_style3  STYLE_DOT
#property indicator_label4  "MACD"
#property indicator_type4   DRAW_COLOR_LINE
#property indicator_color4  clrDarkGray,clrMediumSeaGreen,clrOrangeRed
#property indicator_width4  2
#property indicator_label5  "MACD signal line"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrRed
#property indicator_style5  STYLE_DOT
//
//--- input parameters
//

input int                inpFastPeriod   = 12;           // MACD fast period
input int                inpSlowPeriod   = 26;           // MACD slow period
input int                inpSignalPeriod = 9;            // MACD signal period
input ENUM_APPLIED_PRICE inpPrice        = PRICE_CLOSE;  // Price 
enum enColorChangeOn
{
   cchange_onSlope,  // Change color on slope change
   cchange_onSignal, // Change color on signal cross
   cchange_onLevels, // Change color on outer levels cross
   cchange_onZero    // Change color on middle level cross
};
input int                inpFlPeriod    = 25;               // Floating levels period
input double             inpFlLevelUp   = 90;               // Floating levels up %
input double             inpFlLevelDn   = 10;               // Floating levels down %
input enColorChangeOn    inpColorChange = cchange_onLevels; // Color changing mode

//
//--- buffers declarations
//

double val[],valc[],levu[],levd[],levm[],signal[],emaf[],emas[]; 
double °_alphaSignal = 2.0 / (1.0 + inpSignalPeriod);

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
int OnInit()
{
   //
   //--- indicator buffers mapping
   //
         SetIndexBuffer(0,levu  ,INDICATOR_DATA);
         SetIndexBuffer(1,levm  ,INDICATOR_DATA);
         SetIndexBuffer(2,levd  ,INDICATOR_DATA);
         SetIndexBuffer(3,val   ,INDICATOR_DATA);
         SetIndexBuffer(4,valc  ,INDICATOR_COLOR_INDEX);
         SetIndexBuffer(5,signal,INDICATOR_DATA);
         SetIndexBuffer(6,emaf  ,INDICATOR_CALCULATIONS);
         SetIndexBuffer(7,emas  ,INDICATOR_CALCULATIONS);
            °_alphaSignal = 2.0 / (1.0 + inpSignalPeriod);
   //
   //--- indicator short name assignment
   //
   IndicatorSetString(INDICATOR_SHORTNAME,"MACD of RSI adaptive EMA ("+(string)inpFastPeriod+","+(string)inpSlowPeriod+","+(string)inpSignalPeriod+")");
   return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { }

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
   //
   //
   
   int i=prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
         double _price  = getPrice(inpPrice,open,close,high,low,i);
		   double _alphaf = (iRsi(_price,inpFastPeriod,i,rates_total,0)/100.0 - 0.5) * 2.0; if (_alphaf<0) _alphaf *= -1.0;
		   double _alphas = (iRsi(_price,inpSlowPeriod,i,rates_total,1)/100.0 - 0.5) * 2.0; if (_alphas<0) _alphas *= -1.0;

         //
         //---
         //
         
         if (i>0)
         {      
            emaf[i]   = emaf[i-1] + _alphaf*(_price-emaf[i-1]);
            emas[i]   = emas[i-1] + _alphas*(_price-emas[i-1]);
            val[i]    = emaf[i] - emas[i];
            signal[i] = signal[i-1] + °_alphaSignal*(val[i]-signal[i-1]);
            if (prev_i!=i)
            {
               prev_i = i; 
               int start    = i-inpFlPeriod+1; if (start<0) start=0;
                  prev_max = val[ArrayMaximum(val,start,inpFlPeriod-1)];
                  prev_min = val[ArrayMinimum(val,start,inpFlPeriod-1)];
            }
            double min = (val[i] < prev_min) ? val[i] : prev_min;
            double max = (val[i] > prev_max) ? val[i] : prev_max;
            double range = (max-min)/100.0;
               levu[i] = min+inpFlLevelUp*range;
               levd[i] = min+inpFlLevelDn*range;
               levm[i] = min+        50.0*range;
         
            //
            //
            //
         
            switch (inpColorChange)
            {
               case cchange_onLevels : valc[i] = (val[i]>levu[i]) ? 1 :(val[i]<levd[i]) ? 2 : 0; break;
               case cchange_onSignal : valc[i] = (val[i]>signal[i]) ? 1 :(val[i]<signal[i]) ? 2 : 0; break;
               case cchange_onSlope  : valc[i] = (val[i]>val[i-1]) ? 1 :(val[i]<val[i-1]) ? 2 : valc[i-1]; break;
               case cchange_onZero   : valc[i] = (val[i]>levm[i]) ? 1 :(val[i]<levm[i]) ? 2 : 0; break;
            }         
         }            
         else { emaf[i] = emas[i] = _price; val[i] = valc[i]= signal[i] = 0; }
   }
   return (i);
}

//------------------------------------------------------------------
// Custom functions
//------------------------------------------------------------------
//
//---
//

double iRsi(double price, double period, int i, int bars, int _instanceNo=0)
{
   struct sRsiStruct
   {
      double price;
      double change;
      double changa;
   };
   static sRsiStruct m_array[][2];
   static int m_arraySize = -1;
          if (m_arraySize<bars)
          {
              m_arraySize = ArrayResize(m_array,bars+500); if (m_arraySize<bars) return(0);
          }

   //
   //---
   //

   double alpha=1.0/period;
   m_array[i][_instanceNo].price=price;
   if(i<period)
      {
         int k; double sum=0; 
            for(k=0; k<period && i>k; k++) sum+=MathAbs(m_array[i-k][_instanceNo].price-m_array[i-k-1][_instanceNo].price);
               m_array[i][_instanceNo].change = (m_array[i][_instanceNo].price-m_array[0][_instanceNo].price)/MathMax(k,1);
               m_array[i][_instanceNo].changa =                                                           sum/MathMax(k,1);
      }
      else
      {
         double change = m_array[i][_instanceNo].price-m_array[i-1][_instanceNo].price;
            m_array[i][_instanceNo].change = m_array[i-1][_instanceNo].change + alpha*(change - m_array[i-1][_instanceNo].change);
            if (change>0)
                  m_array[i][_instanceNo].changa = m_array[i-1][_instanceNo].changa + alpha*( change - m_array[i-1][_instanceNo].changa);
            else  m_array[i][_instanceNo].changa = m_array[i-1][_instanceNo].changa + alpha*(-change - m_array[i-1][_instanceNo].changa);
      }
      if (m_array[i][_instanceNo].changa!=0)
            return(50.0*(m_array[i][_instanceNo].change/m_array[i][_instanceNo].changa+1.0));
      else  return(0);
}

//
//---
//

template <typename T>
double getPrice(ENUM_APPLIED_PRICE tprice, T& open[],T& close[],T& high[], T& low[],int i)
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
//------------------------------------------------------------------+
