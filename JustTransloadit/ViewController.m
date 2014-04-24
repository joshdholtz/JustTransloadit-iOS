//
//  ViewController.m
//  JustTransloadit
//
//  Created by Josh Holtz on 4/22/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "ViewController.h"

#import "TransloaditRequestOperation.h"

@interface ViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imgPhoto;
@property (nonatomic, strong) UIImage *imageToUpload;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	[picker dismissViewControllerAnimated:YES completion:^{
        self.imageToUpload = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        [self.imgPhoto setImage:self.imageToUpload];
        
    }];
}

#pragma mark - Actions

- (IBAction)onClickChoose:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    [picker.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [picker.navigationBar setTintColor:[UIColor blackColor]];
    [picker setDelegate:self];
    [picker setSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    
    [self presentViewController:picker animated:YES completion:nil];
}

- (IBAction)onClickUpload:(id)sender {
    
    NSString *key = @"b07b5b60ca2211e3a7608df660eff3ec";
    NSString *templateId = @"3490ae50ca2311e3816b1d6c4b95fef4";

    // Create your data and mime type (we are using an image here)
    NSData *imageData = UIImageJPEGRepresentation(self.imageToUpload, 0.6f);
    NSString *mimeType = @"image/jpg";
    
    // Create your TransloaditRequestOperation (its a subclass of AFHTTPRequestOperation) by passing in your awesome data from above
    TransloaditRequestOperation *requestOperation = [[TransloaditRequestOperation alloc] initWithKey:key withTemplateId:templateId withData:imageData withMimeType:mimeType];
    [requestOperation setWait:YES];
    [requestOperation setDelayInterval: 1];
    
    // Set the upload progress block
    [requestOperation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        CGFloat progress = (float)totalBytesWritten / (float)totalBytesExpectedToWrite;
        NSLog(@"Progress - %f", progress);
    }];
    
    // Set the completion blocks - cause this is what its all about
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success - %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error - %@", error);
    }];
    
    // Add the operation to the queue to get things going
    [[NSOperationQueue mainQueue] addOperation:requestOperation];
    
    NSLog(@"Started upload");
}

#pragma mark - Private

@end
