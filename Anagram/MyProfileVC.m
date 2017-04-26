//
//  MyProfileVC.m
//  Anagram
//
//  Created by Ashok Choudhary on 29/08/16.
//  Copyright © 2016 squarebits. All rights reserved.
//

#import "MyProfileVC.h"
#import "UIImageView+WebCache.h"
@interface MyProfileVC ()

@end

@implementation MyProfileVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer* tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(btnProfilechangeClicked:)];
    [imgProfile addGestureRecognizer:tap];
    
    imgProfile.layer.cornerRadius=86.5;
    imgProfile.layer.masksToBounds=YES;
    
    
    txtUserName.attributedPlaceholder =[[NSAttributedString alloc] initWithString:@"Please enter username"
                                                                    attributes:
                                     @{NSForegroundColorAttributeName:[UIColor grayColor],}];

    
    
    [self getUserDetailsApi];
    // Do any additional setup after loading the view from its nib.
}


-(void)getUserDetailsApi
{
    NSString *strUrl=getUserDetails;
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    [dict setObject:App_Delegate.currentUser.userID forKey:@"user_id"];
    [APIsList callPostAsyncAPIUrl:strUrl withParameter:dict CallBackMethod:@selector(callBackGetUserDetails:) toTarget:self showHUD:YES];
}

-(void)callBackGetUserDetails:(NSMutableDictionary*)dicRes
{
    if ([[dicRes objectForKey:@"status"]integerValue]==1) {
        
        NSDictionary *dict=[dicRes objectForKey:@"user"];
        txtUserName.text=[dict objectForKey:@"username"];
        [imgProfile sd_setImageWithURL:[NSURL URLWithString:[dict objectForKey:@"profile_image"]]placeholderImage:[UIImage imageNamed:@"profile_pic_placeholder"]];
        
        lblHighScore.text=[NSString stringWithFormat:@"High Score: %@",[dict objectForKey:@"score"]];
        
    }
    else
    {
        [App_Delegate showAlertView:@"" strMessage:[dicRes objectForKey:@"message"]];
    }
    
}




- (IBAction)btnProfilechangeClicked:(id)sender {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"Edit Profile Image"
                                  delegate:self
                                  cancelButtonTitle:@"Cancel"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"Camera",@"Photos", nil];
    actionSheet.tag = 1;
    actionSheet.actionSheetStyle = UIBarStyleBlackTranslucent;
    [actionSheet showInView:self.view];
    
}



#pragma mark - ActionSheet

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==0)
    {
        [self openCamera];
    }
    else if(buttonIndex == 1)
    {
        [self openPhotoGallery];
    }
    
}

-(void)openCamera
{
  UIImagePickerController*  imgPicker = [[UIImagePickerController alloc] init];
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else
    {
        imgPicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    }
    imgPicker.delegate = self;
//    imgPicker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
    imgPicker.allowsEditing = YES;
    [self presentViewController:imgPicker animated:YES completion:nil];
}

-(void)openPhotoGallery
{
 UIImagePickerController*   imgPicker = [[UIImagePickerController alloc] init];
    imgPicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    imgPicker.delegate = self;
//    imgPicker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
    imgPicker.allowsEditing = YES;
    [self presentViewController:imgPicker animated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary* )info
{
  UIImage*  imgSelectOwn = info[UIImagePickerControllerEditedImage];
    

    imgProfile.image=imgSelectOwn;
    [self dismissViewControllerAnimated:YES completion:nil];
    
    NSData *data=UIImageJPEGRepresentation(imgSelectOwn, .8);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *savedImagePath = [documentsDirectory stringByAppendingPathComponent:@"savedImage.jpg"];
 
    
    [data writeToFile:savedImagePath atomically:NO];
}


-(IBAction)updateUserProfile
{
    
    NSString *strUrl=updateUserDetails;
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *savedImagePath = [documentsDirectory stringByAppendingPathComponent:@"savedImage.jpg"];
    NSURL *imgUrl=[NSURL fileURLWithPath:savedImagePath];

    BOOL isProfileEdited=NO;
    if ([[NSFileManager defaultManager]fileExistsAtPath:savedImagePath]) {
         [dict setObject:imgUrl forKey:@"image"];
        
        isProfileEdited=YES;
     }
    
    if(txtUserName.text.length>0)
    {
        [dict setObject:txtUserName.text forKey:@"username"];
         isProfileEdited=YES;

    }
    
    
    if (!isProfileEdited) {
        
        [[[UIAlertView alloc]initWithTitle:@"" message:@"Please change your username or profile pic to update" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]show];
        return;
    }
    
    [dict setObject:App_Delegate.currentUser.userID forKey:@"user_id"];
    
    [APIsList callPostAsyncAPIUrl:strUrl withParameter:dict CallBackMethod:@selector(callBackUpdateImage:) toTarget:self showHUD:YES];

}


-(void)callBackUpdateImage:(NSDictionary*)dictRes
{
    if ([[dictRes objectForKey:@"status"]integerValue]==1) {
        
         NSURL *url=[NSURL URLWithString:[dictRes objectForKey:@"image"]];
        if (url) {
            [imgProfile sd_setImageWithURL:url];
        }
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *savedImagePath = [documentsDirectory stringByAppendingPathComponent:@"savedImage.jpg"];
      [[NSFileManager defaultManager]removeItemAtPath:savedImagePath error:nil];

        ObjApp_Delegate.currentUser.userName=txtUserName.text;
    }
}

-(IBAction)btnBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
