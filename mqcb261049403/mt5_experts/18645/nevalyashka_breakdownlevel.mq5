//+------------------------------------------------------------------+
//|          Nevalyashka_BreakdownLevel(barabashkakvn's edition).mq5 |
//|                               Copyright © 2010, Vladimir Hlystov |
//|                                         http://cmillion.narod.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, http://cmillion.narod.ru"
#property link      "cmillion@narod.ru"
#property version   "1.010"
//---
#define MODE_LOW 1
#define MODE_HIGH 2
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
//--- input parameters
input    datetime InpTimeStart   = D'1980.07.19 07:26:00';  // Time start (use only hh:mm) 
input    datetime InpTimeEnd     = D'1980.07.19 09:13:00';  // Time end (use only hh:mm) 
input    bool     InpUseTimeClose= false;                   // true -> Use time close
input    datetime InpTimeClose   = D'1980.07.19 23:30:00';  // Time close (use only hh:mm) 
input    double   InpLot         = 0.1;                     // Lot             
input    double   InpK_martin    = 2;                       // K. martin
input    bool     InpNo_Loss     = false;                   // No loss
input    int      m_magic        = 23180696;                // magic  number
//---
ulong             m_slippage=30;                            // slippage
bool              bln_close_all=false;                      // true -> you must close all positions
double            m_adjusted_point;                         // point value adjusted for 3 or 5 points
int               TradeDey;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   m_symbol.Name(Symbol());                  // sets symbol name
   RefreshRates();
   m_symbol.Refresh();

   string err_text="";
   if(!CheckVolumeValue(InpLot,err_text))
     {
      Print(err_text);
      return(INIT_PARAMETERS_INCORRECT);
     }
//---
   m_trade.SetExpertMagicNumber(m_magic);
//---
   if(IsFillingTypeAllowed(m_symbol.Name(),SYMBOL_FILLING_FOK))
      m_trade.SetTypeFilling(ORDER_FILLING_FOK);
   else if(IsFillingTypeAllowed(m_symbol.Name(),SYMBOL_FILLING_IOC))
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
//---
   MqlDateTime str1,str_time_start,str_time_end,str_time_close;
   TimeToStruct(TimeCurrent(),str1);
//--- filling of structures
   TimeToStruct(InpTimeStart,str_time_start);
   TimeToStruct(InpTimeEnd,str_time_end);
   TimeToStruct(InpTimeClose,str_time_close);
   str_time_start.day         =str_time_end.day          =str_time_close.day           =str1.day;
   str_time_start.day_of_week =str_time_end.day_of_week  =str_time_close.day_of_week   =str1.day_of_week;
   str_time_start.day_of_year =str_time_end.day_of_year  =str_time_close.day_of_year   =str1.day_of_year;
   str_time_start.mon         =str_time_end.mon          =str_time_close.mon           =str1.mon;
   str_time_start.sec         =str_time_end.sec          =str_time_close.sec           =0;
   str_time_start.year        =str_time_end.year         =str_time_close.year          =str1.year;
   datetime Time_Start  =StructToTime(str_time_start);
   datetime Time_End    =StructToTime(str_time_end);
   datetime Time_Close  =StructToTime(str_time_close);
   if(Time_Start>=Time_End)
     {
      Print("\"Time start\" can not be greater than or equal to \"Time end\"");
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(Time_End>=Time_Close)
     {
      Print("\"Time end\" can not be greater than or equal to \"Time close\"");
      return(INIT_PARAMETERS_INCORRECT);
     }
//---
   bln_close_all=false;                      // true -> you must close all positions
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
   if(!RefreshRates())
      return;
//---
   if(bln_close_all)
     {
      if(CalculateAllPositions()==0)
         bln_close_all=false;
      else
        {
         CloseAllPositions();
         return;
        }
     }
//---
   MqlDateTime str1,str_time_start,str_time_end,str_time_close;
   TimeToStruct(TimeCurrent(),str1);
   TimeToStruct(InpTimeStart,str_time_start);
   TimeToStruct(InpTimeEnd,str_time_end);
   TimeToStruct(InpTimeClose,str_time_close);
   str_time_start.day         =str_time_end.day          =str_time_close.day           =str1.day;
   str_time_start.day_of_week =str_time_end.day_of_week  =str_time_close.day_of_week   =str1.day_of_week;
   str_time_start.day_of_year =str_time_end.day_of_year  =str_time_close.day_of_year   =str1.day_of_year;
   str_time_start.mon         =str_time_end.mon          =str_time_close.mon           =str1.mon;
   str_time_start.sec         =str_time_end.sec          =str_time_close.sec           =0;
   str_time_start.year        =str_time_end.year         =str_time_close.year          =str1.year;
   datetime Time_Start  =StructToTime(str_time_start);
   datetime Time_End    =StructToTime(str_time_end);
   datetime Time_Close  =StructToTime(str_time_close);

   if(InpUseTimeClose)
      if(TimeCurrent()>=Time_Close)
        {
         if(CalculateAllPositions()==0)
           {
            bln_close_all=false;
            return;
           }
         bln_close_all=true;                       // true -> you must close all positions
         CloseAllPositions();
         return;
        }

   if(CalculateAllPositions()==0 && TimeCurrent()<Time_Close && TradeDey!=str1.day)
     {
      double Max_Price=iHighest(m_symbol.Name(),Period(),MODE_HIGH,Time_Start,Time_End);
      double Min_Price=iLowest(m_symbol.Name(),Period(),MODE_LOW,Time_Start,Time_End);
      if(Max_Price==0.0 || Min_Price==0.0)
         return;

      if(TimeCurrent()>Time_End && ObjectFind(0,"bar0"+TimeToString(Time_End,TIME_DATE|TIME_MINUTES))==-1)
        {
         RectangleCreate(0,"bar0"+TimeToString(Time_End,TIME_DATE|TIME_MINUTES),0,Time_Start,Max_Price,
                         Time_End,Min_Price,clrBlue,STYLE_SOLID);
        }

      if(m_symbol.Bid()>Max_Price)
         OpenBuy(Min_Price,m_symbol.Ask()+Max_Price-Min_Price,InpLot,"BreakdownLevel");
      if(m_symbol.Bid()<Min_Price)
         OpenSell(Max_Price,m_symbol.Bid()-Max_Price+Min_Price,InpLot,"BreakdownLevel");
      return;
     }
//---
   if(InpNo_Loss)
      No_Loss();
//---
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void No_Loss()
  {
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               if(m_position.StopLoss()>m_position.PriceOpen())
                  continue;
               if((m_position.TakeProfit()-m_position.PriceOpen())/2.0+m_position.PriceOpen()<=m_symbol.Bid())
                  m_trade.PositionModify(m_position.Ticket(),
                                         m_symbol.NormalizePrice(m_position.PriceOpen()+m_symbol.Ask()-m_symbol.Bid()),
                                         m_position.TakeProfit());
              }
            if(m_position.PositionType()==POSITION_TYPE_SELL)
              {
               if(m_position.StopLoss()<m_position.PriceOpen())
                  continue;
               if(m_position.PriceOpen()-(m_position.PriceOpen()-m_position.TakeProfit())/2.0>=m_symbol.Ask())
                  m_trade.PositionModify(m_position.Ticket(),
                                         m_symbol.NormalizePrice(m_position.PriceOpen()-m_symbol.Ask()+m_symbol.Bid()),
                                         m_position.TakeProfit());
              }
           }
  }
//+------------------------------------------------------------------+
//| Check the correctness of the order volume                        |
//+------------------------------------------------------------------+
bool CheckVolumeValue(double volume,string &error_description)
  {
//--- minimal allowed volume for trade operations
   double min_volume=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN);
   if(volume<min_volume)
     {
      error_description=StringFormat("Volume is less than the minimal allowed SYMBOL_VOLUME_MIN=%.2f",min_volume);
      return(false);
     }

//--- maximal allowed volume of trade operations
   double max_volume=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX);
   if(volume>max_volume)
     {
      error_description=StringFormat("Volume is greater than the maximal allowed SYMBOL_VOLUME_MAX=%.2f",max_volume);
      return(false);
     }

//--- get minimal step of volume changing
   double volume_step=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP);

   int ratio=(int)MathRound(volume/volume_step);
   if(MathAbs(ratio*volume_step-volume)>0.0000001)
     {
      error_description=StringFormat("Volume is not a multiple of the minimal step SYMBOL_VOLUME_STEP=%.2f, the closest correct volume is %.2f",
                                     volume_step,ratio*volume_step);
      return(false);
     }
   error_description="Correct volume value";
   return(true);
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
bool IsFillingTypeAllowed(string symbol,int fill_type)
  {
//--- Obtain the value of the property that describes allowed filling modes 
   int filling=(int)SymbolInfoInteger(symbol,SYMBOL_FILLING_MODE);
//--- Return true, if mode fill_type is allowed 
   return((filling & fill_type)==fill_type);
  }
//+------------------------------------------------------------------+
//| Close all positions                                              |
//+------------------------------------------------------------------+
void CloseAllPositions()
  {
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of current positions
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            m_trade.PositionClose(m_position.Ticket()); // close a position by the specified symbol
  }
//+------------------------------------------------------------------+
//| Calculate positions                                              |
//+------------------------------------------------------------------+
int CalculateAllPositions()
  {
   int total=0;

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            total++;
//---
   return(total);
  }
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
  {
//--- get transaction type as enumeration value 
   ENUM_TRADE_TRANSACTION_TYPE type=trans.type;
//--- if transaction is result of addition of the transaction in history
   if(type==TRADE_TRANSACTION_DEAL_ADD)
     {
      long     deal_entry        =0;
      double   deal_profit       =0.0;
      double   deal_volume       =0.0;
      long     deal_type         =0;
      string   deal_symbol       ="";
      string   deal_comment      ="";
      long     deal_magic        =0;
      if(HistoryDealSelect(trans.deal))
        {
         deal_entry=HistoryDealGetInteger(trans.deal,DEAL_ENTRY);
         deal_profit=HistoryDealGetDouble(trans.deal,DEAL_PROFIT);
         deal_volume=HistoryDealGetDouble(trans.deal,DEAL_VOLUME);
         deal_type=HistoryDealGetInteger(trans.deal,DEAL_TYPE);
         deal_symbol=HistoryDealGetString(trans.deal,DEAL_SYMBOL);
         deal_comment=HistoryDealGetString(trans.deal,DEAL_COMMENT);
         deal_magic=HistoryDealGetInteger(trans.deal,DEAL_MAGIC);
        }
      else
         return;
      if(deal_symbol==m_symbol.Name() && deal_magic==m_magic)
         if(deal_entry==DEAL_ENTRY_OUT)
           {
            MqlDateTime str1;
            TimeToStruct(TimeCurrent(),str1);
            //--- there is a chance that this was a closure on the TakeProfit
            if(StringFind(deal_comment,"tp",0)!=-1 || deal_profit>=0.0)
              {
               TradeDey=str1.day;
               return;
              }
            //--- there is a chance that this was a closure on the StopLoss
            if(StringFind(deal_comment,"sl",0)!=-1)
              {
               if(TradeDey!=str1.day)
                 {
                  Print("A StopLoss closure has been detected!");

                  double loss=MathAbs(deal_profit/m_symbol.TickValue()/deal_volume);

                  if(deal_type==DEAL_TYPE_SELL) // the buy position is closed
                    {
                     double SL=m_symbol.Bid()+loss*m_symbol.Point();
                     double TP=m_symbol.Bid()-loss*m_symbol.Point();
                     double Lot=LotCheck(deal_volume*InpK_martin);
                     if(Lot==0.0)
                        return;
                     OpenSell(SL,TP,Lot,"Nevalyashka");

                    }
                  if(deal_type==DEAL_TYPE_BUY) // the sell position is closed
                    {
                     double SL=m_symbol.Ask()-loss*m_symbol.Point();
                     double TP=m_symbol.Ask()+loss*m_symbol.Point();
                     double Lot=LotCheck(deal_volume*InpK_martin);
                     if(Lot==0.0)
                        return;
                     OpenBuy(SL,TP,Lot,"Nevalyashka");
                    }
                  return;
                 }
              }
           }
     }
//---
   return;
  }
//+------------------------------------------------------------------+
//| Returns the maximum value (double) for the start and             |
//|   end dates of a required time interval                          |
//+------------------------------------------------------------------+
double iHighest(string symbol,
                ENUM_TIMEFRAMES timeframe,
                int type,
                datetime start_time,
                datetime stop_time)
  {
   if(type==MODE_HIGH)
     {
      double High[];
      if(CopyHigh(symbol,timeframe,start_time,stop_time,High)==-1)
         return(0.0);
      int index_max=ArrayMaximum(High);
      return(High[index_max]);
     }
//---
   return(0.0);
  }
//+------------------------------------------------------------------+
//| Returns the minimum value (double) for the start and             |
//|   end dates of a required time interval                          |
//+------------------------------------------------------------------+
double iLowest(string symbol,
               ENUM_TIMEFRAMES timeframe,
               int type,
               datetime start_time,
               datetime stop_time)
  {
   if(type==MODE_LOW)
     {
      double Low[];
      if(CopyLow(symbol,timeframe,start_time,stop_time,Low)==-1)
         return(0.0);
      int index_min=ArrayMinimum(Low);
      return(Low[index_min]);
     }
//---
   return(0.0);
  }
//+------------------------------------------------------------------+ 
//| Create rectangle by the given coordinates                        | 
//+------------------------------------------------------------------+ 
bool RectangleCreate(const long            chart_ID=0,// chart's ID 
                     const string          name="Rectangle",  // rectangle name 
                     const int             sub_window=0,      // subwindow index  
                     datetime              time1=0,           // first point time 
                     double                price1=0,          // first point price 
                     datetime              time2=0,           // second point time 
                     double                price2=0,          // second point price 
                     const color           clr=clrRed,        // rectangle color 
                     const ENUM_LINE_STYLE style=STYLE_SOLID, // style of rectangle lines 
                     const int             width=1,           // width of rectangle lines 
                     const bool            fill=false,        // filling rectangle with color 
                     const bool            back=false,        // in the background 
                     const bool            selection=false,   // highlight to move 
                     const bool            hidden=true,       // hidden in the object list 
                     const long            z_order=0)         // priority for mouse click 
  {
//--- reset the error value 
   ResetLastError();
//--- create a rectangle by the given coordinates 
   if(!ObjectCreate(chart_ID,name,OBJ_RECTANGLE,sub_window,time1,price1,time2,price2))
     {
      Print(__FUNCTION__,
            ": failed to create a rectangle! Error code = ",GetLastError());
      return(false);
     }
//--- set rectangle color 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set the style of rectangle lines 
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set width of the rectangle lines 
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- enable (true) or disable (false) the mode of filling the rectangle 
   ObjectSetInteger(chart_ID,name,OBJPROP_FILL,fill);
//--- display in the foreground (false) or background (true) 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of highlighting the rectangle for moving 
//--- when creating a graphical object using ObjectCreate function, the object cannot be 
//--- highlighted and moved by default. Inside this method, selection parameter 
//--- is true by default making it possible to highlight and move the object 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+
//| Open Buy position                                                |
//+------------------------------------------------------------------+
void OpenBuy(double sl,double tp,double lot,string comment=NULL)
  {
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);

//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double check_volume_lot=m_trade.CheckVolume(m_symbol.Name(),lot,m_symbol.Ask(),ORDER_TYPE_BUY);

   if(check_volume_lot!=0.0)
      if(check_volume_lot>=lot)
        {
         if(m_trade.Buy(lot,NULL,m_symbol.Ask(),sl,tp,comment))
           {
            if(m_trade.ResultDeal()==0)
              {
               Print("Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
              }
            else
              {
               Print("Buy -> true. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
              }
           }
         else
           {
            Print("Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
           }
        }
//---
  }
//+------------------------------------------------------------------+
//| Open Sell position                                               |
//+------------------------------------------------------------------+
void OpenSell(double sl,double tp,double lot,string comment=NULL)
  {
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);

//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double check_volume_lot=m_trade.CheckVolume(m_symbol.Name(),lot,m_symbol.Bid(),ORDER_TYPE_SELL);

   if(check_volume_lot!=0.0)
      if(check_volume_lot>=lot)
        {
         if(m_trade.Sell(lot,NULL,m_symbol.Bid(),sl,tp,comment))
           {
            if(m_trade.ResultDeal()==0)
              {
               Print("Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
              }
            else
              {
               Print("Sell -> true. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
              }
           }
         else
           {
            Print("Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
           }
        }
//---
  }
//+------------------------------------------------------------------+
//| Lot Check                                                        |
//+------------------------------------------------------------------+
double LotCheck(double lots)
  {
//--- calculate maximum volume
   double volume=NormalizeDouble(lots,2);
   double stepvol=m_symbol.LotsStep();
   if(stepvol>0.0)
      volume=stepvol*MathFloor(volume/stepvol);
//---
   double minvol=m_symbol.LotsMin();
   if(volume<minvol)
      volume=0.0;
//---
   double maxvol=m_symbol.LotsMax();
   if(volume>maxvol)
      volume=maxvol;
   return(volume);
  }
//+------------------------------------------------------------------+
