//
//  ODB2BluetoothWrapper.m
//  BluetoothTest
//
//  Created by Admin on 11.1.2016.
//  Copyright © 2016 Jari Isohanni. All rights reserved.
//

#import "ODB2BluetoothWrapper.h"

@implementation ODB2BluetoothWrapper

-(id) init
{
    self = [super init];
    if(self)
    {
        self.deviceArray = [NSMutableArray new];
        
        self.btManager = [[SCPCoreBluetoothCentralManager alloc] init];
        
        //Start up the central manager
        [self.btManager startUpSuccess:^
         {
             [self.delegate logMessage:@"Core bluetooth manager successfully started."];
             
         }
                               failure:^(CBCentralManagerState CBCentralManagerState)
         {
             //Handel the error.
             NSString *message;
             
             switch (CBCentralManagerState)
             {
                 case CBCentralManagerStateUnknown:
                 {
                     message = @"Unknown state";
                     break;
                 }
                 case CBCentralManagerStateResetting:
                 {
                     message = @"Central manager is resetting";
                     break;
                 }
                 case CBCentralManagerStateUnsupported:
                 {
                     message = @"Your device is not supported";
                     NSLog(@"Please note it will not work on a simulator");
                     break;
                 }
                 case CBCentralManagerStateUnauthorized:
                 {
                     message = @"Unauthorised";
                     break;
                 }
                 case CBCentralManagerStatePoweredOff:
                 {
                     message = @"Bluetooth is switched off";
                     break;
                 }
                 default:
                 {
                     //Empty default to remove switch warning
                     break;
                 }
             }
             
             
             [self.delegate logMessage:[NSString stringWithFormat:@"Error %@", message]];
             
         }];

    }
    return self;
}

-(void) startScan
{
    [self.deviceArray removeAllObjects];
    [self scanForBtDevices];
}

-(void) stopScan;
{
    if([self.btManager isReady])
    {
        [self.btManager stopScanning];
        
        [self.delegate scanStopped];
    }
}


#pragma MARK Inner BT methods

-(void) scanForBtDevices
{
    //Check that the central manager is ready to scan
    if([self.btManager isReady])
    {
        //Tell the central manager to start scanning
        //If an array of CBUUIDs is given it will only look for the peripherals with that CBUUID
        [self.btManager scanForPeripheralsWithServices:nil
                                       allowDuplicates:NO
         
                                 didDiscoverPeripheral:^(CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI)
         {
             
             
             
             bool newDevice = YES;
             for (CBPeripheral* btDevice  in self.deviceArray)
             {
                 NSUUID* oId = [btDevice identifier];
                 if([oId isEqual:[peripheral identifier]])
                     newDevice = NO;
             }
             
             //A new peripheral has been found
             if(newDevice)
             {
                 [self.delegate logMessage:[NSString stringWithFormat:@"Discovered Peripheral '%@(%@)' with RSSI of %@",peripheral.identifier.UUIDString, [peripheral name], RSSI]];
                 
                 [self.deviceArray addObject:peripheral];
                 
                 [self.delegate deviceFoundWithName:[peripheral name] andUUID: peripheral.identifier.UUIDString];
                 
                 
             }
             
             
             
         }];
        [self.delegate logMessage:[NSString stringWithFormat:@"Scanning started"]];
        
    }
    else
    {
        [self.delegate logMessage:[NSString stringWithFormat:@"Manager not ready to scan"]];
        
    }
}


-(void) connectToDeviceWithUUID:(NSString*) UUID
{
    [self.btManager cleanup];
    
    for (CBPeripheral* device in self.deviceArray)
    {
        if([device.identifier.UUIDString isEqualToString:UUID])
        {
            [device connectSuccess:^(CBPeripheral *peripheral)
             {
                 [self.delegate logMessage:[NSString stringWithFormat:@"Connected to peripheral '%@'", [peripheral name]]];
                 
                 [self findDeviceServices:device];
             }
             
                              failure:^(CBPeripheral *peripheral, NSError *error)
             {
                 
                 [self.delegate logMessage:[NSString stringWithFormat:@"Failed connecting to Peripheral '%@'. Error : %@", [peripheral name], [error localizedDescription]]];
             }];
        }
    }
}

-(void) findDeviceServices: (CBPeripheral*) device
{
    [device discoverServices:nil //If an array of CBUUIDs is given it will only attempt to discover services with these CBUUIDs
    success:^(NSArray *discoveredServices)
     {
         
         
         for (CBService* service in discoveredServices)
         {
             [self.delegate logMessage:[NSString stringWithFormat:@"Service found %@", service]];
             
             [self readServiceCharacteristics:service];
         }
        
     }
                     failure:^(NSError *error)
     {
         [self.delegate logMessage:[NSString stringWithFormat:@"Error discovering services for peripheral '%@'", [device name]]];
         
     }];
}

-(void) readServiceCharacteristics:(CBService*) service
{
    [service discoverCharacteristics:nil //If an array of CBUUIDs is given it will only look for the services with that
    
                         success:^(NSArray *discoveredCharacteristics) {
                              [self.delegate logMessage:[NSString stringWithFormat:@"Characteristics found: %@", discoveredCharacteristics]];
                         }
                         failure:^(NSError *error) {
                             [self.delegate logMessage:[NSString stringWithFormat:@"Error discovering characteristics: %@", [error localizedDescription]]];
                         }];

}
@end
