import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static AppLocalizations? maybeOf(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  // English
  static AppLocalizations en = AppLocalizations(Locale('en'));

  // Arabic
  static AppLocalizations ar = AppLocalizations(Locale('ar'));

  // Getters for all strings
  String get appTitle => _localizedValues[locale.languageCode]!['appTitle'] ?? 'Ashhab Gym';
  String get dashboard => _localizedValues[locale.languageCode]!['dashboard'] ?? 'Dashboard';
  String get members => _localizedValues[locale.languageCode]!['members'] ?? 'Members';
  String get pendingDevices => _localizedValues[locale.languageCode]!['pendingDevices'] ?? 'Pending Devices';
  String get settings => _localizedValues[locale.languageCode]!['settings'] ?? 'Settings';
  String get logout => _localizedValues[locale.languageCode]!['logout'] ?? 'Logout';
  String get login => _localizedValues[locale.languageCode]!['login'] ?? 'Login';
  String get email => _localizedValues[locale.languageCode]!['email'] ?? 'Email';
  String get password => _localizedValues[locale.languageCode]!['password'] ?? 'Password';
  String get loginButton => _localizedValues[locale.languageCode]!['loginButton'] ?? 'Login';
  String get welcomeMessage => _localizedValues[locale.languageCode]!['welcomeMessage'] ?? 'Welcome to Ashhab Gym Admin';
  String get memberDetails => _localizedValues[locale.languageCode]!['memberDetails'] ?? 'Member Details';
  String get deviceId => _localizedValues[locale.languageCode]!['deviceId'] ?? 'Device ID';
  String get phoneNumber => _localizedValues[locale.languageCode]!['phoneNumber'] ?? 'Phone Number';
  String get memberName => _localizedValues[locale.languageCode]!['memberName'] ?? 'Member Name';
  String get membershipStatus => _localizedValues[locale.languageCode]!['membershipStatus'] ?? 'Membership Status';
  String get subscriptionStartDate => _localizedValues[locale.languageCode]!['subscriptionStartDate'] ?? 'Subscription Start Date';
  String get subscriptionExpiryDate => _localizedValues[locale.languageCode]!['subscriptionExpiryDate'] ?? 'Subscription Expiry Date';
  String get subscriptionAmount => _localizedValues[locale.languageCode]!['subscriptionAmount'] ?? 'Subscription Amount';
  String get active => _localizedValues[locale.languageCode]!['active'] ?? 'Active';
  String get pending => _localizedValues[locale.languageCode]!['pending'] ?? 'Pending';
  String get inactive => _localizedValues[locale.languageCode]!['inactive'] ?? 'Inactive';
  String get viewDetails => _localizedValues[locale.languageCode]!['viewDetails'] ?? 'View Details';
  String get edit => _localizedValues[locale.languageCode]!['edit'] ?? 'Edit';
  String get delete => _localizedValues[locale.languageCode]!['delete'] ?? 'Delete';
  String get activate => _localizedValues[locale.languageCode]!['activate'] ?? 'Activate';
  String get deactivate => _localizedValues[locale.languageCode]!['deactivate'] ?? 'Deactivate';
  String get renewSubscription => _localizedValues[locale.languageCode]!['renewSubscription'] ?? 'Renew Subscription';
  String get activateMember => _localizedValues[locale.languageCode]!['activateMember'] ?? 'Activate Member';
  String get memberActivatedSuccessfully => _localizedValues[locale.languageCode]!['memberActivatedSuccessfully'] ?? 'Member activated successfully!';
  String get failedToActivateMember => _localizedValues[locale.languageCode]!['failedToActivateMember'] ?? 'Failed to activate member';
  String get subscriptionRenewedSuccessfully => _localizedValues[locale.languageCode]!['subscriptionRenewedSuccessfully'] ?? 'Subscription renewed successfully!';
  String get failedToRenewSubscription => _localizedValues[locale.languageCode]!['failedToRenewSubscription'] ?? 'Failed to renew subscription';
  String get cancel => _localizedValues[locale.languageCode]!['cancel'] ?? 'Cancel';
  String get ok => _localizedValues[locale.languageCode]!['ok'] ?? 'OK';
  String get confirm => _localizedValues[locale.languageCode]!['confirm'] ?? 'Confirm';
  String get deleteMember => _localizedValues[locale.languageCode]!['deleteMember'] ?? 'Delete Member';
  String get deleteMemberConfirmation => _localizedValues[locale.languageCode]!['deleteMemberConfirmation'] ?? 'Are you sure you want to delete {name}? This action cannot be undone.';
  String get memberDeletedSuccessfully => _localizedValues[locale.languageCode]!['memberDeletedSuccessfully'] ?? 'Member deleted successfully';
  String get failedToDeleteMember => _localizedValues[locale.languageCode]!['failedToDeleteMember'] ?? 'Failed to delete member';
  String get activateMemberConfirmation => _localizedValues[locale.languageCode]!['activateMemberConfirmation'] ?? 'Are you sure you want to {action} this member?';
  String get language => _localizedValues[locale.languageCode]!['language'] ?? 'Language';
  String get selectLanguage => _localizedValues[locale.languageCode]!['selectLanguage'] ?? 'Select Language';
  String get english => _localizedValues[locale.languageCode]!['english'] ?? 'English';
  String get arabic => _localizedValues[locale.languageCode]!['arabic'] ?? 'العربية';
  String get noPendingDeletionRequests => _localizedValues[locale.languageCode]!['noPendingDeletionRequests'] ?? 'No pending member deletion requests';
  String get approveMemberDeletion => _localizedValues[locale.languageCode]!['approveMemberDeletion'] ?? 'Approve Member Deletion';
  String get member => _localizedValues[locale.languageCode]!['member'] ?? 'Member';
  String get name => _localizedValues[locale.languageCode]!['name'] ?? 'Name';
  String get thisActionCannotBeUndone => _localizedValues[locale.languageCode]!['thisActionCannotBeUndone'] ?? 'This action cannot be undone.';
  String get approveDeletion => _localizedValues[locale.languageCode]!['approveDeletion'] ?? 'Approve Deletion';
  String get rejectMemberDeletion => _localizedValues[locale.languageCode]!['rejectMemberDeletion'] ?? 'Reject Member Deletion';
  String get pleaseProvideRejectionReason => _localizedValues[locale.languageCode]!['pleaseProvideRejectionReason'] ?? 'Please provide a reason for rejection:';
  String get rejectionReason => _localizedValues[locale.languageCode]!['rejectionReason'] ?? 'Rejection Reason';
  String get rejectRequest => _localizedValues[locale.languageCode]!['rejectRequest'] ?? 'Reject Request';
  String get requestRejected => _localizedValues[locale.languageCode]!['requestRejected'] ?? 'Request rejected';
  String get failedToRejectRequest => _localizedValues[locale.languageCode]!['failedToRejectRequest'] ?? 'Failed to reject request';
  String get unknownMember => _localizedValues[locale.languageCode]!['unknownMember'] ?? 'Unknown Member';
  String get requestedBy => _localizedValues[locale.languageCode]!['requestedBy'] ?? 'Requested by';
  String get reject => _localizedValues[locale.languageCode]!['reject'] ?? 'Reject';
  String get deleteUserConfirmation => _localizedValues[locale.languageCode]!['deleteUserConfirmation'] ?? 'Are you sure you want to delete {name} ({email})? This action cannot be undone and the user will not be able to login again.';
  String get deleteUserTitle => _localizedValues[locale.languageCode]!['deleteUserTitle'] ?? 'Delete User';
  String get userDeletedSuccessfully => _localizedValues[locale.languageCode]!['userDeletedSuccessfully'] ?? 'User deleted successfully';
  String get failedToDeleteUser => _localizedValues[locale.languageCode]!['failedToDeleteUser'] ?? 'Failed to delete user';
  String get userStatusUpdated => _localizedValues[locale.languageCode]!['userStatusUpdated'] ?? 'User status updated';
  String get failedToUpdateStatus => _localizedValues[locale.languageCode]!['failedToUpdateStatus'] ?? 'Failed to update status';
  String get requestUserDeletion => _localizedValues[locale.languageCode]!['requestUserDeletion'] ?? 'Request User Deletion';
  String get thisRequestWillRequireAdminApproval => _localizedValues[locale.languageCode]!['thisRequestWillRequireAdminApproval'] ?? 'This request will require admin approval.';
  String get reasonOptional => _localizedValues[locale.languageCode]!['reasonOptional'] ?? 'Reason (optional)';
  String get requestDeletion => _localizedValues[locale.languageCode]!['requestDeletion'] ?? 'Request Deletion';
  String get deletionRequestSubmitted => _localizedValues[locale.languageCode]!['deletionRequestSubmitted'] ?? 'Deletion request submitted';
  String get failedToSubmitRequest => _localizedValues[locale.languageCode]!['failedToSubmitRequest'] ?? 'Failed to submit request';
  String get userDetails => _localizedValues[locale.languageCode]!['userDetails'] ?? 'User Details';
  String get close => _localizedValues[locale.languageCode]!['close'] ?? 'Close';
  String get role => _localizedValues[locale.languageCode]!['role'] ?? 'Role';
  String get status => _localizedValues[locale.languageCode]!['status'] ?? 'Status';
  String get createdAt => _localizedValues[locale.languageCode]!['createdAt'] ?? 'Created At';
  String get lastLogin => _localizedValues[locale.languageCode]!['lastLogin'] ?? 'Last Login';
  String get createdBy => _localizedValues[locale.languageCode]!['createdBy'] ?? 'Created By';
  String get enterMemberNameOrPhoneToFindHistory => _localizedValues[locale.languageCode]!['enterMemberNameOrPhoneToFindHistory'] ?? 'Enter member name or phone number to find member history';
  String get gymAdministrator => _localizedValues[locale.languageCode]!['gymAdministrator'] ?? 'Gym Administrator';
  String get emailAddress => _localizedValues[locale.languageCode]!['emailAddress'] ?? 'Email Address';
  String get currentEmail => _localizedValues[locale.languageCode]!['currentEmail'] ?? 'Current Email: {email}';
  String get changeYourPasswordToKeepAccountSecure => _localizedValues[locale.languageCode]!['changeYourPasswordToKeepAccountSecure'] ?? 'Change your password to keep your account secure';
  String get newEmail => _localizedValues[locale.languageCode]!['newEmail'] ?? 'New Email';
  String get enterNewEmailAddress => _localizedValues[locale.languageCode]!['enterNewEmailAddress'] ?? 'Enter new email address';
  String get pleaseEnterAnEmailAddress => _localizedValues[locale.languageCode]!['pleaseEnterAnEmailAddress'] ?? 'Please enter an email address';
  String get pleaseEnterAValidEmailAddress => _localizedValues[locale.languageCode]!['pleaseEnterAValidEmailAddress'] ?? 'Please enter a valid email address';
  String get newPasswordsDoNotMatch => _localizedValues[locale.languageCode]!['newPasswordsDoNotMatch'] ?? 'New passwords do not match';
  String get errorUpdatingEmail => _localizedValues[locale.languageCode]!['errorUpdatingEmail'] ?? 'Error updating email: {error}';
  String get errorUpdatingPassword => _localizedValues[locale.languageCode]!['errorUpdatingPassword'] ?? 'Error updating password: {error}';
  String get pleaseEnterYourCurrentPassword => _localizedValues[locale.languageCode]!['pleaseEnterYourCurrentPassword'] ?? 'Please enter your current password';
  String get pleaseEnterANewPassword => _localizedValues[locale.languageCode]!['pleaseEnterANewPassword'] ?? 'Please enter a new password';
  String get passwordMustBeAtLeast6Characters => _localizedValues[locale.languageCode]!['passwordMustBeAtLeast6Characters'] ?? 'Password must be at least 6 characters';
  String get pleaseConfirmYourNewPassword => _localizedValues[locale.languageCode]!['pleaseConfirmYourNewPassword'] ?? 'Please confirm your new password';
  String get newDeviceRegistrationsWillAppearHere => _localizedValues[locale.languageCode]!['newDeviceRegistrationsWillAppearHere'] ?? 'New device registrations will appear here';
  String get refreshDashboard => _localizedValues[locale.languageCode]!['refreshDashboard'] ?? 'Refresh Dashboard';
  String get changeLanguage => _localizedValues[locale.languageCode]!['changeLanguage'] ?? 'Change Language';
  String get currentSubscription => _localizedValues[locale.languageCode]!['currentSubscription'] ?? 'Current Subscription';
  String get currentAmount => _localizedValues[locale.languageCode]!['currentAmount'] ?? 'Current Amount';
  String get startDate => _localizedValues[locale.languageCode]!['startDate'] ?? 'Start Date';
  String get expiryDate => _localizedValues[locale.languageCode]!['expiryDate'] ?? 'Expiry Date';
  String get newSubscriptionDetails => _localizedValues[locale.languageCode]!['newSubscriptionDetails'] ?? 'New Subscription Details';
  String get newStartDate => _localizedValues[locale.languageCode]!['newStartDate'] ?? 'New Start Date';
  String get newExpiryDate => _localizedValues[locale.languageCode]!['newExpiryDate'] ?? 'New Expiry Date';
  String get selectStartDate => _localizedValues[locale.languageCode]!['selectStartDate'] ?? 'Select start date';
  String get selectExpiryDate => _localizedValues[locale.languageCode]!['selectExpiryDate'] ?? 'Select expiry date';
  String get enterAmountPaid => _localizedValues[locale.languageCode]!['enterAmountPaid'] ?? 'Enter amount paid';
  String get pleaseEnterSubscriptionAmount => _localizedValues[locale.languageCode]!['pleaseEnterSubscriptionAmount'] ?? 'Please enter subscription amount';
  String get pleaseEnterAValidAmount => _localizedValues[locale.languageCode]!['pleaseEnterAValidAmount'] ?? 'Please enter a valid amount';
  String get pleaseSelectAStartDate => _localizedValues[locale.languageCode]!['pleaseSelectAStartDate'] ?? 'Please select a start date';
  String get pleaseSelectAnExpiryDate => _localizedValues[locale.languageCode]!['pleaseSelectAnExpiryDate'] ?? 'Please select an expiry date';
  String get expiryDateMustBeAfterStartDate => _localizedValues[locale.languageCode]!['expiryDateMustBeAfterStartDate'] ?? 'Expiry date must be after start date';
  String get pleaseEnterAValidSubscriptionAmount => _localizedValues[locale.languageCode]!['pleaseEnterAValidSubscriptionAmount'] ?? 'Please enter a valid subscription amount';
  String get welcomeBack => _localizedValues[locale.languageCode]!['welcomeBack'] ?? 'Welcome back!';
  String get areYouSureYouWantToDeleteMember => _localizedValues[locale.languageCode]!['areYouSureYouWantToDeleteMember'] ?? 'Are you sure you want to delete {name}? This action cannot be undone.';
  String get deactivateMember => _localizedValues[locale.languageCode]!['deactivateMember'] ?? 'Deactivate Member';
  String get areYouSureYouWantToDeactivateActivateMember => _localizedValues[locale.languageCode]!['areYouSureYouWantToDeactivateActivateMember'] ?? 'Are you sure you want to {action} this member?';
  String get memberDeactivatedSuccessfully => _localizedValues[locale.languageCode]!['memberDeactivatedSuccessfully'] ?? 'Member deactivated successfully';
  String get failedToUpdateMember => _localizedValues[locale.languageCode]!['failedToUpdateMember'] ?? 'Failed to update member';
  String get updatingMember => _localizedValues[locale.languageCode]!['updatingMember'] ?? 'Updating member...';
  String get memberSubscriptionUpdatedSuccessfully => _localizedValues[locale.languageCode]!['memberSubscriptionUpdatedSuccessfully'] ?? 'Member subscription updated successfully';
  String get failedToUpdateMemberSubscription => _localizedValues[locale.languageCode]!['failedToUpdateMemberSubscription'] ?? 'Failed to update member subscription';
  String get errorUpdatingMember => _localizedValues[locale.languageCode]!['errorUpdatingMember'] ?? 'Error updating member: {error}';
  String get allMembers => _localizedValues[locale.languageCode]!['allMembers'] ?? 'All Members';
  String get activeOnly => _localizedValues[locale.languageCode]!['activeOnly'] ?? 'Active Only';
  String get pendingOnly => _localizedValues[locale.languageCode]!['pendingOnly'] ?? 'Pending Only';
  String get errorLoadingMembers => _localizedValues[locale.languageCode]!['errorLoadingMembers'] ?? 'Error loading members';
  String get noMembersFound => _localizedValues[locale.languageCode]!['noMembersFound'] ?? 'No members found';
  String get tryAdjustingYourFiltersOrCheckBackLater => _localizedValues[locale.languageCode]!['tryAdjustingYourFiltersOrCheckBackLater'] ?? 'Try adjusting your filters or check back later';
  String get createUser => _localizedValues[locale.languageCode]!['createUser'] ?? 'Create User';
  String get enterUserEmail => _localizedValues[locale.languageCode]!['enterUserEmail'] ?? 'Enter user email';
  String get pleaseEnterAnEmail => _localizedValues[locale.languageCode]!['pleaseEnterAnEmail'] ?? 'Please enter an email';
  String get pleaseEnterAValidEmail => _localizedValues[locale.languageCode]!['pleaseEnterAValidEmail'] ?? 'Please enter a valid email';
  String get displayName => _localizedValues[locale.languageCode]!['displayName'] ?? 'Display Name';
  String get enterUserDisplayName => _localizedValues[locale.languageCode]!['enterUserDisplayName'] ?? 'Enter user display name';
  String get pleaseEnterADisplayName => _localizedValues[locale.languageCode]!['pleaseEnterADisplayName'] ?? 'Please enter a display name';
  String get defaultPassword => _localizedValues[locale.languageCode]!['defaultPassword'] ?? 'Default Password';
  String get passwordWillBe => _localizedValues[locale.languageCode]!['passwordWillBe'] ?? 'Password will be: {password}';
  String get userCanChangePasswordAfterFirstLogin => _localizedValues[locale.languageCode]!['userCanChangePasswordAfterFirstLogin'] ?? 'User can change password after first login';
  String get failedToCreateUserEmailMayAlreadyExist => _localizedValues[locale.languageCode]!['failedToCreateUserEmailMayAlreadyExist'] ?? 'Failed to create user. Email may already exist.';
  String get errorCreatingUser => _localizedValues[locale.languageCode]!['errorCreatingUser'] ?? 'Error creating user: {error}';
  String get loading => _localizedValues[locale.languageCode]!['loading'] ?? 'Loading...';
  String get fetchingMemberInformation => _localizedValues[locale.languageCode]!['fetchingMemberInformation'] ?? 'Fetching member information';
  String get noPhoneNumber => _localizedValues[locale.languageCode]!['noPhoneNumber'] ?? 'No phone number';
  String get memberNotFound => _localizedValues[locale.languageCode]!['memberNotFound'] ?? 'Member Not Found';
  String get unableToLoadMemberInformation => _localizedValues[locale.languageCode]!['unableToLoadMemberInformation'] ?? 'Unable to load member information';
  String get errorLoadingHistory => _localizedValues[locale.languageCode]!['errorLoadingHistory'] ?? 'Error loading history';
  String get pleaseTryAgainLater => _localizedValues[locale.languageCode]!['pleaseTryAgainLater'] ?? 'Please try again later';
  String get errorLoadingMember => _localizedValues[locale.languageCode]!['errorLoadingMember'] ?? 'Error loading member data: {error}';
  String get createSampleData => _localizedValues[locale.languageCode]!['createSampleData'] ?? 'Create Sample Data';
  String get noHistoryFound => _localizedValues[locale.languageCode]!['noHistoryFound'] ?? 'No history found';
  String get noActionsRecordedForThisMemberYet => _localizedValues[locale.languageCode]!['noActionsRecordedForThisMemberYet'] ?? 'No actions recorded for this member yet';
  String get sampleHistoryRecordsCreatedSuccessfully => _localizedValues[locale.languageCode]!['sampleHistoryRecordsCreatedSuccessfully'] ?? 'Sample history records created successfully!';
  String get failedToCreateSampleData => _localizedValues[locale.languageCode]!['failedToCreateSampleData'] ?? 'Failed to create sample data';
  String get performedBy => _localizedValues[locale.languageCode]!['performedBy'] ?? 'Performed By';
  String get field => _localizedValues[locale.languageCode]!['field'] ?? 'Field';
  String get oldValue => _localizedValues[locale.languageCode]!['oldValue'] ?? 'Old Value';
  String get newValue => _localizedValues[locale.languageCode]!['newValue'] ?? 'New Value';
  String get reason => _localizedValues[locale.languageCode]!['reason'] ?? 'Reason';
  String get dateTime => _localizedValues[locale.languageCode]!['dateTime'] ?? 'Date/Time';
  String get statusChanged => _localizedValues[locale.languageCode]!['statusChanged'] ?? 'Status Changed';
  String get memberEdited => _localizedValues[locale.languageCode]!['memberEdited'] ?? 'Member Edited';
  String get subscriptionRenewed => _localizedValues[locale.languageCode]!['subscriptionRenewed'] ?? 'Subscription Renewed';
  String get subscriptionExpired => _localizedValues[locale.languageCode]!['subscriptionExpired'] ?? 'Subscription Expired';
  String get deviceAdded => _localizedValues[locale.languageCode]!['deviceAdded'] ?? 'Device Added';
  String get deviceRemoved => _localizedValues[locale.languageCode]!['deviceRemoved'] ?? 'Device Removed';
  String get memberDeleted => _localizedValues[locale.languageCode]!['memberDeleted'] ?? 'Member Deleted';
  String get unknownAction => _localizedValues[locale.languageCode]!['unknownAction'] ?? 'Unknown Action';
  String get gymTodayMessage => _localizedValues[locale.languageCode]!['gymTodayMessage'] ?? 'Here\'s what\'s happening at your gym today';
  String get expired => _localizedValues[locale.languageCode]!['expired'] ?? 'Expired';
  String get todaysCheckins => _localizedValues[locale.languageCode]!['todaysCheckins'] ?? 'Today\'s Check-ins';
  String get activeMembers => _localizedValues[locale.languageCode]!['activeMembers'] ?? 'Active Members';
  String get inactiveMembers => _localizedValues[locale.languageCode]!['inactiveMembers'] ?? 'Inactive Members';
  String get expiredMembers => _localizedValues[locale.languageCode]!['expiredMembers'] ?? 'Expired Members';
  String get quickActions => _localizedValues[locale.languageCode]!['quickActions'] ?? 'Quick Actions';
  String get checkins => _localizedValues[locale.languageCode]!['checkins'] ?? 'Check-ins';
  String get expiredCheckins => _localizedValues[locale.languageCode]!['expiredCheckins'] ?? 'Expired Check-ins';
  String get userManagement => _localizedValues[locale.languageCode]!['userManagement'] ?? 'User Management';
  String get memberHistory => _localizedValues[locale.languageCode]!['memberHistory'] ?? 'Member History';
  String get userProfile => _localizedValues[locale.languageCode]!['userProfile'] ?? 'User Profile';
  String get only => _localizedValues[locale.languageCode]!['only'] ?? 'only';
  String get searchByNameOrPhone => _localizedValues[locale.languageCode]!['searchByNameOrPhone'] ?? 'Search by name or phone';
  String get selectedDate => _localizedValues[locale.languageCode]!['selectedDate'] ?? 'Selected Date';
  String get selectDateRange => _localizedValues[locale.languageCode]!['selectDateRange'] ?? 'Select Date Range';
  String get allAttempts => _localizedValues[locale.languageCode]!['allAttempts'] ?? 'All attempts';
  String get todayOnly => _localizedValues[locale.languageCode]!['todayOnly'] ?? 'Today only';
  String get thisWeek => _localizedValues[locale.languageCode]!['thisWeek'] ?? 'This week';
  String get customDateRange => _localizedValues[locale.languageCode]!['customDateRange'] ?? 'Custom Date Range';
  String get deleteUser => _localizedValues[locale.languageCode]!['deleteUser'] ?? 'Delete user';
  String get admin => _localizedValues[locale.languageCode]!['admin'] ?? 'Admin';
  String get regularUser => _localizedValues[locale.languageCode]!['regularUser'] ?? 'Regular user';
  String get searchMember => _localizedValues[locale.languageCode]!['searchMember'] ?? 'Search Member';
  String get searchMemberButton => _localizedValues[locale.languageCode]!['searchMemberButton'] ?? 'Search Member';
  String get accountSettings => _localizedValues[locale.languageCode]!['accountSettings'] ?? 'Account Settings';
  String get changeEmail => _localizedValues[locale.languageCode]!['changeEmail'] ?? 'Change Email';
  String get changePassword => _localizedValues[locale.languageCode]!['changePassword'] ?? 'Change Password';
  String get currentPassword => _localizedValues[locale.languageCode]!['currentPassword'] ?? 'Current Password';
  String get newPassword => _localizedValues[locale.languageCode]!['newPassword'] ?? 'New Password';
  String get confirmPassword => _localizedValues[locale.languageCode]!['confirmPassword'] ?? 'Confirm Password';
  String get emailUpdated => _localizedValues[locale.languageCode]!['emailUpdated'] ?? 'Email updated successfully';
  String get passwordUpdate => _localizedValues[locale.languageCode]!['passwordUpdate'] ?? 'Update Password';
  String get emailUpdate => _localizedValues[locale.languageCode]!['emailUpdate'] ?? 'Update Email';
  String get passwordUpdated => _localizedValues[locale.languageCode]!['passwordUpdated'] ?? 'Password updated successfully';
  String get noPendingDevicesFound => _localizedValues[locale.languageCode]!['noPendingDevicesFound'] ?? 'No pending devices found';
  String get searchResults => _localizedValues[locale.languageCode]!['searchResults'] ?? 'Search Results';
  String get pleaseEnterNameOrPhone => _localizedValues[locale.languageCode]!['pleaseEnterNameOrPhone'] ?? 'Please enter a name or phone number';
  String get pleaseEnterAtLeast2Chars => _localizedValues[locale.languageCode]!['pleaseEnterAtLeast2Chars'] ?? 'Please enter at least 2 characters';
  String get noMemberFound => _localizedValues[locale.languageCode]!['noMemberFound'] ?? 'No member found with name or phone';
  String get errorSearchingMember => _localizedValues[locale.languageCode]!['errorSearchingMember'] ?? 'Error searching for member';
  String get invalidMemberId => _localizedValues[locale.languageCode]!['invalidMemberId'] ?? 'Invalid member ID. Cannot view history.';
  String get allActions => _localizedValues[locale.languageCode]!['allActions'] ?? 'All Actions';
  String get manageGymMembers => _localizedValues[locale.languageCode]!['manageGymMembers'] ?? 'Manage gym members';
  String get viewCheckinHistory => _localizedValues[locale.languageCode]!['viewCheckinHistory'] ?? 'View check-in history';
  String get viewExpiredCheckins => _localizedValues[locale.languageCode]!['viewExpiredCheckins'] ?? 'View expired check-in attempts';
  String get manageAdminUsers => _localizedValues[locale.languageCode]!['manageAdminUsers'] ?? 'Manage admin users';
  String get viewMemberActivity => _localizedValues[locale.languageCode]!['viewMemberActivity'] ?? 'View member activity history';
  String get manageAccountSettings => _localizedValues[locale.languageCode]!['manageAccountSettings'] ?? 'Manage your account settings';
  String get viewPendingDevices => _localizedValues[locale.languageCode]!['viewPendingDevices'] ?? 'View pending device registrations';
  String get signInToManageGym => _localizedValues[locale.languageCode]!['signInToManageGym'] ?? 'Sign in to manage your gym';
  String get enterYourEmail => _localizedValues[locale.languageCode]!['enterYourEmail'] ?? 'Enter your email';
  String get enterYourPassword => _localizedValues[locale.languageCode]!['enterYourPassword'] ?? 'Enter your password';
  String get pleaseEnterYourEmail => _localizedValues[locale.languageCode]!['pleaseEnterYourEmail'] ?? 'Please enter your email';
  String get pleaseEnterYourPassword => _localizedValues[locale.languageCode]!['pleaseEnterYourPassword'] ?? 'Please enter your password';
  String get invalidEmailOrPassword => _localizedValues[locale.languageCode]!['invalidEmailOrPassword'] ?? 'Invalid email or password';
  String get loginFailed => _localizedValues[locale.languageCode]!['loginFailed'] ?? 'Login failed';

  // Member history screen strings
  String get fetchingMemberInfo => _localizedValues[locale.languageCode]!['fetchingMemberInfo'] ?? 'Fetching member information';
  String get unableToLoadMemberInfo => _localizedValues[locale.languageCode]!['unableToLoadMemberInfo'] ?? 'Unable to load member information';
  String get pleaseTryAgain => _localizedValues[locale.languageCode]!['pleaseTryAgain'] ?? 'Please try again later';
  String get noActionsRecorded => _localizedValues[locale.languageCode]!['noActionsRecorded'] ?? 'No actions recorded for this member yet';
  String get sampleHistoryCreated => _localizedValues[locale.languageCode]!['sampleHistoryCreated'] ?? 'Sample history records created successfully!';
  String get failedToCreateSample => _localizedValues[locale.languageCode]!['failedToCreateSample'] ?? 'Failed to create sample data';
  String get error => _localizedValues[locale.languageCode]!['error'] ?? 'Error';
  String get noExpiryCheckIn => _localizedValues[locale.languageCode]!['noExpiryCheckIn'] ?? 'No expired check-ins found';
  String get allValidCheckIn => _localizedValues[locale.languageCode]!['allValidCheckIn'] ?? 'All check-ins are within valid subscription periods';

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appTitle': 'Ashhab Gym',
      'dashboard': 'Dashboard',
      'members': 'Members',
      'pendingDevices': 'Pending Devices',
      'settings': 'Settings',
      'checkins': 'Check-ins',
      'expiredCheckins': 'Expired Check-ins',
      'userManagement': 'User Management',
      'memberHistory': 'Member History',
      'userProfile': 'User Profile',
      'only': 'only',
      'searchResults': 'Search Results',
      'pleaseEnterNameOrPhone': 'Please enter a name or phone number',
      'pleaseEnterAtLeast2Chars': 'Please enter at least 2 characters',
      'noMemberFound': 'No member found with name or phone',
      'errorSearchingMember': 'Error searching for member',
      'invalidMemberId': 'Invalid member ID. Cannot view history.',
      'performedBy': 'Performed By',
      'email': 'Email',
      'field': 'Field',
      'oldValue': 'Old Value',
      'newValue': 'New Value',
      'reason': 'Reason',
      'dateTime': 'Date/Time',
      'statusChanged': 'Status Changed',
      'memberEdited': 'Member Edited',
      'subscriptionRenewed': 'Subscription Renewed',
      'subscriptionExpired': 'Subscription Expired',
      'deviceAdded': 'Device Added',
      'deviceRemoved': 'Device Removed',
      'memberDeleted': 'Member Deleted',
      'unknownAction': 'Unknown Action',
      'allActions': 'All Actions',
      'manageGymMembers': 'Manage gym members',
      'viewCheckinHistory': 'View check-in history',
      'viewExpiredCheckins': 'View expired check-in attempts',
      'manageAdminUsers': 'Manage admin users',
      'viewMemberActivity': 'View member activity history',
      'manageAccountSettings': 'Manage your account settings',
      'viewPendingDevices': 'View pending device registrations',
      'loading': 'Loading...',
      'fetchingMemberInfo': 'Fetching member information',
      'memberNotFound': 'Member Not Found',
      'unableToLoadMemberInfo': 'Unable to load member information',
      'errorLoadingHistory': 'Error loading history',
      'pleaseTryAgain': 'Please try again later',
      'createSampleData': 'Create Sample Data',
      'noHistoryFound': 'No history found',
      'noActionsRecorded': 'No actions recorded for this member yet',
      'sampleHistoryCreated': 'Sample history records created successfully!',
      'failedToCreateSample': 'Failed to create sample data',
      'error': 'Error',
      'searchByNameOrPhone': 'Search by name or phone',
      'selectedDate': 'Selected Date',
      'selectDateRange': 'Select Date Range',
      'allAttempts': 'All attempts',
      'todayOnly': 'Today only',
      'thisWeek': 'This week',
      'customDateRange': 'Custom Date Range',
      'deleteUser': 'Delete user',
      'deactivate': 'Deactivate',
      'viewDetails': 'View details',
      'admin': 'Admin',
      'regularUser': 'Regular user',
      'searchMember': 'Search Member',
      'searchMemberButton': 'Search Member',
      'accountSettings': 'Account Settings',
      'changeEmail': 'Change Email',
      'changePassword': 'Change Password',
      'currentPassword': 'Current Password',
      'newPassword': 'New Password',
      'confirmPassword': 'Confirm Password',
      'emailUpdated': 'Email updated successfully',
      'emailUpdate': 'Update Email',
      'passwordUpdated': 'Password updated successfully',
      'passwordUpdate': 'Update Password',
      'noPendingDevicesFound': 'No pending devices found',
      'logout': 'Logout',
      'login': 'Login',
      'password': 'Password',
      'loginButton': 'Login',
      'welcomeMessage': 'Welcome to Ashhab Gym Admin',
      'memberDetails': 'Member Details',
      'deviceId': 'Device ID',
      'phoneNumber': 'Phone Number',
      'memberName': 'Member Name',
      'membershipStatus': 'Membership Status',
      'subscriptionStartDate': 'Subscription Start Date',
      'subscriptionExpiryDate': 'Subscription Expiry Date',
      'subscriptionAmount': 'Subscription Amount',
      'active': 'Active',
      'pending': 'Pending',
      'inactive': 'Inactive',
      'cancel': 'Cancel',
      'edit': 'Edit',
      'delete': 'Delete',
      'activate': 'Activate',
      'renewSubscription': 'Renew Subscription',
      'activateMember': 'Activate Member',
      'memberActivatedSuccessfully': 'Member activated successfully!',
      'failedToActivateMember': 'Failed to activate member',
      'subscriptionRenewedSuccessfully': 'Subscription renewed successfully!',
      'failedToRenewSubscription': 'Failed to renew subscription',
      'ok': 'OK',
      'confirm': 'Confirm',
      'deleteMember': 'Delete Member',
      'deleteMemberConfirmation': 'Are you sure you want to delete {name}? This action cannot be undone.',
      'memberDeletedSuccessfully': 'Member deleted successfully',
      'failedToDeleteMember': 'Failed to delete member',
      'activateMemberConfirmation': 'Are you sure you want to {action} this member?',
      'language': 'Language',
      'selectLanguage': 'Select Language',
      'english': 'English',
      'arabic': 'العربية',
      'noPendingDeletionRequests': 'No pending member deletion requests',
      'approveMemberDeletion': 'Approve Member Deletion',
      'member': 'Member',
      'name': 'Name',
      'thisActionCannotBeUndone': 'This action cannot be undone.',
      'approveDeletion': 'Approve Deletion',
      'rejectMemberDeletion': 'Reject Member Deletion',
      'pleaseProvideRejectionReason': 'Please provide a reason for rejection:',
      'rejectionReason': 'Rejection Reason',
      'rejectRequest': 'Reject Request',
      'requestRejected': 'Request rejected',
      'failedToRejectRequest': 'Failed to reject request',
      'unknownMember': 'Unknown Member',
      'requestedBy': 'Requested by',
      'reject': 'Reject',
      'deleteUserConfirmation': 'Are you sure you want to delete {name} ({email})? This action cannot be undone and the user will not be able to login again.',
      'deleteUserTitle': 'Delete User',
      'userDeletedSuccessfully': 'User deleted successfully',
      'failedToDeleteUser': 'Failed to delete user',
      'userStatusUpdated': 'User status updated',
      'failedToUpdateStatus': 'Failed to update status',
      'requestUserDeletion': 'Request User Deletion',
      'user': 'User',
      'thisRequestWillRequireAdminApproval': 'This request will require admin approval.',
      'reasonOptional': 'Reason (optional)',
      'requestDeletion': 'Request Deletion',
      'deletionRequestSubmitted': 'Deletion request submitted',
      'failedToSubmitRequest': 'Failed to submit request',
      'userDetails': 'User Details',
      'close': 'Close',
      'role': 'Role',
      'status': 'Status',
      'createdAt': 'Created At',
      'lastLogin': 'Last Login',
      'createdBy': 'Created By',
      'enterMemberNameOrPhoneToFindHistory': 'Enter member name or phone number to find member history',
      'gymAdministrator': 'Gym Administrator',
      'emailAddress': 'Email Address',
      'currentEmail': 'Current Email: {email}',
      'changeYourPasswordToKeepAccountSecure': 'Change your password to keep your account secure',
      'newEmail': 'New Email',
      'enterNewEmailAddress': 'Enter new email address',
      'pleaseEnterAnEmailAddress': 'Please enter an email address',
      'pleaseEnterAValidEmailAddress': 'Please enter a valid email address',
      'newPasswordsDoNotMatch': 'New passwords do not match',
      'errorUpdatingEmail': 'Error updating email: {error}',
      'errorUpdatingPassword': 'Error updating password: {error}',
      'pleaseEnterYourCurrentPassword': 'Please enter your current password',
      'pleaseEnterANewPassword': 'Please enter a new password',
      'passwordMustBeAtLeast6Characters': 'Password must be at least 6 characters',
      'pleaseConfirmYourNewPassword': 'Please confirm your new password',
      'newDeviceRegistrationsWillAppearHere': 'New device registrations will appear here',
      'refreshDashboard': 'Refresh Dashboard',
      'changeLanguage': 'Change Language',
      'currentSubscription': 'Current Subscription',
      'currentAmount': 'Current Amount',
      'startDate': 'Start Date',
      'expiryDate': 'Expiry Date',
      'newSubscriptionDetails': 'New Subscription Details',
      'newStartDate': 'New Start Date',
      'newExpiryDate': 'New Expiry Date',
      'selectStartDate': 'Select start date',
      'selectExpiryDate': 'Select expiry date',
      'enterAmountPaid': 'Enter amount paid',
      'pleaseEnterSubscriptionAmount': 'Please enter subscription amount',
      'pleaseEnterAValidAmount': 'Please enter a valid amount',
      'pleaseSelectAStartDate': 'Please select a start date',
      'pleaseSelectAnExpiryDate': 'Please select an expiry date',
      'expiryDateMustBeAfterStartDate': 'Expiry date must be after start date',
      'pleaseEnterAValidSubscriptionAmount': 'Please enter a valid subscription amount',
      'welcomeBack': 'Welcome back!',
      'areYouSureYouWantToDeleteMember': 'Are you sure you want to delete {name}? This action cannot be undone.',
      'deactivateMember': 'Deactivate Member',
      'areYouSureYouWantToDeactivateActivateMember': 'Are you sure you want to {action} this member?',
      'memberDeactivatedSuccessfully': 'Member deactivated successfully',
      'failedToUpdateMember': 'Failed to update member',
      'updatingMember': 'Updating member...',
      'memberSubscriptionUpdatedSuccessfully': 'Member subscription updated successfully',
      'failedToUpdateMemberSubscription': 'Failed to update member subscription',
      'errorUpdatingMember': 'Error updating member: {error}',
      'allMembers': 'All Members',
      'activeOnly': 'Active Only',
      'pendingOnly': 'Pending Only',
      'errorLoadingMembers': 'Error loading members',
      'noMembersFound': 'No members found',
      'tryAdjustingYourFiltersOrCheckBackLater': 'Try adjusting your filters or check back later',
      'createUser': 'Create User',
      'enterUserEmail': 'Enter user email',
      'pleaseEnterAnEmail': 'Please enter an email',
      'pleaseEnterAValidEmail': 'Please enter a valid email',
      'displayName': 'Display Name',
      'enterUserDisplayName': 'Enter user display name',
      'pleaseEnterADisplayName': 'Please enter a display name',
      'defaultPassword': 'Default Password',
      'passwordWillBe': 'Password will be: {password}',
      'userCanChangePasswordAfterFirstLogin': 'User can change password after first login',
      'failedToCreateUserEmailMayAlreadyExist': 'Failed to create user. Email may already exist.',
      'errorCreatingUser': 'Error creating user: {error}',
      'errorLoadingMember': 'Error loading member data: {error}',
      'fetchingMemberInformation': 'Fetching member information',
      'noPhoneNumber': 'No phone number',
      'unableToLoadMemberInformation': 'Unable to load member information',
      'pleaseTryAgainLater': 'Please try again later',
      'noActionsRecordedForThisMemberYet': 'No actions recorded for this member yet',
      'sampleHistoryRecordsCreatedSuccessfully': 'Sample history records created successfully!',
      'failedToCreateSampleData': 'Failed to create sample data',
      'gymTodayMessage': 'Here\'s what\'s happening at your gym today',
      'expired': 'Expired',
      'todaysCheckins': 'Today\'s Check-ins',
      'activeMembers': 'Active Members',
      'inactiveMembers': 'Inactive Members',
      'expiredMembers': 'Expired Members',
      'quickActions': 'Quick Actions',
      'signInToManageGym': 'Sign in to manage your gym',
      'enterYourEmail': 'Enter your email',
      'noExpiryCheckIn': 'No expired check-ins found',
      'allValidCheckIn': 'All check-ins are within valid subscription periods',
      'enterYourPassword': 'Enter your password',
      'pleaseEnterYourEmail': 'Please enter your email',
      'pleaseEnterYourPassword': 'Please enter your password',
      'invalidEmailOrPassword': 'Invalid email or password',
      'loginFailed': 'Login failed'
    },
    'ar': {
      'appTitle': 'نظام إدارة صالة الأشهب',
      'dashboard': 'لوحة التحكم',
      'members': 'الأعضاء',
      'pendingDevices': 'الأجهزة المعلقة',
      'settings': 'الإعدادات',
      'logout': 'تسجيل الخروج',
      'login': 'تسجيل الدخول',
      'checkins': 'سجل الحضور',
      'expiredCheckins': 'حضور منتهي الاشتراك',
      'userManagement': 'إدارة المستخدمين',
      'memberHistory': 'سجل الأعضاء',
      'userProfile': 'ملف المستخدم',
      'only': 'فقط',
      'searchResults': 'نتائج البحث',
      'pleaseEnterNameOrPhone': 'الرجاء إدخال اسم أو رقم هاتف',
      'pleaseEnterAtLeast2Chars': 'الرجاء إدخال حرفين على الأقل',
      'noMemberFound': 'لم يتم العثور على عضو بالاسم أو رقم الهاتف',
      'errorSearchingMember': 'خطأ في البحث عن العضو',
      'invalidMemberId': 'معرف العضو غير صالح. لا يمكن عرض السجل.',
      'performedBy': 'تم بواسطة',
      'email': 'البريد الإلكتروني',
      'field': 'حقل',
      'oldValue': 'القيمة القديمة',
      'newValue': 'القيمة الجديدة',
      'reason': 'السبب',
      'dateTime': 'التاريخ/الوقت',
      'statusChanged': 'تم تغيير الحالة',
      'memberEdited': 'تم تعديل العضو',
      'subscriptionRenewed': 'تم تجديد الاشتراك',
      'subscriptionExpired': 'انتهى الاشتراك',
      'deviceAdded': 'تم إضافة الجهاز',
      'deviceRemoved': 'تم إزالة الجهاز',
      'memberDeleted': 'تم حذف العضو',
      'unknownAction': 'إجراء غير معروف',
      'allActions': 'جميع الإجراءات',
      'manageGymMembers': 'إدارة أعضاء الصالة الرياضية',
      'viewCheckinHistory': 'عرض سجل الحضور',
      'viewExpiredCheckins': 'عرض محاولات الحضور المنتهية',
      'manageAdminUsers': 'إدارة المستخدمين المشرفين',
      'viewMemberActivity': 'عرض سجل نشاط العضو',
      'manageAccountSettings': 'إدارة إعدادات حسابك',
      'viewPendingDevices': 'عرض تسجيلات الأجهزة المعلقة',
      'loading': 'جاري التحميل...',
      'fetchingMemberInfo': 'جاري جلب معلومات العضو',
      'memberNotFound': 'العضو غير موجود',
      'unableToLoadMemberInfo': 'غير قادر على تحميل معلومات العضو',
      'errorLoadingHistory': 'خطأ في تحميل السجل',
      'pleaseTryAgain': 'الرجاء المحاولة مرة أخرى لاحقاً',
      'createSampleData': 'إنشاء بيانات عينة',
      'noHistoryFound': 'لم يتم العثور على سجل',
      'noActionsRecorded': 'لم يتم تسجيل أي إجراءات لهذا العضو بعد',
      'sampleHistoryCreated': 'تم إنشاء سجلات تاريخ العينة بنجاح!',
      'failedToCreateSample': 'فشل في إنشاء بيانات العينة',
      'error': 'خطأ',
      'searchByNameOrPhone': 'البحث بالاسم أو رقم الهاتف',
      'selectedDate': 'التاريخ المحدد',
      'selectDateRange': 'اختر نطاق التاريخ',
      'allAttempts': 'جميع المحاولات',
      'todayOnly': 'اليوم فقط',
      'thisWeek': 'هذا الأسبوع',
      'customDateRange': 'نطاق تاريخ مخصص',
      'deleteUser': 'حذف المستخدم',
      'viewDetails': 'عرض التفاصيل',
      'admin': 'مدير',
      'regularUser': 'مستخدم عادي',
      'searchMember': 'بحث عن عضو',
      'searchMemberButton': 'بحث عن عضو',
      'accountSettings': 'إعدادات الحساب',
      'changeEmail': 'تغيير البريد الإلكتروني',
      'changePassword': 'تغيير كلمة المرور',
      'currentPassword': 'كلمة المرور الحالية',
      'newPassword': 'كلمة المرور الجديدة',
      'confirmPassword': 'تأكيد كلمة المرور',
      'emailUpdated': 'تم تحديث البريد الإلكتروني بنجاح',
      'emailUpdate': 'تحديث البريد الالكتروني',
      'passwordUpdated': 'تم تحديث كلمة المرور بنجاح',
      'passwordUpdate': 'تحديث كلمة المرور',
      'cancel': 'إلغاء',
      'noPendingDevicesFound': 'لم يتم العثور على أجهزة معلقة',
      'password': 'كلمة المرور',
      'loginButton': 'دخول',
      'welcomeMessage': 'مرحباً بك في نظام إدارة صالة الأشهب',
      'memberDetails': 'تفاصيل العضو',
      'deviceId': 'معرف الجهاز',
      'phoneNumber': 'رقم الهاتف',
      'memberName': 'اسم العضو',
      'membershipStatus': 'حالة العضوية',
      'subscriptionStartDate': 'تاريخ بداية الاشتراك',
      'subscriptionExpiryDate': 'تاريخ انتهاء الاشتراك',
      'subscriptionAmount': 'مبلغ الاشتراك',
      'active': 'نشط',
      'pending': 'معلق',
      'inactive': 'غير نشط',
      'edit': 'تعديل',
      'delete': 'حذف',
      'activate': 'تفعيل',
      'deactivate': 'إلغاء التفعيل',
      'renewSubscription': 'تجديد الاشتراك',
      'activateMember': 'تفعيل العضو',
      'memberActivatedSuccessfully': 'تم تفعيل العضو بنجاح!',
      'failedToActivateMember': 'فشل في تفعيل العضو',
      'subscriptionRenewedSuccessfully': 'تم تجديد الاشتراك بنجاح!',
      'failedToRenewSubscription': 'فشل في تجديد الاشتراك',
      'ok': 'موافق',
      'confirm': 'تأكيد',
      'deleteMember': 'حذف العضو',
      'deleteMemberConfirmation': 'هل أنت متأكد من حذف {name}؟ هذا الإجراء لا يمكن التراجع عنه.',
      'memberDeletedSuccessfully': 'تم حذف العضو بنجاح',
      'failedToDeleteMember': 'فشل في حذف العضو',
      'activateMemberConfirmation': 'هل أنت متأكد من {action} هذا العضو؟',
      'language': 'اللغة',
      'selectLanguage': 'اختر اللغة',
      'english': 'English',
      'arabic': 'العربية',
      'noPendingDeletionRequests': 'لا توجد طلبات حذف أعضاء معلقة',
      'approveMemberDeletion': 'موافقة على حذف العضو',
      'member': 'العضو',
      'name': 'الاسم',
      'thisActionCannotBeUndone': 'هذا الإجراء لا يمكن التراجع عنه.',
      'approveDeletion': 'موافقة على الحذف',
      'rejectMemberDeletion': 'رفض حذف العضو',
      'pleaseProvideRejectionReason': 'يرجى تقديم سبب للرفض:',
      'rejectionReason': 'سبب الرفض',
      'rejectRequest': 'رفض الطلب',
      'requestRejected': 'تم رفض الطلب',
      'failedToRejectRequest': 'فشل في رفض الطلب',
      'unknownMember': 'عضو غير معروف',
      'requestedBy': 'مقدم الطلب',
      'reject': 'رفض',
      'deleteUserConfirmation': 'هل أنت متأكد من حذف {name} ({email})؟ هذا الإجراء لا يمكن التراجع عنه والمستخدم لن يتمكن من تسجيل الدخول مرة أخرى.',
      'deleteUserTitle': 'حذف المستخدم',
      'userDeletedSuccessfully': 'تم حذف المستخدم بنجاح',
      'failedToDeleteUser': 'فشل في حذف المستخدم',
      'userStatusUpdated': 'تم تحديث حالة المستخدم',
      'failedToUpdateStatus': 'فشل في تحديث الحالة',
      'requestUserDeletion': 'طلب حذف المستخدم',
      'user': 'المستخدم',
      'thisRequestWillRequireAdminApproval': 'هذا الطلب سيتطلب موافقة المشرف.',
      'reasonOptional': 'السبب (اختياري)',
      'requestDeletion': 'طلب الحذف',
      'deletionRequestSubmitted': 'تم تقديم طلب الحذف',
      'failedToSubmitRequest': 'فشل في تقديم الطلب',
      'userDetails': 'تفاصيل المستخدم',
      'close': 'إغلاق',
      'role': 'الدور',
      'status': 'الحالة',
      'createdAt': 'تاريخ الإنشاء',
      'lastLogin': 'آخر تسجيل دخول',
      'createdBy': 'تم الإنشاء بواسطة',
      'enterMemberNameOrPhoneToFindHistory': 'أدخل اسم العضو أو رقم الهاتف للعثور على سجل العضو',
      'gymAdministrator': 'مدير الصالة الرياضية',
      'emailAddress': 'عنوان البريد الإلكتروني',
      'currentEmail': 'البريد الإلكتروني الحالي: {email}',
      'changeYourPasswordToKeepAccountSecure': 'قم بتغيير كلمة المرور للحفاظة على أمان حسابك',
      'newEmail': 'بريد إلكتروني جديد',
      'enterNewEmailAddress': 'أدخل عنوان البريد الإلكتروني الجديد',
      'pleaseEnterAnEmailAddress': 'الرجاء إدخال عنوان بريد إلكتروني',
      'pleaseEnterAValidEmailAddress': 'الرجاء إدخال عنوان بريد إلكتروني صحيح',
      'newPasswordsDoNotMatch': 'كلمات المرور الجديدة غير متطابقة',
      'errorUpdatingEmail': 'خطأ في تحديث البريد الإلكتروني: {error}',
      'errorUpdatingPassword': 'خطأ في تحديث كلمة المرور: {error}',
      'pleaseEnterYourCurrentPassword': 'الرجاء إدخال كلمة المرور الحالية',
      'pleaseEnterANewPassword': 'الرجاء إدخال كلمة مرور جديدة',
      'passwordMustBeAtLeast6Characters': 'يجب أن تكون كلمة المرور 6 أحرف على الأقل',
      'pleaseConfirmYourNewPassword': 'الرجاء تأكيد كلمة المرور الجديدة',
      'newDeviceRegistrationsWillAppearHere': 'ستظهر تسجيلات الأجهزة الجديدة هنا',
      'refreshDashboard': 'تحديث لوحة التحكم',
      'changeLanguage': 'تغيير اللغة',
      'currentSubscription': 'الاشتراك الحالي',
      'currentAmount': 'المبلغ الحالي',
      'startDate': 'تاريخ البدء',
      'expiryDate': 'تاريخ الانتهاء',
      'newSubscriptionDetails': 'تفاصيل الاشتراك الجديد',
      'newStartDate': 'تاريخ البدء الجديد',
      'newExpiryDate': 'تاريخ الانتهاء الجديد',
      'selectStartDate': 'اختر تاريخ البدء',
      'selectExpiryDate': 'اختر تاريخ الانتهاء',
      'enterAmountPaid': 'أدخل المبلغ المدفوع',
      'pleaseEnterSubscriptionAmount': 'الرجاء إدخال مبلغ الاشتراك',
      'pleaseEnterAValidAmount': 'الرجاء إدخال مبلغ صحيح',
      'pleaseSelectAStartDate': 'الرجاء اختيار تاريخ البدء',
      'pleaseSelectAnExpiryDate': 'الرجاء اختيار تاريخ الانتهاء',
      'expiryDateMustBeAfterStartDate': 'يجب أن يكون تاريخ الانتهاء بعد تاريخ البدء',
      'pleaseEnterAValidSubscriptionAmount': 'الرجاء إدخال مبلغ اشتراك صحيح',
      'welcomeBack': 'مرحباً بعودتك!',
      'areYouSureYouWantToDeleteMember': 'هل أنت متأكد من حذف {name}؟ هذا الإجراء لا يمكن التراجع عنه.',
      'deactivateMember': 'إلغاء تنشيط العضو',
      'areYouSureYouWantToDeactivateActivateMember': 'هل أنت متأكد من {action} هذا العضو؟',
      'memberDeactivatedSuccessfully': 'تم إلغاء تنشيط العضو بنجاح',
      'failedToUpdateMember': 'فشل في تحديث العضو',
      'updatingMember': 'جاري تحديث العضو...',
      'memberSubscriptionUpdatedSuccessfully': 'تم تحديث اشتراك العضو بنجاح',
      'failedToUpdateMemberSubscription': 'فشل في تحديث اشتراك العضو',
      'errorUpdatingMember': 'خطأ في تحديث العضو: {error}',
      'allMembers': 'جميع الأعضاء',
      'activeOnly': 'النشطون فقط',
      'pendingOnly': 'المعلقون فقط',
      'errorLoadingMembers': 'خطأ في تحميل الأعضاء',
      'noMembersFound': 'لم يتم العثور على أعضاء',
      'tryAdjustingYourFiltersOrCheckBackLater': 'حاول تعديل عوامل التصفية أو تحقق لاحقًا',
      'createUser': 'إنشاء مستخدم',
      'enterUserEmail': 'أدخل بريد المستخدم الإلكتروني',
      'pleaseEnterAnEmail': 'الرجاء إدخال بريد إلكتروني',
      'pleaseEnterAValidEmail': 'الرجاء إدخال بريد إلكتروني صحيح',
      'displayName': 'اسم العرض',
      'enterUserDisplayName': 'أدخل اسم عرض المستخدم',
      'pleaseEnterADisplayName': 'الرجاء إدخال اسم عرض',
      'defaultPassword': 'كلمة المرور الافتراضية',
      'passwordWillBe': 'كلمة المرور ستكون: {password}',
      'userCanChangePasswordAfterFirstLogin': 'يمكن للمستخدم تغيير كلمة المرور بعد أول تسجيل دخول',
      'failedToCreateUserEmailMayAlreadyExist': 'فشل في إنشاء المستخدم. قد يكون البريد الإلكتروني موجودًا بالفعل.',
      'errorCreatingUser': 'خطأ في إنشاء المستخدم: {error}',
      'errorLoadingMember': 'خطأ في تحميل بيانات العضو: {error}',
      'fetchingMemberInformation': 'جاري جلب معلومات العضو',
      'noPhoneNumber': 'لا يوجد رقم هاتف',
      'unableToLoadMemberInformation': 'غير قادر على تحميل معلومات العضو',
      'pleaseTryAgainLater': 'الرجاء المحاولة مرة أخرى لاحقًا',
      'noActionsRecordedForThisMemberYet': 'لم يتم تسجيل أي إجراءات لهذا العضو بعد',
      'sampleHistoryRecordsCreatedSuccessfully': 'تم إنشاء سجلات السجل النموذجية بنجاح!',
      'failedToCreateSampleData': 'فشل في إنشاء بيانات النموذج',
      'gymTodayMessage': 'إليك ما يحدث في صالتك اليوم',
      'expired': 'منتهي',
      'todaysCheckins': 'حضور اليوم',
      'activeMembers': 'الأعضاء النشطون',
      'inactiveMembers': 'الأعضاء غير النشطون',
      'expiredMembers': 'الأعضاء منتهي الاشتراك',
      'quickActions': 'الإجراءات السريعة',
      'signInToManageGym': 'سجل الدخول لإدارة صالتك الرياضية',
      'enterYourEmail': 'أدخل بريدك الإلكتروني',
      'enterYourPassword': 'أدخل كلمة المرور',
      'noExpiryCheckIn': 'لا يوجد حضور منتهي الاشتراك',
      'allValidCheckIn': 'جميع الحضور بصلاحية فعالة',
      'pleaseEnterYourEmail': 'الرجاء إدخال بريدك الإلكتروني',
      'pleaseEnterYourPassword': 'الرجاء إدخال كلمة المرور',
      'invalidEmailOrPassword': 'البريد الإلكتروني أو كلمة المرور غير صحيحة',
      'loginFailed': 'فشل تسجيل الدخول'
    }
  };
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) {
    return false;
  }
}