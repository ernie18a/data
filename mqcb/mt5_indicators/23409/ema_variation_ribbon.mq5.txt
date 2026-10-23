//------------------------------------------------------------------
#property copyright "© mladen, 2018"
#property link      "mladenfx@gmail.com"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots   3
#property indicator_label1  "Ribbon"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  C'235,255,235',C'255,235,235'
#property indicator_label2  "EMA fast"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrDarkGray,clrMediumSeaGreen,clrOrangeRed
#property indicator_label3  "EMA slow"
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  clrDarkGray,clrMediumSeaGreen,clrOrangeRed
#property indicator_width3  2

//
//--- input parameters
//

input int                inpPeriod   = 14;          // Period
input double             inpDivisorf = 2.5;         // Fast "speed"
input double             inpDivisors = 1.8;         // Slow "speed"
input ENUM_APPLIED_PRICE inpPrice    = PRICE_CLOSE; // Price

//
//--- indicator buffers
//
double valf[],valfc[],vals[],valsc[],fillu[],filld[]; 

//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------

int OnInit()
{
   //
   //--- indicator buffers mapping
   //
         SetIndexBuffer(0,fillu,INDICATOR_DATA);
         SetIndexBuffer(1,filld,INDICATOR_DATA);
         SetIndexBuffer(2,valf ,INDICATOR_DATA);
         SetIndexBuffer(3,valfc,INDICATOR_COLOR_INDEX);
         SetIndexBuffer(4,vals ,INDICATOR_DATA);
         SetIndexBuffer(5,valsc,INDICATOR_COLOR_INDEX);
            iEmaf.init(inpPeriod,inpDivisorf);
            iEmas.init(inpPeriod,inpDivisors);
   //
   //--- indicator short name assignment
   //
   IndicatorSetString(INDICATOR_SHORTNAME,"Ema variation ribbon ("+(string)inpPeriod+","+(string)inpDivisorf+","+(string)inpDivisors+")");
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
      valf[i]  = fillu[i] = iEmaf.calculate(_price,i);
      vals[i]  = filld[i] = iEmas.calculate(_price,i);
      valfc[i] = valsc[i] = (valf[i]>vals[i]) ? 1 :(valf[i]<vals[i]) ? 2 : (i>0) ? valfc[i-1]: 0;
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
CEmaVar iEmaf,iEmas;