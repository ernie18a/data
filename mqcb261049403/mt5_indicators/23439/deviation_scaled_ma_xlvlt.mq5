//------------------------------------------------------------------
#property copyright "© mladen, 2018"
#property link      "mladenfx@gmail.com"
#property version   "1.00"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   3
#property indicator_label1  "up level"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrLimeGreen
#property indicator_style1  STYLE_DOT
#property indicator_label2  "down level"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrOrange
#property indicator_style2  STYLE_DOT
#property indicator_label3  "DSMA"
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  clrSilver,clrMediumSeaGreen,clrOrangeRed
#property indicator_width3  2

//
//---
//

input int                inpPeriod  = 20;          // Period
input ENUM_APPLIED_PRICE inpPrice   = PRICE_CLOSE; // Price

//
//---
//

double val[],valc[],levelUp[],levelDn[];

//------------------------------------------------------------------
//  Custom indicator initialization function
//------------------------------------------------------------------

void OnInit()
{
   //
   //---- indicator buffers mapping
   //
         SetIndexBuffer(0,levelUp,INDICATOR_DATA); 
         SetIndexBuffer(1,levelDn,INDICATOR_DATA);
         SetIndexBuffer(2,val    ,INDICATOR_DATA);
         SetIndexBuffer(3,valc   ,INDICATOR_COLOR_INDEX);
            PlotIndexSetInteger(0,PLOT_SHOW_DATA,false);
            PlotIndexSetInteger(1,PLOT_SHOW_DATA,false);
               iDsma.init(inpPeriod);
               iDsmaUp.init(inpPeriod);
               iDsmaDn.init(inpPeriod);
   //
   //---
   //         
   IndicatorSetString(INDICATOR_SHORTNAME,"DSMA levels ("+(string)inpPeriod+")");
}

//------------------------------------------------------------------
//  Custom indicator iteration function
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
   int i= prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      double _price; _setPrice(inpPrice,_price,i);
      val[i]     = iDsma.calculate(_price,i,false);
      levelUp[i] = iDsmaUp.calculate(val[i],i,(i>0 ? !(val[i]>levelDn[i-1]) : false));
      levelDn[i] = iDsmaDn.calculate(val[i],i,(i>0 ? !(val[i]<levelUp[i-1]) : false));
      valc[i]    = (val[i]>=levelUp[i]) ? 1 : (val[i]<=levelDn[i]) ? 2 : 0;
   }
   return(i);
}

//------------------------------------------------------------------
//  Custom function(s)
//------------------------------------------------------------------
//
//---
//

class cDsma
{
   private :
         int    m_period;
         int    m_arraysize;
         double m_periodMultiplier;
         double m_sc1;
         double m_sc2;
         double m_sc3;
            struct sDsmaArray
            {
               double filter;
               double price;
               double dsm;
               double ssm;
               double mul;
               double sum;
            };
         sDsmaArray m_array[];
                     
   public : 
         cDsma() { init(1); }
        ~cDsma() {};
   
         //
         //
         //
         
         void init(int period)
         {
            m_period           = (period>1) ? period : 1;
            m_periodMultiplier = 5.0 / (double)m_period;
            m_arraysize        = m_period+32;

               ArrayResize(m_array,m_arraysize);
               double a1 = MathExp(-1.414*M_PI_2/m_period);
                   m_sc2 = 2.0*a1*MathCos(1.414*M_PI/m_period);
                   m_sc3 = -a1*a1;
                   m_sc1 = 1.0 - m_sc2 - m_sc3;
         }
         
         double calculate(double price, int i, bool copy)
         {
            int _indC = (i)%m_arraysize; m_array[_indC].price = price;
            
            //
            //---
            //
            
            if (i>1)
            {
               int _indP  = (i-1)%m_arraysize;
               int _indP2 = (i-2)%m_arraysize;
                     m_array[_indC].filter = m_array[_indC].price-m_array[_indP2].price;
                     m_array[_indC].ssm    = m_sc1*(m_array[_indC].filter+m_array[_indP].filter)/2.0 + 
                                             m_sc2*m_array[_indP ].ssm                               + 
                                             m_sc3*m_array[_indP2].ssm; 
                    
                     m_array[_indC].mul = m_array[_indC].ssm*m_array[_indC].ssm;
                     if  (i>m_period)
                            m_array[_indC].sum = m_array[_indP].sum+m_array[_indC].mul-m_array[(i-m_period)%m_arraysize].mul;
                     else { m_array[_indC].sum = m_array[_indC].mul; for (int k=1; k<m_period && i>=k; k++) m_array[_indC].sum += m_array[_indC-k].mul; }
                     
                     //
                     //---
                     //
                     
                     if (!copy)
                     {
                        double  rms        = m_array[_indC].sum ? MathSqrt(m_array[_indC].sum / m_period) : 1;
                        double _scaledFilt = m_array[_indC].ssm / rms;
                        double _alpha      = (_scaledFilt>0 ? _scaledFilt : -_scaledFilt) * m_periodMultiplier;
         
                          m_array[_indC].dsm = m_array[_indP].dsm+_alpha*(price-m_array[_indP].dsm);
                     }
                     else m_array[_indC].dsm = m_array[_indP].dsm;
            }
            else { m_array[_indC].dsm = price; m_array[_indC].ssm = m_array[_indC].mul = m_array[_indC].filter = 0; }
            return(m_array[_indC].dsm);
         }
};
cDsma iDsma,iDsmaUp,iDsmaDn;
//------------------------------------------------------------------