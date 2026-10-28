//------------------------------------------------------------------
#property copyright "© mladen, 2018"
#property link      "mladenfx@gmail.com"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_label1  "EMA"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrMediumSeaGreen,clrOrangeRed
#property indicator_width1  2

//
//--- input parameters
//

input int                inpPeriod  = 20;          // Period
input double             inpDivisor = 3;           // Speed
input ENUM_APPLIED_PRICE inpPrice   = PRICE_CLOSE; // Price

//
//--- indicator buffers
//
double val[],valc[]; 

//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------

int OnInit()
{
   //
   //--- indicator buffers mapping
   //
         SetIndexBuffer(0,val,INDICATOR_DATA);
         SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
            iEma.init(inpPeriod,inpDivisor);
   //
   //--- indicator short name assignment
   //
   IndicatorSetString(INDICATOR_SHORTNAME,"Ema variation ("+(string)inpPeriod+","+(string)inpDivisor+")");
   return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason)
{
}

//------------------------------------------------------------------
// Custom indicator iteration function
//------------------------------------------------------------------
//
//---
//

#define _setPrice(_priceType,_target,_index) \
   { \
   switch(_priceType) \
   { \
      case PRICE_CLOSE:    _target = close[_index];                                              break; \
      case PRICE_OPEN:     _target = open[_index];                                               break; \
      case PRICE_HIGH:     _target = high[_index];                                               break; \
      case PRICE_LOW:      _target = low[_index];                                                break; \
      case PRICE_MEDIAN:   _target = (high[_index]+low[_index])/2.0;                             break; \
      case PRICE_TYPICAL:  _target = (high[_index]+low[_index]+close[_index])/3.0;               break; \
      case PRICE_WEIGHTED: _target = (high[_index]+low[_index]+close[_index]+close[_index])/4.0; break; \
      default : _target = 0; \
   }}
   
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
      double _price; _setPrice(inpPrice,_price,i);
      val[i]  = iEma.calculate(_price,i);
      valc[i] = (i>0) ?(val[i]>val[i-1]) ? 1 :(val[i]<val[i-1]) ? 2 : valc[i-1]: 0;
   }
   return(i);
}

//------------------------------------------------------------------
// Custom class(es)
//------------------------------------------------------------------
//
//---
//

class CEmaVar
{
   #define _ringSize 32 
   private :
         double m_period;
         double m_divisor;
         double m_alpha;
         struct sEmaVarStruct
         {
            double ema1;
            double ema2;
         };
         sEmaVarStruct m_array[_ringSize];
   public :
      CEmaVar() { init(1,1); return; }
     ~CEmaVar() {            return; }
     
     //
     //---
     //
     
     void init(int period, double divisor)
         {
            m_period  = (period>1) ? period : 1;
            m_divisor = (divisor>0) ? divisor : 1;
            m_alpha   = 2.0/(1.0+m_period/m_divisor);
         }
      double calculate(double value, int i)
         {
            int _indC = (i)%_ringSize; 
            int _indP = _indC-1; if (_indP<0) _indP+=_ringSize;
               if (i>0)
               {
                    m_array[_indC].ema1 = m_array[_indP].ema1+m_alpha*(value              -m_array[_indP].ema1); 
                    m_array[_indC].ema2 = m_array[_indP].ema2+m_alpha*(m_array[_indC].ema1-m_array[_indP].ema2); 
               }                    
               else m_array[_indC].ema1 = m_array[_indC].ema2 = value;
            return (m_array[_indC].ema2);
         }
   #undef _ringSize
};
CEmaVar iEma;