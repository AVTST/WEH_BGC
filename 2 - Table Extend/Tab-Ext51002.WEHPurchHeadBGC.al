tableextension 51002 "WEH_Purch. Head BGC" extends "Purchase Header"
{
    fields
    {
        field(51000; "WEH_Budget Document Type"; Enum "WEH_Budget Document Type")
        {
            Caption = 'Budget Document Type';
            //OptionMembers = " ",Corporate,Job;
        }
        field(51001; "WEH_Check Budget"; Enum "WEH_Check Budget")
        {
            Caption = 'Check Budget';
            //OptionMembers = " ",PASS,"NOT PASS";
        }
        field(51002; "WEH_Commit PO"; Enum "WEH_Commit PO")
        {
            Caption = 'Commit PO';
            //OptionMembers = " ",COMMIT;
        }
        field(51003; "WEH_Finish PR"; Boolean)
        {
            Caption = 'Finish PR';
        }
        field(51004; "WEH_Created Date"; Date)
        {
            Caption = 'Created Date';
            Editable = false;
        }
        field(51005; "WEH_Receive Date"; Date)
        {
            Caption = 'Receive Date';

            trigger OnValidate()
            begin
                "Posting Date" := Rec."WEH_Receive Date";
            end;
        }
        field(51006; "WEH_Approval Comment"; Text[250])
        {
            Caption = 'Approval Comment';
        }
        field(51007; "WEH_Ref. PR No."; Text[50])
        {
            Caption = 'Ref. PR No.';
        }
        modify("Currency Code")
        {
            trigger OnBeforeValidate()
            var
                PurchLine: Record "Purchase Line";
            begin
                Clear(PurchLine);
                PurchLine.SetRange("Document Type", Rec."Document Type");
                PurchLine.SetRange("Document No.", Rec."No.");
                if not PurchLine.IsEmpty then
                    Error('Please delete lines before edit currency');
            end;
        }
        modify("Responsibility Center")
        {
            trigger OnBeforeValidate()
            var
                PurchLine: Record "Purchase Line";
            begin
                Clear(PurchLine);
                PurchLine.SetRange("Document Type", Rec."Document Type");
                PurchLine.SetRange("Document No.", Rec."No.");
                if not PurchLine.IsEmpty then
                    Error('Please delete lines before edit Responsibility Center');
            end;
        }
        modify("Expected Receipt Date")
        {
            trigger OnBeforeValidate()
            begin
                Rec.TestField("Order Date");
                if Rec."Order Date" > Rec."Expected Receipt Date" then
                    Error('Expected Receipt Date must not less than Order Date');
            end;
        }
    }

    trigger OnInsert()
    begin
        "WEH_Created Date" := WorkDate();
    end;

    trigger OnDelete()
    begin
        TestField("WEH_Check Budget", "WEH_Check Budget"::" ");
        TestField("WEH_Commit PO", "WEH_Commit PO"::" ");
    end;

    procedure BudgetAssistEdit(OldPurchHeader: Record "Purchase Header"): Boolean
    var
        PurchSetup: Record "Purchases & Payables Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        NoSeriesCode: code[10];
    begin
        if Rec."WEH_Budget Document Type" = Rec."WEH_Budget Document Type"::Corporate then begin
            PurchSetup.Get();
            if Rec."Document Type" = Rec."Document Type"::Quote then begin
                PurchSetup.TestField("WEH_PR Corp. Nos.");
                NoSeriesCode := PurchSetup."WEH_PR Corp. Nos.";
            end else
                if Rec."Document Type" = Rec."Document Type"::Order then begin
                    PurchSetup.TestField("WEH_PO Corp. Nos.");
                    NoSeriesCode := PurchSetup."WEH_PO Corp. Nos.";
                end else
                    Error('Document Type error');

            if NoSeriesMgt.SelectSeries(NoSeriesCode, OldPurchHeader."No. Series", "No. Series") then begin
                TestNoSeries();
                NoSeriesMgt.SetSeries("No.");
                exit(true);
            end;
        end else
            Rec.TestField("WEH_Budget Document Type", Rec."WEH_Budget Document Type"::Corporate);
    end;

    procedure CheckFields()
    var
        PurchLine: Record "Purchase Line";
    begin
        CLEAR(PurchLine);
        PurchLine.SETCURRENTKEY("Document Type", "Document No.", "Line No.");
        PurchLine.SETRANGE("Document Type", "Document Type");
        PurchLine.SETRANGE("Document No.", "No.");
        PurchLine.SETFILTER("No.", '<>%1', '');
        IF PurchLine.FindSet() THEN BEGIN
            REPEAT
                PurchLine.TESTFIELD("Requested Receipt Date");
                PurchLine.TESTFIELD("Gen. Prod. Posting Group");
                PurchLine.TESTFIELD("VAT Prod. Posting Group");
            //PurchLine.TESTFIELD("WHT Product Posting Group");
            UNTIL PurchLine.NEXT() = 0;
        END;
    end;

    procedure CheckReceived(ErrActionTxt: Text)
    var
        PurchLine: Record "Purchase Line";
    begin
        Clear(PurchLine);
        PurchLine.SetRange("Document Type", Rec."Document Type");
        PurchLine.SetRange("Document No.", Rec."No.");
        PurchLine.SetFilter("No.", '<>%1', '');
        PurchLine.SetFilter("Quantity Received", '<>%1', 0);
        if not PurchLine.IsEmpty then
            ERROR('PO No. %1 is already post receive and cannot %2', Rec."No.", ErrActionTxt);
    end;

    procedure CheckLineRefDocReopen()
    var
        PurchLine: Record "Purchase Line";
    begin
        Clear(PurchLine);
        PurchLine.SetRange("Document Type", Rec."Document Type");
        PurchLine.SetRange("Document No.", Rec."No.");
        PurchLine.SetFilter("No.", '<>%1', '');
        PurchLine.SetFilter("AVTD_Ref. Doc. No.", '<>%1', '');
        if not PurchLine.IsEmpty then
            ERROR('PR No. %1 is already created to PO', Rec."No.");
    end;

    [TryFunction]
    procedure "TestRunReport"(var ReportID: Integer; var TableRec: Record "Purchase Header")
    begin
        Report.RunModal(ReportID, true, false, TableRec)
    end;
}
