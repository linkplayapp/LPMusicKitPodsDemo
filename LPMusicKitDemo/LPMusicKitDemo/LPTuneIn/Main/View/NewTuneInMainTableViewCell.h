//
//  NewTuneInMainTableViewCell.h
//  iMuzo
//
//  Created by lyr on 2019/4/16.
//  Copyright © 2019年 wiimu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,MainCollectionViewCellType)
{
    Cell_image_title = 0,//图片+标题
    Cell_image //纯图片显示
};

typedef void (^CollectionViewCellDidBlock)(NSInteger selectIndex, NSInteger type);

@interface NewTuneInMainTableViewCell : UITableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView CellType:(NSString *)cellIdentifier type:(MainCollectionViewCellType)type;

- (void)reloadLoad;

@property (nonatomic, strong) LPTuneInPlayHeader *playHeader;
@property (nonatomic, strong) NSString *controllerName;
@property (nonatomic, copy) CollectionViewCellDidBlock block;

@end

NS_ASSUME_NONNULL_END
