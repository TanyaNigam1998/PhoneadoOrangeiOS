//
//  TermsAndConditionsVC.swift
//  Phoneado
//
//  Created by Zimble on 4/12/22.
//

import UIKit

class TermsAndConditionsVC: UIViewController {
    //MARK: - IB Outlets
    @IBOutlet weak var webView: UIWebView!
    
    @IBOutlet var descLbl: UILabel!
    var isViaSignup:Bool = Bool()
    var type:String = String()
        
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialViewSetup()
        // Do any additional setup after loading the view.
    }
    //MARK: - Required Methods
    func initialViewSetup() {
        
        if (isViaSignup){
            
            guard let file = Bundle.main.path(forResource: "terms", ofType: "html"),
                   let html = try? String(contentsOfFile: file, encoding: String.Encoding.utf8)
               else {
                   return
               }
               webView.loadHTMLString(html, baseURL: nil)
            
//            let url = URL(string: "https://drive.google.com/viewerng/viewer?embedded=true&url=https://phoneadodata.s3.us-east-2.amazonaws.com/Phoneado+Terms+of+Use+3+5+2020.pdf")
//            let requestObj = URLRequest(url: url!)
//            webView.loadRequest(requestObj)
        }else{
            descLbl.text = self.type

            if (self.type == "Terms & Conditions"){
                
                guard let file = Bundle.main.path(forResource: "terms", ofType: "html"),
                       let html = try? String(contentsOfFile: file, encoding: String.Encoding.utf8)
                   else {
                       return
                   }
                   webView.loadHTMLString(html, baseURL: nil)
                
                
//                let url = URL(string: "https://drive.google.com/viewerng/viewer?embedded=true&url=https://phoneadodata.s3.us-east-2.amazonaws.com/Phoneado+Terms+of+Use+3+5+2020.pdf")
//                let requestObj = URLRequest(url: url!)
//                webView.loadRequest(requestObj)

            }else{
                
                guard let file = Bundle.main.path(forResource: "privacy", ofType: "html"),
                       let html = try? String(contentsOfFile: file, encoding: String.Encoding.utf8)
                   else {
                       return
                   }
                   webView.loadHTMLString(html, baseURL: nil)
                
//                let url = URL(string: "https://drive.google.com/viewerng/viewer?embedded=true&url=https://phoneadodata.s3.us-east-2.amazonaws.com/Phoneado_Privacy_PolicyV1.1.pdf")
//                let requestObj = URLRequest(url: url!)
//                webView.loadRequest(requestObj)

            }
        }
 
    }
    //MARK: - IB Actions
    @IBAction func backBtnTapped(_ sender: Any) {
        
        if (isViaSignup){
            self.navigationController?.popViewController(animated: true)
        }else{
            self.dismiss(animated: true, completion: nil)

        }
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}
