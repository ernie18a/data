//+------------------------------------------------------------------+
//|                                                 Fear&Greed_R.mq5 |
//|                                  Copyright 2023, Igor Gerasimov. |
//|                                                 tgwls2@gmail.com |
//+------------------------------------------------------------------+
#property    copyright "Copyright 2023, Igor Gerasimov."
#property    link      "tgwls2@gmail.com"
#property    version   "1.00"
#property    script_show_inputs
#define      MOTIVE    MathPow(M_E,1/(double)261)
#define      BMOTIVE   (1/MOTIVE)
#define      THIRD     (1/(double)3)
#define      SQRTPI    MathSqrt(M_PI)
#define      ELOG2 MathLog(2)
#include     <Trade\Trade.mqh>
input group  "INITIALS"
input string yor_nme="Dude";                 // Your Name
input double bal_lst=0,                      // Last Highest Account Balance
             typ_sns=0;                      // Sensitivity (-1:COWARD/0:NORMAL/1:BRAVE)
input group  "DATAFILE"
input bool   rwr_dat=false;                  // Rewrite Data File
input string fle_pfx="fearNgreed_",          // File Name Prefix
             fle_end="Data.csv";             // File Name Ending
input group  "ADVANCED"
input bool   mke_alr=true,                   // Make Alerts
             snd_ntf=false,                  // Send Notifications
             cls_prf=false;                  // Close All On Daily Goal
uint         his_ttl=0;
uchar        his_cnt=0,
             chk_tim=0;
string       nme_yor=yor_nme;
bool         dln_alr=false,
             dpn_alr=false,
             dln_ntf=false,
             dpn_ntf=false,
             spd_clc=false;
double       sns_typ=typ_sns,
             mul_cwd=0,
             mul_nrm=1,
             mul_brv=0,
             act_cnf=0,
             lst_acc=AccountInfoDouble(ACCOUNT_BALANCE),
             lst_bal=lst_acc>0?(bal_lst>lst_acc?bal_lst:lst_acc):0,
             mtv_bal=lst_bal*MOTIVE,
             sts_bal=lst_acc>0?lst_acc*MathPow(mtv_bal/lst_acc,THIRD)-lst_acc:0,
             rcm_vol=0,
             trl_prf=0,
             sm5[96],
             sm3[48],
             lst_ask=0,
             lst_bid=0,
             cnt_spd=0,
             avg_spd[5][1440],
             rsl_spd[5][1440];
int          spd_cnt=0,
             spd_avg[5][1440];
ushort       Dm5[96],
             Dm3[48],
             slp_tim=99;
datetime     m30_tim=0,
             m15_tim=0,
             m01_tim=0;
CTrade       Trd;
//+------------------------------------------------------------------+
//| SetSensitivity                                                   |
//+------------------------------------------------------------------+
void SetSensitivity(const bool b)
{
    double a=0;
    if((b && HistorySelect(0,TimeCurrent())) || !b)
        {
            double A[10]= {0,0,0,0,0,0,0,0,0,0},
                          lst_mep=0;
            his_ttl=HistoryDealsTotal();
            uint ende=(his_ttl-11)>=0?his_ttl-11:0;
            for(uint y=(his_ttl-1); y>ende && !IsStopped(); y--)
                {
                    uchar cnt_ttl=10;
                    double div_ttl=0,prf_ttl=0,prf_rsl=0,los_rsl=0,lst_prf=0;
                    uint endi=(y-10)>=0?y-10:0;
                    for(uint z=y; z>endi && !IsStopped(); z--)
                        {
                            const ulong tkt=HistoryDealGetTicket(z);
                            if(tkt>0)
                                {
                                    const ENUM_DEAL_TYPE type=(ENUM_DEAL_TYPE)HistoryDealGetInteger(tkt,DEAL_TYPE);
                                    const long entry=HistoryDealGetInteger(tkt,DEAL_ENTRY);
                                    const double profit=HistoryDealGetDouble(tkt,DEAL_PROFIT);
                                    if((type==DEAL_TYPE_BUY || type==DEAL_TYPE_SELL) && entry)
                                        {
                                            if(MathAbs(profit)>=DBL_EPSILON && lst_prf!=profit)
                                                {
                                                    const double v=cnt_ttl/(double)10,t=v>0?v*(1-v*MathLog(1/v)/ELOG2):0;
                                                    if(profit>0)
                                                        {
                                                            prf_rsl+=profit*t;
                                                            prf_ttl+=t;
                                                        }
                                                    else los_rsl+=profit*t;
                                                    div_ttl+=t;
                                                    if((cnt_ttl-1)>0) cnt_ttl--;
                                                    else break;
                                                    lst_prf=profit;
                                                }
                                            else if((endi-1)>=0) endi--;
                                        }
                                }
                        }
                    if(div_ttl>0)
                        {
                            const double prf_avg=prf_ttl>0?prf_rsl/prf_ttl:0,
                                         v=div_ttl-prf_ttl,
                                         los_avg=v>0?los_rsl/v:0,
                                         t=prf_ttl/div_ttl;
                            double B[1];
                            B[0]=prf_avg*t+los_avg*(1-t);
                            if(y==(his_ttl-1))
                                {
                                    const double w=1-((t>0?t*MathLog(1/t)/ELOG2:0)+((1-t)>0?(1-t)*MathLog(1/(1-t))/ELOG2:0));
                                    act_cnf=B[0]>=0?w:-w;
                                }
                            if(lst_mep!=B[0])
                                {
                                    ArrayInsert(A,B,0,0,1);
                                    lst_mep=B[0];
                                }
                            else
                                {
                                    if((ende-1)>=0) ende--;
                                    else break;
                                }
                        }
                }
            const int Mm=ArrayMaximum(A),Mn=ArrayMinimum(A);
            if(Mm>=0 && Mn>=0)
                {
                    const double MN=A[Mn],MD=A[Mm]-MN,t=A[9]-MN;
                    if(MathAbs(MD)>=DBL_EPSILON) a=A[9]>=DBL_EPSILON?t/MD:-(1-t/MD);
                }
        }
    sns_typ=a<1?(a>-1?a:-1):1;
    const double t=0.5-(sns_typ+1)/2;
    mul_cwd=1-MathSqrt(1-MathPow(t>0?t*2:0,2));
    mul_nrm=MathSqrt(1-MathPow(MathAbs(t)*2,2));
    mul_brv=1-MathSqrt(1-MathPow(-t>0?-t*2:0,2));
    return;
}
//+------------------------------------------------------------------+
//| CheckDay                                                         |
//+------------------------------------------------------------------+
bool CheckDay(const MqlDateTime &a)
{
    chk_tim=(uchar)a.day_of_week;
    if(a.day_of_week<1 || a.day_of_week>5) slp_tim=499;
    else
        {
            slp_tim=99;
            return(true);
        }
    return(false);
}
//+------------------------------------------------------------------+
//| Norm                                                             |
//+------------------------------------------------------------------+
bool Norm(const ushort x,double &Y[])
{
    const int maxi=ArrayMaximum(Y),mini=ArrayMinimum(Y);
    if(maxi>=0 && mini>=0)
        {
            const double min=Y[mini],div=Y[maxi]-min;
            if(MathAbs(div)>=DBL_EPSILON) for(ushort z=0; z<x && !IsStopped(); z++) Y[z]=(Y[z]-min)/div;
            else return(false);
        }
    else return(false);
    return(true);
}
//+------------------------------------------------------------------+
//| Norm7                                                            |
//+------------------------------------------------------------------+
bool Norm7(double &Y[])
{
    if(!Norm(7200,Y)) return(false);
    double Tm[7200];
    if(ArrayCopy(Tm,Y)<7200) return(false);
    for(ushort z=0; z<7200 && !IsStopped(); z++) Y[z]=(Tm[z>1?z-2:(z>0?7199:7198)]+Tm[z>0?z-1:7199]+Tm[z]+Tm[z<7199?z+1:0]+Tm[z<7198?z+2:(z<7199?0:1)])/5;
    if(!Norm(7200,Y)) return(false);
    return(true);
}
//+------------------------------------------------------------------+
//| Norm5                                                            |
//+------------------------------------------------------------------+
bool Norm5(const double &X[],double &Y[])
{
    if(!Norm(96,Y)) return(false);
    double Tm[96];
    if(ArrayCopy(Tm,Y)<96) return(false);
    for(ushort z=0; z<96 && !IsStopped(); z++) Y[z]=(Tm[z>1?z-2:(z>0?95:94)]+Tm[z>0?z-1:95]+Tm[z]+Tm[z<95?z+1:0]+Tm[z<94?z+2:(z<95?0:1)])/5;
    const int maxi=ArrayMaximum(Y),mini=ArrayMinimum(Y);
    if(maxi>=0 && mini>=0)
        {
            const double min=Y[mini],div=Y[maxi]-min;
            if(MathAbs(div)>=DBL_EPSILON) for(ushort z=0; z<96 && !IsStopped(); z++) Y[z]=(Y[z]-min)*X[(int)MathFloor((z*PeriodSeconds(PERIOD_M15))/(double)PeriodSeconds(PERIOD_M30))]/div;
            else return(false);
        }
    else return(false);
    if(!Norm(96,Y)) return(false);
    return(true);
}
//+------------------------------------------------------------------+
//| Norm3                                                            |
//+------------------------------------------------------------------+
bool Norm3(double &Y[])
{
    if(!Norm(48,Y)) return(false);
    double Tm[48];
    if(ArrayCopy(Tm,Y)<48) return(false);
    for(ushort z=0; z<48 && !IsStopped(); z++) Y[z]=(Tm[z>0?z-1:47]+Tm[z]+Tm[z<47?z+1:0])/3;
    if(!Norm(48,Y)) return(false);
    return(true);
}
//+------------------------------------------------------------------+
//| RecommendedVolume                                                |
//+------------------------------------------------------------------+
double RecommendedVolume()
{
    double S=0,D=0;
    for(ushort z=960; z>0 && !IsStopped(); z--)
        {
            const int t0=z+1,t1=z+2;
            const double p0=((iHigh(_Symbol,PERIOD_M15,z)+iLow(_Symbol,PERIOD_M15,z))/2+iOpen(_Symbol,PERIOD_M15,z-1))/2,
                         p1=((iHigh(_Symbol,PERIOD_M15,t0)+iLow(_Symbol,PERIOD_M15,t0))/2+iOpen(_Symbol,PERIOD_M15,z))/2,
                         p2=((iHigh(_Symbol,PERIOD_M15,t1)+iLow(_Symbol,PERIOD_M15,t1))/2+iOpen(_Symbol,PERIOD_M15,t0))/2;
            const double v=(961-z)/(double)960,t2=v>0?v*(1-v*MathLog(1/v)/ELOG2):0;
            S+=t2*MathMax(MathMax(MathAbs(p0-p2),MathAbs(p0-p1)),MathAbs(p1-p2));
            D+=t2;
        }
    S/=D;
    double pb=0,ps=0;
    const double ask=SymbolInfoDouble(_Symbol,SYMBOL_ASK),bid=SymbolInfoDouble(_Symbol,SYMBOL_BID);
    if(ask>=_Point && MathIsValidNumber(ask) &&
            bid>=_Point && MathIsValidNumber(bid))
        {
            if(OrderCalcProfit(ORDER_TYPE_BUY,_Symbol,1,ask,bid+S,pb) &&
                    OrderCalcProfit(ORDER_TYPE_SELL,_Symbol,1,bid,ask-S,ps)) return(sts_bal/((pb+ps)/2));
        }
    return(0);
}
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
    double Sm5[96];
    if(lst_acc>=DBL_EPSILON)
        {
            if(FileIsExist(fle_pfx+fle_end) && !rwr_dat)
                {
                    const int fle=FileOpen(fle_pfx+fle_end,FILE_READ|FILE_CSV);
                    const double rdr_lst=FileReadNumber(fle);
                    mtv_bal=FileReadNumber(fle);
                    chk_tim=(uchar)FileReadNumber(fle);
                    nme_yor=FileReadString(fle);
                    m15_tim=StringToTime(FileReadString(fle));
                    FileClose(fle);
                    lst_bal=rdr_lst>0?(rdr_lst>lst_acc?rdr_lst:lst_acc):0;
                    sts_bal=lst_acc*MathPow(mtv_bal/lst_acc,THIRD)-lst_acc;
                    if(m15_tim==iTime(_Symbol,PERIOD_M15,0)) rcm_vol=RecommendedVolume();

                }
            if(FileIsExist(fle_pfx+_Symbol+"_"+fle_end) && !rwr_dat)
                {
                    const int fle=FileOpen(fle_pfx+_Symbol+"_"+fle_end,FILE_READ|FILE_CSV);
                    for(uchar a=0; a<5 && !IsStopped(); a++)
                        {
                            for(ushort b=0; b<1440 && !IsStopped(); b++) avg_spd[a][b]=FileReadNumber(fle);
                            for(ushort b=0; b<1440 && !IsStopped(); b++) spd_avg[a][b]=(int)FileReadNumber(fle);
                        }
                    for(uchar z=0; z<96 && !IsStopped(); z++) sm5[z]=FileReadNumber(fle);
                    for(uchar z=0; z<48 && !IsStopped(); z++) sm3[z]=FileReadNumber(fle);
                    for(uchar z=0; z<96 && !IsStopped(); z++) Dm5[z]=(ushort)FileReadNumber(fle);
                    for(uchar z=0; z<48 && !IsStopped(); z++) Dm3[z]=(ushort)FileReadNumber(fle);
                    m30_tim=StringToTime(FileReadString(fle));
                    FileClose(fle);
                    double Sm3[48];
                    while(!IsStopped())
                        {
                            if(ArrayInitialize(Sm3,0)<48) break;
                            for(ushort z=0; z<48 && !IsStopped(); z++) Sm3[z]=sm3[z]/(Dm3[z]>0?Dm3[z]:1);
                            if(!Norm3(Sm3)) break;
                            break;
                        }
                    while(!IsStopped())
                        {
                            if(ArrayInitialize(Sm5,0)<96) break;
                            for(ushort z=0; z<96 && !IsStopped(); z++) Sm5[z]=sm5[z]/(Dm5[z]>0?Dm5[z]:1);
                            if(!Norm5(Sm3,Sm5)) break;
                            break;
                        }
                }
            else
                {
                    while(!IsStopped())
                        {
                            MqlRates rates[];
                            double Sm3[48];
                            if(ArrayInitialize(Sm3,0)<48) break;
                            if(CopyRates(_Symbol,PERIOD_M30,0,1000,rates)>999)
                                {
                                    if(ArrayInitialize(Dm3,0)<48) break;
                                    for(ushort z=999; z>1 && !IsStopped(); z--)
                                        {
                                            const int t0=z-2,t1=z-1,l=(int)MathFloor((int)(rates[t1].time-iTime(_Symbol,PERIOD_D1,iBarShift(_Symbol,PERIOD_D1,rates[t1].time)))/(double)PeriodSeconds(PERIOD_M30));
                                            sm3[l]+=MathMax(rates[t1].high,rates[t0].open)-MathMin(rates[t1].low,rates[t0].open);
                                            Dm3[l]++;
                                        }
                                    for(ushort z=0; z<48 && !IsStopped(); z++) Sm3[z]=sm3[z]/(Dm3[z]>0?Dm3[z]:1);
                                    if(!Norm3(Sm3)) break;
                                }
                            else break;
                            m30_tim=iTime(_Symbol,PERIOD_M30,0);
                            if(ArrayInitialize(Sm5,0)<96) break;
                            if(CopyRates(_Symbol,PERIOD_M15,0,1000,rates)>999)
                                {
                                    if(ArrayInitialize(Dm5,0)<96) break;
                                    for(ushort z=998; z>1 && !IsStopped(); z--)
                                        {
                                            const int t0=z-2,t1=z-1,l=(int)MathFloor((int)(rates[z].time-iTime(_Symbol,PERIOD_D1,iBarShift(_Symbol,PERIOD_D1,rates[z].time)))/(double)PeriodSeconds(PERIOD_M15));
                                            sm5[l]+=MathAbs((MathMax(rates[t1].high,rates[t0].open)+MathMin(rates[t1].low,rates[t0].open))/2-(MathMax(rates[z].high,rates[t1].open)+MathMin(rates[z].low,rates[t1].open))/2);
                                            Dm5[l]++;
                                        }
                                    for(ushort z=0; z<96 && !IsStopped(); z++) Sm5[z]=sm5[z]/(Dm5[z]>0?Dm5[z]:1);
                                    if(!Norm5(Sm3,Sm5)) break;
                                }
                            else break;
                            m15_tim=iTime(_Symbol,PERIOD_M15,0);
                            break;
                        }
                    MqlDateTime time;
                    if(TimeToStruct(TimeTradeServer(),time))
                        {
                            if(CheckDay(time))
                                {
                                    const string s0="Hi, "+nme_yor, s1="Your Daily Goal Is "+DoubleToString(mtv_bal-AccountInfoDouble(ACCOUNT_BALANCE),2)+" "+AccountInfoString(ACCOUNT_CURRENCY)+", Today.";
                                    if(mke_alr)
                                        {
                                            Alert(s0,".");
                                            Alert(s1);
                                        }
                                    if(snd_ntf) SendNotification(s0+". "+s1);
                                }
                            else
                                {
                                    const string s0="Hi, "+nme_yor, s1="Off-Time, Today.";
                                    if(mke_alr)
                                        {
                                            Alert(s0,".");
                                            Alert(s1);
                                        }
                                    if(snd_ntf) SendNotification(s0+". "+s1);
                                }
                        }
                    for(uchar a=0; a<5 && !IsStopped(); a++)
                        {
                            for(ushort b=0; b<1440 && !IsStopped(); b++) avg_spd[a][b]=0;
                            for(ushort b=0; b<1440 && !IsStopped(); b++) spd_avg[a][b]=0;
                        }
                }
            SetSensitivity(true);
            double tmp_rsl[7200];
            for(uchar a=0; a<5 && !IsStopped(); a++) for(ushort b=0; b<1440 && !IsStopped(); b++) tmp_rsl[a*1440+b]=avg_spd[a][b];
            if(Norm7(tmp_rsl)) for(uchar a=0; a<5 && !IsStopped(); a++) for(ushort b=0; b<1440 && !IsStopped(); b++) rsl_spd[a][b]=tmp_rsl[a*1440+b];
            spd_clc=true;
        }
    double a=lst_acc;
    while(a>=DBL_EPSILON && !IsStopped())
        {
            if(slp_tim<499)
                {
                    if(his_cnt>=150 && HistorySelect(0,TimeCurrent()))                                                        // Check Deals History Every 15 Seconds
                        {
                            if(his_ttl!=HistoryDealsTotal()) SetSensitivity(false);
                            his_cnt=1;
                        }
                    else his_cnt++;
                    if((a=AccountInfoDouble(ACCOUNT_BALANCE))<DBL_EPSILON) break;
                    const double b=lst_bal;
                    lst_bal=a>b?a:b;
                }
            MqlDateTime time;
            if(TimeToStruct(TimeTradeServer(),time))
                {
                    if(chk_tim!=time.day_of_week)
                        {
                            if(CheckDay(time))
                                {
                                    mtv_bal*=MOTIVE;
                                    sts_bal=a*MathPow(mtv_bal/a,THIRD)-a;
                                    const string s0="Hi, "+nme_yor, s1="Your Daily Goal Is "+DoubleToString(mtv_bal-a,2)+" "+AccountInfoString(ACCOUNT_CURRENCY)+", Today.";
                                    if(mke_alr)
                                        {
                                            Alert(s0,".");
                                            Alert(s1);
                                        }
                                    if(snd_ntf) SendNotification(s0+". "+s1);
                                    dln_alr=false;
                                    dpn_alr=false;
                                    dln_ntf=false;
                                    dpn_ntf=false;
                                    spd_clc=false;
                                }
                            else if(!spd_clc)
                                {
                                    double tmp_rsl[7200];
                                    for(uchar z=0; z<5 && !IsStopped(); z++) for(ushort y=0; y<1440 && !IsStopped(); y++) tmp_rsl[z*1440+y]=avg_spd[z][y];
                                    if(Norm7(tmp_rsl)) for(uchar z=0; z<5 && !IsStopped(); z++) for(ushort y=0; y<1440 && !IsStopped(); y++) rsl_spd[z][y]=tmp_rsl[z*1440+y];
                                    spd_clc=true;
                                }
                        }
                    if(slp_tim<499)
                        {
                            if(lst_acc!=a)
                                {
                                    sts_bal=a*MathPow(mtv_bal/a,THIRD)-a;
                                    lst_acc=a;
                                }
                            const double t=a>=DBL_EPSILON?MathPow(lst_bal/a,THIRD)-1:1,
                                         r0=MathSin((t<1?(t>=DBL_EPSILON?t:0):1)*M_PI_2),
                                         c=AccountInfoDouble(ACCOUNT_EQUITY),
                                         d=(lst_bal-c)/lst_bal,
                                         g=d<=-DBL_EPSILON?-d:0,
                                         r1=MathSin((d<1?(d>-1?d:-1):1)*M_PI_2),
                                         e=AccountInfoDouble(ACCOUNT_MARGIN_LEVEL),
                                         f=(MathIsValidNumber(e) && MathAbs(e)>=DBL_EPSILON)?100/e:0,
                                         r2=MathSin((f<1?(f>-1?f:-1):1)*M_PI_2),
                                         w2=1-(r2>=DBL_EPSILON?MathSqrt(1-MathPow(r2,2)):0),
                                         wd=MathAbs(r1)>=DBL_EPSILON?r0/r1:r0/DBL_EPSILON,
                                         wt=1-w2,
                                         w1=wt*(1-wd),
                                         w0=wt*wd,
                                         r=c<lst_bal?r0*w0+r1*w1+r2*w2:0,
                                         fear=c<lst_bal?(-MathTanh(r*12)*mul_cwd-MathSin((r<1?(r>-1?r:-1):1)*M_PI_2)*mul_nrm+(r>=0?MathSqrt(1-MathPow(-r>-1?-r:-1,2))-1:1-MathSqrt(1-MathPow(-r<1?-r:1,2)))*mul_brv):g,
                                         h=AccountInfoDouble(ACCOUNT_PROFIT),
                                         i=(h<0?-MathPow(-h*THIRD,THIRD):MathPow(h,THIRD))/MathPow(sts_bal,THIRD),
                                         stress=i<0?MathTanh(fear+i*(1-fear)*((mtv_bal-mtv_bal*BMOTIVE)/sts_bal)*M_SQRT2):1+MathSin(-(1-(i<1?(i>0?i:0):1))*M_PI_2),
                                         j=mtv_bal-(lst_bal<mtv_bal?lst_bal:c),
                                         k=a-mtv_bal*BMOTIVE,
                                         motive=MathAbs(j)>=DBL_EPSILON?
                                                MathTanh(1-(lst_bal<mtv_bal?(MathAbs(h)>=DBL_EPSILON?(h>=0?MathPow(h,THIRD):-MathPow(-h,THIRD)):(k>=0?MathPow(k,THIRD):-MathPow(-k,THIRD)))/(j>=0?MathPow(j,THIRD):-MathPow(-j,THIRD)):1)):0;
                            if(m01_tim!=iTime(_Symbol,PERIOD_M1,0))
                                {
                                    if(m15_tim!=iTime(_Symbol,PERIOD_M15,0))
                                        {
                                            rcm_vol=RecommendedVolume();
                                            double Sm3[48];
                                            if(m30_tim!=iTime(_Symbol,PERIOD_M30,0))
                                                {
                                                    while(!IsStopped())
                                                        {
                                                            const int l=(int)MathFloor((int)(iTime(_Symbol,PERIOD_M30,1)-iTime(_Symbol,PERIOD_D1,iBarShift(_Symbol,PERIOD_D1,iTime(_Symbol,PERIOD_M30,1))))/(double)PeriodSeconds(PERIOD_M30));
                                                            sm3[l]+=MathMax(iHigh(_Symbol,PERIOD_M30,1),iOpen(_Symbol,PERIOD_M30,0))-MathMin(iLow(_Symbol,PERIOD_M30,1),iOpen(_Symbol,PERIOD_M30,0));
                                                            if((Dm3[l]+1)<=USHORT_MAX) Dm3[l]++;
                                                            else
                                                                {
                                                                    MqlRates rates[];
                                                                    if(CopyRates(_Symbol,PERIOD_M30,0,1000,rates)>999)
                                                                        {
                                                                            for(ushort z=999; z>1 && !IsStopped(); z--)
                                                                                {
                                                                                    const int t0=z-2,t1=z-1,lp=(int)MathFloor((int)(rates[t1].time-iTime(_Symbol,PERIOD_D1,iBarShift(_Symbol,PERIOD_D1,rates[t1].time)))/(double)PeriodSeconds(PERIOD_M30));
                                                                                    if(lp==l)
                                                                                        {
                                                                                            sm3[lp]-=MathMax(rates[t1].high,rates[t0].open)-MathMin(rates[t1].low,rates[t0].open);
                                                                                            break;
                                                                                        }
                                                                                }
                                                                        }
                                                                    else break;
                                                                }
                                                            for(ushort z=0; z<48 && !IsStopped(); z++) Sm3[z]=sm3[z]/(Dm3[z]>0?Dm3[z]:1);
                                                            if(!Norm3(Sm3)) break;
                                                            break;
                                                        }
                                                    m30_tim=iTime(_Symbol,PERIOD_M30,0);
                                                }
                                            while(!IsStopped())
                                                {
                                                    const int l=(int)MathFloor((int)(iTime(_Symbol,PERIOD_M15,2)-iTime(_Symbol,PERIOD_D1,iBarShift(_Symbol,PERIOD_D1,iTime(_Symbol,PERIOD_M15,2))))/(double)PeriodSeconds(PERIOD_M15));
                                                    sm5[l]+=MathAbs((MathMax(iHigh(_Symbol,PERIOD_M15,1),iOpen(_Symbol,PERIOD_M15,0))+MathMin(iLow(_Symbol,PERIOD_M15,1),iOpen(_Symbol,PERIOD_M15,0)))/2-(MathMax(iHigh(_Symbol,PERIOD_M15,2),iOpen(_Symbol,PERIOD_M15,1))+MathMin(iLow(_Symbol,PERIOD_M15,2),iOpen(_Symbol,PERIOD_M15,1)))/2);
                                                    if((Dm5[l]+1)<=USHORT_MAX) Dm5[l]++;
                                                    else
                                                        {
                                                            MqlRates rates[];
                                                            if(CopyRates(_Symbol,PERIOD_M15,0,1000,rates)>999)
                                                                {
                                                                    for(ushort z=998; z>1 && !IsStopped(); z--)
                                                                        {
                                                                            const int t0=z-2,t1=z-1,lp=(int)MathFloor((int)(rates[z].time-iTime(_Symbol,PERIOD_D1,iBarShift(_Symbol,PERIOD_D1,rates[z].time)))/(double)PeriodSeconds(PERIOD_M15));
                                                                            if(lp==l)
                                                                                {
                                                                                    sm5[lp]-=MathAbs((MathMax(rates[t1].high,rates[t0].open)+MathMin(rates[t1].low,rates[t0].open))/2-(MathMax(rates[z].high,rates[t1].open)+MathMin(rates[z].low,rates[t1].open))/2);
                                                                                    break;
                                                                                }
                                                                        }
                                                                }
                                                            else break;
                                                        }
                                                    for(ushort z=0; z<96 && !IsStopped(); z++) Sm5[z]=sm5[z]/(Dm5[z]>0?Dm5[z]:1);
                                                    if(!Norm5(Sm3,Sm5)) break;
                                                    break;
                                                }
                                            m15_tim=iTime(_Symbol,PERIOD_M15,0);
                                        }
                                    const ushort tmp_tim=(ushort)MathFloor((int)(iTime(_Symbol,PERIOD_M1,0)-iTime(_Symbol,PERIOD_D1,0))/(double)PeriodSeconds(PERIOD_M1)),
                                                 min_num=(tmp_tim-1)>=0?tmp_tim-1:1439;
                                    const uchar day_num=(uchar)((tmp_tim-1)>=0?time.day_of_week-1:((time.day_of_week-2)>=0?time.day_of_week-2:4));
                                    if((spd_avg[day_num][min_num]+1)<=INT_MAX) spd_avg[day_num][min_num]++;
                                    avg_spd[day_num][min_num]=spd_avg[day_num][min_num]>1?
                                                              (1-1/(double)spd_avg[day_num][min_num])*avg_spd[day_num][min_num]+
                                                              (spd_cnt>0?cnt_spd/(double)spd_cnt:0)/(double)spd_avg[day_num][min_num]:
                                                              (spd_cnt>0?cnt_spd/(double)spd_cnt:0);
                                    cnt_spd=0;
                                    spd_cnt=0;
                                    m01_tim=iTime(_Symbol,PERIOD_M1,0);
                                }
                            else
                                {
                                    const double ask=SymbolInfoDouble(_Symbol,SYMBOL_ASK),
                                                 bid=SymbolInfoDouble(_Symbol,SYMBOL_BID);
                                    if(ask>=_Point && MathIsValidNumber(ask) &&
                                            bid>=_Point && MathIsValidNumber(bid) &&
                                            (ask!=lst_ask || bid!=lst_bid) &&
                                            (ask-bid)>=_Point)
                                        {
                                            if((spd_cnt+1)<=INT_MAX)
                                                {
                                                    cnt_spd+=ask-bid;
                                                    spd_cnt++;
                                                }
                                            lst_ask=ask;
                                            lst_bid=bid;
                                        }
                                }
                            const int l=(int)MathFloor((int)(iTime(_Symbol,PERIOD_M15,0)-iTime(_Symbol,PERIOD_D1,0))/(double)PeriodSeconds(PERIOD_M15));
                            double td=(int)(TimeCurrent()-iTime(_Symbol,PERIOD_M15,0))/(double)PeriodSeconds(PERIOD_M15),
                                   td0=MathSqrt(1-MathPow(td,2)),
                                   td1=MathSqrt(1-MathPow(1-td,2));
                            const double tdm=sns_typ<0?-sns_typ:0,
                                         dif_vol=(MathSin(2*((Sm5[l]*td0+Sm5[l<95?l+1:0]*td1)/(td0+td1)-0.5)*M_PI_2)+1)/2;
                            double activity=dif_vol*(1+tdm)-tdm;
                            const ushort tmp_tim=(ushort)MathFloor((int)(iTime(_Symbol,PERIOD_M1,0)-iTime(_Symbol,PERIOD_D1,0))/(double)PeriodSeconds(PERIOD_M1)),
                                         min_num=(tmp_tim+1)<1440?tmp_tim+1:0;
                            const uchar day_num=(uchar)((tmp_tim+1)<1440?time.day_of_week-1:(time.day_of_week>4?0:time.day_of_week)),
                                        day_nuc=(uchar)time.day_of_week-1;
                            td=(int)(TimeCurrent()-iTime(_Symbol,PERIOD_M1,0))/(double)PeriodSeconds(PERIOD_M1);
                            td0=MathSqrt(1-MathPow(td,2));
                            td1=MathSqrt(1-MathPow(1-td,2));
                            double dec_act=(rsl_spd[day_nuc][tmp_tim]*td0+rsl_spd[day_num][min_num]*td1)/(td0+td1);
                            const double day_gol=mtv_bal-a,greed=1+fear;
                            if(cls_prf || mke_alr || snd_ntf)
                                {
                                    if((mke_alr || snd_ntf) && (!dln_alr || !dln_ntf) && stress<=(FLT_EPSILON-1))
                                        {
                                            const string s0="Critical Stress Level, "+nme_yor,
                                                         s1="Don't Get Upset.",
                                                         s2="It Is Recommended To Close All Opened Positions",
                                                         s3="And Have A Rest Today.";
                                            if(mke_alr && !dln_alr)
                                                {
                                                    Alert(s0,".");
                                                    Alert(s1);
                                                    Alert(s2);
                                                    Alert(s3);
                                                    dln_alr=true;
                                                }
                                            if(snd_ntf && !dln_ntf)
                                                {
                                                    SendNotification(s0+". "+s1+" "+s2+" "+s3);
                                                    dln_ntf=true;
                                                }
                                        }
                                    uint ttl=PositionsTotal();
                                    if(ttl>0)
                                        {
                                            const double m=day_gol/SQRTPI,n=day_gol-m;
                                            if(day_gol>=DBL_EPSILON && h>=(m+n*sns_typ))
                                                {
                                                    const double o=h*SQRTPI-day_gol,p=trl_prf;
                                                    trl_prf=o>p?o:p;
                                                    if(h<=trl_prf)
                                                        {
                                                            if(cls_prf)
                                                                {
                                                                    uchar try=0;
                                                                    while(ttl>0 && try<255 && !IsStopped())
                                                                            {
                                                                                for(uint z=0; z<ttl && !IsStopped(); z++)
                                                                                    {
                                                                                        const ulong tkt=PositionGetTicket(z);
                                                                                        if(tkt>0) if(Trd.PositionClose(tkt)) continue;
                                                                                    }
                                                                                Sleep(99);
                                                                                ttl=PositionsTotal();
                                                                                try++;
                                                                            }
                                                                }
                                                            const string s0="Well Done, "+nme_yor,
                                                                         s1="Your Daily Goal Has Been Reached.",
                                                                         s2="Profit Is "+DoubleToString(h,2)+" "+AccountInfoString(ACCOUNT_CURRENCY)+".",
                                                                         s3="It Is Recommended To Close All Opened Positions",
                                                                         s4="And Have A Rest Today.";
                                                            if(mke_alr && !dpn_alr)
                                                                {
                                                                    if(cls_prf)
                                                                        {
                                                                            Alert(s0+".");
                                                                            Alert(s1);
                                                                            Alert(s2);
                                                                        }
                                                                    else
                                                                        {
                                                                            Alert(s0+".");
                                                                            Alert(s1);
                                                                            Alert(s3);
                                                                            Alert(s4);
                                                                        }
                                                                    dpn_alr=true;
                                                                }
                                                            if(snd_ntf && !dpn_ntf)
                                                                {
                                                                    const string sr=s0+". "+s1+" ";
                                                                    SendNotification(cls_prf?sr+s2:sr+s3+" "+s4);
                                                                    dpn_ntf=true;
                                                                }
                                                            trl_prf=0;
                                                        }
                                                }
                                            else trl_prf=0;
                                        }
                                    else trl_prf=0;
                                }
                            activity=(activity<=-DBL_EPSILON?activity*(1/(tdm>0?tdm:1)):activity)-dec_act;
                            Comment("          Fear:  "+DoubleToString(fear,7),"\n",
                                    "        Stress:  "+DoubleToString(stress,7),"\n","\n",
                                    "        Greed:  "+DoubleToString(greed,7),"\n",
                                    "       Motive:  "+DoubleToString(motive,7),"\n","\n",
                                    " Confidence:  "+DoubleToString(act_cnf,7),"\n",
                                    "     Activity:   "+DoubleToString(activity>-1?activity:-1,7),"\n","\n",
                                    "     Volume:   "+DoubleToString(MathMin(MathMax(rcm_vol*greed*(1-dif_vol),
                                            SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN)),
                                            SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX)),2)+" LTS","\n","\n",                        // Recommended Volume
                                    "Trade Time:   "+DoubleToString(PeriodSeconds(PERIOD_M15)*3/(3600*THIRD),2)+" HRS","\n",         // Average Trade Time In Hours
                                    " Trade Goal:  "+DoubleToString(sts_bal,2)+" "+AccountInfoString(ACCOUNT_CURRENCY),"\n","\n",    // Current Trade Goal
                                    "  Daily Goal:  "+DoubleToString(day_gol,2)+" "+AccountInfoString(ACCOUNT_CURRENCY),"\n",        // Daily Goal
                                    "Annual Goal: "+DoubleToString(mtv_bal*M_E-a,2)+" "+AccountInfoString(ACCOUNT_CURRENCY));        // Annual Goal
                        }
                    else Comment("Off-Time.");
                }
            Sleep(slp_tim);
        }
    if(a>=DBL_EPSILON)
        {
            int fle=FileOpen(fle_pfx+fle_end,FILE_WRITE|FILE_CSV);
            FileWrite(fle,lst_bal);
            FileWrite(fle,mtv_bal);
            FileWrite(fle,chk_tim);
            FileWriteString(fle,nme_yor+"\n");
            FileWriteString(fle,TimeToString(m15_tim,TIME_DATE|TIME_MINUTES));
            FileClose(fle);
            fle=FileOpen(fle_pfx+_Symbol+"_"+fle_end,FILE_WRITE|FILE_CSV);
            for(uchar z=0; z<5; z++)
                {
                    for(ushort y=0; y<1440; y++) FileWrite(fle,avg_spd[z][y]);
                    for(ushort y=0; y<1440; y++) FileWrite(fle,spd_avg[z][y]);
                }
            for(uchar z=0; z<96; z++) FileWrite(fle,sm5[z]);
            for(uchar z=0; z<48; z++) FileWrite(fle,sm3[z]);
            for(uchar z=0; z<96; z++) FileWrite(fle,Dm5[z]);
            for(uchar z=0; z<48; z++) FileWrite(fle,Dm3[z]);
            FileWriteString(fle,TimeToString(m30_tim,TIME_DATE|TIME_MINUTES));
            FileClose(fle);
        }
    else
        {
            const string s0="Hi, "+nme_yor,
                         s1="Make A Deposit First, Please.";
            if(mke_alr)
                {
                    Alert(s0,".");
                    Alert(s1);
                }
            if(snd_ntf) SendNotification(s0+". "+s1);
            Print(s0+". "+s1);
        }
    Comment("");
}
//+------------------------------------------------------------------+