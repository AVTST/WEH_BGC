page 50085 "WEH_Transfer Budget Order CORP"
{
    Caption = 'Transfer Budget Order - Corporate';
    PageType = Document;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "WEH_Add/T. Budget COR Header";
    SourceTableView = SORTING("No.") WHERE("Document Type" = CONST("Transfer Budget"), Status = CONST(" "));
    RefreshOnActivate = true;
    DeleteAllowed = false;
    PromotedActionCategories = 'New,Process,Reports,Approve,Post,Send Request';

    layout
    {
        area(Content)
        {
            group(General)
            {
                Editable = PageEditabled;
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    trigger OnAssistEdit()
                    begin
                        if Rec."No." <> '' then
                            Error('');

                        if AssistEdit(xRec) then
                            CurrPage.Update;
                    end;
                }
                field("Document Date"; "Document Date")
                {
                    ApplicationArea = All;
                }
                field("Posting Date"; "Posting Date")
                {
                    ApplicationArea = All;
                }
                field("Requested by"; "Requested by")
                {
                    ApplicationArea = All;
                }
                field("Requested Name"; "Requested Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Approve Status"; "Approve Status")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Pending Approvals"; "Pending Approvals")
                {
                    ApplicationArea = All;
                    DrillDown = true;

                    trigger OnDrillDown()
                    var
                        ApprovalEntry: Record "Approval Entry";
                    begin
                        Clear(ApprovalEntry);
                        ApprovalEntry.SetRange("Table ID", 50008);
                        ApprovalEntry.SetRange("Document Type", ApprovalEntry."Document Type"::"Trans. Budget Order - Corp.");
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
                field("Document Type"; "Document Type")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Transfer Amount"; "Transfer Amount")
                {
                    ApplicationArea = ALL;
                }
                field("Created by"; "Created by")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Posted by"; "Posted by")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Post to Budget"; "Post to Budget")
                {
                    ApplicationArea = All;
                    Editable = true;
                }
                field(Remark; Remark)
                {
                    ApplicationArea = All;
                }
                field("Remark 2"; "Remark 2")
                {
                    ApplicationArea = All;
                }
            }
            part(BudgetCorpLines; "WEH_Trans. Budget Subform CORP")
            {
                SubPageLink = "Document No." = FIELD("No.");
                Editable = PageEditabled;
            }
            group(Remarks)
            {
                Visible = false;
                Editable = PageEditabled;
                field("Remark 3"; "Remark 3")
                {
                    ApplicationArea = All;
                }
                field("Remark 4"; "Remark 4")
                {
                    ApplicationArea = All;
                }
                field("Remark 5"; "Remark 5")
                {
                    ApplicationArea = All;
                }
                field("Remark 6"; "Remark 6")
                {
                    ApplicationArea = All;
                }
                field("Remark 7"; "Remark 7")
                {
                    ApplicationArea = All;
                }
                field("Remark 8"; "Remark 8")
                {
                    ApplicationArea = All;
                }
                field("Remark 9"; "Remark 9")
                {
                    ApplicationArea = All;
                }
                field("Remark 10"; "Remark 10")
                {
                    ApplicationArea = All;
                }
            }
        }
        area(Factboxes)
        {
            part("Available Budget Factbox "; "WEH_Available Budget Factbox 2")
            {
                ApplicationArea = All;
                Caption = 'Available Budget';
                Provider = BudgetCorpLines;
                SubPageLink = "Document No." = FIELD("Document No."),
                              "Line No." = FIELD("Line No.");
            }
            part("Attached Documents"; "Document Attachment Factbox")
            {
                ApplicationArea = All;
                Caption = 'Attachments';
                SubPageLink = "Table ID" = CONST(50008), "No." = FIELD("No.");
            }
            systempart(Control1900383207; Links)
            {
                ApplicationArea = RecordLinks;
            }
        }
    }

    actions
    {
        area(Reporting)
        {
            action("Add Budget Request")
            {
                Caption = 'Add Budget Request';
                ApplicationArea = All;
                Image = PrintDocument;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Report;

                trigger OnAction();
                var
                    TransfBudgetHead: Record "WEH_Add/T. Budget COR Header";
                begin
                    CurrPage.SetSelectionFilter(TransfBudgetHead);
                    Report.RunModal(Report::"WEH_Transfer Budget Request", true, false, TransfBudgetHead);
                end;
            }
        }
        area(Processing)
        {
            /*
            action("Approve Add Budget")
            {
                Caption = 'Approve Add Budget';
                ApplicationArea = All;
                Image = Approve;
                Promoted = true;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    UpdateStatusApprove(2);
                end;
            }
            action("Un-Approve Add Budget")
            {
                Caption = 'Un-Approve Add Budget';
                ApplicationArea = All;
                Image = CancelApprovalRequest;
                Promoted = true;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    UpdateStatusApprove(0);
                end;
            }
            action("Reject Add Budget")
            {
                Caption = 'Reject Add Budget';
                ApplicationArea = All;
                Image = Reject;
                Promoted = true;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    UpdateStatusApprove(3);
                end;
            }
            action("Send Approve Add Budget")
            {
                Caption = 'Send Req. Approve Add Budget';
                ApplicationArea = All;
                Image = SendApprovalRequest;
                Promoted = true;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    UpdateStatusApprove(1);
                end;
            }
            */
            action(Post)
            {
                Caption = 'Post';
                ApplicationArea = All;
                Image = Post;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Category5;

                trigger OnAction()
                begin
                    PostTransferGLBudgetEntry();
                end;
            }
            action("Send for Approval")
            {
                Caption = 'Send for Approval';
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Category6;
                PromotedIsBig = true;
                PromotedOnly = true;
                Image = SendApprovalRequest;
                Enabled = NOT OpenApprovalEntriesExist AND CanRequestApprovalForFlow;
                trigger OnAction()
                var
                    AddBudgetLine: Record "WEH_Add/T. Budget COR Line";
                    ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                begin
                    Rec.TestField("Post to Budget");
                    if Rec."Approve Status" in [Rec."Approve Status"::Approved, Rec."Approve Status"::"Pending Approval"] then
                        Error('Approve Status must be reject or blank');

                    Rec.GetBudgetInfo();

                    Clear(AddBudgetLine);
                    AddBudgetLine.SetRange("Document No.", Rec."No.");
                    if AddBudgetLine.FindSet() then begin
                        repeat
                            if AddBudgetLine."Budget Type" = AddBudgetLine."Budget Type"::C then begin
                                AddBudgetLine.TestField("Global Dimension 1 Code");
                                AddBudgetLine.TestField("Global Dimension 2 Code");
                            end else
                                if AddBudgetLine."Budget Type" = AddBudgetLine."Budget Type"::O then
                                    AddBudgetLine.TestField("Global Dimension 1 Code");
                        until AddBudgetLine.Next() = 0;
                    end;

                    IF InitWF.CheckWorkflowBudgetEnabled(Rec) THEN
                        InitWF.OnSendBudgetforApproval(Rec);
                end;
            }
            action("Cancel Approval Request")
            {
                Caption = 'Cancel Approval Request';
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Category6;
                PromotedIsBig = true;
                PromotedOnly = true;
                Image = CancelApprovalRequest;
                Enabled = CanCancelApprovalForRecord OR CanCancelApprovalForFlow;
                trigger OnAction()
                var
                    ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    WorkflowWebhookMgt: Codeunit "Workflow Webhook Management";
                begin
                    InitWF.OnCancelBudgetforApproval(Rec);
                    WorkflowWebhookMgt.FindAndCancel(RECORDID);
                end;
            }
            action(Approvals)
            {
                Caption = 'Approval Entry';
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Category6;
                PromotedIsBig = true;
                PromotedOnly = true;
                Image = Approvals;
                trigger OnAction()
                var
                    ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                begin
                    ApprovalsMgmt.OpenApprovalEntriesPage(RecordId);
                end;
            }
            action("Reopen Approved")
            {
                Caption = 'Reopen Approved';
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Category6;
                PromotedIsBig = true;
                PromotedOnly = true;
                Image = ReOpen;

                trigger OnAction()
                begin
                    Rec.TestField("Approve Status", Rec."Approve Status"::Approved);

                    if not Confirm('Do you want to re-open approved budget?') then
                        exit;

                    Rec."Approve Status" := Rec."Approve Status"::" ";
                    Rec.Modify();
                end;
            }
            action(Approve)
            {
                Caption = 'Approve';
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                PromotedOnly = true;
                Image = Approve;
                Visible = OpenApprovalEntriesExistForCurrUser;
                trigger OnAction()
                var
                    ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                begin
                    ApprovalsMgmt.ApproveRecordApprovalRequest(RECORDID);
                end;
            }
            action(Reject)
            {
                Caption = 'Reject';
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                PromotedOnly = true;
                Image = Reject;
                Visible = OpenApprovalEntriesExistForCurrUser;
                trigger OnAction()
                var
                    ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                begin
                    ApprovalsMgmt.RejectRecordApprovalRequest(RECORDID);
                end;
            }
            action(Delegate)
            {
                Caption = 'Delegate';
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                PromotedOnly = true;
                Image = Delegate;
                Visible = OpenApprovalEntriesExistForCurrUser;
                trigger OnAction()
                var
                    ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                begin
                    ApprovalsMgmt.DelegateRecordApprovalRequest(RECORDID);
                end;
            }
            action(Comment)
            {
                Caption = 'Comment';
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                PromotedOnly = true;
                Image = ViewComments;
                Visible = OpenApprovalEntriesExistForCurrUser;
                trigger OnAction()
                var
                    ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                begin
                    ApprovalsMgmt.GetApprovalComment(Rec);
                end;
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        "Document Type" := "Document Type"::"Transfer Budget";
        SetPageEditabled();
    end;

    trigger OnAfterGetRecord()
    begin
        SetControlAppearance;
        SetPageEditabled();

        GetPendingApprovalID();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        SetControlAppearance;
        SetPageEditabled();

        GetPendingApprovalID();
    end;

    var
        InitWF: Codeunit "WEH_Budget Control Management";
        OpenApprovalEntriesExistForCurrUser: Boolean;
        CanRequestApprovalForFlow: Boolean;
        OpenApprovalEntriesExist: Boolean;
        CanCancelApprovalForRecord: Boolean;
        CanCancelApprovalForFlow: Boolean;
        PageEditabled: Boolean;
        PendingApprovalID: code[50];

    local procedure SetPageEditabled()
    var
    begin
        if "Approve Status" in ["Approve Status"::" ", "Approve Status"::Reject] then
            PageEditabled := true
        else
            PageEditabled := false;
    end;

    local procedure SetControlAppearance()
    var
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        WorkflowWebhookMgt: Codeunit "Workflow Webhook Management";
    begin
        OpenApprovalEntriesExistForCurrUser := ApprovalsMgmt.HasOpenApprovalEntriesForCurrentUser(RECORDID);
        OpenApprovalEntriesExist := ApprovalsMgmt.HasOpenApprovalEntries(RECORDID);
        CanCancelApprovalForRecord := ApprovalsMgmt.CanCancelApprovalForRecord(RECORDID);
        WorkflowWebhookMgt.GetCanRequestAndCanCancel(RECORDID, CanRequestApprovalForFlow, CanCancelApprovalForFlow);
    end;

    local procedure GetPendingApprovalID()
    var
        ApprovalEntry: Record "Approval Entry";
    begin
        Clear(PendingApprovalID);
        Clear(ApprovalEntry);
        ApprovalEntry.SetRange("Table ID", Database::"WEH_Add/T. Budget COR Header");
        ApprovalEntry.SetRange("Document Type", ApprovalEntry."Document Type"::"Trans. Budget Order - Corp.");
        ApprovalEntry.SetRange("Document No.", Rec."No.");
        ApprovalEntry.SetRange(Status, ApprovalEntry.Status::Open);
        if ApprovalEntry.FindLast() then
            PendingApprovalID := ApprovalEntry."Approver ID";
    end;
}
