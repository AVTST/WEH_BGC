pageextension 51006 "WEH_G/L Temp BGC" extends "AVFN_G/L (Order) Template"
{
    layout
    {
        addlast(Control1000000000)
        {
            field("WEH_Budget Type"; "WEH_Budget Type")
            {
                ApplicationArea = all;
            }
        }
    }
}
