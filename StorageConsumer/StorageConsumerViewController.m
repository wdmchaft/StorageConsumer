//
//  StorageConsumerViewController.m
//  StorageConsumer
//
//  Created by Yoichi Tagaya on 12/01/20.
//  Copyright (c) 2012 Yoichi Tagaya. All rights reserved.
//

#import "StorageConsumerViewController.h"
#include <stdio.h>
#include <stdlib.h>

const NSUInteger StorageConsumerComponentCount = 2;
const NSUInteger StorageConsumerGigaComponent = 0;
const NSUInteger StorageConsumerMegaComponent = 1;

@implementation StorageConsumerViewController

@synthesize gigaByteValues;
@synthesize megaByteValues;
@synthesize sizePicker;

#pragma mark - Private
- (NSString *)dataDirectory
{
    static NSString *directory = nil;
    if (nil == directory) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        directory = [[paths objectAtIndex:0] retain];
    }
    return [directory stringByAppendingPathComponent:@"data"];
}

- (NSString *)newDataFileName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *currentFiles = [fileManager contentsOfDirectoryAtPath:[self dataDirectory] error:nil];
    return [NSString stringWithFormat:@"%u", [currentFiles count]];
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:title
                                                     message:message
                                                    delegate:nil
                                           cancelButtonTitle:nil
                                           otherButtonTitles:@"Dismiss", nil]
                          autorelease];
    [alert show];
}

#pragma mark - Public
- (void)dealloc
{
    [gigaByteValues release];
    [megaByteValues release];
    [sizePicker release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSMutableArray *gigaBytes = [NSMutableArray array];
    for (NSUInteger giga = 0; giga <= 10; giga++) {
        [gigaBytes addObject:[NSString stringWithFormat:@"%u", giga]];
    }
    self.gigaByteValues = gigaBytes;
    
    NSMutableArray *megaBytes = [NSMutableArray array];
    for (NSUInteger mega = 0; mega <= 950; mega += 50) {
        [megaBytes addObject:[NSString stringWithFormat:@"%u", mega]];
    }
    self.megaByteValues = megaBytes;
}

- (void)viewDidUnload
{
    self.gigaByteValues = nil;
    self.megaByteValues = nil;
    self.sizePicker = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    } else {
        return YES;
    }
}

#pragma mark IBActions
- (IBAction)consumeButtonDidTouchUpInside:(id)sender
{
    // Calculate file size to write.
    NSInteger gigaRow = [self.sizePicker selectedRowInComponent:StorageConsumerGigaComponent];
    NSString *gigaByteValue = [self.gigaByteValues objectAtIndex:gigaRow];
    NSInteger gigaBytes = [gigaByteValue integerValue];
    NSInteger megaRow = [self.sizePicker selectedRowInComponent:StorageConsumerMegaComponent];
    NSString *megaByteValue = [self.megaByteValues objectAtIndex:megaRow];
    NSInteger megaBytes = 1024 * gigaBytes + [megaByteValue integerValue];
    if (megaBytes <= 0) {
        [self showAlertWithTitle:@"Zero Size" message:@"Select size greater than zero."];
        return;
    }
    
    // Prepare a file to write.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL success = [fileManager createDirectoryAtPath:[self dataDirectory]
                          withIntermediateDirectories:YES
                                           attributes:nil 
                                                error:NULL];
    if (!success) {
        [self showAlertWithTitle:@"Error" message:@"Failed to create data directory."];
        return;
    }
    NSString *newFilePath = [[self dataDirectory] stringByAppendingPathComponent:[self newDataFileName]];
    success = [fileManager createFileAtPath:newFilePath contents:nil attributes:nil];
    if (!success) {
        [self showAlertWithTitle:@"Error" message:@"Failed to prepare a data file."];
    }
    
    // Write data to the file.
    NSFileHandle* fileHandle = [NSFileHandle fileHandleForWritingAtPath:newFilePath];
    void *megaBuffer = malloc(1024*1024);
    if (NULL == megaBuffer) {
        [self showAlertWithTitle:@"Error" message:@"Low memory"];
    }
    NSData *megaData = [NSData dataWithBytesNoCopy:megaBuffer length:1024*1024 freeWhenDone:YES];
    @try {
        for (NSInteger count = 0; count < megaBytes; count++) {
            [fileHandle writeData:megaData];
            NSLog(@"Wrote %d MB", count + 1);
        }
    }
    @catch (NSException *exception) {
        [self showAlertWithTitle:@"Error" message:@"Failed to create data file."];
        return;
    }
    @finally {
        [fileHandle closeFile];
    }
    
    [self showAlertWithTitle:@"Done" message:@"Consumed storage successfully."];
}

- (IBAction)clearButtonDidTouchUpInside:(id)sender
{
    [[NSFileManager defaultManager] removeItemAtPath:[self dataDirectory] error:NULL];
    [self showAlertWithTitle:@"Done" message:@"Cleared consumed data."];
}

#pragma mark UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return StorageConsumerComponentCount;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return StorageConsumerGigaComponent == component 
    ? [self.gigaByteValues count] : [self.megaByteValues count];
}

#pragma mark UIPickerViewDelegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return StorageConsumerGigaComponent == component
    ? [self.gigaByteValues objectAtIndex:row] : [self.megaByteValues objectAtIndex:row];
}

@end
