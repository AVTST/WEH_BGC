table 50009 "WEH_Add/T. Budget COR Line"
{
    DataClassification = CustomerContent;
    Caption = 'Add/Transfer Budget COR Line';

    fields
    {
        field(1; "Document No."; Code[20])
        {

        }
        field(2; "Line No."; Integer)
        {

        }
        field(3; "Budget Type"; Enum "WEH_Budget Type")
        {
            //OptionMembers = " ",O,C,P;
        }
        field(4; "G/L Account No."; Code[20])
        {
            TableRelation = "G/L Account"."No." where("Account Type" = const(Posting));

            trigger OnValidate()
            var
                GLAcc: Record "G/L Account";
            begin
                if "G/L Account No." <> '' then begin
                    GLAcc.Get("G/L Account No.");
                    Description := GLAcc.Name;
                end else
                    Description := '';
            end;
        }
        field(5; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1), Blocked = const(false));
        }
        field(6; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2), Blocked = CONST(false));
        }
        field(7; Description; Text[100])
        {

        }
        field(8; "Start Date"; Date)
        {

        }
        field(9; "End Date"; Date)
        {

        }
        field(10; "To G/L Account No."; Code[20])
        {
            TableRelation = "G/L Account"."No." where("Account Type" = const(Posting));

            trigger OnValidate()
            var
                GLAcc: Record "G/L Account";
            begin
                if "G/L Account No." <> '' then begin
                    GLAcc.Get("G/L Account No.");
                    "To Description" := GLAcc.Name;
                end else
                    "To Description" := '';
            end;
        }
        field(11; "To Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1));
        }
        field(12; "To Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2));
        }
        field(13; "To Description"; Text[100])
        {

        }
        field(14; "To Start Date"; Date)
        {

        }
        field(15; "To End Date"; Date)
        {

        }
        field(16; "To Quantity"; Decimal)
        {

        }
        field(17; "Long Text"; Text[150])
        {

        }
        field(18; "Total Amount (LCY)"; Decimal)
        {

        }
        field(19; "To Total Amount (LCY)"; Decimal)
        {

        }
        field(20; Remark; Text[100])
        {

        }
        field(21; "Remark 2"; Text[100])
        {

        }
        field(22; "Budget Dimension 1 Code"; Code[20])
        {
            TableRelation = Dimension;
        }
        field(23; "Budget Dimension 2 Code"; Code[20])
        {
            TableRelation = Dimension;
        }
        field(24; "To Budget Dimension 1 Code"; Code[20])
        {
            TableRelation = Dimension;
        }
        field(25; "To Budget Dimension 2 Code"; Code[20])
        {
            TableRelation = Dimension;
        }
    }

    keys
    {
        key(PK; "Document No.", "Line No.")
        {
            Clustered = true;
        }
    }

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
