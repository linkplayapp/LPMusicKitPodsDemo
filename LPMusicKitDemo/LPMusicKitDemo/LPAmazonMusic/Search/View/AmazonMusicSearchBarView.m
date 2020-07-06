//
//  NewTuneInSearchBarView.m
//  iMuzo
//
//  Created by lyr on 2019/4/26.
//  Copyright © 2019年 wiimu. All rights reserved.
//

#import "AmazonMusicSearchBarView.h"
#import "AmazonMusicConfig.h"
#import "AmazonMusicMethod.h"

@interface AmazonMusicSearchBarView () <UITextFieldDelegate>

@end

@implementation AmazonMusicSearchBarView

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"AmazonMusicSearchBarView" owner:self options:nil];
        
        // 如果路径不存在，return nil
        if (arrayOfViews.count < 1)
        {
            return nil;
        }
        // 如果xib中view不属于UICollectionReusableView类，return nil
        if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[UIView class]])
        {
            return nil;
        }
        // 加载nib
        self = [arrayOfViews objectAtIndex:0];
        
        self.frame = frame;
        
        self.layer.cornerRadius = 2.0f;
        self.layer.masksToBounds = YES;
        self.backgroundColor = [UIColor clearColor];
        
        [self setAllObject];
        
    }
    return self;
}

- (void)setAllObject
{
    self.backImage.backgroundColor = HWCOLORA(255, 255, 255, 0.1);
    self.searchImage.image = [AmazonMusicMethod imageNamed:@"tunein_search_title_n"];
    
    self.textFiled.delegate = self;
    self.textFiled.attributedPlaceholder = [[NSAttributedString alloc] initWithString:AMAZONLOCALSTRING(@"primemusic_Search_Amazon_Music") attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:self.textFiled.font}];
    self.textFiled.font = [UIFont systemFontOfSize:14];
    self.textFiled.textAlignment = NSTextAlignmentLeft;
    
    self.textFiled.borderStyle = UITextBorderStyleNone;
    self.textFiled.backgroundColor = [UIColor clearColor ];
    self.textFiled.keyboardType = UIKeyboardTypeWebSearch;
    self.textFiled.returnKeyType = UIReturnKeySearch;
//    self.textFiled.clearButtonMode = UITextFieldViewModeWhileEditing;
// self.textFiled.tintColor= self.textColor;
    [self.deleateBut setImage:[AmazonMusicMethod imageNamed:@"tunein_menu_url_delete"] forState:UIControlStateNormal];
}

- (void)endEnditing
{
    [self.textFiled endEditing:YES];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(amazonMusicSearchBarView:Text:)])
    {
        [self.delegate amazonMusicSearchBarView:0 Text:textField.text];
    }
    return YES;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(amazonMusicSearchBarView:Text:)])
    {
        [self.delegate amazonMusicSearchBarView:3 Text:textField.text];
    }
    
    [self.textFiled resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
   
    if ([self.delegate respondsToSelector:@selector(amazonMusicSearchBarView:Text:)])
    {
        
        NSString *all;
        if (string.length > 0)
        {
            all = [NSString stringWithFormat:@"%@%@",self.textFiled.text,string];
        }
        else
        {
            if (self.textFiled.text.length > 1)
            {
                all = [self.textFiled.text substringToIndex:self.textFiled.text.length - 1];
            }
            else
            {
                all = @"";
            }
        }
        
        if (all.length > 0)
        {
            self.deleateBut.hidden = NO;
        }
        else
        {
            self.deleateBut.hidden = YES;
        }
        
        [self.delegate amazonMusicSearchBarView:4 Text:all];
    }
    return YES;
}


- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(amazonMusicSearchBarView:Text:)])
    {
         [self.delegate amazonMusicSearchBarView:4 Text:@""];
    }
    return YES;
}

- (IBAction)deleateButAction:(id)sender {
    
    self.deleateBut.hidden = YES;
    self.textFiled.text = @"";
    if ([self.delegate respondsToSelector:@selector(amazonMusicSearchBarView:Text:)])
    {
        [self.delegate amazonMusicSearchBarView:4 Text:@""];
    }
}


@end
