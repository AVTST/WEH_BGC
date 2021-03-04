tableextension 51012 "WEH_G/L Account BGC" extends "G/L Account"
{
    fields
    {
        field(51000; "WEH_Non-confidential"; Boolean)
        {
            Caption = 'Non-confidential';
            ObsoleteState = Removed;
        }
    }
}
