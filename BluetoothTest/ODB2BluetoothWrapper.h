//
//  ODB2BluetoothWrapper.h
//  BluetoothTest
//
//  Created by Admin on 11.1.2016.
//  Copyright © 2016 Jari Isohanni. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCPCoreBluetoothCentralManager.h"

@protocol ODB2BluetoothWrapperDelegate <NSObject>
@required
- (void) logMessage:(NSString*) message;
- (void) deviceFoundWithName: (NSString*) name andUUID: (NSString*) uuid;
- (void) scanStopped;
@end


@interface ODB2BluetoothWrapper : NSObject
{
    id <ODB2BluetoothWrapperDelegate> _delegate;
    
}

@property (nonatomic,strong) id delegate;

@property SCPCoreBluetoothCentralManager* btManager;

@property NSMutableArray* deviceArray;

-(void) startScan;
-(void) stopScan;
-(void) connectToDeviceWithUUID:(NSString*) UUID;

@end
