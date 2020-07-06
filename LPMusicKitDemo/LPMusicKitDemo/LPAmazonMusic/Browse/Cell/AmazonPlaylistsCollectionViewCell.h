//
//  AmazonPlaylistsCollectionViewCell.h
//  iMuzo
//
//  Created by 许一宁 on 2018/4/13.
//  Copyright © 2018年 wiimu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^playlistSelectButBlock)();

@interface AmazonPlaylistsCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *cover;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@property (weak, nonatomic) IBOutlet UIButton *selectBut;
@property (nonatomic,copy) playlistSelectButBlock block;

@end
