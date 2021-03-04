tableextension 51001 "WEH_G/L Budget Entry" extends "G/L Budget Entry"
{
    fields
    {
        field(51000; "WEH_G/L Budget Name Type"; Enum "WEH_G/L Budget Name Type")
        {
            Caption = 'G/L Budget Name Type';
            //OptionMembers = " ",Budget,Encumbrance;
        }
        field(51001; "WEH_Budget Type"; Enum "WEH_Budget Type")
        {
            Caption = 'Budget Type';
            //OptionMembers = " ",O,C,P;
        }
        field(51002; "WEH_Long Text"; Text[150])
        {
            Caption = 'Long Text';
        }
        field(51003; "WEH_Start Date"; Date)
        {
            Caption = 'Start Date';
        }
        field(51004; "WEH_End Date"; Date)
        {
            Caption = 'End Date';
        }
        field(51005; "WEH_Ref. Document Type"; Enum "WEH_Ref. Document Type")
        {
            Caption = 'Ref. Document Type';
            //OptionMembers = " ",Encumbrance,Invoice,"Credit Memo";
        }
        field(51006; "WEH_Ref. Document No."; Code[20])
        {
            Caption = 'Ref. Document No.';
        }
        field(51007; "WEH_Ref. Document Line No."; Integer)
        {
            Caption = 'Ref. Document Line No.';
        }
        field(51008; "WEH_Remark"; Text[100])
        {
            Caption = 'Remark';
        }
        field(51009; "WEH_Encumbrance PR Amount"; Decimal)
        {
            Caption = 'Encumbrance PR Amount';
            FieldClass = FlowField;
            CalcFormula = Sum("WEH_G/L Budget Enc. PR/PO"."PR Amount" WHERE("G/L Budget Entry No." = FIELD("Entry No."), "Posting Date" = FIELD("WEH_Date filter")));
        }
        field(51010; "WEH_Encumbrance PO Amount"; Decimal)
        {
            Caption = 'Encumbrance PO Amount';
            FieldClass = FlowField;
            CalcFormula = Sum("WEH_G/L Budget Enc. PR/PO"."PO Amount" WHERE("G/L Budget Entry No." = FIELD("Entry No."), "Posting Date" = FIELD("WEH_Date filter")));
        }
        field(51011; "WEH_Encumbrance PI Amount"; Decimal)
        {
            Caption = 'Encumbrance PI Amount';
        }
        field(51012; "WEH_Document Posting Date"; Date)
        {
            Caption = 'Document Posting Date';
        }
        field(51013; "WEH_Document Date"; Date)
        {
            Caption = 'Document Date';
        }
        field(51014; "WEH_Add/Transfer Document No."; code[20])
        {
            Caption = 'Add/Transfer Document No.';
        }
        field(51015; "WEH_Add/Transfer Document Type"; Enum "WEH_Add/Transfer Document Type")
        {
            Caption = 'Add/Transfer Document Type';
            //OptionMembers = " ",ADD,TRANSFER;
        }
        field(51016; "WEH_Date Filter"; Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
        }
    }
}
