//+------------------------------------------------------------------+
//|                   Burg Extrapolator(barabashkakvn's edition).mq5 |
//|                                           Copyright © 2008, gpwr |
//|                                               vlad1004@yahoo.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, gpwr"
#property version   "1.001"
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Expert\Money\MoneyFixedRisk.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CMoneyFixedRisk m_money;
//--- global constants
#define MNo 0
//--- input parameters
input double   Risk           = 5;           // Risk in percent for a deal from a free margin
input int      ntmax          = 5;           // Maximum number of trades in one direction
input ushort   MinProfit      = 160;         // Open positions if predicted profit >= MinProfit (in pips)
input ushort   MaxLoss        = 130;         // Maximum allowed loss (in pips)
input ushort   TakeProfit     = 0;           // 0: disable; >0: enable (in pips)
input ushort   StopLoss       = 180;         // 0: disable; >0: enable (in pips)
input ushort   TrailingStop   = 10;          // 0: disable; >0: enable (StopLoss must be enabled too) (in pips)
input int      PastBars       = 200;         // Number of past bars
input double   ModelOrder     = 0.37;        // Order of Burg model as a fraction of PastBars
input bool     UseMOM         = true;        // Enable Logarithmic Momentum: mom(i)=log[p(i)/p(i-1)]
input bool     UseROC         = false;       // Enable Rate of Change: roc=100*(p(i)/p(i-1)-1)
//--- global parameters
int PrevBars,InitBars,Run;
int np,nf,lb,no;
double p[],av;
//---
ulong          m_magic=191175768;            // magic number
ulong          m_slippage=30;                // slippage
double         ExtMinProfit=0.0;
double         ExtMaxLoss=0.0;
double         ExtTakeProfit=0.0;
double         ExtStopLoss=0.0;
double         ExtTrailingStop=0.0;
double         m_adjusted_point;             // point value adjusted for 3 or 5 points
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
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

   ExtMinProfit      = MinProfit    *m_adjusted_point;
   ExtMaxLoss        = MaxLoss      *m_adjusted_point;
   ExtTakeProfit     = TakeProfit   *m_adjusted_point;
   ExtStopLoss       = StopLoss     *m_adjusted_point;
   ExtTrailingStop   = TrailingStop *m_adjusted_point;
//---
   if(!m_money.Init(GetPointer(m_symbol),Period(),m_symbol.Point()*digits_adjust))
      return(INIT_FAILED);
   m_money.Percent(Risk);
//---
   PrevBars=Bars(m_symbol.Name(),Period());
   Run=1;

   np=PastBars;
   no=(int)(ModelOrder*PastBars);
   nf=np-no-1;
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
   double pf[],a[];
   ArrayResize(pf,nf+1);
   ArrayResize(a,no+1);
//--- calculate initial values (index 0 in p[] corresponds to the oldest price)
   if(Run==1)
     {
      InitBars=Bars(m_symbol.Name(),Period());
      ArrayResize(p,np);
      av=0.0;
      double arr_open[];
      ArraySetAsSeries(arr_open,true);
      if(CopyOpen(m_symbol.Name(),Period(),0,np+1,arr_open)!=np+1)
         return;
      for(int i=0;i<np;i++)
        {
         if(UseMOM)
            p[np-1-i]=MathLog(arr_open[i]/arr_open[i+1]);
         else if(UseROC)
            p[np-1-i]=arr_open[i]/arr_open[i+1]-1.0;
         else
            av+=arr_open[i];
        }
      av/=np;
     }
//--- run calculations only for the first time or if a new bar started
   if(Run==1 || Bars(m_symbol.Name(),Period())>PrevBars)
     {
      double arr_open[];
      ArraySetAsSeries(arr_open,true);
      if(CopyOpen(m_symbol.Name(),Period(),0,np,arr_open)!=np)
         return;
      //--- update input data
      if(Bars(m_symbol.Name(),Period())>InitBars)
        {
         if(UseMOM || UseROC)
           {
            for(int i=0;i<np-1;i++)
               p[i]=p[i+1];
            if(UseMOM)
               p[np-1]=MathLog(arr_open[0]/arr_open[1]);
            else if(UseROC)
               p[np-1]=arr_open[0]/arr_open[1]-1.0;
           }
         else
            av+=(arr_open[0]-arr_open[np])/np;
        }
      if(!(UseMOM || UseROC))
         for(int i=0;i<np;i++)
            p[np-1-i]=arr_open[i]-av;
      //--- find LP coefficients and predictions
      //--- index 0 in pf[] corresponds to the first predicted price
      Burg(a);
      for(int n=np-1;n<np+nf;n++)
        {
         double sum=0.0;
         for(int i=1;i<=no;i++)
            if(n-i<np)
               sum-=a[i]*p[n-i];
         else
            sum-=a[i]*pf[n-i-np+1];
         pf[n-np+1]=sum;
        }
      if(UseMOM || UseROC)
         pf[0]=arr_open[0];
      else
         pf[0]+=av;
      for(int i=1;i<=nf;i++)
        {
         if(UseMOM)
            pf[i]=pf[i-1]*MathExp(pf[i]);
         else if(UseROC)
            pf[i]=pf[i-1]*(1.0+pf[i]);
         else
            pf[i]+=av;
        }
      //--- find trading signals
      double ymax=pf[0];
      double ymin=pf[0];
      int imax=0;
      int imin=0;
      int OpenSignal=0; // 1 = open long, -1 = open short, 0 = no action
      int CloseSignal=0; // 1 = close short, -1 = close long, 0 = no action
      for(int i=1;i<nf;i++) // !!! было np, стало nf
        {
         if(pf[i]>ymax && OpenSignal==0)
           {
            ymax=pf[i];
            imax=i;
            if(imin==0 && ymax-ymin>=ExtMaxLoss)
               CloseSignal=1;
            if(imin==0 && ymax-ymin>=ExtMinProfit)
               OpenSignal=1;
           }
         if(pf[i]<ymin && OpenSignal==0)
           {
            ymin=pf[i];
            imin=i;
            if(imax==0 && ymax-ymin>=ExtMaxLoss)
               CloseSignal=-1;
            if(imax==0 && ymax-ymin>=ExtMinProfit)
               OpenSignal=-1;
           }
        }
      //if(Run==1)
      //   for(int i=0;i<=nf;i++)
      //      Print(DoubleToString(pf[i],4));
      //--- begin Trading
      double SL,TP;
      int nt=CalculateAllPositions();
      if(nt>0)
        {
         //--- closing LONG positions
         if(CloseSignal==-1 || OpenSignal==-1)
            ClosePositions(POSITION_TYPE_BUY);
         return;
         //--- closing SHORT positions 
         if(CloseSignal==1 || OpenSignal==1)
            ClosePositions(POSITION_TYPE_SELL);
         return;
        }
      //--- modifying stop-loss of open orders 
      if(TrailingStop>0 && StopLoss>0)
         for(int i=PositionsTotal()-1;i>=0;i--)
            if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
               if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
                 {
                  if(m_position.PositionType()==POSITION_TYPE_BUY)
                    {
                     if(m_position.PriceCurrent()-m_position.PriceOpen()>ExtTrailingStop)
                        if(m_position.StopLoss()<m_position.PriceCurrent()-ExtTrailingStop)
                           m_trade.PositionModify(m_position.Ticket(),
                                                  m_symbol.NormalizePrice(m_position.PriceCurrent()-ExtTrailingStop),
                                                  m_position.TakeProfit());
                    }
                  else if(m_position.PositionType()==POSITION_TYPE_SELL)
                    {
                     if(m_position.PriceCurrent()+m_position.PriceOpen()<ExtTrailingStop)
                        if(m_position.StopLoss()>m_position.PriceCurrent()+ExtTrailingStop)
                           m_trade.PositionModify(m_position.Ticket(),
                                                  m_symbol.NormalizePrice(m_position.PriceCurrent()+ExtTrailingStop),
                                                  m_position.TakeProfit());
                    }
                 }
      //--- sending OPEN LONG order 
      if(OpenSignal==1 && nt<ntmax)
        {
         if(RefreshRates())
           {
            if(StopLoss!=0)
               SL=m_symbol.Ask()-ExtStopLoss;
            else
               SL=0.0;
            if(TakeProfit!=0)
               TP=m_symbol.Ask()+ExtTakeProfit;
            else
               TP=0.0;
            OpenBuy(SL,TP,TimeToString(iTime(0)));
           }
        }
      //--- sending OPEN SHORT order 
      if(OpenSignal==-1 && nt<ntmax)
        {
         if(RefreshRates())
           {
            if(StopLoss!=0)
               SL=m_symbol.Bid()+ExtStopLoss;
            else
               SL=0;
            if(TakeProfit!=0)
               TP=m_symbol.Bid()-ExtTakeProfit;
            else
               TP=0;
            OpenSell(SL,TP,TimeToString(iTime(0)));
           }
        }
     }
   PrevBars=Bars(m_symbol.Name(),Period());
   Run++;
  }
//+------------------------------------------------------------------+
//| Burg                                                             |
//+------------------------------------------------------------------+
void Burg(double &a[])
  {
   double df[],db[];
   ArrayResize(df,np);
   ArrayResize(db,np);
   int i,k,kh,ki;
   double tmp,num,den,r;
   den=0.0;
   for(i=0;i<np;i++)
      den+=p[i]*p[i];
   den*=2.0;
   for(i=0;i<np;i++)
     {
      df[i]=p[i];
      db[i]=p[i];
     }
   r=0.0;
//--- main loop
   for(k=1;k<=no;k++)
     {
      //--- calculate reflection coefficient
      num=0.0;
      for(i=k;i<np;i++)
         num+=df[i]*db[i-1];
      den=(1-r*r)*den-df[k-1]*df[k-1]-db[np-1]*db[np-1];
      r=(den!=0.0)?-2.0*num/den:0.0;
      //--- calculate prediction coefficients
      a[k]=r;
      kh=k/2;
      for(i=1;i<=kh;i++)
        {
         ki=k-i;
         tmp=a[i];
         a[i]+=r*a[ki];
         if(i!=ki)
            a[ki]+=r*tmp;
        }
      if(k<no) // calculate new residues
         for(i=np-1;i>=k;i--)
           {
            tmp=df[i];
            df[i]+=r*db[i-1];
            db[i]=db[i-1]+r*tmp;
           }
     }
  }
//+------------------------------------------------------------------+
//| Refreshes the symbol quotes data                                 |
//+------------------------------------------------------------------+
bool RefreshRates()
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
//| Calculate all positions                                          |
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
//| Open Buy position                                                |
//+------------------------------------------------------------------+
void OpenBuy(double sl,double tp,const string comment)
  {
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);

   double check_open_long_lot=m_money.CheckOpenLong(m_symbol.Ask(),sl);
//Print("sl=",DoubleToString(sl,m_symbol.Digits()),
//      ", CheckOpenLong: ",DoubleToString(check_open_long_lot,2),
//      ", Balance: ",    DoubleToString(m_account.Balance(),2),
//      ", Equity: ",     DoubleToString(m_account.Equity(),2),
//      ", FreeMargin: ", DoubleToString(m_account.FreeMargin(),2));
   if(check_open_long_lot==0.0)
      return;

//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double check_volume_lot=m_trade.CheckVolume(m_symbol.Name(),check_open_long_lot,m_symbol.Ask(),ORDER_TYPE_BUY);

   if(check_volume_lot!=0.0)
      if(check_volume_lot>=check_open_long_lot)
        {
         if(m_trade.Buy(check_open_long_lot,NULL,m_symbol.Ask(),sl,tp,comment))
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
void OpenSell(double sl,double tp,const string comment)
  {
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);

   double check_open_short_lot=m_money.CheckOpenShort(m_symbol.Bid(),sl);
//Print("sl=",DoubleToString(sl,m_symbol.Digits()),
//      ", CheckOpenLong: ",DoubleToString(check_open_short_lot,2),
//      ", Balance: ",    DoubleToString(m_account.Balance(),2),
//      ", Equity: ",     DoubleToString(m_account.Equity(),2),
//      ", FreeMargin: ", DoubleToString(m_account.FreeMargin(),2));
   if(check_open_short_lot==0.0)
      return;

//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double check_volume_lot=m_trade.CheckVolume(m_symbol.Name(),check_open_short_lot,m_symbol.Bid(),ORDER_TYPE_SELL);

   if(check_volume_lot!=0.0)
      if(check_volume_lot>=check_open_short_lot)
        {
         if(m_trade.Sell(check_open_short_lot,NULL,m_symbol.Bid(),sl,tp,comment))
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
