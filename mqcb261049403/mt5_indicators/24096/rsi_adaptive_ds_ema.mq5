//------------------------------------------------------------------
#property copyright "© mladen, 2018"
#property link      "mladenfx@gmail.com"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   1
#property indicator_label1  "RSI adaptive DS EMA"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrCrimson,clrForestGreen
#property indicator_width1  2
//
//--- input parameters
//
input double             inpPeriod = 32;          // RSI period
input ENUM_APPLIED_PRICE inpPrice  = PRICE_CLOSE; // Price
//
//--- indicator buffers
//
double val[],valc[],valw[];

//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------
//
//---
//
 
int OnInit()
{
   //
   //--- indicator buffers mapping
   //
         SetIndexBuffer(0,val,INDICATOR_DATA);
         SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
         SetIndexBuffer(2,valw,INDICATOR_CALCULATIONS);
   //         
   //--- indicator short name assignment
   //
   IndicatorSetString(INDICATOR_SHORTNAME,"RSI adaptive ds EMA ("+(string)inpPeriod+")");
   return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { }

//------------------------------------------------------------------
// Custom indicator iteration function
//------------------------------------------------------------------
//
//---
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
   int i=prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
         double _price = getPrice(inpPrice,open,close,high,low,i);
		   double _alpha = (iRsi(_price,inpPeriod,i,rates_total) - 0.5) * 2.0; 
		      if (_alpha<0) _alpha *= -1.0; 
		          _alpha = MathSqrt(_alpha);
         
         //
         //---
         //
         
		   if (i>0)
		   {
		      valw[i] = valw[i-1] + _alpha*(_price -valw[i-1]);
            val[i]  = val[i-1]  + _alpha*(valw[i]-val[i-1]);
            valc[i] = (val[i]>val[i-1]) ? 2 :(val[i]<val[i-1]) ? 1 : valc[i-1];
         }
         else { val[i] = valw[i] = _price; valc[i] = 0; } 
   }
   return(i);
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
            return(0.5*(m_array[i][_instanceNo].change/m_array[i][_instanceNo].changa+1.0));
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