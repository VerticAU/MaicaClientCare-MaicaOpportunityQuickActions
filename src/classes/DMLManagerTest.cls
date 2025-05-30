@isTest
private class DMLManagerTest {

    @TestSetup
    static void testSetup() {
        createRestrictedUser();
    }

    /**
     * Creates a User that has only "Read" access to Accounts, Contacts and Opps
     */
    private static void createRestrictedUser() {
        // PMGR-9655 - Starting with Spring '21, the "Read Only" profile may not exist. We should default to using the
        // new "Minimum Access - Salesforce" profile, falling back to "Read Only" otherwise.
        List<Profile> profileList = [SELECT Id, Name FROM Profile WHERE Name IN ('Minimum Access - Salesforce', 'Read Only') ORDER BY Name];
        System.assert(
                profileList.size() >= 1,
                'Unable to create a "restricted" User for testing purposes because we are not able to find the required User Profiles.'
        );
        User restrictedUser = new User(
                Alias = 'standt',
                Email = 'standarduser@testorg.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'Testing',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                // Use the first Profile in the list. Because we've ordered by name, this causes us to use
                // "Minimum Access - Salesforce" if it's present.
                ProfileId = profileList[0].Id,
                TimeZoneSidKey = 'America/Los_Angeles',
                Username = '' + Datetime.now().getTime() + 'crudmanageruser1@testorg.com'
        );
        insert restrictedUser;

        // Create a Permission Set that grants "Read" access to Account, Contact
        PermissionSet ps = new PermissionSet(Label = 'Restricted User', Name = 'RestrictedUser');
        insert ps;

        List<ObjectPermissions> objectPerms = new List<ObjectPermissions>();
        objectPerms.add(createObjectPerms(ps.Id, 'Account', true, false, false, false));
        objectPerms.add(createObjectPerms(ps.Id, 'Contact', true, false, false, false));
        insert objectPerms;

        // Assign this perm set to our restricted user
        PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId = restrictedUser.Id, PermissionSetId = ps.Id);
        insert psa;
    }

    private static ObjectPermissions createObjectPerms(
            Id parentId, String objectType, Boolean canRead, Boolean canCreate, Boolean canEdit, Boolean canDelete
    ) {
        return new ObjectPermissions(
                ParentId = parentId,
                SobjectType = objectType,
                PermissionsRead = canRead,
                PermissionsCreate = canCreate,
                PermissionsEdit = canEdit,
                PermissionsDelete = canDelete
        );
    }

    private static User getRestrictedUser() {
        return [SELECT Id FROM User WHERE Username LIKE '%crudmanageruser1@testorg.com'];
    }

    static testMethod void systemInsert() {
        Contact c1 = new Contact(LastName = 'Original1 Opp');

        User restrictedUser = getRestrictedUser();

        Boolean isExceptionThrown = false;
        try {
            System.runAs(restrictedUser) {
                DMLManager.insertAsSystem(new Contact[]{
                        c1
                });
            }
        } catch (Exception e) {
            isExceptionThrown = true;
        } finally {
            System.assertEquals(false, isExceptionThrown, 'System mode should perform DML regardless of access');
        }
    }

    static testMethod void flsRestrictedInsert() {
        Account c1 = new Account(Name = 'Test1 Campaign');
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert new Account[]{
                    c1
            };
        }

        Contact o1 = new Contact(LastName = 'Original1 Opp', AccountId = c1.Id);

        User restrictedUser = getRestrictedUser();

        // Grant "Create" perm, in addition to "Read"
        assignObjectPermission(restrictedUser, 'Contact', true, false, false);

        System.runAs(restrictedUser) {
            try {
                DMLManager.insertAsUser(new Contact[]{
                        o1
                });
                System.assert(false, 'Expected a DML Error! Restricted User shouldn\'t be able to insert Contact.AccountId');
            } catch (DMLManager.FLSException flse) {
                //expected
                System.assertEquals(Contact.SObjectType, flse.objType);
                System.assertEquals(DMLManager.Operation.OP_INSERT, flse.op);
                System.assertEquals(Contact.SObjectType.fields.AccountId, flse.field);
            }
        }

    }

    static testMethod void flsUnrestrictedUpsert() {
        Account c1 = new Account(Name = 'Test1 Campaign');
        Account c2 = new Account(Name = 'Test2 Campaign');
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert new Account[]{
                    c1, c2
            };
        }

        Contact o1 = new Contact(LastName = 'Original1 Opp', AccountId = c1.Id);
        DMLManager.upsertAsUser(new Contact[]{
                o1
        });
        System.assert(o1.Id != null);

        o1.LastName = 'Updated1 Opp';
        o1.AccountId = c2.Id;

        Contact o2 = new Contact(LastName = 'Test2 Opp', AccountId = c2.Id);

        DMLManager.upsertAsUser(new Contact[]{
                o1, o2
        });

        List<Contact> reload = [SELECT Id, LastName, AccountId FROM Contact ORDER BY Id];
        System.assertEquals(reload.size(), 2);
        System.assertEquals('Updated1 Opp', reload[0].LastName);
        System.assertEquals(c2.Id, reload[0].AccountId);
        System.assertEquals('Test2 Opp', reload[1].LastName);
        System.assertEquals(c2.Id, reload[1].AccountId);
        System.assert(reload[1].Id != null);
    }

    // static testMethod void crudUnrestrictedInsertUpdateDelete() {
    //     Account c1 = new Account(Name = 'Test1 Account');
    //     DMLManager.insertAsUser(c1);

    //     //Would blow up if the Campaign wasn't inserted (List has no rows for assignment)
    //     Account c1Reload = [SELECT Id, Name FROM Account WHERE Id = :c1.Id];

    //     c1Reload.Name = 'Test1 Account1';

    //     DMLManager.updateAsUser(c1Reload);

    //     c1Reload = [SELECT Id, Name FROM Account WHERE Id = :c1.Id];
    //     System.assertEquals('Test1 Account1', c1Reload.Name);

    //     DMLManager.deleteAsUser(c1Reload);

    //     List<Account> reloaded = [SELECT Id, Name FROM Account];
    //     System.assertEquals(0, reloaded.size());
    // }

    static testMethod void crudRestrictedInsertUpdateDelete() {
        User restrictedUser = getRestrictedUser();

        Campaign c1 = new Campaign(Name = 'Test1 Campaign');
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert c1;
        }

        System.runAs(restrictedUser) {
            // First try to insert a new object (including field two)
            try {
                Campaign c2 = new Campaign(Name = 'Test2  Campaign');
                DMLManager.insertAsUser(c2);
                System.assert(false, 'Expected a DML Error!, Restricted User shouldn\'t be able to insert a Campaign');
            } catch (DMLManager.CRUDException crude) {
                //expected
                System.assertEquals(Campaign.SObjectType, crude.objType);
                System.assertEquals(DMLManager.Operation.OP_INSERT, crude.op);
            }

            // Second, try to update the already inserted (previously) object, including field two
            try {
                c1.Name = 'Updated1 Campaign';
                DMLManager.updateAsUser(c1);
                System.assert(false, 'Expected a DML Error!, Restricted User shouldn\'t be able to update a Campaign');
            } catch (DMLManager.CRUDException crude) {
                //expected
                System.assertEquals(Campaign.SObjectType, crude.objType);
                System.assertEquals(DMLManager.Operation.OP_UPDATE, crude.op);
            }

            try {
                DMLManager.deleteAsUser(c1);
                System.assert(false, 'Expected a DML Error!, Restricted User shouldn\'t be able to delete a Campaign');
            } catch (DMLManager.CRUDException crude) {
                //expected
                System.assertEquals(Campaign.SObjectType, crude.objType);
                System.assertEquals(DMLManager.Operation.OP_DELETE, crude.op);
            }
        }
    }

    static testmethod void testFailedUpdateWithErroneousId() {
        Account c1 = new Account(Name = 'Test1 Account');
        Id cId = null;

        insert new SObject[]{
                c1
        };
        cId = c1.Id;
        delete c1;

        try {
            Account c1Resurrected = new Account(Id = cId, Name = 'Resurrected Account');
            DMLManager.upsertAsUser(c1Resurrected);
            System.assert(false, 'Expected a DMLManagerException! Attempting to update a record with an erroneous Id should fail');
        } catch (DMLManager.DMLManagerException dmle) {
            //expected
            System.assert(dmle.getMessage().contains('An existing record could not be found'));
        }
    }

    private static void assignObjectPermission(User u, String objectType, Boolean create, Boolean edit, Boolean remove) {
        PermissionSet ps = new PermissionSet(Name = 'Enable' + objectType, Label = 'Enable ' + objectType);
        insert ps;

        ObjectPermissions oPerm = new ObjectPermissions(ParentId = ps.Id,
                PermissionsRead = true,
                PermissionsCreate = create,
                PermissionsEdit = edit,
                PermissionsDelete = remove,
                SObjectType = objectType);

        insert oPerm;

        PermissionSetAssignment assign = new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = ps.Id);
        insert assign;
    }
}