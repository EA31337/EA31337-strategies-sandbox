//+------------------------------------------------------------------+
//| Implementation of AC Strategy.
//| Docs: https://docs.mql4.com/indicators/iac, https://www.mql5.com/en/docs/indicators/iac
//+------------------------------------------------------------------+
class AC: public Strategy {
    protected:
        int       open_method = EMPTY    // Open method.

    public:
            // Update indicator values.
            bool Update(int tf = EMPTY) {
                for (i = 0; i < FINAL_INDICATOR_INDEX_ENTRY; i++)
                    data[period][i] = iAC(_Symbol, timeframe, i);
                break;
            }
            bool Trade(int cmd, int tf = EMPTY, int open_method = EMPTY) {
                bool result = FALSE;
                if (open_method == EMPTY) open_method = this->open_method; // @fixme: This means to get the value from the class.
                int period = Convert::TimeframeToPeriod(tf); // Convert.mqh

                switch (cmd) {
                    /*
                       @todo: Implement below logic conditions into below bit-wise cases.

                    //1. Acceleration/Deceleration <97> AC
                    //Buy: if the indicator is above zero and 2 consecutive columns are green or if the indicator is below zero and 3 consecutive columns are green
                    //Sell: if the indicator is below zero and 2 consecutive columns are red or if the indicator is above zero and 3 consecutive columns are red
                    if ((iAC(NULL,piac,0)>=0&&iAC(NULL,piac,0)>iAC(NULL,piac,1)&&iAC(NULL,piac,1)>iAC(NULL,piac,2))||(iAC(NULL,piac,0)<=0
                    && iAC(NULL,piac,0)>iAC(NULL,piac,1)&&iAC(NULL,piac,1)>iAC(NULL,piac,2)&&iAC(NULL,piac,2)>iAC(NULL,piac,3)))
                    if ((iAC(NULL,piac,0)<=0&&iAC(NULL,piac,0)<iAC(NULL,piac,1)&&iAC(NULL,piac,1)<iAC(NULL,piac,2))||(iAC(NULL,piac,0)>=0
                    && iAC(NULL,piac,0)<iAC(NULL,piac,1)&&iAC(NULL,piac,1)<iAC(NULL,piac,2)&&iAC(NULL,piac,2)<iAC(NULL,piac,3)))
                     */
                    case OP_BUY:
                        /*
                           bool result = False;
                           if ((open_method &   1) != 0) result = result && Open[CURR] > Close[CURR];
                           if ((open_method &   2) != 0) result = result && !Trade(Convert::CmdOpp);
                           if ((open_method &   4) != 0) result = result && Trade(MathMin(period + 1, M30)); // Check if strategy is signaled on higher period.
                           if ((open_method &   8) != 0) result = result && Trade(cmd, M30); // Check if there is signal on M30.
                           if ((open_method &  16) != 0) result = result && ...
                           if ((open_method &  32) != 0) result = result && ...
                           ...
                         */
                        break;
                    case OP_SELL:
                        /*
                           bool result = False;
                           if ((open_method &   1) != 0) result = result && Open[CURR] < Close[CURR];
                           if ((open_method &   2) != 0) result = result && !Trade(Convert::CmdOpp);
                           if ((open_method &   4) != 0) result = result && Trade(cmd, MathMin(period + 1, M30));
                           if ((open_method &   8) != 0) result = result && Trade(cmd, M30);
                           if ((open_method &  16) != 0) result = result && ...
                           if ((open_method &  32) != 0) result = result && ...
                           ...
                         */
                        break;
                }
                return result;
            }
};
