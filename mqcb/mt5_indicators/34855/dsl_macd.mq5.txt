//------------------------------------------------------------------
#property copyright "© mladen, 2021"
#property link      "mladenfx@gmail.com"
#property version   "2.00"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   4
#property indicator_label1  "up trend;down trend"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  clrLimeGreen,clrOrange
#property indicator_label2  "up level"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrLimeGreen
#property indicator_style2  STYLE_DOT
#property indicator_label3  "down level"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrOrange
#property indicator_style3  STYLE_DOT
#property indicator_label4  "MACD"
#property indicator_type4   DRAW_COLOR_LINE
#property indicator_color4  clrSilver,clrLimeGreen,clrOrange
#property indicator_width4  2

//
//
//

input double             inpFastEma      = 12;          // Fast ema period
input double             inpSlowEma      = 26;          // Slow ema period
input double             inpSignalPeriod = 9;           // Signal period
input ENUM_APPLIED_PRICE inpPrice        = PRICE_CLOSE; // Price
      enum enDisplayZones
         {
            zones_yes = (int)true,   // Display filled zoned
            zones_no  = (int)false,  // No filled zones display
         };
input enDisplayZones    inpZones        = zones_yes;    // Zones display mode 

//
//
//

double  val[],valc[],levelUp[],levelDn[],fillUp[],fillDn[];
struct sGlobalStruct
{
   double alphaFast;
   double alphaSlow;
   double alphaSignal;
};
sGlobalStruct global;

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//

void OnInit()
{
   SetIndexBuffer(0,fillUp ,INDICATOR_DATA);
   SetIndexBuffer(1,fillDn ,INDICATOR_DATA);
   SetIndexBuffer(2,levelUp,INDICATOR_DATA);
   SetIndexBuffer(3,levelDn,INDICATOR_DATA);
   SetIndexBuffer(4,val    ,INDICATOR_DATA);
   SetIndexBuffer(5,valc   ,INDICATOR_COLOR_INDEX);
   
      //
      //
      //
      
      global.alphaFast   = 2.0/(1.0+MathMax(inpFastEma,1.0));
      global.alphaSlow   = 2.0/(1.0+MathMax(inpSlowEma,1.0));
      global.alphaSignal = 2.0/(1.0+MathMax(inpSignalPeriod,1.0));
   IndicatorSetString(INDICATOR_SHORTNAME,StringFormat("(dsl) MACD (%s,%s,%s)",(string)inpFastEma,(string)inpSlowEma,(string)inpSignalPeriod));
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
{
   int limit = (prev_calculated>0) ? prev_calculated-1 : 0;
   
   //
   //
   //
   
         struct sWorkStruct
            {
               double fastEma;
               double slowEma;
            };
         static sWorkStruct m_work[];
         static int         m_workSize = -1;
                        if (m_workSize<rates_total) m_workSize = ArrayResize(m_work,rates_total+500,2000);            

   //
   //
   //
   
   for (int i=limit; i<rates_total && !_StopFlag; i++)
   {
      double _price = getPrice(inpPrice,open,high,low,close,i);
            m_work[i].fastEma = (i>0) ? m_work[i-1].fastEma + global.alphaFast*(_price-m_work[i-1].fastEma) : _price;
            m_work[i].slowEma = (i>0) ? m_work[i-1].slowEma + global.alphaSlow*(_price-m_work[i-1].slowEma) : _price;

            //
            //
            //

            val[i]     = m_work[i].fastEma-m_work[i].slowEma;
            levelUp[i] = (i>0) ? (val[i]>0) ? levelUp[i-1]+global.alphaSignal*(val[i]-levelUp[i-1]) : levelUp[i-1] : 0;
            levelDn[i] = (i>0) ? (val[i]<0) ? levelDn[i-1]+global.alphaSignal*(val[i]-levelDn[i-1]) : levelDn[i-1] : 0;
            valc[i]    = (val[i]>levelUp[i]) ? 1 : (val[i]<levelDn[i]) ? 2 : 0;
            if (inpZones)
               {
                  fillUp[i]  = val[i];
                  fillDn[i]  = (valc[i]==1) ? levelUp[i] : (valc[i]==2) ? levelDn[i] : val[i];
               }
            else fillUp[i] = fillDn[i] = EMPTY_VALUE;
   }        
   return(rates_total);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//

template <typename T>
double getPrice(ENUM_APPLIED_PRICE tprice, T& open[], T& high[], T& low[], T& close[], int i)
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