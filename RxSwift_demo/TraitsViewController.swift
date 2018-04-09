//
//  TraitsViewController.swift
//  RxSwift_demo
//
//  Created by 赵光飞 on 2018/4/8.
//  Copyright © 2018年 ash. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class TraitsViewController: UIViewController {
    
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var button: UIButton!
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        singleTrait()
        
        driverTrait()
        
    }
    
    private func singleTrait() {
        getPlaylist("0").subscribe(onSuccess: { (result) in
            print("JSON结果: ", result)
        }) { (error) in
            print("发生错误: ", error)
        }.disposed(by: disposeBag)
        
        getPlaylist("0").subscribe { (event) in
            switch event {
            case .success(let json):
                print("JSON结果: ", json)
                break
            case .error(let error):
                print("发生错误: ", error)
                break
            }
        }.disposed(by: disposeBag)
        
        
        // asSingle()
        // 可以通过调用 Observable 序列的 .asSingle() 方法，将它转换为 Single。
        
        Observable.of("1")
            .asSingle()
            .subscribe({ print($0) })
            .disposed(by: disposeBag)
        
        // Completable
        // Completable 是 Observable 的另外一个版本。不像 Observable 可以发出多个元素，它要么只能产生一个 completed 事件，要么产生一个 error 事件。
        
        // Completable 和 Observable<Void> 有点类似。适用于那些只关心任务是否完成，而不需要在意任务返回值的情况。比如：在程序退出时将一些数据缓存到本地文件，供下次启动时加载。像这种情况我们只关心缓存是否成功。
        
        
        // Maybe
        // Maybe 同样是 Observable 的另外一个版本。它介于 Single 和 Completable 之间，它要么只能发出一个元素，要么产生一个 completed 事件，要么产生一个 error 事件。
    }
    
    private func driverTrait() {
        
        // Driver
        // 1，基本介绍
        //（1）Driver 可以说是最复杂的 trait，它的目标是提供一种简便的方式在 UI 层编写响应式代码。
        //（2）如果我们的序列满足如下特征，就可以使用它：
        // 不会产生 error 事件
        // 一定在主线程监听（MainScheduler）
        // 共享状态变化（shareReplayLatestWhileConnected）
        
        // ControlProperty
        
        //1，基本介绍
        //（1）ControlProperty 是专门用来描述 UI 控件属性，拥有该类型的属性都是被观察者（Observable）。
        //（2）ControlProperty 具有以下特征：
        //不会产生 error 事件
        //一定在 MainScheduler 订阅（主线程订阅）
        //一定在 MainScheduler 监听（主线程监听）
        //共享状态变化
        
        textField.rx.text.bind(to:label.rx.text).disposed(by: disposeBag)
        
        // ControlEvent
        //1，基本介绍
        //（1）ControlEvent 是专门用于描述 UI 所产生的事件，拥有该类型的属性都是被观察者（Observable）。
        //（2）ControlEvent 和 ControlProperty 一样，都具有以下特征：
        //不会产生 error 事件
        //一定在 MainScheduler 订阅（主线程订阅）
        //一定在 MainScheduler 监听（主线程监听）
        //共享状态变化
        
        button.rx.tap.subscribe (onNext: {
            print("tap me !!!")
        }).disposed(by: disposeBag)
    }
    
    //获取豆瓣某频道下的歌曲信息
    private func getPlaylist(_ channel: String) -> Single<[String: Any]> {
        
        //与数据相关的错误类型
        enum DataError: Error {
            case cantParseJSON
        }
        
        return Single<[String: Any]>.create(subscribe: { (single) -> Disposable in
            
            let url = "https://douban.fm/j/mine/playlist?"
                + "type=n&channel=\(channel)&from=mainsite"
            
            let task = URLSession.shared.dataTask(with: URL.init(string: url)!) { data, response, error in
                if let error = error {
                    single(.error(error))
                    return
                }
                
                guard let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves), let result = json as? [String: Any] else {
                    single(.error(DataError.cantParseJSON))
                    return
                }
                single(.success(result))
            }
            task.resume()
            return Disposables.create {
                task.cancel()
            }
        })
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
