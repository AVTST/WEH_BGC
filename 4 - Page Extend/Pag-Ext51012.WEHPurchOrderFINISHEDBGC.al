pageextension 51012 "WEH_Purch. Order-FINISHED BGC" extends "AVTD_Purch. Order-FINISHED"
{
    layout
    {
        addafter(FINISHED)
        {
            field("WEH_Pending Approvals"; "Pending Approvals")
            {
                ApplicationArea = All;
                DrillDown = true;

                trigger OnDrillDown()
                var
                    ApprovalEntry: Record "Approval Entry";
                begin
                    Clear(ApprovalEntry);
                    ApprovalEntry.SetRange("Table ID", Database::"Purchase Header");
                    ApprovalEntry.SetRange("Document Type", ApprovalEntry."Document Type"::Order);
                    ApprovalEntry.SetRange("Document No.", Rec."No.");
                    if ApprovalEntry.FindSet() then
                        Page.RunModal(Page::"WEH_Approval Details", ApprovalEntry)
                end;
            }
            field("WEH_PendingApprovalID"; PendingApprovalID)
            {
                Caption = 'Pending Approval ID';
                ApplicationArea = all;
                Editable = false;
            }
            field("WEH_Approval Comment"; "WEH_Approval Comment")
            {
                ApplicationArea = All;
            }
        }
    }
    actions
    {
        modify("U&ndo FINISHED PO")
        {
            Visible = false;
        }
        addfirst("F&unctions")
        {
            action("WEH_Undo FINISHED PO")
            {
                ApplicationArea = All;
                Caption = 'U&ndo FINISHED PO';
                Image = ReverseLines;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction();
                var
                    BudgetMgt: Codeunit "WEH_Budget Control Management";
                begin
                    BudgetMgt.UndoFinishPO(Rec);
                    CurrPage.Update();
                end;
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        GetPendingApprovalID();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        GetPendingApprovalID();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Clear(PendingApprovalID);
    end;

    trigger OnOpenPage()
    begin
        Clear(PendingApprovalID);
    end;

    var
        PendingApprovalID: code[50];

    local procedure GetPendingApprovalID()
    var
        ApprovalEntry: Record "Approval Entry";
    begin
        Clear(PendingApprovalID);
        Clear(ApprovalEntry);
        ApprovalEntry.SetRange("Table ID", Database::"Purchase Header");
        ApprovalEntry.SetRange("Document Type", ApprovalEntry."Document Type"::Order);
        ApprovalEntry.SetRange("Document No.", Rec."No.");
        //ApprovalEntry.SetRange("WEH_Document Line No.", 0);
        ApprovalEntry.SetRange(Status, ApprovalEntry.Status::Open);
        if ApprovalEntry.FindLast() then
            PendingApprovalID := ApprovalEntry."Approver ID";
    end;
}
