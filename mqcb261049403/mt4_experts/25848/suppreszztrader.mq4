//+-------------------------------------------------------------------+
//|                                             SuppResZZTrader.mq4   |
//|                                         copyright 2019 R Poster   |
//|                                                                   |
//+-------------------------------------------------------------------+
//+-------------------------------------------------------------------+
//|  SingleCurrency EA                                                |
//|  Use EURUSD H1 Chart                                              |
//|  Triggers:   Std Dev, SMA cross of Supp/Res lines                 |
//|  Set up Buy & Sell Mkt Orders                                     |
//+-------------------------------------------------------------------+
//
// ZigZag indicator changed to function call
#property copyright "RAP"
#property strict
#define   NAME		  "SuppResZZTrader" 
#property link      "http://www.metatrader.org" 
#include <WinUser32.mqh>
//
//---------------------------------------------------------------------                    
// ---- Global variables ----------------
double       PipValue;
int          magic_number;
double       _point,_bid,_ask,_spread,_Low,_High,_close,_open;
int          _digits;
string       _symbol;
int          slpg=3;
double       MULT;
//------------ input parameters ----------------------------------
input int         MagicNumber=123456; //
                                      // -------- Trigger  Data  ---------------------
input bool        CloseTrade=true;   // Close Trade by New Trigger
input int         ProfitTypeClTrd=1; // Close Trade: Prof Type (0:all,1:pos,2:neg)

                                     // Bollinger Band Filter data
int         BBPeriod    =   20;      // Boll Band Period
double      BBSigma     =  2.0;      // Boll Band Sigma
input string      N1=" --------- Buy/Sell Trigger Data ----------";
//
input double      BBSprd_LwLim   =  25.;  // Boll Band Lower Limit
input double      BBSprd_UpLim   =  70.;  // Boll Band Upper Limit
                                          // support resistance setup
extern int        ExtDepth       = 14;  // ZigZag Depth
extern int        ExtDeviation   =  7;  // ZigZag Deviation
extern int        ExtBackstep    =  8;  // ZigZag BacdkStp
extern int        ProcBars_Min   =  8;  // Min Bars in ZZ Segment
 // SMA
input int         SMAPer= 7; // SMA Period 
// sigma indicator parameters
input int         SigPer     =  30;     // Std Dev Period
input double      SigLim     =  1.38;   // Std Dev Upper Limit
//--- ADX indicator parameter
input int         ADX_Per   =  10;    // Period ADX
input double      ADX_Lim   =  24.;   // ADX Lim (Min Lvl)
                                      // Time filters                                     //
input int         entryhour  =  5;     // Trade Entry Hour (0, ... 23)
input int         openhours  = 20;     // Trade Duration Hours (12.. 23)
                                       // Money Mgmt
input string      N2=" --------- Money__Management ----------";
input double      Lots          =  0.01;
input double      TakeProfit    =  200.;
input double      StopLoss      =  125.;
input double      TrailingStop  =   55.;
//
input string      N3=" ------- Order Number Limits ----------";
input int         NumOpenOrders = 1; // Max Open Orders this Symbol
input int         TotOpenOrders = 8; // Max Open Orders All Symbols
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//------------------------------------------------------------------------
//                  Main Functions
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   _symbol=Symbol();   // set symbol
   _point = MarketInfo(_symbol,MODE_POINT);
   _digits= int(MarketInfo(_symbol,MODE_DIGITS));
   MULT=1.0;
   if(_digits==5 || _digits==3) MULT=10.0;
   magic_number=MagicNumber;
   PipValue=PipValues(_symbol);
//   
   return (INIT_SUCCEEDED);
  } //--------------------End init ---------------------------------------------
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   Print(" Active Symbol  ",Symbol(),"  Period ",Period()," pip value ",PipValue);
   Print(" Broker Factor*_point =   ",_point*MULT,"  _point =  ",100000.*_point);

   return;
  }//------------------------------------------------------------------
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
void OnTick()
  {
   int  trentry;
   datetime  bartime_previous;
   static datetime bartime_current;
   int hour_current;
   bool newperiod;
// Order Management parameters   
   double Take_Profit,Stop_Loss;
   double orderlots;
   string OrdComment;
   bool   BuySig,SellSig;
   int    OpenOrders,TrdType;

// -- set up new bar test ---------------------------
   newperiod=false;
   bartime_previous= bartime_current;
   bartime_current =iTime(_symbol,Period(),0);
   if(bartime_current!=bartime_previous) newperiod=true;
//------------------------  Start of new Bar ---------------------------------------    
   if(newperiod)
     {
      // Set Globals       
      _bid =    MarketInfo(_symbol,MODE_BID);
      _ask =    MarketInfo(_symbol,MODE_ASK);
      _spread=MarketInfo(_symbol,MODE_SPREAD);
      _Low  =   MarketInfo(_symbol,MODE_LOW);
      _High =   MarketInfo(_symbol,MODE_HIGH);
      // initializaton          
      BuySig=false;
      SellSig=false;
      OpenOrders=0;
      trentry=0;  // entry flag 1=buy, 2=sell         
      OrdComment="";
      //     
      OpenOrders=NumOpnOrds();   // number of open market orders for this symbol 
                                 //
      //-----------------  Trigger  -----------------------------------------------------   
      SupResTrigger(BuySig,SellSig);

      //------- close trade based on new trigger or AO reversal pattern -------
      if(OpenOrders>=1 && CloseTrade)
        {
         TrdType=GetOpnTrdType();
         if(BuySig &&  TrdType==2) CloseSell(ProfitTypeClTrd);
         if(SellSig && TrdType==1) CloseBuy(ProfitTypeClTrd);
        }
      // ----------------------------------------------------------------------       
      // set trade entry flag trentry                  
      if( BuySig)  trentry=1;
      if( SellSig) trentry=2;
      //
      Take_Profit =  TakeProfit;
      Stop_Loss   =  StopLoss;
      //
      OpenOrders=NumOpnOrds();
      if(OpenOrders>=NumOpenOrders) trentry=0;  // limit number of open orders
                                                // ---------------- Hour of Day Filer -----------------------------------------  
      hour_current=TimeHour(bartime_current);
      if(!HourRange(hour_current,entryhour,openhours)) trentry=0;
      //------------------  open trade ---------------------------------------------  
      if(trentry>0)
        {
         orderlots=Lots;
         // Open new market order - check account for funds and also lot size limits            
         if(CheckMoneyForTrade(_symbol,orderlots,trentry-1))
            OpenOrder(trentry,orderlots,Stop_Loss,Take_Profit,OrdComment,NumOpenOrders);
        } //  --------------- trentry ----------------------------------------------------   
     } // -------------------- end of if new bar ----------------------------------------------------
//                                                                       
// ---------------------------  every tic processing ------------------------------------------------
// ---------------------- Manage trailing stop at every tic for all open orders ---------------------
   if(OrdersTotal()==0) return;
//
   _symbol=Symbol();
   magic_number=MagicNumber;
   _point=MarketInfo(_symbol,MODE_POINT);
   _bid =    MarketInfo(_symbol,MODE_BID);
   _ask =    MarketInfo(_symbol,MODE_ASK);
   _digits=int(MarketInfo(_symbol,MODE_DIGITS));
   MULT=1.0;
   if(_digits==5 || _digits==3)
      MULT=10.0;
// ----------  manage trailing stop --------------------------------------      
   if(TrailingStop>0.) ManageTrlStop(TrailingStop);
   return;
  }
//+------------------- end of OnTick() ---------------------------------------------------------+
//
//+ --------------------------------------------------------------------------------------------+
//|                       Application Functions                                                 |
//+---------------------------------------------------------------------------------------------+
//+---------------------------------------------------------------------------------------------+
//+------------------------------------------------------------------------------------------+
//|   Support Resistance Trigger                                                                      |
//+------------------------------------------------------------------------------------------+
void SupResTrigger(bool &buysig,bool &sellsig)
  {
// for manual trigger, tcs = -1 
   double ADX1_Val;
   double BB_Spread;
   double Sigma[10]={10*0.};
   double SMA1_Hi,SMA1_Lo;
   double ResVal,SupVal;
   double zzArray[100];
   int Proc_BarsMin=4;
   int jj;
   int BarSel,EndBar,ProcBars;
   int limit = 90;
//
   buysig  = false;
   sellsig = false;
   EndBar=0;
//
   BB_Spread=(iBands(_symbol,0,BBPeriod,BBSigma,0,PRICE_CLOSE,MODE_UPPER,1) -
              iBands(_symbol,0,BBPeriod,BBSigma,0,PRICE_CLOSE,MODE_LOWER,1))/(MULT*_point);
//               
   ADX1_Val=iADX(_symbol,0,ADX_Per,PRICE_CLOSE,MODE_MAIN,1);
//  first trigger filter
   if(BB_Spread<BBSprd_LwLim || BB_Spread>BBSprd_UpLim || ADX1_Val < ADX_Lim) return;
//  Standard Deviation
   for(jj=0;jj<5;jj++)
     {
      Sigma[jj]=1000.*iStdDev(_symbol,0,SigPer,0,MODE_SMA,PRICE_HIGH,1+jj);
     }
// ZigZag array (zzArray[]= 0. except for start and end values of segment)
   FunZigZag(limit,ExtDepth,ExtDeviation,ExtBackstep,zzArray);
   for(jj=0; jj<limit; jj++)
    {
//   zzArray[jj] = iCustom(NULL, 0, "ZigZag", ExtDepth, ExtDeviation, ExtBackstep, 0, jj+1);// alternative
     if(zzArray[jj+1]>0.01 && jj>Proc_BarsMin-1)
      {
       EndBar=jj+1;
       break;
      }
    }
//
   ProcBars=EndBar; // total bars to process
   if(ProcBars<ProcBars_Min) return;
   BarSel=1; // use close of last bar
   GetSupRes(ProcBars,BarSel,SupVal,ResVal);
//
   SMA1_Hi=iMA(_symbol,0,SMAPer,0,MODE_SMA,PRICE_HIGH,1 );  // high
   SMA1_Lo=iMA(_symbol,0,SMAPer,0,MODE_SMA,PRICE_LOW, 1 );  // low
                                                            //
   if(SMA1_Hi>ResVal && Sigma[0]<SigLim && Sigma[0]>Sigma[1]) buysig=true;
   if(SMA1_Lo<SupVal && Sigma[0]<SigLim && Sigma[0]>Sigma[1]) sellsig=true;
   return;
  }
//-----------------------------------------------------------------------------------
//
void GetSupRes(int ProcBars,int BarSel,double &SupVal,double &ResVal)
  {
// input are number of bars in ZigZag segment, bar used to compute values of Supp/Res
   double MM,BBS,BBR,ResBarVal,SupBarVal;
   int TotBars,BarSup,BarRes,StartBar;
   StartBar=1;
   TotBars = ProcBars+StartBar-1;
// compute slope of supp/res lines (y = MM*x + BBR)
   MM=(iClose(NULL,0,TotBars)-iClose(NULL,0,StartBar))/ProcBars; // slope
                                                                 // Resistance
   BarRes=Highest(NULL,0,MODE_HIGH,TotBars,StartBar);
   ResBarVal=iHigh(NULL,0,BarRes);
   BBR = ResBarVal-MM*BarRes;  // Res line intercept
   ResVal = MM*BarSel+BBR;     // compute value of Resistance at last closed bar
                               //  Support
   BarSup=Lowest(NULL,0,MODE_LOW,TotBars,StartBar);
   SupBarVal=iLow(NULL,0,BarSup);
   BBS = SupBarVal-MM*BarSup; // Supp line intercept
   SupVal = MM*BarSel+BBS;    // compute value of Support at last closed bar
   return;
  }
// --------------------------------------------------------------------------------  
// ******************* Trading Functions ***********************************************
bool CheckMoneyForTrade(string symb,double &olots,int type)
  {
// check limits of lot size
   if( olots<NormalizeDouble(MarketInfo(NULL,MODE_MINLOT),2) ){ olots=NormalizeDouble(MarketInfo(NULL,MODE_MINLOT),2); }
   if( olots>NormalizeDouble(MarketInfo(NULL,MODE_MAXLOT),2) ){ olots=NormalizeDouble(MarketInfo(NULL,MODE_MINLOT),2); }
//
   double free_margin=AccountFreeMarginCheck(symb,type,olots);
//-- if there is not enough money
   if(free_margin<=0.)
     {
      string oper=(type==OP_BUY)? "Buy":"Sell";
      Print("** Not enough money for ",oper," ",olots," ",symb," Error code=",GetLastError());
      Print(" Account Margin ",AccountMargin(),"  Free Margin ",AccountFreeMargin());
      return(false);
     }
//--- checking successful
   return(true);
  }
//----------------------------------------------------------------------------------------
// ----------------------------------------------------------------------------    
int GetOpnTrdType()
//+--------------------------------------------------------------------------+ 
//|  Return intger value of comment                                          |  
//+--------------------------------------------------------------------------+  
  {
   int cnt,total,TrdType;
   total=OrdersTotal();
   TrdType= 0;
   for(cnt=0;cnt<total;cnt++)
     {
      if(OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderSymbol()==_symbol && OrderMagicNumber()==magic_number)
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

//-------------------------------------------------------------------------------------------
bool HourRange(int hour_current,int lentryhour,int lopenhours)
//+-----------------------------------------------------------------+ 
//| Open trades within a range of hours starting at entry_hour      |
//| Duration of trading window is open_hours                        |
//| open_hours = 0 means trading is open for 1 hour                 |
//+-----------------------------------------------------------------+
  {
   bool Hour_Test;
   int closehour;
   bool wrap;
// 
   Hour_Test=true;
   wrap=false;
   closehour=lentryhour+lopenhours;
   if(closehour>23)wrap=true;
   closehour=int(MathMod((closehour),24));
   if( wrap && (hour_current<lentryhour && hour_current >closehour))  Hour_Test=false;
   if(!wrap && (hour_current<lentryhour || hour_current >closehour))  Hour_Test=false;
// 
   return(Hour_Test);
  }
//------------------------------------------------------------------------------------
void OpenOrder(int tr_entry,double Ord_Lots,double Stop_Loss,double Take_Profit,string New_Comment,int Num_OpenOrders)
//+-----------------------------------------------------------------------------------+
//| Open New Orders                                                                   |
//| Uses externals: magic_number, TotOpenOrders, Currency                             |
//|                                                                                   |
//+-----------------------------------------------------------------------------------+                      
  {
   int total_EA,total,Mag_Num,trade_result,cnt;
   double tp_norm,sl_norm;
   string NetString;

// -------------  Open New Orders ----------------------------------------------      
//  Get new open order total     
   total_EA=0;
   total=OrdersTotal();
   for(cnt=0;cnt<total;cnt++)
     {
      if(OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderType()<=OP_SELL)
         total_EA=total_EA+1;
     } // loop
   if(total_EA>=TotOpenOrders) return; // max number of open orders allowed( all symbols)
                                       //    
   total_EA=0;
   for(cnt=0;cnt<total;cnt++)
     {
      if(OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES)==false) break;
      Mag_Num=OrderMagicNumber();
      if(OrderType()<=OP_SELL && OrderSymbol()==_symbol && Mag_Num==magic_number)
         total_EA=total_EA+1;
     } //----   loop  -------
//      
   if(total_EA<Num_OpenOrders) // open new order if below OpenOrder limit
     {
      if(tr_entry==1) //Open a Buy Order
        {
         sl_norm = NormalizeDouble(_ask - Stop_Loss*MULT*_point, _digits);
         tp_norm = NormalizeDouble(_ask + Take_Profit*MULT*_point, _digits);
         trade_result=Buy_Open(Ord_Lots,sl_norm,tp_norm,magic_number,New_Comment);
         if(trade_result<0)
            return;

        } // ---  end of tr_entry = 1 --------------------------------
      if(tr_entry==2) // Open a Sell Order
        {
         sl_norm = NormalizeDouble((_bid + Stop_Loss*MULT*_point), _digits);
         tp_norm = NormalizeDouble((_bid - Take_Profit*MULT*_point),_digits);
         trade_result=Sell_Open(Ord_Lots,sl_norm,tp_norm,magic_number,New_Comment);
         if(trade_result<0)
            return;
        } // ------------------  end tr_entry = 2 -----------------------   
     } // -----------------------end of Open New Orders ------------------------------- 
   return;
  }
// --------------------------------------------------------------------------------------

//   ------------------- Open Buy Order ------------------------------      
int Buy_Open(double Ord_Lots,double stp_Loss,double tk_profit,int magic_num,string New_Comment)
//+---------------------------------------------------------------------------------+
//|  Open a Long trade                                                              |
//|  Return code < 0 for error                                                      |
// +--------------------------------------------------------------------------------+
  {
   int ticket_num;
   ticket_num=OrderSend(_symbol,OP_BUY,Ord_Lots,_ask,slpg,stp_Loss,tk_profit,New_Comment,magic_num,0,Green);
   if(ticket_num<=0)
     {
      Print(" error on opening Buy order ");
      return (-1);
     }
   return(0);
  }
//---------------------------------------------------------------------------------
// ------ Open Sell Order ---------------------------------------------------------- 
int Sell_Open(double Ord_Lots,double stp_Loss,double tk_profit,int magic_num,string New_Comment)
//+---------------------------------------------------------------------------------+
//|  Open a Short trade                                                             |
//|  Return code < 0 for error                                                      |
// +--------------------------------------------------------------------------------+ 
  {
   int ticket_num;
   ticket_num=OrderSend(_symbol,OP_SELL,Ord_Lots,_bid,slpg,stp_Loss,tk_profit,New_Comment,magic_num,0,Red);
   if(ticket_num<=0)
     {
      Print(" error on opening Sell order ");
      return (-1);
     }
   return(0);
  }
//----------------------------- end Sell -----------------------------------------
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
// ----------------------- end Manage Min Profit ---------------------------------------------- 
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
                  result=OrderClose(OrderTicket(),OrderLots(),_bid,3,Violet); // close long positions  
               if(ProfType==1 && ord_profit >= 0.) result=OrderClose(OrderTicket(),OrderLots(),_bid,3,Violet); // close long positions 
               if(ProfType==2 && ord_profit <= 0.) result=OrderClose(OrderTicket(),OrderLots(),_bid,3,Violet); // close long positions   
               cnt-=1;  // decrement order pointer after remval an order
              }
           }
        }  // orderselect
      if(OrdersTotal()==0) break;
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
                  result=OrderClose(OrderTicket(),OrderLots(),_ask,3,Violet); // close short positions
               if(ProfType==1 && ord_profit >= 0.) result=OrderClose(OrderTicket(),OrderLots(),_ask,3,Violet); // close short positions
               if(ProfType==2 && ord_profit <= 0.) result=OrderClose(OrderTicket(),OrderLots(),_ask,3,Violet); // close short positions 
               cnt-=1;  // decrement order pointer after remval an order
              }
           }
        }  // orderselect
     } // loop  
   return;
  }
//-----------------------------------------------------------------------------------------------     
//---------------------------------------------------------------------------------------------
int NumOpnOrds()
//+--------------------------------------------------------------------------+ 
//|  Return Number of Open Orders for active currency                        |  
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

double PipValues(string SymbolPair)
//+-----------------------------------------------------------------------------------+
//| Calculate Dollars/Pip for 1 Lot                                                   |
//+-----------------------------------------------------------------------------------+
  {
   double DlrsPip;
   DlrsPip = 10.;
   DlrsPip = 10.*MarketInfo(SymbolPair,MODE_TICKVALUE);
   return(DlrsPip);
  }
//------------------------------------------------------------------------  
//+------------------------------------------------------------------+
//|                                                    FunZigZag.mq4 |
//|           2006-2014, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+

void FunZigZag(int limit,int InpDepth,int InpDeviation,int InpBackstep,double &ExtZigzagBuffer[])
// Based on Metaquotes ZigZag MT4 Indicator code 
// - workaround for submittal to codebase -
 {
   int    i,jj,counterZ,whatlookfor=0;
   int    back,pos,lasthighpos=0,lastlowpos=0;
   double extremum;
   double ExtHighBuffer[],ExtLowBuffer[];
   double high[],low[];
   int    ExtLevel=3; // recounting's depth of extremums
   double curlow=0.0,curhigh=0.0,lasthigh=0.0,lastlow=0.0;
   int prev_calculated;
//--- first calculations
   ArrayResize(high,limit+InpDepth);
   ArrayResize(low,limit+InpDepth);
   ArrayResize(ExtHighBuffer,limit+InpBackstep);
   ArrayResize(ExtLowBuffer,limit+InpBackstep);
   ArrayInitialize(ExtZigzagBuffer,0.0);
   ArrayInitialize(ExtHighBuffer,0.0);
   ArrayInitialize(ExtLowBuffer,0.0);
   //
   for(jj=0;jj<(limit+InpDepth);jj++)
    {
     high[jj] = iHigh(Symbol(),0,jj);
     low[jj]  = iLow(Symbol(),0,jj);
    }   
   prev_calculated = 0;
//---------------------------------------------------------
//--- first calculations 
//   if(prev_calculated==0)
//      limit=InitializeAll();
//    else
   if(prev_calculated>0)  // (should not be executed in function call)
     {
      //--- find first extremum in the depth ExtLevel or 100 last bars
      i=counterZ=0;
      while(counterZ<ExtLevel && i<100)
        {
         if(ExtZigzagBuffer[i]!=0.0)
            counterZ++;
         i++;
        }
      //--- no extremum found - recounting all from begin
 //     if(counterZ==0)
 //        limit=InitializeAll();
 //     else
      if(counterZ>0)
        {
         //--- set start position to found extremum position
         limit=i-1;
         //--- what kind of extremum?
         if(ExtLowBuffer[i]!=0.0) 
           {
            //--- low extremum
            curlow=ExtLowBuffer[i];
            //--- will look for the next high extremum
            whatlookfor=1;
           }
         else
           {
            //--- high extremum
            curhigh=ExtHighBuffer[i];
            //--- will look for the next low extremum
            whatlookfor=-1;
           }
         //--- clear the rest data
         for(i=limit-1; i>=0; i--)  
           {
            ExtZigzagBuffer[i]=0.0;  
            ExtLowBuffer[i]=0.0;
            ExtHighBuffer[i]=0.0;
           }
        }
     } // -----  end  if prev calculated>0 -----------------------
//
//--- main loop    -----------------------------------------------------------  
   for(i=limit-1; i>=0; i--) 
     {
      //--- find lowest low in depth of bars
      extremum=low[iLowest(NULL,0,MODE_LOW,InpDepth,i)];
      //--- this lowest has been found previously
      if(extremum==lastlow)
         extremum=0.0;
      else 
        { 
         //--- new last low
         lastlow=extremum; 
         //--- discard extremum if current low is too high
         if(low[i]-extremum>InpDeviation*Point)
            extremum=0.0;
         else
           {
            //--- clear previous extremums in backstep bars
            for(back=1; back<=InpBackstep; back++)
              {
               pos=i+back;
               if(ExtLowBuffer[pos]!=0 && ExtLowBuffer[pos]>extremum)
                  ExtLowBuffer[pos]=0.0; 
              }
           }
        } 
      //--- found extremum is current low
      if(low[i]==extremum)
         ExtLowBuffer[i]=extremum;
      else
         ExtLowBuffer[i]=0.0;
      //--- find highest high in depth of bars
      extremum=high[iHighest(NULL,0,MODE_HIGH,InpDepth,i)];
      //--- this highest has been found previously
      if(extremum==lasthigh)
         extremum=0.0;
      else 
        {
         //--- new last high
         lasthigh=extremum;
         //--- discard extremum if current high is too low
         if(extremum-high[i]>InpDeviation*Point)
            extremum=0.0;
         else
           {
            //--- clear previous extremums in backstep bars
            for(back=1; back<=InpBackstep; back++)
              {
               pos=i+back;
               if(ExtHighBuffer[pos]!=0 && ExtHighBuffer[pos]<extremum)
                  ExtHighBuffer[pos]=0.0; 
              } 
           }
        }
      //--- found extremum is current high
      if(high[i]==extremum)
         ExtHighBuffer[i]=extremum;
      else
         ExtHighBuffer[i]=0.0;
     }
//--- final cutting 
   if(whatlookfor==0)
     {
      lastlow=0.0;
      lasthigh=0.0;  
     }
   else
     {
      lastlow=curlow;
      lasthigh=curhigh;
     }
   for(i=limit-1; i>=0; i--) 
     {
      switch(whatlookfor)
        {
         case 0: // look for peak or lawn 
            if(lastlow==0.0 && lasthigh==0.0)
              {
               if(ExtHighBuffer[i]!=0.0)
                 {
                  lasthigh=High[i];
                  lasthighpos=i;
                  whatlookfor=-1;
                  ExtZigzagBuffer[i]=lasthigh;
                 }
               if(ExtLowBuffer[i]!=0.0)
                 {
                  lastlow=Low[i];
                  lastlowpos=i;
                  whatlookfor=1;
                  ExtZigzagBuffer[i]=lastlow;
                 }
              }
             break;  
         case 1: // look for peak
            if(ExtLowBuffer[i]!=0.0 && ExtLowBuffer[i]<lastlow && ExtHighBuffer[i]==0.0)
              {
               ExtZigzagBuffer[lastlowpos]=0.0;
               lastlowpos=i;
               lastlow=ExtLowBuffer[i];
               ExtZigzagBuffer[i]=lastlow;
              }
            if(ExtHighBuffer[i]!=0.0 && ExtLowBuffer[i]==0.0)
              {
               lasthigh=ExtHighBuffer[i];
               lasthighpos=i;
               ExtZigzagBuffer[i]=lasthigh;
               whatlookfor=-1;
              }   
            break;               
         case -1: // look for lawn
            if(ExtHighBuffer[i]!=0.0 && ExtHighBuffer[i]>lasthigh && ExtLowBuffer[i]==0.0)
              {
               ExtZigzagBuffer[lasthighpos]=0.0;
               lasthighpos=i;
               lasthigh=ExtHighBuffer[i];
               ExtZigzagBuffer[i]=lasthigh;
              }
            if(ExtLowBuffer[i]!=0.0 && ExtHighBuffer[i]==0.0)
              {
               lastlow=ExtLowBuffer[i];
               lastlowpos=i;
               ExtZigzagBuffer[i]=lastlow;
               whatlookfor=1;
              }   
            break;               
        }
     }
//--- done
   return;
  }
//+------------------------------------------------------------------  