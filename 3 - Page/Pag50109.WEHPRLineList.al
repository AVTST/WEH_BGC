page 50109 "WEH_PR Line List"
{
    Caption = 'PR Line List';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Worksheet;
    SourceTable = "Purchase Line";
    SourceTableView = sorting("Document Type", "Document No.", "Line No.");

    layout
    {
        area(content)
        {
            repeater(Control1000000000)
            {
                field("Used Line"; "AVTD_Used Line")
                {
                    ApplicationArea = All;
                }
                field("Document No."; "Document No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Style = Standard;
                    StyleExpr = true;
                }
                field("Line No."; "Line No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Unit of Measure"; "Unit of Measure")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Buy-from Vendor No."; "Buy-from Vendor No.")
                {
                    ApplicationArea = All;
                    Width = 11;
                }
                field(VendName; VendName)
                {
                    Caption = 'Name';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("AVTD_Purchase Status"; "AVTD_Purchase Status")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
            }
        }
    }

    trigger OnInit()
    var
        PurchHeader: Record "Purchase Header";
    begin
        Reset();
        SetRange("Document Type", "Document Type"::Quote);
        SetRange("AVTD_Ref. Doc. No.", '');
        //SetFilter("No.", '<>%1', '');
        if FindSet() then
            repeat
                Clear(PurchHeader);
                if PurchHeader.Get("Document Type", "Document No.") then begin
                    if (PurchHeader.Status = PurchHeader.Status::Released) and (not PurchHeader."WEH_Finish PR") then
                        Mark(true);
                end;
            until Next() = 0;
    end;

    trigger OnOpenPage()
    begin
        Rec.MarkedOnly(true);
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean;
    begin
        if CloseAction in [Action::OK, Action::LookupOK] then
            OKOnPush();
    end;

    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        PurchaseLine1: Record "Purchase Line";
        NewPurchLine: Record "Purchase Line";
        VendName: Text[250];

    trigger OnAfterGetRecord()
    var
        Vend: Record Vendor;
    begin
        Clear(VendName);
        if Vend.Get(Rec."Buy-from Vendor No.") then
            VendName := StrSubstNo(Vend.Name, ' ', Vend."Name 2");
    end;

    trigger OnAfterGetCurrRecord()
    var
        Vend: Record Vendor;
    begin
        Clear(VendName);
        if Vend.Get(Rec."Buy-from Vendor No.") then
            VendName := StrSubstNo(Vend.Name, ' ', Vend."Name 2");
    end;

    procedure SetHeader(PurchHead: Record "Purchase Header");
    begin
        PurchaseHeader := PurchHead;
    end;

    local procedure OKOnPush();
    var
        PurchHead: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
    begin
        PurchaseLine.SetFilter("AVTD_Ref. Doc. No.", '%1', '');
        PurchaseLine.SetRange("AVTD_Used Line", true);
        if PurchaseLine.Find('-') then
            repeat
                NewPurchLine.Init();
                NewPurchLine."Document Type" := NewPurchLine."Document Type"::Order;
                NewPurchLine."Document No." := PurchaseHeader."No.";

                PurchaseLine1.SetRange("Document Type", PurchaseLine1."Document Type"::Order);
                PurchaseLine1.SetFilter("Document No.", PurchaseHeader."No.");
                if PurchaseLine1.FindLast() then
                    NewPurchLine."Line No." := PurchaseLine1."Line No." + 1000
                else
                    NewPurchLine."Line No." := 10000;

                case PurchaseLine.Type of
                    PurchaseLine.Type::"G/L Account":
                        NewPurchLine.Validate(Type, PurchaseLine.Type::"G/L Account");
                    PurchaseLine.Type::"Item":
                        NewPurchLine.Validate(Type, PurchaseLine.Type::Item);
                    PurchaseLine.Type::"Fixed Asset":
                        NewPurchLine.Validate(Type, PurchaseLine.Type::"Fixed Asset");
                    PurchaseLine.Type::"Charge (Item)":
                        NewPurchLine.Validate(Type, PurchaseLine.Type::"Charge (Item)");
                end;

                if PurchaseLine."No." <> '' then
                    NewPurchLine.Validate("No.", PurchaseLine."No.");

                NewPurchLine.Description := PurchaseLine.Description;
                NewPurchLine."Description 2" := PurchaseLine."Description 2";
                NewPurchLine.Validate("Buy-from Vendor No.", PurchaseHeader."Buy-from Vendor No.");

                if PurchaseLine."No." <> '' then begin
                    NewPurchLine.Validate(Quantity, PurchaseLine.Quantity);
                    NewPurchLine.Validate("Location Code", PurchaseLine."Location Code");
                    NewPurchLine.Validate("Unit of Measure Code", PurchaseLine."Unit of Measure Code");
                    NewPurchLine.Validate("Direct Unit Cost", PurchaseLine."Direct Unit Cost");
                    NewPurchLine.Validate("Line Discount %", PurchaseLine."Line Discount %");
                    NewPurchLine."Inv. Discount Amount" := PurchaseLine."Inv. Discount Amount";
                end;

                NewPurchLine."Job No." := PurchaseLine."Job No.";
                NewPurchLine."Job Task No." := PurchaseLine."Job Task No.";
                NewPurchLine.Insert();

                if PurchaseLine."No." <> '' then begin
                    NewPurchLine.Validate("Shortcut Dimension 2 Code", PurchaseLine."Shortcut Dimension 2 Code");
                    NewPurchLine.Validate("Shortcut Dimension 1 Code", PurchaseLine."Shortcut Dimension 1 Code");
                    NewPurchLine.Validate("Gen. Bus. Posting Group", PurchaseHeader."Gen. Bus. Posting Group");
                    NewPurchLine.Validate("AVF_WHT Business Posting Group", PurchaseHeader."AVF_WHT Business Posting Group");
                    NewPurchLine.Validate("Gen. Prod. Posting Group", PurchaseLine."Gen. Prod. Posting Group");
                    NewPurchLine.Validate("VAT Prod. Posting Group", PurchaseLine."VAT Prod. Posting Group");
                    NewPurchLine.Validate("AVF_WHT Product Posting Group", PurchaseLine."AVF_WHT Product Posting Group");
                end;

                NewPurchLine."AVTD_Ref. Doc. No." := PurchaseLine."Document No.";
                NewPurchLine."AVTD_Ref. Line No." := PurchaseLine."Line No.";

                NewPurchLine.Description := PurchaseLine.Description;
                NewPurchLine."Description 2" := PurchaseLine."Description 2";
                NewPurchLine."WEH_Budget Name" := PurchaseLine."WEH_Budget Name";
                NewPurchLine."WEH_Budget Type" := PurchaseLine."WEH_Budget Type";
                NewPurchLine."WEH_Check Budget" := PurchaseLine."WEH_Check Budget"::" ";
                NewPurchLine.Modify();

                PurchaseLine."AVTD_Ref. Doc. No." := PurchaseHeader."No.";
                PurchaseLine."AVTD_Ref. Line No." := NewPurchLine."Line No.";
                PurchaseLine."AVTD_Used Line" := false;
                PurchaseLine."WEH_Finish PR" := true;
                PurchaseLine.Modify();

                Clear(PurchLine);
                PurchLine.SetRange("Document Type", PurchaseLine."Document Type");
                PurchLine.SetRange("Document No.", PurchaseLine."Document No.");
                PurchLine.SetRange("WEH_Finish PR", false);
                PurchLine.SetFilter("No.", '<>%1', '');
                PurchLine.SetFilter(Quantity, '<>%1', 0);
                if PurchLine.IsEmpty then begin
                    Clear(PurchHead);
                    PurchHead.get(PurchaseLine."Document Type", PurchaseLine."Document No.");
                    PurchHead."WEH_Finish PR" := true;
                    PurchHead.Modify();
                end;
            until PurchaseLine.Next() = 0;
    end;
}
