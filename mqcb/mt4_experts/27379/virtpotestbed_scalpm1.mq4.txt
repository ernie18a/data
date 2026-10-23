//+-------------------------------------------------------------------+
//|                                         VirtPOTestBed_Scalp.mq4   |
//|                                         copyright 2019 R Poster   |
//|                                                                   |
//+-------------------------------------------------------------------+
//+-------------------------------------------------------------------+
//|  SingleCurrency EA                                                |
//|  Use EURUSD Chart M1                                              |
//|  Triggers:                                                        |
//|  Set up Buy & Sell Mkt Orders from Virtual Pend Orders            |
//+-------------------------------------------------------------------+
// EURUSD M1
// Use Class CPO from mqh file to simulate Pending Order operation
// vs 2 Option to execute PO at tick level or close bar level
// vs 2 Use Stochastic for trigger and threshold 
// vs 2 Use Trend filtering
#property copyright "RAP"
#define NAME		"VirtPOTestBed_Scalp" 
#property link      "http://www.metatrader.org" 
#property strict
#include <WinUser32.mqh>
#include <VirtPndOrds.mqh>
//
//---------------------------------------------------------------------
                                         //
// ---- Global variables ----------------

double       PipValue;
int          magic_number;
double       _point,_bid,_ask,_Low,_High,_close,_open,_spread;
int          _digits;
int          _period;
string       _symbol;
int          slpg=3;
double       MULT;
static int   Ticket_Ctr,Trigger_ID;
int          Cur_Ticket_Num,cantype;
bool         startInit;
int          BarCtr;
int          trCtr;
double       spravg;
double       per = 1;
//---- Pending Order (PO) class objects (global) ---------------------------------
CPO *VPOUp;
CPO *VPODn;
//---------------- input parameters ------------------------------------
// ---------- Trigger  ----------------------------
input string    ActvSymbol = "EURUSD";
input int       MagicNumber  = 10001;
// -------- Trigger  Data  ---------------------
input string    Note1          = " --- PO Trigger Data ---";
input bool      TickLevel     = true;   // Tick Lvl (vs Bar Cls) PO exe 
input double    POThreshold    =  2.;   // Threshold for PO (pips)
input double    POTimeLim      =  15;   // PO Expiration Time(mins)
 
input double    Spread_Max     = 0.5;   // Max Spread 
input double    VolumeLim      =  90.;  // Volume Minimum
input int       VolatPer       = 100;   // Volatility Period
input double    VolatLim       = 0.5;   // Volatility Limit
input double    BB_LoLim       =  8.;   // BB Spread Lower Limit
input double    BB_HiLim       = 27.;   // BB Spread Upper Limit
input double    LastBarLim     =  5.;   // Limit of last bar change
// trend finding data
input string    Title2=" --- Trend Finding Data ---";
input int       SMAFastPer     =  2;   // SMA Fast Period
input int       SMASloPer      = 34;    // SMA SLow Period
input double    SMADiff        =  3.;   // SMA Difference
// Stochastic data
input string    Title3=" --- PO, MO Stochastic Trigger Data ---";
input int       kStoc          =   7;   // K1 Stoc
input int       dStoc          =   3;   // K2 Stoc
input int       sStoc          =   7;   // K3 Stoc
input double    Stoc_Lo_Set    =  28.;  // Pnd Ord Stoc Buy Limit
input double    Stoc_Lo_Go     =  46.;  // Mkt Ord Stoc Thrshld Buy Limit
// Money Mgmt
input string    Title4        =  " --- Money Management ---";
input double    Lots          = 0.1;  
input double    MaxLots       = 4.0;
//
input double    TakeProfit    =  12.;    // Take Profit
input double    StopLoss      =   5.;    // Stop Loss 
input double    TrailingStop  =   0.;    // Trailing Stop
//  
input string    Title5        = " --- Time Filters ---";
input bool      DayNoTrade    = true;
input int       Day1          = 99;  
input int       Day2          = 99; 
input int       entryhour     =  4;   // Entry Hour
input int       openhours     = 18;   // Number of Open Hours
input int       FridayEndHour = 10;  
//
input int       NumOpenOrders = 1; // Number of Open Orders (this Symbol)
input int       TotOpenOrders = 8;  // Total Number of Open Orders
// 
// --- Close Trade ------------------
input string    Title6 = " --- Close Trade --- "; 
// closetime  default 5000
input double    CloseTimeMins   = 25.; // Close Time (mins)
// ProfType = 0 close all, = 1 close Positive return, = 2 Negative return
input int       ProfitType      =  0; //  ProfitType (0:all, 1:win, 2:lose)
//
//
//------------------------------------------------------------------------
//                  Main Functions
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   double BS_Thrsh,pnt;
   // init globals
   _period = Period(); // set active timeframe
   _symbol=Symbol();   // set symbol
   _point = MarketInfo(_symbol,MODE_POINT);
   _digits = int(MarketInfo(_symbol,MODE_DIGITS));
    MULT=1.0;
   if(_digits==5 || _digits==3)
     MULT=10.0;
    magic_number=MagicNumber;  
//
   startInit=true;   
   PipValue=PipValues(_symbol); 
//   
   BarCtr = 0;
   trCtr = 0;
   spravg=0;
   Ticket_Ctr=0;
   Cur_Ticket_Num=0;
   if(_period==PERIOD_M1)  per=1;
   if(_period==PERIOD_M5)  per=5;
   if(_period==PERIOD_M15) per=15;
   if(_period==PERIOD_H1)  per=60;
   //
   if(ActvSymbol !=_symbol) Alert(" Wrong Symbol ",ActvSymbol);
   //-------------------------------------------------------------------
 // Init of class objects - must first create object, then have virtual close
    pnt = MULT*_point;
    // Buy Stop
    BS_Thrsh = _bid  + POThreshold*pnt;  // Buy Stop Thresold (use bid)
    VPOUp = new CPO(_symbol,ORD_TYPE_BUYSTOP,slpg,Lots, CurTime(),magic_number, 
                      " Buy Stop",BS_Thrsh,StopLoss,TakeProfit, POTimeLim);         
  // Sell Stop
    BS_Thrsh = _bid - POThreshold*pnt;  // Sell Stop Thresold (use bid)
    VPODn = new CPO(_symbol,ORD_TYPE_SELLSTOP,slpg,Lots, CurTime(),magic_number, 
                       " Sell Stop",BS_Thrsh,StopLoss,TakeProfit, POTimeLim);         
    VPOUp.CloseVirtPO();  // virtual close
    VPODn.CloseVirtPO(); 
//------------------------------------------------------------------
   return(INIT_SUCCEEDED);
  } //--------------------End init ---------------------------------------------
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   Print(" Active Symbol  ",Symbol(),"  Period ",Period());
   Print(" Broker Factor*_point =   ",_point*MULT,"  _point =  ",100000.*_point);
   Print(" Spreads ",_symbol,"  ",MarketInfo(_symbol,MODE_SPREAD)," Tic Value  ",
            10.*MarketInfo(_symbol,MODE_TICKVALUE));
   Print("  Lotsize  ",MarketInfo(_symbol,MODE_LOTSIZE));
   Print("  MinLot  ",MarketInfo(_symbol,MODE_MINLOT));
   Print("  LotStep  ",MarketInfo(_symbol,MODE_LOTSTEP));
   Print("  MaxLot  ",MarketInfo(_symbol,MODE_MAXLOT));
   Print("  FreezeLevel  ",MarketInfo(_symbol,MODE_FREEZELEVEL));
   Print("  StopLevel  ",MarketInfo(_symbol,MODE_STOPLEVEL));
   spravg=spravg/BarCtr;
   Print(" Average Spread =  ",NormalizeDouble(spravg,2));
   Print(" Number of Triggers ",trCtr);
     // cleanup class objects
   delete (VPOUp);
   delete (VPODn);
  }//------------------------------------------------------------------
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
void OnTick()
  {
   datetime  bartime_previous;
   static datetime bartime_current;
   int newperiod;
   bool Overtime_Close;
   int  MaxOrders;
   double GpTime;
   int TicketUp,TicketDn;
   bool tBuy,tSell;
   bool Set_Go; // Set_Go = true for PO creation; =false for Threshold test for Mkt Ord
  
// -- set up new bar test ---------------------------
   newperiod=0;
   bartime_previous= bartime_current;
   bartime_current =iTime(_symbol,_period,0);
   if(bartime_current!=bartime_previous) newperiod=1;
   TicketUp=0;
   TicketDn=0;
   tBuy=false;
   tSell=false;
   // Set_Go: Set mode (true) to make PndOrd, Go mode (false) to make MktOrd
   Set_Go=false; // trigger for market order (Set_Go=false=>Go mode)
   _bid =    MarketInfo(_symbol,MODE_BID);
   _ask =    MarketInfo(_symbol,MODE_ASK);   
   _Low  =   MarketInfo(_symbol,MODE_LOW);
   _High =   MarketInfo(_symbol,MODE_HIGH);
   _spread = MarketInfo(_symbol,MODE_SPREAD)/MULT;

//------------------------  Start of new Bar -----------------------------------------------    
   if(newperiod==1)
     {
     
      MaxOrders = NumOpenOrders;
      cantype=1;
      GpTime=99999.;  
  //             
      BarCtr += 1;
      spravg += _spread;
 // --- Check execution threshold of virtual pending order
 //     Create market order if indicator and price exceed thresholds
      if(!TickLevel) // end of bar processing
       {
        TrigSel(tBuy,tSell,Stoc_Lo_Go,Set_Go); // call trigger for Go mode - check for exe of PO
        if(VPOUp.IsOpen()&& tBuy)  TicketUp = VPOUp.Tick(_bid,_spread); // function expects bid price
        if(VPODn.IsOpen()&& tSell) TicketDn = VPODn.Tick(_bid,_spread); // function expects bid price
        Sleep(10);
        RefreshRates();
      }
 //-----------------  Trigger  -----------------------------------------------------  
 // call trigger when have no open mkt orders and no open virt pend orders
      if(NumOpnOrds()==0 && !VPOUp.IsOpen() && !VPODn.IsOpen() )ScalpTrigger(); 
//  ---------------------------------------------------------------------------
      startInit=false;
     } // -------------------- end of if new bar ---------------------------------------------------------                                                                          
// -------------------------------------------------------------------------------------------------------
// ---------------------------  every tic processing -----------------------------------------------------
   _bid =    MarketInfo(_symbol,MODE_BID);
   _ask =    MarketInfo(_symbol,MODE_ASK);
   _spread = MarketInfo(_symbol,MODE_SPREAD)/MULT; 
 //  
 // ----------  Manage virtual pending orders --------------------------------
   //     Check for expired Virt PO
   if(VPOUp.IsOpen()) VPOUp.TimeClosePO(CurTime()); // delete PO when past expiration time
   if(VPODn.IsOpen()) VPODn.TimeClosePO(CurTime()); // delete PO when past expiration time
  //    Check execution threshold of virtual pending order
  if(TickLevel)
   {
    TrigSel(tBuy,tSell,Stoc_Lo_Go,Set_Go);
    // check threshold cross - open market order
    if(VPOUp.IsOpen() && tBuy)  TicketUp=VPOUp.Tick(_bid,_spread); // function expects bid price
    if(VPODn.IsOpen() && tSell) TicketDn=VPODn.Tick(_bid,_spread); // function expects bid price
    Sleep(10);
    RefreshRates();
   }
//--------------------------------------------------------------------------------
   if(NumOpnOrds()==0 ) return;
// --------  Have Open Market Order --------------
 //  ----  Close ALL  open POs -----
   if(VPOUp.IsOpen()) VPOUp.CloseVirtPO();
   if(VPODn.IsOpen()) VPODn.CloseVirtPO();
 //------------------  end manage virt PO ----------------------------------------
 //------ Close Mkt Trades by Timer   
 // check time to close trade          
   if(CloseTimeMins<5000. && CloseTimeMins>0.) // disable if =0.
    {
     Overtime_Close=CloseOvertime2(CloseTimeMins,ProfitType); // close all overtime trades     
    }
// ----------  Manage trailing stop --------------------------------------      
   if(TrailingStop>0. && NumOpnOrds()>0) ManageTrlStop(TrailingStop);
   return;
  }
//+------------------- end of OnTick() ---------------------------------------------------------+
//
//+---------------------------------------------------------------------------------------------+
//|                       Application Functions                                                 |
//+---------------------------------------------------------------------------------------------+
 void TrigSel(bool &tBuy,bool &tSell, double StocLim, bool Set_Go)
  {
   // Set_Go: Set (true) to make PndOrd, Go (false) to make MktOrd
   double Stoc1_Val,Stoc2_Val;
   tBuy=false;
   tSell=false;
   //
  // Pend Order creation only done on start of new bar
   if(Set_Go) // Set mode (creat Pend Order)  look for stoc crossing
    {
     Stoc1_Val=iStochastic(_symbol,0,kStoc,dStoc,sStoc,MODE_SMA,0,MODE_MAIN, 1);
     Stoc2_Val=iStochastic(_symbol,0,kStoc,dStoc,sStoc,MODE_SMA,0,MODE_MAIN, 2);
     if(Stoc2_Val<StocLim && Stoc1_Val>StocLim)               tBuy=true;
     if(Stoc2_Val>(100.-StocLim) && Stoc1_Val<(100.-StocLim)) tSell=true;
    }
   //
  // Market Order executed either at new bar or at tick level
   if(!Set_Go) // Go mode (Pnd Order --> Market Order) look for exceeding stoc threshold
    {
     Stoc1_Val=iStochastic(_symbol,0,kStoc,dStoc,sStoc,MODE_SMA,0,MODE_MAIN, 0);
     if(Stoc1_Val>StocLim)         tBuy=true;
     if(Stoc1_Val<(100.-StocLim))  tSell=true;
    }
   return;
  }
  //----------------------------------------------------------
  void IsTrend(bool &TrndUp, bool &TrndDn)
   {
    double diff;
    //
    TrndUp=false;
    TrndDn=false;
    //
    diff = (iMA(_symbol,PERIOD_M1,SMAFastPer,0,MODE_SMA,PRICE_CLOSE,1)-
            iMA(_symbol,PERIOD_M1,SMASloPer,0,MODE_SMA,PRICE_CLOSE,1))/(MULT*_point);
    if(diff> SMADiff) TrndUp=true;
    if(diff<-SMADiff) TrndDn=true;  
    return;
   }
 //+---------------------------------------------------------+
//|  Pending Order Trigger - Volatility
//+----------------------------------------------------------+
 void ScalpTrigger()
  {
   double pnt;
   double Volm;
   bool tBuy,tSell;
   double BS_Thrsh;
   double LastBarUp,LastBarDn;
   double VolAbs,VolUp,VolDn;
   double BB_Spread;
   int BBPeriod = 20;
   bool Set_Go;
   bool TrndUp, TrndDn;
//
   tSell=false;
   tBuy=false;  
  // Set_Go: use Set mode (Set_Go=true) to make PndOrd, Go mode (false) to make MktOrd
   Set_Go = true; // trigger for Pend Order
//   
   _spread =   MarketInfo(_symbol,MODE_SPREAD)/MULT;
   pnt = MULT*_point;
   //
   BB_Spread = (iBands(_symbol,0,BBPeriod,2,0,PRICE_CLOSE,MODE_UPPER,1) -
               iBands(_symbol,0,BBPeriod,2,0,PRICE_CLOSE,MODE_LOWER,1))/pnt;
   //  avg volume (ticks per minute)
   Volm = (1./per)*(iVolume(_symbol,0,1)+iVolume(_symbol,0,2)+iVolume(_symbol,0,3))/3.;
   GetVols(VolatPer, VolAbs,VolUp, VolDn);
   LastBarUp = (iHigh(_symbol,0,1)-iOpen(_symbol,0,1))/pnt;
   LastBarDn = (iOpen(_symbol,0,1)-iLow(_symbol,0,1))/pnt;
   //--------------------------------
   // Trigger for opening pending orders - set buy or sell flags
   if(Trig_Filters() && _spread<Spread_Max && Volm>VolumeLim && VolAbs>VolatLim && 
      BB_Spread>BB_LoLim && BB_Spread<BB_HiLim )
    {
     TrigSel(tBuy,tSell,Stoc_Lo_Set,Set_Go); // Set mode for PO creation
     IsTrend(TrndUp, TrndDn);
   // Buy Stop
     if(LastBarUp<LastBarLim && tBuy && (TrndDn || TrndUp))
  //   if(LastBarUp<LastBarLim && tBuy)
      {
       delete (VPOUp); // clear old virtual POs before making new one
       BS_Thrsh = _bid  + POThreshold*pnt;  // Buy Stop Thresold (ask)
       VPOUp = new CPO(_symbol,ORD_TYPE_BUYSTOP,slpg,Lots, CurTime(),magic_number, 
                       " Buy Stop",BS_Thrsh,StopLoss,TakeProfit, POTimeLim); 
      }        
  // Sell Stop
     if(LastBarDn<LastBarLim && tSell && (TrndDn || TrndUp))
 //    if(LastBarDn<LastBarLim && tSell )
      {
        delete (VPODn); // clear old virtual POs before making new one
        BS_Thrsh = _bid - POThreshold*pnt;  // Sell Stop Thresold (bid)
        VPODn = new CPO(_symbol,ORD_TYPE_SELLSTOP,slpg,Lots, CurTime(),magic_number, 
                        " Sell Stop",BS_Thrsh,StopLoss,TakeProfit, POTimeLim); 
      }  
    } // 
   return;
  }
//-------------------------------------------------------------------
//----------------------------------------------------------------------
   bool Trig_Filters()
    {
     // Buy ot Sell signal is true upon entry
     // Set Buy and Sell signals to false if meet filter criteria
      datetime bartime_current;
      int hour_current,day_current,kBar;
      bool TradeOK;
      kBar = 0;
      //
      bartime_current =iTime(_symbol,PERIOD_M15,kBar);
      hour_current=TimeHour(bartime_current);
      day_current = TimeDayOfWeek(bartime_current);
      TradeOK = true;
      kBar = 0;
      if(DayNoTrade)
       {
        if(day_current==Day1 || day_current==Day2)
         {
          TradeOK = false;
         }
        if(hour_current>=FridayEndHour && day_current==5)
         {
          TradeOK = false;
         }
       }
      // ---------------- Hour of Day Filer -----------------------------------------    
      if(!HourRange(hour_current,entryhour,openhours)) TradeOK=false;        
      return(TradeOK);
    }
// -----------------------------------------------------------------------------------  
//+------------------------------------------------------------------+
//| compute Abs Volatility, Vol Up and Vol Down                      |
//+------------------------------------------------------------------+
  void GetVols(int VolPer, double &VolAbs,double &VolUp, double &VolDn)
   {
    double pr;
    int jj,ctrUp,ctrDn;
    //
    VolAbs = 0.;
    VolUp  = 0.;
    VolDn  = 0.;
    ctrUp  = 0;
    ctrDn  = 0;   
    //
    for(jj=0;jj<VolPer;jj++)
     {
      pr = (iClose(_symbol,0,jj+1)-iOpen(_symbol,0,jj+1))/(MULT*_point);
      VolAbs = VolAbs + MathAbs(pr);
      if(pr>=0.) 
       {
        VolUp = VolUp+pr;
        ctrUp +=1;
       }
      if(pr<0.) 
       {
        VolDn = VolDn+pr;
        ctrDn +=1;
       }
     } // ----------- loop ----------
     //
     VolAbs = VolAbs/VolPer; // Avg Abs Volatility 
     if(ctrUp>0) VolUp = VolUp/ctrUp;  // Up direction
     if(ctrDn>0) VolDn = MathAbs(VolDn/ctrDn); // Down direction
    return;
   }
   //-----------------------------------------------------------------------
// ******************* Trading Functions ***********************************************
//------------------------------------------------------------------------------------
//
void ManageTrlStop(double Trail_Stop)
//+--------------------------------------------------------------------+
//| Manage Trailing Stop                                               |
//| Globals: _point, MULT, _digits, _bid, _ask                         |
//+--------------------------------------------------------------------+
  {
   double  sl;
   int cnt,total;
   bool result;
//
   total  = OrdersTotal();
   for(cnt=0;cnt<total;cnt++)
     {
      result=OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
      if(!result) break;
      if(OrderType()<=OP_SELL && OrderSymbol()==_symbol && OrderMagicNumber()==magic_number)
        {
         if(OrderType()==OP_BUY) // ------- Manage long position ------
           {
            if(Trail_Stop>0.)
              {
               if((_bid-OrderOpenPrice())>MULT*_point*Trail_Stop)
                 {
                  if(((_bid-MULT*_point*Trail_Stop)-OrderStopLoss())>MULT*_point)
                    {
                     sl=NormalizeDouble(_bid-MULT*_point*Trail_Stop,_digits);
                     result=OrderModify(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),0,Green);
                    }
                 }
              }
           } // ---- end Trailing Stop for Buy  ------------------
         if(OrderType()==OP_SELL) // ------- Manage short position  -----
           {
            if(Trail_Stop>0.)
              {
               if((OrderOpenPrice()-_ask)>MULT*_point*Trail_Stop)
                 {
                  //     if(OrderStopLoss()>(_ask+MULT*_point*Trail_Stop))
                  if((OrderStopLoss()-(_ask+MULT*_point*Trail_Stop))>MULT*_point)
                    {
                     sl=NormalizeDouble(_ask+MULT*_point*Trail_Stop,_digits);
                     result=OrderModify(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),0,Red);
                    }
                 }
              } // ---- end Trailing Stop for Sell  ------------------  
           }//------------- if OrderType = Sell --------------------------------
        }// ---------------- if OrderType ------------------------------------------------  
     }//----------------- loop ----------------------------------------------------------------            
   return;
  }
// ----------------------- end Manage Trl Stop ----------------------------------------------   

int NumOpnOrds()
//+--------------------------------------------------------------------------+ 
//|  Return Number of Open Market Orders                                     |  
//+--------------------------------------------------------------------------+  
  {
   int cnt,NumOpn,total;
   NumOpn = 0;
   total  = OrdersTotal();
   for(cnt=0;cnt<total;cnt++)
     {
      if(OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES)==false) return(NumOpn);
      if(OrderType()<=OP_SELL && OrderSymbol()==_symbol && OrderMagicNumber()==magic_number)
        {
         NumOpn=NumOpn+1;
        }
     }
   return(NumOpn);
  }
// ----------------------------------------------------------------------------    
int NumOpnOrdsAll()
//+--------------------------------------------------------------------------+ 
//|  Return Number of Open Orders                                            |  
//+--------------------------------------------------------------------------+  
  {
   int cnt,NumOpn,total;
   NumOpn = 0;
   total  = OrdersTotal();
   for(cnt=0;cnt<total;cnt++)
     {
      if(OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES)==false) return(NumOpn);
      if(OrderType()<=OP_SELL)
        {
         NumOpn=NumOpn+1;
        }
     }
   return(NumOpn);
  }
//--------------------------------------------------------------------------------

//-------------------------------------------------------------------------------
  bool CloseOvertime2(double TimeLimit,int ProfType)
//+-------------------------------------------------------------------+
//|  Closes all trades if open past time lmit                         |
//| will be OK with FIFO rule because deletion is based on open time! |
//+-------------------------------------------------------------------+
  {
// ProfType = 0 close all, = 1 close Positive return, = 2 Negative return
   int total,cnt;
   double open_mins;
   double ord_profit,stop_Loss;
   datetime ord_time,cur_time;
   bool result;
   result = true;
   total=OrdersTotal();
   if(total == 0) return(result);
   if(ProfType<0 || ProfType>2) ProfType=0;
   for(cnt=total-1;cnt>=0;cnt--)
     {
      if(OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES))
       {
        if(OrderType()<=OP_SELL && OrderSymbol()==_symbol && OrderMagicNumber()==magic_number)
         {
          ord_profit= OrderProfit();
          stop_Loss = MathAbs(OrderOpenPrice()-OrderStopLoss())/(MULT*_point);
          ord_time = OrderOpenTime();
          cur_time = CurTime();
          open_mins=(cur_time-ord_time)/60.;
          if(OrderType()==OP_BUY && open_mins>=TimeLimit)
            { 
             if(ProfType==0)
              result = OrderClose(OrderTicket(),OrderLots(),_bid,3,Violet); // close long positions  
             if(ProfType==1 && ord_profit >= 0.) 
              result = OrderClose(OrderTicket(),OrderLots(),_bid,3,Violet); // close long positions 
             if(ProfType==2 && ord_profit < 0.) 
              result = OrderClose(OrderTicket(),OrderLots(),_bid,3,Violet); // close long positions          
            }
          if(OrderType()==OP_SELL && open_mins>=TimeLimit)
            {
             if(ProfType==0) 
              result = OrderClose(OrderTicket(),OrderLots(),_ask,3,Violet); // close short positions
             if(ProfType==1 && ord_profit >= 0.) 
              result = OrderClose(OrderTicket(),OrderLots(),_ask,3,Violet); // close short positions
             if(ProfType==2 && ord_profit < 0.) 
              result = OrderClose(OrderTicket(),OrderLots(),_ask,3,Violet); // close short positions
            }
          } // ---- end of if ordertype
        } // if OrderSelect
     }//  ----  end of loop ----------------
   if(result == false) Print(" *** ERROR on Close ",open_mins);
   return (result);
  } // -------------------- end Close AllOverTime -----------------------------------------  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseAllActiveTickets()
// +-------------------------------------------------------------------+
//| closes all active tickets - for selected symbol, magic number      |
//| satisfy fifo rule for deletion of open tickets in same currency    |
//| Inputs: none,  Outputs: none                                       |
//| Globals: magic_number, _symbol, _bid, _ask                         |
//+--------------------------------------------------------------------+
  {
   int cnt,jj,total;
   total=OrdersTotal();
   if(total == 0) return;
   cnt=-1;
   for(jj=0;jj<total; jj++)
     {
      cnt+=1;
      if(OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderType()<=OP_SELL && OrderSymbol()==_symbol && OrderMagicNumber()==magic_number)
           {
            if(OrderType()==OP_SELL)
              {
               if(OrderClose(OrderTicket(),OrderLots(),_ask,3,Violet)) // close short position
                  cnt-=1; // decrement order pointer after remval an order
              }
            if(OrderType()==OP_BUY)
              {
               if(OrderClose(OrderTicket(),OrderLots(),_bid,3,Violet)) // close long position   
                  cnt-=1;  // decrement order pointer after remval an order
              }
           }
        }  // orderselect
     } // loop  
   return;
  }
//------------------------------------------------------------------------------- 
void CloseBuy(int ProfType)
// +-------------------------------------------------------------------+
//| closes all long tickets - for selected symbol, magic number      |
//| Inputs: none,  Outputs: none                                       |
//| Globals: magic_number, _symbol, _bid, _ask                         |
//+--------------------------------------------------------------------+
  {
   int cnt,jj,total;
   double ord_profit;
   bool result;
   total=OrdersTotal();
   if(total == 0) return;
   cnt=-1;
   for(jj=0;jj<total; jj++)
     {
      cnt+=1;
      if(OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderType()<=OP_SELL && OrderSymbol()==_symbol && OrderMagicNumber()==magic_number)
           {
            ord_profit=OrderProfit();
            if(OrderType()==OP_BUY)
              {
               if(ProfType==0)
                result = OrderClose(OrderTicket(),OrderLots(),_bid,3,Violet); // close long positions  
               if(ProfType==1 && ord_profit >= 0.) 
                result = OrderClose(OrderTicket(),OrderLots(),_bid,3,Violet); // close long positions 
               if(ProfType==2 && ord_profit <= 0.) 
                result = OrderClose(OrderTicket(),OrderLots(),_bid,3,Violet); // close long positions   
               cnt-=1;  // decrement order pointer after remval an order
              }
           }
        }  // orderselect
     } // loop  
   return;
  }
//---------------------------------------------
void CloseSell(int ProfType)
// +-------------------------------------------------------------------+
//| closes all short tickets - for selected symbol, magic number      |
//| Inputs: none,  Outputs: none                                       |
//| Globals: magic_number, _symbol, _bid, _ask                         |
//+--------------------------------------------------------------------+
  {
   int cnt,jj,total;
   double ord_profit;
   bool result;
   total=OrdersTotal();
   if(total == 0) return;
   cnt=-1;
   for(jj=0;jj<total; jj++)
     {
      cnt+=1;
      if(OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderType()<=OP_SELL && OrderSymbol()==_symbol && OrderMagicNumber()==magic_number)
           {
            ord_profit=OrderProfit();
            if(OrderType()==OP_SELL)
              {
               if(ProfType==0) 
                result = OrderClose(OrderTicket(),OrderLots(),_ask,3,Violet); // close short positions
               if(ProfType==1 && ord_profit >= 0.) 
                result = OrderClose(OrderTicket(),OrderLots(),_ask,3,Violet); // close short positions
               if(ProfType==2 && ord_profit <= 0.) 
                result = OrderClose(OrderTicket(),OrderLots(),_ask,3,Violet); // close short positions 
               cnt-=1;  // decrement order pointer after remval an order
              }
           }
        }  // orderselect
     } // loop  
   return;
  }
//--------------------------------------------

double GLots(string GSymbol,double GRisk,double Max_Lots,double Stop_Loss,int Open_Orders)
// +-------------------------------------------------------------+
//| AutoLots: get lots from margin and risk                      |
//|                                                              |
//+--------------------------------------------------------------+
  {
   double glots,glots1,glots2,GMargin,DlrsPip,GFreeMargin;
   int LotArray[6]={0,1,3,6,10,15};
   int Tot_OpenOrders;
   Tot_OpenOrders=LotArray[Open_Orders];
   glots=0;
   GMargin = MarketInfo(GSymbol,MODE_MARGINREQUIRED);
   DlrsPip = 10.*MarketInfo(GSymbol,MODE_TICKVALUE);
   GFreeMargin=AccountFreeMargin();
   glots2 = GRisk*GFreeMargin/(Stop_Loss*DlrsPip);
   glots1 = 0.90*GFreeMargin/(Tot_OpenOrders*GMargin);
   glots = MathMin(glots1,glots2);
   glots = MathMin(Max_Lots,glots);
   glots = NormalizeDouble(glots,1);
   return (glots);
  }
//-------------------- Hour Range -------------------------------------
bool HourRange(int hour_current,int lentryhour,int lopenhours)
//+-----------------------------------------------------------------+ 
//| Open trades within a range of hours starting at entry_hour      |
//| Duration of trading window is open_hours   
//| open_hours = 0 means open for 1 hour                            |
//+-----------------------------------------------------------------+
  {
   bool Hour_Test;
   int closehour;
// 
   Hour_Test = False;
   closehour = int(MathMod((lentryhour+lopenhours),24));
// 
   if(closehour==lentryhour && hour_current==lentryhour)
      Hour_Test=true;

   if(closehour>lentryhour)
     {
      if(hour_current>=lentryhour && hour_current<=closehour)
         Hour_Test=true;
     }

   if(closehour<lentryhour)
     {
      if(hour_current>=lentryhour && hour_current<=23)
         Hour_Test=true;
      if(hour_current>=0 && hour_current<=closehour)
         Hour_Test=true;
     }
   return(Hour_Test);
  }
//----------------------------------------------------------------------

double PipValues(string SymbolPair)
//+-----------------------------------------------------------------------------------+
//| Calculate Dollars/Pip for 1 Lot                                                   |
//| Modified to use Market Info                                                       |
//+-----------------------------------------------------------------------------------+
  {
   double DlrsPip;
   DlrsPip = 10.;
   DlrsPip = 10.*MarketInfo(SymbolPair,MODE_TICKVALUE);
   return(DlrsPip);
  }
//------------------------------------------------------------------------  
  
int GetOpnTrdType()
//+--------------------------------------------------------------------------+ 
//|  Return intger value of comment                                          |  
//+--------------------------------------------------------------------------+  
  {
   int cnt,total, TrdType;
   total= OrdersTotal();
   TrdType = 0;
   for(cnt=0;cnt<total;cnt++)
     {
      if(OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES))
       {
        if( OrderSymbol()==_symbol && OrderMagicNumber()==magic_number)
         {
          if(OrderType()==OP_SELL ) TrdType=2;
          if(OrderType()==OP_BUY  ) TrdType=1;
          break;
         }
        }
     }
   return(TrdType);
  }
// ----------------------------------------------------------------------------    
//----------------------------------------------------------------------------
bool GetLastTrade()
  {
// assumes only one open trade for thsi symbol, magic number
   bool WinResult;
   int cnt,total;
   WinResult=true;
   total  = HistoryTotal();
   for(cnt=total-1;cnt>=0;cnt--)
     {
      if(OrderSelect(cnt,SELECT_BY_POS,MODE_HISTORY))
       {
        if(OrderType()<=OP_SELL && OrderSymbol()==_symbol && OrderMagicNumber()==magic_number)
         {
          if(OrderProfit()<=0.) WinResult=false;
          break;
         }
        }
     }
   return(WinResult);
  }
//---------------------------------------------------------------------------------------------------------

void GetLastTradeInfo(int &TradeType,double &TradeDuration,int &TradeProfit)
  {
//+----------------------------------------------------------------------------+
// Return values for most recent closed trade                                  |
// Limitations: Does not pick up last closed order if closed by Tester at end  |
//|             Does not pick up if opened and closed during 1 bar period      |
//+----------------------------------------------------------------------------+
//  
// -----------  useage  in calling function --------------------------------
// OpenOrders = NumOpnOrds();   // number of open market orders for this symbol  
// static int Open_Orders = 0;
//  if(Open_Orders > OpenOrders ) // new closed order in History
//   {          
//    GetLastTradeInfo(TradeType, TradeDuration, TradeProfit);
//     .....
//   }
//  Open_Orders = OpenOrders;
//---------------------------------------------------------------------------           
// assumes only one open trade for thsi symbol, magic number
   int cnt,total;
   TradeType=0;
   TradeProfit=0;
   TradeDuration=0.;
   total  = HistoryTotal();
   for(cnt=total-1;cnt>=0;cnt--)
     {
      if(OrderSelect(cnt, SELECT_BY_POS, MODE_HISTORY)==false) return;
      if(OrderType()<=OP_SELL && OrderSymbol()==_symbol && OrderMagicNumber()==magic_number)
        {
         if(OrderType()==OP_BUY)  TradeType=1;
         if(OrderType()==OP_SELL) TradeType=2;
         if(OrderProfit()>=0.) TradeProfit=1;
         if(OrderProfit()<0.) TradeProfit=-1;
         TradeDuration=(OrderCloseTime()-OrderOpenTime())/60.;
         break;
        }
     }
   return;
  }
//-------------------------------------------------------------------
// ------------------------------------------------------------------------------------
 void CloseTrade()
  {
   int trdType;
   double EMALvl;
   int SloPer = 25;
   EMALvl=iMA(_symbol,0,SloPer,0,MODE_EMA,PRICE_CLOSE,1); 
   if(NumOpnOrds()>0)
    {
     trdType = GetOpnTrdType();
     if(trdType==1 && iLow(_symbol,0,1)< EMALvl) CloseBuy(2); // losing Buy trade
     if(trdType==2 && iHigh(_symbol,0,1)> EMALvl) CloseSell(2); // losing Sell Trade   
    }
   return;
  }
 //------------------------------------------------------------------------------------- 
      