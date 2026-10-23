//+------------------------------------------------------------------
#property copyright   "mladen"
#property link        "mladenfx@gmail.com"
#property link        "https://forge.mql5.io"
#property description "ATR Probability Levels"
//+------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0

//--- input parameters
input ENUM_TIMEFRAMES inpTimeFrame   = PERIOD_D1;      // Timeframe for data
input int             inpAtrPeriod   = 21;             // ATR period
input color           inpUp          = clrDeepSkyBlue; // Color for high levels
input color           inpDn          = clrOrangeRed;   // Color for low levels
input string          inpUniqueID    = "AtrLevels1";   // Unique ID for objects
input int             inpLabelsShift = 10;             // Labels shift
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   return (INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0,inpUniqueID+":"); return;
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   MqlRates _rates[]; int _ratesCopied=CopyRates(_Symbol,inpTimeFrame,1,inpAtrPeriod+1,_rates);
   if(_ratesCopied != inpAtrPeriod+1) return(prev_calculated);

   double _atr    = 0; for(int k=0;k<inpAtrPeriod; k++) _atr += MathMax(_rates[k+1].high,_rates[k].close)-MathMin(_rates[k+1].low,_rates[k].close); _atr /= inpAtrPeriod;
   double _pclose = _rates[inpAtrPeriod].close;
   string _tf     = timeFrameToString(inpTimeFrame);
   datetime _time = time[rates_total-1]+PeriodSeconds(_Period)*inpLabelsShift;
   _createLine("res3",_pclose+_atr,_time,inpUp,inpUp,_tf+" probability band R3 ("+DoubleToString(_pclose+_atr,_Digits)+")");
   _createLine("res2",_pclose+_atr*0.75,_time,inpUp,inpUp,_tf+" probability band R2 ("+DoubleToString(_pclose+_atr*0.75,_Digits)+")");
   _createLine("res1",_pclose+_atr*0.50,_time,inpUp,inpUp,_tf+" probability band R1 ("+DoubleToString(_pclose+_atr*0.50,_Digits)+")");
   _createLine("sup1",_pclose-_atr*0.50,_time,inpDn,inpDn,_tf+" probability band S1 ("+DoubleToString(_pclose-_atr*0.50,_Digits)+")");
   _createLine("sup2",_pclose-_atr*0.75,_time,inpDn,inpDn,_tf+" probability band S2 ("+DoubleToString(_pclose-_atr*0.75,_Digits)+")");
   _createLine("sup3",_pclose-_atr,_time,inpDn,inpDn,_tf+" probability band S3 ("+DoubleToString(_pclose-_atr,_Digits)+")");
   ChartRedraw();
   return (rates_total);
  }
//+------------------------------------------------------------------+
//| Custom function(s)                                               |
//+------------------------------------------------------------------+
void _createLine(string _add,double _price,datetime _time,color _color,color _textColor,string _text,int _style=STYLE_DOT)
  {
   string _name=inpUniqueID+":"+_add;
   ObjectCreate(0,_name,OBJ_HLINE,0,0,0);
   ObjectSetInteger(0,_name,OBJPROP_COLOR,_color);
   ObjectSetInteger(0,_name,OBJPROP_STYLE,_style);
   ObjectSetDouble(0,_name,OBJPROP_PRICE,0,_price);
   _name=inpUniqueID+":label:"+_add;
   ObjectCreate(0,_name,OBJ_TEXT,0,0,0);
   ObjectSetInteger(0,_name,OBJPROP_COLOR,_textColor);
   ObjectSetInteger(0,_name,OBJPROP_TIME,0,_time);
   ObjectSetInteger(0,_name,OBJPROP_FONTSIZE,8);
   ObjectSetDouble(0,_name,OBJPROP_PRICE,0,_price);
   ObjectSetString(0,_name,OBJPROP_FONT,"Arial");
   ObjectSetString(0,_name,OBJPROP_TEXT,_text);
  }
//------------------  
int    _tfsPer[]={PERIOD_M1,PERIOD_M2,PERIOD_M3,PERIOD_M4,PERIOD_M5,PERIOD_M6,PERIOD_M10,PERIOD_M12,PERIOD_M15,PERIOD_M20,PERIOD_M30,PERIOD_H1,PERIOD_H2,PERIOD_H3,PERIOD_H4,PERIOD_H6,PERIOD_H8,PERIOD_H12,PERIOD_D1,PERIOD_W1,PERIOD_MN1};
string _tfsStr[]={"1 minute","2 minutes","3 minutes","4 minutes","5 minutes","6 minutes","10 minutes","12 minutes","15 minutes","20 minutes","30 minutes","1 hour","2 hours","3 hours","4 hours","6 hours","8 hours","12 hours","daily","weekly","monthly"};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string timeFrameToString(int period)
  {
   if(period==PERIOD_CURRENT)
      period=_Period;
   int i; for(i=0;i<ArraySize(_tfsPer);i++) if(period==_tfsPer[i]) break;
   return(_tfsStr[i]);
  }
//+------------------------------------------------------------------+
