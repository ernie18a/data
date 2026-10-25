//+------------------------------------------------------------------+
//|                                              RSI_BollBands.mq4   |
//|                                        copyright 2016 R Poster   |
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|  SingleCurrency EA                                               |
//|  Use M15 Chart                                                   |
//|  Triggers: T1 RSI Over Bot/Over Sold with fixed limits           |
//|            T2 RSI Over Bot/Over Sold  N*Sigma Limits             |
//|  Uses M15,H1 and H4 time frames                                  |
//|  Use either T1 or T1, not both                                   |
//+------------------------------------------------------------------+
#property copyright "RAP"
//
// EA Name
#define NAME		"RSI_BollBands" 
#property link      "http://www.metatrader.org" 
#include <WinUser32.mqh>
//
int          MagicNumber=143012791;
int          magic_number;
double       _point,_bid,_ask,_spread,_Low,_High,_close,_open;
int          _digits;
string       _symbol;
int          slpg=3;
double       MULT;
string       SymbolArray[10]={"EURUSD","GBPUSD","USDCAD","USDCHF","USDJPY","AUDUSD","EURJPY","GBPJPY","EURGBP","USDRUB"};
int          ActvTimeFrm;
int          ksymbol;
int          CtrBuy=0;
int          CtrSell=0;

//------------------ input parameters ----------------------------------------------
// ---------- Trigger Control  -----------------------
extern string    ActvSymbol = "EURUSD";
extern bool      TriggerOne = false; // Trig 1 RSI OB/OS Fixed Lims
extern bool      TriggerTwo =  true; // Trig 2 RSI OB/OS BB Sigma Lims

                                     // ------------ Trigger 1 RSI OB/OS ----------------
extern string   NoteTrigger1=" Trigger 1 - RSI OB/OS ";
extern double    BBSpreadH4Min_1=84.;
extern double    BBSpreadM15Max_1=64.;
extern int       RSIPer_1=10;
//
extern double    RSILoM15_1 = 24.;
extern double    RSIHiM15_1 = 66.;
extern double    RSILoH1_1 =  34.;
extern double    RSIHiH1_1 =  54.;
extern double    RSILoH4_1 =  48.;
extern double    RSIHiH4_1 =  56.;
// Lowest and Highest liimits
extern double    RSIHiLimH4_1 =   85.;
extern double    RSILoLimH4_1 =   35.;
extern double    RSIHiLimH1_1 =   80.;
extern double    RSILoLimH1_1 =   24.;
extern double    RSIHiLimM15_1 =  92.;
extern double    RSILoLimM15_1 =  20.;
extern double    RDeltaM15_Lim_1=-3.5;
extern double    StocLoM15_1   =  26.;
extern double    StocHiM15_1   =  64.;
//
// -------- Trigger 2 RSI BB OB/OS ---------------------
extern string   NoteTrigger2=" Trigger 2 - RSI BB OB/OS ";
extern int       RSIPer_2=20;
extern double    BBSpreadH4Min_2=65.;
extern double    BBSpreadM15Max_2=75.;
extern int       NumRSI=60;
//
extern double    RSIM15_Sigma_2= 1.20;
extern double    RSIH1_Sigma_2 =  0.95;
extern double    RSIH4_Sigma_2 =  0.9;
// Lowest and Highest liimits
extern double    RSIM15_SigmaLim_2=1.85;
extern double    RSIH1_SigmaLim_2=  2.55;
extern double    RSIH4_SigmaLim_2=   2.7;
//
extern double    RDeltaM15_Lim_2=-5.5;
//
extern double    StocLoM15_2 = 24.;
extern double    StocHiM15_2 = 68.;
// 
extern double    Lots=0.1;
//
extern string noteT1MonMgt=" Trigger One Money Mgmt";
extern double    TakeProfit_Buy_1=150.;
extern double    StopLoss_Buy_1=70.;
extern double    TakeProfit_Sell_1=70.;
extern double    StopLoss_Sell_1=35.;
//
extern string noteT2MonMgt=" Trigger Two Money Mgmt";
extern double    TakeProfit_Buy_2=140.;
extern double    StopLoss_Buy_2=35.;
extern double    TakeProfit_Sell_2=60.;
extern double    StopLoss_Sell_2=30.;
//
extern string noteCommon=" Common Data ";
//  General Periods and limits
extern int       ATRPer=60;
extern int       BBPeriod=20;
extern double    ATRLim=90.;
// 
extern int       entryhour =     0;
extern int       openhours =    14;
extern int       NumOpenOrders = 1;
extern int       TotOpenOrders = 8;
//
extern int       FridayEndHour=4;
extern int       L1 = 12;
extern int       L2 =  5;
extern int       L3 =  5;
//
//------------------------------------------------------------------------
//                  Main Functions
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
   int jj;
   ActvTimeFrm=Period(); // set active timeframe
   if(ActvSymbol!=Symbol())
     {
      Alert(" *** Exiting EA because of wrong symbol -  "+Symbol());
      jj=deinit();
     }
//    
   if(TriggerOne && TriggerTwo)
     {
      Alert(" Aborting - Should not have both triggers on at the same time ");
      TriggerOne = false;
      TriggerTwo = false;
     }
   for(jj=0;jj<10;jj++)
     {
      if(Symbol()==SymbolArray[jj])
        {
         ksymbol=jj;
         break;
        }
     }
   return (0);
  } //--------------------End init ---------------------------------------------
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
   Print(" Active Symbol  ",Symbol(),"  Period ",Period());
   Print(" # Buy, Sell Signals:  ",CtrBuy," * ",CtrSell);
   return (0);
  }//------------------------------------------------------------------
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
   int  tradentry;
   datetime  bartime_previous;
   static datetime bartime_current;
   int hour_current,minute_current,second_current;
   int newperiod;
   double BB_Lower,BB_Upper,BB_Main,BB_Spread,BB_SpreadM15;;
// Order Management parameters   
   double Take_Profit,Stop_Loss;
   bool Buy_1,Sell_1,Buy_2,Sell_2;
   int  OpenOrders,MaxOrders;
   double orderlots;
   string OrdComment;
   double ATRCur;

// ----------------  Loop over currency pairs (multi currency EA) ------------------------------------------------

   _symbol=Symbol();
// -- set up new bar test ---------------------------
   newperiod=0;
   bartime_previous= bartime_current;
   bartime_current =iTime(_symbol,ActvTimeFrm,0);
   hour_current=TimeHour(bartime_current);
   minute_current = TimeMinute(bartime_current);
   second_current = TimeSeconds(bartime_current);
   if(bartime_current!=bartime_previous)
     {
      newperiod=1;
     }
//------------------------  Start of new Bar -----------------------------------------------    
   if(newperiod==1)
     {
      // Set Globals         
      _point=MarketInfo(_symbol,MODE_POINT);
      _bid =    MarketInfo(_symbol,MODE_BID);
      _ask =    MarketInfo(_symbol,MODE_ASK);
      _digits = MarketInfo(_symbol,MODE_DIGITS);
      _spread = MarketInfo(_symbol,MODE_SPREAD);
      _Low  =   MarketInfo(_symbol,MODE_LOW);
      _High =   MarketInfo(_symbol,MODE_HIGH);
      //         
      MULT=1.0;
      if(_digits==5 || _digits==3)
         MULT=10.0;
      magic_number=MagicNumber;
      //                                             
      //-------------------------------------------------------------------------                
      // initializaton          
      tradentry=0;
      Buy_1=false;
      Sell_1= false;
      Buy_2 = false;
      Sell_2= false;
      OrdComment= "";
      MaxOrders = NumOpenOrders;
      OpenOrders= 0;
      // technical indicators 
      BB_SpreadM15=(iBands(_symbol,PERIOD_M15,BBPeriod,2,0,PRICE_CLOSE,MODE_UPPER,1) -
                    iBands(_symbol,PERIOD_M15,BBPeriod,2,0,PRICE_CLOSE,MODE_LOWER,1))/(_point*MULT);

      BB_Lower = iBands(_symbol,PERIOD_H4,BBPeriod,2,0,PRICE_CLOSE, MODE_LOWER,1 );
      BB_Upper = iBands(_symbol,PERIOD_H4,BBPeriod,2,0,PRICE_CLOSE, MODE_UPPER,1 );
      BB_Main=iBands(_symbol,PERIOD_H4,BBPeriod,2,0,PRICE_CLOSE,MODE_MAIN,1);
      BB_Spread=(BB_Upper-BB_Lower)/(_point*MULT);
      //     
      OpenOrders=NumOpnOrds();   // number of open market orders for this symbol 
      OrdComment= "  ";
      ATRCur=iATR(_symbol,PERIOD_H4,ATRPer,1)/(_point*MULT);

      //----------------  RSI OPb/OS Trigger T3-------------------------------------------
      if(TriggerOne && BB_Spread>BBSpreadH4Min_1 && ATRCur<ATRLim && 
         BB_SpreadM15<BBSpreadM15Max_1) RSITriggerOBS(Buy_1,Sell_1);

      //----------------- RSI BB OB/OS Trigger 4 ----------------------------------             
      if(TriggerTwo && BB_Spread>BBSpreadH4Min_2 && ATRCur<ATRLim && 
         BB_SpreadM15<BBSpreadM15Max_2) RSIBBTrigger(Buy_2,Sell_2);

      // set tradentry                   
      if(Buy_1)
        {
         tradentry=1;
         Take_Profit =  TakeProfit_Buy_1;
         Stop_Loss   =  StopLoss_Buy_1;
        }
      if(Buy_2)
        {
         tradentry=1;
         Take_Profit =  TakeProfit_Buy_2;
         Stop_Loss   =  StopLoss_Buy_2;
        }
      if(Sell_1)
        {
         tradentry=2;
         Take_Profit =  TakeProfit_Sell_1;
         Stop_Loss   =  StopLoss_Sell_1;
        }
      if(Sell_2)
        {
         tradentry=2;
         Take_Profit =  TakeProfit_Sell_2;
         Stop_Loss   =  StopLoss_Sell_2;
        }
      // ---------------------  Filters ------------------------------------------------------           
      if(hour_current>=FridayEndHour && DayOfWeek()==5) tradentry=0;
      // ---------------- Hour of Day Filer ----------------------------------------------------    
      if(!HourRange(hour_current,entryhour,openhours)) tradentry=0;
      //----------------------------------------------------------------------------------------  
      if(tradentry==1) CtrBuy+=1; // instrumentation
      if(tradentry==2) CtrSell += 1;
      //
      if(OpenOrders>=NumOpenOrders) tradentry=0;
      if(tradentry>0)
        {
         orderlots=Lots;
         // Open new market order            
         OpenOrder(tradentry,orderlots,Stop_Loss,Take_Profit,OrdComment,NumOpenOrders);
        } //  --------------- tradentry ---------------------------------------------------------        
     } // -------------------- end of if new bar ----------------------------------------------------                                                                                  
   return(0);
  }
//+-------------------------- end of start() ---------------------------------------------------+
//|                       Application Functions                                                 |
//+---------------------------------------------------------------------------------------------+

// ---------------------- Trading Functions -----------------------------------------------------
//-----------------------------------------------------------------------------------------------
void OpenOrder(int trade_entry,double Ord_Lots,double Stop_Loss,double Take_Profit,string New_Comment,int Num_OpenOrders)
//+-----------------------------------------------------------------------------------+
//| Open New Orders                                                                   |
//| Uses externals: magic_number, NumOpenOrders, Currency                             |
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
      if(OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES)==false) return;
      if(OrderType()<=OP_SELL)
         total_EA+=1;
     } // loop
   if(total_EA>=TotOpenOrders) return; // max number of open orders allowed( all symbols)
                                       //    
   total_EA=0;
   for(cnt=0;cnt<total;cnt++)
     {
      if(OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES)== false) return;
      Mag_Num=OrderMagicNumber();
      if(OrderType()<=OP_SELL && OrderSymbol()==_symbol && Mag_Num==magic_number)
         total_EA+=1;
     } //----   loop  -------
//      
   if(total_EA<Num_OpenOrders) // open new order if below OpenOrder limit
     {
      if(trade_entry==1) //Open a Buy Order
        {
         sl_norm = NormalizeDouble(_ask - Stop_Loss*MULT*_point, _digits);
         tp_norm = NormalizeDouble(_ask + Take_Profit*MULT*_point, _digits);
         trade_result=Buy_Open(Ord_Lots,sl_norm,tp_norm,magic_number,New_Comment);
         if(trade_result<0)
            return;

        } // ---  end of tradentry = 1 --------------------------------
      if(trade_entry==2) // Open a Sell Order
        {
         sl_norm = NormalizeDouble((_bid + Stop_Loss*MULT*_point), _digits);
         tp_norm = NormalizeDouble((_bid - Take_Profit*MULT*_point),_digits);
         trade_result=Sell_Open(Ord_Lots,sl_norm,tp_norm,magic_number,New_Comment);
         if(trade_result<0)
            return;
        } // ------------------  end tradentry = 2 -----------------------   
     } // -----------------------end of Open New Orders ------------------------------- 
   return;
  }
// --------------------------------------------------------------------------------------

//   ------------------- Open Buy Order ------------------------------      
int Buy_Open(double Ord_Lots,double stp_Loss,double tk_profit,int magic_num,string New_Comment)
//+---------------------------------------------------------------------------------+
//|  Open a Long trade and modify for adding Stop/Loss                              |
//|  Return code < 0 for error                                                      |
// +---------------------------------------------------------------------------------+
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
//|  Open a Short trade and modify for adding Stop/Loss                             |
//|  Return code < 0 for error                                                      |
// +---------------------------------------------------------------------------------+ 
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

int NumOpnOrds()
//+--------------------------------------------------------------------------+ 
//|  Return Number of Open Orders for current symbol                         |  
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
   closehour = MathMod((lentryhour+lopenhours),24);
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
//-------------------------------------------------------------------------------------------

//--------------------------------------------------------------------------------------------
void  DataSigmaAsym(int NSize,double &A[],double &AMean,double &ASigmaP,double &ASigmaM)
//+--------------------------------------------------------------------+
//|   Compute Stnd Dev of array                                        |
//| Return two Sigmas for Plus,Minus sides of distribution             |
//+--------------------------------------------------------------------+
  {
   double  AVarP,AVarM,AVar,ASigma;
   int jj,NPlus,NMinus;
   AMean= 0.;
   AVar = 0.;
   AVarP =  0.;
   AVarM =  0.;
   ASigmaP = 0.;
   ASigmaM = 0.;
   NPlus=0;
   NMinus=0;
//
   if(NSize<3)
     {
      AMean=A[0];
      ASigmaP = 0.3*A[0];
      ASigmaM = 0.3*A[0];
      return;
     }
// Compute mean of  array   
   for(jj=0; jj<NSize; jj++)
     {
      AMean+=A[jj];
     }
   AMean=AMean/NSize;
// Compute Sigma of array     
   for(jj=0; jj<NSize; jj++)
     {
      AVar+=MathPow((A[jj]-AMean),2); // Compute variance of each array
      if(A[jj]>=AMean)
        {
         AVarP+=MathPow((A[jj]-AMean),2); // Compute variance of each array
         NPlus+=1;
        }
      if(A[jj]<AMean)
        {
         AVarM+=MathPow((A[jj]-AMean),2); // Compute variance of each array
         NMinus+=1;
        }
     }
   ASigma=MathSqrt(AVar/NSize);
   ASigmaP=ASigma; // no data case
   ASigmaM= ASigma;
   if(NPlus>0)  ASigmaP = MathSqrt(AVarP/NPlus);
   if(NMinus>0) ASigmaM = MathSqrt(AVarM/NMinus);
   return;
  }
//--------------------------------------------------------------------------
// ---------------------  Triggers -----------------------------------------      
//--------------------------------------------------------------------------
void RSITriggerOBS(bool &TBuy,bool &TSell)
//+----------------------------------------------------------+
//| OverBought / OverSold  Trigger 1                         |
//| OverSold: RSI < RSI Low (Buy Trigger)                    |
//| OverBought: RSI > RSI Hi (Sell Trigger)                  |
//+----------------------------------------------------------+
  {
   double RSIH1_1,RSIH4_1,RSIM15_1,RSIM15_2,DeltaM15;
   double StocM15;
//
   RSIM15_1 = iRSI(_symbol,PERIOD_M15,RSIPer_1,PRICE_CLOSE, 1); // 
   RSIH1_1 =  iRSI(_symbol,PERIOD_H1,RSIPer_1, PRICE_CLOSE, 1); //
   RSIH4_1 =  iRSI(_symbol,PERIOD_H4,RSIPer_1, PRICE_CLOSE, 0); //
   RSIM15_2 = iRSI(_symbol,PERIOD_M15,RSIPer_1,PRICE_CLOSE, 2); // 
   DeltaM15 = RSIM15_1 - RSIM15_2;
   StocM15=iStochastic(_symbol,0,L1,L2,L3,MODE_SMA,0,MODE_MAIN,1);
//     
   if(RSIH1_1<RSILoH1_1 && RSIM15_1<RSILoM15_1 && RSIH4_1<RSILoH4_1
      && RSIH4_1>RSILoLimH4_1 && RSIM15_1>RSILoLimM15_1 && RSIH1_1>RSILoLimH1_1 && 
      DeltaM15>RDeltaM15_Lim_1 && StocM15<StocLoM15_1) TBuy=true;
   if(RSIH1_1>RSIHiH1_1 && RSIM15_1>RSIHiM15_1 && RSIH4_1>RSIHiH4_1
      && RSIH4_1<RSIHiLimH4_1 && RSIM15_1<RSIHiLimM15_1 && RSIH1_1<RSIHiLimH1_1 && 
      DeltaM15<-RDeltaM15_Lim_1 && StocM15>StocHiM15_1) TSell=true;

   return;
  }
//----------------------------------------------------------------------------------
//----------------------------------------------------------------------------------
void RSIBBTrigger(bool &TBuy,bool &TSell)
//+----------------------------------------------------------+
//| OverBought / OverSold Bollinger Band Trigger - Trigger 2 |
//| OverSold: RSI < RSI Upper (Buy Trigger)                  |
//| OverBought: RSI > RSI Lower (Sell Trigger)               |
//+----------------------------------------------------------+
  {
   double RSIH1_1,RSIH4_1,RSIM15_1,RSIM15_2,DeltaM15;
   double StocM15;
   double RSIM15Ary[250],RSIH1Ary[250],RSIH4Ary[250];  // greater than NumRSI
   double RSIM15Avg,RSIH1Avg,RSIH4Avg;
   double XMeanM15,XMeanH1,XMeanH4;
   double XSigmaM15P,XSigmaH1P,XSigmaH4P,XSigmaM15M,XSigmaH1M,XSigmaH4M;
   double RSIM15_Lo,RSIH1_Lo,RSIH4_Lo,RSIM15_Hi,RSIH1_Hi,RSIH4_Hi;
   double RSILoLimM15_2,RSILoLimH1_2,RSILoLimH4_2,RSIHiLimM15_2,RSIHiLimH1_2,RSIHiLimH4_2;

   int jj;
//       
   for(jj=0; jj<NumRSI; jj++)
     {
      RSIM15Ary[jj]=iRSI(_symbol,PERIOD_M15,RSIPer_2,PRICE_CLOSE,jj+1);
     }
//          
   for(jj=0; jj<NumRSI; jj++)
     {
      RSIH1Ary[jj]=iRSI(_symbol,PERIOD_H1,RSIPer_2, PRICE_CLOSE, jj+1);
      RSIH4Ary[jj]=iRSI(_symbol,PERIOD_H4,RSIPer_2,PRICE_CLOSE,jj); // start with current bar 
     }
//
   RSIM15_1 = iRSI(_symbol,PERIOD_M15,RSIPer_2, PRICE_CLOSE, 1); // 
   RSIH1_1 =  iRSI(_symbol,PERIOD_H1, RSIPer_2, PRICE_CLOSE, 1); //
   RSIH4_1 =  iRSI(_symbol,PERIOD_H4, RSIPer_2, PRICE_CLOSE, 0); // use current bar
   RSIM15_2 = iRSI(_symbol,PERIOD_M15,RSIPer_2, PRICE_CLOSE, 2); // 
   DeltaM15 = RSIM15_1 - RSIM15_2;
//     
   StocM15=iStochastic(_symbol,0,L1,L2,L3,MODE_SMA,0,MODE_MAIN,1);

   DataSigmaAsym(NumRSI,RSIM15Ary,XMeanM15,XSigmaM15P,XSigmaM15M);    // M15
   RSIM15Avg = XMeanM15;
   RSIM15_Lo = RSIM15Avg - RSIM15_Sigma_2*XSigmaM15M;
   RSIM15_Hi = RSIM15Avg + RSIM15_Sigma_2*XSigmaM15P;
   RSILoLimM15_2 = RSIM15Avg - RSIM15_SigmaLim_2*XSigmaM15M;
   RSIHiLimM15_2 = RSIM15Avg + RSIM15_SigmaLim_2*XSigmaM15P;
//             
   DataSigmaAsym(NumRSI,RSIH1Ary,XMeanH1,XSigmaH1P,XSigmaH1M);        // H1
   RSIH1Avg =  XMeanH1;
   RSIH1_Lo = RSIH1Avg  -  RSIH1_Sigma_2*XSigmaH1M;
   RSIH1_Hi = RSIH1Avg  +  RSIH1_Sigma_2*XSigmaH1P;
   RSILoLimH1_2 = RSIH1Avg - RSIH1_SigmaLim_2*XSigmaH1M;
   RSIHiLimH1_2 = RSIH1Avg + RSIH1_SigmaLim_2*XSigmaH1P;

//               
   DataSigmaAsym(NumRSI,RSIH4Ary,XMeanH4,XSigmaH4P,XSigmaH4M);        // H4 (using current bar)
   RSIH4Avg =  XMeanH4;
   RSIH4_Lo = RSIH4Avg  -  RSIH4_Sigma_2*XSigmaH4M;
   RSIH4_Hi = RSIH4Avg  +  RSIH4_Sigma_2*XSigmaH4P;
   RSILoLimH4_2 = RSIH4Avg - RSIH4_SigmaLim_2*XSigmaH4M;
   RSIHiLimH4_2 = RSIH4Avg + RSIH4_SigmaLim_2*XSigmaH4P;
// 
   RSIM15_Lo=  MathMax(RSIM15_Lo,5.);
   RSIH1_Lo =   MathMax(RSIH1_Lo,  5.);
   RSIH4_Lo =   MathMax(RSIH4_Lo, 5.);
   RSILoLimM15_2= MathMax(RSILoLimM15_2,5.);
   RSILoLimH1_2 =  MathMax(RSILoLimH1_2,5.);
   RSILoLimH4_2 =  MathMax(RSILoLimH4_2,5.);
//         
   RSIM15_Hi=  MathMin(RSIM15_Hi,95.);
   RSIH1_Hi =   MathMin(RSIH1_Hi,95.);
   RSIH4_Hi =   MathMin(RSIH4_Hi,95.);
   RSIHiLimM15_2= MathMin(RSIHiLimM15_2,95.);
   RSIHiLimH1_2 =  MathMin(RSIHiLimH1_2,95.);
   RSIHiLimH4_2 =  MathMin(RSIHiLimH4_2,95.);
//     
   if(RSIH1_1<RSIH1_Lo && RSIM15_1<RSIM15_Lo && RSIH4_1<RSIH4_Lo
      && RSIH4_1>RSILoLimH4_2 && RSIM15_1>RSILoLimM15_2 && RSIH1_1>RSILoLimH1_2 && 
      DeltaM15>RDeltaM15_Lim_2 && StocM15<StocLoM15_2) TBuy=true;
//   
   if(RSIH1_1>RSIH1_Hi && RSIM15_1>RSIM15_Hi && RSIH4_1>RSIH4_Hi
      && RSIH4_1<RSIHiLimH4_2 && RSIM15_1<RSIHiLimM15_2 && RSIH1_1<RSIHiLimH1_2 && 
      DeltaM15<-RDeltaM15_Lim_2 && StocM15>StocHiM15_2) TSell=true;
   return;
  }
//----------------------------------------------------------------------------------
