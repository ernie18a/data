//------------------------------------------------------------------
#property copyright   "copyright© mladen 2020"
#property link        "mladenfx@gmail.com"
#property description "Step chart"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   1
#property indicator_label1  "Step chart"
#property indicator_type1   DRAW_COLOR_HISTOGRAM2
#property indicator_color1  clrDodgerBlue,clrOrangeRed
#property indicator_width1  5

//
//
//

input double             inpStepSize = 5;           // Step size (pips)
input ENUM_APPLIED_PRICE inpPrice    = PRICE_CLOSE; // Price

double barh[],barl[],barc[],_stepSize;

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//

int OnInit()
{
   SetIndexBuffer(0,barh,INDICATOR_DATA);
   SetIndexBuffer(1,barl,INDICATOR_DATA);
   SetIndexBuffer(2,barc,INDICATOR_COLOR_INDEX);

      //
      //
      //
      
      _stepSize = MathMax(inpStepSize*_Point*MathPow(10,_Digits%2),_Point);

      //
      //
      //
      
   IndicatorSetString(INDICATOR_SHORTNAME,"Step chart ("+(string)inpStepSize+")");
   return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { }
 

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//

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
   int limit = prev_calculated-1; if (limit<0) limit=0;
      struct sWorkStruct
      {
         double steps;
         double trend;
      };
      static sWorkStruct m_array[];
      static int         m_arraySize = -1;
                     if (m_arraySize<rates_total) m_arraySize = ArrayResize(m_array,rates_total+500,2000);
   
   //
   //---
   //
   
   for(int i=limit; i<rates_total && !_StopFlag; i++)
   {
      double _price= getPrice(inpPrice,open[i],high[i],low[i],close[i]);
      if (i==0)
      { 
         m_array[i].steps = MathRound(_price/_stepSize)*_stepSize;
         m_array[i].trend = 0; continue; 
      }
      
      //
      //
      //
      
         m_array[i].steps = m_array[i-1].steps;
         double _diff = _price-m_array[i].steps;
            if (_diff < 0) _diff *= -1;
            if (_diff >= _stepSize)
                  m_array[i].steps += int((_price-m_array[i].steps)/_stepSize)*(double)_stepSize;
                  m_array[i].trend = (m_array[i].steps > m_array[i-1].steps) ?  1 : 
                                     (m_array[i].steps < m_array[i-1].steps) ? -1 : m_array[i-1].trend;

         //
         //
         //
                                                
         barc[i] = m_array[i  ].trend==1 ? 0 : 1;
         barh[i] = m_array[i  ].steps;
         barl[i] = m_array[i-1].steps;
            if (barh[i]==barl[i]) barl[i] = barh[i]-_Point*3;
   }
   return (rates_total);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//---
//

template <typename T>
double getPrice(ENUM_APPLIED_PRICE tprice, T& open, T& high, T& low, T& close)
{
   switch(tprice)
   {
      case PRICE_CLOSE:     return(close);
      case PRICE_OPEN:      return(open);
      case PRICE_HIGH:      return(high);
      case PRICE_LOW:       return(low);
      case PRICE_MEDIAN:    return((high+low)/2.0);
      case PRICE_TYPICAL:   return((high+low+close)/3.0);
      case PRICE_WEIGHTED:  return((high+low+close+close)/4.0);
   }
   return(0);
}
