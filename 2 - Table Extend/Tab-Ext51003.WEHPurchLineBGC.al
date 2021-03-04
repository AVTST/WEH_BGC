tableextension 51003 "WEH_Purch. Line BGC" extends "Purchase Line"
{
    fields
    {
        field(51000; "WEH_Budget Type"; Enum "WEH_Budget Type")
        {
            Caption = 'Budget Type';
            //OptionMembers = " ",O,C,P;
        }
        field(51001; "WEH_Budget Name"; Code[10])
        {
            Caption = 'Budget Name';
            TableRelation = "G/L Budget Name" where("WEH_G/L Budget Name Type" = const(Budget));
        }
        field(51002; "WEH_Check Budget"; Enum "WEH_Check Budget")
        {
            Caption = 'Check Budget';
            //OptionMembers = " ",PASS,"NOT PASS";
        }
        field(51003; "WEH_Finish PR"; Boolean)
        {
            Caption = 'Finish PR';
        }
        modify("AVFN_G/L_Temp")
        {
            trigger OnAfterValidate()
            var
                GLTemp: Record "AVFN_G/L (Order) Template";
            begin
                Clear(GLTemp);
                if GLTemp.Get(GLTemp."Order Type"::Purchase, "AVFN_G/L_Temp") then begin
                    if GLTemp."WEH_Budget Type" <> GLTemp."WEH_Budget Type"::" " then
                        "WEH_Budget Type" := GLTemp."WEH_Budget Type";
                end;
            end;
        }
        /*
        modify("Direct Unit Cost")
        {
            trigger OnAfterValidate()
            var
                PurchLine: Record "Purchase Line";
            begin
                CLEAR(PurchLine);
                IF PurchLine.GET("Document Type"::Quote, "AVTD_Ref. Doc. No.", "AVTD_Ref. Line No.") THEN
                    //IF "Direct Unit Cost" > PurchLine."Direct Unit Cost" THEN
                    //Error('Direct Unit Cost cannot more than %1 in PR No. %2 Line No. %3', PurchLine."Direct Unit Cost", PurchLine."Document No.", PurchLine."Line No.");
                    IF "Outstanding Amt. Ex. VAT (LCY)" > PurchLine."Outstanding Amt. Ex. VAT (LCY)" THEN
                        Error('Outstanding Amt. Ex. VAT (LCY) cannot more than %1 in PR No. %2 Line No. %3', PurchLine."Outstanding Amt. Ex. VAT (LCY)", PurchLine."Document No.", PurchLine."Line No.");
            end;
        }
        */
    }

    trigger OnAfterDelete()
    var
        PurchHead: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
    begin
        if Rec."Document Type" = Rec."Document Type"::Order then begin
            CLEAR(PurchLine);
            IF PurchLine.GET("Document Type"::Quote, "AVTD_Ref. Doc. No.", "AVTD_Ref. Line No.") THEN begin
                PurchLine."WEH_Finish PR" := false;
                PurchLine.Modify();

                PurchHead.get("Document Type"::Quote, "AVTD_Ref. Doc. No.");
                if PurchHead."WEH_Finish PR" then begin
                    PurchHead."WEH_Finish PR" := false;
                    PurchHead.Modify();
                end;
            end;
        end;
    end;
}
