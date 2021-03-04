pageextension 51005 "WEH_No. Series BGC" extends "No. Series"
{
    layout
    {
        addlast(Control1)
        {
            field("WEH_Budget Document Type"; "WEH_Budget Document Type")
            {
                ApplicationArea = all;
            }
        }
    }
}
