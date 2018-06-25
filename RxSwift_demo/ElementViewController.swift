//
//  ElementViewController.swift
//  RxSwift_demo
//
//  Created by 赵光飞 on 2018/4/16.
//  Copyright © 2018年 ash. All rights reserved.
//

import UIKit
import RxSwift_demo
//import RxCocoa
//import RxSwift

struct UserViewModel {
    let username = Variable("guest")
    
    lazy var userInfo = {
        return self.username.asObservable().map({ (username) in
            return username == "ash" ? "您是管理员" : "您是普通访客"
        }).share(replay: 1)
    }()
}

/// UI 组件的demo
class ElementViewController: UIViewController {

    @IBOutlet weak var button: UIButton!
    
    @IBOutlet weak var button1: UIButton!
    
    @IBOutlet weak var button2: UIButton!
    
    @IBOutlet weak var button3: UIButton!
    
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var infoLabel: UILabel!
    
    var userVM = UserViewModel()
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        let timer = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
        timer.map(formatTimeInterval).bind(to: button.rx.attributedTitle()).disposed(by: disposeBag)
        
        // 强制解包，避免后面还需要处理可选类型
        let buttons:[UIButton] = [button1, button2, button3].map({$0});
        
        let selectedButton = Observable.from(
            buttons.map({ (button) in
                button.rx.tap.map { button }
            })
        ).merge()
        
        for button in buttons {
            selectedButton.map({$0 == button}).bind(to: button.rx.isSelected).disposed(by: disposeBag)
        }
        
        //简单的双向绑定
        userVM.username.asObservable().bind(to: textField.rx.text).disposed(by: disposeBag)
        textField.rx.text.orEmpty.bind(to: userVM.username).disposed(by: disposeBag)
        
        //将用户信息绑定到label上
        userVM.userInfo.bind(to: infoLabel.rx.text).disposed(by: disposeBag)
        
        
        //自定义双向绑定操作符（operator）
        
    }
    
    func formatTimeInterval(ms: NSInteger) -> NSMutableAttributedString {
        let string = String(format: "%0.2d:%0.2d.%0.1d",
                            arguments: [(ms / 600) % 600, (ms % 600 ) / 10, ms % 10])
        //富文本设置
        let attributeString = NSMutableAttributedString(string: string)
        //从文本0开始6个字符字体HelveticaNeue-Bold,16号
        attributeString.addAttribute(NSAttributedStringKey.font,
                                     value: UIFont(name: "HelveticaNeue-Bold", size: 16)!,
                                     range: NSMakeRange(0, 5))
        //设置字体颜色
        attributeString.addAttribute(NSAttributedStringKey.foregroundColor,
                                     value: UIColor.white, range: NSMakeRange(0, 5))
        //设置文字背景颜色
        attributeString.addAttribute(NSAttributedStringKey.backgroundColor,
                                     value: UIColor.orange, range: NSMakeRange(0, 5))
        return attributeString;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
