#import "UndoIt.h"

@implementation UndoIt

- (IBAction)myUndoIt:(id)sender
{
    AuthorizationRef authRef;
    OSStatus status;
    AuthorizationFlags flags;
    
    flags = kAuthorizationFlagDefaults;
    status = AuthorizationCreate(NULL, kAuthorizationEmptyEnvironment,
                                 flags, &authRef);
    
    if (status != errAuthorizationSuccess) {
        return;
    }
    
    AuthorizationItem authItems = {kAuthorizationRightExecute, 0, NULL, 0};
    AuthorizationRights rights = {1, &authItems};
    flags = kAuthorizationFlagDefaults |
    kAuthorizationFlagInteractionAllowed | kAuthorizationFlagPreAuthorize |
    kAuthorizationFlagExtendRights;
    
    status = AuthorizationCopyRights (authRef, &rights, NULL, flags, NULL);
    if (status != errAuthorizationSuccess) {
        AuthorizationFree(authRef,kAuthorizationFlagDefaults);
        return;
    }
    
    FILE* pipe = NULL;
    flags = kAuthorizationFlagDefaults;
    
    char* args1[3];
    
    args1[0] = "/Library/BootScripts/go4launch.sh";
    args1[1] = "/Library/LaunchDaemons/com.13cubed.launchd.go4launch.plist";
    args1[2] = NULL;
    
    AuthorizationExecuteWithPrivileges(authRef,"/bin/rm",flags,args1,&pipe);
    
    AuthorizationFree(authRef,kAuthorizationFlagDefaults);
    
    NSAlert* alert = [[NSAlert alloc] init];
    [alert setMessageText: @"Go4Launch"];
    [alert setInformativeText: @"Uninstall complete!"];
    [alert setAlertStyle:NSInformationalAlertStyle];
    [alert runModal];
    [alert release];
}

@end
