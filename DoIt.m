#import "DoIt.h"
#include <Security/Authorization.h>
#include <Security/AuthorizationTags.h>

@implementation DoIt

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
    return YES;
}

- (IBAction)myDoIt:(id)sender
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
    
    char* args1[2];
    
    args1[0] = "/Library/BootScripts";
    args1[1] = NULL;
    
    char* args2[3];
    
    args2[0] = "/tmp/go4launch.sh";
    args2[1] = "/Library/BootScripts/";
    args2[2] = NULL;
    
    char* args3[3];
    
    args3[0] = "755";
    args3[1] = "/Library/BootScripts/go4launch.sh";
    args3[2] = NULL;
    
    char* args4[3];
    
    args4[0] = "/tmp/com.13cubed.launchd.go4launch.plist";
    args4[1] = "/Library/LaunchDaemons/";
    args4[2] = NULL;
    
    char* args5[3];
    
    args5[0] = "root:wheel";
    args5[1] = "/Library/LaunchDaemons/com.13cubed.launchd.go4launch.plist";
    args5[2] = NULL;
    
    AuthorizationExecuteWithPrivileges(authRef,"/bin/mkdir",flags,args1,&pipe);
    
    FILE* fptr;
    
    if ((fptr = fopen("/Library/BootScripts/go4launch.sh", "r")))
    {
        NSAlert* alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"No"];
        [alert addButtonWithTitle:@"Yes"];
        [alert setMessageText: @"Go4Launch"];
        [alert setInformativeText: @"The file \"/Library/BootScripts/go4launch.sh\" already exists! Do you want to overwrite?"];
        [alert setAlertStyle:NSInformationalAlertStyle];
        long a = [alert runModal];
        
        if (a == NSAlertFirstButtonReturn)
        {
            [alert release];
            fclose(fptr);
            return;
        }
        
        [alert release];
        fclose(fptr);
    }
    
    if ((fptr = fopen("/tmp/go4launch.sh", "w+")) != NULL)
    {
        fprintf(fptr, "#!/bin/bash\n\n# Use the full path to the startup item. Example:\n#/usr/bin/say Hello, world.\n\n");
        fclose(fptr);
    }
    
    AuthorizationExecuteWithPrivileges(authRef,"/bin/mv",flags,args2,&pipe);
    AuthorizationExecuteWithPrivileges(authRef,"/bin/chmod",flags,args3,&pipe);
    
    if ((fptr = fopen("/tmp/com.13cubed.launchd.go4launch.plist", "w+")) != NULL)
    {
        fprintf(fptr, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n");
        fprintf(fptr, " <!DOCTYPE plist PUBLIC \"-//Apple Computer//DTD PLIST 1.0//EN\"\n");
        fprintf(fptr, "  \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n");
        fprintf(fptr, " <plist version=\"1.0\">\n");
        fprintf(fptr, " <dict>\n");
        fprintf(fptr, "  <key>Label</key>\n");
        fprintf(fptr, "  <string>com.13cubed.launchd.go4launch</string>\n\n");
        fprintf(fptr, "  <key>KeepAlive</key>\n");
        fprintf(fptr, "  <false/>\n\n");
        fprintf(fptr, "  <key>ProgramArguments</key>\n");
        fprintf(fptr, "  <array>\n");
        fprintf(fptr, "   <string>/Library/BootScripts/go4launch.sh</string>\n");
        fprintf(fptr, "   <string>run</string>\n");
        fprintf(fptr, "  </array>\n\n");
        fprintf(fptr, "  <key>RunAtLoad</key>\n");
        fprintf(fptr, "  <true/>\n");
        fprintf(fptr, " </dict>\n");
        fprintf(fptr, " </plist>\n");
        fclose(fptr);
    }
    
    AuthorizationExecuteWithPrivileges(authRef,"/bin/mv",flags,args4,&pipe);
    AuthorizationExecuteWithPrivileges(authRef,"/usr/sbin/chown",flags,args5,&pipe);
    
    AuthorizationFree(authRef,kAuthorizationFlagDefaults);
    
    NSAlert* alert = [[NSAlert alloc] init];
    [alert setMessageText: @"Go4Launch"];
    [alert setInformativeText: @"Install complete! Please open Terminal and use your favorite editor to edit the template script. Example: sudo vi /Library/BootScripts/go4launch.sh"];
    [alert setAlertStyle:NSInformationalAlertStyle];
    [alert runModal];
    [alert release];
}

@end
