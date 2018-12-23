//
//  ViewController.swift
//  MultiPattern
//
//  Created by Bao on 2018/12/20.
//  Copyright © 2018 Chris. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class MultiViewController: UIViewController {
    
    let model = Model(value: "initial value")
    
    @IBOutlet var mvcTextField: UITextField!
    var mvcObserver: NSObjectProtocol?

    @IBOutlet weak var mvpTextField: UITextField!
    var presenter: ViewPrenenter?
    
    @IBOutlet weak var minimalTextField: UITextField!
    var minimalViewModel: MinimalViewModel?
    var minimalObserver: NSObjectProtocol?

    @IBOutlet weak var mvvmTextField: UITextField!
    var mvvmViewModel: ViewModel?
    var mvvmObserver: Disposable?
    
    @IBOutlet weak var mvcvsTextField: UITextField!
    var viewStateObserver: NSObjectProtocol?
    var viewState: ViewState?
    var viewStateModelObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        mvcDidLoad()
        mvpDidLoad()
        minimalDidLoad()
        mvvmDidLoad()
        mvcsDidLoad()
    }
}

extension MultiViewController {
    func mvcDidLoad() {
        mvcTextField.text = model.value
        mvcObserver = NotificationCenter.default.addObserver(forName: Model.textDidChange, object: nil, queue: nil) { [mvcTextField] (noti) in
            mvcTextField?.text = noti.userInfo?[Model.textKey] as? String
        }
    }
    @IBAction func mvcCommit(_ sender: Any) {
        model.value = mvcTextField.text
    }
}

protocol ViewProtocol: class {
    var textFieldValue: String { get set }
}

class ViewPrenenter {
    var model: Model
    weak var view: ViewProtocol?
    let mvpObserver: NSObjectProtocol

    init(model: Model, view: ViewProtocol) {
        self.model = model
        self.view = view
        
        view.textFieldValue = model.value ?? ""
        
        mvpObserver = NotificationCenter.default.addObserver(forName: Model.textDidChange, object: nil, queue: nil) { [view] (noti) in
            view.textFieldValue = noti.userInfo?[Model.textKey] as? String ?? ""
        }
    }
    
    func mvpCommit(value: String) {
        model.value = value
    }
}

extension MultiViewController: ViewProtocol {
    var textFieldValue: String {
        set {
            mvpTextField.text = newValue
        }
        get {
            return mvpTextField.text ?? ""
        }
    }
    func mvpDidLoad() {
        presenter = ViewPrenenter(model: model, view: self)
    }
    @IBAction func mvpCommit(_ sender: Any) {
        presenter?.mvpCommit(value: mvpTextField.text ?? "")
    }
}

class MinimalViewModel: NSObject {
    var model: Model
    
    @objc dynamic var textFieldValue: String
    
    var minimalObserver: NSObjectProtocol?
    
    init(model: Model) {
        self.model = model
        textFieldValue = model.value ?? ""
        super.init()
        minimalObserver = NotificationCenter.default.addObserver(forName: Model.textDidChange, object: nil, queue: nil) { [weak self] (noti) in
            self?.textFieldValue = noti.userInfo?[Model.textKey] as? String ?? ""
        }
    }
    
    func minimalCommit(value: String) {
        model.value = value
    }
}

extension MultiViewController {
    func minimalDidLoad() {
        minimalViewModel = MinimalViewModel(model: model)
        minimalObserver = minimalViewModel?.observe(\.textFieldValue, options: [.initial, .new], changeHandler: { [weak self] (_, change) in
            self?.minimalTextField.text = change.newValue ?? ""
        })
    }
    @IBAction func minimalCommit(_ sender: Any) {
        minimalViewModel?.minimalCommit(value: minimalTextField.text ?? "")
    }
}

class ViewModel {
    var model: Model
    init(model: Model) {
        self.model = model
    }
    
    var textFieldValue = NotificationCenter.default
    .rx.notification(Model.textDidChange, object: nil)
    .map({ (n) -> String in
        n.userInfo?[Model.textKey] as? String ?? ""
    })
    .share(replay: 1, scope: .whileConnected)
    
    func mvvmCommit(value: String) {
        model.value = value
    }
}

extension MultiViewController {
    func mvvmDidLoad() {
        mvvmViewModel = ViewModel(model: model)
        mvvmObserver = mvvmViewModel!.textFieldValue
        .bind(to: self.mvvmTextField.rx.text)
    }
    @IBAction func mvvmCommit(_ sender: Any) {
        mvvmViewModel?.mvvmCommit(value: self.mvvmTextField.text ?? "")
    }
}

class ViewState {
    var textFieldValue: String
    
    init(textFieldValue: String) {
        self.textFieldValue = textFieldValue
    }
}

extension MultiViewController {
    func mvcsDidLoad() {
        viewState = ViewState(textFieldValue: model.value ?? "")
        mvcvsTextField.text = model.value
        viewStateObserver = NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: mvcvsTextField, queue: nil, using: { [weak self] (n) in
            self?.viewState?.textFieldValue = (n.object as! UITextField).text ?? ""
        })
        viewStateModelObserver = NotificationCenter.default.addObserver(forName: Model.textDidChange, object: nil, queue: nil) { [weak self] (n) in
            self?.mvcvsTextField.text = n.userInfo?[Model.textKey] as? String ?? ""
        }
    }
    @IBAction func mvcsCommit(_ sender: Any) {
        model.value = viewState?.textFieldValue
    }
}
