//------------------------------------------------------------------
#property copyright   "© mladen, 2019"
#property link        "mladenfx@gmail.com"
#property description "Kirshenbaum Bands"
//+------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   3
#property indicator_label1  "Band up"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrMediumSeaGreen
#property indicator_label2  "Average"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDarkGray
#property indicator_style2  STYLE_DOT
#property indicator_label3  "Band down"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrOrangeRed
//
//--- input parameters
//
input int                inpBandPeriod     = 21;          // Bands period
input ENUM_APPLIED_PRICE inpBandPrice      = PRICE_CLOSE; // Price
input ENUM_MA_METHOD     inpBandMethod     = MODE_EMA;    // Bands average method
input double             inpBandDeviations = 2;           // Bands deviation
//
//
//
double valu[],vald[],vala[];
int _maHandle;

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
         SetIndexBuffer(0,valu,INDICATOR_DATA);
         SetIndexBuffer(1,vala,INDICATOR_DATA);
         SetIndexBuffer(2,vald,INDICATOR_DATA);
            _maHandle=iMA(_Symbol,0,inpBandPeriod,0,inpBandMethod,inpBandPrice); if(_maHandle==INVALID_HANDLE) { return(INIT_FAILED); }
   //            
   //---
   //
   IndicatorSetString(INDICATOR_SHORTNAME,"Kirshenbaum "+StringSubstr(EnumToString(inpBandMethod),5)+" bands ("+(string)inpBandPeriod+")");
   return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { }

//------------------------------------------------------------------
//
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
   int _copyCount = rates_total-prev_calculated+1; if (_copyCount>rates_total) _copyCount=rates_total;
         if (CopyBuffer(_maHandle,0,0,_copyCount,vala)!=_copyCount) return(prev_calculated);
   
   //
   //---
   //
  

   int i=(prev_calculated>0?prev_calculated-1:0); for (; i<rates_total && !_StopFlag; i++)
   {
      double price = getPrice(inpBandPrice,open,close,high,low,i);
      double error = iStdError(price,inpBandPeriod,i,rates_total);
         if (vala[i]==EMPTY_VALUE) vala[i] = price;
             valu[i] = vala[i] + inpBandDeviations*error;
             vald[i] = vala[i] - inpBandDeviations*error;
   }
   return (i);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//

double iStdError(double price, int period, int i, int bars)
{
   static int    m_arraySize = -1;
   static double m_array[]; 
      if (m_arraySize<bars) { m_arraySize = ArrayResize(m_array,bars+500); if (m_arraySize<bars) return(0); }
   
                        
      //
      //
      //
      //
      //
                  
      m_array[i] = price;                  
      double avgx  = period * (period-1) * 0.5 / period;
      double avgy  = m_array[i]; int j=1; for ( ;j<period && (i-j)>=0; j++) avgy += m_array[i-j]; avgy /= j;
      double sumdx = 0, sumdy = 0, sumdxdy = 0;
  
         for (int k=0; k<period && i>=k; k++)
         {
            double dx = k-avgx;
            double dy = m_array[i-k]-avgy;
               sumdx    += (dx*dx);
               sumdy    += (dy*dy);
               sumdxdy  += (dx*dy);
         }
         double err = (sumdx!=0) ? (sumdy-(sumdxdy*sumdxdy)/sumdx)/(period-2.0) : 0; 

         if (err > 0)
               return(MathSqrt(err));
         else  return(0.00);       
}

//
//
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
