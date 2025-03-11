//
//  ConsentViewController.swift
//  Phoneado
//
//  Created by Apple on 13/07/22.
//

import UIKit

protocol ConsentDelegate{
    func selectedOption(sender: ConsentViewController, agree: Bool)
}

class ConsentViewController: UIViewController {

    @IBOutlet weak var IagreeBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var consentTextView: UITextView!
    
    var delegate: ConsentDelegate?
    var fromGallaryVC: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setUpUI()
        // Do any additional setup after loading the view.
    }
    
    func setUpUI()
    {
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        if fromGallaryVC
        {
            self.consentTextView.text = "Phoneado will export your pics on Photos. There is an option to Sync your Photos, let’s say you lost your phone you don’t have to worry that your photos are gone, you can download Phoneado again and login there as a guest user. When you login as a guest user you will be able to see the photos which you have synced.\nBy clicking 'I Agree' below, you acknowledge and agree to this collection and use. For more information on the type of data being collected and how it will be used, please see our Privacy Policy."
            self.consentTextView.isUserInteractionEnabled = false
        } else {
            self.consentTextView.text = "Phoneado will export your contacts on server. You can chat, call or video call to those. There is an option to Sync your contacts, let’s say you lost your phone you don’t have to worry that your contacts are gone, you can download Phoneado again and login there as a guest user. When you login as a guest user you will be able to see the contacts which you have synced. You can then freely call and text from there and can even favorite a contact as a Guest.\nBy clicking 'I Agree' below, you acknowledge and agree to this collection  and use. For more information on the type of data being collected and how it will be used, please see our Privacy Policy."
            self.consentTextView.isUserInteractionEnabled = true
            
            let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: consentTextView.text ?? "")
            attributedString.setColorForText(textForAttribute: "Privacy Policy", withColor: UIColor(named: "AppColor") ?? UIColor.black)
            self.consentTextView.attributedText = attributedString
            self.consentTextView.font = UIFont.appFontMedium(size: 12)
            self.consentTextView.addGestureRecognizer(getTapGesture())
        }
        
        self.IagreeBtn.setTitle("I AGREE", for: .normal)
        self.IagreeBtn.backgroundColor = UIColor(named: "AppColor")
        self.IagreeBtn.tintColor = .white
        self.IagreeBtn.applyCorner()
        
        self.cancelBtn.setTitle("CANCEL", for: .normal)
        self.cancelBtn.backgroundColor = UIColor(named: "AppColor")
        self.cancelBtn.tintColor = .white
        self.cancelBtn.applyCorner()
        
    }
    
    func getTapGesture() -> UITapGestureRecognizer
    {
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.viewTapHandler))
        tapGesture.cancelsTouchesInView = false
        return tapGesture
    }
    
    @objc func viewTapHandler(gesture: UITapGestureRecognizer)
    {
        let vc = TermsAndConditionsVC.loadViewController(withStoryBoard: StoryBoardName.loggedIn)
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
    @IBAction func agreeBtnAction(_ sender: Any) {
        if self.delegate != nil {
            Alert().showAlertWithAction(
                title: "Sync Contacts",
                message: "Are you sure you want to sync all your contacts?",
                buttonTitle: "Ok",
                secondBtnTitle: "Cancel",
                withCallback: {
                    self.delegate?.selectedOption(sender: self, agree: true)
                    self.dismiss(animated: true)
                },
                withCancelCallback: {
                    self.dismiss(animated: true)
                }
            )
        }
    }
    
    @IBAction func cancelBtnAction(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
