pageextension 51007 "WEH_Posted Purch. Inv. Sub BGC" extends "Posted Purch. Invoice Subform"
{
    layout
    {
        addbefore(Type)
        {
            field("WEH_Line No."; "Line No.")
            {
                ApplicationArea = ALL;
                Editable = false;
            }
            field("WEH_Budget Type"; "WEH_Budget Type")
            {
                ApplicationArea = ALL;
                Editable = false;
            }
        }
        addlast(Control1)
        {
            field("WEH_Budget Name"; "WEH_Budget Name")
            {
                ApplicationArea = ALL;
                Editable = false;
            }
        }
    }
}
