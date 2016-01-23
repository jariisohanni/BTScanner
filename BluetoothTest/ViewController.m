//
//  ViewController.m
//  BluetoothTest
//
//  Created by Admin on 11.1.2016.
//  Copyright © 2016 Jari Isohanni. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()
@property (strong, nonatomic) IBOutlet UILabel *infoLabel;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITextView *logView;

@property NSMutableArray* deviceArray;
@property (strong, nonatomic) IBOutlet UIButton *scanButton;
@property BOOL scanning;

@end

@implementation ViewController

#pragma MARK ODB2BluetoothWrapperDelegate
-(void) logMessage:(NSString*) newLine
{
    if(![NSThread isMainThread])
    {
        dispatch_sync(dispatch_get_main_queue(), ^
        {
            self.logView.text = [NSString stringWithFormat:@"%@%@%@", self.logView.text, newLine, @"\n"];
            [self.logView scrollRangeToVisible:NSMakeRange(self.logView.text.length, 0)];
                      
        });
        }
        else
        {
            self.logView.text = [NSString stringWithFormat:@"%@%@%@", self.logView.text, newLine, @"\n"];
            [self.logView scrollRangeToVisible:NSMakeRange(self.logView.text.length, 0)];

        }
}

-(void) scanStopped
{
    [self.scanButton setTitle:@"SCAN" forState:UIControlStateNormal];
    self.scanning = NO;;
    
}

- (void) deviceFoundWithName: (NSString*) name andUUID: (NSString*) uuid;
{
    [self.deviceArray addObject:uuid];
    [self.tableView performSelectorOnMainThread:@selector(reloadData)
                                     withObject:nil
                                  waitUntilDone:YES];
}
#pragma MARK UI dunctions

- (IBAction)onTouchScan:(id)sender
{
    if(!self.scanning)
    {
        [self.logView setText:@""];
        [self logMessage:@"New SCAN"];
        
        self.scanning = YES;
    
        [self.scanButton setTitle:@"Cancel SCAN" forState:UIControlStateNormal];
    
        [self.deviceArray removeAllObjects];
        [self.tableView performSelectorOnMainThread:@selector(reloadData)
                                         withObject:nil
                                      waitUntilDone:YES];
        [self.btWrapper startScan];
    }
    else
        [self.btWrapper stopScan];
    
    
}

-(void) stopScan
{
    [self.scanButton setTitle:@"SCAN" forState:UIControlStateNormal];
    self.scanning = NO;;
    
    [self.btWrapper stopScan];
    
}
#pragma MARK ViewController life-cycle handling

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void) viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void) viewDidAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterForeground:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [self stopScan];
}

- (void)applicationDidEnterForeground:(UIApplication *)application
{
    

}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    self.btWrapper = [[ODB2BluetoothWrapper alloc] init];
    self.btWrapper.delegate = self;
    
    self.deviceArray = [NSMutableArray new];
    [self.logView setText:@""];
    
}





#pragma MARK TABLE VIEW DELEGATE
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.deviceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    cell.textLabel.text = [self.deviceArray objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    [self.btWrapper connectToDeviceWithUUID: [self.deviceArray objectAtIndex:indexPath.row]];

}

@end
