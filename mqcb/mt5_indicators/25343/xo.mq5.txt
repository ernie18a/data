//------------------------------------------------------------------
#property copyright "© mladen, 2019"
#property link      "mladenfx@gmail.com"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_label1  "XO"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrDarkGray,clrLimeGreen,clrOrangeRed
#property indicator_width1  2

//
//
//

input double             inpBoxSize = 6.5;         // Box size
input ENUM_APPLIED_PRICE inpPrice   = PRICE_CLOSE; // Price

double val[],valc[]; 

//------------------------------------------------------------------
//
//------------------------------------------------------------------

int OnInit()
{
   SetIndexBuffer(0,val,INDICATOR_DATA);
   SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);

      //
      //
      //

         iXo.init(inpBoxSize);
         IndicatorSetString(INDICATOR_SHORTNAME,"XO ("+(string)inpBoxSize+")");
   return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { }

//------------------------------------------------------------------
//
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
   int i=(prev_calculated>0?prev_calculated-1:0); for (; i<rates_total && !_StopFlag; i++)
   {
      double _trend; val[i]  = iXo.calculate(getPrice(inpPrice,open,high,low,close,i),_trend,i,rates_total);
                     valc[i] = (_trend==1) ? 1 : (_trend==-1) ? 2 : 0;
   }
   return(i);
}

//------------------------------------------------------------------
// Custom class(es) and function(s)
//------------------------------------------------------------------
//
//---
//

class CXo
{
   private :
      string m_symbol;
      double m_boxSize;
      bool   m_firstCalcDone;
      struct sXoStruct
      {
         double high;
         double low;
         double pos;
         double neg;
         double trend;
      };
      sXoStruct m_array[];
      int       m_arraySize;
   public :
      CXo() : m_arraySize(-1), m_boxSize(0), m_firstCalcDone(false) {}
     ~CXo() {};
     
      ///
      ///
      ///
     
      void init (double _boxSize, string _symbol="")
      {
         m_symbol  = (_symbol=="") ? _Symbol : _symbol;
         m_boxSize = _boxSize*SymbolInfoDouble(m_symbol,SYMBOL_POINT)*MathPow(10,(int)SymbolInfoInteger(m_symbol,SYMBOL_DIGITS)%2);
      }
      
      //
      //
      //
      
      double calculate(double _value, double& _trend, int i, int bars)
      {
         if (m_arraySize<bars) { m_arraySize = ArrayResize(m_array,bars+500); if (m_arraySize<bars) { _trend = 0; return(0); }}

         //
         //
         //

         if (i>0 && m_firstCalcDone) 
         {
            m_array[i].high  = m_array[i-1].high;
            m_array[i].low   = m_array[i-1].low;
            m_array[i].pos   = m_array[i-1].pos;
            m_array[i].neg   = m_array[i-1].neg;
            m_array[i].trend = m_array[i-1].trend;
               if (_value > (m_array[i].high+m_boxSize))
               {
                    m_array[i].high  = _value;
                    m_array[i].low   = _value-m_boxSize;
                    m_array[i].pos   = m_array[i-1].pos+1;
                    m_array[i].neg   = 0;
                    m_array[i].trend = 1;
               }
               if (_value < (m_array[i].low-m_boxSize))
               {
                    m_array[i].low   = _value;
                    m_array[i].high  = _value+m_boxSize;
                    m_array[i].neg   = m_array[i-1].neg-1;
                    m_array[i].pos   = 0;
                    m_array[i].trend = -1;
               }
          }
          else { m_array[i].high = m_array[i].low = _value; m_array[i].pos = m_array[i].neg =  m_array[i].trend = 0; m_firstCalcDone = true; }
          
          //
          //
          //
          
          _trend = m_array[i].trend;
          return  (m_array[i].trend==1 ? m_array[i].pos : m_array[i].neg);
      }
};
CXo iXo;

//
//---
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