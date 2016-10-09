//
//  NearbyButton.swift
//  1604_LimitFree
//
//  Created by 千锋 on 16/9/27.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit

class NearbyButton: UIControl {
    private var imageView:UIImageView?
    private var textLabel:UILabel?
    //数据  可以通过getter方法获取数据值
    
    var model:LimitModel?{
        didSet{
            let url = NSURL(string: (model?.iconUrl)!)
            imageView?.kf_setImageWithURL(url!)
            
            textLabel?.text = model?.name
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        //初始化子视图
        //文字的高度
        let titleH:CGFloat = 20
        let w = bounds.size.width
        let h = bounds.size.height
        imageView = UIImageView(frame: CGRectMake(0, 0, w, h-titleH))
        addSubview(imageView!)
        
        textLabel = UILabel.createLabelFrame(CGRectMake(0, h-titleH, w, titleH), title: nil, textAlignment: .Center)
        textLabel?.font = UIFont.systemFontOfSize(12)
        addSubview(textLabel!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
  
}
