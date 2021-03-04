page 50105 "WEH_Available Budget Factbox 2"
{
    Caption = 'Available Budget';
    PageType = CardPart;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "WEH_Add/T. Budget COR Line";

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                field("Out_Budget_Amount"; Out_Budget_Amount)
                {
                    ApplicationArea = All;
                    Caption = 'Budget';
                    BlankZero = true;
                }
                field("Out_PR_Amount"; Out_PR_Amount)
                {
                    ApplicationArea = All;
                    Caption = 'PR';
                    BlankZero = true;
                }
                field("Out_PO_Amount"; Out_PO_Amount)
                {
                    ApplicationArea = All;
                    Caption = 'PO';
                    BlankZero = true;
                }
                field("Out_Actual_Amount"; Out_Actual_Amount)
                {
                    ApplicationArea = All;
                    Caption = 'Actual';
                    BlankZero = true;
                }
                field("Out_Available_Amount"; Out_Available_Amount)
                {
                    ApplicationArea = All;
                    Caption = 'Available';
                    BlankZero = true;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        GetBudgetInfo();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        GetBudgetInfo();
    end;

    var
        Out_Budget_Amount: Decimal;
        Out_PR_Amount: Decimal;
        Out_PO_Amount: Decimal;
        Out_Actual_Amount: Decimal;
        Out_Available_Amount: Decimal;

    local procedure GetBudgetInfo()
    var
        GLSetup: Record "General Ledger Setup";
        GLBudgetName: Record "G/L Budget Name";
        GLBudgetEntry: Record "G/L Budget Entry";
        GLEntry: Record "G/L Entry";
        AddBudgetHead: Record "WEH_Add/T. Budget COR Header";
    begin
        CLEAR(Out_Budget_Amount);
        CLEAR(Out_PR_Amount);
        CLEAR(Out_PO_Amount);
        CLEAR(Out_Actual_Amount);
        CLEAR(Out_Available_Amount);

        AddBudgetHead.Get("Document No.");

        if AddBudgetHead."Post to Budget" <> '' then begin
            GLSetup.Get();

            CLEAR(GLBudgetName);
            GLBudgetName.GET(AddBudgetHead."Post to Budget");
            GLBudgetName.TESTFIELD("WEH_Encumbrance Name");

            CLEAR(Out_Budget_Amount);
            CLEAR(Out_PR_Amount);
            CLEAR(Out_PO_Amount);
            CLEAR(Out_Actual_Amount);
            CLEAR(Out_Available_Amount);

            IF "Budget Type" = "Budget Type"::O THEN BEGIN
                CLEAR(GLBudgetEntry);
                GLBudgetEntry.SETCURRENTKEY("Budget Name", "G/L Account No.", "Global Dimension 1 Code");
                GLBudgetEntry.SETRANGE("Budget Name", AddBudgetHead."Post to Budget");
                GLBudgetEntry.SETRANGE("G/L Account No.", "G/L Account No.");
                GLBudgetEntry.SETRANGE("Global Dimension 1 Code", "Global Dimension 1 Code");
                GLBudgetEntry.SETRANGE("WEH_Budget Type", "Budget Type");
                IF GLBudgetEntry.FINDSET() THEN BEGIN
                    REPEAT
                        Out_Budget_Amount := Out_Budget_Amount + GLBudgetEntry.Amount;
                    UNTIL GLBudgetEntry.NEXT() = 0;
                END;

                CLEAR(GLBudgetEntry);
                GLBudgetEntry.SETCURRENTKEY("Budget Name", "G/L Account No.", "Global Dimension 1 Code");
                GLBudgetEntry.SETRANGE("Budget Name", GLBudgetName."WEH_Encumbrance Name");
                GLBudgetEntry.SETRANGE("G/L Account No.", "G/L Account No.");
                GLBudgetEntry.SETRANGE("Global Dimension 1 Code", "Global Dimension 1 Code");
                GLBudgetEntry.SETRANGE("WEH_Budget Type", "Budget Type");
                IF GLBudgetEntry.FindSet() THEN BEGIN
                    REPEAT
                        GLBudgetEntry.CALCFIELDS("WEH_Encumbrance PR Amount", "WEH_Encumbrance PO Amount");
                        Out_PR_Amount += GLBudgetEntry."WEH_Encumbrance PR Amount";
                        Out_PO_Amount += GLBudgetEntry."WEH_Encumbrance PO Amount";
                    UNTIL GLBudgetEntry.NEXT() = 0;
                END;

                CLEAR(GLEntry);
                GLEntry.SETCURRENTKEY("G/L Account No.", "Global Dimension 1 Code");
                GLEntry.SETRANGE("G/L Account No.", "G/L Account No.");
                GLEntry.SETRANGE("Global Dimension 1 Code", "Global Dimension 1 Code");
                GLEntry.SETRANGE("Posting Date", GLBudgetName."WEH_Start Date", GLBudgetName."WEH_End Date");
                IF GLEntry.FINDSET() THEN BEGIN
                    REPEAT
                        Out_Actual_Amount += GLEntry.Amount;
                    UNTIL GLEntry.NEXT() = 0;
                END;

                Out_Available_Amount := Out_Budget_Amount - Out_PR_Amount - Out_PO_Amount - Out_Actual_Amount;
            END ELSE
                IF "Budget Type" = "Budget Type"::C THEN BEGIN
                    CLEAR(GLBudgetEntry);
                    GLBudgetEntry.SETCURRENTKEY("Budget Name", "Global Dimension 1 Code", "Global Dimension 2 Code");
                    GLBudgetEntry.SETRANGE("Budget Name", AddBudgetHead."Post to Budget");
                    GLBudgetEntry.SETRANGE("Global Dimension 1 Code", "Global Dimension 1 Code");
                    GLBudgetEntry.SETRANGE("Global Dimension 2 Code", "Global Dimension 2 Code");
                    GLBudgetEntry.SETRANGE("WEH_Budget Type", "Budget Type");
                    IF GLBudgetEntry.FindSet() THEN BEGIN
                        REPEAT
                            Out_Budget_Amount += GLBudgetEntry.Amount;
                        UNTIL GLBudgetEntry.NEXT() = 0;
                    END;

                    CLEAR(GLBudgetEntry);
                    GLBudgetEntry.SETCURRENTKEY("Budget Name", "Global Dimension 1 Code", "Global Dimension 2 Code");
                    GLBudgetEntry.SETRANGE("Budget Name", GLBudgetName."WEH_Encumbrance Name");
                    GLBudgetEntry.SETRANGE("Global Dimension 1 Code", "Global Dimension 1 Code");
                    GLBudgetEntry.SETRANGE("Global Dimension 2 Code", "Global Dimension 2 Code");
                    GLBudgetEntry.SETRANGE("WEH_Budget Type", "Budget Type");
                    IF GLBudgetEntry.FINDSET() THEN BEGIN
                        REPEAT
                            GLBudgetEntry.CALCFIELDS("WEH_Encumbrance PR Amount", "WEH_Encumbrance PO Amount");
                            Out_PR_Amount += GLBudgetEntry."WEH_Encumbrance PR Amount";
                            Out_PO_Amount += GLBudgetEntry."WEH_Encumbrance PO Amount";
                        UNTIL GLBudgetEntry.NEXT() = 0;
                    END;

                    CLEAR(GLEntry);
                    GLEntry.SETCURRENTKEY("Global Dimension 1 Code", "Global Dimension 2 Code");
                    GLEntry.SETRANGE("Global Dimension 1 Code", "Global Dimension 1 Code");
                    GLEntry.SETRANGE("Global Dimension 2 Code", "Global Dimension 2 Code");
                    GLEntry.SETRANGE("Posting Date", GLBudgetName."WEH_Start Date", GLBudgetName."WEH_End Date");
                    GLEntry.SETFILTER("G/L Account No.", GLSetup."WEH_VAT Account");
                    IF GLEntry.FINDSET() THEN BEGIN
                        REPEAT
                            Out_Actual_Amount := Out_Actual_Amount + GLEntry.Amount;
                        UNTIL GLEntry.NEXT() = 0;
                    END;

                    Out_Available_Amount := Out_Budget_Amount - Out_PR_Amount - Out_PO_Amount - Out_Actual_Amount;
                END;
        end;
    end;
}
