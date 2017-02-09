//
//  DPFeedViewController.m
//  ZFNativeAdsManagerDemo
//
//  Created by DaiPei on 2017/2/7.
//  Copyright © 2017年 Ruozi. All rights reserved.
//

#import "DPFeedViewController.h"
#import "ZFNativeAdsManager.h"

@interface DPFeedViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIButton *back;

@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray<ZFReformedNativeAd *> *feedAds;

@end

@implementation DPFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 200;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"feed"];
    self.feedAds = [[ZFNativeAdsManager sharedInstance] fetchPreloadAdForPlacement:@"preload" count:5];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)refreshButtonDidClick:(UIButton *)sender {
    self.feedAds = [[ZFNativeAdsManager sharedInstance] fetchPreloadAdForPlacement:@"preload" count:5];
    [self.tableView reloadData];
}

- (IBAction)backButtonDidClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UITableViewDelegate


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.feedAds.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"feed"];
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:self.feedAds[indexPath.item].coverImage];
    imageView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 200);
    [cell.contentView addSubview:imageView];
    imageView.userInteractionEnabled = YES;
    UIImageView *iconImageView = [[UIImageView alloc] initWithImage:self.feedAds[indexPath.item].iconImage];
    iconImageView.frame = CGRectMake(0, 0, 100, 100);
    [imageView addSubview:iconImageView];
    [[ZFNativeAdsManager sharedInstance] registAdForInteraction:self.feedAds[indexPath.item] view:imageView];
    return cell;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
