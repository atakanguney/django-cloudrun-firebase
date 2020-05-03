//
//  ViewController.swift
//  Co-1 IOS
//
//  Created by AtakanGüney on 2.05.2020.
//  Copyright © 2020 AtakanGüney. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {
    @IBOutlet weak var labelValue: UILabel!
    @IBOutlet weak var inputFirst: UITextField!
    @IBOutlet weak var inputSecond: UITextField!
    
    var docRef: DocumentReference!
    var quoteListener: ListenerRegistration!
    
    @IBAction func saveTapped(_ sender: Any) {
        guard let quateText = inputFirst.text, !quateText.isEmpty else {return}
        guard let quateAuthor = inputSecond.text, !quateAuthor.isEmpty else {return}
        let dataToSave: [String: Any] = ["quote": quateText, "author": quateAuthor]
        
        
        docRef.setData(dataToSave) {
            (error) in
            
            if let error = error {
                print("Oh no! \(error)")
            } else {
                print("Done")
            }
        }
    }
    
    @IBAction func fetchTapped(_ sender: Any) {
        docRef.getDocument {(docSnapshot, error) in
            guard let docSnapshot = docSnapshot, docSnapshot.exists else { return }
            let myData = docSnapshot.data() ?? ["quote": "", "author": ""]
            let latestQuate = myData["quote"] as? String ?? ""
            let quateAuthor = myData["author"] as? String ?? ""
            self.labelValue.text = "\"\(latestQuate)\" -- \(quateAuthor)"
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        quoteListener = docRef.addSnapshotListener {(docSnapshot, error) in
            guard let docSnapshot = docSnapshot, docSnapshot.exists else { return }
            let myData = docSnapshot.data() ?? ["quote": "", "author": ""]
            let latestQuate = myData["quote"] as? String ?? ""
            let quateAuthor = myData["author"] as? String ?? ""
            self.labelValue.text = "\"\(latestQuate)\" -- \(quateAuthor)"
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        quoteListener.remove()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        docRef = Firestore.firestore().document("sampleData/inspiration")
    }


}

