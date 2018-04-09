//
//  ViewController.swift
//  RxSwift_demo
//
//  Created by 赵光飞 on 2018/3/22.
//  Copyright © 2018年 ash. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

struct MusicListViewModel {
    let data = [
        Music(name: "无条件", singer: "陈奕迅"),
        Music(name: "你曾是少年", singer: "S.H.E"),
        Music(name: "从前的我", singer: "陈洁仪"),
        Music(name: "在木星", singer: "朴树")
    ]
    
    let dataObservable = Observable.just([
        Music(name: "无条件", singer: "陈奕迅"),
        Music(name: "你曾是少年", singer: "S.H.E"),
        Music(name: "从前的我", singer: "陈洁仪"),
        Music(name: "在木星", singer: "朴树")
    ])
}

struct Music {
    let name: String // 歌名
    let singer: String //演唱者
    
    init(name: String, singer: String) {
        self.name = name;
        self.singer = singer;
    }
}

extension Music: CustomStringConvertible {
    var description: String {
        return "name: \(name) singer: \(singer)";
    }
}


class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let viewModel = MusicListViewModel()
    //负责对象销毁
    let disposeBag = DisposeBag()
    
    let label = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        tableView.tableFooterView = UIView()
        
        view.addSubview(label)
        label.textAlignment = .center
        label.frame = CGRect(x: 0, y: 0, width: 200, height: 40)
        
        label.center = self.view.center
        
        
        
//        viewModel.dataObservable.bind(to: tableView.rx.items(cellIdentifier:"musicCell")) { _, music, cell in
//            cell.textLabel?.text = music.name
//            cell.detailTextLabel?.text = music.singer
//        }.disposed(by: disposeBag)
//
//        tableView.rx.modelDeselected(Music.self).subscribe(onNext: { (music) in
//            print("你选中的歌曲信息【\(music)】")
//        }).disposed(by: disposeBag)
        
        
        viewModel_demo()
        
        viewModel_demo1()
        
        utilityOperators()
    }
    
    func viewModel_demo() {
        // 创建 Observable 序列
        
        let observable1 = Observable<Any>.empty()
        
        let observable2 = Observable<Int>.just(5)
        
        let observable3 = Observable.of("22", "33", "444")
        
        let observable4 = Observable.from(["22", "33", "444"])
        // 该方法创建一个永远不会发出 Event（也不会终止）的 Observable 序列。
        let observable5 = Observable<Int>.never()
        
        // 该方法创建一个不做任何操作，而是直接发送一个错误的 Observable 序列。
        
        enum CCError: Error {
            case A
            case B
        }
        
        let observable_error = Observable<Int>.error(CCError.A)
        
        let observable6 = Observable<Int>.range(start: 1, count: 5)
        
        // generate() 方法
        
        let observable7 = Observable.generate(initialState: 0, condition: { $0 < 10 }, iterate: {$0 + 2})
        
        let observable8 = Observable<String>.create { (observer) -> Disposable in
            observer.onNext("23444")
            observer.onCompleted()
            return Disposables.create()
        }
        
        observable1.subscribe(onNext: { (event) in
            print(event)
        }).disposed(by: disposeBag)
        
        observable2.subscribe(onNext: { (event) in
            print(event)
        }).disposed(by: disposeBag)
        
        observable3.subscribe(onNext: { (event) in
            print(event)
        }).disposed(by: disposeBag)
        
        observable4.subscribe(onNext: { (event) in
            print(event)
        }).disposed(by: disposeBag)
        
        observable5.subscribe(onNext: { (event) in
            print(event)
        }).disposed(by: disposeBag)
        
        observable6.subscribe(onNext: { (event) in
            print(event)
        }).disposed(by: disposeBag)
        
        observable7.subscribe(onNext: { (event) in
            print(event)
        }).disposed(by: disposeBag)
        
        observable8.subscribe(onNext: { (event) in
            print(event)
        }).disposed(by: disposeBag)
        
        observable_error.subscribe(onNext: { (event) in
            print(event)
        }).disposed(by: disposeBag)
        
        
        let observable = Observable.of("A", "B", "C")
        
        observable
            .do(onNext: { element in
                print("Intercepted Next：", element)
            }, onError: { error in
                print("Intercepted Error：", error)
            }, onCompleted: {
                print("Intercepted Completed")
            }, onDispose: {
                print("Intercepted Disposed")
            })
            .subscribe(onNext: { element in
                print(element)
            }, onError: { error in
                print(error)
            }, onCompleted: {
                print("completed")
            }, onDisposed: {
                print("disposed")
            }).dispose()
        
    }
    
    func viewModel_demo1() {
        let observable = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
        
        observable.map { (n) -> String in
            return "当前索引数：\(n)"
            }.take(10).bind { [weak self] (text) in
                print("当前索引数：\(text)")
                self?.label.text = text;
            }.disposed(by: disposeBag)


        //创建一个初始值为111的Variable
        let variable = Variable("111")
        //修改value值
        variable.value = "222"
         
        //第1次订阅
        variable.asObservable().subscribe {
            print("第1次订阅：", $0)
        }.disposed(by: disposeBag)

        variable.value = "3333"
        
    }
    
    func utilityOperators() {
        Observable.of(1, 2, 3).delay(2, scheduler: MainScheduler.instance)
            .subscribe(onNext: { print($0) }).disposed(by: disposeBag)
        
        
        Observable.of(1, 2, 3).delaySubscription(2, scheduler: MainScheduler.instance)
            .subscribe(onNext: { print($0) }).disposed(by: disposeBag)
        
        
        // timeout
        // 使用该操作符可以设置一个超时时间。如果源 Observable 在规定时间内没有发任何出元素，就产生一个超时的 error 事件。
        
        //定义好每个事件里的值以及发送的时间
        let times = [
            [ "value": 1, "time": 0 ],
            [ "value": 2, "time": 0.5 ],
            [ "value": 3, "time": 1.5 ],
            [ "value": 4, "time": 4 ],
            [ "value": 5, "time": 5 ]
        ]
        
        Observable.from(times).flatMap { (item) in
            return Observable.of(Int(item["value"]!)).delaySubscription(Double(item["time"]!),scheduler: MainScheduler.instance)
            }
            .timeout(2, scheduler: MainScheduler.instance) //超过两秒没发出元素，则产生error事件
            .subscribe(onNext: { element in
                print(element)
            }, onError: { error in
                print(error)
            })
            .disposed(by: disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "musicCell")
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: "musicCell")
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("你选中的歌曲信息【\(viewModel.data[indexPath.row])】")
    }
}

