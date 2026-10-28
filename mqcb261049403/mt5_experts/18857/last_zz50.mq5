//+------------------------------------------------------------------+
//|                                                    Last ZZ50.mq5 |
//|                              Copyright © 2017, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2017, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.011"
#property description "Strategy based on the indicator \"ZigZag\""
#property description "Pending orders at level 1/2 of the last ray and at level 1/2 of the penultimate ray"
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\OrderInfo.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
COrderInfo     m_order;                      // pending orders object
//+------------------------------------------------------------------+
//| Enum days                                                        |
//+------------------------------------------------------------------+
enum ENUM_DAYS
  {
   day_01   =1,   // Monday
   day_02   =2,   // Tuesday
   day_03   =3,   // Wednesday
   day_04   =4,   // Thursday
   day_05   =5,   // Friday
  };
//+------------------------------------------------------------------+
//| Enum hours                                                       |
//+------------------------------------------------------------------+
enum ENUM_HOURS
  {
   hour_00  =0,   // 00
   hour_01  =1,   // 01
   hour_02  =2,   // 02
   hour_03  =3,   // 03
   hour_04  =4,   // 04
   hour_05  =5,   // 05
   hour_06  =6,   // 06
   hour_07  =7,   // 07
   hour_08  =8,   // 08
   hour_09  =9,   // 09
   hour_10  =10,  // 10
   hour_11  =11,  // 11
   hour_12  =12,  // 12
   hour_13  =13,  // 13
   hour_14  =14,  // 14
   hour_15  =15,  // 15
   hour_16  =16,  // 16
   hour_17  =17,  // 17
   hour_18  =18,  // 18
   hour_19  =19,  // 19
   hour_20  =20,  // 20
   hour_21  =21,  // 21
   hour_22  =22,  // 22
   hour_23  =23,  // 23
  };
//+------------------------------------------------------------------+
//| ENUM MINUTES                                                     |
//+------------------------------------------------------------------+
enum ENUM_MINUTES
  {
   minute_0 = 0 ,  // 0
   minute_1 = 1 ,  // 1
   minute_2 = 2 ,  // 2
   minute_3 = 3 ,  // 3
   minute_4 = 4 ,  // 4
   minute_5 = 5 ,  // 5
   minute_6 = 6 ,  // 6
   minute_7 = 7 ,  // 7
   minute_8 = 8 ,  // 8
   minute_9 = 9 ,  // 9
   minute_10 = 10 ,  // 10
   minute_11 = 11 ,  // 11
   minute_12 = 12 ,  // 12
   minute_13 = 13 ,  // 13
   minute_14 = 14 ,  // 14
   minute_15 = 15 ,  // 15
   minute_16 = 16 ,  // 16
   minute_17 = 17 ,  // 17
   minute_18 = 18 ,  // 18
   minute_19 = 19 ,  // 19
   minute_20 = 20 ,  // 20
   minute_21 = 21 ,  // 21
   minute_22 = 22 ,  // 22
   minute_23 = 23 ,  // 23
   minute_24 = 24 ,  // 24
   minute_25 = 25 ,  // 25
   minute_26 = 26 ,  // 26
   minute_27 = 27 ,  // 27
   minute_28 = 28 ,  // 28
   minute_29 = 29 ,  // 29
   minute_30 = 30 ,  // 30
   minute_31 = 31 ,  // 31
   minute_32 = 32 ,  // 32
   minute_33 = 33 ,  // 33
   minute_34 = 34 ,  // 34
   minute_35 = 35 ,  // 35
   minute_36 = 36 ,  // 36
   minute_37 = 37 ,  // 37
   minute_38 = 38 ,  // 38
   minute_39 = 39 ,  // 39
   minute_40 = 40 ,  // 40
   minute_41 = 41 ,  // 41
   minute_42 = 42 ,  // 42
   minute_43 = 43 ,  // 43
   minute_44 = 44 ,  // 44
   minute_45 = 45 ,  // 45
   minute_46 = 46 ,  // 46
   minute_47 = 47 ,  // 47
   minute_48 = 48 ,  // 48
   minute_49 = 49 ,  // 49
   minute_50 = 50 ,  // 50
   minute_51 = 51 ,  // 51
   minute_52 = 52 ,  // 52
   minute_53 = 53 ,  // 53
   minute_54 = 54 ,  // 54
   minute_55 = 55 ,  // 55
   minute_56 = 56 ,  // 56
   minute_57 = 57 ,  // 57
   minute_58 = 58 ,  // 58
   minute_59 = 59    // 59
  };
//--- input parameters
input uchar          InpNumberMinimumLots = 1;        // Number of minimum lots
input int            InpDepth             = 12;       // Depth 
input int            InpDeviation         = 5;        // Deviation
input int            InpBackstep          = 3;        // Backstep
input ushort         InpTrailingStop      = 15;       // Trailing Stop (in pips)
input ushort         InpTrailingStep      = 5;        // Trailing Step (in pips)
input ENUM_DAYS      InpStartDay          = day_01;   // Start day
input ENUM_HOURS     InpStartHour         = hour_09;  // Start hour (every day)
input ENUM_MINUTES   InpStartMinute       = minute_1; // Start minute (every day)
input ENUM_DAYS      InpEndDay            = day_05;   // End day
input ENUM_HOURS     InpEndHour           = hour_21;  // End hour (every day)
input ENUM_MINUTES   InpEndMinute         = minute_1; // End minute (every day)
input bool           InpCloseAll          = true;     // Close out all business hours
ulong                m_magic              = 15489;    // magic number
ulong                m_slippage           = 10;       // slippage
//---
double               ExtTrailingStop=0;
double               ExtTrailingStep=0;
int                  handle_iCustom;      // variable for storing the handle of the iCustom indicator 
double               m_adjusted_point;    // point value adjusted for 3 or 5 points
string               m_vline_A_name="vline_A";
string               m_vline_B_name="vline_B";
string               m_vline_C_name="vline_C";
string               m_prefix="Last ZZ50";
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(InpStartDay>InpEndDay)
     {
      Print("\"Start day\" not be more \"End day\"");
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(InpStartHour>InpEndHour)
     {
      Print("\"Start hour\" not be more \"End hour\"");
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(InpStartMinute>InpEndMinute)
     {
      Print("\"Start minute\" not be more \"End minute\"");
      return(INIT_PARAMETERS_INCORRECT);
     }
//---
   long  chart_id=0;
   int   sub_window=0;
   int   total=ChartIndicatorsTotal(chart_id,sub_window);
   for(int i=total-1;i>=0;i--)
     {
      string name=ChartIndicatorName(chart_id,sub_window,i);
      ChartIndicatorDelete(chart_id,sub_window,name);
     }
//---
   if(!m_symbol.Name(Symbol())) // sets symbol name
      return(INIT_FAILED);
   RefreshRates();
//---
   m_trade.SetExpertMagicNumber(m_magic);
//---
   if(IsFillingTypeAllowed(SYMBOL_FILLING_FOK))
      m_trade.SetTypeFilling(ORDER_FILLING_FOK);
   else if(IsFillingTypeAllowed(SYMBOL_FILLING_IOC))
      m_trade.SetTypeFilling(ORDER_FILLING_IOC);
   else
      m_trade.SetTypeFilling(ORDER_FILLING_RETURN);
//---
   m_trade.SetDeviationInPoints(m_slippage);
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   m_adjusted_point=m_symbol.Point()*digits_adjust;

   ExtTrailingStop=InpTrailingStop*m_adjusted_point;
   ExtTrailingStep=InpTrailingStep*m_adjusted_point;
//--- create handle of the indicator iCustom
   handle_iCustom=iCustom(m_symbol.Name(),Period(),"Examples\\ZigZag",InpDepth,InpDeviation,InpBackstep);
//--- if the handle is not created 
   if(handle_iCustom==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iCustom indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
   if(!ChartIndicatorAdd(0,0,handle_iCustom))
     {
      Print("ChartIndicatorAdd error# ",GetLastError());
      return(INIT_FAILED);
     }
//---
   long     chart_ID    = 0;
   sub_window           = 0;
   datetime time        = 0;
   VLineCreate(chart_ID,m_vline_A_name,sub_window,time,clrPurple);
   VLineCreate(chart_ID,m_vline_B_name,sub_window,time,clrYellow);
   VLineCreate(chart_ID,m_vline_C_name,sub_window,time,clrRed);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   Print(__FUNCTION__);
   IndicatorRelease(handle_iCustom);
   VLineDelete(0,m_vline_A_name);
   VLineDelete(0,m_vline_B_name);
   VLineDelete(0,m_vline_C_name);
//---
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- we work only at the time of the birth of new bar
   static datetime PrevBars=0;

   MqlDateTime str1;
   TimeToStruct(TimeCurrent(),str1);
   if(str1.day_of_week<InpStartDay || str1.day_of_week>InpEndDay)
     {
      CloseAllPositions();
      return;
     }
   if(str1.hour<InpStartHour || str1.hour>InpEndHour)
     {
      CloseAllPositions();
      return;
     }
   if(str1.hour==InpStartHour && str1.min<InpStartMinute)
     {
      CloseAllPositions();
      return;
     }
   if(str1.hour==InpEndHour && str1.min>InpEndMinute)
     {
      CloseAllPositions();
      return;
     }

   datetime time_0=iTime(m_symbol.Name(),Period(),0);
   if(time_0==PrevBars)
      return;
   PrevBars=time_0;

   if(!RefreshRates())
     {
      PrevBars=iTime(m_symbol.Name(),Period(),1);
      return;
     }

   Trailing();
//--- we begin search of tops of "A", "B" and "C"
   int bars_calculated=BarsCalculated(handle_iCustom);
   bool top_A_is_found=false;
   bool top_B_is_found=false;
   bool top_C_is_found=false;
   double price_A=0.0;
   double price_B=0.0;
   double price_C=0.0;
   int limit=0;
   while((!top_A_is_found || !top_B_is_found || !top_C_is_found) || limit==bars_calculated)
     {
      double custom=iCustomGet(handle_iCustom,0,limit);
      if(custom!=0.0)
        {
         if(!top_A_is_found)
           {
            datetime time_array[];
            if(CopyTime(m_symbol.Name(),Period(),limit,1,time_array)==1)
              {
               top_A_is_found=true;
               price_A=custom;
               VLineMove(0,m_vline_A_name,time_array[0]);
              }
           }
         else if(!top_B_is_found)
           {
            datetime time_array[];
            if(CopyTime(m_symbol.Name(),Period(),limit,1,time_array)==1)
              {
               top_B_is_found=true;
               price_B=custom;
               VLineMove(0,m_vline_B_name,time_array[0]);
              }
           }
         else if(!top_C_is_found)
           {
            datetime time_array[];
            if(CopyTime(m_symbol.Name(),Period(),limit,1,time_array)==1)
              {
               top_C_is_found=true;
               price_C=custom;
               VLineMove(0,m_vline_C_name,time_array[0]);
              }
           }
        }
      limit++;
     }
   if(top_A_is_found && top_B_is_found && top_C_is_found)
     {
      ulong ticket_AB=0;
      ulong ticket_BC=0;
      GetTicketFromGlobalVariable(ticket_AB,ticket_BC);

      double price_pending=0.0;
      //--- processing the beam "BC"
      if(ticket_BC==0)
        {
         //--- search for a position with the comment "BC"
         bool is_search=false;
         for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of current positions
            if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
               if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
                  if(StringFind(m_position.Comment(),m_prefix+"BC",0)!=-1)
                    {
                     is_search=true;
                     break;
                    }
         if((price_B!=GlobalVariableGet(m_prefix+"B") && 
            price_C!=GlobalVariableGet(m_prefix+"C") && is_search) || 
            !is_search)
           {
            price_pending=(price_B+price_C)/2.0;
            //--- protection against situations (pic. 3. and pic. 4. - https://www.mql5.com/ru/forum/211099/page3#comment_5485512 )
            if((price_C<price_B && price_A>price_pending) || (price_C>price_B && price_A<price_pending))
              {
               if(price_B<price_C) // BuyXXXX
                 {
                  ulong ticket=0;
                  if(m_symbol.Ask()>price_pending && m_symbol.Bid()>price_pending)
                     if(PlacePendingOrder(ORDER_TYPE_BUY_LIMIT,(double)(m_symbol.LotsMin()*InpNumberMinimumLots),
                        m_symbol.NormalizePrice(price_pending),ticket,m_prefix+"BC"))
                        ticket_BC=ticket;
                  if(m_symbol.Ask()<price_pending && m_symbol.Bid()<price_pending)
                     if(PlacePendingOrder(ORDER_TYPE_BUY_STOP,(double)(m_symbol.LotsMin()*InpNumberMinimumLots),
                        m_symbol.NormalizePrice(price_pending),ticket,m_prefix+"BC"))
                        ticket_BC=ticket;
                 }
               else if(price_B>price_C) // SellXXX
                 {
                  ulong ticket=0;
                  if(m_symbol.Ask()>price_pending && m_symbol.Bid()>price_pending)
                     if(PlacePendingOrder(ORDER_TYPE_SELL_STOP,(double)(m_symbol.LotsMin()*InpNumberMinimumLots),
                        m_symbol.NormalizePrice(price_pending),ticket,m_prefix+"BC"))
                        ticket_BC=ticket;
                  if(m_symbol.Ask()<price_pending && m_symbol.Bid()<price_pending)
                     if(PlacePendingOrder(ORDER_TYPE_SELL_LIMIT,(double)(m_symbol.LotsMin()*InpNumberMinimumLots),
                        m_symbol.NormalizePrice(price_pending),ticket,m_prefix+"BC"))
                        ticket_BC=ticket;
                 }
               if(ticket_BC!=0)
                  GlobalVariableSet(m_prefix+"BC"+IntegerToString(ticket_BC),0.0);
              }
           }
        }
      else
        {
         price_pending=(price_B+price_C)/2.0;
         if(m_order.Select(ticket_BC))
           {
            if(price_B!=GlobalVariableGet(m_prefix+"B") &&
               price_C!=GlobalVariableGet(m_prefix+"C"))
               m_trade.OrderDelete(m_order.Ticket());
           }
        }
      if(ticket_AB==0)
        {
         //--- search for a position with the comment "AB"
         bool is_search=false;
         for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of current positions
            if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
               if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
                 {
                  if(StringFind(m_position.Comment(),m_prefix+"AB",0)!=-1)
                    {
                     is_search=true;
                     break;
                    }
                 }
         if((price_A!=GlobalVariableGet(m_prefix+"A") && 
            price_B!=GlobalVariableGet(m_prefix+"B") && is_search) || 
            !is_search)
           {
            price_pending=(price_A+price_B)/2.0;
            if(price_A<price_B) // BuyXXXX
              {
               ulong ticket=0;
               if(m_symbol.Ask()>price_pending && m_symbol.Bid()>price_pending)
                  if(PlacePendingOrder(ORDER_TYPE_BUY_LIMIT,(double)(m_symbol.LotsMin()*InpNumberMinimumLots),
                     m_symbol.NormalizePrice(price_pending),ticket,m_prefix+"AB"))
                     ticket_AB=ticket;
               if(m_symbol.Ask()<price_pending && m_symbol.Bid()<price_pending)
                  if(PlacePendingOrder(ORDER_TYPE_BUY_STOP,(double)(m_symbol.LotsMin()*InpNumberMinimumLots),
                     m_symbol.NormalizePrice(price_pending),ticket,m_prefix+"AB"))
                     ticket_AB=ticket;
              }
            else if(price_A>price_B) // SellXXX
              {
               ulong ticket=0;
               if(m_symbol.Ask()>price_pending && m_symbol.Bid()>price_pending)
                  if(PlacePendingOrder(ORDER_TYPE_SELL_STOP,(double)(m_symbol.LotsMin()*InpNumberMinimumLots),
                     m_symbol.NormalizePrice(price_pending),ticket,m_prefix+"AB"))
                     ticket_AB=ticket;
               if(m_symbol.Ask()<price_pending && m_symbol.Bid()<price_pending)
                  if(PlacePendingOrder(ORDER_TYPE_SELL_LIMIT,(double)(m_symbol.LotsMin()*InpNumberMinimumLots),
                     m_symbol.NormalizePrice(price_pending),ticket,m_prefix+"AB"))
                     ticket_AB=ticket;
              }
            if(ticket_AB!=0)
               GlobalVariableSet(m_prefix+"AB"+IntegerToString(ticket_AB),0.0);
           }
        }
      else
        {
         price_pending=(price_A+price_B)/2.0;
         if(m_order.Select(ticket_AB))
           {
            if(price_A!=GlobalVariableGet(m_prefix+"A") &&
               price_B!=GlobalVariableGet(m_prefix+"B"))
               m_trade.OrderDelete(m_order.Ticket());
            else if(!CompareDoubles(price_pending,m_order.PriceOpen()))
               m_trade.OrderModify(ticket_AB,price_pending,
                                   m_order.StopLoss(),
                                   m_order.TakeProfit(),
                                   m_order.TypeTime(),
                                   m_order.TimeExpiration());
           }
        }
      //--- we keep value of tops
      GlobalVariableSet(m_prefix+"A",price_A);
      GlobalVariableSet(m_prefix+"B",price_B);
      GlobalVariableSet(m_prefix+"C",price_C);
     }
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
//| Checks if the specified filling mode is allowed                  | 
//+------------------------------------------------------------------+ 
bool IsFillingTypeAllowed(int fill_type)
  {
//--- Obtain the value of the property that describes allowed filling modes 
   int filling=m_symbol.TradeFillFlags();
//--- Return true, if mode fill_type is allowed 
   return((filling & fill_type)==fill_type);
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iCustom                             |
//|  the buffer numbers are the following:                           |
//+------------------------------------------------------------------+
double iCustomGet(int handle,const int buffer,const int index)
  {
   double Custom[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iCustom array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle,buffer,index,1,Custom)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iCustom indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(Custom[0]);
  }
//+------------------------------------------------------------------+ 
//| Create the vertical line                                         | 
//+------------------------------------------------------------------+ 
bool VLineCreate(const long            chart_ID=0,// chart's ID 
                 const string          name="VLine",      // line name 
                 const int             sub_window=0,      // subwindow index 
                 datetime              time=0,            // line time 
                 const color           clr=clrRed,        // line color 
                 const ENUM_LINE_STYLE style=STYLE_SOLID, // line style 
                 const int             width=1,           // line width 
                 const bool            back=false,        // in the background 
                 const bool            selection=false,   // highlight to move 
                 const bool            ray=true,          // line's continuation down 
                 const bool            hidden=true,       // hidden in the object list 
                 const long            z_order=0)         // priority for mouse click 
  {
//--- if the line time is not set, draw it via the last bar 
   if(!time)
      time=TimeCurrent();
//--- reset the error value 
   ResetLastError();
//--- create a vertical line 
   if(!ObjectCreate(chart_ID,name,OBJ_VLINE,sub_window,time,0))
     {
      Print(__FUNCTION__,
            ": failed to create a vertical line! Error code = ",GetLastError());
      return(false);
     }
//--- set line color 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set line display style 
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set line width 
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- display in the foreground (false) or background (true) 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the line by mouse 
//--- when creating a graphical object using ObjectCreate function, the object cannot be 
//--- highlighted and moved by default. Inside this method, selection parameter 
//--- is true by default making it possible to highlight and move the object 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- enable (true) or disable (false) the mode of displaying the line in the chart subwindows 
   ObjectSetInteger(chart_ID,name,OBJPROP_RAY,ray);
//--- hide (true) or display (false) graphical object name in the object list 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Move the vertical line                                           | 
//+------------------------------------------------------------------+ 
bool VLineMove(const long   chart_ID=0,// chart's ID 
               const string name="VLine", // line name 
               datetime     time=0)       // line time 
  {
//--- if line time is not set, move the line to the last bar 
   if(!time)
      time=TimeCurrent();
//--- reset the error value 
   ResetLastError();
//--- move the vertical line 
   if(!ObjectMove(chart_ID,name,0,time,0))
     {
      Print(__FUNCTION__,
            ": failed to move the vertical line! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Delete the vertical line                                         | 
//+------------------------------------------------------------------+ 
bool VLineDelete(const long   chart_ID=0,// chart's ID 
                 const string name="VLine") // line name 
  {
//--- reset the error value 
   ResetLastError();
//--- delete the vertical line 
   if(!ObjectDelete(chart_ID,name))
     {
      Print(__FUNCTION__,
            ": failed to delete the vertical line! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+
//| Get ticket from global variable                                  |
//|  format: "Last ZZ50ABnnnnnnnn"                                   |
//|          "Last ZZ50BCnnnnnnnn"                                   |
//|          nnnnnnnn - ticket                                       |
//+------------------------------------------------------------------+
void GetTicketFromGlobalVariable(ulong  &ticket_AB,ulong  &ticket_BC)
  {
   ticket_AB=0;
   ticket_BC=0;
   string name_AB="";
   string name_BC="";
   for(int i=0;i<GlobalVariablesTotal();i++)
     {
      string name=GlobalVariableName(i);
      int index=StringFind(name,m_prefix,0);
      if(index!=-1)
        {
         string beam_name=StringSubstr(name,StringLen(m_prefix),2);
         if(beam_name=="AB")
           {
            ticket_AB=StringToInteger(StringSubstr(name,StringLen(m_prefix)+2,-1));
            name_AB=name;
           }
         else if(beam_name=="BC")
           {
            ticket_BC=StringToInteger(StringSubstr(name,StringLen(m_prefix)+2,-1));
            name_BC=name;
           }
        }
     }
//--- pending order search
   if(ticket_AB!=0)
     {
      bool search_AB=false;
      if(!m_order.Select(ticket_AB)) // selects the pending order by ticket
        {
         ticket_AB=0;
         GlobalVariableDel(name_AB);
        }
     }
   if(ticket_BC!=0)
     {
      bool search_BC=false;
      if(!m_order.Select(ticket_BC)) // selects the pending order by ticket
        {
         ticket_BC=0;
         GlobalVariableDel(name_BC);
        }
     }
  }
//+------------------------------------------------------------------+
//| Place pending order                                              |
//+------------------------------------------------------------------+
bool PlacePendingOrder(ENUM_ORDER_TYPE order_type,double volume,double price,ulong  &pending_order_ticket,string comment)
  {
   bool result=true;
   if(order_type!=ORDER_TYPE_BUY_LIMIT && order_type!=ORDER_TYPE_SELL_LIMIT &&
      order_type!=ORDER_TYPE_BUY_STOP && order_type!=ORDER_TYPE_SELL_STOP)
      return(false);

   if(!m_trade.OrderOpen(m_symbol.Name(),order_type,volume,0.0,price,0.0,0.0,0,0,comment))
     {
      Print(EnumToString(order_type)," -> false. Result Retcode: ",m_trade.ResultRetcode(),
            ", description of Retcode: ",m_trade.ResultRetcodeDescription(),
            ", ticket of order: ",m_trade.ResultOrder());
      return(false);
     }
   else if(m_trade.ResultOrder()==0)
     {
      Print(EnumToString(order_type)," -> false. Result Retcode: ",m_trade.ResultRetcode(),
            ", description of Retcode: ",m_trade.ResultRetcodeDescription(),
            ", ticket of order: ",m_trade.ResultOrder());
      return(false);
     }

   pending_order_ticket=m_trade.ResultOrder();
//---
   return(result);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CompareDoubles(double number1,double number2)
  {
   if(NormalizeDouble(number1-number2,Digits()-1)==0)
      return(true);
   else
      return(false);
  }
//+------------------------------------------------------------------+
//| Trailing                                                         |
//+------------------------------------------------------------------+
void Trailing()
  {
   if(ExtTrailingStop==0)
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
                     return;
                    }
              }

           }
  }
//+------------------------------------------------------------------+
//| Close all positions                                              |
//+------------------------------------------------------------------+
void CloseAllPositions()
  {
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of current positions
      if(m_position.SelectByIndex(i))     // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            m_trade.PositionClose(m_position.Ticket()); // close a position by the specified symbol
  }
//+------------------------------------------------------------------+
