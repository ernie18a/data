//+------------------------------------------------------------------+
//|                             Lego EA(barabashkakvn's edition).mq5 |
//+------------------------------------------------------------------+
#property version   "1.001"
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CAccountInfo   m_account;                    // account info wrapper
//--- input parameters
input double   InpLots           = 1.0;      // Lots
input ushort   InpStopLoss       = 200;      // Stop Loss, in pips (1.00045-1.00055=1 pips)
input ushort   InpTakeProfit     = 200;      // Take Profit, in pips (1.00045-1.00055=1 pips)
input double   InpLotMultiply    = 2.0;      // Multiply a lot if the last deal was unprofitable
//--- input CCI parameters
input bool                 InpOpenCCI           = false;          // CCI: use CCI to open
input bool                 InpCloseCCI          = false;          // CCI: use CCI to close
input int                  Inp_CCI_ma_period    = 14;             // CCI: averaging period 
input ENUM_APPLIED_PRICE   Inp_CCI_applied_price= PRICE_TYPICAL;  // CCI: type of price
//--- input MA's parameters
input bool                 InpOpenMA            = true;           // MA's: use MA's to open
input bool                 InpCloseMA           = true;           // MA's: use MA's to close
input int                  Inp_MA1_ma_period    = 14;             // MA1: averaging period 
input int                  Inp_MA2_ma_period    = 67;             // MA2: averaging period 
input int                  Inp_MA_ma_shift      = 1;              // MA's: horizontal shift 
input ENUM_MA_METHOD       Inp_MA_ma_method     = MODE_SMA;       // MA's: smoothing type 
input ENUM_APPLIED_PRICE   Inp_MA_applied_price = PRICE_CLOSE;    // MA's: type of price or handle 
//--- input Stochastic parameters
input bool                 InpOpenSTO           = false;          // STO: use STO to open
input bool                 InpCloseSTO          = false;          // STO: use STO to close
input int                  Inp_STO_Kperiod      = 5;              // STO: K-period (number of bars for calculations) 
input int                  Inp_STO_Dperiod      = 3;              // STO: D-period (period of first smoothing) 
input int                  Inp_STO_slowing      = 3;              // STO: final smoothing 
input ENUM_MA_METHOD       Inp_STO_ma_method    = MODE_SMA;       // STO: type of smoothing 
input ENUM_STO_PRICE       Inp_STO_price_field  = STO_LOWHIGH;    // STO: stochastic calculation method 
input double               Inp_STO_Level_Up     = 30;             // STO: Level Up
input double               Inp_STO_Level_Down   = 70;             // STO: Level Down
//--- input AC parameters
input bool                 InpOpenAC            = false;          // AC: use AC to open
input bool                 InpCloseAC           = false;          // AC: use AC to close
//--- input DeMarker parameter
input bool                 InpOpenDeM           = false;          // DeM: use DeM to open
input bool                 InpCloseDeM          = false;          // DeM: use DeM to close
input int                  Inp_DeM_ma_period    = 14;             // DeM: averaging period 
input double               Inp_Dem_Level_Up     = 0.7;            // DeM: Level Up 
input double               Inp_Dem_Level_Down   = 0.3;            // DeM: Level Down 
//--- input AO parameters
input bool                 InpOpenAO            = false;          // AO: use AO to open
input bool                 InpCloseAO           = false;          // AO: use AO to close
//---
input ulong    m_magic=10224936;             // magic number
//---
ulong  m_slippage=10;                        // slippage
double ExtStopLoss=0.0;
double ExtTakeProfit=0.0;
int    handle_iCCI;                          // variable for storing the handle of the iCCI indicator
int    handle_iMA_1;                         // variable for storing the handle of the iMA indicator 
int    handle_iMA_2;                         // variable for storing the handle of the iMA indicator 
int    handle_iStochastic;                   // variable for storing the handle of the iStochastic indicator
int    handle_iAC;                           // variable for storing the handle of the iAC indicator
int    handle_iDeMarker;                     // variable for storing the handle of the iDeMarker indicator
int    handle_iAO;                           // variable for storing the handle of the iAO indicator
double m_adjusted_point;                     // point value adjusted for 3 or 5 points
bool   m_last_deal_loss=false;
double m_last_deal_lot=0.0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   m_last_deal_loss=false;
//---
   if(!m_symbol.Name(Symbol())) // sets symbol name
      return(INIT_FAILED);
   RefreshRates();
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

   ExtStopLoss       = InpStopLoss        * m_adjusted_point;
   ExtTakeProfit     = InpTakeProfit      * m_adjusted_point;
//--- check the input parameter "Lots"
   string err_text="";
   if(!CheckVolumeValue(InpLots,err_text))
     {
      //--- when testing, we will only output to the log about incorrect input parameters
      if(MQLInfoInteger(MQL_TESTER))
        {
         Print(__FUNCTION__,", ERROR: ",err_text);
         return(INIT_FAILED);
        }
      else // if the Expert Advisor is run on the chart, tell the user about the error
        {
         Alert(__FUNCTION__,", ERROR: ",err_text);
         return(INIT_PARAMETERS_INCORRECT);
        }
     }
   if(InpOpenCCI || InpCloseCCI)
     {
      //--- create handle of the indicator iCCI
      handle_iCCI=iCCI(m_symbol.Name(),Period(),Inp_CCI_ma_period,Inp_CCI_applied_price);
      //--- if the handle is not created 
      if(handle_iCCI==INVALID_HANDLE)
        {
         //--- tell about the failure and output the error code 
         PrintFormat("Failed to create handle of the iCCI indicator for the symbol %s/%s, error code %d",
                     m_symbol.Name(),
                     EnumToString(Period()),
                     GetLastError());
         //--- the indicator is stopped early 
         return(INIT_FAILED);
        }
     }
   if(InpOpenMA || InpCloseMA)
     {
      //--- create handle of the indicator iMA
      handle_iMA_1=iMA(m_symbol.Name(),Period(),Inp_MA1_ma_period,Inp_MA_ma_shift,
                       Inp_MA_ma_method,Inp_MA_applied_price);
      //--- if the handle is not created 
      if(handle_iMA_1==INVALID_HANDLE)
        {
         //--- tell about the failure and output the error code 
         PrintFormat("Failed to create handle of the iMA indicator (\"MA1\") for the symbol %s/%s, error code %d",
                     m_symbol.Name(),
                     EnumToString(Period()),
                     GetLastError());
         //--- the indicator is stopped early 
         return(INIT_FAILED);
        }
      //--- create handle of the indicator iMA
      handle_iMA_2=iMA(m_symbol.Name(),Period(),Inp_MA2_ma_period,Inp_MA_ma_shift,
                       Inp_MA_ma_method,Inp_MA_applied_price);
      //--- if the handle is not created 
      if(handle_iMA_2==INVALID_HANDLE)
        {
         //--- tell about the failure and output the error code 
         PrintFormat("Failed to create handle of the iMA indicator (\"MA2\") for the symbol %s/%s, error code %d",
                     m_symbol.Name(),
                     EnumToString(Period()),
                     GetLastError());
         //--- the indicator is stopped early 
         return(INIT_FAILED);
        }
     }
   if(InpOpenSTO || InpCloseSTO)
     {
      //--- create handle of the indicator iStochastic
      handle_iStochastic=iStochastic(m_symbol.Name(),Period(),Inp_STO_Kperiod,
                                     Inp_STO_Dperiod,Inp_STO_slowing,Inp_STO_ma_method,Inp_STO_price_field);
      //--- if the handle is not created 
      if(handle_iStochastic==INVALID_HANDLE)
        {
         //--- tell about the failure and output the error code 
         PrintFormat("Failed to create handle of the iStochastic indicator for the symbol %s/%s, error code %d",
                     m_symbol.Name(),
                     EnumToString(Period()),
                     GetLastError());
         //--- the indicator is stopped early 
         return(INIT_FAILED);
        }
     }
   if(InpOpenAC || InpCloseAC)
     {
      //--- create handle of the indicator iAC
      handle_iAC=iAC(m_symbol.Name(),Period());
      //--- if the handle is not created 
      if(handle_iAC==INVALID_HANDLE)
        {
         //--- tell about the failure and output the error code 
         PrintFormat("Failed to create handle of the iAC indicator for the symbol %s/%s, error code %d",
                     m_symbol.Name(),
                     EnumToString(Period()),
                     GetLastError());
         //--- the indicator is stopped early 
         return(INIT_FAILED);
        }
     }
   if(InpOpenDeM || InpCloseDeM)
     {
      //--- create handle of the indicator iDeMarker
      handle_iDeMarker=iDeMarker(m_symbol.Name(),Period(),Inp_DeM_ma_period);
      //--- if the handle is not created 
      if(handle_iDeMarker==INVALID_HANDLE)
        {
         //--- tell about the failure and output the error code 
         PrintFormat("Failed to create handle of the iDeMarker indicator for the symbol %s/%s, error code %d",
                     m_symbol.Name(),
                     EnumToString(Period()),
                     GetLastError());
         //--- the indicator is stopped early 
         return(INIT_FAILED);
        }
     }
   if(InpOpenAO || InpCloseAO)
     {
      //--- create handle of the indicator iAO
      handle_iAO=iAO(m_symbol.Name(),Period());
      //--- if the handle is not created 
      if(handle_iAO==INVALID_HANDLE)
        {
         //--- tell about the failure and output the error code 
         PrintFormat("Failed to create handle of the iAO indicator for the symbol %s/%s, error code %d",
                     m_symbol.Name(),
                     EnumToString(Period()),
                     GetLastError());
         //--- the indicator is stopped early 
         return(INIT_FAILED);
        }
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
   if(!RefreshRates())
     {
      PrevBars=0;
      return;
     }
//---
   bool cci_buy   = false, cci_sell = false, close_cci_buy  = false, close_cci_sell = false;
   bool ma_buy    = false, ma_sell  = false, close_ma_sell  = false, close_ma_buy   = false;
   bool sto_buy   = false, sto_sell = false, close_sto_buy  = false, close_sto_sell = false;
   bool ac_buy    = false, ac_sell  = false, close_ac_buy   = false, close_ac_sell  = false;
   bool dem_buy   = false, dem_sell = false, close_dem_buy  = false, close_dem_sell = false;
   bool ao_buy    = false, ao_sell  = false, close_ao_buy   = false, close_ao_sell  = false;
//--- CCI 
   if(InpOpenCCI || InpCloseCCI)
     {
      double cci[];
      ArraySetAsSeries(cci,true);
      int buffer=0,start_pos=0,count=3;
      if(iGetArray(handle_iCCI,buffer,start_pos,count,cci))
        {
         if(InpOpenCCI)
           {
            if(cci[1]<-100.0)
               cci_buy=true;
            else if(cci[1]>100.0)
               cci_sell=true;
           }
         if(InpCloseCCI)
           {
            if(cci[1]<-100.0)
               close_cci_sell=true;
            else if(cci[1]>100.0)
               close_cci_buy=true;
           }
        }
     }
//--- Moving Average
   if(InpOpenMA || InpCloseMA)
     {
      double ma_1[],ma_2[];
      ArraySetAsSeries(ma_1,true);
      ArraySetAsSeries(ma_2,true);
      int buffer=0,start_pos=0,count=3;
      if(iGetArray(handle_iMA_1,buffer,start_pos,count,ma_1) && iGetArray(handle_iMA_2,buffer,start_pos,count,ma_2))
        {
         if(InpOpenMA==true)
           {
            if(ma_1[1]>ma_2[1])
               ma_buy=true;
            else if(ma_1[1]<ma_2[1])
               ma_sell=true;
           }
         if(InpCloseMA==true)
           {
            if(ma_1[1]>ma_2[1])
               close_ma_sell=true;
            if(ma_1[1]<ma_2[1])
               close_ma_buy=true;
           }
        }
     }
//--- Stochastic
   if(InpOpenSTO || InpCloseSTO)
     {
      double sto_main[],sto_signal[];
      ArraySetAsSeries(sto_main,true);
      ArraySetAsSeries(sto_signal,true);
      int start_pos=0,count=3;
      if(iGetArray(handle_iStochastic,MAIN_LINE,start_pos,count,sto_main) && iGetArray(handle_iStochastic,SIGNAL_LINE,start_pos,count,sto_signal))
        {
         if(InpOpenSTO)
           {
            if(sto_main[1]>sto_signal[1] && sto_signal[1]<Inp_STO_Level_Up)
               sto_buy=true;
            else if(sto_main[1]<sto_signal[1] && sto_signal[1]>Inp_STO_Level_Down)
               sto_sell=true;
           }
         if(InpCloseSTO)
           {
            if(sto_main[1]>sto_signal[1] && sto_signal[1]<Inp_STO_Level_Up)
               close_sto_sell=true;
            else if(sto_main[1]<sto_signal[1] && sto_signal[1]>Inp_STO_Level_Down)
               close_sto_buy=true;
           }
        }
     }
//--- Accelerator 
   if(InpOpenAC || InpCloseAC)
     {
      double ac[];
      ArraySetAsSeries(ac,true);
      int buffer=0,start_pos=0,count=4;
      if(iGetArray(handle_iAC,buffer,start_pos,count,ac))
        {
         if(InpOpenAC)
           {
            if((ac[0]>=0.0 && ac[0]>ac[1] && ac[1]>ac[2]) || (ac[0]<=0.0 && ac[0]>ac[1] && ac[1]>ac[2] && ac[2]>ac[3]))
               ac_buy=true;
            else if((ac[0]<=0.0 && ac[0]<ac[1] && ac[1]<ac[2]) || (ac[0]>=0.0 && ac[0]<ac[1] && ac[1]<ac[2] && ac[2]<ac[3]))
                            ac_sell=true;
           }
         if(InpCloseAC)
           {
            if((ac[0]>=0 && ac[0]>ac[1] && ac[1]>ac[2]) || (ac[0]<=0 && ac[0]>ac[1] && ac[1]>ac[2] && ac[2]>ac[3]))
               close_ac_sell=true;
            else if((ac[0]<=0 && ac[0]<ac[1] && ac[1]<ac[2]) || (ac[0]>=0 && ac[0]<ac[1] && ac[1]<ac[2] && ac[2]<ac[3]))
                            close_ac_buy=true;
           }
        }
     }
//--- Demarker
   if(InpOpenDeM || InpCloseDeM)
     {
      double dem[];
      ArraySetAsSeries(dem,true);
      int buffer=0,start_pos=0,count=3;
      if(iGetArray(handle_iDeMarker,buffer,start_pos,count,dem))
        {
         if(InpOpenDeM)
           {
            if(dem[0]<Inp_Dem_Level_Down)
               dem_buy=true;
            else if(dem[0]>Inp_Dem_Level_Up)
               dem_sell=true;
           }
         if(InpCloseDeM)
           {
            if(dem[0]<Inp_Dem_Level_Down)
               close_dem_sell=true;
            else if(dem[0]>Inp_Dem_Level_Up)
               close_dem_buy=true;
           }
        }
     }
//--- Awesome 
   if(InpOpenAO || InpCloseAO)
     {
      double ao[];
      ArraySetAsSeries(ao,true);
      int buffer=0,start_pos=0,count=3;
      if(iGetArray(handle_iAO,buffer,start_pos,count,ao))
        {
         if(InpOpenAO)
           {
            if(ao[0]>ao[1])
               ao_buy=true;
            else if(ao[0]<ao[1])
               ao_sell=true;
           }
         if(InpCloseAO)
           {
            if(ao[0]>ao[1])
               close_ao_sell=true;
            else if(ao[0]<ao[1])
               close_ao_buy=true;
           }
        }
     }
//---
   bool open_buy=false,open_sell=false,close_buy=false,close_sell=false;
//--- check open buy
   if((cci_buy || !InpOpenCCI) && (ma_buy || !InpOpenMA) && (sto_buy || !InpOpenSTO) && 
      (ac_buy || !InpOpenAC) && (dem_buy || !InpOpenDeM) && (ao_buy || !InpOpenAO))
     {
      open_buy=true;
     }
//--- check open sell
   if((cci_sell || !InpOpenCCI) && (ma_sell || !InpOpenMA) && (sto_sell || !InpOpenSTO) && 
      (ac_sell || !InpOpenAC) && (dem_sell || !InpOpenDeM) && (ao_sell || !InpOpenAO))
     {
      open_sell=true;
     }
//--- check close buy
   if((close_cci_buy || !InpCloseCCI) && (close_ma_buy || !InpCloseMA) && (close_sto_buy || !InpCloseSTO) && 
      (close_ac_buy || !InpCloseAC) && (close_dem_buy || !InpCloseDeM) && (close_ao_buy || !InpCloseAO))
     {
      close_buy=true;
     }
//--- check close sell
   if((close_cci_sell || !InpCloseCCI) && (close_ma_sell || !InpCloseMA) && (close_sto_sell || !InpCloseSTO) && 
      (close_ac_sell || !InpCloseAC) && (close_dem_sell || !InpCloseDeM) && (close_ao_sell || !InpCloseAO))
     {
      close_sell=true;
     }
//---
   if(!IsPositionExists())
     {
      if(open_buy || open_sell)
        {
         //--- check Freeze and Stops levels
/*
   Type of order/position  |  Activation price  |  Check
   ------------------------|--------------------|--------------------------------------------
   Buy Limit order         |  Ask               |  Ask-OpenPrice  >= SYMBOL_TRADE_FREEZE_LEVEL
   Buy Stop order          |  Ask	            |  OpenPrice-Ask  >= SYMBOL_TRADE_FREEZE_LEVEL
   Sell Limit order        |  Bid	            |  OpenPrice-Bid  >= SYMBOL_TRADE_FREEZE_LEVEL
   Sell Stop order	      |  Bid	            |  Bid-OpenPrice  >= SYMBOL_TRADE_FREEZE_LEVEL
   Buy position            |  Bid	            |  TakeProfit-Bid >= SYMBOL_TRADE_FREEZE_LEVEL 
                           |                    |  Bid-StopLoss   >= SYMBOL_TRADE_FREEZE_LEVEL
   Sell position           |  Ask	            |  Ask-TakeProfit >= SYMBOL_TRADE_FREEZE_LEVEL
                           |                    |  StopLoss-Ask   >= SYMBOL_TRADE_FREEZE_LEVEL
*/
         if(!RefreshRates() || !m_symbol.Refresh())
           {
            PrevBars=0;
            return;
           }
         //--- FreezeLevel -> for pending order and modification
         double freeze_level=m_symbol.FreezeLevel()*m_symbol.Point();
         if(freeze_level==0.0)
            freeze_level=(m_symbol.Ask()-m_symbol.Bid())*3.0;
         freeze_level*=1.1;
         //--- StopsLevel -> for TakeProfit and StopLoss
         double stop_level=m_symbol.StopsLevel()*m_symbol.Point();
         if(stop_level==0.0)
            stop_level=(m_symbol.Ask()-m_symbol.Bid())*3.0;
         stop_level*=1.1;

         if(freeze_level<=0.0 || stop_level<=0.0)
           {
            PrevBars=0;
            return;
           }
         if(open_buy)
           {
            if(close_buy)
               return; // ERROR!
            double price=m_symbol.Ask();
            double sl=(InpStopLoss==0)?0.0:price-ExtStopLoss;
            double tp=(InpTakeProfit==0)?0.0:price+ExtTakeProfit;
            if(((sl!=0 && ExtStopLoss>=stop_level) || sl==0.0) && ((tp!=0 && ExtTakeProfit>=stop_level) || tp==0.0))
              {
               OpenBuy(sl,tp);
               return;
              }
           }
         if(open_sell)
           {
            if(close_sell)
               return; // ERROR!
            double price=m_symbol.Bid();
            double sl=(InpStopLoss==0)?0.0:price+ExtStopLoss;
            double tp=(InpTakeProfit==0)?0.0:price-ExtTakeProfit;
            if(((sl!=0 && ExtStopLoss>=stop_level) || sl==0.0) && ((tp!=0 && ExtTakeProfit>=stop_level) || tp==0.0))
              {
               OpenSell(sl,tp);
               return;
              }
           }
        }
     }
   else
     {
      if(close_buy)
        {
         if(close_sell)
            return; // ERROR!
         ClosePositions(POSITION_TYPE_BUY);
        }
      if(close_sell)
        {
         if(close_buy)
            return; // ERROR!
         ClosePositions(POSITION_TYPE_SELL);
        }
     }
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
      long     deal_ticket       =0;
      long     deal_order        =0;
      long     deal_time         =0;
      long     deal_time_msc     =0;
      long     deal_type         =-1;
      long     deal_entry        =-1;
      long     deal_magic        =0;
      long     deal_reason       =-1;
      long     deal_position_id  =0;
      double   deal_volume       =0.0;
      double   deal_price        =0.0;
      double   deal_commission   =0.0;
      double   deal_swap         =0.0;
      double   deal_profit       =0.0;
      string   deal_symbol       ="";
      string   deal_comment      ="";
      string   deal_external_id  ="";
      if(HistoryDealSelect(trans.deal))
        {
         deal_ticket       =HistoryDealGetInteger(trans.deal,DEAL_TICKET);
         deal_order        =HistoryDealGetInteger(trans.deal,DEAL_ORDER);
         deal_time         =HistoryDealGetInteger(trans.deal,DEAL_TIME);
         deal_time_msc     =HistoryDealGetInteger(trans.deal,DEAL_TIME_MSC);
         deal_type         =HistoryDealGetInteger(trans.deal,DEAL_TYPE);
         deal_entry        =HistoryDealGetInteger(trans.deal,DEAL_ENTRY);
         deal_magic        =HistoryDealGetInteger(trans.deal,DEAL_MAGIC);
         deal_reason       =HistoryDealGetInteger(trans.deal,DEAL_REASON);
         deal_position_id  =HistoryDealGetInteger(trans.deal,DEAL_POSITION_ID);

         deal_volume       =HistoryDealGetDouble(trans.deal,DEAL_VOLUME);
         deal_price        =HistoryDealGetDouble(trans.deal,DEAL_PRICE);
         deal_commission   =HistoryDealGetDouble(trans.deal,DEAL_COMMISSION);
         deal_swap         =HistoryDealGetDouble(trans.deal,DEAL_SWAP);
         deal_profit       =HistoryDealGetDouble(trans.deal,DEAL_PROFIT);

         deal_symbol       =HistoryDealGetString(trans.deal,DEAL_SYMBOL);
         deal_comment      =HistoryDealGetString(trans.deal,DEAL_COMMENT);
         deal_external_id  =HistoryDealGetString(trans.deal,DEAL_EXTERNAL_ID);
        }
      else
         return;
      if(deal_symbol==m_symbol.Name() && deal_magic==m_magic)
         if(deal_entry==DEAL_ENTRY_OUT)
           {
            if(deal_profit>0)
              {
               m_last_deal_loss=false;
               m_last_deal_lot=deal_volume;
              }
            else
              {
               m_last_deal_loss=true;
               m_last_deal_lot=deal_volume;
              }
           }
     }
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
//| Get value of buffers                                             |
//+------------------------------------------------------------------+
double iGetArray(const int handle,const int buffer,const int start_pos,const int count,double &arr_buffer[])
  {
   bool result=true;
   if(!ArrayIsDynamic(arr_buffer))
     {
      Print("This a no dynamic array!");
      return(false);
     }
   ArrayFree(arr_buffer);
//--- reset error code 
   ResetLastError();
//--- fill a part of the iBands array with values from the indicator buffer
   int copied=CopyBuffer(handle,buffer,start_pos,count,arr_buffer);
   if(copied!=count)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(false);
     }
   return(result);
  }
//+------------------------------------------------------------------+
//| Is position exists                                               |
//+------------------------------------------------------------------+
bool IsPositionExists(void)
  {
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            return(true);
//---
   return(false);
  }
//+------------------------------------------------------------------+
//| Close positions                                                  |
//+------------------------------------------------------------------+
void ClosePositions(const ENUM_POSITION_TYPE pos_type)
  {
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of current positions
      if(m_position.SelectByIndex(i))     // selects the position by index for further access to its properties
         if(m_position.Symbol()==Symbol() && m_position.Magic()==m_magic)
            if(m_position.PositionType()==pos_type) // gets the position type
               m_trade.PositionClose(m_position.Ticket()); // close a position by the specified symbol
  }
//+------------------------------------------------------------------+
//| Open Buy position                                                |
//+------------------------------------------------------------------+
void OpenBuy(double sl,double tp)
  {
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);

   double long_lot=(m_last_deal_loss)?LotCheck(m_last_deal_lot*InpLotMultiply):InpLots;
   if(long_lot==0.0)
      return;
//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double free_margin_check= m_account.FreeMarginCheck(m_symbol.Name(),ORDER_TYPE_BUY,long_lot,m_symbol.Ask());
   double margin_check     = m_account.MarginCheck(m_symbol.Name(),ORDER_TYPE_SELL,long_lot,m_symbol.Bid());
   if(free_margin_check>margin_check)
     {
      if(m_trade.Buy(long_lot,m_symbol.Name(),m_symbol.Ask(),sl,tp))
        {
         if(m_trade.ResultDeal()==0)
           {
            Print("#1 Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
            PrintResultTrade(m_trade,m_symbol);
           }
         else
           {
            Print("#2 Buy -> true. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
            PrintResultTrade(m_trade,m_symbol);
           }
        }
      else
        {
         Print("#3 Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
               ", description of result: ",m_trade.ResultRetcodeDescription());
         PrintResultTrade(m_trade,m_symbol);
        }
     }
   else
     {
      Print(__FUNCTION__,", ERROR: method CAccountInfo::FreeMarginCheck returned the value ",DoubleToString(free_margin_check,2));
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

   double short_lot=(m_last_deal_loss)?LotCheck(m_last_deal_lot*InpLotMultiply):InpLots;
   if(short_lot==0.0)
      return;
//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double free_margin_check= m_account.FreeMarginCheck(m_symbol.Name(),ORDER_TYPE_SELL,short_lot,m_symbol.Bid());
   double margin_check     = m_account.MarginCheck(m_symbol.Name(),ORDER_TYPE_SELL,short_lot,m_symbol.Bid());
   if(free_margin_check>margin_check)
     {
      if(m_trade.Sell(short_lot,m_symbol.Name(),m_symbol.Bid(),sl,tp))
        {
         if(m_trade.ResultDeal()==0)
           {
            Print("#1 Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
            PrintResultTrade(m_trade,m_symbol);
           }
         else
           {
            Print("#2 Sell -> true. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
            PrintResultTrade(m_trade,m_symbol);
           }
        }
      else
        {
         Print("#3 Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
               ", description of result: ",m_trade.ResultRetcodeDescription());
         PrintResultTrade(m_trade,m_symbol);
        }
     }
   else
     {
      Print(__FUNCTION__,", ERROR: method CAccountInfo::FreeMarginCheck returned the value ",DoubleToString(free_margin_check,2));
      return;
     }
//---
  }
//+------------------------------------------------------------------+
//| Print CTrade result                                              |
//+------------------------------------------------------------------+
void PrintResultTrade(CTrade &trade,CSymbolInfo &symbol)
  {
   Print("File: ",__FILE__,", symbol: ",m_symbol.Name());
   Print("Code of request result: "+IntegerToString(trade.ResultRetcode()));
   Print("code of request result as a string: "+trade.ResultRetcodeDescription());
   Print("Deal ticket: "+IntegerToString(trade.ResultDeal()));
   Print("Order ticket: "+IntegerToString(trade.ResultOrder()));
   Print("Volume of deal or order: "+DoubleToString(trade.ResultVolume(),2));
   Print("Price, confirmed by broker: "+DoubleToString(trade.ResultPrice(),symbol.Digits()));
   Print("Current bid price: "+DoubleToString(symbol.Bid(),symbol.Digits())+" (the requote): "+DoubleToString(trade.ResultBid(),symbol.Digits()));
   Print("Current ask price: "+DoubleToString(symbol.Ask(),symbol.Digits())+" (the requote): "+DoubleToString(trade.ResultAsk(),symbol.Digits()));
   Print("Broker comment: "+trade.ResultComment());
  }
//+------------------------------------------------------------------+
