//
//  ViewController.h
//  BluetoothTest
//
//  Created by Admin on 11.1.2016.
//  Copyright © 2016 Jari Isohanni. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ODB2BluetoothWrapper.h"

@interface ViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property ODB2BluetoothWrapper* btWrapper;

@end

