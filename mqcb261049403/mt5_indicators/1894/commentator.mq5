//+------------------------------------------------------------------+ 
//|                                                  Commentator.mq5 | 
//|                                  Copyright © 2008, Andrey Opeyda | 
//|                                                                  | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2008, Andrey Opeyda"
#property link "" 
//---- Indicator version number
#property version   "1.00"
//+------------------------------------------------+ 
//|  Indicator drawing parameters                  |
//+------------------------------------------------+ 
//---- drawing the indicator in the main window
#property indicator_chart_window 
#property indicator_buffers 0
#property indicator_plots   0
//+------------------------------------------------+ 
//|  Declaration of constants                      |
//+------------------------------------------------+ 
#define RESET  0 // the constant for getting the command for the indicator recalculation back to the terminal
//---- declaration of the integer variables for the start of data calculation
int min_rates_total;
//---- Declaration of integer variables for indicators handles
int DeMark_Handle,ATR_Handle,AC_Handle,CCI_Handle,MFI_Handle,WPR_Handle,Stoch_Handle,Mom_Handle;
//+------------------------------------------------------------------+    
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+  
int OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_total=20;

//---- getting handle of the iDeMarker indicator
   DeMark_Handle=iDeMarker(NULL,PERIOD_CURRENT,13);
   if(DeMark_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get handle of the iDeMarker indicator");
      return(INIT_FAILED);
     }

//---- getting handle of the iATR indicator
   ATR_Handle=iATR(NULL,PERIOD_CURRENT,12);
   if(ATR_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get the iATR indicator handle");
      return(INIT_FAILED);
     }

//---- getting handle of the iAC indicator
   AC_Handle=iAC(NULL,PERIOD_CURRENT);
   if(AC_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get handle of the iAC indicator");
      return(INIT_FAILED);
     }

//---- getting handle of the iCCI indicator
   CCI_Handle=iCCI(NULL,PERIOD_CURRENT,12,PRICE_MEDIAN);
   if(CCI_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get handle of the iCCI indicator");
      return(INIT_FAILED);
     }

//---- getting handle of the iMFI indicator
   MFI_Handle=iMFI(NULL,PERIOD_CURRENT,14,VOLUME_TICK);
   if(MFI_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get handle of the iMFI indicator");
      return(INIT_FAILED);
     }

//---- getting handle of the iWPR indicator
   WPR_Handle=iWPR(NULL,PERIOD_CURRENT,14);
   if(WPR_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get handle of the iWPR indicator");
      return(INIT_FAILED);
     }

//---- Getting the handle of the iStochastic indicator
   Stoch_Handle=iStochastic(NULL,PERIOD_CURRENT,5,3,3,MODE_SMA,STO_LOWHIGH);
   if(Stoch_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get the handle of the iStochastic indicator");
      return(INIT_FAILED);
     }
     
//---- getting handle of the iMomentum indicator
   Mom_Handle=iMomentum(NULL,PERIOD_CURRENT,14,PRICE_CLOSE);
   if(Mom_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get handle of the iMomentum indicator");
      return(INIT_FAILED);
     }

//--- Creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,"Commentator");
//--- Determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- initialization end
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
//----
   Comment("");
//----
  }
//+------------------------------------------------------------------+  
//| Custom indicator iteration function                              | 
//+------------------------------------------------------------------+  
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- checking the number of bars to be enough for the calculation
   if(BarsCalculated(DeMark_Handle)<min_rates_total
      || BarsCalculated(ATR_Handle)<min_rates_total
      || BarsCalculated(AC_Handle)<min_rates_total
      || BarsCalculated(CCI_Handle)<min_rates_total
      || BarsCalculated(MFI_Handle)<min_rates_total
      || BarsCalculated(WPR_Handle)<min_rates_total
      || BarsCalculated(Stoch_Handle)<min_rates_total
      || BarsCalculated(Mom_Handle)<min_rates_total) return(RESET);

//---- declaration of local variables 
   double DeMark[1],ATR[1],AC[4],Ac[4],CCI[1],MFI[1],WPR[1],StochM[1],StochS[1],Mom[2];
   int i;
   ArrayInitialize(AC,0);

//---- copy newly appeared data into the arrays
   if(CopyBuffer(DeMark_Handle,0,0,1,DeMark)<=0) return(RESET);
   if(CopyBuffer(ATR_Handle,0,0,1,ATR)<=0) return(RESET);
   if(CopyBuffer(AC_Handle,0,0,4,Ac)<=0) return(RESET);
   if(CopyBuffer(CCI_Handle,0,0,1,CCI)<=0) return(RESET);
   if(CopyBuffer(MFI_Handle,0,0,1,MFI)<=0) return(RESET);
   if(CopyBuffer(WPR_Handle,0,0,1,WPR)<=0) return(RESET);
   if(CopyBuffer(Stoch_Handle,0,0,1,StochM)<=0) return(RESET);
   if(CopyBuffer(Stoch_Handle,1,0,1,StochS)<=0) return(RESET);
   if(CopyBuffer(Mom_Handle,0,0,2,Mom)<=0) return(RESET);

   for(int numb=0; numb<4; numb++) AC[3-numb]=Ac[numb];

//---- Demarker
   string commentDem="DeMarker:    ";
   string commentDemAdd="   No data ";
//----
   if(DeMark[0]<0.30) commentDemAdd="   Upward price reversal is expected ";
   if(DeMark[0]>0.70) commentDemAdd="   Downward price reversal is expected ";
   commentDem=commentDem+commentDemAdd;
//---- ATR
   string commentATR="ATR:           ";
   commentATR=commentATR+"   Probability of trend change "+DoubleToString(ATR[0],6);
//---- AС
   string commentAC="AC:            ";
   string commentACAdd="No data ";
   string commentACAdd0="No data ";
   string commentACAdd1="No data ";
   string commentACAdd2="No data ";
//----   
   if(AC[0]<AC[1]) commentACAdd="Better not sell ";
   if(AC[0]>AC[1]) commentACAdd="Better not buy ";
   bool theeRedUpper=true;
   for(i=2; i>=0; i--)
     {
      if(AC[i]<AC[i+1])
        {
         if(AC[i]<=0) theeRedUpper=false;
        }
      else theeRedUpper=false;
     }
   if(theeRedUpper==true) commentACAdd0="Short position ";
//----
   bool theeGreenDown=true;
   for(i=2; i>=0; i--)
     {
      if(AC[i]>AC[i+1])
        {
         if(AC[i]>=0) theeGreenDown=false;
        }
      else theeGreenDown=false;
     }
   if(theeGreenDown==true) commentACAdd0="Long position ";
//----
   bool twoRedUpper=true;
   for(i=1; i>=0; i--) if(AC[i]>AC[i+1]) twoRedUpper=false;

   if(twoRedUpper==true) commentACAdd2="Short position ";
//----
   bool twoGreenDown=true;
   for(i=2; i>=0; i--) if(AC[i]<AC[i+1]) twoGreenDown=false;

   if(twoGreenDown==true) commentACAdd2="Long position ";
   if(AC[0]<0)
     {
      if(theeRedUpper==true) commentACAdd1="Buying possible, ";
      if(theeGreenDown==true) commentACAdd1="Buying possible, ";
      if(twoRedUpper==true) commentACAdd2="Selling possible, ";
     }

   if(AC[0]>0)
     {
      if(theeRedUpper==true) commentACAdd1="Selling possible, ";
      if(theeGreenDown==true) commentACAdd1="Selling possible, ";
      if(twoGreenDown==true) commentACAdd2="Buying possible, ";
     }

   commentAC=commentAC+"\n"+"   "+commentACAdd+"\n"+"   "+commentACAdd1+commentACAdd0+"\n"+"   "+commentACAdd2;
//----CCI
   string commentCCI="CCI:            ";
   string commentCCIAdd="   No data ";
//----   
   if(CCI[0]>100) commentCCIAdd="   Overbought state (correcting fall is expected) ";
   if(CCI[0]<-100) commentCCIAdd="   Oversold state (correcting growth is expected) ";
   commentCCI=commentCCI+commentCCIAdd+DoubleToString(CCI[0],0);
//---- MFI
   string commentMFI="MFI:            ";
   string commentMFIAdd="   No data ";
//----   
   if(MFI[0]>80) commentMFIAdd= "    Potential market top ";
   if(MFI[0]<20) commentMFIAdd= "    Potential market bottom ";
   commentMFI=commentMFI+commentMFIAdd+DoubleToString(MFI[0],0);
//---- WPR
   string commentWPR="R%:             ";
   string commentWPRAdd="   No data ";
//----   
   if(WPR[0]<-80) commentWPRAdd= "    Oversold state (wait for price to urn up) ";
   if(WPR[0]>-20) commentWPRAdd= "    Overbought state (wait for price to urn down) ";
   commentWPR=commentWPR+commentWPRAdd+DoubleToString(WPR[0],0);
//---- STOCH
   double valSTOCH=0;
   string commentSTOCH="Stoch:         ";
   string commentSTOCHAdd="   No data ";
//----   
   if(StochM[0]>StochS[0]) commentSTOCHAdd= "    Buying possible  ";
   if(StochM[0]<StochS[0]) commentSTOCHAdd= "    Selling possible  ";
   commentSTOCH=commentSTOCH+commentSTOCHAdd+DoubleToString(StochM[0],0);;
//---- Momentum
   double valMom=0;
   string commentMom="Momentum:  ";
   string commentMomAdd="   No data ";
//----   
   if(Mom[0]<100 && Mom[1]>100) commentMomAdd= "    Buy signal  ";
   if(Mom[0]>100 && Mom[1]<100) commentMomAdd= "    Sell signal  ";
   commentMom=commentMom+commentMomAdd+DoubleToString(Mom[0],_Digits);
//----   
   Comment("Indicators\n"
           +commentSTOCH+"\n"
           +commentWPR+"\n"
           +commentMFI+"\n"
           +commentDem+"\n"
           +commentCCI+"\n"
           +commentATR+"\n"
           +commentMom+"\n"
           +commentAC+"\n"
           );
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
