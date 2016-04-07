//+------------------------------------------------------------------+
//| Implementation of AC Strategy based on AC indicator.
//| Docs: https://docs.mql4.com/indicators/iac, https://www.mql5.com/en/docs/indicators/iac
//+------------------------------------------------------------------+
class AC: public Strategy {
    protected:
        int       open_method = EMPTY;    // Open method.
        double    open_level  = 0.0;     // Open level.

    public:
        // Update indicator values.
        bool Update(int tf = EMPTY) {
            for (i = 0; i < FINAL_INDICATOR_INDEX_ENTRY; i++)
                data[period][i] = iAC(_Symbol, tf, i);
            break;
        }
        bool Trade(int cmd, int tf = EMPTY, int open_method = 0, open_level = 0.0) {
            bool result = FALSE;
            if (open_method == EMPTY) open_method = this->open_method; // @fixme: This means to get the value from the class.
            if (open_level  == EMPTY) open_level  = AC::open_level; // @fixme? Get value from the current class instance.

            int period = Convert::TimeframeToPeriod(tf); // Convert.mqh

            switch (cmd) {
                /*
                   @todo: Implement below logic conditions into below bit-wise cases.
                   Break && || into separate bitwise lines, so the conditions can be combined based on the given open_method.

                //1. Acceleration/Deceleration <97> AC
                if ((iAC(NULL,piac,0)>=0&&iAC(NULL,piac,0)>iAC(NULL,piac,1)&&iAC(NULL,piac,1)>iAC(NULL,piac,2))||(iAC(NULL,piac,0)<=0
                && iAC(NULL,piac,0)>iAC(NULL,piac,1)&&iAC(NULL,piac,1)>iAC(NULL,piac,2)&&iAC(NULL,piac,2)>iAC(NULL,piac,3)))

                if ((iAC(NULL,piac,0)<=0&&iAC(NULL,piac,0)<iAC(NULL,piac,1)&&iAC(NULL,piac,1)<iAC(NULL,piac,2))||(iAC(NULL,piac,0)>=0
                && iAC(NULL,piac,0)<iAC(NULL,piac,1)&&iAC(NULL,piac,1)<iAC(NULL,piac,2)&&iAC(NULL,piac,2)<iAC(NULL,piac,3)))
                 */
                case OP_BUY:
                    bool result = @todo; // Buy: if the indicator is above zero and 2 consecutive columns are green or if the indicator is below zero and 3 consecutive columns are green
                    if ((open_method &   1) != 0) result = result && Open[CURR] > Close[CURR];
                    if ((open_method &   2) != 0) result = result && Trade(Convert::CmdOpp); // Check if position on sell.
                    if ((open_method &   4) != 0) result = result && Trade(MathMin(period + 1, M30)); // Check if strategy is signaled on higher period.
                    if ((open_method &   8) != 0) result = result && Trade(cmd, M30); // Check if there is signal on M30.
                    if ((open_method &  16) != 0) result = result && ...
                    if ((open_method &  32) != 0) result = result && ...
                    if ((open_method &  64) != 0) result = result && ...
                    // ...
                    break;
                case OP_SELL:
                    bool result = @todo; // Sell: if the indicator is below zero and 2 consecutive columns are red or if the indicator is above zero and 3 consecutive columns are red
                    if ((open_method &   1) != 0) result = result && Open[CURR] < Close[CURR];
                    if ((open_method &   2) != 0) result = result && Trade(Convert::CmdOpp);
                    if ((open_method &   4) != 0) result = result && Trade(cmd, MathMin(period + 1, M30));
                    if ((open_method &   8) != 0) result = result && Trade(cmd, M30);
                    if ((open_method &  16) != 0) result = result && ...
                    if ((open_method &  32) != 0) result = result && ...
                    if ((open_method &  64) != 0) result = result && ...
                    // ...
                    break;
            }
            return result;
        }
};
