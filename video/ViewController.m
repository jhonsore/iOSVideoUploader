//
//  ViewController.m
//  video
//
//  Created by iOS on 09/09/16.
//  Copyright © 2016 Backstage Digital. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()
{
    CGRect frame;
    NSString *typeRequisition;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    frame = [[UIScreen mainScreen] bounds];
    
    [self createButtonPlay];
    [self createButtonRecord];
    
}

//----------------------------------------------
- (void) createButtonRecord {
        
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self
               action:@selector(recordAction:)
     forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"Record Video" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    button.frame = CGRectMake((frame.size.width-150.0)/2, 250, 150.0, 40.0);
    
    [[button layer] setBorderWidth:1.0f];
    [[button layer] setBorderColor:[UIColor blueColor].CGColor];
    
    [self.view addSubview:button];
    
}

- (void) recordAction:(id) sender{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        typeRequisition = @"record";
        
        UIImagePickerController *picker = [[UIImagePickerController alloc]init];
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.delegate = self;
        picker.allowsEditing = NO;
        
        NSArray *mediaTypes = [[NSArray alloc]initWithObjects:(NSString *)kUTTypeMovie, nil];
        
        picker.mediaTypes = mediaTypes;
        
        [self presentViewController:picker animated:YES completion:nil];
        
    } else {
        
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"Câmera não encontrada" delegate:nil cancelButtonTitle:@"Fechar!" otherButtonTitles:nil, nil];
        [alertView show];
    }

}

//----------------------------------------------
- (void) createButtonPlay {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self
               action:@selector(playAction:)
     forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"Choose Video" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    button.frame = CGRectMake((frame.size.width-150.0)/2, 200, 150.0, 40.0);
    
    [[button layer] setBorderWidth:1.0f];
    [[button layer] setBorderColor:[UIColor blueColor].CGColor];
    
    [self.view addSubview:button];
}

- (void) playAction:(id) sender{
    
    typeRequisition = @"play";
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie,      nil];
    
    [self presentViewController:imagePicker animated:YES completion:nil];
    
}

#pragma mark - Delegate Methods

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    // user hit cancel
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    
    if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
        NSURL *videoUrl=(NSURL*)[info objectForKey:UIImagePickerControllerMediaURL];
        NSString *moviePath = [videoUrl path];
        
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum (moviePath)) {
            
            //caso o typo de requisição seja @"record" gravamos o video no celular
            if([typeRequisition isEqualToString:@"record"]){
                UISaveVideoAtPathToSavedPhotosAlbum (moviePath, nil, nil, nil);
            }
            
            
            NSData *movieData = [NSData dataWithContentsOfURL:videoUrl];
            
           //----------------------------
           //----------------------------
           
            NSURL *yourURL = [NSURL URLWithString:@"your-url/ws-connection.php"];
            
            
            NSData *imgData = movieData;
            
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            [request setURL:yourURL];
            [request setHTTPMethod:@"POST"];
            
            NSMutableData *body = [NSMutableData data];
            NSString *boundary = @"---------------------------14737809831466499882746641449";
            NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
            [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
            
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"Content-Disposition: form-data; name=\"file\"; filename=\"a.mp4\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[NSData dataWithData:imgData]];
            [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
            [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            
            // close form
            [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            
            // setting the body of the post to the request
            [request setHTTPBody:body];
            
            
            NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
            // NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
            NSDictionary *dict=[NSJSONSerialization JSONObjectWithData:returnData options:NSJSONReadingMutableLeaves error:nil];
            NSLog(@"%@",dict);
            
            
            
            
           //----------------------------
           //----------------------------
            
        }
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void) connectionFinishedWithData:(id)data{
    NSLog(@"%@", data);
}




@end
