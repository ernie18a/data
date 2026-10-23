//+------------------------------------------------------------------+
//|                                              Hangseng Trader.mq5 |
//|                              Copyright © 2018, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2018, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.002"
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
//--- input parameters
input double               InpLots              = 0.1;               // Lots
input ushort               InpTrailingStop      = 5;                 // Trailing Stop (in pips)
input ushort               InpTrailingStep      = 5;                 // Trailing Step (in pips)
input uchar                InpNumBars           = 3;                 // Number of DAUY bars for finding support and resistance levels
input int                  Inp_ma_period        = 3;                 // MA: averaging period 
input int                  Inp_ma_shift         = 1;                 // MA: horizontal shift 
input ENUM_MA_METHOD       Inp_ma_method        = MODE_SMA;          // MA: smoothing type 
input ENUM_APPLIED_PRICE   Inp_applied_price    = PRICE_CLOSE;       // MA: type of price 
input ulong                m_magic              = 79131690;          // magic number
//---
input string               InpName              = "FiboLevels";      // Object name 
input color                InpColor             = clrRed;            // Object color 
input ENUM_LINE_STYLE      InpStyle             = STYLE_DASHDOTDOT;  // Line style 
input int                  InpWidth             = 2;                 // Line width 
input bool                 InpBack              = false;             // Background object 
input bool                 InpSelection         = false;             // Highlight to move 
input bool                 InpRayLeft           = true;              // Object's continuation to the left 
input bool                 InpRayRight          = true;              // Object's continuation to the right 
input bool                 InpHidden            = true;              // Hidden in the object list 
input long                 InpZOrder            = 0;                 // Priority for mouse click 
//---
ulong          m_slippage=10;                // slippage
double         ExtTrailingStop=0.0;
double         ExtTrailingStep=0.0;


double m_resist=0.0;
double m_support=0.0;
string m_trend_type="";
string m_signal="";
bool   m_high_first=false;
double fibo_1_000=0.0;
double fibo_0_618=0.0;
double fibo_0_500=0.0;
double fibo_0_382=0.0;
double fibo_0_236=0.0;
double fibo_0_000=0.0;

int    handle_iMA;                           // variable for storing the handle of the iMA indicator 
int    handle_iCustom;                       // variable for storing the handle of the iCustom indicator 

double         m_adjusted_point;             // point value adjusted for 3 or 5 points
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(InpTrailingStop!=0 && InpTrailingStep==0)
     {
      string text=(TerminalInfoString(TERMINAL_LANGUAGE)=="Russian")?
                  "Трейлинг невозможен: параметр \"Trailing Step\" равен нулю!":
                  "Trailing is not possible: parameter \"Trailing Step\" is zero!";
      Alert(__FUNCTION__," ERROR! ",text);
      return(INIT_PARAMETERS_INCORRECT);
     }
//---
   if(!m_symbol.Name(Symbol())) // sets symbol name
      return(INIT_FAILED);
   RefreshRates();

   string err_text="";
   if(!CheckVolumeValue(InpLots,err_text))
     {
      Print(__FUNCTION__,", ERROR: ",err_text);
      return(INIT_PARAMETERS_INCORRECT);
     }
//---
   m_trade.SetExpertMagicNumber(m_magic);
   m_trade.SetMarginMode();
   m_trade.SetTypeFillingBySymbol(m_symbol.Name());
   m_trade.SetDeviationInPoints(m_slippage);
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   m_adjusted_point=m_symbol.Point()*digits_adjust;

   ExtTrailingStop   = InpTrailingStop * m_adjusted_point;
   ExtTrailingStep   = InpTrailingStep * m_adjusted_point;
//--- create handle of the indicator iMA
   handle_iMA=iMA(m_symbol.Name(),Period(),Inp_ma_period,Inp_ma_shift,Inp_ma_method,Inp_applied_price);
//--- if the handle is not created 
   if(handle_iMA==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iCustom
   handle_iCustom=iCustom(m_symbol.Name(),Period(),"Resistance & Support");
//--- if the handle is not created 
   if(handle_iCustom==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iCustom indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- we work only at the time of the birth of new bar
   static datetime PrevBars=0;
   datetime time_0=iTime(m_symbol.Name(),Period(),0);
   if(time_0==PrevBars)
      return;
   PrevBars=time_0;
//---
   if(!FiboMove())
     {
      PrevBars=0;
      return;
     }
/*
   "Resistance & Support":
   buffer 0 -> ResistanceBuffer[];
   buffer 1 -> SupportBuffer[];
*/
   m_resist    = iCustomGet(0,0);
   m_support   = iCustomGet(1,0);
   double ma   = iMAGet(0);
   if(m_resist==EMPTY_VALUE || m_support==EMPTY_VALUE ||
      m_resist==0.0         || m_support==0.0         || ma==0.0 || !RefreshRates())
     {
      PrevBars=0;
      return;
     }
   if(m_symbol.Ask()>ma)
      m_trend_type="Naik";
   if(m_symbol.Bid()<ma)
      m_trend_type="Turun";
   double price_1=ObjectGetDouble(0,InpName,OBJPROP_PRICE,0);
   double price_2=ObjectGetDouble(0,InpName,OBJPROP_PRICE,1);
   if(price_1==0.0 || price_2==0.0)
     {
      PrevBars=0;
      return;
     }
   double fibo_range=price_1-price_2;
   fibo_1_000=price_1;
   fibo_0_618=price_2+fibo_range*0.618;
   fibo_0_500=price_2+fibo_range*0.500;
   fibo_0_382=price_2+fibo_range*0.382;
   fibo_0_236=price_2+fibo_range*0.236;
   fibo_0_000=price_2;
//---
   if(m_high_first==true)
     {
      if(m_symbol.Ask()<fibo_0_236)
         m_signal="Reverse-Buy";
      else if(m_symbol.Bid()>fibo_0_618)
         m_signal="Reverse-Sell";
      else if(m_symbol.Bid()>fibo_0_236 && m_symbol.Ask()<fibo_0_618)
         m_signal="Trading-Area";
      else if(m_symbol.Bid()>fibo_1_000)
         m_signal="Continuation";
      else if(m_symbol.Ask()<fibo_0_000)
         m_signal="Continuation";
     }
   else
     {
      if(m_symbol.Bid()>fibo_0_236)
         m_signal="Reverse-Sell";
      else if(m_symbol.Ask()<fibo_0_618)
         m_signal="Reverse_Buy";
      else if(m_symbol.Bid()>fibo_0_236 && m_symbol.Ask()<fibo_0_618)
         m_signal="Trading-Area";
      else if(m_symbol.Bid()>fibo_1_000)
         m_signal="Continuation";
      else if(m_symbol.Ask()<fibo_0_000)
         m_signal="Continuation";
     }
   CheckForOpen();
   Trailing();
//---
  }
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
  {
//---

  }
//+------------------------------------------------------------------+
//| Refreshes the symbol quotes data                                 |
//+------------------------------------------------------------------+
bool RefreshRates(void)
  {
//--- refresh rates
   if(!m_symbol.RefreshRates())
     {
      Print("RefreshRates error");
      return(false);
     }
//--- protection against the return value of "zero"
   if(m_symbol.Ask()==0 || m_symbol.Bid()==0)
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Check the correctness of the position volume                     |
//+------------------------------------------------------------------+
bool CheckVolumeValue(double volume,string &error_description)
  {
//--- minimal allowed volume for trade operations
   double min_volume=m_symbol.LotsMin();
   if(volume<min_volume)
     {
      if(TerminalInfoString(TERMINAL_LANGUAGE)=="Russian")
         error_description=StringFormat("Объем меньше минимально допустимого SYMBOL_VOLUME_MIN=%.2f",min_volume);
      else
         error_description=StringFormat("Volume is less than the minimal allowed SYMBOL_VOLUME_MIN=%.2f",min_volume);
      return(false);
     }
//--- maximal allowed volume of trade operations
   double max_volume=m_symbol.LotsMax();
   if(volume>max_volume)
     {
      if(TerminalInfoString(TERMINAL_LANGUAGE)=="Russian")
         error_description=StringFormat("Объем больше максимально допустимого SYMBOL_VOLUME_MAX=%.2f",max_volume);
      else
         error_description=StringFormat("Volume is greater than the maximal allowed SYMBOL_VOLUME_MAX=%.2f",max_volume);
      return(false);
     }
//--- get minimal step of volume changing
   double volume_step=m_symbol.LotsStep();
   int ratio=(int)MathRound(volume/volume_step);
   if(MathAbs(ratio*volume_step-volume)>0.0000001)
     {
      if(TerminalInfoString(TERMINAL_LANGUAGE)=="Russian")
         error_description=StringFormat("Объем не кратен минимальному шагу SYMBOL_VOLUME_STEP=%.2f, ближайший правильный объем %.2f",
                                        volume_step,ratio*volume_step);
      else
         error_description=StringFormat("Volume is not a multiple of the minimal step SYMBOL_VOLUME_STEP=%.2f, the closest correct volume is %.2f",
                                        volume_step,ratio*volume_step);
      return(false);
     }
   error_description="Correct volume value";
   return(true);
  }
//+------------------------------------------------------------------+
//| Fibo move                                                        |
//+------------------------------------------------------------------+
bool FiboMove()
  {
   MqlRates ArrRatesDay[];
   ArraySetAsSeries(ArrRatesDay,true);
   int copy_rates=CopyRates(m_symbol.Name(),PERIOD_D1,0,InpNumBars,ArrRatesDay);
   if(copy_rates==-1 || copy_rates!=InpNumBars)
      return(false);
//---
   datetime time_1   = D'1970.01.01 00:00:00';     // first point time 
   double   price_1  = DBL_MIN;                    // first point price 
   datetime time_2   = D'1970.01.01 00:00:00';     // second point time 
   double   price_2  = DBL_MAX;                    // second point price 
   for(int i=0;i<copy_rates;i++)
     {
      if(ArrRatesDay[i].high>price_1)
        {
         time_1=ArrRatesDay[i].time;
         price_1=ArrRatesDay[i].high;
        }
      if(ArrRatesDay[i].low<price_2)
        {
         time_2=ArrRatesDay[i].time;
         price_2=ArrRatesDay[i].low;
        }
     }
   if(time_1==D'1970.01.01 00:00:00' || time_2==D'1970.01.01 00:00:00')
      return(false);
   if(time_1>time_2)
      m_high_first=false;
//--- create an object 
   if(!FiboLevelsCreate(0,InpName,0,time_1,price_1,time_2,price_2,InpColor,
      InpStyle,InpWidth,InpBack,InpSelection,InpRayLeft,InpRayRight,InpHidden,InpZOrder))
     {
      return(false);
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Create Fibonacci Retracement by the given coordinates            | 
//+------------------------------------------------------------------+ 
bool FiboLevelsCreate(const long            chart_ID=0,        // chart's ID 
                      const string          name="FiboLevels", // object name 
                      const int             sub_window=0,      // subwindow index  
                      datetime              time1=0,           // first point time 
                      double                price1=0,          // first point price 
                      datetime              time2=0,           // second point time 
                      double                price2=0,          // second point price 
                      const color           clr=clrRed,        // object color 
                      const ENUM_LINE_STYLE style=STYLE_SOLID, // object line style 
                      const int             width=1,           // object line width 
                      const bool            back=false,        // in the background 
                      const bool            selection=true,    // highlight to move 
                      const bool            ray_left=false,    // object's continuation to the left 
                      const bool            ray_right=false,   // object's continuation to the right 
                      const bool            hidden=true,       // hidden in the object list 
                      const long            z_order=0)         // priority for mouse click 
  {
//--- set anchor points' coordinates if they are not set 
   ChangeFiboLevelsEmptyPoints(time1,price1,time2,price2);
   if(ObjectFind(chart_ID,name)<0)
     {
      //--- reset the error value 
      ResetLastError();
      //--- Create Fibonacci Retracement by the given coordinates 
      if(!ObjectCreate(chart_ID,name,OBJ_FIBO,sub_window,time1,price1,time2,price2))
        {
         Print(__FUNCTION__,
               ": failed to create \"Fibonacci Retracement\"! Error code = ",GetLastError());
         return(false);
        }
      //--- set color 
      ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
      //--- set line style 
      ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
      //--- set line width 
      ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
      //--- display in the foreground (false) or background (true) 
      ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
      //--- enable (true) or disable (false) the mode of highlighting the channel for moving 
      //--- when creating a graphical object using ObjectCreate function, the object cannot be 
      //--- highlighted and moved by default. Inside this method, selection parameter 
      //--- is true by default making it possible to highlight and move the object 
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
      //--- enable (true) or disable (false) the mode of continuation of the object's display to the left 
      ObjectSetInteger(chart_ID,name,OBJPROP_RAY_LEFT,ray_left);
      //--- enable (true) or disable (false) the mode of continuation of the object's display to the right 
      ObjectSetInteger(chart_ID,name,OBJPROP_RAY_RIGHT,ray_right);
      //--- hide (true) or display (false) graphical object name in the object list 
      ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
      //--- set the priority for receiving the event of a mouse click in the chart 
      ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
     }
   else
     {
      if(!FiboLevelsPointChange(chart_ID,name,0,time1,price1) || !FiboLevelsPointChange(chart_ID,name,1,time2,price2))
         return(false);
     }
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Set number of levels and their parameters                        | 
//+------------------------------------------------------------------+ 
bool FiboLevelsSet(int             levels,            // number of level lines 
                   double          &values[],         // values of level lines 
                   color           &colors[],         // color of level lines 
                   ENUM_LINE_STYLE &styles[],         // style of level lines 
                   int             &widths[],         // width of level lines 
                   const long      chart_ID=0,        // chart's ID 
                   const string    name="FiboLevels") // object name 
  {
//--- check array sizes 
   if(levels!=ArraySize(colors) || levels!=ArraySize(styles) ||
      levels!=ArraySize(widths) || levels!=ArraySize(widths))
     {
      Print(__FUNCTION__,": array length does not correspond to the number of levels, error!");
      return(false);
     }
//--- set the number of levels 
   ObjectSetInteger(chart_ID,name,OBJPROP_LEVELS,levels);
//--- set the properties of levels in the loop 
   for(int i=0;i<levels;i++)
     {
      //--- level value 
      ObjectSetDouble(chart_ID,name,OBJPROP_LEVELVALUE,i,values[i]);
      //--- level color 
      ObjectSetInteger(chart_ID,name,OBJPROP_LEVELCOLOR,i,colors[i]);
      //--- level style 
      ObjectSetInteger(chart_ID,name,OBJPROP_LEVELSTYLE,i,styles[i]);
      //--- level width 
      ObjectSetInteger(chart_ID,name,OBJPROP_LEVELWIDTH,i,widths[i]);
      //--- level description 
      ObjectSetString(chart_ID,name,OBJPROP_LEVELTEXT,i,DoubleToString(100*values[i],1));
     }
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Move Fibonacci Retracement anchor point                          | 
//+------------------------------------------------------------------+ 
bool FiboLevelsPointChange(const long   chart_ID=0,        // chart's ID 
                           const string name="FiboLevels", // object name 
                           const int    point_index=0,     // anchor point index 
                           datetime     time=0,            // anchor point time coordinate 
                           double       price=0)           // anchor point price coordinate 
  {
//--- if point position is not set, move it to the current bar having Bid price 
   if(!time)
      time=TimeCurrent();
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- reset the error value 
   ResetLastError();
//--- move the anchor point 
   if(!ObjectMove(chart_ID,name,point_index,time,price))
     {
      Print(__FUNCTION__,
            ": failed to move the anchor point! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Delete Fibonacci Retracement                                     | 
//+------------------------------------------------------------------+ 
bool FiboLevelsDelete(const long   chart_ID=0,        // chart's ID 
                      const string name="FiboLevels") // object name 
  {
//--- reset the error value 
   ResetLastError();
//--- delete the object 
   if(!ObjectDelete(chart_ID,name))
     {
      Print(__FUNCTION__,
            ": failed to delete \"Fibonacci Retracement\"! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Check the values of Fibonacci Retracement anchor points and set  | 
//| default values for empty ones                                    | 
//+------------------------------------------------------------------+ 
void ChangeFiboLevelsEmptyPoints(datetime &time1,double &price1,
                                 datetime &time2,double &price2)
  {
//--- if the second point's time is not set, it will be on the current bar 
   if(!time2)
      time2=TimeCurrent();
//--- if the second point's price is not set, it will have Bid value 
   if(!price2)
      price2=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- if the first point's time is not set, it is located 9 bars left from the second one 
   if(!time1)
     {
      //--- array for receiving the open time of the last 10 bars 
      datetime temp[10];
      CopyTime(Symbol(),Period(),time2,10,temp);
      //--- set the first point 9 bars left from the second one 
      time1=temp[0];
     }
//--- if the first point's price is not set, move it 200 points below the second one 
   if(!price1)
      price1=price2-200*SymbolInfoDouble(Symbol(),SYMBOL_POINT);
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iMA                                 |
//+------------------------------------------------------------------+
double iMAGet(const int index)
  {
   double MA[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iMABuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iMA,0,index,1,MA)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iMA indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(MA[0]);
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iCustom                             |
//|  the buffer numbers are the following:                           |
//+------------------------------------------------------------------+
double iCustomGet(const int buffer,const int index)
  {
   double Custom[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iCustom array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iCustom,buffer,index,1,Custom)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iCustom indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(Custom[0]);
  }
//+------------------------------------------------------------------+
//| CheckForOpen                                                     |
//+------------------------------------------------------------------+
void CheckForOpen()
  {
/*
   if(m_high_first==true)
     {
      if(m_symbol.Ask()<fibo_0_236)
         m_signal="Reverse-Buy";
      else if(m_symbol.Bid()>fibo_0_618)
         m_signal="Reverse-Sell";
      else if(m_symbol.Bid()>fibo_0_236 && m_symbol.Ask()<fibo_0_618)
         m_signal="Trading-Area";
      else if(m_symbol.Bid()>fibo_1_000)
         m_signal="Continuation";
      else if(m_symbol.Ask()<fibo_0_000)
         m_signal="Continuation";
     }
   else
     {
      if(m_symbol.Bid()>fibo_0_236)
         m_signal="Reverse-Sell";
      else if(m_symbol.Ask()<fibo_0_618)
         m_signal="Reverse_Buy";
      else if(m_symbol.Bid()>fibo_0_236 && m_symbol.Ask()<fibo_0_618)
         m_signal="Trading-Area";
      else if(m_symbol.Bid()>fibo_1_000)
         m_signal="Continuation";
      else if(m_symbol.Ask()<fibo_0_000)
         m_signal="Continuation";
     }
*/
   if((m_trend_type=="Naik") && (m_signal=="Trading-Area"))
     {
      if(m_symbol.Ask()>m_resist)
        {
         OpenBuy(m_support,0.0);
         return;
        }
     }

   if(m_trend_type=="Naik" && m_signal=="Reverse-Sell" && !m_high_first)
     {
      if(m_symbol.Ask()<m_resist)
        {
         OpenSell(fibo_1_000,0.0);
         return;
        }
     }

   if(m_trend_type=="Naik" && m_signal=="Reverse-Buy" && !m_high_first)
     {
      if(m_symbol.Bid()<m_resist)
        {
         OpenBuy(fibo_0_000,0.0);
         return;
        }
     }

   if((m_trend_type=="Turun") && (m_signal=="Trading-Area"))
     {
      if(m_symbol.Bid()<m_support)
        {
         OpenSell(m_resist,0.0);
         return;
        }
     }

   if(m_trend_type=="Turun" && m_signal=="Reverse-Sell" && m_high_first)
     {
      if(m_symbol.Bid()<m_resist)
        {
         OpenSell(fibo_1_000,0.0);
         return;
        }
     }

   if(m_trend_type=="Turun" && m_signal=="Reverse-Buy" && m_high_first)
     {
      if(m_symbol.Bid()<m_resist)
        {
         OpenBuy(fibo_0_000,0.0);
         return;
        }
     }
//---

  }
//+------------------------------------------------------------------+
//| Open Buy position                                                |
//+------------------------------------------------------------------+
void OpenBuy(double sl,double tp)
  {
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);
//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double check_volume_lot=m_trade.CheckVolume(m_symbol.Name(),InpLots,m_symbol.Ask(),ORDER_TYPE_BUY);

   if(check_volume_lot!=0.0)
     {
      if(check_volume_lot>=InpLots)
        {
         if(m_trade.Buy(InpLots,m_symbol.Name(),m_symbol.Ask(),sl,tp))
           {
            if(m_trade.ResultDeal()==0)
              {
               Print(__FUNCTION__,", #1 Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               PrintResult(m_trade,m_symbol);
              }
            else
              {
               Print(__FUNCTION__,", #2 Buy -> true. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               PrintResult(m_trade,m_symbol);
              }
           }
         else
           {
            Print(__FUNCTION__,", #3 Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
            PrintResult(m_trade,m_symbol);
           }
        }
      else
        {
         Print(__FUNCTION__,", ERROR: method CheckVolume (",DoubleToString(check_volume_lot,2),") ",
               "< Lots (",DoubleToString(InpLots,2),")");
         return;
        }
     }
   else
     {
      Print(__FUNCTION__,", ERROR: method CheckVolume returned the value of \"0.0\"");
      return;
     }
//---
  }
//+------------------------------------------------------------------+
//| Open Sell position                                               |
//+------------------------------------------------------------------+
void OpenSell(double sl,double tp)
  {
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);
//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double check_volume_lot=m_trade.CheckVolume(m_symbol.Name(),InpLots,m_symbol.Bid(),ORDER_TYPE_SELL);

   if(check_volume_lot!=0.0)
     {
      if(check_volume_lot>=InpLots)
        {
         if(m_trade.Sell(InpLots,m_symbol.Name(),m_symbol.Bid(),sl,tp))
           {
            if(m_trade.ResultDeal()==0)
              {
               Print(__FUNCTION__,", #1 Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               PrintResult(m_trade,m_symbol);
              }
            else
              {
               Print(__FUNCTION__,", #2 Sell -> true. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               PrintResult(m_trade,m_symbol);
              }
           }
         else
           {
            Print(__FUNCTION__,", #3 Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
            PrintResult(m_trade,m_symbol);
           }
        }
      else
        {
         Print(__FUNCTION__,", ERROR: method CheckVolume (",DoubleToString(check_volume_lot,2),") ",
               "< Lots (",DoubleToString(InpLots,2),")");
         return;
        }
     }
   else
     {
      Print(__FUNCTION__,", ERROR: method CheckVolume returned the value of \"0.0\"");
      return;
     }
//---
  }
//+------------------------------------------------------------------+
//| Print CTrade result                                              |
//+------------------------------------------------------------------+
void PrintResult(CTrade &trade,CSymbolInfo &symbol)
  {
   Print("Code of request result: "+IntegerToString(trade.ResultRetcode()));
   Print("code of request result: "+trade.ResultRetcodeDescription());
   Print("deal ticket: "+IntegerToString(trade.ResultDeal()));
   Print("order ticket: "+IntegerToString(trade.ResultOrder()));
   Print("volume of deal or order: "+DoubleToString(trade.ResultVolume(),2));
   Print("price, confirmed by broker: "+DoubleToString(trade.ResultPrice(),symbol.Digits()));
   Print("current bid price: "+DoubleToString(trade.ResultBid(),symbol.Digits()));
   Print("current ask price: "+DoubleToString(trade.ResultAsk(),symbol.Digits()));
   Print("broker comment: "+trade.ResultComment());
   int d=0;
  }
//+------------------------------------------------------------------+
//| Trailing                                                         |
//+------------------------------------------------------------------+
void Trailing()
  {
   if(InpTrailingStop==0)
      return;
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               if(m_position.PriceCurrent()-m_position.PriceOpen()>ExtTrailingStop+ExtTrailingStep)
                  if(m_position.StopLoss()<m_position.PriceCurrent()-(ExtTrailingStop+ExtTrailingStep))
                    {
                     if(!m_trade.PositionModify(m_position.Ticket(),
                        m_symbol.NormalizePrice(m_position.PriceCurrent()-ExtTrailingStop),
                        m_position.TakeProfit()))
                        Print("Modify ",m_position.Ticket(),
                              " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                              ", description of result: ",m_trade.ResultRetcodeDescription());
                     continue;
                    }
              }
            else
              {
               if(m_position.PriceOpen()-m_position.PriceCurrent()>ExtTrailingStop+ExtTrailingStep)
                  if((m_position.StopLoss()>(m_position.PriceCurrent()+(ExtTrailingStop+ExtTrailingStep))) || 
                     (m_position.StopLoss()==0))
                    {
                     if(!m_trade.PositionModify(m_position.Ticket(),
                        m_symbol.NormalizePrice(m_position.PriceCurrent()+ExtTrailingStop),
                        m_position.TakeProfit()))
                        Print("Modify ",m_position.Ticket(),
                              " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                              ", description of result: ",m_trade.ResultRetcodeDescription());
                    }
              }

           }
  }
//+------------------------------------------------------------------+
