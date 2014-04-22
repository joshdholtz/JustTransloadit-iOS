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
    
    NSString *key = @"<your-key>";
    NSString *templateId = @"<your-template-id>";

    TransloaditRequestOperation *requestOperation = [[TransloaditRequestOperation alloc] initWithKey:key withTemplateId:templateId withData:UIImageJPEGRepresentation(self.imageToUpload, 0.6f) withMimeType:@"image/jpg"];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success - %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error - %@", error);
    }];
    [[NSOperationQueue mainQueue] addOperation:requestOperation];
    
    NSLog(@"Started upload");
}

#pragma mark - Private

@end
