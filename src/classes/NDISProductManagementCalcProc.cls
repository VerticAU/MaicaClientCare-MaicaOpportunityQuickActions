//SECURED!
public with sharing class NDISProductManagementCalcProc extends AbstractProcessor {

    private OpportunityLineItem lineItemVar = new OpportunityLineItem();
    private Boolean isNextOccurrenceDateExist = false;
    private List<Holiday> publicHolidays;
    private Decimal quantity = 0;
    private Boolean enforceHolidaysByState;
    private Boolean isItemValidForServiceDate;
    private String participantState;
    private Boolean isCategoryType;

    public override Response process(Request request) {
        this.request = request;

        this.doInit();
        this.calculateQuantity();
        this.validateItemServiceDate();
        this.initResponse();

        return this.response;
    }

    private void doInit() {
        this.request.getMapper().mapToSObject('item', this.lineItemVar);
        String opportunityId = this.request.getString('opportunityId');
        this.enforceHolidaysByState = this.request.getBoolean('enforceHolidaysByState');
        this.enforceHolidaysByState = this.enforceHolidaysByState == null ? false : this.enforceHolidaysByState;
        Opportunity opportunityVar = (Opportunity) Utils.arrays.firstOrException(
                [SELECT Id, Participant__r.MailingState FROM Opportunity WHERE Id = :opportunityId WITH USER_MODE],
                'No Opportunity with Id: ' + opportunityId
        );
        this.participantState = String.isBlank(opportunityVar.Participant__r?.MailingState) ? '' : opportunityVar.Participant__r.MailingState;
        this.isCategoryType = 'Category'.equalsIgnoreCase(this.request.getString('item.type'));

        this.isNextOccurrenceDateExist = Holiday.SObjectType.getDescribe().fields.getMap().get('NextOccurrenceDate') != null;
        if (this.isNextOccurrenceDateExist) {
            this.publicHolidays = Database.query('SELECT ActivityDate, NextOccurrenceDate, Name FROM Holiday');
        } else {
            this.publicHolidays = Database.query('SELECT ActivityDate, Name FROM Holiday');
        }
    }

    private void calculateQuantity() {

        if (this.isCategoryType == true) {
            this.quantity = 1;
            return;
        }

        Date nextDate = this.lineItemVar.Start_Date__c;
        this.lineItemVar.Schedule_Count__c = this.lineItemVar.Schedule_Count__c == 0 ? 1 : this.lineItemVar.Schedule_Count__c;

        while (nextDate <= this.lineItemVar.End_Date__c) {
            if ('Public Holiday'.equalsIgnoreCase(this.lineItemVar.Service_Day__c)) {
                Set<Datetime> usedActivityDates = new Set<Datetime>();
                for (Holiday holidayVar : this.publicHolidays) {
                    if (usedActivityDates.contains(holidayVar.ActivityDate)) {
                        continue;
                    }
                    Boolean isHolidayValid = isHolidayValid(nextDate, holidayVar, this.enforceHolidaysByState, this.participantState, this.isNextOccurrenceDateExist);

                    if (isHolidayValid) {
                        usedActivityDates.add(holidayVar.ActivityDate);
                        this.quantity++;
                    }

                }
                nextDate = nextDate.addDays(1);
            } else if ('One'.equalsIgnoreCase(this.lineItemVar.Service_Frequency__c)) {
                this.quantity = 1;
                break;

            } else if ('Day'.equalsIgnoreCase(this.lineItemVar.Service_Frequency__c)) {
                if (nextDate <= this.lineItemVar.End_Date__c) {
                    this.quantity++;
                }
                nextDate = nextDate.addDays(Utils.objects.defaultIfNull(this.lineItemVar.Schedule_Count__c, 1).intValue());

            } else if ('Week'.equalsIgnoreCase(this.lineItemVar.Service_Frequency__c)) {
                Date weekEnd = nextDate.addDays(6);
                List<String> weekDays = Utils.strings.emptyStringIfNull(this.lineItemVar.Schedule_Day__c).split(';');

                while (nextDate <= weekEnd && nextDate <= this.lineItemVar.End_Date__c) {
                    for (String weekDay : weekDays) {
                        if (((Datetime) nextDate).format('EEEE').equalsIgnoreCase(weekDay)) {
                            this.quantity++;
                        }
                    }
                    nextDate = nextDate.addDays(1);
                }

                nextDate = weekEnd.addDays(7 * (Utils.objects.defaultIfNull(this.lineItemVar.Schedule_Count__c, 1).intValue() - 1) + 1);

            } else if ('Month'.equalsIgnoreCase(this.lineItemVar.Service_Frequency__c)) {
                if (nextDate <= this.lineItemVar.End_Date__c) {
                    this.quantity++;
                }
                nextDate = nextDate.addMonths(Utils.objects.defaultIfNull(this.lineItemVar.Schedule_Count__c, 1).intValue());
            }
        }

        this.quantity = this.quantity * Utils.objects.defaultIfNull(lineItemVar.Service_Duration__c, 1);
        this.quantity = this.quantity.setScale(2);
    }

    private void validateItemServiceDate() {
        String supportItemId = this.request.getString('item.Product2Id');

        if (this.isCategoryType == true) {
            this.isItemValidForServiceDate = true;
        } else if (supportItemId != null && this.lineItemVar.Start_Date__c != null) {
            Product2 productVar = (Product2) Utils.arrays.firstOrException([
                    SELECT Id, Service_Day__c, Service_Time__c FROM Product2 WHERE Id = :supportItemId WITH USER_MODE
            ], 'No Product2 with Id: ' + supportItemId);

            this.isItemValidForServiceDate = new Set<String>{
                    null, productVar.Service_Day__c
            }.contains(this.lineItemVar.Service_Day__c) && new Set<String>{
                    null, productVar.Service_Time__c
            }.contains(this.lineItemVar.Service_Time__c);
        }
    }

    private void initResponse() {
        this.response.put('quantity', this.quantity)
                .put('item', this.lineItemVar)
                .put('isItemValidForServiceDate', this.isItemValidForServiceDate);
    }

    public static Boolean isHolidayValid(Date serviceDate, Holiday holidayVar, Boolean enforceHolidaysByState, String participantState, Boolean isNextOccurrenceDateExist) {
        Boolean isActivityDateValid = (!isNextOccurrenceDateExist || holidayVar.get('NextOccurrenceDate') == null)
                && serviceDate.day() == holidayVar.ActivityDate.day()
                && serviceDate.month() == holidayVar.ActivityDate.month()
                && serviceDate.year() == holidayVar.ActivityDate.year();

        Boolean isNextOccurrenceDateValid = false;
        if (isNextOccurrenceDateExist && holidayVar.get('NextOccurrenceDate') != null) {
            Date nextOccurrenceDate = Date.valueOf(holidayVar.get('NextOccurrenceDate') + '');
            isNextOccurrenceDateValid = serviceDate.day() == nextOccurrenceDate.day()
                    && serviceDate.month() == nextOccurrenceDate.month()
                    && serviceDate.year() == nextOccurrenceDate.year();
        }

        if (isActivityDateValid || isNextOccurrenceDateValid) {
            if (!enforceHolidaysByState) {
                return true;

            } else if (!holidayVar.Name.contains('(') && !holidayVar.Name.contains(')')) {
                return true;

            } else if (String.isNotBlank(participantState) && holidayVar.Name.containsIgnoreCase('(' + participantState + ')')) {
                return true;
            }
        }

        return false;
    }
}