//
//  ViewController.m
//  TakePhoto
//
//  Created by Eternity° on 15/8/11.
//  Copyright (c) 2015年 Eternity. All rights reserved.
//

#import "ViewController.h"
#import "CaptureVideoPreviewLayer.h"
#import "CaptureStillImageOutput.h"

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *arrData;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.arrData = @[@"AVCaptureVideoPreviewLayer",@"CaptureStillImageOutput"];
    [self clipExtraCellLine:self.tableView];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrData.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
    }
    cell.textLabel.text = self.arrData[indexPath.row];
    return cell;
}
- (void)clipExtraCellLine:(UITableView *)tableView
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    [self.tableView setTableFooterView:view];
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        CaptureVideoPreviewLayer *vc = [[CaptureVideoPreviewLayer alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
    }
    if (indexPath.row == 1) {
        CaptureStillImageOutput *vc = [[CaptureStillImageOutput alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
