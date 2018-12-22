//
//  ViewController.swift
//  MultiPattern
//
//  Created by 李松 on 2018/12/20.
//  Copyright © 2018 Chris. All rights reserved.
//

import UIKit

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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        mvcDidLoad()
        mvpDidLoad()
        minimalDidLoad()
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

extension MultiViewController {
    @IBAction func mvvmCommit(_ sender: Any) {
        
    }
}
