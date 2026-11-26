//+------------------------------------------------------------------+
//|                                              RISK CALCULATOR.mq5 |
//|                                  Copyright 2023, Igor Gerasimov. |
//|                                                 tgwls2@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Igor Gerasimov."
#property link      "tgwls2@gmail.com"
#property version   "1.00"
#property script_show_inputs
input double vlo=0.01;        // Trade Volume
input uchar  dgv=2;           // Volume Digits
input double spd=0.0005,      // Average Spread
             unc=1/(double)3, // Uncertainty
             max=20;          // Recommended Risk
double vol=StringToDouble(DoubleToString(vlo<SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN)?
                          SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN):
                          (vlo>SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX)?SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX):vlo),dgv));
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
    double m5s=0,m5d=0,
           m30s=0,m30d=0,
           h4s=0,h4d=0,
           d1s=0,d1d=0,
           w1s=0,w1d=0,
           m1s=0,m1d=0;
    for(uchar z=0; z<240 && !IsStopped(); z++)
        {
            GetRng(PERIOD_M5,z,m5s,m5d);
            GetRng(PERIOD_M30,z,m30s,m30d);
            GetRng(PERIOD_H4,z,h4s,h4d);
            GetRng(PERIOD_D1,z,d1s,d1d);
            GetRng(PERIOD_W1,z,w1s,w1d);
            GetRng(PERIOD_MN1,z,m1s,m1d);
        }
    double u=1+(unc>1?1:(unc<0?0:unc));
    m5s=m5s*u/m5d+spd;
    m30s=m30s*u/m30d+spd;
    h4s=h4s*u/h4d+spd;
    d1s=d1s*u/d1d+spd;
    w1s=w1s*u/w1d+spd;
    m1s=m1s*u/m1d+spd;
    double m5_b=0,m5_s=0,
           m30_b=0,m30_s=0,
           h4_b=0,h4_s=0,
           d1_b=0,d1_s=0,
           w1_b=0,w1_s=0,
           m1_b=0,m1_s=0;
    GetLos(vol,m5s,m5_b,m5_s);
    GetLos(vol,m30s,m30_b,m30_s);
    GetLos(vol,h4s,h4_b,h4_s);
    GetLos(vol,d1s,d1_b,d1_s);
    GetLos(vol,w1s,w1_b,w1_s);
    GetLos(vol,m1s,m1_b,m1_s);
    double b_swp=(SymbolInfoDouble(_Symbol,SYMBOL_SWAP_LONG)*SymbolInfoDouble(_Symbol,SYMBOL_SWAP_MONDAY)+
                  SymbolInfoDouble(_Symbol,SYMBOL_SWAP_LONG)*SymbolInfoDouble(_Symbol,SYMBOL_SWAP_TUESDAY)+
                  SymbolInfoDouble(_Symbol,SYMBOL_SWAP_LONG)*SymbolInfoDouble(_Symbol,SYMBOL_SWAP_WEDNESDAY)+
                  SymbolInfoDouble(_Symbol,SYMBOL_SWAP_LONG)*SymbolInfoDouble(_Symbol,SYMBOL_SWAP_THURSDAY)+
                  SymbolInfoDouble(_Symbol,SYMBOL_SWAP_LONG)*SymbolInfoDouble(_Symbol,SYMBOL_SWAP_FRIDAY)+
                  SymbolInfoDouble(_Symbol,SYMBOL_SWAP_LONG)*SymbolInfoDouble(_Symbol,SYMBOL_SWAP_SATURDAY)+
                  SymbolInfoDouble(_Symbol,SYMBOL_SWAP_LONG)*SymbolInfoDouble(_Symbol,SYMBOL_SWAP_SUNDAY))*vol,
                 s_swp=(SymbolInfoDouble(_Symbol,SYMBOL_SWAP_SHORT)*SymbolInfoDouble(_Symbol,SYMBOL_SWAP_MONDAY)+
                        SymbolInfoDouble(_Symbol,SYMBOL_SWAP_SHORT)*SymbolInfoDouble(_Symbol,SYMBOL_SWAP_TUESDAY)+
                        SymbolInfoDouble(_Symbol,SYMBOL_SWAP_SHORT)*SymbolInfoDouble(_Symbol,SYMBOL_SWAP_WEDNESDAY)+
                        SymbolInfoDouble(_Symbol,SYMBOL_SWAP_SHORT)*SymbolInfoDouble(_Symbol,SYMBOL_SWAP_THURSDAY)+
                        SymbolInfoDouble(_Symbol,SYMBOL_SWAP_SHORT)*SymbolInfoDouble(_Symbol,SYMBOL_SWAP_FRIDAY)+
                        SymbolInfoDouble(_Symbol,SYMBOL_SWAP_SHORT)*SymbolInfoDouble(_Symbol,SYMBOL_SWAP_SATURDAY)+
                        SymbolInfoDouble(_Symbol,SYMBOL_SWAP_SHORT)*SymbolInfoDouble(_Symbol,SYMBOL_SWAP_SUNDAY))*vol;
    m5_b+=b_swp/7;
    m30_b+=b_swp/7;
    h4_b+=b_swp/7;
    d1_b+=b_swp;
    w1_b+=b_swp*4.2;
    m1_b+=b_swp*4.2*6;
    m5_s+=s_swp/7;
    m30_s+=s_swp/7;
    h4_s+=s_swp/7;
    d1_s+=s_swp;
    w1_s+=s_swp*4.2;
    m1_s+=s_swp*4.2*6;
    double bmargin=Margin(ORDER_TYPE_BUY),smargin=Margin(ORDER_TYPE_SELL);
    while(bmargin==0 && smargin==0 && !IsStopped())
        {
            bmargin=Margin(ORDER_TYPE_BUY);
            smargin=Margin(ORDER_TYPE_SELL);
        }
    double b_margin=AccountInfoDouble(ACCOUNT_MARGIN)+bmargin,
           s_margin=AccountInfoDouble(ACCOUNT_MARGIN)+smargin,
           acc_margin=AccountInfoDouble(ACCOUNT_MARGIN_SO_CALL)*100,
           eb_eqy=AccountInfoDouble(ACCOUNT_EQUITY)-bmargin,
           es_eqy=AccountInfoDouble(ACCOUNT_EQUITY)-smargin,
           db_mgn=100/b_margin,
           ds_mgn=100/s_margin,
           m5_bm=acc_margin/((eb_eqy+m5_b*6)*db_mgn),m5_sm=acc_margin/((es_eqy+m5_s*6)*ds_mgn),
           m30_bm=acc_margin/((eb_eqy+m30_b*8)*db_mgn),m30_sm=acc_margin/((es_eqy+m30_s*8)*ds_mgn),
           h4_bm=acc_margin/((eb_eqy+h4_b*6)*db_mgn),h4_sm=acc_margin/((es_eqy+h4_s*6)*ds_mgn),
           d1_bm=acc_margin/((eb_eqy+d1_b*5)*db_mgn),d1_sm=acc_margin/((es_eqy+d1_s*5)*ds_mgn),
           w1_bm=acc_margin/((eb_eqy+w1_b*4.2)*db_mgn),w1_sm=acc_margin/((es_eqy+w1_s*4.2)*ds_mgn),
           m1_bm=acc_margin/((eb_eqy+m1_b*6)*db_mgn),m1_sm=acc_margin/((es_eqy+m1_s*6)*ds_mgn);
    string m5_bs,m5_ss,m5_ms,
           m30_bs,m30_ss,m30_ms,
           h4_bs,h4_ss,h4_ms,
           d1_bs,d1_ss,d1_ms,
           w1_bs,w1_ss,w1_ms,
           m1_bs,m1_ss,m1_ms;
    GetStr(m5_b*6,m5_s*6,(m5_bm<0 || m5_bm>100)?100:m5_bm,m5_bs,m5_ss,m5_ms);
    GetStr(m30_b*8,m30_s*8,(m30_bm<0 || m30_bm>100)?100:m30_bm,m30_bs,m30_ss,m30_ms);
    GetStr(h4_b*6,h4_s*6,(h4_bm<0 || h4_bm>100)?100:h4_bm,h4_bs,h4_ss,h4_ms);
    GetStr(d1_b*5,d1_s*5,(d1_bm<0 || d1_bm>100)?100:d1_bm,d1_bs,d1_ss,d1_ms);
    GetStr(w1_b*4.2,w1_s*4.2,(w1_bm<0 || w1_bm>100)?100:w1_bm,w1_bs,w1_ss,w1_ms);
    GetStr(m1_b*6,m1_s*6,(m1_bm<0 || m1_bm>100)?100:m1_bm,m1_bs,m1_ss,m1_ms);
    const double pm1_bm=(m1_bm<0 || m1_bm>100)?100:m1_bm,
                 pm1_sm=(m1_sm<0 || m1_sm>100)?100:m1_sm;
    Print("Calculation Of Loss Risk For Account: "+(string)AccountInfoInteger(ACCOUNT_LOGIN)+
          ", Leverage: 1/"+(string)AccountInfoInteger(ACCOUNT_LEVERAGE)+
          ", Symbol: "+_Symbol+", Volume "+DoubleToString(vol,2));
    Print("Buy Margin Is "+DoubleToString(bmargin,(int)AccountInfoInteger(ACCOUNT_CURRENCY_DIGITS))+" "+AccountInfoString(ACCOUNT_CURRENCY)+
          ", Sell Margin Is "+DoubleToString(smargin,(int)AccountInfoInteger(ACCOUNT_CURRENCY_DIGITS))+" "+AccountInfoString(ACCOUNT_CURRENCY)+
          ", Average Buy Swap Is "+DoubleToString(-b_swp/7,(int)AccountInfoInteger(ACCOUNT_CURRENCY_DIGITS))+" "+AccountInfoString(ACCOUNT_CURRENCY)+
          ", Average Sell Swap Is "+DoubleToString(-s_swp/7,(int)AccountInfoInteger(ACCOUNT_CURRENCY_DIGITS))+" "+AccountInfoString(ACCOUNT_CURRENCY));
    Print("Trade Time,        Buy Risk In "+AccountInfoString(ACCOUNT_CURRENCY)+
          ",                Sell Risk In "+AccountInfoString(ACCOUNT_CURRENCY)+
          ",          Buy Risk Of Margin Call In %"+",  Sell Risk Of Margin Call In %");
    Print("30 Minutes:             "+GetsTr(m5_b,m5_s,6,m5_bs,m5_ss,m5_ms,m5_bm,m5_sm));
    Print("4 Hours:                "+GetsTr(m30_b,m30_s,8,m30_bs,m30_ss,m30_ms,m30_bm,m30_sm));
    Print("1 Day:                  "+GetsTr(h4_b,h4_s,6,h4_bs,h4_ss,h4_ms,h4_bm,h4_sm));
    Print("1 Week:                 "+GetsTr(d1_b,d1_s,5,d1_bs,d1_ss,d1_ms,d1_bm,d1_sm));
    Print("1 Month:                "+GetsTr(w1_b,w1_s,4.2,w1_bs,w1_ss,w1_ms,w1_bm,w1_sm));
    Print("Half Year:              "+GetsTr(m1_b,m1_s,6,m1_bs,m1_ss,m1_ms,m1_bm,m1_sm));
    if(vol>SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN) && (pm1_bm>max || pm1_sm>max))
        {
            while(!IsStopped())
                {
                    if((vol-SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN))>=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN)) vol-=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
                    else break;
                    GetLos(vol,m1s,m1_b,m1_s);
                    b_swp=(SymbolInfoDouble(_Symbol,SYMBOL_SWAP_LONG)*SymbolInfoDouble(_Symbol,SYMBOL_SWAP_MONDAY)+
                           SymbolInfoDouble(_Symbol,SYMBOL_SWAP_LONG)*SymbolInfoDouble(_Symbol,SYMBOL_SWAP_TUESDAY)+
                           SymbolInfoDouble(_Symbol,SYMBOL_SWAP_LONG)*SymbolInfoDouble(_Symbol,SYMBOL_SWAP_WEDNESDAY)+
                           SymbolInfoDouble(_Symbol,SYMBOL_SWAP_LONG)*SymbolInfoDouble(_Symbol,SYMBOL_SWAP_THURSDAY)+
                           SymbolInfoDouble(_Symbol,SYMBOL_SWAP_LONG)*SymbolInfoDouble(_Symbol,SYMBOL_SWAP_FRIDAY)+
                           SymbolInfoDouble(_Symbol,SYMBOL_SWAP_LONG)*SymbolInfoDouble(_Symbol,SYMBOL_SWAP_SATURDAY)+
                           SymbolInfoDouble(_Symbol,SYMBOL_SWAP_LONG)*SymbolInfoDouble(_Symbol,SYMBOL_SWAP_SUNDAY))*vol;
                    s_swp=(SymbolInfoDouble(_Symbol,SYMBOL_SWAP_SHORT)*SymbolInfoDouble(_Symbol,SYMBOL_SWAP_MONDAY)+
                           SymbolInfoDouble(_Symbol,SYMBOL_SWAP_SHORT)*SymbolInfoDouble(_Symbol,SYMBOL_SWAP_TUESDAY)+
                           SymbolInfoDouble(_Symbol,SYMBOL_SWAP_SHORT)*SymbolInfoDouble(_Symbol,SYMBOL_SWAP_WEDNESDAY)+
                           SymbolInfoDouble(_Symbol,SYMBOL_SWAP_SHORT)*SymbolInfoDouble(_Symbol,SYMBOL_SWAP_THURSDAY)+
                           SymbolInfoDouble(_Symbol,SYMBOL_SWAP_SHORT)*SymbolInfoDouble(_Symbol,SYMBOL_SWAP_FRIDAY)+
                           SymbolInfoDouble(_Symbol,SYMBOL_SWAP_SHORT)*SymbolInfoDouble(_Symbol,SYMBOL_SWAP_SATURDAY)+
                           SymbolInfoDouble(_Symbol,SYMBOL_SWAP_SHORT)*SymbolInfoDouble(_Symbol,SYMBOL_SWAP_SUNDAY))*vol;
                    m1_b+=b_swp*4.2*6;
                    m1_s+=s_swp*4.2*6;
                    bmargin=Margin(ORDER_TYPE_BUY);
                    smargin=Margin(ORDER_TYPE_SELL);
                    while(bmargin==0 && smargin==0 && !IsStopped())
                        {
                            bmargin=Margin(ORDER_TYPE_BUY);
                            smargin=Margin(ORDER_TYPE_SELL);
                        }
                    if(bmargin==0 || smargin==0) continue;
                    b_margin=AccountInfoDouble(ACCOUNT_MARGIN)+bmargin;
                    s_margin=AccountInfoDouble(ACCOUNT_MARGIN)+smargin;
                    acc_margin=AccountInfoDouble(ACCOUNT_MARGIN_SO_CALL)*100;
                    m1_bm=acc_margin/(((AccountInfoDouble(ACCOUNT_EQUITY)-bmargin)+m1_b*6)*100/b_margin);
                    m1_sm=acc_margin/(((AccountInfoDouble(ACCOUNT_EQUITY)-smargin)+m1_s*6)*100/s_margin);
                    if((((m1_bm<0 || m1_bm>100)?100:m1_bm)<=max && ((m1_sm<0 || m1_sm>100)?100:m1_sm)<=max) || vol<=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN)) break;
                }
            Print("Recommended Volume For Symbol: "+_Symbol+" Is "+DoubleToString(vol,2));
        }
    else if(vol<=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX) && pm1_bm<=max && pm1_sm<=max) Print("Used Volume "+DoubleToString(vol,2)+" For Symbol: "+_Symbol+" Is OK.");
    else Print("Used Volume "+DoubleToString(vol,2)+" For Symbol: "+_Symbol+" Is Too High. Please Be Carefull.");
}
//+------------------------------------------------------------------+
//| GetsTr                                                           |
//+------------------------------------------------------------------+
string GetsTr(const double bp,const double sp,const double mp,const string bs,const string ss,const string ms,const double bm,const double sm)
{
    return(DoubleToString(-bp*mp,(int)AccountInfoInteger(ACCOUNT_CURRENCY_DIGITS))+bs+
           DoubleToString(-sp*mp,(int)AccountInfoInteger(ACCOUNT_CURRENCY_DIGITS))+ss+
           DoubleToString((bm<0 || bm>100)?100:bm,2)+ms+DoubleToString((sm<0 || sm>100)?100:sm,2));
}
//+------------------------------------------------------------------+
//| Margin                                                           |
//+------------------------------------------------------------------+
double Margin(const ENUM_ORDER_TYPE type)
{
    MqlTradeRequest request= {};
    MqlTradeCheckResult  result= {};
    request.action   =TRADE_ACTION_DEAL;
    request.symbol   =_Symbol;
    request.volume   =StringToDouble(DoubleToString(vol,dgv));
    request.type     =type;
    request.price    =StringToDouble(DoubleToString((type==ORDER_TYPE_BUY?SymbolInfoDouble(_Symbol,SYMBOL_ASK):SymbolInfoDouble(_Symbol,SYMBOL_BID)),_Digits));
    if(OrderCheck(request,result)) return(result.margin);
    else return(0);
}
//+------------------------------------------------------------------+
//| GetRng                                                           |
//+------------------------------------------------------------------+
void GetRng(const ENUM_TIMEFRAMES P,const uchar z,double &S,double &D)
{
    const double s=MathMax(iLow(_Symbol,P,z+1),iHigh(_Symbol,P,z))-MathMin(iHigh(_Symbol,P,z+1),iLow(_Symbol,P,z));
    S+=MathPow(s,2);
    D+=s;
    return;
}
//+------------------------------------------------------------------+
//| GetLos                                                           |
//+------------------------------------------------------------------+
void GetLos(const double v,const double p,double &b,double &s)
{
    if(!OrderCalcProfit(ORDER_TYPE_BUY,_Symbol,v,StringToDouble(DoubleToString(iOpen(_Symbol,PERIOD_M1,0),_Digits)),StringToDouble(DoubleToString(iOpen(_Symbol,PERIOD_M1,0)-p,_Digits)),b)) b=0;
    if(!OrderCalcProfit(ORDER_TYPE_SELL,_Symbol,v,StringToDouble(DoubleToString(iOpen(_Symbol,PERIOD_M1,0),_Digits)),StringToDouble(DoubleToString(iOpen(_Symbol,PERIOD_M1,0)+p,_Digits)),s)) s=0;
    return;
}
//+------------------------------------------------------------------+
//| GetStr                                                           |
//+------------------------------------------------------------------+
void GetStr(const double b,const double s,const double m,string &bs,string &ss,string &ms)
{
    StringInit(bs,28-(StringLen(DoubleToString(-b,(int)AccountInfoInteger(ACCOUNT_CURRENCY_DIGITS)))-4),StringGetCharacter(" ",0));
    StringInit(ss,28-(StringLen(DoubleToString(-s,(int)AccountInfoInteger(ACCOUNT_CURRENCY_DIGITS)))-4),StringGetCharacter(" ",0));
    StringInit(ms,28-(StringLen(DoubleToString(m,2))-4),StringGetCharacter(" ",0));
    return;
}
//+------------------------------------------------------------------+
