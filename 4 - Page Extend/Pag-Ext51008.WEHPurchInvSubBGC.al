pageextension 51008 "WEH_Purch. Inv. Sub BGC" extends "Purch. Invoice Subform"
{
    layout
    {
        addafter("AVFN_G/L_Temp")
        {
            field("WEH_Budget Type"; "WEH_Budget Type")
            {
                ApplicationArea = All;
            }
        }
        moveafter(ShortcutDimCode4; "AVF_Receipt No.")
        moveafter("AVF_Receipt No."; "AVF_Receipt Line No.")
        addafter("AVF_Receipt Line No.")
        {
            field("WEH_Budget Name"; "WEH_Budget Name")
            {
                ApplicationArea = All;
            }
        }
    }
}
