report 50022 "WEH_Transfer Budget Request"
{
    DefaultLayout = RDLC;
    RDLCLayout = '8 - Report/Rep50022.WEHTransferBudgetRequest.rdl';
    Caption = 'Transfer Budget Request';
    PreviewMode = PrintLayout;

    dataset
    {
        dataitem("WEH_Add/T. Budget COR Header"; "WEH_Add/T. Budget COR Header")
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.";
            column(No_AddTransferBudgetCORHeader; "WEH_Add/T. Budget COR Header"."No.")
            {

            }
            column(CompanyInfo_Picture; CompanyInfo.Picture)
            {

            }
            column(ResourceName; Employee."First Name")
            {

            }
            column(DocumentDate_AddTransferBudgetCORHeader; FORMAT("Document Date", 0, '<Day,2>/<Month,2>/<Year4>'))
            {

            }
            column(Remark; Remark)
            {

            }
            column(Remark_2; "Remark 2")
            {

            }
            column(Remark_3; "Remark 3")
            {

            }
            column(Remark_4; "Remark 4")
            {

            }
            column(Remark_5; "Remark 5")
            {

            }
            column(Remark_6; "Remark 6")
            {

            }
            column(Remark_7; "Remark 7")
            {

            }
            column(Remark_8; "Remark 8")
            {

            }
            column(Remark_9; "Remark 9")
            {

            }
            column(Remark_10; "Remark 10")
            {

            }
            dataitem("WEH_Add/T. Budget COR Line"; "WEH_Add/T. Budget COR Line")
            {
                DataItemLink = "Document No." = FIELD("No.");
                DataItemLinkReference = "WEH_Add/T. Budget COR Header";
                DataItemTableView = SORTING("Document No.", "Line No.");

                column(Running; Running)
                {

                }
                column(Budget_Type; "Budget Type")
                {

                }
                column(G_L_Account_No_; "G/L Account No.")
                {

                }
                column(Global_Dimension_1_Code; "Global Dimension 1 Code")
                {

                }
                column(Description; Description)
                {

                }
                column(To_Total_Amount__LCY_; "To Total Amount (LCY)")
                {

                }
                column(To_G_L_Account_No_; "To G/L Account No.")
                {

                }
                column(To_Global_Dimension_1_Code; "To Global Dimension 1 Code")
                {

                }
                column(To_Description; "To Description")
                {

                }

                trigger OnAfterGetRecord()
                var
                    myInt: Integer;
                begin
                    Running += 1;
                end;

                trigger OnPreDataItem()
                var
                    myInt: Integer;
                begin
                    //Line := COUNT;
                    CLEAR(Line);
                    CLEAR(AddTransferBudgetCORLine);
                    AddTransferBudgetCORLine.SETCURRENTKEY("Document No.", "Line No.");
                    AddTransferBudgetCORLine.SETRANGE("Document No.", "WEH_Add/T. Budget COR Header"."No.");
                    Line := AddTransferBudgetCORLine.COUNT;
                end;
            }

            dataitem(EmptyLine; "Integer")
            {
                DataItemTableView = sorting(Number);
                column(Number_EmptyLine; EmptyLine.Number)
                {
                }

                trigger OnPreDataItem();
                begin
                    /*if Running = CountLine then begin
                        if (Running mod MaxLine) = 0 then
                            SetRange(Number, 1, 0)
                        else begin
                            AddLine := MaxLine - (Running mod MaxLine);
                            SetRange(Number, 1, AddLine);
                        end;
                    end
                    else
                        SetRange(Number, 1, 0);*///AVKSAVIP 24/04/2020
                    if Running = Line then begin
                        if (Running mod MaxLine) = 0 then
                            SetRange(Number, 1, 0)
                        else begin
                            AddLine := MaxLine - (Running mod MaxLine);
                            SetRange(Number, 1, AddLine);
                        end;
                    end
                    else
                        SetRange(Number, 1, 0);

                end;
            }

            trigger OnAfterGetRecord()
            var
                myInt: Integer;
            begin
                //CLEAR(Resource);
                //IF "Add/Transfer Budget COR Header"."Requested by" <> '' THEN
                //Resource.GET("Add/Transfer Budget COR Header"."Requested by");

                CLEAR(Employee);
                IF Employee.GET("WEH_Add/T. Budget COR Header"."Requested by") THEN;
            end;

            trigger OnPreDataItem();
            begin
                CompanyInfo.Get();
                CompanyInfo.CalcFields(Picture);

                MaxLine := 10;
            end;
        }
    }

    /*
        requestpage
        {
            layout
            {
                area(Content)
                {
                    group(GroupName)
                    {
                        field(Name; SourceExpression)
                        {
                            ApplicationArea = All;

                        }
                    }
                }
            }

            actions
            {
                area(processing)
                {
                    action(ActionName)
                    {
                        ApplicationArea = All;

                    }
                }
            }
        }
    */
    var
        CompanyInfo: Record "Company Information";
        Employee: Record Employee;
        Running: Integer;
        Maxline: Integer;
        AddLine: Integer;
        Resource: Record Resource;
        Subtotal: Decimal;
        TotalDiscount: Decimal;
        i: Integer;
        NetTotal: Decimal;
        Line: Integer;
        AddTransferBudgetCORLine: Record "WEH_Add/T. Budget COR Line";
        Qty: Decimal;
        UnitPrice: Decimal;
        AmountT: Decimal;
        DiscountAmount: Decimal;
        AmountVAT: Decimal;
        AmtExdVAT: Decimal;
        VATPersent: Integer;
        runno: Integer;
}