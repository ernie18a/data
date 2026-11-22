//+------------------------------------------------------------------+
//|                                               Straddle&Trail.mq5 |
//|                                         Copyright © 2006, Yannis |
//|                                                 jsfero@otenet.gr |
//+------------------------------------------------------------------+
//|                                       v2.40                      |
//+------------------------------------------------------------------+
// The ea can manage at the same time manually entered trades at any time (they have a magic number of 0)
// AND/OR a straddle (Long and Short pending positions - Stop orders) that is placed for a news event
// at a specific time of the day by this ea. 
//
// The manual trades are checked against Symbol() and MagicNumber=0 so if you have other experts running 
// on the same pair assuming they assign a magic number > 0 to the trades, you won't have any problems between 
// the manual trades and those from your expert. 
//
// The trades entered by the expert are checked against Symbol() Period() And an automatically given Magic Number
// so here also absolutely no problem if you have other experts running.
//
// The positions are tracked through the PosCounter() procedure
// which checks for :   count_buy_pos  / count_sell_pos    ==> Ticket # from Orders actually triggered BY THE EA, if any, otherwise = 0.
//                      count_buy_stop / count_sell_stop   ==> Ticket # from Pending Stop Orders NOT TRIGGERED (the straddle).
//                      count_buy_pos_manual / count_sell_pos_manual   ==> Ticket # from Orders entered Manually.
// The manually entered positions are tracked as far as SL, TP, BE and Trail are concerned, 
// and are totally unaffected by the straddle.
//
// The Stop Orders entered before the news release, either immediately if "Pre_Event_Entry_Minutes"=0 or
// xx minutes before the event and they are tracked and adjusted ONCE EVERY MINUTE, from the moment
// they are entered by the ea until a few minutes before the event (specified by "ExtStop_Adjusting_Min_Before_Event" parameter) 
// modifying their entry price, stop loss and take profit, according to current m_symbol.Bid() and m_symbol.Ask(), if "Adjust_Pending_Orders"=true.
// Once one of them is triggered, the opposite one is removed if "Remove_Opposite_Order" = true.
// 
// Another way of entering a straddle is by setting the "Place_Straddle_Immediately" to true. In that case,
// The time event settings will be ignored and the long and short pending orders that will be entered immediately
// will not be adjusted according to price like they are when this parameter is set to false and we use the ea for
// news release. This is to be used as a narrow range, low volume breakout strategy like for instance during a ranging 
// Asian period.
//
// The "ShutDown_NOW" parameter will shut down all the trades specified by "ShutDown_What" parameter.
// On the ea's input tab you can see the possible values but here they are again as a reference.
// ShutDown_What ==>    0=Everything, 1=All Triggered Positions,  2=Triggered Long
//                      3=Triggered Short, 4=All Pending Positions, 5=Pending Long, 6=Pending Short
// If "ShutDown_Current_Pair_Only" then the ea will close all trades for the pair on which this parameter was set to true
// otherwise it will close ALL the trades on ALL the pairs. 
//
// The ea will check the minimum distance allowed from the broker 
// against the trail, stop loss and take profit values specified by the user
// in the expert parameters tab. If these values are below the allowed distance
// they will be automatically adjusted to that minimum value
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
#include <Trade\DealInfo.mqh>
#include <Trade\OrderInfo.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CAccountInfo   m_account;                    // account info wrapper
CDealInfo      m_deal;                       // deals object
COrderInfo     m_order;                      // pending orders object
//---
input bool    ShutDown_NOW=false;                 // If true ALL POSITIONS (open and/or pending) will be closed/deleted
                                                  // based on "ShutDown_What" flag below
// This parameter is the first on the list so the user can access it
// as quickly as possible.
input string  sStr00=" 0=Everything               ";
input string  sStr01=" 1=All Triggered Positions  ";
input string  sStr02=" 2=Triggered Long           ";
input string  sStr03=" 3=Triggered Short          ";
input string  sStr04=" 4=All Pending Positions    ";
input string  sStr05=" 5=Pending Long             ";
input string  sStr06=" 6=Pending Short            ";
input int     ShutDown_What=-1;                   // "-1" - ALL,"0" - POSITION_TYPE_BUY, "1" - POSITION_TYPE_SELL, "4" - ORDER_TYPE_BUY_STOP, "5" - ORDER_TYPE_SELL_STOP
input bool    ShutDown_Current_Pair_Only=true;    // If true, ALL trades for CURRENT pair will be shutdown (no matter what time frame)
                                                  // If false, ALL trades on ALL pairs will be shutdown
input string  sStr1="=== POSITION DETAILS ===";
input double  Lots=1;
input int     Slippage=10;
input ushort  InpDistance_From_Price=30;             // Initial distance from price for the 2 pending orders
input ushort  InpStopLoss_Pips=30;                // Initial stop loss
input ushort  InpTakeProfit_Pips=60;              // Initial take profit
input ushort  InpTrail_Pips=15;                   // Trail
input bool    Trail_Starts_After_BreakEven=true;  // if true trailing will start after a profit of "ExtMove_To_BreakEven_at_pips" is made
input int     Move_To_BreakEven_Lock_pips=1;      // Pips amount to lock once trade is in profit 
                                                  // by the number of pips specified with "ExtMove_To_BreakEven_at_pips"
// Unused if Trail_Starts_After_BreakEven=false
input ushort  InpMove_To_BreakEven_at_pips=5;     // trades in profit will move to entry price + Move_To_BreakEven_Lock_pips as soon as trade 
                                                  // is at entry price + ExtMove_To_BreakEven_at_pips

// i.e. Entry price on a long order is @ 1.2100
// when price reaches 1.2110 (Entry price + "ExtMove_To_BreakEven_at_pips")
// the ea will lock 1 pip moving sl 
// at 1.2101 (Entry price+ "Move_To_BreakEven_Lock_pips=1")
input string  sStr2="=== NEWS EVENT ===";
input int     Event_Start_Hour=12;                // Event start time = Hour.      Broker's time.
input int     Event_Start_Minutes=30;             // Event start time = Minutes.   Broker's time.
                                                  // IF YOU WANT TO DISABLE THE "NEWS" FEATURE (the straddle)
// SET BOTH PARAMETERS TO 0.
input int     Pre_Event_Entry_Minutes=30;         // Number of minutes before event where the ea will place the straddle.
                                                  // If set to 0, the ea will place the straddle immediately when activated,
// otherwise xx minutes specified here before above Event start time.
input int     InpStop_Adjusting_Min_Before_Event=2;  // Minutes before the event where the EA will stop adjusting
                                                     // the pending orders. The smallest value is 1 min.
input bool    Remove_Opposite_Order=true;         // if true, once the 1st of the 2 pending orders is triggered, 
                                                  // the opposite pending one is removed otherwise left as is.
input bool    Adjust_Pending_Orders=false;         // if true, once the pending orders are placed at
                                                  // "Pre_Event_Start_Minutes" minutes before the event's time, 
// the ea will try to adjust the orders ONCE EVERY MINUTE until
// "ExtStop_Adjusting_Min_Before_Event" minutes before the release where
// it will stay put. 
input bool    Place_Straddle_Immediately=false;   // if true, the straddle will be placed immediately once the 
                                                  // expert is activated. This overrides previous 'News Events' 
// settings for placing the long and short pending orders and 
// in that case, the positions WILL NOT BE ADJUSTED. 
// This is to be used as a "quiet" range breakout, for example if we 
// want to play a "regular" breakout during Asian Session for example
// or at any other time of the day where the market is rangebound
int iMinimum=0;
int count_buy_pos,count_sell_pos,count_buy_stop,count_sell_stop,count_buy_pos_manual,count_sell_pos_manual,OpenTrades;
int LastMin,OpenPositions,OpenLongM,OpenShortM,OpenLong,OpenShort,OpenLongP,OpenShortP;
string my_comment=" Straddle&Trail";
string ScreenComment="Straddle&Trail v2.40";
string NewsLabel="";
string sHour="";
string sMin="";
bool SupplyMagicNumber=true,IsOK=false;
int HourNow=0;
int MinutesNow=0;
//---
double  ExtDistance_From_Price=0.0;
double  ExtStopLoss_Pips=0.0;
double  ExtTakeProfit_Pips=0.0;
double  ExtTrail_Pips=0.0;
double  ExtMove_To_BreakEven_at_pips=0.0;
int     ExtStop_Adjusting_Min_Before_Event=0;
ulong   m_magic=0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//comments();

   if((Event_Start_Hour>=0) && (Event_Start_Hour<=9))
      sHour="0";
   else
      sHour="";

   if((Event_Start_Minutes>=0) && (Event_Start_Minutes<=9))
      sMin="0";
   else sMin="";

   if((Event_Start_Hour==0) && (Event_Start_Minutes==0))
      NewsLabel=ServerTime()+"  No News Event Scheduled";
   else
      NewsLabel=(ServerTime()+"    NEWS SCHEDULED FOR ("+
                 sHour+IntegerToString(Event_Start_Hour)+":"+
                 sMin+IntegerToString(Event_Start_Minutes)+")");

   ObjectDelete(0,"Yannis");
   YannisCustomText("Yannis",15,15,CORNER_LEFT_UPPER);
   ObjectSetString(0,"Yannis",OBJPROP_TEXT,"jsfero@otenet.gr");
   ObjectSetString(0,"Yannis",OBJPROP_FONT,"Times New Roman");
   ObjectSetInteger(0,"Yannis",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"Yannis",OBJPROP_COLOR,clrYellow);

   ObjectDelete(0,"Yannis2");
   YannisCustomText("Yannis2",15,15,CORNER_RIGHT_UPPER);
   ObjectSetString(0,"Yannis2",OBJPROP_TEXT,NewsLabel);
   ObjectSetString(0,"Yannis2",OBJPROP_FONT,"Tahoma");
   ObjectSetInteger(0,"Yannis2",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"Yannis2",OBJPROP_COLOR,clrLightSkyBlue);
//---
   m_symbol.Name(Symbol());                  // sets symbol name
   if(!RefreshRates())
     {
      Print("Error RefreshRates. m_symbol.Bid()=",DoubleToString(m_symbol.Bid(),Digits()),
            ", m_symbol.Ask()=",DoubleToString(m_symbol.Ask(),Digits()));
      return(INIT_FAILED);
     }
   m_symbol.Refresh();

   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;

   ExtDistance_From_Price             = InpDistance_From_Price       * digits_adjust;
   ExtStopLoss_Pips                   = InpStopLoss_Pips             * digits_adjust;
   ExtTakeProfit_Pips                 = InpTakeProfit_Pips           * digits_adjust;
   ExtTrail_Pips                      = InpTrail_Pips                * digits_adjust;
   ExtMove_To_BreakEven_at_pips       = InpMove_To_BreakEven_at_pips *digits_adjust;
   ExtStop_Adjusting_Min_Before_Event = InpStop_Adjusting_Min_Before_Event;
//---
   iMinimum=0;
   m_magic=0;
   HourNow=0;
   MinutesNow=0;
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectDelete(0,"Yannis");
   ObjectDelete(0,"Yannis2");
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   iMinimum=m_symbol.StopsLevel(); // check the minimum pip distance allowed from broker for sl and tp
   bool EventAboutToStart=IsItEventTime();
   if((Event_Start_Hour>=0) && (Event_Start_Hour<=9))
      sHour="0";
   else sHour="";

   if((Event_Start_Minutes>=0) && (Event_Start_Minutes<=9))
      sMin="0";
   else sMin="";

   if((Event_Start_Hour==0) && (Event_Start_Minutes==0))
      NewsLabel=ServerTime()+"  No News Event Scheduled";
   else
      NewsLabel=(ServerTime()+"    NEWS SCHEDULED FOR ("+
                 sHour+IntegerToString(Event_Start_Hour)+":"+
                 sMin+IntegerToString(Event_Start_Minutes)+")");

   m_magic=CalcMagic(Symbol(),Period());
   m_trade.SetExpertMagicNumber(m_magic);    // sets magic number

   if(ExtStopLoss_Pips<iMinimum)
      ExtStopLoss_Pips=iMinimum;

   if(ExtTakeProfit_Pips<iMinimum)
      ExtTakeProfit_Pips=iMinimum;

   if(ExtTrail_Pips<iMinimum)
      ExtTrail_Pips=iMinimum;

//--- check for open positions. Sets count_buy_pos, count_sell_pos, count_buy_stop, count_sell_stop, count_buy_pos_manual, count_sell_pos_manual
//--- count_buy_pos_manual / count_sell_pos_manual   = Ticket Number for Manual Trades 
//--- (count_buy_pos_manual=Long position count_sell_pos_manual=Short position, if any, otherwise = 0)
//--- count_buy_stop / count_sell_stop   = Ticket Number for Pending Trades (Straddle) from EA 
//--- count_buy_pos  / count_sell_pos    = Ticket Number for Triggered Trades (Straddle) from EA
   PosCounter(); /// а нужно ли это???

   if((ShutDown_NOW) && (OpenTrades>0))
     {
      ShutDownAllTrades(ShutDown_What);
      return;
     }
//--- If a position is entered without initial SL / TP then place the initial stops
//--- If no open or pending positions, AND the event start hour and minute is not 0, place the 2 pending orders
//--- If Pre_Event_Entry_Minutes=0 (immediately) or
//--- else Pre event minutes before event time    
   CheckInitialSLTP();

   if((IsTimeToPlaceEntries()) || (Place_Straddle_Immediately))
     {
      if((count_sell_stop==0) && (count_buy_stop==0) && (count_sell_pos==0) && (count_buy_pos==0))
         PlaceTheStraddle();
     }
//---
   PosCounter();
//--- If both pending orders are placed and no trades actually opened 
//--- and we are not into the specified minutes before the event, then we adjust our positions
//--- according to current price automatically every new minute
   if((!EventAboutToStart) && (count_sell_stop>0) && 
      (count_buy_stop>0) && (count_sell_pos==0) && 
      (count_buy_pos==0) && (MinutesNow!=LastMin) && 
      (Adjust_Pending_Orders) && (!Place_Straddle_Immediately))
      AdjustPendingOrders();
//--- If parameter "Remove_Opposite_Order" is set to true, remove non triggered opposite pending order
   PosCounter();
   if(Remove_Opposite_Order)
      if(((count_sell_pos>0) && (count_buy_stop>0)) || ((count_buy_pos>0) && (count_sell_stop>0)))
         RemoveOppositePending();
//--- If a position is triggered, either manual or from ea, trail it.
   PosCounter();
   if((count_sell_pos>0) || (count_buy_pos>0) || (count_buy_pos_manual>0) || (count_sell_pos_manual>0))
     {
      if(ExtMove_To_BreakEven_at_pips!=0)
         MoveToBreakEven(); // Check if must secure position
      Trail_Stop(); // Check trailing methods
     }
//comments();
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsTimeToPlaceEntries()
  {
   return(((Pre_Event_Entry_Minutes==0) ||((HourNow==Event_Start_Hour)&&
          (MinutesNow>=(Event_Start_Minutes-Pre_Event_Entry_Minutes)) &&
          (MinutesNow<=Event_Start_Minutes))) && (Event_Start_Hour>0) &&
          (Event_Start_Minutes>0));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsItEventTime()
  {
   MqlDateTime str1;
   TimeToStruct(TimeCurrent(),str1);

   HourNow=str1.hour;
   MinutesNow=str1.min;
//---
   if((HourNow<Event_Start_Hour) || (HourNow>Event_Start_Hour))
      return(false);

   if((HourNow==Event_Start_Hour) && (MinutesNow>Event_Start_Minutes))
      return(false);

//--- Will return 0 if the event is not started or is over.
   if(ExtStop_Adjusting_Min_Before_Event<1)
      ExtStop_Adjusting_Min_Before_Event=1;

   if(ExtStop_Adjusting_Min_Before_Event>PeriodSeconds()/60)
      ExtStop_Adjusting_Min_Before_Event=PeriodSeconds()/60;
//----
   return((HourNow==Event_Start_Hour)                                          &&
          (MinutesNow>=(Event_Start_Minutes-ExtStop_Adjusting_Min_Before_Event))  &&
          (MinutesNow<=Event_Start_Minutes)
          );
// Will return 0 hence allowing the ea to adjust its pending orders until minutes reaches 
// range between (Event_Start_Minutes-ExtStop_Adjusting_Min_Before_Event) and Event_Start_Minutes range where the ea will return 1.
// For example if the event is scheduled for 12.40, and we have set the 
// ExtStop_Adjusting_Min_Before_Event parameter to 2, then until 12.27:59 the ea will adjust the pending orders.
// From 12.28 and after it will stop adjusting and stay put.
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PlaceTheStraddle()
  {
   if(!IsTradeAllowed())
      return;

   double ShortEntryLevel=0.0,LongEntryLevel=0.0,TP=0.0,SL=0.0;
//---
   if(ExtStopLoss_Pips==0)
      ExtStopLoss_Pips=999;

   if(ExtTakeProfit_Pips==0)
      ExtTakeProfit_Pips=999;

   if(!RefreshRates())
      return;

   ShortEntryLevel=NormalizeDouble(m_symbol.Bid()-(ExtDistance_From_Price*Point()),Digits());
   SL             =NormalizeDouble(ShortEntryLevel+(ExtStopLoss_Pips*Point()),Digits());
   TP             =NormalizeDouble(ShortEntryLevel-(ExtTakeProfit_Pips*Point()),Digits());
   if(!m_trade.SellStop(Lots,ShortEntryLevel,Symbol(),SL,TP,0,0,"Straddle&Trail "+EnumToString(Period())+"min "))
     {
      Print("Error opening SellStop. Result Retcode: ",m_trade.ResultRetcode(),
            ", description of Retcode: ",m_trade.ResultRetcodeDescription(),
            ", m_symbol.Ask()=",DoubleToString(m_symbol.Ask(),Digits()),
            ", m_symbol.Bid()=",DoubleToString(m_symbol.Bid(),Digits()),
            ", Entry @ ",DoubleToString(ShortEntryLevel,Digits()),
            ", SL=",DoubleToString(SL,Digits()),
            ", TP=",DoubleToString(TP,Digits()));
     }

   LongEntryLevel =NormalizeDouble(m_symbol.Ask()+(ExtDistance_From_Price*Point()),Digits());
   SL             =NormalizeDouble(LongEntryLevel-(ExtStopLoss_Pips*Point()),Digits());
   TP             =NormalizeDouble(LongEntryLevel+(ExtTakeProfit_Pips*Point()),Digits());
   if(!m_trade.BuyStop(Lots,LongEntryLevel,Symbol(),SL,TP,0,0,"Straddle&Trail "+EnumToString(Period())+"min "))
     {
      Print("Error opening BuyStop. Result Retcode: ",m_trade.ResultRetcode(),
            ", description of Retcode: ",m_trade.ResultRetcodeDescription(),
            ", m_symbol.Ask()=",DoubleToString(m_symbol.Ask(),Digits()),
            ", m_symbol.Bid()=",DoubleToString(m_symbol.Bid(),Digits()),
            ", Entry @ ",DoubleToString(LongEntryLevel,Digits()),
            ", SL=",DoubleToString(SL,Digits()),
            ", TP=",DoubleToString(TP,Digits()));
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void RemoveOppositePending()
  {
   if(!IsTradeAllowed())
      return;

   for(int i=OrdersTotal()-1;i>=0;i--)
      if(m_order.SelectByIndex(i))
         if(m_order.Magic()==m_magic || m_order.Magic()==0)
            if((ShutDown_Current_Pair_Only && m_order.Symbol()==Symbol()) || !ShutDown_Current_Pair_Only)
              {
               if(m_order.OrderType()==ORDER_TYPE_BUY_STOP)
                  m_trade.OrderDelete(m_order.Ticket());

               if(m_order.OrderType()==ORDER_TYPE_SELL_STOP)
                  m_trade.OrderDelete(m_order.Ticket());
              }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AdjustPendingOrders()
  {
   IsOK=false;
//--- Adjust pending Long order
   if(!IsTradeAllowed())
      return;

   if(!RefreshRates())
      return;

   for(int i=OrdersTotal()-1;i>=0;i--)
      if(m_order.SelectByIndex(i))
         if(m_order.Magic()==m_magic || m_order.Magic()==0)
            if((ShutDown_Current_Pair_Only && m_order.Symbol()==Symbol()) || !ShutDown_Current_Pair_Only)
              {
               if(m_order.OrderType()==ORDER_TYPE_BUY_STOP)
                 {
                  double  LongEntryLevel =NormalizeDouble(m_symbol.Ask()+(ExtDistance_From_Price*Point()),Digits());
                  double  SL             =NormalizeDouble(LongEntryLevel-(ExtStopLoss_Pips*Point()),Digits());
                  double  TP             =NormalizeDouble(LongEntryLevel+(ExtTakeProfit_Pips*Point()),Digits());
                  if(!m_trade.OrderModify(m_order.Ticket(),LongEntryLevel,SL,TP,m_order.TypeTime(),m_order.TimeExpiration()))
                     Print("Error Adjusting Long Pending Order ticket=",m_order.Ticket(),
                           ", Result Retcode: ",m_trade.ResultRetcode(),
                           ", description of Retcode: ",m_trade.ResultRetcodeDescription());
                 }

               if(m_order.OrderType()==ORDER_TYPE_SELL_STOP)
                 {
                  double        ShortEntryLevel=NormalizeDouble(m_symbol.Bid()-(ExtDistance_From_Price*Point()),Digits());
                  double   SL             =NormalizeDouble(ShortEntryLevel+(ExtStopLoss_Pips*Point()),Digits());
                  double   TP             =NormalizeDouble(ShortEntryLevel-(ExtTakeProfit_Pips*Point()),Digits());
                  if(!m_trade.OrderModify(m_order.Ticket(),ShortEntryLevel,SL,TP,m_order.TypeTime(),m_order.TimeExpiration()))
                     Print("Error Adjusting Short Pending Order ticket=",m_order.Ticket(),
                           ", Result Retcode: ",m_trade.ResultRetcode(),
                           ", description of Retcode: ",m_trade.ResultRetcodeDescription());
                 }
              }
   LastMin=MinutesNow; // Resetting the "counter" to current minute so the ea adjusts only every 1 minute
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PosCounter()
  {
   count_buy_pos=0;
   count_sell_pos=0;
   count_buy_pos_manual=0;
   count_sell_pos_manual=0;
   count_buy_stop=0;
   count_sell_stop=0;
   OpenTrades=0;

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==Symbol())
           {
            if(m_position.Magic()==m_magic)
              {
               if(m_position.PositionType()==POSITION_TYPE_BUY)
                  count_buy_pos++;

               if(m_position.PositionType()==POSITION_TYPE_SELL)
                  count_sell_pos++;
              }
            else if(m_position.Magic()==0)
              {
               if(m_position.PositionType()==POSITION_TYPE_BUY)
                  count_buy_pos_manual++;

               if(m_position.PositionType()==POSITION_TYPE_SELL)
                  count_sell_pos_manual++;
              }
           }

   for(int i=OrdersTotal()-1;i>=0;i--)
      if(m_order.SelectByIndex(i))
         if(m_order.Symbol()==Symbol() && m_order.Magic()==m_magic)
           {
            if(m_order.OrderType()==ORDER_TYPE_BUY_STOP)
               count_buy_stop++;

            if(m_order.OrderType()==ORDER_TYPE_SELL_STOP)
               count_sell_stop++;
           }

   OpenTrades=count_buy_pos+count_sell_pos+
              count_buy_pos_manual+count_sell_pos_manual+
              count_buy_stop+count_sell_stop;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Trail_With_Standard_Trailing(int AfterBE)
  {
//PosCounter();
//RefreshRates();
   if(!IsTradeAllowed())
      return;

   if(!RefreshRates())
      return;

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i))
         if(m_position.Magic()==m_magic || m_position.Magic()==0)
            if((ShutDown_Current_Pair_Only && m_position.Symbol()==Symbol()) || !ShutDown_Current_Pair_Only)
              {
               if(AfterBE==0)
                 {
                  if(m_position.PositionType()==POSITION_TYPE_BUY)
                    {
                     double bsl=ExtTrail_Pips*Point();
                     if(m_symbol.Bid()>(m_position.PriceOpen()+bsl) && m_position.StopLoss()<(m_position.PriceOpen()+(m_symbol.Bid()-(m_position.PriceOpen()+bsl))))
                       {
                        double b_tsl=NormalizeDouble(m_position.PriceOpen()+(m_symbol.Bid()-(m_position.PriceOpen()+bsl)),Digits());
                        Print("b_tsl ",b_tsl);
                        if(m_position.StopLoss()<b_tsl)
                           m_trade.PositionModify(m_position.Ticket(),b_tsl,m_position.TakeProfit());
                       }
                    }
                  if(m_position.PositionType()==POSITION_TYPE_SELL)
                    {
                     double ssl=ExtTrail_Pips*Point();
                     if(m_symbol.Ask()<(m_position.PriceOpen()-ssl) && m_position.StopLoss()>(m_position.PriceOpen()-(m_position.PriceOpen()-ssl)-m_symbol.Ask()))
                       {
                        double  s_tsl=NormalizeDouble(m_position.PriceOpen()-((m_position.PriceOpen()-ssl)-m_symbol.Ask()),Digits());
                        Print("s_tsl ",s_tsl);
                        if(m_position.StopLoss()>s_tsl)
                           m_trade.PositionModify(m_position.Ticket(),s_tsl,m_position.TakeProfit());
                       }
                    }
                 }
               else // If Trail_Starts_After_BreakEven
                 {
                  if(m_position.PositionType()==POSITION_TYPE_BUY)
                    {
                     if(m_symbol.Bid()>=(m_position.PriceOpen()+(ExtMove_To_BreakEven_at_pips*Point())))
                       {
                        double bsl=ExtTrail_Pips*Point();
                        if(m_symbol.Bid()>(m_position.PriceOpen()+bsl) && m_position.StopLoss()<(m_position.PriceOpen()+(m_symbol.Bid()-(m_position.PriceOpen()+bsl))))
                          {
                           double b_tsl=NormalizeDouble(m_position.PriceOpen()+(m_symbol.Bid()-(m_position.PriceOpen()+bsl)),Digits());
                           Print("b_tsl ",b_tsl);
                           if(m_position.StopLoss()<b_tsl)
                              m_trade.PositionModify(m_position.Ticket(),b_tsl,m_position.TakeProfit());
                          }
                       }
                    }
                  if(m_position.PositionType()==POSITION_TYPE_SELL)
                    {
                     if(m_symbol.Ask()<=(m_position.PriceOpen()-(ExtMove_To_BreakEven_at_pips*Point())))
                       {
                        double ssl=ExtTrail_Pips*Point();
                        //determine if stoploss should be modified
                        if(m_symbol.Ask()<(m_position.PriceOpen()-ssl) && m_position.StopLoss()>(m_position.PriceOpen()-(m_position.PriceOpen()-ssl)-m_symbol.Ask()))
                          {
                           double   s_tsl=NormalizeDouble(m_position.PriceOpen()-((m_position.PriceOpen()-ssl)-m_symbol.Ask()),Digits());
                           Print("s_tsl ",s_tsl);
                           if(m_position.StopLoss()>s_tsl)
                              m_trade.PositionModify(m_position.Ticket(),s_tsl,m_position.TakeProfit());
                          }
                       }
                    }
                 }
              }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Trail_Stop()
  {
   if(Trail_Starts_After_BreakEven)
      Trail_With_Standard_Trailing(1);
   else
      Trail_With_Standard_Trailing(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MoveToBreakEven()
  {
//PosCounter();
//RefreshRates();
   if(!IsTradeAllowed())
      return;

   if(!RefreshRates())
      return;

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i))
         if(m_position.Magic()==m_magic || m_position.Magic()==0)
            if((ShutDown_Current_Pair_Only && m_position.Symbol()==Symbol()) || !ShutDown_Current_Pair_Only)
              {
               if(m_position.PositionType()==POSITION_TYPE_BUY)
                  if(m_position.StopLoss()<m_position.PriceOpen())
                     if(m_symbol.Bid()>((ExtMove_To_BreakEven_at_pips*Point())+m_position.PriceOpen()))
                       {
                        double SL=m_position.PriceOpen()+Move_To_BreakEven_Lock_pips*Point();
                        if(m_trade.PositionModify(m_position.Ticket(),SL,m_position.TakeProfit()))
                           Print("Long StopLoss Moved to BE at : ",DoubleToString(SL,Digits()));
                        else
                           Print("Error moving Long StopLoss to BE: ",m_trade.ResultRetcodeDescription());
                       }
               if(m_position.PositionType()==POSITION_TYPE_SELL)
                  if(m_position.StopLoss()>m_position.PriceOpen())
                     if(m_symbol.Ask()<(m_position.PriceOpen()-(ExtMove_To_BreakEven_at_pips*Point())))
                       {
                        double SL=m_position.PriceOpen()-(Move_To_BreakEven_Lock_pips*Point());
                        if(m_trade.PositionModify(m_position.Ticket(),SL,m_position.TakeProfit()))
                           Print("Short StopLoss Moved to BE at : ",DoubleToString(SL,Digits()));
                        else
                           Print("Error moving Short StopLoss to BE: ",m_trade.ResultRetcodeDescription());
                       }
              }
  }
//+------------------------------------------------------------------+
//| Attention! For All MagicNumber!                                  |
//+------------------------------------------------------------------+
void CheckInitialSLTP()
  {
   if(!IsTradeAllowed())
      return;

   double sl=0.0,tp=0.0;

   if(count_buy_pos>0 || count_sell_pos>0 || count_buy_pos_manual==0 || count_sell_pos_manual==0)
      for(int i=PositionsTotal()-1;i>=0;i--)
         if(m_position.SelectByIndex(i))
            if(m_position.Magic()==m_magic || m_position.Magic()==0)
               if((ShutDown_Current_Pair_Only && m_position.Symbol()==Symbol()) || !ShutDown_Current_Pair_Only)
                  if(m_position.StopLoss()==0.0 || m_position.TakeProfit()==0.0)
                    {
                     if(m_position.PositionType()==POSITION_TYPE_BUY)
                       {
                        if(m_position.StopLoss()==0.0)
                           sl=m_position.PriceOpen()-ExtStopLoss_Pips*Point();
                        else
                           sl=m_position.StopLoss();

                        if(m_position.TakeProfit()==0)
                           tp=m_position.PriceOpen()+ExtTakeProfit_Pips;
                        else
                           tp=m_position.TakeProfit();

                        if(m_trade.PositionModify(m_position.Ticket(),sl,tp))
                           Print("Initial SL or TP is Set for Long Entry");
                        else
                           Print("Error setting initial SL or TP for Long Entry");
                       }

                     if(m_position.PositionType()==POSITION_TYPE_SELL)
                       {
                        if(m_position.StopLoss()==0.0)
                           sl=m_position.PriceOpen()+ExtStopLoss_Pips*Point();
                        else
                           sl=m_position.StopLoss();

                        if(m_position.TakeProfit()==0)
                           tp=m_position.PriceOpen()-ExtTakeProfit_Pips;
                        else
                           tp=m_position.TakeProfit();

                        if(m_trade.PositionModify(m_position.Ticket(),sl,tp))
                           Print("Initial SL or TP is Set for Short Entry");
                        else
                           Print("Error setting initial SL or TP for Short Entry");
                       }
                    }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ShutDownAllTrades(int aiWhat)
  {
   if(!IsTradeAllowed())
      return;

//--- "-1" - ALL,"0" - POSITION_TYPE_BUY, "1" - POSITION_TYPE_SELL, "4" - ORDER_TYPE_BUY_STOP, "5" - ORDER_TYPE_SELL_STOP

   if(aiWhat==-1 || aiWhat==0 || aiWhat==1)
      for(int i=PositionsTotal()-1;i>=0;i--)
         if(m_position.SelectByIndex(i))
            if(m_position.Magic()==m_magic || m_position.Magic()==0)
               if((ShutDown_Current_Pair_Only && m_position.Symbol()==Symbol()) || !ShutDown_Current_Pair_Only)
                 {
                  if(m_position.PositionType()==POSITION_TYPE_BUY && (aiWhat==-1 || aiWhat==0))
                     m_trade.PositionClose(m_position.Ticket());

                  if(m_position.PositionType()==POSITION_TYPE_SELL && (aiWhat==-1 || aiWhat==1))
                     m_trade.PositionClose(m_position.Ticket());
                 }

   if(aiWhat==-1 || aiWhat==4 || aiWhat==5)
      for(int i=OrdersTotal()-1;i>=0;i--)
         if(m_order.SelectByIndex(i))
            if(m_order.Magic()==m_magic || m_order.Magic()==0)
               if((ShutDown_Current_Pair_Only && m_order.Symbol()==Symbol()) || !ShutDown_Current_Pair_Only)
                 {
                  if(m_order.OrderType()==ORDER_TYPE_BUY_STOP && (aiWhat==-1 || aiWhat==4))
                     m_trade.OrderDelete(m_order.Ticket());

                  if(m_order.OrderType()==ORDER_TYPE_SELL_STOP && (aiWhat==-1 || aiWhat==5))
                     m_trade.OrderDelete(m_order.Ticket());
                 }
  }
////+------------------------------------------------------------------+
////|                                                                  |
////+------------------------------------------------------------------+
//void comments()
//  {
//   string s0="",s1="",s2="",s3="",swap="",sCombo="",sStr;
//   int PipsProfit=0;
//   double AmountProfit=0.0;
//
//   ObjectSetText("Yannis","jsfero@otenet.gr",10,"Times New Roman",Yellow);
//   ObjectSetText("Yannis2",NewsLabel,10,"Tahoma",LightSkyBlue);
//   PosCounter();
//   RefreshRates();
//   if(count_buy_pos>0)
//     {
//      OrderSelect(count_buy_pos,SELECT_BY_TICKET);
//      PipsProfit=NormalizeDouble(((m_symbol.Bid()-OrderOpenPrice())/Point()),Digits());
//      AmountProfit=OrderProfit();
//     }
//   else if(count_sell_pos>0)
//     {
//      OrderSelect(count_sell_pos,SELECT_BY_TICKET);
//      PipsProfit=NormalizeDouble(((OrderOpenPrice()-m_symbol.Ask())/Point()),Digits());
//      AmountProfit=OrderProfit();
//     }
//   else if(count_buy_pos_manual>0)
//     {
//      OrderSelect(count_buy_pos_manual,SELECT_BY_TICKET);
//      PipsProfit=NormalizeDouble(((m_symbol.Bid()-OrderOpenPrice())/Point()),Digits());
//      AmountProfit=OrderProfit();
//     }
//   else if(count_sell_pos_manual>0)
//     {
//      OrderSelect(count_sell_pos_manual,SELECT_BY_TICKET);
//      PipsProfit=NormalizeDouble(((OrderOpenPrice()-m_symbol.Ask())/Point()),Digits());
//      AmountProfit=OrderProfit();
//     }
//   if(ExtMove_To_BreakEven_at_pips>0)
//      s1="S/L will move to B/E after: "+ExtMove_To_BreakEven_at_pips+
//         " pips   and lock: "+Move_To_BreakEven_Lock_pips+" pips"+"\n\n";
//   else
//      s1="";
//
//   if((!Place_Straddle_Immediately) && (Event_Start_Hour!=0) && (Event_Start_Minutes!=0))
//     {
//      if(Adjust_Pending_Orders)
//         s2=StringConcatenate("A straddle will be placed ",DoubleToStr(Pre_Event_Entry_Minutes,0),
//                              " Minutes before news \nat ",DoubleToStr(ExtDistance_From_Price,0),
//                              " pips above and below price \nAdjusting every minute until ",
//                              DoubleToStr(ExtStop_Adjusting_Min_Before_Event,0),
//                              " minutes before event time");
//     }
//   else
//      s2="";
////----
//   Comment("\n",ScreenComment,"\n\n",
//           "SL: ",ExtStopLoss_Pips,"  TP:",ExtTakeProfit_Pips,"  Trail:",ExtTrail_Pips,"\n",
//           s1,"\n",
//           "Minimum allowed for SL & TP is ",iMinimum," pips\n\n",
//           s2
//           );
//  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string ServerTime()
  {
   MqlDateTime str1;
   datetime time=0;

   string strHourPad="",strMinutePad="";
   time=iTime(0,NULL,PERIOD_M1);
   TimeToStruct(time,str1);

   if(str1.hour>=0 && str1.hour<=9)
      strHourPad="0";
   else
      strHourPad="";

   if(str1.min>=0 && str1.min<=9)
      strMinutePad="0";
   else
      strMinutePad="";

   return("Broker\'s Current Time is ("+strHourPad+str1.hour+":"+strMinutePad+str1.min+")");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ulong CalcMagic(string CurrPair,int CurrPeriod)
  {
   if(CurrPair=="EURUSD" || CurrPair=="EURUSDm") {return(1000+CurrPeriod);}
   else if(CurrPair=="GBPUSD" || CurrPair=="GBPUSDm") {return(2000+CurrPeriod);}
   else if(CurrPair=="USDCHF" || CurrPair=="USDCHFm") {return(3000+CurrPeriod);}
   else if(CurrPair=="USDJPY" || CurrPair=="USDJPYm") {return(4000+CurrPeriod);}
   else if(CurrPair=="EURJPY" || CurrPair=="EURJPYm") {return(5000+CurrPeriod);}
   else if(CurrPair=="EURCHF" || CurrPair=="EURCHFm") {return(6000+CurrPeriod);}
   else if(CurrPair=="EURGBP" || CurrPair=="EURGBPm") {return(7000+CurrPeriod);}
   else if(CurrPair=="USDCAD" || CurrPair=="USDCADm") {return(8000+CurrPeriod);}
   else if(CurrPair=="AUDUSD" || CurrPair=="AUDUSDm") {return(9000+CurrPeriod);}
   else if(CurrPair=="GBPCHF" || CurrPair=="GBPCHFm") {return(10000+CurrPeriod);}
   else if(CurrPair=="GBPJPY" || CurrPair=="GBPJPYm") {return(11000+CurrPeriod);}
   else if(CurrPair=="CHFJPY" || CurrPair=="CHFJPYm") {return(12000+CurrPeriod);}
   else if(CurrPair=="NZDUSD" || CurrPair=="NZDUSDm") {return(13000+CurrPeriod);}
   else if(CurrPair=="EURCAD" || CurrPair=="EURCADm") {return(14000+CurrPeriod);}
   else if(CurrPair=="AUDJPY" || CurrPair=="AUDJPYm") {return(15000+CurrPeriod);}
   else if(CurrPair=="EURAUD" || CurrPair=="EURAUDm") {return(16000+CurrPeriod);}
   else if(CurrPair=="AUDCAD" || CurrPair=="AUDCADm") {return(17000+CurrPeriod);}
   else if(CurrPair=="AUDNZD" || CurrPair=="AUDNZDm") {return(18000+CurrPeriod);}
   else if(CurrPair=="NZDJPY" || CurrPair=="NZDJPYm") {return(19000+CurrPeriod);}
   else if(CurrPair=="CADJPY" || CurrPair=="CADJPYm") {return(20000+CurrPeriod);}
   else if(CurrPair=="XAUUSD" || CurrPair=="XAUUSDm") {return(21000+CurrPeriod);}
   else if(CurrPair=="XAGUSD" || CurrPair=="XAGUSDm") {return(22000+CurrPeriod);}
   else if(CurrPair=="GBPAUD" || CurrPair=="GBPAUDm") {return(23000+CurrPeriod);}
   else if(CurrPair=="GBPCAD" || CurrPair=="GBPCADm") {return(24000+CurrPeriod);}
   else if(CurrPair=="AUFCHF" || CurrPair=="AUFCHFm") {return(25000+CurrPeriod);}
   else if(CurrPair=="CADCHF" || CurrPair=="CADCHFm") {return(26000+CurrPeriod);}
   else if(CurrPair=="NZDCHF" || CurrPair=="NZDCHFm") {return(27000+CurrPeriod);}

   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void YannisCustomText(string name_obj,int xOffset,int yOffset,ENUM_BASE_CORNER iCorner=CORNER_LEFT_UPPER)
  {
   ObjectCreate(0,name_obj,OBJ_LABEL,0,0,0);
//--- установим координаты метки
   ObjectSetInteger(0,name_obj,OBJPROP_XDISTANCE,xOffset);
   ObjectSetInteger(0,name_obj,OBJPROP_YDISTANCE,yOffset);
//--- установим угол графика, относительно которого будут определяться координаты точки
   ObjectSetInteger(0,name_obj,OBJPROP_CORNER,iCorner);
//--- отобразим на переднем (false) или заднем (true) плане
   ObjectSetInteger(0,name_obj,OBJPROP_BACK,true);
  }
//+------------------------------------------------------------------+
//| Refreshes the symbol quotes data                                 |
//+------------------------------------------------------------------+
bool RefreshRates()
  {
//--- refresh rates
   if(!m_symbol.RefreshRates())
      return(false);
//--- protection against the return value of "zero"
   if(m_symbol.Ask()==0 || m_symbol.Bid()==0)
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Get Time for specified bar index                                 | 
//+------------------------------------------------------------------+ 
datetime iTime(const int index,string symbol=NULL,ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT)
  {
   if(symbol==NULL)
      symbol=Symbol();
   if(timeframe==0)
      timeframe=Period();
   datetime Time[1];
   datetime time=0;
   int copied=CopyTime(symbol,timeframe,index,1,Time);
   if(copied>0) time=Time[0];
   return(time);
  }
//+------------------------------------------------------------------+
//| Gets the information about permission to trade                   |
//+------------------------------------------------------------------+
bool IsTradeAllowed()
  {
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
     {
      Alert("Check if automated trading is allowed in the terminal settings!");
      return(false);
     }
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
     {
      Alert("Check if automated trading is allowed in the terminal settings!");
      return(false);
     }
   else
     {
      if(!MQLInfoInteger(MQL_TRADE_ALLOWED))
        {
         Alert("Automated trading is forbidden in the program settings for ",__FILE__);
         return(false);
        }
     }
   if(!AccountInfoInteger(ACCOUNT_TRADE_EXPERT))
     {
      Alert("Automated trading is forbidden for the account ",AccountInfoInteger(ACCOUNT_LOGIN),
            " at the trade server side");
      return(false);
     }
   if(!AccountInfoInteger(ACCOUNT_TRADE_ALLOWED))
     {
      Comment("Trading is forbidden for the account ",AccountInfoInteger(ACCOUNT_LOGIN),
              ".\n Perhaps an investor password has been used to connect to the trading account.",
              "\n Check the terminal journal for the following entry:",
              "\n\'",AccountInfoInteger(ACCOUNT_LOGIN),"\': trading has been disabled - investor mode.");
      return(false);
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
