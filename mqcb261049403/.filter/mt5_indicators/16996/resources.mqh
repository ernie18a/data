struct SPoint
{
    double mAsk;
    double mBid;
    double mLow;
    double mHigh;
    double mOpen;
    double mClose;
    double mPoint;
    double mSpread;
    double mVolume;
    datetime mTime;
};

struct SSymbol
{
    string mName;
    double mMean;
    double mUnit;
    double mOrder;
};

struct SSeries
{
    SSymbol mSymbol;
    SPoint mPoints[];
};

struct SMatrix
{
    SSymbol mSymbol;
    double mAsk[];
    double mBid[];
    double mLow[];
    double mHigh[];
    double mOpen[];
    double mClose[];
    double mPoint[];
    double mSpread[];
    double mVolume[];
    datetime mTime[];
};

struct SGroup
{
    string mName;
    string mMessage;
    double mPrice;
    double mMean;
};

struct SDeal
{
    int mEntry;
    int mDirection;
    ulong mTicket;
    string mName;
    double mPrice;
    double mVolume;
    double mSummary;
    datetime mTime;
};

struct SBet
{
    double mCount;
    double mMinus;
    double mPlus;
};

double pipsToMoney(string symbol, double volume, double pips)
{
    double step = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
    double value = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);
    return pips * value * volume / step;
}

int maxPrecision()
{
    int digits = 0;
    double v = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
    
    for (int k = 1; k < 100 && MathFloor(v * k) == 0; k *= 10, digits++);
    
    return digits;
}

double getMargin(string symbol, double volume, string end = "")
{
    long leverage = AccountInfoInteger(ACCOUNT_LEVERAGE);
    double contract = SymbolInfoDouble(symbol, SYMBOL_TRADE_CONTRACT_SIZE) * volume;
    string currency = StringSubstr(symbol, 0, 3) + AccountInfoString(ACCOUNT_CURRENCY) + end;
    return SymbolInfoDouble(currency, SYMBOL_LAST) * contract / leverage;
}

bool isTradingTime(string shours = "0:30-23:30", string sdays = "0-6")
{
    string days[];
    string hours[];
    
    StringSplit(sdays, '-', days);
    StringSplit(shours, '-', hours);

    MqlDateTime o = {0};
    datetime now = TimeCurrent(o);
    
    string day = 
        string(o.year) + "." + 
        string(o.mon) + "." + 
        string(o.day);

    datetime H1 = StringToTime(day + " " + hours[0]);
    
    if (hours[0] > hours[1])
    {
        day = 
            string(o.year) + "." + 
            string(o.mon) + "." + 
            string(o.day + 1);
    }
    
    datetime H2 = StringToTime(day + " " + hours[1]);
    
    int D1 = int(days[0]);
    int D2 = int(days[ArraySize(hours) - 1]);

    if (now >= H1 && 
        now <= H2 && 
        o.day_of_week >= D1 && 
        o.day_of_week <= D2) 
            return true;

    return false;
}

double getTickCost(string symbol, bool check = false)
{
    double cost = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);

    if (cost == 0)
    {
        string altSymbol = StringSubstr(symbol, 3) + "USD";

        if (SymbolSelect(altSymbol, true))
        {
            double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
            double contract = SymbolInfoDouble(symbol, SYMBOL_TRADE_CONTRACT_SIZE);
            double crossCost = SymbolInfoDouble(altSymbol, SYMBOL_TRADE_TICK_VALUE);
            cost = crossCost == 0 && check ? 0 : (point * contract / crossCost);
        }
    }
    
    return cost;
}

datetime getLastSymbolTime(string symbol, ENUM_TIMEFRAMES period = PERIOD_CURRENT, int start = 0)
{
    datetime moment[];
    CopyTime(symbol, period, start, 1, moment);
    return moment[0];
}

datetime getLastTime(SSeries& series[], ENUM_TIMEFRAMES period, int start)
{
    datetime startTime = 0;
    int count = ArraySize(series);

    for (int k = 0; k < count; k++)
    {
        startTime = MathMax(startTime, getLastSymbolTime(series[k].mSymbol.mName, period, start));
    }

    return startTime;
}

int getQuotes(SSeries& series[], ENUM_TIMEFRAMES period, int order, int depth, int position)
{
    int items = 0;

    for (int k = 0; k < order; k++)
    {
        MqlRates rates[];
        int bars = MathMin(depth, Bars(series[k].mSymbol.mName, period));
        int counted = CopyRates(series[k].mSymbol.mName, period, position, bars, rates);

        if (counted < 1)
        {
            Print("Loading : " + series[k].mSymbol.mName);
            return 0;
        }
        
        int index = counted - 1;
        
        items = items == 0 ? counted : MathMin(items, counted);
        
        for (int n = index; n > -1; n--)
        {
            series[k].mPoints[n].mLow = rates[n].low;
            series[k].mPoints[n].mHigh = rates[n].high;
            series[k].mPoints[n].mOpen = rates[n].open;
            series[k].mPoints[n].mClose = rates[n].close;
            series[k].mPoints[n].mPoint = rates[n].close;
            series[k].mPoints[n].mSpread = rates[n].spread;
            series[k].mPoints[n].mVolume = double(rates[n].tick_volume);
            series[k].mPoints[n].mTime = rates[n].time;
        }
    }

    return items;
}

double EMA(double current, double previous, int period)
{
    double result = 0.0;

    if (period > 0)
    {
        double pr = 2.0 / (period + 1.0);
        result = current * pr + previous * (1 - pr);
    }

    return result;
}

int synchronize(SSeries& series[], ENUM_TIMEFRAMES period, int order, int depth, int position, bool closes = true)
{
    int items = 0;
    datetime lastTime = getLastTime(series, period, position);

    for (int k = 0; k < order; k++)
    {
        MqlRates rates[];
        datetime currentTime = lastTime;
        double points = SymbolInfoDouble(series[k].mSymbol.mName, SYMBOL_POINT);
        int bars = MathMin(depth, Bars(series[k].mSymbol.mName, period));
        int counted = CopyRates(series[k].mSymbol.mName, period, position, bars, rates);

        if (counted < 1)
        {
            Print("Synchronization : " + series[k].mSymbol.mName);
            return 0;
        }

        int index = counted - 1;
        
        items = items == 0 ? counted : MathMin(items, counted);

        series[k].mSymbol.mMean = 0;
        series[k].mPoints[depth - 1].mLow = rates[index].low;
        series[k].mPoints[depth - 1].mHigh = rates[index].high;
        series[k].mPoints[depth - 1].mOpen = rates[index].open;
        series[k].mPoints[depth - 1].mClose = rates[index].close;
        series[k].mPoints[depth - 1].mPoint = closes ? rates[index].close : rates[index].open;
        series[k].mPoints[depth - 1].mSpread = rates[index].spread * points;
        series[k].mPoints[depth - 1].mTime = rates[index].time;

        MqlDateTime dates = {0};
        int secondsInPeriod = PeriodSeconds(period);
        int secondsInWeekend = 2 * PeriodSeconds(PERIOD_D1);

        for (int n = depth - 1; n >= 0; n--)
        {
            if (secondsInWeekend >= secondsInPeriod) 
            {
                TimeToStruct(currentTime, dates);

                if (dates.day_of_week == 0) 
                {
                    currentTime -= secondsInWeekend;
                }
            }

            if (currentTime == rates[index].time)
            {
                series[k].mPoints[n].mSpread = rates[index].spread * points;
                series[k].mPoints[n].mPoint = closes ? rates[index].close : rates[index].open;
                series[k].mPoints[n].mClose = rates[index].close;
                series[k].mPoints[n].mOpen = rates[index].open;
                series[k].mPoints[n].mHigh = rates[index].high;
                series[k].mPoints[n].mLow = rates[index].low;
                index = index > 0 ? index - 1 : index;
            }
            else if (n < depth - 1)
            {
                series[k].mPoints[n].mSpread = series[k].mPoints[n + 1].mSpread;
                series[k].mPoints[n].mPoint = series[k].mPoints[n + 1].mPoint;
                series[k].mPoints[n].mClose = series[k].mPoints[n + 1].mClose;
                series[k].mPoints[n].mOpen = series[k].mPoints[n + 1].mOpen;
                series[k].mPoints[n].mHigh = series[k].mPoints[n + 1].mHigh;
                series[k].mPoints[n].mLow = series[k].mPoints[n + 1].mLow;
            }

            series[k].mPoints[n].mTime = currentTime;
            series[k].mSymbol.mMean += series[k].mPoints[n].mPoint;
            currentTime -= PeriodSeconds(period);
        }
        
        series[k].mSymbol.mMean /= depth;
    }

    return items;
}

double getDeviation(SSeries& S[], int index, int depth)
{
    double deviation = 0;

    for (int n = 0; n < depth; n++) 
    {
        deviation += S[index].mPoints[n].mPoint * S[index].mPoints[n].mPoint;
    }

    return MathSqrt(deviation / depth);
}

double getSpread(string symbol, int depth)
{
    double spread = 0;
    MqlRates rates[];

    CopyRates(symbol, _Period, 0, depth, rates);
        
    for (int n = 0; n < depth; n++) 
    {
        spread += rates[n].spread;
    }
    
    return spread * SymbolInfoDouble(symbol, SYMBOL_POINT) / depth;
}

/**
 * Return trading results grouped by probability
 */
string getTrades(SDeal &deals[], SSeries &results[], string symbol = NULL, int mode = 0)
{
    string result = "";
    
    int index = 0;
    int position = 0;
    int K = ArraySize(deals);
    ArrayResize(results, index + 1);
    
    for (int k = 0; k < K; k++)
    {
        if (deals[k].mName == symbol || deals[k].mName == NULL)
        {
            int item = 0;
        
            switch (mode)
            {
                case 0 : item = deals[k].mSummary > 0 ? 1 : 0; break;
                case 1 : item = deals[k].mDirection > 0 ? 1 : 0; break;
            }
            
            ArrayResize(results[index].mPoints, position + 1);
            results[index].mPoints[position].mPoint = item;
            position++;
        
            if (item == 1)
            {
                position = 0;
                ArrayResize(results, index + 2);
                ZeroMemory(results[index + 1]);
                index++;
            }
        }
    }
    
    int max = 0;
    int N = ArraySize(results);
    
    for (int k = 0; k < N; k++)
    {
        int M = ArraySize(results[k].mPoints);
        max = M > max ? M : max;
    }

    for (int k = 0; k < N; k++)
    {
        int M = ArraySize(results[k].mPoints);

        for (int n = M; n < max; n++)
        {
            ArrayResize(results[k].mPoints, n + 1);
            results[k].mPoints[n].mPoint = 2;
        }
    }

    for (int k = 0; k < N; k++)
    {
        int M = ArraySize(results[k].mPoints);

        for (int n = 0; n < M; n++)
        {
            result += DoubleToString(results[k].mPoints[n].mPoint, 0) + (n < M - 1 ? ":" : "");
        }
        
        result += "\n";
    }
    
    return result;
}

int getDeals(SDeal &deals[], string symbol = NULL, ENUM_DEAL_ENTRY entry = -1, ENUM_DEAL_TYPE direction = -1)
{
    ArrayResize(deals, 0);

    if (HistorySelect(0, TimeCurrent()))
    {
        int index = 0;
        int count = HistoryDealsTotal();
        
        for (int k = 0; k < count; k++)
        {
            ulong ticket = HistoryDealGetTicket(k);
            ENUM_DEAL_TYPE route = (ENUM_DEAL_TYPE) HistoryDealGetInteger(ticket, DEAL_TYPE);
            ENUM_DEAL_ENTRY deal = (ENUM_DEAL_ENTRY) HistoryDealGetInteger(ticket, DEAL_ENTRY);

            bool A = entry == -1 || entry == deal;
            bool B = direction == -1 || direction == route;

            if (A && B)
            {
                ArrayResize(deals, index + 1);
                deals[index].mEntry = deal;
                deals[index].mTicket = ticket;
                deals[index].mName = HistoryDealGetString(ticket, DEAL_SYMBOL);
                deals[index].mPrice = HistoryDealGetDouble(ticket, DEAL_PRICE);
                deals[index].mSummary = HistoryDealGetDouble(ticket, DEAL_PROFIT);
                deals[index].mTime = datetime(HistoryDealGetInteger(ticket, DEAL_TIME));
                deals[index].mVolume = HistoryDealGetDouble(ticket, DEAL_VOLUME);
                deals[index].mDirection = HistoryDealGetInteger(ticket, DEAL_TYPE) == DEAL_TYPE_BUY ? 1 : -1;
                index++;
            }
        }
    }
    
    return ArraySize(deals);
}

/**
 * Make two positions of equal size
 */
double getNextSize(double oppositeSize, double index = 0)
{
    double size = oppositeSize * MathMax(index, 0);
    return NormalizeDouble(size, maxPrecision());
}

void logData(string data)
{
    int FH = FileOpen("debug.log", FILE_WRITE | FILE_READ | FILE_SHARE_READ | FILE_ANSI);
    FileSeek(FH, 0, SEEK_END);
    FileWrite(FH, data);
	FileFlush(FH);
	FileClose(FH);
}

int getChain(uchar &codes[], int order)
{
    ArraySetAsSeries(codes, true);

    for (int k = 0; k < order; k++) 
    {
        if (codes[k] == 0)
        {
            codes[k] = 1;
            return 1;
        }
        else
        {
            codes[k] = 0;
        }
    }

    return 0;
}

/**
 * List combinations of provided currencies
 */
int listCombinations(SSeries& series[], string names, string end = "", int complete = 0)
{
    string syms[];
    int index = 0;
    int count = StringSplit(names, ',', syms);

    for (int k = 0; k < count; k++)
    {
        for (int n = 0; n < count; n++)
        {
            string s1 = syms[k] + syms[n];
            string s2 = syms[n] + syms[k];
            bool c1 = SymbolSelect(s1 + end, true);
            bool c2 = SymbolSelect(s2 + end, true);

            if ((c1 && SymbolInfoInteger(s1 + end, SYMBOL_TRADE_MODE) == SYMBOL_TRADE_MODE_FULL) || 
                (c2 && SymbolInfoInteger(s2 + end, SYMBOL_TRADE_MODE) == SYMBOL_TRADE_MODE_FULL))
                {
                    ArrayResize(series, index + 1);
                    series[index].mSymbol.mName = (c1 ? s1 : s2) + (complete ? end : "");
                    index++;
                }
        }
    }

    return index;
}

/**
 * Split string of symbols by separator
 */
int listPairs(SSeries& series[], string names)
{
    string syms[];
    int index = 0, count = StringSplit(names, ',', syms);

    for (int k = 0; k < count; k++)
    {
        string inverse = StringSubstr(syms[k], 3, 3) + StringSubstr(syms[k], 0, 3) + StringSubstr(syms[k], 6);

        if (SymbolSelect(syms[k], true) && SymbolInfoInteger(syms[k], SYMBOL_TRADE_MODE) == SYMBOL_TRADE_MODE_FULL)
        {
            ArrayResize(series, index + 1); 
            series[index].mSymbol.mName = syms[k];
            series[index].mSymbol.mOrder = 0;
            index++;
        }
        else if (SymbolSelect(inverse, true) && SymbolInfoInteger(inverse, SYMBOL_TRADE_MODE) == SYMBOL_TRADE_MODE_FULL)
        {
            ArrayResize(series, index + 1); 
            series[index].mSymbol.mName = inverse;
            series[index].mSymbol.mOrder = 1;
            index++;
        }
    }
    
    return index;
}

int getGroups(SSeries &series[], SGroup &groups[], string symbol = NULL)
{
    int n = 0;
    uchar codes[];
    
    int K = ArraySize(series);
    ArrayResize(codes, K);
    ArrayFill(codes, 0, K, 0);

    while (getChain(codes, K))
    {
        string name;
    
        for (int k = 0; k < K; k++) 
        {
            name += codes[k] ? (series[k].mSymbol.mName + ":") : "";
        }
        
        if (symbol == NULL || isChannel(name, symbol))
        {
            ArrayResize(groups, n + 1);
            groups[n++].mName = StringSubstr(name, 0, StringLen(name) - 1);
        }
   }

    return ArraySize(groups);
}

int isChannel(string name, string symbol = NULL)
{
    string T;
    string B;
    string sT;
    string sB;

    ZeroMemory(T);
    ZeroMemory(B);

    int L = StringLen(name);
    int E = StringLen(":");

    for (int k = 0; k < L; k += E + 6)
    {
        sT = StringSubstr(name, k, 3);
        sB = StringSubstr(name, k + 3, 3);

        int D1 = StringFind(T, sB);
        int D2 = StringFind(B, sT);

        if (D1 > -1) T = StringSubstr(T, 0, D1) + StringSubstr(T, D1 + 3, StringLen(T)); else B += sB;
        if (D2 > -1) B = StringSubstr(B, 0, D2) + StringSubstr(B, D2 + 3, StringLen(B)); else T += sT;
    }

    return 
        (symbol == NULL && StringLen(T) == 0 && StringLen(B) == 0) || 
        (StringLen(B) == 0 && StringFind(T, symbol) > -1) || 
        (StringLen(T) == 0 && StringFind(B, symbol) > -1);
}

string logRange(SSeries &series[], SBet &results[])
{
    string bets = "";
    int K = ArraySize(series);
    
    if (K > 0)
    {
        int N = ArraySize(series[0].mPoints);
        ArrayResize(results, N);
    
        for (int n = 0; n < N; n++)
        {
            int C = 0;
            int W = 0;
        
            for (int k = 0; k < K; k++)
            {
                if (series[k].mPoints[n].mPoint < 2)
                {
                    C++;
                    if (series[k].mPoints[n].mPoint == 1) W += int(series[k].mPoints[n].mPoint);
                }
            }
    
            results[n].mPlus = W;
            results[n].mCount = C;
            results[n].mMinus = C - W;
    
            bets += 
                IntegerToString(n) + " : " + 
                IntegerToString(C) + " : " + 
                IntegerToString(W) + " : " + 
                IntegerToString(C - W) + (n < N - 1 ? "\n" : "");
        }
    }
    
    return bets;
}

/**
 * Check if new bar has come
 */
int isNewPeriod(int bars = 0, ENUM_TIMEFRAMES period = PERIOD_CURRENT)
{
    static datetime last = getLastSymbolTime(Symbol(), Period());
    
    if (int(getLastSymbolTime(Symbol(), period)) - int(last) > PeriodSeconds(period) * bars)
    {
        last = getLastSymbolTime(Symbol(), period);
        return 1;
    }
    
    return 0;
}

/**
 * Get random number, may be restricted to binary only
 */
int getRandom(bool binary, int size = 0)
{
    if (size <= 0 || size >= 32768)
    {
        size = 32768;
    }

    int number = 1 + size * MathRand() / 32768;

    if (binary)
    {
        return number % 2 == 0 ? 1 : -1;
    }

    return number;
}

/**
 * Class to parse math formulas with constansts and variable
 */
class CExpression 
{
    public:

        string separators[];
        int separatorsCount;

        CExpression(void)
        {
            string operators[] = {"^", "/", "*", "+", "-", "(", ")"};
            ArrayCopy(this.separators, operators);
            this.separatorsCount = ArraySize(this.separators);
        };

        /**
         * Check if provided string is an operator
         */
        bool isOperator(string v)
        {
            bool op = false;
        
            for (int k = 0; k < this.separatorsCount; k++)
            {
                if (this.separators[k] == v)
                {
                    op = true;
                }
            }
        
            return op;
        };
        
        /**
         * Get priority of an operator
         */
        int order(string v) 
        {
            char x = (char) StringGetCharacter(v, 0);
        
            switch (x)
            {
                case '+': return 1;
                case '-': return 1;
                case '*': return 2;
                case '/': return 2;
                case '^': return 3;
            }
            
            return 0;
        };

        /** 
         * Execute operation
         */
        double operation(double a, double b, string op) 
        {
            char x = (char) StringGetCharacter(op, 0);
        
            switch (x)
            {
                case '+': return a + b;
                case '-': return a - b;
                case '*': return a * b;
                case '/': return b == 0 ? 0 : a / b;
                case '^': return MathPow(a, b);
            }
            
            return 0;
        };
        
        /**
         * Compare priorities of 2 operators
         */
        bool isHigher(string a, string b) 
        {
            return this.order(a) >= this.order(b);
        };

        /**
         * Remove extra spaces, etc, and split by single space
         */
        int splitExpression(string source, string &expression[]) 
        {
            for (int k = 0; k < this.separatorsCount; k++) 
            {
                StringReplace(source, this.separators[k], " " + this.separators[k] + " ");
            }
            
            while (StringReplace(source, "  ", " ") > 0);

            return StringSplit(source, ' ', expression);
        };
        
        /**
         * Turn expression from human readable form to PostFix format
         */
        string getExpression(string source, string &expression[]) 
        {
            string parts[];

            this.splitExpression(source, parts);

            string queue = "";
            int operatorIndex = -1;
            string operatorStack[100] = {0};

            int size = ArraySize(parts);

            for (int i = 0; i < size; i++) 
            {
                string token = parts[i];

                if (this.isOperator(token)) 
                {
                    if (token == "(") 
                    {
                        operatorIndex++;
                        operatorStack[operatorIndex] = token;
                    } 
                    else if (token == ")") 
                    {    
                        while (operatorStack[operatorIndex] != "(") 
                        {
                            queue += operatorStack[operatorIndex] + " ";
                            operatorIndex--;
                        }
                        
                        operatorIndex--;
                    } 
                    else 
                    {
                        string o1 = token;
                        string o2 = operatorIndex >= 0 ? operatorStack[operatorIndex] : "";

                        while (this.isHigher(o2, o1)) 
                        {
                            queue += operatorStack[operatorIndex] + " ";
                            operatorIndex--;
                            o2 = operatorIndex >= 0 ? operatorStack[operatorIndex] : "";
                        }
                        
                        operatorIndex++;
                        operatorStack[operatorIndex] = o1;
                    }
                } 
                else 
                {
                    queue += token + " ";
                }
            }

            while (operatorIndex >= 0) 
            {
                queue += operatorStack[operatorIndex] + " ";
                operatorIndex--;
            }

            while (StringReplace(queue, "  ", " ") > 0);
            
            StringSplit(queue, ' ', expression);

            return queue;
        };
        
        /**
         * Substitute variables and evaluate expression
         */
        double getResult(const string &variables[], string &names[], string &values[])
        {
            string items[];
            int stackIndex = -1;
            double stack[100] = {0};
            
            ArrayCopy(items, variables);
            
            int count = ArraySize(items);
            int evaluations = ArraySize(names);

            for (int k = 0; k < evaluations; k++) 
            {
                for (int n = 0; n < count; n++) 
                {
                    if (items[n] == names[k]) 
                    {
                        items[n] = values[k];
                    }
                }
            }
string x = "";
for (int k = 0; k < count; k++) x += items[k] + " ";
Print(x);
            for (int k = 0; k < count; k++) {
            
                if (this.isOperator(items[k])) 
                {
                    double b = stack[stackIndex];
                    stackIndex--;
                    double a = stack[stackIndex];
                    stackIndex--;

                    stackIndex++;
                    stack[stackIndex] = this.operation(a, b, items[k]);
                } 
                else if (items[k] != "")
                {
                    stackIndex++;
                    stack[stackIndex] = StringToDouble(items[k]);
                }
            }

            return stack[0];
        };
};