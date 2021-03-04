table 50007 "WEH_G/L Budget Enc. PR/PO"
{
    DataClassification = CustomerContent;
    Caption = 'G/L Budget Encumbrance PR/PO';

    fields
    {
        field(1; "Entry No."; Integer)
        {

        }
        field(2; "G/L Budget Entry No."; Integer)
        {

        }
        field(3; "Entry Type"; Enum "WEH_Budget Enc. Entry Type")
        {
            //OptionMembers = " ","Check Budget","Un-Check Budget","Commit PO","Un-Commit PO","Cancel PR","Final PO","Cancel PO","Adjust PO","Inv. Deduct PO";
        }
        field(4; "Budget Name"; Code[10])
        {

        }
        field(5; "Posting Date"; Date)
        {

        }
        field(6; "PR IN Amount"; Decimal)
        {

        }
        field(7; "PR OUT Amount"; Decimal)
        {

        }
        field(8; "PR Amount"; Decimal)
        {

        }
        field(9; "PO IN Amount"; Decimal)
        {

        }
        field(10; "PO OUT Amount"; Decimal)
        {

        }
        field(11; "PO Amount"; Decimal)
        {

        }
        field(12; "PR IN Quantity"; Decimal)
        {

        }
        field(13; "PR OUT Quantity"; Decimal)
        {

        }
        field(14; "PR Quantity"; Decimal)
        {

        }
        field(15; "PO IN Quantity"; Decimal)
        {

        }
        field(16; "PO OUT Quantity"; Decimal)
        {

        }
        field(17; "PO Quantity"; Decimal)
        {

        }
        field(18; "User ID"; Code[50])
        {

        }
        field(19; "Actual Amount Exc. VAT"; Decimal)
        {

        }
        field(20; "Posted Invoice No."; Code[20])
        {

        }
        field(21; "Posted Invoice Line No."; Integer)
        {

        }
        field(22; "Ref. Document No."; Code[20])
        {

        }
        field(23; "Ref. Document Line No."; Integer)
        {

        }
        field(24; "Ref. Item Ledger Entry"; Integer)
        {

        }
        field(25; "Ref. Entry No."; Integer)
        {

        }
        field(26; "Document Posting Date"; Date)
        {

        }
        field(27; "Document Date"; Date)
        {

        }
        field(28; Type; Enum "Purchase Line Type")
        {

        }
        field(29; "No."; Code[20])
        {
            TableRelation = IF (Type = CONST(" ")) "Standard Text"
            ELSE
            IF (Type = CONST("G/L Account")) "G/L Account"
            ELSE
            IF (Type = CONST("Fixed Asset")) "Fixed Asset"
            ELSE
            IF (Type = CONST("Charge (Item)")) "Item Charge"
            ELSE
            IF (Type = CONST(Item)) Item
            else
            if (Type = const(Resource)) Resource;

            ValidateTableRelation = false;
        }
        field(30; "Currency Factor"; Decimal)
        {
            DecimalPlaces = 0 : 15;
            Editable = false;
            MinValue = 0;
        }
        field(31; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1), Blocked = CONST(false));
        }
        field(32; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2), Blocked = CONST(false));
        }
        field(33; "Budget Type"; Enum "WEH_Budget Type")
        {

        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }

    var
        myInt: Integer;

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;
}
