//
//  LimitFreeViewController.swift
//  1604_LimitFree
//
//  Created by gaokunpeng on 16/9/26.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit

/**
 限免界面
 */

class LimitFreeViewController: LFNavViewController {
    
    //表格
    var tbView: UITableView?
    
    //数据源数组
    lazy var dataArray = Array<LimitModel>()
    
    //当前页数
    var curPage: Int = 1
    
    //创建表格
    func createTableView() {
        
        automaticallyAdjustsScrollViewInsets = false
        
        tbView = UITableView(frame: CGRectMake(0, 64, kScreenWidth, kScreenHeight-64-49), style: .Plain)
        tbView?.delegate = self
        tbView?.dataSource = self
        view.addSubview(tbView!)
        
        //下拉刷新
        tbView?.headerView = XWRefreshNormalHeader(target: self, action: #selector(loadFirstPage))
        
        //上拉加载更多
        tbView?.footerView = XWRefreshAutoNormalFooter(target: self, action: #selector(loadNextPage))
    }
    
    //下拉刷新
    func loadFirstPage(){
        
        curPage = 1
        downloadData()
        
    }
    
    //上拉加载更多
    func loadNextPage(){
        
        curPage += 1
        downloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        

        //导航
        createMyNav()
        //表格
        createTableView()
        //下载
        downloadData()
        
    }
    
    
    //下载
    func downloadData() {
        
        //进入加载状态
        ProgressHUD.showOnView(view)
        
        
        let urlString = String(format: kLimitUrl, curPage)
        
        let d = LFDownloader()
        d.delegate = self
        d.downloadWithURLString(urlString)
    }
    

    //创建导航
    func createMyNav() {
        //分类
        addNavButton("分类", target: self, action: #selector(gotoCategory), isLeft: true)
        
        //标题
        addNavTitle("限免")
        
        //设置
        addNavButton("设置", target: self, action: #selector(gotoSetPage), isLeft: false)
    }
    
    func gotoCategory(){}
    func gotoSetPage() {}
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

//MARK: LFDownloader代理
extension LimitFreeViewController: LFDownloaderDelegate {
    
    //下载失败
    func downloader(downloder: LFDownloader, didFailWithError error: NSError) {
        
        ProgressHUD.hideAfterFailOnView(view)
        
    }
    
    //下载成功
    func downloader(downloader: LFDownloader, didFinishWithData data: NSData) {
        //JSON解析
//        let str = NSString(data: data, encoding: NSUTF8StringEncoding)
//        print(str!)
        
        //这段代码应该写在下载结束的地方--begin
        if curPage == 1 {
            //清空数组
            dataArray.removeAll()
        }
        //这段代码应该写在下载结束的地方--end
        
        let result = try! NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers)
        if result.isKindOfClass(NSDictionary) {
            
            let dict = result as! Dictionary<String, AnyObject>
            
            let array = dict["applications"] as! Array<Dictionary<String, AnyObject>>
            for appDict in array {
                //创建模型对象
                let model = LimitModel()
                //使用KVC
                model.setValuesForKeysWithDictionary(appDict)
                dataArray.append(model)
            }
            
            //回到主线程刷新UI
            dispatch_async(dispatch_get_main_queue(), {
                self.tbView!.reloadData()
                
                //结束刷新
                self.tbView?.headerView?.endRefreshing()
                self.tbView?.footerView?.endRefreshing()
                
                ProgressHUD.hideAfterSuccessOnView(self.view)
            })
            
            /**
             怎么判断是滑到了最后一页
             1、接口返回一个最大页数值或者最大数量值
             1)maxPage
             2)totalCount
             
             2、http://1000phone.net:8088/app/iAppFree/api/topic.php?page=1&number=21
             
             //每页20条
             //请求21条数据，只显示20条
             
             1）如果总数是40
             1->21  
             21->40   返回的数据<21条
             
             2) 如果是41条
             1->21
             21->41
             41-> 返回一条 < 21条

             */
            
            
        }
        
        
    }
    
}

//MARK: UITableView代理
extension LimitFreeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellId = "limitCellId"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId) as? LimitCell
        if nil == cell {
            cell = NSBundle.mainBundle().loadNibNamed("LimitCell", owner: nil, options: nil).last as? LimitCell
        }
        
        cell?.selectionStyle = .None
        
        //显示数据
        let model = dataArray[indexPath.row]
        cell?.config(model, atIndex: indexPath.row+1)
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //点击跳转详情界面
        
        let detailCtrl = DetailViewController()
        let model = dataArray[indexPath.row]
        detailCtrl.appId = model.applicationId
        
        //跳转之前隐藏tabbar
        hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(detailCtrl, animated: true)
        //跳转之后前面界面显示tabbar
        hidesBottomBarWhenPushed = false
        
    }
    
}





