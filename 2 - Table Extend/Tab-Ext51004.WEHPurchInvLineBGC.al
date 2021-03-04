tableextension 51004 "WEH_Purch. Inv. Line BGC" extends "Purch. Inv. Line"
{
    fields
    {
        field(51000; "WEH_Budget Type"; Enum "WEH_Budget Type")
        {
            Caption = 'Budget Type';
            Editable = false;
        }
        field(51001; "WEH_Budget Name"; Code[10])
        {
            Caption = 'Budget Name';
            TableRelation = "G/L Budget Name" where("WEH_G/L Budget Name Type" = const(Budget));
            Editable = false;
        }
    }
}
